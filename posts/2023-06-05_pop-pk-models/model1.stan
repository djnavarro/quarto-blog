functions {
  vector amount_change(real time,
                       vector state,
                       real KA,
                       real CL,
                       real V) {
    vector[2] dadt;
    dadt[1] = - (KA * state[1]);
    dadt[2] = (KA * state[1]) - (CL / V) * state[2];
    return dadt;
  }
}

data {
  int<lower=1> n_ids;
  int<lower=1> n_tot;
  int<lower=1> n_fit;
  array[n_ids] int n_obs;
  vector[n_ids] dose;
  array[n_tot] real t_obs;
  vector[n_tot] c_obs;
  array[n_fit] real t_fit;
}

transformed data {
  array[n_ids] int start;
  array[n_ids] int stop;
  array[n_ids] vector[2] initial_amount;
  real initial_time = 0;

  // break points within the data vector
  start[1] = 1;
  stop[1] = n_obs[1];
  for(i in 2:n_ids) {
    start[i] = start[i - 1] + n_obs[i - 1];
    stop[i] = stop[i - 1] + n_obs[i];
  }

  // initial states for each person
  for(i in 1:n_ids) {
    initial_amount[i][1] = dose[i];
    initial_amount[i][2] = 0;
  }
}

parameters {
  real<lower=0> theta_KA;
  real<lower=0> theta_CL;
  real<lower=0> theta_V;
  real<lower=.001> omega_KA;
  real<lower=.001> omega_CL;
  real<lower=.001> omega_V;
  real<lower=.001> sigma;
  vector[n_ids] eta_KA;
  vector[n_ids] eta_CL;
  vector[n_ids] eta_V;
}

transformed parameters {
  vector<lower=0>[n_ids] KA;
  vector<lower=0>[n_ids] CL;
  vector<lower=0>[n_ids] V;
  array[n_tot] vector[2] amount;
  vector[n_tot] c_pred;

  for(i in 1:n_ids) {
    // pharmacokinetic parameters
    KA[i] = theta_KA * exp(eta_KA[i]);
    CL[i] = theta_CL * exp(eta_CL[i]);
    V[i] = theta_CL * exp(eta_V[i]);

    // predicted drug amounts
    amount[start[i]:stop[i]] = ode_bdf(
      amount_change,            // ode function
      initial_amount[i],        // initial state
      initial_time,             // initial time
      t_obs[start[i]:stop[i]],  // observation times
      KA[i],                    // absorption rate
      CL[i],                    // clearance
      V[i]                      // volume
    );

    // convert to concentrations
    for(j in 1:n_obs[i]) {
      c_pred[start[i] + j - 1] = amount[start[i] + j - 1, 2] / V[i];
    }
  }
}

model {
  // foolish priors over population parameters
  theta_KA ~ normal(0, 10);
  theta_CL ~ normal(0, 10);
  theta_V ~ normal(0, 10);
  sigma ~ normal(0, 10);
  omega_KA ~ normal(0, 10);
  omega_CL ~ normal(0, 10);
  omega_V ~ normal(0, 10);

  // random effect terms
  for(i in 1:n_ids) {
    eta_KA[i] ~ normal(0, omega_KA);
    eta_CL[i] ~ normal(0, omega_CL);
    eta_V[i] ~ normal(0, omega_V);
  }

  // likelihood of observed concentrations
  c_obs ~ normal(c_pred, sigma);
}

generated quantities {
  array[n_ids, n_fit] vector[2] a_fit;
  array[n_ids, n_fit] real c_fit;

  for(i in 1:n_ids) {
    // predicted drug amounts
    a_fit[i] = ode_bdf(
      amount_change,        // ode function
      initial_amount[i],    // initial state
      initial_time,         // initial time
      t_fit,                // observation times
      KA[i],                // absorption rate
      CL[i],                // clearance
      V[i]                  // volume
    );

    // convert to concentrations
    for(j in 1:n_fit) {
      c_fit[i, j] = a_fit[i, j][2] / V[i];
    }
  }
}



