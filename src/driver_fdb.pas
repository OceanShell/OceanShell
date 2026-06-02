unit driver_fdb;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB;

(******************************** SELECT Procedures ***************************)
procedure GetInstrumentIDByName(instr_name:string; var instr_id:integer);
procedure GetInstrumentNameByID(instr_id:integer; var instr_name:string);
procedure GetUnitsNameShortByID(units_id:integer; var units_name:string);
procedure GetStationFilePathByID(id:int64; var file_path:string);

procedure GetFDBParameters(ID:int64; Var n_prof:size_t;
  Var station_parameters_list:TStringList);

procedure GetFDBProfile(ID:int64; paramname:string; prof_num:integer;
  Var instr_id: integer; Var instr_name, fname: string; Var prof_best: boolean;
  Var lev_cnt: integer; Var pres_arr, lev_arr, par_arr, qc_arr:array of single;
  Var num_size, num_scale: integer; Var units_id: integer);


(******************************** INSERT Procedures ***************************)
procedure PutFDBPlatform(Q:TSQLQuery; cruise_id, platform_name, country_id,
  notes, date_added, date_updated: Variant);

procedure PutFDBCruise(Q:TSQLQuery; cruise_id: Int64; platform_id, source_id,
  institute_id, project_id, expocode, cruise_number, principal_investigator,
  notes, doi, www, date_start_total, date_end_total,
  date_added, date_updated: Variant);

procedure PutFDBStation(Q:TSQLQuery; station_id:int64; latitude, longitude:real;
  stdate: TDateTime; bottom_depth:Variant; cruise_id:int64; numincruise,
  st_id_orig: Variant; qcflag, version: smallint; cast_number:integer;
  file_path: Variant; date_added, date_updated: TDateTime);

procedure PutFDBStationParameters(Q:TSQLQuery; station_id, table_id: int64);


procedure PutFDBProfile_Prepare(Q:TSQLQuery; table_name:string);

procedure PutFDBProfile_(Q:TSQLQuery; table_name:string; station_id:int64;
  lev_bar, lev_m:real; val: double; pqf1, pqf2, sqf: smallint; bottle_number:Variant;
  units_id, instrument_id, profile_number: integer; profile_best: boolean);

procedure PutFDBProfile(Q:TSQLQuery; table_name:string; station_id:int64;
  lev_bar, lev_m:real; val: double; pqf1, pqf2, sqf: smallint; bottle_number:Variant;
  units_id, instrument_id, profile_number: integer; profile_best: boolean);


(******************************** DELETE Procedures ***************************)
procedure DeleteFDBStation(Q:TSQLQuery; station_id:int64);
procedure DeleteFDBStationParameters(Q:TSQLQuery; station_id:int64);

implementation

uses osmain, dm;

// Inserting new platform
procedure PutFDBPlatform(Q:TSQLQuery; cruise_id, platform_name, country_id,
  notes, date_added, date_updated: Variant);
begin
  with Q do begin
    Close;
      SQL.Clear;
      SQL.Add(' INSERT INTO PLATFORM ');
      SQL.Add(' (ID, NAME, COUNTRY_ID, DATE_ADDED, DATE_UPDATED, NOTES) ');
      SQL.Add(' VALUES ' );
      SQL.Add(' (:id, :name, :country_id, :date_added, :date_updated, :notes) ');
      ParamByName('id'          ).Value:=cruise_id;
      ParamByName('name'        ).Value:=platform_name;
      ParamByName('country_id'  ).Value:=country_id;
      ParamByName('date_added'  ).Value:=date_added;
      ParamByName('date_updated').Value:=date_updated;
      ParamByName('notes'       ).Value:=notes;
    ExecSQL;
  end;
end;

// Inserting new cruise
procedure PutFDBCruise(Q:TSQLQuery; cruise_id: Int64; platform_id, source_id,
  institute_id, project_id, expocode, cruise_number, principal_investigator,
  notes, doi, www, date_start_total, date_end_total,
  date_added, date_updated: Variant);
