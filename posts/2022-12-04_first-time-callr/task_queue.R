# adapted from: https://www.tidyverse.org/blog/2019/09/callr-task-q/

TaskQueue <- R6::R6Class(
  classname = "TaskQueue",

  # Our public methods will all be thin wrappers: we're only using the public
  # methods for the user-facing API. No computation is done here
  public = list(
    initialize = function(workers = 4L) {
      private$initialize_queue(workers)
      invisible(self)
    },
    push = function(fun, args = list(), id = NULL) {
      private$push_task_onto_queue(fun, args, id)
    },
    pop = function(timeout = 0) {
      private$pop_task_from_queue(timeout)
    },
    poll = function(timeout = 0) {
      private$poll_workers(timeout)
    },
    get_tasks = function() {
      private$tasks
    },
    run = function() {
      private$execute_queue()
    }
  ),

  private = list(

    # A tibble that represents the tasks queue itself. More precisely it's
    # as the container for callr R session objects (workers), results, and other
    # important metadata that we need. The row order matters. It reflects
    # priority order: tasks at the top are assigned to workers first, and are
    # handled in strict sequential order when workers become available
    tasks = tibble::tibble(
      id = character(),
      idle = logical(),
      state = character(),
      fun = list(),
      args = list(),
      worker = list(),
      result = list()
    ),

    # Start as many worker R sessions as requested, and create dummy rows in
    # the tasks tibble, representing the "idle state", in which that worker has
    # no actual task to do. These rows will always sit at the bottom of the
    # task queue (i.e., they are by definition lowest priority)
    initialize_queue = function(workers) {

      for (i in seq_len(workers)) {

        # This launches a new R session in a separate thread
        worker <- callr::r_session$new(wait = FALSE)

        # Adds a row for an "idle" task and assigns the worker to that task.
        # Idle tasks are special: they never have state "done", so workers are
        # only pulled off them because the scheduler knows these aren't real
        private$tasks <- private$tasks |>
          tibble::add_row(
            id = paste0(".idle-", i),
            idle = TRUE,
            state = "running",
            fun = list(NULL),
            args = list(NULL),
            worker = list(worker),
            result = list(NULL)
          )
      }
    },

    # Convenience function and counter for generating task ids
    next_id = 1L,
    get_next_id = function() {
      id <- private$next_id
      private$next_id <- id + 1L
      paste0(".", id)
    },

    # Push task to queue and call scheduler
    push_task_onto_queue = function(fun, args, id) {

      if (is.null(id)) id <- private$get_next_id()
      if (id %in% private$tasks$id) stop("Duplicate task id")

      private$tasks <- private$tasks |>
        tibble::add_row(
          .before = which(private$tasks$idle)[1],
          id = id,
          idle = FALSE,
          state = "waiting",
          fun = list(fun),
          args = list(args),
          worker = list(NULL),
          result = list(NULL)
        )
      private$schedule()
      invisible(id)
    },

    # This pops the results of first completed task off the queue
    # and removes it from the listed tasks. It returns null if
    # nothing has finished
    pop_task_from_queue = function(timeout) {
      done <- self$poll(timeout)[1]
      if (is.na(done)) return(NULL)
      row <- match(done, private$tasks$id)
      result <- private$tasks$result[[row]]
      private$tasks <- private$tasks[-row, ]
      c(result, list(task_id = done))
    },

    # Convenience function converting units to milliseconds
    as_ms = function(x) {
      if (x==Inf) -1 else as.integer(as.double(x, "secs") * 1000)
    },

    # Poll the running workers once with processx::poll(), and call
    # the scheduler
    poll_once = function(timeout) {

      # Find the tasks that have workers assigned, and were known to be
      # still running at the time of the last poll
      workers_to_poll <- which(private$tasks$state == "running")

      # Grab the actual connections
      connections <- lapply(
        private$tasks$worker[workers_to_poll],
        function(x) x$get_poll_connection()
      )

      # Now poll each of those processes to determine their current state
      pr <- processx::poll(
        processes = connections,
        ms = private$as_ms(timeout)
      )

      # Use the poll results to update the listings on the task queue and
      # call the scheduler to reassign workers (the scheduler will return
      # early if none need to be reassigned so that's fine)
      private$tasks$state[workers_to_poll][pr == "ready"] <- "ready"
      private$schedule()

      # Return vector of ids for tasks in the "done" state
      tasks_done <- private$tasks$id[private$tasks$state == "done"]
      tasks_done
    },

    # Poll the running workers at least once, possibly more than once,
    # until timeout occurs or until a worker in the "done" state is detected
    poll_workers = function(timeout) {
      limit <- Sys.time() + timeout
      repeat{
        tasks_done <- private$poll_once(timeout)
        if (is.finite(timeout)) timeout <- limit - Sys.time()
        if (length(tasks_done) || timeout < 0) break;
      }
      tasks_done
    },

    # Run all jobs loaded onto the queue (in fifo order)
    execute_queue = function() {
      spinner <- cli::make_spinner(
        which = "dots2",
        template = "{spin} Queue"
      )
      repeat{
        n_waiting <- sum(!private$tasks$idle & private$tasks$state == "waiting")
        n_running <- sum(!private$tasks$idle & private$tasks$state == "running")
        n_done <- sum(private$tasks$state == "done")

        private$poll_workers(timeout = 0)
        msg <- paste("{spin} Queue progress:", n_waiting, "tasks waiting", "\u1405",
                     n_running, "tasks running", "\u1405", n_done, "tasks done")
        spinner$spin(msg)
        if(n_waiting == 0 & n_running == 0) break
        Sys.sleep(.05)
      }
      spinner$finish()
      cli::cli_alert_success("Queue complete: {n_done} tasks done")
      return(invisible(private$tasks))
    },

    # Convenience function to launch the job registered in the i-th row
    # of the task queue. It assumes the worker is correctly assigned already.
    # The only check it does is to see if this is a real job: the "idle" tasks
    # do nothing when start_task() is called
    start_task = function(i) {
      if (!private$tasks$idle[i]) {
        private$tasks$worker[[i]]$call(
          func = private$tasks$fun[[i]],
          args = private$tasks$args[[i]]
        )
      }
    },

    # Scheduler: find completed tasks, read results, start next tasks
    schedule = function() {

      # Find the ready worker R sessions: those that have finished their task.
      # (Return early if no workers are ready)
      ready <- which(private$tasks$state == "ready")
      if (!length(ready)) return()
      workers <- private$tasks$worker[ready]

      # For ready workers, read the results of completed tasks into
      # private$tasks, remove the worker from that task, and update the
      # status of that task: "waiting" if it's one of the dummy tasks used
      # to denote idle workers, "done" if it's a real task that has completed
      private$tasks$result[ready] <- lapply(workers, function(x) x$read())
      private$tasks$worker[ready] <- replicate(length(ready), NULL)
      private$tasks$state[ready] <- ifelse(
        test = private$tasks$idle[ready],
        yes = "waiting",
        no = "done"
      )

      # Now assign the workers to the top N tasks that are still in the
      # "waiting" state (either real tasks or idle state dummy tasks), and
      # start the corresponding tasks
      waiting <- which(private$tasks$state == "waiting")[1:length(ready)]
      private$tasks$worker[waiting] <- workers
      private$tasks$state[waiting] <- ifelse(
        test = private$tasks$idle[waiting],
        yes = "ready",  # idle workers remain "ready" after assignment
        no = "running"  # active workers are "running" after assignment
      )
      lapply(waiting, private$start_task)
    }
  )
)




