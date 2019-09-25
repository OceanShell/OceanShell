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
    btnadd: TToolButton;
    btncommit: TToolButton;
    btndelete: TToolButton;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DS: TDataSource;
    ePlatform_NameNative: TEdit;
    ePlatform_Source: TEdit;
    ePlatform_ID: TEdit;
    eCountry_ID: TEdit;
    Image1: TImage;
    lbCountry: TLabel;
    Panel2: TPanel;
    ePlatform_Name: TEdit;
    Panel3: TPanel;
    ePlatform_NODC: TEdit;
    Panel4: TPanel;
    Panel8: TPanel;
    Q: TSQLQuery;
    Splitter1: TSplitter;
    PageControl1: TPageControl;
    tbSource: TTabSheet;
    tbPlatform: TTabSheet;
    tbCountry: TTabSheet;
    Panel5: TPanel;
    Panel6: TPanel;
    eCountry_Name: TEdit;
    eCountry_ISOAlpha2: TEdit;
    eCountry_OCL: TEdit;
    eCountry_NODC: TEdit;
    ePlatform_OCL: TEdit;
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
    btnUpdateQC: TToolButton;

    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure mNotesKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PageControl1Change(Sender: TObject);
    procedure QAfterScroll(DataSet: TDataSet);

    procedure btnaddClick(Sender: TObject);
    procedure btndeleteClick(Sender: TObject);
    procedure btncancelClick(Sender: TObject);
    procedure btncommitClick(Sender: TObject);
    procedure btnUpdateQCClick(Sender: TObject);

    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure DBGrid2TitleClick(Column: TColumn);

    procedure ePlatform_IDChange(Sender: TObject);
    procedure ePlatform_OCLChange(Sender: TObject);
    procedure ePlatform_SourceChange(Sender: TObject);
    procedure ePlatform_NameChange(Sender: TObject);
    procedure ePlatform_NameClick(Sender: TObject);
    procedure ePlatform_NODCChange(Sender: TObject);
    procedure ePlatform_NameNativeChange(Sender: TObject);
    procedure ePlatform_IMOChange(Sender: TObject);
    procedure ePlatform_CallsignChange(Sender: TObject);

    procedure eCountry_IDChange(Sender: TObject);
    procedure eCountry_NameChange(Sender: TObject);
    procedure eCountry_ISOAlpha2Change(Sender: TObject);
    procedure eCountry_NameClick(Sender: TObject);
    procedure eCountry_OCLChange(Sender: TObject);
    procedure eCountry_NODCChange(Sender: TObject);


  private
    { Private declarations }
    procedure Navigation;
  public
    { Public declarations }
  end;

var
  frmcodes: Tfrmcodes;
  CodesTblName: string; //Global active table name

implementation

{$R *.lfm}

uses dm, codesupdateqc;

procedure Tfrmcodes.FormShow(Sender: TObject);
begin
 PageControl1.OnChange(self);

 DBGrid1.Columns[0].Width:=55;
 DBGrid1.Columns[1].Width:=55;
 DBGrid1.Columns[2].Width:=60;
 DBGrid1.Columns[3].Width:=60;
 DBGrid1.Columns[4].Width:=60;
 DBGrid1.Columns[7].Width:=70;

 frmcodes.OnResize(self);
end;


procedure Tfrmcodes.PageControl1Change(Sender: TObject);
begin
 With Q do begin
   Filter:='';
   Filtered:=false;
   SQL.text:='';
   Close;
 end;

 CodesTblName:='';
 case PageControl1.ActivePageIndex of
  0: begin
       CodesTblName:='PLATFORM';
       Q.SQL.text:='Select ID, NODC_ID, OCL_ID, IMO_ID, CALLSIGN, NAME, '+
                   'NAME_NATIVE, SOURCE FROM PLATFORM ORDER BY NAME';
     end;
  1: begin
       CodesTblName:='COUNTRY';
       Q.SQL.text:='Select ID, NODC_ID, OCL_ID, ISO_ALPHA2, NAME '+
                   'FROM COUNTRY ORDER BY NAME';
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

   lbCountry.Caption:=''; Image1.Picture.Clear;
   cc:=Copy(Q.FieldByName('NODC_ID').AsString, 1, 2);
   if trim(cc)='' then exit;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' select ISO_ALPHA2, NAME from COUNTRY ');
      SQL.Add(' where NODC_ID=:code');
      ParamByName('code').AsString:=cc;
     Open;
    end;

    if Qt.IsEmpty=true then
     with Qt do begin
      Close;
       SQL.Clear;
       SQL.Add(' select ISO_ALPHA2, NAME from COUNTRY ');
       SQL.Add(' where ISO_ALPHA2=:code');
       ParamByName('code').AsString:=cc;
      Open;
    end;

    if Qt.IsEmpty=false then begin
       try
         Image1.Picture.LoadFromLazarusResource(LowerCase(Qt.Fields[0].AsString+'_32'));
       except
       end;
       lbCountry.Caption:=Qt.Fields[1].AsString;
      end;
    Qt.Close;
   end;
   TRt.Commit;
   Qt.Free;
   TRt.Free;
 end; //End Platform
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
  Q.Delete;
