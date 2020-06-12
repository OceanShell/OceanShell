unit osservice;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants, Math, DB, SQLDB, osmain, dm, procedures, Dialogs;

procedure UpdateLastLevel;
procedure UpdateCruiseInfo(ID: integer);


implementation


(* Вставляем последний горизонт для выборки *)
procedure UpdateLastLevel;
var
  ci1, CurrentID, k:integer;
  Max_LLM, Max_LLD:variant;

  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
   TRt:=TSQLTransaction.Create(nil);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(nil);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

try
 CurrentID:=frmdm.Q.FieldByName('ID').AsInteger;
 frmdm.Q.DisableControls;
 frmdm.Q.First;

 k:=0;
 While not frmdm.Q.Eof do begin
   inc(k);

    Max_LLM:=-9;
    Max_LLD:=-9;
    for ci1:=0 to frmosmain.ListBox1.Count-1 do begin
      With Qt do begin
       Close;
        SQL.Clear;
        SQL.Add(' Select max(LEV_M) as LLM, max(LEV_DBAR) as LLD from ');
        SQL.Add(frmosmain.ListBox1.Items.Strings[ci1]);
        SQL.Add(' where ID=:pAbsNum ');
        Parambyname('pAbsnum').asInteger:=frmdm.Q.FieldByName('ID').AsInteger;
       Open;
          if not VarIsNull(Qt.Fields[0].AsVariant) then Max_LLM:=Max(Max_LLM,Qt.Fields[0].AsFloat);
          if not VarIsNull(Qt.Fields[1].AsVariant) then Max_LLD:=Max(Max_LLD,Qt.Fields[1].AsFloat);
       Close;
      end;
    end;

    if Max_LLM=-9 then Max_LLM:=Null;
    if Max_LLD=-9 then Max_LLD:=Null;

    With Qt do begin
       Close;
        SQL.Clear;
        SQL.Add(' Update STATION set ');
        SQL.Add(' LASTLEVEL_M=:LLM, ');
        SQL.Add(' LASTLEVEL_DBAR=:LLD ');
        SQL.Add(' where ID=:pAbsNum ');
        Parambyname('pAbsnum').asInteger:=frmdm.Q.FieldByName('ID').AsInteger;
        Parambyname('LLM').Value:=Max_LLM;
        Parambyname('LLD').Value:=Max_LLD;
       ExecSQL;
    end;
    Procedures.ProgressTaskbar(k, frmdm.Q.RecordCount-1);
   frmdm.Q.Next;
 end;
 Procedures.ProgressTaskbar(0, 0);
finally
 frmdm.Q.Refresh;
 frmdm.Q.Locate('ID',CurrentID,[loCaseInsensitive]);
 frmdm.Q.EnableControls;
 Qt.Close;
 Qt.free;
 TrT.Commit;
 TrT.Free;

 showmessage('Last level update completed');
end;
end;



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

