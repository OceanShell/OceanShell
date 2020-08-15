unit osmain;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, ComCtrls, LCLType,
  Menus, Dialogs, ActnList, StdCtrls, IniFiles, ExtCtrls, DateUtils, sqldb, DB,
  Buttons, DBGrids, Spin, DBCtrls, DateTimePicker, Process, Math, Grids,
  LCLIntf, ComboEx;

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
    aSettings: TAction;
    aProfilesStationSingle: TAction;
    aProfilesSelectedAllPlot: TAction;
    aMapSelectedStation: TAction;
    aProfilesStationAll: TAction;
    aMapKML: TAction;
    aOpenDatabase: TAction;
    aMapAllStations: TAction;
    AL: TActionList;
    btnAddCruise: TToolButton;
    btnOpenOceanFDB: TBitBtn;
    btnadd: TToolButton;
    btnAddCruise1: TToolButton;
    btncancel: TToolButton;
    btndelete: TToolButton;
    btnsave: TToolButton;
    btnSaveCruise: TToolButton;
    btnSaveEntry: TToolButton;
    btnSelectStations: TButton;
    btnAdvancedSelection: TButton;
    btnCustomSQLQuery: TButton;
    btnSelectCruises: TButton;
    btnSelectID: TButton;
    cbCruiseCountry: TCheckComboBox;
    cbCruiseInstitute: TCheckComboBox;
    cbCruiseProject: TCheckComboBox;
    cbCruiseSource: TCheckComboBox;
    cbCruisePlatform: TCheckComboBox;
    cbSource: TCheckComboBox;
    cbPlatform: TCheckComboBox;
    cbCountry: TCheckComboBox;
    cbInstitute: TCheckComboBox;
    cbProject: TCheckComboBox;
    cgQCFlag: TCheckGroup;
    chkSelectDuplicates: TCheckBox;
    chkCruiseNOTCountry: TCheckBox;
    chkCruiseNOTInstitute: TCheckBox;
    chkNOTPlatform: TCheckBox;
    chkNOTCountry: TCheckBox;
    chkCruiseNOTPlatform: TCheckBox;
    chkCruiseNOTProject: TCheckBox;
    chkNOTSource: TCheckBox;
    chkNOTInstitute: TCheckBox;
    chkNOTProject: TCheckBox;
    chkCruiseNOTSource: TCheckBox;
    chkParameters: TCheckGroup;
    chkinstrument: TCheckGroup;
    chkPeriod: TCheckBox;
    chkCruiseIgnoreDuplicates: TCheckBox;
    DBGridCruise1: TDBGrid;
    DBGridCruise2: TDBGrid;
    DBGridEntry: TDBGrid;
    DBGridStation2: TDBGrid;
    DBGridStation1: TDBGrid;
    DBMemoCruises: TDBMemo;
    DBMemoEntriy: TDBMemo;
    dtpCruiseDateAddedMax: TDateTimePicker;
    dtpDateAddedMin: TDateTimePicker;
    dtpCruiseDateAddedMin: TDateTimePicker;
    dtpCruiseDateMax: TDateTimePicker;
    dtpCruiseDateMin: TDateTimePicker;
    dtpCruiseDateUpdatedMax: TDateTimePicker;
    dtpDateUpdatedMin: TDateTimePicker;
    dtpDateMin: TDateTimePicker;
    dtpDateMax: TDateTimePicker;
    dtpDateAddedMax: TDateTimePicker;
    dtpDateUpdatedMax: TDateTimePicker;
    dtpCruiseDateUpdatedMin: TDateTimePicker;
    eEntry_ID: TEdit;
    eEntry_Title: TEdit;
    eEntry_Type: TEdit;
    gbAuxiliaryParameters1: TGroupBox;
    GroupBox10: TGroupBox;
    GroupBox11: TGroupBox;
    GroupBox12: TGroupBox;
    GroupBox2: TGroupBox;
    gbAuxiliaryParameters: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    GroupBox9: TGroupBox;
    iProfilesAll: TMenuItem;
    ishowselectedstation: TMenuItem;
    iUpdateLastLevel: TMenuItem;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbResetSearchStations: TLabel;
    iLoad_Pangaea_CTD_tab: TMenuItem;
    iLoad_WOD18: TMenuItem;
    iMap: TMenuItem;
    iImport: TMenuItem;
    iInitialDatabase: TMenuItem;
    iUpdateCruise: TMenuItem;
    lbResetSearchCruises: TLabel;
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
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    iBottomDepthGEBCO: TMenuItem;
    MenuItem15: TMenuItem;
    iStandarddeviationslayers: TMenuItem;
    iVisualizationSurfer: TMenuItem;
    iVisualizationSurferSquares: TMenuItem;
    MenuItem2: TMenuItem;
    iSelectEntry: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    iSelectCruise: TMenuItem;
    iServiceStatistics: TMenuItem;
    iDBStatistics_AK: TMenuItem;
    iDuplicates: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    iDIVAnd: TMenuItem;
    iQC: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    pCruiseFiller: TPanel;
    pCruiseGrid: TPanel;
    pEntryFilter: TPanel;
    PMStation: TPopupMenu;
    PMCruise: TPopupMenu;
    PMEntry: TPopupMenu;
    sbDatabase: TStatusBar;
    sbSelection: TStatusBar;
    ODir: TSelectDirectoryDialog;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    seCruiseStationsDuplicateMin: TSpinEdit;
    seCruiseStationsTotalMin: TSpinEdit;
    seCruiseStationsDatabaseMin: TSpinEdit;
    seCruiseStationsTotalMax: TSpinEdit;
    seCruiseStationsDatabaseMax: TSpinEdit;
    seCruiseStationsDuplicateMax: TSpinEdit;
    seIDMax: TSpinEdit;
    seCruiseIDMax: TSpinEdit;
    seIDMin: TSpinEdit;
    seCruiseIDMin: TSpinEdit;
    seCruiseLatMax: TFloatSpinEdit;
    seCruiseLatMin: TFloatSpinEdit;
    seCruiseLonMax: TFloatSpinEdit;
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
    seCruiseLonMin: TFloatSpinEdit;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    tsSelectedCruises: TTabSheet;
    tbCruise: TToolBar;
    ToolButton8: TToolButton;
    tbFastAccess: TToolBar;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    tsSelectedStations: TTabSheet;
    ToolBar2: TToolBar;
    btnRemoveEntry: TToolButton;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    tsMainEntries: TTabSheet;
    tsMainSelect: TTabSheet;
    tsMainCruises: TTabSheet;

    procedure aMapAllStationsExecute(Sender: TObject);
    procedure aMapKMLExecute(Sender: TObject);
    procedure aMapSelectedStationExecute(Sender: TObject);
    procedure aOpenDatabaseExecute(Sender: TObject);
    procedure aProfilesSelectedAllPlotExecute(Sender: TObject);
    procedure aProfilesStationAllExecute(Sender: TObject);
    procedure aProfilesStationSingleExecute(Sender: TObject);
    procedure aSettingsExecute(Sender: TObject);
    procedure btnAddCruiseClick(Sender: TObject);
    procedure btnAdvancedSelectionClick(Sender: TObject);
    procedure btnCustomSQLQueryClick(Sender: TObject);
    procedure btnOpenOceanFDBClick(Sender: TObject);
    procedure btnSaveCruiseClick(Sender: TObject);
    procedure btnSelectCruisesClick(Sender: TObject);
    procedure btnSelectIDClick(Sender: TObject);
    procedure btnSelectStationsClick(Sender: TObject);
    procedure DBGridCruise1CellClick(Column: TColumn);
    procedure DBGridCruise1ColumnSized(Sender: TObject);
    procedure DBGridCruise1EditingDone(Sender: TObject);
    procedure DBGridCruise1PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DBGridCruise1SelectEditor(Sender: TObject; Column: TColumn;
      var Editor: TWinControl);
    procedure DBGridCruise1TitleClick(Column: TColumn);
    procedure DBGridCruise1UserCheckboxState(Sender: TObject; Column: TColumn;
      var AState: TCheckboxState);
    procedure DBGridCruise2EditingDone(Sender: TObject);
    procedure DBGridCruise2SelectEditor(Sender: TObject; Column: TColumn;
      var Editor: TWinControl);
    procedure DBGridCruise2TitleClick(Column: TColumn);
    procedure DBGridEntryCellClick(Column: TColumn);
    procedure DBGridEntryColumnSized(Sender: TObject);
    procedure DBGridEntryTitleClick(Column: TColumn);
    procedure DBGridEntryUserCheckboxState(Sender: TObject; Column: TColumn;
      var AState: TCheckboxState);
    procedure DBGridStation2CellClick(Column: TColumn);
    procedure DBGridStation2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGridStation2TitleClick(Column: TColumn);
    procedure eCruise_IDClick(Sender: TObject);
    procedure eCruise_NUMBERChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure iAboutClick(Sender: TObject);
    procedure iDBStatisticsClick(Sender: TObject);
    procedure iDBStatistics_AKClick(Sender: TObject);
    procedure iDIVAndClick(Sender: TObject);
    procedure iDuplicatesClick(Sender: TObject);
    procedure iBottomDepthGEBCOClick(Sender: TObject);
    procedure iInitialDatabaseClick(Sender: TObject);
    procedure iLoadARGOClick(Sender: TObject);
    procedure iLoadITPClick(Sender: TObject);
    procedure iLoad_GLODAP_2019_v2_productClick(Sender: TObject);
    procedure iLoad_ITPClick(Sender: TObject);
    procedure iLoad_Pangaea_CTD_tabClick(Sender: TObject);
    procedure iLoad_WOD18Click(Sender: TObject);
    procedure iPlotBathymetryClick(Sender: TObject);
    procedure iQCflagfromfileClick(Sender: TObject);
    procedure iQC_dbar_meterClick(Sender: TObject);
    procedure iSelectCruiseClick(Sender: TObject);
    procedure iNewDatabaseClick(Sender: TObject);
    procedure iSelectEntryClick(Sender: TObject);
    procedure iServiceStatisticsClick(Sender: TObject);
    procedure iSettingsClick(Sender: TObject);
    procedure iStandarddeviationslayersClick(Sender: TObject);
    procedure iSupportTablesClick(Sender: TObject);
    procedure iUpdateLastLevelClick(Sender: TObject);
    procedure iUpdateUnitsClick(Sender: TObject);
    procedure iVisualizationSurferSquaresClick(Sender: TObject);
    procedure lbResetSearchCruisesClick(Sender: TObject);
    procedure lbResetSearchStationsClick(Sender: TObject);
    procedure iUpdateCruiseClick(Sender: TObject);
    procedure iExportASCIIClick(Sender: TObject);

  private
    procedure SearchID(Sender:TObject);
    procedure SearchPLATFORM(Sender:TObject);
    procedure SearchCOUNTRY(Sender:TObject);
    procedure SearchSOURCE(Sender:TObject);
    procedure SearchPI(Sender:TObject);
    procedure SearchINSTITUTE(Sender:TObject);
    procedure SearchPROJECT(Sender:TObject);
    procedure FetchEntries;
    procedure PopulatePickLists;
    procedure GetIDListCruise(Var id_str:string);
    procedure GetIDListEntry(Var id_str:string);
    procedure GetIDListStation(Var id_str:string);

    procedure SelectGetCruisesFromStation(SQL_str:string);

  public

 //   RecListCruise  :TBookmarklist;
 //   RecListEntry   :TBookmarklist;
 //   RecListStation :TBookmarklist;

    procedure OpenDatabase;
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

  Source_unq:TStringList; //list of unique sources from selection
  depth_units: integer; //0-meters, 1-dBar

  IBLatMin,IBLatMax,IBLonMin,IBLonMax,SLatMin,SLatMax,SLonMin,SLonMax:Real;
  IBDateMin, IBDateMax, SDateMin, SDateMax :TDateTime;
  IBDateAddedMin, IBDateAddedMax, IBDateUpdatedMin, IBDateUpdatedMax :TDateTime;
  IBCount, SCount, IDMin, IDMax:Integer; //number OD stations in database and selection
  IDCruiseMin, IDCruiseMax, IBCruiseLatMin,IBCruiseLatMax,IBCruiseLonMin,IBCruiseLonMax: real;
  IBCruiseDateAddedMin, IBCruiseDateAddedMax :TDateTime;
  IBCruiseDateUpdatedMin, IBCruiseDateUpdatedMax :TDateTime;

  IBCruiseStationsTotalMax, IBCruiseStationsDatabaseMax, IBCruiseStationsDuplicateMax: integer;

  NavigationOrder:boolean=true; //Stop navigation until all modules responded

  SLatP_arr:array[0..20000] of real;
  SLonP_arr:array[0..20000] of real;
  Length_arr:integer;

  frmprofile_station_all_open, frmprofile_station_single_open :boolean;
  frmmap_open, frmprofile_plot_all_open, frmparameters_list_open: boolean;


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
  osabout,
  sortbufds,
  procedures,
  osbathymetry,
  declarations_netcdf,
  osunitsupdate,

