unit osload_ices2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, FileCtrl,
  StdCtrls, Buttons, Spin, ExtCtrls, DateUtils, FileUtil, StrUtils,
  IBConnection, SQLDB;

type

  { Tfrmload_ices2 }

  Tfrmload_ices2 = class(TForm)
    btnUpdateProfileBest: TBitBtn;
    btnAddBottleToCTD: TBitBtn;
    btnTest: TBitBtn;
    btnDownloadData: TBitBtn;
    btnSplitFile: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    FileListBox1: TFileListBox;
    FileListBox3: TFileListBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    IBDB2: TIBConnection;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    PageControl1: TPageControl;
    q1: TSQLQuery;
    q2: TSQLQuery;
    q3: TSQLQuery;
    RadioGroup1: TRadioGroup;
    seDateThreshold: TSpinEdit;
    seThreshold: TFloatSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TR2: TSQLTransaction;
    procedure btnAddBottleToCTDClick(Sender: TObject);
    procedure btnDownloadDataClick(Sender: TObject);
    procedure btnSplitFileClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure btnUpdateProfileBestClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    procedure CopyStation(stid_btl:Int64);
    procedure AddProfiles(stid_btl,stid_ctd:Int64);
  public

  end;

var
  frmload_ices2: Tfrmload_ices2;
  stid_max,crid_max :int64;
  pathData,pathCSR,pathCR,pathPreview :string;
  fn :string;
  DT1,DT2 :TDateTime;
  fi,fo,fo1 :text;


implementation

uses osmain, dm, procedures, GibbsSeaWater;

{$R *.lfm}

{ Tfrmload_ices2 }

procedure Tfrmload_ices2.FormShow(Sender: TObject);
begin
  memo1.Clear;
  FileListBox1.Clear;

  pathData:=GlobalDataPath+'ICES'+PathDelim;
  if not DirectoryExists(pathData) then CreateDir(pathData);

  if not DirectoryExists(pathData+'CSR') then CreateDir(pathData+'CSR');
  if not DirectoryExists(pathData+'cruises')     then CreateDir(pathData+'cruises');
  if not DirectoryExists(pathData+'preview')     then CreateDir(pathData+'preview');

  pathCSR:=pathData+'CSR'+PathDelim;
  pathCR :=pathData+'cruises'+PathDelim;
  pathPreview:=pathData+'preview'+PathDelim;

  FileListBox1.Directory:=pathData;
  FileListBox3.Directory:=pathCR;

  label4.Caption:='CTD DB   : '+extractfilename(frmdm.IBDB.DatabaseName);
  label5.Caption:='Bottle DB: '+extractfilename(IBDB2.DatabaseName);

  with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add('select max(id) from CRUISE ');
     Open;
     crid_max:=FieldByName('max').AsInteger;
     Close;
  end;

  with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add('select max(id) from STATION ');
     Open;
     stid_max:=FieldByName('max').AsInteger;
     Close;
  end;

  IBDB2.GetTableNames(ListBox1.Items,False);

end;



procedure Tfrmload_ices2.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  IBDB2.Close(true);
end;




procedure Tfrmload_ices2.btnTestClick(Sender: TObject);
begin
  with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add('select count(id) from STATION ');
     Open;
     showmessage('stations# in STATION='+inttostr(FieldByName('count').AsInteger));
     Close;
  end;

end;




procedure Tfrmload_ices2.btnSplitFileClick(Sender: TObject);
type
  Variable=record
    NameICES :string;
    UnitICES :string;
    Table :string;
    UnitID :integer;
    end;
  StVariable=array of Variable;

type
  SC=record
    nodc_code :string[4];
    count :integer;
  end;
  SCDA=array of SC;

var
StVar: StVariable;
ShipCODE :SCDA;
StDate :array of TDateTime;
CruiseLine: array of integer; //cruises boundary in the text file

i,kf,kl,vc :integer;
col,cl,scc,day_cc,date_cc,tlp,cc,crn,L1,L2,LL :integer;
y,m,d,hh,mm :word;
platform_id :integer;
str,str_header,buf,instrument :string;
st_num,st_type,st_date,st_lat,st_lon,st_bd,crns :string;
name_PLATFORM,name_ICES,name_WOD,name_NATIVE,nameICES :string;
nodc_code :string[4];
col_arr :array[1..1000] of string;
shc_new,DayChange,DateChange :boolean;
stDT,stDT1,stDT2 :TDateTime;
label 10;
begin


DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));

