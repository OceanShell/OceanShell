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
    btnCustomSQLQuery: TButton;
    btnOpenDB: TBitBtn;
    btnAddEntry: TToolButton;
    btnSaveCruise: TToolButton;
    btnSaveEntry: TToolButton;
    btnSelect: TButton;
    btnSelectID: TButton;
    cbCountry: TCheckComboBox;
    cbInstitute: TCheckComboBox;
    cbCruise: TCheckComboBox;
    cbPlatform: TCheckComboBox;
    cbPredefinedRegion: TComboBox;
    cbProject: TCheckComboBox;
    cbSource: TCheckComboBox;
    cgParameters: TCheckGroup;
    cgQCFlag: TCheckGroup;
    chkAuxMetadata: TCheckBox;
    chkCrNumStat: TCheckBox;
    chkCruiseIDList: TCheckBox;
    chkDateandTime: TCheckBox;
    chkDepth: TCheckBox;
    chkStationIDRange: TCheckBox;
    chkCruiseIDRange: TCheckBox;
    chkIgnoreDup: TCheckBox;
    chkNOTCountry: TCheckBox;
    chkNOTCruise: TCheckBox;
    chkNOTInstitute: TCheckBox;
    chkNOTPlatform: TCheckBox;
    chkNOTProject: TCheckBox;
    chkNOTSource: TCheckBox;
    chkParameter: TCheckBox;
    chkPeriod: TCheckBox;
    chkQCFlag: TCheckBox;
    chkRegion: TCheckBox;
    cbEntryType: TComboBox;
    chkShowQuery: TCheckBox;
    chkStationIDList: TCheckBox;
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
    dtpDateAddedMax: TDateTimePicker;
    dtpDateAddedMin: TDateTimePicker;
    dtpDateMax: TDateTimePicker;
    dtpDateMin: TDateTimePicker;
    dtpDateUpdatedMax: TDateTimePicker;
    dtpDateUpdatedMin: TDateTimePicker;
    FlowPanel1: TFlowPanel;
    gbAuxiliaryMetadata: TGroupBox;
    gbCRUISENumStations: TGroupBox;
    gbDateandTime: TGroupBox;
    gbDepth: TGroupBox;
    gbIDRange: TGroupBox;
    gbRegion: TGroupBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    gbSelectionMode: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    iProfilesAll: TMenuItem;
    iSelectStationsForCruise: TMenuItem;
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
    lbResetSearchStations: TLabel;
    mCruiseIDList: TMemo;
    iDataAnalysis: TMenuItem;
    iDA_ClusterAnalysis: TMenuItem;
    iSplitCruises: TMenuItem;
    iLoadICESnew: TMenuItem;
    iFixedStation: TMenuItem;
    iUpdateStationParameters: TMenuItem;
    iLoad_GLODAP_v2_2021: TMenuItem;
    MenuItem26: TMenuItem;
    iImportFirebird: TMenuItem;
    btnUpdateCruiseInfo: TMenuItem;
    MenuItem28: TMenuItem;
    mStationIDList: TMemo;
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
    iRestoreQC: TMenuItem;
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
    MenuItem24: TMenuItem;
    iBackupQC: TMenuItem;
    iInterpolatedProfile: TMenuItem;
    MenuItem25: TMenuItem;
    iMetadataUpdate: TMenuItem;
    iDensity: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
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
    Panel4: TPanel;
    pcCruiseNumStations: TPageControl;
    pStationIDList: TPanel;
    pDepth: TPanel;
    pCruiseNumStations: TPanel;
    pcDepth: TPageControl;
    pCruiseIDList: TPanel;
    pParameters: TPanel;
    pAuxiliaryMetadata: TPanel;
    pQCFlag: TPanel;
    pIDRange: TPanel;
    pcDateandTime: TPageControl;
    pDateAndTime: TPanel;
    pcRegion: TPageControl;
    pRegion: TPanel;
    pDataCruise: TPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    pEntryFilter: TPanel;
    PMStation: TPopupMenu;
    PMCruise: TPopupMenu;
    PMEntry: TPopupMenu;
    rbCruises: TRadioButton;
    rbStations: TRadioButton;
    sbDatabase: TStatusBar;
    sbSelection: TStatusBar;
    ODir: TSelectDirectoryDialog;
    sbStationSearch: TScrollBox;
    sbSelectedCruise: TScrollBox;
    seAroundPointLat: TFloatSpinEdit;
    seAroundPointLon: TFloatSpinEdit;
    seAroundPointRaduis: TSpinEdit;
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
    seCruiseIDMax: TSpinEdit;
    seCruiseIDMin: TSpinEdit;
    seCruiseStationsDatabaseMax: TSpinEdit;
    seCruiseStationsDatabaseMin: TSpinEdit;
    seCruiseStationsDuplicateMax: TSpinEdit;
    seCruiseStationsDuplicateMin: TSpinEdit;
    seCruiseStationsTotalMax: TSpinEdit;
    seCruiseStationsTotalMin: TSpinEdit;
    seDepthMax: TSpinEdit;
    seDepthMin: TSpinEdit;
    seGEBCOMax: TSpinEdit;
    seGEBCOMin: TSpinEdit;
    seStationIDMax: TSpinEdit;
    seStationIDMin: TSpinEdit;
    seLastLevelMax: TFloatSpinEdit;
    seLastLevelMin: TFloatSpinEdit;
    seLatMax: TFloatSpinEdit;
    seLatMin: TFloatSpinEdit;
    seLonMax: TFloatSpinEdit;
    seLonMin: TFloatSpinEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet11: TTabSheet;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    TabSheet14: TTabSheet;
    TabSheet15: TTabSheet;
    TabSheet16: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
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
    tsTimeAdded: TTabSheet;
    tsTimeObs: TTabSheet;
    tsTimeUpdated: TTabSheet;

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
    procedure btnOpenDBClick(Sender: TObject);
    procedure btnRemoveEntryClick(Sender: TObject);
    procedure btnSaveCruiseClick(Sender: TObject);
    procedure btnSaveEntryClick(Sender: TObject);
    procedure btnSelectIDClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnUpdateCruiseInfoClick(Sender: TObject);
    procedure cbCountryDropDown(Sender: TObject);
    procedure cbCruiseDropDown(Sender: TObject);
    procedure cbEntryTypeSelect(Sender: TObject);
    procedure cbInstituteDropDown(Sender: TObject);
    procedure cbPlatformDropDown(Sender: TObject);
    procedure cbPredefinedRegionDropDown(Sender: TObject);
    procedure cbProjectDropDown(Sender: TObject);
    procedure cbSourceDropDown(Sender: TObject);
    procedure chkAuxMetadataChange(Sender: TObject);
    procedure chkCrNumStatChange(Sender: TObject);
    procedure chkCruiseIDListChange(Sender: TObject);
    procedure chkCruiseIDRangeChange(Sender: TObject);
    procedure chkDateandTimeChange(Sender: TObject);
    procedure chkDepthChange(Sender: TObject);
    procedure chkStationIDListChange(Sender: TObject);
    procedure chkStationIDRangeChange(Sender: TObject);
    procedure chkParameterChange(Sender: TObject);
    procedure chkQCFlagChange(Sender: TObject);
    procedure chkRegionChange(Sender: TObject);
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
    procedure iBackupQCClick(Sender: TObject);
    procedure iDBStatisticsClick(Sender: TObject);
    procedure iDBStatistics_AKClick(Sender: TObject);
    procedure iDensityClick(Sender: TObject);
    procedure iExportDIVAndClick(Sender: TObject);
    procedure iDuplicatesClick(Sender: TObject);
    procedure iFixedStationClick(Sender: TObject);
    procedure iImportFirebirdClick(Sender: TObject);
    procedure iInsertBottomDepthGEBCOClick(Sender: TObject);
    procedure iExportCIAClick(Sender: TObject);
    procedure iExportCOMFORTClick(Sender: TObject);
    procedure iExportCOMFORT_tableClick(Sender: TObject);
    procedure iInterpolatedProfileClick(Sender: TObject);
    procedure iLoadARGOClick(Sender: TObject);
    procedure iLoadICESnewClick(Sender: TObject);
    procedure iLoadITPClick(Sender: TObject);
    procedure iLoad_GLODAP_2019_v2_productClick(Sender: TObject);
    procedure iLoad_GLODAP_v2_2021Click(Sender: TObject);
    procedure iload_icesClick(Sender: TObject);
    procedure iLoad_ITPClick(Sender: TObject);
    procedure iLoad_Pangaea_CTD_tabClick(Sender: TObject);
    procedure iLoad_WOD18Click(Sender: TObject);
    procedure iMetadataUpdateClick(Sender: TObject);
    procedure iMeteoClick(Sender: TObject);
    procedure ioutliersClick(Sender: TObject);
    procedure iPlotBathymetryClick(Sender: TObject);
    procedure iQCClick(Sender: TObject);
    procedure iRestoreQCClick(Sender: TObject);
    procedure iQC_dbar_meterClick(Sender: TObject);
    procedure iQC_WideRangesClick(Sender: TObject);
    procedure iSelectStationsForCruiseClick(Sender: TObject);
    procedure iNewDatabaseClick(Sender: TObject);
    procedure iSelectEntryClick(Sender: TObject);
    procedure iServiceStatisticsClick(Sender: TObject);
    procedure iSettingsClick(Sender: TObject);
    procedure iSplitCruisesClick(Sender: TObject);
    procedure iStandarddeviationslayersClick(Sender: TObject);
    procedure iSupportTablesClick(Sender: TObject);
    procedure iTDdiagramsClick(Sender: TObject);
    procedure iUpdateStationParametersClick(Sender: TObject);
    procedure iUpdateUnitsClick(Sender: TObject);
    procedure iVisualizationGrapferHistorgamClick(Sender: TObject);
    procedure iVisualizationSurferSquaresClick(Sender: TObject);
    procedure lbResetSearchStationsClick(Sender: TObject);
    procedure iExportASCIIClick(Sender: TObject);
    procedure itestClick(Sender: TObject);
    procedure MenuItem19Click(Sender: TObject);
    procedure iInsertLastLevelClick(Sender: TObject);
    procedure iExportFirebirdDBClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure rbCruisesChange(Sender: TObject);
    procedure rbStationsChange(Sender: TObject);

  private
    procedure SelectGetCruisesFromStation(temp_list:TStringList);
    procedure SaveSettingsSearch;

  public
    procedure OpenLocalDatabase(DBName:string);
    procedure OpenRegisteredDatabase(DBAlias: string);
    procedure DatabaseInfo;
    procedure SelectionInfo(UpdateCruises:boolean);
    procedure CDSNavigation;
    procedure ExpertModeOff;
    procedure GetSQLQueryText;

    Procedure UpdateCruiseInfo(ID: int64; TotalEqualDB:boolean);
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
    'CRUISE.ID, CRUISE.PLATFORM_ID, CRUISE.SOURCE_ID, CRUISE.CRUISE_NUMBER, '+
    'CRUISE.DATE_START_DATABASE, CRUISE.DATE_END_DATABASE, '+
    'CRUISE.STATIONS_DATABASE, CRUISE.STATIONS_DUPLICATES, '+
    'CRUISE.SELECTED, CRUISE.DUPLICATE, '+
    'SOURCE.NAME AS SOURCE,   '+
    'PLATFORM.NAME AS PLATFORM '+
    'FROM CRUISE, SOURCE, PLATFORM ';

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
  GlobalPath, GlobalDataPath, GlobalUnloadPath, GlobalSupportPath:string; //global paths for the app
  OceanToolsPath, DBAlias:string;
  CurrentParTable: string;
  Cruise_SQL_str, Station_SQL_str: string;

  source_list_open, country_list_open, platform_list_open: boolean;

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
  frmmeteo_open, frmprofile_interpolation_open, frmopendb_open: boolean;
  frmopendbreg_open, frminfo_open:boolean;

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
  osopendb,
  osopendb_reg,
  oscreatenewdb,
  osdbstructure_updater, //temporary module to be removed later
  ossettings,
  osinfo,
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
  osload_GLODAP_v2_2021_product,
  osload_WOD18,
  osload_PangaeaTab,
  osload_ices1,
  osload_ices2,

(* database service procedures *)
  ossupporttables,
  osservicestatistics,

(* dat import *)
  osimportdb,

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
  osqc_wideranges_upd,
  osqc_meanprofile,
  osqc_setflags,
  osqc_outliers,
  osqc_metadata_update,
  osqc_update_station_parameters,

(* tools *)
  osmap,
  osmap_kml,
  osparameters_list,
  osprofile_station_all,
  osprofile_station_single,
  osprofile_plot_all,
  osprofile_interpolation,
  osbathymetry_plot,
  osmeteo,
  ostools_density,

(* statistics *)
  osstatistics,
  osstatistics_AK,

(* visualization *)
  osviz_surfer_squares,
  osviz_grapher_histogram,

(* data analysis *)
  osca_splitcruises, //cluster analysis -> split cruises
  osca_fixedstation  //cluster analysis -> fixed stations
;

{$R *.lfm}


procedure Tfrmosmain.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
  k:integer;
begin

 // showmessage('here');

