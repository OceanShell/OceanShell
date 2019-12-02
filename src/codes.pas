unit codes;

{$mode objfpc}{$H+}

interface

uses
  Windows, lclintf, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, ExtCtrls, Menus, sqldb, DB, sortbufds,
  DBGrids, DBCtrls;

type

  { Tfrmcodes }

  Tfrmcodes = class(TForm)
    btnadd: TToolButton;
    btnsave: TToolButton;
    btndelete: TToolButton;
    btnUpdateQC: TBitBtn;
    cbCruise_Institute: TComboBox;
    cbCruise_Project: TComboBox;
    cbCruise_PI: TComboBox;
    DBGridCruise: TDBGrid;
    DBGridCruiseWOD: TDBGrid;
    DBGridCruiseGLODAP: TDBGrid;
    DBGridUnits: TDBGrid;
    DBGridPI: TDBGrid;
    DBGridPlatform: TDBGrid;
    DBGridCountry: TDBGrid;
    DBGridProject: TDBGrid;
    DBGridInstitute: TDBGrid;
    DBGridInstrument: TDBGrid;
    DBGridSource: TDBGrid;
    DBGridQCFlag: TDBGrid;
    DS: TDataSource;
    eCruiseGLODAP_PI: TEdit;
    eCruiseWOD_COUNTRYNAME: TEdit;
    eCruiseWOD_WMO: TEdit;
    eCruiseWOD_WOD: TEdit;
    eCruiseWOD_ID: TEdit;
    eCruiseGLODAP_ID: TEdit;
    eCruiseGLODAP_NUMBER: TEdit;
    eCruiseWOD_PLATFORMNAME: TEdit;
    eCruiseGLODAP_PLATFORMNAME: TEdit;
    eCruiseWOD_Institute: TEdit;
    eCruiseGLODAP_COUNTRYNAME: TEdit;
    eCruise_WOD: TEdit;
    eCruiseGLODAP_EXPOCODE: TEdit;
    eCruise_SOURCENAME: TEdit;
    ePIWOD_ID: TEdit;
    ePIWOD_Name: TEdit;
    eCruise_DATEEND: TEdit;
    eCruise_ID: TEdit;
    eCruise_DATESTART: TEdit;
    eCruise_STATIONAMOUNT: TEdit;
    eCruise_COUNTRYNAME: TEdit;
    eCruise_PLATFORMNAME: TEdit;
    eCruise_NUMBER: TEdit;
    eProject_ID: TEdit;
    eInstitute_ID: TEdit;
    eInstrument_ID: TEdit;
    eQCFlag_SOURCENAME: TEdit;
    eUnits_ID: TEdit;
    eInstrument_Name: TEdit;
    eSource_ID: TEdit;
    eQCFlag_ID: TEdit;
    eUnits_Name: TEdit;
    eProject_WOD: TEdit;
    eInstitute_NODC: TEdit;
    eInstitute_WOD: TEdit;
    eProject_Name: TEdit;
    eInstitute_Name: TEdit;
    ePlatform_NameNative: TEdit;
    ePlatform_ID: TEdit;
    eCountry_ID: TEdit;
    eInstrument_WOD: TEdit;
    eSource_NAME: TEdit;
    eQCFlag_SourceFlag: TEdit;
    eQCFlag_ODBFlag: TEdit;
    imgFlagPlatform: TImage;
    ImgFlagInstitute: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbCountryPlatform: TLabel;
    lbCountryInstitute: TLabel;
    mNotesCruise: TMemo;
    mNotesCruiseGLODAP: TMemo;
    mNotesInstitute: TMemo;
    mNotesUnits: TMemo;
    mNotesProject: TMemo;
    mNotesInstrument: TMemo;
    mNotesSource: TMemo;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    Panel17: TPanel;
    Panel18: TPanel;
    Panel19: TPanel;
    Panel2: TPanel;
    ePlatform_Name: TEdit;
    Panel20: TPanel;
    Panel21: TPanel;
    Panel22: TPanel;
    Panel23: TPanel;
    Panel24: TPanel;
    Panel25: TPanel;
    Panel26: TPanel;
    Panel27: TPanel;
    Panel28: TPanel;
    Panel29: TPanel;
    Panel3: TPanel;
    ePlatform_NODC: TEdit;
    Panel30: TPanel;
    pCruiseGLODAP: TPanel;
    Panel4: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    pCruiseWOD: TPanel;
    Q: TSQLQuery;
    Splitter1: TSplitter;
    PageControl1: TPageControl;
    Splitter2: TSplitter;
    tbCruiseWOD: TTabSheet;
    tbCruiseGLODAP: TTabSheet;
    tbInstrument: TTabSheet;
    tbQCFlag: TTabSheet;
    tbUnits: TTabSheet;
    tbSource: TTabSheet;
    tbPlatform: TTabSheet;
    tbCountry: TTabSheet;
    Panel5: TPanel;
    Panel6: TPanel;
    eCountry_Name: TEdit;
    eCountry_ISO: TEdit;
    ePlatform_WOD: TEdit;
    Panel1: TPanel;
    mNotesICES: TMemo;
    mNotesPlatform: TMemo;
    ePlatform_IMO: TEdit;
    ePlatform_Callsign: TEdit;
    mNotesWOD: TMemo;
    Splitter3: TSplitter;
    tbPI_WOD: TTabSheet;
    tbProject: TTabSheet;
    tbInstitute: TTabSheet;
    tbCruise: TTabSheet;
    ToolBar1: TToolBar;
    btncancel: TToolButton;
    ToolButton1: TToolButton;

    procedure btnUpdateQCClick(Sender: TObject);
    procedure cbCruise_ProjectDropDown(Sender: TObject);
    procedure DBGridPlatformKeyPress(Sender: TObject; var Key: char);
    procedure eCruiseGLODAP_COUNTRYNAMEChange(Sender: TObject);
    procedure eCruiseGLODAP_EXPOCODEChange(Sender: TObject);
    procedure eCruiseGLODAP_NUMBERChange(Sender: TObject);
    procedure eCruiseGLODAP_PLATFORMNAMEChange(Sender: TObject);
    procedure ePlatform_IDClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure mNotesPlatformKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PageControl1Change(Sender: TObject);
    procedure QAfterEdit(DataSet: TDataSet);
    procedure QAfterScroll(DataSet: TDataSet);

    procedure btnaddClick(Sender: TObject);
    procedure btndeleteClick(Sender: TObject);
    procedure btncancelClick(Sender: TObject);
    procedure btnsaveClick(Sender: TObject);

    procedure DBGridPlatformCellClick(Column: TColumn);
    procedure DBGridPlatformKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGridPlatformTitleClick(Column: TColumn);
    procedure DBGridCountryTitleClick(Column: TColumn);

    procedure ePlatform_NameNativeChange(Sender: TObject);
    procedure ePlatfo(Sender: TObject);
    procedure ePlatform_(Sender: TObject);
    procedure eCountry_ISOChange(Sender: TObject);


  private
    { Private declarations }
    procedure Navigation;
    procedure ResizeColumns(Sender: TObject);

    procedure SearchID(Sender:TObject);
    procedure SearchNAME(Sender:TObject);
    procedure SearchSOURCENAME(Sender:TObject);
    procedure SearchPI(Sender:TObject);
    procedure SearchNODC(Sender:TObject);
    procedure SearchWOD(Sender:TObject);
  public
    { Public declarations }
  end;

