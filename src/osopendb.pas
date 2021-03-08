unit osopendb;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, IniFiles, Menus, Dialogs, ComCtrls, ToolWin, ExtCtrls;


type

  { Tfrmopendb }

  Tfrmopendb = class(TForm)
    ListBox1: TListBox;
    PopupMenu1: TPopupMenu;
    btnAdd: TMenuItem;
    btnDelete: TMenuItem;

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure ListBox1DblClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure RefreshDBList;
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1MouseEnter(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmopendb: Tfrmopendb;

implementation

{$R *.lfm}

uses osmain, dm, osopendb_reg;


procedure Tfrmopendb.FormCreate(Sender: TObject);
var
  APoint: TPoint;
begin
  APoint.x := 0;
  APoint.y := 0;
  APoint := frmosmain.Panel1.ClientToScreen(APoint);

 { ShowMessage('Button X = ' + APoint.x.ToString +
    ', Y =' + APoint.y.ToString);  }

  Top:=APoint.y+frmosmain.Panel1.Height;
  Left:=frmosmain.Left;

  RefreshDBList;
end;

procedure Tfrmopendb.RefreshDBList;
Var
Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
 try
   if Ini.SectionExists('DB') then Ini.ReadSection('DB', ListBox1.Items);
  finally
   Ini.Free;
 end;
end;


procedure Tfrmopendb.ListBox1DblClick(Sender: TObject);
begin
  frmosmain.OpenRegisteredDatabase(ListBox1.Items.Strings[ListBox1.ItemIndex]);
end;


procedure Tfrmopendb.btnAddClick(Sender: TObject);
begin
if frmopendbreg_open=false then
   frmopendb_reg := Tfrmopendb_reg.Create(Self) else
   frmopendb_reg.SetFocus;
frmopendbreg_open:=true;

if ListBox1.ItemIndex<>-1 then
 frmopendb_reg.ShowDBSettings(ListBox1.Items.Strings[ListBox1.ItemIndex]);
end;

procedure Tfrmopendb.btnDeleteClick(Sender: TObject);
Var
  Ini, DBIni:TIniFile;
  Str:String;
begin
 if ListBox1.ItemIndex=-1 then exit;

 Ini := TIniFile.Create(IniFileName);
 try
  Ini.DeleteKey('DB', ListBox1.Items.Strings[ListBox1.ItemIndex]);
 finally
  Ini.Free;
 end;

 DBIni := TIniFile.Create(IniFileName+'_db');
 try
  DBIni.EraseSection(ListBox1.Items.Strings[ListBox1.ItemIndex]);
 finally
  DBIni.Free;
 end;

ListBox1.DeleteSelected;
end;

procedure Tfrmopendb.ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  left_tab = 6;
  top_tab = 26;
begin
  ListBox1.ItemIndex := ListBox1.ItemAtPos(Point(x, y), true);
  if Button = mbRight then
  PopupMenu1.Popup(x + ListBox1.Left + Left + left_tab, y + ListBox1.Top + Top + top_tab)
end;

procedure Tfrmopendb.ListBox1MouseEnter(Sender: TObject);
begin
  if ListBox1.Count=0 then  btnAdd.OnClick(self);
end;

procedure Tfrmopendb.ListBox1Click(Sender: TObject);
begin
if frmopendbreg_open=true then
  if ListBox1.ItemIndex<>-1 then
    frmopendb_reg.ShowDBSettings(ListBox1.Items.Strings[ListBox1.ItemIndex]);
end;

procedure Tfrmopendb.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  frmopendb_open:=false;
end;


end.
