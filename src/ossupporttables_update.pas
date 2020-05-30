unit ossupporttables_update;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF WINDOWS}
  ComObj,
  {$ENDIF}
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, sqldb, Variants, lclintf;

type

  { Tfrmsupporttables_update }

  Tfrmsupporttables_update = class(TForm)
    btnCountryDuplicates: TButton;
    btnInstituteWOD: TButton;
    btnPIWOD: TButton;
    btnCruiseWOD: TButton;
    btnProjectWOD: TButton;
    btnPlatformICES: TButton;
    btnCountryWOD: TButton;
    btnPlatformDuplicates: TButton;
    btnPlatformWOD2013: TButton;
    Button1: TButton;
    btnCountryISO: TButton;
    btnCruiseGLODAP: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    chkShowLog: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    Label1: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    mLog: TMemo;
    PageControl1: TPageControl;
    rgDupCountry: TRadioGroup;
    rgDuplicates: TRadioGroup;
    Splitter1: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;

    procedure btnCountryDuplicatesClick(Sender: TObject);
    procedure btnCountryISOClick(Sender: TObject);
    procedure btnCruiseWODClick(Sender: TObject);
    procedure btnCruiseGLODAPClick(Sender: TObject);
    procedure btnPIWODClick(Sender: TObject);
    procedure btnInstituteWODClick(Sender: TObject);
    procedure btnProjectWODClick(Sender: TObject);
    procedure btnCountryWODClick(Sender: TObject);
    procedure btnPlatformICESClick(Sender: TObject);
    procedure btnPlatformDuplicatesClick(Sender: TObject);
    procedure btnPlatformWOD2013Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
  private

  public

  end;

var
  frmsupporttables_update: Tfrmsupporttables_update;

implementation

{$R *.lfm}

{ Tfrmsupporttables_update }

uses osmain, dm, ossupporttables, procedures;

(* ICES PLATFORM codes *)
procedure Tfrmsupporttables_update.Label12Click(Sender: TObject);
begin
  OpenURL('http://data.ices.dk/Reports/ShipC.aspx');
end;

(* WOD PLATFORM codes *)
procedure Tfrmsupporttables_update.Label8Click(Sender: TObject);
begin
  OpenURL('https://www.nodc.noaa.gov/General/NODC-Archive/platformlist.txt');
end;

(* Free ISO COUNTRY codes *)
procedure Tfrmsupporttables_update.Label7Click(Sender: TObject);
begin
  OpenURL('http://data.okfn.org/data/core/country-list');
end;

(* WOD COUNTRY codes *)
procedure Tfrmsupporttables_update.Label1Click(Sender: TObject);
begin
   OpenURL('https://www.nodc.noaa.gov/OC5/WOD/wod_codes.html');
end;


procedure Tfrmsupporttables_update.btnPlatformICESClick(Sender: TObject);
Var
k, absnum:integer;
XL: oleVariant;
XLTemplate:Variant;
RString, src, shipname:String;
TRt:TSQLTransaction;
Qt1, Qt2, Qt3:TSQLQuery;
begin
{$IFDEF WINDOWS}
 mLog.Clear;

 frmosmain.OD.Filter:='*.xls;*.xlsx|*.xls;*.xlsx';
 frmosmain.OD.InitialDir:=GlobalPath+'support\codes\';


if frmosmain.OD.Execute then begin

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

  Qt3 :=TSQLQuery.Create(self);
  Qt3.Database:=frmdm.IBDB;
  Qt3.Transaction:=TRt;

 XLTemplate:=frmosmain.OD.FileName;

 try
  XL := CreateOleObject('Excel.Application');
  XL.Visible := False;
  XL.DisplayAlerts := False;
 except
  Showmessage('MS Excel is not installed');
  Exit;
 end;

  XL.WorkBooks.Open(XLTemplate);

  src:='ICES_'+Vartostr(Xl.Cells[2, 5].Value);

 try
