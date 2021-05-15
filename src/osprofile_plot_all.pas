unit osprofile_plot_all;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF WINDOWS}
    UXTheme,
  {$ENDIF}

  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, IniFiles, SQLDB, Variants, Types, TAGraph, TATools, TASeries, DB,
  TATypes, TACustomSeries, TAChartUtils, TAEnumerators, BufDataset;

type

  { Tfrmprofile_plot_all }

  Tfrmprofile_plot_all = class(TForm)
    Chart1: TChart;
    ChartToolset1: TChartToolset;
    chkCruiseHighlight: TCheckBox;
    chkShowBest: TCheckBox;
    DPH: TDataPointHintTool;
    DPC: TDataPointClickTool;
    Label1: TLabel;
    pFilter: TPanel;
    pUnitsContainer: TPanel;
    pDepth: TPanel;
    pfiller: TPanel;
    rbUnitsOriginal: TRadioButton;
    rbUnitsDefault: TRadioButton;
    StatusBar1: TStatusBar;
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

    procedure chkCruiseHighlightChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnFilterClick(Sender: TObject);
    procedure chkShowBestChange(Sender: TObject);
    procedure rbUnitsDefaultClick(Sender: TObject);
    procedure rbUnitsOriginalClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPriorClick(Sender: TObject);
    procedure DPCPointClick(ATool: TChartTool; APoint: TPoint);
    procedure DPHAfterMouseMove(ATool: TChartTool; APoint: TPoint);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);

  private
    function AddLineSeries (AChart: TChart; ATitle: String;
      AColor:TColor; sName:string):TLineSeries;
    function AddPointSeries(AChart: TChart; ATitle: String;
      AColor:TColor; sName:string):TLineSeries;
    procedure HighlightSeries(ASeries: TBasicChartSeries);
    procedure SelectProfile(sname:string);
    procedure InitialPlot;
    procedure FilterSources(Sender: TObject);

  public
    procedure AddToPlot(ID, INSTR_ID, PROF_NUM:integer; INSTR_NAME: string;
      prof_best, ToUpdate:boolean; var units:integer; Var units_ok:boolean);
    procedure ChangeID(ID:integer);
  end;

var
  frmprofile_plot_all: Tfrmprofile_plot_all;
  mik, Units_default:integer;
  units_default_name:string;
  chkSourceList:array of TCheckBox;


implementation

{$R *.lfm}

{ Tfrmprofile_plot_all }

uses osmain, dm, osparameters_list, osunitsconversion;


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
  k, top_pos:integer;
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


  (* creating checkboxes for sources *)
  SetLength(chkSourceList, Source_unq_list.Count);
  top_pos:=80;
  for k:=0 to Source_unq_list.Count-1 do begin
    top_pos:=top_pos+25;

    chkSourceList[k]:=TCheckBox.Create(frmprofile_plot_all);
    chkSourceList[k].Parent:=pfilter;
    chkSourceList[k].Caption:=Source_unq_list.Strings[k];
    chkSourceList[k].Checked:=true;
    if k<=high(s_clr) then
      chkSourceList[k].Font.Color:=s_clr[k+1] else
      chkSourceList[k].Font.Color:=s_clr[k+1-high(s_clr)];
    chkSourceList[k].Left:=16;
    chkSourceList[k].Top:=top_pos;
    chkSourceList[k].OnChange:=@FilterSources;

  {$IFDEF WINDOWS}
    SetWindowTheme(chkSourceList[k].Handle, '', '');
  {$ENDIF}

  end;
end;

procedure Tfrmprofile_plot_all.chkCruiseHighlightChange(Sender: TObject);
Var
  ID, crID, crID_stat, ss:integer;
  sName: string;
