unit ossettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, Spin, IniFiles;

type

  { Tfrmsettings }

  Tfrmsettings = class(TForm)
    btnGrapherPath: TButton;
    btnInstallPackages: TButton;
    btnOk: TButton;
    btnPython: TButton;
    btnSupportPath: TButton;
    btnSurferPath: TButton;
    btnUnloadPath: TButton;
    btnGEBCOPath: TButton;
    chkExpFeat: TCheckBox;
    eUser: TEdit;
    ePass: TEdit;
    eGrapherPath: TEdit;
    eDBPath: TEdit;
    ePythonPath: TEdit;
    eHost: TEdit;
    eSupportPath: TEdit;
    eSurferPath: TEdit;
    eUnloadPath: TEdit;
    eGEBCOPath: TEdit;
    gbGrapherPath: TGroupBox;
    gbSurferPath: TGroupBox;
    GroupBox3: TGroupBox;
    gbPythonPath: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    GroupBox9: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lbKML: TLabel;
    mAdvancedSettings: TMemo;
    Memo1: TMemo;
    PageControl1: TPageControl;
    rgDepth: TRadioGroup;
    rgPlotSoft: TRadioGroup;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    tsAdvanced: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;

    procedure btnGEBCOPathClick(Sender: TObject);
    procedure btnInstallPackagesClick(Sender: TObject);
    procedure btnOceanFDBPathClick(Sender: TObject);
    procedure btnPythonClick(Sender: TObject);
    procedure btnSupportPathClick(Sender: TObject);
    procedure btnUnloadPathClick(Sender: TObject);
    procedure chkExpFeatChange(Sender: TObject);
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

uses osmain, procedures;

{ Tfrmsettings }

procedure Tfrmsettings.FormShow(Sender: TObject);
Var
 Ini:TIniFile;
 server:string;
 SurferDefault, GrapherDefault, GEBCODefault, OceanFDBDefault:string;
begin
 SurferDefault   :='c:\Program Files\Golden Software\Surfer 13\Scripter\Scripter.exe';
 GrapherDefault  :='c:\Program Files\Golden Software\Grapher 11\Scripter\Scripter.exe';
 GEBCODefault    :=GlobalPath+'support'+PathDelim+'bathymetry'+PathDelim+'GEBCO_2020.nc';
 OceanFDBDefault :=GlobalPath+'databases'+PathDelim+'OCEAN.FDB';

 server:='firebird';

  Ini := TIniFile.Create(IniFileName);
  try
   eDBPath.Text := Ini.ReadString (server, 'dbpath',   OceanFDBDefault);
   eHost.Text   := Ini.ReadString (server, 'host',     'localhost');
   //ePort.Text   := Ini.ReadString (server, 'port',     '3050');
   eUser.Text   := Ini.ReadString (server, 'user',     'SYSDBA');
   epass.Text   := Ini.ReadString (server, 'pass',     'masterkey');

   eSupportPath.Text      :=Ini.ReadString  ( 'main', 'SupportPath',      GlobalPath+'support'+PathDelim);
   eUnloadPath.Text       :=Ini.ReadString  ( 'main', 'UnloadPath',       GlobalPath+'unload'+PathDelim);
   eSurferPath.Text       :=Ini.ReadString  ( 'main', 'SurferPath',       SurferDefault);
   eGrapherPath.Text      :=Ini.ReadString  ( 'main', 'GrapherPath',      GrapherDefault);
   eGEBCOPath.Text        :=Ini.ReadString  ( 'main', 'GEBCOPath',        GEBCODefault);
   rgDepth.ItemIndex      :=Ini.ReadInteger ( 'main', 'Depth_units',      0);
   ePythonPath.Text       :=Ini.ReadString  ( 'main', 'PythonPath',       '');
   rgPlotSoft.ItemIndex   :=Ini.ReadInteger ( 'main', 'Plotting_soft',    0);
   chkExpFeat.Checked     :=Ini.ReadBool    ( 'main', 'Experimental',     false);


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

   tsAdvanced.TabVisible:=chkExpFeat.Checked;

  {$IFDEF UNIX}
     gbPythonPath.Enabled:=false;
     gbSurferPath.Visible:=false;
     gbGrapherPath.Visible:=false;
     rgPlotSoft.ItemIndex:=1;
     TRadioButton(rgPlotSoft.Controls[0]).Enabled := False;
  {$ENDIF}
