#' Given an S3 bucket prefix, get subdirectories, extract dates and return the most recent
#' @param s3_bucket_prefix
#' @param s3_bucket_name
#' @return most recent date in file names
#'
get_most_recent_date <- function(s3_bucket_name, s3_bucket_prefix, aws_region = 'us-west-2') {
  s3_contents <- aws.s3::get_bucket_df(s3_bucket_name, s3_bucket_prefix, max = Inf, region = aws_region)
  dates_df <- s3_contents |>
    dplyr::mutate(date = as.Date(stringr::str_extract(Key, "\\b\\d{4}-\\d{2}-\\d{2}\\b")))
  return(max(dates_df$date))
}

download_forecast <- function(forecast_date, forecast_week, aws_region,
                              s3_bucket_name, outfile_template) {
  
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
    bucket = s3_bucket_name,
    region = aws_region
  )
  
  return(outfile)
}

download_streamflow <- function(forecast_date, site, aws_region, s3_bucket_name,
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
    bucket = s3_bucket_name,
    region = aws_region
  )
  return(outfile)
}

#' Download a shapefile from S3
#' 
#' @param s3_bucket_name bucket name on S3
#' @param region region for s3_bucket_name
#' @param path_to_shp path to shapefile within `s3_bucket_name`
#' @param out_dir directory to which the shapefile will be saved
#' @return path to downloaded shapefile
#'
get_s3_shapefile <- function(s3_bucket_name, region, path_to_shp, out_dir) {
  
  s3_bucket_prefix <- tools::file_path_sans_ext(path_to_shp)
  
  # get list of all files associated w/ shapefile in s3_bucket_name
  shp_df <- aws.s3::get_bucket_df(bucket = s3_bucket_name, 
                                  prefix = s3_bucket_prefix, 
                                  region = region)
  
  # download .shp and all associated files
  shp_files <- purrr::map(shp_df[['Key']], function(file_key) {
    aws.s3::save_object(
      object = file_key,
      file = file.path(out_dir, basename(file_key)),
      direction = "download",
      bucket = s3_bucket_name,
      region = region
    )
  })
  
  # pull out .shp file to track
  out_file <- shp_files[[grep('.shp$', shp_files)]]
  
  if (!file.exists(out_file)) {
    message(sprintf('failed to download %s.shp from the %s s3 bucket.', 
                    s3_bucket_prefix, 
                    s3_bucket_name))
  }
  
  return(out_file)
}

#' Download site-specific thresholds from s3
#' 
#' @param bucket_name bucket name on S3
#' @param aws_region region for bucket
#' @param prefix path to thresholds folder within `bucket`
#' @param site site id of site for which to download thresholds
#' @param redownload flag, boolean - should thresholds for site be redownloaded,
#' regardless of whether or not they exist on disk?
#' @param outfile_template template filepath for savign the files
#' @return path to downloaded thresholds file
#'
download_thresholds <- function(bucket_name, aws_region = 'us-west-2', prefix,
                                site, redownload, outfile_template) {
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  
  filepath <- sprintf(outfile_template, site)
  filename <- basename(filepath)
  
  # if redownload flagged as TRUE, download thresholds for all sites
  if (redownload) {
    thresholds_file <- aws.s3::save_object(
      object = paste0(prefix, filename),
      file = filepath,
      direction = "download",
      bucket = bucket_name,
      region = aws_region
    )
  } else {
    # only download thresholds file if doesn't yet exist
    if (!file.exists(filepath)) {
      thresholds_file <- aws.s3::save_object(
        object = paste0(prefix, filename),
        file = filepath,
        direction = "download",
        bucket = bucket_name,
        region = aws_region
      )
    } else {
      thresholds_file <- filepath
    }
  }
  
  return(thresholds_file)
}
