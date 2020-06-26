unit osprofile_plot_all;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, IniFiles, SQLDB, Variants, Types, TAGraph, TATools, TASeries,
  TATypes, TACustomSeries,  // for TChartSeries
  TAChartUtils,    // for nptCustom
  TAEnumerators;   // for CustomSeries(Chart) ;

type

  { Tfrmprofile_plot_all }

  Tfrmprofile_plot_all = class(TForm)
    btnFilterSources: TButton;
    btnClearFilter: TButton;
    Chart1: TChart;
    ChartToolset1: TChartToolset;
    chkShowDuplicates: TCheckBox;
    chkSources: TCheckGroup;
    chkShowBest: TCheckBox;
    DPH: TDataPointHintTool;
    DPC: TDataPointClickTool;
    pFilter: TPanel;
    pUnits: TPanel;
    pDepth: TPanel;
    pfiller: TPanel;
    rbUnitsOriginal: TRadioButton;
    rbUnitsDefault: TRadioButton;
    ToolButton1: TToolButton;
    btnFilter: TToolButton;
    ToolButton3: TToolButton;
    ZD: TZoomDragTool;
    ZMW: TZoomMouseWheelTool;
    ToolBar1: TToolBar;
    btnPrior: TToolButton;
    btnNext: TToolButton;
    btnAllParameters: TToolButton;
    btnMap: TToolButton;
    ToolButton6: TToolButton;
    btnSingleProfile: TToolButton;


    procedure btnClearFilterClick(Sender: TObject);
    procedure btnFilterClick(Sender: TObject);
    procedure btnFilterSourcesClick(Sender: TObject);
    procedure chkHighlightSourceChange(Sender: TObject);
    procedure chkShowBestChange(Sender: TObject);
    procedure chkShowDuplicatesChange(Sender: TObject);
    procedure rbUnitsDefaultClick(Sender: TObject);
    procedure rbUnitsOriginalClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
 //   procedure FormShow(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPriorClick(Sender: TObject);
    procedure DPCPointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure DPHAfterMouseMove(ATool: TChartTool; APoint: TPoint);
    procedure rbDbarClick(Sender: TObject);
    procedure rbMetersClick(Sender: TObject);

  private
    function AddLineSeries (AChart: TChart; ATitle: String;
      AColor:TColor; sName:string):TLineSeries;
    function AddPointSeries(AChart: TChart; ATitle: String;
      AColor:TColor; sName:string):TLineSeries;
    procedure HighlightSeries(ASeries: TBasicChartSeries);
    procedure SelectProfile(sname:string);
    procedure InitialPlot;
  public
    procedure AddToPlot(ID:integer; ToUpdate:boolean);
    procedure ChangeID(ID:integer);
  end;

var
  frmprofile_plot_all: Tfrmprofile_plot_all;
  mik, Units_default:integer;
  flag_st, instr_st:string;


implementation

{$R *.lfm}

{ Tfrmprofile_plot_all }

uses osmain, dm, osunitsconversion, procedures;


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


procedure Tfrmprofile_plot_all.FormCreate(Sender: TObject);
Var
  Ini:TInifile;
  k:integer;
begin
 Ini := TIniFile.Create(IniFileName);
  try
    Top   :=Ini.ReadInteger( 'osprofile_plot_all', 'Top',  100);
    Left  :=Ini.ReadInteger( 'osprofile_plot_all', 'Left', 100);
    Width :=Ini.ReadInteger( 'osprofile_plot_all', 'Width',  600);
    Height:=Ini.ReadInteger( 'osprofile_plot_all', 'Height', 600);
  finally
   Ini.Free;
  end;

  chkSources.Items:=frmosmain.cbSource.Items;
  for k:=0 to chkSources.Items.Count-1 do chkSources.Checked[k]:=true;

  InitialPlot;
end;


procedure Tfrmprofile_plot_all.InitialPlot;
Var
ID, CurrentID, k:integer;
Ini:TInifile;
LeftAxisTitle :string;
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
   SQL.Add(' SELECT UNITS_ID_DEFAULT FROM DATABASE_TABLES WHERE  ');
   SQL.Add(' NAME_TABLE='+QuotedStr(CurrentParTable));
  Open;
   Units_default:=Qt.Fields[0].AsInteger;
  Close;
 end;
