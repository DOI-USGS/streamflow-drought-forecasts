#' Given an S3 prefix, get subdirectories, extract dates and return the most recent
#' 
#' @param s3_bucket_name bucket name on S3
#' @param prefix path to directory within `s3_bucket_name`
#' @param aws_region region for bucket
#' 
#' @returns most recent date in file names
#'
get_most_recent_date <- function(s3_bucket_name, prefix, aws_region = 'us-west-2') {
  s3 <- paws::s3(config = list(region = aws_region))
  
  responses <- paws::paginate_lapply(s3$list_objects_v2(
    Bucket = s3_bucket_name,
    Prefix = prefix
  ), function(page) page$Contents)
  
  all_keys <- lapply(responses, function(x) sapply(x, function(x) x$Key)) |> unlist()
  if (length(all_keys) == 0) {
    stop("No objects found with the given prefix")
  }
  # Extract dates from keys
  dates_df <- data.frame(Key = all_keys) |>
    dplyr::mutate(date = as.Date(stringr::str_extract(Key, "\\b\\d{4}-\\d{2}-\\d{2}\\b")))
  return(max(dates_df$date))
}

#' Download the forecast data for a specific forecast date and forecast week
#' 
#' @param forecast_date date identifying forecast directory on s3
#' @param forecast_week integer (1-13) for forecast week
#' @param aws_region region for bucket
#' @param s3_bucket_name bucket name on S3
#' @param outfile_template template for outfile name
#' 
#' @returns filepath to downloaded forecast file
#'
download_forecast <- function(forecast_date, forecast_week, aws_region,
                              s3_bucket_name, outfile_template) {
  
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  outfile <- sprintf(outfile_template,
                     forecast_week)
  
  # Create S3 client
  s3 <- paws::s3(config = list(region = aws_region))
  
  # CONUS gaged sites, neural-network predictions, 1-week forecasts
  # NOTE: currently date in filename does not match date in file b/c the input 
  # data are updated weekly, yet model is run daily. In future, running of the 
  # model and data prep will be better synced
  s3$download_file(
    Bucket = s3_bucket_name,
    Key = sprintf("conus_gaged_nn_predictions/%s/fy25_operational_discrete_%sw_CalibrateBelow30_EnfQuant_PostprocMed/fy25_operational_discrete_%sw_CalibrateBelow30_EnfQuant_PostprocMed_late_test_results.feather",
                  forecast_date, 
                  forecast_week,
                  forecast_week),
    Filename = outfile
  )
  
  return(outfile)
}

#' Download site-specific data from s3
#' 
#' @param s3_bucket_name bucket name on S3
#' @param aws_region region for bucket
#' @param prefix path to data folder within `bucket`
#' @param site site id of site for which to download data
#' @param redownload flag, boolean - should data for site be redownloaded,
#' regardless of whether or not they exist on disk?
#' @param outfile_template template filepath for saving the files
#'
#' @returns path to downloaded site data file
#'
download_s3_site_data <- function(s3_bucket_name, aws_region = 'us-west-2', 
                                  prefix, site, redownload, outfile_template) {
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  
  filepath <- sprintf(outfile_template, site)
  filename <- basename(filepath)
  
  # Create S3 client
  s3 <- paws::s3(config = list(region = aws_region))
  
  # if redownload flagged as TRUE, download data files for all sites
  if (redownload) {
    s3$download_file(
      Bucket = s3_bucket_name,
      Key = paste0(prefix, filename),
      Filename = filepath
    )
    downloaded_file <- filepath
  } else {
    # only download data file if doesn't yet exist
    if (!file.exists(filepath)) {
      s3$download_file(
        Bucket = s3_bucket_name,
        Key = paste0(prefix, filename),
        Filename = filepath
      )
      downloaded_file <- filepath
    } else {
      downloaded_file <- filepath
    }
  }
  
  return(downloaded_file)
}

#' Download data from s3
#' 
#' @param s3_bucket_name bucket name on S3
#' @param aws_region region for bucket
#' @param s3_filepath path to file within `s3_bucket_name`
#' @param outfile filepath for saving the files
#' 
#' @returns path to downloaded data file
#'
download_s3_data <- function(s3_bucket_name, aws_region, s3_filepath, outfile) {
  # Create S3 client
  s3 <- paws::s3(config = list(region = aws_region))
  
  # download file
  s3$download_file(
    Bucket = s3_bucket_name,
    Key = s3_filepath,
    Filename = outfile
  )
  
  return(outfile)
}
