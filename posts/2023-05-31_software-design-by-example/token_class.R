token <- function(kind, loc, value = NULL) {
  structure(
    list(kind = kind, loc = loc, value = value),
    class = "token"
  )
}

token_list <- function(...) {
  structure(
    list(...),
    class = "token_list"
  )
}

print.token <- function(x, ...) {
  cat("<Token at ",  x$loc, "> ", x$kind, sep = "")
  if(!is.null(x$value)) {
    cat(":", x$value)
  }
  cat("\n")
  return(invisible(x))
}

print.token_list <- function(x, ...) {
  if(length(x) == 0) {
    cat("<Empty token list>\n")
  } else {
    for(token in x) {
      print(token)
    }
  }
  return(invisible(x))
}
