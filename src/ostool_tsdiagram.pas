unit ostool_tsdiagram;

{$mode ObjFPC}{$H+}

interface

uses
  LCLIntf, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  DBGrids, Grids, ComCtrls, TAGraph, TASeries, TAChartUtils, TATypes, TATools,
  TACustomSeries, TAEnumerators,
  IniFiles, DB, SQLDB, Math, Types;

type

  { Tfrmostool_tsdiagram }

  Tfrmostool_tsdiagram = class(TForm)
    Chart1: TChart;
    CTS: TChartToolset;
    ZMV: TZoomMouseWheelTool;
    ZD: TZoomDragTool;
    DPH: TDataPointHintTool;
    DPC: TDataPointClickTool;
    Panel1: TPanel;
    sgTSDiagram: TStringGrid;
    tbTSDiagram: TToolBar;
    btnSurfer: TToolButton;
    btnOpenDataFolder: TToolButton;
    procedure btnOpenDataFolderClick(Sender: TObject);
    procedure DPCPointClick(ATool: TChartTool; APoint: TPoint);
    procedure DPHAfterMouseMove(ATool: TChartTool; APoint: TPoint);
    procedure DPHHint(ATool: TDataPointHintTool; const APoint: TPoint;
      var AHint: String);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnSurferClick(Sender: TObject);

  private
    function AddLineSeries (AChart: TChart; ATitle: String;
      AColor:TColor; sName:string):TLineSeries;
    procedure HighlightSeries(ASeries: TBasicChartSeries);
    procedure SelectProfile(sname:string);

  public
    procedure ChangeID(ID:int64);
  end;


var
  frmostool_tsdiagram: Tfrmostool_tsdiagram;
  tsdiagram_path: string;
  mik:integer;


implementation

{$R *.lfm}

{ Tfrmostool_tsdiagram }

uses osmain, dm, ostool_tsdiagram_surfer;

function Tfrmostool_tsdiagram.AddLineSeries(AChart: TChart;
  ATitle: String; AColor:TColor; sName:string): TLineSeries;
begin
 Result := TLineSeries.Create(AChart.Owner);
  with TLineSeries(Result) do begin
    Title := ATitle;
    Name := sName;
    ShowPoints := false;
    Pointer.Brush.Color := AColor;
    Pointer.Pen.Color := AColor;
    Pointer.Style := psCircle;
    Pointer.HorizSize:=2;
    Pointer.VertSize:=2;
    ShowLines := true;
    LinePen.Style := psSolid;
    LinePen.Width := 1;
    LinePen.Cosmetic := true;
    SeriesColor := AColor;
    LineType := ltFromPrevious;
    AxisIndexX := -1;
    AxisIndexY := -1;
    Marks.Visible :=false;
    ToolTargets := [nptPoint, nptYList, nptCustom];
  end;
 AChart.AddSeries(Result);
end;

procedure Tfrmostool_tsdiagram.FormCreate(Sender: TObject);
var
  ID, ID_old: int64;
  k, ll:integer;
  lat,lon: real;
  tmin,tmax,smin,smax,dmin,dmax:double;
  Ini:TInifile;
  sName, pqf2_str:string;
  ts_out:text;
begin
  Ini := TIniFile.Create(IniFileName);
    try
      Top   :=Ini.ReadInteger(Name, 'Top',    frmosmain.Height);
      Left  :=Ini.ReadInteger(Name, 'Left',   frmosmain.Left);
      Height:=Ini.ReadInteger(Name, 'Height', 450 );
      Width :=Ini.ReadInteger(Name, 'Width',  750 );

      pqf2_str:='';
      for k:=0 to PQF2_list.Count-1 do
        if Ini.ReadBool('osparameters_list', 'PQF2_'+inttostr(k), true) =true then
          pqf2_str:=pqf2_str+','+ Copy(PQF2_list.Strings[k], 2, Pos(']', PQF2_list.Strings[k])-2);
      pqf2_str:=copy(pqf2_str, 2, length(pqf2_str));
   //   showmessage(pqf2_str);

    finally
     Ini.Free;
    end;
    if Left> Screen.Width then Left:=0;

    tsdiagram_path:=GlobalUnloadPath+'tsdiagram';
    if not DirectoryExists(tsdiagram_path) then CreateDir(tsdiagram_path);

    AssignFile(ts_out, tsdiagram_path+PathDelim+'ts_diagram.dat'); rewrite(ts_out);
    writeln(ts_out, 'S':8, 'T':8, 'D':8, 'Lev':11, 'ID':8);

    mik:=-1;
    tmin:=9999; tmax:=-9999;
    smin:=9999; smax:=-9999;
    dmin:=9999; dmax:=-9999;
     try
      ID_old:=frmdm.Q.FieldByName('ID').Value;
      frmdm.Q.DisableControls;
      frmdm.Q.First;
       While not frmdm.Q.Eof do begin
         ID:=frmdm.Q.FieldByName('ID').value;
         Lat:=frmdm.Q.FieldByName('latitude').value;
         Lon:=frmdm.Q.FieldByName('longitude').value;

         GetDensityProfile(frmdm.Q.FieldByName('ID').value, pqf2_str,
                          lat, lon, tmin, tmax, smin, smax, dmin, dmax);

         if length(CDSDensity) = 0 then Continue;

         sName:='s'+inttostr(ID); //+'_'+Src;

         AddLineSeries(Chart1, sName, clGray, sName);
         inc(mik);

         for ll:=1 to high(CDSDensity) do begin

             TLineSeries(Chart1.Series[mik]).AddXY(
               CDSDensity[ll].SVal,
               CDSDensity[ll].Tval,
               FloattostrF(CDSDensity[ll].DVal, fffixed, 8, 4)+'; '+
               Floattostr(CDSDensity[ll].Lev));

             writeln(ts_out, CDSDensity[ll].SVal:8:4,
                             CDSDensity[ll].TVal:8:4,
                             CDSDensity[ll].DVal:8:4,
                             CDSDensity[ll].Lev:11:4,
                             ID:8);
          end;
          frmdm.Q.Next;
       end;

     finally
      frmdm.Q.Locate('ID', ID_old, []);
      frmdm.Q.EnableControls;
     end;
     CloseFile(ts_out);

  // Density contour for Surfer
  GetDensityContour(tsdiagram_path,lat,lon,tmin,tmax,smin,smax,dmin,dmax);

  // Selecting current station
  ChangeID(ID_old);
