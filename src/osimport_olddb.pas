unit osimport_olddb;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin, DB,
  SQLDB, IBConnection, Variants, DateUtils, Math;

type

  { Tfrmimport_olddb }

  Tfrmimport_olddb = class(TForm)
    btnSelectOldStations: TButton;
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
  path_odb_na:='Y:\ODB\ODB_NA_20200220_FB5.FDB';

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

end.

