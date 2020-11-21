unit osprofile_station_all;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Math,
  Controls, Forms, ExtCtrls, DB, StdCtrls, ComCtrls, CheckLst,
  BufDataSet, IniFiles, Dialogs, Menus, DBGrids, SQLDB, Grids,
  TAGraph, TATools, TASeries, TATypes, TAChartAxisUtils,
//  TACustomSeries,  // for TChartSeries
  TAChartUtils,    // for nptCustom
  TAEnumerators, Types;   // for CustomSeries(Chart) ;

type

  { Tfrmprofile_station_all }

  Tfrmprofile_station_all = class(TForm)
    pFiller: TPanel;
    rbPQF1: TRadioButton;
    rbPQF2: TRadioButton;
    rbSQF: TRadioButton;
    SetFlagAbove: TMenuItem;
    SetFlagBelow: TMenuItem;
    Toolset: TChartToolset;
    DBGrid1: TDBGrid;
    DPC: TDataPointClickTool;
    DPH: TDataPointHintTool;
    Panel1: TPanel;
    pCharts: TScrollBox;
    Splitter2: TSplitter;
    ToolBar1: TToolBar;
    btnCommit: TToolButton;
    DS1: TDataSource;
    PM: TPopupMenu;
    btnSetFlag: TToolButton;
    ToolButton3: TToolButton;
    ZD: TZoomDragTool;
    ZMW: TZoomMouseWheelTool;

    procedure btnSetFlagArrowClick(Sender: TObject);
    procedure DBGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DPCPointClick(ATool: TChartTool; APoint: TPoint);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnCommitClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure iSetFlagParameterClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rbPQF1Click(Sender: TObject);
    procedure rbPQF2Click(Sender: TObject);
    procedure rbSQFClick(Sender: TObject);
    procedure SetFlagAboveClick(Sender: TObject);
    procedure SetFlagBelowClick(Sender: TObject);

  private
    procedure CheckChartSize;
    function AddLineSeries(AChart: TChart): TLineSeries;

  public
    procedure ChangeID(ID:integer);
  end;

var
  frmprofile_station_all: Tfrmprofile_station_all;
  CDS:TBufDataSet;
  Charts:array [1..200] of TChart;
  Tools: array of TChartToolset;
  ToolDPC: array of TDataPointClickTool;
  ToolDPH: array of TDataPointHintTool;
  cbUnits: array of TComboBox;
  Ks:integer;
  flag_type:string;


implementation

uses osmain, dm, osprofile_flag, osprofile_plot_all;

{$R *.lfm}

function Tfrmprofile_station_all.AddLineSeries(AChart: TChart): TLineSeries;
begin
 Result := TLineSeries.Create(AChart.Owner);
  with TLineSeries(Result) do begin
    ShowPoints := true;
    ShowLines := true;
    LinePen.Style := psSolid;
    SeriesColor := clBlue;
    Pointer.Style:=psCircle;
    Pointer.Brush.Color := clBlue;
    Pointer.Pen.Color := clBlack;
    Pointer.HorizSize:=3;
    Pointer.VertSize:=3;
    Pointer.Visible:=true;
   // ToolTargets := [nptPoint, nptYList, nptCustom];
  end;
 AChart.AddSeries(Result);
end;


procedure Tfrmprofile_station_all.FormCreate(Sender: TObject);
Var
ID:Integer;
par:string;
begin
 CDS:=TBufDataSet.Create(nil);
  ID:=frmdm.Q.FieldByName('ID').AsInteger;
 ChangeID(ID);
end;


procedure Tfrmprofile_station_all.FormShow(Sender: TObject);
Var
  Ini:TInifile;
begin
Ini := TIniFile.Create(IniFileName);
  try
    Width :=Ini.ReadInteger( 'parameters_station', 'Width',  900);
    Height:=Ini.ReadInteger( 'parameters_station', 'Height', 500);
    //CheckListBox1.Width :=Ini.ReadInteger( 'parameters_station', 'listbox1', 200);
    pCharts.Height      :=Ini.ReadInteger( 'parameters_station', 'pCharts',  200);

    case Ini.ReadInteger( 'osmain', 'QCFlagType', 1) of
      0: rbPQF1.Checked:=true;
      1: rbPQF2.Checked:=true;
      2: rbSQF.Checked:=true;
    end;
  finally
   Ini.Free;
  end;
