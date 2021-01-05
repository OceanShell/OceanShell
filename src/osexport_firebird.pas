unit osexport_firebird;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { Tfrmexport_firebird }

  Tfrmexport_firebird = class(TForm)
    btnExportFirebird: TButton;
    chlbVariables: TCheckGroup;
    procedure btnExportFirebirdClick(Sender: TObject);
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
  chlbVariables.Items.Clear;
  chlbVariables.Items:=frmosmain.ListBox1.Items;
end;

procedure Tfrmexport_firebird.btnExportFirebirdClick(Sender: TObject);
begin
  frmosmain.SD.Filter:='Firebird database|*.FDB';
  frmosmain.SD.DefaultExt:='FDB';
   if frmosmain.SD.Execute then begin
    btnExportFirebird.Enabled:=false;
    Application.ProcessMessages;

     frmcreatenewdb.CreateNewDB(frmosmain.SD.FileName);
    // PopulateSupportTables(frmosmain.SD.FileName);

      frmdm.IBDB.Close;
      frmdm.IBDB.DatabaseName:=frmosmain.SD.FileName;
      frmosmain.OpenLocalDatabase(frmdm.IBDB.DatabaseName);

    btnExportFirebird.Enabled:=true;
    Application.ProcessMessages;
    Close;
   end;
end;

procedure Tfrmexport_firebird.chlbVariablesItemClick(Sender: TObject;
  Index: integer);
Var
 k:integer;
 fl:boolean;
begin
  fl:=false;
  for k:=0 to chlbVariables.Items.Count-1 do
    if chlbVariables.Checked[k] then fl:=true;

 btnExportFirebird.Enabled:=fl;
end;

end.

