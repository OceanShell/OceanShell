unit procedures;

{$mode objfpc}{$H+}

interface

uses
{$ifdef WINDOWS}
  Registry, ShlObj, comobj, Win32Int, InterfaceBase,
{$ENDIF}

  SysUtils, Variants, Dialogs, DateUtils, Forms, osmain, Math;

function CheckKML:boolean;
function ClearDir(Dir:string ): boolean;

{$ifdef WINDOWS}
(* ProgressBar on taskbar in WINDOWS *)
procedure ProgressTaskbar(k, max_k : integer);
{$ENDIF}
procedure Distance(ln0,ln1,lt0,lt1:real; var Dist:real);
procedure PositionByDistance(Lat0, Lon0, Dist: real;
 var LatMin, LatMax, LonMin, LonMax:real);

(* Date encoding function *)
function DateEncode(Year,Month,Day,Hour,Minutes:word;
 Var DaysInAMonthFlag,DateChangedFlag:Boolean):TDateTime;


Function  Cond2Sal78 (aConductivity, Temp, Press : Double; Var aSalinity: Double) : Boolean;


implementation

{$ifdef WINDOWS}
procedure ProgressTaskbar(k, max_k : integer);
Var
 FTaskBarList: ITaskbarList3;
 AppHandle: THandle;
begin
 AppHandle := TWin32WidgetSet(WidgetSet).AppHandle;
 FTaskBarList := CreateComObject(CLSID_TaskbarList) as ITaskbarList3;
 FTaskBarList.SetProgressState(AppHandle, TBPF_Normal);
 FTaskBarList.SetProgressValue(AppHandle, k, max_k);
end;
{$ENDIF}


function CheckKML:boolean;
var
 FileClass: string;
 {$IFDEF WINDOWS}
  Reg: TRegistry;
 {$ENDIF}
begin
{$IFDEF WINDOWS}
  Reg := TRegistry.Create(KEY_EXECUTE);
  Reg.RootKey := HKEY_CLASSES_ROOT;
  FileClass := '';
  if Reg.OpenKeyReadOnly('.kml') then
  begin
    FileClass := Reg.ReadString('');
    Reg.CloseKey;
  end;
  if FileClass <> '' then begin
    if Reg.OpenKeyReadOnly(FileClass + '\Shell\Open\Command') then
    begin
      if trim(Reg.ReadString(''))<>'' then Result := true else Result := false;
      Reg.CloseKey;
    end;
  end;
  Reg.Free;
  {$ENDIF}
end;


(* Erasing content of the given folder *)
function ClearDir( Dir: string ): boolean;
var  isFound: boolean;
sRec: TSearchRec;
begin
 Result := false;
 ChDir( Dir );
  if IOResult <> 0 then Exit;
  if Dir[Length(Dir)] <> PathDelim then Dir := Dir + PathDelim;

  isFound := FindFirst(Dir + '*.*',faAnyFile,sRec ) = 0;
  while isFound do  begin
   if ( sRec.Name <> '.' ) and ( sRec.Name <> '..' ) then
    if ( sRec.Attr and faDirectory ) = faDirectory then  begin
     if not ClearDir( Dir + sRec.Name ) then  Exit;
     if ( sRec.Name <> '.' ) and ( sRec.Name <> '..' ) then
      if ( Dir + sRec.Name ) <> Dir then  begin  ChDir( '..' );
        RmDir( Dir + sRec.Name );
      end;
    end else if not SysUtils.DeleteFile(Dir + sRec.Name) then Exit;
   isFound := FindNext(sRec ) = 0;
  end;
 SysUtils.FindClose(sRec);
 Result := IOResult = 0;
end;


