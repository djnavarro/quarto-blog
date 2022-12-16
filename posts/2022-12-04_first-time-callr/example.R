
# define TaskQueue R6 class and subdivision() art function
post_dir <- here::here("posts/2022-12-04_first-time-callr")
source(file.path(post_dir, "task_queue.R"))
source(file.path(post_dir, "subdivision.R"))

# set up queue with 6 workers
queue <- Queue$new(workers = 6)

# load 30 art jobs onto queue
for(seed in 201:210) {
  queue$push(subdivision, args = list(seed))
}

# multi-threaded execution
queue$run(verbose = TRUE)

# forces a crash in n seconds
#crashn <- function(n = 5) {Sys.sleep(n); .Call("abort")}


