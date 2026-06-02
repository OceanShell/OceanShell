unit osload_argo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, IBConnection, DB, SQLDB, dynlibs, lclintf,
  Dialogs, Variants, Math,

  osmain, declarations_netcdf, dm, driver_fdb, driver_argo, GibbsSeaWater;

procedure ARGO_CRUISE(DB:TIBConnection;
  DataPath, log_path: string; ToWrite:boolean;
  var cnt_kept, cnt_add, cnt_upd, cnt_del: integer);

procedure ARGO_STATION(DB:TIBConnection; md_file, log_path:string;
  ToWrite:boolean;  isCore: boolean; first_buoy:integer; Var cnt_kept,
  cnt_updated, cnt_new, cnt_skipped: integer);

procedure GetCodes(argo_code:string; Var country_id, institute_id,
  project_id:integer);

procedure GetTableName(var_name:string; Var tbl_name: string);
procedure QFMapping(argo_QF:integer; var QF:integer);

procedure UpdateStationParameters(Q:TSQLQuery; ID:int64;
  param_str: string; stdate_upd_f:TDateTime);

implementation

procedure ARGO_CRUISE(DB:TIBConnection;
  DataPath, log_path: string; ToWrite:boolean;
  var cnt_kept, cnt_add, cnt_upd, cnt_del: integer);
Var
  TRt:TSQLTransaction;
  Qt1, Qt2, Qt3:TSQLQuery;

  ID, k, str_cnt, fl:integer;
  DBUser, DBPass, DBHost, DBPath: string;

  dat:text;
  c, i:integer;
  st, fname, fpath, prof_type, inst_code, date_upd, platf, buf_str:string;
  country_id, institute_id, project_id: integer;
  stdate_upd:TDateTime;

  ID_buf: array of Int64;
  ID_arr: array of int64;

  ncid, varidp:integer;
  ip: array of PAnsiChar;
  proj, pi, op_inst, www, notes_str:string;

  dat0, dat1, dat2, dat3:text;
