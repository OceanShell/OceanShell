unit oscreatenewdb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  IBConnection, SQLDB, DB, IniFiles, Registry;

type

  { Tfrmcreatenewdb }

  Tfrmcreatenewdb = class(TForm)
    btnCreateDB: TButton;
    chlbVariables: TCheckGroup;
    cbDatabases: TComboBox;
    eNewDB: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;

    procedure cbDatabasesSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCreateDBClick(Sender: TObject);
    procedure chlbVariablesItemClick(Sender: TObject; Index: integer);

  private
    procedure PopulateSupportTables(dbname:string);
  public
    function  GetDDL:boolean;
    procedure ProcessDDL;
    procedure AddTbl(tbl:string);
    procedure CreateNewDB(dbname:string);
  end;

var
  frmcreatenewdb: Tfrmcreatenewdb;
  DBOcean:string;

implementation

{$R *.lfm}

{ Tfrmcreatenewdb }

uses osmain, dm;


procedure Tfrmcreatenewdb.FormShow(Sender: TObject);
Var
Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
cbDatabases.Clear;
 try
   if Ini.SectionExists('DB') then Ini.ReadSection('DB', cbDatabases.Items);
  finally
   Ini.Free;
 end;
end;


procedure Tfrmcreatenewdb.cbDatabasesSelect(Sender: TObject);
Var
  DBIni: TIniFile;
  DB:TIBConnection;
  TR:TSQLTransaction;
  Q:TSQLQuery;
  DBUser, DBPass, DBHost, DBPath: string;
begin
try
   DB:=TIBConnection.Create(nil);
   TR:=TSQLTransaction.Create(nil);

   DB.Transaction:=TR;
   TR.Database:=DB;

   Q:=TSQLQuery.Create(self);
   Q.Database:=DB;
   Q.Transaction:=TR;

   DBIni := TIniFile.Create(IniFileName+'_db');
   try
     DBUser :=DBIni.ReadString(cbDatabases.text, 'user',     'SYSDBA');
     DBPass :=DBIni.ReadString(cbDatabases.text, 'pass',     'masterkey');
     DBHost :=DBIni.ReadString(cbDatabases.text, 'host',     'localhost');
     DBPath :=DBIni.ReadString(cbDatabases.text, 'dbpath',   '');
   finally
     DBIni.Free;
   end;

   with DB do begin
     Connected:=false;
     UserName:=DBUser;
     Password:=DBPass;
     HostName:=DBHost;
     DatabaseName:=DBPath;
     Connected:=true;
   end;

    With Q do begin
      Close;
        SQL.Clear;
        SQL.Add(' SELECT NAME_TABLE FROM DATABASE_TABLES ');
        SQL.Add(' ORDER BY NAME_TABLE ');
      Open;
    end;

    chlbVariables.Items.Clear;
    while not Q.eof do begin
     chlbVariables.Items.Add(Q.Fields[0].AsString);
     Q.Next;
    end;
    Q.Close;
 finally
  Q.Free;
  TR.Commit;
  TR.Free;
  DB.Connected:=false;
  DB.Free;
 end;
end;

procedure Tfrmcreatenewdb.chlbVariablesItemClick(Sender: TObject; Index: integer);
Var
 k:integer;
 fl:boolean;
begin
 fl:=false;
  for k:=0 to chlbVariables.Items.Count-1 do
    if chlbVariables.Checked[k] then fl:=true;
 btnCreateDB.Enabled:=fl;
end;


(* Creating NEW EMPTY database EXACTLY like OCEAN.FDB *)
function Tfrmcreatenewdb.GetDDL:boolean;
var
  Ini: TIniFile;
  lReg : TRegistry;
  FBPath, OceanPath, cmd, ScriptFile: String;
begin

