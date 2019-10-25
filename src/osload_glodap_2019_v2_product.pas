//GLODAPv2.2019 product download
//
// I. First file scroll btnDataSource
//    determining the number of variables in a file (102)
//    number of lines in file (1175007)
//    creation of an array of names on the first line (var_name[1..200])
//
// II.Second file scroll btnDownloadMD
//    extract metadata from strings
//    string conversion to values and date
//    counting the number of cruises (840), stations (52299), castes (42112)
//    and real stations (RSt#=86705)
//    creation of an array of station boundaries in a file (by line numbers)
//    line_err[1..100000]
//    writing metadata to the STATION table
//
//III.Third file scroll btnDownloadData
//    divide station on casts (CDS_DSC)
//    writing profiles into variables table
//


unit osload_GLODAP_2019_v2_product;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  DateUtils, SQLDB, DB, BufDataSet;

type

  { TfrmloadGLODAP_2019_v2_product }

  TfrmloadGLODAP_2019_v2_product = class(TForm)
    btnDataSource: TButton;
    btnDownloadMD: TButton;
    btnCreateTables: TButton;
    btnDownloadData: TButton;
    btnSplitOnMDandProfiles: TButton;
    CheckBox1: TCheckBox;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure btnDataSourceClick(Sender: TObject);
    procedure btnDownloadMDClick(Sender: TObject);
    procedure btnDownloadDataClick(Sender: TObject);

    procedure btnCreateTablesClick(Sender: TObject);
    procedure btnSplitOnMDandProfilesClick(Sender: TObject);

  private

  public

  end;

var
  frmloadGLODAP_2019_v2_product: TfrmloadGLODAP_2019_v2_product;
  var_num,LinesInFile,RSt:integer;
  Path, path_out, path_MD, path_PRF:string;
  var_name:array[1..200] of string;     //variables names
  line_arr:array[1..100000] of integer; //profile intervals at stations
  Dat, out, outMD, outPRF:text;
  CDS_DSC:TBufDataSet; //CDS Divide stations on casts

implementation

uses osmain, procedures, dm, declarations_gsw;

{$R *.lfm}

{ TfrmloadGLODAP_2019_v2_product }



procedure TfrmloadGLODAP_2019_v2_product.btnDataSourceClick(Sender: TObject);
var
k,kv,n,i:integer;
cruiseN,stationN,castN,stNBNum,cast_max:integer;
year,month,day,hour,min:integer;
stlat,stlon,stBD,stPDS:real;
buf:real;
symbol:char;
st,buf_str:string;
StDate,StTime,StDT:TDateTime;
DayChange,DateChange:Boolean;
//divide file on stations/casts
cruiseNbuf,stationNbuf,castNbuf:Integer;
cruise_count,station_count,cast_count:Integer;
newCruise,newStation,newCast,NewMD:Boolean;

begin
  path:='c:\Users\ako071\AK\datasets\GLODAP\GLODAPv2.2019_Merged_Master_File.csv';
  memo1.Lines.Add('path='+path);

  path_out:='c:\Users\ako071\AK\datasets\GLODAP\output_MD.dat';
  AssignFile(out, Path_out); Rewrite(out);
  memo1.Lines.Add('path_out='+path_out);

  writeln(out,'Rst#  Line_arr[RSt]  line#  cruise#  st#  cast#  date  lat  lon  BD  LastPress bottle#');

  AssignFile(dat, Path); Reset(dat);
  readln(dat, st);
  st:=trim(st);

//number of variables in file from the first line
    var_num:=0;
  for k:=1 to length(st) do begin
    symbol:=st[k];
    if symbol=',' then var_num:=var_num+1;
  end;
    var_num:=var_num+1;
    memo1.Lines.Add('Variables in file:'+inttostr(var_num));


//create array with variable names
  for k:=1 to 200 do var_name[k]:='';
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
  memo1.Lines.Add('Array with variable names is created');


//count lines in file
  i:=1;
  try
  repeat
    readln(dat,st);
    i:=i+1;
  until eof(dat);
  finally
    closefile(dat);
  end;
    LinesInFile:=i;
    memo1.Lines.Add('Total    lines in file    :'+inttostr(LinesInFile));
    memo1.Lines.Add('Profiles lines in file    :'+inttostr(LinesInFile-1));



//create array 'line_arr' for file division on profiles

     Reset(dat);
     readln(dat, st);
     line_arr[1]:=2; //first profile begins in line 2
     RSt:=0; //real station = profile

{L}for i:=2 to LinesInFile do begin
     readln(dat,st);
     st:=trim(st);

     newCruise:=false;
     newStation:=false;
     newCast:=false;

//the string analysis
     n:=0;
{kv}for kv:=1 to var_num do begin
     buf_str:='';
{s}repeat
    inc(n);
    symbol:=st[n];
    if (symbol<>',') then buf_str:=buf_str+symbol;
    //if i=1 then showmessage (' kv='+inttostr(kv)+' n='+inttostr(n)+' sym='+symbol
    //            +' ASCII='+inttostr(ord(symbol))+' buf='+buf_str);
    //if i=LinesInFile-1 then showmessage (' kv='+inttostr(kv)+' n='+inttostr(n)+' sym='+symbol
    //            +' ASCII='+inttostr(ord(symbol))+' buf='+buf_str);
{s}until (symbol=',') or (n=length(st));

{b}if buf_str<>'' then begin

       if not TryStrToFloat(buf_str, buf)
       then showmessage ('trystrtofloat line='+inttostr(i)+' '+buf_str);

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
       end; {case}

{b}end; {buf_str<>''}
{kv}end; {kv variables loop}
//end the string analysis

     //convert date and time into datetime
     StDT:= procedures.DateEncode(Year,Month,Day,Hour,Min,DayChange,DateChange);
     if DayChange=true then memo1.Lines.Add('Day was changed in line='
                       +inttostr(i)
                       +'  '+inttostr(day)+'.'+inttostr(month)+'.'+inttostr(year)
                       +'  '+inttostr(hour)+':'+inttostr(min));
     if DateChange=true then memo1.Lines.Add('Date was changed in line='
                       +inttostr(i)
                       +'  '+inttostr(day)+'.'+inttostr(month)+'.'+inttostr(year)
                       +'  '+inttostr(hour)+':'+inttostr(min));

     //count cruise, stations, casts
     if i=1 then begin
           cruiseNbuf:=cruiseN;
           stationNbuf:=stationN;
           castNbuf:=cruiseN;
     end;

     //count cruises, stations, casts
     if i>1 then begin
       if cruiseN<>cruiseNbuf then begin newCruise:=true; cruise_count:=cruise_count+1; end;
       if stationN<>stationNbuf then begin newStation:=true; station_count:=station_count+1; end;
       if castN<>castNbuf then begin newCast:=true; cast_count:=cast_count+1; end;

       newMD:=false;
       if(newCruise=true)  then newMD:=true;
       if(newStation=true) then newMD:=true;
     end;

   //find stations first line
{N}if newMD=true then begin
           RSt:=RSt+1;
           line_arr[RSt]:=i; //lines where stations begin
           //showmessage('RST -> Line  '+inttostr(RSt)+'->'+inttostr(line));

           cruiseNbuf:=cruiseN;
           stationNbuf:=stationN;
           castNbuf:=castN;

           writeln(out,inttostr(RSt),
           #9,inttostr(line_arr[Rst]),
           #9,inttostr(i),
           #9,inttostr(cruiseN),
           #9,inttostr(stationN),
           #9,inttostr(castN),
           #9,datetimetostr(stDT),
           #9,floattostr(stlat),
           #9,floattostr(stlon),
           #9,floattostr(stBD),
           #9,floattostr(stPDS),
           #9,inttostr(stNBNum)
           );
{N}end;

