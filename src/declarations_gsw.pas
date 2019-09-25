unit declarations_gsw;

{$mode objfpc}{$H+}

(*
Gibbs SeaWater (GSW) Oceanographic Toolbox of TEOS–10 (gsw_c_v3.05_1)
http://www.teos-10.org/pubs/gsw/html/gsw_contents.html

These declarations facilitate the use of TEOS-10 functions with Lazarus.

Alexander Smirnov
Arctic and Antarctic Research Institute
St. Petersburg, Russia
2015-2019
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
   sa      - absolute  salinity  [ g/kg ]
   sp      - practical salinity  [ g/kg ]
   sstar   - preformed salinity  [ g/kg ]
   sr      - reference salinity  [ g/kg ]
   sk      - knudsen   salinity  [ g/kg ]
   t       - in situ temperature (ITS-90) [ deg C ]
   pt      - potential temperature [ deg C ]
   ct      - conservative temperature [ deg C ]
   p       - sea pressure  [ dbar ]
   p_ref   - reference pressure [ dbar ] ( i.e. absolute reference pressure - 10.1325 dbar; zero if none )
   pt0_ice - potential temperature of ice [ deg C ] with reference sea pressure (pr) = 0 dbar.
   lon     - longitude
   lat     - latitude
*)

//extern void   gsw_add_barrier(double *input_data, double lon, double lat, double long_grid, double lat_grid, double dlong_grid, double dlat_grid, double *output_data);
//extern void   gsw_add_mean(double *data_in, double *data_out);

//{$IFDEF WINDOWS}
(* Adiabatic lapse rate from Conservative Temperature *)
function gsw_adiabatic_lapse_rate_from_ct(sa, ct, p:double):double; cdecl; external libgswteos;
(* Adiabatic lapse rate of ice *)
function gsw_adiabatic_lapse_rate_ice(t, p:double):double; cdecl; external libgswteos;
(* Thermal expansion coefficient with respect to CT *)
function  gsw_alpha(sa, ct, p:double):double; cdecl; external libgswteos;
(* Alpha divided by beta *)
function  gsw_alpha_on_beta(sa, ct, p:double):double; cdecl; external libgswteos;
(* Thermal expansion coefficient with respect to in-situ temperature *)
function  gsw_alpha_wrt_t_exact(sa, t, p:double):double; cdecl; external libgswteos;
(* Thermal expansion coefficient of ice with respect to in-situ temperature *)
function  gsw_alpha_wrt_t_ice(t, p:double):double; cdecl; external libgswteos;
(* Saline contraction coefficient at constant in-situ temperature *)
function  gsw_beta_const_t_exact(sa, t, p:double):double; cdecl; external libgswteos;
(* Saline contraction coefficient at constant CT *)
function  gsw_beta(sa, ct, p:double):double; cdecl; external libgswteos;
(* Cabbeling coefficient (75-term equation) *)
function  gsw_cabbeling(sa, ct, p:double):double; cdecl; external libgswteos;
(* Conductivity from Practical Salinity (incl. for SP < 2) *)
function  gsw_c_from_sp(sp, t, p:double):double; cdecl; external libgswteos;
(* Chemical potential of water in ice *)
function  gsw_chem_potential_water_ice(t, p:double):double; cdecl; external libgswteos;
(* Chemical potential of water in seawater *)
function  gsw_chem_potential_water_t_exact(sa, t, p:double):double; cdecl; external libgswteos;
(* Isobaric heat capacity of ice *)
function  gsw_cp_ice(t, p:double):double; cdecl; external libgswteos;
(* Isobaric heat capacity *)
function  gsw_cp_t_exact(sa, t, p:double):double; cdecl; external libgswteos;

//extern void   gsw_ct_first_derivatives (double sa, double pt, double *ct_sa, double *ct_pt);
//extern void   gsw_ct_first_derivatives_wrt_t_exact(double sa, double t, double p, double *ct_sa_wrt_t, double *ct_t_wrt_t, double *ct_p_wrt_t);