begin

  AssignFile(dat, datapath+'ar_index_global_meta.txt'); reset(dat);
  for c:=1 to 9 do readln(dat, st);
  c:=0;
  repeat
    readln(dat, st);
    inc(c);
  until eof(dat);
  CloseFile(dat);

  SetLength(ID_buf, c);

 // showmessage('stations: '+inttostr(c));

 try
   TRt:=TSQLTransaction.Create(nil);

   DB.Transaction.Commit;
   DB.Transaction:=TRt;
   TRt.Database:=DB;

   Qt1:=TSQLQuery.Create(nil);
   Qt1.Database:=DB;
   Qt1.Transaction:=TRt;

   Qt2:=TSQLQuery.Create(nil);
   Qt2.Database:=DB;
   Qt2.Transaction:=TRt;

   Qt3:=TSQLQuery.Create(nil);
   Qt3.Database:=DB;
   Qt3.Transaction:=TRt;


  AssignFile(dat,  DataPath+'ar_index_global_meta.txt'); reset(dat);
  AssignFile(dat0, log_path+'ARGO_CRUISE_kept.txt');     rewrite(dat0);
  AssignFile(dat1, log_path+'ARGO_CRUISE_added.txt');    rewrite(dat1);
  AssignFile(dat2, log_path+'ARGO_CRUISE_updated.txt');  rewrite(dat2);
  AssignFile(dat3, log_path+'ARGO_CRUISE_removed.txt');  rewrite(dat3);



 // showmessage(DataPath+'ar_index_global_meta.txt');
  for c:=1 to 9 do readln(dat, st);

  cnt_add:=0;
  cnt_upd:=0;
  cnt_kept:=0;
  str_cnt:=9;
  repeat
   readln(dat, st);

   c:=0;
   for k:=1 to 4 do begin
    buf_str:='';
    repeat
      inc(c);
      if st[c]<>',' then buf_str:=buf_str+st[c];
    until (st[c]=',') or (c=length(st));

    case k of
     1: fname:=buf_str;
     2: prof_type:=buf_str;
     3: inst_code:=buf_str;
     4: date_upd:=buf_str;
    end;
   end;


   stdate_upd:=EncodeDateTime(StrToInt(copy(date_upd, 1, 4)),
                          StrToInt(copy(date_upd, 5, 2)),
                          StrToInt(copy(date_upd, 7, 2)),
                          StrToInt(copy(date_upd, 9, 2)),
                          StrToInt(copy(date_upd, 11, 2)),
                          StrToInt(copy(date_upd, 13, 2)),
                          0);

   fpath := copy(fname, 1, Pos('/', fname)-1);
 //  showmessage(fpath);

   k:=Pos('/', fname);
   buf_str:='';
   repeat
    inc(k);
    if fname[k]<>'/' then buf_str:=buf_str+fname[k];
   until fname[k]='/';

   platf:=buf_str;
   www:='https://fleetmonitoring.euro-argo.eu/float/'+platf;

   ID:=20000000+strtoint(platf);
   ID_buf[str_cnt-9] := ID;

   try
 //  showmessage(DataPath+fname);
    nc_open(pansichar(AnsiString(DataPath+fname)), 0, ncid); // only for reading

     nc_inq_varid (ncid, pAnsiChar('PROJECT_NAME'), varidp);
     SetLength(ip, 64);
     nc_get_var_text(ncid, varidp, ip);
     proj:=trim(pchar(ip));

     nc_inq_varid (ncid, pAnsiChar('PI_NAME'), varidp);
     SetLength(ip, 64);
     nc_get_var_text(ncid, varidp, ip);
     PI:=trim(pchar(ip));

     nc_inq_varid (ncid, pAnsiChar('OPERATING_INSTITUTION'), varidp);
     SetLength(ip, 64);
     nc_get_var_text(ncid, varidp, ip);
     op_inst:=trim(pchar(ip));

     notes_str:='Project: '+proj+#13+'Operating institute: '+op_inst;
   finally
    nc_close(ncid);
   end;

    with Qt1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT ID, DATE_UPDATED FROM CRUISE WHERE ID=:ID ');
      ParamByName('ID').AsInteger:=ID;
     Open;
   end;

   if Qt1.IsEmpty=false then begin
   if stdate_upd=Qt1.FieldByName('DATE_UPDATED').AsDateTime then begin
     inc(cnt_kept);
     writeln(dat0, st);
     flush(dat0);
   end;
   if stdate_upd>Qt1.FieldByName('DATE_UPDATED').AsDateTime then begin
     if ToWrite then begin
        with Qt2 do begin
          Close;
           Sql.Clear;
           SQL.Add(' UPDATE CRUISE SET DATE_UPDATED=:DD ');
           SQL.Add(' WHERE ID=:ID ');
           ParamByName('ID').Value:=ID;
           ParamByName('DD').Value:=stdate_upd;
          ExecSQL;
        end;
     end;

      inc(cnt_upd);

      writeln(dat2, st);
      flush(dat2);
     Trt.CommitRetaining;
    end;
   end;

   if Qt1.IsEmpty=true then begin
    country_id:=0;
    institute_id:=0;
    project_id:=0;
    GetCodes(inst_code, country_id, institute_id, project_id);

    if (country_id<>-9) and (institute_id<>-9) and (project_id<>-9) then begin
     //checking if platform exists
     with Qt2 do begin
       Close;
        Sql.Clear;
        SQL.Add(' SELECT ID FROM PLATFORM ');
        SQL.Add(' WHERE ID=:ID ');
        ParamByName('ID').Value:=ID;
       Open;
     end;

     // inserting new platform
    if ToWrite then begin
     if (Qt2.IsEmpty=true) then begin
       PutFDBPlatform(Qt3, ID, platf, country_id, null, stdate_upd, stdate_upd);
      Trt.CommitRetaining;
     end;

    // inserting new cruise
      PutFDBCruise(Qt3, ID, ID, 5, institute_id, project_id, null, platf,
        pi, notes_str, null, www, null, null, stdate_upd, stdate_upd);
      Trt.CommitRetaining;
    end;  //towrite

     inc(cnt_add);
     writeln(dat1, st);
     flush(dat1);
    end; //codes exist
   end; // qt1 is empty

   inc(str_cnt);
  // if str_cnt mod 500=0 then
  //  write(#13+'Processed strings: '+inttostr(str_cnt));

   Qt1.Close;
  until eof(dat);

