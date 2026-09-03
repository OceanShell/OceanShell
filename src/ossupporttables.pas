unit ossupporttables;

{$mode objfpc}{$H+}

interface

uses

  lclintf, SysUtils, Variants, Classes, Graphics, Controls, Forms, LCLType,
  Dialogs, StdCtrls, Buttons, ComCtrls, ExtCtrls, Menus, sqldb, DB, sortbufds,
  DBGrids, DBCtrls, LResources, Grids, IniFiles;

type

  { Tfrmsupporttables }

  Tfrmsupporttables = class(TForm)
    btnadd: TToolButton;
    btnsave: TToolButton;
    btndelete: TToolButton;
    btnUpdateQC: TBitBtn;
    DBGridFlag: TDBGrid;
    DBGridTables: TDBGrid;
    DBGridUnits: TDBGrid;
    DBGridPlatform: TDBGrid;
    DBGridCountry: TDBGrid;
    DBGridProject: TDBGrid;
    DBGridInstitute: TDBGrid;
    DBGridInstrument: TDBGrid;
    DBGridSource: TDBGrid;
    DS: TDataSource;
    eInstitute_NameNative: TEdit;
    eInstitute_Country: TEdit;
    eInstitute_Place: TEdit;
    ePlatform_Title: TEdit;
    eTables_ID: TEdit;
    eTables_NAME: TEdit;
    eCountry_NODC: TEdit;
    eTables_TABLENAME: TEdit;
    ePlatform_Country: TEdit;
    eProject_ID: TEdit;
    eInstitute_ID: TEdit;
    eInstrument_ID: TEdit;
    eUnits_ID: TEdit;
    eInstrument_Name: TEdit;
    eSource_ID: TEdit;
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
    imgFlagPlatform: TImage;
    ImgFlagInstitute: TImage;
    lbCruisesInDB: TLabel;
    lbCountryPlatform: TLabel;
    lbCountryInstitute: TLabel;
    mNotesTables: TMemo;
    mNotesInstitute: TMemo;
    mNotesCountry: TMemo;
    mNotesInstrument: TMemo;
    mNotesUnits: TMemo;
    mNotesProject: TMemo;
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
    Panel3: TPanel;
    ePlatform_NODC: TEdit;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    rgFlag: TRadioGroup;
    Splitter1: TSplitter;
    PageControl1: TPageControl;
    ToolButton2: TToolButton;
    tsFlag: TTabSheet;
    tsTables: TTabSheet;
    tbInstrument: TTabSheet;
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
    ePlatform_CS: TEdit;
    mNotesWOD: TMemo;
    Splitter3: TSplitter;
    tbProject: TTabSheet;
    tbInstitute: TTabSheet;
    ToolBar1: TToolBar;
    btncancel: TToolButton;
    ToolButton1: TToolButton;

    procedure eInstitute_PlaceChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnUpdateQCClick(Sender: TObject);

    procedure DBGridCountryColumnSized(Sender: TObject);
    procedure DBGridInstituteColumnSized(Sender: TObject);
    procedure DBGridInstrumentColumnSized(Sender: TObject);
    procedure DBGridPlatformColumnSized(Sender: TObject);
    procedure DBGridUnitsColumnSized(Sender: TObject);
    procedure DBGridProjectColumnSized(Sender: TObject);
    procedure DBGridSourceColumnSized(Sender: TObject);
    procedure DBGridTablesColumnSized(Sender: TObject);

    procedure DBGridPlatformEditingDone(Sender: TObject);
    procedure DBGridPlatformKeyPress(Sender: TObject; var Key: char);
    procedure DBGridPlatformPrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DBGridPlatformSelectEditor(Sender: TObject; Column: TColumn;
      var Editor: TWinControl);
    procedure DBGridTablesEditingDone(Sender: TObject);
    procedure DBGridTablesSelectEditor(Sender: TObject; Column: TColumn;
      var Editor: TWinControl);

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

    procedure eCountry_NODCChange(Sender: TObject);
    procedure eInstitute_NameFullChange(Sender: TObject);
    procedure ePlatform_IDClick(Sender: TObject);
    procedure eProject_NameFullChange(Sender: TObject);
    procedure eTables_TABLENAMEChange(Sender: TObject);
    procedure rgFlagClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);


  private
    { Private declarations }
    procedure Navigation;

    procedure SearchID(Sender:TObject);
    procedure SearchNAME(Sender:TObject);
    procedure SearchNAMENATIVE(Sender:TObject);
    procedure SearchSOURCENAME(Sender:TObject);
    procedure SearchPI(Sender:TObject);
    procedure SearchNODC(Sender:TObject);
    procedure SearchWOD(Sender:TObject);
    procedure SearchIMO(Sender:TObject);
    procedure SearchCS(Sender:TObject);
    procedure SearchISO(Sender:TObject);
    procedure SearchTitle(Sender:TObject);
    procedure SearchCountry(Sender:TObject);
  public
    { Public declarations }
  end;

var
  frmsupporttables: Tfrmsupporttables;
  CodesTblName: string; //Global active table name
  TR:TSQLTransaction;
  Q:TSQLQuery;