{ Distance [km] calculation between two points input}
{ Initial coordinates in degres decimal}
Procedure Distance(ln0,ln1,lt0,lt1:real; var Dist:real);
var
lnd,ltd,lnkm,ltkm,m,r:real;
begin
{ Coordinates in decimal reprisentation }
 lnd:=abs(ln1-ln0);
  if lnd>180 then lnd:=abs(360-lnd);
 ltd:=abs(lt1-lt0);
 r:=2*pi*6378.137/360;  {equatorial radius Hayford 1909 [km] 6378.137}
 m:=1.8532; {mile}
 lnkm:=r*cos((lt0+lt1)/2*(pi/180))*lnd;
 ltkm:=r*ltd;
Dist:=sqrt(lnkm*lnkm+ltkm*ltkm);
end;


procedure PositionByDistance(Lat0, Lon0, Dist: real;
 var LatMin, LatMax, LonMin, LonMax:real);
Var
  theta, a, b, c, d: double;
  lat, lon, dlat, dlon, lat_d, lon_d :double;
begin
  // in degrees
  lat_d:=Lat0;
  lon_d:=Lon0;

  // convert to radians
  lat0 := lat0*Pi/180;
  lon0 := lon0*Pi/180;
  dist := dist/6371;
  theta:= 270*Pi/180;

  lat := arcsin(sin(lat0)*cos(dist)+cos(lat0)*sin(dist)*cos(0));
  d:= arctan2(sin(theta)*sin(dist)*cos(lat0), cos(dist)-sin(lat0)*sin(lat));

  a:=lon0-d+pi;
  b:=2*pi;
  c:= a - b * Int(a / b);

  lon := c - pi;

  dlat:=(lat-lat0)*180/pi;
  dlon:=(lon-lon0)*180/pi;

  LatMin:=lat_d-dlat;
  LatMax:=lat_d+dlat;
  LonMin:=lon_d-dlon;
  LonMax:=lon_d+dlon;

//  showmessage(floattostr(latmin)+'   '+floattostr(latmax));
end;

