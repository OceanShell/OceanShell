program UpdateStationParameters;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, IniFiles, SQLDB, DB, IBConnection, Variants, Math
  { you can add units after this };

type

  { TUpdateStationParameters }

  TUpdateStationParameters = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
  end;

{ TUpdateStationParameters }

procedure TUpdateStationParameters.DoRun;
const
  StatusMsg = #13'Updated stations: %d of %d (%d%%) ...';
Var
  Ini: TIniFile;
  DB_read, DB_write:TIBConnection;
  TR_read, TR_write:TSQLTransaction;
  Q1_read,  Q2_read, Q3_read:TSQLQuery;
  Q_write:TSQLQuery;

  ID, ID_MIN, ID_MAX, tbl_id, k, ci1, cnt, Pct:integer;
  tmp_lst, tbl_lst:TStringList;
  AppPath, IniFileName, DBAlias, DBUser, DBPass, DBHost, DBPath, tbl: string;

  cnt_prof, cnt_lev: Variant;
  Lev_m_min, Lev_m_avg, Lev_m_max, Lev_dbar_min, Lev_dbar_avg, Lev_dbar_max:Variant;
  Value_min, Value_avg, Value_max, Value_min_flag, Value_avg_flag, Value_max_flag:Variant;
begin

  AppPath:= ExtractFilePath(ParamStr(0));

  IniFileName:=GetUserDir+'.climateshell_db';
  if not FileExists(IniFileName) then begin
    writeln('Ini file is not found');
    halt;
  end;

  if HasOption('d','db')    then DBAlias:=trim(GetOptionValue('d','db')) else DBAlias:='';
  if HasOption('b','idmin') then ID_MIN:=StrToInt(trim(GetOptionValue('b','idmin'))) else ID_MIN:=-9999;
  if HasOption('e','idmax') then ID_MAX:=StrToInt(trim(GetOptionValue('e','idmax'))) else ID_MAX:=-9999;

  if DBAlias='' then begin
    writeln('Database is not specified');
    halt;
  end;

  if (ID_MIN=-9999) or (ID_MAX=-9999) then begin
    writeln('ID_MIN and ID_MAX not specified');
    halt;
  end;

  Ini := TIniFile.Create(IniFileName);
  try
    DBUser :=Ini.ReadString(DBAlias, 'user',     'SYSDBA');
    DBPass :=Ini.ReadString(DBAlias, 'pass',     'masterkey');
    DBHost :=Ini.ReadString(DBAlias, 'host',     'localhost');
    DBPath :=Ini.ReadString(DBAlias, 'dbpath',   '');
  finally
    Ini.Free;
  end;


  (* transaction for reading *)
   DB_read:=TIBConnection.Create(nil);
   TR_read:=TSQLTransaction.Create(nil);
     with TR_read.Params do begin
       Clear;
        Add('isc_tpb_read');
        Add('isc_tpb_read_committed');
        Add('isc_tpb_nowait');
        Add('isc_tpb_rec_version');
     end;
   DB_read.Transaction:=TR_read;
   TR_read.Database:=DB_read;

   Q1_read:=TSQLQuery.Create(self);
   Q1_read.Database:=DB_read;
   Q1_read.Transaction:=TR_read;

   Q2_read:=TSQLQuery.Create(self);
   Q2_read.Database:=DB_read;
   Q2_read.Transaction:=TR_read;

   Q3_read:=TSQLQuery.Create(self);
   Q3_read.Database:=DB_read;
   Q3_read.Transaction:=TR_read;

     (* transaction for writing *)
     DB_write:=TIBConnection.Create(nil);
     TR_write:=TSQLTransaction.Create(nil);

     DB_write.Transaction:=TR_write;
     TR_write.Database:=DB_write;

     Q_write:=TSQLQuery.Create(self);
     Q_write.Database:=DB_write;
     Q_write.Transaction:=TR_write;

   Ini := TIniFile.Create(AppPath+'database.ini');
   try
     DBUser :=Ini.ReadString('firebird', 'user',     'SYSDBA');
     DBPass :=Ini.ReadString('firebird', 'pass',     'masterkey');
     DBHost :=Ini.ReadString('firebird', 'host',     'localhost');
     DBPath :=Ini.ReadString('firebird', 'dbpath',   '');
   finally
     Ini.Free;
   end;

 //  writeln(DBPath);

   with DB_read do begin
    Params.Clear;
    Connected:=false;
    UserName:=DBUser;
    Password:=DBPass;
    HostName:=DBHost;
    DatabaseName:=DBPath;
    Connected:=true;
   end;

   with DB_write do begin
    Params.Clear;
    Connected:=false;
    UserName:=DBUser;
    Password:=DBPass;
    HostName:=DBHost;
    DatabaseName:=DBPath;
    Connected:=true;
   end;

   writeln('Database connected ');
   writeln('Updating stations from '+
           inttostr(ID_MIN)+' to '+
           inttostr(ID_MAX));

   tmp_lst:=TStringList.Create;
   tbl_lst:=TStringList.Create;
   DB_read.GetTableNames(tmp_lst,False);

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
  writeln('Stations to update: '+inttostr(cnt));

  with Q_write do begin
   Close;
    SQL.Clear;
    SQL.Add(' DELETE FROM STATION_PARAMETERS ');
    SQL.Add(' WHERE STATION_ID BETWEEN :ID_MIN AND :ID_MAX ');
    ParamByName('ID_MIN').Value:=ID_MIN;
    ParamByName('ID_MAX').Value:=ID_MAX;
   ExecSQL;
  end;
  TR_write.CommitRetaining;
  writeln('Old records removed');

  k:=0;
  While not Q1_read.Eof do begin
   inc(k);
    ID:=Q1_read.FieldByName('ID').Value;

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

    With Q_write do begin
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

     end; // not empty
    end; //tbl

    if k mod 100=0 then begin
        TR_write.CommitRetaining;
        Pct := Trunc((k * 1.0 / cnt) * 100);
        Write(Format(StatusMsg, [k, cnt, Pct]));
    end;

   Q1_read.Next;
  end;

  writeln();
  writeln('Done!');

  tbl_lst.Free;
  tmp_lst.Free;

  TR_read.Commit;
  Q1_read.Free;
  Q2_read.Free;
  DB_read.Connected:=false;
  TR_read.Free;
  DB_read.Free;

  TR_write.Commit;
  Q_write.Free;
  DB_write.Connected:=false;
  TR_write.Free;
  DB_write.Free;

  // stop program loop
  Terminate;
end;

var
  Application: TUpdateStationParameters;
begin
  Application:=TUpdateStationParameters.Create(nil);
  Application.Title:='UpdateStationParameters';
  Application.Run;
  Application.Free;
end.