implementation

{$R *.lfm}

uses osmain, dm, ossupporttables_update;


procedure Tfrmsupporttables.FormCreate(Sender: TObject);
begin
  TR:=TSQLTransaction.Create(self);
  TR.DataBase:=frmdm.IBDB;

  Q:=TSQLQuery.Create(self);
  Q.Database:=frmdm.IBDB;
  Q.Transaction:=TR;
end;

procedure Tfrmsupporttables.FormShow(Sender: TObject);
Var
  Ini: TIniFile;
begin

 PageControl1.ActivePageIndex:=0;
 PageControl1.OnChange(self);

  (* Loading settings from INI file *)
  Ini := TIniFile.Create(IniFileName);
  try
    (* main form sizes *)
    Top   :=Ini.ReadInteger( 'ossupporttables', 'top',    50);
    Left  :=Ini.ReadInteger( 'ossupporttables', 'left',   50);
    Width :=Ini.ReadInteger( 'ossupporttables', 'width',  900);
    Height:=Ini.ReadInteger( 'ossupporttables', 'weight', 500);
  finally
    Ini.Free;
  end;

 // Assigning procedures for fast search
 (* ID *)
 eTables_ID.OnChange       := @SearchID;
 ePlatform_ID.OnChange     := @SearchID;
 eCountry_ID.OnChange      := @SearchID;
 eSource_ID.OnChange       := @SearchID;
 eProject_ID.OnChange      := @SearchID;
 eInstitute_ID.OnChange    := @SearchID;
 eInstrument_ID.OnChange   := @SearchID;
 eUnits_ID.OnChange        := @SearchID;
// eFlag_ID.OnChange        := @SearchID;

 (* NAME *)
 eTables_NAME.OnChange     := @SearchNAME;
 ePlatform_NAME.OnChange   := @SearchNAME;
 eCountry_NAME.OnChange    := @SearchNAME;
 eSource_NAME.OnChange     := @SearchNAME;
 eProject_NAME.OnChange    := @SearchNAME;
 eInstitute_NAME.OnChange  := @SearchNAME;
 eInstrument_NAME.OnChange := @SearchNAME;
 eUnits_NAME.OnChange      := @SearchNAME;

 (* NAME NATIVE *)
 ePlatform_NAMENATIVE.OnChange  := @SearchNAMENATIVE;
 eInstitute_NAMENATIVE.OnChange := @SearchNAMENATIVE;

  (* COUNTRY *)
 ePlatform_Country.OnChange  := @SearchCountry;
 eInstitute_Country.OnChange := @SearchCountry;

 (* NODC *)
 ePlatform_NODC.OnChange   := @SearchNODC;
 eInstitute_NODC.OnChange  := @SearchNODC;
 eCountry_NODC.OnChange    := @SearchNODC;

 (* WOD*)
 ePlatform_WOD.OnChange    := @SearchWOD;
 eProject_WOD.OnChange     := @SearchWOD;
 eInstitute_WOD.OnChange   := @SearchWOD;
 eInstrument_WOD.OnChange  := @SearchWOD;

 ePlatform_IMO.OnChange    := @SearchIMO;
 ePlatform_CS.OnChange     := @SearchCS;
 eCountry_ISO.OnChange     := @SearchISO;
 ePlatform_Title.OnChange  := @SearchTitle;
end;


procedure Tfrmsupporttables.FormResize(Sender: TObject);
begin
  DbGridTables.OnColumnSized(self);
  DBGridPlatform.OnColumnSized(self);
  DBGridSource.OnColumnSized(self);
  DBGridUnits.OnColumnSized(self);
  DBGridInstrument.OnColumnSized(self);
  DBGridInstitute.OnColumnSized(self);
  DBGridProject.OnColumnSized(self);
  DBGridCountry.OnColumnSized(self);
end;


procedure Tfrmsupporttables.PageControl1Change(Sender: TObject);
Var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
  Qt1, Qt2, Qt3, Qt4:TSQLQuery;
  DS1, DS2, DS3, DS4:TDataSource;

  k: integer;
  tbl, tbl_missing:string;
