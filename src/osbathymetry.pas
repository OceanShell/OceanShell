unit osbathymetry;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, osmain, declarations_netcdf, IniFiles, dynlibs;

function GetGEBCODepth(Lon, Lat:real):integer;

implementation


(* Choosing bathymtry source according to the INI settings *)
Function GetGEBCODepth(Lon, Lat:real):integer;
Var
Ini:TIniFile;
fname: string;
ncid:integer;
start: PArraySize_t;
sp:array of smallint;
lat0, lon0, step: real;

nc_open:Tnc_open;
nc_get_var1_short:Tnc_get_var1_short;
nc_close:Tnc_close;
begin
 result:=-99999;

 Ini := TIniFile.Create(IniFileName);
 try
  fname:=Ini.ReadString('main', 'GEBCOPath', '');
 finally
  Ini.Free;
 end;

 (* if full GEBCO_2020.nc is found *)
 if FileExists(fname)=true then begin
   lat0:=-(89+(59/60)+(525E-1/3600));  // first latitude
   lon0:=-(179+(59/60)+(525E-1/3600)); // first longitude
   step  := 1/240;  // 15"
 end else begin
   fname:=GlobalPath+'GEBCO_2020_6min.nc';
   lat0:=-(89+(59/60)+(525E-1/3600));  // first latitude
   lon0:=-(179+(59/60)+(525E-1/3600)); // first longitude
   step  := 1/10;  // 6'
 end;

 try
  // opening GEBCO_2020.nc
   nc_open:=Tnc_open(GetProcedureAddress(netcdf, 'nc_open'));
   nc_get_var1_short:=Tnc_get_var1_short(GetProcedureAddress(netcdf, 'nc_get_var1_short'));
   nc_close:=Tnc_close(GetProcedureAddress(netcdf, 'nc_close'));

   nc_open(pansichar(fname), NC_NOWRITE, ncid);
     start:=GetMemory(SizeOf(TArraySize_t)*2);

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

