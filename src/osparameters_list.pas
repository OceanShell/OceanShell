unit osparameters_list;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Controls,
  StdCtrls, CheckLst, ComCtrls, Forms, Dialogs, ExtCtrls, IniFiles, SQLDB;

type

  { Tfrmparameters_list }

  Tfrmparameters_list = class(TForm)
    chklInstrument: TCheckListBox;
    chkPQF1: TCheckListBox;
    chkSQF: TCheckListBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    chkPQF2: TCheckListBox;
    lbParameters: TListBox;
    btnAmountOfProfiles: TButton;
    btnCancel: TButton;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;

    procedure CheckToolName(ToolName:string);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbParametersClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure btnAmountOfProfilesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnCancelClick(Sender: TObject);

  private
    { Private declarations }
    procedure SaveSettings;
  public
    { Public declarations }
  end;

var
  frmparameters_list: Tfrmparameters_list;
  cancel_fl:boolean=false;

implementation

uses osmain, dm, osprofile_plot_all, ostimedepthdiagram;

{$R *.lfm}


procedure Tfrmparameters_list.FormShow(Sender: TObject);
Var
 Ini:TIniFile;
 k: integer;
begin


 chklInstrument.Items:=instrument_list;
 chkPQF1.Items:=PQF1_list;
 chkPQF2.Items:=PQF2_list;
 chkSQF.Items :=SQF_list;

 Ini := TIniFile.Create(IniFileName);
   try
    Width := Ini.ReadInteger( 'osparameters_list', 'width',  423);
    Height:= Ini.ReadInteger( 'osparameters_list', 'weight', 525);

    for k:=0 to chkPQF1.Count-1 do
      chkPQF1.Checked[k]:=Ini.ReadBool('osparameters_list', 'PQF1_'+inttostr(k), true);

    for k:=0 to chkPQF2.Count-1 do
      chkPQF2.Checked[k]:=Ini.ReadBool('osparameters_list', 'PQF2_'+inttostr(k), true);

    for k:=0 to chkSQF.Count-1 do
      chkSQF.Checked[k]:=Ini.ReadBool('osparameters_list', 'SQF_'+inttostr(k), true);

    for k:=0 to chklInstrument.Count-1 do
      chklInstrument.Checked[k]:=Ini.ReadBool('osparameters_list', 'Instrument'+inttostr(k), true);
   finally
     Ini.Free;
   end;

  lbParameters.Clear;
   for k:=0 to frmosmain.ListBox1.Items.Count-1 do
    lbParameters.Items.Add(frmosmain.ListBox1.Items.Strings[k]+' ');

end;


procedure Tfrmparameters_list.CheckToolName(ToolName:string);
Var
k_prf, t_fl, S_fl:integer;
tblPar:string;
begin
Caption:=ToolName;

 
//���� ����������� ������� ����������




{ t_fl:=0; S_fl:=0;  //����� �� ������������� ����. � �����-��
 for k_prf:=0 to lbParameters.Items.Count-1 do begin
  if trim(lbParameters.Items.Strings[k_prf])='P_TEMPERATURE' then t_fl:=1;
  if trim(lbParameters.Items.Strings[k_prf])='P_SALINITY'    then s_fl:=1;
 end; }

 { if (t_fl=1) and (s_fl=1) then begin
    if (ToolName='PROFILES')   or (ToolName='TDDIAGRAMS')   or
       (ToolName='FIELDS')     or (ToolName='SECTIONS')     or
       (ToolName='STATISTICS') or (ToolName='MEAN PROFILE') or
       (ToolName='SECTION ANOMALIES') then begin
         lbParameters.Items.Add('-----------------Computed-----------------');
         lbParameters.Items.Add('DENSITY ');
      if  (ToolName='PROFILES')     or (ToolName='TDDIAGRAMS') or
          (ToolName='MEAN PROFILE') or (ToolName='SECTION ANOMALIES') then
         lbParameters.Items.Add('BUOYANCY ');
    end;
 end; }

 btnAmountOfProfiles.Enabled:=true;
end;


