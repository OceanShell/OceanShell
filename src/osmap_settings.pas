unit osmap_settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ColorBox,
  StdCtrls, ComCtrls, Spin, IniFiles, osmap_globctrl;

type

  { Tfrmosmap_settings }

  Tfrmosmap_settings = class(TForm)
    btnSave: TButton;
    btnReset: TButton;
    chkShowStars: TCheckBox;
    ColorPointerBorder: TColorBox;
    ColorPointerInner: TColorBox;
    ColorMapBackground: TColorBox;
    ColorSelectionCross: TColorBox;
    ColorLand: TColorBox;
    ColorLandContour: TColorBox;
    ColorGlobeDisc: TColorBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    PageControl1: TPageControl;
    rgPointerSize: TRadioGroup;
    seZoomStep: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;

    procedure btnResetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);

  private

  public

  end;

var
  frmosmap_settings: Tfrmosmap_settings;

implementation

{$R *.lfm}

uses osmain;

{ Tfrmosmap_settings }

procedure Tfrmosmap_settings.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
begin
   Ini := TIniFile.Create(IniFileName);
  try
    rgPointerSize.ItemIndex     :=Ini.ReadInteger( 'osmap', 'pointer_size', 2);
    seZoomStep.Value            :=Ini.ReadInteger( 'osmap', 'zoom_step', 50);
    chkShowStars.Checked        :=Ini.ReadBool   ( 'osmap', 'show_stars', true);
    ColorPointerInner.Selected  :=StringToColor(Ini.ReadString( 'osmap', 'pointer_inner_color',   'clYellow'));
    ColorPointerBorder.Selected :=StringToColor(Ini.ReadString( 'osmap', 'pointer_border_color',  'clBlack'));
    ColorSelectionCross.Selected:=StringToColor(Ini.ReadString( 'osmap', 'selection_cross_color', 'clRed'));
    ColorMapBackground.Selected :=StringToColor(Ini.ReadString( 'osmap', 'map_background_color',  'clNavy'));
    ColorGlobeDisc.Selected     :=StringToColor(Ini.ReadString( 'osmap', 'globe_disc_color',      'clAqua'));
    ColorLand.Selected          :=StringToColor(Ini.ReadString( 'osmap', 'land_color',            '$00D000')); //Light Green
    ColorLandContour.Selected   :=StringToColor(Ini.ReadString( 'osmap', 'land_contour_color',    '$004000')); //Dark Green
  finally
    Ini.Free;
  end;
end;


procedure Tfrmosmap_settings.btnResetClick(Sender: TObject);
begin
  rgPointerSize.ItemIndex     :=2;
  seZoomStep.Value            :=50;
  chkShowStars.Checked        :=true;
  ColorPointerInner.Selected  :=clYellow;
  ColorPointerBorder.Selected :=clBlack;
  ColorSelectionCross.Selected:=clRed;
  ColorMapBackground.Selected :=clNavy;
  ColorGlobeDisc.Selected     :=clAqua;
  ColorLand.Selected          :=TColor($00D000); //Light Green
  ColorLandContour.Selected   :=TColor($004000); //Dark Green
end;



procedure Tfrmosmap_settings.btnSaveClick(Sender: TObject);
Var
  Ini:TIniFile;
begin
   Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger( 'osmap', 'pointer_size',          rgPointerSize.ItemIndex);
    Ini.WriteInteger( 'osmap', 'zoom_step',             seZoomStep.Value);
    Ini.WriteBool   ( 'osmap', 'show_stars',            chkShowStars.Checked);
    Ini.WriteString ( 'osmap', 'pointer_inner_color',   ColorToString(ColorPointerInner.Selected));
    Ini.WriteString ( 'osmap', 'pointer_border_color',  ColorToString(ColorPointerBorder.Selected));
    Ini.WriteString ( 'osmap', 'selection_cross_color', ColorToString(ColorSelectionCross.Selected));
    Ini.WriteString ( 'osmap', 'map_background_color',  ColorToString(ColorMapBackground.Selected));
    Ini.WriteString ( 'osmap', 'globe_disc_color',      ColorToString(ColorGlobeDisc.Selected));
    Ini.WriteString ( 'osmap', 'land_color',            ColorToString(ColorLand.Selected));
    Ini.WriteString ( 'osmap', 'land_contour_color',    ColorToString(ColorLandContour.Selected));

  finally
    Ini.Free;
  end;
  Close;
end;


end.