//  Enabled:=false; // отключаем форму
//  Q.DisableControls;
  btnPlatformICES.Enabled:=false;

  k:=4;
  repeat
   inc(k);

       RString:='';
       if VarToStr(Xl.Cells[k,  3].Value)<>'' then RString:=RString+'Title: '              +VarToStr(Xl.Cells[k,  3].Value)+#13 ;
      // if VarToStr(Xl.Cells[k,  5].Value)<>'' then RString:=RString+'Country: '            +VarToStr(Xl.Cells[k,  5].Value)+#13;
       //empty
       if VarToStr(Xl.Cells[k,  7].Value)<>'' then RString:=RString+'Platform class: '     +VarToStr(Xl.Cells[k,  7].Value)+#13;
       if VarToStr(Xl.Cells[k,  9].Value)<>'' then RString:=RString+'Commissioned: '       +VarToStr(Xl.Cells[k,  9].Value)+#13;
       if VarToStr(Xl.Cells[k, 10].Value)<>'' then RString:=RString+'Decomissioned: '      +VarToStr(Xl.Cells[k, 10].Value)+#13;
       if VarToStr(Xl.Cells[k, 11].Value)<>'' then RString:=RString+'Pennant: '            +VarToStr(Xl.Cells[k, 11].Value)+#13;
       if VarToStr(Xl.Cells[k, 13].Value)<>'' then RString:=RString+'Previous name: '      +VarToStr(Xl.Cells[k, 13].Value)+#13;
       if VarToStr(Xl.Cells[k, 14].Value)<>'' then RString:=RString+'Previous code: '      +VarToStr(Xl.Cells[k, 14].Value)+#13;
       if VarToStr(Xl.Cells[k, 15].Value)<>'' then RString:=RString+'Previous callsign: '  +VarToStr(Xl.Cells[k, 15].Value)+#13;
       if VarToStr(Xl.Cells[k, 16].Value)<>'' then RString:=RString+'Previous pennant: '   +VarToStr(Xl.Cells[k, 16].Value)+#13;
       if VarToStr(Xl.Cells[k, 12].Value)<>'' then
         if RString<>'' then RString:=RString+'-----------------'+#13+VarToStr(Xl.Cells[k, 12].Value) else
            RString:=VarToStr(Xl.Cells[k, 12].Value);

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, name from PLATFORM ');
     SQL.Add(' where nodc_ID=:code_nodc ');
     ParamByName('code_nodc').AsWideString:=VarToStr(Xl.Cells[k,  1].Value);
    Open;
   end;

    (*Вставляем новое судно *)
   if Qt1.IsEmpty=true then begin
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.ADD(' Select max(ID) as AbsnumMax from PLATFORM ');
      Open;
        Absnum:=Qt2.FieldByName('AbsnumMax').AsInteger+1;
      Close;
     end;

    try
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO PLATFORM ' );
       SQL.Add(' (ID, NODC_ID, NAME, IMO_ID, CALLSIGN,  NOTES_ICES, SOURCE) ');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ID, :NODC_ID, :NAME, :IMO_ID, :CALLSIGN, :NOTES_ICES, :SOURCE ');
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('NODC_CODE').asString:=UpperCase(VarToStr(Xl.Cells[k, 1].Value));
       ParamByName('NAME').AsString:=UpperCase(VarToStr(Xl.Cells[k, 2].Value));
       if trim(Xl.Cells[k, 4].Value)<>'' then
       ParamByName('IMO_CODE').AsInteger:=Xl.Cells[k, 4].Value else
       ParamByName('IMO_CODE').AsInteger:=-9;
       ParamByName('CALLSIGN').AsString:=VarToStr(Xl.Cells[k, 8].Value);
       ParamByName('Source').AsString:=src;
       ParamByName('NOTES_ICES').AsWideString:=RString; //Wide??
      ExecSQL;
      Close;
     end;
      Trt.CommitRetaining;
     except
      mLog.Lines.Add('Insert error: '+RString);
      TRt.RollbackRetaining;
     end;
    end;


   (* Обновляем существующую запись *)
   if Qt1.IsEmpty=false then begin

    Absnum  :=Qt1.FieldByName('ID').AsInteger;
    ShipName:=Qt1.FieldByName('Name').AsString;

    if ShipName<>trim(UpperCase(VarToStr(Xl.Cells[k,  2].Value))) then begin
     RString:='ICES name: '+VarToStr(Xl.Cells[k,  2].Value)+#13+RString;
     mLog.lines.add(uppercase(Xl.Cells[k,  2].Value));
    end;

   try
    with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Update PLATFORM set ');
       SQL.Add(' SOURCE=:Source, NOTES_ICES=:Notes ');
       SQL.Add(' where ID=:ID ' );
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('Source').AsString:=src;
       ParamByName('NOTES').AsWideString:=RString;
      ExecSQL;
      Close;
     end;
    TRt.CommitRetaining;
   except
    mLog.Lines.Add('Update error: '+VarToStr(Xl.Cells[k, 1].Value)+#13+RString);
    TRt.RollbackRetaining;
   end;

    (* IMO *)
    if VarToStr(Xl.Cells[k, 4].Value)<>'' then begin
    try
      with Qt3 do begin
       Close;
        SQL.Clear;
        SQL.Add(' Select IMO_CODE from PLATFORM ');
        SQL.Add(' where ID=:ID ' );
        ParamByName('ID').AsInteger:=absnum;
       Open;
        if Qt3.Fields[0].AsInteger<>-9 then begin
         with Qt2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' Update PLATFORM ');
           SQL.Add(' IMO_ID=:IMO ');
           SQL.Add(' where ID=:ID ' );
           ParamByName('ID').AsInteger:=absnum;
           ParamByName('IMO').AsInteger:=Xl.Cells[k, 4].Value;
          ExecSQL;
         end;
        end;
      Close;
     end;
    TRt.CommitRetaining;
   except
    mLog.Lines.Add('Update error IMO_CODE: '+Xl.Cells[k, 4].Value);
    TRt.RollbackRetaining;
   end;
  end;
   (* END of IMO *)

   (* CALLSIGN *)
    if VarToStr(Xl.Cells[k, 8].Value)<>'' then begin
     try
      with Qt3 do begin
       Close;
        SQL.Clear;
        SQL.Add(' Select CALLSIGN from PLATFORM ');
        SQL.Add(' where ID=:ID ' );
        ParamByName('ID').AsInteger:=absnum;
       Open;
        if VarIsNull(Qt3.Fields[0].AsVariant) then begin
         with Qt2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' Update PLATFORM set ');
           SQL.Add(' CALLSIGN=:CALLSIGN ');
           SQL.Add(' where ID=:ID ' );
           ParamByName('ID').AsInteger:=absnum;
           ParamByName('CALLSIGN').AsString:=Xl.Cells[k, 8].Value;
          ExecSQL;
         end;
        end;
      Close;
    end;
    TRt.CommitRetaining;
   except
    mLog.Lines.Add('Update error CALLSIGN: '+Xl.Cells[k, 8].Value);
    TRt.RollbackRetaining;
   end;
   end;
   (* END of CALLSIGN *)


     Qt1.Close;
  end;
  until trim(Xl.Cells[k, 1].Value)='';

  TRt.Commit;
 finally
  XL.Quit;
  XL:=UnAssigned;

//  Q.EnableControls;
  btnPlatformICES.Enabled:=true;
  Enabled:=true; // включаем форму
  Qt1.Free;
  Qt2.Free;
  Qt3.free;
  TrT.Free;
 end;
  Showmessage('Update finished. Stations processed: '+inttostr(k-5));
end; // if file is open   }
{$ENDIF}
end;


(* Update PLATFORM code from WOD *)
procedure Tfrmsupporttables_update.btnPlatformWOD2013Click(Sender: TObject);
var
dat: text;
PathToCodesSource, ShipName, buf_str:string;
c, k, code_ocl, imo, absnum, str_pos:integer;
notes, shipname0, ReportString, st,code_nodc:widestring;
TRt:TSQLTransaction;
Qt1, Qt2, Qt3:TSQLQuery;
begin
try
mLog.Clear;

 //Q.DisableControls;
 btnPlatformWOD2013.Enabled:=false;

 frmosmain.OD.Filter:='*.txt|*.txt';
 frmosmain.OD.InitialDir:=GlobalPath;
 if frmosmain.OD.Execute then PathToCodesSource:=frmosmain.OD.FileName else exit;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

  Qt3 :=TSQLQuery.Create(self);
  Qt3.Database:=frmdm.IBDB;
  Qt3.Transaction:=TRt;

 AssignFile(dat, PathToCodesSource); reset(dat);
 readln(dat,st);
 readln(dat,st);

   repeat
    readln(dat, st);
    if eof(dat) then exit;

    k:=0;
    for c:=1 to 3 do begin
     buf_str:='';
     repeat
      inc(k);
       if (st[k]<>',') and (st[k]<>'(') then buf_str:=buf_str+st[k];
     until (st[k]=',') or (st[k]='(') or (k=length(st));
     if c=1 then code_ocl:=StrToInt(trim(buf_str));
     if c=2 then code_nodc:=trim(buf_str);
     if c=3 then ShipName:=trim(buf_str);
    end;

    notes:='';
    if st[k]='(' then begin
      repeat
        inc(k);
        if st[k]<>')' then notes:=notes+st[k];
      until (k=length(st)) or (st[k]=')');
    end;

    ReportString:=inttostr(code_ocl)+#9+code_nodc+#9+ShipName+#9+notes;

    imo:=-9;
    str_pos:=pos('IMO', notes);
    if str_pos>0 then
     if TryStrToInt(copy(notes, str_pos+3, 7), imo)=true then
        imo:=strtoint(copy(notes, str_pos+3, 7))else
        mLog.Lines.Add(inttostr(code_ocl)+'   '+copy(notes, str_pos+3, 7));

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, source, nodc_ID, wod_id, name from PLATFORM ');
     SQL.Add(' where nodc_id=:code_nodc and wod_id=:code_ocl ');
     ParamByName('code_nodc').AsString:=code_nodc;
     ParamByName('code_ocl').AsInteger:=code_ocl;
    Open;
   end;

    (*Вставляем новое судно *)
   if Qt1.IsEmpty=true then begin
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.ADD(' Select max(ID) as AbsnumMax from PLATFORM ');
      Open;
        Absnum:=Qt2.FieldByName('AbsnumMax').AsInteger+1;
      Close;
     end;

    try
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO PLATFORM ' );
       SQL.Add(' (ID, NODC_ID, WOD_ID, IMO_ID, NAME, NOTES_WOD, SOURCE)');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ID, :NODC_ID, :OCL_ID, :IMO_ID, :NAME, :NOTES_WOD, :SOURCE)');
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('NODC_ID').AsString:=UpperCase(code_nodc);
       ParamByName('OCL_ID').AsInteger:=code_ocl;
       ParamByName('IMO_ID').AsInteger:=imo;
       ParamByName('Name').AsString:=UpperCase(ShipName);
       ParamByName('Source').AsString:='WOD';
       ParamByName('NOTES_WOD').AsWideString:=Notes; //Wide??
      ExecSQL;
      Close;
     end;
      Trt.CommitRetaining;
      if chkShowLog.Checked then mLog.Lines.add('Insert successful: '+ReportString);
     except
      mLog.Lines.add('Insert error: '+ReportString);
     end;
    end;


   (* Обновляем существующую запись *)
   if (Qt1.IsEmpty=false) then begin
     Absnum:=Qt1.Fields[0].AsInteger;
     shipname0:=Qt1.FieldByName('NAME').AsString;

   if shipname<>shipname0 then notes:=shipname+#13+notes;

   try
    with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Update PLATFORM set' );
       SQL.Add(' WOD_ID=:OCLSHIPCODE, NOTES_WOD=:Notes');
       SQL.Add(' where ID=:absnum ' );
       ParamByName('absnum').AsInteger:=absnum;
       ParamByName('OCLSHIPCODE').AsInteger:=code_ocl;
       ParamByName('NOTES').AsString:=Notes;
      ExecSQL;
     Close;
     end;
     TrT.CommitRetaining;
     if chkShowLog.Checked then mLog.Lines.add('Update successful: '+ReportString);
   except
    mLog.Lines.add('Update error: '+ReportString);
   end;

   (* IMO *)
    if imo<>-9 then begin
      with Qt3 do begin
       Close;
        SQL.Clear;
        SQL.Add(' Select IMO_ID from PLATFORM ');
        SQL.Add(' where ID=:absnum ' );
        ParamByName('absnum').AsInteger:=absnum;
       Open;
        if VarIsNull(Qt3.Fields[0].AsVariant) then begin
         with Qt2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' Update PLATFORM set ');
           SQL.Add(' IMO_ID=:IMO ');
           SQL.Add(' where ID=:absnum ' );
           ParamByName('absnum').AsInteger:=absnum;
           ParamByName('IMO').AsInteger:=imo;
          ExecSQL;
         end;
        end;
      Close;
    end;
   end;
   (* END of IMO *)

   end;
  until eof(dat);
  closefile(dat);

 finally
  btnPlatformWOD2013.Enabled:=true;
  Qt1.Free;
  Qt2.Free;
  Qt3.free;
  TrT.Free;

  frmsupporttables.PageControl1.OnChange(self);

  Showmessage(SDone);
 end;
