
subset_streamflow <- function(file, start_date, out_dir) {
  dir.create(out_dir, showWarnings = FALSE)
  outfile <- file.path(out_dir, basename(file))
  readr::read_csv(file, col_types = cols(StaID = "c")) |>
    select(StaID, dt, result = Flow_7d, pd = weibull_jd_30d_wndw_7d) |>
    filter(dt >= start_date) |>
    readr::write_csv(outfile)

  return(outfile)
}

#' @description Munge input spatial data for CONUS gages
#' 
#' @param in_file The filepath for the raw shapefile downloaded from s3
#' @param forecast_sites vector of site ids for subsetting the spatial data
#' @param out_file The filepath for the munged output shapefile
#' @returns The output filepath for the munged shapefile
#'
munge_conus_gages <- function(in_file, forecast_sites, out_file) {
  
  sf::st_read(in_file) |>
    sf::st_drop_geometry()|>
    sf::st_as_sf(coords = c("dec_long_v", "dec_lat_va"), crs = "EPSG:4269") |>
    dplyr::select(StaID = site_no, station_nm, state_cd, county_cd, huc_cd) |>
    dplyr::mutate("StaID" = stringr::str_pad(StaID, 8, pad = "0")) |>
    dplyr::filter(StaID %in% forecast_sites) |>
    sf::st_write(out_file, append = FALSE)
  
  return(out_file)
}

munge_gage_info <- function(gages_shp) {
  conus_counties <- tigris::counties(cb = TRUE, resolution = "20m") |>
    sf::st_drop_geometry()
  
  sf::read_sf(gages_shp) |>
    dplyr::mutate(StaID = ifelse(nchar(as.character(StaID)) == 8,
                                 as.character(StaID),
                                 paste0("0", as.character(StaID)))) |>
    sf::st_drop_geometry() |>
    mutate("GEOID" = paste0(state_cd, stringr::str_pad(county_cd, 3, pad = "0"))) |>
    left_join(conus_counties, by = "GEOID") |>
    select(StaID, station_nm, huc_cd, state = STATE_NAME, county = NAMELSAD)
}
