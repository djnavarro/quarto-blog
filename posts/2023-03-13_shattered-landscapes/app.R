library(shiny)

ui <- fluidPage(

  theme = bslib::bs_theme(
    version = 5,
    bg = "#F8F8FF",
    fg = "#000000",
    secondary = "#222222",
    base_font = bslib::font_google("Atkinson Hyperlegible")
  ),

  titlePanel("Shattered landscape generator"),

  sidebarLayout(

    sidebarPanel(

      numericInput(
        inputId = "seed",
        label = "Seed Value:",
        value = 1,
        min = 1,
        max = 1000000,
        step = 1
      ),

      colourpicker::colourInput(
        inputId = "background",
        label = "Background Colour",
        value = "#F8F8FF"
      ),

      colourpicker::colourInput(
        inputId = "texture1",
        label = "Texture Colour #1",
        value = "#177F97"
      ),

      colourpicker::colourInput(
        inputId = "texture2",
        label = "Texture Colour #2",
        value = "#B7F1B2"
      ),

      actionButton("generate", "Generate"),

      width = 3
    ),

    mainPanel(

      shinycssloaders::withSpinner(
        ui_element = plotOutput(
          outputId = "art",
          width = "calc(min(80vh, 60vw))",
          height = "calc(min(80vh, 60vw))"
        ),
        type = 8,
        color = "#000000"
      ),

      width = 9
    )
  )
)

server <- function(input, output) {

  new_grid <- function(n = 800) {
    ambient::long_grid(
      x = seq(0, 1, length.out = n),
      y = seq(0, 1, length.out = n)
    )
  }

  discretise <- function(x, n) {
    round(ambient::normalise(x) * n) / n
  }

  generate_curl <- function(x, y, seed = NULL) {
    if(!is.null(seed)) {
      set.seed(seed)
    }
    ambient::curl_noise(
      generator = ambient::fracture,
      noise = ambient::gen_simplex,
      fractal = ambient::fbm,
      octaves = 3,
      frequency = ~ . * 2,
      freq_init = .3,
      gain_init = 1,
      gain = ~ . * .5,
      x = x,
      y = y
    )
  }

  generate_simplex <- function(x, y, seed = NULL) {
    if(!is.null(seed)) {
      set.seed(seed)
    }
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

  generate_fancy_noise <- function(x, y, seed = NULL) {
    if(!is.null(seed)) {
      set.seed(seed)
    }
    z <- ambient::fracture(
      noise = ambient::gen_worley,
      fractal = ambient::billow,
      octaves = 8,
      freq_init = .1,
      frequency = ~ . * 2,
      gain_init = 3,
      gain = ~ . * .5,
      value = "distance2",
      x = x,
      y = y
    )
    a <- runif(1, -1, 1)
    b <- runif(1, -1, 1)
    ambient::fracture(
      noise = ambient::gen_simplex,
      fractal = ambient::billow,
      octaves = 10,
      freq_init = .02,
      frequency = ~ . * 2,
      gain_init = 1,
      gain = ~ . * .8,
      x = a * x + z,
      y = b * y + z
    )
  }

  generate_palette <- function(params) {
    set.seed(params$seed)
    gradient <- c(params$texture1, params$texture2)
    shades <- colorRampPalette(gradient)(50)
    shades <- sample(shades)
    shades[1] <- params$background
    shades
  }

  art_plot <- function(params) {

    shades <- generate_palette(params)

    grid <- new_grid()
    coords <- generate_curl(grid$x, grid$y, seed = params$seed)

    par(mar = c(0, 0, 0, 0))

    canvas <- grid |>
      dplyr::mutate(
        curl_x = coords$x |> discretise(50),
        curl_y = coords$y |> discretise(50),
        noise_curl = generate_fancy_noise(curl_x, curl_y, seed = params$seed),
        noise_base = generate_simplex(x, y, seed = params$seed),
        height = (noise_curl + noise_base) |> discretise(50),
        islands = dplyr::if_else(
          condition = height < median(height),
          true = median(height),
          false = height
        )
      ) |>
      as.array(value = islands) |>
      image(axes = FALSE, asp = 1, useRaster = TRUE, col = shades)
  }

  output$art <- renderPlot(art_plot(input)) |>
    bindEvent(input$generate)

}

shinyApp(ui = ui, server = server)
