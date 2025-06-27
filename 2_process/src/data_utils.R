
build_date_info_table <- function(issue_date, forecasts) {
  current_info <-
    tibble(
      issue_date = issue_date,
      date = issue_date - 1, # Day before is when we have current conditiosn info
      f_w = 0
    )
  forecast_info <- 
    tibble(
      issue_date = issue_date,
      date = unique(forecasts[["forecast_date"]]),
      f_w = unique(forecasts[["forecast_week"]]),
    )
  dplyr::bind_rows(current_info, forecast_info)
}

subset_streamflow <- function(file, start_date) {
  readr::read_csv(file, col_types = cols(StaID = "c")) |>
    dplyr::select(StaID, dt, Flow_7d, weibull_jd_30d_wndw_7d) |>
    dplyr::filter(dt >= start_date)
}

munge_streamflow <- function(site, streamflow_csv, thresholds_csv, 
                             thresholds_jd_csv, start_date, 
                             replace_negative_flow_w_zero, outfile_template) {

  # subset streamflow
  subset_streamflow <- subset_streamflow(streamflow_csv, start_date)
  
  if (!(site == unique(subset_streamflow[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in streamflow data"))
  }
  
  # if streamflow is NA, go ahead and return as-is, without more processing
  if (all(is.na(subset_streamflow[["Flow_7d"]]))) {
    munged_streamflow <- subset_streamflow |>
      mutate(jd = yday(dt)) |>
      select(StaID, dt, jd, result = Flow_7d, pd = weibull_jd_30d_wndw_7d)
  } else {
    # load in thresholds data
    thresholds <- readr::read_csv(thresholds_csv, col_types = cols(StaID = "c"))
    thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                     col_types = cols(StaID = "c"))
    
    if (!(site == unique(thresholds[["StaID"]]))) {
      stop(message("Provided site doesn't match StaID in thresholds data"))
    }
    if (!(site == unique(thresholds_jd[["StaID"]]))) {
      stop(message("Provided site doesn't match StaID in thresholds_jd data"))
    }
    
    # replace negative values, if directed
    if (replace_negative_flow_w_zero) {
      subset_streamflow <- subset_streamflow |>
        mutate(
          Flow_7d = ifelse(Flow_7d < 0,
                           0,
                           Flow_7d)
        )
    }
    
    # recompute streamflow percentiles
    converted_streamflow <- convert_cfs_to_percentiles(site, subset_streamflow, 
                                                       thresholds, thresholds_jd)
    
    # adjust column names
    munged_streamflow <- converted_streamflow |> 
      dplyr::rename(result = Flow_7d)
  }
  
  # save subsetted and converted streamflow
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(munged_streamflow, outfile)
  
  return(outfile)
}

identify_streamflow_droughts <- function(site, streamflow_csv, thresholds_jd_csv,
                                         outfile_template) {
  
  streamflow <- readr::read_csv(streamflow_csv, col_types = cols(StaID = "c"))
  
  thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                   col_types = cols(StaID = "c"))
  
  if (!(site == unique(streamflow[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in streamflow data"))
  }
  if (!(site == unique(thresholds_jd[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in thresholds_jd data"))
  }
  
  # use 1981-2020 thresholds to define drought bins
  thresholds_wide <- thresholds_jd |>
    pivot_wider(id_cols = c(StaID, jd),
                names_from = percentile_threshold,
                names_prefix = "percentile_threshold_",
                values_from = "Flow_7d")
  
  streamflow <- streamflow |>
    mutate(jd = lubridate::yday(dt)) |>
    left_join(thresholds_wide, by = c("StaID", "jd")) |>
    mutate(
      drought_cat = case_when(
        result <= percentile_threshold_5 ~ "5",
        result <= percentile_threshold_10 ~ "10",
        result <= percentile_threshold_20 ~ "20",
        TRUE ~ NA
      )
    )|>
    select(StaID, dt, drought_cat)
  
  streamflow_droughts <- streamflow |>
    filter(!is.na(drought_cat))
  
  if (nrow(streamflow_droughts) == 0) {
    # empty table
    streamflow_droughts_wide <- tibble(
      StaID = character(),
      drought_cat = character(),
      start = date(),
      end = date()
    )
  } else {
    streamflow_droughts_wide <- streamflow_droughts |>
      group_by(StaID, drought_cat) |>
      mutate(group = cumsum(c(TRUE, diff(dt) > 1))) |>
      group_by(group, .add = TRUE) |>
      summarise(start = min(dt), end = max(dt) + 1, .groups = "drop") |>
      select(StaID, drought_cat, start, end) |>
      arrange(start)
  }
  
  # save streamflow droughts
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(streamflow_droughts_wide, outfile)
  
  return(outfile)
}

#' @description Munge input spatial data for CONUS gages
#' 
#' @param in_shp The filepath for the raw shapefile downloaded from s3
#' @param forecast_sites vector of site ids for subsetting the spatial data
#' @param outfile The filepath for the munged output shapefile
#' @returns The output filepath for the munged shapefile
#'
munge_conus_gages <- function(in_shp, forecast_sites, outfile) {
  
  sf::st_read(in_shp) |>
    sf::st_drop_geometry()|>
    sf::st_as_sf(coords = c("dec_long_v", "dec_lat_va"), crs = "EPSG:4269") |>
    dplyr::select(StaID = site_no, station_nm, state_cd, county_cd, huc_cd) |>
    dplyr::mutate("StaID" = stringr::str_pad(StaID, 8, pad = "0")) |>
    dplyr::filter(StaID %in% forecast_sites) |>
    sf::st_write(outfile, append = FALSE)
  
  return(outfile)
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
process_thresholds_data <- function(site, thresholds_csv, date_subset, 
                                    replace_negative_flow_w_zero,
                                    outfile_template) {
  
  jd_subset <- lubridate::yday(date_subset)
  
  thresholds <- readr::read_csv(thresholds_csv, col_types = cols(StaID = "c"))
  
  if (!(site == unique(thresholds[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in thresholds data"))
  }
  
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
  
  # Save processed thresholds
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(thresholds_jd, outfile)
  
  return(outfile)
}

munge_raw_forecast_data <- function(forecast_feathers, forecast_sites, 
                                    replace_out_of_bound_predictions) {
  forecast_data <- arrow::open_dataset(
    sources = forecast_feathers,
    format = "feather") |>
    dplyr::collect() |>
    dplyr::rename("StaID" = "site_id") |>
    # filter to subset defined by p1_sites
    dplyr::filter(StaID %in% forecast_sites) |>
    dplyr::mutate(
      issue_date = as.Date(reference_datetime, 
                           tz = "America/New_York"),
      forecast_date = as.Date(datetime, tz = "America/New_York"),
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

#' @title convert cfs to percentiles
#' Input streamflow have percentiles, but they seem not to have been computed
#' w/ the percentile thresholds included in the interpolation set, since the
#' converted flow values, when compared to threshold cfs values, suggest different
#' percentiles than is noted in the raw data, e.g for site "02313230" on jd 112
#' 
#' @param streamflow streamflow values
#' @param thresholds historical streamflow and thresholds data
#' @param thresholds_jd unique thresholds for each jd
#' @returns streamflow in units of flow as well as percentiles
#'
#' Mimic Caelan's approach here: 
# https://code.chs.usgs.gov/wma/drought_prediction/streamflow-target-data/-/blob/main/Operational_Scripts/convert_percentiles_to_flow_using_saved_files.R
convert_cfs_to_percentiles <- function(site, streamflow, thresholds, 
                                       thresholds_jd) {
  
  df_pct <- thresholds |>
    select(c(StaID, dt, jd, mean_value_7d, weibull_jd_7d, weibull_site_7d, 
             weibull_jd_30d_wndw_7d)) |>
    rename(Flow_7d = mean_value_7d)
  
  pct_type <- "weibull_jd_30d_wndw_7d"
  
  df_sub <- streamflow |>
    mutate(
      pd_orig = get(pct_type),
      jd = lubridate::yday(dt),
      streamflow_data = "Yes",
      !!pct_type := NA
    )
  
  df_both <- bind_rows(
    # streamflow, for which we want to recompute percentile values
    df_sub, 
    # Add in historical flow and percentiles data
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
  
  # recompute percentile values with interpolation
  streamflow_jds <- unique(df_sub[["jd"]])
  df_both <- purrr::map(streamflow_jds, function(streamflow_jd) {
    jd_values <- df_both |>
      dplyr::filter(jd == streamflow_jd & !is.na(Flow_7d))
    if (all(jd_values[["Flow_7d"]] == 0)) {
      # If all Flow on jd is 0, keep original streamflow percentile
      jd_values <- jd_values |>
        mutate(percentiles = ifelse(is.na(percentiles), pd_orig, percentiles))
    } else if (any(jd_values[["Flow_7d"]] == 0)) {
      # otherwise recompute, interpolating based on historical and threshold
      # percentiles
      # But only include highest percentile historical zero-flow value in
      # interpolation
      highest_percentile_zero_flow_value <- jd_values |>
        dplyr::filter(Flow_7d == 0 & is.na(streamflow_data)) |>
        slice_max(percentiles)
      jd_values <- jd_values |>
        dplyr::filter(Flow_7d > 0 | !is.na(streamflow_data)) |>
        bind_rows(highest_percentile_zero_flow_value) |>
        arrange(Flow_7d, percentiles) |>
        # Use rule 2 of approx to use closest data extreme for points beyond end of range
        mutate(percentiles = zoo::na.approx(percentiles, Flow_7d, na.rm = FALSE,
                                            ties = "mean", rule = 2))
    } else {
      # otherwise recompute, interpolating based on historical and threshold
      # percentiles
      jd_values <- jd_values |>
        arrange(Flow_7d, percentiles) |>
        # Use rule 2 of approx to use closest data extreme for points beyond end of range
        mutate(percentiles = zoo::na.approx(percentiles, Flow_7d, na.rm = FALSE,
                                            ties = "mean", rule = 2))
    }
    return(jd_values)
  }) |>
    list_rbind()

  # df_both <- df_both |>
  #   dplyr::filter(jd %in% unique(df_sub[["jd"]])) |>
  #   group_by(jd) |>
  #   group_modify(~ {
  #     .x <- dplyr::filter(.x, !is.na(Flow_7d))
  #     if (all(.x[["Flow_7d"]] == 0)) {
  #       # If all Flow on jd is 0, keep original streamflow percentile
  #       .x |>
  #         mutate(percentiles = ifelse(is.na(percentiles), pd_orig, percentiles))
  #     } else if (any(.x[["Flow_7d"]] == 0)) {
  #       # otherwise recompute, interpolating based on historical and threshold
  #       # percentiles
  #       # But only include highest percentile historical zero-flow value in
  #       # interpolation
  #       highest_percentile_zero_flow_value <- .x |>
  #         dplyr::filter(Flow_7d == 0 & is.na(streamflow_data)) |>
  #         slice_max(percentiles)
  #       .x |>
  #         dplyr::filter(Flow_7d > 0 | !is.na(streamflow_data)) |>
  #         bind_rows(highest_percentile_zero_flow_value) |>
  #         arrange(Flow_7d, percentiles) |>
  #         # Use rule 2 of approx to use closest data extreme for points beyond end of range
  #         mutate(percentiles = zoo::na.approx(percentiles, Flow_7d, na.rm = FALSE, 
  #                                             ties = "mean", rule = 2))
  #     } else {
  #       # otherwise recompute, interpolating based on historical and threshold
  #       # percentiles
  #       .x |>
  #         arrange(Flow_7d, percentiles) |>
  #         # Use rule 2 of approx to use closest data extreme for points beyond end of range
  #         mutate(percentiles = zoo::na.approx(percentiles, Flow_7d, na.rm = FALSE, 
  #                                             ties = "mean", rule = 2))
  #     }
  #   }) |>
  #   ungroup()
  
  df_new_pct <- filter(df_both, !is.na(streamflow_data)) |>
    arrange(dt) |>
    select(StaID, dt, jd, Flow_7d, pd = percentiles)

  return(df_new_pct)
}

#' @title convert forecast percentiles to cfs
#' 
#' @param site_forecast forecast percentile values
#' @param thresholds historical streamflow and thresholds data
#' @param thresholds_jd unique thresholds for each jd
#' @returns forecasts in units of flow as well as percentiles
#'
#' Follow's Caelan's approach here: 
# https://code.chs.usgs.gov/wma/drought_prediction/streamflow-target-data/-/blob/main/Operational_Scripts/convert_percentiles_to_flow_using_saved_files.R
convert_percentiles_to_cfs <- function(site, site_forecast, thresholds, 
                                       thresholds_jd) {
  
  df_pct <- thresholds |>
    select(c(StaID, dt, jd, mean_value_7d, weibull_jd_7d, weibull_site_7d, 
             weibull_jd_30d_wndw_7d)) |>
    rename(Flow_7d = mean_value_7d)
  
  df_sub <- site_forecast |>
    rename(dt = forecast_date) |>
    mutate(Flow_7d = NA,
           jd = lubridate::yday(dt),
           modeled_data = "Yes")
  
  pct_type <- df_sub[["variable"]][[1]]
  df_sub[pct_type] <- df_sub[["prediction"]]
  
  df_both <- bind_rows(
    # forecasts (missing flow values)
    df_sub, 
    # Add in historical flow and percentiles data
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
  
  # estimate missing flow values with interpolation
  df_both <- df_both |>
    dplyr::filter(jd %in% unique(df_sub[["jd"]])) |>
    group_by(jd) |>
    arrange(percentiles) |>
    # Use rule 2 of approx to use closest data extreme for points beyond end of range
    mutate(Flow_7d = zoo::na.approx(Flow_7d, percentiles, na.rm = FALSE, 
                                    ties = "mean", rule = 2))
  
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

convert_forecast_percentiles_to_cfs <- function(site, site_forecast, 
                                                 thresholds_csv,
                                                 thresholds_jd_csv, 
                                                 outfile_template) {
  
  thresholds <- readr::read_csv(thresholds_csv, col_types = cols(StaID = "c"))
  thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                   col_types = cols(StaID = "c"))
  
  if (!(site == unique(site_forecast[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in site_forecast data"))
  }
  if (!(site == unique(thresholds[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in thresholds data"))
  }
  if (!(site == unique(thresholds_jd[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in thresholds_jd data"))
  }
  
  converted_forecasts <- convert_percentiles_to_cfs(site, site_forecast, 
                                                    thresholds, thresholds_jd)

  # # use 1981-2020 thresholds to define drought bins
  # thresholds_wide <- thresholds_jd |>
  #   pivot_wider(id_cols = c(StaID, jd), 
  #               names_from = percentile_threshold, 
  #               names_prefix = "percentile_threshold_",
  #               values_from = "Flow_7d")
  
  munged_forecasts <- converted_forecasts |>
    # left_join(thresholds_wide, by = c("StaID", "jd")) |>
    mutate(
      drought_cat = case_when(
        prediction < 5 ~ "5",
        prediction < 10 ~ "10",
        prediction < 20 ~ "20",
        TRUE ~ "none"
      )
      # drought_cat = case_when(
      #   Flow_7d <= percentile_threshold_5 ~ "5",
      #   Flow_7d <= percentile_threshold_10 ~ "10",
      #   Flow_7d <= percentile_threshold_20 ~ "20",
      #   TRUE ~ "none" 
      # )
    )|>
    select(StaID, dt, jd, f_w = forecast_week, parameter, result = Flow_7d, 
           pd = prediction, drought_cat)
  
  # save forecasts
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(munged_forecasts, outfile)
  
  return(outfile)
}

generate_threshold_band_csv <-function(site, thresholds_jd_csv, date_subset, 
                                        outfile_template) {
  thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                   col_types = cols(StaID = "c"))

  if (!(site == unique(thresholds_jd[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in thresholds_jd data"))
  }

  date_tibble <- tibble(
    dt = date_subset,
    jd = lubridate::yday(dt)
  )
  
  threshold_bands <- thresholds_jd |>
    group_by(jd) |>
    arrange(percentile_threshold) |>
    mutate(
      result_min = ifelse(is.na(lag(Flow_7d)), 0, lag(Flow_7d))
    ) |>
    rename(pd = percentile_threshold, result_max = Flow_7d) |>
    left_join(date_tibble, by = "jd")
  
  # save threshold bands
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(threshold_bands, outfile)
  
  return(outfile)
}

generate_buffer_dates <- function(date_info, bar_width_days) {
  date_buffer <- (bar_width_days - 1) / 2
  forecast_info <- date_info |>
    dplyr::filter(f_w > 0)
  forecast_dates <- pull(forecast_info, date)
  
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
      f_w = rep(forecast_weeks, each  = (bar_width_days - 1))
    )
}

generate_lower_overlay <- function(site, site_forecast_csv, thresholds_jd_csv, 
                                   buffer_dates, date_subset,
                                   outfile_template) {
  
  site_forecast <- readr::read_csv(site_forecast_csv, 
                                   col_types = cols(StaID = "c")) |>
    rename(Flow_7d = result)
  thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                   col_types = cols(StaID = "c"))
  
  if (!(site == unique(site_forecast[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in site_forecast data"))
  }
  if (!(site == unique(thresholds_jd[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in thresholds_jd data"))
  }

  # For the lower overlay, the max value will be the 20th percentile threshold,
  # OR, where we have forecasts +/- the date_buffer, the 5% quantile prediction, 
  # if that value is < the 20th percentile threshold
  dip_data <- site_forecast |>
    filter(parameter == "pred_interv_05")
  
  # join the extra dates to the 5% quantile predictions, fill with the predicted
  # flow, then compare the predicted flow to the 20th percentile threshold,
  # setting the latter as the flow value if it is < the prediction
  dip_data <- bind_rows(dip_data, buffer_dates) |>
    arrange(dt) |>
    group_by(f_w) |>
    fill(StaID, pd, Flow_7d, .direction = "downup") |>
    ungroup() |>
    left_join(thresholds_jd |>
                filter(percentile_threshold == "20") |>
                select(jd, threshold_Flow_7d = Flow_7d),
              by = "jd") |>
    mutate(Flow_7d = ifelse(Flow_7d < threshold_Flow_7d, 
                            Flow_7d, 
                            threshold_Flow_7d),
           pd = ifelse(Flow_7d < threshold_Flow_7d, 
                       pd, 
                       20))
  
  # pull out the edge jd dates (min and max dates) for each 'dip' in the overlay
  min_dip_jds <- dip_data |>
    group_by(f_w) |>
    summarize(jd = min(jd)) |>
    pull(jd)
  
  max_dip_jds <- dip_data |>
    group_by(f_w) |>
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
    mutate(pd = ifelse(is.na(pd), 
                       percentile_threshold, 
                       pd))
  
  # Add back in dates for plotting
  date_tibble <- tibble(
    dt = date_subset,
    jd = lubridate::yday(dt)
  )
  
  lower_overlay_data <- lower_overlay_data |>
    select(StaID, jd, pd, result_max = Flow_7d) |>
    mutate(result_min = 0) |>
    left_join(date_tibble, by = "jd")
  
  # save lower overlay
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(lower_overlay_data, outfile)
  
  return(outfile)
}

generate_upper_overlay <- function(site, site_forecast_csv, thresholds_jd_csv, 
                                   buffer_dates, date_subset,
                                   outfile_template) {
  
  site_forecast <- readr::read_csv(site_forecast_csv, 
                                   col_types = cols(StaID = "c")) |>
    rename(Flow_7d = result)
  thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                   col_types = cols(StaID = "c"))
  
  if (!(site == unique(site_forecast[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in site_forecast data"))
  }
  if (!(site == unique(thresholds_jd[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in thresholds_jd data"))
  }

  # The upper overlay will only be present where the 95% quantile prediction is
  # < the 20th percentile threshold, +/- the date_buffer. The max value will be 
  # the 20th percentile threshold, and the min value will be the 95% quantile 
  # prediction
  upper_overlay_data <- site_forecast |>
    filter(parameter == "pred_interv_95") |>
    bind_rows(buffer_dates) |>
    arrange(dt) |>
    group_by(f_w) |>
    fill(StaID, pd, Flow_7d, .direction = "downup") |>
    ungroup() |>
    left_join(thresholds_jd |>
                filter(percentile_threshold == "20") |>
                select(jd, threshold_Flow_7d = Flow_7d),
              by = "jd") |>
    mutate(ymin = ifelse(Flow_7d < threshold_Flow_7d, Flow_7d, NA),
           ymax = ifelse(Flow_7d < threshold_Flow_7d, threshold_Flow_7d, NA),
           pd = ifelse(Flow_7d < threshold_Flow_7d, pd, NA)) |>
    filter(!is.na(ymin))
  
  # Add back in dates for plotting
  date_tibble <- tibble(
    dt = date_subset,
    jd = lubridate::yday(dt)
  )
  
  upper_overlay_data <- upper_overlay_data |>
    select(StaID, jd, f_w, pd, result_max = ymax, 
           result_min = ymin) |>
    left_join(date_tibble, by = "jd")
  
  # save upper overlay
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(upper_overlay_data, outfile)
  
  return(outfile)
}
