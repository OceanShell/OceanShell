unit osViz_surfer_squares;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, GetText, LCLIntf, IniFIles, fileutil;

type

  { Tfrmviz_surfer_squares }

  Tfrmviz_surfer_squares = class(TForm)
    btnOpenFolder: TBitBtn;
    btnOpenScript: TBitBtn;
    btnPlot: TButton;
    btnSamplesInLayers: TBitBtn;
    btnSelectAll_Layers: TBitBtn;
    btnSelectAll_Variables: TBitBtn;
    btnSurferSettings: TButton;
    cbAllOutputFiles: TComboBox;
    cbColumn: TComboBox;
    CheckBox1: TCheckBox;
    CheckGroup2: TCheckGroup;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    frmviz_surfer_squares: TBitBtn;
    btnProfilesInTables: TBitBtn;
    btnCompute: TBitBtn;
    CheckGroup1: TCheckGroup;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    Memo2: TMemo;
    myQ: TSQLQuery;
    RadioGroup1: TRadioGroup;
    procedure btnComputeClick(Sender: TObject);
    procedure btnOpenFolderClick(Sender: TObject);
    procedure btnOpenScriptClick(Sender: TObject);
    procedure btnPlotClick(Sender: TObject);
    procedure btnProfilesInTablesClick(Sender: TObject);
    procedure btnSamplesInLayersClick(Sender: TObject);
    procedure btnSelectAll_VariablesClick(Sender: TObject);
    procedure btnSelectAll_LayersClick(Sender: TObject);
    procedure btnSurferSettingsClick(Sender: TObject);
    procedure cbAllOutputFilesDropDown(Sender: TObject);
    procedure cbAllOutputFilesSelect(Sender: TObject);
    procedure cbColumnSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure get_stations(step:real);
    procedure get_profiles(step:real);
    procedure get_var_statistics(step:real);
    procedure get_arbitrary_layer_statistics(step:real);
  public

  end;

var
  frmviz_surfer_squares: Tfrmviz_surfer_squares;
  st_count: integer;
  user_path: string;
  fn:string;
  Layer :array[1..2,1..44] of real;
  fo,fo1: text;

implementation

uses osmain, dm, osunitsconversion, surfer_settings, surfer_field;

{$R *.lfm}

{ Tfrmviz_surfer_squares }

procedure Tfrmviz_surfer_squares.FormShow(Sender: TObject);
var
kt,kl :integer;
dir_name: string;
begin
  memo1.Clear;

  user_path:=GlobalUnloadPath+PathDelim+'squares'+PathDelim;
  if directoryexists(user_path)=false then mkdir(user_path);


  with myQ do begin
    Close;
    SQL.Clear;
    SQL.Add(' Select count(id) as st_count from STATION');
    SQL.Add(' where duplicate=false ');
    Open;
    st_count:=FieldByName('st_count').AsInteger;
    Close;
  end;

  label1.Caption:='Station# (without duplicates): '+inttostr(st_count);

  {
  frmdm.IBDB.GetTableNames(ListBox1.Items,False);

{T}for kt:=0 to ListBox1.Items.Count-1 do begin
{P}if (copy(ListBox1.items.strings[kt],1,2)='P_') then begin
     CheckGroup1.items.add(ListBox1.items.strings[kt]);
{P}end;
{T}end; }

  (* заменил код выше на упрощенную версию *)
  CheckGroup1.items:=frmosmain.ListBox1.Items;

