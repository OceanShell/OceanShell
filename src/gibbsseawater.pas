unit GibbsSeaWater;

(*
Gibbs SeaWater (GSW) Oceanographic Toolbox of TEOS–10 (gsw_c_v3.05)
http://www.teos-10.org/pubs/gsw/html/gsw_contents.html

These declarations facilitate the use of TEOS-10
functions with FreePascal/Lazarus.

Alexander Smirnov (axline@mail.ru)
2015-2019

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License 3 as published by the Free Software
Foundation. See the GNU General Public License for more details
(http://www.gnu.org/licenses/).

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.
*)


interface

{$IFDEF WINDOWS}
const
  libgswteos='libgswteos-10.dll';
{$ENDIF}

{$IFDEF LINUX}
const
  libgswteos='libgswteos-10.so';
{$ENDIF}


(*
Adds a barrier through Central America (Panama) and then averages
over the appropriate side of the barrier

data_in      :  data                                         [unitless]
lon          :  Longitudes of data degrees east              [0 ... +360]
lat          :  Latitudes of data degrees north              [-90 ... +90]
longs_grid   :  Longitudes of regular grid degrees east      [0 ... +360]
lats_grid    :  Latitudes of regular grid degrees north      [-90 ... +90]
dlongs_grid  :  Longitude difference of regular grid degrees [deg longitude]
dlats_grid   :  Latitude difference of regular grid degrees  [deg latitude]

output_data  : average of data depending on which side of the
Panama canal it is on                         [unitless]
*)
// void   gsw_add_barrier(double *input_data, double lon, double lat, double long_grid, double lat_grid, double dlong_grid, double dlat_grid, double *output_data);



(*
Replaces NaN's with non-nan mean of the 4 adjacent neighbours
data_in   : data set of the 4 adjacent neighbours
data_out : non-nan mean of the 4 adjacent neighbours     [unitless]
*)
// void   gsw_add_mean(double *data_in, double *data_out);


(*
Calculates the adiabatic lapse rate from Conservative Temperature

sa     : Absolute Salinity                                 [g/kg]
ct     : Conservative Temperature                          [deg C]
p      : sea pressure                                      [dbar]

gsw_adiabatic_lapse_rate_from_ct : adiabatic lapse rate    [K/Pa]
*)
//double gsw_adiabatic_lapse_rate_from_ct(double sa, double ct, double p);
function gsw_adiabatic_lapse_rate_from_ct(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates the adiabatic lapse rate of ice.

t  =  in-situ temperature (ITS-90)                         [deg C]
p  =  sea pressure                                         [dbar]
( i.e. absolute pressure - 10.1325 dbar )

Note.  The output is in unit of degress Celsius per Pa,
(or equivilently K/Pa) not in units of K/dbar.
*)
//double gsw_adiabatic_lapse_rate_ice(double t, double p);
function gsw_adiabatic_lapse_rate_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates the thermal expansion coefficient of seawater with respect to
Conservative Temperature using the computationally-efficient 48-term
expression for density in terms of SA, CT and p (IOC et al., 2010)

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature                        [deg C]
p      : sea pressure                                    [dbar]

gsw_alpha : thermal expansion coefficient of seawater (48 term equation)
*)
// double gsw_alpha(double sa, double ct, double p);
function  gsw_alpha(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates alpha divided by beta, where alpha is the thermal expansion
coefficient and beta is the saline contraction coefficient of seawater
from Absolute Salinity and Conservative Temperature.  This function uses
the computationally-efficient expression for specific volume in terms of
SA, CT and p (Roquet et al., 2014).

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature                        [deg C]
p      : sea pressure                                    [dbar]

alpha_on_beta : thermal expansion coefficient 
                with respect to   [kg g^-1 K^-1]
Conservative Temperature divided by the saline
contraction coefficient at constant Conservative Temperature
*)
// double gsw_alpha_on_beta(double sa, double ct, double p);
function  gsw_alpha_on_beta(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates thermal expansion coefficient of seawater with respect to
in-situ temperature

sa     : Absolute Salinity                               [g/kg]
t      : insitu temperature                              [deg C]
p      : sea pressure                                    [dbar]

gsw_alpha_wrt_t_exact : thermal expansion coefficient    [1/K]
wrt (in-situ) temperature
*)
// double gsw_alpha_wrt_t_exact(double sa, double t, double p);
function  gsw_alpha_wrt_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates the thermal expansion coefficient of ice with respect to
in-situ temperature.

t  =  in-situ temperature (ITS-90)                       [deg C]
p  =  sea pressure                                       [dbar]
     ( i.e. absolute pressure - 10.1325 dbar )

alpha_wrt_t_ice  =  thermal expansion coefficient of ice with respect
                    to in-situ temperature               [1/K]
*)
// double gsw_alpha_wrt_t_ice(double t, double p);
function  gsw_alpha_wrt_t_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates saline (haline) contraction coefficient of seawater at
constant in-situ temperature.

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

beta_const_t_exact : haline contraction coefficient      [kg/g]
*)
// double gsw_beta_const_t_exact(double sa, double t, double p);
function  gsw_beta_const_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates the saline (i.e. haline) contraction coefficient of seawater
at constant Conservative Temperature using the computationally-efficient
expression for specific volume in terms of SA, CT and p
(Roquet et al., 2014).

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature (ITS-90)               [deg C]
p      : sea pressure                                    [dbar]
( i.e. absolute pressure - 10.1325 dbar )

beta   : saline contraction coefficient of seawater      [kg/g]
at constant Conservative Temperature
*)
// double gsw_beta(double sa, double ct, double p);
function  gsw_beta(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates the cabbeling coefficient of seawater with respect to
Conservative Temperature.  This function uses the computationally-
efficient expression for specific volume in terms of SA, CT and p
(Roquet et al., 2014).

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature (ITS-90)               [deg C]
p      : sea pressure                                    [dbar]

cabbeling  : cabbeling coefficient with respect to       [1/K^2]
Conservative Temperature.
*)
// double gsw_cabbeling(double sa, double ct, double p);
function  gsw_cabbeling(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates conductivity, C, from (SP,t,p) using PSS-78 in the range
2 < SP < 42.  If the input Practical Salinity is less than 2 then a
modified form of the Hill et al. (1986) fomula is used for Practical
Salinity.  The modification of the Hill et al. (1986) expression is to
ensure that it is exactly consistent with PSS-78 at SP = 2.

The conductivity ratio returned by this function is consistent with the
input value of Practical Salinity, SP, to 2x10^-14 psu over the full
range of input parameters (from pure fresh water up to SP = 42 psu).
This error of 2x10^-14 psu is machine precision at typical seawater
salinities.  This accuracy is achieved by having four different
polynomials for the starting value of Rtx (the square root of Rt) in
four different ranges of SP, and by using one and a half iterations of
a computationally efficient modified Newton-Raphson technique (McDougall
and Wotherspoon, 2012) to find the root of the equation.

Note that strictly speaking PSS-78 (Unesco, 1983) defines Practical
Salinity in terms of the conductivity ratio, R, without actually
specifying the value of C(35,15,0) (which we currently take to be
42.9140 mS/cm).

sp     : Practical Salinity                               [unitless]
t      : in-situ temperature [ITS-90]                     [deg C]
p      : sea pressure                                     [dbar]
c      : conductivity                                     [ mS/cm ]
*)
// double gsw_c_from_sp(double sp, double t, double p);
function  gsw_c_from_sp(sp, t, p:double):double; cdecl; external libgswteos;


(*
Calculates the chemical potential of water in ice from in-situ
temperature and pressure.

t  =  in-situ temperature (ITS-90)                              [deg C]
p  =  sea pressure                                              [dbar]
( i.e. absolute pressure - 10.1325 dbar )

chem_potential_water_ice  =  chemical potential of ice          [J/kg]
*)
// double gsw_chem_potential_water_ice(double t, double p);
function  gsw_chem_potential_water_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates the chemical potential of water in seawater.

SA  =  Absolute Salinity                                        [g/kg]
t   =  in-situ temperature (ITS-90)                             [deg C]
p   =  sea pressure                                             [dbar]
( i.e. absolute pressure - 10.1325 dbar )

chem_potential_water_t_exact  =  chemical potential of water 
                                 in seawater                    [J/g]
*)
// double gsw_chem_potential_water_t_exact(double sa, double t, double p);
function  gsw_chem_potential_water_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates the isobaric heat capacity of seawater.

t   =  in-situ temperature (ITS-90)                            [deg C]
p   =  sea pressure                                            [dbar]
( i.e. absolute pressure - 10.1325 dbar )

gsw_cp_ice  =  heat capacity of ice                            [J kg^-1 K^-1]
*)
// double gsw_cp_ice(double t, double p);
function  gsw_cp_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates isobaric heat capacity of seawater

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

gsw_cp_t_exact : heat capacity                           [J/(kg K)]
*)
// double gsw_cp_t_exact(double sa, double t, double p);
function  gsw_cp_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates the following two derivatives of Conservative Temperature
(1) CT_SA, the derivative with respect to Absolute Salinity at
constant potential temperature (with pr = 0 dbar), and
2) CT_pt, the derivative with respect to potential temperature
(the regular potential temperature which is referenced to 0 dbar)
at constant Absolute Salinity.

SA  =  Absolute Salinity                                        [ g/kg ]
pt  =  potential temperature (ITS-90)                          [ deg C ]
       (whose reference pressure is 0 dbar)

CT_SA  =  The derivative of Conservative Temperature with respect to
          Absolute Salinity at constant potential temperature
          (the regular potential temperature which has reference
          sea pressure of 0 dbar).
          The CT_SA output has units of:                     [ K/(g/kg)]
CT_pt  =  The derivative of Conservative Temperature with respect to
          potential temperature (the regular one with pr = 0 dbar)
          at constant SA. CT_pt is dimensionless.           [ unitless ]
*)
// void   gsw_ct_first_derivatives (double sa, double pt, double *ct_sa, double *ct_pt);
Procedure gsw_ct_first_derivatives (sa, pt: double; Var ct_sa, ct_pt: double); cdecl; external libgswteos;


(*
Calculates the following three derivatives of Conservative Temperature.
These derivatives are done with respect to in-situ temperature t (in the
case of CT_T_wrt_t) or at constant in-situ tempertature (in the cases of
CT_SA_wrt_t and CT_P_wrt_t).
(1) CT_SA_wrt_t, the derivative of CT with respect to Absolute Salinity
at constant t and p, and
(2) CT_T_wrt_t, derivative of CT with respect to in-situ temperature t
at constant SA and p.
(3) CT_P_wrt_t, derivative of CT with respect to pressure P (in Pa) at
constant SA and t.

This function uses the full Gibbs function. Note that this function
avoids the NaN that would exist in CT_SA_wrt_t at SA = 0 if it were
evaluated in the straightforward way from the derivatives of the Gibbs
function function.

SA  =  Absolute Salinity                                        [ g/kg ]
t   =  in-situ temperature (ITS-90)                            [ deg C ]
p   =  sea pressure                                             [ dbar ]
       ( i.e. absolute pressure - 10.1325 dbar)

CT_SA_wrt_t  =  The first derivative of Conservative Temperature with
                respect to Absolute Salinity at constant t and p.
                [ K/(g/kg)]  i.e. [ K kg/g ]
CT_T_wrt_t  =   The first derivative of Conservative Temperature with
                respect to in-situ temperature, t, at constant SA and p.
                [ unitless ]
CT_P_wrt_t  =   The first derivative of Conservative Temperature with
                respect to pressure P (in Pa) at constant SA and t.
                [ K/Pa ]
*)
// void   gsw_ct_first_derivatives_wrt_t_exact(double sa, double t, double p, double *ct_sa_wrt_t, double *ct_t_wrt_t, double *ct_p_wrt_t);


(*
Calculates the Conservative Temperature at which seawater freezes.  The
Conservative Temperature freezing point is calculated from the exact
in-situ freezing temperature which is found by a modified Newton-Raphson
iteration (McDougall and Wotherspoon, 2013) of the equality of the
chemical potentials of water in seawater and in ice.

An alternative GSW function, gsw_CT_freezing_poly, it is based on a
computationally-efficient polynomial, and is accurate to within -5e-4 K
and 6e-4 K, when compared with this function.

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction = the saturation fraction of dissolved air in
                      seawater

CT_freezing = Conservative Temperature at freezing of seawater [ deg C ]
*)
// double gsw_ct_freezing(double sa, double p, double saturation_fraction);
function  gsw_ct_freezing(sa, p, saturation_fraction:double):double; cdecl; external libgswteos;


(*
Calculates the first derivatives of the Conservative Temperature at
which seawater freezes, with respect to Absolute Salinity SA and
pressure P (in Pa).

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction = the saturation fraction of dissolved air in
                      seawater

CTfreezing_SA = the derivative of the Conservative Temperature at
                freezing (ITS-90) with respect to Absolute Salinity at
                fixed pressure              [ K/(g/kg) ] i.e. [ K kg/g ]

CTfreezing_P  = the derivative of the Conservative Temperature at
                freezing (ITS-90) with respect to pressure (in Pa) at
                fixed Absolute Salinity                         [ K/Pa ]
*)
// void   gsw_ct_freezing_first_derivatives(double sa, double p, double saturation_fraction, double *ctfreezing_sa, double *ctfreezing_p);
Procedure gsw_ct_freezing_first_derivatives(sa, p, saturation_fraction:double; Var ctfreezing_sa, ctfreezing_p:double); cdecl; external libgswteos;


(*
Calculates the first derivatives of the Conservative Temperature at
which seawater freezes, with respect to Absolute Salinity SA and
pressure P (in Pa) of the comptationally efficient polynomial fit of the
freezing temperature (McDougall et al., 2014).

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction = the saturation fraction of dissolved air in
                      seawater

CTfreezing_SA = the derivative of the Conservative Temperature at
                freezing (ITS-90) with respect to Absolute Salinity at
                fixed pressure              [ K/(g/kg) ] i.e. [ K kg/g]

CTfreezing_P  = the derivative of the Conservative Temperature at
                freezing (ITS-90) with respect to pressure (in Pa) at
                fixed Absolute Salinity                         [ K/Pa]
*)
// void   gsw_ct_freezing_first_derivatives_poly(double sa, double p, double saturation_fraction, double *ctfreezing_sa, double *ctfreezing_p);
Procedure gsw_ct_freezing_first_derivatives_poly(sa, p, saturation_fraction: double; Var ctfreezing_sa, ctfreezing_p: double); cdecl; external libgswteos;


(*
Calculates the Conservative Temperature at which seawater freezes.
The error of this fit ranges between -5e-4 K and 6e-4 K when compared
with the Conservative Temperature calculated from the exact in-situ
freezing temperature which is found by a Newton-Raphson iteration of the
equality of the chemical potentials of water in seawater and in ice.
Note that the Conservative temperature freezing temperature can be found
by this exact method using the function gsw_CT_freezing.

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction = the saturation fraction of dissolved air in
seawater

CT_freezing = Conservative Temperature at freezing of seawater [ deg C ]
That is, the freezing temperature expressed in
terms of Conservative Temperature (ITS-90).
*)
// double gsw_ct_freezing_poly(double sa, double p, double saturation_fraction);
function  gsw_ct_freezing_poly(sa, p, saturation_fraction:double):double; cdecl; external libgswteos;


(*
Calculates the Conservative Temperature of seawater, given the Absolute
Salinity, specific enthalpy, h, and pressure p.

SA  =  Absolute Salinity                                        [ g/kg ]
h   =  specific enthalpy                                        [ J/kg ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325d0 dbar )

CT  =  Conservative Temperature ( ITS-90)                      [ deg C ]
*)
// double gsw_ct_from_enthalpy(double sa, double h, double p);
function  gsw_ct_from_enthalpy(sa, h, p:double):double; cdecl; external libgswteos;


