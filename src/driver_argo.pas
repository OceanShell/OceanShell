unit driver_argo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Variants;

procedure GetARGOParameters(file_path:string; Var n_prof:size_t;
  Var station_parameters_list:TStringList);

procedure GetARGOProfile(ID:int64; paramname_fdb:string; prof_num:integer;
  Var instr_id: integer; Var instr_name, fname: string; Var prof_best: boolean;
  Var lev_cnt: integer; Var pres_arr, lev_arr, par_arr, qc_arr:array of single;
  Var num_size, num_scale: integer; Var units_id: integer);

procedure QFMapping(argo_QF:integer; var QF:single);

implementation

uses osmain, declarations_netcdf, gibbsseawater, driver_fdb;

procedure GetARGOParameters(file_path:string; Var n_prof:size_t;
  Var station_parameters_list:TStringList);
Var
  Varname, Dimname: array of pAnsiChar;
  dimidsp: array of Integer;
  ip: array of PAnsiChar;

  ncid, ndimsp, nvarsp, ngattsp, varidp, unlimdimidp, k, c, par_cnt:integer;
  profidp, levidp, paridp, cc1, cc2, fl: integer;
  par_str, buf_str:string;
  lenp, n_params, n_levels: size_t;

  fname, just_name: string;
  Par_nc_arr: array [1..50] of string;
  n_sp:size_t;
  vardimidsp:array of integer;

  pp, pr, sp: integer;
  start: PArraySize_t;
