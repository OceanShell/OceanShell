unit osViz_surfer_squares;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, GetText, LCLIntf, Spin, IniFIles, fileutil, DateTimePicker;

type

  { Tfrmviz_surfer_squares }

  Tfrmviz_surfer_squares = class(TForm)
    btnOpenFolder: TBitBtn;
    btnOpenScript: TBitBtn;
    btnPlot: TButton;
    btnSamplesInLayers: TBitBtn;
    btnSurferSettings: TBitBtn;
    cbAllOutputFiles: TComboBox;
    cbColumn: TComboBox;
    chkArbitraryLayer: TCheckBox;
    chkLayers: TCheckGroup;
    dtpDateMax: TDateTimePicker;
    dtpDateMin: TDateTimePicker;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    frmviz_surfer_squares: TBitBtn;
    btnProfilesInTables: TBitBtn;
    btnCompute: TBitBtn;
    chkVariables: TCheckGroup;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    lbSelectAllVariables: TLabel;
    lbSelectAllLayers: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    Memo2: TMemo;
    myQ: TSQLQuery;
    rgSquares: TRadioGroup;
    seLatMax: TFloatSpinEdit;
    seLatMin: TFloatSpinEdit;
    seLonMax: TFloatSpinEdit;
    seLonMin: TFloatSpinEdit;
    procedure btnComputeClick(Sender: TObject);
    procedure btnOpenFolderClick(Sender: TObject);
    procedure btnOpenScriptClick(Sender: TObject);
    procedure btnPlotClick(Sender: TObject);
    procedure btnProfilesInTablesClick(Sender: TObject);
    procedure btnSamplesInLayersClick(Sender: TObject);
    procedure btnSurferSettingsClick(Sender: TObject);
    procedure cbAllOutputFilesDropDown(Sender: TObject);
    procedure cbAllOutputFilesSelect(Sender: TObject);
    procedure cbColumnSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbSelectAllLayersClick(Sender: TObject);
    procedure lbSelectAllVariablesClick(Sender: TObject);
    procedure rgSquaresClick(Sender: TObject);
  private
    procedure get_stations(step:real);
    procedure get_profiles(step:real);
    procedure get_var_statistics(step:real);
    procedure get_arbitrary_layer_statistics(step:real);
    procedure save_settings;
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
  Ini:TIniFile;
kt,kl :integer;
dir_name: string;
begin
  memo1.Clear;

  user_path:=GlobalUnloadPath+PathDelim+'squares'+PathDelim;
  if directoryexists(user_path)=false then mkdir(user_path);

  (* заменил код выше на упрощенную версию *)
  chkVariables.items:=frmosmain.ListBox1.Items;

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

      chkLayers.items.add(floattostr(Layer[1,kl])+'->'+floattostr(Layer[2,kl]));

{L}end;

Ini := TIniFile.Create(IniFileName); // settings from file
 try
  rgSquares.ItemIndex:=Ini.ReadInteger(name, 'Squares', 0);
  seLonMin.Text:=Ini.ReadString(name, 'LonMin', '-180');
  seLonMax.Text:=Ini.ReadString(name, 'LonMax',  '180');
  seLatMin.Text:=Ini.ReadString(name, 'LatMin',  '-90');
  seLatMax.Text:=Ini.ReadString(name, 'LatMax',   '90');
  dtpDateMin.DateTime:=Ini.ReadDateTime(name, 'DateMin', StationDateMin);
  dtpDateMax.DateTime:=Ini.ReadDateTime(name, 'DateMax', StationDateMax);
 finally
   Ini.Free;
 end;

  rgSquares.OnClick(self);
end;

