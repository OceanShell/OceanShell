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
    cbInstrument: TComboBox;
    cbProfileNumber: TComboBox;
    DS: TDataSource;
    PM: TPopupMenu;
    Series1: TLineSeries;
    DBGridSingleProfile: TDBGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    SetFlagAbove: TMenuItem;
    SetFlagBelow: TMenuItem;
    Splitter1: TSplitter;
    Qt: TSQLQuery;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    btnSetProfNum1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;

    procedure btnAddClick(Sender: TObject);
    procedure btnCommitClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure cbInstrumentChange(Sender: TObject);
    procedure cbParametersChange(Sender: TObject);
    procedure cbProfileNumberChange(Sender: TObject);
    procedure ChartToolset1DataPointClickTool1PointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure DBGridSingleProfilePrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DBGridSingleProfileSelectEditor(Sender: TObject; Column: TColumn;
      var Editor: TWinControl);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SetFlagAboveClick(Sender: TObject);
    procedure SetFlagBelowClick(Sender: TObject);

  private
    procedure GetProfile(ID, INSTR_ID, PROF_NUM : integer);
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
     Columns[8].Width :=Ini.ReadInteger( IniSection, 'DBGridCol08',  70);
     Columns[9].Width :=Ini.ReadInteger( IniSection, 'DBGridCol09',  70);
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

    with Qtt do begin
     Close;
      Sql.Clear;
      SQL.Add(' SELECT ID FROM INSTRUMENT ORDER BY ID ');
     Open;
    end;

    DBGridSingleProfile.Columns[8].PickList.Clear;
    while not Qtt.EOF do begin
      DBGridSingleProfile.Columns[8].PickList.Add(IntToStr(Qtt.Fields[0].AsInteger));
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
     //Trt.

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
        SQL.Add(' (ID, lev_m, lev_dbar, val, pqf1, pqf2, sqf, ');
        SQL.Add(' bottle_number, units_id, instrument_id) ');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :lev_m, :lev_dbar, :val, :pqf1, :pqf2, :sqf, ');
        SQL.Add(' :bottle_number, :units_id, :instrument_id) ');
        ParamByName('ID').Value:=Qt.FieldByName('ID').Value;
        ParamByName('LEV_M').Value:=Qt.FieldByName('LEV_M').Value;
        ParamByName('LEV_DBAR').Value:=Qt.FieldByName('LEV_DBAR').Value;
        ParamByName('VAL').Value:=Qt.FieldByName('VAL').Value;
        ParamByName('PQF1').Value:=Qt.FieldByName('PQF1').Value;
        ParamByName('PQF2').Value:=Qt.FieldByName('PQF2').Value;
        ParamByName('SQF').Value:=Qt.FieldByName('SQF').Value;
        ParamByName('BOTTLE_NUMBER').Value:=Qt.FieldByName('BOTTLE_NUMBER').Value;
        ParamByName('UNITS_ID').Value:=Qt.FieldByName('UNITS_ID').Value;
        ParamByName('INSTRUMENT_ID').Value:=Qt.FieldByName('INSTRUMENT_ID').Value;
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
  k:integer;
  TRt:TSQLTransaction;
  Qtt:TSQLQuery;
begin

if (CurrentParTable='') then CurrentParTable:=cbParameters.Items.Strings[0];