end;

procedure Tfrmsupporttables_update.Button10Click(Sender: TObject);
begin

end;


(* Update PROJECT from WOD *)
procedure Tfrmsupporttables_update.btnProjectWODClick(Sender: TObject);
var
dat: text;
PathToCodesSource, buf_str, projectname, st:string;
c, k, absnum, code_wod:integer;
TRt:TSQLTransaction;
Qt1, Qt2:TSQLQuery;
begin
try
mLog.Clear;

 //Q.DisableControls;
 btnProjectWOD.Enabled:=false;

 frmosmain.OD.Filter:='s_2_project.txt|s_2_project.txt';
 frmosmain.OD.InitialDir:=GlobalPath;
 if frmosmain.OD.Execute then PathToCodesSource:=frmosmain.OD.FileName else exit;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.ADD(' Select max(ID) as AbsnumMax from PROJECT ');
    Open;
      Absnum:=Qt1.FieldByName('AbsnumMax').AsInteger;
    Close;
  end;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

 AssignFile(dat, PathToCodesSource); reset(dat);
 readln(dat,st);
 readln(dat,st);

   repeat
    readln(dat, st);
    if eof(dat) then exit;

    k:=0;
    for c:=1 to 2 do begin
     buf_str:='';
     repeat
      inc(k);
       if (st[k]<>',') then buf_str:=buf_str+st[k];
     until (st[k]=',') or (k=length(st));
     if c=1 then code_wod:=StrToInt(trim(buf_str));
     if c=2 then ProjectName:=trim(buf_str);
    end;

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, name from PROJECT ');
     SQL.Add(' where wod_id=:code_wod ');
     ParamByName('code_wod').AsInteger:=code_wod;
    Open;
   end;

    (*New project*)
   if Qt1.IsEmpty=true then begin
    inc(absnum);
    try
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO PROJECT ' );
       SQL.Add(' (ID, WOD_ID, NAME )');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ID, :WOD_ID, :NAME)');
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('WOD_ID').AsInteger:=code_wod;
       ParamByName('Name').AsString:=UpperCase(ProjectName);
      ExecSQL;
      Close;
     end;
      Trt.CommitRetaining;
      if chkShowLog.Checked then mLog.Lines.add('Insert successful: '+st);
     except
      mLog.Lines.add('Insert error: '+st);
     end;
    end;


   (* Обновляем существующую запись *)
   if (Qt1.IsEmpty=false) then begin
     Absnum:=Qt1.Fields[0].AsInteger;
   try
    with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Update PROJECT set' );
       SQL.Add(' NAME=:name ');
       SQL.Add(' where ID=:absnum ' );
       ParamByName('absnum').AsInteger:=absnum;
       ParamByName('name').AsString:=ProjectName;
      ExecSQL;
     Close;
     end;
     TrT.CommitRetaining;
     if chkShowLog.Checked then mLog.Lines.add('Update successful: '+st);
   except
    mLog.Lines.add('Update error: '+st);
   end;

   end;
  until eof(dat);
  closefile(dat);

 finally
  btnProjectWOD.Enabled:=true;
  Qt1.Free;
  Qt2.Free;
  TrT.Commit;
  TrT.Free;
  frmsupporttables.PageControl1.OnChange(self);
  Showmessage(SDone);
 end;
end;



