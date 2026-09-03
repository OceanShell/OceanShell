unit osqc_cruiseinfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection;


Procedure UpdateCruiseInfo(DB_main:TIBConnection; cruise_ID: int64);


implementation

Procedure UpdateCruiseInfo(DB_main:TIBConnection; cruise_ID: int64);
Var
DBt:TIBConnection;
TRt:TSQLTransaction;
Qt:TSQLQuery;

cnt: integer;
latmin, latmax, lonmin, lonmax:real;
datemin, datemax, dateupd:TDateTime;
begin

   TRt:=TSQLTransaction.Create(nil);
    DBt:=TIBConnection.Create(nil);
    With DBt do begin
     DatabaseName:=DB_main.DatabaseName;
     UserName:=DB_main.UserName;
     Password:=DB_main.Password;
     Params:=DB_main.Params;
     Transaction:=TRt;
    end;

    TRt.Database:=DBt;

 Qt:=TSQLQuery.Create(nil);
 Qt.Database:=DBt;
 Qt.Transaction:=TRt;

 try
  cnt:=0;
  with Qt do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT ');
    SQL.Add(' min(LATITUDE) as LatMin, ');
    SQL.Add(' max(LATITUDE) as LatMax, ');
    SQL.Add(' min(LONGITUDE) as LonMin, ');
    SQL.Add(' max(LONGITUDE) as LonMax, ');
    SQL.Add(' min(DATEANDTIME) as DateMin, ');
    SQL.Add(' max(DATEANDTIME) as DateMax, ');
    SQL.Add(' max(DATE_UPDATED) as DateUpd, ');
    SQL.Add(' count(ID) as cnt ');
    SQL.Add(' FROM STATION ');
    SQL.Add(' where CRUISE_ID=:CR_ID ');
    ParamByName('CR_ID').AsInteger:=Cruise_ID;
   Open;
    if FieldByName('cnt').AsInteger>0 then begin
      LatMin:=FieldByName('LatMin').Value;
      LatMax:=FieldByName('LatMax').Value;
      LonMin:=FieldByName('LonMin').Value;
      LonMax:=FieldByName('LonMax').Value;
      DateMin:=FieldByName('DateMin').Value;
      DateMax:=FieldByName('DateMax').Value;
      DateUpd:=FieldByName('DateUpd').Value;
      cnt:=FieldByName('cnt').Value;
    end;
    if FieldByName('cnt').AsInteger=0 then begin
      LatMin:=0;
      LatMax:=0;
      LonMin:=0;
      LonMax:=0;
      DateMin:=now;
      DateMax:=now;
      DateUpd:=now;
      cnt:=0;
    end;
   Close;
  end;

  with Qt do begin
   Close;
    SQL.Clear;
    SQL.Add(' UPDATE CRUISE SET ');
    SQL.Add(' LATITUDE_MIN=:LatMin, ');
    SQL.Add(' LATITUDE_MAX=:LatMax, ');
    SQL.Add(' LONGITUDE_MIN=:LonMin, ');
    SQL.Add(' LONGITUDE_MAX=:LonMax, ');
    SQL.Add(' DATE_UPDATED=:DateUpd, ');
    SQL.Add(' DATE_START_DATABASE=:DateMin, ');
    SQL.Add(' DATE_END_DATABASE=:DateMax, ');
    SQL.Add(' STATIONS_DATABASE=:cnt ');
    SQL.Add(' WHERE ID=:CR_ID ');
    ParamByName('CR_ID').AsInteger:=Cruise_ID;
    ParamByName('LatMin').Value:=LatMin;
    ParamByName('LatMax').Value:=LatMax;
    ParamByName('LonMin').Value:=LonMin;
    ParamByName('LonMax').Value:=LonMax;
    ParamByName('DateMin').Value:=DateMin;
    ParamByName('DateMax').Value:=DateMax;
    ParamByName('DateUpd').Value:=DateUpd;
    ParamByName('cnt').Value:=cnt;
   ExecSQL;
  end;

 finally
  Qt.Close;
  Trt.Commit;
  Qt.Free;
  Trt.Free;
  DBt.Connected:=false;
  DBt.Free;
 end;
end;

end.