(* checking for unique instruments and profile numbers *)
//if cbInstrument.ItemIndex=-1 then begin
 try
     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qtt:=TSQLQuery.Create(self);
     Qtt.Database:=frmdm.IBDB;
     Qtt.Transaction:=TRt;

        with Qtt do begin
         Close;
           Sql.Clear;
           SQL.Add(' SELECT DISTINCT(INSTRUMENT_ID) FROM ');
           SQL.Add( CurrentParTable);
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.ID=:ID ');
           ParamByName('ID').AsInteger:=ID;
         Open;
        end;

       cbInstrument.Clear;
       while not Qtt.EOF do begin
         cbInstrument.Items.Add(IntToStr(Qtt.Fields[0].AsInteger));
         Qtt.Next;
       end;
     if cbInstrument.Items.Count>0 then cbInstrument.ItemIndex:=0;
 finally
   Qtt.Close;
   Trt.Commit;
   Qtt.Free;
   Trt.Free;
 end;

 (* Exit if there's no profile *)
  if (cbInstrument.ItemIndex=-1) then begin
   Series1.Clear;
   Qt.Close;
   for k:=0 to StatusBar1.Panels.Count-1 do StatusBar1.Panels.Items[k].Text:='';
   for k:=0 to StatusBar2.Panels.Count-1 do StatusBar2.Panels.Items[k].Text:='';
   exit;
  end;

  cbInstrument.OnChange(self);
end;


procedure Tfrmprofile_station_single.cbInstrumentChange(Sender: TObject);
var
TRt:TSQLTransaction;
Qtt:TSQLQuery;
begin
try
  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qtt:=TSQLQuery.Create(self);
  Qtt.Database:=frmdm.IBDB;
  Qtt.Transaction:=TRt;

  with Qtt do begin
   Close;
    Sql.Clear;
    SQL.Add(' SELECT DISTINCT(PROFILE_NUMBER) FROM ');
    SQL.Add( CurrentParTable);
    SQL.Add(' WHERE ');
    SQL.Add( CurrentParTable+'.ID=:ID ');
    ParamByName('ID').AsInteger:=frmdm.Q.FieldByName('ID').AsInteger;
   Open;
  end;

  cbProfileNumber.Clear;
  while not Qtt.EOF do begin
   cbProfileNumber.Items.Add(IntToStr(Qtt.Fields[0].AsInteger));
   Qtt.Next;
  end;
finally
 Qtt.Close;
 Trt.Commit;
 Qtt.Free;
 Trt.Free;
end;


  if cbProfileNumber.Items.Count>0 then cbProfileNumber.ItemIndex:=0;

  Caption:='Single parameter: '+inttostr(frmdm.Q.FieldByName('ID').AsInteger)+
           ', Instruments: '+Inttostr(cbInstrument.Items.Count)+
           ', Profiles: '+IntToStr(cbProfileNumber.Items.Count);

   GetProfile(frmdm.Q.FieldByName('ID').AsInteger,
              StrToInt(cbInstrument.Text),
              StrToInt(cbProfileNumber.Text));
end;


procedure Tfrmprofile_station_single.cbProfileNumberChange(Sender: TObject);
begin
     GetProfile(frmdm.Q.FieldByName('ID').AsInteger,
              StrToInt(cbInstrument.Text),
              StrToInt(cbProfileNumber.Text));
end;


procedure Tfrmprofile_station_single.GetProfile(ID, INSTR_ID, PROF_NUM : integer);
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
  Series1.Clear;

  Ini := TIniFile.Create(IniFileName);
  try
    Depth_units:=Ini.ReadInteger ( 'main', 'Depth_units', 0);
  finally
    ini.Free;
  end;

//  showmessage('here');

  Items_id:=cbParameters.ItemIndex;

  //  showmessage('here2');

        with Qt do begin
         Close;
           Sql.Clear;
           SQL.Add(' SELECT * FROM ');
           SQL.Add( CurrentParTable);
           SQL.Add(' WHERE ');
           SQL.Add( CurrentParTable+'.ID=:ID AND ');
           SQL.Add( CurrentParTable+'.INSTRUMENT_ID=:INST_ID AND ');
           SQL.Add( CurrentParTable+'.PROFILE_NUMBER=:PROF_NUM ');
           SQL.Add(' ORDER BY LEV_DBAR, LEV_M');
           ParamByName('ID').AsInteger:=ID;
           ParamByName('INST_ID').AsInteger:=INSTR_ID;
           ParamByName('PROF_NUM').AsInteger:=PROF_NUM;
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

  // showmessage('here5');
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
     Ini.WriteInteger( IniSection, 'DBGridCol08',  Columns[8].Width);
     Ini.WriteInteger( IniSection, 'DBGridCol09',  Columns[9].Width);
    end;

  finally
   Ini.Free;
  end;

  frmprofile_station_single_open:=false;
end;



end.