(*
Calculates the Conservative Temperature of seawater, given the Absolute
Salinity, specific enthalpy, h, and pressure p.

SA  =  Absolute Salinity                                        [ g/kg ]
h   =  specific enthalpy                                        [ J/kg ]
p   =  sea pressure                                             [ dbar ]
       ( i.e. absolute pressure - 10.1325d0 dbar )

CT  =  Conservative Temperature ( ITS-90)                      [ deg C ]
*)
// double gsw_ct_from_enthalpy_exact(double sa, double h, double p);
function  gsw_ct_from_enthalpy_exact(sa, h, p:double):double; cdecl; external libgswteos;


(*
Calculates Conservative Temperature with entropy as an input variable.

SA       =  Absolute Salinity                                   [ g/kg ]
entropy  =  specific entropy                                   [ deg C ]

CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
*)
// double gsw_ct_from_entropy(double sa, double entropy);
function  gsw_ct_from_entropy(sa, entropy:double):double; cdecl; external libgswteos;


(*
Calculates Conservative Temperature from potential temperature of seawater

sa      : Absolute Salinity                              [g/kg]
pt      : potential temperature with                     [deg C]
reference pressure of 0 dbar

gsw_ct_from_pt : Conservative Temperature                [deg C]
*)
// double gsw_ct_from_pt(double sa, double pt);
function  gsw_ct_from_pt(sa, pt:double):double; cdecl; external libgswteos;


(*
Calculates the Conservative Temperature of a seawater sample, for given
values of its density, Absolute Salinity and sea pressure (in dbar).

rho  =  density of a seawater sample (e.g. 1026 kg/m^3)       [ kg/m^3 ]
Note. This input has not had 1000 kg/m^3 subtracted from it.
That is, it is 'density', not 'density anomaly'.
SA   =  Absolute Salinity                                       [ g/kg ]
p    =  sea pressure                                            [ dbar ]
       ( i.e. absolute pressure - 10.1325 dbar )

CT  =  Conservative Temperature  (ITS-90)                      [ deg C ]
CT_multiple  =  Conservative Temperature  (ITS-90)             [ deg C ]

Note that at low salinities, in brackish water, there are two possible
Conservative Temperatures for a single density.  This programme will
output both valid solutions.  To see this second solution the user
must call the programme with two outputs (i.e. [CT,CT_multiple]), if
there is only one possible solution and the programme has been
called with two outputs the second variable will be set to NaN.
*)
// void   gsw_ct_from_rho(double rho, double sa, double p, double *ct, double *ct_multiple);
Procedure gsw_ct_from_rho(rho, sa, p:double; Var ct, ct_multiple:double); cdecl; external libgswteos;


(*
Calculates Conservative Temperature from in-situ temperature

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

gsw_ct_from_t : Conservative Temperature                 [deg C]
*)
// double gsw_ct_from_t(double sa, double t, double p);
function  gsw_ct_from_t(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates the Conservative Temperature of maximum density of seawater.
This function returns the Conservative temperature at which the density
of seawater is a maximum, at given Absolute Salinity, SA, and sea
pressure, p (in dbar).

SA =  Absolute Salinity                                         [ g/kg ]
p  =  sea pressure                                              [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

CT_maxdensity  =  Conservative Temperature at which            [ deg C ]
the density of seawater is a maximum for
given Absolute Salinity and pressure.
*)
// double gsw_ct_maxdensity(double sa, double p);
function  gsw_ct_maxdensity(sa, p:double):double; cdecl; external libgswteos;

//void   gsw_ct_second_derivatives(double sa, double pt, double *ct_sa_sa, double *ct_sa_pt, double *ct_pt_pt);


(*
Calculates the Absolute Salinity Anomaly atlas value, delta_SA_atlas.

 p      : sea pressure                                    [dbar]
 lon    : longiture                                       [deg E]
 lat    : latitude                                        [deg N]

 deltasa_atlas : Absolute Salinity Anomaly atlas value    [g/kg]
*)
// double gsw_deltasa_atlas(double p, double lon, double lat);
function  gsw_deltasa_atlas(p, lon, lat:double):double; cdecl; external libgswteos;


(*
Calculates Absolute Salinity Anomaly, deltaSA, from Practical Salinity, SP.

sp     : Practical Salinity                              [unitless]
p      : sea pressure                                    [dbar]
lon    : longitude                                       [deg E]
lat    : latitude                                        [deg N]

gsw_deltasa_from_sp : Absolute Salinty Anomaly           [g/kg]
*)
// double gsw_deltasa_from_sp(double sp, double p, double lon, double lat);
function  gsw_deltasa_from_sp(sp, p, lon, lat:double):double; cdecl; external libgswteos;


(*
Calculates the dilution coefficient of seawater.  The dilution
coefficient of seawater is defined as the Absolute Salinity times the
second derivative of the Gibbs function with respect to Absolute
Salinity, that is, SA.*g_SA_SA.

SA =  Absolute Salinity                                         [ g/kg ]
t  =  in-situ temperature (ITS-90)                             [ deg C ]
p  =  sea pressure                                              [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

dilution_coefficient_t_exact  =  dilution coefficient   [ (J/kg)(kg/g) ]
*)
// double gsw_dilution_coefficient_t_exact(double sa, double t, double p);
function  gsw_dilution_coefficient_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates dynamic enthalpy of seawater using the computationally-
efficient expression for specific volume in terms of SA, CT and p
(Roquet et al., 2014).  Dynamic enthalpy is defined as enthalpy minus
potential enthalpy (Young, 2010).

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature (ITS-90)               [deg C]
p      : sea pressure                                    [dbar]
( i.e. absolute pressure - 10.1325 dbar )

dynamic_enthalpy  :  dynamic enthalpy                    [J/kg]
*)
// double gsw_dynamic_enthalpy(double sa, double ct, double p);
function  gsw_dynamic_enthalpy(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates specific enthalpy of seawater from Absolute Salinity and
Conservative Temperature and pressure.

Note that this function uses the full Gibbs function.

SA  =  Absolute Salinity                                        [g/kg]
CT  =  Conservative Temperature (ITS-90)                        [deg C]
p   =  sea pressure                                             [dbar]
( i.e. absolute pressure - 10.1325 dbar )

enthalpy_CT_exact  =  specific enthalpy                         [J/kg]
*)
// double gsw_enthalpy_ct_exact(double sa, double ct, double p);
function  gsw_enthalpy_ct_exact(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates the difference of the specific enthalpy of seawater between
two different pressures, p_deep (the deeper pressure) and p_shallow
(the shallower pressure), at the same values of SA and CT.  This
function uses the computationally-efficient expression for specific
volume in terms of SA, CT and p (Roquet et al., 2014).  The output
(enthalpy_diff_CT) is the specific enthalpy evaluated at (SA,CT,p_deep)
minus the specific enthalpy at (SA,CT,p_shallow).

SA         =  Absolute Salinity                                 [ g/kg ]
CT         =  Conservative Temperature (ITS-90)                 [ deg C ]
p_shallow  =  upper sea pressure                                [ dbar ]
( i.e. shallower absolute pressure - 10.1325 dbar )
p_deep     =  lower sea pressure                                [ dbar ]
( i.e. deeper absolute pressure - 10.1325 dbar )

enthalpy_diff_CT  =  difference of specific enthalpy            [ J/kg ]
(deep minus shallow)
*)
// double gsw_enthalpy_diff(double sa, double ct, double p_shallow, double p_deep);
function  gsw_enthalpy_diff(sa, ct, p_shallow, p_deep:double):double; cdecl; external libgswteos;


(*
Calculates specific enthalpy of seawater using the computationally-
efficient expression for specific volume in terms of SA, CT and p
(Roquet et al., 2014).

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature (ITS-90)               [deg C]
p      : sea pressure                                    [dbar]
( i.e. absolute pressure - 10.1325 dbar )

enthalpy  :  specific enthalpy of seawater               [J/kg]
*)
// double gsw_enthalpy(double sa, double ct, double p);
function  gsw_enthalpy(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates the following two derivatives of specific enthalpy (h)
(1) h_SA, the derivative with respect to Absolute Salinity at
constant CT and p, and
(2) h_CT, derivative with respect to CT at constant SA and p.
Note that h_P is specific volume (1/rho) it can be calulated by calling
gsw_specvol_CT_exact(SA,CT,p). This function uses the full Gibbs function.

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )

h_SA  =  The first derivative of specific enthalpy with respect to
         Absolute Salinity at constant CT and p.
         [ J/(kg (g/kg))]  i.e. [ J/g ]
h_CT  =  The first derivative of specific enthalpy with respect to
         CT at constant SA and p.                           [ J/(kg K) ]
*)
// void   gsw_enthalpy_first_derivatives_ct_exact(double sa, double ct, double p, double *h_sa, double *h_ct);


(*
Calculates the following two derivatives of specific enthalpy (h) of
seawater using the computationally-efficient expression for
specific volume in terms of SA, CT and p (Roquet et al., 2014).
(1) h_SA, the derivative with respect to Absolute Salinity at
constant CT and p, and
(2) h_CT, derivative with respect to CT at constant SA and p.
Note that h_P is specific volume (1/rho) it can be caclulated by calling
gsw_specvol(SA,CT,p).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )

h_SA  =  The first derivative of specific enthalpy with respect to
         Absolute Salinity at constant CT and p.
         [ J/(kg (g/kg))]  i.e. [ J/g ]
h_CT  =  The first derivative of specific enthalpy with respect to
         CT at constant SA and p.                           [ J/(kg K) ]
*)
// void   gsw_enthalpy_first_derivatives(double sa, double ct, double p, double *h_sa, double *h_ct);



(*
Calculates the specific enthalpy of ice (h_Ih).

t  =  in-situ temperature (ITS-90)                             [ deg C ]
p  =  sea pressure                                              [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

gsw_enthalpy_ice  :  specific enthalpy of ice                   [ J/kg ]
*)
// double gsw_enthalpy_ice(double t, double p);
function  gsw_enthalpy_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates three second-order derivatives of specific enthalpy (h).
Note that this function uses the full Gibbs function.

sa  =  Absolute Salinity                                        [ g/kg ]
ct  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )

h_sa_sa  =  The second derivative of specific enthalpy with respect to
            Absolute Salinity at constant ct & p.    [ J/(kg (g/kg)^2) ]
h_sa_ct  =  The second derivative of specific enthalpy with respect to
            sa and ct at constant p.                  [ J/(kg K(g/kg)) ]
h_ct_ct  =  The second derivative of specific enthalpy with respect to
            ct at constant sa and p.                      [ J/(kg K^2) ]
*)
// void   gsw_enthalpy_second_derivatives_ct_exact(double sa, double ct, double p, double *h_sa_sa, double *h_sa_ct, double *h_ct_ct);


(*
Calculates the following three second-order derivatives of specific
enthalpy (h),using the computationally-efficient expression for
specific volume in terms of SA, CT and p (Roquet et al., 2014).
(1) h_SA_SA, second-order derivative with respect to Absolute Salinity
at constant CT & p.
(2) h_SA_CT, second-order derivative with respect to SA & CT at
constant p.
(3) h_CT_CT, second-order derivative with respect to CT at constant SA
and p.

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )

h_SA_SA  =  The second derivative of specific enthalpy with respect to
            Absolute Salinity at constant CT & p.    [ J/(kg (g/kg)^2) ]
h_SA_CT  =  The second derivative of specific enthalpy with respect to
            SA and CT at constant p.                  [ J/(kg K(g/kg)) ]
h_CT_CT  =  The second derivative of specific enthalpy with respect to
            CT at constant SA and p.                      [ J/(kg K^2) ]
*)
// void   gsw_enthalpy_second_derivatives(double sa, double ct, double p, double *h_sa_sa, double *h_sa_ct, double *h_ct_ct);



(*
This function calculates enthalpy at the Standard Ocean Salinity, SSO,
and at a Conservative Temperature of zero degrees C, as a function of
pressure, p, in dbar, using a streamlined version of the
computationally-efficient expression for specific volume, that is, a
streamlined version of the code "gsw_enthalpy(SA,CT,p)".

p      : sea pressure                                    [dbar]

enthalpy_sso_0 : enthalpy(sso,0,p)
*)
// double gsw_enthalpy_sso_0(double p);
function  gsw_enthalpy_sso_0(p:double):double; cdecl; external libgswteos;


(*
Calculates the specific enthalpy of seawater

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

gsw_enthalpy_t_exact : specific enthalpy                 [J/kg]
*)
// double gsw_enthalpy_t_exact(double sa, double t, double p);
function  gsw_enthalpy_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates the following two partial derivatives of specific entropy
(eta)
(1) eta_SA, the derivative with respect to Absolute Salinity at
constant Conservative Temperature, and
(2) eta_CT, the derivative with respect to Conservative Temperature at
constant Absolute Salinity.

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]

eta_SA =  The derivative of specific entropy with respect to
Absolute Salinity (in units of g kg^-1) at constant
Conservative Temperature.
eta_SA has units of:         [ J/(kg K(g/kg))]  or [ J/(g K) ]
eta_CT =  The derivative of specific entropy with respect to
Conservative Temperature at constant Absolute Salinity.
eta_CT has units of:                            [ J/(kg K^2) ]
*)
// void   gsw_entropy_first_derivatives(double sa, double ct, double *eta_sa, double *eta_ct);



(*
Calculates specific entropy of seawater from Conservative Temperature.

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]

entropy  =  specific entropy                                   [ deg C ]
*)
// double gsw_entropy_from_ct(sa, ct)
function  gsw_entropy_from_ct(sa, ct:double):double; cdecl; external libgswteos;


(*
Calculates specific entropy of seawater.

SA  =  Absolute Salinity                                        [ g/kg ]
pt  =  potential temperature (ITS-90)                          [ deg C ]

entropy  =  specific entropy                                [ J/(kg*K) ]
*)
// double gsw_entropy_from_pt(double sa, double pt);
function  gsw_entropy_from_pt(sa, pt:double):double; cdecl; external libgswteos;


(*
Calculates the specific entropy of seawater

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

gsw_entropy_from_t : specific entropy                    [J/(kg K)]
*)
// double gsw_entropy_from_t(double sa, double t, double p);
function  gsw_entropy_from_t(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates specific entropy of ice.

t  =  in-situ temperature (ITS-90)                             [ deg C ]
p  =  sea pressure                                              [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

ice_entropy  =  specific entropy of ice                 [ J kg^-1 K^-1 ]
*)
// double gsw_entropy_ice(double t, double p);
function  gsw_entropy_ice(t, p:double):double; cdecl; external libgswteos;


(*
Entropy minus the terms that are a function of only SA

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

entropy_part : entropy part
*)
// double gsw_entropy_part(double sa, double t, double p);
function  gsw_entropy_part(sa, t, p:double):double; cdecl; external libgswteos;


(*
Entropy part evaluated at the sea surface

sa     : Absolute Salinity                               [g/kg]
pt0    : insitu temperature                              [deg C]

entropy_part_zerop : entropy part at the sea surface
*)
// double gsw_entropy_part_zerop(double sa, double pt0);
function  gsw_entropy_part_zerop(sa, pt0:double):double; cdecl; external libgswteos;


(*
Calculates the following three second-order partial derivatives of
specific entropy (eta)
(1) eta_SA_SA, the second derivative with respect to Absolute
Salinity at constant Conservative Temperature, and
(2) eta_SA_CT, the derivative with respect to Absolute Salinity and
Conservative Temperature.
(3) eta_CT_CT, the second derivative with respect to Conservative
Temperature at constant Absolute Salinity.

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]

eta_SA_SA =  The second derivative of specific entropy with respect
to Absolute Salinity (in units of g kg^-1) at constant
Conservative Temperature.
eta_SA_SA has units of:                 [ J/(kg K(g/kg)^2)]
eta_SA_CT =  The second derivative of specific entropy with respect
to Conservative Temperature at constant Absolute
Salinity. eta_SA_CT has units of:     [ J/(kg (g/kg) K^2) ]
eta_CT_CT =  The second derivative of specific entropy with respect
to Conservative Temperature at constant Absolute
Salinity.  eta_CT_CT has units of:           [ J/(kg K^3) ]
*)
// void   gsw_entropy_second_derivatives(double sa, double ct, double *eta_sa_sa, double *eta_sa_ct, double *eta_ct_ct);



