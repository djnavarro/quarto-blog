// Two compartment model using Torsten analytical solver 

data{
  int<lower = 1> nt;  // number of events
  int<lower = 1> nObs;  // number of observation
  array[nObs] int<lower = 1> iObs;  // index of observation
  
  // NONMEM data
  array[nt] int<lower = 1> cmt; // compartment number
  array[nt] int evid; // event id (0=observation, 1=dose, 2=other)
  array[nt] int addl; // number of additional identical doses given
  array[nt] int ss; // steady-state dosing (0=false, 1=true)
  array[nt] real amt; // dose amount administered at this time
  array[nt] real time; // time of observation/administration 
  array[nt] real rate; // rate of drug infusion (0 for bolus)
  array[nt] real ii; // interdose interval, time between additional doses 
  
  vector<lower = 0>[nObs] cObs;  // observed concentration (the dv)
}

transformed data{
  vector[nObs] logCObs = log(cObs);
  int nTheta = 5;  // number of ODE parameters in 2-compartment model
  int nCmt = 3;  // number of compartments in model
}

parameters{
  real<lower = 0> CL;
  real<lower = 0> Q;
  real<lower = 0> V1;
  real<lower = 0> V2;
  real<lower = 0> ka;
  real<lower = 0> sigma;
}

transformed parameters{
  array[nTheta] real theta;  // ODE parameters
  row_vector<lower = 0>[nt] cHat;
  vector<lower = 0>[nObs] cHatObs;
  matrix<lower = 0>[nCmt, nt] x;

  theta[1] = CL;
  theta[2] = Q;
  theta[3] = V1;
  theta[4] = V2;
  theta[5] = ka;

  x = pmx_solve_twocpt(time, amt, rate, ii, evid, cmt, addl, ss, theta);

  cHat = x[2, :] ./ V1; // drug amount in the second compartment
  cHatObs = cHat'[iObs]; // predictions for observed data records
}

model{
  // informative prior
  CL ~ lognormal(log(10), 0.25);
  Q ~ lognormal(log(15), 0.5);
  V1 ~ lognormal(log(35), 0.25);
  V2 ~ lognormal(log(105), 0.5);
  ka ~ lognormal(log(2.5), 1);
  sigma ~ cauchy(0, 1);

  logCObs ~ normal(log(cHatObs), sigma);
}

generated quantities{
  array[nObs] real cObsPred;
  for(i in 1:nObs) {
    cObsPred[i] = exp(normal_rng(log(cHatObs[i]), sigma));
  }
}
