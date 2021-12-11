## readr way, via local copy of `scores` dir
scores_files <- fs::dir_ls("scores/", type="file", recurse = TRUE)
combined <- readr::read_csv(scores_files, progress = FALSE)

## Remote arrow:
library(arrow)
library(dplyr)
s <- neon4cast::score_schema()
s3 <- s3_bucket(bucket = "scores", endpoint_override = "data.ecoforecast.org")
ds <- open_dataset("scores", schema=s, format = "csv", skip_rows = 1)

## Simpler format fails due to date vs datetime formatting of "time"
#ds <- open_dataset(s3, format = "csv")

## Test
bet <- ds %>% filter(theme == "beetles") %>% collect()


