unit osqc_stationparameters;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, SQLDB, procedures, dialogs;


Procedure UpdateStationParameters(DB:TIBConnection; ID_MIN, ID_MAX: int64);

implementation


Procedure UpdateStationParameters(DB:TIBConnection; ID_MIN, ID_MAX: int64);
Var
  TR:TSQLTransaction;
  Q1_read,  Q2_read, Q3_read, Q_write:TSQLQuery;

  ID, tbl_id, k, ci1, cnt, Pct:integer;
  tmp_lst, tbl_lst:TStringList;
  AppPath, IniFileName, DBAlias, DBUser, DBPass, DBHost, DBPath, tbl: string;

  cnt_prof, cnt_lev: Variant;
  Lev_m_min, Lev_m_avg, Lev_m_max, Lev_dbar_min, Lev_dbar_avg, Lev_dbar_max:Variant;
  Value_min, Value_avg, Value_max, Value_min_flag, Value_avg_flag, Value_max_flag:Variant;

begin

  DB.Transaction.Commit;

  try
   TR:=TSQLTransaction.Create(nil);
   TR.Database:=DB;

   Q1_read:=TSQLQuery.Create(nil);
   Q1_read.Database:=DB;
   Q1_read.Transaction:=TR;

   Q2_read:=TSQLQuery.Create(nil);
   Q2_read.Database:=DB;
   Q2_read.Transaction:=TR;

   Q3_read:=TSQLQuery.Create(nil);
   Q3_read.Database:=DB;
   Q3_read.Transaction:=TR;

   Q_write:=TSQLQuery.Create(nil);
   Q_write.Database:=DB;
   Q_write.Transaction:=TR;

   tmp_lst:=TStringList.Create;
   tbl_lst:=TStringList.Create;
   DB.GetTableNames(tmp_lst,False);

    for k:=0 to tmp_lst.Count-1 do
     if (copy(tmp_lst.Strings[k], 1, 2)='P_') then
       tbl_lst.Add(tmp_lst.Strings[k]);
   tmp_lst.Free;


  with Q1_read do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT ID FROM STATION ');
    SQL.Add(' WHERE ID BETWEEN :ID_MIN AND :ID_MAX ');
    ParamByName('ID_MIN').Value:=ID_MIN;
    ParamByName('ID_MAX').Value:=ID_MAX;
   Open;
   Last;
   First;
  end;
  cnt:=Q1_read.RecordCount;
 // writeln('Stations to update: '+inttostr(cnt));
  showmessage('Stations to update: '+inttostr(cnt));

  with Q_write do begin
   Close;
    SQL.Clear;
    SQL.Add(' DELETE FROM STATION_PARAMETERS ');
    SQL.Add(' WHERE STATION_ID BETWEEN :ID_MIN AND :ID_MAX ');
    ParamByName('ID_MIN').Value:=ID_MIN;
    ParamByName('ID_MAX').Value:=ID_MAX;
   ExecSQL;
  end;
  TR.CommitRetaining;