(* Conservative Temperature freezing point *)
function  gsw_ct_freezing(sa, p, saturation_fraction:double):double; cdecl; external libgswteos;
(* Conservative Temperature at which seawater freezes *)
function  gsw_ct_freezing_exact(sa, p, saturation_fraction:double):double; cdecl; external libgswteos;

//extern void   gsw_ct_freezing_first_derivatives(double sa, double p, double saturation_fraction, double *ctfreezing_sa, double *ctfreezing_p);
//extern void   gsw_ct_freezing_first_derivatives_poly(double sa, double p, double saturation_fraction, double *ctfreezing_sa, double *ctfreezing_p);

(* Conservative Temperature freezing point (poly) *)
function  gsw_ct_freezing_poly(sa, p, saturation_fraction:double):double; cdecl; external libgswteos;
(* Conservative Temperature from specific enthalpy of seawater (75-term equation) *)
function  gsw_ct_from_enthalpy(sa, h, p:double):double; cdecl; external libgswteos;
(* Conservative Temperature as a function of enthalpy *)
function  gsw_ct_from_enthalpy_exact(sa, h, p:double):double; cdecl; external libgswteos;
(* Conservative Temperature as a function of entropy *)
function  gsw_ct_from_entropy(sa, entropy:double):double; cdecl; external libgswteos;
(* Conservative Temperature from potential temperature *)
function  gsw_ct_from_pt(sa, pt:double):double; cdecl; external libgswteos;
(* Conservative Temperature from density (75-term equation) *)
//procedure gsw_ct_from_rho(rho, sa, p:double; Var ct, ct_multiple:double);