end;


procedure Tfrmostool_tsdiagram.ChangeID(ID:int64);
begin
  SelectProfile('s'+inttostr(ID));
end;



procedure Tfrmostool_tsdiagram.SelectProfile(sname:string);
var
ID: int64;
k,ll:integer;
ChartName, lb: string;
begin
 for k:=0 to Chart1.SeriesCount-1 do begin
  ChartName:=TLineSeries(Chart1.Series[k]).Name;

  if sName=ChartName then begin
    with TLineSeries(Chart1.Series[k]) do begin
     SeriesColor:=clRed;
     ShowPoints := true;
     Pointer.Brush.Color:=clRed;
     Pointer.Pen.Color := clBlack;
     LinePen.Width:=2;
     ZPosition:=mik;
    end;

    sgTSDiagram.Clear;
    sgTSDiagram.RowCount:=TLineSeries(Chart1.Series[k]).Count+1;
    for ll:=1 to TLineSeries(Chart1.Series[k]).Count do begin
      lb:=TLineSeries(Chart1.Series[k]).ListSource.Item[ll-1]^.Text;
      with sgTSDiagram do begin
        Cells[0,ll]:=copy(lb, pos(';', lb)+1, length(lb));
        Cells[1,ll]:=floattostr(TLineSeries(Chart1.Series[k]).YValue[ll-1]);
        Cells[2,ll]:=floattostr(TLineSeries(Chart1.Series[k]).XValue[ll-1]);
        Cells[3,ll]:=copy(lb, 1, pos(';', lb)-1);
      end;
    end;

    ID:=StrToInt(copy(sName, 2, length(sName)));
    Caption:='TS diagram: '+IntToStr(ID);
    frmdm.Q.Locate('ID', ID, []);
    frmosmain.CDSNavigation;

  end else begin
    with TLineSeries(Chart1.Series[k]) do begin
     SeriesColor:=clGray;
     ShowPoints := false;
     LinePen.Width:=1;
     ZPosition:=0;
    end;
  end;
 end;

end;


procedure Tfrmostool_tsdiagram.DPCPointClick(ATool: TChartTool; APoint: TPoint);
Var
 tool: TDataPointClicktool;
 series: TLineSeries;
begin
  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);
   if series.Active=true then begin
     SelectProfile(series.name);
     if tool.PointIndex<>-1 then sgTSDiagram.Row:=tool.PointIndex+1;
   end;
  end;
end;


procedure Tfrmostool_tsdiagram.HighlightSeries(ASeries: TBasicChartSeries);
var
  series: TCustomChartSeries;
begin
  for series in CustomSeries(Chart1) do
    if (series is TLineSeries) and (series.Active=true) then begin
      if (series = ASeries) and (TLineSeries(series).SeriesColor<>clRed) then begin
        TLineSeries(series).LinePen.Width:=2;
      end;
      if (series <> ASeries) and (TLineSeries(series).SeriesColor<>clRed) then begin
        TLineSeries(series).LinePen.Width:=1;
      end;
    end;
end;

procedure Tfrmostool_tsdiagram.DPHAfterMouseMove(ATool: TChartTool;
  APoint: TPoint);
begin
    HighlightSeries(TDatapointHintTool(ATool).Series);
end;

procedure Tfrmostool_tsdiagram.DPHHint(ATool: TDataPointHintTool;
  const APoint: TPoint; var AHint: String);
Var
  tool:TDataPointHintTool;
begin
  tool := ATool as TDataPointHintTool;
  if (tool.PointIndex<>-1) then
  AHint:= TLineSeries(ATool.Series).Source.Item[ATool.PointIndex]^.Text;
end;


procedure Tfrmostool_tsdiagram.btnSurferClick(Sender: TObject);
begin

end;

procedure Tfrmostool_tsdiagram.btnOpenDataFolderClick(Sender: TObject);
begin
  OpenDocument(PChar(tsdiagram_path));
end;


procedure Tfrmostool_tsdiagram.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var
Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger(Name, 'Top', Top);
    Ini.WriteInteger(Name, 'Left', Left);
    Ini.WriteInteger(Name, 'Height', Height);
    Ini.WriteInteger(Name, 'Width', Width);
   finally
    ini.Free;
  end;

  frmostool_tsdiagram_open:=false;
  CloseAction:=cafree;
end;


end.

