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
    SetFlagAbove: TMenuItem;
    SetFlagBelow: TMenuItem;
    Toolset: TChartToolset;
    CheckListBox1: TCheckListBox;
    DBGrid1: TDBGrid;
    DPC: TDataPointClickTool;
    DPH: TDataPointHintTool;
    Panel1: TPanel;
    pCharts: TScrollBox;
    Splitter2: TSplitter;
    ToolBar1: TToolBar;
    btnAdd: TToolButton;
    btnDelete: TToolButton;
    ToolButton1: TToolButton;
    btnCommit: TToolButton;
    DS1: TDataSource;
    PM: TPopupMenu;
    Splitter1: TSplitter;
    iDeleteParameter: TMenuItem;
    btnSetFlag: TToolButton;
    N1: TMenuItem;
    ToolButton3: TToolButton;
    ZD: TZoomDragTool;
    ZMW: TZoomMouseWheelTool;

    procedure btnSetFlagArrowClick(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1ColumnSized(Sender: TObject);
    procedure DBGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DBGrid1PrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DPCPointClick(ATool: TChartTool; APoint: TPoint);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnCommitClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure iDeleteParameterClick(Sender: TObject);
{    procedure SeriesClick(Sender: TChartSeries; ValueIndex: Integer;
    Button: TMouseButton; Shift: TShiftState; X,Y: Integer);  }
    procedure iSetFlagParameterClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DBGridEh1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
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
  Charts:array of TChart;
  Tools: array of TChartToolset;
  ToolDPC: array of TDataPointClickTool;
  ToolDPH: array of TDataPointHintTool;
  cbUnits: array of TComboBox;
  Ks:integer;


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
  SetLength(Charts,  frmosmain.listbox1.Count);
 // SetLength(cbUnits, frmosmain.listbox1.Count);

   CDS:=TBufDataSet.Create(nil);
    CDS.FieldDefs.Add('Lev_dbar',ftFloat,0,false);
    CDS.FieldDefs.Add('Lev_m',ftFloat,0,false);
     for ks:=0 to frmosmain.ListBox1.Items.Count-1 do begin
      Par:=frmosmain.ListBox1.Items.Strings[ks];

       CDS.FieldDefs.Add(Par,ftFloat,0,false);
       CDS.FieldDefs.Add(Par+'_FL',ftInteger,0,false);

       { cbUnits[ks]:=TComboBox.Create(self);
          with cbUnits[ks] do begin
            Parent:=pUnits;
            Name:=Par;
            Align:=alLeft;
            Style:=csDropDownList;
          end; }

        Charts[ks]:=TChart.Create(Self);
        Charts[ks].Toolset:=Toolset;
          with Charts[ks] do begin
             Parent:=pCharts;
             Align:=alRight;
             Legend.Visible:=false;
             LeftAxis.Inverted:=true;
             Title.Text.Clear;
             Title.Alignment:=taCenter;
             Title.Visible:=true;
             Charts[ks].BackColor:=clWhite;
             Charts[ks].LeftAxis.Inverted:=true;
             Charts[ks].BottomAxis.Alignment:=calTop;
             Width:=250;
          end;

          AddLineSeries(Charts[ks]);
     end;

     CDS.CreateDataSet;
     CDS.IndexFieldNames:=CDS.FieldbyName('Lev_m').FieldName+';'+
                          CDS.FieldbyName('Lev_dbar').FieldName;

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
    CheckListBox1.Width :=Ini.ReadInteger( 'parameters_station', 'listbox1', 200);
    pCharts.Height      :=Ini.ReadInteger( 'parameters_station', 'pCharts',  200);
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
k, fl, ff, count_st, units_id, Flag_:integer;
cur_l, Val_, min_lev, max_lev:real;
lev_d, lev_m: Variant;
Units_, par, par_name, col_title:string;

TRt:TSQLTransaction;
Qt:TSQLQuery;
begin

//Memo1.Clear; Memo1.Visible:=false;
Caption:='All parameters: '+inttostr(ID);
CheckListBox1.Clear;

 try
  CDS.DisableControls;
   if CDS.Active then begin
    CDS.Close;
   end;
  CDS.Open;

  DS1.DataSet:=CDS;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

 // showmessage('here2');
  min_lev:=9999;
  max_lev:= -9999;
  for k:=0 to frmosmain.ListBox1.Items.Count-1 do begin
    TLineSeries(Charts[k].Series[0]).Clear;

    par:=frmosmain.listbox1.Items.Strings[k];

      with Qt do begin
       Close;
         Sql.Clear;
         SQL.Add(' SELECT ');
         SQL.Add( par+'.LEV_DBAR, '+par+'.LEV_M, '+par+'.VAL, ');
         SQL.Add( par+'.PQF2,'+ par+'.UNITS_ID, UNITS.NAME_SHORT ');
         SQL.Add(' FROM ');
         SQL.Add( par+', UNITS ');
         SQL.Add(' WHERE ');
         SQL.Add( par+'.UNITS_ID=UNITS.ID AND ');
         SQL.Add( par+'.ID=:ID ');
         SQL.Add(' order by LEV_DBAR, LEV_M');
         ParamByName('ID').AsInteger:=ID;
       Open;
      end;

  //  showmessage(inttostr(Qt.RecordCount));
  Qt.First;
  Count_st:=0; cur_l:=-9;
    while not Qt.eof do begin
      Lev_m   :=Qt.FieldByName('LEV_M').AsVariant;
      Lev_d   :=Qt.FieldByName('LEV_DBAR').AsVariant;
      Val_    :=Qt.FieldByName('VAL').AsFloat;
      Flag_   :=Qt.FieldByName('PQF2').AsInteger;
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
             CDS.FieldByName(par).AsFloat:=Val_;
             CDS.FieldByName(par+'_FL').AsInteger:=Flag_;
            CDS.Post;  fl:=0;
        end;
        CDS.Next;
      end;

      if fl=1 then begin
         CDS.Append;
         if not VarIsNull(Lev_d) then CDS.FieldByName('LEV_DBAR').AsFloat:=Lev_d;
         if not VarIsNull(Lev_m) then CDS.FieldByName('LEV_M').AsFloat:=Lev_m;
         CDS.FieldByName(par).AsFloat:=Val_;
         CDS.FieldByName(par+'_FL').AsInteger:=Flag_;
         CDS.Post;
      end;
      inc(Count_st);
     // cur_l:=lev;
      TLineSeries(Charts[k].Series[0]).AddXY(val_,lev_m);
      Qt.Next;
    end;
    Qt.Close;

    par_name:='['+inttostr(count_st)+']  '+copy(par,3,length(par))+' ';
    CheckListBox1.Items.Add(par_name);

    col_title:=Copy(par, 3, length(par));
    col_title:=Copy(col_title, 1, Pos('_', col_title)+3);

    Charts[k].Title.Text.Clear;
    Charts[k].Title.Text.Add(col_title);
    Charts[k].Title.Text.Add(Units_);

    if Count_st>0 then begin
       CheckListBox1.Checked[k]:=true;
       CDS.FieldByName(par).visible:=true;
       CDS.FieldByName(par+'_FL').visible:=true;
       Charts[k].Visible:=true;
    end;

    if Count_st=0 then begin
       CDS.FieldByName(par).visible:=false;
       CDS.FieldByName(par+'_FL').visible:=false;
       Charts[k].Visible:=false;
    end;

   Application.ProcessMessages;
  end;

 // showmessage(floattostr(min_lev)+'   '+floattostr(max_lev));

  for k:=0 to length(Charts)-1 do begin
    Charts[k].LeftAxis.Range.Min:=min_lev;
    Charts[k].LeftAxis.Range.Max:=max_lev;
    Charts[k].LeftAxis.Range.UseMin:=true;
    Charts[k].LeftAxis.Range.UseMax:=true;
  end;

 (* settings for the grid *)
  DBGrid1.Columns[0].Title.Caption:='Level, dBar';
  DBGrid1.Columns[1].Title.Caption:='Level, m';
  for k:=2 to DBGrid1.Columns.Count-1 do begin
   col_title:=DBGrid1.Columns[k].Title.Caption;

    if (k mod 2<>1) then begin
      col_title:=Copy(col_title, 3, length(col_title));
     // col_title:=Copy(col_title, 1, Pos('_', col_title)+3);
      DBGrid1.Columns[k].Title.Caption:=col_title;
      DBGrid1.Columns[k].Width:=80;
    end;

    if (k mod 2=1) then begin
      DBGrid1.Columns[k].Title.Caption:='QF';
      DBGrid1.Columns[k].Width:=40;
      //QCFlags
      with DBGrid1.Columns[k].PickList do begin
        for ff:=0 to 8 do Add(inttostr(ff));
      end;
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
 end;

 // DBGridEh1.SumList.RecalcAll;
  CheckChartSize;
end;


procedure Tfrmprofile_station_all.btnCommitClick(Sender: TObject);
Var
ID, k, levnum:integer;
tbl:string;
Qt:TSQLQuery;
TRt:TSQLTransaction;
begin
ID:=frmdm.Q.FieldByName('ID').AsInteger;

try
 CDS.DisableControls;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

 For k:=0 to CheckListBox1.Items.Count-1 do
   if CheckListBox1.Checked[k] then begin
     tbl:=CheckListBox1.Items.Strings[k];
     tbl:='P_'+trim(copy(tbl, pos(' ', tbl), length(tbl)));
      if copy(tbl, length(tbl)-1, 1)=']' then
       tbl:=copy(tbl, 1, pos(' ', tbl)-1);

    //  showmessage(tbl);
    try
     CDS.First; LevNum:=0;
     while not cds.Eof do begin

       if not CDS.FieldByName(tbl).IsNull then begin
        with Qt do begin
           Close;
              Sql.Clear;
              SQL.Add(' UPDATE ');
              SQL.Add(tbl);
              SQL.Add(' SET '+tbl+'.PQF2=:fl ');
              SQL.Add(' WHERE ' );
              SQL.Add(' ID=:ID AND LEV_DBAR=:lev_d ');
              ParamByName('ID').AsInteger:=ID;
              ParamByName('lev_d').AsFloat:=CDS.FieldByName('lev_dbar').AsFloat;
              ParamByName('fl').AsInteger:=CDS.FieldByName(tbl+'_FL').AsInteger;
           ExecSQL;
        end;
       end;
      CDS.Next;
    end;
     TRt.Commit;
    except
     On E :Exception do begin
      ShowMessage(E.Message);
      TRt.Rollback;
     end;
    end;
   end;
  finally
   CDS.EnableControls;
   Qt.Free;
   TRt.Free;
  end;


{ try
 CDS.DisableControls;

  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=frmdm.TR;

 For k:=0 to frmosmain.listbox1.Items.Count-1 do begin
    tbl:=frmosmain.listbox1.Items.Strings[k];

    Qt.Close;
    Qt.SQL.Text:='Delete from '+tbl+' where ID=:ID';
    Qt.ParamByName('ID').AsInteger:=ID;
    Qt.ExecSQL;
    frmdm.TR.CommitRetaining;

    try
     CDS.First; LevNum:=0;
     while not cds.Eof do begin

       if not CDS.FieldByName(tbl).IsNull then begin
        with Qt do begin
           Close;
              Sql.Clear;
              SQL.Add('insert into');
              SQL.Add(tbl);
              SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF2, UNITS_ID) ');
              SQL.Add(' VALUES ' );
              SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF2, :UNITS_ID) ');
              ParamByName('ID').AsInteger:=ID;
              ParamByName('LEV_DBAR').AsFloat:=CDS.FieldByName('lev_dbar').AsFloat;
              ParamByName('LEV_M').AsFloat:=CDS.FieldByName('lev_m').AsFloat;
              ParamByName('VAL').AsFloat:=CDS.FieldByName(tbl).AsFloat;
              ParamByName('PQF2').AsInteger:=CDS.FieldByName(tbl+'_FL').AsInteger;
             // ParamByName('UNITS_ID').AsInteger:=CDS.FieldByName(tbl+'_FL').AsInteger;
           ExecSQL;
        end;
       end;
      CDS.Next;
    end;
     frmdm.TR.Commit;
    except
     On E :Exception do begin
      ShowMessage(E.Message);
      frmdm.TR.Rollback;
     end;
    end;
   end;
  finally
   CDS.EnableControls;
   Qt.Free;
  end;   }
