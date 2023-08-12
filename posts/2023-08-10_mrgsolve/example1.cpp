[PROB]

This is a minor variation of the "pk2cmt" model that is distributed as
part of the mrgsolve internal model library. It has a single extravascular
dosing compartment (the GUT), a central compartment (CENT), and a
peripheral compartment (PERIPH). Absorption from GUT is first order,
whereas elimination from CENT follows Michaelis-Menten kinetics.

[PARAM] @annotated

CL   :   0  : Clearance (volume/time)
VC   :  20  : Central volume (volume)
Q    :   2  : Inter-compartmental clearance (volume/time)
VP   :  10  : Peripheral volume of distribution (volume)
KA   : 0.5  : Absorption rate constant (1/time)
VMAX :   1  : Maximum velocity of elimination (mass/time)
KM   :   2  : Michaelis constant for elimination (mass/volume)

[CMT] @annotated

GUT    : Drug amount in gut (mass)
CENT   : Drug amount in central compartment (mass)
PERIPH : Drug amount in peripherhal compartment (mass)

[GLOBAL]

#define CP (CENT / VC)          // concentration in central compartment
#define CT (PERIPH / VP)        // concentration in peripheral compartment
#define CLNL (VMAX / (KM + CP)) // non-linear clearance, per MM kinetics

[ODE]

dxdt_GUT = -KA * GUT;
dxdt_CENT = KA * GUT - (CL + CLNL + Q) * CP  + Q * CT;
dxdt_PERIPH = (Q * CP) - (Q * CT);

[CAPTURE] @annotated

CP : Plasma concentration (mass/time)