var
  frmcodes: Tfrmcodes;
  CodesTblName: string; //Global active table name

implementation

{$R *.lfm}

uses osmain, dm, codesupdateqc;

procedure Tfrmcodes.FormShow(Sender: TObject);
begin
 PageControl1.ActivePageIndex:=0;
 PageControl1.OnChange(self);

 ResizeColumns(self);

 // Assigning procedures for fast search
 (* ID *)
 ePlatform_ID.OnChange     := @SearchID;
 eCruise_ID.OnChange       := @SearchID;
 eCruiseWOD_ID.OnChange    := @SearchID;
 eCruiseGLODAP_ID.OnChange := @SearchID;
 eCountry_ID.OnChange      := @SearchID;
 eSource_ID.OnChange       := @SearchID;
 ePIWOD_ID.OnChange        := @SearchID;
 eProject_ID.OnChange      := @SearchID;
 eInstitute_ID.OnChange    := @SearchID;
 eInstrument_ID.OnChange   := @SearchID;
 eUnits_ID.OnChange        := @SearchID;
 eQCFlag_ID.OnChange       := @SearchID;

 (* NAME *)
 ePlatform_NAME.OnChange   := @SearchNAME;
 eCountry_NAME.OnChange    := @SearchNAME;
 eSource_NAME.OnChange     := @SearchNAME;
 ePIWOD_NAME.OnChange      := @SearchNAME;
 eProject_NAME.OnChange    := @SearchNAME;
 eInstitute_NAME.OnChange  := @SearchNAME;
 eInstrument_NAME.OnChange := @SearchNAME;
 eUnits_NAME.OnChange      := @SearchNAME;


 (* SOURCE *)
 eCruise_SOURCENAME.OnChange := @SearchSOURCENAME;
 eQCFlag_SOURCENAME.OnChange := @SearchSOURCENAME;

 (* PI *)
 eCruiseGLODAP_PI.OnChange := @SearchPI;

 (* NODC *)
 ePlatform_NODC.OnChange  := @SearchNODC;
 eInstitute_NODC.OnChange := @SearchNODC;

 (* WOD*)
 ePlatform_WOD.OnChange   := @SearchWOD;
 eCruise_WOD.OnChange     := @SearchWOD;
 eProject_WOD.OnChange    := @SearchWOD;
 eInstitute_WOD.OnChange  := @SearchWOD;
 eInstrument_WOD.OnChange := @SearchWOD;


 (* Procedures for resizing *)
 DBGridPlatform.OnColumnSized     := @ResizeColumns;
 DBGridCruise.OnColumnSized       := @ResizeColumns;
 DBGridCruiseGLODAP.OnColumnSized := @ResizeColumns;
 DBGridCruiseWOD.OnColumnSized    := @ResizeColumns;
 DBGridCountry.OnColumnSized      := @ResizeColumns;
 DBGridSource.OnColumnSized       := @ResizeColumns;
 DBGridPI.OnColumnSized           := @ResizeColumns;
 DBGridProject.OnColumnSized      := @ResizeColumns;
 DBGridInstitute.OnColumnSized    := @ResizeColumns;
 DBGridInstrument.OnColumnSized   := @ResizeColumns;
 DBGridUnits.OnColumnSized        := @ResizeColumns;
 DBGridQCFlag.OnColumnSized       := @ResizeColumns;
end;


