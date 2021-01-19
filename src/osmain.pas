unit osmain;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, ComCtrls, LCLType,
  Menus, Dialogs, ActnList, StdCtrls, IniFiles, ExtCtrls, DateUtils, sqldb, DB,
  Buttons, DBGrids, Spin, DBCtrls, DateTimePicker, Process, Math, Grids, dynlibs,
  LCLIntf, ComboEx, DBExtCtrls;

type
   MapDS=record
     ID:int64;
     Cruise_ID:int64;
     Latitude:real;
     Longitude:real;
     x:int64;
     y:int64;
end;

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
    aMeteo: TAction;
    aSettings: TAction;
    aProfilesStationSingle: TAction;
    aProfilesSelectedAllPlot: TAction;
    aMapSelectedStation: TAction;
    aProfilesStationAll: TAction;
    aMapKML: TAction;
    aOpenDatabase: TAction;
    aMapAllStations: TAction;
    AL: TActionList;
    btnOpenOceanFDB: TBitBtn;
    btnAddEntry: TToolButton;
    btnSaveCruise: TToolButton;
    btnSaveEntry: TToolButton;
    btnSelectStations: TButton;
    btnCustomSQLQuery: TButton;
    btnSelectCruises: TButton;
    btnSelectID: TButton;
    cbCountry: TCheckComboBox;
    cbCruiseCountry: TCheckComboBox;
    cbCruiseInstitute: TCheckComboBox;
    cbCruiseProject: TCheckComboBox;
    cbCruiseSource: TCheckComboBox;
    cbCruisePlatform: TCheckComboBox;
    cbCruiseCruiseNum: TCheckComboBox;
    cbInstitute: TCheckComboBox;
    cbPlatform: TCheckComboBox;
    cbCruisePredefinedRegion: TComboBox;
    cbProject: TCheckComboBox;
    cbSource: TCheckComboBox;
    cgQCFlag: TCheckGroup;
    cgCruiseQCFlag: TCheckGroup;
    chkCRUISEDateandtime: TCheckBox;
    chkCruiseIDRange: TCheckBox;
    chkCruiseNumStations: TCheckBox;
    chkCruiseQCFlag: TCheckBox;
    chkCRUISERegion: TCheckBox;
    chkDateandTime: TCheckBox;
    chkDepth: TCheckBox;
    chkIDRange: TCheckBox;
    chkParameter: TCheckBox;
    chkQCFlag: TCheckBox;
    chkRegion: TCheckBox;
    chkShowQuery: TCheckBox;
    chkPeriod: TCheckBox;
    chkCruiseNOTSourceNum: TCheckBox;
    chkNOTCountry: TCheckBox;
    chkNOTInstitute: TCheckBox;
    chkNOTPlatform: TCheckBox;
    chkNOTProject: TCheckBox;
    chkNOTSource: TCheckBox;
    cgParameter: TCheckGroup;
    chkIgnoreDup: TCheckBox;
    chkCruiseNOTCountry: TCheckBox;
    chkCruiseNOTInstitute: TCheckBox;
    chkCruiseNOTPlatform: TCheckBox;
    chkCruiseNOTProject: TCheckBox;
    chkCruiseNOTSource: TCheckBox;
    chkCruiseIgnoreDup: TCheckBox;
    cbEntryType: TComboBox;
    cbPredefinedRegion: TComboBox;
    chkCruiseShowQuery: TCheckBox;
    DBCruiseCountry: TDBComboBox;
    DBCruiseInstitute: TDBComboBox;
    DBCruiseLatMax: TDBEdit;
    DBCruiseLatMin: TDBEdit;
    DBCruiseLonMax: TDBEdit;
    DBCrusieStationsTotal: TDBEdit;
    DBCrusieDateStartTotal: TDBDateEdit;
    DBCrusieDateEndTotal: TDBDateEdit;
    DBStationAccessionNum: TDBEdit;
    DBStationSourceID: TDBEdit;
    DBCruiseLonMin: TDBEdit;
    DBCruiseProject: TDBComboBox;
    DBCruiseUpdated: TDBDateEdit;
    DBCrusiePI: TDBEdit;
    DBCrusieExpocode: TDBEdit;
    DBStationUpdated: TDBDateEdit;
    DBStationAdded: TDBDateEdit;
    DBCrusieAdded: TDBDateEdit;
    DBGridCruise: TDBGrid;
    DBGridEntry: TDBGrid;
    DBGridStation: TDBGrid;
    DBCruiseNotes: TDBMemo;
    DBMemoEntriy: TDBMemo;
    dtpCruiseDateAddedMax: TDateTimePicker;
    dtpCruiseDateAddedMin: TDateTimePicker;
    dtpCruiseDateDBMax: TDateTimePicker;
    dtpCruiseDateDBMin: TDateTimePicker;
    dtpCruiseDateTotMax: TDateTimePicker;
    dtpCruiseDateTotMin: TDateTimePicker;
    dtpCruiseDateUpdatedMax: TDateTimePicker;
    dtpCruiseDateUpdatedMin: TDateTimePicker;
    dtpDateAddedMax: TDateTimePicker;
    dtpDateAddedMin: TDateTimePicker;
    dtpDateMax: TDateTimePicker;
    dtpDateMin: TDateTimePicker;
    dtpDateUpdatedMax: TDateTimePicker;
    dtpDateUpdatedMin: TDateTimePicker;
    gbAuxiliaryParameters: TGroupBox;
    gbAuxiliaryParameters1: TGroupBox;
    gbDepth: TGroupBox;
    GroupBox1: TGroupBox;
    gbCRUISENumStations: TGroupBox;
    gbCruiseRegion: TGroupBox;
    gbCruiseDateandTime: TGroupBox;
    gbIDRange: TGroupBox;
    gbDateandTime: TGroupBox;
    gbRegion: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    gbCruiseIDRange: TGroupBox;
    iProfilesAll: TMenuItem;
    ishowselectedstation: TMenuItem;
    iLoad_Pangaea_CTD_tab: TMenuItem;
    iLoad_WOD18: TMenuItem;
    iMap: TMenuItem;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbResetSearchCruises: TLabel;
    lbResetSearchStations: TLabel;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    iKnowledgeDB: TMenuItem;
    iSupportTables: TMenuItem;
    iQC_dbar_meter: TMenuItem;
    iExportASCII: TMenuItem;
    iLoadARGO: TMenuItem;
    iUpdateUnits: TMenuItem;
    iVisualization: TMenuItem;
    iPlotBathymetry: TMenuItem;
    iQCflagfromfile: TMenuItem;
    iExportCIA: TMenuItem;
    iQC_WideRanges: TMenuItem;
    iMeteo: TMenuItem;
    iTDdiagrams: TMenuItem;
    btnEntryAddStations: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    iInsertBottomDepthGEBCO: TMenuItem;
    itest: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    iStandarddeviationslayers: TMenuItem;
    iVisualizationSurfer: TMenuItem;
    iVisualizationSurferSquares: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    iSelectEntry: TMenuItem;
    iInsertLastLevel: TMenuItem;
    iExportFirebirdDB: TMenuItem;
    ioutliers: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    iVisualizationGrapferHistorgam: TMenuItem;
    MenuItem21: TMenuItem;
    iExportCOMFORT: TMenuItem;
    iExportCOMFORT_table: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    iload_ices: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    iSelectCruise: TMenuItem;
    iServiceStatistics: TMenuItem;
    iDBStatistics_AK: TMenuItem;
    iDuplicates: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    iExportDIVAnd: TMenuItem;
    iQC: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel3: TPanel;
    pcDepth: TPageControl;
    pcRegion1: TPageControl;
    pDataCruise: TPanel;
    pcCruiseDateandTime: TPageControl;
    pcCruiseNumStations: TPageControl;
    pcRegion: TPageControl;
    pcDateandTime: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    pEntryFilter: TPanel;
    PMStation: TPopupMenu;
    PMCruise: TPopupMenu;
    PMEntry: TPopupMenu;
    sbCruiseSearch: TScrollBox;
    sbDatabase: TStatusBar;
    sbSelection: TStatusBar;
    ODir: TSelectDirectoryDialog;
    sbStationSearch: TScrollBox;
    sbSelectedCruise: TScrollBox;
    seAroundPointLat: TFloatSpinEdit;
    seCruiseAroundPointLat: TFloatSpinEdit;
    seAroundPointLon: TFloatSpinEdit;
    seCruiseAroundPointLon: TFloatSpinEdit;
    seAroundPointRaduis: TSpinEdit;
    seCruiseAroundPointRaduis: TSpinEdit;
    seCruiseStationsDatabaseMax: TSpinEdit;
    seCruiseStationsDatabaseMin: TSpinEdit;
    seCruiseStationsDuplicateMax: TSpinEdit;
    seCruiseStationsDuplicateMin: TSpinEdit;
    seCruiseStationsTotalMax: TSpinEdit;
    seCruiseStationsTotalMin: TSpinEdit;
    seIDMax: TSpinEdit;
    seIDMin: TSpinEdit;
    seCruiseIDMax: TSpinEdit;
    seCruiseIDMin: TSpinEdit;
    iSettings: TMenuItem;
    iLoad: TMenuItem;
    iTools: TMenuItem;
    iLoad_ITP: TMenuItem;
    MenuItem1: TMenuItem;
    iLoad_GLODAP_2019_v2_product: TMenuItem;
    iStatistics: TMenuItem;
    iDBStatistics: TMenuItem;
    MenuItem3: TMenuItem;
    iLoad_GLODAP_2019_v2: TMenuItem;
    OD: TOpenDialog;
    PageControl1: TPageControl;
    SD: TSaveDialog;
    Memo1: TMemo;
    MM: TMainMenu;
    iFile: TMenuItem;
    iNewDatabase: TMenuItem;
    iOpenDatabase: TMenuItem;
    iHelp: TMenuItem;
    iHelpContent: TMenuItem;
    iAbout: TMenuItem;
    N3: TMenuItem;
    iExit: TMenuItem;
    ListBox1: TListBox;
    seDepthMin: TSpinEdit;
    seDepthMax: TSpinEdit;
    seGEBCOMin: TSpinEdit;
    seGEBCOMax: TSpinEdit;
    seLatMax: TFloatSpinEdit;
    seCruiseLatMax: TFloatSpinEdit;
    seLatMin: TFloatSpinEdit;
    seCruiseLatMin: TFloatSpinEdit;
    seLonMax: TFloatSpinEdit;
    seLastLevelMin: TFloatSpinEdit;
    seLastLevelMax: TFloatSpinEdit;
    seCruiseLonMax: TFloatSpinEdit;
    seLonMin: TFloatSpinEdit;
    seCruiseLonMin: TFloatSpinEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    TabSheet14: TTabSheet;
    TabSheet15: TTabSheet;
    TabSheet16: TTabSheet;
    TabSheet17: TTabSheet;
    TabSheet18: TTabSheet;
    TabSheet19: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    TabSheet9: TTabSheet;
    tbCruise: TToolBar;
    tbFastAccess: TToolBar;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    tsSelectedStations: TTabSheet;
    ToolBar2: TToolBar;
    btnRemoveEntry: TToolButton;
    ToolButton3: TToolButton;
    tsMainEntries: TTabSheet;
    tsMainSelect: TTabSheet;
    tsMainCruises: TTabSheet;

    procedure aMapAllStationsExecute(Sender: TObject);
    procedure aMapKMLExecute(Sender: TObject);
    procedure aMapSelectedStationExecute(Sender: TObject);
    procedure aMeteoExecute(Sender: TObject);
    procedure aOpenDatabaseExecute(Sender: TObject);
    procedure aProfilesSelectedAllPlotExecute(Sender: TObject);
    procedure aProfilesStationAllExecute(Sender: TObject);
    procedure aProfilesStationSingleExecute(Sender: TObject);
    procedure aSettingsExecute(Sender: TObject);
    procedure btnAddCruiseClick(Sender: TObject);
    procedure btnAddEntryClick(Sender: TObject);
    procedure btnAdvancedSelectionClick(Sender: TObject);
    procedure btnCustomSQLQueryClick(Sender: TObject);
    procedure btnEntryAddStationsClick(Sender: TObject);
    procedure btnOpenOceanFDBClick(Sender: TObject);
    procedure btnRemoveEntryClick(Sender: TObject);
    procedure btnSaveCruiseClick(Sender: TObject);
    procedure btnSaveEntryClick(Sender: TObject);
    procedure btnSelectCruisesClick(Sender: TObject);
    procedure btnSelectIDClick(Sender: TObject);
    procedure btnSelectStationsClick(Sender: TObject);
    procedure cbCountryDropDown(Sender: TObject);
    procedure cbCruiseCruiseNumDropDown(Sender: TObject);
    procedure cbEntryTypeSelect(Sender: TObject);
    procedure cbInstituteDropDown(Sender: TObject);
    procedure cbPlatformDropDown(Sender: TObject);
    procedure cbPredefinedRegionDropDown(Sender: TObject);
    procedure cbProjectDropDown(Sender: TObject);
    procedure cbSourceDropDown(Sender: TObject);
    procedure chkCRUISEDateandtimeChange(Sender: TObject);
    procedure chkCruiseIDRangeChange(Sender: TObject);
    procedure chkCruiseNumStationsChange(Sender: TObject);
    procedure chkCruiseQCFlagChange(Sender: TObject);
    procedure chkCRUISERegionChange(Sender: TObject);
    procedure chkDateandTimeChange(Sender: TObject);
    procedure chkDepthChange(Sender: TObject);
    procedure chkIDRangeChange(Sender: TObject);
    procedure chkParameterChange(Sender: TObject);
    procedure chkQCFlagChange(Sender: TObject);
    procedure chkRegionChange(Sender: TObject);
    procedure DBCruiseCountryDropDown(Sender: TObject);
    procedure DBCruiseInstituteDropDown(Sender: TObject);
    procedure DBCruiseProjectDropDown(Sender: TObject);
    procedure DBGridCruiseCellClick(Column: TColumn);
    procedure DBGridCruiseEditingDone(Sender: TObject);
    procedure DBGridCruiseKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGridCruisePrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DBGridCruiseSelectEditor(Sender: TObject; Column: TColumn;
      var Editor: TWinControl);
    procedure DBGridCruiseTitleClick(Column: TColumn);
    procedure DBGridEntryTitleClick(Column: TColumn);
    procedure DBGridStation2CellClick(Column: TColumn);
    procedure DBGridStation2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGridStation2TitleClick(Column: TColumn);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure iAboutClick(Sender: TObject);
    procedure iDBStatisticsClick(Sender: TObject);
    procedure iDBStatistics_AKClick(Sender: TObject);
    procedure iExportDIVAndClick(Sender: TObject);
    procedure iDuplicatesClick(Sender: TObject);
    procedure iInsertBottomDepthGEBCOClick(Sender: TObject);
    procedure iExportCIAClick(Sender: TObject);
    procedure iExportCOMFORTClick(Sender: TObject);
    procedure iExportCOMFORT_tableClick(Sender: TObject);
    procedure iLoadARGOClick(Sender: TObject);
    procedure iLoadITPClick(Sender: TObject);
    procedure iLoad_GLODAP_2019_v2_productClick(Sender: TObject);
    procedure iload_icesClick(Sender: TObject);
    procedure iLoad_ITPClick(Sender: TObject);
    procedure iLoad_Pangaea_CTD_tabClick(Sender: TObject);
    procedure iLoad_WOD18Click(Sender: TObject);
    procedure iMeteoClick(Sender: TObject);
    procedure ioutliersClick(Sender: TObject);
    procedure iPlotBathymetryClick(Sender: TObject);
    procedure iQCflagfromfileClick(Sender: TObject);
    procedure iQC_dbar_meterClick(Sender: TObject);
    procedure iQC_WideRangesClick(Sender: TObject);
    procedure iSelectCruiseClick(Sender: TObject);
    procedure iNewDatabaseClick(Sender: TObject);
    procedure iSelectEntryClick(Sender: TObject);
    procedure iServiceStatisticsClick(Sender: TObject);
    procedure iSettingsClick(Sender: TObject);
    procedure iStandarddeviationslayersClick(Sender: TObject);
    procedure iSupportTablesClick(Sender: TObject);
    procedure iTDdiagramsClick(Sender: TObject);
    procedure iUpdateUnitsClick(Sender: TObject);
    procedure iVisualizationGrapferHistorgamClick(Sender: TObject);
    procedure iVisualizationSurferSquaresClick(Sender: TObject);
    procedure lbResetSearchCruisesClick(Sender: TObject);
    procedure lbResetSearchStationsClick(Sender: TObject);
    procedure iExportASCIIClick(Sender: TObject);
    procedure itestClick(Sender: TObject);
    procedure MenuItem19Click(Sender: TObject);
    procedure iInsertLastLevelClick(Sender: TObject);
    procedure iExportFirebirdDBClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);

  private
    procedure SelectGetCruisesFromStation(SQL_str:string);

    procedure PopulatePLATFORMList;
    procedure PopulateCOUNTRYList;
    procedure PopulateSOURCEList;
    procedure PopulateINSTITUTEList;
    procedure PopulatePROJECTList;

    procedure SaveSettingsStationSearch;
    procedure LoadSettingsCruiseSearch;
    procedure SaveSettingsCruiseSearch;

  public
    procedure OpenLocalDatabase(DBName:string);
    procedure DatabaseInfo;
    procedure SelectionInfo;
    procedure CDSNavigation;
    procedure ExpertModeOff;

    Procedure UpdateCruiseInfo(ID: int64; TotalEqualDB:boolean);
    Procedure InsertLastLevel;
    Procedure InsertGEBCODepth;
    Procedure PopulateQCFlagLists;
    Procedure PopulateInstrumentList;
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


const
  StationSQL =
    'SELECT '+
    'ID, LATITUDE, LONGITUDE, DATEANDTIME, BOTTOMDEPTH, LASTLEVEL_M, '+
    'LASTLEVEL_DBAR, CRUISE_ID, CAST_NUMBER, ST_NUMBER_ORIGIN, '+
    'ST_ID_ORIGIN, QCFLAG, STVERSION, DUPLICATE, BOTTOMDEPTH_GEBCO,  '+
    'ACCESSION_NUMBER, DATE_ADDED, DATE_UPDATED, SELECTED '+
    'FROM STATION ';

  CruiseSQL =
    'SELECT '+
    'CRUISE.ID, PLATFORM_ID, SOURCE_ID, PLATFORM.NAME AS PLATFORM, '+
    'SOURCE.NAME AS SOURCE,  CRUISE.CRUISE_NUMBER, '+
    'CRUISE.DATE_START_DATABASE, CRUISE.DATE_END_DATABASE, '+
    'CRUISE.STATIONS_DATABASE, CRUISE.STATIONS_DUPLICATES, '+
    'CRUISE.SELECTED, CRUISE.DUPLICATE '+
    'FROM CRUISE, PLATFORM, SOURCE ';

  CruiseDetailSQL =
    ' SELECT '+
    ' CRUISE.ID, INSTITUTE_ID, PROJECT_ID,  COUNTRY.NAME AS COUNTRY, '+
    ' INSTITUTE.NAME AS INSTITUTE, PROJECT.NAME AS PROJECT, '+
    ' CRUISE.DATE_ADDED, CRUISE.DATE_UPDATED, '+
    ' CRUISE.DATE_START_TOTAL, CRUISE.DATE_END_TOTAL, '+
    ' CRUISE.LATITUDE_MIN, CRUISE.LATITUDE_MAX, '+
    ' CRUISE.LONGITUDE_MIN, CRUISE.LONGITUDE_MAX, CRUISE.EXPOCODE, '+
    ' CRUISE.PI, CRUISE.NOTES, CRUISE.STATIONS_TOTAL, '+
    ' CRUISE.SELECTED '+
    ' FROM CRUISE, PLATFORM, COUNTRY, INSTITUTE, PROJECT '+
    ' WHERE '+
    ' CRUISE.PLATFORM_ID=PLATFORM.ID AND '+
    ' PLATFORM.COUNTRY_ID=COUNTRY.ID AND '+
    ' CRUISE.INSTITUTE_ID=INSTITUTE.ID AND '+
    ' CRUISE.PROJECT_ID=PROJECT.ID AND '+
    ' CRUISE.ID=';




