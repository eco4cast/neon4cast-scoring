#remotes::install_deps()

library(aws.s3)
library(neon4cast)
library(magrittr)
#source("R/score_it.R")
source("../neon4cast-shared-utilities/publish.R")

dir.create("scores")
Sys.setenv("AWS_DEFAULT_REGION" = "data",
           "AWS_S3_ENDPOINT" = "ecoforecast.org")

## Note: sync also requires auth credentials even to download from public bucket
suppressMessages({
aws.s3::s3sync("forecasts", bucket= "forecasts",  direction= "download", verbose= FALSE)
aws.s3::s3sync("targets", "targets", direction= "download", FALSE)
})


## List the downloaded files
targets <- fs::dir_ls("targets", recurse = TRUE, type = "file")
forecasts <- fs::dir_ls("forecasts", recurse = TRUE, type = "file")


filter_theme <- function(x, theme) {
  x <- x[grepl(paste0(theme, "-"), x)]
  x <- x[!stringr::str_detect(x, "xml")]
  x <- x[!stringr::str_detect(x, "not_in_standard")]
  x
}
library(contentid)
filter_prov <- function(x, prov_tsv, target){
  
        if(!file.exists(prov_tsv)) return(x)
        prov <- read_tsv(prov_tsv)
        
        new_target <- !(content_id(target) %in% prov$id)
        if(new_target) return(x)
          
        
        ids <- content_id(x)
        keep <- !(ids %in% prov$id)
        x[keep]
}

## aquatics
targets_file <- filter_theme(targets, "aquatics")
forecast_files <- filter_theme(forecasts, "aquatics") %>%
  filter_prov( "scores/aquatics/prov.tsv", targets_file)

if(length(forecast_files) > 0){
        score_files <- neon4cast:::score_it(targets_file, forecast_files,
         target_variables = c("oxygen", "temperature"))

## Publish
publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "aquatics/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")
}

## beetles
targets_file <- filter_theme(targets, "beetles")
forecast_files <- filter_theme(forecasts, "beetles") %>%
        filter_prov("scores/beetles/prov.tsv", targets_file)

if(length(forecast_files) > 0){
  score_files <- neon4cast:::score_it(targets_file, forecast_files,
                       target_variables = c("richness", "abundance"),
                       )

  publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "beetles/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")
}

## terrestrial
targets_file <- filter_theme(targets, "terrestrial_daily")
forecast_files <- filter_theme(forecasts, "terrestrial_daily") %>%
        filter_prov("scores/terrestrial/prov.tsv", targets_file)

if(length(forecast_files) > 0){
        score_files <- neon4cast:::score_it(targets_file, forecast_files,
                        target_variables = c("nee", "le", "vswc"))

publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "terrestrial/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")
}

## terrestrial
targets_file <- filter_theme(targets, "terrestrial_30min")
forecast_files <- filter_theme(forecasts, "terrestrial_30min") %>%
        filter_prov("scores/terrestrial/prov.tsv", targets_file)

if(length(forecast_files) > 0){
        score_files <- neon4cast:::score_it(targets_file, forecast_files,
                        target_variables = c("nee", "le", "vswc"))

publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "terrestrial/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")
}

## phenology


targets_file <- filter_theme(targets, "phenology")
forecast_files <- filter_theme(forecasts, "phenology") %>%
        filter_prov("scores/phenology/prov.tsv", targets_file)

if(length(forecast_files) > 0){
        score_files <- neon4cast:::score_it(targets_file, forecast_files,
                        target_variables = c("gcc_90", "rcc_90"))

publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "phenology/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")
}


## ticks
targets_file <- filter_theme(targets, "ticks")
forecast_files <- filter_theme(forecasts, "ticks") %>%
        filter_prov("scores/ticks/prov.tsv", targets_file)

if(length(forecast_files) > 0){
  score_files <- neon4cast:::score_it(targets_file, forecast_files,
                        target_variables = c("ixodes_scapularis", "amblyomma_americanum"),
                        grouping_variables = c("time","siteID"))

  publish(data_in = c(targets_file, forecast_files),
        data_out = score_files,
        prefix = "ticks/",
        bucket = "scores",
        registries = "https://hash-archive.carlboettiger.info")

}