(*
Calculates fdelta.

p      : sea pressure                                    [dbar]
lon    : longitude                                       [deg E]
lat    : latitude                                        [deg N]

gsw_fdelta : Absolute Salinty Anomaly                    [unitless]

*)
// double gsw_fdelta(double p, double lon, double lat);
function  gsw_fdelta(p, lon, lat:double):double; cdecl; external libgswteos;


(*
Calculates the mass fraction of ice (mass of ice divided by mass of ice
plus seawater), w_Ih_final, which results from given values of the bulk
Absolute Salinity, SA_bulk, bulk enthalpy, h_bulk, occuring at pressure
p.  The final values of Absolute Salinity, SA_final, and Conservative
Temperature, CT_final, of the interstitial seawater phase are also
returned.  This code assumes that there is no dissolved air in the
seawater (that is, saturation_fraction is assumed to be zero
throughout the code).

When the mass fraction w_Ih_final is calculated as being a positive
value, the seawater-ice mixture is at thermodynamic equlibrium.

This code returns w_Ih_final = 0 when the input bulk enthalpy, h_bulk,
is sufficiently large (i.e. sufficiently "warm") so that there is no ice
present in the final state.  In this case the final state consists of
only seawater rather than being an equlibrium mixture of seawater and
ice which occurs when w_Ih_final is positive.  Note that when
w_Ih_final = 0, the final seawater is not at the freezing temperature.

SA_bulk =  bulk Absolute Salinity of the seawater and ice mixture
[ g/kg ]
h_bulk  =  bulk enthalpy of the seawater and ice mixture        [ J/kg ]
p       =  sea pressure                                         [ dbar ]
          ( i.e. absolute pressure - 10.1325 dbar )

SA_final    =  Absolute Salinity of the seawater in the final state,
               whether or not any ice is present.               [ g/kg ]
CT_final    =  Conservative Temperature of the seawater in the the final
               state, whether or not any ice is present.       [ deg C ]
w_Ih_final  =  mass fraction of ice in the final seawater-ice mixture.
               If this ice mass fraction is positive, the system is at
               thermodynamic equilibrium.  If this ice mass fraction is
               zero there is no ice in the final state which consists
               only of seawater which is warmer than the freezing
               temperature.                                   [unitless]
*)
// void   gsw_frazil_properties(double sa_bulk, double h_bulk, double p, double *sa_final, double *ct_final, double *w_ih_final);



(*
Calculates the mass fraction of ice (mass of ice divided by mass of ice
plus seawater), w_Ih_final, which results from given values of the bulk
Absolute Salinity, SA_bulk, bulk potential enthalpy, h_pot_bulk,
occuring at pressure p.  The final equilibrium values of Absolute
Salinity, SA_final, and Conservative Temperature, CT_final, of the
interstitial seawater phase are also returned.  This code assumes that
there is no dissolved air in the seawater (that is, saturation_fraction
is assumed to be zero thoughout the code).

When the mass fraction w_Ih_final is calculated as being a positive
value, the seawater-ice mixture is at thermodynamic equlibrium.

This code returns w_Ih_final = 0 when the input bulk enthalpy, h_bulk,
is sufficiently large (i.e. sufficiently "warm") so that there is no ice
present in the final state.  In this case the final state consists of
only seawater rather than being an equlibrium mixture of seawater and
ice which occurs when w_Ih_final is positive.  Note that when
w_Ih_final = 0, the final seawater is not at the freezing temperature.

Note that this code uses the exact forms of CT_freezing and
pot_enthalpy_ice_freezing.

SA_bulk     =  bulk Absolute Salinity of the seawater and ice mixture
               [ g/kg ]
h_pot_bulk  =  bulk potential enthalpy of the seawater and ice mixture
               [ J/kg ]
p           =  sea pressure                                  [ dbar ]
              ( i.e. absolute pressure - 10.1325 dbar )

SA_final    =  Absolute Salinity of the seawater in the final state,
               whether or not any ice is present.               [ g/kg ]
CT_final    =  Conservative Temperature of the seawater in the the final
               state, whether or not any ice is present.       [ deg C ]
w_Ih_final  =  mass fraction of ice in the final seawater-ice mixture.
               If this ice mass fraction is positive, the system is at
               thermodynamic equilibrium.  If this ice mass fraction is
               zero there is no ice in the final state which consists
               only of seawater which is warmer than the freezing
               temperature.                                   [unitless]
*)
// void   gsw_frazil_properties_potential(double sa_bulk, double h_pot_bulk, double p, double *sa_final, double *ct_final, double *w_ih_final);



(*
Calculates the mass fraction of ice (mass of ice divided by mass of ice
plus seawater), w_Ih_final, which results from given values of the bulk
Absolute Salinity, SA_bulk, bulk potential enthalpy, h_pot_bulk,
occuring at pressure p.  The final equilibrium values of Absolute
Salinity, SA_final, and Conservative Temperature, CT_final, of the
interstitial seawater phase are also returned.  This code assumes that
there is no dissolved air in the seawater (that is, saturation_fraction
is assumed to be zero thoughout the code).

When the mass fraction w_Ih_final is calculated as being a positive
value, the seawater-ice mixture is at thermodynamic equlibrium.

This code returns w_Ih_final = 0 when the input bulk enthalpy, h_bulk,
is sufficiently large (i.e. sufficiently "warm") so that there is no ice
present in the final state.  In this case the final state consists of
only seawater rather than being an equlibrium mixture of seawater and
ice which occurs when w_Ih_final is positive.  Note that when
w_Ih_final = 0, the final seawater is not at the freezing temperature.

Note that this code uses the polynomial forms of CT_freezing and
pot_enthalpy_ice_freezing. This code is intended to be used in ocean
models where the model prognostic variables are SA_bulk and h_pot_bulk.

SA_bulk     =  bulk Absolute Salinity of the seawater and ice mixture
               [ g/kg ]
h_pot_bulk  =  bulk potential enthalpy of the seawater and ice mixture
               [ J/kg ]
p           =  sea pressure                                  [ dbar ]
              ( i.e. absolute pressure - 10.1325 dbar )

SA_final    =  Absolute Salinity of the seawater in the final state,
               whether or not any ice is present.               [ g/kg ]
CT_final    =  Conservative Temperature of the seawater in the the final
               state, whether or not any ice is present.       [ deg C ]
w_Ih_final  =  mass fraction of ice in the final seawater-ice mixture.
               If this ice mass fraction is positive, the system is at
               thermodynamic equilibrium.  If this ice mass fraction is
               zero there is no ice in the final state which consists
               only of seawater which is warmer than the freezing
               temperature.                                   [unitless]
*)
// void   gsw_frazil_properties_potential_poly(double sa_bulk, double h_pot_bulk, double p, double *sa_final, double *ct_final, double *w_ih_final);



(*
Calculates the ratios of SA, CT and P changes when frazil ice forms or
melts in response to an adiabatic change in pressure of a mixture of
seawater and frazil ice crystals.

Note that the first output, dSA_dCT_frazil, is dSA/dCT rather than
dCT/dSA.  This is done so that when SA = 0, the output, dSA/dCT, is zero
whereas dCT/dSA would then be infinite.

Also note that both dSA_dP_frazil and dCT_dP_frazil are the pressure
derivatives with the pressure measured in Pa not dbar.

SA  =  Absolute Salinity of seawater                            [ g/kg ]
p   =  sea pressure of seawater at which melting occurs         [ dbar ]
       ( i.e. absolute pressure - 10.1325d0 dbar )
w_Ih  =  mass fraction of ice, that is the mass of ice divided by the
         sum of the masses of ice and seawater.  That is, the mass of
         ice divided by the mass of the final mixed fluid.
         w_Ih must be between 0 and 1.                      [ unitless ]

dSA_dCT_frazil =  the ratio of the changes in Absolute Salinity
                  to that of Conservative Temperature       [ g/(kg K) ]
dSA_dP_frazil  =  the ratio of the changes in Absolute Salinity
                  to that of pressure (in Pa)              [ g/(kg Pa) ]
dCT_dP_frazil  =  the ratio of the changes in Conservative Temperature
                  to that of pressure (in Pa)                   [ K/Pa ]
*)
// void   gsw_frazil_ratios_adiabatic(double sa, double p, double w_ih, double *dsa_dct_frazil, double *dsa_dp_frazil, double *dct_dp_frazil);


(*
Calculates the ratios of SA, CT and P changes when frazil ice forms or
melts in response to an adiabatic change in pressure of a mixture of
seawater and frazil ice crystals.

Note that the first output, dSA_dCT_frazil, is dSA/dCT rather than
dCT/dSA.  This is done so that when SA = 0, the output, dSA/dCT, is zero
whereas dCT/dSA would then be infinite.

Also note that both dSA_dP_frazil and dCT_dP_frazil are the pressure
derivatives with the pressure measured in Pa not dbar.

SA  =  Absolute Salinity of seawater                            [ g/kg ]
p   =  sea pressure of seawater at which melting occurs         [ dbar ]
       ( i.e. absolute pressure - 10.1325d0 dbar )
w_Ih  =  mass fraction of ice, that is the mass of ice divided by the
         sum of the masses of ice and seawater.  That is, the mass of
         ice divided by the mass of the final mixed fluid.
         w_Ih must be between 0 and 1.                      [ unitless ]

dSA_dCT_frazil =  the ratio of the changes in Absolute Salinity
                  to that of Conservative Temperature       [ g/(kg K) ]
dSA_dP_frazil  =  the ratio of the changes in Absolute Salinity
                  to that of pressure (in Pa)              [ g/(kg Pa) ]
dCT_dP_frazil  =  the ratio of the changes in Conservative Temperature
                  to that of pressure (in Pa)                   [ K/Pa ]
*)
// void   gsw_frazil_ratios_adiabatic_poly(double sa, double p, double w_ih, double *dsa_dct_frazil, double *dsa_dp_frazil, double *dct_dp_frazil);


(*
Calculates dynamic height anomaly as the integral of specific volume
anomaly from the pressure p of the bottle to the reference pressure
p_ref.

Hence, geo_strf_dyn_height is the dynamic height anomaly with respect
to a given reference pressure.  This is the geostrophic streamfunction
for the difference between the horizontal velocity at the pressure
concerned, p, and the horizontal velocity at p_ref.  Dynamic height
anomaly is the geostrophic streamfunction in an isobaric surface.  The
reference values used for the specific volume anomaly are
SSO = 35.16504 g/kg and CT = 0 deg C.  This function calculates
specific volume anomaly using the computationally efficient
expression for specific volume of Roquet et al. (2015).

This function evaluates the pressure integral of specific volume using
SA and CT interpolated with respect to pressure using the method of
Reiniger and Ross (1968).  It uses a weighted mean of (i) values
obtained from linear interpolation of the two nearest data points, and
(ii) a linear extrapolation of the pairs of data above and below.  This
"curve fitting" method resembles the use of cubic splines.

SA    =  Absolute Salinity                                      [ g/kg ]
CT    =  Conservative Temperature (ITS-90)                     [ deg C ]
p     =  sea pressure                                           [ dbar ]
         ( i.e. absolute pressure - 10.1325 dbar )
p_ref =  reference pressure                                     [ dbar ]
         ( i.e. reference absolute pressure - 10.1325 dbar )

geo_strf_dyn_height  =  dynamic height anomaly               [ m^2/s^2 ]
Note. If p_ref exceeds the pressure of the deepest bottle on a
vertical profile, the dynamic height anomaly for each bottle
on the whole vertical profile is returned as NaN.
*)
// double *gsw_geo_strf_dyn_height(double *sa, double *ct, double *p, double p_ref, int n_levels, double *dyn_height);



(*
Calculates dynamic height anomaly as the integral of specific volume
anomaly from the pressure p of the bottle to the reference pressure
p_ref.

Hence, geo_strf_dyn_height is the dynamic height anomaly with respect
to a given reference pressure.  This is the geostrophic streamfunction
for the difference between the horizontal velocity at the pressure
concerned, p, and the horizontal velocity at p_ref.  Dynamic height
anomaly is the geostrophic streamfunction in an isobaric surface.  The
reference values used for the specific volume anomaly are
SSO = 35.16504 g/kg and CT = 0 deg C.  This function calculates
specific volume anomaly using the computationally efficient
expression for specific volume of Roquet et al. (2015).

This function evaluates the pressure integral of specific volume using
SA and CT interpolated with respect to pressure. The interpolation method
may be chosen as linear or "PCHIP", piecewise cubic Hermite using a shape-
preserving algorithm for setting the derivatives.

SA    =  Absolute Salinity                                      [ g/kg ]
CT    =  Conservative Temperature (ITS-90)                     [ deg C ]
p     =  sea pressure  (increasing with index)                  [ dbar ]
         ( i.e. absolute pressure - 10.1325 dbar )
nz    =  number of points in each array
p_ref =  reference pressure                                     [ dbar ]
         ( i.e. reference absolute pressure - 10.1325 dbar )
geo_strf_dyn_height  =  dynamic height anomaly               [ m^2/s^2 ]
max_dp_i = maximum pressure difference between points for triggering
            interpolation.
interp_method = 1 for linear, 2 for PCHIP

Note. If p_ref falls outside the range of a vertical profile, the dynamic height
anomaly for each bottle on the whole vertical profile is returned as NaN.
*)
// double *gsw_geo_strf_dyn_height_pc(double *sa, double *ct, double *delta_p, int n_levels, double *geo_strf_dyn_height_pc, double *p_mid);



(*
Ice specific Gibbs energy and derivatives up to order 2.

nt  =  order of t derivative                      [ integers 0, 1 or 2 ]
np  =  order of p derivative                      [ integers 0, 1 or 2 ]
t   =  in-situ temperature (ITS-90)                            [ deg C ]
p   =  sea pressure                                             [ dbar ]

gibbs_ice = Specific Gibbs energy of ice or its derivatives.

The Gibbs energy (when nt = np = 0) has units of:     [J/kg]
The temperature derivatives are output in units of:   [(J/kg) (K)^(-nt)]
The pressure derivatives are output in units of:      [(J/kg) (Pa)^(-np)]
The mixed derivatives are output in units of:         [(J/kg) (K)^(-nt) (Pa)^(-np)]

Note. The derivatives are taken with respect to pressure in Pa, not
withstanding that the pressure input into this routine is in dbar.
*)
// double gsw_gibbs_ice (int nt, int np, double t, double p);
function  gsw_gibbs_ice(nt, np: integer; t, p:double):double; cdecl; external libgswteos;


(*
part of the the first temperature derivative of Gibbs energy of ice
that is the outout is gibbs_ice(1,0,t,p) + S0

t   =  in-situ temperature (ITS-90)                            [ deg C ]
p   =  sea pressure                                             [ dbar ]

gibbs_ice_part_t = part of temperature derivative       [ J kg^-1 K^-1 ]
*)
// double gsw_gibbs_ice_part_t(double t, double p);
function  gsw_gibbs_ice_part_t(t, p:double):double; cdecl; external libgswteos;


(*
Part of the the first temperature derivative of Gibbs energy of ice
that is the outout is "gibbs_ice(1,0,pt0,0) + s0"

pt0  =  potential temperature with reference sea pressure of zero dbar

gsw_gibbs_ice_pt0 = part of temperature derivative     [ J kg^-1 K^-1 ]
*)
// double gsw_gibbs_ice_pt0(double pt0);
function  gsw_gibbs_ice_pt0(pt0:double):double; cdecl; external libgswteos;


(*
The second temperature derivative of Gibbs energy of ice at the
potential temperature with reference sea pressure of zero dbar.  That is
the output is gibbs_ice(2,0,pt0,0).

pt0  =  potential temperature with reference sea pressure of zero dbar

gsw_gibbs_ice_pt0_pt0 = temperature second derivative at pt0
*)
// double gsw_gibbs_ice_pt0_pt0(double pt0);
function  gsw_gibbs_ice_pt0_pt0(pt0:double):double; cdecl; external libgswteos;


