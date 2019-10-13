unit osmain;

{$mode objfpc}{$H+}

interface

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, Menus, Dialogs, ActnList, StdCtrls,  INIFiles,  ExtCtrls,
  DateUtils, sqldb, DB, SHFolder, LCLTranslator, Process;

type

  {$IFDEF CPU386}
    PtrUInt = DWORD;
    PtrInt = longint;
  {$ENDIF}
  {$IFDEF CPUX64}
    PtrUInt = QWORD;
    PtrInt = int64;
  {$ENDIF}

  { Tfrmosmain }

  Tfrmosmain = class(TForm)
    IL1: TImageList;
    iSettings: TMenuItem;
    iLoad: TMenuItem;
    iTools: TMenuItem;
    iLoad_ITP: TMenuItem;
    iMap: TMenuItem;
    MenuItem1: TMenuItem;
    iLoad_GLODAP_2019_v2_product: TMenuItem;
    iKnowledgeDBOpen: TMenuItem;
    MenuItem3: TMenuItem;
    iLoad_GLODAP_2019_v2: TMenuItem;
    MenuItem4: TMenuItem;
    OD: TOpenDialog;
    pnl2: TPanel;
    ProgressBar1: TProgressBar;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    IL2: TImageList;
    SD: TSaveDialog;
    Memo1: TMemo;
    MM1: TMainMenu;
    iFile: TMenuItem;
    iNewDatabase: TMenuItem;
    iOpenDatabase: TMenuItem;
    iHelp: TMenuItem;
    iHelpContent: TMenuItem;
    iAbout: TMenuItem;
    N3: TMenuItem;
    iExit: TMenuItem;
    StatusBar3: TStatusBar;
    ListBox1: TListBox;
    ListBox2: TListBox;

    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure iAboutClick(Sender: TObject);
    procedure iKnowledgeDBOpenClick(Sender: TObject);
    procedure iLoadARGOClick(Sender: TObject);
    procedure iLoadITPClick(Sender: TObject);
    procedure iLoad_GLODAP_2019_v2_productClick(Sender: TObject);
    procedure iSettingsClick(Sender: TObject);
    procedure iNewDatabaseClick(Sender: TObject);

    (*File*)
    procedure iOpenDatabaseClick(Sender: TObject);


  private

  public
    procedure OpenDatabase;
    procedure ItemsVisibility;
    procedure UpdateDBContent;
    procedure RunScript(ExeFlag:integer; cmd:string; Sender:TMemo);
  end;

  resourcestring
    SOpenFile = 'Open file?';
    SErrorOccured = 'Something went wrong. Check the output';

    SYes = 'Yes';
    SNo  = 'No';
    SDone = 'Done!';
    SDelete = 'Delete';

    SNoPython = 'Python is not found';
    SNoSurfer = 'Surfer is not found';
    SNoGrapher = 'Grapher is not found';
    SNoCDO = 'CDO is not found';
    SNoSupportDB = 'Suport database is not found';



var
  frmosmain: Tfrmosmain;

  IBName, IniFileName:string;
  GlobalPath, GlobalUnloadPath, GlobalSupportPath:string; //global paths for the app

  IBLatMin,IBLatMax,IBLonMin,IBLonMax:Real;
  IBYearMin,IBYearMax,IBMonthMin,IBMonthMax,IBDayMin,IBDayMax :Word;
  IBCount:Integer;
  IBDateMin,IBDateMax :TDateTime;

  NavigationOrder:boolean=true; //Stop navigation until all modules responded

  SLatP_arr:array[0..20000] of real;
  SLonP_arr:array[0..20000] of real;
  Length_arr:integer;

  frmcodes_open, frmcodesQC_open:boolean;


const
   NC_NOWRITE   = 0;    // file for reading
   NC_WRITE     = 1;    // file for writing
   NC_GLOBAL    = -1;   // global attributes ID
   NC_MAX_NAME  = 1024; // value from netcdf.h
   NC_UNLIMITED = 0;
   WS_EX_STATICEDGE = $20000;
   buf_len      = 3000;

implementation


uses dm, oscreatenewdb, settings, codes, osabout,
  //loading data
  osload_itp,
  osload_GLODAP_2019_v2_product
  //export
  //QC
  //tools
  ;