var
  frmosmain: Tfrmosmain;

  IniFileName:string;
  GlobalPath, GlobalUnloadPath, GlobalSupportPath:string; //global paths for the app
  CurrentParTable: string;

  Source_unq_list:TStringList; //list of unique sources from selection
  Instrument_list: TStringList; // list of instruments
  PQF1_list: TStringList; // list for PQF1
  PQF2_list: TStringList; // list for PQF2
  SQF_list : TStringList; // list for SQF

  depth_units: integer; //0-meters, 1-dBar

  StationIDMin, StationIDMax: integer;
  StationLatMin,StationLatMax,StationLonMin,StationLonMax: real;
  SLatMin,SLatMax,SLonMin,SLonMax:Real;
  StationDateMin, StationDateMax, SDateMin, SDateMax :TDateTime;
  StationDateAddedMin, StationDateAddedMax, StationDateUpdatedMin, StationDateUpdatedMax :TDateTime;
  StationCount, SCount:Integer; //number OD stations in database and selection

  CruiseIDMin, CruiseIDMax:integer;
  CruiseLatMin,CruiseLatMax,CruiseLonMin,CruiseLonMax: real;
  CruiseDateAddedMin, CruiseDateAddedMax :TDateTime;
  CruiseDateUpdatedMin, CruiseDateUpdatedMax :TDateTime;
  CruiseStationsTotalMax, CruiseStationsDatabaseMax, CruiseStationsDuplicateMax: integer;

  CRUISEInfoObtained: boolean = false; //getting CRUISE info on app start
  NavigationOrder:boolean=true; //Stop navigation until all modules responded

  libgswteos, netcdf:TLibHandle;
  libgswteos_exists, netcdf_exists:boolean;

  SLatP_arr:array[0..20000] of real;
  SLonP_arr:array[0..20000] of real;
  Length_arr:integer;

  MapDataset: array of MapDS;

  frmprofile_station_all_open, frmprofile_station_single_open :boolean;
  frmmap_open, frmprofile_plot_all_open, frmparameters_list_open: boolean;
  frmmeteo_open: boolean;

const
   NC_NOWRITE   = 0;    // file for reading
   NC_WRITE     = 1;    // file for writing
   NC_GLOBAL    = -1;   // global attributes ID
   NC_MAX_NAME  = 1024; // value from netcdf.h
   NC_UNLIMITED = 0;
   WS_EX_STATICEDGE = $20000;
   buf_len      = 3000;

   S_clr:Array[1..15] of TColor =
   (clBlue,clFuchsia,clMaroon,clBlack,clGreen,clNavy,clPurple,clTeal,
    clOlive,clGray,clSilver,clLime,clYellow,clAqua,clLtGray);

implementation


uses
(* core modules *)
  dm,
  oscreatenewdb,
  osdbstructure_updater, //temporary module to be removed later
  ossettings,
  osselection_advanced,
  osselection_customsql,
  sortbufds,
  procedures,
  ArbytraryRegion,
  osbathymetry,
  declarations_netcdf,
  osunitsupdate,

(* loading data *)
  osload_argo,
  osload_itp,
  osload_GLODAP_2019_v2_product,
  osload_WOD18,
  osload_PangaeaTab,
  osload_ices,

(* database service procedures *)
  ossupporttables,
  osservicestatistics,

(* data export *)
  osexport_divand,
  osexport_ascii,
  osexport_CIA,
  osexport_comfort,
  osexport_comfort_table,
  osexport_firebird,

(* QC *)
  osqc_dbar_meters_consistency,
  osqc_duplicates,
  osqc_wideranges,
  osqc_meanprofile,
  osqc_setflags,
  osqc_outliers,

(* tools *)
  osmap,
  osmap_kml,
  osparameters_list,
  osprofile_station_all,
  osprofile_station_single,
  osprofile_plot_all,
  osbathymetry_plot,
  osmeteo,

(* statistics *)
  osstatistics,
  osstatistics_AK,

(* visualization *)
  osviz_surfer_squares,
  osviz_grapher_histogram
;

{$R *.lfm}


procedure Tfrmosmain.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
  k:integer;
begin

(* flags on open forms *)
 frmprofile_station_all_open:=false; frmprofile_station_single_open:=false;
 frmmap_open:=false; frmparameters_list_open:=false; frmmeteo_open:=false;
 frmprofile_plot_all_open:=false;

 (* Defining Global Path - application root lolder *)
  GlobalPath:=ExtractFilePath(Application.ExeName);

  (* Define settings file, unique for every user*)
  IniFileName:=GetUserDir+'.climateshell';
  if not FileExists(IniFileName) then begin
    Ini:=TIniFile.Create(IniFileName);
    Ini.WriteInteger('main', 'Language', 0);
    Ini.Free;
  end;

  (* Loading TEOS-2010 dynamic library *)
  {$IFDEF WINDOWS}
    libgswteos:=LoadLibrary(PChar(GlobalPath+'libgswteos-10.dll'));
    netcdf    :=LoadLibrary(PChar(GlobalPath+'netcdf.dll'));
  {$ENDIF}
  {$IFDEF LINUX}
    libgswteos:=LoadLibrary(PChar(GlobalPath+'libgswteos-10.so'));
    netcdf    :=LoadLibrary(PChar(GlobalPath+'libnetcdf.so'));
  {$ENDIF}
  {$IFDEF DARWIN}
    libgswteos:=LoadLibrary(PChar(GlobalPath+'libgswteos-10.dylib'));
    netcdf    :=LoadLibrary(PChar(GlobalPath+'libnetcdf.dylib'));
  {$ENDIF}


  //GibbsSeaWater loaded?
  if libgswteos=0 then libgswteos_exists:=false else libgswteos_exists:=true;
    if not libgswteos_exists then showmessage('TEOS-10 is not installed');

  //netCDF loaded?
  if netcdf=0 then netcdf_exists:=false else netcdf_exists:=true;

  if not netcdf_exists then showmessage('netCDF is not installed');


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

    depth_units:=Ini.ReadInteger('main', 'depth_units', 0);

    if Ini.ReadBool( 'main', 'Experimental',false)=false then ExpertModeOff;

    (* STATION search settings *)
    pcRegion.ActivePageIndex:=Ini.ReadInteger( 'osmain', 'station_region_pcRegion', 0);
    seLatMin.Value   :=Ini.ReadFloat  ( 'osmain', 'station_latmin',     0);
    seLatMax.Value   :=Ini.ReadFloat  ( 'osmain', 'station_latmax',     0);
    seLonMin.Value   :=Ini.ReadFloat  ( 'osmain', 'station_lonmin',     0);
    seLonMax.Value   :=Ini.ReadFloat  ( 'osmain', 'station_lonmax',     0);

    seAroundPointLat.Value    := Ini.ReadFloat( 'osmain', 'station_around_point_lat',    0);
    seAroundPointLon.Value    := Ini.ReadFloat( 'osmain', 'station_around_point_lon',    0);
    seAroundPointRaduis.Value := Ini.ReadInteger( 'osmain', 'station_around_point_radius', 0);


    chkPeriod.Checked:=Ini.ReadBool   ( 'osmain', 'station_period', false);
    seIDMin.Value    :=Ini.ReadInteger( 'osmain', 'station_idmin',      0);
    seIDMax.Value    :=Ini.ReadInteger( 'osmain', 'station_idmax',      0);
    cbPlatform.Text  :=Ini.ReadString ( 'osmain', 'station_platform',  '');
    cbCountry.Text   :=Ini.ReadString ( 'osmain', 'station_country',   '');
    cbSource.Text    :=Ini.ReadString ( 'osmain', 'station_source',    '');
    cbInstitute.Text :=Ini.ReadString ( 'osmain', 'station_institute', '');
    cbProject.Text   :=Ini.ReadString ( 'osmain', 'station_project',   '');

    pcDateandTime.ActivePageIndex:=Ini.ReadInteger( 'osmain', 'station_region_pcDateandTime', 0);
    dtpDateMin.DateTime:=Ini.ReadDateTime('osmain', 'station_datemin', now);
    dtpDateMax.DateTime:=Ini.ReadDateTime('osmain', 'station_datemax', now);
    dtpDateAddedMin.DateTime:=Ini.ReadDateTime('osmain', 'station_dateaddedmin', now);
    dtpDateAddedMax.DateTime:=Ini.ReadDateTime('osmain', 'station_dateaddedmax', now);
    dtpDateUpdatedMin.DateTime:=Ini.ReadDateTime('osmain', 'station_dateupdatedmin', now);
    dtpDateUpdatedMax.DateTime:=Ini.ReadDateTime('osmain', 'station_dateupdatedmax', now);

    chkIgnoreDup.Checked   := Ini.ReadBool( 'osmain', 'station_chkIgnoreDup',   true);
    chkRegion.Checked      := Ini.ReadBool( 'osmain', 'station_chkRegion',      true);
    chkDateandTime.Checked := Ini.ReadBool( 'osmain', 'station_chkDateandTime', true);
    chkIDRange.Checked     := Ini.ReadBool( 'osmain', 'station_chkIDRange',     false);
    chkParameter.Checked   := Ini.ReadBool( 'osmain', 'station_chkVariables',   false);
    chkQCFlag.Checked      := Ini.ReadBool( 'osmain', 'station_chkQCFlag',      false);
    chkDepth.Checked       := Ini.ReadBool( 'osmain', 'station_chkDepth',       false);


    sbSelectedCruise.width := Ini.ReadInteger( 'osmain', 'sbSelectedCruie_Width', 400);
    DBGridCruise.Height    := Ini.ReadInteger( 'osmain', 'dbGridCruise_Height',   200);

    (* CRUISE table columns *)
    With DBGridCruise do begin
     Columns[0].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col00',  30);
     Columns[1].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col01',  50);
     Columns[2].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col02', 150);
     Columns[3].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col03', 100);
     Columns[4].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col04', 100);
     Columns[5].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col05',  70);
     Columns[6].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col06',  70);
     Columns[7].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col07',  70);
     Columns[8].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col08',  70);
     Columns[9].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col09',  70);
    End;


    (* ENTRY table columns *)
    With DBGridEntry do begin
     Columns[0].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col00',  30); //CheckBox
     Columns[1].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col01',  50); //ID
     Columns[2].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col02', 150); //Title
     Columns[3].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col03',  60); //Stations
     Columns[4].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col04',  70); //Start date
     Columns[5].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col05',  70); //Finish date
     Columns[6].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col06',  70); //Date_added
     Columns[7].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col07',  70); //Date_upfated
    end;

    with DBGridStation do begin
     Columns[0].Width  :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col00',    30);  //CheckBox
     Columns[1].Width  :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col01',    60);  //STATION ID
     Columns[2].Width  :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col02',    60);  //CRUISE ID
     Columns[3].Width  :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col03',    60);  //FLAG
     Columns[4].Width  :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col04',    60);  //LATITUDE
     Columns[5].Width  :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col05',    60);  //LONGITUDE
     Columns[6].Width  :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col06',    60);  //DATE
     Columns[7].Width  :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col07',    60);  //SOURCE
     Columns[8].Width  :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col08',    60);  //PLATFORM
     Columns[9].Width  :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col09',    60);  //COUNTRY
     Columns[10].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col10',    60);
     Columns[11].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col11',    60);
     Columns[12].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col12',    60);
     Columns[13].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col13',    60);
    end;

   (* Essential program folders *)
    GlobalSupportPath := Ini.ReadString('main', 'SupportPath', GlobalPath+'support'+PathDelim);
      if not DirectoryExists(GlobalSupportPath) then CreateDir(GlobalSupportPath);
    GlobalUnloadPath  := Ini.ReadString('main', 'UnloadPath', GlobalPath+'unload'+PathDelim);
      if not DirectoryExists(GlobalUnloadPath) then CreateDir(GlobalUnloadPath);
  finally
    Ini.Free;
  end;

 // showmessage('2');

  chkRegion.OnChange(self);
  chkDateandTime.OnChange(self);
  chkIDRange.OnChange(self);
  chkParameter.OnChange(self);
  chkQCFlag.OnChange(self);
  chkDepth.OnChange(self);

 (* Works on double click *)
 { If ParamCount<>0 then begin
   if uppercase(ExtractFileExt(ParamStr(1)))='.FDB' then begin
      IBName:=ParamStr(1);
      OpenDatabase;
   end;
  end;  }

 (* disabling menu items *)
  for k:=1 to MM.Items.Count-2 do MM.Items[k].Enabled:=false;

 (* list of unique sources - only those selected *)
 Source_unq_list:=TStringList.Create;
 Instrument_list:=TStringList.Create;
 PQF1_list:=TStringList.Create;
 PQF2_list:=TStringList.Create;
 SQF_list:=TStringList.Create;

 OnResize(Self);
 SetFocus;
 Application.ProcessMessages;
end;

procedure Tfrmosmain.btnRemoveEntryClick(Sender: TObject);
begin
  frmdm.QEntry.Delete;
end;


procedure Tfrmosmain.btnSelectStationsClick(Sender: TObject);
var
i, k, fl:integer;
SSYearMin,SSYearMax,SSMonthMin,SSMonthMax,SSDayMin,SSDayMax :Word;
NotCondCountry, NotCondPlatform, NotCondSource:string;
NotCondInstitute, NotCondProject, NotCondOrigin, SBordersFile:string;

dlat, dlon, lat, lon, dist:real;
time0, time1:TDateTime;
buf_str, SQL_str, QCFlag_str: string;
LatMin, LatMax, LonMin, LonMax:real;
begin

(* saving current search settings *)
SaveSettingsStationSearch;

frmosmain.Enabled:=false;
Application.ProcessMessages;

