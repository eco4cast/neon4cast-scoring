

read_forecast <- function(file_in, 
                          grouping_variables = c("siteID", "time"),
                          target_variables = c("oxygen", 
                                               "temperature", 
                                               "richness",
                                               "abundance", 
                                               "nee",
                                               "le", 
                                               "vswc",
                                               "gcc_90"),
                          reps_col = "ensemble",
                          ...){
  

    
    if(any(vapply(c("[.]csv", "[.]csv\\.gz"), grepl, logical(1), file_in))){  
      # if file is csv zip file
      out <- read_csv(file_in, guess_max = 1e6, ...)
      
    } else if(grepl("[.]nc", file_in)){ #if file is nc
      
      nc <- ncdf4::nc_open(file_in)
      siteID <- ncdf4::ncvar_get(nc, "siteID")
      time <- ncdf4::ncvar_get(nc, "time")
      tustr<-strsplit(ncdf4::ncatt_get(nc, varid = "time", "units")$value, " ")
      time <-lubridate::as_date(time,origin=unlist(tustr)[3])
      

      targets <- names(nc$var)[which(names(nc$var) %in% target_variables)]
      combined_forecast <- NULL
      for(j in 1:length(targets)){
        forecast_targets <- ncdf4::ncvar_get(nc, targets[j])
        for(i in 1:length(siteID)){
          tmp <- forecast_targets[ ,i ,]
          d <- cbind(time, as.data.frame(tmp))
          names(d) <- c("time", seq(1,dim(tmp)[2]))
          d <- d %>%
            tidyr::pivot_longer(-time, names_to = reps_col, values_to = "value") %>%
            dplyr::mutate(siteID = siteID[i],
                          variable = targets[j])
          combined_forecast <- rbind(combined_forecast, d)
        }
      }
      ncdf4::nc_close(nc)
      combined_forecast <- combined_forecast %>%
        tidyr::pivot_wider(names_from = variable, values_from = value)
      
      out <- combined_forecast
    }
  
  out
}