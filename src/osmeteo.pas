unit osmeteo;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, IniFiles, sqldb,
  Menus, ExtCtrls, StdCtrls, DBCtrls, TAGraph, TASeries;

//Series, TeEngine, StdCtrls, ToolWin, ComCtrls, ExtCtrls, TeeProcs,
//  Chart, DBCtrls, MaskEdit, DB, sqldb,
//  IniFiles, Dialogs, TAGraph, TASeries, DateUtils, LCLIntf, LCLType, LMessages, Messages, ;


type

  { Tfrmmeteo }

  Tfrmmeteo = class(TForm)
    Chart1: TChart;
    Series1: TLineSeries;
    //QM: TSQLQuery;
    //DS: TDataSource;
    //MDS: TClientDataSet;
   // MP: TDataSetProvider;
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
   // Chart1: TChart;
   // Series1: TLineSeries;
   // Series2: TPointSeries;
    btnPrior: TButton;
    btnNext: TButton;
    btnCommit: TButton;
    Panel1: TPanel;
    QM: TSQLQuery;

    procedure ChangeAbsnum;
  //  procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCommitClick(Sender: TObject);
    procedure DBComboBox1DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
 //   procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
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
    procedure btnPriorClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);

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
 //ODBDM.CDSMD.IndexFieldNames:='stdate;sttime';
// ChangeAbsnum;
end;

procedure Tfrmmeteo.ChangeAbsnum;
Var
 ID:integer;
begin
Caption:='Meteo';
DBCombobox1.Focused;
Series1.Clear;

 ID:=frmdm.Q.FieldByName('ID').AsInteger;

 QM.SQL.Text:='Select * from METEO where ID='+inttostr(ID);
 Qm.Open;

end;

procedure Tfrmmeteo.btnCommitClick(Sender: TObject);
begin
DBEdit20.Text:=inttostr(frmdm.Q.FieldByName('ID').AsInteger);
 try
  QM.ApplyUpdates(0);
  frmdm.TR.CommitRetaining;
 except
  frmdm.TR.RollbackRetaining;
  QM.CancelUpdates;
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

procedure Tfrmmeteo.btnPriorClick(Sender: TObject);
begin
{if ODBDM.CDSMD.Active then begin
  btnNext.Enabled:=true;
   ODBDM.CDSMD.Prior;
    if ODBDM.CDSMD.RecNo=1 then btnPrior.Enabled:=false;
   Main.CDSNavigation;
end; }
end;

procedure Tfrmmeteo.btnNextClick(Sender: TObject);
begin
{if ODBDM.CDSMD.Active then begin
btnPrior.Enabled:=true;
  ODBDM.CDSMD.Next;
  if ODBDM.CDSMD.Eof then btnNext.Enabled:=false;
Main.CDSNavigation;
end; }
end;

procedure Tfrmmeteo.GetTimeSeries(ParameterName, ParameterCaption:string);
Var
bkm:TBytes;
par:string;
absnum:integer;
NumInCr:string;
StDate, StTime, Date:TDateTime;
year, month, day, hour, min, sec, msec:word;
begin
{Series1.Clear;
Series2.Clear;
Caption:='Meteo: '+ParameterCaption;
  bkm:=ODBDM.CDSMD.Bookmark;
  ODBDM.CDSMD.DisableControls;
  ODBDM.IBTransaction1.StartTransaction;
 try
  ODBDM.CDSMD.First;
    while not ODBDM.CDSMD.Eof do begin
      absnum:=ODBDM.CDSMD.FieldByName('Absnum').AsInteger;
      stdate:=ODBDM.CDSMD.FieldByName('stdate').AsDateTime;
      DecodeDate(stdate,year, month,day);
      sttime:=ODBDM.CDSMD.FieldByName('sttime').AsDateTime;
      DecodeTime(sttime,hour,min,sec,msec);
      Date:=EncodeDateTime(year,month,day,hour,min,sec,msec);
       with ODBDM.ib1q2 do begin
        Close;
          SQL.Clear;
          SQL.Add(' Select '+ParameterName+' from METEO ');
          SQL.Add(' where absnum='+inttostr(Absnum));
       Open;
      end;
     If ODBDM.ib1q2.Fields[0].AsVariant<>null then
        Series1.AddXY(Date, ODBDM.ib1q2.Fields[0].AsFloat, DateToStr(StDate));
     ODBDM.ib1q2.Close;
     ODBDM.CDSMD.Next;
  end;
 finally
   ODBDM.IBTransaction1.Commit;
   ODBDM.CDSMD.Bookmark:=bkm;
   ODBDM.CDSMD.EnableControls;
 end;  }
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
