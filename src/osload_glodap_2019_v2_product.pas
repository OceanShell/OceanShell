// GLODAPv2.2019 product download
//
// I. First file scroll btnDataSource
//    determining the number of variables in a file (102)
//    number of lines in file (1175007)
//    creation of an array of names on the first line (var_name[1..200])
//
// II.Second file scroll btnSaveStationMDonDisk
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
    btnSaveStationMDonDisk: TButton;
    btnCreateTables: TButton;
    btnDownloadData: TButton;
    btnSplitOnMDandProfiles: TButton;
    btnDownloadMD: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    procedure btnDataSourceClick(Sender: TObject);
    procedure btnDownloadMDClick(Sender: TObject);
    procedure btnDownloadDataClick(Sender: TObject);

    procedure btnSaveStationMDonDiskClick(Sender: TObject); //GLODAP stations with casts
    procedure btnCreateTablesClick(Sender: TObject);        //add variable tables to DB
    //неудачная попытка записать все за один проход текстового файла
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
  Dat, out, outMD :text;
  CDS_DSC1,CDS_DSC2:TBufDataSet; //CDS Divide stations on casts
  CDS_DSC:TBufDataSet; //ПОТОМ УБРАТЬ


  outPRF1,outPRF2,outPRF3,outPRF4,outPRF5,outPRF6,outPRF7,outPRF8,outPRF9:text;
  outPRF10,outPRF11,outPRF12,outPRF13,outPRF14,outPRF15,outPRF16,outPRF17:text;
  outPRF18,outPRF19,outPRF20,outPRF21,outPRF22,outPRF23,outPRF24,outPRF25:text;
  outPRF26,outPRF27,outPRF28,outPRF29,outPRF30,outPRF31,outPRF32,outPRF33:text;
  outPRF34:text;

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

     memo1.Lines.Add('Stations in file          :'+inttostr(RSt-1));
     GroupBox1.Visible:=true;
end;




procedure TfrmloadGLODAP_2019_v2_product.btnDownloadMDClick(Sender: TObject);
var
kst,kL,kv,kc,n:integer;
L1,L2:integer;
PRF_count,Cast_MaxN:integer;
cruiseN,stationN,castN,stNBNum,StVersion,countDup:integer;
Year,Month,Day,Hour,Min:integer;
stlat,stlon,stBD,stPDS,stMDS:real;
press:real;
symbol:char;
st,buf_str,str_MD,path_MD:string;
StDT:TDateTime;
DayChange,DateChange:boolean;
begin

 path_MD:='c:\Users\ako071\AK\datasets\GLODAP\download\STATION.dat';

 str_MD:='ID'+#9+'LATITUDE'+#9+'LONGITUDE'+#9+'DATEANDTIME'+#9+'BOTTOMDEPTH'
 +#9+'LASTLEV_M'+#9+'LASTLEV_DBAR'+#9+'CRUISE_ID'+#9+'INSTRUMENT_ID'
 +#9+'ST_NUM_ORIGIN'+#9+'ST_ID_ORIGIN'+#9+'CAST_NUMBER'
 +#9+'QCFLAG'+#9+'STVERSION'+#9+'MERGED'+#9+'DATE_ADDED'+#9+'DATE_UPDATED';

 AssignFile(outMD, path_MD); Rewrite(outMD);
 writeln(outMD,str_MD);

  //CDS Divide Station on Casts
   CDS_DSC:=TBufDataSet.Create(self);
  with CDS_DSC.FieldDefs do begin
    Add('ID',  ftInteger,0,true);
    Add('Press', ftFloat,0,true);
    Add('Bottle',  ftInteger,0,true);
    Add('Station',  ftInteger,0,true);
    Add('Cast',  ftInteger,0,true);
  end;
   CDS_DSC.CreateDataSet;
   Reset(dat);
   readln(dat, st);
   PRF_count:=0;
{ST}for kst:=1 to RSt-1 do begin  //GLODAP Stations

  if CDS_DSC.Active then CDS_DSC.Close;
    CDS_DSC.Open;


    L1:=line_arr[kst];      //station begin
    L2:=line_arr[kst+1]-1;  //station end
    //memo1.Lines.Add('kst='+inttostr(kst)+'   L1:'+inttostr(L1)+'->'+inttostr(L2));


{L}for kL:=L1 to L2 do begin    //GLODAP station
         readln(dat, st);
         st:=trim(st);


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
             end;{case}
         {b}end;

         {kv}end;
//end string analysis

   with CDS_DSC do begin
    Append;
    FieldByName('ID').AsInteger:=kst;
    FieldByName('Press').AsFloat:=press;
    FieldByName('Bottle').AsInteger:=stNBNum;
    FieldByName('Station').AsInteger:=stationN;
    FieldByName('Cast').AsInteger:=castN;
    Post;
  end;
{L}end;

   StDT:= procedures.DateEncode(Year,Month,Day,Hour,Min,DayChange,DateChange);

   CDS_DSC.First;
   Cast_MaxN:=CDS_DSC.FieldByName('Cast').AsInteger;
{s}while not CDS_DSC.EOF do begin
   if Cast_MaxN<CDS_DSC.FieldByName('Cast').AsInteger
   then Cast_MaxN:=CDS_DSC.FieldByName('Cast').AsInteger;
   CDS_DSC.Next;
{s}end;

{c}for kc:=1 to cast_maxN do begin
    CDS_DSC.Filter:='CAST='+inttostr(kc);
    CDS_DSC.Filtered:=true;               //filter by cast
    CDS_DSC.IndexFieldNames:='Press';     //sort by press

