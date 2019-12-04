unit declarations_gsw;

{$mode objfpc}{$H+}

(*
Gibbs SeaWater (GSW) Oceanographic Toolbox of TEOS–10 (gsw_c_v3.05)
http://www.teos-10.org/pubs/gsw/html/gsw_contents.html

These declarations facilitate the use of TEOS-10
functions with Lazarus/FreePascal.

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

//extern void   gsw_add_barrier(double *input_data, double lon, double lat, double long_grid, double lat_grid, double dlong_grid, double dlat_grid, double *output_data);
//extern void   gsw_add_mean(double *data_in, double *data_out);


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


// extern void   gsw_ct_first_derivatives (double sa, double pt, double *ct_sa, double *ct_pt);
// extern void   gsw_ct_first_derivatives_wrt_t_exact(double sa, double t, double p, double *ct_sa_wrt_t, double *ct_t_wrt_t, double *ct_p_wrt_t);


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


// extern void   gsw_ct_freezing_first_derivatives(double sa, double p, double saturation_fraction, double *ctfreezing_sa, double *ctfreezing_p);
// extern void   gsw_ct_freezing_first_derivatives_poly(double sa, double p, double saturation_fraction, double *ctfreezing_sa, double *ctfreezing_p);


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
//   void   gsw_ct_from_rho(double rho, double sa, double p, double *ct, double *ct_multiple);
//procedure gsw_ct_from_rho(rho, sa, p:double; Var ct, ct_multiple:double);


(*
Calculates Conservative Temperature from in-situ temperature

sa     : Absolute Salinity                               [g/kg]
t      : in-situ temperature                             [deg C]
p      : sea pressure                                    [dbar]

gsw_ct_from_t : Conservative Temperature                 [deg C]
*)
// double gsw_ct_from_t(double sa, double t, double p);
function  gsw_ct_from_t(sa, t, p:double):double; cdecl; external libgswteos;


// extern double gsw_ct_maxdensity(double sa, double p);
// extern void   gsw_ct_second_derivatives(double sa, double pt, double *ct_sa_sa, double *ct_sa_pt, double *ct_pt_pt);
// extern double gsw_deltasa_atlas(double p, double lon, double lat);
// extern double gsw_deltasa_from_sp(double sp, double p, double lon, double lat);
// extern double gsw_dilution_coefficient_t_exact(double sa, double t, double p);
// extern double gsw_dynamic_enthalpy(double sa, double ct, double p);
// extern double gsw_enthalpy_ct_exact(double sa, double ct, double p);
// extern double gsw_enthalpy_diff(double sa, double ct, double p_shallow, double p_deep);
// extern double gsw_enthalpy(double sa, double ct, double p);
// extern void   gsw_enthalpy_first_derivatives_ct_exact(double sa, double ct, double p, double *h_sa, double *h_ct);
// extern void   gsw_enthalpy_first_derivatives(double sa, double ct, double p, double *h_sa, double *h_ct);
// extern double gsw_enthalpy_ice(double t, double p);
// extern void   gsw_enthalpy_second_derivatives_ct_exact(double sa, double ct, double p, double *h_sa_sa, double *h_sa_ct, double *h_ct_ct);
// extern void   gsw_enthalpy_second_derivatives(double sa, double ct, double p, double *h_sa_sa, double *h_sa_ct, double *h_ct_ct);
// extern double gsw_enthalpy_sso_0(double p);
// extern double gsw_enthalpy_t_exact(double sa, double t, double p);
// extern void   gsw_entropy_first_derivatives(double sa, double ct, double *eta_sa, double *eta_ct);
// extern double gsw_entropy_from_pt(double sa, double pt);
// extern double gsw_entropy_from_t(double sa, double t, double p);
// extern double gsw_entropy_ice(double t, double p);
// extern double gsw_entropy_part(double sa, double t, double p);
// extern double gsw_entropy_part_zerop(double sa, double pt0);
// extern void   gsw_entropy_second_derivatives(double sa, double ct, double *eta_sa_sa, double *eta_sa_ct, double *eta_ct_ct);
// extern double gsw_fdelta(double p, double lon, double lat);
// extern void   gsw_frazil_properties(double sa_bulk, double h_bulk, double p, double *sa_final, double *ct_final, double *w_ih_final);
// extern void   gsw_frazil_properties_potential(double sa_bulk, double h_pot_bulk, double p, double *sa_final, double *ct_final, double *w_ih_final);
// extern void   gsw_frazil_properties_potential_poly(double sa_bulk, double h_pot_bulk, double p, double *sa_final, double *ct_final, double *w_ih_final);
// extern void   gsw_frazil_ratios_adiabatic(double sa, double p, double w_ih, double *dsa_dct_frazil, double *dsa_dp_frazil, double *dct_dp_frazil);
// extern void   gsw_frazil_ratios_adiabatic_poly(double sa, double p, double w_ih, double *dsa_dct_frazil, double *dsa_dp_frazil, double *dct_dp_frazil);
// extern double *gsw_geo_strf_dyn_height(double *sa, double *ct, double *p, double p_ref, int n_levels, double *dyn_height);
// extern double *gsw_geo_strf_dyn_height_pc(double *sa, double *ct, double *delta_p, int n_levels, double *geo_strf_dyn_height_pc, double *p_mid);
// extern double gsw_gibbs_ice (int nt, int np, double t, double p);
// extern double gsw_gibbs_ice_part_t(double t, double p);
// extern double gsw_gibbs_ice_pt0(double pt0);
// extern double gsw_gibbs_ice_pt0_pt0(double pt0);
// extern double gsw_gibbs(int ns, int nt, int np, double sa, double t, double p);
// extern double gsw_gibbs_pt0_pt0(double sa, double pt0);


// double gsw_grav(double lat, double p);
function  gsw_grav(lat, p:double):double; cdecl; external libgswteos;


// double gsw_helmholtz_energy_ice(double t, double p);
function  gsw_helmholtz_energy_ice(t, p:double):double; cdecl; external libgswteos;


// extern double gsw_hill_ratio_at_sp2(double t);
// extern void   gsw_ice_fraction_to_freeze_seawater(double sa, double ct, double p, double t_ih, double *sa_freeze, double *ct_freeze, double *w_ih);
// extern double gsw_internal_energy(double sa, double ct, double p);
// extern double gsw_internal_energy_ice(double t, double p);
// extern void   gsw_ipv_vs_fnsquared_ratio(double *sa, double *ct, double *p, double p_ref, int nz, double *ipv_vs_fnsquared_ratio, double *p_mid);
// extern double gsw_kappa_const_t_ice(double t, double p);
// extern double gsw_kappa(double sa, double ct, double p);
// extern double gsw_kappa_ice(double t, double p);
// extern double gsw_kappa_t_exact(double sa, double t, double p);
// extern double gsw_latentheat_evap_ct(double sa, double ct);
// extern double gsw_latentheat_evap_t(double sa, double t);
// extern double gsw_latentheat_melting(double sa, double p);
// extern void   gsw_linear_interp_sa_ct(double *sa, double *ct, double *p, int np, double *p_i, int npi, double *sa_i, double *ct_i);
// extern double gsw_melting_ice_equilibrium_sa_ct_ratio(double sa, double p);
// extern double gsw_melting_ice_equilibrium_sa_ct_ratio_poly(double sa, double p);
// extern void   gsw_melting_ice_into_seawater(double sa, double ct, double p, double w_ih, double t_ih, double *sa_final, double *ct_final, double *w_ih_final);
// extern double gsw_melting_ice_sa_ct_ratio(double sa, double ct, double p, double t_ih);
// extern double gsw_melting_ice_sa_ct_ratio_poly(double sa, double ct, double p, double t_ih);
// extern double gsw_melting_seaice_equilibrium_sa_ct_ratio(double sa, double p);
// extern double gsw_melting_seaice_equilibrium_sa_ct_ratio_poly(double sa, double p);
// extern void   gsw_melting_seaice_into_seawater(double sa, double ct, double p, double w_seaice, double sa_seaice, double t_seaice, double *sa_final, double *ct_final);
// extern double gsw_melting_seaice_sa_ct_ratio(double sa, double ct, double p, double sa_seaice, double t_seaice);
// extern double gsw_melting_seaice_sa_ct_ratio_poly(double sa, double ct, double p, double sa_seaice, double t_seaice);
// extern void   gsw_nsquared(double *sa, double *ct, double *p, double *lat, int nz, double *n2, double *p_mid);
// extern double gsw_pot_enthalpy_from_pt_ice(double pt0_ice);
// extern double gsw_pot_enthalpy_from_pt_ice_poly(double pt0_ice);
// extern double gsw_pot_enthalpy_ice_freezing(double sa, double p);
// extern void   gsw_pot_enthalpy_ice_freezing_first_derivatives(double sa, double p, double *pot_enthalpy_ice_freezing_sa, double *pot_enthalpy_ice_freezing_p);
// extern void   gsw_pot_enthalpy_ice_freezing_first_derivatives_poly(double sa, double p, double *pot_enthalpy_ice_freezing_sa, double *pot_enthalpy_ice_freezing_p);
// extern double gsw_pot_enthalpy_ice_freezing_poly(double sa, double p);
// extern double gsw_pot_rho_t_exact(double sa, double t, double p, double p_ref);
// extern double gsw_pressure_coefficient_ice(double t, double p);
// extern double gsw_pressure_freezing_ct(double sa, double ct, double saturation_fraction);
// extern double gsw_pt0_cold_ice_poly(double pot_enthalpy_ice);
// extern double gsw_pt0_from_t(double sa, double t, double p);
// extern double gsw_pt0_from_t_ice(double t, double p);
// extern void   gsw_pt_first_derivatives (double sa, double ct, double *pt_sa, double *pt_ct);


(* Potential temperature from Conservative Temperature *)
function gsw_pt_from_ct(sa, ct:double):double; cdecl; external libgswteos;


(* Potential temperature with a reference sea pressure of zero dbar as a function of entropy *)
function gsw_pt_from_entropy(sa, entropy:double):double; cdecl; external libgswteos;


(* Potential temperature of ice with a reference sea pressure of zero dbar from the potential enthalpy of ice *)
function gsw_pt_from_pot_enthalpy_ice(pot_enthalpy_ice:double):double; cdecl; external libgswteos;


(* Вerivative of potential temperature of ice with respect to potential enthalpy *)
function gsw_pt_from_pot_enthalpy_ice_poly_dh(pot_enthalpy_ice:double):double; cdecl; external libgswteos;


(* Potential temperature of ice with a reference sea pressure of zero dbar from the potential enthalpy of ice (polynomial) *)
function gsw_pt_from_pot_enthalpy_ice_poly(pot_enthalpy_ice:double):double; cdecl; external libgswteos;


(* Potential temperature *)
function gsw_pt_from_t(sa, t, p, p_ref:double):double; cdecl; external libgswteos;


(* Potential temperature of ice  *)
function gsw_pt_from_t_ice(t, p, p_ref:double):double; cdecl; external libgswteos;


//extern void   gsw_pt_second_derivatives (double sa, double ct, double *pt_sa_sa, double *pt_sa_ct, double *pt_ct_ct);
//extern void   gsw_rho_alpha_beta (double sa, double ct, double p, double *rho, double *alpha, double *beta);


(* In-situ density (75-term equation) *)
function gsw_rho(sa, ct, p:double):double; cdecl; external libgswteos;


// extern void   gsw_rho_first_derivatives(double sa, double ct, double p, double *drho_dsa, double *drho_dct, double *drho_dp);
// extern void   gsw_rho_first_derivatives_wrt_enthalpy (double sa, double ct, double p, double *rho_sa, double *rho_h);


(* In-situ density of ice *)
function gsw_rho_ice(t, p:double):double; cdecl; external libgswteos;

// extern void   gsw_rho_second_derivatives(double sa, double ct, double p, double *rho_sa_sa, double *rho_sa_ct, double *rho_ct_ct, double *rho_sa_p, double *rho_ct_p);
// extern void   gsw_rho_second_derivatives_wrt_enthalpy(double sa, double ct, double p, double *rho_sa_sa, double *rho_sa_h, double *rho_h_h);


(* In-situ density of seawater *)
function gsw_rho_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


// extern void   gsw_rr68_interp_sa_ct(double *sa, double *ct, double *p, int mp, double *p_i, int mp_i, double *sa_i, double *ct_i);


(* Absolute Salinity Anomaly Ratio *)
function gsw_saar(p, lon, lat:double):double; cdecl; external libgswteos;


(* Form an estimate of SA from a polynomial in CT and p *)
function gsw_sa_freezing_estimate(p, saturation_fraction:double):double; cdecl; external libgswteos;


(* Absolute Salinity of seawater at the freezing point *)
function gsw_sa_freezing_from_ct(ct, p, saturation_fraction:double):double; cdecl; external libgswteos;


(* Absolute Salinity of seawater at the freezing point (poly) *)
function gsw_freezing_from_ct_poly(ct, p, saturation_fraction:double):double; cdecl; external libgswteos;


(* Absolute Salinity of seawater at the freezing point *)
function gsw_sa_freezing_from_t(t, p, saturation_fraction:double):double; cdecl; external libgswteos;


(* Absolute Salinity of seawater at the freezing point (poly) *)
function gsw_sa_freezing_from_t_poly(t, p, saturation_fraction:double):double; cdecl; external libgswteos;


(* Absolute Salinity from density (48-term equation) *)
function gsw_sa_from_rho(rho, ct, p:double):double; cdecl; external libgswteos;


(* Absolute Salinity in the Baltic Sea *)
function gsw_sa_from_sp_baltic(sp, lon, lat:double):double; cdecl; external libgswteos;


(* Absolute Salinity from Practical Salinity *)
function gsw_sa_from_sp(sp, p, lon, lat:double):double; cdecl; external libgswteos;


(* Absolute Salinity from Preformed Salinity *)
function gsw_sa_from_sstar(sstar, p, lon, lat:double):double; cdecl; external libgswteos;


// extern int    gsw_sa_p_inrange(double sa, double p);
// extern void   gsw_seaice_fraction_to_freeze_seawater(double sa, double ct, double p, double sa_seaice, double t_seaice, double *sa_freeze, double *ct_freeze, double *w_seaice);
// extern double gsw_sigma0(double sa, double ct);
// extern double gsw_sigma1(double sa, double ct);
// extern double gsw_sigma2(double sa, double ct);
// extern double gsw_sigma3(double sa, double ct);
// extern double gsw_sigma4(double sa, double ct);
// extern double gsw_sound_speed(double sa, double ct, double p);
// extern double gsw_sound_speed_ice(double t, double p);
// extern double gsw_sound_speed_t_exact(double sa, double t, double p);
// extern void   gsw_specvol_alpha_beta(double sa, double ct, double p, double *specvol, double *alpha, double *beta);
// extern double gsw_specvol_anom_standard(double sa, double ct, double p);
// extern double gsw_specvol(double sa, double ct, double p);
// extern void   gsw_specvol_first_derivatives(double sa, double ct, double p, double *v_sa, double *v_ct, double *v_p);
// extern void   gsw_specvol_first_derivatives_wrt_enthalpy(double sa, double ct, double p, double *v_sa, double *v_h);
// extern double gsw_specvol_ice(double t, double p);
// extern void   gsw_specvol_second_derivatives (double sa, double ct, double p, double *v_sa_sa, double *v_sa_ct, double *v_ct_ct, double *v_sa_p, double *v_ct_p);
// extern void   gsw_specvol_second_derivatives_wrt_enthalpy(double sa, double ct, double p, double *v_sa_sa, double *v_sa_h, double *v_h_h);



(* specific volume at the Standard Ocean Salinty, SSO, and at a Conservative Temperature of zero degrees C *)
// double gsw_specvol_sso_0(double p);
function gsw_specvol_sso_0(p:double):double; cdecl; external libgswteos;


(* Specific volume of seawater *)
// double gsw_specvol_t_exact(double sa, double t, double p);
function gsw_specvol_t_exact(sa, t, p:double):double; cdecl; external libgswteos;


(* Practical Salinity from conductivity, C (incl. for SP < 2) *)
// double gsw_sp_from_c(double c, double t, double p);
function gsw_sp_from_c(c, t, p:double):double; cdecl; external libgswteos;


(* Practical Salinity for the Baltic Sea ONLY *)
// double gsw_sp_from_sa_baltic(double sa, double lon, double lat);
function gsw_sp_from_sa_baltic(sa, lon, lat:double):double; cdecl; external libgswteos;


(* Practical Salinity from Absolute Salinity *)
// double gsw_sp_from_sa(double sa, double p, double lon, double lat);
function gsw_sp_from_sa(sa, p, lon, lat:double):double; cdecl; external libgswteos;


(* Practical Salinity from Knudsen Salinity *)
// double gsw_sp_from_sk(double sk);
function gsw_sp_from_sk(sk:double):double; cdecl; external libgswteos;


(* Practical Salinity from Reference Salinity *)
// double gsw_sp_from_sr(double sr);
function gsw_sp_from_sr(sr:double):double; cdecl; external libgswteos;


(* Practical Salinity from Preformed Salinity *)
// double gsw_sp_from_sstar(double sstar, double p,double lon,double lat);
function gsw_sp_from_sstar(sstar, p, lon, lat:double):double; cdecl; external libgswteos;


(* Spiciness at p = 0 dbar (75-term equation) *)
// double gsw_spiciness0(double sa, double ct);
function gsw_spiciness0(sa, ct:double):double; cdecl; external libgswteos;


(* Spiciness at p = 1000 dbar (75-term equation) *)
// double gsw_spiciness1(double sa, double ct);
function gsw_spiciness1(sa, ct:double):double; cdecl; external libgswteos;


(* Spiciness at p = 2000 dbar (75-term equation) *)
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
// extern double gsw_sstar_from_sp(double sp, double p, double lon, double lat); 
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
// extern double gsw_t_freezing(double sa, double p, double saturation_fraction); 
function gsw_t_freezing(sa, p, saturation_fraction:double):double; cdecl; external libgswteos;


(* In-situ temperature at which seawater freezes *)
function gsw_t_freezing_exact(sa, p, saturation_fraction:double):double; cdecl; external libgswteos;


// extern void   gsw_t_freezing_first_derivatives_poly(double sa, double p, double saturation_fraction, double *tfreezing_sa, double *tfreezing_p);
// extern void   gsw_t_freezing_first_derivatives(double sa, double p, double saturation_fraction, double *tfreezing_sa, double *tfreezing_p);


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
// extern double gsw_t_freezing_poly(double sa, double p,double saturation_fraction);
function gsw_t_freezing_poly(sa, p, saturation_fraction:double; polynomial:integer):double; cdecl; external libgswteos;


(*
Calculates in-situ temperature from Conservative Temperature of seawater

sa      : Absolute Salinity                              [g/kg]
ct      : Conservative Temperature                       [deg C]
gsw_t_from_ct : in-situ temperature                      [deg C]
*)
// extern double gsw_t_from_ct(double sa, double ct, double p);
function gsw_t_from_ct(sa, ct, p:double):double; cdecl; external libgswteos;


(* 
Calculates in-situ temperature from the potential temperature of ice Ih
with reference pressure, p_ref, of 0 dbar (the surface), and the
in-situ pressure.

pt0_ice  =  potential temperature of ice Ih with reference pressure of
            zero dbar (ITS-90)                           [ deg C ]
p        =  sea pressure                                 [ dbar ]
           ( i.e. absolute pressure - 10.1325 dbar )
*)
// extern double gsw_t_from_pt0_ice(double pt0_ice, double p);
function gsw_t_from_pt0_ice(pt0_ice, p:double):double; cdecl; external libgswteos;


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
// extern double gsw_thermobaric(double sa, double ct, double p);
function gsw_thermobaric(sa, ct, p:double):double; cdecl; external libgswteos;


// extern void   gsw_turner_rsubrho(double *sa, double *ct, double *p, int nz, double *tu, double *rsubrho, double *p_mid);
// extern int    gsw_util_indx(double *x, int n, double z);
// extern double *gsw_util_interp1q_int(int nx, double *x, int *iy, int nxi, double *x_i, double *y_i);
// extern void   gsw_util_sort_real(double *rarray, int nx, int *iarray);
// extern double gsw_util_xinterp1(double *x, double *y, int n, double x0);


(* 
Calculates the height z from pressure p (75-term equation) 
NEGATIVE in the ocean
p            : sea pressure                                [dbar]
lat          : latitude                                    [deg]
gsw_z_from_p : height                                      [m]
*)
// extern double gsw_z_from_p(double p, double lat);
function gsw_z_from_p(p, lat:double):double; cdecl; external libgswteos;


(* 
Calculates the pressure p from height z (75-term equation) 
z            : height                                      [m]
lat          : latitude                                    [deg]
gsw_p_from_z : pressure                                    [dbar]
*)
// extern double gsw_p_from_z(double z, double lat);
function gsw_p_from_z(z, lat:double):double; cdecl; external libgswteos;


implementation

end.