end;


procedure Tfrmprofile_station_all.FormResize(Sender: TObject);
begin
  CheckChartSize;
end;


procedure Tfrmprofile_station_all.ChangeID(ID:integer);
Var
Ini:TIniFile;
k, i, fl, ff, pp, ss, cc, count_st, units_id, Flag_, instr_id, prof_num:integer;
QF: integer;
cur_l, Val_, min_lev, max_lev:real;
lev_d, lev_m: Variant;
prof_best:boolean;
Units_, par, par_name, col_title, instr_name, isbest, sName, buf_str:string;
cds_name, LeftAxisTitle: string;

TRt:TSQLTransaction;
Qt, Qt1, Qt2:TSQLQuery;
begin

//Memo1.Clear; Memo1.Visible:=false;
Caption:='All parameters: '+inttostr(ID);
//CheckListBox1.Clear;

Ini := TIniFile.Create(IniFileName);
try
  case Ini.ReadInteger('osmain', 'QCFlagType', 1) of
    0: flag_type:='PQF1';
    1: flag_type:='PQF2';
    2: flag_type:='SQF';
  end;
finally
 Ini.Free;
end;


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

ss:=0;

 try
  pCharts.Visible:=false;

  for k:=1 to 200 do charts[k].Free;

  CDS.DisableControls;
  CDS.Clear;

  CDS.FieldDefs.Add('Lev_dbar',ftFloat,0,false);
  CDS.FieldDefs.Add('Lev_m',ftFloat,0,false);

  (* loop over tables *)
  for ks:=0 to frmosmain.ListBox1.Items.Count-1 do begin
    Par:=frmosmain.ListBox1.Items.Strings[ks];

      with Qt1 do begin
       Close;
         SQL.Clear;
         SQL.Add(' SELECT DISTINCT(INSTRUMENT_ID), INSTRUMENT.NAME ');
         SQL.Add(' FROM INSTRUMENT, '+ Par);
         SQL.Add(' WHERE ');
         SQL.Add( Par+'.INSTRUMENT_ID=INSTRUMENT.ID AND ');
         SQL.Add( Par+'.ID=:ID ');
         ParamByName('ID').AsInteger:=ID;
       Open;
      end;

      While not Qt1.eof do begin
        INSTR_ID:=Qt1.Fields[0].Value;
        INSTR_NAME:=Qt1.Fields[1].Value;

        With Qt2 do begin
          Close;
            SQL.Clear;
            SQL.Add(' SELECT DISTINCT(PROFILE_NUMBER), PROFILE_BEST, UNITS_ID FROM ');
            SQL.Add( Par);
            SQL.Add(' WHERE ');
            SQL.Add( Par+'.ID=:ID AND INSTRUMENT_ID=:INSTR_ID ');
            ParamByName('ID').AsInteger:=ID;
            ParamByName('INSTR_ID').AsInteger:=INSTR_ID;
          Open;
        end;

        while not Qt2.eof do begin
          prof_num :=Qt2.Fields[0].AsInteger;
          prof_best:=Qt2.Fields[1].AsBoolean;
          units_id :=Qt2.Fields[2].AsInteger;

          sName:=par+'_'+instr_name+'_'+inttostr(prof_num)+'_'+inttostr(units_id);

          CDS.FieldDefs.Add(sname,ftFloat,0,false);
          CDS.FieldDefs.Add(sname+'_FL',ftInteger,0,false);

          inc(ss);

          //showmessage(inttostr(ss));

          Charts[ss]:=TChart.Create(Self);
          Charts[ss].Toolset:=Toolset;
           with Charts[ss] do begin
             Parent:=pCharts;
             Align:=alRight;
             Legend.Visible:=false;
             LeftAxis.Inverted:=true;
             Title.Text.Clear;
             Title.Alignment:=taCenter;
             Title.Visible:=true;
             BackColor:=clWhite;
             LeftAxis.Inverted:=true;
             BottomAxis.Alignment:=calTop;
             Width:=250;
           end;

          AddLineSeries(Charts[ss]);

          Qt2.Next;
        end;
        Qt1.Next;
      end;
  end; // parameters
  Qt2.Close;
  Qt1.Close;

  CDS.CreateDataSet;
  CDS.IndexFieldNames:=CDS.FieldbyName('Lev_dbar').FieldName;
  CDS.Open;

  DS1.DataSet:=CDS;


  min_lev:=9999;
  max_lev:= -9999;

  cc:=0;
  for pp:=2 to CDS.FieldCount-1 do begin

   if (pp mod 2<>1) then begin
    inc(cc);
    TLineSeries(Charts[cc].Series[0]).Clear;

    sName:=CDS.Fields[pp].FieldName;

  //  showmessage(sname);

    ss:=2;
    for i:=1 to 4 do begin
      buf_str:='';
      repeat
       inc(ss);
        if sName[ss]<>'_' then buf_str:=buf_str+sname[ss];
      until (sName[ss]='_') or (ss=length(sName));
      case i of
       1: par:='P_'+buf_str;
       2: INSTR_NAME:=buf_str;
       3: prof_num:=strtoint(buf_str);
       4: units_id:=strtoint(buf_str);
      end;
    end;

   with Qt do begin
     Close;
       Sql.Clear;
       SQL.Add(' SELECT * FROM ');
       SQL.Add( Par+', UNITS ');
       SQL.Add(' WHERE ');
       SQL.Add( Par +'.ID=:ID AND ');
       SQL.Add( Par +'.UNITS_ID=UNITS.ID AND ');
       SQL.Add( Par +'.INSTRUMENT_ID IN ');
       SQL.Add('(SELECT ID FROM INSTRUMENT WHERE ');
       SQL.Add('INSTRUMENT.NAME=:INSTR_NAME) AND ');
       SQL.Add( Par +'.PROFILE_NUMBER=:PROF_NUM');
       SQL.Add(' ORDER BY LEV_DBAR ');
       ParamByName('ID').AsInteger:=ID;
       ParamByName('INSTR_NAME').AsString:=INSTR_NAME;
       ParamByName('PROF_NUM').AsInteger:=PROF_NUM;
     Open;
    end;

   cds_name:=par+'_'+instr_name+'_'+inttostr(prof_num)+'_'+inttostr(units_id);

  //  showmessage(inttostr(Qt.RecordCount));
  Qt.First;
  Count_st:=0; cur_l:=-9;
    while not Qt.eof do begin
      Lev_m   :=Qt.FieldByName('LEV_M').AsVariant;
      Lev_d   :=Qt.FieldByName('LEV_DBAR').AsVariant;
      Val_    :=Qt.FieldByName('VAL').AsFloat;
      QF      :=Qt.FieldByName(flag_type).AsInteger;
      Units_  :=Qt.FieldByName('NAME_SHORT').AsString;

      min_lev := min(min_lev, lev_m);
      max_lev := max(max_lev, lev_m);

 //     showmessage(par+#9+floattostr(lev)+#9+floattostr(val));

  {    if cur_l=lev then memo1.Lines.Add(frmosmain.listbox1Items.Strings[k]+
                        '-> level: '+floattostr(lev)+' has duplicate!'); }

      CDS.First; Fl:=1;
      while not CDS.Eof do begin
        if (CDS.FieldByName('LEV_DBAR').AsFloat=Lev_d) or
           (CDS.FieldByName('LEV_M').AsFloat=Lev_m) then begin
            CDS.edit;
             CDS.FieldByName(cds_name).AsFloat:=Val_;
             CDS.FieldByName(cds_name+'_FL').AsInteger:=QF;
            // CDS.FieldByName(cds_name+'_PQF2').AsInteger:=PQF2;
            // CDS.FieldByName(cds_name+'_SQF').AsInteger:=SQF;
            CDS.Post;  fl:=0;
        end;
        CDS.Next;
      end;

      if fl=1 then begin
         CDS.Append;
         CDS.FieldByName('LEV_DBAR').AsFloat:=Lev_d;
         CDS.FieldByName('LEV_M').AsFloat:=Lev_m;
         CDS.FieldByName(cds_name).AsFloat:=Val_;
         CDS.FieldByName(cds_name+'_FL').AsInteger:=QF;
         CDS.Post;
      end;
      inc(Count_st);
     // cur_l:=lev;
      TLineSeries(Charts[cc].Series[0]).AddXY(val_,lev_m);
      Qt.Next;
    end;
    Qt.Close;

    //par_name:='['+inttostr(count_st)+']  '+copy(par,3,length(par))+' ';
    //CheckListBox1.Items.Add(par_name);

    col_title:=Copy(par, 3, length(par));
    //col_title:=Copy(col_title, 1, Pos('_', col_title)+3);

    Charts[cc].Title.Text.Clear;
    Charts[cc].Title.Text.Add(col_title+', ['+units_+']');
    Charts[cc].Title.Text.Add(instr_name+', Profile '+inttostr(prof_num));
    Charts[cc].Title.Text.Add('Levels: '+inttostr(count_st));


    //CDS.FieldByName(cds_name).visible:=true;
   // CDS.FieldByName(cds_name+'_FL').visible:=true;
  //     Charts[cc].Visible:=true

   Application.ProcessMessages;
  end;
 end;

  for k:=1 to cc do begin
    Charts[k].LeftAxis.Range.Min:=min_lev;
    Charts[k].LeftAxis.Range.Max:=max_lev;
    Charts[k].LeftAxis.Range.UseMin:=true;
    Charts[k].LeftAxis.Range.UseMax:=true;
  end;

  (* depth units for the first chart *)
  case depth_units of
   0: LeftAxisTitle:='Depth, [m]';
   1: LeftAxisTitle:='Depth, [dBar]';
  end;
  Charts[cc].Width:=280;
  Charts[cc].AxisList.LeftAxis.Title.Caption:=LeftAxisTitle;

 (* settings for the grid *)
  DBGrid1.Columns[0].Title.Caption:='Level, dBar';
  DBGrid1.Columns[0].ReadOnly:=true;
  DBGrid1.Columns[1].Title.Caption:='Level, m';
  for k:=2 to DBGrid1.Columns.Count-1 do begin
   col_title:=DBGrid1.Columns[k].Title.Caption;

    if (k mod 2<>1) then begin
      col_title:=Copy(col_title, 3, length(col_title));
     // col_title:=Copy(col_title, 1, Pos('_', col_title)+3);
      DBGrid1.Columns[k].Title.Caption:=col_title;
      DBGrid1.Columns[k].ReadOnly:=true;
      DBGrid1.Columns[k].Width:=120;
    end;

    if (k mod 2=1) then begin
      DBGrid1.Columns[k].Title.Caption:='QF';
      DBGrid1.Columns[k].Width:=40;

      //QCFlags
      DBGrid1.Columns[k].PickList:=frmosmain.DBGridStation.Columns[12].PickList;
    end else begin
     // DBGrid1.Columns[k].Footer.ValueType:=fvtAvg;
    end;
  end;

 finally
  TRt.Commit;
  CDS.First;
  CDS.EnableControls;
  Qt.Free;
  Trt.Free;
  pCharts.Visible:=true;
 end;

  CheckChartSize;
