unit osmain;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, ComCtrls, LCLType,
  Menus, Dialogs, ActnList, StdCtrls, INIFiles, ExtCtrls, DateUtils, sqldb, DB,
  Buttons, DBGrids, Spin, DBCtrls, DateTimePicker, Process, Math, Grids;

type

  {$IFDEF CPU386}
    PtrUInt = DWORD;
    PtrInt = longint;
  {$ENDIF}
  {$IFDEF CPUX64}
    PtrUInt = QWORD;
    PtrInt = int64;
  {$ENDIF}

  { Tfrmosmain }

  Tfrmosmain = class(TForm)
    aProfilesSelectedAllPlot: TAction;
    aShowStations: TAction;
    aMapSelectedStation: TAction;
    aProfilesStationAll: TAction;
    aMapKML: TAction;
    aOpenDatabase: TAction;
    aMapAllStations: TAction;
    AL1: TActionList;
    btnFastAccessOpenMap: TToolButton;
    btnSelection: TButton;
    btnAdvancedSelection: TButton;
    btnCustomSQLQuery: TButton;
    cbCountry: TComboBox;
    cbSource: TComboBox;
    cbInstitute: TComboBox;
    cbProject: TComboBox;
    chkNOTPlatform: TCheckBox;
    chkNOTCountry: TCheckBox;
    chkNOTSource: TCheckBox;
    chkNOTInstitute: TCheckBox;
    chkNOTProject: TCheckBox;
    chkPeriod: TCheckBox;
    cbPlatform: TComboBox;
    DBGridEntries: TDBGrid;
    DBMemoCruises: TDBMemo;
    DBMemoEntries: TDBMemo;
    DBGridCruise: TDBGrid;
    dtpDateMin: TDateTimePicker;
    dtpDateMax: TDateTimePicker;
    eCruise_COUNTRY: TEdit;
    eCruise_ID: TEdit;
    eCruise_Project: TEdit;
    eCruise_NUMBER: TEdit;
    eCruise_Institute: TEdit;
    eCruise_PLATFORM: TEdit;
    eCruise_SOURCE: TEdit;
    eCruise_PI: TEdit;
    GroupBox2: TGroupBox;
    gbAuxiliaryParameters: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lbResetArea: TLabel;
    lbResetDates: TLabel;
    iLoad_Pangaea_CTD_tab: TMenuItem;
    lbResetAux: TLabel;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    btnUpdateCruiseStatistics: TMenuItem;
    MenuItem2: TMenuItem;
    iLoad_WOD18: TMenuItem;
    iLoad_WOD: TMenuItem;
    iMap: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    iSelectCruise: TMenuItem;
    MenuItem7: TMenuItem;
    iDIVAnd: TMenuItem;
    iService: TMenuItem;
    btnUpdateLastLEvel: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    pfillercruise: TPanel;
    Panel22: TPanel;
    PM1: TPopupMenu;
    sbDatabase: TStatusBar;
    sbSelection: TStatusBar;
    seIDMax: TSpinEdit;
    seIDMin: TSpinEdit;
    seLonMin: TFloatSpinEdit;
    seLonMax: TFloatSpinEdit;
    seLatMax: TFloatSpinEdit;
    seLatMin: TFloatSpinEdit;
    GroupBox1: TGroupBox;
    iSettings: TMenuItem;
    iLoad: TMenuItem;
    iTools: TMenuItem;
    iLoad_ITP: TMenuItem;
    MenuItem1: TMenuItem;
    iLoad_GLODAP_2019_v2_product: TMenuItem;
    iKnowledgeDBOpen: TMenuItem;
    iStatistics: TMenuItem;
    iDBStatistics: TMenuItem;
    MenuItem3: TMenuItem;
    iLoad_GLODAP_2019_v2: TMenuItem;
    MenuItem4: TMenuItem;
    OD: TOpenDialog;
    PageControl1: TPageControl;
    SD: TSaveDialog;
    Memo1: TMemo;
    MM1: TMainMenu;
    iFile: TMenuItem;
    iNewDatabase: TMenuItem;
    iOpenDatabase: TMenuItem;
    iHelp: TMenuItem;
    iHelpContent: TMenuItem;
    iAbout: TMenuItem;
    N3: TMenuItem;
    iExit: TMenuItem;
    ListBox1: TListBox;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    tsMainEntries: TTabSheet;
    tbFastAccess: TToolBar;
    btnFastAccessOpenDB: TToolButton;
    btnShowStations: TToolButton;
    tsMainSelect: TTabSheet;
    tsMainCruises: TTabSheet;

    procedure aMapAllStationsExecute(Sender: TObject);
    procedure aMapKMLExecute(Sender: TObject);
    procedure aMapSelectedStationExecute(Sender: TObject);
    procedure aOpenDatabaseExecute(Sender: TObject);
    procedure aProfilesSelectedAllPlotExecute(Sender: TObject);
    procedure aProfilesStationAllExecute(Sender: TObject);
    procedure aShowStationsExecute(Sender: TObject);
    procedure btnAdvancedSelectionClick(Sender: TObject);
    procedure btnSelectionClick(Sender: TObject);
    procedure btnUpdateLastLEvelClick(Sender: TObject);
    procedure DBGridCruiseColumnSized(Sender: TObject);
    procedure DBGridCruisePrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DBGridCruiseTitleClick(Column: TColumn);
    procedure eCruise_IDClick(Sender: TObject);
    procedure eCruise_NUMBERChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure iAboutClick(Sender: TObject);
    procedure iDBStatisticsClick(Sender: TObject);
    procedure iDIVAndClick(Sender: TObject);
    procedure iKnowledgeDBOpenClick(Sender: TObject);
    procedure iLoadARGOClick(Sender: TObject);
    procedure iLoadITPClick(Sender: TObject);
    procedure iLoad_GLODAP_2019_v2_productClick(Sender: TObject);
    procedure iLoad_ITPClick(Sender: TObject);
    procedure iLoad_Pangaea_CTD_tabClick(Sender: TObject);
    procedure iLoad_WOD18Click(Sender: TObject);
    procedure iLoad_WODClick(Sender: TObject);
    procedure iSelectCruiseClick(Sender: TObject);
    procedure iSettingsClick(Sender: TObject);
    procedure iNewDatabaseClick(Sender: TObject);
    procedure lbResetAreaClick(Sender: TObject);
    procedure lbResetAuxClick(Sender: TObject);
    procedure lbResetDatesClick(Sender: TObject);
    procedure btnUpdateCruiseStatisticsClick(Sender: TObject);


  private
    procedure SearchID(Sender:TObject);
    procedure SearchPLATFORM(Sender:TObject);
    procedure SearchCOUNTRY(Sender:TObject);
    procedure SearchSOURCE(Sender:TObject);
    procedure SearchPI(Sender:TObject);
    procedure SearchINSTITUTE(Sender:TObject);
    procedure SearchPROJECT(Sender:TObject);
    procedure cbOnDropDown(Sender:TObject);

  public
    procedure OpenDatabase;
    procedure ItemsVisibility;
    procedure DatabaseInfo;
    procedure SelectionInfo;
    procedure CDSNavigation;
    procedure RunScript(ExeFlag:integer; cmd:string; Sender:TMemo);
  end;

  resourcestring
    SOpenFile = 'Open file?';
    SErrorOccured = 'Something went wrong. Check the output';

    SYes = 'Yes';
    SNo  = 'No';
    SDone = 'Done!';
    SDelete = 'Delete';

    SNoPython = 'Python is not found';
    SNoSurfer = 'Surfer is not found';
    SNoGrapher = 'Grapher is not found';
    SNoCDO = 'CDO is not found';
    SNoSupportDB = 'Suport database is not found';



