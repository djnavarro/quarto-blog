subtree <- function(parent, children = list()) {
  structure(
    list(parent = parent, children = children),
    class = "subtree"
  )
}

print.subtree <- function(x, ...) {
  if(length(x) == 0) {
    cat("<Empty parse_tree>\n")
  } else {
    print(x$parent)
    if(length(x$children) > 0) {
      for(child in x$children) {
        out <- capture.output(print(child))
        out <- paste("    ", out)
        cat(out, sep = "\n")
      }
    }
  }
  return(invisible(x))
}
