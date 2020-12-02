
library(tidyverse)
library(scoringRules)

## Generic scoring function.
crps_score <- function(forecast, target,
                       grouping_variables = c("siteID", "time"),
                       target_variables = c("richness", "abundance"),
                       reps_col = "ensemble"){
  
  ## drop extraneous columns && make grouping vars into chr ids (i.e. not dates)
  variables <- c(grouping_variables, target_variables, reps_col)
  
  forecast <- forecast %>% select(any_of(variables))
  target <- target %>% select(any_of(variables)) 
  
  ## Teach crps to treat any NA observations as NA scores:
  scoring_fn <- function(y, dat) {
    tryCatch(scoringRules::crps_sample(y, dat), error = function(e) NA_real_, finally = NA_real_)
  }
  
  ## Make tables into long format
  target_long <- target %>% 
    pivot_longer(any_of(target_variables), 
                 names_to = "target", 
                 values_to = "observed") %>%
    tidyr::unite("id", -all_of("observed"))
  
  forecast_long <- forecast %>% 
    pivot_longer(any_of(target_variables), 
                 names_to = "target", 
                 values_to = "predicted") %>%
    unite("id", -all_of(c(reps_col, "predicted")))
  
  
  ## Left-join will keep only the rows for which site,month,year of the target match the predicted
  inner_join(forecast_long, target_long, by = c("id"))  %>% 
    group_by(id) %>% 
    summarise(score = scoring_fn(observed[[1]], predicted),
              .groups = "drop")
  
}


score_it <- function(targets_file, 
                     forecast_files, 
                     target_variables,
                     grouping_variables = c("time", "siteID"),
                     reps_col = "ensemble",
                     score_files = file.path("scores", 
                                             paste0("scores-",
                                                    basename(forecast_files)))
){
  
  ## Read in data and compute scores!
  target <- read_csv(targets_file)
  forecasts <- lapply(forecast_files, read_csv, guess_max = 1e5)
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
