unit dm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Controls, IBConnection, sqldb, sqldblib,
  BufDataset, db;

type

  { Tfrmdm }

  Tfrmdm = class(TDataModule)
    DS: TDataSource;
    DSCruiseDetails: TDataSource;
    DSEntry: TDataSource;
    DSCruise: TDataSource;
    IBDB: TIBConnection;
    Q: TSQLQuery;
    q1: TSQLQuery;
    q2: TSQLQuery;
    q3: TSQLQuery;
    QCruiseDetails: TSQLQuery;
    QCruise: TSQLQuery;
    QEntry: TSQLQuery;
    DBLoader: TSQLDBLibraryLoader;
    TR: TSQLTransaction;

    procedure DataModuleDestroy(Sender: TObject);
    procedure QCruiseAfterEdit(DataSet: TDataSet);
    procedure QCruiseAfterScroll(DataSet: TDataSet);
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

procedure Tfrmdm.QCruiseAfterScroll(DataSet: TDataSet);
Var
  ID: int64;
begin
 ID:=QCruise.FieldByName('ID').Value;
 with QCruiseDetails do begin
  Close;
   SQL.Clear;
   SQL.Add(CruiseDetailSQL+Inttostr(ID));
  Open;
 end;
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

