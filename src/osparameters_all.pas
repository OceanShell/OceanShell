unit osparameters_all;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, ExtCtrls, DB, StdCtrls, ComCtrls, CheckLst,
  BufDataSet, IniFiles, Dialogs, Menus, DBGrids, SQLDB;

type

  { Tfrmparametersall }

  Tfrmparametersall = class(TForm)
    CheckListBox1: TCheckListBox;
    DBGrid1: TDBGrid;
  //  DBGridEh1: TDBGridEh;
    ToolBar1: TToolBar;
    btnAdd: TToolButton;
    btnDelete: TToolButton;
    ToolButton2: TToolButton;
    btnCommit: TToolButton;
    DS1: TDataSource;
    PM: TPopupMenu;
    Splitter1: TSplitter;
    iDeleteParameter: TMenuItem;
    btnSetFlag: TToolButton;
    ToolButton3: TToolButton;
    iSetFlagParameter: TMenuItem;
    N1: TMenuItem;

    procedure DBGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ShowAllProf(ID:integer);
    procedure btnCommitClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
 {   procedure DBGridEh1GetCellParams(Sender: TObject; Column: TColumnEh;
      AFont: TFont; var Background: TColor; State: TGridDrawState); }
    procedure iDeleteParameterClick(Sender: TObject);
{    procedure SeriesClick(Sender: TChartSeries; ValueIndex: Integer;
    Button: TMouseButton; Shift: TShiftState; X,Y: Integer);  }
    procedure DBGridEh1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
 {   procedure DBGridEh1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumnEh; State: TGridDrawState);  }
    procedure btnSetFlagClick(Sender: TObject);
    procedure iSetFlagParameterClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DBGridEh1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);

  private
    procedure CheckChartSize;
  public
    { Public declarations }
  end;

var
  frmparametersall: Tfrmparametersall;
  CDS:TBufDataSet;
//  Charts:array of TChart;
//  TMPSeries:array of TChartSeries;
  Ks:integer;

implementation

uses osmain, dm;

{$R *.lfm}

procedure Tfrmparametersall.FormCreate(Sender: TObject);
Var
ID:Integer;
par:string;
begin
 { SetLength(Charts,    frmosmain.listbox1Count);
  SetLength(TMPSeries, frmosmain.listbox1Count); }

   CDS:=TBufDataSet.Create(nil);
    CDS.FieldDefs.Add('Level',ftFloat,0,true);
     for ks:=0 to frmosmain.ListBox1.Items.Count-1 do begin
      Par:=frmosmain.ListBox1.Items.Strings[ks];

       CDS.FieldDefs.Add(Par,ftFloat,0,false);
       CDS.FieldDefs.Add(Par+'_FL',ftInteger,0,false);

     {   Charts[ks]:=TChart.Create(Self);
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
       TMPSeries[ks].OnClick:=SeriesClick;  }
     end;

     CDS.CreateDataSet;
 //   CDS.LogChanges:=false;
    CDS.IndexFieldNames:=CDS.FieldbyName('Level').FieldName;

 ID:=frmdm.Q.FieldByName('ID').AsInteger;
// showmessage('here');
ShowAllProf(ID);
end;


procedure Tfrmparametersall.FormShow(Sender: TObject);
Var
  Ini:TInifile;
begin
Ini := TIniFile.Create(IniFileName);
  try
    Top   :=Ini.ReadInteger( 'AllPar', 'Top',    50);
    Left  :=Ini.ReadInteger( 'AllPar', 'Left',   50);
    Width :=Ini.ReadInteger( 'AllPar', 'Width',  900);
    Height:=Ini.ReadInteger( 'AllPar', 'Height', 500);
    CheckListBox1.Width :=Ini.ReadInteger( 'AllPar', 'listbox1', 200 );
  //  Panel2.Height       :=Ini.ReadInteger( 'AllPar', 'Panel2',   320);
  finally
   Ini.Free;
  end;
end;


procedure Tfrmparametersall.FormResize(Sender: TObject);
begin
  CheckChartSize;
end;


procedure Tfrmparametersall.ShowAllProf(ID:integer);
Var
k, fl,count_st:integer;
cur_l, lev, Val, Flag_:real;
Units, par, par_name, col_title:string;

TRt:TSQLTransaction;
Qt:TSQLQuery;
begin

