
subset_streamflow <- function(file, start_date, out_dir) {
  outfile <- file.path(out_dir, basename(file))
  readr::read_csv(file,
                  col_types = cols(StaID = "c")) |>
    select(StaID, dt, result = Flow_7d, pd = weibull_jd_30d_wndw_7d) |>
    filter(dt >= start_date) |>
    readr::write_csv(outfile)
  return(outfile)
}
