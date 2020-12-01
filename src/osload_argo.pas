unit osload_argo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SQLDB, DB,
  DateUtils, Variants, BufDataset, LCLIntf, Buttons, ExtCtrls, math,
  IniFiles;

type

  { Tfrmload_argo }

  Tfrmload_argo = class(TForm)
    btnSelectDataFolder: TButton;
    btnRun: TButton;
    cgTasks: TCheckGroup;
    ePath: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Memo1: TMemo;

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnSelectDataFolderClick(Sender: TObject);

  private
    procedure GetCodes(argo_code:string; Var country_id, institute_id,
      project_id:integer);
    procedure GetTableName(var_name:string; Var tbl_name: string);
    procedure QFMapping(argo_QF:integer; var QF:integer);
    procedure UpdateCRUISE;
    procedure UpdateSTATION(fname:string);
    procedure WriteMetadata(ID, cruise_id: integer; StLat, StLon: real;
      StDate, stdate_add_db, stdate_upd_f:TDateTime; stnum:string;
      cast, QF:smallint);
    procedure WriteProfile(fname:string; id: integer);
    procedure GreyList;
    procedure GreyListUpdateTable(cruise_id, QF:integer;
      tbl_name:string; dd1, dd2:tDateTime);
    procedure UpdateCruiseInfo;
    procedure DeleteEmptyStations;
    procedure InsertLastLevel;
    procedure InsertGEBCODepth;
  public

  end;

var
  frmload_argo: Tfrmload_argo;

implementation

{$R *.lfm}

{ Tfrmload_argo }

uses osmain, dm, declarations_netcdf, GibbsSeaWater, procedures;


procedure Tfrmload_argo.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
  k:integer;
begin

  Ini := TIniFile.Create(IniFileName);
   try
     ePath.Text := Ini.ReadString('osload_argo', 'data_path',  '');
   finally
     Ini.Free;
   end;

  // all tasks checked
  for k:=0 to cgTasks.Items.Count-1 do cgTasks.Checked[k]:=true;

end;


(* Running tasks one by one *)
procedure Tfrmload_argo.btnRunClick(Sender: TObject);
begin
 memo1.Clear;
  if cgTasks.Checked[0] then UpdateCRUISE;
  if cgTasks.Checked[1] then UpdateSTATION('argo_synthetic-profile_index.txt');
  if cgTasks.Checked[2] then UpdateSTATION('ar_index_global_prof.txt');
  if cgTasks.Checked[3] then UpdateCruiseInfo;
  if cgTasks.Checked[4] then GreyList;
  if cgTasks.Checked[5] then InsertLastLevel;
  if cgTasks.Checked[6] then InsertGEBCODepth;
end;


procedure Tfrmload_argo.btnSelectDataFolderClick(Sender: TObject);
begin
  if frmosmain.ODir.Execute then ePath.Text:=frmosmain.ODir.FileName+PathDelim;
end;


(* reading ar_index_global_meta.txt and updating CRUISE *)
procedure Tfrmload_argo.UpdateCRUISE;
Var
  dat:text;
  c, k, cnt_added, cnt_updated, cnt_removed, ID:integer;
  st, fname, prof_type, inst_code, date_upd, platf, buf_str:string;
  country_id, institute_id, project_id: integer;
  stdate_upd:TDateTime;

  Qt1, Qt2:TSQLQuery;
  TRt:TSQLTransaction;

  ID_buf:TBufDataset;

  ncid, varidp:integer;
  ip: array of PAnsiChar;
  proj, pi, op_inst, notes_str, log_path:string;

  dat1, dat2, dat3:text;
  DateStart:TDateTime;