begin
    crID:=frmdm.QCruise.FieldByName('ID').AsInteger;

    if chkCruiseHighlight.Checked=true then begin
      for ss:=0 to Chart1.Series.Count-1 do begin
       sName:=Chart1.Series[ss].Name;
       if (Chart1.Series[ss].Active=true) then begin
         ID:=StrToInt(copy(sname, 2, Pos('_', sname)-2));
         crID_stat:=frmdm.Q.Lookup('ID', ID, 'CRUISE_ID');
         if CrID_stat=CrID then begin
           with TLineSeries(Chart1.Series[ss]) do begin
            LinePen.Width:=3;
            Pointer.HorizSize:=4;
            Pointer.VertSize:=4;
            ZPosition:=mik;
          end;
         end else
          with TLineSeries(Chart1.Series[ss]) do begin
            LinePen.Width:=1;
            Pointer.HorizSize:=2;
            Pointer.VertSize:=2;
            ZPosition:=0;
          end;
       end;
      end;
    end;

   if chkCruiseHighlight.Checked=false then begin
    for ss:=0 to Chart1.Series.Count-1 do begin
     if (Chart1.Series[ss].Active=true) then begin
      with TLineSeries(Chart1.Series[ss]) do begin
       LinePen.Width:=1;
       Pointer.HorizSize:=2;
       Pointer.VertSize:=2;
       ZPosition:=0;
      end;
     end;
    end;
   end;
end;


procedure Tfrmprofile_plot_all.FormShow(Sender: TObject);
Var
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
   SQL.Add(' SELECT DATABASE_TABLES.UNITS_ID_DEFAULT, ');
   SQL.Add(' UNITS.NAME_SHORT FROM ');
   SQL.Add(' DATABASE_TABLES, UNITS WHERE  ');
   SQL.Add(' DATABASE_TABLES.UNITS_ID_DEFAULT=UNITS.ID AND  ');
   SQL.Add(' DATABASE_TABLES.NAME_TABLE='+QuotedStr(CurrentParTable));
  Open;
   Units_default:=Qt.FieldByName('UNITS_ID_DEFAULT').AsInteger;
   Units_default_name:=Qt.FieldByName('NAME_SHORT').AsString;
  Close;
 end;
finally
 Trt.Commit;
 Trt.Free;
 Qt.Free;

 InitialPlot;
end;
end;


procedure Tfrmprofile_plot_all.InitialPlot;
Var
ID, CurrentID, k, cnt, ss, c:integer;
Ini:TInifile;
sName, src_name, str_units :string;

prof_num, instr_id, units: integer;
prof_best: boolean;
instr_name, LeftAxisTitle: string;

units_arr: array of integer;
units_prof, cnt_def, cnt_orig:integer;

units_buf:TBufDataset;
units_ok: boolean;

Qt1, Qt2:TSQLQuery;
TRt:TSQLTransaction;