procedure Tfrmcodes.PageControl1Change(Sender: TObject);
begin
 if Q.Active then btnsave.onClick(Self);

 With Q do begin
   Filter:='';
   Filtered:=false;
   SQL.text:='';
   Close;
   ClearIndexes;
 end;

 CodesTblName:='';
 case PageControl1.ActivePageIndex of
  0: begin
       CodesTblName:='PLATFORM';
       Q.SQL.text:='Select ID, NODC_CODE, WOD_ID, IMO_ID, CALLSIGN, NAME, '+
                   'NAME_NATIVE FROM PLATFORM ORDER BY NAME';
     end;
  1: begin
       CodesTblName:='CRUISE';
       Q.SQL.text:='Select CRUISE.ID, CRUISE.WOD_ID, PLATFORM.NAME as PLATFORMNAME, '+
                   'COUNTRY.NAME as COUNTRYNAME, CRUISE.CRUISE_NUMBER, '+
                   'CRUISE.DATE_START, CRUISE.DATE_END, CRUISE.STATIONS_AMOUNT, '+
                   'SOURCE.NAME AS SOURCENAME '+
                   'FROM CRUISE, PLATFORM, COUNTRY, SOURCE WHERE '+
                   'CRUISE.PLATFORM_ID=PLATFORM.ID AND '+
                   'CRUISE.COUNTRY_ID=COUNTRY.ID AND '+
                   'CRUISE.SOURCE_ID=SOURCE.ID '+
                   'ORDER BY CRUISE.DATE_START, PLATFORM.NAME';
     end;
  2: begin
       CodesTblName:='CRUISE_WOD';
       Q.SQL.text:='Select CRUISE_WOD.ID, PLATFORM.WOD_ID as PLATFORM_WOD, '+
                   'PLATFORM.NAME as PLATFORMNAME, CRUISE_WOD.COUNTRY_ID, '+
                   'COUNTRY.ISO3166_CODE as ISO, COUNTRY.NAME as COUNTRYNAME, '+
                   'CRUISE_WOD.INSTITUTE_ID, '+
                   'INSTITUTE.NAME as INSTITUTENAME, CRUISE_WOD.DATE_START, '+
                   'CRUISE_WOD.DATE_END, CRUISE_WOD.STATIONS_AMOUNT, '+
                   'CRUISE_WOD.WOD_CODE, CRUISE_WOD.WMO_CODE '+
                   'FROM CRUISE_WOD, PLATFORM, COUNTRY, INSTITUTE WHERE '+
                   'CRUISE_WOD.PLATFORM_ID=PLATFORM.ID AND '+
                   'CRUISE_WOD.COUNTRY_ID=COUNTRY.ID AND '+
                   'CRUISE_WOD.INSTITUTE_ID=INSTITUTE.ID '+
                   'ORDER BY CRUISE_WOD.DATE_START, PLATFORM.NAME';
     end;
  3: begin
         CodesTblName:='CRUISE_GLODAP';
         Q.SQL.text:='Select CRUISE_GLODAP.ID, CRUISE_GLODAP.EXPOCODE, '+
                     'PLATFORM.NAME as PLATFORMNAME, CRUISE_GLODAP.PI, '+
                     'COUNTRY.NAME as COUNTRYNAME, CRUISE_GLODAP.CRUISE_NUMBER, '+
                     'CRUISE_GLODAP.DATE_START, CRUISE_GLODAP.DATE_END, '+
                     'CRUISE_GLODAP.STATIONS_AMOUNT '+
                     'FROM CRUISE_GLODAP, PLATFORM, COUNTRY WHERE '+
                     'CRUISE_GLODAP.PLATFORM_ID=PLATFORM.ID and '+
                     'CRUISE_GLODAP.COUNTRY_ID=COUNTRY.ID '+
                     'ORDER BY CRUISE_GLODAP.ID';
     end;
  4: begin
       CodesTblName:='COUNTRY';
       Q.SQL.text:='Select ID, ISO3166_CODE, NAME '+
                   'FROM COUNTRY ORDER BY NAME';
     end;
  5: begin
       CodesTblName:='SOURCE';
       Q.SQL.text:='Select ID, ID_MIN, ID_MAX, NAME '+
                   'FROM SOURCE ORDER BY ID';
     end;
  6: begin
       CodesTblName:='PI_WOD';
       Q.SQL.text:='Select PI_WOD.ID, PI_WOD.NAME '+
                   'FROM PI_WOD ORDER BY ID';
     end;
  7: begin
       CodesTblName:='PROJECT';
       Q.SQL.text:='Select ID, WOD_ID, NAME '+
                   'FROM PROJECT ORDER BY NAME';
     end;
  8: begin
       CodesTblName:='INSTITUTE';
       Q.SQL.text:='Select ID, WOD_ID, NODC_CODE, NAME '+
                   'FROM INSTITUTE ORDER BY NAME';
     end;
  9: begin
       CodesTblName:='INSTRUMENT';
       Q.SQL.text:='Select ID, WOD_ID, NAME '+
                   'FROM INSTRUMENT ORDER BY WOD_ID';
  end;
  10: begin
       CodesTblName:='UNITS';
       Q.SQL.text:='Select ID, NAME_SHORT, NAME, SCALE, LENGTH '+
                   'FROM UNITS ORDER BY ID';
  end;
  11: begin
       CodesTblName:='QCFLAG';
       Q.SQL.text:='Select QCFLAG.ID, SOURCE.NAME as SOURCENAME, '+
                   'QCFLAG.SOURCE_FLAG, QCFLAG.ODB_FLAG '+
                   'FROM QCFLAG, SOURCE '+
                   'WHERE QCFLAG.SOURCE_ID=SOURCE.ID '+
                   'ORDER BY SOURCE.NAME, QCFLAG.SOURCE_FLAG';
  end;
 end;

 //If table exists
 if CodesTblName<>'' then begin
 //  showmessage(Q.SQL.Text);
  Q.Open;
  Q.Last;
  Q.First;

   // Page title with amount of rows
   if not Q.IsEmpty then
     Caption:='Codes: '+CodesTblName+' ['+inttostr(Q.RecordCount)+']' else
     Caption:='Codes: '+CodesTblName;

   Navigation;
   ResizeColumns(self);
 end;
