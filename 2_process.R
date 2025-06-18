source("2_process/src/data_utils.R")

p2_targets <- list(
  ##### Process streamflow #####
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
  ),
  
  ##### Process thresholds data #####
  tar_target(
    p2_plot_end_date,
    max(pull(p2_forecast_data, forecast_date)) + p0_end_date_buffer_days
  ),
  tar_target(
    p2_plot_dates,
    seq(p2_antecedent_start_date, p2_plot_end_date, by = "day")
  ),
  tar_target(
    p2_jd_thresholds,
    process_thresholds_data(
      thresholds_csv = p1_thresholds_csvs,
      date_subset = p2_plot_dates,
      replace_negative_flow_w_zero = p0_replace_negative_flow_w_zero
    ),
    pattern = map(p1_thresholds_csvs)
  ),
  tar_target(
    p2_threshold_band_csvs,
    generate_threshold_band_csvs(
      thresholds_jd = p2_jd_thresholds,
      date_subset = p2_plot_dates,
      outfile_template = "2_process/out/thresholds/%s.csv"
    ),
    pattern = map(p2_jd_thresholds),
    format = "file"
  ),
  
  ##### Process forecasts #####
  tar_target(
    p2_forecast_data,
    munge_raw_forecast_data(
      forecast_feathers = p1_forecast_feathers,
      forecast_sites = p1_sites,
      replace_out_of_bound_predictions = p0_replace_out_of_bound_predictions
    )
  ),
  tar_target(
    p2_forecast_info,
    tibble(
      issue_date = unique(p2_forecast_data[["issue_date"]]),
      forecast_date = unique(p2_forecast_data[["forecast_date"]]),
      f_w = unique(p2_forecast_data[["forecast_week"]]),
    )
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
      dplyr::select(StaID, f_w = forecast_week, forecast_date, parameter, prediction) |>
      pivot_wider(id_cols = c("StaID",  "f_w", "forecast_date"), 
                  names_from = "parameter",
                  values_from = "prediction")
  ),
  # forecasts by site
  tarchetypes::tar_group_by(
    p2_forecast_data_grouped,
    p2_forecast_data |>
      group_by(StaID),
    StaID
  ),
  tar_target(
    p2_forecast_cfs,
    convert_percentiles_to_cfs(
      site_forecasts = p2_forecast_data_grouped,
      thresholds_csv = p1_thresholds_csvs, 
      thresholds_jd = p2_jd_thresholds),
    pattern = map(p2_forecast_data_grouped, p1_thresholds_csvs, p2_jd_thresholds)
  ),
  tar_target(
    p2_forecast_csvs,
    generate_forecast_csvs(
      site_forecasts = p2_forecast_cfs,
      thresholds_jd = p2_jd_thresholds, 
      outfile_template = "2_process/out/forecasts/%s.csv"
    ),
    pattern = map(p2_forecast_cfs, p2_jd_thresholds),
    format = "file"
  ),
  # # medians only
  # tar_target(
  #   p2_forecast_medians_csvs,
  #   process_medians(
  #     site_forecasts = p2_forecast_data_grouped,
  #     out_dir = '2_process/out/medians'
  #   ),
  #   pattern = map(p2_forecast_data_grouped),
  #   format = "file"
  # ),
  
  ##### Process spatial data #####
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
  tar_target(
    p2_forecast_medians_sf,
    join_median_forecasts_and_spatial_data(
      forecasts = p2_forecast_wide,
      gages_shp = p2_conus_gages_shp
    )
  ),
  
  ##### Generate overlays to mask thresholds outside of uncertainty bars #####
  tar_target(
    p2_buffer_dates,
    generate_buffer_dates(
      forecast_info = p2_forecast_info,
      bar_width_days = p0_bar_width_days
    )
  ),
  tar_target(
    p2_overlay_lower_csvs,
    generate_lower_overlay(
      site_forecasts = p2_forecast_cfs,
      thresholds_jd = p2_jd_thresholds,
      buffer_dates = p2_buffer_dates,
      date_subset = p2_plot_dates,
      outfile_template = "2_process/out/overlays_lower/%s.csv"
    ),
    map(p2_forecast_cfs, p2_jd_thresholds),
    format = "file"
  ),
  tar_target(
    p2_overlay_upper_csvs,
    generate_upper_overlay(
      site_forecasts = p2_forecast_cfs,
      thresholds_jd = p2_jd_thresholds,
      buffer_dates = p2_buffer_dates,
      date_subset = p2_plot_dates,
      outfile_template = "2_process/out/overlays_upper/%s.csv"
    ),
    map(p2_forecast_cfs, p2_jd_thresholds),
    format = "file"
  )
)