PQF1_st, PQF2_st, SQF_st, instr_st: string;
begin

  case depth_units of
   0: LeftAxisTitle:='Depth, [m]';
   1: LeftAxisTitle:='Depth, [dBar]';
  end;

  frmparameters_list.GetFlags(PQF1_st, PQF2_st, SQF_st, instr_st);

 //  showmessage(pqf1_st+#13+pqf2_st+#13+sqf_st+#13+instr_st);

  if (trim(PQF1_st)='') or (trim(PQF2_st)='') or (trim(SQF_st)='') then
    if MessageDlg('Please, set QC flags', mtWarning, [mbOk], 0)=mrOk then exit;

  if trim(instr_st)='' then
    if MessageDlg('Select at least one instrument', mtWarning, [mbOk], 0)=mrOk then exit;


 mik:=-1;
 Chart1.Series.Clear;
  try
   CurrentID:=frmdm.Q.FieldByName('ID').AsInteger;

   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt1:=TSQLQuery.Create(self);
   Qt1.Database:=frmdm.IBDB;
   Qt1.Transaction:=TRt;

   Qt2:=TSQLQuery.Create(self);
   Qt2.Database:=frmdm.IBDB;
   Qt2.Transaction:=TRt;

   frmdm.Q.DisableControls;
   frmdm.Q.First;
     cnt_def:=0;
     cnt_orig:=0;

   units_buf:=TBufDataSet.Create(nil);
   with units_buf.FieldDefs do begin
     Add('qf',  ftinteger, 0, false);
     Add('cnt', ftinteger, 0, false);
   end;
   units_buf.CreateDataSet;

     While not frmdm.Q.Eof do begin
      ID:=frmdm.Q.FieldByName('ID').AsInteger;

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

        AddToPlot(ID, INSTR_ID,  PROF_NUM, INSTR_NAME, prof_best, false, units, units_ok);

        if units_ok=true then begin
         if VarIsNull(units_buf.Lookup('qf', units, 'qf')) then begin
          units_buf.Append;
          units_buf.FieldByName('qf').Value:=units;
          units_buf.FieldByName('cnt').Value:=1;
          units_buf.Post;
         end else begin
          units_buf.Locate('qf', units, []);
          units_buf.Edit;
          units_buf.FieldByName('cnt').Value:=units_buf.FieldByName('cnt').Value+1;
          units_buf.Post;
         end;
        end;
       Qt2.Next;
      end;
     Qt1.Next;
   end;

  frmdm.Q.Next;
  end;

   str_units:='';
   units_buf.First;
   while not units_buf.EOF do begin
     with Qt2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT UNITS.NAME_SHORT ');
       SQL.Add(' FROM UNITS WHERE ID='+inttostr(units_buf.Fields[0].Value));
      Open;
     end;
    str_units:=str_units+'; '+
               Qt2.Fields[0].Value+' ('+
               inttostr(units_buf.Fields[1].Value)+')';
    units_buf.Next;
   end;
   str_units:=trim(copy(str_units, 2, length(str_units)));
   StatusBar1.Panels.Items[0].Text:=str_units;
   rbUnitsOriginal.Caption:='Original units ('+inttostr(units_buf.RecordCount)+')';
   rbUnitsDefault.Caption:=units_default_name;

   finally
    Qt1.Close;
    Qt2.Close;
    Qt1.Free;
    Qt2.Free;

    Trt.Commit;
    Trt.Free;

    units_buf.Free;

     frmdm.Q.Locate('ID',CurrentID,[]);
     frmdm.Q.EnableControls;
   end;

   for k:=0 to high(chkSourceList) do begin
    if Pos('(', chkSourceList[k].Caption)>0 then
      src_name:=copy(chkSourceList[k].Caption, 1, Pos('(', chkSourceList[k].Caption)-2) else
      src_name:=chkSourceList[k].Caption;

    cnt:=0;
    for ss:=0 to Chart1.Series.Count-1 do begin
      sName:=Chart1.Series[ss].Name;
      if copy(sName, Pos('_', sName)+1, (Pos('__', sName)-Pos('_', sName))-1) = src_name then inc(cnt);
     end;
     chkSourceList[k].Caption:=src_name+' ('+inttostr(cnt)+')';
    end;

 Chart1.AxisList.LeftAxis.Title.Caption:=LeftAxisTitle;
 ChangeID(CurrentID);

Caption:=CurrentParTable+', '+inttostr(Chart1.SeriesCount)+' profiles';

Application.ProcessMessages;
end;

procedure Tfrmprofile_plot_all.ChangeID(ID:integer);
begin
 SelectProfile('s'+inttostr(ID));
end;


procedure Tfrmprofile_plot_all.AddToPlot(ID, INSTR_ID, PROF_NUM:integer;
  INSTR_NAME: string; prof_best, ToUpdate:boolean; var units:integer;
  var units_ok:boolean);
Var
k, flag:integer;
lev, val1, val_out, lab_dens, Lat, Lon:real;
sName:TComponentName;
lev_m, lev_d:Variant;
isConverted:boolean=false;
src_fl: boolean;
Src, src_name: string;

sColor:TColor;

TRt:TSQLTransaction;
Qt:TSQLQuery;

PQF1_st, PQF2_st, SQF_st, instr_st:string;
begin

TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt:=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=TRt;
try
units_ok:=false;