begin

  station_parameters_list.Clear;

  file_path:=StringReplace(file_path, '/', '\', [rfReplaceAll]);
  fname:=path_to_argo+'dac'+PathDelim+file_path;

  if not FileExists(fname) then exit;

  try
     nc_open(pansichar(fname), NC_NOWRITE, ncid); // only for reading

     nc_inq_dimid(ncid, pAnsiChar('N_PROF'), profidp);
     nc_inq_dimlen(ncid, profidp, n_prof);

  //   showmessage(inttostr(n_prof)+'   '+inttostr(profidp));

     nc_inq_dimid(ncid, pAnsiChar('N_LEVELS'), levidp);
     nc_inq_dimlen(ncid, levidp, n_levels);
  //   showmessage(inttostr(n_levels));}

     nc_inq_dimid(ncid, pAnsiChar('N_PARAM'), paridp);
     nc_inq_dimlen(ncid, paridp, n_params);
 //    showmessage(inttostr(n_params));

     nc_inq_varid (ncid, pAnsiChar('STATION_PARAMETERS'), varidp);
     nc_inq_varndims (ncid, varidp, ndimsp);

     SetLength(vardimidsp, ndimsp); //number of dimensions
     nc_inq_vardimid(ncid, varidp, vardimidsp);
     n_sp:=0;
      for k:=0 to ndimsp-1 do begin  // Loop for variable dimensions
        setlength(dimname, 0);
        setlength(dimname, NC_MAX_NAME);
        nc_inq_dimname(ncid, vardimidsp[k], dimname); //Dimension's name
        if copy(pansichar(dimname), 1, 6)='STRING' then nc_inq_dimlen (ncid, vardimidsp[k], n_sp);
    end;

    start:=GetMemory(SizeOf(TArraySize_t)*3); // get memory for start pointer

    for pp:=0 to n_prof-1 do begin
      start^[0]:=pp;
      for pr:=0 to n_params-1 do begin
         start^[1]:=pr;
         par_str:='';
         for sp:=0 to n_sp do begin
         start^[2]:=sp ;//n_sp;

         setlength(ip, 1);
         nc_get_var1_text(ncid, varidp, start^, ip);
         par_str:=par_str+pansichar(ip);
       end;
      par_str:=trim(par_str);

      for c:=0 to high(ARGO_FDB_MAPPING) do
        if par_str=ARGO_FDB_MAPPING[c].NAME_ARGO then begin
            par_str:=ARGO_FDB_MAPPING[c].NAME_FDB;

            fl:=0;
            for k:=0 to station_parameters_list.Count-1 do
              if station_parameters_list.Strings[k]=par_str then fl:=1;

            if fl=0 then station_parameters_list.Add(par_str);
        end;

      end;

   end;

  finally
    FreeMemory(start);
    nc_close(ncid);
  end;
end;


procedure GetARGOProfile(ID:int64; paramname_fdb:string; prof_num:integer;
  Var instr_id: integer; Var instr_name, fname: string;  Var prof_best: boolean;
  Var lev_cnt: integer; Var pres_arr, lev_arr, par_arr, qc_arr:array of single;
  Var num_size, num_scale: integer;  Var units_id: integer);
Var
  start: PArraySize_t;

  ncid, varidp, levidp, presidp, qcidp, ll_i:integer;
  adj_str:string;
  pi, vi:array of single;
  QF:array of PAnsiChar;
  lat: array of double;

  adjusted:boolean;

  atttext:    array of pAnsiChar;
  atttype: nc_type;
  n_levels, attlenp:size_t;
  attname: array of pAnsiChar;
  a, varnattsp, c: integer;
  file_name_full, paramname, file_path:string;
begin
    paramname:='';
    for c:=0 to high(ARGO_FDB_MAPPING) do begin
      if paramname_fdb=ARGO_FDB_MAPPING[c].NAME_FDB then begin
        paramname:=ARGO_FDB_MAPPING[c].NAME_ARGO;
        units_id:=ARGO_FDB_MAPPING[c].UNITS;
        break;
      end;
    end;

    GetStationFilePathByID(id, file_path);

    file_path:=StringReplace(file_path, '/', '\', [rfReplaceAll]);
    file_name_full:=path_to_argo+'dac'+PathDelim+file_path;

    fname:=ExtractFileName(file_name_full);
    fname:=copy(fname, 1, length(fname)-3);

    if (Copy(fname, 1, 1)='D') or (Copy(fname, 2, 1) ='D') then adjusted:=true;
    if (Copy(fname, 1, 1)='R') or (Copy(fname, 2, 1) ='R') then adjusted:=false;

    instr_id:=9;
    instr_name:='PFL';
    prof_best:=false;

  try
      nc_open(pansichar(AnsiString(file_name_full)), 0, ncid); // only for reading

      nc_inq_dimid(ncid, pAnsiChar('N_LEVELS'), levidp);
      nc_inq_dimlen(ncid, levidp, n_levels);

      setlength(lat, 1);
      nc_inq_varid (ncid, pAnsiChar('LATITUDE'), varidp);
      nc_get_var_double(ncid, varidp, lat);

    //  showmessage(floattostr(lat));

      if adjusted=true then adj_str:='_ADJUSTED' else adj_str:='';

      nc_inq_varid (ncid, pAnsiChar('PRES'+adj_str), presidp);
      nc_inq_varid (ncid, pAnsiChar(paramname+adj_str), varidp);
      nc_inq_varid (ncid, pAnsiChar(paramname+adj_str+'_QC'), qcidp);

      nc_inq_attlen (ncid, varidp, pAnsiChar('FORTRAN_format'), attlenp);
      setlength(atttext, 0);
      setlength(atttext, attlenp);
      nc_get_att_text (ncid, varidp, pAnsiChar('FORTRAN_format'), atttext);
    //  showmessage(pansichar(atttext));

      if trim(pansichar(atttext))<>'' then begin
        if copy(pansichar(atttext), 2, 1)='.' then num_size:=0 else
         num_size :=StrToInt(copy(pansichar(atttext), 2, Pos('.', pansichar(atttext))-2));
         num_scale:=StrToInt(copy(pansichar(atttext), Pos('.', pansichar(atttext))+1, Length(pansichar(atttext))));
      end else begin
         num_size:=10;
         num_scale:=5;
      end;

      nc_inq_attlen (ncid, varidp, pAnsiChar('units'), attlenp);
      setlength(atttext, 0);
      setlength(atttext, attlenp);
      nc_get_att_text (ncid, varidp, pAnsiChar('units'), atttext);
      //val_units_str:=pansichar(atttext);

      start:=GetMemory(SizeOf(TArraySize_t)*2); // get memory for start pointer

      setlength(pi, 1);
      setlength(vi, 1);
      setlength(qf, 1);
      lev_cnt:=-1;

      start^[0]:=prof_num;
      for ll_i:=0 to high(pres_arr) do begin
       start^[1]:=ll_i;

        nc_get_var1_float(ncid, presidp, start^, pi);
        nc_get_var1_float(ncid, varidp,  start^, vi);
        nc_get_var1_text (ncid, qcidp,   start^, qf);

        if (pi[0]<>99999) and (vi[0]<>99999) then begin
           inc(lev_cnt);
           pres_arr[lev_cnt]:=pi[0];
           par_arr [lev_cnt]:=vi[0];

           QFMapping(StrToInt(pansichar(qf)), qc_arr[lev_cnt]);

           lev_arr[lev_cnt] := -gsw_z_from_p(pres_arr[lev_cnt], lat[0], 0, 0);
        end;
      end;
   finally
     FreeMemory(start);
     Lat:=nil;
     pi:=nil;
     vi:=nil;
     qf:=nil;
     nc_close(ncid);
   end;
end;


procedure QFMapping(argo_QF:integer; var QF:single);
begin
  QF:=0;
   case argo_QF of
     0: QF:=0;
     1: QF:=4;
     2: QF:=2;
     3: QF:=1;
     4: QF:=1;
     5: QF:=4;
     8: QF:=3;
     9: QF:=1;
   end;
end;

end.