procedure Tfrmparameters_list.lbParametersClick(Sender: TObject);
var
par:string;
begin

 SaveSettings;

 try
   Par:=lbParameters.Items.Strings[lbParameters.ItemIndex];
   if Copy(par,1,1)='-' then exit;

   CurrentParTable:=trim(copy(Par,1,LastDelimiter(' ',Par)));


    // All profiles for selected stations
    if Caption='PROFILES' then begin
      if frmprofile_plot_all_open=true then begin
        frmprofile_plot_all_open:=false;
        frmprofile_plot_all.Close;
      end;
      frmprofile_plot_all:= Tfrmprofile_plot_all.Create(nil);
      frmprofile_plot_all_open:=true;
    end;

    //��������� ��������� �����
    if Caption='TDDIAGRAMS' then begin
     frmtimedepthdiagram := Tfrmtimedepthdiagram.Create(Self);
     try
      if not frmtimedepthdiagram.ShowModal = mrOk then exit;
     finally
      frmtimedepthdiagram.Free;
      frmtimedepthdiagram := nil;
     end;
    end;

 {   if Caption='TIME SERIES' then begin
     frmTimeSeries:= TfrmTimeSeries.Create(Self);
     try
      if not frmTimeSeries.ShowModal = mrOk then exit;
     finally
       frmTimeSeries.Free;
       frmTimeSeries := nil;
     end;
    end;

     if Caption='MEAN PROFILE' then begin
      MeanProfile:=TMeanProfile.Create(Self);
      try
        if MeanProfile.ShowModal = mrOk then
       finally
        MeanProfile.Free;
        MeanProfile := nil;
       end;
     end;     }

    {
    //�������
    if Caption='SECTIONS'  then Sections:= TSections.Create(Self);

    if Caption='SECTIONS DIVA'  then Sections:= TSections.Create(Self);

     //�������� �� ��������
    if Caption='SECTION ANOMALIES' then begin
      if SectAnomOpen=false then SectionAnomalies:=TSectionAnomalies.Create(Self) else
                                 SectionAnomalies.SetFocus;
      SectAnomOpen:=true;
    end;

    //����
    if Caption='FIELDS' then begin
      if FieldsOpen=false then frmToolField:= TfrmToolField.Create(Self) else frmToolField.SetFocus;
        FieldsOpen:=true;
    end;

    if Caption='STATISTICS' then StandartLevels:= TStandartLevels.Create(Self);
    }

     lbParameters.ItemIndex:=-1; //������� ����� � ��������� �������
   except
     //catching exception if the click is outside of the list
   end;
end;



procedure Tfrmparameters_list.btnAmountOfProfilesClick(Sender: TObject);
Var
prfCount,k_prf, ID_cur:integer;
tblPar:string;

TRt:TSQLTransaction;
Qt:TSQLQuery;
begin
TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qt:=TSQLQuery.Create(self);
Qt.Database:=frmdm.IBDB;
Qt.Transaction:=TRt;

btnAmountOfProfiles.Enabled:=false;
lbParameters.Enabled:=false;
lbParameters.Items.Clear;
try
 ID_cur:=frmdm.Q.FieldByName('ID').AsInteger;
 frmdm.Q.DisableControls;
  for k_prf:=0 to frmosmain.ListBox1.Count-1 do begin
   tblPar:=frmosmain.ListBox1.Items.Strings[k_prf];

   if cancel_fl=false then begin
    prfCount:=0;
    frmdm.Q.First;
     while not frmdm.Q.Eof do begin
      with Qt do begin
       Close;
           SQL.Clear;
           SQL.Add(' SELECT ID FROM '+tblPar);
           SQL.Add(' WHERE ID=:ID ');
           SQL.Add(' ROWS 1 ');
           ParamByName('ID').AsInteger:=frmdm.Q.FieldByName('ID').AsInteger;
         Open;
          if not Qt.IsEmpty then prfCount:=prfCount+1;
       Close;
      end;
      frmdm.Q.Next;
    end;

     if prfCount>0 then begin
       lbParameters.Items.Add(tblPar+'   ['+inttostr(prfCount)+']');
       Application.ProcessMessages;
     end;

   end;
 end;
 Finally
  btnAmountOfProfiles.Enabled:=true;
  lbParameters.Enabled:=true;

  Qt.Close;
  Trt.Commit;
  Qt.Free;
  TrT.Free;
  frmdm.Q.Locate('ID', ID_cur, []);
  frmdm.Q.EnableControls;
 end;
end;


procedure Tfrmparameters_list.SaveSettings;
Var
  k :integer;
  Ini:TIniFile;
begin
  Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteInteger( 'osparameters_list', 'top',    Top);
   Ini.WriteInteger( 'osparameters_list', 'left',   Left);
   Ini.WriteInteger( 'osparameters_list', 'width',  Width);
   Ini.WriteInteger( 'osparameters_list', 'weight', Height);

   for k:=0 to chkPQF1.Count-1 do
     Ini.WriteBool( 'osparameters_list', 'PQF1_'+inttostr(k), chkPQF1.Checked[k]);

   for k:=0 to chkPQF2.Count-1 do
     Ini.WriteBool( 'osparameters_list', 'PQF2_'+inttostr(k), chkPQF2.Checked[k]);

   for k:=0 to chkSQF.Count-1 do
     Ini.WriteBool( 'osparameters_list','SQF_'+inttostr(k), chkSQF.Checked[k]);

   for k:=0 to chklInstrument.Count-1 do
     Ini.WriteBool('osparameters_list', 'Instrument'+inttostr(k),  chklInstrument.Checked[k]);

  finally
    Ini.Free;
  end;
end;

procedure Tfrmparameters_list.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveSettings;
  frmparameters_list_open:=false;
end;


procedure Tfrmparameters_list.btnCancelClick(Sender: TObject);
begin
  cancel_fl:= true;
end;


procedure Tfrmparameters_list.FormResize(Sender: TObject);
begin
  if Width<=450 then lbParameters.Columns:=1;
  if (Width>450) and (Width<700) then lbParameters.Columns:=2;
  if Width>=700 then lbParameters.Columns:=3;
end;

{ ������������� ��������� �������� ����� ����� ��������� �������� }
procedure Tfrmparameters_list.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 {if DensOpen=true      then QDensity.Close;
 if QProfilesOpen=true then QProfiles.Close;
 if FieldsOpen=true    then frmToolField.Close; }
end;

end.