(* loading data *)
  osload_argo,
  osload_itp,
  osload_GLODAP_2019_v2_product,
  osload_WOD18,
  osload_PangaeaTab,

(* database service procedures *)
  ossupporttables,
  osservicestatistics,

(* data import *)
  osimport_fdb,

(* data export *)
  osexport_divand,
  osexport_ascii,

(* QC *)
  osqc_dbar_meters_consistency,
  osqc_duplicates,
  osqc_meanprofile,
  osqc_setflags,

(* tools *)
  osmap,
  osmap_kml,
  osparameters_list,
  osprofile_station_all,
  osprofile_station_single,
  osprofile_plot_all,
  osbathymetry_plot,

(* statistics *)
  osstatistics,
  osstatistics_AK,

(* visualization *)
  osviz_surfer_squares
;

{$R *.lfm}


procedure Tfrmosmain.FormCreate(Sender: TObject);
begin
  //RecListCruise  := TBookmarkList.Create(DBGridCruise1);
  //RecListEntry   := TBookmarkList.Create(DbGridEntry);
 // RecListStation := TBookmarkList.Create(DbGridStation1);
end;


procedure Tfrmosmain.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
  k:integer;
begin
 IBName:='';

(* flags on open forms *)
 frmprofile_station_all_open:=false; frmprofile_station_single_open:=false;
 frmmap_open:=false; frmparameters_list_open:=false;
 frmprofile_plot_all_open:=false;

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

    depth_units:=Ini.ReadInteger('main', 'depth_units', 0);

    (* STATION search settings *)
    seLatMin.Value   :=Ini.ReadFloat  ( 'osmain', 'station_latmin',     0);
    seLatMax.Value   :=Ini.ReadFloat  ( 'osmain', 'station_latmax',     0);
    seLonMin.Value   :=Ini.ReadFloat  ( 'osmain', 'station_lonmin',     0);
    seLonMax.Value   :=Ini.ReadFloat  ( 'osmain', 'station_lonmax',     0);
    chkPeriod.Checked:=Ini.ReadBool   ( 'osmain', 'station_period', false);
    seIDMin.Value    :=Ini.ReadInteger( 'osmain', 'station_idmin',      0);
    seIDMax.Value    :=Ini.ReadInteger( 'osmain', 'station_idmax',      0);
    cbPlatform.Text  :=Ini.ReadString ( 'osmain', 'station_platform',  '');
    cbCountry.Text   :=Ini.ReadString ( 'osmain', 'station_country',   '');
    cbSource.Text    :=Ini.ReadString ( 'osmain', 'station_source',    '');
    cbInstitute.Text :=Ini.ReadString ( 'osmain', 'station_institute', '');
    cbProject.Text   :=Ini.ReadString ( 'osmain', 'station_project',   '');
    dtpDateMin.DateTime:=Ini.ReadDateTime('osmain', 'station_datemin', now);
    dtpDateMax.DateTime:=Ini.ReadDateTime('osmain', 'station_datemax', now);
    dtpDateAddedMin.DateTime:=Ini.ReadDateTime('osmain', 'station_dateaddedmin', now);
    dtpDateAddedMax.DateTime:=Ini.ReadDateTime('osmain', 'station_dateaddedmax', now);
    dtpDateUpdatedMin.DateTime:=Ini.ReadDateTime('osmain', 'station_dateupdatedmin', now);
    dtpDateUpdatedMax.DateTime:=Ini.ReadDateTime('osmain', 'station_dateupdatedmax', now);
    //seCruiseStationsDatabaseMin.Value:=Ini.ReadInteger( 'osmain', 'idmax',      0);

    (* CRUISE search settings *)
    seCruiseLatMin.Value   :=Ini.ReadFloat  ( 'osmain', 'cruise_latmin',     0);
    seCruiseLatMax.Value   :=Ini.ReadFloat  ( 'osmain', 'cruise_latmax',     0);
    seCruiseLonMin.Value   :=Ini.ReadFloat  ( 'osmain', 'cruise_lonmin',     0);
    seCruiseLonMax.Value   :=Ini.ReadFloat  ( 'osmain', 'cruise_lonmax',     0);
    seCruiseIDMin.Value    :=Ini.ReadInteger( 'osmain', 'cruise_idmin',      0);
    seCruiseIDMax.Value    :=Ini.ReadInteger( 'osmain', 'cruise_idmax',      0);
    cbCruisePlatform.Text  :=Ini.ReadString ( 'osmain', 'cruise_platform',  '');
    cbCruiseCountry.Text   :=Ini.ReadString ( 'osmain', 'cruise_country',   '');
    cbCruiseSource.Text    :=Ini.ReadString ( 'osmain', 'cruise_source',    '');
    cbCruiseInstitute.Text :=Ini.ReadString ( 'osmain', 'cruise_institute', '');
    cbCruiseProject.Text   :=Ini.ReadString ( 'osmain', 'cruise_project',   '');
    dtpCruiseDateMin.DateTime:=Ini.ReadDateTime('osmain', 'cruise_datemin', now);
    dtpCruiseDateMax.DateTime:=Ini.ReadDateTime('osmain', 'cruise_datemax', now);
    dtpCruiseDateAddedMin.DateTime:=Ini.ReadDateTime('osmain', 'cruise_dateaddedmin', now);
    dtpCruiseDateAddedMax.DateTime:=Ini.ReadDateTime('osmain', 'cruise_dateaddedmax', now);
    dtpCruiseDateUpdatedMin.DateTime:=Ini.ReadDateTime('osmain', 'cruise_dateupdatedmin', now);
    dtpCruiseDateUpdatedMax.DateTime:=Ini.ReadDateTime('osmain', 'cruise_dateupdatedmax', now);

    (* CRUISE table columns *)
    DBMemoCruises.width := Ini.ReadInteger( 'osmain', 'pCruiseNotes_Width', 250);
    DBGridCruise2.Height:= Ini.ReadInteger( 'osmain', 'pCruiseBottom_Height', 200);
    With DBGridCruise1 do begin
     Columns[0].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col00',  30);
     Columns[1].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col01',  50);
     Columns[2].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col02', 150);
     Columns[3].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col03', 100);
     Columns[4].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col04',  70);
     Columns[5].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col05',  70);
     Columns[6].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col06',  70);
     Columns[7].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col07',  70);
     Columns[8].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col08',  70);
     Columns[9].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col09',  70);
     Columns[10].Width:=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col10',  70);
     Columns[11].Width:=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col11',  70);
    End;

    With DBGridCruise2 do begin
     Columns[0].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col12',  150);
     Columns[1].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col13',  150);
     Columns[2].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col14',  150);
     Columns[3].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col15',  150);
     Columns[4].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col16',  70);
     Columns[5].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col17',  70);
     Columns[6].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col18',  70);
     Columns[7].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col19',  70);
     Columns[8].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col20',  70);
     Columns[9].Width :=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col21',  70);
     Columns[10].Width:=Ini.ReadInteger( 'osmain', 'DBGridCruise_Col22',  70);
    end;

    (* ENTRY table columns *)
    With DBGridEntry do begin
     Columns[0].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col00',  30); //CheckBox
     Columns[1].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col01',  50); //ID
     Columns[2].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col02', 100); //Type
     Columns[3].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col03', 150); //Title
     Columns[4].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col04',  60); //Stations
     Columns[5].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col05',  70); //Start date
     Columns[6].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col06',  70); //Finish date
     Columns[7].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col07',  70); //Date_added
     Columns[8].Width :=Ini.ReadInteger( 'osmain', 'DBGridEntry_Col08',  70); //Date_upfated
    end;

    with DBGridStation1 do begin
     Height := Ini.ReadInteger( 'osmain', 'DBGridStation1_Height', 300);
     Columns[0].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col00',    30);  //CheckBox
     Columns[1].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col01',    60);  //STATION ID
     Columns[2].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col02',    60);  //CRUISE ID
     Columns[3].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col03',    60);  //FLAG
     Columns[4].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col04',    80);  //LATITUDE
     Columns[5].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col05',    80);  //LONGITUDE
     Columns[6].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col06',   130);  //DATE
     Columns[7].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col07',   130);  //SOURCE
     Columns[8].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col08',   130);  //PLATFORM
     Columns[9].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation1_Col09',   130);  //COUNTRY
    end;

    with DBGridStation2 do begin
     Columns[0].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col00',    60);
     Columns[1].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col01',    60);
     Columns[2].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col02',    60);
     Columns[3].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col03',    60);
     Columns[4].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col04',    60);
     Columns[5].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col05',    60);
     Columns[6].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col06',    60);
     Columns[7].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col07',    60);
     Columns[8].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col08',    60);
     Columns[9].Width :=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col09',    60);
     Columns[10].Width:=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col10',    60);
     Columns[11].Width:=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col11',    60);
     Columns[12].Width:=Ini.ReadInteger( 'osmain', 'DBGridStation2_Col12',    60);
    end;


    for k:=0 to cgQCFlag.Items.Count-1 do
      cgQCFlag.Checked[k]:= Ini.ReadBool( 'osmain', 'QCF'+inttostr(k), true);


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

   DBGridCruise1.OnColumnSized(Self);

 {  eCruise_ID.OnChange           := @SearchID;
   eCruise_PLATFORM.OnChange     := @SearchPLATFORM;
   eCruise_COUNTRY.OnChange      := @SearchCOUNTRY;
   eCruise_SOURCE.OnChange       := @SearchSOURCE;
   eCruise_Project.OnChange      := @SearchPROJECT;
   eCruise_Institute.OnChange    := @SearchINSTITUTE;
   eCruise_PI.OnChange           := @SearchPI; }


 (* disabling menu items *)
  for k:=1 to MM.Items.Count-2 do MM.Items[k].Enabled:=false;

 (* list of unique sources - only those selected *)
 Source_unq:=TStringList.Create;

 (* Disabling some menu items if there is no GEBCO *)
 iPlotBathymetry.Enabled:=GEBCOExists;
 iBottomDepthGEBCO.Enabled:=GEBCOExists;


 OnResize(Self);
 SetFocus;
 Application.ProcessMessages;