procedure Tfrmviz_surfer_squares.btnComputeClick(Sender: TObject);
var
i :integer;
step :real;
var_selected,layer_selected :boolean;
begin
  save_settings; // saving current settings;

  step:=StrToInt(rgSquares.Items.Strings[rgSquares.ItemIndex]);

  var_selected:=false;
  for i:=0 to chkVariables.Items.Count-1 do
   if chkVariables.Checked[i] then var_selected:=true;

  layer_selected:=false;
  for i:=0 to chkLayers.Items.Count-1 do
   if chkLayers.Checked[i] then layer_selected:=true;

  if chkArbitraryLayer.Checked then get_arbitrary_layer_statistics(step)
   else begin
    if (var_selected=false) and (layer_selected=false) then get_stations(step);
    if (var_selected=true)  and (layer_selected=false) then get_profiles(step);
    if (var_selected=true)  and (layer_selected=true)  then get_var_statistics(step);
   end;
end;


procedure Tfrmviz_surfer_squares.rgSquaresClick(Sender: TObject);
begin
 seLonMin.Increment:=StrToFloat(rgSquares.Items.Strings[rgSquares.ItemIndex]);
 seLonMax.Increment:=seLonMin.Increment;
 seLatMin.Increment:=seLonMin.Increment;
 seLatMax.Increment:=seLonMin.Increment;
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

 ncols:=round((seLonMax.Value-seLonMin.Value)/grid_step);
 nrows:=round((seLatMax.Value-seLatMin.Value)/grid_step);

 GetFieldScript(cbAllOutputFiles.Text, //data file
                param, // variable name and its units
                (cbColumn.ItemIndex+3),
                ncols, nrows, //colums and rows
                seLonMin.Value, seLonMax.Value, seLatMin.Value, seLatMax.Value //region
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
  chkVariables.Items.Clear;
  chkVariables.Visible:=false;
  Application.ProcessMessages;


{T}for kt:=0 to ListBox1.Items.Count-1 do begin
{P}if (copy(ListBox1.items.strings[kt],1,2)='P_') then begin

    tbl:=ListBox1.items.strings[kt];
    if pos(' ',tbl)<>0 then tbl:=copy(tbl,1,(pos(' ',tbl)));
    tbl:=trim(tbl);

    with myQ do begin
      Close;
      SQL.Clear;
      SQL.Add(' Select count(distinct('+tbl+'.id)) as prf_count from station,'+tbl);
      SQL.Add(' where station.id='+tbl+'.id and duplicate=false');
      Open;
      prf_count:=FieldByName('prf_count').AsInteger;
      Close;
    end;

    chkVariables.items.add(ListBox1.items.strings[kt]+'  ('+inttostr(prf_count)+')');

{P}end;
{T}end;

   chkVariables.Visible:=true;
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
 for kt:=0 to chkVariables.Items.Count-1 do begin
 if chkVariables.Checked[kt] then begin
   tbl_count:=tbl_count+1;
 end;
 end;
 if tbl_count<>1 then begin
   showmessage('Variable (only one) should be selected!');
   Exit;
 end;

   chkLayers.Items.Clear;
   chkLayers.Visible:=false;
   Application.ProcessMessages;


{T}for kt:=0 to chkVariables.Items.Count-1 do begin
{P}if chkVariables.Checked[kt] then begin

     tbl:=chkVariables.items.Strings[kt];
     if pos(' ',tbl)<>0 then tbl:=copy(tbl,1,(pos(' ',tbl)));
     tbl:=trim(tbl);
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

     chkLayers.items.add(floattostr(L1)+'->'+floattostr(L2)+'  ('+inttostr(samples_count)+')');

{L}end;
{P}end;
{T}end;

    chkLayers.Visible:=true;
    Application.ProcessMessages;

    DT2:=NOW;
    memo1.Lines.Add('');
    memo1.Lines.Add('...stop: '+datetimetostr(DT2));
    memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;


procedure Tfrmviz_surfer_squares.lbSelectAllVariablesClick(Sender: TObject);
var
i: integer;
begin
   if lbSelectAllVariables.Caption='Select all' then begin
     for i:=0 to chkVariables.Items.Count-1 do chkVariables.Checked[i]:=true;
     lbSelectAllVariables.Caption:='Deselect all';
     Exit;
   end;

    if lbSelectAllVariables.Caption='Deselect all' then begin
     for i:=0 to chkVariables.Items.Count-1 do chkVariables.Checked[i]:=false;
     lbSelectAllVariables.Caption:='Select all';
     Exit;
   end;
end;


procedure Tfrmviz_surfer_squares.lbSelectAllLayersClick(Sender: TObject);
var
i:integer;
begin
   if lbSelectAllLayers.Caption='Select all' then begin
      for i:=0 to chkLayers.Items.Count-1 do chkLayers.Checked[i]:=true;
      lbSelectAllLayers.Caption:='Deselect all';
      Exit;
   end;
   if lbSelectAllLayers.Caption='Deselect all' then begin
      for i:=0 to chkLayers.Items.Count-1 do chkLayers.Checked[i]:=false;
      lbSelectAllLayers.Caption:='Select all';
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
 showmessage(user_path);
 cbAllOutputFiles.Items:=FindAllFiles(user_path, '*.txt', false);
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
      ltn:=seLatMax.Value-step*(klt-1);
      lts:=seLatMax.Value-step*klt;
      lt:=(ltn+lts)/2;
      //memo1.Lines.Add(inttostr(klt)+#9+floattostr(ltn)+'->'+floattostr(lts)+#9+floattostr(lt));

      kln:=0;
{Ln}repeat
      inc(kln);
      lnw:=seLonMin.Value+step*(kln-1);
      lne:=seLonMin.Value+step*kln;
      ln:=(lnw+lne)/2;
      //memo1.Lines.Add(#9+inttostr(kln)+#9+floattostr(lnw)+'->'+floattostr(lne)+#9+floattostr(ln));

      {...no duplicates, PQF2>2}
      with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' select count(id) as st_in_sq from STATION ');
        SQL.Add(' where duplicate=false ');
        SQL.Add(' and latitude>:lts and latitude<=:ltn ');
        {...select data from 180 meridian}
        if lne<>180 then SQL.Add(' and longitude>=:lnw and longitude<:lne ')
                    else SQL.Add(' and longitude>=:lnw and longitude<=:lne ');
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

