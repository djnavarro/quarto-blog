// Two compartment model using Torsten analytical solver 

data{
  int<lower = 1> nt;                // number of events
  int<lower = 1> nObs;              // number of observations
  array[nObs] int<lower = 1> iObs;  // indices of observation events
  
  // NONMEM data
  array[nt] int<lower = 1> cmt; // compartment number
  array[nt] int evid;           // event id (0=observation, 1=dose, 2=other)
  array[nt] int addl;           // number of additional identical doses given
  array[nt] int ss;             // is it steady-state dosing? (0=false, 1=true)
  array[nt] real amt;           // dose amount administered at this time
  array[nt] real time;          // time of observation/administration 
  array[nt] real rate;          // rate of drug infusion (0 for bolus administration)
  array[nt] real ii;            // interdose interval: time between additional doses 
  
  vector<lower = 0>[nObs] cObs;  // observed concentration (the dv)
}

transformed data{
  vector[nObs] logCObs = log(cObs);
  int nTheta = 5;  // number of ODE parameters describing the pharmacokinetic function
  int nCmt = 3;    // number of compartments in model (1=gut, 2=central, 3=peripheral)
}

parameters{
  real<lower = 0> CL;    // clearance rate from central compartment
  real<lower = 0> Q;     // intercompartmental clearance rate
  real<lower = 0> V1;    // volume of distribution, central compartment
  real<lower = 0> V2;    // volume of distribution, peripheral compartment
  real<lower = 0> ka;    // absorption rate constant from gut to central 
  real<lower = 0> sigma; // standard deviation of measurement error on log-scale
}

transformed parameters{
  array[nTheta] real theta;        // parameters of the pharmacokinetic function
  matrix<lower = 0>[nCmt, nt] x;   // drug amounts in each compartment over time

  // predicted drug concentrations in the central compartment
  row_vector<lower = 0>[nt] cHat;  // row vector, one element per event
  vector<lower = 0>[nObs] cHatObs; // column vector, one element per *observation*

  // bundle pharmacokinetic parameters into a vector
  theta[1] = CL;
  theta[2] = Q;
  theta[3] = V1;
  theta[4] = V2;
  theta[5] = ka;

  // compute the pharmacokinetic function (drug amounts in all compartments)
  x = pmx_solve_twocpt(time, amt, rate, ii, evid, cmt, addl, ss, theta);

  cHat = x[2, :] ./ V1;  // compute drug concentrations in central compartment
  cHatObs = cHat'[iObs]; // transform to column vector & keep relevant cells only
}

model{
  // informative prior
  CL ~ lognormal(log(10), 0.25);
  Q ~ lognormal(log(15), 0.5);
  V1 ~ lognormal(log(35), 0.25);
  V2 ~ lognormal(log(105), 0.5);
  ka ~ lognormal(log(2.5), 1);
  sigma ~ cauchy(0, 1);

  // measurement errors are log-normally distributed
  logCObs ~ normal(log(cHatObs), sigma);
}

generated quantities{
  array[nObs] real cObsPred; // simulated observations
  for(i in 1:nObs) {
    cObsPred[i] = exp(normal_rng(log(cHatObs[i]), sigma));
  }
}