{L}for kl:=1 to 44 do begin
      {SeaDataNet global climatology  July 2019}
      case kl of
      1: begin  Layer[1,kl]:=0;  Layer[2,kl]:=10; end;
      2: begin  Layer[1,kl]:=10;  Layer[2,kl]:=20; end;
      3: begin  Layer[1,kl]:=20;  Layer[2,kl]:=30; end;
      4: begin  Layer[1,kl]:=30;  Layer[2,kl]:=40; end;
      5: begin  Layer[1,kl]:=40;  Layer[2,kl]:=50; end;
      6: begin  Layer[1,kl]:=50;  Layer[2,kl]:=60; end;
      7: begin  Layer[1,kl]:=60;  Layer[2,kl]:=70; end;
      8: begin  Layer[1,kl]:=70;  Layer[2,kl]:=80; end;
      9: begin  Layer[1,kl]:=80;  Layer[2,kl]:=90; end;
      10: begin  Layer[1,kl]:=90;  Layer[2,kl]:=100; end;
      11: begin  Layer[1,kl]:=100;  Layer[2,kl]:=125; end;
      12: begin  Layer[1,kl]:=125;  Layer[2,kl]:=150; end;
      13: begin  Layer[1,kl]:=150;  Layer[2,kl]:=175; end;
      14: begin  Layer[1,kl]:=175;  Layer[2,kl]:=200; end;
      15: begin  Layer[1,kl]:=200;  Layer[2,kl]:=225; end;
      16: begin  Layer[1,kl]:=225;  Layer[2,kl]:=250; end;
      17: begin  Layer[1,kl]:=250;  Layer[2,kl]:=275; end;
      18: begin  Layer[1,kl]:=275;  Layer[2,kl]:=300; end;
      19: begin  Layer[1,kl]:=300;  Layer[2,kl]:=325; end;
      20: begin  Layer[1,kl]:=325;  Layer[2,kl]:=350; end;
      21: begin  Layer[1,kl]:=350;  Layer[2,kl]:=375; end;
      22: begin  Layer[1,kl]:=375;  Layer[2,kl]:=400; end;
      23: begin  Layer[1,kl]:=400;  Layer[2,kl]:=425; end;
      24: begin  Layer[1,kl]:=425;  Layer[2,kl]:=450; end;
      25: begin  Layer[1,kl]:=450;  Layer[2,kl]:=475; end;
      26: begin  Layer[1,kl]:=475;  Layer[2,kl]:=500; end;
      27: begin  Layer[1,kl]:=500;  Layer[2,kl]:=600; end;
      28: begin  Layer[1,kl]:=600;  Layer[2,kl]:=700; end;
      29: begin  Layer[1,kl]:=700;  Layer[2,kl]:=800; end;
      30: begin  Layer[1,kl]:=800;  Layer[2,kl]:=900; end;
      31: begin  Layer[1,kl]:=900;  Layer[2,kl]:=1000; end;
      32: begin  Layer[1,kl]:=1000;  Layer[2,kl]:=1200; end;
      33: begin  Layer[1,kl]:=1200;  Layer[2,kl]:=1400; end;
      34: begin  Layer[1,kl]:=1400;  Layer[2,kl]:=1600; end;
      35: begin  Layer[1,kl]:=1600;  Layer[2,kl]:=1800; end;
      36: begin  Layer[1,kl]:=1800;  Layer[2,kl]:=2000; end;
      37: begin  Layer[1,kl]:=2000;  Layer[2,kl]:=2500; end;
      38: begin  Layer[1,kl]:=2500;  Layer[2,kl]:=3000; end;
      39: begin  Layer[1,kl]:=3000;  Layer[2,kl]:=3500; end;
      40: begin  Layer[1,kl]:=3500;  Layer[2,kl]:=4000; end;
      41: begin  Layer[1,kl]:=4000;  Layer[2,kl]:=4500; end;
      42: begin  Layer[1,kl]:=4500;  Layer[2,kl]:=5000; end;
      43: begin  Layer[1,kl]:=5000;  Layer[2,kl]:=5500; end;
      44: begin  Layer[1,kl]:=5500;  Layer[2,kl]:=6000; end;
      end;

      CheckGroup2.items.add(floattostr(Layer[1,kl])+'->'+floattostr(Layer[2,kl]));

{L}end;
end;


procedure Tfrmviz_surfer_squares.btnComputeClick(Sender: TObject);
var
i :integer;
step :real;
var_selected,layer_selected :boolean;
begin

   case RadioGroup1.ItemIndex of
      0: step:=5;
      1: step:=1;
      2: step:=0.25;
   end;

     var_selected:=false;
   for i:=0 to CheckGroup1.Items.Count-1 do
   if CheckGroup1.Checked[i] then var_selected:=true;

    layer_selected:=false;
   for i:=0 to CheckGroup2.Items.Count-1 do
   if CheckGroup2.Checked[i] then layer_selected:=true;

   if CheckBox1.Checked then get_arbitrary_layer_statistics(step)
   else begin
    if (var_selected=false) and (layer_selected=false) then get_stations(step);
    if (var_selected=true) and (layer_selected=false) then get_profiles(step);
    if (var_selected=true) and (layer_selected=true) then get_var_statistics(step);
   end;

end;

procedure Tfrmviz_surfer_squares.btnOpenFolderClick(Sender: TObject);
begin
  OpenDocument(PChar(user_path));
end;

procedure Tfrmviz_surfer_squares.btnOpenScriptClick(Sender: TObject);
Var
ScriptFile, Scripter:string;
Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName); // settings from file
  try
   scripter:=Ini.ReadString('main', 'SurferPath', '');
  finally
    Ini.Free;
  end;
 ScriptFile:=ExtractFilePath(user_path)+'Script.bas';
 SysUtils.ExecuteProcess('"'+Scripter+'" "'+ScriptFile+'"', '', []);
end;

procedure Tfrmviz_surfer_squares.btnPlotClick(Sender: TObject);
Var
  ncols, nrows: integer;
  fname, param: string;
  grid_step:real;
begin

 fname:=ExtractFileName(cbAllOutputFiles.Text);
 param:=copy(fname, Pos('_', fname)+1, Pos('_', fname)-Pos('.', fname)-1);

 grid_step:=StrToFloat(copy(fname, 1, Pos('x', fname)-1));

 ncols:=round(360/grid_step);
 nrows:=round(180/grid_step);

 GetFieldScript(cbAllOutputFiles.Text, //data file
                param, // variable name and its units
                (cbColumn.ItemIndex+3),
                ncols, nrows, //colums and rows
                -180, 180, -90, 90, //region
                'Rainbow', //preset name
                '', // no custon clr
                false //reversed!
                );

   {$IFDEF Windows}
     frmosmain.RunScript(2, '-x "'+user_path+'script.bas"', nil);
   {$ENDIF}
end;




procedure Tfrmviz_surfer_squares.btnProfilesInTablesClick(Sender: TObject);
var
kt :integer;
prf_count :integer;
tbl:string;
DT1,DT2:TDateTime;
begin

  DT1:=NOW;
  memo1.Lines.Add('...start: '+datetimetostr(DT1));
  CheckGroup1.Items.Clear;
  CheckGroup1.Visible:=false;
  Application.ProcessMessages;


