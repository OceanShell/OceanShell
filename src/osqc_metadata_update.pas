unit osqc_metadata_update;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  SQLDB, DB;

type

  { Tfrmqc_metadata_update }

  Tfrmqc_metadata_update = class(TForm)
    btnUpdate: TButton;
    cbSTATIONQCFlag: TComboBox;
    PageControl1: TPageControl;
    rbSTATION_QCFLAG: TRadioButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;

    procedure btnUpdateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    procedure SetSTATION_QCFlag;
  public

  end;

var
  frmqc_metadata_update: Tfrmqc_metadata_update;

implementation

{$R *.lfm}

uses osmain, dm, procedures;

{ Tfrmqc_metadata_update }

procedure Tfrmqc_metadata_update.FormShow(Sender: TObject);
begin
  cbStationQCFlag.Items:=frmosmain.cgQCFlag.Items;
end;


procedure Tfrmqc_metadata_update.btnUpdateClick(Sender: TObject);
begin
  btnUpdate.Enabled:=false;
    if rbSTATION_QCFLAG.Checked then SetSTATION_QCFlag;
  btnUpdate.Enabled:=true;
end;


procedure Tfrmqc_metadata_update.SetSTATION_QCFlag;
Var
  Qt:TSQLQuery;
  TRt:TSQLTransaction;

  QF:smallint;
  cnt, k: integer;
begin
  if cbSTATIONQCFlag.ItemIndex=-1 then
    if MessageDlg('Please, select QC flag', mtWarning, [mbOk], 0)=mrOk then exit;

 QF:=StrToInt(copy(cbSTATIONQCFlag.Text, 2, Pos(']', cbSTATIONQCFlag.Text)-2));

 try
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt:=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

  try

  cnt:=frmdm.Q.RecordCount;
  k:=0;

  frmdm.Q.DisableControls;
  frmdm.Q.First;
  while not frmdm.Q.Eof do begin //w
   inc(k);
    with Qt do begin
     Close;
       SQL.Clear;
       SQL.Add(' UPDATE STATION ');
       SQL.Add(' SET QCFLAG=:QF ');
       SQL.Add(' WHERE ID=:ID ');
       ParamByName('ID').Value:=frmdm.Q.fieldByName('ID').Value;
       ParamByName('QF').Value:=QF;
     ExecSQL;
    end;

    ProgressTaskbar(k, cnt);

   frmdm.Q.Next;
  end;
  Trt.Commit;
  Showmessage('Update was successfully applied');
  except
    on e: Exception do
      if MessageDlg('Update failed: '+e.message, mtError, [mbOk], 0)=mrOk then begin
        Trt.Rollback;
        Close;
      end;
  end;

 finally
   Qt.Free;
   Trt.Free;
   ProgressTaskbar(0, 0);
   frmdm.Q.EnableControls;
 end;
end;

end.