begin
 if Q.Active then btnsave.onClick(Self);

 try
 Q.DisableControls;
  With Q do begin
   Filter:='';
   Filtered:=false;
   Close;
   SQL.Clear;
   InsertSQL.Clear;
   UpdateSQL.Clear;
   DeleteSQL.Clear;
   ClearIndexes;
  end;

 CodesTblName:='';
 case PageControl1.ActivePageIndex of
  0: begin
       CodesTblName:='DATABASE_TABLES';

       try
        TRt:=TSQLTransaction.Create(self);
        TRt.DataBase:=frmdm.IBDB;

        Qt:=TSQLQuery.Create(self);
        Qt.Database:=frmdm.IBDB;
        Qt.Transaction:=TRt;

        DBGridTables.Columns[1].PickList.Clear;
        DBGridTables.Columns[1].PickList:=frmosmain.ListBox1.Items;

        DBGridTables.Columns[3].PickList.Clear;
        Qt.SQL.Text:=' SELECT DISTINCT NAME FROM UNITS ORDER BY NAME ';
        Qt.Open;

         while not Qt.Eof do begin
           DBGridTables.Columns[3].PickList.Add(Qt.Fields[0].AsString);
          Qt.Next;
         end;
         Qt.Close;
       finally
         TrT.Commit;
         Qt.Free;
         TrT.Free;
       end;

       Q.SQL.text:='Select DATABASE_TABLES.ID, DATABASE_TABLES.NAME_TABLE, '+
                   'DATABASE_TABLES.NAME, DATABASE_TABLES.UNITS_ID_DEFAULT, '+
                   'UNITS.NAME as DEFAULT_UNITS, '+
                   'DATABASE_TABLES.UNITS_RANGE_MIN, '+
                   'DATABASE_TABLES.UNITS_RANGE_MAX '+
                   'FROM DATABASE_TABLES, UNITS WHERE '+
                   'DATABASE_TABLES.UNITS_ID_DEFAULT=UNITS.ID '+
                   'ORDER BY DATABASE_TABLES.NAME_TABLE';

       Q.InsertSQL.Text:='INSERT INTO DATABASE_TABLES '+
                         '(ID, NAME_TABLE, NAME, UNITS_ID_DEFAULT) '+
                         ' VALUES '+
                         '(:ID, :NAME_TABLE, :NAME, :UNITS_ID_DEFAULT) ';
       Q.UpdateSQL.Text:='UPDATE DATABASE_TABLES SET '+
                         'ID=:ID, NAME_TABLE=:NAME_TABLE, '+
                         'NAME=:NAME, UNITS_ID_DEFAULT=:UNITS_ID_DEFAULT '+
                         'WHERE ID=:ID';
       Q.DeleteSQL.Text:='DELETE FROM DATABASE_TABLES WHERE ID=:ID';

       DBGridTables.OnColumnSized(self);
     end;
  1: begin
       CodesTblName:='PLATFORM';

       try
        TRt:=TSQLTransaction.Create(self);
        TRt.DataBase:=frmdm.IBDB;

        Qt:=TSQLQuery.Create(self);
        Qt.Database:=frmdm.IBDB;
        Qt.Transaction:=TRt;

        DBGridPlatform.Columns[7].PickList.Clear;
        Qt.SQL.Text:=' SELECT DISTINCT NAME FROM COUNTRY ORDER BY NAME ';
        Qt.Open;

         while not Qt.Eof do begin
           DBGridPlatform.Columns[7].PickList.Add(Qt.Fields[0].AsString);
          Qt.Next;
         end;
         Qt.Close;
       finally
         TrT.Commit;
         Qt.Free;
         TrT.Free;
       end;

       Q.SQL.text:='Select PLATFORM.ID, PLATFORM.NODC_CODE, WOD_ID, IMO_ID, '+
                   'CALLSIGN, PLATFORM.TITLE, PLATFORM.NAME, NAME_NATIVE, '+
                   'COUNTRY.NAME as CTRY, PLATFORM.COUNTRY_ID FROM PLATFORM, '+
                   'COUNTRY WHERE PLATFORM.COUNTRY_ID=COUNTRY.ID ORDER BY NAME';

       Q.InsertSQL.Text:='INSERT INTO PLATFORM '+
                         '(ID, NODC_CODE, WOD_ID, IMO_ID, CALLSIGN, TITLE, '+
                         'NAME, NAME_NATIVE, COUNTRY_ID) '+
                         ' VALUES '+
                         '(:ID, :NODC_CODE, :WOD_ID, :IMO_ID, :CALLSIGN, :TITLE, '+
                         ':NAME, :NAME_NATIVE, :COUNTRY_ID) ';
       Q.UpdateSQL.Text:='UPDATE PLATFORM SET '+
                         'ID=:ID, NODC_CODE=:NODC_CODE, WOD_ID=:WOD_ID, '+
                         'IMO_ID=:IMO_ID, CALLSIGN=:CALLSIGN, TITLE=:TITLE, '+
                         'NAME=:NAME, NAME_NATIVE=:NAME_NATIVE, COUNTRY_ID=:COUNTRY_ID '+
                         'WHERE ID=:ID';
       Q.DeleteSQL.Text:='DELETE FROM PLATFORM WHERE ID=:ID';
     end;
  2: begin
       CodesTblName:='SOURCE';
       Q.SQL.text:='Select ID, STATION_ID_MIN, STATION_ID_MAX, NAME '+
                   'FROM SOURCE ORDER BY ID';
     end;
  3: begin
       CodesTblName:='UNITS';
       Q.SQL.text:='Select ID, NAME_SHORT, NAME, SCALE, LENGTH '+
                   'FROM UNITS ORDER BY ID';
     end;
  4: begin
       CodesTblName:='INSTRUMENT';
       Q.SQL.text:='Select ID, WOD_ID, NAME '+
                   'FROM INSTRUMENT ORDER BY ID';
     end;
  5: begin
       CodesTblName:='PROJECT';
       Q.SQL.text:='Select ID, WOD_ID, NAME '+
                   'FROM PROJECT ORDER BY NAME';
     end;
  6: begin
       CodesTblName:='INSTITUTE';
       Q.SQL.text:='SELECT INSTITUTE.ID, INSTITUTE.NODC_CODE, INSTITUTE.WOD_ID, '+
                   'INSTITUTE.NAME, INSTITUTE.NAME_NATIVE, INSTITUTE.PLACE, '+
                   'COUNTRY.NAME as CTRY, INSTITUTE.COUNTRY_ID FROM INSTITUTE, '+
                   'COUNTRY WHERE INSTITUTE.COUNTRY_ID=COUNTRY.ID ORDER BY '+
                   'INSTITUTE.NAME';
     end;
  7: begin
       CodesTblName:='COUNTRY';
       Q.SQL.text:='Select ID, NODC_CODE, ISO3166_CODE, NAME '+
                   'FROM COUNTRY ORDER BY NAME';
     end;
  8: begin
      CodesTblName:='FLAG_'+rgFlag.Items.Strings[rgFlag.ItemIndex];
       Q.SQL.text:='Select ID, NAME '+
                   'FROM '+CodesTblName+' ORDER BY ID';
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

   // check if there's any tables in the database not in DATABASE_TABLES
   if CodesTblName='DATABASE_TABLES' then begin
    tbl_missing:='';
     for k:=0 to frmosmain.ListBox1.Count-1 do begin
      tbl:=frmosmain.ListBox1.Items.Strings[k];
      if VarIsNull(Q.Locate('NAME_TABLE', tbl, [])) then tbl_missing:=tbl_missing+#13;
     end;
    if trim(tbl_missing)<>'' then
      showmessage('Tables NOT in DATABASE_TABLES:'+tbl_missing);
   end;

   Navigation;
 end;

 DS.DataSet:=Q;

 finally
   Q.EnableControls;
 end;
