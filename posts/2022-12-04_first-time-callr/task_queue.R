# adapted from: https://www.tidyverse.org/blog/2019/09/callr-task-q/

Task <- R6::R6Class(
  classname = "Task",
  public = list(
    initialize = function(fun, args = list(), id = NULL) {
      self$fun = fun
      self$args = args
      self$id = id
    },
    fun = NULL,
    args = NULL,
    results = NULL,
    id = NULL,
    state = "waiting"
  )
)

Worker <- R6::R6Class(
  classname = "Worker",
  public = list(
    initialize = function() {
      self$session <- callr::r_session$new(wait = FALSE)
      self$session$initialize()
      self$id <- self$session$get_pid()
    },
    task = NULL,
    session = NULL,
    id = NULL,
    try_start = function() {
      if(!is.null(self$task) && self$task$state == "waiting") {
        self$session$call(self$task$fun, self$task$args)
        self$task$state <- "running"
      }
    },
    try_assign = function(task) {
      if(is.null(self$task)) {
        self$task <- task
        self$task$state <- "waiting"
      }
    },
    try_finish = function(timeout = 0) {
      if(!is.null(self$task) && self$task$state == "running") {
        if(self$session$poll_process(timeout) == "ready") {
          self$task$results <- self$session$read()
          self$task$state <- "done"
          self$task <- NULL
        }
      }
    }
  ),
  active = list(
    state = function() self$session$get_state()
  )
)

Queue <- R6::R6Class(
  classname = "Queue",
  public = list(
    workers = list(),
    tasks = list(),
    actions = list(),
    initialize = function(workers = 4) {
      for(i in seq_len(workers)) self$workers[[i]] <- Worker$new()
    },
    push = function(fun, args = list(), id = NULL) {
      if(is.null(id)) id <- private$get_next_id()
      self$tasks[[self$num_tasks + 1]] <- Task$new(fun, args, id)
    },
    run = function() {
      private$run_batch()
    }
  ),
  active = list(
    num_tasks = function() length(self$tasks),
    state = function() unlist(lapply(self$tasks, function(x) x$state))
  ),

  private = list(

    next_id = 1L,
    get_next_id = function() {
      id <- private$next_id
      private$next_id <- id + 1L
      paste0(".", id)
    },

    schedule = function() {
      lapply(self$workers, function(x) x$try_finish())
      unassigned <- which(vapply(self$workers, function(x) is.null(x$task), logical(1)))
      waiting <- which(vapply(self$tasks, function(x) x$state == "waiting", logical(1)))
      n <- min(length(unassigned), length(waiting))
      for(i in seq_len(n)) {
        self$workers[unassigned][[i]]$try_assign(self$tasks[waiting][[i]])
      }
      lapply(self$workers, function(x) x$try_start())
    },

    # Run all jobs loaded onto the queue as a batch
    run_batch = function() {
      spinner <- cli::make_spinner(which = "dots2", template = "{spin} Queue")
      repeat{
        private$schedule()
        state <- self$state
        msg <- paste(
          "{spin} Queue progress:", sum(state == "waiting"), "waiting",
          "\u1405", sum(state == "running"), "running", "\u1405",
          sum(state == "done"), "done"
        )
        spinner$spin(msg)
        if(sum(state == "waiting") == 0 & sum(state == "running") == 0) break
        Sys.sleep(.05)
      }
      spinner$finish()
      msg <- paste("Queue complete:", sum(state == "done"), "tasks done")
      cli::cli_alert_success(msg)
      return(invisible(private$tasks))
    }
  )
)
