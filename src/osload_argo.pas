unit osload_argo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, IBConnection, DB, SQLDB,
  dynlibs, declarations_netcdf, dm, Dialogs, procedures;

procedure ARGO_CRUISE(netcdf: TLibHandle; DB:TIBConnection;
  DataPath, log_path: string; ToWrite:boolean;
  var cnt_add, cnt_upd, cnt_del: integer);

procedure ARGO_STATION(DB:TIBConnection; md_file, log_path:string;
  ToWrite:boolean; Var cnt_kept, cnt_updated, cnt_new, cnt_skipped,
  cnt_error: integer);


procedure GetCodes(argo_code:string; Var country_id, institute_id,
  project_id:integer);


implementation

procedure ARGO_CRUISE(netcdf: TLibHandle; DB:TIBConnection;
  DataPath, log_path: string; ToWrite:boolean;
  var cnt_add, cnt_upd, cnt_del: integer);
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

  ncid, varidp:integer;
  ip: array of PAnsiChar;
  proj, pi, op_inst, notes_str:string;

  dat1, dat2, dat3:text;
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

  AssignFile(dat1, log_path+'ARGO_CRUISE_added.txt');   rewrite(dat1);
  AssignFile(dat2, log_path+'ARGO_CRUISE_updated.txt'); rewrite(dat2);
  AssignFile(dat3, log_path+'ARGO_CRUISE_removed.txt'); rewrite(dat3);

  AssignFile(dat,  DataPath+'ar_index_global_meta.txt'); reset(dat);

 // showmessage(DataPath+'ar_index_global_meta.txt');
  for c:=1 to 9 do readln(dat, st);

  cnt_add:=0;
  cnt_upd:=0;
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
//   showmessage('p:' +platf);

   ID:=20000000+strtoint(platf);
   ID_buf[str_cnt-9] := ID;