//  writeln('checking for missing cruises');
  (* removing any cruises which are not in the list any more *)
   cnt_del:=0;
   with Qt1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM CRUISE ');
       SQL.Add(' WHERE ID BETWEEN 20000001 AND 30000000 ');
       SQL.Add(' ORDER BY ID ');
     Open;
   end;

   while not Qt1.EOF do begin
    ID:=Qt1.FieldByName('ID').Value;

    fl:=0;
    For c:=0 to high(ID_buf) do begin
     if ID_buf[c]=ID then begin
       fl:=1;
       break;
     end;
    end;

   if (fl=0) then begin
    if ToWrite then begin
      with Qt2 do begin
       Close;
        Sql.Clear;
        SQL.Add(' DELETE FROM CRUISE WHERE ID=:ID ');
        ParamByName('ID').Value:=ID;
       ExecSQL;
      end;

      with Qt2 do begin
       Close;
        Sql.Clear;
        SQL.Add(' DELETE FROM PLATFORM WHERE ID=:ID ');
        ParamByName('ID').Value:=ID;
       ExecSQL;
      end;
      Trt.CommitRetaining;
    end;

      inc(cnt_del);

      writeln(dat3, inttostr(ID-20000000));
      flush(dat3);
    end;
    Qt1.Next;
   end;
   Qt1.Close;

  finally
   CloseFile(dat);
   CloseFile(dat0);
   CloseFile(dat1);
   CloseFile(dat2);
   CloseFile(dat3);

   TRt.Commit;
   Qt1.Free;
   Qt2.Free;
   Qt3.Free;
  end;
end;


(* Reading input metadata file *)
procedure ARGO_STATION(DB:TIBConnection; md_file, log_path:string;
  ToWrite:boolean;  isCore: boolean; first_buoy:integer; Var cnt_kept,
  cnt_updated, cnt_new, cnt_skipped: integer);
Type
  MDFromDatabase=record
    ID:integer;
    Cruise_ID:integer;
    StNum:string;
    file_path:string;
    Date_ins:TDateTime;
    Date_upd:TDateTime;
end;
Type
  MDFromFile=record
    platf:string;
    Cruise_ID:integer;
    StNum:string;
    Date_st:TDateTime;
    Date_upd:TDateTime;
    Lat:real;
    Lon:real;
    QF:integer;
    fname_full: string;
    fname_short: string;
    param_str:string;
end;
MDDB=array of MDFromDatabase;
MDF=array of MDFromFile;
Var
  dat:text;
 // isCore:boolean;

  ID, c, k, max_id, new_id, pp:int64;
  cnt_str, MDF_arr_cnt, MDDB_arr_cnt: int64;
  k_db, cc, par_cnt, ID_current: int64;

  st, fname, fpath, date_str, platf, buf_str, date_upd, data_file:string;
  cruise_id, cnt_missing_file, tbl_id: integer;

  lat, lon:string;
  stlat, stlon:real;


  Qt2, Qt1:TSQLQuery;
  TRt:TSQLTransaction;

  stdate, stdate_upd_db, stdate_add_db, stdate_upd_f, max_date_upd:TDateTime;
  stnum, tbl, station_type, param_str:string;
  cast, QF:integer;

  dat0, dat1, dat2, dat3, dat4:text;
  DateStart:TDateTime;

  QF_str: string;

  MDDB_arr: MDDB;
  MDF_arr:MDF;

  Available_ID: array of int64;