begin
  with Q do begin
    Close;
      SQL.Clear;
      SQL.Add(' INSERT INTO CRUISE ');
      SQL.Add(' (ID, platform_id, source_id, institute_id, project_id, ');
      SQL.Add(' EXPOCODE, CRUISE_NUMBER, PRINCIPAL_INVESTIGATOR, NOTES, ');
      SQL.Add(' DOI, WWW, ');
      SQL.Add(' DATE_START_TOTAL, DATE_END_TOTAL, DATE_ADDED, DATE_UPDATED) ');
      SQL.Add(' VALUES ' );
      SQL.Add(' (:cruise_id, :platform_id, :source_id, :institute_id, :project_id, ');
      SQL.Add(' :expocode, :cruise_number, :principal_investigator, :notes, ');
      SQL.Add(' :doi, :www, ');
      SQL.Add(' :date_start_total, :date_end_total, :date_added, :date_updated) ');
      ParamByName('cruise_id'             ).Value:=cruise_id;
      ParamByName('platform_id'           ).Value:=platform_id;
      ParamByName('source_id'             ).Value:=source_id;
      ParamByName('institute_id'          ).Value:=institute_id;
      ParamByName('project_id'            ).Value:=project_id;
      ParamByName('expocode'              ).Value:=expocode;
      ParamByName('cruise_number'         ).Value:=cruise_number;
      ParamByName('principal_investigator').Value:=principal_investigator;
      ParamByName('notes'                 ).Value:=notes;
      ParamByName('doi'                   ).Value:=doi;
      ParamByName('www'                   ).Value:=www;
      ParamByName('date_start_total'      ).Value:=date_start_total;
      ParamByName('date_end_total'        ).Value:=date_end_total;
      ParamByName('date_added'            ).Value:=date_added;
      ParamByName('date_updated'          ).Value:=date_updated;
    ExecSQL;
  end;
end;

// Inserting new station
procedure PutFDBStation(Q:TSQLQuery; station_id:int64; latitude, longitude:real;
  stdate: TDateTime; bottom_depth:Variant; cruise_id:int64; numincruise,
  st_id_orig: Variant; qcflag, version: smallint; cast_number:integer;
  file_path: variant; date_added, date_updated: TDateTime);
begin
  with Q do begin
    Close;
      SQL.Clear;
      SQL.Add(' UPDATE OR INSERT INTO STATION ');
      SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, BOTTOMDEPTH, CRUISE_ID, ');
      SQL.Add('  ST_NUMBER_ORIGIN, ST_ID_ORIGIN, QCFLAG, STVERSION, CAST_NUMBER, ');
      SQL.Add('  FILE_PATH, DATE_ADDED, DATE_UPDATED) ');
      SQL.Add(' VALUES ');
      SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :BOTTOMDEPTH, :CRUISE_ID, ');
      SQL.Add('  :ST_NUMBER_ORIGIN, :ST_ID_ORIGIN, :QCFLAG, :STVERSION, :CAST_NUMBER, ');
      SQL.Add('  :FILE_PATH, :DATE_ADDED, :DATE_UPDATED) ');
      SQL.Add(' MATCHING (ID) ');
      ParamByName('ID'               ).Value:=station_id;
      ParamByName('LATITUDE'         ).Value:=latitude;
      ParamByName('LONGITUDE'        ).Value:=longitude;
      ParamByName('DATEANDTIME'      ).Value:=stdate;
      ParamByName('BOTTOMDEPTH'      ).Value:=bottom_depth;
      ParamByName('CRUISE_ID'        ).Value:=cruise_id;
      ParamByName('ST_NUMBER_ORIGIN' ).Value:=numincruise;
      ParamByName('ST_ID_ORIGIN'     ).Value:=st_id_orig;
      ParamByName('QCFLAG'           ).Value:=qcflag;
      ParamByName('STVERSION'        ).Value:=version;
      ParamByName('CAST_NUMBER'      ).Value:=cast_number;
      ParamByName('FILE_PATH'        ).Value:=file_path;
      ParamByName('DATE_ADDED'       ).Value:=date_added;
      ParamByName('DATE_UPDATED'     ).Value:=date_updated;
    ExecSQL;
  end;
end;

// Inserting into Station_Parameters
procedure PutFDBStationParameters(Q:TSQLQuery; station_id, table_id: int64);
begin
  with Q do begin
      ParamByName('STATION_ID'    ).Value:=station_id;
      ParamByName('TABLE_ID'      ).Value:=table_id;
    ExecSQL;
  end;
end;