try
// frmdm.Q.DisableControls;
 DecodeDate(dtpDateMin.Date, SSYearMin, SSMonthMin, SSDayMin);
 DecodeDate(dtpDateMax.Date, SSYearMax, SSMonthMax, SSDayMax);

  if chkNOTCountry.Checked   =true then NotCondCountry   :='NOT' else NotCondCountry   :='';
  if chkNOTPlatform.Checked  =true then NotCondPlatform  :='NOT' else NotCondPlatform  :='';
  if chkNOTSource.Checked    =true then NotCondSource    :='NOT' else NotCondSource    :='';
  if chkNOTInstitute.Checked =true then NotCondInstitute :='NOT' else NotCondInstitute :='';
  if chkNOTProject.Checked   =true then NotCondProject   :='NOT' else NotCondProject   :='';

  SQL_str:='';

    (* ID range *)
    if chkIDRange.Checked=true then begin
        SQL_str:=SQL_str+' AND (STATION.ID BETWEEN '+seIDMin.Text+
                         ' AND '+seIDMax.Text+') ';
    end;

    (* QC Flag *)
    if chkQCFlag.Checked=true then begin
     QCFlag_str:='';
     for k:=0 to cgQCFlag.Items.Count-1 do
      if cgQCFlag.Checked[k]=true then
       QCFlag_str:=QCFlag_str+
                  copy(cgQCFlag.Items.Strings[k], 2, Pos(']',
                       cgQCFlag.Items.Strings[k])-2)+',';

     QCFlag_str:=copy(QCFlag_str, 1, length(QCFlag_str)-1);
     if trim(QCFlag_str)<>'' then
      SQL_str:=SQL_str+' AND (STATION.QCFLAG IN ('+QCFlag_str+')) ';
    end;

    (* Coordinates *)
    if chkRegion.Checked=true then begin
    if pcRegion.ActivePageIndex=0 then begin
    SQL_str:=SQL_str+' AND (LATITUDE BETWEEN '+seLatMin.Text+
                     ' AND '+seLatMax.Text+') ';

     if seLonMax.Value>=seLonMin.Value then
       SQL_str:=SQL_str+' AND (LONGITUDE BETWEEN '+seLonMin.Text+
                        ' AND '+seLonMax.Text+') ';

     if seLonMax.Value<seLonMin.Value then
      SQL_str:=SQL_str+' AND ((LONGITUDE>='+seLonMin.Text+
                       ' AND LONGITUDE<=180) OR '+
                       '(LONGITUDE>=-180 and LONGITUDE<='+seLonMax.Text+')) ';
    end;


    // around point
    if pcRegion.ActivePageIndex=1 then begin
      PositionByDistance(seAroundPointLat.Value,
                         seAroundPointLon.Value,
                         seAroundPointRaduis.Value,
                         dlat, dlon);

      with frmdm.q1 do begin
       Close;
         SQL.Clear;
         SQL.Add(' DELETE FROM TEMPORARY_ID_LIST ');
       ExecSQL;
      end;
      frmdm.TR.CommitRetaining;

      with frmdm.q1 do begin
       Close;
         SQL.Clear;
         SQL.Add(' SELECT ID, LATITUDE, LONGITUDE FROM STATION ');
         SQL.Add(' WHERE ');
         SQL.Add(' (LATITUDE BETWEEN ' );
         SQL.Add(floattostr(seAroundPointLat.Value-dlat)+' AND ');
         SQL.Add(floattostr(seAroundPointLat.Value+dlat)+') AND ');
         if seAroundPointLon.Value+dlon<=180 then begin
           SQL.Add(' (LONGITUDE BETWEEN ');
           SQL.Add(floattostr(seAroundPointLon.Value-dlon)+' AND ');
           SQL.Add(floattostr(seAroundPointLon.Value+dlon)+') ');
         end;
         if seAroundPointLon.Value+dlon>180 then begin
           SQL.Add(' ((LONGITUDE>= ');
           SQL.Add(floattostr(seAroundPointLon.Value-dlon));
           SQL.Add(' AND LONGITUDE<=180) OR ');
           SQL.Add('(LONGITUDE>=-180 and LONGITUDE<= ');
           SQL.Add(floattostr(seAroundPointLon.Value+dlon)+')) ');
         end;
        //   showmessage(frmdm.q1.SQL.Text);
       Open;
      end;

      while not frmdm.q1.EOF do begin
         Lat:=frmdm.q1.FieldByName('LATITUDE').AsFloat;
         Lon:=frmdm.q1.FieldByName('LONGITUDE').AsFloat;

         Distance(seAroundPointLon.Value, Lon, seAroundPointLat.Value, Lat, Dist);

         if (dist<=seAroundPointRaduis.Value) then begin
          with frmdm.q2 do begin
           Close;
            SQL.Clear;
            SQL.Add(' INSERT INTO TEMPORARY_ID_LIST ');
            SQL.Add(' (ID) VALUES (:ID) ');
            ParamByName('ID').Value:=frmdm.q1.FieldByName('ID').AsInteger;
           ExecSQL;
          end;
         end;
       frmdm.q1.Next;
      end;
      frmdm.TR.CommitRetaining;

      SQL_str:=SQL_str+' AND STATION.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) ';
    end;

    // predefined region
    if pcRegion.ActivePageIndex=2 then begin

    if cbPredefinedRegion.ItemIndex<0 then
     if MessageDlg('Choose a region first', mtWarning, [mbOk], 0)=mrOk then exit;

    ArbytraryRegion.GetArbirtaryRegion(
      GlobalSupportPath+'sea_borders'+PathDelim+cbPredefinedRegion.Text+'.bln',
      LatMin, LatMax, LonMin, LonMax);

 {   showmessage(floattostr(LatMIn)+'   '+
                floattostr(latmax)+'   '+
                floattostr(lonmin)+'   '+
                floattostr(lonmax));  }

      with frmdm.q1 do begin
       Close;
         SQL.Clear;
         SQL.Add(' DELETE FROM TEMPORARY_ID_LIST ');
       ExecSQL;
      end;
      frmdm.TR.CommitRetaining;

      with frmdm.q1 do begin
       Close;
         SQL.Clear;
         SQL.Add(' SELECT ID, LATITUDE, LONGITUDE FROM STATION ');
         SQL.Add(' WHERE ');
         SQL.Add(' (LATITUDE BETWEEN ' );
         SQL.Add(floattostr(LatMin)+' AND ');
         SQL.Add(floattostr(LatMax)+') AND ');
         if LonMin<=LonMax then begin
           SQL.Add(' (LONGITUDE BETWEEN ');
           SQL.Add(floattostr(LonMin)+' AND ');
           SQL.Add(floattostr(LonMax)+') ');
         end;
         if LonMin>LonMax then begin
           SQL.Add(' ((LONGITUDE>= ');
           SQL.Add(floattostr(LonMIn));
           SQL.Add(' AND LONGITUDE<=180) OR ');
           SQL.Add('(LONGITUDE>=-180 and LONGITUDE<= ');
           SQL.Add(floattostr(LonMax)+')) ');
         end;
        //   showmessage(frmdm.q1.SQL.Text);
       Open;
      end;

      while not frmdm.q1.EOF do begin
         Lat:=frmdm.q1.FieldByName('LATITUDE').AsFloat;
         Lon:=frmdm.q1.FieldByName('LONGITUDE').AsFloat;

         if Odd(Point_Status(Lon,Lat)) then begin
          with frmdm.q2 do begin
           Close;
            SQL.Clear;
            SQL.Add(' INSERT INTO TEMPORARY_ID_LIST ');
            SQL.Add(' (ID) VALUES (:ID) ');
            ParamByName('ID').Value:=frmdm.q1.FieldByName('ID').AsInteger;
           ExecSQL;
          end;
         end;
       frmdm.q1.Next;
      end;
      frmdm.TR.CommitRetaining;

      SQL_str:=SQL_str+' AND STATION.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) ';
    end;

    end; //region


    (* Date and Time *)
    if chkDateandTime.Checked=true then begin

    if pcDateandTime.ActivePageIndex=0 then begin
    // From date to date
      if chkPeriod.Checked=false then begin
       SQL_str:=SQL_str+' AND (DATEANDTIME BETWEEN '+
                        QuotedStr(DateTimeToStr(dtpDateMin.DateTime))+' AND '+
                        QuotedStr(DateTimeToStr(dtpDateMax.DateTime))+') ';
      end;

     //Date in Period
     if chkPeriod.Checked=true then begin
      SQL_str:=SQL_str+' AND (Extract(Year from DATEANDTIME) BETWEEN '+
                       IntToStr(SSYearMin)+' AND '+
                       IntToStr(SSYearMax)+') ';

      if SSMonthMin<=SSMonthMax then
         SQL_str:=SQL_str+' AND (Extract(Month from DATEANDTIME) BETWEEN '+
                          IntToStr(SSMonthMin)+' AND '+
                          IntToStr(SSMonthMax)+') ';
      if SSMonthMin>SSMonthMax then
         SQL_str:=SQL_str+' AND ((Extract(Month from DATEANDTIME)>= '+
                          IntToStr(SSMonthMin)+') OR'+
                          ' (Extract(Month from DATEANDTIME)<= '+
                          IntToStr(SSMonthMax)+')) ';
      if SSDayMin<=SSDayMax then
         SQL_str:=SQL_str+' AND (Extract(Day from DATEANDTIME) BETWEEN '+
                          IntToStr(SSDayMin)+' AND '+
                          IntToStr(SSDayMax)+') ';
      if SSDayMin>SSDayMax then
         SQL_str:=SQL_str+' AND ((Extract(Day from DATEANDTIME)>= '+
                          IntToStr(SSDayMin)+') OR '+
                          ' (Extract(Day from DATEANDTIME)<= '+
                          IntToStr(SSDayMax)+')) ';
     end;
    end;

    (* DATE_ADDED *)
    if pcDateandTime.ActivePageIndex=1 then begin
      SQL_str:=SQL_str+' AND (STATION.DATE_ADDED BETWEEN '+
                       QuotedStr(DateTimeToStr(dtpDateAddedMin.DateTime))+' AND '+
                       QuotedStr(DateTimeToStr(dtpDateAddedMax.DateTime))+' ) ';
    end;

    (* DATE_UPDATED *)
    if pcDateandTime.ActivePageIndex=2 then begin
     SQL_str:=SQL_str+' AND (STATION.DATE_UPDATED between '+
                      QuotedStr(DateTimeToStr(dtpDateUpdatedMin.DateTime))+' AND '+
                      QuotedStr(DateTimeToStr(dtpDateUpdatedMax.DateTime))+' ) ';
    end;
    end; // dates


    if cbPlatform.Text<>'' then begin
      SQL_str:=SQL_str+' AND (STATION.CRUISE_ID IN (SELECT CRUISE.ID FROM '+
      ' CRUISE, PLATFORM WHERE CRUISE.PLATFORM_ID=PLATFORM.ID AND '+
      NotCondSource+' PLATFORM.NAME IN (';
       for k:=0 to cbPlatform.Count-1 do
         if cbPlatform.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbPlatform.Items.Strings[k])+',';
       SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+'))) ';
    end;

    if cbCountry.Text<>'' then begin
      SQL_str:=SQL_str+' AND (STATION.CRUISE_ID IN (SELECT CRUISE.ID FROM '+
      ' CRUISE, PLATFORM, COUNTRY WHERE CRUISE.PLATFORM_ID=PLATFORM.ID AND '+
      ' PLATFORM.COUNTRY_ID=COUNTRY.ID AND '+NotCondSource+
      ' PLATFORM.NAME IN (';
       for k:=0 to cbCountry.Count-1 do
         if cbCountry.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbCountry.Items.Strings[k])+',';
       SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+'))) ';
    end;

    if cbSource.Text<>'' then begin
     SQL_str:=SQL_str+' AND (STATION.CRUISE_ID IN (SELECT CRUISE.ID FROM '+
          ' CRUISE, SOURCE WHERE CRUISE.SOURCE_ID=SOURCE.ID AND '+
          NotCondSource+' SOURCE.NAME IN (';
       for k:=0 to cbSource.Count-1 do
         if cbSource.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbSource.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+'))) ';
    end;

    if cbInstitute.Text<>'' then begin
     SQL_str:=SQL_str+' AND (STATION.CRUISE_ID IN (SELECT CRUISE.ID FROM '+
          ' CRUISE, INSTITUTE WHERE CRUISE.INSTITUTE_ID=INSTITUTE.ID AND '+
          NotCondSource+' INSTITUTE.NAME IN (';
       for k:=0 to cbInstitute.Count-1 do
        if cbInstitute.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbInstitute.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+'))) ';
    end;

    if cbProject.Text<>'' then begin
     SQL_str:=SQL_str+' AND (STATION.CRUISE_ID IN (SELECT CRUISE.ID FROM '+
          ' CRUISE, PROJECT WHERE CRUISE.PROJECT_ID=PROJECT.ID AND '+
          NotCondSource+' PROJECT.NAME IN (';
     for k:=0 to cbProject.Count-1 do
       if cbProject.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbProject.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+'))) ';
    end;


    (* Parameters *)
    if chkParameter.Checked=true then begin
     for k:=0 to cgParameter.Items.Count-1 do
       if cgParameter.Checked[k] then
        SQL_str:=SQL_str+' AND (STATION.ID IN (SELECT DISTINCT(ID) FROM '+
                         cgParameter.Items.Strings[k]+')) ';
    end;

    (* Depth *)
    if chkDepth.Checked=true then begin
      if pcDepth.ActivePageIndex=0 then begin
       SQL_str:=SQL_str+' AND (STATION.BOTTOMDEPTH BETWEEN '+
                        seDepthMin.Text+' AND '+seDepthMax.Text+') ';
      end;
      if pcDepth.ActivePageIndex=1 then begin
       SQL_str:=SQL_str+' AND (STATION.BOTTOMDEPTH_GEBCO BETWEEN '+
                        seGebcoMin.Text+' AND '+seGebcoMax.Text+') ';
      end;
      if pcDepth.ActivePageIndex=2 then begin
       SQL_str:=SQL_str+' AND (STATION.LASTLEVEL_M BETWEEN '+
                        seLastLevelMin.Text+' AND '+seLastLevelMax.Text+') ';
      end;
    end;

    if chkIgnoreDup.Checked=true then
      SQL_str:=SQL_str+' AND (STATION.DUPLICATE=FALSE) ';

    if copy(SQL_str, 1, 4)=' AND'   then SQL_str:=Copy(SQL_str, 5, length(SQL_str));

   if frmdm.TR.Active=true then frmdm.TR.Commit;
   with frmdm.Q do begin
    Close;
     SQL.Clear;
     SQL.Add(StationSQL);
     if trim(SQL_str)<>'' then begin
      SQL.Add(' WHERE ');
      SQL.Add(SQL_str);
     end;
     SQL.Add('ORDER BY DATEANDTIME ');

     (* Show the query before executing *)
     if chkShowQuery.Checked then
      if MessageDlg(SQL.Text+#13+#13+'Execute the query?',
                    mtInformation, [mbYes, mbNo],0)=mrNo then exit;
    Open;
   end;

  // showmessage('selected');

   // getting cruises for selected stations
   if not frmdm.Q.IsEmpty then begin
     SelectGetCruisesFromStation(SQL_str);
   end;

   SelectionInfo;
   CDSNavigation;

finally
  frmosmain.Enabled:=true;
  Application.ProcessMessages;
end;
end;


procedure Tfrmosmain.SelectGetCruisesFromStation(SQL_str:string);
begin
  With frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' SELECT DISTINCT(SOURCE.NAME) FROM ');
     SQL.Add(' SOURCE, STATION, CRUISE ');
     SQL.Add(' WHERE ');
     SQL.Add(' SOURCE.ID=CRUISE.SOURCE_ID AND ');
     SQL.Add(' CRUISE.ID=STATION.CRUISE_ID ');
     if trim(SQL_str)<>'' then
       SQL.Add(' AND '+SQL_str  );
     SQL.Add(' ORDER BY SOURCE.NAME ');
   Open;
  end;

  Source_unq_list.Clear;
  while not frmdm.q1.EOF do begin
     Source_unq_list.Add(frmdm.q1.Fields[0].AsString);
   frmdm.q1.Next;
  end;


  With frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' SELECT DISTINCT(CRUISE_ID) FROM ');
     SQL.Add(' STATION ');
     if trim(SQL_str)<>'' then begin
       SQL.Add(' WHERE ');
       SQL.Add(  SQL_str  );
     end;
   Open;
   Last;
   First;
  end;

 //  showmessage(DateTimeToStr(now-t_begin));

  (* Cleansing the temporary list *)
  with frmdm.q2 do begin
    Close;
      SQL.Clear;
      SQL.Add(' DELETE FROM TEMPORARY_ID_LIST ');
    ExecSQL;
  end;
  frmdm.TR.CommitRetaining;

 //  showmessage(DateTimeToStr(now-t_begin));

  (* populating ID list *)
  while not frmdm.q1.EOF do begin
   with frmdm.q2 do begin
    Close;
      SQL.Clear;
      SQL.Add(' INSERT INTO TEMPORARY_ID_LIST ');
      SQL.Add(' (ID) VALUES (:ID) ');
      ParamByName('ID').Value:=frmdm.q1.FieldByName('CRUISE_ID').AsInteger;
    ExecSQL;
   end;
   frmdm.q1.Next;
  end;
  frmdm.q1.Close;
  frmdm.TR.CommitRetaining;

 //  showmessage(DateTimeToStr(now-t_begin));

   with frmdm.QCruise do begin
    Close;
      SQL.Clear;
      SQL.Add(CruiseSQL);
      SQL.Add(' WHERE ');
      SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
      SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
      SQL.Add(' CRUISE.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) ');
      SQL.Add(' ORDER BY PLATFORM.NAME, CRUISE.DATE_START_DATABASE ' );
    Open;
    Last;
    First;
   end;

end;

procedure Tfrmosmain.btnSelectIDClick(Sender: TObject);
Var
 dat: text;
 ID:integer;
 SQL_str:string;
begin
 frmosmain.OD.Filter:='*.txt|*.txt';
  if frmosmain.OD.Execute then begin
   AssignFile(dat, frmosmain.OD.FileName); reset(dat);
  end else exit;

  (* Cleansing the temporary list *)
  with frmdm.q2 do begin
    Close;
      SQL.Clear;
      SQL.Add(' DELETE FROM TEMPORARY_ID_LIST ');
    ExecSQL;
  end;
  frmdm.TR.CommitRetaining;



  readln(dat); //skipping the header
  repeat
    readln(dat, id);

     with frmdm.q2 do begin
      Close;
        SQL.Clear;
        SQL.Add(' INSERT INTO TEMPORARY_ID_LIST ');
        SQL.Add(' (ID) VALUES (:ID) ');
        ParamByName('ID').Value:=ID;
      ExecSQL;
     end;
  until eof(dat);
  CloseFile(Dat);
  frmdm.TR.CommitRetaining;

  SQL_str:=' STATION.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) ';
  try
   with frmdm.Q do begin
   Close;
    SQL.Clear;
    SQL.Add(StationSQL);
    SQL.Add(SQL_str);
   Open;
   Last;
   First;
 end;

 SelectGetCruisesFromStation(SQL_str);

 SelectionInfo;
 CDSNavigation;

 finally
   frmosmain.Enabled:=true;
   Application.ProcessMessages;
 end;

end;


procedure Tfrmosmain.btnSelectCruisesClick(Sender: TObject);
Var
  k: integer;
  NotCondCountry, NotCondPlatform, NotCondSource:string;
  NotCondInstitute, NotCondProject, NotCondSourceNum:string;
  SQL_str, QCFlag_str: string;
