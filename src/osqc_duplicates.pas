unit osqc_duplicates;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  SQLDB, DB, DateUtils, LCLIntf;

type

  { Tfrmqc_duplicates }

  Tfrmqc_duplicates = class(TForm)
    btnFindDuplicates: TButton;
    btnUpdateCruise: TButton;
    btnMarkCruiseDuplicate: TButton;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    seRatio: TSpinEdit;
    seThreshold: TFloatSpinEdit;
    seDateThreshold: TSpinEdit;

    procedure btnFindDuplicatesClick(Sender: TObject);
    procedure btnUpdateCruiseClick(Sender: TObject);
    procedure btnMarkCruiseDuplicateClick(Sender: TObject);

  private

  public

  end;

var
  frmqc_duplicates: Tfrmqc_duplicates;

implementation

{$R *.lfm}

{ Tfrmqc_duplicates }

uses osmain, dm, procedures;


procedure Tfrmqc_duplicates.btnFindDuplicatesClick(Sender: TObject);
Var
TRt:TSQLTransaction;
Qt1, Qt2, Qt3:TSQLQuery;

k, cnt_dup, r_lev:integer;
begin


try
btnFindDuplicates.Enabled:=false;
btnUpdateCruise.Enabled:=false;
btnMarkCruiseDuplicate.Enabled:=false;

TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt1 :=TSQLQuery.Create(self);
Qt1.Database:=frmdm.IBDB;
Qt1.Transaction:=TRt;

Qt2 :=TSQLQuery.Create(self);
Qt2.Database:=frmdm.IBDB;
Qt2.Transaction:=TRt;

(*
There are 3 ratings:
1 - the highest, initial sources
2 - trusted compilations
3 - al the rest

We start with selecting all the stations with the rating=1, and then look for
duplicates in stations with the rating=2. Then we select all the stations with
raitings<=2, and look for duplicates in stations with the rating =3 *)

  cnt_dup:=0;
  for r_lev:=1 to 2 do begin //rating levels

   (* Select the highest rating first *)
   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT STATION.ID, LATITUDE, LONGITUDE, DATEANDTIME ');
     SQL.Add(' FROM STATION WHERE ');
     SQL.Add(' CRUISE_ID IN (SELECT CRUISE.ID FROM CRUISE, SOURCE WHERE ');
     SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND SOURCE.PRIORITY <= :R_LEV ');
     SQL.Add(' AND SOURCE.NAME <> '+QuotedStr('ARGO'));
     SQL.Add(' AND SOURCE.NAME <> '+QuotedStr('ITP')+')');
     SQL.Add(' ORDER BY STATION.ID ');
     ParamByName('R_LEV').Value:=r_lev;
    Open;
    Last;
    First;
   end;


   k:=0;
   while not Qt1.EOF do begin
    inc(k);
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT STATION.ID ');
       SQL.Add(' FROM STATION, CRUISE, SOURCE WHERE ');
       SQL.Add(' STATION.CRUISE_ID=CRUISE.ID AND ');
       SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
       SQL.Add(' SOURCE.PRIORITY=:R_LEV AND ');
       SQL.Add(' LATITUDE BETWEEN :LatMin AND :LatMax AND ');
       SQL.Add(' LONGITUDE BETWEEN :LonMin AND :LonMax AND ');
       SQL.Add(' DATEANDTIME BETWEEN :DateMin AND :DateMax AND ');
       SQL.Add(' STATION.DUPLICATE=FALSE ');
       ParamByName('R_LEV').Value:=r_lev+1; //One step lower
       ParambyName('LatMin').AsFloat:=Qt1.FieldByName('LATITUDE').AsFloat-seThreshold.Value;
       ParambyName('LatMax').AsFloat:=Qt1.FieldByName('LATITUDE').AsFloat+seThreshold.Value;
       ParambyName('LonMin').AsFloat:=Qt1.FieldByName('LONGITUDE').AsFloat-seThreshold.Value;
       ParambyName('LonMax').AsFloat:=Qt1.FieldByName('LONGITUDE').AsFloat+seThreshold.Value;
       ParambyName('DateMin').AsDateTime:=IncDay(Qt1.FieldByName('DATEANDTIME').AsDateTime, -seDateThreshold.Value);
       ParambyName('DateMax').AsDateTime:=IncDay(Qt1.FieldByName('DATEANDTIME').AsDateTime,  seDateThreshold.Value);
     Open;
   end;

      while not Qt2.EOF do begin
       inc(cnt_dup);
        with frmdm.q1 do begin
         Close;
           SQL.Clear;
           SQL.Add(' UPDATE STATION SET ');
           SQL.Add(' DUPLICATE=TRUE WHERE');
           SQL.Add(' ID=:ID AND DUPLICATE=FALSE');
           ParamByName('ID').AsInteger:=Qt2.FieldByName('ID').AsInteger;
         ExecSQL;
        end;
        Qt2.Next;
        caption:='Step: '+inttostr(r_lev)+', Duplicates: '+inttostr(cnt_dup);
        Application.ProcessMessages;
      end;

     {$IFDEF WINDOWS}
        Procedures.ProgressTaskbar(k, qt1.RecordCount);
     {$ENDIF}

    Qt1.Next;
   end;

  end; //r_lev


 finally
  Showmessage('Found '+inttostr(cnt_dup)+' duplicates');

  {$IFDEF WINDOWS}
    Procedures.ProgressTaskbar(0, 0);
  {$ENDIF}

  btnFindDuplicates.Enabled:=true;
  btnUpdateCruise.Enabled:=true;
  btnMarkCruiseDuplicate.Enabled:=true;

  frmdm.TR.CommitRetaining;
  Trt.Commit;
  Qt1.Close;
  Qt1.Free;
  Trt.Free;
 end;
