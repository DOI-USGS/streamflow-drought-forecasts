source("3_export/src/export_utils.R")

p3_targets <- list(
  # Push subsetted streamflow files to s3
  # Must be logged into gs-chs-wma-prod AWS account
  tar_target(
    p3_streamflow_s3_push,
    push_files_to_s3(
      files = p2_streamflow_subset_csvs, 
      website_bucket_name = p0_website_bucket_name, 
      s3_website_prefix = p0_website_prefix, 
      aws_region = p0_aws_region
    )
  )
)