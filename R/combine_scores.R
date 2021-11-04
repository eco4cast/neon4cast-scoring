
scores_files <- fs::dir_ls("scores/", type="file", recurse = TRUE)
combined <- readr::read_csv(scores_files, progress = FALSE)