end;

procedure Tfrmcodes.ResizeColumns(Sender: TObject);
Var
 occup:integer;
begin
 if CodesTblName='CRUISE' then begin
    occup:=trunc(DBGridCruise.Width-20-
           (DBGridCruise.Columns[0].Width+
            DBGridCruise.Columns[1].Width+
            DBGridCruise.Columns[2].Width+
            DBGridCruise.Columns[3].Width+
            DBGridCruise.Columns[4].Width+
            DBGridCruise.Columns[5].Width+
            DBGridCruise.Columns[7].Width+
            DBGridCruise.Columns[8].Width));
    DBGridCruise.Columns[6].Width:=occup+1;

    eCruise_ID.Width:=DBGridCruise.Columns[0].Width+1;
    eCruise_PLATFORMNAME.Width:=DBGridCruise.Columns[1].Width;
    eCruise_NUMBER.Width:=DBGridCruise.Columns[2].Width;
    eCruise_DATESTART.Width:=DBGridCruise.Columns[3].Width;
    eCruise_DATEEND.Width:=DBGridCruise.Columns[4].Width;
    eCruise_STATIONAMOUNT.Width:=DBGridCruise.Columns[5].Width;
    eCruise_COUNTRYNAME.Width:=DBGridCruise.Columns[6].Width;
    eCruise_SOURCENAME.Width:=DBGridCruise.Columns[7].Width;
    eCruise_WOD.Width:=DBGridCruise.Columns[8].Width;
 end;
 if CodesTblName='CRUISE_WOD' then begin
   DBGridCruiseWOD.Columns[1].Width:=65;
   DBGridCruiseWOD.Columns[3].Width:=65;
   DBGridCruiseWOD.Columns[4].Width:=65;
   DBGridCruiseWOD.Columns[5].Width:=65;

   pCruiseWOD.Width:=DBGridCruiseWOD.Columns[3].Width+
                     DBGridCruiseWOD.Columns[4].Width+
                     DBGridCruiseWOD.Columns[5].Width;

