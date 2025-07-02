#' @title write to geojson
#' @description write data to geojson
#' @param data_sf sf dataframe to be written to geojson
#' @param cols_to_keep columns from dataframe to write. If NULL, all are kept
#' @param outfile filepath to which geojson should be written
#' @return the filepath of the saved geojson
write_to_geojson <- function(data_sf, cols_to_keep = NULL, outfile) {
  if (file.exists(outfile)) unlink(outfile)
  
  if (!is.null(cols_to_keep)) {
    data_sf <- dplyr::select(data_sf, !!cols_to_keep)
  }
  
  data_sf %>%
    sf::st_transform(crs = 4326) %>%
    sf::st_write(outfile, append = FALSE)
  
  return(outfile)
}

generate_geojson <- function(data_sf, cols_to_keep, precision, tmp_dir, outfile) {
  raw_geojson <- file.path(tmp_dir, basename(outfile))
  write_to_geojson(
    data_sf = data_sf, 
    cols_to_keep = cols_to_keep,
    outfile = raw_geojson
  )
  system(sprintf('mapshaper %s -o %s precision=%s format=geojson', 
                 raw_geojson, outfile, precision))
  unlink(raw_geojson)
  return(outfile)
}

push_files_to_s3 <- function(files, s3_bucket_name, s3_bucket_prefix, 
                             aws_region) {
  copy_df <- tibble(local_file = files) |>
    mutate(target = sub("^2_process/out/", "", files),
           target = c(sub(
             "^",
             paste0("s3://",
                    s3_bucket_name,
                    "/",
                    s3_bucket_prefix,
                    "/"),
             target))
    )
  
  for (i in seq_len(nrow(copy_df))) {
    cat(paste("s3 copying", 
              copy_df[i, ]$local_file, 
              "to", 
              copy_df[i, ]$target, "\n"))
    put_object(file = copy_df[i, ]$local_file,
               object = copy_df[i, ]$target,
               bucket = s3_bucket_name,
               region = aws_region,
               acl = "bucket-owner-full-control")
  }
}