(*
Seawater specific Gibbs free energy and derivatives up to order 2

ns     : order of s derivative
nt     : order of t derivative
np     : order of p derivative
sa     : Absolute Salinity                               [g/kg]
t      : temperature                                     [deg C]
p      : sea pressure                                    [dbar]
-1
gsw_gibbs  : specific Gibbs energy or its derivative     [J kg  ]
*)
// double gsw_gibbs(int ns, int nt, int np, double sa, double t, double p);
function  gsw_gibbs(ns, nt, np: integer; sa, t, p:double):double; cdecl; external libgswteos;


(*
gibbs_tt at (sa,pt,0)

sa     : Absolute Salinity                            [g/kg]
pt0    : potential temperature                        [deg C]

gibbs_pt0_pt0 : gibbs_tt at (sa,pt,0)
*)
// double gsw_gibbs_pt0_pt0(double sa, double pt0);
function  gsw_gibbs_pt0_pt0(sa, pt0:double):double; cdecl; external libgswteos;


(*
Calculates acceleration due to gravity as a function of latitude and as
a function of pressure in the ocean.

lat  =  latitude in decimal degress north                [ -90 ... +90 ]
p    =  sea pressure                                     [ dbar ]

grav : grav  =  gravitational acceleration               [ m s^-2 ]
*)
// double gsw_grav(double lat, double p);
function  gsw_grav(lat, p:double):double; cdecl; external libgswteos;


(*
Calculates the Helmholtz energy of ice.

t  =  in-situ temperature (ITS-90)                             [ deg C ]
p  =  sea pressure                                              [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

Helmholtz_energy_ice  =  Helmholtz energy of ice                [ J/kg ]
*)
// double gsw_helmholtz_energy_ice(double t, double p);
function  gsw_helmholtz_energy_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates the Hill ratio, which is the adjustment needed to apply for
Practical Salinities smaller than 2.  This ratio is defined at a
Practical Salinity = 2 and in-situ temperature, t using PSS-78. The Hill
ratio is the ratio of 2 to the output of the Hill et al. (1986) formula
for Practical Salinity at the conductivity ratio, Rt, at which Practical
Salinity on the PSS-78 scale is exactly 2.

t                 : in-situ temperature (ITS-90)              [deg C]
hill_ratio_at_sp2 : Hill ratio                                [dimensionless]
*)
// double gsw_hill_ratio_at_sp2(double t);
function  gsw_hill_ratio_at_sp2(t:double):double; cdecl; external libgswteos;


(*
Calculates the mass fraction of ice (mass of ice divided by mass of ice
plus seawater), which, when melted into seawater having (SA,CT,p) causes
the final dilute seawater to be at the freezing temperature.  The other
outputs are the Absolute Salinity and Conservative Temperature of the
final diluted seawater.

SA   =  Absolute Salinity of seawater                           [ g/kg ]
CT   =  Conservative Temperature of seawater (ITS-90)          [ deg C ]
p    =  sea pressure                                            [ dbar ]
        ( i.e. absolute pressure - 10.1325d0 dbar )
t_Ih =  in-situ temperature of the ice at pressure p (ITS-90)  [ deg C ]

SA_freeze = Absolute Salinity of seawater after the mass fraction of
            ice, ice_fraction, at temperature t_Ih has melted into the
            original seawater, and the final mixture is at the freezing
            temperature of seawater.                            [ g/kg ]

CT_freeze = Conservative Temperature of seawater after the mass
            fraction, w_Ih, of ice at temperature t_Ih has melted into
            the original seawater, and the final mixture is at the
            freezing temperature of seawater.                  [ deg C ]

w_Ih      = mass fraction of ice, having in-situ temperature t_Ih,
            which, when melted into seawater at (SA,CT,p) leads to the
            final diluted seawater being at the freezing temperature.
            This output must be between 0 and 1.              [unitless]
*)
// void   gsw_ice_fraction_to_freeze_seawater(double sa, double ct, double p, double t_ih, double *sa_freeze, double *ct_freeze, double *w_ih);



(*
Calculates internal energy of seawater.

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature (ITS-90)               [deg C]
p      : sea pressure                                    [dbar]

internal_energy  :  internal_energy of seawater          [J/kg]
*)
// double gsw_internal_energy(double sa, double ct, double p);
function  gsw_internal_energy(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates the specific internal energy of ice.

t  =  in-situ temperature (ITS-90)                        [deg C]
p  =  sea pressure                                        [dbar]
( i.e. absolute pressure - 10.1325 dbar )

internal_energy_ice  =  specific internal energy (u)      [J/kg]
*)
// double gsw_internal_energy_ice(double t, double p);
function  gsw_internal_energy_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates the ratio of the vertical gradient of potential density to
the vertical gradient of locally-referenced potential density.  This
ratio is also the ratio of the planetary Isopycnal Potential Vorticity
(IPV) to f times N^2, hence the name for this variable,
IPV_vs_fNsquared_ratio (see Eqn. (3.20.5) of IOC et al. (2010)).
The reference sea pressure, p_ref, of the potential density surface must
have a constant value.

IPV_vs_fNsquared_ratio is evaluated at the mid pressure between the
individual data points in the vertical.

sa      : Absolute Salinity         (a profile (length nz))     [g/kg]
ct      : Conservative Temperature  (a profile (length nz))     [deg C]
p       : sea pressure              (a profile (length nz))     [dbar]
p_ref   : reference sea pressure of the potential density surface
         ( i.e. absolute reference pressure - 10.1325 dbar )      [dbar]
nz      : number of bottles
IPV_vs_fNsquared_ratio : The ratio of the vertical gradient of potential
                         density referenced to p_ref, to the vertical gradient
                         of locally-referenced potential density.  It is ouput
                         on the same vertical (M-1)xN grid as p_mid.
                         IPV_vs_fNsquared_ratio is dimensionless.  [ unitless ]
p_mid   : Mid pressure between p grid  (length nz-1)           [dbar]
*)
// void   gsw_ipv_vs_fnsquared_ratio(double *sa, double *ct, double *p, double p_ref, int nz, double *ipv_vs_fnsquared_ratio, double *p_mid);



(*
Calculates isothermal compressibility of ice.
Note. This is the compressibility of ice AT CONSTANT IN-SITU
TEMPERATURE

t  =  in-situ temperature (ITS-90)                             [ deg C ]
p  =  sea pressure                                              [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

kappa_const_t_ice  =  isothermal compressibility                [ 1/Pa ]
Note. The output units are 1/Pa not 1/dbar.
*)
// double gsw_kappa_const_t_ice(double t, double p);
function  gsw_kappa_const_t_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates isentropic compressibility of seawater.  This function
has inputs of Absolute Salinity and Conservative Temperature.  This
function uses the computationally-efficient expression for
specific volume in terms of SA, CT and p (Roquet et al., 2014).

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature (ITS-90)               [deg C]
p      : sea pressure                                    [dbar]

kappa  :  isentropic compressibility                     [1.0/Pa]
*)
// double gsw_kappa(double sa, double ct, double p);
function  gsw_kappa(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates the isentropic compressibility of ice.

t  =  in-situ temperature (ITS-90)                             [ deg C ]
p  =  sea pressure                                              [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

kappa_ice  =  isentropic compressibility                        [ 1/Pa ]
Note. The output units are 1/Pa not 1/dbar.
*)
// double gsw_kappa_ice(double t, double p);
function  gsw_kappa_ice(t, p:double):double; cdecl; external libgswteos;


(*
isentropic compressibility of seawater

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

gsw_kappa_t_exact : isentropic compressibility           [1/Pa]
*)
// double gsw_kappa_t_exact(double sa, double t, double p);
function  gsw_kappa_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates latent heat, or enthalpy, of evaporation.

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature                        [deg C]

latentheat_evaporation : latent heat of evaporation      [J/kg]
*)
// double gsw_latentheat_evap_ct(double sa, double ct);
function  gsw_latentheat_evap_ct(sa, ct:double):double; cdecl; external libgswteos;


(*
Calculates latent heat, or enthalpy, of evaporation.

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]

gsw_latentheat_evap_t : latent heat of evaporation       [J/kg]
*)
// double gsw_latentheat_evap_t(double sa, double t);
function  gsw_latentheat_evap_t(sa, t:double):double; cdecl; external libgswteos;


(*
Calculates latent heat, or enthalpy, of melting.

sa     : Absolute Salinity                               [g/kg]
p      : sea pressure                                    [dbar]

latentheat_melting : latent heat of melting              [kg/m^3]
*)
// double gsw_latentheat_melting(double sa, double p);
function  gsw_latentheat_melting(sa, p:double):double; cdecl; external libgswteos;



(*
This function interpolates the cast with respect to the interpolating
variable p. This function finds the values of SA, CT at p_i on this cast.
VERSION NUMBER: 3.05 (27th January 2015)

This function was adapted from Matlab's interp1q.
*)
// void   gsw_linear_interp_sa_ct(double *sa, double *ct, double *p, int np, double *p_i, int npi, double *sa_i, double *ct_i);