{CAST}if CDS_DSC.IsEmpty=false then begin

        //real last level for each profile
        CDS_DSC.Last;
        stPDS:=CDS_DSC.FieldByName('Press').AsFloat;

        //CDS_DSC.First;
        PRF_count:=PRF_count+1;

        StDT:= procedures.DateEncode(Year,Month,Day,Hour,Min,DayChange,DateChange);
        //TEOS: dbar to meters
        stMDS:=declarations_gsw.gsw_z_from_p(stPDS,stlat);
        stMDS:=-stMDS;

        //memo1.Lines.Add('ID='+inttostr(PRF_count)
        //+'   Cruise:'+inttostr(CruiseN)
        //+'  Station:'+inttostr(StationN)
        //+'  Cast:'+inttostr(CastN));

        //STATION
        writeln(outMD,inttostr(PRF_count),  //ID
        #9,floattostr(stlat),       //LATITUDE
        #9,floattostr(stlon),       //LONGITUDE
        #9,datetimetostr(StDT),    //DATEANDTIME
        #9,floattostr(stBD),        //BOTTOMDEPTH
        #9,floattostr(stMDS),        //LASTLEVEL_M   !!!CONVERT
        #9,floattostr(stPDS),        //LASTLEVEL_DBAR
        #9,inttostr(CruiseN),        //CRUISEID
        #9,inttostr(7),        //INSTRUMENT_ID
        #9,inttostr(StationN),        //ST_NUM_ORIGIN
        #9,inttostr(0),              //ST_ID_ORIGIN
        #9,inttostr(kc),           //CAST_NUMBER
        #9,inttostr(1),               //QCFLAG
        #9,inttostr(1),               //STVERSION
        #9,inttostr(1),               //MERGED
        #9,datetimetostr(NOW),        //DATE_ADDED
        #9,datetimetostr(NOW));      //DATE_UPDATED



//write MD into GLODAPv2_2019_PRODUCT.FDB
{wDB}if CheckBox1.Checked then begin

             StVersion:=0;
           with frmdm.q1 do begin
             Close;
              SQL.Clear;
              SQL.Add(' Select count(ID) as CountDup from STATION ');
              SQL.Add(' where DATEANDTIME=:stDT and ');
              SQL.Add(' Latitude=:stlat and Longitude=:stlon and CAST_NUMBER=:CAST_NUMBER ');
              ParamByName('stDT').AsDateTime:=stDT;
              ParamByName('stlat' ).Asfloat:=stlat;
              ParamByName('stlon' ).AsFloat:=stlon;
              ParamByName('CAST_NUMBER').AsInteger:=castN;
              Open;
                CountDup:=FieldByName('CountDup').AsInteger;
              Close;
           end;
             if CountDup>0 then StVersion:=CountDup+1;

           with frmdm.q2 do begin
             Close;
              SQL.Clear;
              SQL.Add(' INSERT INTO STATION ' );
              SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, BOTTOMDEPTH, LASTLEVEL_M, ' );
              SQL.Add('  LASTLEVEL_DBAR, CRUISE_ID, INSTRUMENT_ID, ST_NUMBER_ORIGIN, ST_ID_ORIGIN, ' );
              SQL.Add('  CAST_NUMBER, QCFLAG, STVERSION, MERGED, DATE_ADDED, DATE_UPDATED ) ' );
              SQL.Add(' VALUES ' );
              SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :BOTTOMDEPTH, :LASTLEVEL_M, ' );
              SQL.Add('  :LASTLEVEL_DBAR, :CRUISE_ID, :INSTRUMENT_ID, :ST_NUMBER_ORIGIN, :ST_ID_ORIGIN, ' );
              SQL.Add('  :CAST_NUMBER, :QCFLAG, :STVERSION, :MERGED, :DATE_ADDED, :DATE_UPDATED ) ' );
              ParamByName('ID'               ).Value:=PRF_count;
              ParamByName('LATITUDE'         ).Value:=stlat;
              ParamByName('LONGITUDE'        ).Value:=stlon;
              ParamByName('DATEANDTIME'      ).Value:=stDT;
              ParamByName('BOTTOMDEPTH'      ).Value:=stBD;
              ParamByName('LASTLEVEL_M'      ).Value:=stMDS;
              ParamByName('LASTLEVEL_DBAR'   ).Value:=stPDS;
              ParamByName('CRUISE_ID'        ).Value:=cruiseN;
              ParamByName('INSTRUMENT_ID'    ).Value:=7; //bottle type unknown
              ParamByName('ST_NUMBER_ORIGIN' ).Value:=inttostr(stationN);
              ParamByName('ST_ID_ORIGIN'     ).Value:=0;
              ParamByName('CAST_NUMBER'      ).Value:=kc;
              ParamByName('QCFLAG'           ).Value:=0;
              ParamByName('STVERSION'        ).Value:=stversion;
              ParamByName('MERGED'           ).Value:=0;
              ParamByName('DATE_ADDED'       ).Value:=Now;
              ParamByName('DATE_UPDATED'     ).Value:=Now;
             ExecSQL;
           end;

              frmdm.TR.CommitRetaining;
{wDB}end;
        CDS_DSC.Next;
{CAST}end; {CDS_DSC not empty}
        CDS_DSC.Filtered:=false;
{c}end; {kc 1..cast_maxN}
{ST}end; {kst 1..RSt-1}

  if CDS_DSC.Active=true then CDS_DSC.Close;
     CDS_DSC.Free;
  closefile(outMD);

  memo1.Lines.Add('Profiles in file: '+inttostr(PRF_count));
  btnDownloadData.Visible:=true;
end;





procedure TfrmloadGLODAP_2019_v2_product.btnSaveStationMDonDiskClick(Sender: TObject);
var
i,k,kv,line,n,mik,L:integer;
cruiseN,stationN,castN,stNBNum,cast_max,st_count:integer;
year,month,day,hour,min:integer;
stlat,stlon,stBD,stPDS,stMDS:real;
buf:real;
symbol:char;
st,buf_str:string;
StDate,StTime,StDT:TDateTime;
DayChange,DateChange:Boolean;
ww:boolean; //workedwell
NextStFound:boolean;
str_out:string;

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
   path_out:='c:\Users\ako071\AK\datasets\GLODAP\download\GLODAP_STATIONS.dat';
   AssignFile(out, Path_out); Rewrite(out);
   str_out:='st_count'+#9+'lat'+#9+'lon'+#9+'datetime'+#9+'BD[m]'+#9+'LastLev[m]'
   +#9+'LastLev[dbar]'+#9+'Cruise#'+#9+'Instrument_ID'+#9+'Station#'+#9+'StID'
   +#9+'Cast#'+#9+'QCFlag'+#9+'StVersion'+#9+'Megged'+#9+'DateAdded'+#9+'LineInFile';
   writeln(out,str_out);


   memo1.Lines.Add('');
   memo1.Lines.Add('Variables');
   for kv:=1 to var_num do memo1.Lines.Add(inttostr(kv)+#9+var_name[kv]);

   //memo1.Lines.Add('Variables in file:'+inttostr(var_num));
   //memo1.Lines.Add('Lines in file:'+inttostr(LinesInFile));



   Reset(dat);
   st_count:=0;
   cast_max:=1;
{LF}for i:=1 to LinesInFile-1 do begin
     readln(dat, st);
     st:=trim(st);
     //showmessage('line='+inttostr(i)+'  length='+inttostr(length(st)));

     NextStFound:=false;
   for k:=1 to RSt do begin
     L:=line_arr[k];
     if (i=L) then NextStFound:=true;
   end;

{NS}if NextStFound=true then begin

     st_count:=st_count+1;
     stlat:=-9999;
     stlon:=-9999;
     stPDS:=-9999;
     stNBNum:=-9999;


//START string analysis
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
  then showmessage ('trystrtofloat line='+inttostr(i)+' '+buf_str);

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
{b}end;
{kv}end;
//END string analysis


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



    (* Last level from dbar to meters TEOS10 *)
    stMDS:=declarations_gsw.gsw_z_from_p(stPDS, stlat);


      writeln(out,inttostr(st_count),       //stations count
      #9,floattostrF(stlat,FFFixed,10,5),    //LATITUDE
      #9,floattostrF(stlon,FFFixed,12,5),    //LONGITUDE
      #9,datetimetostr(stDT):20,           //DATEANDTIME
      #9,floattostrF(stBD,FFFixed,7,1),     //BOTTOMDEPTH
      #9,floattostrF(stMDS,FFFixed,7,1), //LASTLEVVEL_M
      #9,floattostrF(stPDS,FFFixed,7,1), //LASTLEVVEL_M
      #9,inttostr(cruiseN), //CRUISE_ID
      #9,inttostr(7),        //INSTRUMENT_ID
      #9,inttostr(stationN), //ST_NUMBER_ORIGIN
      #9,inttostr(0),        //ST_ID_ORIGIN
      #9,inttostr(castN),    //CAST_NUMBER
      #9,inttostr(0),        //QCFLAG
      #9,inttostr(0),        //STVERSION
      #9,inttostr(0),        //MERGED
      #9,datetimetostr(NOW), //DATE_ADDED
      #9,inttostr(i));


    //memo1.Lines.Add(inttostr(line)
    //+#9+inttostr(cruiseN)
    //+#9+inttostr(stationN)
    //+#9+inttostr(castN)
    //);

//write MD into GLODAPv2_2019_PRODUCT.FDB
{wDB}if CheckBox1.Checked then begin

     StVersion:=1;
   with frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' Select count(ID) as CountDup from STATION ');
      SQL.Add(' where DATEANDTIME=:stDT and ');
      SQL.Add(' Latitude=:stlat and Longitude=:stlon and CAST_NUMBER=:CAST_NUMBER ');
      ParamByName('stDT').AsDateTime:=stDT;
      ParamByName('stlat' ).Asfloat:=stlat;
      ParamByName('stlon' ).AsFloat:=stlon;
      ParamByName('CAST_NUMBER').AsInteger:=castN;
      Open;
        CountDup:=FieldByName('CountDup').AsInteger;
      Close;
   end;

     if CountDup>0 then begin
       StVersion:=CountDup+1;
       memo1.Lines.Add('Duplicate found in line='+inttostr(i));
     end;

     //memo1.Lines.Add(inttostr(RSt)+#9+datetimetostr(NOW));


   with frmdm.q2 do begin
     Close;
      SQL.Clear;
      SQL.Add(' INSERT INTO STATION ' );
      SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, BOTTOMDEPTH, LASTLEVEL_M, ' );
      SQL.Add('  LASTLEVEL_DBAR, CRUISE_ID, INSTRUMENT_ID, ST_NUMBER_ORIGIN, ST_ID_ORIGIN, ' );
      SQL.Add('  CAST_NUMBER, QCFLAG, STVERSION, MERGED, DATE_ADDED, DATE_UPDATED ) ' );
      SQL.Add(' VALUES ' );
      SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :BOTTOMDEPTH, :LASTLEVEL_M, ' );
      SQL.Add('  :LASTLEVEL_DBAR, :CRUISE_ID, :INSTRUMENT_ID, :ST_NUMBER_ORIGIN, :ST_ID_ORIGIN, ' );
      SQL.Add('  :CAST_NUMBER, :QCFLAG, :STVERSION, :MERGED, :DATE_ADDED, :DATE_UPDATED ) ' );
      ParamByName('ID'               ).Value:=RSt-1;
      ParamByName('LATITUDE'         ).Value:=stlat;
      ParamByName('LONGITUDE'        ).Value:=stlat;
      ParamByName('DATEANDTIME'      ).Value:=stDT;
      ParamByName('BOTTOMDEPTH'      ).Value:=stBD;
      ParamByName('LASTLEVEL_M'      ).Value:=stMDS;
      ParamByName('LASTLEVEL_DBAR'   ).Value:=stPDS;
      ParamByName('CRUISE_ID'        ).Value:=cruiseN;
      ParamByName('INSTRUMENT_ID'    ).Value:=7; //bottle type unknown
      ParamByName('ST_NUMBER_ORIGIN' ).Value:=inttostr(stationN);
      ParamByName('ST_ID_ORIGIN'     ).Value:=0;
      ParamByName('CAST_NUMBER'      ).Value:=castN;
      ParamByName('QCFLAG'           ).Value:=0;
      ParamByName('STVERSION'        ).Value:=stversion;
      ParamByName('MERGED'           ).Value:=0;
      ParamByName('DATE_ADDED'       ).Value:=Now;
      ParamByName('DATE_UPDATED'     ).Value:=Now;
     ExecSQL;
   end;

      frmdm.TR.CommitRetaining;

{wDB}end;

{NS}end;{next station found}
{LF}end; {1..LinesInFile}

   CloseFile(dat);
   CloseFile(out);

   memo1.Lines.Add('End of file');
   memo1.Lines.Add('Stations# ='+inttostr(st_count));
   memo1.Lines.Add('cast max       ='+inttostr(cast_max));

   btnDownloadData.Visible:=true;
end;




//split file on MD and Profiles/casts
procedure TfrmloadGLODAP_2019_v2_product.btnSplitOnMDandProfilesClick(
  Sender: TObject);
var
  kst,ktn,kL,kv,kt,L1,L2,n,c,i,line:integer;
  kTT:integer;
  cruiseN,stationN,castN,stNBNum:integer;
  cast_maxN,PRF_count:integer;
  Year,Month,Day,Hour,Min:integer;
  stlat,stlon,stBD,stPDS,stMDS:real;
  symbol:char;
  st,buf_str:string;
  str_MD,str_PRF,path_TBL:string;
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

  TPQF1,TPQF2,TSQF,TBottle,TUnit:integer;
  TVAL,TVALERR:real;
  TName:string;
  str_PRF1,str_PRF2:string;
  TNames1_arr:array[1..29] of string;   //GLODAP tables names Type 1
  TNames2_arr:array[1..5] of string;   //GLODAP tables names Type 1
begin
      TNames1_arr[1]:='P_AOF_BOTTLE';
      TNames1_arr[2]:='P_C13_BOTTLE';
      TNames1_arr[3]:='P_CHLA_BOTTLE';
      TNames1_arr[4]:='P_DOC_BOTTLE';
      TNames1_arr[5]:='P_DON_BOTTLE';
      TNames1_arr[6]:='P_NITRATE_BOTTLE';
      TNames1_arr[7]:='P_NITRITE_BOTTLE';
      TNames1_arr[8]:='P_O18_BOTTLE';
      TNames1_arr[9]:='P_OXYGEN_BOTTLE';
      TNames1_arr[10]:='P_PHOSPHATE_BOTTLE';
      TNames1_arr[11]:='P_PHTS25P0_BOTTLE';
      TNames1_arr[12]:='P_PHTSINSITUTP_BOTTLE';
      TNames1_arr[13]:='P_SALINITY_BOTTLE';
      TNames1_arr[14]:='P_SILICATE_BOTTLE';
      TNames1_arr[15]:='P_TALK_BOTTLE';
      TNames1_arr[16]:='P_TCO2_BOTTLE';
      TNames1_arr[17]:='P_TDN_BOTTLE';
      TNames1_arr[18]:='P_TOC_BOTTLE';
      TNames1_arr[19]:='P_TEMPERATURE_BOTTLE';
      TNames1_arr[20]:='P_CC14_BOTTLE';
      TNames1_arr[21]:='P_PCCL4_BOTTLE';
      TNames1_arr[22]:='P_CFC113_BOTTLE';
      TNames1_arr[23]:='P_PCFC113_BOTTLE';
      TNames1_arr[24]:='P_CFC11_BOTTLE';
      TNames1_arr[25]:='P_PCFC11_BOTTLE';
      TNames1_arr[26]:='P_CFC12_BOTTLE';
      TNames1_arr[27]:='P_PCFC12_BOTTLE';
      TNames1_arr[28]:='P_SF6_BOTTLE';
      TNames1_arr[29]:='P_PSF6_BOTTLE';

      TNames2_arr[1]:='P_C14_BOTTLE';
      TNames2_arr[2]:='P_HE3_BOTTLE';
      TNames2_arr[3]:='P_HE_BOTTLE';
      TNames2_arr[4]:='P_NEON_BOTTLE';
      TNames2_arr[5]:='P_H3_BOTTLE';


 path_MD:='c:\Users\ako071\AK\datasets\GLODAP\download\STATION.dat';
 str_MD:='ID LATITUDE LONGITUDE DATEANDTIME BOTTOMDEPTH LASTLEV_M LASTLEV_DBAR ' +
 'CRUISE_ID INSTRUMENT_ID ST_NUM_ORIGIN ST_ID_ORIGIN CAST_NUMBER ' +
 'QFLAG STVERSION MERGED DATE_ADDED DATE_UPDATED';

 AssignFile(outMD, path_MD); Rewrite(outMD);
 writeln(outMD,str_MD);

 //DB TBL Type1 fields:8 PRES VAL
 //DB TBL Type2 fields:9 PRES VAL VALERR
 str_PRF1:='ID PRES VAL PQF1 PQF2 SQF BOTTLE_NUMBER UNITS_ID';
 str_PRF2:='ID PRES VAL VALERR PQF1 PQF2 SQF BOTTLE_NUMBER UNITS_ID';

    //create TBL files on disk Type 1
    path_PRF:='c:\Users\ako071\AK\datasets\GLODAP\download\';
    // 1  P_AOF_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[1]+'.dat';
                  AssignFile(outPRF1, path_TBL);
                     Rewrite(outPRF1);
                     writeln(outPRF1,str_PRF1);
    // 2  P_C13_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[2]+'.dat';
                  AssignFile(outPRF2, path_TBL);
                     Rewrite(outPRF2);
                     writeln(outPRF2,str_PRF1);
    // 3  P_C13_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[3]+'.dat';
                  AssignFile(outPRF3, path_TBL);
                     Rewrite(outPRF3);
                     writeln(outPRF3,str_PRF1);
    // 4  P_DOC_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[4]+'.dat';
                  AssignFile(outPRF4, path_TBL);
                     Rewrite(outPRF4);
                     writeln(outPRF4,str_PRF1);
    // 5  P_DON_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[5]+'.dat';
                  AssignFile(outPRF5, path_TBL);
                     Rewrite(outPRF5);
                     writeln(outPRF5,str_PRF1);
    // 6  P_NITRATE_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[6]+'.dat';
                  AssignFile(outPRF6, path_TBL);
                     Rewrite(outPRF6);
                     writeln(outPRF6,str_PRF1);
    // 7  P_NITRITE_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[7]+'.dat';
                  AssignFile(outPRF7, path_TBL);
                     Rewrite(outPRF7);
                     writeln(outPRF7,str_PRF1);
    // 8  P_018_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[8]+'.dat';
                  AssignFile(outPRF8, path_TBL);
                     Rewrite(outPRF8);
                     writeln(outPRF8,str_PRF1);
    // 9  P_OXYGEN_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[9]+'.dat';
                  AssignFile(outPRF9, path_TBL);
                     Rewrite(outPRF9);
                     writeln(outPRF9,str_PRF1);
    // 10 P_PHOSPHATE_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[10]+'.dat';
                  AssignFile(outPRF10, path_TBL);
                     Rewrite(outPRF10);
                     writeln(outPRF10,str_PRF1);
    // 11 P_PHTS25P0_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[11]+'.dat';
                  AssignFile(outPRF11, path_TBL);
                     Rewrite(outPRF11);
                     writeln(outPRF11,str_PRF1);
    // 12 P_PHTSINSITUTP_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[12]+'.dat';
                  AssignFile(outPRF12, path_TBL);
                     Rewrite(outPRF12);
                     writeln(outPRF12,str_PRF1);
    // 13 P_SALINITY_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[13]+'.dat';
                  AssignFile(outPRF13, path_TBL);
                     Rewrite(outPRF13);
                     writeln(outPRF13,str_PRF1);
    // 14 P_SILICATE_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[14]+'.dat';
                  AssignFile(outPRF14, path_TBL);
                     Rewrite(outPRF14);
                     writeln(outPRF14,str_PRF1);
    // 15 P_TALK_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[15]+'.dat';
                  AssignFile(outPRF15, path_TBL);
                     Rewrite(outPRF15);
                     writeln(outPRF15,str_PRF1);
    // 16 P_TCO2_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[16]+'.dat';
                  AssignFile(outPRF16, path_TBL);
                     Rewrite(outPRF16);
                     writeln(outPRF16,str_PRF1);
    // 17 P_TDN_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[17]+'.dat';
                  AssignFile(outPRF17, path_TBL);
                     Rewrite(outPRF17);
                     writeln(outPRF17,str_PRF1);
    // 18 P_TOC_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[18]+'.dat';
                  AssignFile(outPRF18, path_TBL);
                     Rewrite(outPRF18);
                     writeln(outPRF18,str_PRF1);
    // 19 P_TEMPERATURE_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[19]+'.dat';
                  AssignFile(outPRF19, path_TBL);
                     Rewrite(outPRF19);
                     writeln(outPRF19,str_PRF1);
    // 20 P_CC14_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[20]+'.dat';
                  AssignFile(outPRF20, path_TBL);
                     Rewrite(outPRF20);
                     writeln(outPRF20,str_PRF1);
    // 21 P_PCCL4_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[21]+'.dat';
                  AssignFile(outPRF21, path_TBL);
                     Rewrite(outPRF21);
                     writeln(outPRF21,str_PRF1);
    // 22 P_CFC113_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[22]+'.dat';
                  AssignFile(outPRF22, path_TBL);
                     Rewrite(outPRF22);
                     writeln(outPRF22,str_PRF1);
    // 23 P_PCFC113_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[23]+'.dat';
                  AssignFile(outPRF23, path_TBL);
                     Rewrite(outPRF23);
                     writeln(outPRF23,str_PRF1);
    // 24 P_CFC11_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[24]+'.dat';
                  AssignFile(outPRF24, path_TBL);
                     Rewrite(outPRF24);
                     writeln(outPRF24,str_PRF1);
    // 25 P_PCFC11_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[25]+'.dat';
                  AssignFile(outPRF25, path_TBL);
                     Rewrite(outPRF25);
                     writeln(outPRF25,str_PRF1);
    // 26 P_CFC12_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[26]+'.dat';
                  AssignFile(outPRF26, path_TBL);
                     Rewrite(outPRF26);
                     writeln(outPRF26,str_PRF1);
    // 27 P_PCFC12_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[27]+'.dat';
                  AssignFile(outPRF27, path_TBL);
                     Rewrite(outPRF27);
                     writeln(outPRF27,str_PRF1);
    // 28 P_SF6_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[28]+'.dat';
                  AssignFile(outPRF28, path_TBL);
                     Rewrite(outPRF28);
                     writeln(outPRF28,str_PRF1);
    // 29 P_PSF6_BOTTLE
    path_TBL:=path_PRF+TNames1_arr[29]+'.dat';
                  AssignFile(outPRF29, path_TBL);
                     Rewrite(outPRF29);
                     writeln(outPRF29,str_PRF1);

    //create TBL files on disk Type 2
    // 1  P_C14_BOTTLE ->30
    path_TBL:=path_PRF+TNames2_arr[1]+'.dat';
                  AssignFile(outPRF30, path_TBL);
                     Rewrite(outPRF30);
                     writeln(outPRF30,str_PRF2);
    // 2  P_HE3_BOTTLE ->31
    path_TBL:=path_PRF+TNames2_arr[2]+'.dat';
                  AssignFile(outPRF31, path_TBL);
                     Rewrite(outPRF31);
                     writeln(outPRF31,str_PRF2);
    // 3  P_HE_BOTTLE ->32
    path_TBL:=path_PRF+TNames2_arr[3]+'.dat';
                  AssignFile(outPRF32, path_TBL);
                     Rewrite(outPRF32);
                     writeln(outPRF32,str_PRF2);
    // 4  P_NEON_BOTTLE ->33
    path_TBL:=path_PRF+TNames2_arr[4]+'.dat';
                  AssignFile(outPRF33, path_TBL);
                     Rewrite(outPRF33);
                     writeln(outPRF33,str_PRF2);
    // 5  P_H3_BOTTLE ->34
    path_TBL:=path_PRF+TNames2_arr[5]+'.dat';
                  AssignFile(outPRF34, path_TBL);
                     Rewrite(outPRF34);
                     writeln(outPRF34,str_PRF2);


//CDS Divide Station on Casts Type 1
 CDS_DSC1:=TBufDataSet.Create(self);
with CDS_DSC1.FieldDefs do begin
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
 CDS_DSC1.CreateDataSet;

 //CDS Divide Station on Casts  Type2 (+ValErr)
 CDS_DSC2:=TBufDataSet.Create(self);
with CDS_DSC2.FieldDefs do begin
  Add('ID',  ftInteger,0,true);
  Add('Press', ftFloat,0,true);
  Add('Val', ftFloat,0,true);
  Add('ValErr', ftFloat,0,true);
  Add('PQF1',  ftInteger,0,true);
  Add('PQF2',  ftInteger,0,true);
  Add('SQF', ftInteger, 0,true);
  Add('Bottle',  ftInteger,0,true);
  Add('Station',  ftInteger,0,true);
  Add('Cast',  ftInteger,0,true);
  Add('Units_ID',  ftInteger,0,true);
end;
 CDS_DSC2.CreateDataSet;


 //START SPLITING
    Reset(dat);
    readln(dat, st);
    line:=1;
    PRF_count:=0;
{ST}for kst:=1 to RSt-1 do begin

   if CDS_DSC1.Active then CDS_DSC1.Close;
     CDS_DSC1.Open;
   if CDS_DSC2.Active then CDS_DSC2.Close;
     CDS_DSC2.Open;

     L1:=line_arr[kst];      //station begin
     L2:=line_arr[kst+1]-1;  //station end

     memo1.Lines.Add('kst='+inttostr(kst)+'   L1:'+inttostr(L1)+'->'+inttostr(L2));

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
   //DB TBL Type1 fields:8 PRES VAL
   //DB TBL Type2 fields:9 PRES VAL VALERR



{TN}for kTN:=1 to 34 do begin
     if (kTN<=29) then kTT:=1 else kTT:=2; //two different GLODAP tables types

     TPQF1:=0;
     TPQF2:=0;
     TSQF:=0;

{T1}if kTT=1 then begin
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
   20: begin
      TName:='P_CC14_BOTTLE';
      Tval:=cc14;
      TPQF1:=cc14_pQF1;
      TSQF:=cc14_SQF;
      TBottle:=stNBNum;
      TUNIT:=13;  //Pico-mole per kilogram
      end;
   21: begin
       TName:='P_PCCL4_BOTTLE';
       Tval:=pcc14;
       TPQF1:=cc14_pQF1;
       TSQF:=cc14_SQF;
       TBottle:=stNBNum;
       TUNIT:=18;  //Parts per thousand (16) or trillion (18) ???
       end;
   22: begin
       TName:='P_CFC113_BOTTLE';
       Tval:=cfc113;
       TPQF1:=cfc113_pQF1;
       TSQF:=cfc113_SQF;
       TBottle:=stNBNum;
       TUNIT:=13;  //Pico-mole per kilogram
       end;
   23: begin
       TName:='P_PCFC113_BOTTLE';
       Tval:=pcfc113;
       TPQF1:=cfc113_pQF1;
       TSQF:=cfc113_SQF;
       TBottle:=stNBNum;
       TUNIT:=18;  //Parts per thousand (16) or trillion (18) ???
       end;
   24: begin
       TName:='P_CFC11_BOTTLE';
       Tval:=cfc11;
       TPQF1:=cfc11_pQF1;
       TSQF:=cfc11_SQF;
       TBottle:=stNBNum;
       TUNIT:=13;  //Pico-mole per kilogram
       end;
   25: begin
       TName:='P_PCFC11_BOTTLE';
       Tval:=pcfc11;
       TPQF1:=cfc11_pQF1;
       TSQF:=cfc11_SQF;
       TBottle:=stNBNum;
       TUNIT:=18;  //Parts per thousand (16) or trillion (18) ???
       end;
   26: begin
       TName:='P_CFC12_BOTTLE';
       Tval:=cfc12;
       TPQF1:=cfc12_pQF1;
       TSQF:=cfc12_SQF;
       TBottle:=stNBNum;
       TUNIT:=13;  //Pico-mole per kilogram
       end;
   27: begin
       TName:='P_PCFC12_BOTTLE';
       Tval:=pcfc12;
       TPQF1:=cfc12_pQF1;
       TSQF:=cfc12_SQF;
       TBottle:=stNBNum;
       TUNIT:=18;  //Parts per thousand (16) or trillion (18) ???
       end;
   28: begin
      TName:='P_SF6_BOTTLE';
      Tval:=sf6;
      TPQF1:=sf6_pQF1;
      TBottle:=stNBNum;
      TUNIT:=19;  //Femto-mole per kilogram
      end;
   29: begin
      TName:='P_PSF6_BOTTLE';
      Tval:=psf6;
      TPQF1:=sf6_pQF1;
      TBottle:=stNBNum;
      TUNIT:=18;  //Parts per thousand (16) or trillion (18) ???
      end;
     end;{case}
{T1}end;


{T2}if (kTT=2) then begin
   case kTN of
   30: begin
      TName:='P_C14_BOTTLE';
      Tval:=c14;
      Tvalerr:=c14_err;
      TPQF1:=c14_pQF1;
      TBottle:=stNBNum;
      TUNIT:=11;  //Per-mille deviation
      end;
   31: begin
      TName:='P_HE3_BOTTLE';
      Tval:=he3;
      Tvalerr:=he3_err;
      TPQF1:=he3_pQF1;
      TBottle:=stNBNum;
      TUNIT:=10;  //
      end;
   32: begin
      TName:='P_HE_BOTTLE';
      Tval:=he;
      Tvalerr:=he_err;
      TPQF1:=he_pQF1;
      TBottle:=stNBNum;
      TUNIT:=12;  //Nano-mole per kilogram
      end;
   33: begin
      TName:='P_NEON_BOTTLE';
      Tval:=neon;
      Tvalerr:=neon_err;
      TPQF1:=neon_pQF1;
      TBottle:=stNBNum;
      TUNIT:=12;  //Nano-mole per kilogram
      end;
   34: begin
      TName:='P_H3_BOTTLE';
      Tval:=h3;
      Tvalerr:=h3_err;
      TPQF1:=h3_pQF1;
      TBottle:=stNBNum;
      TUNIT:=8;  // TU Tritium Unit
      end;
    end;{case}
{T2}end;


   //append to CDS Type1
   if kTT=1 then
   with CDS_DSC1 do begin
     Append;
     FieldByName('ID').AsInteger:=kst;
     FieldByName('Press').AsFloat:=press;
     FieldByName('Val').AsFloat:=TVal;
     FieldByName('PQF1').AsInteger:=TPQF1;
     FieldByName('PQF2').AsInteger:=TPQF2;
     FieldByName('SQF').AsInteger:=TSQF;
     FieldByName('Bottle').AsInteger:=TBottle;
     FieldByName('Station').AsInteger:=stationN;
     FieldByName('Cast').AsInteger:=CastN;
     FieldByName('Units_ID').AsInteger:=TUNIT;
     Post;
   end;

   //append to CDS Type1
   if kTT=2 then
   with CDS_DSC2 do begin
     Append;
     FieldByName('ID').AsInteger:=kst;
     FieldByName('Press').AsFloat:=press;
     FieldByName('Val').AsFloat:=TVal;
     FieldByName('ValErr').AsFloat:=TValErr;
     FieldByName('PQF1').AsInteger:=TPQF1;
     FieldByName('PQF2').AsInteger:=TPQF2;
     FieldByName('SQF').AsInteger:=TSQF;
     FieldByName('Bottle').AsInteger:=TBottle;
     FieldByName('Station').AsInteger:=stationN;
     FieldByName('Cast').AsInteger:=CastN;
     FieldByName('Units_ID').AsInteger:=TUNIT;
     Post;
   end;

{pr}end;{inside profiles}
{L} end; {lines loop}

  StDT:= procedures.DateEncode(Year,Month,Day,Hour,Min,DayChange,DateChange);

//CDS_DSC1
//determine max number of casts at stations
{CDS1}if kTT=1 then begin
    CDS_DSC1.First;
    cast_maxN:=CDS_DSC1.FieldByName('Cast').AsInteger;
{s}while not CDS_DSC1.EOF do begin
    if cast_maxN<CDS_DSC1.FieldByName('Cast').AsInteger
    then cast_maxN:=CDS_DSC1.FieldByName('Cast').AsInteger;
    CDS_DSC1.Next;
{s}end;
showmessage('kst='+inttostr(kst)+'  cast_maxN='+inttostr(cast_maxN));
  //divide station on casts
{c}for c:=1 to cast_maxN do begin
    CDS_DSC1.Filter:='CAST='+inttostr(c);
    CDS_DSC1.Filtered:=true;

    CDS_DSC1.IndexFieldNames:='Press';  //sort by press


{i}if CDS_DSC1.IsEmpty=false then begin
    CDS_DSC1.First;
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

{s}while not CDS_DSC1.EOF do begin
    case kTN of
    1: begin
    writeln(outPRF1,inttostr(PRF_count),                      //ID
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),     //PRESS
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),       //VAL
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),      //PQF1
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),      //PQF2
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),      //SQF
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),    //BOTTLE_NUMBER
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger)); //UNITS_ID
    end;
    2: begin
    writeln(outPRF2,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    3: begin
    writeln(outPRF3,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    4: begin
    writeln(outPRF4,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    5: begin
    writeln(outPRF5,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    6: begin
    writeln(outPRF6,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    7: begin
    writeln(outPRF7,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    8: begin
    writeln(outPRF8,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    9: begin
    writeln(outPRF9,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    10: begin
    writeln(outPRF10,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    11: begin
    writeln(outPRF11,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    12: begin
    writeln(outPRF12,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    13: begin
    writeln(outPRF13,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    14: begin
    writeln(outPRF14,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    15: begin
    writeln(outPRF15,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    16: begin
    writeln(outPRF16,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    17: begin
    writeln(outPRF17,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    18: begin
    writeln(outPRF18,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    19: begin
    writeln(outPRF19,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    20: begin
    writeln(outPRF20,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    21: begin
    writeln(outPRF21,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    22: begin
    writeln(outPRF22,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    23: begin
    writeln(outPRF23,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    24: begin
    writeln(outPRF24,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    25: begin
    writeln(outPRF25,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    26: begin
    writeln(outPRF26,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    27: begin
    writeln(outPRF27,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    28: begin
    writeln(outPRF28,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    29: begin
    writeln(outPRF29,inttostr(PRF_count),
    #9,floattostr(CDS_DSC1.FieldByName('press').AsFloat),
    #9,floattostr(CDS_DSC1.FieldByName('val').AsFloat),
    #9,inttostr(CDS_DSC1.FieldByName('PQF1').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('PQF2').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('Bottle').AsInteger),
    #9,inttostr(CDS_DSC1.FieldByName('UNITS_ID').AsInteger));
    end;
    end;{case}

     CDS_DSC1.Next;
{s}end; {CDS_DSC1.EOF}
{i}end; //if cast exists
{c}end; //casts
{CDS1}end;




//CDS_DSC2
//determine max number of casts at stations
{CDS2}if kTT=2 then begin
    CDS_DSC2.First;
    cast_maxN:=CDS_DSC2.FieldByName('Cast').AsInteger;
{s}while not CDS_DSC2.EOF do begin
    if cast_maxN<CDS_DSC2.FieldByName('Cast').AsInteger
    then cast_maxN:=CDS_DSC2.FieldByName('Cast').AsInteger;
    CDS_DSC2.Next;
{s}end;

  //divide station on casts
{c}for c:=1 to cast_maxN do begin
    CDS_DSC2.Filter:='CAST='+inttostr(c);
    CDS_DSC2.Filtered:=true;

    CDS_DSC2.IndexFieldNames:='Press';  //sort by press


{i}if CDS_DSC2.IsEmpty=false then begin
    CDS_DSC2.First;
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

{s}while not CDS_DSC2.EOF do begin
        case kTN of
        30: begin
        writeln(outPRF30,inttostr(PRF_count),                      //ID
        #9,floattostr(CDS_DSC2.FieldByName('press').AsFloat),     //PRESS
        #9,floattostr(CDS_DSC2.FieldByName('val').AsFloat),       //VAL
        #9,floattostr(CDS_DSC2.FieldByName('valerr').AsFloat),    //VALERR
        #9,inttostr(CDS_DSC2.FieldByName('PQF1').AsInteger),      //PQF1
        #9,inttostr(CDS_DSC2.FieldByName('PQF2').AsInteger),      //PQF2
        #9,inttostr(CDS_DSC2.FieldByName('PQF2').AsInteger),      //SQF
        #9,inttostr(CDS_DSC2.FieldByName('Bottle').AsInteger),    //BOTTLE_NUMBER
        #9,inttostr(CDS_DSC2.FieldByName('UNITS_ID').AsInteger)); //UNITS_ID
        end;
        31: begin
        writeln(outPRF31,inttostr(PRF_count),                      //ID
        #9,floattostr(CDS_DSC2.FieldByName('press').AsFloat),     //PRESS
        #9,floattostr(CDS_DSC2.FieldByName('val').AsFloat),       //VAL
        #9,floattostr(CDS_DSC2.FieldByName('valerr').AsFloat),    //VALERR
        #9,inttostr(CDS_DSC2.FieldByName('PQF1').AsInteger),      //PQF1
        #9,inttostr(CDS_DSC2.FieldByName('PQF2').AsInteger),      //PQF2
        #9,inttostr(CDS_DSC2.FieldByName('PQF2').AsInteger),      //SQF
        #9,inttostr(CDS_DSC2.FieldByName('Bottle').AsInteger),    //BOTTLE_NUMBER
        #9,inttostr(CDS_DSC2.FieldByName('UNITS_ID').AsInteger)); //UNITS_ID
        end;
        32: begin
        writeln(outPRF32,inttostr(PRF_count),                      //ID
        #9,floattostr(CDS_DSC2.FieldByName('press').AsFloat),     //PRESS
        #9,floattostr(CDS_DSC2.FieldByName('val').AsFloat),       //VAL
        #9,floattostr(CDS_DSC2.FieldByName('valerr').AsFloat),    //VALERR
        #9,inttostr(CDS_DSC2.FieldByName('PQF1').AsInteger),      //PQF1
        #9,inttostr(CDS_DSC2.FieldByName('PQF2').AsInteger),      //PQF2
        #9,inttostr(CDS_DSC2.FieldByName('PQF2').AsInteger),      //SQF
        #9,inttostr(CDS_DSC2.FieldByName('Bottle').AsInteger),    //BOTTLE_NUMBER
        #9,inttostr(CDS_DSC2.FieldByName('UNITS_ID').AsInteger)); //UNITS_ID
        end;
        33: begin
        writeln(outPRF33,inttostr(PRF_count),                      //ID
        #9,floattostr(CDS_DSC2.FieldByName('press').AsFloat),     //PRESS
        #9,floattostr(CDS_DSC2.FieldByName('val').AsFloat),       //VAL
        #9,floattostr(CDS_DSC2.FieldByName('valerr').AsFloat),    //VALERR
        #9,inttostr(CDS_DSC2.FieldByName('PQF1').AsInteger),      //PQF1
        #9,inttostr(CDS_DSC2.FieldByName('PQF2').AsInteger),      //PQF2
        #9,inttostr(CDS_DSC2.FieldByName('PQF2').AsInteger),      //SQF
        #9,inttostr(CDS_DSC2.FieldByName('Bottle').AsInteger),    //BOTTLE_NUMBER
        #9,inttostr(CDS_DSC2.FieldByName('UNITS_ID').AsInteger)); //UNITS_ID
        end;
        34: begin
        writeln(outPRF34,inttostr(PRF_count),                      //ID
        #9,floattostr(CDS_DSC2.FieldByName('press').AsFloat),     //PRESS
        #9,floattostr(CDS_DSC2.FieldByName('val').AsFloat),       //VAL
        #9,floattostr(CDS_DSC2.FieldByName('valerr').AsFloat),    //VALERR
        #9,inttostr(CDS_DSC2.FieldByName('PQF1').AsInteger),      //PQF1
        #9,inttostr(CDS_DSC2.FieldByName('PQF2').AsInteger),      //PQF2
        #9,inttostr(CDS_DSC2.FieldByName('PQF2').AsInteger),      //SQF
        #9,inttostr(CDS_DSC2.FieldByName('Bottle').AsInteger),    //BOTTLE_NUMBER
        #9,inttostr(CDS_DSC2.FieldByName('UNITS_ID').AsInteger)); //UNITS_ID
        end;
        end;{case}

        CDS_DSC2.Next;

{s}end;{CDS_DSC2.EOF}
{i}end; //if cast exists
{c}end; //casts
{CDS2}end;

{TN}end; //table names 1..34

     CDS_DSC1.Filtered:=false;
     CDS_DSC2.Filtered:=false;
     //CDS_DSC.Close;
     //CDS_DSC.Clear;
     //CDS_DSC.Active:=false;

{ST}end; //real stations loop

  if CDS_DSC1.Active=true then CDS_DSC1.Close;
     CDS_DSC1.Free;
  if CDS_DSC2.Active=true then CDS_DSC2.Close;
     CDS_DSC2.Free;

     closefile(outMD);

     closefile(outPRF1);
     closefile(outPRF2);
     closefile(outPRF3);
     closefile(outPRF4);
     closefile(outPRF5);
     closefile(outPRF6);
     closefile(outPRF7);
     closefile(outPRF8);
     closefile(outPRF9);
     closefile(outPRF10);
     closefile(outPRF11);
     closefile(outPRF12);
     closefile(outPRF13);
     closefile(outPRF14);
     closefile(outPRF15);
     closefile(outPRF16);
     closefile(outPRF17);
     closefile(outPRF18);
     closefile(outPRF19);
     closefile(outPRF20);
     closefile(outPRF21);
     closefile(outPRF22);
     closefile(outPRF23);
     closefile(outPRF24);
     closefile(outPRF25);
     closefile(outPRF26);
     closefile(outPRF27);
     closefile(outPRF28);
     closefile(outPRF29);
     closefile(outPRF30);
     closefile(outPRF31);
     closefile(outPRF32);
     closefile(outPRF33);
     closefile(outPRF34);

     memo1.Lines.Add('Profiles in file: '+inttostr(PRF_count));
     memo1.Lines.Add('Spliting completed');

     CheckBox1.Visible:=true;
     btnSaveStationMDonDisk.Visible:=true;
     btnDownloadData.Visible:=true;
end;





procedure TfrmloadGLODAP_2019_v2_product.btnDownloadDataClick(Sender: TObject);
var
  ktbl,kst,kl,kv,L1,L2,n,c,i,PRF_count:integer;
  cruiseN,stationN,castN,stNBNum:integer;
  cast_maxN:integer;
  Year,Month,Day,Hour,Min:integer;
  stlat,stlon,stBD,stPDS:real;
  symbol:char;
  st,buf_str,path_out,path_TBL,str_out:string;
  StDT:TDateTime;
  DayChange,DateChange:Boolean;
  UnitID:array[1..34] of integer;
  TblName:array[1..34] of string;
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

  TPQF1,TPQF2,TSQF,TBottle,TUnit:integer;
  TPress,TVAL,TVALERR:real;

begin

TblName[1]:='P_AOU_BOTTLE';
TblName[2]:='P_C13_BOTTLE';
TblName[3]:='P_CHLA_BOTTLE';
TblName[4]:='P_DOC_BOTTLE';
TblName[5]:='P_DON_BOTTLE';
TblName[6]:='P_NITRATE_BOTTLE';
TblName[7]:='P_NITRITE_BOTTLE';
TblName[8]:='P_O18_BOTTLE';
TblName[9]:='P_OXYGEN_BOTTLE';
TblName[10]:='P_PHOSPHATE_BOTTLE';
TblName[11]:='P_PHTS25P0_BOTTLE';
TblName[12]:='P_PHTSINSITUTP_BOTTLE';
TblName[13]:='P_SALINITY_BOTTLE';
TblName[14]:='P_SILICATE_BOTTLE';
TblName[15]:='P_TALK_BOTTLE';
TblName[16]:='P_TCO2_BOTTLE';
TblName[17]:='P_TDN_BOTTLE';
TblName[18]:='P_TOC_BOTTLE';
TblName[19]:='P_TEMPERATURE_BOTTLE';
TblName[20]:='P_CC14_BOTTLE';
TblName[21]:='P_PCCL4_BOTTLE';
TblName[22]:='P_CFC113_BOTTLE';
TblName[23]:='P_PCFC113_BOTTLE';
TblName[24]:='P_CFC11_BOTTLE';
TblName[25]:='P_PCFC11_BOTTLE';
TblName[26]:='P_CFC12_BOTTLE';
TblName[27]:='P_PCFC12_BOTTLE';
TblName[28]:='P_SF6_BOTTLE';
TblName[29]:='P_PSF6_BOTTLE';
TblName[30]:='P_C14_BOTTLE';
TblName[31]:='P_HE3_BOTTLE';
TblName[32]:='P_HE_BOTTLE';
TblName[33]:='P_NEON_BOTTLE';
TblName[34]:='P_H3_BOTTLE';

UnitID[1]:=3;              //'P_AOU_BOTTLE'  Micro-mole per kilogram
UnitID[2]:=11;             //'P_C13_BOTTLE'  Per-mille deviation
UnitID[3]:=14;             //'P_CHLA_BOTTLE'  Micro-gram per kilogram
UnitID[4]:=15;             //'P_DOC_BOTTLE'  Micro-gram per liter
UnitID[5]:=15;             //'P_DON_BOTTLE'  Micro-gram per liter
UnitID[6]:=3;              //'P_NITRATE_BOTTLE'  Micro-mole per kilogram
UnitID[7]:=3;              //'P_NITRITE_BOTTLE'  Micro-mole per kilogram
UnitID[8]:=11;             //'P_O18_BOTTLE'  Per-mille deviation
UnitID[9]:=3;              //'P_OXYGEN_BOTTLE'  Micro-mole per kilogram
UnitID[10]:=3;             //'P_PHOSPHATE_BOTTLE'  Micro-mole per kilogram
UnitID[11]:=2;             //'P_PHTS25P0_BOTTLE' Dimensionless or unit less
UnitID[12]:=2;             //'P_PHTSINSITUTP_BOTTLE'  Dimensionless or unit less
UnitID[13]:=2;             //'P_SALINITY_BOTTLE' Dimensionless or unit less
UnitID[14]:=3;             //'P_SILICATE_BOTTLE'  Micro-mole per kilogram
UnitID[15]:=3;             //'P_TALK_BOTTLE'  Micro-mole per kilogram
UnitID[16]:=3;             //'P_TCO2_BOTTLE'  Micro-mole per kilogram
UnitID[17]:=15;            //'P_TDN_BOTTLE' Micro-mole per liter
UnitID[18]:=15;            //'P_TOC_BOTTLE'  Micro-mole per liter
UnitID[19]:=1;             //'P_TEMPERATURE_BOTTLE'  Degree centigrade
UnitID[20]:=13;            //'P_CC14_BOTTLE'  Pico-mole per kilogram
UnitID[21]:=18;            //'P_PCCL4_BOTTLE'  Parts per thousand (16) or trillion (18) ???
UnitID[22]:=13;            //'P_CFC113_BOTTLE'  Pico-mole per kilogram
UnitID[23]:=18;            //'P_PCFC113_BOTTLE'  Parts per thousand (16) or trillion (18) ???
UnitID[24]:=13;            //'P_CFC11_BOTTLE'  Pico-mole per kilogram
UnitID[25]:=18;            //'P_PCFC11_BOTTLE'  Parts per thousand (16) or trillion (18) ???
UnitID[26]:=13;            //'P_CFC12_BOTTLE' Pico-mole per kilogram
UnitID[27]:=18;            //'P_PCFC12_BOTTLE'  Parts per thousand (16) or trillion (18) ???
UnitID[28]:=19;            //'P_SF6_BOTTLE'  Femto-mole per kilogram
UnitID[29]:=18;            //'P_PSF6_BOTTLE'  Parts per thousand (16) or trillion (18) ???
UnitID[30]:=11;            //'P_C14_BOTTLE'  Per-mille deviation
UnitID[31]:=10;            //'P_HE3_BOTTLE'  Persent
UnitID[32]:=12;            //'P_HE_BOTTLE'  Nano-mole per kilogram
UnitID[33]:=12;            //'P_NEON_BOTTLE Nano-mole per kilogram
UnitID[34]:=8;             //'P_H3_BOTTLE' TU Tritium Unit

path_out:='c:\Users\ako071\AK\datasets\GLODAP\download\';

memo1.Lines.Add('Start:'+datetimetostr(NOW));

//{TBL}for ktbl:=1 to 34 do begin
{TBL}for ktbl:=1 to 1 do begin

     Reset(dat);
     readln(dat, st);

     path_TBL:=path_out+TblName[ktbl];

     AssignFile(out,path_tbl);
     Rewrite(out);

     str_out:='ID'+#9+'Pres'+#9+'VAL'+#9+'PQF1'+#9+'PQF2'+#9+'SQF'+#9+'BOTTLE_NUMBER'+#9+'UNITS_ID';
     if (ktbl>29) then
     str_out:='ID'+#9+'Pres'+#9+'VAL'+#9+'VALERR'+#9+'PQF1'+#9+'PQF2'+#9+'SQF'+#9+'BOTTLE_NUMBER'+#9+'UNITS_ID';
     writeln(out,str_out);

     memo1.Lines.Add(inttostr(ktbl)+#9+path_TBL);

   //CDS Divide Station on Casts
    CDS_DSC:=TBufDataSet.Create(self);
   with CDS_DSC.FieldDefs do begin
     Add('ID',  ftInteger,0,true);
     Add('Press', ftFloat,0,true);
     Add('Val', ftFloat,0,true);
     if (ktbl>29) then Add('ValErr', ftFloat,0,true);
     Add('PQF1',  ftInteger,0,true);
     Add('PQF2',  ftInteger,0,true);
     Add('SQF', ftInteger, 0,true);
     Add('Bottle',  ftInteger,0,true);
     Add('Station',  ftInteger,0,true);
     Add('Cast',  ftInteger,0,true);
     Add('Units_ID',  ftInteger,0,true);
   end;
    CDS_DSC.CreateDataSet;


    PRF_count:=0;
{ST}for kst:=1 to RSt-1 do begin        //GLODAP Stations

    if CDS_DSC.Active then CDS_DSC.Close;
      CDS_DSC.Open;

      L1:=line_arr[kst];
      L2:=line_arr[kst+1]-1;
      //memo1.Lines.Add('kst='+inttostr(kst)+'   L1:'+inttostr(L1)+'->'+inttostr(L2));

{L}for kL:=L1 to L2 do begin    //file scroll

      readln(dat, st);
      st:=trim(st);
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

      TVal:=-9999;
      TValErr:=-9999;
      TPQF1:=0;
      TPQF2:=0;
      TSQF:=0;
      TUNIT:=0;

      case ktbl of
      1: begin
         TPress:=press;
         Tval:=aou;
         TPQF1:=aou_pQF1;
         TBottle:=stNBNum;
         TUNIT:=3; //Micro-mole per kilogram
         end; {1}
      2: begin
         TPress:=press;
         Tval:=c13;
         TPQF1:=c13_pQF1;
         TSQF:=c13_SQF;
         TBottle:=stNBNum;
         TUNIT:=11; //Per-mille deviation
         end; {2}
      3: begin
         TPress:=press;
         Tval:=chla;
         TPQF1:=chla_pQF1;
         TBottle:=stNBNum;
         TUNIT:=14;  //Micro-gram per kilogram
         end;
      4: begin
         TPress:=press;
         Tval:=doc;
         TPQF1:=doc_pQF1;
         TBottle:=stNBNum;
         TUNIT:=15;  //Micro-gram per liter
         end;
      5: begin
         TPress:=press;
         Tval:=don;
         TPQF1:=don_pQF1;
         TBottle:=stNBNum;
         TUNIT:=15;  //Micro-gram per liter
         end;
      6: begin
         TPress:=press;
         Tval:=nat;
         TPQF1:=nat_pQF1;
         TSQF:=nat_SQF;
         TBottle:=stNBNum;
         TUNIT:=3;  //Micro-mole per kilogram
         end;
      7: begin
         TPress:=press;
         Tval:=nit;
         TPQF1:=nit_pQF1;
         TBottle:=stNBNum;
         TUNIT:=3;  //Micro-mole per kilogram
         end;
      8: begin
         TPress:=press;
         Tval:=O18;
         TPQF1:=O18_pQF1;
         TBottle:=stNBNum;
         TUNIT:=11;  //Per-mille deviation
         end;
      9: begin
         TPress:=press;
         Tval:=oxy;
         TPQF1:=oxy_pQF1;
         TSQF:=oxy_SQF;
         TBottle:=stNBNum;
         TUNIT:=3;  //Micro-mole per kilogram
         end;
      10: begin
          TPress:=press;
          Tval:=pho;
          TPQF1:=pho_pQF1;
          TSQF:=pho_SQF;
          TBottle:=stNBNum;
          TUNIT:=3;  //Micro-mole per kilogram
          end;
      11: begin
          TPress:=press;
          Tval:=phts25p0;
          TPQF1:=phts25p0_pQF1;
          TSQF:=phts25p0_SQF;
          TBottle:=stNBNum;
          TUNIT:=2;  //Dimensionless or unit less
          end;
      12: begin
          TPress:=press;
          Tval:=phtsinsitutp;
          TPQF1:=phtsinsitutp_pQF1;
          TSQF:=phtsinsitutp_SQF;
          TBottle:=stNBNum;
          TUNIT:=2;  //Dimensionless or unit less
          end;
      13: begin
          TPress:=press;
          Tval:=salt;
          TPQF1:=salt_pQF1;
          TSQF:=salt_SQF;
          TBottle:=stNBNum;
          TUNIT:=2;  //Dimensionless or unit less
          end;
      14: begin
          TPress:=press;
          Tval:=sil;
          TPQF1:=sil_pQF1;
          TSQF:=sil_SQF;
          TBottle:=stNBNum;
          TUNIT:=3;  //Micro-mole per kilogram
          end;
      15: begin
          TPress:=press;
          Tval:=talk;
          TPQF1:=talk_pQF1;
          TSQF:=talk_SQF;
          TBottle:=stNBNum;
          TUNIT:=3;  //Micro-mole per kilogram
          end;
      16: begin
          TPress:=press;
          Tval:=tco2;
          TPQF1:=tco2_pQF1;
          TSQF:=tco2_SQF;
          TBottle:=stNBNum;
          TUNIT:=3;  //Micro-mole per kilogram
          end;
      17: begin
          TPress:=press;
          Tval:=tdn;
          TPQF1:=tdn_pQF1;
          TBottle:=stNBNum;
          TUNIT:=15;  //Micro-mole per liter
          end;
      18: begin
          TPress:=press;
          Tval:=toc;
          TPQF1:=toc_pQF1;
          TBottle:=stNBNum;
          TUNIT:=15;  //Micro-mole per liter
          end;
      19: begin
          TPress:=press;
          Tval:=temp;
          TBottle:=stNBNum;
          TUNIT:=1;  //Degree centigrade
          end;
      20: begin
         TPress:=press;
         Tval:=cc14;
         TPQF1:=cc14_pQF1;
         TSQF:=cc14_SQF;
         TBottle:=stNBNum;
         TUNIT:=13;  //Pico-mole per kilogram
         end;
      21: begin
          TPress:=press;
          Tval:=pcc14;
          TPQF1:=cc14_pQF1;
          TSQF:=cc14_SQF;
          TBottle:=stNBNum;
          TUNIT:=18;  //Parts per thousand (16) or trillion (18) ???
          end;
      22: begin
          TPress:=press;
          Tval:=cfc113;
          TPQF1:=cfc113_pQF1;
          TSQF:=cfc113_SQF;
          TBottle:=stNBNum;
          TUNIT:=13;  //Pico-mole per kilogram
          end;
      23: begin
          TPress:=press;
          Tval:=pcfc113;
          TPQF1:=cfc113_pQF1;
          TSQF:=cfc113_SQF;
          TBottle:=stNBNum;
          TUNIT:=18;  //Parts per thousand (16) or trillion (18) ???
          end;
      24: begin
          TPress:=press;
          Tval:=cfc11;
          TPQF1:=cfc11_pQF1;
          TSQF:=cfc11_SQF;
          TBottle:=stNBNum;
          TUNIT:=13;  //Pico-mole per kilogram
          end;
      25: begin
          TPress:=press;
          Tval:=pcfc11;
          TPQF1:=cfc11_pQF1;
          TSQF:=cfc11_SQF;
          TBottle:=stNBNum;
          TUNIT:=18;  //Parts per thousand (16) or trillion (18) ???
          end;
      26: begin
          TPress:=press;
          Tval:=cfc12;
          TPQF1:=cfc12_pQF1;
          TSQF:=cfc12_SQF;
          TBottle:=stNBNum;
          TUNIT:=13;  //Pico-mole per kilogram
          end;
      27: begin
          TPress:=press;
          Tval:=pcfc12;
          TPQF1:=cfc12_pQF1;
          TSQF:=cfc12_SQF;
          TBottle:=stNBNum;
          TUNIT:=18;  //Parts per thousand (16) or trillion (18) ???
          end;
      28: begin
         TPress:=press;
         Tval:=sf6;
         TPQF1:=sf6_pQF1;
         TBottle:=stNBNum;
         TUNIT:=19;  //Femto-mole per kilogram
         end;
      29: begin
         TPress:=press;
         Tval:=psf6;
         TPQF1:=sf6_pQF1;
         TBottle:=stNBNum;
         TUNIT:=18;  //Parts per thousand (16) or trillion (18) ???
         end;
      30: begin
         TPress:=press;
         Tval:=c14;
         Tvalerr:=c14_err;
         TPQF1:=c14_pQF1;
         TBottle:=stNBNum;
         TUNIT:=11;  //Per-mille deviation
         end;
      31: begin
         TPress:=press;
         Tval:=he3;
         Tvalerr:=he3_err;
         TPQF1:=he3_pQF1;
         TBottle:=stNBNum;
         TUNIT:=10;  //
         end;
      32: begin
         TPress:=press;
         Tval:=he;
         Tvalerr:=he_err;
         TPQF1:=he_pQF1;
         TBottle:=stNBNum;
         TUNIT:=12;  //Nano-mole per kilogram
         end;
      33: begin
         TPress:=press;
         Tval:=neon;
         Tvalerr:=neon_err;
         TPQF1:=neon_pQF1;
         TBottle:=stNBNum;
         TUNIT:=12;  //Nano-mole per kilogram
         end;
      34: begin
         TPress:=press;
         Tval:=h3;
         Tvalerr:=h3_err;
         TPQF1:=h3_pQF1;
         TBottle:=stNBNum;
         TUNIT:=8;  // TU Tritium Unit
         end;
      end;{case}



   //append to CDS
   with CDS_DSC do begin
      Append;
      FieldByName('ID').AsInteger:=kst;
      FieldByName('Press').AsFloat:=TPress;
      FieldByName('Val').AsFloat:=TVal;
      if (kTBL>29) then FieldByName('ValErr').AsFloat:=TValErr;
      FieldByName('PQF1').AsInteger:=0;
      FieldByName('PQF2').AsInteger:=0;
      FieldByName('SQF').AsInteger:=0;
      FieldByName('Bottle').AsInteger:=stNBNum;
      FieldByName('Station').AsInteger:=stationN;
      FieldByName('Cast').AsInteger:=castN;
      FieldByName('Units_ID').AsInteger:=UnitID[ktbl];
      Post;
   end;

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
{CN}for c:=1 to cast_maxN do begin       //cast number
     CDS_DSC.Filter:='CAST='+inttostr(c);
     CDS_DSC.Filtered:=true;            //filter by cast
     CDS_DSC.IndexFieldNames:='Press';  //sort by press


{CAST}if CDS_DSC.IsEmpty=false then begin
      PRF_count:=PRF_count+1;

      CDS_DSC.First;
{PRF}while not CDS_DSC.EOF do begin


//write if value exists
//on disk
{V}if (CDS_DSC.FieldByName('Val').AsFloat<>-9999) and (ktbl<=29) then begin
       writeln(out,inttostr(PRF_count),
       #9,floattostr(CDS_DSC.FieldByName('Press').AsFloat),
       #9,floattostr(CDS_DSC.FieldByName('Val').AsFloat),
       #9,inttostr(CDS_DSC.FieldByName('PQF1').AsInteger),
       #9,inttostr(CDS_DSC.FieldByName('PQF2').AsInteger),
       #9,inttostr(CDS_DSC.FieldByName('SQF').AsInteger),
       #9,inttostr(CDS_DSC.FieldByName('Bottle').AsInteger),
       #9,inttostr(CDS_DSC.FieldByName('Units_ID').AsInteger));

//write into DB
       if CheckBox2.Checked then
       with frmdm.q3 do begin
         Close;
         SQL.Clear;
         SQL.Add(' insert into ');
         SQL.Add(trim(TblName[ktbl]));
         SQL.Add(' (ID, PRES, VAL, PQF1, PQF2, SQF, BOTTLE_NUMBER, UNITS_ID) ');
         SQL.Add(' values ');
         SQL.Add(' (:ID, :PRES, :VAL, :PQF1, :PQF2, :SQF, :BOTTLE_NUMBER, :UNITS_ID) ');
         ParamByName('ID').AsInteger:=PRF_count;
         ParamByName('PRES').AsFloat:=CDS_DSC.FieldByName('Press').AsFloat;
         ParamByName('VAL').AsFloat:=CDS_DSC.FieldByName('Val').AsFloat;
         ParamByName('PQF1').AsInteger:=CDS_DSC.FieldByName('PQF1').AsInteger;
         ParamByName('PQF2').AsInteger:=CDS_DSC.FieldByName('PQF2').AsInteger;
         ParamByName('SQF').AsInteger:=CDS_DSC.FieldByName('SQF').AsInteger;
         ParamByName('BOTTLE_NUMBER').AsInteger:=CDS_DSC.FieldByName('Bottle').AsInteger;
         ParamByName('UNITS_ID').AsInteger:=CDS_DSC.FieldByName('Units_ID').AsInteger;
         ExecSQL;
       end;
       frmdm.TR.CommitRetaining;
{V}end;

{V}if (CDS_DSC.FieldByName('Val').AsFloat<>-9999) and (ktbl>29) then begin

       writeln(out,inttostr(PRF_count),
       #9,floattostr(CDS_DSC.FieldByName('Press').AsFloat),
       #9,floattostr(CDS_DSC.FieldByName('Val').AsFloat),
       #9,floattostr(CDS_DSC.FieldByName('ValErr').AsFloat),
       #9,inttostr(CDS_DSC.FieldByName('PQF1').AsInteger),
       #9,inttostr(CDS_DSC.FieldByName('PQF2').AsInteger),
       #9,inttostr(CDS_DSC.FieldByName('SQF').AsInteger),
       #9,inttostr(CDS_DSC.FieldByName('Bottle').AsInteger),
       #9,inttostr(CDS_DSC.FieldByName('Units_ID').AsInteger));
       if CheckBox2.Checked then

       if CheckBox2.Checked then
       with frmdm.q3 do begin
         Close;
         SQL.Clear;
         SQL.Add(' insert into ');
         SQL.Add(TblName[ktbl]);
         SQL.Add(' (ID, PRES, VAL, VALERR, PQF1, PQF2, SQF, BOTTLE_NUMBER, UNITS_ID) ');
         SQL.Add(' values ');
         SQL.Add(' (:ID, :PRES, :VAL, :VALERR, :PQF1, :PQF2, :SQF, :BOTTLE_NUMBER, :UNITS_ID) ');
         ParamByName('ID').AsInteger:=PRF_count;
         ParamByName('PRES').AsFloat:=CDS_DSC.FieldByName('Press').AsFloat;
         ParamByName('VAL').AsFloat:=CDS_DSC.FieldByName('Val').AsFloat;
         ParamByName('VALERR').AsFloat:=CDS_DSC.FieldByName('ValErr').AsFloat;
         ParamByName('PQF1').AsInteger:=CDS_DSC.FieldByName('PQF1').AsInteger;
         ParamByName('PQF2').AsInteger:=CDS_DSC.FieldByName('PQF2').AsInteger;
         ParamByName('SQF').AsInteger:=CDS_DSC.FieldByName('SQF').AsInteger;
         ParamByName('BOTTLE_NUMBER').AsInteger:=CDS_DSC.FieldByName('Bottle').AsInteger;
         ParamByName('UNITS_ID').AsInteger:=CDS_DSC.FieldByName('Units_ID').AsInteger;
         ExecSQL;
       end;
       frmdm.TR.CommitRetaining;

{V}end;


     CDS_DSC.Next;
{PRF}end; //filtered by cast number and sorted station
{CAST}end; //if cast exists
{CN}end; // 1..cast_maxN

      CDS_DSC.Filtered:=false;
{ST}end; //GLODAP stations

   if CDS_DSC.Active=true then CDS_DSC.Close;
      CDS_DSC.Free;

      closefile(dat);
      closefile(out);

{TBL}end; {ktbl 1..34}

      memo1.Lines.Add('');
      memo1.Lines.Add('Loading completed');
      memo1.Lines.Add('End:'+datetimetostr(NOW));

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

  (* 13	P_CFC11_BOTTLE		6	press val    pQF1 pQF2 sQF	CV	CFC11		Halogenated transient tracer CFC11  *)
     'CREATE TABLE P_CFC11_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 13a P_PCFC11_BOTTLE		6	press val    pQF1 pQF2 sQF	CV	CFC11		Halogenated transient tracer CFC11  *)
     'CREATE TABLE P_PCFC11_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 14	P_CFC12_BOTTLE		6	press val    pQF1 pQF2 sQF	CV	CFC12		Halogenated transient tracer CFC12 *)
     'CREATE TABLE P_CFC12_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 14	P_PCFC12_BOTTLE		6	press val    pQF1 pQF2 sQF	CV	CFC12		Halogenated transient tracer CFC12 *)
     'CREATE TABLE P_PCFC12_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 15	P_CFC113_BOTTLE		6	press val    pQF1 pQF2 sQF	CV	CFC113		Halogenated transient tracer CFC113 *)
     'CREATE TABLE P_CFC113_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 15a	P_PCFC113_BOTTLE		6	press val    pQF1 pQF2 sQF	CV	CFC113		Halogenated transient tracer CFC113 *)
     'CREATE TABLE P_PCFC113_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
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
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (*16a	P_CC14_BOTTLE		6	press val    pQF1 pQF2 sQF	CV	CC14		Halogenated transient tracer CC14 *)
     'CREATE TABLE P_PCC14_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 17	P_SF6_BOTTLE		6	press val    pQF1 pQF2 sQF		SF6		Sulfur hexafluoride  *)
     'CREATE TABLE P_SF6_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
     '   pQF1           SMALLINT, '+LineEnding+
     '   pQF2           SMALLINT, '+LineEnding+
     '   sQF            SMALLINT, '+LineEnding+
     '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
     '   UNITS_ID        BIGINT '+LineEnding+
     '); '+LineEnding+

  (* 17a P_PSF6_BOTTLE		6	press val    pQF1 pQF2 sQF		SF6		Sulfur hexafluoride  *)
     'CREATE TABLE P_PSF6_BOTTLE ( '+LineEnding+
     '   ID             BIGINT NOT NULL, '+LineEnding+
     '   PRES           DECIMAL(9,4) NOT NULL, '+LineEnding+
     '   VAL            DECIMAL(8,4) NOT NULL, '+LineEnding+
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
     'ALTER TABLE P_PCFC11_BOTTLE ADD CONSTRAINT FK_P_PCFC11_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_CFC12_BOTTLE ADD CONSTRAINT FK_P_CFC12_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_PCFC12_BOTTLE ADD CONSTRAINT FK_P_PCFC12_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_CFC113_BOTTLE ADD CONSTRAINT FK_P_CFC113_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_PCFC113_BOTTLE ADD CONSTRAINT FK_P_PCFC113_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_CC14_BOTTLE ADD CONSTRAINT FK_P_CC14_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_PCC14_BOTTLE ADD CONSTRAINT FK_P_PCC14_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_SF6_BOTTLE ADD CONSTRAINT FK_P_SF6_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
     'ALTER TABLE P_PSF6_BOTTLE ADD CONSTRAINT FK_P_PSF6_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
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

