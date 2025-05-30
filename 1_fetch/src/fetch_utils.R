#' Given an S3 prefix, get subdirectories, extract dates and return the most recent
#' @param s3_prefix
#' @param bucket
#' @return most recent date in file names
#'
get_most_recent_date <- function(bucket_name, prefix, aws_region = 'us-west-2') {
  s3_contents <- aws.s3::get_bucket_df(bucket_name, prefix, max = Inf, region = aws_region)
  dates_df <- s3_contents |>
    dplyr::mutate(date = as.Date(stringr::str_extract(Key, "\\b\\d{4}-\\d{2}-\\d{2}\\b")))
  return(max(dates_df$date))
}

download_forecast <- function(forecast_date, forecast_week, aws_region,
                              bucket_name, outfile_template) {
  
  dir.create(dirname(outfile_template), showWarnings = FALSE)
  outfile <- sprintf(outfile_template,
                     forecast_week)
  
  # CONUS gaged sites, neural-network predictions, 1-week forecasts
  # NOTE: currently date in filename does not match date in file b/c the input 
  # data are updated weekly, yet model is run daily. In future, running of the 
  # model and data prep will be better synced, with either a moving 7-day window
  # or a single model run a week
  save_object(
    object = sprintf("conus_gaged_nn_predictions/%s/bakeoff2_v1_operational_discrete_%sw9/bakeoff2_v1_operational_discrete_%sw9_bakeoff2_v1_operational_discrete_%sw_late_test_results_BA.feather",
                     forecast_date, 
                     forecast_week, 
                     forecast_week,
                     forecast_week),
    file = outfile,
    direction = "download",
    bucket = bucket_name,
    region = aws_region
  )
  
  return(outfile)
}

download_streamflow <- function(forecast_date, site, aws_region, bucket_name,
                                outfile_template) {
  dir.create(dirname(outfile_template), showWarnings = FALSE)

  object_name <- sprintf("conus_streamflow_target_data/%s/%s.csv",
                         forecast_date,
                         site)
  outfile <- sprintf(outfile_template,
                     basename(object_name))
  aws.s3::save_object(
    object = object_name,
    file = outfile,
    direction = "download",
    bucket = bucket_name,
    region = aws_region
  )
  return(outfile)
}
