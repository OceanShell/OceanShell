unit osprofile_plot_all;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, IniFiles,
  SQLDB, Variants, Types,
  TAGraph, TATools, TASeries, TATypes,
  TACustomSeries,  // for TChartSeries
  TAChartUtils,    // for nptCustom
  TAEnumerators;   // for CustomSeries(Chart) ;

type

  { Tfrmprofile_plot_all }

  Tfrmprofile_plot_all = class(TForm)
    Chart1: TChart;
    ChartToolset1: TChartToolset;
    DPH: TDataPointHintTool;
    DPC: TDataPointClickTool;
    ZD: TZoomDragTool;
    ZMW: TZoomMouseWheelTool;
    ToolBar1: TToolBar;
    btnPrior: TToolButton;
    btnNext: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;


    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPriorClick(Sender: TObject);
    procedure DPCPointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure DPHAfterMouseMove(ATool: TChartTool; APoint: TPoint);

  private
    function AddLineSeries (AChart: TChart; ATitle: String;
      AColor:TColor; sName:string):TLineSeries;
    function AddPointSeries(AChart: TChart; ATitle: String;
      AColor:TColor; sName:string):TLineSeries;
    procedure HighlightSeries(ASeries: TBasicChartSeries);
    procedure SelectProfile(sname:string);
  public
    procedure AddToPlot(ID:integer; ToUpdate:boolean);
    procedure ChangeID(ID:integer);
   // procedure UpdateProfile(ID:integer);
  end;

var
  frmprofile_plot_all: Tfrmprofile_plot_all;
  mik, depth_units:integer;
  flag_st:string;


implementation

{$R *.lfm}

{ Tfrmprofile_plot_all }

uses osmain, dm, osparameters_list;


function Tfrmprofile_plot_all.AddLineSeries(AChart: TChart;
  ATitle: String; AColor:TColor; sName:string): TLineSeries;
begin
 Result := TLineSeries.Create(AChart.Owner);
  with TLineSeries(Result) do begin
    Title := ATitle;
    ShowPoints := false;
    ShowLines := true;
    LinePen.Style := psSolid;
    SeriesColor := AColor;
    Name := sName;
    ToolTargets := [nptPoint, nptYList, nptCustom];
  end;
 AChart.AddSeries(Result);
end;


function Tfrmprofile_plot_all.AddPointSeries(AChart: TChart;
  ATitle: String; AColor:TColor; sName:string): TLineSeries;
begin
 Result := TLineSeries.Create(AChart.Owner);
  with TLineSeries(Result) do begin
    Title := ATitle;
    ShowPoints := true;
    Pointer.Brush.Color := AColor;
    Pointer.Pen.Color := clBlack;
    Pointer.Style := psCircle;
    ShowLines := false;
    Name := sName;
  end;
 AChart.AddSeries(Result);
end;


procedure Tfrmprofile_plot_all.FormShow(Sender: TObject);
var
ID, CurrentID, k:integer;
Ini:TInifile;
LeftAxisTitle :string;
begin
 Ini := TIniFile.Create(IniFileName);
  try
    Top   :=Ini.ReadInteger( 'osprofile_plot_all', 'Top',  100);
    Left  :=Ini.ReadInteger( 'osprofile_plot_all', 'Left', 100);
    Width :=Ini.ReadInteger( 'osprofile_plot_all', 'Width',  600);
    Height:=Ini.ReadInteger( 'osprofile_plot_all', 'Height', 600);

    Depth_units:=Ini.ReadInteger ( 'osmain', 'depth_units', 0);

    flag_st:='';
    for k:=0 to 8 do
      if Ini.ReadBool('osparameters_list', 'QCF'+inttostr(k), true) then
         flag_st:=flag_st+','+inttostr(k);

  finally
   Ini.Free;
  end;

  flag_st:=copy(flag_st, 2, length(flag_st));
  if trim(flag_st)='' then
   if MessageDlg('Select at least one QF', mtWarning, [mbOk], 0)=mrOk then exit;


    mik:=-1;
     try
      CurrentID:=frmdm.Q.FieldByName('ID').AsInteger;
      frmdm.Q.DisableControls;
      frmdm.Q.First;
        While not frmdm.Q.Eof do begin
         ID:=frmdm.Q.FieldByName('ID').AsInteger;
           AddToPlot(ID, false);
         frmdm.Q.Next;
        end;
      finally
        frmdm.Q.Locate('ID',CurrentID,[]);
        frmdm.Q.EnableControls;
      end;

    if depth_units=0 then LeftAxisTitle:='Depth, [m]' else LeftAxisTitle:='Depth, [dBar]';

    Chart1.AxisList.LeftAxis.Title.Caption:=LeftAxisTitle;
    ChangeID(CurrentID);

  Caption:=CurrentParTable+', '+inttostr(Chart1.SeriesCount-1)+' profiles';
  Application.ProcessMessages;
end;


procedure Tfrmprofile_plot_all.ChangeID(ID:integer);
begin
 SelectProfile('s'+inttostr(ID));
end;


procedure Tfrmprofile_plot_all.AddToPlot(ID:integer; ToUpdate:boolean);
Var
k, flag:integer;
lev, val:real;
sName:TComponentName;
lev_m, lev_d:Variant;

