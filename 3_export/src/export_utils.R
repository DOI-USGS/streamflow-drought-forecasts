#' Write data to geojson
#' 
#' @param data_sf sf dataframe to be written to geojson
#' @param cols_to_keep columns from dataframe to write. If NULL, all are kept
#' @param outfile filepath to which geojson should be written
#' 
#' @returns the filepath of the saved geojson
#' 
write_to_geojson <- function(data_sf, cols_to_keep = NULL, outfile) {
  if (file.exists(outfile)) unlink(outfile)
  out_dir <- dirname(outfile)
  if (!dir.exists(out_dir)) dir.create(out_dir)
  
  if (!is.null(cols_to_keep)) {
    data_sf <- dplyr::select(data_sf, !!cols_to_keep)
  }
  
  data_sf %>%
    sf::st_transform(crs = 4326) %>%
    sf::st_write(outfile, append = FALSE)
  
  return(outfile)
}

#' Generate geojson
#' 
#' @param data_sf sf object to write to geojson
#' @param cols_to_keep columns from dataframe to write. If NULL, all are kept
#' @param precision precision for final geojson
#' @param tmp_dir temp directory for writing intermediate file output
#' @param outfile outfile for final geojson
#' 
#' @returns most recent date in file names
#'
generate_geojson <- function(data_sf, cols_to_keep = NULL, precision, tmp_dir, outfile) {
  if (!dir.exists(tmp_dir)) dir.create(tmp_dir)
  
  raw_geojson <- file.path(tmp_dir, basename(outfile))
  write_to_geojson(
    data_sf = data_sf, 
    cols_to_keep = cols_to_keep,
    outfile = raw_geojson
  )
  # check that mapshaper is installed on the system by trying mapshaper commmand
  tryCatch(
    {
      system('mapshaper -version')
    },
    warning = function(w) {
      stop(message("Error: Must have system installation of mapshaper to generate final geojson"))
    }
  )
  
  # if have mapshaper, run command to generate final geojson
  system(sprintf('mapshaper %s -o %s precision=%s format=geojson', 
                 raw_geojson, outfile, precision))
  unlink(raw_geojson)
  return(outfile)
}

#' Push file(s) to s3
#'
#' Uploads a vector of local files to S3, reusing a single paws S3 client for
#' the whole batch instead of rebuilding it per file. Uploads run concurrently
#' via forked workers (`parallel::mclapply`) so that large file vectors (e.g.
#' the tens of thousands of per-site timeseries files) are not sent one at a
#' time. On platforms without fork support, or when `workers = 1`, uploads run
#' serially.
#'
#' @param files file(s) to be pushed to s3
#' @param s3_bucket_name bucket name on S3
#' @param s3_bucket_prefix path to directory within `s3_bucket_name`
#' @param aws_region region for bucket
#' @param workers number of concurrent uploads. Defaults to 8, capped at the
#' number of files.
#'
#' @returns NULL
#' 
push_files_to_s3 <- function(files, s3_bucket_name, s3_bucket_prefix, 
                             aws_region, workers = 8) {
  if (length(files) == 0) {
    return(invisible(NULL))
  }
  
  # Build the S3 client once and reuse it for every upload in this batch
  s3 <- paws::s3(config = list(region = aws_region))
  
  # Derive S3 keys: strip the local output prefix, then prepend the bucket
  # prefix. Vectorized so we do not rebuild the mapping per iteration.
  targets_keys <- sub("^2_process/out/", "", files)
  targets_keys <- paste0(s3_bucket_prefix, "/", targets_keys)
  
  upload_one <- function(i) {
    s3$put_object(
      Bucket = s3_bucket_name,
      Key = targets_keys[i],
      Body = files[i],
      ContentType = xfun::mime_type(files[i]),
      ACL = "bucket-owner-full-control"
    )
    NULL
  }
  
  # Fork-based concurrency is unavailable on Windows; fall back to serial.
  n_workers <- max(1, min(workers, length(files)))
  use_parallel <- n_workers > 1 && .Platform$OS.type != "windows"
  
  if (use_parallel) {
    results <- parallel::mclapply(
      seq_along(files), upload_one, mc.cores = n_workers
    )
    # mclapply reports per-element errors as try-error objects rather than
    # aborting; surface them so a failed upload is not silently dropped.
    failed <- vapply(results, function(r) inherits(r, "try-error"), logical(1))
    if (any(failed)) {
      stop(sprintf(
        "Failed to upload %d of %d file(s) to s3. First error: %s",
        sum(failed), length(files),
        conditionMessage(attr(results[[which(failed)[1]]], "condition"))
      ))
    }
  } else {
    for (i in seq_along(files)) {
      upload_one(i)
    }
  }
  
  invisible(NULL)
}

#' Generate map of CONUS where a state or all of CONUS is visuall highlighted
#'
#' @param conus_states_sf sf object of CONUS states
#' @param selected_state_abb abbreviation for selected state, e.g., 'ME'. This
#' state is visually highlighted. If  NULL (default), all of CONUS will be 
#' highlighted.
#' @param outfile outfile path for final image
#' @param width width of final image
#' @param height height of final image
#' @param dpi dpi of final image
#'
#' @returns filepath of generated image
#' 
generate_map <- function(conus_states_sf, selected_state_abb = NULL, outfile, width, 
                         height, dpi) {

  if (is.null(selected_state_abb)) {
    map <- ggplot() +
      geom_sf(data = conus_states_sf, fill = "#333333", color = "#333333")
  } else {
    map <- ggplot() +
      geom_sf(data = conus_states_sf, fill = "#CCCCCC", color = "#CCCCCC") +
      geom_sf(data = dplyr::filter(conus_states_sf, STUSPS == selected_state_abb),
              fill = "#333333",
              color = "#333333")
  }
  
  map <- map +
    scale_x_continuous(expand = c(0,0)) +
    scale_y_continuous(expand = c(0,0)) +
    theme_void()
  
  ggplot2::ggsave(outfile, plot = map, width = width, height = height, dpi = dpi)
  
  return(outfile)
}

