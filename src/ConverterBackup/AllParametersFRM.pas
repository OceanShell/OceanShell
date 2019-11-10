unit AllParametersFRM;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ExtCtrls, DB, StdCtrls, ComCtrls, ToolWin, GridsEh, DBGridEh, CheckLst,
  TeEngine, DBClient, Chart, Series, IniFiles, Dialogs, Menus, DBGridEhGrouping,
  ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh, DBAxisGridsEh, EhLibVCL;

type
  TAllParameters = class(TForm)
    CheckListBox1: TCheckListBox;
    DBGridEh1: TDBGridEh;
    ToolBar1: TToolBar;
    btnAdd: TToolButton;
    btnDelete: TToolButton;
    ToolButton2: TToolButton;
    btnCommit: TToolButton;
    DS1: TDataSource;
    PopupMenu1: TPopupMenu;
    Memo1: TMemo;
    Splitter1: TSplitter;
    btnDeletePar: TMenuItem;
    btnSetFlag: TToolButton;
    ToolButton3: TToolButton;
    Setflag1: TMenuItem;
    N1: TMenuItem;
    Copyparameterstoanotherstation1: TMenuItem;
    N2: TMenuItem;
    Panel2: TPanel;
    pCharts: TPanel;
    Splitter2: TSplitter;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ShowAllProf(ID:integer);
    procedure btnCommitClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
    procedure DBGridEh1GetCellParams(Sender: TObject; Column: TColumnEh;
      AFont: TFont; var Background: TColor; State: TGridDrawState);
    procedure btnDeleteParClick(Sender: TObject);
    procedure SeriesClick(Sender: TChartSeries; ValueIndex: Integer;
    Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    procedure DBGridEh1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DBGridEh1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumnEh; State: TGridDrawState);
    procedure btnSetFlagClick(Sender: TObject);
    procedure Setflag1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DBGridEh1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Copyparameterstoanotherstation1Click(Sender: TObject);

  private
    procedure CheckChartSize;
  public
    { Public declarations }
  end;

var
  AllParameters: TAllParameters;
  CDS:TClientDataSet;
  Charts:array of TChart;
  TMPSeries:array of TChartSeries;
  Ks:integer;

implementation

uses MainFRM, ODBDMFRM, QProfilesFRM, SetFlagFRM, StandartQueries;

{$R *.dfm}

procedure TAllParameters.FormCreate(Sender: TObject);
Var
ID:Integer;
par:string;
begin
  SetLength(Charts,    Main.ListBox2.Count);
  SetLength(TMPSeries, Main.ListBox2.Count);

   CDS:=TClientDataSet.Create(nil);
    CDS.FieldDefs.Add('Level',ftFloat,0,true);
     for ks:=0 to Main.ListBox2.Items.Count-1 do begin
      Par:=Main.ListBox2.Items.Strings[ks];
       CDS.FieldDefs.Add(Par,ftFloat,0,false);
       CDS.FieldDefs.Add(Par+'_FL',ftInteger,0,false);

        Charts[ks]:=TChart.Create(Self);
          with Charts[ks] do begin
             Parent:=pCharts;
             Align:=alLeft;
             View3D:=false;
             Legend.Visible:=false;
             LeftAxis.Inverted:=true;
             Title.Caption:=Copy(Par, 3, length(Par));
             Walls.Back.Color:=clWhite;
             Walls.Back.Transparent:=false;
          end;

        TMPSeries[ks]:=TLineSeries.Create(Charts[ks]);
          with TMPSeries[ks] as TLineSeries  do begin
             Color:=clBlue;
             ParentChart:=Charts[ks];
             XValues.order:=lonone;
             YValues.order:=lonone;
             XValues.ValueSource:=Par;
             YValues.ValueSource:='Level';
             Pointer.Style:=psCircle;
             Pointer.HorizSize:=3;
             Pointer.VertSize:=3;
             Pointer.Visible:=true;
             Cursor:=crHandPoint;
          end;
       TMPSeries[ks].OnClick:=SeriesClick;
     end;
    CDS.CreateDataSet;
    CDS.LogChanges:=false;
    CDS.IndexFieldNames:=CDS.FieldbyName('Level').FieldName;

 ID:=ODBDM.CDSMD.FieldByName('Absnum').AsInteger;
ShowAllProf(ID);

