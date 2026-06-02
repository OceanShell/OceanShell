unit driver__selector;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

procedure GetParameters(ID:int64;  Var n_prof:size_t;
  Var station_parameters_list:TStringList);

procedure GetProfile(ID:int64; paramname:string; prof_num:integer;
  Var instr_id: integer; Var instr_name, fname: string;  Var prof_best: boolean;
  Var lev_cnt: integer; Var pres_arr, lev_arr, par_arr, qc_arr:array of single;
  Var num_size, num_scale: integer; Var units_id: integer);

implementation

uses driver_argo, driver_fdb, driver_wod;

procedure GetParameters(ID:int64; Var n_prof:size_t;
  Var station_parameters_list:TStringList);
Var
  Src, file_path:string;
begin
  Src:='ARGO';
  if Src='ARGO' then begin
    GetStationFilePathByID(ID, file_path);
    GetARGOParameters(file_path, n_prof, station_parameters_list)
  end
  else
    GetFDBParameters(ID, n_prof, station_parameters_list);
end;

procedure GetProfile(Src: string, ID:int64; paramname:string; prof_num:integer;
  Var instr_id: integer; Var instr_name, fname: string; Var prof_best: boolean;
  Var lev_cnt: integer; Var pres_arr, lev_arr, par_arr, qc_arr:array of single;
  Var num_size, num_scale: integer; Var units_id: integer);
begin
  if Src='ARGO' then
    GetArgoProfile(ID, paramname, prof_num, instr_id,
     instr_name, fname, prof_best, lev_cnt, pres_arr, lev_arr, par_arr, qc_arr,
     num_size, num_scale, units_id) else
  if Src='WOD' then
    GetFDBProfile(ID, paramname, prof_num, instr_id,
     instr_name, fname, prof_best, lev_cnt, pres_arr, lev_arr, par_arr, qc_arr,
     num_size, num_scale, units_id) else
    GetWODProfile(ID, paramname, prof_num, instr_id,
     instr_name, fname, prof_best, lev_cnt, pres_arr, lev_arr, par_arr, qc_arr,
     num_size, num_scale, units_id);
end;

end.

