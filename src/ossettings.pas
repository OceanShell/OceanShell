unit ossettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, CheckLst, IniFiles;

type

  { Tfrmsettings }

  Tfrmsettings = class(TForm)
    btnGEBCOPath: TButton;
    btnGrapherPath: TButton;
    btnOk: TButton;
    btnSelectARGOPath: TButton;
    btnSelectWODPath: TButton;
    btnSupportPath: TButton;
    btnSurferPath: TButton;
    btnUnloadPath: TButton;
    btnDataPath: TButton;
    chkExpFeat: TCheckBox;
    chkPQF1: TCheckListBox;
    chkPQF2: TCheckListBox;
    chkSQF: TCheckListBox;
    eWODPath: TEdit;
    eGEBCOPath: TEdit;
    eGrapherPath: TEdit;
    eARGOPath: TEdit;
    eSupportPath: TEdit;
    eSurferPath: TEdit;
    eUnloadPath: TEdit;
    eDataPath: TEdit;
    gbGrapherPath: TGroupBox;
    gbSurferPath: TGroupBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    GroupBox9: TGroupBox;
    Label1: TLabel;
    lbPQF1: TLabel;
    lbKML: TLabel;
    lbPQF2: TLabel;
    lbPQF3: TLabel;
    mAdvancedSettings: TMemo;
    PageControl1: TPageControl;
    rgDepth: TRadioGroup;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    tsQualityFlags: TTabSheet;
    tsAdvanced: TTabSheet;
    TabSheet4: TTabSheet;

    procedure btnSelectARGOPathClick(Sender: TObject);
    procedure btnSelectWODPathClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDataPathClick(Sender: TObject);
    procedure btnGEBCOPathClick(Sender: TObject);
    procedure btnOceanToolsPathClick(Sender: TObject);
    procedure btnSaveConnectionClick(Sender: TObject);
    procedure btnSupportPathClick(Sender: TObject);
    procedure btnUnloadPathClick(Sender: TObject);
    procedure chkExpFeatChange(Sender: TObject);
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
 SurferDefault, GrapherDefault, GEBCODefault:string;
 k: integer;
begin
 SurferDefault   :='c:\Program Files\Golden Software\Surfer\Scripter\Scripter.exe';
 GrapherDefault  :='c:\Program Files\Golden Software\Grapher\Scripter\Scripter.exe';
 GEBCODefault    :=GlobalPath+'support'+PathDelim+'bathymetry'+PathDelim+'GEBCO_2025.nc';

// showmessage(inttostr(PQF1_list.Count));
 if PQF1_list.Count > 0 then begin
   chkPQF1.Items:=PQF1_list;
   chkPQF2.Items:=PQF2_list;
   chkSQF.Items :=SQF_list;
 end else begin
   tsQualityFlags.TabVisible:=false;
 end;

  Ini := TIniFile.Create(IniFileName);
  try
   eDataPath.Text         :=Ini.ReadString  ( 'main', 'DataPath',         GlobalPath+'data'+PathDelim);
   eSupportPath.Text      :=Ini.ReadString  ( 'main', 'SupportPath',      GlobalPath+'support'+PathDelim);
   eUnloadPath.Text       :=Ini.ReadString  ( 'main', 'UnloadPath',       GlobalPath+'unload'+PathDelim);
   //eOceanToolsPath.Text   :=Ini.ReadString  ( 'main', 'OceanToolsPath',   GlobalPath);

   eSurferPath.Text       :=Ini.ReadString  ( 'main', 'SurferPath',       SurferDefault);
   eGrapherPath.Text      :=Ini.ReadString  ( 'main', 'GrapherPath',      GrapherDefault);
   eGEBCOPath.Text        :=Ini.ReadString  ( 'main', 'GEBCOPath',        GEBCODefault);
   rgDepth.ItemIndex      :=Ini.ReadInteger ( 'main', 'Depth_units',      0);
   chkExpFeat.Checked     :=Ini.ReadBool    ( 'main', 'Experimental',     false);

   eARGOPath.Text         :=Ini.ReadString  ( 'ARGO', 'data_path',  '');
   eWODPath.Text          :=Ini.ReadString  ( 'WOD',  'data_path',  '');

   for k:=0 to chkPQF1.Count-1 do
      chkPQF1.Checked[k]:=Ini.ReadBool('osparameters_list', 'PQF1_'+inttostr(k), true);

   for k:=0 to chkPQF2.Count-1 do
      chkPQF2.Checked[k]:=Ini.ReadBool('osparameters_list', 'PQF2_'+inttostr(k), true);

   for k:=0 to chkSQF.Count-1 do
      chkSQF.Checked[k]:=Ini.ReadBool('osparameters_list', 'SQF_'+inttostr(k), true);
  finally
    ini.Free;
  end;

 {
 Ini := TIniFile.Create(IniFileName);
   try
    Width := Ini.ReadInteger( 'osparameters_list', 'width',  423);
    Height:= Ini.ReadInteger( 'osparameters_list', 'weight', 525);





    for k:=0 to chklInstrument.Count-1 do
      chklInstrument.Checked[k]:=Ini.ReadBool('osparameters_list', 'Instrument'+inttostr(k), true);
   finally
     Ini.Free;
   end;  }


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
  if DirectoryExists(eDataPath.Text)     then eDataPath.Font.Color     :=clGreen else eDataPath.Font.Color       :=clRed;
  if DirectoryExists(eSupportPath.Text)  then eSupportPath.Font.Color  :=clGreen else eSupportPath.Font.Color    :=clRed;
  if DirectoryExists(eUnloadPath.Text)   then eUnloadPath.Font.Color   :=clGreen else eUnloadPath.Font.Color     :=clRed;
 // if DirectoryExists(eOceanToolsPath.Text) then eOceanToolsPath.Font.Color :=clGreen else eOceanToolsPath.Font.Color :=clRed;

  if FileExists(eGEBCOPath.Text)         then eGEBCOPath.Font.Color    :=clGreen else eGEBCOPath.Font.Color   :=clRed;
  if FileExists(eSurferPath.Text)        then eSurferPath.Font.Color   :=clGreen else eSurferPath.Font.Color  :=clRed;
  if FileExists(eGrapherPath.Text)       then eGrapherPath.Font.Color  :=clGreen else eGrapherPath.Font.Color :=clRed;

  if DirectoryExists(eARGOPath.Text)     then eARGOPath.Font.Color     :=clGreen else eARGOPath.Font.Color    :=clRed;
  if DirectoryExists(eWODPath.Text)      then eWODPath.Font.Color      :=clGreen else eWODPath.Font.Color     :=clRed;
