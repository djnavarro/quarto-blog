

TWIT_post <- rtweet:::TWIT_post
TWIT_paginate_cursor <- rtweet:::TWIT_paginate_cursor

cancel_user <- function(user, type) {
  api <- c(
    "block" = "/1.1/blocks/create",
    "mute" = "/1.1/mutes/users/create"
  )
  TWIT_post(
    token = NULL,
    api = api[type],
    params = list(user_id = user)
  )
}

cancel_safely <- purrr::safely(cancel_user)

rate_exceeded <- function(out) {
  if(is.null(out$error)) return(FALSE)
  if(grepl("limit exceeded", out$error$message)) return(TRUE)
  return(FALSE)
}

cancel_verbosely <- function(user, type) {

  msg <- c(
    "block" = "blocking user id",
    "mute" = "muting user id"
  )
  withr::local_options(scipen = 14)
  cli::cli_process_start(paste(msg[type], user))

  repeat {
    out <- cancel_safely(user, type)
    if(rate_exceeded(out)) {
      Sys.sleep(300)
    } else {
      break
    }
  }

  if(is.null(out$result)) {
    cli::cli_process_failed()
  } else{
    cli::cli_process_done()
  }
}

cancel_users <- function(users, type) {
  msg <- c("block" = "blocking ", "mute" = "muting ")
  cat(msg[type], length(users), " users\n...")
  purrr::walk(users, cancel_verbosely, type = type)
}

list_cancelled <- function(type, n_max, ...) {
  api <- c(
    "block" = "/1.1/blocks/ids",
    "mute" = "/1.1/mutes/users/ids"
  )
  params <- list(
    include_entities = "false",
    skip_status = "true"
  )
  resp <- TWIT_paginate_cursor(NULL, api[type], params, n = n_max, ...)
  users <- unlist(lapply(resp, function(x) x$ids))
  return(users)
}

cancel_followers <- function(user, type = "block", n_max = 50000, precancelled = numeric(0)) {

  followers <- rtweet::get_followers(user, n = n_max, retryonratelimit = TRUE)
  followers <- followers$from_id

  uncancelled <- setdiff(followers, precancelled)
  uncancelled <- sort(as.numeric(uncancelled))

  cancel_users(uncancelled, type = type)
}

cancel_followers("docstockk")