//   showmessage('id: '+inttostr(ID));

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
      with Qt3 do begin
       Close;
        Sql.Clear;
        SQL.Add(' INSERT INTO PLATFORM ');
        SQL.Add(' (ID, NAME, COUNTRY_ID, DATE_ADDED, DATE_UPDATED, NOTES) ');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :name, :country_id, :date_added, :date_updated, :NOTES) ');
        ParamByName('ID').Value:=ID;
        ParamByName('name').Value:=platf;
        ParamByName('country_id').Value:=country_id;
        ParamByName('date_added').Value:=stdate_upd;
        ParamByName('date_updated').Value:=stdate_upd;
        ParamByName('NOTES').AsWideString:='https://fleetmonitoring.euro-argo.eu/float/'+platf;
       ExecSQL;
      end;
      Trt.CommitRetaining;
     end;

    // inserting new station
      with Qt3 do begin
       Close;
        SQL.Clear;
        SQL.Add(' INSERT INTO CRUISE');
        SQL.Add(' (ID, platform_id, source_id, institute_id, project_id, ');
        SQL.Add(' CRUISE_NUMBER, DATE_START_TOTAL, DATE_END_TOTAL, ');
        SQL.Add(' DATE_START_DATABASE, DATE_END_DATABASE, PI, NOTES, DATE_ADDED, ');
        SQL.Add(' DATE_UPDATED, LATITUDE_MIN, LATITUDE_MAX, LONGITUDE_MIN, ');
        SQL.Add(' LONGITUDE_MAX, SELECTED, DUPLICATE, STATIONS_TOTAL, STATIONS_DATABASE, ');
        SQL.Add(' STATIONS_DUPLICATES, EXPOCODE) ');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :platform_id, :source_id, :institute_id, :project_id, ');
        SQL.Add(' :CRUISE_NUMBER, :DATE_START_TOTAL, :DATE_END_TOTAL, ');
        SQL.Add(' :DATE_START_DATABASE, :DATE_END_DATABASE, :PI, :NOTES, :DATE_ADDED, ');
        SQL.Add(' :DATE_UPDATED, :LATITUDE_MIN, :LATITUDE_MAX, :LONGITUDE_MIN, ');
        SQL.Add(' :LONGITUDE_MAX, :SELECTED, :DUPLICATE, :STATIONS_TOTAL, :STATIONS_DATABASE, ');
        SQL.Add(' :STATIONS_DUPLICATES, :EXPOCODE) ');
        ParamByName('ID').Value:=ID;
        ParamByName('platform_id').Value:=ID;
        ParamByName('source_id').Value:=5;
        ParamByName('institute_id').Value:=institute_id;
        ParamByName('project_id').Value:=project_id;
        ParamByName('cruise_number').Value:=platf;
        ParamByName('date_start_total').Value:=stdate_upd;
        ParamByName('date_end_total').Value:=stdate_upd;
        ParamByName('date_start_database').Value:=stdate_upd;
        ParamByName('date_end_database').Value:=stdate_upd;
        ParamByName('PI').Value:=pi;
        ParamByName('NOTES').Value:=notes_str;
        ParamByName('date_added').Value:=stdate_upd;
        ParamByName('date_updated').Value:=stdate_upd;
        ParamByName('LATITUDE_MIN').Value:=0;
        ParamByName('LATITUDE_MAX').Value:=0;
        ParamByName('LONGITUDE_MIN').Value:=0;
        ParamByName('LONGITUDE_MAX').Value:=0;
        ParamByName('SELECTED').Value:=false;
        ParamByName('DUPLICATE').Value:=false;
        ParamByName('stations_total').Value:=0;
        ParamByName('stations_database').Value:=0;
        ParamByName('stations_duplicates').Value:=0;
        ParamByName('EXPOCODE').Value:=fpath;
       ExecSQL;
      end;
      Trt.CommitRetaining;
     end;
    end;

     inc(cnt_add);
     writeln(dat1, st);
     flush(dat1);
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
  ToWrite:boolean; Var cnt_kept, cnt_updated, cnt_new, cnt_skipped,
  cnt_error: integer);
Type
  MDFromDatabase=record
    ID:integer;
    Cruise_ID:integer;
    StNum:string;
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
end;
MDDB=array of MDFromDatabase;
MDF=array of MDFromFile;
Var
  dat:text;
 // isCore:boolean;

  ID, c, k, max_id, pp:int64;
  cnt_str, MDF_arr_cnt, MDDB_arr_cnt: int64;
  k_db, cc, par_cnt: int64;

  st, fpath, fname, date_str, platf, buf_str, date_upd:string;
  cruise_id, cnt_missing_file: integer;

  lat, lon:string;
  stlat, stlon:real;


  Qt2, Qt1:TSQLQuery;
  TRt:TSQLTransaction;

  stdate, stdate_upd_db, stdate_add_db, stdate_upd_f, max_date_upd:TDateTime;
  stnum, tbl:string;
  cast, QF:integer;

  dat1, dat2, dat3, dat4:text;
  DateStart:TDateTime;

 QF_str: string;

 MDDB_arr: MDDB;
 MDF_arr:MDF;
 ALength: Int64;
begin

  fpath:=ExtractFilePath(md_file);
