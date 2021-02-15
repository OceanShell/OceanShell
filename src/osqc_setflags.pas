unit osqc_setflags;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, osmain, dm, dialogs;

procedure BackupQCFlags(QCFfilename:string);
procedure RestoreQCFlags(QCFfilename:string);


implementation


procedure BackupQCFlags(QCFfilename:string);
Var
  dat: text;
  fname, tbl:string;
  id, lev_m, val1, PQF2, instr_id, prof_num: real;
begin
  (* file name without path *)
  fname:=ExtractFileName(QCFfilename);

  (* parameter name *)
  tbl:='P_'+UpperCase(copy(fname, 1, pos('_', fname)-1));

  (* opening file *)
  AssignFile(dat, QCFfilename); reset(dat);
end;


procedure RestoreQCFlags(QCFfilename:string);
Var
  dat: text;
  fname, tbl:string;
  id, lev_m, val1, PQF2, instr_id, prof_num: real;
begin
  (* file name without path *)
  fname:=ExtractFileName(QCFfilename);

  (* parameter name *)
  tbl:='P_'+UpperCase(copy(fname, 1, pos('_', fname)-1));

  (* opening file *)
  AssignFile(dat, QCFfilename); reset(dat);

  readln(dat); // skipping header
   repeat
    readln(dat, id, lev_m, val1, PQF2, instr_id, prof_num);

      with frmdm.q1 do begin
       Close;
        SQL.Clear;
        SQL.Add(' UPDATE '+tbl+' SET PQF2=:QF WHERE ');
        SQL.Add(' ID=:ID AND LEV_M=:LEV_M AND VAL=:VAL AND ');
        SQL.Add(' INSTRUMENT_ID=:INSTR_ID AND ');
        SQL.Add(' PROFILE_NUMBER=:PROF_NUM ');
        ParamByName('ID').Value:=ID;
        ParamByName('QF').Value:=PQF2;
        ParamByName('LEV_M').Value:=lev_m;
        ParamByName('VAL').Value:=val1;
        ParamByName('INSTR_ID').Value:=instr_id;
        ParamByName('PROF_NUM').Value:=prof_num;
       ExecSQL;
      end;

   until eof(dat);
  Closefile(dat);
  frmdm.q1.Close;
  frmdm.TR.CommitRetaining;
end;

end.

