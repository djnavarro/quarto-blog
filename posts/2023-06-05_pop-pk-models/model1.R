
# preliminaries -----------------------------------------------------------

dir <- here::here("posts", "2023-06-10_pop-pk-models")
csv_path <- fs::path(dir, "warfpk.csv")
mod_path <- fs::path(dir, "model1.stan")

warfpk <- csv_path |>
  readr::read_csv(na = ".", show_col_types = FALSE) |>
  dplyr::rename(id = `#ID`) |>
  dplyr::mutate(
    id = id |>
      stringr::str_remove_all("#") |>
      as.numeric()
  )


# organise data for stan --------------------------------------------------

warfpk_obs <- warfpk[warfpk$mdv == 0, ]
warfpk_amt <- warfpk[!is.na(warfpk$rate), ]

t_fit <- c(
  seq(.1, .9, .1),
  seq(1, 2.75, .25),
  seq(3, 9.5, .5),
  seq(10, 23, 1),
  seq(24, 120, 3)
)

dat <- list(
  n_ids = nrow(warfpk_amt),
  n_tot = nrow(warfpk_obs),
  n_obs = purrr::map_int(
    warfpk_amt$id,
    ~ nrow(warfpk_obs[warfpk_obs$id == .x, ])
  ),
  t_obs = warfpk_obs$time,
  c_obs = warfpk_obs$dv,
  dose = warfpk_amt$amt,
  t_fit = t_fit,
  n_fit = length(t_fit)
)

# fit model ---------------------------------------------------------------

mod <- cmdstanr::cmdstan_model(mod_path)

time_start <- Sys.time()
out <- mod$sample(
  data = dat,
  chains = 4,
  refresh = 1,
  iter_warmup = 1000,
  iter_sampling = 1000
)
time_stop <- Sys.time()

# save results ------------------------------------------------------------

out_summary <- out$summary()
out_draws <- out$draws(format = "draws_df")

readr::write_csv(out_summary, fs::path(dir, "model1_summary.csv"))
readr::write_csv(out_draws, fs::path(dir, "model1_draws.csv"))


# quick check -------------------------------------------------------------

res <- tibble::tibble(
  y = dat$c_obs,
  y_hat = out_summary$mean[grepl("c_pred", out_summary$variable)],
  id = warfpk_obs$id
)

pic <- ggplot2::ggplot(res, ggplot2::aes(y_hat, y, colour = factor(id))) +
  ggplot2::geom_abline(intercept = 0, slope = 1) +
  ggplot2::geom_point(show.legend = FALSE) +
  ggplot2::facet_wrap(~ factor(id))

plot(pic)

