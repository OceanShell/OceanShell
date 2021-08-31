unit osunitsconversion_exact;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, osmain, dm, gibbsseawater, dynlibs;

procedure GetDefaultUnitsExact(par:string; units, units_default, ID,
  instr_id, prof_num: integer; val_in, Lat, Lon, LEV_M: real;
  Var val_out:real; Var isconverted:boolean);


implementation


(* Use density calculated from in situ salinity and T=22 deg C,  atmospheric pressure = 1 ATM  *)
procedure GetDefaultUnitsExact(par:string; units, units_default, ID,
  instr_id, prof_num: integer; val_in, Lat, Lon, LEV_M: real;
  Var val_out:real; Var isconverted:boolean);
Var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;

  SA, sp, p, p_ref, t, t_lab, lab_dens, pot_dens, pot_temp, LEV_DBAR:real;

  gsw_sa_from_sp:Tgsw_sa_from_sp;
  gsw_rho_t_exact:Tgsw_rho_t_exact;
  gsw_pt_from_t:Tgsw_pt_from_t;
begin
 val_out:=-9999;

 try
   TRt:=TSQLTransaction.Create(nil);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(nil);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   sp:=-9999; t:=-9999;
   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT P_TEMPERATURE.VAL AS TVAL, ');
     SQL.Add(' P_TEMPERATURE.LEV_DBAR AS TLEV, ');
     SQL.Add(' P_SALINITY.VAL AS SVAL ');
     SQL.Add(' FROM P_TEMPERATURE, P_SALINITY ');
     SQL.Add(' WHERE ');
     SQL.Add(' P_SALINITY.ID=P_TEMPERATURE.ID AND ');
     SQL.Add(' P_SALINITY.LEV_M=P_TEMPERATURE.LEV_M AND ');
     SQL.Add(' P_SALINITY.INSTRUMENT_ID=P_TEMPERATURE.INSTRUMENT_ID AND ');
     SQL.Add(' P_SALINITY.PROFILE_NUMBER=P_TEMPERATURE.PROFILE_NUMBER AND ');
     SQL.Add(' P_SALINITY.ID=:ID AND ');
     SQL.Add(' P_SALINITY.LEV_M=:LEV AND ');
     SQL.Add(' P_SALINITY.INSTRUMENT_ID=:INSTR_ID AND ');
     SQL.Add(' P_SALINITY.PROFILE_NUMBER=:PROF_NUM ');
     SQL.Add(' and P_TEMPERATURE.PQF2<>1 and P_TEMPERATURE.PQF2<>2 ');
     SQL.Add(' and P_SALINITY.PQF2<>1 and P_SALINITY.PQF2<>2 ');
     ParamByName('ID').Value:=ID;
     ParamByName('LEV').Value:=LEV_M;
     ParamByName('INSTR_ID').Value:=instr_id;
     ParamByName('PROF_NUM').Value:=prof_num;
    Open;
      if not Qt.IsEmpty then begin
        LEV_DBAR:=Qt.FieldByName('TLEV').Value;
        sp:=Qt.FieldByName('SVAL').Value;
        t :=Qt.FieldByName('TVAL').Value;
      end;
    Close;
   end;
 finally
   Trt.Commit;
   Qt.Free;
   Trt.Free;
 end;

 if (sp=-9999) or (t=-9999) then exit; // terminate if there is no salinity/temperature

 p_ref:=10.1325; //atmosheric pressure, dbar
 t_lab:=22;  //laboratory temperature

 gsw_sa_from_sp:=Tgsw_z_from_p(GetProcedureAddress(libgswteos, 'gsw_sa_from_sp'));
 SA  := gsw_sa_from_sp(sp, p_ref, lon, lat); // absolute salinity

 gsw_rho_t_exact:=Tgsw_rho_t_exact(GetProcedureAddress(libgswteos, 'gsw_rho_t_exact'));
 lab_dens:= gsw_rho_t_exact(SA, t_lab, p_ref); //laboratory density
 lab_dens:=lab_dens/1000;

 p:=LEV_DBAR+p_ref; //absolute pressure=atmospheric pressure+hydrostatic pressure

 gsw_pt_from_t:=Tgsw_pt_from_t(GetProcedureAddress(libgswteos, 'gsw_pt_from_t'));
 pot_temp:=gsw_pt_from_t(SA, t, p, p_ref);  //potential temperature

 pot_dens:=gsw_rho_t_exact(SA, pot_temp, p); //potential density
 pot_dens:=pot_dens/1000;


 if (par='P_ALKALINITY') then begin
   (* Milli-equivalent per liter (5) -> Micro-mole per kilogram (3) *)
   if (units=5) and (units_default=3) then val_out:=val_in*1000/lab_dens; //≈ 2000-2500
 end;


 if (par='P_AMMONIUM') then begin
   (* Micro-gram per liter (4) ->    Micro-gram per kilogram (14) *)
   if (units=4) and (units_default=14) then val_out:=val_in/lab_dens;
 end;

 if (par='P_CHLOROPHYLL') then begin
   (* Micro-gram per liter (4) ->    Micro-gram per kilogram (14) *)
   if (units=4) and (units_default=14) then val_out:=val_in/pot_dens;
 end;


 if (par='P_DIC') then begin
   (* Milli-mole per liter (7) -> Micro-mole per kilogram (3) *)
   if (units=7) and (units_default=3) then val_out:=val_in*1000/lab_dens;
 end;

 if (par='P_DIN') then begin
   (* Micro-gram per liter (4) -> Micro-gram per kilogram (14) *)
   if (units=4) and (units_default=14) then val_out:=val_in/lab_dens;
 end;

 if (par='P_SF6') then begin
   (* Nano-mole per kilogram (12) ->     Femto-mole per kilogram (19) *)
   if (units=12) and (units_default=19) then val_out:=val_in*1e6;
 end;

 if (par='P_OXYGEN') then begin
   (* Milliliter per liter to Micro-mole per kilogram *)
   if (units=21) and (units_default=3) then val_out:=44.661*val_in/pot_dens; //g/l ≈ g/kg × 1.025
 end;

 if (par='P_NITRATE') or (par='P_NITRATENITRITE') then begin
   (* Micro-gram per liter to Micro-mole per kilogram *)
   if (units=4)  and (units_default=3) then val_out:=0.071394*val_in/lab_dens; //g/l ≈ g/kg × 1.025
   (* Micro-gram per kilogram to Micro-mole per kilogram *)
   if (units=14) and (units_default=3) then val_out:=0.071394*val_in;
   (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
   if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM
 end;

 if (par='P_NITRITE') then begin
   (* Micro-gram per liter to Micro-mole per kilogram *)
   if (units=4)  and (units_default=3) then val_out:=0.071394*val_in/lab_dens; //g/l ≈ g/kg × 1.025
   (* Micro-gram per kilogram to Micro-mole per kilogram *)
   if (units=14) and (units_default=3) then val_out:=0.071394*val_in;
   (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
   if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM
 end;


 if (par='P_PHOSPHATE') then begin
     (* Micro-gram per liter to Micro-mole per kilogram *)
     if (units=4)  and (units_default=3) then val_out:=0.032285*val_in/lab_dens;
     (* Micro-gram per kilogram to Micro-mole per kilogram *)
     if (units=14) and (units_default=3) then val_out:=0.032285*val_in; //g/l ≈ g/kg × 1.025
     (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
     if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM
 end;


 if (par='P_SILICATE') then begin
     (* Micro-gram per liter to Micro-mole per kilogram *)
     if (units=4)  and (units_default=3) then val_out:=0.03561*val_in/lab_dens;
     (* Micro-gram per kilogram to Micro-mole per kilogram *)
     if (units=14) and (units_default=3) then val_out:=0.03561*val_in; //g/l ≈ g/kg × 1.025
     (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
     if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM
 end;


 // if no conversion done
 if val_out<>-9999 then isconverted:=true else isconverted:=false;
end;


end.

