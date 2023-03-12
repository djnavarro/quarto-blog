
new_grid <- function(n = 500) {
  ambient::long_grid(
    x = seq(0, 1, length.out = n),
    y = seq(0, 1, length.out = n)
  )
}

generate_simplex <- function(x, y) {
  ambient::fracture(
    noise = ambient::gen_simplex,
    fractal = ambient::billow,
    octaves = 10,
    freq_init = .02,
    frequency = ~ . * 2,
    gain_init = 1,
    gain = ~ . * .8,
    x = x,
    y = y
  )
}

render <- function(mat, shades = NULL) {
  if(is.null(shades)) {
    shades <- hcl.colors(12, "YlOrRd", rev = TRUE)
  }
  rayshader::height_shade(
    heightmap = mat,
    texture = shades
  ) |>
    rayshader::add_shadow(
      shadowmap = rayshader::ray_shade(
        heightmap = mat,
        sunaltitude = 50,
        sunangle = 80,
        multicore = TRUE,
        zscale = .005
      ),
      max_darken = .2
    ) |>
    rayshader::plot_map()
}

set.seed(8)
new_grid() |>
  dplyr::mutate(
    height = generate_simplex(x, y),
    islands = dplyr::if_else(
      condition = height < median(height),
      true = median(height),
      false = height
    )
  ) |>
  as.array(value = islands) |>
  render()
