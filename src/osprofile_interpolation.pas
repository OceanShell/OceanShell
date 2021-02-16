unit osprofile_interpolation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, DBGrids, IniFiles, SQLDB, DB, Grids, Menus, Types,
  TAGraph, TATools, TASeries, TATypes, TAChartAxisUtils,
  TACustomSeries,  // for TChartSeries
  TAChartUtils,
  TAEnumerators;

type

  { Tfrmprofile_interpolation }

  Tfrmprofile_interpolation = class(TForm)
    Chart1: TChart;
    cbParameters: TComboBox;
    ChartToolset1: TChartToolset;
    DBGridInterpolated: TDBGrid;
    DBGridOriginal: TDBGrid;
    DPCT: TDataPointClickTool;
    DPHT: TDataPointHintTool;
    DS2: TDataSource;
    Splitter3: TSplitter;
    ZDT: TZoomDragTool;
    ZMWT: TZoomMouseWheelTool;
    DS1: TDataSource;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Qt: TSQLQuery;
    TabControl1: TTabControl;

    procedure FormShow(Sender: TObject);
    procedure cbParametersChange(Sender: TObject);
    procedure DPCTPointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure DBGridInterpolatedPrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DPHTAfterMouseMove(ATool: TChartTool; APoint: TPoint);
    procedure TabControl1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

  private
    function AddLineSeries (AChart: TChart; ATitle: String; AColor:TColor; sName:string):TLineSeries;
    procedure HighlightSeries(ASeries: TBasicChartSeries);
    procedure GetProfile(ID, prof_num, instr_id: integer);
  public
    procedure ChangeID(ID:integer);
  end;

var
  frmprofile_interpolation: Tfrmprofile_interpolation;
  current_index, mik: integer;

implementation

{$R *.lfm}

{ Tfrmprofile_interpolation }

uses osmain, dm;


function Tfrmprofile_interpolation.AddLineSeries(AChart: TChart;
  ATitle: String; AColor:TColor; sName:string): TLineSeries;
begin
 Result := TLineSeries.Create(AChart.Owner);
  with TLineSeries(Result) do begin
    Title := ATitle;
    ShowPoints := false;
    ShowLines := true;
    LinePen.Style := psSolid;
    LinePen.Width:=2;
    SeriesColor := AColor;
    Pointer.Style:=psCircle;
    Pointer.Brush.Color := AColor;
    Pointer.Pen.Color := AColor;
    Pointer.HorizSize:=3;
    Pointer.VertSize:=3;
    Pointer.Visible:=true;
    Name := sName;
    ToolTargets := [nptPoint, nptYList, nptCustom];
  end;
 AChart.AddSeries(Result);
end;


procedure Tfrmprofile_interpolation.FormShow(Sender: TObject);
Var
Ini:TIniFile;
IniSection: string;
begin
  Ini := TIniFile.Create(IniFileName);
  IniSection:=name;
  try
    Width :=Ini.ReadInteger(IniSection, 'Width',  600);
    Height:=Ini.ReadInteger(IniSection, 'Height', 600);
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


procedure Tfrmprofile_interpolation.cbParametersChange(Sender: TObject);
Var
  ID:integer;
begin
 ID:=frmdm.Q.FieldByName('ID').AsInteger;
  CurrentParTable:=cbParameters.Text;
 ChangeID(ID);
end;


procedure Tfrmprofile_interpolation.ChangeID(ID:integer);
var
  Ini:TIniFile;
  k, tt, prof_num, instr_id:integer;
  TRt:TSQLTransaction;
  Qt1, Qt2:TSQLQuery;
  Instr_name, TabName, SName, isbest:string;
  prof_best: boolean;
  lev, lev_m, lev_d, val1: real;
  LeftAxisTitle: string;
begin

if (CurrentParTable='') then CurrentParTable:=cbParameters.Items.Strings[0];

Caption:='Vertical interpolation: '+inttostr(ID);
Application.ProcessMessages;

Chart1.AxisList.LeftAxis.Title.Caption:='Depth, [m]';

mik:=-1;


