
# process_medians <- function(site_forecasts, out_dir) {
#   site_id <- unique(site_forecasts[["StaID"]])
#   outfile <- file.path(out_dir, paste0(site_id, ".csv"))
#   forecasts |>
#     dplyr::filter(parameter == "median") |>
#     select(StaID, dt = forecast_date, result = prediction)
# }

subset_streamflow <- function(file, start_date, out_dir) {
  dir.create(out_dir, showWarnings = FALSE)
  outfile <- file.path(out_dir, basename(file))
  readr::read_csv(file, col_types = cols(StaID = "c")) |>
    select(StaID, dt, result = Flow_7d, pd = weibull_jd_30d_wndw_7d) |>
    filter(dt >= start_date) |>
    readr::write_csv(outfile)

  return(outfile)
}

#' @description Munge input spatial data for CONUS gages
#' 
#' @param in_file The filepath for the raw shapefile downloaded from s3
#' @param forecast_sites vector of site ids for subsetting the spatial data
#' @param out_file The filepath for the munged output shapefile
#' @returns The output filepath for the munged shapefile
#'
munge_conus_gages <- function(in_file, forecast_sites, out_file) {
  
  sf::st_read(in_file) |>
    sf::st_drop_geometry()|>
    sf::st_as_sf(coords = c("dec_long_v", "dec_lat_va"), crs = "EPSG:4269") |>
    dplyr::select(StaID = site_no, station_nm, state_cd, county_cd, huc_cd) |>
    dplyr::mutate("StaID" = stringr::str_pad(StaID, 8, pad = "0")) |>
    dplyr::filter(StaID %in% forecast_sites) |>
    sf::st_write(out_file, append = FALSE)
  
  return(out_file)
}

munge_gage_info <- function(gages_shp) {
  conus_counties <- tigris::counties(cb = TRUE, resolution = "20m") |>
    sf::st_drop_geometry()
  
  sf::read_sf(gages_shp) |>
    dplyr::mutate(StaID = ifelse(nchar(as.character(StaID)) == 8,
                                 as.character(StaID),
                                 paste0("0", as.character(StaID)))) |>
    sf::st_drop_geometry() |>
    mutate("GEOID" = paste0(state_cd, stringr::str_pad(county_cd, 3, pad = "0"))) |>
    left_join(conus_counties, by = "GEOID") |>
    select(StaID, station_nm, huc_cd, state = STATE_NAME, county = NAMELSAD)
}

#' @title process thresholds data
#' 
#' @param thresholds_csv csv with historical streamflow and thresholds data
#' @param date_subset vector of sequential dates for which we need jd thresholds
#' @param replace_negative_flow_w_zero T/F replace negative threshold flow values
#' on log scale
#' 
#' @returns julian day 5, 10, and 20 percentile thresholds
#'
process_thresholds_data <- function(thresholds_csv, date_subset, 
                                    replace_negative_flow_w_zero) {
  
  jd_subset <- lubridate::yday(date_subset)
  
  thresholds <- readr::read_csv(thresholds_csv, col_types = cols(StaID = "c"))
  threshold_fields <- colnames(thresholds)
  threshold_fields <- threshold_fields[grepl("thresh_\\d+_jd_30d_wndw_7d", threshold_fields)]
  
  thresholds_jd <- thresholds |>
    group_by(StaID, jd) |>
    summarize(across(all_of(threshold_fields), ~first(.x)), .groups = "drop") |>
    filter(jd %in% jd_subset) |>
    pivot_longer(cols = all_of(threshold_fields), 
                 names_to = "percentile_threshold",
                 names_pattern = "(\\d+)",
                 names_transform = list(percentile_threshold = as.integer),
                 values_to = "Flow_7d") |>
    filter(percentile_threshold <= 20 & percentile_threshold >= 5)
  
  if (replace_negative_flow_w_zero) {
    thresholds_jd <- thresholds_jd |>
      mutate(
        Flow_7d = ifelse(Flow_7d < 0,
                         0,
                         Flow_7d)
      )
  }
  
  return(thresholds_jd)
}