end;


procedure Tfrmqc_duplicates.btnUpdateCruiseClick(Sender: TObject);
Var
 cnt_dup:integer;
begin
 try
   btnFindDuplicates.Enabled:=false;
   btnUpdateCruise.Enabled:=false;
   btnMarkCruiseDuplicate.Enabled:=false;

    with frmdm.q1 do begin
      Close;
        SQL.Clear;
        SQL.Add(' SELECT ID from CRUISE ');
        SQL.Add(' ORDER BY CRUISE.ID ');
      Open;
     end;

    while not frmdm.q1.EOF do begin

     cnt_dup:=0;
     with frmdm.q2 do begin
       Close;
         SQL.Clear;
         SQL.Add(' SELECT COUNT(ID) from STATION ');
         SQL.Add(' WHERE CRUISE_ID=:CR_ID AND ');
         SQL.Add(' DUPLICATE=TRUE ');
         ParamByName('CR_ID').AsInteger:=frmdm.q1.Fields[0].AsInteger;
       Open;
        cnt_dup:=frmdm.q2.Fields[0].AsInteger;
       Close;
     end;

       with frmdm.q2 do begin
         Close;
          SQL.Clear;
          SQL.Add(' UPDATE CRUISE SET ');
          SQL.Add(' STATIONS_DUPLICATES=:cnt ');
          SQL.Add(' where ID=:CR_ID ');
          ParamByName('CR_ID').AsInteger:=frmdm.q1.Fields[0].AsInteger;
          ParamByName('cnt').AsInteger:=cnt_dup;
         ExecSQL;
       end;

  frmdm.q1.Next;
end;

  showmessage('Update completed');

 finally
  btnFindDuplicates.Enabled:=true;
  btnUpdateCruise.Enabled:=true;
  btnMarkCruiseDuplicate.Enabled:=true;

  frmdm.TR.CommitRetaining;
 end;

end;

procedure Tfrmqc_duplicates.btnMarkCruiseDuplicateClick(Sender: TObject);
Var
 TRt:TSQLTransaction;
 Qt1, Qt2:TSQLQuery;

 id: int64;
 dat:text;
 st_db, st_dup, cnt_dup: integer;
begin

try

btnFindDuplicates.Enabled:=false;
btnUpdateCruise.Enabled:=false;
btnMarkCruiseDuplicate.Enabled:=false;

TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt1 :=TSQLQuery.Create(self);
Qt1.Database:=frmdm.IBDB;
Qt1.Transaction:=TRt;

Qt2 :=TSQLQuery.Create(self);
Qt2.Database:=frmdm.IBDB;
Qt2.Transaction:=TRt;

AssignFile(dat, GlobalUnloadPath+'dup_cruises.txt'); rewrite(dat);
writeln(dat, 'Duplicated cruises');

    with Qt1 do begin
      Close;
        SQL.Clear;
        SQL.Add(' SELECT ID, STATIONS_DATABASE, STATIONS_DUPLICATES ');
        SQL.Add(' FROM CRUISE ');
        SQL.Add(' WHERE STATIONS_DATABASE>0 ');
        SQL.Add(' ORDER BY CRUISE.ID ');
      Open;
     end;

    cnt_dup:=0;
    while not Qt1.EOF do begin
      id:=Qt1.Fields[0].AsInteger;
      st_db:=Qt1.Fields[1].AsInteger;
      st_dup:=Qt1.Fields[2].AsInteger;

      if st_dup/st_db>=seRatio.Value/100 then begin
      // memo1.Lines.Add(inttostr(id));
       with Qt2 do begin
         Close;
          SQL.Clear;
          SQL.Add(' UPDATE CRUISE SET ');
          SQL.Add(' DUPLICATE=true ');
          SQL.Add(' where ID=:CR_ID ');
          ParamByName('CR_ID').Value:=id;
         ExecSQL;
       end;
       Trt.CommitRetaining;
       inc(cnt_dup);
       writeln(dat, inttostr(id));
      end;
     Qt1.Next;
    end;


  showmessage('Duplicated cruises: '+inttostr(cnt_dup));
  OpenDocument(GlobalUnloadPath+'dup_cruises.txt');
finally

  btnFindDuplicates.Enabled:=true;
  btnUpdateCruise.Enabled:=true;
  btnMarkCruiseDuplicate.Enabled:=true;

  Trt.Commit;
  Qt1.Free;
  Qt2.Free;
  Trt.Free;
  closeFile(dat);
end;
end;

end.