//showmessage('here');

  (* Looking for installed Firebird *)
  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_LOCAL_MACHINE;
    lReg.Access:= KEY_READ;
    If lReg.OpenKey('\SOFTWARE\Firebird Project\Firebird Server\Instances', False) Then
      FBPath := lReg.ReadString('DefaultInstance');
    lReg.CloseKey;
  finally
    FreeAndNil(lReg);
  end;

  (* Path to Ocean.FDB *)
  Ini := TIniFile.Create(IniFileName);
  try
   OceanPath:=Ini.ReadString( 'main', 'OceanFDBPath',  '');
  finally
    Ini.free;
  end;

  (* Getting DDL from OCEAN.FDB *)
  ScriptFile:=GlobalUnloadPath+'TMP.SQL';
  DeleteFile(ScriptFile);

  cmd:=FBPath+'isql -ex -o '+
       ScriptFile+' '+
       OceanPath+' -user sysdba -pass masterkey';

  frmosmain.RunScript(0, cmd, nil);

  Result:=FileExists(ScriptFile);
end;

procedure Tfrmcreatenewdb.ProcessDDL;
Var
  dat, out1:text;
  st, buf_str:string;
  k, c:integer;
begin
  try
   AssignFile(dat,  GlobalUnloadPath+'TMP.SQL'); reset(dat);
   AssignFile(out1, GlobalUnloadPath+'OCEAN.SQL'); rewrite(out1);

   //skipping DB creation part
   for k:=1 to 9 do readln(dat, st);

   repeat
    readln(dat, st);
    if (copy(st, 1, 15)<>'CREATE TABLE P_') and
       (copy(st, 1, 15)<>'CREATE INDEX P_') and
       (copy(st, 1, 26)<>'CREATE DESCENDING INDEX P_') and
       (copy(st, 1, 14)<>'ALTER TABLE P_') and
       (copy(st, 1, 12)<>'COMMIT WORK;') then
          if trim(st)<>'' then writeln(out1, st);

    if (copy(st, 1, 15)='CREATE TABLE P_') then begin
     repeat
       readln(dat, st);
     until trim(st)='';
    end;

   until eof(dat);
  finally
    CloseFile(dat);
    CloseFile(out1);
  end;

  (* tables from the list *)
  for k:=0 to chlbVariables.Items.Count-1 do
    if chlbVariables.Checked[k]=true then
      AddTbl(chlbVariables.Items.Strings[k]);

  (* new tables *)
  if trim(eNewDB.Text)<>'' then begin
    c:=0;
   repeat
    buf_str:='';
    repeat
      inc(c);
       if eNewDB.Text[c]<>';' then buf_str:=buf_str+eNewDB.Text[c];
    until (eNewDB.Text[c]=';') or (c=length(eNewDB.Text));

    AddTbl(trim(buf_str));
   until (c>=length(eNewDB.Text));
  end;


  AssignFile(dat, GlobalUnloadPath+'OCEAN.SQL'); append(dat);
    writeln(dat,'COMMIT WORK;');
  CloseFile(dat);
end;

procedure Tfrmcreatenewdb.AddTbl(tbl:string);
Var
  dat:text;