finally
 Trt.Commit;
 Trt.Free;
 Qt.Free;
end;


 Ini := TIniFile.Create(IniFileName);
 try
 { case Ini.ReadInteger ( 'osmain', 'depth_units', 0) of
   0: begin
       rbMeters.Checked:=true;
       LeftAxisTitle:='Depth, [m]';
      end;
   1: begin
       rbDbar.Checked:=true;
       LeftAxisTitle:='Depth, [dBar]';
      end;
  end; }

// if Ini.ReadInteger( 'osmain', 'units_default', 0)=0 then
//   rbUnitsDefault.Checked:=true else rbUnitsOriginal.Checked:=true;

 flag_st:='';
 for k:=0 to 8 do
   if Ini.ReadBool('osparameters_list', 'QCF'+inttostr(k), true) then
      flag_st:=flag_st+','+inttostr(k);

 instr_st:='';
 for k:=0 to 17 do
   if Ini.ReadBool('osparameters_list', 'Instrument'+inttostr(k), true) then
      instr_st:=instr_st+','+inttostr(k);

 finally
  Ini.Free;
 end;

flag_st:=copy(flag_st, 2, length(flag_st));
if trim(flag_st)='' then
if MessageDlg('Select at least one QC flag', mtWarning, [mbOk], 0)=mrOk then exit;

instr_st:=copy(instr_st, 2, length(instr_st));
if trim(instr_st)='' then
if MessageDlg('Select at least one instrument', mtWarning, [mbOk], 0)=mrOk then exit;


 mik:=-1;
 Chart1.Series.Clear;
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
k, flag, units, INSTR_ID, PROF_NUM:integer;
lev, val1, val_out:real;
sName:TComponentName;
lev_m, lev_d:Variant;
isConverted:boolean=false;
prof_best, src_fl: boolean;
Instr_name, Src: string;

sColor:TColor;

TRt:TSQLTransaction;
Qt, Qt1, Qt2:TSQLQuery;
begin
TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt:=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=TRt;

Qt1:=TSQLQuery.Create(self);
Qt1.Database:=frmdm.IBDB;
Qt1.Transaction:=TRt;

Qt2:=TSQLQuery.Create(self);
Qt2.Database:=frmdm.IBDB;
Qt2.Transaction:=TRt;

{if (chkHighlightSource.Checked) and
   (frmdm.Q.FieldByName('SRC').Value=cbSource.Text) then
     sColor:=clFuchsia else sColor:=clGray; }

(* filtering sources *)
Src:=frmdm.Q.FieldByName('SRC').AsString;
Src_Fl:=false;
for k:=0 to chkSources.Items.Count-1 do
  if (chkSources.Checked[k]=true) and (chkSources.Items.Strings[k]=Src) then
   Src_Fl:=true;

if Src_Fl=false then exit;

(* filtering duplicates *)
if (chkShowDuplicates.Checked=false) then
   if (frmdm.Q.FieldByName('DUPLICATE').AsBoolean=true) then exit;


try