(* flags on open forms *)
 frmprofile_station_all_open:=false; frmprofile_station_single_open:=false;
 frmmap_open:=false; frmparameters_list_open:=false; frmmeteo_open:=false;
 frmprofile_plot_all_open:=false; frmprofile_interpolation_open:=false;
 frmopendb_open:=false; frmopendbreg_open:=false; frminfo_open:=false;

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

  //  showmessage('2');

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
    rbCruises.Checked      := Ini.ReadBool( 'osmain', 'station_cruises',        false);
    rbStations.Checked     := Ini.ReadBool( 'osmain', 'station_stations',       true);

    chkRegion.Checked      := Ini.ReadBool( 'osmain', 'station_chkRegion',      true);
    chkDateandTime.Checked := Ini.ReadBool( 'osmain', 'station_chkDateandTime', true);
    chkAuxMetadata.Checked := Ini.ReadBool( 'osmain', 'station_chkAuxMetadata', false);
    chkStationIDRange.Checked := Ini.ReadBool( 'osmain', 'station_chkIDRange',  false);
    chkCruiseIDRange.Checked  := Ini.ReadBool( 'osmain', 'cruise_chkIDRange',   false);
    chkStationIDList.Checked  := Ini.ReadBool( 'osmain', 'station_chkIDList',   false);
    chkCruiseIDList.Checked   := Ini.ReadBool( 'osmain', 'cruise_chkIDList',    false);

    chkParameter.Checked   := Ini.ReadBool( 'osmain', 'station_chkVariables',   false);
    chkQCFlag.Checked      := Ini.ReadBool( 'osmain', 'station_chkQCFlag',      false);
    chkDepth.Checked       := Ini.ReadBool( 'osmain', 'station_chkDepth',       false);
    chkCrNumStat.Checked   := Ini.ReadBool( 'osmain', 'cruise_chkNumStations',  false);

    chkIgnoreDup.Checked   := Ini.ReadBool( 'osmain', 'station_chkIgnoreDup',   true);
    chkShowQuery.Checked   := Ini.ReadBool( 'osmain', 'station_chkShowQuery',   false);


    pcRegion.ActivePageIndex:=Ini.ReadInteger( 'osmain', 'station_region_pcRegion', 0);
    seLatMin.Value   :=Ini.ReadFloat  ( 'osmain', 'station_latmin',     0);
    seLatMax.Value   :=Ini.ReadFloat  ( 'osmain', 'station_latmax',     0);
    seLonMin.Value   :=Ini.ReadFloat  ( 'osmain', 'station_lonmin',     0);
    seLonMax.Value   :=Ini.ReadFloat  ( 'osmain', 'station_lonmax',     0);

    seAroundPointLat.Value    := Ini.ReadFloat( 'osmain', 'station_around_point_lat',    0);
    seAroundPointLon.Value    := Ini.ReadFloat( 'osmain', 'station_around_point_lon',    0);
    seAroundPointRaduis.Value := Ini.ReadInteger( 'osmain', 'station_around_point_radius', 0);

    seStationIDMin.Value    :=Ini.ReadInteger( 'osmain', 'station_idmin',      0);
    seStationIDMax.Value    :=Ini.ReadInteger( 'osmain', 'station_idmax',      0);
    seCruiseIDMin.Value     :=Ini.ReadInteger( 'osmain', 'cruise_idmin',      0);
    seCruiseIDMax.Value     :=Ini.ReadInteger( 'osmain', 'cruise_idmax',      0);

    mCruiseIDList.Clear;
    mCruiseIDList.Lines.Add(Ini.ReadString( 'osmain', 'cruise_list',      ''));

    mStationIDList.Clear;
    mStationIDList.Lines.Add(Ini.ReadString( 'osmain', 'station_list',      ''));

    cbSource.Text    :=Ini.ReadString ( 'osmain', 'station_source',    '');
    cbPlatform.Text  :=Ini.ReadString ( 'osmain', 'station_platform',  '');
    cbCountry.Text   :=Ini.ReadString ( 'osmain', 'station_country',   '');
    cbCruise.Text    :=Ini.ReadString ( 'osmain', 'station_cruise',    '');
    cbInstitute.Text :=Ini.ReadString ( 'osmain', 'station_institute', '');
    cbProject.Text   :=Ini.ReadString ( 'osmain', 'station_project',   '');

    chkPeriod.Checked:=Ini.ReadBool   ( 'osmain', 'station_period', false);
    pcDateandTime.ActivePageIndex:=Ini.ReadInteger( 'osmain', 'station_region_pcDateandTime', 0);
    dtpDateMin.DateTime:=Ini.ReadDateTime('osmain', 'station_datemin', now);
    dtpDateMax.DateTime:=Ini.ReadDateTime('osmain', 'station_datemax', now);
    dtpDateAddedMin.DateTime:=Ini.ReadDateTime('osmain', 'station_dateaddedmin', now);
    dtpDateAddedMax.DateTime:=Ini.ReadDateTime('osmain', 'station_dateaddedmax', now);
    dtpDateUpdatedMin.DateTime:=Ini.ReadDateTime('osmain', 'station_dateupdatedmin', now);
    dtpDateUpdatedMax.DateTime:=Ini.ReadDateTime('osmain', 'station_dateupdatedmax', now);

    //Depth
    seDepthMin.Value    :=Ini.Readinteger  ( 'osmain', 'station_depthmin',   0);
    seDepthMax.Value    :=Ini.Readinteger  ( 'osmain', 'station_depthmax',   12000);
    seGEBCOMin.Value    :=Ini.Readinteger  ( 'osmain', 'station_gebcomin',   0);
    seGEBCOMax.Value    :=Ini.Readinteger  ( 'osmain', 'station_gebcomax',   12000);
    seLastLevelMin.Value:=Ini.ReadFloat    ( 'osmain', 'station_lastlevmin', 0);
    seLastLevelMax.Value:=Ini.ReadFloat    ( 'osmain', 'station_lastlevmax', 12000);

    //Cruise stations
    seCruiseStationsDatabaseMin.Value :=Ini.ReadInteger  ( 'osmain', 'cruises_stationsdatabasemin',  0);
    seCruiseStationsDatabaseMax.Value :=Ini.ReadInteger  ( 'osmain', 'cruises_stationsdatabasemax',  1000000);
    seCruiseStationsTotalMin.Value    :=Ini.ReadInteger  ( 'osmain', 'cruises_stationstotalmin',     0);
    seCruiseStationsTotalMax.Value    :=Ini.ReadInteger  ( 'osmain', 'cruises_stationstotalmax',     1000000);
    seCruiseStationsDuplicateMin.Value:=Ini.ReadInteger  ( 'osmain', 'cruises_stationsduplicatemin', 0);
    seCruiseStationsDuplicateMax.Value:=Ini.ReadInteger  ( 'osmain', 'cruises_stationsduplicatemax', 1000000);

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
    GlobalDataPath := Ini.ReadString('main', 'DataPath', GlobalPath+'data'+PathDelim);
      if not DirectoryExists(GlobalDataPath) then CreateDir(GlobalDataPath);
    GlobalSupportPath := Ini.ReadString('main', 'SupportPath', GlobalPath+'support'+PathDelim);
      if not DirectoryExists(GlobalSupportPath) then CreateDir(GlobalSupportPath);
    GlobalUnloadPath  := Ini.ReadString('main', 'UnloadPath', GlobalPath+'unload'+PathDelim);
      if not DirectoryExists(GlobalUnloadPath) then CreateDir(GlobalUnloadPath);
    OceanToolsPath    :=Ini.ReadString('main', 'OceanToolsPath', '');

  finally
    Ini.Free;
  end;

 // showmessage('2.1');

  if rbCruises.Checked then rbCruises.OnChange(self);
  if rbStations.Checked then rbStations.OnChange(self);

  chkRegion.OnChange(self);
  chkDateandTime.OnChange(self);
  chkCruiseIDRange.OnChange(self);
  chkStationIDRange.OnChange(self);
  chkCruiseIDList.OnChange(self);
  chkStationIDList.OnChange(self);
  chkAuxMetadata.OnChange(self);
  chkParameter.OnChange(self);
  chkQCFlag.OnChange(self);
  chkDepth.OnChange(self);
  chkCrNumStat.OnChange(self);

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



procedure Tfrmosmain.GetSQLQueryText;
Var
  k: integer;

  SSYearMin,SSYearMax,SSMonthMin,SSMonthMax,SSDayMin,SSDayMax :Word;
  NotCondCountry, NotCondPlatform, NotCondSource, NotCondCruise:string;
  NotCondInstitute, NotCondProject, NotCondOrigin, SBordersFile:string;

  QCFlag_str, source_str, country_str, platform_str, cruise_str:string;
  institute_str, project_str, cr: string;
begin

  if chkNOTCountry.Checked   =true then NotCondCountry   :='NOT' else NotCondCountry   :='';
  if chkNOTPlatform.Checked  =true then NotCondPlatform  :='NOT' else NotCondPlatform  :='';
  if chkNOTSource.Checked    =true then NotCondSource    :='NOT' else NotCondSource    :='';
  if chkNOTCruise.Checked    =true then NotCondCruise    :='NOT' else NotCondCruise    :='';
  if chkNOTInstitute.Checked =true then NotCondInstitute :='NOT' else NotCondInstitute :='';
  if chkNOTProject.Checked   =true then NotCondProject   :='NOT' else NotCondProject   :='';


   DecodeDate(dtpDateMin.Date, SSYearMin, SSMonthMin, SSDayMin);
   DecodeDate(dtpDateMax.Date, SSYearMax, SSMonthMax, SSDayMax);

   (* QC Flag *)
    QCFlag_str:='';
     if chkQCFlag.Checked=true then begin
      for k:=0 to cgQCFlag.Items.Count-1 do
       if cgQCFlag.Checked[k]=true then
        QCFlag_str:=QCFlag_str+
                   copy(cgQCFlag.Items.Strings[k], 2, Pos(']',
                        cgQCFlag.Items.Strings[k])-2)+',';
      QCFlag_str:=copy(QCFlag_str, 1, length(QCFlag_str)-1);
     end;

    (* Source *)
     source_str:='';
     if cbSource.Text<>'' then begin
      for k:=0 to cbSource.Count-1 do
        if cbSource.Checked[k]=true then
           source_str:=source_str+QuotedStr(cbSource.Items.Strings[k])+',';
      source_str:=copy(source_str, 1, length(source_str)-1);
     end;

     (* Country *)
     country_str:='';
     if cbCountry.Text<>'' then begin
      for k:=0 to cbCountry.Count-1 do
        if cbCountry.Checked[k]=true then
          country_str:=country_str+QuotedStr(cbCountry.Items.Strings[k])+',';
      country_str:=copy(country_str, 1, length(country_str)-1);
     end;

     (* Platform *)
     platform_str:='';
     if cbPlatform.Text<>'' then begin
      for k:=0 to cbPlatform.Count-1 do
        if cbPlatform.Checked[k]=true then
         platform_str:=platform_str+QuotedStr(cbPlatform.Items.Strings[k])+',';
       platform_str:=copy(platform_str, 1, length(platform_str)-1);
     end;

     (* Cruise number *)
     cruise_str:='';
     if cbCruise.Text<>'' then begin
       for k:=0 to cbCruise.Count-1 do
        if cbCruise.Checked[k]=true then
          if Pos('_', cbCruise.Text)>0 then
            cr:=copy(cbCruise.Text, 1, Pos('_', cbCruise.Text)-1) else
            cr:=cbCruise.Text;
         cruise_str:=cruise_str+cr+',';
         cruise_str:=copy(cruise_str, 1, length(cruise_str)-1);
     end;

     (* Institute *)
     institute_str:='';
     if cbInstitute.Text<>'' then begin
      for k:=0 to cbInstitute.Count-1 do
        if cbInstitute.Checked[k]=true then
         institute_str:=institute_str+QuotedStr(cbInstitute.Items.Strings[k])+',';
       institute_str:=copy(institute_str, 1, length(institute_str)-1);
     end;

     (* Project *)
     project_str:='';
     if cbProject.Text<>'' then begin
      for k:=0 to cbProject.Count-1 do
        if cbProject.Checked[k]=true then
         project_str:=project_str+QuotedStr(cbProject.Items.Strings[k])+',';
      project_str:=copy(project_str, 1, length(project_str)-1);
     end;


 //    showmessage(country_str);


