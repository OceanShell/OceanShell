unit ossupporttables;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  lclintf, SysUtils, Variants, Classes, Graphics, Controls, Forms, LCLType,
  Dialogs, StdCtrls, Buttons, ComCtrls, ExtCtrls, Menus, sqldb, DB, sortbufds,
  DBGrids, DBCtrls, LResources, Grids;

type

  { Tfrmsupporttables }

  Tfrmsupporttables = class(TForm)
    btnadd: TToolButton;
    btnsave: TToolButton;
    btndelete: TToolButton;
    btnUpdateQC: TBitBtn;
    DBGridUnits: TDBGrid;
    DBGridPlatform: TDBGrid;
    DBGridCountry: TDBGrid;
    DBGridProject: TDBGrid;
    DBGridInstitute: TDBGrid;
    DBGridInstrument: TDBGrid;
    DBGridSource: TDBGrid;
    DS: TDataSource;
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
    lbCountryPlatform: TLabel;
    lbCountryInstitute: TLabel;
    mNotesInstitute: TMemo;
    mNotesCountry: TMemo;
    mNotesInstrument: TMemo;
    mNotesUnits: TMemo;
    mNotesProject: TMemo;
    mNotesSource: TMemo;
    Panel10: TPanel;
    Panel11: TPanel;
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
    Panel28: TPanel;
    Panel3: TPanel;
    ePlatform_NODC: TEdit;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    Q: TSQLQuery;
    Splitter1: TSplitter;
    PageControl1: TPageControl;
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
    ePlatform_Callsign: TEdit;
    mNotesWOD: TMemo;
    Splitter3: TSplitter;
    tbProject: TTabSheet;
    tbInstitute: TTabSheet;
    ToolBar1: TToolBar;
    btncancel: TToolButton;
    ToolButton1: TToolButton;

    procedure btnUpdateQCClick(Sender: TObject);
    procedure DBGridPlatformKeyPress(Sender: TObject; var Key: char);
    procedure DBGridPlatformPrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
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
  frmsupporttables: Tfrmsupporttables;
  CodesTblName: string; //Global active table name

implementation

{$R *.lfm}

uses osmain, dm, ossupporttables_update;

procedure Tfrmsupporttables.FormShow(Sender: TObject);
begin
 PageControl1.ActivePageIndex:=0;
 PageControl1.OnChange(self);

 ResizeColumns(self);

 // Assigning procedures for fast search
 (* ID *)
 ePlatform_ID.OnChange     := @SearchID;
 eCountry_ID.OnChange      := @SearchID;
 eSource_ID.OnChange       := @SearchID;
 eProject_ID.OnChange      := @SearchID;
 eInstitute_ID.OnChange    := @SearchID;
 eInstrument_ID.OnChange   := @SearchID;
 eUnits_ID.OnChange        := @SearchID;

 (* NAME *)
 ePlatform_NAME.OnChange   := @SearchNAME;
 eCountry_NAME.OnChange    := @SearchNAME;
 eSource_NAME.OnChange     := @SearchNAME;
 eProject_NAME.OnChange    := @SearchNAME;
 eInstitute_NAME.OnChange  := @SearchNAME;
 eInstrument_NAME.OnChange := @SearchNAME;
 eUnits_NAME.OnChange      := @SearchNAME;

 (* NODC *)
 ePlatform_NODC.OnChange  := @SearchNODC;
 eInstitute_NODC.OnChange := @SearchNODC;

 (* WOD*)
 ePlatform_WOD.OnChange   := @SearchWOD;
 eProject_WOD.OnChange    := @SearchWOD;
 eInstitute_WOD.OnChange  := @SearchWOD;
 eInstrument_WOD.OnChange := @SearchWOD;


 (* Procedures for resizing *)
 DBGridPlatform.OnColumnSized     := @ResizeColumns;
 DBGridCountry.OnColumnSized      := @ResizeColumns;
 DBGridSource.OnColumnSized       := @ResizeColumns;
 DBGridProject.OnColumnSized      := @ResizeColumns;
 DBGridInstitute.OnColumnSized    := @ResizeColumns;
 DBGridInstrument.OnColumnSized   := @ResizeColumns;
 DBGridUnits.OnColumnSized        := @ResizeColumns;
end;