end;



procedure Tfrmosmain.btnOpenOceanFDBClick(Sender: TObject);
Var
  Ini: TIniFile;
  DBName:string;
begin
  Ini := TIniFile.Create(IniFileName);
  try
   DBName:=Ini.ReadString( 'main', 'OceanFDBPath',  '');
  finally
    Ini.free;
  end;

  if FileExists(DBName) then begin
   IBName:='localhost:'+DBName;
   OpenDatabase;
  end else
   if MessageDlg('Please, specify path to Ocean.fdb', mtWarning, [mbOk], 0)=mrOk then
    aSettings.Execute();
end;


procedure Tfrmosmain.btnSelectStationsClick(Sender: TObject);
var
i, k, fl:integer;
SSYearMin,SSYearMax,SSMonthMin,SSMonthMax,SSDayMin,SSDayMax :Word;
NotCondCountry, NotCondPlatform, NotCondSource:string;
NotCondInstitute, NotCondProject, NotCondOrigin, SBordersFile:string;
{
MinDay, MaxDay, cnt:integer;
Lat, Lon:real; }
time0, time1:TDateTime;
buf_str, SQL_str, QCFlag_str: string;
t_begin:TDateTime;
begin

frmosmain.Enabled:=false;
Application.ProcessMessages;

try
 DecodeDate(dtpDateMin.Date, SSYearMin, SSMonthMin, SSDayMin);
 DecodeDate(dtpDateMax.Date, SSYearMax, SSMonthMax, SSDayMax);

  if chkNOTPlatform.Checked  =true then NotCondCountry   :='NOT' else NotCondCountry   :='';
  if chkNOTPlatform.Checked  =true then NotCondPlatform  :='NOT' else NotCondPlatform  :='';
  if chkNOTSource.Checked    =true then NotCondSource    :='NOT' else NotCondSource    :='';
  if chkNOTInstitute.Checked =true then NotCondInstitute :='NOT' else NotCondInstitute :='';
  if chkNOTProject.Checked   =true then NotCondProject   :='NOT' else NotCondProject   :='';


 t_begin:=now;
 with frmdm.Q do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT ');
    SQL.Add(' STATION.ID, STATION.LATITUDE, STATION.LONGITUDE, ');
    SQL.Add(' STATION.DATEANDTIME, STATION.BOTTOMDEPTH, STATION.LASTLEVEL_M, ');
    SQL.Add(' STATION.LASTLEVEL_DBAR, STATION.CRUISE_ID, STATION.CAST_NUMBER,  ');
    SQL.Add(' STATION.ST_NUMBER_ORIGIN, STATION.ST_ID_ORIGIN, ');
    SQL.Add(' STATION.QCFLAG, STATION.STVERSION, STATION.DUPLICATE, ');
    SQL.Add(' STATION.BOTTOMDEPTH_GEBCO, ');
    SQL.Add(' STATION.MERGED, STATION.ACCESSION_NUMBER, STATION.DATE_ADDED, ');
    SQL.Add(' STATION.DATE_UPDATED, PLATFORM.NAME as PLATF, CRUISE.CRUISE_NUMBER, ');
    SQL.Add(' COUNTRY.NAME as CNTR, SOURCE.NAME as SRC ');
    SQL.Add(' FROM STATION, CRUISE, PLATFORM, COUNTRY, SOURCE ');
    SQL.Add(' WHERE ');

    SQL_str:='';

    (* Parameters *)
    for k:=0 to chkParameters.Items.Count-1 do
       if chkParameters.Checked[k] then
        SQL_str:=SQL_str+' STATION.ID IN (SELECT DISTINCT(ID) FROM '+chkParameters.Items.Strings[k]+') AND ';

    SQL_str:=SQL_str+' STATION.CRUISE_ID=CRUISE.ID AND ';
    SQL_str:=SQL_str+' CRUISE.PLATFORM_ID=PLATFORM.ID AND ';
    SQL_str:=SQL_str+' PLATFORM.COUNTRY_ID=COUNTRY.ID AND ';
    SQL_str:=SQL_str+' CRUISE.SOURCE_ID=SOURCE.ID ';
    SQL_str:=SQL_str+' AND (STATION.ID BETWEEN :SSIDMin AND :SSIDMax) ';

    (* QC Flag *)
    QCFlag_str:='';
    for k:=0 to cgQCFlag.Items.Count-1 do
      if cgQCFlag.Checked[k]=true then
       QCFlag_str:=QCFlag_str+inttostr(k)+',';
    QCFlag_str:=copy(QCFlag_str, 1, length(QCFlag_str)-1);
    if trim(QCFlag_str)<>'' then
      SQL_str:=SQL_str+' AND (STATION.QCFLAG IN ('+QCFlag_str+')) ';

    (* Coordinates *)
    SQL_str:=SQL_str+' AND (LATITUDE BETWEEN :SSLatMin AND :SSLatMax) ';
     if seLonMax.Value>=seLonMin.Value then
      SQL_str:=SQL_str+' AND (LONGITUDE BETWEEN :SSLonMin AND :SSLonMax) ';
     if seLonMax.Value<seLonMin.Value then
      SQL_str:=SQL_str+' AND ((LONGITUDE>=:SSLonMin AND LONGITUDE<=180) OR '+
                       '(LONGITUDE>=-180 and LONGITUDE<=:SSLonMax)) ';
    (* End of coordinates *)

    (* Date and Time *)
    // From date to date
    if chkPeriod.Checked=false then
     SQL_str:=SQL_str+'  AND (DATEANDTIME between :SSDateMin and :SSDateMax) ';

    //Date in Period
    if chkPeriod.Checked=true then begin
      SQL_str:=SQL_str+' AND (Extract(Year from DATEANDTIME) between :SSYearMin  and :SSYearMax) ';
      if SSMonthMin<=SSMonthMax then
         SQL_str:=SQL_str+' AND (Extract(Month from DATEANDTIME) between :SSMonthMin and :SSMonthMax) ';
      if SSMonthMin>SSMonthMax then
         SQL_str:=SQL_str+' AND ((Extract(Month from DATEANDTIME)>= :SSMonthMin) or'+
                          ' (Extract(Month from DATEANDTIME)<= :SSMonthMax)) ';
      if SSDayMin<=SSDayMax then
         SQL_str:=SQL_str+' AND (Extract(Day from DATEANDTIME) between :SSDayMin and :SSDayMax) ';
      if SSDayMin>SSDayMax then
         SQL_str:=SQL_str+' AND ((Extract(Day from DATEANDTIME)>= :SSDayMin) OR '+
                          ' (Extract(Day from DATEANDTIME)<= :SSDayMax)) ';
    end;

    SQL_str:=SQL_str+'  AND (STATION.DATE_ADDED between :SSDateAddedMin and :SSDateAddedMax) ';
    SQL_str:=SQL_str+'  AND (STATION.DATE_UPDATED between :SSDateUpdatedMin and :SSDateUpdatedMax) ';

    (* End of Date and Time *)

    if cbPlatform.Text<>'' then begin
      SQL_str:=SQL_str+' AND '+NotCondSource    +' PLATFORM.NAME IN (';
     for k:=0 to cbPlatform.Count-1 do
       if cbPlatform.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbPlatform.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+') ';
    end;

    if cbCountry.Text<>'' then begin
      SQL_str:=SQL_str+' AND '+NotCondSource    +' COUNTRY.NAME IN (';
     for k:=0 to cbCountry.Count-1 do
       if cbCountry.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbCountry.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+') ';
    end;

    if cbSource.Text<>'' then begin
      SQL_str:=SQL_str+' AND '+NotCondSource    +' SOURCE.NAME IN (';
     for k:=0 to cbSource.Count-1 do
       if cbSource.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbSource.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+') ';
    end;

    if cbInstitute.Text<>'' then begin
      SQL_str:=SQL_str+' AND '+NotCondSource    +' INSTITUTE.NAME IN (';
     for k:=0 to cbInstitute.Count-1 do
       if cbInstitute.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbInstitute.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+') ';
    end;

    if cbProject.Text<>'' then begin
      SQL_str:=SQL_str+' AND '+NotCondSource    +' PROJECT.NAME IN (';
     for k:=0 to cbProject.Count-1 do
       if cbProject.Checked[k]=true then
          SQL_str:=SQL_str+QuotedStr(cbProject.Items.Strings[k])+',';
     SQL_str:=copy(SQL_str, 1, length(SQL_str)-1)+') ';
    end;

    if chkSelectDuplicates.Checked=true then
      SQL_str:=SQL_str+' AND STATION.DUPLICATE=FALSE ';

    SQL.Add(SQL_str);
    SQL.Add(' ORDER BY DATEANDTIME ');

    ParamByName('SSIDMin').AsInteger:=seIDMin.Value;
    ParamByName('SSIDMax').AsInteger:=seIDMax.Value;

    //ParamByName('SSQCMin').AsInteger:=StrToInt(cbQCFlag1.Text);
    //ParamByName('SSQCMax').AsInteger:=StrToInt(cbQCFlag2.Text);

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
    ParamByName('SSDateAddedMin').AsDateTime:=dtpDateAddedMin.DateTime;
    ParamByName('SSDateAddedMax').AsDateTime:=dtpDateAddedMax.DateTime;
    ParamByName('SSDateUpdatedMin').AsDateTime:=dtpDateUpdatedMin.DateTime;
    ParamByName('SSDateUpdatedMax').AsDateTime:=dtpDateUpdatedMax.DateTime;

   Open;
 end;

 SelectGetCruisesFromStation(SQL_str);

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
     SQL.Add(' STATION, CRUISE, PLATFORM, COUNTRY, SOURCE ');
     SQL.Add(' WHERE ');
     SQL.Add(  SQL_str  );
     SQL.Add(' ORDER BY SOURCE.NAME ');
     Params:=frmdm.Q.Params;
   Open;
  end;

  Source_unq.Clear;
  while not frmdm.q1.EOF do begin
     Source_unq.Add(frmdm.q1.Fields[0].AsString);
   frmdm.q1.Next;
  end;

 // showmessage(Source_unq.Strings[0]);