end;


procedure Tfrmprofile_station_all.btnCommitClick(Sender: TObject);
Var
ID, k, ss, pp, i, prof_num, units_id:integer;
par, sName, instr_name, buf_str:string;
begin
ID:=frmdm.Q.FieldByName('ID').AsInteger;

try
 CDS.DisableControls;

 (* saving levels *)
 For pp:=2 to CDS.FieldCount-1 do begin
  sName:=CDS.Fields[pp].FieldName;
  if copy(sName, length(sname)-2, 3)<>'_FL' then begin

     ss:=2;
     for i:=1 to 4 do begin
       buf_str:='';
       repeat
        inc(ss);
         if sName[ss]<>'_' then buf_str:=buf_str+sname[ss];
       until (sName[ss]='_') or (ss=length(sName));
       case i of
        1: par:='P_'+buf_str;
        2: INSTR_NAME:=buf_str;
        3: prof_num:=strtoint(buf_str);
        4: units_id:=strtoint(buf_str);
       end;
     end;

     CDS.First;
     while not cds.Eof do begin

      if (not CDS.FieldByName(sName).IsNull) and
         (not CDS.FieldByName('lev_m').isNull) then begin

      try
        with frmdm.q1 do begin
         Close;
           SQL.Clear;
           SQL.Add(' UPDATE ');
           SQL.Add(par);
           SQL.Add(' SET ');
           SQL.Add(' LEV_M=:LEV_M, VAL=:val, '+flag_type+'=:QF ');
           SQL.Add(' WHERE ' );
           SQL.Add(' ID=:ID AND LEV_DBAR=:lev_d AND ');
           SQL.Add(' INSTRUMENT_ID IN (SELECT ID FROM INSTRUMENT ');
           SQL.Add(' WHERE INSTRUMENT.NAME=:INSTR_NAME) AND ');
           SQL.Add(' PROFILE_NUMBER=:PROF_NUM ');
           ParamByName('ID').AsInteger:=ID;
           ParamByName('INSTR_NAME').AsString:=instr_NAME;
           ParamByName('PROF_NUM').AsInteger:=prof_num;
           ParamByName('lev_d').AsFloat:=CDS.FieldByName('lev_dbar').AsFloat;
           ParamByName('lev_m').AsFloat:=CDS.FieldByName('lev_m').AsFloat;
           ParamByName('VAL').AsFloat:=CDS.FieldByName(sname).AsFloat;
           ParamByName('QF').AsInteger:=CDS.FieldByName(sname+'_FL').AsInteger;
         ExecSQL;
        end;
      frmdm.TR.CommitRetaining;
      except
       On E :Exception do begin
         ShowMessage(E.Message);
        frmdm.TR.RollbackRetaining;
       end;
      end;
      end;

      CDS.Next;
     end;
    end;

  end;
  finally
   CDS.EnableControls;
  end;
