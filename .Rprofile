
# use the global .Rprofile
source("~/.Rprofile")

if(interactive()) {
  # add an extra shim
  assign(
    x = "new_quarto_post",
    value = function(slug, date = as.character(lubridate::today())) {
      lines <- c(
        '---',
        paste0('title: "', slug, '"'),
        'description: "This is a subtitle"',
        paste0('date: "', date, '"'),
        '--- ',
        '',
        '<!--------------- my typical setup ----------------->',
        '',
        '```{r}',
        '#| label: setup',
        '#| include: false',
        'very_wide <- 500',
        'wide <- 136',
        'narrow <- 76',
        'options(width = narrow)',
        'cache_images <- TRUE',
        'set.seed(1)',
        '```',
        '',
        '<!--------------- post begins here ----------------->',
        ''
      )
      dir <- here::here("posts", paste0(date, "_", slug))
      fs::dir_create(dir)
      brio::write_lines(lines, fs::path(dir, "index.qmd"))
    },
    envir = as.environment("shims:danielle")
  )
}
