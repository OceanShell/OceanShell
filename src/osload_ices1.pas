unit osload_ices1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, FileCtrl, StdCtrls,
  Buttons, ExtCtrls, DateUtils, FileUtil, StrUtils, dynlibs;

type

  { Tfrmload_ices1 }

  Tfrmload_ices1 = class(TForm)
    btnMarkThinnedCTD: TBitBtn;
    btnSplitFile: TBitBtn;
    btnDownloadData: TBitBtn;
    btnCleanDate: TBitBtn;
    btnCleanCruiseName: TBitBtn;
    btnPopuateCruiseTable: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    FileListBox1: TFileListBox;
    FileListBox2: TFileListBox;
    FileListBox3: TFileListBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    procedure btnCleanCruiseNameClick(Sender: TObject);
    procedure btnCleanDateClick(Sender: TObject);
    procedure btnDownloadDataClick(Sender: TObject);
    procedure btnMarkThinnedCTDClick(Sender: TObject);
    procedure btnPopuateCruiseTableClick(Sender: TObject);
    procedure btnSplitFileClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmload_ices1: Tfrmload_ices1;
  pathData,pathCSR,pathCR,pathPreview :string;
  fn :string;
  DT1,DT2 :TDateTime;
  fi,fo,fo1 :text;

implementation

{$R *.lfm}
uses osmain, dm, GibbsSeaWater;

{ Tfrmload_ices1 }

procedure Tfrmload_ices1.FormShow(Sender: TObject);
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
  FileListBox2.Directory:=pathCSR;
  FileListBox3.Directory:=pathCR;
end;





procedure Tfrmload_ices1.btnSplitFileClick(Sender: TObject);
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
ShipCODE :SCDA;
StVar: StVariable;
StDate :array of TDateTime;
CruiseLine: array of integer; //cruises boundary in the text file

cruise_id :int64;
i,kf,col :integer;
cc,cl,scc,vc,crn,L1,L2,platform_id :integer;
y,m,d,hh,mm :word;
str,str_header,buf,name_PLATFORM,name_ICES,name_WOD,name_NATIVE :string;
nameICES,unitICES,crns,instrument :string;
st_num,st_type,st_date,st_lat,st_lon,st_bd :string;
nodc_code :string[4];
col_arr :array[1..100] of string;
shc_new :boolean;
stDT,stDT1,stDT2 :TDateTime;
begin
DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));


if directoryexists(pathCR)=true then deletedirectory(pathCR,true);
if directoryexists(pathCR)=false then mkdir(pathCR);
if directoryexists(pathPreview)=true then deletedirectory(pathPreview,true);
if directoryexists(pathPreview)=false then mkdir(pathPreview);
FileListBox3.Clear;


{F}for kf:=0 to FileListBox1.Items.Count-1 do begin

    fn:=pathData+FileListBox1.Items.Strings[kf];
    if AnsiContainsStr(fn,'b_')=true then instrument:='Bottle';
    if AnsiContainsStr(fn,'c_')=true then instrument:='CTD';
    AssignFile(fi,concat(fn));
    Reset(fi);
    memo1.Lines.Add(fn);
    readln(fi,str);
    memo1.Lines.Add(str);

    fn:=pathPreview+FileListBox1.Items.Strings[kf];
    fn:=copy(fn,1,length(fn)-4)+'_upd.csv';
    memo1.Lines.Add(fn);
    AssignFile(fo,concat(fn));
    Rewrite(fo);
    writeln(fo,'cruise#'+','+'platform_id'+','+str);


{.....first line analysis on commas}
    col:=0;
    buf:='';
{s}for i:=1 to length(str) do begin
    if ord(str[i])<>44 then buf:=buf+str[i]
    else begin
      col:=col+1;
      col_arr[col]:=buf;
      buf:='';
    end;
{s}end;
    col:=col+1;
    col_arr[col]:=buf;

{i}for i:=1 to col do begin
    memo1.Lines.Add(col_arr[i]);
{i}end;
{.....first line}



