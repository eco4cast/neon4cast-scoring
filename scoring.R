library(aws.s3)

source("R/score_it.R")
source("R/download_bucket.R")
source("R/publish.R")

## We'll read the files over the AWS API, though we could also read them directly from disk on the serve
dir.create("scores")
Sys.setenv("AWS_DEFAULT_REGION" = "data",
           "AWS_S3_ENDPOINT" = "ecoforecast.org")
targets <- download_bucket("targets")
forecasts <- download_bucket("forecasts")
submissions <- download_bucket("submissions")

submission_files <- submissions[grepl("aquatics-", submissions)]
submission_files <- submissions[grepl("beetles-", submissions)]
submission_files <- submissions[grepl("terrestrial-", submissions)]


## aquatics
targets_file <- targets[grepl("aquatics-targets", targets)]
forecast_files <- forecasts[grepl("aquatics-", forecasts)]
score_files <- score_it(targets_file, forecast_files,
         target_variables = c("oxygen", "temperature"))

## Publish
publish(code = c("scoring.R","R/score_it.R", "R/download_bucket.R"),
        data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "aquatics/",
        bucket = "scores")

## beetles
targets_file <- targets[grepl("beetles-", targets)]
forecast_files <- forecasts[grepl("beetles-", forecasts)]
score_files <- score_it(targets_file, forecast_files,
                       target_variables = c("richness", "abundance"))

publish(code = c("scoring.R","R/score_it.R", "R/download_bucket.R"),
        data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "beetles/",
        bucket = "scores")

## terrestrial
targets_file <- targets[grepl("terrestrial_daily-", targets)]
forecast_files <- forecasts[grepl("terrestrial_daily-", forecasts)]
score_files <- score_it(targets_file, forecast_files,
                        target_variables = c("nee", "lee", "vswc"))

publish(code = c("scoring.R","R/score_it.R", "R/download_bucket.R"),
        data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "terrestrial/",
        bucket = "scores")
