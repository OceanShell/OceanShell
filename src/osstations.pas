unit osstations;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, DBGrids,
  Menus, IniFiles, sortbufds, Windows, Grids, ExtCtrls;

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
    MenuItem1: TMenuItem;
    iUpdateLastLevel: TMenuItem;
    MenuItem8: TMenuItem;
    Panel1: TPanel;
    PM1: TPopupMenu;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    btnMap: TToolButton;
    btnAllProfiles: TToolButton;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGridStationCellClick(Column: TColumn);
    procedure DBGridStationKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGridStationPrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DBGridStationTitleClick(Column: TColumn);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure iUpdateLastLevelClick(Sender: TObject);


  private

  public

  end;

var
  frmosstation: Tfrmosstation;

implementation

{$R *.lfm}

{ Tfrmosstation }

uses osmain, dm, osservice;

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

    with DBGridStation do begin
     Columns[0].Width :=Ini.ReadInteger( 'osstations', 'col0',    60);  //STATION ID
     Columns[1].Width :=Ini.ReadInteger( 'osstations', 'col1',    60);  //CRUISE ID
     Columns[2].Width :=Ini.ReadInteger( 'osstations', 'col2',    60);  //FLAG
     Columns[3].Width :=Ini.ReadInteger( 'osstations', 'col3',    80);  //LATITUDE
     Columns[4].Width :=Ini.ReadInteger( 'osstations', 'col4',    80);  //LONGITUDE
     Columns[5].Width :=Ini.ReadInteger( 'osstations', 'col5',   130);  //DATE
     Columns[6].Width :=Ini.ReadInteger( 'osstations', 'col6',    60);  //DEPTH
     Columns[7].Width :=Ini.ReadInteger( 'osstations', 'col7',    60);  //LAST_LEVEL_M
     Columns[8].Width :=Ini.ReadInteger( 'osstations', 'col8',    60);  //LAST_LEVEL_DBAR
     Columns[9].Width :=Ini.ReadInteger( 'osstations', 'col9',    60);  //ST_NUM
     Columns[10].Width:=Ini.ReadInteger( 'osstations', 'col10',   60);  //CAST
     Columns[11].Width:=Ini.ReadInteger( 'osstations', 'col11',   60);  //ACESSION
     Columns[12].Width:=Ini.ReadInteger( 'osstations', 'col12',   60);  //ST_NUM_ORIGIN
     Columns[13].Width:=Ini.ReadInteger( 'osstations', 'col13',   60);  //INSTRUMENT
     Columns[14].Width:=Ini.ReadInteger( 'osstations', 'col14',   60);  //VERSION
     Columns[15].Width:=Ini.ReadInteger( 'osstations', 'col15',   60);  //MERGED
    end;

  finally
    Ini.Free;
  end;

end;


procedure Tfrmosstation.FormShow(Sender: TObject);
begin
  frmosstation.onResize(self);
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
  if (column.FieldName='ID') or
     (column.FieldName='CRUISE_ID') or
     (column.FieldName='DATE_ADDED') or
     (column.FieldName='DATE_UPDATED') then
    TDBGrid(sender).Canvas.Brush.Color :=clBtnFace;

  if gdRowHighlight in AState then begin
    TDBGrid(sender).Canvas.Brush.Color := clNavy;
    TDBGrid(sender).Canvas.Font.Color:= clYellow;
    TDBGrid(sender).Canvas.Font.Style:=[fsBold];
  end;
end;


procedure Tfrmosstation.DBGridStationTitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(frmdm.Q, Column.FieldName);
end;


procedure Tfrmosstation.FormResize(Sender: TObject);
begin
 panel1.Width:=frmosstation.Width-250;
 Application.ProcessMessages;
end;

procedure Tfrmosstation.iUpdateLastLevelClick(Sender: TObject);
begin
  osservice.UpdateLastLevel;
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

    with DBGridStation do begin
     Ini.WriteInteger( 'osstations', 'col0',  Columns[0].Width);  //STATION ID
     Ini.WriteInteger( 'osstations', 'col1',  Columns[1].Width);  //CRUISE ID
     Ini.WriteInteger( 'osstations', 'col2',  Columns[2].Width);  //FLAG
     Ini.WriteInteger( 'osstations', 'col3',  Columns[3].Width);  //LATITUDE
     Ini.WriteInteger( 'osstations', 'col4',  Columns[4].Width);  //LONGITUDE
     Ini.WriteInteger( 'osstations', 'col5',  Columns[5].Width);  //DATE
     Ini.WriteInteger( 'osstations', 'col6',  Columns[6].Width);  //DEPTH
     Ini.WriteInteger( 'osstations', 'col7',  Columns[7].Width);  //LAST_LEVEL_M
     Ini.WriteInteger( 'osstations', 'col8',  Columns[8].Width);  //LAST_LEVEL_DBAR
     Ini.WriteInteger( 'osstations', 'col9',  Columns[9].Width);  //ST_NUM
     Ini.WriteInteger( 'osstations', 'col10', Columns[10].Width); //CAST
     Ini.WriteInteger( 'osstations', 'col11', Columns[11].Width); //ACESSION
     Ini.WriteInteger( 'osstations', 'col12', Columns[12].Width); //ST_NUM_ORIGIN
     Ini.WriteInteger( 'osstations', 'col13', Columns[13].Width); //INSTRUMENT
     Ini.WriteInteger( 'osstations', 'col14', Columns[14].Width); //VERSION
     Ini.WriteInteger( 'osstations', 'col15', Columns[15].Width); //MERGED
    end;

   finally
     Ini.Free;
   end;

  frmstations_open:=false;
end;

end.