//   showmessage(DateTimeToStr(now-t_begin));


  With frmdm.q1 do begin
   Close;
     SQL.Clear;
     SQL.Add(' SELECT DISTINCT(CRUISE_ID) FROM ');
     SQL.Add(' STATION, CRUISE, PLATFORM, COUNTRY, SOURCE ');
     SQL.Add(' WHERE ');
     SQL.Add(  SQL_str  );
     Params:=frmdm.Q.Params;
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
      SQL.Add(' SELECT ');
      SQL.Add(' CRUISE.ID, PLATFORM_ID, SOURCE_ID, INSTITUTE_ID, PROJECT_ID, ');
      SQL.Add(' PLATFORM.NAME AS PLATFORM, COUNTRY.NAME AS COUNTRY, ');
      SQL.Add(' SOURCE.NAME AS SOURCE, INSTITUTE.NAME AS INSTITUTE, ');
      SQL.Add(' PROJECT.NAME AS PROJECT, CRUISE.DATE_ADDED, CRUISE.DATE_UPDATED, ');
      SQL.Add(' CRUISE.CRUISE_NUMBER, CRUISE.DATE_START_TOTAL, ');
      SQL.Add(' CRUISE.DATE_END_TOTAL, CRUISE.DATE_START_DATABASE,  ');
      SQL.Add(' CRUISE.DATE_END_DATABASE, CRUISE.LATITUDE_MIN, CRUISE.LATITUDE_MAX, ');
      SQL.Add(' CRUISE.LONGITUDE_MIN, CRUISE.LONGITUDE_MAX, CRUISE.EXPOCODE, ');
      SQL.Add(' CRUISE.PI, CRUISE.NOTES, CRUISE.STATIONS_TOTAL, CRUISE.SELECTED, ');
      SQL.Add(' CRUISE.STATIONS_DATABASE, CRUISE.STATIONS_DUPLICATES ');
      SQL.Add(' FROM CRUISE, PLATFORM, COUNTRY, SOURCE, INSTITUTE, PROJECT ');
      SQL.Add(' WHERE ');
      SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
      SQL.Add(' PLATFORM.COUNTRY_ID=COUNTRY.ID AND ');
      SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
      SQL.Add(' CRUISE.INSTITUTE_ID=INSTITUTE.ID AND ');
      SQL.Add(' CRUISE.PROJECT_ID=PROJECT.ID AND ');
      SQL.Add(' CRUISE.ID IN (SELECT ID FROM TEMPORARY_ID_LIST) ');
      SQL.Add(' ORDER BY PLATFORM.NAME, CRUISE.DATE_START_TOTAL ' );
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

  try
   with frmdm.Q do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT ');
    SQL.Add(' STATION.ID, STATION.LATITUDE, STATION.LONGITUDE, ');
    SQL.Add(' STATION.DATEANDTIME, STATION.BOTTOMDEPTH, STATION.LASTLEVEL_M, ');
    SQL.Add(' STATION.LASTLEVEL_DBAR, STATION.CRUISE_ID, STATION.CAST_NUMBER,  ');
    SQL.Add(' STATION.ST_NUMBER_ORIGIN, STATION.ST_ID_ORIGIN, ');
    SQL.Add(' STATION.QCFLAG, STATION.STVERSION, STATION.DUPLICATE, ');
    SQL.Add(' STATION.BOTTOMDEPTH_GEBCO, ');
    SQL.Add(' STATION.MERGED, STATION.ACCESSION_NUMBER, STATION.DATE_ADDED, ');
    SQL.Add(' STATION.DATE_UPDATED, PLATFORM.NAME as PLATF, CRUISE.CRUISE_NUMBER, ');
    SQL.Add(' COUNTRY.NAME as CNTR, SOURCE.NAME as SRC ');
    SQL.Add(' FROM STATION, CRUISE, PLATFORM, COUNTRY, SOURCE ');
    SQL.Add(' WHERE ');
        SQL_str:=' STATION.CRUISE_ID=CRUISE.ID AND ';
        SQL_str:=SQL_str+' CRUISE.PLATFORM_ID=PLATFORM.ID AND ';
        SQL_str:=SQL_str+' PLATFORM.COUNTRY_ID=COUNTRY.ID AND ';
        SQL_str:=SQL_str+' CRUISE.SOURCE_ID=SOURCE.ID AND ';
        SQL_str:=SQL_str+' STATION.ID IN (SELECT ID FROM TEMPORARY_ID_LIST)';
    SQL.Add( SQL_str);
    SQL.Add(' ORDER BY DATEANDTIME ');
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
  NotCondInstitute, NotCondProject:string;
  SQL_str: string;
begin

{  frmdm.Q.Close; //closing selected sations query
  for k:=1 to 7 do sbSelection.Panels[k].Text:='---'; }

  if chkNOTPlatform.Checked  =true then NotCondCountry   :='NOT' else NotCondCountry   :='';
  if chkNOTPlatform.Checked  =true then NotCondPlatform  :='NOT' else NotCondPlatform  :='';
  if chkNOTSource.Checked    =true then NotCondSource    :='NOT' else NotCondSource    :='';
  if chkNOTInstitute.Checked =true then NotCondInstitute :='NOT' else NotCondInstitute :='';
  if chkNOTProject.Checked   =true then NotCondProject   :='NOT' else NotCondProject   :='';


  with frmdm.QCruise do begin
    Close;
      SQL.Clear;
      SQL.Add(' SELECT ');
      SQL.Add(' CRUISE.ID, PLATFORM_ID, SOURCE_ID, INSTITUTE_ID, PROJECT_ID, ');
      SQL.Add(' PLATFORM.NAME AS PLATFORM, COUNTRY.NAME AS COUNTRY, ');
      SQL.Add(' SOURCE.NAME AS SOURCE, INSTITUTE.NAME AS INSTITUTE, ');
      SQL.Add(' PROJECT.NAME AS PROJECT, CRUISE.DATE_ADDED, CRUISE.DATE_UPDATED, ');
      SQL.Add(' CRUISE.CRUISE_NUMBER, CRUISE.DATE_START_TOTAL, ');
      SQL.Add(' CRUISE.DATE_END_TOTAL, CRUISE.DATE_START_DATABASE,  ');
      SQL.Add(' CRUISE.DATE_END_DATABASE, CRUISE.LATITUDE_MIN, CRUISE.LATITUDE_MAX, ');
      SQL.Add(' CRUISE.LONGITUDE_MIN, CRUISE.LONGITUDE_MAX, CRUISE.EXPOCODE, ');
      SQL.Add(' CRUISE.PI, CRUISE.NOTES, CRUISE.STATIONS_TOTAL, ');
      SQL.Add(' CRUISE.STATIONS_DATABASE, CRUISE.STATIONS_DUPLICATES, ');
      SQL.Add(' CRUISE.SELECTED ');
      SQL.Add(' FROM CRUISE, PLATFORM, COUNTRY, SOURCE, INSTITUTE, PROJECT ');
      SQL.Add(' WHERE ');
      SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
      SQL.Add(' PLATFORM.COUNTRY_ID=COUNTRY.ID AND ');
      SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
      SQL.Add(' CRUISE.INSTITUTE_ID=INSTITUTE.ID AND ');
      SQL.Add(' CRUISE.PROJECT_ID=PROJECT.ID ');

      (* IDs *)
      SQL.Add(' AND (CRUISE.ID BETWEEN :SSIDMin AND :SSIDMax) ');

     (* Coordinates *)
     SQL.Add(' AND ((LATITUDE_MIN>=:SSLatMin AND LATITUDE_MAX<=:SSLatMax) OR ');
     SQL.Add('      (LATITUDE_MIN BETWEEN :SSLatMin AND :SSLatMax) OR ');
     SQL.Add('      (LATITUDE_MAX BETWEEN :SSLatMin AND :SSLatMax)) ');

     if seLonMax.Value>=seLonMin.Value then
      SQL.Add(' AND ((LONGITUDE_MIN>=:SSLonMin AND LONGITUDE_MAX<=:SSLonMax) OR ');
      SQL.Add('      (LONGITUDE_MIN BETWEEN :SSLonMin AND :SSLonMax) OR ');
      SQL.Add('      (LONGITUDE_MAX BETWEEN :SSLonMin AND :SSLonMax)) ');

     (* FIX NEEDED HERE *)
     if seLonMax.Value<seLonMin.Value then
      SQL.Add(' AND ((LONGITUDE_MIN>=:SSLonMin AND LONGITUDE_MAX<=180) OR'+
              '      (LONGITUDE_MIN>=-180 AND LONGITUDE_MAX<=:SSLonMax)) ');

     SQL.Add('  AND (DATE_START_TOTAL >= :SSDateMin) AND (DATE_END_TOTAL <= :SSDateMax) ');
     SQL.Add('  AND (CRUISE.DATE_ADDED between :SSDateAddedMin and :SSDateAddedMax) ');
     SQL.Add('  AND (CRUISE.DATE_UPDATED between :SSDateUpdatedMin and :SSDateUpdatedMax) ');

     SQL.Add('  AND (STATIONS_TOTAL >= :SSStationsTotalMin) AND (STATIONS_TOTAL <= :SSStationsTotalMax)  ');
     SQL.Add('  AND (STATIONS_DATABASE >= :SSStationsDBMin) AND (STATIONS_DATABASE <= :SSStationsDBMax)  ');
     SQL.Add('  AND (STATIONS_DUPLICATES >= :SSStationsDupMin) AND (STATIONS_DUPLICATES <= :SSStationsDupMax)  ');

    SQL_str:='';
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

    if chkCruiseIgnoreDuplicates.Checked=true then
      SQL_str:=SQL_str+' AND CRUISE.DUPLICATE=FALSE ';

    SQL.Add( SQL_str);
    SQL.Add(' ORDER BY PLATFORM.NAME, CRUISE.DATE_START_TOTAL ' );

    ParamByName('SSIDMin').Value:=seCruiseIDMin.Value;
    ParamByName('SSIDMax').Value:=seCruiseIDMax.Value;

    ParamByName('SSLatMin').AsFloat:=seCruiseLatMin.Value;
    ParamByName('SSLatMax').AsFloat:=seCruiseLatMax.Value;
    ParamByName('SSLonMin').AsFloat:=seCruiseLonMin.Value;
    ParamByName('SSLonMax').AsFloat:=seCruiseLonMax.Value;
    ParamByName('SSStationsTotalMin').AsInteger:=seCruiseStationsTotalMin.Value;
    ParamByName('SSStationsTotalMax').AsInteger:=seCruiseStationsTotalMax.Value;
    ParamByName('SSStationsDBMin').AsInteger:=seCruiseStationsDatabaseMin.Value;
    ParamByName('SSStationsDBMax').AsInteger:=seCruiseStationsDatabaseMax.Value;
    ParamByName('SSStationsDupMin').AsInteger:=seCruiseStationsDuplicateMin.Value;
    ParamByName('SSStationsDupMax').AsInteger:=seCruiseStationsDuplicateMax.Value;

    ParamByName('SSDateMin').AsDateTime:=dtpCruiseDateMin.DateTime;
    ParamByName('SSDateMax').AsDateTime:=dtpCruiseDateMax.DateTime;
    ParamByName('SSDateAddedMin').AsDateTime:=dtpCruiseDateAddedMin.DateTime;
    ParamByName('SSDateAddedMax').AsDateTime:=dtpCruiseDateAddedMax.DateTime;
    ParamByName('SSDateUpdatedMin').AsDateTime:=dtpCruiseDateUpdatedMin.DateTime;
    ParamByName('SSDateUpdatedMax').AsDateTime:=dtpCruiseDateUpdatedMax.DateTime;

   //showmessage(frmdm.QCruise.SQL.Text);
   Open;
   Last;
   First;
  end;

  tsSelectedCruises.TabVisible:= not frmdm.QCruise.IsEmpty;
  if not frmdm.QCruise.IsEmpty then begin
    PageControl1.ActivePageIndex:=3;
    tsSelectedCruises.Caption:='Selected cruises: '+inttostr(frmdm.QCruise.RecordCount);
  end;

 Application.ProcessMessages;
