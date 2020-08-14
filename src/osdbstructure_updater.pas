unit osdbstructure_updater;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, Dialogs, osmain, dm;

procedure CheckDBStructure;

implementation


(* checking if all the tables and fields are present in the DB *)
procedure CheckDBStructure;
Var
  k: integer;
  tmp_lst: TStringList;
  temp_fl:boolean;
  tbl_name, fld_name:string;
begin
  tmp_lst:=TStringList.Create;

  frmdm.IBDB.GetTableNames(tmp_lst, False);

  temp_fl:=false;
  for k:=0 to tmp_lst.Count-1 do begin
    tbl_name:=tmp_lst.Strings[k];
    if tbl_name='TEMPORARY_ID_LIST' then temp_fl:=true;
  end;

  if temp_fl=false then begin
   With frmdm.q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' CREATE GLOBAL TEMPORARY TABLE TEMPORARY_ID_LIST ( ');
       SQL.Add(' ID BIGINT NOT NULL) ');
       SQL.Add(' ON COMMIT PRESERVE ROWS ');
     ExecSQL;
   end;
   frmdm.TR.CommitRetaining;

    With frmdm.q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' ALTER TABLE TEMPORARY_ID_LIST ADD CONSTRAINT ');
       SQL.Add(' PK_TEMPORARY_ID_LIST PRIMARY KEY (ID) ');
     ExecSQL;
    end;
   frmdm.TR.CommitRetaining;
  end;

  frmdm.IBDB.GetFieldNames('STATION', tmp_lst);
  temp_fl:=false;
  for k:=0 to tmp_lst.Count-1 do begin
    fld_name:=tmp_lst.Strings[k];
    if fld_name='BOTTOMDEPTH_GEBCO' then temp_fl:=true;
  end;

  if temp_fl=false then begin
   With frmdm.q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' ALTER TABLE STATION ADD BOTTOMDEPTH_GEBCO INTEGER ');
     ExecSQL;
   end;
   frmdm.TR.CommitRetaining;
  end;


  frmdm.IBDB.GetFieldNames('CRUISE', tmp_lst);

  temp_fl:=false;
  for k:=0 to tmp_lst.Count-1 do begin
    fld_name:=tmp_lst.Strings[k];
    if fld_name='SELECTED' then temp_fl:=true;
  end;

  if temp_fl=false then begin
   With frmdm.q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' ALTER TABLE CRUISE ADD SELECTED BOOLEAN ');
     ExecSQL;
   end;
   frmdm.TR.CommitRetaining;
  end;


  temp_fl:=false;
  for k:=0 to tmp_lst.Count-1 do begin
    fld_name:=tmp_lst.Strings[k];
    if fld_name='DUPLICATE' then temp_fl:=true;
  end;

  if temp_fl=false then begin
   With frmdm.q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' ALTER TABLE CRUISE ADD DUPLICATE BOOLEAN ');
     ExecSQL;
   end;
   frmdm.TR.CommitRetaining;
  end;


  frmdm.IBDB.GetFieldNames('ENTRY', tmp_lst);
  temp_fl:=false;
  for k:=0 to tmp_lst.Count-1 do begin
    fld_name:=tmp_lst.Strings[k];
    if fld_name='SELECTED' then temp_fl:=true;
  end;

  if temp_fl=false then begin
   With frmdm.q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' ALTER TABLE ENTRY ADD SELECTED BOOLEAN ');
     ExecSQL;
   end;
   frmdm.TR.CommitRetaining;
  end;


end;

end.