with Qt1 do begin
  Close;
   SQL.Clear;
   SQL.Add(' SELECT DISTINCT(INSTRUMENT_ID), INSTRUMENT.NAME ');
   SQL.Add(' FROM INSTRUMENT, '+ CurrentParTable);
   SQL.Add(' WHERE ');
   SQL.Add( CurrentParTable+'.INSTRUMENT_ID=INSTRUMENT.ID AND ');
   SQL.Add( CurrentParTable+'.INSTRUMENT_ID in ('+instr_st+') AND ');
   SQL.Add( CurrentParTable+'.ID=:ID ');
   ParamByName('ID').AsInteger:=ID;
  Open;
 end;

 While not Qt1.eof do begin
  INSTR_ID:=Qt1.Fields[0].Value;
  INSTR_NAME:=Qt1.Fields[1].Value;

   with Qt2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT DISTINCT(PROFILE_NUMBER), PROFILE_BEST FROM ');
     SQL.Add( CurrentParTable);
     SQL.Add(' WHERE ');
     SQL.Add( CurrentParTable+'.ID=:ID AND INSTRUMENT_ID=:INSTR_ID ');
     ParamByName('ID').AsInteger:=ID;
     ParamByName('INSTR_ID').AsInteger:=INSTR_ID;
    Open;
   end;

   while not Qt2.eof do begin
    prof_num :=Qt2.Fields[0].AsInteger;
    prof_best:=Qt2.Fields[1].AsBoolean;

   // TabName:=Qt1.Fields[1].Value+', Profile '+inttostr(prof_num);
   // if prof_best=true then TabName:=TabName+' [BEST]';

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' select LEV_DBAR, LEV_M, VAL, PQF2, UNITS_ID from ');
      SQL.Add( CurrentParTable );
      SQL.Add(' where ID=:ID AND ');
      SQL.Add(' PQF2 in ('+flag_st+') AND ');
      SQL.Add(' INSTRUMENT_ID=:INSTR_ID AND ');
      SQL.Add(' PROFILE_NUMBER=:PROF_NUM ');
      if chkShowBest.Checked then
        SQL.Add(' AND PROFILE_BEST=TRUE ');
      SQL.Add(' ORDER BY LEV_DBAR, LEV_M ');
      ParamByName('ID').AsInteger:=ID;
      ParamByName('INSTR_ID').AsInteger:=INSTR_ID;
      ParamByName('PROF_NUM').AsInteger:=PROF_NUM;
     Open;
     Last;
     First;
    end;


   sName:='s'+inttostr(ID)+'_'+instr_name+'__'+inttostr(prof_num);

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
    if Qt.RecordCount=1 then AddPointSeries(Chart1, sName, sColor, sName);
    if Qt.RecordCount>1 then AddLineSeries(Chart1, sName, sColor, sName);
   end;

   Qt.First;
    while not Qt.Eof do begin
     lev_m := Qt.FieldByName('LEV_M').AsVariant;
     lev_d := Qt.FieldByName('LEV_DBAR').AsVariant;
     val1  := Qt.FieldByName('VAL').AsFloat;
     flag  := Qt.FieldByName('PQF2').AsInteger;
     units := Qt.FieldByName('UNITS_ID').AsInteger;

    // if rbMeters.Checked then lev:=lev_m else lev:=lev_d;
    lev:=lev_m;

     if (rbUnitsDefault.Checked=true) and (units<>units_default) then begin
       osunitsconversion.GetDefaultUnits(CurrentParTable, units, units_default,
                                         val1, val_out, isconverted);

       if isConverted=true then val1:=val_out;
     end;

        TLineSeries(Chart1.Series[mik]).AddXY(val1,lev);
      Qt.Next;
    end;
    Qt.Close;
   end;
   qt2.Next;
   end;
  qt1.Next;
 end;

finally
 Qt.Close;
 Qt1.Close;
 Qt2.Close;

 Qt.Free;
 Qt1.Free;
 Qt2.Free;

 Trt.Commit;
 Trt.Free;
end;
end;



procedure Tfrmprofile_plot_all.SelectProfile(sName:string);
var
k,cs:integer;
ChartName: string;
begin
  cs:=-1;
  for k:=0 to Chart1.SeriesCount-1 do begin

   ChartName:=TLineSeries(Chart1.Series[k]).Name;
   ChartName:=Copy(ChartName, 1, Pos('_', ChartName)-1);

 //  showmessage(chartname+'   '+sname);

   with TLineSeries(Chart1.Series[k]) do begin
    SeriesColor:=clGray;
    Pointer.Brush.Color:=clGray;
    LinePen.Width:=1;
    Pointer.HorizSize:=2;
    Pointer.VertSize:=2;
    ZPosition:=0;
   end;

   if ChartName=sName then cs:=k; //current series
  end;

  if cs>0 then begin
   with TLineSeries(Chart1.Series[cs]) do begin
    SeriesColor:=clRed;
    Pointer.Brush.Color:=clRed;
    LinePen.Width:=2;
    Pointer.HorizSize:=3;
    Pointer.VertSize:=3;
    ZPosition:=mik;
   end;
  end;
end;


procedure Tfrmprofile_plot_all.DPCPointClick(
  ATool: TChartTool; APoint: TPoint);
Var
 ID:integer;
 tool: TDataPointClicktool;
 series: TLineSeries;
 ss:integer;
