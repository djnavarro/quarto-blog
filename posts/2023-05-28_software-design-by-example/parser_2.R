list_reverse <- function(x) {
  x[length(x):1]
}

update_tree <- function(tree, token) {

  # For some kinds of token, we simply append them to the tree
  if(token$kind %in% c("Literal", "Start", "End", "GroupStart")) {
    tree[[length(tree) + 1]] <- subtree(token)
  }

  # When GroupEnd is encountered, find the most recent GroupStart and
  # make the tokens between them the children of a Group
  if (token$kind == "GroupEnd") {
    children <- list()
    while(TRUE) {
      last <- tree[[length(tree)]]
      tree <- tree[-length(tree)]
      if(last$parent$kind == "GroupStart") {
        break
      }
      children[[length(children) + 1]] <- last
    }
    tree[[length(tree) + 1]] <- subtree(
      parent = token("Group", last$parent$loc),
      children = list_reverse(children)
    )
  }

  # When Any is encountered, make the preceding token (or subtree)
  # the child of the Any token
  if (token$kind == "Any") {
    last <- tree[[length(tree)]]
    tree[[length(tree)]] <- subtree(
      parent = token,
      children = list(last)
    )
  }

  # When Or is encountered, create a subtree with two children. The
  # first (or left) child is taken by moving it from the previous
  # token/subtree in our list. The second child is tagged as "Missing"
  # and will be filled in later
  if (token$kind == "Or") {
    last <- tree[[length(tree)]]
    tree[[length(tree)]] <- subtree(
      parent = token,
      children = list(last, subtree(token(kind = "Missing", loc = 0)))
    )
  }

  return(tree)
}

has_children <- function(x) {
  !is.null(x$children) && length(x$children) > 0
}

compress_or_skip <- function(tree, location) {
  if (has_children(tree[[location - 1]])) {
    n <- length(tree[[location - 1]]$children)
    if (tree[[location - 1]]$children[[n]]$parent$kind == "Missing") {
      tree[[location - 1]]$children[[n]] <- tree[[location]]
      tree[[location]] <- NULL
    }
  }
  return(tree)
}

compress_tree <- function(tree) {
  if (length(tree) <= 1) {
    return(tree)
  }

  # Compress branches of the top-level tree
  loc <- length(tree)
  while (loc > 1) {
    tree <- compress_or_skip(tree, loc)
    loc <- loc - 1
  }

  # Recursively compress branches of children subtrees
  for (loc in 1:length(tree)) {
    tree[[loc]]$children <- compress_tree(tree[[loc]]$children)
  }

  return(tree)
}

parse <- function(text) {
  tree <- list()
  tokens <- tokenize(text)
  for(token in tokens) {
    tree <- update_tree(tree, token)
  }
  tree <- compress_tree(tree)
  class(tree) <- "token_list" # allows pretty printing
  return(tree)
}