if directoryexists(pathCR)=true then deletedirectory(pathCR,true);
if directoryexists(pathCR)=false then mkdir(pathCR);
if directoryexists(pathPreview)=true then deletedirectory(pathPreview,true);
if directoryexists(pathPreview)=false then mkdir(pathPreview);
FileListBox3.Clear;

    day_cc:=0; //day change count, wrong format
    date_cc:=0; //date change count
    tlp:=0; //total lines processes
{F}for kf:=0 to FileListBox1.Items.Count-1 do begin
    fn:=pathData+FileListBox1.Items.Strings[kf];
    memo1.Lines.Add('');
    if CheckBox1.Checked then memo1.Lines.Add(fn);

    if copy(FileListBox1.Items.Strings[kf],1,2)='B_' then instrument:='Bottle';
    if copy(FileListBox1.Items.Strings[kf],1,2)='C_' then instrument:='CTD';

    AssignFile(fi,concat(fn));
    Reset(fi);
    readln(fi,str);

    fn:=pathPreview+FileListBox1.Items.Strings[kf];
    fn:=copy(fn,1,length(fn)-4)+'_upd.txt';
    AssignFile(fo,concat(fn));
    Rewrite(fo);
    writeln(fo,'cruise#',#9,str);

{.....first line analysis on tab}
    col:=0;
    buf:='';
{s}for i:=1 to length(str) do begin
    if ord(str[i])<>9 then buf:=buf+str[i]
    else begin
      col:=col+1;
      col_arr[col]:=buf;
      buf:='';
    end;
{s}end;
    col:=col+1;
    col_arr[col]:=buf;

{m}if CheckBox1.Checked then begin
{i}for i:=1 to col do begin
    memo1.Lines.Add(inttostr(i)+#9+col_arr[i]);
{i}end;
{m}end;
{.....first line}


{.....variables in file from 19th column}
    vc:=0; //number of variables in the file
{i}for i:=19 to col do begin
{B}if instrument='Bottle' then begin
    case i of
    19: begin  //Temperature [degC]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[degC]';
         StVar[vc-1].Table:='P_TEMPERATURE';
         StVar[vc-1].UnitID:=1; //Degree centigrade
        end;
    21: begin  //Practical Salinity [dmnless]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[dmnless]';
         StVar[vc-1].Table:='P_SALINITY';
         StVar[vc-1].UnitID:=28; //practical salinity unit
        end;
    23: begin  //Dissolved Oxygen [ml/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[ml/l]';
         StVar[vc-1].Table:='P_OXYGEN';
         StVar[vc-1].UnitID:=21; //Milliliter per liter
        end;
    25: begin  //Dissolved Oxygen [ml/kg]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[ml/kg]';
         StVar[vc-1].Table:='P_OXYGEN';
         StVar[vc-1].UnitID:=29; //Milliliter per kilogram
        end;
    27: begin  //Phosphate Phosphorus (PO4-P) [umol/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/l]';
         StVar[vc-1].Table:='P_PHOSPHATE';
         StVar[vc-1].UnitID:=15; //Micro-mole per liter
        end;
    29: begin  //Phosphate Phosphorus (PO4-P) [umol/kg]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/kg]';
         StVar[vc-1].Table:='P_PHOSPHATE';
         StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
        end;
    31: begin  //Total Phosphorus (P) [umol/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/l]';
         StVar[vc-1].Table:='P_TOTALPHOSPHORUS';
         StVar[vc-1].UnitID:=15; //Micro-mole per liter
        end;
    33: begin  //Total Phosphorus (P) [umol/kg]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/kg]';
         StVar[vc-1].Table:='P_TOTALPHOSPHORUS';
         StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
        end;
    35: begin  //Silicate Silicon (SiO4-Si) [umol/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/l]';
         StVar[vc-1].Table:='P_SILICATE';
         StVar[vc-1].UnitID:=15; //Micro-mole per liter
        end;
    37: begin  //Silicate Silicon (SiO4-Si) [umol/kg]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/kg]';
         StVar[vc-1].Table:='P_SILICATE';
         StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
        end;
    39: begin  //Nitrate Nitrogen (NO3-N) [umol/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/l]';
         StVar[vc-1].Table:='P_NITRATE';
         StVar[vc-1].UnitID:=15; //Micro-mole per liter
        end;
    41: begin  //Nitrate Nitrogen (NO3-N) [umol/kg]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/kg]';
         StVar[vc-1].Table:='P_NITRATE';
         StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
        end;
    43: begin  //Nitrite Nitrogen (NO2-N) [umol/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/l]';
         StVar[vc-1].Table:='P_NITRITE';
         StVar[vc-1].UnitID:=15; //Micro-mole per liter
        end;
    45: begin  //Nitrite Nitrogen (NO2-N) [umol/kg]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/kg]';
         StVar[vc-1].Table:='P_NITRITE';
         StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
        end;
    47: begin  //Ammonium Nitrogen (NH4-N) [umol/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/l]';
         StVar[vc-1].Table:='P_AMMONIUM';
         StVar[vc-1].UnitID:=15; //Micro-mole per liter
        end;
    49: begin  //Ammonium Nitrogen (NH4-N) [umol/kg]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/kg]';
         StVar[vc-1].Table:='P_AMMONIUM';
         StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
        end;
    51: begin  //Total Nitrogen (N) [umol/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/l]';
         StVar[vc-1].Table:='P_TDN';
         StVar[vc-1].UnitID:=15;; //Micro-mole per liter
        end;
    53: begin  //Hydrogen Sulphide (H2S-S) [umol/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[umol/l]';
         StVar[vc-1].Table:='P_H2S';
         StVar[vc-1].UnitID:=15; //Micro-mole per liter
        end;
    55: begin  //Hydrogen Ion Concentration (pH) [pH]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[pH]';
         StVar[vc-1].Table:='P_PH';
         StVar[vc-1].UnitID:=2; //Dimensionless or unit less
        end;
    57: begin  //Alkalinity [mEq/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[mEq/l]';
         StVar[vc-1].Table:='P_ALKALINITY';
         StVar[vc-1].UnitID:=5; //Milli-equivalent per liter
        end;
    59: begin  //Alkalinity [mEq/kg]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[mEq/kg]';
         StVar[vc-1].Table:='P_ALKALINITY';
         StVar[vc-1].UnitID:=30; //Milli-equivalent per kilogram
        end;
    61: begin  //Chlorophyll a [ug/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[ug/l]';
         StVar[vc-1].Table:='P_CHLOROPHYLL';
         StVar[vc-1].UnitID:=4; //Micro-gram per liter
        end;
    63: begin  //Chlorophyll a [ug/kg]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[ug/kg]';
         StVar[vc-1].Table:='P_CHLOROPHYLL';
         StVar[vc-1].UnitID:=14; //Micro-gram per kilogram
        end;
    end;{case}
{B}end;

{C}if instrument='CTD' then begin
    case i of
    19: begin  //Temperature [degC]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[degC]';
         StVar[vc-1].Table:='P_TEMPERATURE';
         StVar[vc-1].UnitID:=1; //Degree centigrade
        end;
    21: begin  //Practical Salinity [dmnless]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[dmnless]';
         StVar[vc-1].Table:='P_SALINITY';
         StVar[vc-1].UnitID:=28; //practical salinity unit
        end;
    23: begin  //Dissolved Oxygen [ml/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[ml/l]';
         StVar[vc-1].Table:='P_OXYGEN';
         StVar[vc-1].UnitID:=21; //Milliliter per liter
        end;
    25: begin  //Dissolved Oxygen [ml/kg]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[ml/kg]';
         StVar[vc-1].Table:='P_OXYGEN';
         StVar[vc-1].UnitID:=29; //Milliliter per kilogram
        end;
    27: begin  //Hydrogen Ion Concentration (pH) [pH]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[pH]';
         StVar[vc-1].Table:='P_PH';
         StVar[vc-1].UnitID:=2; //Dimensionless or unit less
        end;
    29: begin  //Chlorophyll a [ug/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[ug/l]';
         StVar[vc-1].Table:='P_CHLOROPHYLL';
         StVar[vc-1].UnitID:=4; //Micro-gram per liter
        end;
    end;{case}
{C}end;

{i}end;
{memo}if CheckBox1.Checked then begin
    memo1.Lines.Add('');
    memo1.Lines.Add('...variables ');
    memo1.Lines.Add('NameICES'+#9+'UnitICES'+#9+'Database Table'+#9+'Database units_id ');
    for i:=0 to High(StVar) do
    memo1.Lines.Add(StVar[i].NameICES
    +#9+StVar[i].UnitICES
    +#9+StVar[i].Table
    +#9+inttostr(StVar[i].UnitID));
    memo1.Lines.Add('variables# in the file:'+inttostr(Length(StVar)));
{memo}end;
{.....variables}



{.....ShipCode - unique nodc_codes in file}
    cl:=0; //count lines
{L}while not EOF(fi) do begin
    readln(fi,str);
    cl:=cl+1;
    inc(tlp);
    label1.Caption:='lines processed='+inttostr(tlp);
    if tlp MOD 10000=0 then Application.ProcessMessages;

    {lines analysis on commes}
    col:=0;
    buf:='';
{s}for i:=1 to length(str) do begin
    {comma 44, tab 9}
    if ord(str[i])<>9 then buf:=buf+str[i]
    else begin
      col:=col+1;
      col_arr[col]:=buf;
      buf:='';
    end;
{s}end;
    col:=col+1;
    col_arr[col]:=buf;

    nodc_code:=col_arr[1];
    st_num:=col_arr[2];
    st_type:=col_arr[3];

    y:=strtoint(col_arr[4]);
    m:=strtoint(col_arr[5]);
    d:=strtoint(col_arr[6]);
    if(col_arr[7]<>'') then hh:=strtoint(col_arr[7]) else hh:=0;
    if(col_arr[8]<>'') then mm:=strtoint(col_arr[8]) else mm:=0;

    {convert date and time into datetime}
    stDT:= procedures.DateEncode(y,m,d,hh,mm,DayChange,DateChange);
    if DayChange=true  then day_cc:=day_cc+1;
    if DateChange=true then date_cc:=date_cc+1;


    st_lat:=col_arr[9];
    st_lon:=col_arr[10];
    st_bd:=col_arr[11];


    {StDate: stations dates}
    SetLength(StDate,cl);
    StDate[cl-1]:=stDT;

    {ShipCode: unique ship codes}
    if cl=1 then begin
     scc:=1; //ship code count
     SetLength(ShipCode,scc);
     ShipCode[scc-1].nodc_code:=nodc_code;
    end;
    shc_new:=true;
    for i:=0 to High(ShipCode) do if ShipCode[i].nodc_code=nodc_code then shc_new:=false;
    if shc_new=true then begin
     scc:=scc+1;
     SetLength(ShipCode,scc);
     ShipCode[scc-1].nodc_code:=nodc_code;
    end;
{L}end;
    closefile(fi);

    memo1.Lines.Add('data lines# in file='+inttostr(cl));

    {...count unique nodc_code}
    for i:=0 to High(ShipCode) do
    ShipCode[i].count:=0;

    reset(fi);
    readln(fi,str);
{L}while not EOF(fi) do begin
    readln(fi,str);
    nodc_code:=copy(str,1,4);
    for i:=0 to High(ShipCode) do
    if ShipCode[i].nodc_code=nodc_code then ShipCode[i].count:=ShipCode[i].count+1;
{L}end;
    closefile(fi);

    {...add names from PLATFORM}
{memo}if CheckBox1.Checked then begin
    memo1.Lines.Add('');
    memo1.Lines.Add('...platforms');
    memo1.Lines.Add('#'+#9+'nodc_code'+#9+'lines#'+#9+'name'+#9+'name_ICES'+#9+'name_WOD'+#9+'name_NATIVE');
{memo}end;
{SC}for i:=0 to High(ShipCode) do begin
    nodc_code:= ShipCode[i].nodc_code;
    //if nodc_code='????' then nodc_code:='9099';
    with frmdm.q1 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select * from PLATFORM ');
       SQL.Add(' where nodc_code=:nodc_code ');
       ParamByName('nodc_code').AsString:=nodc_code;
       Open;
       name_PLATFORM:=FieldByName('name').AsString;
       name_ICES:=FieldByName('name_ICES').AsString;
       name_WOD:=FieldByName('name_WOD').AsString;
       name_NATIVE:=FieldByName('name_NATIVE').AsString;
       Close;
     end;
    if CheckBox1.Checked then
     memo1.Lines.Add(inttostr(i)
     +#9+nodc_code
     +#9+inttostr(ShipCode[i].count) //lines# in file
     +#9+name_PLATFORM
     +#9+name_ICES
     +#9+name_WOD
     +#9+name_NATIVE);
{SC}end;
{.....ShipCode}

    {...check StDate}
{memo}if CheckBox1.Checked then begin
     memo1.Lines.Add('');
     memo1.Lines.Add('...StDate');
     memo1.Lines.Add('dates# in file='+inttostr(Length(StDate)));
     memo1.Lines.Add('cruise#'+#9+'line#');
     for i:=0 to High(StDate) do memo1.Lines.Add(inttostr(i)+#9+datetimetostr(StDate[i]));
{memo}end;



{.....CruiseLine -split file on cruises}
     cc:=1; //cruise count
     SetLength(CruiseLine,cc);
     CruiseLine[cc-1]:=2; //line where a new cruise begins
    for i:=0 to High(StDate)-1 do begin
      stDT1:=StDate[i];
      stDT2:=StDate[i+1];
  if Daysbetween(stDT1,stDT2)>strtoint(trim(Edit1.Text)) then begin
     cc:=cc+1;
     SetLength(CruiseLine,cc);
     CruiseLine[cc-1]:=i+3;
  end;
  end;
     {last line in file}
     cc:=cc+1;
     SetLength(CruiseLine,cc);
     CruiseLine[cc-1]:=i+3;
{memo}if CheckBox1.Checked then begin
     memo1.Lines.Add('');
     memo1.Lines.Add('cruises# in file='+inttostr(High(CruiseLine)));
     memo1.Lines.Add('cruise#'+#9+'line#');
     for i:=0 to High(CruiseLine) do memo1.Lines.Add(inttostr(i)+#9+inttostr(CruiseLine[i]));
{memo}end;
{.....CruiseLine}



{.....output cruises}
    reset(fi);
    readln(fi,str_header);
    cl:=1;
{C}for i:=0 to High(CruiseLine)-1 do begin
    crn:=i+1; //cruise number in file
    label1.Caption:='cruise: '+inttostr(crn);
    Application.ProcessMessages;
    L1:=CruiseLine[i];
    L2:=CruiseLine[i+1];
    LL:=L2-L1;  //# of levels at the station

{L}for kL:=1 to LL do begin
    inc(cl);
    readln(fi,str);

{L1}if kL=1 then begin
     nodc_code:=copy(str,1,4);
     name_Platform:='UNKNOWN';
     platform_id:=17271; //nodc_code=9099 SHIP NOT IDENTIFIED
    with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select id,name from PLATFORM ');
     SQL.Add(' where nodc_code=:nodc_code ');
     ParamByName('nodc_code').AsString:=nodc_code;
     Open;
     platform_id:=FieldByName('id').AsInteger;
     name_Platform:=FieldByName('name').AsString;
     Close;
    end;
     if name_Platform='' then name_Platform:='UNKNOWN';
     if name_Platform='SHIP NOT IDENTIFIED' then name_Platform:='UNKNOWN';

     crns:='00000'+inttostr(crn);
     if crn>=10 then crns:='0000'+inttostr(crn);
     if crn>=100 then crns:='000'+inttostr(crn);
     if crn>=1000 then crns:='00'+inttostr(crn);
     if crn>=10000 then crns:='0'+inttostr(crn);
     if crn>=100000 then crns:=inttostr(crn);

     {...replace invalid characters in the file name}
     name_platform:=StringReplace(name_platform,'/','-',[rfReplaceAll, rfIgnoreCase]);
     name_platform:=StringReplace(name_platform,'?','-',[rfReplaceAll, rfIgnoreCase]);

     fn:=pathCR+crns+'_'+instrument+'_'+name_PLATFORM+'.txt';
     memo1.Lines.Add(fn);
     AssignFile(fo1,concat(fn));
     Rewrite(fo1);
     writeln(fo1,str_header);
     //writeln(fo1,str);
{L1}end;

     writeln(fo,inttostr(crn),#9,str);
     writeln(fo1,str);

     if kL=LL then closefile(fo1);

{L}end;
{C}end;
    closefile(fi);
{.....output}

    closefile(fo);
{F}end;

label1.Caption:='lines processed='+inttostr(tlp);

memo1.Lines.Add('');
memo1.Lines.Add('total lines processed= '+inttostr(tlp));
memo1.Lines.Add('day change count= '+inttostr(day_cc));
memo1.Lines.Add('date change count= '+inttostr(date_cc));

FileListBox3.Directory:=pathCR;
FileListBox3.UpdateFileList;
Application.ProcessMessages;

DT2:=NOW;
memo1.Lines.Add('');
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;





procedure Tfrmload_ices2.btnDownloadDataClick(Sender: TObject);
type
  Variable=record
    NameICES :string;
    UnitICES :string;
    Table :string;
    UnitID :integer;
    end;
  StVariable=array of Variable;
var
StVar: StVariable;
StNumber: array of string; //stations numbers
StLine: array of integer; //station positions
Station: array of array of real;

cruise_id,station_id :int64;
source_id,platform_id,instrument_id,units_id :integer;
i,j,col,kf,ks,kL,L1,L2,LL,clev,mik :integer;
cl,cs,vc,stations_database,bd,StVersion,CountDup,day_cc,date_cc :integer;
vi,qi,prfn,PQF1,PQF2  :integer;
y,m,d,hh,mm :word;
lat,lon,lat_min,lon_min,lat_max,lon_max,lev_m,lev_dbar: real;
last_lev_dbar,last_lev_m :real;
str,buf,name_PLATFORM,tbl,instrument :string;
nameICES,unitICES,CSR_cruise_number,CSR_expocode,CSR_notes :string;
st_num,st_type,st_date,st_lat,st_lon,st_bd,st1,st2,st_lev_m,st_lev_dbar :string;
nodc_code :string[4];
col_arr :array[1..100] of string;
st_DT,dsdb_DT,dedb_DT,date_start_total,date_end_total :TDateTime;
DayChange,DateChange :boolean;
FuncZ:Tgsw_z_from_p;
FuncP:Tgsw_p_from_z;
begin

DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));

   source_id:=4; //ICES
{.....determine cruise_id and station_id}
with frmdm.q1 do begin
   Close;
   SQL.Clear;
   SQL.Add(' select max(id) as cruise_id from CRUISE ');
   Open;
   cruise_id:=FieldByName('cruise_id').AsInteger;
   if cruise_id=0 then cruise_id:=15000000;  //ICES rannge
   Close;
 end;
with frmdm.q1 do begin
   Close;
   SQL.Clear;
   SQL.Add(' select max(id) as station_id from STATION ');
   Open;
   station_id:=FieldByName('station_id').AsInteger;
   if station_id=0 then station_id:=15000000;  //ICES rannge
   Close;
 end;
   memo1.Lines.Add('max  cruise.id='+inttostr(cruise_id));
   memo1.Lines.Add('max station.id='+inttostr(station_id));
   memo1.Lines.Add('');

    label1.Caption:='cruise max:'+inttostr(cruise_id);
    Label1.Visible:=true;
    Application.ProcessMessages;
{F}for kf:=0 to FileListBox3.Items.Count-1 do begin
//{F}for kf:=0 to 2 do begin

    cruise_id:=cruise_id+1;
    label1.Caption:='cruise:'+inttostr(cruise_id);
    Application.ProcessMessages;

    fn:=pathCR+FileListBox3.Items.Strings[kf];
    AssignFile(fi,concat(fn));
    if CheckBox1.Checked then memo1.Lines.Add(fn);

    if AnsiContainsStr(FileListBox3.Items.Strings[kf],'_Bottle_')
    then begin instrument:='Bottle'; instrument_id:=7; end;
    if AnsiContainsStr(FileListBox3.Items.Strings[kf],'_CTD_')
    then begin instrument:='CTD'; instrument_id:=4; end;

//showmessage('instrument: '+instrument);
{.....step 1: StVar: coinsidence between file and BD - variable columns, DB tables, units }
{.....header analysis}
    Reset(fi);
    readln(fi,str);
    cl:=1; //count lines

   {...first line analysis on tab}
    col:=0;
    buf:='';
{s}for i:=1 to length(str) do begin
    if ord(str[i])<>9 then buf:=buf+str[i]
    else begin
      col:=col+1;
      col_arr[col]:=buf;
      buf:='';
    end;
{s}end;
    col:=col+1;
    col_arr[col]:=buf;

{m}if CheckBox1.Checked then begin
{i}for i:=1 to col do begin
    memo1.Lines.Add(inttostr(i)+#9+col_arr[i]);
{i}end;
{m}end;

   {...variables in file from 19th column}
    vc:=0; //number of variables in the file
{i}for i:=19 to col do begin
{B}if instrument='Bottle' then begin
 case i of
 19: begin  //Temperature [degC]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[degC]';
      StVar[vc-1].Table:='P_TEMPERATURE';
      StVar[vc-1].UnitID:=1; //Degree centigrade
     end;
 21: begin  //Practical Salinity [dmnless]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[dmnless]';
      StVar[vc-1].Table:='P_SALINITY';
      StVar[vc-1].UnitID:=28; //practical salinity unit
     end;
 23: begin  //Dissolved Oxygen [ml/l]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[ml/l]';
      StVar[vc-1].Table:='P_OXYGEN';
      StVar[vc-1].UnitID:=21; //Milliliter per liter
     end;
 25: begin  //Dissolved Oxygen [ml/kg]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[ml/kg]';
      StVar[vc-1].Table:='P_OXYGEN';
      StVar[vc-1].UnitID:=29; //Milliliter per kilogram
     end;
 27: begin  //Phosphate Phosphorus (PO4-P) [umol/l]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/l]';
      StVar[vc-1].Table:='P_PHOSPHATE';
      StVar[vc-1].UnitID:=15; //Micro-mole per liter
     end;
 29: begin  //Phosphate Phosphorus (PO4-P) [umol/kg]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/kg]';
      StVar[vc-1].Table:='P_PHOSPHATE';
      StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
     end;
 31: begin  //Total Phosphorus (P) [umol/l]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/l]';
      StVar[vc-1].Table:='P_TOTALPHOSPHORUS';
      StVar[vc-1].UnitID:=15; //Micro-mole per liter
     end;
 33: begin  //Total Phosphorus (P) [umol/kg]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/kg]';
      StVar[vc-1].Table:='P_TOTALPHOSPHORUS';
      StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
     end;
 35: begin  //Silicate Silicon (SiO4-Si) [umol/l]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/l]';
      StVar[vc-1].Table:='P_SILICATE';
      StVar[vc-1].UnitID:=15; //Micro-mole per liter
     end;
 37: begin  //Silicate Silicon (SiO4-Si) [umol/kg]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/kg]';
      StVar[vc-1].Table:='P_SILICATE';
      StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
     end;
 39: begin  //Nitrate Nitrogen (NO3-N) [umol/l]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/l]';
      StVar[vc-1].Table:='P_NITRATE';
      StVar[vc-1].UnitID:=15; //Micro-mole per liter
     end;
 41: begin  //Nitrate Nitrogen (NO3-N) [umol/kg]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/kg]';
      StVar[vc-1].Table:='P_NITRATE';
      StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
     end;
 43: begin  //Nitrite Nitrogen (NO2-N) [umol/l]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/l]';
      StVar[vc-1].Table:='P_NITRITE';
      StVar[vc-1].UnitID:=15; //Micro-mole per liter
     end;
 45: begin  //Nitrite Nitrogen (NO2-N) [umol/kg]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/kg]';
      StVar[vc-1].Table:='P_NITRITE';
      StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
     end;
 47: begin  //Ammonium Nitrogen (NH4-N) [umol/l]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/l]';
      StVar[vc-1].Table:='P_AMMONIUM';
      StVar[vc-1].UnitID:=15; //Micro-mole per liter
     end;
 49: begin  //Ammonium Nitrogen (NH4-N) [umol/kg]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/kg]';
      StVar[vc-1].Table:='P_AMMONIUM';
      StVar[vc-1].UnitID:=3; //Micro-mole per kilogram
     end;
 51: begin  //Total Nitrogen (N) [umol/l]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/l]';
      StVar[vc-1].Table:='P_TDN';
      StVar[vc-1].UnitID:=15;; //Micro-mole per liter
     end;
 53: begin  //Hydrogen Sulphide (H2S-S) [umol/l]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[umol/l]';
      StVar[vc-1].Table:='P_H2S';
      StVar[vc-1].UnitID:=15; //Micro-mole per liter
     end;
 55: begin  //Hydrogen Ion Concentration (pH) [pH]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[pH]';
      StVar[vc-1].Table:='P_PH';
      StVar[vc-1].UnitID:=2; //Dimensionless or unit less
     end;
 57: begin  //Alkalinity [mEq/l]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[mEq/l]';
      StVar[vc-1].Table:='P_ALKALINITY';
      StVar[vc-1].UnitID:=5; //Milli-equivalent per liter
     end;
 59: begin  //Alkalinity [mEq/kg]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[mEq/kg]';
      StVar[vc-1].Table:='P_ALKALINITY';
      StVar[vc-1].UnitID:=30; //Milli-equivalent per kilogram
     end;
 61: begin  //Chlorophyll a [ug/l]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[ug/l]';
      StVar[vc-1].Table:='P_CHLOROPHYLL';
      StVar[vc-1].UnitID:=4; //Micro-gram per liter
     end;
 63: begin  //Chlorophyll a [ug/kg]
      inc(vc);
      SetLength(StVar,vc);
      StVar[vc-1].NameICES:=col_arr[i];
      StVar[vc-1].UnitICES:='[ug/kg]';
      StVar[vc-1].Table:='P_CHLOROPHYLL';
      StVar[vc-1].UnitID:=14; //Micro-gram per kilogram
     end;
 end;{case}
{B}end;

{C}if instrument='CTD' then begin
    case i of
    19: begin  //Temperature [degC]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[degC]';
         StVar[vc-1].Table:='P_TEMPERATURE';
         StVar[vc-1].UnitID:=1; //Degree centigrade
        end;
    21: begin  //Practical Salinity [dmnless]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[dmnless]';
         StVar[vc-1].Table:='P_SALINITY';
         StVar[vc-1].UnitID:=28; //practical salinity unit
        end;
    23: begin  //Dissolved Oxygen [ml/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[ml/l]';
         StVar[vc-1].Table:='P_OXYGEN';
         StVar[vc-1].UnitID:=21; //Milliliter per liter
        end;
    25: begin  //Dissolved Oxygen [ml/kg]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[ml/kg]';
         StVar[vc-1].Table:='P_OXYGEN';
         StVar[vc-1].UnitID:=29; //Milliliter per kilogram
        end;
    27: begin  //Hydrogen Ion Concentration (pH) [pH]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[pH]';
         StVar[vc-1].Table:='P_PH';
         StVar[vc-1].UnitID:=2; //Dimensionless or unit less
        end;
    29: begin  //Chlorophyll a [ug/l]
         inc(vc);
         SetLength(StVar,vc);
         StVar[vc-1].NameICES:=col_arr[i];
         StVar[vc-1].UnitICES:='[ug/l]';
         StVar[vc-1].Table:='P_CHLOROPHYLL';
         StVar[vc-1].UnitID:=4; //Micro-gram per liter
        end;
    end;{case}
{C}end;

{i}end;

{memo}if CheckBox1.Checked then begin
    memo1.Lines.Add('');
    memo1.Lines.Add('...variables ');
    memo1.Lines.Add('NameICES'+#9+'UnitICES'+#9+'Database Table'+#9+'Database units_id ');
    for i:=0 to High(StVar) do
    memo1.Lines.Add(inttostr(i+1)
    +#9+StVar[i].NameICES
    +#9+StVar[i].UnitICES
    +#9+StVar[i].Table
    +#9+inttostr(StVar[i].UnitID));
    memo1.Lines.Add('variables# in the file:'+inttostr(Length(StVar)));
{memo}end;
    closefile(fi);
{.....step1}



{.....step 2: StNumber: station numbers in file }
{.....data lines analysis}
    Reset(fi);
    readln(fi,str);  //skip header

    cl:=0;   //count data line in file
{L}while not EOF(fi) do begin
    readln(fi,str);
    cl:=cl+1;

    col:=0;
    buf:='';
    {...tab analysis}
{s}for i:=1 to length(str) do begin
    if ord(str[i])<>9 then buf:=buf+str[i]
    else begin
      col:=col+1;
      col_arr[col]:=buf;
      buf:='';
    end;
{s}end;
    col:=col+1;
    col_arr[col]:=buf;

    nodc_code:=col_arr[1];
    st_num:=col_arr[2];
    st_type:=col_arr[3];

    y:=strtoint(col_arr[4]);
    m:=strtoint(col_arr[5]);
    d:=strtoint(col_arr[6]);
    if(col_arr[7]<>'') then hh:=strtoint(col_arr[7]) else hh:=0;
    if(col_arr[8]<>'') then mm:=strtoint(col_arr[8]) else mm:=0;

    {convert date and time into datetime}
    st_DT:= procedures.DateEncode(y,m,d,hh,mm,DayChange,DateChange);
    if DayChange=true  then day_cc:=day_cc+1;
    if DateChange=true then date_cc:=date_cc+1;

    st_lat:=col_arr[9];
    st_lon:=col_arr[10];
    st_bd:=col_arr[11];

    {position}
    lat:=strtofloat(st_lat);
    lon:=strtofloat(st_lon);

    {cruise  metadata from first data line}
{1}if cl=1 then begin
    with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select id, name from PLATFORM ');
     SQL.Add(' where nodc_code=:nodc_code ');
     ParamByName('nodc_code').AsString:=nodc_code;
     Open;
     platform_id:=frmdm.q1.FieldByName('id').AsInteger;
     name_platform:=frmdm.q1.FieldByName('name').AsString;
     {platfom and country names are UNKNOWN}
     if IsEmpty=true then platform_id:=18695;
     Close;
    end;

    dsdb_DT:=st_DT; //date_start_database
    dedb_DT:=st_DT; //date_start_database
    lat_min:=lat;
    lat_max:=lat;
    lon_min:=lon;
    lon_max:=lon;
{1}end
{2}else begin
    if dsdb_DT>st_DT then dsdb_DT:=st_DT;
    if dedb_DT<st_DT then dedb_DT:=st_DT;
    if lat_min>lat then lat_min:=lat;
    if lat_max<lat then lat_max:=lat;
    if lon_min>lon then lon_min:=lon;
    if lon_max<lon then lon_max:=lon;
{2}end;

    SetLength(StNumber,cl);
    StNumber[cl-1]:=trim(st_num);

{L}end;
    closefile(fi);

{m}if CheckBox1.Checked then begin
    memo1.Lines.Add('...step 2: Elements in StNumber array='+inttostr(Length(StNumber)));
    for i:=0 to High(StNumber) do memo1.Lines.Add(inttostr(i)+#9+StNumber[i]);
{m}end;
{.....step 2}



{.....step 3: StLine -create array with stations position in file}
   cs:=1; //count  stations
   SetLength(StLine,cs);
   StLine[cs-1]:=2; //line where a new cruise begins
for i:=0 to High(StNumber)-1 do begin
   st1:=StNumber[i];
   st2:=StNumber[i+1];
if st1<>st2 then begin
   cs:=cs+1;
   SetLength(StLine,cs);
   StLine[cs-1]:=i+3;
end;
end;
   {last line in file}
   cs:=cs+1;
   SetLength(StLine,cs);
   StLine[cs-1]:=i+4;
   if CheckBox1.Checked then begin
   memo1.Lines.Add('...step 3: records# in StLine='+inttostr(Length(StLine)));
   memo1.Lines.Add('st#'+#9+'line#');
   for i:=0 to High(StLine) do memo1.Lines.Add(inttostr(i)+#9+inttostr(StLine[i]));
   end;
   stations_database:=High(StLine);
{.....step3}


{.....step 4: populate CRUISE}
    {...CRUISE_CSR}
    CSR_cruise_number:='UNKNOWN';
   with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select cruise_number, expocode, notes,  ');
     SQL.Add(' date_start_total, date_end_total ');
     SQL.Add(' from CRUISE_CSR ');
     SQL.Add(' where :st_DT between date_start_total and date_end_total ');
     SQL.Add(' and platform_id=:platform_id ');
     ParambyName('st_DT').AsDateTime:=dsdb_DT;   //date_start_database
     ParambyName('platform_id').AsInteger:=platform_id;
     Open;
     CSR_cruise_number:=FieldByName('cruise_number').AsString;
     CSR_expocode:=FieldByName('expocode').AsString;
     CSR_notes:=FieldByName('notes').AsString;
     date_start_total:=FieldByName('date_start_total').AsDateTime;
     date_end_total:=FieldByName('date_end_total').AsDateTime;
     Close;
   end;
     if CSR_cruise_number='' then CSR_cruise_number:='UNKNOWN';

   if CheckBox1.Checked then begin
    memo1.Lines.Add('...step 4: CRUISE: '
    +#9+inttostr(cruise_id)
    +#9+nodc_code
    +#9+inttostr(platform_id)
    +#9+name_platform
    +#9+inttostr(source_id)
    +#9+datetimetostr(dsdb_DT)
    +#9+datetimetostr(dedb_DT)
    +#9+floattostr(lat_min)+'->'+floattostr(lat_max)
    +#9+floattostr(lon_min)+'->'+floattostr(lon_max)
    +#9+inttostr(stations_database)
    +#9+'CSR: '+CSR_cruise_number
    +#9+CSR_expocode
    );
   end;

   if CheckBox2.Checked then begin
   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add('insert into CRUISE');
     //SQL.Add('insert into CRUISE');
     SQL.Add(' (ID, platform_id, source_id, institute_id, project_id, expocode, notes, ');
     SQL.Add(' DATE_ADDED, DATE_UPDATED, DATE_START_TOTAL, DATE_END_TOTAL,  ');
     SQL.Add(' DATE_START_DATABASE, DATE_END_DATABASE, CRUISE_NUMBER,');
     SQL.Add(' LATITUDE_MIN, LATITUDE_MAX, LONGITUDE_MIN, LONGITUDE_MAX,');
     SQL.Add(' STATIONS_TOTAL, STATIONS_DATABASE, STATIONS_DUPLICATES) ');
     SQL.Add(' VALUES ' );
     SQL.Add(' (:ID, :platform_id, :source_id, :institute_id, :project_id, :expocode, :notes, ');
     SQL.Add(' :DATE_ADDED, :DATE_UPDATED, :DATE_START_TOTAL, :DATE_END_TOTAL, ');
     SQL.Add(' :DATE_START_DATABASE, :DATE_END_DATABASE, :CRUISE_NUMBER, ');
     SQL.Add(' :LATITUDE_MIN, :LATITUDE_MAX, :LONGITUDE_MIN, :LONGITUDE_MAX,');
     SQL.Add(' :STATIONS_TOTAL, :STATIONS_DATABASE, :STATIONS_DUPLICATES) ');
     ParamByName('ID').Value:=cruise_id;
     ParamByName('platform_id').Value:=platform_id;
     ParamByName('source_id').Value:=source_id;
     ParamByName('institute_id').Value:=1; //UNKNOWN
     ParamByName('project_id').Value:=0;  //UNKNOWN
     ParamByName('expocode'       ).Value:=FileListBox3.Items.Strings[kf];
     ParamByName('date_added').Value:=now;
     ParamByName('date_updated').Value:=now;
     ParamByName('date_start_total').Value:=date_start_total;
     ParamByName('date_end_total').Value:=date_end_total;
     ParamByName('date_start_database').Value:=dsdb_DT;
     ParamByName('date_end_database').Value:=dedb_DT;
     ParamByName('cruise_number').Value:=CSR_cruise_number;  //from CSR if was found
     ParamByName('notes'       ).Value:=CSR_notes;  //CSRRef
     ParamByName('latitude_min').Value:=lat_min;
     ParamByName('latitude_max').Value:=lat_max;
     ParamByName('longitude_min').Value:=lon_min;
     ParamByName('longitude_max').Value:=lon_max;
     ParamByName('stations_total').Value:=0;
     ParamByName('stations_database').Value:=stations_database;
     ParamByName('stations_duplicates').Value:=0;
    ExecSQL;
   end;
   frmdm.TR.CommitRetaining;
 end;
{.....step4}



{step 5: split cruise to stations, populate STATION, populate P_tables}
{58VG,0143,B,1931-07-17T08:00,66.97,2.43,,0,10.37,34.661,,,,,,,,,,,,}
    if CheckBox1.Checked then memo1.Lines.Add('...step 5');
    Reset(fi);
    readln(fi,str); //skip header;
    cl:=1;   //count lines
{ST}for ks:=0 to High(StLine)-1 do begin

    //SetLength(Station,0,0);
    station_id:=station_id+1;
    L1:=StLine[ks];
    L2:=StLine[ks+1]; //number of levels at station
    LL:=L2-L1;

    SetLength(Station,LL,Length(StVar)*2+2); //[levels] x [m+dbar+variables+QCF]

//showmessage('cruise_id='+inttostr(cruise_id)+'  station_id='+inttostr(cruise_id));
//showmessage('High(Station)='+inttostr(High(Station))+'  High(StVar)='+inttostr(High(StVar)));

    for i:=0 to High(Station) do begin
    for j:=0 to High(StVar)*2+2 do begin
     Station[i,j]:=-9999;
    end;
    end;

//showmessage('ks='+inttostr(ks)+'  LL='+inttostr(LL));
{L}for kL:=1 to LL do begin
    readln(fi,str);
    cl:=cl+1;

    col:=0;
    buf:='';
{s}for i:=1 to length(str) do begin
    {...check for tab and less-than sign}
    if ord(str[i])<>9 then buf:=buf+str[i]
    else begin
      col:=col+1;
      if copy(buf,1,1)='<' then begin
      buf:=copy(buf,2,length(buf));
      memo1.Lines.Add('<'+buf+ 'converted to '+buf);
      end;
      col_arr[col]:=buf;
      buf:='';
    end;
{s}end;
    col:=col+1;
    col_arr[col]:=buf;

    {depth level conversion}
    st_lev_m:=col_arr[15];
    st_lev_dbar:=col_arr[17];
    if st_lev_m<>'' then lev_m:=strtofloat(st_lev_m) else lev_m:=-9999;
    if st_lev_dbar<>'' then lev_dbar:=strtofloat(st_lev_dbar) else lev_dbar:=-9999;

    if (lev_m<>-9999) and (lev_dbar=-9999) then begin
    FuncP:=Tgsw_z_from_p(GetProcedureAddress(libgswteos, 'gsw_p_from_z'));
    lev_dbar:=FuncP(-lev_m, lat, 0, 0);
    end;

    if (lev_dbar<>-9999) and (lev_m=-9999) then begin
    FuncZ:=Tgsw_z_from_p(GetProcedureAddress(libgswteos, 'gsw_z_from_p'));
    lev_m:=-FuncZ(lev_dbar, lat, 0, 0);
    end;

    //memo1.Lines.Add(inttostr(station_id)+'  lat='+floattostr(lat)+'  lev_m='+floattostr(lev_m)
    //+'  lev_dbar='+floattostr(lev_dbar));

    Station[kL-1,0]:=lev_dbar;
    Station[kL-1,1]:=lev_m;


//showmessage('kl='+inttostr(kl)+'  lev_m='+floattostr(lev_m));

    {variables, start from index=2}
{i}for i:=19 to col do begin
     if col_arr[i]<>'' then Station[kL-1,i-17]:=strtofloat(col_arr[i])
                       else Station[kL-1,i-17]:=-9999;
{i}end;


    {...station metadata}
{md}if kL=1 then begin
    nodc_code:=trim(col_arr[1]);
    st_num:=trim(col_arr[2]);
    st_type:=trim(col_arr[3]);

//showmessage('str='+str);
//showmessage('st_num='+st_num);

    y:=strtoint(col_arr[4]);
    m:=strtoint(col_arr[5]);
    d:=strtoint(col_arr[6]);
    if(col_arr[7]<>'') then hh:=strtoint(col_arr[7]) else hh:=0;
    if(col_arr[8]<>'') then mm:=strtoint(col_arr[8]) else mm:=0;

    {convert date and time into datetime}
    st_DT:= procedures.DateEncode(y,m,d,hh,mm,DayChange,DateChange);
    if DayChange=true  then day_cc:=day_cc+1;
    if DateChange=true then date_cc:=date_cc+1;

    st_lat:=col_arr[9];
    st_lon:=col_arr[10];
    st_bd:=col_arr[11];

    {instrument_id}
    //if copy(FileListBox3.Items.Strings[kf],1,2)='B_' then instrument_id:=7;
    //if copy(FileListBox3.Items.Strings[kf],1,2)='C_' then instrument_id:=4;
    {position}
    lat:=strtofloat(st_lat);
    lon:=strtofloat(st_lon);
    {bottom depth}
    if st_bd<>'' then bd:=strtoint(st_bd) else bd:=-9999;
    {level}
    last_lev_dbar:=lev_dbar;
    last_lev_m:=lev_m;
{md}end;

    if last_lev_dbar<lev_dbar then last_lev_dbar:=lev_dbar;
    if last_lev_m<lev_m then last_lev_m:=lev_m;

{L}end;

    StVersion:=0;
    CountDup:=0;
   with frmdm.q1 do begin
    Close;
    SQL.Clear;
    SQL.Add(' Select count(id) from STATION ');
    SQL.Add(' where dateandtime=:st_DT and ');
    SQL.Add(' latitude=:lat and longitude=:lon and cast_number=:cast_number ');
    ParamByName('st_DT').AsDateTime:=st_DT;
    ParamByName('lat' ).Asfloat:=lat;
    ParamByName('lon' ).AsFloat:=lon;
    ParamByName('cast_number').AsInteger:=1;
    Open;
    if not IsEmpty then
    CountDup:=FieldByName('count').AsInteger;
    Close;
   end;

//showmessage('CountDup='+inttostr(CountDup));
    if CountDup>0 then StVersion:=CountDup+1;


   if CheckBox1.Checked then
   memo1.Lines.Add(inttostr(station_id)
   +#9+'  L1->L2: '+inttostr(L1)+'->'+inttostr(L2)
   +#9+floattostr(lat)
   +#9+floattostr(lon)
   +#9+datetimetostr(st_DT)
   +#9+inttostr(bd)
   +#9+floattostr(last_lev_dbar)
   +#9+floattostrF(last_lev_m,ffFixed,6,1)
   +#9+'st_num='+st_num
   );

   if CheckBox2.Checked then
   with frmdm.q1 do begin
    Close;
    SQL.Clear;
    SQL.Add(' INSERT INTO STATION ' );
    SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ' );
    SQL.Add(' BottomDepth, LastLevel_m, LastLevel_dbar, ' );
    SQL.Add('  ST_NUMBER_ORIGIN, CAST_NUMBER, QCFLAG, ' );
    SQL.Add('  STVERSION, DUPLICATE, DATE_ADDED, DATE_UPDATED)' );
    SQL.Add(' VALUES ' );
    SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ' );
    SQL.Add(' :BottomDepth, :LastLevel_m, :LastLevel_dbar, ' );
    SQL.Add('  :ST_NUMBER_ORIGIN, :CAST_NUMBER, :QCFLAG, ' );
    SQL.Add('   :STVERSION, :DUPLICATE, :DATE_ADDED, :DATE_UPDATED) ' );
    ParamByName('ID'               ).Value:=station_id;
    ParamByName('LATITUDE'         ).Value:=lat;
    ParamByName('LONGITUDE'        ).Value:=lon;
    ParamByName('DATEANDTIME'      ).Value:=st_DT;
    if bd<>-9999 then
    ParamByName('BottomDepth'      ).Value:=bd;
    ParamByName('CRUISE_ID'        ).Value:=cruise_id;
    ParamByName('LastLevel_m'        ).Value:=last_lev_m;
    ParamByName('LastLevel_dbar'     ).Value:=last_lev_dbar;
    ParamByName('ST_NUMBER_ORIGIN' ).Value:=st_num;
    ParamByName('CAST_NUMBER'      ).Value:=1;
    ParamByName('QCFLAG'           ).Value:=0;
    ParamByName('STVERSION'        ).Value:=StVersion;
    ParamByName('DUPLICATE'        ).Value:=false;
    ParamByName('DATE_ADDED'       ).Value:=now;
    ParamByName('DATE_UPDATED'     ).Value:=now;
    ExecSQL;
   end;
   if CheckBox2.Checked then
   frmdm.TR.CommitRetaining;

{...STATION array}
if CheckBox1.Checked then begin
memo1.Lines.Add('');
memo1.Lines.Add('cruise_id='+inttostr(cruise_id)+'  Station_id='+inttostr(station_id));
for i:=0 to High(Station) do begin
 str:='';
for j:=0 to High(StVar)*2+2 do begin str:=str+floattostrF(Station[i,j],ffFixed,9,3)+#9; end;
 memo1.Lines.Add(str);
end;
end;

{...tables with data}
{var}for j:=0 to High(StVar) do begin  //23 (0-22) ICES variables

     prfn:=1; //profile numnber to destinct different units

{B}if instrument='Bottle' then begin
     case j of
 0:  begin vi:=0;  qi:=1;  end; //temperature var and QCF indexes in STATION
 1:  begin vi:=2;  qi:=3;  end; //salinity
 2:  begin vi:=4;  qi:=5;  end; //oxygen mL/L
 3:  begin vi:=6;  qi:=7; prfn:=2; end; //oxygen mL/kg
 4:  begin vi:=8;  qi:=9;  end; //phosphate umol/L
 5:  begin vi:=10; qi:=11; prfn:=2; end; //phosphate umol/kg
 6:  begin vi:=12; qi:=13; end; //total phosphorus umol/L
 7:  begin vi:=14; qi:=15; prfn:=2; end; //total phosphorus umol/kg
 8:  begin vi:=16; qi:=17; end; //silicate umol/L
 9:  begin vi:=18; qi:=19; prfn:=2; end; //silicate umol/kg
 10: begin vi:=20; qi:=21; end; //nitrate umol/L
 11: begin vi:=22; qi:=23; prfn:=2; end; //nitrate umol/kg
 12: begin vi:=24; qi:=25; end; //nitrite umol/L
 13: begin vi:=26; qi:=27; prfn:=2; end; //nitrite umol/kg
 14: begin vi:=28; qi:=29; end; //ammonium umol/L
 15: begin vi:=30; qi:=31; prfn:=2; end; //ammonium umol/kg
 16: begin vi:=32; qi:=33; end; //TDN umol/L
 17: begin vi:=34; qi:=35; end; //H2S umol/L
 18: begin vi:=36; qi:=37; end; //PH
 19: begin vi:=38; qi:=39; end; //Alkalinity mEq/L
 20: begin vi:=40; qi:=41; prfn:=2; end; //Alkalinity mEq/kg
 21: begin vi:=42; qi:=43; end; //Chlorophyll ug/L
 22: begin vi:=44; qi:=45; prfn:=2; end; //Chlorophyll ug/kg
     end;
{B}end;

{C}if instrument='CTD' then begin
     case j of
 0:  begin vi:=0;  qi:=1;  end; //temperature var and QCF indexes in STATION
 1:  begin vi:=2;  qi:=3;  end; //salinity
 2:  begin vi:=4;  qi:=5;  end; //oxygen mL/L
 3:  begin vi:=6;  qi:=7; prfn:=2; end; //oxygen mL/kg
 4:  begin vi:=8; qi:=9; end; //PH
 5:  begin vi:=10; qi:=11; end; //Chlorophyll ug/L
     end;
{C}end;

     {...check if values exist}
     mik:=0;
     for i:=0 to High(Station) do begin
     if Station[i,vi+2]<>-9999 then mik:=mik+1;
     {Showmessage('i='+inttostr(i)
     +'  Station[i,0]='+floattostr(Station[i,0])
     +' [vi+2]='+inttostr(vi+2)
     +'  Station[i,vi+2]='+floattostr(Station[i,vi+2])
     + '  mik='+inttostr(vi+2));}
     end;

     //memo1.Lines.Add(inttostr(station_id)+#9+StVar[j].Table+'  vi='+inttostr(vi)+'  mik='+inttostr(mik));

{prf}if mik>0 then begin
      tbl:=StVar[j].Table;
      units_id:=StVar[j].UnitID;
      if CheckBox1.Checked then
      memo1.Lines.Add(StVar[j].Table+'->'+inttostr(mik));
{lev}for i:=0 to High(Station) do begin

{out}if Station[i,vi+2]<>-9999 then begin
     //memo1.Lines.Add(floattostrF(Station[i,0],ffFixed,9,1)
     //+#9+floattostrF(Station[i,1],ffFixed,9,1)
     //+#9+floattostrF(Station[i,j+2],ffFixed,9,3));

{populate P_tables}
      PQF2:=0;
      PQF1:=trunc(Station[i,qi+2]);
      case PQF1 of
      1: PQF2:=4; //good value
      4: PQF2:=1; //bad value
      end;

if CheckBox2.Checked then
with frmdm.q1 do begin
 Close;
  SQL.Clear;
  SQL.Add(' insert into ');
  SQL.Add(tbl);
  SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF1, PQF2, SQF, UNITS_ID, ');
  SQL.Add('  INSTRUMENT_ID, PROFILE_NUMBER, PROFILE_BEST) ');
  SQL.Add(' values ');
  SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF1, :PQF2, :SQF, :UNITS_ID, ');
  SQL.Add('  :INSTRUMENT_ID, :PROFILE_NUMBER, :PROFILE_BEST) ');
  ParamByName('ID').AsInteger:=station_id;
  ParamByName('LEV_DBAR').AsFloat:=Station[i,0];
  ParamByName('LEV_M').AsFloat:=Station[i,1];
  ParamByName('VAL').AsFloat:=Station[i,vi+2];
  ParamByName('PQF1').AsInteger:=PQF1;
  ParamByName('PQF2').AsInteger:=PQF2;
  ParamByName('SQF').AsInteger:=0;
  ParamByName('UNITS_ID').AsInteger:=units_id;
  ParamByName('INSTRUMENT_ID').AsInteger:=instrument_id;
  ParamByName('PROFILE_NUMBER').AsInteger:=prfn;
  ParamByName('PROFILE_BEST').AsBoolean:=true;
 ExecSQL;
end;
{out}end;
{lev}end;
   if CheckBox2.Checked then
   frmdm.TR.CommitRetaining;
{prf}end;
{var}end;
     SetLength(Station,0,0);
{ST}end;
{.....step 5}


    closefile(fi);
{F}end;

DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;



procedure Tfrmload_ices2.btnAddBottleToCTDClick(Sender: TObject);
var
mik :integer;
cbs,cds,cdst,stid_btl,stid_ctd :integer;
lat_btl,lon_btl :real;
str,sno_btl,sno_ctd :string;
DT_btl: TDateTime;
begin
DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));

memo1.Lines.Add('');
memo1.Lines.Add('CTD DB   : '+frmdm.IBDB.DatabaseName);
memo1.Lines.Add('Bottle DB: '+IBDB2.DatabaseName);
memo1.Lines.Add('');
memo1.Lines.Add('CTD DB  cruise_id max='+inttostr(crid_max));
memo1.Lines.Add('CTD DB station_id max='+inttostr(stid_max));

fn:=pathPreview+'merge.txt';
AssignFile(fo,concat(fn));
Rewrite(fo);
writeln(fo,'...merge CTD and BTL');

{.....step1: find station duplicates}
   {...btl}
   with q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select id, latitude, longitude, dateandtime, st_number_origin ');
     SQL.Add(' from STATION ');
     Open;
   end;

    cbs:=0; //count btl stations
    cdst:=0; //count duplicate stations total
{btl}while not q1.EOF do begin
    inc(cbs);
    label1.Caption:='btl station='+inttostr(cbs);
    if cbs MOD 10000=0 then Application.ProcessMessages;


    stid_btl:=q1.FieldByName('id').AsInteger;
    lat_btl:=q1.FieldByName('latitude').AsFloat;
    lon_btl:=q1.FieldByName('longitude').AsFloat;
    DT_btl:=q1.FieldByName('dateandtime').AsDateTime;
    sno_btl:=q1.FieldByName('st_number_origin').AsString;

    str:=inttostr(stid_btl)+'->';

    {...ctd}
    with frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' select id, st_number_origin ');
      SQL.Add(' from STATION ');
      SQL.Add(' where ');
      SQL.Add(' latitude between :LatMin and :LatMax and ');
      SQL.Add(' longitude between :LonMin and :LonMax and ');
      SQL.Add(' dateandtime between :DateMin and :DateMax ');
      ParambyName('LatMin').AsFloat:=lat_btl-seThreshold.Value;
      ParambyName('LatMax').AsFloat:=lat_btl+seThreshold.Value;
      ParambyName('LonMin').AsFloat:=lon_btl-seThreshold.Value;
      ParambyName('LonMax').AsFloat:=lon_btl+seThreshold.Value;
      ParambyName('DateMin').AsDateTime:=IncDay(DT_btl, -seDateThreshold.Value);
      ParambyName('DateMax').AsDateTime:=IncDay(DT_btl,  seDateThreshold.Value);
    Open;
  end;

    cds:=0; //count duplicate stations
{ctd}while not frmdm.q1.EOF do begin
      inc(cds);
      frmdm.q1.Next;
{ctd}end;

      {### COPY station from btl to ctd if not duplicate}
      if (cds=0) then begin
      writeln(fo,'stid_btl='+inttostr(stid_btl)+ '->copy station');
      CopyStation(stid_btl);
      end;

      {...output duplicates}
{dup}if cds>0 then begin
      cdst:=cdst+1;
      writeln(fo);
      writeln(fo,inttostr(cbs)
      +#9+'  btl st_id='
      +#9+inttostr(stID_btl)
      +#9+floattostr(lat_btl)
      +#9+floattostr(lon_btl)
      +#9+FormatDateTime('DD.MM.YYYY hh:mm',DT_btl)
      +#9+inttostr(cds)
      +#9+'  sno_btl='+sno_btl
      );

      frmdm.q1.First;
      mik:=0;
{ctd}while not frmdm.q1.EOF do begin
      inc(mik);
      stid_ctd:=frmdm.q1.FieldByName('id').AsInteger;
      sno_ctd:=frmdm.q1.FieldByName('st_number_origin').AsString;
      writeln(fo,#9+'ctd: '+inttostr(mik)
      +'  station_id='+inttostr(stid_ctd)
      +'  sno='+sno_ctd);
      str:=str+inttostr(stid_ctd)+',';

      {### ADD profiles from btl station to ctd station}
      if sno_btl=sno_ctd then begin
       writeln(fo,'stid_btl='+inttostr(stid_btl)+ '->add profiles');
       AddProfiles(stid_btl,stid_ctd);
      end;

      frmdm.q1.Next;
{ctd}end;
      frmdm.q1.Close;

{memo}if cds>1 then begin
      memo1.Lines.Add(inttostr(cbs)
      +#9+inttostr(cds)
      +#9+'  btl st_id='
      +#9+inttostr(stID_btl)
      +#9+floattostr(lat_btl)
      +#9+floattostr(lon_btl)
      +#9+FormatDateTime('DD.MM.YYYY hh:mm',DT_btl)
      +#9+str
      );
{memo}end;

{dup}end;

    q1.Next;
{btl}end;
    q1.Close;
    writeln(fo);
    writeln(fo,'stations duplicates total='+inttostr(cdst));
    closefile(fo);
    label1.Caption:='btl station='+inttostr(cbs);
{.....step1}


DT2:=NOW;
memo1.Lines.Add('');
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;



procedure Tfrmload_ices2.CopyStation(stid_btl:Int64);
var
kt :integer;
crid_btl,crid_ctd,platform_id,ccr,clev :integer;
lat,lon :real;
tbl :string;
DT: TDateTime;
begin

   {...new station_id to be added to target CTD DB}
   inc(stid_max);

   {...btl: STATION}
   with q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select * from STATION ');
     SQL.Add(' where id=:stid_btl ');
     ParamByName('stid_btl').AsInteger:=stid_btl;
     Open;
     crid_btl:=FieldByName('cruise_id').AsInteger;
     lat:=FieldByName('latitude').AsFloat;
     lon:=FieldByName('longitude').AsFloat;
     DT:=FieldByName('dateandtime').AsDateTime;
   end;

   {...btl: CRUISE}
   with q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select * from CRUISE ');
     SQL.Add(' where id=:crid_btl ');
     ParamByName('crid_btl').AsInteger:=crid_btl;
     Open;
     platform_id:=FieldByName('platform_id').AsInteger;
   end;

   {...ctd: CRUISE: find if btl station belong to ctd cruise}
     ccr:=0; //count cruise
   with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select count(id) from CRUISE ');
     SQL.Add(' where platform_id=:platform_id ');
     SQL.Add(' and latitude_min<=:lat and latitude_max>=:lat ');
     SQL.Add(' and longitude_min<=:lon and longitude_max>=:lon ');
     SQL.Add(' and date_start_database<=:dt and date_end_database>=:dt ');
     ParamByName('platform_id').AsInteger:=platform_id;
     ParamByName('lat').AsFloat:=lat;
     ParamByName('lon').AsFloat:=lon;
     ParamByName('dt').AsDateTime:=dt;
     Open;
     ccr:=FieldByName('count').AsInteger;
     Close;
   end;

   {...add btl cruise as new ctd cruise}
{N}if ccr=0 then begin
    inc(crid_max);
    writeln(fo,'...station='+inttostr(stid_btl)
    +'  btl cruise='+inttostr(crid_btl)
    +'  new ctd cruise='+inttostr(crid_max)
    );

   {...add btl cruise to ctd CRUISE with new id}
   if CheckBox2.Checked then begin
   with frmdm.q2 do begin
    Close;
     SQL.Clear;
     SQL.Add('insert into CRUISE');
     SQL.Add(' (ID, platform_id, source_id, institute_id, project_id, expocode, notes, ');
     SQL.Add(' DATE_ADDED, DATE_UPDATED, DATE_START_TOTAL, DATE_END_TOTAL,  ');
     SQL.Add(' DATE_START_DATABASE, DATE_END_DATABASE, CRUISE_NUMBER,');
     SQL.Add(' LATITUDE_MIN, LATITUDE_MAX, LONGITUDE_MIN, LONGITUDE_MAX,');
     SQL.Add(' STATIONS_TOTAL, STATIONS_DATABASE, STATIONS_DUPLICATES) ');
     SQL.Add(' VALUES ' );
     SQL.Add(' (:ID, :platform_id, :source_id, :institute_id, :project_id, :expocode, :notes, ');
     SQL.Add(' :DATE_ADDED, :DATE_UPDATED, :DATE_START_TOTAL, :DATE_END_TOTAL, ');
     SQL.Add(' :DATE_START_DATABASE, :DATE_END_DATABASE, :CRUISE_NUMBER, ');
     SQL.Add(' :LATITUDE_MIN, :LATITUDE_MAX, :LONGITUDE_MIN, :LONGITUDE_MAX,');
     SQL.Add(' :STATIONS_TOTAL, :STATIONS_DATABASE, :STATIONS_DUPLICATES) ');
     ParamByName('ID').Value:=crid_max;
     ParamByName('platform_id').Value:=platform_id;
     ParamByName('source_id').Value:=q3.FieldByName('source_id').Value;
     ParamByName('institute_id').Value:=q3.FieldByName('institute_id').Value;
     ParamByName('project_id').Value:=q3.FieldByName('project_id').Value;
     ParamByName('expocode').Value:=q3.FieldByName('expocode').Value;
     ParamByName('date_added').Value:=now;
     ParamByName('date_updated').Value:=now;
     ParamByName('date_start_total').Value:=q3.FieldByName('date_start_total').Value;
     ParamByName('date_end_total').Value:=q3.FieldByName('date_end_total').Value;
     ParamByName('date_start_database').Value:=q3.FieldByName('date_start_database').Value;
     ParamByName('date_end_database').Value:=q3.FieldByName('date_end_database').Value;
     ParamByName('cruise_number').Value:=q3.FieldByName('cruise_number').Value;
     ParamByName('notes').Value:=q3.FieldByName('notes').Value;
     ParamByName('latitude_min').Value:=q3.FieldByName('latitude_min').Value;
     ParamByName('latitude_max').Value:=q3.FieldByName('latitude_max').Value;
     ParamByName('longitude_min').Value:=q3.FieldByName('longitude_min').Value;
     ParamByName('longitude_max').Value:=q3.FieldByName('longitude_max').Value;
     ParamByName('stations_total').Value:=q3.FieldByName('stations_total').Value;
     ParamByName('stations_database').Value:=q3.FieldByName('stations_database').Value;
     ParamByName('stations_duplicates').Value:=q3.FieldByName('stations_duplicates').Value;
    ExecSQL;
   end;
   frmdm.TR.CommitRetaining;
 end;

   {...add btl station to ctd STATION with new id}
  if CheckBox2.Checked then begin
  with frmdm.q2 do begin
   Close;
   SQL.Clear;
   SQL.Add(' INSERT INTO STATION ' );
   SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ' );
   SQL.Add(' BottomDepth, LastLevel_m, LastLevel_dbar, ' );
   SQL.Add('  ST_NUMBER_ORIGIN, CAST_NUMBER, QCFLAG, ' );
   SQL.Add('  STVERSION, DUPLICATE, DATE_ADDED, DATE_UPDATED)' );
   SQL.Add(' VALUES ' );
   SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ' );
   SQL.Add(' :BottomDepth, :LastLevel_m, :LastLevel_dbar, ' );
   SQL.Add('  :ST_NUMBER_ORIGIN, :CAST_NUMBER, :QCFLAG, ' );
   SQL.Add('   :STVERSION, :DUPLICATE, :DATE_ADDED, :DATE_UPDATED) ' );
   ParamByName('ID').Value:=stid_max;
   ParamByName('LATITUDE').Value:=q2.FieldByName('LATITUDE').Value;
   ParamByName('LONGITUDE').Value:=q2.FieldByName('LONGITUDE').Value;
   ParamByName('DATEANDTIME').Value:=q2.FieldByName('DATEANDTIME').Value;
   ParamByName('BottomDepth').Value:=q2.FieldByName('BottomDepth').Value;
   ParamByName('CRUISE_ID').Value:=crid_max;
   ParamByName('LastLevel_m').Value:=q2.FieldByName('LastLevel_m').Value;
   ParamByName('LastLevel_dbar').Value:=q2.FieldByName('LastLevel_dbar').Value;
   ParamByName('ST_NUMBER_ORIGIN').Value:=q2.FieldByName('ST_NUMBER_ORIGIN').Value;
   ParamByName('CAST_NUMBER').Value:=q2.FieldByName('CAST_NUMBER').Value;
   ParamByName('QCFLAG').Value:=q2.FieldByName('QCFLAG').Value;
   ParamByName('STVERSION').Value:=q2.FieldByName('STVERSION').Value;
   ParamByName('DUPLICATE').Value:=q2.FieldByName('DUPLICATE').Value;
   ParamByName('DATE_ADDED').Value:=now;
   ParamByName('DATE_UPDATED').Value:=now;
   ExecSQL;
  end;
  frmdm.TR.CommitRetaining;
  end;

  //q2.Close;
  q3.Close;

  {...add all variables from btl DB to ctd DB with new station ID}
  {...variables in btl DB}
{T}for kt:=0 to ListBox1.Items.Count-1 do begin
{P_}if (copy(ListBox1.items.strings[kt],1,2)='P_') then begin

   tbl:=ListBox1.items.strings[kt];

   clev:=0; //count levels
   with q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select count(id) from '+tbl);
     SQL.Add(' where id=:stid_btl ');
     ParamByName('stid_btl').AsInteger:=stid_btl;
     Open;
     clev:=FieldByName('count').AsInteger;
     Close;
   end;


   {...copy variable btl->ctd}
{TBL}if clev>0 then begin
    writeln(fo,#9+'(btl cruise)  '+tbl+'  clev='+inttostr(clev));
{db}if CheckBox2.Checked then begin

    with q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select * from '+tbl);
     SQL.Add(' where id=:stid_btl ');
     SQL.Add(' order by profile_number, lev_dbar ');
     ParamByName('stid_btl').AsInteger:=stid_btl;
     Open;
    end;

{q2}while not q3.EOF do begin
    with frmdm.q2 do begin
     Close;
       SQL.Clear;
       SQL.Add(' insert into ');
       SQL.Add(tbl);
       SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF1, PQF2, SQF, BOTTLE_NUMBER, PROFILE_NUMBER, UNITS_ID, INSTRUMENT_ID, PROFILE_BEST) ');
       SQL.Add(' values ');
       SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF1, :PQF2, :SQF, :BOTTLE_NUMBER, :PROFILE_NUMBER, :UNITS_ID, :INSTRUMENT_ID, :PROFILE_BEST) ');
       ParamByName('ID').AsInteger:=stid_max;
       ParamByName('LEV_DBAR').AsFloat:=q3.FieldByName('lev_dbar').AsFloat;
       ParamByName('LEV_M').AsFloat:=q3.FieldByName('lev_m').AsFloat;
       ParamByName('VAL').AsFloat:=q3.FieldByName('val').AsFloat;
       ParamByName('PQF1').AsInteger:=q3.FieldByName('pqf1').AsInteger;
       ParamByName('PQF2').AsInteger:=q3.FieldByName('pqf2').AsInteger;
       ParamByName('SQF').AsInteger:=q3.FieldByName('sqf').AsInteger;
       ParamByName('BOTTLE_NUMBER').AsInteger:=q3.FieldByName('bottle_number').AsInteger;
       ParamByName('UNITS_ID').AsInteger:=q3.FieldByName('units_id').AsInteger;
       ParamByName('INSTRUMENT_ID').AsInteger:=q3.FieldByName('INSTRUMENT_ID').AsInteger;
       ParamByName('PROFILE_NUMBER').AsInteger:=q3.FieldByName('profile_number').AsInteger;;
       ParamByName('PROFILE_BEST').AsBoolean:=q3.FieldByName('profile_best').AsBoolean;;
       ExecSQL;
    end;
     q3.Next;
{q2}end;
     q3.Close;
     frmdm.TR.CommitRetaining;
{db}end;
{TBL}end;
{P_}end;
{T}end;
{N}end;



   {...add btl station and profiles to existing ctd cruise}
{Ex}if ccr>0 then begin

    with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select id from CRUISE ');
     SQL.Add(' where platform_id=:platform_id ');
     SQL.Add(' and latitude_min<=:lat and latitude_max>=:lat ');
     SQL.Add(' and longitude_min<=:lon and longitude_max>=:lon ');
     SQL.Add(' and date_start_database<=:dt and date_end_database>=:dt ');
     ParamByName('platform_id').AsInteger:=platform_id;
     ParamByName('lat').AsFloat:=lat;
     ParamByName('lon').AsFloat:=lon;
     ParamByName('dt').AsDateTime:=dt;
     Open;
     crid_ctd:=FieldByName('id').AsInteger;
     Close;
    end;

    {...add btl station to ctd STATION with new station id and existing ctd cruise id}
{db}if CheckBox2.Checked then begin
   with frmdm.q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' INSERT INTO STATION ' );
    SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ' );
    SQL.Add(' BottomDepth, LastLevel_m, LastLevel_dbar, ' );
    SQL.Add('  ST_NUMBER_ORIGIN, CAST_NUMBER, QCFLAG, ' );
    SQL.Add('  STVERSION, DUPLICATE, DATE_ADDED, DATE_UPDATED)' );
    SQL.Add(' VALUES ' );
    SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ' );
    SQL.Add(' :BottomDepth, :LastLevel_m, :LastLevel_dbar, ' );
    SQL.Add('  :ST_NUMBER_ORIGIN, :CAST_NUMBER, :QCFLAG, ' );
    SQL.Add('   :STVERSION, :DUPLICATE, :DATE_ADDED, :DATE_UPDATED) ' );
    ParamByName('ID').Value:=stid_max;
    ParamByName('LATITUDE').Value:=q2.FieldByName('LATITUDE').Value;
    ParamByName('LONGITUDE').Value:=q2.FieldByName('LONGITUDE').Value;
    ParamByName('DATEANDTIME').Value:=q2.FieldByName('DATEANDTIME').Value;
    ParamByName('BottomDepth').Value:=q2.FieldByName('BottomDepth').Value;
    ParamByName('CRUISE_ID').Value:=crid_ctd;
    ParamByName('LastLevel_m').Value:=q2.FieldByName('LastLevel_m').Value;
    ParamByName('LastLevel_dbar').Value:=q2.FieldByName('LastLevel_dbar').Value;
    ParamByName('ST_NUMBER_ORIGIN').Value:=q2.FieldByName('ST_NUMBER_ORIGIN').Value;
    ParamByName('CAST_NUMBER').Value:=q2.FieldByName('CAST_NUMBER').Value;
    ParamByName('QCFLAG').Value:=q2.FieldByName('QCFLAG').Value;
    ParamByName('STVERSION').Value:=q2.FieldByName('STVERSION').Value;
    ParamByName('DUPLICATE').Value:=q2.FieldByName('DUPLICATE').Value;
    ParamByName('DATE_ADDED').Value:=now;
    ParamByName('DATE_UPDATED').Value:=now;
    ExecSQL;
   end;
   frmdm.TR.CommitRetaining;
{db}end;

{...add all variables from btl DB to ctd DB with new station ID}
{...variables in btl DB}
{T}for kt:=0 to ListBox1.Items.Count-1 do begin
{P_}if (copy(ListBox1.items.strings[kt],1,2)='P_') then begin

   tbl:=ListBox1.items.strings[kt];

   clev:=0; //count levels
   with q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select count(id) from '+tbl);
     SQL.Add(' where id=:stid_btl ');
     ParamByName('stid_btl').AsInteger:=stid_btl;
     Open;
     clev:=FieldByName('count').AsInteger;
     Close;
   end;

   {...copy variable btl->ctd}
{TBL}if clev>0 then begin
    writeln(fo,#9+'(ctd cruise)  '+tbl+'  clev='+inttostr(clev));
{db}if CheckBox2.Checked then begin

    with q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select * from '+tbl);
     SQL.Add(' where id=:stid_btl ');
     SQL.Add(' order by profile_number, lev_dbar ');
     ParamByName('stid_btl').AsInteger:=stid_btl;
     Open;
    end;

{q2}while not q3.EOF do begin
    with frmdm.q2 do begin
     Close;
       SQL.Clear;
       SQL.Add(' insert into ');
       SQL.Add(tbl);
       SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF1, PQF2, SQF, BOTTLE_NUMBER, PROFILE_NUMBER, UNITS_ID, INSTRUMENT_ID, PROFILE_BEST) ');
       SQL.Add(' values ');
       SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF1, :PQF2, :SQF, :BOTTLE_NUMBER, :PROFILE_NUMBER, :UNITS_ID, :INSTRUMENT_ID, :PROFILE_BEST) ');
       ParamByName('ID').AsInteger:=stid_max;
       ParamByName('LEV_DBAR').AsFloat:=q3.FieldByName('lev_dbar').AsFloat;
       ParamByName('LEV_M').AsFloat:=q3.FieldByName('lev_m').AsFloat;
       ParamByName('VAL').AsFloat:=q3.FieldByName('val').AsFloat;
       ParamByName('PQF1').AsInteger:=q3.FieldByName('pqf1').AsInteger;
       ParamByName('PQF2').AsInteger:=q3.FieldByName('pqf2').AsInteger;
       ParamByName('SQF').AsInteger:=q3.FieldByName('sqf').AsInteger;
       ParamByName('BOTTLE_NUMBER').AsInteger:=q3.FieldByName('bottle_number').AsInteger;
       ParamByName('UNITS_ID').AsInteger:=q3.FieldByName('units_id').AsInteger;
       ParamByName('INSTRUMENT_ID').AsInteger:=q3.FieldByName('INSTRUMENT_ID').AsInteger;
       ParamByName('PROFILE_NUMBER').AsInteger:=q3.FieldByName('profile_number').AsInteger;;
       ParamByName('PROFILE_BEST').AsBoolean:=q3.FieldByName('profile_best').AsBoolean;;
       ExecSQL;
    end;
     q3.Next;
{q2}end;
     q3.Close;
     frmdm.TR.CommitRetaining;
{db}end;
{TBL}end;
{P_}end;
{T}end;
{Ex}end;
   q2.close;
end;

{.....add btl station's profiles into existing ctd station}
procedure Tfrmload_ices2.AddProfiles(stid_btl,stid_ctd:Int64);
var
kt :integer;
clev :integer;
tbl :string;
begin

{T}for kt:=0 to ListBox1.Items.Count-1 do begin
{P_}if (copy(ListBox1.items.strings[kt],1,2)='P_') then begin

   tbl:=ListBox1.items.strings[kt];

   clev:=0; //count levels
   with q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select count(id) from '+tbl);
     SQL.Add(' where id=:stid_btl ');
     ParamByName('stid_btl').AsInteger:=stid_btl;
     Open;
     clev:=FieldByName('count').AsInteger;
     Close;
   end;

   {...copy variable btl->ctd station (the same ctd cruise and station IDs)}
{TBL}if clev>0 then begin
    writeln(fo,#9+'(ctd station)  '+tbl+'  clev='+inttostr(clev));
{db}if CheckBox2.Checked then begin

    with q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select * from '+tbl);
     SQL.Add(' where id=:stid_btl ');
     SQL.Add(' order by profile_number, lev_dbar ');
     ParamByName('stid_btl').AsInteger:=stid_btl;
     Open;
    end;

{q2}while not q3.EOF do begin
    with frmdm.q2 do begin
     Close;
       SQL.Clear;
       SQL.Add(' insert into ');
       SQL.Add(tbl);
       SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF1, PQF2, SQF, BOTTLE_NUMBER, PROFILE_NUMBER, UNITS_ID, INSTRUMENT_ID, PROFILE_BEST) ');
       SQL.Add(' values ');
       SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF1, :PQF2, :SQF, :BOTTLE_NUMBER, :PROFILE_NUMBER, :UNITS_ID, :INSTRUMENT_ID, :PROFILE_BEST) ');
       ParamByName('ID').AsInteger:=stid_ctd;
       ParamByName('LEV_DBAR').AsFloat:=q3.FieldByName('lev_dbar').AsFloat;
       ParamByName('LEV_M').AsFloat:=q3.FieldByName('lev_m').AsFloat;
       ParamByName('VAL').AsFloat:=q3.FieldByName('val').AsFloat;
       ParamByName('PQF1').AsInteger:=q3.FieldByName('pqf1').AsInteger;
       ParamByName('PQF2').AsInteger:=q3.FieldByName('pqf2').AsInteger;
       ParamByName('SQF').AsInteger:=q3.FieldByName('sqf').AsInteger;
       ParamByName('BOTTLE_NUMBER').AsInteger:=q3.FieldByName('bottle_number').AsInteger;
       ParamByName('UNITS_ID').AsInteger:=q3.FieldByName('units_id').AsInteger;
       ParamByName('INSTRUMENT_ID').AsInteger:=q3.FieldByName('INSTRUMENT_ID').AsInteger;
       ParamByName('PROFILE_NUMBER').AsInteger:=q3.FieldByName('profile_number').AsInteger;;
       ParamByName('PROFILE_BEST').AsBoolean:=q3.FieldByName('profile_best').AsBoolean;;
       ExecSQL;
    end;
     q3.Next;
{q2}end;
     q3.Close;
     frmdm.TR.CommitRetaining;
{db}end;
{TBL}end;
{P_}end;
{T}end;
end;


procedure Tfrmload_ices2.btnUpdateProfileBestClick(Sender: TObject);
var
i,kt :integer;
station_id,instrument_id,cinst :int64;
tbl :string;
inst_type :array[1..2] of integer;
begin

DT1:=NOW;
memo1.Lines.Add('...profile_best: '+datetimetostr(DT1));

fn:=pathPreview+'profile_best.txt';
AssignFile(fo,concat(fn));
Rewrite(fo);
writeln(fo,'...set profile_best at ststions for all variables in DB');

case RadioGroup1.ItemIndex of
0: instrument_id:=4;
1: instrument_id:=7;
end;

{T}for kt:=0 to frmosmain.ListBox1.Items.Count-1 do begin

   tbl:=frmosmain.ListBox1.items.strings[kt];
   writeln(fo,'.....new table');
   writeln(fo,tbl);

   label1.Caption:=tbl;
   Application.ProcessMessages;

{db}if CheckBox2.Checked then begin
    with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' update '+tbl);
     SQL.Add(' set profile_best=false ');
     ExecSQL;
    end;
     frmdm.TR.CommitRetaining;
{db}end;

    with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select distinct(id) from '+tbl);
     Open;
    end;

{S}while not frmdm.q1.EOF do begin
    station_id:=frmdm.q1.FieldByName('id').AsInteger;
    //writeln(fo,inttostr(station_id));

    {...instruments number and composition at station}
    with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select distinct(instrument_id) from '+tbl);
     SQL.Add(' where id=:station_id ');
     ParamByName('station_id').AsInteger:=station_id;
     Open;
    end;

     cinst:=0; //count instrument
     frmdm.q2.First;
    while not frmdm.q2.EOF do begin
     inc(cinst);
     inst_type[cinst]:=frmdm.q2.FieldByName('instrument_id').AsInteger;
     frmdm.q2.Next;
    end;
     frmdm.q2.Close;

    {...if only one instrument make prf1 the best}
{1}if cinst=1 then begin
    writeln(fo,#9,inttostr(station_id),#9,'cinst=',inttostr(cinst),#9,inttostr(inst_type[1]));
{db}if CheckBox2.Checked then begin
    with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' update '+tbl);
     SQL.Add(' set profile_best=true where id=:station_id ');
     SQL.Add(' and instrument_id=:instrument_id ');
     SQL.Add(' and profile_number=1 ');
     ParamByName('station_id').AsInteger:=station_id;
     ParamByName('instrument_id').AsInteger:=inst_type[1];
     ExecSQL;
    end;
     frmdm.TR.CommitRetaining;
{db}end;
{1}end;

    {...if two instrument make prf1 the best for instrument selected in settings}
{2}if cinst=2 then begin
    writeln(fo,#9,inttostr(station_id),#9,'cinst=',inttostr(cinst),#9,inttostr(instrument_id));
{db}if CheckBox2.Checked then begin
    with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' update '+tbl);
     SQL.Add(' set profile_best=true where id=:station_id ');
     SQL.Add(' and instrument_id=:instrument_id ');
     SQL.Add(' and profile_number=1 ');
     ParamByName('station_id').AsInteger:=station_id;
     ParamByName('instrument_id').AsInteger:=instrument_id;
     ExecSQL;
    end;
     frmdm.TR.CommitRetaining;
{db}end;
{2}end;

    frmdm.q1.Next;
{S}end;
    frmdm.q1.Close;

{T}end;
    closefile(fo);

DT2:=NOW;
memo1.Lines.Add('');
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;




end.

