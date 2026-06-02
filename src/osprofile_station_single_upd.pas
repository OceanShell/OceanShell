unit osprofile_station_single_upd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, DBGrids, IniFiles, SQLDB, DB, Grids, Menus, DBCtrls, Types, Math,
  // for TAChartSeries
  TAGraph, TATools, TASeries, TATypes, TAChartAxisUtils, TACustomSeries,
  TAChartUtils, TAEnumerators, TAChartListbox;

type

  { Tfrmprofile_station_single_upd }

  Tfrmprofile_station_single_upd = class(TForm)
    Chart1: TChart;
    cbParameters: TComboBox;
    clbSeries: TChartListbox;
    CTS: TChartToolset;
    DPCT: TDataPointClickTool;
    DPHT: TDataPointHintTool;
    MenuItem1: TMenuItem;
    btnBestProfile: TMenuItem;
    PageControl1: TPageControl;
    Splitter2: TSplitter;
    ZDT: TZoomDragTool;
    ZMWT: TZoomMouseWheelTool;
    PM: TPopupMenu;
    Panel1: TPanel;
    Panel2: TPanel;
    SetFlagAbove: TMenuItem;
    SetFlagBelow: TMenuItem;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;

    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnBestProfileClick(Sender: TObject);
    procedure btnCommitClick(Sender: TObject);
    procedure cbParametersChange(Sender: TObject);
    procedure DPCTPointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure DPHTAfterMouseMove(ATool: TChartTool; APoint: TPoint);
    procedure PageControl1Change(Sender: TObject);
    procedure SetFlagAboveClick(Sender: TObject);
    procedure SetFlagBelowClick(Sender: TObject);
 //   procedure TabControl1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

  private
    function AddLineSeries (AChart: TChart; ATitle: String; AColor:TColor; sName:string):TLineSeries;
    procedure ClearControls;
    procedure HighlightSeries(ASeries: TBasicChartSeries);
    procedure PlotProfile(prof_num, lev_cnt, num_size, num_scale, instr_id:integer;
      instr_name:string; prof_best: boolean; pres_arr, lev_arr, par_arr, qc_arr: array of single);
  public
    procedure ChangeID;
  end;

var
  frmprofile_station_single_upd: Tfrmprofile_station_single_upd;
  current_index, mik: integer;

implementation

{$R *.lfm}

{ Tfrmprofile_station_single_upd }

uses osmain, dm, driver_selector, driver_fdb, procedures;


