source("3_export/src/export_utils.R")

p3_targets <- list(
  ##### Mini maps #####
  tar_target(
    p3_conus_png,
    generate_map(
      proj = p2_map_proj,
      selected_state_abb = NULL,
      outfile = "src/assets/images/conus_map.png",
      width = 3,
      height = 2,
      dpi = 300
    ),
    format = "file"
  ),
  tar_target(
    p3_conus_focal_state_png,
    generate_map(
      proj = p2_map_proj,
      selected_state_abb = 'TX',
      outfile = "src/assets/images/state_map.png",
      width = 3,
      height = 2,
      dpi = 300
    ),
    format = "file"
  ),
  tar_target(
    p3_state_layout_csv,
    {
      outfile <- "public/conus_grid_layout.csv"
      geofacet::us_state_grid1 |>
        as_tibble() |>
        dplyr::filter(!code %in% c("AK", "HI", "DC")) |>
        readr::write_csv(outfile)
      return(outfile)
    },
    format = "file"
  ),
  tar_target(
    p3_site_maps_s3_push,
    push_files_to_s3(
      files = p2_site_map_pngs,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  ),
  ##### Spatial metadata #####
  tar_target(
    p3_conus_gages_info_csv,
    {
      outfile <- "public/site_info.csv"
      p2_conus_gages_info_sf |>
        sf::st_drop_geometry() |>
        readr::write_csv(outfile)
      return(outfile)
    },
    format = "file"
  ),
  tar_target(
    p3_conus_gages_geojson,
    generate_geojson(
      data_sf = p2_conus_gages_info_sf,
      cols_to_keep = 'StaID',
      precision = 0.0001,
      tmp_dir = "2_process/tmp",
      outfile = "public/CONUS_data.geojson"
    ),
    format = "file"
  ),
  ##### Date metadata #####
  # Export key dates for timeseries plot
  tar_target(
    p2_timeseries_x_domain_csv,
    {
      outfile <- "public/timeseries_x_domain.csv"
      date_df <- tibble(
        start = p2_antecedent_start_date,
        end = p2_plot_end_date
      )
      readr::write_csv(date_df, outfile)
      return(outfile)
    },
    format = "file"
  ),
  ##### Gage conditions (current conditions + forecasts) #####
  # Write gage conditions metadata
  tar_target(
    p2_date_info_csv,
    {
      outfile <- "public/date_info.csv"
      readr::write_csv(p2_date_info, outfile)
      return(outfile)
    },
    format = "file"
  ),
  # All gage conditions
  tar_target(
    p3_conditions_s3_push,
    push_files_to_s3(
      files = p2_conditions_data_csvs,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  ),
  # Geojsons w/ weekly gage conditions
  tar_target(
    p3_conditions_geojsons_s3_push,
    push_files_to_s3(
      files = p2_gage_conditions_geojsons,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  ),
  # Site forecasts
  # Must be logged into gs-chs-wma-prod AWS account
  tar_target(
    p3_forecasts_s3_push,
    push_files_to_s3(
      files = p2_forecast_csvs,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  ),
  
  ##### Streamflow #####
  # Push subsetted streamflow files to s3
  # Must be logged into gs-chs-wma-prod AWS account
  tar_target(
    p3_streamflow_s3_push,
    push_files_to_s3(
      files = p2_streamflow_subset_csvs,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  ),
  tar_target(
    p3_streamflow_droughts_s3_push,
    push_files_to_s3(
      files = p2_streamflow_drought_csvs,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  ),
  
  ##### Drought thresholds #####
  # Site-specific threshold bands
  # Must be logged into gs-chs-wma-prod AWS account
  tar_target(
    p3_thresholds_s3_push,
    push_files_to_s3(
      files = p2_threshold_band_csvs,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  ),
  
  ##### Threshold overlays #####
  # Site-specific threshold overlays
  # Must be logged into gs-chs-wma-prod AWS account
  tar_target(
    p3_overlay_lower_s3_push,
    push_files_to_s3(
      files = p2_overlay_lower_csvs,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  ),
  tar_target(
    p3_overlay_upper_s3_push,
    push_files_to_s3(
      files = p2_overlay_upper_csvs,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  )
)