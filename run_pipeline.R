library(targets)

# Run the pipeline
cat("** Running the targets pipeline\n")
cat(paste0("** RUNNING_ON_AWS_ECS is ", Sys.getenv("RUNNING_ON_AWS_ECS"), "\n")))
targets::tar_make()
