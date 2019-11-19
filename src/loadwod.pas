unit loadwod;

{$mode objfpc}{$H+}
                                                                            
interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IniFiles;

type

  { TfrmLoadASC_WOD }

  TfrmLoadASC_WOD = class(TForm)
    GroupBox1: TGroupBox;
    OpenDialog1: TOpenDialog;
    btnStart: TButton;
    GroupBox2: TGroupBox;
    Memo1: TMemo;
    Edit1: TEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    btnOpenData: TButton;
    cbSource: TComboBox;
    Memo2: TMemo;

    procedure btnStartClick(Sender: TObject);
    procedure ConvertOSD;
    procedure ConvertToFloat(Str:string; var ParVal:real);
    procedure btnOpenDataClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLoadASC_WOD: TfrmLoadASC_WOD;
  StInFile:integer;
  PathSource, PathUnloadPar:string;
  FileForRead:string;
  f_dat:text;

implementation

uses osmain, DM, procedures, osstandartqueries;

{$R *.lfm}

procedure TfrmLoadASC_WOD.btnStartClick(Sender: TObject);
var
Ini:TIniFile;
kf,count_st:integer;
sym:char;
DB2Name, SupportDB:string;
begin
 Ini := TIniFile.Create(IniFileName);
  try
   SupportDB:=Ini.ReadString('SupportDatabase', 'Path','localhost:'+GlobalPath+'support\supporttables.fdb');
  finally
   Ini.Free;
  end;

//AK   if FileExists(SupportDB) then begin
//AK       ODBDM.IBDatabase2.Close;
//AK       ODBDM.IBDatabase2.DatabaseName:=SupportDB;
//AK       ODBDM.IBDatabase2.Open;
//AK   end else begin
//AK    Showmessage('Support database is not found');
//AK     exit;
//AK   end;

//  if checkbox2.Checked then QueryPreparation;
//AK  ODBDM.IBTransaction1.starttransaction;

Memo1.Clear;
//{f}for kf:=0 to ListBox1.Items.Count-1 do begin

    FileForRead:=Edit1.Text; //+ListBox1.Items.Strings[kf];
    try
    AssignFile(f_dat,FileForRead); reset(f_dat);
    count_st:=0;
    while not EOF(f_dat) do begin
     readln(f_dat,sym);
     if sym='A' then count_st:=count_st+1;
    end;
    closefile(f_dat);
    StInFile:=count_st;

    Application.ProcessMessages;

    reset(f_dat);
    ConvertOSD;
    finally
    closefile(f_dat);
    end;
   if checkbox2.Checked then begin
//AK      ODBDM.IBTransaction1.Commit;
//AK      frmmain.UpdateIBContent;
   end;
   Memo1.Lines.Add('=======');
   Memo1.Lines.Add('Done!');
end;