//  AssignFile(dat3, log_path+'ARGO_STATION_missing_md.txt'); rewrite(dat3); // missing metadata - skipping
//  AssignFile(dat4, log_path+'ARGO_STATION_missing_file.txt'); rewrite(dat4); // missing initial files

  AssignFile(dat, md_file); reset(dat);
  cnt_str:=0;
  repeat
   inc(cnt_str);
   readln(dat, st);
  until copy(st,1, 4)='file';

  SetLength(MDF_arr, 5000000);
  MDF_arr_cnt:=0;

  cnt_missing_file:=0;
  cnt_skipped:=0;
  repeat
   inc(cnt_str);
   readln(dat, st);

    c:=0; pp:=0;
   //reading first 4 columns
   for k:=1 to 4 do begin
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
    end;
   end;

   date_upd:=copy(st, length(st)-13, 14);

     (* if data file is not found - skip it *)
  // showmessage(fpath+pathDelim+'dac'+PathDelim+fname);
   if FileExists(fpath+pathDelim+'dac'+PathDelim+fname) then begin

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

        inc(MDF_arr_cnt);
       end; //coordinates -90 - 90; -180 - 180
       end else begin // if some inportant metadata is missing -> skipping
          inc(cnt_skipped);
      //    writeln(dat3, st);
      //    flush(dat3);
          end;

        end else begin
         inc(cnt_missing_file);
      //   writeln(dat4, fname); // file doesn't exist
      //   flush(dat4);
        end;

  until eof(dat);
  CloseFile(dat);
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
        SQL.Add(' select id, cruise_id, st_number_origin, date_added, ');
        SQL.Add(' date_updated from station ');
        SQL.Add(' where cruise_id between 20000001 and 30000000 ');
        SQL.Add(' order by cruise_id ');
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

  // assigning log files
  AssignFile(dat1, log_path+'ARGO_STATION_added.txt');   rewrite(dat1); // new sations
//  AssignFile(dat2, log_path+'ARGO_STATION_updated.txt'); rewrite(dat2); // updated

  cnt_kept:=0;
  cnt_updated:=0;
  cnt_new:=0;
  cnt_error:=0;

showmessage('stations file: '+inttostr(MDF_arr_cnt)+#13+
'stations DB: '+inttostr(MDDB_arr_cnt));

 for pp:=0 to MDF_arr_cnt-1 do begin

   stdate_upd_f:=MDF_arr[pp].date_upd;

    ID:=0;
    For cc:=0 to MDDB_arr_cnt-1 do begin
      if (MDDB_arr[cc].Cruise_ID=MDF_arr[pp].cruise_id) and
         (MDDB_arr[cc].StNum=MDF_arr[pp].StNum) then begin

           ID:=MDDB_arr[cc].ID;
           stdate_upd_db:=MDDB_arr[cc].Date_upd;
           stdate_add_db:=MDDB_arr[cc].Date_ins;

           Delete(MDDB_arr, cc, 1);
         {  ALength := Length(MDDB_arr);
           if (ALength > 1) then begin
            for k:=cc+1 to ALength-1 do MDDB_arr[k-1]:=MDDB_arr[k];
             SetLength(MDDB_arr, ALength-1);
           end;  }
         break;
        end;
       end;

  //  showmessage(inttostr(ID));

      (* station is in the database *)
      if ID>0 then begin

        if stdate_upd_db>=stdate_upd_f then begin
         inc(cnt_kept);
        end;

        if stdate_upd_db<stdate_upd_f then begin
         inc(cnt_updated);
      //   showmessage('update '+datetimetostr(stdate_upd_db)+'   '+
      //   datetimetostr(stdate_upd_f)+'   '+inttostr(MDF_arr[pp].QF));

         if ToWrite then begin
            with Qt1 do begin
             Close;
              SQL.Clear;
              SQL.Add(' UPDATE STATION SET ');
              SQL.Add(' LATITUDE=:LT, LONGITUDE=:LN, ');
              SQL.Add(' DATE_UPDATED=:DA, QCFLAG=:QF ');
              SQL.Add(' WHERE ID=:ID ');
              ParamByName('ID').Value:=id;
              ParamByName('LT').Value:=MDF_arr[pp].Lat;
              ParamByName('LN').Value:=MDF_arr[pp].Lon;
              ParamByName('DA').Value:=MDF_arr[pp].Date_upd;
              ParamByName('QF').Value:=MDF_arr[pp].QF;
             ExecSQL;
            end;
    //     writeln(dat2, inttostr(id)+#9+fname);
    //     flush(dat2);
       end;
      end;
      end; //ID>0

    //  if ID=0 then showmessage(inttostr(pp));

      (* new station *)
      if (ID=0) and (MDF_arr[pp].StNum<>'') then begin
       inc(cnt_new);
       inc(max_id);

        if ToWrite then begin
         with Qt1 do begin
          Close;
           SQL.Clear;
           SQL.Add(' INSERT INTO STATION ');
           SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ');
           SQL.Add(' ST_NUMBER_ORIGIN, DATE_ADDED, DATE_UPDATED, ');
           SQL.Add(' CAST_NUMBER, QCFLAG)');
           SQL.Add(' VALUES ');
           SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ');
           SQL.Add(' :ST_NUMBER_ORIGIN, :DATE_ADDED, :DATE_UPDATED, ');
           SQL.Add(' :CAST_NUMBER, :QCFLAG)');
           ParamByName('ID').Value:=max_id;
           ParamByName('latitude').Value:=MDF_arr[pp].Lat;
           ParamByName('longitude').Value:=MDF_arr[pp].Lon;
           ParamByName('dateandtime').Value:=MDF_arr[pp].Date_st;
           ParamByName('cruise_id').Value:=MDF_arr[pp].Cruise_ID;
           ParamByName('st_number_origin').Value:=MDF_arr[pp].StNum;
           ParamByName('date_added').Value:=MDF_arr[pp].Date_upd;
           ParamByName('date_updated').Value:=MDF_arr[pp].Date_upd;
           ParamByName('cast_number').Value:=1;
           ParamByName('QCFLAG').Value:=MDF_arr[pp].QF;
          ExecSQL;
         end;
         end;
          writeln(dat1, MDF_arr[pp].platf);
          flush(dat1);
      end; //ID=0 -> writing a new station

    if ToWrite then
      if pp mod 1000 = 0 then Trt.CommitRetaining;

    if (pp>0) and (pp mod 100000 = 0) then
      showmessage(
      'processed from file: '+inttostr(pp)+#13+
      'left in the DB: '+inttostr(length(MDDB_arr))+#13+
      'kept: '+inttostr(cnt_kept)+#13+
      'updated: '+inttostr(cnt_updated)+#13+
      'inserted: '+inttostr(cnt_new));