var
  frmosmain: Tfrmosmain;

  IBName, IniFileName:string;
  GlobalPath, GlobalUnloadPath, GlobalSupportPath:string; //global paths for the app
  CurrentParTable: string;

  IBLatMin,IBLatMax,IBLonMin,IBLonMax,SLatMin,SLatMax,SLonMin,SLonMax:Real;
  IBDateMin, IBDateMax, SDateMin, SDateMax :TDateTime;
  IBCount, SCount, IDMin, IDMax:Integer; //number od stations in database and selection


  NavigationOrder:boolean=true; //Stop navigation until all modules responded

  SLatP_arr:array[0..20000] of real;
  SLonP_arr:array[0..20000] of real;
  Length_arr:integer;

  frmcodes_open, frmcodesQC_open, frmparameters_station_open, frmmap_open:boolean;
  frmstations_open, frmparameters_allprofiles_open, frmparameters_list_open: boolean;


const
   NC_NOWRITE   = 0;    // file for reading
   NC_WRITE     = 1;    // file for writing
   NC_GLOBAL    = -1;   // global attributes ID
   NC_MAX_NAME  = 1024; // value from netcdf.h
   NC_UNLIMITED = 0;
   WS_EX_STATICEDGE = $20000;
   buf_len      = 3000;

implementation


uses
(* core modules *)
  osmain_advancedselection,
  dm,
  oscreatenewdb,
  settings,
  codes,
  osabout,
  sortbufds,
  osstations,

(* loading data *)
  osload_itp,
  osload_GLODAP_2019_v2_product,
  osload_WOD18,
  loadwod,
  osload_PangaeaTab,

(* database service procedures *)
  osservice,

(* data export *)
  osexport_divand,

(* QC *)

(* tools *)
  osmap,
  osmap_kml,
  osparameters_list,
  osparameters_station,
  osparameters_allprofiles,

(* statistics *)
  osstatistics
;

{$R *.lfm}


procedure Tfrmosmain.FormShow(Sender: TObject);
Var
  Ini:TINIFile;
begin
 IBName:='';

(* flags on open forms *)
 frmcodes_open:=false; frmcodesQC_open:=false; frmparameters_station_open:=false;
 frmmap_open:=false; frmstations_open:=false; frmparameters_allprofiles_open:=false;
 frmparameters_list_open:=false;

 (* Define Global Path *)
  GlobalPath:=ExtractFilePath(Application.ExeName);

  (* Define settings file, unique for every user*)
  IniFileName:=GetUserDir+'.climateshell';
  if not FileExists(IniFileName) then begin
    Ini:=TIniFile.Create(IniFileName);
    Ini.WriteInteger('main', 'Language', 0);
    Ini.Free;
  end;

  (* Define global delimiter *)
  DefaultFormatSettings.DecimalSeparator := '.';

  (* Loading settings from INI file *)
  Ini := TIniFile.Create(IniFileName);
  try
    (* main form sizes *)
    Top   :=Ini.ReadInteger( 'osmain', 'top',    50);
    Left  :=Ini.ReadInteger( 'osmain', 'left',   50);
    Width :=Ini.ReadInteger( 'osmain', 'width',  900);
    Height:=Ini.ReadInteger( 'osmain', 'weight', 500);

    (* cruise table columns *)
    With DBGridCruise do begin
     Columns[0].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col00',  50); //ID
     Columns[1].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col01', 150); //Platform
     Columns[2].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col02', 100); //Cruise #
     Columns[3].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col03', 100); //Country
     Columns[4].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col04',  70); //Start date
     Columns[5].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col05',  70); //Finish date
     Columns[6].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col06',  60); //Stations
     Columns[7].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col07',  70); //Source
     Columns[8].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col08', 100); //PI
     Columns[9].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col09', 100); //Institute
     Columns[10].Width:=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col10', 100); //Project
     Columns[11].Width:=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col11',  70); //Date_added
     Columns[12].Width:=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col12',  70); //Date_upfated
    end;

   (* Essencial program folders *)
    GlobalSupportPath := Ini.ReadString('main', 'SupportPath', GlobalPath+'support'+PathDelim);
      if not DirectoryExists(GlobalSupportPath) then CreateDir(GlobalSupportPath);
    GlobalUnloadPath  := Ini.ReadString('main', 'UnloadPath', GlobalPath+'unload'+PathDelim);
      if not DirectoryExists(GlobalUnloadPath) then CreateDir(GlobalUnloadPath);
  finally
    Ini.Free;
  end;


 (* Works on double click *)
  If ParamCount<>0 then begin
   if uppercase(ExtractFileExt(ParamStr(1)))='.FDB' then begin
      IBName:=ParamStr(1);
      OpenDatabase;
   end;
  end;

   DBGridCruise.OnColumnSized(Self);

   eCruise_ID.OnChange           := @SearchID;
   eCruise_PLATFORM.OnChange     := @SearchPLATFORM;
   eCruise_COUNTRY.OnChange      := @SearchCOUNTRY;
   eCruise_SOURCE.OnChange       := @SearchSOURCE;
   eCruise_Project.OnChange      := @SearchPROJECT;
   eCruise_Institute.OnChange    := @SearchINSTITUTE;
   eCruise_PI.OnChange           := @SearchPI;

   cbPlatform.OnDropDown  := @cbOnDropDown;
   cbCountry.OnDropDown   := @cbOnDropDown;
   cbSource.OnDropDown    := @cbOnDropDown;
   cbProject.OnDropDown   := @cbOnDropDown;
   cbInstitute.OnDropDown := @cbOnDropDown;


 OnResize(Self);
 SetFocus;
 Application.ProcessMessages;
