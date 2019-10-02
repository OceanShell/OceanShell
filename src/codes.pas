unit codes;

{$mode objfpc}{$H+}

interface

uses
  Windows, lclintf, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, ExtCtrls, Menus, sqldb, DB, sortbufds,
  LResources, DBGrids;

type

  { Tfrmcodes }

  Tfrmcodes = class(TForm)
    btnUpdateQC: TBitBtn;
    btnadd: TToolButton;
    btnsave: TToolButton;
    btndelete: TToolButton;
    DBGridUnits: TDBGrid;
    DBGridPI: TDBGrid;
    DBGridPlatform: TDBGrid;
    DBGridCountry: TDBGrid;
    DBGridProject: TDBGrid;
    DBGridInstitute: TDBGrid;
    DBGridInstrument: TDBGrid;
    DBGridSource: TDBGrid;
    DS: TDataSource;
    ePI_ID: TEdit;
    ePI_WOD: TEdit;
    ePI_Name: TEdit;
    eProject_ID: TEdit;
    eInstitute_ID: TEdit;
    eProject_ID1: TEdit;
    eUnits_ID: TEdit;
    eProject_Name1: TEdit;
    eSource_ID: TEdit;
    eUnits_Name: TEdit;
    eProject_WOD: TEdit;
    eInstitute_NODC: TEdit;
    eInstitute_WOD: TEdit;
    eProject_Name: TEdit;
    eInstitute_Name: TEdit;
    ePlatform_NameNative: TEdit;
    ePlatform_Source: TEdit;
    ePlatform_ID: TEdit;
    eCountry_ID: TEdit;
    eProject_WOD1: TEdit;
    eUnits_Empty: TEdit;
    eSource_Name: TEdit;
    imgFlagPlatform: TImage;
    ImgFlagInstitute: TImage;
    lbCountryPlatform: TLabel;
    lbCountryInstitute: TLabel;
    mNotesInstitute: TMemo;
    mNotesUnits: TMemo;
    mNotesProject: TMemo;
    mNotesPI: TMemo;
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
    mNotes: TMemo;
    ePlatform_IMO: TEdit;
    ePlatform_Callsign: TEdit;
    mNotesWOD: TMemo;
    Splitter3: TSplitter;
    tbPI: TTabSheet;
    tbProject: TTabSheet;
    tbInstitute: TTabSheet;
    tbCruise: TTabSheet;
    ToolBar1: TToolBar;
    btncancel: TToolButton;
    ToolButton1: TToolButton;

    procedure btnUpdateQCClick(Sender: TObject);
    procedure DBGridPlatformKeyPress(Sender: TObject; var Key: char);
    procedure ePlatform_IDClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure mNotesKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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

    procedure ePlatform_IDChange(Sender: TObject);
    procedure ePlatform_WODChange(Sender: TObject);
    procedure ePlatform_SourceChange(Sender: TObject);
    procedure ePlatform_NameChange(Sender: TObject);
    procedure ePlatform_NODCChange(Sender: TObject);
    procedure ePlatform_NameNativeChange(Sender: TObject);
    procedure ePlatform_IMOChange(Sender: TObject);
    procedure ePlatform_CallsignChange(Sender: TObject);
    procedure eCountry_ISOChange(Sender: TObject);


  private
    { Private declarations }
    procedure Navigation;
    procedure ResizeColumns;
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

 DBGridPlatform.Columns[0].Width:=64;
 DBGridPlatform.Columns[1].Width:=62;
 DBGridPlatform.Columns[2].Width:=62;
 DBGridPlatform.Columns[3].Width:=62;
 DBGridPlatform.Columns[4].Width:=62;
 DBGridPlatform.Columns[7].Width:=64;

end;


procedure Tfrmcodes.PageControl1Change(Sender: TObject);
begin
 if Q.Active then btnsave.onClick(Self);

 With Q do begin
   Filter:='';
   Filtered:=false;
   SQL.text:='';
   Close;
 end;

 ResizeColumns;

 CodesTblName:='';
 case PageControl1.ActivePageIndex of
  1: begin
       CodesTblName:='PLATFORM';
       Q.SQL.text:='Select ID, NODC_ID, WOD_ID, IMO_ID, CALLSIGN, NAME, '+
                   'NAME_NATIVE, SOURCE FROM PLATFORM ORDER BY NAME';
     end;
  2: begin
       CodesTblName:='COUNTRY';
       Q.SQL.text:='Select ID, ISO_3166, NAME '+
                   'FROM COUNTRY ORDER BY NAME';
     end;
  3: begin
       CodesTblName:='SOURCE';
       Q.SQL.text:='Select ID, NAME '+
                   'FROM SOURCE ORDER BY ID';
     end;
  4: begin
       CodesTblName:='PI';
       Q.SQL.text:='Select ID, WOD_ID, NAME '+
                   'FROM PI ORDER BY NAME';
     end;
  5: begin
       CodesTblName:='PROJECT';
       Q.SQL.text:='Select ID, WOD_ID, NAME '+
                   'FROM PROJECT ORDER BY NAME';
     end;
  6: begin
       CodesTblName:='INSTITUTE';
       Q.SQL.text:='Select ID, WOD_ID, NODC_ID, NAME '+
                   'FROM INSTITUTE ORDER BY NAME';
     end;
  7: begin
       CodesTblName:='INSTRUMENT';
       Q.SQL.text:='Select ID, WOD_ID, NAME '+
                   'FROM INSTRUMENT ORDER BY WOD_ID';
  end;
  8: begin
       CodesTblName:='UNITS';
       Q.SQL.text:='Select ID, NAME_SHORT, NAME '+
                   'FROM UNITS ORDER BY ID';
  end;
 end;

 //If table exists
 if CodesTblName<>'' then begin
  Q.Open;
  Q.Last;
  Q.First;

   // Page title with amount of rows
   if not Q.IsEmpty then
     PageControl1.Page[PageControl1.ActivePageIndex].Caption:=CodesTblName+
                ': '+inttostr(Q.RecordCount);

   Navigation;
 end;
