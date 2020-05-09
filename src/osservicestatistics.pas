unit osservicestatistics;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SQLDB, DB;

type

  { Tfrmservicestatistics }

  Tfrmservicestatistics = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  frmservicestatistics: Tfrmservicestatistics;

implementation

{$R *.lfm}

{ Tfrmservicestatistics }

uses osmain, dm;

procedure Tfrmservicestatistics.Button1Click(Sender: TObject);
Var
  k: integer;
  tbl:string;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
  memo1.Clear;

  try
  TRt:=TSQLTransaction.Create(nil);
  TRt.DataBase:=frmdm.IBDB;

  Qt:=TSQLQuery.Create(nil);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

  for k:=0 to frmosmain.ListBox1.Count-1 do begin
    tbl:=frmosmain.ListBox1.Items.Strings[k];

    Qt.Close;
    Qt.SQL.Text:= 'Select distinct(units_id) from '+tbl;
    Qt.Open;

    while not Qt.Eof do begin
      memo1.Lines.Add(tbl+ ': '+Inttostr(Qt.Fields[0].AsInteger));
      Qt.Next;
    end;
    Qt.Close;
  end;

  finally
    Trt.Commit;
    Qt.Free;
    Trt.Free;
  end;
end;


end.