(***********************************CRUISE_SQL_str*****************************)
      Cruise_SQL_str:='';

      (* IDs *)
      if chkCruiseIDRange.Checked then
        Cruise_SQL_str:=Cruise_SQL_str+
        ' AND (CRUISE.ID BETWEEN '+seCruiseIDMin.Text+
        ' AND '+seCruiseIDMax.Text+')';

      (* List of Cruise IDs *)
      if (chkCruiseIDList.Checked) and (mCruiseIDList.Lines.Count>0) then begin
        Cruise_SQL_str:=Cruise_SQL_str+' AND (CRUISE.ID IN (';
         for k:=0 to mCruiseIDList.Lines.Count-1 do
          Cruise_SQL_Str:=Cruise_SQL_str+mCruiseIDList.Lines.Strings[k];
        Cruise_SQL_Str:=Cruise_SQL_str+')) ';
      end;

     (* Coordinates *)
     if chkRegion.Checked then begin
     // if chNoEmptyCruises.Checked=false then begin
       Cruise_SQL_str:=Cruise_SQL_str+
       ' AND ((LATITUDE_MIN>='+seLatMin.Text+' AND LATITUDE_MAX<='+seLatMax.Text+') OR '+
       '      (LATITUDE_MIN BETWEEN '+seLatMin.Text+' AND '+seLatMax.Text+') OR '+
       '      (LATITUDE_MAX BETWEEN '+seLatMin.Text+' AND '+seLatMax.Text+') OR '+
       '      (LATITUDE_MIN <='+seLatMin.Text+' AND LATITUDE_MAX>='+seLatMax.Text+'))';

       if seLonMax.Value>=seLonMin.Value then
         Cruise_SQL_str:=Cruise_SQL_str+
         ' AND ((LONGITUDE_MIN>='+seLonMin.Text+'  AND LONGITUDE_MAX<='+seLonMax.Text+') OR '+
         '      (LONGITUDE_MIN BETWEEN '+seLonMin.Text+'  AND '+seLonMax.Text+') OR '+
         '      (LONGITUDE_MAX BETWEEN '+seLonMin.Text+'  AND '+seLonMax.Text+') OR '+
         '      (LONGITUDE_MIN <='+seLonMin.Text+' AND LONGITUDE_MAX>='+seLonMax.Text+'))';

       (* FIX NEEDED HERE *)
       if seLonMax.Value<seLonMin.Value then
        Cruise_SQL_str:=Cruise_SQL_str+
        ' AND ((LONGITUDE_MIN>='+seLonMin.Text+' AND LONGITUDE_MAX<=180) OR'+
        ' (LONGITUDE_MIN>=-180 AND LONGITUDE_MAX<='+seLonMax.Text+')) ';
    end;

     if chkDateandTime.Checked then begin
      case pcDateandTime.ActivePageIndex of
        0: begin
            Cruise_SQL_str:=Cruise_SQL_str+' AND ((DATE_START_DATABASE >= ';
            Cruise_SQL_str:=Cruise_SQL_str+QuotedStr(DateTimeToStr(dtpDateMin.DateTime))+' AND ';
            Cruise_SQL_str:=Cruise_SQL_str+'       DATE_END_DATABASE <=  ';
            Cruise_SQL_str:=Cruise_SQL_str+QuotedStr(DateTimeToStr(dtpDateMax.DateTime))+') OR ';
            Cruise_SQL_str:=Cruise_SQL_str+'      (DATE_START_DATABASE BETWEEN ';
            Cruise_SQL_str:=Cruise_SQL_str+QuotedStr(DateTimeToStr(dtpDateMin.DateTime))+' AND ';
            Cruise_SQL_str:=Cruise_SQL_str+QuotedStr(DateTimeToStr(dtpDateMax.DateTime))+') OR ';
            Cruise_SQL_str:=Cruise_SQL_str+'      (DATE_END_DATABASE BETWEEN ';
            Cruise_SQL_str:=Cruise_SQL_str+QuotedStr(DateTimeToStr(dtpDateMin.DateTime))+' AND ';
            Cruise_SQL_str:=Cruise_SQL_str+QuotedStr(DateTimeToStr(dtpDateMax.DateTime))+'))';
        end;
       1: begin
           Cruise_SQL_str:=Cruise_SQL_str+'  AND (CRUISE.DATE_ADDED BETWEEN ';
           Cruise_SQL_str:=Cruise_SQL_str+QuotedStr(DateTimeToStr(dtpDateAddedMin.DateTime))+' AND ';
           Cruise_SQL_str:=Cruise_SQL_str+QuotedStr(DateTimeToStr(dtpDateAddedMax.DateTime));
       end;
       2: begin
           Cruise_SQL_str:=Cruise_SQL_str+'  AND (CRUISE.DATE_UPDATED BETWEEN ';
           Cruise_SQL_str:=Cruise_SQL_str+QuotedStr(DateTimeToStr(dtpDateUpdatedMin.DateTime))+' AND ';
           Cruise_SQL_str:=Cruise_SQL_str+QuotedStr(DateTimeToStr(dtpDateUpdatedMax.DateTime));
       end;
      end;
     end;

    if chkCrNumStat.Checked=true then begin
      case pcCruiseNumStations.ActivePageIndex of
        0: begin
          Cruise_SQL_str:=Cruise_SQL_str+
          '  AND (STATIONS_DATABASE BETWEEN '+
          seCruiseStationsDatabaseMin.Text+' AND '+
          seCruiseStationsDatabaseMax.Text+') ';
        end;
        1: begin
          Cruise_SQL_str:=Cruise_SQL_str+
          '  AND (STATIONS_TOTAL BETWEEN '+
          seCruiseStationsTotalMin.Text+' AND '+
          seCruiseStationsTotalMax.Text+') ';
        end;
        2: begin
          Cruise_SQL_str:=Cruise_SQL_str+
          '  AND (STATIONS_DUPLICATES BETWEEN '+
          seCruiseStationsDuplicateMin.Text+' AND '+
          seCruiseStationsDuplicateMax.Text+') ';
        end;
      end;
    end;


    (* QC Flags *)
    if trim(QCFlag_str)<>'' then
       Cruise_SQL_str:=Cruise_SQL_str+
              ' AND CRUISE.ID IN (SELECT STATION.CRUISE_ID '+
              ' FROM STATION WHERE STATION.QCFLAG IN '+
              ' ('+QCFlag_str+')) ';

    if chkAuxMetadata.Checked=true then begin

     // if there's a cruise
    if cruise_str<>'' then
       Cruise_SQL_str:=Cruise_SQL_str+' AND '+NotCondCruise+
       ' CRUISE.ID IN ('+cruise_str+') ';

    //if there's a platform but no cruise
    if (platform_str<>'') and (cruise_str='') then
       Cruise_SQL_str:=Cruise_SQL_str+' AND '+NotCondPlatform+
       ' PLATFORM.NAME IN ('+platform_str+') ';

    //if there's a country, but no cruise
    if (country_str<>'') and (cruise_str='') then
       Cruise_SQL_str:=Cruise_SQL_str+' AND '+NotCondCountry+
       ' PLATFORM.COUNTRY_ID=COUNTRY.ID AND '+
       ' COUNTRY.NAME IN ('+country_str+') ';


    //if there's a source but no cruise
    if (source_str<>'') and (cruise_str='') then
       Cruise_SQL_str:=Cruise_SQL_str+' AND '+NotCondSource+
       ' SOURCE.NAME IN ('+source_str+') ';

    if institute_str<>'' then
       Cruise_SQL_str:=Cruise_SQL_str+' AND '+NotCondInstitute+
       ' CRUISE.ID IN (SELECT CRUISE.ID FROM CRUISE, INSTITUTE '+
       ' WHERE CRUISE.INSTITUTE_ID=INSTITUTE.ID AND '+
       ' INSTITUTE.NAME IN ('+institute_str+')) ';

    if project_str<>'' then
       Cruise_SQL_str:=Cruise_SQL_str+' AND '+NotCondProject+
       ' CRUISE.ID IN (SELECT CRUISE.ID FROM CRUISE, PROJECT '+
       ' WHERE CRUISE.PROJECT_ID=PROJECT.ID AND '+
       ' PROJECT.NAME IN ('+project_str+')) ';
    end;

    if chkIgnoreDup.Checked=true then
       Cruise_SQL_str:=Cruise_SQL_str+' AND CRUISE.DUPLICATE=FALSE ';

(*===========================END OF CRUISE_SQL_str============================*)


//showmessage(Cruise_SQL_str);

(******************************STATION_SQL_str*********************************)
Station_SQL_str:='';


   (* CRUISE ID range *)
   if chkCruiseIDRange.Checked=true then begin
       Station_SQL_str:=Station_SQL_str+
                        ' AND (STATION.CRUISE_ID BETWEEN '+seCruiseIDMin.Text+
                        ' AND '+seCruiseIDMax.Text+') ';
   end;

   (* STATION ID range *)
   if chkStationIDRange.Checked=true then begin
       Station_SQL_str:=Station_SQL_str+
                        ' AND (STATION.ID BETWEEN '+seStationIDMin.Text+
                        ' AND '+seStationIDMax.Text+') ';
   end;

   (* List of Cruise IDs *)
   if (chkCruiseIDList.Checked) and (mCruiseIDList.Lines.Count>0) then begin
     Station_SQL_str:=Station_SQL_str+' AND (STATION.CRUISE_ID IN (';
       for k:=0 to mCruiseIDList.Lines.Count-1 do
         Station_SQL_Str:=Station_SQL_str+mCruiseIDList.Lines.Strings[k];
     Station_SQL_Str:=Station_SQL_str+')) ';
   end;

   (* List of Station IDs *)
   if (chkStationIDList.Checked) and (mStationIDList.Lines.Count>0) then begin
     Station_SQL_str:=Station_SQL_str+' AND (STATION.ID IN (';
       for k:=0 to mStationIDList.Lines.Count-1 do
         Station_SQL_Str:=Station_SQL_str+mStationIDList.Lines.Strings[k];
     Station_SQL_Str:=Station_SQL_str+')) ';
   end;


   (* QC Flag *)
   if trim(QCFlag_str)<>'' then
     Station_SQL_str:=Station_SQL_str+' AND (STATION.QCFLAG IN ('+QCFlag_str+')) ';

 (* Coordinates *)
 if chkRegion.Checked=true then begin
   if pcRegion.ActivePageIndex=0 then begin
   Station_SQL_str:=Station_SQL_str+
                    ' AND (LATITUDE BETWEEN '+seLatMin.Text+
                    ' AND '+seLatMax.Text+') ';

    if seLonMax.Value>=seLonMin.Value then
      Station_SQL_str:=Station_SQL_str+
                    ' AND (LONGITUDE BETWEEN '+seLonMin.Text+
                    ' AND '+seLonMax.Text+') ';

    if seLonMax.Value<seLonMin.Value then
     Station_SQL_str:=Station_SQL_str+' AND ((LONGITUDE>='+seLonMin.Text+
                      ' AND LONGITUDE<=180) OR '+
                      '(LONGITUDE>=-180 and LONGITUDE<='+seLonMax.Text+')) ';
   end;
  end; //region


   (* Date and Time *)
   if chkDateandTime.Checked=true then begin

   if pcDateandTime.ActivePageIndex=0 then begin
   // From date to date
     if chkPeriod.Checked=false then begin
      Station_SQL_str:=Station_SQL_str+' AND (DATEANDTIME BETWEEN '+
                       QuotedStr(DateTimeToStr(dtpDateMin.DateTime))+' AND '+
                       QuotedStr(DateTimeToStr(dtpDateMax.DateTime))+') ';
     end;

    //Date in Period
    if chkPeriod.Checked=true then begin
     Station_SQL_str:=Station_SQL_str+' AND (Extract(Year from DATEANDTIME) BETWEEN '+
                      IntToStr(SSYearMin)+' AND '+
                      IntToStr(SSYearMax)+') ';

     if SSMonthMin<=SSMonthMax then
        Station_SQL_str:=Station_SQL_str+' AND (Extract(Month from DATEANDTIME) BETWEEN '+
                         IntToStr(SSMonthMin)+' AND '+
                         IntToStr(SSMonthMax)+') ';
     if SSMonthMin>SSMonthMax then
        Station_SQL_str:=Station_SQL_str+' AND ((Extract(Month from DATEANDTIME)>= '+
                         IntToStr(SSMonthMin)+') OR'+
                         ' (Extract(Month from DATEANDTIME)<= '+
                         IntToStr(SSMonthMax)+')) ';
     if SSDayMin<=SSDayMax then
        Station_SQL_str:=Station_SQL_str+' AND (Extract(Day from DATEANDTIME) BETWEEN '+
                         IntToStr(SSDayMin)+' AND '+
                         IntToStr(SSDayMax)+') ';
     if SSDayMin>SSDayMax then
        Station_SQL_str:=Station_SQL_str+' AND ((Extract(Day from DATEANDTIME)>= '+
                         IntToStr(SSDayMin)+') OR '+
                         ' (Extract(Day from DATEANDTIME)<= '+
                         IntToStr(SSDayMax)+')) ';
    end;
   end;

   (* DATE_ADDED *)
   if pcDateandTime.ActivePageIndex=1 then begin
     Station_SQL_str:=Station_SQL_str+' AND (STATION.DATE_ADDED BETWEEN '+
                      QuotedStr(DateTimeToStr(dtpDateAddedMin.DateTime))+' AND '+
                      QuotedStr(DateTimeToStr(dtpDateAddedMax.DateTime))+' ) ';
   end;

   (* DATE_UPDATED *)
   if pcDateandTime.ActivePageIndex=2 then begin
    Station_SQL_str:=Station_SQL_str+' AND (STATION.DATE_UPDATED between '+
                     QuotedStr(DateTimeToStr(dtpDateUpdatedMin.DateTime))+' AND '+
                     QuotedStr(DateTimeToStr(dtpDateUpdatedMax.DateTime))+' ) ';
   end;
   end; // dates


  if chkAuxMetadata.Checked=true then begin

  // showmessage('here');
   // if there is a cruise
   if cruise_str<>'' then
    Station_SQL_str:=Station_SQL_str+
    ' AND '+NotCondCruise+
    ' (STATION.CRUISE_ID IN ('+cruise_str+')) ';

   //if there's a platform but no cruise
   if (platform_str<>'') and (cruise_str='') then
     Station_SQL_str:=Station_SQL_str+
     ' AND (STATION.CRUISE_ID IN (SELECT CRUISE.ID FROM '+
     ' CRUISE, PLATFORM WHERE CRUISE.PLATFORM_ID=PLATFORM.ID AND '+
     NotCondSource+' PLATFORM.NAME IN ('+platform_str+'))) ';

   //if there's a country, but no cruise/platform
   if (country_str<>'') and  (cruise_str='') then
     Station_SQL_str:=Station_SQL_str+
     ' AND (STATION.CRUISE_ID IN (SELECT CRUISE.ID FROM '+
     ' CRUISE, PLATFORM, COUNTRY WHERE CRUISE.PLATFORM_ID=PLATFORM.ID AND '+
     ' PLATFORM.COUNTRY_ID=COUNTRY.ID AND '+NotCondSource+
     ' COUNTRY.NAME IN ('+country_str+'))) ';

   //if there's a source but no cruise
   if (source_str<>'') and (cruise_str='') then
    Station_SQL_str:=Station_SQL_str+
    ' AND (STATION.CRUISE_ID IN (SELECT CRUISE.ID FROM '+
    ' CRUISE, SOURCE WHERE CRUISE.SOURCE_ID=SOURCE.ID AND '+
    NotCondSource+' SOURCE.NAME IN ('+source_str+'))) ';

  // showmessage(station_sql_str);


   if institute_str<>'' then
    Station_SQL_str:=Station_SQL_str+
    ' AND (STATION.CRUISE_ID IN (SELECT CRUISE.ID FROM '+
    ' CRUISE, INSTITUTE WHERE CRUISE.INSTITUTE_ID=INSTITUTE.ID AND '+
    NotCondSource+' INSTITUTE.NAME IN ('+institute_str+'))) ';


   if project_str<>'' then
    Station_SQL_str:=Station_SQL_str+
    ' AND (STATION.CRUISE_ID IN (SELECT CRUISE.ID FROM '+
    ' CRUISE, PROJECT WHERE CRUISE.PROJECT_ID=PROJECT.ID AND '+
    NotCondSource+' PROJECT.NAME IN ('+project_str+'))) ';
 end;


   (* Parameters *)
   if chkParameter.Checked=true then begin
    for k:=0 to cgParameters.Items.Count-1 do
      if cgParameters.Checked[k] then
       Station_SQL_str:=Station_SQL_str+
       ' AND (STATION.ID IN (SELECT DISTINCT(ID) FROM '+
       cgParameters.Items.Strings[k]+')) ';
   end;

   (* Depth *)
   if chkDepth.Checked=true then begin
     if pcDepth.ActivePageIndex=0 then begin
      Station_SQL_str:=Station_SQL_str+
      ' AND (STATION.BOTTOMDEPTH BETWEEN '+
      seDepthMin.Text+' AND '+seDepthMax.Text+') ';
     end;
     if pcDepth.ActivePageIndex=1 then begin
      Station_SQL_str:=Station_SQL_str+
      ' AND (STATION.BOTTOMDEPTH_GEBCO BETWEEN '+
      seGebcoMin.Text+' AND '+seGebcoMax.Text+') ';
     end;
     if pcDepth.ActivePageIndex=2 then begin
      Station_SQL_str:=Station_SQL_str+
      ' AND (STATION.LASTLEVEL_M BETWEEN '+
      seLastLevelMin.Text+' AND '+seLastLevelMax.Text+') ';
     end;
   end;

   if chkIgnoreDup.Checked=true then
     Station_SQL_str:=Station_SQL_str+' AND (STATION.DUPLICATE=FALSE) ';

   if copy(Station_SQL_str, 1, 4)=' AND' then
     Station_SQL_str:=Copy(Station_SQL_str, 5, length(Station_SQL_str));


