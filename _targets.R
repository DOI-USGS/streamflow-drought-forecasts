library(targets)
library(tarchetypes)

options(tidyverse.quiet = TRUE)

# set package needs
tar_option_set(packages = c("aws.s3",
                            "tidyverse",
                            "arrow",
                            "tigris",
                            "sf",
                            "lubridate"))

# files to source
source('1_fetch.R')
source('2_process.R')
source('3_export.R')


p0_targets <- list(
  ########  SET UP GLOBAL PARAMETERS ########
  # AWS parameters
  tar_target(
    p0_aws_region,
    "us-west-2"
  ),
  tar_target(
    p0_pipeline_bucket_name,
    "drought-operational-dev"
  ),
  tar_target(
    p0_website_bucket_name,
    "water-visualizations-prod-website"
  ),
  tar_target(
    p0_website_prefix,
    "visualizations/streamflow-drought-forecasts"
  ),
  tar_target(
    p0_ecs_environment_boolean,
    (tolower(Sys.getenv("RUNNING_ON_AWS_ECS")) %in% c("true"))
  ),
  # CONUS forecast weeks
  # NOTE: will be 1-13 eventually
  tar_target(
    p0_forecast_weeks,
    c(1, 2, 4, 9, 13)
  ),
  # Data processing parameters
  tar_target(
    p0_antecedent_days,
    90
  ),
  tar_target(
    p0_end_date_buffer_days,
    30
  ),
  tar_target(
    p0_replace_negative_w_zero,
    FALSE
  )
)

# Combined list of target outputs
c(p0_targets, p1_targets, p2_targets, p3_targets)