{   occup:= trunc((DBGridCruiseWOD.Width-20-
                  DBGridCruiseWOD.Columns[0].Width+
                  DBGridCruiseWOD.Columns[1].Width+
                  DBGridCruiseWOD.Columns[2].Width+
                  pCruiseWOD.Width+
                  DBGridCruiseWOD.Columns[8].Width)/2);

   showmessage(inttostr(DBGridCruiseWOD.Width-
                  DBGridCruiseWOD.Columns[0].Width+
                  DBGridCruiseWOD.Columns[1].Width+
                  DBGridCruiseWOD.Columns[2].Width+
                  pCruiseWOD.Width+
                  DBGridCruiseWOD.Columns[8].Width));

   showmessage(inttostr(DBGridCruiseWOD.Width-20)+'   '+inttostr(occup));

    DBGridCruiseWOD.Columns[6].Width:=occup;
    DBGridCruiseWOD.Columns[7].Width:=occup;    }

    eCruiseWOD_ID.Width:=           DBGridCruiseWOD.Columns[0].Width+1;
    eCruiseWOD_WOD.Width:=          DBGridCruiseWOD.Columns[1].Width;
    eCruiseWOD_PLATFORMNAME.Width:= DBGridCruiseWOD.Columns[2].Width;
    eCruiseWOD_COUNTRYNAME.Width:=  DBGridCruiseWOD.Columns[6].Width;
    eCruiseWOD_Institute.Width:=    DBGridCruiseWOD.Columns[7].Width;
    eCruiseWOD_WMO.Width:=          DBGridCruiseWOD.Columns[8].Width;
 end;
 if CodesTblName='CRUISE_GLODAP' then begin
    DBGridCruiseGLODAP.Columns[4].Width:=65;
    DBGridCruiseGLODAP.Columns[5].Width:=65;
    DBGridCruiseGLODAP.Columns[6].Width:=65;

    pCruiseGLODAP.Width:=DBGridCruiseGLODAP.Columns[4].Width+
                         DBGridCruiseGLODAP.Columns[5].Width+
                         DBGridCruiseGLODAP.Columns[6].Width;

    occup:=trunc(DBGridCruiseGLODAP.Width-20-
           (DBGridCruiseGLODAP.Columns[0].Width+
            DBGridCruiseGLODAP.Columns[1].Width+
            DBGridCruiseGLODAP.Columns[2].Width+
            DBGridCruiseGLODAP.Columns[3].Width+
            pCruiseGLODAP.Width+
            DBGridCruiseGLODAP.Columns[7].Width));

    DBGridCruiseGLODAP.Columns[8].Width:=occup+1;

    eCruiseGLODAP_ID.Width:=          DBGridCruiseGLODAP.Columns[0].Width+1;
    eCruiseGLODAP_EXPOCODE.Width:=    DBGridCruiseGLODAP.Columns[1].Width;
    eCruiseGLODAP_PLATFORMNAME.Width:=DBGridCruiseGLODAP.Columns[2].Width;
    eCruiseGLODAP_NUMBER.Width:=      DBGridCruiseGLODAP.Columns[3].Width;
    eCruiseGLODAP_COUNTRYNAME.Width:= DBGridCruiseGLODAP.Columns[7].Width;
    eCruiseGLODAP_PI.Width:=          DBGridCruiseGLODAP.Columns[8].Width;
 end;
 if CodesTblName='PLATFORM' then begin
    occup:=trunc((DBGridPlatform.Width-20-
            (DBGridPlatform.Columns[0].Width+
             DBGridPlatform.Columns[1].Width+
             DBGridPlatform.Columns[2].Width+
             DBGridPlatform.Columns[3].Width+
             DBGridPlatform.Columns[4].Width))/2);

    DBGridPlatform.Columns[5].Width:=occup+1;
    DBGridPlatform.Columns[6].Width:=occup+1;

    ePlatform_ID.Width:=DBGridPlatform.Columns[0].Width+1;
    ePlatform_NODC.Width:=DBGridPlatform.Columns[1].Width;
    ePlatform_WOD.Width:=DBGridPlatform.Columns[2].Width;
    ePlatform_IMO.Width:=DBGridPlatform.Columns[3].Width;
    ePlatform_Callsign.Width:=DBGridPlatform.Columns[4].Width;
    ePlatform_Name.Width:=DBGridPlatform.Columns[5].Width;
    ePlatform_NameNative.Width:=DBGridPlatform.Columns[6].Width;
 end;
 if CodesTblName='COUNTRY' then begin
    occup:=trunc(DBGridCountry.Width-20-
           (DBGridCountry.Columns[0].Width+
            DBGridCountry.Columns[1].Width));
    DBGridCountry.Columns[2].Width:=occup+1;
 end;
 if CodesTblName='SOURCE' then begin
    occup:=trunc(DBGridSource.Width-20-
           (DBGridSource.Columns[0].Width+
            DBGridSource.Columns[2].Width+
            DBGridSource.Columns[3].Width));
    DBGridSource.Columns[1].Width:=occup+1;
    eSource_Name.Width:=DBGridSource.Columns[1].Width;
 end;
 if CodesTblName='PI' then begin
    occup:=trunc(DBGridPI.Width-20-
           (DBGridPI.Columns[0].Width+
            DBGridPI.Columns[2].Width+
            DBGridPI.Columns[3].Width));

    DBGridPI.Columns[1].Width:=occup+1;

    ePIWOD_ID.Width:=     DBGridPI.Columns[0].Width+1;
    ePIWOD_Name.Width:=   DBGridPI.Columns[1].Width;
    //ePI_Source.Width:= DBGridPI.Columns[2].Width;
   // ePI_WOD.Width:=    DBGridPI.Columns[3].Width;
 end;
 if CodesTblName='PROJECT' then begin
    occup:=trunc(DBGridProject.Width-20-
           (DBGridProject.Columns[0].Width+
            DBGridProject.Columns[1].Width));
    DBGridProject.Columns[2].Width:=occup+1;
 end;
 if CodesTblName='INSTITUTE' then begin
    occup:=trunc(DBGridInstitute.Width-20-
           (DBGridInstitute.Columns[0].Width+
            DBGridInstitute.Columns[1].Width+
            DBGridInstitute.Columns[2].Width));
    DBGridInstitute.Columns[3].Width:=occup+1;
 end;
 if CodesTblName='INSTRUMENT' then begin
    occup:=trunc(DBGridInstrument.Width-20-
           (DBGridInstrument.Columns[0].Width+
            DBGridInstrument.Columns[1].Width));
    DBGridInstrument.Columns[2].Width:=occup+1;
 end;
 if CodesTblName='UNITS' then begin
    occup:=trunc(DBGridUnits.Width-20-
           (DBGridUnits.Columns[0].Width+
            DBGridUnits.Columns[2].Width+
            DBGridUnits.Columns[3].Width+
            DBGridUnits.Columns[4].Width));
    DBGridUnits.Columns[1].Width:=occup+1;
    eUnits_Name.Width:=DBGridUnits.Columns[1].Width;
 end;

 if CodesTblName='QCFLAG' then begin
    eQCFlag_ID.Width:=DBGridQCFlag.Columns[0].Width+1;
    eQCFlag_SOURCENAME.Width:=DBGridQCFlag.Columns[1].Width;
    eQCFlag_SourceFlag.Width:=DBGridQCFlag.Columns[2].Width;
    eQCFlag_ODBFlag.Width:=DBGridQCFlag.Columns[3].Width+1;
 end;

Panel28.Width:=trunc(ToolBar1.Width-65-
 (btnAdd.Width+btnDelete.Width+btnCancel.Width+btnUpdateQC.Width));
Application.ProcessMessages;
end;


procedure Tfrmcodes.Navigation;
Var
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
 cc:string;
begin

