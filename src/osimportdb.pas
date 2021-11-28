unit osimportdb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, IniFiles;

type

  { Tfrmimportdb }

  Tfrmimportdb = class(TForm)
    btnStart: TButton;
    cbDBFrom: TComboBox;
    chkWrite: TCheckBox;
    GroupBox1: TGroupBox;
    mLog: TMemo;
    procedure btnStartClick(Sender: TObject);
    procedure cbDBFromSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmimportdb: Tfrmimportdb;

implementation

{$R *.lfm}

{ Tfrmimportdb }

uses osmain;

procedure Tfrmimportdb.FormShow(Sender: TObject);
Var
Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
cbDBFrom.Clear;
 try
   if Ini.SectionExists('DB') then Ini.ReadSection('DB', cbDBFrom.Items);
  finally
   Ini.Free;
 end;
end;


procedure Tfrmimportdb.cbDBFromSelect(Sender: TObject);
begin
  btnStart.Enabled:=true;
end;

procedure Tfrmimportdb.btnStartClick(Sender: TObject);
Var
  cmd:string;
begin
 cmd:=OceanToolsPath+'ImportNewSource.exe -a '+DBAlias+' -d '+cbDBFrom.Text;

  if chkWrite.Checked=true then cmd:=cmd+' -w';
   frmosmain.RunScript(0, cmd, mLog);
end;

end.