//Memo1.Clear; Memo1.Visible:=false;
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
  for k:=0 to frmosmain.ListBox1.Items.Count-1 do begin
 // TMPSeries[k].Clear;
  par:=frmosmain.listbox1.Items.Strings[k];

    with Qt do begin
       Close;
         Sql.Clear;
         SQL.Add('select * from ');
         SQL.Add( par );
         SQL.Add(' where ID=:ID ');
         SQL.Add(' order by PRES');
         ParamByName('ID').AsInteger:=ID;
       //  showmessage(Sql.Text);
       Open;
    end;

  //  showmessage(inttostr(Qt.RecordCount));
  Qt.First;
  Count_st:=0; cur_l:=-9;
    while not Qt.eof do begin

      Lev:=Qt.FieldByName('PRES').AsFloat;
      Val:=Qt.FieldByName('VAL').AsFloat;
      Flag_:=Qt.FieldByName('PQF2').AsFloat;

 //     showmessage(par+#9+floattostr(lev)+#9+floattostr(val));

  {    if cur_l=lev then memo1.Lines.Add(frmosmain.listbox1Items.Strings[k]+
                        '-> level: '+floattostr(lev)+' has duplicate!'); }

      CDS.First; Fl:=1;
      while not CDS.Eof do begin
        if CDS.Fields[0].AsFloat=Lev then begin
            CDS.edit;
             CDS.FieldByName(par).AsFloat:=Val;
             CDS.FieldByName(par+'_FL').AsFloat:=Flag_;
            CDS.Post;  fl:=0;
        end;
        CDS.Next;
      end;

      if fl=1 then begin
         CDS.Append;
         CDS.Fields[0].AsFloat:=Lev;
         CDS.FieldByName(par).AsFloat:=Val;
         CDS.FieldByName(par+'_FL').AsFloat:=Flag_;
         CDS.Post;
      end;
      inc(Count_st);
      cur_l:=lev;
      //TMPSeries[k].AddXY(val, lev);
      Qt.Next;
    end;
    Qt.Close;

//    ODBDM.GetUnits(ID, frmosmain.listbox1.Items.Strings[k], Units);

    par_name:='['+inttostr(count_st)+']  '+copy(par,3,length(par))+' ';
   //  if Units<>'' then par_name:=par_name+'['+Units+']';
    CheckListBox1.Items.Add(par_name);

    if Count_st>0 then begin
       CheckListBox1.Checked[k]:=true;
       CDS.FieldByName(par).visible:=true;
       CDS.FieldByName(par+'_FL').visible:=true;
 //      Charts[k].Visible:=true;
    end;

    if Count_st=0 then begin
       CDS.FieldByName(par).visible:=false;
       CDS.FieldByName(par+'_FL').visible:=false;
    //   Charts[k].Visible:=false;
    end;

   Application.ProcessMessages;
  end;

 (* settings for the grid *)
  for k:=0 to DBGrid1.Columns.Count-1 do begin
   col_title:=DBGrid1.Columns[k].Title.Caption;

    if (k>0) and (k mod 2=1) then begin
      col_title:=Copy(col_title, 3, length(col_title));
      col_title:=Copy(col_title, 1, Pos('_', col_title)+3);
      DBGrid1.Columns[k].Title.Caption:=col_title;
    end;

    if (k>0) and (k mod 2<>1) then begin
      DBGrid1.Columns[k].Title.Caption:='QF';
      DBGrid1.Columns[k].Width:=40;
      with DBGrid1.Columns[k].PickList do begin  //Добавляем флаги в список
        Add('0');
        Add('16384');
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


procedure Tfrmparametersall.btnCommitClick(Sender: TObject);
Var
ID, k, levnum:integer;
tbl:string;

TRt:TSQLTransaction;
Qt:TSQLQuery;
begin
ID:=frmdm.Q.FieldByName('ID').AsInteger;

 try
 CDS.DisableControls;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

 For k:=0 to frmosmain.listbox1.Items.Count-1 do begin
    tbl:=frmosmain.listbox1.Items.Strings[k];

    Qt.Close;
    Qt.SQL.Text:='Delete from '+tbl+' where ID=:ID';
    Qt.ParamByName('ID').AsInteger:=ID;
    Qt.ExecSQL;
    Trt.CommitRetaining;

     CDS.First; LevNum:=0;
     while not cds.Eof do begin
       inc(levnum);
       if CDS.FieldByName(tbl).IsNull=false then begin
         with Qt do begin
           Close;
              Sql.Clear;
              SQL.Add('insert into');
              SQL.Add(tbl);
              SQL.Add(' (ID, PRES, VAL, PQF2) ');
              SQL.Add(' VALUES ' );
              SQL.Add(' (:ID, :PRES, :VAL, :PQF2) ');
              ParamByName('ID').AsInteger:=ID;
              ParamByName('PRES').AsFloat:=CDS.FieldByName('level').AsFloat;
              ParamByName('VAL').AsFloat:=CDS.FieldByName(tbl).AsFloat;
              ParamByName('PQF2').AsFloat:=CDS.FieldByName(tbl+'_FL').AsFloat;
           ExecSQL;
        end;
       end;
      CDS.Next;
    end;
  end;
  finally
   CDS.EnableControls;
   Trt.Commit;
   Qt.Free;
   TrT.Free;
  end;