{Ln}until lne=seLonMax.Value;
{Lt}until lts=seLatMin.Value;


      closefile(fo);
      closefile(fo1);

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

{T}for kt:=0 to chkVariables.Items.Count-1 do begin
{C}if chkVariables.Checked[kt] then begin

   tbl:=chkVariables.Items.Strings[kt];
   //memo1.Lines.Add(tbl);

{   with myQ do begin
     Close;
     SQL.Clear;
     SQL.Add(' Select count(distinct('+tbl+'.id)) as prf_count from station,'+tbl);
     SQL.Add(' where station.id='+tbl+'.id and duplicate=false');
     Open;
     prf_count:=FieldByName('prf_count').AsInteger;
     Close;
   end;

   memo1.Lines.Add(tbl+'  profiles#: '+inttostr(prf_count));
   Application.ProcessMessages;      }

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
      ltn:=seLatMax.Value-step*(klt-1);
      lts:=seLatMax.Value-step*klt;
      lt:=(ltn+lts)/2;
      //memo1.Lines.Add(inttostr(klt)+#9+floattostr(ltn)+'->'+floattostr(lts)+#9+floattostr(lt));

      kln:=0;
{Ln}repeat
      inc(kln);
      lnw:=seLonMin.Value+step*(kln-1);
      lne:=seLonMin.Value+step*kln;
      ln:=(lnw+lne)/2;

      min_dt:=dtpDateMax.DateTime;
      max_dt:=dtpDateMin.DateTime;

      {...no duplicates, PQF2>2}
      with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' select distinct(station.id), dateandtime from STATION,'+tbl);
        SQL.Add(' where station.id='+tbl+'.id and duplicate=false ');
        SQL.Add(' and dateandtime between :dmin and :dmax ');
        SQL.Add(' and latitude>:lts and latitude<=:ltn ');
        {...select data from 180 meridian}
        if lne<>180 then SQL.Add(' and longitude>=:lnw and longitude<:lne ')
                    else SQL.Add(' and longitude>=:lnw and longitude<=:lne ');
        //SQL.Add(' and longitude>=:lnw and longitude<:lne ');
        SQL.Add(' and PQF2>2 ');
        ParamByName('dmin').AsDateTime:=dtpDateMin.DateTime;
        ParamByName('dmax').AsDateTime:=dtpDateMax.DateTime;
        ParamByName('ltn').AsFloat:=ltn;
        ParamByName('lts').AsFloat:=lts;
        ParamByName('lnw').AsFloat:=lnw;
        ParamByName('lne').AsFloat:=lne;
        Open;
      end;

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

