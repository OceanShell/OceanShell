unit procedures;

{$mode objfpc}{$H+}

interface

uses
{$ifdef WINDOWS}
  Windows, Registry, ShlObj, comobj, Win32Int, InterfaceBase,
{$ENDIF}
  SysUtils, Variants, Dialogs, DateUtils, Forms, osmain, declarations_netcdf;


function CheckKML:boolean;
function ClearDir(Dir:string ): boolean;
function DateTimeToFloat(StDate, StTime:TDateTime):Real;
function US80(t,s,p:real):real;

(* Date encoding function *)
function DateEncode(Year,Month,Day,Hour,Minutes:word;
 Var DaysInAMonthFlag,DateChangedFlag:Boolean):TDateTime;

(* ProgressBar on taskbar in WINDOWS *)
procedure ProgressTaskbar(k, max_k : integer);



{vertical interpolation}
procedure ODBPr_VertInt(IntLev,LU1,LU2,LD1,LD2,VU1,VU2,VD1,VD2:real;
                                        var IntVal:real; var Enable:boolean);
function  ODBPr_Line(x0,x1,x2,px1,px2:real) :real;
procedure ODBPr_Lag(x,x1,x2,x3,px1,px2,px3:real; var value:real);
procedure ODBPr_RR(level:real; l_arr,p_arr:array of real;    var value:real);


//UNESCO 1983
procedure Potential_Temperature(press,t1,s1:real;var tpot:real);
Procedure IEOS80(press,t,s:real;var svan,dens:real);
Procedure Distance(ln0,ln1,lt0,lt1:real; var Dist:real);
procedure Depth_to_Pressure(z,lt_real:real; m:integer; var press:real);
Function  Cond2Sal78 (aConductivity, Temp, Press : Double; Var aSalinity: Double) : Boolean;