begin

 SaveSettingsCruiseSearch;

  frmdm.Q.Close; //closing selected sations query
  for k:=1 to 7 do sbSelection.Panels[k].Text:='---';

  if chkCruiseNOTCountry.Checked   =true then NotCondCountry   :='NOT' else NotCondCountry   :='';
  if chkCruiseNOTPlatform.Checked  =true then NotCondPlatform  :='NOT' else NotCondPlatform  :='';
  if chkCruiseNOTSource.Checked    =true then NotCondSource    :='NOT' else NotCondSource    :='';
  if chkCruiseNOTSourceNum.Checked =true then NotCondSourceNum :='NOT' else NotCondSourceNum :='';
  if chkCruiseNOTInstitute.Checked =true then NotCondInstitute :='NOT' else NotCondInstitute :='';
  if chkCruiseNOTProject.Checked   =true then NotCondProject   :='NOT' else NotCondProject   :='';

  frmdm.QCruise.DisableControls;
  try
   with frmdm.QCruise do begin
    Close;

      (* IDs *)
      if chkCruiseIDRange.Checked then begin
        SQL.Add(' AND (CRUISE.ID BETWEEN '+seCruiseIDMin.Text+' AND '+seCruiseIDMax.Text+')');
      end;

     (* Coordinates *)
     if chkCruiseRegion.Checked then begin
     SQL.Add(' AND ((LATITUDE_MIN>='+seCruiseLatMin.Text+' AND LATITUDE_MAX<='+seCruiseLatMax.Text+') OR ');
     SQL.Add('      (LATITUDE_MIN BETWEEN '+seCruiseLatMin.Text+' AND '+seCruiseLatMin.Text+') OR ');
     SQL.Add('      (LATITUDE_MAX BETWEEN '+seCruiseLatMin.Text+' AND '+seCruiseLatMin.Text+')) ');

     if seLonMax.Value>=seLonMin.Value then
      SQL.Add(' AND ((LONGITUDE_MIN>='+seCruiseLonMin.Text+'  AND LONGITUDE_MAX<='+seCruiseLonMax.Text+') OR ');
      SQL.Add('      (LONGITUDE_MIN BETWEEN'+seCruiseLonMin.Text+'  AND '+seCruiseLonMax.Text+') OR ');
      SQL.Add('      (LONGITUDE_MAX BETWEEN'+seCruiseLonMin.Text+'  AND '+seCruiseLonMax.Text+')) ');

     (* FIX NEEDED HERE *)
     if seLonMax.Value<seLonMin.Value then
      SQL.Add(' AND ((LONGITUDE_MIN>='+seCruiseLonMin.Text+' AND LONGITUDE_MAX<=180) OR'+
              '      (LONGITUDE_MIN>=-180 AND LONGITUDE_MAX<='+seCruiseLonMax.Text+')) ');
     end;


     if chkCruiseDateandTime.Checked then begin
      case pcCruiseDateandTime.ActivePageIndex of
        0: begin
            SQL.Add(' AND ((DATE_START_DATABASE >= ');
            SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateDBMin.DateTime))+' AND ');
            SQL.Add('       DATE_END_DATABASE <=  ');
            SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateDBMax.DateTime))+') OR ');
            SQL.Add('      (DATE_START_DATABASE BETWEEN ');
            SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateDBMin.DateTime))+' AND ');
            SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateDBMax.DateTime))+') OR ');
            SQL.Add('      (DATE_END_DATABASE BETWEEN ');
            SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateDBMin.DateTime))+' AND ');
            SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateDBMax.DateTime))+'))');
        end;
        1: begin
           SQL.Add(' AND ((DATE_START_TOTAL >=');
           SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateTotMin.DateTime))+' AND ');
           SQL.Add('       DATE_END_TOTAL <=  ');
           SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateTotMax.DateTime))+') OR ');
           SQL.Add('      (DATE_START_TOTAL BETWEEN ');
           SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateTotMin.DateTime))+' AND ');
           SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateTotMax.DateTime))+') OR ');
           SQL.Add('      (DATE_END_TOTAL BETWEEN ');
           SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateTotMin.DateTime))+' AND ');
           SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateTotMax.DateTime))+'))');
        end;
       2: begin
           SQL.Add('  AND (CRUISE.DATE_ADDED BETWEEN ');
           SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateAddedMin.DateTime))+' AND ');
           SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateAddedMax.DateTime)));
       end;
       3: begin
           SQL.Add('  AND (CRUISE.DATE_UPDATED BETWEEN ');
           SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateUpdatedMin.DateTime))+' AND ');
           SQL.Add(QuotedStr(DateTimeToStr(dtpCruiseDateUpdatedMax.DateTime)));
       end;
      end;
     end;

    if chkCruiseNumStations.Checked=true then begin
      case pcCruiseNumStations.ActivePageIndex of
        0: begin
           SQL.Add('  AND (STATIONS_DATABASE >='+seCruiseStationsDatabaseMin.Text+') ');
           SQL.Add('  AND (STATIONS_DATABASE <='+seCruiseStationsDatabaseMax.Text+') ');
        end;
        1: begin
           SQL.Add('  AND (STATIONS_TOTAL >='+seCruiseStationsTotalMin.Text+') ');
           SQL.Add('  AND (STATIONS_TOTAL <='+seCruiseStationsTotalMax.Text+') ');
        end;
        2: begin
           SQL.Add('  AND (STATIONS_DUPLICATES >='+seCruiseStationsDuplicateMin.Text+') ');
           SQL.Add('  AND (STATIONS_DUPLICATES <='+seCruiseStationsDuplicateMax.Text+') ');

        end;
      end;
    end;

   //extra parameters
    SQL_str:='';

    (* QC Flag *)
    if chkCruiseQCFlag.Checked=true then begin
     QCFlag_str:='';
     for k:=0 to cgCruiseQCFlag.Items.Count-1 do
      if cgCruiseQCFlag.Checked[k]=true then
       QCFlag_str:=QCFlag_str+
                  copy(cgCruiseQCFlag.Items.Strings[k], 2, Pos(']',
                       cgCruiseQCFlag.Items.Strings[k])-2)+',';
     QCFlag_str:=copy(QCFlag_str, 1, length(QCFlag_str)-1);

     if trim(QCFlag_str)<>'' then
      SQL_str:=SQL_str+' AND CRUISE.ID IN (SELECT STATION.CRUISE_ID '+
                       ' FROM STATION WHERE STATION.QCFLAG IN '+
                       ' ('+QCFlag_str+')) ';
    end;

    if cbCruisePlatform.Text<>'' then begin
      SQL_str:=SQL_str+' AND '+NotCondSource    +' PLATFORM.NAME IN (';
     for k:=0 to cbCruisePlatform.Count-1 do
       if cbCruisePlatform.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbCruisePlatform.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+') ';
    end;

    if cbCruiseCountry.Text<>'' then begin
      SQL_str:=SQL_str+' AND '+NotCondSource    +' COUNTRY.NAME IN (';
     for k:=0 to cbCruiseCountry.Count-1 do
       if cbCruiseCountry.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbCruiseCountry.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+') ';
    end;

    if cbCruiseSource.Text<>'' then begin
      SQL_str:=SQL_str+' AND '+NotCondSource    +' SOURCE.NAME IN (';
     for k:=0 to cbCruiseSource.Count-1 do
       if cbCruiseSource.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbCruiseSource.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+') ';
    end;

    if cbCruiseCruiseNum.Text<>'' then begin
     SQL_str:=SQL_str+' AND '+NotCondSourceNum  +' CRUISE.CRUISE_NUMBER IN (';
      for k:=0 to cbCruiseCruiseNum.Count-1 do
       if cbCruiseCruiseNum.Checked[k]=true then
         SQL_str:=SQL_str+QuotedStr(cbCruiseCruiseNum.Items.Strings[k])+',';
       SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+') ';
    end;

    if cbCruiseInstitute.Text<>'' then begin
      SQL_str:=SQL_str+' AND '+NotCondSource    +' INSTITUTE.NAME IN (';
     for k:=0 to cbCruiseInstitute.Count-1 do
       if cbCruiseInstitute.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbCruiseInstitute.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+') ';
    end;

    if cbCruiseProject.Text<>'' then begin
      SQL_str:=SQL_str+' AND '+NotCondSource    +' PROJECT.NAME IN (';
     for k:=0 to cbCruiseProject.Count-1 do
       if cbCruiseProject.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbCruiseProject.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+') ';
    end;

    if chkCruiseIgnoreDup.Checked=true then
      SQL_str:=SQL_str+' AND CRUISE.DUPLICATE=FALSE ';


      SQL.Clear;
      SQL.Add(CruiseSQL);
      SQL.Add(' WHERE ');
      SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
      SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID ');

      if trim(SQL_str)<>'' then
        SQL.Add(SQL_str);

     SQL.Add(' ORDER BY PLATFORM.NAME, CRUISE.DATE_START_TOTAL ' );

    if chkCruiseShowQuery.Checked=true then showmessage(frmdm.QCruise.SQL.Text);
   Open;
   Last;
   First;
  end;
  finally
    frmdm.QCruise.EnableControls;
  end;

  tsSelectedStations.TabVisible:= not frmdm.QCruise.IsEmpty;
  tsSelectedStations.Caption:='Cruises: '+inttostr(frmdm.QCruise.RecordCount);
  PageControl1.ActivePageIndex:=3;
  Application.ProcessMessages;
end;


procedure Tfrmosmain.iSelectCruiseClick(Sender: TObject);
Var
 crID_OLD, cnt: int64;
// id_str: string;
begin
  With frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' DELETE FROM TEMPORARY_ID_LIST ');
   ExecSQL;
  end;
  frmdm.TR.CommitRetaining;

 try
  (* saving current ID *)
  crID_old:=frmdm.QCruise.FieldByName('ID').AsInteger;

  (* making sure that current cruise is selected *)
  with frmdm.QCruise do begin
   Edit;
    FieldByName('SELECTED').AsBoolean:=true;
   Post;
  end;

  frmdm.QCruise.DisableControls;
  frmdm.QCruise.First;
  cnt:=0;
  while not frmdm.QCruise.EOF do begin
   if frmdm.QCruise.FieldByName('SELECTED').AsBoolean=true then begin
    inc(cnt);
     With frmdm.q1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO TEMPORARY_ID_LIST ');
       SQL.Add(' (ID) VALUES (:ID) ');
       ParamByName('ID').Value:=frmdm.QCruise.FieldByName('ID').Value;
      ExecSQL;
     end;
   end;
   frmdm.QCruise.Next;
  end;
  frmdm.TR.CommitRetaining;
 finally
  frmdm.QCruise.Locate('ID', crID_old, []);
  frmdm.QCruise.EnableControls;
 end;

  if frmdm.TR.Active=true then frmdm.TR.CommitRetaining;
   with frmdm.Q do begin
     Close;
      SQL.Clear;
      SQL.Add(StationSQL);
      SQL.Add(' STATION.CRUISE_ID IN (SELECT ID FROM TEMPORARY_ID_LIST) '); //('+id_str+') ');
     Open;
   end;

   With frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' SELECT DISTINCT(SOURCE.NAME) FROM ');
     SQL.Add(' CRUISE, SOURCE ');
     SQL.Add(' WHERE ');
     SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
     SQL.Add(' CRUISE.ID in (SELECT ID FROM TEMPORARY_ID_LIST) ');
     SQL.Add(' ORDER BY SOURCE.NAME ');
   Open;
  end;

  Source_unq_list.Clear;
  while not frmdm.q1.EOF do begin
     Source_unq_list.Add(frmdm.q1.Fields[0].AsString);
   frmdm.q1.Next;
  end;
  frmdm.q1.Close;

  SelectionInfo;
  CDSNavigation;
  Application.ProcessMessages;
end;


procedure Tfrmosmain.MenuItem19Click(Sender: TObject);
Var
 ID_OLD, cnt: integer;
 SQL_str: string;
begin
  With frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' DELETE FROM TEMPORARY_ID_LIST ');
   ExecSQL;
  end;
  frmdm.TR.CommitRetaining;

 try
  (* saving current ID *)
  ID_old:=frmdm.Q.FieldByName('ID').AsInteger;

  (* making sure that current cruise is selected *)
  with frmdm.Q do begin
   Edit;
     FieldByName('SELECTED').AsBoolean:=true;
   Post;
  end;

  frmdm.Q.DisableControls;
  frmdm.Q.First;
  cnt:=0;
  while not frmdm.Q.EOF do begin
   if frmdm.Q.FieldByName('SELECTED').AsBoolean=true then begin
    inc(cnt);
     With frmdm.q1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO TEMPORARY_ID_LIST ');
       SQL.Add(' (ID) VALUES (:ID) ');
       ParamByName('ID').Value:=frmdm.Q.FieldByName('ID').Value;
      ExecSQL;
     end;
    // showmessage(inttostr(frmdm.Q.FieldByName('ID').Value));
   end;
   frmdm.Q.Next;
  end;
  frmdm.TR.CommitRetaining;
 finally
  frmdm.Q.Locate('ID', ID_old, []);
  frmdm.Q.EnableControls;
 end;

  if frmdm.TR.Active=true then frmdm.TR.CommitRetaining;

  SQL_str:=' STATION.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) ';
   with frmdm.Q do begin
     Close;
      SQL.Clear;
      SQL.Add(StationSQL);
      SQL.Add(SQL_str); //('+id_str+') ');
     Open;
   end;

  // showmessage('1');

   With frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' SELECT DISTINCT(SOURCE.NAME) FROM ');
     SQL.Add(' STATION, CRUISE, SOURCE ');
     SQL.Add(' WHERE ');
     SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
     SQL.Add(' CRUISE.ID=STATION.CRUISE_ID AND ');
     SQL.Add(' STATION.ID in (SELECT ID FROM TEMPORARY_ID_LIST) ');
     SQL.Add(' ORDER BY SOURCE.NAME ');
   Open;
  end;

    //  showmessage('2');

  Source_unq_list.Clear;
  while not frmdm.q1.EOF do begin
     Source_unq_list.Add(frmdm.q1.Fields[0].AsString);
   frmdm.q1.Next;
  end;
  frmdm.q1.Close;

  //   showmessage('3');

  if not frmdm.Q.IsEmpty then begin
    SelectGetCruisesFromStation(SQL_str);
  end;

  //   showmessage('4');

  SelectionInfo;
  CDSNavigation;
  Application.ProcessMessages;
end;


procedure Tfrmosmain.iSelectEntryClick(Sender: TObject);
Var
  Ini: TIniFile;
  id_str, SQL_str: string;
  crID_old :integer;
begin
  try
    (* saving current ID *)
    crID_old:=frmdm.QEntry.FieldByName('ID').AsInteger;

    (* making sure that current cruise is selected *)
    with frmdm.QEntry do begin
     Edit;
      FieldByName('SELECTED').AsBoolean:=true;
     Post;
    end;

    With frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' DELETE FROM TEMPORARY_ID_LIST ');
     ExecSQL;
    end;
    frmdm.TR.CommitRetaining;


    frmdm.QEntry.DisableControls;
    frmdm.QEntry.First;
    while not frmdm.QEntry.EOF do begin
     if frmdm.QEntry.FieldByName('SELECTED').AsBoolean=true then begin
      //inc(cnt);
       With frmdm.q1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' INSERT INTO TEMPORARY_ID_LIST ');
         SQL.Add(' (ID) VALUES (:ID) ');
         ParamByName('ID').Value:=frmdm.QEntry.FieldByName('ID').Value;
        ExecSQL;
       end;
     end;
     frmdm.QEntry.Next;
    end;
    frmdm.TR.CommitRetaining;
   finally
    frmdm.QEntry.Locate('ID', crID_old, []);
    frmdm.QEntry.EnableControls;
   end;

   SQL_str:=' STATION.ID IN (SELECT STATION_ID FROM STATION_ENTRY WHERE '+
            ' ENTRY_ID IN (SELECT ID FROM TEMPORARY_ID_LIST)) ';

   if frmdm.TR.Active=true then frmdm.TR.CommitRetaining;
     with frmdm.Q do begin
       Close;
        SQL.Clear;
        SQL.Add(StationSQL);
        SQL.Add(SQL_str);
        SQL.Add(' ORDER BY DATEANDTIME ');
       Open;
       Last;
       First;
     end;

     SelectGetCruisesFromStation(SQL_str);

     SelectionInfo;
     CDSNavigation;
     Application.ProcessMessages;
end;

procedure Tfrmosmain.lbResetSearchStationsClick(Sender: TObject);
Var
  k:integer;
begin

  chkRegion.Checked:=false;
  chkDateandTime.Checked:=false;
  chkIDRange.Checked:=false;
  chkQCFlag.Checked:=false;
  chkParameter.Checked:=false;

  pcRegion.ActivePageIndex:=0;
  pcDateandtime.ActivePageIndex:=0;

  seAroundPointLat.Value:=0;
  seAroundPointLon.Value:=0;
  seAroundPointRaduis.Value:=0;

  cbPredefinedRegion.Items.Clear;

  seLatMin.Value:=StationLatMin;
  seLatMax.Value:=StationLatMax;
  seLonMin.Value:=StationLonMin;
  seLonMax.Value:=StationLonMax;

  for k:=0 to cbPlatform.Count-1  do cbPlatform.Checked[k]:=false;
  for k:=0 to cbCountry.Count-1   do cbCountry.Checked[k]:=false;
  for k:=0 to cbSource.Count-1    do cbSource.Checked[k]:=false;
  for k:=0 to cbInstitute.Count-1 do cbInstitute.Checked[k]:=false;
  for k:=0 to cbPlatform.Count-1  do cbPlatform.Checked[k]:=false;

  cbPlatform.ItemIndex:=-1;
  cbCountry.ItemIndex:=-1;
  cbSource.ItemIndex:=-1;
  cbInstitute.ItemIndex:=-1;
  cbProject.ItemIndex:=-1;

  chkNOTPlatform.Checked:=false;
  chkNOTCountry.Checked:=false;
  chkNOTSource.Checked:=false;
  chkNOTInstitute.Checked:=false;
  chkNOTProject.Checked:=false;

  seIDMin.Value:=StationIDMin;
  seIDMax.Value:=StationIDMax;

  dtpDateMin.DateTime:=StationDateMin;
  dtpDateMax.DateTime:=StationDateMax;
  chkPeriod.Checked:=false;

  dtpDateAddedMin.DateTime:=StationDateAddedMin;
  dtpDateAddedMax.DateTime:=StationDateAddedMax;
  dtpDateUpdatedMin.DateTime:=StationDateUpdatedMin;
  dtpDateUpdatedMax.DateTime:=StationDateUpdatedMax;

  for k:=0 to cgParameter.Items.Count-1 do
    cgParameter.Checked[k]:=false;

  for k:=0 to cgQCFlag.Items.Count-1 do
    cgQCFlag.Checked[k]:=true;
end;


procedure Tfrmosmain.lbResetSearchCruisesClick(Sender: TObject);
Var
  k: integer;
begin

  chkCruiseNumStations.Checked:=false;
  chkCRUISEIDRange.Checked:=false;
  chkCruiseRegion.Checked:=false;
  chkCruiseDateandtime.Checked:=false;
  chkCruiseQCFlag.Checked:=false;

  seCruiseStationsTotalMin.Value:=0;
  seCruiseStationsTotalMax.Value:=CruiseStationsTotalMax;
  seCruiseStationsDatabaseMin.Value:=0;
  seCruiseStationsDatabaseMax.Value:=CruiseStationsDatabaseMax;
  seCruiseStationsDuplicateMin.Value:=0;
  seCruiseStationsDuplicateMax.Value:=CruiseStationsDuplicateMax;

  seCruiseLatMin.Value:=CruiseLatMin;
  seCruiseLatMax.Value:=CruiseLatMax;
  seCruiseLonMin.Value:=CruiseLonMin;
  seCruiseLonMax.Value:=CruiseLonMax;

  for k:=0 to cbCruisePlatform.Count-1  do cbCruisePlatform.Checked[k]:=false;
  for k:=0 to cbCruiseCountry.Count-1   do cbCruiseCountry.Checked[k]:=false;
  for k:=0 to cbCruiseSource.Count-1    do cbCruiseSource.Checked[k]:=false;
  for k:=0 to cbCruiseCruiseNum.Count-1 do cbCruiseCruiseNum.Checked[k]:=false;
  for k:=0 to cbCruiseInstitute.Count-1 do cbCruiseInstitute.Checked[k]:=false;
  for k:=0 to cbCruisePlatform.Count-1  do cbCruisePlatform.Checked[k]:=false;

  cbCruisePlatform.ItemIndex:=-1;
  cbCruiseCountry.ItemIndex:=-1;
  cbCruiseSource.ItemIndex:=-1;
  cbCruiseCruiseNum.ItemIndex:=-1;
  cbCruiseInstitute.ItemIndex:=-1;
  cbCruiseProject.ItemIndex:=-1;

  chkCruiseNOTPlatform.Checked:=false;
  chkCruiseNOTCountry.Checked:=false;
  chkCruiseNOTSource.Checked:=false;
  chkCruiseNOTSourceNum.Checked:=false;
  chkCruiseNOTInstitute.Checked:=false;
  chkCruiseNOTProject.Checked:=false;

  seCruiseIDMin.Value:=CruiseIDMin;
  seCruiseIDMax.Value:=CruiseIDMax;

  dtpCruiseDateDBMin.DateTime:=StationDateMin;
  dtpCruiseDateDBMax.DateTime:=StationDateMax;

  dtpCruiseDateTotMin.DateTime:=StationDateMin;
  dtpCruiseDateTotMax.DateTime:=StationDateMax;

  dtpCruiseDateAddedMin.DateTime:=CruiseDateAddedMin;
  dtpCruiseDateAddedMax.DateTime:=CruiseDateAddedMax;
  dtpCruiseDateUpdatedMin.DateTime:=CruiseDateUpdatedMin;
  dtpCruiseDateUpdatedMax.DateTime:=CruiseDateUpdatedMax;
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

procedure Tfrmosmain.iDBStatistics_AKClick(Sender: TObject);
begin
 frmosstatistics_AK := Tfrmosstatistics_AK.Create(Self);
 try
  if not frmosstatistics_AK.ShowModal = mrOk then exit;
 finally
   frmosstatistics_AK.Free;
   frmosstatistics_AK := nil;
 end;
end;


procedure Tfrmosmain.iExportDIVAndClick(Sender: TObject);
begin
  frmosexport_divand := Tfrmosexport_divand.Create(Self);
   try
    if not frmosexport_divand.ShowModal = mrOk then exit;
   finally
     frmosexport_divand.Free;
     frmosexport_divand := nil;
   end;
end;

