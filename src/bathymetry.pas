unit bathymetry;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, Dialogs, osmain, declarations_netcdf;

Function  GetBathymetry(Lon, Lat:real):integer;
Function  GEBCO_15(Lon, Lat:real):integer;
Function  GEBCO_30(Lon, Lat:real):integer;
Function  GEBCO_1(Lon, Lat:real):integer;
Function  ETOPO_1(Lon, Lat:real):integer;

implementation

(* Chosing bathymtry source according to the INI settings *)
Function GetBathymetry(Lon, Lat:real):integer;
Var
  Ini:TIniFile;
begin
 result:=-99999;
  try
    Ini := TIniFile.Create(IniFileName);
      if Ini.ReadInteger( 'main', 'Bathymetry', 0)=0 then result:=GEBCO_15(Lon, Lat);
      if Ini.ReadInteger( 'main', 'Bathymetry', 0)=1 then result:=GEBCO_30(Lon, Lat);
      if Ini.ReadInteger( 'main', 'Bathymetry', 0)=2 then result:=GEBCO_1(Lon, Lat);
      if Ini.ReadInteger( 'main', 'Bathymetry', 0)=3 then result:=ETOPO_1(Lon, Lat);
  finally
   ini.Free;
  end;
end;


(* GEBCO 15" 2020 *)
Function GEBCO_15(Lon, Lat:real):integer;
Var
fname: string;
ncid:integer;
start: PArraySize_t;
sp:array of smallint;
lat0, lon0, step: real;
begin
 fname:=GlobalSupportPath+'bathymetry'+PathDelim+'GEBCO_2020.nc';

 if not FileExists(fname) then begin
   Result:=-99999;
   exit; // if there's no file
 end;

 try
  // opening GEBCO_2020.nc
   nc_open(pansichar(fname), NC_NOWRITE, ncid);
     start:=GetMemory(SizeOf(TArraySize_t)*2);

     lat0:=-(89+(59/60)+(525E-1/3600));  // first latitude
     lon0:=-(179+(59/60)+(525E-1/3600)); // first longitude
     step  := 1/240;  // 15"

     // search by indexes
     start^[0]:=abs(trunc((lat0-lat)/step)); // lat index
     start^[1]:=abs(trunc((lon0-lon)/step)); // lon index

     SetLength(sp, 1); // setting an empty array
      nc_get_var1_short(ncid, 2, start^, sp);  // sending request to the file
     result:=round(sp[0]); // getting results
   finally
      sp:=nil;
      FreeMemory(start);
    nc_close(ncid);  // Close nc file
   end;
end;


(* GEBCO 30" 2014 *)
Function GEBCO_30(Lon, Lat:real):integer;
Var
fname: string;
ncid:integer;
start: PArraySize_t;
sp:array of smallint;
lat0, lon0, step: real;
begin
 fname:=GlobalSupportPath+'bathymetry'+PathDelim+'GEBCO_2014_2D.nc';

 if not FileExists(fname) then begin
   Result:=-99999;
   exit; // if there's no file
 end;

 try
  // opening GEBCO_2014_2D.nc
   nc_open(pansichar(fname), NC_NOWRITE, ncid);
     start:=GetMemory(SizeOf(TArraySize_t)*2);

     lat0:=-(89+(59/60)+(45/3600));  // first latitude
     lon0:=-(179+(59/60)+(45/3600)); // first longitude
     step  := 1/120; // 30"

     // search by indexes
     start^[0]:=abs(trunc((lat0-lat)/step)); // lat index
     start^[1]:=abs(trunc((lon0-lon)/step)); // lon index

     SetLength(sp, 1); // setting an empty array
      nc_get_var1_short(ncid, 0, start^, sp);  // sending request to the file
     result:=sp[0]; // getting results
  finally
    sp:=nil;
    FreeMemory(start);
   nc_close(ncid);  // Close nc file
  end;
end;


Function GEBCO_1(Lon, Lat:real):integer;
Var
Ini:TIniFile;
fname: string;
start: PArraySize_t;
sp:array of smallint;
dp:array of double;
T_lat, B_Lat, L_lon, R_Lon, lat0, lon0, step, H_point, Sum_dist, Dist:real;
ncid, latidp, lonidp, varidp, node0_lat, node0_lon, Hlt, Hlb, Hrt, Hrb:integer;
begin
  try
    Ini := TIniFile.Create(IniFileName);

   //GEBCO 30"
   if Ini.ReadInteger( 'main', 'Bathymetry', 0)=0 then begin
    fname:=GlobalPath+'support\bathymetry\GEBCO_2014_2D.nc';
    latidp:= 1;
    lonidp:= 2;
    varidp:= 0;
    step  := 1/120;
   end;

   //ETOPO 1'
   if Ini.ReadInteger( 'main', 'Bathymetry', 0)=1 then begin
    fname:=GlobalPath+'support\bathymetry\ETOPO1_Ice_g_gmt4.nc';
    latidp:= 1;
    lonidp:= 0;
    varidp:= 2;
    step  := 1/60;
   end;
  finally
   ini.Free;
  end;

 if not FileExists(fname) then begin
   Result:=-999;
   exit; // if there's no file
 end;

 try
   nc_open(pansichar(AnsiString(fname)), NC_NOWRITE, ncid);

   try
     start:=GetMemory(SizeOf(TArraySize_t));

     start^[0]:=0;
     SetLength(dp, 1);
       nc_get_var1_double(ncid, latidp, start^, dp);
     Lat0:=dp[0];

     start^[0]:=0;
     SetLength(dp, 1);
       nc_get_var1_double(ncid, lonidp, start^, dp);
     Lon0:=dp[0];

     node0_lat:=abs(trunc((lat0-lat)/step));
     node0_lon:=abs(trunc((lon0-lon)/step));

     start^[0]:=node0_lat+1;
     SetLength(dp, 1);
       nc_get_var1_double(ncid, latidp, start^, dp);
     T_Lat:=dp[0];

     start^[0]:=node0_lat;
     SetLength(dp, 1);
       nc_get_var1_double(ncid, latidp, start^, dp);
     B_Lat:=dp[0];

     start^[0]:=node0_lon;
     SetLength(dp, 1);
       nc_get_var1_double(ncid, lonidp, start^, dp);
     L_Lon:=dp[0];

     start^[0]:=node0_lon+1;
     SetLength(dp, 1);
       nc_get_var1_double(ncid, lonidp, start^, dp);
     R_Lon:=dp[0];
   finally
    dp:=nil;
    FreeMemory(start);
   end;

     start:=GetMemory(SizeOf(TArraySize_t)*2);

     start^[0]:=node0_lat+1;
     start^[1]:=node0_lon;
     SetLength(sp, 1);
      nc_get_var1_short(ncid, varidp, start^, sp);
     hlt:=round(sp[0]);

     start^[0]:=node0_lat+1;
     start^[1]:=node0_lon+1;
     SetLength(sp, 1);
      nc_get_var1_short(ncid, varidp, start^, sp);
     hrt:=round(sp[0]);

     start^[0]:=node0_lat;
     start^[1]:=node0_lon;
     SetLength(sp, 1);
      nc_get_var1_short(ncid, varidp, start^, sp);
     hlb:=round(sp[0]);

     start^[0]:=node0_lat;
     start^[1]:=node0_lon+1;
     SetLength(sp, 1);
      nc_get_var1_short(ncid, varidp, start^, sp);
     hrb:=round(sp[0]);

 finally
  sp:=nil;
  FreeMemory(start);
  nc_close(ncid);  // Close file
 end;

    H_Point:=0;
    Sum_Dist:=0;

    Dist:=111.3*sqrt(sqr(Lat-T_lat)+
     sqr(cos(Pi/360*(Lat+T_Lat))*(Lon-L_Lon)));
    If Dist=0 then
     Dist:=1E-10;
    H_point:=H_point+HLT/Dist;
    Sum_Dist:=Sum_Dist+1/Dist;

    Dist:=111.3*sqrt(sqr(Lat-T_lat)+
     sqr(cos(Pi/360*(Lat+T_Lat))*(Lon-R_Lon)));
    If Dist=0 then
     Dist:=1E-10;
    H_point:=H_point+HRT/Dist;
    Sum_Dist:=Sum_Dist+1/Dist;

    Dist:=111.3*sqrt(sqr(Lat-B_lat)+
     sqr(cos(Pi/360*(Lat+B_Lat))*(Lon-L_Lon)));
    If Dist=0 then
     Dist:=1E-10;
    H_point:=H_point+HLB/Dist;
    Sum_Dist:=Sum_Dist+1/Dist;

    Dist:=111.3*sqrt(sqr(Lat-B_lat)+
     sqr(cos(Pi/360*(Lat+B_Lat))*(Lon-R_Lon)));
    If Dist=0 then
     Dist:=1E-10;
    H_point:=H_point+HRB/Dist;
    Sum_Dist:=Sum_Dist+1/Dist;

 result:=round(H_point/Sum_Dist);
end;


Function ETOPO_1(Lon, Lat:real):integer;
begin
 result:=-99999;
end;


end.

