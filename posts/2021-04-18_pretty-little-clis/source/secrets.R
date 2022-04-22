
# mimic relevant part of .Rmd state ---------------------------------------

suppressPackageStartupMessages(library(cli))
wait <- function(seconds = 2) {Sys.sleep(seconds)}

# code chunk --------------------------------------------------------------

title_theme_scroll <- function() {
  cli_text("Got a secret, can you keep it?"); wait()
  cli_text("Swear this one you'll save"); wait()
  cli_text("Better lock it in your pocket"); wait()
  cli_text("Taking this one to the grave"); wait()
  cli_text("If I show you then I know you won't tell what I said"); wait()
  cli_text("Cause two can keep a secret if one of them is dead"); wait()
}
title_theme_scroll()
