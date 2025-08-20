
build_date_info_table <- function(issue_date, latest_streamflow_date, forecasts) {
  current_info <-
    tibble(
      issue_date = issue_date,
      dt = latest_streamflow_date, # Latest streamflow date
      f_w = 0
    )
  forecast_info <- 
    tibble(
      issue_date = issue_date,
      dt = unique(forecasts[["dt"]]),
      f_w = unique(forecasts[["f_w"]]),
    )
  dplyr::bind_rows(current_info, forecast_info) |>
    dplyr::mutate(dt_formatted = format(dt, format="%m/%d/%y"))
}

subset_streamflow <- function(file, start_date, end_date) {
  readr::read_csv(file, col_types = cols(StaID = "c")) |>
    dplyr::filter(dt >= start_date, dt <= end_date) |>
    dplyr::mutate(jd = lubridate::yday(dt)) |>
    dplyr::select(StaID, jd, dt, Flow_7d, weibull_jd_30d_wndw_7d)
}

round_flow <- function(streamflow, replace_negative_flow_w_zero,
                       round_near_zero_to_zero) {
  # replace negative values, if directed
  if (replace_negative_flow_w_zero) {
    streamflow <- streamflow |>
      mutate(
        Flow_7d = ifelse(Flow_7d < 0,
                         0,
                         Flow_7d)
      )
  }
  
  # round near zero values (<0.001) to zero, if directed
  if (round_near_zero_to_zero) {
    streamflow <- streamflow |>
      mutate(
        Flow_7d = ifelse(Flow_7d < 0.001,
                         0,
                         Flow_7d)
      )
  }
  return(streamflow)
}

determine_streamflow_percentiles <- function(streamflow, thresholds) {
  thresholds |>
    group_by(jd) |>
    mutate(any_thresh_0 = any(Flow_7d == 0)) |>
    pivot_wider(id_cols = c(StaID, jd, any_thresh_0), 
                names_from = percentile_threshold,
                names_prefix = "percentile_threshold_",
                values_from = "Flow_7d") |>
    ungroup() |>
    right_join(streamflow, by = c("StaID", "jd")) |>
    mutate(
      pd = case_when(
        # if Flow 0 and any threshold value is 0, use raw percentiles
        Flow_7d == 0 & any_thresh_0 ~ weibull_jd_30d_wndw_7d,
        Flow_7d < percentile_threshold_5 ~ 4.9,
        Flow_7d < percentile_threshold_10 ~ 9.9,
        Flow_7d < percentile_threshold_20 ~ 19.9,
        Flow_7d >= percentile_threshold_20 ~ 20.9,
        TRUE ~ NA
      )
    ) |>
    select(StaID, dt, jd, Flow_7d, pd) |>
    arrange(dt)
}

