
library(tidyverse)
library(scoringRules)

source("R/read_forecast.R")

## Generic scoring function.
crps_score <- function(forecast, 
                       target,
                       grouping_variables = c("siteID", "time"),
                       target_variables = c("oxygen", 
                                            "temperature", 
                                            "richness",
                                            "abundance", 
                                            "nee",
                                            "le", 
                                            "vswc",
                                            "gcc_90"),
                       reps_col = c("ensemble")){
  
  
  ## drop extraneous columns && make grouping vars into chr ids (i.e. not dates)
  
  if("ensemble" %in% colnames(forecast)){ 
    reps_col <- "ensemble"
    variables <- c(grouping_variables, target_variables, reps_col)
  }else  if("statistic" %in% colnames(forecast)){ 
    reps_col <- "statistic"
    variables <- c(grouping_variables, target_variables, reps_col) 
  }
  
  forecast <- forecast %>% dplyr::select(any_of(variables))
  target <- target %>% select(any_of(variables))
  
  ## Teach crps to treat any NA observations as NA scores:
  scoring_fn_ensemble <- function(y, dat) {
    tryCatch(scoringRules::crps_sample(y, dat), error = function(e) NA_real_, finally = NA_real_)
  }
  
  scoring_fn_stat <- function(y, mean, sd) {
    tryCatch(scoringRules::crps_norm(y, mean = mean, sd = sd), error = function(e) NA_real_, finally = NA_real_)
  }
  
  ## Make tables into long format
  target_long <- target %>% 
    pivot_longer(any_of(target_variables), 
                 names_to = "target", 
                 values_to = "observed")
  forecast_long <- forecast %>% 
    pivot_longer(any_of(target_variables), 
                 names_to = "target", 
                 values_to = "predicted")
  
  if(reps_col == "ensemble"){
    
    inner_join(forecast_long, target_long, by = grouping_variables)  %>% 
      group_by(grouping_variables) %>% 
      summarise(score = scoring_fn_ensemble(observed[[1]], predicted),
                .groups = "drop")
    
  } else {
    
    forecast_long %>%
      pivot_wider(names_from = statistic, values_from = predicted) %>%
      inner_join(target_long, by = grouping_variables)  %>% 
      group_by(grouping_variables) %>% 
      summarise(score = scoring_fn_stat(observed[[1]], mean, sd),
                .groups = "drop")
    
  }
}


score_filenames <- function(forecast_files){
  f_name <- tools::file_path_sans_ext(paste0("scores-",
                                             basename(forecast_files)), compression = TRUE)
  file.path("scores", paste0(f_name, ".csv.gz"))
}


score_it <- function(targets_file, 
                     forecast_files, 
                     target_variables,
                     grouping_variables = c("time", "siteID"),
                     reps_col = c("ensemble"),
                     score_files = score_filenames(forecast_files)
){
  
  ## Read in data and compute scores!
  target <- read_forecast(targets_file)
  forecasts <- lapply(forecast_files, read_forecast)
  scores <- lapply(forecasts, 
                   crps_score, 
                   target = target,  
                   target_variables = target_variables, 
                   grouping_variables = grouping_variables,
                   reps_col = reps_col)
  
  ## write out score files
  purrr::walk2(scores, score_files, readr::write_csv)
  invisible(score_files)
}



