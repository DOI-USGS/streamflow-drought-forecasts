push_files_to_s3 <- function(files, s3_bucket_name, s3_bucket_prefix, 
                             aws_region) {
  copy_df <- tibble(local_file = files) |>
    mutate(target = sub("^2_process/out/", "", files),
           target = c(sub(
             "^",
             paste0("s3://",
                    s3_bucket_name,
                    "/",
                    s3_bucket_prefix,
                    "/"),
             target))
    )
  
  for (i in seq_len(nrow(copy_df))) {
    cat(paste("s3 copying", 
              copy_df[i, ]$local_file, 
              "to", 
              copy_df[i, ]$target, "\n"))
    put_object(file = copy_df[i, ]$local_file,
               object = copy_df[i, ]$target,
               bucket = s3_bucket_name,
               region = aws_region,
               acl = "bucket-owner-full-control")
  }
}