{.....variables in file}
    vc:=0; //number of variables in the file
{i}for i:=9 to col do begin
    vc:=vc+1;
    SetLength(StVar,vc);
    NameICES:=trim(copy(col_arr[i],1,4));
    UnitICES:=trim(copy(col_arr[i],5,length(col_arr[i])));
    StVar[vc-1].NameICES:=NameICES;
    StVar[vc-1].UnitICES:=UnitICES;
    {TEMP [deg C]}
    if NameICES='TEMP' then StVar[vc-1].Table:='P_TEMPERATURE';
    if UnitICES='[deg C]' then StVar[vc-1].UnitID:=1; // Degree centigrade
    {PSAL [psu]}
    if NameICES='PSAL' then StVar[vc-1].Table:='P_SALINITY';
    if UnitICES='[psu]' then StVar[vc-1].UnitID:=28; //practical salinity unit
    {ALKY [meq/l]}
    if NameICES='ALKY' then StVar[vc-1].Table:='P_ALKALINITY';
    if UnitICES='[meq/l]' then StVar[vc-1].UnitID:=5; //Milli-equivalent per liter
    {AMON [umol/l]}
    if NameICES='AMON' then StVar[vc-1].Table:='P_AMMONIUM';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {CPHL [ug/l]}
    if NameICES='CPHL' then StVar[vc-1].Table:='P_CHLOROPHYLL';
    if UnitICES='[ug/l]' then StVar[vc-1].UnitID:=4; //Micro-gram per liter
    {DOXY [ml/l]}
    if NameICES='DOXY' then StVar[vc-1].Table:='P_OXYGEN';
    if UnitICES='[ml/l]' then StVar[vc-1].UnitID:=21; //Milliliter per liter
    {H2SX [umol/l]}
    if NameICES='H2SX' then StVar[vc-1].Table:='P_H2S';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {NTOT [umol/l]}
    if NameICES='NTOT' then StVar[vc-1].Table:='P_TDN'; //Total dissolved nitrogen
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {NTRA [umol/l]}
    if NameICES='NTRA' then StVar[vc-1].Table:='P_NITRATE';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {NTRI [umol/l]}
    if NameICES='NTRI' then StVar[vc-1].Table:='P_NITRITE';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {PHPH []}
    if NameICES='PHPH' then StVar[vc-1].Table:='P_PH';
    if UnitICES='[]' then StVar[vc-1].UnitID:=2; //Dimensionless or unit less
    {SLCA [umol/l]}
    if NameICES='SLCA' then StVar[vc-1].Table:='P_SILICATE';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {TPHS [umol/l]}
    if NameICES='TPHS' then StVar[vc-1].Table:='P_TOTALPHOSPHORUS';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
{i}end;
    memo1.Lines.Add('');
    memo1.Lines.Add('...variables ');
    memo1.Lines.Add('NameICES'+#9+'UnitICES'+#9+'Database Table'+#9+'Database units_id ');
for i:=0 to High(StVar) do
    memo1.Lines.Add(StVar[i].NameICES
    +#9+StVar[i].UnitICES
    +#9+StVar[i].Table
    +#9+inttostr(StVar[i].UnitID));
    memo1.Lines.Add('variables# in the file:'+inttostr(Length(StVar)));
{.....variables}



{.....ShipCode - unique nodc_codes in file}
    cl:=0; //count lines
    scc:=1; //ship code count
    SetLength(ShipCode,scc);
{L}while not EOF(fi) do begin
    readln(fi,str);
    cl:=cl+1;
    {lines analysis on commes}
    col:=0;
    buf:='';
{s}for i:=1 to length(str) do begin
    if ord(str[i])<>44 then buf:=buf+str[i]
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
    st_date:=col_arr[4];
    st_lat:=col_arr[5];
    st_lon:=col_arr[6];
    st_bd:=col_arr[7];

    {date: yyyy-mm-ddThh:mm}
    y:=strtoint(copy(st_date,1,4));
    m:=strtoint(copy(st_date,6,2));
    d:=strtoint(copy(st_date,9,2));
    hh:=strtoint(copy(st_date,12,2));
    mm:=strtoint(copy(st_date,15,2));
    stDT:=EncodeDateTime(y,m,d,hh,mm,0,0);

    {stations dates}
    SetLength(StDate,cl);
    StDate[cl-1]:=stDT;
    {   cruise_id:=20000000;
    with frmdm.q1 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select cruise.id from CRUISE,PLATFORM ');
       SQL.Add(' where platform.id=cruise.platform_id ');
       SQL.Add(' and nodc_code=:nodc_code ');
       SQL.Add(' and date_start_total<=:st_dt and date_end_total>=:st_dt ');
       ParamByName('nodc_code').AsString:=nodc_code;
       ParamByName('st_dt').AsDateTime:=st_DT;
       Open;
       cruise_id:=FieldByName('id').AsInteger;
       Close;
     end;
    writeln(fo,inttostr(cruise_id)+#9+nodc_code+#9+st_num+#9+datetimetostr(st_DT));}
    {unique ship codes}
    if cl=1 then ShipCode[scc-1].nodc_code:=nodc_code;
    shc_new:=true;
    for i:=0 to High(ShipCode) do if ShipCode[i].nodc_code=nodc_code then shc_new:=false;
    if shc_new=true then begin
     scc:=scc+1;
     SetLength(ShipCode,scc);
     ShipCode[scc-1].nodc_code:=nodc_code;
    end;
{L}end;
    closefile(fi);
    //closefile(fo);
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
    memo1.Lines.Add('');
    memo1.Lines.Add('...platforms');
    memo1.Lines.Add('#'+#9+'nodc_code'+#9+'lines#'+#9+'name'+#9+'name_ICES'+#9+'name_WOD'+#9+'name_NATIVE');
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
     memo1.Lines.Add(inttostr(i)
     +#9+nodc_code
     +#9+inttostr(ShipCode[i].count) //lines# in file
     +#9+name_PLATFORM
     +#9+name_ICES
     +#9+name_WOD
     +#9+name_NATIVE);
{SC}end;
{.....ShipCode}



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
     CruiseLine[cc-1]:=i+4;
     memo1.Lines.Add('');
     memo1.Lines.Add('cruises# in file='+inttostr(High(CruiseLine)));
     memo1.Lines.Add('cruise#'+#9+'line#');
     for i:=0 to High(CruiseLine) do memo1.Lines.Add(inttostr(i)+#9+inttostr(CruiseLine[i]));
{.....CruiseLine}



{.....output cruises}
    label1.Visible:=true;
{C}for i:=0 to High(CruiseLine)-1 do begin
    crn:=i+1; //cruise number in file
    label1.Caption:='cruise: '+inttostr(crn);
    Application.ProcessMessages;
    L1:=CruiseLine[i];
    L2:=CruiseLine[i+1];
    reset(fi);
    readln(fi,str_header);
    cl:=1;
{L}while not EOF(fi) do begin
    readln(fi,str);
    cl:=cl+1;
    {cruise line range in file}
{CL}if (cl>=L1) and (cl<L2) then begin
{L1}if cl=L1 then begin
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

       crns:='000'+inttostr(crn);
       if crn>=10 then crns:='00'+inttostr(crn);
       if crn>=100 then crns:='0'+inttostr(crn);
       if crn>=1000 then crns:=inttostr(crn);

       fn:=pathCR+crns+'_'+instrument+'_'+name_PLATFORM+'.csv';
       memo1.Lines.Add(fn);
       AssignFile(fo1,concat(fn));
       Rewrite(fo1);
       writeln(fo1,str_header);
{L1}end;

       writeln(fo,inttostr(crn),',', inttostr(platform_id),',',str);
       writeln(fo1,str);
{CL}end;
{L}end;
    closefile(fi);
    closefile(fo1);

{C}end;
    closefile(fo);
{.....output}

     memo1.Lines.Add('');
     memo1.Lines.Add('lines# with data: '+inttostr(cl));

{F}end;

     memo1.Lines.Add('');
     DT2:=NOW;
     memo1.Lines.Add('...stop: '+datetimetostr(DT2));
     memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
     FileListBox3.Directory:=pathCR;
     FileListBox3.UpdateFileList;
     Application.ProcessMessages;

end;



procedure Tfrmload_ices1.btnDownloadDataClick(Sender: TObject);
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
i,j,col,kf,ks,L1,L2,clev,mik :integer;
cl,cs,vc,stations_database,bd,StVersion,CountDup :integer;
y,m,d,hh,mm :word;
lat,lon,lat_min,lon_min,lat_max,lon_max,lev_m,lev_dbar: real;
last_lev_dbar,last_lev_m :real;
str,buf,name_PLATFORM,tbl :string;
nameICES,unitICES :string;
st_num,st_type,st_date,st_lat,st_lon,st_bd,st1,st2,st_lev_dbar :string;
nodc_code :string[4];
col_arr :array[1..100] of string;
st_DT,dsdb_DT,dedb_DT :TDateTime;
Func:Tgsw_z_from_p;

begin

DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));

    source_id:=4; //ICES
    cruise_id:=15000000;
    station_id:=15000000;
    label1.Caption:='cruise:'+inttostr(cruise_id);
    Label1.Visible:=true;
    Application.ProcessMessages;
{F}for kf:=0 to FileListBox3.Items.Count-1 do begin
//{F}for kf:=0 to 2 do begin

    cruise_id:=cruise_id+1;
    label1.Caption:='cruise:'+inttostr(cruise_id);
    Application.ProcessMessages;

    if CheckBox1.Checked then memo1.Lines.Add('');
    fn:=pathCR+FileListBox3.Items.Strings[kf];
    memo1.Lines.Add(fn);
    AssignFile(fi,concat(fn));

{step 1: StVar    - create array with variable sequence, composition, units and DB tables }
    Reset(fi);
    readln(fi,str);

    cl:=1; //count lines
{.....first line - header}
    col:=0;
    buf:='';
{s}for i:=1 to length(str) do begin
    if ord(str[i])<>44 then buf:=buf+str[i]
    else begin
      col:=col+1;
      col_arr[col]:=buf;
      buf:='';
    end;
{s}end;
    col:=col+1;
    col_arr[col]:=buf;
{.....StVar - variables in file}
    vc:=0; //number of variables in the file
{i}for i:=9 to col do begin
    vc:=vc+1;
    SetLength(StVar,vc);
    NameICES:=trim(copy(col_arr[i],1,4));
    UnitICES:=trim(copy(col_arr[i],5,length(col_arr[i])));
    StVar[vc-1].NameICES:=NameICES;
    StVar[vc-1].UnitICES:=UnitICES;
    {TEMP [deg C]}
    if NameICES='TEMP' then StVar[vc-1].Table:='P_TEMPERATURE';
    if UnitICES='[deg C]' then StVar[vc-1].UnitID:=1; // Degree centigrade
    {PSAL [psu]}
    if NameICES='PSAL' then StVar[vc-1].Table:='P_SALINITY';
    if UnitICES='[psu]' then StVar[vc-1].UnitID:=28; //practical salinity unit
    {ALKY [meq/l]}
    if NameICES='ALKY' then StVar[vc-1].Table:='P_ALKALINITY';
    if UnitICES='[meq/l]' then StVar[vc-1].UnitID:=5; //Milli-equivalent per liter
    {AMON [umol/l]}
    if NameICES='AMON' then StVar[vc-1].Table:='P_AMMONIUM';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {CPHL [ug/l]}
    if NameICES='CPHL' then StVar[vc-1].Table:='P_CHLOROPHYLL';
    if UnitICES='[ug/l]' then StVar[vc-1].UnitID:=4; //Micro-gram per liter
    {DOXY [ml/l]}
    if NameICES='DOXY' then StVar[vc-1].Table:='P_OXYGEN';
    if UnitICES='[ml/l]' then StVar[vc-1].UnitID:=21; //Milliliter per liter
    {H2SX [umol/l]}
    if NameICES='H2SX' then StVar[vc-1].Table:='P_H2S';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {NTOT [umol/l]}
    if NameICES='NTOT' then StVar[vc-1].Table:='P_TDN'; //Total dissolved nitrogen
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {NTRA [umol/l]}
    if NameICES='NTRA' then StVar[vc-1].Table:='P_NITRATE';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {NTRI [umol/l]}
    if NameICES='NTRI' then StVar[vc-1].Table:='P_NITRITE';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {PHOS [umol/l]}
    if NameICES='PHOS' then StVar[vc-1].Table:='P_PHOSPHATE';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Dimensionless or unit less
    {PHPH []}
    if NameICES='PHPH' then StVar[vc-1].Table:='P_PH';
    if UnitICES='[]' then StVar[vc-1].UnitID:=2; //Dimensionless or unit less
    {SLCA [umol/l]}
    if NameICES='SLCA' then StVar[vc-1].Table:='P_SILICATE';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
    {TPHS [umol/l]}
    if NameICES='TPHS' then StVar[vc-1].Table:='P_TOTALPHOSPHORUS';
    if UnitICES='[umol/l]' then StVar[vc-1].UnitID:=15; //Micro-mole per liter
{i}end;
    closefile(fi);
    if CheckBox1.Checked then begin
    memo1.Lines.Add('...step 1 variables ');
    memo1.Lines.Add('NameICES'+#9+'UnitICES'+#9+'Database Table'+#9+'Database units_id ');
for i:=0 to High(StVar) do
    memo1.Lines.Add(StVar[i].NameICES
    +#9+StVar[i].UnitICES
    +#9+StVar[i].Table
    +#9+inttostr(StVar[i].UnitID));
    memo1.Lines.Add('variables# in the file:'+inttostr(Length(StVar)));
    end;
{.....step 1}


{step 2: StNumber - create array with station numbers in file }
    Reset(fi);
    readln(fi,str);
    cl:=0;
{L}while not EOF(fi) do begin
    readln(fi,str);
    cl:=cl+1;

    col:=0;
    buf:='';
{s}for i:=1 to length(str) do begin
    if ord(str[i])<>44 then buf:=buf+str[i]
    else begin
      col:=col+1;
      col_arr[col]:=buf;
      buf:='';
    end;
{s}end;
    col:=col+1;
    col_arr[col]:=buf;

    nodc_code:=trim(col_arr[1]);
    st_num:=trim(col_arr[2]);
    st_type:=col_arr[3];
    st_date:=col_arr[4];
    st_lat:=col_arr[5];
    st_lon:=col_arr[6];
    st_bd:=col_arr[7];

    {date: yyyy-mm-ddThh:mm}
    y:=strtoint(copy(st_date,1,4));
    m:=strtoint(copy(st_date,6,2));
    d:=strtoint(copy(st_date,9,2));
    hh:=strtoint(copy(st_date,12,2));
    mm:=strtoint(copy(st_date,15,2));
    st_DT:=EncodeDateTime(y,m,d,hh,mm,0,0);

    {position}
    lat:=strtofloat(st_lat);
    lon:=strtofloat(st_lon);

    {cruise  metadata}
    if cl=2 then begin
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
    end
    else begin
    if dsdb_DT>st_DT then dsdb_DT:=st_DT;
    if dedb_DT<st_DT then dedb_DT:=st_DT;
    if lat_min>lat then lat_min:=lat;
    if lat_max<lat then lat_max:=lat;
    if lon_min>lon then lon_min:=lon;
    if lon_max<lon then lon_max:=lon;
    end;
    SetLength(StNumber,cl);
    StNumber[cl-1]:=trim(st_num);  //starts in line 2
{L}end;
    closefile(fi);
    if CheckBox1.Checked then begin
    memo1.Lines.Add('...step 2: Elements in StNumber array='+inttostr(Length(StNumber)));
    //for i:=0 to High(StNumber) do memo1.Lines.Add(inttostr(i)+#9+StNumber[i]);
    end;
{.....step 2}



{step 3: StLine -create array with stations position in file}
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



{step 4: populate CRUISE}
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
    );
   end;

   if CheckBox2.Checked then begin
   with frmdm.q1 do begin
    Close;
     SQL.Clear;
     SQL.Add('insert into CRUISE');
     //SQL.Add('insert into CRUISE');
     SQL.Add(' (ID, platform_id, source_id, institute_id, project_id, expocode, ');
     SQL.Add(' DATE_ADDED, DATE_UPDATED, DATE_START_TOTAL, DATE_END_TOTAL,  ');
     SQL.Add(' DATE_START_DATABASE, DATE_END_DATABASE, CRUISE_NUMBER,');
     SQL.Add(' LATITUDE_MIN, LATITUDE_MAX, LONGITUDE_MIN, LONGITUDE_MAX,');
     SQL.Add(' STATIONS_TOTAL, STATIONS_DATABASE, STATIONS_DUPLICATES) ');
     SQL.Add(' VALUES ' );
     SQL.Add(' (:ID, :platform_id, :source_id, :institute_id, :project_id, :expocode, ');
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
     ParamByName('date_start_total').Value:=now;
     ParamByName('date_end_total').Value:=now;
     ParamByName('date_start_database').Value:=dsdb_DT;
     ParamByName('date_end_database').Value:=dedb_DT;
     //ParamByName('cruise_number').Value:=ITP_ID;
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



{step 5: split cruise to stations, populate STATION}
{58VG,0143,B,1931-07-17T08:00,66.97,2.43,,0,10.37,34.661,,,,,,,,,,,,}
    if CheckBox1.Checked then memo1.Lines.Add('...step 5');
    //SetLength(Station,0,0);
{ST}for ks:=0 to High(StLine)-1 do begin

    SetLength(Station,0,0);
    station_id:=station_id+1;
    L1:=StLine[ks];
    L2:=StLine[ks+1]-1;

    SetLength(Station,L2-L1+1,High(StVar)+2);
    for i:=0 to High(Station) do begin
    for j:=0 to High(StVar)+2 do begin
     Station[i,j]:=-9999;
    end;
    end;

    Reset(fi);
    readln(fi,str);
    cl:=1;   //count lines
    clev:=0; //count levels
{L}while not EOF(fi) do begin
    readln(fi,str);
    cl:=cl+1;

{L1->L2}if (cl>=L1) and (cl<=L2) then begin
    clev:=clev+1;
    col:=0;
    buf:='';
{s}for i:=1 to length(str) do begin
    if ord(str[i])<>44 then buf:=buf+str[i]
    else begin
      col:=col+1;
      col_arr[col]:=buf;
      buf:='';
    end;
{s}end;
    col:=col+1;
    col_arr[col]:=buf;

    st_lev_dbar:=col_arr[8];
    lev_dbar:=strtofloat(st_lev_dbar);
    Func:=Tgsw_z_from_p(GetProcedureAddress(libgswteos, 'gsw_z_from_p'));
    lev_m:=-Func(lev_dbar, lat, 0, 0);

    Station[clev-1,0]:=lev_dbar;
    Station[clev-1,1]:=lev_m;

{i}for i:=9 to col do begin
     if col_arr[i]<>'' then Station[clev-1,i-7]:=strtofloat(col_arr[i])
                       else Station[clev-1,i-7]:=-9999;
{i}end;

    {...station metadata}
{m}if cl=L1 then begin
    nodc_code:=trim(col_arr[1]);
    st_num:=trim(col_arr[2]);
    st_type:=trim(col_arr[3]);
    st_date:=col_arr[4];
    st_lat:=col_arr[5];
    st_lon:=col_arr[6];
    st_bd:=col_arr[7];
    {instrument_id}
    if UpperCase(st_type)='B' then instrument_id:=7;
    if UpperCase(st_type)='C' then instrument_id:=4;
    {date: yyyy-mm-ddThh:mm}
    y:=strtoint(copy(st_date,1,4));
    m:=strtoint(copy(st_date,6,2));
    d:=strtoint(copy(st_date,9,2));
    hh:=strtoint(copy(st_date,12,2));
    mm:=strtoint(copy(st_date,15,2));
    st_DT:=EncodeDateTime(y,m,d,hh,mm,0,0);
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

{L1->L2}end
{L}end;
   closefile(fi);

    StVersion:=0;
   with frmdm.q1 do begin
    Close;
    SQL.Clear;
    SQL.Add(' Select count(ID) as CountDup from STATION ');
    SQL.Add(' where dateandtime=:st_DT and ');
    SQL.Add(' latitude=:lat and longitude=:lon and cast_number=:cast_number ');
    ParamByName('st_DT').AsDateTime:=st_DT;
    ParamByName('lat' ).Asfloat:=lat;
    ParamByName('lon' ).AsFloat:=lon;
    ParamByName('cast_number').AsInteger:=1;
    Open;
    CountDup:=FieldByName('CountDup').AsInteger;
    Close;
   end;
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

//{ST}end;

{...STATION array}

{for i:=0 to High(Station) do begin
 str:='';
for j:=0 to High(StVar)+2 do begin str:=str+floattostrF(Station[i,j],ffFixed,9,3)+' '; end;
 memo1.Lines.Add(str);
end;}

{...tables with data}
{var}for j:=0 to High(StVar) do begin

     mik:=0;
     for i:=0 to High(Station) do
     if Station[i,j+2]<>-9999 then mik:=mik+1;

{prf}if mik>0 then begin
      tbl:=StVar[j].Table;
      units_id:=StVar[j].UnitID;
      memo1.Lines.Add(StVar[j].Table+'->'+inttostr(mik));
{lev}for i:=0 to High(Station) do begin

{out}if Station[i,j+2]<>-9999 then begin
     //memo1.Lines.Add(floattostrF(Station[i,0],ffFixed,9,1)
     //+#9+floattostrF(Station[i,1],ffFixed,9,1)
     //+#9+floattostrF(Station[i,j+2],ffFixed,9,3));

{populate P_tables}

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
  ParamByName('VAL').AsFloat:=Station[i,j+2];
  ParamByName('PQF1').AsInteger:=0;
  ParamByName('PQF2').AsInteger:=0;
  ParamByName('SQF').AsInteger:=0;
  ParamByName('UNITS_ID').AsInteger:=units_id;
  ParamByName('INSTRUMENT_ID').AsInteger:=instrument_id;
  ParamByName('PROFILE_NUMBER').AsInteger:=1;
  ParamByName('PROFILE_BEST').AsBoolean:=true;
 ExecSQL;
end;
{out}end;
{lev}end;
   if CheckBox2.Checked then
   frmdm.TR.CommitRetaining;
{prf}end;

{var}end;

{ST}end;
{.....step 5}


    //closefile(fi);
{F}end;

DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;



procedure Tfrmload_ices1.btnCleanCruiseNameClick(Sender: TObject);
var
cc,sc,i :integer;
str,str_new :string;
begin

    fn:=pathCSR+FileListBox2.Items.Strings[0];
    AssignFile(fi,concat(fn));
    Reset(fi);
    memo1.Lines.Add(fn);
    readln(fi,str);
    memo1.Lines.Add(str);

    fn:=copy(fn,1,length(fn)-4)+'_ed.csv';
    memo1.Lines.Add(fn);
    AssignFile(fo,concat(fn));
    Rewrite(fo);
    writeln(fo,str);

     cc:=0; //cruise_count
{CR}while not EOF(fi) do begin
     readln(fi,str);
     cc:=cc+1;

     sc:=0; //symbol count
     str_new:='';
{i}for  i:=1 to length(str) do begin
     {.....ASCII codes:  tab:9  ',':44  '"':34}
     if ord(str[i])=34 then sc:=sc+1;
     if (sc<>1) and (sc<>3) then str_new:=str_new+str[i];
     if (sc=1) and (ord(str[i])<>44) then str_new:=str_new+str[i];
     if (sc=1) and (ord(str[i])=44)  then str_new:=str_new+';'; //replace the comma with a semicolon
     if (sc=3) and (ord(str[i])<>44) then str_new:=str_new+str[i];
     if (sc=3) and (ord(str[i])=44)  then str_new:=str_new+';'; //replace the comma with a semicolon
{i}end;
     writeln(fo,str_new);
{CR}end;

    memo1.Lines.Add('cruise_count='+inttostr(cc));
    closefile(fi);
    closefile(fo);

end;

procedure Tfrmload_ices1.btnCleanDateClick(Sender: TObject);
var
cc,col,i,err_count :integer;
str,buf,cs,ce :string;
col_arr :array[1..100] of string;
date_err :boolean;
begin
    fn:=pathCSR+FileListBox2.Items.Strings[0];
    AssignFile(fi,concat(fn));
    Reset(fi);
    memo1.Lines.Add(fn);
    readln(fi,str);
    memo1.Lines.Add(str);

    fn:=copy(fn,1,length(fn)-4)+'_dates.csv';
    memo1.Lines.Add(fn);
    AssignFile(fo,concat(fn));
    Rewrite(fo);
    writeln(fo,str);

     cc:=0; //cruise_count
     err_count:=0; //cruise count where 'T' found in dates
{CR}while not EOF(fi) do begin
     readln(fi,str);
     cc:=cc+1;

     col:=0;
     buf:='';
 {s}for i:=1 to length(str)-1 do begin   //skip the last comma
     if ord(str[i])<>44 then buf:=buf+str[i]
     else begin
       col:=col+1;
       col_arr[col]:=buf;
       buf:='';
     end;
 {s}end;
     col:=col+1;
     col_arr[col]:=buf;

     cs:=col_arr[3]; //cruise start
     ce:=col_arr[4]; //cruise end
     date_err:=false;
    for i:=1 to length(cs) do if cs[i]='T' then date_err:=true;
    for i:=1 to length(ce) do if ce[i]='T' then date_err:=true;

    if date_err=false then writeln(fo,str)
    else begin
     err_count:=err_count+1;
     memo1.Lines.Add(inttostr(err_count)+#9+str);
    end;

{CR}end;

    memo1.Lines.Add('cruise_count ='+inttostr(cc));
    memo1.Lines.Add('date er_count='+inttostr(err_count));
    closefile(fi);
    closefile(fo);

end;




procedure Tfrmload_ices1.btnPopuateCruiseTableClick(Sender: TObject);
var
cruise_id :integer;
i,col,cc,platform_id,country_id,unknown_count,no_code_count :integer;
prf_max,st_max,mtc,col_CTD,col_BTL,prf_CTD,prf_BTL :integer;
y,m,d :word;
str,notes_str,buf,mtcs: string;
platform,cruise,cruise_CSRRef,cruise_ICESRef: string;
col_arr :array[1..100] of string;
cruise_start,cruise_end :TDateTime;
skip_cruise :boolean;
begin

DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));

  {https://ocean.ices.dk/csr/}
  {ex. CSR first line}
  {Platform Name,Cruise Name,Start Date,End Date,CSRREF,ICESREF,B01,B02,B07,
  B09,B71,B72,H09,H10,H17,H22,H24,H26,H27,H32,H71,H74,H76,H90}

  {ex. cruises}
  {"Silas Bent","343716","T","T","19776148","","","","","","","","","","","","","","","","","","","",}
  {"Scotia","1118S ","2018-07-28","2018-08-17","0","201874017","","","","","","","","","","","","","","","","","","",}
  {"","TR_ROSSMA","2018-03-06","2018-03-06","20185337","","","","","","","","","","","","","","","","","","","",}
  {"G.O. Sars","1997902","1997-08-19","1997-09-09","19975464","199758052","","","","","","","","","","","","","","","","","","",}
  {"ARNI FRIDRIKSSON","CR A14-97 Juvenile VEINS, Task 1.4.2,1.4.3 and 1.4.4 - ref a1497","1997-08-12","1997-09-05","0","199746020","","","","","","","","","","","","","","","","","","",}

  fn:=pathCSR+FileListBox2.Items.Strings[0];
  AssignFile(fi,concat(fn));
  Reset(fi);
  memo1.Lines.Add(fn);
  readln(fi,str);
  memo1.Lines.Add(str);

  fn:=copy(fn,1,length(fn)-4)+'_CRUISE.txt';
  memo1.Lines.Add(fn);
  AssignFile(fo,concat(fn));
  Rewrite(fo);
  writeln(fo,str);

  fn:=copy(fn,1,length(fn)-4)+'_unknown_platforms.txt';
  memo1.Lines.Add(fn);
  AssignFile(fo1,concat(fn));
  Rewrite(fo1);
  writeln(fo1,str);

    {...title}
    {.....ASCII codes:  tab:9  ',':44  '"':34}
    col:=0;
    buf:='';

{s}for i:=1 to length(str) do begin
    if ord(str[i])<>44 then buf:=buf+str[i]
    else begin
      col:=col+1;
      col_arr[col]:=buf;
      buf:='';
    end;
{s}end;
    col:=col+1;
    col_arr[col]:=buf;
{i}for i:=1 to col do begin
    memo1.Lines.Add(col_arr[i]);
    if col_arr[i]='H09' then col_CTD:=i;
    if col_arr[i]='H10' then col_BTL:=i;
{i}end;

    memo1.Lines.Add('');
    memo1.Lines.Add('cruise_id'+#9+'platform_id'+#9+'country_id'
    +#9+'platform'+#9+'cruise'+#9+'start'+#9+'end'+#9+'CSRREF'+#9+'ICESREF'+#9+'stations#');
    cc:=0; //cruise_count
    unknown_count:=0; //unknown platforms
    no_code_count:=0; //platform code not found
    label1.Caption:='CSR cruise: '+inttostr(cc);
    label1.Visible:=true;
    Application.ProcessMessages;
{CR}while not EOF(fi) do begin
    readln(fi,str);
    cc:=cc+1;
    label1.Caption:='CSR cruise: '+inttostr(cc);
    Application.ProcessMessages;

    col:=0;
    buf:='';
{s}for i:=1 to length(str)-1 do begin   //skip the last comma
    if ord(str[i])<>44 then buf:=buf+str[i]
    else begin
      col:=col+1;
      col_arr[col]:=buf;
      buf:='';
    end;
{s}end;
    col:=col+1;
    col_arr[col]:=buf;

    platform:=trim(col_arr[1]);  //showmessage('platform:'+platform);
    skip_cruise:=false;

    //if UpperCase(copy(platform,2,6))='UNKNOW' then showmessage(UpperCase(copy(platform,2,6)));
    if copy(platform,1,2)='""' then skip_cruise:=true;
    if UpperCase(copy(platform,2,6))='UNKNOW' then skip_cruise:=true;
    if UpperCase(copy(platform,2,11))='UNSPECIFIED' then skip_cruise:=true;
    if UpperCase(copy(platform,2,8))='UNMANNED' then skip_cruise:=true;

    {...platforms}
{UNKNOWN}if skip_cruise=true then begin
           unknown_count:=unknown_count+1;
           writeln(fo1,str);
{UNKNOWN}end;

{KNOWN}if skip_cruise=false then begin
    cruise:=trim(col_arr[2]);
    platform:=copy(platform,2,(length(platform)-2));
    cruise:=copy(cruise,2,(length(cruise)-2));

    cruise_CSRRef :=copy(col_arr[5],2,(length(col_arr[5])-2));
    cruise_ICESRef:=copy(col_arr[6],2,(length(col_arr[6])-2));

    {"2018-07-28"}
    cruise_start:=encodedate(2100,1,1);
    if length(col_arr[3])=12 then begin
    y:=strtoint(copy(col_arr[3],2,4));
    m:=strtoint(copy(col_arr[3],7,2));
    d:=strtoint(copy(col_arr[3],10,2));
    cruise_start:=encodedate(y,m,d);
    end
    else begin
           memo1.Lines.Add('...wrong start time:'+col_arr[3]+'  row#:'+inttostr(cc));
           memo1.Lines.Add(str);
         end;
    {"2018-07-28"}
    cruise_end:=encodedate(2100,1,1);
    if length(col_arr[4])=12 then begin
    y:=strtoint(copy(col_arr[4],2,4));
    m:=strtoint(copy(col_arr[4],7,2));
    d:=strtoint(copy(col_arr[4],10,2));
    cruise_end:=encodedate(y,m,d);
    end
    else begin
           memo1.Lines.Add('...wrong end time:'+col_arr[4]+'  row#:'+inttostr(cc));
           memo1.Lines.Add(str);
         end;

      prf_max:=0; //maximun of profiles among all reported instrument types
      st_max:=0; //stations number as maximum among bottle and ctd profiles
{st}for i:=7 to col do begin
     mtcs:=col_arr[i]; //measurement type count string
     if mtcs<>'""' then mtcs:=trim(copy(mtcs,2,length(mtcs)-2)) else mtcs:='0';
     //if (mtcs<>'0') then memo1.Lines.Add(mtcs+'('+inttostr(i)+')');
     mtc:=strtoint(mtcs);
     if mtc>prf_max then prf_max:=mtc;

     if i=col_CTD then prf_CTD:=mtc;
     if i=col_BTL then prf_BTL:=mtc;

     //if prf_CTD>=prf_BTL then st_max:=prf_CTD else st_max:=prf_BTL;
     st_max:=prf_CTD+prf_BTL;

{st}end;

      {platform unknown and country unknown}
      platform_id:=18695;
      country_id:=488;
    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select id, country_id from PLATFORM ');
      SQL.Add(' where name_ices=:name_ices or name_ices=:name_ices_uc ');
      SQL.Add(' or name=:name_ices_uc or name_native=:name_ices_uc' );
      SQL.Add(' or name_wod=:name_ices_uc' );
      ParamByName('name_ices').AsString:=trim(copy(platform,1,50));
      ParamByName('name_ices_uc').AsString:=UpperCase(trim(copy(platform,1,50)));
      Open;
      platform_id:=FieldByName('id').AsInteger;
      country_id:=FieldByName('country_id').AsInteger;
    end;


     cruise_id:=15000000+cc;  //ICES range in OCEAN.fdb 50000001-60000000

{NotIdentified}if platform_id=0 then begin
                 no_code_count:=no_code_count+1;
                 writeln(fo1,str);
{NotIdentified}end;

{out}if platform_id<>0 then begin
    if CheckBox1.Checked then
    memo1.Lines.Add(inttostr(cruise_id)
    +#9+inttostr(platform_id)
    +#9+inttostr(country_id)
    +#9+platform
    +#9+cruise
    +#9+datetostr(cruise_start)
    +#9+datetostr(cruise_end)
    +#9+cruise_CSRRef
    +#9+cruise_ICESRef
    //+#9+inttostr(prf_max)
    //+#9+inttostr(prf_CTD)
    //+#9+inttostr(prf_BTL)
    +#9+inttostr(st_max) //sum of bottle and CTD
    );

    writeln(fo,inttostr(cruise_id)
    +#9+inttostr(platform_id)
    +#9+inttostr(country_id)
    +#9+platform
    +#9+cruise
    +#9+datetostr(cruise_start)
    +#9+datetostr(cruise_end)
    +#9+cruise_CSRRef
    +#9+cruise_ICESRef
    +#9+inttostr(st_max) //sum of bottle and CTD
    );

    notes_str:='CSRRef:'+cruise_CSRRef+';'+'   ICESRef:'+cruise_ICESRef+';'+'  cruise:'+cruise+';';

{DB}if CheckBox2.Checked then begin
    with frmdm.Q2 do begin
     Close;
      SQL.Clear;
      SQL.Add('insert into CRUISE_CSR');
      SQL.Add(' (ID, platform_id, source_id, institute_id, project_id, ');
      SQL.Add('  expocode, cruise_number, notes, ');
      SQL.Add(' DATE_ADDED, DATE_UPDATED, DATE_START_TOTAL, DATE_END_TOTAL, ');
      SQL.Add(' DATE_START_DATABASE, DATE_END_DATABASE, ');
      SQL.Add(' STATIONS_TOTAL, STATIONS_DATABASE, STATIONS_DUPLICATES) ');
      SQL.Add(' VALUES ' );
      SQL.Add(' (:ID, :platform_id, :source_id, :institute_id, :project_id, ');
      SQL.Add('  :expocode, :cruise_number, :notes, ');
      SQL.Add(' :DATE_ADDED, :DATE_UPDATED, :DATE_START_TOTAL, :DATE_END_TOTAL, ');
      SQL.Add(' :DATE_START_DATABASE, :DATE_END_DATABASE, ');
      SQL.Add(' :STATIONS_TOTAL, :STATIONS_DATABASE, :STATIONS_DUPLICATES) ');
      ParamByName('ID').Value:=cruise_id;
      ParamByName('platform_id').Value:=platform_id;
      ParamByName('source_id').Value:=4;
      ParamByName('institute_id').Value:=1;
      ParamByName('expocode').Value:=cruise_ICESRef;
      ParamByName('project_id').Value:=0;
      ParamByName('cruise_number').Value:=trim(copy(cruise,1,100));
      ParamByName('date_added').Value:=now;
      ParamByName('date_updated').Value:=now;
      ParamByName('date_start_total').Value:=cruise_start;
      ParamByName('date_end_total').Value:=cruise_end;
      ParamByName('date_start_database').Value:=cruise_start;
      ParamByName('date_end_database').Value:=cruise_end;
      ParamByName('notes').Value:=notes_str;
      ParamByName('stations_total').Value:=st_max;
      ParamByName('stations_database').Value:=0;
      ParamByName('stations_duplicates').Value:=0;
     ExecSQL;
    end;

    frmdm.TR.CommitRetaining;

{DB}end;

{out}end;

{KNOWN}end;
{CR}end;
    memo1.Lines.Add('cruise_  count    ='+inttostr(cc));
    memo1.Lines.Add('unknown cruise    ='+inttostr(unknown_count));
    memo1.Lines.Add('code was not found='+inttostr(no_code_count));
    closefile(fi);
    closefile(fo);
    closefile(fo1);

memo1.Lines.Add('');
DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;


procedure Tfrmload_ices1.btnMarkThinnedCTDClick(Sender: TObject);
var
mik,cdup: integer;
station_id,cruise_id,platform_id :integer;
platform_name,expocode,st_number_origin :string;
st_DT :TDateTime;
begin

DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));

with frmdm.q1 do begin
  Close;
  SQL.Clear;
  SQL.Add(' select dateandtime from STATION ');
  SQL.Add(' where stversion>0 ');
  SQL.Add(' order by dateandtime ');
  Open;
end;

memo1.Lines.Add('datatime');
memo1.Lines.Add('cruise_id'+#9+'station_id'+#9+'platform_id'
+#9+'st_number_origin'+#9+'platform_name'+#9+'expocode');

       mik:=0;
       cdup:=0; //count ctd duplicates
{stv}while not frmdm.q1.EOF do begin
      inc(mik);
      st_DT:=frmdm.q1.FieldByName('dateandtime').AsDateTime;
      memo1.Lines.Add('');
      memo1.Lines.Add(inttostr(mik)+#9+datetimetostr(st_DT));

      with frmdm.q2 do begin
        Close;
        SQL.Clear;
        SQL.Add(' select id,st_number_origin,cruise_id ');
        SQL.Add(' from STATION ');
        SQL.Add(' where dateandtime=:st_DT ');
        ParamByName('st_DT').AsDateTime:=st_DT;
        Open;
      end;


{cr}while not frmdm.q2.EOF do begin
     station_id:=frmdm.q2.FieldByName('id').AsInteger;
     st_number_origin:=frmdm.q2.FieldByName('st_number_origin').AsString;
     cruise_id:=frmdm.q2.FieldByName('cruise_id').AsInteger;


     with frmdm.q3 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select expocode,platform_id,name ');
       SQL.Add(' from CRUISE,PLATFORM ');
       SQL.Add(' where cruise.id=:cruise_id ');
       SQL.Add(' and platform.id=cruise.platform_id ');
       ParamByName('cruise_id').AsDateTime:=cruise_id;
       Open;
       expocode:=frmdm.q3.FieldByName('expocode').AsString;
       platform_id:=frmdm.q3.FieldByName('platform_id').AsInteger;
       platform_name:=frmdm.q3.FieldByName('name').AsString;
       Close;
     end;

{dup}if AnsiContainsStr(expocode, '_Bottle_') then begin
      inc(cdup);

      if CheckBox2.Checked then begin
      with frmdm.q3 do begin
        Close;
        SQL.Clear;
        SQL.Add(' update STATION set duplicate=true ');
        SQL.Add(' where id=:station_id ');
        ParamByName('station_id').AsInteger:=station_id;
        ExecSQL;
      end;
        frmdm.TR.CommitRetaining;
      end;

{dup}end;

     if CheckBox1.Checked then
     memo1.Lines.Add(inttostr(cruise_id)
     +#9+inttostr(station_id)
     +#9+inttostr(platform_id)
     +#9+st_number_origin
     +#9+platform_name
     +#9+expocode
     );


     frmdm.q2.Next;
{cr}end;
     frmdm.q2.Close;


      frmdm.q1.Next;
{stv}end;
      frmdm.q1.Close;

memo1.Lines.Add('');
memo1.Lines.Add('stations# marked as duplicate='+inttostr(cdup));

DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;





end.

