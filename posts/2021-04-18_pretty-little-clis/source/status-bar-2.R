
# mimic relevant part of .Rmd state ---------------------------------------

suppressPackageStartupMessages(library(cli))
wait <- function(seconds = 2) {Sys.sleep(seconds)}
cat("\n")


# code chunk --------------------------------------------------------------

message_inline <- function() {
  id <- cli_status("")
  cli_status_update(id, "You found my bracelet."); wait()
  cli_status_update(id, "Now come find me."); wait()
  cli_status_update(id, "Good luck bitches."); wait()
  cli_status_update(id, "-A"); wait()
  cli_status_clear(id)
}
message_inline()