end;


procedure Tfrmsupporttables.DBGridTablesColumnSized(Sender: TObject);
Var
  occup:integer;
begin
 with DBGridTables do begin
  occup:=trunc(Width-25-(Columns[0].Width+Columns[4].Width+Columns[5].Width));

  Columns[1].Width:=trunc(occup/3);
  Columns[2].Width:=trunc(occup/3);
  Columns[3].Width:=trunc(occup/3);

  eTables_ID.Width       :=Columns[0].Width+1;
  eTables_TABLENAME.Width:=Columns[1].Width;
  eTables_NAME.Width     :=Columns[2].Width;
 end;
end;


procedure Tfrmsupporttables.DBGridPlatformColumnSized(Sender: TObject);
Var
  occup:integer;
begin
  with DBGridPlatform do begin
    occup:=trunc(Width-25-
      (Columns[0].Width+Columns[1].Width+Columns[2].Width+
       Columns[3].Width+Columns[4].Width+Columns[5].Width));
    Columns[6].Width:=trunc(occup/3);
    Columns[7].Width:=trunc(occup/3);
    Columns[8].Width:=trunc(occup/3);

    ePlatform_ID.Width        :=Columns[0].Width+1;
    ePlatform_NODC.Width      :=Columns[1].Width;
    ePlatform_WOD.Width       :=Columns[2].Width;
    ePlatform_IMO.Width       :=Columns[3].Width;
    ePlatform_CS.Width        :=Columns[4].Width;
    ePlatform_Title.Width     :=Columns[5].Width;
    ePlatform_Name.Width      :=Columns[6].Width;
    ePlatform_NameNative.Width:=Columns[7].Width;
    ePlatform_Country.Width   :=Columns[8].Width;
  end;
end;

procedure Tfrmsupporttables.DBGridSourceColumnSized(Sender: TObject);
Var
  occup:integer;
begin
 With DBGridSource do begin
   occup:=trunc(Width-25-(Columns[0].Width+Columns[2].Width+Columns[3].Width));
   Columns[1].Width:=occup+1;
   eSource_ID.Width  :=Columns[0].Width;
   eSource_Name.Width:=Columns[1].Width;
 end;
end;


procedure Tfrmsupporttables.DBGridUnitsColumnSized(Sender: TObject);
Var
  occup:integer;
begin
 occup:=trunc(DBGridUnits.Width-25-
        (DBGridUnits.Columns[0].Width+
         DBGridUnits.Columns[2].Width+
         DBGridUnits.Columns[3].Width+
         DBGridUnits.Columns[4].Width));
 DBGridUnits.Columns[1].Width:=occup+1;
 eUnits_ID.Width  :=DBGridUnits.Columns[0].Width;
 eUnits_Name.Width:=DBGridUnits.Columns[1].Width;
end;


procedure Tfrmsupporttables.DBGridInstrumentColumnSized(Sender: TObject);
Var
  occup:integer;
begin
 occup:=trunc(DBGridInstrument.Width-25-
        (DBGridInstrument.Columns[0].Width+
         DBGridInstrument.Columns[1].Width));
 DBGridInstrument.Columns[2].Width:=occup+1;
 eInstrument_ID.Width  :=DBGridInstrument.Columns[0].Width;
 eInstrument_WOD.Width :=DBGridInstrument.Columns[1].Width;
 eInstrument_NAME.Width:=DBGridInstrument.Columns[2].Width;
