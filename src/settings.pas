unit settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, Spin, IniFiles;

type

  { Tfrmsettings }

  Tfrmsettings = class(TForm)
    btnGrapherPath: TButton;
    btnInstallMissing: TButton;
    btnOk: TButton;
    btnPythonPath: TButton;
    btnShowInstalled: TButton;
    btnSupportPath: TButton;
    btnSurferPath: TButton;
    btnUnloadPath: TButton;
    eGrapherPath: TEdit;
    ePythonPath: TEdit;
    eSupportPath: TEdit;
    eSurferPath: TEdit;
    eUnloadPath: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    Label1: TLabel;
    lbKML: TLabel;
    Memo1: TMemo;
    memo2: TMemo;
    PageControl1: TPageControl;
    rgBathymetry: TRadioGroup;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet3: TTabSheet;

    procedure btnInstallMissingClick(Sender: TObject);
    procedure btnPythonPathClick(Sender: TObject);
    procedure btnShowInstalledClick(Sender: TObject);
    procedure ePythonPathChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnGrapherPathClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnSurferPathClick(Sender: TObject);
    procedure eGrapherPathChange(Sender: TObject);
    procedure eSurferPathChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmsettings: Tfrmsettings;

implementation

{$R *.lfm}

uses osmain, procedures;

{ Tfrmsettings }

procedure Tfrmsettings.FormShow(Sender: TObject);
Var
 Ini:TIniFile;
 SurferDefault, GrapherDefault, PythonDefault, bathymetry_path:string;
begin
 SurferDefault :='c:\Program Files\Golden Software\Surfer 13\Scripter\Scripter.exe';
 GrapherDefault:='c:\Program Files\Golden Software\Grapher 11\Scripter\Scripter.exe';
 PythonDefault :=GlobalPath+'Python27'+PathDelim+'python.exe';

  Ini := TIniFile.Create(IniFileName);
  try
   eSupportPath.Text      :=Ini.ReadString  ( 'main', 'SupportPath',      GlobalPath+'support'+PathDelim);
   eUnloadPath.Text       :=Ini.ReadString  ( 'main', 'UnloadPath',       GlobalPath+'unload'+PathDelim);
   eSurferPath.Text       :=Ini.ReadString  ( 'main', 'SurferPath',       SurferDefault);
   eGrapherPath.Text      :=Ini.ReadString  ( 'main', 'GrapherPath',      GrapherDefault);
   ePythonPath.Text       :=Ini.ReadString  ( 'main', 'PythonPath',       PythonDefault);
   //rgLanguage.ItemIndex   :=Ini.ReadInteger ( 'main', 'Language',         0);
   rgBathymetry.ItemIndex :=Ini.ReadInteger ( 'main', 'Bathymetry',       0);
  finally
    ini.Free;
  end;

   if FileExists(eSurferPath.Text)  then eSurferPath.Font.Color :=clGreen  else eSurferPath.Font.Color :=clRed;
   if FileExists(eGrapherPath.Text) then eGrapherPath.Font.Color:=clGreen  else eGrapherPath.Font.Color:=clRed;

   bathymetry_path:=GlobalSupportPath+'bathymetry'+PathDelim;
     rgBathymetry.Controls[0].Enabled := FileExists(bathymetry_path+'GEBCO_2019.nc');
     rgBathymetry.Controls[1].Enabled := FileExists(bathymetry_path+'GEBCO_2014_2D.nc');
     rgBathymetry.Controls[2].Enabled := FileExists(bathymetry_path+'gridone.nc');
     rgBathymetry.Controls[3].Enabled := FileExists(bathymetry_path+'ETOPO1_Ice_g_gmt4.nc');

   if checkKML=true then begin
     lbKML.Caption:=SYes;
     lbKML.Font.Color:=clGreen;
   end;
   if checkKML=false then begin
     lbKML.Caption:=SNo;
     lbKML.Font.Color:=clRed;
   end;
end;


procedure Tfrmsettings.PageControl1Change(Sender: TObject);
begin
  memo1.Lines.LoadFromFile(IniFileName);
end;


procedure Tfrmsettings.btnSurferPathClick(Sender: TObject);
begin
  frmosmain.OD.Filter:='Scripter.exe|Scripter.exe';
  if frmosmain.OD.Execute then eSurferPath.Text:= frmosmain.OD.FileName;
end;

procedure Tfrmsettings.eSurferPathChange(Sender: TObject);
begin
 if FileExists(eSurferPath.Text)  then eSurferPath.Font.Color :=clGreen  else eSurferPath.Font.Color:=clRed;
end;

procedure Tfrmsettings.btnGrapherPathClick(Sender: TObject);
begin
  frmosmain.OD.Filter:='Scripter.exe|Scripter.exe';
  if frmosmain.OD.Execute then eGrapherPath.Text:= frmosmain.OD.FileName;
end;

procedure Tfrmsettings.eGrapherPathChange(Sender: TObject);
begin
  if FileExists(eGrapherPath.Text) then eGrapherPath.Font.Color:=clGreen else eGrapherPath.Font.Color:=clRed;
end;

procedure Tfrmsettings.btnPythonPathClick(Sender: TObject);
begin
  frmosmain.OD.Filter:='Python.exe|Python.exe';
  if frmosmain.OD.Execute then ePythonPath.Text:= frmosmain.OD.FileName;
end;

procedure Tfrmsettings.btnShowInstalledClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
memo2.Clear;
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteString ( 'main', 'PythonPath',       ePythonPath.Text);
  finally
   Ini.Free;
  end;
frmosmain.RunScript(1, '-m pip freeze', memo2);
end;

procedure Tfrmsettings.btnInstallMissingClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
memo2.Clear;
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteString ( 'main', 'PythonPath',       ePythonPath.Text);
  finally
   Ini.Free;
  end;

  frmosmain.RunScript(1, '-m pip install scipy',      memo2);
  frmosmain.RunScript(1, '-m pip install pandas',     memo2);
  frmosmain.RunScript(1, '-m pip install matplotlib', memo2);
  frmosmain.RunScript(1, '-m pip install motuclient', memo2);
  frmosmain.RunScript(1, '-m pip install cdsapi',     memo2);
end;

procedure Tfrmsettings.ePythonPathChange(Sender: TObject);
begin
btnInstallMissing.Enabled:=FileExists(ePythonPath.Text);
btnShowInstalled.Enabled:=FileExists(ePythonPath.Text);

  if FileExists(ePythonPath.Text) then
     ePythonPath.Font.Color:=clGreen else
     ePythonPath.Font.Color:=clRed;
end;


procedure Tfrmsettings.btnOkClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteString ( 'main', 'SupportPath',      eSupportPath.Text);
   Ini.WriteString ( 'main', 'UnloadPath',       eUnloadPath.Text);
   Ini.WriteString ( 'Main', 'SurferPath',       eSurferPath.Text);
   Ini.WriteString ( 'Main', 'GrapherPath',      eGrapherPath.Text);
   Ini.WriteString ( 'main', 'PythonPath',       ePythonPath.Text);
 //  Ini.WriteInteger( 'main', 'Language',         rgLanguage.ItemIndex);
   Ini.WriteInteger( 'main', 'Bathymetry',       rgBathymetry.ItemIndex);
  finally
    ini.Free;
  end;

  GlobalSupportPath:=eSupportPath.Text;
  GlobalUnloadPath:=eUnloadPath.Text;

 frmosmain.ItemsVisibility;
 Close;
end;

end.

