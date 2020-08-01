unit ossettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, IniFiles;

type

  { Tfrmsettings }

  Tfrmsettings = class(TForm)
    btnGrapherPath: TButton;
    btnOk: TButton;
    btnSupportPath: TButton;
    btnOceanFDBPath: TButton;
    btnSurferPath: TButton;
    btnUnloadPath: TButton;
    btnGEBCOPath: TButton;
    eGrapherPath: TEdit;
    eSupportPath: TEdit;
    eOceanFDBPath: TEdit;
    eSurferPath: TEdit;
    eUnloadPath: TEdit;
    eGEBCOPath: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    GroupBox9: TGroupBox;
    Label1: TLabel;
    lbKML: TLabel;
    mAdvancedSettings: TMemo;
    PageControl1: TPageControl;
    rgDepth: TRadioGroup;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;

    procedure btnGEBCOPathClick(Sender: TObject);
    procedure btnOceanFDBPathClick(Sender: TObject);
    procedure btnSupportPathClick(Sender: TObject);
    procedure btnUnloadPathClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnGrapherPathClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnSurferPathClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);

  private
    { private declarations }
    procedure CheckExistence;
  public
    { public declarations }
  end;

var
  frmsettings: Tfrmsettings;

implementation

{$R *.lfm}

uses osmain, procedures, osbathymetry;

{ Tfrmsettings }

procedure Tfrmsettings.FormShow(Sender: TObject);
Var
 Ini:TIniFile;
 SurferDefault, GrapherDefault, GEBCODefault:string;
begin
 SurferDefault :='c:\Program Files\Golden Software\Surfer 13\Scripter\Scripter.exe';
 GrapherDefault:='c:\Program Files\Golden Software\Grapher 11\Scripter\Scripter.exe';
 GEBCODefault :=GlobalPath+'support'+PathDelim+'bathymetry'+PathDelim+'GEBCO_2020.nc';

  Ini := TIniFile.Create(IniFileName);
  try
   eOceanFDBPath.Text     :=Ini.ReadString  ( 'main', 'OceanFDBPath',     GlobalPath+'databases'+PathDelim+'OCEAN.FDB');
   eSupportPath.Text      :=Ini.ReadString  ( 'main', 'SupportPath',      GlobalPath+'support'+PathDelim);
   eUnloadPath.Text       :=Ini.ReadString  ( 'main', 'UnloadPath',       GlobalPath+'unload'+PathDelim);
   eSurferPath.Text       :=Ini.ReadString  ( 'main', 'SurferPath',       SurferDefault);
   eGrapherPath.Text      :=Ini.ReadString  ( 'main', 'GrapherPath',      GrapherDefault);
   eGEBCOPath.Text        :=Ini.ReadString  ( 'main', 'GEBCOPath',        GEBCODefault);
   //rgLanguage.ItemIndex   :=Ini.ReadInteger ( 'main', 'Language',         0);
   rgDepth.ItemIndex      :=Ini.ReadInteger ( 'main', 'Depth_units',      0);
  finally
    ini.Free;
  end;
   (* Check if there is KML support *)
   if checkKML=true then begin
     lbKML.Caption:=SYes;
     lbKML.Font.Color:=clGreen;
   end;
   if checkKML=false then begin
     lbKML.Caption:=SNo;
     lbKML.Font.Color:=clRed;
   end;

   CheckExistence;
end;

procedure Tfrmsettings.CheckExistence;
begin
  if FileExists(eOceanFDBPath.Text)     then eOceanFDBPath.Font.Color :=clGreen else eOceanFDBPath.Font.Color:=clRed;
  if DirectoryExists(eSupportPath.Text) then eSupportPath.Font.Color  :=clGreen else eSupportPath.Font.Color :=clRed;
  if DirectoryExists(eUnloadPath.Text)  then eUnloadPath.Font.Color   :=clGreen else eUnloadPath.Font.Color  :=clRed;
  if FileExists(eGEBCOPath.Text)        then eGEBCOPath.Font.Color    :=clGreen else eGEBCOPath.Font.Color   :=clRed;
  if FileExists(eSurferPath.Text)       then eSurferPath.Font.Color   :=clGreen else eSurferPath.Font.Color  :=clRed;
  if FileExists(eGrapherPath.Text)      then eGrapherPath.Font.Color  :=clGreen else eGrapherPath.Font.Color :=clRed;
end;

procedure Tfrmsettings.PageControl1Change(Sender: TObject);
begin
  mAdvancedSettings.Lines.LoadFromFile(IniFileName);
end;

procedure Tfrmsettings.btnOceanFDBPathClick(Sender: TObject);
begin
 frmosmain.OD.Filter:='Ocean.fdb|OCEAN.FDB';
  if frmosmain.OD.Execute then eOceanFDBPath.Text:= frmosmain.OD.FileName;
 CheckExistence;
end;

procedure Tfrmsettings.btnSupportPathClick(Sender: TObject);
begin
  frmosmain.ODir.InitialDir:=GlobalSupportPath;
   if frmosmain.ODir.Execute then eSupportPath.Text:=frmosmain.ODir.FileName+PathDelim;
  CheckExistence;
end;

procedure Tfrmsettings.btnUnloadPathClick(Sender: TObject);
begin
 frmosmain.ODir.InitialDir:=GlobalUnloadPath;
  if frmosmain.ODir.Execute then eUnloadPath.Text:=frmosmain.ODir.FileName+PathDelim;
 CheckExistence;
end;

procedure Tfrmsettings.btnGEBCOPathClick(Sender: TObject);
begin
 frmosmain.OD.Filter:='GEBCO 2020|GEBCO_2020.nc';
   if frmosmain.OD.Execute then eGEBCOPath.Text:= frmosmain.OD.FileName;
 CheckExistence;
end;

procedure Tfrmsettings.btnSurferPathClick(Sender: TObject);
begin
 frmosmain.OD.Filter:='Scripter.exe|Scripter.exe';
   if frmosmain.OD.Execute then eSurferPath.Text:= frmosmain.OD.FileName;
 CheckExistence;
end;

procedure Tfrmsettings.btnGrapherPathClick(Sender: TObject);
begin
  frmosmain.OD.Filter:='Scripter.exe|Scripter.exe';
    if frmosmain.OD.Execute then eGrapherPath.Text:= frmosmain.OD.FileName;
  CheckExistence;
end;

procedure Tfrmsettings.btnOkClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
 (* Saving settings *)
 if PageControl1.PageIndex<3 then begin
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteString ( 'main', 'OceanFDBPath',     eOceanFDBPath.Text);
   Ini.WriteString ( 'main', 'SupportPath',      eSupportPath.Text);
   Ini.WriteString ( 'main', 'UnloadPath',       eUnloadPath.Text);
   Ini.WriteString ( 'main', 'SurferPath',       eSurferPath.Text);
   Ini.WriteString ( 'main', 'GrapherPath',      eGrapherPath.Text);
   Ini.WriteString ( 'main', 'GEBCOPath',        eGEBCOPath.Text);
   Ini.WriteInteger( 'main', 'Depth_units',      rgDepth.ItemIndex);
  finally
    ini.Free;
  end;
 end;


 (* replacing settings from the advanced tab *)
 if PageControl1.PageIndex=3 then
  if MessageDlg('This action will rewrite settings. Proceed?', mtWarning,
                [mbYes, mbNo], 0)=mrYes then mAdvancedSettings.Lines.SaveToFile(IniFileName);


  GlobalSupportPath:=eSupportPath.Text;
  GlobalUnloadPath:=eUnloadPath.Text;

 Close;
end;

end.