(* Update INSTITUTE from WOD *)
procedure Tfrmsupporttables_update.btnInstituteWODClick(Sender: TObject);
var
dat: text;
PathToCodesSource, buf_str, institutename, st, code_nodc:string;
c, k, absnum, code_wod:integer;
TRt:TSQLTransaction;
Qt1, Qt2:TSQLQuery;
begin
try
mLog.Clear;

 //Q.DisableControls;
 btnInstituteWOD.Enabled:=false;

 frmosmain.OD.Filter:='s_4_institute.txt|s_4_institute.txt';
 frmosmain.OD.InitialDir:=GlobalPath;
 if frmosmain.OD.Execute then PathToCodesSource:=frmosmain.OD.FileName else exit;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.ADD(' Select max(ID) as AbsnumMax from INSTITUTE ');
    Open;
      Absnum:=Qt1.FieldByName('AbsnumMax').AsInteger;
    Close;
  end;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

 AssignFile(dat, PathToCodesSource); reset(dat);
 readln(dat,st);
 readln(dat,st);

   repeat
    readln(dat, st);
    if eof(dat) then exit;

    k:=0;
    for c:=1 to 3 do begin
     buf_str:='';
     repeat
      inc(k);
       if (st[k]<>',') then buf_str:=buf_str+st[k];
     until (st[k]=',') or (k=length(st));
     if c=1 then code_wod:=StrToInt(trim(buf_str));
     if c=2 then code_nodc:=trim(buf_str);
     if c=3 then InstituteName:=trim(buf_str);
    end;

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID from INSTITUTE ');
     SQL.Add(' where wod_id=:code_wod ');
     ParamByName('code_wod').AsInteger:=code_wod;
    Open;
   end;

    (*New project*)
   if Qt1.IsEmpty=true then begin
    inc(absnum);
    try
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO INSTITUTE ' );
       SQL.Add(' (ID, WOD_ID, NODC_ID, NAME )');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ID, :WOD_ID, :NODC_ID, :NAME)');
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('WOD_ID').AsInteger:=code_wod;
       ParamByName('NODC_ID').AsString:=code_nodc;
       ParamByName('Name').AsString:=UpperCase(InstituteName);
      ExecSQL;
      Close;
     end;
      Trt.CommitRetaining;
      if chkShowLog.Checked then mLog.Lines.add('Insert successful: '+st);
     except
      mLog.Lines.add('Insert error: '+st);
     end;
    end;


   (* Обновляем существующую запись *)
   if (Qt1.IsEmpty=false) then begin
     Absnum:=Qt1.Fields[0].AsInteger;
   try
    with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Update INSTITUTE set' );
       SQL.Add(' NODC_ID=:code_nodc, NAME=:name ');
       SQL.Add(' where ID=:absnum ' );
       ParamByName('absnum').AsInteger:=absnum;
       ParamByName('code_nodc').AsString:=code_nodc;
       ParamByName('name').AsString:=InstituteName;
      ExecSQL;
     Close;
     end;
     TrT.CommitRetaining;
     if chkShowLog.Checked then mLog.Lines.add('Update successful: '+st);
   except
    mLog.Lines.add('Update error: '+st);
   end;

   end;
  until eof(dat);
  closefile(dat);

 finally
  btnInstituteWOD.Enabled:=true;
  Qt1.Free;
  Qt2.Free;
  TrT.Commit;
  TrT.Free;
  frmsupporttables.PageControl1.OnChange(self);
  Showmessage(SDone);
 end;
end;



procedure Tfrmsupporttables_update.Button1Click(Sender: TObject);
Var
TRt:TSQLTransaction;
Qt1, Qt2:TSQLQuery;
name0, name1:string;
begin
mLog.Clear;

TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt1 :=TSQLQuery.Create(self);
Qt1.Database:=frmdm.IBDB;
Qt1.Transaction:=TRt;

Qt2 :=TSQLQuery.Create(self);
Qt2.Database:=frmdm.IBDB;
Qt2.Transaction:=TRt;

with Qt1 do begin
 Close;
  SQL.Clear;
  SQL.Add(' select ID, name from PLATFORM ');
 Open;
end;

qt1.first;
while not qt1.eof do begin
 name0:=Qt1.fieldbyname('name').asstring;
  if copy(name0, 1, 4)='USS ' then begin
   name1:=trim(copy(name0, 4, length(name0)));

   with qt2 do begin
    close;
     sql.clear;
     sql.add('update PLATFORM ');
     sql.add('set name=:name where id=:id');
     parambyname('id').AsInteger:=Qt1.FieldByName('id').asinteger;
     parambyname('name').AsString:=name1;
    execsql;
    close;
   end;
   trt.CommitRetaining;
   mLog.lines.add(name1);
  end;
 qt1.next;
end;
qt1.close;

trt.Commit;

qt1.free;
qt2.free;
trt.free;

showmessage('done');

end;


procedure Tfrmsupporttables_update.btnPlatformDuplicatesClick(Sender: TObject);
Var
VN, par:string;
Cnt: integer;
TRt:TSQLTransaction;
Qt:TSQLQuery;
begin
mLog.Clear;

TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt :=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=TRt;

 case rgDuplicates.ItemIndex of
  0: par:='shipname';
  1: par:='shipnameorig';
  2: par:='NODCshipcode';
  3: par:='OCLshipcode';
  4: par:='IMOshipcode';
  5: par:='callsign';
 end;

