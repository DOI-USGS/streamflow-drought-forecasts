library(targets)
library(tarchetypes)

options(tidyverse.quiet = TRUE)

# set package needs
tar_option_set(packages = c("paws",
                            "xfun",
                            "tidyverse",
                            "arrow",
                            "tigris",
                            "sf",
                            "lubridate",
                            "geofacet",
                            "zoo",
                            "data.table",
                            "dataRetrieval"))
# Also requires system installation of mapshaper
# https://github.com/mbloch/mapshaper?tab=readme-ov-file#installation

# files to source
source('1_fetch.R')
source('2_process.R')
source('3_export.R')


p0_targets <- list(
  ########  SET UP GLOBAL PARAMETERS ########
  # Site build tier
  tar_target(
    p0_data_tier,
    {
      data_tier <- Sys.getenv("VITE_APP_DATA_TIER")
      stopifnot(
        "data_tier must be one of test, beta, or prod." = data_tier %in%
          c("test", "beta", "prod")
      )
      return(data_tier)
    },
    cue = tar_cue(mode = "always")
  ),
  tar_target(
    show_token,
    cat(paste("the token is", Sys.getenv("API_USGS_PAT"), "\n"))
  ),
  # AWS parameters
  tar_target(
    p0_aws_region,
    "us-west-2"
  ),
  tar_target(
    p0_pipeline_bucket_name,
    ifelse(p0_data_tier == "test", 
           "drought-operational-dev", 
           "drought-operational-prod")
  ),
  tar_target(
    p0_website_bucket_name,
    ifelse(p0_data_tier == "test", 
           "water-visualizations-development-website", 
           sprintf("water-visualizations-%s-website", p0_data_tier))
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
  tar_target(
    p0_forecast_weeks,
    seq(1,13)
  ),
  # Data processing parameters
  tar_target(
    p0_antecedent_days,
    90
  ),
  tar_target(
    p0_end_date_buffer_days,
    7
  ),
  # parameter for restricting predicted percentiles to 0-100
  tar_target(
    p0_replace_out_of_bound_predictions,
    TRUE
  ),
  # parameter for replacing negative flow values with zero
  tar_target(
    p0_replace_negative_flow_w_zero,
    TRUE
  ),
  # parameter for rounding flows <0.001 to zero
  tar_target(
    p0_round_near_zero_to_zero,
    TRUE
  ),
  # NOTE: this must match `WIDTH_IN_DAYS` set in 
  # `src/assets/scripts/d3/time_series_points.js` and
  # `src/assets/scripts/d3/time_series_rects.js`
  # MUST be an odd value
  tar_target(
    p0_bar_width_days,
    5
  ),
  tar_target(
    p0_map_proj,
    "ESRI:102004"
  )
)

# Combined list of target outputs
c(p0_targets, p1_targets, p2_targets, p3_targets)