{Ln}until lne=seLonMax.Value;
{Lt}until lts=seLatMin.Value;
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
unit_id,tbl_count: integer;
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

      tbl_count:=0;
{T}for kt:=0 to chkVariables.Items.Count-1 do begin
{TC}if chkVariables.Checked[kt] then begin
   tbl_count:=tbl_count+1;
{TC}end;
{T} end;

  if tbl_count=0 then begin
     showmessage('Variable is not selected');
     Exit;
  end;


    DT1:=NOW;
    memo1.Lines.Add('...start: '+datetimetostr(DT1));
    memo1.Lines.Add('');

    sq_index:=floattostr(step)+'x'+floattostr(step)+'_';


{T}for kt:=0 to chkVariables.Items.Count-1 do begin
{TC}if chkVariables.Checked[kt] then begin

     tbl:=chkVariables.Items.Strings[kt];
     if pos(' ',tbl)<>0 then tbl:=copy(tbl,1,(pos(' ',tbl)));
     tbl:=trim(tbl);
     var_name:=copy(tbl,3,length(tbl));
     memo1.Lines.Add(tbl);

{L}for kl:=0 to chkLayers.Items.Count-1 do begin
{LC}if chkLayers.Checked[kl] then begin
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
      ltn:=seLatMax.Value-step*(klt-1);
      lts:=seLatMax.Value-step*klt;
      lt:=(ltn+lts)/2;
      //memo1.Lines.Add(inttostr(klt)+#9+floattostr(ltn)+'->'+floattostr(lts)+#9+floattostr(lt));

      kln:=0;
{Ln}repeat
      inc(kln);
      lnw:=seLonMin.Value+step*(kln-1);
      lne:=seLonMin.Value+step*kln;
      ln:=(lnw+lne)/2;

      n:=0;
      md:=0;
      sd:=0;
      s1:=0;
      s2:=0;
      min:=9999;
      max:=-9999;
      min_dt:=dtpDateMax.DateTime;
      max_dt:=dtpDateMin.DateTime;

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
        SQL.Add(' and dateandtime between :dmin and :dmax ');
        SQL.Add(' and latitude>:lts and latitude<=:ltn ');
        {...select data from 180 meridian}
        if lne<>180 then SQL.Add(' and longitude>=:lnw and longitude<:lne ')
                    else SQL.Add(' and longitude>=:lnw and longitude<=:lne ');
        //SQL.Add(' and longitude>=:lnw and longitude<:lne ');
        SQL.Add(' and lev_m>=:L1 and lev_m<:L2 ');
        SQL.Add(' and PQF2>2 ');
        ParamByName('dmin').AsDateTime:=dtpDateMin.DateTime;
        ParamByName('dmax').AsDateTime:=dtpDateMax.DateTime;
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

     if tbl = 'P_TEMPERATURE' then vu:=true;
     if tbl = 'P_SALINITY' then vu:=true;
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