(*
Calculates the ratio of SA to CT changes when ice melts into seawater
with both the seawater and the seaice temperatures being almost equal to
the equilibrium freezing temperature.  It is assumed that a small mass
of ice melts into an infinite mass of seawater.  If indeed the
temperature of the seawater and the ice were both equal to the freezing
temperature, then no melting or freezing would occur an imbalance
between these three temperatures is needed for freezing or melting to
occur (the three temperatures being (1) the seawater temperature,
(2) the ice temperature, and (3) the freezing temperature.

The output, melting_ice_equilibrium_SA_CT_ratio, is dSA/dCT rather than
dCT/dSA.  This is done so that when SA = 0, the output, dSA/dCT is zero
whereas dCT/dSA would be infinite.

SA  =  Absolute Salinity of seawater                            [ g/kg ]
p   =  sea pressure at which the melting occurs                 [ dbar ]
( i.e. absolute pressure - 10.1325d0 dbar )

melting_ice_equilibrium_SA_CT_ratio = the ratio dSA/dCT of SA to CT
changes when ice melts into seawater, with
the seawater and seaice being close to the
freezing temperature.         [ g/(kg K) ]
*)
// double gsw_melting_ice_equilibrium_sa_ct_ratio(double sa, double p);
function  gsw_melting_ice_equilibrium_sa_ct_ratio(sa, p:double):double; cdecl; external libgswteos;


(*
Calculates the ratio of SA to CT changes when ice melts into seawater
with both the seawater and the seaice temperatures being almost equal to
the equilibrium freezing temperature.  It is assumed that a small mass
of ice melts into an infinite mass of seawater.  If indeed the
temperature of the seawater and the ice were both equal to the freezing
temperature, then no melting or freezing would occur an imbalance
between these three temperatures is needed for freezing or melting to
occur (the three temperatures being (1) the seawater temperature,
(2) the ice temperature, and (3) the freezing temperature.

The output, melting_ice_equilibrium_SA_CT_ratio, is dSA/dCT rather than
dCT/dSA.  This is done so that when SA = 0, the output, dSA/dCT is zero
whereas dCT/dSA would be infinite.

SA  =  Absolute Salinity of seawater                            [ g/kg ]
p   =  sea pressure at which the melting occurs                 [ dbar ]
( i.e. absolute pressure - 10.1325d0 dbar )

melting_ice_equilibrium_SA_CT_ratio = the ratio dSA/dCT of SA to CT
changes when ice melts into seawater, with
the seawater and seaice being close to the
freezing temperature.         [ g/(kg K) ]
*)
// double gsw_melting_ice_equilibrium_sa_ct_ratio_poly(double sa, double p);
function  gsw_melting_ice_equilibrium_sa_ct_ratio_poly(sa, p:double):double; cdecl; external libgswteos;


(*
Calculates the final Absolute Salinity, final Conservative Temperature
and final ice mass fraction that results when a given mass fraction of
ice melts and is mixed into seawater whose properties are (SA,CT,p).
This code takes the seawater to contain no dissolved air.

When the mass fraction w_Ih_final is calculated as being a positive
value, the seawater-ice mixture is at thermodynamic equlibrium.

This code returns w_Ih_final = 0 when the input bulk enthalpy, h_bulk,
is sufficiently large (i.e. sufficiently "warm") so that there is no ice
present in the final state.  In this case the final state consists of
only seawater rather than being an equlibrium mixture of seawater and
ice which occurs when w_Ih_final is positive.  Note that when
w_Ih_final = 0, the final seawater is not at the freezing temperature.

SA   =  Absolute Salinity of seawater                           [ g/kg ]
CT   =  Conservative Temperature of seawater (ITS-90)          [ deg C ]
p    =  sea pressure at which the melting occurs                [ dbar ]
        ( i.e. absolute pressure - 10.1325 dbar )
w_Ih =  mass fraction of ice, that is the mass of ice divided by the
        sum of the masses of ice and seawater.  That is, the mass of
        ice divided by the mass of the final mixed fluid.
        w_Ih must be between 0 and 1.                       [ unitless ]
t_Ih =  the in-situ temperature of the ice (ITS-90)            [ deg C ]

SA_final    =  Absolute Salinity of the seawater in the final state,
               whether or not any ice is present.               [ g/kg ]
CT_final    =  Conservative Temperature of the seawater in the the final
               state, whether or not any ice is present.       [ deg C ]
w_Ih_final  =  mass fraction of ice in the final seawater-ice mixture.
               If this ice mass fraction is positive, the system is at
               thermodynamic equilibrium.  If this ice mass fraction is
               zero there is no ice in the final state which consists
               only of seawater which is warmer than the freezing
               temperature.                                   [unitless]
*)
// void   gsw_melting_ice_into_seawater(double sa, double ct, double p, double w_ih, double t_ih, double *sa_final, double *ct_final, double *w_ih_final);



(*
Calculates the ratio of SA to CT changes when ice melts into seawater.
It is assumed that a small mass of ice melts into an infinite mass of
seawater.  Because of the infinite mass of seawater, the ice will always
melt.

The output, melting_seaice_SA_CT_ratio, is dSA/dCT rather than dCT/dSA.
This is done so that when SA = 0, the output, dSA/dCT is zero whereas
dCT/dSA would be infinite.

SA   =  Absolute Salinity of seawater                           [ g/kg ]
CT   =  Conservative Temperature of seawater (ITS-90)          [ deg C ]
p    =  sea pressure at which the melting occurs                [ dbar ]
( i.e. absolute pressure - 10.1325d0 dbar )
t_Ih =  the in-situ temperature of the ice (ITS-90)            [ deg C ]

melting_ice_SA_CT_ratio = the ratio of SA to CT changes when ice melts
into a large mass of seawater
[ g kg^-1 K^-1 ]
*)
// double gsw_melting_ice_sa_ct_ratio(double sa, double ct, double p, double t_ih);
function  gsw_melting_ice_sa_ct_ratio(sa, ct, p, t_ih:double):double; cdecl; external libgswteos;


(*
Calculates the ratio of SA to CT changes when ice melts into seawater.
It is assumed that a small mass of ice melts into an infinite mass of
seawater.  Because of the infinite mass of seawater, the ice will always
melt.

The output, melting_seaice_SA_CT_ratio, is dSA/dCT rather than dCT/dSA.
This is done so that when SA = 0, the output, dSA/dCT is zero whereas
dCT/dSA would be infinite.

SA   =  Absolute Salinity of seawater                           [ g/kg ]
CT   =  Conservative Temperature of seawater (ITS-90)          [ deg C ]
p    =  sea pressure at which the melting occurs                [ dbar ]
( i.e. absolute pressure - 10.1325d0 dbar )
t_Ih =  the in-situ temperature of the ice (ITS-90)            [ deg C ]

melting_ice_SA_CT_ratio = the ratio of SA to CT changes when ice melts
into a large mass of seawater
[ g kg^-1 K^-1 ]
*)
// double gsw_melting_ice_sa_ct_ratio_poly(double sa, double ct, double p, double t_ih);
function  gsw_melting_ice_sa_ct_ratio_poly(sa, ct, p, t_ih:double):double; cdecl; external libgswteos;


(*
Calculates the ratio of SA to CT changes when sea ice melts into
seawater with both the seawater and the sea ice temperatures being
almost equal to the equilibrium freezing temperature.  It is assumed
that a small mass of seaice melts into an infinite mass of seawater.  If
indeed the temperature of the seawater and the sea ice were both equal
to the freezing temperature, then no melting or freezing would occur; an
imbalance between these three temperatures is needed for freezing or
melting to occur (the three temperatures being (1) the seawater
temperature, (2) the sea ice temperature, and (3) the freezing
temperature.

Note that the output of this function, dSA/dCT is independent of the
sea ice salinity, SA_seaice.  That is, the output applies equally to
pure ice Ih and to sea ice with seaice salinity, SA_seaice.  This result
is proven in the manuscript, McDougall et al. (2013).

The output, melting_seaice_equilibrium_SA_CT_ratio, is dSA/dCT rather
than dCT/dSA.  This is done so that when SA = 0, the output, dSA/dCT is
zero whereas dCT/dSA would be infinite.

SA  =  Absolute Salinity of seawater                            [ g/kg ]
p   =  sea pressure at which the melting occurs                 [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

melting_seaice_equilibrium_SA_CT_ratio = the ratio dSA/dCT of SA to CT
changes when sea ice melts into seawater, with
the seawater and sea ice being close to the
freezing temperature.             [ g/(kg K) ]
*)
// double gsw_melting_seaice_equilibrium_sa_ct_ratio(double sa, double p);
function  gsw_melting_seaice_equilibrium_sa_ct_ratio(sa, p:double):double; cdecl; external libgswteos;


(*
Calculates the ratio of SA to CT changes when sea ice melts into
seawater with both the seawater and the sea ice temperatures being
almost equal to the equilibrium freezing temperature.  It is assumed
that a small mass of seaice melts into an infinite mass of seawater.  If
indeed the temperature of the seawater and the sea ice were both equal
to the freezing temperature, then no melting or freezing would occur; an
imbalance between these three temperatures is needed for freezing or
melting to occur (the three temperatures being (1) the seawater
temperature, (2) the sea ice temperature, and (3) the freezing
temperature.

Note that the output of this function, dSA/dCT is independent of the
sea ice salinity, SA_seaice.  That is, the output applies equally to
pure ice Ih and to sea ice with seaice salinity, SA_seaice.  This result
is proven in the manuscript, McDougall et al. (2013).

The output, melting_seaice_equilibrium_SA_CT_ratio, is dSA/dCT rather
than dCT/dSA.  This is done so that when SA = 0, the output, dSA/dCT is
zero whereas dCT/dSA would be infinite.

SA  =  Absolute Salinity of seawater                            [ g/kg ]
p   =  sea pressure at which the melting occurs                 [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

melting_seaice_equilibrium_SA_CT_ratio = the ratio dSA/dCT of SA to CT
changes when sea ice melts into seawater, with
the seawater and sea ice being close to the
freezing temperature.             [ g/(kg K) ]
*)
// double gsw_melting_seaice_equilibrium_sa_ct_ratio_poly(double sa, double p);
function  gsw_melting_seaice_equilibrium_sa_ct_ratio_poly(sa, p:double):double; cdecl; external libgswteos;


(*
Calculates the Absolute Salinity and Conservative Temperature that
results when a given mass of sea ice (or ice) melts and is mixed into a
known mass of seawater (whose properties are (SA,CT,p)).

If the ice contains no salt (e.g. if it is of glacial origin), then the
input 'SA_seaice' should be set to zero.

Ice formed at the sea surface (sea ice) typically contains between 2 g/kg
and 12 g/kg of salt (defined as the mass of salt divided by the mass of
ice Ih plus brine) and this programme returns NaN's if the input
SA_seaice is greater than 15 g/kg.  If the SA_seaice input is not zero,
usually this would imply that the pressure p should be zero, as sea ice
only occurs near the sea surface.  The code does not impose that p = 0
if SA_seaice is non-zero.  Rather, this is left to the user.

The Absolute Salinity, SA_brine, of the brine trapped in little pockets
in the sea ice, is in thermodynamic equilibrium with the ice Ih that
surrounds these pockets.  As the sea ice temperature, t_seaice, may be
less than the freezing temperature, SA_brine is usually greater than the
Absolute Salinity of the seawater at the time and place when and where
the sea ice was formed.  So usually SA_brine will be larger than SA.

SA  =  Absolute Salinity of seawater                            [ g/kg ]
CT  =  Conservative Temperature of seawater (ITS-90)           [ deg C ]
p   =  sea pressure at which the melting occurs                 [ dbar ]
       ( i.e. absolute pressure - 10.1325 dbar )
w_seaice  =  mass fraction of sea ice, that is the mass of sea ice
             divided by the sum of the masses of sea ice and seawater.
             That is, the mass of sea ice divided by the mass of the
             final mixed fluid.  w_seaice must be between 0 and 1.
             [ unitless ]
SA_seaice =  Absolute Salinity of sea ice, that is, the mass fraction of
             salt in sea ice, expressed in g of salt per kg of sea ice.
             [ g/kg ]
t_seaice  =  the in-situ temperature of the sea ice (or ice) (ITS-90)
             [ deg C ]

SA_final  =  Absolute Salinity of the mixture of the melted sea ice
             (or ice) and the orignal seawater                  [ g/kg ]
CT_final  =  Conservative Temperature of the mixture of the melted
             sea ice (or ice) and the orignal seawater         [ deg C ]
*)
// void   gsw_melting_seaice_into_seawater(double sa, double ct, double p, double w_seaice, double sa_seaice, double t_seaice, double *sa_final, double *ct_final);




(*
Calculates the ratio of SA to CT changes when sea ice melts into seawater.
It is assumed that a small mass of sea ice melts into an infinite mass of
seawater.  Because of the infinite mass of seawater, the sea ice will
always melt.

Ice formed at the sea surface (sea ice) typically contains between 2 g/kg
and 12 g/kg of salt (defined as the mass of salt divided by the mass of
ice Ih plus brine) and this programme returns NaN's if the input
SA_seaice is greater than 15 g/kg.  If the SA_seaice input is not zero,
usually this would imply that the pressure p should be zero, as sea ice
only occurs near the sea surface.  The code does not impose that p = 0 if
SA_seaice is non-zero.  Rather, this is left to the user.

The Absolute Salinity, SA_brine, of the brine trapped in little pockets
in the sea ice, is in thermodynamic equilibrium with the ice Ih that
surrounds these pockets.  As the seaice temperature, t_seaice, may be
less than the freezing temperature, SA_brine is usually greater than the
Absolute Salinity of the seawater at the time and place when and where
the sea ice was formed.  So usually SA_brine will be larger than SA.

The output, melting_seaice_SA_CT_ratio, is dSA/dCT rather than dCT/dSA.
This is done so that when (SA - seaice_SA) = 0, the output, dSA/dCT is
zero whereas dCT/dSA would be infinite.

SA  =  Absolute Salinity of seawater                            [ g/kg ]
CT  =  Conservative Temperature of seawater (ITS-90)           [ deg C ]
p   =  sea pressure at which the melting occurs                 [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )
SA_seaice  =  Absolute Salinity of sea ice, that is, the mass fraction
of salt in sea ice expressed in g of salt per kg of
sea ice                                           [ g/kg ]
t_seaice = the in-situ temperature of the sea ice (ITS-90)     [ deg C ]

melting_seaice_SA_CT_ratio = the ratio dSA/dCT of SA to CT changes when
sea ice melts into a large mass of seawater   [ g/(kg K) ]
*)
// double gsw_melting_seaice_sa_ct_ratio(double sa, double ct, double p, double sa_seaice, double t_seaice);
function  gsw_melting_seaice_sa_ct_ratio(sa, ct, p, sa_seaice, t_seaice:double):double; cdecl; external libgswteos;


(*
Calculates the ratio of SA to CT changes when sea ice melts into seawater.
It is assumed that a small mass of sea ice melts into an infinite mass of
seawater.  Because of the infinite mass of seawater, the sea ice will
always melt.

Ice formed at the sea surface (sea ice) typically contains between 2 g/kg
and 12 g/kg of salt (defined as the mass of salt divided by the mass of
ice Ih plus brine) and this programme returns NaN's if the input
SA_seaice is greater than 15 g/kg.  If the SA_seaice input is not zero,
usually this would imply that the pressure p should be zero, as sea ice
only occurs near the sea surface.  The code does not impose that p = 0 if
SA_seaice is non-zero.  Rather, this is left to the user.

The Absolute Salinity, SA_brine, of the brine trapped in little pockets
in the sea ice, is in thermodynamic equilibrium with the ice Ih that
surrounds these pockets.  As the seaice temperature, t_seaice, may be
less than the freezing temperature, SA_brine is usually greater than the
Absolute Salinity of the seawater at the time and place when and where
the sea ice was formed.  So usually SA_brine will be larger than SA.

The output, melting_seaice_SA_CT_ratio, is dSA/dCT rather than dCT/dSA.
This is done so that when (SA - seaice_SA) = 0, the output, dSA/dCT is
zero whereas dCT/dSA would be infinite.

SA  =  Absolute Salinity of seawater                            [ g/kg ]
CT  =  Conservative Temperature of seawater (ITS-90)           [ deg C ]
p   =  sea pressure at which the melting occurs                 [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )
SA_seaice  =  Absolute Salinity of sea ice, that is, the mass fraction
of salt in sea ice expressed in g of salt per kg of
sea ice                                           [ g/kg ]
t_seaice = the in-situ temperature of the sea ice (ITS-90)     [ deg C ]

melting_seaice_SA_CT_ratio = the ratio dSA/dCT of SA to CT changes when
sea ice melts into a large mass of seawater   [ g/(kg K) ]
*)
// double gsw_melting_seaice_sa_ct_ratio_poly(double sa, double ct, double p, double sa_seaice, double t_seaice);
function  gsw_melting_seaice_sa_ct_ratio_poly(sa, ct, p, sa_seaice, t_seaice:double):double; cdecl; external libgswteos;


(*
Calculates the buoyancy frequency squared (N^2)(i.e. the Brunt-Vaisala
frequency squared) at the mid pressure from the equation,


2      2             beta.d(SA) - alpha.d(CT)
N   =  g  .rho_local. -------------------------
dP

The pressure increment, dP, in the above formula is in Pa, so that it is
10^4 times the pressure increment dp in dbar.

sa     : Absolute Salinity         (a profile (length nz))     [g/kg]
ct     : Conservative Temperature  (a profile (length nz))     [deg C]
p      : sea pressure              (a profile (length nz))     [dbar]
lat    : latitude                  (a profile (length nz))     [deg N]
nz     : number of levels in the profile
n2     : Brunt-Vaisala Frequency squared  (length nz-1)        [s^-2]
p_mid  : Mid pressure between p grid      (length nz-1)        [dbar]
*)
// void   gsw_nsquared(double *sa, double *ct, double *p, double *lat, int nz, double *n2, double *p_mid);



(*
Calculates the oxygen concentration expected at equilibrium with air at
an Absolute Pressure of 101325 Pa (sea pressure of 0 dbar) including
saturated water vapor.  This function uses the solubility coefficients
derived from the data of Benson and Krause (1984), as fitted by Garcia
and Gordon (1992, 1993).

Note that this algorithm has not been approved by IOC and is not work
from SCOR/IAPSO Working Group 127. It is included in the GSW
Oceanographic Toolbox as it seems to be oceanographic best practice.

SA  :  Absolute Salinity of seawater                           [ g/kg ]
CT  :  Conservative Temperature of seawater (ITS-90)           [ deg C ]
p   :  sea pressure at which the melting occurs                [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )
lat : latitude                                                 [deg]
lon : longitude                                                [deg]

gsw_o2sol : olubility of oxygen in micro-moles per kg          [umol/kg]
*)
// gsw_o2sol(sa,ct,p,lon,lat)
function  gsw_o2sol(sa, ct, p, lon, lat:double):double; cdecl; external libgswteos;


(*
Calculates the oxygen concentration expected at equilibrium with air at
an Absolute Pressure of 101325 Pa (sea pressure of 0 dbar) including
saturated water vapor.  This function uses the solubility coefficients
derived from the data of Benson and Krause (1984), as fitted by Garcia
and Gordon (1992, 1993).

Note that this algorithm has not been approved by IOC and is not work
from SCOR/IAPSO Working Group 127. It is included in the GSW
Oceanographic Toolbox as it seems to be oceanographic best practice.

SP  :  Practical Salinity  (PSS-78)                         [ unitless ]
pt  :  potential temperature (ITS-90) referenced               [ dbar ]
to one standard atmosphere (0 dbar).

gsw_o2sol_sp_pt : olubility of oxygen in micro-moles per kg     [umol/kg]
*)
//     gsw_o2sol_sp_pt(sp,pt)
function  gsw_o2sol_sp_pt(sp, pt:double):double; cdecl; external libgswteos;


(*
Calculates the potential enthalpy of ice from potential temperature of
ice (whose reference sea pressure is zero dbar).

pt0_ice  =  potential temperature of ice (ITS-90)              [ deg C ]

gsw_pot_enthalpy_ice  =  potential enthalpy of ice              [ J/kg ]
*)
// double gsw_pot_enthalpy_from_pt_ice(double pt0_ice);
function  gsw_pot_enthalpy_from_pt_ice(pt0_ice:double):double; cdecl; external libgswteos;



(*
Calculates the potential enthalpy of ice from potential temperature of
ice (whose reference sea pressure is zero dbar).  This is a
compuationally efficient polynomial fit to the potential enthalpy of
ice.

pt0_ice  =  potential temperature of ice (ITS-90)              [ deg C ]

pot_enthalpy_ice  =  potential enthalpy of ice                  [ J/kg ]
*)
// double gsw_pot_enthalpy_from_pt_ice_poly(double pt0_ice);
function  gsw_pot_enthalpy_from_pt_ice_poly(pt0_ice:double):double; cdecl; external libgswteos;


(*
Calculates the potential enthalpy of ice at which seawater freezes.

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

pot_enthalpy_ice_freezing = potential enthalpy of ice at freezing
of seawater                        [ deg C ]
*)
// double gsw_pot_enthalpy_ice_freezing(double sa, double p);
function  gsw_pot_enthalpy_ice_freezing(sa, p:double):double; cdecl; external libgswteos;


(*
Calculates the first derivatives of the potential enthalpy of ice at
which seawater freezes, with respect to Absolute Salinity SA and
pressure P (in Pa).

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )

pot_enthalpy_ice_freezing_SA = the derivative of the potential enthalpy
                               of ice at freezing (ITS-90) with respect to
                               Absolute salinity at fixed pressure  [ K/(g/kg) ] i.e. [ K kg/g ]

pot_enthalpy_ice_freezing_P  = the derivative of the potential enthalpy
                               of ice at freezing (ITS-90) with respect to
                               pressure (in Pa) at fixed Absolute Salinity              [ K/Pa ]
*)
// void   gsw_pot_enthalpy_ice_freezing_first_derivatives(double sa, double p, double *pot_enthalpy_ice_freezing_sa, double *pot_enthalpy_ice_freezing_p);


(*
Calculates the first derivatives of the potential enthalpy of ice Ih at
which ice melts into seawater with Absolute Salinity SA and at pressure
p.  This code uses the comptationally efficient polynomial fit of the
freezing potential enthalpy of ice Ih (McDougall et al., 2015).

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )

pot_enthalpy_ice_freezing_SA = the derivative of the potential enthalpy
                               of ice at freezing (ITS-90) with respect to
                               Absolute salinity at fixed pressure
                               [ (J/kg)/(g/kg) ] i.e. [ J/g ]

pot_enthalpy_ice_freezing_P  = the derivative of the potential enthalpy
                               of ice at freezing (ITS-90) with respect to
                               pressure (in Pa) at fixed Absolute Salinity           [ (J/kg)/Pa ]
*)
// void   gsw_pot_enthalpy_ice_freezing_first_derivatives_poly(double sa, double p, double *pot_enthalpy_ice_freezing_sa, double *pot_enthalpy_ice_freezing_p);


(*
Calculates the potential enthalpy of ice at which seawater freezes.
The error of this fit ranges between -2.5 and 1 J/kg with an rms of
1.07, between SA of 0 and 120 g/kg and p between 0 and 10,000 dbar (the
error in the fit is between -0.7 and 0.7 with an rms of
0.3, between SA of 0 and 120 g/kg and p between 0 and 5,000 dbar) when
compared with the potential enthalpy calculated from the exact in-situ
freezing temperature which is found by a Newton-Raphson iteration of the
equality of the chemical potentials of water in seawater and in ice.

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

pot_enthalpy_ice_freezing = potential enthalpy of ice at freezing
of seawater                         [ J/kg ]
*)
// double gsw_pot_enthalpy_ice_freezing_poly(double sa, double p);
function  gsw_pot_enthalpy_ice_freezing_poly(sa, p:double):double; cdecl; external libgswteos;


(*
Calculates the potential density of seawater

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]
p_ref  : reference sea pressure                          [dbar]

gsw_pot_rho_t_exact : potential density                  [kg/m^3]
*)
// double gsw_pot_rho_t_exact(double sa, double t, double p, double p_ref);
function  gsw_pot_rho_t_exact(sa, t, p, p_ref:double):double; cdecl; external libgswteos;


(*
Calculates pressure coefficient of ice.

t  =  in-situ temperature (ITS-90)                           [deg C]
p  =  sea pressure                                           [dbar]
( i.e. absolute pressure - 10.1325 dbar )

pressure_coefficient_ice  =  pressure coefficient of ice     [Pa/K]
Note. The output units are Pa/K NOT dbar/K.
*)
// double gsw_pressure_coefficient_ice(double t, double p);
function  gsw_pressure_coefficient_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates the pressure (in dbar) of seawater at the freezing
temperature.  That is, the output is the pressure at which seawater,
with Absolute Salinity SA, Conservative Temperature CT, and with
saturation_fraction of dissolved air, freezes.  If the input values are
such that there is no value of pressure in the range between 0 dbar and
10,000 dbar for which seawater is at the freezing temperature, the
output, pressure_freezing, is put equal to NaN.

SA  =  Absolute Salinity of seawater                            [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
saturation_fraction = the saturation fraction of dissolved air in
seawater

pressure_freezing = sea pressure at which the seawater freezes  [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )
*)
// double gsw_pressure_freezing_ct(double sa, double ct, double saturation_fraction);
function  gsw_pressure_freezing_ct(sa, ct, saturation_fraction:double):double; cdecl; external libgswteos;


(*
Calculates an initial estimate of pt0_ice when it is less than about
-100 deg C.

pot_enthalpy_ice  =  potential enthalpy of ice                  [ J/kg ]

pt0_cold_ice_poly  =  initial estimate of potential temperatur
of very cold ice in dgress C (not K)     [ deg C ]
*)
// double gsw_pt0_cold_ice_poly(double pot_enthalpy_ice);
function  gsw_pt0_cold_ice_poly(pot_enthalpy_ice:double):double; cdecl; external libgswteos;


(*
Calculates potential temperature with reference pressure, p_ref = 0 dbar.

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

gsw_pt0_from_t : potential temperature, p_ref = 0        [deg C]
*)
// double gsw_pt0_from_t(double sa, double t, double p);
function  gsw_pt0_from_t(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates potential temperature of ice Ih with a reference pressure of
0 dbar, from in-situ temperature, t.

t   =  in-situ temperature  (ITS-90)                           [ deg C ]
p   =  sea pressure                                             [ dbar ]
       ( i.e. absolute pressure - 10.1325 dbar )

pt0_ice  =  potential temperature of ice Ih with reference pressure of
           zero dbar (ITS-90)                                 [ deg C ]
*)
// double gsw_pt0_from_t_ice(double t, double p);
function  gsw_pt0_from_t_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates the following two partial derivatives of potential temperature
(the regular potential temperature whose reference sea pressure is 0 dbar)
(1) pt_SA, the derivative with respect to Absolute Salinity at
constant Conservative Temperature, and
(2) pt_CT, the derivative with respect to Conservative Temperature at
constant Absolute Salinity.

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]

pt_SA =  The derivative of potential temperature with respect to
         Absolute Salinity at constant Conservative Temperature. [ K/(g/kg)]
pt_CT =  The derivative of potential temperature with respect to
         Conservative Temperature at constant Absolute Salinity.
         pt_CT is dimensionless.                            [ unitless ]
*)
// void   gsw_pt_first_derivatives (double sa, double ct, double *pt_sa, double *pt_ct);



(*
Potential temperature of seawater from conservative temperature

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature                        [deg C]
p      : sea pressure                                    [dbar]

gsw_pt_from_ct : potential temperature with              [deg C]
reference pressure of  0 dbar
*)
// double gsw_pt_from_ct(double sa, double ct);
function  gsw_pt_from_ct(sa, ct:double):double; cdecl; external libgswteos;


(*
Calculates potential temperature with reference pressure p_ref = 0 dbar
and with entropy as an input variable.

SA       =  Absolute Salinity                                   [ g/kg ]
entropy  =  specific entropy                                   [ deg C ]

pt   =  potential temperature                                  [ deg C ]
       with reference sea pressure (p_ref) = 0 dbar.
Note. The reference sea pressure of the output, pt, is zero dbar.
*)
// double gsw_pt_from_entropy(double sa, double entropy);
function  gsw_pt_from_entropy(sa, entropy:double):double; cdecl; external libgswteos;


(*
Calculates the potential temperature of ice from the potential enthalpy
of ice.  The reference sea pressure of both the potential temperature
and the potential enthalpy is zero dbar.

pot_enthalpy_ice  =  potential enthalpy of ice                  [ J/kg ]

pt0_ice  =  potential temperature of ice (ITS-90)              [ deg C ]
*)
// double gsw_pt_from_pot_enthalpy_ice(double pot_enthalpy_ice);
function  gsw_pt_from_pot_enthalpy_ice(pot_enthalpy_ice:double):double; cdecl; external libgswteos;


(*
Calculates the derivative of potential temperature of ice with respect
to potential enthalpy.  This is based on the compuationally-efficient
polynomial fit to the potential enthalpy of ice.

pot_enthalpy_ice  =  potential enthalpy of ice                  [ J/kg ]

dpt0_ice_dh  =  derivative of potential temperature of ice
with respect to potential enthalpy             [ deg C ]
*)
// double gsw_pt_from_pot_enthalpy_ice_poly_dh(double pot_enthalpy_ice);
function  gsw_pt_from_pot_enthalpy_ice_poly_dh(pot_enthalpy_ice:double):double; cdecl; external libgswteos;


(*
Calculates the potential temperature of ice (whose reference sea
pressure is zero dbar) from the potential enthalpy of ice.  This is a
compuationally efficient polynomial fit to the potential enthalpy of
ice.

pot_enthalpy_ice  =  potential enthalpy of ice                  [ J/kg ]

pt0_ice  =  potential temperature of ice (ITS-90)              [ deg C ]
*)
// double gsw_pt_from_pot_enthalpy_ice_poly(double pot_enthalpy_ice);
function  gsw_pt_from_pot_enthalpy_ice_poly(pot_enthalpy_ice:double):double; cdecl; external libgswteos;


(*
Calculates potential temperature of seawater from in-situ temperature

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]
p_ref  : reference sea pressure                          [dbar]

gsw_pt_from_t : potential temperature                    [deg C]
*)
// double gsw_pt_from_t(double sa, double t, double p, double p_ref);
function  gsw_pt_from_t(sa, t, p, p_ref:double):double; cdecl; external libgswteos;