end;

procedure Tfrmcodes.ResizeColumns;
Var
 occup:integer;
begin
//  showmessage(inttostr(PageControl1.ActivePageIndex));
case PageControl1.ActivePageIndex of
 1: begin
    occup:=trunc((DBGridPlatform.Width-20-
            (DBGridPlatform.Columns[0].Width+
             DBGridPlatform.Columns[1].Width+
             DBGridPlatform.Columns[2].Width+
             DBGridPlatform.Columns[3].Width+
             DBGridPlatform.Columns[4].Width+
             DBGridPlatform.Columns[7].Width))/2);

    DBGridPlatform.Columns[5].Width:=occup+1;
    DBGridPlatform.Columns[6].Width:=occup+1;

    ePlatform_ID.Width:=DBGridPlatform.Columns[0].Width+1;
    ePlatform_NODC.Width:=DBGridPlatform.Columns[1].Width;
    ePlatform_WOD.Width:=DBGridPlatform.Columns[2].Width;
    ePlatform_IMO.Width:=DBGridPlatform.Columns[3].Width;
    ePlatform_Callsign.Width:=DBGridPlatform.Columns[4].Width;
    ePlatform_Name.Width:=DBGridPlatform.Columns[5].Width;
    ePlatform_NameNative.Width:=DBGridPlatform.Columns[6].Width;
    ePlatform_Source.Width:=DBGridPlatform.Columns[7].Width;
 end;
 2: begin //COUNTRY
    occup:=trunc(DBGridCountry.Width-20-
           (DBGridCountry.Columns[0].Width+
            DBGridCountry.Columns[1].Width));
           // DBGridCountry.Columns[3].Width+
         //   DBGridCountry.Columns[4].Width));
    DBGridCountry.Columns[2].Width:=occup+1;
 end;
 3: begin
    occup:=trunc(DBGridSource.Width-20-
           (DBGridSource.Columns[0].Width));
    DBGridSource.Columns[1].Width:=occup+1;
 end;
 4: begin
    occup:=trunc(DBGridPI.Width-20-
           (DBGridPI.Columns[0].Width+
            DBGridPI.Columns[1].Width));
    DBGridPI.Columns[2].Width:=occup+1;
 end;
 5: begin
    occup:=trunc(DBGridProject.Width-20-
           (DBGridProject.Columns[0].Width+
            DBGridProject.Columns[1].Width));
    DBGridProject.Columns[2].Width:=occup+1;
 end;
 6: begin
    occup:=trunc(DBGridInstitute.Width-20-
           (DBGridInstitute.Columns[0].Width+
            DBGridInstitute.Columns[1].Width+
            DBGridInstitute.Columns[2].Width));
    DBGridInstitute.Columns[3].Width:=occup+1;
 end;
 7: begin
    occup:=trunc(DBGridInstrument.Width-20-
           (DBGridInstrument.Columns[0].Width+
            DBGridInstrument.Columns[1].Width));
    DBGridInstrument.Columns[2].Width:=occup+1;
 end;
 8: begin
    occup:=trunc(DBGridUnits.Width-20-
           (DBGridUnits.Columns[0].Width+
            DBGridUnits.Columns[1].Width));
    DBGridUnits.Columns[2].Width:=occup+1;
 end;
end;

//Panel4.Width:=trunc(ToolBar1.Width-65-
// (btnAdd.Width+btnDelete.Width+btnCancel.Width+btnUpdateQC.Width));
end;


procedure Tfrmcodes.Navigation;
Var
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
 cc:string;
