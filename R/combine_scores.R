
scores_files <- fs::dir_ls("scores/", type="file", recurse = TRUE)
combined <- readr::read_csv(scores_files, progress = FALSE)



library(arrow)
library(dplyr)
s <- arrow::schema(
  theme = string(),
  team = string(),
  issue_date = date32(),
  siteID = string(),
  time = arrow::timestamp("s", timezone="UTC"),
  target = string(),
  mean = float64(),
  sd = float64(),
  observed = float64(),
  crps = float64(),
  logs = float64(),
  upper95 = float64(),
  lower95 = float64(),
  interval = int64(),
  forecast_start_time = timestamp("s", timezone="UTC"),
  horizon = float64()
)
ds <- open_dataset("scores", schema=s, format = "csv", skip_rows = 1)
## WHOOOPSIES, WHERE'S THE OBSERVATION DATA!
ds %>% filter(!is.na(observed)) %>% count(theme) %>% collect()

ds %>% filter(theme=="beetles", !is.na(mean)) %>% count(team) %>% collect()