end;



procedure Tfrmosmain.btnSelectClick(Sender: TObject);
var
i, k, fl:integer;


dlat, dlon, lat, lon, dist:real;
time0, time1:TDateTime;
buf_str, cr: string;
LatMin, LatMax, LonMin, LonMax:real;
begin

frmosmain.Enabled:=false;
Application.ProcessMessages;
try

  //Saving current search settings
  SaveSettingsSearch;

  //closing transaction if it's still active
  if frmdm.TR.Active=true then frmdm.TR.Commit;

  GetSQLQueryText;

(*************************** Selecting CRUISES ********************************)
  if rbCruises.Checked=true then begin
   SelectionInfo(false);
   CDSNavigation;

   try
   frmdm.QCruise.DisableControls;
   with frmdm.QCruise do begin
    Close;
      SQL.Clear;
      SQL.Add(CruiseSQL);
      SQL.Add(' WHERE ');
      SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
      SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID ');
      if trim(CRUISE_SQL_str)<>'' then
        SQL.Add(CRUISE_SQL_str);
     SQL.Add(' ORDER BY PLATFORM.NAME, CRUISE.DATE_START_TOTAL ' );

     if chkShowQuery.Checked then
       if MessageDlg(SQL.Text+#13+#13+'Execute the query?',
                    mtInformation, [mbYes, mbNo],0)=mrNo then exit;
   Open;
   Last;
   First;
  end;

   if not frmdm.QCruise.IsEmpty then begin
    tsSelectedStations.Caption:='Cruises: '+inttostr(frmdm.QCruise.RecordCount);
    PageControl1.ActivePageIndex:=2;
   end;

   finally
    frmdm.QCruise.EnableControls;
    tsSelectedStations.TabVisible:= not frmdm.QCruise.IsEmpty;
   end;
  end;
(***********************END OF CRUISE SELECTION *******************************)



(**********************SELECTING STATIONS**************************************)
 if rbStations.Checked=true then begin

    if pcRegion.ActivePageIndex>0 then begin
     // around point
     if pcRegion.ActivePageIndex=1 then begin
      PositionByDistance(seAroundPointLat.Value,
                         seAroundPointLon.Value,
                         seAroundPointRaduis.Value,
                         LatMin, LatMax, LonMin, LonMax);
     end;

     // arbitrary region
     if pcRegion.ActivePageIndex=2 then begin
      if cbPredefinedRegion.ItemIndex<0 then
        if MessageDlg('Choose a region first', mtWarning, [mbOk], 0)=mrOk then exit;

      ArbytraryRegion.GetArbirtaryRegion(
      GlobalSupportPath+'sea_borders'+PathDelim+
      cbPredefinedRegion.Text+'.bln',
      LatMin, LatMax, LonMin, LonMax);
     end;

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
         if LonMax<=180 then begin
           SQL.Add(' (LONGITUDE BETWEEN ');
           SQL.Add(floattostr(LonMin)+' AND ');
           SQL.Add(floattostr(LonMax)+') ');
         end;
         if LonMax>180 then begin
           SQL.Add(' ((LONGITUDE>= ');
           SQL.Add(floattostr(LonMin));
           SQL.Add(' AND LONGITUDE<=180) OR ');
           SQL.Add('(LONGITUDE>=-180 and LONGITUDE<= ');
           SQL.Add(floattostr(LonMax)+')) ');
         end;
         SQL.Add(' AND '+Station_SQL_str);
      // showmessage(frmdm.q1.SQL.Text);
       Open;
      end;

    //  showmessage(inttostr(frmdm.q1.RecordCount));

      while not frmdm.q1.EOF do begin
         Lat:=frmdm.q1.FieldByName('LATITUDE').Value;
         Lon:=frmdm.q1.FieldByName('LONGITUDE').Value;

         if pcRegion.ActivePageIndex=1 then
            Distance(seAroundPointLon.Value, Lon,
                     seAroundPointLat.Value, Lat,
                     Dist);

         if ((pcRegion.ActivePageIndex=1) and (dist<=seAroundPointRaduis.Value)) or
            ((pcRegion.ActivePageIndex=2) and (Odd(Point_Status(Lon,Lat)))) then begin
         // mCruiseIDList.lines.add(floattostr(lat)+'   '+floattostr(lon));
          with frmdm.q2 do begin
           Close;
            SQL.Clear;
            SQL.Add(' INSERT INTO TEMPORARY_ID_LIST ');
            SQL.Add(' (ID) VALUES (:ID) ');
            ParamByName('ID').Value:=frmdm.q1.FieldByName('ID').Value;
           ExecSQL;
          end;
         end;
       frmdm.q1.Next;
      end;
      frmdm.TR.CommitRetaining;
      Station_SQL_str:=' STATION.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) ';
    end;


   with frmdm.Q do begin
    Close;
     SQL.Clear;
     SQL.Add(StationSQL);
     if trim(Station_SQL_str)<>'' then begin
      SQL.Add(' WHERE ');
      SQL.Add(Station_SQL_str);
     end;
     SQL.Add('ORDER BY DATEANDTIME ');

     (* Show the query before executing *)
     if chkShowQuery.Checked then
      if MessageDlg(SQL.Text+#13+#13+'Execute the query?',
                    mtInformation, [mbYes, mbNo],0)=mrNo then exit;
    Open;
    Last;
    First;
   end;
   SelectionInfo(true);
   CDSNavigation;
  end;

finally
  frmosmain.Enabled:=true;
  Application.ProcessMessages;
end;
end;



procedure Tfrmosmain.btnUpdateCruiseInfoClick(Sender: TObject);
Var
  crID_old, cnt:Int64;
begin

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
        UpdateCruiseInfo(frmdm.QCruise.FieldByName('ID').Value, true);
     end;
     frmdm.QCruise.Next;
    end;
    frmdm.TR.CommitRetaining;
   finally
    frmdm.QCruise.Locate('ID', crID_old, []);
    frmdm.QCruise.EnableControls;
    Showmessage('Please, redo the selection');
   end;
end;


procedure Tfrmosmain.SelectGetCruisesFromStation(temp_list:TStringList);
Var
  k:integer;
begin

//   showmessage('2.2');

  (* Cleansing the temporary list *)
  with frmdm.q2 do begin
    Close;
      SQL.Clear;
      SQL.Add(' DELETE FROM TEMPORARY_ID_LIST ');
    ExecSQL;
  end;
  frmdm.TR.CommitRetaining;

 //  showmessage(DateTimeToStr(now-t_begin));
//  showmessage('2.3');

  (* populating ID list *)
  for k:=0 to temp_list.Count-1 do begin
   with frmdm.q2 do begin
    Close;
      SQL.Clear;
      SQL.Add(' INSERT INTO TEMPORARY_ID_LIST ');
      SQL.Add(' (ID) VALUES (:ID) ');
      ParamByName('ID').Value:=StrToInt(temp_list.Strings[k]);
    ExecSQL;
   end;
  end;
  frmdm.TR.CommitRetaining;

 //  showmessage(DateTimeToStr(now-t_begin));
 // showmessage('2.4');
 // showmessage(inttostr(temp_list.Count));
   with frmdm.QCruise do begin
    Close;
      SQL.Clear;
      SQL.Add(CruiseSQL);
      SQL.Add(' WHERE ');
      SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
      SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
      SQL.Add(' CRUISE.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) ');
      SQL.Add(' ORDER BY PLATFORM.NAME, CRUISE.DATE_START_DATABASE ' );
      //showmessage(SQL.Text);
    Open;
    Last;
    First;
   end;

  //  showmessage('2.5');

  With frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' SELECT DISTINCT(SOURCE.NAME) FROM ');
     SQL.Add(' SOURCE, CRUISE ');
     SQL.Add(' WHERE ');
     SQL.Add(' SOURCE.ID=CRUISE.SOURCE_ID AND ');
     SQL.Add(' CRUISE.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) ');
   Open;
  end;

//  showmessage('2.1');
  Source_unq_list.Clear;
  while not frmdm.q1.EOF do begin
     Source_unq_list.Add(frmdm.q1.Fields[0].AsString);
   frmdm.q1.Next;
  end;
  frmdm.q1.Close;
end;

procedure Tfrmosmain.btnSelectIDClick(Sender: TObject);
Var
 dat: text;
 ID:integer;
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

  if frmdm.TR.Active=true then frmdm.TR.Commit;

  try
   if frmosmain.rbCruises.Checked then begin
     with frmdm.QCruise do begin
       Close;
        SQL.Clear;
        SQL.Add(CruiseSQL);
        SQL.Add(' WHERE ');
        SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
        SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
        SQL.Add(' CRUISE.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) ');
        SQL.Add(' ORDER BY PLATFORM.NAME, CRUISE.DATE_START_TOTAL ' );
       Open;
       Last;
       First;
     end;

     if not frmdm.QCruise.IsEmpty then begin
       tsSelectedStations.Caption:='Cruises: '+inttostr(frmdm.QCruise.RecordCount);
       PageControl1.ActivePageIndex:=2;
     end;
     tsSelectedStations.TabVisible:= not frmdm.QCruise.IsEmpty;
  end;

  if frmosmain.rbStations.Checked then begin
     with frmdm.Q do begin
       Close;
        SQL.Clear;
        SQL.Add(StationSQL);
        SQL.Add(' WHERE ');
        SQL.Add(' STATION.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) ');
       Open;
       Last;
       First;
     end;
    SelectionInfo(true);
    CDSNavigation;
  end;

 finally
   frmosmain.Enabled:=true;
   Application.ProcessMessages;
 end;

end;


procedure Tfrmosmain.iSelectStationsForCruiseClick(Sender: TObject);
Var
 crID_OLD, cnt: int64;
 temp_list:TStringList;
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

 //  showmessage('2');

 // if frmdm.TR.Active=true then frmdm.TR.CommitRetaining;
   with frmdm.Q do begin
     Close;
      SQL.Clear;
      SQL.Add(StationSQL);
      SQL.Add(' WHERE STATION.CRUISE_ID IN (SELECT ID FROM TEMPORARY_ID_LIST) '); //('+id_str+') ');
    //  showmessage(frmdm.Q.SQL.Text);
      Open;
   end;

  //   showmessage('3');

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

//  showmessage('here');

  SelectionInfo(false);
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

   with frmdm.Q do begin
     Close;
      SQL.Clear;
      SQL.Add(StationSQL);
      SQL.Add(' WHERE STATION.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) '); //('+id_str+') ');
     // showmessage(frmdm.Q.SQL.Text);
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


  SelectionInfo(true);
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
        SQL.Add(' WHERE ');
        SQL.Add(SQL_str);
        SQL.Add(' ORDER BY DATEANDTIME ');
     //  showmessage(SQL.text);
       Open;
       Last;
       First;
     end;

  //   SelectGetCruisesFromStation(SQL_str);

     SelectionInfo(true);
     CDSNavigation;
     Application.ProcessMessages;