end;


procedure Tfrmosmain.FormResize(Sender: TObject);
begin
  tbFastAccess.Top:=PageControl1.Top;
  tbFastAccess.Left:=PageControl1.Width-tbFastAccess.Width;

  panel1.Height:=sbDatabase.Height+sbSelection.Height;
end;


procedure Tfrmosmain.btnSelectionClick(Sender: TObject);
var
i, k, fl:integer;
SSYearMin,SSYearMax,SSMonthMin,SSMonthMax,SSDayMin,SSDayMax :Word;
NotCondCountry, NotCondPlatform, NotCondSource:string;
NotCondInstitute, NotCondProject, NotCondOrigin, SBordersFile:string;
{
MinDay, MaxDay, cnt:integer;
Lat, Lon:real; }
time0, time1:TDateTime;
buf_str: string;
begin
DecodeDate(dtpDateMin.Date, SSYearMin, SSMonthMin, SSDayMin);
DecodeDate(dtpDateMax.Date, SSYearMax, SSMonthMax, SSDayMax);

  if chkNOTPlatform.Checked  =true then NotCondCountry   :='NOT' else NotCondCountry   :='';
  if chkNOTPlatform.Checked  =true then NotCondPlatform  :='NOT' else NotCondPlatform  :='';
  if chkNOTSource.Checked    =true then NotCondSource    :='NOT' else NotCondSource    :='';
  if chkNOTInstitute.Checked =true then NotCondInstitute :='NOT' else NotCondInstitute :='';
  if chkNOTProject.Checked   =true then NotCondProject   :='NOT' else NotCondProject   :='';

 with frmdm.Q do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT ');
    SQL.Add(' ID, LATITUDE, LONGITUDE, DATEANDTIME, BOTTOMDEPTH, ');
    SQL.Add(' LASTLEVEL_M, LASTLEVEL_DBAR, CRUISE_ID, INSTRUMENT_ID, ');
    SQL.Add(' ST_NUMBER_ORIGIN, ST_ID_ORIGIN, CAST_NUMBER, QCFLAG, ');
    SQL.Add(' STVERSION, DUPLICATE, MERGED, ACCESSION_NUMBER, ');
    SQL.Add(' DATE_ADDED, DATE_UPDATED ');
    SQL.Add(' FROM STATION');
    SQL.Add(' WHERE ');
     (* Coordinates *)
    SQL.Add(' (ID BETWEEN :SSIDMin AND :SSIDMax) ');

    (* Coordinates *)
    SQL.Add(' and (LATITUDE BETWEEN :SSLatMin AND :SSLatMax) ');
     if seLonMax.Value>=seLonMin.Value then
      SQL.Add(' and (LONGITUDE BETWEEN :SSLonMin AND :SSLonMax) ');
     if seLonMax.Value<seLonMin.Value then
      SQL.Add(' and ((LONGITUDE>=:SSLonMin AND LONGITUDE<=180) or'+
              '      (LONGITUDE>=-180 and LONGITUDE<=:SSLonMax)) ');
    (* End of coordinates *)

    (* Date and Time *)
    // From date to date
    if chkPeriod.Checked=false then
     SQL.Add('  and (DATEANDTIME between :SSDateMin and :SSDateMax) ');

    //Date in Period
    if chkPeriod.Checked=true then begin
      SQL.Add(' and (Extract(Year from DATEANDTIME) between :SSYearMin  and :SSYearMax) ');
      if SSMonthMin<=SSMonthMax then
         SQL.Add(' and (Extract(Month from DATEANDTIME) between :SSMonthMin and :SSMonthMax) ');
      if SSMonthMin>SSMonthMax then
         SQL.Add(' and ((Extract(Month from DATEANDTIME)>= :SSMonthMin) or'+
                 '      (Extract(Month from DATEANDTIME)<= :SSMonthMax)) ');
      if SSDayMin<=SSDayMax then
         SQL.Add(' and (Extract(Day from DATEANDTIME) between :SSDayMin and :SSDayMax) ');
      if SSDayMin>SSDayMax then
         SQL.Add(' and ((Extract(Day from DATEANDTIME)>= :SSDayMin) or '+
                 '      (Extract(Day from DATEANDTIME)<= :SSDayMax)) ');
    end;
    (* End of Date and Time *)

    (* Platform*)
    if cbPlatform.text<>'' then
      SQL.Add(' AND '+NotCondPlatform  +' (STATION.CRUISE_ID IN (SELECT CRUISE.ID '+
              ' FROM CRUISE WHERE CRUISE.PLATFORM_ID IN (SELECT PLATFORM.ID FROM' +
              ' PLATFORM WHERE PLATFORM.NAME='+QuotedStr(cbPlatform.text)+'))) ');
    if cbCountry.text<>'' then
      SQL.Add(' AND '+NotCondCountry  +' (STATION.CRUISE_ID IN (SELECT CRUISE.ID '+
              ' FROM CRUISE WHERE CRUISE.COUNTRY_ID IN (SELECT COUNTRY.ID FROM' +
              ' COUNTRY WHERE COUNTRY.NAME='+QuotedStr(cbCountry.text)+'))) ');
    if cbSource.text<>'' then
      SQL.Add(' AND '+NotCondSource  +' (STATION.CRUISE_ID IN (SELECT CRUISE.ID '+
              ' FROM CRUISE WHERE CRUISE.SOURCE_ID IN (SELECT SOURCE.ID FROM' +
              ' SOURCE WHERE SOURCE.NAME='+QuotedStr(cbSource.text)+'))) ');
    if cbInstitute.text<>'' then
      SQL.Add(' AND '+NotCondInstitute  +' (STATION.CRUISE_ID IN (SELECT CRUISE.ID '+
              ' FROM CRUISE WHERE CRUISE.INSTITUTE_ID IN (SELECT INSTITUTE.ID FROM' +
              ' INSTITUTE WHERE INSTITUTE.NAME='+QuotedStr(cbInstitute.text)+'))) ');
    if cbProject.text<>'' then begin
      SQL.Add(' AND '+NotCondProject  +' (STATION.CRUISE_ID IN (SELECT CRUISE.ID '+
              ' FROM CRUISE WHERE CRUISE.PROJECT_ID IN (SELECT PROJECT.ID FROM' +
              ' PROJECT WHERE PROJECT.NAME='+QuotedStr(cbProject.text)+'))) ');
    end;

    SQL.Add(' ORDER BY DATEANDTIME ' );
  //  showmessage(SQL.Text);

    ParamByName('SSIDMin').AsInteger:=seIDMin.Value;
    ParamByName('SSIDMax').AsInteger:=seIDMax.Value;

    ParamByName('SSLatMin').AsFloat:=seLatMin.Value;
    ParamByName('SSLatMax').AsFloat:=seLatMax.Value;
    ParamByName('SSLonMin').AsFloat:=seLonMin.Value;
    ParamByName('SSLonMax').AsFloat:=seLonMax.Value;
     if chkPeriod.Checked=true then begin
       ParamByName('SSYearMin').AsInteger:=SSYearMin;
       ParamByName('SSYearMax').AsInteger:=SSYearMax;
       ParamByName('SSMonthMin').AsInteger:=SSMonthMin;
       ParamByName('SSMonthMax').AsInteger:=SSMonthMax;
       ParamByName('SSDayMin').AsInteger:=SSDayMin;
       ParamByName('SSDayMax').AsInteger:=SSDayMax;
     end;
     if chkPeriod.Checked=false then begin
       ParamByName('SSDateMin').AsDateTime:=dtpDateMin.DateTime;
       ParamByName('SSDateMax').AsDateTime:=dtpDateMax.DateTime;
     end;

   Open;
   //Last changes
   Last;
   First;
 end;

 SelectionInfo;
 CDSNavigation;

 aShowStations.Execute();