ChangeID(ID);
//if frmprofile_plot_all_open=true then frmprofile_plot_all.AddToPlot(ID, true);
end;


procedure Tfrmprofile_station_all.CheckChartSize;
Var
k, CountChecked:integer;
begin
 pFiller.Width:=ToolBar1.Width-
                (btnSetFlag.Width+
                 btnCommit.Width+
                 rbPQF1.Width+
                 rbPQF2.Width+
                 rbSQF.Width)-20;
 Application.ProcessMessages;
 // CountChecked:=0;
 //  for k:=0 to CheckListBox1.Count-1 do if CheckListBox1.Checked[k]=true then inc(CountChecked);
 //   if CountChecked>0 then
 //    for k:=0 to frmosmain.listbox1.Items.Count-1 do Charts[k].Width:=round(pCharts.Width/CountChecked);
 //  if memo1.Lines.Count>0 then memo1.Visible:=true;
end;


(* Setting flags for EVERY parameter *)
procedure Tfrmprofile_station_all.btnSetFlagArrowClick(Sender: TObject);
Var
k, cur_pos:integer;
tbl:string;
begin
   frmparameters_flag:= Tfrmparameters_flag.Create(Self);
   frmparameters_flag.Top:=GetSystemMetrics(SM_CYCAPTION)+Top+btnSetFlag.Height;
   frmparameters_flag.Left:=Left+btnSetFlag.Left+5;
  try
   if frmparameters_flag.ShowModal = mrOk then
   finally
    frmparameters_flag.Free;
    frmparameters_flag := nil;
   end;

  if ProfFlag=-9 then exit; // Оставляем старый флаг

   try
   CDS.DisableControls;
   Cur_pos:=CDS.RecNo;

     if (ProfFlag<>999) and (ProfFlag<>777) then begin
      For k:=2 to CDS.Fields.Count-1 do begin
       tbl:=CDS.Fields[k].FieldName;
       if copy(tbl, length(tbl)-2, 3)='_FL' then begin
        CDS.First;
         while not CDS.Eof do begin
          CDS.Edit;
           if not CDS.FieldByName(copy(tbl, 1, length(tbl)-3)).IsNull then
           CDS.FieldByName(tbl).AsFloat:=ProfFlag;
          CDS.Post;
          CDS.Next;
        end;
       end;
      end;
     end;

    // flag above selected level
     if ProfFlag=777 then begin
      repeat
      // showmessage(inttostr(cds.RecNo));
        For k:=2 to CDS.Fields.Count-1 do begin
        tbl:=CDS.Fields[k].FieldName;
      //  showmessage(tbl);
        if copy(tbl, length(tbl)-2, 3)='_FL' then begin
        // showmessage(tbl+'   '+inttostr(CDS.RecNo));
          if not CDS.FieldByName(copy(tbl, 1, length(tbl)-3)).IsNull then begin
           CDS.Edit;
           CDS.FieldByName(tbl).AsFloat:=2;
           CDS.Post;
          end;
         end;
        end;
       CDS.Prior;
       until CDS.RecNo=1;
      CDS.First;
      For k:=2 to CDS.Fields.Count-1 do begin
      tbl:=CDS.Fields[k].FieldName;
       if copy(tbl, length(tbl)-2, 3)='_FL' then begin
        if not CDS.FieldByName(copy(tbl, 1, length(tbl)-3)).IsNull then begin
         CDS.Edit;
         CDS.FieldByName(tbl).AsFloat:=2;
         CDS.Post;
        end;
      end;
      end;
     end;

     // flag below selected level
     if ProfFlag=999 then begin
      while not CDS.Eof do begin
       For k:=2 to CDS.Fields.Count-1 do begin
        tbl:=CDS.Fields[k].FieldName;
        if copy(tbl, length(tbl)-2, 3)='_FL' then begin
          if not CDS.FieldByName(copy(tbl, 1, length(tbl)-3)).IsNull then begin
           CDS.Edit;
           CDS.FieldByName(tbl).AsFloat:=2;
           CDS.Post;
          end;
         end;
        end;
       CDS.Next;
      end;
     end;

  finally
   CDS.RecNo:=Cur_pos;
   CDS.EnableControls;
  end;
