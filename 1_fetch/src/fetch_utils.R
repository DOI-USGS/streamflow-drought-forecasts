#' Given an S3 prefix, get subdirectories, extract dates and return the most recent
#' @param s3_bucket_name
#' @param prefix
#' @param aws_region
#' @return most recent date in file names
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

download_forecast <- function(forecast_date, forecast_week, aws_region,
                              s3_bucket_name, outfile_template) {
  
  dir.create(dirname(outfile_template), showWarnings = FALSE)
  outfile <- sprintf(outfile_template,
                     forecast_week)
  
  # Create S3 client
  s3 <- paws::s3(config = list(region = aws_region))
  
  # CONUS gaged sites, neural-network predictions, 1-week forecasts
  # NOTE: currently date in filename does not match date in file b/c the input 
  # data are updated weekly, yet model is run daily. In future, running of the 
  # model and data prep will be better synced, with either a moving 7-day window
  # or a single model run a week
  s3$download_file(
    Bucket = s3_bucket_name,
    Key = sprintf("conus_gaged_nn_predictions/%s/bakeoff2_v1_operational_discrete_%sw9/bakeoff2_v1_operational_discrete_%sw9_bakeoff2_v1_operational_discrete_%sw_late_test_results_BA.feather",
                  forecast_date, 
                  forecast_week, 
                  forecast_week,
                  forecast_week),
    Filename = outfile
  )
  
  return(outfile)
}

# download_streamflow <- function(forecast_date, site, aws_region, s3_bucket_name,
#                                 outfile_template) {
#   dir.create(dirname(outfile_template), showWarnings = FALSE)
# 
#   object_name <- sprintf("conus_streamflow_target_data/%s/%s.csv",
#                          forecast_date,
#                          site)
#   outfile <- sprintf(outfile_template,
#                      basename(object_name))
#   
#   # Create S3 client
#   s3 <- paws::s3(config = list(region = aws_region))
# 
#   # Download streamflow file
#   s3$download_file(
#     Bucket = s3_bucket_name,
#     Key = object_name,
#     Filename = outfile
#   )
#   return(outfile)
# }

#' Download a shapefile from S3
#' 
#' @param s3_bucket_name bucket name on S3
#' @param aws_region aws region for bucket
#' @param path_to_shp path to shapefile within `bucket`
#' @param out_dir directory to which the shapefile will be saved
#' @return path to downloaded shapefile
#'
get_s3_shapefile <- function(s3_bucket_name, aws_region, path_to_shp, out_dir) {
  
  prefix <- tools::file_path_sans_ext(path_to_shp)
  
  # Create S3 client
  s3 <- paws::s3(config = list(region = aws_region))
  
  # get list of all files associated w/ shapefile in bucket
  shp_response <- s3$list_objects_v2( # note pagination needed if > 1000 objects matching
    Bucket = s3_bucket_name,
    Prefix = prefix
  )
  
  # download .shp and all associated files
  if (!is.null(shp_response$Contents)) {
    shp_files <- purrr::map_chr(shp_response$Contents, function(obj) {
      file_path <- file.path(out_dir, basename(obj$Key))
      s3$download_file(
        Bucket = s3_bucket_name,
        Key = obj$Key,
        Filename = file_path
      )
      return(file_path)
    })
  } else {
    stop(sprintf("No files found with prefix '%s' in bucket '%s'", prefix, bucket))
  }
  # pull out .shp file to track
  shp_file_index <- grep('.shp$', shp_files)
  if (length(shp_file_index) > 0) {
    out_file <- shp_files[[shp_file_index]]
  } else {
    out_file <- NULL
  }
  
  if (is.null(out_file) || !file.exists(out_file)) {
    message(sprintf('failed to download %s.shp from the %s s3 bucket.', 
                    prefix, 
                    s3_bucket_name))
  }
  
  return(out_file)
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
#' @return path to downloaded data file
#'
download_s3_site_data <- function(s3_bucket_name, aws_region = 'us-west-2', prefix,
                                  site, redownload, outfile_template) {
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
#' @param s3_filepath path to file within `bucket`
#' @param outfile filepath for saving the files
#' @return path to downloaded data file
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