(* checking for unique instruments and profile numbers *)
//if cbInstrument.ItemIndex=-1 then begin
 try
     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qt1:=TSQLQuery.Create(self);
     Qt1.Database:=frmdm.IBDB;
     Qt1.Transaction:=TRt;

     Qt2:=TSQLQuery.Create(self);
     Qt2.Database:=frmdm.IBDB;
     Qt2.Transaction:=TRt;


        with Qt1 do begin
         Close;
           Sql.Clear;
           SQL.Add(' SELECT DISTINCT(INSTRUMENT_ID), INSTRUMENT.NAME ');
           SQL.Add(' FROM INSTRUMENT, '+CurrentParTable);
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.INSTRUMENT_ID=INSTRUMENT.ID AND ');
           SQL.Add( CurrentParTable+'.ID=:ID ');
           ParamByName('ID').AsInteger:=ID;
         Open;
        end;

     if not Qt1.IsEmpty then begin
       TabControl1.Tabs.Clear;
     //  clbSeries.Items.Clear;

       while not Qt1.EOF do begin

        with Qt2 do begin
          Close;
            SQL.Clear;
            SQL.Add(' SELECT DISTINCT(PROFILE_NUMBER), PROFILE_BEST FROM ');
            SQL.Add( CurrentParTable);
            SQL.Add(' WHERE ');
            SQL.Add( CurrentParTable+'.ID=:ID AND INSTRUMENT_ID=:I_ID ');
            ParamByName('ID').AsInteger:=frmdm.Q.FieldByName('ID').AsInteger;
            ParamByName('I_ID').AsInteger:=Qt1.Fields[0].Value;
          Open;
        end;

        while not Qt2.eof do begin
          prof_num :=Qt2.Fields[0].AsInteger;
          prof_best:=Qt2.Fields[1].AsBoolean;

          TabName:=Qt1.Fields[1].Value+', Profile '+inttostr(prof_num);
          if prof_best=true then TabName:=TabName+' [BEST]';

          TabControl1.Tabs.Add(TabName);
         // clbSeries.Items.Add(TabName);
        //  inc(ss);
        //  clbSeries.Checked[ss]:=true;

         Qt2.Next;
        end;
        Qt2.Close;

       Qt1.Next;
     end;
 end;

 // No profiles for given parameters
 if Qt1.IsEmpty then begin
  TabControl1.Tabs.Clear;
  Chart1.Series.Clear;
  //clbSeries.Items.Clear;
  Qt1.Close;
  Qt.Close;
  exit;
 end;

 //
 if not Qt1.IsEmpty then begin
  Chart1.Series.Clear;
   for tt:=0 to TabControl1.Tabs.Count-1 do begin
     TabName:=TabControl1.Tabs.Strings[tt];
     isbest:='';
     if Pos('[', TabName) <> 0 then begin
        TabName:=copy(TabName, 1, Pos('[', TabName)-2);
        isbest:='__B';
     end;

     Instr_name:=trim(Copy(TabName, 1, Pos(',', TabName)-1));
      with Qt2 do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT ID FROM INSTRUMENT ');
        SQL.Add(' WHERE NAME=:INSTR_NAME ');
        ParamByName('INSTR_NAME').AsString:=INSTR_NAME;
       Open;
         instr_id:=Qt1.Fields[0].AsInteger;
       Close;
      end;

     Prof_num :=StrToInt(trim(Copy(TabName, Pos('Profile', TabName)+7, length(TabName))));

     sName:='s'+inttostr(instr_id)+'_'+inttostr(prof_num)+isbest;

     inc(mik);
    // showmessage(inttostr(mik));
     AddLineSeries (Chart1, sName, s_clr[mik+1], sName);

       with Qt2 do begin
         Close;
           Sql.Clear;
           SQL.Add(' SELECT LEV_M, VAL FROM ');
           SQL.Add( CurrentParTable);
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.ID=:ID AND ');
           SQL.Add( CurrentParTable+'.INSTRUMENT_ID=:INSTR_ID AND ');
           SQL.Add( CurrentParTable+'.PROFILE_NUMBER=:PROF_NUM');
           SQL.Add(' ORDER BY LEV_DBAR, LEV_M');
           ParamByName('ID').AsInteger:=ID;
           ParamByName('INSTR_ID').AsInteger:=INSTR_ID;
           ParamByName('PROF_NUM').AsInteger:=PROF_NUM;
         Open;
        end;

       while not Qt2.eof do begin
         lev_m := Qt2.FieldByName('LEV_M').AsVariant;
         val1  := Qt2.FieldByName('VAL').AsFloat;

         TLineSeries(Chart1.Series[mik]).AddXY(val1,lev_m);

         Qt2.Next;
       end;
   end;
 end;

 finally
   Qt1.Close;
   Qt2.Close;
   Trt.Commit;
   Qt1.Free;
   Qt2.Close;
   Trt.Free;
 end;

 if TabControl1.Tabs.Count>0 then begin
    TabControl1.TabIndex:=0;
    TabControl1.OnChange(self);
 end;
end;