begin

  if isCore then station_type:='CORE' else station_type:='SYNTHETIC';

  fpath:=ExtractFilePath(md_file);
  AssignFile(dat3, log_path+'ARGO_'+station_type+'_missing_md.txt'); rewrite(dat3); // missing metadata - skipping
  AssignFile(dat4, log_path+'ARGO_'+station_type+'_missing_file.txt'); rewrite(dat4); // missing initial files

  // Opening data file
  AssignFile(dat, md_file); reset(dat);

  // Skipping the header
  cnt_str:=0;
  repeat
   inc(cnt_str);
   readln(dat, st);
  until copy(st,1, 4)='file';

  if first_buoy<>-9 then begin
   repeat
     inc(cnt_str);
     readln(dat, st);
   until pos(IntToStr(first_buoy), st)>0;
  end;

 // showmessage(st);

  SetLength(MDF_arr, 5000000);
  MDF_arr_cnt:=0;

  cnt_missing_file:=0;
  cnt_skipped:=0;
  repeat
   inc(cnt_str);
   readln(dat, st);

    c:=0; pp:=0;
   //reading first 4 columns
   for k:=1 to 8 do begin
    buf_str:='';
    repeat
      inc(c);
      inc(pp);
      if st[c]<>',' then buf_str:=buf_str+st[c];
    until (st[c]=',') or (c=length(st));

    case k of
     1: fname:=buf_str;
     2: date_str:=buf_str;
     3: lat:=buf_str;
     4: lon:=buf_str;
     8: param_str:=buf_str;
    end;
   end;

   date_upd:=copy(st, length(st)-13, 14);

   (* if data file is not found - skip it *)
   data_file:=fpath+pathDelim+'dac'+PathDelim+fname;
   if not FileExists(data_file) then begin
     inc(cnt_missing_file);
     writeln(dat4, fname); // file doesn't exist
     flush(dat4);
     Continue;
   end;

   // flags from the file name
   if copy(ExtractFileName(fname), 1, 1)='S' then
       QF_str:=copy(ExtractFileName(fname), 2, 1) else
       QF_str:=copy(ExtractFileName(fname), 1, 1);

   QF:=-1;
   if QF_str='D' then QF:=4;
   if QF_str='R' then QF:=0;

   k:=Pos('/', fname);
   buf_str:='';
   repeat
    inc(k);
    if fname[k]<>'/' then buf_str:=buf_str+fname[k];
   until fname[k]='/';
   platf:=buf_str;

   cruise_ID:=20000000+strtoint(platf);


   stnum:=copy(fname, pos('_', fname)+1, length(fname));
   stnum:=copy(stnum, 1, length(stnum)-3);

   if copy(stnum, length(stnum), 1)='D' then begin
     stnum:=copy(stnum,1, length(stnum)-1);
     stnum:=IntToStr(StrToInt(stnum))+'D';
   end else
     stnum:=IntToStr(StrToInt(stnum));

   if copy(stnum, length(stnum), 1)='D' then cast:=2 else cast:=1;

  // showmessage(stnum+'   '+copy(stnum, length(stnum), 1));

   if (trim(lat)<>'') and
      (trim(lon)<>'') and
      (length(date_str)=14) and
      (cruise_id>0) then begin

       stlat:=StrToFloat(lat);
       stlon:=StrToFloat(lon);

       if (stlat>=-90) and (stlat<=90) and (stlon>=-180) and (stlon<=180) then begin

       stdate:=EncodeDateTime(StrToInt(copy(date_str, 1, 4)),
                          StrToInt(copy(date_str, 5, 2)),
                          StrToInt(copy(date_str, 7, 2)),
                          StrToInt(copy(date_str, 9, 2)),
                          StrToInt(copy(date_str, 11, 2)),
                          StrToInt(copy(date_str, 13, 2)),
                          0);

       stdate_upd_f:=EncodeDateTime(StrToInt(copy(date_upd, 1, 4)),
                          StrToInt(copy(date_upd, 5, 2)),
                          StrToInt(copy(date_upd, 7, 2)),
                          StrToInt(copy(date_upd, 9, 2)),
                          StrToInt(copy(date_upd, 11, 2)),
                          StrToInt(copy(date_upd, 13, 2)),
                          0);

        MDF_arr[MDF_arr_cnt].platf:=platf;
        MDF_arr[MDF_arr_cnt].Cruise_ID:=cruise_id;
        MDF_arr[MDF_arr_cnt].StNum:=stnum;
        MDF_arr[MDF_arr_cnt].Date_st:=stdate;
        MDF_arr[MDF_arr_cnt].Date_upd:=stdate_upd_f;
        MDF_arr[MDF_arr_cnt].Lat:=stlat;
        MDF_arr[MDF_arr_cnt].Lon:=stlon;
        MDF_arr[MDF_arr_cnt].QF:=QF;
        MDF_arr[MDF_arr_cnt].fname_full:=data_file;
        MDF_arr[MDF_arr_cnt].fname_short:=fname;
        MDF_arr[MDF_arr_cnt].param_str:=param_str;

        inc(MDF_arr_cnt);
       end; //coordinates -90 - 90; -180 - 180
   end else begin // if some important metadata is missing -> skipping
     inc(cnt_skipped);
     writeln(dat3, st);
     flush(dat3);
   end;
  until eof(dat);
  CloseFile(dat);
  CloseFile(dat3);
  CloseFile(dat4);

  SetLength(MDF_arr, MDF_arr_cnt);
