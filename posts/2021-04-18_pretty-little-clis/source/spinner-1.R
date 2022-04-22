
# mimic relevant part of .Rmd state ---------------------------------------

suppressPackageStartupMessages(library(cli))
wait <- function(seconds = 2) {Sys.sleep(seconds)}
cat("\n")


# code chunk --------------------------------------------------------------

theatrics <- function(which) {
  spinny <- make_spinner(
    which = which,
    template = "{spin} It's not over until I say it is."
  )
  for(i in 1:100) {
    spinny$spin()
    wait(.05)
  }
  spinny$finish()
  cli_alert_success("Sleep tight while you still can, bitches. -A")
}

theatrics("dots2")
