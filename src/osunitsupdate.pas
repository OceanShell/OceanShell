unit osunitsupdate;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SQLDB, DB;

type

  { Tfrmuntsupdate }

  Tfrmuntsupdate = class(TForm)
    btnUpdate: TButton;
    cbParameters: TComboBox;
    cbUnits: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    procedure btnUpdateClick(Sender: TObject);
    procedure cbParametersChange(Sender: TObject);
    procedure cbUnitsChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmuntsupdate: Tfrmuntsupdate;

implementation

{$R *.lfm}

{ Tfrmuntsupdate }

uses osmain, dm, procedures;

procedure Tfrmuntsupdate.FormShow(Sender: TObject);
Var
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
begin

cbParameters.Items:=frmosmain.ListBox1.Items;

TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt :=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=TRt;
 try
   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT DISTINCT(NAME) FROM UNITS ORDER BY ID ');
    Open;
   end;

   while not Qt.EOF do begin
      cbUnits.Items.Add(Qt.Fields[0].AsString);
     Qt.Next;
   end;
 finally
   Qt.Close;
   Qt.Free;
   Trt.Commit;
   Trt.Free;
 end;
end;

procedure Tfrmuntsupdate.cbParametersChange(Sender: TObject);
begin
  cbUnits.Enabled:=true;
end;

procedure Tfrmuntsupdate.cbUnitsChange(Sender: TObject);
begin
  btnUpdate.Enabled:=true;
end;


procedure Tfrmuntsupdate.btnUpdateClick(Sender: TObject);
Var
 ID_OLD, ID, U_ID, k: integer;
begin


    with frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT ID FROM UNITS WHERE ');
      SQL.Add(' NAME=:u_name ');
      ParamByName('u_name').AsString:=cbUnits.Text;
     Open;
      U_ID:=Fields[0].AsInteger;
     Close;
    end;

  try
    ID_OLD:=frmdm.Q.FieldByName('ID').AsInteger;

    frmdm.Q.DisableControls;
    frmdm.Q.First;

    while not frmdm.Q.EOF do begin
      inc(k);
      ID:=frmdm.Q.FieldByName('ID').AsInteger;

         with frmdm.q1 do begin
           Close;
             SQL.Clear;
             SQL.Add(' UPDATE '+cbParameters.Text);
             SQL.Add(' SET UNITS_ID=:U_ID WHERE ');
             SQL.Add(' ID=:ID ');
             ParamByName('ID').AsInteger:=ID;
             ParamByName('U_ID').AsInteger:=U_ID;
           ExecSQL;
         end;

      Procedures.ProgressTaskbar(k, frmdm.QCruise.RecordCount-1);
      frmdm.Q.Next;
    end;

  Showmessage('Units successfully updated');
  finally
    frmdm.TR.CommitRetaining;
    frmdm.Q.Locate('ID', ID_OLD, []);
    frmdm.Q.EnableControls;
   Close;
  end;
end;



end.

