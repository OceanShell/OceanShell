unit osmeteo;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, IniFiles, sqldb, db,
  Menus, ExtCtrls, StdCtrls, DBCtrls, TAGraph, TASeries, TATools,
  TAIntervalSources;

type

  { Tfrmmeteo }

  Tfrmmeteo = class(TForm)
    Chart1: TChart;
    DateTimeIntSrc: TDateTimeIntervalChartSource;
    DSMeteo: TDataSource;
    Series1: TLineSeries;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label19: TLabel;
    Label18: TLabel;
    Label17: TLabel;
    Label16: TLabel;
    Label15: TLabel;
    Label14: TLabel;
    Label13: TLabel;
    Label12: TLabel;
    Label20: TLabel;
    DBEdit3: TDBEdit;
    DBEdit8: TDBEdit;
    DBEdit7: TDBEdit;
    DBEdit6: TDBEdit;
    DBEdit5: TDBEdit;
    DBEdit4: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit9: TDBEdit;
    DBEdit10: TDBEdit;
    DBEdit19: TDBEdit;
    DBEdit18: TDBEdit;
    DBEdit17: TDBEdit;
    DBEdit16: TDBEdit;
    DBEdit15: TDBEdit;
    DBEdit14: TDBEdit;
    DBEdit13: TDBEdit;
    DBEdit12: TDBEdit;
    DBEdit20: TDBEdit;
    DBComboBox2: TDBComboBox;
    DBEdit1: TDBEdit;
    DBComboBox1: TDBComboBox;
    btnCommit: TButton;
    Panel1: TPanel;
    QMeteo: TSQLQuery;

    procedure ChangeID(ID:int64);

    procedure FormShow(Sender: TObject);
    procedure btnCommitClick(Sender: TObject);
    procedure DBComboBox1DblClick(Sender: TObject);


    procedure DBEdit10DblClick(Sender: TObject);
  //  procedure Series1Click(Sender: TChartSeries; ValueIndex: Integer;
  //    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Label4Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label9Click(Sender: TObject);
    procedure Label10Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure Label20Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure Label11Click(Sender: TObject);
    procedure Label14Click(Sender: TObject);
    procedure Label13Click(Sender: TObject);
    procedure Label17Click(Sender: TObject);
    procedure Label16Click(Sender: TObject);
    procedure Label15Click(Sender: TObject);
    procedure Label18Click(Sender: TObject);
    procedure Label19Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

  private
    procedure GetTimeSeries(ParameterName, ParameterCaption:string);
  public
    { Public declarations }
  end;

var
  frmmeteo: Tfrmmeteo;

implementation

{$R *.lfm}

uses osmain, dm;

procedure Tfrmmeteo.FormShow(Sender: TObject);
Var
Ini:TInifile;
m, x, y, i:integer;
begin
Ini := TIniFile.Create(IniFileName);
  try
     Top   :=Ini.ReadInteger( 'meteo', 'top',    50);
     Left  :=Ini.ReadInteger( 'meteo', 'left',   50);
     Width :=Ini.ReadInteger( 'meteo', 'width',  900);
     Height:=Ini.ReadInteger( 'meteo', 'height', 500);
  finally
   Ini.Free;
  end;
 frmdm.Q.IndexFieldNames:='DATEANDTIME';

 ChangeID(frmdm.Q.FieldByName('ID').Value);
end;

procedure Tfrmmeteo.ChangeID(ID:int64);
begin
Caption:='Meteo';
DBCombobox1.Focused;
Series1.Clear;
 QMeteo.Close;
 QMeteo.SQL.Text:='Select * from METEO where ID='+inttostr(ID);
 QMeteo.Open;
end;

procedure Tfrmmeteo.btnCommitClick(Sender: TObject);
begin
DBEdit20.Text:=inttostr(frmdm.Q.FieldByName('ID').AsInteger);
 try
  QMeteo.ApplyUpdates(0);
  frmdm.TR.CommitRetaining;
 except
  frmdm.TR.RollbackRetaining;
  QMeteo.CancelUpdates;
 end;
end;

procedure Tfrmmeteo.DBComboBox1DblClick(Sender: TObject);
Var
str_buf:string;
TBuf:integer;
begin
str_buf:=TDBCombobox(sender).Text;
   if str_buf='Ñ'   then TBuf:=0;
   if str_buf='ÑÑÂ' then Tbuf:=23;
   if str_buf='ÑÂ'  then Tbuf:=45;
   if str_buf='ÂÑÂ' then Tbuf:=68;
   if str_buf='Â'   then Tbuf:=90;
   if str_buf='ÂÞÂ' then Tbuf:=113;
   if str_buf='ÞÂ'  then Tbuf:=135;
   if str_buf='ÞÞÂ' then Tbuf:=158;
   if str_buf='Þ'   then Tbuf:=180;
   if str_buf='ÞÞÇ' then Tbuf:=203;
   if str_buf='ÞÇ'  then Tbuf:=225;
   if str_buf='ÇÞÇ' then Tbuf:=248;
   if str_buf='Ç'   then Tbuf:=270;
   if str_buf='ÇÑÇ' then Tbuf:=293;
   if str_buf='ÑÇ'  then Tbuf:=315;
   if str_buf='ÑÑÇ' then Tbuf:=338;
TDBCombobox(sender).Text:=inttostr(TBuf);
end;