//  showmessage(MDF_arr[MDF_arr_cnt-1].StNum);
//  showmessage('stations: '+inttostr(MDF_arr_cnt)+' rows: '+inttostr(cnt_str));
  try
     TRt:=TSQLTransaction.Create(nil);
     TRt.DataBase:=frmdm.IBDB;

     Qt1:=TSQLQuery.Create(nil);
     Qt1.Database:=frmdm.IBDB;
     Qt1.Transaction:=TRt;

     Qt2:=TSQLQuery.Create(nil);
     Qt2.Database:=frmdm.IBDB;
     Qt2.Transaction:=TRt;

      with Qt1 do begin
       Close;
        Sql.Clear;
        SQL.Add(' select max(id) from station where ID BETWEEN 20000001 AND 30000000  ');
       Open;
        max_id  :=Qt1.Fields[0].AsInteger;
       Close;
      end;

      with Qt1 do begin
       Close;
        Sql.Clear;
        SQL.Add(' select id, cruise_id, st_number_origin, ');
        SQL.Add(' file_path, date_added, date_updated from station ');
        SQL.Add(' where id between 20000001 and 30000000 ');
        SQL.Add(' order by id ');
       Open;
       Last;
       First;
      end;

      SetLength(MDDB_arr, Qt1.RecordCount);

      MDDB_arr_cnt:=0;
      while not Qt1.EOF do begin
         MDDB_arr[MDDB_arr_cnt].ID:=Qt1.FieldByName('ID').asInteger;
         MDDB_arr[MDDB_arr_cnt].Cruise_ID:=Qt1.FieldByName('CRUISE_ID').asInteger;
         MDDB_arr[MDDB_arr_cnt].StNum:=Qt1.FieldByName('st_number_origin').asString;
         MDDB_arr[MDDB_arr_cnt].Date_ins:=Qt1.FieldByName('date_added').asDateTime;
         MDDB_arr[MDDB_arr_cnt].Date_upd:=Qt1.FieldByName('date_updated').asDateTime;
        inc(MDDB_arr_cnt);
       Qt1.Next;
      end;
      Qt1.Close;

      // Looking for empty IDs
      AssignFile(dat0, log_path+'ARGO_AvailableIDs.txt'); rewrite(dat0);
      for k:=0 to high(MDDB_arr)-1 do begin
        if MDDB_arr[k+1].ID>MDDB_arr[k].ID+1 then begin
          ID_current:=MDDB_arr[k].ID;
          repeat
            inc(ID_current);
            Insert(ID_current, Available_ID, 0);
            writeln(dat0, inttostr(ID_current));
          until (MDDB_arr[k+1].ID=ID_current+1);
        end;
      end;
      CloseFile(dat0);

  // assigning log files
  AssignFile(dat0, log_path+'ARGO_'+station_type+'_kept.txt');    rewrite(dat0);
  AssignFile(dat1, log_path+'ARGO_'+station_type+'_added.txt');   rewrite(dat1); // new sations
  AssignFile(dat2, log_path+'ARGO_'+station_type+'_updated.txt'); rewrite(dat2); // updated

  cnt_kept:=0;
  cnt_updated:=0;
  cnt_new:=0;

