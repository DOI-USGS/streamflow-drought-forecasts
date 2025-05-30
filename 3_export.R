source("3_export/src/export_utils.R")

p3_targets <- list(
  # Spatial data
  tar_target(
    p3_conus_gages_info_csv,
    {
      outfile <- "public/site_info.csv"
      readr::write_csv(p2_conus_gages_info, outfile)
      return(outfile)
    }
  ),
  # Export key dates for timeseries plot
  tar_target(
    p2_timeseries_x_domain_csv,
    {
      outfile <- "public/timeseries_x_domain.csv"
      date_df <- tibble(
        start = p2_antecedent_start_date,
        end = max(pull(p2_forecast_data, forecast_date)) + p0_end_date_buffer_days
      )
      readr::write_csv(date_df, outfile)
      return(outfile)
    }
  ),
  # Write forecast data
  tar_target(
    p2_forecast_info_csv,
    {
      outfile <- "public/forecast_info.csv"
      readr::write_csv(p2_forecast_info, outfile)
      return(outfile)
    },
    format = "file"
  ),
  tar_target(
    p2_forecast_data_csv,
    {
      outfile <- "public/forecast_data.csv"
      readr::write_csv(p2_forecast_wide, outfile)
      return(outfile)
    },
    format = "file"
  ),
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
  )
)