ChangeID(ID);
if frmprofile_plot_all_open=true then frmprofile_plot_all.AddToPlot(ID, true);
end;


procedure Tfrmprofile_station_all.CheckChartSize;
Var
k, CountChecked:integer;
begin
  CountChecked:=0;
 //  for k:=0 to CheckListBox1.Count-1 do if CheckListBox1.Checked[k]=true then inc(CountChecked);
 //   if CountChecked>0 then
 //    for k:=0 to frmosmain.listbox1.Items.Count-1 do Charts[k].Width:=round(pCharts.Width/CountChecked);
 //  if memo1.Lines.Count>0 then memo1.Visible:=true;
end;

procedure Tfrmprofile_station_all.btnAddClick(Sender: TObject);
begin
  CDS.Insert;
end;

procedure Tfrmprofile_station_all.btnDeleteClick(Sender: TObject);
begin
  CDS.Delete;
end;


procedure Tfrmprofile_station_all.CheckListBox1Click(Sender: TObject);
var
k:integer;
cap_par, par:string;
begin
try
  par:=CheckListBox1.Items.Strings[CheckListBox1.ItemIndex];
  par:='P_'+trim(copy(par, pos(' ', par), length(par)));
    if copy(par, length(par)-1, 1)=']' then par:=copy(par, 1, pos(' ', par)-1);
  cap_par:=trim(Copy(Par, 3, Length(Par)));

 // showmessage(par+'   '+cap_par);

   if CheckListBox1.Checked[CheckListBox1.ItemIndex]= true then begin
     CDS.FieldByName(Par).Visible:=true;
     CDS.FieldByName(Par+'_FL').Visible:=true;
       for k:=2 to DBGrid1.Columns.Count-1 do
          if (k>0) and (k mod 2=1) then DBGrid1.Columns[k].Title.Caption:='QF';
       for k:=0 to frmosmain.listbox1.Count-1 do
          if Charts[k].Title.Text[0]=cap_par then Charts[k].Visible:=true;
   end else begin
      CDS.FieldByName(Par).Visible:=false;
      CDS.FieldByName(Par+'_FL').Visible:=false;
    for k:=0 to frmosmain.listbox1.Count-1 do
      if Charts[k].Title.Text[0]=cap_par then Charts[k].Visible:=false;
   end;
   CDS.First;
  except