end;

procedure Tfrmosmain.lbResetSearchStationsClick(Sender: TObject);
Var
  k:integer;
begin

{  chkRegion.Checked:=true;
  chkDateandTime.Checked:=true;
  chkStationIDRange.Checked:=false;
  chkAuxMetadata.Checked:=false;
  chkQCFlag.Checked:=false;
  chkParameter.Checked:=false;
  chkDepth.Checked:=false;  }

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

  cbSource.Clear;
  cbCountry.Clear;
  cbPlatform.Clear;
  cbCruise.Clear;
  cbInstitute.Clear;
  cbProject.Clear;

  chkNOTPlatform.Checked:=false;
  chkNOTCountry.Checked:=false;
  chkNOTSource.Checked:=false;
  chkNOTInstitute.Checked:=false;
  chkNOTProject.Checked:=false;
  chkNOTCruise.Checked:=false;

  seStationIDMin.Value:=StationIDMin;
  seStationIDMax.Value:=StationIDMax;
  seCruiseIDMin.Value:=CruiseIDMin;
  seCruiseIDMax.Value:=CruiseIDMax;

  mCruiseIDList.Clear;
  mStationIDList.Clear;

  dtpDateMin.DateTime:=StationDateMin;
  dtpDateMax.DateTime:=StationDateMax;

  seCruiseStationsTotalMin.Value:=0;
  seCruiseStationsTotalMax.Value:=CruiseStationsTotalMax;
  seCruiseStationsDatabaseMin.Value:=0;
  seCruiseStationsDatabaseMax.Value:=CruiseStationsDatabaseMax;
  seCruiseStationsDuplicateMin.Value:=0;
  seCruiseStationsDuplicateMax.Value:=CruiseStationsDuplicateMax;

  chkPeriod.Checked:=false;

  dtpDateAddedMin.DateTime:=StationDateAddedMin;
  dtpDateAddedMax.DateTime:=StationDateAddedMax;
  dtpDateUpdatedMin.DateTime:=StationDateUpdatedMin;
  dtpDateUpdatedMax.DateTime:=StationDateUpdatedMax;

  seCruiseStationsTotalMax.Value:=0;
  seCruiseStationsTotalMax.Value:=CruiseStationsTotalMax;
  seCruiseStationsDatabaseMin.Value:=0;
  seCruiseStationsDatabaseMax.Value:=CruiseStationsDatabaseMax;
  seCruiseStationsDuplicateMin.Value:=0;
  seCruiseStationsDuplicateMax.Value:=CruiseStationsDuplicateMax;

  for k:=0 to cgParameters.Items.Count-1 do
    cgParameters.Checked[k]:=false;

  for k:=0 to cgQCFlag.Items.Count-1 do
    cgQCFlag.Checked[k]:=true;
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

procedure Tfrmosmain.iDensityClick(Sender: TObject);
begin
  frmcompute_density := Tfrmcompute_density.Create(Self);
   try
    if not frmcompute_density.ShowModal = mrOk then exit;
   finally
     frmcompute_density.Free;
     frmcompute_density := nil;
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
  //showmessage(inttostr(osbathymetry.getgebcodepth(66, 2)));
  frmdm.q1.Close;
 frmdm.q1.SQL.text:='select RDB$GET_CONTEXT('+
 QuotedStr('SYSTEM')+', '+QuotedStr('WIRE_COMPRESSED')+
 ') as st from rdb$database';
 showmessage(frmdm.q1.SQL.text);
 frmdm.q1.Open;
 showmessage(frmdm.q1.Fields[0].Value);
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

     with frmdm.QEntry do begin
       Append;
        FieldByName('ID').Value:=max_id+1;
        FieldByName('ENTRY_TYPE_ID').Value:=type_id;
        FieldByName('ENTRY_TYPE_ID').Value:=type_id;
        FieldByName('STATIONS_AMOUNT').Value:=0;
        FieldByName('DATE_START').Value:=Now;
        FieldByName('DATE_END').Value:=Now;
        FieldByName('DATE_ADDED').Value:=Now;
        FieldByName('DATE_UPDATED').Value:=Now;
        FieldByName('SELECTED').Value:=false;
     end;

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

procedure Tfrmosmain.iSplitCruisesClick(Sender: TObject);
begin
  frmSplitCruises := TfrmSplitCruises.Create(Self);
   try
    if not frmSplitCruises.ShowModal = mrOk then exit;
   finally
     frmSplitCruises.Free;
     frmSplitCruises := nil;
   end;
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

procedure Tfrmosmain.btnOpenDBClick(Sender: TObject);
begin

if frmopendb_open=false then
   frmopendb:= Tfrmopendb.Create(Self) else
   frmopendb.SetFocus;

frmopendb_open:=true;
end;

procedure Tfrmosmain.OpenRegisteredDatabase(DBAlias: string);
Var
 DBIni:TIniFile;
 DBUser, DBPass, DBHost, DBPath: string;
 k:integer;
begin

  DBIni := TIniFile.Create(IniFileName+'_db');
  try
    DBUser :=DBIni.ReadString(DBAlias, 'user',     'SYSDBA');
    DBPass :=DBIni.ReadString(DBAlias, 'pass',     'masterkey');
    DBHost :=DBIni.ReadString(DBAlias, 'host',     'localhost');
    DBPath :=DBIni.ReadString(DBAlias, 'dbpath',   '');
  finally
    DBIni.Free;
  end;

  // if database isn't specified
  if (trim(DBUser)='') or (trim(DBPass)='') or
     (trim(DBHost)='') or (trim(DBPath)='') then
      if MessageDlg('Please, provide all information connection',
                    mtwarning, [mbOk], 0)=mrOk then exit;

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
      Connected:=false;
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

    if frmopendbreg_open=true then frmopendb_reg.Close;
    if frmopendb_open=true then frmopendb.Close;

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


procedure Tfrmosmain.iInterpolatedProfileClick(Sender: TObject);
begin
  if frmprofile_interpolation_open=true then frmprofile_interpolation.SetFocus else
     begin
       frmprofile_interpolation := Tfrmprofile_interpolation.Create(Self);
       frmprofile_interpolation.Show;
     end;
  frmprofile_interpolation_open:=true;
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


procedure Tfrmosmain.iInsertBottomDepthGEBCOClick(Sender: TObject);
var
  ID, k, cnt_null,cnt_updated, cnt:int64;
  IniFileName: string;
  Lat, Lon: real;

  Ini:TIniFile;

  GebcoFileName: string;
  ncid, varidp, Pct:integer;
  start: PArraySize_t;
  sp:array of smallint;
  lat0, lon0, step: real;
  GEBCO:variant;

  nc_open:Tnc_open;
  nc_inq_varid:Tnc_inq_varid;
  nc_get_var1_short:Tnc_get_var1_short;
  nc_close:Tnc_close;

  TRt:TSQLTransaction;
  Qt, Qt1:TSQLQuery;
begin

   lat0:=-(89+(59/60)+(525E-1/3600));  // first latitude
   lon0:=-(179+(59/60)+(525E-1/3600)); // first longitude
   step  := 1/240;  // 15"

   Ini := TIniFile.Create(IniFileName);
    try
      GebcoFileName:=Ini.ReadString('main', 'GEBCOPath', '');
    finally
      Ini.Free;
    end;

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
      SQL.Add(' SELECT ID, LATITUDE, LONGITUDE ');
      SQL.Add(' FROM STATION ');
      SQL.Add(' WHERE BOTTOMDEPTH_GEBCO IS NULL ');
      SQL.Add(' ORDER BY ID ');
     Open;
     Last;
       cnt:=Qt.RecordCount;
     First;
    end;

    if MessageDlg(inttostr(cnt)+' stations will be updated. Proceed?',
      mtWarning, [mbYes, mbNo], 0)= mrNo then Exit;

   // opening GEBCO_2021.nc
   nc_open:=Tnc_open(GetProcedureAddress(netcdf, 'nc_open'));
   nc_inq_varid:= Tnc_inq_varid(GetProcedureAddress(netcdf, 'nc_inq_varid'));
   nc_get_var1_short:=Tnc_get_var1_short(GetProcedureAddress(netcdf, 'nc_get_var1_short'));
   nc_close:=Tnc_close(GetProcedureAddress(netcdf, 'nc_close'));

   nc_open(pansichar(GebcoFileName), 0, ncid);
   nc_inq_varid (ncid, pChar('elevation'), varidp);
   start:=GetMemory(SizeOf(TArraySize_t)*2);

    k:=0;
    While not Qt.Eof do begin
     inc(k);
      ID:=Qt.FieldByName('ID').Value;
      Lat:=Qt.FieldByName('LATITUDE').Value;
      Lon:=Qt.FieldByName('LONGITUDE').Value;

     start^[0]:=abs(trunc((lat0-lat)/step)); // lat index
     start^[1]:=abs(trunc((lon0-lon)/step)); // lon index

     SetLength(sp, 1); // setting an empty array
     nc_get_var1_short(ncid, varidp, start^, sp);  // sending request to the file

     if not VarIsNull(sp[0]) then
       GEBCO:=-sp[0] else begin
         GEBCO:=null;
         inc(cnt_null);
       end;

     if (GEBCO<>null) then begin
       inc(cnt_updated);
    //   writeln(dat, inttostr(id)+'   '+floattostr(lat)+'   '+floattostr(lon)+'   '+vartostr(gebco){+'   '+vartostr(dep)});

       With Qt1 do begin
        Close;
         SQL.Clear;
         SQL.Add(' Update STATION set ');
         SQL.Add(' BOTTOMDEPTH_GEBCO=:GEB ');
         SQL.Add(' where ID=:pAbsNum ');
         Parambyname('pAbsnum').Value:=ID;
         Parambyname('GEB').Value:=GEBCO;
        ExecSQL;
       end;
    end;

      {$IFDEF WINDOWS}
       Procedures.ProgressTaskbar(k, cnt);
      {$ENDIF}

      if (k mod 1000=0) then TRt.CommitRetaining;

     Qt.Next;
    end;
    finally
     {$IFDEF WINDOWS}
       Procedures.ProgressTaskbar(0, 0);
     {$ENDIF}

      sp:=nil;
      FreeMemory(start);
      nc_close(ncid);  // Close nc file

     Trt.Commit;
     Qt.Free;
     Qt1.Free;
     Trt.Free;
    end;
end;

procedure Tfrmosmain.iInsertLastLevelClick(Sender: TObject);
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
    SQL.Add(' WHERE ');
    SQL.Add(' (LASTLEVEL_M IS NULL OR LASTLEVEL_DBAR IS NULL) AND ');
    SQL.Add(' (EMPTY=FALSE) ');
    SQL.Add(' ORDER BY ID ');
   Open;
   Last;
     cnt:=Qt.RecordCount;
   First;
  end;

  if MessageDlg(inttostr(cnt)+' stations will be updated. Proceed?',
    mtWarning, [mbYes, mbNo], 0)= mrNo then Exit;

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

    if (k mod 1000=0) then TRt.CommitRetaining;

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

procedure Tfrmosmain.iUpdateStationParametersClick(Sender: TObject);
begin
  frmQCUpdateStationParameters := TfrmQCUpdateStationParameters.Create(Self);
   try
    if not frmQCUpdateStationParameters.ShowModal = mrOk then exit;
   finally
     frmQCUpdateStationParameters.Free;
     frmQCUpdateStationParameters := nil;
   end;
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
//  showmessage('here');

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
        SQL.Add(' min(CRUISE_ID) as CrIDMin, max(CRUISE_ID) as CrIDMax, ');
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
     // showmessage(inttostr(stationCount));
       if StationCount>0 then begin
         StationIDMin   :=FieldByName('IDMin').AsInteger;
         StationIDMax   :=FieldByName('IDMax').AsInteger;
         CruiseIDMin    :=FieldByName('CrIDMin').AsInteger;
         CruiseIDMax    :=FieldByName('CrIDMax').AsInteger;
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
         if (seStationIDMin.Value=0) and (seStationIDMax.Value=0) then begin
           seStationIDMin.Value:=StationIDMin;
           seStationIDMax.Value:=StationIDMax;
           seCruiseIDMin.Value:=CruiseIDMin;
           seCruiseIDMax.Value:=CruiseIDMax;

           seLatMin.Value:=StationLatMin;
           seLatMax.Value:=StationLatMax;
           seLonMin.Value:=StationLonMin;
           seLonMax.Value:=StationLonMax;

         //if new database
         if (StationIDMin<seStationIDMin.Value) or (StationIDMax>seStationIDMax.Value) then begin
           seStationIDMin.Value:=StationIDMin;
           seStationIDMax.Value:=StationIDMax;
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

   with Qt_DB1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' select count(ID) as StCount, ');
       SQL.Add(' max(STATIONS_TOTAL) as ST_TOTAL_MAX, ');
       SQL.Add(' max(STATIONS_DATABASE) as ST_DATABASE_MAX, ');
       SQL.Add(' max(STATIONS_DUPLICATES) as ST_DUPLICATES_MAX ');
       SQL.Add(' FROM CRUISE');
     Open;
     if FieldByName('StCount').AsInteger>0 then begin
       CruiseStationsTotalMax:=FieldByName('ST_TOTAL_MAX').AsInteger;
       CruiseStationsDatabaseMax:=FieldByName('ST_DATABASE_MAX').AsInteger;
       CruiseStationsDuplicateMax:=FieldByName('ST_DUPLICATES_MAX').AsInteger;

       seCruiseStationsTotalMax.Value:=CruiseStationsTotalMax;
       seCruiseStationsDatabaseMax.Value:=CruiseStationsDatabaseMax;
       seCruiseStationsDuplicateMax.Value:=CruiseStationsDuplicateMax;
     end;
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

   pParameters.Visible:=false;
   cgParameters.Items.Clear;
   cgParameters.Items:=ListBox1.Items;
   pParameters.Visible:=chkParameter.Checked;

   (* cleaning selection info *)
   for k:=1 to 7 do sbSelection.Panels[k].Text:='---';

   (* getting QC flags from the database and storing them in lists *)
   PopulateQCFlagLists;

   (* getting list of all instruments *)
   PopulateInstrumentList;

   cbSource.Clear;
   cbCountry.Clear;
   cbPlatform.Clear;
   cbCruise.Clear;
   cbInstitute.Clear;
   cbProject.Clear;

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
  (* Fetch ENTRY_TYPE *)
  if (PageControl1.PageIndex=1) and (cbEntryType.Items.Count=0) then begin

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


