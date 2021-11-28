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

    procedure Button1Click(Sender: TObject);
    procedure cbDatabasesSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCreateDBClick(Sender: TObject);
    procedure chlbVariablesItemClick(Sender: TObject; Index: integer);

  private
    procedure PopulateSupportTables(dbname:string);
  public
    function  GetDDL(DBAlias:string):boolean;
    procedure ProcessDDL;
    procedure AddTblNew(tbl:string);
    procedure AddTblScript(tbl:string);
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
  DBUser, DBPass, DBHost, DBPath: string;
  k:integer;
  TempList:TListBox;
begin
try
   DB:=TIBConnection.Create(nil);
   TR:=TSQLTransaction.Create(nil);

   DB.Transaction:=TR;
   TR.Database:=DB;

   DBAlias:=cbDatabases.text;

   DBIni := TIniFile.Create(IniFileName+'_db');
   try
     DBUser :=DBIni.ReadString(DBAlias, 'user',     'SYSDBA');
     DBPass :=DBIni.ReadString(DBAlias, 'pass',     'masterkey');
     DBHost :=DBIni.ReadString(DBAlias, 'host',     'localhost');
     DBPath :=DBIni.ReadString(DBAlias, 'dbpath',   '');
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

   try
   TempList:=TListBox.Create(self);
   DB.GetTableNames(TempList.Items,False);

    for k:=0 to TempList.Items.Count-1 do
     if (copy(TempList.Items.Strings[k], 1, 2)='P_') then
       chlbVariables.Items.Add(TempList.Items.Strings[k]);
   finally
     TempList.Free;
   end;

 finally
  TR.Commit;
  TR.Free;
  DB.Connected:=false;
  DB.Free;
 end;

 for k:=0 to chlbVariables.Items.Count-1 do chlbVariables.Checked[k]:=true;
end;



procedure Tfrmcreatenewdb.Button1Click(Sender: TObject);
var
  k:integer;
begin
    (* tables from the list *)
  for k:=0 to chlbVariables.Items.Count-1 do
    if chlbVariables.Checked[k]=true then
      AddTblScript(chlbVariables.Items.Strings[k]);
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
function Tfrmcreatenewdb.GetDDL(DBAlias:string):boolean;
var
  DBIni: TIniFile;
  lReg : TRegistry;
  FBPath, cmd, ScriptFile: String;
  DBUser, DBPass, DBHost, DBPath: string;
begin
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
    DBIni := TIniFile.Create(IniFileName+'_db');
    try
      DBUser :=DBIni.ReadString(DBAlias, 'user',     'SYSDBA');
      DBPass :=DBIni.ReadString(DBAlias, 'pass',     'masterkey');
      DBHost :=DBIni.ReadString(DBAlias, 'host',     'localhost');
      DBPath :=DBIni.ReadString(DBAlias, 'dbpath',   '');
    finally
      DBIni.Free;
    end;

  (* Getting DDL from OCEAN.FDB *)
  ScriptFile:=GlobalUnloadPath+'TMP.SQL';
  DeleteFile(ScriptFile);

  cmd:=FBPath+'isql -ex -o '+
       ScriptFile+' '+
       DBHost+':'+DBPath+
       ' -user '+DBUser+
       ' -pass '+DBPass;

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
      AddTblScript(chlbVariables.Items.Strings[k]);

  (* new tables *)
  if trim(eNewDB.Text)<>'' then begin
    c:=0;
   repeat
    buf_str:='';
    repeat
      inc(c);
       if eNewDB.Text[c]<>';' then buf_str:=buf_str+eNewDB.Text[c];
    until (eNewDB.Text[c]=';') or (c=length(eNewDB.Text));

    AddTblNew(trim(buf_str));
   until (c>=length(eNewDB.Text));
  end;


  AssignFile(dat, GlobalUnloadPath+'OCEAN.SQL'); append(dat);
    writeln(dat,'COMMIT WORK;');
  CloseFile(dat);
end;

procedure Tfrmcreatenewdb.AddTblScript(tbl:string);
Var
  dat1, out1:text;
  st:string;