end;

procedure Tfrmsettings.CheckExistence;
begin
  if DirectoryExists(eSupportPath.Text) then eSupportPath.Font.Color  :=clGreen else eSupportPath.Font.Color :=clRed;
  if DirectoryExists(eUnloadPath.Text)  then eUnloadPath.Font.Color   :=clGreen else eUnloadPath.Font.Color  :=clRed;
  if FileExists(eGEBCOPath.Text)        then eGEBCOPath.Font.Color    :=clGreen else eGEBCOPath.Font.Color   :=clRed;
  if FileExists(eSurferPath.Text)       then eSurferPath.Font.Color   :=clGreen else eSurferPath.Font.Color  :=clRed;
  if FileExists(eGrapherPath.Text)      then eGrapherPath.Font.Color  :=clGreen else eGrapherPath.Font.Color :=clRed;
  if FileExists(ePythonPath.Text)       then ePythonPath.Font.Color   :=clGreen else ePythonPath.Font.Color  :=clRed;

  {$IFDEF WINDOWS}
    TRadioButton(rgPlotSoft.Controls[1]).Enabled:=FileExists(ePythonPath.Text);
  {$ENDIF}
end;

procedure Tfrmsettings.PageControl1Change(Sender: TObject);
begin
  mAdvancedSettings.Lines.LoadFromFile(IniFileName);
end;

procedure Tfrmsettings.btnOceanFDBPathClick(Sender: TObject);
begin
 frmosmain.OD.Filter:='*.FDB|*.FDB';
  if frmosmain.OD.Execute then eDBPath.Text:= frmosmain.OD.FileName;
end;

procedure Tfrmsettings.btnPythonClick(Sender: TObject);
begin
  frmosmain.OD.Filter:='Python|Python.exe';
  if frmosmain.OD.Execute then ePythonPath.Text:= frmosmain.OD.FileName;
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

procedure Tfrmsettings.chkExpFeatChange(Sender: TObject);
begin
  tsAdvanced.TabVisible:=chkExpFeat.Checked;
  Application.ProcessMessages;
end;

procedure Tfrmsettings.btnGEBCOPathClick(Sender: TObject);
begin
 frmosmain.OD.Filter:='GEBCO 2020|GEBCO_2020.nc';
   if frmosmain.OD.Execute then eGEBCOPath.Text:= frmosmain.OD.FileName;
 CheckExistence;
end;

procedure Tfrmsettings.btnInstallPackagesClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
memo1.Clear;
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteString ( 'main', 'PythonPath', ePythonPath.Text);
  finally
   Ini.Free;
  end;
  frmosmain.RunScript(1, GlobalPath+'get-pip.py', memo1);
  frmosmain.RunScript(1, '-m pip install matplotlib', memo1);
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
 server:string;
begin
 (* Saving settings *)
 if PageControl1.PageIndex<3 then begin
 Ini := TIniFile.Create(IniFileName);

 server:='firebird';
  try
   Ini.WriteString (server, 'dbpath',   eDBPath.Text);
   Ini.WriteString (server, 'host',     eHost.Text);
  // Ini.WriteString (server, 'port',     ePort.Text);
   Ini.WriteString (server, 'user',     eUser.Text);
   Ini.WriteString (server, 'pass',     epass.Text);

   Ini.WriteString ( 'main', 'SupportPath',      eSupportPath.Text);
   Ini.WriteString ( 'main', 'UnloadPath',       eUnloadPath.Text);
   Ini.WriteString ( 'main', 'SurferPath',       eSurferPath.Text);
   Ini.WriteString ( 'main', 'GrapherPath',      eGrapherPath.Text);
   Ini.WriteString ( 'main', 'GEBCOPath',        eGEBCOPath.Text);
   Ini.WriteInteger( 'main', 'Depth_units',      rgDepth.ItemIndex);
   Ini.WriteString ( 'main', 'PythonPath',       ePythonPath.Text);
   Ini.WriteInteger( 'main', 'Plotting_soft',    rgPlotSoft.ItemIndex);
   Ini.WriteBool   ( 'main', 'Experimental',     chkExpFeat.Checked);
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

