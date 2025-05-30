source("2_process/src/data_utils.R")

p2_targets <- list(
  ### Process spatial data
  # spatial data
  tar_target(
    p2_conus_gages_shp,
    munge_conus_gages(
      in_file = p1_conus_gages_raw_shp,
      forecast_sites = p1_sites,
      out_file = "2_process/out/CONUS_gages.shp"
    ),
    format = 'file'
  ),
  tar_target(
    p2_conus_gages_info,
    munge_gage_info(
      gages_shp = p2_conus_gages_shp
    )
  ),
  ### Process forecasts
  tar_target(
    p2_forecast_data,
    arrow::open_dataset(
      sources = p1_forecast_feathers,
      format = 'feather') |>
      dplyr::collect() |>
      dplyr::rename('StaID' = 'site_id') |>
      # filter to subset defined by p1_sites
      dplyr::filter(StaID %in% p1_sites) |>
      dplyr::mutate(issue_date = as.Date(reference_datetime, 
                                         tz = 'America/New_York'),
                    forecast_date = as.Date(datetime, tz = 'America/New_York'),
                    forecast_week = as.integer(difftime(forecast_date, 
                                                        issue_date, 
                                                        units="weeks"))) |>
      dplyr::arrange(forecast_date)
  ),
  tar_target(
    p2_forecast_wide,
    p2_forecast_data  |>
      dplyr::mutate(
        prediction = round(prediction, 1),
        # parameter = case_when(
        #   parameter == "median" ~ "pd",
        #   parameter == "pred_interv_05" ~ "pd5",
        #   parameter == "pred_interv_95" ~ "pd95"
        # )
      ) |>
      dplyr::select(StaID, forecast_date, parameter, prediction) |>
      pivot_wider(id_cols = c("StaID",  "forecast_date"), 
                  names_from = "parameter",
                  values_from = "prediction")
  ),
  # medians only
  tar_target(
    p2_forecast_medians,
    p2_forecast_data |>
      dplyr::filter(parameter == 'median')
  ),
  tar_target(
    p2_forecast_info,
    tibble(
      issue_date = unique(p2_forecast_data[["issue_date"]]),
      forecast_date = unique(p2_forecast_data[["forecast_date"]]),
      f_w = unique(p2_forecast_data[["forecast_week"]]),
    )
  ),
  ### Process streamflow
  # Get start date for antecedent period
  tar_target(
    p2_antecedent_start_date,
    p1_latest_forecast_date - p0_antecedent_days
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