procedure Tfrmosmain.iExportFirebirdDBClick(Sender: TObject);
begin
  frmexport_firebird := Tfrmexport_firebird.Create(Self);
   try
    if not frmexport_firebird.ShowModal = mrOk then exit;
   finally
     frmexport_firebird.Free;
     frmexport_firebird := nil;
   end;
end;

procedure Tfrmosmain.iExportASCIIClick(Sender: TObject);
begin
 ExportASCII;
end;

procedure Tfrmosmain.itestClick(Sender: TObject);
begin
  showmessage(inttostr(osbathymetry.getgebcodepth(66, 2)));
end;


procedure Tfrmosmain.aSettingsExecute(Sender: TObject);
begin
 frmsettings := Tfrmsettings.Create(Self);
  try
   if not frmsettings.ShowModal = mrOk then exit;
  finally
    frmsettings.Free;
    frmsettings := nil;
  end;
end;

procedure Tfrmosmain.btnAddCruiseClick(Sender: TObject);
Var
 Qt:TSQLQuery;
begin
{frmdm.QCruise.Insert;

Qt :=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=frmdm.TR;

   if frmdm.QCruise.FieldByName('ID').IsNull then begin
     Qt.Close;
     Qt.SQL.Text:=' Select max(ID) from CRUISE ';
     Qt.Open;
      frmdm.QCruise.Append;
      frmdm.QCruise.FieldByName('ID').Value:=Qt.Fields[0].AsInteger+1;
      frmdm.QCruise.FieldByName('DATE_ADDED').Value:=Now;
     Qt.Close;
   end;

Qt.Free;
btnSaveCruise.Enabled:=true;
}
end;

procedure Tfrmosmain.btnAddEntryClick(Sender: TObject);
Var
 Qt:TSQLQuery;
 max_id, type_id: integer;
begin
frmdm.QEntry.Insert;

  if frmdm.QEntry.FieldByName('ID').IsNull then begin
   Qt :=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=frmdm.TR;
   try
     Qt.Close;
     Qt.SQL.Text:=' Select max(ID) from ENTRY ';
     Qt.Open;
       max_ID:=Qt.Fields[0].AsInteger;
     Qt.Close;
     Qt.SQL.Text:=' SELECT ID from ENTRY_TYPE '+
                  ' WHERE NAME='+QuotedStr(cbEntryType.Text);
     Qt.Open;
       type_ID:=Qt.Fields[0].AsInteger;
     Qt.Close;

      frmdm.QEntry.Append;
      frmdm.QEntry.FieldByName('ID').Value:=max_id+1;
      frmdm.QEntry.FieldByName('ENTRY_TYPE_ID').Value:=type_id;
      frmdm.QEntry.FieldByName('DATE_ADDED').Value:=Now;
      frmdm.QEntry.FieldByName('DATE_UPDATED').Value:=Now;

   finally
     frmdm.TR.CommitRetaining;
     Qt.Free;
   end;
  end;

btnSaveEntry.Enabled:=true;
end;


procedure Tfrmosmain.iSettingsClick(Sender: TObject);
begin
  aSettings.Execute;
end;


(* Opening a local database*)
procedure Tfrmosmain.aOpenDatabaseExecute(Sender: TObject);
Var
  k:integer;
begin
  OD.Filter:='Firebird Database|*.FDB;*.fdb';
  if OD.Execute then begin
   OpenLocalDatabase(OD.FileName);
  end;
end;

procedure Tfrmosmain.OpenLocalDatabase(DBName:string);
Var
  k:integer;
begin
  try
    frmdm.IBDB.Close(false);
    frmdm.IBDB.DatabaseName:=DBName;
    frmdm.IBDB.Open;
  except
    on E: Exception do
      if MessageDlg(E.Message, mtWarning, [mbOk], 0)=mrOk then exit;
  end;

  Caption:='OceanShell ['+DBName+']';
  Application.ProcessMessages;

  (*******************TEMPORARY *********************)
     //CheckDBStructure;
  (*******************TEMPORARY *********************)

  DatabaseInfo;

  for k:=1 to MM.Items.Count-2 do MM.Items[k].Enabled:=true;
  PageControl1.Enabled:=true;
end;

procedure Tfrmosmain.btnOpenOceanFDBClick(Sender: TObject);
Var
  Ini: TIniFile;
  server, DBPath, DBHost, DBUser, DBPass:string;
  k:integer;
begin
  server:='firebird';

  Ini := TIniFile.Create(IniFileName);
  try
    DBUser :=Ini.ReadString(server, 'user',     'SYSDBA');
    DBPass :=Ini.ReadString(server, 'pass',     'masterkey');
    DBHost :=Ini.ReadString(server, 'host',     'localhost');
    DBPath :=Ini.ReadString(server, 'dbpath',   '');
  finally
    Ini.Free;
  end;

  // if database isn't specified
  if (trim(DBPath)='') then begin
   if MessageDlg('Specify the database, please', mtwarning, [mbOk], 0)=mrOk then
    iSettings.OnClick(self);
   exit;
  end;

  with frmdm.DBLoader do begin
    {$IFDEF WINDOWS}
      LibraryName:=GlobalPath+'fbclient.dll';
    {$ENDIF}
    {$IFDEF LINUX}
      LibraryName:=GlobalPath+'libfbclient.so.3.0.5';
    {$ENDIF}
    {$IFDEF DARWIN}
      LibraryName:=GlobalPath+'libfbclient.dylib';
    {$ENDIF}
    Enabled:=true;
  end;

  try
    with frmdm.IBDB do begin
      UserName:=DBUser;
      Password:=DBPass;
      HostName:=DBHost;
      DatabaseName:=DBPath;
      Connected:=true;
    end;

    DatabaseInfo;

    for k:=1 to MM.Items.Count-2 do MM.Items[k].Enabled:=true;
    PageControl1.Enabled:=true;

    Caption := 'OceanShell ['+DBHost+':'+DBPath+']';
    Application.ProcessMessages;

  except
    on e: Exception do
      if MessageDlg(e.message, mtError, [mbOk], 0)=mrOk then close;
  end;

end;

(* turning off some experimantal features *)
procedure Tfrmosmain.ExpertModeOff;
begin
  iExportFirebirdDB.Visible:=false;
  iExportDIVAnd.Visible:=false;
  iExportASCII.Visible:=false;
  itest.Visible:=false;
end;

procedure Tfrmosmain.aProfilesStationAllExecute(Sender: TObject);
begin
  if frmprofile_station_all_open=true then frmprofile_station_all.SetFocus else
     begin
       frmprofile_station_all := Tfrmprofile_station_all.Create(Self);
       frmprofile_station_all.Show;
     end;
  frmprofile_station_all_open:=true;
end;

procedure Tfrmosmain.aProfilesStationSingleExecute(Sender: TObject);
begin
  if frmprofile_station_single_open=true then frmprofile_station_single.SetFocus else
     begin
       frmprofile_station_single := Tfrmprofile_station_single.Create(Self);
       frmprofile_station_single.Show;
     end;
  frmprofile_station_single_open:=true;
end;

procedure Tfrmosmain.aMeteoExecute(Sender: TObject);
begin
  if frmmeteo_open=true then frmmeteo.SetFocus else
     begin
       frmmeteo := Tfrmmeteo.Create(Self);
       frmmeteo.Show;
     end;
  frmmeteo_open:=true;
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


procedure Tfrmosmain.iTDdiagramsClick(Sender: TObject);
begin
  if frmparameters_list_open=true then frmparameters_list.SetFocus else
     begin
       frmparameters_list := Tfrmparameters_list.Create(Self);
       frmparameters_list.Show;
     end;
  frmparameters_list.Caption:='TDDIAGRAMS';
  frmparameters_list_open:=true;
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

procedure Tfrmosmain.btnCustomSQLQueryClick(Sender: TObject);
begin
  frmselection_customsql := Tfrmselection_customsql.Create(Self);
   try
    if not frmselection_customsql.ShowModal = mrOk then exit;
   finally
     frmselection_customsql.Free;
     frmselection_customsql := nil;
   end;
end;

(* Adding selected stations in ENTRY *)
procedure Tfrmosmain.btnEntryAddStationsClick(Sender: TObject);
Var
  ID_Entry, ID_Station, ID_old, cnt: integer;
  MinDate, MaxDate: TDateTime;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
if btnSaveEntry.Enabled=true then btnSaveEntry.OnClick(self);

if VarIsNull(frmdm.QEntry.FieldByName('ID').Value) then
 if MessageDlg('Add new entry first', mtWarning, [mbOk], 0)=mrOk then exit;

ID_Entry:=frmdm.QEntry.FieldByName('ID').Value;

TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt :=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=TRt;

 try
  {Удаляем все старые записи из STATION_ENTRY}
  With Qt do begin
   Close;
    SQL.Clear;
    SQL.Add(' DELETE FROM STATION_ENTRY ');
    SQL.Add(' WHERE ENTRY_ID=:ID ');
    ParamByName('ID').AsInteger:=ID_Entry;
   ExecSQL;
  end;
  TRt.Commit;

  ID_old:=frmdm.Q.fieldbyname('ID').Value;

  frmdm.Q.DisableControls;
  frmdm.Q.First;
  While not frmdm.Q.Eof do begin
   ID_STATION:=frmdm.Q.fieldbyname('ID').AsInteger;

    With Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' Insert into STATION_ENTRY ');
      SQL.Add(' (STATION_ID, ENTRY_ID) ');
      SQL.Add(' Values ');
      SQL.Add(' (:STATION_ID, :ENTRY_ID) ');
      ParamByName('STATION_ID').Value:=ID_STATION;
      ParamByName('ENTRY_ID').Value:=ID_ENTRY;
     ExecSQL;
    end;
   frmdm.Q.Next;
  end;
  TRt.Commit;
  showmessage('here');

  with Qt do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select count(ID), min(dateandtime), max(dateandtime) ');
    SQL.Add(' from Station where ');
    SQL.Add(' ID IN (SELECT STATION_ID FROM STATION_ENTRY ');
    SQL.Add(' WHERE ENTRY_ID='+inttostr(ID_ENTRY)+')');
   Open;
     Cnt:=Qt.fields[0].AsInteger;
     MinDate:=Qt.fields[1].AsDateTime;
     MaxDate:=Qt.fields[2].AsDateTime;
   Close;
  end;

  with frmdm.QEntry do begin
    Edit;
      FieldByName('DATE_START').Value:=MinDate;
      FieldByName('DATE_END').Value:=MaxDate;
      FieldByName('STATIONS_AMOUNT').Value:=cnt;
      FieldByName('DATE_UPDATED').Value:=Now;
    Post;
  end;

 btnSaveEntry.OnClick(self);

 finally
  frmdm.Q.Locate('ID', ID_old, []);
  frmdm.Q.EnableControls;
 end;

end;

procedure Tfrmosmain.btnSaveCruiseClick(Sender: TObject);
begin
 (*
  if frmdm.QCruise.Modified then frmdm.QCruise.Post;


  frmdm.QCruise.ApplyUpdates(0);
  frmdm.TR.CommitRetaining;

  btnSaveCruise.Enabled:=false;
  Application.ProcessMessages;
  *)
end;


procedure Tfrmosmain.btnSaveEntryClick(Sender: TObject);
begin
  if frmdm.QEntry.Modified then frmdm.QEntry.Post;


  frmdm.QEntry.ApplyUpdates(0);
  frmdm.TR.CommitRetaining;

  btnSaveEntry.Enabled:=false;
  Application.ProcessMessages;
end;


(* gathering info about the database *)
procedure Tfrmosmain.DatabaseInfo;
var
  Ini:TIniFile;

  TRt_DB1:TSQLTransaction;
  Qt_DB1:TSQLQuery;
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
 try
   with Qt_DB1 do begin
    Close;
        SQL.Clear;
        SQL.Add(' select count(ID) as StCount, ');
        SQL.Add(' min(ID) as IDMin, max(ID) as IDMax, ');
        SQL.Add(' min(LATITUDE) as StLatMin, max(LATITUDE) as StLatMax, ');
        SQL.Add(' min(LONGITUDE) as StLonMin, max(LONGITUDE) as StLonMax, ');
        SQL.Add(' min(DATEANDTIME) as StDateMin, ');
        SQL.Add(' max(DATEANDTIME) as StDateMax, ');
        SQL.Add(' min(DATE_ADDED) as StDateAddedMin, ');
        SQL.Add(' max(DATE_ADDED) as StDateAddedMax, ');
        SQL.Add(' min(DATE_UPDATED) as StDateUpdatedMin, ');
        SQL.Add(' max(DATE_UPDATED) as StDateUpdatedMax ');
        SQL.Add(' from STATION');
    Open;
      StationCount:=FieldByName('StCount').AsInteger;
       if StationCount>0 then begin
         StationIDMin     :=FieldByName('IDMin').AsInteger;
         StationIDMax     :=FieldByName('IDMax').AsInteger;
         StationLatMin  :=FieldByName('StLatMin').AsFloat;
         StationLatMax  :=FieldByName('StLatMax').AsFloat;
         StationLonMin  :=FieldByName('StLonMin').AsFloat;
         StationLonMax  :=FieldByName('StLonMax').AsFloat;
         StationDateMin :=FieldByName('StDateMin').AsDateTime;
         StationDateMax :=FieldByName('StDateMax').AsDateTime;
         StationDateAddedMin :=FieldByName('StDateAddedMin').AsDateTime;
         StationDateAddedMax :=FieldByName('StDateAddedMax').AsDateTime;
         StationDateUpdatedMin :=FieldByName('StDateUpdatedMin').AsDateTime;
         StationDateUpdatedMax :=FieldByName('StDateUpdatedMax').AsDateTime;

         with sbDatabase do begin
           Panels[1].Text:='LtMin: '+floattostr(StationLatMin);
           Panels[2].Text:='LtMax: '+floattostr(StationLatMax);
           Panels[3].Text:='LnMin: '+floattostr(StationLonMin);
           Panels[4].Text:='LnMax: '+floattostr(StationLonMax);
           Panels[5].Text:='DateMin: '+datetostr(StationDateMin);
           Panels[6].Text:='DateMax: '+datetostr(StationDateMax);
           Panels[7].Text:='Stations: '+inttostr(StationCount);
         end;

         // if there are no saved settings
         if (seIDMin.Value=0) and (seIDMax.Value=0) then begin
           seIDMin.Value:=StationIDMin;
           seIdMax.Value:=StationIDMax;
           seLatMin.Value:=StationLatMin;
           seLatMax.Value:=StationLatMax;
           seLonMin.Value:=StationLonMin;
           seLonMax.Value:=StationLonMax;

         //if new database
         if (StationIDMin<seIDMin.Value) or (StationIDMax>seIdMax.Value) then begin
           seIDMin.Value:=StationIDMin;
           seIdMax.Value:=StationIDMax;
         end;

           dtpDateMin.DateTime:=StationDateMin;
           dtpDateMax.DateTime:=StationDateMax;
           dtpDateAddedMin.DateTime:=StationDateAddedMin;
           dtpDateAddedMax.DateTime:=StationDateAddedMax;
           dtpDateUpdatedMin.DateTime:=StationDateUpdatedMin;
           dtpDateUpdatedMax.DateTime:=StationDateUpdatedMax;
         end;

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

   cgParameter.Visible:=false;
   cgParameter.Items.Clear;
   cgParameter.Items:=ListBox1.Items;
   cgParameter.Visible:=true;

   (* cleaning selection info *)
   for k:=1 to 7 do sbSelection.Panels[k].Text:='---';

   (* getting QC flags from the database and storing them in lists *)
   PopulateQCFlagLists;

   (* getting list of all instruments *)
   PopulateInstrumentList;

 Finally
  TRt_DB1.Commit;
  Qt_DB1.Free;
  TRt_DB1.free;
 end;
end;

(* lists for QC flags *)
Procedure Tfrmosmain.PopulateQCFlagLists;
Var
  Ini:TIniFile;
  K: integer;
  tbl_name: string;

  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

  PQF1_list.Clear;
  PQF2_list.Clear;
  SQF_list.Clear;

  try
   for k:=1 to 4 do begin
    case k of
     1: begin
          tbl_name:='FLAG_STATION';
          DBGridStation.Columns[12].PickList.Clear;
          cgQCFlag.Items.Clear;
        end;
     2: tbl_name:='FLAG_PQF1';
     3: tbl_name:='FLAG_PQF2';
     4: tbl_name:='FLAG_SQF';
    end;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT ID, NAME FROM '+tbl_name+' ORDER BY ID ');
     Open;
    end;

    while not Qt.EOF do begin
     case k of
      1: begin
           cgQCFlag.Items.Add('['+inttostr(Qt.Fields[0].Value)+'] '+Qt.Fields[1].Value);
           DBGridStation.Columns[12].PickList.Add(inttostr(Qt.Fields[0].Value));
         end;
      2: PQF1_list.Add('['+inttostr(Qt.Fields[0].Value)+'] '+Qt.Fields[1].Value);
      3: PQF2_list.Add('['+inttostr(Qt.Fields[0].Value)+'] '+Qt.Fields[1].Value);
      4: SQF_list.Add ('['+inttostr(Qt.Fields[0].Value)+'] '+Qt.Fields[1].Value);
     end;
     Qt.Next;
    end;
   end;
  finally
   Trt.Commit;
   Qt.Free;
   Trt.Free;
  end;

  (* reading settings for checked flags *)
   Ini := TIniFile.Create(IniFileName);
   try
    for k:=0 to cgQCFlag.Items.Count-1 do
      cgQCFlag.Checked[k]:= Ini.ReadBool( 'osmain', 'QCF'+inttostr(k), true);
   finally
     Ini.Free;
   end;
end;


Procedure Tfrmosmain.PopulateInstrumentList;
Var
  K: integer;

  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

  Instrument_list.Clear;
  try
    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT ID, NAME FROM INSTRUMENT ORDER BY ID ');
     Open;
    end;

    while not Qt.EOF do begin
      instrument_list.Add('['+inttostr(Qt.Fields[0].Value)+'] '+Qt.Fields[1].Value);
     Qt.Next;
    end;

  finally
   Trt.Commit;
   Qt.Free;
   Trt.Free;
  end;
end;


(* info about CRUISE, only when needed *)
procedure Tfrmosmain.PageControl1Change(Sender: TObject);
var
  Ini:TIniFile;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
  Entry_type_str: string;