(*
Calculates potential temperature of ice Ih with the general reference
pressure, p_ref, from in-situ temperature, t.

A faster gsw routine exists if p_ref is indeed zero dbar.  This routine
is "gsw_pt0_from_t_ice(t,p)".

t  =  in-situ temperature (ITS-90)                             [ deg C ]
p  =  sea pressure                                              [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )
p_ref  =  reference pressure                                    [ dbar ]
*)
// double gsw_pt_from_t_ice(double t, double p, double p_ref);
function  gsw_pt_from_t_ice(t, p, p_ref:double):double; cdecl; external libgswteos;


(*
Calculates the following three second-order derivatives of potential
temperature (the regular potential temperature which has a reference
sea pressure of 0 dbar),
(1) pt_SA_SA, the second derivative with respect to Absolute Salinity
at constant Conservative Temperature,
(2) pt_SA_CT, the derivative with respect to Conservative Temperature
and Absolute Salinity, and
(3) pt_CT_CT, the second derivative with respect to Conservative
Temperature at constant Absolute Salinity.

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]

pt_SA_SA  =  The second derivative of potential temperature (the
regular potential temperature which has reference sea
pressure of 0 dbar) with respect to Absolute Salinity
at constant Conservative Temperature.
pt_SA_SA has units of:                     [ K/((g/kg)^2) ]
pt_SA_CT  =  The derivative of potential temperature with respect
to Absolute Salinity and Conservative Temperature.
pt_SA_CT has units of:                         [ 1/(g/kg) ]
pt_CT_CT  =  The second derivative of potential temperature (the
regular one with p_ref = 0 dbar) with respect to
Conservative Temperature at constant SA.
pt_CT_CT has units of:                              [ 1/K ]
*)
//extern void   gsw_pt_second_derivatives (double sa, double ct, double *pt_sa_sa, double *pt_sa_ct, double *pt_ct_ct);


(*
Calculates in-situ density, the appropiate thermal expansion coefficient
and the appropriate saline contraction coefficient of seawater from
Absolute Salinity and Conservative Temperature.  This function uses the
computationally-efficient expression for specific volume in terms of
SA, CT and p (Roquet et al., 2014).

Note that potential density (pot_rho) with respect to reference pressure
p_ref is obtained by calling this function with the pressure argument
being p_ref as in [pot_rho, ~, ~] = gsw_rho_alpha_beta(SA,CT,p_ref).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

rho    =  in-situ density                                       [ kg/m ]
alpha  =  thermal expansion coefficient                          [ 1/K ]
with respect to Conservative Temperature
beta   =  saline (i.e. haline) contraction                      [ kg/g ]
coefficient at constant Conservative Temperature
*)
//extern void   gsw_rho_alpha_beta (double sa, double ct, double p, double *rho, double *alpha, double *beta);


(*
Calculates in-situ density from Absolute Salinity and Conservative
Temperature, using the computationally-efficient expression for
specific volume in terms of SA, CT and p (Roquet et al., 2014).

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature (ITS-90)               [deg C]
p      : sea pressure                                    [dbar]
( i.e. absolute pressure - 10.1325 dbar )

rho    : in-situ density                                 [kg/m]
*)
// double gsw_rho(double sa, double ct, double p);
function  gsw_rho(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates the three (3) partial derivatives of in situ density with
respect to Absolute Salinity, Conservative Temperature and pressure.
Note that the pressure derivative is done with respect to pressure in
Pa, not dbar.  This function uses the computationally-efficient expression
for specific volume in terms of SA, CT and p (Roquet et al., 2014).

sa        : Absolute Salinity                               [g/kg]
ct        : Conservative Temperature                        [deg C]
p         : sea pressure                                    [dbar]
drho_dsa  : partial derivatives of density                  [kg^2/(g m^3)]
with respect to Absolute Salinity
drho_dct  : partial derivatives of density                  [kg/(K m^3)]
with respect to Conservative Temperature
drho_dp   : partial derivatives of density                  [kg/(Pa m^3)]
with respect to pressure in Pa
*)
// void   gsw_rho_first_derivatives(double sa, double ct, double p, double *drho_dsa, double *drho_dct, double *drho_dp);


(*
Calculates two first-order derivatives of specific volume (v).
Note that this function uses the using the computationally-efficient
expression for specific volume (Roquet et al., 2014).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

rho_SA =  The first derivative of rho with respect to
Absolute Salinity at constant CT & p.    [ J/(kg (g/kg)^2) ]
rho_h  =  The first derivative of rho with respect to
SA and CT at constant p.                  [ J/(kg K(g/kg)) ]
*)
// void   gsw_rho_first_derivatives_wrt_enthalpy (double sa, double ct, double p, double *rho_sa, double *rho_h);


(*
Calculates in-situ density of ice from in-situ temperature and pressure.
Note that the output, rho_ice, is density, not density anomaly;  that
is, 1000 kg/m^3 is not subracted from it.

t   =  in-situ temperature (ITS-90)                            [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

rho_ice  =  in-situ density of ice (not density anomaly)      [ kg/m^3 ]
*)
// double gsw_rho_ice(double t, double p);
function  gsw_rho_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates five second-order derivatives of rho. Note that this function
uses the computationally-efficient expression for specific
volume (Roquet et al., 2014).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

rho_SA_SA = The second-order derivative of rho with respect to
Absolute Salinity at constant CT & p.    [ J/(kg (g/kg)^2) ]
rho_SA_CT = The second-order derivative of rho with respect to
SA and CT at constant p.                  [ J/(kg K(g/kg)) ]
rho_CT_CT = The second-order derivative of rho with respect to CT at
constant SA & p
rho_SA_P  = The second-order derivative with respect to SA & P at
constant CT.
rho_CT_P  = The second-order derivative with respect to CT & P at
constant SA.
*)
// void   gsw_rho_second_derivatives(double sa, double ct, double p, double *rho_sa_sa, double *rho_sa_ct, double *rho_ct_ct, double *rho_sa_p, double *rho_ct_p);


(*
Calculates three second-order derivatives of rho with respect to enthalpy.
Note that this function uses the using the computationally-efficient
expression for specific volume (Roquet et al., 2014).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

rho_SA_SA = The second-order derivative of rho with respect to
Absolute Salinity at constant h & p.     [ J/(kg (g/kg)^2) ]
rho_SA_h  = The second-order derivative of rho with respect to
SA and h at constant p.                   [ J/(kg K(g/kg)) ]
rho_h_h   = The second-order derivative of rho with respect to h at
constant SA & p
*)
// void   gsw_rho_second_derivatives_wrt_enthalpy(double sa, double ct, double p, double *rho_sa_sa, double *rho_sa_h, double *rho_h_h);


(*
Calculates in-situ density of seawater from Absolute Salinity and
in-situ temperature.

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

gsw_rho_t_exact : in-situ density                        [kg/m^3]
*)
// double gsw_rho_t_exact(double sa, double t, double p);
function  gsw_rho_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(*
Interpolate Absolute Salinity and Conservative Temperature values to
arbitrary pressures using the Reiniger and Ross (1968) interpolation
scheme.
Note that this interpolation scheme requires at least four observed
bottles on the cast.

SA   =  Absolute Salinity                                  [ g/kg ]
CT   =  Conservative Temperature (ITS-90)                 [ deg C ]
p    =  sea pressure                                       [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )
p_i  =  pressures to interpolate to.

SA_i = interpolated SA values at pressures p_i.
CT_i = interpolated CT values at pressures p_i.
*)
// void   gsw_rr68_interp_sa_ct(double *sa, double *ct, double *p, int mp, double *p_i, int mp_i, double *sa_i, double *ct_i);


(*
Absolute Salinity Anomaly Ratio
*)
// double gsw_saar(double p, double lon, double lat);
function  gsw_saar(p, lon, lat:double):double; cdecl; external libgswteos;


(*
Form an estimate of SA from a polynomial in CT and p
*)
// double gsw_sa_freezing_estimate(double p, double saturation_fraction, double *ct, double *t);
//function gsw_sa_freezing_estimate(p, saturation_fraction:double):double; cdecl; external libgswteos;