ShowAllProf(ID);
//if QProfilesOpen=true then QProfiles.UpdateProfile(ID);
end;


procedure Tfrmparametersall.CheckChartSize;
Var
k, CountChecked:integer;
begin
  CountChecked:=0;
   for k:=0 to CheckListBox1.Count-1 do if CheckListBox1.Checked[k]=true then inc(CountChecked);
  //  if CountChecked>0 then
  //   for k:=0 to frmosmain.listbox1.Items.Count-1 do Charts[k].Width:=round(pCharts.Width/CountChecked);
 //  if memo1.Lines.Count>0 then memo1.Visible:=true;
end;

procedure Tfrmparametersall.btnAddClick(Sender: TObject);
begin
  CDS.Insert;
end;

procedure Tfrmparametersall.btnDeleteClick(Sender: TObject);
begin
  CDS.Delete;
end;


procedure Tfrmparametersall.CheckListBox1Click(Sender: TObject);
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
       for k:=0 to DBGrid1.Columns.Count-1 do begin
          if (k>0) and (k mod 2<>1) then DBGrid1.Columns[k].Title.Caption:='QF';
     //      DBGrid1.Columns[k].Footer.ValueType:=fvtAvg;
     //      DBGrid1.SumList.RecalcAll;
       end;
 //   for k:=0 to frmosmain.listbox1.Count-1 do if Charts[k].Title.Caption=cap_par then Charts[k].Visible:=true;
   end else
    begin
      CDS.FieldByName(Par).Visible:=false;
      CDS.FieldByName(Par+'_FL').Visible:=false;
  //  for k:=0 to frmosmain.listbox1Count-1 do if Charts[k].Title.Caption=cap_par then Charts[k].Visible:=false;
    end;
   CDS.First;
  except
end;
end;


{procedure Tfrmparametersall.SeriesClick(Sender: TChartSeries; ValueIndex: Integer;
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
end; }


{procedure Tfrmparametersall.DBGridEh1DrawColumnCell(Sender: TObject;
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
end;     }

{
procedure Tfrmparametersall.DBGridEh1GetCellParams(Sender: TObject;
  Column: TColumnEh; AFont: TFont; var Background: TColor;
  State: TGridDrawState);
begin
 if DBGridEh1.SumList.RecNo mod 2=1 then
       Background:=$00CFFFF6 else Background:=$00CFEFE6;
end;
}

procedure Tfrmparametersall.DBGridEh1KeyUp(Sender: TObject; var Key: Word;
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

procedure Tfrmparametersall.iDeleteParameterClick(Sender: TObject);
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

 ShowAllProf(ID);
end;


(* Ставим флаги на ВСЕ параметры *)
procedure Tfrmparametersall.btnSetFlagClick(Sender: TObject);
Var
k, cur_pos:integer;
tbl:string;
begin
 {  SetFlag:= TSetFlag.Create(Self);
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
      For k:=0 to frmosmain.listbox1Items.Count-1 do begin
       tbl:=frmosmain.listbox1Items.Strings[k];
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
      For k:=0 to frmosmain.listbox1Items.Count-1 do begin
       tbl:=frmosmain.listbox1Items.Strings[k];
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
      For k:=0 to frmosmain.listbox1Items.Count-1 do begin
       tbl:=frmosmain.listbox1Items.Strings[k];
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
  end; }

end;


(* Ставим флаг на отдельный профиль *)
procedure Tfrmparametersall.iSetFlagParameterClick(Sender: TObject);
Var
Par:string;
Coord: TPoint;
begin
  {SetFlag:= TSetFlag.Create(Self);

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
  end;   }
end;


procedure Tfrmparametersall.DBGridEh1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //if (ssAlt in Shift) then Main.DBGridSaveAsActExecute(Sender);
end;


procedure Tfrmparametersall.DBGrid1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
  Par:string;
begin
  if Button=mbRight then begin
   par:=DBGrid1.SelectedColumn.Title.Caption;
    if (Par<>'Level') and (Par<>'QF') then begin
       iSetFlagParameter.Caption:='Set flag for '+Par;
       iDeleteParameter.Caption:='Delete '+Par;
       PM.PopUp;
    end;
  end;
end;


procedure Tfrmparametersall.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var
Ini:TIniFile;
begin
Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger( 'AllPar', 'Top',      Top);
    Ini.WriteInteger( 'AllPar', 'Left',     Left);
    Ini.WriteInteger( 'AllPar', 'Height',   Height);
    Ini.WriteInteger( 'AllPar', 'Width',    Width);
    Ini.WriteInteger( 'AllPar', 'listbox1', CheckListBox1.Width);
   finally
    ini.Free;
  end;
CDS.Free;

frmparametersall_open:=false;
end;



end.