ToolBar1.Visible:=not Restriction;
end;


procedure TAllParameters.FormShow(Sender: TObject);
Var
  Ini:TInifile;
  m, x, y, i:integer;
begin
Ini := TIniFile.Create(IniFileName);
  try
   (* Задаем положение формы *)
    Width :=Ini.ReadInteger( 'AllPar', 'Width',  600);
    Height:=Ini.ReadInteger( 'AllPar', 'Height', 500);

    //реальное разрешение экрана (включая дополнительные мониторы
    Monitor; // Геттер этого свойства обновит список TScreen.Monitors

    m:=Screen.MonitorCount;
    x:=0; y:=0;
    for i:=0 to m-1 do begin
      x:=x+Screen.Monitors[i].Width;
      y:=y+Screen.Monitors[i].Height;
    end;

     if Ini.ReadInteger('AllPar', 'Left', 0)<x then
        Left:=Ini.ReadInteger( 'AllPar', 'Left', 0) else
        Left:=0;

     if Ini.ReadInteger('AllPar', 'Top', Main.Height)<y then
        Top:=Ini.ReadInteger( 'AllPar', 'Top', Main.Height) else
        Top:=155;
   (* конец определения положения формы *)

    CheckListBox1.Width :=Ini.ReadInteger( 'AllPar', 'List box', 125 );
    Panel2.Height       :=Ini.ReadInteger( 'AllPar', 'Panel2',   320);
  finally
   Ini.Free;
  end;
end;


procedure TAllParameters.FormResize(Sender: TObject);
begin
  CheckChartSize;
end;


procedure TAllParameters.ShowAllProf(ID:integer);
Var
k, fl,count_st:integer;
cur_l, lev, Val, Flag_:real;
Units, par_name:string;
begin

Memo1.Clear; Memo1.Visible:=false;
CheckListBox1.Clear;

 try
  CDS.EmptyDataSet;
  CDS.Close;
  CDS.Open;

  CDS.DisableControls;
  DS1.DataSet:=CDS;

  ODBDM.IBTransaction1.StartTransaction;
  for k:=0 to Main.ListBox2.Items.Count-1 do begin
  TMPSeries[k].Clear;

    with ODBDM.ib1q1 do begin
       Close;
         Sql.Clear;
         SQL.Add('select * from ');
         SQL.Add( Main.ListBox2.Items.Strings[k] );
         SQL.Add(' where absnum=:absnum ');
         SQL.Add(' order by level_');
         ParamByName('absnum').AsInteger:=ID;
       Open;
    end;

  ODBDM.ib1q1.First; Count_st:=0; cur_l:=-9;
    while not ODBDM.ib1q1.eof do begin

      Lev:=ODBDM.ib1q1.FieldByName('level_').AsFloat;
      Val:=ODBDM.ib1q1.FieldByName('Value_').AsFloat;
      Flag_:=ODBDM.ib1q1.FieldByName('Flag_').AsFloat;

      if cur_l=lev then memo1.Lines.Add(Main.ListBox2.Items.Strings[k]+
                        '-> level: '+floattostr(lev)+' has duplicate!');

      CDS.First; Fl:=1;
      while not CDS.Eof do begin
        if CDS.Fields[0].AsFloat=Lev then begin
            CDS.edit;
             CDS.FieldByName(Main.ListBox2.Items.Strings[k]).AsFloat:=Val;
             CDS.FieldByName(Main.ListBox2.Items.Strings[k]+'_FL').AsFloat:=Flag_;
            CDS.Post;  fl:=0;
        end;
        CDS.Next;
      end;

      if fl=1 then begin
         CDS.Append;
         CDS.Fields[0].AsFloat:=Lev;
         CDS.FieldByName(Main.ListBox2.Items.Strings[k]).AsFloat:=Val;
         CDS.FieldByName(Main.ListBox2.Items.Strings[k]+'_FL').AsFloat:=Flag_;
         CDS.Post;
      end;
      inc(Count_st);
      cur_l:=lev;
      TMPSeries[k].AddXY(val, lev);
      ODBDM.ib1q1.Next;
    end;
    ODBDM.ib1q1.Close;

    ODBDM.GetUnits(ID, Main.ListBox2.Items.Strings[k], Units);

    par_name:='['+inttostr(count_st)+']  '+copy(Main.ListBox2.Items.Strings[k],3,length(Main.ListBox2.Items.Strings[k]))+' ';
     if Units<>'' then par_name:=par_name+'['+Units+']';
    CheckListBox1.Items.Add(par_name);

    if Count_st>0 then begin
       CheckListBox1.Checked[k]:=true;
       Charts[k].Visible:=true;
    end;

    if Count_st=0 then begin
       CDS.FieldByName(Main.ListBox2.Items.Strings[k]).visible:=false;
       CDS.FieldByName(Main.ListBox2.Items.Strings[k]+'_FL').visible:=false;
       Charts[k].Visible:=false;
    end;

   Application.ProcessMessages;
  end;
 finally
  ODBDM.IBTransaction1.Commit;
  CDS.First;
  CDS.EnableControls;
 end;

  for k:=0 to DBGridEh1.Columns.Count-1 do begin
    if (k>0) and (k mod 2<>1) then begin
      DBGridEh1.Columns[k].Title.Caption:='Flag';
      with DBGridEh1.Columns[k].PickList do begin  //Добавляем флаги в список
        Add('0');
        Add('16384');
      end;
      end else begin
      DBGridEh1.Columns[k].Footer.ValueType:=fvtAvg;
    end;
  end;
  DBGridEh1.SumList.RecalcAll;
  CheckChartSize;
