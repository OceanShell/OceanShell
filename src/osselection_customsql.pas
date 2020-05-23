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
    ToolBar2: TToolBar;
    ToolButton5: TToolButton;

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
  with memo1.Lines do begin
    Add('SELECT ');
    Add('STATION.ID, STATION.LATITUDE, STATION.LONGITUDE, ');
    Add('STATION.DATEANDTIME, STATION.BOTTOMDEPTH, STATION.LASTLEVEL_M, ');
    Add('STATION.LASTLEVEL_DBAR, STATION.CRUISE_ID, STATION.INSTRUMENT_ID, ');
    Add('STATION.ST_NUMBER_ORIGIN, STATION.ST_ID_ORIGIN, STATION.CAST_NUMBER, ');
    Add('STATION.QCFLAG, STATION.STVERSION, STATION.DUPLICATE, ');
    Add('STATION.MERGED, STATION.ACCESSION_NUMBER, STATION.DATE_ADDED, ');
    Add('STATION.DATE_UPDATED, PLATFORM.NAME as PLATF, ');
    Add('COUNTRY.NAME as CNTR, SOURCE.NAME as SRC ');
    Add('FROM STATION, CRUISE, PLATFORM, COUNTRY, SOURCE ');
    Add('WHERE ');
    Add('STATION.CRUISE_ID=CRUISE.ID AND ');
    Add('CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
    Add('CRUISE.COUNTRY_ID=COUNTRY.ID AND ');
    Add('CRUISE.SOURCE_ID=SOURCE.ID ');
  end;
end;


procedure Tfrmselection_customsql.btnSelectClick(Sender: TObject);
begin
 try
  frmdm.Q.Close;
  frmdm.Q.Sql.Text:=Memo1.Lines.Text;
  frmdm.Q.Open;
 except
   On e : EDatabaseError do begin
    if MessageDlg(e.message, mtError, [mbOK],0) = mrOk then exit;
   end;
 end;

 frmosmain.SelectionInfo;
 frmosmain.CDSNavigation;

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

end.