{ Aligning MessageDlg to the center of the active window}
function MessageDlgCtr(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;


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


(* Кодируем текстовую строку *)
Function Decode(S:AnsiString): String;
Var
t, Code: Integer;
Begin
Code:=8902343; //Код можно менять для изменения шифрования
 For t:=1 to Length(S) Do S[t]:=AnsiChar(Ord(Char(S[t])) xor Code);
  Result:=S;
End;




{ Функция MessageDlg располагает диалог над центром активного окна }
function MessageDlgCtr(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
begin
  with CreateMessageDialog(Msg, DlgType, Buttons) do
  try
    HelpContext := HelpCtx;
    Left := Screen.ActiveForm.Left + (Screen.ActiveForm.Width div 2) -
      (Width div 2);

    Top := Screen.ActiveForm.Top + (Screen.ActiveForm.Height div 2) -
      (Height div 2);

    Result := ShowModal;
  finally
    Free;
  end;
end;


(* Erasing content of the given folder *)
function ClearDir( Dir: string ): boolean;
var  isFound: boolean;
sRec: TSearchRec;
begin
 Result := false;
 ChDir( Dir );
  if IOResult <> 0 then Exit;
  if Dir[Length(Dir)] <> '\' then Dir := Dir + '\';

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



(* Преобразование даты и времени в число *)
function DateTimeToFloat(StDate, StTime:TDateTime):Real;
Var
yy, mn, dd, hh, mm, ss, mss:word;
date1, time1:real;
begin
 DecodeDate(StDate, yy, mn, dd);
 DecodeTime(StTime, hh, mm, ss, mss);
  Result:=yy+(mn-1)/12+(dd-1)/(12*DaysInAMonth(yy,mn))+(hh+mn/60+ss/3600)/(12*DaysInAMonth(yy,mn)*24);
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


{m=0- depth to pressure, 1- pressure to depth}
procedure Depth_to_Pressure(z,lt_real:real; m:integer; var press:real);
var
k:integer;
gr0,pi,zi,x,eps :double;
 {...}
 function depth(p0:real;lat0:real):Real;
  begin
   depth:=((((-1.82E-15*p0+2.279E-10)*p0-2.2512E-5)*p0+9.72659)*p0)/lat0;
  end;
 function drdep(p0:real;lat0:real):real;
  begin
   drdep:=(((-7.28E-15*p0+6.837E-10)*p0-4.5024E-5)*p0+9.72659)/lat0;
  end;
 function gr(xz:real; gr0:real):real;
  begin
   gr:=gr0+1.092E-6*xz;
  end;
   {...}
  begin
   x:=sin(lt_real/57.29578);
   x:=x*x;
   gr0:=9.780318*(1+(5.2788E-3+2.36E-5*x)*x);
  case m of
  0:  begin
       pi:=z;
       zi:=depth(z,gr(z,gr0));
       for k:=1 to 10 do begin
        eps:=abs(zi-z);
        if(eps>0.0001) then begin
         pi:=pi+(z-zi)/drdep(pi,gr(pi,gr0));
         zi:=depth(pi,gr(pi,gr0));
        end;
       end;
            press:=pi;
            end;
  1:  press:=depth(z,gr(z,gr0));
  end; {case}
 end; {Depth_to_Pressure}

{Функция расчета плотности по УС-80 в зависимости от
температуры солености и давления}
function US80(t,s,p:real):real;
var
  Bw,Aw,B1,A1,Al,Bl,Kp,Kts0,Kptsp,A,B,C,rop,rots0:real;
begin
  Bw:=8.50935e-5-6.12293e-6*T+5.2787e-8*T*T;
  Aw:=3.239908+1.43713e-3*T+1.16092e-4*T*T-5.77905e-7*T*T*T;
  B1:=Bw-(9.9348e-7-2.0816e-8*T-9.1697e-10*T*T)*S;
  A1:=Aw+(2.2838e-3-1.0981e-5*T-1.6078e-6*T*T)*S+1.91075e-4*sqrt(S*S*S);
  Bl:=7.944e-2+1.6483e-2*T-5.3009e-4*T*T;
  Al:=54.6746-0.603459*T+1.09987e-2*T*T-6.61670e-5*T*T*T;
  Kp:=19652.21+148.4206*T-2.327105*T*T+1.360477e-2*T*T*T-5.155288e-5*T*T*T*T;
  Kts0:=Kp+Al*S+Bl*sqrt(S*S*S);
  Kptsp:=Kts0+P*A1*1e-5+B1*P*P*1e-10;
  A:=0.824493-4.0899e-3*T+7.6438e-5*T*T-8.2647e-7*T*T*T+5.3875e-9*T*T*T*T;
  B:=5.72466e-3-1.0227e-4*T+1.6546e-6*T*T;
  C:=4.8314e-4;
  rop:=999.842594+6.793952e-2*T-9.09529e-3*T*T+1.001685e-4*T*T*T-1.120083e-6*T*T*T*T+6.536332e-9*T*T*T*T*T;
  rots0:=rop+A*S-B*sqrt(S*S*S)+C*S*S;
  US80:=rots0/(1-p*1e-5/kptsp);
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


procedure ODBPr_GetCountryName(CountryCode:string; var CountryName:string);
begin
   {...country name}
    CountryName:='UNKNOWN';
  { with ODBDM.ibqCountry do begin
    Close;
    SQL.Clear;
    SQL.Add(' select * from CountryCode_List ');
    SQL.Add(' where NODCCountryCode=:CountryCode ');
    ParamByName('CountryCode').AsString:=CountryCode;
    Open;
    CountryName:=ODBDM.ibqCountry.FieldByName('CountryName').AsString;
    Close;
   end;     }
end;


procedure ODBPr_GetShipNamebyOCLShipCode(OCLShipCode:longint;
                  var NODCShipCode :string;
                  var ShipName:string);
begin
    ShipName:='UNKNOWN';
 {  with ODBDM.ibqVessel do begin
    Close;
    SQL.Clear;
    SQL.Add(' select * from ShipCode_List ');
    SQL.Add(' where OCLShipCode=:OCLShipCode ');
    ParamByName('OCLShipCode').AsInteger:=OCLShipCode;
    Open;
    NODCShipCode:=ODBDM.ibqVessel.FieldByName('NODCShipCode').AsString;
    ShipName:=ODBDM.ibqVessel.FieldByName('ShipName').AsString;
    Close;
   end;  }
end;



procedure ODBPr_GetShipNamebyNODCShipCode(NODCShipCode:string;
                  var ShipName:string);
begin
    ShipName:='UNKNOWN';
 {  with ODBDM.ibqVessel do begin
    Close;
    SQL.Clear;
    SQL.Add(' select * from ShipCode_List ');
    SQL.Add(' where NODCShipCode=:NODCShipCode ');
    ParamByName('NODCShipCode').AsString:=NODCShipCode;
    Open;
    ShipName:=ODBDM.ibqVessel.FieldByName('ShipName').AsString;
    Close;
   end;   }
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

//.............................................................
//Процедуры и функции вертикальной интерполяции профилей после ОА
//линейная по 2 горизонтам
function ODBPr_Line(x0,x1,x2,px1,px2:real) :real;
          begin
          if (x1-x2)<>0 then
          ODBPr_Line:=(px1*(x0-x2) - px2*(x0-x1)) / (x1 - x2);
          end;
//Лагранж  по 3 горизонтам
procedure ODBPr_Lag(x,x1,x2,x3,px1,px2,px3:real; var value:real);
   var
          a1,a2,a3              :real;
          b1,b2,b3,b4,b5,b6     :real;
          y1,y2,y3              :real;
          begin
          a1:=x-x1;          a2:=x-x2;          a3:=x-x3;
          b1:=x1-x2;         b2:=x1-x3;
          b3:=x2-x1;         b4:=x2-x3;
          b5:=x3-x1;         b6:=x3-x2;
          if (b1*b2<>0) then y1:=(a2*a3)/(b1*b2);
          if (b3*b4<>0) then y2:=(a1*a3)/(b3*b4);
          if (b5*b6<>0) then y3:=(a1*a2)/(b5*b6);
          value:=y1*px1 + y2*px2 + y3*px3;
          end;
//Рейнигер-Росс по 4 горизонтам
Procedure ODBPr_RR(level:real; l_arr,p_arr:array of real; var value:real);
   var
   kk,k,lev_n:longint;
   col,int_sx,mik_int,rown,ox,coin,check:integer;
   x,x1,x2,x3,x4,px1,px2,px3,px4        :real;
   p,p1,p2                              :real;
   c1,c2                                :real;
   a1,a2,a3,a4                          :real;
   l_12,l_23,l_34                       :real;
   ref                                  :real;
   st_lat                               :real;
   lev_f,lev_l,row_l,u                  :real;
   st                                   :string;
{..........................................................}
   begin
       x:=level;

{---uniform profile}
             x1:=l_arr[1];  px1:=p_arr[1];
             x2:=l_arr[2];  px2:=p_arr[2];
             x3:=l_arr[3];  px3:=p_arr[3];
             x4:=l_arr[4];  px4:=p_arr[4];
        if(abs(px1-px2)=0) and
          (abs(px2-px3)=0) and
          (abs(px3-px4)=0) then
          value:=(px2+px3)/2;

{---level coincide}
        coin:=0;
        if(x=x1) then begin value:=px1; coin:=1; end;
        if(x=x2) then begin value:=px2; coin:=1; end;
        if(x=x3) then begin value:=px3; coin:=1; end;
        if(x=x4) then begin value:=px4; coin:=1; end;

{y}     if(coin=0) then begin

{--- If not uniform profile}
        if(abs(px1-px2)>0) or
          (abs(px2-px3)>0) or
          (abs(px3-px4)>0) then
{x}     begin

{--- linearly interpolation}
             l_12:=ODBPr_Line(x,x1,x2,px1,px2);
             l_23:=ODBPr_Line(x,x2,x3,px2,px3);
             l_34:=ODBPr_Line(x,x3,x4,px3,px4);
          {  writeln('line; ',l_12:12:5,l_23:12:5,l_34:12:5);}
          {  readln;}
{--- reference curve}
             a1:=sqr(l_23-l_34)*l_12;
             a2:=sqr(l_12-l_23)*l_34;
             a3:=sqr(l_23-l_34);
             a4:=sqr(l_12-l_23);

                            check:=0;
         if((a3+a4)>0.000001) then check:=1;
            { writeln(a1:10:4,a2:10:4,a3:12:7,a4:12:7);
             writeln'check: ',check:5);}
         case check of
         1: begin  {exclude zero devizion}
             ref:=0.5*( l_23+ ((a1 + a2) / (a3 + a4)) );
{--- parabolic interpolation}
             ODBPr_Lag(x,x1,x2,x3,px1,px2,px3,p1);
             ODBPr_Lag(x,x2,x3,x4,px2,px3,px4,p2);
{--- weighing values}
             a1:=abs((ref-p1))*p2;
             a2:=abs((ref-p2))*p1;
             a3:=abs((ref-p1));
             a4:=abs((ref-p2));
             if (a3+a4)<>0 then value:=(a1+a2)/(a3+a4)
                           else value:=l_23;
     end; {case 1:}
         0:  value:=l_23;
     end; {case}

{x}  end; {if not uniform}
{y}  end; {if level coincide}
   end;


procedure ODBPr_VertInt(IntLev,LU1,LU2,LD1,LD2,VU1,VU2,VD1,VD2:real;
                                        var IntVal:real; var Enable:boolean);
var
k:integer;
nu,nd,IntMethod:integer;
h1Limit,h2Limit,h1,h2,h1u,h1d,h2u,h2d:real;
x1,x2,x3,x4,px1,px2,px3,px4,LineVal,pmax,pmin,deviation,rrVal,LagVal:real;
lev_arr,val_arr: array[1..4] of real;
begin
Enable:=false;

   (* update от 10.02.2010 *)
  //lev_arr[1]:=LU2; lev_arr[2]:=LU1; lev_arr[3]:=LD1; lev_arr[4]:=LD2;
  //val_arr[1]:=VU2; val_arr[2]:=VU1; val_arr[3]:=VD1; val_arr[4]:=VD2;
  lev_arr[1]:=LU1; lev_arr[2]:=LU2; lev_arr[3]:=LD1; lev_arr[4]:=LD2;  //AK
  val_arr[1]:=VU1; val_arr[2]:=VU2; val_arr[3]:=VD1; val_arr[4]:=VD2;  //AK


   //определяем пределы интервалов глубин при которых проводится интерполяция
   h1Limit:=5+(1000-5)/3500*IntLev;     {inner limit}
   h2Limit:=200+(1000-200)/3500*IntLev; {upper limit}

   //число горизонтов с наблюдениями выше и ниже стандартного
    nu:=0;
    nd:=0;
    for k:=1 to 2 do if lev_arr[k]<>-9 then nu:=nu+1;
    for k:=3 to 4 do if lev_arr[k]<>-9 then nd:=nd+1;
    //memo1.Lines.Add('nu='+inttostr(nu)+'   nd='+inttostr(nd));

{!}if (nu>0) and (nd>0) then begin

   //разности глубин
     h1:=9999; h2:=9999;
     h2u:=9999; h2d:=9999;
     h1u:=abs(IntLev-lev_arr[2]);
     h1d:=abs(IntLev-lev_arr[3]);
     if nu>1 then h2u:=abs(IntLev-lev_arr[1]);
     if nd>1 then h2d:=abs(IntLev-lev_arr[4]);

     h1:=abs(lev_arr[3]-lev_arr[2]); //inner distance
     if (nu>1) and (nd>1) then
     h2:=abs(lev_arr[4]-lev_arr[1]); //outer distance

     //выбираем метод интерполяции
     //интерполяция проводится если расстояние от интерполируемого
     //до одного из ближайших горизонтов (h1u/h1d) не превышает установленный
     //внутренний предел (h1Limit)

     //интерполяция по 3 точкам используются если растояния от интерполируемого горизонта
     //до выше или ниже лежащей пары горизонтов (h1u,h2u  или h1d,h2d) не выходят
     //за установленные пределы (h1limit,h2Limit)

     //интерполяция по 4 точкам используются если растояния между внутренней и внешней парами
     //ближайших горизонтов не выходят за установленные пределы (h1limit,h2Limit)

     //если полученное нелинейными методами значение не укладывается в диапазон
     //значений параметра на ближайших горизонтах сниженного на 50% (из наибольшего
     //значения вычитается 25% диапазона, к наименьшему прибавляется 25% диапозона)
     //то значение замещается величеной полученной линейным методом

     IntMethod:=1; //Skip Interpolation
     if (h1u<=h1Limit) or (h1d<=h1Limit) then begin
                                                 IntMethod:=3; {  + x +    Linear}
      if (h1<=h1Limit)  and (h2<=h2Limit)  then  IntMethod:=4; {+ + x + +  RR}
      if (h2u<=h2Limit) and (h2d>h2Limit)  then  IntMethod:=5; {+ + x +    LagU}
      if (h2u>h2Limit)  and (h2d<=h2Limit) then  IntMethod:=6; {  + x + +  LagD}
     end;

     //если расстояние между двумя ближайшими горизонтами больше внешнего предела,
     //интерполяция не проводится вообще
     if h1>h2Limit then IntMethod:=1;

     //memo1.Lines.Add('Int Method='+inttostr(IntMethod));


     case IntMethod of
{NO} 1: begin
         Enable:=false;
        end;
{Lin}3: begin
         Enable:=true;
         x1:=lev_arr[2];  px1:=val_arr[2];
         x2:=lev_arr[3];  px2:=val_arr[3];
         IntVal:=ODBPr_Line(IntLev,x1,x2,px1,px2);
        end;
{RR} 4: begin
         Enable:=true;
         x1:=lev_arr[2];  px1:=val_arr[2];
         x2:=lev_arr[3];  px2:=val_arr[3];
         LineVal:=ODBPr_Line(IntLev,x1,x2,px1,px2);
         IntVal:=LineVal;
         {...define nearest max and min}
         if(px1>=px2) then begin pmax:=px1; pmin:=px2; end
                      else begin pmax:=px2; pmin:=px1; end;
         Deviation:=abs(pmax-pmin)*0.25;
         ODBPr_RR(IntLev,lev_arr,val_arr,rrVal);

         //if interpolated value more or less than nearest values
         //and difference with linear int less then 25%
         if(rrVal>pmin) and (rrVal<pmax) and
           (rrVal>LineVal-deviation) and (rrVal<LineVal+deviation)
         then  IntVal:=rrVal;
     end; {4}

{LagUp} 5: begin
          Enable:=true;
            x1:=lev_arr[1];    px1:=val_arr[1];
            x2:=lev_arr[2];    px2:=val_arr[2];
            x3:=lev_arr[3];    px3:=val_arr[3];
            LineVal:=ODBPr_Line(IntLev,x2,x3,px2,px3);
            IntVal:=LineVal;
            {...define nearest max and min}
          if(px2>=px3) then begin pmax:=px2; pmin:=px3; end
                       else begin pmax:=px3; pmin:=px2; end;
            Deviation:=abs(pmax-pmin)*0.25;
            ODBPr_Lag(IntLev,x1,x2,x3,px1,px2,px3,LagVal);

            {...if interpolated value more or less than nearest values}
            if(LagVal>pmin) and (LagVal<pmax) and
              (LagVal>LineVal-deviation) and (LagVal<LineVal+deviation)
            then IntVal:=LagVal;
          end; { case 5:}

{LagDw} 6: begin
           Enable:=true;
            x1:=lev_arr[2];  px1:=val_arr[2];
            x2:=lev_arr[3];  px2:=val_arr[3];
            x3:=lev_arr[4];  px3:=val_arr[4];
            LineVal:=ODBPr_Line(IntLev,x1,x2,px1,px2);
            IntVal:=LineVal;
            {...define nearest max and min}
           if(px1>=px2) then begin pmax:=px1; pmin:=px2; end
                        else begin pmax:=px2; pmin:=px1; end;
            Deviation:=abs(pmax-pmin)*0.25;
            ODBPr_Lag(IntLev,x1,x2,x3,px1,px2,px3,LagVal);
            if(LagVal>pmin) and (LagVal<pmax) and
              (LagVal>LineVal-deviation) and (LagVal<LineVal+deviation)
            then IntVal:=LagVal;
         end; {6}
     end; {case}
{!}end;
end;



//tpot- temperature of the element of seawater raised adiabatically with
//no change of salinity to atmospheric pressure
procedure Potential_Temperature(press,t1,s1:real;var tpot:real);
		var
		pr,t,p,s:real;
                h,xk,ds,q:real;
                    function ATG(s5,t5,p5:real):real;
                    begin
                    ds:=s5-35.;
          atg:=(((-2.1687e-16*t5+1.8676e-14)*t5-4.6206e-13)*p5
          +((2.7759e-12*t5-1.1351e-10)*ds+((-5.4481e-14*t5
          +8.733e-12)*t5-6.7795e-10)*t5+1.8741e-8))*p5
          +(-4.2393e-8*t5+1.8932e-6)*ds
          +((6.6228e-10*t5-6.836e-8)*t5+8.5258e-6)*t5+3.5803e-5;
                         end;  {  ATG   }
                begin
                s:=s1;
		p:=press;
                pr:=0.;
                t:=t1;
                h:=pr-p;

                xk:=h*atg(s,t,p);
                t:=t+0.5*xk;
                q:=xk;
                p:=p+0.5*h;

                xk:=h*atg(s,t,p);
                t:=t+0.29289322*(xk-q);
                q:=0.58578644*xk+0.121320344*q;

                xk:=h*atg(s,t,p);
                t:=t+1.707106781*(xk-q);
                q:=3.414213562*xk-4.121320344*q;
                p:=p+0.5*h;

                xk:=h*atg(s,t,p);
                tpot:=t+(xk-2.0*q)/6.0;
end;    {Potential_Temperature}



// The International Equation of State of seawater
// dens [kg/m*3]
// The specific volume (or steric) anomaly (svan [m*3/kg])
Procedure IEOS80(press,t,s:real;var svan,dens:real);
	var
	st,s0,a,a1,k0,r1,sig,tt,t0,
	b,b1,kw,r2,dr35p,pt,p0,c,aw,k35,r3,
	dvan,sr,d,bw,dk,gam,sva,e,pk,v350p:real;
	i,n:integer;
	const r3500=1028.1063; r4=4.8314e-4; dr350=28.106331;
	begin
	st:=s;
	s0:=st;
	tt:=t;
	t0:=tt;
	pt:=0.1*press;
	p0:=pt;
	sr:=sqrt(abs(s0));
	r1:=((((6.536332e-9*t0-1.120083e-6)*t0+1.001685e-4)*t0-
	    9.095290e-3)*t0+6.793952e-2)*t0-28.263737;
	r2:=(((5.3875e-9*t0-8.2467e-7)*t0+7.6438e-5)*t0-4.0899e-3)*t0+
	    8.24493e-1;
	r3:=(-1.6546e-6*t0+1.0227e-4)*t0-5.72466e-3;
	sig:=(r4*s0+r3*sr+r2)*s0+r1;
	v350p:=1./r3500;
	sva:=-sig*v350p/(r3500+sig);
	dens:=sig+dr350;
	svan:=sva*1e8;
	{   }
	e:=(9.1697e-10*t0+2.0816e-8)*t0-9.9348e-7;
	bw:=(5.2787e-8*t0-6.12293e-6)*t0+3.47718e-5;
	b:=bw+e*s0;
	d:=1.91075e-4;
	c:=(-1.6078e-6*t0-1.0981e-5)*t0+2.2838e-3;
	aw:=((-5.77905e-7*t0+1.16092e-4)*t0+1.43713e-3)*t0-0.1194975;
	a:=(d*sr+c)*s0+aw;
	b1:=(-5.3009e-4*t0+1.6483e-2)*t0+7.944e-2;
	a1:=((-6.1670e-5*t0+1.09987e-2)*t0-0.603459)*t0+54.6746;
	kw:=(((-5.155288e-5*t0+1.360477e-2)*t0-2.327105)*t0+
	    148.4206)*t0-1930.06;
	k0:=(b1*sr+a1)*s0+kw;
	dk:=(b*p0+a)*p0+k0;
	k35:=(5.03217e-5*p0+3.35940552)*p0+21582.27;
	gam:=p0/k35;
	pk:=1-gam;
	sva:=sva*pk+(v350p+sva)*p0*dk/(k35*(k35+dk));
	svan:=sva*1e8;
	v350p:=v350p*pk;
	dr35p:=gam/v350p;
	dvan:=sva/(v350p*(v350p+sva));
	dens:=dr350+dr35p-dvan;
end;{IEOS80}


end.
