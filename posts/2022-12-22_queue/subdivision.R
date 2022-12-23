
subdivision <- function(seed) {

  library(ggplot2)
  on.exit(gc()) # explicit gc() call to manage magick cache

  set.seed(seed)
  ncol <- 1000
  nrow <- 1000
  nsplits <- 100

  # sample a random palette
  sample_canva <- function(seed = NULL, n = 4) {
    if(!is.null(seed)) set.seed(seed)
    sample(ggthemes::canva_palettes, 1)[[1]] |>
      (\(x) colorRampPalette(x)(n))()
  }
  shades <- sample_canva(seed)

  # pick a random rectangle to subdivide
  choose_rectangle <- function(blocks) {
    sample(nrow(blocks), 1, prob = blocks$area)
  }

  # choose a location to break a line (discretized)
  choose_break <- function(lower, upper) {
    round((upper - lower) * runif(1))
  }

  # convenience function to create values with associated metadata
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

  # subdivide a rectangle horizontally
  split_rectangle_x <- function(rectangle, new_value) {
    with(rectangle, {
      split <- choose_break(left, right)
      new_left  <- c(left, left + split)
      new_right <- c(left + split, right)
      new_value <- c(value, new_value)
      create_rectangles(new_left, new_right, bottom, top, new_value)
    })
  }

  # subdivide a rectangle vertically
  split_rectangle_y <- function(rectangle, new_value) {
    with(rectangle, {
      split <- choose_break(bottom, top)
      new_bottom <- c(bottom, bottom + split)
      new_top <- c(bottom + split, top)
      new_value <- c(value, new_value)
      create_rectangles(left, right, new_bottom, new_top, new_value)
    })
  }

  # subdivide one rectangle
  split_rectangle <- function(rectangle, value) {
    if(runif(1) < .5) {
      return(split_rectangle_x(rectangle, value))
    }
    split_rectangle_y(rectangle, value)
  }

  # apply split_rectangle to the existing data set
  split_block <- function(blocks, value) {
    old <- choose_rectangle(blocks)
    new <- split_rectangle(blocks[old, ], value)
    dplyr::bind_rows(blocks[-old, ], new)
  }

  # create initial rectangle and subdivide
  blocks <- create_rectangles(1, ncol, 1, nrow, value = 0)
  div <- purrr::reduce(1:nsplits, split_block, .init = blocks)

  # helper function to define a polygon as a ggplot layer
  polygon_layer <- function(x, y, fill = "white", alpha = .5) {
    df <- data.frame(x = x, y = y)
    geom_polygon(mapping = aes(x, y), data = df, fill = fill,
                 alpha = alpha, inherit.aes = FALSE)
  }

  # coords for a hexagon
  x_hex <- cos(seq(0, 2*pi, length.out = 7))
  y_hex <- sin(seq(0, 2*pi, length.out = 7))

  # 20 random hexagons
  poly <- purrr::map(seq_len(20), function(x) {
    radius <- rbeta(1, 1, 4)
    polygon_layer(
      x = (x_hex * radius + runif(1, min = -.3, max = 1.3)) * ncol,
      y = (y_hex * radius + runif(1, min = -.3, max = 1.3)) * nrow
    )
  })

  # helper function to lift the domain of ggfx:as_group
  as_group_l <- purrr::lift_dl(ggfx::as_group)

  # plot the subdivided rectangles and use hexagons to define displacement filters
  pic <- div |>
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

  # file path
  output_dir <- here::here("posts", "2022-12-22_queue", "output")
  output_file <- paste0("subdivision_", seed, ".png")

  # render image
  ggsave(
    filename = file.path(output_dir, output_file),
    plot = pic,
    dpi = 300,
    width = 2000/300,
    height = 2000/300
  )
  return(output_file)
}
