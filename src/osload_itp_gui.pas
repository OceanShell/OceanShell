unit osload_itp_gui;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, DateUtils, SQLDB, dynlibs, IniFiles,

  osmain, dm, osload_itp, osqc_cruiseinfo;

type

  { TfrmLoadITP }

  TfrmLoadITP = class(TForm)
    btnOpenZIP: TButton;
    btnLoad: TButton;
    chkWrite: TCheckBox;
    eITPPath: TEdit;
    Label1: TLabel;
    folder_lst: TListBox;
    Memo1: TMemo;
    mLog: TMemo;

    procedure btnLoadClick(Sender: TObject);
    procedure btnOpenZIPClick(Sender: TObject);
    procedure eITPPathChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLoadITP: TfrmLoadITP;

implementation

{$R *.lfm}

procedure TfrmLoadITP.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
  try
    eITPPath.Text:=Ini.ReadString('load', 'ITP', GlobalPath+'data'+PathDelim);
  finally
    Ini.Free;
  end;
  eITPPath.OnChange(self);
end;


procedure TfrmLoadITP.btnLoadClick(Sender: TObject);
Var
  ff:integer;
  cruise_id:int64;
  StatOnly, isfinal:boolean;
  cnt_add, cnt_upd, cnt_del: integer;
  str, buoytype, FolderName, StVessel, isfinal_str:string;
  log:text;
begin
 mLog.Clear;
 Application.ProcessMessages;

 AssignFile(log, GlobalUnloadPath+'ITP_update.log'); rewrite(log);
 StatOnly := not chkWrite.Checked;

 For ff:=0 to folder_lst.Count-1 do begin
  FolderName:=folder_lst.Items.Strings[ff];

  //ITP or TOP
    buoytype:='';
    if copy(FolderName, 1, 3)='itp' then buoytype:='itp';
    if copy(FolderName, 1, 3)='top' then buoytype:='top';

    //Final?
    if Pos('final',FolderName)>0 then begin
      stvessel:=copy(FolderName, 4, Pos('final',FolderName)-4);
      isfinal:=true;
      isfinal_str:='final';
    end else begin
      stvessel:=copy(FolderName, 4, Pos('grddata',FolderName)-4);
      isfinal:=false;
      isfinal_str:='grddata';
    end;


  str:='Cruise '+buoytype+stVessel+' ('+isfinal_str+')';

  cnt_add:=0; cnt_upd:=0; cnt_del:=0;

  ITP(frmdm.IBDB, eITPpath.Text, FolderName,
      buoytype, stvessel, StatOnly, isfinal, log,
      cnt_add, cnt_upd, cnt_del, cruise_id);

  if (cnt_upd=0) and (cnt_add=0) and (cnt_del=0) then
    str:=str+' is up to date' else begin
      if (cnt_add>0) then str:=str+' added: '+inttostr(cnt_add);
      if (cnt_upd>0) then str:=str+' updated: '+inttostr(cnt_upd);
      if (cnt_del>0) then str:=str+' removed: '+inttostr(cnt_del);

      if not StatOnly then UpdateCruiseInfo(frmdm.IBDB, cruise_id);
    end;

  mLog.Lines.Add(str);
  Application.ProcessMessages;
 end;

// frmosmain.DatabaseInfo;
 CloseFile(log);
 Showmessage('Completed!');
end;

procedure TfrmLoadITP.btnOpenZIPClick(Sender: TObject);
begin
  frmosmain.ODir.InitialDir:=GlobalDataPath;
   if frmosmain.ODir.Execute then eITPPath.Text:=frmosmain.ODir.FileName+PathDelim;
  eITPPath.OnChange(self);
end;


procedure TfrmLoadITP.eITPPathChange(Sender: TObject);
Var
  fdb:TSearchRec;
begin
  if DirectoryExists(eITPPath.Text) then
     eITPPath.Font.Color:=clGreen else
     eITPPath.Font.Color:=clRed;

    btnLoad.Enabled:=DirectoryExists(eITPPath.Text);

    fdb.Name:='';
    folder_lst.Clear;
    if FindFirst(eITPpath.Text+PathDelim+'*',faAnyFile, fdb)=0 then
       Repeat
         if ((fdb.Attr and faDirectory)=faDirectory) and
             (length(fdb.Name)>2) then folder_lst.Items.Add(fdb.Name);
       Until FindNext(fdb)<>0;
    FindClose(fdb);
end;

procedure TfrmLoadITP.FormClose(Sender: TObject; var CloseAction: TCloseAction);
Var
  Ini:TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteString('load', 'ITP', eITPPath.Text);
  finally
    Ini.Free;
  end;
end;

end.
