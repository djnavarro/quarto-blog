library(ggplot2)
library(tidyr)
library(tibble)
library(dplyr)

sample_whales <- function(seed = NULL, nrow = 4, ncol = 6) {

  if(is.null(seed)) seed <- sample(1000, 1)
  set.seed(seed)

  nwhales <- nrow * ncol

  # define a circle
  circle <- tibble(
    th = seq(0, 2*pi, length.out = 1000),
    x = cos(th),
    y = sin(th)
  )

  # distort a circle to create the whale body
  whale_body <- circle |>
    mutate(
      y = if_else(y > 0, 0, y),
      y = if_else(x < 0, -abs(y) ^ .6, -abs(y) ^ 1.7),
      part = "body"
    )

  # distort a circle to create the whale tail
  whale_tail <- circle |>
    mutate(
      weight = (abs(th - pi)/pi) ^ 1.3,
      angle = pi * 1.2,
      x = x * weight + .35 * (1 - weight),
      x_scaled = x * .6,
      y_scaled = y * .4,
      x = x_scaled * cos(angle) - y_scaled * sin(angle),
      y = x_scaled * sin(angle) + y_scaled * cos(angle),
      x = x + 1.35,
      y = y + 0.25,
      part = "tail"
    )

  # bind the body to the tail to make a whale
  whale <- bind_rows(whale_body, whale_tail)

  # fully stacked set of boxes
  box_stack <- expand_grid(
    x = seq(-.7, .5, .3),
    y = seq(.25, 1.5, .3)
  )

  # sample names using babynames package
  names <- unique(sample(
    x = babynames::babynames$name,
    size = ceiling(nwhales * 1.2)
  ))

  # sample colours using a blue palette from ggthemes
  shades <- sample(
    x = ggthemes::canva_palettes$`Cool blues`,
    size = nrow * ncol,
    replace = TRUE
  )

  boxes <- list()
  whales <- list()
  for(i in 1:(nrow * ncol)) {

    # assign the whales a name and a look
    whales[[i]] <- whale |>
      mutate(
        name = names[[i]],
        look = shades[[i]]
      )

    # assign the whales a name and colour,
    # and randomly remove boxes off the stack
    boxes[[i]] <- box_stack |>
      mutate(
        name = names[[i]],
        look = shades[[i]]
      ) |>
      group_by(x) |>
      mutate(max_height = runif(1, min = .05, max = 1.8)) |>
      filter(y < max_height)
  }

  # collapse lists to data frames
  boxes <- bind_rows(boxes)
  whales <- bind_rows(whales)

  # last minute tinkering... :-)
  boxes <- boxes |> mutate(y = y - .3, x = x + .01)
  whales <- whales |> mutate(y = y - .31)

  # draw the plot
  ggplot(mapping = aes(x, y, fill = look, colour = look)) +
    geom_polygon(
      data = whales,
      mapping = aes(group = part),
      linewidth = 2
    ) +
    geom_tile(
      data = boxes,
      width = .18,
      height = .18,
      linewidth = 2,
      linejoin = "bevel"
    ) +
    facet_wrap(vars(name), nrow = nrow, ncol = ncol) +
    coord_equal(xlim = c(-1.5, 1.5), ylim = c(-1.5, 1.5)) +
    scale_x_continuous(labels = NULL, name = NULL) +
    scale_y_continuous(labels = NULL, name = NULL) +
    scale_fill_identity() +
    scale_color_identity() +
    theme_minimal(base_size = 14) +
    theme(
      axis.ticks = element_blank(),
      panel.border = element_rect(fill = NA, colour = "grey90")
    )
}