procedure PutFDBProfile_Prepare(Q:TSQLQuery; table_name:string);
begin
 with Q do begin
   Close;
     SQL.Clear;
     SQL.Add(' INSERT INTO ');
     SQL.Add( table_name );
     SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF1, PQF2, SQF, BOTTLE_NUMBER, ');
     SQL.Add('  UNITS_ID, INSTRUMENT_ID, PROFILE_NUMBER, PROFILE_BEST) ');
     SQL.Add(' values ');
     SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF1, :PQF2, :SQF, :BOTTLE_NUMBER, ');
     SQL.Add('  :UNITS_ID, :INSTRUMENT_ID, :PROFILE_NUMBER, :PROFILE_BEST) ');
   Prepare;
 end;
end;


procedure PutFDBProfile_(Q:TSQLQuery; table_name:string; station_id:int64;
  lev_bar, lev_m:real; val: double; pqf1, pqf2, sqf: smallint; bottle_number:Variant;
  units_id, instrument_id, profile_number: integer; profile_best: boolean);
begin
 with Q do begin
     ParamByName('ID'            ).Value:=station_id;
     ParamByName('LEV_DBAR'      ).Value:=lev_bar;
     ParamByName('LEV_M'         ).Value:=lev_m;
     ParamByName('VAL'           ).Value:=val;
     ParamByName('PQF1'          ).Value:=pqf1;
     ParamByName('PQF2'          ).Value:=pqf2;
     ParamByName('SQF'           ).Value:=sqf;
     ParamByName('BOTTLE_NUMBER' ).Value:=bottle_number;
     ParamByName('UNITS_ID'      ).Value:=units_id;
     ParamByName('INSTRUMENT_ID' ).Value:=instrument_id;
     ParamByName('PROFILE_NUMBER').Value:=profile_number;
     ParamByName('PROFILE_BEST'  ).Value:=profile_best;
   ExecSQL;
 end;
end;

// Inserting new profile
procedure PutFDBProfile(Q:TSQLQuery; table_name:string; station_id:int64;
  lev_bar, lev_m:real; val: double; pqf1, pqf2, sqf: smallint; bottle_number:Variant;
  units_id, instrument_id, profile_number: integer; profile_best: boolean);
begin
 with Q do begin
   Close;
     SQL.Clear;
     SQL.Add(' INSERT INTO ');
     SQL.Add( table_name );
     SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF1, PQF2, SQF, BOTTLE_NUMBER, ');
     SQL.Add('  UNITS_ID, INSTRUMENT_ID, PROFILE_NUMBER, PROFILE_BEST) ');
     SQL.Add(' values ');
     SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF1, :PQF2, :SQF, :BOTTLE_NUMBER, ');
     SQL.Add('  :UNITS_ID, :INSTRUMENT_ID, :PROFILE_NUMBER, :PROFILE_BEST) ');
     ParamByName('ID'            ).Value:=station_id;
     ParamByName('LEV_DBAR'      ).Value:=lev_bar;
     ParamByName('LEV_M'         ).Value:=lev_m;
     ParamByName('VAL'           ).Value:=val;
     ParamByName('PQF1'          ).Value:=pqf1;
     ParamByName('PQF2'          ).Value:=pqf2;
     ParamByName('SQF'           ).Value:=sqf;
     ParamByName('BOTTLE_NUMBER' ).Value:=bottle_number;
     ParamByName('UNITS_ID'      ).Value:=units_id;
     ParamByName('INSTRUMENT_ID' ).Value:=instrument_id;
     ParamByName('PROFILE_NUMBER').Value:=profile_number;
     ParamByName('PROFILE_BEST'  ).Value:=profile_best;
   ExecSQL;
 end;
end;

procedure GetFDBParameters(ID:int64; Var n_prof:size_t;
  Var station_parameters_list:TStringList);
var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
 try
   TRt:=TSQLTransaction.Create(nil);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(nil);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT NAME_TABLE FROM ');
      SQL.Add(' DATABASE_TABLES, STATION_PARAMETERS ');
      SQL.Add(' WHERE ');
      SQL.Add(' DATABASE_TABLES.ID=STATION_PARAMETERS.TABLE_ID AND ');
      SQL.Add(' STATION_PARAMETERS.STATION_ID=:ID ');
      ParamByName('ID').Value:=id;
     Open;
    end;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT NAME_TABLE FROM ');
      SQL.Add(' DATABASE_TABLES, STATION_PARAMETERS ');
      SQL.Add(' WHERE ');
      SQL.Add(' DATABASE_TABLES.ID=STATION_PARAMETERS.TABLE_ID AND ');
      SQL.Add(' STATION_PARAMETERS.STATION_ID=:ID ');
      ParamByName('ID').Value:=id;
     Open;
    end;

    while not Qt.EOF do begin
      station_parameters_list.Add(Qt.Fields[0].Value);
     Qt.Next;
    end;
 finally
  Trt.Commit;
  Qt.Free;
  Trt.Free;
 end;
