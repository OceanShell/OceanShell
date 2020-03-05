unit osstations;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, DBGrids,
  Menus, IniFiles, sortbufds, Windows, Grids;

type

  { Tfrmosstation }

  Tfrmosstation = class(TForm)
    btnadd: TToolButton;
    btncancel: TToolButton;
    btndelete: TToolButton;
    btnsave: TToolButton;
    DBGridStation: TDBGrid;
    iProfilesAll: TMenuItem;
    ishowselectedstation: TMenuItem;
    MenuItem8: TMenuItem;
    PM1: TPopupMenu;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;

    procedure DBGridStationCellClick(Column: TColumn);
    procedure DBGridStationKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGridStationPrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DBGridStationTitleClick(Column: TColumn);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);

  private

  public

  end;

var
  frmosstation: Tfrmosstation;

implementation

{$R *.lfm}

{ Tfrmosstation }

uses osmain, dm;

procedure Tfrmosstation.FormCreate(Sender: TObject);
Var
  Ini:TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
  try
    Top   :=Ini.ReadInteger( 'osstations', 'top',    50);
    Left  :=Ini.ReadInteger( 'osstations', 'left',   50);
    Width :=Ini.ReadInteger( 'osstations', 'width',  900);
    Height:=Ini.ReadInteger( 'osstations', 'weight', 500);
  finally
    Ini.Free;
  end;

  with DBGridStation do begin
    Columns[0].Width:=60;  //STATION ID
    Columns[1].Width:=60;  //CRUISE ID
    Columns[2].Width:=60;  //FLAG
    Columns[3].Width:=80;  //LATITUDE
    Columns[4].Width:=80;  //LONGITUDE
    Columns[5].Width:=130; //DATE
    Columns[6].Width:=60;  //DEPTH
    Columns[7].Width:=60;  //LAST_LEVEL_M
    Columns[8].Width:=60;  //LAST_LEVEL_DBAR
    Columns[9].Width:=60;  //ST_NUM
  end;
end;


procedure Tfrmosstation.DBGridStationCellClick(Column: TColumn);
begin
  frmosmain.CDSNavigation;
end;

procedure Tfrmosstation.DBGridStationKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key=VK_UP) or (key=VK_DOWN) then frmosmain.CDSNavigation;
end;

procedure Tfrmosstation.DBGridStationPrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
 if (column.FieldName='ID') or (column.FieldName='CRUISE_ID') then begin
    TDBGrid(sender).Canvas.Brush.Color := clBtnFace;
 end;

 if (gdSelected in AState) then begin
   TDBGrid(Sender).Canvas.Brush.Color := clNavy;
   TDBGrid(Sender).Canvas.Font.Color  := clYellow;
   TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
 end;
end;

procedure Tfrmosstation.DBGridStationTitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(frmdm.Q, Column.FieldName);
end;


procedure Tfrmosstation.FormClose(Sender: TObject; var CloseAction: TCloseAction);
Var
  Ini:TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
   try
    Ini.WriteInteger( 'osstations', 'top',    Top);
    Ini.WriteInteger( 'osstations', 'left',   Left);
    Ini.WriteInteger( 'osstations', 'width',  Width);
    Ini.WriteInteger( 'osstations', 'weight', Height);
   finally
     Ini.Free;
   end;

  frmstations_open:=false;
end;

end.