munge_raw_forecast_data <- function(forecast_feathers, forecast_sites, 
                                    replace_out_of_bound_predictions) {
  forecast_data <- arrow::open_dataset(
    sources = forecast_feathers,
    format = 'feather') |>
    dplyr::collect() |>
    dplyr::rename('StaID' = 'site_id') |>
    # filter to subset defined by p1_sites
    dplyr::filter(StaID %in% forecast_sites) |>
    dplyr::mutate(
      issue_date = as.Date(reference_datetime, 
                           tz = 'America/New_York'),
      forecast_date = as.Date(datetime, tz = 'America/New_York'),
      forecast_week = as.integer(difftime(forecast_date, 
                                          issue_date, 
                                          units="weeks"))
    ) |>
    dplyr::arrange(forecast_date, StaID)
  
  if (replace_out_of_bound_predictions) {
    forecast_data <- forecast_data |>
      mutate(prediction = case_when(
        prediction > 100 ~ 100,
        prediction < 0 ~ 0,
        TRUE ~ prediction
      ))
  }
  
  return(forecast_data)
}

#' @title convert forecast percentiles to cfs
#' 
#' @param site_forecasts forecast percentile values
#' @param thresholds_csv csv with historical streamflow and thresholds data
#' @param thresholds_jd unique thresholds for each jd
#' @returns forecasts in units of flow as well as percentiles
#'
#' Follow's Caelan's approach here: 
# https://code.chs.usgs.gov/wma/drought_prediction/streamflow-target-data/-/blob/main/Operational_Scripts/convert_percentiles_to_flow_using_saved_files.R
convert_percentiles_to_cfs <- function(site_forecasts, thresholds_csv, 
                                       thresholds_jd) {
  
  thresholds <- readr::read_csv(thresholds_csv, col_types = cols(StaID = "c"))
  df_pct <- thresholds |>
    select(c(StaID, dt, jd, mean_value_7d, weibull_jd_7d, weibull_site_7d, 
             weibull_jd_30d_wndw_7d)) |>
    rename(Flow_7d = mean_value_7d)
  
  df_sub <- site_forecasts |>
    rename(dt = forecast_date) |>
    mutate(Flow_7d = NA,
           jd = lubridate::yday(dt),
           modeled_data = "Yes")
  
  pct_type <- df_sub[["variable"]][[1]]
  df_sub[pct_type] <- df_sub[["prediction"]]
  
  df_both <- bind_rows(df_sub, 
                       # Add in forecasts (missing percentile values)
                       dplyr::select(df_pct, 
                                     all_of(c("StaID", "dt", "jd", pct_type, 
                                              "Flow_7d"))),
                       # Add in percentile thresholds
                       dplyr::select(thresholds_jd, 
                                     all_of(c("StaID", "jd", 
                                              "percentile_threshold", 
                                              "Flow_7d"))) |>
                         rename({{ pct_type }} := percentile_threshold)
  )
  
  df_both["percentiles"] <- df_both[pct_type]
  
  df_both <- df_both |>
    group_by(jd) |>
    arrange(percentiles) |>
    # Use rule 2 of approx to use closest data extreme for points beyond end of range
    mutate(Flow_7d = zoo::na.approx(Flow_7d, percentiles, na.rm = FALSE, 
                                    ties = 'mean', rule = 2))
  
  df_new_pct <- filter(df_both, !is.na(modeled_data)) |>
    ungroup() |>
    select(-c(modeled_data, percentiles, all_of(pct_type))) |>
    arrange(dt) |>
    select(StaID, dt, jd, forecast_week, parameter, prediction, Flow_7d)
  
  return(df_new_pct)
}

