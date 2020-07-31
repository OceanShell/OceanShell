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
    eGrapherPath: TEdit;
    eSupportPath: TEdit;
    eOceanFDBPath: TEdit;
    eSurferPath: TEdit;
    eUnloadPath: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    GroupBox9: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    lbGEBCO: TLabel;
    lbKML: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;

    procedure btnInstallMissingClick(Sender: TObject);
    procedure btnOceanFDBPathClick(Sender: TObject);
    procedure btnPythonPathClick(Sender: TObject);
    procedure btnShowInstalledClick(Sender: TObject);
    procedure btnSupportPathClick(Sender: TObject);
    procedure btnUnloadPathClick(Sender: TObject);
    procedure eOceanFDBPathChange(Sender: TObject);
//    procedure ePythonPathChange(Sender: TObject);
    procedure eSupportPathChange(Sender: TObject);
    procedure eUnloadPathChange(Sender: TObject);
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

uses osmain, procedures, osbathymetry;

{ Tfrmsettings }

procedure Tfrmsettings.FormShow(Sender: TObject);
Var
 Ini:TIniFile;
 SurferDefault, GrapherDefault, PythonDefault:string;
begin
 SurferDefault :='c:\Program Files\Golden Software\Surfer 13\Scripter\Scripter.exe';
 GrapherDefault:='c:\Program Files\Golden Software\Grapher 11\Scripter\Scripter.exe';
 PythonDefault :=GlobalPath+'Python27'+PathDelim+'python.exe';

  Ini := TIniFile.Create(IniFileName);
  try
   eOceanFDBPath.Text     :=Ini.ReadString  ( 'main', 'OceanFDBPath',     GlobalPath+'databases'+PathDelim+'OCEAN.FDB');
   eSupportPath.Text      :=Ini.ReadString  ( 'main', 'SupportPath',      GlobalPath+'support'+PathDelim);
   eUnloadPath.Text       :=Ini.ReadString  ( 'main', 'UnloadPath',       GlobalPath+'unload'+PathDelim);
   eSurferPath.Text       :=Ini.ReadString  ( 'main', 'SurferPath',       SurferDefault);
   eGrapherPath.Text      :=Ini.ReadString  ( 'main', 'GrapherPath',      GrapherDefault);
//   ePythonPath.Text       :=Ini.ReadString  ( 'main', 'PythonPath',       PythonDefault);
   //rgLanguage.ItemIndex   :=Ini.ReadInteger ( 'main', 'Language',         0);
   //rgDepth.ItemIndex      :=Ini.ReadInteger ( 'main', 'Depth_units',      0);
  finally
    ini.Free;
  end;

   if FileExists(eSurferPath.Text)  then eSurferPath.Font.Color :=clGreen  else eSurferPath.Font.Color :=clRed;
   if FileExists(eGrapherPath.Text) then eGrapherPath.Font.Color:=clGreen  else eGrapherPath.Font.Color:=clRed;

   (* Check if GEBCO is in place *)
   if GEBCOExists=true then begin
     lbGEBCO.Caption:=SYes;
     lbGEBCO.Font.Color:=clGreen;
   end else begin
     lbGEBCO.Caption:=SNo;
     lbGEBCO.Font.Color:=clRed;
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
end;


procedure Tfrmsettings.PageControl1Change(Sender: TObject);
begin
  memo1.Lines.LoadFromFile(IniFileName);
end;

procedure Tfrmsettings.btnOceanFDBPathClick(Sender: TObject);
begin
 frmosmain.OD.Filter:='Ocean.fdb|OCEAN.FDB';
 if frmosmain.OD.Execute then eOceanFDBPath.Text:= frmosmain.OD.FileName;
end;


procedure Tfrmsettings.btnSurferPathClick(Sender: TObject);
begin
  frmosmain.OD.Filter:='Scripter.exe|Scripter.exe';
  if frmosmain.OD.Execute then eSurferPath.Text:= frmosmain.OD.FileName;
end;

procedure Tfrmsettings.btnSupportPathClick(Sender: TObject);
begin
  frmosmain.ODir.InitialDir:=GlobalSupportPath;
  if frmosmain.ODir.Execute then eSupportPath.Text:=frmosmain.ODir.FileName+PathDelim;
end;

procedure Tfrmsettings.btnUnloadPathClick(Sender: TObject);
begin
 frmosmain.ODir.InitialDir:=GlobalUnloadPath;
 if frmosmain.ODir.Execute then eUnloadPath.Text:=frmosmain.ODir.FileName+PathDelim;
end;

procedure Tfrmsettings.eOceanFDBPathChange(Sender: TObject);
begin
 if FileExists(eOceanFDBPath.Text)  then eOceanFDBPath.Font.Color :=clGreen  else eOceanFDBPath.Font.Color:=clRed;
end;

procedure Tfrmsettings.eSupportPathChange(Sender: TObject);
begin
 if DirectoryExists(eSupportPath.Text)  then eSupportPath.Font.Color :=clGreen  else eSupportPath.Font.Color:=clRed;
end;

procedure Tfrmsettings.eUnloadPathChange(Sender: TObject);
begin
 if DirectoryExists(eUnloadPath.Text)  then eUnloadPath.Font.Color :=clGreen  else eUnloadPath.Font.Color:=clRed;
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
 // frmosmain.OD.Filter:='Python.exe|Python.exe';
 // if frmosmain.OD.Execute then ePythonPath.Text:= frmosmain.OD.FileName;
end;

procedure Tfrmsettings.btnShowInstalledClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
{memo2.Clear;
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteString ( 'main', 'PythonPath',       ePythonPath.Text);
  finally
   Ini.Free;
  end;
frmosmain.RunScript(1, '-m pip freeze', memo2); }
end;


procedure Tfrmsettings.btnInstallMissingClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
{memo2.Clear;
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
     ePythonPath.Font.Color:=clRed; }
end;


procedure Tfrmsettings.btnOkClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteString ( 'main', 'OceanFDBPath',     eOceanFDBPath.Text);
   Ini.WriteString ( 'main', 'SupportPath',      eSupportPath.Text);
   Ini.WriteString ( 'main', 'UnloadPath',       eUnloadPath.Text);
   Ini.WriteString ( 'main', 'SurferPath',       eSurferPath.Text);
   Ini.WriteString ( 'main', 'GrapherPath',      eGrapherPath.Text);
 //  Ini.WriteString ( 'main', 'PythonPath',       ePythonPath.Text);
 //  Ini.WriteInteger( 'main', 'Language',         rgLanguage.ItemIndex);
  finally
    ini.Free;
  end;

  GlobalSupportPath:=eSupportPath.Text;
  GlobalUnloadPath:=eUnloadPath.Text;
 Close;
end;

end.

