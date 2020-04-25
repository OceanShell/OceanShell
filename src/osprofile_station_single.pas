unit osprofile_station_single;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, DBGrids, ColorBox, IniFiles, SQLDB, DB, Grids, Types,
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
    btnSetFlag: TToolButton;
    Chart1: TChart;
    cbParameters: TComboBox;
    ChartToolset1: TChartToolset;
    ChartToolset1DataPointClickTool1: TDataPointClickTool;
    ChartToolset1DataPointHintTool1: TDataPointHintTool;
    ChartToolset1ZoomDragTool1: TZoomDragTool;
    ChartToolset1ZoomMouseWheelTool1: TZoomMouseWheelTool;
    DS: TDataSource;
    Series1: TLineSeries;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Qt: TSQLQuery;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;

    procedure cbParametersChange(Sender: TObject);
    procedure ChartToolset1DataPointClickTool1PointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);

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
m, x, y, i:integer;
begin
  Ini := TIniFile.Create(IniFileName);
  try
   (* form position *)
    Width :=Ini.ReadInteger( 'frmprofile_station_single', 'Width',  600);
    Height:=Ini.ReadInteger( 'frmprofile_station_single', 'Height', 600);

  //  if Ini.ReadBool('SinglePar', 'StayOnTop', false)= true then
   //    FormStyle:=fsStayOnTop else FormStyle:=fsNormal;
  finally
     Ini.Free;
  end;
cbParameters.Items:=frmosmain.ListBox1.Items;
current_index:=-1;
end;

procedure Tfrmprofile_station_single.cbParametersChange(Sender: TObject);
Var
  ID:integer;
begin
 ID:=frmdm.Q.FieldByName('ID').AsInteger;
  CurrentParTable:=cbParameters.Text;
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
begin

Series1.Clear;

Ini := TIniFile.Create(IniFileName);
try
  Depth_units:=Ini.ReadInteger ( 'main', 'Depth_units', 0);
finally
  ini.Free;
end;


if (CurrentParTable='') then CurrentParTable:=cbParameters.Items.Strings[0];

Caption:=CurrentParTable;
Items_id:=cbParameters.ItemIndex;


 { cbParameters.Clear;
  for k:=0 to frmosmain.ListBox1.Items.Count-1 do begin
   tbl:=frmosmain.ListBox1.Items.Strings[k];
   with Qt do begin
    Close;
      Sql.Clear;
      SQL.Add(' select 1 from ');
      SQL.Add( tbl );
      SQL.Add(' where ID=:ID ');
      ParamByName('ID').AsInteger:=ID;
    Open;
       if Qt.IsEmpty=false then cbParameters.Items.Add(tbl);
    Close;
   end;
  end;
  cbParameters.ItemIndex:=Items_id;  }

       with Qt do begin
         Close;
           Sql.Clear;
           SQL.Add(' SELECT ');
           SQL.Add( CurrentParTable+'.LEV_DBAR, '+CurrentParTable+'.LEV_M, ');
           SQL.Add( CurrentParTable+'.VAL, '+CurrentParTable+'.PQF2, ');
           SQL.Add(' UNITS.NAME_SHORT ');
           SQL.Add(' FROM ');
           SQL.Add( CurrentParTable+', UNITS ');
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.UNITS_ID=UNITS.ID AND ');
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
      Units   :=Qt.FieldByName('NAME_SHORT').AsString;

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

DBGrid1.DataSource:=DS;

//btnDeleteProfile.Enabled:=true;
btnCommit.Enabled:=true;
//series2.Clear;

//ComboBoxEx1.Text:=copy(CurrentParTable,3,length(CurrentParTable));

//DBChart1.RefreshData;
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

