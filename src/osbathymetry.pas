unit osbathymetry;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, osmain, declarations_netcdf, Dialogs;

function GEBCOExists:boolean;
function GetGEBCODepth(Lon, Lat:real):integer;

implementation


(* Checking if GEBCO 2020 is in place *)
function GEBCOExists:boolean;
begin
 Result:=FileExists(GlobalSupportPath+PathDelim+'bathymetry'+PathDelim+'GEBCO_2020.nc');
end;

(* Chosing bathymtry source according to the INI settings *)
Function GetGEBCODepth(Lon, Lat:real):integer;
Var
fname: string;
ncid:integer;
start: PArraySize_t;
sp:array of smallint;
lat0, lon0, step: real;
begin
 result:=-99999;

 fname:=GlobalSupportPath+PathDelim+'bathymetry'+PathDelim+'GEBCO_2020.nc';

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
     result:=sp[0]; // getting results
   finally
      sp:=nil;
      FreeMemory(start);
    nc_close(ncid);  // Close nc file
   end;
end;

end.

