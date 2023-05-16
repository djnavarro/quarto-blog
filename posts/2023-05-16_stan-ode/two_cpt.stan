functions {
  vector two_cpt(real time,
                 vector state,
                 real qe,
                 real qi,
                 real vc,
                 real vp,
                 real ka) {

    // convenience...
    real ag = state[1]; // gut amount
    real ac = state[2]; // central amount
    real ap = state[3]; // peripheral amount

    // derivative of state vector with respect to time
    vector[3] dadt;

    // compute derivatives
    dadt[1] = - (ka * ag);
    dadt[2] = (ka * ag) + (qi / vp) * ap - (qi / vc) * ac - (qe / vc) * ac;
    dadt[3] = - (qi / vp) * ap + (qi / vc) * ac;

    return dadt;
  }
}

data {
  int<lower=1> n_obs;
  int<lower=1> n_fit;
  vector[n_obs] c_obs;
  array[n_obs] real t_obs;
  array[n_fit] real t_fit;
  vector[3] a0;
  real t0;
}

parameters {
  real<lower=.001> qe;
  real<lower=.001> qi;
  real<lower=.001> vc;
  real<lower=.001> vp;
  real<lower=.001> ka;
  real<lower=.001> sigma;
}

transformed parameters {
  // use ode solver to find all amounts at all event times
  array[n_obs] vector[3] amount = ode_rk45(two_cpt,
                                           a0,
                                           t0,
                                           t_obs,
                                           qe,
                                           qi,
                                           vc,
                                           vp,
                                           ka);

  // vector of central concentrations
  vector[n_obs] mu;
  for (j in 1:n_obs) {
    mu[j] = amount[j, 2] / vc;
  }
}

model {
  // priors (adapted from Margossian et al 2022)
  qe ~ lognormal(log(10), 0.25); // elimination clearance, aka CL
  qi ~ lognormal(log(15), 0.5);  // intercompartmental clearance, aka Q
  vc ~ lognormal(log(35), 0.25); // central compartment volume
  vp ~ lognormal(log(105), 0.5); // peripheral compartment volume
  ka ~ lognormal(log(2.5), 1);   // absorption rate
  sigma ~ normal(0, 1);          // measurement error

  // likelihood of observed central concentrations
  c_obs ~ normal(mu, sigma);
}

generated quantities {
  array[n_fit] vector[3] amt_fit = ode_rk45(two_cpt,
                                            a0,
                                            t0,
                                            t_fit,
                                            qe,
                                            qi,
                                            vc,
                                            vp,
                                            ka);

  vector[n_fit] c_fit;
  for (j in 1:n_fit) {
    c_fit[j] = amt_fit[j, 2] / vc;
  }
}