//showmessage('stations file: '+inttostr(MDF_arr_cnt)+#13+
//'stations DB: '+inttostr(MDDB_arr_cnt));

 for pp:=0 to MDF_arr_cnt-1 do begin

   stdate_upd_f:=MDF_arr[pp].date_upd;
   data_file:=MDF_arr[pp].fname_full;
   param_str:=MDF_arr[pp].param_str;

    ID:=0;
    For cc:=0 to MDDB_arr_cnt-1 do begin
      if (MDDB_arr[cc].Cruise_ID=MDF_arr[pp].cruise_id) and
         (MDDB_arr[cc].StNum=MDF_arr[pp].StNum) then begin

           ID:=MDDB_arr[cc].ID;
           stdate_upd_db:=MDDB_arr[cc].Date_upd;
           stdate_add_db:=MDDB_arr[cc].Date_ins;

         Delete(MDDB_arr,cc,1); //removing exisiting station
         break;
        end;
       end;

      (* station is in the database *)
      if ID>0 then begin
        UpdateStationParameters(Qt1, ID, MDF_arr[pp].param_str, stdate_upd_f);
     {   // keep
        if (stdate_upd_db >= stdate_upd_f) and (data_file = MDF_arr[pp].fname_short) then begin
          writeln(dat0, inttostr(id)+#9+
            data_file+#9+
            datetimetostr(stdate_upd_db)+#9+
            datetimetostr(stdate_upd_f));
          inc(cnt_kept);
        end;

        // update
        if (stdate_upd_db<stdate_upd_f) or
           ((isCore = false) and (stdate_upd_db = stdate_upd_f) and (data_file <> MDF_arr[pp].fname_short)) then begin

          if ToWrite then begin
            with Qt1 do begin
              Close;
                SQL.Clear;
                SQL.Add(' UPDATE STATION SET ');
                SQL.Add(' LATITUDE=:lat, LONGITUDE=:lon, DATEANDTIME=:dd, ');
                SQL.Add(' QCFLAG=:QF, FILE_PATH=:fp, DATE_UPDATED=:upd ');
                SQL.Add(' where ID=:ID ');
                ParamByName('ID' ).Value:=ID;
                ParamByName('lat').Value:=MDF_arr[pp].Lat;
                ParamByName('lon').Value:=MDF_arr[pp].Lon;
                ParamByName('dd' ).Value:=MDF_arr[pp].Date_st;
                ParamByName('QF' ).Value:=MDF_arr[pp].QF;
                ParamByName('fp' ).Value:=MDF_arr[pp].fname_short;
                ParamByName('upd').Value:=stdate_upd_f;
              ExecSQL;
            end;
            UpdateStationParameters(Qt2, Qt1, ID, MDF_arr[pp].param_str, stdate_upd_f);
          end;

          writeln(dat2, inttostr(id)+#9+
            data_file+#9+
            datetimetostr(stdate_upd_db)+#9+
            datetimetostr(stdate_upd_f));
        // flush(dat2);
        inc(cnt_updated);
        end;      }
      end; //ID>0

      (* new station *)
      if (ID=0) and (data_file<>'') then begin
        // filling gaps in IDs
        if high(Available_ID) > 0 then begin
          new_id:=Available_ID[high(Available_ID)];
          Delete(Available_ID, high(Available_ID), 1);
        end else begin
          inc(max_id);
          new_id:=max_id;
        end;

         if ToWrite then begin
           // adding station
           PutFDBStation(Qt1, new_id, MDF_arr[pp].Lat, MDF_arr[pp].Lon,
              MDF_arr[pp].Date_st, null, MDF_arr[pp].Cruise_ID, MDF_arr[pp].StNum,
              null, MDF_arr[pp].QF, 1, 1, MDF_arr[pp].fname_short,
              stdate_upd_f, stdate_upd_f);
         end;

       writeln(dat1, inttostr(new_id)+#9+data_file);
      // flush(dat1);
       inc(cnt_new);
      end;//ID=0 -> writing a new station }

   end; //pp
   Qt2.Close;

  finally
     Trt.Commit;
     Qt1.Free;
     Qt2.Free;
     Trt.Free;

     CloseFile(dat0);
     CloseFile(dat1);
     CloseFile(dat2);
  end;
end;

procedure GetCodes(argo_code:string; Var country_id, institute_id, project_id:integer);
begin
 country_id:=-9;
 institute_id:=-9;
 project_id:=-9;

 if argo_code='AO' then begin institute_id:=251;  project_id:=422; country_id:=186; end;
 if argo_code='BO' then begin institute_id:=655;  project_id:=31;  country_id:=229; end;
 if argo_code='GE' then begin institute_id:=17;   project_id:=769; country_id:=161; end;
 if argo_code='HZ' then begin institute_id:=820;  project_id:=69;  country_id:=231; end;
 if argo_code='CS' then begin institute_id:=48;   project_id:=27;  country_id:=164; end;
 if argo_code='EA' then begin institute_id:=1486; project_id:=542; country_id:=190; end;
 if argo_code='VL' then begin institute_id:=1487; project_id:=768; country_id:=299; end;
 if argo_code='GT' then begin institute_id:=1;    project_id:=770; country_id:=1;   end; // institute unknown
 if argo_code='IN' then begin institute_id:=821;  project_id:=187; country_id:=196; end;
 if argo_code='PL' then begin institute_id:=1488; project_id:=771; country_id:=222; end;
 if argo_code='IF' then begin institute_id:=388;  project_id:=124; country_id:=190; end;
 if argo_code='CI' then begin institute_id:=1489; project_id:=61;  country_id:=173; end;
 if argo_code='JA' then begin institute_id:=538;  project_id:=201; country_id:=204; end;
 if argo_code='JM' then begin institute_id:=539;  project_id:=201; country_id:=204; end;
 if argo_code='KM' then begin institute_id:=125;  project_id:=451; country_id:=179; end;
 if argo_code='KO' then begin institute_id:=124;  project_id:=451; country_id:=179; end;
 if argo_code='LV' then begin institute_id:=1490; project_id:=124; country_id:=190; end;
 if argo_code='MB' then begin institute_id:=190;  project_id:=422; country_id:=186; end;
 if argo_code='ME' then begin institute_id:=822;  project_id:=61;  country_id:=173; end;
 if argo_code='NA' then begin institute_id:=1491; project_id:=422; country_id:=186; end;
 if argo_code='NM' then begin institute_id:=823;  project_id:=69;  country_id:=231; end;
 if argo_code='PM' then begin institute_id:=1492; project_id:=422; country_id:=186; end;
 if argo_code='RU' then begin institute_id:=1;    project_id:=768; country_id:=245; end; // institute unknown
 if argo_code='SI' then begin institute_id:=243;  project_id:=422; country_id:=186; end;
 if argo_code='SP' then begin institute_id:=1;    project_id:=772; country_id:=184; end; // institute unknown
 if argo_code='UW' then begin institute_id:=250;  project_id:=422; country_id:=186; end;
 if argo_code='WH' then begin institute_id:=244;  project_id:=422; country_id:=186; end;
end;


procedure QFMapping(argo_QF:integer; var QF:integer);
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

procedure UpdateStationParameters(Q:TSQLQuery; ID:int64;
  param_str: string; stdate_upd_f:TDateTime);
Var
  k, c, tbl_id:integer;
  buf_str: string;
begin
 k:=5; //skipping PRES
 repeat
  buf_str:='';
  tbl_id:=-1;
  repeat
    inc(k);
    if param_str[k]<>' ' then buf_str:=buf_str+param_str[k];
  until (param_str[k]=' ') or (k=length(param_str));

  tbl_id:=-1;
  for c:=0 to high(ARGO_FDB_MAPPING) do begin
 //  showmessage(ARGO_FDB_MAPPING[c].NAME_ARGO+'   '+buf_str);
    if buf_str=ARGO_FDB_MAPPING[c].NAME_ARGO then begin
      tbl_id:=ARGO_FDB_MAPPING[c].TBL_ID;
      break;
    end;
  end;

  if (tbl_id>0) then
      PutFDBStationParameters(Q, ID, tbl_id)
    else
      showmessage('Table is missing: '+buf_str+'   '+inttostr(tbl_id));
 until k=length(param_str);
end;

procedure GetTableName(var_name:string; Var tbl_name: string);
begin
 tbl_name:='';
  if var_name='TEMP' then tbl_name:='P_TEMPERATURE';
  if var_name='PSAL' then tbl_name:='P_SALINITY';
  if var_name='DOXY' then tbl_name:='P_OXYGEN';
  if var_name='CDOM' then tbl_name:='P_CDOM';
  if var_name='CHLA' then tbl_name:='P_CHLOROPHYLL';
  if var_name='NITRATE'    then tbl_name:='P_NITRATE';
  if var_name='TURBIDITY'  then tbl_name:='P_TURBIDITY';
  if var_name='PH_IN_SITU_TOTAL' then tbl_name:='P_PHTSINSITUTP';
  if var_name='BISULFIDE'        then tbl_name:='P_BISULFIDE';
  //BBP700
  //DOWN_IRRADIANCE380
  //DOWN_IRRADIANCE412
  //DOWN_IRRADIANCE490
  if var_name='DOWNWELLING_PAR'  then tbl_name:='P_PAR';
end;

end.

