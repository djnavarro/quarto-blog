library(httr)
library(XML)
library(tibble)
library(purrr)
library(dplyr)
library(stringr)

url <- "https://en.wikipedia.org/wiki/List_of_The_Magicians_(American_TV_series)_episodes#Season_1_(2015%E2%80%9316)"
raw <- GET(url)

doc <- readHTMLTable(content(raw, "text"))
doc <- lapply(doc, as_tibble)

# 8:12 have episode numbers, titles etc
# 2:6 is the weird interleaved
core <- map_dfr(doc[8:12], ~ .x)
names(core) <- unclass(unlist(core[1,]))

magicians <- core %>%
  janitor::clean_names() %>%
  filter(no != "No.") %>%
  transmute(
    season = ceiling(row_number()/13),
    episode = as.numeric(no),
    title = title %>%
      str_remove_all('^"') %>%
      str_remove_all('"$'),
    air_date = lubridate::mdy(air_date),
    rating = as.numeric(rating_18_49),
    viewers = viewers_millions %>%
      str_remove_all("\\[.*\\]$") %>%
      as.numeric()
  )

readr::write_csv(magicians, here::here("_posts/2022-01-18_binding-arrow-to-r/magicians.csv"))

