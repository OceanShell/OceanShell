unit osprofile_station_single;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, DBGrids, ColorBox, IniFiles, SQLDB, DB, Grids, Menus, Types,
  TAGraph, TATools, TASeries, TATypes, TAChartAxisUtils,
//  TACustomSeries,  // for TChartSeries
  TAChartUtils,
  TAEnumerators;

type

  { Tfrmprofile_station_single }

  Tfrmprofile_station_single = class(TForm)
    btnAdd: TToolButton;
    btnCommit: TToolButton;
    btnDelete: TToolButton;
    Chart1: TChart;
    cbParameters: TComboBox;
    ChartToolset1: TChartToolset;
    ChartToolset1DataPointClickTool1: TDataPointClickTool;
    ChartToolset1DataPointHintTool1: TDataPointHintTool;
    ChartToolset1ZoomDragTool1: TZoomDragTool;
    ChartToolset1ZoomMouseWheelTool1: TZoomMouseWheelTool;
    DS: TDataSource;
    PM: TPopupMenu;
    Series1: TLineSeries;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    SetFlagAbove: TMenuItem;
    SetFlagBelow: TMenuItem;
    Splitter1: TSplitter;
    Qt: TSQLQuery;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton3: TToolButton;

    procedure btnAddClick(Sender: TObject);
    procedure btnCommitClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure cbParametersChange(Sender: TObject);
    procedure ChartToolset1DataPointClickTool1PointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SetFlagAboveClick(Sender: TObject);
    procedure SetFlagBelowClick(Sender: TObject);

  private

  public
    procedure ChangeID(ID:integer);
  end;

var
  frmprofile_station_single: Tfrmprofile_station_single;
  current_index: integer;

implementation

{$R *.lfm}

{ Tfrmprofile_station_single }

uses osmain, dm;

procedure Tfrmprofile_station_single.FormShow(Sender: TObject);
Var
Ini:TIniFile;
m, x, y, i, ind:integer;
begin
  Ini := TIniFile.Create(IniFileName);
  try
    Width :=Ini.ReadInteger( 'frmprofile_station_single', 'Width',  600);
    Height:=Ini.ReadInteger( 'frmprofile_station_single', 'Height', 600);
  finally
     Ini.Free;
  end;
cbParameters.Items:=frmosmain.ListBox1.Items;
current_index:=-1;

if CurrentParTable<>'' then
  cbParameters.ItemIndex:=cbParameters.Items.IndexOf(CurrentParTable) else
  cbParameters.ItemIndex:=0;

cbParameters.OnChange(self);
end;



procedure Tfrmprofile_station_single.cbParametersChange(Sender: TObject);
Var
  ID:integer;
begin
 ID:=frmdm.Q.FieldByName('ID').AsInteger;
  CurrentParTable:=cbParameters.Text;
 ChangeID(ID);
end;

procedure Tfrmprofile_station_single.btnAddClick(Sender: TObject);
begin
  Qt.Append;
end;

procedure Tfrmprofile_station_single.btnDeleteClick(Sender: TObject);
begin
  Qt.Delete;
end;

procedure Tfrmprofile_station_single.btnCommitClick(Sender: TObject);
Var
  ID:integer;
  Qtt:TSQLQuery;
  TRt:TSQLTransaction;
