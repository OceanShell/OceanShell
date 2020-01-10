unit osmain;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  SysUtils, Variants, Classes, Graphics, Controls, Forms, ComCtrls, LCLType,
  Menus, Dialogs, ActnList, StdCtrls, INIFiles, ExtCtrls, DateUtils, sqldb, DB,
  Buttons, DBGrids, Spin, DateTimePicker, Process, Math;

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
    aMapSelectedStation: TAction;
    aProfilesStationAll: TAction;
    aMapKML: TAction;
    aOpenDatabase: TAction;
    aMapAllStations: TAction;
    AL1: TActionList;
    btnadd: TToolButton;
    btncancel: TToolButton;
    btndelete: TToolButton;
    btnFastAccessOpenMap: TToolButton;
    btnsave: TToolButton;
    btnSelection: TButton;
    chkPeriod: TCheckBox;
    dtpDateMin: TDateTimePicker;
    dtpDateMax: TDateTimePicker;
    DS: TDataSource;
    DBGridPlatform: TDBGrid;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    iProfilesAll: TMenuItem;
    lbResetArea: TLabel;
    lbResetDates: TLabel;
    MenuItem2: TMenuItem;
    iLoad_WOD18: TMenuItem;
    iLoad_WOD: TMenuItem;
    iMap: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    Panel1: TPanel;
    PM1: TPopupMenu;
    sbDatabase: TStatusBar;
    sbSelection: TStatusBar;
    seIDMax: TSpinEdit;
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
    seIDMin: TSpinEdit;
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
    ToolBar1: TToolBar;
    tbFastAccess: TToolBar;
    ToolButton1: TToolButton;
    btnFastAccessOpenDB: TToolButton;
    tsMainSelect: TTabSheet;
    tsMainSelectAdvanced: TTabSheet;
    tsMainData: TTabSheet;

    procedure aMapAllStationsExecute(Sender: TObject);
    procedure aMapKMLExecute(Sender: TObject);
    procedure aMapSelectedStationExecute(Sender: TObject);
    procedure aOpenDatabaseExecute(Sender: TObject);
    procedure aProfilesStationAllExecute(Sender: TObject);
    procedure btnSelectionClick(Sender: TObject);
    procedure DBGridPlatformCellClick(Column: TColumn);
    procedure DBGridPlatformKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGridPlatformTitleClick(Column: TColumn);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure iAboutClick(Sender: TObject);
    procedure iDBStatisticsClick(Sender: TObject);
    procedure iKnowledgeDBOpenClick(Sender: TObject);
    procedure iLoadARGOClick(Sender: TObject);
    procedure iLoadITPClick(Sender: TObject);
    procedure iLoad_GLODAP_2019_v2_productClick(Sender: TObject);
    procedure iLoad_WOD18Click(Sender: TObject);
    procedure iLoad_WODClick(Sender: TObject);
    procedure iSettingsClick(Sender: TObject);
    procedure iNewDatabaseClick(Sender: TObject);
    procedure lbResetAreaClick(Sender: TObject);
    procedure lbResetDatesClick(Sender: TObject);


  private

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

  IBLatMin,IBLatMax,IBLonMin,IBLonMax,SLatMin,SLatMax,SLonMin,SLonMax:Real;
  IBDateMin, IBDateMax, SDateMin, SDateMax :TDateTime;
  IBCount, SCount, IDMin, IDMax:Integer; //number od stations in database and selection


  NavigationOrder:boolean=true; //Stop navigation until all modules responded

  SLatP_arr:array[0..20000] of real;
  SLonP_arr:array[0..20000] of real;
  Length_arr:integer;

  frmcodes_open, frmcodesQC_open, frmparametersall_open, frmmap_open:boolean;


const
   NC_NOWRITE   = 0;    // file for reading
   NC_WRITE     = 1;    // file for writing
   NC_GLOBAL    = -1;   // global attributes ID
   NC_MAX_NAME  = 1024; // value from netcdf.h
   NC_UNLIMITED = 0;
   WS_EX_STATICEDGE = $20000;
   buf_len      = 3000;

implementation


uses dm, oscreatenewdb, settings, codes, osabout, sortbufds,
(* loading data *)
  osload_itp,
  osload_GLODAP_2019_v2_product,
  osload_WOD18,
  loadwod,
(* export *)
(* QC *)
(* tools *)
  osmap,
  osmap_kml,
  osparameters_all,

