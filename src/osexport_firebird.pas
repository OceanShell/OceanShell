unit osexport_firebird;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  SQLDB, DB, IBConnection, LCLType;

type

  { Tfrmexport_firebird }

  Tfrmexport_firebird = class(TForm)
    btnExport: TButton;
    btnCreateDatabase: TButton;
    Button2: TButton;
    chkParameters: TCheckGroup;
    eTargetDB: TEdit;
    GroupBox1: TGroupBox;
    mLog: TMemo;

    procedure btnCreateDatabaseClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure eTargetDBChange(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    procedure WriteTable(Q_from, Q_to:TSQLQuery; tbl: string; ID:Int64; prof:boolean);
    procedure CreateParameter(S:TSQLScript; tbl: string);
  public

  end;

var
  frmexport_firebird: Tfrmexport_firebird;

implementation

uses osmain, dm, osqc_databaseinfo;

{$R *.lfm}

{ Tfrmexport_firebird }

procedure Tfrmexport_firebird.FormShow(Sender: TObject);
begin
 chkParameters.Items.Clear;
 chkParameters.Items:=frmosmain.ListBox1.Items;
  mLog.clear;
end;


procedure Tfrmexport_firebird.Button2Click(Sender: TObject);
begin
  frmosmain.OD.Filter:='Firebird database|*.FDB';
   if frmosmain.OD.Execute then
     eTargetDB.Text:=frmosmain.OD.FileName;
end;


procedure Tfrmexport_firebird.btnExportClick(Sender: TObject);
Var
 DB_to:TIBConnection;
 TR_to:TSQLTransaction;
 Q_from, Q_to:TSQLQuery;
 S:TSQLScript;

 k, c, cnt1, cnt2, str_cnt:integer;
 Ini_to, Ini_from: string;
 str1, str2: string;
 DBUser, DBPass, DBHost, DBPath: string;
 DateStart:TDateTime;
 fl_exit: boolean;
 tbl:string;
 tbl_arr:array of string;
 dbtbl_lst:TStringList;
 ID:int64;

 sl_platform, sl_source, sl_institute, sl_project, sl_parameter: TStringList;
begin
 mLog.clear;


  sl_parameter:=TStringList.Create;
  for k:=0 to chkParameters.Items.Count-1 do begin
   if chkParameters.Checked[k] then sl_parameter.Add(chkParameters.Items.Strings[k]);
  end;
  if sl_parameter.Count=0 then
    if MessageDlg('Select at least one parameter', mtWarning, [mbOk], 0)=mrOk then exit;


    DB_to:=TIBConnection.Create(nil);
    TR_to:=TSQLTransaction.Create(nil);
    DB_to.Transaction:=TR_to;
    TR_to.Database:=DB_to;

    S:=TSQLScript.Create(nil);
    S.Database:=DB_to;
    S.Transaction:=TR_to;

    Q_from:=TSQLQuery.Create(self);
    Q_from.Database:=frmdm.IBDB;
    Q_from.Transaction:=frmdm.TR;

    Q_to:=TSQLQuery.Create(self);
    Q_to.Database:=DB_to;
    Q_to.Transaction:=TR_to;


    with DB_to do begin
     Params.Clear;
     Connected:=false;
     UserName:='SYSDBA';
     Password:='masterkey';
     HostName:='localhost';
     DatabaseName:=eTargetDB.Text;
     Connected:=true;
    end;

    setlength(tbl_arr, 9);
    tbl_arr[0]:='COUNTRY';
    tbl_arr[1]:='INSTITUTE';
    tbl_arr[2]:='PROJECT';
    tbl_arr[3]:='FLAG_PQF1';
    tbl_arr[4]:='FLAG_PQF2';
    tbl_arr[5]:='FLAG_SQF';
    tbl_arr[6]:='FLAG_STATION';
    tbl_arr[7]:='UNITS';
    tbl_arr[8]:='INSTRUMENT';
  //  tbl_arr[9]:='SOURCE';

    for k:=0 to length(tbl_arr)-1 do WriteTable(Q_from, Q_to, tbl_arr[k], -9999, false);
    TR_to.CommitRetaining;

    sl_platform:=TStringList.Create;
    sl_platform.Sorted:=true;
    sl_platform.Duplicates:=dupIgnore;

    sl_source:=TStringList.Create;
    sl_source.Sorted:=true;
    sl_source.Duplicates:=dupIgnore;

    frmdm.QCruise.DisableControls;
    frmdm.QCruise.First;
    while not frmdm.QCruise.EOF do begin
      sl_platform.Add(Inttostr(frmdm.QCruise.FieldByName('platform_id').Value));
      sl_source.Add(Inttostr(frmdm.QCruise.FieldByName('source_id').Value));
     frmdm.QCruise.Next;
    end;

    for k:=0 to sl_platform.Count-1 do
      WriteTable(Q_from, Q_to, 'PLATFORM', StrToInt(sl_platform.Strings[k]), false);
    TR_to.CommitRetaining;

    for k:=0 to sl_source.Count-1 do
      WriteTable(Q_from, Q_to, 'SOURCE', StrToInt(sl_source.Strings[k]), false);
    TR_to.CommitRetaining;

    for k:=0 to sl_parameter.Count-1 do
      CreateParameter(S, sl_parameter.Strings[k]);
    TR_to.CommitRetaining;

    mLog.Lines.add('Processing CRUISE');
    frmdm.QCruise.First;
    while not frmdm.QCruise.EOF do begin
       WriteTable(Q_from, Q_to, 'CRUISE', frmdm.QCruise.FieldByName('ID').Value, false);
     frmdm.QCruise.Next;
    end;
    TR_to.CommitRetaining;

    mLog.Lines.add('Processing STATION');
    frmdm.Q.First;
    while not frmdm.Q.EOF do begin
       WriteTable(Q_from, Q_to, 'STATION', frmdm.Q.FieldByName('ID').Value, false);

       for k:=0 to sl_parameter.Count-1 do begin
         WriteTable(Q_from, Q_to, sl_parameter.Strings[k], frmdm.Q.FieldByName('ID').Value, true);
       end;

     frmdm.Q.Next;
    end;
    TR_to.CommitRetaining;

    mLog.Lines.add('Processing DATABASE_TABLES');
    for k:=0 to sl_parameter.Count-1 do begin
     With Q_from do begin
      Close;
        SQL.Clear;
        SQL.Add(' SELECT ID FROM DATABASE_TABLES ');
        SQL.Add(' WHERE NAME_TABLE= '+QuotedStr(sl_parameter.Strings[k]));
      Open;
        ID:=Q_from.Fields[0].Value;
      Close
     end;

      WriteTable(Q_from, Q_to, 'DATABASE_TABLES', ID, false);
    end;

 UpdateDatabaseInfo(DB_to);

 mLog.Lines.add('=====');
 mLog.Lines.add('Export completed!');

 Q_from.Close;
 Q_to.Close;
 TR_to.Commit;

 DB_to.Connected:=false;
 S.Free;
 Q_from.Free;
 Q_to.Free;
 TR_to.Free;
 DB_to.Free;
end;


procedure Tfrmexport_firebird.CreateParameter(S:TSQLScript; tbl: string);
Var
 script: string;
begin

script:=
 'CREATE TABLE '+tbl+' ('+
 '    ID              BIGINT NOT NULL,'+
 '    LEV_DBAR        DECIMAL(9,4) NOT NULL,'+
 '    LEV_M           DECIMAL(9,4) NOT NULL,'+
 '    VAL             DOUBLE PRECISION NOT NULL,'+
 '    PQF1            SMALLINT NOT NULL,'+
 '    PQF2            SMALLINT NOT NULL,'+
 '    SQF             SMALLINT NOT NULL,'+
 '    BOTTLE_NUMBER   SMALLINT,'+
 '    PROFILE_NUMBER  SMALLINT NOT NULL,'+
 '    PROFILE_BEST    BOOLEAN DEFAULT TRUE NOT NULL,'+
 '    UNITS_ID        SMALLINT NOT NULL,'+
 '    INSTRUMENT_ID   SMALLINT NOT NULL'+
 ');'+
 #13+
 'ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_1 FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE;'+
 'ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_2 FOREIGN KEY (INSTRUMENT_ID) REFERENCES INSTRUMENT (ID) ON UPDATE CASCADE;'+
 'ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_3 FOREIGN KEY (UNITS_ID) REFERENCES UNITS (ID) ON UPDATE CASCADE;'+
 'ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_4 FOREIGN KEY (PQF1) REFERENCES FLAG_PQF1 (ID) ON UPDATE CASCADE;'+
 'ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_5 FOREIGN KEY (PQF2) REFERENCES FLAG_PQF2 (ID) ON UPDATE CASCADE;'+
 'ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_6 FOREIGN KEY (SQF) REFERENCES FLAG_SQF (ID) ON UPDATE CASCADE;'+
 #13+
 'CREATE INDEX '+tbl+'_IDX1 ON '+tbl+' (ID, PROFILE_NUMBER, INSTRUMENT_ID);'+
 'CREATE INDEX '+tbl+'_IDX2 ON '+tbl+' (ID, INSTRUMENT_ID);'+
 'CREATE INDEX '+tbl+'_IDX3 ON '+tbl+' (ID, PROFILE_NUMBER);'+
 'CREATE DESCENDING INDEX '+tbl+'_IDX4 ON '+tbl+' (ID, LEV_DBAR, LEV_M);';

  S.Script.Text:=script;
  S.Execute;

end;

procedure Tfrmexport_firebird.WriteTable(Q_from, Q_to:TSQLQuery; tbl: string;
  ID:Int64; prof:boolean);
Var
  dbtbl_lst:TStringList;
  str1, str2: string;
  c:integer;
begin

 if ID<=-9999 then  mLog.Lines.add('Processing '+tbl);

  dbtbl_lst:=TStringList.Create;
  frmdm.IBDB.GetFieldNames(tbl, dbtbl_lst);

     str1:=' (';
     str2:=' (';
     for c:=0 to dbtbl_lst.Count-1 do begin
       str1:=str1+dbtbl_lst.Strings[c]+', ';
       str2:=str2+':'+dbtbl_lst.Strings[c]+', ';
     end;
     str1:=copy(str1,1,length(str1)-2)+')';
     str2:=copy(str2,1,length(str2)-2)+')';

  With Q_from do begin
   Close;
     SQL.Clear;
     SQL.Add(' SELECT * FROM '+tbl);
     if ID<>-9999 then begin
       SQL.Add(' WHERE ID=:ID ');
       ParamByName('ID').Value:=ID;
     end;
   Open;
  end;

  while not Q_from.EOF do begin
     With Q_to do begin
      Close;
        SQL.Clear;
        SQL.Add(' UPDATE OR INSERT INTO '+tbl);
        SQL.Add( str1 );
        SQL.Add(' VALUES ');
        SQL.Add( str2 );
        if not prof then
          SQL.Add(' MATCHING (ID) ') else
          SQL.Add(' MATCHING (ID,LEV_DBAR,PROFILE_NUMBER) ');
          for c:=0 to dbtbl_lst.Count-1 do
            ParamByName(dbtbl_lst.Strings[c]).Value:=Q_from.FieldByName(dbtbl_lst.Strings[c]).Value;
        ExecSQL;
      end;
   Q_from.Next;
  end;
  dbtbl_lst.Free;
end;


procedure Tfrmexport_firebird.eTargetDBChange(Sender: TObject);
begin
  btnExport.Enabled:=FileExists(eTargetDB.Text);
end;


procedure Tfrmexport_firebird.btnCreateDatabaseClick(Sender: TObject);
Var
 DBName, script_path : string;
 DB:TIBConnection;
 TR:TSQLTransaction;
 S:TSQLScript;
 FileStream: TResourceStream;
begin
 frmosmain.SD.InitialDir:=GlobalPath;
 frmosmain.SD.Filter:='*.FDB|*.FDB';
 if frmosmain.SD.Execute then DBName:=frmosmain.SD.FileName else Exit;

 try
    DB:=TIBConnection.Create(nil);
    TR:=TSQLTransaction.Create(nil);
    With DB do begin
     DB.DatabaseName:=DBName;
     DB.UserName:=frmdm.IBDB.UserName;
     DB.Password:=frmdm.IBDB.Password;
     DB.Params:=frmdm.IBDB.Params;
     DB.Transaction:=TR;
    end;
    TR.Database:=DB;

    S:=TSQLScript.Create(nil);
    S.Database:=DB;
    S.Transaction:=TR;

    DB.Connected:=false;
    DB.CreateDB;
    DB.Open;

    try
      FileStream := TResourceStream.Create(HInstance, 'OCEAN', RT_RCDATA);
      S.Script.LoadFromStream(FileStream);
    finally
      FileStream.Free;
    end;

  //  mlog.Lines.Add(S.Script.Text);

    S.Execute;
    TR.Commit;

    eTargetDB.Text:=DBName;
 finally
  DB.Close(false);
  S.Free;
  TR.Free;
  DB.Free;
 end;
end;

end.

