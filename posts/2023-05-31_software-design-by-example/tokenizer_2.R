simple <- list(
  "*" = "Any",
  "|" = "Or",
  "(" = "GroupStart",
  ")" = "GroupEnd"
)

tokenize <- function(text) {
  result <- token_list()
  n <- 0
  for (i in 1:nchar(text)) {
    chr <- substr(text, start = i, stop = i)

    # simple cases are always added as non-literal tokens
    if (chr %in% names(simple)) {
      result[[n + 1]] <- token(simple[[chr]], i)
      n <- n + 1

    # the ^ character is non-literal if position is 1
    } else if (chr == "^" & i == 1) {
      result[[n + 1]] <- token("Start", i)
      n <- n + 1

    # the $ character is non-literal if it's the last character
    } else if (chr == "$" & i == nchar(text)) {
      result[[n + 1]] <- token("End", i)
      n <- n + 1

    # literals always create a new token
    } else {
      result[[n + 1]] <- token("Literal", i, value = chr)
      n <- n + 1
    }
  }
  return(result)
}
