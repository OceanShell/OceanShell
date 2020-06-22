unit osimport_fdb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, IBConnection,
  SQLDB, DB;

type

  { Tfrmimport_fdb }

  Tfrmimport_fdb = class(TForm)
    btnImportCruise: TButton;
    btnImportCruise1: TButton;
    btnImportCruise2: TButton;
    btnOpenDB2: TButton;
    ePathDB2: TEdit;
    Memo1: TMemo;

    procedure btnImportCruise1Click(Sender: TObject);

  private

  public

  end;

var
  frmimport_fdb: Tfrmimport_fdb;

implementation

{$R *.lfm}

{ Tfrmimport_fdb }

uses osmain, dm;


procedure Tfrmimport_fdb.btnImportCruise1Click(Sender: TObject);
Var
DB_NEW:TIBConnection;
TR_NEW:TSQLTransaction;
Q_NEW, Q_OCEAN:TSQLQuery;
k, stver:integer;
tbl:string;
begin
 try

 if not FileExists(ePAthDB2.Text) then begin
  showmessage('New database is not found');
  exit;
 end;

   (* Opening NEW database *)
   DB_NEW:=TIBConnection.Create(nil);
   TR_NEW:=TSQLTransaction.Create(nil);
   Q_NEW:=TSQLQuery.Create(nil);

   DB_NEW.Transaction:=TR_NEW;
   TR_NEW.Database:=DB_NEW;
   Q_NEW.Transaction:=TR_NEW;
   Q_NEW.Database:=DB_NEW;

   DB_NEW.DatabaseName:=(ePathDB2.text);
   DB_NEW.UserName:='SYSDBA';
   DB_NEW.Password:='masterkey';
   DB_NEW.LoginPrompt:=False;
   DB_NEW.Connected:=True;

   Q_NEW.Close;
   Q_NEW.SQL.Text:='SELECT * FROM STATION ORDER BY ID';
   Q_NEW.Open;

        while not Q_NEW.EOF do begin
          With frmdm.q1 do begin
            Close;
             SQL.Clear;
             SQL.Add(' SELECT count(ID) FROM STATION WHERE ');
             SQL.Add(' LATITUDE=:LAT AND LONGITUDE=:LON AND ');
             SQL.Add(' DATEANDTIME=:DATE1 ');
             ParamByName('LAT').Value:=Q_NEW.FieldByName('LATITUDE').Value;
             ParamByName('LON').Value:=Q_NEW.FieldByName('LONGITUDE').Value;
             ParamByName('DATE1').Value:=Q_NEW.FieldByName('DATEANDTIME').Value;
            Open;
              if not frmdm.q1.IsEmpty then stver:=frmdm.q1.Fields[0].AsInteger+1 else stver:=0;
            Close;
          end;

         try
          With frmdm.q1 do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO STATION ');
             SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, BOTTOMDEPTH, LASTLEVEL_M, ');
             SQL.Add(' LASTLEVEL_DBAR, CRUISE_ID, ST_NUMBER_ORIGIN, ST_ID_ORIGIN, ');
             SQL.Add(' CAST_NUMBER, QCFLAG, STVERSION, MERGED, DUPLICATE, ');
             SQL.Add(' ACCESSION_NUMBER, DATE_ADDED, DATE_UPDATED) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :BOTTOMDEPTH, :LASTLEVEL_M, ');
             SQL.Add(' :LASTLEVEL_DBAR, :CRUISE_ID, :ST_NUMBER_ORIGIN, :ST_ID_ORIGIN, ');
             SQL.Add(' :CAST_NUMBER, :QCFLAG, :STVERSION, :MERGED, :DUPLICATE, ');
             SQL.Add(' :ACCESSION_NUMBER, :DATE_ADDED, :DATE_UPDATED) ');
             ParamByName('ID').Value:=Q_NEW.FieldByName('ID').Value;
             ParamByName('LATITUDE').Value:=Q_NEW.FieldByName('LATITUDE').Value;
             ParamByName('LONGITUDE').Value:=Q_NEW.FieldByName('LONGITUDE').Value;
             ParamByName('DATEANDTIME').Value:=Q_NEW.FieldByName('DATEANDTIME').Value;
             ParamByName('LASTLEVEL_M').Value:=Q_NEW.FieldByName('LASTLEVEL_M').Value;
             ParamByName('LASTLEVEL_DBAR').Value:=Q_NEW.FieldByName('LASTLEVEL_DBAR').Value;
             ParamByName('CRUISE_ID').Value:=Q_NEW.FieldByName('CRUISE_ID').Value;
             ParamByName('ST_NUMBER_ORIGIN').Value:=Q_NEW.FieldByName('ST_NUMBER_ORIGIN').Value;
             ParamByName('ST_ID_ORIGIN').Value:=Q_NEW.FieldByName('ST_ID_ORIGIN').Value;
             ParamByName('CAST_NUMBER').Value:=Q_NEW.FieldByName('CAST_NUMBER').Value;
             ParamByName('QCFLAG').Value:=Q_NEW.FieldByName('QCFLAG').Value;
             ParamByName('STVERSION').Value:=stver;
             ParamByName('MERGED').Value:=Q_NEW.FieldByName('MERGED').Value;
             ParamByName('DUPLICATE').Value:=Q_NEW.FieldByName('DUPLICATE').Value;
             ParamByName('ACCESSION_NUMBER').Value:=Q_NEW.FieldByName('ACCESSION_NUMBER').Value;
             ParamByName('DATE_ADDED').Value:=Q_NEW.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_NEW.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
           frmdm.Tr.CommitRetaining;
          except
           // memo1.lines.add(inttostr(Q_NEW.FieldByName('ID').Value));
            showmessage(inttostr(Q_NEW.FieldByName('ID').Value)+'   '+inttostr(stver));
            frmdm.Tr.RollbackRetaining;
          end;
          Q_NEW.Next;
        end;

 finally
  TR_NEW.Commit;
  Q_NEW.Free;
  TR_NEW.Free;
  DB_NEW.Connected:=false;
  DB_NEW.Free;
 end;

end;


end.

