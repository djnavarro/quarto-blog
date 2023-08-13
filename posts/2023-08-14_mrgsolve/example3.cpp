[PROB]

This is an example adapted from the user guide "topics" section.

[PARAM] @annotated

TVCL : 1.1   : Typical clearance (L/hr)
TVV  : 35.6  : Typical volume of distribution (L)
TVKA : 1.35  : Typical absorption rate constant (1/hr)
WT   : 70    : Weight (kg)
SEX  : 0     : Sex coded as male = 0, female = 1
WTCL : 0.75  : Coefficient for the effect of weight on CL
SEXV : 0.878 : Coefficient for the effect of sex = 1 on V

[MAIN]

double CL = TVCL * pow(WT/70, WTCL) * exp(ECL);
double V  = TVV  * pow(SEXV, SEX) * exp(EV);
double KA = TVKA * exp(EKA);

[OMEGA] @correlation @block @annotated

ECL : 1.23          : Random effect on CL
EV  : 0.67 0.4      : Random effect on V
EKA : 0.25 0.87 0.2 : Random effect on KA

[SIGMA] @annotated

PROP: 0.005  : Proportional residual error
ADD : 0.0001 : Additive residual error

[CMT] @annotated

GUT  : Dosing compartment (mg)
CENT : Central compartment (mg)

[PKMODEL]

ncmt = 1, depot = TRUE

[TABLE]

double CP = CENT / V;
double DV = CP * (1 + PROP) + ADD;

[CAPTURE] @annotated

CP : True plasma concentration (mg/L)
DV : Observed plasma concentration (mg/L)
