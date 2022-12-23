donut <- function(seed,
                  filename = paste0("donut_", seed, ".png"),
                  width = 2000,
                  height = 2000,
                  dpi = 300,
                  units = "px",
                  ...) {

  sample_canva <- function(seed = NULL) {
    if(!is.null(seed)) set.seed(seed)
    sample(ggthemes::canva_palettes, 1)[[1]]
  }

  sample_data <- function(seed = NULL, n = 100){
    if(!is.null(seed)) set.seed(seed)
    dat <- tibble::tibble(
      x0 = stats::runif(n),
      y0 = stats::runif(n),
      x1 = x0 + stats::runif(n, min = -.2, max = .2),
      y1 = y0 + stats::runif(n, min = -.2, max = .2),
      shade = stats::runif(n),
      size = stats::runif(n),
      shape = factor(sample(0:22, size = n, replace = TRUE))
    )
  }

  donut_style <- function(data = NULL, palette) {
    ggplot2::ggplot(
      data = data,
      mapping = ggplot2::aes(
        x = x0,
        y = y0,
        xend = x1,
        yend = y1,
        colour = shade,
        linewidth = size
      )) +
      ggplot2::coord_polar(clip = "off") +
      ggplot2::scale_y_continuous(
        expand = c(0, 0),
        limits = c(-1, 1),
        oob = scales::oob_keep
      ) +
      ggplot2::scale_x_continuous(
        expand = c(0, 0),
        limits = c(0, 1),
        oob = scales::oob_keep
      ) +
      ggplot2::scale_colour_gradientn(colours = palette) +
      ggplot2::scale_linewidth(range = c(0, 4)) +
      ggplot2::theme_void() +
      ggplot2::theme(
        panel.background = ggplot2::element_rect(
          fill = palette[1], colour = palette[1]
        )
      ) +
      ggplot2::guides(
        colour = ggplot2::guide_none(),
        linewidth = ggplot2::guide_none(),
        fill = ggplot2::guide_none(),
        shape = ggplot2::guide_none()
      )
  }


  dat <- sample_data(n = 10000, seed = seed) |>
    dplyr::mutate(y1 = y0, size = size / 4)

  line_spec <- sample(c("331311", "11", "111115"), 1)

  pic <- donut_style(palette = sample_canva(seed = seed)) +
    ggplot2::geom_segment(data = dat, linetype = line_spec)

  if(stats::runif(1) < .5) {
    pic <- pic +
      ggplot2::geom_segment(
        data = dat |> dplyr::mutate(y1 = y1 - .2, y0 = y0 - .2),
        linetype = line_spec
      )
  }
  if(stats::runif(1) < .5) {
    pic <- pic +
      ggplot2::geom_segment(
        data = dat |> dplyr::mutate(y1 = y1 - .4, y0 = y0 - .4),
        linetype = line_spec
      )
  }

  ggplot2::ggsave(
    filename = filename,
    plot = pic,
    width = width,
    height = height,
    dpi = dpi,
    units = units,
    ...
  )

}