end;


procedure Tfrmosmain.iSelectCruiseClick(Sender: TObject);
Var
 crID_OLD, cnt: integer;
 id_str: string;
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


   with frmdm.Q do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT ');
      SQL.Add(' STATION.ID, STATION.LATITUDE, STATION.LONGITUDE, ');
      SQL.Add(' STATION.DATEANDTIME, STATION.BOTTOMDEPTH, STATION.LASTLEVEL_M, ');
      SQL.Add(' STATION.LASTLEVEL_DBAR, STATION.CRUISE_ID, STATION.CAST_NUMBER, ');
      SQL.Add(' STATION.BOTTOMDEPTH_GEBCO, ');
      SQL.Add(' STATION.ST_NUMBER_ORIGIN, STATION.ST_ID_ORIGIN, ');
      SQL.Add(' STATION.QCFLAG, STATION.STVERSION, STATION.DUPLICATE, ');
      SQL.Add(' STATION.MERGED, STATION.ACCESSION_NUMBER, STATION.DATE_ADDED, ');
      SQL.Add(' STATION.DATE_UPDATED, PLATFORM.NAME as PLATF, ');
      SQL.Add(' COUNTRY.NAME as CNTR, SOURCE.NAME as SRC, CRUISE.CRUISE_NUMBER ');
      SQL.Add(' FROM STATION, CRUISE, PLATFORM, COUNTRY, SOURCE ');
      SQL.Add(' WHERE ');
      SQL.Add(' STATION.CRUISE_ID=CRUISE.ID AND ');
      SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
      SQL.Add(' PLATFORM.COUNTRY_ID=COUNTRY.ID AND ');
      SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
      SQL.Add(' STATION.CRUISE_ID in (SELECT ID FROM TEMPORARY_ID_LIST) '); //('+id_str+') ');
     Open;
     Last;
     First;
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

  Source_unq.Clear;
  while not frmdm.q1.EOF do begin
     Source_unq.Add(frmdm.q1.Fields[0].AsString);
   frmdm.q1.Next;
  end;
  frmdm.q1.Close;

   SelectionInfo;
   CDSNavigation;
   Application.ProcessMessages;
end;