{convert WOD2005 Ocean Station data}
procedure TfrmLoadASC_WOD.ConvertOSD;
var
k,kb,kL,k_var,mik_line,mik_st,s,k_lev,k_par:integer;
BP,SL,line,NC,BNF,RC,TF,BSH,SHNC,BBH:integer;
OCLStNum,StCruise,mEx,ParFlag:integer;
levnum,proftype,varnum,qflag,mdatnum,m,varcode,varspcode,OCLShipCode:integer;
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
StCountryCode_Platform,CountryName_Platform:string;
par_arr :array [1..30] of integer;
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
begin

    line:=0;
    mik_st:=0;
{1}repeat

     {default}
     st:='';
     StFlag:=0;
     VesselCruiseID:='UNKNOWN';
     StSource:=cbSource.Text;
     SourceDataOrigin:='UNKNOWN';
     CountryName:='UNKNOWN';
     ShipName:='UNKNOWN';

    for kb:=1 to 80 do begin read(f_dat,buf); st:=concat(st,buf); end;
    readln(f_dat);
    line:=line+1;
    wst:=st;   {whole station}
    BP:=strtoint(copy(st,2,1));
    SL :=strtoint(copy(st,3,BP));  //bytes in profile
    mik_line:=trunc(SL/80);
    if (SL MOD 80 = 0) then mik_line:=mik_line-1;

   for kL:=1 to mik_line do begin
    readln(f_dat,st); line:=line+1;
    wst:=wst+st;
   end;
    wst:=trim(wst);
    mik_st:=mik_st+1;
 //   Main.ProgressBar1.Position:=mik_st;
   {...wst analysis  SL -station length in bytes}
   {                      BP -bytes in SL}
   {                      NC -next column in string for reading}
   {                      BNF-bytes in next field}
   NC:=BP+3;
   BNF:=strtoint(copy(wst,NC,1)); {bytes in OCLStNum}
   NC:=NC+1;
   OCLStNum:=strtoint(copy(wst,NC,BNF));   {OCL Station number}
   NC:=NC+BNF;
   StCountryCode:=copy(wst,NC,2);            {country code}

 //  showmessage('countrycode: '+stcountrycode);

   NC:=NC+2;
   BNF:=strtoint(copy(wst,NC,1)); {bytes in StCruise}
   NC:=NC+1;
   StCruise:=strtoint(copy(wst,NC,BNF));  {cruise number}
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
   StDateTime:=DateEncode(StYear,StMonth,StDay,StHour,StMin,MonthErr,TimeErr);


  {StDateDT:=DateEncode(StYear,StMonth,StDay,StHour,StMin,MonthErr,TimeErr);
   StTimeDT:=DateEncode(StYear,StMonth,StDay,StHour,StMin,MonthErr,TimeErr);
   DecodeDate(StDateDT,StYear,StMonth,StDay);
   DecodeTime(StTimeDT,StHour,StMin,StSec,StMSec);}
  if MonthErr=true    then  StFlag:=StFlag+32; {if days in month out limit}
  if TimeErr=true  then  StFlag:=StFlag+64; {if date changed hour 24 or minutes 60}



   {variable codes, quality flags, metadata}

