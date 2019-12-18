unit osmap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  osmain, dm, DB, osmap_kml, procedures, osmap_globctrl, osmap_datastreams;

type

  { Tfrmmap }

  Tfrmmap = class(TForm)
    MainGlobe : TGlobeControl;
    pmap: TPanel;
    ToolBar1: TToolBar;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    btnKMLExport: TToolButton;
    btnShowSelected: TToolButton;
    btnShowAllStations: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;

    procedure btnShowAllStationsClick(Sender: TObject);
    procedure btnShowSelectedClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure ChangeID;

  private

  public

  end;

var
  frmmap: Tfrmmap;


implementation

{$R *.lfm}

{ Tfrmmap }



procedure Tfrmmap.FormCreate(Sender: TObject);
begin


  // Loading the globe
  MainGlobe := TGlobeControl.Create(Self);
  MainGlobe.Align := alClient;
  MainGlobe.Parent := pmap;

  MainGlobe.Marker.Lat := frmdm.Q.FieldByName('LATITUDE').AsFloat;
  MainGlobe.Marker.Lon := frmdm.Q.FieldByName('LONGITUDE').AsFloat;

  btnKMLExport.Enabled:=CheckKML;
end;

procedure Tfrmmap.ChangeID;
begin
  MainGlobe.ChangeID;
End;

procedure Tfrmmap.btnShowAllStationsClick(Sender: TObject);
begin
  MainGlobe.ShowAllStations;
end;

procedure Tfrmmap.btnShowSelectedClick(Sender: TObject);
begin
  MainGlobe.ShowSelectedStation;
end;

procedure Tfrmmap.btnZoomInClick(Sender: TObject);
begin
  MainGlobe.ZoomIn;
end;

procedure Tfrmmap.btnZoomOutClick(Sender: TObject);
begin
  MainGlobe.ZoomOut;
end;


procedure Tfrmmap.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 frmmap_open:=false;
end;


end.

