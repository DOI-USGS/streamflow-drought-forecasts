source("1_fetch/src/fetch_utils.R")

p1_targets <- list(
  # Pull latest forecast date
  tar_target(
    p1_latest_forecast_date,
    get_most_recent_date(
      bucket = p0_pipeline_bucket_name,
      prefix = "conus_gaged_nn_predictions"
    )
  ),
  # Download forecasts
  tar_target(
    p1_forecast_feathers,
    download_forecast(
      forecast_date = p1_latest_forecast_date,
      forecast_week = p0_forecast_weeks,
      aws_region = p0_aws_region,
      bucket_name = p0_pipeline_bucket_name,
      outfile_template = "1_fetch/in/forecasts/nn_conus_gaged_preds_%sw_BA.feather"
    ),
    pattern = map(p0_forecast_weeks),
    format = "file"
  ),
  tar_target(
    p1_streamflow_csvs,
    download_streamflow(
      forecast_date = p1_latest_forecast_date,
      aws_region = p0_aws_region,
      bucket_name = p0_pipeline_bucket_name,
      outfile_template = "1_fetch/in/streamflow/%s"
    ),
    format = "file"
  )
)