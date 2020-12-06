unit osqc_outliers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, Spin, FileUtil;

type

  { Tfrmoutliers }

  Tfrmoutliers = class(TForm)
    btnExportAllPlots: TBitBtn;
    btnSelectAllSources: TBitBtn;
    btnSelectAll: TBitBtn;
    btnStart: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckGroup1: TCheckGroup;
    CheckGroup2: TCheckGroup;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    SpinEdit1: TSpinEdit;
    procedure btnExportAllPlotsClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnSelectAllSourcesClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure ComboBox1DropDown(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure GrapherPlotOutliers(fn_MP,fn_samples,fn_outliers: string;
      units_def_id:integer;  units_def_name:string; single_plot:boolean);
  public

  end;

var
  frmoutliers: Tfrmoutliers;
  user_path,update_path,select_path: string;
  fn:string;
  fo_MP,fo_samples,fo_update,fo_select,fo_statistics,fi_samples: text;
  script: text;

implementation

uses osmain, dm, osunitsconversion;

{$R *.lfm}

{ Tfrmoutliers }


procedure Tfrmoutliers.FormShow(Sender: TObject);
begin
  CheckGroup1.items:=frmosmain.ListBox1.Items;

  user_path:=GlobalUnloadPath+PathDelim+'outliers'+PathDelim;

  with frmdm.q1 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select name from SOURCE ');
    SQL.Add(' where station_id_min>0 ');
    Open;
  end;

  while not frmdm.q1.EOF do begin
    name:=frmdm.q1.FieldByName('name').AsString;
    ListBox1.Items.Add(name);
    frmdm.q1.Next;
  end;
    frmdm.q1.Close;

    CheckGroup2.items:=ListBox1.Items;

    frmoutliers.Caption:='frmoutliers';
end;


procedure Tfrmoutliers.btnSelectAllClick(Sender: TObject);
var
i: integer;
begin
  if btnSelectAll.Caption='Select all' then begin
    for i:=0 to CheckGroup1.Items.Count-1 do CheckGroup1.Checked[i]:=true;
    btnSelectAll.Caption:='Deselect all';
    Exit;
  end;
  if btnSelectAll.Caption='Deselect all' then begin
    for i:=0 to CheckGroup1.Items.Count-1 do CheckGroup1.Checked[i]:=false;
    btnSelectAll.Caption:='Select all';
    Exit;
  end;
end;



procedure Tfrmoutliers.btnSelectAllSourcesClick(Sender: TObject);
var
i: integer;
begin
  if btnSelectAllSources.Caption='Select all' then begin
    for i:=0 to CheckGroup2.Items.Count-1 do CheckGroup2.Checked[i]:=true;
    btnSelectAllSources.Caption:='Deselect all';
    Exit;
  end;
  if btnSelectAllSources.Caption='Deselect all' then begin
    for i:=0 to CheckGroup2.Items.Count-1 do CheckGroup2.Checked[i]:=false;
    btnSelectAllSources.Caption:='Select all';
    Exit;
  end;
end;

procedure Tfrmoutliers.btnStartClick(Sender: TObject);
type
   layer=record
     L1:real;
     L2:real;
     n:integer;
     md:real;
     sd:real;
     s1:double;
     s2:double;
     min:real;
     max:real;
   end;
   LS=array of layer;  {layer statistics}

   single_source=record
     name:string;
     id_min:integer;
     id_max:integer;
   end;
   SS=array of single_source;

var
MP: LS; {mean profile}
Sources: SS; {sources name and range}
SSID: array of integer; {selected stations id}

i,kt,ks,klt,kln,kL :integer;
s_count,step,sqn,s_min,s_max,prf_in_sq,samples_in_sq,sq_count,n :integer;
station_id,pqf2,units_id,units_def,instrument_id,profile_number :integer;
uid_count,samples_count,samples_total,outliers_count,outliers_total,sd_factor,msl :integer;
ltn,lts,lnw,lne,ld1,ld2,L1,L2,LM :real;
lev_m,val,val_conv: real;
sd1L,sd1R,sd2L,sd2R,sd3L,sd3R,sd4L,sd4R,sd5L,sd5R :real;
md,sd,sdL,sdR :real;
s1,s2 :double;
tbl,lt_str,ln_str,sqn_str,s_name :string;
s_selected,isconverted,val_outside_sd,new_id: boolean;
DT1,DT2: TDateTime;
begin

   DT1:=NOW;
   memo1.Lines.Add('...start [crossover analysis]: '+datetimetostr(DT1));

   //user_path:=GlobalUnloadPath+PathDelim+'outliers'+PathDelim;
   if directoryexists(user_path)=true then deletedirectory(user_path,true);
   if directoryexists(user_path)=false then mkdir(user_path);

   update_path:=GlobalUnloadPath+PathDelim+'outliers'+PathDelim+'update'+PathDelim;
   if directoryexists(update_path)=true then deletedirectory(update_path,true);
   if directoryexists(update_path)=false then mkdir(update_path);

   select_path:=GlobalUnloadPath+PathDelim+'outliers'+PathDelim+'select'+PathDelim;
   if directoryexists(select_path)=true then deletedirectory(select_path,true);
   if directoryexists(select_path)=false then mkdir(select_path);

   s_count:=0;
{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{TC}if CheckGroup1.Checked[kt] then begin
   s_count:=s_count+1;
{TC}end;
{T} end;
   if s_count=0 then begin
     showmessage('Variable does not selected!');
     Exit;
   end;

   s_count:=0;
{S}for ks:=0 to CheckGroup2.Items.Count-1 do begin
{SC}if CheckGroup2.Checked[ks] then begin
   s_count:=s_count+1;
{SC}end;
{S} end;
   if s_count=0 then begin
     showmessage('Source(s) does not selected!');
     Exit;
   end;


{.....selected sources for mean profile computing in a square}
    memo1.Lines.Add('...selected sources');
    memo1.Lines.Add('name  st_id_min  st_id_max');
    s_count:=0;
    setlength(Sources,1);  //skip 0 index
{S}for ks:=0 to CheckGroup2.Items.Count-1 do begin
{C}if CheckGroup2.Checked[ks] then begin
    s_count:=s_count+1;
    s_name:=CheckGroup2.Items.Strings[ks]; {selected source}
  with frmdm.q1 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select station_id_min as s_min, station_id_max as s_max from SOURCE ');
    SQL.Add(' where name=:name ');
    ParamByName('name').AsString:=s_name;
    Open;
    s_min:=FieldByName('s_min').AsInteger;
    s_max:=FieldByName('s_max').AsInteger;
    Close;
  end;

    setlength(Sources,s_count+1);
    Sources[s_count].name:=s_name;
    Sources[s_count].id_min:=s_min;
    Sources[s_count].id_max:=s_max;

  memo1.Lines.Add(s_name+#9+inttostr(s_min)+#9+inttostr(s_max));

{C}end;
{S}end;
{............................................selected sources}




{.....P_tables}
   samples_total:=0; {total outliers in table}
   outliers_total:=0; {total outliers in table}
   step:=strtoint(Edit1.Text);
{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
   sq_count:=0; //squares with data
{C}if CheckGroup1.Checked[kt] then begin

   Edit6.Text:='';
   Edit7.Text:='';
   Edit8.Text:='';
   Edit9.Text:='';

   tbl:=CheckGroup1.Items.Strings[kt]; {selected table}
   memo1.Lines.Add(tbl);
   Edit9.Text:=tbl;
   Application.ProcessMessages;

   {statistics in squares}
   fn:=user_path+'_'+tbl+'_sq_statistics.txt';
   assignfile(fo_statistics,fn);
   rewrite(fo_statistics);
   writeln(fo_statistics,'square'
   +#9+'sampels#'
   +#9+'outliers#'
   +#9+'lts'
   +#9+'ltn'
   +#9+'lnw'
   +#9+'lne');

   {...variable default unit}
   with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select * from DATABASE_TABLES ');
     SQL.Add(' where name_table=:tbl ');
     ParamByName('tbl').AsString:=tbl;
     Open;
     units_def:=FieldByName('units_id_default').AsInteger;
     Close;
   end;

      sqn:=0;
      klt:=0;
{Lt}repeat
      inc(klt);
      ltn:=90-step*(klt-1);
      lts:=90-step*klt;
      //lt:=(ltn+lts)/2;
      lt_str:=floattostr(lts)+' '+floattostr(ltn);
      Edit7.Text:=floattostr(lts)+' -> '+floattostr(ltn);

      kln:=0;
{Ln}repeat
      inc(kln);
      lnw:=-180+step*(kln-1);
      lne:=-180+step*kln;
      //ln:=(lnw+lne)/2;
      inc(sqn);

      Edit6.Text:=inttostr(sqn);
      sqn_str:=inttostr(sqn);
      if length(sqn_str)<4 then for i:=1 to (4-length(sqn_str)) do sqn_str:='0'+sqn_str;

      ln_str:=floattostr(lnw)+' '+floattostr(lne);
      Edit8.Text:=floattostr(lnw)+' -> '+floattostr(lne);
      Application.ProcessMessages;


{.....clean MP for each square}
{.....44 layers SeaDataCloud (SDC) climatology 0-6000m}
  setlength(MP,1);  //skip 0 index
  ld1:=0;
  ld2:=0;
{MP}for kL:=1 to 44 do begin
      setlength(MP,kL+1);

      {10m layers 2->10(10) 0-100m}
      if (kl>=1) and (kl<=10) then begin
        ld1:=ld1;
        ld2:=ld1+10;
        MP[kl].l1:=ld1;
        MP[kl].l2:=ld2;
        ld1:=ld2;
      end;
      {25m layers 11->26(16) 100-500m}
      if (kl>=11) and (kl<=26) then begin
        ld1:=ld1;
        ld2:=ld1+25;
        MP[kl].l1:=ld1;
        MP[kl].l2:=ld2;
        ld1:=ld2;
      end;
      {100m layers 27->31(5) 500-1000m}
      if (kl>=27) and (kl<=31) then begin
        ld1:=ld1;
        ld2:=ld1+100;
        MP[kl].l1:=ld1;
        MP[kl].l2:=ld2;
        ld1:=ld2;
      end;
      {200m layers 32->36(5) 1000-2000m}
      if (kl>=32) and (kl<=36) then begin
        ld1:=ld1;
        ld2:=ld1+200;
        MP[kl].l1:=ld1;
        MP[kl].l2:=ld2;
        ld1:=ld2;
      end;
      {500m layers 37->44(8) 2000-6000m}
      if (kl>=37) and (kl<=44) then begin
        ld1:=ld1;
        ld2:=ld1+500;
        MP[kl].l1:=ld1;
        MP[kl].l2:=ld2;
        ld1:=ld2;
      end;

      MP[kl].n:=0;
      MP[kl].md:=0;
      MP[kl].sd:=0;
      MP[kl].s1:=0;
      MP[kl].s2:=0;
      MP[kl].min:=9999;
      MP[kl].max:=-9999;
{MP}end;
      sd1L:=0; sd1R:=0;
      sd2L:=0; sd2R:=0;
      sd3L:=0; sd3R:=0;
      sd4L:=0; sd4R:=0;
      sd5L:=0; sd5R:=0;
{.................................clean MP}


{.....STEP1 compute mean profile for each square}
   {...q1 stations.id with oxygen inside square, not duplicates, PQF2>2}
   {...no duplicates, PQF2>2}
with frmdm.q1 do begin
  Close;
  SQL.Clear;
  SQL.Add(' select distinct(station.id)  from STATION,'+tbl);
  SQL.Add(' where station.id='+tbl+'.id and duplicate=false');
  SQL.Add(' and latitude>:lts and latitude<=:ltn ');
  SQL.Add(' and extract(year from dateandtime)>=:Y1 and extract(year from dateandtime)<=:Y2 ');
  {...select data from 180 meridian}
  if lne<>180 then SQL.Add(' and longitude>=:lnw and longitude<:lne ')
              else SQL.Add(' and longitude>=:lnw and longitude<=:lne ');
  SQL.Add(' and PQF1<>0 and PQF2>=3 '); //skip unchecked ARGO,ITP and bad,suspitious samples
  ParamByName('ltn').AsFloat:=ltn;
  ParamByName('lts').AsFloat:=lts;
  ParamByName('lnw').AsFloat:=lnw;
  ParamByName('lne').AsFloat:=lne;
  ParamByName('Y1').AsInteger:=strtoint(Edit2.Text);
  ParamByName('Y2').AsInteger:=strtoint(Edit3.Text);
  Open;
end;

    prf_in_sq:=0;
    samples_in_sq:=0;
    frmdm.q1.First;
{q1}while not frmdm.q1.EOF do begin
    station_id:=frmdm.q1.FieldByName('id').AsInteger;
    {...check sources}
    s_selected:=false;
    for ks:=1 to High(Sources) do
    if (station_id>=Sources[ks].id_min) and (station_id<=Sources[ks].id_max) then s_selected:=true;

{SS}if s_selected=true then begin

  prf_in_sq:=prf_in_sq+1;
  with frmdm.q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' Select * from '+tbl);
    SQL.Add(' where id=:station_id ');
    SQL.Add(' and PQF1<>0 and PQF2>=3 ');
    ParamByName('station_id').AsInteger:=station_id;
    Open;
  end;

  {.....MP}
    frmdm.q2.First;
{q2}while not frmdm.q2.EOF do begin

    lev_m         :=frmdm.q2.FieldByName('lev_m').AsFloat;
    val           :=frmdm.q2.FieldByName('val').AsFloat;
    pqf2          :=frmdm.q2.FieldByName('pqf2').AsInteger;
    units_id       :=frmdm.q2.FieldByName('units_id').AsInteger;
    instrument_id :=frmdm.q2.FieldByName('instrument_id').AsInteger;
    profile_number:=frmdm.q2.FieldByName('profile_number').AsInteger;

{CONVERSION}if units_id<>units_def then begin
     val_conv:=-9999;
     isconverted:=false;
     getdefaultunits(tbl,units_id,units_def,val,val_conv,isconverted);
     if isconverted=true then val:=val_conv;
{CONVERSION}end;

{val}if val<>-9999 then begin

     samples_in_sq:=samples_in_sq+1;
     {...fo_samples}
     if samples_in_sq=1 then begin
       fn:=user_path+tbl+'_'+sqn_str+'_'+lt_str+'_'+ln_str+'_samples.txt';
       assignfile(fo_samples,fn);
       rewrite(fo_samples);
       writeln(fo_samples,'lev_m'+#9+'val'+#9+'units_origin'+#9+'units_default'
       +#9+'PQF2'+#9+'station_id'+#9+'instrument_id'+#9+'profile_number');
     end;

{MP}for kl:=1 to High(MP) do begin
     L1:=MP[kl].L1;
     L2:=MP[kl].L2;

{in}if (lev_m>=L1) and (lev_m<L2) then begin
     MP[kl].n:=MP[kl].n+1;
     MP[kl].s1:=MP[kl].s1+val;
     MP[kl].s2:=MP[kl].s2+val*val;
     if MP[kl].min>val then MP[kl].min:=val;
     if MP[kl].max<val then MP[kl].max:=val;

     writeln(fo_samples,floattostrF(lev_m,ffFixed,7,1),
     #9,floattostrF(val,ffFixed,9,3),
     #9,inttostr(units_id),
     #9,inttostr(units_def),
     #9,inttostr(pqf2),
     #9,inttostr(station_id),
     #9,inttostr(instrument_id),
     #9,inttostr(profile_number)
     );

{in}end;
{MP}end;
{val}end;
    frmdm.q2.Next;
{q2}end;
    frmdm.q2.Close;
{SS}end;
    frmdm.q1.Next;
{q1}end;
    frmdm.q1.Close;
    if prf_in_sq>0 then closefile(fo_samples);

{...output mean profile for each square}
{0} if prf_in_sq>0 then begin

   sq_count:=sq_count+1;

   fn:=user_path+tbl+'_'+sqn_str+'_'+lt_str+'_'+ln_str+'_MP.txt';
   assignfile(fo_MP,fn);
   rewrite(fo_MP);
   writeln(fo_MP,'(m)'+#9+'md'+#9+'sd'+#9+'min'+#9+'max'+#9+'n'+#9+'L1'+#9+'L2'
   +#9+'1sdL'+#9+'1sdR'+#9+'2sdL'+#9+'2sdR'+#9+'3sdL'+#9+'3sdR'+#9+'4sdL'+#9+'4sdR'+#9+'5sdL'+#9+'5sdR');


{MP}for kl:=1 to High(MP) do begin
     L1:=MP[kl].L1;
     L2:=MP[kl].L2;
     LM:=(L2+L1)/2;

     n :=MP[kl].n;
     s1:=MP[kl].s1;
     s2:=MP[kl].s2;

{n}if n<>0 then begin

     MP[kl].md:=s1/n;
     MP[kl].sd:=(s2-s1*s1/n)/n;
     if MP[kl].sd<>0 then MP[kl].sd:=sqrt(abs(MP[kl].sd));

     sd1L:=MP[kl].md - 1*MP[kl].sd;
     sd1R:=MP[kl].md + 1*MP[kl].sd;
     sd2L:=MP[kl].md - 2*MP[kl].sd;
     sd2R:=MP[kl].md + 2*MP[kl].sd;
     sd3L:=MP[kl].md - 3*MP[kl].sd;
     sd3R:=MP[kl].md + 3*MP[kl].sd;
     sd4L:=MP[kl].md - 4*MP[kl].sd;
     sd4R:=MP[kl].md + 4*MP[kl].sd;
     sd5L:=MP[kl].md - 5*MP[kl].sd;
     sd5R:=MP[kl].md + 5*MP[kl].sd;

     {...how many measurements?}
     if MP[kl].n>=3 then
     writeln(fo_MP,floattostrF(LM,ffFixed,9,3),
     #9,floattostrF(MP[kl].md,ffFixed,9,3),
     #9,floattostrF(MP[kl].sd,ffFixed,9,3),
     #9,floattostrF(MP[kl].min,ffFixed,9,3),
     #9,floattostrF(MP[kl].max,ffFixed,9,3),
     #9,inttostr(MP[kl].n),
     #9,floattostrF(L1,ffFixed,9,3),
     #9,floattostrF(L2,ffFixed,9,3),
     #9,floattostrF(sd1L,ffFixed,9,3),
     #9,floattostrF(sd1R,ffFixed,9,3),
     #9,floattostrF(sd2L,ffFixed,9,3),
     #9,floattostrF(sd2R,ffFixed,9,3),
     #9,floattostrF(sd3L,ffFixed,9,3),
     #9,floattostrF(sd3R,ffFixed,9,3),
     #9,floattostrF(sd4L,ffFixed,9,3),
     #9,floattostrF(sd4R,ffFixed,9,3),
     #9,floattostrF(sd5L,ffFixed,9,3),
     #9,floattostrF(sd5R,ffFixed,9,3));

{n}end;
{MP}end;
     closefile(fo_MP);
{0} end;
{....................................STEP1}



{STEP2   determine outliers and write into file: update and select }
{IF}if samples_in_sq>0 then begin
   msl:=strtoint(Edit4.Text); //minimum samples in layer
   //sd_factor:=strtoint(Edit5.Text);
   sd_factor:=SpinEdit1.Value;

   {input file}
   fn:=user_path+tbl+'_'+sqn_str+'_'+lt_str+'_'+ln_str+'_samples.txt';
   assignfile(fi_samples,fn);
   reset(fi_samples);

   readln(fi_samples);
   samples_count:=0; {total outliers in square}
   outliers_count:=0; {total outliers in square}
   uid_count:=0; {unique station_id number count}
   setlength(SSID,1);
   SSID[0]:=0;


{SAMPLES}while not EOF(fi_samples) do begin

   readln(fi_samples,lev_m,val,units_id,units_def,PQF2,station_id,instrument_id,profile_number);
   samples_count:=samples_count+1;

{MP}for kl:=1 to High(MP) do begin
   L1:=MP[kl].L1;
   L2:=MP[kl].L2;
   LM:=(L2+L1)/2;

   n :=MP[kl].n;
   md:=MP[kl].md;
   sd:=MP[kl].sd;

   sdL:=md - sd_factor*sd;
   sdR:=md + sd_factor*sd;

   val_outside_sd:=false;
   if (val<=sdL) or (val>=sdR) then val_outside_sd:=true;

{SD}if (lev_m>=L1) and (lev_m<L2) and (val_outside_sd=true)
    and (n>=msl) then begin

     outliers_count:=outliers_count+1;
     new_id:=true;
     for i:=0 to High(SSID) do if station_id=SSID[i] then new_id:=false;

{new}if new_id=true then begin
     uid_count:=uid_count+1;
     setlength(SSID,uid_count+1);
     SSID[uid_count]:=station_id;
{new}end;

   if outliers_count=1 then begin
   {create file UPDATE}
   fn:=update_path+tbl+'_'+sqn_str+'_'+lt_str+'_'+ln_str+'_outliers_update.txt';
   assignfile(fo_update,fn);
   rewrite(fo_update);
   writeln(fo_update,'station_id'+#9+'lev_m'+#9+'val'+#9+'PQF2'+#9+'instrument_id'+#9+'profile_number');
   end;

   {write into file UPDATE}
   if outliers_count>0 then
   writeln(fo_update,inttostr(station_id),
   #9,floattostr(lev_m),
   #9,floattostr(val),
   #9,floattostr(PQF2),
   #9,inttostr(instrument_id),
   #9,inttostr(profile_number));

   if CheckBox1.Checked then
   with frmdm.q3 do begin
    Close;
     SQL.Clear;
     SQL.Add(' UPDATE '+tbl+' SET PQF2=:QF WHERE ');
     SQL.Add(' ID=:ID AND LEV_M=:LEV_M AND VAL=:VAL AND ');
     SQL.Add(' INSTRUMENT_ID=:INSTR_ID AND ');
     SQL.Add(' PROFILE_NUMBER=:PROF_NUM ');
     ParamByName('ID').Value:=station_id;
     ParamByName('QF').Value:=2;
     ParamByName('LEV_M').Value:=lev_m;
     ParamByName('VAL').Value:=val;
     ParamByName('INSTR_ID').Value:=instrument_id;
     ParamByName('PROF_NUM').Value:=profile_number;
    ExecSQL;
   end;

{SD}end;
{MP}end;
{SAMPLES} end;
   closefile(fi_samples);
   if outliers_count>0 then closefile(fo_update);

   outliers_total:=outliers_total+outliers_count;

   if High(SSID)>0 then begin
   {output file SELECT}
   fn:=select_path+tbl+'_'+sqn_str+'_'+lt_str+'_'+ln_str+'_outliers_select.txt';
   assignfile(fo_select,fn);
   rewrite(fo_select);
   writeln(fo_select,'station_id');
   for i:=1 to High(SSID) do writeln(fo_select,inttostr(SSID[i]));
   closefile(fo_select);
   end;

{IF}end;
{.........................................STEP2}

   samples_total:=samples_total+samples_count;

    writeln(fo_statistics,inttostr(sqn),
    #9,inttostr(samples_count),
    #9,inttostr(outliers_count),
    #9,floattostr(lts),
    #9,floattostr(ltn),
    #9,floattostr(lnw),
    #9,floattostr(lne));


    setlength(SSID,0);
    setlength(MP,0);
{Ln}until lne=180;
{Lt}until lts=-90;
    memo1.Lines.Add('number of squares with data='+inttostr(sq_count));
    memo1.Lines.Add('total  number  of samples ='+inttostr(samples_total));
    memo1.Lines.Add('total  number  of outliers ='+inttostr(outliers_total));
    memo1.Lines.Add('%  of outliers ='+floattostr(100*outliers_total/samples_total));

   if (outliers_count>0) and CheckBox1.Checked then frmdm.TR.CommitRetaining;

{C}end; {table is checked }
{T}end; {tables cycle}
    closefile(fo_statistics);

DT2:=NOW;
memo1.Lines.Add('');
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));



end;

procedure Tfrmoutliers.ComboBox1DropDown(Sender: TObject);
begin
{function FindAllFiles(const SearchPath: String; SearchMask: String = '';
  SearchSubDirs: Boolean = True): TStringList;}

    //ComboBox1.Items:=FindAllFiles(user_path, 'P_OXYGEN_0586_62 66_0 4_MP.txt', false);
    ComboBox1.Items:=FindAllFiles(user_path, '*_MP.txt', false);
end;



procedure Tfrmoutliers.btnExportAllPlotsClick(Sender: TObject);
var
i,ksq,mik,sp,units_def_id :integer;
path,prefix,tblsq,tbl,fn_MP,fn_samples,fn_outliers,units_def_name: string;
single_plot: boolean;
DT1,DT2: TDateTime;
begin

   DT1:=NOW;
   memo1.Lines.Add('...start [export all plots]: '+datetimetostr(DT1));

   ComboBox1.Items:=FindAllFiles(user_path, '*_MP.txt', false);

   if (CheckBox2.Checked=false) and (CheckBox3.Checked=false) then begin
    showmessage('Export formate has to be selected!');
    Exit;
   end;

{sq}for ksq:=0 to ComboBox1.Items.Count-1 do begin
     //memo1.Lines.Add(ComboBox1.Items.Strings[ksq]);
     fn_MP:=ComboBox1.Items.Strings[ksq];
     path:=ExtractFilePath(fn_MP);
     tblsq:=ExtractFileName(fn_MP);  //table + square
     tblsq:=copy(tblsq,1,(length(tblsq)-7));
     prefix:=copy(fn_MP,1,(length(fn_MP)-7));

       mik:=0;
     for i:=1 to length(tblsq) do begin
       if tblsq[i]='_' then mik:=mik+1;
       if mik=1 then sp:=i; //symbol position in the string
     end;

     tbl:=copy(tblsq,1,sp);

     with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' select * from DATABASE_TABLES ');
        SQL.Add(' where name_table=:tbl ');
        ParamByName('tbl').AsString:=tbl;
       Open;
       units_def_id:=FieldByName('units_id_default').AsInteger;
       Close;
     end;

     with frmdm.q1 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select name from UNITS ');
       SQL.Add(' where id=:units_def_id ');
       ParamByName('units_def_id').AsInteger:=units_def_id;
       Open;
       units_def_name:=FieldByName('name').AsString;
       Close;
     end;

     fn_samples:=prefix+'_samples.txt';
     fn_outliers:=path+'update'+PathDelim+tblsq+'_outliers_update.txt';

     single_plot:=false;
     if fileexists(fn_outliers) then
     GrapherPlotOutliers(fn_MP,fn_samples,fn_outliers,units_def_id,units_def_name,single_plot);

{sq}end;

DT2:=NOW;
memo1.Lines.Add('');
memo1.Lines.Add('...stop  [export all plots]: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;



procedure Tfrmoutliers.ComboBox1Select(Sender: TObject);
var
i,mik,sp,units_def_id :integer;
path,prefix,tblsq,tbl,fn_MP,fn_samples,fn_outliers,units_def_name: string;
single_plot: boolean;
begin
  fn_MP:=ComboBox1.Text;
  path:=ExtractFilePath(ComboBox1.Text);
  tblsq:=ExtractFileName(ComboBox1.Text);  //table + square
  tblsq:=copy(tblsq,1,(length(tblsq)-7));
  prefix:=copy(ComboBox1.Text,1,(length(fn_MP)-7));

    mik:=0;
  for i:=1 to length(tblsq) do begin
    if tblsq[i]='_' then mik:=mik+1;
    if mik=1 then sp:=i; //symbol position in the string
  end;
    tbl:=copy(tblsq,1,sp);

    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select * from DATABASE_TABLES ');
      SQL.Add(' where name_table=:tbl ');
      ParamByName('tbl').AsString:=tbl;
      Open;
      units_def_id:=FieldByName('units_id_default').AsInteger;
      Close;
    end;

    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select name from UNITS ');
      SQL.Add(' where id=:units_def_id ');
      ParamByName('units_def_id').AsInteger:=units_def_id;
      Open;
      units_def_name:=FieldByName('name').AsString;
      Close;
    end;

  fn_samples:=prefix+'_samples.txt';
  fn_outliers:=path+'update'+PathDelim+tblsq+'_outliers_update.txt';

  single_plot:=true;
  GrapherPlotOutliers(fn_MP,fn_samples,fn_outliers,units_def_id,units_def_name,single_plot);

end;



procedure Tfrmoutliers.GrapherPlotOutliers(fn_MP,fn_samples,fn_outliers:string;
  units_def_id:integer; units_def_name:string; single_plot:boolean);
var
ks,sd_factor,plot_count,s_count: integer;
fsize :real;
str,sdL,sdR,pc: string;
qchar: char;
file_too_big :boolean;
begin

  memo1.Lines.Add(fn_MP);
  //memo1.Lines.Add(fn_samples);
  //memo1.Lines.Add(fn_outliers);
  Application.ProcessMessages;

{to plot correct information the setting should be the same as when the files were created}
  s_count:=0;
{S}for ks:=0 to CheckGroup2.Items.Count-1 do begin
{SC}if CheckGroup2.Checked[ks] then begin
  s_count:=s_count+1;
{SC}end;
{S} end;
  if s_count=0 then begin
    showmessage('Source(s) does not selected!');
    Exit;
  end;

  qchar:='"';
  plot_count:=0;

AssignFile(script,user_path+'outliers.bas');
rewrite(script);
{...start creating script}
Writeln(script, 'Sub Main');
Writeln(script, '');
Writeln(script, ' Dim Grapher,Plot,Graph As Object');
Writeln(script, '');

{...path to data files}
WriteLn(script, ' path_MP ="' +fn_MP+'"');
WriteLn(script, ' path_samples ="' +fn_samples+'"');
WriteLn(script, ' path_outliers ="' +fn_outliers+'"');
Writeln(script, '');

{...set Grapher variable as Grapher Application Object}
Writeln(script, ' Set Grapher = CreateObject("Grapher.Application") ');
if single_plot=true  then Writeln(script, ' Grapher.Visible = True');
if single_plot=false then Writeln(script, ' Grapher.Visible = False');
Writeln(script, '');

{...set Plot variable as Plot Document Object}
Writeln(script, ' Set Plot = Grapher.Documents.Add(grfPlotDoc) ');
Writeln(script, ' Plot.PageSetup.Orientation = grfLandscape ');
Writeln(script, '');

{...Graph text information}
str:='Settings for mean profiles and outliers ';
str:=AnsiQuotedStr(str,qchar);
Writeln(script, ' Set Txt=Plot.Shapes.AddText(3,19.4, ' +str +')' );
Writeln(script, ' txt.Font.Size=10 ');
Writeln(script, ' txt.Font.Face="Courier New" ');
Writeln(script, ' txt.Font.Bold=true ');
Writeln(script, '');
str:='mean profile - sources (all squares): ';
{S}for ks:=0 to CheckGroup2.Items.Count-1 do begin
{SC}if CheckGroup2.Checked[ks] then begin
str:=str+CheckGroup2.Items.Strings[ks]+'; ';
{SC}end;
{S} end;
str:=AnsiQuotedStr(str,qchar);
Writeln(script, ' Set Txt=Plot.Shapes.AddText(3,19, ' +str +')' );
Writeln(script, ' txt.Font.Size=10 ');
Writeln(script, ' txt.Font.Face="Courier New" ');
Writeln(script, ' txt.Font.Bold=true ');
Writeln(script, '');
str:='mean profile - square size (deg): ';
str:=str+Edit1.Text+'x'+Edit1.Text;
str:=AnsiQuotedStr(str,qchar);
Writeln(script, ' Set Txt=Plot.Shapes.AddText(3,18.6, ' +str +')' );
Writeln(script, ' txt.Font.Size=10 ');
Writeln(script, ' txt.Font.Face="Courier New" ');
Writeln(script, ' txt.Font.Bold=true ');
Writeln(script, '');
str:='mean profile - period (years): ';
str:=str+Edit2.Text+'-'+Edit3.Text;
str:=AnsiQuotedStr(str,qchar);
Writeln(script, ' Set Txt=Plot.Shapes.AddText(3,18.2, ' +str +')' );
Writeln(script, ' txt.Font.Size=10 ');
Writeln(script, ' txt.Font.Face="Courier New" ');
Writeln(script, ' txt.Font.Bold=true ');
Writeln(script, '');
str:='outliers - minimum number of samples in a layer for sd computing: ';
str:=str+Edit4.Text;
str:=AnsiQuotedStr(str,qchar);
Writeln(script, ' Set Txt=Plot.Shapes.AddText(3,17.8, ' +str +')' );
Writeln(script, ' txt.Font.Size=10 ');
Writeln(script, ' txt.Font.Face="Courier New" ');
Writeln(script, ' txt.Font.Bold=true ');
Writeln(script, '');
str:='outliers - standard deviation factor for outlies definition: ';
str:=str+inttostr(SpinEdit1.Value);
str:=AnsiQuotedStr(str,qchar);
Writeln(script, ' Set Txt=Plot.Shapes.AddText(3,17.4, ' +str +')' );
Writeln(script, ' txt.Font.Size=10 ');
Writeln(script, ' txt.Font.Face="Courier New" ');
Writeln(script, ' txt.Font.Bold=true ');
Writeln(script, '');



{...Graph title}
str:='Outliers (mean profile in: ' +extractfilename(fn_MP)+ ')';
str:=AnsiQuotedStr(str,qchar);

{...x1 title}
units_def_name:=units_def_name+'(id='+inttostr(units_def_id)+')';
units_def_name:=AnsiQuotedStr(units_def_name,qchar);

{...create Graph and add outliers plot}
if fileexists(fn_outliers) then begin
Writeln(script, ' Set Graph=Plot.Shapes.AddLinePlotGraph(path_outliers,3,2,"Outliers") ');
Writeln(script, '');

Writeln(script, ' Graph.Title.Text='+str);
Writeln(script, ' Graph.title.xOffset = 0 ');
Writeln(script, ' Graph.title.yOffset = 3.5 ');
Writeln(script, '');
{......item 1: ouliers plot if exists}
plot_count:=plot_count+1;
pc:=inttostr(plot_count);
Writeln(script, '  Set outliers=Graph.Plots.Item('+pc+') ');
Writeln(script, '  outliers.Name="outliers" ');
Writeln(script, '  outliers.Line.style="Invisible" ');
Writeln(script, '  outliers.symbolFreq=1 ');
Writeln(script, '  outliers.symbol.Index = 9 ');
Writeln(script, '  outliers.symbol.size = 0.2 ');
Writeln(script, '  outliers.symbol.Fill.foreColor = grfColorRed ');
Writeln(script, '  outliers.symbol.Line.foreColor = grfColorRed ');
Writeln(script, '');
end;

{...reload worksheet}
Writeln(script, ' Plot.ReloadWorksheets ');
Writeln(script, '');

{...x1 axis settings}
Writeln(script, ' Set XAxis1 =Graph.Axes.Item(1) ');
Writeln(script, ' XAxis1.title.text= '+units_def_name);
Writeln(script, ' XAxis1.length=14 ');
Writeln(script, ' XAxis1.xPos=4 ');
Writeln(script, ' XAxis1.yPos=2 ');
Writeln(script, ' XAxis1.Tickmarks.MajorLength=0.2 ');
Writeln(script, ' XAxis1.Tickmarks.MinorLength=0 ');
Writeln(script, ' XAxis1.title.Font.color=grfColorBlack ');
Writeln(script, ' XAxis1.Tickmarks.MajorSide = grfTicksTopRight ');
Writeln(script, ' XAxis1.TickLabels.MajorSide = grfTicksTopRight ');
Writeln(script, ' XAxis1.title.Side = grfAxisTitleRightTop ');
Writeln(script, ' XAxis1.title.yOffset = 0.2 ');
Writeln(script, '');

{...y1 axis settings}
Writeln(script, ' Set YAxis1 =Graph.Axes.Item(2) ');
Writeln(script, ' Set YAxis1.length=12 ');
Writeln(script, ' YAxis1.xPos=3 '); //position of the graph
Writeln(script, ' YAxis1.yPos=2 ');
Writeln(script, ' YAxis1.AutoMin = False ');
Writeln(script, ' YAxis1.Min = 0 ');
Writeln(script, ' YAxis1.Descending = True ');
Writeln(script, ' YAxis1.title.Font.color=grfColorBlack ');
Writeln(script, ' YAxis1.title.Text="depth (m)" ');
Writeln(script, '');

{...move x1 on top y1}
Writeln(script, ' XAxis1.PositionAxis(grfPositionRightTop, "Y Axis 1") ');
Writeln(script, '');

{...sd factor}
   sd_factor:=SpinEdit1.Value;
   sdL:='sd'+inttostr(sd_factor)+'L';
   sdL:=AnsiQuotedStr(sdL,qchar);
   sdR:='sd'+inttostr(sd_factor)+'R';
   sdR:=AnsiQuotedStr(sdR,qchar);

{......item 2: sdXL }
case sd_factor of
1: Writeln(script, ' Graph.AddLinePlot(path_MP,9,1) ');
2: Writeln(script, ' Graph.AddLinePlot(path_MP,11,1) ');
3: Writeln(script, ' Graph.AddLinePlot(path_MP,13,1) ');
4: Writeln(script, ' Graph.AddLinePlot(path_MP,15,1) ');
5: Writeln(script, ' Graph.AddLinePlot(path_MP,17,1) ');
end;
plot_count:=plot_count+1;
pc:=inttostr(plot_count);
Writeln(script, ' Set sdL=Graph.Plots.Item('+pc+') ');
Writeln(script, ' sdL.Name='+sdL);
Writeln(script, ' sdL.Line.forecolor=grfColorMagenta ');
Writeln(script, ' sdL.line.width="0.1" ');
Writeln(script, '');

{......item 3: sdXR }
case sd_factor of
1: Writeln(script, ' Graph.AddLinePlot(path_MP,10,1) ');
2: Writeln(script, ' Graph.AddLinePlot(path_MP,12,1) ');
3: Writeln(script, ' Graph.AddLinePlot(path_MP,14,1) ');
4: Writeln(script, ' Graph.AddLinePlot(path_MP,16,1) ');
5: Writeln(script, ' Graph.AddLinePlot(path_MP,18,1) ');
end;
plot_count:=plot_count+1;
pc:=inttostr(plot_count);
Writeln(script, ' Set sdR=Graph.Plots.Item('+pc+') ');
Writeln(script, ' sdR.Name='+sdR);
Writeln(script, ' sdR.Line.forecolor=grfColorMagenta ');
Writeln(script, ' sdR.line.width="0.1" ');
Writeln(script, '');

{...add x2 axis to the Graph }
Writeln(script, ' Graph.AddAxis(grfXAxis) ');
Writeln(script, ' Set XAxis2 =Graph.Axes.Item(3) ');
Writeln(script, '  XAxis2.title.Text="samples#" ');
Writeln(script, '  XAxis2.length=5 ');
Writeln(script, '  XAxis2.PositionAxis(grfPositionRightTop, "Y Axis 1") '); //move on top y1
Writeln(script, '  XAxis2.xPos=18 '); //move along x
Writeln(script, '  XAxis2.Tickmarks.MajorSide = grfTicksTopRight ');
Writeln(script, '  XAxis2.TickLabels.MajorSide = grfTicksTopRight ');
Writeln(script, '  XAxis2.title.Side = grfAxisTitleRightTop ');
Writeln(script, '  XAxis2.title.yOffset = 0.2 ');
Writeln(script, '  XAxis2.Tickmarks.MajorLength=0.2 ');
Writeln(script, '  XAxis2.Tickmarks.MinorLength=0 ');
Writeln(script, '');

{......item 4:number of samples profile}
Writeln(script, '  Graph.AddLinePlot(path_MP,6,1,"X Axis 2","Y Axis 1") ');
plot_count:=plot_count+1;
pc:=inttostr(plot_count);
Writeln(script, '  Set sd5R=Graph.Plots.Item('+pc+') ');
Writeln(script, '  sd5R.Name="samples#" ');
Writeln(script, '  sd5R.Line.forecolor=grfColorDeepNavyBlue ');
Writeln(script, '  sd5R.line.width="0.1" ');
Writeln(script, '');

{...item 5: samples if selected and less than 30 000 000 byte }
if CheckBox4.Checked then begin
   file_too_big:=false;
   assignfile(fi_samples,fn_samples);
   reset(fi_samples);
   if filesize(fn_samples)>30000000 then file_too_big:=true;
   closefile(fi_samples);
   if file_too_big=true then begin
   fsize:=filesize(fn_samples)/(1024*1024);
   memo1.Lines.Add(floattostrF(fsize,ffFixed,5,1)+' MB '+'''!!! samples file is too big to be drawn : '+fn_samples);
   str:=floattostrF(fsize,ffFixed,5,1)+' MB '+'!!! samples file is too big to be drawn ';
   str:=AnsiQuotedStr(str,qchar);
   Writeln(script, ' Set Txt=Plot.Shapes.AddText(3,17, ' +str +')' );
   Writeln(script, ' txt.Font.Size=10 ');
   Writeln(script, ' txt.Font.Face="Courier New" ');
   Writeln(script, ' txt.Font.Bold=true ');
   Writeln(script, ' txt.Font.Color = grfColorRed ');
   Writeln(script, '');
   end;

if file_too_big=false then begin
Writeln(script, '  Graph.AddLinePlot(path_samples,2,1,"X Axis 1","Y Axis 1") ');
plot_count:=plot_count+1;
pc:=inttostr(plot_count);
Writeln(script, ' Set samples=Graph.Plots.Item('+pc+') ');
Writeln(script, ' samples.name="samples" ');
Writeln(script, '  samples.Line.style="Invisible" ');
Writeln(script, '  samples.symbolFreq=1 ');
Writeln(script, '  samples.symbol.Index = 12 ');
Writeln(script, '  samples.symbol.size = 0.1 ');
Writeln(script, '  samples.symbol.Fill.foreColor = grfColorBlue ');
Writeln(script, '  samples.symbol.Line.foreColor = grfColorBlue ');
Writeln(script, '');
end;
end;

{...item 6: MP }
Writeln(script, '  Graph.AddLinePlot(path_MP,2,1,"X Axis 1","Y Axis 1") ');
plot_count:=plot_count+1;
pc:=inttostr(plot_count);
Writeln(script, '  Set MP=Graph.Plots.Item('+pc+') ');
Writeln(script, '  MP.Name="MP" ');
Writeln(script, '  MP.Line.forecolor=grfColorRed ');
Writeln(script, '  MP.Line.width="0.1" ');
Writeln(script, '');


{...add legend}
Writeln(script, '  Set Legend=Graph.AddLegend(True) ');
Writeln(script, '  Legend.Left=23 ');
Writeln(script, '  Legend.Top=8 ');
Writeln(script, '  Legend.TitleFont.size=12 ');
Writeln(script, '  Legend.FrameStyle=grfRoundFrame ');
Writeln(script, '  Legend.DisplayShadow=True ');
Writeln(script, '  Legend.ShadowColor=grfColorBlue20 ');
Writeln(script, '  Legend.ShowVisibleOnly=True ');
Writeln(script, '  Legend.LineLength=0.7 ');
Writeln(script, '  Legend.SymbolCount=2 ');
Writeln(script, '');


{...export plot as pdf and png}
if CheckBox2.Checked or CheckBox3.Checked then
Writeln(script, ' Set Plot = Grapher.Documents.Active ');
{Exports file to PDF with same name and location as plot - uses defaults}
if CheckBox2.Checked then
Writeln(script, ' Plot.Export2(Left(path_MP,Len(path_MP)-3) + "pdf",False,"Defaults=0, EmbedFonts=1",True,"pdfv") ');
{Exports file to PNG with same name and location as plot - uses defaults}
if CheckBox3.Checked then
Writeln(script, ' Plot.Export2(Left(path_MP,Len(path_MP)-3) + "png",False,"Defaults=0", True, "png") ');

if single_plot=false then Writeln(script, 'Plot.Close(grfSaveChangesNo)');

Writeln(script, '');
Writeln(script, 'End Sub');
CloseFile(script);

frmosmain.RunScript(3, '-x "'+user_path+'outliers.bas"', nil);
//sleep(1000);

end;


end.

