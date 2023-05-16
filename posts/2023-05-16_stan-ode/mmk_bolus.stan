functions {
  vector mmk(real time,
             vector state,
             real vm,
             real km) {
    vector[1] derivative;
    derivative[1] = - state[1] * vm / (km + state[1]);
    return derivative;
  }
}

data {
  int<lower=1> n_obs;
  int<lower=1> n_fit;
  vector<lower=0>[n_obs] c_obs;
  array[n_obs] real t_obs;
  array[n_fit] real t_fit;
  real<lower=0> vol_d;
  real<lower=0> dose;
  real t0;
}

parameters {
  real<lower=0.01> sigma;
  real<lower=0.01, upper=30> v0;
  real<lower=0.01, upper=50> km;
  real<lower=1, upper=12> vol_d_true;
}

transformed parameters {
  vector[1] c0;
  c0[1] = dose / vol_d_true;
  real<lower=0.01> vm = v0 * (km + c0[1]) / c0[1];
}

model {
  array[n_obs] vector[1] mu_arr;
  vector[n_obs] mu_vec;

  v0 ~ normal(0, 10) T[0.01, ];
  km ~ normal(0, 10) T[0.01, ];
  sigma ~ normal(0, 1) T[0.01, ];
  vol_d_true ~ normal(vol_d, 1);

  mu_arr = ode_rk45(mmk, c0, t0, t_obs, vm, km);
  for (i in 1:n_obs) {
    mu_vec[i] = mu_arr[i, 1];
  }
  c_obs ~ normal(mu_vec, sigma);
}

generated quantities {
  array[n_fit] vector[1] c_fit = ode_rk45(mmk, c0, t0, t_fit, vm, km);
  real<lower=0.01> k0 = (c0[1] * km) / (c0[1] + 2*km);
}