procedure Tfrmsupporttables.PageControl1Change(Sender: TObject);
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
       CodesTblName:='SOURCE';
       Q.SQL.text:='Select ID, STATION_ID_MIN, STATION_ID_MAX, NAME '+
                   'FROM SOURCE ORDER BY ID';
     end;
  2: begin
       CodesTblName:='UNITS';
       Q.SQL.text:='Select ID, NAME_SHORT, NAME, SCALE, LENGTH '+
                   'FROM UNITS ORDER BY ID';
     end;
  3: begin
       CodesTblName:='INSTRUMENT';
       Q.SQL.text:='Select ID, WOD_ID, NAME '+
                   'FROM INSTRUMENT ORDER BY WOD_ID';
     end;
  4: begin
       CodesTblName:='PROJECT';
       Q.SQL.text:='Select ID, WOD_ID, NAME '+
                   'FROM PROJECT ORDER BY NAME';
     end;
  5: begin
       CodesTblName:='INSTITUTE';
       Q.SQL.text:='Select ID, WOD_ID, NODC_CODE, NAME '+
                   'FROM INSTITUTE ORDER BY NAME';
     end;
  6: begin
       CodesTblName:='COUNTRY';
       Q.SQL.text:='Select ID, ISO3166_CODE, NAME '+
                   'FROM COUNTRY ORDER BY NAME';
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

procedure Tfrmsupporttables.ResizeColumns(Sender: TObject);
Var
 occup:integer;
begin
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

Panel28.Width:=trunc(ToolBar1.Width-70-(btnAdd.Width+btnDelete.Width+btnCancel.Width+btnUpdateQC.Width));
Application.ProcessMessages;
end;


procedure Tfrmsupporttables.Navigation;
Var
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
 cc:string;
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
   TRt.Commit;
   Qt.Free;
   TRt.Free;
  end;
 end;

  If (CodesTblName='PLATFORM') or (CodesTblName='INSTITUTE') then begin
    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;
    Qt :=TSQLQuery.Create(self);
    Qt.Database:=frmdm.IBDB;
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
  TRt.DataBase:=frmdm.IBDB;
  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;
   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add(' select NOTES from '+CodesTblName+' where ');
     SQL.Add(' ID='+inttostr(Q.FieldByName('ID').AsInteger));
    Open;
     if CodesTblName='PLATFORM' then begin
       mNotesPlatform.Clear;
       mNotesPlatform.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
     end;
     if CodesTblName='COUNTRY' then begin
       mNotesCountry.Clear;
       mNotesCountry.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
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
procedure Tfrmsupporttables.btnaddClick(Sender: TObject);
Var
 Qt:TSQLQuery;
begin
Q.Insert;
Qt :=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=frmdm.TR;

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
   if Q.Modified then Q.Post;

 //  showmessage('here');
      Q.ApplyUpdates(0);
      frmdm.TR.CommitRetaining;
 //   showmessage('here2');

      if (CodesTblName='PLATFORM') and (mNotesPlatform.Lines.Text<>'') then begin
        TRt:=TSQLTransaction.Create(self);
        TRt.DataBase:=frmdm.IBDB;

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

(* SOURCE *)
procedure Tfrmsupporttables.SearchSOURCENAME(Sender: TObject);
begin
  Q.Filter:='SOURCENAME = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
  Q.Filtered:=true;
end;

(* PI *)
procedure Tfrmsupporttables.SearchPI(Sender: TObject);
begin
  Q.Filter:='PI = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
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
procedure Tfrmsupporttables.ePlatfo(Sender: TObject);
begin
 if ePlatform_IMO.Text='' then exit;
   Q.Locate('IMO_ID', StrToInt(ePlatform_IMO.Text),[loCaseInsensitive, loPartialKey]);
end;

(* ISO-3166 code *)
procedure Tfrmsupporttables.eCountry_ISOChange(Sender: TObject);
begin
 if eCountry_ISO.Text='' then exit;
  Q.Locate('ISO3166_CODE',eCountry_ISO.Text,[loCaseInsensitive, loPartialKey]);
end;

(* Callsign *)
procedure Tfrmsupporttables.ePlatform_(Sender: TObject);
begin
 Q.Filter:='CALLSIGN = '+QuotedStr('*'+ePlatform_Callsign.Text+'*');
 Q.Filtered:=true;
end;


(* Platform native name *)
procedure Tfrmsupporttables.ePlatform_NameNativeChange(Sender: TObject);
begin
  Q.Filter:='NAME_NATIVE = '+QuotedStr('*'+ePlatform_NameNative.Text+'*');
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


procedure Tfrmsupporttables.DBGridPlatformTitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(Q, Column.FieldName);
end;

procedure Tfrmsupporttables.DBGridCountryTitleClick(Column: TColumn);
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


procedure Tfrmsupporttables.FormResize(Sender: TObject);
begin
  ResizeColumns(self);
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
begin
 Q.Close;
 CloseAction:= caFree;
end;


initialization
  {$I flags.lrs}


end.