procedure Tfrmosmain.rbCruisesChange(Sender: TObject);
begin

  chkStationIDRange.Enabled:=false;
  chkStationIDRange.Checked:=false;

  chkStationIDList.Enabled:=false;
  chkStationIDList.Checked:=false;

  chkParameter.Enabled:=false;
  chkParameter.Checked:=false;

  chkDepth.Enabled:=false;
  chkDepth.Checked:=false;;

  chkCrNumStat.Enabled:=true;

  chkParameter.OnChange(self);
  chkDepth.OnChange(self);
  chkCrNumStat.OnChange(self);

  pcRegion.Pages[1].TabVisible:=false;
  pcRegion.Pages[2].TabVisible:=false;

  chkPeriod.Visible:=false;
  //chNoEmptyCruises.Enabled:=true;
end;

procedure Tfrmosmain.rbStationsChange(Sender: TObject);
begin
  chkStationIDRange.Enabled:=true;
  chkStationIDList.Enabled:=true;
  chkParameter.Enabled:=true;
  chkDepth.Enabled:=true;

  chkCrNumStat.Checked:=false;
  chkCrNumStat.Enabled:=false;

  chkParameter.OnChange(self);
  chkDepth.OnChange(self);
  chkCrNumStat.OnChange(self);

  pcRegion.Pages[1].TabVisible:=true;
  pcRegion.Pages[2].TabVisible:=true;

  chkPeriod.Visible:=true;
  //chNoEmptyCruises.Enabled:=false;
end;


(* gathering info about selected stations *)
procedure Tfrmosmain.SelectionInfo(UpdateCruises:boolean);
var
  ID, crID: int64;
  k: integer;
  lat1, lon1:real;
  dat1:TDateTime;
  items_enabled:boolean;
  yy, mn, dd:word;
  temp_list: TStringList;
  tblpar:string;
begin

  SCount:=0;
  items_enabled:=false;

 if frmdm.Q.Active then begin
 try
  frmdm.Q.DisableControls;

  SLatMin:=90;  SLatMax:=-90;
  SLonMin:=180; SLonMax:=-180;
  SDateMin:=Now;
  yy:=1900; mn:=1; dd:=1;
  SDateMax:=EncodeDate(yy, mn, dd);

  (* temporal list of unique Cruise IDs *)
  temp_list:=TStringList.Create;
  temp_list.Sorted:=true;
  temp_list.Duplicates:=dupIgnore;


  SetLength(MapDataset, StationCount);
  frmdm.Q.First;
  k:=-1;
  while not frmdm.Q.EOF do begin
   inc(k);
   ID  :=frmdm.Q.FieldByName('ID').Value;
   crID:=frmdm.Q.FieldByName('CRUISE_ID').Value;
   lat1:=frmdm.Q.FieldByName('LATITUDE').AsFloat;
   lon1:=frmdm.Q.FieldByName('LONGITUDE').AsFloat;
   dat1:=frmdm.Q.FieldByName('DATEANDTIME').AsDateTime;

     if lat1<SLatMin then SLatMin:=lat1;
     if lat1>SLatMax then SLatMax:=lat1;
     if lon1<SLonMin then SLonMin:=lon1;
     if lon1>SLonMax then SLonMax:=lon1;
     if CompareDate(dat1, SDateMin)<0 then SDateMin:=dat1;
     if CompareDate(dat1, SDateMax)>0 then SDateMax:=dat1;

     MapDataset[k].ID:=ID;
     MapDataset[k].Cruise_ID:=crID;
     MapDataset[k].Latitude :=lat1;
     MapDataset[k].Longitude:=lon1;

     temp_list.Add(IntToStr(CrID));

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

       // getting cruises based on the list of CRUISE_ID
       if UpdateCruises=true then
          SelectGetCruisesFromStation(temp_list);

       items_enabled:=true;
     end;

  finally
    temp_list.Free;
    frmdm.Q.EnableControls;
  end;
 end;

 if SCount=0 then
   for k:=1 to 7 do sbSelection.Panels[k].Text:='---';

  iDBStatistics.Enabled:=items_enabled;
  aMapAllStations.Enabled:=items_enabled;
  aMapKML.Enabled:=items_enabled;
  aProfilesStationSingle.Enabled:=items_enabled;
  aProfilesStationAll.Enabled:=items_enabled;
  aProfilesSelectedAllPlot.Enabled:=items_enabled;
  iStandarddeviationslayers.Enabled:=items_enabled;
  iTDdiagrams.Enabled:=items_enabled;
  iMetadataUpdate.Enabled:=items_enabled;


  tsSelectedStations.TabVisible:=items_enabled;
  if tsSelectedStations.TabVisible=true then begin
    PageControl1.ActivePageIndex:=2;
    tsSelectedStations.Caption:='Cruises: '+inttostr(frmdm.QCruise.RecordCount)+'; '+
                                'Stations: '+inttostr(frmdm.Q.RecordCount);
  end;

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



procedure Tfrmosmain.cbSourceDropDown(Sender: TObject);
Var
  k: integer;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
  country_str, platform_str, NotCondCountry, NotCondPlatform: string;
begin

  if cbSource.Count>0 then exit;

try
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt:=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

  if chkNOTCountry.Checked =true then NotCondCountry :='NOT' else NotCondCountry :='';
  if chkNOTPlatform.Checked=true then NotCondPlatform:='NOT' else NotCondPlatform:='';

  country_str:='';
  if cbCountry.Text<>'' then begin
    for k:=0 to cbCountry.Count-1 do
      if cbCountry.Checked[k] then
        country_str:=','+QuotedStr(cbCountry.Items.Strings[k]);
    country_str:=copy(country_str, 2, length(country_str));
  end;

  platform_str:='';
  if cbPlatform.Text<>''  then begin
    for k:=0 to cbPlatform.Count-1 do
      if cbPlatform.Checked[k] then
        platform_str:=','+QuotedStr(cbPlatform.Items.Strings[k]);
    platform_str:=copy(platform_str, 2, length(platform_str));
  end;

  if (cbCountry.Text='') and (cbPlatform.Text='') then begin
    With Qt do begin
      Close;
         SQL.Clear;
         SQL.Add(' SELECT DISTINCT SOURCE.NAME FROM SOURCE ');
         SQL.Add(' RIGHT JOIN CRUISE ON ');
         SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID ');
         SQL.Add(' ORDER BY SOURCE.NAME ');
       Open;
    end;
  end;


  if (cbCountry.Text<>'') and (cbPlatform.Text='') then begin
   With Qt do begin
      Close;
         SQL.Clear;
         SQL.Add(' SELECT DISTINCT SOURCE.NAME FROM ');
         SQL.Add(' COUNTRY, PLATFORM, CRUISE, SOURCE WHERE ');
         SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
         SQL.Add(' COUNTRY.ID=PLATFORM.COUNTRY_ID AND ');
         SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
         SQL.Add(' COUNTRY.NAME '+NotCondCountry+' IN ('+country_str+')');
         SQL.Add(' ORDER BY SOURCE.NAME ');
      Open;
    end;
  end;

  if (cbCountry.Text='') and (cbPlatform.Text<>'') then begin
    With Qt do begin
      Close;
         SQL.Clear;
         SQL.Add(' SELECT DISTINCT SOURCE.NAME FROM ');
         SQL.Add(' PLATFORM, CRUISE, SOURCE WHERE ');
         SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
         SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
         SQL.Add(' PLATFORM.NAME '+NotCondPlatform+' IN ('+platform_str+')');
         SQL.Add(' ORDER BY SOURCE.NAME ');
       Open;
    end;
  end;

  if (cbCountry.Text<>'') and (cbPlatform.Text<>'') then begin
    With Qt do begin
      Close;
         SQL.Clear;
         SQL.Add(' SELECT DISTINCT SOURCE.NAME FROM ');
         SQL.Add(' COUNTRY, PLATFORM, CRUISE, SOURCE WHERE ');
         SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
         SQL.Add(' COUNTRY.ID=PLATFORM.COUNTRY_ID AND ');
         SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
         SQL.Add(' COUNTRY.NAME '+NotCondCountry+' IN ('+country_str+') AND ');
         SQL.Add(' PLATFORM.NAME '+NotCondPlatform+' IN ('+platform_str+')');
         SQL.Add(' ORDER BY SOURCE.NAME ');
      Open;
    end;
  end;

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
end;


procedure Tfrmosmain.cbCountryDropDown(Sender: TObject);
Var
  k:integer;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
  source_str, platform_str, QC_str, NotCondPlatform, NotCondSource: string;
begin

  if cbCountry.Count>0 then exit;

  try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   if chkQCFlag.checked=true then begin
    qc_str:='';
     for k:=0 to cgQCFlag.Items.Count-1 do
      if cgQCFlag.Checked[k] then
       qc_str:=qc_str+','+cgQCFlag.Items.Strings[k];
    qc_str:=copy(qc_str, 1, length(qc_str)-1);
   end;

   source_str:='';
   if cbSource.Text<>'' then begin
    for k:=0 to cbSource.Count-1 do
    if cbSource.Checked[k] then
      source_str:=source_str+','+QuotedStr(cbSource.Items.Strings[k]);
    source_str:=copy(source_str, 2, length(source_str));
   end;

   if cbPlatform.Text<>'' then begin
    platform_str:='';
     for k:=0 to cbPlatform.Count-1 do
     if cbPlatform.Checked[k] then
       platform_str:=platform_str+','+QuotedStr(cbPlatform.Items.Strings[k]);
     platform_str:=copy(platform_str, 2, length(platform_str));
   end;

   if chkNOTSource.Checked=true then NotCondSource:='NOT' else NotCondSource:='';
   if chkNOTPlatform.Checked=true then NotCondPlatform:='NOT' else NotCondPlatform:='';

   if (cbSource.Text='') and (cbPlatform.Text='') then begin
    With Qt do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT COUNTRY.NAME FROM ');
       SQL.Add(' COUNTRY, CRUISE, STATION, PLATFORM ');
       SQL.Add(' WHERE ');
       SQL.Add(' (PLATFORM.COUNTRY_ID=COUNTRY.ID) ');
       SQL.Add(' AND (CRUISE.PLATFORM_ID=PLATFORM.ID) ');
       SQL.Add(' AND (STATION.CRUISE_ID=CRUISE.ID) ');
       if chkQCFlag.Checked=true then
         SQL.Add(' AND (STATION.QCFLAG  IN ('+qc_str+')) ');
       if chkIgnoreDup.Checked=true then
         SQL.Add(' AND (CRUISE.DUPLICATE = FALSE) ');
       SQL.Add(' AND (CRUISE.STATIONS_DATABASE>0) ');
       SQL.Add(' ORDER BY COUNTRY.NAME ');
     Open;
    end;
   end;

   if (cbSource.Text<>'') and (cbPlatform.Text='') then begin
    With Qt do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT COUNTRY.NAME FROM ');
       SQL.Add(' COUNTRY, PLATFORM, CRUISE, SOURCE, STATION WHERE ');
       SQL.Add(' (CRUISE.PLATFORM_ID=PLATFORM.ID) AND ');
       SQL.Add(' (COUNTRY.ID=PLATFORM.COUNTRY_ID) AND ');
       SQL.Add(' (CRUISE.SOURCE_ID=SOURCE.ID) AND ');
       SQL.Add(' (STATION.CRUISE_ID=CRUISE.ID) AND ');
       SQL.Add(' (SOURCE.NAME '+NotCondSource+' IN ('+source_str+')) ');

       if chkQCFlag.Checked=true then
         SQL.Add(' AND (STATION.QCFLAG  IN ('+qc_str+')) ');
       if chkIgnoreDup.Checked=true then
         SQL.Add(' AND (CRUISE.DUPLICATE = FALSE) ');
       SQL.Add(' AND (CRUISE.STATIONS_DATABASE>0) ');

       SQL.Add(' ORDER BY COUNTRY.NAME ');
     Open;
    end;
   end;

   if (cbSource.Text='') and (cbPlatform.Text<>'') then begin
     With Qt do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT COUNTRY.NAME FROM ');
       SQL.Add(' COUNTRY, PLATFORM, CRUISE, SOURCE, STATION WHERE ');
       SQL.Add(' (CRUISE.PLATFORM_ID=PLATFORM.ID) AND ');
       SQL.Add(' (COUNTRY.ID=PLATFORM.COUNTRY_ID) AND ');
       SQL.Add(' (CRUISE.SOURCE_ID=SOURCE.ID) AND ');
       SQL.Add(' (STATION.CRUISE_ID=CRUISE.ID) AND ');
       SQL.Add(' (PLATFORM.NAME '+NotCondPlatform+' IN ('+platform_str+')) ');

       if chkQCFlag.Checked=true then
         SQL.Add(' AND (STATION.QCFLAG  IN ('+qc_str+')) ');
       if chkIgnoreDup.Checked=true then
         SQL.Add(' AND (CRUISE.DUPLICATE = FALSE) ');
       SQL.Add(' AND (CRUISE.STATIONS_DATABASE>0) ');

       SQL.Add(' ORDER BY COUNTRY.NAME ');
      Open;
     end;
   end;

   if (cbSource.Text<>'') and (cbPlatform.Text<>'') then begin
    With Qt do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT COUNTRY.NAME FROM ');
       SQL.Add(' COUNTRY, PLATFORM, CRUISE, SOURCE, STATION WHERE ');
       SQL.Add(' (CRUISE.PLATFORM_ID=PLATFORM.ID) AND ');
       SQL.Add(' (COUNTRY.ID=PLATFORM.COUNTRY_ID) AND ');
       SQL.Add(' (CRUISE.SOURCE_ID=SOURCE.ID) AND ');
       SQL.Add(' (STATION.CRUISE_ID=CRUISE.ID) AND ');
       SQL.Add(' (SOURCE.NAME '+NotCondSource+' IN ('+source_str+')) AND ');
       SQL.Add(' (PLATFORM.NAME '+NotCondPlatform+' IN ('+platform_str+')) ');

       if chkQCFlag.Checked=true then
         SQL.Add(' AND (STATION.QCFLAG  IN ('+qc_str+')) ');
       if chkIgnoreDup.Checked=true then
         SQL.Add(' AND (CRUISE.DUPLICATE = FALSE) ');
       SQL.Add(' AND (CRUISE.STATIONS_DATABASE>0) ');

       SQL.Add(' ORDER BY COUNTRY.NAME ');
      // showmessage(sql.Text);
     Open;
    end;
   end;

   while not Qt.Eof do begin
     cbCountry.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
    Qt.Next;
   end;

   Qt.Close;
   TRt.Commit;
  finally
   Qt.Free;
   TrT.Free;
  end;
