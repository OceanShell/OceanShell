unit osqc_wideranges_upd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids,
  ExtCtrls, Buttons;

type

  { Tfrmwideranges_upd }

  Tfrmwideranges_upd = class(TForm)
    btnStart: TBitBtn;
    chkWrite: TCheckBox;
    DS: TDataSource;
    DBGridTables: TDBGrid;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure DBGridTablesCellClick(Column: TColumn);
    procedure DBGridTablesUserCheckboxState(Sender: TObject; Column: TColumn;
      var AState: TCheckboxState);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private

  public

  end;

var
  frmwideranges_upd: Tfrmwideranges_upd;
  RecList: TBookmarklist;
  isSelected:boolean=true;

implementation

{$R *.lfm}

{ Tfrmwideranges_upd }

uses osmain, dm, osinfo;

procedure Tfrmwideranges_upd.FormShow(Sender: TObject);
begin
  RecList := TBookmarkList.Create(DbGridTables);

   with frmdm.q2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT ');
     SQL.Add(' DATABASE_TABLES.NAME_TABLE, DATABASE_TABLES.UNITS_RANGE_MIN, ');
     SQL.Add(' DATABASE_TABLES.UNITS_RANGE_MAX, UNITS.NAME_SHORT ');
     SQL.Add(' FROM DATABASE_TABLES, UNITS ');
     SQL.Add(' WHERE ');
     SQL.Add(' DATABASE_TABLES.UNITS_ID_DEFAULT=UNITS.ID ');
     SQL.Add(' ORDER BY DATABASE_TABLES.NAME_TABLE ');
    Open;
   end;

end;

procedure Tfrmwideranges_upd.Label1Click(Sender: TObject);
begin
  frmdm.q2.First;
    while not frmdm.q2.EOF do begin
      RecList.CurrentRowSelected := isSelected;
      frmdm.q2.Next;
    end;
  frmdm.q2.First;

  isSelected:=not isSelected;
end;


procedure Tfrmwideranges_upd.FormDestroy(Sender: TObject);
begin
  RecList.Free;
end;

procedure Tfrmwideranges_upd.DBGridTablesCellClick(Column: TColumn);
begin
 if Column.Index=0 then
    RecList.CurrentRowSelected := not RecList.CurrentRowSelected;
end;

procedure Tfrmwideranges_upd.DBGridTablesUserCheckboxState(Sender: TObject;
  Column: TColumn; var AState: TCheckboxState);
begin
  if RecList.CurrentRowSelected then
    AState := cbChecked
  else
    AState := cbUnchecked;
end;


procedure Tfrmwideranges_upd.btnStartClick(Sender: TObject);
Var
  cmd:string;
  tbl_count: integer;
begin
 //form to show log
 if frminfo_open=false then frmInfo := TfrmInfo.Create(Self) else frminfo.SetFocus;
 frminfo.memo1.Clear;
 frminfo.memo1.Lines.Add('Start: '+DateTimeToStr(Now));

 tbl_count:=0;

 // loop over selected tables
   frmdm.q2.First;
    while not frmdm.q2.EOF do begin
      if RecList.CurrentRowSelected=true then begin
       inc(tbl_count);
       cmd:=OceanToolsPath+'QCWideRanges.exe'+
            ' -d '+DBAlias+
            ' -p '+frmdm.q2.FieldByName('NAME_TABLE').Value;
       if chkWrite.Checked=true then cmd:=cmd+' -w'; //write

       frmosmain.RunScript(0, cmd, frmInfo.memo1);
      end;
      frmdm.q2.Next;
    end;
  frminfo.memo1.Lines.Add('Done! Processed '+inttostr(tbl_count)+' tables');
  frminfo.memo1.Lines.Add('Finish: '+DateTimeToStr(Now));
end;

end.

