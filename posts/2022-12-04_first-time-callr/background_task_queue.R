
# doesn't currently work, just placeholder for code
BackgroundTaskQueue <- R6::R6Class(
  classname = "BackgroundTaskQueue",
  public = list(),
  private = list(

    # Register a task handler for the queue, so that the user is updated
    # every time a top-level function completes
    add_queue_callback = function() {
      addTaskCallback(function(expr, value, ok, visible) {
        n_waiting <- sum(!private$tasks$idle & private$tasks$state == "waiting")
        n_running <- sum(!private$tasks$idle & private$tasks$state == "running")
        n_done <- sum(private$tasks$state == "done")
        msg <- paste0("[", self$name, "]")
        msg <- paste(
          msg, n_waiting, "waiting", "\u1405", n_running,
          "running", "\u1405", n_done, "done"
        )
        cli::cli_alert(msg)
        n_waiting > 0 || n_done == 0
      }, name = "TaskQueueCallback")
    },


    # Finalizer does cleanup: removes any callback we've added, (and kills any
    # worker R sessions?)
    finalize = function() {
      invisible(removeTaskCallback("TaskQueueCallback"))
    }

  )
)

