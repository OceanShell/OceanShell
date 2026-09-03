unit ossupporttables_update;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF WINDOWS}
  ComObj,
  {$ENDIF}
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, sqldb, Variants, lclintf, BufDataset, DB;

type

  { Tfrmsupporttables_update }

  Tfrmsupporttables_update = class(TForm)
    btnCountryDuplicates: TButton;
    btnInstituteWOD: TButton;
    btnPIWOD: TButton;
    btnProjectWOD: TButton;
    btnPlatformICES: TButton;
    btnCountryWOD: TButton;
    btnPlatformDuplicates: TButton;
    btnPlatformWOD2013: TButton;
    btnCountryISO: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    btnNODC_WOD: TButton;
    Button8: TButton;
    GroupBox1: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    Label1: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
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
    procedure btnPIWODClick(Sender: TObject);
    procedure btnInstituteWODClick(Sender: TObject);
    procedure btnProjectWODClick(Sender: TObject);
    procedure btnCountryWODClick(Sender: TObject);
    procedure btnPlatformICESClick(Sender: TObject);
    procedure btnPlatformDuplicatesClick(Sender: TObject);
    procedure btnPlatformWOD2013Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure btnNODC_WODClick(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
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

uses osmain, dm, procedures;

(* ICES PLATFORM codes *)
procedure Tfrmsupporttables_update.Label12Click(Sender: TObject);
begin
  OpenURL('http://data.ices.dk/Reports/ShipC.aspx');
end;

(* WOD PLATFORM codes *)
procedure Tfrmsupporttables_update.Label8Click(Sender: TObject);
begin
  OpenURL('https://www.ncei.noaa.gov/data/oceans/woa/WOD/CODES/CSV/s_3_platform.csv');
end;

(* Free ISO COUNTRY codes *)
procedure Tfrmsupporttables_update.Label7Click(Sender: TObject);
begin
  OpenURL('http://data.okfn.org/data/core/country-list');
end;

(* WOD COUNTRY codes *)
procedure Tfrmsupporttables_update.Label1Click(Sender: TObject);
begin
   OpenURL('https://www.ncei.noaa.gov/data/oceans/woa/WOD/CODES/CSV/country_list.csv');
end;

procedure Tfrmsupporttables_update.Label2Click(Sender: TObject);
begin
  OpenURL('https://www.ncei.noaa.gov/data/oceans/woa/WOD/CODES/CSV/s_4_institute.csv');
end;

procedure Tfrmsupporttables_update.Label3Click(Sender: TObject);
begin
  OpenURL('https://www.ncei.noaa.gov/data/oceans/woa/WOD/CODES/CSV/s_2_project.csv');
end;


procedure Tfrmsupporttables_update.btnPlatformICESClick(Sender: TObject);
Var
k, absnum, Country_ID, cnt_ins, fl:integer;
XL: oleVariant;
XLTemplate:Variant;
RString, src, shipname, shiptitle:String;
TRt:TSQLTransaction;
Qt1, Qt2, Qt3:TSQLQuery;
dat, dat2: text;
NODC_CODE_arr: array [1..20000] of string;
NODC_CODE_cnt:integer;
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

  AssignFile(dat, GlobalUnloadPath+'ICES_update_name_mismatch.txt'); rewrite(dat);
  cnt_ins:=0;
  NODC_CODE_cnt:=0;
 try
//  Enabled:=false; // отключаем форму
//  Q.DisableControls;
  btnPlatformICES.Enabled:=false;

  k:=4;
  repeat
   inc(k);

   //NODC code must have 4 symbols
   if length(VarToStr(Xl.Cells[k,  1].Value))<>4 then Continue;

       RString:='';
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

   inc(NODC_CODE_cnt);
   NODC_CODE_arr[NODC_CODE_cnt]:=VarToStr(Xl.Cells[k,  1].Value);
   //mlog.Lines.add(NODC_CODE_arr[NODC_CODE_cnt]);


   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, NAME, TITLE from PLATFORM ');
     SQL.Add(' where NODC_CODE=:code_nodc and ID<10000000 ');
     ParamByName('code_nodc').AsWideString:=VarToStr(Xl.Cells[k,  1].Value);
    Open;
    Last;
    First;
   end;

   (*Вставляем новое судно *)
   if Qt1.IsEmpty=true then begin
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.ADD(' Select max(ID) as AbsnumMax from PLATFORM ');
       SQL.ADD(' where ID<10000000 ');
      Open;
        Absnum:=Qt2.FieldByName('AbsnumMax').AsInteger+1;
      Close;
     end;

     Country_ID:=0;
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM COUNTRY WHERE ' );
       SQL.Add(' NODC_CODE=:NODC_CODE ');
       ParamByName('NODC_CODE').asString:=Copy(UpperCase(VarToStr(Xl.Cells[k, 1].Value)), 1, 2);
      Open;
       Country_ID:=Qt2.Fields[0].AsInteger;
      Close;
     end;

     if Country_ID=0 then begin
      with Qt2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT ID FROM COUNTRY WHERE ' );
        SQL.Add(' ISO3166_CODE=:ISO3166_CODE ');
        ParamByName('ISO3166_CODE').asString:=Copy(UpperCase(VarToStr(Xl.Cells[k, 1].Value)), 1, 2);
       Open;
        Country_ID:=Qt2.Fields[0].AsInteger;
       Close;
      end;
     end;

     if Country_ID=0 then begin
      mLog.Lines.Add('Missing country '+Copy(UpperCase(VarToStr(Xl.Cells[k, 1].Value)), 1, 2));
      Continue;
     end;

    try
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO PLATFORM ' );
       SQL.Add(' (ID, NODC_CODE, TITLE, NAME, IMO_ID, COUNTRY_ID, CALLSIGN, NOTES_ICES) ');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ID, :NODC_CODE, :TITLE, :NAME, :IMO_ID, :COUNTRY_ID, :CALLSIGN, :NOTES_ICES)');
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('NODC_CODE').asString:=UpperCase(VarToStr(Xl.Cells[k, 1].Value));
       ParamByName('COUNTRY_ID').asInteger:=Country_ID;
       ParamByName('TITLE').AsString:=UpperCase(VarToStr(Xl.Cells[k, 3].Value));
       ParamByName('NAME').AsString:=UpperCase(VarToStr(Xl.Cells[k, 2].Value));
       if trim(Xl.Cells[k, 4].Value)<>'' then
       ParamByName('IMO_ID').AsInteger:=Xl.Cells[k, 4].Value else ParamByName('IMO_ID').Value:=null;
       ParamByName('CALLSIGN').AsString:=VarToStr(Xl.Cells[k, 8].Value);
       ParamByName('NOTES_ICES').AsWideString:=RString; //Wide??
       //showmessage(SQL.Text);
      ExecSQL;
      Close;
     end;

      mLog.lines.add('Inserted: '+uppercase(Xl.Cells[k,  2].Value));
      Trt.CommitRetaining;
      inc(cnt_ins);
     except
       on e: Exception do begin
        mLog.Lines.Add('Insert error: '+RString);
        TRt.RollbackRetaining;
        Showmessage(e.message);
     end;

     end;
    end;


   (* Обновляем существующую запись *)
   if (Qt1.IsEmpty=false) and (Qt1.RecordCount=1) then begin

    Absnum   :=Qt1.FieldByName('ID').AsInteger;
    ShipName :=Qt1.FieldByName('NAME').AsString;
    ShipTitle:=Qt1.FieldByName('TITLE').AsString;

    if ShipName<>trim(UpperCase(VarToStr(Xl.Cells[k,  2].Value))) then begin
     RString:='ICES name: '+VarToStr(Xl.Cells[k,  2].Value)+#13+RString;

       with Qt2 do begin
         Close;
          SQL.Clear;
          SQL.Add(' Update PLATFORM set ');
          SQL.Add(' NAME_ICES=:NAME, NOTES_ICES=:Notes ');
          SQL.Add(' where ID=:ID ' );
          ParamByName('ID').AsInteger:=absnum;
          ParamByName('NAME').AsString:=VarToStr(Xl.Cells[k,  2].Value);
          ParamByName('NOTES').AsWideString:=RString;
         ExecSQL;
         Close;
       end;
       TRt.CommitRetaining;

       writeln(dat, 'NODC: '+VarToStr(Xl.Cells[k,  1].Value)+'; '+
                  'DB: '+ShipName+' --> ICES: '+
                  uppercase(Xl.Cells[k,  2].Value));
    end;

    if ShipTitle<>trim(UpperCase(VarToStr(Xl.Cells[k,  3].Value))) then begin
     //showmessage(trim(UpperCase(VarToStr(Xl.Cells[k,  3].Value))));
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Update PLATFORM set ');
       SQL.Add(' TITLE=:title ');
       SQL.Add(' where ID=:ID ' );
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('title').AsString:=trim(UpperCase(VarToStr(Xl.Cells[k,  3].Value)));
      ExecSQL;
      Close;
     end;
    TRt.CommitRetaining;
   end;

    (* IMO *)
    if VarToStr(Xl.Cells[k, 4].Value)<>'' then begin
    try
      with Qt3 do begin
       Close;
        SQL.Clear;
        SQL.Add(' Select IMO_ID from PLATFORM ');
        SQL.Add(' where ID=:ID ' );
        ParamByName('ID').AsInteger:=absnum;
       Open;
        if Qt3.Fields[0].AsInteger<>-9 then begin
         with Qt2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' Update PLATFORM set ');
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
  end;

  if Qt1.RecordCount>1 then
    mLog.lines.add('NODC '+trim(Xl.Cells[k, 1].Value)+' has multiple entries');


  Qt1.Close;
  until trim(Xl.Cells[k, 1].Value)='';
  TRt.Commit;

  (* looking for codes NOT in the update file *)
  AssignFile(dat2, GlobalUnloadPath+'ICES_codes_not_in_source.txt'); rewrite(dat2);
   with Qt1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT(NODC_CODE) FROM PLATFORM ');
       SQL.Add(' WHERE NODC_CODE IS NOT NULL ');
       SQL.Add(' ORDER BY NODC_CODE ');
     Open;
   end;
   while not Qt1.EOF do begin
    fl:=0;
    for k:=1 to high(NODC_CODE_arr) do begin
     if Qt1.Fields[0].asString=NODC_CODE_arr[k] then begin
      fl:=1;
      break;
     end;
    end;
    if fl=0 then Writeln(dat2, Qt1.Fields[0].asString);

    Qt1.Next;
   end;
   Qt1.Close;
  CloseFile(dat2);

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
  Closefile(dat);
 end;
  Showmessage('Update finished. Platforms processed: '+inttostr(k-5)+'. '+
              'Platforms inserted: '+inttostr(cnt_ins));
