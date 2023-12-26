Seed <- R6::R6Class("Seed",
  public = list(
    initialize = function(...) {
      old <- .Random.seed
      set.seed(...)
      self$state <- eval(.Random.seed, envir = .GlobalEnv)
      assign(".Random.seed", old, envir = .GlobalEnv)
    },
    state = NULL,
    use = function(expr, envir = parent.frame()) {
      old <- .Random.seed
      assign(".Random.seed", self$state, envir = .GlobalEnv)
      x <- eval(substitute(expr), envir = envir)
      self$state <- eval(.Random.seed, envir = .GlobalEnv)
      assign(".Random.seed", old, envir = .GlobalEnv)
      return(x)
    }
  )
)
