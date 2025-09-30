
#' Build date info table
#'
#' @param issue_date date current forecasts were issued
#' @param latest_streamflow_date latest date for current conditions data
#' @param forecasts dataframe with current 1-13 week forecasts, with fields 'dt' 
#' for forecast date and 'f_w' for forecast week
#'
#' @returns tibble with row for each forecast week (including week 0), and 
#' columns for issue date, forecast date, and forecast week
#' 
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

#' Subset streamflow data for a single site
#'
#' @param file filepath for streamflow csv
#' @param start_date start date of period to keep (inclusive)
#' @param end_date end date of period to keep (inclusive)
#'
#' @returns tibble of streamflow data for a single site, with row for all days 
#' from `start_date` through `end_date`, and columns for site id, Julian day, 
#' date, seven-day mean flow, and flow percentile
#' 
subset_streamflow <- function(file, start_date, end_date) {
  date_tibble <- tibble(
    dt = seq(start_date, end_date, by = "day")
  )
  data.table::fread(file, colClasses = c(StaID = "character")) |>
    mutate(dt = as.Date(dt)) |>
    # make sure all dates in specified window are represented, and only those 
    # dates
    dplyr::right_join(date_tibble, by = "dt") |>
    dplyr::mutate(jd = lubridate::yday(dt)) |>
    dplyr::select(StaID, jd, dt, Flow_7d, weibull_jd_30d_wndw_7d) |>
    arrange(dt) |>
    fill(StaID, .direction = "down")
}

#' Round streamflow data, as directe
#'
#' @param streamflow dataframe of streamflow data, with 'Flow_7d' field
#' @param replace_negative_flow_w_zero boolean. If TRUE, replace any mean 
#' seven-day streamflow values below zero with zero
#' @param round_near_zero_to_zero boolean. If TRUE, round any near zero mean
#' seven-day streamfow values (<0.001) to zero
#'
#' @returns dataframe with seven-day mean streamflow, where negative values have 
#' been replaced with zero (if `replace_negative_flow_w_zero`) and near-zero
#' values have been rounded to zero (if `round_near_zero_to_zero`)
#' 
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

