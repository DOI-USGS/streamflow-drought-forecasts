# Export steps
# Note: If running for "test" data tier, requires that user be authenticated to
# the `gs-chs-wma-dev` AWS account. If running for "beta" or "prod" data tier,
# requires that user be authenticated to the `gs-chs-wma-prod` AWS account.

source("3_export/src/export_utils.R")

p3_targets <- list(
  ##### Global data that change each run #####
  ###### Date metadata ######
  # csv that controls slider options, issue date, dates for each forecast week
  tar_target(
    p3_date_info_push,
    push_files_to_s3(
      files = p2_date_info_csv,
      s3_bucket_name = p0_website_bucket_name,
      s3_bucket_prefix = p0_website_prefix,
      aws_region = p0_aws_region
    )
  ),
  ###### Gage conditions (current conditions + forecasts) ######
  # Csvs w/ weekly gage conditions for extent summaries
  tar_target(
    p3_conditions_s3_push,
    {
      # Mention upstream target to create edge in dependency graph to control
      # run order
      p3_date_info_push
      # Push weekly gage condition csvs to s3
      push_files_to_s3(
        files = p2_conditions_data_csvs,
        s3_bucket_name = p0_website_bucket_name,
        s3_bucket_prefix = p0_website_prefix,
        aws_region = p0_aws_region
      )
    }
  ),
  # Geojsons w/ weekly gage conditions for interactive map
  tar_target(
    p3_conditions_geojsons_s3_push,
    {
      # Mention upstream target to create edge in dependency graph to control
      # run order
      p3_date_info_push
      # Push weekly gage condition geojsons to s3
      push_files_to_s3(
        files = p2_gage_conditions_geojsons,
        s3_bucket_name = p0_website_bucket_name,
        s3_bucket_prefix = p0_website_prefix,
        aws_region = p0_aws_region
      )
    }
  ),
  ###### Gages metadata ######
  # This target only changes between runs if a site is added/removed, but is
  # important to have up to date for map pop-ups
  tar_target(
    p3_conus_gages_info_push,
    {
      # Mention upstream target to create edge in dependency graph to control
      # run order
      p3_conditions_geojsons_s3_push
      # Push gage metadata to s3
      push_files_to_s3(
        files = p2_conus_gages_info_csv,
        s3_bucket_name = p0_website_bucket_name,
        s3_bucket_prefix = p0_website_prefix,
        aws_region = p0_aws_region
      )
    }
  ),
  ###### Formatted forecasts ######
  # Push formatted forecast parquet file to s3
  tar_target(
    p3_forecast_parquet_s3_push,
    {
      # Mention upstream target to create edge in dependency graph to control
      # run order
      p3_conditions_geojsons_s3_push
      # Formatted parquet file of LSTM <30 and Light GBM forecasts
      push_files_to_s3(
        files = p2_forecast_parquet,
        s3_bucket_name = p0_website_bucket_name,
        s3_bucket_prefix = p0_website_prefix,
        aws_region = p0_aws_region
      )
    }
  ),
  
  ##### Site summary data that change each run #####
  ###### Key dates for timeseries plot ######
  tar_target(
    p3_timeseries_x_domain_push,
    {
      # Mention upstream targets to create edge in dependency graph to control
      # run order
      p3_conditions_s3_push
      p3_conditions_geojsons_s3_push
      # Push timeseries domain csv to s3
      push_files_to_s3(
        files = p2_timeseries_x_domain_csv,
        s3_bucket_name = p0_website_bucket_name,
        s3_bucket_prefix = p0_website_prefix,
        aws_region = p0_aws_region
      )
    }
  ),
  ###### Site-specific timeseries data ######
  # Threshold bands
  # Threshold overlays (lower and upper)
  # Subsetted streamflow
  # Forecasts
  # Streamflow droughts
  tar_target(
    p3_timeseries_data_s3_push,
    {
      # Mention upstream target to create edge in dependency graph to control
      # run order
      p3_timeseries_x_domain_push
      # Command to push timeseries data
      push_files_to_s3(
        files = c(p2_threshold_band_csvs, p2_overlay_lower_csvs, 
                  p2_overlay_upper_csvs, p2_streamflow_subset_csvs, 
                  p2_forecast_csvs, p2_streamflow_drought_csvs),
        s3_bucket_name = p0_website_bucket_name,
        s3_bucket_prefix = p0_website_prefix,
        aws_region = p0_aws_region
      )
    },
    pattern = map(p2_threshold_band_csvs, p2_overlay_lower_csvs, 
                  p2_overlay_upper_csvs, p2_streamflow_subset_csvs, 
                  p2_forecast_csvs, p2_streamflow_drought_csvs)
  ),
  ###### Drought records #####
  # Drought records
  tar_target(
    p3_drought_records_push,
    {
      # Mention upstream target to create edge in dependency graph to control
      # run order
      p3_timeseries_data_s3_push
      # Push csv of drought records for all sites to s3
      push_files_to_s3(
        files = p2_drought_records_csv,
        s3_bucket_name = p0_website_bucket_name,
        s3_bucket_prefix = p0_website_prefix,
        aws_region = p0_aws_region
      )
    }
  ),
  ###### Site mini maps ######
  # This target only changes between runs if a site is added/removed
  tar_target(
    p3_site_maps_s3_push,
    {
      # Mention upstream target to create edge in dependency graph to control
      # run order
      p3_timeseries_data_s3_push
      # Push site mini maps to s3
      push_files_to_s3(
        files = p2_site_map_pngs,
        s3_bucket_name = p0_website_bucket_name,
        s3_bucket_prefix = p0_website_prefix,
        aws_region = p0_aws_region
      )
    }
  ),
  
  ##### Data that are unchanged between runs #####
  ###### State geojsons for highlighting states in state views ######
  tar_target(
    p3_conus_states_geosjons_s3_push,
    {
      # Mention upstream target to create edge in dependency graph to control
      # run order
      p3_site_maps_s3_push
      # Push state geojsons to s3
      push_files_to_s3(
        files = p2_conus_states_geosjons,
        s3_bucket_name = p0_website_bucket_name,
        s3_bucket_prefix = p0_website_prefix,
        aws_region = p0_aws_region
      )
    }
  ),
  ###### Icon maps ######
  # CONUS map for map reset icon
  tar_target(
    p3_conus_png,
    {
      # Mention upstream target to create edge in dependency graph to control
      # run order
      p3_site_maps_s3_push
      # Generate CONUS map
      generate_map(
        conus_states_sf = p1_conus_states_20m_sf,
        selected_state_abb = NULL,
        outfile = "src/assets/images/conus_map.png",
        width = 3,
        height = 2,
        dpi = 300
      )
    },
    format = "file"
  ),
  # CONUS map with Texas highlighted for state picker icon
  tar_target(
    p3_conus_focal_state_png,
    {
      # Mention upstream target to create edge in dependency graph to control
      # run order
      p3_site_maps_s3_push
      # Generate CONUS map with Texas highlighted
      generate_map(
        conus_states_sf = p1_conus_states_20m_sf,
        selected_state_abb = 'TX',
        outfile = "src/assets/images/state_map.png",
        width = 3,
        height = 2,
        dpi = 300
      )
    },
    format = "file"
  ),
  ###### State grid for state picker ######
  # Layout grid for state picker
  tar_target(
    p3_state_layout_csv,
    {
      # Mention upstream target to create edge in dependency graph to control
      # run order
      p3_site_maps_s3_push
      # Generate layout grid for state picker
      outfile <- "public/conus_grid_layout.csv"
      geofacet::us_state_grid1 |>
        as_tibble() |>
        dplyr::filter(!code %in% c("AK", "HI", "DC")) |>
        readr::write_csv(outfile)
      return(outfile)
    },
    format = "file"
  )
)