#remotes::install_deps()

library(aws.s3)
library(neon4cast)

#source("R/score_it.R")
source("R/download_bucket.R")
source("../neon4cast-shared-utilities/publish.R")

## We'll read the files over the AWS API, though we could als o read them directly from disk on the serve
dir.create("scores")
Sys.setenv("AWS_DEFAULT_REGION" = "data",
           "AWS_S3_ENDPOINT" = "ecoforecast.org")
targets <- download_bucket("targets")
forecasts <- download_bucket("forecasts")
submissions <- download_bucket("submissions")



## aquatics
targets_file <- targets[grepl("aquatics-targets", targets)]
forecast_files <- forecasts[grepl("aquatics-", forecasts)]
forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "xml")]
forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "not_in_standard")]
score_files <- neon4cast:::score_it(targets_file, forecast_files,
         target_variables = c("oxygen", "temperature"))

## Publish
publish(code = c("R/download_bucket.R"),
        data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "aquatics/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")


## beetles
targets_file <- targets[grepl("beetles-", targets)]
forecast_files <- forecasts[grepl("beetles-", forecasts)]
forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "xml")]
forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "not_in_standard")]
score_files <- neon4cast:::score_it(targets_file, forecast_files,
                       target_variables = c("richness", "abundance"),
                       )

publish(code = c("R/download_bucket.R"),
        data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "beetles/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")


## terrestrial
targets_file <- targets[grepl("terrestrial_daily-", targets)]
forecast_files <- forecasts[grepl("terrestrial_daily-", forecasts)]
forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "xml")]
forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "not_in_standard")]
score_files <- neon4cast:::score_it(targets_file, forecast_files,
                        target_variables = c("nee", "le", "vswc"))

publish(code = c("R/download_bucket.R"),
        data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "terrestrial/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")


## terrestrial
#targets_file <- targets[grepl("terrestrial_30min-", targets)]
#forecast_files <- forecasts[grepl("terrestrial_30min-", forecasts)]
#forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "xml")]
#forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "not_in_standard")]
#score_files <- neon4cast:::score_it(targets_file, forecast_files,
#                        target_variables = c("nee", "le", "vswc"))

#publish(code = c("R/download_bucket.R"),
#        data_in = c(targets_file, forecast_files),
#        data_out = score_files,
#        prefix = "terrestrial/",
#        bucket = "scores",
#        registries = "https://hash-archive.carlboettiger.info")


## phenology
targets_file <- targets[grepl("phenology-", targets)]
forecast_files <- forecasts[grepl("phenology-", forecasts)]
forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "xml")]
forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "not_in_standard")]
score_files <- neon4cast:::score_it(targets_file, forecast_files,
                        target_variables = c("gcc_90"))

publish(code = c("R/download_bucket.R"),
        data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "phenology/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")

## ticks
targets_file <- targets[grepl("ticks-", targets)]
forecast_files <- forecasts[grepl("ticks-", forecasts)]
forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "xml")]
forecast_files <- forecast_files[!stringr::str_detect(forecast_files, "not_in_standard")]
score_files <- neon4cast:::score_it(targets_file, forecast_files,
                        target_variables = c("ixodes_scapularis", "amblyomma_americanum"),
                        grouping_variables = c("time", "plotID", "siteID"))


publish(code = c("R/download_bucket.R"),
        data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "ticks/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")