begin
  (* Search CRUISE *)
  if (PageControl1.PageIndex=1) and (CRUISEInfoObtained=false) then begin

    LoadSettingsCruiseSearch;

    cgCruiseQCFlag.Items:=cgQCFlag.Items;

    chkCruiseRegion.OnChange(self);
    chkCruiseDateandTime.OnChange(self);
    chkCruiseIDRange.OnChange(self);
    chkCruiseQCFlag.OnChange(self);
    chkCruiseNumStations.OnChange(self);

    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;

    Qt :=TSQLQuery.Create(self);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

    try
      with Qt do begin
        Close;
          SQL.Clear;
          SQL.Add(' select count(ID) as StCount, ');
          SQL.Add(' min(ID) as IDMin, max(ID) as IDMax, ');
          SQL.Add(' min(LATITUDE_MIN) as StLatMin, max(LATITUDE_MAX) as StLatMax, ');
          SQL.Add(' min(LONGITUDE_MIN) as StLonMin, max(LONGITUDE_MAX) as StLonMax, ');
          SQL.Add(' min(DATE_ADDED) as StDateAddedMin, ');
          SQL.Add(' max(DATE_ADDED) as StDateAddedMax, ');
          SQL.Add(' min(DATE_UPDATED) as StDateUpdatedMin, ');
          SQL.Add(' max(DATE_UPDATED) as StDateUpdatedMax, ');
          SQL.Add(' max(STATIONS_TOTAL) as ST_TOTAL_MAX, ');
          SQL.Add(' max(STATIONS_DATABASE) as ST_DATABASE_MAX, ');
          SQL.Add(' max(STATIONS_DUPLICATES) as ST_DUPLICATES_MAX ');
          SQL.Add(' FROM CRUISE');
        Open;
         if FieldByName('StCount').AsInteger>0 then begin
           CruiseIDMin   :=FieldByName('IDMin').AsInteger;
           CruiseIDMax   :=FieldByName('IDMax').AsInteger;
           CruiseLatMin  :=FieldByName('StLatMin').AsFloat;
           CruiseLatMax  :=FieldByName('StLatMax').AsFloat;
           CruiseLonMin  :=FieldByName('StLonMin').AsFloat;
           CruiseLonMax  :=FieldByName('StLonMax').AsFloat;
           CruiseDateAddedMin   :=FieldByName('StDateAddedMin').AsDateTime;
           CruiseDateAddedMax   :=FieldByName('StDateAddedMax').AsDateTime;
           CruiseDateUpdatedMin :=FieldByName('StDateUpdatedMin').AsDateTime;
           CruiseDateUpdatedMax :=FieldByName('StDateUpdatedMax').AsDateTime;
           CruiseStationsTotalMax:=FieldByName('ST_TOTAL_MAX').AsInteger;
           CruiseStationsDatabaseMax:=FieldByName('ST_DATABASE_MAX').AsInteger;
           CruiseStationsDuplicateMax:=FieldByName('ST_DUPLICATES_MAX').AsInteger;

           seCruiseStationsTotalMax.Value:=CruiseStationsTotalMax;
           seCruiseStationsDatabaseMax.Value:=CruiseStationsDatabaseMax;
           seCruiseStationsDuplicateMax.Value:=CruiseStationsDuplicateMax;

           if (seCruiseIDMin.Value=0) and (seCruiseIDMax.Value=0) then begin
             seCruiseIDMin.Value:=CruiseIDMin;
             seCruiseIDMax.Value:=CruiseIDMax;
             seCruiseLatMin.Value:=CruiseLatMin;
             seCruiseLatMax.Value:=CruiseLatMax;
             seCruiseLonMin.Value:=CruiseLonMin;
             seCruiseLonMax.Value:=CruiseLonMax;

             dtpCruiseDateDBMin.DateTime:=StationDateMin;
             dtpCruiseDateDBMax.DateTime:=StationDateMax;
             dtpCruiseDateTotMin.DateTime:=StationDateMin;
             dtpCruiseDateTotMax.DateTime:=StationDateMax;
             dtpCruiseDateAddedMin.DateTime:=CruiseDateAddedMin;
             dtpCruiseDateAddedMax.DateTime:=CruiseDateAddedMax;
             dtpCruiseDateUpdatedMin.DateTime:=CruiseDateUpdatedMin;
             dtpCruiseDateUpdatedMax.DateTime:=CruiseDateUpdatedMax;
           end;
         end;
     end;
   Finally
    CRUISEInfoObtained:=true;
    TRt.Commit;
    Qt.Free;
    TRt.free;
   end;
  end; //Search CRUISE tab


  (* Fetch ENTRY_TYPE *)
  if (PageControl1.PageIndex=2) and (cbEntryType.Items.Count=0) then begin

   Ini := TIniFile.Create(IniFileName);
   try
     Entry_type_str:=Ini.ReadString( 'osmain', 'entry_type', '');
   finally
    Ini.Free;
   end;

    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;

    Qt :=TSQLQuery.Create(self);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

    try
      with Qt do begin
        Close;
          SQL.Clear;
          SQL.Add(' SELECT NAME ');
          SQL.Add(' FROM ENTRY_TYPE ');
          SQL.Add(' ORDER by ID ');
        Open;
      end;

      cbEntryType.Clear;
      while not Qt.eof do begin
        cbEntryType.Items.Add(Qt.FieldByName('NAME').AsString);
       Qt.Next;
      end;
      Qt.Close;

      if Entry_type_str<>'' then
       cbEntryType.ItemIndex:=cbEntryType.Items.IndexOf(Entry_type_str) else
       cbEntryType.ItemIndex:=0;

      cbEntryType.OnSelect(self);
    finally
      TRt.Commit;
      Qt.Free;
      TRt.free;
    end;
   end; // ENTRY


end;


(* gathering info about selected stations *)
procedure Tfrmosmain.SelectionInfo;
var
  k: integer;
  lat1, lon1:real;
  dat1:TDateTime;
  items_enabled:boolean;
  yy, mn, dd:word;
begin

 try
  frmdm.Q.DisableControls;

  SLatMin:=90;  SLatMax:=-90;
  SLonMin:=180; SLonMax:=-180;
  SDateMin:=Now;
  yy:=1; mn:=1; dd:=1;
  SDateMax:=EncodeDate(yy, mn, dd);


  SetLength(MapDataset, StationCount);
  frmdm.Q.First;
  k:=-1;
  while not frmdm.Q.EOF do begin
   inc(k);
   lat1:=frmdm.Q.FieldByName('LATITUDE').AsFloat;
   lon1:=frmdm.Q.FieldByName('LONGITUDE').AsFloat;
   dat1:=frmdm.Q.FieldByName('DATEANDTIME').AsDateTime;

     if lat1<SLatMin then SLatMin:=lat1;
     if lat1>SLatMax then SLatMax:=lat1;
     if lon1<SLonMin then SLonMin:=lon1;
     if lon1>SLonMax then SLonMax:=lon1;
     if CompareDate(dat1, SDateMin)<0 then SDateMin:=dat1;
     if CompareDate(dat1, SDateMax)>0 then SDateMax:=dat1;

     MapDataset[k].ID:=frmdm.Q.FieldByName('ID').Value;
     MapDataset[k].Cruise_ID:=frmdm.Q.FieldByName('CRUISE_ID').Value;
     MapDataset[k].Latitude :=lat1;
     MapDataset[k].Longitude:=lon1;

    frmdm.Q.Next;
  end;
  frmdm.Q.First;

  SCount:=frmdm.Q.RecordCount;
  SetLength(MapDataset, SCount+1);

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

       PageControl1.ActivePageIndex:=3;
     end else for k:=1 to 7 do sbSelection.Panels[k].Text:='---';

  (* if there are selected station enabling some menu items *)
  if SCount>0 then items_enabled:=true else items_enabled:=false;

  finally
     frmdm.Q.EnableControls;
  end;

  iDBStatistics.Enabled:=items_enabled;
  aMapAllStations.Enabled:=items_enabled;
  aMapKML.Enabled:=items_enabled;
  aProfilesStationSingle.Enabled:=items_enabled;
  aProfilesStationAll.Enabled:=items_enabled;
  aProfilesSelectedAllPlot.Enabled:=items_enabled;
  iStandarddeviationslayers.Enabled:=items_enabled;
  iTDdiagrams.Enabled:=items_enabled;


  tsSelectedStations.TabVisible:=items_enabled;
  PageControl1.ActivePageIndex:=3;
  tsSelectedStations.Caption:='Cruises: '+inttostr(frmdm.QCruise.RecordCount)+'; '+
                              'Stations: '+inttostr(frmdm.Q.RecordCount);

  if frmprofile_plot_all_open then begin
    frmprofile_plot_all.Close;
    frmprofile_plot_all:= Tfrmprofile_plot_all.Create(nil);
    frmprofile_plot_all_open:=true;
  end;
end;


procedure Tfrmosmain.cbPredefinedRegionDropDown(Sender: TObject);
Var
  fdb:TSearchRec;
  fname: string;
begin
fdb.Name:='';
cbPredefinedRegion.Clear;
 FindFirst(GlobalSupportPath+'sea_borders'+PathDelim+'*.bln',faAnyFile, fdb);
  if fdb.Name<>'' then begin
   fname:=ExtractFileName(fdb.Name);
    cbPredefinedRegion.Items.Add(copy(fname,1, length(fname)-4));
     while findnext(fdb)=0 do begin
       fname:=ExtractFileName(fdb.Name);
       cbPredefinedRegion.Items.Add(copy(fname,1, length(fname)-4));
     end;
  end;
 FindClose(fdb);
end;

procedure Tfrmosmain.cbPlatformDropDown(Sender: TObject);
begin
  PopulatePlatformList;
end;

procedure Tfrmosmain.PopulatePlatformList;
Var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
  pp: integer;
begin
 if cbPlatform.Count>0 then exit;

  try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   DBGridCruise.Columns[2].PickList.Clear; //PLATFORM
   cbPlatform.Clear;

   Qt.Close;
   Qt.SQL.Text:=' SELECT DISTINCT NAME FROM PLATFORM ORDER BY NAME ';
   Qt.Open;

   while not Qt.Eof do begin
     cbPlatform.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
    Qt.Next;
   end;

    DBGridCruise.Columns[2].PickList:=cbPlatform.Items;

    Qt.Close;
    TRt.Commit;
  finally
   Qt.Free;
   TrT.Free;
  end;

  cbCruisePlatform.Clear;
  for pp:=0 to cbPlatform.Count-1 do
     cbCruisePlatform.AddItem(cbPlatform.Items.Strings[pp], cbUnchecked, true);
end;

procedure Tfrmosmain.cbCountryDropDown(Sender: TObject);
begin
  PopulateCountryList;
end;

procedure Tfrmosmain.PopulateCOUNTRYList;
Var
  pp:integer;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
  if cbCountry.Count>0 then exit;

  try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;


   DBCruiseCountry.Items.Clear;
   cbCountry.Clear;

   Qt.Close;
   Qt.SQL.Text:=' SELECT DISTINCT NAME FROM COUNTRY ORDER BY NAME ';
   Qt.Open;

   while not Qt.Eof do begin
     cbCountry.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
    Qt.Next;
   end;

   DBCruiseCountry.Items:=cbCountry.Items;

   Qt.Close;
   TRt.Commit;
  finally
   Qt.Free;
   TrT.Free;
  end;

   cbCruiseCountry.Clear;
   for pp:=0 to cbCountry.Count-1 do
     cbCruiseCountry.AddItem(cbCountry.Items.Strings[pp], cbUnchecked, true);
end;

procedure Tfrmosmain.cbSourceDropDown(Sender: TObject);
begin
  PopulateSourceList;
  cbCruiseCruiseNum.Clear;
end;

procedure Tfrmosmain.DBCruiseCountryDropDown(Sender: TObject);
begin

end;

procedure Tfrmosmain.DBCruiseInstituteDropDown(Sender: TObject);
begin

end;

procedure Tfrmosmain.DBCruiseProjectDropDown(Sender: TObject);
begin

end;


procedure Tfrmosmain.chkRegionChange(Sender: TObject);
begin
  gbRegion.Enabled:=chkRegion.Checked;
end;

procedure Tfrmosmain.chkCRUISERegionChange(Sender: TObject);
begin
  gbCruiseRegion.Enabled:=chkCruiseRegion.Checked;
end;

procedure Tfrmosmain.chkCRUISEDateandtimeChange(Sender: TObject);
begin
  gbCruiseDateandTime.Enabled:=chkCruiseDateandTime.Checked;
end;

procedure Tfrmosmain.chkDateandTimeChange(Sender: TObject);
begin
  gbDateandTime.Enabled:=chkDateandTime.Checked;
end;

procedure Tfrmosmain.chkDepthChange(Sender: TObject);
begin
 gbDepth.Enabled:=chkDepth.Checked;
end;

procedure Tfrmosmain.chkIDRangeChange(Sender: TObject);
begin
  gbIDRange.Enabled:=chkIDRange.Checked;
end;

procedure Tfrmosmain.chkCruiseIDRangeChange(Sender: TObject);
begin
  gbCruiseIDRange.Enabled:=chkCruiseIDRange.Checked;
end;

procedure Tfrmosmain.chkParameterChange(Sender: TObject);
begin
  cgParameter.Enabled:=chkParameter.Checked;
end;

procedure Tfrmosmain.chkQCFlagChange(Sender: TObject);
begin
  cgQCFlag.Enabled:=chkQCFlag.Checked;
end;

procedure Tfrmosmain.chkCruiseQCFlagChange(Sender: TObject);
begin
  cgCruiseQCFlag.Enabled:=chkCruiseQCFlag.Checked;
end;

procedure Tfrmosmain.chkCruiseNumStationsChange(Sender: TObject);
begin
  gbCRUISENumStations.Enabled:=chkCruiseNumStations.Checked;
end;

procedure Tfrmosmain.DBGridCruiseCellClick(Column: TColumn);
Var
  ID, CrID:int64;
begin
  if (not frmdm.Q.IsEmpty) and
     (not VarisNull(frmdm.Q.FieldByName('ID').Value)) then begin
     ID:=frmdm.Q.FieldByName('ID').Value;
     CrID:=frmdm.QCruise.FieldByName('ID').Value;

     if frmmap_open=true then frmmap.ChangeID(ID); //Map
     if frmprofile_plot_all_open then frmprofile_plot_all.chkCruiseHighlight.OnChange(self);

     if frmdm.Q.FieldByName('CRUISE_ID').Value<>CrID then frmdm.Q.Locate('CRUISE_ID', CrID,[]);
  end;
end;

procedure Tfrmosmain.DBGridCruiseKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((key=VK_UP) or (key=VK_DOWN)) and
     (not frmdm.Q.IsEmpty) and
     (not VarIsNull(frmdm.Q.FieldByName('ID').Value)) then begin
    if frmmap_open=true then frmmap.ChangeID(frmdm.Q.FieldByName('ID').Value); //Map
    if frmprofile_plot_all_open then frmprofile_plot_all.chkCruiseHighlight.OnChange(self);
  end;
end;


procedure Tfrmosmain.PopulateSOURCEList;
Var
  pp:integer;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin

  if cbSource.Count>0 then exit;

  try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   DBGridCruise.Columns[4].PickList.Clear; //SOURCE
   cbSource.Clear;

   Qt.Close;
   Qt.SQL.Text:=' SELECT DISTINCT NAME FROM SOURCE ORDER BY NAME ';
   Qt.Open;

      while not Qt.Eof do begin
        cbSource.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
       Qt.Next;
      end;

      DBGridCruise.Columns[4].PickList:=cbSource.Items;

    Qt.Close;
    TRt.Commit;
  finally
   Qt.Free;
   TrT.Free;
  end;

   cbCruiseSource.Clear;
   for pp:=0 to cbSource.Count-1 do
     cbCruiseSource.AddItem(cbSource.Items.Strings[pp], cbUnchecked, true);
end;

procedure Tfrmosmain.cbInstituteDropDown(Sender: TObject);
begin
  PopulateInstituteList;
end;

procedure Tfrmosmain.PopulateINSTITUTEList;
Var
  pp:integer;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin

  if cbInstitute.Count>0 then exit;

  try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   DBCruiseInstitute.Items.Clear;
   cbInstitute.Clear;

   Qt.Close;
   Qt.SQL.Text:=' SELECT DISTINCT NAME FROM INSTITUTE ORDER BY NAME ';
   Qt.Open;

      while not Qt.Eof do begin
        cbInstitute.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
       Qt.Next;
      end;

    DBCruiseInstitute.Items:=cbInstitute.Items;

    Qt.Close;
    TRt.Commit;
  finally
   Qt.Free;
   TrT.Free;
  end;

   cbCruiseInstitute.Clear;
   for pp:=0 to cbInstitute.Count-1 do
     cbCruiseInstitute.AddItem(cbInstitute.Items.Strings[pp], cbUnchecked, true);
end;

procedure Tfrmosmain.cbProjectDropDown(Sender: TObject);
begin
  PopulateProjectList;
end;

procedure Tfrmosmain.PopulatePROJECTList;
Var
  pp:integer;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin

if cbProject.Count>0 then exit;

 try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   DBCruiseProject.Items.Clear;
   cbProject.Clear;

   Qt.Close;
   Qt.SQL.Text:=' SELECT DISTINCT NAME FROM PROJECT ORDER BY NAME ';
   Qt.Open;

      while not Qt.Eof do begin
        cbProject.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
       Qt.Next;
      end;

   DBCruiseProject.Items:=cbProject.Items;

    Qt.Close;
    TRt.Commit;
  finally
   Qt.Free;
   TrT.Free;
  end;

   cbCruiseProject.Clear;
   for pp:=0 to cbProject.Count-1 do
     cbCruiseProject.AddItem(cbProject.Items.Strings[pp], cbUnchecked, true);
end;


procedure Tfrmosmain.cbCruiseCruiseNumDropDown(Sender: TObject);
Var
  pp:integer;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin

 if cbCruiseCruiseNum.Count>0 then exit;
  try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;


   cbCruiseCruiseNum.Clear;

   with Qt do begin
    Close;
      SQL.Clear;
      SQL.Add(' SELECT DISTINCT(CRUISE_NUMBER) NAME FROM CRUISE ');
      if cbCruiseSource.Text<>'' then begin
        SQL.Add(' WHERE SOURCE_ID IN (SELECT SOURCE.ID FROM SOURCE ');
        SQL.Add(' WHERE SOURCE.NAME='+QuotedStr(cbCruiseSource.Text)+')');
      end;
     Open;
   end;

      while not Qt.Eof do begin
        cbCruiseCruiseNum.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
       Qt.Next;
      end;

    Qt.Close;
    TRt.Commit;
  finally
   Qt.Free;
   TrT.Free;
  end;
end;

procedure Tfrmosmain.cbEntryTypeSelect(Sender: TObject);
Var
  Ini:TIniFile;
begin
 if cbEntryType.ItemIndex>=0 then begin
   with frmdm.QEntry do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT ');
    SQL.Add(' ENTRY.ID, ENTRY.TITLE, ENTRY.DATE_START, ENTRY.DATE_END, ');
    SQL.Add(' ENTRY.STATIONS_AMOUNT, ENTRY.DATE_ADDED, ENTRY.DATE_UPDATED, ');
    SQL.Add(' ENTRY.NOTES, ENTRY.ENTRY_TYPE_ID, ENTRY.SELECTED ');
    SQL.Add(' FROM ENTRY, ENTRY_TYPE ');
    SQL.Add(' WHERE ');
    SQL.Add(' ENTRY.ENTRY_TYPE_ID=ENTRY_TYPE.ID AND ENTRY_TYPE_ID IN ');
    SQL.Add(' (SELECT ID FROM ENTRY_TYPE WHERE NAME=:TypeName)');
    SQL.Add(' ORDER by ENTRY.TITLE, ENTRY.DATE_START ');
    ParambyName('TypeName').AsString:=cbEntryType.Text;
   Open;
   Last;
   First;
  end;

   Ini := TIniFile.Create(IniFileName);
   try
     Ini.WriteString( 'osmain', 'entry_type', cbEntryType.Text);
   finally
    Ini.Free;
   end;
 end;
