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
    ColorPointerBorderCruise: TColorBox;
    ColorPointerInner: TColorBox;
    ColorMapBackground: TColorBox;
    ColorPointerInnerCruise: TColorBox;
    ColorLand: TColorBox;
    ColorLandContour: TColorBox;
    ColorGlobeDisc: TColorBox;
    ColorSelectionCross: TColorBox;
    GroupBox1: TGroupBox;
    GroupBox10: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    GroupBox9: TGroupBox;
    PageControl1: TPageControl;
    rgPointerSize: TRadioGroup;
    rgPointerSizeCruise: TRadioGroup;
    seZoomStep: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;

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
    seZoomStep.Value            :=Ini.ReadInteger( 'osmap', 'zoom_step', 50);
    chkShowStars.Checked        :=Ini.ReadBool   ( 'osmap', 'show_stars', true);

    rgPointerSize.ItemIndex     :=Ini.ReadInteger( 'osmap', 'pointer_size', 2);
    ColorPointerInner.Selected  :=StringToColor(Ini.ReadString( 'osmap', 'pointer_inner_color',   'clRed'));
    ColorPointerBorder.Selected :=StringToColor(Ini.ReadString( 'osmap', 'pointer_border_color',  'clBlack'));

    rgPointerSizeCruise.ItemIndex     :=Ini.ReadInteger( 'osmap', 'pointer_size_cruise', 2);
    ColorPointerInnerCruise.Selected  :=StringToColor(Ini.ReadString( 'osmap', 'pointer_inner_color_cruise',   'clYellow'));
    ColorPointerBorderCruise.Selected :=StringToColor(Ini.ReadString( 'osmap', 'pointer_border_color_cruise',  'clBlack'));

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
  seZoomStep.Value            :=50;
  chkShowStars.Checked        :=true;

  rgPointerSize.ItemIndex     :=2;
  ColorPointerInner.Selected  :=clRed;
  ColorPointerBorder.Selected :=clBlack;

  rgPointerSizeCruise.ItemIndex     :=2;
  ColorPointerInnerCruise.Selected  :=clYellow;
  ColorPointerBorderCruise.Selected :=clBlack;

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
    Ini.WriteInteger( 'osmap', 'zoom_step',             seZoomStep.Value);
    Ini.WriteBool   ( 'osmap', 'show_stars',            chkShowStars.Checked);

    Ini.WriteInteger( 'osmap', 'pointer_size',          rgPointerSize.ItemIndex);
    Ini.WriteString ( 'osmap', 'pointer_inner_color',   ColorToString(ColorPointerInner.Selected));
    Ini.WriteString ( 'osmap', 'pointer_border_color',  ColorToString(ColorPointerBorder.Selected));

    Ini.WriteInteger( 'osmap', 'pointer_size_cruise',          rgPointerSizeCruise.ItemIndex);
    Ini.WriteString ( 'osmap', 'pointer_inner_color_cruise',   ColorToString(ColorPointerInnerCruise.Selected));
    Ini.WriteString ( 'osmap', 'pointer_border_color_cruise',  ColorToString(ColorPointerBorderCruise.Selected));

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