join_median_forecasts_and_spatial_data <- function(forecasts, gages_shp) {
  gages_sf <- sf::read_sf(gages_shp)
  
  forecasts |>
    dplyr::select(StaID, f_w, median) |>
    pivot_wider(id_cols = "StaID", names_from = "f_w", names_prefix = "pd",
                values_from = "median") |>
    dplyr::left_join(dplyr::select(gages_sf, StaID)) |>
    sf::st_as_sf()
}

generate_forecast_csvs <- function(site_forecasts, outfile_template) {
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  
  outfile <- sprintf(outfile_template, unique(site_forecasts[["StaID"]]))
  
  site_forecasts |>
    select(StaID, dt, parameter, result = Flow_7d, pd = prediction) |>
    readr::write_csv(outfile)
  
  return(outfile)
}

generate_threshold_band_csvs <-function(thresholds_jd, date_subset, 
                                        outfile_template) {
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  
  outfile <- sprintf(outfile_template, unique(thresholds_jd[["StaID"]]))

  date_tibble <- tibble(
    dt = date_subset,
    jd = lubridate::yday(dt)
  )
  
  thresholds_jd |>
    group_by(jd) |>
    arrange(percentile_threshold) |>
    mutate(
      result_min = ifelse(is.na(lag(Flow_7d)), 0, lag(Flow_7d))
    ) |>
    rename(pd = percentile_threshold, result_max = Flow_7d) |>
    left_join(date_tibble) |>
    readr::write_csv(outfile)
  
  return(outfile)
}

generate_buffer_dates <- function(forecast_info, bar_width_days) {
  date_buffer <- (bar_width_days - 1) / 2
  forecast_dates <- pull(forecast_info, forecast_date)
  
  # Pull out the dates in addition to the forecast date for which we want to
  # avoid masking the thresholds
  dates_minus <- purrr::map(seq(1,date_buffer), ~forecast_dates - .x) |> 
    unlist() |> 
    lubridate::as_date()
  dates_plus <- purrr::map(seq(1,date_buffer), ~forecast_dates + .x) |> 
    unlist() |> 
    lubridate::as_date()
  forecast_weeks <- unique(forecast_info[["f_w"]])
  buffer_dates <- tibble(dt = c(dates_minus, dates_plus)) |> 
    arrange(dt) |>
    mutate(
      jd = lubridate::yday(dt),
      forecast_week = rep(forecast_weeks, each  = (bar_width_days - 1))
    )
}

