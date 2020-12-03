unit osabout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, osmain, declarations_netcdf, dynlibs;

function AboutProgram:string;
function ProgramVersion(v_beg:integer; str:string):string;

implementation

function AboutProgram:string;
Var
  winver, gsw_path, gsw_info, cdo_path, cdo_info, nco_path, nco_info:string;
  AboutOpts:TProcessOptions;
  nc_inq_libvers:Tnc_inq_libvers;
begin
 {$ifdef WINDOWS}
   {$ifdef WIN32}
     winver:='i386-win32';
   {$endif}

   {$ifdef WIN64}
     winver:='x86_64-win64';
   {$endif}
   cdo_path:=GlobalSupportPath+'cdo'+PathDelim+'cdo.exe';
   nco_path:=GlobalSupportPath+'nco'+PathDelim+'ncra.exe';
 {$endif}

 {$ifdef Linux}
   {$ifdef CPU32}
     winver:='i386-linux';
   {$endif}
   {$ifdef CPU64}
     winver:='x86_64-linux';
   {$endif}
   cdo_path:='cdo';
   nco_path:='ncra';
 {$endif}

  {$ifdef DARWIN}
   {$ifdef CPU32}
     winver:='i386-darwin';
   {$endif}
   {$ifdef CPU64}
     winver:='x86_64-darwin';
   {$endif}
   cdo_path:='cdo';
   nco_path:='ncra';
 {$endif}

 nc_inq_libvers:=Tnc_inq_libvers(GetProcedureAddress(netcdf, 'nc_inq_libvers'));

 AboutOpts:=[poUsePipes, poWaitOnExit, poStderrToOutPut, poNoConsole];

 //showmessage(pchar(nc_inq_libvers));

    Result:='OceanShell ('+winver+')'+LineEnding+LineEnding+
            'netCDF: '+{ProgramVersion(0, }pchar(nc_inq_libvers)+LineEnding+
            'GSW Oceanographic Toolbox: 3.0.5'+LineEnding;

   if RunCommand(cdo_path, ['-V'], cdo_info, AboutOpts) then
      Result:= Result+'Climate Data Operators: '+ProgramVersion(31, cdo_info)+LineEnding;

   if RunCommand(nco_path, ['-r'], nco_info, AboutOpts) then
      Result:= Result+'NCO netCDF Operators: '+ProgramVersion(29, nco_info)+LineEnding;

   Result:=Result+LineEnding+'© 2004-2020 by Alexander Smirnov & Alexander Korablev';
end;


function ProgramVersion(v_beg:integer; str:string):string;
Var
  c:integer;
  buf_str:string;
begin
  c:=v_beg;
  buf_str:='';
  repeat
    inc(c);
     if str[c]<>' ' then buf_str:=buf_str+str[c];
  until (str[c]=' ') or (c=length(str));
  Result:=trim(buf_str);
end;

end.

