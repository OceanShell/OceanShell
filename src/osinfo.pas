unit osinfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { Tfrminfo }

  Tfrminfo = class(TForm)
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frminfo: Tfrminfo;

implementation

{$R *.lfm}

{ Tfrminfo }

uses osmain;

procedure Tfrminfo.FormShow(Sender: TObject);
begin
  frminfo_open:=true;
end;

procedure Tfrminfo.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  frminfo_open:=false;
end;


end.