end;
end;


procedure Tfrmprofile_station_all.DBGridEh1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
Var
Ini:TIniFile;
DelEnable:boolean;
begin
(* Удаление строчки при нажатии Del *)
{    Ini := TIniFile.Create(IniFileName);
    try
     DelEnable:=Ini.ReadBool( 'Selection', 'Del_enable', false);
    Finally
     Ini.Free;
    end;
  if (key=VK_DELETE) and (DelEnable=true) then btnDelete.OnClick(self); }
end;

procedure Tfrmprofile_station_all.iDeleteParameterClick(Sender: TObject);
Var
ID:integer;
Par:string;

TRt:TSQLTransaction;
Qt:TSQLQuery;
begin
ID:=frmdm.Q.FieldByName('ID').AsInteger;

 TRt:=TSQLTransaction.Create(self);
 TRt.DataBase:=frmdm.IBDB;

 Qt :=TSQLQuery.Create(self);
 Qt.Database:=frmdm.IBDB;
 Qt.Transaction:=TRt;

 try
   par:=DBGrid1.SelectedField.FieldName;
   if Copy(par,1,2)<>'P_' then exit;
   if Copy(par,length(par)-2,3)='_FL' then Delete(par,length(par)-2,length(par));

   if Messagedlg('Delete '+par+' ?',mtconfirmation, [mbYes,mbNo],0)=mrYes then begin
    with Qt do begin
      Close;
        SQL.Text:='Delete from '+Par+' where ID='+inttostr(ID);
      ExecSQL;
    end;
    Trt.Commit;
   end;
 finally
  Qt.Close;
  Qt.Free;
  TRt.Free;
 end;

 ChangeID(ID);
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
     if (ProfFlag<>999) and (ProfFlag<>777) then begin
      For k:=0 to frmosmain.listbox1.Items.Count-1 do begin
       tbl:=frmosmain.listbox1.Items.Strings[k];
       CDS.First;
       while not CDS.Eof do begin
         CDS.Edit;
          CDS.FieldByName(tbl+'_FL').AsFloat:=ProfFlag;
         CDS.Post;
        CDS.Next;
       end;
      end;
     end;

    // flag above selected level
     if ProfFlag=777 then begin
      Cur_pos:=CDS.RecNo;
      For k:=0 to frmosmain.listbox1.Items.Count-1 do begin
       tbl:=frmosmain.listbox1.Items.Strings[k];
       CDS.RecNo:=Cur_pos;
       repeat
         CDS.Edit;
          CDS.FieldByName(tbl+'_FL').AsFloat:=2;
         CDS.Post;
        CDS.Prior;
       until CDS.RecNo=1;
       CDS.First;
       CDS.Edit;
       CDS.FieldByName(tbl+'_FL').AsFloat:=2;
       CDS.Post;
      end;
     end;

  finally
   CDS.EnableControls;
  end;
end;

procedure Tfrmprofile_station_all.DBGrid1CellClick(Column: TColumn);
begin
  // For k:=0 to Charts.Count-1 do begin
  //  TLineSeries(series).SeriesColo
  // end;
end;

procedure Tfrmprofile_station_all.DBGrid1ColumnSized(Sender: TObject);
begin
  //pUnitsFiller.Width:=DBGrid1.Columns[0].Width+DBGrid1.Columns[1].Width;
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
       iDeleteParameter.Caption:='Delete '+Par;
       PM.PopUp;
  end;
end;

procedure Tfrmprofile_station_all.DBGrid1PrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
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
    Ini.WriteInteger( 'parameters_station', 'listbox1', CheckListBox1.Width);
    Ini.WriteInteger( 'parameters_station', 'pCharts',  pCharts.Height);
   finally
    ini.Free;
  end;
CDS.Free;

frmprofile_station_all_open:=false;
end;


procedure Tfrmprofile_station_all.FormDestroy(Sender: TObject);
begin
// Charts:=nil;
end;



end.