end;


procedure TAllParameters.btnCommitClick(Sender: TObject);
Var
ID, k, levnum:integer;
tbl:string;
begin
ID:=ODBDM.CDSMD.FieldByName('absnum').AsInteger;
ODBDM.IBTransaction1.StartTransaction;

 try
 CDS.DisableControls;
 For k:=0 to Main.ListBox2.Items.Count-1 do begin
    tbl:=Main.ListBox2.Items.Strings[k];

    ODBDM.ib1q1.Close;
    ODBDM.ib1q1.SQL.Text:='Delete from '+tbl+' where absnum=:absnum';
    ODBDM.ib1q1.ParamByName('absnum').AsInteger:=ID;
    ODBDM.ib1q1.ExecSQL;
    ODBDM.IBTransaction1.CommitRetaining;

     CDS.First; LevNum:=0;
     while not cds.Eof do begin
       inc(levnum);
       if CDS.FieldByName(tbl).IsNull=false then begin
         with ODBDM.ib1q1 do begin
           Close;
              Sql.Clear;
              SQL.Add('insert into');
              SQL.Add(tbl);
              if IniDB=false then SQL.Add(' (absnum, level_, value_, flag_) ') else
                                  SQL.Add(' (absnum, levelnum, level_, value_, flag_) ');
              SQL.Add(' VALUES ' );
              if IniDB=false then SQL.Add(' (:absnum, :level_, :value_, :flag_) ') else
                                  SQL.Add(' (:absnum, :levelnum, :level_, :value_, :flag_) ');
              ParamByName('absnum').AsInteger:=ID;
              ParamByName('Level_').AsFloat:=CDS.FieldByName('level').AsFloat;
              ParamByName('Value_').AsFloat:=CDS.FieldByName(tbl).AsFloat;
                if IniDB=true then ParamByName('levelnum').AsInteger:=levnum;
              ParamByName('flag_').AsFloat:=CDS.FieldByName(tbl+'_FL').AsFloat;
           ExecSQL;
        end;
       end;
      CDS.Next;
    end;
  end;
  finally
   CDS.EnableControls;
   ODBDM.IBTransaction1.Commit;
  end;
ShowAllProf(ID);
if QProfilesOpen=true then QProfiles.UpdateProfile(ID);
end;


procedure TAllParameters.CheckChartSize;
Var
k, CountChecked:integer;
begin
  CountChecked:=0;
   for k:=0 to CheckListBox1.Count-1 do if CheckListBox1.Checked[k]=true then inc(CountChecked);
    if CountChecked>0 then
     for k:=0 to Main.ListBox2.Items.Count-1 do Charts[k].Width:=round(pCharts.Width/CountChecked);
   if memo1.Lines.Count>0 then memo1.Visible:=true;
end;

procedure TAllParameters.btnAddClick(Sender: TObject);
begin
  CDS.Insert;
end;

procedure TAllParameters.btnDeleteClick(Sender: TObject);
begin
  CDS.Delete;
end;


