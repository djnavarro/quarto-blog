
# mimic relevant part of .Rmd state ---------------------------------------

cat("\n")


# code chunk --------------------------------------------------------------

wait <- function(seconds = 2) {Sys.sleep(seconds)}
send_cat_threat <- function() {
  cat("Dead girls walking.\n"); wait()
  cat("--A.\n")
}
send_cat_threat()
