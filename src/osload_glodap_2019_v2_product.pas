unit osload_GLODAP_2019_v2_product;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DateUtils;

type

  { TfrmloadGLODAP_2019_v2_product }

  TfrmloadGLODAP_2019_v2_product = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
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



press,temp,salt,oxy,aou,nat,nit,sil,pho,tco2,talk,phts25p0,phtsinsitutp
salt_pQF1,oxy_pQF1,aou_pQF1,nat_pQF1,nit_pQF1,sil_pQF1,pho_pQF1,tco2_pQF1,talk_pQF1
phtsinsitutp_pQF1
salt_sQF,oxy_sQF,nat_sQF,sil_sQF,pho_sQF,tco2_sQF,talk_sQF,phtsinsitutp_sQF

    end;{case}
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

end.