begin
   (* adding tables *)
  AssignFile(dat, GlobalUnloadPath+'OCEAN.SQL'); append(dat);

     writeln(dat,'CREATE TABLE '+tbl+' (ID BIGINT NOT NULL, ');
     writeln(dat,'   LEV_DBAR DECIMAL(9, 4) NOT NULL, ');
     writeln(dat,'   LEV_M DECIMAL(9, 4) NOT NULL, ');
     writeln(dat,'   VAL DOUBLE PRECISION NOT NULL, ');
     writeln(dat,'   PQF1 SMALLINT NOT NULL, ');
     writeln(dat,'   PQF2 SMALLINT NOT NULL, ');
     writeln(dat,'   SQF SMALLINT NOT NULL, ');
     writeln(dat,'   BOTTLE_NUMBER SMALLINT, ');
     writeln(dat,'   PROFILE_NUMBER INTEGER NOT NULL, ');
     writeln(dat,'   PROFILE_BEST BOOLEAN DEFAULT TRUE NOT NULL, ');
     writeln(dat,'   UNITS_ID SMALLINT NOT NULL, ');
     writeln(dat,'   INSTRUMENT_ID SMALLINT NOT NULL); ');
     writeln(dat,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_1 FOREIGN KEY (ID) REFERENCES STATION (ID) ON UPDATE CASCADE ON DELETE CASCADE;');
     writeln(dat,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_2 FOREIGN KEY (INSTRUMENT_ID) REFERENCES INSTRUMENT (ID) ON UPDATE CASCADE;');
     writeln(dat,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_3 FOREIGN KEY (UNITS_ID) REFERENCES UNITS (ID) ON UPDATE CASCADE;');
     writeln(dat,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_4 FOREIGN KEY (PQF1) REFERENCES FLAG_PQF1 (ID) ON UPDATE CASCADE;');
     writeln(dat,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_5 FOREIGN KEY (PQF2) REFERENCES FLAG_PQF2 (ID) ON UPDATE CASCADE;');
     writeln(dat,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_6 FOREIGN KEY (SQF) REFERENCES FLAG_SQF (ID) ON UPDATE CASCADE;');
     writeln(dat,'');
  CloseFile(dat);
end;


(* Creating new DB *)
procedure Tfrmcreatenewdb.CreateNewDB(dbname:string);
Var
DB:TIBConnection;
TR:TSQLTransaction;
SC:TSQLScript;
begin

(* extracting structure from OCEAN.FDB *)
 if not(GetDDL) then
  if MessageDlg('Unable to extract DDL', mtWarning, [mbOk], 0)=mrOk then exit;

 ProcessDDL;

 try
 (* Creating database *)
   DB:=TIBConnection.Create(nil);
   TR:=TSQLTransaction.Create(nil);
   SC:=TSQLScript.Create(nil);

    DB.Transaction:=TR;
    TR.Database:=DB;
    SC.Transaction:=TR;
    SC.Database:=DB;
    SC.CommentsInSQL:=false;

    DB.DatabaseName:=(dbname);
    DB.UserName:='SYSDBA';
    DB.Password:='masterkey';
     With DB.Params do begin
      Clear;
       Add('SET SQL DIALECT 3');
       Add('SET NAMES UTF8');
       Add('PAGE_SIZE 16384');
       Add('DEFAULT CHARACTER SET UTF8 COLLATION UTF8');
     end;
    DB.CreateDB;
    DB.Connected:=False;
    DB.LoginPrompt:=False;
    DB.Open;

    SC.Script.LoadFromFile(GlobalUnloadPath+'OCEAN.SQL');
   // showmessage(SC.Script.Text);

    SC.UseCommit:=true;
    SC.UseSetTerm:=true; // for Firebird ONLY
    SC.CommentsInSQL:=false;
     try
      SC.Execute;
      TR.Commit;
     except
      on E: EDataBaseError do begin
        ShowMessage('Error running script: '+E.Message);
        TR.Rollback;
      end;
     end;

 finally
  SC.Free;
  TR.Free;
  DB.Free;
 end;
end;


(* Copying support data from OCEAN.FDB into the NEW database *)
procedure Tfrmcreatenewdb.PopulateSupportTables(dbname:string);
Var
DBIni:TIniFIle;
DB_NEW, DB_OCEAN:TIBConnection;
TR_NEW, TR_OCEAN:TSQLTransaction;
Q_NEW, Q_OCEAN:TSQLQuery;
k:integer;
DBUser, DBPass, DBHost, DBPath: string;
begin
 try

   (* Opening NEW database *)
   DB_NEW:=TIBConnection.Create(nil);
   TR_NEW:=TSQLTransaction.Create(nil);
   Q_NEW:=TSQLQuery.Create(nil);

   DB_NEW.Transaction:=TR_NEW;
   TR_NEW.Database:=DB_NEW;
   Q_NEW.Transaction:=TR_NEW;
   Q_NEW.Database:=DB_NEW;

   DB_NEW.DatabaseName:=(dbname);
   DB_NEW.UserName:='SYSDBA';
   DB_NEW.Password:='masterkey';
   DB_NEW.LoginPrompt:=False;
   DB_NEW.Connected:=True;

   (* Opening OCEAN.FDB database *)
   DB_OCEAN:=TIBConnection.Create(nil);
   TR_OCEAN:=TSQLTransaction.Create(nil);
   Q_OCEAN:=TSQLQuery.Create(nil);

   DB_OCEAN.Transaction:=TR_OCEAN;
   TR_OCEAN.Database:=DB_OCEAN;
   Q_OCEAN.Transaction:=TR_OCEAN;
   Q_OCEAN.Database:=DB_OCEAN;

   DBIni := TIniFile.Create(IniFileName+'_db');
     try
       DBUser :=DBIni.ReadString(cbDatabases.text, 'user',     'SYSDBA');
       DBPass :=DBIni.ReadString(cbDatabases.text, 'pass',     'masterkey');
       DBHost :=DBIni.ReadString(cbDatabases.text, 'host',     'localhost');
       DBPath :=DBIni.ReadString(cbDatabases.text, 'dbpath',   '');
     finally
       DBIni.Free;
     end;

     with DB_OCEAN do begin
       Connected:=false;
       UserName:=DBUser;
       Password:=DBPass;
       HostName:=DBHost;
       DatabaseName:=DBPath;
       Connected:=true;
     end;


   for k:=1 to 9 do begin
     case k of
      1: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM COUNTRY ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO COUNTRY ');
             SQL.Add(' (ID, NODC_CODE, ISO3166_CODE, NAME, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NODC_CODE, :ISO3166_CODE, :NAME, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NODC_CODE').Value:=Q_OCEAN.FieldByName('NODC_CODE').Value;
             ParamByName('ISO3166_CODE').Value:=Q_OCEAN.FieldByName('ISO3166_CODE').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      2: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM INSTITUTE ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO INSTITUTE ');
             SQL.Add(' (ID, NODC_CODE, WOD_ID, NAME, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NODC_CODE, :WOD_ID, :NAME, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NODC_CODE').Value:=Q_OCEAN.FieldByName('NODC_CODE').Value;
             ParamByName('WOD_ID').Value:=Q_OCEAN.FieldByName('WOD_ID').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
            // ParamByName('NAME_FULL').Value:=Q_OCEAN.FieldByName('NAME_FULL').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;
      3:begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM INSTRUMENT ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO INSTRUMENT ');
             SQL.Add(' (ID, WOD_ID, NAME, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :WOD_ID, :NAME, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('WOD_ID').Value:=Q_OCEAN.FieldByName('WOD_ID').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      4: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM PROJECT ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO PROJECT ');
             SQL.Add(' (ID, WOD_ID, NAME, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :WOD_ID, :NAME, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('WOD_ID').Value:=Q_OCEAN.FieldByName('WOD_ID').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
            // ParamByName('NAME_FULL').Value:=Q_OCEAN.FieldByName('NAME_FULL').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      5: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM SOURCE ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO SOURCE ');
             SQL.Add(' (ID, NAME, STATION_ID_MIN, STATION_ID_MAX, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NAME, :STATION_ID_MIN, :STATION_ID_MAX, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('STATION_ID_MIN').Value:=Q_OCEAN.FieldByName('STATION_ID_MIN').Value;
             ParamByName('STATION_ID_MAX').Value:=Q_OCEAN.FieldByName('STATION_ID_MAX').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      6: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM UNITS ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO UNITS ');
             SQL.Add(' (ID, NAME_SHORT, NAME, LENGTH, SCALE, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NAME_SHORT, :NAME, :LENGTH, :SCALE, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NAME_SHORT').Value:=Q_OCEAN.FieldByName('NAME_SHORT').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('LENGTH').Value:=Q_OCEAN.FieldByName('LENGTH').Value;
             ParamByName('SCALE').Value:=Q_OCEAN.FieldByName('SCALE').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      7: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM PLATFORM ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO PLATFORM ');
             SQL.Add(' (ID, NODC_CODE, WOD_ID, IMO_ID, CALLSIGN, NAME, ');
             SQL.Add(' NAME_NATIVE, COUNTRY_ID, DATE_ADDED, DATE_UPDATED, ');
             SQL.Add(' NOTES, NOTES_ICES, NOTES_WOD) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NODC_CODE, :WOD_ID, :IMO_ID, :CALLSIGN, :NAME, ');
             SQL.Add(' :NAME_NATIVE, :COUNTRY_ID, :DATE_ADDED, :DATE_UPDATED, ');
             SQL.Add(' :NOTES, :NOTES_ICES, :NOTES_WOD) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NODC_CODE').Value:=Q_OCEAN.FieldByName('NODC_CODE').Value;
             ParamByName('WOD_ID').Value:=Q_OCEAN.FieldByName('WOD_ID').Value;
             ParamByName('IMO_ID').Value:=Q_OCEAN.FieldByName('IMO_ID').Value;
             ParamByName('CALLSIGN').Value:=Q_OCEAN.FieldByName('CALLSIGN').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('NAME_NATIVE').Value:=Q_OCEAN.FieldByName('NAME_NATIVE').Value;
             ParamByName('COUNTRY_ID').Value:=Q_OCEAN.FieldByName('COUNTRY_ID').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('NOTES_ICES').Value:=Q_OCEAN.FieldByName('NOTES_ICES').Value;
             ParamByName('NOTES_WOD').Value:=Q_OCEAN.FieldByName('NOTES_WOD').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      8: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM DATABASE_TABLES ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO DATABASE_TABLES ');
             SQL.Add(' (ID, NAME_TABLE, NAME, UNITS_ID_DEFAULT, NOTES, ');
             SQL.Add(' DATE_ADDED, DATE_UPDATED) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NAME_TABLE, :NAME, :UNITS_ID_DEFAULT, :NOTES, ');
             SQL.Add(' :DATE_ADDED, :DATE_UPDATED) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NAME_TABLE').Value:=Q_OCEAN.FieldByName('NAME_TABLE').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('UNITS_ID_DEFAULT').Value:=Q_OCEAN.FieldByName('UNITS_ID_DEFAULT').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
         end;
         TR_OCEAN.CommitRetaining;
        end;

        9: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM ENTRY_TYPE ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO ENTRY_TYPE ');
             SQL.Add(' (ID, NAME, DESCRIPTION) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NAME, :DESCRIPTION) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('DESCRIPTION').Value:=Q_OCEAN.FieldByName('DESCRIPTION').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
      end;
      TR_OCEAN.CommitRetaining;
     end; //9
    end; //end of case
   end; // 1-9

 finally
  TR_NEW.Commit;
  TR_OCEAN.Commit;
  Q_NEW.Free;
  Q_OCEAN.Free;
  TR_NEW.Free;
  TR_OCEAN.Free;
  DB_NEW.Connected:=false;
  DB_NEW.Free;
  DB_OCEAN.Connected:=false;
  DB_OCEAN.Free;
 end;

end;



procedure Tfrmcreatenewdb.btnCreateDBClick(Sender: TObject);
begin
frmosmain.SD.Filter:='Firebird database|*.FDB';
frmosmain.SD.DefaultExt:='FDB';
 if frmosmain.SD.Execute then begin
  frmcreatenewdb.Enabled:=false;
  Application.ProcessMessages;

   CreateNewDB(frmosmain.SD.FileName);
   PopulateSupportTables(frmosmain.SD.FileName);

    frmdm.IBDB.Close;
    frmdm.IBDB.DatabaseName:=frmosmain.SD.FileName;
    frmosmain.OpenLocalDatabase(frmdm.IBDB.DatabaseName);
  frmcreatenewdb.Enabled:=true;
  Close;
 end;
end;


end.