end;


  finally
     Trt.Commit;
     Qt1.Free;
     Qt2.Free;
     Trt.Free;

     CloseFile(dat1);
     CloseFile(dat2);
     CloseFile(dat3);
     CloseFile(dat4);

   //OpenDocument(PChar(log_path));
  end;
end;


procedure GetCodes(argo_code:string; Var country_id, institute_id, project_id:integer);
begin
 country_id:=-9;
 institute_id:=-9;
 project_id:=-9;

 if argo_code='AO' then begin institute_id:=251; project_id:=422; country_id:=186; end;
 if argo_code='BO' then begin institute_id:=655; project_id:=31;  country_id:=229; end;
 if argo_code='CS' then begin institute_id:=48;  project_id:=27;  country_id:=164; end;
 if argo_code='HZ' then begin institute_id:=820; project_id:=69;  country_id:=231; end;
 if argo_code='IF' then begin institute_id:=388; project_id:=124; country_id:=190; end;
 if argo_code='IN' then begin institute_id:=821; project_id:=187; country_id:=196; end;
 if argo_code='JA' then begin institute_id:=538; project_id:=201; country_id:=204; end;
 if argo_code='JM' then begin institute_id:=539; project_id:=201; country_id:=204; end;
 if argo_code='KM' then begin institute_id:=125; project_id:=451; country_id:=179; end;
 if argo_code='KO' then begin institute_id:=124; project_id:=451; country_id:=179; end;
 if argo_code='ME' then begin institute_id:=822; project_id:=61;  country_id:=173; end;
 if argo_code='NM' then begin institute_id:=823; project_id:=69;  country_id:=231; end;
end;

end.

