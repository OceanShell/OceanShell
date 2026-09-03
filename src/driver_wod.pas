unit driver_wod;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

Procedure GetWODProfile(ID:int64; paramname:string; prof_num:integer;
  Var instr_id: integer; Var instr_name, fname: string;  Var prof_best: boolean;
  Var lev_cnt: integer; Var pres_arr, lev_arr, par_arr, qc_arr:array of single;
  Var num_size, num_scale: integer; Var units_id: integer);

implementation


Procedure GetWODProfile(ID:int64; paramname:string; prof_num:integer;
  Var instr_id: integer; Var instr_name, fname: string;  Var prof_best: boolean;
  Var lev_cnt: integer; Var pres_arr, lev_arr, par_arr, qc_arr:array of single;
  Var num_size, num_scale: integer; Var units_id: integer);
begin
 //

end;

end.