{T}for kt:=0 to ListBox1.Items.Count-1 do begin
{P}if (copy(ListBox1.items.strings[kt],1,2)='P_') then begin

    tbl:=ListBox1.items.strings[kt];
    if pos(' ',tbl)<>0 then tbl:=copy(tbl,1,(pos(' ',tbl)));

    with myQ do begin
      Close;
      SQL.Clear;
      SQL.Add(' Select count(distinct('+tbl+'.id)) as prf_count from station,'+tbl);
      SQL.Add(' where station.id='+tbl+'.id and duplicate=false');
      Open;
      prf_count:=FieldByName('prf_count').AsInteger;
      Close;
    end;

    CheckGroup1.items.add(ListBox1.items.strings[kt]+'  ('+inttostr(prf_count)+')');

{P}end;
{T}end;

   CheckGroup1.Visible:=true;
   Application.ProcessMessages;

   DT2:=NOW;
   memo1.Lines.Add('');
   memo1.Lines.Add('...stop: '+datetimetostr(DT2));
   memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;



procedure Tfrmviz_surfer_squares.btnSamplesInLayersClick(Sender: TObject);
var
kt,kl :integer;
tbl_count,samples_count :integer;
L1,L2: real;
tbl:string;
DT1,DT2:TDateTime;
begin
   DT1:=NOW;
   memo1.Lines.Add('...start: '+datetimetostr(DT1));

 {...only one table has to be checked}
   tbl_count:=0;
 for kt:=0 to CheckGroup1.Items.Count-1 do begin
 if CheckGroup1.Checked[kt] then begin
   tbl_count:=tbl_count+1;
 end;
 end;
 if tbl_count<>1 then begin
   showmessage('Variable (only one) should be selected!');
   Exit;
 end;

   CheckGroup2.Items.Clear;
   CheckGroup2.Visible:=false;
   Application.ProcessMessages;


