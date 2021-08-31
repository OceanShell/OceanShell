unit osexport_comfort_table;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons;

type

  { TfrmExport_COMFORT_table }

  TfrmExport_COMFORT_table = class(TForm)
    btnExport: TBitBtn;
    btnSelectAll: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckGroup1: TCheckGroup;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    procedure btnExportClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure qf_ocean_to_woce(qf_ocean:integer; var qf_woce:integer);

  public

  end;

var
  frmExport_COMFORT_table: TfrmExport_COMFORT_table;
  user_path :string;
  fo :text;

implementation

uses osmain, dm, osunitsconversion, osunitsconversion_exact;

{$R *.lfm}

{ TfrmExport_COMFORT_table }

procedure TfrmExport_COMFORT_table.FormShow(Sender: TObject);
begin
  memo1.Clear;
  CheckGroup1.items:=frmosmain.ListBox1.Items;
end;



procedure TfrmExport_COMFORT_table.btnSelectAllClick(Sender: TObject);
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


procedure TfrmExport_COMFORT_table.qf_ocean_to_woce(qf_ocean:integer; var qf_woce:integer);
begin
    {WOCE flags according Table 1 in GLODAP article}
    if qf_ocean =-9999 then qf_woce:=9; //there is no sample -> data not received/not used/sample not drawn/no data
    if qf_ocean =0     then qf_woce:=9; //not checked -> data not received/not used/sample not drawn/no data
    if qf_ocean =1     then qf_woce:=4; //        bad -> bad/not used
    if qf_ocean =2     then qf_woce:=3; // suspitious -> questionable/not used
    if qf_ocean =3     then qf_woce:=0; // calculated -> not used/interpolated or calculated value
    if qf_ocean>=4     then qf_woce:=2; // acceptable -> acceptable
end;



procedure TfrmExport_COMFORT_table.btnExportClick(Sender: TObject);
var
kt,ks,mik: integer;
tbl_count,units_count,samples_count,samples_total,conv1_count,conv2_count :integer;
units_def,station_id :integer;
step,row1,row2,sel_size :integer;
lat,lon,conv1_min,conv1_max,conv2_min,conv2_max :real;
conv1_md,conv2_md :double;
tbl,fn,units_name,fstr :string;
convert,isconverted,best :boolean;
DT1,DT2: TDateTime;

{P_tables}
lev_dbar,lev_m,val,valerr,val_conv1,val_conv2 :real;
PQF1,PQF2,SQF,WQF :integer;
btl_num,units_id,instr_id,prf_num,prf_best :integer;