{Ln}until lne=seLonMax.Value;
{Lt}until lts=seLatMin.Value;


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
tbl_count,station_id,PQF1,unit_id: integer;
L1,L2,val: real;
ltn,lts,lt,lnw,lne,ln :real;
sq_index,tbl,L1_str,L2_str,var_name,dir_name: string;
DT1,DT2 :TDateTime;
skip :boolean;

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
{T}for kt:=0 to chkVariables.Items.Count-1 do begin
{TC}if chkVariables.Checked[kt] then begin
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

{T}for kt:=0 to chkVariables.Items.Count-1 do begin
{TC}if chkVariables.Checked[kt] then begin

   tbl:=chkVariables.items.Strings[kt];
   if pos(' ',tbl)<>0 then tbl:=copy(tbl,1,(pos(' ',tbl)));
   tbl:=trim(tbl);
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

   fn:=dir_name+sq_index+var_name+'_'+L1_str+'-'+L2_str+'_arbitrary_mask.txt';
   assignfile(fo1,fn);
   rewrite(fo1);
   writeln(fo1,'lon'+#9+'lat');

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
        SQL.Add(' select station.id as station_id, dateandtime,val,PQF1,units_id from STATION,'+tbl);
        SQL.Add(' where station.id='+tbl+'.id and duplicate=false');
        SQL.Add(' and latitude>:lts and latitude<=:ltn ');
        {...select data from 180 meridian}
        if lne<>180 then SQL.Add(' and longitude>=:lnw and longitude<:lne ')
                    else SQL.Add(' and longitude>=:lnw and longitude<=:lne ');
        //SQL.Add(' and longitude>=:lnw and longitude<:lne ');
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

     station_id:=frmdm.q1.FieldByName('station_id').AsInteger;
     val:=frmdm.q1.FieldByName('val').AsFloat;
     PQF1:=frmdm.q1.FieldByName('PQF1').AsInteger;
     unit_id:=frmdm.q1.FieldByName('units_id').AsInteger;
     val_dt:=frmdm.q1.FieldByName('dateandtime').AsDateTime;

     {...skip unchecked samples from ITP and ARGO}
      skip:=false;
      if (station_id>=10000001) and (station_id<=15000001) and (PQF1=0) then skip:=true;  //ITP
      if (station_id>=20000001) and (station_id<=30000001) and (PQF1=0) then skip:=true;  //ARGO

{SKIP}if skip=false then begin

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


     if tbl = 'P_TEMPERATURE' then vu:=true;
     if tbl = 'P_SALINITY' then vu:=true;
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

{SKIP}end;
     frmdm.q1.Next;
{W}end;
     frmdm.q1.Close;

     ts_length_years:=High(TSL_y);
     ts_length_months:=High(TSL_m);

    {...without zero}
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

    {...without zero}
     if n=0 then writeln(fo1,floattostr(ln),#9,floattostr(lt));

{Ln}until lne=180;
{Lt}until lts=-90;
     closefile(fo);
     closefile(fo1);
{TC}end;
{T} end;

     DT2:=NOW;
     memo1.Lines.Add('');
     memo1.Lines.Add('...stop: '+datetimetostr(DT2));
     memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;

procedure Tfrmviz_surfer_squares.save_settings;
Var
  Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
  try
   Ini.WriteInteger (name, 'Squares', rgSquares.ItemIndex);
   Ini.WriteString  (name, 'LonMin',  seLonMin.Text);
   Ini.WriteString  (name, 'LonMax',  seLonMax.Text);
   Ini.WriteString  (name, 'LatMin',  seLatMin.Text);
   Ini.WriteString  (name, 'LatMax',  seLatMax.Text);
   Ini.WriteDateTime(name, 'DateMin', dtpDateMin.DateTime);
   Ini.WriteDateTime(name, 'DateMax', dtpDateMax.DateTime);
  finally
    Ini.Free;
  end;
end;


end.