end;


(* Ставим флаг на отдельный профиль *)
procedure Tfrmprofile_station_all.iSetFlagParameterClick(Sender: TObject);
Var
Par:string;
Coord: TPoint;
Cur_pos:integer;
begin
  frmparameters_flag:= Tfrmparameters_flag.Create(Self);

  GetCursorPos(Coord);
  frmparameters_flag.Top:=Coord.Y;
  frmparameters_flag.Left:=Coord.X;

  try
   if frmparameters_flag.ShowModal = mrOk then
  finally
    frmparameters_flag.Free;
    frmparameters_flag := nil;
  end;
  if ProfFlag=-9 then exit;

  par:=DBGrid1.SelectedField.FieldName;
  if (Par='Lev_m') or (Par='Lev_dbar') then exit;
  if Copy(par,length(par)-2,3)<>'_FL' then Par:=Par+'_FL';

  try
  CDS.DisableControls;
  Cur_pos:=CDS.RecNo;

  if (ProfFlag<>999) and (ProfFlag<>777) then begin
    CDS.First;
    while not cds.Eof do begin
     if CDS.FieldByName(Par).IsNull=false then begin
      CDS.Edit;
       CDS.FieldByName(Par).AsFloat:=ProfFlag;
      CDS.Post;
     end;
    CDS.Next;
   end;
   end;
  finally
   CDS.RecNo:=Cur_pos;
   CDS.EnableControls;
  end;