begin
  DT1:=NOW;
  memo1.Lines.Add('...start [export]: '+datetimetostr(DT1));


  tbl_count:=0;
{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{TC}if CheckGroup1.Checked[kt] then begin
  tbl_count:=tbl_count+1;
{TC}end;
{T} end;
if tbl_count=0 then begin
   showmessage('Variable does not selected!');
   Exit;
end;

user_path:=GlobalUnloadPath+PathDelim+'export_comfort'+PathDelim;
if directoryexists(user_path)=false then mkdir(user_path);

{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{C}if CheckGroup1.Checked[kt] then begin

   Edit1.Text:='';
   Edit2.Text:='';

   tbl:=CheckGroup1.Items.Strings[kt]; {selected table}
   memo1.Lines.Add(tbl);

   {...default unit values to be converted}
   with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select * from DATABASE_TABLES ');
     SQL.Add(' where name_table=:nt ');
     ParamByName('nt').AsString:=tbl;
     Open;
     units_def:=FieldByName('units_id_default').AsInteger;
     Close;
   end;

   with frmdm.q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select name_short as ns from UNITS ');
     SQL.Add(' where id=:units_id ');
     ParamByName('units_id').AsInteger:=units_def;
     Open;
     units_name:=frmdm.q3.FieldByName('ns').AsString;
     Close;
   end;

   memo1.Lines.Add('default unit: '+inttostr(units_def)+' ('+units_name+')');

   {...units statistics in the table}
   memo1.Lines.Add('{...number of samples by unit}');

   with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select units_id, count(units_id) from '+tbl);
     SQL.Add(' group by units_id ');
     Open;
   end;

   mik:=0;
{U}while not frmdm.q2.EOF do begin
   mik:=mik+1;
   units_id:=frmdm.q2.FieldByName('units_id').AsInteger;
   units_count:=frmdm.q2.FieldByName('count').AsInteger;

   with frmdm.q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select name_short as ns from UNITS ');
     SQL.Add(' where id=:units_id ');
     ParamByName('units_id').AsInteger:=units_id;
     Open;
     units_name:=frmdm.q3.FieldByName('ns').AsString;
     Close;
   end;

   memo1.Lines.Add(inttostr(units_id)+' ('+units_name+'): '+#9+inttostr(units_count));

   frmdm.q2.Next;
{U}end;
   frmdm.q2.Close;

   if mik=1 then convert:=false else convert:=true;
   if convert=false then memo1.Lines.Add('Units conversion is not required');

   fn:=user_path+copy(tbl,3,length(tbl))+'.txt';
   assignfile(fo,fn);
   rewrite(fo);
   if convert=true then
   fstr:='id'+#9+'[dbar]'+#9+'[m]'+#9+'val'
   +#9+'PQF1'+#9+'PQF2'+#9+'SQF'+#9+'WOCEQF'
   +#9+'niskin'+#9+'units_id'+#9+'instrument_id'+#9+'prf_num'+#9+'prf_best'
   +#9+'units_def'+#9+'val_conv1'+#9+'val_conv2';
   if convert=false then
   fstr:='id'+#9+'[dbar]'+#9+'[m]'+#9+'val'
   +#9+'PQF1'+#9+'PQF2'+#9+'SQF'+#9+'WOCEQF'
   +#9+'niskin'+#9+'units_id'+#9+'instrument_id'+#9+'prf_num'+#9+'prf_best';
   {...four tables include additional column}
   if (tbl='P_HE') or (tbl='P_C14') or (tbl='P_HE3') or (tbl='P_NEON') then
   fstr:='id'+#9+'[dbar]'+#9+'[m]'+#9+'val'+#9+'count_err'
   +#9+'PQF1'+#9+'PQF2'+#9+'SQF'+#9+'WOCEQF'
   +#9+'niskin'+#9+'units_id'+#9+'instrument_id'+#9+'prf_num'+#9+'prf_best';

   writeln(fo,fstr);

   {.....total number samples in table}
   with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select count(id) as samples_count from '+tbl);
     Open;
     samples_total:=FieldByName('samples_count').AsInteger;
     Edit1.Text:=inttostr(samples_total);
     Close;
   end;
   Application.ProcessMessages;

       sel_size:=5000000;
       if samples_total>sel_size then step:=trunc(samples_total/sel_size) else step:=1;
       memo1.Lines.Add('Query divided on '+inttostr(step)+' steps');
       samples_count:=0;
       conv1_count:=0;
       conv2_count:=0;
       conv1_min:=9999;
       conv1_max:=-9999;
       conv1_md:=0;
       conv2_min:=9999;
       conv2_max:=-9999;
       conv2_md:=0;

{STEP}for ks:=1 to step do begin
       row1:=1+sel_size*(ks-1);
       row2:=sel_size*ks;
       if ks=step then row2:=samples_total;
       memo1.Lines.Add('step='+inttostr(ks)+'  '+inttostr(row1)+'->'+inttostr(row2));

   with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select * from '+tbl);
     SQL.Add(' rows :row1 to :row2 ');
     ParamByName('row1').AsInteger:=row1;
     ParamByName('row2').AsInteger:=row2;
     Open;
   end;

   {.....units convertion}
{UC}if convert=true then begin
{S}while not frmdm.q1.EOF do begin

   samples_count:=samples_count+1;

   if samples_count mod 1000=0 then begin
     Edit2.Text:=inttostr(samples_count);
     Application.ProcessMessages;
   end;

   WQF:=9;
   val_conv1:=-9999;
   val_conv2:=-9999;

   station_id:=frmdm.q1.FieldByName('id').AsInteger;
   lev_dbar:=frmdm.q1.FieldByName('lev_dbar').AsFloat;
   lev_m:=frmdm.q1.FieldByName('lev_m').AsFloat;
   val:=frmdm.q1.FieldByName('val').AsFloat;
   PQF1:=frmdm.q1.FieldByName('PQF1').AsInteger;
   PQF2:=frmdm.q1.FieldByName('PQF2').AsInteger;
   SQF:=frmdm.q1.FieldByName('SQF').AsInteger;
   btl_num:=frmdm.q1.FieldByName('bottle_number').AsInteger;
   units_id:=frmdm.q1.FieldByName('units_id').AsInteger;
   instr_id:=frmdm.q1.FieldByName('instrument_id').AsInteger;
   prf_num:=frmdm.q1.FieldByName('profile_number').AsInteger;
   best:=frmdm.q1.FieldByName('profile_best').AsBoolean;

   if (tbl='P_HE') or (tbl='P_C14') or (tbl='P_HE3') or (tbl='P_NEON') then
   valerr:=frmdm.q1.FieldByName('valerr').AsFloat;

   if best=true then prf_best:=1 else prf_best:=0;

   {convert OCEAN QF to WOCE}
   qf_ocean_to_woce(PQF2,WQF);

   if units_id=units_def then begin val_conv1:=val; val_conv2:=val; end
{CONVERSION}else begin

     isconverted:=false;
{ICES}if CheckBox1.Checked then
     getdefaultunits(tbl,units_id,units_def,val,val_conv1,isconverted);

{advanced}if CheckBox2.Checked then begin
   with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select latitude, longitude from STATION ');
     SQL.Add(' where id=:station_id ');
     Open;
     lat:=frmdm.q2.FieldByName('latitude').AsFloat;
     lon:=frmdm.q2.FieldByName('longitude').AsFloat;
     Close;
   end;
     GetDefaultUnitsExact(tbl,units_id,units_def,station_id,instr_id,prf_num,val,lat,lon,lev_m,val_conv2,isconverted);
{advanced}end;

{CONVERSION}end;

   if (tbl='P_HE') or (tbl='P_C14') or (tbl='P_HE3') or (tbl='P_NEON') then
   writeln(fo,inttostr(station_id)
  +#9+floattostrF(lev_dbar,ffFixed,9,1)
  +#9+floattostrF(lev_m,ffFixed,9,1)
  +#9+floattostr(val)
  +#9+floattostr(valerr)
  +#9+inttostr(PQF1)
  +#9+inttostr(PQF2)
  +#9+inttostr(SQF)
  +#9+inttostr(WQF)
  +#9+inttostr(btl_num)
  +#9+inttostr(units_id)
  +#9+inttostr(instr_id)
  +#9+inttostr(prf_num)
  +#9+inttostr(prf_best)
  +#9+inttostr(units_def)
  +#9+floattostrF(val_conv1,ffFixed,12,5)
  +#9+floattostrF(val_conv2,ffFixed,12,5))
  else
    writeln(fo,inttostr(station_id)
   +#9+floattostrF(lev_dbar,ffFixed,9,1)
   +#9+floattostrF(lev_m,ffFixed,9,1)
   +#9+floattostr(val)
   +#9+inttostr(PQF1)
   +#9+inttostr(PQF2)
   +#9+inttostr(SQF)
   +#9+inttostr(WQF)
   +#9+inttostr(btl_num)
   +#9+inttostr(units_id)
   +#9+inttostr(instr_id)
   +#9+inttostr(prf_num)
   +#9+inttostr(prf_best)
   +#9+inttostr(units_def)
   +#9+floattostrF(val_conv1,ffFixed,12,5)
   +#9+floattostrF(val_conv2,ffFixed,12,5));


{PQF2}if PQF2>=strtoint(Edit3.Text) then begin
  if val_conv1<>-9999 then begin
    conv1_count:=conv1_count+1;
    conv1_md:=conv1_md+val_conv1;
    if conv1_min>val_conv1 then conv1_min:=val_conv1;
    if conv1_max<val_conv1 then conv1_max:=val_conv1;
  end;
  if val_conv2<>-9999 then begin
    conv2_count:=conv2_count+1;
    conv2_md:=conv2_md+val_conv2;
    if conv2_min>val_conv2 then conv2_min:=val_conv2;
    if conv2_max<val_conv2 then conv2_max:=val_conv2;
  end;
{PQF2}end;

   frmdm.q1.Next;
{S}end;
   Edit2.Text:=inttostr(samples_count);
{UC}end;


{.....no units convertion}
{UC}if convert=false then begin
{S}while not frmdm.q1.EOF do begin

    samples_count:=samples_count+1;
  if samples_count mod 1000=0 then begin
    Edit2.Text:=inttostr(samples_count);
    Application.ProcessMessages;
  end;

  WQF:=9;

  station_id:=frmdm.q1.FieldByName('id').AsInteger;
  lev_dbar:=frmdm.q1.FieldByName('lev_dbar').AsFloat;
  lev_m:=frmdm.q1.FieldByName('lev_m').AsFloat;
  val:=frmdm.q1.FieldByName('val').AsFloat;
  PQF1:=frmdm.q1.FieldByName('PQF1').AsInteger;
  PQF2:=frmdm.q1.FieldByName('PQF2').AsInteger;
  SQF:=frmdm.q1.FieldByName('SQF').AsInteger;
  btl_num:=frmdm.q1.FieldByName('bottle_number').AsInteger;
  units_id:=frmdm.q1.FieldByName('units_id').AsInteger;
  instr_id:=frmdm.q1.FieldByName('instrument_id').AsInteger;
  prf_num:=frmdm.q1.FieldByName('profile_number').AsInteger;
  best:=frmdm.q1.FieldByName('profile_best').AsBoolean;

  if best=true then prf_best:=1 else prf_best:=0;

  if (tbl='P_HE') or (tbl='P_C14') or (tbl='P_HE3') or (tbl='P_NEON') then
  valerr:=frmdm.q1.FieldByName('valerr').AsFloat;

{convert OCEAN QF to WOCE}
  qf_ocean_to_woce(PQF2,WQF);

  if (tbl='P_HE') or (tbl='P_C14') or (tbl='P_HE3') or (tbl='P_NEON') then
  writeln(fo,inttostr(station_id)
  +#9+floattostrF(lev_dbar,ffFixed,9,1)
  +#9+floattostrF(lev_m,ffFixed,9,1)
  +#9+floattostr(val)
  +#9+floattostr(valerr)
  +#9+inttostr(PQF1)
  +#9+inttostr(PQF2)
  +#9+inttostr(SQF)
  +#9+inttostr(WQF)
  +#9+inttostr(btl_num)
  +#9+inttostr(units_id)
  +#9+inttostr(instr_id)
  +#9+inttostr(prf_num)
  +#9+inttostr(prf_best))
  else
    writeln(fo,inttostr(station_id)
    +#9+floattostrF(lev_dbar,ffFixed,9,1)
    +#9+floattostrF(lev_m,ffFixed,9,1)
    +#9+floattostr(val)
    +#9+inttostr(PQF1)
    +#9+inttostr(PQF2)
    +#9+inttostr(SQF)
    +#9+inttostr(WQF)
    +#9+inttostr(btl_num)
    +#9+inttostr(units_id)
    +#9+inttostr(instr_id)
    +#9+inttostr(prf_num)
    +#9+inttostr(prf_best));

  frmdm.q1.Next;
{S}end;
  Edit2.Text:=inttostr(samples_count);
{UC}end;

  frmdm.q1.Close;
{STEP}end;

  {statistics for converted values}
{s}if convert=true then begin

  if conv1_count<>0 then conv1_md:=conv1_md/conv1_count;
  if conv2_count<>0 then conv2_md:=conv2_md/conv2_count;

  memo1.Lines.Add('');
  memo1.Lines.Add('statistics computed for values with PQF2>=3');
  memo1.Lines.Add('statistics: '+#9+'count'+#9+'md'+#9+'min'+#9+'max');
  memo1.Lines.Add('val_conv1 : '
  +#9+inttostr(conv1_count)
  +#9+floattostrF(conv1_md,ffFixed,12,3)
  +#9+floattostrF(conv1_min,ffFixed,12,3)
  +#9+floattostrF(conv1_max,ffFixed,12,3));
  memo1.Lines.Add('val_conv2 : '
  +#9+inttostr(conv2_count)
  +#9+floattostrF(conv2_md,ffFixed,12,3)
  +#9+floattostrF(conv2_min,ffFixed,12,3)
  +#9+floattostrF(conv2_max,ffFixed,12,3));
{s}end;

  closefile(fo);
{C}end; {table is checked }
{T}end; {tables cycle}

  DT2:=NOW;
  memo1.Lines.Add('');
  memo1.Lines.Add('...stop: '+datetimetostr(DT2));
  memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;

end.