TRt:TSQLTransaction;
Qt:TSQLQuery;
begin
TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt:=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=TRt;

sName:='s'+inttostr(ID);

try
 with Qt do begin
  Close;
   SQL.Clear;
   SQL.Add(' select LEV_DBAR, LEV_M, VAL, PQF2 from ');
   SQL.Add( CurrentParTable );
   SQL.Add(' where ID=:ID AND PQF2 in ('+flag_st+')');
   SQL.Add(' order by LEV_DBAR, LEV_M ');
   ParamByName('ID').AsInteger:=ID;
  Open;
  Last;
  First;
 end;

   if ToUpdate = true then begin
    for k:=0 to Chart1.SeriesCount-1 do
     if Chart1.Series[k].Name=sName then begin
       TLineSeries(Chart1.Series[k]).Clear;
       mik:=k;
       break;
     end;
   end;

  if (ToUpdate = true) and (Qt.IsEmpty=true) then
      TLineSeries(Chart1.Series[mik]).Free;


  if not Qt.IsEmpty then begin
   if ToUpdate = false then begin
    inc(mik);
    if Qt.RecordCount=1 then AddPointSeries(Chart1, sName, clGray, sName);
    if Qt.RecordCount>1 then AddLineSeries(Chart1, sName, clGray, sName);
   end;


    Qt.First;
    while not Qt.Eof do begin
     lev_m := Qt.FieldByName('LEV_M').AsVariant;
     lev_d := Qt.FieldByName('LEV_DBAR').AsVariant;
     val :=Qt.FieldByName('VAL').AsFloat;
     flag:=Qt.FieldByName('PQF2').AsInteger;

        if depth_units=0 then lev:=lev_m else lev:=lev_d;

        TLineSeries(Chart1.Series[mik]).AddXY(val,lev);
      Qt.Next;
    end;
    Qt.Close;
   end;

finally
 Qt.Close;
 Qt.Free;
 Trt.Commit;
 Trt.Free;
end;
end;



procedure Tfrmprofile_plot_all.SelectProfile(sName:string);
var
k,cs:integer;
begin
  cs:=-1;
  for k:=0 to Chart1.SeriesCount-1 do begin
   with TLineSeries(Chart1.Series[k]) do begin
    SeriesColor:=clGray;
    LinePen.Width:=1;
    Pointer.HorizSize:=2;
    Pointer.VertSize:=2;
    ZPosition:=0;
   end;

   if TLineSeries(Chart1.Series[k]).Name=sName then cs:=k; //current series
  end;

  if cs>0 then begin
   with TLineSeries(Chart1.Series[cs]) do begin
    SeriesColor:=clRed;
    LinePen.Width:=2;
    Pointer.HorizSize:=3;
    Pointer.VertSize:=3;
    ZPosition:=1;
   end;
  end;
end;


procedure Tfrmprofile_plot_all.DPCPointClick(
  ATool: TChartTool; APoint: TPoint);
Var
 ID:integer;
 tool: TDataPointClicktool;
 series: TLineSeries;
begin
  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);
      SelectProfile(series.Name);
      ID:=strtoint(copy(series.Name,2,length(series.Name)));
      frmdm.Q.Locate('ID', ID, []);
      frmosmain.CDSNavigation;
  end;
end;

procedure Tfrmprofile_plot_all.btnPriorClick(Sender: TObject);
begin
 btnNext.Enabled:=true;
 frmdm.Q.Prior;
 if frmdm.Q.RecNo=1 then btnPrior.Enabled:=false;
 frmosmain.CDSNavigation;
end;


procedure Tfrmprofile_plot_all.btnNextClick(Sender: TObject);
begin
 btnPrior.Enabled:=true;
 frmdm.Q.Next;
 if frmdm.Q.Eof then btnNext.Enabled:=false;
 frmosmain.CDSNavigation;
end;

procedure Tfrmprofile_plot_all.HighlightSeries(ASeries: TBasicChartSeries);
var
  series: TCustomChartSeries;
begin
  for series in CustomSeries(Chart1) do
    if series is TLineSeries then
    begin
      if (series = ASeries) and (TLineSeries(series).SeriesColor<>clRed) then begin
        TLineSeries(series).LinePen.Width:=2;
        TLineSeries(series).SeriesColor:=clBlack;
      end;
      if (series <> ASeries) and (TLineSeries(series).SeriesColor<>clRed) then begin
        TLineSeries(series).LinePen.Width:=1;
        TLineSeries(series).SeriesColor:=clGray;
      end;
    end;
end;

procedure Tfrmprofile_plot_all.DPHAfterMouseMove(ATool: TChartTool;
  APoint: TPoint);
begin
  HighlightSeries(TDatapointHintTool(ATool).Series);
end;

procedure Tfrmprofile_plot_all.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
Var
  Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
   try
     Ini.WriteInteger( 'osprofile_plot_all', 'Top',    Top);
     Ini.WriteInteger( 'osprofile_plot_all', 'Left',   Left);
     Ini.WriteInteger( 'osprofile_plot_all', 'Width',  Width);
     Ini.WriteInteger( 'osprofile_plot_all', 'Height', Height);
   finally
    Ini.Free;
   end;
end;



end.

