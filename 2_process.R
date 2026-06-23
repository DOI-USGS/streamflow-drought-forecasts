source("2_process/src/data_utils.R")
source("3_export/src/export_utils.R")

p2_targets <- list(
  ##### Process spatial data #####
  ###### Gages ######
  # spatial data
  tar_target(
    p2_conus_gages_info_csv,
    munge_gage_info(
      gages_sf = p1_conus_gages_sf,
      gages_binary_qualifiers_csv = p1_gages_binary_qualifiers_csv,
      outfile = "2_process/out/site_info.csv"
    ),
    format = "file"
  ),
  # Site maps
  tar_target(
    p2_site_map_pngs,
    generate_site_map(
      conus_states_sf = p1_conus_states_20m_sf,
      gages_sf = p1_conus_gages_sf,
      proj = p0_map_proj,
      site = p1_sites,
      outfile_template = "2_process/out/site_maps/%s.png",
      width = 3,
      height = 2,
      dpi = 300
    ),
    pattern = map(p1_sites),
    format = "file"
  ),
  
  ###### States ######
  tar_target(
    p2_conus_states,
    p1_conus_states_500k_sf |> 
      dplyr::filter(!STUSPS == "DC") |> 
      arrange(NAME) |> 
      pull(NAME) |> 
      unique()
  ),
  tar_target(
    p2_conus_states_geosjons,
    {
      state_sf <- p1_conus_states_500k_sf |>
        dplyr::filter(NAME == p2_conus_states)
      generate_geojson(
        data_sf = state_sf, 
        cols_to_keep = c('STUSPS', 'NAME'), 
        precision = 0.0001,
        tmp_dir = "2_process/tmp",
        outfile = sprintf("2_process/out/state_geojsons/%s.geojson",
                          gsub(" ", "_", p2_conus_states))
      )
    },
    pattern = map(p2_conus_states),
    format = "file"
  ),
  ###### Ungaged units ######
  # Ungaged catchments
  tar_target(
    p2_ungaged_catchments_sf,
    arrow::read_parquet(p1_ungaged_catchments_parquet) |>
      sf::st_as_sf(crs = p0_ungaged_data_proj)
  ),
  tar_target(
    p2_ungaged_polygon_ids,
    unique(p2_ungaged_catchments_sf[["hru_segment_v1_1"]])
  ),
  # Ungaged catchment id xwalk
  tar_target(
    p2_ungaged_catchments_id_xwalk,
    arrow::read_parquet(p1_ungaged_catchments_xwalk_parquet) |>
      sf::st_drop_geometry() |>
      dplyr::select(hru_segment_v1_1, nhm_id)
  ),
  # Simplified ungaged catchments data
  tar_target(
    p2_ungaged_catchments_simp_shp,
    simplify_ungaged_data(
      ungaged_parquet = p1_ungaged_catchments_parquet,
      ungaged_crs = p0_ungaged_data_proj,
      tmp_dir = "2_process/tmp/ungaged_spatial",
      mapshaper_template = "mapshaper %s -simplify 16%% keep-shapes -clean gap-fill-area=5km2 -o %s"
    ),
    format = "file"
  ),
  # Info json on which ungaged units overlap each state and CONUS
  tar_target(
    p2_ungaged_info,
    munge_ungaged_state_info(
      ungaged_parquet = p1_ungaged_segments_parquet,
      ungaged_id_column = "nsegment_v1_1",
      ungaged_crs = p0_ungaged_data_proj,
      conus_states_sf = p1_conus_states_500k_sf
    )
  ),
  tar_target(
    p2_ungaged_info_json,
    {
      outfile_json = '2_process/out/ungaged_info.json'
      jsonlite::write_json(
        p2_ungaged_info,
        outfile_json,
        pretty = TRUE,
        auto_unbox = TRUE
      )
      return(outfile_json)
    },
    format = "file"
  ),
  
  ##### Key dates #####
  # Get start date for antecedent period
  tar_target(
    p2_antecedent_start_date,
    p1_issue_date - p0_antecedent_days
  ),
  tar_target(
    p2_plot_end_date,
    max(pull(p2_forecast_data, dt)) + p0_end_date_buffer_days
  ),
  tar_target(
    p2_plot_dates,
    seq(p2_antecedent_start_date, p2_plot_end_date, by = "day")
  ),
  tar_target(
    p2_timeseries_x_domain_csv,
    {
      outfile <- "2_process/out/timeseries_x_domain.csv"
      date_df <- tibble(
        start = p2_antecedent_start_date,
        end = p2_plot_end_date
      )
      readr::write_csv(date_df, outfile)
      return(outfile)
    },
    format = "file"
  ),
  ##### Process thresholds data #####
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
    compute_site_drought_record(
      site = p1_sites,
      streamflow_csv = p1_streamflow_csvs,
      thresholds_jd_csv = p2_jd_thresholds_csvs,
      streamflow_drought_csv = p2_streamflow_drought_csvs,
      antecedent_days = p0_antecedent_days,
      antecedent_start_date = p2_antecedent_start_date,
      issue_date = p1_issue_date,
      latest_streamflow_date = p2_latest_streamflow_date,
      replace_negative_flow_w_zero = p0_replace_negative_flow_w_zero,
      round_near_zero_to_zero = p0_round_near_zero_to_zero
    ),
    pattern = map(p1_sites, p1_streamflow_csvs, p2_jd_thresholds_csvs, p2_streamflow_drought_csvs)
  ),
  # the filename for the drought record CSV
  tar_target(
    p2_drought_records_csv_path,
    "2_process/out/drought_records.csv"
  ),
  # write drought record to CSV
  tar_target(
    p2_drought_records_csv,
    {
      out_dir <- dirname(p2_drought_records_csv_path)
      if (!dir.exists(out_dir)) dir.create(out_dir)
      write_csv(p2_drought_records, p2_drought_records_csv_path)
      p2_drought_records_csv_path
    },
    format = "file"
  ),

  ##### Process forecasts #####
  ###### LSTM <50 gaged forecasts ######
  tar_target(
    p2_forecast_data,
    munge_raw_forecast_data(
      forecast_feathers = p1_forecast_feathers,
      forecast_sites = p1_sites,
      id_column = "StaID",
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
    p2_date_info_csv,
    {
      outfile <- "2_process/out/date_info.csv"
      readr::write_csv(p2_date_info, outfile)
      return(outfile)
    },
    format = "file"
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
  # Geojsons w/ all forecasts
  # Requires system installation of mapshaper
  # https://github.com/mbloch/mapshaper?tab=readme-ov-file#installation
  tar_target(
    p2_gage_conditions_geojsons,
    generate_conditions_geojson(
      conditions_and_forecasts = p2_conditions_and_forecasts_grouped,
      gages_sf = p1_conus_gages_sf,
      cols_to_keep = NULL,
      precision = 0.0001,
      tmp_dir = "2_process/tmp",
      outfile_template = "2_process/out/conditions_geojsons/CONUS_data_w%s.geojson"
    ),
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
  
  ###### Ungaged forecasts and nowcasts ######
  tar_target(
    p2_ungaged_nhm_ids,
    p2_ungaged_catchments_id_xwalk |>
      dplyr::filter(hru_segment_v1_1 %in% p2_ungaged_polygon_ids) |>
      pull(nhm_id)
  ),
  tar_target(
    p2_ungaged_nowcast_forecast_data,
    munge_raw_forecast_data(
      forecast_feathers = c(p1_ungaged_nowcast_feather, 
                            p1_ungaged_forecast_feathers),
      # subset to forecast ids for which we have catchments, for now
      forecast_sites = p1_ungaged_ids[p1_ungaged_ids %in% p2_ungaged_nhm_ids],
      id_column = "nhm_id",
      replace_out_of_bound_predictions = p0_replace_out_of_bound_predictions
    )
  ),
  tar_target(
    p2_ungaged_nowcasts_and_forecasts,
    munge_nowcasts_and_forecasts(
      ungaged_nowcasts_forecasts = p2_ungaged_nowcast_forecast_data,
      poly_id_xwalk = p2_ungaged_catchments_id_xwalk
    )
  ),
  tarchetypes::tar_group_by(
    p2_ungaged_nowcasts_and_forecasts_grouped,
    p2_ungaged_nowcasts_and_forecasts |>
      group_by(f_w),
    f_w
  ),
  tar_target(
    p2_ungaged_conditions_data_csvs,
    {
      outfile <- sprintf("2_process/out/ungaged_conditions/ungaged_conditions_w%s.csv",
                         unique(p2_ungaged_nowcasts_and_forecasts_grouped[["f_w"]]))
      out_dir <- dirname(outfile)
      if (!dir.exists(out_dir)) dir.create(out_dir)
      p2_ungaged_nowcasts_and_forecasts_grouped |>
        select(u_id, pd) |>
        readr::write_csv(outfile)
      return(outfile)
    },
    pattern = map(p2_ungaged_nowcasts_and_forecasts_grouped),
    format = "file"
  ),
  # Geojson of simplified ungaged catchments data
  tar_target(
    p2_ungaged_catchments_geojson,
    generate_ungaged_geojson(
      ungaged_conditions_and_forecasts = p2_ungaged_nowcasts_and_forecasts, 
      ungaged_units_shp = p2_ungaged_catchments_simp_shp,
      shp_id_column = "hr__1_1", # ESRI Shapefile driver abbrev. of hru_segment_v1_1
      cols_to_keep = NULL,
      precision = 0.001,
      tmp_dir = "2_process/tmp",
      outfile = "2_process/out/CONUS_ungaged_catchment_data.geojson"
    ),
    format = "file"
  ),
  tar_target(
    p2_ungaged_percent_areas,
    compute_percent_areas_in_drought(
      ungaged_info = p2_ungaged_info,
      ungaged_nowcasts_forecasts = p2_ungaged_nowcasts_and_forecasts,
      ungaged_catchments_sf = p2_ungaged_catchments_sf
    ),
    pattern = map(p2_ungaged_info)
  ),
  tar_target(
    p2_ungaged_percent_areas_csv,
    {
      outfile = "2_process/out/ungaged_percent_areas.csv"
      p2_ungaged_percent_areas |>
        dplyr::mutate(across(where(is.numeric), ~replace_na(., 0))) |>
        readr::write_csv(outfile)
      return(outfile)
    },
    format = "file"
  ),
  
  ###### Light GBM gaged forecasts ######
  tar_target(
    p2_lgb_forecast_data,
    {
      lgb_forecast_data <- munge_raw_forecast_data(
        forecast_feather = p1_lgb_forecast_feather,
        forecast_sites = p1_sites,
        id_column = "StaID",
        replace_out_of_bound_predictions = p0_replace_out_of_bound_predictions
      ) |>
        mutate(parameter = case_when(
          parameter == "pred_interv_05.0" ~ "pred_interv_05",
          parameter == "pred_interv_95.0" ~ "pred_interv_95",
          TRUE ~ parameter
        )) |>
        dplyr::filter(issue_date == max(issue_date))

      if (!unique(lgb_forecast_data[["issue_date"]]) == p1_issue_date) {
        stop(message(sprintf('Light GBM issue date (%s) does not match the LSTM<50 issue date (%s)',
                             unique(lgb_forecast_data[["issue_date"]]),
                             p1_issue_date)))
      }

      return(lgb_forecast_data)
    }
  ),
  
  ###### Formatted forecasts for download ######
  tar_target(
    p2_forecast_parquet,
    format_forecast_data(
      issue_date = p1_issue_date,
      lstm_forecasts = p2_forecast_data,
      lgb_forecasts = p2_lgb_forecast_data,
      outfile_template = "2_process/out/USGS_streamflow_drought_forecasts_%s.parquet"
    ),
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