end;


procedure Tfrmosmain.DBGridCruisePrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
 if (column.FieldName='ID') or
    (column.FieldName='DATE_ADDED') or
    (column.FieldName='DATE_UPDATED') then begin
    TDBGrid(sender).Canvas.Brush.Color := clBtnFace;
 end;

 if (gdRowHighlight in AState) then begin
    TDBGrid(Sender).Canvas.Brush.Color := clNavy;
    TDBGrid(Sender).Canvas.Font.Color  := clYellow;
    TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
 end;
end;

procedure Tfrmosmain.DBGridCruiseTitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(frmdm.QCruise, Column.FieldName);
end;


procedure Tfrmosmain.iSelectCruiseClick(Sender: TObject);
begin
   with frmdm.Q do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT ');
      SQL.Add(' ID, LATITUDE, LONGITUDE, DATEANDTIME, BOTTOMDEPTH, ');
      SQL.Add(' LASTLEVEL_M, LASTLEVEL_DBAR, CRUISE_ID, INSTRUMENT_ID, ');
      SQL.Add(' ST_NUMBER_ORIGIN, ST_ID_ORIGIN, CAST_NUMBER, QCFLAG, ');
      SQL.Add(' STVERSION, DUPLICATE, MERGED, ACCESSION_NUMBER, ');
      SQL.Add(' DATE_ADDED, DATE_UPDATED ');
      SQL.Add(' FROM STATION ');
      SQL.Add(' WHERE ');
      SQL.Add(' CRUISE_ID=:CRUISE ');
      ParamByName('CRUISE').AsInteger:=frmdm.QCruise.FieldByName('ID').AsInteger;
     Open;
     //Last changes
     Last;
     First;
   end;

   SelectionInfo;
   CDSNavigation;

   aShowStations.Execute();
end;


procedure Tfrmosmain.lbResetAreaClick(Sender: TObject);
begin
  seLatMin.Value:=IBLatMin;
  seLatMax.Value:=IBLatMax;
  seLonMin.Value:=IBLonMin;
  seLonMax.Value:=IBLonMax;
end;

procedure Tfrmosmain.lbResetAuxClick(Sender: TObject);
begin
  cbPlatform.Clear;
  cbCountry.Clear;
  cbSource.Clear;
  cbInstitute.Clear;
  cbProject.Clear;

  seIDMin.Value:=IDMin;
  seIDMax.Value:=IDMax;
end;

procedure Tfrmosmain.lbResetDatesClick(Sender: TObject);
begin
  dtpDateMin.DateTime:=IBDateMin;
  dtpDateMax.DateTime:=IBDateMax;
end;


procedure Tfrmosmain.CDSNavigation;
Var
ID:integer;
begin
ID:=frmdm.Q.FieldByName('ID').AsInteger;
if NavigationOrder=false then exit;

 If NavigationOrder=true then begin
  NavigationOrder:=false; //blocking everthing until previous operations have been completed
     if frmstations_open=true then begin
       frmdm.QCruise.Locate('ID', frmdm.Q.FieldByName('CRUISE_ID').AsInteger,[]);
     end;
     if frmmap_open=true then frmmap.ChangeID(ID); //Map
     if frmparameters_station_open=true then frmparameters_station.ChangeID(ID);
     if frmparameters_allprofiles_open=true then frmparameters_allprofiles.ChangeID(ID);
 //  if InfoOpen      =true then Info.ChangeID;
 //  if QProfilesOpen =true then QProfiles.ChangeStation(ID);
 //  if DensOpen      =true then QDensity.ChangeDensStation(ID);
 //  if TSOPen        =true then frmToolTSDiagram.ChangeID;
 //  if SinglePrfOpen =true then SingleParameter.TblChange(ID);

 //  if MeteoOpen     =true then Meteo.ChangeAbsnum;
 //  if MLDOpen       =true then MLD.ChangeID;
 //  if TrackOpen     =true then frmVesselSpeed.ChangeID;
 //  if RossbyOpen    =true then Rossby.ChangeID;
 //  if QCTDOpen      =true then QCTD.ChangeID;
 //  if VertIntOpen   =true then VertInt.TblChange(ID)

  NavigationOrder:=true; //Завершили, открываем доступ к навигации
 end;