frmparameters_list.GetFlags(PQF1_st, PQF2_st, SQF_st, instr_st);

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT LEV_DBAR, LEV_M, VAL, UNITS_ID ');
      SQL.Add(' FROM '+ CurrentParTable );
      SQL.Add(' WHERE ID=:ID AND ');
      SQL.Add(' PQF1 IN ('+PQF1_st+') AND ');
      SQL.Add(' PQF2 IN ('+PQF2_st+') AND ');
      SQL.Add(' SQF IN ('+SQF_st+') AND ');
      SQL.Add(' INSTRUMENT_ID=:INSTR_ID AND ');
      SQL.Add(' PROFILE_NUMBER=:PROF_NUM ');
      if chkShowBest.Checked then
        SQL.Add(' AND PROFILE_BEST=TRUE ');
      SQL.Add(' ORDER BY LEV_DBAR');
      ParamByName('ID').AsInteger:=ID;
      ParamByName('INSTR_ID').AsInteger:=INSTR_ID;
      ParamByName('PROF_NUM').AsInteger:=PROF_NUM;
     Open;
     Last;
     First;
    end;

    Lat:=frmdm.Q.FieldByName('LATITUDE').Value;
    Lon:=frmdm.Q.FieldByName('LONGITUDE').Value;

    Src:=frmdm.QCruise.Lookup('ID', frmdm.Q.FieldByName('CRUISE_ID').Value, 'SOURCE');
    for k:=0 to high(chkSourceList) do begin
     if Pos('(', chkSourceList[k].Caption)>0 then
       src_name:=copy(chkSourceList[k].Caption, 1, Pos('(', chkSourceList[k].Caption)-2) else
       src_name:=chkSourceList[k].Caption;
     if Src=src_name then begin
       if k<=high(s_clr) then sColor:=s_clr[k+1] else sColor:=s_clr[k+1-high(s_clr)];
     end;
    end;

   // if there is a space in the instrument name
   instr_name:=StringReplace(instr_name, ' ', '_', []);

   sName:='s'+inttostr(ID)+'_'+Src+'__'+instr_name+'___'+inttostr(prof_num);
   if prof_best=true then sName:=sName+'____B';

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
     units := Qt.FieldByName('UNITS_ID').AsInteger;

     (* units for the vertical axis *)
     if depth_units=0 then lev:=lev_m else lev:=lev_d;

     if (rbUnitsDefault.Checked=true) and (units<>units_default) then begin

       osunitsconversion.GetDefaultUnits(CurrentParTable, units, units_default,
                                         val1, val_out, isconverted);

       if isConverted=true then val1:=val_out else val1:=-9999;
     end;

     if val1<>-9999 then begin
      TLineSeries(Chart1.Series[mik]).AddXY(val1,lev);
      units_ok:=true;
     end;
      Qt.Next;
    end;
    Qt.Close;
   end;

finally
 Qt.Close;

 Trt.Commit;
 Trt.Free;
end;
end;



procedure Tfrmprofile_plot_all.SelectProfile(sName:string);
var
k, cs, i, c:integer;
ChartName, ss_name, src_name: string;
clr:TColor;
begin
  cs:=-1;
  for k:=0 to Chart1.SeriesCount-1 do begin

   ChartName:=TLineSeries(Chart1.Series[k]).Name;

   ss_name:=copy(ChartName, Pos('_', ChartName)+1,
                (Pos('__', ChartName)-Pos('_', ChartName))-1);

       for c:=0 to high(chkSourceList) do begin
        if Pos('(', chkSourceList[c].Caption)>0 then
        src_name:=copy(chkSourceList[c].Caption, 1, Pos('(', chkSourceList[c].Caption)-2) else
        src_name:=chkSourceList[c].Caption;

        if src_name=ss_name then clr:=s_clr[c+1];
        end;

   with TLineSeries(Chart1.Series[k]) do begin
    SeriesColor:=clr;
    Pointer.Brush.Color:=clr;
    LinePen.Width:=1;
    Pointer.HorizSize:=2;
    Pointer.VertSize:=2;
    ZPosition:=0;
   end;

   if sName=Copy(ChartName, 1, Pos('_', ChartName)-1) then cs:=k; //current series
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
 ID, CrID:integer;
 tool: TDataPointClicktool;
 series: TLineSeries;
 k, ss:integer;
 clr:TColor;
 sName, ss_name, src_name:string;