begin
  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);

    for ss:=0 to Chart1.Series.Count-1 do begin
       //  showmessage(Chart1.Series[ss].Name+'   '+series.name);
      if Chart1.Series[ss].Name=series.name then begin
        TLineSeries(Chart1.Series[ss]).SeriesColor:=clRed;
        TLineSeries(Chart1.Series[ss]).Pointer.Brush.Color:=clRed;
        TLineSeries(Chart1.Series[ss]).LinePen.Width:=2;
        TLineSeries(Chart1.Series[ss]).Pointer.HorizSize:=3;
        TLineSeries(Chart1.Series[ss]).Pointer.VertSize:=3;
        TLineSeries(Chart1.Series[ss]).ZPosition:=mik;
      end else begin
        TLineSeries(Chart1.Series[ss]).SeriesColor:=clGray;
        TLineSeries(Chart1.Series[ss]).Pointer.Brush.Color:=clGray;
        TLineSeries(Chart1.Series[ss]).LinePen.Width:=1;
        TLineSeries(Chart1.Series[ss]).Pointer.HorizSize:=2;
        TLineSeries(Chart1.Series[ss]).Pointer.VertSize:=2;
        TLineSeries(Chart1.Series[ss]).ZPosition:=0;
      end;
    end;

      ID:=strtoint(copy(series.Name,2,Pos('_', series.Name)-2));
      frmdm.Q.Locate('ID', ID, []);
     // frmosmain.CDSNavigation;
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


procedure Tfrmprofile_plot_all.rbMetersClick(Sender: TObject);
Var
  Ini:TIniFile;
begin
 { if rbMeters.Checked=true then begin
    Ini := TIniFile.Create(IniFileName);
     try
      Ini.WriteInteger( 'osmain', 'Depth_units', 0);
     finally
      Ini.Free;
     end;
    InitialPlot;
  end;  }
end;


procedure Tfrmprofile_plot_all.rbDBarClick(Sender: TObject);
Var
  Ini:TIniFile;
begin
 { if rbDBar.Checked=true then begin
    Ini := TIniFile.Create(IniFileName);
     try
      Ini.WriteInteger( 'osmain', 'Depth_units', 1);
     finally
      Ini.Free;
     end;
    InitialPlot;
  end; }
end;

procedure Tfrmprofile_plot_all.rbUnitsOriginalClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
   if rbUnitsOriginal.Checked=true then begin
     Ini := TIniFile.Create(IniFileName);
      try
       Ini.WriteInteger( 'osmain', 'units_default', 0)
      finally
       Ini.Free;
      end;
     InitialPlot;
   end;
end;

procedure Tfrmprofile_plot_all.rbUnitsDefaultClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
   if rbUnitsDefault.Checked=true then begin
     Ini := TIniFile.Create(IniFileName);
      try
       Ini.WriteInteger( 'osmain', 'units_default', 1)
      finally
       Ini.Free;
      end;
     InitialPlot;
   end;
end;

procedure Tfrmprofile_plot_all.btnFilterClick(Sender: TObject);
begin
  pFilter.Visible:=btnFilter.Down;
end;

procedure Tfrmprofile_plot_all.btnClearFilterClick(Sender: TObject);
Var
 k: integer;
begin
  chkShowBest.Checked:=false;
    for k:=0 to chkSources.Items.Count-1 do chkSources.Checked[k]:=true;
  InitialPlot;
end;

procedure Tfrmprofile_plot_all.btnFilterSourcesClick(Sender: TObject);
begin
 InitialPlot;
end;

procedure Tfrmprofile_plot_all.chkHighlightSourceChange(Sender: TObject);
begin
{  if cbSource.ItemIndex=-1 then
   if MessageDlg('Select source below', mtWarning, [mbOk], 0)=mrOk then exit;

   InitialPlot; }
end;

procedure Tfrmprofile_plot_all.chkShowBestChange(Sender: TObject);
begin
  InitialPlot;
end;

procedure Tfrmprofile_plot_all.chkShowDuplicatesChange(Sender: TObject);
begin
  InitialPlot;
end;


procedure Tfrmprofile_plot_all.FormDestroy(Sender: TObject);
begin
 Chart1.Series.Clear;
end;

procedure Tfrmprofile_plot_all.FormResize(Sender: TObject);
begin
 pFiller.Width:=ToolBar1.Width-20-
 (btnPrior.Width+
  btnNext.Width+
  btnAllParameters.Width+
  btnSingleProfile.Width+
  btnMap.Width+
  btnFilter.Width+
  pDepth.Width+
  pUnits.Width);
end;



end.