end;


procedure Tfrmosmain.CDSNavigation;
Var
ID:integer;
begin
ID:=frmdm.Q.FieldByName('ID').AsInteger;
if NavigationOrder=false then exit;

 If NavigationOrder=true then begin
  NavigationOrder:=false; //blocking everthing until previous operations have been completed

  if not frmdm.QCruise.IsEmpty then
    frmdm.QCruise.Locate('ID', frmdm.Q.FieldByName('CRUISE_ID').AsInteger,[]);

     if frmmap_open=true then frmmap.ChangeID(ID); //Map
     if frmprofile_station_all_open=true then frmprofile_station_all.ChangeID(ID); //
     if frmprofile_station_single_open =true then frmprofile_station_single.ChangeID(ID);
     if frmprofile_plot_all_open=true then frmprofile_plot_all.ChangeID(ID);
     if frmmeteo_open=true then frmmeteo.ChangeID(ID);
 //  if InfoOpen      =true then Info.ChangeID;
 //  if QProfilesOpen =true then QProfiles.ChangeStation(ID);
 //  if DensOpen      =true then QDensity.ChangeDensStation(ID);
 //  if TSOPen        =true then frmToolTSDiagram.ChangeID;


 //  if MeteoOpen     =true then Meteo.ChangeAbsnum;
 //  if MLDOpen       =true then MLD.ChangeID;
 //  if TrackOpen     =true then frmVesselSpeed.ChangeID;
 //  if RossbyOpen    =true then Rossby.ChangeID;
 //  if QCTDOpen      =true then QCTD.ChangeID;
 //  if VertIntOpen   =true then VertInt.TblChange(ID)

  NavigationOrder:=true; //Завершили, открываем доступ к навигации
 end;
end;

procedure Tfrmosmain.iNewDatabaseClick(Sender: TObject);
Var
  Ini:TIniFile;
  DBName:string;
begin
  Ini := TIniFile.Create(IniFileName);
  try
   DBName:=Ini.ReadString( 'main', 'OceanFDBPath',  '');
  finally
    Ini.free;
  end;

  if FileExists(DBName) then begin
   frmcreatenewdb := Tfrmcreatenewdb.Create(Self);
    try
     if not frmcreatenewdb.ShowModal = mrOk then exit;
    finally
      frmcreatenewdb.Free;
      frmcreatenewdb := nil;
    end;
  end else
   if MessageDlg('Please, specify path to Ocean.fdb', mtWarning, [mbOk], 0)=mrOk then
    aSettings.Execute();
end;

procedure Tfrmosmain.iSupportTablesClick(Sender: TObject);
begin
  frmsupporttables := Tfrmsupporttables.Create(Self);
    try
     if not frmsupporttables.ShowModal = mrOk then exit;
    finally
      frmsupporttables.Free;
      frmsupporttables := nil;
    end;
end;

procedure Tfrmosmain.iServiceStatisticsClick(Sender: TObject);
begin
  frmservicestatistics := Tfrmservicestatistics.Create(Self);
    try
     if not frmservicestatistics.ShowModal = mrOk then exit;
    finally
      frmservicestatistics.Free;
      frmservicestatistics := nil;
    end;
end;


procedure Tfrmosmain.iInsertBottomDepthGEBCOClick(Sender: TObject);
begin
 InsertGEBCODepth;
 Showmessage('Bottom depth from GEBCO has been updated');
end;

procedure Tfrmosmain.iInsertLastLevelClick(Sender: TObject);
begin
 InsertLastLevel;
 Showmessage('Last levels have been updated');
end;


procedure Tfrmosmain.InsertGEBCODepth;
Var
  ID: int64;
  GEBCO, k: integer;
  Lon, lat: real;

  fname: string;
  ncid:integer;
  start: PArraySize_t;
  sp:array of smallint;
  lat0, lon0, step: real;

  TRt:TSQLTransaction;
  Qt, Qt1:TSQLQuery;

  nc_open:Tnc_open;
  nc_get_var1_short:Tnc_get_var1_short;
  nc_close:Tnc_close;

begin
   fname:=GlobalSupportPath+PathDelim+'bathymetry'+PathDelim+'GEBCO_2020.nc';

   if not FileExists(fname) then
    if MessageDlg('GEBCO is not found', mtWarning, [mbOk], 0)=mrOk then exit; // if there's no file

  try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   Qt1:=TSQLQuery.Create(self);
   Qt1.Database:=frmdm.IBDB;
   Qt1.Transaction:=TRt;

   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT ID, LATITUDE, LONGITUDE FROM STATION ');
     SQL.Add(' WHERE BOTTOMDEPTH_GEBCO IS NULL ORDER BY ID ');
    Open;
    Last;
    First;
   end;

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' UPDATE STATION SET ');
     SQL.Add(' BOTTOMDEPTH_GEBCO=:GEBCO ');
     SQL.Add(' WHERE ID=:ID ');
    Prepare;
   end;

   nc_open:=Tnc_open(GetProcedureAddress(netcdf, 'nc_open'));
   nc_get_var1_short:=Tnc_get_var1_short(GetProcedureAddress(netcdf, 'nc_get_var1_short'));
   nc_close:=Tnc_close(GetProcedureAddress(netcdf, 'nc_close'));

    // opening GEBCO_2020.nc
     nc_open(pansichar(fname), NC_NOWRITE, ncid);
     start:=GetMemory(SizeOf(TArraySize_t)*2);

     lat0:=-(89+(59/60)+(525E-1/3600));  // first latitude
     lon0:=-(179+(59/60)+(525E-1/3600)); // first longitude
     step  := 1/240;  // 15"

  k:=0;
  while not Qt.EOF do begin
   ID :=Qt.FieldByName('ID').AsInteger;
   Lat:=Qt.FieldByName('LATITUDE').AsFloat;
   Lon:=Qt.FieldByName('LONGITUDE').AsFloat;

    // search by indexes
    start^[0]:=abs(trunc((lat0-lat)/step)); // lat index
    start^[1]:=abs(trunc((lon0-lon)/step)); // lon index

    SetLength(sp, 1); // setting an empty array
     nc_get_var1_short(ncid, 2, start^, sp);  // sending request to the file
    GEBCO:=-sp[0]; // getting results

     with Qt1 do begin
       Close;
         ParamByName('ID').AsInteger:=ID;
         ParamByName('GEBCO').AsInteger:=GEBCO;
       ExecSQL;
     end;

   inc(k);

   {$IFDEF WINDOWS}
     Procedures.ProgressTaskbar(k, Qt.RecordCount);
   {$ENDIF}

   if (k mod 1000)=1 then TRt.CommitRetaining;

   Qt.Next;
  end;

finally
 sp:=nil;
 FreeMemory(start);
 nc_close(ncid);  // Close nc file

 {$IFDEF WINDOWS}
   Procedures.ProgressTaskbar(0, 0);
 {$ENDIF}

 Trt.Commit;
 Qt.Free;
 Qt1.Free;
 Trt.Free;
end;
end;


(* Insert LASTLEVEL where it is NULL *)
Procedure Tfrmosmain.InsertLastLevel;
var
  ID: int64;
  ci1, k, cnt:integer;
  Max_LLM, Max_LLD:variant;

  TRt:TSQLTransaction;
  Qt, Qt1:TSQLQuery;
begin

 TRt:=TSQLTransaction.Create(self);
 TRt.DataBase:=frmdm.IBDB;

 Qt:=TSQLQuery.Create(self);
 Qt.Database:=frmdm.IBDB;
 Qt.Transaction:=TRt;

 Qt1:=TSQLQuery.Create(self);
 Qt1.Database:=frmdm.IBDB;
 Qt1.Transaction:=TRt;

 try

  with Qt do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT ID FROM STATION ');
    SQL.Add(' WHERE LASTLEVEL_M IS NULL ');
    SQL.Add(' ORDER BY ID ');
   Open;
   Last;
     cnt:=Qt.RecordCount;
   First;
  end;

  k:=0;
  While not Qt.Eof do begin
   inc(k);
    ID:=Qt.FieldByName('ID').Value;

    Max_LLM:=-9;
    Max_LLD:=-9;
    for ci1:=0 to frmosmain.ListBox1.Count-1 do begin
      With Qt1 do begin
       Close;
        SQL.Clear;
        SQL.Add(' Select max(LEV_M) as LLM, max(LEV_DBAR) as LLD from ');
        SQL.Add(frmosmain.ListBox1.Items.Strings[ci1]);
        SQL.Add(' where ID=:pAbsNum ');
        Parambyname('pAbsnum').asInteger:=ID;
       Open;
          if not VarIsNull(Qt1.Fields[0].AsVariant) then Max_LLM:=Max(Max_LLM,Qt1.Fields[0].AsFloat);
          if not VarIsNull(Qt1.Fields[1].AsVariant) then Max_LLD:=Max(Max_LLD,Qt1.Fields[1].AsFloat);
       Close;
      end;
    end;

    if Max_LLM=-9 then Max_LLM:=Null;
    if Max_LLD=-9 then Max_LLD:=Null;

    With Qt1 do begin
       Close;
        SQL.Clear;
        SQL.Add(' Update STATION set ');
        SQL.Add(' LASTLEVEL_M=:LLM, ');
        SQL.Add(' LASTLEVEL_DBAR=:LLD ');
        SQL.Add(' where ID=:pAbsNum ');
        Parambyname('pAbsnum').Value:=ID;
        Parambyname('LLM').Value:=Max_LLM;
        Parambyname('LLD').Value:=Max_LLD;
       ExecSQL;
    end;

    {$IFDEF WINDOWS}
     Procedures.ProgressTaskbar(k, cnt);
    {$ENDIF}

    if (k mod 1000)=1 then TRt.CommitRetaining;

   Qt.Next;
  end;
  finally
   {$IFDEF WINDOWS}
     Procedures.ProgressTaskbar(0, 0);
   {$ENDIF}

   Trt.Commit;
   Qt.Free;
   Qt1.Free;
   Trt.Free;
  end;
end;


Procedure Tfrmosmain.UpdateCruiseInfo(ID: int64; TotalEqualDB:boolean);
Var
TRt:TSQLTransaction;
Qt:TSQLQuery;

cnt: integer;
latmin, latmax, lonmin, lonmax:real;
datemin, datemax, dateupd:TDateTime;
begin


 TRt:=TSQLTransaction.Create(self);
 TRt.DataBase:=frmdm.IBDB;

 Qt:=TSQLQuery.Create(self);
 Qt.Database:=frmdm.IBDB;
 Qt.Transaction:=TRt;

 try
  cnt:=0;
  with Qt do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT ');
    SQL.Add(' min(LATITUDE) as LatMin, ');
    SQL.Add(' max(LATITUDE) as LatMax, ');
    SQL.Add(' min(LONGITUDE) as LonMin, ');
    SQL.Add(' max(LONGITUDE) as LonMax, ');
    SQL.Add(' min(DATEANDTIME) as DateMin, ');
    SQL.Add(' max(DATEANDTIME) as DateMax, ');
    SQL.Add(' max(DATE_UPDATED) as DateUpd, ');
    SQL.Add(' count(ID) as cnt ');
    SQL.Add(' FROM STATION ');
    SQL.Add(' where CRUISE_ID=:CR_ID ');
    ParamByName('CR_ID').AsInteger:=ID;
   Open;
    if FieldByName('cnt').AsInteger>0 then begin
      LatMin:=FieldByName('LatMin').Value;
      LatMax:=FieldByName('LatMax').Value;
      LonMin:=FieldByName('LonMin').Value;
      LonMax:=FieldByName('LonMax').Value;
      DateMin:=FieldByName('DateMin').Value;
      DateMax:=FieldByName('DateMax').Value;
      DateUpd:=FieldByName('DateUpd').Value;
      cnt:=FieldByName('cnt').Value;
    end;
    if FieldByName('cnt').AsInteger=0 then begin
      LatMin:=0;
      LatMax:=0;
      LonMin:=0;
      LonMax:=0;
      DateMin:=EncodeDate(1900, 01, 01);
      DateMax:=EncodeDate(1900, 01, 01);
      DateUpd:=EncodeDate(1900, 01, 01);
      cnt:=0;
    end;
   Close;
  end;

  with Qt do begin
   Close;
    SQL.Clear;
    SQL.Add(' UPDATE CRUISE SET ');
    SQL.Add(' LATITUDE_MIN=:LatMin, ');
    SQL.Add(' LATITUDE_MAX=:LatMax, ');
    SQL.Add(' LONGITUDE_MIN=:LonMin, ');
    SQL.Add(' LONGITUDE_MAX=:LonMax, ');
    SQL.Add(' DATE_UPDATED=:DateUpd, ');
    SQL.Add(' DATE_START_DATABASE=:DateMin, ');
    SQL.Add(' DATE_END_DATABASE=:DateMax, ');
    SQL.Add(' STATIONS_DATABASE=:cnt, ');

    if TotalEqualDB=true then begin
      SQL.Add(' DATE_START_TOTAL=:DateMin, ');
      SQL.Add(' DATE_END_TOTAL=:DateMax, ');
      SQL.Add(' STATIONS_TOTAL=:cnt ');
    end;

    SQL.Add(' WHERE ID=:CR_ID ');
    ParamByName('CR_ID').AsInteger:=ID;
    ParamByName('LatMin').Value:=LatMin;
    ParamByName('LatMax').Value:=LatMax;
    ParamByName('LonMin').Value:=LonMin;
    ParamByName('LonMax').Value:=LonMax;
    ParamByName('DateMin').Value:=DateMin;
    ParamByName('DateMax').Value:=DateMax;
    ParamByName('DateUpd').Value:=DateUpd;
    ParamByName('cnt').Value:=cnt;
   ExecSQL;
  end;

 finally
  Qt.Close;
  Trt.Commit;
  Qt.Free;
  Trt.Free;
 end;
end;

procedure Tfrmosmain.iExportCIAClick(Sender: TObject);
begin
  frmExport_CIA := TfrmExport_CIA.Create(Self);
   try
    if not frmExport_CIA.ShowModal = mrOk then exit;
   finally
     frmExport_CIA.Free;
     frmExport_CIA := nil;
   end;
end;

procedure Tfrmosmain.iExportCOMFORTClick(Sender: TObject);
begin
  frmExport_COMFORT := TfrmExport_COMFORT.Create(Self);
   try
    if not frmExport_COMFORT.ShowModal = mrOk then exit;
   finally
     frmExport_COMFORT.Free;
     frmExport_COMFORT := nil;
   end;
end;

procedure Tfrmosmain.iExportCOMFORT_tableClick(Sender: TObject);
begin
  frmExport_COMFORT_table := TfrmExport_COMFORT_table.Create(Self);
   try
    if not frmExport_COMFORT_table.ShowModal = mrOk then exit;
   finally
     frmExport_COMFORT_table.Free;
     frmExport_COMFORT_table := nil;
   end;
end;


procedure Tfrmosmain.iLoadARGOClick(Sender: TObject);
begin
  frmload_argo := Tfrmload_argo.Create(Self);
   try
    if not frmload_argo.ShowModal = mrOk then exit;
   finally
     frmload_argo.Free;
     frmload_argo := nil;
   end;
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


procedure Tfrmosmain.iUpdateUnitsClick(Sender: TObject);
begin
  frmuntsupdate := Tfrmuntsupdate.Create(Self);
   try
    if not frmuntsupdate.ShowModal = mrOk then exit;
   finally
     frmuntsupdate.Free;
     frmuntsupdate := nil;
   end;
end;

procedure Tfrmosmain.iVisualizationGrapferHistorgamClick(Sender: TObject);
begin
  frmviz_grapfer_histogram := Tfrmviz_grapfer_histogram.Create(Self);
 try
  if not frmviz_grapfer_histogram.ShowModal = mrOk then exit;
 finally
   frmviz_grapfer_histogram.Free;
   frmviz_grapfer_histogram := nil;
end;
end;

procedure Tfrmosmain.iVisualizationSurferSquaresClick(Sender: TObject);
begin
  frmviz_surfer_squares := Tfrmviz_surfer_squares.Create(Self);
 try
  if not frmviz_surfer_squares.ShowModal = mrOk then exit;
 finally
   frmviz_surfer_squares.Free;
   frmviz_surfer_squares := nil;
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

procedure Tfrmosmain.iload_icesClick(Sender: TObject);
begin
 frmload_ices := Tfrmload_ices.Create(Self);
 try
  if not frmload_ices.ShowModal = mrOk then exit;
 finally
   frmload_ices.Free;
   frmload_ices := nil;
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

procedure Tfrmosmain.iMeteoClick(Sender: TObject);
begin
  if frmmeteo_open=true then frmmeteo.SetFocus else
     begin
        frmmeteo := Tfrmmeteo.Create(Self);
        frmmeteo.Show;
     end;
 //  frmmeteo.btnShowSelectedClick(self);
   frmmeteo_open:=true;
end;

procedure Tfrmosmain.ioutliersClick(Sender: TObject);
begin
  frmoutliers := Tfrmoutliers.Create(Self);
   try
    if not frmoutliers.ShowModal = mrOk then exit;
   finally
     frmoutliers.Free;
     frmoutliers:= nil;
   end;
end;

procedure Tfrmosmain.iPlotBathymetryClick(Sender: TObject);
begin
  frmbathymetry_plot := Tfrmbathymetry_plot.Create(Self);
   try
    if not frmbathymetry_plot.ShowModal = mrOk then exit;
   finally
     frmbathymetry_plot.Free;
     frmbathymetry_plot := nil;
   end;
end;

procedure Tfrmosmain.iQCflagfromfileClick(Sender: TObject);
begin
  OD.Filter:='Text files|*.TXT;*.txt';
    if OD.Execute then begin
     osqc_setflags.SetFlags(OD.FileName);
      If MessageDlg('QC flags have been set', mtInformation, [mbOk], 0)=mrOk then exit;
    end;
end;


procedure Tfrmosmain.iQC_dbar_meterClick(Sender: TObject);
begin
 frmqc_dbar_meters_consistency := Tfrmqc_dbar_meters_consistency.Create(Self);
   try
    if not frmqc_dbar_meters_consistency.ShowModal = mrOk then exit;
   finally
     frmqc_dbar_meters_consistency.Free;
     frmqc_dbar_meters_consistency:= nil;
   end;
end;

procedure Tfrmosmain.iQC_WideRangesClick(Sender: TObject);
begin
  frmQC_WideRanges := TfrmQC_WideRanges.Create(Self);
   try
    if not frmQC_WideRanges.ShowModal = mrOk then exit;
   finally
     frmQC_WideRanges.Free;
     frmQC_WideRanges:= nil;
   end;
end;


procedure Tfrmosmain.iStandarddeviationslayersClick(Sender: TObject);
begin
  frmQC_MeanProfile := TfrmQC_MeanProfile.Create(Self);
   try
    if not frmQC_MeanProfile.ShowModal = mrOk then exit;
   finally
     frmQC_MeanProfile.Free;
     frmQC_MeanProfile:= nil;
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