(* CRUISE *)
 if CodesTblName='CRUISE' then begin
  cbCruise_project.Clear;
  cbCruise_institute.Clear;
  cbCruise_pi.Clear;

 if Q.FieldByName('ID').AsInteger>0 then begin
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.SupportDB;
  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.SupportDB;
  Qt.Transaction:=TRt;
   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add('select CRUISE.ID, PROJECT.NAME as PROJECTNAME, INSTITUTE.NAME as INSTITUTENAME, ');
     SQL.Add('PI.NAME as PINAME FROM CRUISE, COUNTRY, PROJECT, INSTITUTE, PI WHERE ');
     SQL.Add('CRUISE.PROJECT_ID=PROJECT.ID and CRUISE.INSTITUTE_ID=INSTITUTE.ID and ');
     SQL.Add('CRUISE.PI_ID=PI.ID and CRUISE.ID='+inttostr(Q.FieldByName('ID').AsInteger));
    Open;
     cbCruise_project.Text:=Qt.FieldByName('PROJECTNAME').AsWideString;
     cbCruise_institute.Text:=Qt.FieldByName('INSTITUTENAME').AsWideString;
     cbCruise_pi.Text:=Qt.FieldByName('PINAME').AsWideString;
    Close;
   end;
   TRt.Commit;
   Qt.Free;
   TRt.Free;
  end;
 end;

 (* Platform *)
 if CodesTblName='PLATFORM' then begin
  mNotesICES.Clear;
  mNotesWOD.Clear;

 if Q.FieldByName('ID').AsInteger>0 then begin
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.SupportDB;
  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.SupportDB;
  Qt.Transaction:=TRt;
   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add(' select NOTES_ICES, NOTES_WOD ');
     SQL.Add(' from PLATFORM where ');
     SQL.Add(' ID='+inttostr(Q.FieldByName('ID').AsInteger));
    Open;
     mNotesICES.Lines.Text:=Qt.FieldByName('NOTES_ICES').AsWideString;
     mNotesWOD.Lines.Text :=Qt.FieldByName('NOTES_WOD').AsWideString;
    Close;
   end;
   TRt.Commit;
   Qt.Free;
   TRt.Free;
  end;
 end;

  If (CodesTblName='PLATFORM') or (CodesTblName='INSTITUTE') then begin
    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.SupportDB;
    Qt :=TSQLQuery.Create(self);
    Qt.Database:=frmdm.SupportDB;
    Qt.Transaction:=TRt;

   lbCountryPlatform.Caption:=''; imgFlagPlatform.Picture.Clear;
   lbCountryInstitute.Caption:=''; imgFlagInstitute.Picture.Clear;

   cc:=Copy(Q.FieldByName('NODC_CODE').AsString, 1, 2);
   if trim(cc)='' then exit;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' select ISO3166_CODE, NAME from COUNTRY ');
      SQL.Add(' where NODC_CODE=:code');
      ParamByName('code').AsString:=cc;
     Open;
    end;

    if Qt.IsEmpty=true then
     with Qt do begin
      Close;
       SQL.Clear;
       SQL.Add(' select ISO3166_CODE, NAME from COUNTRY ');
       SQL.Add(' where ISO3166_CODE=:code');
       ParamByName('code').AsString:=cc;
      Open;
    end;

    if Qt.IsEmpty=false then begin
       try
         if CodesTblName='PLATFORM' then begin
            imgFlagPlatform.Picture.LoadFromLazarusResource(LowerCase(Qt.Fields[0].AsString+'_32'));
            lbCountryPlatform.Caption:=Qt.Fields[1].AsString;
         end;
         if CodesTblName='INSTITUTE' then begin
            imgFlagInstitute.Picture.LoadFromLazarusResource(LowerCase(Qt.Fields[0].AsString+'_32'));
            lbCountryInstitute.Caption:=Qt.Fields[1].AsString;
         end;
       except
       end;

      end;
    TRt.Commit;
   Qt.Free;
   TRt.Free;
  end;


 if (Q.FieldByName('ID').AsInteger>0) and
    (CodesTblName<>'COUNTRY') and
    (CodesTblName<>'QCFLAG') and
    (CodesTblName<>'CRUISE_WOD') and
    (CodesTblName<>'PI_WOD') then begin
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.SupportDB;
  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.SupportDB;
  Qt.Transaction:=TRt;
   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add(' select NOTES from '+CodesTblName+' where ');
     SQL.Add(' ID='+inttostr(Q.FieldByName('ID').AsInteger));
    Open;
     if CodesTblName='CRUISE' then begin
       mNotesCruise.Clear;
       mNotesCruise.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
     end;
     if CodesTblName='CRUISE_GLODAP' then begin
       mNotesCruiseGLODAP.Clear;
       mNotesCruiseGLODAP.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
     end;
     if CodesTblName='PLATFORM' then begin
       mNotesPlatform.Clear;
       mNotesPlatform.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
     end;
     if CodesTblName='COUNTRY' then begin
       mNotesCruise.Clear;
       mNotesCruise.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
     end;
     if CodesTblName='SOURCE' then begin
       mNotesSource.Clear;
       mNotesSource.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
     end;
     if CodesTblName='PROJECT' then begin
       mNotesProject.Clear;
       mNotesProject.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
     end;
     if CodesTblName='INSTITUTE' then begin
       mNotesInstitute.Clear;
       mNotesInstitute.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
     end;
     if CodesTblName='INSTRUMENT' then begin
       mNotesInstrument.Clear;
       mNotesInstrument.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
     end;
     if CodesTblName='UNITS' then begin
       mNotesUnits.Clear;
       mNotesUnits.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
     end;
    Close;
   end;
  end;