{$R *.lfm}


procedure Tfrmosmain.FormCreate(Sender: TObject);
begin
 StatusBar1.Panels[2].Style := psOwnerDraw;
 ProgressBar1.Parent:=StatusBar1;
end;

procedure Tfrmosmain.FormResize(Sender: TObject);
begin
 StatusBar1.Panels[1].Width:=Width-(statusbar1.Panels[0].Width+statusbar1.Panels[2].Width+75);
end;

procedure Tfrmosmain.FormShow(Sender: TObject);
Var
  Ini:TINIFile;
begin
IBName:='';

 (* Define Global Path *)
  GlobalPath:=ExtractFilePath(Application.ExeName);

  (* Define settings file, unique for every user*)
  IniFileName:=GetUserDir+'.climateshell';
  if not FileExists(IniFileName) then begin
    Ini:=TIniFile.Create(IniFileName);
    Ini.WriteInteger('main', 'Language', 0);
    Ini.Free;
  end;

 (* Check for existing program folders *)
{  if not DirectoryExists(GlobalPath+'unload\')              then CreateDir(GlobalPath+'unload\');
  if not DirectoryExists(GlobalPath+'unload\fields\')       then CreateDir(GlobalPath+'unload\fields\');
  if not DirectoryExists(GlobalPath+'unload\topography\')   then CreateDir(GlobalPath+'unload\topography\');
  if not DirectoryExists(GlobalPath+'unload\timeseries\')   then CreateDir(GlobalPath+'unload\timeseries\');
  if not DirectoryExists(GlobalPath+'unload\nctimeseries\') then CreateDir(GlobalPath+'unload\nctimeseries\');
  if not DirectoryExists(GlobalPath+'unload\nctldiagrams\') then CreateDir(GlobalPath+'unload\nctldiagrams\');
  if not DirectoryExists(GlobalPath+'unload\tsdiagram\')    then CreateDir(GlobalPath+'unload\tsdiagram\');
  if not DirectoryExists(GlobalPath+'unload\export\')       then CreateDir(GlobalPath+'unload\export\');
  if not DirectoryExists(GlobalPath+'unload\statistics\')   then CreateDir(GlobalPath+'unload\statistics\');
  if not DirectoryExists(GlobalPath+'unload\sections\')     then CreateDir(GlobalPath+'unload\sections\');
  }


 (* открываем ассоциированный файл (nc или ib) *)
  If ParamCount<>0 then begin
   if uppercase(ExtractFileExt(ParamStr(1)))='.IB' then begin
      IBName:=ParamStr(1);
      OpenDatabase;
   end;
  end;

 (* flags on open forms *)
  frmcodes_open:=false; frmcodesQC_open:=false;

SetFocus;
end;

procedure Tfrmosmain.iAboutClick(Sender: TObject);
begin
  if messagedlg(AboutProgram, mtInformation, [mbOk], 0)=mrOk then exit;
end;


procedure Tfrmosmain.iSettingsClick(Sender: TObject);
begin
 frmsettings := Tfrmsettings.Create(Self);
  try
   if not frmsettings.ShowModal = mrOk then exit;
  finally
    frmsettings.Free;
    frmsettings := nil;
  end;
end;


(* Open SupportTables.FDB *)
procedure Tfrmosmain.iKnowledgeDBOpenClick(Sender: TObject);
begin
 if frmcodes_open=true then frmcodes.SetFocus else
    begin
      frmcodes := Tfrmcodes.Create(Self);
      frmcodes.Show;
    end;
 frmcodes_open:=true;
end;



(**)
procedure Tfrmosmain.iOpenDatabaseClick(Sender: TObject);
begin
  OD.Filter:='Firebird Database|*.FDB;*.fdb';
  if OD.Execute then begin
   IBName:=OD.FileName;
   OpenDatabase;
  end;
end;


(* Open local database *)
procedure Tfrmosmain.OpenDatabase;
begin
   try
    frmdm.IBDB.DatabaseName:=IBName;
    frmdm.IBDB.Open;
   except
     on E: Exception do
       if MessageDlg(E.Message, mtWarning, [mbOk], 0)=mrOk then exit;
   end;
  UpdateDBContent;
end;


(* gathering info about the database *)
procedure Tfrmosmain.UpdateDBContent;
var
TRt:TSQLTransaction;
Qt:TSQLQuery;

k,i:integer;
tbl_arr:array[0..30] of string;
LocName:string;
begin
ListBox1.Clear;
ListBox2.Clear;

TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt :=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=TRt;

   with Qt do begin
    Close;
        SQL.Clear;
        SQL.Add(' select count(ID) as StCount, ');
        SQL.Add(' min(STLAT) as StLatMin, max(STLAT) as StLatMax, ');
        SQL.Add(' min(STLON) as StLonMin, max(STLON) as StLonMax, ');
        SQL.Add(' min(Extract(Year from STDATE)) as StYearMin, ');
        SQL.Add(' max(Extract(Year from STDATE)) as StYearMax, ');
        SQL.Add(' min(Extract(Month from STDATE)) as StMonthMin, ');
        SQL.Add(' max(Extract(Month from STDATE)) as StMonthMax, ');
        SQL.Add(' min(Extract(Day from STDATE)) as StDayMin, ');
        SQL.Add(' max(Extract(Day from STDATE)) as StDayMax ');
        SQL.Add(' from STATION');
       // showmessage(SQL.Text);
    Open;
      IBCount:=FieldByName('StCount').AsInteger;
       if IBCount>0 then begin
         IBLatMin  :=FieldByName('StLatMin').AsFloat;
         IBLatMax  :=FieldByName('StLatMax').AsFloat;
         IBLonMin  :=FieldByName('StLonMin').AsFloat;
         IBLonMax  :=FieldByName('StLonMax').AsFloat;
         IBYearMin :=FieldByName('StYearMin').AsInteger;
         IBYearMax :=FieldByName('StYearMax').AsInteger;
         IBMonthMin:=FieldByName('StMonthMin').AsInteger;
         IBMonthMax:=FieldByName('StMonthMax').AsInteger;
         IBDayMin  :=FieldByName('StDayMin').AsInteger;
         IBDayMax  :=FieldByName('StDayMax').AsInteger;
         IBDateMin :=EncodeDate(IBYearMin, IBMonthMin, IBDayMin);
         IBDateMax :=EncodeDate(IBYearMax, IBMonthMax, IBDayMax);

         StatusBar2.Panels[1].Text:='LtMin: '+floattostr(IBLatMin);
         StatusBar2.Panels[2].Text:='LtMax: '+floattostr(IBLatMax);
         StatusBar2.Panels[3].Text:='LnMin: '+floattostr(IBLonMin);
         StatusBar2.Panels[4].Text:='LnMax: '+floattostr(IBLonMax);
         StatusBar2.Panels[5].Text:='DateMin: '+datetostr(IBDateMin);
         StatusBar2.Panels[6].Text:='DateMax: '+datetostr(IBDateMax);
         StatusBar2.Panels[7].Text:='Stations: '+inttostr(IBCount);
      end else for k:=1 to 7 do frmosmain.statusbar2.Panels[k].Text:='---';
    Close;
   end;
  TRt.Commit;
  Qt.Free;
  TRt.free;
end;


procedure Tfrmosmain.ItemsVisibility;
Var
  Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
  try
   if Ini.ReadInteger( 'main', 'Language', 0)=0 then SetDefaultLang('en') else SetDefaultLang('ru');
  finally
   ini.Free;
  end;
end;


procedure Tfrmosmain.iNewDatabaseClick(Sender: TObject);
Var
ScriptPath:string;
begin
 SD.Filter:='Firebird database|*.FDB';
 SD.DefaultExt:='FDB';
 if SD.Execute then begin
    CreateNewDB(SD.FileName);
     frmdm.IBDB.Close;
     frmdm.IBDB.DatabaseName:=SD.FileName;
    IBName:=frmdm.IBDB.DatabaseName;
  OpenDatabase;
 end;
end;


procedure Tfrmosmain.iLoadARGOClick(Sender: TObject);
begin
 { frmloadargo := Tfrmloadargo.Create(Self);
   try
    if not frmloadargo.ShowModal = mrOk then exit;
   finally
     frmloadargo.Free;
     frmloadargo := nil;
   end; }
end;


procedure Tfrmosmain.iLoadITPClick(Sender: TObject);
begin
  frmLoadITP := TfrmLoadITP.Create(Self);
   try
    if not frmLoadITP.ShowModal = mrOk then exit;
   finally
     frmLoadITP.Free;
     frmLoadITP := nil;
   end;
end;

procedure Tfrmosmain.iLoad_GLODAP_2019_v2_productClick(Sender: TObject);
begin
    frmloadGLODAP_2019_v2_product := TfrmloadGLODAP_2019_v2_product.Create(Self);
   try
    if not frmloadGLODAP_2019_v2_product.ShowModal = mrOk then exit;
   finally
     frmloadGLODAP_2019_v2_product.Free;
     frmloadGLODAP_2019_v2_product := nil;
   end;
end;


(* Launching scripts *)
procedure Tfrmosmain.RunScript(ExeFlag:integer; cmd:string; Sender:TMemo);
Var
  Ini:TIniFile;
  P:TProcess;
  ExeName, buf, s: string;
  WaitOnExit:boolean;
  i, j: integer;
begin
(*
  ExeFlag = 0 /Random executable file
  ExeFlag = 1 /Python
  ExeFlag = 2 /Surfer
  ExeFlag = 3 /Grapher
  ExeFlag = 4 /CDO
  ExeFlag = 5 /NCO
*)

{$IFDEF WINDOWS}
  Ini := TIniFile.Create(IniFileName);
  try
    case ExeFlag of
     0: begin
        ExeName:='';
        WaitOnExit:=false;
     end;
     1: begin
        ExeName:=Ini.ReadString('main', 'PythonPath', '');
        WaitOnExit:=false;
        if not FileExists(ExeName) then
           if Messagedlg(SNoPython, mtwarning, [mbOk], 0)=mrOk then exit;
     end;
     2: begin
        ExeName:=Ini.ReadString('main', 'SurferPath',  '');
        WaitOnExit:=true;
        if not FileExists(ExeName) then
           if Messagedlg(SNoSurfer, mtwarning, [mbOk], 0)=mrOk then exit;
     end;
     3: begin
        ExeName:=Ini.ReadString('main', 'GrapherPath', '');
        WaitOnExit:=true;
        if not FileExists(ExeName) then
           if Messagedlg(SNoGrapher, mtwarning, [mbOk], 0)=mrOk then exit;
     end;
     4: begin
        ExeName:=GlobalSupportPath+'cdo'+PathDelim+'cdo.exe';
        WaitOnExit:=true;
        if not FileExists(ExeName) then
           if Messagedlg(SNoCDO,    mtwarning, [mbOk], 0)=mrOk then exit;
     end;
    end;
  finally
   ini.Free;
  end;
{$ENDIF}

{$IFDEF UNIX}
  Case ExeFlag of
    1: ExeName :='python3';
    4: ExeName :='cdo';
    5: ExeName :='nco';
  end;
{$ENDIF}

 try
  P:=TProcess.Create(Nil);
  P.Commandline:=trim(ExeName+' '+cmd);
//  showmessage(P.CommandLine);
  P.Options:=[poUsePipes, poNoConsole];
  if WaitOnExit=true then P.Options:=P.Options+[poWaitOnExit];
  P.Execute;

  repeat
   SetLength(buf, buf_len);
   SetLength(buf, p.output.Read(buf[1], length(buf))); //waits for the process output
   // cut the incoming stream to lines:
   s:=s + buf; //add to the accumulator
   repeat //detect the line breaks and cut.
     i:=Pos(#13, s);
     j:=Pos(#10, s);
     if i=0 then i:=j;
     if j=0 then j:=i;
     if j = 0 then Break; //there are no complete lines yet.
     if (Sender<> nil) then begin
       Sender.Lines.Add(Copy(s, 1, min(i, j) - 1)); //return the line without the CR/LF characters
       Application.ProcessMessages;
     end;
     s:=Copy(s, max(i, j) + 1, length(s) - max(i, j)); //remove the line from accumulator
   until false;
 until buf = '';
 if (s <> '') and (Sender<>nil) then begin
   Sender.Lines.Add(s);
   Application.ProcessMessages;
 end;
finally
 P.Free;
end;
end;


end.


