unit osload_argo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SQLDB, DB,
  DateUtils, Variants, BufDataset, LCLIntf, Buttons;

type

  { Tfrmload_argo }

  Tfrmload_argo = class(TForm)
    btnCruise: TButton;
    btnSynthetic: TButton;
    btnCore: TButton;
    Button1: TButton;
    ePath: TEdit;
    Label4: TLabel;
    Memo1: TMemo;

    procedure btnCoreClick(Sender: TObject);
    procedure btnCruiseClick(Sender: TObject);
    procedure btnSyntheticClick(Sender: TObject);

  private
    procedure GetCodes(argo_code:string; Var country_id, institute_id,
      project_id:integer);
    procedure ReadMetadata(fname:string; isCore:boolean);
    procedure WriteProfile(fname:string; id: integer; StLat: real;
      isCore:boolean; QF: integer);
  public

  end;

var
  frmload_argo: Tfrmload_argo;

implementation

{$R *.lfm}

{ Tfrmload_argo }

uses osmain, dm, declarations_netcdf, GibbsSeaWater;


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



(* reading ar_index_global_meta.txt and updating CRUISE *)
procedure Tfrmload_argo.btnCruiseClick(Sender: TObject);
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
  memo1.Clear;
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


   Memo1.lines.add('Added: '+inttostr(cnt_added));
   Memo1.lines.add('Updated: '+inttostr(cnt_updated));
   Memo1.lines.add('Removed: '+inttostr(cnt_removed));
   Memo1.lines.add('');

   memo1.lines.add('Done! Time spent: '+timetostr(now-DateStart));

   OpenDocument(PChar(log_path));
 end;
end;

procedure Tfrmload_argo.btnSyntheticClick(Sender: TObject);
Var
  fname:string;