procedure Tfrmosmain.iSelectEntryClick(Sender: TObject);
Var
id_str: string;
begin
  GetIDListEntry(id_str);

  if trim(id_str)='' then
     if MessageDlg('Select one or more entry', mtWarning, [mbOk], 0)=mrOk then exit;

   with frmdm.Q do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT ');
      SQL.Add(' STATION.ID, STATION.LATITUDE, STATION.LONGITUDE, ');
      SQL.Add(' STATION.DATEANDTIME, STATION.BOTTOMDEPTH, STATION.LASTLEVEL_M, ');
      SQL.Add(' STATION.LASTLEVEL_DBAR, STATION.CRUISE_ID, STATION.CAST_NUMBER, ');
      SQL.Add(' STATION.ST_NUMBER_ORIGIN, STATION.ST_ID_ORIGIN, ');
      SQL.Add(' STATION.QCFLAG, STATION.STVERSION, STATION.DUPLICATE, ');
      SQL.Add(' STATION.MERGED, STATION.ACCESSION_NUMBER, STATION.DATE_ADDED, ');
      SQL.Add(' STATION.DATE_UPDATED, PLATFORM.NAME as PLATF, ');
      SQL.Add(' COUNTRY.NAME as CNTR, SOURCE.NAME as SRC, CRUISE.CRUISE.NUMBER ');
      SQL.Add(' FROM STATION, STATION_ENTRY, CRUISE, PLATFORM, COUNTRY, SOURCE ');
      SQL.Add(' WHERE ');
      SQL.Add(' STATION.CRUISE_ID=CRUISE.ID AND ');
      SQL.Add(' CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
      SQL.Add(' PLATFORM.COUNTRY_ID=COUNTRY.ID AND ');
      SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
      SQL.Add(' STATION.ID = STATION_ENTRY.STATION_ID AND ');
      SQL.Add(' STATION_ENTRY.ENTRY_ID in ('+id_str+') ');
     Open;
     //Last changes
     Last;
     First;
   end;

   SelectionInfo;
   CDSNavigation;
end;

procedure Tfrmosmain.lbResetSearchStationsClick(Sender: TObject);
Var
  k:integer;
begin
  seLatMin.Value:=IBLatMin;
  seLatMax.Value:=IBLatMax;
  seLonMin.Value:=IBLonMin;
  seLonMax.Value:=IBLonMax;

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

  seIDMin.Value:=IDMin;
  seIDMax.Value:=IDMax;

  dtpDateMin.DateTime:=IBDateMin;
  dtpDateMax.DateTime:=IBDateMax;
  chkPeriod.Checked:=false;

  dtpDateAddedMin.DateTime:=IBDateAddedMin;
  dtpDateAddedMax.DateTime:=IBDateAddedMax;
  dtpDateUpdatedMin.DateTime:=IBDateUpdatedMin;
  dtpDateUpdatedMax.DateTime:=IBDateUpdatedMax;

  for k:=0 to chkParameters.Items.Count-1 do
    chkParameters.Checked[k]:=false;
end;


procedure Tfrmosmain.lbResetSearchCruisesClick(Sender: TObject);
Var
  k: integer;
begin

  seCruiseStationsTotalMin.Value:=0;
  seCruiseStationsTotalMax.Value:=IBCruiseStationsTotalMax;
  seCruiseStationsDatabaseMin.Value:=0;
  seCruiseStationsDatabaseMax.Value:=IBCruiseStationsDatabaseMax;
  seCruiseStationsDuplicateMin.Value:=0;
  seCruiseStationsDuplicateMax.Value:=IBCruiseStationsDuplicateMax;

  seCruiseLatMin.Value:=IBCruiseLatMin;
  seCruiseLatMax.Value:=IBCruiseLatMax;
  seCruiseLonMin.Value:=IBCruiseLonMin;
  seCruiseLonMax.Value:=IBCruiseLonMax;

  for k:=0 to cbCruisePlatform.Count-1  do cbCruisePlatform.Checked[k]:=false;
  for k:=0 to cbCruiseCountry.Count-1   do cbCruiseCountry.Checked[k]:=false;
  for k:=0 to cbCruiseSource.Count-1    do cbCruiseSource.Checked[k]:=false;
  for k:=0 to cbCruiseInstitute.Count-1 do cbCruiseInstitute.Checked[k]:=false;
  for k:=0 to cbCruisePlatform.Count-1  do cbCruisePlatform.Checked[k]:=false;

  cbCruisePlatform.ItemIndex:=-1;
  cbCruiseCountry.ItemIndex:=-1;
  cbCruiseSource.ItemIndex:=-1;
  cbCruiseInstitute.ItemIndex:=-1;
  cbCruiseProject.ItemIndex:=-1;

  chkCruiseNOTPlatform.Checked:=false;
  chkCruiseNOTCountry.Checked:=false;
  chkCruiseNOTSource.Checked:=false;
  chkCruiseNOTInstitute.Checked:=false;
  chkCruiseNOTProject.Checked:=false;

  seCruiseIDMin.Value:=IDCruiseMin;
  seCruiseIDMax.Value:=IDCruiseMax;

  dtpCruiseDateMin.DateTime:=IBDateMin;
  dtpCruiseDateMax.DateTime:=IBDateMax;

  dtpCruiseDateAddedMin.DateTime:=IBCruiseDateAddedMin;
  dtpCruiseDateAddedMax.DateTime:=IBCruiseDateAddedMax;
  dtpCruiseDateUpdatedMin.DateTime:=IBCruiseDateUpdatedMin;
  dtpCruiseDateUpdatedMax.DateTime:=IBCruiseDateUpdatedMax;
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

procedure Tfrmosmain.iInitialDatabaseClick(Sender: TObject);
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
   frmimport_fdb := Tfrmimport_fdb.Create(Self);
     try
      if not frmimport_fdb.ShowModal = mrOk then exit;
     finally
       frmimport_fdb.Free;
       frmimport_fdb := nil;
     end;
  end else
   if MessageDlg('Please, specify path to Ocean.fdb', mtWarning, [mbOk], 0)=mrOk then
    aSettings.Execute();
end;

procedure Tfrmosmain.iExportASCIIClick(Sender: TObject);
begin
 ExportASCII;
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
frmdm.QCruise.Insert;

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
end;


procedure Tfrmosmain.iSettingsClick(Sender: TObject);
begin
  aSettings.Execute;
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

procedure Tfrmosmain.btnSaveCruiseClick(Sender: TObject);
begin
if frmdm.QCruise.Modified then frmdm.QCruise.Post;


frmdm.QCruise.ApplyUpdates(0);
frmdm.TR.CommitRetaining;

btnSaveCruise.Enabled:=false;
Application.ProcessMessages;
end;


(* Open local database *)
procedure Tfrmosmain.OpenDatabase;
Var
  k:integer;
begin
   try
    frmdm.IBDB.Close(false);
    frmdm.IBDB.DatabaseName:=IBName;
    frmdm.IBDB.Open;
   except
     on E: Exception do
       if MessageDlg(E.Message, mtWarning, [mbOk], 0)=mrOk then exit;
   end;

 (*******************TEMPORARY *********************)
  //CheckDBStructure;
 (*******************TEMPORARY *********************)

  DatabaseInfo;

  for k:=1 to MM.Items.Count-2 do MM.Items[k].Enabled:=true;
  PageControl1.Enabled:=true;
end;


(* gathering info about the database *)
procedure Tfrmosmain.DatabaseInfo;
var
TRt_DB1:TSQLTransaction;
Qt_DB1:TSQLQuery;
TempList:TListBox;

k:integer;
begin

Caption:='OceanShell: '+IBName;
Application.ProcessMessages;


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
         IBDateAddedMin :=FieldByName('StDateAddedMin').AsDateTime;
         IBDateAddedMax :=FieldByName('StDateAddedMax').AsDateTime;
         IBDateUpdatedMin :=FieldByName('StDateUpdatedMin').AsDateTime;
         IBDateUpdatedMax :=FieldByName('StDateUpdatedMax').AsDateTime;

         with sbDatabase do begin
           Panels[1].Text:='LtMin: '+floattostr(IBLatMin);
           Panels[2].Text:='LtMax: '+floattostr(IBLatMax);
           Panels[3].Text:='LnMin: '+floattostr(IBLonMin);
           Panels[4].Text:='LnMax: '+floattostr(IBLonMax);
           Panels[5].Text:='DateMin: '+datetostr(IBDateMin);
           Panels[6].Text:='DateMax: '+datetostr(IBDateMax);
           Panels[7].Text:='Stations: '+inttostr(IBCount);
         end;

         // if there are no saved settings
         if (seIDMin.Value=0) and (seIDMax.Value=0) then begin
           seIDMin.Value:=IDMin;
           seIdMax.Value:=IDMax;
           seLatMin.Value:=IBLatMin;
           seLatMax.Value:=IBLatMax;
           seLonMin.Value:=IBLonMin;
           seLonMax.Value:=IBLonMax;

         //if new database
         if (IDMin<seIDMin.Value) or (IDMax>seIdMax.Value) then begin
           seIDMin.Value:=IDMin;
           seIdMax.Value:=IDMax;
         end;

           dtpDateMin.DateTime:=IBDateMin;
           dtpDateMax.DateTime:=IBDateMax;
           dtpDateAddedMin.DateTime:=IBDateAddedMin;
           dtpDateAddedMax.DateTime:=IBDateAddedMax;
           dtpDateUpdatedMin.DateTime:=IBDateUpdatedMin;
           dtpDateUpdatedMax.DateTime:=IBDateUpdatedMax;
         end;

      end else for k:=1 to 7 do sbDatabase.Panels[k].Text:='---';
    Close;
   end;


   with Qt_DB1 do begin
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
         IDCruiseMin     :=FieldByName('IDMin').AsInteger;
         IDCruiseMax     :=FieldByName('IDMax').AsInteger;
         IBCruiseLatMin  :=FieldByName('StLatMin').AsFloat;
         IBCruiseLatMax  :=FieldByName('StLatMax').AsFloat;
         IBCruiseLonMin  :=FieldByName('StLonMin').AsFloat;
         IBCruiseLonMax  :=FieldByName('StLonMax').AsFloat;
         IBCruiseDateAddedMin   :=FieldByName('StDateAddedMin').AsDateTime;
         IBCruiseDateAddedMax   :=FieldByName('StDateAddedMax').AsDateTime;
         IBCruiseDateUpdatedMin :=FieldByName('StDateUpdatedMin').AsDateTime;
         IBCruiseDateUpdatedMax :=FieldByName('StDateUpdatedMax').AsDateTime;
         IBCruiseStationsTotalMax:=FieldByName('ST_TOTAL_MAX').AsInteger;
         IBCruiseStationsDatabaseMax:=FieldByName('ST_DATABASE_MAX').AsInteger;
         IBCruiseStationsDuplicateMax:=FieldByName('ST_DUPLICATES_MAX').AsInteger;

         if (seCruiseIDMin.Value=0) and (seCruiseIDMax.Value=0) then begin
         seCruiseStationsTotalMax.Value:=IBCruiseStationsTotalMax;
         seCruiseStationsDatabaseMax.Value:=IBCruiseStationsDatabaseMax;
         seCruiseStationsDuplicateMax.Value:=IBCruiseStationsDuplicateMax;

         seCruiseIDMin.Value:=IDCruiseMin;
         seCruiseIDMax.Value:=IDCruiseMax;
         seCruiseLatMin.Value:=IBCruiseLatMin;
         seCruiseLatMax.Value:=IBCruiseLatMax;
         seCruiseLonMin.Value:=IBCruiseLonMin;
         seCruiseLonMax.Value:=IBCruiseLonMax;

         dtpCruiseDateMin.DateTime:=IBDateMin;
         dtpCruiseDateMax.DateTime:=IBDateMax;
         dtpCruiseDateAddedMin.DateTime:=IBCruiseDateAddedMin;
         dtpCruiseDateAddedMax.DateTime:=IBCruiseDateAddedMax;
         dtpCruiseDateUpdatedMin.DateTime:=IBCruiseDateUpdatedMin;
         dtpCruiseDateUpdatedMax.DateTime:=IBCruiseDateUpdatedMax;
         end;
       end;
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

   chkParameters.Visible:=false;
   chkParameters.Items.Clear;
   chkParameters.Items:=ListBox1.Items;
   chkParameters.Visible:=true;

   (* Loading ENTRY list *)
   FetchEntries;

   (* Populating picklists in both grids *)
   PopulatePickLists;

   (* cleaning selection info *)
   for k:=1 to 7 do sbSelection.Panels[k].Text:='---';

 Finally
  TRt_DB1.Commit;
  Qt_DB1.Free;
  TRt_DB1.free;
 end;
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
  aMapAllStations.Enabled:=items_enabled;
  aMapKML.Enabled:=items_enabled;
  aProfilesStationAll.Enabled:=items_enabled;
  aProfilesSelectedAllPlot.Enabled:=items_enabled;
  iStandarddeviationslayers.Enabled:=items_enabled;

  tsSelectedStations.TabVisible:=items_enabled;
  tsSelectedCruises.TabVisible:= not frmdm.QCruise.IsEmpty;

  if not frmdm.QCruise.IsEmpty then
    tsSelectedCruises.Caption:='Selected cruises: '+inttostr(frmdm.QCruise.RecordCount);



  if frmprofile_plot_all_open then begin
    frmprofile_plot_all.Close;
    frmprofile_plot_all:= Tfrmprofile_plot_all.Create(nil);
    frmprofile_plot_all_open:=true;
  end;
end;


procedure Tfrmosmain.FetchEntries;
begin
  with frmdm.QEntry do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT ');
    SQL.Add(' ENTRY.ID, ENTRY.TITLE, ENTRY.DATE_START, ENTRY.DATE_END, ');
    SQL.Add(' ENTRY.STATIONS_AMOUNT, ENTRY.DATE_ADDED, ENTRY.DATE_UPDATED, ');
    SQL.Add(' ENTRY_TYPE.NAME as TYPE_NAME, ENTRY.NOTES ');
    SQL.Add(' FROM ENTRY, ENTRY_TYPE ');
    SQL.Add(' WHERE ENTRY.ENTRY_TYPE_ID=ENTRY_TYPE.ID ');
    SQL.Add(' ORDER by ENTRY.TITLE, ENTRY.DATE_START ');
   Open;
   Last;
   First;
  end;
 // tsMainEntries.Caption:='Entries: ['+inttostr(frmdm.QEntry.RecordCount)+']';
  Application.ProcessMessages;
end;

procedure Tfrmosmain.PopulatePickLists;
Var
  pp:integer;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
  try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   DBGridCruise1.Columns[2].PickList.Clear; //PLATFORM
   DBGridCruise1.Columns[4].PickList.Clear; //SOURCE

   DBGridCruise2.Columns[0].PickList.Clear; //COUNTRY
   DBGridCruise2.Columns[1].PickList.Clear; //INSTITUTE
   DBGridCruise2.Columns[2].PickList.Clear; //PROJECT

   DBGridEntry.Columns[2].PickList.Clear;

   cbPlatform.Clear;
   cbCountry.Clear;
   cbSource.Clear;
   cbInstitute.Clear;
   cbProject.Clear;

    For pp:=1 to 7 do begin
      Qt.Close;
       case pp of
         1: Qt.SQL.Text:=' SELECT DISTINCT NAME FROM PLATFORM ORDER BY NAME ';
         2: Qt.SQL.Text:=' SELECT DISTINCT NAME FROM COUNTRY ORDER BY NAME ';
         3: Qt.SQL.Text:=' SELECT DISTINCT NAME FROM SOURCE ORDER BY NAME ';
         4: Qt.SQL.Text:=' SELECT DISTINCT NAME FROM INSTITUTE ORDER BY NAME ';
         5: Qt.SQL.Text:=' SELECT DISTINCT NAME FROM PROJECT ORDER BY NAME ';
         6: Qt.SQL.Text:=' SELECT DISTINCT NAME FROM ENTRY_TYPE ORDER BY NAME ';
         7: Qt.SQL.Text:=' SELECT DISTINCT NAME FROM INSTRUMENT ORDER BY ID ';
       end;
      Qt.Open;

      while not Qt.Eof do begin
        case pp of
         1: cbPlatform.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
         2: cbCountry.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
         3: cbSource.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
         4: cbInstitute.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
         5: cbProject.AddItem(Qt.Fields[0].AsString, cbUnchecked, true);
         6: DBGridEntry.Columns[2].PickList.Add(Qt.Fields[0].AsString);
         7: chkInstrument.Items.Add(Qt.Fields[0].AsString);
        end;
       Qt.Next;
      end;

      DBGridCruise1.Columns[2].PickList:=cbPlatform.Items;
      DBGridCruise1.Columns[4].PickList:=cbSource.Items;

      DBGridCruise2.Columns[0].PickList:=cbCountry.Items;
      DBGridCruise2.Columns[1].PickList:=cbInstitute.Items;
      DBGridCruise2.Columns[2].PickList:=cbProject.Items;

    end;
    Qt.Close;
    TRt.Commit;
  finally
   Qt.Free;
   TrT.Free;
  end;

   cbCruisePlatform.Items:=cbPlatform.Items;
   cbCruiseCountry.Items:=cbCountry.Items;
   cbCruiseSource.Items:=cbSource.Items;
   cbCruiseInstitute.Items:=cbInstitute.Items;
   cbCruiseProject.Items:=cbProject.Items;

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


procedure Tfrmosmain.iUpdateLastLevelClick(Sender: TObject);
var
  ci1, CurrentID, k:integer;
  Max_LLM, Max_LLD:variant;
begin

try
 CurrentID:=frmdm.Q.FieldByName('ID').AsInteger;
 frmdm.Q.DisableControls;
 frmdm.Q.First;

 k:=0;
 While not frmdm.Q.Eof do begin
   inc(k);

    Max_LLM:=-9;
    Max_LLD:=-9;
    for ci1:=0 to frmosmain.ListBox1.Count-1 do begin
      With frmdm.q1 do begin
       Close;
        SQL.Clear;
        SQL.Add(' Select max(LEV_M) as LLM, max(LEV_DBAR) as LLD from ');
        SQL.Add(frmosmain.ListBox1.Items.Strings[ci1]);
        SQL.Add(' where ID=:pAbsNum ');
        Parambyname('pAbsnum').asInteger:=frmdm.Q.FieldByName('ID').AsInteger;
       Open;
          if not VarIsNull(frmdm.q1.Fields[0].AsVariant) then Max_LLM:=Max(Max_LLM,frmdm.q1.Fields[0].AsFloat);
          if not VarIsNull(frmdm.q1.Fields[1].AsVariant) then Max_LLD:=Max(Max_LLD,frmdm.q1.Fields[1].AsFloat);
       Close;
      end;
    end;

    if Max_LLM=-9 then Max_LLM:=Null;
    if Max_LLD=-9 then Max_LLD:=Null;

    With frmdm.q1 do begin
       Close;
        SQL.Clear;
        SQL.Add(' Update STATION set ');
        SQL.Add(' LASTLEVEL_M=:LLM, ');
        SQL.Add(' LASTLEVEL_DBAR=:LLD ');
        SQL.Add(' where ID=:pAbsNum ');
        Parambyname('pAbsnum').asInteger:=frmdm.Q.FieldByName('ID').AsInteger;
        Parambyname('LLM').Value:=Max_LLM;
        Parambyname('LLD').Value:=Max_LLD;
       ExecSQL;
    end;
    Procedures.ProgressTaskbar(k, frmdm.Q.RecordCount-1);
   frmdm.Q.Next;
 end;
 Procedures.ProgressTaskbar(0, 0);
finally
 frmdm.Q.Refresh;
 frmdm.Q.Locate('ID',CurrentID,[loCaseInsensitive]);
 frmdm.Q.EnableControls;

 showmessage('Last level update completed');
end;
end;


procedure Tfrmosmain.iUpdateCruiseClick(Sender: TObject);
Var
  ID, k : integer;

  TRt:TSQLTransaction;
  Qt, Qt1:TSQLQuery;

  LatMin, LatMax, LonMin, LonMax: real;
  DateMin, DateMax: TDateTime;
  cnt: integer;
begin
   try
    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;

    Qt:=TSQLQuery.Create(self);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

     frmdm.QCruise.DisableControls;
     frmdm.QCruise.First;

     k:=0;
     while not frmdm.QCruise.eof do begin
      inc(k);

      if frmdm.QCruise.FieldByName('SELECTED').AsBoolean=true then begin
        ID:=frmdm.QCruise.FieldByName('ID').AsInteger;

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
          SQL.Add(' count(ID) as cnt ');
          SQL.Add(' FROM STATION ');
          SQL.Add(' where CRUISE_ID=:CR_ID ');
          ParamByName('CR_ID').AsInteger:=ID;
         Open;
           if Qt1.FieldByName('cnt').AsInteger>0 then begin
             LatMin:=Qt1.FieldByName('LatMin').Value;
             LatMax:=Qt1.FieldByName('LatMax').Value;
             LonMin:=Qt1.FieldByName('LonMin').Value;
             LonMax:=Qt1.FieldByName('LonMax').Value;
             DateMin:=Qt1.FieldByName('DateMin').Value;
             DateMax:=Qt1.FieldByName('DateMax').Value;
             cnt:=Qt1.FieldByName('cnt').Value;
           end;
           if Qt1.FieldByName('cnt').AsInteger=0 then begin
             LatMin:=0;
             LatMax:=0;
             LonMin:=0;
             LonMax:=0;
             DateMin:=EncodeDate(1900, 01, 01);
             DateMax:=EncodeDate(1900, 01, 01);
             cnt:=0;
           end;
         Close;
       end;

      with frmdm.q1 do begin
       Close;
        SQL.Clear;
        SQL.Add(' UPDATE CRUISE SET ');
        SQL.Add(' LATITUDE_MIN=:LatMin, ');
        SQL.Add(' LATITUDE_MAX=:LatMax, ');
        SQL.Add(' LONGITUDE_MIN=:LonMin, ');
        SQL.Add(' LONGITUDE_MAX=:LonMax, ');
        SQL.Add(' DATE_START_DATABASE=:DateMin, ');
        SQL.Add(' DATE_END_DATABASE=:DateMax, ');
        SQL.Add(' STATIONS_DATABASE=:cnt ');
        SQL.Add(' WHERE ID=:CR_ID ');
        ParamByName('CR_ID').AsInteger:=ID;
        ParamByName('LatMin').Value:=LatMin;
        ParamByName('LatMax').Value:=LatMax;
        ParamByName('LonMin').Value:=LonMin;
        ParamByName('LonMax').Value:=LonMax;
        ParamByName('DateMin').Value:=DateMin;
        ParamByName('DateMax').Value:=DateMax;
        ParamByName('cnt').Value:=cnt;
       ExecSQL;
      end;

      end; // if SELECTED=true

      Procedures.ProgressTaskbar(k, Qt.RecordCount-1);
      frmdm.QCruise.Next;
     end;

      finally
        Qt.Close;
        Trt.Commit;
        Qt.Free;
        Trt.Free;
        frmdm.TR.CommitRetaining;
      end;

     if MessageDlg('Cruise info was successfuly updated',
      mtInformation, [mbOk], 0)=mrOk then Procedures.ProgressTaskbar(0, 0);
end;


procedure Tfrmosmain.iBottomDepthGEBCOClick(Sender: TObject);
Var
  ID, GEBCO, k: integer;
  Lon, lat: real;

  fname: string;
  ncid:integer;
  start: PArraySize_t;
  sp:array of smallint;
  lat0, lon0, step: real;
begin
   fname:=GlobalSupportPath+PathDelim+'bathymetry'+PathDelim+'GEBCO_2020.nc';

   if not FileExists(fname) then
    if MessageDlg('GEBCO is not found', mtWarning, [mbOk], 0)=mrOk then exit; // if there's no file

   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT ID, LATITUDE, LONGITUDE FROM STATION ');
     SQL.Add(' WHERE BOTTOMDEPTH_GEBCO IS NULL ORDER BY ID ');
    Open;
    Last;
    First;
   end;

   with frmdm.q2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' UPDATE STATION SET ');
     SQL.Add(' BOTTOMDEPTH_GEBCO=:GEBCO ');
     SQL.Add(' WHERE ID=:ID ');
    Prepare;
   end;

   try
    // opening GEBCO_2020.nc
     nc_open(pansichar(fname), NC_NOWRITE, ncid);
     start:=GetMemory(SizeOf(TArraySize_t)*2);

     lat0:=-(89+(59/60)+(525E-1/3600));  // first latitude
     lon0:=-(179+(59/60)+(525E-1/3600)); // first longitude
     step  := 1/240;  // 15"

  k:=0;
  while not frmdm.q1.EOF do begin
   ID :=frmdm.q1.FieldByName('ID').AsInteger;
   Lat:=frmdm.q1.FieldByName('LATITUDE').AsFloat;
   Lon:=frmdm.q1.FieldByName('LONGITUDE').AsFloat;

    // search by indexes
    start^[0]:=abs(trunc((lat0-lat)/step)); // lat index
    start^[1]:=abs(trunc((lon0-lon)/step)); // lon index

    SetLength(sp, 1); // setting an empty array
     nc_get_var1_short(ncid, 2, start^, sp);  // sending request to the file
    GEBCO:=-sp[0]; // getting results

     with frmdm.q2 do begin
       Close;
         ParamByName('ID').AsInteger:=ID;
         ParamByName('GEBCO').AsInteger:=GEBCO;
       ExecSQL;
     end;

   inc(k);
   ProgressTaskbar(k, frmdm.q1.RecordCount);

   if (k mod 10000)=1 then frmdm.TR.CommitRetaining;

   frmdm.q1.Next;
  end;

 ProgressTaskbar(0, 0);
 Showmessage('Bottom depth from GEBCO successfully updated');
