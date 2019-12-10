unit osload_WOD18;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  FileCtrl, Variants, IBConnection, DB, sqldb, SQLScript;


type

  { TfrmloadWOD18 }

  TfrmloadWOD18 = class(TForm)
    btnCreateWOD: TBitBtn;
    btnPreprocessing: TBitBtn;
    CheckBox1: TCheckBox;
    FileListBox1: TFileListBox;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    Memo2: TMemo;

    procedure btnCreateWODClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure btnPreprocessingClick(Sender: TObject);
    procedure ConvertOSD(var StInFile:integer);
    procedure ConvertToFloat(Str:string; var ParVal:real);

  private

  public

  end;

var
  frmloadWOD18: TfrmloadWOD18;
  mik_stTotal:integer;
  VarCount_arr :array [1..50] of integer;    //count variables appearance
  f_dat, f_statistics, f_station: text;
  f_temp, f_salt, f_oxyg: text;

implementation

uses osmain, procedures, GibbsSeaWater;

{$R *.lfm}

{ TfrmloadWOD18 }

procedure TfrmloadWOD18.FormShow(Sender: TObject);
begin
  memo1.Clear;
  memo2.Clear;
  FileListBox1.Clear;
end;




procedure TfrmloadWOD18.btnPreprocessingClick(Sender: TObject);
var
i,mik: integer;
StInFile,StInDataset:integer;
sym:char;
StrOut:string;
PathSource,FileForRead,PathOut,FileOut:string;
WOD18Var:array[1..45] of string;