end;


procedure Tfrmosmain.iDBStatisticsClick(Sender: TObject);
begin
frmosstatistics := Tfrmosstatistics.Create(Self);
 try
  if not frmosstatistics.ShowModal = mrOk then exit;
 finally
   frmosstatistics.Free;
   frmosstatistics := nil;
 end;
end;

procedure Tfrmosmain.iDIVAndClick(Sender: TObject);
begin
  frmosexport_divand := Tfrmosexport_divand.Create(Self);
   try
    if not frmosexport_divand.ShowModal = mrOk then exit;
   finally
     frmosexport_divand.Free;
     frmosexport_divand := nil;
   end;
end;


procedure Tfrmosmain.iSettingsClick(Sender: TObject);
begin
 frmsettings := Tfrmsettings.Create(Self);
  try
   if not frmsettings.ShowModal = mrOk then exit;
  finally
    frmsettings.Free;
    frmsettings := nil;
  end;
end;


(* Open SupportTables.FDB *)
procedure Tfrmosmain.iKnowledgeDBOpenClick(Sender: TObject);
begin
 if frmcodes_open=true then frmcodes.SetFocus else
    begin
      frmcodes := Tfrmcodes.Create(Self);
      frmcodes.Show;
    end;
 frmcodes_open:=true;
end;


(**)
procedure Tfrmosmain.aOpenDatabaseExecute(Sender: TObject);
begin
  OD.Filter:='Firebird Database|*.FDB;*.fdb';
  if OD.Execute then begin
   IBName:=OD.FileName;
   OpenDatabase;
  end;
end;

procedure Tfrmosmain.aProfilesStationAllExecute(Sender: TObject);
begin
  if frmparameters_station_open=true then frmparameters_station.SetFocus else
     begin
       frmparameters_station := Tfrmparameters_station.Create(Self);
       frmparameters_station.Show;
     end;
  frmparameters_station_open:=true;
end;


procedure Tfrmosmain.aProfilesSelectedAllPlotExecute(Sender: TObject);
begin
  if frmparameters_list_open=true then frmparameters_list.SetFocus else
     begin
       frmparameters_list := Tfrmparameters_list.Create(Self);
       frmparameters_list.Show;
     end;
  frmparameters_list.Caption:='PROFILES';
  frmparameters_list_open:=true;
end;


procedure Tfrmosmain.aShowStationsExecute(Sender: TObject);
begin
  if frmstations_open=true then frmosstation.SetFocus else
     begin
       frmosstation := Tfrmosstation.Create(Self);
       frmosstation.Show;
     end;
  frmstations_open:=true;
end;

procedure Tfrmosmain.btnAdvancedSelectionClick(Sender: TObject);
begin
  frmadvancedselection := Tfrmadvancedselection.Create(Self);
   try
    if not frmadvancedselection.ShowModal = mrOk then exit;
   finally
     frmadvancedselection.Free;
     frmadvancedselection := nil;
   end;
end;


(* Open local database *)
procedure Tfrmosmain.OpenDatabase;
begin
   try
    frmdm.IBDB.Close(false);
    frmdm.IBDB.DatabaseName:=IBName;
    frmdm.IBDB.Open;
   except
     on E: Exception do
       if MessageDlg(E.Message, mtWarning, [mbOk], 0)=mrOk then exit;
   end;
  DatabaseInfo;
  ItemsVisibility;
end;


(* gathering info about the database *)
procedure Tfrmosmain.DatabaseInfo;
var
TRt_DB1, TRt_DB2:TSQLTransaction;
Qt_DB1, Qt_DB2:TSQLQuery;
TempList:TListBox;

k:integer;
begin
(* temporary transaction for main database *)
TRt_DB1:=TSQLTransaction.Create(self);
TRt_DB1.DataBase:=frmdm.IBDB;

(* temporary query for main database *)
Qt_DB1 :=TSQLQuery.Create(self);
Qt_DB1.Database:=frmdm.IBDB;
Qt_DB1.Transaction:=TRt_DB1;

(* temporary transaction for support database *)
TRt_DB2:=TSQLTransaction.Create(self);
TRt_DB2.DataBase:=frmdm.SupportDB;

