
library(asciicast)

make_asciicast <- function(name, rows) {

  blogroot <- rprojroot::find_root(".blogroot")
  folder <- fs::path(blogroot, "pretty-little-clis")
  script <- file.path(folder, "source", paste0(name, ".R"))
  output <- file.path(folder, "output", paste0(name, ".svg"))

  rec <- record(
    typing_speed = .001,
    empty_wait = 0,
    start_wait = 0,
    end_wait = 4,
    idle_time_limit = 10,
    timeout = 1000,
    script = script,
    echo = FALSE
  )

  write_svg(
    cast = rec,
    cursor = FALSE,
    path = output,
    rows = rows,
    cols = 80,
    window = TRUE,
    start_at = 0,
    end_at = 100,
    omit_last_line = FALSE
  )
}

make_asciicast("secrets", rows = 6)
make_asciicast("cat-example", rows = 4)
make_asciicast("cli-example-1", rows = 4)
make_asciicast("cli-example-2", rows = 4)
make_asciicast("status-bar-1", rows = 6)
make_asciicast("status-bar-2", rows = 3)
make_asciicast("spinner-1", rows = 3)
make_asciicast("spinner-2", rows = 3)
