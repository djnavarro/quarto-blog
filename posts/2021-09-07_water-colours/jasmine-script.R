

# set up ------------------------------------------------------------------


library(magrittr)
library(readr)
library(tidyr)
library(tibble)
library(stringr)
library(ggplot2)
library(purrr)
library(dplyr)

conflicted::conflict_prefer("extract", "tidyr")
conflicted::conflict_prefer("select", "dplyr")
conflicted::conflict_prefer("filter", "dplyr")



# helpers: importing the image --------------------------------------------


import_image <- function(path, width, height) {
  geometry <- paste0(width, "x", height) # e.g., "100x60"
  path %>%
    magick::image_read() %>%
    magick::image_scale(geometry)
}

construct_matrix <- function(image) {

  # read matrix
  mat <- image %>%
    as.raster() %>%
    as.matrix()

  # use the row and column names to represent co-ordinates
  rownames(mat) <- paste0("y", nrow(mat):1) # <- flip y
  colnames(mat) <- paste0("x", 1:ncol(mat))

  return(mat)
}

construct_tibble <- function(mat) {

  # convert to tibble
  tbl <- mat %>%
    as.data.frame() %>%
    rownames_to_column("y") %>%
    as_tibble()

  # reshape
  tbl <- tbl %>%
    pivot_longer(
      cols = starts_with("x"),
      names_to = "x",
      values_to = "shade"
    )

  # tidy
  tbl <- tbl %>%
    arrange(x, y) %>%
    mutate(
      x = x %>% str_remove_all("x") %>% as.numeric(),
      y = y %>% str_remove_all("y") %>% as.numeric(),
      id = row_number()
    )

  return(tbl)
}



# helpers: plot -----------------------------------------------------------


ggplot_themed <- function(data) {
  data %>%
    ggplot(aes(x, y)) +
    coord_equal() +
    scale_size_identity() +
    scale_colour_identity() +
    scale_fill_identity() +
    theme_void()
}



# helpers: channels -------------------------------------------------------


extract_channels <- function(tbl) {
  rgb <- with(tbl, col2rgb(shade))
  hsv <- rgb2hsv(rgb)
  tbl <- tbl %>%
    mutate(
      red = rgb[1, ],
      grn = rgb[2, ],
      blu = rgb[3, ],
      hue = hsv[1, ],
      sat = hsv[2, ],
      val = hsv[3, ]
    )
  return(tbl)
}



# helpers: flow fields ----------------------------------------------------


field <- function(points, frequency = .1, octaves = 1) {
  ambient::curl_noise(
    generator = ambient::fracture,
    fractal = ambient::billow,
    noise = ambient::gen_simplex,
    x = points$x,
    y = points$y,
    frequency = frequency,
    octaves = octaves,
    seed = 1
  )
}

shift <- function(points, amount, ...) {
  vectors <- field(points, ...)
  points <- points %>%
    mutate(
      x = x + vectors$x * amount,
      y = y + vectors$y * amount,
      time = time + 1,
      id = id
    )
  return(points)
}

iterate <- function(pts, time, step, ...) {
  bind_rows(accumulate(
    .x = rep(step, time),
    .f = shift,
    .init = pts,
    ...
  ))
}



# helpers: extract and merge ----------------------------------------------


extract_points <- function(data) {
  data %>%
    select(x, y, id) %>%
    mutate(time = 0)
}

restore_points <- function(jas, pts) {
  jas %>%
    select(-x, -y) %>%
    full_join(pts, by = "id") %>%
    arrange(time, id)
}




# top level commands ------------------------------------------------------

file <- fs::path(
  rprojroot::find_root("_site.yml"),
  "_posts",
  "2021-09-07_water-colours",
  "jasmines.jpg"
)

jas <- file %>%
  import_image(width = 200, height = 120) %>%
  construct_matrix() %>%
  construct_tibble() %>%
  extract_channels()

pts <- jas %>%
  extract_points() %>%
  iterate(
    time = 40,
    step = .2,
    octaves = 10,
    frequency = .05
  )

jas <- jas %>%
  restore_points(pts)

map_size <- function(x, y) {
  12 * (1 - x) * (max(y)^2 - y^2) / y^2
}

pic <- jas %>%
  ggplot_themed() +
  geom_point(
    mapping = aes(
      colour = shade,
      size = map_size(val, time)
    ),
    alpha = 1,
    stroke = 0,
    show.legend = FALSE
  )

pic <- pic +
  scale_x_continuous(limits = c(11, 190), expand = c(0, 0)) +
  scale_y_continuous(limits = c(7, 114), expand = c(0, 0))



