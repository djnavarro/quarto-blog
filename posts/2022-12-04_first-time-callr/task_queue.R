# adapted from: https://www.tidyverse.org/blog/2019/09/callr-task-q/

Task <- R6::R6Class(
  classname = "Task",
  public = list(
    initialize = function(fun, args = list(), id = NULL) {
      self$fun <- fun
      self$args <- args
      self$task_id <- id
      self$state <- "waiting"
      self$time_created <- Sys.time()
    },
    fun = NULL,
    args = NULL,
    results = NULL,
    task_id = NULL,
    worker_id = NULL,
    state = NULL,
    time_created = NULL,
    time_started = NULL,
    time_finished = NULL,
    time_elapsed = NULL
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
        self$task$worker_id <- self$id
        self$task$time_started <- Sys.time()
        return(invisible(TRUE))
      }
      invisible(FALSE)
    },
    try_assign = function(task) {
      if(is.null(self$task)) {
        self$task <- task
        self$task$state <- "waiting"
        return(invisible(TRUE))
      }
      invisible(FALSE)
    },
    try_finish = function(timeout = 0) {
      if(!is.null(self$task) && self$task$state == "running") {
        if(self$session$poll_process(timeout) == "ready") {
          self$task$results <- self$session$read()
          self$task$state <- "done"
          self$task$time_finished <- Sys.time()
          self$task$time_elapsed <- self$task$time_finished - self$task$time_started
          self$task <- NULL
          return(invisible(TRUE))
        }
      }
      invisible(FALSE)
    }
  ),
  active = list(
    state = function() self$session$get_state()
  )
)

WorkerPool <- R6::R6Class(
  classname = "WorkerPool",
  public = list(
    initialize = function(workers = 4L) {
      for(i in seq_len(workers)) self$pool[[i]] <- Worker$new()
    },
    pool = list(),
    refill_pool = function() {
      fin <- which(self$state == "finished")
      if(length(fin)) {
        for(i in seq_len(fin)) self$pool[fin][[i]] <- Worker$new()
      }
    },
    try_finish = function() {
      lapply(self$pool, function(x) x$try_finish())
    },
    try_start = function() {
      lapply(self$pool, function(x) x$try_start())
    },
    try_assign = function(tasks) {
      n_workers <- length(self$pool)
      n_tasks <- length(tasks)
      w <- 1
      t <- 1
      while(n_workers > 0 & n_tasks > 0) {
        assigned <- self$pool[[w]]$try_assign(tasks[[t]])
        w <- w + 1
        n_workers <- n_workers - 1
        if(assigned) {
          t <- t + 1
          n_tasks <- n_tasks - 1
        }
      }
    }
  ),
  active = list(
    state = function() vapply(self$pool, function(x) x$state, character(1))
  )
)

Queue <- R6::R6Class(
  classname = "Queue",

  public = list(
    workers = NULL,
    tasks = list(),
    actions = list(),
    initialize = function(workers = 4) {
      if(inherits(workers, "WorkerPool")) {
        self$workers <- workers
      } else {
        self$workers <- WorkerPool$new(workers)
      }
    },
    push = function(fun, args = list(), id = NULL) {
      if(is.null(id)) id <- private$get_next_id()
      self$tasks[[self$num_tasks + 1]] <- Task$new(fun, args, id)
    },
    run = function(verbose = FALSE) {
      private$run_batch(verbose)
    }
  ),

  active = list(
    num_tasks = function() length(self$tasks),
    state = function() {
      s <- unlist(lapply(self$tasks, function(x) x$state))
      names(s) <- unlist(lapply(self$tasks, function(x) x$task_id))
      s
    }
  ),

  private = list(

    next_id = 1L,

    get_next_id = function() {
      id <- private$next_id
      private$next_id <- id + 1L
      paste0(".", id)
    },

    # these feel like hacks: get rid of it when we have a proper tibble
    get_task_by_id = function(id) {
      ind <- which(unlist(lapply(self$tasks, function(x) x$task_id == id)))
      self$tasks[[ind]]
    },
    get_waiting_tasks = function() {
      waiting <- vapply(self$tasks, function(x) x$state == "waiting", logical(1))
      self$tasks[waiting]
    },

    schedule = function() {
      out <- list()
      out$try_finish  <- self$workers$try_finish()
      out$refill_pool <- self$workers$refill_pool()
      out$try_assign  <- self$workers$try_assign(private$get_waiting_tasks())
      out$try_start   <- self$workers$try_start()
      invisible(out)
    },

    message_spinner_progress = function(state) {
      paste(
        "{spin} Queue progress:", sum(state == "waiting"), "waiting",
        "\u1405", sum(state == "running"), "running", "\u1405",
        sum(state == "done"), "done"
      )
    },

    message_batch_finished = function(state, time_elapsed) {
      runtime <- round(as.numeric(time_elapsed), 2)
      paste("Queue complete:", sum(state == "done"), "tasks done",
            "(Total time:", runtime, "seconds)")
    },

    message_task_finished = function(id) {
      task <- private$get_task_by_id(id)
      runtime <- round(as.numeric(task$time_elapsed), 2)
      paste("Task complete:", id, "(Time:", runtime, "seconds)")
    },

    new_spinner = function() {
      cli::make_spinner(which = "dots2", template = "{spin} Queue")
    },

    run_batch = function(verbose) {
      time_started <- Sys.time()
      spinner <- private$new_spinner()
      if(verbose) {
        state <- self$state
        done_before <- names(which(state == "done"))
      }
      repeat{
        private$schedule()
        state <- self$state
        if(verbose) {
          done_now <- names(which(state == "done"))
          done_just_now <- setdiff(done_now, done_before)
          if(length(done_just_now)) {
            done_before <- done_now
            spinner$finish()
            for(id in done_just_now) {
              cli::cli_alert(private$message_task_finished(id))
            }
            spinner <- private$new_spinner()
          }
        }
        spinner$spin(private$message_spinner_progress(state))
        if(sum(state %in% c("waiting", "running")) == 0) break
        Sys.sleep(.05)
      }
      spinner$finish()
      time_finished <- Sys.time()
      time_elapsed <- time_finished - time_started
      cli::cli_alert_success(private$message_batch_finished(state, time_elapsed))
      return(invisible(private$tasks))
    }
  )
)
