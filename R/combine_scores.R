get_scores <- function(files){
  teams_tmp <- (str_split(basename(files2), c("-")))
  score <- NULL
  for(i in 1:length(teams_tmp)){
    curr_score <- readr::read_csv(files2[i], col_types = list(id = readr::col_character(), score = readr::col_double()))
    if(nrow(curr_score) > 0){
      id <- str_split(curr_score$id, c("_"), simplify = TRUE)
      dates <- sort(lubridate::as_date(unique(id[,1])))
      time_step <- dates[2] - dates[1]
      first_date <- dates[1] - time_step
      combined <- tibble(date = lubridate::as_date(id[, 1]),
                         siteID = id[, 2],
                         target = id[, 3],
                         horizon = as.numeric(lubridate::as_date(id[, 1]) - first_date),
                         theme = teams_tmp[[i]][2],
                         team = tools::file_path_sans_ext(tools::file_path_sans_ext(last(teams_tmp[[i]]))),
                         score = curr_score$score,
                         forecast_start = first_date)
      score <- rbind(score, combined)
    }
  }
  return(score)
}