try

 with Qt do begin
  Close;
   SQL.Clear;
   SQL.Add(' select distinct('+par+'), count('+par+') ');
   SQL.Add(' from shipcode_list group by '+par);
  Open;
 end;

 while not Qt.eof  do begin
    VN :=Qt.Fields[0].AsString;
    Cnt:=Qt.Fields[1].AsInteger;
     if Cnt>1 then mLog.Lines.Add(VN+#9+inttostr(Cnt));
   Qt.next;
 end;
 Qt.Close;

 showmessage('Done!');
 finally
  Trt.Commit;
  Qt.Free;
  TrT.Free;
 end;
end;


procedure Tfrmsupporttables_update.btnCountryDuplicatesClick(Sender: TObject);
Var
VN, par:string;
Cnt: integer;
TRt:TSQLTransaction;
Qt:TSQLQuery;
begin
mLog.Clear;

TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt :=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=TRt;

 case rgDupCountry.ItemIndex of
  0: par:='countryname';
  1: par:='NODCcountrycode';
  2: par:='ISOcountrycode';
 end;

try
 with Qt do begin
  Close;
   SQL.Clear;
   SQL.Add(' select distinct('+par+'), count('+par+') ');
   SQL.Add(' from countrycode_list group by '+par);
  Open;
 end;

 while not Qt.eof  do begin
    VN :=Qt.Fields[0].AsString;
    Cnt:=Qt.Fields[1].AsInteger;
     if Cnt>1 then mLog.Lines.Add(VN+#9+inttostr(Cnt));
   Qt.next;
 end;
 Qt.Close;

 showmessage('Done!');
 finally
  Trt.Commit;
  Qt.Free;
  Trt.Free;
 end;
end;






procedure Tfrmsupporttables_update.btnCountryISOClick(Sender: TObject);
Var
  PathToCodes, st, stcountry, code, ReportString:string;
  absnum:integer;
begin
 mLog.Clear;

{ Main.OpenDialog1.Filter:='*.csv|*.csv';
 Main.OpenDialog1.InitialDir:=GlobalPath+'support\codes\';
 if Main.OpenDialog1.Execute then PathToCodes:=Main.OpenDialog1.FileName else exit;

 Main.ProgressBar1.Max:=LinesCount(PathToCodes)-1;
 Main.ProgressBar1.Position:=0;

 AssignFile(f_dat, PathToCodes); reset(f_dat);
 readln(f_dat, st);

   ODBDM.IBTransaction2.StartTransaction;
   repeat
    readln(f_dat, st);

    if copy(st, 1, 1)<>'"' then begin
      stcountry:=UpperCase(copy(st, 1, pos(',',st)-1));
      code:=copy(st, pos(',', st)+1, length(st));
    end;
    if copy(st, 1, 1)='"' then begin
     stcountry:=UpperCase(copy(st, 2, pos('",',st)-2));
     code:=copy(st, pos('",', st)+2, length(st));
    end;

   with ODBDM.ib2q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select absnum, countryname from countrycode_list ');
     SQL.Add(' where ISOcountrycode=:code ');
     ParamByName('code').AsString:=code;
    Open;
   end;

    (*Вставляем новое судно *)
   if ODBDM.ib2q1.IsEmpty=true then begin
     with ODBDM.ib2q2 do begin
      Close;
       SQL.Clear;
       SQL.ADD(' Select max(absnum) as AbsnumMax from countryCode_list ');
      Open;
        Absnum:=ODBDM.ib2q2.FieldByName('AbsnumMax').AsInteger+1;
      Close;
     end;

    try
     with ODBDM.ib2qq1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO countryCode_List ' );
       SQL.Add(' (ABSNUM, OCLCOUNTRYCODE, NODCCOUNTRYCODE, ISOCOUNTRYCODE, COUNTRYNAME)');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ABSNUM, :OCLCOUNTRYCODE, :NODCCOUNTRYCODE, :ISOCOUNTRYCODE, :COUNTRYNAME)');
       ParamByName('absnum').AsInteger:=absnum;
       ParamByName('NODCCOUNTRYCODE').AsString:='';
       ParamByName('OCLCOUNTRYCODE').AsInteger:=-9;
       ParamByName('ISOCOUNTRYCODE').AsString:=code;
       ParamByName('countryName').AsString:=stcountry;
      ExecQuery;
     end;
    except
     showmessage(st+#13+code+'   '+stcountry);
    end;
      ODBDM.ib2q1.Close;
      ODBDM.IBTransaction2.CommitRetaining;
    end;

   (* Обновляем существующую запись *)
   if (ODBDM.ib2q1.IsEmpty=false) then begin
     Absnum:=ODBDM.ib2q1.Fields[0].AsInteger;

   if (ODBDM.ib2q1.FieldByName('countryname').AsString<>stcountry) then begin
     mLog.lines.add(stcountry);
   { with ODBDM.ib2qq1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Update countryCode_List set' );
       SQL.Add(' COUNTRYNAME=:COUNTRYNAME ');
       SQL.Add(' where absnum=:absnum ' );
       ParamByName('absnum').AsInteger:=absnum;
       ParamByName('countryName').AsString:=UpperCase(stcountry);
      ExecQuery;
     end;  }
     ODBDM.ib2q1.Close;
     ODBDM.IBTransaction2.CommitRetaining;
   end;
   end;

   Main.ProgressBar1.Position:=Main.ProgressBar1.Position+1;
   Application.ProcessMessages;
  until eof(f_dat);
  closefile(f_dat);

  GetNODC;  }
end;



procedure Tfrmsupporttables_update.btnCruiseWODClick(Sender: TObject);
var
dat: text;
PathToCodesSource, buf_str, piname, st, code_nodc:string;
c, k, i, absnum, ID:integer;
wod_country:string;
wod_id, country_ID, wod_institute_id, wod_platform_id, stnum: integer;
platform_id, institute_id, project_id: integer;

cruise_ind, start_date, end_date, wmo_id: string;
mn, dd, yy: word;

fl1, fl2:boolean;

nodate:boolean;
date1, date2:TDateTime;

TRt:TSQLTransaction;
Qt1, Qt2, Qt3:TSQLQuery;
begin
try
mLog.Clear;

 btnCruiseWOD.Enabled:=false;

 frmosmain.OD.Filter:='allcruises_list.txt|allcruises_list.txt';
 if frmosmain.OD.Execute then PathToCodesSource:=frmosmain.OD.FileName else exit;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

  Qt3 :=TSQLQuery.Create(self);
  Qt3.Database:=frmdm.IBDB;
  Qt3.Transaction:=TRt;

 AssignFile(dat, PathToCodesSource); reset(dat);
 readln(dat, st);
// readln(dat, st);

 absnum:=0;
   repeat
    readln(dat, st);
    if eof(dat) then exit;

    k:=0;
    wmo_id:='';
    for c:=1 to 8 do begin
     buf_str:='';
     repeat
      inc(k);
       if (st[k]<>',') then buf_str:=buf_str+st[k];
     until (st[k]=',') or (k=length(st));
     if c=1 then cruise_ind:=trim(buf_str);
     if c=2 then if trim(buf_str)<>'' then wod_institute_ID:=StrToInt(trim(buf_str)) else wod_institute_ID:=-9;
     if c=3 then if trim(buf_str)<>'' then wod_platform_ID:=StrToInt(trim(buf_str)) else wod_platform_ID:=-9;
     if c=4 then
       if (trim(buf_str)<>'') and (trim(buf_str)<>'S') then stnum:=strtoint(trim(buf_str)) else stnum:=0;
     if c=6 then start_date:=trim(buf_str);
     if c=7 then end_date:=trim(buf_str);
     if c=8 then if trim(buf_str)<>'' then wmo_ID:=trim(buf_str);
    end;

    wod_country:=copy(cruise_ind, 1, 2);

    with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID from COUNTRY ');
     SQL.Add(' where iso3166_code=:code_wod ');
     ParamByName('code_wod').AsString:=wod_country;
    Open;
      if Qt1.IsEmpty=false then country_id:=Qt1.Fields[0].AsInteger else country_id:=99;
    Close;
   end;

    wod_id:=strtoint(copy(cruise_ind, 4, length(cruise_ind)));

    nodate:=false;
    for i:=1 to 2 do begin
     if i=1 then st:=start_date;
     if i=2 then st:=end_date;
       k:=0;
        for c:=1 to 3 do begin
         buf_str:='';
          repeat
           inc(k);
            if (st[k]<>'/') then buf_str:=buf_str+st[k];
          until (st[k]='/') or (k=length(st));
        if c=1 then mn:=StrToInt(trim(buf_str));
        if c=2 then dd:=StrToInt(trim(buf_str));
        if c=3 then yy:=StrToInt(trim(buf_str));
       end;
     if i=1 then date1:=DateEncode(yy, mn, dd, 0, 0, fl1, fl2);
     if i=2 then date2:=DateEncode(yy, mn, dd, 0, 0, fl1, fl2);
    end;

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID from CRUISE_WOD ');
     SQL.Add(' where wod_code=:code_wod ');
     ParamByName('code_wod').AsWideString:=cruise_ind;
    Open;
   end;

   if Qt1.IsEmpty=true then begin
    inc(absnum);

    with Qt3 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID from PLATFORM ');
     SQL.Add(' where WOD_ID=:code_wod ');
     ParamByName('code_wod').AsInteger:=wod_platform_id;
    Open;
      if Qt3.IsEmpty=false then platform_id:=Qt3.Fields[0].AsInteger else platform_id:=1;
    Close;
   end;

   with Qt3 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID from INSTITUTE ');
     SQL.Add(' where WOD_ID=:code_wod ');
     ParamByName('code_wod').AsInteger:=wod_institute_id;
    Open;
     if Qt3.IsEmpty=false then  institute_id:=Qt3.Fields[0].AsInteger else institute_id:=1;
    Close;
   end;


     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO CRUISE_WOD ' );
       SQL.Add(' (ID, PLATFORM_ID, DATE_START, DATE_END, STATIONS_AMOUNT, ');
       SQL.Add('  COUNTRY_ID, INSTITUTE_ID, WOD_CODE, WMO_CODE )');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ID, :PLATFORM_ID, :DATE_START, :DATE_END, :STATIONS_AMOUNT, ');
       SQL.Add('  :COUNTRY_ID, :INSTITUTE_ID, :WOD_CODE, :WMO_CODE )');
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('PLATFORM_ID').AsInteger:=platform_id;
       ParamByName('DATE_START').AsDate:=date1;
       ParamByName('DATE_END').AsDate:=date2;
       ParamByName('STATIONS_AMOUNT').AsInteger:=stnum;
       ParamByName('COUNTRY_ID').AsInteger:=country_id;
       ParamByName('INSTITUTE_ID').AsInteger:=institute_id;
       ParamByName('WOD_CODE').AsString:=cruise_ind;
       ParamByName('WMO_CODE').AsString:=wmo_id;
      ExecSQL;
      Close;
     end;
      Trt.CommitRetaining;
      if chkShowLog.Checked then mLog.Lines.add('Insert successful: '+st);
  {   except
       on E: Exception do begin
          mLog.Lines.add('Insert error: '+st);
       end;   }

    // end;

  {  mLog.Lines.Add(inttostr(absnum)+'   '+
                  inttostr(platform_id)+'   '+
                  datetostr(date1)+'   '+
                  datetostr(date2)+'   '+
                  inttostr(stnum)+'   '+
                  inttostr(country_id)+'   '+
                  inttostr(institute_id)+'   '+
                  cruise_ind+'   '+
                  wmo_id); }
  end;

  until eof(dat);
  closefile(dat);

 finally
  btnCRUISEWOD.Enabled:=true;
  Qt1.Free;
  Qt2.Free;
  TrT.Commit;
  TrT.Free;
  frmsupporttables.PageControl1.OnChange(self);
  Showmessage(SDone);
 end;
end;


procedure Tfrmsupporttables_update.btnCountryWODClick(Sender: TObject);
Var
  f_dat:text;
  PathToCodes, st, stcountry, code, ReportString:string;
  absnum:integer;

  TRt:TSQLTransaction;
  Qt1, Qt2:TSQLQuery;
begin
mLog.Clear;

 frmosmain.OD.Filter:='country_list.txt|country_list.txt';
 if frmosmain.OD.Execute then PathToCodes:=frmosmain.OD.FileName else exit;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

    with Qt1 do begin
      Close;
       SQL.Clear;
       SQL.ADD(' Select max(ID) as AbsnumMax from COUNTRY ');
      Open;
        Absnum:=Qt1.FieldByName('AbsnumMax').AsInteger+1;
      Close;
    end;


 AssignFile(f_dat, PathToCodes); reset(f_dat);


   repeat
    readln(f_dat, st);

    code:=copy(st, 1, 2);
    stcountry:=trim(copy(st, 4, 50));

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, NAME from COUNTRY ');
     SQL.Add(' where ISO_3166=:code ');
     ParamByName('code').AsString:=code;
    Open;
   end;

    (* insert missing country *)
   if Qt1.IsEmpty=true then begin
    inc(absnum);
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO COUNTRY ' );
       SQL.Add(' (ID, ISO_3166, NAME)');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ID, :ISO_3166, :NAME)');
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('ISO_3166').AsString:=code;
       ParamByName('Name').AsString:=stcountry;
      ExecSQL;
      Close;
     end;
     Trt.CommitRetaining;
    end;

   until eof(f_dat);
   TRt.Commit;
  Qt1.free;
  Qt2.free;
  TrT.Free;
end;


procedure Tfrmsupporttables_update.btnPIWODClick(Sender: TObject);
var
dat: text;
PathToCodesSource, buf_str, piname, st, code_nodc:string;
c, k, absnum, code_wod:integer;
TRt:TSQLTransaction;
Qt1, Qt2:TSQLQuery;
begin
try
mLog.Clear;

 btnPIWOD.Enabled:=false;

 frmosmain.OD.Filter:='primary_investigator_list.txt|primary_investigator_list.txt';
 if frmosmain.OD.Execute then PathToCodesSource:=frmosmain.OD.FileName else exit;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.ADD(' Select max(ID) as AbsnumMax from PI ');
    Open;
      Absnum:=Qt1.FieldByName('AbsnumMax').AsInteger;
    Close;
  end;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

 AssignFile(dat, PathToCodesSource); reset(dat);

   repeat
    readln(dat, st);
    if eof(dat) then exit;

    k:=0;
    for c:=1 to 2 do begin
     buf_str:='';
     repeat
      inc(k);
       if (st[k]<>',') then buf_str:=buf_str+st[k];
     until (st[k]=',') or (k=length(st));
     if c=1 then code_wod:=StrToInt(trim(buf_str));
     if c=2 then PIName:=trim(buf_str);
    end;

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID from PI ');
     SQL.Add(' where wod_id=:code_wod ');
     ParamByName('code_wod').AsInteger:=code_wod;
    Open;
   end;

    (*New project*)
   if Qt1.IsEmpty=true then begin
    inc(absnum);
    try
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO PI ' );
       SQL.Add(' (ID, WOD_ID, NAME )');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ID, :WOD_ID, :NAME)');
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('WOD_ID').AsInteger:=code_wod;
       ParamByName('Name').AsString:=UpperCase(PIName);
      ExecSQL;
      Close;
     end;
      Trt.CommitRetaining;
      if chkShowLog.Checked then mLog.Lines.add('Insert successful: '+st);
     except
      mLog.Lines.add('Insert error: '+st);
     end;
    end;


   (* Обновляем существующую запись *)
   if (Qt1.IsEmpty=false) then begin
     Absnum:=Qt1.Fields[0].AsInteger;
   try
    with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Update PI set' );
       SQL.Add(' NAME=:name ');
       SQL.Add(' where ID=:absnum ' );
       ParamByName('absnum').AsInteger:=absnum;
       ParamByName('name').AsString:=PIName;
      ExecSQL;
     Close;
     end;
     TrT.CommitRetaining;
     if chkShowLog.Checked then mLog.Lines.add('Update successful: '+st);
   except
    mLog.Lines.add('Update error: '+st);
   end;

   end;
  until eof(dat);
  closefile(dat);

 finally
  btnPIWOD.Enabled:=true;
  Qt1.Free;
  Qt2.Free;
  TrT.Commit;
  TrT.Free;
  frmsupporttables.PageControl1.OnChange(self);
  Showmessage(SDone);
 end;
