list_reverse <- function(x) {
  x[length(x):1]
}

handle <- function(result, token) {

  # create a subtree with no child nodes
  if(token$kind %in% c("Literal", "Start", "End", "GroupStart")) {
    result[[length(result) + 1]] <- subtree(token)
  }

  # when end group is encountered, find corresponding start group and
  # create a subtree with parent of kind group with the appropriate children
  if (token$kind == "GroupEnd") {
    children <- list()
    while(TRUE) {
      last <- result[[length(result)]]
      result <- result[-length(result)]
      if(last$parent$kind == "GroupStart") {
        break
      }
      children[[length(children) + 1]] <- last
    }
    result[[length(result) + 1]] <- subtree(
      parent = token("Group", last$parent$loc),
      children = list_reverse(children)
    )
  }

  # when an any token is encountered, create a subtree with the any token
  # as the parent, and the preceding subtree as the child
  if (token$kind == "Any") {
    last <- result[[length(result)]]
    result[[length(result)]] <- subtree(
      parent = token,
      children = list(last)
    )
  }

  # when an or token is encountered, create a subtree with the or token
  # as the parent, and two children: one from the preceding subtree, and
  # one "missing" token that will be filled later
  if (token$kind == "Or") {
    last <- result[[length(result)]]
    result[[length(result)]] <- subtree(
      parent = token,
      children = list(last, subtree(token(kind = "Missing", loc = 0)))
    )
  }

  return(result)
}

parse <- function(text) {
  result <- token_list()
  tokens <- tokenize(text)
  for(i in 1:length(tokens)) {
    token <- tokens[[i]]
    result <- handle(result, token)
  }
  class(result) <- "token_list"
  return(result)
}

