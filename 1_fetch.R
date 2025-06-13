source("1_fetch/src/fetch_utils.R")

p1_targets <- list(
  ##### Spatial Data #####
  # Download gages shapefile
  # Must be logged into gs-chs-drought-aimldev AWS account
  tar_target(
    p1_conus_gages_raw_shp,
    get_s3_shapefile(s3_bucket_name = p0_pipeline_bucket_name,
                     region = p0_aws_region,
                     path_to_shp = "configuration/CONUS_drought_prediction_gages.shp",
                     out_dir = "1_fetch/out"),
    format = 'file'
  ),
  
  ##### Forecasts #####
  # Pull latest forecast date
  # Must be logged into gs-chs-drought-aimldev AWS account
  tar_target(
    p1_latest_forecast_date,
    get_most_recent_date(
      s3_bucket_name = p0_pipeline_bucket_name,
      s3_bucket_prefix = "conus_gaged_nn_predictions"
    )
  ),
  # Download forecasts
  # Must be logged into gs-chs-drought-aimldev AWS account
  tar_target(
    p1_forecast_feathers,
    download_forecast(
      forecast_date = p1_latest_forecast_date,
      forecast_week = p0_forecast_weeks,
      aws_region = p0_aws_region,
      s3_bucket_name = p0_pipeline_bucket_name,
      outfile_template = "1_fetch/out/forecasts/nn_conus_gaged_preds_%sw_BA.feather"
    ),
    pattern = map(p0_forecast_weeks),
    format = "file"
  ),
  # Get unique site ids
  tar_target(
    p1_sites,
    sort(c("01019000", "01116500", "01200500", "01208990", "01347000", "01483200", 
      "02055000", "02359170", "04256000", "06355500", "06410500", "06803000", 
      "08408500", "09394500", "09466500", "13297350", "08150800", "06876900", 
      "01411500", "01580000", "01484100", "06810000", "02313230", "06091700", 
      "06408700", "08165300", "08165500", "08192000", "08194500", "08198000", 
      "08198500", "08201500", "08248000", "09337000", "09337500", "09403600", 
      "09405500", "09406000", "09408150", "09444500", "09490500", "09492400", 
      "09494000", "09497500", "09498500", "09510200", "10183500", "10242000", 
      "10259200", "10259300", "10263000", "11365000", "11470500", "11480410", 
      "12433000", "11317000"))
    # arrow::open_dataset(
    #   sources = p1_forecast_feathers[[1]],
    #   format = 'feather'
    # ) |>
    #   dplyr::filter(parameter == 'median') |>
    #   dplyr::collect() |>
    #   pull(site_id)
  ),
  
  ##### Streamflow #####
  # Download streamflow data
  # Must be logged into gs-chs-drought-aimldev AWS account
  tar_target(
    p1_streamflow_csvs,
    download_streamflow(
      forecast_date = p1_latest_forecast_date,
      site = p1_sites,
      aws_region = p0_aws_region,
      s3_bucket_name = p0_pipeline_bucket_name,
      outfile_template = "1_fetch/out/streamflow/%s"
    ),
    pattern = map(p1_sites),
    format = "file"
  ),
   
  ##### Historical streamflow and thresholds #####
  tar_target(
    p1_thresholds_csvs,
    file.path("1_fetch/out/thresholds", paste0(p1_sites, ".csv")),
    # download_thresholds(
    #   bucket_name = p0_pipeline_bucket_name,
    #   prefix = "historical_streamflow_target_data_national/streamflow_target_data_national_extra_columns/",
    #   site = p1_sites,
    #   redownload = FALSE,
    #   outfile_template = "1_fetch/out/thresholds/%s"),
    pattern = map(p1_sites),
    format = 'file'
  )
)