procedure Tfrmprofile_interpolation.TabControl1Change(Sender: TObject);
Var
  TabName, Instr_name, SName, isbest: string;
  Prof_num, instr_id, ss: integer;
  TRt:TSQLTransaction;
  Qt1:TSQLQuery;
begin
  TabName:=TabControl1.Tabs.Strings[TabControl1.TabIndex];
  if Pos('[', TabName) <> 0 then begin
    TabName:=copy(TabName, 1, Pos('[', TabName)-2);
    isbest:='__B';
  end else isbest:='';

  Instr_name:=trim(Copy(TabName, 1, Pos(',', TabName)-1));
  try
     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qt1:=TSQLQuery.Create(self);
     Qt1.Database:=frmdm.IBDB;
     Qt1.Transaction:=TRt;

      with Qt1 do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT ID FROM INSTRUMENT ');
        SQL.Add(' WHERE NAME=:INSTR_NAME ');
        ParamByName('INSTR_NAME').AsString:=INSTR_NAME;
       Open;
         instr_id:=Qt1.Fields[0].AsInteger;
       Close;
      end;
  finally
    Trt.Commit;
    Qt1.Free;
    Trt.Free;
  end;

  Prof_num :=StrToInt(trim(Copy(TabName, Pos('Profile', TabName)+7, length(TabName))));
  SName:='s'+inttostr(instr_id)+'_'+inttostr(prof_num)+isbest;

  for ss:=0 to Chart1.Series.Count-1 do
      if Chart1.Series[ss].Name=sName then begin
       // showmessage('here');
        TLineSeries(Chart1.Series[ss]).LinePen.Width:=3;
        TLineSeries(Chart1.Series[ss]).Pointer.HorizSize:=4;
        TLineSeries(Chart1.Series[ss]).Pointer.VertSize:=4;
        TLineSeries(Chart1.Series[ss]).ZPosition:=mik;
      end else begin
        TLineSeries(Chart1.Series[ss]).LinePen.Width:=2;
        TLineSeries(Chart1.Series[ss]).Pointer.HorizSize:=3;
        TLineSeries(Chart1.Series[ss]).Pointer.VertSize:=3;
        TLineSeries(Chart1.Series[ss]).ZPosition:=0;
      end;

  GetProfile(frmdm.Q.FieldByName('ID').AsInteger, prof_num, Instr_id);

end;


procedure Tfrmprofile_interpolation.GetProfile(ID, PROF_NUM, instr_id: integer);
Var
  Ini: TIniFile;
  count, items_id, k, LNum:integer;
  Avg, Sum, Dif2, ValX, SD, ValX_Sum:real;
  lev, val, avg_lev, avg_val:real;
  val_sum, lev_sum, lev_min, lev_max, val_min, val_max:real;
  units, tbl, depth_units_str:string;
  Depth_units: integer;

  TRt:TSQLTransaction;
  Qtt:TSQLQuery;
begin
  Ini := TIniFile.Create(IniFileName);
  try
    Depth_units:=Ini.ReadInteger ( 'main', 'Depth_units', 0);
  finally
    ini.Free;
  end;

  Items_id:=cbParameters.ItemIndex;

  try
  Qt.DisableControls;

        with Qt do begin
         Close;
           Sql.Clear;
           SQL.Add(' SELECT LEV_M, VAL FROM ');
           SQL.Add( CurrentParTable);
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.ID=:ID AND ');
           SQL.Add( CurrentParTable+'.INSTRUMENT_ID=:INSTR_ID AND ');
           SQL.Add( CurrentParTable+'.PROFILE_NUMBER=:PROF_NUM');
           SQL.Add(' ORDER BY LEV_DBAR, LEV_M');
           ParamByName('ID').AsInteger:=ID;
           ParamByName('INSTR_ID').AsInteger:=INSTR_ID;
           ParamByName('PROF_NUM').AsInteger:=PROF_NUM;
          // showmessage(qt.SQL.Text);
         Open;
        end;

  if Qt.IsEmpty=false then begin
    Val_Sum:=0; Lev_sum:=0;
    Val_min:=10000; Val_max:=-9999;
    Lev_min:=10000; Lev_max:=-9999;

    Qt.First;
    while not Qt.eof do begin
       Lev:=Qt.FieldByName('LEV_M').AsFloat;
      Val:=Qt.FieldByName('VAL').AsFloat;
      //Flag_:=Qt.FieldByName('PQF2').AsFloat;

      Val_sum:=Val_sum+Val;
      Lev_sum:=Lev_sum+Lev;

      if lev>lev_max then lev_max:=lev;
      if lev<lev_min then lev_min:=lev;
      if val>val_max then val_max:=val;
      if val<val_min then val_min:=val;

     // Series1.AddXY(val,lev);

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

   //  showmessage('here3');

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
           SQL.Add( CurrentParTable+'.INSTRUMENT_ID=:INSTR_ID AND ');
           SQL.Add( CurrentParTable+'.PROFILE_NUMBER=:PROF_NUM AND ');
           SQL.Add( CurrentParTable+'.ID=:ID ');
           ParamByName('ID').AsInteger:=ID;
           ParamByName('INSTR_ID').AsInteger:=INSTR_ID;
           ParamByName('PROF_NUM').AsInteger:=PROF_NUM;
         Open;
           Units:=Qtt.Fields[0].AsString;
         Close;
        end;
   finally
     Trt.Commit;
     Qtt.Free;
     Trt.Free;
   end;
    // showmessage('here4');
  end;
  finally
    Qt.EnableControls;
  end;
