unit osparameters_allprofiles;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, TAGraph,
  TASeries, TATypes, TATools, IniFiles, SQLDB, Variants, Types;

type

  { Tfrmparameters_allprofiles }

  Tfrmparameters_allprofiles = class(TForm)
    Chart1: TChart;
    ChartToolset1: TChartToolset;
    ChartToolset1DataPointClickTool1: TDataPointClickTool;
    ChartToolset1ZoomDragTool1: TZoomDragTool;
    ChartToolset1ZoomMouseWheelTool1: TZoomMouseWheelTool;
    ToolBar1: TToolBar;
    btnPrior: TToolButton;
    btnNext: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;

    procedure btnNextClick(Sender: TObject);
    procedure btnPriorClick(Sender: TObject);
    procedure ChartToolset1DataPointClickTool1PointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure FormShow(Sender: TObject);


  private
    function AddLineSeries (AChart: TChart; ATitle: String;
      AColor:TColor; sName:string):TLineSeries;
    function AddPointSeries(AChart: TChart; ATitle: String;
      AColor:TColor; sName:string):TLineSeries;
    procedure SelectProfile(sname:string);
  public
    procedure AddToPlot(ID:integer);
    procedure ChangeID(ID:integer);
    procedure UpdateProfile(ID:integer);
  end;

var
  frmparameters_allprofiles: Tfrmparameters_allprofiles;

  TMPSeries:TBasicChartSeries;
  mik:integer;
  ismeters: boolean=false;

implementation

{$R *.lfm}

{ Tfrmparameters_allprofiles }

uses osmain, dm, osparameters_list;


function Tfrmparameters_allprofiles.AddLineSeries(AChart: TChart;
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
  end;
 AChart.AddSeries(Result);
end;


function Tfrmparameters_allprofiles.AddPointSeries(AChart: TChart;
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


procedure Tfrmparameters_allprofiles.FormShow(Sender: TObject);
var
k, ID, CurrentID:integer;
sName:TComponentName;
Ini:TInifile;
LeftAxisTitle:string;
begin
Ini := TIniFile.Create(IniFileName);
  try
    Width :=Ini.ReadInteger( 'Profiles', 'Width',  600);
    Height:=Ini.ReadInteger( 'Profiles', 'Height', 600);
  finally
   Ini.Free;
  end;

    mik:=-1;
    ismeters:=false;
     try
      CurrentID:=frmdm.Q.FieldByName('ID').AsInteger;
      frmdm.Q.DisableControls;
      frmdm.Q.First;
        While not frmdm.Q.Eof do begin
         ID:=frmdm.Q.FieldByName('ID').AsInteger;
           AddToPlot(ID);
         frmdm.Q.Next;
        end;
      finally
        frmdm.Q.Locate('ID',CurrentID,[]);
        frmdm.Q.EnableControls;
      end;

    if ismeters then LeftAxisTitle:='Depth, [m]' else LeftAxisTitle:='Depth, [dBar]';

    Chart1.AxisList.LeftAxis.Title.Caption:=LeftAxisTitle;
    ChangeID(CurrentID);

  Caption:=CurrentParTable+', '+inttostr(Chart1.SeriesCount-1)+' profiles';
  Application.ProcessMessages;
end;


procedure Tfrmparameters_allprofiles.ChangeID(ID:integer);
var
sname, stnum:string;
begin
 sName:='s'+inttostr(ID);
 SelectProfile(sname);
end;


procedure Tfrmparameters_allprofiles.AddToPlot(ID:integer);
Var
flag:integer;
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

try
 with Qt do begin
  Close;
   SQL.Clear;
   SQL.Add(' select LEV_DBAR, LEV_M, VAL, PQF2 from ');
   SQL.Add( CurrentParTable );
   SQL.Add(' where ID=:ID ');
   SQL.Add(' order by LEV_DBAR, LEV_M ');
   ParamByName('ID').AsInteger:=ID;
  Open;
  Last;
  First;
 end;

  if not Qt.IsEmpty then begin
   inc(mik);
   sName:='s'+inttostr(ID);

    if Qt.RecordCount=1 then AddPointSeries(Chart1, sName, clYellow, sName);
    if Qt.RecordCount>1 then AddLineSeries(Chart1, sName, clGray, sName);

    Qt.First;
    while not Qt.Eof do begin
     lev_m := Qt.FieldByName('LEV_M').AsVariant;
     lev_d := Qt.FieldByName('LEV_DBAR').AsVariant;
     val :=Qt.FieldByName('VAL').AsFloat;
     flag:=Qt.FieldByName('PQF2').AsInteger;

     if not VarIsNull(lev_m) then begin
       lev:=lev_m;
       ismeters:=true;
     end else lev:=lev_d;

     if frmparameters_list.chklQCFlags.Checked[flag]=true then
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



procedure Tfrmparameters_allprofiles.SelectProfile(sName:string);
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


procedure Tfrmparameters_allprofiles.UpdateProfile(ID:integer);
Var
sname:string;
k, flag:integer;
Empty, FlagIsSet:boolean;
val, lev:real;
begin
{sName:='s'+inttostr(ID);
for k:=0 to Chart1.SeriesList.Count-1 do
  if Chart1.SeriesList[k].Name=sName then begin
     Chart1[k].Clear;
     ODBDM.IBTransaction1.StartTransaction;
     SelectData(ID, Empty);
     if Empty=false then begin
        ODBDM.ib1q2.First;
        while not ODBDM.ib1q2.Eof do begin
           lev:=ODBDM.ib1q2.FieldByName('Level_').AsFloat;
           val:=ODBDM.ib1q2.FieldByName('Value_').AsFloat;
           flag:=ODBDM.ib1q2.FieldByName('Flag_').AsInteger;
             FlagIsSet:=false;
              if flag>0 then ProfilesSelection.FlagAnalysis(flag,FlagIsSet);
              if FlagIsSet=false then Chart1.Series[mik].AddXY(val,lev);
         ODBDM.ib1q2.Next;
        end;
        ODBDM.ib1q2.Close;
    end;
    ODBDM.IBTransaction1.Commit;
 end;   }
end;


procedure Tfrmparameters_allprofiles.ChartToolset1DataPointClickTool1PointClick(
  ATool: TChartTool; APoint: TPoint);
Var
 sName:string;
 ID:integer;
  tool: TDataPointClicktool;
  series: TLineSeries;
begin
showmessage('here');

  if not (ATool is TDataPointClickTool) then exit;

  tool := TDatapointClickTool(ATool);
  if tool <> nil then begin
   showmessage('here2');

    if not (tool.Series is TLineSeries) then exit;
    series := TLineSeries(tool.Series);

    showmessage('here3');
    if series <> nil then begin
      sName := series.Name;
      SelectProfile(sname);
      ID:=strtoint(copy(sname,2,length(sname)));
      frmdm.Q.Locate('ID', ID, []);
      frmosmain.CDSNavigation;
   end
  end;
end;

procedure Tfrmparameters_allprofiles.btnPriorClick(Sender: TObject);
begin
 btnNext.Enabled:=true;
 frmdm.Q.Prior;
 if frmdm.Q.RecNo=1 then btnPrior.Enabled:=false;
 frmosmain.CDSNavigation;
end;


procedure Tfrmparameters_allprofiles.btnNextClick(Sender: TObject);
begin
 btnPrior.Enabled:=true;
 frmdm.Q.Next;
 if frmdm.Q.Eof then btnNext.Enabled:=false;
 frmosmain.CDSNavigation;
end;



end.

