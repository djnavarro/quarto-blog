functions {
  vector mmk(real t,
             vector c,
             real vm,
             real km) {
    vector[1] dcdt;
    dcdt[1] = c[1] * vm / (km + c[1]);
    return dcdt;
  }
}
data {
  int<lower=1> T;
  vector[1] c0;
  real t0;
  array[T] real ts;
  real vm;
  real km;
}
model {
}
generated quantities {
  array[T] vector[1] conc = ode_rk45(mmk, c0, t0, ts, vm, km);
}
