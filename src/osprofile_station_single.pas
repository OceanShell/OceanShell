unit osprofile_station_single;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, DBGrids, IniFiles, SQLDB, DB, Grids, Menus, Types,
  TAGraph, TATools, TASeries, TATypes, TAChartAxisUtils,
  TACustomSeries,  // for TChartSeries
  TAChartUtils,
  TAEnumerators, TALegendPanel, TAChartListbox;

type

  { Tfrmprofile_station_single }

  Tfrmprofile_station_single = class(TForm)
    btnAdd: TToolButton;
    btnCommit: TToolButton;
    btnDelete: TToolButton;
    Chart1: TChart;
    cbParameters: TComboBox;
    clbSeries: TChartListbox;
    ChartToolset1: TChartToolset;
    DPCT: TDataPointClickTool;
    DPHT: TDataPointHintTool;
    MenuItem1: TMenuItem;
    btnBestProfile: TMenuItem;
    Splitter2: TSplitter;
    ZDT: TZoomDragTool;
    ZMWT: TZoomMouseWheelTool;
    DS: TDataSource;
    PM: TPopupMenu;
    DBGridSingleProfile: TDBGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    SetFlagAbove: TMenuItem;
    SetFlagBelow: TMenuItem;
    Splitter1: TSplitter;
    Qt: TSQLQuery;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    TabControl1: TTabControl;
    ToolBar1: TToolBar;
    ToolButton4: TToolButton;

    procedure FormShow(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnBestProfileClick(Sender: TObject);
    procedure btnCommitClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure cbParametersChange(Sender: TObject);
    procedure DPCTPointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure DBGridSingleProfilePrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DBGridSingleProfileSelectEditor(Sender: TObject; Column: TColumn;
      var Editor: TWinControl);
    procedure DPHTAfterMouseMove(ATool: TChartTool; APoint: TPoint);
    procedure SetFlagAboveClick(Sender: TObject);
    procedure SetFlagBelowClick(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

  private
    function AddLineSeries (AChart: TChart; ATitle: String; AColor:TColor; sName:string):TLineSeries;
    procedure HighlightSeries(ASeries: TBasicChartSeries);
    procedure GetProfile(ID, PROF_NUM: integer; INSTR_NAME: string);
  public
    procedure ChangeID(ID:integer);
  end;

var
  frmprofile_station_single: Tfrmprofile_station_single;
  current_index, mik: integer;

implementation

{$R *.lfm}

{ Tfrmprofile_station_single }

uses osmain, dm;


function Tfrmprofile_station_single.AddLineSeries(AChart: TChart;
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


procedure Tfrmprofile_station_single.FormShow(Sender: TObject);
Var
Ini:TIniFile;
IniSection: string;
k:integer;

TRt:TSQLTransaction;
Qtt:TSQLQuery;
begin
  Ini := TIniFile.Create(IniFileName);
  IniSection:=name;
  try
    Width :=Ini.ReadInteger(IniSection, 'Width',  600);
    Height:=Ini.ReadInteger(IniSection, 'Height', 600);

    With DBGridSingleProfile do begin
     Columns[0].Width :=Ini.ReadInteger( IniSection, 'DBGridCol00',  70);
     Columns[1].Width :=Ini.ReadInteger( IniSection, 'DBGridCol01',  70);
     Columns[2].Width :=Ini.ReadInteger( IniSection, 'DBGridCol02',  70);
     Columns[3].Width :=Ini.ReadInteger( IniSection, 'DBGridCol03',  70);
     Columns[4].Width :=Ini.ReadInteger( IniSection, 'DBGridCol04',  70);
     Columns[5].Width :=Ini.ReadInteger( IniSection, 'DBGridCol05',  70);
     Columns[6].Width :=Ini.ReadInteger( IniSection, 'DBGridCol06',  70);
     Columns[7].Width :=Ini.ReadInteger( IniSection, 'DBGridCol07',  70);
    end;

  finally
     Ini.Free;
  end;
cbParameters.Items:=frmosmain.ListBox1.Items;
current_index:=-1;

if CurrentParTable<>'' then
  cbParameters.ItemIndex:=cbParameters.Items.IndexOf(CurrentParTable) else
  cbParameters.ItemIndex:=0;

DBGridSingleProfile.Columns[3].PickList.Clear;
DBGridSingleProfile.Columns[4].PickList.Clear;
DBGridSingleProfile.Columns[5].PickList.Clear;

// QF pick lists
for k:=0 to 8 do begin
 DBGridSingleProfile.Columns[3].PickList.Add(IntToStr(k));
 DBGridSingleProfile.Columns[4].PickList.Add(IntToStr(k));
 DBGridSingleProfile.Columns[5].PickList.Add(IntToStr(k));
end;

try
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qtt:=TSQLQuery.Create(self);
  Qtt.Database:=frmdm.IBDB;
  Qtt.Transaction:=TRt;

    with Qtt do begin
     Close;
      Sql.Clear;
      SQL.Add(' SELECT ID FROM UNITS ORDER BY ID');
     Open;
    end;

    DBGridSingleProfile.Columns[7].PickList.Clear;
    while not Qtt.EOF do begin
      DBGridSingleProfile.Columns[7].PickList.Add(IntToStr(Qtt.Fields[0].AsInteger));
     Qtt.Next;
    end;
    Qtt.close;
finally
 Trt.Commit;
 Qtt.Free;
 Trt.Free;
end;


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


procedure Tfrmprofile_station_single.ChangeID(ID:integer);
var
  k, tt, prof_num:integer;
  TRt:TSQLTransaction;
  Qt1, Qt2:TSQLQuery;
  Instr_name, TabName, SName, isbest:string;
  prof_best: boolean;
  lev_m, lev_d, val1: real;
  S_clr:Array[1..16] of TColor;
begin

if (CurrentParTable='') then CurrentParTable:=cbParameters.Items.Strings[0];

Caption:='Single parameter: '+inttostr(ID);
Application.ProcessMessages;

mik:=-1;

S_clr[1]:=clBlue;
S_clr[2]:=clRed;
S_clr[3]:=clFuchsia;
S_clr[4]:=clMaroon;
S_clr[5]:=clBlack;
S_clr[6]:=clGreen;
S_clr[7]:=clNavy;
S_clr[8]:=clPurple;
S_clr[9]:=clTeal;
S_clr[10]:=clOlive;
S_clr[11]:=clGray;
S_clr[12]:=clSilver;
S_clr[13]:=clLime;
S_clr[14]:=clYellow;
S_clr[15]:=clAqua;
S_clr[16]:=clLtGray;


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
       clbSeries.Items.Clear;

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
  clbSeries.Items.Clear;
  toolbar1.Enabled:=false;
  Qt1.Close;
  Qt.Close;

  for k:=1 to StatusBar1.Panels.Count-1 do StatusBar1.Panels.Items[k].Text:='';
  for k:=1 to StatusBar2.Panels.Count-1 do StatusBar2.Panels.Items[k].Text:='';
  exit;
 end;



 //
 if not Qt1.IsEmpty then begin
  Chart1.Series.Clear;
  toolbar1.Enabled:=true;
   for tt:=0 to TabControl1.Tabs.Count-1 do begin
     TabName:=TabControl1.Tabs.Strings[tt];
     isbest:='';
     if Pos('[', TabName) <> 0 then begin
        TabName:=copy(TabName, 1, Pos('[', TabName)-2);
        isbest:='__B';
     end;

     Instr_name:=trim(Copy(TabName, 1, Pos(',', TabName)-1));
     Prof_num :=StrToInt(trim(Copy(TabName, Pos('Profile', TabName)+7, length(TabName))));

     sName:=instr_name+'_'+inttostr(prof_num)+isbest;

     inc(mik);
    // showmessage(inttostr(mik));
     AddLineSeries (Chart1, sName, s_clr[mik+1], sName);

       with Qt2 do begin
         Close;
           Sql.Clear;
           SQL.Add(' SELECT * FROM ');
           SQL.Add( CurrentParTable);
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.ID=:ID AND ');
           SQL.Add( CurrentParTable+'.INSTRUMENT_ID IN ');
           SQL.Add('(SELECT ID FROM INSTRUMENT WHERE ');
           SQL.Add('INSTRUMENT.NAME=:INSTR_NAME) AND ');
           SQL.Add( CurrentParTable+'.PROFILE_NUMBER=:PROF_NUM');
           SQL.Add(' ORDER BY LEV_DBAR, LEV_M');
           ParamByName('ID').AsInteger:=ID;
           ParamByName('INSTR_NAME').AsString:=INSTR_NAME;
           ParamByName('PROF_NUM').AsInteger:=PROF_NUM;
         Open;
        end;

       while not Qt2.eof do begin
         lev_m := Qt2.FieldByName('LEV_M').AsVariant;
         lev_d := Qt2.FieldByName('LEV_DBAR').AsVariant;
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


procedure Tfrmprofile_station_single.TabControl1Change(Sender: TObject);
Var
  TabName, Instr_name, SName, isbest: string;
  Prof_num, ss: integer;
begin
  TabName:=TabControl1.Tabs.Strings[TabControl1.TabIndex];
  if Pos('[', TabName) <> 0 then begin
    TabName:=copy(TabName, 1, Pos('[', TabName)-2);
    isbest:='__B';
  end else isbest:='';

  Instr_name:=trim(Copy(TabName, 1, Pos(',', TabName)-1));
  Prof_num :=StrToInt(trim(Copy(TabName, Pos('Profile', TabName)+7, length(TabName))));
  SName:=Instr_name+'_'+inttostr(prof_num)+isbest;

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

  GetProfile(frmdm.Q.FieldByName('ID').AsInteger, prof_num, Instr_name);

end;


procedure Tfrmprofile_station_single.GetProfile(ID, PROF_NUM: integer; INSTR_NAME:string);
Var
  Ini: TIniFile;
  count, items_id, k, LNum:integer;
  Avg, Sum, Dif2, ValX, SD, ValX_Sum:real;
  lev, val, flag_, avg_lev, avg_val:real;
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
           SQL.Add(' SELECT * FROM ');
           SQL.Add( CurrentParTable);
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.ID=:ID AND ');
           SQL.Add( CurrentParTable+'.INSTRUMENT_ID IN ');
           SQL.Add('(SELECT ID FROM INSTRUMENT WHERE ');
           SQL.Add('INSTRUMENT.NAME=:INSTR_NAME) AND ');
           SQL.Add( CurrentParTable+'.PROFILE_NUMBER=:PROF_NUM');
           SQL.Add(' ORDER BY LEV_DBAR, LEV_M');
           ParamByName('ID').AsInteger:=ID;
           ParamByName('INSTR_NAME').AsString:=INSTR_NAME;
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
           SQL.Add(CurrentParTable+ ', UNITS, INSTRUMENT ');
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.UNITS_ID=UNITS.ID AND ');
           SQL.Add( CurrentParTable+'.INSTRUMENT_ID IN ');
           SQL.Add('(SELECT ID FROM INSTRUMENT WHERE ');
           SQL.Add('INSTRUMENT.NAME=:INSTR_NAME) AND ');
           SQL.Add( CurrentParTable+'.PROFILE_NUMBER=:PROF_NUM AND ');
           SQL.Add( CurrentParTable+'.ID=:ID ');
           ParamByName('ID').AsInteger:=ID;
           ParamByName('INSTR_NAME').AsString:=INSTR_NAME;
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

  end;
  finally
    Qt.EnableControls;
  end;


//  showmessage('here6');

btnCommit.Enabled:=true;
Application.ProcessMessages;

end;

procedure Tfrmprofile_station_single.DBGridSingleProfilePrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
  if gdRowHighlight in AState then begin
    TDBGrid(sender).Canvas.Brush.Color := clNavy;
    TDBGrid(sender).Canvas.Font.Color:= clYellow;
    TDBGrid(sender).Canvas.Font.Style:=[fsBold];
  end;
end;

procedure Tfrmprofile_station_single.DBGridSingleProfileSelectEditor(
  Sender: TObject; Column: TColumn; var Editor: TWinControl);
begin
  if (Column.Index = 3) or
     (Column.Index = 4) or
     (Column.Index = 5) or
     (Column.Index = 7) or
     (Column.Index = 8) then begin
       if (Editor is TCustomComboBox) then
        with Editor as TCustomComboBox do
          Style := csDropDownList;
  end;
end;

procedure Tfrmprofile_station_single.DPHTAfterMouseMove(ATool: TChartTool;
  APoint: TPoint);
begin
    HighlightSeries(TDatapointHintTool(ATool).Series);
end;

procedure Tfrmprofile_station_single.DPCTPointClick(
  ATool: TChartTool; APoint: TPoint);
Var
 k,pp: integer;
 tool: TDataPointClicktool;
 series: TLineSeries;
 pointer: TSeriesPointer;
 instr_name, id, prof_num: string;
begin
  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);

    INSTR_NAME:=Copy(series.Name, 1, Pos('_', Series.Name)-1);
    Prof_num:=Copy(series.name, Pos('_', Series.Name)+1, length(series.name));

    if Pos('__B', series.name)<>0 then
      Prof_num:=StringReplace(Prof_num, '__B', ' [BEST]', []);

    TabControl1.TabIndex:=TabControl1.IndexOfTabWithCaption(INSTR_NAME+', Profile '+Prof_num);
    TabControl1.OnChange(self);

    if (tool.PointIndex<>-1) then begin
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


procedure Tfrmprofile_station_single.btnCommitClick(Sender: TObject);
Var
  ID, Instr_id, Prof_num:integer;
  TabName, Instr_name:string;
begin
  ID:=frmdm.Q.FieldByName('ID').AsInteger;

  TabName:=TabControl1.Tabs[TabControl1.TabIndex];
  if Pos('[', TabName) <> 0 then TabName:=copy(TabName, 1, Pos('[', TabName)-2);

  Instr_name:=Copy(tabName, 1, Pos(',', TabName)-1);
  Prof_num :=StrToInt(trim(Copy(TabName, Pos('Profile', TabName)+7, length(TabName))));

  try
   Qt.DisableControls;

     try
      with frmdm.q1 do begin
        Close;
          Sql.Clear;
          SQL.Add(' SELECT ID FROM INSTRUMENT WHERE NAME=:INSTR ');
          ParamByName('INSTR').Value:=INSTR_NAME;
        Open;
         Instr_id:=frmdm.q1.Fields[0].AsInteger;
        Close;
      end;

       with frmdm.q1 do begin
         Close;
           Sql.Clear;
           SQL.Add(' DELETE FROM ');
           SQL.Add(CurrentParTable);
           SQL.Add(' WHERE ');
           SQL.Add(' ID=:ID AND PROFILE_NUMBER=:P_NUM AND ');
           SQL.Add(' INSTRUMENT_ID=:ID_I ');
           ParamByName('ID').AsInteger:=ID;
           ParamByName('ID_I').AsInteger:=Instr_ID;
           ParamByName('P_NUM').AsInteger:=Prof_num;
         ExecSQL;
         Close;
        end;
     frmdm.TR.CommitRetaining;

     Qt.First;
     while not Qt.Eof do begin
      with frmdm.q1 do begin
       Close;
        Sql.Clear;
        SQL.Add('insert into');
        SQL.Add(CurrentParTable);
        SQL.Add(' (ID, lev_m, lev_dbar, val, pqf1, pqf2, sqf, ');
        SQL.Add(' bottle_number, units_id, instrument_id, PROFILE_NUMBER) ');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :lev_m, :lev_dbar, :val, :pqf1, :pqf2, :sqf, ');
        SQL.Add(' :bottle_number, :units_id, :instrument_id, :PROFILE_NUMBER) ');
        ParamByName('ID').Value:=Qt.FieldByName('ID').Value;
        ParamByName('LEV_M').Value:=Qt.FieldByName('LEV_M').Value;
        ParamByName('LEV_DBAR').Value:=Qt.FieldByName('LEV_DBAR').Value;
        ParamByName('VAL').Value:=Qt.FieldByName('VAL').Value;
        ParamByName('PQF1').Value:=Qt.FieldByName('PQF1').Value;
        ParamByName('PQF2').Value:=Qt.FieldByName('PQF2').Value;
        ParamByName('SQF').Value:=Qt.FieldByName('SQF').Value;
        ParamByName('BOTTLE_NUMBER').Value:=Qt.FieldByName('BOTTLE_NUMBER').Value;
        ParamByName('UNITS_ID').Value:=Qt.FieldByName('UNITS_ID').Value;
        ParamByName('INSTRUMENT_ID').Value:=Instr_id;
        ParamByName('PROFILE_NUMBER').Value:=Prof_num;
       ExecSQL;
      end;
     Qt.Next;
   end;

   frmdm.TR.CommitRetaining;
   except
    On E :Exception do begin
     ShowMessage(E.Message);
     frmdm.TR.RollbackRetaining;
    end;
   end;

   finally
     Qt.EnableControls;
   end;
 ChangeID(ID);
end;


procedure Tfrmprofile_station_single.btnBestProfileClick(Sender: TObject);
Var
  TabName, Instr_name:string;
  ID, Prof_num, prof_cur, instr_id: integer;
  TRt:TSQLTransaction;
  Qt1:TSQLQuery;
begin
  TabName:=TabControl1.Tabs.Strings[TabControl1.TabIndex];
  if Pos('[', TabName) <> 0 then
   if MessageDlg('This profile is already the BEST!', mtWarning, [mbOk], 0)=mrOk then exit;

  Instr_name:=trim(Copy(TabName, 1, Pos(',', TabName)-1));
  Prof_num :=StrToInt(trim(Copy(TabName, Pos('Profile', TabName)+7, length(TabName))));
  ID:=frmdm.Q.FieldByName('ID').AsInteger;

      with frmdm.q1 do begin
        Close;
          Sql.Clear;
          SQL.Add(' SELECT ID FROM INSTRUMENT WHERE NAME=:INSTR ');
          ParamByName('INSTR').Value:=INSTR_NAME;
        Open;
         Instr_id := frmdm.q1.Fields[0].AsInteger;
        Close;
      end;

      with frmdm.q1 do begin
        Close;
          SQL.Clear;
          SQL.Add(' UPDATE '+CurrentParTable);
          SQL.Add(' SET PROFILE_BEST=FALSE ');
          SQL.Add(' WHERE '+CurrentParTable+'.ID=:ID ');
          ParambyName('ID').AsInteger:=ID;
        ExecSQL;
      end;
      frmdm.TR.CommitRetaining;

      with frmdm.q1 do begin
        Close;
          SQL.Clear;
          SQL.Add(' UPDATE '+CurrentParTable);
          SQL.Add(' SET PROFILE_BEST=TRUE WHERE ');
          SQL.Add( CurrentParTable+'.ID=:ID AND ');
          SQL.Add( CurrentParTable+'.INSTRUMENT_ID=:I_ID AND ');
          SQL.Add( CurrentParTable+'.PROFILE_NUMBER=:PROF_NUM ');
          ParamByName('ID').AsInteger:=ID;
          ParamByName('I_ID').Value:=INSTR_ID;
          ParamByName('PROF_NUM').Value:=PROF_NUM;
        ExecSQL;
      end;
      frmdm.TR.CommitRetaining;

  ChangeID(ID);
end;



procedure Tfrmprofile_station_single.HighlightSeries(ASeries: TBasicChartSeries);
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


procedure Tfrmprofile_station_single.FormClose(Sender: TObject;
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

    With DBGridSingleProfile do begin
     Ini.WriteInteger( IniSection, 'DBGridCol00',  Columns[0].Width);
     Ini.WriteInteger( IniSection, 'DBGridCol01',  Columns[1].Width);
     Ini.WriteInteger( IniSection, 'DBGridCol02',  Columns[2].Width);
     Ini.WriteInteger( IniSection, 'DBGridCol03',  Columns[3].Width);
     Ini.WriteInteger( IniSection, 'DBGridCol04',  Columns[4].Width);
     Ini.WriteInteger( IniSection, 'DBGridCol05',  Columns[5].Width);
     Ini.WriteInteger( IniSection, 'DBGridCol06',  Columns[6].Width);
     Ini.WriteInteger( IniSection, 'DBGridCol07',  Columns[7].Width);
    end;

  finally
   Ini.Free;
  end;

  frmprofile_station_single_open:=false;
end;



end.

