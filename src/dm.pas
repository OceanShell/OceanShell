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
    q2: TSQLQuery;
    q3: TSQLQuery;
    IBDB: TIBConnection;
    Q: TSQLQuery;
    QCruise: TSQLQuery;
    QEntry: TSQLQuery;
    SupportDB: TIBConnection;
    TR: TSQLTransaction;
    q1: TSQLQuery;
    SupportTR: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);

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


procedure Tfrmdm.DataModuleCreate(Sender: TObject);
begin
{   (* if there's no support database then exit *)
 if not FileExists(GlobalPath+'SUPPORTTABLES.FDB') then
   if MessageDlg(SNoSupportDB, mtError, [mbOK], 0)=mrOk  then Exit;

 (* opening the support database *)
 SupportDB.DatabaseName:=GlobalPath+'SUPPORTTABLES.FDB';
 SupportDB.Open; }
end;


procedure Tfrmdm.DataModuleDestroy(Sender: TObject);
begin
 TR.Commit;
 IBDB.Close(true);

 SupportTR.Commit;
 SupportDB.Close(true);
end;

end.

