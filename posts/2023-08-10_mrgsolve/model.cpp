[ PROB ]

This is general purpose text used to annotate the model

[PARAM] @annotated

TVCL : 1.1   : Clearance (L/hr)
TVV  : 35.6  : Volume of distribution (L)
TVKA : 1.35  : Absorption rate constant (1/hr)
WT   : 70    : Weight (kg)
SEX  : 1     : Male = 0, Female = 1
WTCL : 0.75  : Exponent weight on CL
SEXV : 0.878 : Volume female / Volume male

[MAIN]

double CL = TVCL * pow(WT/70, WTCL) * exp(ECL);
double V  = TVV  * pow(SEXVC, SEX) * exp(EV);
double KA = TVKA * exp(EKA);

[OMEGA] @name OMGA @correlation @block @annotated

ECL : 1.23 : Random effect on CL
EV  : 0.67 0.4 : Random effect on V
EKA : 0.25 0.87 0.2 : Random effect on KA

[SIGMA] @name SGMA @annotated

PROP: 0.25 : Proportional residual error
ADD : 25   : Additive residual error

[CMT] @annotated

GUT  : Dosing compartment (mg)
CENT : Central compartment (mg)

[PKMODEL] ncmt = 1, depot=TRUE

[TABLE]

capture IPRED = CENT/V;
double DV = IPRED*(1+PROP) + ADD;

[CAPTURE] @annotated
DV  : Concentration (mg/L)
ECL : Random effect on CL
CL  : Individual clearance (L/hr)