begin

 (* Platform *)
 if CodesTblName='PLATFORM' then begin
  mNotesICES.Clear;
  mNotesWOD.Clear;
  mNotes.Clear;

 if Q.FieldByName('ID').AsInteger>0 then begin
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.SupportDB;
  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.SupportDB;
  Qt.Transaction:=TRt;
   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add(' select NOTES_ICES, NOTES_WOD, NOTES ');
     SQL.Add(' from PLATFORM where ');
     SQL.Add(' ID='+inttostr(Q.FieldByName('ID').AsInteger));
    Open;
     mNotesICES.Lines.Text:=Qt.FieldByName('NOTES_ICES').AsWideString;
     mNotesWOD.Lines.Text :=Qt.FieldByName('NOTES_WOD').AsWideString;
     mNotes.Lines.Text    :=Qt.FieldByName('NOTES').AsWideString;
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

   cc:=Copy(Q.FieldByName('NODC_ID').AsString, 1, 2);
   if trim(cc)='' then exit;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' select ISO_3166, NAME from COUNTRY ');
      SQL.Add(' where NODC_ID=:code');
      ParamByName('code').AsString:=cc;
     Open;
    end;

    if Qt.IsEmpty=true then
     with Qt do begin
      Close;
       SQL.Clear;
       SQL.Add(' select ISO_3166, NAME from COUNTRY ');
       SQL.Add(' where ISO_3166=:code');
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


 if (CodesTblName<>'COUNTRY') and (Q.FieldByName('ID').AsInteger>0) then begin
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
     if CodesTblName='PROJECT' then begin
       mNotesProject.Clear;
       mNotesProject.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
     end;
     if CodesTblName='INSTITUTE' then begin
       mNotesInstitute.Clear;
       mNotesInstitute.Lines.Text:=Qt.FieldByName('NOTES').AsWideString;
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
end;


(* Delete row *)
procedure Tfrmcodes.btndeleteClick(Sender: TObject);
begin
   if MessageDlg(SDelete+' '+Q.FieldByName('NAME').AsString+'"?',
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

      if (CodesTblName='PLATFORM') and (mNotes.Lines.Text<>'') then begin
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
          ParamByName('NOTES').AsWideString:=mNotes.Lines.Text;
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
         ((CodesTblName='PI') and (mNotesPI.Lines.Text<>'')) or
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
          if (CodesTblName='PI') then ParamByName('NOTES').AsWideString:=mNotesPI.Lines.Text;
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
procedure Tfrmcodes.ePlatform_IDChange(Sender: TObject);
begin
 if (Sender as TEdit).Text='' then exit;
   Q.Locate('ID', StrToInt((Sender as TEdit).Text),[loCaseInsensitive, loPartialKey]);
end;

(* NODC *)
procedure Tfrmcodes.ePlatform_NODCChange(Sender: TObject);
begin
 Q.Filter:='NODC_ID = '+QuotedStr((Sender as TEdit).Text+'*');
 Q.Filtered:=true;
end;

(* WOD *)
procedure Tfrmcodes.ePlatform_WODChange(Sender: TObject);
begin
 if (Sender as TEdit).Text='' then exit;
   Q.Locate('WOD_ID', StrToInt((Sender as TEdit).Text),[loCaseInsensitive, loPartialKey]);
end;

(* IMO *)
procedure Tfrmcodes.ePlatform_IMOChange(Sender: TObject);
begin
 if ePlatform_IMO.Text='' then exit;
   Q.Locate('IMO_ID', StrToInt(ePlatform_IMO.Text),[loCaseInsensitive, loPartialKey]);
end;

(* ISO-3166 code *)
procedure Tfrmcodes.eCountry_ISOChange(Sender: TObject);
begin
 if eCountry_ISO.Text='' then exit;
  Q.Locate('ISO_3166',eCountry_ISO.Text,[loCaseInsensitive, loPartialKey]);
end;

(* Callsign *)
procedure Tfrmcodes.ePlatform_CallsignChange(Sender: TObject);
begin
 Q.Filter:='CALLSIGN = '+QuotedStr('*'+ePlatform_Callsign.Text+'*');
 Q.Filtered:=true;
end;

(* Name *)
procedure Tfrmcodes.ePlatform_NameChange(Sender: TObject);
begin
 Q.Filter:='NAME = '+QuotedStr('*'+(Sender as TEdit).Text+'*');
 Q.Filtered:=true;
end;

(* Platform native name *)
procedure Tfrmcodes.ePlatform_NameNativeChange(Sender: TObject);
begin
  Q.Filter:='NAME_NATIVE = '+QuotedStr('*'+ePlatform_NameNative.Text+'*');
  Q.Filtered:=true;
end;

(* Data source *)
procedure Tfrmcodes.ePlatform_SourceChange(Sender: TObject);
begin
Q.Filter:='SOURCE = '+QuotedStr('*'+ePlatform_Source.Text+'*');
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


procedure Tfrmcodes.mNotesKeyUp(Sender: TObject; var Key: Word;
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
  ResizeColumns;
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


procedure Tfrmcodes.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 Q.Close;
 CloseAction:= caFree;
 frmcodes_open:=false;
end;


initialization
  {$I flags.lrs}


end.

