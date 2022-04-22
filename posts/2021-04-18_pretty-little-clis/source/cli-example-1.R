
# mimic relevant part of .Rmd state ---------------------------------------

suppressPackageStartupMessages(library(cli))
wait <- function(seconds = 2) {Sys.sleep(seconds)}
cat("\n")

# code chunk --------------------------------------------------------------

send_cli_threat <- function() {
  cli_text("Dead girls walking."); wait()
  cli_text("--A.")
}
send_cli_threat()