(* Conservative Temperature from in-situ temperature *)
function gsw_ct_from_t(sa, t, p:double):double; cdecl; external libgswteos;
(*
extern double gsw_ct_maxdensity(double sa, double p);

//extern void   gsw_ct_second_derivatives(double sa, double pt, double *ct_sa_sa, double *ct_sa_pt, double *ct_pt_pt);

extern double gsw_deltasa_atlas(double p, double lon, double lat);
// Absolute Salinity Anomaly from Practical Salinity
extern double gsw_deltasa_from_sp(double sp, double p, double lon, double lat);
extern double gsw_dilution_coefficient_t_exact(double sa, double t, double p);
extern double gsw_dynamic_enthalpy(double sa, double ct, double p);
extern double gsw_enthalpy_ct_exact(double sa, double ct, double p);
extern double gsw_enthalpy_diff(double sa, double ct, double p_shallow, double p_deep);
extern double gsw_enthalpy(double sa, double ct, double p);

//extern void   gsw_enthalpy_first_derivatives_ct_exact(double sa, double ct, double p, double *h_sa, double *h_ct);
//extern void   gsw_enthalpy_first_derivatives(double sa, double ct, double p, double *h_sa, double *h_ct);

extern double gsw_enthalpy_ice(double t, double p);

//extern void   gsw_enthalpy_second_derivatives_ct_exact(double sa, double ct, double p, double *h_sa_sa, double *h_sa_ct, double *h_ct_ct);
//extern void   gsw_enthalpy_second_derivatives(double sa, double ct, double p, double *h_sa_sa, double *h_sa_ct, double *h_ct_ct);

extern double gsw_enthalpy_sso_0(double p);
extern double gsw_enthalpy_t_exact(double sa, double t, double p);

//extern void   gsw_entropy_first_derivatives(double sa, double ct, double *eta_sa, double *eta_ct);

extern double gsw_entropy_from_pt(double sa, double pt);
extern double gsw_entropy_from_t(double sa, double t, double p);
extern double gsw_entropy_ice(double t, double p);
extern double gsw_entropy_part(double sa, double t, double p);
extern double gsw_entropy_part_zerop(double sa, double pt0);

//extern void   gsw_entropy_second_derivatives(double sa, double ct, double *eta_sa_sa, double *eta_sa_ct, double *eta_ct_ct);

extern double gsw_fdelta(double p, double lon, double lat);

//extern void   gsw_frazil_properties(double sa_bulk, double h_bulk, double p, double *sa_final, double *ct_final, double *w_ih_final);
//extern void   gsw_frazil_properties_potential(double sa_bulk, double h_pot_bulk, double p, double *sa_final, double *ct_final, double *w_ih_final);
//extern void   gsw_frazil_properties_potential_poly(double sa_bulk, double h_pot_bulk, double p, double *sa_final, double *ct_final, double *w_ih_final);
//extern void   gsw_frazil_ratios_adiabatic(double sa, double p, double w_ih, double *dsa_dct_frazil, double *dsa_dp_frazil, double *dct_dp_frazil);
//extern void   gsw_frazil_ratios_adiabatic_poly(double sa, double p, double w_ih, double *dsa_dct_frazil, double *dsa_dp_frazil, double *dct_dp_frazil);

extern double *gsw_geo_strf_dyn_height(double *sa, double *ct, double *p, double p_ref, int n_levels, double *dyn_height);
extern double *gsw_geo_strf_dyn_height_pc(double *sa, double *ct, double *delta_p, int n_levels, double *geo_strf_dyn_height_pc, double *p_mid);
extern double gsw_gibbs_ice (int nt, int np, double t, double p);
extern double gsw_gibbs_ice_part_t(double t, double p);
extern double gsw_gibbs_ice_pt0(double pt0);
extern double gsw_gibbs_ice_pt0_pt0(double pt0);
extern double gsw_gibbs(int ns, int nt, int np, double sa, double t, double p);
extern double gsw_gibbs_pt0_pt0(double sa, double pt0);
*)
function gsw_grav(lat, p:double):double; cdecl; external libgswteos;
function gsw_helmholtz_energy_ice(t, p:double):double; cdecl; external libgswteos;
(*
extern double gsw_hill_ratio_at_sp2(double t);

//extern void   gsw_ice_fraction_to_freeze_seawater(double sa, double ct, double p, double t_ih, double *sa_freeze, double *ct_freeze, double *w_ih);

extern double gsw_internal_energy(double sa, double ct, double p);
extern double gsw_internal_energy_ice(double t, double p);

//extern void   gsw_ipv_vs_fnsquared_ratio(double *sa, double *ct, double *p, double p_ref, int nz, double *ipv_vs_fnsquared_ratio, double *p_mid);

extern double gsw_kappa_const_t_ice(double t, double p);
extern double gsw_kappa(double sa, double ct, double p);
extern double gsw_kappa_ice(double t, double p);
extern double gsw_kappa_t_exact(double sa, double t, double p);
extern double gsw_latentheat_evap_ct(double sa, double ct);
extern double gsw_latentheat_evap_t(double sa, double t);
extern double gsw_latentheat_melting(double sa, double p);

//extern void   gsw_linear_interp_sa_ct(double *sa, double *ct, double *p, int np, double *p_i, int npi, double *sa_i, double *ct_i);

extern double gsw_melting_ice_equilibrium_sa_ct_ratio(double sa, double p);
extern double gsw_melting_ice_equilibrium_sa_ct_ratio_poly(double sa, double p);

//extern void   gsw_melting_ice_into_seawater(double sa, double ct, double p, double w_ih, double t_ih, double *sa_final, double *ct_final, double *w_ih_final);

extern double gsw_melting_ice_sa_ct_ratio(double sa, double ct, double p, double t_ih);
extern double gsw_melting_ice_sa_ct_ratio_poly(double sa, double ct, double p, double t_ih);
extern double gsw_melting_seaice_equilibrium_sa_ct_ratio(double sa, double p);
extern double gsw_melting_seaice_equilibrium_sa_ct_ratio_poly(double sa, double p);

//extern void   gsw_melting_seaice_into_seawater(double sa, double ct, double p, double w_seaice, double sa_seaice, double t_seaice, double *sa_final, double *ct_final);

extern double gsw_melting_seaice_sa_ct_ratio(double sa, double ct, double p, double sa_seaice, double t_seaice);
extern double gsw_melting_seaice_sa_ct_ratio_poly(double sa, double ct, double p, double sa_seaice, double t_seaice);

//extern void   gsw_nsquared(double *sa, double *ct, double *p, double *lat, int nz, double *n2, double *p_mid);

extern double gsw_pot_enthalpy_from_pt_ice(double pt0_ice);
extern double gsw_pot_enthalpy_from_pt_ice_poly(double pt0_ice);
extern double gsw_pot_enthalpy_ice_freezing(double sa, double p);

//extern void   gsw_pot_enthalpy_ice_freezing_first_derivatives(double sa, double p, double *pot_enthalpy_ice_freezing_sa, double *pot_enthalpy_ice_freezing_p);
//extern void   gsw_pot_enthalpy_ice_freezing_first_derivatives_poly(double sa, double p, double *pot_enthalpy_ice_freezing_sa, double *pot_enthalpy_ice_freezing_p);

extern double gsw_pot_enthalpy_ice_freezing_poly(double sa, double p);
extern double gsw_pot_rho_t_exact(double sa, double t, double p, double p_ref);
extern double gsw_pressure_coefficient_ice(double t, double p);
extern double gsw_pressure_freezing_ct(double sa, double ct, double saturation_fraction);
extern double gsw_pt0_cold_ice_poly(double pot_enthalpy_ice);
extern double gsw_pt0_from_t(double sa, double t, double p);
extern double gsw_pt0_from_t_ice(double t, double p);
*)