end;

procedure Tfrmsettings.PageControl1Change(Sender: TObject);
begin
  mAdvancedSettings.Lines.LoadFromFile(IniFileName);
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

procedure Tfrmsettings.btnSelectARGOPathClick(Sender: TObject);
begin
 frmosmain.ODir.InitialDir:=GlobalPath;
  if frmosmain.ODir.Execute then eARGOPath.Text:=frmosmain.ODir.FileName+PathDelim;
 CheckExistence;
end;

procedure Tfrmsettings.btnSelectWODPathClick(Sender: TObject);
begin
 frmosmain.ODir.InitialDir:=GlobalPath;
  if frmosmain.ODir.Execute then eWODPath.Text:=frmosmain.ODir.FileName+PathDelim;
 CheckExistence;
end;


procedure Tfrmsettings.chkExpFeatChange(Sender: TObject);
begin
  tsAdvanced.TabVisible:=chkExpFeat.Checked;
  Application.ProcessMessages;
end;


procedure Tfrmsettings.btnGEBCOPathClick(Sender: TObject);
begin
 frmosmain.OD.Filter:='GEBCO|*.nc';
   if frmosmain.OD.Execute then eGEBCOPath.Text:= frmosmain.OD.FileName;
 CheckExistence;
end;

procedure Tfrmsettings.btnDataPathClick(Sender: TObject);
begin
 frmosmain.ODir.InitialDir:=GlobalDataPath;
  if frmosmain.ODir.Execute then eDataPath.Text:=frmosmain.ODir.FileName+PathDelim;
 CheckExistence;
end;

procedure Tfrmsettings.btnOceanToolsPathClick(Sender: TObject);
begin
 frmosmain.ODir.InitialDir:=GlobalDataPath;
 // if frmosmain.ODir.Execute then eOceanToolsPath.Text:=frmosmain.ODir.FileName+PathDelim;
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


procedure Tfrmsettings.btnSaveConnectionClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteString ('server', 'dbpath',   '');
  finally
   Ini.Free;
  end;
end;


procedure Tfrmsettings.btnOkClick(Sender: TObject);
Var
 Ini:TIniFile;
 k: integer;
begin
 (* Saving settings *)
 if PageControl1.PageIndex<4 then begin
 Ini := TIniFile.Create(IniFileName);

  try
   Ini.WriteString ( 'main', 'DataPath',         eDataPath.Text);
   Ini.WriteString ( 'main', 'SupportPath',      eSupportPath.Text);
   Ini.WriteString ( 'main', 'UnloadPath',       eUnloadPath.Text);
 //  Ini.WriteString ( 'main', 'OceanToolsPath',   eOceanToolsPath.Text);
   Ini.WriteString ( 'main', 'SurferPath',       eSurferPath.Text);
   Ini.WriteString ( 'main', 'GrapherPath',      eGrapherPath.Text);
   Ini.WriteString ( 'main', 'GEBCOPath',        eGEBCOPath.Text);
   Ini.WriteInteger( 'main', 'Depth_units',      rgDepth.ItemIndex);
   Ini.WriteBool   ( 'main', 'Experimental',     chkExpFeat.Checked);

   Ini.WriteString ( 'ARGO', 'data_path',        eARGOPath.Text);
   Ini.WriteString ( 'WOD',  'data_path',        eWODPath.Text);

   if tsQualityFlags.TabVisible then begin
   for k:=0 to chkPQF1.Count-1 do
     Ini.WriteBool( 'osparameters_list', 'PQF1_'+inttostr(k), chkPQF1.Checked[k]);

   for k:=0 to chkPQF2.Count-1 do
     Ini.WriteBool( 'osparameters_list', 'PQF2_'+inttostr(k), chkPQF2.Checked[k]);

   for k:=0 to chkSQF.Count-1 do
     Ini.WriteBool( 'osparameters_list','SQF_'+inttostr(k), chkSQF.Checked[k]);

   {for k:=0 to chklInstrument.Count-1 do
     Ini.WriteBool('osparameters_list', 'Instrument'+inttostr(k),  chklInstrument.Checked[k]); }
   end;
  finally
    ini.Free;
  end;
 end;


 (* replacing settings from the advanced tab *)
 if PageControl1.PageIndex=4 then
  if MessageDlg('This action will rewrite settings. Proceed?', mtWarning,
                [mbYes, mbNo], 0)=mrYes then mAdvancedSettings.Lines.SaveToFile(IniFileName);


  GlobalSupportPath:=eSupportPath.Text;
  GlobalUnloadPath:=eUnloadPath.Text;

 Close;
end;

end.

