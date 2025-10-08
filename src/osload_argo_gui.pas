unit osload_argo_gui;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SQLDB, DB,
  DateUtils, Variants, BufDataset, LCLIntf, Buttons, ExtCtrls, math, dynlibs,
  IniFiles,
  osqc_cruiseinfo, osload_argo;

type

  { Tfrmload_argo }

  Tfrmload_argo = class(TForm)
    btnSelectDataFolder: TButton;
    btnRun: TButton;
    cgTasks: TCheckGroup;
    chkWrite: TCheckBox;
    ePath: TEdit;
    GroupBox1: TGroupBox;
    Memo1: TMemo;

    procedure FormShow(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnSelectDataFolderClick(Sender: TObject);

  private
    procedure GetTableName(var_name:string; Var tbl_name: string);
    procedure QFMapping(argo_QF:integer; var QF:integer);
    procedure UpdateCRUISE;
    procedure UpdateSTATION;
    procedure GreyList;
    procedure GreyListUpdateTable(cruise_id, QF:integer;
      tbl_name:string; dd1, dd2:tDateTime);
    procedure DeleteEmptyStations;
    procedure DeleteDuplicates;
  public

  end;

var
  frmload_argo: Tfrmload_argo;

implementation

{$R *.lfm}

{ Tfrmload_argo }

uses osmain, dm, declarations_netcdf, GibbsSeaWater, procedures;


procedure Tfrmload_argo.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
  k:integer;
begin

  Ini := TIniFile.Create(IniFileName);
   try
     ePath.Text := Ini.ReadString('osload_argo', 'data_path',  '');
   finally
     Ini.Free;
   end;

  // all tasks checked
  for k:=0 to cgTasks.Items.Count-1 do cgTasks.Checked[k]:=false;

end;


(* Running tasks one by one *)
procedure Tfrmload_argo.btnRunClick(Sender: TObject);
begin
 memo1.Clear;
  if cgTasks.Checked[0] then UpdateCRUISE;
  if cgTasks.Checked[1] then UpdateSTATION;
  //if cgTasks.Checked[2] then UpdateCruiseInfo;
  {if cgTasks.Checked[4] then GreyList;
  if cgTasks.Checked[5] then DeleteDuplicates;}
end;



procedure Tfrmload_argo.btnSelectDataFolderClick(Sender: TObject);
Var
  Ini:TIniFile;
begin
  if frmosmain.ODir.Execute then ePath.Text:=frmosmain.ODir.FileName+PathDelim;

  Ini := TIniFile.Create(IniFileName);
   try
     Ini.WriteString('osload_argo', 'data_path', ePath.Text);
   finally
     Ini.Free;
   end;
end;


(* reading ar_index_global_meta.txt and updating CRUISE *)
procedure Tfrmload_argo.UpdateCRUISE;
Var
  dat:text;
  c, k, cnt_added, cnt_updated, cnt_removed, ID:integer;
  st, fname, prof_type, inst_code, date_upd, platf, buf_str:string;
  country_id, institute_id, project_id: integer;

  cnt_add, cnt_upd, cnt_del: integer;

  stdate_upd:TDateTime;

  Qt1, Qt2:TSQLQuery;
  TRt:TSQLTransaction;

  ID_buf:TBufDataset;

  ncid, varidp:integer;
  ip: array of PAnsiChar;
  proj, pi, op_inst, notes_str, log_path:string;

  dat1, dat2, dat3:text;
  DateStart:TDateTime;
begin
if not FileExists(epath.text+'ar_index_global_meta.txt') then
  if MessageDlg(epath.text+'ar_index_global_meta.txt cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

  DateStart:=now;

   With memo1.lines do begin
     add('');
     add('Updating CRUISE');
     add('Start: '+datetimetostr(DateStart));
     add('')
   end;

   log_path:=GlobalUnloadPath+'log'+PathDelim;
    if not DirectoryExists(log_path) then CreateDir(log_path);

 //  ARGO_CRUISE(netcdf, frmdm.IBDB, epath.Text, log_path, chkWrite.Checked, cnt_add, cnt_upd, cnt_del);

   With memo1.lines do begin
     add('Added: '+inttostr(cnt_add));
     add('Updated: '+inttostr(cnt_upd));
     add('Removed: '+inttostr(cnt_del));
     add('');
     add('Done! '+datetimetostr(Now));
   end;

   OpenDocument(PChar(log_path));
end;


procedure Tfrmload_argo.UpdateSTATION;
Var
  DateStart: TDateTime;
  cnt_kept, cnt_updated, cnt_new, cnt_skipped, cnt_error: integer;
  md_file, log_path: string;
begin

 md_file := epath.text+'argo_synthetic-profile_index.txt';
 //md_file := epath.text+'ar_index_global_prof.txt';

 if not FileExists(md_file) then
   if MessageDlg(md_file+' cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

 log_path:=GlobalUnloadPath+'log'+PathDelim;
   if not DirectoryExists(log_path) then CreateDir(log_path);

  DateStart:=now;

  with memo1.Lines do begin
    add('');
    add('Updating STATION from '+md_file);
    add('Start: '+datetimetostr(DateStart));
    add('');
  end;

  ARGO_STATION(frmdm.IBDB, md_file, log_path, chkWrite.Checked,
               cnt_kept, cnt_updated, cnt_new, cnt_skipped, cnt_error);

  with memo1.Lines do begin
    add('Unchanged: '+inttostr(cnt_kept));
    add('Updated: '  +inttostr(cnt_updated));
    add('Added: '    +inttostr(cnt_new));
    add('Skipped: '  +inttostr(cnt_skipped));
    add('Insert error: '+inttostr(cnt_error));
    add('');
    add('Done: '+DateTimeToStr(Now));
  end;
end;


procedure Tfrmload_argo.GreyList;
var
 dat, dat1:text;
 fname, buf_str, st, log_path: string;
 cruise_id, QF, argo_QF, c, k: integer;
 var_name, tbl_name: string;
 DateStart, date_beg, date_end:TDateTime;
 yy, mn, dd: word;
begin
 fname:='ar_greylist.txt';
 if not FileExists(epath.text+fname) then
   if MessageDlg(fname+' cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

  DateStart:=now;

  memo1.lines.add('');
  memo1.lines.add('Processing "grey" list ');
  memo1.lines.add('Start: '+datetimetostr(DateStart));
  memo1.lines.add('');

  AssignFile(dat, epath.text+fname); reset(dat);
  readln(dat);

  log_path:=epath.text+PathDelim+'_Logs'+PathDelim;
   if not DirectoryExists(log_path) then CreateDir(log_path);

  AssignFile(dat1, log_path+'GreyList_progress.txt'); rewrite(dat1);

  repeat
   readln(dat, st);

   c:=0;
   for k:=1 to 5 do begin
    buf_str:='';
     repeat
      inc(c);
      if st[c]<>',' then buf_str:=buf_str+st[c];
     until (st[c]=',') or (c=length(st));
      case k of
       1: cruise_ID:=20000000+strtoint(buf_str);
       2: var_name:=trim(buf_str);
       3: begin
           yy:=StrToInt(copy(buf_str, 1, 4));
           mn:=StrToInt(copy(buf_str, 5, 2));
           dd:=StrToInt(copy(buf_str, 7, 2));
           date_beg:=EncodeDate(yy, mn, dd);
       end;
       4: begin
           if trim(buf_str)<>'' then begin
            yy:=StrToInt(copy(buf_str, 1, 4));
            mn:=StrToInt(copy(buf_str, 5, 2));
            dd:=StrToInt(copy(buf_str, 7, 2));
            date_end:=EncodeDate(yy, mn, dd)
           end else
            date_end:=EncodeDate(9999,01,01);
       end;
       5: argo_qf:=strtoint(buf_str);
      end;
   end;

   QFMapping(argo_QF, QF);

   if QF>0 then begin
     if (var_name<>'PRES') then begin
       GetTableName(var_name, tbl_name);
       if (tbl_name<>'') then begin
         GreyListUpdateTable(cruise_id, QF, tbl_name, date_beg, date_end);

         writeln(dat1, inttostr(cruise_id)+'   '+
                       var_name+'   '+
                       datetostr(date_beg)+'   '+
                       datetostr(date_end));
         flush(dat1);
       end else
         writeln(dat1, 'Error: '+st);
     end;

     if (var_name='PRES') then begin
       for k:=0 to frmosmain.ListBox1.Count-1 do begin
         tbl_name:=frmosmain.ListBox1.Items.Strings[k];
         GreyListUpdateTable(cruise_id, QF, tbl_name, date_beg, date_end);
       end;
        writeln(dat1, inttostr(cruise_id)+'   '+
                       var_name+'   '+
                       datetostr(date_beg)+'   '+
                       datetostr(date_end));
         flush(dat1);
     end;
   end;  //QF>0

  until eof(dat);
  CloseFile(dat);
  CloseFile(dat1);

  with memo1.Lines do begin
    add('');
    add('Done: '+DateTimeToStr(Now));
  end;
end;


procedure Tfrmload_argo.GreyListUpdateTable(cruise_id, QF:integer;
      tbl_name:string; dd1, dd2:tDateTime);
Var
  TRt:TSQLTransaction;
  Qt, Qt1:TSQLQuery;
begin
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt:=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

  Qt1:=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

 {  showmessage(inttostr(cruise_id)+'    '+
        datetostr(dd1)+'   '+datetostr(dd2)+
        tbl_name+'   '+inttostr(qf)); }

  try
   with Qt do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT ID FROM STATION WHERE ');
     SQL.Add(' DATEANDTIME BETWEEN :dd1 AND :dd2 AND ');
     SQL.Add(' CRUISE_ID=:cr_ID ');
     ParamByName('cr_id').Value:=cruise_id;
     ParamByName('dd1').Value:=dd1;
     ParamByName('dd2').Value:=dd2;
    Open;
   end;

   while not Qt.EOF do begin
    with Qt1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' UPDATE '+tbl_name);
      SQL.Add(' SET PQF1=:QF, PQF2=:QF ');
      SQL.Add(' WHERE ID=:ID AND PQF1<>QF ');
      ParamByName('ID').Value:=Qt.Fields[0].Value;
      ParamByName('QF').Value:=QF;
     ExecSQL;
    end;
    Qt.Next;
   end;

   Trt.Commit;
  except
    Trt.Rollback;
  end;
  Qt.Free;
  Trt.Free;
end;



procedure Tfrmload_argo.DeleteEmptyStations;
Var
 Qt1, Qt2:TSQLQuery;
 TRt:TSQLTransaction;

 log_path:string;
 k, cnt, cnt_t, cnt_s, cnt_o, cnt_del:integer;
 dat: text;

 DateStart: TDateTime;
begin
Memo1.Clear;

  DateStart:=now;

  memo1.lines.add('');
  memo1.lines.add('Removing empty stations');
  memo1.lines.add('Start: '+timetostr(DateStart));
  memo1.lines.add('');

   log_path:=epath.text+PathDelim+'_logs'+PathDelim;
    if not DirectoryExists(log_path) then CreateDir(log_path);

   AssignFile(dat, log_path+'Empty.txt');   rewrite(dat);

 try
    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;

    Qt1:=TSQLQuery.Create(self);
    Qt1.Database:=frmdm.IBDB;
    Qt1.Transaction:=TRt;

    Qt2:=TSQLQuery.Create(self);
    Qt2.Database:=frmdm.IBDB;
    Qt2.Transaction:=TRt;

     with Qt1 do begin
      Close;
       SQL.Clear;
       SQL.Add('SELECT ID FROM STATION WHERE ID>20000001 and ID<30000000 ORDER BY ID ');
      Open;
      Last;
      First;
     end;

     cnt:=Qt1.RecordCount;
     k:=0;
     cnt_del:=0;
     while not Qt1.EOF do begin

     with Qt2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT count(ID) FROM P_TEMPERATURE ');
        SQL.Add(' WHERE ID=:ID ');
        ParamByName('ID').AsInteger:=Qt1.FieldByName('ID').AsInteger;
       Open;
        cnt_t:=Qt2.Fields[0].Value;
       Close;
      end;

      with Qt2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT count(ID) FROM P_SALINITY ');
        SQL.Add(' WHERE ID=:ID ');
        ParamByName('ID').AsInteger:=Qt1.FieldByName('ID').AsInteger;
       Open;
        cnt_s:=Qt2.Fields[0].Value;
       Close;
      end;

      with Qt2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT count(ID) FROM P_OXYGEN ');
        SQL.Add(' WHERE ID=:ID ');
        ParamByName('ID').AsInteger:=Qt1.FieldByName('ID').AsInteger;
       Open;
        cnt_o:=Qt2.Fields[0].Value;
       Close;
      end;

      if (cnt_t=0) and (cnt_s=0) and (cnt_o=0) then begin
       with Qt2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' DELETE FROM STATION ');
         SQL.Add(' WHERE ID=:ID ');
         ParamByName('ID').AsInteger:=Qt1.FieldByName('ID').AsInteger;
        ExecSQL;
       end;

       inc(cnt_del);
       writeln(dat, Qt1.FieldByName('ID').AsInteger);
      end;

      inc(k);
      {$IFDEF WINDOWS}
        Procedures.ProgressTaskbar(k, cnt);
      {$ENDIF}

      Qt1.Next;
     end;
     Closefile(dat);

     with memo1.Lines do begin
       add('Removed: '  +inttostr(cnt_del));
       add('');
       add('Done! Time spent: '+timetostr(now-DateStart));
     end;
    OpenDocument(PChar(log_path+'Empty.txt'));

 finally
  Trt.Commit;
  Qt1.Free;
  Qt2.Free;
  Trt.Free;
 end;
end;


procedure tfrmload_argo.DeleteDuplicates;
Var
TRt:TSQLTransaction;
Qt1, Qt2:TSQLQuery;

k, cnt_dup:integer;
st, buf_id:string;
lst:TStringList;
begin
TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt1 :=TSQLQuery.Create(self);
Qt1.Database:=frmdm.IBDB;
Qt1.Transaction:=TRt;

Qt2 :=TSQLQuery.Create(self);
Qt2.Database:=frmdm.IBDB;
Qt2.Transaction:=TRt;

 try
   (* Select everyting except the specified source *)
   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT LIST(id) ');
     SQL.Add(' FROM station ');
     SQL.Add(' WHERE CRUISE_ID BETWEEN 20000001 and 30000001 ');
     SQL.Add(' GROUP BY cruise_id, st_number_origin ');
     SQL.Add(' HAVING ( COUNT(*) > 1 ) ');
    Open;
    Last;
    First;
   end;


   cnt_dup:=0;
   while not Qt1.EOF do begin
    st:=VarToStr(Qt1.Fields[0].Value);

    k:=0;
    buf_id:='';
    lst:=TStringList.Create();
    lst.Sorted:=true;
     repeat
      inc(k);
      if st[k]<>',' then buf_id:=buf_id+st[k];
      if (st[k]=',') or (k=length(st)) then begin
        lst.Add(buf_id);
        buf_id:='';
      end;
      until (k=length(st));

      for k:=1 to lst.Count-1 do begin
       inc(cnt_dup);

        with Qt2 do begin
         Close;
          SQL.Clear;
          SQL.Add(' DELETE FROM STATION ');
          SQL.Add(' WHERE ID='+lst.Strings[k]);
         ExecSQL;
        end;

        caption:='Duplicates: '+inttostr(cnt_dup);
        Application.ProcessMessages;
      end;
      lst.Free;

     {$IFDEF WINDOWS}
        Procedures.ProgressTaskbar(k, qt1.RecordCount);
     {$ENDIF}

    Qt1.Next;
   end;


 finally
  Showmessage('Found '+inttostr(cnt_dup)+' duplicates');

  {$IFDEF WINDOWS}
    Procedures.ProgressTaskbar(0, 0);
  {$ENDIF}

  frmdm.TR.CommitRetaining;
  Trt.Commit;
  Qt1.Close;
  Qt1.Free;
  Trt.Free;
 end;


end;

procedure Tfrmload_argo.GetTableName(var_name:string; Var tbl_name: string);
begin
 tbl_name:='';
  if var_name='TEMP'             then tbl_name:='P_TEMPERATURE';
  if var_name='PSAL'             then tbl_name:='P_SALINITY';
  if var_name='DOXY'             then tbl_name:='P_OXYGEN';
  if var_name='CDOM'             then tbl_name:='P_CDOM';
  if var_name='CHLA'             then tbl_name:='P_CHLOROPHYLL';
  if var_name='NITRATE'          then tbl_name:='P_NITRATE';
  if var_name='TURBIDITY'        then tbl_name:='P_TURBIDITY';
  if var_name='PH_IN_SITU_TOTAL' then tbl_name:='P_PHTSINSITUTP';
  if var_name='BISULFIDE'        then tbl_name:='P_BISULFIDE';
  //BBP700
  //DOWN_IRRADIANCE380
  //DOWN_IRRADIANCE412
  //DOWN_IRRADIANCE490
  if var_name='DOWNWELLING_PAR'  then tbl_name:='P_PAR';
end;



procedure Tfrmload_argo.QFMapping(argo_QF:integer; var QF:integer);
begin
  QF:=0;
   case argo_QF of
     0: QF:=0;
     1: QF:=4;
     2: QF:=2;
     3: QF:=1;
     4: QF:=1;
     5: QF:=4;
     8: QF:=3;
     9: QF:=1;
   end;
end;

end.