{v}if (varnum>0) and (levnum>0) then begin
{c}for k_var:=1 to VarNum do begin
     BNF:=strtoint(copy(wst,NC,1));
{memo1.Lines.Add('>>>>>>>'+inttostr(k_var)+' -> '+copy(wst,NC,BNF)+'  NC:'+inttostr(nc));}
     NC:=NC+1;   VarCode:=strtoint(copy(wst,NC,BNF)); {variable code}
     par_arr[k_var]:=VarCode;
     NC:=NC+BNF; QFlag  :=strtoint(copy(wst,NC,1));   {quality control flag}
     NC:=NC+1;   BNF    :=strtoint(copy(wst,NC,1));
     NC:=NC+1;   MDatNum:=strtoint(copy(wst,NC,BNF)); {number of variable-specific metadata}
     NC:=NC+BNF;

  {  if CheckBox1.Checked then
    memo1.Lines.Add('...kvar: '+inttostr(k_var)
     +#9+'...VarCode: '+inttostr(VarCode)
     +#9+'...QFlag  : '+inttostr(QFlag)
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

    if CheckBox1.Checked then
  {  memo1.Lines.Add('<<<...m: '+inttostr(m)
     +#9+'...VarSpCode : '+inttostr(VarSpCode)
     +#9+'...ParMetData: '+floattostr(ParMetaData)); }

   end;
{m}end;
{c}end;
{v}end;

    {...character data and principal investigator}
    BNF:=strtoint(copy(wst,NC,1)); {showmessage(inttostr(NC)+'  BNF: '+inttostr(BNF));}
    NC:=NC+1;
{cd}if BNF>0 then begin
     BSH:=strtoint(copy(wst,NC,BNF)); {total bytes for character data}
     {showmessage(inttostr(NC)+'  BSH [CharDataSection]: '+inttostr(BSH));}
     NC:=NC+BNF+BSH; {skip all bytes in character data section}
{cd}end;


    {...secondary header}
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
               // showmessage('OCLshipcode: '+inttostr(OCLShipCode));

//AK                ODBDM.IBTransaction2.StartTransaction;
//AK                try
//AK                  with ODBDM.ib2q2 do begin
//AK                  Close;
//AK                    SQL.Clear;
//AK                    SQL.Add(' select NODCShipCode, ShipName from ShipCode_List ');
//AK                    SQL.Add(' where OCLShipCode=:OCLShipCode ');
//AK                    ParamByName('OCLShipCode').AsInteger:=OCLShipCode;
//AK                   Open;
//AK                    NODCShipCode:=ODBDM.ib2q2.FieldByName('NODCShipCode').AsString;
//AK                    ShipName:=ODBDM.ib2q2.FieldByName('ShipName').AsString;
//AK                   Close;
//AK                  end;
//AK               ODBDM.IBTransaction2.Commit;
//AK                except
//AK                 ODBDM.IBTransaction2.Rollback;
//AK                end;
               //  showmessage(shipname);

                 StCountryCode_Platform:=copy(NODCShipCode,1,2);
                 CountryName_Platform:='';
 //AK                 ODBDM.IBTransaction2.StartTransaction;
 //AK                try
 //AK                 with ODBDM.ib2q2 do begin
 //AK                  Close;
 //AK                   SQL.Clear;
 //AK                    SQL.Add(' select CountryName from CountryCode_List ');
 //AK                    SQL.Add(' where NODCCountryCode=:CountryCode ');
 //AK                   ParamByName('CountryCode').AsString:=StCountryCode_Platform;
 //AK                  Open;
 //AK                  if ODBDM.ib2q2.IsEmpty=false then
 //AK                     CountryName_Platform:=ODBDM.ib2q2.FieldByName('CountryName').AsString;
 //AK                  Close;
 //AK                 end;

 //AK                  if CountryName_Platform='' then begin
 //AK                  with ODBDM.ib2q2 do begin
 //AK                   Close;
 //AK                    SQL.Clear;
 //AK                    SQL.Add(' select CountryName from CountryCode_List ');
 //AK                    SQL.Add(' where ISOCountryCode=:CountryCode ');
 //AK                    ParamByName('CountryCode').AsString:=StCountryCode_Platform;
 //AK                   Open;
 //AK                   if ODBDM.ib2q2.IsEmpty=false then
 //AK                     CountryName_Platform:=ODBDM.ib2q2.FieldByName('CountryName').AsString;
 //AK                    Close;
 //AK                   end;
 //AK                 end;

                //  showmessage(CountryName_Platform);

 //AK                   ODBDM.IBTransaction2.Commit;
 //AK                except
 //AK                   ODBDM.IBTransaction2.Rollback;
 //AK                 end;
                //  showmessage(countryname+'   '+shipname);

                  if StCountryCode_Platform<>'99' then begin
                     StCountryCode:=StCountryCode_Platform;
                     CountryName:=CountryName_Platform;
                  end;
              end;
           end;
      4:  StInstituteCode:=round(SHCodeValue); //Код института
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


   {get Absnum}
//AK   with ODBDM.ib1q1 do begin
//AK      Close;
//AK        SQL.Clear;
//AK        SQL.ADD(' Select gen_id(StAbsNum,0) from RDB$DataBase ');
//AK    Open;
//AK      Absnum:=ODBDM.ib1q1.Fields[0].AsInteger+1;
//AK    Close;
//AK   end;

 if checkbox1.Checked then begin
   memo1.Lines.Add(inttostr(OCLStNum)
    +#9+inttostr(absnum)
    +#9+inttostr(StFlag)
    +#9+floattostr(StLat)
    +#9+floattostr(StLon)
    +#9+datetostr(StDateTime)
    +#9+timetostr(StDateTime)
    +#9+StSource
    +#9+inttostr(StVersion)
    +#9+CountryName
    +#9+ShipName
    +#9+inttostr(StDepthSource)
    +#9+StCountryCode
    +#9+inttostr(OCLShipCode)+' -> '+NODCShipCode
    +#9+OrStNum
    +#9+inttostr(StProjectCode)
    +#9+inttostr(StInstituteCode)
    +#9+inttostr(TSProbeType)
    +#9+inttostr(OCLStNum)
    +#9+VesselCruiseID);

   memo2.Lines.Add(
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
    +#9+vartostr(SurfSalt));
 end;

    if CheckBox2.Checked then begin  //Пишем метаданные в базу

    InsertMetadata(Absnum, StFlag, StLat, StLon, StDateTime, StDateTime,
                   StSource, 0, CountryName, ShipName, StDepthSource,
                   StCountryCode, NODCShipCode, OrStNum, StProjectCode, StInstituteCode,
                   TSProbeType, inttostr(OCLStNum), SourceDataOrigin, VesselCruiseID);

    InsertMeteo(Absnum, StAirTemp, StTWet, StAirPressure, WindDir, WindSpeed,
          CloudCover, null, CloudType, Visibility, AbsHum, null,
          WHeight, Wavedir, Waveperiod, Seastate, StWeather, Watercolor,
          WaterTransp, SurfTemp, SurfSalt);
    end;


     {...Profile Data}
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
                  ParErFlag1:=strtoint(copy(wst,NC,1));     {Par Error Flag}
      NC:=NC+1;   ParErFlag2:=strtoint(copy(wst,NC,1));     {Par Error Flag Originator's}
{p3}end;

      if(SF='-') then ParVal:=-9;

       ParFlag:=0;
      case par_arr[k_par] of
      1: begin
         if ParErFlag2>0 then ParFlag:=2;

         if ParVal<>-9 then begin
         mEx:=1;
         count_temperature:=count_temperature+1;
         if Checkbox2.Checked then
         InsertParameters('P_TEMPERATURE', Absnum, {count_temperature,} stLev, ParVal, ParFlag);
         end;
         end;
      2: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_salinity:=count_salinity+1;
          if Checkbox2.Checked then
         InsertParameters('P_SALINITY', Absnum, {count_salinity,} stLev, ParVal, ParFlag);
         end;
         end;
      3: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_oxygen:=count_oxygen+1;
      //   writeln(fo_oxyg,absnum:8,count_temperature:5,StLev:7:1,ParVal:9:3,ParFlag:6);
       if Checkbox2.Checked then
         InsertParameters('P_OXYGEN', Absnum, {count_oxygen,} stLev, ParVal, ParFlag);
         end;
         end;
      4: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_phosphate:=count_phosphate;
          if Checkbox2.Checked then
         InsertParameters('P_PHOSPHATE', Absnum, {count_phosphate,} stLev, ParVal, ParFlag);
         end;
         end;
      6: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_silicate:=count_silicate+1;
          if Checkbox2.Checked then
         InsertParameters('P_SILICATE', Absnum, {count_silicate,} stLev, ParVal, ParFlag);
         end;
         end;
      8: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_nitrate:=count_nitrate+1;
          if Checkbox2.Checked then
         InsertParameters('P_NITRATE', Absnum, {count_nitrate,} stLev, ParVal, ParFlag);
         end;
         end;
      9: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_ph:=count_ph+1;
          if Checkbox2.Checked then
         InsertParameters('P_PH', Absnum, {count_ph,} stLev, ParVal, ParFlag);
         end;
         end;
     11: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_chlorophyll:=count_chlorophyll+1;
          if Checkbox2.Checked then
         InsertParameters('P_CHLOROPHYLL', Absnum, {count_temperature,} stLev, ParVal, ParFlag);
         end;
         end;
     17: begin
         if ParErFlag2>0 then ParFlag:=2;
         if ParVal<>-9 then begin
         mEx:=1;
         count_alkalinity:=count_alkalinity+1;
          if Checkbox2.Checked then
         InsertParameters('P_ALKALINITY', Absnum, {count_temperature,} stLev, ParVal, ParFlag);
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
{PD}end;

{1}until eof(f_dat); {}
end;



procedure TfrmLoadASC_WOD.ConvertToFloat(Str:string; var ParVal:real);
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


procedure TfrmLoadASC_WOD.btnOpenDataClick(Sender: TObject);
begin
 if OpenDialog1.Execute then Edit1.Text:=OpenDialog1.FileName;
 Edit1.OnChange(self);
end;

procedure TfrmLoadASC_WOD.Edit1Change(Sender: TObject);
begin
 if FileExists(Edit1.Text) then btnStart.Enabled:=true;
end;

procedure TfrmLoadASC_WOD.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
//AK   ODBDM.IBDatabase2.Close;
end;


end.
