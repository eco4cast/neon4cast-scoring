
filter_theme <- function(x, theme) {
  x <- x[grepl(paste0(theme, "-"), x)]
  x <- x[!stringr::str_detect(x, "xml")]
  x <- x[!stringr::str_detect(x, "prov")]
  x <- x[!stringr::str_detect(x, "not_in_standard")]
  x
}
filter_prov <- function(x, prov_tsv, target){
  
  if(!file.exists(prov_tsv)) return(x)
  prov <- readr::read_tsv(prov_tsv, show_col_types = FALSE, lazy = FALSE)
  
  new_target <- !(contentid::content_id(target) %in% prov$id)
  if(new_target) return(x)
  
  
  ids <- contentid::content_id(x)
  keep <- !(ids %in% prov$id)
  x[keep]
}