end;


// Selecting profile
procedure GetFDBProfile(ID:int64; paramname:string; prof_num:integer;
  Var instr_id: integer; Var instr_name, fname: string; Var prof_best: boolean;
  Var lev_cnt: integer; Var pres_arr, lev_arr, par_arr, qc_arr:array of single;
  Var num_size, num_scale: integer; Var units_id: integer);
Var
  count, items_id, k, LNum:integer;
  Avg, Sum, Dif2, ValX, SD, ValX_Sum:real;
  lev, val, avg_lev, avg_val:real;
  val_sum, lev_sum, lev_min, lev_max, val_min, val_max:real;
  units, tbl, depth_units_str:string;
  Depth_units: integer;

  TRt:TSQLTransaction;
  Qtt:TSQLQuery;
begin

{
  Items_id:=cbParameters.ItemIndex;

  try
  Qt.DisableControls;

        with Qt do begin
         Close;
           Sql.Clear;
           SQL.Add(' SELECT * FROM ');
           SQL.Add( CurrentParTable);
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.ID=:ID AND ');
           SQL.Add( CurrentParTable+'.INSTRUMENT_ID=:INSTR_ID AND ');
           SQL.Add( CurrentParTable+'.PROFILE_NUMBER=:PROF_NUM');
           SQL.Add(' ORDER BY LEV_DBAR, LEV_M');
           ParamByName('ID').AsInteger:=ID;
           ParamByName('INSTR_ID').AsInteger:=INSTR_ID;
           ParamByName('PROF_NUM').AsInteger:=PROF_NUM;
          // showmessage(qt.SQL.Text);
         Open;
        end;

  if Qt.IsEmpty=false then begin
    Val_Sum:=0; Lev_sum:=0;
    Val_min:=10000; Val_max:=-9999;
    Lev_min:=10000; Lev_max:=-9999;

    Qt.First;
    while not Qt.eof do begin

      if Depth_units=0 then begin
       Lev:=Qt.FieldByName('LEV_M').AsFloat;
       depth_units_str:='Meter';
      end;
      if Depth_units=1 then begin
       Lev:=Qt.FieldByName('LEV_DBAR').AsFloat;
       depth_units_str:='dBar';
      end;

      Val:=Qt.FieldByName('VAL').AsFloat;
      //Flag_:=Qt.FieldByName('PQF2').AsFloat;

      Val_sum:=Val_sum+Val;
      Lev_sum:=Lev_sum+Lev;

      if lev>lev_max then lev_max:=lev;
      if lev<lev_min then lev_min:=lev;
      if val>val_max then val_max:=val;
      if val<val_min then val_min:=val;

     // Series1.AddXY(val,lev);

      Qt.Next;
    end;
    Count:=Qt.RecordCount;
    Avg_Val:=Val_sum/Qt.RecordCount;
    Avg_Lev:=Lev_sum/Qt.RecordCount;

   Qt.First; sum:=0;
    while not Qt.Eof do begin
     Val:=Qt.FieldByName('VAL').AsFloat;
     Dif2:=sqr(Val-Avg_Val);
    sum:=sum+Dif2;
    Qt.Next;
   end;
   Qt.First;

   //  showmessage('here3');

   try
     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qtt:=TSQLQuery.Create(self);
     Qtt.Database:=frmdm.IBDB;
     Qtt.Transaction:=TRt;

       with Qtt do begin
         Close;
           Sql.Clear;
           SQL.Add(' SELECT UNITS.NAME_SHORT FROM ');
           SQL.Add(CurrentParTable+ ', UNITS ');
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.UNITS_ID=UNITS.ID AND ');
           SQL.Add( CurrentParTable+'.INSTRUMENT_ID=:INSTR_ID AND ');
           SQL.Add( CurrentParTable+'.PROFILE_NUMBER=:PROF_NUM AND ');
           SQL.Add( CurrentParTable+'.ID=:ID ');
           ParamByName('ID').AsInteger:=ID;
           ParamByName('INSTR_ID').AsInteger:=INSTR_ID;
           ParamByName('PROF_NUM').AsInteger:=PROF_NUM;
         Open;
           Units:=Qtt.Fields[0].AsString;
         Close;
        end;
   finally
     Trt.Commit;
     Qtt.Free;
     Trt.Free;
   end;
    // showmessage('here4');

    SD:=sqrt(sum/count);

    StatusBar1.Panels[1].Text:='Count= '+Inttostr(Count);
    StatusBar1.Panels[2].Text:='Min= '  +floattostr(Lev_Min);
    StatusBar1.Panels[3].Text:='Max= '  +floattostr(Lev_Max);
    StatusBar1.Panels[4].Text:='Avg= '  +floattostrF(Avg_Lev, fffixed,8,3);
    StatusBar1.Panels[5].Text:='Units= '+depth_units_str;

    StatusBar2.Panels[1].Text:='SD= '   +floattostrF(SD, fffixed,8,4);
    StatusBar2.Panels[2].Text:='Min= '  +floattostr(Val_Min);
    StatusBar2.Panels[3].Text:='Max= '  +floattostr(Val_Max);
    StatusBar2.Panels[4].Text:='Avg= '  +floattostrF(Avg_Val, fffixed,8,4);
    StatusBar2.Panels[5].Text:='Units= '+Units;

  end;
  finally
    Qt.EnableControls;
  end;


//  showmessage('here6');

btnCommit.Enabled:=true;
Application.ProcessMessages;  }