generate_lower_overlay <- function(site_forecasts, thresholds_jd, 
                                   buffer_dates, date_subset,
                                   outfile_template) {
  
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  
  outfile <- sprintf(outfile_template, unique(site_forecasts[["StaID"]]))

  # For the lower overlay, the max value will be the 20th percentile threshold,
  # OR, where we have forecasts +/- the date_buffer, the 5% quantile prediction, 
  # if that value is < the 20th percentile threshold
  dip_data <- site_forecasts |>
    filter(parameter == "pred_interv_05")
  
  # join the extra dates to the 5% quantile predictions, fill with the predicted
  # flow, then compare the predicted flow to the 20th percentile threshold,
  # setting the latter as the flow value if it is < the prediction
  dip_data <- bind_rows(dip_data, buffer_dates) |>
    arrange(dt) |>
    group_by(forecast_week) |>
    fill(StaID, prediction, Flow_7d, .direction = "downup") |>
    ungroup() |>
    left_join(thresholds_jd |>
                filter(percentile_threshold == "20") |>
                select(jd, threshold_Flow_7d = Flow_7d),
              by = "jd") |>
    mutate(Flow_7d = ifelse(Flow_7d < threshold_Flow_7d, 
                            Flow_7d, 
                            threshold_Flow_7d),
           prediction = ifelse(Flow_7d < threshold_Flow_7d, 
                               prediction, 
                               20))
  
  # pull out the edge jd dates (min and max dates) for each 'dip' in the overlay
  min_dip_jds <- dip_data |>
    group_by(forecast_week) |>
    summarize(jd = min(jd)) |>
    pull(jd)
  
  max_dip_jds <- dip_data |>
    group_by(forecast_week) |>
    summarize(jd = max(jd)) |>
    pull(jd)
  
  # identify the non-edge jd dates for each 'dip' in the overlay
  exclude_jds <- dip_data |>
    filter(!(jd %in% c(min_dip_jds, max_dip_jds))) |>
    pull(jd)
  
  # pull together the final lower overlay dataset
  # for 'min' edge dates, we need to plot the threshold value, then the dip value
  # for 'max' edge dates, we need to plot the dip value, then the threshold value
  lower_overlay_data <- thresholds_jd |> 
    dplyr::filter(percentile_threshold == "20" & !(jd %in% exclude_jds)) |>
    mutate(plot_group = case_when(
      jd >= max_dip_jds[[5]] ~ 11,
      jd >= max_dip_jds[[4]] ~ 9,
      jd >= max_dip_jds[[3]] ~ 7,
      jd >= max_dip_jds[[2]] ~ 5,
      jd >= max_dip_jds[[1]] ~ 3,
      jd <= max_dip_jds[[1]] ~ 1,
      TRUE ~ NA
    )) |>
    bind_rows(dip_data) |>
    mutate(plot_group = case_when(
      !(is.na(plot_group)) ~ plot_group,
      jd >= min_dip_jds[[5]] ~ 10,
      jd >= min_dip_jds[[4]] ~ 8,
      jd >= min_dip_jds[[3]] ~ 6,
      jd >= min_dip_jds[[2]] ~ 4,
      jd >= min_dip_jds[[1]] ~ 2,
      TRUE ~ NA
    )) |>
    arrange(jd, plot_group) |>
    mutate(prediction = ifelse(is.na(prediction), 
                               percentile_threshold, 
                               prediction))
  
  # Add back in dates for plotting
  date_tibble <- tibble(
    dt = date_subset,
    jd = lubridate::yday(dt)
  )
  
  lower_overlay_data <- lower_overlay_data |>
    select(StaID, jd, pd = prediction, result_max = Flow_7d) |>
    mutate(result_min = 0) |>
    left_join(date_tibble) |>
    readr::write_csv(outfile)
  
  return(outfile)
}

generate_upper_overlay <- function(site_forecasts, thresholds_jd, 
                                   buffer_dates, date_subset,
                                   outfile_template) {
  
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  
  outfile <- sprintf(outfile_template, unique(site_forecasts[["StaID"]]))

  # The upper overlay will only be present where the 95% quantile prediction is
  # < the 20th percentile threshold, +/- the date_buffer. The max value will be 
  # the 20th percentile threshold, and the min value will be the 95% quantile 
  # prediction
  upper_overlay_data <- site_forecasts |>
    filter(parameter == "pred_interv_95") |>
    bind_rows(buffer_dates) |>
    arrange(dt) |>
    group_by(forecast_week) |>
    fill(StaID, prediction, Flow_7d, .direction = "downup") |>
    ungroup() |>
    left_join(thresholds_jd |>
                filter(percentile_threshold == "20") |>
                select(jd, threshold_Flow_7d = Flow_7d),
              by = "jd") |>
    mutate(ymin = ifelse(Flow_7d < threshold_Flow_7d, Flow_7d, NA),
           ymax = ifelse(Flow_7d < threshold_Flow_7d, threshold_Flow_7d, NA),
           prediction = ifelse(Flow_7d < threshold_Flow_7d, prediction, NA)) |>
    filter(!is.na(ymin))
  
  # Add back in dates for plotting
  date_tibble <- tibble(
    dt = date_subset,
    jd = lubridate::yday(dt)
  )
  
  upper_overlay_data <- upper_overlay_data |>
    select(StaID, jd, f_w = forecast_week, pd = prediction, result_max = ymax, 
           result_min = ymin) |>
    left_join(date_tibble) |>
    readr::write_csv(outfile)
  
  return(outfile)
}