begin
  ID:=frmdm.Q.FieldByName('ID').AsInteger;

  try
   Qt.DisableControls;

     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qtt:=TSQLQuery.Create(self);
     Qtt.Database:=frmdm.IBDB;
     Qtt.Transaction:=TRt;

     try
       with Qtt do begin
         Close;
           Sql.Clear;
           SQL.Add(' DELETE FROM ');
           SQL.Add(CurrentParTable);
           SQL.Add(' WHERE ');
           SQL.Add(' ID=:ID ');
           ParamByName('ID').AsInteger:=ID;
         ExecSQL;
         Close;
        end;
     Trt.CommitRetaining;

     Qt.First;
     while not Qt.Eof do begin
      with Qtt do begin
       Close;
        Sql.Clear;
        SQL.Add('insert into');
        SQL.Add(CurrentParTable);
        SQL.Add(' (ID, lev_m, lev_dbar, val, pqf1, pqf2, sqf, bottle_number, units_id) ');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :lev_m, :lev_dbar, :val, :pqf1, :pqf2, :sqf, :bottle_number, :units_id) ');
        ParamByName('ID').Value:=Qt.FieldByName('ID').Value;
        ParamByName('LEV_M').Value:=Qt.FieldByName('LEV_M').Value;
        ParamByName('LEV_DBAR').Value:=Qt.FieldByName('LEV_DBAR').Value;
        ParamByName('VAL').Value:=Qt.FieldByName('VAL').Value;
        ParamByName('PQF1').Value:=Qt.FieldByName('PQF1').Value;
        ParamByName('PQF2').Value:=Qt.FieldByName('PQF2').Value;
        ParamByName('SQF').Value:=Qt.FieldByName('SQF').Value;
        ParamByName('BOTTLE_NUMBER').Value:=Qt.FieldByName('BOTTLE_NUMBER').Value;
        ParamByName('UNITS_ID').Value:=Qt.FieldByName('UNITS_ID').Value;
        //showmessage(SQL.Text);
       ExecSQL;
      end;
     Qt.Next;
   end;

   TRt.Commit;
   except
    On E :Exception do begin
     ShowMessage(E.Message);
     TRt.Rollback;
    end;
   end;

   finally
     Qtt.Free;
     Trt.Free;
     Qt.EnableControls;
   end;

   ChangeID(ID);
end;


procedure Tfrmprofile_station_single.ChangeID(ID:integer);
var
count, items_id, k, LNum:integer;
Avg, Sum, Dif2, ValX, SD, ValX_Sum:real;
lev, val, flag_, avg_lev, avg_val:real;
val_sum, lev_sum, lev_min, lev_max, val_min, val_max:real;
units, tbl, depth_units_str:string;

Ini: TIniFile;
Depth_units: integer;

TRt:TSQLTransaction;
Qtt:TSQLQuery;
begin

Series1.Clear;

Ini := TIniFile.Create(IniFileName);
try
  Depth_units:=Ini.ReadInteger ( 'main', 'Depth_units', 0);
finally
  ini.Free;
end;

if (CurrentParTable='') then CurrentParTable:=cbParameters.Items.Strings[0];

Caption:='Single parameter: '+inttostr(ID);
Items_id:=cbParameters.ItemIndex;

       with Qt do begin
         Close;
           Sql.Clear;
           SQL.Add(' SELECT * FROM ');
           SQL.Add( CurrentParTable);
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.ID=:ID ');
           SQL.Add(' order by LEV_DBAR, LEV_M');
           ParamByName('ID').AsInteger:=ID;
         Open;
        end;

  if Qt.IsEmpty=false then
   try
   Qt.DisableControls;
    Val_Sum:=0; Lev_sum:=0;
    Val_min:=10000; Val_max:=-9999;
    Lev_min:=10000; Lev_max:=-9999;

    Qt.First;
    while not Qt.eof do begin

      if Depth_units=0 then begin
       Lev:=Qt.FieldByName('LEV_M').AsFloat;
       depth_units_str:='Meter';
      end;
      if Depth_units=1 then begin
       Lev:=Qt.FieldByName('LEV_DBAR').AsFloat;
       depth_units_str:='dBar';
      end;

      Val:=Qt.FieldByName('VAL').AsFloat;
      Flag_:=Qt.FieldByName('PQF2').AsFloat;

      Val_sum:=Val_sum+Val;
      Lev_sum:=Lev_sum+Lev;

      if lev>lev_max then lev_max:=lev;
      if lev<lev_min then lev_min:=lev;
      if val>val_max then val_max:=val;
      if val<val_min then val_min:=val;

      Series1.AddXY(val,lev);

      Qt.Next;
    end;
    Count:=Qt.RecordCount;
    Avg_Val:=Val_sum/Qt.RecordCount;
    Avg_Lev:=Lev_sum/Qt.RecordCount;

   Qt.First; sum:=0;
    while not Qt.Eof do begin
     Val:=Qt.FieldByName('VAL').AsFloat;
     Dif2:=sqr(Val-Avg_Val);
    sum:=sum+Dif2;
    Qt.Next;
   end;
   Qt.First;

   try
     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qtt:=TSQLQuery.Create(self);
     Qtt.Database:=frmdm.IBDB;
     Qtt.Transaction:=TRt;

       with Qtt do begin
         Close;
           Sql.Clear;
           SQL.Add(' SELECT UNITS.NAME_SHORT FROM ');
           SQL.Add(CurrentParTable+ ', UNITS ');
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.UNITS_ID=UNITS.ID AND ');
           SQL.Add( CurrentParTable+'.ID=:ID ');
           ParamByName('ID').AsInteger:=ID;
         Open;
           Units:=Qtt.Fields[0].AsString;
         Close;
        end;
   finally
     Trt.Commit;
     Qtt.Free;
     Trt.Free;
   end;


   SD:=sqrt(sum/count);

   StatusBar1.Panels[1].Text:='Count= '+Inttostr(Count);
   StatusBar1.Panels[2].Text:='Min= '  +floattostr(Lev_Min);
   StatusBar1.Panels[3].Text:='Max= '  +floattostr(Lev_Max);
   StatusBar1.Panels[4].Text:='Avg= '  +floattostrF(Avg_Lev, fffixed,8,3);
   StatusBar1.Panels[5].Text:='Units= '+depth_units_str;

   StatusBar2.Panels[1].Text:='SD= '   +floattostrF(SD, fffixed,8,4);
   StatusBar2.Panels[2].Text:='Min= '  +floattostr(Val_Min);
   StatusBar2.Panels[3].Text:='Max= '  +floattostr(Val_Max);
   StatusBar2.Panels[4].Text:='Avg= '  +floattostrF(Avg_Val, fffixed,8,4);
   StatusBar2.Panels[5].Text:='Units= '+Units;
  finally
    Qt.EnableControls;
  end;

