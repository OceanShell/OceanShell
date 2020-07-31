unit osbathymetry_plot;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ExtCtrls, Buttons, Variants, IniFiles, LCLIntf;

type

  { Tfrmbathymetry_plot }

  Tfrmbathymetry_plot = class(TForm)
    btnOpenFolder: TBitBtn;
    btnOpenScript: TBitBtn;
    btnPlot: TButton;
    btnSurferSettings: TButton;
    btnGetData: TButton;
    Label1: TLabel;
    seLatMax: TFloatSpinEdit;
    SeLonMin: TFloatSpinEdit;
    seLatMin: TFloatSpinEdit;
    seLonMax: TFloatSpinEdit;
    GroupBox1: TGroupBox;
    seStep: TSpinEdit;
    procedure btnGetDataClick(Sender: TObject);
    procedure btnOpenFolderClick(Sender: TObject);
    procedure btnOpenScriptClick(Sender: TObject);
    procedure btnPlotClick(Sender: TObject);
    procedure btnSurferSettingsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmbathymetry_plot: Tfrmbathymetry_plot;
  pathbathymetry:string;

implementation

{$R *.lfm}

{ Tfrmbathymetry_plot }

uses osmain, osbathymetry, declarations_netcdf, surfer_field, surfer_settings;


procedure Tfrmbathymetry_plot.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
 try
  seLatMin.Text := Ini.ReadString('bathymetry', 'LatMin',  '-90');
  seLatMax.Text := Ini.ReadString('bathymetry', 'LatMax',   '90');
  seLonMin.Text := Ini.ReadString('bathymetry', 'LonMin', '-180');
  seLonMax.Text := Ini.ReadString('bathymetry', 'LonMax',  '180');
  seStep.Text   := Ini.ReadString('bathymetry', 'Step',     '60');
 finally
   ini.Free;
 end;

 pathbathymetry:=GlobalUnloadPath+'bathymetry'+PathDelim;
   if not DirectoryExists(pathbathymetry) then CreateDir(pathbathymetry);
end;


procedure Tfrmbathymetry_plot.btnGetDataClick(Sender: TObject);
Var
 dat: text;
 step, lat, lon:real;
 depth :integer;
begin

 step:=seStep.value/3600;

 AssignFile(dat, pathbathymetry+'GEBCO.TXT'); rewrite(dat);

 Lat:=seLatMin.Value;
 repeat
   Lon:=seLonMin.Value;
   repeat
     depth:=-GetGEBCODepth(lon, lat);
     if depth>0 then writeln(dat, floattostrF(lon, fffixed, 9, 5),' ',
                                  floattostrF(lat, fffixed, 8, 5),' ',
                                  inttostr(depth));

     lon:=lon+step;
   until lon>seLonMax.Value;
  lat:=lat+step;
 until lat>SeLatMax.Value;
 CloseFile(dat);

 btnPlot.Enabled:=true;
 btnOpenScript.Enabled:=true;
end;


procedure Tfrmbathymetry_plot.btnPlotClick(Sender: TObject);
Var
 step:real;
 ncols, nrows:integer;
begin
 step:=seStep.value/3600;
 ncols:=trunc((seLonMax.Value-seLonMin.Value)/step)+1;
 nrows:=trunc((seLatMax.Value-seLatMin.Value)/step)+1;


  GetFieldScript(pathbathymetry+'GEBCO.TXT', //data file
                 'Depth, [m]', // variable name and its units
                 3, //column to plot
                 ncols, nrows, //colums and rows
                 seLonMin.Value, seLonMax.Value, seLatMin.Value, seLatMax.Value, //region
                 'Bathymetry', //preset name
                 '', // no custon clr
                 true //reversed!
                 );

  {$IFDEF Windows}
    frmosmain.RunScript(2, '-x "'+pathbathymetry+'script.bas"', nil);
  {$ENDIF}
end;

procedure Tfrmbathymetry_plot.btnSurferSettingsClick(Sender: TObject);
begin
   frmSurferSettings := TfrmSurferSettings.Create(Self);
   frmSurferSettings.LoadSettings('field');
    try
     if not frmSurferSettings.ShowModal = mrOk then exit;
    finally
      frmSurferSettings.Free;
      frmSurferSettings := nil;
    end;
end;


procedure Tfrmbathymetry_plot.btnOpenFolderClick(Sender: TObject);
begin
  OpenDocument(PChar(pathbathymetry));
end;

procedure Tfrmbathymetry_plot.btnOpenScriptClick(Sender: TObject);
Var
ScriptFile, Scripter:string;
Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName); // settings from file
  try
   scripter:=Ini.ReadString('main', 'SurferPath', '');
  finally
    Ini.Free;
  end;
 ScriptFile:=ExtractFilePath(pathbathymetry)+PathDelim+'Script.bas';
 SysUtils.ExecuteProcess('"'+Scripter+'" "'+ScriptFile+'"', '', []);
end;

procedure Tfrmbathymetry_plot.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
Var
 Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
 try
   Ini.WriteString('bathymetry', 'LatMin', seLatMin.Text);
   Ini.WriteString('bathymetry', 'LatMax', seLatMax.Text);
   Ini.WriteString('bathymetry', 'LonMin', seLonMin.Text);
   Ini.WriteString('bathymetry', 'LonMax', seLonMax.Text);
   Ini.WriteString('bathymetry', 'Step',   seStep.Text);
 finally
   Ini.Free;
 end;
end;

end.