{updated 9.10.2004}
function DateEncode(Year,Month,Day,Hour,Minutes:word;
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


{...convert date/time to TdateTime and assign quality flags}
Procedure ODBPr_ConvertDateTime(StYear,StMonth,StDay,StHour,StMin:word;
                                var StDate,StTime:TDateTime;
                                var MonthErr,TimeErr:Boolean);
label 10;
var
DM:integer;
d:word;
begin

    DM:=DaysInAMonth(StYear,StMonth);
    MonthErr:=false;
    TimeErr:=false;
    d:=StDay;

    {not considered outside}
    if (StMin>60) or (StHour>24)then begin
     StMin:=0;
     StHour:=0;
    end;

   {if StDay exceed DM -> next month/year}
{m}if (StDay>DM) then begin
    MonthErr:=true; {flag 32}
    StDay:=1;
    if StMonth<12 then Stmonth:=StMonth+1;
    if StMonth=12 then begin
     StMonth:=1;
     StYear:=StYear+1;
    end;
    if (StHour=23) and (StMin=60) then begin
                       StHour:=0;
                       StMin:=0;
                       TimeErr:=true;
                       end;
    if StMin=60  then begin StMin:=0; TimeErr:=true; end;
    if StHour=24 then begin StHour:=0; TimeErr:=true; end;
   goto 10;
{m}end;

   {if StMin >=60 -> next hour/day}
{h1}if (StDay<DM) then begin
    if (StMin>=60) then begin
     StMin:=0;
     StHour:=StHour+1;
    end;
{!} if (StHour>=24) then begin
     StHour:=0;
     if (StDay<DM) then StDay:=StDay+1;
{!} end;
    if (StDay<>d) then TimeErr:=true; {flag 64}
{h1}end;

   {if StMin >=60 and StDay=DM -> next day/month/year}
{h2}if (StDay=DM) then begin

    if (StMin=60) then begin
     StMin:=0;
     StHour:=StHour+1;
    end;
{!} if (StHour>=24) then begin
     StHour:=0;
     StDay:=1;
     if StMonth<12 then Stmonth:=StMonth+1;
     if StMonth=12 then begin
      StMonth:=1;
      StYear:=StYear+1;
     end;
{!} end;
    if (StDay<>d) then TimeErr:=true; {flag 64}
{h2}end;

10: StDate:=EncodeDate(StYear,StMonth,StDay);
    StTime:=EncodeTime(StHour,StMin,0,0);
end;



Function Cond2Sal78 (aConductivity, Temp, Press : Double; Var aSalinity: Double) : Boolean;
// Function Cond2Sal converts a conductivity value of seawater to a value
// of the pratical-salinity-scale 1978 (PSS-78) for given values of
// conductivity, temperature and pressure. Result is returned as
// parameter in aSalinity. A returned boolean result TRUE of the
// function indicates that the result is reliable.
// UNITS:
//   PRESSURE      Press          DECIBARS
//   TEMPERATURE   Temp           DEG CELSIUS IPTS-68
//   CONDUCTIVITY  aConductivity  S/m
//   SALINITY      aSalinity      PSS-78
// ----------------------------------------------------------
// CHECKVALUES:
//   2.) aSalinity=40.00000 for CND=1.888091, T=40 DEG C, P=10000 DECIBARS
// ----------------------------------------------------------
// SAL78 RATIO: RETURNS ZERO FOR CONDUCTIVITY RATIO: < 0.0005
// ----------------------------------------------------------
// This source code is based on the original fortran code in:
//   UNESCO technical papers in marine science 44 (1983) -
//   'Algorithms for computation of fundamental properties of seawater'
// ----------------------------------------------------------
// Written in object pascal by:
//   Dr. Jan Schulz, 26. May 2008, www.code10.info

    Function SAL (XR, XT: Double): Double;
    // PRACTICAL SALINITY SCALE 1978 DEFINITION WITH TEMPERATURE
    // CORRECTION;XT :=T-15.0; XR:=SQRT(RT);
    Begin

      SAL := ((((2.7081*XR-7.0261)*XR+14.0941)*XR+25.3851)*XR
              - 0.1692)*XR+0.0080
              + (XT/(1.0+0.0162*XT))*(((((-0.0144*XR
              + 0.0636)*XR-0.0375)*XR-0.0066)*XR-0.0056)*XR+0.0005);
    end;

    Function RT35 (XT : Double) : Double;
    // FUNCTION RT35: C(35,T,0)/C(35,15,0) VARIATION WITH TEMPERATURE
    Begin
      RT35 := (((1.0031E-9 * XT - 6.9698E-7) * XT + 1.104259E-4) * XT
               + 2.00564E-2) * XT + 0.6766097;
    end;

    Function C (XP : Double) : Double;
    // C(XP) POLYNOMIAL CORRESPONDS TO A1-A3 CONSTANTS: LEWIS 1980
    Begin
      C := ((3.989E-15 * XP - 6.370E-10) * XP + 2.070E-5) * XP;
    end;

    Function B (XT :Double) : Double;
    Begin
      B := (4.464E-4 * XT + 3.426E-2) * XT + 1.0;
    end;

    Function A (XT : Double): Double;
    //A(XT) POLYNOMIAL CORRESPONDS TO B3 AND B4 CONSTANTS: LEWIS 1980
    Begin
      A := -3.107E-3 * XT + 0.4215;
    end;
Var DT : Double;
    RT : Double;
Begin
// we expect the best
  Cond2Sal78 := True;
  aSalinity  := 0;

  // equation is not defined for conductivity values below 5e-4
  If aConductivity <= 0.2 THen
  Begin
    Cond2Sal78 := False;
    Exit;
  end;

  // start conversion
  DT        := Temp - 15;
  aSalinity := aConductivity/4.2914;
  RT        := aSalinity / (RT35 (Temp) * (1.0 + C (Press) / (B (Temp) + A (Temp) * aSalinity)));
  RT        := Sqrt (Abs (RT));
  aSalinity := SAL (RT, DT);

  // control, whether result is in the validity range of PSS-78
  If (aSalinity < 2) Or (aSalinity > 42) THen
  Begin
    Cond2Sal78 := False;
  end;
end;


end.