munge_streamflow <- function(site, streamflow_csv, thresholds_jd_csv, 
                             start_date, end_date, replace_negative_flow_w_zero,
                             round_near_zero_to_zero, outfile_template) {
  
  # subset streamflow
  subset_streamflow <- subset_streamflow(streamflow_csv, start_date, end_date)
  
  if (!(site == unique(subset_streamflow[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in streamflow data"))
  }
  
  # if streamflow is NA, go ahead and return as-is, without more processing
  if (all(is.na(subset_streamflow[["Flow_7d"]]))) {
    munged_streamflow <- subset_streamflow |>
      mutate(jd = yday(dt)) |>
      select(StaID, dt, jd, result = Flow_7d, pd = weibull_jd_30d_wndw_7d)
  } else {
    # load in jd thresholds data
    thresholds <- readr::read_csv(thresholds_jd_csv, 
                                  col_types = cols(StaID = "c"))
    
    if (!(site == unique(thresholds[["StaID"]]))) {
      stop(message("Provided site doesn't match StaID in thresholds data"))
    }
    
    # replace negative values, if directed
    # round near zero values (<0.001) to zero, if directed
    munged_streamflow <- round_flow(streamflow = subset_streamflow,
                                    replace_negative_flow_w_zero, 
                                    round_near_zero_to_zero)
    
    # define streamflow percentiles (If flow > 0 and all thresholds > 0,
    # manually set percentile values that will fall into the correct bin for
    # categorizing streamflow drought OR, if flow = 0 AND any
    # historical threshold = 0, then use raw streamflow percentiles
    munged_streamflow <- determine_streamflow_percentiles(munged_streamflow, 
                                                          thresholds)

    munged_streamflow <- munged_streamflow |>
      mutate(
        # round output values
        Flow_7d = round(Flow_7d, 5),
        pd = round(pd, 5)
      ) |>
      select(StaID, dt, jd, result = Flow_7d, pd)
  }
  
  # save subsetted and converted streamflow
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(munged_streamflow, outfile)
  
  return(outfile)
}

identify_streamflow_droughts <- function(site, streamflow_csv, 
                                         outfile_template) {
  
  streamflow <- readr::read_csv(streamflow_csv, col_types = cols(StaID = "c"))
  
  if (!(site == unique(streamflow[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in streamflow data"))
  }
  
  # Categorize streamflow droughts based on percentiles set in munge_streamflow()
  streamflow <- streamflow |>
    mutate(
      drought_cat = case_when(
        pd < 5 ~ "5",
        pd < 10 ~ "10",
        pd < 20 ~ "20",
        TRUE ~ NA
      )
    ) |>
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

compute_drought_records <- function(sites, streamflow_csvs, 
                                    thresholds_jd_csvs,
                                    streamflow_drought_csvs, 
                                    antecedent_start_date, issue_date, 
                                    latest_streamflow_date,
                                    replace_negative_flow_w_zero,
                                    round_near_zero_to_zero, outfile) {
  drought_records <- purrr::map(sites, function(site) {
    site_index <- which(sites == site)
    
    # Load in streamflow data for site
    streamflow <- data.table::fread(streamflow_csvs[[site_index]],
                                    colClasses = c(StaID = "character")) |>
      mutate(dt = as.Date(dt),
             jd = lubridate::yday(dt)) |>
      dplyr::select(StaID, jd, dt, Flow_7d, weibull_jd_30d_wndw_7d)|>
      filter(dt <= latest_streamflow_date)
    
    if (!(site == unique(streamflow[["StaID"]]))) {
      stop(message("Provided site doesn't match StaID in streamflow data"))
    }
    
    # Load in jd thresholds data for site
    thresholds <- data.table::fread(thresholds_jd_csvs[[site_index]], 
                                    colClasses = c(StaID = "character"))
    
    if (!(site == unique(thresholds[["StaID"]]))) {
      stop(message("Provided site doesn't match StaID in thresholds data"))
    }
    
    # replace negative values, if directed
    # round near zero values (<0.001) to zero, if directed
    streamflow <- round_flow(streamflow = streamflow,
                             replace_negative_flow_w_zero, 
                             round_near_zero_to_zero)
    
    # define streamflow percentiles (If flow > 0 and all thresholds > 0,
    # manually set percentile values that will fall into the correct bin for
    # categorizing streamflow drought OR, if flow = 0 AND any
    # historical threshold = 0, then use raw streamflow percentiles
    streamflow <- determine_streamflow_percentiles(streamflow, 
                                                   thresholds)
    
    # Determine completeness of record in past year
    issue_date_minus_year <- issue_date - lubridate::years(1)
    last_year_obs_days <- streamflow |>
      dplyr::filter(dt >= issue_date_minus_year & !is.na(Flow_7d)) |>
      pull(dt) |>
      length()
    last_year_obs_per <- round(last_year_obs_days/365*100, 0)
    
    # Determine completeness of record in antecedent period
    antecedent_obs_days <- streamflow |>
      dplyr::filter(dt >= antecedent_start_date & !is.na(Flow_7d)) |>
      pull(dt) |>
      length()
    antecedent_obs_per <- round(antecedent_obs_days/
                                  as.double(issue_date - antecedent_start_date)*100, 
                                0)
    
    # Categorize streamflow droughts based on percentiles set in munge_streamflow()
    streamflow_cat <- streamflow |>
      mutate(
        drought_cat = case_when(
          pd < 5 ~ "5",
          pd < 10 ~ "10",
          pd < 20 ~ "20",
          TRUE ~ NA
        )
      )
    # Figure out what percent of last year site has been in drought
    # Does not account for <100% observation frequency
    last_year_drought_days <- streamflow_cat |>
      dplyr::filter(dt >= issue_date_minus_year & !is.na(drought_cat)) |>
      pull(dt) |>
      length()
    last_year_drought_per <- round(last_year_drought_days/365*100, 0)
    
    current_drought_cat <- streamflow_cat |>
      dplyr::filter(dt == max(dt)) |>
      pull(drought_cat)
    
    currently_in_drought <- !is.na(current_drought_cat)
    if (currently_in_drought) {
      # figure out how long site has been in drought
      dates_w_o_drought <- streamflow_cat |>
        dplyr::filter(is.na(drought_cat)) |>
        pull(dt)
      
      date_chunks <- tibble(break_date = c(dates_w_o_drought, issue_date)) %>%
        mutate(chunk_num = row_number(),
               start_date = case_when(
                 chunk_num == 1 ~ min(streamflow_cat[["dt"]]),
                 TRUE ~ lag(break_date) + 1),
               chunk_length_days = as.numeric(break_date-start_date))
      
      current_date_chunk <- dplyr::slice_tail(date_chunks, n = 1)
      continuous_drought_length <- current_date_chunk[["chunk_length_days"]]
      
      # get category and length of current drought
      streamflow_droughts_wide <- data.table::fread(
        streamflow_drought_csvs[[site_index]],
        colClasses = c(StaID = "character")
      ) |>
        mutate(start = as.Date(start),
               end = as.Date(end))
      
      if (!(site == unique(streamflow_droughts_wide[["StaID"]]))) {
        stop(message("Provided site doesn't match StaID in streamflow_droughts_wide data"))
      }
      
      current_drought_info <- dplyr::filter(streamflow_droughts_wide,
                                            end == issue_date)
      
      current_drought_length <- as.numeric(difftime(current_drought_info[["end"]],
                                                    current_drought_info[["start"]],
                                                    units = "days"))
      drought_record <- tibble(
        StaID = site,
        antecedent_obs_per = antecedent_obs_per,
        last_year_obs_per = last_year_obs_per,
        last_year_drought_per = last_year_drought_per,
        continuous_drought_length = continuous_drought_length,
        current_drought_category = current_drought_cat,
        current_drought_length = current_drought_length
      )
    } else {
      drought_record <- tibble(
        StaID = site,
        antecedent_obs_per = antecedent_obs_per,
        last_year_obs_per = last_year_obs_per,
        last_year_drought_per = last_year_drought_per,
        continuous_drought_length = NA,
        current_drought_category = NA,
        current_drought_length = NA
      )
    }
    return(drought_record)
    
  }) |>
    list_rbind()
  
  # save drought record
  out_dir <- dirname(outfile)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  readr::write_csv(drought_records, outfile)
  
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

munge_gage_info <- function(gages_sf, gages_binary_qualifiers_csv, 
                            gages_addl_snow_qualifiers_csv, forecast_sites,
                            outfile) {
  
  conus_states <- tigris::states(cb = TRUE, resolution = "20m", 
                                 progress_bar = FALSE) |>
    sf::st_drop_geometry()
  
  gage_info <- gages_sf |>
    sf::st_drop_geometry() |>
    dplyr::mutate(GEOID = stringr::str_pad(state_cd, 2, pad="0")) |>
    dplyr::left_join(conus_states, by = "GEOID") |>
    dplyr::select(StaID, station_nm, huc_cd, state = NAME)
  
  # Add in binary qualifiers for hydrologic characteristics
  gages_binary_qualifiers <- readr::read_csv(gages_binary_qualifiers_csv, 
                                             col_types = cols(gageID = "c")) |>
    dplyr::rename(StaID = gageID) |>
    dplyr::select(
      StaID,
      site_regulated = dam_impacted,
      site_intermittent = non_perennial,
      site_snow_dominated = snow_dominated,
      site_ice_impacted= ice_impacted
    )
  gages_addl_snow_qualifiers <- readr::read_csv(gages_addl_snow_qualifiers_csv,
                                                    col_types = cols(STAID = "c")) |>
    dplyr::rename(StaID = STAID) |>
    dplyr::select(
      StaID,
      site_snow_dominated = snow_dominated
    )
  
  gages_binary_qualifiers <- bind_rows(gages_binary_qualifiers,
                                       gages_addl_snow_qualifiers)
  
  gage_info <- gage_info |>
    left_join(gages_binary_qualifiers, by = "StaID") |>
    # If missing qualifiers, set to 0 (false) for now
    mutate(
      across(where(is.numeric), ~replace_na(.x, 0))
    )
  
  # save gage_info
  out_dir <- dirname(outfile)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  readr::write_csv(gage_info, outfile)
  
  return(outfile)
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
process_thresholds_data <- function(site, thresholds_csv, 
                                    replace_negative_flow_w_zero,
                                    outfile_template) {

  thresholds <- readr::read_csv(thresholds_csv, col_types = cols(StaID = "c"))
  
  if (!(site == unique(thresholds[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in thresholds data"))
  }
  
  threshold_fields <- colnames(thresholds)
  threshold_fields <- threshold_fields[grepl("thresh_\\d+_jd_30d_wndw_7d", threshold_fields)]
  
  thresholds_jd <- thresholds |>
    group_by(StaID, jd) |>
    summarize(across(all_of(threshold_fields), ~first(.x)), .groups = "drop") |>
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

pivot_thresholds_data <- function(site, thresholds_jd_csv, outfile_template) {
  
  thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                   col_types = cols(StaID = "c"))

  if (!(site == unique(thresholds_jd[["StaID"]]))) {
    stop(message("Provided site doesn't match StaID in thresholds_jd data"))
  }
  
  thresholds_wide <- thresholds_jd |>
    pivot_wider(id_cols = c(StaID, jd),
                names_from = percentile_threshold,
                names_prefix = "percentile_threshold_",
                values_from = "Flow_7d")
  
  # save forecasts
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(thresholds_wide, outfile)
  
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
      dt = as.Date(datetime, tz = "America/New_York"),
      f_w = as.integer(difftime(dt, 
                                issue_date, 
                                units="weeks"))
    ) |>
    dplyr::arrange(dt, StaID)
  
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
    mutate(Flow_7d = NA,
           jd = lubridate::yday(dt),
           modeled_data = "Yes")
  
  # filter to only relevant jds
  forecast_jds <- unique(df_sub[["jd"]])
  df_pct <- dplyr::filter(df_pct, jd %in% forecast_jds)
  thresholds_jd <- dplyr::filter(thresholds_jd, jd %in% forecast_jds)
  
  # get common column name for percentiles
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
    group_by(jd) |>
    arrange(percentiles) |>
    # Use rule 2 of approx to use closest data extreme for points beyond end of range
    mutate(Flow_7d = zoo::na.approx(Flow_7d, percentiles, na.rm = FALSE, 
                                    ties = "mean", rule = 2))
  
  df_new_pct <- filter(df_both, !is.na(modeled_data)) |>
    ungroup() |>
    select(-c(modeled_data, percentiles, all_of(pct_type))) |>
    arrange(dt) |>
    select(StaID, dt, jd, f_w, parameter, prediction, Flow_7d)
  
  return(df_new_pct)
}

join_conditions_and_forecasts <- function(streamflow_csvs, issue_date, 
                                          forecasts) {
  
  # read in latest streamflow data for each site
  streamflow <- purrr::map(streamflow_csvs, function(streamflow_csv) {
    latest_streamflow <- readr::read_csv(streamflow_csv, 
                                         col_types = cols(StaID = "c")) |>
      # Filter to max date for now. It's not clear what date this will be. It
      # depends on whether p1_latest_forecast date and p1_issue_date match. The
      # closer those two dates are, likely the larger the lag here (biggest gap
      # between max(dt) and p1_issue_date).
      # Note that streamflow data has been filtered to < issue_date in 
      # munge_streamflow(), since sometimes pulled streamflow data extend beyond
      # p1_issue_date if forecast reference datetime (issue_date) has not changed
      dplyr::filter(dt == max(dt)) 
  }) |>
    list_rbind() |>
    mutate(
      f_w = 0, 
      # if the percentile is NA, set to 999
      pd = ifelse(is.na(pd), 999, round(pd, 1))
    ) |>
    select(StaID, dt, f_w, pd)
  
  # filter to median forecasts and pivot wider
  forecasts <- forecasts  |>
    dplyr::filter(parameter == "median") |>
    dplyr::mutate(
      prediction = round(prediction, 1)
    ) |>
    dplyr::select(StaID, dt, f_w, pd = prediction)
  
  dplyr::bind_rows(streamflow, forecasts)
}

join_conditions_and_spatial_data <- function(conditions_and_forecasts, 
                                             gages_shp) {

  # read in spatial data
  gages_sf <- sf::read_sf(gages_shp)
  
  # join together
  conditions_and_forecasts |>
    select(StaID, pd) |>
    dplyr::left_join(dplyr::select(gages_sf, StaID), by = "StaID") |>
    sf::st_as_sf()
}

convert_forecast_percentiles_to_cfs <- function(site, site_forecast, 
                                                thresholds_csv,
                                                thresholds_jd_csv, 
                                                thresholds_jd_wide_csv,
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

  # categorize forecasts based on forecast percentile
  munged_forecasts <- converted_forecasts |>
    mutate(
      drought_cat = case_when(
        prediction < 5 ~ "5",
        prediction < 10 ~ "10",
        prediction < 20 ~ "20",
        TRUE ~ NA
      ),
      Flow_7d = round(Flow_7d, 5),
      prediction = round(prediction, 5)
    )|>
    select(StaID, dt, jd, f_w, parameter, result = Flow_7d, 
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
    # filter to plot dates
    dplyr::filter(jd %in% date_tibble[["jd"]]) |>
    group_by(jd) |>
    arrange(percentile_threshold) |>
    mutate(
      Flow_7d = round(Flow_7d, 5),
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
  forecast_dates <- pull(forecast_info, dt)
  
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
  
  # get tibble of plot dates
  date_tibble <- tibble(
    dt = date_subset,
    jd = lubridate::yday(dt)
  )

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
                            threshold_Flow_7d))
  
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
    # filter to plot dates & 20th percentile threshold
    dplyr::filter(jd %in% date_tibble[["jd"]] & percentile_threshold == "20") |>
    # filter to only edge dates
    dplyr::filter(!(jd %in% exclude_jds)) |>
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
    arrange(jd, plot_group)
  
  # Add back in dates for plotting
  lower_overlay_data <- lower_overlay_data |>
    select(StaID, jd, result_max = Flow_7d) |>
    mutate(
      result_min = 0,
      result_max = round(result_max, 5)
    ) |>
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
           ymax = ifelse(Flow_7d < threshold_Flow_7d, threshold_Flow_7d, NA)) |>
    filter(!is.na(ymin))
  
  # Add back in dates for plotting
  date_tibble <- tibble(
    dt = date_subset,
    jd = lubridate::yday(dt)
  )
  
  upper_overlay_data <- upper_overlay_data |>
    select(StaID, jd, f_w, result_max = ymax, 
           result_min = ymin) |>
    mutate(
      result_min = round(result_min, 5),
      result_max = round(result_max, 5)
    ) |>
    left_join(date_tibble, by = "jd")
  
  # save upper overlay
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(upper_overlay_data, outfile)
  
  return(outfile)
}

generate_conditions_geojson <- function(conditions_and_forecasts, gages_shp,
                                        cols_to_keep, precision, tmp_dir,
                                        outfile_template) {
  # read in spatial data
  gages_sf <- sf::read_sf(gages_shp)
  
  # join together
  joined_data <- conditions_and_forecasts |>
    select(StaID, pd) |>
    dplyr::left_join(dplyr::select(gages_sf, StaID), by = "StaID") |>
    sf::st_as_sf()
  
  outfile <- sprintf(outfile_template, unique(conditions_and_forecasts[["f_w"]]))
  generate_geojson(data_sf = joined_data, 
                   cols_to_keep = cols_to_keep, 
                   precision = precision, 
                   tmp_dir = tmp_dir, 
                   outfile = outfile)
}

generate_site_map <- function(conus_states_sf, gages_sf, proj, site,
                              outfile_template, width, height, dpi) {
  
  site_sf <- gages_sf |>
    dplyr::filter(StaID == site) |>
    sf::st_transform(crs = proj)
  
  map <- ggplot() +
    geom_sf(data = conus_states_sf, fill = "#CCCCCC", color = "#CCCCCC") +
    geom_sf(data = site_sf, color = "#000000", size = 3) +
    scale_x_continuous(expand = c(0.01,0.01)) +
    scale_y_continuous(expand = c(0.01,0.01)) +
    theme_void()
  
  # save map
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  ggplot2::ggsave(outfile, plot = map, width = width, height = height, dpi = dpi)
  
  return(outfile)
}