end;


procedure Tfrmsupporttables.DBGridProjectColumnSized(Sender: TObject);
Var
  occup:integer;
begin
 occup:=trunc(DBGridProject.Width-25-
      (DBGridProject.Columns[0].Width+
       DBGridProject.Columns[1].Width));
DBGridProject.Columns[2].Width:=occup+1;
eProject_ID.Width  :=DBGridProject.Columns[0].Width;
eProject_WOD.Width :=DBGridProject.Columns[1].Width;
eProject_NAME.Width:=DBGridProject.Columns[2].Width;
end;


procedure Tfrmsupporttables.DBGridInstituteColumnSized(Sender: TObject);
Var
  occup:integer;
begin
  With DBGridInstitute do begin
    occup:=trunc(Width-25-(Columns[0].Width+Columns[1].Width+Columns[2].Width+
    Columns[3].Width));

    Columns[4].Width:=trunc(occup/3)+1;
    Columns[5].Width:=trunc(occup/3)+1;
    Columns[6].Width:=trunc(occup/3)+1;

    eInstitute_ID.Width  :=Columns[0].Width;
    eInstitute_NODC.Width:=Columns[1].Width;
    eInstitute_WOD.Width :=Columns[2].Width;
    eInstitute_NAME.Width:=Columns[3].Width;
    eInstitute_NameNative.Width:=Columns[4].Width;
    eInstitute_Place.Width:=Columns[5].Width;
    eInstitute_Country.Width:=Columns[6].Width;
  end;
end;


procedure Tfrmsupporttables.DBGridCountryColumnSized(Sender: TObject);
Var
  occup:integer;
begin
  With DBGridCountry do begin
    occup:=trunc(Width-25-(Columns[0].Width+Columns[1].Width+Columns[2].Width));
    Columns[3].Width:=occup+1;
    eCountry_ID.Width  :=Columns[0].Width;
    eCountry_NODC.Width:=Columns[1].Width;
    eCountry_ISO.Width :=Columns[2].Width;
    eCountry_NAME.Width:=Columns[3].Width;
  end;
end;


procedure Tfrmsupporttables.Navigation;
Var
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
 cc, notes_str:string;
begin
 (* Platform *)
 if CodesTblName='PLATFORM' then begin
  mNotesICES.Clear;
  mNotesWOD.Clear;

 if Q.FieldByName('ID').AsInteger>0 then begin
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;
  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
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

     with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' select COUNT(PLATFORM_ID) FROM CRUISE ');
      SQL.Add(' where PLATFORM_ID=:ID');
      ParamByName('ID').Value:=Q.FieldByName('ID').AsInteger;
     Open;
      lbCruisesInDB.Caption:='Cruises in DB: '+VarToStr(Qt.Fields[0].Value);
     Close;
    end;

   lbCountryPlatform.Caption:=''; imgFlagPlatform.Picture.Clear;
     with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' select ISO3166_CODE, NAME from COUNTRY ');
      SQL.Add(' where ID=:ID');
      ParamByName('ID').Value:=Q.FieldByName('COUNTRY_ID').AsInteger;
     Open;
    end;

    if Qt.IsEmpty=false then begin
      imgFlagPlatform.Picture.LoadFromLazarusResource(LowerCase(Qt.Fields[0].AsString+'_32'));
      lbCountryPlatform.Caption:=Qt.Fields[1].AsString;
    end;

   TRt.Commit;
   Qt.Free;
   TRt.Free;
  end;
 end;

  If (CodesTblName='INSTITUTE') then begin
  lbCountryInstitute.Caption:='';
  imgFlagInstitute.Picture.Clear;
  if Q.FieldByName('COUNTRY_ID').Value>0 then begin
    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;
    Qt :=TSQLQuery.Create(self);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' select ISO3166_CODE, NAME from COUNTRY ');
      SQL.Add(' where ID=:ID');
      ParamByName('ID').Value:=Q.FieldByName('COUNTRY_ID').Value;
     Open;
    end;

      if Qt.IsEmpty=false then begin
        imgFlagInstitute.Picture.LoadFromLazarusResource(LowerCase(Qt.Fields[0].AsString+'_32'));
        lbCountryInstitute.Caption:=Qt.Fields[1].AsString;
      end;
    TRt.Commit;
    Qt.Free;
    TRt.Free;
   end;
  end;


 if (Q.FieldByName('ID').AsInteger>0) and
    (PageControl1.ActivePageIndex<8) then begin
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;
  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

   notes_str:='';
   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add(' select NOTES from '+CodesTblName+' where ');
     SQL.Add(' ID='+inttostr(Q.FieldByName('ID').AsInteger));
    Open;
     notes_str:=Qt.FieldByName('NOTES').AsWideString;
    Close;
   end;

     if CodesTblName='DATABASE_TABLES' then begin
       mNotesTables.Clear;
       mNotesTables.Lines.Text:=notes_str;
     end;

     if CodesTblName='PLATFORM' then begin
       mNotesPlatform.Clear;
       mNotesPlatform.Lines.Text:=notes_str;
     end;
     if CodesTblName='COUNTRY' then begin
       mNotesCountry.Clear;
       mNotesCountry.Lines.Text:=notes_str;
     end;
     if CodesTblName='SOURCE' then begin
       mNotesSource.Clear;
       mNotesSource.Lines.Text:=notes_str;
     end;
     if CodesTblName='PROJECT' then begin
       mNotesProject.Clear;
       mNotesProject.Lines.Text:=notes_str;
     end;
     if CodesTblName='INSTITUTE' then begin
       mNotesInstitute.Clear;
       mNotesInstitute.Lines.Text:=notes_str;
     end;
     if CodesTblName='INSTRUMENT' then begin
       mNotesInstrument.Clear;
       mNotesInstrument.Lines.Text:=notes_str;
     end;
     if CodesTblName='UNITS' then begin
       mNotesUnits.Clear;
       mNotesUnits.Lines.Text:=notes_str;
     end;
  end;