(* temporary query for support database *)
Qt_DB2 :=TSQLQuery.Create(self);
Qt_DB2.Database:=frmdm.SupportDB;
Qt_DB2.Transaction:=TRt_DB2;

   with Qt_DB1 do begin
    Close;
        SQL.Clear;
        SQL.Add(' select count(ID) as StCount, ');
        SQL.Add(' min(ID) as IDMin, max(ID) as IDMax, ');
        SQL.Add(' min(LATITUDE) as StLatMin, max(LATITUDE) as StLatMax, ');
        SQL.Add(' min(LONGITUDE) as StLonMin, max(LONGITUDE) as StLonMax, ');
        SQL.Add(' min(DATEANDTIME) as StDateMin, ');
        SQL.Add(' max(DATEANDTIME) as StDateMax ');
        SQL.Add(' from STATION');
    Open;
      IBCount:=FieldByName('StCount').AsInteger;
       if IBCount>0 then begin
         IDMin     :=FieldByName('IDMin').AsInteger;
         IDMax     :=FieldByName('IDMax').AsInteger;
         IBLatMin  :=FieldByName('StLatMin').AsFloat;
         IBLatMax  :=FieldByName('StLatMax').AsFloat;
         IBLonMin  :=FieldByName('StLonMin').AsFloat;
         IBLonMax  :=FieldByName('StLonMax').AsFloat;
         IBDateMin :=FieldByName('StDateMin').AsDateTime;
         IBDateMax :=FieldByName('StDateMax').AsDateTime;

         with sbDatabase do begin
           Panels[1].Text:='LtMin: '+floattostr(IBLatMin);
           Panels[2].Text:='LtMax: '+floattostr(IBLatMax);
           Panels[3].Text:='LnMin: '+floattostr(IBLonMin);
           Panels[4].Text:='LnMax: '+floattostr(IBLonMax);
           Panels[5].Text:='DateMin: '+datetostr(IBDateMin);
           Panels[6].Text:='DateMax: '+datetostr(IBDateMax);
           Panels[7].Text:='Stations: '+inttostr(IBCount);
         end;

         seIDMin.Value:=IDMin;
         seIdMax.Value:=IDMax;
         seLatMin.Value:=IBLatMin;
         seLatMax.Value:=IBLatMax;
         seLonMin.Value:=IBLonMin;
         seLonMax.Value:=IBLonMax;

         dtpDateMin.DateTime:=IBDateMin;
         dtpDateMax.DateTime:=IBDateMax;

      end else for k:=1 to 7 do sbDatabase.Panels[k].Text:='---';
    Close;
   end;

   (* permanent list for parameter tables *)
   ListBox1.Clear;

   try
   (* temporary list for all tables from Db *)
    TempList:=TListBox.Create(self);

   (* list of all tables *)
   frmdm.IBDB.GetTableNames(TempList.Items,False);

    for k:=0 to TempList.Items.Count-1 do
     if (copy(TempList.Items.Strings[k], 1, 2)='P_') then
       ListBox1.Items.Add(TempList.Items.Strings[k]);
   finally
     TempList.Free;
   end;

   with frmdm.QCruise do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT ');
     SQL.Add(' CRUISE.ID, PLATFORM.NAME as PLATFORM, COUNTRY.NAME as COUNTRY, ');
     SQL.Add(' SOURCE.NAME as SOURCE, INSTITUTE.NAME as INSTITUTE, ');
     SQL.Add(' PROJECT.NAME as PROJECT, CRUISE.DATE_ADDED, CRUISE.DATE_UPDATED, ');
     SQL.Add(' CRUISE.CRUISE_NUMBER, CRUISE.DATE_START, CRUISE.DATE_END, ');
     SQL.Add(' CRUISE.STATIONS_AMOUNT, CRUISE.PI, CRUISE.NOTES ');
     SQL.Add(' FROM CRUISE, PLATFORM, COUNTRY, SOURCE, INSTITUTE, PROJECT ');
     SQL.Add(' WHERE ');
     SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID and ');
     SQL.Add(' CRUISE.COUNTRY_ID=COUNTRY.ID and ');
     SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID and ');
     SQL.Add(' CRUISE.INSTITUTE_ID=INSTITUTE.ID and ');
     SQL.Add(' CRUISE.PROJECT_ID=PROJECT.ID');
     SQL.Add(' ORDER by PLATFORM.NAME, CRUISE.DATE_START ');
    Open;
    Last;
    First;
   end;

   with frmdm.QEntry do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT * ');
    SQL.Add(' FROM ENTRY ');
    SQL.Add(' ORDER by ID ');
   Open;
   Last;
   First;
   end;

  TRt_DB1.Commit;
  TRt_DB2.Commit;

  Qt_DB1.Free;
  Qt_DB2.Free;

  TRt_DB1.free;
  TRt_DB2.free;
end;


(* gathering info about selected stations *)
procedure Tfrmosmain.SelectionInfo;
var
  k: integer;
  lat1, lon1:real;
  dat1:TDateTime;
  items_enabled:boolean;
begin

 try
  frmdm.Q.DisableControls;

  SLatMin:=90;  SLatMax:=-90;
  SLonMin:=180; SLonMax:=-180;
  SDateMin:=Now;

  frmdm.Q.First;
  while not frmdm.Q.EOF do begin
   lat1:=frmdm.Q.FieldByName('LATITUDE').AsFloat;
   lon1:=frmdm.Q.FieldByName('LONGITUDE').AsFloat;
   dat1:=frmdm.Q.FieldByName('DATEANDTIME').AsDateTime;

     if lat1<SLatMin then SLatMin:=lat1;
     if lat1>SLatMax then SLatMax:=lat1;
     if lon1<SLonMin then SLonMin:=lon1;
     if lon1>SLonMax then SLonMax:=lon1;
     if CompareDate(dat1, SDateMin)<0 then SDateMin:=dat1;
     if CompareDate(dat1, SDateMax)>0 then SDateMax:=dat1;

    frmdm.Q.Next;
  end;
  frmdm.Q.First;

     SCount:=frmdm.Q.RecordCount;
     if SCount>0 then begin
       with sbSelection do begin
         Panels[1].Text:='LtMin: '+floattostr(SLatMin);
         Panels[2].Text:='LtMax: '+floattostr(SLatMax);
         Panels[3].Text:='LnMin: '+floattostr(SLonMin);
         Panels[4].Text:='LnMax: '+floattostr(SLonMax);
         Panels[5].Text:='DateMin: '+datetostr(SDateMin);
         Panels[6].Text:='DateMax: '+datetostr(SDateMax);
         Panels[7].Text:='Stations: '+inttostr(SCount);
       end;
     end else for k:=1 to 7 do sbSelection.Panels[k].Text:='---';

  (* if there are selected station enabling some menu items *)
  if SCount>0 then items_enabled:=true else items_enabled:=false;

  finally
     frmdm.Q.EnableControls;
  end;

  iDBStatistics.Enabled:=items_enabled;
  aShowStations.Enabled:=items_enabled;
  aMapAllStations.Enabled:=items_enabled;
  aMapKML.Enabled:=items_enabled;
  aProfilesStationAll.Enabled:=items_enabled;
  aProfilesSelectedAllPlot.Enabled:=items_enabled;
end;


procedure Tfrmosmain.ItemsVisibility;
begin
 PageControl1.Enabled:=true;
end;


procedure Tfrmosmain.iNewDatabaseClick(Sender: TObject);
begin
 SD.Filter:='Firebird database|*.FDB';
 SD.DefaultExt:='FDB';
 if SD.Execute then begin
    CreateNewDB(SD.FileName);
     frmdm.IBDB.Close;
     frmdm.IBDB.DatabaseName:=SD.FileName;
    IBName:=frmdm.IBDB.DatabaseName;
  OpenDatabase;
 end;
