source("2_process/src/data_utils.R")
source("3_export/src/export_utils.R")

p2_targets <- list(
  ##### Process thresholds data #####
  tar_target(
    p2_plot_end_date,
    max(pull(p2_forecast_data, dt)) + p0_end_date_buffer_days
  ),
  tar_target(
    p2_plot_dates,
    seq(p2_antecedent_start_date, p2_plot_end_date, by = "day")
  ),
  tar_target(
    p2_jd_thresholds_csvs,
    process_thresholds_data(
      site = p1_sites,
      thresholds_csv = p1_thresholds_csvs,
      replace_negative_flow_w_zero = p0_replace_negative_flow_w_zero,
      outfile_template = "2_process/tmp/thresholds_jd/%s.csv"
    ),
    pattern = map(p1_sites, p1_thresholds_csvs),
    format = "file"
  ),
  tar_target(
    p2_threshold_band_csvs,
    generate_threshold_band_csv(
      site = p1_sites,
      thresholds_jd_csv = p2_jd_thresholds_csvs,
      date_subset = p2_plot_dates,
      outfile_template = "2_process/out/thresholds/%s.csv"
    ),
    pattern = map(p1_sites, p2_jd_thresholds_csvs),
    format = "file"
  ),
  
  ##### Process streamflow #####
  # Get start date for antecedent period
  tar_target(
    p2_antecedent_start_date,
    p1_issue_date - p0_antecedent_days
  ),
  # Set latest streamflow date to day before issue date
  tar_target(
    p2_latest_streamflow_date,
    p1_issue_date - 1
  ),
  # Subset streamflow
  tar_target(
    p2_streamflow_subset_csvs,
    munge_streamflow(
      site = p1_sites,
      streamflow_csv = p1_streamflow_csvs,
      thresholds_jd_csv = p2_jd_thresholds_csvs,
      start_date = p2_antecedent_start_date,
      end_date = p2_latest_streamflow_date,
      replace_negative_flow_w_zero = p0_replace_negative_flow_w_zero,
      round_near_zero_to_zero = p0_round_near_zero_to_zero,
      outfile_template = "2_process/out/streamflow/%s.csv"
    ),
    pattern = map(p1_sites, p1_streamflow_csvs, p2_jd_thresholds_csvs),
    format = 'file'
  ),
  # Identify streamflow droughts
  tar_target(
    p2_streamflow_drought_csvs,
    identify_streamflow_droughts(
      site = p1_sites,
      streamflow_csv = p2_streamflow_subset_csvs,
      outfile_template = "2_process/out/streamflow_droughts/%s.csv"
    ),
    pattern = map(p1_sites, p2_streamflow_subset_csvs),
    format = 'file'
  ),
  # Compute drought record
  tar_target(
    p2_drought_records,
    compute_drought_records(
      sites = p1_sites,
      streamflow_csvs = p1_streamflow_csvs, 
      thresholds_jd_csvs = p2_jd_thresholds_csvs,
      streamflow_drought_csvs = p2_streamflow_drought_csvs,
      antecedent_start_date = p2_antecedent_start_date,
      issue_date = p1_issue_date,
      latest_streamflow_date = p2_latest_streamflow_date,
      replace_negative_flow_w_zero = p0_replace_negative_flow_w_zero,
      round_near_zero_to_zero = p0_round_near_zero_to_zero
    )
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
    p2_date_info,
    build_date_info_table(
      issue_date = p1_issue_date,
      latest_streamflow_date = p2_latest_streamflow_date,
      forecasts = p2_forecast_data
    )
  ),
  tar_target(
    p2_conditions_and_forecasts,
    join_conditions_and_forecasts(
      streamflow_csvs = p2_streamflow_subset_csvs,
      issue_date = p1_issue_date,
      latest_streamflow_date = p2_latest_streamflow_date,
      forecasts = p2_forecast_data
    )
  ),
  tarchetypes::tar_group_by(
    p2_conditions_and_forecasts_grouped,
    p2_conditions_and_forecasts |>
      group_by(f_w),
    f_w
  ),
  tar_target(
    p2_conditions_data_csvs,
    {
      outfile <- sprintf("2_process/out/conditions/conditions_w%s.csv",
                         unique(p2_conditions_and_forecasts_grouped[["f_w"]]))
      out_dir <- dirname(outfile)
      if (!dir.exists(out_dir)) dir.create(out_dir)
      p2_conditions_and_forecasts_grouped |>
        select(StaID, dt, pd) |>
        readr::write_csv(outfile)
      return(outfile)
    },
    pattern = map(p2_conditions_and_forecasts_grouped),
    format = "file"
  ),
  # forecasts by site
  tarchetypes::tar_group_by(
    p2_forecast_data_grouped,
    p2_forecast_data |>
      group_by(StaID),
    StaID
  ),
  tar_target(
    p2_forecast_csvs,
    convert_forecast_percentiles_to_cfs(
      site = p1_sites,
      site_forecast = p2_forecast_data_grouped,
      thresholds_csv = p1_thresholds_csvs,
      thresholds_jd_csv = p2_jd_thresholds_csvs,
      outfile_template = "2_process/out/forecasts/%s.csv"
    ),
    pattern = map(p1_sites, p2_forecast_data_grouped, p1_thresholds_csvs,
                  p2_jd_thresholds_csvs),
    format = "file"
  ),
  
  ##### Process spatial data #####
  # spatial data
  tar_target(
    p2_conus_gages_shp,
    munge_conus_gages(
      in_shp = p1_conus_gages_raw_shp,
      forecast_sites = p1_sites,
      outfile = "2_process/out/CONUS_gages.shp"
    ),
    format = 'file'
  ),
  tar_target(
    p2_conus_gages_sf,
    sf::st_read(p2_conus_gages_shp) |>
      dplyr::mutate(StaID = ifelse(nchar(as.character(StaID)) == 8,
                                   as.character(StaID),
                                   paste0("0", as.character(StaID))))
  ),
  tar_target(
    p2_conus_gages_info,
    munge_gage_info(
      gages_sf = p2_conus_gages_sf,
      gages_binary_qualifiers_csv = p1_gages_binary_qualifiers_csv,
      gages_addl_snow_qualifiers_csv = p1_gages_addl_snow_qualifiers_csv,
      forecast_sites = p1_sites
    )
  ),
  # Geojson w/ all forecasts
  # Requires system installation of mapshaper
  # https://github.com/mbloch/mapshaper?tab=readme-ov-file#installation
  tar_target(
    p2_gage_conditions_geojsons,
    generate_conditions_geojson(
      conditions_and_forecasts = p2_conditions_and_forecasts_grouped,
      gages_shp = p2_conus_gages_shp,
      cols_to_keep = NULL,
      precision = 0.0001,
      tmp_dir = "2_process/tmp",
      outfile_template = "2_process/out/conditions_geojsons/CONUS_data_w%s.geojson"
    ),
    pattern = map(p2_conditions_and_forecasts_grouped),
    format = "file"
  ),
  # Site maps
  tar_target(
    p2_map_proj,
    "ESRI:102004"
  ),
  tar_target(
    p2_site_map_pngs,
    generate_site_map(
      gages_sf = p2_conus_gages_sf,
      proj = p2_map_proj,
      site = p1_sites,
      outfile_template = "2_process/out/site_maps/%s.png",
      width = 3,
      height = 2,
      dpi = 300
    ),
    pattern = map(p1_sites),
    format = "file"
  ),
  
  ##### Generate overlays to mask thresholds outside of uncertainty bars #####
  tar_target(
    p2_buffer_dates,
    generate_buffer_dates(
      date_info = p2_date_info,
      bar_width_days = p0_bar_width_days
    )
  ),
  tar_target(
    p2_overlay_lower_csvs,
    generate_lower_overlay(
      site = p1_sites,
      site_forecast_csv = p2_forecast_csvs,
      thresholds_jd_csv = p2_jd_thresholds_csvs,
      buffer_dates = p2_buffer_dates,
      date_subset = p2_plot_dates,
      outfile_template = "2_process/out/overlays_lower/%s.csv"
    ),
    map(p1_sites, p2_forecast_csvs, p2_jd_thresholds_csvs),
    format = "file"
  ),
  tar_target(
    p2_overlay_upper_csvs,
    generate_upper_overlay(
      site = p1_sites,
      site_forecast_csv = p2_forecast_csvs,
      thresholds_jd_csv = p2_jd_thresholds_csvs,
      buffer_dates = p2_buffer_dates,
      date_subset = p2_plot_dates,
      outfile_template = "2_process/out/overlays_upper/%s.csv"
    ),
    map(p1_sites, p2_forecast_csvs, p2_jd_thresholds_csvs),
    format = "file"
  )
)
