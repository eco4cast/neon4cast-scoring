monthly_targets <- function(target_file){
  targets <- readr::read_csv(target_file, guess_max = Inf)
  
  targets_month_year <- targets %>% 
   dplyr::mutate(month = lubridate::month(time),
           year = lubridate::year(time)) %>% 
    dplyr::select(month, year) %>% 
    dplyr::distinct()
  
  file_names <- rep(NA, length(nrow(targets_month_year)))
  
  for(i in 1:nrow(targets_month_year)){
    month_file <- targets %>% 
      dplyr::filter(lubridate::month(time) == targets_month_year$month[i],
             lubridate::year(time) == targets_month_year$year[i])
    
    month <- targets_month_year$month[i] 
    if(targets_month_year$month[i] < 10){
      month <- paste0("0", month)
    }
    
    output <- paste0(targets_month_year$year[i], "-", month, "-", basename(target_file))
    
    theme <- unlist(stringr::str_split_fixed(basename(target_file),"-",2 ))[1]
    
    readr::write_csv(month_file, file.path("targets", theme, "monthly", output))
    
    #aws.s3::s3write_using(FUN = readr::write_csv,
    #                      x = month_file,
    #                      object = file.path(theme, "monthly", output),
    #                      bucket = "targets",
    #                      opts = list(
    #                        base_url = "ecoforecast.org",
    #                        region = "data"))
    
    file_names[i] <- file.path("targets", theme, "monthly", output)
  }
  invisible(file_names)
}