end; // if file is open   }
{$ENDIF}
end;


(* Update PLATFORM code from WOD *)
procedure Tfrmsupporttables_update.btnNODC_WODClick(Sender: TObject);
var
  dat: text;
  PathToCodesSource, ShipName, ship_title:string;
  code_ocl, absnum, cnt_ins, Country_id, fl:integer;
  call_sign, st,code_nodc:widestring;
  TRt:TSQLTransaction;
  Qt1, Qt2:TSQLQuery;
begin

 try
  mLog.Clear;

 //Q.DisableControls;
 btnNODC_WOD.Enabled:=false;

 frmosmain.OD.Filter:='platformlist.txt|platformlist.txt';
 if frmosmain.OD.Execute then PathToCodesSource:=frmosmain.OD.FileName else exit;

 cnt_ins:=0;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

 AssignFile(dat, PathToCodesSource); reset(dat);
 repeat
   readln(dat,st);
 until copy(st,1,3)='  -';

  // WOD_ID_cnt:=0;
   repeat
    readln(dat, st);

    if copy(st,1,1)=' ' then Continue;

    code_nodc:=trim(copy(st,1,4));
    if trim(copy(st,6,7))<>'' then
      code_ocl :=StrToInt(trim(copy(st,6,7))) else code_ocl:=-9;
    call_sign:=trim(copy(st,13,8));
    Ship_title:=trim(copy(st,22,7));
    ShipName:=trim(copy(st,30,length(st)));

   if length(code_nodc)<>4 then Continue;

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, nodc_code, wod_id, name from PLATFORM ');
     SQL.Add(' where nodc_code=:nodc ');
     ParamByName('nodc').Value:=code_nodc;
    Open;
   end;

   if Qt1.IsEmpty=true then begin
       with Qt2 do begin
        Close;
         SQL.Clear;
         SQL.ADD(' Select max(ID) as AbsnumMax from PLATFORM ');
         SQL.ADD(' WHERE ID<10000000 ');
        Open;
          Absnum:=Qt2.FieldByName('AbsnumMax').AsInteger+1;
        Close;
       end;

       Country_ID:=0;
       with Qt2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' SELECT ID FROM COUNTRY WHERE ' );
         SQL.Add(' NODC_CODE=:NODC_CODE ');
         ParamByName('NODC_CODE').asString:=Copy(UpperCase(code_nodc), 1, 2);
        Open;
         Country_ID:=Qt2.Fields[0].AsInteger;
        Close;
       end;

       if Country_ID=0 then begin
        with Qt2 do begin
         Close;
          SQL.Clear;
          SQL.Add(' SELECT ID FROM COUNTRY WHERE ' );
          SQL.Add(' ISO3166_CODE=:ISO3166_CODE ');
          ParamByName('ISO3166_CODE').asString:=Copy(UpperCase(code_nodc), 1, 2);
         Open;
          Country_ID:=Qt2.Fields[0].AsInteger;
         Close;
        end;
       end;
      try
       with Qt2 do begin
        Close;
         SQL.Clear;
         SQL.Add(' INSERT INTO PLATFORM ' );
         SQL.Add(' (ID, NODC_CODE, WOD_ID, CALLSIGN, TITLE, NAME, COUNTRY_ID)');
         SQL.Add(' VALUES ' );
         SQL.Add(' (:ID, :NODC_CODE, :OCL_ID, :CALLSIGN, :TITLE, :NAME, :COUNTRY_ID)');
         ParamByName('ID').AsInteger:=absnum;
         ParamByName('NODC_CODE').AsString:=UpperCase(code_nodc);
         if call_sign<>'' then
           ParamByName('callsign').Value:=call_sign else
           ParamByName('callsign').Value:=null;

         if code_ocl<>-9 then
           ParamByName('OCL_ID').AsInteger:=code_ocl else
           ParamByName('OCL_ID').Value:=null;
         if Ship_Title<>'' then
           ParamByName('TITLE').AsString:=UpperCase(Ship_Title) else
           ParamByName('TITLE').Value:=null;
         ParamByName('Name').AsString:=UpperCase(ShipName);
         ParamByName('COUNTRY_ID').AsInteger:=Country_ID;
        ExecSQL;
        Close;
       end;
        Trt.CommitRetaining;
        mLog.Lines.add('Insert successful: '+code_nodc+'   '+ShipName);
         inc(cnt_ins);
      except
        TrT.RollbackRetaining;
        mLog.Lines.add('Insert error: '+code_nodc);
       end;
   end;

   if not Qt1.IsEmpty=true then begin
     if VarIsNull(Qt1.FieldByName('WOD_ID').Value) then begin
      if (code_ocl>-9) and (code_ocl<20000) then begin
         with Qt2 do begin
          Close;
           SQL.Clear;
           SQL.Add(' Update PLATFORM set' );
           SQL.Add(' WOD_ID=:code_ocl');
           SQL.Add(' where ID=:absnum ' );
           ParamByName('absnum').AsInteger:=Qt1.FieldByName('ID').AsInteger;
           ParamByName('code_ocl').AsInteger:=code_ocl;
          ExecSQL;
          Close;
         end;
         TrT.CommitRetaining;
      mlog.Lines.add('NODC_code: '+code_nodc+' WOD_ID updated with: '+inttostr(code_ocl));
      end;
     end;
   end;

   until eof(dat);
   closefile(dat);

 finally
  btnNODC_WOD.Enabled:=true;
  Qt1.Free;
  Qt2.Free;
  TrT.Free;

  Showmessage(SDone+' Insterted: '+inttostr(cnt_ins));
 end;
