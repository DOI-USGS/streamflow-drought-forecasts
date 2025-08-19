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

push_files_to_s3 <- function(files, data_tier, s3_bucket_name, s3_bucket_prefix, 
                             aws_region) {
  # Create S3 client
  s3 <- paws::s3(config = list(region = aws_region))
  
  copy_df <- tibble(local_file = files) |>
    mutate(target = sub("^2_process/out/", 
                        stringr::str_glue("{data_tier}/"), 
                        files),
           target = sub(
             "^",
             paste0(s3_bucket_prefix, "/"),
             target)
    )
  
  for (i in seq_len(nrow(copy_df))) {
    cat(paste("s3 copying", 
              copy_df[i, ]$local_file, 
              "to", 
              copy_df[i, ]$target, "\n"))

    s3$put_object(
      Bucket = s3_bucket_name,
      Key = copy_df[i, ]$target,
      Body = copy_df[i, ]$local_file,
      ContentType = xfun::mime_type(copy_df[i, ]$local_file),
      ACL = "bucket-owner-full-control"
    )
  }
}

generate_map <- function(proj, selected_state_abb = NULL, outfile, width, 
                         height, dpi) {
  
  conus_states_sf <- tigris::states(cb = TRUE, resolution = "20m", 
                                    progress_bar = FALSE) |>
    dplyr::filter(STUSPS %in% state.abb[!state.abb %in% c("AK", "HI")]) |>
    sf::st_transform(crs = proj)

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