end;



procedure Tfrmsupporttables_update.btnCruiseGLODAPClick(Sender: TObject);
var
dat: text;


PathToCodesSource, buf_str, piname, st, code_nodc:string;
c, k, i, absnum, ID:integer;
wod_country:string;
wod_id, country_ID, wod_institute_id, wod_platform_id, stnum: integer;
platform_id, institute_id, project_id: integer;

cruise_ind, start_date, end_date, wmo_id, date_str: string;
Glodap_ID, country_name, platform_name: string;
notes_str: widestring;

expocode, cr_alias, dates, platform, chiefSc, carbonPI, HydroPI, OxygenPI: widestring;
NutrientPI, CFCPI, OrganicsPI, IsotopesPI, OtherPI, source_id:widestring;
mn, dd, yy: word;

fl1, fl2:boolean;

XL: oleVariant;
XLTemplate:Variant;
date1, date2:TDateTime;

TRt:TSQLTransaction;
Qt1, Qt2, Qt3:TSQLQuery;
begin
{$IFDEF WINDOWS}
try
mLog.Clear;

 btnCruiseGLODAP.Enabled:=false;


 frmosmain.OD.Filter:='*.xls|*.xls';
 if frmosmain.OD.Execute then PathToCodesSource:=frmosmain.OD.FileName else exit;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

  Qt3 :=TSQLQuery.Create(self);
  Qt3.Database:=frmdm.IBDB;
  Qt3.Transaction:=TRt;


  XLTemplate:=frmosmain.OD.FileName;

  try
   XL := CreateOleObject('Excel.Application');
   XL.Visible := False;
   XL.DisplayAlerts := False;
  except
   Showmessage('MS Excel is not installed');
   Exit;
  end;

  XL.WorkBooks.Open(XLTemplate);

   k:=1;
   repeat
    inc(k);

    if vartostr(Xl.Cells[k, 1].Value)='' then exit;

    expocode:=''; cr_alias:=''; dates:=''; platform_name:=''; chiefsc:='';
    CarbonPI:=''; HydroPI:=''; OxygenPI:=''; NutrientPI:=''; CFCPI:='';
    OrganicsPI:=''; IsotopesPI:=''; OtherPI:='';

 {   showmessage(vartostr(Xl.Cells[k, 1].Value)+#13+
    vartostr(Xl.Cells[k, 2].Value)+#13+
    vartostr(Xl.Cells[k, 3].Value)+#13+
    vartostr(Xl.Cells[k, 4].Value)+#13+
    vartostr(Xl.Cells[k, 5].Value)+#13+
    vartostr(Xl.Cells[k, 6].Value)+#13+
    vartostr(Xl.Cells[k, 7].Value)+#13+
    vartostr(Xl.Cells[k, 8].Value)+#13+
    vartostr(Xl.Cells[k, 9].Value)+#13+
    vartostr(Xl.Cells[k, 10].Value)+#13+
    vartostr(Xl.Cells[k, 11].Value)+#13+
    vartostr(Xl.Cells[k, 12].Value)+#13+
    vartostr(Xl.Cells[k, 13].Value)+#13+
    vartostr(Xl.Cells[k, 14].Value));     }

     Glodap_ID:= vartostr(Xl.Cells[k, 1].Value);
     EXPOCODE:=  vartostr(Xl.Cells[k, 2].Value);
     Cr_Alias:=  vartostr(Xl.Cells[k, 3].Value);
     dates:=     vartostr(Xl.Cells[k, 4].Value);
     platform:=  vartostr(Xl.Cells[k, 5].Value);
     ChiefSc:=   vartostr(Xl.Cells[k, 6].Value);
     CarbonPI:=  vartostr(Xl.Cells[k, 7].Value);
     HydroPI:=   vartostr(Xl.Cells[k, 8].Value);
     OxygenPI:=  vartostr(Xl.Cells[k, 9].Value);
     NutrientPI:=vartostr(Xl.Cells[k, 10].Value);
     CFCPI:=     vartostr(Xl.Cells[k, 11].Value);
     OrganicsPI:=vartostr(Xl.Cells[k, 12].Value);
     IsotopesPI:=vartostr(Xl.Cells[k, 13].Value);
     OtherPI:=   vartostr(Xl.Cells[k, 14].Value);

    notes_str:='';
    if ChiefSc<>''    then notes_str:='Chief scientist: '+ChiefSc+LineEnding;
    if CarbonPI<>''   then notes_str:=notes_str+'Carbon PI: '+CarbonPI+LineEnding;
    if HydroPI<>''    then notes_str:=notes_str+'Hydro PI: '+HydroPI+LineEnding;
    if OxygenPI<>''   then notes_str:=notes_str+'Oxygen PI: '+OxygenPI+LineEnding;
    if NutrientPI<>'' then notes_str:=notes_str+'Nutrient PI: '+NutrientPI+LineEnding;
    if CFCPI<>''      then notes_str:=notes_str+'CFC PI: '+CFCPI+LineEnding;
    if OrganicsPI<>'' then notes_str:=notes_str+'Organics PI: '+OrganicsPI+LineEnding;
    if IsotopesPI<>'' then notes_str:=notes_str+'Isotopes PI: '+IsotopesPI;
    if OtherPI<>''    then notes_str:=notes_str+'Other PI: '+OtherPI;

  //   showmessage(notes_str);

  if (strtoint(Glodap_ID)<>396) and
     (strtoint(Glodap_ID)<=718) then begin
   date1:=DateEncode(StrToInt(copy(EXPOCODE, 5, 4)),
                     StrToInt(copy(EXPOCODE, 9, 2)),
                     StrToInt(copy(EXPOCODE, 11, 2)),
                     0, 0, fl1, fl2);

   date_str:=trim(copy(dates, Pos('-',dates)+1, length(dates)));

   i:=0;
   for c:=1 to 3 do begin
    buf_str:='';
      repeat
        inc(i);
            if (date_str[i]<>'/') then buf_str:=buf_str+date_str[i];
      until (date_str[i]='/') or (i=length(date_str));
        if c=1 then mn:=StrToInt(trim(buf_str));
        if c=2 then dd:=StrToInt(trim(buf_str));
        if c=3 then yy:=StrToInt(trim(buf_str));
   end;
   date2:=DateEncode(yy, mn, dd, 0, 0, fl1, fl2);
  end;

  if strtoint(Glodap_ID)=396 then begin
    date1:=DateEncode(1990, 01, 27, 0, 0, fl1, fl2);
    date2:=DateEncode(1995, 08, 01, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=719 then begin
    date1:=DateEncode(2005, 01, 01, 0, 0, fl1, fl2);
    date2:=DateEncode(2007, 12, 31, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=720 then begin
    date1:=DateEncode(1991, 08, 15, 0, 0, fl1, fl2);
    date2:=DateEncode(2006, 10, 02, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=721 then begin
    date1:=DateEncode(1991, 08, 08, 0, 0, fl1, fl2);
    date2:=DateEncode(2006, 02, 02, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=722 then begin
    date1:=DateEncode(1993, 04, 01, 0, 0, fl1, fl2);
    date2:=DateEncode(1995, 11, 30, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=723 then begin
    date1:=DateEncode(1997, 06, 01, 0, 0, fl1, fl2);
    date2:=DateEncode(1999, 09, 30, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=724 then begin
    date1:=DateEncode(2005, 01, 01, 0, 0, fl1, fl2);
    date2:=DateEncode(2009, 12, 31, 0, 0, fl1, fl2);
  end;

  if (strtoint(Glodap_ID)>=725) then begin
    yy:=StrToInt(copy(dates, 1, 4));
    mn:=StrToInt(copy(dates, 5, 2));
    dd:=StrToInt(copy(dates, 7, 2));

    date1:=DateEncode(yy, mn, dd, 0, 0, fl1, fl2);

    yy:=StrToInt(copy(dates, 12, 4));
    mn:=StrToInt(copy(dates, 16, 2));
    dd:=StrToInt(copy(dates, 18, 2));

    date2:=DateEncode(yy, mn, dd, 0, 0, fl1, fl2);
  end;

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID from CRUISE_GLODAP ');
     SQL.Add(' where id=:ID ');
     ParamByName('ID').AsString:=Glodap_ID;
    Open;
   end;

   if Qt1.IsEmpty=true then begin
   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, name from COUNTRY ');
     SQL.Add(' where NODC_ID=:ID ');
     ParamByName('ID').AsString:=copy(EXPOCODE, 1, 2);
    Open;
     if Qt1.IsEmpty=false then begin
       country_id:=Qt1.Fields[0].AsInteger;
       country_name:=Qt1.Fields[1].AsString;
     end else country_id:=488;   //UNKNOWN
    Close;
   end;

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, name from PLATFORM');
     SQL.Add(' where NODC_ID=:ID ');
     ParamByName('ID').AsString:=copy(EXPOCODE, 1, 4);
    Open;
     if Qt1.IsEmpty=false then begin
       platform_id:=Qt1.Fields[0].AsInteger;
       platform_name:=Qt1.Fields[1].AsString;
     end else platform_id:=19043;  //UNKNOWN PLATFORM
    Close;
   end;

    try
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO CRUISE_GLODAP ' );
       SQL.Add(' (ID, PLATFORM_ID, DATE_START, DATE_END, CRUISE_NUMBER, ');
       SQL.Add('  COUNTRY_ID, EXPOCODE, PI, NOTES, DATE_ADDED )');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ID, :PLATFORM_ID, :DATE_START, :DATE_END, :CRUISE_NUMBER, ');
       SQL.Add('  :COUNTRY_ID, :EXPOCODE, :PI, :NOTES, :DATE_ADDED )');
       ParamByName('ID').AsInteger:=strtoint(glodap_id);
       ParamByName('PLATFORM_ID').AsInteger:=platform_id;
       ParamByName('DATE_START').AsDate:=date1;
       ParamByName('DATE_END').AsDate:=date2;
       ParamByName('CRUISE_NUMBER').AsString:=Cr_alias;
       ParamByName('EXPOCODE').AsString:=EXPOCODE;
       ParamByName('PI').AsWideString:=UpperCase(ChiefSc);
       ParamByName('COUNTRY_ID').AsInteger:=country_id;
       ParamByName('Notes').AsWideString:=notes_str;
       ParamByName('DATE_ADDED').AsDateTime :=now;
      ExecSQL;
      Close;
     end;
      Trt.CommitRetaining;
      if chkShowLog.Checked then mLog.Lines.add('Insert successful: '+st);
     except
       on E: Exception do begin
         if MessageDlg(E.Message, mtWarning, [mbOk], 0)=mrOk then exit;
          mLog.Lines.add('Insert error: '+st);
       end;

     end;

    mLog.Lines.Add(Glodap_ID+'   '+
                  platform_name+'   '+
                  datetostr(date1)+'   '+
                  datetostr(date2)+'   '+
                  country_name+'   '+
                  expocode+'   '+
                  cr_alias);
   end;

  until vartostr(Xl.Cells[k, 1].Value)='';

 finally
  XL.Quit;
  XL:=UnAssigned;

  btnCRUISEWOD.Enabled:=true;
  Qt1.Free;
  Qt2.Free;
  TrT.Commit;
  TrT.Free;
  frmsupporttables.PageControl1.OnChange(self);
  Showmessage(SDone);
 end;
{$ENDIF}
end;

procedure Tfrmsupporttables_update.Button2Click(Sender: TObject);
Var
  dat:text;
  st, vesselname:string;
  TRt:TSQLTransaction;
  Qt1:TSQLQuery;
begin
try
mLog.Clear;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

 AssignFile(dat, 'X:\OceanShell_old\databases\ODB\AARI_vessels_combined.txt'); reset(dat);

 repeat
   readln(dat, st);
   vesselname:=copy(st, 1, pos(#9,st)-1);

    with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID from PLATFORM');
     SQL.Add(' where NAME=:VN ');
     ParamByName('VN').AsString:=vesselname;
    Open;
     if Qt1.IsEmpty=false then begin
       mlog.Lines.Add(vesselname+#9+inttostr(Qt1.Fields[0].AsInteger));
     end else
       mlog.Lines.Add(vesselname+#9+'-9');
    Close;
   end;

 until eof(dat);

finally
 TrT.Commit;
 Qt1.Free;
 Trt.Free;
end;
end;

procedure Tfrmsupporttables_update.Button3Click(Sender: TObject);
Var
  dat:text;
  st, vesselname:string;
  TRt:TSQLTransaction;
  Qt1:TSQLQuery;
  ID: integer;
begin
try
mLog.Clear;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

 AssignFile(dat, 'X:\OceanShell_old\databases\ODB\AARI_RAID.txt'); reset(dat);

 ID:=1;
 repeat
   readln(dat, st);
   inc(ID);

    with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' INSERT INTO PLATFORM ');
     SQL.Add(' (ID, NAME)');
     SQL.Add(' values ');
     SQL.Add(' (:ID, :NAME)');
     ParamByName('ID').AsInteger:=ID;
     ParamByName('NAME').AsString:=trim(ST);
    ExecSQL;
   end;

 until eof(dat);

finally
 TrT.Commit;
 Qt1.Free;
 Trt.Free;
end;
end;

procedure Tfrmsupporttables_update.Button4Click(Sender: TObject);
Var
  TRt:TSQLTransaction;
  Qt1, Qt2:TSQLQuery;
  ID: integer;
  cc:string;
  country_id:integer;
begin
try
mLog.Clear;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT id, NODC_CODE FROM PLATFORM ORDER BY ID ');
    Open;
   end;

   while not Qt1.EOF do begin
    id:=Qt1.Fields[0].AsInteger;
    cc:= copy(Qt1.Fields[1].AsString, 1, 2);

    if trim(cc)<>'' then begin

   with Qt2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT ID FROM COUNTRY WHERE NODC_CODE='+QuotedStr(cc));
    Open;
     if not Qt2.IsEmpty then country_id:=Qt2.Fields[0].AsInteger else country_id:=-9;
    Close;
   end;

   if country_id=-9 then begin
      with Qt2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT ID FROM COUNTRY WHERE ISO3166_CODE='+QuotedStr(cc));
    Open;
     if not Qt2.IsEmpty then country_id:=Qt2.Fields[0].AsInteger else country_id:=-9;
    Close;
   end;
   end;

  if country_id<>-9 then begin
    with Qt2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' UPDATE PLATFORM SET COUNTRY_ID='+inttostr(country_id)+' WHERE ID='+Inttostr(ID));
    ExecSQL;
   end;
  end;
 end;

   qt1.Next;
end;

finally
 TrT.Commit;
 Qt1.Free;
 Trt.Free;
end;
end;



procedure Tfrmsupporttables_update.Button5Click(Sender: TObject);
Var
  TRt:TSQLTransaction;
  Qt1, Qt2:TSQLQuery;
  name_full, name_short, name_long, name1, name2:string;
  ID:integer;
begin
try
mLog.Clear;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT ID, NAME_FULL FROM PROJECT ');
    Open;
   end;

   while not Qt1.eof do begin
    ID:=Qt1.Fields[0].asInteger;
    name_full:=Qt1.Fields[1].asString;

    name1:=copy(name_full, 1, pos('(', name_full)-1);
    name2:=copy(name_full, pos('(', name_full)+1, pos(')', name_full)-1);

    if (trim(name1)<>'') and (trim(name2)<>'') then begin
    name1:=stringReplace(name1,'(','',[]);
    name1:=stringReplace(name1,')','',[]);
    name2:=stringReplace(name2,'(','',[]);
    name2:=stringReplace(name2,')','',[]);

    if length(name1)>length(name2) then begin
     name_short:=name2;
     name_long:=name1;
    end else begin
     name_short:=name1;
     name_long:=name2;
    end;

    mlog.Lines.add(name_short+'   '+name_long);
    with Qt2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' UPDATE PROJECT SET ');
     SQL.Add(' NAME=:name_short, ');
     SQL.Add(' NAME_FULL=:name_long ');
     SQL.Add(' WHERE ID=:ID');
     ParamByName('ID').asinteger:=ID;
     ParamByName('name_short').asstring:=name_short;
     ParamByName('name_long').asstring:=name_long;
    ExecSQL;
   end;

    end;
    Qt1.Next;
   end;
finally
 TrT.Commit;
 Qt1.Free;
 Trt.Free;
end;

end;



end.