{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{P}if CheckGroup1.Checked[kt] then begin

     tbl:=CheckGroup1.items.Strings[kt];
     if pos(' ',tbl)<>0 then tbl:=copy(tbl,1,(pos(' ',tbl)));
     memo1.Lines.Add(tbl);

{L}for kl:=1 to 44 do begin
     L1:=Layer[1,kl];
     L2:=Layer[2,kl];
     samples_count:=0;

     with myQ do begin
       Close;
       SQL.Clear;
       SQL.Add(' Select count(distinct('+tbl+'.id)) as prf_count from station,'+tbl);
       SQL.Add(' where station.id='+tbl+'.id and duplicate=false ');
       SQL.Add(' and lev_m>=:L1 and lev_m<:L2');
       ParamByName('L1').AsFloat:=L1;
       ParamByName('L2').AsFloat:=L2;
       Open;
       samples_count:=FieldByName('prf_count').AsInteger;
       Close;
     end;

     CheckGroup2.items.add(floattostr(L1)+'->'+floattostr(L2)+'  ('+inttostr(samples_count)+')');

{L}end;
{P}end;
{T}end;

    CheckGroup2.Visible:=true;
    Application.ProcessMessages;

    DT2:=NOW;
    memo1.Lines.Add('');
    memo1.Lines.Add('...stop: '+datetimetostr(DT2));
    memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;





procedure Tfrmviz_surfer_squares.btnSelectAll_VariablesClick(Sender: TObject);
var
i: integer;
begin
   if btnSelectAll_Variables.Caption='Select all' then begin
     for i:=0 to CheckGroup1.Items.Count-1 do CheckGroup1.Checked[i]:=true;
     btnSelectAll_Variables.Caption:='Deselect all';
     Exit;
   end;

    if btnSelectAll_Variables.Caption='Deselect all' then begin
     for i:=0 to CheckGroup1.Items.Count-1 do CheckGroup1.Checked[i]:=false;
     btnSelectAll_Variables.Caption:='Select all';
     Exit;
   end;
end;




procedure Tfrmviz_surfer_squares.btnSelectAll_LayersClick(Sender: TObject);
var
i:integer;
begin
      if btnSelectAll_Layers.Caption='Select all' then begin
      for i:=0 to CheckGroup2.Items.Count-1 do CheckGroup2.Checked[i]:=true;
      btnSelectAll_Layers.Caption:='Deselect all';
      Exit;
    end;
     if btnSelectAll_Layers.Caption='Deselect all' then begin
      for i:=0 to CheckGroup2.Items.Count-1 do CheckGroup2.Checked[i]:=false;
      btnSelectAll_Layers.Caption:='Select all';
      Exit;
    end;
end;

procedure Tfrmviz_surfer_squares.btnSurferSettingsClick(Sender: TObject);
begin
 frmSurferSettings := TfrmSurferSettings.Create(Self);
 frmSurferSettings.LoadSettings('field');
  try
   if not frmSurferSettings.ShowModal = mrOk then exit;
  finally
    frmSurferSettings.Free;
    frmSurferSettings := nil;
  end;
end;

procedure Tfrmviz_surfer_squares.cbAllOutputFilesDropDown(Sender: TObject);
begin
 cbAllOutputFiles.Items:=FindAllFiles(user_path, '*.txt', true);
end;


procedure Tfrmviz_surfer_squares.cbAllOutputFilesSelect(Sender: TObject);
Var
  dat:text;
  st, buf_str: string;
  k, cnt:integer;
begin
  AssignFile(dat, cbAllOutputFiles.Text); reset(dat);
  readln(dat, st);

  cbColumn.Clear;
  k:=0;
  cnt:=0;
  repeat
   buf_str:='';
   repeat
    inc(k);
   // showmessage(st[k]);
    if st[k]<>#9 then buf_str:=buf_str+st[k];
   until (st[k]=#9) or (k=length(st));
  // showmessage(buf_str);
   inc(cnt);
   if cnt>2 then cbColumn.Items.Add(buf_str);
  until k=length(st);

  cbColumn.Enabled:=true;
  btnPlot.Enabled:=false;
end;

procedure Tfrmviz_surfer_squares.cbColumnSelect(Sender: TObject);
begin
  btnPlot.Enabled:=true;
end;




procedure Tfrmviz_surfer_squares.get_stations(step:real);
var
klt,kln :integer;
st_in_sq: integer;
ltn,lts,lt,lnw,lne,ln :real;
sq_index: string;
DT1,DT2 :TDateTime;
begin
   memo1.Lines.Add('number of stations');
   memo1.Lines.Add('lat/lon step='+floattostr(step));
   DT1:=NOW;
   memo1.Lines.Add('...start: '+datetimetostr(DT1));

   with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select count(id) as st_in_sq from STATION ');
     SQL.Add(' where latitude>:lts and latitude<=:ltn ');
     SQL.Add(' and longitude>=:lnw and longitude<:lne ');
     Prepare;
   end;

   sq_index:=floattostr(step)+'x'+floattostr(step)+'_';
   fn:=user_path+sq_index + 'stations_0.txt';
   assignfile(fo,fn);
   rewrite(fo);
   writeln(fo,'lon'+#9+'lat'+#9+'station#');

   fn:=user_path+ sq_index + 'stations.txt';
   assignfile(fo1,fn);
   rewrite(fo1);
   writeln(fo1,'lon'+#9+'lat'+#9+'station#');


      klt:=0;
{Lt}repeat
      inc(klt);
      ltn:=90-step*(klt-1);
      lts:=90-step*klt;
      lt:=(ltn+lts)/2;
      //memo1.Lines.Add(inttostr(klt)+#9+floattostr(ltn)+'->'+floattostr(lts)+#9+floattostr(lt));

      kln:=0;
{Ln}repeat
      inc(kln);
      lnw:=-180+step*(kln-1);
      lne:=-180+step*kln;
      ln:=(lnw+lne)/2;
      //memo1.Lines.Add(#9+inttostr(kln)+#9+floattostr(lnw)+'->'+floattostr(lne)+#9+floattostr(ln));


      with frmdm.q1 do begin
        ParamByName('ltn').AsFloat:=ltn;
        ParamByName('lts').AsFloat:=lts;
        ParamByName('lnw').AsFloat:=lnw;
        ParamByName('lne').AsFloat:=lne;
        Open;
        st_in_sq:=FieldByName('st_in_sq').AsInteger;
        Close;
      end;

      writeln(fo,floattostr(ln),#9,floattostr(lt),#9,inttostr(st_in_sq));
      if st_in_sq>0 then
      writeln(fo1,floattostr(ln),#9,floattostr(lt),#9,inttostr(st_in_sq));

{Ln}until lne=180;
{Lt}until lts=-90;
      closefile(fo);
      closefile(fo1);
      frmdm.q1.UnPrepare;

      DT2:=NOW;
      memo1.Lines.Add('');
      memo1.Lines.Add('...stop: '+datetimetostr(DT2));
      memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;





procedure Tfrmviz_surfer_squares.get_profiles(step:real);
Type
  MonthOfTheYear=record
    y:integer;
    m:integer;
  end;
  MY=array of MonthOfTheYear;

var
i,kt,klt,kln: integer;
prf_count,prf_in_sq: integer;
ltn,lts,lt,lnw,lne,ln :real;
tbl,var_name,sq_index: string;
DT1,DT2 :TDateTime;

{time series length}
count_y,count_m,ts_length_years,ts_length_months: integer;
y,m,d: word;
add_y,add_m: boolean;
val_dt,min_dt,max_dt: TDateTime;
TSL_y: array of integer;
TSL_m: MY;

begin

   memo1.Lines.Add('number of profiles');
   memo1.Lines.Add('lat/lon step='+floattostr(step));
   DT1:=NOW;
   memo1.Lines.Add('...start: '+datetimetostr(DT1));
   memo1.Lines.Add('');

{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{C}if CheckGroup1.Checked[kt] then begin

   tbl:=CheckGroup1.Items.Strings[kt];
   //memo1.Lines.Add(tbl);

   with myQ do begin
     Close;
     SQL.Clear;
     SQL.Add(' Select count(distinct('+tbl+'.id)) as prf_count from station,'+tbl);
     SQL.Add(' where station.id='+tbl+'.id and duplicate=false');
     Open;
     prf_count:=FieldByName('prf_count').AsInteger;
     Close;
   end;

   memo1.Lines.Add(tbl+'  profiles#: '+inttostr(prf_count));
   var_name:=copy(tbl,3,length(tbl));

   sq_index:=floattostr(step)+'x'+floattostr(step)+'_';

   fn:=user_path + sq_index + var_name + '_0.txt';
   assignfile(fo,fn);
   rewrite(fo);
   writeln(fo,'lon'+#9+'lat'+#9+'prf#'+#9+'min_dt'+#9+'max_dt'+#9+'TSL_y'+#9+'TSL_m');

   fn:=user_path+ sq_index + var_name + '.txt';
   assignfile(fo1,fn);
   rewrite(fo1);
   writeln(fo1,'lon'+#9+'lat'+#9+'prf#'+#9+'min_dt'+#9+'max_dt'+#9+'TSL_y'+#9+'TSL_m');

      klt:=0;
{Lt}repeat
      inc(klt);
      ltn:=90-step*(klt-1);
      lts:=90-step*klt;
      lt:=(ltn+lts)/2;
      //memo1.Lines.Add(inttostr(klt)+#9+floattostr(ltn)+'->'+floattostr(lts)+#9+floattostr(lt));

      kln:=0;
{Ln}repeat
      inc(kln);
      lnw:=-180+step*(kln-1);
      lne:=-180+step*kln;
      ln:=(lnw+lne)/2;

      {with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' Select count(distinct('+tbl+'.id)) as prf_in_sq from STATION,'+tbl);
        SQL.Add(' where station.id='+tbl+'.id and duplicate=false');
        SQL.Add(' and latitude>:lts and latitude<=:ltn ');
        SQL.Add(' and longitude>=:lnw and longitude<:lne ');
        ParamByName('ltn').AsFloat:=ltn;
        ParamByName('lts').AsFloat:=lts;
        ParamByName('lnw').AsFloat:=lnw;
        ParamByName('lne').AsFloat:=lne;
        Open;
        prf_in_sq:=FieldByName('prf_in_sq').AsInteger;
        Close;
      end; }

      {...no duplicates, PQF2>2}
      with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' select distinct(station.id), dateandtime from STATION,'+tbl);
        SQL.Add(' where station.id='+tbl+'.id and duplicate=false');
        SQL.Add(' and latitude>:lts and latitude<=:ltn ');
        SQL.Add(' and longitude>=:lnw and longitude<:lne ');
        SQL.Add(' and PQF2>2 ');
        ParamByName('ltn').AsFloat:=ltn;
        ParamByName('lts').AsFloat:=lts;
        ParamByName('lnw').AsFloat:=lnw;
        ParamByName('lne').AsFloat:=lne;
        Open;
      end;

      min_dt:=strtodate('01.01.2100');
      max_dt:=strtodate('01.01.1600');

      count_y:=1;
      setlength(TSL_y,count_y);
      TSL_y[count_y-1]:=0;

      count_m:=1;
      setlength(TSL_m,count_m);
      TSL_m[count_m-1].y:=0;
      TSL_m[count_m-1].m:=0;


      prf_in_sq:=0;
{W}while not frmdm.q1.EOF do begin

      prf_in_sq:=prf_in_sq+1;

      val_dt:=frmdm.q1.FieldByName('dateandtime').AsDateTime;
      DecodeDate(val_dt,y,m,d);

      if min_dt>val_dt then min_dt:=val_dt;
      if max_dt<val_dt then max_dt:=val_dt;

      {...time series length in years}
      add_y:=true;
      for i:=0 to High(TSL_y) do if TSL_y[i]=y then add_y:=false;
      if add_y=true then begin
         count_y:=count_y+1;
         setlength(TSL_y,count_y);
         TSL_y[count_y-1]:=y;
      end;

      {...time series length in months}
      add_m:=true;
      for i:=0 to High(TSL_m) do if (TSL_m[i].y=y) and (TSL_m[i].m=m) then add_m:=false;
      if add_m=true then begin
         count_m:=count_m+1;
         setlength(TSL_m,count_m);
         TSL_m[count_m-1].y:=y;
         TSL_m[count_m-1].m:=m;
      end;

      frmdm.q1.Next;
{W}end;
      frmdm.q1.Close;

      ts_length_years:=High(TSL_y);
      ts_length_months:=High(TSL_m);

      {...with 0}
      writeln(fo,floattostr(ln),
      #9,floattostr(lt),
      #9,inttostr(prf_in_sq),
      #9,datetostr(min_dt),
      #9,datetostr(max_dt),
      #9,inttostr(ts_length_years),
      #9,inttostr(ts_length_months));

      {...without 0}
      if prf_in_sq>0 then
      writeln(fo1,floattostr(ln),
      #9,floattostr(lt),
      #9,inttostr(prf_in_sq),
      #9,datetostr(min_dt),
      #9,datetostr(max_dt),
      #9,inttostr(ts_length_years),
      #9,inttostr(ts_length_months));

{Ln}until lne=180;
{Lt}until lts=-90;
      closefile(fo);
      closefile(fo1);

{C}end;
{T}end;

     DT2:=NOW;
     memo1.Lines.Add('');
     memo1.Lines.Add('...stop: '+datetimetostr(DT2));
     memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;



procedure Tfrmviz_surfer_squares.get_var_statistics(step:real);
Type
  MonthOfTheYear=record
    y:integer;
    m:integer;
  end;
  MY=array of MonthOfTheYear;

var
i,kt,kl,klt,kln: integer;
unit_id: integer;
L1,L2: real;
ltn,lts,lt,lnw,lne,ln :real;
val :real;
sq_index,tbl,L1_str,L2_str,var_name,dir_name: string;
DT1,DT2 :TDateTime;

{units conversion}
val_conv:real;
isconverted,vu: boolean;

{statistics in square}
n:integer;
md,sd,min,max: real;
s1,s2:double;

{time series length}
count_y,count_m,ts_length_years,ts_length_months: integer;
y,m,d: word;
add_y,add_m: boolean;
val_dt,min_dt,max_dt :TDateTime;
TSL_y: array of integer;
TSL_m: MY;

begin
   memo1.Lines.Add('variables statistics in layers');
   memo1.Lines.Add('lat/lon step='+floattostr(step));

   {...check/create folder for output}
   dir_name:=user_path+PathDelim+'layers'+PathDelim;
   if directoryexists(dir_name)=false then mkdir(dir_name);
   setcurrentdir(dir_name);

    DT1:=NOW;
    memo1.Lines.Add('...start: '+datetimetostr(DT1));
    memo1.Lines.Add('');

    sq_index:=floattostr(step)+'x'+floattostr(step)+'_';


{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{TC}if CheckGroup1.Checked[kt] then begin

     tbl:=CheckGroup1.Items.Strings[kt];
     if pos(' ',tbl)<>0 then tbl:=copy(tbl,1,(pos(' ',tbl)));
     var_name:=copy(tbl,3,length(tbl));
     memo1.Lines.Add(tbl);

{L}for kl:=0 to CheckGroup2.Items.Count-1 do begin
{LC}if CheckGroup2.Checked[kl] then begin
     L1:=Layer[1,kl+1]; {array and CheckGroup indexes are diffrent}
     L2:=Layer[2,kl+1];

     L1_str:=trim(inttostr(trunc(L1)));
     if length(L1_str)<4 then for i:=1 to 4-length(L1_str) do L1_str:='0'+L1_str;

     L2_str:=trim(inttostr(trunc(L2)));
     if length(L2_str)<4 then for i:=1 to 4-length(L2_str) do L2_str:='0'+L2_str;

     {without 0}
     fn:=dir_name+sq_index+var_name+'_'+L1_str+'-'+L2_str+'.txt';
     assignfile(fo,fn);
     rewrite(fo);
     writeln(fo,'lon'+#9+'lat'+#9+'n'+#9+'md'+#9+'sd'+#9+'min'+#9+'max'+#9+'unit_id'
     +#9+'min_dt'+#9+'max_dt'+#9+'TSL_y'+#9+'TSL_m');

     {with 0}
     fn:=dir_name+sq_index+var_name+'_'+L1_str+'-'+L2_str+'_0.txt';
     assignfile(fo1,fn);
     rewrite(fo1);
     writeln(fo1,'lon'+#9+'lat'+#9+'n'+#9+'md'+#9+'sd'+#9+'min'+#9+'max'+#9+'unit_id'
     +#9+'min_dt'+#9+'max_dt'+#9+'TSL_y'+#9+'TSL_m');

{.....var staistics in squares and layer }
         klt:=0;
{Lt}repeat
      inc(klt);
      ltn:=90-step*(klt-1);
      lts:=90-step*klt;
      lt:=(ltn+lts)/2;
      //memo1.Lines.Add(inttostr(klt)+#9+floattostr(ltn)+'->'+floattostr(lts)+#9+floattostr(lt));

      kln:=0;
{Ln}repeat
      inc(kln);
      lnw:=-180+step*(kln-1);
      lne:=-180+step*kln;
      ln:=(lnw+lne)/2;

      n:=0;
      md:=0;
      sd:=0;
      s1:=0;
      s2:=0;
      min:=9999;
      max:=-9999;
      min_dt:=strtodate('01.01.2100');
      max_dt:=strtodate('01.01.1600');

      count_y:=1;
      setlength(TSL_y,count_y);
      TSL_y[count_y-1]:=0;

      count_m:=1;
      setlength(TSL_m,count_m);
      TSL_m[count_m-1].y:=0;
      TSL_m[count_m-1].m:=0;

      with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' select dateandtime,val,units_id from STATION,'+tbl);
        SQL.Add(' where station.id='+tbl+'.id and duplicate=false');
        SQL.Add(' and latitude>:lts and latitude<=:ltn ');
        SQL.Add(' and longitude>=:lnw and longitude<:lne ');
        SQL.Add(' and lev_m>=:L1 and lev_m<:L2 ');
        SQL.Add(' and PQF2>2 ');
        ParamByName('ltn').AsFloat:=ltn;
        ParamByName('lts').AsFloat:=lts;
        ParamByName('lnw').AsFloat:=lnw;
        ParamByName('lne').AsFloat:=lne;
        ParamByName('L1').AsFloat:=L1;
        ParamByName('L2').AsFloat:=L2;
        Open;
      end;

     n:=0;
{W}while not frmdm.q1.EOF do begin

     val:=frmdm.q1.FieldByName('val').AsFloat;
     unit_id:=frmdm.q1.FieldByName('units_id').AsInteger;
     val_dt:=frmdm.q1.FieldByName('dateandtime').AsDateTime;

     DecodeDate(val_dt,y,m,d);

     {...time series length in years}
     add_y:=true;
     for i:=0 to High(TSL_y) do if TSL_y[i]=y then add_y:=false;
     if add_y=true then begin
        count_y:=count_y+1;
        setlength(TSL_y,count_y);
        TSL_y[count_y-1]:=y;
     end;

     {...time series length in months}
     add_m:=true;
     for i:=0 to High(TSL_m) do if (TSL_m[i].y=y) and (TSL_m[i].m=m) then add_m:=false;
     if add_m=true then begin
        count_m:=count_m+1;
        setlength(TSL_m,count_m);
        TSL_m[count_m-1].y:=y;
        TSL_m[count_m-1].m:=m;
     end;

     {...units conversion}
     vu:=false; {valid unit}
     val_conv:=-999;
     isconverted:=false;

     if tbl = 'P_OXYGEN' then begin
     if unit_id=3 then vu:=true
     else begin
       getdefaultunits(tbl,unit_id,3,val,val_conv,isconverted);
       if isconverted=true then begin  val:=val_conv; unit_id:=3; vu:=true; end;
     end;
     end;

{U}if vu=true then begin
     n:=n+1;
     s1:=s1+val;
     s2:=s2+val*val;
     if min>val then min:=val;
     if max<val then max:=val;
     if min_dt>val_dt then min_dt:=val_dt;
     if max_dt<val_dt then max_dt:=val_dt;
{U}end;

     frmdm.q1.Next;
{W}end;
     frmdm.q1.Close;

     ts_length_years:=High(TSL_y);
     ts_length_months:=High(TSL_m);

{n}if n>=strtoint(Edit3.Text) then begin
     md:=s1/n;
     sd:=(s2-s1*s1/n)/n;
     if sd<>0 then sd:=sqrt(abs(sd));

      writeln(fo,floattostr(ln),
      #9,floattostr(lt),
      #9,inttostr(n),
      #9,floattostrF(md,ffFixed,9,3),
      #9,floattostrF(sd,ffFixed,9,3),
      #9,floattostrF(min,ffFixed,9,3),
      #9,floattostrF(max,ffFixed,9,3),
      #9,inttostr(unit_id),
      #9,datetostr(min_dt),
      #9,datetostr(max_dt),
      #9,inttostr(ts_length_years),
      #9,inttostr(ts_length_months)
      );
{n}end;

   {...to plot only time series lenght}
{n}if n>=0 then begin
     if n<>0 then begin
     md:=s1/n;
     sd:=(s2-s1*s1/n)/n;
     if sd<>0 then sd:=sqrt(abs(sd));
     end;

      writeln(fo1,floattostr(ln),
      #9,floattostr(lt),
      #9,inttostr(n),
      #9,floattostrF(md,ffFixed,9,3),
      #9,floattostrF(sd,ffFixed,9,3),
      #9,floattostrF(min,ffFixed,9,3),
      #9,floattostrF(max,ffFixed,9,3),
      #9,inttostr(unit_id),
      #9,datetostr(min_dt),
      #9,datetostr(max_dt),
      #9,inttostr(ts_length_years),
      #9,inttostr(ts_length_months)
      );
{n}end;


{Ln}until lne=180;
{Lt}until lts=-90;


     closefile(fo);
     closefile(fo1);

{LC}end;
{L}end;
{TC}end;
{T}end;

     DT2:=NOW;
     memo1.Lines.Add('');
     memo1.Lines.Add('...stop: '+datetimetostr(DT2));
     memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;



procedure Tfrmviz_surfer_squares.get_arbitrary_layer_statistics(step:real);
Type
  MonthOfTheYear=record
    y:integer;
    m:integer;
  end;
  MY=array of MonthOfTheYear;

var
i,kt,klt,kln: integer;
tbl_count,unit_id: integer;
L1,L2,val: real;
ltn,lts,lt,lnw,lne,ln :real;
sq_index,tbl,L1_str,L2_str,var_name,dir_name: string;
DT1,DT2 :TDateTime;

{units conversion}
val_conv:real;
isconverted,vu: boolean;

{statistics in square}
n:integer;
md,sd,min,max: real;
s1,s2:double;

{time series length}
count_y,count_m,ts_length_years,ts_length_months: integer;
y,m,d: word;
add_y,add_m: boolean;
val_dt,min_dt,max_dt :TDateTime;
TSL_y: array of integer;
TSL_m: MY;

begin
   memo1.Lines.Add('variables statistics in arbitrary layer');
   memo1.Lines.Add('lat/lon step='+floattostr(step));

   {...check/create folder for output}
   dir_name:=user_path+PathDelim+'layers'+PathDelim;
   if directoryexists(dir_name)=false then mkdir(dir_name);
   setcurrentdir(dir_name);

     tbl_count:=0;
{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{TC}if CheckGroup1.Checked[kt] then begin
     tbl_count:=tbl_count+1;
{TC}end;
{T} end;

    if tbl_count=0 then begin
       showmessage('Variable does not selected');
       Exit;
    end;

    DT1:=NOW;
    memo1.Lines.Add('...start: '+datetimetostr(DT1));
    memo1.Lines.Add('');

    sq_index:=floattostr(step)+'x'+floattostr(step)+'_';

    L1:=strtofloat(Edit1.Text);
    L2:=strtofloat(Edit2.Text);
    L1_str:=trim(inttostr(trunc(L1)));
    if length(L1_str)<4 then for i:=1 to 4-length(L1_str) do L1_str:='0'+L1_str;
    L2_str:=trim(inttostr(trunc(L2)));
    if length(L2_str)<4 then for i:=1 to 4-length(L2_str) do L2_str:='0'+L2_str;

{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{TC}if CheckGroup1.Checked[kt] then begin

   tbl:=CheckGroup1.items.Strings[kt];
   if pos(' ',tbl)<>0 then tbl:=copy(tbl,1,(pos(' ',tbl)));
   var_name:=copy(tbl,3,length(tbl));

   {...total samples in layer}
   {with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' Select count('+tbl+'.id) as samples_total from STATION,'+tbl);
     SQL.Add(' where station.id='+tbl+'.id and duplicate=false');
     SQL.Add(' and lev_m>=:L1 and lev_m<:L2 ');
     ParamByName('L1').AsFloat:=L1;
     ParamByName('L2').AsFloat:=L2;
     Open;
     samples_total:=FieldByName('samples_total').AsInteger;
     Close;
   end;
   memo1.Lines.Add(tbl+'  total number of samples in '+floattostr(L1)+'->'+floattostr(L2)+' layer: '+inttostr(samples_total));}

   fn:=dir_name+sq_index+var_name+'_'+L1_str+'-'+L2_str+'_arbitrary.txt';
   assignfile(fo,fn);
   rewrite(fo);
   writeln(fo,'lon'+#9+'lat'+#9+'n'+#9+'md'+#9+'sd'+#9+'min'+#9+'max'+#9+'unit_id'
   +#9+'min_dt'+#9+'max_dt'+#9+'TSL_y'+#9+'TSL_m');

{.....var staistics in squares and layer }
         klt:=0;
{Lt}repeat
      inc(klt);
      ltn:=90-step*(klt-1);
      lts:=90-step*klt;
      lt:=(ltn+lts)/2;
      //memo1.Lines.Add(inttostr(klt)+#9+floattostr(ltn)+'->'+floattostr(lts)+#9+floattostr(lt));

      kln:=0;
{Ln}repeat
      inc(kln);
      lnw:=-180+step*(kln-1);
      lne:=-180+step*kln;
      ln:=(lnw+lne)/2;

   {...тут все наблюдения сбрасываем в запрос и из него вытаскиваем всю статистику}
   {...конвертируем единицы}
   {...через динамический массив}
   {... так не получится}

      n:=0;
      md:=0;
      sd:=0;
      s1:=0;
      s2:=0;
      min:=9999;
      max:=-9999;
      min_dt:=strtodate('01.01.2100');
      max_dt:=strtodate('01.01.1600');

      count_y:=1;
      setlength(TSL_y,count_y);
      TSL_y[count_y-1]:=0;

      count_m:=1;
      setlength(TSL_m,count_m);
      TSL_m[count_m-1].y:=0;
      TSL_m[count_m-1].m:=0;

      with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' select dateandtime,val,units_id from STATION,'+tbl);
        SQL.Add(' where station.id='+tbl+'.id and duplicate=false');
        SQL.Add(' and latitude>:lts and latitude<=:ltn ');
        SQL.Add(' and longitude>=:lnw and longitude<:lne ');
        SQL.Add(' and lev_m>=:L1 and lev_m<:L2 ');
        SQL.Add(' and PQF2>2 ');
        ParamByName('ltn').AsFloat:=ltn;
        ParamByName('lts').AsFloat:=lts;
        ParamByName('lnw').AsFloat:=lnw;
        ParamByName('lne').AsFloat:=lne;
        ParamByName('L1').AsFloat:=L1;
        ParamByName('L2').AsFloat:=L2;
        Open;
      end;

     n:=0;
{W}while not frmdm.q1.EOF do begin

     val:=frmdm.q1.FieldByName('val').AsFloat;
     unit_id:=frmdm.q1.FieldByName('units_id').AsInteger;
     val_dt:=frmdm.q1.FieldByName('dateandtime').AsDateTime;

     DecodeDate(val_dt,y,m,d);

     {...time series length in years}
     add_y:=true;
     for i:=0 to High(TSL_y) do if TSL_y[i]=y then add_y:=false;
     if add_y=true then begin
        count_y:=count_y+1;
        setlength(TSL_y,count_y);
        TSL_y[count_y-1]:=y;
     end;

     {...time series length in months}
     add_m:=true;
     for i:=0 to High(TSL_m) do if (TSL_m[i].y=y) and (TSL_m[i].m=m) then add_m:=false;
     if add_m=true then begin
        count_m:=count_m+1;
        setlength(TSL_m,count_m);
        TSL_m[count_m-1].y:=y;
        TSL_m[count_m-1].m:=m;
     end;

     {...units conversion}
     vu:=false; {valid unit}
     val_conv:=-999;
     isconverted:=false;

     if tbl = 'P_OXYGEN' then begin
     if unit_id=3 then vu:=true
     else begin
       getdefaultunits(tbl,unit_id,3,val,val_conv,isconverted);
       if isconverted=true then begin  val:=val_conv; unit_id:=3; vu:=true; end;
     end;
     end;

{U}if vu=true then begin
     n:=n+1;
     s1:=s1+val;
     s2:=s2+val*val;
     if min>val then min:=val;
     if max<val then max:=val;
     if min_dt>val_dt then min_dt:=val_dt;
     if max_dt<val_dt then max_dt:=val_dt;
{U}end;

     frmdm.q1.Next;
{W}end;
     frmdm.q1.Close;

     ts_length_years:=High(TSL_y);
     ts_length_months:=High(TSL_m);

{n}if n>=strtoint(Edit3.Text) then begin
     md:=s1/n;
     sd:=(s2-s1*s1/n)/n;
     if sd<>0 then sd:=sqrt(abs(sd));

      writeln(fo,floattostr(ln),
      #9,floattostr(lt),
      #9,inttostr(n),
      #9,floattostrF(md,ffFixed,9,3),
      #9,floattostrF(sd,ffFixed,9,3),
      #9,floattostrF(min,ffFixed,9,3),
      #9,floattostrF(max,ffFixed,9,3),
      #9,inttostr(unit_id),
      #9,datetostr(min_dt),
      #9,datetostr(max_dt),
      #9,inttostr(ts_length_years),
      #9,inttostr(ts_length_months)
      );

{n}end;

{Ln}until lne=180;
{Lt}until lts=-90;
     closefile(fo);
{TC}end;
{T} end;

     DT2:=NOW;
     memo1.Lines.Add('');
     memo1.Lines.Add('...stop: '+datetimetostr(DT2));
     memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;

end.

