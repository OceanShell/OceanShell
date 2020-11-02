unit dm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Controls, IBConnection, sqldb, BufDataset, db;

type

  { Tfrmdm }

  Tfrmdm = class(TDataModule)
    DS: TDataSource;
    DSEntry: TDataSource;
    DSCruise: TDataSource;
    IBDB: TIBConnection;
    Q: TSQLQuery;
    q1: TSQLQuery;
    q2: TSQLQuery;
    q3: TSQLQuery;
    QCruise: TSQLQuery;
    QEntry: TSQLQuery;
    TR: TSQLTransaction;

    procedure DataModuleDestroy(Sender: TObject);
    procedure QCruiseAfterEdit(DataSet: TDataSet);
    procedure QCruiseBeforePost(DataSet: TDataSet);
    procedure QEntryAfterEdit(DataSet: TDataSet);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmdm: Tfrmdm;


implementation

{$R *.lfm}

{ Tfrmdm }

uses osmain;

procedure Tfrmdm.QCruiseAfterEdit(DataSet: TDataSet);
begin
 frmosmain.btnSaveCruise.Enabled:=true;
end;

procedure Tfrmdm.QCruiseBeforePost(DataSet: TDataSet);
begin
  QCruise.FieldByName('DATE_UPDATED').AsDateTime:=now;
end;

procedure Tfrmdm.QEntryAfterEdit(DataSet: TDataSet);
begin
  frmosmain.btnSaveEntry.Enabled:=true;
end;

procedure Tfrmdm.DataModuleDestroy(Sender: TObject);
begin
 TR.Commit;
 IBDB.Close(true);
end;

end.

