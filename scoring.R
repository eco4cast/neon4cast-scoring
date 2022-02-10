# remotes::install_deps()
library(aws.s3)
library(neon4cast)
library(magrittr)
library(future)


## Heper utility:
source("R/filter_forecasts.R")
source("R/monthly_targets.R")


## A place to store everything
fs::dir_create("forecasts")
fs::dir_create("targets")
fs::dir_create("prov")
Sys.setenv("AWS_DEFAULT_REGION" = "data",
           "AWS_S3_ENDPOINT" = "ecoforecast.org")

message("Downloading forecasts ...")

## Note: s3sync stupidly also requires auth credentials even to download from public bucket



sink(tempfile()) # aws.s3 is crazy chatty and ignores suppressMessages()...
aws.s3::s3sync("forecasts", bucket= "forecasts",  direction= "download", verbose= FALSE)
aws.s3::s3sync("targets", "targets", direction= "download", verbose=FALSE)
aws.s3::s3sync("prov", bucket= "prov",  direction= "download", verbose= FALSE)

sink()

## List all the downloaded files
targets <- fs::dir_ls("targets", recurse = TRUE, type = "file")
forecasts <- fs::dir_ls("forecasts", recurse = TRUE, type = "file")



## Opt in to parallel execution (for score-it)
future::plan(future::multisession)
furrr::furrr_options(seed=TRUE)
options("mc.cores"=2)  # using too many cores with too little RAM wil crash


## aquatics
message("Aquatics ...")
targets_file <- filter_theme(targets, "aquatics")
targets_files <- monthly_targets(targets_file)
forecast_files <- filter_theme(forecasts, "aquatics")
matched_targets <- lapply(forecast_files, match_targets, targets_file= targets_file)

forecast_files <- forecast_files %>%
  filter_prov( "prov/scores-prov.tsv", targets_file)

if(length(forecast_files) > 0){
  score_files <- neon4cast:::score_it(targets_file, forecast_files, dir = "scores/")
  prov::write_prov_tsv(data_in = c(targets_file, forecast_files),  data_out = score_files, provdb =  "prov/scores-prov.tsv")
}


## beetles
message("Beetles ...")
#targets_file <- filter_theme(targets, "beetles")
#targets_files <- monthly_targets(targets_file)
#forecast_files <- filter_theme(forecasts, "beetles") %>%
#  filter_prov("prov/scores-prov.tsv", targets_file)

#if(length(forecast_files) > 0){
#  score_files <- neon4cast:::score_it(targets_file, forecast_files, dir = "scores/") 
#  prov::write_prov_tsv(data_in = c(targets_file, forecast_files),  data_out = score_files, provdb = "prov/scores-prov.tsv")
#}


## terrestrial
message("Terrestrial - daily interval ...")
targets_file <- filter_theme(targets, "terrestrial_daily")
targets_files <- monthly_targets(targets_file)
forecast_files <- filter_theme(forecasts, "terrestrial_daily") %>%
  filter_prov("prov/scores-prov.tsv", targets_file)

if(length(forecast_files) > 0){
  score_files <- neon4cast:::score_it(targets_file, forecast_files, dir = "scores/")
  prov::write_prov_tsv(data_in = c(targets_file, forecast_files),  data_out = score_files, provdb = "prov/scores-prov.tsv")
}


## terrestrial - 30 Minute
message("Terrestrial - 30 Min interval ...")

targets_file <- filter_theme(targets, "terrestrial_30min")
targets_files <- monthly_targets(targets_file)
forecast_files <- filter_theme(forecasts, "terrestrial_30min") %>%
  filter_prov("prov/scores-prov.tsv", targets_file)

if(length(forecast_files) > 0){
  score_files <- neon4cast:::score_it(targets_file, forecast_files, dir = "scores/")
  prov::write_prov_tsv(data_in = c(targets_file, forecast_files),  data_out = score_files, provdb = "prov/scores-prov.tsv")
}


## phenology
message("Phenology...")
targets_file <- filter_theme(targets, "phenology")
targets_files <- monthly_targets(targets_file)
forecast_files <- filter_theme(forecasts, "phenology")
matched_targets <- lapply(forecast_files, match_targets, targets_file= targets_file)
if(length(forecast_files) > 0){
  score_files <- neon4cast:::score_it(targets_file, forecast_files, dir = "scores/")
  prov::write_prov_tsv(data_in = c(targets_file, forecast_files),  data_out = score_files, provdb = "prov/scores-prov.tsv")
}


## ticks
message("Ticks...")
targets_file <- filter_theme(targets, "ticks")
targets_files <- monthly_targets(targets_file)
forecast_files <- filter_theme(forecasts, "ticks") %>%
  filter_prov("prov/scores-ticks-prov.tsv", targets_file)

if(length(forecast_files) > 0){
  score_files <- neon4cast:::score_it(targets_file, forecast_files, dir = "scores/")
  prov::write_prov_tsv(data_in = c(targets_file, forecast_files),  data_out = score_files, provdb = "prov/scores-prov.tsv")
}


################### EFI-USE ONLY -- Requires secure credentials to upload data to EFI SERVER  #######################

message("Uploading scores to EFI server...")
sink(tempfile())  # aws.s3 is crazy chatty and ignores suppressMessages()..


aws.s3::s3sync("scores", "scores", direction= "upload", verbose=FALSE)
aws.s3::s3sync("prov", bucket= "prov",  direction= "upload", verbose= FALSE)


sink()