end;


(* retrieving instrument ID by the instrument name *)
procedure GetInstrumentIDByName(instr_name:string; var instr_id:integer);
var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
 try
   TRt:=TSQLTransaction.Create(nil);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(nil);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT ID FROM INSTRUMENT ');
      SQL.Add(' WHERE NAME=:INSTR_NAME ');
      ParamByName('INSTR_NAME').Value:=instr_name;
     Open;
       instr_id:=Qt.Fields[0].Value;
     Close;
    end;
 finally
  Trt.Commit;
  Qt.Free;
  Trt.Free;
 end;
end;

(* retrieving instrument name by the instrument ID *)
procedure GetInstrumentNameByID(instr_id:integer; var instr_name:string);
var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
 try
   TRt:=TSQLTransaction.Create(nil);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(nil);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT NAME FROM INSTRUMENT ');
      SQL.Add(' WHERE ID=:ID ');
      ParamByName('ID').Value:=instr_id;
     Open;
       instr_name:=Qt.Fields[0].Value;
     Close;
    end;
 finally
  Trt.Commit;
  Qt.Free;
  Trt.Free;
 end;
end;


(* retrieving unit name by ID *)
procedure GetUnitsNameShortByID(units_id:integer; var units_name:string);
var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
 try
   TRt:=TSQLTransaction.Create(nil);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(nil);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT NAME_SHORT FROM UNITS ');
      SQL.Add(' WHERE ID=:ID ');
      ParamByName('ID').Value:=units_id;
     Open;
       units_name:=Qt.Fields[0].Value;
     Close;
    end;
 finally
  Trt.Commit;
  Qt.Free;
  Trt.Free;
 end;
end;


procedure GetStationFilePathByID(id:int64; var file_path:string);
var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
 try
   TRt:=TSQLTransaction.Create(nil);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(nil);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT FILE_PATH FROM STATION ');
      SQL.Add(' WHERE ID=:ID ');
      ParamByName('ID').Value:=id;
     Open;
       file_path:=Qt.Fields[0].Value;
     Close;
    end;
 finally
  Trt.Commit;
  Qt.Free;
  Trt.Free;
 end;
end;


(********************** DELETE PROCEDURES ************************************)
// Deleting station
procedure DeleteFDBStation(Q:TSQLQuery; station_id:int64);
begin
 with Q do begin
   Close;
    SQL.Clear;
    SQL.Add(' DELETE FROM STATION ');
    SQL.Add(' where ID=:ID ');
   ParamByName('ID').Value:=station_id;
  ExecSQL;
 end;
end;

procedure DeleteFDBStationParameters(Q:TSQLQuery; station_id:int64);
begin
 with Q do begin
   Close;
    SQL.Clear;
    SQL.Add(' DELETE FROM STATION_PARAMETERS ');
    SQL.Add(' where ID=:ID ');
   ParamByName('ID').Value:=station_id;
  ExecSQL;
 end;
end;

end.

