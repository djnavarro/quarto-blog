
subdivision <- function(seed) {

  library(ggplot2)
  on.exit(gc())

  set.seed(seed)
  ncol <- 1000
  nrow <- 1000
  nsplits <- 100

  sample_canva <- function(seed = NULL, n = 4) {
    if(!is.null(seed)) set.seed(seed)
    sample(ggthemes::canva_palettes, 1)[[1]] |>
      (\(x) colorRampPalette(x)(n))()
  }

  choose_rectangle <- function(blocks) {
    sample(nrow(blocks), 1, prob = blocks$area)
  }

  choose_break <- function(lower, upper) {
    round((upper - lower) * runif(1))
  }

  create_rectangles <- function(left, right, bottom, top, value) {
    tibble::tibble(
      left = left,
      right = right,
      bottom = bottom,
      top = top,
      width = right - left,
      height = top - bottom,
      area = width * height,
      value = value
    )
  }

  split_rectangle_x <- function(rectangle, new_value) {
    with(rectangle, {
      split <- choose_break(left, right)
      new_left  <- c(left, left + split)
      new_right <- c(left + split, right)
      new_value <- c(value, new_value)
      create_rectangles(new_left, new_right, bottom, top, new_value)
    })
  }

  split_rectangle_y <- function(rectangle, new_value) {
    with(rectangle, {
      split <- choose_break(bottom, top)
      new_bottom <- c(bottom, bottom + split)
      new_top <- c(bottom + split, top)
      new_value <- c(value, new_value)
      create_rectangles(left, right, new_bottom, new_top, new_value)
    })
  }

  split_rectangle <- function(rectangle, value) {
    if(runif(1) < .5) {
      return(split_rectangle_x(rectangle, value))
    }
    split_rectangle_y(rectangle, value)
  }

  split_block <- function(blocks, value) {
    old <- choose_rectangle(blocks)
    new <- split_rectangle(blocks[old, ], value)
    dplyr::bind_rows(blocks[-old, ], new)
  }

  blocks <- create_rectangles(1, ncol, 1, nrow, value = 0)
  div <- purrr::reduce(1:nsplits, split_block, .init = blocks)

  polygon_layer <- function(x, y, fill = "white", alpha = .5) {
    df <- data.frame(x = x, y = y)
    geom_polygon(mapping = aes(x, y), data = df, fill = fill,
                 alpha = alpha, inherit.aes = FALSE)
  }

  x_hex <- cos(seq(0, 2*pi, length.out = 7))
  y_hex <- sin(seq(0, 2*pi, length.out = 7))

  poly <- purrr::map(seq_len(20), function(x) {
    radius <- rbeta(1, 1, 4)
    polygon_layer(
      x = (x_hex * radius + runif(1, min = -.3, max = 1.3)) * ncol,
      y = (y_hex * radius + runif(1, min = -.3, max = 1.3)) * nrow
    )
  })

  shades <- sample_canva(seed)
  as_group_l <- purrr::lift_dl(ggfx::as_group)

  div |>
    ggplot(aes(xmin = left, xmax = right, ymin = bottom, ymax = top, fill = value)) +
    as_group_l(c(poly, id = "polygons")) +
    ggfx::as_reference("polygons", id = "displace") +
    ggfx::with_displacement(
      geom_rect(colour = shades[1], linewidth = 0, show.legend = FALSE),
      x_map = ggfx::ch_alpha("displace"),
      y_map = ggfx::ch_alpha("displace"),
      x_scale = 120,
      y_scale = -120
    ) +
    scale_fill_gradientn(colours = shades) +
    coord_equal(
      xlim = c(50, ncol - 50),
      ylim = c(50, nrow - 50)
    ) +
    theme_void() +
    theme(panel.background = element_rect(fill = shades[1], colour = shades[1]))
}
