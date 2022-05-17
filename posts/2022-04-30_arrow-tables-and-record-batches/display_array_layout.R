library(arrow)
library(cli)

array_layout <- function(x) {
  d <- x$data()
  class(d) <- c("PrettyArrayData", class(d))
  return(d)
}

parse_validity_buffer <- function(buffer, array_length) {
  if(is.null(buffer)) {
    return("null")
  }
  bits <- rawToBits(buffer$data())[1:array_length]
  str <- bits |> as.numeric() |> paste0(collapse = " ")
  return(str)
}

parse_string_buffer <- function(buffer) {
  str <- rawToChar(buffer$data())
  return(str)
}

parse_offset_buffer <- function(buffer, array_length) {
  offsets <- buffer$data() |>
    readBin(what = "integer", n = array_length + 1)
  str <- paste(offsets, collapse = " ")
  return(str)
}

parse_integer_buffer <- function(buffer, array_length) {
  offsets <- buffer$data() |>
    readBin(what = "integer", n = array_length)
  str <- paste(offsets, collapse = " ")
  return(str)
}


print.PrettyArrayData <- function(x, ...) {

  supported <- c("string", "int32")

  if(!(x$type$ToString() %in% supported)) {
    NextMethod()
  }

  # determine contents of buffers
  if(x$type$ToString() == "string") {
    buffers <- c(
      paste0("validity : ", parse_validity_buffer(x$buffers[[1]], x$length)),
      paste0("offset : ", parse_offset_buffer(x$buffers[[2]], x$length)),
      paste0("data : ", parse_string_buffer(x$buffers[[3]]))
    )
  }
  if(x$type$ToString() == "int32") {
    buffers <- c(
      paste0("validity : ", parse_validity_buffer(x$buffers[[1]], x$length)),
      paste0("data : ", parse_integer_buffer(x$buffers[[2]], x$length))
    )
  }

  # display message to user
  cli({
    cli_h3("Metadata")
    cli_ul(c(
      paste0("length : ", x$length),
      paste0("null count : ", x$null_count)
    ))
    cli_h3("Buffers")
    cli_ul(buffers)
    cli_text("")
  })
}