(* statistics *)
  osstatistics
;

{$R *.lfm}


procedure Tfrmosmain.FormShow(Sender: TObject);
Var
  Ini:TINIFile;
begin
IBName:='';

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

 (* Check for existing essencial program folders *)
  Ini := TIniFile.Create(IniFileName);
  try
    Top   :=Ini.ReadInteger( 'osmain', 'top',    50);
    Left  :=Ini.ReadInteger( 'osmain', 'left',   50);
    Width :=Ini.ReadInteger( 'osmain', 'width',  900);
    Height:=Ini.ReadInteger( 'osmain', 'weight', 500);

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

 (* flags on open forms *)
  frmcodes_open:=false; frmcodesQC_open:=false; frmparametersall_open:=false;
  frmmap_open:=false;

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
//i, k, fl:integer;
SSYearMin,SSYearMax,SSMonthMin,SSMonthMax,SSDayMin,SSDayMax :Word;
{NotCondCountry, NotCondVessel, NotCondSource, SBordersFile, str, buf_str:string;
NotCondCruise, NotCondInstr, NotCondOrigin, NotCondCountryC, NotCondVesselC, instr:string;
MinDay, MaxDay, cnt:integer;
Lat, Lon:real; }
time0, time1:TDateTime;
begin
DecodeDate(dtpDateMin.Date, SSYearMin, SSMonthMin, SSDayMin);
DecodeDate(dtpDateMax.Date, SSYearMax, SSMonthMax, SSDayMax);

//Time0:=now;

 with frmdm.Q do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT ');
    SQL.Add(' ID, LATITUDE, LONGITUDE, DATEANDTIME, BOTTOMDEPTH, ');
    SQL.Add(' LASTLEVEL_M, LASTLEVEL_DBAR, CRUISE_ID, INSTRUMENT_ID, ');
    SQL.Add(' ST_NUMBER_ORIGIN, ST_ID_ORIGIN, CAST_NUMBER, QCFLAG, ');
    SQL.Add(' STVERSION, DUPLICATE, MERGED, ACCESSION_NUMBER, ');
    SQL.Add(' DATE_ADDED, DATE_UPDATED ');
 {   SQL.Add(' max(LATITUDE) as LatMax, min(LATITUDE) as LatMin, ');
    SQL.Add(' max(LONGITUDE) as LonMax, min(LONGITUDE) as LonMin, ');
    SQL.Add(' max(DATEANDTIME) as DateMax,  min(DATEANDTIME) as DateMin '); }
    SQL.Add(' FROM STATION ');
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

    SQL.Add(' ORDER BY DATEANDTIME ' );

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

// time1:=now;

// showmessage(dateTimetostr(time1-time0));

// SelectionInfo;
end;


procedure Tfrmosmain.lbResetAreaClick(Sender: TObject);
begin
  seLatMin.Value:=IBLatMin;
  seLatMax.Value:=IBLatMax;
  seLonMin.Value:=IBLonMin;
  seLonMax.Value:=IBLonMax;
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
if (ID=0) or (NavigationOrder=false) then exit;

 If NavigationOrder=true then begin
  NavigationOrder:=false; //blocking everthing until previous operations have been completed
     if frmmap_open     =true then frmmap.ChangeID;
     if frmparametersall_open  =true then frmparametersall.ShowAllProf(ID);
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


procedure Tfrmosmain.DBGridPlatformCellClick(Column: TColumn);
begin
   CDSNavigation;
end;

procedure Tfrmosmain.DBGridPlatformKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key=VK_UP) or (key=VK_DOWN) then CDSNavigation;
end;


procedure Tfrmosmain.DBGridPlatformTitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(frmdm.Q, Column.FieldName);
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
  if frmparametersall_open=true then frmparametersall.SetFocus else
     begin
       frmparametersall := Tfrmparametersall.Create(Self);
       frmparametersall.Show;
     end;
  frmparametersall_open:=true;
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

     SCount   :=frmdm.Q.RecordCount;
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
  //iMapKML.Enabled:=items_enabled;
  aMapAllStations.Enabled:=items_enabled;
  aMapKML.Enabled:=items_enabled;
  aProfilesStationAll.Enabled:=items_enabled;
end;


procedure Tfrmosmain.ItemsVisibility;
begin
 btnSelection.Enabled:=true;
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
   finally
     Ini.Free;
   end;
end;


end.