begin
if not FileExists(epath.text+'ar_index_global_meta.txt') then
  if MessageDlg('ar_index_global_meta.txt cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

  DateStart:=now;

  memo1.lines.add('');
  memo1.lines.add('Updating CRUISE');
  memo1.lines.add('Start: '+timetostr(DateStart));
  memo1.lines.add('');

try
    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;

    Qt1:=TSQLQuery.Create(self);
    Qt1.Database:=frmdm.IBDB;
    Qt1.Transaction:=TRt;

    Qt2:=TSQLQuery.Create(self);
    Qt2.Database:=frmdm.IBDB;
    Qt2.Transaction:=TRt;


    ID_buf:=TBufDataSet.Create(nil);
      with ID_buf.FieldDefs do begin
       Add('id', ftinteger, 0, false);
      end;
    ID_buf.CreateDataSet;


    log_path:=epath.text+PathDelim+'_Logs'+PathDelim;
     if not DirectoryExists(log_path) then CreateDir(log_path);

    AssignFile(dat1, log_path+'CRUISE_added.txt');   rewrite(dat1);
    AssignFile(dat2, log_path+'CRUISE_updated.txt'); rewrite(dat2);
    AssignFile(dat3, log_path+'CRUISE_removed.txt'); rewrite(dat3);


  AssignFile(dat, epath.text+'ar_index_global_meta.txt');
  reset(dat);

  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';

  cnt_added:=0;
  cnt_updated:=0;
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


   k:=Pos('/', fname);
   buf_str:='';
   repeat
    inc(k);
    if fname[k]<>'/' then buf_str:=buf_str+fname[k];
   until fname[k]='/';

   platf:=buf_str;

   ID:=20000000+strtoint(platf);


 //  showmessage(AnsiString(epath.text+fname));
   try
    nc_open(pansichar(AnsiString(epath.text+fname)), NC_NOWRITE, ncid); // only for reading

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

   with ID_buf do begin
    Append;
     FieldByName('ID').asInteger:=ID;
    Post;
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
    // showmessage(datetimetostr(stdate_upd)+'   '+datetimetostr(Qt1.FieldByName('DATE_UPDATED').AsDateTime));
      with Qt2 do begin
          Close;
           Sql.Clear;
           SQL.Add(' UPDATE CRUISE SET DATE_UPDATED=:DD ');
           SQL.Add(' WHERE ID=:ID ');
           ParamByName('ID').Value:=ID;
           ParamByName('DD').Value:=stdate_upd;
          ExecSQL;
      end;

      inc(cnt_updated);
       writeln(dat2, inttostr(ID));

     Trt.CommitRetaining;
    end;
   end;

   if Qt1.IsEmpty=true then begin
    GetCodes(inst_code, country_id, institute_id, project_id);

    if (country_id<>-9) and (institute_id<>-9) and (project_id<>-9) then begin
     with Qt2 do begin
       Close;
        Sql.Clear;
        SQL.Add(' INSERT INTO PLATFORM ');
        SQL.Add(' (ID, NAME, COUNTRY_ID, DATE_ADDED, NOTES) ');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :name, :country_id, :date_added, :NOTES) ');
        ParamByName('ID').Value:=ID;
        ParamByName('name').Value:=platf;
        ParamByName('country_id').Value:=country_id;
        ParamByName('date_added').Value:=stdate_upd;
        ParamByName('NOTES').AsWideString:='https://fleetmonitoring.euro-argo.eu/float/'+platf;
       ExecSQL;
      end;
    Trt.CommitRetaining;

    with Qt2 do begin
     Close;
      SQL.Clear;
      SQL.Add('insert into CRUISE');
      SQL.Add(' (ID, platform_id, source_id, institute_id, project_id, ');
      SQL.Add(' DATE_ADDED, DATE_UPDATED, DATE_START_TOTAL, DATE_END_TOTAL, ');
      SQL.Add(' DATE_START_DATABASE, DATE_END_DATABASE, CRUISE_NUMBER, PI, ');
      SQL.Add(' NOTES, STATIONS_TOTAL, STATIONS_DATABASE, STATIONS_DUPLICATES) ');
      SQL.Add(' VALUES ' );
      SQL.Add(' (:ID, :platform_id, :source_id, :institute_id, :project_id, ');
      SQL.Add(' :DATE_ADDED, :DATE_UPDATED, :DATE_START_TOTAL, :DATE_END_TOTAL, ');
      SQL.Add(' :DATE_START_DATABASE, :DATE_END_DATABASE, :CRUISE_NUMBER, :PI, ');
      SQL.Add(' :NOTES, :STATIONS_TOTAL, :STATIONS_DATABASE, :STATIONS_DUPLICATES) ');
      ParamByName('ID').Value:=ID;
      ParamByName('platform_id').Value:=ID;
      ParamByName('source_id').Value:=5;
      ParamByName('institute_id').Value:=institute_id;
      ParamByName('project_id').Value:=project_id;
      ParamByName('date_added').Value:=stdate_upd;
      ParamByName('date_updated').Value:=stdate_upd;
      ParamByName('date_start_total').Value:=stdate_upd;
      ParamByName('date_end_total').Value:=stdate_upd;
      ParamByName('date_start_database').Value:=stdate_upd;
      ParamByName('date_end_database').Value:=stdate_upd;
      ParamByName('cruise_number').Value:=platf;
      ParamByName('stations_total').Value:=0;
      ParamByName('stations_database').Value:=0;
      ParamByName('stations_duplicates').Value:=0;
      ParamByName('PI').Value:=pi;
      ParamByName('NOTES').Value:=notes_str;
     ExecSQL;
    end;
    inc(cnt_added);
     writeln(dat1, inttostr(ID));

    end else
     Memo1.lines.add('Missing codes -> '+inttostr(ID)); //-9
   end; // qt empty

  Qt1.Close;
  until eof(dat);


  (* removing any cruises which are not in the list any more *)
   with Qt1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM CRUISE ');
       SQL.Add(' WHERE ID BETWEEN 20000001 AND 30000000 ');
       SQL.Add(' ORDER BY ID ');
     Open;
   end;

   cnt_removed:=0;
   while not Qt1.EOF do begin
    if VarIsNull(ID_buf.Lookup('ID', Qt1.FieldByName('ID').asInteger,'ID')) then begin
      with Qt2 do begin
       Close;
        Sql.Clear;
        SQL.Add(' DELETE FROM CRUISE WHERE ID=:ID ');
        ParamByName('ID').Value:=Qt1.FieldByName('ID').asInteger;
       ExecSQL;
      end;

      with Qt2 do begin
       Close;
        Sql.Clear;
        SQL.Add(' DELETE FROM PLATFORM WHERE ID=:ID ');
        ParamByName('ID').Value:=Qt1.FieldByName('ID').asInteger;
       ExecSQL;
      end;
      Trt.CommitRetaining;

    inc(cnt_removed);
    writeln(dat3, inttostr(ID));
    end;
    Qt1.Next;
   end;
   Qt1.Close;


