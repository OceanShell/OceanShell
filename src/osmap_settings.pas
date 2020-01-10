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
    ColorPointerBorder: TColorBox;
    ColorPointerInner: TColorBox;
    ColorSelectionCross: TColorBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    rgPointerSize: TRadioGroup;
    seZoomStep: TSpinEdit;

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
    rgPointerSize.ItemIndex:=Ini.ReadInteger( 'osmap', 'pointer_size', 4);
    seZoomStep.Value :=Ini.ReadInteger( 'osmap', 'zoom_step', 50);
    ColorPointerInner.Selected  :=StringToColor(Ini.ReadString( 'osmap', 'pointer_inner_color',   'clYellow'));
    ColorPointerBorder.Selected :=StringToColor(Ini.ReadString( 'osmap', 'pointer_border_color',  'clBlack'));
    ColorSelectionCross.Selected:=StringToColor(Ini.ReadString( 'osmap', 'selection_cross_color', 'clRed'));
  finally
    Ini.Free;
  end;
end;



procedure Tfrmosmap_settings.btnSaveClick(Sender: TObject);
Var
  Ini:TIniFile;
begin
   Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger( 'osmap', 'pointer_size', rgPointerSize.ItemIndex);
    Ini.WriteInteger( 'osmap', 'zoom_step', seZoomStep.Value);
    Ini.WriteString ( 'osmap', 'pointer_inner_color',   ColorToString(ColorPointerInner.Selected));
    Ini.WriteString ( 'osmap', 'pointer_border_color',  ColorToString(ColorPointerBorder.Selected));
    Ini.WriteString ( 'osmap', 'selection_cross_color', ColorToString(ColorSelectionCross.Selected));
  finally
    Ini.Free;
  end;
  Close;
end;


end.

