unit osmap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  osmain, dm, DB, osmap_globctrl, osmap_kml, procedures;

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
    ToolButton2: TToolButton;

    procedure btnKMLExportClick(Sender: TObject);
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
  DSMap: TDataSource;

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

procedure Tfrmmap.btnShowSelectedClick(Sender: TObject);
begin
 With MainGlobe do begin
   Location.Lat := frmdm.Q.FieldByName('LATITUDE').AsFloat;
   Location.Lon := frmdm.Q.FieldByName('LONGITUDE').AsFloat;
   Center := Location;
   ReCenter;
 end;
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

procedure Tfrmmap.btnKMLExportClick(Sender: TObject);
begin
  ExportKML_;
end;

end.

