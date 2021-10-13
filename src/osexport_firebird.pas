unit osexport_firebird;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  SQLDB, DB, IBConnection;

type

  { Tfrmexport_firebird }

  Tfrmexport_firebird = class(TForm)
    btnExportFirebird: TButton;
    Button2: TButton;
    eExportDB: TEdit;
    GroupBox1: TGroupBox;
    mLog: TMemo;
    procedure btnExportFirebirdClick(Sender: TObject);
//    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure chlbVariablesItemClick(Sender: TObject; Index: integer);
    procedure FormShow(Sender: TObject);

  private

  public

  end;

var
  frmexport_firebird: Tfrmexport_firebird;

implementation

uses osmain, dm, oscreatenewdb;

{$R *.lfm}

{ Tfrmexport_firebird }

procedure Tfrmexport_firebird.FormShow(Sender: TObject);
begin
 // chlbVariables.Items.Clear;
 // chlbVariables.Items:=frmosmain.ListBox1.Items;
end;


procedure Tfrmexport_firebird.Button2Click(Sender: TObject);
begin
  frmosmain.OD.Filter:='Firebird database|*.FDB';
   if frmosmain.OD.Execute then
     eExportDB.Text:=frmosmain.OD.FileName;
end;


procedure Tfrmexport_firebird.btnExportFirebirdClick(Sender: TObject);
Var
 DB_to:TIBConnection;
 TR_to:TSQLTransaction;
 Q1_to, Q2_to:TSQLQuery;
 ID, k, c, cnt1, cnt2, str_cnt:integer;
 Ini_to, Ini_from: string;
 str1, str2: string;
 DBUser, DBPass, DBHost, DBPath: string;
 DateStart:TDateTime;
 fl_exit: boolean;
 tbl:string;
 tbl_arr:array of string;
 dbtbl_lst:TStringList;
begin

    DB_to:=TIBConnection.Create(nil);
    TR_to:=TSQLTransaction.Create(nil);

    DB_to.Transaction:=TR_to;
    TR_to.Database:=DB_to;

    Q1_to:=TSQLQuery.Create(self);
    Q1_to.Database:=DB_to;
    Q1_to.Transaction:=TR_to;

    Q2_to:=TSQLQuery.Create(self);
    Q2_to.Database:=DB_to;
    Q2_to.Transaction:=TR_to;


    with DB_to do begin
     Params.Clear;
     Connected:=false;
     UserName:='SYSDBA';
     Password:='masterkey';
     HostName:='localhost';
     DatabaseName:=eExportDB.Text;
     Connected:=true;
    end;

  setlength(tbl_arr, frmosmain.ListBox1.Count+2);
  tbl_arr[0]:='CRUISE';
  tbl_arr[1]:='STATION';

  for k:=0 to frmosmain.ListBox1.Count-1 do
    tbl_arr[k+2]:=frmosmain.ListBox1.Items.Strings[k];

//  for k:=0 to high(tbl_arr) do mLog.Lines.add(tbl_arr[k]);


  try
  frmdm.QCruise.DisableControls;
  frmdm.Q.DisableControls;
  DateStart:=now;

  for k:=0 to high(tbl_arr) do begin
   mLog.Lines.add('Processing '+tbl_arr[k]);

   if k=0 then frmdm.q1:=frmdm.QCruise;
   if k>=1 then frmdm.q1:=frmdm.Q;

    dbtbl_lst:=TStringList.Create;
    frmdm.IBDB.GetFieldNames(tbl_arr[k], dbtbl_lst);

      str1:=' (';
      str2:=' (';
      for c:=0 to dbtbl_lst.Count-1 do begin
        str1:=str1+dbtbl_lst.Strings[c]+', ';
        str2:=str2+':'+dbtbl_lst.Strings[c]+', ';
      end;
      str1:=copy(str1,1,length(str1)-2)+')';
      str2:=copy(str2,1,length(str2)-2)+')';

    str_cnt:=0;
    frmdm.q1.First;
    while not frmdm.q1.EOF do begin
      With frmdm.q2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' SELECT * FROM '+tbl_arr[k]+' WHERE ID=:ID');
         ParamByName('ID').Value:=frmdm.q1.FieldByName('ID').Value;
        Open;
       end;

      if not frmdm.q2.IsEmpty then begin
      With Q1_to do begin
       Close;
         SQL.Clear;
         SQL.Add(' INSERT INTO '+tbl_arr[k]);
         SQL.Add( str1 );
         SQL.Add(' VALUES ');
         SQL.Add( str2 );
           for c:=0 to dbtbl_lst.Count-1 do
             ParamByName(dbtbl_lst.Strings[c]).Value:=frmdm.q2.FieldByName(dbtbl_lst.Strings[c]).Value;
         ExecSQL;
       end;

       inc(str_cnt);
       end;
      frmdm.q2.Close;

      frmdm.q1.Next;
    end;
   // TR_to.CommitRetaining;
    mLog.Lines.add('Rows written: '+inttostr(str_cnt));
    dbtbl_lst.Free;
  end;

  finally
   frmdm.QCruise.EnableControls;
   frmdm.Q.EnableControls;
  end;


 Q1_to.Close;
 Q2_to.Close;
 TR_to.Commit;

 DB_to.Connected:=false;

 Q1_to.Free;
 Q2_to.Free;
 TR_to.Free;
 DB_to.Free;
end;


procedure Tfrmexport_firebird.chlbVariablesItemClick(Sender: TObject;
  Index: integer);
Var
 k:integer;
 fl:boolean;
begin
{  fl:=false;
  for k:=0 to chlbVariables.Items.Count-1 do
    if chlbVariables.Checked[k] then fl:=true;

 btnExportFirebird.Enabled:=fl; }
end;

end.

