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
  int<lower=1> nt;
  vector[1] c0;
  real t0;
  array[nt] real ts;
  real vm;
  real km;
}

model {
}

generated quantities {
  array[nt] vector[1] conc = ode_rk45(mmk, c0, t0, ts, vm, km);
}