procedure Tfrmmeteo.DBEdit10DblClick(Sender: TObject);
Var
first, sec, third, str:string;
begin
  str:=Copy(DBEdit10.Text,1,1);
    if str='0' then first:='';
    if str='1' then first:='Cu';
    if str='2' then first:='Cu';
    if str='3' then first:='CbCu';
    if str='4' then first:='ScCu';
    if str='5' then first:='Sc';
    if str='6' then first:='St';
    if str='7' then first:='FrNb';
    if str='8' then first:='ScCb';
    if str='9' then first:='Cb';

  str:=Copy(DBEdit10.Text,2,1);
    if str='0' then sec:='';
    if str='1' then sec:='As';
    if str='2' then sec:='Ns';
    if str='3' then sec:='Ac';
    if str='4' then sec:='AcAs';
    if str='5' then sec:='AcAs';
    if str='6' then sec:='Ac';
    if str='7' then sec:='Ac';
    if str='8' then sec:='Ac';
    if str='9' then sec:='Ac';

  str:=Copy(DBEdit10.Text,3,1);
    if str='0' then third:='';
    if str='1' then third:='Ci';
    if str='2' then third:='Ci';
    if str='3' then third:='Ci';
    if str='4' then third:='Ci';
    if str='5' then third:='Cs';
    if str='6' then third:='CsCi';
    if str='7' then third:='Cs';
    if str='8' then third:='Cs';
    if str='9' then third:='Cc';

DBEdit10.Text:=First+Sec+Third;
end;

{
procedure Tfrmmeteo.Series1Click(Sender: TChartSeries; ValueIndex: Integer;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
Num_Clicked:int64;
year, month, day, hour, min, sec, msec:word;
stdate, sttime:TDateTime;
LVar:array[0..1] of Variant;
begin
{series2.Clear;
with series1 do
  begin
  Num_Clicked:=Clicked(X,Y);
    if Num_Clicked<>-1 then
     begin
     DecodeDateTime(XValues[Num_clicked], year, month, day, hour, min, sec, msec);
     stdate:=EncodeDate(year, month, day);
     sttime:=EncodeTime(hour, min, sec, msec);
     LVar[0]:=stdate;
     Lvar[1]:=sttime;
      ODBDM.CDSMD.Locate('StDate;StTime',VarArrayOf(LVar),[loCaseInsensitive]);
      series2.AddXY(XValues[Num_Clicked],YValues[Num_Clicked]);
      changeAbsnum;
     end;
  end; }
end;
       }

procedure Tfrmmeteo.GetTimeSeries(ParameterName, ParameterCaption:string);
Var
ID, OldID:int64;
date1:TDateTime;

TRt:TSQLTransaction;
Qt:TSQLQuery;
begin
Series1.Clear;

Caption:='Meteo: '+ParameterCaption;
OldID:=frmdm.Q.FieldByName('ID').AsInteger;

 frmdm.Q.DisableControls;
 try
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt:=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

  frmdm.Q.First;
    while not frmdm.Q.Eof do begin
      ID:=frmdm.Q.FieldByName('ID').AsInteger;
      date1:=frmdm.Q.FieldByName('DATEANDTIME').AsDateTime;

       with Qt do begin
        Close;
          SQL.Clear;
          SQL.Add(' Select '+ParameterName+' from METEO ');
          SQL.Add(' where ID='+inttostr(ID));
       Open;
      end;
     If not VarIsNull(Qt.Fields[0].AsVariant) then
        Series1.AddXY(date1, Qt.Fields[0].Value);
     Qt.Close;
    frmdm.Q.Next;
  end;
 finally
   Trt.Commit;
   Qt.Free;
   Trt.Free;
   frmdm.Q.Locate('ID', OldID, []);
   frmdm.Q.EnableControls;
 end;
end;

procedure Tfrmmeteo.Label4Click(Sender: TObject);
begin
 GetTimeSeries('WINDDIR', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label5Click(Sender: TObject);
begin
  GetTimeSeries('WINDSPEED', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label8Click(Sender: TObject);
begin
 GetTimeSeries('VISIBILITY', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label1Click(Sender: TObject);
begin
 GetTimeSeries('TEMPDRY', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label2Click(Sender: TObject);
begin
 GetTimeSeries('TEMPWET', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label9Click(Sender: TObject);
begin
 GetTimeSeries('HUMABS', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label10Click(Sender: TObject);
begin
 GetTimeSeries('HUMREL', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label3Click(Sender: TObject);
begin
 GetTimeSeries('PRESSURE', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label6Click(Sender: TObject);
begin
 GetTimeSeries('CLOUDCOMMON', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label20Click(Sender: TObject);
begin
 GetTimeSeries('CLOUDLOW', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label12Click(Sender: TObject);
begin
 GetTimeSeries('WAVEDIR', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label11Click(Sender: TObject);
begin
 GetTimeSeries('WAVEHEIGHT', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label14Click(Sender: TObject);
begin
 GetTimeSeries('SEASTATE', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label13Click(Sender: TObject);
begin
 GetTimeSeries('WAVEPERIOD', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label17Click(Sender: TObject);
begin
 GetTimeSeries('WATERTRANSP', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label16Click(Sender: TObject);
begin
 GetTimeSeries('WATERCOLOR', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label15Click(Sender: TObject);
begin
 GetTimeSeries('WEATHER', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label18Click(Sender: TObject);
begin
 GetTimeSeries('SURFTEMP', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.Label19Click(Sender: TObject);
begin
 GetTimeSeries('SURFSALT', TLabel(sender).Caption);
end;

procedure Tfrmmeteo.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger( 'meteo', 'top',    Top);
    Ini.WriteInteger( 'meteo', 'left',   Left);
    Ini.WriteInteger( 'meteo', 'width',  Width);
    Ini.WriteInteger( 'meteo', 'height', Height);
   finally
    ini.Free;
  end;
frmmeteo_open:=false;
end;

end.