end;


procedure Tfrmosmain.iLoadARGOClick(Sender: TObject);
begin
 { frmloadargo := Tfrmloadargo.Create(Self);
   try
    if not frmloadargo.ShowModal = mrOk then exit;
   finally
     frmloadargo.Free;
     frmloadargo := nil;
   end; }
end;


procedure Tfrmosmain.iLoadITPClick(Sender: TObject);
begin
  frmLoadITP := TfrmLoadITP.Create(Self);
   try
    if not frmLoadITP.ShowModal = mrOk then exit;
   finally
     frmLoadITP.Free;
     frmLoadITP := nil;
   end;
end;

procedure Tfrmosmain.iLoad_GLODAP_2019_v2_productClick(Sender: TObject);
begin
  frmloadGLODAP_2019_v2_product := TfrmloadGLODAP_2019_v2_product.Create(Self);
 try
  if not frmloadGLODAP_2019_v2_product.ShowModal = mrOk then exit;
 finally
   frmloadGLODAP_2019_v2_product.Free;
   frmloadGLODAP_2019_v2_product := nil;
 end;
end;

procedure Tfrmosmain.iLoad_ITPClick(Sender: TObject);
begin
  frmLoadITP := TfrmLoadITP.Create(Self);
 try
  if not frmLoadITP.ShowModal = mrOk then exit;
 finally
   frmLoadITP.Free;
   frmLoadITP := nil;
 end;
end;

procedure Tfrmosmain.iLoad_Pangaea_CTD_tabClick(Sender: TObject);
begin
    frmloadPangaeaTab := TfrmloadPangaeaTab.Create(Self);
 try
  if not frmloadPangaeaTab.ShowModal = mrOk then exit;
 finally
   frmloadPangaeaTab.Free;
   frmloadPangaeaTab := nil;
 end;
end;

procedure Tfrmosmain.iLoad_WOD18Click(Sender: TObject);
begin
 frmloadWOD18 := TfrmloadWOD18.Create(Self);
try
 if not frmloadWOD18.ShowModal = mrOk then exit;
finally
  frmloadWOD18.Free;
  frmloadWOD18 := nil;
end;
end;

procedure Tfrmosmain.iLoad_WODClick(Sender: TObject);
begin
  frmLoadASC_WOD := TfrmLoadASC_WOD.Create(Self);
 try
  if not frmLoadASC_WOD.ShowModal = mrOk then exit;
 finally
   frmLoadASC_WOD.Free;
   frmLoadASC_WOD := nil;
 end;
end;


procedure Tfrmosmain.aMapAllStationsExecute(Sender: TObject);
begin
 if frmmap_open=true then frmmap.SetFocus else
    begin
       frmmap := Tfrmmap.Create(Self);
       frmmap.Show;
    end;
  frmmap.btnShowAllStationsClick(self);
  frmmap_open:=true;
end;


procedure Tfrmosmain.aMapSelectedStationExecute(Sender: TObject);
begin
 if frmmap_open=true then frmmap.SetFocus else
    begin
       frmmap := Tfrmmap.Create(Self);
       frmmap.Show;
    end;
  frmmap.btnShowSelectedClick(self);
  frmmap_open:=true;
end;


procedure Tfrmosmain.aMapKMLExecute(Sender: TObject);
begin
  ExportKML_;
end;


(* Launching scripts *)
procedure Tfrmosmain.RunScript(ExeFlag:integer; cmd:string; Sender:TMemo);
Var
  Ini:TIniFile;
  P:TProcess;
  ExeName, buf, s: string;
  WaitOnExit:boolean;
  i, j: integer;
begin
(*
  ExeFlag = 0 /Random executable file
  ExeFlag = 1 /Python
  ExeFlag = 2 /Surfer
  ExeFlag = 3 /Grapher
  ExeFlag = 4 /CDO
  ExeFlag = 5 /NCO
*)

{$IFDEF WINDOWS}
  Ini := TIniFile.Create(IniFileName);
  try
    case ExeFlag of
     0: begin
        ExeName:='';
        WaitOnExit:=false;
     end;
     1: begin
        ExeName:=Ini.ReadString('main', 'PythonPath', '');
        WaitOnExit:=false;
        if not FileExists(ExeName) then
           if Messagedlg(SNoPython, mtwarning, [mbOk], 0)=mrOk then exit;
     end;
     2: begin
        ExeName:=Ini.ReadString('main', 'SurferPath',  '');
        WaitOnExit:=true;
        if not FileExists(ExeName) then
           if Messagedlg(SNoSurfer, mtwarning, [mbOk], 0)=mrOk then exit;
     end;
     3: begin
        ExeName:=Ini.ReadString('main', 'GrapherPath', '');
        WaitOnExit:=true;
        if not FileExists(ExeName) then
           if Messagedlg(SNoGrapher, mtwarning, [mbOk], 0)=mrOk then exit;
     end;
     4: begin
        ExeName:=GlobalSupportPath+'cdo'+PathDelim+'cdo.exe';
        WaitOnExit:=true;
        if not FileExists(ExeName) then
           if Messagedlg(SNoCDO,    mtwarning, [mbOk], 0)=mrOk then exit;
     end;
    end;
  finally
   ini.Free;
  end;
{$ENDIF}

{$IFDEF UNIX}
  Case ExeFlag of
    1: ExeName :='python3';
    4: ExeName :='cdo';
    5: ExeName :='nco';
  end;
{$ENDIF}

 try
  P:=TProcess.Create(Nil);
  P.Commandline:=trim(ExeName+' '+cmd);