//  writeln('Old records removed');

  k:=0;
  While not Q1_read.Eof do begin
   inc(k);
    ID:=Q1_read.FieldByName('ID').Value;

       //   showmessage(tbl);

    (* Loop over tables *)
    for ci1:=0 to tbl_lst.Count-1 do begin
      tbl:=tbl_lst.Strings[ci1];

      With Q2_read do begin
        Close;
         SQL.Clear;
         SQL.Add(' SELECT 1 FROM '+tbl);
         SQL.Add(' WHERE ID=:ID ');
         ParamByName('ID').Value:=ID;
        Open;
      end;

      (* if tbl has values *)
      if not Q2_read.IsEmpty then begin

   //   showmessage('not empty');

       With Q3_read do begin
        Close;
         SQL.Clear;
         SQL.Add(' SELECT ID FROM DATABASE_TABLES ');
         SQL.Add(' WHERE NAME_TABLE='+QuotedStr(tbl));
        Open;
         tbl_ID:=Q3_read.Fields[0].Value;
        Close;
       end;

      cnt_prof:=0;
      cnt_lev:=0;
      Lev_m_min:=-9999;
      Lev_m_avg:=-9999;
      Lev_m_max:=-9999;
      Lev_dbar_min:=-9999;
      Lev_dbar_avg:=-9999;
      Lev_dbar_max:=-9999;
      Value_min:=-9999;
      Value_avg:=-9999;
      Value_max:=-9999;
      With Q3_read do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT ');
        SQL.Add(' count(distinct(PROFILE_NUMBER)) as CNT_PROF, ');
        SQL.Add(' count(LEV_M) as CNT_LEV, ');
        SQL.Add(' min(LEV_M) as LEVEL_M_MIN, ');
        SQL.Add(' avg(LEV_M) as LEVEL_M_AVG, ');
        SQL.Add(' max(LEV_M) as LEVEL_M_MAX, ');
        SQL.Add(' min(LEV_DBAR) as LEVEL_DBAR_MIN, ');
        SQL.Add(' avg(LEV_DBAR) as LEVEL_DBAR_AVG, ');
        SQL.Add(' max(LEV_DBAR) as LEVEL_DBAR_MAX, ');
        SQL.Add(' min(VAL) as VALUE_MIN, ');
        SQL.Add(' avg(VAL) as VALUE_AVG, ');
        SQL.Add(' max(VAL) as VALUE_MAX ');
        SQL.Add(' FROM '+tbl);
        SQL.Add(' WHERE ID=:pAbsNum ');
        Parambyname('pAbsnum').asInteger:=ID;
       Open;
        cnt_prof:=Q3_read.FieldByName('CNT_PROF').Value;
        cnt_lev:=Q3_read.FieldByName('CNT_LEV').Value;
        lev_m_min:=Q3_read.FieldByName('LEVEL_M_MIN').Value;
        lev_m_avg:=Q3_read.FieldByName('LEVEL_M_AVG').Value;
        lev_m_max:=Q3_read.FieldByName('LEVEL_M_MAX').Value;
        lev_dbar_min:=Q3_read.FieldByName('LEVEL_DBAR_MIN').Value;
        lev_dbar_avg:=Q3_read.FieldByName('LEVEL_DBAR_AVG').Value;
        lev_dbar_max:=Q3_read.FieldByName('LEVEL_DBAR_MAX').Value;
        value_min:=Q3_read.FieldByName('VALUE_MIN').Value;
        value_avg:=Q3_read.FieldByName('VALUE_AVG').Value;
        value_max:=Q3_read.FieldByName('VALUE_MAX').Value;
       Close;
      end;

     // writeln('1');

      Value_min_flag:=-9999;
      Value_avg_flag:=-9999;
      Value_max_flag:=-9999;
      With Q3_read do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT ');
        SQL.Add(' min(VAL) as VALUE_MIN_FLAG, ');
        SQL.Add(' avg(VAL) as VALUE_AVG_FLAG, ');
        SQL.Add(' max(VAL) as VALUE_MAX_FLAG ');
        SQL.Add(' FROM '+tbl);
        SQL.Add(' where ID=:pAbsNum AND PQF2>=3 '); // only good ones
        Parambyname('pAbsnum').asInteger:=ID;
       Open;
         value_min_flag:=Q3_read.FieldByName('VALUE_MIN_FLAG').Value;
         value_avg_flag:=Q3_read.FieldByName('VALUE_AVG_FLAG').Value;
         value_max_flag:=Q3_read.FieldByName('VALUE_MAX_FLAG').Value;
       Close;
      end;

     // showmessage(floattostr(value_min_flag));

  { With Q_write do begin
     Close;
      SQL.Clear;
        SQL.Add(' INSERT INTO STATION_PARAMETERS ');
        SQL.Add(' (STATION_ID, DATABASE_TABLE_ID, AMOUNT_PROFILES, AMOUNT_LEVELS, ');
        SQL.Add(' LEVEL_M_MIN, LEVEL_M_AVG, LEVEL_M_MAX, ');
        SQL.Add(' LEVEL_DBAR_MIN, LEVEL_DBAR_AVG, LEVEL_DBAR_MAX, ');
        SQL.Add(' VALUE_MIN, VALUE_AVG, VALUE_MAX, ');
        SQL.Add(' VALUE_MIN_PQF2_3, VALUE_AVG_PQF2_3, VALUE_MAX_PQF2_3) ');
        SQL.Add(' VALUES ');
        SQL.Add(' (:STATION_ID, :DATABASE_TABLE_ID, :AMOUNT_PROFILES, :AMOUNT_LEVELS, ');
        SQL.Add(' :LEVEL_M_MIN, :LEVEL_M_AVG, :LEVEL_M_MAX, ');
        SQL.Add(' :LEVEL_DBAR_MIN, :LEVEL_DBAR_AVG, :LEVEL_DBAR_MAX, ');
        SQL.Add(' :VALUE_MIN, :VALUE_AVG, :VALUE_MAX, ');
        SQL.Add(' :VALUE_MIN_FLAG, :VALUE_AVG_FLAG, :VALUE_MAX_FLAG) ');
        Parambyname('STATION_ID').Value:=ID;
        Parambyname('DATABASE_TABLE_ID').Value:=tbl_ID;
        Parambyname('AMOUNT_PROFILES').Value:=cnt_prof;
        Parambyname('AMOUNT_LEVELS').Value:=cnt_lev;
        Parambyname('LEVEL_M_MIN').Value:=lev_m_min;
        Parambyname('LEVEL_M_AVG').Value:=lev_m_avg;
        Parambyname('LEVEL_M_MAX').Value:=lev_m_max;
        Parambyname('LEVEL_DBAR_MIN').Value:=lev_dbar_min;
        Parambyname('LEVEL_DBAR_AVG').Value:=lev_dbar_avg;
        Parambyname('LEVEL_DBAR_MAX').Value:=lev_dbar_max;
        Parambyname('VALUE_MIN').Value:=value_min;
        Parambyname('VALUE_AVG').Value:=value_avg;
        Parambyname('VALUE_MAX').Value:=value_max;
        Parambyname('VALUE_MIN_FLAG').Value:=value_min_flag;
        Parambyname('VALUE_AVG_FLAG').Value:=value_avg_flag;
        Parambyname('VALUE_MAX_FLAG').Value:=value_max_flag;
       ExecSQL;
      end;
          showmessage('written');
      TR.CommitRetaining; }

     end; // not empty
    end; //tbl

    {$ifdef WINDOWS}
      ProgressTaskbar(k, cnt);
    {$ENDIF}

    TR.CommitRetaining;

  {  if k mod 100=0 then begin
      //  TR_write.CommitRetaining;
        Pct := Trunc((k * 1.0 / cnt) * 100);
  //      Write(Format(StatusMsg, [k, cnt, Pct]));
    end;   }

   Q1_read.Next;
  end;

 // writeln();
// writeln('Done!');
 finally
 // ProgressTaskbar(0, 0);
  tbl_lst.Free;
  tmp_lst.Free;

  TR.Commit;
  Q1_read.Free;
  Q2_read.Free;
  Q3_read.Free;
  Q_write.Free;
  TR.Free;
 end;
end;

end.