end;



procedure Tfrmosmain.cbPlatformDropDown(Sender: TObject);
Var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
  pp, k: integer;
  country_str, source_str, qc_str, NotCondSource, NotCondCountry:string;
begin

 if cbPlatform.Count>0 then exit;

  try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   if chkNOTSource.Checked=true then NotCondSource:='NOT' else NotCondSource:='';
   if chkNOTCountry.Checked=true then NotCondCountry:='NOT' else NotCondCountry:='';

   qc_str:='';
   if chkQCFlag.checked=true then begin
     for k:=0 to cgQCFlag.Items.Count-1 do
      if cgQCFlag.Checked[k] then
       qc_str:=','+cgQCFlag.Items.Strings[k];
    qc_str:=copy(qc_str, 2, length(qc_str));
   end;

   source_str:='';
   if cbSource.Text<>'' then begin
     for k:=0 to cbSource.Count-1 do
       if cbSource.Checked[k] then
         source_str:=source_str+','+QuotedStr(cbSource.Items.Strings[k]);
     source_str:=copy(source_str, 2, length(source_str));
   end;

   country_str:='';
   if cbCountry.Text<>'' then begin
     for k:=0 to cbCountry.Count-1 do
      if cbCountry.Checked[k] then
       country_str:=country_str+','+QuotedStr(cbCountry.Items.Strings[k]);
     country_str:=copy(country_str, 2, length(country_str));
   end;

   if (cbSource.Text='') and (cbCountry.Text='') then begin
    With Qt do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT PLATFORM.NAME FROM ');
       SQL.Add(' PLATFORM, CRUISE, STATION WHERE ');
       SQL.Add(' (CRUISE.PLATFORM_ID=PLATFORM.ID) ');
       SQL.Add(' AND (STATION.CRUISE_ID=CRUISE.ID) ');

       if chkQCFlag.Checked=true then
         SQL.Add(' AND (STATION.QCFLAG  IN ('+qc_str+')) ');
       if chkIgnoreDup.Checked=true then
         SQL.Add(' AND (CRUISE.DUPLICATE = FALSE) ');
       SQL.Add(' AND (CRUISE.STATIONS_DATABASE>0) ');

       SQL.Add(' ORDER BY PLATFORM.NAME ');
     Open;
    end;
   end;

   if (cbSource.Text<>'') and (cbCountry.Text='') then begin
    With Qt do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT PLATFORM.NAME FROM ');
       SQL.Add(' PLATFORM, CRUISE, SOURCE, STATION WHERE ');
       SQL.Add(' (CRUISE.PLATFORM_ID=PLATFORM.ID) AND ');
       SQL.Add(' (CRUISE.SOURCE_ID=SOURCE.ID) AND ');
       SQL.Add(' (STATION.CRUISE_ID=CRUISE.ID) AND ');
       SQL.Add(' (SOURCE.NAME '+NotCondSource+' IN ('+source_str+')) ');

       if chkQCFlag.Checked=true then
         SQL.Add(' AND (STATION.QCFLAG  IN ('+qc_str+')) ');
       if chkIgnoreDup.Checked=true then
         SQL.Add(' AND (CRUISE.DUPLICATE = FALSE) ');
       SQL.Add(' AND (CRUISE.STATIONS_DATABASE>0) ');

       SQL.Add(' ORDER BY PLATFORM.NAME ');
      // showmessage(sql.text);
     Open;
    end;
   end;

   if (cbSource.Text='') and (cbCountry.Text<>'') then begin
    With Qt do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT PLATFORM.NAME FROM PLATFORM ');
       SQL.Add(' PLATFORM, CRUISE, SOURCE, COUNTRY, STATION WHERE ');
       SQL.Add(' (CRUISE.PLATFORM_ID=PLATFORM.ID) AND ');
       SQL.Add(' (CRUISE.SOURCE_ID=SOURCE.ID) AND ');
       SQL.Add(' (PLATFORM.COUNTRY_ID=COUNTRY.ID) AND ');
       SQL.Add(' (STATION.CRUISE_ID=CRUISE.ID) AND ');
       SQL.Add(' (COUNTRY.NAME '+NotCondCountry+' IN ('+country_str+')) ');

       if chkQCFlag.Checked=true then
         SQL.Add(' AND (STATION.QCFLAG  IN ('+qc_str+')) ');
       if chkIgnoreDup.Checked=true then
         SQL.Add(' AND (CRUISE.DUPLICATE = FALSE) ');
       SQL.Add(' AND (CRUISE.STATIONS_DATABASE>0) ');

       SQL.Add(' ORDER BY PLATFORM.NAME ');
     Open;
    end;
   end;

   if (cbSource.Text<>'') and (cbCountry.Text<>'') then begin
    With Qt do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT PLATFORM.NAME FROM PLATFORM ');
       SQL.Add(' PLATFORM, CRUISE, SOURCE, COUNTRY, STATION WHERE ');
       SQL.Add(' (CRUISE.PLATFORM_ID=PLATFORM.ID) AND ');
       SQL.Add(' (CRUISE.SOURCE_ID=SOURCE.ID) AND ');
       SQL.Add(' (PLATFORM.COUNTRY_ID=COUNTRY.ID) AND ');
       SQL.Add(' (STATION.CRUISE_ID=CRUISE.ID) AND ');
       SQL.Add(' (COUNTRY.NAME '+NotCondCountry+' IN ('+country_str+')) AND ');
       SQL.Add(' (SOURCE.NAME '+NotCondSource+' IN ('+source_str+')) ');

       if chkQCFlag.Checked=true then
         SQL.Add(' AND (STATION.QCFLAG  IN ('+qc_str+')) ');
       if chkIgnoreDup.Checked=true then
         SQL.Add(' AND (CRUISE.DUPLICATE = FALSE) ');
       SQL.Add(' AND (CRUISE.STATIONS_DATABASE>0) ');

       SQL.Add(' ORDER BY PLATFORM.NAME ');
     Open;
    end;
   end;

   while not Qt.Eof do begin
     cbPlatform.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
    Qt.Next;
   end;

   DBGridCruise.Columns[2].PickList:=cbPlatform.Items;

    Qt.Close;
    TRt.Commit;

    cbCruise.Clear;
    cbCruise.Enabled:=true;

  finally
   Qt.Free;
   TrT.Free;
  end;
end;


procedure Tfrmosmain.cbCruiseDropDown(Sender: TObject);
Var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
  pp, k, cr_id: integer;
  SQL_str, cr, cr_num, platform_str, qc_str, NotCondPlatform:string;
begin
  try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   if chkQCFlag.checked=true then begin
    qc_str:='';
     for k:=0 to cgQCFlag.Items.Count-1 do
      if cgQCFlag.Checked[k] then
       qc_str:=','+cgQCFlag.Items.Strings[k];
    qc_str:=copy(qc_str, 2, length(qc_str));
   end;


   platform_str:='';
   if cbPlatform.text<>'' then begin
     for k:=0 to cbPlatform.Count-1 do
     if cbPlatform.Checked[k] then
       platform_str:=platform_str+','+QuotedStr(cbPlatform.Items.Strings[k]);
     platform_str:=copy(platform_str, 2, length(platform_str));
   end;

   if chkNOTPlatform.Checked=true then NotCondPlatform:='NOT' else NotCondPlatform:='';

    With Qt do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT CRUISE.ID, CRUISE_NUMBER ');
       SQL.Add(' FROM CRUISE, STATION, PLATFORM ');
       SQL.Add(' WHERE ');
       SQL.ADD(' (STATION.CRUISE_ID=CRUISE.ID) AND ');
       SQL.Add(' (CRUISE.PLATFORM_ID=PLATFORM.ID) AND ');
       SQL.Add(' (PLATFORM.NAME '+NotCondPlatform+' IN ('+platform_str+')) ');

       if chkQCFlag.Checked=true then
         SQL.Add(' AND (STATION.QCFLAG  IN ('+qc_str+')) ');
       if chkIgnoreDup.Checked=true then
         SQL.Add(' AND (CRUISE.DUPLICATE = FALSE) ');
       SQL.Add(' AND (CRUISE.STATIONS_DATABASE>0) ');

       SQL.Add(' ORDER BY CRUISE_NUMBER ');
     //  showmessage(SQL.Text);
     Qt.Open;
    end;

    cbCruise.Clear;
   while not Qt.Eof do begin
     cr_id:=Qt.Fields[0].Value;
     cr_num:=Qt.Fields[1].AsString;
     if trim(cr_num)<>'' then
        cr:=inttostr(cr_id)+'_'+cr_num else
        cr:=inttostr(cr_id);
     cbCruise.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
    Qt.Next;
   end;

    Qt.Close;
    TRt.Commit;
  finally
   Qt.Free;
   TrT.Free;
  end;

end;



procedure Tfrmosmain.chkRegionChange(Sender: TObject);
begin
 // gbRegion.Enabled:=chkRegion.Checked;
  pRegion.Visible:=chkRegion.Checked;
end;

procedure Tfrmosmain.chkDateandTimeChange(Sender: TObject);
begin
 // gbDateandTime.Enabled:=chkDateandTime.Checked;
  pDateandTime.Visible:=chkDateandTime.Checked;
end;

procedure Tfrmosmain.chkStationIDRangeChange(Sender: TObject);
begin
 // gbIDRange.Enabled:=chkStationIDRange.Checked;
  seStationIDMin.Enabled:=chkStationIDRange.Checked;
  seStationIDMax.Enabled:=chkStationIDRange.Checked;

  if (chkStationIDRange.Checked) or
     (chkCruiseIDRange.Checked) then
     pIDRange.Visible:=true else pIDRange.Visible:=false;
end;

procedure Tfrmosmain.chkCruiseIDRangeChange(Sender: TObject);
begin
  seCruiseIDMin.Enabled:=chkCruiseIDRange.Checked;
  seCruiseIDMax.Enabled:=chkCruiseIDRange.Checked;

  if (chkStationIDRange.Checked) or
     (chkCruiseIDRange.Checked) then
     pIDRange.Visible:=true else pIDRange.Visible:=false;
end;

procedure Tfrmosmain.chkCruiseIDListChange(Sender: TObject);
begin
  pCruiseIDList.Visible:=chkCruiseIDList.Checked;
end;

procedure Tfrmosmain.chkStationIDListChange(Sender: TObject);
begin
  pStationIDList.Visible:=chkStationIDList.Checked;
end;


procedure Tfrmosmain.chkAuxMetadataChange(Sender: TObject);
begin
 //gbAuxiliaryMetadata.Enabled:=chkAuxMetadata.Checked;
  pAuxiliaryMetadata.Visible:=chkAuxMetadata.Checked;
end;

procedure Tfrmosmain.chkQCFlagChange(Sender: TObject);
begin
 // cgQCFlag.Enabled:=chkQCFlag.Checked;
  pQCFlag.Visible:=chkQCFlag.Checked;
end;

procedure Tfrmosmain.chkParameterChange(Sender: TObject);
begin
 // cgParameters.Enabled:=chkParameter.Checked;
  pParameters.Visible:=chkParameter.Checked;
end;

procedure Tfrmosmain.chkDepthChange(Sender: TObject);
begin
 //gbDepth.Enabled:=chkDepth.Checked;
 pDepth.Visible:=chkDepth.Checked;
end;