finally
   Trt.Commit;
   Qt1.Free;
   Qt2.Free;
   Trt.Free;
   ID_buf.Free;

   CloseFile(dat1);
   CloseFile(dat2);
   CloseFile(dat3);

   With memo1.lines do begin
     add('Added: '+inttostr(cnt_added));
     add('Updated: '+inttostr(cnt_updated));
     add('Removed: '+inttostr(cnt_removed));
     add('');
     add('Done! '+datetimetostr(Now));
   end;

   OpenDocument(PChar(log_path));
 end;
end;


(* Reading input metadata file *)
procedure Tfrmload_argo.UpdateSTATION(fname:string);
Type
  MDFromDatabase=record
    ID:integer;
    Cruise_ID:integer;
    StNum:string;
    Date_ins:TDateTime;
    Date_upd:TDateTime;
end;
MDDB=array of MDFromDatabase;

Var
  dat:text;
 // isCore:boolean;

  ID, c, k, max_id, pp:int64;
  cnt_str, cnt_kept, cnt_updated, cnt_new, cnt_skipped, cnt_error: int64;
  k_db, cc, par_cnt: int64;

  st, date_str, platf, buf_str, date_upd:string;
  cruise_id: integer;

  lat, lon:string;
  stlat, stlon:real;


  Qt2, Qt1:TSQLQuery;
  TRt:TSQLTransaction;

  stdate, stdate_upd_db, stdate_add_db, stdate_upd_f, max_date:TDateTime;
  stnum, tbl, log_path:string;
  cast, QF:integer;

  dat1, dat2, dat3, dat4, dat5:text;
  DateStart:TDateTime;

 QF_str: string;

 MDDB_arr: MDDB;
 ALength: Int64;