btnCommit.Enabled:=true;
Application.ProcessMessages;
end;


procedure Tfrmprofile_station_single.DBGrid1PrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
  if gdRowHighlight in AState then begin
    TDBGrid(sender).Canvas.Brush.Color := clNavy;
    TDBGrid(sender).Canvas.Font.Color:= clYellow;
    TDBGrid(sender).Canvas.Font.Style:=[fsBold];
  end;
end;

procedure Tfrmprofile_station_single.ChartToolset1DataPointClickTool1PointClick(
  ATool: TChartTool; APoint: TPoint);
Var
 k,pp: integer;
 tool: TDataPointClicktool;
 series: TLineSeries;
 pointer: TSeriesPointer;
begin
  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);
    if (tool.PointIndex<>-1) then begin
      if current_index<>-1 then
       series.SetColor(current_index, clDefault);
     series.SetColor(tool.PointIndex, clRed);
     Qt.Locate('Lev_m', series.YValue[tool.PointIndex], []);
     current_index:=tool.PointIndex;
    end;
  end;
end;


procedure Tfrmprofile_station_single.SetFlagBelowClick(Sender: TObject);
Var
  par:string;
  fl, cur_pos: integer;
begin
 Qt.DisableControls;
 cur_pos:=Qt.RecNo;
 try
  fl:=Qt.FieldByName('PQF2').AsInteger;
   while not Qt.Eof do begin
    Qt.Edit;
     Qt.FieldByName('PQF2').AsInteger:=fl;
     Qt.Post;
    Qt.Next;
   end;
 finally
   Qt.RecNo:=Cur_pos;
   Qt.EnableControls;
 end;
end;


procedure Tfrmprofile_station_single.SetFlagAboveClick(Sender: TObject);
Var
  par:string;
  fl, cur_pos: integer;
begin

 Qt.DisableControls;
 cur_pos:=Qt.RecNo;
 try
  fl:=Qt.FieldByName('PQF2').AsInteger;
    repeat
     Qt.Edit;
      Qt.FieldByName('PQF2').AsInteger:=fl;
      Qt.Post;
     Qt.Prior;
    until Qt.RecNo=1;
    Qt.First;
    Qt.Edit;
    Qt.FieldByName(par).AsFloat:=fl;
    Qt.Post;
 finally
   Qt.RecNo:=Cur_pos;
   Qt.EnableControls;
 end;

end;

procedure Tfrmprofile_station_single.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
Var
  Ini: TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger( 'frmprofile_station_single', 'Width',  Width);
    Ini.WriteInteger( 'frmprofile_station_single', 'Height', Height);
  finally
   Ini.Free;
  end;

  frmprofile_station_single_open:=false;
end;



end.

