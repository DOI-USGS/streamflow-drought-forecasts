# Export steps
# Note: If running for "test" data tier, requires that user be authenticated to
# the `gs-chs-wma-dev` AWS account. If running for "beta" or "prod" data tier,
# requires that user be authenticated to the `gs-chs-wma-prod` AWS account.

source("3_export/src/export_utils.R")

p3_targets <- list(
  ##### Mini maps #####
  tar_target(
    p3_conus_png,
    generate_map(
      conus_states_sf = p1_conus_states_20m_sf,
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
      conus_states_sf = p1_conus_states_20m_sf,
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
    p3_conus_states_geosjons_s3_push,
    push_files_to_s3(
      files = p2_conus_states_geosjons,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
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
    p3_conus_gages_info_push,
    push_files_to_s3(
      files = p2_conus_gages_info_csv,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  ),
  ##### Date metadata #####
  # Export key dates for timeseries plot
  tar_target(
    p3_timeseries_x_domain_push,
    push_files_to_s3(
      files = p2_timeseries_x_domain_csv,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  ),
  ##### Gage conditions (current conditions + forecasts) #####
  # Write gage conditions metadata
  tar_target(
    p3_date_info_push,
    push_files_to_s3(
      files = p2_date_info_csv,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
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
  ##### Formatted forecasts #####
  # Push formatted forecast parquet file to s3
  tar_target(
    p3_forecast_parquet_s3_push,
    push_files_to_s3(
      files = p2_forecast_parquet,
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
  # Drought records
  tar_target(
    p3_drought_records_push,
    push_files_to_s3(
      files = p2_drought_records_csv,
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