end;



(* Add new row *)
procedure Tfrmcodes.btnaddClick(Sender: TObject);
Var
 Qt:TSQLQuery;
begin
Q.Insert;
Qt :=TSQLQuery.Create(self);
Qt.Database:=frmdm.SupportDB;
Qt.Transaction:=frmdm.SupportTR;

   if Q.FieldByName('ID').AsInteger=-1 then begin
     Qt.Close;
     Qt.SQL.Text:=' Select max(ID) from '+CodesTblName;
     Qt.Open;
      Q.Append;
      Q.FieldByName('ID').Value:=Qt.Fields[0].AsInteger+1;
     Qt.Close;
   end;

Qt.Free;
btnSave.Enabled:=true;
end;


(* Delete row *)
procedure Tfrmcodes.btndeleteClick(Sender: TObject);
begin
   if MessageDlg(SDelete+' ID='+Q.Fields[0].AsString+'?',
      mtWarning, [mbYes, MbNo], 0)=mrYes then begin
        Q.Delete;
     btnSave.Enabled:=true;
   end;
end;


(* Cancel changes *)
procedure Tfrmcodes.btncancelClick(Sender: TObject);
begin
  Q.Cancel;
  btnSave.Enabled:=true;
end;


(* Save changes *)
procedure Tfrmcodes.btnsaveClick(Sender: TObject);
Var
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
begin
   if Q.Modified then Q.Post;

 //  showmessage('here');
      Q.ApplyUpdates(0);
      frmdm.SupportTR.CommitRetaining;
 //   showmessage('here2');

      if (CodesTblName='PLATFORM') and (mNotesPlatform.Lines.Text<>'') then begin
        TRt:=TSQLTransaction.Create(self);
        TRt.DataBase:=frmdm.SupportDB;

        Qt:=TSQLQuery.Create(self);
        Qt.Transaction:=TRt;

        With Qt do begin
         Close;
          SQL.Clear;
          SQL.Add(' Update PLATFORM set ');
          SQL.Add(' NOTES=:NOTES ');
          SQL.Add(' where ID=:ID ');
          ParamByName('ID').AsInteger:=Q.FieldByName('ID').AsInteger;
          ParamByName('NOTES').AsWideString:=mNotesPlatform.Lines.Text;
         ExecSQL;
        end;
        Qt.Close;
        TRt.Commit;
        Qt.Free;
        TRt.Free;
      end;

      if ((CodesTblName='SOURCE') and (mNotesSource.Lines.Text<>'')) or
         ((CodesTblName='PROJECT') and (mNotesProject.Lines.Text<>'')) or
         ((CodesTblName='INSTITUTE') and (mNotesInstitute.Lines.Text<>'')) or
         ((CodesTblName='INSTRUMENT') and (mNotesInstrument.Lines.Text<>'')) or
         ((CodesTblName='UNITS') and (mNotesUnits.Lines.Text<>'')) then begin

        TRt:=TSQLTransaction.Create(self);
        TRt.DataBase:=frmdm.SupportDB;

        Qt:=TSQLQuery.Create(self);
        Qt.Transaction:=TRt;

        With Qt do begin
         Close;
          SQL.Clear;
          SQL.Add(' Update '+CodesTblName+' set ');
          SQL.Add(' NOTES=:NOTES ');
          SQL.Add(' where ID=:ID ');
          ParamByName('ID').AsInteger:=Q.FieldByName('ID').AsInteger;
          if (CodesTblName='SOURCE') then ParamByName('NOTES').AsWideString:=mNotesSource.Lines.Text;
          if (CodesTblName='PROJECT') then ParamByName('NOTES').AsWideString:=mNotesProject.Lines.Text;
          if (CodesTblName='INSTITUTE') then ParamByName('NOTES').AsWideString:=mNotesInstitute.Lines.Text;
          if (CodesTblName='INSTRUMENT') then ParamByName('NOTES').AsWideString:=mNotesInstrument.Lines.Text;
          if (CodesTblName='UNITS') then ParamByName('NOTES').AsWideString:=mNotesUnits.Lines.Text;
         ExecSQL;
        end;
        Qt.Close;
        TRt.Commit;
        Qt.Free;
        TRt.Free;
      end;

 btnSave.Enabled:=false; //Disabling Save button
end;


(******************************* Fast search *********************************)
(* ID *)
procedure Tfrmcodes.SearchID(Sender: TObject);
Begin
  if (Sender as TEdit).Text='' then exit;
    Q.Locate('ID', StrToInt((Sender as TEdit).Text),[loCaseInsensitive, loPartialKey]);
end;

(* NAME *)
procedure Tfrmcodes.SearchNAME(Sender: TObject);
begin
 Q.Filter:='NAME = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
 Q.Filtered:=true;
end;

(* SOURCE *)
procedure Tfrmcodes.SearchSOURCENAME(Sender: TObject);
begin
  Q.Filter:='SOURCENAME = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  Q.Filtered:=true;
end;

(* PI *)
procedure Tfrmcodes.SearchPI(Sender: TObject);
begin
  Q.Filter:='PI = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  Q.Filtered:=true;
end;

(* NODC *)
procedure Tfrmcodes.SearchNODC(Sender: TObject);
begin
 Q.Filter:='NODC_CODE = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
 Q.Filtered:=true;
end;