end;



procedure Tfrmsupporttables_update.btnPlatformWOD2013Click(Sender: TObject);
var
dat, dat1, dat2: text;
PathToCodesSource, ShipName, buf_str:string;
c, k, code_ocl, imo, absnum, str_pos, cnt_ins, Country_id, fl:integer;
notes, shipname0, ReportString, st,code_nodc, code_nodc0:widestring;
TRt:TSQLTransaction;
Qt1, Qt2, Qt3:TSQLQuery;
WOD_ID_arr: array [1..20000] of integer;
WOD_ID_cnt:integer;
begin

 try
  mLog.Clear;

 //Q.DisableControls;
 btnPlatformWOD2013.Enabled:=false;

 frmosmain.OD.Filter:='s_3_platform.csv|s_3_platform.csv';
 if frmosmain.OD.Execute then PathToCodesSource:=frmosmain.OD.FileName else exit;

 AssignFile(dat1, GlobalUnloadPath+'WOD_update_name_mismatch.txt'); rewrite(dat1);
 AssignFile(dat2, GlobalUnloadPath+'WOD_update_NODC_mismatch.txt'); rewrite(dat2);


 cnt_ins:=0;

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

   WOD_ID_cnt:=0;
   repeat
    readln(dat, st);
   // if eof(dat) then exit;

    k:=0;
    for c:=1 to 2 do begin
     buf_str:='';
     repeat
      inc(k);
       if (st[k]<>',') and (st[k]<>'(') then buf_str:=buf_str+st[k];
     until (st[k]=',') or (st[k]='(') or (k=length(st));
     if c=1 then code_ocl:=StrToInt(trim(buf_str));
     if c=2 then ShipName:=trim(buf_str);
    end;

    notes:='';
    if st[k]='(' then begin
      repeat
        inc(k);
        if st[k]<>')' then notes:=notes+st[k];
      until (k=length(st)) or (st[k]=')');
    end;

    ReportString:=inttostr(code_ocl)+#9+code_nodc+#9+ShipName+#9+notes;

    inc(WOD_ID_cnt);
    WOD_ID_arr[WOD_ID_cnt]:=code_ocl;

    imo:=-9;
    str_pos:=pos('IMO', notes);
    if str_pos>0 then
     if TryStrToInt(copy(notes, str_pos+3, 7), imo)=true then
        imo:=strtoint(copy(notes, str_pos+3, 7)) else
        mLog.Lines.Add(inttostr(code_ocl)+'   '+copy(notes, str_pos+3, 7));


   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, wod_id, name from PLATFORM ');
     SQL.Add(' where wod_id=:code_ocl ');
     ParamByName('code_ocl').AsInteger:=code_ocl;
    Open;
   end;

    (*Вставляем новое судно *)
   if Qt1.IsEmpty=true then begin
    { with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.ADD(' Select max(ID) as AbsnumMax from PLATFORM ');
       SQL.ADD(' WHERE ID<10000000 ');
      Open;
        Absnum:=Qt2.FieldByName('AbsnumMax').AsInteger+1;
      Close;
     end;

     Country_ID:=0;
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM COUNTRY WHERE ' );
       SQL.Add(' NODC_CODE=:NODC_CODE ');
       ParamByName('NODC_CODE').asString:=Copy(UpperCase(code_nodc), 1, 2);
      Open;
       Country_ID:=Qt2.Fields[0].AsInteger;
      Close;
     end;

     if Country_ID=0 then begin
      with Qt2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT ID FROM COUNTRY WHERE ' );
        SQL.Add(' ISO3166_CODE=:ISO3166_CODE ');
        ParamByName('ISO3166_CODE').asString:=Copy(UpperCase(code_nodc), 1, 2);
       Open;
        Country_ID:=Qt2.Fields[0].AsInteger;
       Close;
      end;
     end;


    try
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO PLATFORM ' );
       SQL.Add(' (ID, NODC_CODE, WOD_ID, IMO_ID, NAME, NOTES_WOD, COUNTRY_ID)');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ID, :NODC_CODE, :OCL_ID, :IMO_ID, :NAME, :NOTES_WOD, :COUNTRY_ID)');
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('NODC_CODE').AsString:=UpperCase(code_nodc);
       ParamByName('OCL_ID').AsInteger:=code_ocl;
       if imo=-9 then
        ParamByName('IMO_ID').Value:=null else
        ParamByName('IMO_ID').Value:=imo;
       ParamByName('Name').AsString:=UpperCase(ShipName);
       ParamByName('COUNTRY_ID').AsInteger:=Country_ID;
       ParamByName('NOTES_WOD').AsWideString:=Notes; //Wide??
      ExecSQL;
      Close;
     end;
      Trt.CommitRetaining;
      mLog.Lines.add('Insert successful: '+ReportString);
       inc(cnt_ins);
    except
      TrT.RollbackRetaining;
      mLog.Lines.add('Insert error: '+ReportString);
     end; }

    mLog.Lines.add('Insert successful: '+ReportString);
    end;


   (* Обновляем существующую запись *)
   if (Qt1.IsEmpty=false) then begin
     Absnum:=Qt1.Fields[0].AsInteger;
    // code_nodc0:=Qt1.FieldByName('NODC_CODE').AsString;
     shipname0:=Qt1.FieldByName('NAME').AsString;

   if ShipName<>shipname0 then begin
     writeln(dat1, 'OCL: '+inttostr(code_ocl)+'; '+'DB: '+
             ShipName0+' --> WOD: '+shipname);
     notes:='WOD name: '+shipname+#13+notes;
   end;

   if code_nodc<>code_nodc0 then begin
     writeln(dat2, 'DB: '+code_nodc0+' --> WOD: '+string(code_nodc));
   end;


   try
    with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Update PLATFORM set' );
       SQL.Add(' NOTES_WOD=:Notes');
       SQL.Add(' where ID=:absnum ' );
       ParamByName('absnum').AsInteger:=absnum;
       ParamByName('NOTES').AsString:=Notes;
      ExecSQL;
     Close;
     end;
     TrT.CommitRetaining;
   //  mLog.Lines.add('Update successful: '+ReportString);
   except
     TrT.RollbackRetaining;
    mLog.Lines.add('Update error: '+ReportString);
   end;

   (* IMO *)
  {  if imo<>-9 then begin
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
           ParamByName('IMO').Value:=imo;
          ExecSQL;
         end;
        end;
      Close;
    end;
   end;    }
   (* END of IMO *)
   end;

  until eof(dat);
  closefile(dat);
  closefile(dat1);
  closefile(dat2);

 // showmessage('here');

  (* looking for codes NOT in the update file *)
 { AssignFile(dat2, GlobalUnloadPath+'WOD_ID_not_in_source.txt'); rewrite(dat2);
   with Qt1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT DISTINCT(WOD_ID) FROM PLATFORM ');
       SQL.Add(' WHERE WOD_ID IS NOT NULL ');
       SQL.Add(' ORDER BY WOD_ID ');
     Open;
   end;
   while not Qt1.EOF do begin
    fl:=0;
    for k:=1 to high(WOD_ID_arr) do begin
     if Qt1.Fields[0].Value=WOD_ID_arr[k] then begin
      fl:=1;
      break;
     end;
    end;
    if fl=0 then Writeln(dat2, inttostr(Qt1.Fields[0].Value));

    Qt1.Next;
   end;
   Qt1.Close;
  CloseFile(dat2);  }


 finally
  btnPlatformWOD2013.Enabled:=true;
  Qt1.Free;
  Qt2.Free;
  Qt3.free;
  TrT.Free;

  Showmessage(SDone+' Insterted: '+inttostr(cnt_ins));
 end;
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

 frmosmain.OD.Filter:='s_2_project.csv|s_2_project.csv';
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

   if Qt1.IsEmpty=false then begin
    mLog.Lines.add('Exists: '+st);
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
      mLog.Lines.add('Insert successful: '+st);
     except
      mLog.Lines.add('Insert error: '+st);
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

 frmosmain.OD.Filter:='s_4_institute.csv|s_4_institute.csv';
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
    for c:=1 to 2 do begin
     buf_str:='';
     repeat
      inc(k);
       if (st[k]<>',') then buf_str:=buf_str+st[k];
     until (st[k]=',') or (k=length(st));
     if c=1 then code_wod:=StrToInt(trim(buf_str));
   //  if c=2 then code_nodc:=trim(buf_str);
     if c=2 then InstituteName:=trim(buf_str);
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
       SQL.Add(' (ID, WOD_ID, NAME )');
       SQL.Add(' VALUES ' );
       SQL.Add(' (:ID, :WOD_ID, :NAME)');
       ParamByName('ID').AsInteger:=absnum;
       ParamByName('WOD_ID').AsInteger:=code_wod;
    //   ParamByName('NODC_ID').AsString:=code_nodc;
       ParamByName('Name').AsString:=UpperCase(InstituteName);
      ExecSQL;
      Close;
     end;
      Trt.CommitRetaining;
      mLog.Lines.add('Insert successful: '+st);
     except
      mLog.Lines.add('Insert error: '+st);
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
  SQL.Add(' select ID, name from PLATFORM where ID<10000000 ');
 Open;
