unit osunitsconversion;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

procedure GetDefaultUnits(par:string; units, units_default: integer;
  val_in: real; Var val_out:real; Var isconverted:boolean);


implementation


procedure  GetDefaultUnits(par:string; units, units_default: integer; val_in: real;
  Var val_out:real; Var isconverted:boolean);
begin
 val_out:=-9999;

 if (par='P_ALKALINITY') then begin
   //UNITS = 3 (default), 5, 30

   (* Milli-equivalent per liter (5) -> Micro-mole per kilogram (3) *)
   if (units=5) and (units_default=3) then val_out:=val_in*1000/1.025; //≈ 2000-2500

   {UPDATED 30.08.2021}
   (* Milli-equivalent per kilogram (30) -> Micro-mole per kilogram (3) *)
   if (units=30) and (units_default=3) then val_out:=val_in*1000;
 end;


 if (par='P_AMMONIUM') then begin
   //UNITS = 3, 4, 14 (default), 15

   (* Micro-gram per liter (4) ->    Micro-gram per kilogram (14) *)
   if (units=4) and (units_default=14) then val_out:=val_in/1.025;

   {UPDATED 30.08.2021}
   (* Micro-mole per kilogram (3) -> Micro-gram per kilogram (14) *)
   if (units=3) and (units_default=14) then val_out:=val_in/17.031;

   //http://unitslab.com/node/153
   (* Micro-mole per liter (15) ->    Micro-gram per kilogram (14) *)
   if (units=15) and (units_default=14) then val_out:=(val_in/17.031)/1.025;
 end;


 if (par='P_AOU') then begin
  //UNITS = 3 (default)
 end;


 if (par='P_ARGON') then begin
  //UNITS = 12 (default)
 end;


 if (par='P_BARIUM') then begin
   //UNITS = 7, 14 (default)

   (* Milli-mole per liter (7) to Micro-gram per kilogram (14) *)
   //???????????????
 end;


 if (par='P_BISULFIDE') then begin
   //UNITS = 3 (default)
 end;


 if (par='P_C13') then begin
   //UNITS = 11 (default)
 end;


 if (par='P_C14') then begin
   //UNITS = 11 (default)
 end;


 if (par='P_CCL4') then begin
   //UNITS = 13 (default)
 end;


 if (par='P_CDOM') then begin
   //UNITS = 24 (default)
 end;


 if (par='P_CFC11') then begin
   //UNITS = 13 (default)
 end;


 if (par='P_CFC113') then begin
   //UNITS = 13 (default)
 end;


 if (par='P_CFC12') then begin
   //UNITS = 13 (default)
 end;


 if (par='P_CHLOROPHYLL') then begin
   //UNITS = 4, 9, 14 (default)

   (* Micro-gram per liter (4) ->    Micro-gram per kilogram (14) *)
   if (units=4) and (units_default=14) then val_out:=val_in/1.025;

   {UPDATED 30.08.2021}
   (* Micro-gram per cubic meter (9) ->    Micro-gram per kilogram (14) *)
   if (units=9) and (units_default=14) then val_out:=val_in*1000/1.025;
 end;


 if (par='P_DIC') then begin
   //UNITS = 3 (default), 7

   (* Milli-mole per liter (7) -> Micro-mole per kilogram (3) *)
   if (units=7) and (units_default=3) then val_out:=val_in*1000/1.025;
 end;


 if (par='P_DIN') then begin
   //UNITS = 4, 14 (default)

   (* Micro-gram per liter (4) -> Micro-gram per kilogram (14) *)
   if (units=4) and (units_default=14) then val_out:=val_in/1.025;
 end;


 if (par='P_DOC') then begin
   //UNITS = 15 (default)
 end;


 if (par='P_DON') then begin
   //UNITS = 15 (default)
 end;


 if (par='P_FLUORESCENCE') then begin
   //UNITS = 9 (default), 22

   (* Volume scattering coefficient (22) to  Micro-gram per cubic meter (9) *)
   //?????????????????
 end;


 if (par='P_H2S') then begin
   //UNITS = 15 (default)
 end;


 if (par='P_H3') then begin
   //UNITS = 8 (default)
 end;


 if (par='P_HE') then begin
   //UNITS = 12 (default)
 end;


 if (par='P_HE3') then begin
   //UNITS = 10 (default)
 end;


 if (par='P_NEON') then begin
   //UNITS = 12 (default)
 end;


 if (par='P_NITRATE') or (par='P_NITRATENITRITE') then begin
   //UNITS =  3 (default), 4, 14, 15, 26

   {1 μg NO3/l = 1/ MW NO3 μg/l = 0.016128 μmol NO3/l
   1 μg NO3/l = MW N/MW NO3 = 0.225897 μg N/l
   1 μg N/l = 1/MW N = 0.071394 μmol N/l
   MW NO3 = 62.005010
   MW N = 14.006720}

   (* Micro-gram per liter to Micro-mole per kilogram *)
   if (units=4)  and (units_default=3) then val_out:=0.071394*val_in/1.025; //g/l ≈ g/kg × 1.025
   (* Micro-gram per kilogram to Micro-mole per kilogram *)
   if (units=14) and (units_default=3) then val_out:=0.071394*val_in;
   (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
   if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM

   {UPDATED 30.08.2021}
   (* Micro-mole per liter to Micro-mole per kilogram *)
   if (units=15) and (units_default=3) then val_out:=val_in/1.025;
 end;


 if (par='P_NITRITE') then begin
   //UNITS =  3 (default), 4, 14, 15, 26

   {1 μg NO2/l = 1/ MW NO2 = 0.021736 μmol/l
    1 μg NO2/l = MW N/MW NO2 = 0.304457 μg/l N
    1 μg N/l = 1/MW N = 0.071394 μmol N/l
    MW NO2 = 46.005580
    MW N = 14.006720}

   (* Micro-gram per liter to Micro-mole per kilogram *)
   if (units=4)  and (units_default=3) then val_out:=0.071394*val_in/1.025; //g/l ≈ g/kg × 1.025
   (* Micro-gram per kilogram to Micro-mole per kilogram *)
   if (units=14) and (units_default=3) then val_out:=0.071394*val_in;
   (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
   if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM

   {UPDATED 30.08.2021}
   (* Micro-mole per liter to Micro-mole per kilogram *)
   if (units=15) and (units_default=3) then val_out:=val_in/1.025;
 end;


 if (par='P_O18') then begin
   //UNITS = 11 (default)
 end;


 if (par='P_OXYGEN') then begin
   //UNITS = 3 (default), 10, 21, 29

    {1 μmol O2 = .022391 ml
     1 ml/l = 103/22.391 = 44.661 μmol/l
     1 mg/l = 22.391 ml/31.998 = 0.700 ml/l
     1 mg-at/l = 15.994x22.391/31.998 = 11.192 ml}

   (* Milliliter per liter to Micro-mole per kilogram *)
   if (units=21) and (units_default=3) then val_out:=44.661*val_in/1.025; //g/l ≈ g/kg × 1.025

   {UPDATED 31.08.2021}
   (* Percent to Micro-mole per kilogram *)
   //if (units=10) and (units_default=3) then val_out:=?????????

   (* Milli-liter per kilogram to Micro-mole per kilogram *)
   if (units=29) and (units_default=3) then val_out:=44.661*val_in;
 end;


 if (par='P_PAR') then begin
   //UNITS = 21, 23 (default)

   (* Milliliter per liter (21) to Micromole per second and square meter (23) *)
   //?????????
 end;


 if (par='P_PCCL4') then begin
   //UNITS = 18 (default)
 end;


 if (par='P_PCFC11') then begin
   //UNITS = 18 (default)
 end;


 if (par='P_PCFC113') then begin
   //UNITS = 18 (default)
 end;


 if (par='P_PCFC12') then begin
   //UNITS = 18 (default)
 end;


 if (par='P_PCO2') then begin
   //UNITS = 6 (default)
 end;


 if (par='P_PH') then begin
   //UNITS = 2 (default)
 end;


 if (par='P_PHOSPHATE') then begin
   //UNITS =  3 (default), 4, 14, 15, 26

    {1 μg PO4/l = 1/MW PO4 μg = 0.010529 μmol PO4/l
     1 μg PO4/l = MW P/MW PO4 = 0.326138 μg P/l
     1 μg P/l = 1/MW P = 0.032285 μmol P/l
     MW PO4 = 94.971482
     MW P = 30.973762}

     (* Micro-gram per liter to Micro-mole per kilogram *)
     if (units=4)  and (units_default=3) then val_out:=0.032285*val_in/1.025;
     (* Micro-gram per kilogram to Micro-mole per kilogram *)
     if (units=14) and (units_default=3) then val_out:=0.032285*val_in; //g/l ≈ g/kg × 1.025
     (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
     if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM

     {UPDATED 30.08.2021}
     (* Micro-mole per liter to Micro-mole per kilogram *)
     if (units=15) and (units_default=3) then val_out:=val_in/1.025;
 end;


 if (par='P_PHTS25P0') then begin
   //UNITS = 2 (default)
 end;


 if (par='P_PHTSINSITUTP') then begin
   //UNITS = 2 (default)
 end;


 if (par='P_PSF6') then begin
   //UNITS = 18 (default)
 end;


 if (par='P_SALINITY') then begin
   //UNITS = 28 (default)
 end;

 if (par='P_SF6') then begin
   //UNITS = 19 (default)

   (* Nano-mole per kilogram (12) ->     Femto-mole per kilogram (19) *)
   if (units=12) and (units_default=19) then val_out:=val_in*1e6;
 end;


 if (par='P_SILICATE') then begin
   //UNITS =  3 (default), 4, 14, 15, 26

    {1 μg SiO3/l = 1/ MW SiO3 = 0.013143 μmol SiO3/l
     1 μg SiO3/l = MW Si/MW SiO3 = 0.369139 μg Si/l
     1 μg Si/l = 1/MW Si = 0.035606 μmol Si/l
     MW SiO3 = 76.083820
     MW Si = 28.085530}

     (* Micro-gram per liter to Micro-mole per kilogram *)
     if (units=4)  and (units_default=3) then val_out:=0.03561*val_in/1.025;
     (* Micro-gram per kilogram to Micro-mole per kilogram *)
     if (units=14) and (units_default=3) then val_out:=0.03561*val_in; //g/l ≈ g/kg × 1.025
     (* Micro-gram-atom per kilogram to Micro-mole per kilogram *)
     if (units=26) and (units_default=3) then val_out:=val_in; //μmol/l = μg-at/l = mmol/m3 = μM

     {UPDATED 30.08.2021}
     (* Micro-mole per liter to Micro-mole per kilogram *)
     if (units=15) and (units_default=3) then val_out:=val_in/1.025;
 end;


 if (par='P_TCO2') then begin
   //UNITS = 3 (default)
 end;


 if (par='P_TDN') then begin
   //UNITS = 15 (default)
 end;


 if (par='P_TEMPERATURE') then begin
   //UNITS = 1 (default)
 end;


 if (par='P_TOC') then begin
   //UNITS = 15 (default)
 end;


 if (par='P_TOTALPHOSPHORUS') then begin
   //UNITS = 3, 15 (default)

     {UPDATED 30.08.2021}
     (* Micro-mole per kilogram to Micro-mole per liter *)
     if (units=3) and (units_default=15) then val_out:=val_in*1.025;
 end;


 if (par='P_TRANSMISSION') then begin
   //UNITS = 10 (default)
 end;


 if (par='P_TURBIDITY') then begin
   //UNITS = 22, 25 (default)
 end;


 // if no conversion done
 if val_out<>-9999 then isconverted:=true else isconverted:=false;
end;


end.