finally
 sp:=nil;
 FreeMemory(start);
 nc_close(ncid);  // Close nc file
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

procedure Tfrmosmain.eCruise_IDClick(Sender: TObject);
begin
 {  eCruise_ID.Clear;
   eCruise_PLATFORM.Clear;
   eCruise_COUNTRY.Clear;
   eCruise_SOURCE.Clear;
   eCruise_Project.Clear;
   eCruise_Institute.Clear;
   eCruise_PI.Clear; }
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


procedure Tfrmosmain.DBGridCruise1ColumnSized(Sender: TObject);
begin
    {eCruise_ID.Width:=DBGridCruise1.Columns[0].Width+
                      DBGridCruise1.Columns[1].Width+1;
    eCruise_PLATFORM.Width:=DBGridCruise1.Columns[2].Width;
    eCruise_NUMBER.Width:=DBGridCruise1.Columns[3].Width;
    eCruise_SOURCE.Width:=DBGridCruise1.Columns[4].Width;

    eCruise_COUNTRY.Width:=DBGridCruise2.Columns[0].Width;
    eCruise_Institute.Width:=DBGridCruise2.Columns[1].Width;
    eCruise_Project.Width:=DBGridCruise2.Columns[2].Width;
    eCruise_PI.Width:=DBGridCruise2.Columns[3].Width; }
end;


procedure Tfrmosmain.DBGridEntryColumnSized(Sender: TObject);
begin
  eEntry_ID.Width:=DBGridEntry.Columns[0].Width+
                   DBGridEntry.Columns[1].Width+1;
  eEntry_Type.Width:=DBGridEntry.Columns[2].Width;
  eEntry_Title.Width:=DBGridEntry.Columns[3].Width;
end;

procedure Tfrmosmain.DBGridCruise1PrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
 if ((column.Index=0) and (column.Title.Caption='')) or
    (column.FieldName='ID') or
    (column.FieldName='CRUISE_ID') or
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

procedure Tfrmosmain.DBGridCruise1SelectEditor(Sender: TObject;
  Column: TColumn; var Editor: TWinControl);
begin
    if (Column.Index=2) or (Column.Index=4) then begin
     if (Editor is TCustomComboBox) then
      with Editor as TCustomComboBox do
          Style := csDropDownList;
    end;

  {  if (Column.Index=5) or (Column.Index=6) then begin
     if (Editor is TCustomComboBox) then
       with Editor as TCustomComboBox do
          Style := csDropDownList;
    end; }
end;

procedure Tfrmosmain.DBGridCruise2SelectEditor(Sender: TObject;
  Column: TColumn; var Editor: TWinControl);
begin
    if (Column.Index<=2) then begin
     if (Editor is TCustomComboBox) then
      with Editor as TCustomComboBox do
          Style := csDropDownList;
    end;
end;


procedure Tfrmosmain.DBGridCruise1EditingDone(Sender: TObject);
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


     if Par='SOURCE' then begin
     With Qt do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM '+Par+' WHERE NAME=:NAME ');
       ParamByName('NAME').AsString:=frmdm.QCruise.FieldByName(Par).AsString;
      Open;
       frmdm.QCruise.Edit;
       frmdm.QCruise.FieldByName(Par+'_ID').AsInteger:=Qt.Fields[0].AsInteger;
       //frmdm.QCruise.Post;
      Close;
     end;
     end;

     if Par='PLATFORM' then begin
      With Qt do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT PLATFORM.ID, COUNTRY.NAME FROM ');
       SQL.ADD(' PLATFORM, COUNTRY WHERE ');
       SQL.Add(' PLATFORM.COUNTRY_ID=COUNTRY.ID AND ');
       SQL.ADD(' PLATFORM.NAME=:NAME');
       ParamByName('NAME').AsString:=frmdm.QCruise.FieldByName(Par).AsString;
      Open;
       frmdm.QCruise.Edit;
       frmdm.QCruise.FieldByName(Par+'_ID').AsInteger:=Qt.Fields[0].AsInteger;
       frmdm.QCruise.FieldByName('COUNTRY').AsString:=Qt.Fields[1].AsString;
       //frmdm.QCruise.Post;
      Close;
     end;
     end;
    Finally
     Qt.Close;
     TRt.Commit;
     Qt.Free;
    end;
  end;
