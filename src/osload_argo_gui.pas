unit osload_argo_gui;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SQLDB, DB,
  DateUtils, Variants, BufDataset, LCLIntf, Buttons, ExtCtrls, Spin, math,
  dynlibs, IniFiles,

  osqc_cruiseinfo, osload_argo;

type

  { Tfrmload_argo }

  Tfrmload_argo = class(TForm)
    btnSelectDataFolder: TButton;
    btnRun: TButton;
    cgTasks: TCheckGroup;
    chkFirstBuoy: TCheckBox;
    chkWrite: TCheckBox;
    ePath: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    mLog: TMemo;
    seFirstBuoy: TSpinEdit;

    procedure chkFirstBuoyChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnSelectDataFolderClick(Sender: TObject);

  private
    procedure UpdateCRUISE;
    procedure UpdateSTATION(fname:string; isCore: boolean; first_buoy:integer);
    procedure DeleteDuplicates;
    procedure UpdateStationParameters;
  public

  end;

var
  frmload_argo: Tfrmload_argo;

implementation

{$R *.lfm}

{ Tfrmload_argo }

uses osmain, dm, declarations_netcdf, GibbsSeaWater, procedures, driver_argo,
  driver_fdb;


procedure Tfrmload_argo.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
  k:integer;
begin

  Ini := TIniFile.Create(IniFileName);
   try
     ePath.Text := Ini.ReadString('ARGO', 'data_path',  '');
   finally
     Ini.Free;
   end;

  // all tasks checked
  for k:=0 to cgTasks.Items.Count-1 do cgTasks.Checked[k]:=false;

end;

procedure Tfrmload_argo.chkFirstBuoyChange(Sender: TObject);
begin
  seFirstBuoy.Enabled:=chkFirstBuoy.Checked;
end;


(* Running tasks one by one *)
procedure Tfrmload_argo.btnRunClick(Sender: TObject);
Var
  first_buoy:integer;
begin
 mLog.Clear;
 Application.ProcessMessages;

 if chkFirstBuoy.Checked then first_buoy:=seFirstBuoy.Value else first_buoy:=-9;

  if cgTasks.Checked[0] then UpdateCRUISE;
  if cgTasks.Checked[1] then UpdateSTATION('argo_synthetic-profile_index.txt', false, first_buoy);
  if cgTasks.Checked[2] then UpdateSTATION('ar_index_global_prof.txt', true, first_buoy);
  if cgTasks.Checked[3] then UpdateStationParameters;
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
     Ini.WriteString('ARGO', 'data_path', ePath.Text);
   finally
     Ini.Free;
   end;
end;


(* reading ar_index_global_meta.txt and updating CRUISE *)
procedure Tfrmload_argo.UpdateCRUISE;
Var
  cnt_kept, cnt_add, cnt_upd, cnt_del: integer;
  DateStart:TDateTime;
  log_path: string;
