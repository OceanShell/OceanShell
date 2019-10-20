unit osload_GLODAP_2019_v2_product;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DateUtils,
  SQLDB, DB;

type

  { TfrmloadGLODAP_2019_v2_product }

  TfrmloadGLODAP_2019_v2_product = class(TForm)
    Button1: TButton;
    Button2: TButton;
    btnCreateTables: TButton;
    Memo1: TMemo;
    procedure btnCreateTablesClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    function DateEncode(Year,Month,Day,Hour,Minutes:word;
      Var DaysInAMonthFlag,DateChangedFlag:Boolean):TDateTime;
  public

  end;

var
  frmloadGLODAP_2019_v2_product: TfrmloadGLODAP_2019_v2_product;
  var_num,line_num:integer;
  Path, path_out:string;
  var_name:array[1..200] of string;
  Dat, out:text;

implementation

uses osmain, procedures, dm;

{$R *.lfm}

{ TfrmloadGLODAP_2019_v2_product }



procedure TfrmloadGLODAP_2019_v2_product.Button1Click(Sender: TObject);
var
  k,n,line:integer;
  symbol:char;
  st,buf_str:string;
begin
  path:='c:\Users\ako071\AK\datasets\GLODAP\GLODAPv2.2019_Merged_Master_File.csv';
  //path:='c:\Users\ako071\AK\datasets\GLODAP\cruise 1116a.csv';
  //path:='c:\Users\ako071\AK\datasets\GLODAP\cruise 1046.csv';
  memo1.Lines.Add('path='+path);

  AssignFile(dat, Path); Reset(dat);
  readln(dat, st);

  //number of variables in the first line
  if trim(st)<>'' then begin
    var_num:=0;
  for k:=1 to length(st) do begin
    symbol:=st[k];
    if symbol=',' then var_num:=var_num+1;
  end;
  end;
    var_num:=var_num+1;
    memo1.Lines.Add('var_num='+inttostr(var_num));

  //create array with variable names from the first line
    n:=0;
  for k:=1 to var_num do begin
    buf_str:='';
  repeat
    inc(n);
    symbol:=st[n];
    if (symbol<>',') then buf_str:=buf_str+symbol;
  until (symbol=',') or (symbol=#10);
    var_name[k]:=buf_str;
  end;

  //count lines
  line:=1;
  try
  repeat
    readln(dat,st);
    line:=line+1;
  until eof(dat);
  finally
    closefile(dat);
  end;
    line_num:=line;
    memo1.Lines.Add('line#='+inttostr(line));

  //CloseFile(dat);
  Button2.Visible:=true;
end;


procedure TfrmloadGLODAP_2019_v2_product.Button2Click(Sender: TObject);
var
k,kv,line,n,mik:integer;
cruiseN,stationN,castN,stNBNum:integer;
year,month,day,hour,min:integer;
stlat,stlon,stBD,stPDS:real;
buf:real;
symbol:char;
st,buf_str:string;
StDate,StTime,StDT:TDateTime;
DayChange,DateChange:Boolean;
ww:boolean; //workedwell

press,temp,salt,oxy,aou,nat,nit,sil,pho,tco2,talk,phts25p0,phtsinsitutp,cfcll:real;
salt_pQF1,oxy_pQF1,aou_pQF1,nat_pQF1,nit_pQF1,sil_pQF1,pho_pQF1,tco2_pQF1,talk_pQF1:integer;
phtsinsitutp_pQF1, phts25p0_pQF1, cfcll_pQF1: integer;
salt_sQF,oxy_sQF,nat_sQF,sil_sQF,pho_sQF,tco2_sQF,talk_sQF,phtsinsitutp_sQF, phts25p0_sQF:integer;

//cfcll:real;

begin
   path_out:='c:\Users\ako071\AK\datasets\GLODAP\output.dat';
   AssignFile(out, Path_out); Rewrite(out);

   memo1.Lines.Add('');
   memo1.Lines.Add('var_num ='+inttostr(var_num));
   for k:=1 to var_num do memo1.Lines.Add(inttostr(k)+#9+var_name[k]);
   memo1.Lines.Add('line_num='+inttostr(line_num));


   Reset(dat);
   readln(dat, st);
   line:=1;
//{r}repeat
//{w}while not EOF(dat) do begin
{f}for k:=1 to line_num-1 do begin
     readln(dat, st);
     line:=line+1;
     //showmessage('line='+inttostr(line)+'  length='+inttostr(length(st)));

     stlat:=-9999;
     stlon:=-9999;
     stPDS:=-9999;
     stNBNum:=-9999;

//string analysis
     n:=0;
{k}for kv:=1 to var_num do begin
     buf_str:='';
{s}repeat
     inc(n);
     symbol:=st[n];
     if (symbol<>',') then buf_str:=buf_str+symbol;

     //if k=1 then showmessage (' kv='+inttostr(kv)+' n='+inttostr(n)+' sym='+symbol
     //            +' ASCII='+inttostr(ord(symbol))+' buf='+buf_str);
     //if k=line_num-1 then showmessage (' kv='+inttostr(kv)+' n='+inttostr(n)+' sym='+symbol
     //            +' ASCII='+inttostr(ord(symbol))+' buf='+buf_str);

{s}until (symbol=',') or (n=length(st));
{b}if buf_str<>'' then begin

  if not TryStrToFloat(buf_str, buf)
  then showmessage ('trystrtofloat line='+inttostr(line)+' '+buf_str);


(***********************************COMMENTED out to compile the code - AS
    case kv of
    1: cruiseN:=trunc(strtofloat(buf_str));
    2: stationN:=trunc(strtofloat(buf_str));
    3: castN:=trunc(strtofloat(buf_str));
    4: year:=trunc(strtofloat(buf_str));
    5: month:=trunc(strtofloat(buf_str));
    6: day:=trunc(strtofloat(buf_str));
    7: hour:=trunc(strtofloat(buf_str));
    8: min:=trunc(strtofloat(buf_str));
    9: stlat:=strtofloat(buf_str);
   10: stlon:=strtofloat(buf_str);
   11: stBD:=strtofloat(buf_str);                    //bottom depth m
   12: stPDS:=strtofloat(buf_str);                   //pressure of the deepest sample
   13: stNBNum:=trunc(strtofloat(buf_str));          //Niskin bottle number

   14: press:=strtofloat(buf_str);                   //sampling pressure dbar
   16: temp:=strtofloat(buf_str);                    //temperature

   18: salt:=strtofloat(buf_str);                    //salinity
   19: salt_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   20: salt_sQF:=trunc(strtofloat(buf_str));         //sQF

   27: oxy:=strtofloat(buf_str);                    //oxygen
   28: oxy_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   29: oxy_sQF:=trunc(strtofloat(buf_str));         //sQF

   27: aou:=strtofloat(buf_str);                    //apparant oxygen utilization
   28: aou_pQF1:=trunc(strtofloat(buf_str));        //pQF1

   32: nat:=strtofloat(buf_str);                    //nitrate
   33: nat_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   34: nat_sQF:=trunc(strtofloat(buf_str));         //sQF

   35: nit:=strtofloat(buf_str);                    //nitrite
   36: nit_pQF1:=trunc(strtofloat(buf_str));        //pQF1

   37: sil:=strtofloat(buf_str);                    //silicate
   38: sil_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   39: sil_sQF:=trunc(strtofloat(buf_str));         //sQF

   40: pho:=strtofloat(buf_str);                    //phosphate
   41: pho_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   42: pho_sQF:=trunc(strtofloat(buf_str));         //sQF

   43: tco2:=strtofloat(buf_str);                    //tco2
   44: tco2_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   45: tco2_sQF:=trunc(strtofloat(buf_str));         //sQF

   43: talk:=strtofloat(buf_str);                    //talk
   44: talk_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   45: talk_sQF:=trunc(strtofloat(buf_str));         //sQF

   49: phts25p0:=strtofloat(buf_str);                    //ph ts 25 p0
   50: phts25p0_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   53: phts25p0_sQF:=trunc(strtofloat(buf_str));         //sQF

   51: phtsinsitutp:=strtofloat(buf_str);                    //ph ts insitu tp
   52: phtsinsitutp_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   53: phtsinsitutp_sQF:=trunc(strtofloat(buf_str));         //sQF

   51: cfc11:=strtofloat(buf_str);                    //cfc11
   51: pcfc11:=strtofloat(buf_str);                   //cfc11
   52: cfc11_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   53: cfc11_sQF:=trunc(strtofloat(buf_str));         //sQF
 }

{
press,temp,salt,oxy,aou,nat,nit,sil,pho,tco2,talk,phts25p0,phtsinsitutp
salt_pQF1,oxy_pQF1,aou_pQF1,nat_pQF1,nit_pQF1,sil_pQF1,pho_pQF1,tco2_pQF1,talk_pQF1
phtsinsitutp_pQF1
salt_sQF,oxy_sQF,nat_sQF,sil_sQF,pho_sQF,tco2_sQF,talk_sQF,phtsinsitutp_sQF}

    end;{case}
*)  //END of commenting out - AS

{k}end;

{b}end;

    //stDate:=EncodeDate(year,month,day);
    //stTime:=EncodeTime(hour,min,0,0);
    //ODBPr_ConvertDateTime(year,month,day,hour,min,StDate,StTime,MonthErr,TimeErr);

    StDT:= DateEncode(Year,Month,Day,Hour,Min,DayChange,DateChange);

    if DayChange=true then memo1.Lines.Add('Day was changed in line='
                           +inttostr(line)
                           +'  '+inttostr(day)+'.'+inttostr(month)+'.'+inttostr(year)
                           +'  '+inttostr(hour)+':'+inttostr(min));
    if DateChange=true then memo1.Lines.Add('Date was changed in line='
                           +inttostr(line)
                           +'  '+inttostr(day)+'.'+inttostr(month)+'.'+inttostr(year)
                           +'  '+inttostr(hour)+':'+inttostr(min));


     writeln(out,inttostr(line),
     #9,inttostr(cruiseN),
     #9,inttostr(stationN),
     #9,inttostr(castN),
     //#9,datetostr(stdate),
     //#9,timetostr(sttime),
     #9,datetimetostr(stDT),
     #9,floattostr(stlat),
     #9,floattostr(stlon),
     #9,floattostr(stBD),
     #9,floattostr(stPDS),
     #9,inttostr(stNBNum)
     );

    //memo1.Lines.Add(inttostr(line)
    //+#9+inttostr(cruiseN)
    //+#9+inttostr(stationN)
    //+#9+inttostr(castN)
    //);

//{r}until eof(dat);
//{w}end;
{f}end;

   CloseFile(dat);
   CloseFile(out);

   memo1.Lines.Add('End of file');

end;

function TfrmloadGLODAP_2019_v2_product.DateEncode(Year,Month,Day,Hour,Minutes:word;
  Var DaysInAMonthFlag,DateChangedFlag:Boolean):TDateTime;
var
  DateBuf:TDateTime;
begin

  DaysInAMonthFlag:=False;
  DateChangedFlag:=False;

  if Day<=DaysInaMonth(Year,Month) then
  begin
    DateBuf:=EncodeDateTime(Year+1600,Month,1,0,0,0,0);
    if (Hour>=0) and (Hour<=24) then
    begin
      if ((Minutes<=60) and (Minutes>0) and (Hour<24)) or
       ((Minutes<60) and (Hour=24)) then
       DateBuf:=IncMinute(DateBuf,Minutes)  ;

      if (Hour=24) or ((Hour=23) and (Minutes=60)) then
        DateChangedFlag:=True;
      if (Hour=24) and (Minutes>60) then
        DateChangedFlag:=False;

      if (Hour>0) and (Minutes<=60) then
        DateBuf:=IncHour(DateBuf,Hour);
    end;

    DateBuf:=IncDay(DateBuf,Day-1);
    Result:=IncYear(DateBuf,-1600);
  end
  else
  begin
    DaysInAMonthFlag:=True;
    if Month<12 then
      DateBuf:=EncodeDateTime(Year+1600,Month+1,1,0,0,0,0)
    else
      DateBuf:=EncodeDateTime(Year+1601,1,1,0,0,0,0);

    if (Hour>=0) and (Hour<=24) then
    begin
      if (Minutes<60) and (Minutes>0) then
       DateBuf:=IncMinute(DateBuf,Minutes)
      else
      begin
       if Minutes=60 then
          inc(Hour);
      end;

      if (Hour>=24) or ((Hour=23) and (Minutes=60)) then
        DateChangedFlag:=True;
      if (Hour=24) and (Minutes>60) then
        DateChangedFlag:=False;

      if (Hour>=24) or (Minutes>60) then
        Hour:=0;
      DateBuf:=IncHour(DateBuf,Hour);
    end;

    Result:=IncYear(DateBuf,-1600);
  end;

end;



procedure TfrmloadGLODAP_2019_v2_product.btnCreateTablesClick(Sender: TObject);
Var
TR:TSQLTransaction;
ST:TSQLScript;

ScriptText:string;
begin

  if frmdm.IBDB.Connected=false then begin
    showmessage('database is not opened');
    exit;
  end;

  (* Script for parameter tables *)
  ScriptText:=
  (* 1	P_TEMPERATURE_BOTTLE	5	press val         pQF1      sQF		TEMPERATURE	Sea water temperture *)
     'CREATE TABLE P_TEMPERATURE_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 2	P_SALINITY_BOTTLE	5	press val         pQF1 pQF2 sQF	CV	SALINITY	Sea water salinity *)
     'CREATE TABLE P_SALINITY_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 3	P_OXYGEN_BOTTLE		5	press val         pQF1 pQF2 sQF	CV	OXYGEN		Dissolved Oxygen *)
     'CREATE TABLE P_OXYGEN_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 4	P_AOU_BOTTLE		5	press val         pQF1 pQF2 sQF		AOU		Apparent oxygen utilization  *)
     'CREATE TABLE P_AOU_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 5	P_NITRATE_BOTTLE	5	press val         pQF1 pQF2 sQF	CV	NITRATE		Nitrate *)
     'CREATE TABLE P_NITRATE_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 6	P_NITRITE_BOTTLE	5	press val         pQF1 pQF2 sQF		NITRITE		Nitrite *)
     'CREATE TABLE P_NITRITE_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 7	P_SILICATE_BOTTLE	5	press val         pQF1 pQF2 sQF	CV	SILICATE	Silicate *)
     'CREATE TABLE P_SILICATE_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 8	P_PHOSPHATE_BOTTLE	5	press val         pQF1 pQF2 sQF	CV	PHOSPHATE	Phosphate  *)
     'CREATE TABLE P_PHOSPHATE_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+


  (* 9	P_TCO2_BOTTLE		5	press val         pQF1 pQF2 sQF	CV	TCO2		Dissolved inorganic carbon *)
     'CREATE TABLE P_TCO2_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 10	P_TALK_BOTTLE		5	press val         pQF1 pQF2 sQF	CV	TALK		Total alkalinity *)
     'CREATE TABLE P_TALK_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 11	P_PHTS25P0_BOTTLE	5	press val         pQF1 pQF2 sQF	CV	PH		pH on total scale, 25C, 0dbar *)
     'CREATE TABLE P_PHTS25P0_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 12	P_PHTSINSITUTP_BOTTLE	5	press val         pQF1 pQF2 sQF		PH		pH on total scale, in situ temperature and pressure *)
     'CREATE TABLE P_PHTSINSITUTP_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 13	P_CFC11_BOTTLE		6	press val pval    pQF1 pQF2 sQF	CV	CFC11		Halogenated transient tracer CFC11  *)
     'CREATE TABLE P_CFC11_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   PVAL           DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 14	P_CFC12_BOTTLE		6	press val pval    pQF1 pQF2 sQF	CV	CFC12		Halogenated transient tracer CFC12 *)
     'CREATE TABLE P_CFC12_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   PVAL           DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 15	P_CFC113_BOTTLE		6	press val pval    pQF1 pQF2 sQF	CV	CFC113		Halogenated transient tracer CFC113 *)
     'CREATE TABLE P_CFC113_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   PVAL           DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (*16	P_CC14_BOTTLE		6	press val pval    pQF1 pQF2 sQF	CV	CC14		Halogenated transient tracer CC14 *)
     'CREATE TABLE P_CC14_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   PVAL           DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 17	P_SF6_BOTTLE		6	press val pval    pQF1 pQF2 sQF		SF6		Sulfur hexafluoride  *)
     'CREATE TABLE P_SF6_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   PVAL           DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 18	P_C13_BOTTLE		5	press val         pQF1 pQF2 sQF		C13		Stable isotop carbon 13 *)
     'CREATE TABLE P_C13_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 19	P_C14_BOTTLE		6	press val valerr  pQF1 pQF2 sQF		C14		Radioisotop carbon 14  *)
     'CREATE TABLE P_C14_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   VALERR         DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 20	P_H3_BOTTLE		6	press val valerr  pQF1 pQF2 sQF		H3		Radioisotop hydrogen 3, tritium *)
     'CREATE TABLE P_H3_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   VALERR         DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 21	P_HE3_BOTTLE		6	press val valerr  pQF1 pQF2 sQF		HE3		Radioisotop helium 3, counting error  *)
     'CREATE TABLE P_HE3_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   VALERR         DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 22	P_HE_BOTTLE		6	press val valerr  pQF1 pQF2 sQF		HE		Helium, counting error  *)
     'CREATE TABLE P_HE_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   VALERR         DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 23	P_NEON_BOTTLE		6	press val valerr  pQF1 pQF2 sQF		NEON		Neon, counting error *)
     'CREATE TABLE P_NEON_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   VALERR         DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 24	P_O18_BOTTLE		5	press val         pQF1 pQF2 sQF		O18		Stable isotop of oxygen 18 *)
     'CREATE TABLE P_O18_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 25	P_TOC_BOTTLE		5	press val         pQF1 pQF2 sQF		TOC		Total organic carbon *)
     'CREATE TABLE P_TOC_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 26	P_DOC_BOTTLE		5	press val         pQF1 pQF2 sQF		DOC		Dissolved organic carbon  *)
     'CREATE TABLE P_DOC_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 27	P_DON_BOTTLE		5	press val         pQF1 pQF2 sQF		DON		Dissolved organic nitrogen *)
     'CREATE TABLE P_DON_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 28	P_TDN_BOTTLE		5	press val         pQF1 pQF2 sQF		TDN		Total dissolved nitrogen *)
     'CREATE TABLE P_TDN_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 29	P_CHLA_BOTTLE		5	press val         pQF1 pQF2 sQF		CHLA		chlorophylla *)
     'CREATE TABLE P_CHLA_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   CAST_NUMBER    SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

     'ALTER TABLE P_TEMPERATURE_BOTTLE ADD CONSTRAINT FK_P_TEMPERATURE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_SALINITY_BOTTLE ADD CONSTRAINT FK_P_SALINITY_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_OXYGEN_BOTTLE ADD CONSTRAINT FK_P_OXYGEN_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_AOU_BOTTLE ADD CONSTRAINT FK_P_AOU_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_NITRATE_BOTTLE ADD CONSTRAINT FK_P_NITRATE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_NITRITE_BOTTLE ADD CONSTRAINT FK_P_NITRITE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_SILICATE_BOTTLE ADD CONSTRAINT FK_P_SILICATE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_PHOSPHATE_BOTTLE ADD CONSTRAINT FK_P_PHOSPHATE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_TCO2_BOTTLE ADD CONSTRAINT FK_P_TCO2_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_TALK_BOTTLE ADD CONSTRAINT FK_P_TALK_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_PHTS25P0_BOTTLE ADD CONSTRAINT FK_P_PHTS25P0_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_PHTSINSITUTP_BOTTLE ADD CONSTRAINT FK_P_PHTSINSITUTP_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_CFC11_BOTTLE ADD CONSTRAINT FK_P_CFC11_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_CFC12_BOTTLE ADD CONSTRAINT FK_P_CFC12_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_CFC113_BOTTLE ADD CONSTRAINT FK_P_CFC113_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_CC14_BOTTLE ADD CONSTRAINT FK_P_CC14_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_SF6_BOTTLE ADD CONSTRAINT FK_P_SF6_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_C13_BOTTLE ADD CONSTRAINT FK_P_C13_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_C14_BOTTLE ADD CONSTRAINT FK_P_C14_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_H3_BOTTLE ADD CONSTRAINT FK_P_H3_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_HE3_BOTTLE ADD CONSTRAINT FK_P_HE3_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_HE_BOTTLE ADD CONSTRAINT FK_P_HE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_NEON_BOTTLE ADD CONSTRAINT FK_P_NEON_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_O18_BOTTLE ADD CONSTRAINT FK_P_O18_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_TOC_BOTTLE ADD CONSTRAINT FK_P_TOC_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_DOC_BOTTLE ADD CONSTRAINT FK_P_DOC_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_DON_BOTTLE ADD CONSTRAINT FK_P_DON_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_TDN_BOTTLE ADD CONSTRAINT FK_P_TDN_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_CHLA_BOTTLE ADD CONSTRAINT FK_P_CHLA_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+

     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (1, '+QuotedStr('P_TEMPERATURE_BOTTLE')+','  +QuotedStr('TEMPERATURE')+','+QuotedStr('Sea water temperture')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (2, '+QuotedStr('P_SALINITY_BOTTLE')+','     +QuotedStr('SALINITY')+','   +QuotedStr('Sea water salinity')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (3, '+QuotedStr('P_OXYGEN_BOTTLE')+','       +QuotedStr('OXYGEN')+','     +QuotedStr('Dissolved Oxygen')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (4, '+QuotedStr('P_AOU_BOTTLE')+','          +QuotedStr('AOU')+','        +QuotedStr('Apparent oxygen utilization')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (5, '+QuotedStr('P_NITRATE_BOTTLE')+','      +QuotedStr('NITRATE')+','    +QuotedStr('Nitrate')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (6, '+QuotedStr('P_NITRITE_BOTTLE')+','      +QuotedStr('NITRITE')+','    +QuotedStr('Nitrite')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (7, '+QuotedStr('P_SILICATE_BOTTLE')+','     +QuotedStr('SILICATE')+','   +QuotedStr('Silicate')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (8, '+QuotedStr('P_PHOSPHATE_BOTTLE')+','    +QuotedStr('PHOSPHATE')+','  +QuotedStr('Phosphate')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (9, '+QuotedStr('P_TCO2_BOTTLE')+','         +QuotedStr('TCO2')+','       +QuotedStr('Dissolved inorganic carbon')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (10, '+QuotedStr('P_TALK_BOTTLE')+','        +QuotedStr('TALK')+','       +QuotedStr('Total alkalinity')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (11, '+QuotedStr('P_PHTS25P0_BOTTLE')+','    +QuotedStr('PH')+','         +QuotedStr('pH on total scale, 25C, 0dbar')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (12, '+QuotedStr('P_PHTSINSITUTP_BOTTLE')+','+QuotedStr('PH')+','         +QuotedStr('pH on total scale, in situ temperature and pressure')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (13, '+QuotedStr('P_CFC11_BOTTLE')+','       +QuotedStr('CFC11')+','      +QuotedStr('Halogenated transient tracer CFC11, partial pressure')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (14, '+QuotedStr('P_CFC12_BOTTLE')+','       +QuotedStr('CFC12')+','      +QuotedStr('Halogenated transient tracer CFC12, partial pressure')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (15, '+QuotedStr('P_CFC113_BOTTLE')+','      +QuotedStr('CFC113')+','     +QuotedStr('Halogenated transient tracer CFC113, partial pressure')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (16, '+QuotedStr('P_CC14_BOTTLE')+','        +QuotedStr('CC14,')+','      +QuotedStr('Halogenated transient tracer CC14, partial pressure')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (17, '+QuotedStr('P_SF6_BOTTLE')+','         +QuotedStr('SF6,')+','       +QuotedStr('Sulfur hexafluoride, partial pressure')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (18, '+QuotedStr('P_C13_BOTTLE')+','         +QuotedStr('C13,')+','       +QuotedStr('Stable isotop carbon 13')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (19, '+QuotedStr('P_C14_BOTTLE')+','         +QuotedStr('C14,')+','       +QuotedStr('Radioisotop carbon 14, counting error')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (21, '+QuotedStr('P_H3_BOTTLE')+','          +QuotedStr('H3,')+','        +QuotedStr('Radioisotop hydrogen 3, tritium')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (20, '+QuotedStr('P_HE3_BOTTLE')+','         +QuotedStr('HE3,')+','       +QuotedStr('Radioisotop helium 3, counting error')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (21, '+QuotedStr('P_HE_BOTTLE')+','          +QuotedStr('HE,')+','        +QuotedStr('Helium, counting error')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (22, '+QuotedStr('P_NEON_BOTTLE')+','        +QuotedStr('NEON,')+','      +QuotedStr('Neon, counting error')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (23, '+QuotedStr('P_O18_BOTTLE')+','         +QuotedStr('O18,')+','       +QuotedStr('Stable isotop of oxygen 18')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (24, '+QuotedStr('P_TOC_BOTTLE')+','         +QuotedStr('TOC,')+','       +QuotedStr('Total organic carbon')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (25, '+QuotedStr('P_DOC_BOTTLE')+','         +QuotedStr('DOC,')+','       +QuotedStr('Dissolved organic carbon')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (26, '+QuotedStr('P_DON_BOTTLE')+','         +QuotedStr('DON,')+','       +QuotedStr('Dissolved organic nitrogen')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (27, '+QuotedStr('P_TDN_BOTTLE')+','         +QuotedStr('TDN,')+','       +QuotedStr('Total dissolved nitrogen')+'); '+LineEnding+
     'INSERT INTO "PARAMETER" (ID, TABLENAME, PARAMETERNAME, DESCRIPTION) VALUES (28, '+QuotedStr('P_CHLA_BOTTLE')+','        +QuotedStr('CHLA,')+','      +QuotedStr('chlorophylla')+'); '+LineEnding+

     'COMMIT WORK '+LineEnding+
     'SET TERM ; '+LineEnding;

//  memo1.Lines.add(ScriptText);
 try
    TR:=TSQLTransaction.Create(self);
    TR.DataBase:=frmdm.IBDB;

    ST:=TSQLScript.Create(nil);
    ST.Transaction:=TR;
    ST.Database:=frmdm.IBDB;

    ST.Script.Text:=ScriptText;
    ST.UseCommit:=true;
    ST.UseSetTerm:=true; // for Firebird ONLY
    ST.CommentsInSQL:=false;
     try
      ST.Execute;
      TR.Commit;

       ShowMessage('Script successfully applied');
     except
      on E: EDataBaseError do begin
        ShowMessage('Error running script: '+E.Message);
        TR.Rollback;
      end;
     end;
 finally
  ST.Free;
  TR.Free;
 end;
end;

end.