#' Determine percentiles for streamflow data for a single site
#'
#' @param streamflow dataframe of streamflow data for a single site, with 
#' mean seven-day streamflow values and raw percentiles
#' @param thresholds_jd dataframe of variable (Julian-day) streamflow drought
#' thresholds for a single site, with 5th, 10th and 20th percentile thresholds
#'
#' @returns a dataframe of streamflow data for a single site with an additional
#' column 'pd' that contains the percentile value for each mean seven-day flow
#' 
determine_streamflow_percentiles <- function(streamflow, thresholds_jd) {
  thresholds_jd |>
    group_by(jd) |>
    # Determine if any threshold is 0
    mutate(any_thresh_0 = any(Flow_7d == 0)) |>
    # Pivot to wide format
    pivot_wider(id_cols = c(StaID, jd, any_thresh_0), 
                names_from = percentile_threshold,
                names_prefix = "percentile_threshold_",
                values_from = "Flow_7d") |>
    ungroup() |>
    # Join in streamflow data, by Julian day
    right_join(streamflow, by = c("StaID", "jd")) |>
    mutate(
      pd = case_when(
        # Based on discussion w/ John and Caelan, for intermittent sites, use 
        # raw percentile values in incoming streamflow data
        # if Flow 0 and any threshold value is 0, use raw percentiles
        Flow_7d == 0 & any_thresh_0 ~ weibull_jd_30d_wndw_7d,
        # Otherwise, if site is not intermittent, manually assign percentiles 
        # by comparing mean seven-day flow to the historical thresholds.
        # These manual percentiles are assigned for binning purposes only.
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

#' Munge streamflow data
#'
#' @param site id of USGS gage site
#' @param streamflow_csv filepath to streamflow data for `site`
#' @param thresholds_jd_csv filepath to Julian-day thresholds for `site`
#' @param start_date start date for subsetting streamflow data (inclusive)
#' @param end_date end date for subsetting streamflow data (inclusive)
#' @param replace_negative_flow_w_zero boolean. If TRUE, replace any mean 
#' seven-day streamflow values below zero with zero
#' @param round_near_zero_to_zero boolean. If TRUE, round any near zero mean
#' seven-day streamfow values (<0.001) to zero
#' @param outfile_template template for outfile
#'
#' @returns filepath for saved munged streamflow data
#' 
munge_streamflow <- function(site, streamflow_csv, thresholds_jd_csv, 
                             start_date, end_date, replace_negative_flow_w_zero,
                             round_near_zero_to_zero, outfile_template) {
  
  # subset streamflow
  subsetted_streamflow <- subset_streamflow(streamflow_csv, start_date, end_date)
  
  if (!(site == unique(subsetted_streamflow[["StaID"]]))) {
    stop(message(sprintf(
      "Provided site (%s) doesn't match StaID in %s (%s)",
      site,
      streamflow_csv,
      unique(subsetted_streamflow[["StaID"]]))))
  }
  
  # if streamflow is NA, go ahead and return as-is, without more processing
  if (all(is.na(subsetted_streamflow[["Flow_7d"]]))) {
    munged_streamflow <- subsetted_streamflow |>
      mutate(jd = yday(dt),
             drought_cat = NA)|>
      select(StaID, dt, jd, result = Flow_7d, pd = weibull_jd_30d_wndw_7d,
             drought_cat)
  } else {
    # load in jd thresholds data
    thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                  col_types = cols(StaID = "c"))
    
    if (!(site == unique(thresholds_jd[["StaID"]]))) {
      stop(message(sprintf(
        "Provided site (%s) doesn't match StaID in %s (%s)",
        site,
        thresholds_jd_csv,
        unique(thresholds_jd[["StaID"]]))))
    }
    
    # replace negative values, if directed
    # round near zero values (<0.001) to zero, if directed
    munged_streamflow <- round_flow(streamflow = subsetted_streamflow,
                                    replace_negative_flow_w_zero, 
                                    round_near_zero_to_zero)
    
    # define streamflow percentiles (If flow > 0 and all thresholds > 0,
    # manually set percentile values that will fall into the correct bin for
    # categorizing streamflow drought OR, if flow = 0 AND any historical
    # threshold = 0 (intermittent site), then use raw streamflow percentiles
    munged_streamflow <- determine_streamflow_percentiles(munged_streamflow, 
                                                          thresholds_jd)

    munged_streamflow <- munged_streamflow |>
      mutate(
        # categorize streamflow droughts based on percentiles
        drought_cat = case_when(
          pd < 5 ~ "5",
          pd < 10 ~ "10",
          pd < 20 ~ "20",
          TRUE ~ NA
        ),
        # round output values
        Flow_7d = round(Flow_7d, 5),
        pd = round(pd, 5)
      ) |>
      select(StaID, dt, jd, result = Flow_7d, pd, drought_cat)
  }
  
  # save subsetted and converted streamflow
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(munged_streamflow, outfile)
  
  return(outfile)
}

#' Identify streamflow drought events at a site
#'
#' @param site id of USGS gage site
#' @param streamflow_csv filepath to streamflow data for site
#' @param outfile_template template for outfile
#'
#' @returns filepath for drought event data
#' 
identify_streamflow_droughts <- function(site, streamflow_csv, 
                                         outfile_template) {
  
  streamflow <- readr::read_csv(streamflow_csv, col_types = cols(StaID = "c"))
  
  if (!(site == unique(streamflow[["StaID"]]))) {
    stop(message(sprintf(
      "Provided site (%s) doesn't match StaID in %s (%s)",
      site,
      streamflow_csv,
      unique(streamflow[["StaID"]]))))
  }
  
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
      # group days with streamflow droughts into events, by drought level
      mutate(group = cumsum(c(TRUE, diff(dt) > 1))) |>
      # for each event, determine start and end date
      group_by(group, .add = TRUE) |>
      # note end of drought date as max date + 1, to be inclusive of final day 
      # of drought when plotting with D3 - this way, when plotting rectangle,
      # the rectangle ends at 12am on day after last day of drought, rather than
      # 12am on the last day of the drought, thereby including the last day in
      # the drought band visually.
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

#' Compute drought records for all sites
#'
#' @param sites vector of USGS site ids
#' @param streamflow_csvs filepaths to streamflow data for sites
#' @param thresholds_jd_csvs filepaths to Julian-day thresholds for sites
#' @param streamflow_drought_csvs filepaths to streamflow drought event data for 
#' sites
#' @param antecedent_days number of days in antecedent period
#' @param antecedent_start_date start date for antecedent period
#' @param issue_date date current forecasts were issued
#' @param latest_streamflow_date latest date for current conditions data
#' @param replace_negative_flow_w_zero boolean. If TRUE, replace any mean 
#' seven-day streamflow values below zero with zero
#' @param round_near_zero_to_zero boolean. If TRUE, round any near zero mean
#' seven-day streamfow values (<0.001) to zero
#' @param outfile filepath for saved file
#'
#' @returns filepath of saved drought record csv
#' 
compute_drought_records <- function(sites, streamflow_csvs, 
                                    thresholds_jd_csvs,
                                    streamflow_drought_csvs, antecedent_days,
                                    antecedent_start_date, issue_date, 
                                    latest_streamflow_date,
                                    replace_negative_flow_w_zero,
                                    round_near_zero_to_zero, outfile) {
  
  data_list <- list(site = sites,
                    streamflow_csv = streamflow_csvs,
                    thresholds_jd_csv = thresholds_jd_csvs,
                    streamflow_drought_csv = streamflow_drought_csvs)
  drought_records <- purrr::pmap(data_list, function(site, streamflow_csv,
                                                     thresholds_jd_csv,
                                                     streamflow_drought_csv) {
    
    # Load in streamflow data for site, subsetting to last year
    latest_streamflow_date_minus_year <- 
      latest_streamflow_date - lubridate::years(1)
    streamflow <- subset_streamflow(
      file = streamflow_csv,
      start_date = latest_streamflow_date_minus_year,
      end_date = latest_streamflow_date
    )
    
    if (!(site == unique(streamflow[["StaID"]]))) {
      stop(message(sprintf(
        "Provided site (%s) doesn't match StaID in %s (%s)",
        site,
        streamflow_csv,
        unique(streamflow[["StaID"]]))))
    }
    
    # Load in jd thresholds data for site
    thresholds_jd <- data.table::fread(thresholds_jd_csv, 
                                    colClasses = c(StaID = "character"))
    
    if (!(site == unique(thresholds_jd[["StaID"]]))) {
      stop(message(sprintf(
        "Provided site (%s) doesn't match StaID in %s (%s)",
        site,
        thresholds_jd_csv,
        unique(thresholds_jd[["StaID"]]))))
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
                                                   thresholds_jd)
    
    # Determine completeness of record in past year
    # Note: streamflow already subset to last year, above
    last_year_obs_days <- streamflow |>
      dplyr::filter(!is.na(Flow_7d)) |>
      pull(dt) |>
      length()
    last_year_obs_per <- last_year_obs_days/nrow(streamflow)*100
    last_year_obs_per <- ifelse(last_year_obs_per > 99,
                                round(last_year_obs_per, 1),
                                round(last_year_obs_per, 0))
    
    # Determine completeness of record in antecedent period
    antecedent_obs_days <- streamflow |>
      dplyr::filter(dt >= antecedent_start_date & !is.na(Flow_7d)) |>
      pull(dt) |>
      length()
    antecedent_obs_per <- antecedent_obs_days/antecedent_days*100
    antecedent_obs_per <- ifelse(antecedent_obs_per > 99,
                                 round(antecedent_obs_per, 1),
                                 round(antecedent_obs_per, 0))
    
    # Categorize streamflow droughts based on percentiles
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
    # Note: streamflow already subset to last year, above
    last_year_drought_days <- streamflow_cat |>
      dplyr::filter(!is.na(drought_cat)) |>
      pull(dt) |>
      length()
    last_year_drought_per <- round(last_year_drought_days/365*100, 0)
    # Figure out what percent of antecedent period has been in drought
    # Does not account for <100% observation frequency in antecedent period
    antecedent_drought_days <- streamflow_cat |>
      dplyr::filter(!is.na(drought_cat), dt >= antecedent_start_date) |>
      pull(dt) |>
      length()
    antecedent_drought_per <- antecedent_drought_days/antecedent_days*100
    antecedent_drought_per <- ifelse(antecedent_drought_per > 99 | antecedent_drought_per < 1,
                                 round(antecedent_drought_per, 1),
                                 round(antecedent_drought_per, 0))
    
    # Determine current status on latest streamflow date (issue date - 1)
    current_drought_cat <- streamflow_cat |>
      dplyr::filter(dt == latest_streamflow_date) |>
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
      continuous_drought_start <- format(current_date_chunk[["start_date"]], format="%m/%d/%y")
      
      # get category and length of current drought
      streamflow_droughts_wide <- data.table::fread(
        streamflow_drought_csv,
        colClasses = c(StaID = "character")
      ) |>
        mutate(start = as.Date(start),
               end = as.Date(end))
      
      if (!(site == unique(streamflow_droughts_wide[["StaID"]]))) {
        stop(message(sprintf(
          "Provided site (%s) doesn't match StaID in %s (%s)",
          site,
          streamflow_drought_csv,
          unique(streamflow_droughts_wide[["StaID"]]))))
      }
      
      current_drought_info <- dplyr::filter(streamflow_droughts_wide,
                                            end == issue_date)
      current_drought_start <- format(current_drought_info[["start"]], format="%m/%d/%y")
      current_drought_length <- as.numeric(difftime(current_drought_info[["end"]],
                                                    current_drought_info[["start"]],
                                                    units = "days"))
      drought_record <- tibble(
        StaID = site,
        antecedent_days = antecedent_days,
        antecedent_obs_per = antecedent_obs_per,
        antecedent_drought_days = antecedent_drought_days,
        antecedent_drought_per = antecedent_drought_per,
        last_year_obs_per = last_year_obs_per,
        last_year_drought_per = last_year_drought_per,
        continuous_drought_start = continuous_drought_start,
        continuous_drought_length = continuous_drought_length,
        current_drought_category = current_drought_cat,
        current_drought_start = current_drought_start,
        current_drought_length = current_drought_length
      )
    } else {
      drought_record <- tibble(
        StaID = site,
        antecedent_days = antecedent_days,
        antecedent_obs_per = antecedent_obs_per,
        antecedent_drought_days = antecedent_drought_days,
        antecedent_drought_per = antecedent_drought_per,
        last_year_obs_per = last_year_obs_per,
        last_year_drought_per = last_year_drought_per,
        continuous_drought_start = NA,
        continuous_drought_length = NA,
        current_drought_category = NA,
        current_drought_start = NA,
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

#' Munge USGS gage information
#'
#' @param gages_sf sf object of forecast gages. Point data.
#' @param gages_binary_qualifiers_csv filepath to hydrologic qualifiers data
#' for USGS gages
#' @param outfile The filepath for the munged output information csv
#'
#' @returns filepath of output csv
#' 
munge_gage_info <- function(gages_sf, gages_binary_qualifiers_csv, outfile) {
  
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

  gage_info <- gages_sf |>
    left_join(gages_binary_qualifiers, by = "StaID")
  
  # save gage_info
  out_dir <- dirname(outfile)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  readr::write_csv(gage_info, outfile)
  
  return(outfile)
}

#' Process thresholds data
#' 
#' @param site id of USGS gage site
#' @param thresholds_csv filepath to historical streamflow and thresholds data 
#' for `site`
#' @param replace_negative_flow_w_zero T/F replace negative threshold flow values
#' on log scale
#' @param outfile_template template for outfile
#' 
#' @returns filepath to csv with Julian day 5, 10, and 20 percentile thresholds 
#' for site
#'
process_thresholds_data <- function(site, thresholds_csv, 
                                    replace_negative_flow_w_zero,
                                    outfile_template) {

  thresholds <- readr::read_csv(thresholds_csv, col_types = cols(StaID = "c"))
  
  if (!(site == unique(thresholds[["StaID"]]))) {
    stop(message(sprintf(
      "Provided site (%s) doesn't match StaID in %s (%s)",
      site,
      thresholds_csv,
      unique(thresholds[["StaID"]]))))
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
    filter(percentile_threshold <= 30 & percentile_threshold >= 5)
  
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

#' Munge raw forecast data
#'
#' @param forecast_feathers vector of weekly forecast feather files 
#' @param forecast_sites vector of USGS site ids
#' @param replace_out_of_bound_predictions boolean. If TRUE, replace any forecast 
#' percentile values below zero with zero and any forecast percentile values
#' over 100 with 100
#'
#' @returns dataframe with 1-13 week forecasts for all `foreast_sites`
#' 
munge_raw_forecast_data <- function(forecast_feathers, forecast_sites, 
                                    replace_out_of_bound_predictions) {
  forecast_data <- arrow::open_dataset(
    sources = forecast_feathers,
    format = "feather") |>
    # filter to subset defined by p1_sites
    dplyr::filter(site_id %in% forecast_sites) |>
    dplyr::collect() |>
    dplyr::rename("StaID" = "site_id") |>
    dplyr::mutate(
      issue_date = as.Date(reference_datetime, 
                           tz = "UTC"),
      dt = as.Date(datetime, tz = "UTC"),
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

#' Format forecast data for downloadable file
#'
#' @param issue_date date current forecasts were issued
#' @param lstm_forecasts dataframe of munged 1-13 week LSTM<30 forecast data
#' @param lgb_forecasts dataframe of munged 1-13 week Light GBM forecast data
#' @param outfile_template template for output parquet file
#'
#' @returns filepath to formatted forecast parquet file
#' 
format_forecast_data <- function(issue_date, lstm_forecasts, lgb_forecasts, 
                                 outfile_template) {
  
  lstm_forecasts <- mutate(lstm_forecasts, model_type = 'LSTM<30')
  lgb_forecasts <- mutate(lgb_forecasts, model_type = 'LightGBM')
  
  forecast_data <- bind_rows(lstm_forecasts, lgb_forecasts) |>
    dplyr::mutate(
      source = 'USGS',
      parameter = sprintf('%s_pct', parameter),
    ) |>
    select(source, model_type, issue_date, StaID, forecast_date = dt, 
           forecast_week = f_w, parameter, prediction) |>
    arrange(StaID, model_type, forecast_date, parameter)
  
  forecast_wide <- forecast_data |>
    pivot_wider(names_from = parameter, values_from = prediction)
  
  # save forecasts
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, issue_date)
  arrow::write_parquet(forecast_wide, outfile)
  
  return(outfile)
}

#' Convert percentile values to cfs
#' Follows Caelan's approach here: 
#' https://code.chs.usgs.gov/wma/drought_prediction/streamflow-target-data/-/blob/main/Operational_Scripts/convert_percentiles_to_flow_using_saved_files.R
#' 
#' @param site id of USGS gage site
#' @param site_forecast dataframe of 1-13 week forecast percentile values for 
#' `site`
#' @param thresholds dataframe of historical streamflow and thresholds data for 
#' `site`
#' @param thresholds_jd dataframe of Julian day thresholds for `site`
#' 
#' @returns forecasts in units of flow as well as percentiles
#'
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

#' Join current conditions data and forecasts
#'
#' @param streamflow_csvs filepaths to streamflow data for sites
#' @param issue_date date current forecasts were issued
#' @param latest_streamflow_date latest date for current conditions data
#' @param forecasts dataframe of munged 1-13 week forecast data 
#'
#' @returns dataframe with current conditions (0-week) and 1-13 week forecasts 
#' for all forecast sites, with fields for 'StaID', 'dt', 'f_w' and 'pd'
#' 
join_conditions_and_forecasts <- function(streamflow_csvs, issue_date, 
                                          latest_streamflow_date, forecasts) {
  
  # read in latest streamflow data for each site
  streamflow <- purrr::map(streamflow_csvs, function(streamflow_csv) {
    latest_streamflow <- readr::read_csv(streamflow_csv, 
                                         col_types = cols(StaID = "c")) |>
      # Filter to latest streamflow date (day before issue date).
      # Note that streamflow data has been filtered to < issue_date in 
      # munge_streamflow(), since sometimes pulled streamflow data extend beyond
      # p1_issue_date if forecast reference datetime (issue_date) has not changed
      dplyr::filter(dt == latest_streamflow_date) 
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

#' Convert forecast percentiles to cfs
#'
#' @param site id of USGS gage site
#' @param site_forecast dataframe of 1-13 week forecast percentile values for 
#' `site`
#' @param thresholds_csv filepath to historical streamflow and thresholds data for
#' `site`
#' @param thresholds_jd_csv filepath to Julian-day thresholds for `site`
#' @param outfile_template template for outfile
#'
#' @returns filepath to csv with forecast percentiles and streamflow values
#' 
convert_forecast_percentiles_to_cfs <- function(site, site_forecast, 
                                                thresholds_csv, 
                                                thresholds_jd_csv, 
                                                outfile_template) {
  
  thresholds <- readr::read_csv(thresholds_csv, col_types = cols(StaID = "c"))
  thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                   col_types = cols(StaID = "c"))
  
  if (!(site == unique(site_forecast[["StaID"]]))) {
    stop(message(sprintf(
      "Provided site (%s) doesn't match StaID in site forecasts (%s)",
      site,
      unique(site_forecast[["StaID"]]))))
  }
  if (!(site == unique(thresholds[["StaID"]]))) {
    stop(message(sprintf(
      "Provided site (%s) doesn't match StaID in %s (%s)",
      site,
      thresholds_csv,
      unique(thresholds[["StaID"]]))))
  }
  if (!(site == unique(thresholds_jd[["StaID"]]))) {
    stop(message(sprintf(
      "Provided site (%s) doesn't match StaID in %s (%s)",
      site,
      thresholds_jd_csv,
      unique(thresholds_jd[["StaID"]]))))
  }
  
  # convert forecast percentiles to cfs
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

#' Generate csv with threshold band data
#'
#' @param site id of USGS gage site
#' @param thresholds_jd_csv filepath to Julian-day thresholds for `site`
#' @param date_subset vector of dates for plotting
#' @param outfile_template template for outfile
#'
#' @returns filepath to csv with min and max values for threshold bands for 
#' `site` within `date_subset`
#' 
generate_threshold_band_csv <-function(site, thresholds_jd_csv, date_subset, 
                                        outfile_template) {
  thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                   col_types = cols(StaID = "c"))

  if (!(site == unique(thresholds_jd[["StaID"]]))) {
    stop(message(sprintf(
      "Provided site (%s) doesn't match StaID in %s (%s)",
      site,
      thresholds_jd_csv,
      unique(thresholds_jd[["StaID"]]))))
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
    left_join(date_tibble, by = "jd") |>
    arrange(dt)
  
  # save threshold bands
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(threshold_bands, outfile)
  
  return(outfile)
}

#' Generate buffer dates for forecast weeks, for plotting uncertainty rectangles
#'
#' @param date_info tibble with row for each forecast week (including week 0), 
#' and columns for issue date, forecast date, and forecast week
#' @param bar_width_days width of uncertainty bar, in days (including forecast
#' date itself)
#'
#' @returns tibble with row for each buffer date, where (`bar_width_days` - 1)/2
#' are included on either side of each forecast date, and fields for date, the
#' Julian day, and the forecast week
#' 
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
      f_w = rep(forecast_weeks, each = (bar_width_days - 1))
    )
}

#' Generate lower overlay to visually mask threshold bands
#'
#' @param site id of USGS gage site
#' @param site_forecast_csv filepath to 1-13 week forecasts for `site`
#' @param thresholds_jd_csv filepath to Julian-day thresholds for `site`
#' @param buffer_dates tibble of dates for visually buffering forecast dates
#' @param date_subset vector of dates for plotting
#' @param outfile_template template for outfile
#'
#' @returns filepath to csv with lower overlay for threshold bands for `site` 
#' (overlay covering thresholds up to the 5th quantile prediction on 
#' `buffer_dates` and forecast dates, and up to the 20th percentile threshold
#' otherwise)
#' 
generate_lower_overlay <- function(site, site_forecast_csv, thresholds_jd_csv, 
                                   buffer_dates, date_subset,
                                   outfile_template) {
  
  site_forecast <- readr::read_csv(site_forecast_csv, 
                                   col_types = cols(StaID = "c")) |>
    rename(Flow_7d = result)
  thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                   col_types = cols(StaID = "c"))
  
  if (!(site == unique(site_forecast[["StaID"]]))) {
    stop(message(sprintf(
      "Provided site (%s) doesn't match StaID in %s (%s)",
      site,
      site_forecast_csv,
      unique(site_forecast[["StaID"]]))))
  }
  if (!(site == unique(thresholds_jd[["StaID"]]))) {
    stop(message(sprintf(
      "Provided site (%s) doesn't match StaID in %s (%s)",
      site,
      thresholds_jd_csv,
      unique(thresholds_jd[["StaID"]]))))
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
  
  # pull out the edge dates (min and max dates) for each 'dip' in the overlay
  min_dip_dts <- dip_data |>
    group_by(f_w) |>
    summarize(dt = min(dt)) |>
    pull(dt)
  
  max_dip_dts <- dip_data |>
    group_by(f_w) |>
    summarize(dt = max(dt)) |>
    pull(dt)
  
  # identify the non-edge dates for each 'dip' in the overlay
  exclude_dts <- dip_data |>
    filter(!(dt %in% c(min_dip_dts, max_dip_dts))) |>
    pull(dt)
  
  # pull together the final lower overlay dataset
  # for 'min' edge dates, we need to plot the threshold value, then the dip value
  # for 'max' edge dates, we need to plot the dip value, then the threshold value
  lower_overlay_data <- thresholds_jd |> 
    # filter to plot dates & 20th percentile threshold
    dplyr::filter(percentile_threshold == "20") |>
    dplyr::right_join(date_tibble, by = "jd") |>
    arrange(dt) |>
    # filter to only edge dates
    dplyr::filter(!(dt %in% exclude_dts)) |>
    mutate(plot_group = case_when(
      dt >= max_dip_dts[[13]] ~ 27,
      dt >= max_dip_dts[[12]] ~ 25,
      dt >= max_dip_dts[[11]] ~ 23,
      dt >= max_dip_dts[[10]] ~ 21,
      dt >= max_dip_dts[[9]] ~ 19,
      dt >= max_dip_dts[[8]] ~ 17,
      dt >= max_dip_dts[[7]] ~ 15,
      dt >= max_dip_dts[[6]] ~ 13,
      dt >= max_dip_dts[[5]] ~ 11,
      dt >= max_dip_dts[[4]] ~ 9,
      dt >= max_dip_dts[[3]] ~ 7,
      dt >= max_dip_dts[[2]] ~ 5,
      dt >= max_dip_dts[[1]] ~ 3,
      dt <= max_dip_dts[[1]] ~ 1,
      TRUE ~ NA
    )) |>
    bind_rows(dip_data) |>
    arrange(dt) |>
    mutate(plot_group = case_when(
      !(is.na(plot_group)) ~ plot_group,
      dt >= min_dip_dts[[13]] ~ 26,
      dt >= min_dip_dts[[12]] ~ 24,
      dt >= min_dip_dts[[11]] ~ 22,
      dt >= min_dip_dts[[10]] ~ 20,
      dt >= min_dip_dts[[9]] ~ 18,
      dt >= min_dip_dts[[8]] ~ 16,
      dt >= min_dip_dts[[7]] ~ 14,
      dt >= min_dip_dts[[6]] ~ 12,
      dt >= min_dip_dts[[5]] ~ 10,
      dt >= min_dip_dts[[4]] ~ 8,
      dt >= min_dip_dts[[3]] ~ 6,
      dt >= min_dip_dts[[2]] ~ 4,
      dt >= min_dip_dts[[1]] ~ 2,
      TRUE ~ NA
    )) |>
    arrange(dt, plot_group)
  
  # Add fields for plotting
  lower_overlay_data <- lower_overlay_data |>
    select(StaID, jd, dt, result_max = Flow_7d) |>
    mutate(
      result_min = 0,
      result_max = round(result_max, 5)
    )
  
  # save lower overlay
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(lower_overlay_data, outfile)
  
  return(outfile)
}

#' Generate upper overlay to visually mask threshold bands
#'
#' @param site id of USGS gage site
#' @param site_forecast_csv filepath to 1-13 week forecasts for `site`
#' @param thresholds_jd_csv filepath to Julian-day thresholds for `site`
#' @param buffer_dates tibble of dates for visually buffering forecast dates
#' @param date_subset vector of dates for plotting
#' @param outfile_template template for outfile
#'
#' @returns filepath to csv with upper overlay for threshold bands for `site` 
#' (overlay covering thresholds from the 5th quantile prediction up to the 20th 
#' percentile threshold on `buffer_dates` only)
#' 
generate_upper_overlay <- function(site, site_forecast_csv, thresholds_jd_csv, 
                                   buffer_dates, date_subset,
                                   outfile_template) {
  
  site_forecast <- readr::read_csv(site_forecast_csv, 
                                   col_types = cols(StaID = "c")) |>
    rename(Flow_7d = result)
  thresholds_jd <- readr::read_csv(thresholds_jd_csv, 
                                   col_types = cols(StaID = "c"))
  
  if (!(site == unique(site_forecast[["StaID"]]))) {
    stop(message(sprintf(
      "Provided site (%s) doesn't match StaID in %s (%s)",
      site,
      site_forecast_csv,
      unique(site_forecast[["StaID"]]))))
  }
  if (!(site == unique(thresholds_jd[["StaID"]]))) {
    stop(message(sprintf(
      "Provided site (%s) doesn't match StaID in %s (%s)",
      site,
      thresholds_jd_csv,
      unique(thresholds_jd[["StaID"]]))))
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
    left_join(date_tibble, by = "jd") |>
    arrange(dt)
  
  # save upper overlay
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template, site)
  readr::write_csv(upper_overlay_data, outfile)
  
  return(outfile)
}

#' Generate geojson of current conditions and forecast data for a forecast week
#'
#' @param conditions_and_forecasts dataframe of current/forecast conditions
#' for a given week (0-13)
#' @param gages_sf sf object of forecast gages. Point data.
#' @param cols_to_keep columns from dataframe to write. If NULL, all are kept
#' @param precision precision for final geojson
#' @param tmp_dir temp directory for writing intermediate file output
#' @param outfile_template template for output geojson
#'
#' @returns filepath to geojson of gage locations and current/forecast 
#' percentiles
#' 
generate_conditions_geojson <- function(conditions_and_forecasts, gages_sf,
                                        cols_to_keep, precision, tmp_dir,
                                        outfile_template) {
  
  # join together current/forecast conditions and spatial data
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

#' Generate map of site location within CONUS
#'
#' @param conus_states_sf sf object of CONUS states
#' @param gages_sf sf object of forecast gages. Point data.
#' @param proj projection to use for map
#' @param site id of USGS gage site
#' @param outfile_template template for output image
#' @param width width of final image
#' @param height height of final image
#' @param dpi dpi of final image
#'
#' @returns filepath to image
#' 
generate_site_map <- function(conus_states_sf, gages_sf, proj, site,
                              outfile_template, width, height, dpi) {
  
  site_sf <- gages_sf |>
    dplyr::filter(StaID == site) |>
    sf::st_transform(crs = proj)
  
  map <- ggplot() +
    geom_sf(data = conus_states_sf, fill = "#CCCCCC", color = "#CCCCCC") +
    geom_sf(data = site_sf, color = "#000000", size = 4) +
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