procedure Tfrmosmain.iDuplicatesClick(Sender: TObject);
begin
  frmqc_duplicates := Tfrmqc_duplicates.Create(Self);
    try
     if not frmqc_duplicates.ShowModal = mrOk then exit;
    finally
      frmqc_duplicates.Free;
      frmqc_duplicates:= nil;
    end;
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


procedure Tfrmosmain.iAboutClick(Sender: TObject);
Var
  winver, AboutProgram:string;
begin
 {$ifdef WINDOWS}
   {$ifdef WIN32}
     winver:='i386-win32';
   {$endif}

   {$ifdef WIN64}
     winver:='x86_64-win64';
   {$endif}
 {$endif}

 {$ifdef Linux}
   {$ifdef CPU32}
     winver:='i386-linux';
   {$endif}
   {$ifdef CPU64}
     winver:='x86_64-linux';
   {$endif}
 {$endif}

  {$ifdef DARWIN}
   {$ifdef CPU32}
     winver:='i386-darwin';
   {$endif}
   {$ifdef CPU64}
     winver:='x86_64-darwin';
   {$endif}
 {$endif}

  AboutProgram:='OceanShell ('+winver+')'+LineEnding+LineEnding+
                'Alexander Smirnov & Alexander Korablev'+LineEnding+
                '© 2004-2020';

  if messagedlg(AboutProgram, mtInformation, [mbOk], 0)=mrOk then exit;
end;

procedure Tfrmosmain.DBGridCruisePrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
 if ((column.Index=0) and (column.Title.Caption='')) or
    (column.FieldName='ID') then begin
    TDBGrid(sender).Canvas.Brush.Color := clBtnFace;
 end;

 if (gdRowHighlight in AState) then begin
    TDBGrid(Sender).Canvas.Brush.Color := clNavy;
    TDBGrid(Sender).Canvas.Font.Color  := clYellow;
    TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
 end;
end;

procedure Tfrmosmain.DBGridCruiseSelectEditor(Sender: TObject;
  Column: TColumn; var Editor: TWinControl);
begin
  if (Column.Index=2) and (cbPlatform.Count=0) then PopulatePlatformList;
  if (Column.Index=4) and (cbSource.Count=0)   then PopulateSourceList;

  if (Column.Index=2) or (Column.Index=4) then begin
    if (Editor is TCustomComboBox) then
      with Editor as TCustomComboBox do
          Style := csDropDownList;
    end;
end;

procedure Tfrmosmain.DBGridCruiseEditingDone(Sender: TObject);
Var
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
 par:string;
begin
  par:='';
  Case TDBGrid(Sender).SelectedColumn.Index of
    2: par:='PLATFORM';
    4: par:='SOURCE';
  end;

  if Par<>'' then begin
    try
     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qt:=TSQLQuery.Create(self);
     Qt.Transaction:=TRt;

     With Qt do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM '+Par+' WHERE NAME=:NAME ');
       ParamByName('NAME').AsString:=frmdm.QCruise.FieldByName(Par).AsString;
      Open;
       frmdm.QCruise.Edit;
       frmdm.QCruise.FieldByName(Par+'_ID').AsInteger:=Qt.Fields[0].AsInteger;
       frmdm.QCruise.Post;
      Close;
     end;
    Finally
     Qt.Close;
     TRt.Commit;
     Qt.Free;
    end;
  end;
end;


procedure Tfrmosmain.DBGridCruiseTitleClick(Column: TColumn);
Var
  id_old:integer;
  check_old: boolean;
begin
  if Column.Index=0 then begin
     id_old:=frmdm.QCruise.FieldByName('ID').AsInteger;
     check_old:=frmdm.QCruise.FieldByName('SELECTED').Value;
     try
       frmdm.QCruise.DisableControls;
       frmdm.QCruise.First;
       while not frmdm.QCruise.EOF do begin
        frmdm.QCruise.Edit;
         frmdm.QCruise.FieldByName('SELECTED').Value:=not check_old;
        frmdm.QCruise.Post;
        frmdm.QCruise.Next;
       end;
     finally
       frmdm.QCruise.Locate('ID', ID_old, []);
       frmdm.QCruise.EnableControls;
     end;
  end;

  if Column.Index>0 then sortbufds.SortBufDataSet(frmdm.QCruise, Column.FieldName);
end;

procedure Tfrmosmain.DBGridEntryTitleClick(Column: TColumn);
Var
  id_old:integer;
  check_old: boolean;
begin
  if Column.Index=0 then begin
     id_old:=frmdm.QEntry.FieldByName('ID').AsInteger;
     check_old:=frmdm.QEntry.FieldByName('SELECTED').Value;
     try
       frmdm.QEntry.DisableControls;
       frmdm.QEntry.First;
       while not frmdm.QEntry.EOF do begin
        frmdm.QEntry.Edit;
         frmdm.QEntry.FieldByName('SELECTED').Value:=not check_old;
        frmdm.QEntry.Post;
        frmdm.QEntry.Next;
       end;
     finally
       frmdm.QEntry.Locate('ID', ID_old, []);
       frmdm.QEntry.EnableControls;
     end;
  end;

  if Column.Index>0 then sortbufds.SortBufDataSet(frmdm.QEntry, Column.FieldName);
end;

procedure Tfrmosmain.DBGridStation2CellClick(Column: TColumn);
begin
  frmosmain.CDSNavigation;
end;

procedure Tfrmosmain.DBGridStation2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if (key=VK_UP) or (key=VK_DOWN) then frmosmain.CDSNavigation;
end;

procedure Tfrmosmain.DBGridStation2TitleClick(Column: TColumn);
Var
  id_old:integer;
  check_old: boolean;
begin
  if Column.Index=0 then begin
     id_old   :=frmdm.Q.FieldByName('ID').AsInteger;
     check_old:=frmdm.Q.FieldByName('SELECTED').Value;
     try
       frmdm.Q.DisableControls;
       frmdm.Q.First;
       while not frmdm.Q.EOF do begin
          frmdm.Q.Edit;
          frmdm.Q.FieldByName('SELECTED').Value:=not check_old;
          frmdm.Q.Post;
         frmdm.Q.Next;
       end;
     finally
       frmdm.Q.Locate('ID', ID_old, []);
       frmdm.Q.EnableControls;
     end;
  end;

  if Column.Index>0 then sortbufds.SortBufDataSet(frmdm.Q, Column.FieldName);
end;


procedure Tfrmosmain.FormResize(Sender: TObject);
begin
  tbFastAccess.Top:=PageControl1.Top;
  tbFastAccess.Left:=Width-10-tbFastAccess.Width;

  panel1.Height:=sbDatabase.Height+sbSelection.Height;

 { pCruiseFiller.Width:=tbCruise.Width-50-
                 (btnAddCruise.Width+
                  btnSaveCruise.Width+
                  //cbCruiseFilter.Width+
                  eCruiseFilter.Width);  }

  //pStationFiller.Width:=Width-330;
  Application.ProcessMessages;
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
  //showmessage(P.CommandLine);
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


(* Saving STATION search settings *)
procedure Tfrmosmain.SaveSettingsStationSearch;
Var
  Ini:TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger ( 'osmain', 'station_region_pcRegion', pcRegion.ActivePageIndex);
    Ini.WriteFloat   ( 'osmain', 'station_latmin',   seLatMin.Value);
    Ini.WriteFloat   ( 'osmain', 'station_latmax',   seLatMax.Value);
    Ini.WriteFloat   ( 'osmain', 'station_lonmin',   seLonMin.Value);
    Ini.WriteFloat   ( 'osmain', 'station_lonmax',   seLonMax.Value);
    Ini.WriteFloat   ( 'osmain', 'station_around_point_lat',    seAroundPointLat.Value);
    Ini.WriteFloat   ( 'osmain', 'station_around_point_lon',    seAroundPointLon.Value);
    Ini.WriteInteger ( 'osmain', 'station_around_point_radius', seAroundPointRaduis.Value);
    Ini.WriteInteger ( 'osmain', 'station_idmin',    seIDMin.Value);
    Ini.WriteInteger ( 'osmain', 'station_idmax',    seIDMax.Value);
    Ini.WriteString  ( 'osmain', 'station_platform', cbPlatform.Text);
    Ini.WriteString  ( 'osmain', 'station_country',  cbCountry.Text);
    Ini.WriteString  ( 'osmain', 'station_source',   cbSource.Text);
    Ini.WriteString  ( 'osmain', 'station_institute',cbInstitute.Text);
    Ini.WriteString  ( 'osmain', 'station_project',  cbProject.Text);

    Ini.WriteInteger ( 'osmain', 'station_region_pcDateandTime', pcDateandTime.ActivePageIndex);
    Ini.WriteBool    ( 'osmain', 'station_period',   chkPeriod.Checked);
    Ini.WriteDateTime( 'osmain', 'station_datemin',  dtpDateMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_datemax',  dtpDateMax.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateaddedmin',   dtpDateAddedMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateaddedmax',   dtpDateAddedMax.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateupdatedmin', dtpDateUpdatedMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateupdatedmax', dtpDateUpdatedMax.DateTime);

    Ini.WriteBool    ( 'osmain', 'station_chkIgnoreDuplicates', chkIgnoreDup.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkRegion',           chkRegion.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkIDRange',          chkIDRange.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkVariables',        chkParameter.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkQCFlag',           chkQCFlag.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkDateandTime',      chkDateandTime.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkDepth',            chkDepth.Checked);

  finally
    Ini.Free;
  end;
end;


(* Loading CRUISE search settings *)
procedure Tfrmosmain.LoadSettingsCruiseSearch;
Var
  Ini:TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
    try
     seCruiseLatMin.Value   :=Ini.ReadFloat  ( 'osmain', 'cruise_latmin',     0);
     seCruiseLatMax.Value   :=Ini.ReadFloat  ( 'osmain', 'cruise_latmax',     0);
     seCruiseLonMin.Value   :=Ini.ReadFloat  ( 'osmain', 'cruise_lonmin',     0);
     seCruiseLonMax.Value   :=Ini.ReadFloat  ( 'osmain', 'cruise_lonmax',     0);
     seCruiseIDMin.Value    :=Ini.ReadInteger( 'osmain', 'cruise_idmin',      0);
     seCruiseIDMax.Value    :=Ini.ReadInteger( 'osmain', 'cruise_idmax',      0);
     cbCruisePlatform.Text  :=Ini.ReadString ( 'osmain', 'cruise_platform',  '');
     cbCruiseCountry.Text   :=Ini.ReadString ( 'osmain', 'cruise_country',   '');
     cbCruiseSource.Text    :=Ini.ReadString ( 'osmain', 'cruise_source',    '');
     cbCruiseCruiseNum.Text :=Ini.ReadString ( 'osmain', 'cruise_cruisenum', '');
     cbCruiseInstitute.Text :=Ini.ReadString ( 'osmain', 'cruise_institute', '');
     cbCruiseProject.Text   :=Ini.ReadString ( 'osmain', 'cruise_project',   '');
     dtpCruiseDateDBMin.DateTime:=Ini.ReadDateTime('osmain', 'cruise_datedbmin', now);
     dtpCruiseDateDBMax.DateTime:=Ini.ReadDateTime('osmain', 'cruise_datedbmax', now);
     dtpCruiseDateTotMin.DateTime:=Ini.ReadDateTime('osmain', 'cruise_datetotmin', now);
     dtpCruiseDateTotMax.DateTime:=Ini.ReadDateTime('osmain', 'cruise_datetotmax', now);
     dtpCruiseDateAddedMin.DateTime:=Ini.ReadDateTime('osmain', 'cruise_dateaddedmin', now);
     dtpCruiseDateAddedMax.DateTime:=Ini.ReadDateTime('osmain', 'cruise_dateaddedmax', now);
     dtpCruiseDateUpdatedMin.DateTime:=Ini.ReadDateTime('osmain', 'cruise_dateupdatedmin', now);
     dtpCruiseDateUpdatedMax.DateTime:=Ini.ReadDateTime('osmain', 'cruise_dateupdatedmax', now);
     chkCruiseIgnoreDup.Checked   :=Ini.ReadBool('osmain', 'cruise_chkCruiseIgnoreDuplicates', false);
     chkCruiseNumStations.Checked :=Ini.ReadBool('osmain', 'cruise_chkCruiseNumStations',      false);
     chkCRUISEIDRange.Checked     :=Ini.ReadBool('osmain', 'cruise_chkCruiseIDRange',          false);
     chkCRUISEDateandtime.Checked :=Ini.ReadBool('osmain', 'cruise_chkCruiseDateandtime',      false);
     chkCRUISERegion.Checked      :=Ini.ReadBool('osmain', 'cruise_chkCruiseRegion',           false);
     chkCruiseQCFlag.Checked      :=Ini.ReadBool('osmain', 'cruise_chkQCFlag',                 false);
    finally
     Ini.Free;
    end;
end;

(* Saving CRUISE search settings *)
procedure Tfrmosmain.SaveSettingsCruiseSearch;
Var
  Ini:TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteFloat   ( 'osmain', 'cruise_latmin',   seCruiseLatMin.Value);
    Ini.WriteFloat   ( 'osmain', 'cruise_latmax',   seCruiseLatMax.Value);
    Ini.WriteFloat   ( 'osmain', 'cruise_lonmin',   seCruiseLonMin.Value);
    Ini.WriteFloat   ( 'osmain', 'cruise_lonmax',   seCruiseLonMax.Value);
    Ini.WriteInteger ( 'osmain', 'cruise_idmin',    seCruiseIDMin.Value);
    Ini.WriteInteger ( 'osmain', 'cruise_idmax',    seCruiseIDMax.Value);
    Ini.WriteString  ( 'osmain', 'cruise_platform', cbCruisePlatform.Text);
    Ini.WriteString  ( 'osmain', 'cruise_country',  cbCruiseCountry.Text);
    Ini.WriteString  ( 'osmain', 'cruise_source',   cbCruiseSource.Text);
    Ini.WriteString  ( 'osmain', 'cruise_cruisenum',cbCruiseCruiseNum.Text);
    Ini.WriteString  ( 'osmain', 'cruise_institute',cbCruiseInstitute.Text);
    Ini.WriteString  ( 'osmain', 'cruise_project',  cbCruiseProject.Text);
    Ini.WriteDateTime( 'osmain', 'cruise_datedbmin',   dtpCruiseDateDBMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_datedbmax',   dtpCruiseDateDBMax.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_datetotmin',  dtpCruiseDateTotMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_datetotmax',  dtpCruiseDateTotMax.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_dateaddedmin',   dtpCruiseDateAddedMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_dateaddedmax',   dtpCruiseDateAddedMax.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_dateupdatedmin', dtpCruiseDateUpdatedMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_dateupdatedmax', dtpCruiseDateUpdatedMax.DateTime);
    Ini.WriteBool    ( 'osmain', 'cruise_chkCruiseIgnoreDuplicates', chkCruiseIgnoreDup.Checked);
    Ini.WriteBool    ( 'osmain', 'cruise_chkCruiseNumStations',      chkCruiseNumStations.Checked);
    Ini.WriteBool    ( 'osmain', 'cruise_chkCruiseIDRange',          chkCRUISEIDRange.Checked);
    Ini.WriteBool    ( 'osmain', 'cruise_chkCruiseDateandtime',      chkCRUISEDateandtime.Checked);
    Ini.WriteBool    ( 'osmain', 'cruise_chkCruiseRegion',           chkCRUISERegion.Checked);
    Ini.WriteBool    ( 'osmain', 'cruise_chkQCFlag',                 chkCruiseQCFlag.Checked);
  finally
    Ini.Free;
  end;
end;

procedure Tfrmosmain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
Var
  Ini:TIniFile;
  k: integer;
begin
  Ini := TIniFile.Create(IniFileName);
   try
    Ini.WriteInteger( 'osmain', 'top',    Top);
    Ini.WriteInteger( 'osmain', 'left',   Left);
    Ini.WriteInteger( 'osmain', 'width',  Width);
    Ini.WriteInteger( 'osmain', 'weight', Height);

    Ini.WriteInteger( 'osmain', 'sbSelectedCruie_Width', sbSelectedCruise.width);
    Ini.WriteInteger( 'osmain', 'dbGridCruise_Height',   DBGridCruise.Height);

    (* cruise table columns *)
    With DBGridCruise do begin
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col00', Columns[0].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col01', Columns[1].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col02', Columns[2].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col03', Columns[3].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col04', Columns[4].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col05', Columns[5].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col06', Columns[6].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col07', Columns[7].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col08', Columns[8].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col09', Columns[9].Width);
    end;

    With DBGridEntry do begin
     Ini.WriteInteger( 'osmain', 'DBGridEntry_Col00',  Columns[0].Width);
     Ini.WriteInteger( 'osmain', 'DBGridEntry_Col01',  Columns[1].Width);
     Ini.WriteInteger( 'osmain', 'DBGridEntry_Col02',  Columns[2].Width);
     Ini.WriteInteger( 'osmain', 'DBGridEntry_Col03',  Columns[3].Width);
     Ini.WriteInteger( 'osmain', 'DBGridEntry_Col04',  Columns[4].Width);
     Ini.WriteInteger( 'osmain', 'DBGridEntry_Col05',  Columns[5].Width);
     Ini.WriteInteger( 'osmain', 'DBGridEntry_Col06',  Columns[6].Width);
     Ini.WriteInteger( 'osmain', 'DBGridEntry_Col07',  Columns[7].Width);
    end;

    with DBGridStation do begin
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col00',  Columns[0].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col01',  Columns[1].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col02',  Columns[2].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col03',  Columns[3].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col04',  Columns[4].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col05',  Columns[5].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col06',  Columns[6].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col07',  Columns[7].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col08',  Columns[8].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col09',  Columns[9].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col10',  Columns[10].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col11',  Columns[11].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation1_Col12',  Columns[12].Width );
    end;

    for k:=0 to cgQCFlag.Items.Count-1 do
      Ini.WriteBool( 'osmain', 'QCF'+inttostr(k), cgQCFlag.Checked[k]);

   finally
     Ini.Free;
   end;

   cbPlatform.Clear;
   cbCountry.Clear;
   cbSource.Clear;
   cbInstitute.Clear;
   cbProject.Clear;
end;


procedure Tfrmosmain.FormDestroy(Sender: TObject);
begin
  Source_unq_list.Free;
  PQF1_list.Free;
  PQF2_list.Free;
  SQF_list.Free;

  if frmdm.DBLoader.Enabled=true then frmdm.DBLoader.Enabled:=false;

  FreeLibrary(libgswteos);
  FreeLibrary(netcdf);

  if frmmap_open then frmmap.Close;
  if frmprofile_station_all_open then frmprofile_station_all.Close;
  if frmprofile_station_single_open then frmprofile_station_single.Close;
  if frmprofile_plot_all_open then frmprofile_plot_all.Close;
  if frmparameters_list_open then frmparameters_list.Close;
end;

end.