end;



(* Add new row *)
procedure Tfrmsupporttables.btnaddClick(Sender: TObject);
Var
 Qt:TSQLQuery;
begin
Q.Insert;
Qt :=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=frmdm.TR;

   if Q.FieldByName('ID').IsNull then begin
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
procedure Tfrmsupporttables.btndeleteClick(Sender: TObject);
begin
   if MessageDlg(SDelete+' ID='+Q.Fields[0].AsString+'?',
      mtWarning, [mbYes, MbNo], 0)=mrYes then begin
        Q.Delete;
     btnSave.Enabled:=true;
   end;
end;


(* Cancel changes *)
procedure Tfrmsupporttables.btncancelClick(Sender: TObject);
begin
  Q.Cancel;
  btnSave.Enabled:=true;
end;


(* Save changes *)
procedure Tfrmsupporttables.btnsaveClick(Sender: TObject);
Var
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
begin

  if (CodesTblName='DATABASE_TABLES') and
     (Q.FieldByName('DEFAULT_UNITS').AsString='') then
    if MessageDlg('Select default units', mtWarning, [mbOk], 0)=mrOk then exit;

  if (CodesTblName='PLATFORM') and
     (Q.FieldByName('CTRY').AsString='') then
    if MessageDlg('Select country', mtWarning, [mbOk], 0)=mrOk then exit;


      if Q.Modified then Q.Post;
      Q.ApplyUpdates(0);
      frmdm.TR.CommitRetaining;


      if (CodesTblName='DATABASE_TABLES') or
         (CodesTblName='PLATFORM') or
         (CodesTblName='SOURCE') or
         (CodesTblName='UNITS') or
         (CodesTblName='INSTRUMENT') or
         (CodesTblName='PROJECT') or
         (CodesTblName='INSTITUTE') or
         (CodesTblName='COUNTRY') then begin

      try
        TRt:=TSQLTransaction.Create(self);
        TRt.DataBase:=frmdm.IBDB;

        Qt:=TSQLQuery.Create(self);
        Qt.Transaction:=TRt;

        With Qt do begin
         Close;
          SQL.Clear;
          SQL.Add(' Update '+CodesTblName+' set ');
          SQL.Add(' NOTES=:NOTES ');
          SQL.Add(' where ID=:ID ');
          ParamByName('ID').AsInteger:=Q.FieldByName('ID').AsInteger;
          if (CodesTblName='DATABASE_TABLES') then begin
            if mNotesTables.Lines.Text<>'' then
               ParamByName('NOTES').Value:=mNotesTables.Lines.Text else
               ParamByName('NOTES').Value:=null;
          end;
          if (CodesTblName='PLATFORM') then begin
            if mNotesPlatform.Lines.Text<>'' then
               ParamByName('NOTES').Value:=mNotesPlatform.Lines.Text else
               ParamByName('NOTES').Value:=null;
          end;
          if (CodesTblName='SOURCE') then begin
             if mNotesSource.Lines.Text<>'' then
               ParamByName('NOTES').Value:=mNotesSource.Lines.Text else
               ParamByName('NOTES').Value:=null;
          end;
          if (CodesTblName='PROJECT') then begin
             if mNotesProject.Lines.Text<>'' then
               ParamByName('NOTES').Value:=mNotesProject.Lines.Text else
               ParamByName('NOTES').Value:=null;
          end;
          if (CodesTblName='INSTITUTE') then begin
             if mNotesInstitute.Lines.Text<>'' then
               ParamByName('NOTES').Value:=mNotesInstitute.Lines.Text else
               ParamByName('NOTES').Value:=null;
          end;
          if (CodesTblName='INSTRUMENT') then begin
             if mNotesInstrument.Lines.Text<>'' then
               ParamByName('NOTES').Value:=mNotesInstrument.Lines.Text else
               ParamByName('NOTES').Value:=null;
          end;
          if (CodesTblName='UNITS') then begin
             if mNotesUnits.Lines.Text<>'' then
               ParamByName('NOTES').Value:=mNotesUnits.Lines.Text else
               ParamByName('NOTES').Value:=null;
          end;
          if (CodesTblName='COUNTRY') then begin
             if mNotesCountry.Lines.Text<>'' then
               ParamByName('NOTES').Value:=mNotesCountry.Lines.Text else
               ParamByName('NOTES').Value:=null;
          end;

         ExecSQL;
        end;
      finally
        Qt.Close;
        TRt.Commit;
        Qt.Free;
        TRt.Free;
      end;
   end;

 if Copy(CodesTblName, 1, 4) ='FLAG' then frmosmain.PopulateQCFlagLists;
 if Copy(CodesTblName, 1, 10)='INSTRUMENT' then frmosmain.PopulateInstrumentList;

 btnSave.Enabled:=false; //Disabling Save button