end;


(* Cancel changes *)
procedure Tfrmcodes.btncancelClick(Sender: TObject);
begin
  Q.Cancel;
end;


(* Save changes *)
procedure Tfrmcodes.btncommitClick(Sender: TObject);
Var
 Qt:TSQLQuery;
begin
   if Q.Modified then Q.Post;
      Q.ApplyUpdates(-1);
      frmdm.SupportTR.CommitRetaining;

      if (CodesTblName='PLATFORM') and (trim(mNotes.Lines.Text)<>'') then begin
        With Qt do begin
         Close;
          SQL.Clear;
          SQL.Add(' Update PLATFORM set ');
          SQL.Add(' NOTES=:NOTES ');
          SQL.Add(' where ID=:ID ');
          ParamByName('ID').AsInteger:=Q.FieldByName('ID').AsInteger;
          ParamByName('NOTES').AsBlob:=mNotes.Lines.Text;
         ExecSQL;
        end;
        frmdm.SupportTR.CommitRetaining;
      end;
     Qt.Free;
end;


(* Update and QC procedures *)
procedure Tfrmcodes.btnUpdateQCClick(Sender: TObject);
begin
frmcodesQC := TfrmcodesQC.Create(Self);
 try
  if not frmcodesQC.ShowModal = mrOk then exit;
 finally
   frmcodesQC.Free;
   frmcodesQC := nil;
 end;
end;


(******************** Fast search in PLATFORM *********************************)
procedure Tfrmcodes.ePlatform_IDChange(Sender: TObject);
begin
 if ePlatform_ID.Text='' then exit;
   Q.Locate('ID', StrToInt(ePlatform_ID.Text),[loCaseInsensitive, loPartialKey]);
end;

(* NODC*)
procedure Tfrmcodes.ePlatform_NODCChange(Sender: TObject);
begin
 Q.Filter:='NODC_ID = '+QuotedStr(ePlatform_NODC.Text+'*');
 Q.Filtered:=true;
end;

(* OCL *)
procedure Tfrmcodes.ePlatform_OCLChange(Sender: TObject);
begin
 if ePlatform_OCL.Text='' then exit;
   Q.Locate('OCL_ID', StrToInt(ePlatform_OCL.Text),[loCaseInsensitive, loPartialKey]);
end;

(* IMO *)
procedure Tfrmcodes.ePlatform_IMOChange(Sender: TObject);
begin
 if ePlatform_IMO.Text='' then exit;
   Q.Locate('IMO_ID', StrToInt(ePlatform_IMO.Text),[loCaseInsensitive, loPartialKey]);
end;

(* Callsign *)
procedure Tfrmcodes.ePlatform_CallsignChange(Sender: TObject);
begin
 Q.Filter:='CALLSIGN = '+QuotedStr('*'+ePlatform_Callsign.Text+'*');
 Q.Filtered:=true;
end;

(* Platform name *)
procedure Tfrmcodes.ePlatform_NameChange(Sender: TObject);
begin
 Q.Filter:='NAME = '+QuotedStr('*'+ePlatform_Name.Text+'*');
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


(************************* Fast search in COUNTRY ****************************)
procedure Tfrmcodes.eCountry_IDChange(Sender: TObject);
begin
 if eCountry_ID.Text='' then exit;
   Q.Locate('ID',eCountry_ID.Text,[loCaseInsensitive, loPartialKey]);