begin
if not FileExists(epath.text+'ar_index_global_meta.txt') then
  if MessageDlg(epath.text+'ar_index_global_meta.txt cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

  DateStart:=now;

   With mLog.lines do begin
     add('');
     add('Updating CRUISE');
     add('Start: '+datetimetostr(DateStart));
     add('')
   end;

   log_path:=GlobalUnloadPath+PathDelim+'log'+PathDelim;
    if not DirectoryExists(log_path) then CreateDir(log_path);

   cnt_kept:=0; cnt_add:=0; cnt_upd:=0; cnt_del:=0;
   ARGO_CRUISE(frmdm.IBDB, epath.Text, log_path, chkWrite.Checked, cnt_kept, cnt_add, cnt_upd, cnt_del);

   With mLog.lines do begin
     add('Kept: '+inttostr(cnt_kept));
     add('Added: '+inttostr(cnt_add));
     add('Updated: '+inttostr(cnt_upd));
     add('Removed: '+inttostr(cnt_del));
     add('');
     add('Done! '+datetimetostr(Now));
   end;

   OpenDocument(PChar(log_path));
end;


procedure Tfrmload_argo.UpdateSTATION(fname:string; isCore: boolean;
  first_buoy: integer);
Var
  DateStart: TDateTime;
  cnt_kept, cnt_updated, cnt_new, cnt_skipped: integer;
  md_file, log_path: string;
begin

 md_file := epath.text+fname;
 if not FileExists(md_file) then
   if MessageDlg(md_file+' cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

 log_path:=GlobalUnloadPath+PathDelim+'log'+PathDelim;
   if not DirectoryExists(log_path) then CreateDir(log_path);

  DateStart:=now;

  with mLog.Lines do begin
    add('');
    add('Updating STATION from: ');
    add( md_file);
    add('Start: '+datetimetostr(DateStart));
    add('');
  end;

  cnt_kept:=0; cnt_updated:=0; cnt_new:=0; cnt_skipped:=0;
  ARGO_STATION(frmdm.IBDB, md_file, log_path, chkWrite.Checked, isCore, first_buoy,
   cnt_kept,cnt_updated, cnt_new, cnt_skipped);

  with mLog.Lines do begin
    add('Unchanged: '+inttostr(cnt_kept));
    add('Updated: '  +inttostr(cnt_updated));
    add('Added: '    +inttostr(cnt_new));
    add('Skipped: '  +inttostr(cnt_skipped));
    add('');
    add('Done: '+DateTimeToStr(Now));
  end;

  OpenDocument(PChar(log_path));
end;



procedure Tfrmload_argo.UpdateStationParameters;
Var
TRt:TSQLTransaction;
Qt1, Qt2:TSQLQuery;

ID, tbl_id:int64;
k, c, i, cnt_dup:integer;
st, buf_id, file_path:string;
lst:TStringList;

n_prof, n_levels, n_params:size_t;
station_parameters_list:TStringList;

stdate_upd_f:TDateTime;
begin
TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt1 :=TSQLQuery.Create(self);
Qt1.Database:=frmdm.IBDB;
Qt1.Transaction:=TRt;

Qt2 :=TSQLQuery.Create(self);
Qt2.Database:=frmdm.IBDB;
Qt2.Transaction:=TRt;

with Qt2 do begin
  Close;
    SQL.Clear;
    SQL.Add(' INSERT INTO STATION_PARAMETERS ');
    SQL.Add(' (STATION_ID, TABLE_ID) ');
    SQL.Add(' VALUES ');
    SQL.Add(' (:STATION_ID, :TABLE_ID) ');
  Prepare;
end;

station_parameters_list:=TStringList.Create();

 try
   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select id, file_path from station ');
     SQL.Add(' where (id between 20000001 and 30000000) ');
     SQL.Add(' and (id not in (select distinct(station_id) from station_parameters)) ');
     SQL.Add(' order by id ');
    Open;
    Last;
    First;
   end;

   Caption:='Total stations: '+inttostr(Qt1.RecordCount);

   i:=0;
   while not Qt1.EOF do begin
    inc(i);
    ID:=Qt1.FieldByName('ID').Value;
    file_path:=Qt1.FieldByName('file_path').Value;
   // stdate_upd_f:=Qt1.FieldByName('date_updated').Value;

   //GetARGOParameters(file_path, station_parameters_list);

  { for k:=0 to station_parameters_list.Count-1 do
     showmessage(file_path+'   '+station_parameters_list.Strings[k]);  }

   if station_parameters_list.Count>0 then begin
    for c:=0 to high(ARGO_FDB_MAPPING) do begin
      tbl_id:=-1;
      for k:=0 to station_parameters_list.Count-1 do begin
        if station_parameters_list.Strings[k]=ARGO_FDB_MAPPING[c].NAME_ARGO then begin
          tbl_id:=ARGO_FDB_MAPPING[c].TBL_ID;
          if (tbl_id>0) then begin
            with Qt2 do begin
              ParamByName('STATION_ID'  ).Value:=ID;
              ParamByName('TABLE_ID'    ).Value:=tbl_id;
             ExecSQL;
            end;
          end;
          break;
        end;
      end;
     end;
    end else mLog.Lines.Add(inttostr(id)+'   '+file_path);

    if (i mod 10000=0) then begin
      label1.Caption:=inttostr(i);
      Application.ProcessMessages;
      TRt.CommitRetaining;
    end;

    Qt1.Next;
   end;

 finally
  Trt.Commit;
  Qt1.Free;
  Qt2.Free;
  Trt.Free;
  station_parameters_list.Free;
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


end.