(* WOD *)
procedure Tfrmcodes.SearchWOD(Sender: TObject);
begin
 if (Sender as TEdit).Text='' then exit;
   Q.Locate('WOD_ID', StrToInt((Sender as TEdit).Text),[loCaseInsensitive, loPartialKey]);
end;


(* IMO *)
procedure Tfrmcodes.ePlatfo(Sender: TObject);
begin
 if ePlatform_IMO.Text='' then exit;
   Q.Locate('IMO_ID', StrToInt(ePlatform_IMO.Text),[loCaseInsensitive, loPartialKey]);
end;

(* ISO-3166 code *)
procedure Tfrmcodes.eCountry_ISOChange(Sender: TObject);
begin
 if eCountry_ISO.Text='' then exit;
  Q.Locate('ISO3166_CODE',eCountry_ISO.Text,[loCaseInsensitive, loPartialKey]);
end;

(* Callsign *)
procedure Tfrmcodes.ePlatform_(Sender: TObject);
begin
 Q.Filter:='CALLSIGN = '+QuotedStr('*'+ePlatform_Callsign.Text+'*');
 Q.Filtered:=true;
end;


(* Platform native name *)
procedure Tfrmcodes.ePlatform_NameNativeChange(Sender: TObject);
begin
  Q.Filter:='NAME_NATIVE = '+QuotedStr('*'+ePlatform_NameNative.Text+'*');
  Q.Filtered:=true;
end;


procedure Tfrmcodes.eCruiseGLODAP_EXPOCODEChange(Sender: TObject);
begin
 Q.Filter:='EXPOCODE = '+QuotedStr('*'+eCruiseGLODAP_EXPOCODE.Text+'*');
 Q.Filtered:=true;
end;

procedure Tfrmcodes.eCruiseGLODAP_NUMBERChange(Sender: TObject);
begin
 Q.Filter:='CRUISE_NUMBER = '+QuotedStr('*'+eCruiseGLODAP_NUMBER.Text+'*');
 Q.Filtered:=true;
end;

procedure Tfrmcodes.eCruiseGLODAP_PLATFORMNAMEChange(Sender: TObject);
begin
 Q.Filter:='PLATFORMNAME = '+QuotedStr('*'+eCruiseGLODAP_PLATFORMNAME.Text+'*');
 Q.Filtered:=true;
end;

procedure Tfrmcodes.eCruiseGLODAP_COUNTRYNAMEChange(Sender: TObject);
begin
 Q.Filter:='COUNTRYNAME = '+QuotedStr('*'+eCruiseGLODAP_COUNTRYNAME.Text+'*');
 Q.Filtered:=true;
end;


(* Cleaning controls on click and drop the filter *)
procedure Tfrmcodes.ePlatform_IDClick(Sender: TObject);
var
  k: Integer;
begin
  for k:= 0 to frmcodes.ComponentCount-1 do
    if frmcodes.Components[k] is TEdit then TEdit(frmcodes.Components[k]).Clear;
  Q.Filtered:=false;
end;


(************************************END**************************************)

procedure Tfrmcodes.DBGridPlatformKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key=VK_UP) or (key=VK_DOWN) then Navigation;
end;

procedure Tfrmcodes.DBGridPlatformKeyPress(Sender: TObject; var Key: char);
begin
 Key := UpCase(Key); //only capital letters
end;


procedure Tfrmcodes.DBGridPlatformTitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(Q, Column.FieldName);
end;

procedure Tfrmcodes.DBGridCountryTitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(Q, Column.FieldName);
end;


procedure Tfrmcodes.DBGridPlatformCellClick(Column: TColumn);
begin
  Navigation;
end;


procedure Tfrmcodes.mNotesPlatformKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 Q.Edit;
end;

(* navigating trough table PLATFORM *)
procedure Tfrmcodes.QAfterScroll(DataSet: TDataSet);
begin
  Navigation;
end;


(* Enabling Save as the query was changed *)
procedure Tfrmcodes.QAfterEdit(DataSet: TDataSet);
begin
   btnSave.Enabled:=true;
end;


procedure Tfrmcodes.FormResize(Sender: TObject);
begin
  ResizeColumns(self);
end;


(* Update and QC for SupportTables.FDB *)
procedure Tfrmcodes.btnUpdateQCClick(Sender: TObject);
begin
 if frmcodesQC_open=true then frmcodesQC.SetFocus else
    begin
      frmcodesQC:= TfrmcodesQC.Create(Self);
      frmcodesQC.Show;
    end;
 frmcodesQC_open:=true;
end;



procedure Tfrmcodes.cbCruise_ProjectDropDown(Sender: TObject);
Var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
 cbCruise_project.Items.Clear;

 TRt:=TSQLTransaction.Create(self);
 TRt.DataBase:=frmdm.SupportDB;
 Qt :=TSQLQuery.Create(self);
 With Qt do begin
   Database:=frmdm.SupportDB;
   Transaction:=TRt;
   SQL.Text:='select Distinct(NAME) from PROJECT order by NAME';
   Open;
 end;

 while not Qt.Eof do begin
   cbCruise_project.Items.Add(Qt.Fields[0].AsWideString);
  Qt.Next;
 end;
  Qt.Close;
  TRt.Commit;
  Qt.Free;
  TRt.Free;
//   DBGridEh1.Columns[9].PickList:=cbVessel.Items;
end;

procedure Tfrmcodes.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 Q.Close;
 CloseAction:= caFree;
 frmcodes_open:=false;
end;


end.