function Tfrmprofile_station_single_upd.AddLineSeries(AChart: TChart;
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


procedure Tfrmprofile_station_single_upd.ClearControls;
Var
  k:integer;
begin
   mik:=-1;
   PageControl1.Clear;
   Chart1.Series.Clear;
   clbSeries.Items.Clear;

   for k:=1 to StatusBar1.Panels.Count-1 do StatusBar1.Panels.Items[k].Text:='';
   for k:=1 to StatusBar2.Panels.Count-1 do StatusBar2.Panels.Items[k].Text:='';
   Application.ProcessMessages;
end;


procedure Tfrmprofile_station_single_upd.FormShow(Sender: TObject);
Var
  Ini:TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
  try
    Left  :=Ini.ReadInteger(Name, 'Left',   50);
    Top   :=Ini.ReadInteger(Name, 'Top',    50);
    Width :=Ini.ReadInteger(Name, 'Width',  600);
    Height:=Ini.ReadInteger(Name, 'Height', 600);
  finally
     Ini.Free;
  end;
  if Left> Screen.Width then Left:=0;

  Chart1.AxisList.LeftAxis.Title.Caption:='Depth, ['+depth_units_str+']';

  current_index:=-1;
end;

procedure Tfrmprofile_station_single_upd.FormResize(Sender: TObject);
begin
 { pUnits.Width:=ToolBar1.Width-(
                btnAdd.Width+
                btnDelete.Width+
                btnCommit.Width);   }
  //showmessage(inttostr(ToolBar1.Width));
end;


procedure Tfrmprofile_station_single_upd.cbParametersChange(Sender: TObject);
begin
  CurrentParTable:=cbParameters.Text;
  ChangeID;
end;


procedure Tfrmprofile_station_single_upd.PlotProfile(prof_num, lev_cnt, num_size,
  num_scale, instr_id:integer; instr_name:string; prof_best: boolean;
  pres_arr, lev_arr, par_arr, qc_arr: array of single);
Var
  Ini:TIniFile;
  k, tt, ll:integer;
  TRt:TSQLTransaction;
  Qt1, Qt2:TSQLQuery;
  TabName, SName, isbest, tblPar:string;
  lev, lev_m, lev_d, val1: double;
  LeftAxisTitle: string;
  units:integer;

  fname, src, comm_name:string;
  paramnames:TStringList;

  QF: integer;
  val:real;

  n_prof, n_levels, n_params:size_t;

  NewTab:TTabSheet;
  NewGrid:TStringGrid;
begin
 // showmessage(inttostr(lev_cnt));
  if lev_cnt<0 then exit; //empty profile

   TabName:=instr_name+', Profile '+inttostr(prof_num);
   if prof_best=true then TabName:=TabName+' [BEST]';

   comm_name:=inttostr(instr_id)+'_'+inttostr(prof_num)+isbest;
   sName:='s'+comm_name;

   NewTab := TTabSheet.Create(PageControl1);
   NewTab.PageControl := PageControl1;
   NewTab.Name        := 't'+comm_name;
   NewTab.Caption     := TabName;

   NewGrid:=TStringGrid.Create(NewTab);
   with NewGrid do begin
     Name:='g'+comm_name;
     Align:=alClient;
     Color:=$00CFEFE6;
     AlternateColor:=$00CFFFF6;
     FixedCols:=0;
     FixedRows:=1; //header
     RowCount:=lev_cnt+2; //+header, + array 0..N
     ColCount:=7;
     Flat:=true;
     Options:=Options+[goColSizing,goRowSelect];
     Parent:=NewTab;
     Visible:=true;
   end;

   for k:=1 to 7 do NewGrid.Columns.Add;
   with NewGrid.Columns do begin
     Items[0].Title.Caption:='Level [dBar]';
     Items[0].Width:=70;
     Items[1].Title.Caption:='Level [m]';
     Items[1].Width:=65;
     Items[2].Title.Caption:='Value';
     Items[2].Width:=60;
     Items[3].Title.Caption:='PQF1';
     Items[3].Width:=60;
     Items[4].Title.Caption:='PQF2';
     Items[4].Width:=60;
     Items[5].Title.Caption:='SQF';
     Items[5].Width:=60;
     Items[6].Title.Caption:='Bottle #';
     Items[6].Width:=60;
   end;

     inc(mik);
   //  showmessage(inttostr(mik));
     AddLineSeries (Chart1, sName, s_clr[mik+1], sName);

   //  showmessage(inttostr(num_size)+'   '+floattostr(num_scale));
     for ll:=0 to lev_cnt do begin

   //     showmessage(floattostr(pres_arr[ll])+'   '+floattostr(par_arr[ll]));

     (* units for the vertical axis *)
       if depth_units_id=0 then lev:= lev_arr[ll]; //meters
       if depth_units_id=1 then lev:=pres_arr[ll]; //dBar

       lev:=roundto(lev, -1);
       val:=roundto(par_arr[ll], -num_scale);

      with NewGrid do begin
       Cells[0,ll+1]:=floattostrF(pres_arr[ll], fffixed, 5, 1);
       Cells[1,ll+1]:=floattostrF(lev_arr[ll],  fffixed, 5, 1);//depth in meters;
       Cells[2,ll+1]:=floattostrF(par_arr[ll],  fffixed, num_size, num_scale);
       Cells[3,ll+1]:=inttostr(trunc(qc_arr[ll]));
      end;

       TLineSeries(Chart1.Series[mik]).AddXY(val,lev);
     end;
end;

procedure Tfrmprofile_station_single_upd.ChangeID;
var
  prof_num, instr_id, units_id:integer;
  instr_name, fname:string;
  prof_best: boolean;
  pres_arr, lev_arr, par_arr, qc_arr:array of single;
  n_prof, n_levels, n_params:size_t;
  lev_cnt: integer;
  station_parameters_list: TStringList;
  num_size, num_scale: integer;
  units_name, val_units_str: string;
begin
  Caption:='Single parameter: '+inttostr(Current_Station_ID);
  Application.ProcessMessages;

 // showmessage(inttostr(ID)+'   '+CurrentParTable);
  ClearControls;

  try
    station_parameters_list:=TStringList.Create;

    GetParameters(Current_Station_ID, n_prof, station_parameters_list);
    cbParameters.Items := station_parameters_list;
  finally
    station_parameters_list.Free;
  end;


  if CurrentParTable<>'' then begin
    if cbParameters.Items.IndexOf(CurrentParTable)=-1 then
      CurrentParTable:=cbParameters.Items.Strings[0] else
      CurrentParTable:=cbParameters.Items.Strings[cbParameters.Items.IndexOf(CurrentParTable)];
  end else CurrentParTable:=cbParameters.Items.Strings[0];


  cbParameters.Text:=CurrentParTable;

  SetLength(pres_arr,  n_levels);
  SetLength(lev_arr,   n_levels);
  SetLength(par_arr,   n_levels);
  SetLength(qc_arr,    n_levels);

 // showmessage(inttostr(n_levels));

  for prof_num :=0 to n_prof-1 do begin
    GetProfile(Current_Station_ID, CurrentParTable, prof_num, instr_id, instr_name, fname,
               prof_best, lev_cnt, pres_arr, lev_arr, par_arr, qc_arr,
               num_size, num_scale, units_id);

    SetLength(pres_arr, lev_cnt+1);
    SetLength(lev_arr,  lev_cnt+1);
    SetLength(par_arr,  lev_cnt+1);
    SetLength(qc_arr,   lev_cnt+1);

    PlotProfile(prof_num+1, lev_cnt, num_size, num_scale, instr_id, instr_name,
               prof_best, pres_arr, lev_arr, par_arr, qc_arr);
  end;

  driver_fdb.GetUnitsNameShortByID(units_id, units_name);

  StatusBar1.Panels[6].Text:=fname;
  StatusBar2.Panels[5].Text:='Units= '+units_name;

  PageControl1.OnChange(self);
end;


procedure Tfrmprofile_station_single_upd.PageControl1Change(Sender: TObject);
Var
  ID: int64;
  TabName, Instr_name, SName, isbest, Src: string;
  comm_name:string;
  Prof_num, instr_id, ss, ll: integer;
  comp_name:TComponent;
  pres_arr, lev_arr, par_arr:array of single;
  lev_cnt: integer;
  lev_min, lev_max, lev_avg, val_sd, val_min, val_max, val_avg: real;
begin
  if PageControl1.PageCount=0 then exit;

   ID := strtoint(copy(Caption, Pos(':', Caption)+2, length(Caption)));
   TabName:= PageControl1.Pages[PageControl1.TabIndex].Caption;

   if Pos('[', TabName) <> 0 then begin
     TabName:=copy(TabName, 1, Pos('[', TabName)-2);
     isbest:='__B';
   end else isbest:='';

   Instr_name:=trim(Copy(TabName, 1, Pos(',', TabName)-1));

   driver_fdb.GetInstrumentIDByName(instr_name, instr_id);

   Prof_num :=StrToInt(trim(Copy(TabName, Pos('Profile', TabName)+7, length(TabName))));

   comm_name:=inttostr(instr_id)+'_'+inttostr(prof_num)+isbest;
   SName:='s'+comm_name;

 //  showmessage(sname);

     for ss:=0 to Chart1.Series.Count-1 do
      if Chart1.Series[ss].Name=sName then begin
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

   comp_name:=PageControl1.Pages[PageControl1.ActivePageIndex].Components[0];
   if (comp_name is TStringGrid) then begin
     with (comp_name as TStringGrid) do begin
      lev_cnt:=RowCount-1;
      SetLength(pres_arr, lev_cnt);
      SetLength(lev_arr,  lev_cnt);
      SetLength(par_arr,  lev_cnt);
      for ll:=0 to lev_cnt-1 do begin
        pres_arr[ll]:=StrToFloat(Cells[0,ll+1]);
        lev_arr[ll] :=StrToFloat(Cells[1,ll+1]);
        par_arr[ll] :=StrToFloat(Cells[2,ll+1]);
      end;
     end;
   end;

   GetProfileStatistics(pres_arr, lev_arr, par_arr, lev_min, lev_max, lev_avg,
     val_sd, val_min, val_max, val_avg);

  // UnitsMapping(argo_par:string; var units_id:integer

   StatusBar1.Panels[1].Text:='Count= '+Inttostr(lev_cnt);
   StatusBar1.Panels[2].Text:='Min= '  +floattostrF(lev_min, fffixed,8,1);
   StatusBar1.Panels[3].Text:='Max= '  +floattostrF(lev_max, fffixed,8,1);
   StatusBar1.Panels[4].Text:='Avg= '  +floattostrF(lev_avg, fffixed,8,3);
   StatusBar1.Panels[5].Text:='Units= '+depth_units_str;

   StatusBar2.Panels[1].Text:='SD= '   +floattostrF(val_sd, fffixed,8,4);
   StatusBar2.Panels[2].Text:='Min= '  +floattostrF(val_min, fffixed,8,4);
   StatusBar2.Panels[3].Text:='Max= '  +floattostrF(val_max, fffixed,8,4);
   StatusBar2.Panels[4].Text:='Avg= '  +floattostrF(val_avg, fffixed,8,4);
end;


procedure Tfrmprofile_station_single_upd.DPHTAfterMouseMove(ATool: TChartTool;
  APoint: TPoint);
begin
    HighlightSeries(TDatapointHintTool(ATool).Series);
end;


procedure Tfrmprofile_station_single_upd.DPCTPointClick(
  ATool: TChartTool; APoint: TPoint);
Var
 k, pp, ll: integer;
 tool: TDataPointClicktool;
 series: TLineSeries;
 pointer: TSeriesPointer;
 instr_name, id, prof_num: string;
 instr_id: integer;

 TRt:TSQLTransaction;
 Qt1:TSQLQuery;
 plot_depth: real;

 comp_name: TComponent;
begin
  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);
    INSTR_ID:=StrToInt(Copy(series.Name, 2, Pos('_', Series.Name)-2));

    driver_fdb.GetInstrumentNameByID(instr_id, instr_name);


    Prof_num:=Copy(series.name, Pos('_', Series.Name)+1, length(series.name));
  //  showmessage(prof_num);

    if Pos('__B', series.name)<>0 then
      Prof_num:=StringReplace(Prof_num, '__B', ' [BEST]', []);

    comp_name:=PageControl1.Pages[PageControl1.ActivePageIndex].Components[0];
       if (comp_name is TStringGrid) then begin
         with (comp_name as TStringGrid) do begin
          for ll:=0 to RowCount-2 do begin
           if ((depth_units_id=0) and (series.YValue[tool.PointIndex]-StrToFloat(Cells[1,ll+1])<1E-2)) or
              ((depth_units_id=1) and (series.YValue[tool.PointIndex]-StrToFloat(Cells[0,ll+1])<1E-2)) then begin
              (comp_name as TStringGrid).Row:=ll+1;
              break;
          end;
         end;
        end;
       end;
  end;
