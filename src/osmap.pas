unit osmap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  osmain, dm, DB, osmap_kml, procedures, osmap_globctrl, osmap_datastreams,
  osmap_settings;

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
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    btnSettings: TToolButton;
    btnSaveMapAs: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;

    procedure btnSaveMapAsClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnShowAllStationsClick(Sender: TObject);
    procedure btnShowSelectedClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnZoomInClick(Sender: TObject);
    procedure btnZoomOutClick(Sender: TObject);
    procedure ChangeID(ID:integer);
    procedure FormDestroy(Sender: TObject);

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

  MainGlobe.CheckSettings;

  btnKMLExport.Enabled:=CheckKML;
end;

procedure Tfrmmap.ChangeID(ID:integer);
begin
  MainGlobe.ChangeID(ID);
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

procedure Tfrmmap.btnSaveMapAsClick(Sender: TObject);
Var
  bmp : TBitmap;
  png : TPortableNetworkGraphic;
  Src: TRect;
  Dest: TRect;
begin
frmosmain.SD.DefaultExt:='.bmp';
frmosmain.SD.Filter:='Bitmap|*.bmp';

 if frmosmain.SD.Execute then begin
   try
     bmp := TBitmap.Create;
     bmp.Width :=pmap.Width;
     bmp.Height:=pmap.Height;

     Dest:= Rect(0, 0, pmap.Width, pmap.Height);
     Src := Rect(0, 0, pmap.Width, pmap.Height);

     bmp.Canvas.CopyRect(Dest, pmap.Canvas, Src);
     bmp.SaveToFile(frmosmain.SD.FileName);
  finally
    bmp.Free;
  end;
 end;

{  png := TPortableNetworkGraphic.Create;
  try
    png.Assign(FBufferBitmap);
    png.SaveToFile(fname);
  finally
    png.Free;
  end; }
end;


procedure Tfrmmap.btnSettingsClick(Sender: TObject);
begin
 frmosmap_settings := Tfrmosmap_settings.Create(Self);
  try
   if not frmosmap_settings.ShowModal = mrOk then exit;
  finally
    frmosmap_settings.Free;
    frmosmap_settings := nil;
    MainGlobe.CheckSettings;
    ChangeID(frmdm.Q.FieldByName('ID').AsInteger);
  end;
end;


procedure Tfrmmap.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 frmmap_open:=false;
end;

procedure Tfrmmap.FormDestroy(Sender: TObject);
begin
 MainGlobe.Destroy;
end;

end.

