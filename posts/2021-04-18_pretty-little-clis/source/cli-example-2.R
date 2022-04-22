
# mimic relevant part of .Rmd state ---------------------------------------

suppressPackageStartupMessages(library(cli))
wait <- function(seconds = 2) {Sys.sleep(seconds)}
cat("\n")

# code chunk --------------------------------------------------------------

send_cli_warning <- function() {
  cli_alert_warning("Dead girls walking."); wait()
  cli_alert_warning("--A.")
}
send_cli_warning()