{L}end; { i all lines in file}
     RSt:=RSt+1;
     line_arr[RSt]:=LinesInFile;

     writeln(out,'!!! Last element in the Line_ARR contains number of the last line in file ');
     writeln(out,'!!! So it is not really the station number');
     writeln(out,inttostr(RSt),
     #9,inttostr(line_arr[Rst]),
     #9,inttostr(i),
     #9,inttostr(cruiseN),
     #9,inttostr(stationN),
     #9,inttostr(castN),
     #9,datetimetostr(stDT),
     #9,floattostr(stlat),
     #9,floattostr(stlon),
     #9,floattostr(stBD),
     #9,floattostr(stPDS),
     #9,inttostr(stNBNum)
     );


     closefile(dat);
     closefile(out);

     Panel1.Visible:=true;
     btnSplitOnMDandProfiles.Visible:=true;
     //btnDownloadMD.Visible:=true;

     memo1.Lines.Add('Stations in file          :'+inttostr(RSt-1));
end;


procedure TfrmloadGLODAP_2019_v2_product.btnDownloadMDClick(Sender: TObject);
var
i,kv,line,n,mik:integer;
cruiseN,stationN,castN,stNBNum,cast_max:integer;
year,month,day,hour,min:integer;
stlat,stlon,stBD,stPDS,stLLM:real;
buf:real;
symbol:char;
st,buf_str:string;
StDate,StTime,StDT:TDateTime;
DayChange,DateChange:Boolean;
ww:boolean; //workedwell


//values
press,temp,salt,oxy,aou,nat,nit,sil,pho,tco2,talk,phts25p0,phtsinsitutp:real;
cfc11,pcfc11,cfc12,pcfc12,cfc113,pcfc113,cc14,pcc14,sf6,psf6,c13,c14:real;
h3,he3,he,neon,O18,toc,doc,don,tdn,chla:real;
//errors
c14_err,h3_err,he3_err,he_err,neon_err:real;
//QF primary 1
salt_pQF1,oxy_pQF1,aou_pQF1,nat_pQF1,nit_pQF1,sil_pQF1,pho_pQF1:integer;
tco2_pQF1,talk_pQF1,phtsinsitutp_pQF1,cfc11_pQF1,cfc12_pQF1,cfc113_pQF1:integer;
cc14_pQF1,c13_pQF1,c14_pQF1,h3_pQF1,he3_pQF1,he_pQF1,neon_pQF1:integer;
O18_pQF1,toc_pQF1,doc_pQF1,don_pQF1,tdn_pQF1,chla_pQF1,phts25p0_pQF1:integer;
//QF secondary
salt_sQF,oxy_sQF,nat_sQF,sil_sQF,pho_sQF,tco2_sQF,talk_sQF,phtsinsitutp_sQF:integer;
cfc11_sQF,cfc12_sQF,cfc113_sQF,cc14_sQF,sf6_pQF1,c13_sQF,phts25p0_sQF:integer;
//divide file on stations/casts
cast_count:Integer;
//download
CountDup,StVersion:integer;