end;


(******************************* Fast search *********************************)
(* ID *)
procedure Tfrmsupporttables.SearchID(Sender: TObject);
Begin
  if (Sender as TEdit).Text='' then exit;
    Q.Locate('ID', StrToInt((Sender as TEdit).Text),[loCaseInsensitive, loPartialKey]);
end;

(* NAME *)
procedure Tfrmsupporttables.SearchNAME(Sender: TObject);
begin
 Q.Filter:='NAME = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
 Q.Filtered:=true;
end;

(* NAME NATIVE *)
procedure Tfrmsupporttables.SearchNameNative(Sender: TObject);
begin
  Q.Filter:='NAME_NATIVE = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  Q.Filtered:=true;
end;

(* SOURCE *)
procedure Tfrmsupporttables.SearchSOURCENAME(Sender: TObject);
begin
  Q.Filter:='SOURCENAME = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  Q.Filtered:=true;
end;

(* COUNTRY *)
procedure Tfrmsupporttables.SearchCountry(Sender: TObject);
begin
 Q.Filter:='CTRY = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
 Q.Filtered:=true;
end;

(* PRINCIPAL_INVESTIGATOR *)
procedure Tfrmsupporttables.SearchPI(Sender: TObject);
begin
  Q.Filter:='PRINCIPAL_INVESTIGATOR = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  Q.Filtered:=true;
end;

(* NODC *)
procedure Tfrmsupporttables.SearchNODC(Sender: TObject);
begin
 Q.Filter:='NODC_CODE = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
 Q.Filtered:=true;
end;

(* WOD *)
procedure Tfrmsupporttables.SearchWOD(Sender: TObject);
begin
 if (Sender as TEdit).Text='' then exit;
   Q.Locate('WOD_ID', StrToInt((Sender as TEdit).Text),[loCaseInsensitive, loPartialKey]);
end;


(* IMO *)
procedure Tfrmsupporttables.SearchIMO(Sender: TObject);
begin
 if ePlatform_IMO.Text='' then exit;
   Q.Locate('IMO_ID', StrToInt(ePlatform_IMO.Text),[loCaseInsensitive, loPartialKey]);
end;

(* NODC code *)
procedure Tfrmsupporttables.eCountry_NODCChange(Sender: TObject);
begin
 if eCountry_NODC.Text='' then exit;
  Q.Locate('NODC_CODE',eCountry_NODC.Text,[loCaseInsensitive, loPartialKey]);
end;

(* ISO-3166 code *)
procedure Tfrmsupporttables.SearchISO(Sender:TObject);
begin
 if eCountry_ISO.Text='' then exit;
  Q.Locate('ISO3166_CODE',eCountry_ISO.Text,[loCaseInsensitive, loPartialKey]);
end;

(* PLACE *)
procedure Tfrmsupporttables.eInstitute_PlaceChange(Sender: TObject);
begin
   Q.Filter:='PLACE = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
   Q.Filtered:=true;
end;

procedure Tfrmsupporttables.rgFlagClick(Sender: TObject);
begin
  PageControl1.OnChange(self);
end;


(* Callsign *)
procedure Tfrmsupporttables.SearchCS(Sender: TObject);
begin
 Q.Filter:='CALLSIGN = '+QuotedStr('*'+ePlatform_CS.Text+'*');
 Q.Filtered:=true;
end;


procedure Tfrmsupporttables.SearchTitle(Sender: TObject);
begin
 Q.Filter:='TITLE = '+QuotedStr('*'+ePlatform_Title.Text+'*');
 Q.Filtered:=true;
end;


(* Cleaning controls on click and drop the filter *)
procedure Tfrmsupporttables.ePlatform_IDClick(Sender: TObject);
var
  k: Integer;
begin
  for k:= 0 to frmsupporttables.ComponentCount-1 do
    if frmsupporttables.Components[k] is TEdit then TEdit(frmsupporttables.Components[k]).Clear;
  Q.Filtered:=false;
end;


procedure Tfrmsupporttables.eProject_NameFullChange(Sender: TObject);
begin
 //Q.Filter:='NAME_FULL = '+QuotedStr('*'+eProject_NAMEFULL.Text+'*');
 Q.Filtered:=true;
end;