begin
  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);
   if series.Active=true then begin
    for ss:=0 to Chart1.Series.Count-1 do begin
       sName:=Chart1.Series[ss].Name;
       ss_name:=copy(sName, Pos('_', sName)+1, (Pos('__', sName)-Pos('_', sName))-1);

       for k:=0 to high(chkSourceList) do begin
        if Pos('(', chkSourceList[k].Caption)>0 then
        src_name:=copy(chkSourceList[k].Caption, 1, Pos('(', chkSourceList[k].Caption)-2) else
        src_name:=chkSourceList[k].Caption;

        if src_name=ss_name then clr:=s_clr[k+1];
        end;

      if Chart1.Series[ss].Name=series.name then begin
        TLineSeries(Chart1.Series[ss]).SeriesColor:=clRed;
        TLineSeries(Chart1.Series[ss]).Pointer.Brush.Color:=clRed;
        TLineSeries(Chart1.Series[ss]).LinePen.Width:=2;
        TLineSeries(Chart1.Series[ss]).Pointer.HorizSize:=3;
        TLineSeries(Chart1.Series[ss]).Pointer.VertSize:=3;
        TLineSeries(Chart1.Series[ss]).ZPosition:=mik;
      end else begin
        TLineSeries(Chart1.Series[ss]).SeriesColor:=clr;
        TLineSeries(Chart1.Series[ss]).Pointer.Brush.Color:=clr;
        TLineSeries(Chart1.Series[ss]).LinePen.Width:=1;
        TLineSeries(Chart1.Series[ss]).Pointer.HorizSize:=2;
        TLineSeries(Chart1.Series[ss]).Pointer.VertSize:=2;
        TLineSeries(Chart1.Series[ss]).ZPosition:=0;
      end;
    end;

      ID:=strtoint(copy(series.Name,2,Pos('_', series.Name)-2));
      frmdm.Q.Locate('ID', ID, []);
      frmdm.QCruise.Locate('ID', frmdm.Q.FieldByName('CRUISE_ID').Value, []);
    end;
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
    if (series is TLineSeries) and (series.Active=true) then begin
      if (series = ASeries) and (TLineSeries(series).SeriesColor<>clRed) then begin
        TLineSeries(series).LinePen.Width:=2;
      end;
      if (series <> ASeries) and (TLineSeries(series).SeriesColor<>clRed) then begin
        TLineSeries(series).LinePen.Width:=1;
      end;
    end;
end;

procedure Tfrmprofile_plot_all.DPHAfterMouseMove(ATool: TChartTool;
  APoint: TPoint);
begin
  HighlightSeries(TDatapointHintTool(ATool).Series);
end;


procedure Tfrmprofile_plot_all.rbUnitsOriginalClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
   if rbUnitsOriginal.Checked=true then begin
     Ini := TIniFile.Create(IniFileName);
      try
       Ini.WriteInteger( 'main', 'units_default', 0)
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
       Ini.WriteInteger('main', 'units_default', 1)
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


procedure Tfrmprofile_plot_all.chkShowBestChange(Sender: TObject);
Var
  ss, cnt: integer;
  sName:string;
begin
 if chkShowBest.Checked=true then begin
  cnt:=0;
  for ss:=0 to Chart1.Series.Count-1 do begin
   sName:=Chart1.Series[ss].Name;
   if (Chart1.Series[ss].Active=true) then
    if (Pos('____B', sName)>0) then inc(cnt) else
     Chart1.Series[ss].Active:=false;
  end;
   Caption:=CurrentParTable+', '+inttostr(cnt)+' profiles';
   Application.ProcessMessages;
 end;

  if chkShowBest.Checked=false then FilterSources(chkShowBest);
end;


procedure Tfrmprofile_plot_all.FilterSources(Sender:TObject);
Var
  ss, pp, cnt: integer;
  sName, src_name, src_ss:string;
begin
   cnt:=0;
   for ss:=0 to Chart1.Series.Count-1 do begin
    sName:=Chart1.Series[ss].Name;
    src_ss:=copy(sName, Pos('_', sName)+1, (Pos('__', sName)-Pos('_', sName))-1);
     for pp:=0 to high(chkSourceList) do begin
      src_name:=copy(chkSourceList[pp].Caption, 1, Pos('(', chkSourceList[pp].Caption)-2);
      if (src_ss=src_name) then begin
        Chart1.Series[ss].Active:=chkSourceList[pp].Checked;
        Chart1.Series[ss].ZPosition:=mik;
      end;
     end;
     if Chart1.Series[ss].Active=true then inc(cnt);
   end;
   Caption:=CurrentParTable+', '+inttostr(cnt)+' profiles';
   Application.ProcessMessages;
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
  pUnitsContainer.Width);
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

  frmprofile_plot_all_open:=false;
end;


procedure Tfrmprofile_plot_all.FormDestroy(Sender: TObject);
begin
 Chart1.Series.Clear;
 chkSourceList:=nil;
end;

end.

