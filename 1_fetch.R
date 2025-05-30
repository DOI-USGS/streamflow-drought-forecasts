source("1_fetch/src/fetch_utils.R")

p1_targets <- list(
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
    arrow::open_dataset(
      sources = p1_forecast_feathers[[1]],
      format = 'feather'
    ) |>
      dplyr::filter(parameter == 'median') |>
      dplyr::collect() |>
      pull(site_id)
  ),
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
  )
)