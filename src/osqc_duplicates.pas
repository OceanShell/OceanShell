unit osqc_duplicates;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  SQLDB, DB, DateUtils;

type

  { Tfrmqc_duplicates }

  Tfrmqc_duplicates = class(TForm)
    btnFindDuplicates: TButton;
    btnUpdateCruise: TButton;
    cbSource: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    seThreshold: TFloatSpinEdit;
    seDateThreshold: TSpinEdit;
    procedure btnFindDuplicatesClick(Sender: TObject);
    procedure btnUpdateCruiseClick(Sender: TObject);
    procedure cbSourceChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmqc_duplicates: Tfrmqc_duplicates;

implementation

{$R *.lfm}

{ Tfrmqc_duplicates }

uses osmain, dm, procedures;

procedure Tfrmqc_duplicates.FormShow(Sender: TObject);
begin
 cbSource.Items:=frmosmain.cbSource.Items;
end;

procedure Tfrmqc_duplicates.cbSourceChange(Sender: TObject);
begin
  btnFindDuplicates.Enabled:=true;
  btnUpdateCruise.Enabled:=true;
end;

procedure Tfrmqc_duplicates.btnFindDuplicatesClick(Sender: TObject);
Var
TRt:TSQLTransaction;
Qt1, Qt2, Qt3:TSQLQuery;

k, cnt_dup:integer;
begin

btnFindDuplicates.Enabled:=false;

TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt1 :=TSQLQuery.Create(self);
Qt1.Database:=frmdm.IBDB;
Qt1.Transaction:=TRt;

Qt2 :=TSQLQuery.Create(self);
Qt2.Database:=frmdm.IBDB;
Qt2.Transaction:=TRt;

 try
   (* Select everyting except the specified source *)
   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT STATION.ID, LATITUDE, LONGITUDE, DATEANDTIME ');
     SQL.Add(' FROM STATION WHERE ');
    // SQL.Add(' DUPLICATE=FALSE AND ');
     SQL.Add(' CRUISE_ID NOT IN (SELECT CRUISE.ID FROM CRUISE, SOURCE WHERE ');
     SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND SOURCE.NAME=:SrcName) ');
   //  SQL.Add(' AND DATEANDTIME BETWEEN '+QuotedStr('01.01.1935'));
   ///  SQL.Add(' and '+QuotedStr('31.12.1935'));
   //  SQL.Add(' and LATITUDE>60 ');
     SQL.Add(' ORDER BY STATION.ID ');
     ParamByName('SrcName').AsString:=cbSource.Text;
    Open;
    Last;
    First;
   end;


   k:=0; cnt_dup:=0;
   while not Qt1.EOF do begin
    inc(k);
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT STATION.ID ');
       SQL.Add(' FROM STATION, CRUISE, SOURCE WHERE ');
       SQL.Add(' STATION.CRUISE_ID=CRUISE.ID AND ');
       SQL.Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
       SQL.Add(' SOURCE.NAME=:SrcName AND ');
       SQL.Add(' LATITUDE BETWEEN :LatMin AND :LatMax AND ');
       SQL.Add(' LONGITUDE BETWEEN :LonMin AND :LonMax AND ');
       SQL.Add(' DATEANDTIME BETWEEN :DateMin AND :DateMax AND ');
       SQL.Add(' DUPLICATE=FALSE ');
       ParamByName('SrcName').AsString:=cbSource.Text;
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
           SQL.Add(' ID=:ID ');
           ParamByName('ID').AsInteger:=Qt2.FieldByName('ID').AsInteger;
         ExecSQL;
        end;
        Qt2.Next;
        caption:='Duplicates: '+inttostr(cnt_dup);
        Application.ProcessMessages;
      end;

    ProgressTaskbar(k, qt1.RecordCount);
    //Application.ProcessMessages;

    Qt1.Next;
   end;


 finally
  Showmessage('Found '+inttostr(cnt_dup)+' duplicates');
  ProgressTaskbar(0, 0);

  btnFindDuplicates.Enabled:=true;
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

    with frmdm.q1 do begin
      Close;
        SQL.Clear;
        SQL.Add(' SELECT ID from CRUISE ');
        SQL.Add(' WHERE ');
        SQL.Add(' SOURCE_ID IN (SELECT SOURCE.ID FROM SOURCE WHERE ');
        SQL.Add(' SOURCE.NAME=:SrcName) ');
        SQL.Add(' ORDER BY CRUISE.ID ');
        ParamByName('SrcName').AsString:=cbSource.Text;
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
          SQL.Add(' STATIONS_DUPLICATED=:cnt ');
          SQL.Add(' where ID=:CR_ID ');
          ParamByName('CR_ID').AsInteger:=frmdm.q1.Fields[0].AsInteger;
          ParamByName('cnt').AsInteger:=cnt_dup;
         ExecSQL;
       end;

  frmdm.q1.Next;
end;
    frmdm.TR.CommitRetaining;
    showmessage('Update completed');
end;

end.