begin
fname:='argo_synthetic-profile_index.txt';
 if not FileExists(epath.text+fname) then
   if MessageDlg(fname+' cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

  ReadMetadata(epath.text+fname, false);
end;

procedure Tfrmload_argo.btnCoreClick(Sender: TObject);
Var
  fname: string;
begin
fname:='ar_index_global_prof.txt';
 if not FileExists(epath.text+fname) then
   if MessageDlg(fname+' cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

  ReadMetadata(epath.text+fname, true);
end;


(* Reading input metadata file *)
procedure Tfrmload_argo.ReadMetadata(fname:string; isCore:boolean);
Type
  MDFromDatabase=record
    ID:integer;
    Cruise_ID:integer;
    StNum:string;
    Date_upd:TDateTime;
  end;

  MDDB=array of MDFromDatabase;
Var
  dat:text;
  ID, c, k, max_id, pp:integer;
  cnt_str, cnt_kept, cnt_updated, cnt_new, cnt_skipped: integer;
  k_db, cc, par_cnt: integer;

  st, date_str, platf, buf_str, date_upd:string;
  cruise_id: integer;

  lat, lon:string;
  stlat, stlon:real;


  Qt2, Qt1:TSQLQuery;
  TRt:TSQLTransaction;

  stdate, stdate_upd_db, stdate_upd_f, max_date:TDateTime;
  stnum, tbl, log_path:string;
  cast, QF:integer;

  dat1, dat2, dat3, dat4:text;
  DateStart:TDateTime;


 ff: array of PAnsiChar;
 lenp: size_t;
 QF_str: string;

 id_db_arr, cr_id_arr:array of integer;
 st_num_arr:array of string;
 d_upd_arr: array of TDateTime;

 MDDB_arr: MDDB;
 ALength: Cardinal;

//id_db_arr, cr_id_arr, st_num_arr, d_upd_arr: TStringList;

begin


DateStart:=now;
memo1.Clear;
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
        SQL.Add(' select id, cruise_id, st_number_origin, date_updated from station ');
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
         MDDB_arr[k_db].Date_upd:=Qt1.FieldByName('date_updated').asDateTime;
       Qt1.Next;
      end;
      Qt1.Close;

 // showmessage(inttostr(k_db));


  log_path:=epath.text+PathDelim+'_Logs'+PathDelim;
    if not DirectoryExists(log_path) then CreateDir(log_path);

  AssignFile(dat1, log_path+'STATION_added.txt');   rewrite(dat1);
  AssignFile(dat2, log_path+'STATION_updated.txt'); rewrite(dat2);
  AssignFile(dat3, log_path+'STATION_skipped.txt'); rewrite(dat3);
  AssignFile(dat4, log_path+'STATION_file_missing.txt'); rewrite(dat4);

  // opening input file
  AssignFile(dat, fname); reset(dat);

  // skipping the header
  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';

//  for k:=1 to 143960 do readln(dat, st);

  // setting counters to 0
  cnt_str:=0; cnt_kept:=0; cnt_updated:=0; cnt_new:=0; cnt_skipped:=0;

  // reading input file string by string, filling up arrays
  repeat
   readln(dat, st);

   inc(cnt_str);

  // if cnt_str>=1000 then exit;

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
   if not FileExists(ePath.text+fname) then begin
     writeln(dat4, fname);
     exit;
   end;

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
  // showmessage(stnum+'   '+copy(stnum, length(stnum), 1));

   if copy(stnum, length(stnum), 1)='D' then begin
     stnum:=copy(stnum,1, length(stnum)-1);
     stnum:=IntToStr(StrToInt(stnum))+'D';
   end else
     stnum:=IntToStr(StrToInt(stnum));

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

       ID:=0;
       if k_db>0 then begin
        For cc:=0 to k_db do begin
         if (MDDB_arr[cc].Cruise_ID=cruise_id) and
            (MDDB_arr[cc].StNum=stnum) then begin

           ID:=MDDB_arr[cc].ID;
           stdate_upd_db:=MDDB_arr[cc].Date_upd;


           ALength := Length(MDDB_arr);
           if (ALength > 1) then begin
            for k:=cc+1 to ALength-1 do MDDB_arr[k-1]:=MDDB_arr[k];
             SetLength(MDDB_arr, ALength-1);
           end;
         break;
        end;
       end;
     end;
   //  showmessage(inttostr(id));


      (* station is in the database *)
      if ID>0 then begin

        if stdate_upd_db>=stdate_upd_f then begin
         inc(cnt_kept);
        end;

        if stdate_upd_db<stdate_upd_f then begin
         inc(cnt_updated);

          with Qt2 do begin
           Close;
            SQL.Clear;
            SQL.Add(' UPDATE STATION SET ');
            SQL.Add(' LATITUDE=:lat, ');
            SQL.Add(' LONGITUDE=:lon, ');
            SQL.Add(' DATEANDTIME=:date1, ');
            SQL.Add(' QCFLAG=:QF, ');
            SQL.Add(' DATE_UPDATED=:date_upd ');
            SQL.Add(' where ID=:ID ');
            ParamByName('Lat').Value:=stlat;
            ParamByName('Lon').Value:=stlon;
            ParamByName('date1').Value:=stdate;
            ParamByName('QF').Value:=QF;
            ParamByName('date_upd').Value:=stdate_upd_f;
            ParamByName('ID').Value:=ID;
           ExecSQL;
          end;

          (* removing old profiles *)
         if isCore then par_cnt:=2 else par_cnt:=3;

         for pp:=1 to par_cnt-1 do begin
          case pp of
           1: tbl:='P_TEMPERATURE';
           2: tbl:='P_SALINITY';
           3: tbl:='P_OXYGEN';
          end;

          with Qt2 do begin
           Close;
            SQL.Clear;
            SQL.Add(' DELETE FROM '+tbl);
            SQL.Add(' where ID=:ID ');
            ParamByName('ID').Value:=ID;
           ExecSQL;
         end;
         TRt.CommitRetaining;
         end;


         (* writing updated profiles *)
          WriteProfile(ePath.text+fname, id, StLat, isCore, QF);


         writeln(dat2, inttostr(id)+#9+platf+'_'+stnum);
        end;
       end;

      (* new station *)
      if ID=0 then begin
       inc(cnt_new);
       inc(max_id);

       if copy(stnum, length(stnum), 1)='D' then cast:=2 else cast:=1;

       try
        with Qt2 do begin
         Close;
          Sql.Clear;
          SQL.Add(' insert into STATION ');
          SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ');
          SQL.Add(' ST_NUMBER_ORIGIN, DATE_ADDED, DATE_UPDATED, ');
          SQL.Add(' CAST_NUMBER, QCFLAG)');
          SQL.Add(' VALUES ');
          SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ');
          SQL.Add(' :ST_NUMBER_ORIGIN, :DATE_ADDED, :DATE_UPDATED, ');
          SQL.Add(' :CAST_NUMBER, :QCFLAG)');
          ParamByName('ID').Value:=max_id;
          ParamByName('latitude').Value:=StLat;
          ParamByName('longitude').Value:=StLon;
          ParamByName('dateandtime').Value:=StDate;
          ParamByName('cruise_id').Value:=cruise_id;
          ParamByName('st_number_origin').Value:=stnum;
          ParamByName('date_added').Value:=stdate_upd_f;
          ParamByName('date_updated').Value:=stdate_upd_f;
          ParamByName('cast_number').Value:=cast;
          ParamByName('QCFLAG').Value:=QF;
         ExecSQL;
        end;
        Trt.CommitRetaining;

        WriteProfile(ePath.text+fname, max_id, StLat, isCore, QF);

        writeln(dat1, inttostr(max_id)+#9+platf+'_'+stnum);
       except
         Trt.RollbackRetaining;
         memo1.Lines.add(st);
       end;
      end; //ID=0 -> writing a new station


    end; //coordinates -90 - 90; -180 - 180
  end else begin // if some inportant metadata is missing -> skipping
    inc(cnt_skipped);
    writeln(dat3, st);
    flush(dat3);
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

     with memo1.Lines do begin
       add('Unchanged: '+inttostr(cnt_kept));
       add('Updated: '  +inttostr(cnt_updated));
       add('Added: '    +inttostr(cnt_new));
       add('Skipped: '  +inttostr(cnt_skipped));
       add('');
       add('Done! Time spent: '+timetostr(now-DateStart));
     end;

   OpenDocument(PChar(log_path));
  end;
end;


procedure Tfrmload_argo.WriteProfile(fname:string; id: integer; StLat: real;
  isCore:boolean; QF: integer);
Var
 k, ncid, varidp, pp, ll, par, prof_fl, units_id, par_cnt: integer;
 var_name, tbl: string;
 n_prof, n_levels, n_param: size_t;
 vtype: nc_type; //nc_inq_var
 ip: array of single;
 pres_arr, temp_arr, sal_arr, oxy_arr:array of single;
 val1, lev_m: real;


 ff: array of PAnsiChar;
 lenp: size_t;
 QF_str, par_str: string;
 TRt:TSQLTransaction;
 Qt:TSQLQuery;

begin
 try
   TRt:=TSQLTransaction.Create(nil);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(nil);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

  nc_open(pansichar(AnsiString(fname)), NC_NOWRITE, ncid); // only for reading

  nc_inq_dimid (ncid, pAnsiChar('N_PROF'), varidp);
  nc_inq_dimlen(ncid, varidp, n_prof);

  (* if data file has more than 1 profile - skip it *)
  if n_prof>1 then begin
    Memo1.lines.add(inttostr(n_prof)+'   '+fname);
    exit;
  end;

  nc_inq_dimid (ncid, pAnsiChar('N_PARAM'), varidp);
  nc_inq_dimlen(ncid, varidp, n_param);


  nc_inq_dimid (ncid, pAnsiChar('N_LEVELS'), varidp);
  nc_inq_dimlen(ncid, varidp, n_levels);

  (* !!! just pres, temp, dsal, doxy!!! *)
  QF_str:='';
  if n_param>4 then begin
    n_param:=4;
    nc_inq_varid (ncid, pAnsiChar('PARAMETER_DATA_MODE'), varidp);
    SetLength(ff, (n_prof*n_param));
    nc_get_var_text(ncid, varidp, ff);
    QF_str:=trim(pchar(ff));
  end;

  SetLength(pres_arr, n_levels);
  SetLength(temp_arr, n_levels);
  SetLength(sal_arr,  n_levels);
  SetLength(oxy_arr,  n_levels);


  for par:=1 to n_param do begin
     case par of
      1: begin
         var_name:='PRES';
      end;
      2: begin
         var_name:='TEMP';
         if trim(QF_str)<>'' then
          if (copy(QF_str, 2, 1)='D') or
             (copy(QF_str, 2, 1)='A') then QF:=4 else QF:=0;
      end;
      3: begin
         var_name:='PSAL';
         if trim(QF_str)<>'' then
          if (copy(QF_str, 3, 1)='D') or
             (copy(QF_str, 3, 1)='A') then QF:=4 else QF:=0;
      end;
      4: begin
         var_name:='DOXY';
         if trim(QF_str)<>'' then
          if (copy(QF_str, 4, 1)='D') or
             (copy(QF_str, 4, 1)='A') then QF:=4 else QF:=0;
      end;
     end; //eof case


     if QF=4 then var_name:=var_name+'_ADJUSTED';

     nc_inq_varid(ncid, pAnsiChar(AnsiString(var_name)), varidp);
     SetLength(ip, n_levels);
     nc_get_var_float(ncid, varidp, ip);

     case par of
      1: pres_arr:=ip;
      2: temp_arr:=ip;
      3: sal_arr:=ip;
      4: oxy_arr:=ip;
     end;
   ip:=nil;
  end;


  for ll:=0 to n_levels-1 do begin
  { showmessage(floattostr(pres_arr[ll])+'   '+
               floattostr(temp_arr[ll])+'   '+
               floattostr(sal_arr[ll])+'   '+
               floattostr(oxy_arr[ll])); }
   // skipping pressure
   for pp:=1 to n_param-1 do begin
    val1:=99999;
    case pp of
     1: begin
       tbl:='P_TEMPERATURE';
       units_id:=1;
       val1:=temp_arr[ll];
       if (val1=99999) or (val1<-2.5) or (val1>40) then val1:=-9999;
     end;
     2: begin
       tbl:='P_SALINITY';
       units_id:=2;
       val1:=sal_arr[ll];
       if (val1=99999) or (val1<2) or (val1>41) then val1:=-9999;
     end;
     3: begin
       tbl:='P_OXYGEN';
       units_id:=3;
       val1:=oxy_arr[ll];
       if (val1=99999) or (val1<5) or (val1>600) then val1:=-9999;
     end;
    end;

   lev_m:=-gibbsseawater.gsw_z_from_p(pres_arr[ll], stlat, 0, 0);

   if val1<>-9999 then begin
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
      ParamByName('LEV_DBAR').AsFloat:=pres_arr[ll];
      ParamByName('LEV_M').AsFloat:=lev_m;
      ParamByName('VAL').AsFloat:=val1;
      ParamByName('PQF1').AsInteger:=QF;
      ParamByName('PQF2').AsInteger:=QF;
      ParamByName('SQF').AsInteger:=0;
      ParamByName('UNITS_ID').AsInteger:=units_id;
      ParamByName('INSTRUMENT_ID').AsInteger:=11;
      ParamByName('PROFILE_NUMBER').AsInteger:=n_prof;
      ParamByName('PROFILE_BEST').AsBoolean:=true;
     ExecSQL;
    end;
   end;// not -9999

   end;//tables
  end;

 finally
  nc_close(ncid);

  Trt.Commit;
  Qt.Free;
  TrT.Free;

  pres_arr:=nil;
  temp_arr:=nil;
  sal_arr:=nil;
  oxy_arr:=nil;
 end;

end;


end.