end;

procedure Tfrmprofile_station_all.SetFlagBelowClick(Sender: TObject);
Var
  par:string;
  fl, cur_pos: integer;
begin
 par:=DBGrid1.SelectedField.FieldName;
  if (Par='Lev_m') or (Par='Lev_dbar') then exit;
  if Copy(par,length(par)-2,3)<>'_FL' then Par:=Par+'_FL';

 CDS.DisableControls;
 cur_pos:=CDS.RecNo;
 try
  fl:=CDS.FieldByName(par).AsInteger;
   while not CDS.Eof do begin
    CDS.Edit;
     CDS.FieldByName(par).AsFloat:=fl;
     CDS.Post;
    CDS.Next;
   end;
 finally
   CDS.RecNo:=Cur_pos;
   CDS.EnableControls;
 end;
end;


procedure Tfrmprofile_station_all.SetFlagAboveClick(Sender: TObject);
Var
  par:string;
  fl, cur_pos: integer;
begin
 par:=DBGrid1.SelectedField.FieldName;

 if (DBGrid1.SelectedColumn.Index=0) or
    (DBGrid1.SelectedColumn.Index=1) then exit;

  if Copy(par,length(par)-2,3)<>'_FL' then Par:=Par+'_FL';

 CDS.DisableControls;
 cur_pos:=CDS.RecNo;
 try
  fl:=CDS.FieldByName(par).AsInteger;
    repeat
     CDS.Edit;
      CDS.FieldByName(par).AsFloat:=fl;
      CDS.Post;
     CDS.Prior;
    until CDS.RecNo=1;
    CDS.First;
    CDS.Edit;
    CDS.FieldByName(par).AsFloat:=fl;
    CDS.Post;
 finally
   CDS.RecNo:=Cur_pos;
   CDS.EnableControls;
 end;
