source("2_process/src/data_utils.R")

p2_targets <- list(
  ### Process streamflow
  # Get start date for antecedent period
  tar_target(
    p2_antecedent_start_date,
    p1_latest_forecast_date - p0_antedent_days
  ),
  # Subset streamflow
  tar_target(
    p2_streamflow_subset_csvs,
    subset_streamflow(
      file = p1_streamflow_csvs,
      start_date = p2_antecedent_start_date,
      out_dir = '2_process/out/streamflow'
    ),
    pattern = map(p1_streamflow_csvs),
    format = 'file'
  )
)