(*
Calculates the Absolute Salinity of seawater at the freezing temperature.
That is, the output is the Absolute Salinity of seawater, with
Conservative Temperature CT, pressure p and the fraction
saturation_fraction of dissolved air, that is in equilibrium
with ice at the same in situ temperature and pressure.  If the input
values are such that there is no positive value of Absolute Salinity for
which seawater is frozen, the output is made a NaN.

CT  =  Conservative Temperature of seawater (ITS-90)           [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction  =  the saturation fraction of dissolved air in
seawater

sa_freezing_from_ct  =  Absolute Salinity of seawater when it freezes,
for given input values of its Conservative Temperature,
pressure and air saturation fraction.            [ g/kg ]
*)
// double gsw_sa_freezing_from_ct(double ct, double p, double saturation_fraction);
function gsw_sa_freezing_from_ct(ct, p, saturation_fraction:double):double; cdecl; external libgswteos;


(*
Calculates the Absolute Salinity of seawater at the freezing temperature.
That is, the output is the Absolute Salinity of seawater, with the
fraction saturation_fraction of dissolved air, that is in equilibrium
with ice at Conservative Temperature CT and pressure p.  If the input
values are such that there is no positive value of Absolute Salinity for
which seawater is frozen, the output is put equal to Nan.

CT  =  Conservative Temperature (ITS-90)                        [deg C]
p   =  sea pressure                                             [dbar ]
       ( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction  =  the saturation fraction of dissolved air in
                        seawater

sa_freezing_from_ct  =  Absolute Salinity of seawater when it freezes,
                        for given input values of Conservative Temperature
                        pressure and air saturation fraction.    [g/kg]
*)
// double gsw_sa_freezing_from_ct_poly(double ct, double p, double saturation_fraction);
function  gsw_sa_freezing_from_ct_poly(ct, p, saturation_fraction:double):double; cdecl; external libgswteos;


(*
Calculates the Absolute Salinity of seawater at the freezing temperature.
That is, the output is the Absolute Salinity of seawater, with the
fraction saturation_fraction of dissolved air, that is in equilibrium
with ice at in-situ temperature t and pressure p.  If the input values
are such that there is no positive value of Absolute Salinity for which
seawater is frozen, the output is set to NaN.

t  =  in-situ Temperature (ITS-90)                              [deg C]
p  =  sea pressure                                              [dbar]
      ( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction = the saturation fraction of dissolved air in
                      seawater (i.e., saturation_fraction must be
                      between 0 and 1, and the default is 1,
                      completely saturated)

sa_freezing_from_t  =  Absolute Salinity of seawater when it freezes, for
                       given input values of in situ temperature, pressure and
                       air saturation fraction.                  [g/kg]
*)
// double gsw_sa_freezing_from_t(double t, double p, double saturation_fraction);
function  gsw_sa_freezing_from_t(t, p, saturation_fraction:double):double; cdecl; external libgswteos;


(*
Calculates the Absolute Salinity of seawater at the freezing temperature.
That is, the output is the Absolute Salinity of seawater, with the
fraction saturation_fraction of dissolved air, that is in equilibrium
with ice at in-situ temperature t and pressure p.  If the input values
are such that there is no positive value of Absolute Salinity for which
seawater is frozen, the output is put equal to Nan.

t  =  in-situ Temperature (ITS-90)                             [deg C]
p  =  sea pressure                                             [dbar]
      ( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction = the saturation fraction of dissolved air in
                      seawater

sa_freezing_from_t_poly  =  Absolute Salinity of seawater when it freezes,
                            for given input values of in situ temperature,
                            pressure and air saturation fraction. [g/kg]
*)
// double gsw_sa_freezing_from_t_poly(double t, double p, double saturation_fraction);
function  gsw_sa_freezing_from_t_poly(t, p, saturation_fraction:double):double; cdecl; external libgswteos;


(*
Calculates the Absolute Salinity of a seawater sample, for given values
of its density, Conservative Temperature and sea pressure (in dbar).

rho =  density of a seawater sample (e.g. 1026 kg/m^3).       [kg/m^3]
Note. This input has not had 1000 kg/m^3 subtracted from it.
That is, it is 'density', not 'density anomaly'.

ct  =  Conservative Temperature (ITS-90)                      [deg C]
p   =  sea pressure                                           [dbar]

sa  =  Absolute Salinity                                      [g/kg]
*)
// double gsw_sa_from_rho(double rho, double ct, double p);
function  gsw_sa_from_rho(rho, ct, p:double):double; cdecl; external libgswteos;


(*
For the Baltic Sea, calculates Absolute Salinity with a value
computed analytically from Practical Salinity

sp     : Practical Salinity                              [unitless]
lon    : longitude                                       [deg E]
lat    : latitude                                        [deg N]

sa_from_sp_baltic : Absolute Salinity                    [g/kg]
*)
// double gsw_sa_from_sp_baltic(double sp, double lon, double lat);
function  gsw_sa_from_sp_baltic(sp, lon, lat:double):double; cdecl; external libgswteos;


(*
Calculates Absolute Salinity, SA, from Practical Salinity, SP

sp     : Practical Salinity                              [unitless]
p      : sea pressure                                    [dbar]
lon    : longitude                                       [DEG E]
lat    : latitude                                        [DEG N]

gsw_sa_from_sp   : Absolute Salinity                     [g/kg]
*)
// double gsw_sa_from_sp(double sp, double p, double lon, double lat);
function  gsw_sa_from_sp(sp, p, lon, lat:double):double; cdecl; external libgswteos;


(*
Calculates Absolute Salinity, SA, from Preformed Salinity, Sstar.

Sstar  : Preformed Salinity                              [g/kg]
p      : sea pressure                                    [dbar]
lon   : longitude                                        [deg E]
lat    : latitude                                        [deg N]

gsw_sa_from_sstar   : Absolute Salinity                  [g/kg]
*)
// double gsw_sa_from_sstar(double sstar, double p,double lon,double lat);
function  gsw_sa_from_sstar(sstar, p, lon, lat:double):double; cdecl; external libgswteos;


(*
Check for any values that are out of the TEOS-10 range ...

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )
*)
// int    gsw_sa_p_inrange(double sa, double p);
function  gsw_sa_p_inrange(sa, p:double):integer; cdecl; external libgswteos;


(*
Calculates the mass fraction of sea ice (mass of sea ice divided by mass
of sea ice plus seawater), which, when melted into seawater having the
properties (SA,CT,p) causes the final seawater to be at the freezing
temperature.  The other outputs are the Absolute Salinity and
Conservative Temperature of the final seawater.

SA        =  Absolute Salinity of seawater                      [ g/kg ]
CT        =  Conservative Temperature of seawater (ITS-90)     [ deg C ]
p         =  sea pressure                                       [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )
SA_seaice =  Absolute Salinity of sea ice, that is, the mass fraction of
salt in sea ice, expressed in g of salt per kg of sea ice.
[ g/kg ]
t_seaice  =  in-situ temperature of the sea ice at pressure p (ITS-90)
[ deg C ]

SA_freeze  =  Absolute Salinity of seawater after the mass fraction of
sea ice, w_seaice, at temperature t_seaice has melted into
the original seawater, and the final mixture is at the
freezing temperature of seawater.                 [ g/kg ]

CT_freeze  =  Conservative Temperature of seawater after the mass
fraction, w_seaice, of sea ice at temperature t_seaice has
melted into the original seawater, and the final mixture
is at the freezing temperature of seawater.      [ deg C ]

w_seaice   =  mass fraction of sea ice, at SA_seaice and t_seaice,
which, when melted into seawater at (SA,CT,p) leads to the
final mixed seawater being at the freezing temperature.
This output is between 0 and 1.                 [unitless]
*)
// void   gsw_seaice_fraction_to_freeze_seawater(double sa, double ct, double p, double sa_seaice, double t_seaice, double *sa_freeze, double *ct_freeze, double *w_seaice);


(*
Calculates potential density anomaly with reference pressure of 0 dbar,
this being this particular potential density minus 1000 kg/m^3.  This
function has inputs of Absolute Salinity and Conservative Temperature.
This function uses the computationally-efficient 48-term expression for
density in terms of SA, CT and p (IOC et al., 2010).

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature                        [deg C]

gsw_sigma0  : potential density anomaly with reference pressure of 0
(48 term equation)
*)
// double gsw_sigma0(double sa, double ct);
function  gsw_sigma0(sa, ct:double):double; cdecl; external libgswteos;


(*
Calculates potential density anomaly with reference pressure of 1000 dbar,
this being this particular potential density minus 1000 kg/m^3.  This
function has inputs of Absolute Salinity and Conservative Temperature.

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature                        [deg C]

sigma1 : potential density anomaly with reference pressure of 1000
*)
// double gsw_sigma1(double sa, double ct);
function  gsw_sigma1(sa, ct:double):double; cdecl; external libgswteos;


(*
Calculates potential density anomaly with reference pressure of 2000 dbar,
this being this particular potential density minus 1000 kg/m^3.  This
function has inputs of Absolute Salinity and Conservative Temperature.

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature                        [deg C]

sigma2 : potential density anomaly with reference pressure of 2000
*)
// double gsw_sigma2(double sa, double ct);
function  gsw_sigma2(sa, ct:double):double; cdecl; external libgswteos;


(*
Calculates potential density anomaly with reference pressure of 3000 dbar,
this being this particular potential density minus 1000 kg/m^3.  This
function has inputs of Absolute Salinity and Conservative Temperature.

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature                        [deg C]

sigma3 : potential density anomaly with reference pressure of 3000
*)
// double gsw_sigma3(double sa, double ct);
function  gsw_sigma3(sa, ct:double):double; cdecl; external libgswteos;


(*
Calculates potential density anomaly with reference pressure of 4000 dbar,
this being this particular potential density minus 1000 kg/m^3.  This
function has inputs of Absolute Salinity and Conservative Temperature.

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature                        [deg C]

sigma4  : potential density anomaly with reference pressure of 4000
*)
// double gsw_sigma4(double sa, double ct);
function  gsw_sigma4(sa, ct:double):double; cdecl; external libgswteos;


(*
Calculates the speed of sound in seawater.  This function has inputs of
Absolute Salinity and Conservative Temperature.  This function uses the
computationally-efficient expression for specific volume in terms of SA,
CT and p (Roquet et al., 2014).

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature (ITS-90)               [deg C]
p      : sea pressure                                    [dbar]

sound_speed  : speed of sound in seawater                [m/s]
*)
// double gsw_sound_speed(double sa, double ct, double p);
function  gsw_sound_speed(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates the compression speed of sound in ice.

t   =  in-situ temperature (ITS-90)                            [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

sound_speed_ice  =  compression speed of sound in ice            [ m/s ]
*)
// double gsw_sound_speed_ice(double t, double p);
function  gsw_sound_speed_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates the speed of sound in seawater

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

gsw_sound_speed_t_exact : sound speed                    [m/s]
*)
// double gsw_sound_speed_t_exact(double sa, double t, double p);
function  gsw_sound_speed_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates specific volume, the appropiate thermal expansion coefficient
and the appropriate saline contraction coefficient of seawater from
Absolute Salinity and Conservative Temperature.  This function uses the
computationally-efficient expression for specific volume in terms of
SA, CT and p (Roquet et al., 2014).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

specvol =  specific volume                                      [ m/kg ]
alpha   =  thermal expansion coefficient                         [ 1/K ]
with respect to Conservative Temperature
beta    =  saline (i.e. haline) contraction                     [ kg/g ]
coefficient at constant Conservative Temperature
*)
// void   gsw_specvol_alpha_beta(double sa, double ct, double p, double *specvol, double *alpha, double *beta);


(*
Calculates specific volume anomaly of seawater.

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature (ITS-90)               [deg C]
p      : sea pressure                                    [dbar]

specvol_anom  :  specific volume anomaly of seawater
*)
// double gsw_specvol_anom_standard(double sa, double ct, double p);
function  gsw_specvol_anom_standard(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates specific volume from Absolute Salinity, Conservative
Temperature and pressure, using the computationally-efficient
polynomial expression for specific volume (Roquet et al., 2014).

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature (ITS-90)               [deg C]
p      : sea pressure                                    [dbar]
( i.e. absolute pressure - 10.1325 dbar )

specvol: specific volume                                 [m^3/kg]
*)
// double gsw_specvol(double sa, double ct, double p);
function  gsw_specvol(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates three first-order derivatives of specific volume (v).
Note that this function uses the computationally-efficient
expression for specific volume (Roquet et al., 2014).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

v_SA  =  The first derivative of specific volume with respect to
         Absolute Salinity at constant CT & p.       [ J/(kg (g/kg)^2) ]
v_CT  =  The first derivative of specific volume with respect to
         CT at constant SA and p.                     [ J/(kg K(g/kg)) ]
v_P   =  The first derivative of specific volume with respect to
         P at constant SA and CT.                         [ J/(kg K^2) ]
*)
// void   gsw_specvol_first_derivatives(double sa, double ct, double p, double *v_sa, double *v_ct, double *v_p);


(*
Calculates two first-order derivatives of specific volume (v).
Note that this function uses the using the computationally-efficient
expression for specific volume (Roquet et al., 2014).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

v_SA  =  The first derivative of specific volume with respect to
Absolute Salinity at constant CT & p.    [ J/(kg (g/kg)^2) ]
v_h  =  The first derivative of specific volume with respect to
SA and CT at constant p.                  [ J/(kg K(g/kg)) ]
*)
// void   gsw_specvol_first_derivatives_wrt_enthalpy(double sa, double ct, double p, double *v_sa, double *v_h);


(*
Calculates the specific volume of ice.

t  =  in-situ temperature (ITS-90)                             [ deg C ]
p  =  sea pressure                                              [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

specvol_ice  =  specific volume                               [ m^3/kg ]
*)
// double gsw_specvol_ice(double t, double p);
function  gsw_specvol_ice(t, p:double):double; cdecl; external libgswteos;


(*
Calculates five second-order derivatives of specific volume (v).
Note that this function uses the computationally-efficient
expression for specific volume (Roquet et al., 2014).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

v_SA_SA  =  The second derivative of specific volume with respect to
            Absolute Salinity at constant CT & p.    [ J/(kg (g/kg)^2) ]
v_SA_CT  =  The second derivative of specific volume with respect to
            SA and CT at constant p.                  [ J/(kg K(g/kg)) ]
v_CT_CT  =  The second derivative of specific volume with respect to
            CT at constant SA and p.                      [ J/(kg K^2) ]
v_SA_P  =   The second derivative of specific volume with respect to
            SA and P at constant CT.                  [ J/(kg K(g/kg)) ]
v_CT_P  =   The second derivative of specific volume with respect to
            CT and P at constant SA.                  [ J/(kg K(g/kg)) ]
*)
// void   gsw_specvol_second_derivatives (double sa, double ct, double p, double *v_sa_sa, double *v_sa_ct, double *v_ct_ct, double *v_sa_p, double *v_ct_p);


(*
Calculates three first-order derivatives of specific volume (v) with
respect to enthalpy. Note that this function uses the using the
computationally-efficient expression for specific volume
(Roquet et al., 2014).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )

v_SA_SA = The second-order derivative of specific volume with respect to
          Absolute Salinity at constant h & p.       [ J/(kg (g/kg)^2) ]
v_SA_h  = The second-order derivative of specific volume with respect to
          SA and h at constant p.                     [ J/(kg K(g/kg)) ]
v_h_h   = The second-order derivative with respect to h at
          constant SA & p.
*)
// void   gsw_specvol_second_derivatives_wrt_enthalpy(double sa, double ct, double p, double *v_sa_sa, double *v_sa_h, double *v_h_h);



(*
This function calculates specific volume at the Standard Ocean Salinty,
SSO, and at a Conservative Temperature of zero degrees C, as a function
of pressure, p, in dbar, using a streamlined version of the CT version
of specific volume, that is, a streamlined version of the code
"gsw_specvol(SA,CT,p)".

p      : sea pressure                                    [dbar]
3   -1
specvol_sso_0 : specvol(sso,0,p)                         [m  kg  ]
*)
// double gsw_specvol_sso_0(double p);
function  gsw_specvol_sso_0(p:double):double; cdecl; external libgswteos;


(*
Calculates the specific volume of seawater

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

specvol_t_exact : specific volume                        [kg/m^3]

*)
// double gsw_specvol_t_exact(double sa, double t, double p);
function  gsw_specvol_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates Practical Salinity, SP, from conductivity, C, primarily using
the PSS-78 algorithm.  Note that the PSS-78 algorithm for Practical
Salinity is only valid in the range 2 < SP < 42.  If the PSS-78
algorithm produces a Practical Salinity that is less than 2 then the
Practical Salinity is recalculated with a modified form of the Hill et
al. (1986) formula.  The modification of the Hill et al. (1986)
expression is to ensure that it is exactly consistent with PSS-78
at SP = 2.  Note that the input values of conductivity need to be in
units of mS/cm (not S/m).

c      : conductivity                                     [ mS/cm ]
t      : in-situ temperature [ITS-90]                     [deg C]
p      : sea pressure                                     [dbar]

sp     : Practical Salinity                               [unitless]
*)
// double gsw_sp_from_c(double c, double t, double p);
function gsw_sp_from_c(c, t, p:double):double; cdecl; external libgswteos;


(*
For the Baltic Sea (ONLY!), calculates Practical Salinity with a value
computed analytically from Absolute Salinity

sa     : Absolute Salinity                               [g/kg]
lon    : longitude                                       [deg E]
lat    : latitude                                        [deg N]

gsw_sp_from_sa_baltic  : Practical Salinity              [unitless]
*)
// double gsw_sp_from_sa_baltic(double sa, double lon, double lat);
function gsw_sp_from_sa_baltic(sa, lon, lat:double):double; cdecl; external libgswteos;


(*
Calculates Practical salinity, sp, from Absolute salinity, sa

sa     : Absolute Salinity                               [g/kg]
p      : sea pressure                                    [dbar]
lon    : longitude                                       [DEG E]
lat    : latitude                                        [DEG N]

gsw_sp_from_sa      : Practical Salinity                 [unitless]
*)
// double gsw_sp_from_sa(double sa, double p, double lon, double lat);
function gsw_sp_from_sa(sa, p, lon, lat:double):double; cdecl; external libgswteos;


(*
Calculates Practical Salinity, SP, from Knudsen salinity, SK

SK    : Knudsen Salinity                        [parts per thousand, ppt]

gsw_sp_from_sk  : Practical Salinity            [unitless]
*)
// double gsw_sp_from_sk(double sk);
function gsw_sp_from_sk(sk:double):double; cdecl; external libgswteos;


(*
Calculates Practical Salinity, sp, from Reference Salinity, sr.

sr     : Reference Salinity                              [g/kg]

gsw_sp_from_sr  : Practical Salinity                     [unitless]
*)
// double gsw_sp_from_sr(double sr);
function gsw_sp_from_sr(sr:double):double; cdecl; external libgswteos;


(*
Calculates Practical Salinity, SP, from Preformed Salinity, Sstar.

sstar  : Preformed Salinity                              [g/kg]
p      : sea pressure                                    [dbar]
lon   : longitude                                        [deg E]
lat    : latitude                                        [deg N]

gsw_sp_from_Sstar : Preformed Salinity                   [g/kg]
*)
// double gsw_sp_from_sstar(double sstar, double p,double lon,double lat);
function gsw_sp_from_sstar(sstar, p, lon, lat:double):double; cdecl; external libgswteos;


(*
Calculates Practical Salinity SP from a salinometer, primarily using the
PSS-78 algorithm.  Note that the PSS-78 algorithm for Practical Salinity
is only valid in the range 2 < SP < 42.  If the PSS-78 algorithm
produces a Practical Salinity that is less than 2 then the Practical
Salinity is recalculated with a modified form of the Hill et al. (1986)
formula.  The modification of the Hill et al. (1986) expression is to
ensure that it is exactly consistent with PSS-78 at SP = 2.

A laboratory salinometer has the ratio of conductivities, Rt, as an
output, and the present function uses this conductivity ratio and the
temperature t of the salinometer bath as the two input variables.

rt  = C(SP,t_68,0)/C(SP=35,t_68,0)                          [ unitless ]
t   = temperature of the bath of the salinometer,
      measured on the ITS-90 scale (ITS-90)                 [ deg C ]

gsw_sp_salinometer = Practical Salinity on the PSS-78 scale [ unitless ]
*)
// double gsw_sp_salinometer(double rt, double t);
function gsw_sp_salinometer(rt, t:double):double; cdecl; external libgswteos;


(*
Calculates spiciness from Absolute Salinity and Conservative
Temperature at a pressure of 0 dbar, as described by McDougall and
Krzysik (2015).  This routine is based on the computationally-efficient
expression for specific volume in terms of SA, CT and p (Roquet et al.,
2015).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                        [ deg C ]

spiciness0  =  spiciness referenced to a pressure of 0 dbar,
               i.e. the surface                                 [ kg/m^3 ]
*)
// double gsw_spiciness0(double sa, double ct);
function gsw_spiciness0(sa, ct:double):double; cdecl; external libgswteos;


(*
Calculates spiciness from Absolute Salinity and Conservative
Temperature at a pressure of 1000 dbar, as described by McDougall and
Krzysik (2015).  This routine is based on the computationally-efficient
expression for specific volume in terms of SA, CT and p (Roquet et al.,
2015).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]

spiciness1  =  spiciness referenced to a pressure of 1000 dbar [ kg/m^3 ]
*)
// double gsw_spiciness1(double sa, double ct);
function gsw_spiciness1(sa, ct:double):double; cdecl; external libgswteos;


