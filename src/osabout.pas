unit osabout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, DateUtils,

  declarations_netcdf;

function AboutProgram:string;
function ProgramVersion(v_beg:integer; str:string):string;

implementation

function AboutProgram:string;
Var
  osver, ncver:string;
begin
 {$ifdef WINDOWS}
   {$ifdef WIN32}
     oser:='i386-win32';
   {$endif}

   {$ifdef WIN64}
     osver:='x86_64-win64';
   {$endif}
 {$endif}

 {$ifdef Linux}
   {$ifdef CPU32}
     osver:='i386-linux';
   {$endif}
   {$ifdef CPU64}
     osver:='x86_64-linux';
   {$endif}
 {$endif}

  {$ifdef DARWIN}
   {$ifdef CPU32}
     osver:='i386-darwin';
   {$endif}
   {$ifdef CPU64}
     osver:='x86_64-darwin';
   {$endif}
 {$endif}

 // ncver:='netCDF: '+ProgramVersion(0, pansichar(nc_inq_libvers));

  result:='OceanShell ('+osver+')'+LineEnding+
                ncver+LineEnding+LineEnding+
                'Alexander Smirnov & Alexander Korablev'+LineEnding+
                '© 2004-'+IntToStr(YearOf(now));
   showmessage(result);
end;


function ProgramVersion(v_beg:integer; str:string):string;
Var
  c:integer;
  buf_str:string;
begin
   showmessage(str);
  c:=v_beg;
  buf_str:='';
  repeat
    inc(c);
     if str[c]<>' ' then buf_str:=buf_str+str[c];
  until (str[c]=' ') or (c=length(str));
  Result:=trim(buf_str);
end;

end.