begin
  AssignFile(dat1, GlobalUnloadPath+PathDelim+'TMP.SQL'); reset(dat1);
  AssignFile(out1, GlobalUnloadPath+'OCEAN.SQL'); append(out1);

  st:='';
  repeat
    readln(dat1, st);
  until (copy(st, 14, length(tbl)) = tbl);

 { if eof(dat1) then begin
   showmessage('not found: '+tbl);
   closefile(dat1);
   closefile(out1);
   exit;
  end;   }

  repeat
     if trim(st)<>'' then writeln(out1, st);
   readln(dat1, st);
  until trim(st)='';

  writeln(out1,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_1 FOREIGN KEY (ID) REFERENCES STATION (ID) ON UPDATE CASCADE ON DELETE CASCADE;');
  writeln(out1,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_2 FOREIGN KEY (INSTRUMENT_ID) REFERENCES INSTRUMENT (ID) ON UPDATE CASCADE;');
  writeln(out1,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_3 FOREIGN KEY (UNITS_ID) REFERENCES UNITS (ID) ON UPDATE CASCADE;');
  writeln(out1,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_4 FOREIGN KEY (PQF1) REFERENCES FLAG_PQF1 (ID) ON UPDATE CASCADE;');
  writeln(out1,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_5 FOREIGN KEY (PQF2) REFERENCES FLAG_PQF2 (ID) ON UPDATE CASCADE;');
  writeln(out1,'   ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_6 FOREIGN KEY (SQF) REFERENCES FLAG_SQF (ID) ON UPDATE CASCADE;');
  writeln(out1,'');

  CloseFile(dat1);
  CloseFile(out1);
end;

procedure Tfrmcreatenewdb.AddTblNew(tbl: string);
Var
  dat:text;
begin
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
 if not GetDDL(cbDatabases.Text) then
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
k, i, c:integer;
DBUser, DBPass, DBHost, DBPath, tbl, st, str1, str2: string;

dat:text;
dbtbl_lst:TStringList;
tbl_arr:array of string;
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

   SetLength(tbl_arr, 13);
   tbl_arr[0] :='COUNTRY';
   tbl_arr[1] :='INSTITUTE';
   tbl_arr[2] :='INSTRUMENT';
   tbl_arr[3] :='PROJECT';
   tbl_arr[4] :='SOURCE';
   tbl_arr[5] :='UNITS';
   tbl_arr[6] :='PLATFORM';
   tbl_arr[7] :='DATABASE_TABLES';
   tbl_arr[8] :='ENTRY_TYPE';
   tbl_arr[9] :='FLAG_STATION';
   tbl_arr[10]:='FLAG_PQF1';
   tbl_arr[11]:='FLAG_PQF2';
   tbl_arr[12]:='FLAG_SQF';

   (* loop over tables we'd like to populate *)
   for k:=0 to high(tbl_arr) do begin

     //getting fields for every table
      dbtbl_lst:=TStringList.Create;
      DB_OCEAN.GetFieldNames(tbl_arr[k], dbtbl_lst);

       str1:=' (';
       str2:=' (';
       for c:=0 to dbtbl_lst.Count-1 do begin
         str1:=str1+dbtbl_lst.Strings[c]+', ';
         str2:=str2+' :'+dbtbl_lst.Strings[c]+', ';
       end;
       str1:=copy(str1,1,length(str1)-2)+')';
       str2:=copy(str2,1,length(str2)-2)+')';

        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM '+tbl_arr[k]+' ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO '+tbl_arr[k]);
             SQL.Add( str1 );
             SQL.Add(' VALUES ');
             SQL.Add( str2 );
              for c:=0 to dbtbl_lst.Count-1 do
               ParamByName(dbtbl_lst.Strings[c]).Value:=Q_OCEAN.FieldByName(dbtbl_lst.Strings[c]).Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;

       dbtbl_lst.Free;
   //   showmessage(tbl);
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
  Tbl_arr:=nil;
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

  {  frmdm.IBDB.Close;
    frmdm.IBDB.DatabaseName:=frmosmain.SD.FileName;
    frmosmain.OpenLocalDatabase(frmdm.IBDB.DatabaseName); }
  frmcreatenewdb.Enabled:=true;
  Close;
 end;
end;


end.

