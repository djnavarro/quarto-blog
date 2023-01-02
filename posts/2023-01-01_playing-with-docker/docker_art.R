library(ggplot2)
library(tidyr)
library(tibble)
library(dplyr)

whale <- function(seed, box = TRUE, fancybox = TRUE) {

  set.seed(seed)

  circle <- tibble(
    th = seq(0, 2*pi, length.out = 1000),
    x = cos(th),
    y = sin(th)
  )

  body <- circle |>
    mutate(
      y = if_else(y > 0, 0, y),
      y = if_else(x < 0, -abs(y)^.6, -abs(y)^1.7)
    )

  tail <- circle |>
    mutate(
      w = (abs(th - pi)/pi) ^ 1.3,
      v = pi * 1.2,
      x = x * .6,
      y = y * .4,
      x_tmp = x * w + .35 * (1 - w),
      x = x_tmp * cos(v) - y * sin(v),
      y = x_tmp * sin(v) + y * cos(v),
      x = x + 1.35,
      y = y + .25
    )

  boxes <- expand_grid(
    x = seq(-.7, .5, .3),
    y = seq(.25, 1.5, .3)
  ) |>
    mutate(b = row_number())

  boxes <- boxes |> mutate(y = y - .32, x = x + .01)
  body <- body |> mutate(y = y - .3)
  tail <- tail |> mutate(y = y - .3)

  base_colour <- "black"

  if(fancybox) {
    boxes <- boxes |>
      group_by(x) |>
      mutate(h = runif(1, min(y) - .3, max(y) + .3)) |>
      filter(y < h)
  }

  pic <- ggplot(mapping = aes(x, y)) +
    geom_polygon(
      data = body,
      colour = base_colour,
      fill =  base_colour,
      linewidth = 5
    ) +
    geom_polygon(
      data = tail,
      colour = base_colour,
      fill = base_colour,
      linewidth = 1
    )

  if(box) pic <- pic +
    geom_tile(
      width = .2,
      height = .2,
      data = boxes,
      colour = base_colour,
      fill = base_colour,
      linewidth = 3,
      linejoin = "bevel"
    )

  pic <- pic +
    coord_equal(xlim = c(-1.5, 1.5), ylim = c(-1.5, 1.5)) +
    scale_x_continuous(labels = NULL, name = NULL) +
    scale_y_continuous(labels = NULL, name = NULL) +
    theme_void() +
    theme(axis.ticks = element_blank()) +
    NULL

  pic
}