end;

procedure Tfrmcodes.eCountry_NODCChange(Sender: TObject);
begin
if eCountry_NODC.Text='' then exit;
  Q.Locate('NODC_ID',eCountry_NODC.Text,[loCaseInsensitive, loPartialKey]);
end;

procedure Tfrmcodes.eCountry_OCLChange(Sender: TObject);
begin
 if eCountry_OCL.Text<>'' then
  Q.Locate('OCL_ID',eCountry_OCL.Text,[loCaseInsensitive, loPartialKey]);
end;

procedure Tfrmcodes.eCountry_ISOAlpha2Change(Sender: TObject);
begin
 if eCountry_ISOAlpha2.Text='' then exit;
  Q.Locate('ISO_ALPHA2',eCountry_ISOAlpha2.Text,[loCaseInsensitive, loPartialKey]);
end;

(* Быстрый поиск по названию страны *)
procedure Tfrmcodes.eCountry_NameChange(Sender: TObject);
begin
  Q.Filter:='NAME = '+QuotedStr('*'+eCountry_Name.Text+'*');
  Q.Filtered:=true;
end;


procedure Tfrmcodes.ePlatform_NameClick(Sender: TObject);
begin
 ePlatform_ID.Clear;
 ePlatform_Name.Clear;
 ePlatform_NameNative.Clear;
 ePlatform_NODC.Clear;
 ePlatform_OCL.Clear;
 ePlatform_IMO.Clear;
 ePlatform_Callsign.Clear;
 ePlatform_Source.Clear;

 Q.Filtered:=false;
end;

procedure Tfrmcodes.eCountry_NameClick(Sender: TObject);
begin
 eCountry_ID.Clear;
 eCountry_Name.Clear;
 eCountry_NODC.Clear;
 eCountry_OCL.Clear;
 eCountry_ISOAlpha2.Clear;

 Q.Filtered:=false;
end;


procedure Tfrmcodes.DBGrid1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key=VK_UP) or (key=VK_DOWN) then Navigation;
end;

procedure Tfrmcodes.DBGrid1TitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(Q, Column.FieldName);
end;

procedure Tfrmcodes.DBGrid2TitleClick(Column: TColumn);
begin
  sortbufds.SortBufDataSet(Q, Column.FieldName);
end;


procedure Tfrmcodes.DBGrid1CellClick(Column: TColumn);
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


procedure Tfrmcodes.FormResize(Sender: TObject);
Var
 occup:integer;
begin

case PageControl1.ActivePageIndex of
 0: begin
    occup:=trunc((DBGrid1.Width-20-
            (DBGrid1.Columns[0].Width+
             DBGrid1.Columns[1].Width+
             DBGrid1.Columns[2].Width+
             DBGrid1.Columns[3].Width+
             DBGrid1.Columns[4].Width+
             DBGrid1.Columns[7].Width))/2);

    DBGrid1.Columns[5].Width:=occup+1;
    DBGrid1.Columns[6].Width:=occup+1;

    ePlatform_ID.Width:=DBGrid1.Columns[0].Width+1;
    ePlatform_NODC.Width:=DBGrid1.Columns[1].Width;
    ePlatform_OCL.Width:=DBGrid1.Columns[2].Width;
    ePlatform_IMO.Width:=DBGrid1.Columns[3].Width;
    ePlatform_Callsign.Width:=DBGrid1.Columns[4].Width;
    ePlatform_Name.Width:=DBGrid1.Columns[5].Width;
    ePlatform_NameNative.Width:=DBGrid1.Columns[6].Width;
    ePlatform_Source.Width:=DBGrid1.Columns[7].Width;
 end;
 1: begin
    occup:=trunc(DBGrid2.Width-20-
           (DBGrid2.Columns[0].Width+
            DBGrid2.Columns[1].Width+
            DBGrid2.Columns[2].Width+
            DBGrid2.Columns[3].Width));
    DBGrid2.Columns[4].Width:=occup+1;
 end;
end;

Panel4.Width:=trunc(ToolBar1.Width-65-
 (btnAdd.Width+btnDelete.Width+btnCancel.Width+btnUpdateQC.Width));
end;


procedure Tfrmcodes.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 Q.Close;
end;


initialization
  {$I flags.lrs}


end.

