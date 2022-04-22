

# packages you'll need ----------------------------------------------------

# It's very bad manners for a script to install something on someone
# else's computer without permission, so this script doesn't. But these
# are the packages you'll need, so you can uncomment these and run them
# if need be...

# install.packages("tidyverse")
# install.packages("gghighlight")

# packages to load --------------------------------------------------------

library(dplyr)
library(stringr)
library(ggplot2)

# constructing the download link ------------------------------------------

site <- "https://raw.githubusercontent.com"
user <- "rfordatascience"
repo <- "tidytuesday"
branch <- "master"
folder1 <- "data"
folder2 <- "2021"
folder3 <- "2021-09-14"
file <- "billboard.csv"

data_url <- paste(
  site, user, repo, branch, folder1,
  folder2, folder3, file, sep = "/"
)


# import the data ---------------------------------------------------------

billboard <- readr::read_csv(data_url)


# assemble the britney data -----------------------------------------------

britney <- billboard %>%
  filter(str_detect(performer, "^Britney")) %>%
  mutate(week_id = lubridate::mdy(week_id))


# a couple of plots -------------------------------------------------------

pic_1 <- britney %>%
  ggplot(aes(
    x = week_id,
    y = week_position,
    colour = song
  )) +
  geom_line() +
  geom_point() +
  scale_y_reverse() +
  gghighlight::gghighlight(song %in% highlights)


pic_2 <- britney %>%
  ggplot(aes(
    x = weeks_on_chart,
    y = week_position,
    group = song,
    colour = song
  )) +
  geom_line(size = 1.5) +
  scale_y_reverse() +
  scale_color_brewer(palette = "Dark2") +
  gghighlight::gghighlight(song %in% highlights,
                           unhighlighted_params = list(size = .5)) +
  theme_minimal() +
  labs(
    title = "Britney Spears' first hit was also her biggest",
    subtitle = "Chart performance of Britney Spears' songs",
    x = "Weeks in Billboard Top 100",
    y = "Chart Position"
  )

plot(pic_1)
plot(pic_2)