procedure Tfrmsupporttables.eInstitute_NameFullChange(Sender: TObject);
begin
 //Q.Filter:='NAME_FULL = '+QuotedStr('*'+eInstitute_NAMEFULL.Text+'*');
 Q.Filtered:=true;
end;

procedure Tfrmsupporttables.eTables_TABLENAMEChange(Sender: TObject);
begin
  Q.Filter:='NAME_TABLE = '+QuotedStr('*'+eTables_TABLENAME.Text+'*');
  Q.Filtered:=true;
end;


(************************************END**************************************)

procedure Tfrmsupporttables.DBGridPlatformKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key=VK_UP) or (key=VK_DOWN) then Navigation;
end;

procedure Tfrmsupporttables.DBGridPlatformKeyPress(Sender: TObject; var Key: char);
begin
 Key := UpCase(Key); //only capital letters
end;

procedure Tfrmsupporttables.DBGridPlatformPrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
 if (gdRowHighlight in AState) then begin
   TDBGrid(Sender).Canvas.Brush.Color := clNavy;
   TDBGrid(Sender).Canvas.Font.Color  := clYellow;
   TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
 end;
end;


procedure Tfrmsupporttables.DBGridTablesEditingDone(Sender: TObject);
Var
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
begin
  if TDBGrid(Sender).SelectedColumn.Index=3 then begin
    try
     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qt:=TSQLQuery.Create(self);
     Qt.Transaction:=TRt;

     With Qt do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM UNITS WHERE NAME=:NAME ');
       ParamByName('NAME').AsString:=Q.FieldByName('DEFAULT_UNITS').AsString;
      Open;
      Q.Edit;
       Q.FieldByName('UNITS_ID_DEFAULT').AsInteger:=Qt.Fields[0].AsInteger;
       Q.Post;
      Close;
     end;
    Finally
     Qt.Close;
     TRt.Commit;
     Qt.Free;
    end;
  end;
end;


procedure Tfrmsupporttables.DBGridPlatformEditingDone(Sender: TObject);
Var
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
begin
  if TDBGrid(Sender).SelectedColumn.Index=7 then begin
    try
     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qt:=TSQLQuery.Create(self);
     Qt.Transaction:=TRt;

     With Qt do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM COUNTRY WHERE NAME=:NAME ');
       ParamByName('NAME').AsString:=Q.FieldByName('CTRY').AsString;
      Open;
      Q.Edit;
       Q.FieldByName('COUNTRY_ID').AsInteger:=Qt.Fields[0].AsInteger;
       Q.Post;
      Close;
     end;
    Finally
     Qt.Close;
     TRt.Commit;
     Qt.Free;
    end;
  end;
end;


procedure Tfrmsupporttables.DBGridTablesSelectEditor(Sender: TObject;
  Column: TColumn; var Editor: TWinControl);
begin
  if (Column.Index = 1) or (Column.Index = 3) then begin
    if (Editor is TCustomComboBox) then
      with Editor as TCustomComboBox do
          Style := csDropDownList;
  end;
end;


procedure Tfrmsupporttables.DBGridPlatformSelectEditor(Sender: TObject;
  Column: TColumn; var Editor: TWinControl);
begin
    if Column.Index = 7 then begin
    if (Editor is TCustomComboBox) then
      with Editor as TCustomComboBox do
          Style := csDropDownList;
  end;
end;


procedure Tfrmsupporttables.DBGridPlatformTitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(Q, Column.FieldName);
end;


procedure Tfrmsupporttables.DBGridPlatformCellClick(Column: TColumn);
begin
  Navigation;
end;


procedure Tfrmsupporttables.mNotesPlatformKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 Q.Edit;
end;

(* navigating trough table PLATFORM *)
procedure Tfrmsupporttables.QAfterScroll(DataSet: TDataSet);
begin
  Navigation;
end;


(* Enabling Save as the query was changed *)
procedure Tfrmsupporttables.QAfterEdit(DataSet: TDataSet);
begin
   btnSave.Enabled:=true;
end;



(* Update and QC for SupportTables.FDB *)
procedure Tfrmsupporttables.btnUpdateQCClick(Sender: TObject);
begin
 frmsupporttables_update := Tfrmsupporttables_update.Create(Self);
 try
  if not frmsupporttables_update.ShowModal = mrOk then exit;
 finally
   frmsupporttables_update.Free;
   frmsupporttables_update := nil;
 end;
end;



procedure Tfrmsupporttables.FormClose(Sender: TObject; var CloseAction: TCloseAction);
Var
  Ini:TIniFile;
begin
  TR.Commit;
  Q.Close;
  Q.Free;
  TR.Free;

  Ini := TIniFile.Create(IniFileName);
   try
    Ini.WriteInteger( 'ossupporttables', 'top',    Top);
    Ini.WriteInteger( 'ossupporttables', 'left',   Left);
    Ini.WriteInteger( 'ossupporttables', 'width',  Width);
    Ini.WriteInteger( 'ossupporttables', 'weight', Height);
   finally
     Ini.Free;
   end;
 CloseAction:= caFree;
end;


initialization
  {$I flags.lrs}


end.

