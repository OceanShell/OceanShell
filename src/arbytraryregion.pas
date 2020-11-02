unit arbytraryregion;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

var
  Num_point_BLN:array[1..1] of integer;
  Coord_BLN:array[1..2,1..200] of real;
  Long_min_BLN,Lat_min_BLN, lat_p, lon_p:real;


Procedure GetArbirtaryRegion(sea_border:string;
  Var LatMin, LatMax, LonMin, LonMax: real);

Function Point_Status(Long_p,Lat_p:real):byte;

implementation


Procedure GetArbirtaryRegion(sea_border:string;
  Var LatMin, LatMax, LonMin, LonMax: real);
var
  fin:text;
  fname, st: string;
  lat, lon:real;
  ci1:integer;
begin

  fname:=sea_border;

  if not FileExists(fname) then exit;

  AssignFile(fin, fname ); reset(fin);
  readln(fin, st);

   ci1:=1;
   Latmin:=90;
   Latmax:=-90;
   lonmin:=180;
   lonmax:=-180;

  repeat
   readln(fin, st);

   lon:=StrToFloat(trim(copy(st, 1, pos(',', st)-1)));
   lat:=StrToFloat(trim(copy(st, pos(',', st)+1, length(st))));

      Coord_BLN[1,ci1]:=lon;
      Coord_BLN[2,ci1]:=lat;

      if Coord_BLN[1,ci1]<lonmin then
        lonmin:=Coord_BLN[1,ci1];
      if Coord_BLN[1,ci1]>lonmax then
        lonmax:=Coord_BLN[1,ci1];
      if Coord_BLN[2,ci1]<latmin then
        latmin:=Coord_BLN[2,ci1];
      if Coord_BLN[2,ci1]>latmax then
        latmax:=Coord_BLN[2,ci1];
      inc(ci1);
  until eof(fin);
  CloseFile(fin);

    Coord_BLN[1,ci1]:=Coord_BLN[1,1];
    Coord_BLN[2,ci1]:=Coord_BLN[2,1];
    Num_point_BLN[1]:=ci1;

    Long_min_BLN:=lonmin;
    Lat_min_bln:=latmin;
end;


Function Point_Status(Long_p,Lat_p:real):byte;
Label
  Lab_1;
Const
  {Задание сдвига базовой точки от минимальных значений координат в BLN-файле}
  Shift=0.123456789;
var
  Long_Point,Long_Base,Lat_Point,Lat_Base:real;
  K_Base,B_Base,K_BLN,B_BLN:real;
  Current_Max_Long,Current_Min_Long,Current_Max_Lat,Current_Min_Lat:real;
  ci4,ci3,First_Point,Num_Transsect:integer;

Function Verify:Boolean;
begin
  {Проверка на принадлежность точки пересечения !!!!отрезку!!! базовой прямой}
  Verify:=False;

  if ((Long_point>Long_Base) and (Lat_point>Lat_Base)
    and (Long_point<=Long_p) and (Lat_point<=Lat_p)) then
  begin
    Current_Min_Long:=Coord_BLN[1,ci4];
    Current_Max_Long:=Coord_BLN[1,ci4+1];
    Current_Min_Lat:=Coord_BLN[2,ci4];
    Current_Max_Lat:=Coord_BLN[2,ci4+1];
    if Current_Max_Long<Current_Min_Long then
    begin
      Current_Max_Long:=Coord_BLN[1,ci4];
      Current_Min_Long:=Coord_BLN[1,ci4+1];
    end;
    if Current_Max_Lat<Current_Min_Lat then
    begin
      Current_Max_Lat:=Coord_BLN[2,ci4];
      Current_Min_Lat:=Coord_BLN[2,ci4+1];
    end;

    {Не забыть о равенстве значений на границе}
    if (Long_point>=Current_Min_Long) and (Lat_point>=Current_Min_Lat)
      and (Long_point<=Current_Max_Long) and (Lat_point<=Current_Max_Lat) then
      begin
      Verify:=True
     end;
  end;
end;

begin
  {Определение координат узловой точки отсчета}
Lab_1:

  Long_Base:=Long_min_BLN-Shift*random;
  Lat_base:=Lat_min_BLN-Shift*random;

  {Определение коээфициентов уравнения прямой от базовой точки до исследуемой.
  Уравнение прямой в виде y=kx+b}

  K_Base:=(Lat_p-Lat_base)/(Long_p-Long_base);

  B_Base:=Lat_p-K_Base*Long_p;
  {Если в контуре всего один объект}
  First_Point:=1;
  ci3:=1;

  Num_Transsect:=0;
  for ci4:=First_Point to First_Point+Num_point_BLN[ci3]-2 do
  begin
    if Coord_BLN[1,ci4]<>Coord_BLN[1,ci4+1] then
    begin
      K_BLN:=(Coord_BLN[2,ci4+1]-Coord_BLN[2,ci4])/
       (Coord_BLN[1,ci4+1]-Coord_BLN[1,ci4]);
      B_BLN:=Coord_BLN[2,ci4]-Coord_BLN[1,ci4]*K_BLN;

      if K_BLN=K_Base then
      begin
       goto Lab_1
      end
      else
      begin
        Long_point:=(B_BLN-B_Base)/(K_Base-K_BLN);
        Lat_Point:=K_BLN*Long_point+B_BLN;
      end;

    end
    else
    begin
      Long_Point:=Coord_BLN[1,ci4];
      Lat_Point:=K_Base*Long_point+B_Base;
    end;

    if Verify then
    begin
      Inc(Num_Transsect);
    end;
  end;
  Point_Status:=Num_Transsect;
end;

end.

