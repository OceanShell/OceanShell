unit osunitsconversion;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

procedure GetDefaultUnits(par:string; units, units_default: integer; val_in: real;
  Var val_out:real; Var isconverted:boolean);


implementation


procedure  GetDefaultUnits(par:string; units, units_default: integer; val_in: real;
  Var val_out:real; Var isconverted:boolean);
begin
 val_out:=-999;


 if (par='P_OXYGEN') then begin
    {1 μmol O2 = .022391 ml
     1 ml/l = 103/22.391 = 44.661 μmol/l
     1 mg/l = 22.391 ml/31.998 = 0.700 ml/l
     1 mg-at/l = 15.994x22.391/31.998 = 11.192 ml}

   (* Milliliter per liter to Micro-mole per kilogram *)
   if (units=21) and (units_default=3) then val_out:=44.661*val_in/1.025; //g/l ≈ g/kg × 1.025
 end;

 if (par='P_NITRATE') then begin
   {1 μg NO3/l = 1/ MW NO3 μg/l = 0.016128 μmol NO3/l
   1 μg NO3/l = MW N/MW NO3 = 0.225897 μg N/l
   1 μg N/l = 1/MW N = 0.071394 μmol N/l
   MW NO3 = 62.005010
   MW N = 14.006720}

   (* Micro-gram per liter to Micro-mole per kilogram *)
   if (units=4)  and (units_default=3) then val_out:=0.016128*val_in/1.025; //g/l ≈ g/kg × 1.025
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
   if (units=4)  and (units_default=3) then val_out:=0.016128*val_in/1.025; //g/l ≈ g/kg × 1.025
   (* Micro-gram per kilogram to Micro-mole per kilogram *)
   if (units=14) and (units_default=3) then val_out:=0.016128*val_in;
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
     if (units=4)  and (units_default=3) then val_out:=0.010529*val_in/1.025;
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
     if (units=4)  and (units_default=3) then val_out:=0.013143*val_in/1.025;
     (* Micro-gram per kilogram to Micro-mole per kilogram *)
     if (units=14) and (units_default=3) then val_out:=0.013143*val_in; //g/l ≈ g/kg × 1.025
     (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
     if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM
 end;


 // if no conversion done
 if val_out<>-999 then isconverted:=true else isconverted:=false;
end;


end.