end;

qt1.first;
while not qt1.eof do begin
 name0:=trim(Qt1.fieldbyname('name').asstring);

 name1:='';
 if pos(' F/S', name0)>0 then name1:=trim(copy(name0, 1, pos(' F/S', name0)));

 if copy(name0, 1, 4)='USS '   then name1:=trim(copy(name0, 4, length(name0)));
 if copy(name0, 1, 6)='USCGC ' then name1:=trim(copy(name0, 6, length(name0)));
 if copy(name0, 1, 5)='USNS '  then name1:=trim(copy(name0, 5, length(name0)));
 if copy(name0, 1, 5)='USCG '  then name1:=trim(copy(name0, 5, length(name0)));
 if copy(name0, 1, 3)='SS '    then name1:=trim(copy(name0, 3, length(name0)));
 if copy(name0, 1, 5)='CCGC '  then name1:=trim(copy(name0, 5, length(name0)));
 if copy(name0, 1, 6)='USCGR ' then name1:=trim(copy(name0, 6, length(name0)));
 if copy(name0, 1, 4)='CSX '   then name1:=trim(copy(name0, 4, length(name0)));
 if copy(name0, 1, 5)='HMTS '  then name1:=trim(copy(name0, 5, length(name0)));

 if trim(name1)<>'' then begin
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
  0: par:='NAME';
  1: par:='NAME_NATIVE';
  2: par:='NODC_CODE';
  3: par:='WOD_ID';
  4: par:='IMO_ID';
  5: par:='CALLSIGN';
 end;

