unit osunitsconversion;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Dialogs;

procedure GetDefaultUnits(par:string; units, units_default: integer; val_in: real;
  Var val_out:real; Var isconverted:boolean);

procedure Oxygen_21_3(val_in:real; Var val_out:real);


implementation


procedure  GetDefaultUnits(par:string; units, units_default: integer; val_in: real;
  Var val_out:real; Var isconverted:boolean);
begin
 val_out:=-999;

 {1 μmol O2 = .022391 ml
 1 ml/l = 103/22.391 = 44.661 μmol/l
 1 mg/l = 22.391 ml/31.998 = 0.700 ml/l
 1 mg-at/l = 15.994x22.391/31.998 = 11.192 ml}

 if (par='P_OXYGEN') then begin
  (* Milliliter per liter to Micro-mole per kilogram *)
  if (units=21) and (units_default=3) then val_out:=44.661*val_in/1.025;
 end;

 if val_out<>-999 then isconverted:=true else isconverted:=false;
end;

procedure Oxygen_21_3(val_in:real; Var val_out:real);
begin



end;

end.

