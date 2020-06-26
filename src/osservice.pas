unit osservice;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants, Math, DB, SQLDB, osmain, dm, procedures, Dialogs;

procedure UpdateCruiseInfo(ID: integer);


implementation



procedure UpdateCruiseInfo(ID: integer);
Var
  TRt:TSQLTransaction;
  Qt1, Qt2:TSQLQuery;
  k:integer;
begin
  try
   Qt1:=TSQLQuery.Create(nil);
   Qt1.Database:=frmdm.IBDB;
   Qt1.Transaction:=frmdm.TR;

   Qt2:=TSQLQuery.Create(nil);
   Qt2.Database:=frmdm.IBDB;
   Qt2.Transaction:=frmdm.TR;

     with Qt1 do begin
       Close;
         SQL.Clear;
         SQL.Add(' SELECT ');
         SQL.Add(' min(DATEANDTIME) as min_date, ');
         SQL.Add(' max(DATEANDTIME) as max_date, ');
         SQL.Add(' count(ID) as cnt ');
         SQL.Add(' FROM STATION ');
         SQL.Add(' where CRUISE_ID=:CR_ID ');
         ParamByName('CR_ID').AsInteger:=ID;
       Open;
     end;

     with Qt2 do begin
       Close;
         SQL.Clear;
         SQL.Add(' UPDATE CRUISE SET ');
         SQL.Add(' DATE_START=:min_date, DATE_END=:max_date, STATIONS_AMOUNT=:cnt ');
         SQL.Add(' where ID=:CR_ID ');
         ParamByName('CR_ID').AsInteger:=ID;
         ParamByName('min_date').AsDateTime:=Qt1.FieldByName('min_date').AsDateTime;
         ParamByName('max_date').AsDateTime:=Qt1.FieldByName('max_date').AsDateTime;
         ParamByName('cnt').AsInteger:=Qt1.FieldByName('cnt').AsInteger;
       ExecSQL;
     end;
     Qt1.Close;

  finally
     Qt1.Close;
     Qt2.Close;
     Qt1.free;
     Qt2.free;
     frmdm.TR.CommitRetaining;
  end;
end;

end.