try

 with Qt do begin
  Close;
   SQL.Clear;
   SQL.Add(' select distinct('+par+'), count('+par+') ');
   SQL.Add(' from PLATFORM group by '+par);
  Open;
 end;

 while not Qt.eof  do begin
    VN :=Qt.Fields[0].AsString;
    Cnt:=Qt.Fields[1].AsInteger;
     if Cnt>1 then mLog.Lines.Add(VN+#9+inttostr(Cnt));
   Qt.next;
 end;
 Qt.Close;

// showmessage('Done!');
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
  0: par:='NAME';
  1: par:='NODC_CODE';
  2: par:='ISO3166_CODE';
 end;

try
 with Qt do begin
  Close;
   SQL.Clear;
   SQL.Add(' select distinct('+par+'), count('+par+') ');
   SQL.Add(' from country group by '+par);
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
     SQL.ADD(' Select max(ID) as AbsnumMax from PRINCIPAL_INVESTIGATOR ');
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
     SQL.Add(' select ID from PRINCIPAL_INVESTIGATOR ');
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
       SQL.Add(' INSERT INTO PRINCIPAL_INVESTIGATOR ' );
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
      mLog.Lines.add('Insert successful: '+st);
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
       SQL.Add(' Update PRINCIPAL_INVESTIGATOR set' );
       SQL.Add(' NAME=:name ');
       SQL.Add(' where ID=:absnum ' );
       ParamByName('absnum').AsInteger:=absnum;
       ParamByName('name').AsString:=PIName;
      ExecSQL;
     Close;
     end;
     TrT.CommitRetaining;
     mLog.Lines.add('Update successful: '+st);
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

  Showmessage(SDone);
 end;
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

procedure Tfrmsupporttables_update.Button8Click(Sender: TObject);
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
     SQL.Add(' SELECT ID, NODC_CODE FROM INSTITUTE ');
     SQL.Add(' WHERE NODC_CODE IS NOT NULL ');
     SQL.Add(' ORDER BY ID ');
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
     SQL.Add(' UPDATE INSTITUTE SET COUNTRY_ID='+inttostr(country_id)+' WHERE ID='+Inttostr(ID));
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

procedure Tfrmsupporttables_update.Button7Click(Sender: TObject);
var
dat, dat1, dat2: text;
PathToCodesSource, ShipName, buf_str:string;
c, k, code_ocl, imo, absnum, str_pos, cnt_ins, Country_id, fl:integer;
notes, shipname0, ReportString, st,code_nodc, code_nodc0:widestring;
TRt:TSQLTransaction;
Qt1, Qt2, Qt3:TSQLQuery;
WOD_ID_arr: array [1..20000] of integer;
WOD_ID_cnt:integer;
begin

 try
  mLog.Clear;

 //Q.DisableControls;
 btnPlatformWOD2013.Enabled:=false;

 frmosmain.OD.Filter:='*.csv|*.csv';
 if frmosmain.OD.Execute then PathToCodesSource:=frmosmain.OD.FileName else exit;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

  AssignFile(dat, PathToCodesSource); reset(dat);
  readln(dat,st);

   repeat
    readln(dat, st);

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

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, name_wod from PLATFORM ');
     SQL.Add(' where wod_id=:code_ocl ');
     ParamByName('code_ocl').AsInteger:=code_ocl;
    Open;
   end;


   Absnum:=Qt1.Fields[0].AsInteger;
   shipname0:=Qt1.FieldByName('NAME_WOD').AsString;

   if ShipName<>shipname0 then begin
    with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' Update PLATFORM set' );
       SQL.Add(' NAME_WOD=:Name_wod');
       SQL.Add(' where ID=:absnum ' );
       ParamByName('absnum').AsInteger:=absnum;
       ParamByName('NAME_WOD').AsString:=shipname;
      ExecSQL;
     Close;
     end;
     TrT.CommitRetaining;
   end;
  until eof(dat);
  closefile(dat);

 finally
  btnPlatformWOD2013.Enabled:=true;
  Qt1.Free;
  Qt2.Free;
  Qt3.free;
  TrT.Free;
 end;
end;



end.