end;

procedure Tfrmprofile_interpolation.DBGridInterpolatedPrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
  if gdRowHighlight in AState then begin
    TDBGrid(sender).Canvas.Brush.Color := clNavy;
    TDBGrid(sender).Canvas.Font.Color:= clYellow;
    TDBGrid(sender).Canvas.Font.Style:=[fsBold];
  end;
end;

procedure Tfrmprofile_interpolation.DPHTAfterMouseMove(ATool: TChartTool;
  APoint: TPoint);
begin
    HighlightSeries(TDatapointHintTool(ATool).Series);
end;

procedure Tfrmprofile_interpolation.DPCTPointClick(
  ATool: TChartTool; APoint: TPoint);
Var
 k,pp: integer;
 tool: TDataPointClicktool;
 series: TLineSeries;
 pointer: TSeriesPointer;
 instr_name, id, prof_num: string;
 instr_id: integer;

 TRt:TSQLTransaction;
 Qt1:TSQLQuery;
begin
  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);

    INSTR_ID:=StrToInt(Copy(series.Name, 2, Pos('_', Series.Name)-2));

  //  showmessage(inttostr(instr_ID));

    try
     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qt1:=TSQLQuery.Create(self);
     Qt1.Database:=frmdm.IBDB;
     Qt1.Transaction:=TRt;

      with Qt1 do begin
       Close;
        SQL.Clear;
        SQL.Add(' SELECT NAME FROM INSTRUMENT ');
        SQL.Add(' WHERE ID=:ID ');
        ParamByName('ID').AsInteger:=INSTR_ID;
       Open;
         instr_name:=Qt1.Fields[0].AsString;
       Close;
      end;
    finally
      Trt.Commit;
      Qt1.Free;
      TrT.Free;
    end;


    Prof_num:=Copy(series.name, Pos('_', Series.Name)+1, length(series.name));

    if Pos('__B', series.name)<>0 then
      Prof_num:=StringReplace(Prof_num, '__B', ' [BEST]', []);

  //  showmessage(prof_num);

    TabControl1.TabIndex:=TabControl1.IndexOfTabWithCaption(INSTR_NAME+', Profile '+Prof_num);
    TabControl1.OnChange(self);

    if (tool.PointIndex<>-1) then begin
        Qt.Locate('LEV_M', series.YValue[tool.PointIndex], []);

     current_index:=tool.PointIndex;
    end;
  end;
end;


procedure Tfrmprofile_interpolation.HighlightSeries(ASeries: TBasicChartSeries);
var
  series: TCustomChartSeries;
begin
  for series in CustomSeries(Chart1) do
    if series is TLineSeries then
    begin
      if (series = ASeries) then begin
        TLineSeries(series).LinePen.Width:=3;
        TLineSeries(series).Pointer.HorizSize:=4;
        TLineSeries(series).Pointer.VertSize:=4;
        TLineSeries(series).ZPosition:=mik;
      end;
      if (series <> ASeries) then begin
        TLineSeries(series).LinePen.Width:=2;
        TLineSeries(series).Pointer.HorizSize:=3;
        TLineSeries(series).Pointer.VertSize:=3;
        TLineSeries(series).ZPosition:=0;
      end;
    end;
end;


procedure Tfrmprofile_interpolation.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
Var
  Ini: TIniFile;
  IniSection:string;
begin
 Ini := TIniFile.Create(IniFileName);
 IniSection:=name;
  try
    Ini.WriteInteger (IniSection, 'Width',  Width);
    Ini.WriteInteger (IniSection, 'Height', Height);
  finally
   Ini.Free;
  end;

  frmprofile_interpolation_open:=false;
end;



end.