(*
Calculates spiciness from Absolute Salinity and Conservative
Temperature at a pressure of 2000 dbar, as described by McDougall and
Krzysik (2015).  This routine is based on the computationally-efficient
expression for specific volume in terms of SA, CT and p (Roquet et al.,
2015).

SA  =  Absolute Salinity                                        [ g/kg ]
CT  =  Conservative Temperature (ITS-90)                       [ deg C ]

spiciness2  =  spiciness referenced to a pressure of 2000 dbar [ kg/m^3 ]
*)
// double gsw_spiciness2(double sa, double ct);
function gsw_spiciness2(sa, ct:double):double; cdecl; external libgswteos;


(*
Calculates Reference Salinity, SR, from Practical Salinity, SP.

sp     : Practical Salinity                              [unitless]

gsw_sr_from_sp : Reference Salinity                      [g/kg]
*)
// double gsw_sr_from_sp(double sp);
function gsw_sr_from_sp(sp:double):double; cdecl; external libgswteos;


(*
Calculates Preformed Salinity, Sstar, from Absolute Salinity, SA.

sa     : Absolute Salinity                               [g/kg]
p      : sea pressure                                    [dbar]
lon    : longitude                                       [deg E]
lat    : latitude                                        [deg N]

gsw_sstar_from_sa : Preformed Salinity                   [g/kg]
*)
// double gsw_sstar_from_sa(double sa, double p, double lon, double lat);
function gsw_sstar_from_sa(sa, p, lon, lat:double):double; cdecl; external libgswteos;


(*
Calculates Preformed Salinity, Sstar, from Practical Salinity, SP.

sp     : Practical Salinity                              [unitless]
p      : sea pressure                                    [dbar]
lon    : longitude                                       [deg E]
lat    : latitude                                        [deg N]

gsw_sstar_from_sp  : Preformed Salinity                  [g/kg]
*)
// double gsw_sstar_from_sp(double sp, double p, double lon, double lat);
function gsw_sstar_from_sp(sp, p, lon, lat:double):double; cdecl; external libgswteos;


(*
Calculates the temperature derivative of the chemical potential of water
in seawater so that it is valid at exactly SA = 0.

SA  =  Absolute Salinity                                [ g/kg ]
t   =  in-situ temperature (ITS-90)                     [ deg C ]
p   =  sea pressure                                     [ dbar ]
       ( i.e. absolute pressure - 10.1325 dbar )

chem_potential_water_dt  =  temperature derivative of the chemical
                            potential of water in seawater  [ J g^-1 K^-1 ]
*)
function gsw_t_deriv_chem_potential_water_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(*
Calculates the in-situ temperature at which seawater freezes

sa     : Absolute Salinity [g/kg]
p      : sea pressure      [dbar]
         ( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction : the saturation fraction of dissolved air
                      in seawater

t_freezing : in-situ temperature at which seawater freezes. [deg C]
*)
// double gsw_t_freezing(double sa, double p, double saturation_fraction);
function  gsw_t_freezing(sa, p, saturation_fraction:double):double; cdecl; external libgswteos;


(*
Calculates the first derivatives of the in-situ temperature at which
seawater freezes with respect to Absolute Salinity SA and pressure P (in
Pa).  These expressions come from differentiating the expression that
defines the freezing temperature, namely the equality between the
chemical potentials of water in seawater and in ice.

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction = the saturation fraction of dissolved air in
                      seawater

tfreezing_SA = the derivative of the in-situ freezing temperature
               (ITS-90) with respect to Absolute Salinity at fixed
               pressure                     [ K/(g/kg) ] i.e. [ K kg/g ]

tfreezing_P  = the derivative of the in-situ freezing temperature
              (ITS-90) with respect to pressure (in Pa) at fixed
               Absolute Salinity                                [ K/Pa ]
*)
// void   gsw_t_freezing_first_derivatives_poly(double sa, double p, double saturation_fraction, double *tfreezing_sa, double *tfreezing_p);


(*
Calculates the first derivatives of the in-situ temperature at which
seawater freezes with respect to Absolute Salinity SA and pressure P (in
Pa).  These expressions come from differentiating the expression that
defines the freezing temperature, namely the equality between the
chemical potentials of water in seawater and in ice.

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
      ( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction = the saturation fraction of dissolved air in
                      seawater

tfreezing_SA = the derivative of the in-situ freezing temperature
              (ITS-90) with respect to Absolute Salinity at fixed
               pressure                     [ K/(g/kg) ] i.e. [ K kg/g ]

tfreezing_P  = the derivative of the in-situ freezing temperature
               (ITS-90) with respect to pressure (in Pa) at fixed
               Absolute Salinity                                [ K/Pa ]
*)
// void   gsw_t_freezing_first_derivatives(double sa, double p, double saturation_fraction, double *tfreezing_sa, double *tfreezing_p);



(*
Calculates the in-situ temperature at which seawater freezes from a
computationally efficient polynomial.

SA  =  Absolute Salinity                                        [ g/kg ]
p   =  sea pressure                                             [ dbar ]
( i.e. absolute pressure - 10.1325 dbar )
saturation_fraction = the saturation fraction of dissolved air in
seawater

t_freezing = in-situ temperature at which seawater freezes.    [ deg C ]
(ITS-90)
*)
// double gsw_t_freezing_poly(double sa, double p,double saturation_fraction);
function  gsw_t_freezing_poly(sa, p, saturation_fraction:double):double; cdecl; external libgswteos;


(*
Calculates in-situ temperature from Conservative Temperature of seawater

sa      : Absolute Salinity                              [g/kg]
ct      : Conservative Temperature                       [deg C]
gsw_t_from_ct : in-situ temperature                      [deg C]
*)
// double gsw_t_from_ct(double sa, double ct, double p);
function  gsw_t_from_ct(sa, ct, p:double):double; cdecl; external libgswteos;


(* 
Calculates in-situ temperature from the potential temperature of ice Ih
with reference pressure, p_ref, of 0 dbar (the surface), and the
in-situ pressure.

pt0_ice  =  potential temperature of ice Ih with reference pressure of
            zero dbar (ITS-90)                           [ deg C ]
p        =  sea pressure                                 [ dbar ]
           ( i.e. absolute pressure - 10.1325 dbar )
*)
// double gsw_t_from_pt0_ice(double pt0_ice, double p);
function  gsw_t_from_pt0_ice(pt0_ice, p:double):double; cdecl; external libgswteos;


(* 
Calculates the thermobaric coefficient of seawater with respect to
Conservative Temperature.  This routine is based on the
computationally-efficient expression for specific volume in terms of
SA, CT and p (Roquet et al., 2014).

sa     : Absolute Salinity                               [g/kg]
ct     : Conservative Temperature (ITS-90)               [deg C]
p      : sea pressure                                    [dbar]
thermobaric  : thermobaric coefficient with              [1/(K Pa)]
respect to Conservative Temperature (48 term equation)
*)
// double gsw_thermobaric(double sa, double ct, double p);
function  gsw_thermobaric(sa, ct, p:double):double; cdecl; external libgswteos;


(*
Calculates the Turner angle and the Rsubrho as a function of pressure
down a vertical water column.  These quantities express the relative
contributions of the vertical gradients of Conservative Temperature
and Absolute Salinity to the vertical stability (the square of the
Brunt-Vaisala Frequency squared, N^2).  Tu and Rsubrho are evaluated at
the mid pressure between the individual data points in the vertical.

Note that in the double-diffusive literature, papers concerned with
the "diffusive" form of double-diffusive convection often define the
stability ratio as the reciprocal of what is defined here as the
stability ratio.

sa      : Absolute Salinity         (a profile (length nz))     [g/kg]
ct      : Conservative Temperature  (a profile (length nz))     [deg C]
p       : sea pressure              (a profile (length nz))     [dbar]
nz      : number of bottles
tu      : Turner angle, on the same (nz-1) grid as p_mid.
Turner angle has units of:           [ degrees of rotation ]
rsubrho : Stability Ratio, on the same (nz-1) grid as p_mid.
Rsubrho is dimensionless.                       [ unitless ]
p_mid   : Mid pressure between p grid  (length nz-1)           [dbar]
*)
// void   gsw_turner_rsubrho(double *sa, double *ct, double *p, int nz, double *tu, double *rsubrho, double *p_mid);


(*
Finds the index of the value in a monotonically increasing array

x     :  array of monotonically increasing values
n     :  length of the array
z     :  value to be indexed
K      : index K - if X(K) <= Z < X(K+1), or
N-1                      - if Z = X(N)
*)
// int    gsw_util_indx(double *x, int n, double z);


(*
Returns the value of the 1-D function iy (integer) at the points of column
vector x_i using linear interpolation. The vector x specifies the
coordinates of the underlying interval.
*)
// double *gsw_util_interp1q_int(int nx, double *x, int *iy, int nxi, double *x_i, double *y_i);



(*
Returns the values of the functions y{ny} at the points of column
vector x_i using linear interpolation. The vector x specifies the
coordinates of the underlying interval, and the matrix y specifies
the function values at each x coordinate. Note that y has dimensions
nx x ny and y_i has dimensions nxi x ny.
This function was adapted from Matlab's interp1q.
*)
//double *gsw_util_linear_interp(int nx, double *x, int ny, double *y, int nxi, double *x_i, double *y_i);

(*
Sort the double array rarray into ascending value sequence
returning an index array of the sorted result.  This function
is thread-safe.
*)
// void   gsw_util_sort_real(double *rarray, int nx, int *iarray);



(*
Linearly interpolate a real array

x      : y array (Must be monotonic)
y      : y array
n      : length of X and Y arrays
x0     : value to be interpolated
gsw_xinterp1 : Linearly interpolated value
*)
// double gsw_util_xinterp1(double *x, double *y, int n, double x0);


(* 
Calculates the height z from pressure p

NEGATIVE in the ocean

p      : sea pressure                                    [dbar]
lat    : latitude                                        [deg]
geo_strf_dyn_height : dynamic height anomaly             [m^2/s^2]

Note that the reference pressure, p_ref, of geo_strf_dyn_height must
be zero (0) dbar.

sea_surface_geopotential : geopotential at zero sea pressure  [m^2/s^2]

gsw_z_from_p : height                                    [m]                                      [m]
*)
// double gsw_z_from_p(double p, double lat, double geo_strf_dyn_height, double sea_surface_geopotential)
function  gsw_z_from_p(p, lat, geo_strf_dyn_height, sea_surface_geopotential:double):double; cdecl; external libgswteos;


(* 
Calculates the pressure p from height z

z      : height                                          [m]
lat    : latitude                                        [deg]
geo_strf_dyn_height : dynamic height anomaly             [m^2/s^2]

Note that the reference pressure, p_ref, of geo_strf_dyn_height
must be zero (0) dbar.

sea_surface_geopotential : geopotential at zero sea pressure  [m^2/s^2]

gsw_p_from_z : pressure                                  [dbar]                                    [dbar]
*)

function  gsw_p_from_z(z, lat, geo_strf_dyn_height, sea_surface_geopotential:double):double; cdecl; external libgswteos;


implementation

end.