begin

 PathSource:='c:\Users\ako071\AK\datasets\WOD18\YEARLY OSD OBS\test\';
 //PathSource:='c:\Users\ako071\AK\datasets\WOD18\YEARLY OSD OBS\data\';
 FileListBox1.Directory:=PathSource;
 PathOut:='c:\Users\ako071\AK\datasets\WOD18\YEARLY OSD OBS\Output\';

   FileOut:=PathOut+'Statistics.dat';
   StrOut:= 'Cast#'+#9+'Cast#File'+#9+'WOD_cast_num'+#9+'DateTime'+
   #9+'Latitude'+#9+'Longitude'+#9+'VarNum'+#9+'VarCodes';
   AssignFile(f_statistics,FileOut);
   rewrite(f_statistics);
   writeln(f_statistics,StrOut);

   FileOut:=PathOut+'Station.dat';
   StrOut:='ID'+#9+'LATITUDE'+#9+'LONGITUDE'+#9+'DATEANDTIME'+#9+'BOTTOMDEPTH'
   +#9+'LASTLEV_M'+#9+'LASTLEV_DBAR'+#9+'CRUISE_ID'+#9+'INSTRUMENT_ID'
   +#9+'ST_NUM_ORIGIN'+#9+'ST_ID_ORIGIN'+#9+'CAST_NUMBER'
   +#9+'QCFLAG'+#9+'STVERSION'+#9+'MERGED'+#9+'DATE_ADDED'+#9+'DATE_UPDATED';
   AssignFile(f_station,FileOut);
   rewrite(f_station);
   writeln(f_station,StrOut);

   StrOut:='ID'+#9+'DBAR'+#9+'M'+#9+'VAL'+#9+'PQF1'
   +#9+'PQF2'+#9+'SQF'+#9+'BOTTLE_NUMBER'+#9+'UNITS_ID';

   FileOut:=PathOut+'TEMPERATURE.dat';
   AssignFile(f_temp,FileOut); rewrite(f_temp); writeln(f_temp,StrOut);
   FileOut:=PathOut+'SALINITY.dat';
   AssignFile(f_salt,FileOut); rewrite(f_salt); writeln(f_salt,StrOut);
   FileOut:=PathOut+'OXYGEN.dat';
   AssignFile(f_oxyg,FileOut); rewrite(f_oxyg); writeln(f_oxyg,StrOut);



   if checkbox1.Checked then
   memo1.Lines.Add('absnum'+#9+'WODCastNum'+#9+'StFlag'+#9+'StLat'
      +#9+'StLon'+#9+'DateTime'+#9+'ShipCode');



      for i:=1 to 50 do VarCount_arr[i]:=0;
      mik_stTotal:=0;
      StInDataset:=0;
{..........processing files from FileListBox..........}
{FLB}for i:=0 to (FileListBox1.Items.Count-1) do begin
      FileForRead:=PathSource+trim(FileListBox1.Items.Strings[i]);
      AssignFile(f_dat,FileForRead);
      reset(f_dat);

      {!!!counting number of casts by WOD version identifier in the first position}
      {...actually not correct since the identifier 'C' can be inside the station}
      {...also at the first position}

      {...start file conversion}
      ConvertOSD(StInFile);

      StInDataset:=StInDataset+StInFile;

      memo1.Lines.Add(inttostr(i)
      +#9+FileForRead
      +#9+inttostr(StInFile)
      );

      closefile(f_dat);
      Application.ProcessMessages;
{FLB}end;    {end files processing}


{..........VARIABLES STATIASTICS..........}
//maximum variable code in WOD18 is 43 (table 3 in user manual)
   for i:=1 to 45 do WOD18Var[i]:='RESERVED';
   WOD18Var[1]:='TEMPERATURE';
   WOD18Var[2]:='SALINITY';
   WOD18Var[3]:='OXYGEN';
   WOD18Var[4]:='PHOSPHATE';
   WOD18Var[6]:='SILICATE';
   WOD18Var[8]:='NITRATE';
   WOD18Var[9]:='PH';
   WOD18Var[11]:='TCHL';
   WOD18Var[17]:='ALK';
   WOD18Var[20]:='PCO2';
   WOD18Var[21]:='DIC';
   WOD18Var[25]:='WPRES';
   WOD18Var[33]:='H3';
   WOD18Var[34]:='HE';
   WOD18Var[35]:='HE3';
   WOD18Var[36]:='C14';
   WOD18Var[37]:='C13';
   WOD18Var[38]:='ARGON';
   WOD18Var[39]:='NEON';
   WOD18Var[40]:='CFC11';
   WOD18Var[41]:='CFC12';
   WOD18Var[42]:='CFC113';
   WOD18Var[43]:='O18';


    memo1.Lines.Add('');
    memo1.Lines.Add('#'+#9+'VarCode'+#9+'Stations with variable');

    writeln(f_statistics, '');
    writeln(f_statistics, '#',#9,'VarCode',#9,'StationsWithVariable');

      mik:=0;
    for i:=1 to 50 do begin
    if VarCount_arr[i]<>0 then begin
      mik:=mik+1;
      memo1.Lines.Add(inttostr(mik)+#9+inttostr(i)+#9+inttostr(VarCount_arr[i])
      +#9+WOD18Var[i]);
      writeln(f_statistics,inttostr(mik),#9,inttostr(i),#9,inttostr(VarCount_arr[i])
      ,#9,WOD18Var[i]);
    end;
    end;

    memo1.Lines.Add('StInDataset='+inttostr(StInDataset));
    writeln(f_statistics,'StInDataset=',inttostr(StInDataset));

    closefile(f_statistics);
    closefile(f_station);
    closefile(f_temp);
    closefile(f_salt);
    closefile(f_oxyg);
end;


{convert WOD2018 Ocean Station data}
procedure TfrmloadWOD18.ConvertOSD(var StInFile:integer);
var
k,kb,kL,k_var,mik_line,mik_st,s,k_lev,k_par:integer;
BNF,SL,line,NC,RC,TF,BSH,SHNC,BBH:integer;
WODCastNum,WODCruiseNum,mEx,ParFlag:integer;
levnum,proftype,varnum,V_QF,ST_QF,mdatnum,m,varcode,varspcode,OCLShipCode:integer;
StProjectCode,StInstituteCode,SHCode:integer;
StDepthSource,DepthErFlag1,DepthErFlag2,ParErFlag1,ParErFlag2:integer;
countDup,TSProbeType:integer;
StYear,StMonth,StDay,StHour,StMin,StSec,StMSec:word;
StTime,StLat,StLon,ParMetaData,SHCodeValue,ErrVal,stlev:real;
ParVal :real;
buf:char;
st,wst,sf,str,shstr,countryname,shipname:string;
StCountryCode :string[2];
NODCShipCode :string;
StCountryName :string[40];
StVesselName :string[40];
StCountryCode_Platform,CountryName_Platform,VarAtSt:string;
VarCode_arr :array [1..50] of integer;
lev_arr :array[1..50000] of real;
count_temperature,count_salinity,count_oxygen:integer;
count_phosphate,count_silicate,count_nitrate,count_pH :integer;
count_chlorophyll,count_alkalinity,count_pCO2,count_tCO2,count_NaNi:integer;

StDateDT,StTimeDT,StDateTime:TDateTime;
StFlag,absnum,stversion:integer;
StSource,OrStNum,VesselCruiseID,SourceDataOrigin:string;
MonthErr,TimeErr:Boolean;

{Meteo}
StAirTemp, StTWet, StAirPressure, WindDir, WindSpeed,
CloudCover, CloudType, Visibility, AbsHum,
WHeight, Wavedir, Waveperiod, Seastate, StWeather, Watercolor,
WaterTransp, SurfTemp, SurfSalt:Variant;

//ocean.fdb
Lev_m,Lev_dbar,LastLev_m,LastLev_dbar:real;
PQF1,PQF2,SQF,BNum,UID:integer; //primary QF1,QF2, secondary QF, Niskin bottle, our unit ID
OrCastNum:integer;

begin

    line:=0;
    mik_st:=0;
{WFR}repeat   //whole file reading

     {default}
     st:='';
     StFlag:=0;
     VesselCruiseID:='UNKNOWN';
     SourceDataOrigin:='UNKNOWN';
     CountryName:='UNKNOWN';
     ShipName:='UNKNOWN';

{..........create WST..........}
    {...first line at a station}
    for kb:=1 to 80 do begin read(f_dat,buf); st:=concat(st,buf); end;
    readln(f_dat);
    line:=line+1;
    {...Whole Station (WST) -string containing all stations' bytes/symbols}
    wst:=st;
    {...Bytes in Next Field (BNF)}
    {...first BNF in the second symbol}
    BNF:=strtoint(copy(st,2,1));
    SL :=strtoint(copy(st,3,BNF));  //WST length
    mik_line:=trunc(SL/80);
    if (SL MOD 80 = 0) then mik_line:=mik_line-1; //number of lines at a station
    {...concatenation of all lines at a station}
   for kL:=1 to mik_line do begin
    readln(f_dat,st); line:=line+1;
    wst:=wst+st;
   end;
    wst:=trim(wst);
    mik_st:=mik_st+1;  //count stations in file
    mik_stTotal:=mik_stTotal+1;  //count stations in all files
    absnum:=mik_stTotal;

    {...find C in the first position inside station string}
     //for i:=2 to length(wst) do begin
     // if wst[i]='C' then showmessage('C found around line='+inttostr(line));
     //end;

   //memo1.Lines.Add('mik_st='+inttostr(mik_st));
   //memo1.Lines.Add(wst);


{..........PRIMARY HEADER..........}
{..........WST analysis..........}
//(column to read) = (number of symbols for a station length)+ A1(C) + I1(BNF) + I1(BNF)
   NC:=BNF+3;
   BNF:=strtoint(copy(wst,NC,1)); {bytes in WOD unique cast number}
   NC:=NC+1;
   WODCastNum:=strtoint(copy(wst,NC,BNF));   {WOD unique cast number identification}
   NC:=NC+BNF;
   StCountryCode:=copy(wst,NC,2);            {country code}

   NC:=NC+2;
   BNF:=strtoint(copy(wst,NC,1)); {bytes in Cruise Number}
   NC:=NC+1;
   WODCruiseNum:=strtoint(copy(wst,NC,BNF));  {WOD Cruise Number identification}
   VesselCruiseID:=copy(wst,NC,BNF);
   NC:=NC+BNF;
   StYear:=strtoint(copy(wst,NC,4));       {year}
   NC:=NC+4;
   StMonth:=strtoint(copy(wst,NC,2));      {month}
   NC:=NC+2;
   StDay:=strtoint(copy(wst,NC,2));        {day}
   NC:=NC+2;



   {...time}
      StTime:=0;
      RC:=NC;  {fix read column}
      SF:=copy(wst,RC,1);
      TF:=strtoint(copy(wst,NC+1,1));
      str:=copy(wst,RC,TF+3);
      ConvertToFloat(str,StTime);
      if(SF='-') then NC:=NC+1 else NC:=RC+TF+3;

   {...lat}
      RC:=NC;  {fix read column}
      SF:=copy(wst,RC,1);
      TF:=strtoint(copy(wst,NC+1,1));
      str:=copy(wst,RC,TF+3);
      {showmessage(inttostr(RC)+' '+inttostr(TF)+' '+SF+' '+str);}
      ConvertToFloat(str,StLat);
      if(SF='-') then NC:=NC+1 else NC:=RC+TF+3;

   {...lon}
      RC:=NC;  {fix read column}
      SF:=copy(wst,RC,1);
      TF:=strtoint(copy(wst,NC+1,1));
      str:=copy(wst,RC,TF+3);
      ConvertToFloat(str,StLon);
      if(SF='-') then NC:=NC+1 else NC:=RC+TF+3;
{showmessage('SF:'+SF+'  RC:'+' '+inttostr(RC)+'  TF:'+' '+inttostr(TF)+'   NC:'+' '+inttostr(NC));}

   {...levels}
     BNF:=strtoint(copy(wst,NC,1)); {bytes in LevNum}
     NC:=NC+1;
{showmessage(inttostr(nc)+' '+inttostr(BNF)+' '+copy(wst,NC,BNF));}
     LevNum  :=strtoint(copy(wst,NC,BNF)); {number of levels }
     NC:=NC+BNF; ProfType:=strtoint(copy(wst,NC,1));   {profile type 0/1}
     NC:=NC+1; VarNum:=strtoint(copy(wst,NC,2));     {number of parameters }
     NC:=NC+2;

    {...convert data and time}
     if (StDay=0) then StDay:=1;
     if(StTime>=0) then begin
                   StHour:=trunc(StTime);
                   StMin:=round(frac(StTime)*60);
                   StSec:=round(frac(StMin)*60);
                   end;
     if (StTime<0) then begin
                   StHour:=0;
                   StMin:=0;
                   StSec:=0;
                   StFlag:=StFlag+16; {time missing}
                   end;


  {function from ODBprocedures module}
   StDateTime:=Procedures.DateEncode(StYear,StMonth,StDay,StHour,StMin,MonthErr,TimeErr);


  {StDateDT:=DateEncode(StYear,StMonth,StDay,StHour,StMin,MonthErr,TimeErr);
   StTimeDT:=DateEncode(StYear,StMonth,StDay,StHour,StMin,MonthErr,TimeErr);
   DecodeDate(StDateDT,StYear,StMonth,StDay);
   DecodeTime(StTimeDT,StHour,StMin,StSec,StMSec);}
  if MonthErr=true    then  StFlag:=StFlag+32; {if days in month out limit}
  if TimeErr=true  then  StFlag:=StFlag+64; {if date changed hour 24 or minutes 60}


   {...variable codes, quality flags, metadata}
{v}if (varnum>0) and (levnum>0) then begin
    ST_QF:=4; //ocean.fdb QF =acceptable (WOD algorithms on variables passed successfully)
{c}for k_var:=1 to VarNum do begin
     BNF:=strtoint(copy(wst,NC,1));
{memo1.Lines.Add('>>>>>>>'+inttostr(k_var)+' -> '+copy(wst,NC,BNF)+'  NC:'+inttostr(nc));}
     NC:=NC+1;   VarCode:=strtoint(copy(wst,NC,BNF)); {variable code}
     VarCode_arr[k_var]:=VarCode;
     NC:=NC+BNF; V_QF  :=strtoint(copy(wst,NC,1));   {quality control flag for variable}

     //if a variable in the cast not accepted by one of WOD QC algorithms QF=2 (ocean.fdb) is set (suspicious cast as a whole)
     if V_QF>0 then ST_QF:=2;

     NC:=NC+1;   BNF    :=strtoint(copy(wst,NC,1));
     NC:=NC+1;   MDatNum:=strtoint(copy(wst,NC,BNF)); {number of variable-specific metadata}
     NC:=NC+BNF;

  {  if CheckBox1.Checked then
    memo1.Lines.Add('...kvar: '+inttostr(k_var)
     +#9+'...VarCode: '+inttostr(VarCode)
     +#9+'...V_QF  : '+inttostr(V_QF)
     +#9+'...MDatNum: '+inttostr(MDatNum)); }


     {...read in variable-specific metadata}
{m}if (MDatNum>0) then begin
   for m:=1 to MDatNum do begin
      BNF:=strtoint(copy(wst,NC,1));
      NC:=NC+1; VarSpCode:=strtoint(copy(wst,NC,BNF));
{memo1.Lines.Add('>>>>>>>'+inttostr(m)+' -> '+copy(wst,NC,BNF));}
      NC:=NC+BNF;
      RC:=NC;  {fix read column}
      SF:=copy(wst,RC,1);
      TF:=strtoint(copy(wst,NC+1,1));
      str:=copy(wst,RC,TF+3);
      ConvertToFloat(str,ParMetaData);
      if(SF='-') then NC:=NC+1 else NC:=RC+TF+3;


   end;
{m}end;
{c}end;
    //if ST_QF<>0 then memo1.Lines.Add('ST_QF<>0');
{v}end;

    {...character data and principal investigator}
    BNF:=strtoint(copy(wst,NC,1)); {showmessage(inttostr(NC)+'  BNF: '+inttostr(BNF));}
    NC:=NC+1;
{cd}if BNF>0 then begin
     BSH:=strtoint(copy(wst,NC,BNF)); {total bytes for character data}
     {showmessage(inttostr(NC)+'  BSH [CharDataSection]: '+inttostr(BSH));}
     NC:=NC+BNF+BSH; {skip all bytes in character data section}
{cd}end;


    {...SECONDARY HEADER}
    BNF:=strtoint(copy(wst,NC,1)); {showmessage(inttostr(NC)+'  NewBNF: '+inttostr(BNF));}
{sh}if BNF>0 then begin
     BNF:=strtoint(copy(wst,NC,1));
     NC:=NC+1; BSH:=strtoint(copy(wst,NC,BNF)); {total bytes for secondary header}
     SHstr:=copy(wst,NC+BNF,BSH); {Sec>Header string}
     {showmessage(inttostr(mik_st)+' '+inttostr(NC)+'SecHeaderSec: '+' '+
     inttostr(BSH)+' '+SHstr);}
     NC:=NC+BNF+BSH; {skip all bytes in secondary header}

      SHnc:=1;  {next col. in SHstr string}
     {...read in Sec.Header Data}
     BNF:=strtoint(copy(SHstr,SHnc,1)); {showmessage('BNF for s:  '+inttostr(BNF));}
     SHnc:=SHnc+1;
     s:=strtoint(copy(SHstr,SHnc,BNF)); {number of entries}
     {showmessage('S:  '+inttostr(s));}
     SHnc:=SHnc+BNF;

       StProjectCode:=-9;
       StInstituteCode:=-9;
       StDepthSource:=-9;
       TSProbeType:=0; {unknown codes from OCL codes 0-8}
       OCLShipCode:=9999;
       ShipName:='UNKNOWN';
       OrStNum:='';
       OrCastNum:=1;

       StAirTemp:=null; StTWet:=null; StAirPressure:=null; WindDir:=null;
       WindSpeed:=null; CloudCover:=null; CloudType:=null; Visibility:=null;
       AbsHum:=null; WHeight:=null; Wavedir:=null; Waveperiod:=null;
       Seastate:=null; StWeather:=null; Watercolor:=null; WaterTransp:=null;
       SurfTemp:=null; SurfSalt:=null;

{s}for k:=1 to s do begin
       BNF:=strtoint(copy(SHstr,SHnc,1));
       SHnc:=SHnc+1;   SHCode:=strtoint(copy(SHstr,SHnc,BNF)); {showmessage(inttostr(SHnc)+' SHCode : '+inttostr(SHCode));}
       SHnc:=SHnc+BNF;

      RC:=SHnc;  {fix read column}
      SF:=copy(SHstr,RC,1);
      TF:=strtoint(copy(SHstr,RC+1,1));
      str:=copy(SHstr,RC,TF+3);        {showmessage('SHnc: '+inttostr(SHnc)+' '+str);}
      ConvertToFloat(str,SHCodeValue); {showmessage('SHCodeValue : '+floattostr(SHCodeValue));}
      SHnc:=SHnc+TF+3;

      case SHCode of
      2:  StProjectCode:=round(SHCodeValue);  //Код проекта
      3:  begin
           OCLShipCode:=round(SHCodeValue);   //OCL код судна
           if OCLShipCode<0 then OCLShipCode:=9999;

             NODCShipCode:='';
              if OCLShipCode<>9999 then begin
                 CountryName_Platform:='';

                  if StCountryCode_Platform<>'99' then begin
                     StCountryCode:=StCountryCode_Platform;
                     CountryName:=CountryName_Platform;
                  end;
              end;
           end;
      4:  StInstituteCode:=round(SHCodeValue); //Код института
      5:  OrCastNum:=round(SHCodeValue);       //Cast/Tow number
      7:  OrStNum:=floattostr(SHCodeValue);    //Номер из источника
      10: StDepthSource:=round(SHCodeValue);   //Глубина из источника
      14: WaterColor:=round(SHCodeValue);      //Код цвета воды
      15: WaterTransp:=round(SHCodeValue);     //Код прозрачности
      16: begin
          WaveDir:=round(SHCodeValue);         //Направление волн
          WaveDir:=WaveDir*10;
            if WaveDir>360 then WaveDir:=null;
            if WaveDir=360 then WaveDir:=WaveDir-360;
          end;
      17: WHeight:=SHCodeValue/2;          //Высота волн
      18: SeaState:=round(SHCodeValue);    //Sea State
      20: begin
          WavePeriod:=round(SHCodeValue);  //Wave period
          WavePeriod:=10-WavePeriod;
          end;
      21: begin
          WindDir:=round(SHCodeValue); //Wind Direction
          WindDir:=WindDir*10;
            if WindDir>360 then WindDir:=null;
            if WindDir=360 then WindDir:=WindDir-360;
          end;
      22: WindSpeed:=SHCodeValue/2;        //Wind Speed
      23: StAirPressure:=SHCodeValue;      //Air Pressure
      24: StAirTemp:=SHCodeValue;          //Air Temperature
      25: StTWet:=SHCodeValue;             //Wet Bulb Temperature
      26: StWeather:=round(SHCodeValue);   //Weather State
      27: begin
          CloudType:=round(SHCodeValue);   //CloudType
             case CloudType of
               0: CloudType:='CI';
               1: CloudType:='CC';
               2: CloudType:='CS';
               3: CloudType:='AC';
               4: CloudType:='AS';
               5: CloudType:='NS';
               6: CloudType:='SC';
               7: CloudType:='ST';
               8: CloudType:='CU';
               9: CloudType:='CB';
             end;
          end;
      28: begin
            CloudCover:=round(SHCodeValue);  //CloudCover
            if CloudCover=9 then CloudCover:=null;
          end;
      29: TSProbeType:=round(SHCodeValue); //Instrument
      41: Visibility:=round(SHCodeValue);  //Код видимости
      45: AbsHum:=SHCodeValue;             //Абсолютная влажность
      46: SurfTemp:=SHCodeValue;           //Поверхностная температура
      47: SurfSalt:=SHCodeValue;           //Поверхностная соленость
      end;
{s} end;
{sh}end;


    {...biological header}
     BNF:=strtoint(copy(wst,NC,1)); {showmessage(inttostr(NC)+'  NewBNF: '+inttostr(BNF));}
    if BNF>0 then begin
     BBH:=strtoint(copy(wst,NC+1,BNF));
     {showmessage(inttostr(NC)+' BBH BiologicalHeaderSection: '+inttostr(BBH));}
     NC:=NC+BNF+BBH; {skip all bytes in biological header}
    end;


{memo}if checkbox1.Checked then begin
   memo1.Lines.Add(inttostr(absnum)
    +#9+inttostr(WODCastNum)
    +#9+inttostr(StFlag)
    +#9+floattostr(StLat)
    +#9+floattostr(StLon)
    +#9+datetimetostr(StDateTime)
//    +#9+datetostr(StDateTime)
//    +#9+timetostr(StDateTime)
//    +#9+StSource
//    +#9+inttostr(StVersion)
//    +#9+CountryName
//    +#9+ShipName
//    +#9+inttostr(StDepthSource)
//    +#9+StCountryCode
    +#9+inttostr(OCLShipCode)
//    +#9+inttostr(OCLShipCode)+' -> '+NODCShipCode
//    +#9+OrStNum
//    +#9+inttostr(StProjectCode)
//    +#9+inttostr(StInstituteCode)
//    +#9+inttostr(TSProbeType)
//    +#9+inttostr(WODCastNum)
//    +#9+VesselCruiseID
    );

   {memo2.Lines.Add(
        vartostr(WaterColor)
    +#9+vartostr(WaterTransp)
    +#9+vartostr(WaveDir)
    +#9+vartostr(WHeight)
    +#9+vartostr(SeaState)
    +#9+vartostr(WavePeriod)
    +#9+vartostr(WindDir)
    +#9+vartostr(WindSpeed)
    +#9+vartostr(StAirPressure)
    +#9+vartostr(StAirTemp)
    +#9+vartostr(StTWet)
    +#9+vartostr(StWeather)
    +#9+vartostr(CloudType)
    +#9+vartostr(CloudCover)
    +#9+vartostr(Visibility)
    +#9+vartostr(AbsHum)
    +#9+vartostr(SurfTemp)
    +#9+vartostr(SurfSalt));}
{memo}end;


   VarAtSt:='';
   for k_par:=1 to VarNum do begin
    VarAtSt:=VarAtSt+' '+inttostr(VarCode_arr[k_Par]);
    //writeln(f_statistics,'VarCode=',inttostr(VarCode_arr[k_Par]));
    VarCount_arr[VarCode_arr[k_Par]]:=VarCount_arr[VarCode_arr[k_Par]]+1;
   end;


   writeln(f_statistics,inttostr(mik_stTotal),
   #9,inttostr(mik_st),
   #9,inttostr(WODCastNum),
   #9,datetimetostr(StDateTime),
   #9,floattostr(StLat),
   #9,floattostr(StLon),
   #9,inttostr(VarNum),    //number of variables at station
   #9,VarAtSt);            //variables codes at station


{..........PROFILE DATA.........}
{PD}if LevNum>0 then begin
   count_temperature:=0;
   count_salinity:=0;
   count_oxygen:=0;
   count_phosphate:=0;
   count_silicate:=0;
   count_nitrate:=0;
   count_pH:=0;
   count_chlorophyll:=0;
   count_alkalinity:=0;
   count_pCO2:=0;
   count_tCO2:=0;
   count_NaNi:=0;
   mEx:=0;

    LastLev_m:=-9;
{p1}for k_lev:=1 to LevNum do begin
     {read in depth}
      NC:=NC+1;
      RC:=NC;  {fix read column}
      SF:=copy(wst,RC,1);
      TF:=strtoint(copy(wst,NC+1,1));
      str:=copy(wst,RC,TF+3);  {showmessage('k_lev: '+inttostr(k_lev)+' '+str);}
      ConvertToFloat(str,StLev);

     // if CheckBox1.Checked then
   //   memo1.Lines.Add('+++++Lev: '+floattostr(StLev));

      lev_arr[k_lev]:=StLev;
      if(SF='-') then NC:=NC+1 else
      begin
      NC:=RC+TF+3;
                  DepthErFlag1:=strtoint(copy(wst,NC,1));     {Depth Error Flag}
      NC:=NC+1;   DepthErFlag2:=strtoint(copy(wst,NC,1));     {Depth Error Flag Originator's}
      end;
      {write(fo_test,StLev:6:1);}

{p2}for k_par:=1 to VarNum do begin
      {read in parameter}
      NC:=NC+1;
      RC:=NC;  {fix read column}
      SF:=copy(wst,RC,1);
{p3}if(SF<>'-') then begin
      TF:=strtoint(copy(wst,NC+1,1));
      str:=copy(wst,RC,TF+3); {showmessage('k_par: '+inttostr(k_par)+' '+str);}
      ConvertToFloat(str,ParVal);
      {populate parameter arrays}
      NC:=RC+TF+3;
                  ParErFlag1:=strtoint(copy(wst,NC,1));     {Value quality control flag}
      NC:=NC+1;   ParErFlag2:=strtoint(copy(wst,NC,1));     {Originator's flag}

      //...assign DB QC flags
      if ParErFlag1>0 then PQF1:=2 else PQF1:=4;  //primary QF1
      PQF2:=PQF1;  //PQF2 can be changed afterwards by OceanShell
      SQF:=0;            //secondary QF
      BNum:=0;           //'NISKIN bottle number' UNKNOWN in WOD ???


{p3}end;

      if(SF='-') then ParVal:=-9;


      //TEOS: meters to dbar
      Lev_m:=-stLev;
      Lev_dbar:=GibbsSeaWater.gsw_p_from_z(Lev_m,stlat,0,0);
      Lev_m:=stLev;
      {m=0- depth to pressure, 1- pressure to depth}
      //Lev_m:=stLev;
      //procedures.Depth_to_Pressure(Lev_m,stLat,0,Lev_dbar);

      StDateTime:=Procedures.DateEncode(StYear,StMonth,StDay,StHour,StMin,MonthErr,TimeErr);

       ParFlag:=0;
      case VarCode_arr[k_par] of
      1: begin //#TEMPERATURE
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_temperature:=count_temperature+1;
         //if CheckBox1.Checked then
         //memo1.Lines.Add('lev temp QF '+#9+floattostr(stLev)+#9+floattostr(ParVal)+#9+floattostr(ParFlag));
         UID:=1; //ocean.fdb unit ID: Degrees Celsius
         writeln(f_temp,inttostr(absnum),
         #9,floattostrF(Lev_dbar,ffFixed,7,1),
         #9,floattostr(Lev_m),
         #9,floattostr(ParVal),
         #9,inttostr(PQF1), //Profile data, field 11: value quality control flag
         #9,inttostr(PQF2),
         #9,inttostr(SQF),
         #9,inttostr(BNum),
         #9,UID);
         //if Checkbox2.Checked then
         //InsertParameters('P_TEMPERATURE', Absnum, {count_temperature,} stLev, ParVal, ParFlag);
         end;
         end; {1}
      2: begin //#SALINITY
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_salinity:=count_salinity+1;
         UID:=2; //ocean.fdb unit ID: Dimensionless (unitless)
         writeln(f_salt,inttostr(absnum),
         #9,floattostrF(Lev_dbar,ffFixed,7,1),
         #9,floattostr(Lev_m),
         #9,floattostr(ParVal),
         #9,inttostr(PQF1), //Profile data, field 11: value quality control flag
         #9,inttostr(PQF2),
         #9,inttostr(SQF),
         #9,inttostr(BNum),
         #9,UID);
         //if Checkbox2.Checked then
         //InsertParameters('P_SALINITY', Absnum, {count_salinity,} stLev, ParVal, ParFlag);
         end;
         end;
      3: begin //#OXYGEN
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_oxygen:=count_oxygen+1;
         UID:=3; //ocean.fdb unit ID: Micromole per kilogram
         writeln(f_oxyg,inttostr(absnum),
         #9,floattostrF(Lev_dbar,ffFixed,7,1),
         #9,floattostr(Lev_m),
         #9,floattostr(ParVal),
         #9,inttostr(PQF1),     //Profile data, field 11: value quality control flag
         #9,inttostr(PQF2),
         #9,inttostr(SQF),
         #9,inttostr(BNum),
         #9,UID);
         //if Checkbox2.Checked then
         //InsertParameters('P_OXYGEN', Absnum, {count_oxygen,} stLev, ParVal, ParFlag);
         end;
         end;
      4: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_phosphate:=count_phosphate;
         //if Checkbox2.Checked then
         //InsertParameters('P_PHOSPHATE', Absnum, {count_phosphate,} stLev, ParVal, ParFlag);
         end;
         end;
      6: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_silicate:=count_silicate+1;
         //if Checkbox2.Checked then
         //InsertParameters('P_SILICATE', Absnum, {count_silicate,} stLev, ParVal, ParFlag);
         end;
         end;
      8: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_nitrate:=count_nitrate+1;
         //if Checkbox2.Checked then
         //InsertParameters('P_NITRATE', Absnum, {count_nitrate,} stLev, ParVal, ParFlag);
         end;
         end;
      9: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_ph:=count_ph+1;
         //if Checkbox2.Checked then
         //InsertParameters('P_PH', Absnum, {count_ph,} stLev, ParVal, ParFlag);
         end;
         end;
     11: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_chlorophyll:=count_chlorophyll+1;
         //if Checkbox2.Checked then
         //InsertParameters('P_CHLOROPHYLL', Absnum, {count_temperature,} stLev, ParVal, ParFlag);
         end;
         end;
     17: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_alkalinity:=count_alkalinity+1;
         //if Checkbox2.Checked then
         //InsertParameters('P_ALKALINITY', Absnum, {count_temperature,} stLev, ParVal, ParFlag);
         end;
         end;
   {  20: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_pCO2:=count_pCO2+1;
         writeln(fo_pCO2,absnum:8,count_temperature:5,StLev:7:1,ParVal:9:3,ParFlag:6);
         end;
         end;
     21: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_tCO2:=count_tCO2+1;
         writeln(fo_tCO2,absnum:8,count_temperature:5,StLev:7:1,ParVal:9:3,ParFlag:6);
         end;
         end;
     23: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         count_NANI:=count_NANI+1;
         writeln(fo_NANI,absnum:8,count_temperature:5,StLev:7:1,ParVal:9:3,ParFlag:6);
         end;
         end; }
      end;

{p2}end;
{p1}end;
     {m=0- depth to pressure, 1- pressure to depth}
     //LastLev_m:=StLev;
     //procedures.Depth_to_Pressure(LastLev_m,stLat,0,LastLev_dbar);

     //TEOS: meters to dbar
     LastLev_m:=-StLev;
     LastLev_dbar:=GibbsSeaWater.gsw_p_from_z(LastLev_m,stlat,0,0);
     LastLev_m:=StLev;

{PD}end;


//output into file
//STATION             NCEI Accession Number ???
writeln(f_station,inttostr(absnum),
#9,floattostr(StLat),
#9,floattostr(StLon),
#9,datetimetostr(StDateTime),
#9,inttostr(StDepthSource),
#9,floattostr(LastLev_m),                //LASTLEVEL_M
#9,floattostrF(LastLev_dbar,ffFixed,7,1),//LASTLEVEL_DBAR
#9,inttostr(WODCruiseNum),         //CRUISEID = WOD cruise number identification (Primary Header/Field 8: 'Cruise number'). Integer
#9,inttostr(TSProbeType),           //INSTRUMENT_ID
#9,OrStNum,                         //ST_NUM_ORIGIN = station number assigned during the cruise (Secondary Header/Field 7: 'Originator's station number'). String
#9,inttostr(WODCastNum),            //ST_ID_ORIGIN = WOD cast identification (Primary header/Field 5: 'WOD unique cast number'). Integer
#9,inttostr(OrCastNum),             //CAST_NUMBER = station number assigned during the cruise (Secondary Header/Field 5: 'Cast/Tow number'). integer?
#9,inttostr(ST_QF),                 //0 - not checked, 2 - suspicious becouse one of WOD algotithms on variables failed
#9,inttostr(1),                     //STVERSION
#9,inttostr(0),                    //MERGED
#9,datetimetostr(NOW),        //DATE_ADDED
#9,datetimetostr(NOW));      //DATE_UPDATED


{WFR}until eof(f_dat); {end of file}

     StInFile:=mik_st;
     //memo1.Lines.Add('mik_st='+inttostr(mik_st));

end;


procedure TfrmloadWOD18.ConvertToFloat(Str:string; var ParVal:real);
    var
     PF,TF,RB,k :integer;
     PF10: longint;
     ErrVal:real;
     SF :string[1];
    begin
         ErrVal:=-9;
       {...lat}
         SF:=copy(str,1,1); {Sig.Figures} {showmessage('SF: '+SF);}
         PF:=0; PF10:=1;
       if (SF<>'-') then begin
         RB:=2;     TF:=strtoint(copy(str,RB,1)); {Total Figures}
         RB:=RB+1;  PF:=strtoint(copy(str,RB,1)); {Precision Figures}
         for k:=1 to PF do PF10:=PF10*10;
         RB:=RB+1;  ParVal:=strtoint(copy(str,RB,TF))/PF10;
       end;
       if (SF='-') then ParVal:=ErrVal;
    end;



procedure TfrmloadWOD18.btnCreateWODClick(Sender: TObject);
Var
DB:TIBConnection;
TR:TSQLTransaction;
ST:TSQLScript;

(* Script for main tables *)
const ScriptText=
   (* STATION *)
   'CREATE TABLE STATION ('+LineEnding+
   '    ID                  BIGINT NOT NULL, '+LineEnding+
   '    LATITUDE            DECIMAL(8,5) NOT NULL, '+LineEnding+
   '    LONGITUDE           DECIMAL(9,5) NOT NULL, '+LineEnding+
   '    DATEANDTIME         TIMESTAMP NOT NULL, '+LineEnding+
   '    BOTTOMDEPTH         INTEGER, '+LineEnding+
   '    LASTLEVEL_M         INTEGER, '+LineEnding+
   '    LASTLEVEL_DBAR      INTEGER, '+LineEnding+
   '    CRUISE_ID           BIGINT NOT NULL, '+LineEnding+
   '    INSTRUMENT_ID       BIGINT NOT NULL, '+LineEnding+
   '    ST_NUMBER_ORIGIN    VARCHAR(50), '+LineEnding+
   '    ST_ID_ORIGIN        BIGINT, '+LineEnding+
   '    CAST_NUMBER         SMALLINT DEFAULT 1 NOT NULL, '+LineEnding+
   '    QCFLAG              SMALLINT NOT NULL, '+LineEnding+
   '    STVERSION           SMALLINT NOT NULL, '+LineEnding+
   '    MERGED              SMALLINT DEFAULT 0 NOT NULL, '+LineEnding+
   '    DATE_ADDED          TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_UPDATED        TIMESTAMP, '+LineEnding+
   '    CONSTRAINT STATION_PK PRIMARY KEY (ID) '+LineEnding+
   '); '+LineEnding+

   //   '    SOURCE_ID           BIGINT DEFAULT -9 NOT NULL, '+LineEnding+
//   '    COUNTRY_ID          BIGINT DEFAULT -9 NOT NULL, '+LineEnding+
//   '    PLATFORM_ID         BIGINT DEFAULT -9 NOT NULL, '+LineEnding+
   //   '    INSTRUMENT_ID       BIGINT DEFAULT -9 NOT NULL, '+LineEnding+

   (* ENTRY *)
   'CREATE TABLE ENTRY ('+LineEnding+
   '    ID               BIGINT NOT NULL, '+LineEnding+
   '    ENTRIES_TYPE_ID  BIGINT NOT NULL, '+LineEnding+
   '    TITLE            VARCHAR(100) NOT NULL, '+LineEnding+
   '    DATE_BEGIN       TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_END         TIMESTAMP NOT NULL, '+LineEnding+
   '    STATIONS_NUMBER  BIGINT, '+LineEnding+
   '    DATE_ADDED       TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_UPDATED     TIMESTAMP, '+LineEnding+
   '    CONSTRAINT ENTRY_PK PRIMARY KEY (ID) '+LineEnding+
   '); '+LineEnding+

   (* ENTRY_TYPE *)
   'CREATE TABLE ENTRY_TYPE ('+LineEnding+
   '    ID           BIGINT NOT NULL, '+LineEnding+
   '    NAME         VARCHAR(255) NOT NULL, '+LineEnding+
   '    DESCRIPTION  BLOB SUB_TYPE 1 SEGMENT SIZE 16384, '+LineEnding+
   '    CONSTRAINT ENTRY_TYPE_PK PRIMARY KEY (ID) '+LineEnding+
   '); '+LineEnding+

   (* STATION_ENTRY *)
   'CREATE TABLE STATION_ENTRY ('+LineEnding+
   '    STATION_ID  BIGINT NOT NULL, '+LineEnding+
   '    ENTRY_ID    BIGINT NOT NULL '+LineEnding+
   '); '+LineEnding+

   (* METEO *)
   'CREATE TABLE METEO ('+LineEnding+
   '    ID           BIGINT NOT NULL, '+LineEnding+
   '    TEMPDRY      DECIMAL(5,2), '+LineEnding+
   '    TEMPWET      DECIMAL(5,2), '+LineEnding+
   '    PRESSURE     DECIMAL(5,1), '+LineEnding+
   '    WINDDIR      SMALLINT, '    +LineEnding+
   '    WINDSPEED    DECIMAL(5,1), '+LineEnding+
   '    CLOUDCOMMON  SMALLINT, '    +LineEnding+
   '    CLOUDLOW     SMALLINT, '    +LineEnding+
   '    CLOUDTYPE    VARCHAR(20), ' +LineEnding+
   '    VISIBILITY   SMALLINT, '    +LineEnding+
   '    HUMABS       DECIMAL(4,1), '+LineEnding+
   '    HUMREL       SMALLINT, '    +LineEnding+
   '    WAVEHEIGHT   DECIMAL(5,1), '+LineEnding+
   '    WAVEDIR      SMALLINT, '    +LineEnding+
   '    WAVEPERIOD   SMALLINT, '    +LineEnding+
   '    SEASTATE     SMALLINT, '    +LineEnding+
   '    WEATHER      SMALLINT, '    +LineEnding+
   '    WATERCOLOR   SMALLINT, '    +LineEnding+
   '    WATERTRANSP  SMALLINT, '    +LineEnding+
   '    SURFTEMP     DECIMAL(5,2), '+LineEnding+
   '    SURFSALT     DECIMAL(5,2) ' +LineEnding+
   '); '+LineEnding+

   (* PARAMETERS *)
   'CREATE TABLE DATABASE_TABLES ('+LineEnding+
   '    ID            BIGINT NOT NULL, '+LineEnding+
   '    TABLENAME     VARCHAR(255) NOT NULL, '+LineEnding+
   '    VARIABLENAME  VARCHAR(255) NOT NULL, '+LineEnding+
   '    DESCRIPTION   VARCHAR(255), '+LineEnding+
   '    CONSTRAINT DATABASE_TABLES_PK PRIMARY KEY (ID) '+LineEnding+
   '); '+LineEnding+

   (* 1	P_TEMPERATURE_OSD *)
      'CREATE TABLE P_TEMPERATURE_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 2	P_SALINITY_OSD *)
      'CREATE TABLE P_SALINITY_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 3	P_OXYGEN_OSD *)
      'CREATE TABLE P_OXYGEN_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 4	P_PHOSPHATE_OSD *)
      'CREATE TABLE P_PHOSPHATE_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 5	P_SILICATE_OSD *)
      'CREATE TABLE P_SILICATE_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 6	P_NITRATE_OSD *)
   (* 6	Nitrate and Nitrate+Nitrite *)
      'CREATE TABLE P_NITRATE_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 7	P_PH_OSD *)
      'CREATE TABLE P_PH_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 8	P_TCHL_OSD *)
   (* 8	Total Chlorophyll [Chl] unless specified *)
      'CREATE TABLE P_TCHL_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 9	P_ALK_OSD *)
   (* 9	Alkalinity *)
      'CREATE TABLE P_ALK_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 10 P_PCO2_OSD *)
   (* 10 Partial pressure of carbon dioxide [pCO2] *)
      'CREATE TABLE P_PCO2_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 11 P_DIC_OSD *)
   (* 11 Dissolved Inorganic carbon *)
      'CREATE TABLE P_DIC_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 12 P_WPRES_OSD *)
   (* 12 Water pressure *)
      'CREATE TABLE P_WPRES_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+


   (* 13 P_H3_OSD *)
   (* 13   Tritium *)
      'CREATE TABLE P_H3_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 14 P_HE_OSD *)
   (* 14   Helium *)
      'CREATE TABLE P_HE_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+


   (* 15 P_HE3_OSD *)
   (* 15   Delta Helium-3 *)
      'CREATE TABLE P_HE3_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 16 P_C14_OSD *)
   (* 16   Delta Carbon-14 *)
      'CREATE TABLE P_C14_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 17 P_C13_OSD *)
   (* 17 Delta Carbon-13 *)
      'CREATE TABLE P_C13_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+


   (* 18 P_ARGON_OSD *)
      'CREATE TABLE P_ARGON_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 19 P_NEON_OSD *)
      'CREATE TABLE P_NEON_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 20 P_CFC11_OSD *)
   (* 20 Chlorofluorocarbon 11 *)
      'CREATE TABLE P_CFC11_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 21 P_CFC12_OSD *)
   (* 21 Chlorofluorocarbon 12 *)
      'CREATE TABLE P_CFC12_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 22 P_CFC113_OSD *)
   (* 22 Chlorofluorocarbon 113 *)
      'CREATE TABLE P_CFC113_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+

   (* 23 P_O18_OSD *)
   (* 23 Delta Oxygen-18 *)
      'CREATE TABLE P_O18_OSD ( '+LineEnding+
      '   ID             BIGINT NOT NULL, '+LineEnding+
      '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
      '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
      '   pQF1           SMALLINT, '+LineEnding+
      '   pQF2           SMALLINT, '+LineEnding+
      '   sQF            SMALLINT, '+LineEnding+
      '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
      '   UNITS_ID        BIGINT '+LineEnding+
      '); '+LineEnding+



   'ALTER TABLE STATION ADD CONSTRAINT UNQ1_STATION UNIQUE (LATITUDE,LONGITUDE,DATEANDTIME,CAST_NUMBER,STVERSION); '+LineEnding+
   'ALTER TABLE METEO ADD CONSTRAINT FK_METEO FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE ENTRY ADD CONSTRAINT FK_ENTRY FOREIGN KEY (ENTRIES_TYPE_ID) REFERENCES ENTRY_TYPE (ID); '+LineEnding+
   'ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_1 FOREIGN KEY (STATION_ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_2 FOREIGN KEY (ENTRY_ID) REFERENCES ENTRY (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+

   'ALTER TABLE P_TEMPERATURE_OSD ADD CONSTRAINT FK_P_TEMPERATURE_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_SALINITY_OSD ADD CONSTRAINT FK_P_SALINITY_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_OXYGEN_OSD ADD CONSTRAINT FK_P_OXYGEN_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_PHOSPHATE_OSD ADD CONSTRAINT FK_P_PHOSPHATE_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_SILICATE_OSD ADD CONSTRAINT FK_P_SILICATE_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_NITRATE_OSD ADD CONSTRAINT FK_P_NITRATE_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_PH_OSD ADD CONSTRAINT FK_P_PH_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_TCHL_OSD ADD CONSTRAINT FK_P_TCHL_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_ALK_OSD ADD CONSTRAINT FK_P_ALK_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_PCO2_OSD ADD CONSTRAINT FK_P_PCO2_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_DIC_OSD ADD CONSTRAINT FK_P_DIC_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_WPRES_OSD ADD CONSTRAINT FK_P_WPRES_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_H3_OSD ADD CONSTRAINT FK_P_H3_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_HE_OSD ADD CONSTRAINT FK_P_HE_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_HE3_OSD ADD CONSTRAINT FK_P_HE3_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_C14_OSD ADD CONSTRAINT FK_P_C14_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_C13_OSD ADD CONSTRAINT FK_P_C13_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_ARGON_OSD ADD CONSTRAINT FK_P_ARGON_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_NEON_OSD ADD CONSTRAINT FK_P_NEON_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_CFC11_OSD ADD CONSTRAINT FK_P_CFC11_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_CFC12_OSD ADD CONSTRAINT FK_P_CFC12_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_CFC113_OSD ADD CONSTRAINT FK_P_CFC113_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE P_O18_OSD ADD CONSTRAINT FK_P_O18_OSD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+

   'COMMIT WORK '+LineEnding+
   'SET TERM ; '+LineEnding;

begin

// showmessage(ScriptText);
 try
   DB:=TIBConnection.Create(nil);
   TR:=TSQLTransaction.Create(nil);
   ST:=TSQLScript.Create(nil);

    DB.Transaction:=TR;
    TR.Database:=DB;
    ST.Transaction:=TR;
    ST.Database:=DB;
    ST.CommentsInSQL:=false;

    //DB.DatabaseName:=(dbname);
    DB.DatabaseName:='c:\Users\ako071\AK\OceanShell-GIT\OceanShell\databases\WOD18.fdb';
    DB.UserName:='SYSDBA';
    DB.Password:='masterkey';
     With DB.Params do begin
      Clear;
       Add('SET SQL DIALECT 3');
       Add('SET NAMES UTF8');
       Add('PAGE_SIZE 16384');
       Add('DEFAULT CHARACTER SET UTF8 COLLATION UTF8');
     end;
    DB.CreateDB;
    DB.Connected:=False;
    DB.LoginPrompt:=False;
    DB.Open;

    ST.Script.Text:=ScriptText;
    ST.UseCommit:=true;
    ST.UseSetTerm:=true; // for Firebird ONLY
    ST.CommentsInSQL:=false;
     try
      ST.Execute;
      TR.Commit;
     except
      on E: EDataBaseError do begin
        ShowMessage('Error running script: '+E.Message);
        TR.Rollback;
      end;
     end;
 finally
  ST.Free;
  TR.Free;
  DB.Free;
 end;
  showmessage('WOD database has been created ');
end;





end.

