
subdivision <- function(seed) {

  library(ggplot2)
  library(tibble)
  library(purrr)
  library(dplyr)
  library(ggfx)

  sample_canva2 <- function(seed = NULL, n = 4) {
    if(!is.null(seed)) set.seed(seed)
    sample(ggthemes::canva_palettes, 1)[[1]] |>
      (\(x) colorRampPalette(x)(n))()
  }

  sample_canva3 <- function(seed = NULL, n = 4) {
    if(!is.null(seed)) set.seed(seed)
    max_pal <- max(colorir::colores$palette_index)
    pal_ind <- sample(max_pal, 1)
    shades <- colorir::colores$colour[colorir::colores$palette_index == pal_ind]
    shades |>
      (\(x) colorRampPalette(x)(n))()
  }

  sample_canva <- function(seed = NULL, n = 4) {
    if(runif(1) < .5) return(sample_canva2(seed, n))
    return(sample_canva3(seed, n))
  }

  choose_rectangle <- function(blocks) {
    sample(nrow(blocks), 1, prob = blocks$area)
  }

  choose_break <- function(lower, upper) {
    round((upper - lower) * runif(1))
  }

  create_rectangles <- function(left, right, bottom, top, value) {
    tibble(
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
    bind_rows(blocks[-old, ], new)
  }

  subdivision <- function(ncol = 1000,
                          nrow = 1000,
                          nsplits = 50,
                          seed = NULL) {

    if(!is.null(seed)) set.seed(seed)
    blocks <- create_rectangles(
      left = 1,
      right = ncol,
      bottom = 1,
      top = nrow,
      value = 0
    )
    reduce(1:nsplits, split_block, .init = blocks)
  }

  polygon_layer <- function(x, y, fill = "white", alpha = .5) {
    df <- data.frame(x = x, y = y)
    geom_polygon(mapping = aes(x, y), data = df, fill = fill,
                 alpha = alpha, inherit.aes = FALSE)
  }

  develop <- function(div, seed = NULL, linewidth = 3) {

    if(!is.null(seed)) set.seed(seed)

    ncol <- 1000
    nrow <- 1000
    poly <- list()
    base_x <- cos(seq(0, 2*pi, length.out = 7))
    base_y <- sin(seq(0, 2*pi, length.out = 7))

    for(i in 1:24) {

      radius <- rbeta(1, 1, 4)
      x_shift <- runif(1, min = -.3, max = 1.3)
      y_shift <- runif(1, min = -.3, max = 1.3)

      #ind <- sample(1:3, 1, prob = c(.6, .2, .2))
      #xval <- base_x * cos(rot[ind]) - base_y * sin(rot[ind])
      #yval <- base_x * sin(rot[ind]) + base_y * sin(rot[ind])

      xval <- base_x * radius + x_shift
      yval <- base_y * radius + y_shift

      poly[[i]] <- polygon_layer(x = xval * ncol, y = yval * nrow)
    }

    shades <- sample_canva(seed)
    clip <- 50

    div |>
      ggplot(aes(
        xmin = left,
        xmax = right,
        ymin = bottom,
        ymax = top,
        fill = value
      )) +
      as_group(
        poly[[1]], poly[[2]], poly[[3]], poly[[4]],
        poly[[5]], poly[[6]], poly[[7]], poly[[8]],
        poly[[9]], poly[[10]], poly[[11]], poly[[12]],
        poly[[13]], poly[[14]], poly[[15]], poly[[16]],
        poly[[17]], poly[[18]], poly[[19]], poly[[20]],
        #      poly[[21]], poly[[22]], poly[[23]], poly[[24]],
        id = "polygons"
      ) +
      as_reference(
        "polygons",
        id = "displacement_map"
      ) +
      with_displacement(
        geom_rect(
          colour = shades[1],
          linewidth = linewidth,
          show.legend = FALSE
        ),
        x_map = ch_alpha("displacement_map"),
        y_map = ch_alpha("displacement_map"),
        x_scale = 120,
        y_scale = -120
      ) +
      scale_fill_gradientn(
        colours = shades
      ) +
      coord_equal(
        xlim = c(clip, ncol-clip),
        ylim = c(clip, nrow-clip)
      ) +
      theme_void() +
      theme(panel.background = element_rect(
        fill = shades[1], colour = shades[1]
      ))
  }

  write_subdivision <- function(seed) {
    fname <- paste0("subdivision_11_", seed, ".png")
    post <- file.path("posts", "2022-12-04_first-time-callr")
    cat("generating", fname, "\n")
    subdivision(seed = seed, nsplits = 100) |>
      develop(linewidth = 0, seed = seed) |>
      ggsave(
        filename = here::here(post, "output", fname),
        plot = _,
        #bg = "white",
        dpi = 300,
        width = 2000/300,
        height = 2000/300
      )
    gc() # clear any magick resources
  }

  write_subdivision(seed)
}
