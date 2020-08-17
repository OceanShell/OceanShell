unit osunitsconversion;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, dm, gibbsseawater;

procedure GetDefaultUnits(par:string; units, units_default: integer; val_in,
  lab_dens: real; Var val_out:real; Var isconverted:boolean);

procedure GetLabDensity(ID, INSTRUMENT_ID, PROFILE_NUMBER: integer;
  Lat, Lon, LEV_M: real; Var lab_dens:real);

implementation


(* Use density calculated from in situ salinity and T=22 deg C,  atmospheric pressure = 1 ATM  *)
procedure GetLabDensity(ID, INSTRUMENT_ID, PROFILE_NUMBER: integer;
  Lat, Lon, LEV_M: real; Var lab_dens:real);
Var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;

  SA, sp, p, t:real;
begin
 lab_dens:=-9999;

 try
   TRt:=TSQLTransaction.Create(nil);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(nil);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   sp:=-9999;
   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT VAL FROM P_SALINITY ');
     SQL.Add(' WHERE ');
     SQL.Add(' P_SALINITY.ID=:ID AND ');
     SQL.Add(' P_SALINITY.LEV_M=:LEV AND ');
     SQL.Add(' P_SALINITY.INSTRUMENT_ID=:INSTR_ID AND ');
     SQL.Add(' P_SALINITY.PROFILE_NUMBER=:PROF_NUM ');
     ParamByName('ID').Value:=ID;
     ParamByName('LEV').Value:=LEV_M;
     ParamByName('INSTR_ID').Value:=INSTRUMENT_ID;
     ParamByName('PROF_NUM').Value:=PROFILE_NUMBER;
    Open;
      if not Qt.IsEmpty then sp:=Qt.Fields[0].Value;
    Close;
   end;
 finally
   Trt.Commit;
   Qt.Free;
   Trt.Free;
 end;

 if sp<>-9999 then begin
   p:=10.1325; //atmosheric pressure, dbar
   t:=22;      //laboratory temperature
   SA  := gsw_SA_from_SP(sp, p, lon, lat);
   lab_dens:= gsw_rho_t_exact(SA, t, p); // kg/m3
   lab_dens:=lab_dens/1000;
 end;

end;

procedure  GetDefaultUnits(par:string; units, units_default: integer; val_in,
  lab_dens: real; Var val_out:real; Var isconverted:boolean);
begin
 val_out:=-9999;

 if lab_dens=-9999 then exit;


 if (par='P_OXYGEN') then begin
    {1 μmol O2 = .022391 ml
     1 ml/l = 103/22.391 = 44.661 μmol/l
     1 mg/l = 22.391 ml/31.998 = 0.700 ml/l
     1 mg-at/l = 15.994x22.391/31.998 = 11.192 ml}

   (* Milliliter per liter to Micro-mole per kilogram *)
   if (units=21) and (units_default=3) then val_out:=44.661*val_in/lab_dens; //g/l ≈ g/kg × 1.025
 end;

 if (par='P_NITRATE') then begin
   {1 μg NO3/l = 1/ MW NO3 μg/l = 0.016128 μmol NO3/l
   1 μg NO3/l = MW N/MW NO3 = 0.225897 μg N/l
   1 μg N/l = 1/MW N = 0.071394 μmol N/l
   MW NO3 = 62.005010
   MW N = 14.006720}

   (* Micro-gram per liter to Micro-mole per kilogram *)
   if (units=4)  and (units_default=3) then val_out:=0.016128*val_in/lab_dens; //g/l ≈ g/kg × 1.025
   (* Micro-gram per kilogram to Micro-mole per kilogram *)
   if (units=14) and (units_default=3) then val_out:=0.016128*val_in;
   (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
   if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM
 end;

  if (par='P_NITRITE') then begin
   {1 μg NO2/l = 1/ MW NO2 = 0.021736 μmol/l
    1 μg NO2/l = MW N/MW NO2 = 0.304457 μg/l N
    1 μg N/l = 1/MW N = 0.071394 μmol N/l
    MW NO2 = 46.005580
    MW N = 14.006720}

   (* Micro-gram per liter to Micro-mole per kilogram *)
   if (units=4)  and (units_default=3) then val_out:=0.02174*val_in/lab_dens; //g/l ≈ g/kg × 1.025
   (* Micro-gram per kilogram to Micro-mole per kilogram *)
   if (units=14) and (units_default=3) then val_out:=0.02174*val_in;
   (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
   if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM
 end;


 if (par='P_PHOSPHATE') then begin
    {1 μg PO4/l = 1/MW PO4 μg = 0.010529 μmol PO4/l
     1 μg PO4/l = MW P/MW PO4 = 0.326138 μg P/l
     1 μg P/l = 1/MW P = 0.032285 μmol P/l
     MW PO4 = 94.971482
     MW P = 30.973762}

     (* Micro-gram per liter to Micro-mole per kilogram *)
     if (units=4)  and (units_default=3) then val_out:=0.010529*val_in/lab_dens;
     (* Micro-gram per kilogram to Micro-mole per kilogram *)
     if (units=14) and (units_default=3) then val_out:=0.010529*val_in; //g/l ≈ g/kg × 1.025
     (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
     if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM
 end;


 if (par='P_SILICATE') then begin
    {1 μg SiO3/l = 1/ MW SiO3 = 0.013143 μmol SiO3/l
     1 μg SiO3/l = MW Si/MW SiO3 = 0.369139 μg Si/l
     1 μg Si/l = 1/MW Si = 0.035606 μmol Si/l
     MW SiO3 = 76.083820
     MW Si = 28.085530}

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

