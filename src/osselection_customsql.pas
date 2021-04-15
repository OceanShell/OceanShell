unit osselection_customsql;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Controls, StdCtrls, ComCtrls, IniFiles, DB, Dialogs, Classes;

type

  { Tfrmselection_customsql }

  Tfrmselection_customsql = class(TForm)
    btnDefaultQuery: TToolButton;
    btnSelect: TToolButton;
    Memo1: TMemo;
    rbCruises: TRadioButton;
    rbStations: TRadioButton;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    btnSaveAs: TToolButton;
    btnLoadFromFile: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;

    procedure btnLoadFromFileClick(Sender: TObject);
    procedure btnSaveAsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnDefaultQueryClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);

  private
    procedure SaveSettings;
  public
    { Public declarations }
  end;

var
  frmselection_customsql: Tfrmselection_customsql;

implementation

uses osmain, dm;

{$R *.lfm}

procedure Tfrmselection_customsql.FormShow(Sender: TObject);
Var
Ini:TIniFile;
begin
memo1.Clear;
Ini := TIniFile.Create(IniFileName);
 try
  Height := ini.ReadInteger('osselection_customsql', 'Height', 540);
  Width  := ini.ReadInteger('osselection_customsql', 'Width',  750);
 finally
   Ini.Free;
 end;

 if FileExists(GlobalUnloadPath+'temp.sql') then
  Memo1.Lines.LoadFromFile(GlobalUnloadPath+'temp.sql') else
  btnDefaultQuery.OnClick(self);
end;

procedure Tfrmselection_customsql.btnDefaultQueryClick(Sender: TObject);
begin
 Memo1.Clear;

 frmosmain.GetSQLQueryText;

 if rbCruises.Checked=true then begin
  with Memo1.Lines do begin
    Add(CruiseSQL);
    Add(' WHERE ');
    Add(' CRUISE.SOURCE_ID=SOURCE.ID AND ');
    Add(' CRUISE.PLATFORM_ID=PLATFORM.ID ');
    if trim(CRUISE_SQL_str)<>'' then
      Add(CRUISE_SQL_str);
   Add(' ORDER BY PLATFORM.NAME, CRUISE.DATE_START_TOTAL ' );
  end;
 end;

 if rbStations.Checked=true then begin
   with Memo1.Lines do begin
     Add(StationSQL);
     if trim(Station_SQL_str)<>'' then begin
      Add(' WHERE ');
      Add(Station_SQL_str);
     end;
    Add('ORDER BY DATEANDTIME ');
   end;
 end;
end;


procedure Tfrmselection_customsql.btnSelectClick(Sender: TObject);
begin
 try

  if rbCruises.Checked=true then begin
    with frmdm.QCruise do begin
      Close;
        SQL.Text:=Memo1.Lines.Text;
      Open;
      Last;
      First;
    end;

   if not frmdm.QCruise.IsEmpty then begin
    frmosmain.tsSelectedStations.Caption:=
       'Cruises: '+inttostr(frmdm.QCruise.RecordCount);
    frmosmain.PageControl1.ActivePageIndex:=2;
   end;
  end;

   if rbStations.Checked=true then begin
    with frmdm.Q do begin
      Close;
        SQL.Text:=Memo1.Lines.Text;
      Open;
      Last;
      First;
    end;
   frmosmain.SelectionInfo(true);
   frmosmain.CDSNavigation;
  end;


 except
   On e : EDatabaseError do begin
    if MessageDlg(e.message, mtError, [mbOK],0) = mrOk then exit;
   end;
 end;

 SaveSettings;

 Close;
end;

procedure Tfrmselection_customsql.SaveSettings;
Var
  outsql:text;
  k:integer;
begin
 AssignFile(outsql, GlobalUnloadPath+'temp.sql'); rewrite(outsql);
  for k:=0 to Memo1.Lines.Count-1 do
   writeln(outsql, Memo1.Lines.Strings[k]);
 CloseFile(outsql);
end;

procedure Tfrmselection_customsql.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  SaveSettings;
end;

procedure Tfrmselection_customsql.btnLoadFromFileClick(Sender: TObject);
begin
  frmosmain.OD.DefaultExt:='*.sql';
  frmosmain.SD.Filter:='SQL Query|*.SQL; *.sql; *.Sql';
  if frmosmain.OD.Execute then begin
   memo1.Lines.LoadFromFile(frmosmain.OD.FileName);
  end;
end;

procedure Tfrmselection_customsql.btnSaveAsClick(Sender: TObject);
begin
 frmosmain.SD.Filter:='SQL Query|*.SQL; *.sql; *.Sql';
 if frmosmain.SD.Execute then begin
  memo1.Lines.SaveToFile(frmosmain.SD.FileName);
 end;
end;

end.