end;

procedure Tfrmprofile_station_single_upd.SetFlagBelowClick(Sender: TObject);
Var
  par:string;
  fl, cur_pos: integer;
begin
{ Qt.DisableControls;
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
 end; }
end;


procedure Tfrmprofile_station_single_upd.SetFlagAboveClick(Sender: TObject);
Var
  par:string;
  fl, cur_pos: integer;
begin
 {
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
    Qt.FieldByName('PQF2').AsFloat:=fl;
    Qt.Post;
 finally
   Qt.RecNo:=Cur_pos;
   Qt.EnableControls;
 end;  }
end;


procedure Tfrmprofile_station_single_upd.btnCommitClick(Sender: TObject);
Var
  ID, Instr_id, Prof_num:integer;
  TabName, Instr_name:string;
begin
{  ID:=frmdm.Q.FieldByName('ID').AsInteger;

 // TabName:=TabControl1.Tabs[TabControl1.TabIndex];
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
        SQL.Add(' bottle_number, units_id, instrument_id, PROFILE_NUMBER, ');
        SQL.Add(' PROFILE_BEST) ');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :lev_m, :lev_dbar, :val, :pqf1, :pqf2, :sqf, ');
        SQL.Add(' :bottle_number, :units_id, :instrument_id, :PROFILE_NUMBER, ');
        SQL.Add(' :PROFILE_BEST) ');
        ParamByName('ID').Value:=Qt.FieldByName('ID').Value;
        ParamByName('LEV_M').Value:=Qt.FieldByName('LEV_M').Value;
        ParamByName('LEV_DBAR').Value:=Qt.FieldByName('LEV_DBAR').Value;
        ParamByName('VAL').Value:=Qt.FieldByName('VAL').Value;
        ParamByName('PQF1').Value:=Qt.FieldByName('PQF1').Value;
        ParamByName('PQF2').Value:=Qt.FieldByName('PQF2').Value;
        ParamByName('SQF').Value:=Qt.FieldByName('SQF').Value;
        ParamByName('BOTTLE_NUMBER').Value:=Qt.FieldByName('BOTTLE_NUMBER').Value;
        ParamByName('PROFILE_BEST').Value:=Qt.FieldByName('PROFILE_BEST').Value;
        ParamByName('UNITS_ID').Value:=Qt.FieldByName('UNITS_ID').Value;
        ParamByName('INSTRUMENT_ID').Value:=Instr_id;
        ParamByName('PROFILE_NUMBER').Value:=Prof_num;
      //  showmessage(SQL.Text);
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
 ChangeID;

// if frmprofile_plot_all_open=true then frmprofile_plot_all.AddToPlot(ID, true);    }
end;


procedure Tfrmprofile_station_single_upd.btnBestProfileClick(Sender: TObject);
Var
  TabName, Instr_name:string;
  ID, Prof_num, prof_cur, instr_id: integer;
  TRt:TSQLTransaction;
  Qt1:TSQLQuery;
begin
 // TabName:=TabControl1.Tabs.Strings[TabControl1.TabIndex];
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

  ChangeID;
end;



procedure Tfrmprofile_station_single_upd.HighlightSeries(ASeries: TBasicChartSeries);
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


procedure Tfrmprofile_station_single_upd.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
Var
  Ini: TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);

  try
    Ini.WriteInteger(Name, 'Left',   Left);
    Ini.WriteInteger(Name, 'Top',    Top);
    Ini.WriteInteger(Name, 'Width',  Width);
    Ini.WriteInteger(Name, 'Height', Height);
  finally
   Ini.Free;
  end;

  frmprofile_station_single_open:=false;
end;



end.

