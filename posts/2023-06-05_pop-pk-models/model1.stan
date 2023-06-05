functions {
  vector amount_change(real time,
                       vector state,
                       real KA,
                       real CL,
                       real V) {

    real Ag = state[1]; // gut amount
    real Ac = state[2]; // central amount

    // compute derivatives
    vector[2] dadt;
    dadt[1] = - (KA * Ag);
    dadt[2] = (KA * Ag) - (CL / V) * Ac;

    return dadt;
  }
}

data {
  int<lower=1> n_obs;
  int<lower=1> n_fit;
  vector[n_obs] c_obs;
  array[n_obs] real t_obs;
  array[n_fit] real t_fit;
  vector[2] A0;
  real t0;
}

parameters {
  real<lower=.001> KA;
  real<lower=.001> CL;
  real<lower=.001> V;
  real<lower=.001> sigma;
}

transformed parameters {
  // use ode solver to find all amounts at all event times
  array[n_obs] vector[3] amount = ode_rk45(
    amount_change, A0, t0, t_obs, KA, CL, V
  );

  // vector of central concentrations
  vector[n_obs] mu;
  for (j in 1:n_obs) {
    mu[j] = amount[j, 2] / vc;
  }
}

model {
  // priors (adapted from Margossian et al 2022)
  CL ~ lognormal(log(10), 0.25); // clearance
  V ~ lognormal(log(35), 0.25);  // central compartment volume
  VA ~ lognormal(log(2.5), 1);   // absorption rate
  sigma ~ normal(0, 1);          // measurement error

  // likelihood of observed central concentrations
  c_obs ~ normal(mu, sigma);
}

generated quantities {
  array[n_fit] vector[3] amt_fit = ode_rk45(
    amount_change, A0, t0, t_fit, KA, CL, V
  );

  vector[n_fit] c_fit;
  for (j in 1:n_fit) {
    c_fit[j] = amt_fit[j, 2] / vc;
  }
}
