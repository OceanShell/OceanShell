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
    Button1: TButton;
    btnCore: TButton;
    Button2: TButton;
    Button3: TButton;
    ePath: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
  //  procedure btnParametersBioClick(Sender: TObject);
    procedure btnCoreClick(Sender: TObject);
    procedure btnCruiseClick(Sender: TObject);
    procedure btnSyntheticClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);

  private
    procedure GetCodes(argo_code:string; Var country_id, institute_id, project_id:integer);
   // procedure WriteCoreProfile(fname:string);
    procedure WriteSynteticProfile(fname:string; ID: integer; Lat: real);
  public

  end;

var
  frmload_argo: Tfrmload_argo;

implementation

{$R *.lfm}

{ Tfrmload_argo }

uses osmain, dm, declarations_netcdf, GibbsSeaWater;

(* Link to the data *)
procedure Tfrmload_argo.Label3Click(Sender: TObject);
begin
  OpenURL('https://www.seanoe.org/data/00311/42182/');
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
  proj, pi, op_inst, notes_str:string;
begin
if not FileExists(epath.text+'ar_index_global_meta.txt') then
  if MessageDlg('ar_index_global_meta.txt cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

Memo1.Clear;
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
       Add('id'   ,ftinteger, 0, false);
      end;
    ID_buf.CreateDataSet;


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


{    with Qt2 do begin
          Close;
           Sql.Clear;
           SQL.Add(' UPDATE CRUISE SET PI=:PI, NOTES=:pr ');
           SQL.Add(' WHERE ID=:ID ');
           ParamByName('ID').Value:=ID;
           ParamByName('PI').Value:=PI;
           ParamByName('pr').Value:=notes_str;
          ExecSQL;
      end;
    Qt2.Close;  }

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
     Memo1.lines.add('Updated -> '+inttostr(ID));
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
    Memo1.lines.add('New -> '+inttostr(ID));

    end else
     Memo1.lines.add('Missing codes -> '+inttostr(ID)); //-9
   end; // qt empty

  Qt1.Close;
  until eof(dat);


  (* removing any cruises which are not in the list any more *)
   with Qt1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM CRUISE ORDER BY ID ');
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

    Memo1.lines.add('Removed -> '+inttostr(ID));
    inc(cnt_removed);
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
   Memo1.lines.add('=====');
   Memo1.lines.add('Added: '+inttostr(cnt_added));
   Memo1.lines.add('Updated: '+inttostr(cnt_updated));
   Memo1.lines.add('Removed: '+inttostr(cnt_removed));
 end;
end;


(* Reading ar_index_global_prof.txt and updating STATION *)
procedure Tfrmload_argo.btnCoreClick(Sender: TObject);
Var
  dat:text;
  ID, c, k, cnt, max_id, pp, cnt_kept, cnt_updated, cnt_new, cnt_skipped:integer;

  st, fname, date_str, platf, buf_str, date_upd:string;
  cruise_id: integer;

  lat, lon:string;
  stlat, stlon:real;


  Qt2, Qt1:TSQLQuery;
  TRt:TSQLTransaction;

  stdate, stdate_upd, max_date:TDateTime;
  stnum:string;
  cast, QF:integer;

begin
if not FileExists(epath.text+'ar_index_global_prof.txt') then
  if MessageDlg('ar_index_global_prof.txt cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

Memo1.Clear;
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
        SQL.Add(' select max(id) from station where ID BETWEEN 20000000 AND 30000000  ');
       Open;
        max_id  :=Qt1.Fields[0].AsInteger;
       Close;
      end;


  AssignFile(dat, ePath.text+'ar_index_global_prof.txt');
  reset(dat);

  cnt_kept:=0; cnt_updated:=0; cnt_new:=0; cnt_skipped:=0;
  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';


  repeat
   readln(dat, st);

   c:=0; pp:=0;
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
     8: date_upd:=buf_str;
    end;
   end;

   if copy(ExtractFileName(fname), 2, 1)='D' then QF:=4 else QF:=0;

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


  // st_id_orig:=Strtoint(platf)*10000+Strtoint(stnum);


     if (trim(lat)<>'') and (trim(lon)<>'') and
        (length(date_str)=14) and (cruise_id>0) then begin

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

       stdate_upd:=EncodeDateTime(StrToInt(copy(date_upd, 1, 4)),
                          StrToInt(copy(date_upd, 5, 2)),
                          StrToInt(copy(date_upd, 7, 2)),
                          StrToInt(copy(date_upd, 9, 2)),
                          StrToInt(copy(date_upd, 11, 2)),
                          StrToInt(copy(date_upd, 13, 2)),
                          0);

       inc(cnt);

      with Qt1 do begin
       Close;
        Sql.Clear;
        SQL.Add(' select id, date_updated from station ');
        SQL.Add(' where cruise_id=:crID and st_number_origin=:stnum ');
        ParamByName('crID').Value:=cruise_ID;
        ParamByName('stnum').Value:=stnum;
       Open;
      end;

      (* station is in the database *)
      if Qt1.IsEmpty=false then begin

        if Qt1.FieldByName('date_updated').AsDateTime>=stdate_upd then begin
         inc(cnt_kept);
        end;

        if Qt1.FieldByName('date_updated').AsDateTime<stdate_upd then begin
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
            SQL.Add(' where cruise_id=:crID and st_number_origin=:stnum ');
            ParamByName('Lat').Value:=stlat;
            ParamByName('Lon').Value:=stlon;
            ParamByName('date1').Value:=stdate;
            ParamByName('QF').Value:=QF;
            ParamByName('date_upd').Value:=stdate_upd;
            ParamByName('crID').Value:=cruise_ID;
            ParamByName('stnum').Value:=stnum;
           ExecSQL;
         end;

         Memo1.lines.add('Updated: '+platf+'_'+stnum);
        end;
       end;


      if Qt1.IsEmpty=true then begin
       inc(cnt_new);
       inc(max_id);

       if copy(stnum, length(stnum), 1)='D' then cast:=2 else cast:=1;

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
          ParamByName('date_added').Value:=stdate_upd;
          ParamByName('date_updated').Value:=stdate_upd;
          ParamByName('cast_number').Value:=cast;
          ParamByName('QCFLAG').Value:=QF;
         ExecSQL;
        end;
       Memo1.lines.add('Inserted: '+platf+'_'+stnum);
       end; //q2
       Qt1.Close;

     end; //Qt1;
     Qt1.Close;

     end else inc(cnt_skipped); // coordinates in -90..90, -180..180

  until eof(dat);
  finally
     Trt.Commit;
     Qt1.Free;
     Qt2.Free;
     Trt.Free;
     Memo1.lines.add('=====');
     Memo1.lines.add('Done!');
     Memo1.lines.add('Unchanged: '+inttostr(cnt_kept));
     Memo1.lines.add('Updated: '  +inttostr(cnt_updated));
     Memo1.lines.add('Added: '    +inttostr(cnt_new));
     Memo1.lines.add('Skipped: '  +inttostr(cnt_skipped));
   end;
end;


procedure Tfrmload_argo.btnSyntheticClick(Sender: TObject);
Var
  dat:text;
  ID, c, k, cnt, max_id, pp, cnt_kept, cnt_updated, cnt_new, cnt_skipped:integer;

  st, fname, date_str, platf, buf_str, date_upd:string;
  cruise_id: integer;

  lat, lon:string;
  stlat, stlon:real;


  Qt2, Qt1:TSQLQuery;
  TRt:TSQLTransaction;

  stdate, stdate_upd, max_date:TDateTime;
  stnum, tbl:string;
  cast, QF:integer;

begin
if not FileExists(epath.text+'argo_synthetic-profile_index.txt') then
  if MessageDlg('argo_synthetic-profile_index.txt cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

Memo1.Clear;
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
        SQL.Add(' select max(id) from station where ID BETWEEN 20000000 AND 30000000  ');
       Open;
        max_id  :=Qt1.Fields[0].AsInteger;
       Close;
      end;

  AssignFile(dat, ePath.text+'argo_synthetic-profile_index.txt');

  reset(dat);

  cnt_kept:=0; cnt_updated:=0; cnt_new:=0; cnt_skipped:=0;
  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';


  repeat
   readln(dat, st);

   c:=0; pp:=0;
   for k:=1 to 10 do begin
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
     10: date_upd:=buf_str;
    end;
   end;

   if copy(ExtractFileName(fname), 2, 1)='D' then QF:=4 else QF:=0;

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


  // st_id_orig:=Strtoint(platf)*10000+Strtoint(stnum);


     if (trim(lat)<>'') and (trim(lon)<>'') and
        (length(date_str)=14) and (cruise_id>0) then begin

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

       stdate_upd:=EncodeDateTime(StrToInt(copy(date_upd, 1, 4)),
                          StrToInt(copy(date_upd, 5, 2)),
                          StrToInt(copy(date_upd, 7, 2)),
                          StrToInt(copy(date_upd, 9, 2)),
                          StrToInt(copy(date_upd, 11, 2)),
                          StrToInt(copy(date_upd, 13, 2)),
                          0);

       inc(cnt);

      with Qt1 do begin
       Close;
        Sql.Clear;
        SQL.Add(' select id, date_updated from station ');
        SQL.Add(' where cruise_id=:crID and st_number_origin=:stnum ');
        ParamByName('crID').Value:=cruise_ID;
        ParamByName('stnum').Value:=stnum;
       Open;
      end;

      (* station is in the database *)
      if Qt1.IsEmpty=false then begin

        if Qt1.FieldByName('date_updated').AsDateTime>=stdate_upd then begin
         inc(cnt_kept);
        end;

        if Qt1.FieldByName('date_updated').AsDateTime<stdate_upd then begin
         inc(cnt_updated);

         with Qt2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' SELECT ID FROM STATION WHERE ');
           SQL.Add(' cruise_id=:crID and st_number_origin=:stnum ');
           ParamByName('crID').Value:=cruise_ID;
           ParamByName('stnum').Value:=stnum;
          Open;
           ID:=Qt2.FieldByName('ID').AsInteger;
          Close;
         end;

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
            ParamByName('date_upd').Value:=stdate_upd;
            ParamByName('ID').Value:=ID;
           ExecSQL;
         end;

         (* removing old profiles *)
         for pp:=1 to 3 do begin
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
         WriteSynteticProfile(ePath.text+fname, id, StLat);

         Memo1.lines.add('Updated: '+platf+'_'+stnum);
        end;
       end;


      if Qt1.IsEmpty=true then begin
       inc(cnt_new);
       inc(max_id);

       if copy(stnum, length(stnum), 1)='D' then cast:=2 else cast:=1;

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
          ParamByName('date_added').Value:=stdate_upd;
          ParamByName('date_updated').Value:=stdate_upd;
          ParamByName('cast_number').Value:=cast;
          ParamByName('QCFLAG').Value:=QF;
         ExecSQL;
        end;
       Memo1.lines.add('Inserted: '+platf+'_'+stnum);
       end; //q2
       Qt1.Close;
       Trt.CommitRetaining;

       (* writing parameters for new station *)
       WriteSynteticProfile(ePath.text+fname, max_id, StLat);

     end; //Qt1;
     Qt1.Close;

     end else inc(cnt_skipped); // coordinates in -90..90, -180..180

  until eof(dat);
  finally
     Trt.Commit;
     Qt1.Free;
     Qt2.Free;
     Trt.Free;
     Memo1.lines.add('=====');
     Memo1.lines.add('Done!');
     Memo1.lines.add('Unchanged: '+inttostr(cnt_kept));
     Memo1.lines.add('Updated: '  +inttostr(cnt_updated));
     Memo1.lines.add('Added: '    +inttostr(cnt_new));
     Memo1.lines.add('Skipped: '  +inttostr(cnt_skipped));
   end;
end;



procedure Tfrmload_argo.WriteSynteticProfile(fname:string; ID: integer; Lat: real);
Var
 k, ncid, varidp, pp, ll, par, prof_fl, units_id, QF: integer;
 var_name, tbl: string;
 n_prof, n_levels, n_param: size_t;
 vtype: nc_type; //nc_inq_var
 ip: array of single;
 pres_arr, temp_arr, sal_arr, oxy_arr:array of single;
 val1, lev_m: real;


 ff: array of PAnsiChar;
 lenp: size_t;
 QF_str: string;
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
  if n_prof>1 then Memo1.lines.add(inttostr(n_prof)+'   '+fname);

  nc_inq_dimid (ncid, pAnsiChar('N_PARAM'), varidp);
  nc_inq_dimlen(ncid, varidp, n_param);


  nc_inq_dimid (ncid, pAnsiChar('N_LEVELS'), varidp);
  nc_inq_dimlen(ncid, varidp, n_levels);


  nc_inq_varid (ncid, pAnsiChar('PARAMETER_DATA_MODE'), varidp);
  SetLength(ff, (n_prof*n_param));
  nc_get_var_text(ncid, varidp, ff);
  QF_str:=trim(pchar(ff));

 // showmessage(QF_str);


  SetLength(pres_arr, n_levels);
  SetLength(temp_arr, n_levels);
  SetLength(sal_arr,  n_levels);
  SetLength(oxy_arr,  n_levels);

  for par:=1 to 4 do begin
     case par of
      1: begin
         var_name:='PRES';
      end;
      2: begin
         var_name:='TEMP';
         if (copy(QF_str, 2, 1)='D') or (copy(QF_str, 2, 1)='A') then QF:=4 else QF:=0;
      end;
      3: begin
         var_name:='PSAL';
         if (copy(QF_str, 3, 1)='D') or (copy(QF_str, 3, 1)='A') then QF:=4 else QF:=0;
      end;
      4: begin
         var_name:='DOXY';
         if (copy(QF_str, 4, 1)='D') or (copy(QF_str, 4, 1)='A') then QF:=4 else QF:=0;
      end;
     end;


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
   for pp:=1 to 3 do begin
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

   lev_m:=-gibbsseawater.gsw_z_from_p(pres_arr[ll], lat, 0, 0);

   if val1<>-9999 then begin
    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' insert into ');
      SQL.Add(tbl);
      SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF1, PQF2, UNITS_ID, ');
      SQL.Add('  INSTRUMENT_ID, PROFILE_NUMBER, PROFILE_BEST) ');
      SQL.Add(' values ');
      SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF1, :PQF2, :UNITS_ID, ');
      SQL.Add('  :INSTRUMENT_ID, :PROFILE_NUMBER, :PROFILE_BEST) ');
      ParamByName('ID').AsInteger:=id;
      ParamByName('LEV_DBAR').AsFloat:=pres_arr[ll];
      ParamByName('LEV_M').AsFloat:=lev_m;
      ParamByName('VAL').AsFloat:=val1;
      ParamByName('PQF1').AsInteger:=QF;
      ParamByName('PQF2').AsInteger:=QF;
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


{procedure Tfrmload_argo.btnCoreClick(Sender: TObject);
Var
  dat:text;
  st, buf_str:string;
  cnt, c:integer;
begin
  AssignFile(dat, ePath.text+'ar_index_global_prof.txt'); reset(dat);

  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';

  cnt:=0;
  repeat
   inc(cnt);

   readln(dat, st);

   c:=0;
    buf_str:='';
    repeat
      inc(c);
      if st[c]<>',' then buf_str:=buf_str+st[c];
    until (st[c]=',') or (c=length(st));

    //WriteCoreProfile(ePath.Text+buf_str);
  until eof(dat);
 CloseFile(dat);
end;    }


procedure Tfrmload_argo.Button3Click(Sender: TObject);
Var
 Qtt, Qt1, qt2:TSQLQuery;
 TRt:TSQLTransaction;
 id:integer;
 id_str:string;
begin
 Memo1.clear;

    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;

    Qtt:=TSQLQuery.Create(self);
    Qtt.Database:=frmdm.IBDB;
    Qtt.Transaction:=TRt;


     Qt1:=TSQLQuery.Create(self);
     Qt1.Database:=frmdm.IBDB;
     Qt1.Transaction:=TRt;


      with Qtt do begin
       Close;
        Sql.Clear;
        SQL.Add(' SELECT LIST( id ) ');
        SQL.Add(' FROM station ');
        SQL.Add(' GROUP BY latitude, longitude, dateandtime ');
        SQL.Add(' HAVING ( COUNT(*) > 1 )');
       Open;
      end;

      while not Qtt.eof do begin
      id_str:=Qtt.Fields[0].Value;
      id:=StrToInt(copy(id_str, Pos(',', id_str)+1, length(id_str)));
         with Qt1 do begin
           Close;
            Sql.Clear;
            SQL.Add(' update station set stversion= 1');
            SQL.Add(' where id='+inttostr(id));
           ExecSQL;
         end;
         trt.CommitRetaining;

       Qtt.Next;
      end;

    trt.Commit;
end;




procedure Tfrmload_argo.Button1Click(Sender: TObject);
Var
 dat:text;
 st, fname, proj, pi: string;

 k, ncid, varidp:integer;
 vtype :nc_type;

 ip: array of PAnsiChar;
begin

  AssignFile(dat, epath.text+'argo_synthetic-profile_index.txt'); Reset(dat);

  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';

  repeat
   readln(dat, st);
   fname:=epath.text+copy(st, 1, pos(',', st)-1);

   nc_open(pansichar(AnsiString(fname)), NC_NOWRITE, ncid); // only for reading

   nc_inq_varid (ncid, pAnsiChar('PROJECT_NAME'), varidp);
   SetLength(ip, 64);
   nc_get_var_text(ncid, varidp, ip);
   proj:=trim(pchar(ip));


   nc_inq_varid (ncid, pAnsiChar('PI_NAME'), varidp);
   SetLength(ip, 64);
   nc_get_var_text(ncid, varidp, ip);
   PI:=trim(pchar(ip));

 //  showmessage(proj+'   '+PI);
   Memo1.lines.Add(proj);
   nc_close(ncid);

  until eof(dat);
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


procedure Tfrmload_argo.Button2Click(Sender: TObject);
Var
 Qt2, Qt1, Qt3:TSQLQuery;
 TRt:TSQLTransaction;

 stdate, stdate_upd, max_date:TDateTime;
 stnum, tbl:string;
 cast, QF, cnt_t, cnt_s, cnt_o:integer;
begin
Memo1.Clear;
 try
    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;

    Qt1:=TSQLQuery.Create(self);
    Qt1.Database:=frmdm.IBDB;
    Qt1.Transaction:=TRt;

    Qt2:=TSQLQuery.Create(self);
    Qt2.Database:=frmdm.IBDB;
    Qt2.Transaction:=TRt;

    Qt3:=TSQLQuery.Create(self);
    Qt3.Database:=frmdm.IBDB;
    Qt3.Transaction:=TRt;


     with Qt1 do begin
      Close;
       SQL.Clear;
       SQL.Add('SELECT ID FROM STATION WHERE ID>20000001 and ID<30000000 ORDER BY ID ');
      Open;
     end;

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
      { with Qt3 do begin
        Close;
         SQL.Clear;
         SQL.Add(' DELETE FROM STATION ');
         SQL.Add(' WHERE ID=:ID ');
         ParamByName('ID').AsInteger:=Qt1.FieldByName('ID').AsInteger;
        ExecSQL;
       end;  }
      Memo1.Lines.add(inttostr(Qt1.FieldByName('ID').AsInteger));
      end;

      Qt1.Next;
     end;
 finally
  Trt.Commit;
  Qt1.Free;
  Qt2.Free;
  Qt3.Free;
  Trt.Free;
 end;
end;


end.

