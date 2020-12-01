unit osqc_dbar_meters_consistency;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  DB, SQLDB, LCLintf;

type

  { Tfrmqc_dbar_meters_consistency }

  Tfrmqc_dbar_meters_consistency = class(TForm)
    btnRun: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    seThreshold: TFloatSpinEdit;

    procedure btnCancelClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);

  private

  public

  end;

var
  frmqc_dbar_meters_consistency: Tfrmqc_dbar_meters_consistency;
  cancel_run:boolean=false;

implementation

{$R *.lfm}

{ Tfrmqc_dbar_meters_consistency }

uses osmain, dm, gibbsseawater, procedures;

procedure Tfrmqc_dbar_meters_consistency.btnRunClick(Sender: TObject);
Var
 dat: text;
 pp, ID: integer;
 LAT, LEV_M0, LEV_M1, LEV_D0, LEV_D1:real;
 tbl, fpath:string;
 TRt:TSQLTransaction;
 Qt:TSQLQuery;
begin

 if MessageDlg('This procedure will check the entire database and take time. Proceed?',
   mtInformation, [MbYes, mbNo], 0)=mrNo then exit;

 btnRun.Enabled:=false;
 cancel_run:=false;

 fpath:=GlobalUnloadPath+'QC'+PathDelim;
 if not DirectoryExists(fpath) then CreateDir(fpath);

  AssignFile(dat, fpath+'QC_dbar_meters_corresp.txt'); Rewrite(dat);
  writeln(dat, 'ID   lev_m0   lev_m1   lev_d0   lev_d1   lev_m_diff   lev_dbar_diff');


TRt:=TSQLTransaction.Create(nil);
TRt.DataBase:=frmdm.IBDB;

Qt :=TSQLQuery.Create(nil);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=TRt;
 try
   for pp:=0 to frmosmain.ListBox1.Count-1 do begin
     tbl:=frmosmain.ListBox1.Items.Strings[pp];
     writeln(dat, '=====');
     writeln(dat, tbl);

     with Qt do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT STATION.ID, STATION.LATITUDE, LEV_M, LEV_DBAR ');
       SQL.Add(' FROM STATION, '+tbl);
       SQL.Add(' WHERE STATION.ID='+tbl+'.ID ');
       SQL.Add(' ORDER BY ID, LEV_DBAR, LEV_M ');
      Open;
     end;

     while not Qt.EOF do begin;
      ID:=Qt.FieldByName('ID').AsInteger;
      LAT:=Qt.FieldByName('LATITUDE').AsFloat;
      LEV_M0:=Qt.FieldByName('LEV_M').AsFloat;
      LEV_D0:=Qt.FieldByName('LEV_DBAR').AsFloat;

      LEV_D1:=gibbsseawater.gsw_p_from_z(-LEV_M0, lat, 0, 0);
      LEV_M1:=-gibbsseawater.gsw_z_from_p(LEV_D0, lat, 0, 0);

     { showmessage());  }

     if (abs(lev_m0-lev_m1) > seThreshold.Value) or
        (abs(lev_d0-lev_d1) > seThreshold.Value) then
      writeln(dat, inttostr(ID)+'   '+
                   floattostr(lev_m0)+'   '+
                   floattostr(lev_m1)+'   '+
                   floattostr(lev_d0)+'   '+
                   floattostr(lev_d1)+'   '+
                   floattostr(lev_m0-lev_m1)+'   '+
                   floattostr(lev_d0-lev_d1));

      if cancel_run then break;
      application.ProcessMessages;

      qt.Next;
     end;
     {$IFDEF WINDOWS}
        Procedures.ProgressTaskbar(pp, frmosmain.ListBox1.Count-1);
     {$ENDIF}

   end;
  finally
     closefile(dat);
     Qt.close;
     TRt.Commit;
     Qt.free;
     TrT.free;

     {$IFDEF WINDOWS}
        Procedures.ProgressTaskbar(0, 0);
     {$ENDIF}

     btnRun.Enabled:=true;
     OpenDocument(fpath+'QC_dbar_meters_corresp.txt');
   end;
end;

procedure Tfrmqc_dbar_meters_consistency.btnCancelClick(Sender: TObject);
begin
  cancel_run:=true;
end;

end.

