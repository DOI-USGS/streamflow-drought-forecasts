source("3_export/src/export_utils.R")

p3_targets <- list(
  ##### Spatial metadata #####
  tar_target(
    p3_conus_gages_info_csv,
    {
      outfile <- "public/site_info.csv"
      readr::write_csv(p2_conus_gages_info, outfile)
      return(outfile)
    }
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
    }
  ),
  ##### Forecasts #####
  # Write forecast metadata
  tar_target(
    p2_forecast_info_csv,
    {
      outfile <- "public/forecast_info.csv"
      readr::write_csv(p2_forecast_info, outfile)
      return(outfile)
    },
    format = "file"
  ),
  # All forecasts
  tar_target(
    p2_forecast_data_csv,
    {
      outfile <- "public/forecast_data.csv"
      readr::write_csv(p2_forecast_wide, outfile)
      return(outfile)
    },
    format = "file"
  ),
  # Geojson w/ all forecasts
  # Requires system installation of mapshaper
  tar_target(
    p3_forecast_geojson,
    generate_geojson(
      data_sf = p2_forecast_medians_sf,
      cols_to_keep = NULL,
      precision = 0.0001,
      tmp_dir = "2_process/tmp",
      outfile = "public/CONUS_data.geojson"
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