procedure TAllParameters.CheckListBox1Click(Sender: TObject);
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
       for k:=0 to DBGridEh1.Columns.Count-1 do begin
          if (k>0) and (k mod 2<>1) then DBGridEh1.Columns[k].Title.Caption:='Flag';
           DBGridEh1.Columns[k].Footer.ValueType:=fvtAvg;
           DBGridEh1.SumList.RecalcAll;
       end;
    for k:=0 to Main.ListBox2.Count-1 do if Charts[k].Title.Caption=cap_par then Charts[k].Visible:=true;
   end else
    begin
      CDS.FieldByName(Par).Visible:=false;
      CDS.FieldByName(Par+'_FL').Visible:=false;
    for k:=0 to Main.ListBox2.Count-1 do if Charts[k].Title.Caption=cap_par then Charts[k].Visible:=false;
    end;
   CDS.First;
  except
end;
end;


procedure TAllParameters.SeriesClick(Sender: TChartSeries; ValueIndex: Integer;
    Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
Var
Num_Clicked:int64;
LVar:array[0..1] of Variant;
begin
with Sender do begin
  Num_Clicked:=Clicked(X,Y);
    if Num_Clicked<>-1 then begin
    //  if X>=Sender.ParentChart.Width-Panel1.Width then Panel1.Left:=X-Panel1.Width else Panel1.Left:=X;
    //  if Y>=Sender.ParentChart.Height-Panel1.Height-20 then Panel1.Top:=Y-Panel1.Height else Panel1.Top:=Y;
      CDS.Locate('Level', YValues[Num_clicked], [loCaseInsensitive]);
  //    lbLevel.Caption:='Level='+floattostr(YValues[Num_clicked]);
  //    lbValue.Caption:='Value='+floattostr(XValues[Num_clicked]);
    end;
  end;
end;


procedure TAllParameters.DBGridEh1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumnEh;
  State: TGridDrawState);
begin
 if (Rect.Top =TDBGridEh(sender).CellRect(TDBGridEh(sender).Col,TDBGridEh(sender).Row).Top) and
  not (gdFocused in State) then begin
   TDBGridEh(sender).Canvas.Brush.Color := clNavy;
   TDBGridEh(sender).Canvas.Font.Color:= clWhite;
   TDBGridEh(sender).Canvas.Font.Style:=[fsBold];
 end;
 if gdFocused in State then begin
   TDBGridEh(sender).Canvas.Brush.Color := clHighLight;
   TDBGridEh(sender).Canvas.Font.Color:= clYellow;
   TDBGridEh(sender).Canvas.Font.Style:=[fsBold];
 end;
TDBGridEh(sender).DefaultDrawColumnCell(Rect,DataCol,Column,State);
end;


procedure TAllParameters.DBGridEh1GetCellParams(Sender: TObject;
  Column: TColumnEh; AFont: TFont; var Background: TColor;
  State: TGridDrawState);
begin
 if DBGridEh1.SumList.RecNo mod 2=1 then
       Background:=$00CFFFF6 else Background:=$00CFEFE6;
end;


procedure TAllParameters.DBGridEh1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
Var
Ini:TIniFile;
DelEnable:boolean;
begin
(* Удаление строчки при нажатии Del *)
    Ini := TIniFile.Create(IniFileName);
    try
     DelEnable:=Ini.ReadBool( 'Selection', 'Del enable', false);
    Finally
     Ini.Free;
    end;
  if (key=VK_DELETE) and (DelEnable=true) then btnDelete.OnClick(self);
end;

procedure TAllParameters.btnDeleteParClick(Sender: TObject);
Var
ID:integer;
Par:string;
begin
ID:=ODBDM.CDSMD.FieldByName('Absnum').AsInteger;
par:=DBGridEh1.SelectedField.FieldName;
if Copy(par,1,2)<>'P_' then exit;
if Copy(par,length(par)-2,3)='_FL' then Delete(par,length(par)-2,length(par));
 //par:='P_'+ComboBox1.Text;
 if Messagedlg('Delete '+par+' ?',mtconfirmation, [mbYes,mbNo],0)=mrYes then begin
  ODBDM.IBTransaction1.StartTransaction;
    with ODBDM.ib1qq1 do begin
      Close;
        SQL.Text:='Delete from '+Par+' where absnum='+inttostr(ID);
      ExecQuery;
    end;
  ODBDM.IBTransaction1.Commit;
  ShowAllProf(ID);
 end;