//  showmessage(P.CommandLine);
  P.Options:=[poUsePipes, poNoConsole];
  if WaitOnExit=true then P.Options:=P.Options+[poWaitOnExit];
  P.Execute;

  repeat
   SetLength(buf, buf_len);
   SetLength(buf, p.output.Read(buf[1], length(buf))); //waits for the process output
   // cut the incoming stream to lines:
   s:=s + buf; //add to the accumulator
   repeat //detect the line breaks and cut.
     i:=Pos(#13, s);
     j:=Pos(#10, s);
     if i=0 then i:=j;
     if j=0 then j:=i;
     if j = 0 then Break; //there are no complete lines yet.
     if (Sender<> nil) then begin
       Sender.Lines.Add(Copy(s, 1, min(i, j) - 1)); //return the line without the CR/LF characters
       Application.ProcessMessages;
     end;
     s:=Copy(s, max(i, j) + 1, length(s) - max(i, j)); //remove the line from accumulator
   until false;
 until buf = '';
 if (s <> '') and (Sender<>nil) then begin
   Sender.Lines.Add(s);
   Application.ProcessMessages;
 end;
finally
 P.Free;
end;
end;


procedure Tfrmosmain.iAboutClick(Sender: TObject);
begin
  if messagedlg(AboutProgram, mtInformation, [mbOk], 0)=mrOk then exit;
end;



procedure Tfrmosmain.cbOnDropDown(Sender: TObject);
var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
  tbl:string;
begin
  if (Sender as TComboBox).Items.Count=0 then begin
   try
    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;

    Qt :=TSQLQuery.Create(self);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

    tbl:=Copy((Sender as TComboBox).Name, 3, length((Sender as TComboBox).Name));

    Qt.Close;
    Qt.SQL.Text:=' SELECT DISTINCT NAME FROM '+tbl+' ORDER BY NAME ';
    Qt.Open;

    while not Qt.Eof do begin
      (Sender as TComboBox).Items.Add(Qt.Fields[0].AsString);
     Qt.Next;
    end;
    Qt.Close;
    TRt.Commit;
   // DBGridCruise.Columns[1].PickList:=cbPlatform.Items;
   finally
    Qt.Free;
    TRt.Free;
   end;
 end;
end;

procedure Tfrmosmain.eCruise_IDClick(Sender: TObject);
begin
   eCruise_ID.Clear;
   eCruise_PLATFORM.Clear;
   eCruise_COUNTRY.Clear;
   eCruise_SOURCE.Clear;
   eCruise_Project.Clear;
   eCruise_Institute.Clear;
   eCruise_PI.Clear;
  frmdm.QCruise.Filtered:=false;
end;


(* ID *)
procedure Tfrmosmain.SearchID(Sender: TObject);
Begin
  if (Sender as TEdit).Text='' then exit;
    frmdm.QCruise.Locate('ID', StrToInt((Sender as TEdit).Text),[loCaseInsensitive, loPartialKey]);
end;

(* PLATFORM *)
procedure Tfrmosmain.SearchPLATFORM(Sender: TObject);
begin
  frmdm.QCruise.Filter:='PLATFORM = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  frmdm.QCruise.Filtered:=true;
end;

procedure Tfrmosmain.eCruise_NUMBERChange(Sender: TObject);
begin
  frmdm.QCruise.Filter:='CRUISE_NUMBER = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  frmdm.QCruise.Filtered:=true;
end;

(* SOURCE *)
procedure Tfrmosmain.SearchSOURCE(Sender: TObject);
begin
  frmdm.QCruise.Filter:='SOURCE = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  frmdm.QCruise.Filtered:=true;
end;

(* PI *)
procedure Tfrmosmain.SearchPI(Sender: TObject);
begin
  frmdm.QCruise.Filter:='PI = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  frmdm.QCruise.Filtered:=true;
end;

(* COUNTRY*)
procedure Tfrmosmain.SearchCOUNTRY(Sender: TObject);
begin
  frmdm.QCruise.Filter:='COUNTRY = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  frmdm.QCruise.Filtered:=true;
end;

(* INSTITUTE *)
procedure Tfrmosmain.SearchINSTITUTE(Sender: TObject);
begin
  frmdm.QCruise.Filter:='INSTITUTE = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  frmdm.QCruise.Filtered:=true;
end;

(* PROJECT *)
procedure Tfrmosmain.SearchPROJECT(Sender: TObject);
begin
  frmdm.QCruise.Filter:='PROJECT = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  frmdm.QCruise.Filtered:=true;
end;

(* Call for procedure to update dates and amount of stations for every cruise *)
procedure Tfrmosmain.btnUpdateCruiseStatisticsClick(Sender: TObject);
begin
 osservice.UpdateCruiseStatistics;
end;

(* Call for procedure to update last level *)
procedure Tfrmosmain.btnUpdateLastLEvelClick(Sender: TObject);
begin
 osservice.UpdateLastLevel;
end;


procedure Tfrmosmain.DBGridCruiseColumnSized(Sender: TObject);
begin
    eCruise_ID.Width:=DBGridCruise.Columns[0].Width+1;
    eCruise_PLATFORM.Width:=DBGridCruise.Columns[1].Width;
    eCruise_NUMBER.Width:=DBGridCruise.Columns[2].Width;
    eCruise_COUNTRY.Width:=DBGridCruise.Columns[3].Width;
    pfillercruise.Width:=(DBGridCruise.Columns[4].Width+
                          DBGridCruise.Columns[5].Width+
                          DBGridCruise.Columns[6].Width)-1;
    eCruise_SOURCE.Width:=DBGridCruise.Columns[7].Width;
    eCruise_PI.Width:=DBGridCruise.Columns[8].Width;
    eCruise_Institute.Width:=DBGridCruise.Columns[9].Width;
    eCruise_Project.Width:=DBGridCruise.Columns[10].Width;
end;


procedure Tfrmosmain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
Var
  Ini:TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
   try
    Ini.WriteInteger( 'osmain', 'top',    Top);
    Ini.WriteInteger( 'osmain', 'left',   Left);
    Ini.WriteInteger( 'osmain', 'width',  Width);
    Ini.WriteInteger( 'osmain', 'weight', Height);

    (* cruise table columns *)
    With DBGridCruise do begin
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col00', Columns[0].Width); //ID
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col01', Columns[1].Width); //Platform
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col02', Columns[2].Width); //Cruise #
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col03', Columns[3].Width); //Country
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col04', Columns[4].Width); //Start date
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col05', Columns[5].Width); //Finish date
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col06', Columns[6].Width); //Stations
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col07', Columns[7].Width); //Source
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col08', Columns[8].Width); //PI
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col09', Columns[9].Width); //Institute
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col10', Columns[10].Width);//Project
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col11', Columns[11].Width);//Date added
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col12', Columns[12].Width);//Date updated
    end;

   finally
     Ini.Free;
   end;
end;


end.


