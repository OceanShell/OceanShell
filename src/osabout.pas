unit osabout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, declarations_netcdf;

function AboutProgram:string;
function ProgramVersion(v_beg:integer; str:string):string;

implementation

function AboutProgram:string;
Var
  winver, ncver:string;
  yy, mn, dd: word;
begin
 {$ifdef WINDOWS}
   {$ifdef WIN32}
     winver:='i386-win32';
   {$endif}

   {$ifdef WIN64}
     winver:='x86_64-win64';
   {$endif}
 {$endif}

 {$ifdef Linux}
   {$ifdef CPU32}
     winver:='i386-linux';
   {$endif}
   {$ifdef CPU64}
     winver:='x86_64-linux';
   {$endif}
 {$endif}

  {$ifdef DARWIN}
   {$ifdef CPU32}
     winver:='i386-darwin';
   {$endif}
   {$ifdef CPU64}
     winver:='x86_64-darwin';
   {$endif}
 {$endif}

  DecodeDate(now, yy, mn, dd);

  ncver:='netCDF: '+ProgramVersion(0, pansichar(nc_inq_libvers));

  result:='OceanShell ('+winver+')'+LineEnding+
                ncver+LineEnding+LineEnding+
                'Alexander Smirnov & Alexander Korablev'+LineEnding+
                '© 2004-'+inttostr(yy);
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