//extern void   gsw_pt_first_derivatives (double sa, double ct, double *pt_sa, double *pt_ct);

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

//extern void   gsw_rho_first_derivatives(double sa, double ct, double p, double *drho_dsa, double *drho_dct, double *drho_dp);
//extern void   gsw_rho_first_derivatives_wrt_enthalpy (double sa, double ct, double p, double *rho_sa, double *rho_h);

(* In-situ density of ice *)
function gsw_rho_ice(t, p:double):double; cdecl; external libgswteos;

//extern void   gsw_rho_second_derivatives(double sa, double ct, double p, double *rho_sa_sa, double *rho_sa_ct, double *rho_ct_ct, double *rho_sa_p, double *rho_ct_p);
//extern void   gsw_rho_second_derivatives_wrt_enthalpy(double sa, double ct, double p, double *rho_sa_sa, double *rho_sa_h, double *rho_h_h);

(* In-situ density of seawater *)
function gsw_rho_t_exact(sa, t, p:double):double; cdecl; external libgswteos;

//extern void   gsw_rr68_interp_sa_ct(double *sa, double *ct, double *p, int mp, double *p_i, int mp_i, double *sa_i, double *ct_i);

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
(*
extern int    gsw_sa_p_inrange(double sa, double p);

//extern void   gsw_seaice_fraction_to_freeze_seawater(double sa, double ct, double p, double sa_seaice, double t_seaice, double *sa_freeze, double *ct_freeze, double *w_seaice);

extern double gsw_sigma0(double sa, double ct);
extern double gsw_sigma1(double sa, double ct);
extern double gsw_sigma2(double sa, double ct);
extern double gsw_sigma3(double sa, double ct);
extern double gsw_sigma4(double sa, double ct);
extern double gsw_sound_speed(double sa, double ct, double p);
extern double gsw_sound_speed_ice(double t, double p);
extern double gsw_sound_speed_t_exact(double sa, double t, double p);

//extern void   gsw_specvol_alpha_beta(double sa, double ct, double p, double *specvol, double *alpha, double *beta);

extern double gsw_specvol_anom_standard(double sa, double ct, double p);
extern double gsw_specvol(double sa, double ct, double p);

//extern void   gsw_specvol_first_derivatives(double sa, double ct, double p, double *v_sa, double *v_ct, double *v_p);
//extern void   gsw_specvol_first_derivatives_wrt_enthalpy(double sa, double ct, double p, double *v_sa, double *v_h);

extern double gsw_specvol_ice(double t, double p);

//extern void   gsw_specvol_second_derivatives (double sa, double ct, double p, double *v_sa_sa, double *v_sa_ct, double *v_ct_ct, double *v_sa_p, double *v_ct_p);
//extern void   gsw_specvol_second_derivatives_wrt_enthalpy(double sa, double ct, double p, double *v_sa_sa, double *v_sa_h, double *v_h_h);
*)
(* specific volume at the Standard Ocean Salinty, SSO, and at a Conservative Temperature of zero degrees C *)
function gsw_specvol_sso_0(p:double):double; cdecl; external libgswteos;
(* Specific volume of seawater *)
function gsw_specvol_t_exact(sa, t, p:double):double; cdecl; external libgswteos;
(* Practical Salinity from conductivity, C (incl. for SP < 2) *)
function gsw_sp_from_c(c, t, p:double):double; cdecl; external libgswteos;
(* Practical Salinity for the Baltic Sea ONLY *)
function gsw_sp_from_sa_baltic(sa, lon, lat:double):double; cdecl; external libgswteos;
(* Practical Salinity from Absolute Salinity *)
function gsw_sp_from_sa(sa, p, lon, lat:double):double; cdecl; external libgswteos;
(* Practical Salinity from Knudsen Salinity *)
function gsw_sp_from_sk(sk:double):double; cdecl; external libgswteos;
(* Practical Salinity from Reference Salinity *)
function gsw_sp_from_sr(sr:double):double; cdecl; external libgswteos;
(* Practical Salinity from Preformed Salinity *)
function gsw_sp_from_sstar(sstar, p, lon, lat:double):double; cdecl; external libgswteos;
(* Spiciness at p = 0 dbar (75-term equation) *)
function gsw_spiciness0(sa, ct:double):double; cdecl; external libgswteos;
(* Spiciness at p = 1000 dbar (75-term equation) *)
function gsw_spiciness1(sa, ct:double):double; cdecl; external libgswteos;
(* Spiciness at p = 2000 dbar (75-term equation) *)
function gsw_spiciness2(sa, ct:double):double; cdecl; external libgswteos;
(* Reference Salinity from Practical Salinity *)
function gsw_sr_from_sp(sp:double):double; cdecl; external libgswteos;
(* Preformed Salinity from Absolute Salinity *)
function gsw_sstar_from_sa(sa, p, lon, lat:double):double; cdecl; external libgswteos;
(* Preformed Salinity from Practical Salinity *)
function gsw_sstar_from_sp(sp, p, lon, lat:double):double; cdecl; external libgswteos;
(* Temperature derivative of the chemical potential of water in seawater *)
function gsw_t_deriv_chem_potential_water_t_exact(sa, t, p:double):double; cdecl; external libgswteos;
(* In-situ temperature freezing point *)
function gsw_t_freezing(sa, p, saturation_fraction:double):double; cdecl; external libgswteos;
(* In-situ temperature at which seawater freezes *)
function gsw_t_freezing_exact(sa, p, saturation_fraction:double):double; cdecl; external libgswteos;

