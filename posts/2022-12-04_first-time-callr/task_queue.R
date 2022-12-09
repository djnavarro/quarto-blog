task_queue <- R6::R6Class(
  classname = "task_queue",

  # Our public methods will all be thin wrappers: we're only using the public
  # methods for the user-facing API. No computation is done here
  public = list(
    initialize = function(workers = 4L) {
      private$initialize_task_queue(workers)
      invisible(self)
    },
    push = function(fun, args = list(), id = NULL) {
      private$push_task_onto_queue(fun, args, id)
    },
    pop = function(timeout = 0) {
      private$pop_task_from_queue(timeout)
    },
    poll = function(timeout = 0) {
      private$poll_worker(timeout)
    }
  ),

  # The tasks field is an active binding because it needs to update whenever
  # the state of the tasks queue changes (stored in private$tasks)
  active = list(
    tasks = function() {
      private$tasks
    }
  ),

  private = list(

    # A tibble that represents the tasks queue itself. More precisely it's
    # as the container for callr R session objects (workers), results, and other
    # important metadata that we need. The row order matters. It reflects
    # priority order: tasks at the top are assigned to workers first, and are
    # handled in strict sequential order when workers become available
    tasks = private$tasks <- tibble::tibble(
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
    as_ms <- function(x) {
      if (x==Inf) -1 else as.integer(as.double(x, "secs") * 1000)
    },

    # Poll the running workers once with processx::poll(), and call
    # the scheduler
    poll_once <- function() {

      # Find the tasks that have workers assigned, and were known to be
      # still running at the time of the last poll
      workers_to_poll <- which(private$tasks$state == "running")

      # Grab the actual connections
      connections <- lapply(
        private$tasks$worker[workers_to_poll],
        function(x) x$get_poll_connection()
      )

      # Now poll each of those processes to determine their current state
      pr <- processx::poll(processes = connections, ms = as_ms(timeout))

      # Use the poll results to update the listings on the task queue and
      # call the scheduler to reassign workers (the scheduler will return
      # early if none need to be reassigned so that's fine)
      private$tasks$state[workers_to_poll][pr == "ready"] <- "ready"
      private$schedule()

      # Return vector of ids for tasks in the "done" state
      tasks_done <- private$tasks$id[private$tasks$state == "done"]
      tasks_done
    }

    # Poll the running workers at least once (but possibly more than once),
    # until timeout occurs or until a worker in the "done" state is detected
    poll_workers = function(timeout) {
      limit <- Sys.time() + timeout
      repeat{
        tasks_done <- poll_once()
        if (is.finite(timeout)) timeout <- limit - Sys.time()
        if (length(tasks_done) || timeout < 0) break;
      }
      tasks_done
    },

    # scheduling function
    schedule = function() {

      # find worker R sessions that have finished (return early if none have)
      ready <- which(private$tasks$state == "ready")
      if (!length(ready)) return()

      # for finished tasks, read out the results into private$tasks
      ready_workers <- private$tasks$worker[ready]
      private$tasks$result[ready] <- lapply(
        ready_workers,
        function(x) x$read()
      )

      #
      private$tasks$worker[ready] <- replicate(length(ready), NULL)
      private$tasks$state[ready] <-
        ifelse(private$tasks$idle[ready], "waiting", "done")

      waiting_tasks <- which(private$tasks$state == "waiting")[1:length(ready)]

      private$tasks$worker[waiting_tasks] <- ready_workers

      private$tasks$state[waiting_tasks] <- ifelse(
        test = private$tasks$idle[waiting_tasks],
        yes = "ready",
        no = "running"
      )
      lapply(waiting_tasks, function(i) {
        if (! private$tasks$idle[i]) {
          private$tasks$worker[[i]]$call(private$tasks$fun[[i]],
                                         private$tasks$args[[i]])
        }
      })
    }

  )
)
