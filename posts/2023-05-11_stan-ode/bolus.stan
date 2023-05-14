data {
  int<lower=1> n_obs;
  int<lower=1> n_pred;
  real<lower=0> c0;
  vector<lower=0>[n_obs] t_obs;
  vector<lower=0>[n_obs] c_obs;
  vector<lower=0>[n_pred] t_pred;
}

parameters {
  real<lower=0> sigma;
  real<lower=0> k;
}

model {
  sigma ~ cauchy(0, 5);
  c_obs ~ normal(c0 * exp(-k * t_obs), sigma);
}

generated quantities {
  vector<lower=0>[n_pred] c_pred = c0 * exp(-k * t_pred);
}
