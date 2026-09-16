#' Construct a paws S3 client
#'
#' Centralizes client construction so callers can build a single client and
#' reuse it across many requests instead of paying the construction and
#' credential-resolution cost on every object. Passing an existing client
#' through `client` returns it unchanged.
#'
#' @param aws_region region for bucket
#' @param client an existing paws S3 client to reuse, or NULL to build one
#'
#' @returns a paws S3 client
#'
s3_client <- function(aws_region = 'us-west-2', client = NULL) {
  if (!is.null(client)) {
    return(client)
  }
  paws::s3(config = list(region = aws_region))
}

#' Given an S3 prefix, get subdirectories, extract dates and return the most recent
#' 
#' @param s3_bucket_name bucket name on S3
#' @param prefix path to directory within `s3_bucket_name`
#' @param aws_region region for bucket
#' 
#' @returns most recent date in file names
#'
get_most_recent_date <- function(s3_bucket_name, prefix, aws_region = 'us-west-2') {
  s3 <- s3_client(aws_region)
  
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

#' Download site-specific data from s3
#' 
#' @param s3_bucket_name bucket name on S3
#' @param aws_region region for bucket
#' @param prefix path to data folder within `bucket`
#' @param site site id of site for which to download data
#' @param redownload flag, boolean - should data for site be redownloaded,
#' regardless of whether or not they exist on disk?
#' @param outfile_template template filepath for saving the files
#' @param client an existing paws S3 client to reuse. If NULL, one is built.
#'
#' @returns path to downloaded site data file
#'
download_s3_site_data <- function(s3_bucket_name, aws_region = 'us-west-2', 
                                  prefix, site, redownload, outfile_template,
                                  client = NULL) {
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  
  filepath <- sprintf(outfile_template, site)
  filename <- basename(filepath)
  
  # Reuse the provided S3 client, or build one if none was supplied
  s3 <- s3_client(aws_region, client)
  
  # Skip the download only when not forcing a redownload and the file is present
  if (!redownload && file.exists(filepath)) {
    return(filepath)
  }
  
  s3$download_file(
    Bucket = s3_bucket_name,
    Key = paste0(prefix, filename),
    Filename = filepath
  )
  return(filepath)
}

#' Download site data for a batch of sites using a single S3 client
#'
#' Downloads the data files for every site in `sites` while reusing one paws S3
#' client for the whole batch. Intended to be driven by a chunked dynamic
#' branch (one branch per chunk of sites) so that thousands of latency-bound
#' object downloads are spread across a small number of high-concurrency
#' workers instead of one target branch per site.
#'
#' @param s3_bucket_name bucket name on S3
#' @param aws_region region for bucket
#' @param prefix path to data folder within `s3_bucket_name`
#' @param sites character vector of site ids to download
#' @param redownload flag, boolean - should data be redownloaded regardless of
#' whether it already exists on disk?
#' @param outfile_template template filepath for saving the files
#'
#' @returns character vector of downloaded site data file paths, one per site,
#' in the same order as `sites`
#'
download_s3_site_data_batch <- function(s3_bucket_name, aws_region = 'us-west-2',
                                        prefix, sites, redownload,
                                        outfile_template) {
  out_dir <- dirname(outfile_template)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  
  # Build the client once and reuse it for every site in this chunk
  s3 <- s3_client(aws_region)
  
  # Download each site independently. A single missing/failed object should not
  # fail the whole chunk: skip it here and let the downstream per-site target
  # decide how to handle a missing file (preserving per-site failure
  # granularity rather than failing ~n_chunk sites at once).
  downloaded <- character(0)
  for (site in sites) {
    result <- tryCatch(
      download_s3_site_data(
        s3_bucket_name = s3_bucket_name,
        aws_region = aws_region,
        prefix = prefix,
        site = site,
        redownload = redownload,
        outfile_template = outfile_template,
        client = s3
      ),
      error = function(e) {
        warning(sprintf(
          "Failed to download data for site %s: %s", site, conditionMessage(e)
        ))
        NA_character_
      }
    )
    if (!is.na(result)) {
      downloaded <- c(downloaded, result)
    }
  }
  
  if (length(downloaded) == 0) {
    stop(sprintf(
      "No files downloaded for chunk of %d site(s) from prefix '%s'.",
      length(sites), prefix
    ))
  }
  
  return(downloaded)
}

#' Resolve the deterministic on-disk path for a single site's data file
#'
#' The batched download targets write each site to a path derived purely from
#' the site id and `outfile_template`. This helper lets a lightweight per-site
#' target report that path (as a `format = "file"` output) without re-issuing a
#' network request, keeping the per-site branch count aligned with downstream
#' `map()` patterns.
#'
#' @param site site id
#' @param outfile_template template filepath used by the batched download
#'
#' @returns path to the site's data file
#'
resolve_site_data_path <- function(site, outfile_template) {
  filepath <- sprintf(outfile_template, site)
  if (!file.exists(filepath)) {
    stop(sprintf(
      "Expected downloaded file for site %s at %s but it does not exist.",
      site, filepath
    ))
  }
  return(filepath)
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
download_s3_data <- function(s3_bucket_name, aws_region, s3_filepath, outfile,
                             client = NULL) {
  out_dir <- dirname(outfile)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  
  # Reuse the provided S3 client, or build one if none was supplied
  s3 <- s3_client(aws_region, client)
  
  # download file
  s3$download_file(
    Bucket = s3_bucket_name,
    Key = s3_filepath,
    Filename = outfile
  )
  
  return(outfile)
}
