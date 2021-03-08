unit osopendb_reg;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IniFiles;

type

  { Tfrmopendb_reg }

  Tfrmopendb_reg = class(TForm)
    btnSave: TButton;
    btnOpenDB: TButton;
    ePath: TEdit;
    eHost: TEdit;
    ePass: TEdit;
    eAlias: TEdit;
    eUser: TEdit;
    GroupBox8: TGroupBox;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;

    procedure btnSaveClick(Sender: TObject);
    procedure btnOpenDBClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure ShowDBSettings(alias_str:string);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmopendb_reg: Tfrmopendb_reg;

implementation

{$R *.lfm}

Uses osmain, dm, osopendb;

procedure Tfrmopendb_reg.FormShow(Sender: TObject);
begin
 // F.Width := W - 2*(LCLIntf.GetSystemMetrics(SM_CYSIZEFRAME));
 //     F.Height := H - (LCLIntf.GetSystemMetrics(SM_CYCAPTION) + 2*LCLIntf.GetSystemMetrics(SM_CYSIZEFRAME));
 //     F.Left := Screen.WorkAreaLeft + W*J;
 //     F.Top := Screen.WorkAreaTop + H*I;

// showmessage(inttostr(LCLIntf.GetSystemMetrics(SM_CYSIZEFRAME)));
  Left:=frmopendb.Left+frmopendb.Width;//+(LCLIntf.GetSystemMetrics(SM_CYSIZEFRAME));
  Top:=frmopendb.Top;
end;

procedure Tfrmopendb_reg.ShowDBSettings(alias_str:string);
Var
  DBIni:TIniFile;
begin
 DBIni := TIniFile.Create(IniFileName+'_db');
 try
   eHost.text  :=DBIni.ReadString(alias_str, 'host',     'localhost');
   ePath.text  :=DBIni.ReadString(alias_str, 'dbpath',   '');
   eUser.text  :=DBIni.ReadString(alias_str, 'user',     'SYSDBA');
   ePass.text  :=DBIni.ReadString(alias_str, 'pass',     'masterkey');
   eAlias.text :=alias_str;
 finally
   DBIni.Free;
 end;
end;

procedure Tfrmopendb_reg.btnSaveClick(Sender: TObject);
Var
  Ini, DBIni: TIniFile;
begin
 if eHost.Text='' then
   if MessageDlg('Insert host name / IP address', mtWarning, [mbOk], 0)=mrOk then exit;
 if ePath.Text='' then
   if MessageDlg('Insert database name / full path', mtWarning, [mbOk], 0)=mrOk then exit;
 if eUser.Text='' then
   if MessageDlg('Insert user name', mtWarning, [mbOk], 0)=mrOk then exit;
 if ePass.Text='' then
   if MessageDlg('Insert user password', mtWarning, [mbOk], 0)=mrOk then exit;
 if eAlias.Text='' then
   if MessageDlg('Insert database alias', mtWarning, [mbOk], 0)=mrOk then exit;

  Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteString('DB', eAlias.Text, '');
  finally
    Ini.Free;
  end;

  DBIni := TIniFile.Create(IniFileName+'_db');
  try
    DBIni.WriteString (eAlias.Text, 'dbpath',   ePath.Text);
    DBIni.WriteString (eAlias.Text, 'host',     eHost.Text);
    DBIni.WriteString (eAlias.Text, 'user',     eUser.Text);
    DBIni.WriteString (eAlias.Text, 'pass',     epass.Text);
  finally
    DBIni.Free;
  end;

  frmopendb.RefreshDBList;

  Close;
end;

procedure Tfrmopendb_reg.btnOpenDBClick(Sender: TObject);
Var
FName:string;
begin
frmosmain.OD.Filter := 'Firebird database|*.FDB;*.fdb';
 if frmosmain.OD.Execute then begin
   ePath.Text:=frmosmain.OD.FileName;
   FName:=ExtractFileName(frmosmain.OD.FileName);
   eAlias.Text:=FName;
 end;
end;

procedure Tfrmopendb_reg.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  frmopendbreg_open:=false;
end;


end.