end;


(* Ставим флаги на ВСЕ параметры *)
procedure TAllParameters.btnSetFlagClick(Sender: TObject);
Var
k, cur_pos:integer;
tbl:string;
begin
  SetFlag:= TSetFlag.Create(Self);
   SetFlag.Top:=Top+btnSetFlag.Height+30;
   SetFlag.Left:=Left+btnSetFlag.Left+5;
  try
   if SetFlag.ShowModal = mrOk then
   finally
    SetFlag.Free;
    SetFlag := nil;
  end;

  if ProfFlag=-9 then exit; // Оставляем старый флаг

   try
   CDS.DisableControls;
     if (ProfFlag<>999) and (ProfFlag<>777) then begin
      For k:=0 to Main.ListBox2.Items.Count-1 do begin
       tbl:=Main.ListBox2.Items.Strings[k];
       CDS.First;
       while not CDS.Eof do begin
         CDS.Edit;
          CDS.FieldByName(tbl+'_FL').AsFloat:=ProfFlag;
         CDS.Post;
        CDS.Next;
       end;
      end;
     end;

    if ProfFlag=999 then begin
      Cur_pos:=CDS.RecNo;
      For k:=0 to Main.ListBox2.Items.Count-1 do begin
       tbl:=Main.ListBox2.Items.Strings[k];
       CDS.RecNo:=Cur_pos;
       while not CDS.Eof do begin
        CDS.Edit;
         CDS.FieldByName(tbl+'_FL').AsFloat:=16384;
        CDS.Post;
       CDS.Next;
       end;
      end;
     end;

     if ProfFlag=777 then begin
      Cur_pos:=CDS.RecNo;
      For k:=0 to Main.ListBox2.Items.Count-1 do begin
       tbl:=Main.ListBox2.Items.Strings[k];
       CDS.RecNo:=Cur_pos;
       repeat
         CDS.Edit;
          CDS.FieldByName(tbl+'_FL').AsFloat:=16384;
         CDS.Post;
        CDS.Prior;
       until CDS.RecNo=1;
       CDS.First;
       CDS.Edit;
       CDS.FieldByName(tbl+'_FL').AsFloat:=16384;
       CDS.Post;
      end;
     end;

  finally
   CDS.EnableControls;
  end;

end;


(* Ставим флаг на отдельный профиль *)
procedure TAllParameters.Setflag1Click(Sender: TObject);
Var
Par:string;
Coord: TPoint;
begin
  SetFlag:= TSetFlag.Create(Self);

  GetCursorPos(Coord);
  SetFlag.Top:=Coord.Y;
  SetFlag.Left:=Coord.X;

  try
   if SetFlag.ShowModal = mrOk then
  finally
    SetFlag.Free;
    SetFlag := nil;
  end;
  if ProfFlag=-9 then exit;

  par:=DBGridEh1.SelectedField.FieldName;
  if Par='Level' then exit;
  if Copy(par,length(par)-2,3)<>'_FL' then Par:=Par+'_FL';

  try
   CDS.DisableControls;
    CDS.First;
    while not cds.Eof do begin
     if CDS.FieldByName(Par).IsNull=false then begin
      CDS.Edit;
       CDS.FieldByName(Par).AsFloat:=ProfFlag;
      CDS.Post;
     end;
    CDS.Next;
   end;
  finally
   CDS.First;
   CDS.EnableControls;
  end;
end;


procedure TAllParameters.DBGridEh1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (ssAlt in Shift) then Main.DBGridSaveAsActExecute(Sender);
end;


procedure TAllParameters.Copyparameterstoanotherstation1Click(Sender: TObject);
begin
 //
end;


procedure TAllParameters.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger( 'AllPar', 'Top',      Top);
    Ini.WriteInteger( 'AllPar', 'Left',     Left);
    Ini.WriteInteger( 'AllPar', 'Height',   Height);
    Ini.WriteInteger( 'AllPar', 'Width',    Width);
    Ini.WriteInteger( 'AllPar', 'List box', CheckListBox1.Width);
    Ini.WriteInteger( 'AllPar', 'Panel2',   Panel2.Height);
   finally
    ini.Free;
  end;
DBGridEh1.SumList.Active:=false;
CDS.Free;
AllParamOpen:=false;
action:=cafree;
end;
end.
