## readr way, via local copy of `scores` dir
scores_files <- fs::dir_ls("scores/", type="file", recurse = TRUE)
combined <- readr::read_csv(scores_files, progress = FALSE)

## Remote arrow:
library(arrow)
library(dplyr)
s <- neon4cast::score_schema()
s3 <- s3_bucket(bucket = "scores", endpoint_override = "data.ecoforecast.org")
ds <- open_dataset(s3, schema=s, format = "csv", skip_rows = 1)


## Test
bet <- ds %>% filter(theme == "beetles") %>% collect()


## Simpler format fails due to date vs datetime formatting of "time"
#ds <- open_dataset(s3, format = "csv")