end;


procedure Tfrmprofile_station_all.DBGrid1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
  Par:string;
begin
  if (Button=mbRight) and
     (DBGrid1.SelectedColumn.Index<>0) and
     (DBGrid1.SelectedColumn.Index<>1) then begin
        par:=DBGrid1.SelectedColumn.FieldName;

        if Copy(par,length(par)-2,3)='_FL' then Par:=copy(par, 1, length(par)-3);


       //iSetFlagParameter.Caption:='Set flag for '+Par;
      // iDeleteParameter.Caption:='Delete '+Par;
       PM.PopUp;
  end;
end;

procedure Tfrmprofile_station_all.DBGrid1PrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
  if Column.Index=0 then TDBGrid(sender).Canvas.Brush.Color:=clBtnFace;
  if gdRowHighlight in AState then begin
    TDBGrid(sender).Canvas.Brush.Color := clNavy;
    TDBGrid(sender).Canvas.Font.Color:= clYellow;
    TDBGrid(sender).Canvas.Font.Style:=[fsBold];
  end;
end;


procedure Tfrmprofile_station_all.DPCPointClick(ATool: TChartTool;
  APoint: TPoint);
Var
 k,pp: integer;
 tool: TDataPointClicktool;
 series: TLineSeries;
 pointer: TSeriesPointer;
begin
{  for k:=0 to length(Charts)-1 do
    for pp in TLineSeries(Charts[k].Series[0]).Pointer do
 //   TLineSeries(Charts[k].Series[0]).Pointer.Brush.Color:=clBlue;  }

  tool := ATool as TDataPointClickTool;
  if tool.Series is TLineSeries then begin
    series := TLineSeries(tool.Series);
    if (tool.PointIndex<>-1) then begin
     // series.SetColor(tool.PointIndex, clRed);
     CDS.Locate('Lev_m', series.YValue[tool.PointIndex], []);
    end;
  end;
end;



procedure Tfrmprofile_station_all.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var
Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger( 'parameters_station', 'Height',   Height);
    Ini.WriteInteger( 'parameters_station', 'Width',    Width);
   // Ini.WriteInteger( 'parameters_station', 'listbox1', CheckListBox1.Width);
    Ini.WriteInteger( 'parameters_station', 'pCharts',  pCharts.Height);
   finally
    ini.Free;
  end;
CDS.Free;

frmprofile_station_all_open:=false;
end;



procedure Tfrmprofile_station_all.rbPQF1Click(Sender: TObject);
Var
  Ini:TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger( 'osmain', 'QCFlagType', 0);
  finally
    Ini.Free;
  end;
ChangeID(frmdm.Q.FieldByName('ID').Value);
end;



procedure Tfrmprofile_station_all.rbPQF2Click(Sender: TObject);
Var
  Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger( 'osmain', 'QCFlagType', 1);
  finally
    Ini.Free;
  end;
ChangeID(frmdm.Q.FieldByName('ID').Value);
end;


procedure Tfrmprofile_station_all.rbSQFClick(Sender: TObject);
Var
  Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger( 'osmain', 'QCFlagType', 2);
  finally
    Ini.Free;
  end;
ChangeID(frmdm.Q.FieldByName('ID').Value);
end;


procedure Tfrmprofile_station_all.FormDestroy(Sender: TObject);
begin
// Charts:=nil;
end;



end.
