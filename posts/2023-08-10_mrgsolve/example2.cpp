[PROB]

This is a population-PK two-compartment model.

[PARAM] @annotated

TVVC   : 20  : Typical value for VC (volume)
TVVP   : 10  : Typical value for VP (volume)
TVKA   :  1  : Typical value for KA (1/time)
TVCL   :  1  : Typical value for CL (volume/time)
TVQ    :  2  : Typical value for Q (volume/time)

[OMEGA] @annotated

EVC   :   2 : Variance of random effect on VC
EVP   :   1 : Variance of random effect on VP
EKA   : 0.1 : Variance of random effect on KA
ECL   : 0.1 : Variance of random effect on CL
EQ    : 0.1 : Variance of random effect on Q

[MAIN]

double VC = TVVC * exp(EVC); // central compartment volume
double VP = TVVP * exp(EVP); // peripheral compartment volume
double KA = TVKA * exp(EKA); // absorption rate constant
double CL = TVCL * exp(ECL); // clearance
double Q  = TVQ  * exp(EQ);  // intercompartmental clearance

[CMT] @annotated

GUT    : Drug amount in gut (mass)
CENT   : Drug amount in central compartment (mass)
PERIPH : Drug amount in peripherhal compartment (mass)

[GLOBAL]

#define CP (CENT / VC)   // concentration in central compartment
#define CT (PERIPH / VP) // concentration in peripheral compartment

[ODE]

dxdt_GUT    = -(KA * GUT);
dxdt_CENT   =  (KA * GUT) - (CL + Q) * CP + (Q * CT);
dxdt_PERIPH =  (Q * CP) - (Q * CT);

[CAPTURE] @annotated

CP : Plasma concentration (mass/time)