begin
{   path_out:='c:\Users\ako071\AK\datasets\GLODAP\output_MD_Load.dat';
   AssignFile(out, Path_out); Rewrite(out);
   writeln(out,'Rst#  line#  cruise#  st#  cast#  date  lat  lon  BD  LastPress bottle#');


   memo1.Lines.Add('');
   memo1.Lines.Add('Variables');
   for kv:=1 to var_num do memo1.Lines.Add(inttostr(kv)+#9+var_name[kv]);

   //memo1.Lines.Add('Variables in file:'+inttostr(var_num));
   //memo1.Lines.Add('Lines in file:'+inttostr(LinesInFile));


   Reset(dat);

   cast_max:=1;

{i}for i:=1 to LinesInFile do begin
     readln(dat, st);
     st:=trim(st);
     //showmessage('line='+inttostr(line)+'  length='+inttostr(length(st)));

     NextStFound:=false;
   for k:=1 to RSt do begin
     L:=line_arr[k];
     if (i=L) then NextStFound:=true;
   end;

{N}if NextStFound=true then begin

     stlat:=-9999;
     stlon:=-9999;
     stPDS:=-9999;
     stNBNum:=-9999;

     newCruise:=false;
     newStation:=false;
     newCast:=false;

//string analysis
     n:=0;
{kv}for kv:=1 to var_num do begin
     buf_str:='';
{s}repeat
     inc(n);
     symbol:=st[n];
     if (symbol<>',') then buf_str:=buf_str+symbol;
{s}until (symbol=',') or (n=length(st));

{b}if buf_str<>'' then begin

  if not TryStrToFloat(buf_str, buf)
  then showmessage ('trystrtofloat line='+inttostr(line)+' '+buf_str);

    case kv of
    1: cruiseN:=trunc(strtofloat(buf_str));
    2: stationN:=trunc(strtofloat(buf_str));
    3: begin
       castN:=trunc(strtofloat(buf_str));
       if (cast_max<castN) then cast_max:=castN;
       end;
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

   30: aou:=strtofloat(buf_str);                    //apparant oxygen utilization
   31: aou_pQF1:=trunc(strtofloat(buf_str));        //pQF1

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

   43: tco2:=strtofloat(buf_str);                    //tco2:Dissolved inorganic carbon
   44: tco2_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   45: tco2_sQF:=trunc(strtofloat(buf_str));         //sQF

   46: talk:=strtofloat(buf_str);                    //talk
   47: talk_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   48: talk_sQF:=trunc(strtofloat(buf_str));         //sQF

   49: phts25p0:=strtofloat(buf_str);                    //ph ts 25 p0
   50: phts25p0_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   53: begin
        phts25p0_sQF:=trunc(strtofloat(buf_str));         //sQF
        phtsinsitutp_sQF:=trunc(strtofloat(buf_str));         //sQF
       end;

   51: phtsinsitutp:=strtofloat(buf_str);                    //ph ts insitu tp
   52: phtsinsitutp_pQF1:=trunc(strtofloat(buf_str));        //pQF1

   54: cfc11:=strtofloat(buf_str);                    //cfc11:transient tracer
   55: pcfc11:=strtofloat(buf_str);                   //pcfc11
   56: cfc11_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   57: cfc11_sQF:=trunc(strtofloat(buf_str));         //sQF

   58: cfc12:=strtofloat(buf_str);                    //cfc12:transient tracer
   59: pcfc12:=strtofloat(buf_str);                   //pcfc12
   60: cfc12_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   61: cfc12_sQF:=trunc(strtofloat(buf_str));         //sQF

   62: cfc113:=strtofloat(buf_str);                    //cfc113:transient tracer
   63: pcfc113:=strtofloat(buf_str);                   //pcfc113
   64: cfc113_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   65: cfc113_sQF:=trunc(strtofloat(buf_str));         //sQF

   66: cc14:=strtofloat(buf_str);                    //cc14:transient tracer
   67: pcc14:=strtofloat(buf_str);                   //pcc14
   68: cc14_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   69: cc14_sQF:=trunc(strtofloat(buf_str));         //sQF

   70: sf6:=strtofloat(buf_str);                    //sf6:Sulfur hexafluoride
   71: psf6:=strtofloat(buf_str);                   //psf6
   72: sf6_pQF1:=trunc(strtofloat(buf_str));        //pQF1

   73: c13:=strtofloat(buf_str);                    //c13 Stable isotop carbon 13
   74: c13_pQF1:=trunc(strtofloat(buf_str));        //pQF1
   75: c13_sQF:=trunc(strtofloat(buf_str));         //sQF

   76: c14:=strtofloat(buf_str);                   //c14 Radioisotop carbon 14
   77: c14_pQF1:=trunc(strtofloat(buf_str));       //pQF1
   78: c14_err:=strtofloat(buf_str);               //counting error

   79: h3:=strtofloat(buf_str);                   //h3:radioisotop hydrogen 3, Tritium
   80: h3_pQF1:=trunc(strtofloat(buf_str));       //pQF1
   81: h3_err:=strtofloat(buf_str);               //counting error

   82: he3:=strtofloat(buf_str);                   //he3:Radioisotop helium 3
   83: he3_pQF1:=trunc(strtofloat(buf_str));       //pQF1
   84: he3_err:=strtofloat(buf_str);               //counting error

   85: he:=strtofloat(buf_str);                    //he:helium
   86: he_pQF1:=trunc(strtofloat(buf_str));       //pQF1
   87: he_err:=strtofloat(buf_str);               //counting error

   88: neon:=strtofloat(buf_str);                    //neon
   89: neon_pQF1:=trunc(strtofloat(buf_str));       //pQF1
   90: neon_err:=strtofloat(buf_str);               //counting error

   91: O18:=strtofloat(buf_str);                    //O18:Stable isotop of oxygen 18
   92: O18_pQF1:=trunc(strtofloat(buf_str));        //pQF1

   93: toc:=strtofloat(buf_str);                    //toc:Total organic carbon
   94: toc_pQF1:=trunc(strtofloat(buf_str));        //pQF1

   95: doc:=strtofloat(buf_str);                    //doc:Dissolved organic carbon
   96: doc_pQF1:=trunc(strtofloat(buf_str));        //pQF1

   97: don:=strtofloat(buf_str);                    //don:Dissolved organic nitrogen
   98: don_pQF1:=trunc(strtofloat(buf_str));        //pQF1

   99: tdn:=strtofloat(buf_str);                    //tdn:Total dissolved nitrogen
  100: tdn_pQF1:=trunc(strtofloat(buf_str));        //pQF1

  101: chla:=strtofloat(buf_str);                    //chla:chlorophylla
  102: chla_pQF1:=trunc(strtofloat(buf_str));        //pQF1
    end;{case}

{kv}end;

{b}end;

    //dates
    //stDate:=EncodeDate(year,month,day);
    //stTime:=EncodeTime(hour,min,0,0);
    //ODBPr_ConvertDateTime(year,month,day,hour,min,StDate,StTime,MonthErr,TimeErr);
    StDT:= procedures.DateEncode(Year,Month,Day,Hour,Min,DayChange,DateChange);
    if DayChange=true then memo1.Lines.Add('Day was changed in line='
                           +inttostr(line)
                           +'  '+inttostr(day)+'.'+inttostr(month)+'.'+inttostr(year)
                           +'  '+inttostr(hour)+':'+inttostr(min));
    if DateChange=true then memo1.Lines.Add('Date was changed in line='
                           +inttostr(line)
                           +'  '+inttostr(day)+'.'+inttostr(month)+'.'+inttostr(year)
                           +'  '+inttostr(hour)+':'+inttostr(min));


      writeln(out,inttostr(RSt),
      #9,inttostr(line),
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

//write MD into GLODAPv2_2019_PRODUCT.FDB
{w}if CheckBox1.Checked then begin

     StVersion:=1;
   with frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' Select count(ID) as CountDup from STATION ');
      SQL.Add(' where DATEANDTIME=:stDT and ');
      SQL.Add(' Latitude=:stlat and Longitude=:stlon ');
      ParamByName('stDT').AsDateTime:=stDT;
      ParamByName('stlat' ).Asfloat:=stlat;
      ParamByName('stlon' ).AsFloat:=stlon;
      Open;
        CountDup:=FieldByName('CountDup').AsInteger;
      Close;
   end;

     if CountDup>0 then begin
       StVersion:=CountDup+1;
     end;

     //memo1.Lines.Add(inttostr(RSt)+#9+datetimetostr(NOW));

   (* Last level from dbar to meters *)
   stLLM:=declarations_gsw.gsw_z_from_p(stPDS, stlat);

   with frmdm.q2 do begin
     Close;
      SQL.Clear;
      SQL.Add(' INSERT INTO STATION ' );
      SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, BOTTOMDEPTH, LASTLEVEL_M, ' );
      SQL.Add('  LASTLEVEL_DBAR, CRUISE_ID, INSTRUMENT_ID, STATIONID, STATIONID_ORIG, ' );
      SQL.Add('  QCFLAG, STVERSION, MERGED, DATE_ADDED, DATE_UPDATED ) ' );
      SQL.Add(' VALUES ' );
      SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :BOTTOMDEPTH, :LASTLEVEL_M, ' );
      SQL.Add('  :LASTLEVEL_DBAR, :CRUISE_ID, :INSTRUMENT_ID, :STATIONID, :STATIONID_ORIG, ' );
      SQL.Add('  :QCFLAG, :STVERSION, :MERGED, :DATE_ADDED, :DATE_UPDATED ) ' );
      ParamByName('ID'            ).Value:=RSt-1;
      ParamByName('LATITUDE'      ).Value:=stlat;
      ParamByName('LONGITUDE'     ).Value:=stlat;
      ParamByName('DATEANDTIME'   ).Value:=stDT;
      ParamByName('BOTTOMDEPTH'   ).Value:=stBD;
      ParamByName('LASTLEVEL_M'   ).Value:=stLLM;
      ParamByName('LASTLEVEL_DBAR').Value:=stPDS;
      ParamByName('CRUISE_ID'     ).Value:=cruiseN;
      ParamByName('INSTRUMENT_ID' ).Value:=7; //bottle type unknown
      ParamByName('STATIONID'     ).Value:='';
      ParamByName('STATIONID_ORIG').Value:=stationN;
      ParamByName('QCFLAG'        ).Value:=0;
      ParamByName('STVERSION'     ).Value:=stversion;
      ParamByName('MERGED'        ).Value:=0;
      ParamByName('DATE_ADDED'    ).Value:=Now;
      ParamByName('DATE_UPDATED'  ).Value:=Now;
     ExecSQL;
   end;

      frmdm.TR.CommitRetaining;

{w}end;



{MD}end;

//{r}until eof(dat);
//{w}end;
{i}end; {lines }

   CloseFile(dat);
   CloseFile(out);
   //last line in file
   RSt:=RSt+1;
   line_arr[RSt]:=LinesInFile;


   memo1.Lines.Add('End of file');
   memo1.Lines.Add('cruises#       ='+inttostr(cruise_count));
   memo1.Lines.Add('stations#      ='+inttostr(station_count));
   memo1.Lines.Add('casts#         ='+inttostr(cast_count));
   memo1.Lines.Add('cast max       ='+inttostr(cast_max));
   memo1.Lines.Add('Real Stations# ='+inttostr(RSt));

   btnDownloadData.Visible:=true;

//showmessage('L1 L2:  '+inttostr(line_arr[1])+'  '+inttostr(line_arr[2]));
}
end;




//split file on MD and Profiles/casts
procedure TfrmloadGLODAP_2019_v2_product.btnSplitOnMDandProfilesClick(
  Sender: TObject);
var
  kst,kL,kv,L1,L2,n,c,i,line:integer;
  kTT:integer;
  cruiseN,stationN,castN,stNBNum:integer;
  cast_maxN,PRF_count:integer;
  Year,Month,Day,Hour,Min:integer;
  stlat,stlon,stBD,stPDS,stMDS:real;
  symbol:char;
  st,buf_str:string;
  str_MD,str_PRF:string;
  StDT:TDateTime;
  DayChange,DateChange:Boolean;

  //values
  press,temp,salt,oxy,aou,nat,nit,sil,pho,tco2,talk,phts25p0,phtsinsitutp:real;
  cfc11,pcfc11,cfc12,pcfc12,cfc113,pcfc113,cc14,pcc14,sf6,psf6,c13,c14:real;
  h3,he3,he,neon,O18,toc,doc,don,tdn,chla:real;
  //errors
  c14_err,h3_err,he3_err,he_err,neon_err:real;
  //QF primary 1
  salt_pQF1,oxy_pQF1,aou_pQF1,nat_pQF1,nit_pQF1,sil_pQF1,pho_pQF1:integer;
  tco2_pQF1,talk_pQF1,phtsinsitutp_pQF1,cfc11_pQF1,cfc12_pQF1,cfc113_pQF1:integer;
  cc14_pQF1,c13_pQF1,c14_pQF1,h3_pQF1,he3_pQF1,he_pQF1,neon_pQF1:integer;
  O18_pQF1,toc_pQF1,doc_pQF1,don_pQF1,tdn_pQF1,chla_pQF1,phts25p0_pQF1:integer;
  //QF secondary
  salt_sQF,oxy_sQF,nat_sQF,sil_sQF,pho_sQF,tco2_sQF,talk_sQF,phtsinsitutp_sQF:integer;
  cfc11_sQF,cfc12_sQF,cfc113_sQF,cc14_sQF,sf6_pQF1,c13_sQF,phts25p0_sQF:integer;
  //divide file on stations/casts
  cast_count:Integer;
  //download
  CountDup,StVersion:integer;


begin

//three GLODAP tables types
{TT}for kTT:=1 to 3 do begin

  //CDS Divide Station on Casts
   CDS_DSC:=TBufDataSet.Create(self);
  with CDS_DSC.FieldDefs do begin
    Add('ID',  ftInteger,0,true);
    Add('Press', ftFloat,0,true);
    Add('Val', ftFloat,0,true);
    if kTT=2 then Add('PVal', ftFloat,0,true);
    if kTT=3 then Add('ValErr', ftFloat,0,true);
    Add('PQF1',  ftInteger,0,true);
    Add('PQF2',  ftInteger,0,true);
    Add('SQF', ftInteger, 0,true);
    Add('Bottle',  ftInteger,0,true);
    Add('Station',  ftInteger,0,true);
    Add('Units_ID',  ftInteger,0,true);
  end;
   CDS_DSC.CreateDataSet;

   str_MD:='ID LATITUDE LONGITUDE DATEANDTIME BOTTOMDEPTH LASTLEV_M LASTLEV_DBAR ' +
   'CRUISE_ID INSTRUMENT_ID STATION_NUM_ORIGin STATION_ID_ORIGin CAST_NUMBER ' +
   'QFLAG STVERSION MERGED DATE_ADDED DATE_UPDATED';

   //DB TBL Type1 fields:8 PRES VAL
   //DB TBL Type2 fields:9 PRES VAL PVAL
   //DB TBL Type3 fields:9 PRES VALERR PVAL
   if kTT=1 then str_PRF:='ID PRES VAL PQF1 PQF2 SQF BOTTLE_NUMBER UNITS_ID';
   if kTT=2 then 'ID PRES VAL PVAL PQF1 PQF2 SQF BOTTLE_NUMBER UNITS_ID';
   if kTT=3 then 'ID PRES VAL PVAL PQF1 PQF2 SQF BOTTLE_NUMBER UNITS_ID';

   path_MD:='c:\Users\ako071\AK\datasets\GLODAP\download\STATION.dat';
   AssignFile(outMD, path_MD); Rewrite(outMD);
   writeln(outMD,str_MD);

   path_PRF:='c:\Users\ako071\AK\datasets\GLODAP\download\P_TEMPERATURE_BOTTLE.dat';
   AssignFile(outPRF, path_PRF); Rewrite(outPRF);
   writeln(outPRF,str_PRF1);


   Reset(dat);
   readln(dat, st);


   line:=1;
   PRF_count:=0;
{st}for kst:=1 to RSt-1 do begin

   if CDS_DSC.Active then CDS_DSC.Close;
     CDS_DSC.Open;

     L1:=line_arr[kst];      //station begin
     L2:=line_arr[kst+1]-1;  //station end

     //memo1.Lines.Add('kst='+inttostr(kst)+'   L1:'+inttostr(L1)+'->'+inttostr(L2));

{L}for kL:=L1 to L2 do begin    //file scroll
     readln(dat, st);
     st:=trim(st);
     line:=line+1;


{pr}if (line>=L1) and (line<=L2) then begin  //inside profile

//showmessage('L1->L2:'+inttostr(L1)+'->'+inttostr(L2)+'  line='+inttostr(line));


//string analysis
      n:=0;
{kv}for kv:=1 to var_num do begin
      buf_str:='';
{s}repeat
      inc(n);
      symbol:=st[n];
      if (symbol<>',') then buf_str:=buf_str+symbol;
{s}until (symbol=',') or (n=length(st));

 {b}if buf_str<>'' then begin
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

    30: aou:=strtofloat(buf_str);                    //apparant oxygen utilization
    31: aou_pQF1:=trunc(strtofloat(buf_str));        //pQF1

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

    43: tco2:=strtofloat(buf_str);                    //tco2:Dissolved inorganic carbon
    44: tco2_pQF1:=trunc(strtofloat(buf_str));        //pQF1
    45: tco2_sQF:=trunc(strtofloat(buf_str));         //sQF

    46: talk:=strtofloat(buf_str);                    //talk
    47: talk_pQF1:=trunc(strtofloat(buf_str));        //pQF1
    48: talk_sQF:=trunc(strtofloat(buf_str));         //sQF

    49: phts25p0:=strtofloat(buf_str);                    //ph ts 25 p0
    50: phts25p0_pQF1:=trunc(strtofloat(buf_str));        //pQF1
    53: begin
         phts25p0_sQF:=trunc(strtofloat(buf_str));         //sQF
         phtsinsitutp_sQF:=trunc(strtofloat(buf_str));         //sQF
        end;

    51: phtsinsitutp:=strtofloat(buf_str);                    //ph ts insitu tp
    52: phtsinsitutp_pQF1:=trunc(strtofloat(buf_str));        //pQF1

    54: cfc11:=strtofloat(buf_str);                    //cfc11:transient tracer
    55: pcfc11:=strtofloat(buf_str);                   //pcfc11
    56: cfc11_pQF1:=trunc(strtofloat(buf_str));        //pQF1
    57: cfc11_sQF:=trunc(strtofloat(buf_str));         //sQF

    58: cfc12:=strtofloat(buf_str);                    //cfc12:transient tracer
    59: pcfc12:=strtofloat(buf_str);                   //pcfc12
    60: cfc12_pQF1:=trunc(strtofloat(buf_str));        //pQF1
    61: cfc12_sQF:=trunc(strtofloat(buf_str));         //sQF

    62: cfc113:=strtofloat(buf_str);                    //cfc113:transient tracer
    63: pcfc113:=strtofloat(buf_str);                   //pcfc113
    64: cfc113_pQF1:=trunc(strtofloat(buf_str));        //pQF1
    65: cfc113_sQF:=trunc(strtofloat(buf_str));         //sQF

    66: cc14:=strtofloat(buf_str);                    //cc14:transient tracer
    67: pcc14:=strtofloat(buf_str);                   //pcc14
    68: cc14_pQF1:=trunc(strtofloat(buf_str));        //pQF1
    69: cc14_sQF:=trunc(strtofloat(buf_str));         //sQF

    70: sf6:=strtofloat(buf_str);                    //sf6:Sulfur hexafluoride
    71: psf6:=strtofloat(buf_str);                   //psf6
    72: sf6_pQF1:=trunc(strtofloat(buf_str));        //pQF1

    73: c13:=strtofloat(buf_str);                    //c13 Stable isotop carbon 13
    74: c13_pQF1:=trunc(strtofloat(buf_str));        //pQF1
    75: c13_sQF:=trunc(strtofloat(buf_str));         //sQF

    76: c14:=strtofloat(buf_str);                   //c14 Radioisotop carbon 14
    77: c14_pQF1:=trunc(strtofloat(buf_str));       //pQF1
    78: c14_err:=strtofloat(buf_str);               //counting error

    79: h3:=strtofloat(buf_str);                   //h3:radioisotop hydrogen 3, Tritium
    80: h3_pQF1:=trunc(strtofloat(buf_str));       //pQF1
    81: h3_err:=strtofloat(buf_str);               //counting error

    82: he3:=strtofloat(buf_str);                   //he3:Radioisotop helium 3
    83: he3_pQF1:=trunc(strtofloat(buf_str));       //pQF1
    84: he3_err:=strtofloat(buf_str);               //counting error

    85: he:=strtofloat(buf_str);                    //he:helium
    86: he_pQF1:=trunc(strtofloat(buf_str));       //pQF1
    87: he_err:=strtofloat(buf_str);               //counting error

    88: neon:=strtofloat(buf_str);                    //neon
    89: neon_pQF1:=trunc(strtofloat(buf_str));       //pQF1
    90: neon_err:=strtofloat(buf_str);               //counting error

    91: O18:=strtofloat(buf_str);                    //O18:Stable isotop of oxygen 18
    92: O18_pQF1:=trunc(strtofloat(buf_str));        //pQF1

    93: toc:=strtofloat(buf_str);                    //toc:Total organic carbon
    94: toc_pQF1:=trunc(strtofloat(buf_str));        //pQF1

    95: doc:=strtofloat(buf_str);                    //doc:Dissolved organic carbon
    96: doc_pQF1:=trunc(strtofloat(buf_str));        //pQF1

    97: don:=strtofloat(buf_str);                    //don:Dissolved organic nitrogen
    98: don_pQF1:=trunc(strtofloat(buf_str));        //pQF1

    99: tdn:=strtofloat(buf_str);                    //tdn:Total dissolved nitrogen
   100: tdn_pQF1:=trunc(strtofloat(buf_str));        //pQF1

   101: chla:=strtofloat(buf_str);                    //chla:chlorophylla
   102: chla_pQF1:=trunc(strtofloat(buf_str));        //pQF1
    end;{case}

{b}end;

{kv}end;
//end string analysis

   //number of tables depending on table type
   if (kTT=1) then TNum:=19;
   if (kTT=2) then TNum:=5;
   if (kTT=3) then TNum:=5;

   TPQF1:=0;
   TPQF2:=0;
   TSQF:=0;

   //UNITS indexes from TBD UNITS
   //1 Degree centigrade
   //3 Micro-mole per kilogram

{TN}for kTN:=1 to TNum

   if (kTT) =1 then begin
   case kTN of
   1: begin
      TName:='P_AOF_BOTTLE';
      Tval:=aou;
      TPQF1:=aou_pQF1;
      TBottle:=stNBNum;
      TUNIT:=3; //Micro-mole per kilogram
      end; {1}
   2: begin
      TName:='P_C13_BOTTLE';
      Tval:=c13;
      TPQF1:=c13_pQF1;
      TSQF:=c13_SQF;
      TBottle:=stNBNum;
      TUNIT:=11; //Per-mille deviation
      end; {2}
   3: begin
      TName:='P_CHLA_BOTTLE';
      Tval:=chla;
      TPQF1:=chla_pQF1;
      TBottle:=stNBNum;
      TUNIT:=14;  //Micro-gram per kilogram
      end;
   4: begin
      TName:='P_DOC_BOTTLE';
      Tval:=doc;
      TPQF1:=doc_pQF1;
      TBottle:=stNBNum;
      TUNIT:=15;  //Micro-gram per liter
      end;
   5: begin
      TName:='P_DON_BOTTLE';
      Tval:=don;
      TPQF1:=don_pQF1;
      TBottle:=stNBNum;
      TUNIT:=15;  //Micro-gram per liter
      end;
   6: begin
      TName:='P_NITRATE_BOTTLE';
      Tval:=nat;
      TPQF1:=nat_pQF1;
      TSQF:=nat_SQF;
      TBottle:=stNBNum;
      TUNIT:=3;  //Micro-mole per kilogram
      end;
   7: begin
      TName:='P_NITRITE_BOTTLE';
      Tval:=nit;
      TPQF1:=nit_pQF1;
      TBottle:=stNBNum;
      TUNIT:=3;  //Micro-mole per kilogram
      end;
   8: begin
      TName:='P_018_BOTTLE';
      Tval:=O18;
      TPQF1:=O18_pQF1;
      TBottle:=stNBNum;
      TUNIT:=11;  //Per-mille deviation
      end;
   9: begin
      TName:='P_OXYGEN_BOTTLE';
      Tval:=oxy;
      TPQF1:=oxy_pQF1;
      TSQF:=oxy_SQF;
      TBottle:=stNBNum;
      TUNIT:=3;  //Micro-mole per kilogram
      end;
   10: begin
       TName:='P_PHOSPHATE_BOTTLE';
       Tval:=pho;
       TPQF1:=pho_pQF1;
       TSQF:=pho_SQF;
       TBottle:=stNBNum;
       TUNIT:=3;  //Micro-mole per kilogram
       end;
   11: begin
       TName:='P_PHTS25P0_BOTTLE';
       Tval:=phts25p0;
       TPQF1:=phts25p0_pQF1;
       TSQF:=phts25p0_SQF;
       TBottle:=stNBNum;
       TUNIT:=2;  //Dimensionless or unit less
       end;
   12: begin
       TName:='P_PHTSINSITUTP_BOTTLE';
       Tval:=phtsinsitutp;
       TPQF1:=phtsinsitutp_pQF1;
       TSQF:=phtsinsitutp_SQF;
       TBottle:=stNBNum;
       TUNIT:=2;  //Dimensionless or unit less
       end;
   13: begin
       TName:='P_SALINITY_BOTTLE';
       Tval:=salt;
       TPQF1:=salt_pQF1;
       TSQF:=salt_SQF;
       TBottle:=stNBNum;
       TUNIT:=2;  //Dimensionless or unit less
       end;
   14: begin
       TName:='P_SILICATE_BOTTLE';
       Tval:=sil;
       TPQF1:=sil_pQF1;
       TSQF:=sil_SQF;
       TBottle:=stNBNum;
       TUNIT:=3;  //Micro-mole per kilogram
       end;
   15: begin
       TName:='P_TALK_BOTTLE';
       Tval:=talk;
       TPQF1:=talk_pQF1;
       TSQF:=talk_SQF;
       TBottle:=stNBNum;
       TUNIT:=3;  //Micro-mole per kilogram
       end;
   16: begin
       TName:='P_TCO2_BOTTLE';
       Tval:=tco2;
       TPQF1:=tco2_pQF1;
       TSQF:=tco2_SQF;
       TBottle:=stNBNum;
       TUNIT:=3;  //Micro-mole per kilogram
       end;
   17: begin
       TName:='P_TDN_BOTTLE';
       Tval:=tdn;
       TPQF1:=tdn_pQF1;
       TBottle:=stNBNum;
       TUNIT:=15;  //Micro-mole per liter
       end;
   18: begin
       TName:='P_TOC_BOTTLE';
       Tval:=toc;
       TPQF1:=toc_pQF1;
       TBottle:=stNBNum;
       TUNIT:=15;  //Micro-mole per liter
       end;
   19: begin
       TName:='P_TEMPERATURE_BOTTLE';
       Tval:=temp;
       TBottle:=stNBNum;
       TUNIT:=1;  //Degree centigrade
       end;
   end;

   if (kTT) =2 then begin
   case kTN of
   1: TName:='P_CC14_BOTTLE';
   2: TName:='P_CFC113_BOTTLE';
   3: TName:='P_CFC11_BOTTLE';
   4: TName:='P_CFC12_BOTTLE';
   5: TName:='P_SF6_BOTTLE';
   end;

   if (kTT) =3 then begin
   case kTN of
   1: TName:='P_C14_BOTTLE';
   2: TName:='P_HE3_BOTTLE';
   3: TName:='P_HE_BOTTLE';
   4: TName:='P_NEON_BOTTLE';
   5: TName:='P_H3_BOTTLE';
   end;


  //append to CDS
  with CDS_DSC do begin
     Append;
     FieldByName('ID').AsInteger:=kst;
     FieldByName('Press').AsFloat:=press;
     FieldByName('Val').AsFloat:=temp;
     if (kTT=2) then  FieldByName('PVal').AsFloat:=temp;
     if (kTT=3) then  FieldByName('ValErr').AsFloat:=temp;
     FieldByName('PQF1').AsInteger:=0;
     FieldByName('PQF2').AsInteger:=0;
     FieldByName('SQF').AsInteger:=0;
     FieldByName('Bottle').AsInteger:=stNBNum;
     FieldByName('Station').AsInteger:=stationN;
     FieldByName('Units_ID').AsInteger:=1; //temperature
     Post;
  end;



{pr}end;{inside profiles}
{L} end; {lines loop}

  StDT:= procedures.DateEncode(Year,Month,Day,Hour,Min,DayChange,DateChange);

//determine max number of casts at stations
    CDS_DSC.First;
    cast_maxN:=CDS_DSC.FieldByName('Cast').AsInteger;
{s}while not CDS_DSC.EOF do begin
    if cast_maxN<CDS_DSC.FieldByName('Cast').AsInteger
    then cast_maxN:=CDS_DSC.FieldByName('Cast').AsInteger;
    CDS_DSC.Next;
{s}end;



  //divide station on casts
{c}for c:=1 to cast_maxN do begin
    CDS_DSC.Filter:='CAST='+inttostr(c);
    CDS_DSC.Filtered:=true;

    CDS_DSC.IndexFieldNames:='Press';  //sort by press


{i}if CDS_DSC.IsEmpty=false then begin
    CDS_DSC.First;
    PRF_count:=PRF_count+1;

    //convert pressure to depth
    //m=1 pressure to depth
    //Depth_to_Pressure(stPDS,stlat,1,stLastLevel_m);
    stMDS:=declarations_gsw.gsw_z_from_p(stPDS,stlat);


    //prepare to write into STATION
    writeln(outMD,inttostr(PRF_count),  //ID
    #9,floattostr(stlat),       //LATITUDE
    #9,floattostr(stlon),       //LONGITUDE
    #9,datetimetostr(StDT),    //DATEANDTIME
    #9,floattostr(stBD),        //BOTTOMDEPTH
    #9,floattostr(stMDS),        //LASTLEVEL_M   !!!CONVERT
    #9,floattostr(stPDS),        //LASTLEVEL_DBAR
    #9,inttostr(CruiseN),        //CRUISEID
    #9,inttostr(StationN),        //ST_NUM_ORIGIN
    #9,inttostr(StationN),        //ST_ID_ORIGIN
    #9,inttostr(castN),           //CAST_NUMBER
    #9,inttostr(1),               //QCFLAG
    #9,inttostr(1),               //STVERSION
    #9,datetimetostr(NOW),        //DATE_ADDED
    #9,datetimetostr(NOW));      //DATE_UPDATED


{s}while not CDS_DSC.EOF do begin

  //prepare variable table  !!! make TABLES NAMES IN CYCLE
  writeln(outPRF,inttostr(PRF_count),                      //ID
  #9,floattostr(CDS_DSC.FieldByName('press').AsFloat),     //PRESS
  #9,floattostr(CDS_DSC.FieldByName('val').AsFloat),       //VAL
  #9,inttostr(CDS_DSC.FieldByName('PQF1').AsInteger),      //PQF1
  #9,inttostr(CDS_DSC.FieldByName('PQF2').AsInteger),      //PQF2
  #9,inttostr(CDS_DSC.FieldByName('PQF2').AsInteger),      //SQF
  #9,inttostr(CDS_DSC.FieldByName('Bottle').AsInteger),    //BOTTLE_NUMBER
  #9,inttostr(CDS_DSC.FieldByName('Cast').AsInteger),      //CAST_NUMBER
  #9,inttostr(CDS_DSC.FieldByName('UNITS_ID').AsInteger)); //UNITS_ID

    CDS_DSC.Next;
{s}end; //filtered by cast number and sorted station
{i}end; //if cast exists
{c}end; //casts

     CDS_DSC.Filtered:=false;
     //CDS_DSC.Close;
     //CDS_DSC.Clear;
     //CDS_DSC.Active:=false;
{st}end; //real stations loop

{TN}end; //GLODAP tables depending on type 19,5,5
{TT}end; //three GLODAP table types


  if CDS_DSC.Active=true then CDS_DSC.Close;
     CDS_DSC.Free;

     closefile(outMD);
     closefile(outPRF);

     memo1.Lines.Add('Profiles in file: '+inttostr(PRF_count));
     memo1.Lines.Add('Spliting completed');

     CheckBox1.Visible:=true;
     btnDownloadMD.Visible:=true;
     btnDownloadData.Visible:=true;
end;





procedure TfrmloadGLODAP_2019_v2_product.btnDownloadDataClick(Sender: TObject);
var
  kst,kl,kv,line,L1,L2,n,c,i:integer;
  cruiseN,stationN,castN,stNBNum:integer;
  cast_maxN:integer;
  Year,Month,Day,Hour,Min:integer;
  press, temp,stlat,stlon,stBD,stPDS:real;
  symbol:char;
  st,buf_str:string;
  StDT:TDateTime;
  DayChange,DateChange:Boolean;

begin

   //CDS Divide Station on Casts
    CDS_DSC:=TBufDataSet.Create(self);
   with CDS_DSC.FieldDefs do begin
     Add('ID',  ftInteger,0,true);
     Add('Press', ftFloat,0,true);
     Add('Val', ftFloat,0,true);
     Add('PQF1',  ftInteger,0,true);
     Add('PQF2',  ftInteger,0,true);
     Add('SQF', ftInteger, 0,true);
     Add('Bottle',  ftInteger,0,true);
     Add('Station',  ftInteger,0,true);
     Add('Cast',  ftInteger,0,true);
     Add('Units_ID',  ftInteger,0,true);
   end;
    CDS_DSC.CreateDataSet;


   path_out:='c:\Users\ako071\AK\datasets\GLODAP\output_profiles.dat';
   AssignFile(out, Path_out); Rewrite(out);
   writeln(out,'RSt#  L1  L2  line#  cruise  station  cast  bottle#  press  temp');


   Reset(dat);
   readln(dat, st);
   line:=1;


//first prepare data for one table P_TEMPERATURE_BOTTLE
{st}for kst:=1 to RSt do begin

    if CDS_DSC.Active then CDS_DSC.Close;
      CDS_DSC.Open;

      L1:=line_arr[kst];
      L2:=line_arr[kst+1]-1;

      memo1.Lines.Add('kst='+inttostr(kst)+'   L1:'+inttostr(L1)+'->'+inttostr(L2));

{L}for kl:=L1 to L2 do begin    //file scroll
      readln(dat, st);
      st:=trim(st);
      line:=line+1;


{pr}if (line>=L1) and (line<=L2) then begin  //inside profile

//showmessage('L1->L2:'+inttostr(L1)+'->'+inttostr(L2)+'  line='+inttostr(line));


//string analysis
       n:=0;
{kv}for kv:=1 to var_num do begin
       buf_str:='';
{s}repeat
       inc(n);
       symbol:=st[n];
       if (symbol<>',') then buf_str:=buf_str+symbol;
{s}until (symbol=',') or (n=length(st));

  {b}if buf_str<>'' then begin
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
      end;{case}
  {b}end;

  {kv}end;
//end string analysis


   //append to CDS
   with CDS_DSC do begin
      Append;
      FieldByName('ID').AsInteger:=kst;
      FieldByName('Press').AsFloat:=press;
      FieldByName('Val').AsFloat:=temp;
      FieldByName('PQF1').AsInteger:=0;
      FieldByName('PQF2').AsInteger:=0;
      FieldByName('SQF').AsInteger:=0;
      FieldByName('Bottle').AsInteger:=stNBNum;
      FieldByName('Station').AsInteger:=stationN;
      FieldByName('Cast').AsInteger:=castN;
      FieldByName('Units_ID').AsInteger:=1; //temperature
      Post;
   end;



{pr}end;{inside profiles}
{L} end; {lines loop}

   StDT:= procedures.DateEncode(Year,Month,Day,Hour,Min,DayChange,DateChange);

//determine max number of casts at stations
     CDS_DSC.First;
     cast_maxN:=CDS_DSC.FieldByName('Cast').AsInteger;
{s}while not CDS_DSC.EOF do begin
     if cast_maxN<CDS_DSC.FieldByName('Cast').AsInteger
     then cast_maxN:=CDS_DSC.FieldByName('Cast').AsInteger;
     CDS_DSC.Next;
{s}end;



   //divide station on casts
{c}for c:=1 to cast_maxN do begin
     CDS_DSC.Filter:='CAST='+inttostr(c);
     CDS_DSC.Filtered:=true;

     CDS_DSC.IndexFieldNames:='Press';  //sort by press


{i}if CDS_DSC.IsEmpty=false then begin
     CDS_DSC.First;


     writeln(out,'...new Real Station: '+inttostr(kst)
     +'  date: '+datetimetostr(StDT)
     +'  lat: '+floattostr(stlat)
     +'  lon: '+floattostr(stlon)
     +'  BD : '+floattostr(stBD)
     +'  PDS: '+floattostr(stPDS)
     );

     {writeln(out,inttostr(kst),
       #9+inttostr(L1),
       #9+inttostr(L2),
       #9,inttostr(line),
       #9,inttostr(cruiseN));}


{s}while not CDS_DSC.EOF do begin

   writeln(out,inttostr(kst),
   #9,inttostr(cruiseN),
   #9,inttostr(CDS_DSC.FieldByName('Station').AsInteger),
   #9,inttostr(CDS_DSC.FieldByName('Cast').AsInteger),
   #9,inttostr(CDS_DSC.FieldByName('Bottle').AsInteger),
   #9,floattostr(CDS_DSC.FieldByName('press').AsFloat),
   #9,floattostr(CDS_DSC.FieldByName('val').AsFloat));

     CDS_DSC.Next;
{s}end; //filtered by cast number and sorted station
{i}end; //if cast exists
{c}end; //casts

      CDS_DSC.Filtered:=false;
      //CDS_DSC.Close;
      //CDS_DSC.Clear;
      //CDS_DSC.Active:=false;
{st}end; //real stations loop

   if CDS_DSC.Active=true then CDS_DSC.Close;
      CDS_DSC.Free;
      closefile(out);

      memo1.Lines.Add('');
      memo1.Lines.Add('Loading completed');
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
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
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

     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (1, '+QuotedStr('P_TEMPERATURE_BOTTLE')+','  +QuotedStr('TEMPERATURE')+','+QuotedStr('Sea water temperture')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (2, '+QuotedStr('P_SALINITY_BOTTLE')+','     +QuotedStr('SALINITY')+','   +QuotedStr('Sea water salinity')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (3, '+QuotedStr('P_OXYGEN_BOTTLE')+','       +QuotedStr('OXYGEN')+','     +QuotedStr('Dissolved Oxygen')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (4, '+QuotedStr('P_AOU_BOTTLE')+','          +QuotedStr('AOU')+','        +QuotedStr('Apparent oxygen utilization')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (5, '+QuotedStr('P_NITRATE_BOTTLE')+','      +QuotedStr('NITRATE')+','    +QuotedStr('Nitrate')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (6, '+QuotedStr('P_NITRITE_BOTTLE')+','      +QuotedStr('NITRITE')+','    +QuotedStr('Nitrite')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (7, '+QuotedStr('P_SILICATE_BOTTLE')+','     +QuotedStr('SILICATE')+','   +QuotedStr('Silicate')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (8, '+QuotedStr('P_PHOSPHATE_BOTTLE')+','    +QuotedStr('PHOSPHATE')+','  +QuotedStr('Phosphate')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (9, '+QuotedStr('P_TCO2_BOTTLE')+','         +QuotedStr('TCO2')+','       +QuotedStr('Dissolved inorganic carbon')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (10, '+QuotedStr('P_TALK_BOTTLE')+','        +QuotedStr('TALK')+','       +QuotedStr('Total alkalinity')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (11, '+QuotedStr('P_PHTS25P0_BOTTLE')+','    +QuotedStr('PH')+','         +QuotedStr('pH on total scale, 25C, 0dbar')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (12, '+QuotedStr('P_PHTSINSITUTP_BOTTLE')+','+QuotedStr('PH')+','         +QuotedStr('pH on total scale, in situ temperature and pressure')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (13, '+QuotedStr('P_CFC11_BOTTLE')+','       +QuotedStr('CFC11')+','      +QuotedStr('Halogenated transient tracer CFC11, partial pressure')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (14, '+QuotedStr('P_CFC12_BOTTLE')+','       +QuotedStr('CFC12')+','      +QuotedStr('Halogenated transient tracer CFC12, partial pressure')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (15, '+QuotedStr('P_CFC113_BOTTLE')+','      +QuotedStr('CFC113')+','     +QuotedStr('Halogenated transient tracer CFC113, partial pressure')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (16, '+QuotedStr('P_CC14_BOTTLE')+','        +QuotedStr('CC14,')+','      +QuotedStr('Halogenated transient tracer CC14, partial pressure')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (17, '+QuotedStr('P_SF6_BOTTLE')+','         +QuotedStr('SF6,')+','       +QuotedStr('Sulfur hexafluoride, partial pressure')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (18, '+QuotedStr('P_C13_BOTTLE')+','         +QuotedStr('C13,')+','       +QuotedStr('Stable isotop carbon 13')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (19, '+QuotedStr('P_C14_BOTTLE')+','         +QuotedStr('C14,')+','       +QuotedStr('Radioisotop carbon 14, counting error')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (20, '+QuotedStr('P_H3_BOTTLE')+','          +QuotedStr('H3,')+','        +QuotedStr('Radioisotop hydrogen 3, tritium')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (21, '+QuotedStr('P_HE3_BOTTLE')+','         +QuotedStr('HE3,')+','       +QuotedStr('Radioisotop helium 3, counting error')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (22, '+QuotedStr('P_HE_BOTTLE')+','          +QuotedStr('HE,')+','        +QuotedStr('Helium, counting error')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (23, '+QuotedStr('P_NEON_BOTTLE')+','        +QuotedStr('NEON,')+','      +QuotedStr('Neon, counting error')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (24, '+QuotedStr('P_O18_BOTTLE')+','         +QuotedStr('O18,')+','       +QuotedStr('Stable isotop of oxygen 18')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (25, '+QuotedStr('P_TOC_BOTTLE')+','         +QuotedStr('TOC,')+','       +QuotedStr('Total organic carbon')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (26, '+QuotedStr('P_DOC_BOTTLE')+','         +QuotedStr('DOC,')+','       +QuotedStr('Dissolved organic carbon')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (27, '+QuotedStr('P_DON_BOTTLE')+','         +QuotedStr('DON,')+','       +QuotedStr('Dissolved organic nitrogen')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (28, '+QuotedStr('P_TDN_BOTTLE')+','         +QuotedStr('TDN,')+','       +QuotedStr('Total dissolved nitrogen')+'); '+LineEnding+
     'INSERT INTO DATABASE_TABLES (ID, TABLENAME, VARIABLENAME, DESCRIPTION) VALUES (29, '+QuotedStr('P_CHLA_BOTTLE')+','        +QuotedStr('CHLA,')+','      +QuotedStr('chlorophylla')+'); '+LineEnding+

     'COMMIT WORK '+LineEnding+
     'SET TERM ; '+LineEnding;

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

