
# mimic relevant part of .Rmd state ---------------------------------------

suppressPackageStartupMessages(library(cli))
wait <- function(seconds = 2) {Sys.sleep(seconds)}
cat("\n")


# code chunk --------------------------------------------------------------

message_scroll <- function() {
  cli_text("You found my bracelet."); wait()
  cli_text("Now come find me."); wait()
  cli_text("Good luck bitches."); wait()
  cli_text("-A"); wait()
}
message_scroll()
