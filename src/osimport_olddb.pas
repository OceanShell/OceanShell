unit osimport_olddb;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin, DB,
  SQLDB, IBConnection, Variants, DateUtils, Math, LConvEncoding;

type

  { Tfrmimport_olddb }

  Tfrmimport_olddb = class(TForm)
    btnSelectOldStations: TButton;
    Button1: TButton;
    Button2: TButton;
    eOldSource: TComboBox;
    eOldVessel: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    mLog: TMemo;
    seSourceNew: TSpinEdit;
    seProjectNew: TSpinEdit;
    seInstituteNew: TSpinEdit;
    seVesselNew: TSpinEdit;
    procedure btnSelectOldStationsClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure eOldVesselSelect(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    procedure CopyProfile(id_from, id_to:int64; Lat:real; inst_id:integer);

  public

  end;

var
  frmimport_olddb: Tfrmimport_olddb;
  path_odb_na: string;
  DB_OLD:TIBConnection;
  TR_OLD:TSQLTransaction;
  Q_OLD:TSQLQuery;

implementation

{$R *.lfm}

uses osmain, dm, driver_fdb, GibbsSeaWater;

{ Tfrmimport_olddb }

procedure Tfrmimport_olddb.FormCreate(Sender: TObject);
begin
 // path_odb_na:='Y:\ODB\ODB_NA_20200220_FB5.FDB';

  path_odb_na:='X:\ODB_backup\_backups\__OCEAN.FDB\OCEAN_NO_ARGO.FDB';

  DB_OLD:=TIBConnection.Create(nil);
  TR_OLD:=TSQLTransaction.Create(nil);
     With DB_OLD do begin
      HostName:='localhost/gds_db';
      DatabaseName:=path_odb_na;
      UserName:=frmdm.IBDB.UserName;
      Password:=frmdm.IBDB.Password;
      Params:=frmdm.IBDB.Params;
      Transaction:=TR_OLD;
     end;

  TR_OLD.Database:=DB_OLD;

  Q_OLD:=TSQLQuery.Create(nil);
  Q_OLD.Database:=DB_OLD;
  Q_OLD.Transaction:=TR_OLD;

  eOldVessel.Clear;
  with Q_OLD do begin
    Close;
      SQL.Clear;
      SQL.Add('SELECT DISTINCT(STVESSELNAME) ');
      SQL.Add('FROM STATION WHERE STVESSELNAME IS NOT NULL ');
      SQL.Add('ORDER BY STVESSELNAME ');
    Open;
  end;
  while not Q_OLD.EOF do begin
    eOldVessel.Items.Add(Q_OLD.Fields[0].Value);
   Q_OLD.Next;
  end;

  eOldSource.Clear;
  with Q_OLD do begin
    Close;
      SQL.Clear;
      SQL.Add('SELECT DISTINCT(STSOURCE) ');
      SQL.Add('FROM STATION ORDER BY STSOURCE ');
    Open;
  end;
  while not Q_OLD.EOF do begin
    eOldSource.Items.Add(Q_OLD.Fields[0].Value);
   Q_OLD.Next;
  end;
end;

procedure Tfrmimport_olddb.btnSelectOldStationsClick(Sender: TObject);
Var
  k: integer;
  Q_TMP, Q:TSQLQuery;
  TR_TMP, TR:TSQLTransaction;

  cruise_id, cruise_id_min, cruise_id_max, station_id, absnum: int64;
  date1, stdate, sttime, date_added, date_updated: TDateTime;
  yy, mn, dd, hh, mm, ss, ms: word;
  latitude, longitude: real;

  version, qcflag: smallint;
  station_cnt, inst_id: integer;
  numincruise, bottom_depth, st_id_orig:Variant;
begin

  TR_TMP:=TSQLTransaction.Create(nil);
  TR_TMP.Database:=DB_OLD;

  Q_TMP:=TSQLQuery.Create(nil);
  Q_TMP.Database:=DB_OLD;
  Q_TMP.Transaction:=TR_TMP;

  TR:=TSQLTransaction.Create(nil);
  TR.Database:=frmdm.IBDB;

  Q:=TSQLQuery.Create(nil);
  Q.Database:=frmdm.IBDB;
  Q.Transaction:=TR;

  with Q do begin
    Close;
      SQL.Clear;
      SQL.Clear;
      SQL.Add(' SELECT STATION_ID_MIN, STATION_ID_MAX FROM SOURCE ');
      SQL.Add(' WHERE ID='+seSourceNew.Text);
    Open;
      cruise_id_min:=Q.Fields[0].Value;
      cruise_id_max:=Q.Fields[1].Value;
    Close;
  end;

  with Q do begin
    Close;
      SQL.Clear;
      SQL.Clear;
      SQL.Add(' SELECT MAX(ID) FROM CRUISE ');
      SQL.Add(' WHERE ID BETWEEN :ID_MIN AND :ID_MAX ');
      ParamByName('ID_MIN').Value:=cruise_id_min;
      ParamByName('ID_MAX').Value:=cruise_id_max;
    Open;
      if not VarIsNull(Q.Fields[0].Value) then
        cruise_id:=Q.Fields[0].Value else cruise_id:=cruise_id_min-1;
    Close;
  end;

  with Q do begin
    Close;
      SQL.Clear;
      SQL.Clear;
      SQL.Add(' SELECT MAX(ID) FROM STATION ');
      SQL.Add(' WHERE ID BETWEEN :ID_MIN AND :ID_MAX ');
      ParamByName('ID_MIN').Value:=cruise_id_min;
      ParamByName('ID_MAX').Value:=cruise_id_max;
    Open;
      if not VarIsNull(Q.Fields[0].Value) then
        station_id:=Q.Fields[0].Value else station_id:=cruise_id_min-1;
    Close;
  end;

  with Q_TMP do begin
     Close;
       SQL.Clear;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT(VESSELCRUISEID) FROM STATION, STATION_INFO ');
       SQL.Add(' WHERE STATION.ABSNUM=STATION_INFO.ABSNUM AND ');
       SQL.Add(' STATION.STVESSELNAME='+QuotedStr(eOldVessel.Text)+' AND ');
       SQL.Add(' STATION.STSOURCE='+QuotedStr(eOldSource.Text));
       SQL.Add(' ORDER BY VESSELCRUISEID ');
     Open;
   end;

  While not Q_TMP.EOF do begin

   with Q_OLD do begin
     Close;
       SQL.Clear;
       SQL.Clear;
       SQL.Add(' SELECT * FROM STATION, STATION_INFO ');
       SQL.Add(' WHERE STATION.ABSNUM=STATION_INFO.ABSNUM AND ');
       SQL.Add(' STATION.STVESSELNAME='+QuotedStr(eOldVessel.Text)+' AND ');
       SQL.Add(' STATION.STSOURCE='+QuotedStr(eOldSource.Text)+' AND ');
       SQL.Add(' STATION_INFO.VESSELCRUISEID='+QuotedStr(Q_TMP.Fields[0].Value));
     Open;
   end;

   inc(cruise_id);
      PutFDBCruise(Q, cruise_id, seVesselNew.Value, seSourceNew.Value,
                          seInstituteNew.Value, seProjectNew.Value, null,
                          Q_TMP.Fields[0].Value, null, null, null, null, now, now,
                          now, now);
  TR.CommitRetaining;


   station_cnt:=0;
   while not Q_OLD.EOF do begin
  //  showmessage(vartostr(Q_OLD.FieldByName('stdate').Value)+'   '+vartostr(Q_OLD.FieldByName('sttime').Value));
     With Q_OLD do begin
       absnum       := FieldByName('absnum').AsInteger;
       stdate       := FieldByName('stdate').AsFloat;
       sttime       := FieldByName('sttime').AsFloat;
       latitude     := FieldByName('stlat').AsFloat;
       longitude    := FieldByName('stlon').AsFloat;
       bottom_depth := FieldByName('stdepthsource').AsInteger;
       numincruise  := FieldByName('stnumincruise').Value;
       st_id_orig   := FieldByName('sourceuniqueid').Value;
       version      := FieldByName('stversion').AsInteger;
       inst_id      := FieldByName('instrument').AsInteger;
       if not VarIsNull(FieldByName('added').Value) then
         date_added:=FieldByName('added').Value else date_added:=now;
       if not VarIsNull(FieldByName('updated').Value) then
         date_updated:=FieldByName('updated').Value else date_updated:=now;
     End;

     decodedate(stdate, yy, mn, dd);
     decodetime(sttime, hh, mm,ss,ms);

     date1:=encodedatetime(yy, mn, dd, hh, mm, ss, ms);

     mlog.Lines.Add(datetimetostr(date1));

     inc(station_id);
     inc(station_cnt);
     PutFDBStation(Q, station_id, latitude, longitude, date1, bottom_depth,
                   cruise_id, numincruise, null, 0, version, 1,
                   null, date_added, date_updated);
     TR.CommitRetaining;

     CopyProfile(absnum, station_id, latitude, inst_id);

     Q_OLD.Next;
   end;

   mLog.Lines.Add(eOldVessel.Text+'   '+
                  Q_TMP.Fields[0].Value+'   '+
                  inttostr(Q_OLD.RecordCount)+'   '+
                  inttostr(station_cnt)+'   '+
                  inttostr(cruise_id));

   Q_TMP.Next;
  end;

//  Showmessage(inttostr(Q_old.RecordCount));
end;

procedure Tfrmimport_olddb.eOldVesselSelect(Sender: TObject);
Var
  k: integer;
  Q_TMP:TSQLQuery;
  TR_TMP:TSQLTransaction;
begin
try
  TR_TMP:=TSQLTransaction.Create(nil);
  TR_TMP.Database:=frmdm.IBDB;

  Q_TMP:=TSQLQuery.Create(nil);
  Q_TMP.Database:=frmdm.IBDB;
  Q_TMP.Transaction:=TR_TMP;

  with Q_TMP do begin
     Close;
       SQL.Clear;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM PLATFORM ');
       SQL.Add(' WHERE NAME='+QuotedStr(eOldVessel.Text));
     Open;
       if not VarIsNull(Q_TMP.Fields[0].Value) then
         seVesselNew.Value:=Q_TMP.Fields[0].Value else seVesselNew.Value:=0;
     close;
   end;

finally
  TR_TMP.Commit;
  Q_TMP.Close;
  Q_TMP.Free;
  TR_TMP.Free;
end;
end;



procedure Tfrmimport_olddb.CopyProfile(id_from, id_to:int64; Lat:real; inst_id:integer);
Var
  k, FL, PQF1, PQF2, units_id:integer;
  tbl: string;
  lev_m, lev_dbar, val1:real;

  Q_FROM, Q_TO:TSQLQuery;
  TR_FROM, TR_TO:TSQLTransaction;
begin
try
 TR_FROM:=TSQLTransaction.Create(nil);
 TR_FROM.Database:=DB_OLD;

 Q_FROM:=TSQLQuery.Create(nil);
 Q_FROM.Database:=DB_OLD;
 Q_FROM.Transaction:=TR_FROM;

 TR_TO:=TSQLTransaction.Create(nil);
 TR_TO.Database:=frmdm.IBDB;

 Q_TO:=TSQLQuery.Create(nil);
 Q_TO.Database:=frmdm.IBDB;
 Q_TO.Transaction:=TR_TO;

  for k:=1 to 10 do begin
   case k of
    1: begin tbl:='P_ALKALINITY';  units_id:=5;  end;
    2: begin tbl:='P_CHLOROPHYLL'; units_id:=4;  end;
    3: begin tbl:='P_NITRATE';     units_id:=15; end;
    4: begin tbl:='P_NITRITE';     units_id:=15; end;
    5: begin tbl:='P_OXYGEN';      units_id:=21; end;
    6: begin tbl:='P_PH';          units_id:=2;  end;
    7: begin tbl:='P_PHOSPHATE';   units_id:=15; end;
    8: begin tbl:='P_SALINITY';    units_id:=28; end;
    9: begin tbl:='P_SILICATE';    units_id:=15; end;
   10: begin tbl:='P_TEMPERATURE'; units_id:=1;  end;
  end;

    with Q_FROM do begin
      Close;
        SQL.Clear;
        SQL.Add(' SELECT level_, value_, flag_ from '+tbl);
        SQL.Add(' WHERE ABSNUM=:ID ');
        SQL.Add(' order by absnum, level_');
        ParambyName('ID').Value:=id_from;
      Open;
    end;


    PutFDBProfile_Prepare(Q_TO, tbl);
    while not Q_FROM.EOF do begin
     with Q_FROM do begin
      LEV_M:=FieldByName('level_').AsFloat;
      LEV_DBAR:=RoundTo(gsw_p_from_z(-lev_m, lat,0,0), -3);
      VAL1 :=FieldByName('value_').AsFloat;
      FL   :=FieldByName('flag_').AsInteger;
     end;

      if fl>=16384 then begin
       pqf1:=2;
       pqf2:=2;
      end else begin
       pqf1:=4;
       pqf2:=4;
      end;

      PutFDBProfile_(Q_TO, tbl, id_to, lev_dbar, lev_m, val1, pqf1, pqf2, 0,
      null, units_id, inst_id, 1, true);

      Q_FROM.Next;
    end;
   end; //tables
   TR_TO.CommitRetaining;

  finally
    TR_FROM.Commit;
    Q_FROM.Close;
    Q_FROM.Free;
    TR_FROM.Free;
    TR_TO.Commit;
    Q_TO.Close;
    Q_TO.Free;
    TR_TO.Free;
  end;
end;


procedure Tfrmimport_olddb.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  TR_OLD.Commit;
  Q_OLD.Close;
  DB_OLD.Connected:=false;
  Q_OLD.Free;
  TR_OLD.Free;
  DB_OLD.Free;
end;




procedure Tfrmimport_olddb.Button1Click(Sender: TObject);
Type
  OLD=record
    lat:real;
    lon:real;
    date:TDateTime;
    depth:variant;
    st_num:variant;
    num_unq: variant;
end;
Type
  NEW=record
    id:int64;
    lat:real;
    lon:real;
    depth:variant;
    date:TDateTime;
    st_num:variant;
end;

Var
  cnt_old, cnt_new, fl, oo, nn: integer;
  Q_OLD, Q_NEW:TSQLQuery;
  TR_OLD, TR_NEW:TSQLTransaction;

  old_arr: array of OLD;
  new_arr: array of NEW;

  yy, mn, dd, hh, mm, ss, ms: word;
begin

  TR_OLD:=TSQLTransaction.Create(nil);
  TR_OLD.Database:=DB_OLD;

  Q_OLD:=TSQLQuery.Create(nil);
  Q_OLD.Database:=DB_OLD;
  Q_OLD.Transaction:=TR_OLD;

  TR_NEW:=TSQLTransaction.Create(nil);
  TR_NEW.Database:=frmdm.IBDB;

  Q_NEW:=TSQLQuery.Create(nil);
  Q_NEW.Database:=frmdm.IBDB;
  Q_NEW.Transaction:=TR_NEW;

  with Q_OLD do begin
    Close;
      SQL.Clear;
      SQL.Clear;
      SQL.Add(' SELECT STLAT, STLON, STDATE, STTIME, STDEPTHSOURCE, STNUMINCRUISE, SOURCEUNIQUEID ');
      SQL.Add(' FROM STATION, STATION_INFO WHERE STATION.ABSNUM=STATION_INFO.ABSNUM ');
      SQL.Add(' AND STSOURCE='+QuotedStr('AARI_TGM'));
      SQL.Add(' ORDER BY STATION.ABSNUM ');
    Open;
  end;

//  showmessage('here');
  cnt_old:=-1;
  while not Q_OLD.eof do begin
   DecodeDate(Q_OLD.FieldByName('STDATE').Value, yy, mn, dd);
   DecodeTime(Q_OLD.FieldByName('STTIME').Value, hh, mm, ss, ms);

   inc(cnt_old);
   setlength(old_arr, cnt_old+1);
   old_arr[cnt_old].lat:=Q_OLD.FieldByName('STLAT').Value;
   old_arr[cnt_old].lon:=Q_OLD.FieldByName('STLON').Value;
   if not VarIsNull(Q_OLD.FieldByName('STDEPTHSOURCE').Value) then
     old_arr[cnt_old].depth:=Q_OLD.FieldByName('STDEPTHSOURCE').Value else
     old_arr[cnt_old].depth:=-9;
   old_arr[cnt_old].date:=EncodeDateTime(yy, mn, dd, hh, mm, ss, ms);
   old_arr[cnt_old].st_num:=Q_OLD.FieldByName('STNUMINCRUISE').Value;
   old_arr[cnt_old].num_unq:=Q_OLD.FieldByName('SOURCEUNIQUEID').Value;
   Q_OLD.Next;
  end;
  Q_OLD.Close;
//  showmessage('old done');

//  showmessage('here2');
  with Q_NEW do begin
    Close;
      SQL.Clear;
      SQL.Clear;
      SQL.Add(' SELECT STATION.ID, LATITUDE, LONGITUDE, DATEANDTIME, BOTTOMDEPTH, ST_NUMBER_ORIGIN ');
      SQL.Add(' FROM STATION, CRUISE WHERE STATION.CRUISE_ID=CRUISE.ID ');
      SQL.Add(' AND CRUISE.SOURCE_ID=3 ');
      SQL.Add(' ORDER BY STATION.ID ');
    Open;
  end;

  cnt_new:=-1;
  while not Q_NEW.eof do begin
   inc(cnt_new);
   setlength(new_arr, cnt_new+1);
   new_arr[cnt_new].id:=Q_NEW.FieldByName('ID').Value;
   new_arr[cnt_new].lat:=Q_NEW.FieldByName('LATITUDE').Value;
   new_arr[cnt_new].lon:=Q_NEW.FieldByName('LONGITUDE').Value;
   if not VarIsNull(Q_NEW.FieldByName('BOTTOMDEPTH').Value) then
     new_arr[cnt_new].depth:=Q_NEW.FieldByName('BOTTOMDEPTH').Value else
     new_arr[cnt_new].depth:=-9;
   new_arr[cnt_new].date:=Q_NEW.FieldByName('DATEANDTIME').Value;
   new_arr[cnt_new].st_num:=Q_NEW.FieldByName('ST_NUMBER_ORIGIN').Value;
   Q_NEW.Next;
  end;
  Q_NEW.Close;

 // Showmessage(inttostr(Q_old.RecordCount)+'   '+inttostr(Q_new.RecordCount));

   for nn:=0 to cnt_new do begin
    fl:=0;
    for oo:=0 to cnt_old do begin
     if (new_arr[nn].lat=old_arr[oo].lat) and
        (new_arr[nn].lon=old_arr[oo].lon) and
        (new_arr[nn].date=old_arr[oo].date) and
        (new_arr[nn].depth=old_arr[oo].depth) then begin
        fl:=1;
        break;
     end;
    end;
    if fl=1 then begin
       if VarIsNull(old_arr[oo].st_num)  then old_arr[oo].st_num:='';
       if VarIsNull(old_arr[oo].num_unq) then old_arr[oo].num_unq:='';

       if new_arr[nn].st_num<>old_arr[oo].st_num then begin
       {  mLog.lines.add('Station: '+inttostr(new_arr[nn].id)+', '+
         new_arr[nn].st_num+' -> '+old_arr[oo].st_num+', '+old_arr[oo].num_unq); }
         try
          with Q_NEW do begin
            Close;
              SQL.Clear;
              SQL.Clear;
              SQL.Add(' UPDATE STATION SET ST_NUMBER_ORIGIN='+QuotedStr(CP1251ToUTF8(old_arr[oo].st_num)));
              SQL.Add(' WHERE STATION.ID=:ID ');
              ParamByName('ID').Value:=new_arr[nn].id;
            ExecSQL;
         end;
         except
           showmessage(old_arr[oo].st_num);
         end;
       end;
    end;
    if fl=0 then begin
      mLog.lines.add('Missing: '+inttostr(new_arr[nn].id));
    end;
   // if nn>1000 then break;
  end;
  TR_NEW.Commit;
  TR_OLD.Commit;


end;

procedure Tfrmimport_olddb.Button2Click(Sender: TObject);
Type
  OLD=record
    st_id_orig:int64;
    date:TDateTime;
end;
Type
  NEW=record
    id:int64;
    st_id_orig:int64;
    date:TDateTime;
end;

Var
  cnt_old, cnt_new, fl, oo, nn, cnt_upd: integer;
  Q_OLD, Q_NEW:TSQLQuery;
  TR_OLD, TR_NEW:TSQLTransaction;

  old_arr: array of OLD;
  new_arr: array of NEW;

  yy, mn, dd, hh, mm, ss, ms: word;
begin

  TR_OLD:=TSQLTransaction.Create(nil);
  TR_OLD.Database:=DB_OLD;

  Q_OLD:=TSQLQuery.Create(nil);
  Q_OLD.Database:=DB_OLD;
  Q_OLD.Transaction:=TR_OLD;

  TR_NEW:=TSQLTransaction.Create(nil);
  TR_NEW.Database:=frmdm.IBDB;

  Q_NEW:=TSQLQuery.Create(nil);
  Q_NEW.Database:=frmdm.IBDB;
  Q_NEW.Transaction:=TR_NEW;

  with Q_OLD do begin
    Close;
      SQL.Clear;
      SQL.Clear;
      SQL.Add(' SELECT ST_ID_ORIGIN, DATEANDTIME ');
      SQL.Add(' FROM STATION WHERE ID BETWEEN 30000001 AND 50000000');
      SQL.Add(' ORDER BY ST_ID_ORIGIN ');
    Open;
  end;

  cnt_old:=-1;
  while not Q_OLD.eof do begin
   inc(cnt_old);
   setlength(old_arr, cnt_old+1);
   old_arr[cnt_old].st_id_orig:=Q_OLD.FieldByName('ST_ID_ORIGIN').Value;
   old_arr[cnt_old].date:=Q_OLD.FieldByName('DATEANDTIME').Value;
   Q_OLD.Next;
  end;
  Q_OLD.Close;
  mLog.lines.add('OLD: '+inttostr(cnt_old));


  with Q_NEW do begin
    Close;
      SQL.Clear;
      SQL.Clear;
      SQL.Add(' SELECT ID, ST_ID_ORIGIN, DATEANDTIME ');
      SQL.Add(' FROM STATION WHERE ');
      SQL.Add(' (ID BETWEEN 30000001 AND 50000000) AND ');
      SQL.Add(' (Extract(year from DATEANDTIME)<1700) ');
      SQL.Add(' ORDER BY ST_ID_ORIGIN ');
    Open;
  end;

  cnt_new:=-1;
  while not Q_NEW.eof do begin
   inc(cnt_new);
   setlength(new_arr, cnt_new+1);
   new_arr[cnt_new].id:=Q_NEW.FieldByName('ID').Value;
   new_arr[cnt_new].date:=Q_NEW.FieldByName('DATEANDTIME').Value;
   new_arr[cnt_new].st_id_orig:=Q_NEW.FieldByName('ST_ID_ORIGIN').Value;
   Q_NEW.Next;
  end;
  Q_NEW.Close;
  mLog.lines.add('NEW: '+inttostr(cnt_new));

   with Q_NEW do begin
     Close;
      SQL.Clear;
      SQL.Clear;
      SQL.Add(' UPDATE STATION SET DATEANDTIME=:dat0 ');
      SQL.Add(' WHERE ID=:ID ');
     Prepare;
   end;

   cnt_upd:=0;
   for nn:=0 to cnt_new do begin
    fl:=0;
    for oo:=0 to cnt_old do begin
     if (new_arr[nn].st_id_orig=old_arr[oo].st_id_orig) then begin
        fl:=1;
        break;
     end;
    end;
    if fl=1 then begin
       if (new_arr[nn].date<>old_arr[oo].date) then begin
            inc(cnt_upd);
          with Q_NEW do begin
              ParamByName('ID').Value:=new_arr[nn].id;
              ParamByName('dat0').Value:=old_arr[oo].date;
            ExecSQL;
         end;
       {  mLog.lines.add(datetimetostr(new_arr[nn].date)+' -> '+
                        datetimetostr(old_arr[oo].date));  }
      Caption:=inttostr(cnt_upd);
      Application.ProcessMessages;
       end;
    end;
   { if fl=0 then begin
      mLog.lines.add('Missing: '+inttostr(new_arr[nn].st_id_orig));
    end; }
   // if nn>1000 then break;
  end;
  TR_NEW.Commit;
  TR_OLD.Commit;



end;

end.