procedure Tfrmosmain.chkCrNumStatChange(Sender: TObject);
begin
  pCruiseNumStations.Visible:=chkCrNumStat.Checked;
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
  if ((key=VK_UP) or (key=VK_DOWN)) then begin
    if (not frmdm.QCruise.IsEmpty) and (not VarIsNull(frmdm.QCruise.FieldByName('ID').Value)) then begin
      if (not frmdm.Q.IsEmpty) and (not VarIsNull(frmdm.Q.FieldByName('ID').Value)) then begin
        if frmmap_open=true then frmmap.ChangeID(frmdm.Q.FieldByName('ID').Value); //Map
        if frmprofile_plot_all_open then frmprofile_plot_all.chkCruiseHighlight.OnChange(self);
      end;
    end;
  end;
end;


procedure Tfrmosmain.cbInstituteDropDown(Sender: TObject);
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

   //DBCruiseInstitute.Items.Clear;
 //  cbInstitute.Clear;

     With Qt do begin
       Close;
         SQL.Clear;
         SQL.Add(' SELECT DISTINCT NAME FROM INSTITUTE ');
         SQL.Add(' RIGHT JOIN CRUISE ON ');
         SQL.Add(' CRUISE.INSTITUTE_ID=INSTITUTE.ID ');
         SQL.Add(' ORDER BY NAME ');
       Open;
      end;

      while not Qt.Eof do begin
       // cbInstitute.Items.Add(Qt.Fields[0].AsString);
        cbInstitute.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
       Qt.Next;
      end;

  //  DBCruiseInstitute.Items:=cbInstitute.Items;

    Qt.Close;
    TRt.Commit;
  finally
   Qt.Free;
   TrT.Free;
  end;
end;


procedure Tfrmosmain.cbProjectDropDown(Sender: TObject);
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

   //DBCruiseProject.Items.Clear;
   //cbProject.Clear;

   With Qt do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT NAME FROM PROJECT, CRUISE ');
       SQL.Add(' WHERE CRUISE.PROJECT_ID=PROJECT.ID ');
       SQL.Add(' ORDER BY NAME ');
     Open;
    end;

      while not Qt.Eof do begin
       // cbProject.Items.Add(Qt.Fields[0].AsString);
        cbProject.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
       Qt.Next;
      end;

  // DBCruiseProject.Items:=cbProject.Items;

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
if frmdm.Q.Active then begin
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
     if frmparameters_list_open then begin
      if (Pos('[',frmparameters_list.lbParameters.Items.Strings[0])>0) then
           frmparameters_list.btnAmountOfProfiles.OnClick(self);
     end;
  NavigationOrder:=true; //Завершили, открываем доступ к навигации
 end;
end;

if not frmdm.Q.Active then begin
 if frmmap_open=true then frmmap.Close;
 if frmprofile_station_all_open=true then frmprofile_station_all.Close; //
 if frmprofile_station_single_open =true then frmprofile_station_single.Close;
 if frmprofile_plot_all_open=true then frmprofile_plot_all.Close;
 if frmmeteo_open=true then frmmeteo.Close;
 if frmparameters_list_open then frmparameters_list.Close;
end;

end;

procedure Tfrmosmain.iNewDatabaseClick(Sender: TObject);
begin
  frmcreatenewdb := Tfrmcreatenewdb.Create(Self);
  try
    if not frmcreatenewdb.ShowModal = mrOk then exit;
  finally
    frmcreatenewdb.Free;
    frmcreatenewdb := nil;
  end;
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
      DateMin:=now;
      DateMax:=now;
      DateUpd:=now;
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
    SQL.Add(' STATIONS_DATABASE=:cnt ');

    if TotalEqualDB=true then begin
      SQL.Add(',');
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

procedure Tfrmosmain.iLoadICESnewClick(Sender: TObject);
begin
  frmload_ices2 := Tfrmload_ices2.Create(Self);
  try
   if not frmload_ices2.ShowModal = mrOk then exit;
  finally
    frmload_ices2.Free;
    frmload_ices2 := nil;
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

procedure Tfrmosmain.iLoad_GLODAP_v2_2021Click(Sender: TObject);
begin
  frmloadGLODAP_v2_2021_product := TfrmloadGLODAP_v2_2021_product.Create(Self);
 try
  if not frmloadGLODAP_v2_2021_product.ShowModal = mrOk then exit;
 finally
   frmloadGLODAP_v2_2021_product.Free;
   frmloadGLODAP_v2_2021_product := nil;
 end;
end;

procedure Tfrmosmain.iload_icesClick(Sender: TObject);
begin
 frmload_ices1 := Tfrmload_ices1.Create(Self);
 try
  if not frmload_ices1.ShowModal = mrOk then exit;
 finally
   frmload_ices1.Free;
   frmload_ices1 := nil;
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

procedure Tfrmosmain.iMetadataUpdateClick(Sender: TObject);
begin
  frmqc_metadata_update := Tfrmqc_metadata_update.Create(Self);
    try
     if not frmqc_metadata_update.ShowModal = mrOk then exit;
    finally
      frmqc_metadata_update.Free;
      frmqc_metadata_update:= nil;
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

procedure Tfrmosmain.iQCClick(Sender: TObject);
begin
  iUpdateStationParameters.Enabled:=FileExists(OceanToolsPath+'UpdateStationParameters.exe');
  iInsertBottomDepthGEBCO.Enabled :=FileExists(OceanToolsPath+'UpdateGEBCO.exe');
  iInsertLastLevel.Enabled        :=FileExists(OceanToolsPath+'UpdateLastLevel.exe');
end;

procedure Tfrmosmain.iBackupQCClick(Sender: TObject);
begin
  SD.Filter:='Text files|*.TXT;*.txt';
    if SD.Execute then begin
     osqc_setflags.BackupQCFlags(SD.FileName);
      If MessageDlg('QC flags have been backed up', mtInformation, [mbOk], 0)=mrOk then exit;
    end;
end;

procedure Tfrmosmain.iRestoreQCClick(Sender: TObject);
begin
  OD.Filter:='Text files|*.TXT;*.txt';
    if OD.Execute then begin
     osqc_setflags.RestoreQCFlags(OD.FileName);
      If MessageDlg('QC flags have been restored', mtInformation, [mbOk], 0)=mrOk then exit;
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
{  frmQC_WideRanges := TfrmQC_WideRanges.Create(Self);
   try
    if not frmQC_WideRanges.ShowModal = mrOk then exit;
   finally
     frmQC_WideRanges.Free;
     frmQC_WideRanges:= nil;
   end;}

   frmwideranges_upd := Tfrmwideranges_upd.Create(Self);
   try
    if not frmwideranges_upd.ShowModal = mrOk then exit;
   finally
     frmwideranges_upd.Free;
     frmwideranges_upd:= nil;
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

procedure Tfrmosmain.iFixedStationClick(Sender: TObject);
begin
  frmFixedStation := TfrmFixedStation.Create(Self);
   try
    if not frmFixedStation.ShowModal = mrOk then exit;
   finally
     frmFixedStation.Free;
     frmFixedStation := nil;
   end;
end;


procedure Tfrmosmain.iImportFirebirdClick(Sender: TObject);
begin
  frmimportdb := Tfrmimportdb.Create(Self);
   try
    if not frmimportdb.ShowModal = mrOk then exit;
   finally
     frmimportdb.Free;
     frmimportdb:= nil;
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
 // if (Column.Index=2) and (cbPlatform.Count=0) then PopulatePlatformList;
 // if (Column.Index=4) and (cbSource.Count=0)   then PopulateSourceList;

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
       DBGridCruise.Enabled:=false;
       Application.ProcessMessages;

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
       DBGridCruise.Enabled:=true;
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
procedure Tfrmosmain.SaveSettingsSearch;
Var
  Ini:TIniFile;
  k:integer;
  str: string;
begin
  Ini := TIniFile.Create(IniFileName);
  try

   (* mode *)
    Ini.WriteBool    ( 'osmain', 'station_cruises',             rbCruises.Checked);
    Ini.WriteBool    ( 'osmain', 'station_stations',            rbStations.Checked);


    (* Main checkboxes *)
    Ini.WriteBool    ( 'osmain', 'station_chkRegion',           chkRegion.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkIDRange',          chkStationIDRange.Checked);
    Ini.WriteBool    ( 'osmain', 'cruise_chkIDRange',           chkCruiseIDRange.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkIDList',           chkStationIDList.Checked);
    Ini.WriteBool    ( 'osmain', 'cruise_chkIDList',            chkCruiseIDList.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkAuxMetadata',      chkAuxMetadata.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkVariables',        chkParameter.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkQCFlag',           chkQCFlag.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkDateandTime',      chkDateandTime.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkDepth',            chkDepth.Checked);
    Ini.WriteBool    ( 'osmain', 'cruise_chkNumStations',       chkCrNumStat.Checked);

    (* Auxiliary checkboxes *)
    Ini.WriteBool    ( 'osmain', 'station_chkIgnoreDup',        chkIgnoreDup.Checked);
    Ini.WriteBool    ( 'osmain', 'station_chkShowQuery',        chkShowQuery.Checked);

    // Region
    Ini.WriteInteger ( 'osmain', 'station_region_pcRegion', pcRegion.ActivePageIndex);
    Ini.WriteFloat   ( 'osmain', 'station_latmin',   seLatMin.Value);
    Ini.WriteFloat   ( 'osmain', 'station_latmax',   seLatMax.Value);
    Ini.WriteFloat   ( 'osmain', 'station_lonmin',   seLonMin.Value);
    Ini.WriteFloat   ( 'osmain', 'station_lonmax',   seLonMax.Value);
    Ini.WriteFloat   ( 'osmain', 'station_around_point_lat',    seAroundPointLat.Value);
    Ini.WriteFloat   ( 'osmain', 'station_around_point_lon',    seAroundPointLon.Value);
    Ini.WriteInteger ( 'osmain', 'station_around_point_radius', seAroundPointRaduis.Value);

    // Date and Time
    Ini.WriteInteger ( 'osmain', 'station_region_pcDateandTime', pcDateandTime.ActivePageIndex);
    Ini.WriteBool    ( 'osmain', 'station_period',   chkPeriod.Checked);
    Ini.WriteDateTime( 'osmain', 'station_datemin',  dtpDateMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_datemax',  dtpDateMax.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateaddedmin',   dtpDateAddedMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateaddedmax',   dtpDateAddedMax.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateupdatedmin', dtpDateUpdatedMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateupdatedmax', dtpDateUpdatedMax.DateTime);

    // IDs
    Ini.WriteInteger ( 'osmain', 'station_idmin',    seStationIDMin.Value);
    Ini.WriteInteger ( 'osmain', 'station_idmax',    seStationIDMax.Value);
    Ini.WriteInteger ( 'osmain', 'cruise_idmin',     seCruiseIDMin.Value);
    Ini.WriteInteger ( 'osmain', 'cruise_idmax',     seCruiseIDMax.Value);

    str:='';
    for k:=0 to mCruiseIDList.Lines.Count-1 do
      str:=str+mCruiseIDList.Lines.Strings[k];
    Ini.WriteString  ( 'osmain', 'cruise_list', str);

    str:='';
    for k:=0 to mStationIDList.Lines.Count-1 do
      str:=str+mStationIDList.Lines.Strings[k];
    Ini.WriteString  ( 'osmain', 'station_list', str);

    // Auxiliary metadata
    Ini.WriteString  ( 'osmain', 'station_source',   cbSource.Text);
    Ini.WriteString  ( 'osmain', 'station_country',  cbCountry.Text);
    Ini.WriteString  ( 'osmain', 'station_platform', cbPlatform.Text);
    Ini.WriteString  ( 'osmain', 'station_cruise',   cbCruise.Text);
    Ini.WriteString  ( 'osmain', 'station_institute',cbInstitute.Text);
    Ini.WriteString  ( 'osmain', 'station_project',  cbProject.Text);

    //Depth
    Ini.Writeinteger  ( 'osmain', 'station_depthmin',  seDepthMin.Value);
    Ini.Writeinteger  ( 'osmain', 'station_depthmax',  seDepthMax.Value);
    Ini.Writeinteger  ( 'osmain', 'station_gebcomin',  seGEBCOMin.Value);
    Ini.Writeinteger  ( 'osmain', 'station_gebcomax',  seGEBCOMax.Value);
    Ini.WriteFloat    ( 'osmain', 'station_lastlevmin',seLastLevelMin.Value);
    Ini.WriteFloat    ( 'osmain', 'station_lastlevmax',seLastLevelMax.Value);

    //Cruise stations
    Ini.Writeinteger  ( 'osmain', 'cruises_stationsdatabasemin',  seCruiseStationsDatabaseMin.Value);
    Ini.Writeinteger  ( 'osmain', 'cruises_stationsdatabasemax',  seCruiseStationsDatabaseMax.Value);
    Ini.Writeinteger  ( 'osmain', 'cruises_stationstotalmin',     seCruiseStationsTotalMin.Value);
    Ini.Writeinteger  ( 'osmain', 'cruises_stationstotalmax',     seCruiseStationsTotalMax.Value);
    Ini.Writeinteger  ( 'osmain', 'cruises_stationsduplicatemin', seCruiseStationsDuplicateMin.Value);
    Ini.Writeinteger  ( 'osmain', 'cruises_stationsduplicatemax', seCruiseStationsDuplicateMax.Value);


  finally
    Ini.Free;
  end;
end;

procedure Tfrmosmain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
Var
  Ini:TIniFile;
  k: integer;
begin

  (* saving current search settings *)
  SaveSettingsSearch;

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


