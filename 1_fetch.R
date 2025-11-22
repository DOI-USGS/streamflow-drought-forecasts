# Fetch steps
# Note: If running for "test" data tier, requires that user be authenticated to
# the `gs-chs-drought-aimldev` AWS account. If running for "beta" or "prod" data 
# tier, requires that user be authenticated to the `gs-chs-drought-aimlprod` AWS 
# account.

source("1_fetch/src/fetch_utils.R")

p1_targets <- list(
  
  ##### LSTM<30 forecasts #####
  # Pull latest forecast date
  # Must be logged into gs-chs-drought-aimldev AWS account
  tar_target(
    p1_latest_forecast_date,
    get_most_recent_date(
      s3_bucket_name = p0_pipeline_bucket_name,
      prefix = "conus_gaged_nn_predictions",
      aws_region = p0_aws_region
    ),
    cue = tar_cue(mode = "always")
  ),
  # Download LSTM<30 forecasts
  # Must be logged into gs-chs-drought-aimldev AWS account
  tar_target(
    p1_forecast_feathers,
    {
      aws_filepath <- sprintf("conus_gaged_nn_predictions/%s/fy25_operational_discrete_%sw_CalibrateBelow30_EnfQuant_PostprocMed/fy25_operational_discrete_%sw_CalibrateBelow30_EnfQuant_PostprocMed_late_test_results.feather",
                              p1_latest_forecast_date, 
                              p0_forecast_weeks,
                              p0_forecast_weeks)
      download_s3_data(
        s3_bucket_name = p0_pipeline_bucket_name,
        aws_region = p0_aws_region,
        s3_filepath = aws_filepath, 
        outfile = sprintf("1_fetch/out/forecasts/%s", basename(aws_filepath))
      )
    },
    pattern = map(p0_forecast_weeks),
    format = "file"
  ),
  tar_target(
    p1_issue_date,
    {
      # Get intersection of reference datetime (issue date) across all forecast 
      # feathers
      # Start with first file
      result <- arrow::read_feather(p1_forecast_feathers[1]) |>
        arrow::arrow_table()
      
      # Use reduce and semi_join to intersect the remaining files
      for (i in 2:length(p1_forecast_feathers)) {
        next_file <- arrow::read_feather(p1_forecast_feathers[i]) |>
          arrow::arrow_table()
        result <- result |>
          dplyr::semi_join(next_file, by = "reference_datetime")
      }
      
      # Then collect to dataframe
      issue_date <- result |>
        distinct(reference_datetime) |>
        collect() |>
        dplyr::arrange(reference_datetime) |>
        pull(reference_datetime) |>
        as.Date(tz = "UTC")
      
      if (length(issue_date) > 1) {
        stop(message(sprintf(
          'Input feathers have >1 unique reference datetime: %s',
          issue_date)))
      }
      
      return(issue_date)
    }
  ),
  # Get unique site ids
  tar_target(
    p1_sites,
    {
      # Get intersection of site ids across all forecast feathers
      # Start with first file
      result <- arrow::read_feather(p1_forecast_feathers[1]) |>
        arrow::arrow_table()
      
      # Use reduce and semi_join to intersect the remaining files
      for (i in 2:length(p1_forecast_feathers)) {
        next_file <- arrow::read_feather(p1_forecast_feathers[i]) |>
          arrow::arrow_table()
        result <- result |>
          dplyr::semi_join(next_file, by = "site_id")
      }
      
      # Then collect to dataframe
      result |>
        distinct(site_id) |>
        collect() |>
        dplyr::arrange(site_id) |>
        pull(site_id)
    }
  ),
  
  ##### Spatial Data #####
  tar_target(
    p1_conus_states_20m_sf,
    tigris::states(cb = TRUE, resolution = "20m", 
                   progress_bar = FALSE) |>
      dplyr::filter(! STUSPS %in% c("AK", "HI", "PR")) |>
      sf::st_transform(crs = p0_map_proj)
  ),
  tar_target(
    p1_conus_states_500k_sf,
    tigris::states(cb = TRUE, resolution = '500k', 
                   progress_bar = FALSE) |>
      dplyr::filter(! STUSPS %in% c("AK", "HI", "PR", "GU", "MP", "AS", "VI"))
  ),
  # Download gages spatial data
  tar_target(
    p1_conus_gages_sf,
    {
      # To avoid need for API tokenm, split site list into chunks of 500 sites
      split_site_list <- split(p1_sites, ceiling(seq_along(p1_sites)/500))
      conus_gages_sf <- purrr::map(split_site_list, function(site_list) {
        dataRetrieval::read_waterdata_monitoring_location(
          monitoring_location_number = site_list,
          properties = c("monitoring_location_number", 
                         "monitoring_location_name",
                         "state_name"))
      }) |>
        bind_rows() |>
        rename(StaID = monitoring_location_number,
               station_nm = monitoring_location_name,
               state = state_name)
      
      if (!length(unique(conus_gages_sf[["StaID"]])) == length(p1_sites)) {
        stop(message(sprintf('Failed to retrieve spatial data for sites %s',
                             p1_sites[!p1_sites %in% conus_gages_sf[["StaID"]]])))
      }
      
      return(conus_gages_sf)
    }
  ),
  
  ##### Gage hydro qualifiers #####
  # Gages-II sites & non gages-II sites
  tar_target(
    p1_gages_binary_qualifiers_csv,
    download_s3_data(
      s3_bucket_name = p0_pipeline_bucket_name,
      aws_region = p0_aws_region,
      s3_filepath = "mapping_flags/gages2_and_nongages2_binary_qualifiers.csv", 
      outfile = "1_fetch/out/gages2_and_nongages2_binary_qualifiers.csv"
    ),
    format = "file"
  ),
  
  ##### Streamflow #####
  # Download streamflow data
  # Must be logged into gs-chs-drought-aimldev AWS account
  tar_target(
    p1_streamflow_csvs,
    {
      streamflow_prefix <- sprintf(
        "conus_streamflow_target_data/%s/",
        p1_latest_forecast_date
      )
      download_s3_site_data(
        s3_bucket_name = p0_pipeline_bucket_name,
        aws_region = p0_aws_region,
        prefix = streamflow_prefix,
        site = p1_sites,
        redownload = TRUE,
        outfile_template = "1_fetch/out/streamflow/%s.csv"
      )
    },
    pattern = map(p1_sites),
    format = "file"
  ),
   
  ##### Historical streamflow and thresholds #####
  tar_target(
    p1_thresholds_csvs,
    download_s3_site_data(
      s3_bucket_name = p0_pipeline_bucket_name,
      aws_region = p0_aws_region,
      prefix = "historical_streamflow_target_data_national/streamflow_target_data_national_extra_columns/",
      site = p1_sites,
      redownload = FALSE,
      outfile_template = "1_fetch/out/thresholds/%s.csv"),
    pattern = map(p1_sites),
    format = "file"
  ),
  ##### Historical drought context #####
  tar_target(
    p1_gages_drought_summary_csv,
    download_s3_data(
      s3_bucket_name = p0_pipeline_bucket_name,
      aws_region = p0_aws_region,
      s3_filepath = "mapping_flags/moderate_drought_duration_summary_wide.csv", 
      outfile = "1_fetch/out/moderate_drought_duration_summary_wide.csv"
    ),
    format = "file"
  ),
  
  ##### Light GBM forecasts #####
  ##### Light GBM forecasts (for formatting and exporting only) #####
  # Pull latest forecast date
  # Must be logged into gs-chs-drought-aimldev AWS account
  tar_target(
    p1_latest_lgb_forecast_date,
    get_most_recent_date(
      s3_bucket_name = p0_pipeline_bucket_name,
      prefix = "conus_gaged_lgb_predictions",
      aws_region = p0_aws_region
    ),
    cue = tar_cue(mode = "always")
  ),
  # Download lightGBM forecasts
  # Must be logged into gs-chs-drought-aimldev AWS account
  tar_target(
    p1_lgb_forecast_feather,
    {
      if (!(p1_latest_forecast_date == p1_latest_lgb_forecast_date)) {
        stop(message(sprintf("Light GBM model output is not available for %s, the latest LSTM<30 forecast date. The latest Light GBM forecast date is %s",
                             p1_latest_forecast_date,
                             p1_latest_lgb_forecast_date)))
      }
      aws_filepath <- sprintf("conus_gaged_lgb_predictions/%s/_targets/objects/combined_operational_gaged_forecasts",
                              p1_latest_lgb_forecast_date)
      
      download_s3_data(
        s3_bucket_name = p0_pipeline_bucket_name,
        aws_region = p0_aws_region,
        s3_filepath = aws_filepath,
        outfile = sprintf("1_fetch/out/lgb_forecasts/%s.feather", basename(aws_filepath))
      )
    },
    format = "file"
  )
)