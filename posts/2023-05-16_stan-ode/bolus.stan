data {
  int<lower=1> n_obs;
  real<lower=0> dose;
  real<lower=0> vol_d;
  vector[n_obs] t_obs;
  vector<lower=0>[n_obs] c_obs;
}

parameters {
  real<lower=0.01> sigma;
  real<lower=0.01> k;
  real<lower=1, upper=12> vol_d_true;
}

model {
  k ~ normal(0, 5) T[0.01, ];
  sigma ~ normal(0, 1) T[0.01, ];
  vol_d_true ~ normal(vol_d, 1);
  c_obs ~ normal(dose / vol_d_true * exp(-k * t_obs), sigma);
}