begin

 if not FileExists(epath.text+fname) then
   if MessageDlg(fname+' cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

  DateStart:=now;

  memo1.lines.add('');
  memo1.lines.add('Updating STATION from '+fname);
  memo1.lines.add('Start: '+datetimetostr(DateStart));
  memo1.lines.add('');

  try
     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qt1:=TSQLQuery.Create(self);
     Qt1.Database:=frmdm.IBDB;
     Qt1.Transaction:=TRt;

     Qt2:=TSQLQuery.Create(self);
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
      if max_id=0 then max_id:=20000000;

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

      k_db:=-1;
      while not Qt1.EOF do begin
       inc(k_db);
         MDDB_arr[k_db].ID:=Qt1.FieldByName('ID').asInteger;
         MDDB_arr[k_db].Cruise_ID:=Qt1.FieldByName('CRUISE_ID').asInteger;
         MDDB_arr[k_db].StNum:=Qt1.FieldByName('st_number_origin').asString;
         MDDB_arr[k_db].Date_ins:=Qt1.FieldByName('date_added').asDateTime;
         MDDB_arr[k_db].Date_upd:=Qt1.FieldByName('date_updated').asDateTime;
       Qt1.Next;
      end;
      Qt1.Close;

 // showmessage(inttostr(k_db));


  // path to log directory
  log_path:=epath.text+PathDelim+'_logs'+PathDelim;
    if not DirectoryExists(log_path) then CreateDir(log_path);

  // assigning log files
  AssignFile(dat1, log_path+'STATION_added.txt');   rewrite(dat1); // new sations
  AssignFile(dat2, log_path+'STATION_updated.txt'); rewrite(dat2); // updated
  AssignFile(dat3, log_path+'STATION_skipped_metadata.txt'); rewrite(dat3); // missing metadata - skipping
  AssignFile(dat4, log_path+'STATION_missing_file.txt'); rewrite(dat4); // missing initial files
  AssignFile(dat5, log_path+'STATION_insert_error.txt'); rewrite(dat5);

  // opening input file
  AssignFile(dat, epath.text+fname); reset(dat);

  // skipping the header
  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';

   for k:=1 to 74600 do readln(dat, st);

  // setting all counters to 0
  cnt_str:=0;
  cnt_kept:=0;
  cnt_updated:=0;
  cnt_new:=0;
  cnt_skipped:=0;
  cnt_error:=0;

  // reading input file string by string, filling up arrays
  repeat
   readln(dat, st);

 //  showmessage(st);

   inc(cnt_str);

   if cnt_str>1000 then exit;

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

   (* if data file is not found - skip it *)
   if FileExists(ePath.text+fname) then begin

   date_upd:=copy(st, length(st)-13, 14);

   // flags from the file name
   if copy(ExtractFileName(fname), 1, 1)='S' then
       QF_str:=copy(ExtractFileName(fname), 2, 1) else
       QF_str:=copy(ExtractFileName(fname), 1, 1);

   if QF_str='D' then QF:=4 else QF:=0;

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

 //  showmessage(stnum+'   '+copy(stnum, length(stnum), 1));

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

     //  showmessage(datetimetostr(stdate));

       ID:=0;
       if k_db>0 then begin
        For cc:=0 to k_db do begin
         if (MDDB_arr[cc].Cruise_ID=cruise_id) and
            (MDDB_arr[cc].StNum=stnum) then begin

           ID:=MDDB_arr[cc].ID;
           stdate_upd_db:=MDDB_arr[cc].Date_upd;
           stdate_add_db:=MDDB_arr[cc].Date_ins;


           ALength := Length(MDDB_arr);
           if (ALength > 1) then begin
            for k:=cc+1 to ALength-1 do MDDB_arr[k-1]:=MDDB_arr[k];
             SetLength(MDDB_arr, ALength-1);
           end;
         break;
        end;
       end;
     end;
    // showmessage(inttostr(id));


      (* station is in the database *)
      if ID>0 then begin

        if stdate_upd_db>=stdate_upd_f then begin
         inc(cnt_kept);
        end;

        if stdate_upd_db<stdate_upd_f then begin
         inc(cnt_updated);
         // removing old station
          with Qt2 do begin
           Close;
            SQL.Clear;
            SQL.Add(' DELETE FROM STATION ');
            SQL.Add(' where ID=:ID ');
            ParamByName('ID').Value:=ID;
           ExecSQL;
          end;
         TRt.Commit;

         (* writing metadata into STATION *)
         WriteMetadata(id, cruise_id, StLat, StLon, StDate,
                       stdate_add_db, stdate_upd_f, stnum,
                       cast, QF);

         (* writing updated profiles *)
          WriteProfile(ePath.text+fname, id);


         writeln(dat2, inttostr(id)+#9+fname);
         flush(dat2);
        end;
       end;

      (* new station *)
      if ID=0 then begin
       inc(cnt_new);
       inc(max_id);

       try
        WriteMetadata(max_id, cruise_id, StLat, StLon, StDate,
                      stdate_upd_f, stdate_upd_f, stnum,
                      cast, QF);

        WriteProfile(ePath.text+fname, max_id);

        writeln(dat1, inttostr(max_id)+#9+fname);
        flush(dat1);
       except
        inc(cnt_error);
        writeln(dat5, st);
        flush(dat5);
       end;
      end; //ID=0 -> writing a new station

     end; //coordinates -90 - 90; -180 - 180
    end else begin // if some inportant metadata is missing -> skipping
    inc(cnt_skipped);
    writeln(dat3, st);
    flush(dat3);
    end;

  end else begin
   writeln(dat4, fname); // file doesn't exist
   flush(dat4);
  end;

  until eof(dat);

  finally
     Trt.Commit;
     Qt1.Free;
     Qt2.Free;
     Trt.Free;

     CloseFile(dat1);
     CloseFile(dat2);
     CloseFile(dat3);
     CloseFile(dat4);
     CloseFile(dat5);

     with memo1.Lines do begin
       add('Unchanged: '+inttostr(cnt_kept));
       add('Updated: '  +inttostr(cnt_updated));
       add('Added: '    +inttostr(cnt_new));
       add('Skipped: '  +inttostr(cnt_skipped));
       add('Insert error: '+inttostr(cnt_error));
       add('');
       add('Done: '+DateTimeToStr(Now));
     end;

   OpenDocument(PChar(log_path));
  end;
end;


procedure Tfrmload_argo.WriteMetadata(ID, cruise_id: integer; StLat, StLon: real;
      StDate, stdate_add_db, stdate_upd_f:TDateTime; stnum:string;
      cast, QF:smallint);
Var
  Qt:TSQLQuery;
  TRt:TSQLTransaction;
begin

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt:=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;
 try
  with Qt do begin
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
    ParamByName('ID').Value:=id;
    ParamByName('latitude').Value:=StLat;
    ParamByName('longitude').Value:=StLon;
    ParamByName('dateandtime').Value:=StDate;
    ParamByName('cruise_id').Value:=cruise_id;
    ParamByName('st_number_origin').Value:=stnum;
    ParamByName('date_added').Value:=stdate_add_db;
    ParamByName('date_updated').Value:=stdate_upd_f;
    ParamByName('cast_number').Value:=cast;
    ParamByName('QCFLAG').Value:=QF;
   ExecSQL;
  end;
   Trt.Commit;
 except
   Trt.Rollback;
 end;
end;


procedure Tfrmload_argo.WriteProfile(fname:string; id: integer);
Var
 ncid, varidp, ll, k, c, units_id, k_prof, k_par, QF: integer;
 precision: integer;
 var_name, tbl, QF_str: string;
 n_prof, n_levels, n_param: size_t;
 ip: array of single;
 ff: array of PAnsiChar;
 dd: array of double;

 start: PArraySize_t;
 pres_QF, val_QF, QF_ll, pres_tbl: String;

 limit_min, limit_max, stlat:double;
 val1, lev_m, pres: double;
 isCore, isBest: boolean;
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
begin
 try
   TRt:=TSQLTransaction.Create(nil);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(nil);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

  // opening NC file
  nc_open(pansichar(AnsiString(fname)), NC_NOWRITE, ncid); // only for reading


  // Core or synthetic?
  nc_inq_varid (ncid, pAnsiChar('DATA_TYPE'), varidp);
  SetLength(ff, 16);
  nc_get_var_text(ncid, varidp, ff);
    if trim(pchar(ff))='Argo profile' then isCore:=true else isCore:=false;

  // getting number of profiles
  nc_inq_dimid (ncid, pAnsiChar('N_PROF'), varidp);
  nc_inq_dimlen(ncid, varidp, n_prof);

  // geting number of parameters
  nc_inq_dimid (ncid, pAnsiChar('N_PARAM'), varidp);
  nc_inq_dimlen(ncid, varidp, n_param);

  // getting number of levels
  nc_inq_dimid (ncid, pAnsiChar('N_LEVELS'), varidp);
  nc_inq_dimlen(ncid, varidp, n_levels);

//  if n_prof>1 then memo1.lines.add(inttostr(n_prof)+'   '+fname);

  (* Loop over profiles *)
  For k_prof:=0 to n_prof-1 do begin

   if k_prof=0 then isbest:=true else isBest:=false;

    // getting latitude
    nc_inq_varid (ncid, pAnsiChar('LATITUDE'), varidp);
    start:=GetMemory(SizeOf(TArraySize_t)*n_prof);
     start^[0]:=k_prof;
     SetLength(dd, 1);
      nc_get_var1_double(ncid, varidp, start^, dd);
      StLat:=dd[0];
    FreeMemory(start);

    // if Core file
    if IsCore=true then begin
      nc_inq_varid (ncid, pAnsiChar('DATA_MODE'), varidp);
      start:=GetMemory(SizeOf(TArraySize_t)*n_prof);
       start^[0]:=k_prof;
       setlength(ff, 0);
       setlength(ff, 1);
       nc_get_var1_text(ncid, varidp, start^, ff);
       QF_str:=pchar(ff);
      FreeMemory(start);
    end;

    (* Loop for parameters *)
    for k_par:=1 to n_param-1 do begin  // skipping PRES (k_par=0)

     // if synthetic
      if isCore=false then begin
       nc_inq_varid (ncid, pAnsiChar('PARAMETER_DATA_MODE'), varidp);
        start:=GetMemory(SizeOf(TArraySize_t)*n_prof*n_param);
         start^[0]:=k_prof;
         start^[1]:=k_par;
         setlength(ff, 0);
         setlength(ff, 1);
         nc_get_var1_text(ncid, varidp, start^, ff);
          QF_str:=trim(pchar(ff));
         // showmessage(qf_str);
        FreeMemory(start);
      end;

     // getting parameter names
     nc_inq_varid (ncid, pAnsiChar('STATION_PARAMETERS'), varidp);
     start:=GetMemory(SizeOf(TArraySize_t)*n_prof*n_param);
      start^[0]:=k_prof;
      start^[1]:=k_par;
      var_name:='';
      for c:=0 to 63 do begin
        start^[2]:=c;
        SetLength(ff, 0);
        SetLength(ff, 1);
         nc_get_var1_text(ncid, varidp, start^, ff);
         var_name:=var_name+pChar(ff);
      end;
      var_name:=trim(var_name);
     FreeMemory(start);

     tbl:='';
     if var_name='TEMP' then begin
       units_id:=1;
       limit_min:=-2.5;
       limit_max:=40;
       precision:=-3; //0.001
     end;
     if var_name='PSAL' then begin
       units_id:=2;
       limit_min:=2;
       limit_max:=41;
       precision:=-3; //0.001
     end;
     if var_name='DOXY' then begin
       units_id:=3;
       limit_min:=5;
       limit_max:=600;
       precision:=-3; //0.001
     end;
     if var_name='CDOM' then begin
       units_id:=24;
       limit_min:=-99999;
       limit_max:= 99999;
       precision:=-3; //0.001
     end;
     if var_name='CHLA' then begin
       units_id:=9;
       limit_min:=-99999;
       limit_max:= 99999;
       precision:=-3; //0.025
     end;
     if var_name='NITRATE' then begin
       units_id:=3;
       limit_min:=-99999;
       limit_max:= 99999;
       precision:=-2; //0.01
     end;

     if var_name='TURBIDITY' then begin
       units_id:=25;
       limit_min:=-99999;
       limit_max:= 99999;
       precision:=-3; //0.001
     end;
     if var_name='PH_IN_SITU_TOTAL' then begin
       units_id:=2;
       limit_min:=-99999;
       limit_max:= 99999;
       precision:=-4; //0.0001
     end;
     if var_name='BISULFIDE' then begin
       units_id:=3;
       limit_min:=-99999;
       limit_max:= 99999;
       precision:=-3; //0.001
     end;
     if var_name='DOWNWELLING_PAR' then begin
       units_id:=23;
       limit_min:=-99999;
       limit_max:= 99999;
       precision:=-3; //0.001
     end;


     GetTableName(var_name, tbl);


     if (QF_str='A') or (QF_str='D') then begin
        var_name:=var_name+'_ADJUSTED';
        pres_tbl:='PRES_ADJUSTED';
     end else pres_tbl:='PRES';

    // showmessage(fname+'   '+Var_name+'   '+tbl);

     if tbl<>'' then begin

      start:=GetMemory(SizeOf(TArraySize_t)*n_prof*n_levels);
      start^[0]:=k_prof;

      (* Loop over levels *)
      for ll:=0 to n_levels-1 do begin
        start^[1]:=ll;

        //pressure
        nc_inq_varid(ncid, pAnsiChar(AnsiString(pres_tbl)), varidp);
        SetLength(ip, 1);
        nc_get_var1_float(ncid, varidp, start^, ip);
        if not VarIsNull(ip[0]) then pres:=ip[0] else pres:=-9999;
        if (pres<0) or (pres>12000) then pres:=-9999;

        nc_inq_varid(ncid, pAnsiChar(AnsiString(var_name)), varidp);
        SetLength(ip, 1);
        nc_get_var1_float(ncid, varidp, start^, ip);
        if not VarIsNull(ip[0]) then val1:=ip[0] else val1:=-9999;

        nc_inq_varid(ncid, pAnsiChar(AnsiString(var_name+'_QC')), varidp);
        SetLength(ff, 0);
        SetLength(ff, 1);
        nc_get_var1_text(ncid, varidp, start^, ff);
        val_QF:=PChar(ff);

        if (val1=99999) or
           (val1<limit_min) or
           (val1>limit_max) or
           (trim(val_QF)='') then val1:=-9999;

       if (pres<>-9999) and (val1<>-9999) then begin
         lev_m:=-gibbsseawater.gsw_z_from_p(pres, stlat, 0, 0);

        // ARGO QF to Ocean.fdb QF
         QFMapping(StrToInt(val_QF), QF);

     {   memo1.Lines.Add(floattostr(pres)+'   '+
                        floattostr(val1)+'   '+
                        inttostr(QF));  }

         with Qt do begin
          Close;
           SQL.Clear;
           SQL.Add(' insert into ');
           SQL.Add(tbl);
           SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF1, PQF2, SQF, UNITS_ID, ');
           SQL.Add('  INSTRUMENT_ID, PROFILE_NUMBER, PROFILE_BEST) ');
           SQL.Add(' values ');
           SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF1, :PQF2, :SQF, :UNITS_ID, ');
           SQL.Add('  :INSTRUMENT_ID, :PROFILE_NUMBER, :PROFILE_BEST) ');
           ParamByName('ID').AsInteger:=id;
           ParamByName('LEV_DBAR').AsFloat:=roundto(pres, -1);
           ParamByName('LEV_M').AsFloat:=roundto(lev_m, -1);
           ParamByName('VAL').AsFloat:=roundto(val1, precision);
           ParamByName('PQF1').AsInteger:=QF;
           ParamByName('PQF2').AsInteger:=QF;
           ParamByName('SQF').AsInteger:=0;
           ParamByName('UNITS_ID').AsInteger:=units_id;
           ParamByName('INSTRUMENT_ID').AsInteger:=11;
           ParamByName('PROFILE_NUMBER').AsInteger:=k_prof+1;
           ParamByName('PROFILE_BEST').AsBoolean:=isBest;
          ExecSQL;
         end;
       end;// not -9999
       ip:=nil;
       ff:=nil;
     end; // loop ovel levels
     FreeMemory(start);

   end; // tbl<>''
  end; // loop over tables
 end; // loop over n_prof

 finally
  nc_close(ncid);

  Trt.Commit;
  Qt.Free;
  TrT.Free;
 end;
end;


procedure Tfrmload_argo.GreyList;
var
 dat, dat1:text;
 fname, buf_str, st, log_path: string;
 cruise_id, QF, argo_QF, c, k: integer;
 var_name, tbl_name: string;
 DateStart, date_beg, date_end:TDateTime;
 yy, mn, dd: word;
begin
 fname:='ar_greylist.txt';
 if not FileExists(epath.text+fname) then
   if MessageDlg(fname+' cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

  DateStart:=now;

  memo1.lines.add('');
  memo1.lines.add('Processing "grey" list ');
  memo1.lines.add('Start: '+datetimetostr(DateStart));
  memo1.lines.add('');

  AssignFile(dat, epath.text+fname); reset(dat);
  readln(dat);

  log_path:=epath.text+PathDelim+'_Logs'+PathDelim;
   if not DirectoryExists(log_path) then CreateDir(log_path);

  AssignFile(dat1, log_path+'GreyList_progress.txt'); rewrite(dat1);

  repeat
   readln(dat, st);

   c:=0;
   for k:=1 to 5 do begin
    buf_str:='';
     repeat
      inc(c);
      if st[c]<>',' then buf_str:=buf_str+st[c];
     until (st[c]=',') or (c=length(st));
      case k of
       1: cruise_ID:=20000000+strtoint(buf_str);
       2: var_name:=trim(buf_str);
       3: begin
           yy:=StrToInt(copy(buf_str, 1, 4));
           mn:=StrToInt(copy(buf_str, 5, 2));
           dd:=StrToInt(copy(buf_str, 7, 2));
           date_beg:=EncodeDate(yy, mn, dd);
       end;
       4: begin
           if trim(buf_str)<>'' then begin
            yy:=StrToInt(copy(buf_str, 1, 4));
            mn:=StrToInt(copy(buf_str, 5, 2));
            dd:=StrToInt(copy(buf_str, 7, 2));
            date_end:=EncodeDate(yy, mn, dd)
           end else
            date_end:=EncodeDate(9999,01,01);
       end;
       5: argo_qf:=strtoint(buf_str);
      end;
   end;

   QFMapping(argo_QF, QF);

   if QF>0 then begin
     if (var_name<>'PRES') then begin
       GetTableName(var_name, tbl_name);
       if (tbl_name<>'') then begin
         GreyListUpdateTable(cruise_id, QF, tbl_name, date_beg, date_end);

         writeln(dat1, inttostr(cruise_id)+'   '+
                       var_name+'   '+
                       datetostr(date_beg)+'   '+
                       datetostr(date_end));
         flush(dat1);
       end else
         writeln(dat1, 'Error: '+st);
     end;

     if (var_name='PRES') then begin
       for k:=0 to frmosmain.ListBox1.Count-1 do begin
         tbl_name:=frmosmain.ListBox1.Items.Strings[k];
         GreyListUpdateTable(cruise_id, QF, tbl_name, date_beg, date_end);
       end;
        writeln(dat1, inttostr(cruise_id)+'   '+
                       var_name+'   '+
                       datetostr(date_beg)+'   '+
                       datetostr(date_end));
         flush(dat1);
     end;
   end;  //QF>0

  until eof(dat);
  CloseFile(dat);
  CloseFile(dat1);

  with memo1.Lines do begin
    add('');
    add('Done: '+DateTimeToStr(Now));
  end;
end;


procedure Tfrmload_argo.GreyListUpdateTable(cruise_id, QF:integer;
      tbl_name:string; dd1, dd2:tDateTime);
Var
  TRt:TSQLTransaction;
  Qt, Qt1:TSQLQuery;
begin
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt:=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

  Qt1:=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

 {  showmessage(inttostr(cruise_id)+'    '+
        datetostr(dd1)+'   '+datetostr(dd2)+
        tbl_name+'   '+inttostr(qf)); }

  try
   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT ID FROM STATION WHERE ');
     SQL.Add(' DATEANDTIME BETWEEN :dd1 AND :dd2 AND ');
     SQL.Add(' CRUISE_ID=:cr_ID ');
     ParamByName('cr_id').Value:=cruise_id;
     ParamByName('dd1').Value:=dd1;
     ParamByName('dd2').Value:=dd2;
    Open;
   end;

   while not Qt.EOF do begin
    with Qt1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' UPDATE '+tbl_name);
      SQL.Add(' SET PQF1=:QF, PQF2=:QF ');
      SQL.Add(' WHERE ID=:ID AND PQF1<>QF ');
      ParamByName('ID').Value:=Qt.Fields[0].Value;
      ParamByName('QF').Value:=QF;
     ExecSQL;
    end;
    Qt.Next;
   end;

   Trt.Commit;
  except
    Trt.Rollback;
  end;
  Qt.Free;
  Trt.Free;
end;



procedure Tfrmload_argo.DeleteEmptyStations;
Var
 Qt1, Qt2:TSQLQuery;
 TRt:TSQLTransaction;

 log_path:string;
 k, cnt, cnt_t, cnt_s, cnt_o, cnt_del:integer;
 dat: text;

 DateStart: TDateTime;
begin
Memo1.Clear;

  DateStart:=now;

  memo1.lines.add('');
  memo1.lines.add('Removing empty stations');
  memo1.lines.add('Start: '+timetostr(DateStart));
  memo1.lines.add('');

   log_path:=epath.text+PathDelim+'_logs'+PathDelim;
    if not DirectoryExists(log_path) then CreateDir(log_path);

   AssignFile(dat, log_path+'Empty.txt');   rewrite(dat);

 try
    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;

    Qt1:=TSQLQuery.Create(self);
    Qt1.Database:=frmdm.IBDB;
    Qt1.Transaction:=TRt;

    Qt2:=TSQLQuery.Create(self);
    Qt2.Database:=frmdm.IBDB;
    Qt2.Transaction:=TRt;

     with Qt1 do begin
      Close;
       SQL.Clear;
       SQL.Add('SELECT ID FROM STATION WHERE ID>20000001 and ID<30000000 ORDER BY ID ');
      Open;
      Last;
      First;
     end;

     cnt:=Qt1.RecordCount;
     k:=0;
     cnt_del:=0;
     while not Qt1.EOF do begin

     with Qt2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT count(ID) FROM P_TEMPERATURE ');
        SQL.Add(' WHERE ID=:ID ');
        ParamByName('ID').AsInteger:=Qt1.FieldByName('ID').AsInteger;
       Open;
        cnt_t:=Qt2.Fields[0].Value;
       Close;
      end;

      with Qt2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT count(ID) FROM P_SALINITY ');
        SQL.Add(' WHERE ID=:ID ');
        ParamByName('ID').AsInteger:=Qt1.FieldByName('ID').AsInteger;
       Open;
        cnt_s:=Qt2.Fields[0].Value;
       Close;
      end;

      with Qt2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT count(ID) FROM P_OXYGEN ');
        SQL.Add(' WHERE ID=:ID ');
        ParamByName('ID').AsInteger:=Qt1.FieldByName('ID').AsInteger;
       Open;
        cnt_o:=Qt2.Fields[0].Value;
       Close;
      end;

      if (cnt_t=0) and (cnt_s=0) and (cnt_o=0) then begin
       with Qt2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' DELETE FROM STATION ');
         SQL.Add(' WHERE ID=:ID ');
         ParamByName('ID').AsInteger:=Qt1.FieldByName('ID').AsInteger;
        ExecSQL;
       end;

       inc(cnt_del);
       writeln(dat, Qt1.FieldByName('ID').AsInteger);
      end;

      inc(k);
      {$IFDEF WINDOWS}
        Procedures.ProgressTaskbar(k, cnt);
      {$ENDIF}

      Qt1.Next;
     end;
     Closefile(dat);

     with memo1.Lines do begin
       add('Removed: '  +inttostr(cnt_del));
       add('');
       add('Done! Time spent: '+timetostr(now-DateStart));
     end;
    OpenDocument(PChar(log_path+'Empty.txt'));

 finally
  Trt.Commit;
  Qt1.Free;
  Qt2.Free;
  Trt.Free;
 end;
end;

procedure Tfrmload_argo.UpdateCruiseInfo;
Var
 DateStart: TDateTime;
 fpath, fname: string;
 k, cnt: integer;
 dat:text;
 ID: int64;
begin
 DateStart:=now;

 memo1.lines.add('');
 memo1.lines.add('Updating CRUISE info');
 memo1.lines.add('Start: '+DateTimeToStr(DateStart));
 memo1.lines.add('');

 fpath:=ePath.Text+'_logs'+PathDelim;
 cnt:=0;
 for k:=1 to 2 do begin
  if k=1 then fname:='CRUISE_added.txt';
  if k=2 then fname:='CRUISE_updated.txt';

  if FileExists(fpath+fname) then begin
    AssignFile(dat, fpath+fname); reset(dat);
    while not eof(dat) do begin
     readln(dat, ID);
     frmosmain.UpdateCruiseInfo(ID, true);
     inc(cnt);
    end;
    Closefile(dat);
  end;
 end;

 memo1.Lines.add('Updated '+inttostr(cnt)+' cruises');
 memo1.Lines.add('');
 memo1.Lines.add('Done: '+DateTimeToStr(Now));
end;



procedure Tfrmload_argo.InsertLastLevel;
Var
 DateStart: TDateTime;
begin
 DateStart:=now;

 memo1.lines.add('');
 memo1.lines.add('Instering last level');
 memo1.lines.add('Start: '+DateTimeToStr(DateStart));
 memo1.lines.add('');

   frmosmain.InsertLastLevel;

 memo1.Lines.add('');
 memo1.Lines.add('Done: '+DateTimeToStr(Now));
end;


procedure Tfrmload_argo.InsertGEBCODepth;
Var
 DateStart: TDateTime;
begin
 DateStart:=now;

 memo1.lines.add('');
 memo1.lines.add('Instering bottom depth from GEBCO');
 memo1.lines.add('Start: '+DateTimeToStr(DateStart));
 memo1.lines.add('');

   frmosmain.InsertGEBCODepth;

 memo1.Lines.add('');
 memo1.Lines.add('Done: '+DateTimeToStr(Now));
end;


procedure Tfrmload_argo.GetTableName(var_name:string; Var tbl_name: string);
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
  if var_name='DOWNWELLING_PAR'  then tbl_name:='P_PAR';
end;


procedure Tfrmload_argo.GetCodes(argo_code:string; Var country_id, institute_id, project_id:integer);
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
 if argo_code='KM' then begin institute_id:=125; project_id:=447; country_id:=179; end;
 if argo_code='KO' then begin institute_id:=124; project_id:=447; country_id:=179; end;
 if argo_code='ME' then begin institute_id:=822; project_id:=61;  country_id:=173; end;
 if argo_code='NM' then begin institute_id:=823; project_id:=69;  country_id:=231; end;
end;


procedure Tfrmload_argo.QFMapping(argo_QF:integer; var QF:integer);
begin
  QF:=0;
   case argo_QF of
     0: QF:=0;
     1: QF:=4;
     2: QF:=2;
     3: QF:=1;
     4: QF:=1;
     5: QF:=3;
     8: QF:=3;
   end;
end;


procedure Tfrmload_argo.FormClose(Sender: TObject; var CloseAction: TCloseAction);
Var
 Ini:TIniFile;
begin
    Ini := TIniFile.Create(IniFileName);
   try
     Ini.WriteString('osload_argo', 'data_path', ePath.Text);
   finally
     Ini.Free;
   end;
end;

end.

