#remotes::install_deps()
library(aws.s3)
library(neon4cast)
library(magrittr)
library(future)


#source("R/score_it.R")
source("../neon4cast-shared-utilities/publish.R")
source("R/filter_forecasts.R")

fs::dir_create("forecasts")
fs::dir_create("targets")

Sys.setenv("AWS_DEFAULT_REGION" = "data",
           "AWS_S3_ENDPOINT" = "ecoforecast.org")

## Note: sync also requires auth credentials even to download from public bucket
message("Downloading forecasts ...")

sink(tempfile())

aws.s3::s3sync("forecasts", bucket= "forecasts",  direction= "download", verbose= FALSE)
aws.s3::s3sync("targets", "targets", direction= "download", verbose=FALSE)

sink()



## List the downloaded files
targets <- fs::dir_ls("targets", recurse = TRUE, type = "file")
forecasts <- fs::dir_ls("forecasts", recurse = TRUE, type = "file")




## Opt in to parallel execution (for score-it)
future::plan(future::multisession)
furrr::furrr_options(seed=TRUE)
options("mc.cores"=2)  # using too many cores with too little RAM wil crash



## aquatics
message("Aquatics ...")
targets_file <- filter_theme(targets, "aquatics")
forecast_files <- filter_theme(forecasts, "aquatics") %>%
  filter_prov( "scores/aquatics/prov.tsv", targets_file)

if(length(forecast_files) > 0){
        score_files <- neon4cast:::score_it(targets_file, forecast_files, dir = "scores/aquatics")

## Publish
publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "aquatics/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")
}

## beetles
message("Beetles ...")
targets_file <- filter_theme(targets, "beetles")
forecast_files <- filter_theme(forecasts, "beetles") %>%
        filter_prov("scores/beetles/prov.tsv", targets_file)

if(length(forecast_files) > 0){
  score_files <- neon4cast:::score_it(targets_file, forecast_files, dir = "scores/beetles") 

  publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "beetles/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")
}

## terrestrial
message("Terrestrial - daily interval ...")
targets_file <- filter_theme(targets, "terrestrial_daily")
forecast_files <- filter_theme(forecasts, "terrestrial_daily") %>%
        filter_prov("scores/terrestrial/prov.tsv", targets_file)

if(length(forecast_files) > 0){
        score_files <- neon4cast:::score_it(targets_file, forecast_files, dir = "scores/terrestrial")
                       

publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "terrestrial/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")
}

## terrestrial - 30 Minute
message("Terrestrial - 30 Min interval ...")

targets_file <- filter_theme(targets, "terrestrial_30min")
forecast_files <- filter_theme(forecasts, "terrestrial_30min") %>%
        filter_prov("scores/terrestrial/prov.tsv", targets_file)

if(length(forecast_files) > 0){
        score_files <- neon4cast:::score_it(targets_file, forecast_files, dir = "scores/terrestrial")

publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "terrestrial/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")
}

## phenology
message("Phenology...")
targets_file <- filter_theme(targets, "phenology")
forecast_files <- filter_theme(forecasts, "phenology") %>%
        filter_prov("scores/phenology/prov.tsv", targets_file)

if(length(forecast_files) > 0){
  score_files <- neon4cast:::score_it(targets_file, forecast_files,dir = "scores/phenology")

publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "phenology/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")
}


## ticks
message("Ticks...")
targets_file <- filter_theme(targets, "ticks")
forecast_files <- filter_theme(forecasts, "ticks") %>%
        filter_prov("scores/ticks/prov.tsv", targets_file)

if(length(forecast_files) > 0){
  score_files <- neon4cast:::score_it(targets_file, forecast_files, dir = "scores/ticks")

  publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "ticks/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")

}