//extern void   gsw_t_freezing_first_derivatives_poly(double sa, double p, double saturation_fraction, double *tfreezing_sa, double *tfreezing_p);
//extern void   gsw_t_freezing_first_derivatives(double sa, double p, double saturation_fraction, double *tfreezing_sa, double *tfreezing_p);

(* In-situ temperature freezing point (poly) *)
function gsw_t_freezing_poly(sa, p, saturation_fraction:double; polynomial:integer):double; cdecl; external libgswteos;
(* In-situ temperature from Conservative Temperature *)
function gsw_t_from_ct(sa, ct, p:double):double; cdecl; external libgswteos;
(* In-situ temperature of ice from potential temperature with p_ref = 0 dbar *)
function gsw_t_from_pt0_ice(pt0_ice, p:double):double; cdecl; external libgswteos;
(* Thermobaric coefficient (75-term equation) *)
function gsw_thermobaric(sa, ct, p:double):double; cdecl; external libgswteos;

//extern void   gsw_turner_rsubrho(double *sa, double *ct, double *p, int nz, double *tu, double *rsubrho, double *p_mid);
//extern int    gsw_util_indx(double *x, int n, double z);
//extern double *gsw_util_interp1q_int(int nx, double *x, int *iy, int nxi, double *x_i, double *y_i);
//extern void   gsw_util_sort_real(double *rarray, int nx, int *iarray);
//extern double gsw_util_xinterp1(double *x, double *y, int n, double x0);

(* Height from pressure (75-term equation), NEGATIVE in the ocean *)
function gsw_z_from_p(p, lat:double):double; cdecl; external libgswteos;
//{$ENDIF}

implementation

end.