end;


procedure Tfrmosmain.DBGridCruise2EditingDone(Sender: TObject);
Var
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
 par:string;
begin
  par:='';
  Case TDBGrid(Sender).SelectedColumn.Index of
    1: par:='INSTITUTE';
    2: par:='PROJECT';
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
      Close;
     end;
    Finally
     Qt.Close;
     TRt.Commit;
     Qt.Free;
    end;
  end;
end;

procedure Tfrmosmain.GetIDListCruise(Var id_str:string);
Var
 id_old: integer;
begin
{ id_str:='';

 id_old:=frmdm.QCruise.FieldByName('ID').AsInteger;
 RecListCruise.CurrentRowSelected:=true;
 try
   frmdm.QCruise.DisableControls;
   frmdm.QCruise.First;
   while not frmdm.QCruise.EOF do begin
    if RecListCruise.CurrentRowSelected then
      id_str:=id_str+','+IntToStr(frmdm.QCruise.FieldByName('ID').AsInteger);
     frmdm.QCruise.Next;
   end;
 finally
   id_str:=copy(id_str, 2, length(id_str));
   frmdm.QCruise.Locate('ID', ID_old, []);
   frmdm.QCruise.EnableControls;
 end;     }
end;

procedure Tfrmosmain.GetIDListEntry(Var id_str:string);
Var
 id_old: integer;
begin
{ id_old:=frmdm.QEntry.FieldByName('ID').AsInteger;
 RecListEntry.CurrentRowSelected:=true;

 id_str:='';
 try
   frmdm.QEntry.DisableControls;
   frmdm.QEntry.First;
   while not frmdm.QEntry.EOF do begin
    if RecListEntry.CurrentRowSelected then
      id_str:=id_str+','+IntToStr(frmdm.QEntry.FieldByName('ID').AsInteger);
     frmdm.QEntry.Next;
   end;
 finally
   id_str:=copy(id_str, 2, length(id_str));
   frmdm.QEntry.Locate('ID', ID_old, []);
   frmdm.QEntry.EnableControls;
 end;  }
end;

procedure Tfrmosmain.GetIDListStation(Var id_str:string);
Var
 id_old: integer;
begin
{ id_old:=frmdm.Q.FieldByName('ID').AsInteger;
 RecListStation.CurrentRowSelected:=true;

 id_str:='';
 try
   frmdm.Q.DisableControls;
   frmdm.Q.First;
   while not frmdm.Q.EOF do begin
    if RecListStation.CurrentRowSelected then
      id_str:=id_str+','+IntToStr(frmdm.Q.FieldByName('ID').AsInteger);
     frmdm.Q.Next;
   end;
 finally
   id_str:=copy(id_str, 2, length(id_str));
   frmdm.Q.Locate('ID', ID_old, []);
   frmdm.Q.EnableControls;
 end;    }
end;

procedure Tfrmosmain.DBGridCruise1TitleClick(Column: TColumn);
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


procedure Tfrmosmain.DBGridCruise2TitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(frmdm.QCruise, Column.FieldName);
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

procedure Tfrmosmain.DBGridEntryUserCheckboxState(Sender: TObject;
  Column: TColumn; var AState: TCheckboxState);
begin
 // if RecListEntry.CurrentRowSelected then AState := cbChecked else AState := cbUnchecked;
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
     id_old:=frmdm.Q.FieldByName('ID').AsInteger;
  //   check_old:=RecListStation.CurrentRowSelected;
     try
       frmdm.Q.DisableControls;
       frmdm.Q.First;
       while not frmdm.Q.EOF do begin
     //   RecListStation.CurrentRowSelected := not check_old;
         frmdm.Q.Next;
       end;
     finally
       frmdm.Q.Locate('ID', ID_old, []);
       frmdm.Q.EnableControls;
     end;
  end;

  if Column.Index>0 then sortbufds.SortBufDataSet(frmdm.Q, Column.FieldName);

end;

procedure Tfrmosmain.DBGridCruise1UserCheckboxState(Sender: TObject;
  Column: TColumn; var AState: TCheckboxState);
begin
 // if RecListCruise.CurrentRowSelected then AState := cbChecked else AState := cbUnchecked;
end;


procedure Tfrmosmain.DBGridCruise1CellClick(Column: TColumn);
begin
  //if Column.Index=0 then
  //  RecListCruise.CurrentRowSelected := not RecListCruise.CurrentRowSelected;
  if frmprofile_plot_all_open=true then CDSNavigation;
end;

procedure Tfrmosmain.DBGridEntryCellClick(Column: TColumn);
begin
  if Column.Index=0 then
  //  RecListEntry.CurrentRowSelected := not RecListEntry.CurrentRowSelected;
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

    (* STATION search settings *)
    Ini.WriteFloat   ( 'osmain', 'station_latmin',   seLatMin.Value);
    Ini.WriteFloat   ( 'osmain', 'station_latmax',   seLatMax.Value);
    Ini.WriteFloat   ( 'osmain', 'station_lonmin',   seLonMin.Value);
    Ini.WriteFloat   ( 'osmain', 'station_lonmax',   seLonMax.Value);
    Ini.WriteBool    ( 'osmain', 'station_period',   chkPeriod.Checked);
    Ini.WriteInteger ( 'osmain', 'station_idmin',    seIDMin.Value);
    Ini.WriteInteger ( 'osmain', 'station_idmax',    seIDMax.Value);
    Ini.WriteString  ( 'osmain', 'station_platform', cbPlatform.Text);
    Ini.WriteString  ( 'osmain', 'station_country',  cbCountry.Text);
    Ini.WriteString  ( 'osmain', 'station_source',   cbSource.Text);
    Ini.WriteString  ( 'osmain', 'station_institute',cbInstitute.Text);
    Ini.WriteString  ( 'osmain', 'station_project',  cbProject.Text);
    Ini.WriteDateTime( 'osmain', 'station_datemin',  dtpDateMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_datemax',  dtpDateMax.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateaddedmin',   dtpDateAddedMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateaddedmax',   dtpDateAddedMax.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateupdatedmin', dtpDateUpdatedMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'station_dateupdatedmax', dtpDateUpdatedMax.DateTime);

    (* CRUISE search settings *)
    Ini.WriteFloat   ( 'osmain', 'cruise_latmin',   seCruiseLatMin.Value);
    Ini.WriteFloat   ( 'osmain', 'cruise_latmax',   seCruiseLatMax.Value);
    Ini.WriteFloat   ( 'osmain', 'cruise_lonmin',   seCruiseLonMin.Value);
    Ini.WriteFloat   ( 'osmain', 'cruise_lonmax',   seCruiseLonMax.Value);
    Ini.WriteInteger ( 'osmain', 'cruise_idmin',    seCruiseIDMin.Value);
    Ini.WriteInteger ( 'osmain', 'cruise_idmax',    seCruiseIDMax.Value);
    Ini.WriteString  ( 'osmain', 'cruise_platform', cbCruisePlatform.Text);
    Ini.WriteString  ( 'osmain', 'cruise_country',  cbCruiseCountry.Text);
    Ini.WriteString  ( 'osmain', 'cruise_source',   cbCruiseSource.Text);
    Ini.WriteString  ( 'osmain', 'cruise_institute',cbCruiseInstitute.Text);
    Ini.WriteString  ( 'osmain', 'cruise_project',  cbCruiseProject.Text);
    Ini.WriteDateTime( 'osmain', 'cruise_datemin',  dtpCruiseDateMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_datemax',  dtpCruiseDateMax.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_dateaddedmin',   dtpCruiseDateAddedMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_dateaddedmax',   dtpCruiseDateAddedMax.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_dateupdatedmin', dtpCruiseDateUpdatedMin.DateTime);
    Ini.WriteDateTime( 'osmain', 'cruise_dateupdatedmax', dtpCruiseDateUpdatedMax.DateTime);

    (* cruise table columns *)
    Ini.WriteInteger( 'osmain', 'pCruiseNotes_Width',   DBMemoCruises.width);
    Ini.WriteInteger( 'osmain', 'pCruiseBottom_Height', DBGridCruise2.Height);
    With DBGridCruise1 do begin
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
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col10', Columns[10].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col11', Columns[11].Width);
    /// Ini.WriteInteger( 'osmain', 'DBGridCruise_Col12', Columns[12].Width);
    // Ini.WriteInteger( 'osmain', 'DBGridCruise_Col13', Columns[13].Width);
    end;
    With DBGridCruise2 do begin
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col12', Columns[0].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col13', Columns[1].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col14', Columns[2].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col15', Columns[3].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col16', Columns[4].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col17', Columns[5].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col18', Columns[6].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col19', Columns[7].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col20', Columns[8].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col21', Columns[9].Width);
     Ini.WriteInteger( 'osmain', 'DBGridCruise_Col22', Columns[10].Width);
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
     Ini.WriteInteger( 'osmain', 'DBGridEntry_Col08',  Columns[8].Width);
    end;

    with DBGridStation1 do begin
     Ini.writeInteger( 'osmain', 'DBGridStation1_Height', Height);
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
    end;

    with DBGridStation2 do begin
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col00',  Columns[0].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col01',  Columns[1].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col02',  Columns[2].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col03',  Columns[3].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col04',  Columns[4].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col05',  Columns[5].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col06',  Columns[6].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col07',  Columns[7].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col08',  Columns[8].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col09',  Columns[9].Width );
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col10',  Columns[10].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col11',  Columns[11].Width);
     Ini.writeInteger( 'osmain', 'DBGridStation2_Col12',  Columns[12].Width);
    end;


    for k:=0 to cgQCFlag.Items.Count-1 do
     Ini.WriteBool( 'osmain', 'QCF'+inttostr(k), cgQCFlag.Checked[k]);

   finally
     Ini.Free;
   end;
end;

procedure Tfrmosmain.FormDestroy(Sender: TObject);
begin
 { RecListCruise.Free;
  RecListEntry.Free;
  RecListStation.Free;}

  Source_unq.Free;

  if frmmap_open then frmmap.Close;
  if frmprofile_station_all_open then frmprofile_station_all.Close;
  if frmprofile_station_single_open then frmprofile_station_single.Close;
  if frmprofile_plot_all_open then frmprofile_plot_all.Close;
  if frmparameters_list_open then frmparameters_list.Close;
end;

end.


