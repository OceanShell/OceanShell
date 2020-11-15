unit osstatistics_AK;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls;

type

  { Tfrmosstatistics_AK }

  Tfrmosstatistics_AK = class(TForm)
    btnGetTblStatisticsConverted: TBitBtn;
    btnGetDuplicates: TBitBtn;
    btnSelectAll: TBitBtn;
    btnGetTblStatistics: TBitBtn;
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
    Memo1: TMemo;
    procedure btnGetDuplicatesClick(Sender: TObject);
    procedure btnGetTblStatisticsClick(Sender: TObject);
    procedure btnGetTblStatisticsConvertedClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmosstatistics_AK: Tfrmosstatistics_AK;

implementation

uses osmain,dm, osunitsconversion;

{$R *.lfm}

{ Tfrmosstatistics_AK }



procedure Tfrmosstatistics_AK.FormShow(Sender: TObject);
var
k,mik:integer;
source_id,count_cruise,source_id_min,source_id_max:integer;
stations_count,duplicate_count:integer;
source_name,str:string;
begin

memo1.Clear;
memo1.Lines.Add(IBName);
memo1.Lines.Add('');

CheckGroup1.items:=frmosmain.ListBox1.Items;

   {...two cases: all cruises/not empty cruises}
{2}for k:=1 to 2 do begin

with frmdm.q1 do begin
  Close;
  SQL.Clear;
  SQL.Add(' select source_id, count(source_id) as count_cruise from CRUISE ');
  if k=2 then
  SQL.Add(' where stations_database>0 ');
  SQL.Add(' group by source_id ');
  Open;
end;

with frmdm.q2 do begin
  Close;
  SQL.Clear;
  SQL.Add(' select * from SOURCE ');
  SQL.Add(' where id=:id ');
  Prepare;
end;

  str:='#'+#9+'source'+#9+'source_id'+#9+'id_min'+#9+'id_max'
  +#9+'cruises#'+#9+'stations#'+#9+'duplicates#';

  memo1.Lines.Add(str);

  mik:=0;
while not frmdm.q1.EOF do begin
  mik:=mik+1;
  source_id:=frmdm.q1.FieldByName('source_id').AsInteger;
  count_cruise:=frmdm.q1.FieldByName('count_cruise').AsInteger;

  with frmdm.q2 do begin
    ParamByName('id').AsInteger:=source_id;
    Open;
    source_name:=frmdm.q2.FieldByName('name').AsString;
    source_id_min:=frmdm.q2.FieldByName('station_id_min').AsInteger;
    source_id_max:=frmdm.q2.FieldByName('station_id_max').AsInteger;
    Close;
  end;


  with frmdm.q3 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select count(id) from STATION ');
    SQL.Add(' where id>=:id_min  and id<=:id_max ');
    ParamByName('id_min').AsInteger:=source_id_min;
    ParamByName('id_max').AsInteger:=source_id_max;
    Open;
    stations_count:=frmdm.q3.FieldByName('count').AsInteger;
    Close;
  end;

  with frmdm.q3 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select count(duplicate) from STATION ');
    SQL.Add(' where id>=:id_min  and id<=:id_max ');
    SQL.Add(' and duplicate=true ');
    ParamByName('id_min').AsInteger:=source_id_min;
    ParamByName('id_max').AsInteger:=source_id_max;
    Open;
    duplicate_count:=frmdm.q3.FieldByName('count').AsInteger;
    Close;
  end;


  memo1.Lines.Add(inttostr(mik)
  +#9+source_name
  +#9+inttostr(source_id)
  +#9+inttostr(source_id_min)
  +#9+inttostr(source_id_max)
  +#9+inttostr(count_cruise)
  +#9+inttostr(stations_count)
  +#9+inttostr(duplicate_count)
  );

  frmdm.q1.Next;
end;
  frmdm.q1.Close;
  frmdm.q2.UnPrepare;

{2}end;

end;




procedure Tfrmosstatistics_AK.btnSelectAllClick(Sender: TObject);
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




{statistics by source without units conversion}
procedure Tfrmosstatistics_AK.btnGetTblStatisticsClick(Sender: TObject);
Type
  DataSource=record
    ds_id :integer;
    ds_name :string;
    id_min :integer;
    id_max :integer;
  end;
  DB_DataSource = array of DataSource;

var
DS :DB_DataSource;    //datasets id limits

i,ktbl,kfl,kds :integer;
st_count,samples_count,ds_id,ds_id_min,ds_id_max,units_id :integer;
s,id_min,id_max :integer;
lm_min,lm_max,val_min,val_max,val_avg :real;
tbl,str,str_flags,ds_name,str_units :string;
count_flags:array[0..9] of integer;
var_selected :boolean;
DT1,DT2:TDateTime;
begin


   var_selected:=false;
   for i:=0 to CheckGroup1.Items.Count-1 do
   if CheckGroup1.Checked[i] then var_selected:=true;

   if var_selected=false then begin
     showmessage('Variable not selected');
     Exit;
   end;

   DT1:=NOW;
   memo1.Lines.Add('...start: '+datetimetostr(DT1));
   memo1.Lines.Add('');
   memo1.Lines.Add('PDF2>='+Edit1.Text);
   memo1.lines.Add('statistics by tables');
   str:='#'+#9+'tbl'+#9+'ds'+#9+'ds_id'+#9+'stations#'+#9+'samples#'+#9+'lev_m_min'+#9+'lev_m_max'
   +#9+'units'+#9+'val_min'+#9+'val_max'+#9+'val_avg'+#9+'QC flags';
   memo1.lines.Add(str);

   with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select min(station_id_min), max(station_id_max) from SOURCE ');
     Open;
     id_min:=FieldByName('min').AsInteger;
     id_max:=FieldByName('max').AsInteger;
     Close;
   end;

   s:=1;
   setlength(DS,s);
   DS[s-1].ds_id:=0;
   DS[s-1].ds_name:='All_DSs';
   DS[s-1].id_min:=id_min;
   DS[s-1].id_max:=id_max;

   with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select * from SOURCE ');
     Open;
   end;
{ds}while not frmdm.q1.EOF do begin
   ds_id:=frmdm.q1.FieldByName('id').AsInteger;
   ds_name:=frmdm.q1.FieldByName('name').AsString;
   ds_id_min:=frmdm.q1.FieldByName('station_id_min').AsInteger;
   ds_id_max:=frmdm.q1.FieldByName('station_id_max').AsInteger;

   s:=s+1;
   setlength(DS,s);
   DS[s-1].ds_id:=ds_id;
   DS[s-1].ds_name:=ds_name;
   DS[s-1].id_min:=ds_id_min;
   DS[s-1].id_max:=ds_id_max;

   frmdm.q1.Next;
{ds}end;
   frmdm.q1.Close;


{T}for ktbl:=0 to CheckGroup1.Items.Count-1 do begin
{C}if CheckGroup1.Checked[ktbl] then begin

   tbl:=CheckGroup1.Items.Strings[ktbl];

{ds}for kds:=0 to High(DS) do begin

   ds_id:=DS[kds].ds_id;
   ds_name:=DS[kds].ds_name;
   ds_id_min:=DS[kds].id_min;
   ds_id_max:=DS[kds].id_max;

   with frmdm.q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' Select count(distinct(ID)) as st_count, count(*) as samples_count, ');
    SQL.Add(' min(lev_m) as lm_min, max(lev_m) as lm_max,  ');
    SQL.Add(' min(val) as val_min, max(val) as val_max, avg(val) as val_avg ');
    SQL.Add(' from '+tbl);
    SQL.Add(' where PQF2>=:PQF2 ');
    SQL.Add(' and id>=:ds_id_min and id<=:ds_id_max ');
    ParamByName('PQF2').AsInteger:=strtoint(Edit1.Text);
    ParamByName('ds_id_min').AsInteger:=ds_id_min;
    ParamByName('ds_id_max').AsInteger:=ds_id_max;
    Open;
    st_count:=FieldByName('st_count').AsInteger;
    samples_count:=FieldByName('samples_count').AsInteger;
    lm_min:=FieldByName('lm_min').AsFloat;
    lm_max:=FieldByName('lm_max').AsFloat;
    val_min:=FieldByName('val_min').AsFloat;
    val_max:=FieldByName('val_max').AsFloat;
    val_avg:=FieldByName('val_avg').AsFloat;
    Close;
   end;


   with frmdm.q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' Select distinct(units_id) from '+tbl);
     SQL.Add(' where id>=:ds_id_min and id<=:ds_id_max ');
     ParamByName('ds_id_min').AsInteger:=ds_id_min;
     ParamByName('ds_id_max').AsInteger:=ds_id_max;
     Open;
   end;

      str_units:='';
{uid}while not frmdm.q3.EOF do begin
      units_id:=frmdm.q3.FieldByName('units_id').AsInteger;
      str_units:=str_units+inttostr(units_id)+' ';
      frmdm.q3.Next;
{uid}end;
      frmdm.q3.Close;

     str_flags:='';
{fl}for kfl:=0 to 9 do begin
   with frmdm.q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' Select count(PQF2) as QF_count ');
     SQL.Add(' from '+tbl);
     SQL.Add(' where PQF2= ' + inttostr(kfl));
     SQL.Add(' and id>=:ds_id_min and id<=:ds_id_max ');
     ParamByName('ds_id_min').AsInteger:=ds_id_min;
     ParamByName('ds_id_max').AsInteger:=ds_id_max;
     Open;
     count_flags[kfl]:=frmdm.q3.FieldByName('QF_count').AsInteger;
     Close;
   end;
{fl}end;

   for kfl:=0 to 9 do str_flags:=str_flags+inttostr(count_flags[kfl])+'('+inttostr(kfl)+') ';


   {if length(tbl)<25 then
   for i:=length(tbl) to 25 do tbl:=tbl+'_';}

   if (st_count<>0) then
    memo1.Lines.Add(inttostr(ktbl+1)
    +#9+tbl
    +#9+ds_name
    +#9+inttostr(ds_id)
    +#9+inttostr(st_count)
    +#9+inttostr(samples_count)
    +#9+floattostrF(lm_min,ffFixed,9,1)
    +#9+floattostrF(lm_max,ffFixed,9,1)
    +#9+str_units
    +#9+floattostrF(val_min,ffFixed,9,3)
    +#9+floattostrF(val_max,ffFixed,9,3)
    +#9+floattostrF(val_avg,ffFixed,9,3)
    +#9+str_flags);

    Application.ProcessMessages;

{ds}end;

{C}end;
{T}end;

     DT2:=NOW;
     memo1.Lines.Add('');
     memo1.Lines.Add('...stop: '+datetimetostr(DT2));
     memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;




{duplicates number by source}
procedure Tfrmosstatistics_AK.btnGetDuplicatesClick(Sender: TObject);
Type
  source = record
    id :integer;
    name :string;
    stdup :integer;
    crdup0 :integer;
    crdup1 :integer;
    crdupAll :integer;
  end;
  SourceDuplicate = array of source;

var
SD :SourceDuplicate;

ks :integer;
source_id,source_id_min,source_id_max :integer;
source_count,duplicate_count,dup_amount,number_of_cases :integer;
cruise_dup0,cruise_dup1,cruise_dupAll :integer;
source_name :string;
DT1,DT2 :TDateTime;

begin

    memo1.Clear;

    DT1:=NOW;
    memo1.Lines.Add('...start: '+datetimetostr(DT1));
    memo1.Lines.Add('');


   with frmdm.q1 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select * from SOURCE ');
    Open;
   end;

    source_count:=0;
    setlength(SD,source_count+1);
    SD[source_count].id:=0;
    SD[source_count].name:='';
    SD[source_count].stdup:=0;
    SD[source_count].crdup0:=0;
    SD[source_count].crdup1:=0;
    SD[source_count].crdupAll:=0;

{S}while not frmdm.q1.EOF do begin

    source_id:=frmdm.q1.FieldByName('id').AsInteger;
    source_name:=frmdm.q1.FieldByName('name').AsString;
    source_id_min:=frmdm.q1.FieldByName('station_id_min').AsInteger;
    source_id_max:=frmdm.q1.FieldByName('station_id_max').AsInteger;

    with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select stations_duplicates, count(stations_duplicates) as number_of_cases from CRUISE ');
     SQL.Add(' where id>=:source_id_min and id <=:source_id_max');
     SQL.Add(' group by stations_duplicates ');
     ParamByName('source_id_min').AsInteger:=source_id_min;
     ParamByName('source_id_max').AsInteger:=source_id_max;
     Open;
    end;


{EMPTY}if frmdm.q2.IsEmpty=false then begin

    source_count:=source_count+1;
    duplicate_count:=0;
    cruise_dup0:=0;   {number of cruises without duplicate stations}
    cruise_dup1:=0;   {number of cruises with one station marked as duplicate}
    cruise_dupAll:=0; {number of cruises with any number of stations marked as duplicate}

    memo1.Lines.Add(inttostr(source_count)
    +#9+source_name+'('+inttostr(source_id)+')'
    +#9+inttostr(source_id_min)
    +#9+inttostr(source_id_max))
    ;


{Cr}while not frmdm.q2.EOF do begin
    dup_amount:=frmdm.q2.FieldByName('stations_duplicates').AsInteger;
    number_of_cases:=frmdm.q2.FieldByName('number_of_cases').AsInteger;

    duplicate_count:=duplicate_count+dup_amount;

    if dup_amount=0 then cruise_dup0:=number_of_cases;
    if dup_amount=1 then cruise_dup1:=number_of_cases;
    if dup_amount>=1 then cruise_dupAll:=cruise_dupAll+number_of_cases;

    memo1.Lines.Add('duplicates amount found in a cruise= '+inttostr(dup_amount)
    +#9+'number of cases= '+inttostr(number_of_cases));

   frmdm.q2.Next;
{Cr}end;
   frmdm.q2.Close;

    setlength(SD,source_count+1);
    SD[source_count].id:=source_id;
    SD[source_count].name:=source_name;
    SD[source_count].stdup:=duplicate_count;
    SD[source_count].crdup0:=cruise_dup0;
    SD[source_count].crdup1:=cruise_dup1;
    SD[source_count].crdupAll:=cruise_dupAll;

{EMPTY}end;
    frmdm.q1.Next;
{S}end;
    frmdm.q1.Close;

    memo1.Lines.Add('');
    memo1.Lines.Add('#'+#9+'s_id'+#9+'s_name'+#9+'st_dup'+#9+'cr_dup0'+#9+'cr_dup1'+#9+'cr_dupAll');
    for ks:=1 to High(SD) do
    memo1.Lines.Add(inttostr(ks)
    +#9+inttostr(SD[ks].id)
    +#9+(SD[ks].name)
    +#9+inttostr(SD[ks].stdup)
    +#9+inttostr(SD[ks].crdup0)
    +#9+inttostr(SD[ks].crdup1)
    +#9+inttostr(SD[ks].crdupAll)
    );



    DT2:=NOW;
    memo1.Lines.Add('');
    memo1.Lines.Add('...stop: '+datetimetostr(DT2));
    memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;


procedure Tfrmosstatistics_AK.btnGetTblStatisticsConvertedClick(Sender: TObject
  );
var
i,kt,ks,mik :integer;
units_count,st,sel_size,step,row1,row2,sc :integer;
units_def,station_id :integer;
lat,lon :real;
units_name :string;
tbl,str :string;
var_selected,convert,isconverted :boolean;
DT1,DT2:TDateTime;

{P_tables}
val,cv1,cv2,lev_m :real;
PQF2,units_id,instr_id,prf_num :integer;
//best :boolean;
//lev_dbar,lev_m,val,cv1,cv2 :real;
//PQF1,PQF2,SQF,WQF :integer;
//btl_num,units_id,instr_id,prf_num,prf_best :integer;

{staistics for converted values}
cv1_count,cv2_count,ncv1_count,jv_count :integer;
ncv1_min,ncv1_max,cv1_min,cv2_min,cv1_max,cv2_max,jv_min,jv_max :real;
ncv1_md,cv1_md,cv2_md,jv_md :double;

{sincle unit in table}
st_count,samples_count :integer;
lm_min,lm_max,val_min,val_max,val_avg :real;

begin
   var_selected:=false;
   for i:=0 to CheckGroup1.Items.Count-1 do
   if CheckGroup1.Checked[i] then var_selected:=true;

   if var_selected=false then begin
     showmessage('Variable not selected');
     Exit;
   end;

   DT1:=NOW;
   memo1.Lines.Add('...start: '+datetimetostr(DT1));
   memo1.Lines.Add('');
   memo1.Lines.Add('PDF2>='+Edit1.Text);
   memo1.lines.Add('statistics by tables with units conversion if formula exists ');
   str:='tbl'+#9+'stations#'+#9+'samples#'+#9+'lev_m_min'+#9+'lev_m_max'
   +#9+'val_min'+#9+'val_max'+#9+'val_avg';

{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{C}if CheckGroup1.Checked[kt] then begin

   tbl:=CheckGroup1.Items.Strings[kt];
   GroupBox1.Caption:=tbl;
   Edit2.Text:='';
   Edit3.Text:='';

   memo1.Lines.Add('');
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


      {.....units convertion - need to read all records}
{C=T}if convert=true then begin
   {.....samples number in table}
  with frmdm.q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select count(id) as samples_count from '+tbl);
    Open;
    st:=FieldByName('samples_count').AsInteger;
    Edit2.Text:=inttostr(st);
    memo1.Lines.Add('Total samples in table '+inttostr(st));
    Close;
  end;
    Application.ProcessMessages;

    sel_size:=5000000;
    if st>sel_size then step:=trunc(st/sel_size) else step:=1;
    memo1.Lines.Add('Query divided on '+inttostr(step)+' steps');

    sc:=0;
    {converted statistics ICES}
    cv1_count:=0;
    cv1_min:=9999;
    cv1_max:=-9999;
    cv1_md:=0;
    {converted statistics ADVANCED}
    cv2_count:=0;
    cv2_min:=9999;
    cv2_max:=-9999;
    cv2_md:=0;
    {not converted}
    ncv1_count:=0;
    ncv1_min:=9999;
    ncv1_max:=-9999;
    ncv1_md:=0;
    {joint}
    jv_count:=0;
    jv_min:=9999;
    jv_max:=-9999;
    jv_md:=0;

{STEP}for ks:=1 to step do begin
      row1:=1+sel_size*(ks-1);
      row2:=sel_size*ks;
      if ks=step then row2:=st;
      memo1.Lines.Add('step='+inttostr(ks)+'  '+inttostr(row1)+'->'+inttostr(row2));

      with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' select id,lev_m,val,PQF2,units_id,instrument_id,profile_number from '+tbl);
        SQL.Add(' rows :row1 to :row2 ');
        ParamByName('row1').AsInteger:=row1;
        ParamByName('row2').AsInteger:=row2;
        Open;
      end;

    frmdm.q1.First;
{S}while not frmdm.q1.EOF do begin

   sc:=sc+1;  //samples count

   cv1:=-9999;
   cv2:=-9999;

   if sc mod 1000=0 then begin
     Edit3.Text:=inttostr(sc);
     Application.ProcessMessages;
   end;

   if (st<1000000) and (sc mod 10=0) then begin
     Edit3.Text:=inttostr(sc);
     Application.ProcessMessages;
   end;

   //Edit3.Text:=inttostr(sc);
   //Application.ProcessMessages;

   station_id:=frmdm.q1.FieldByName('id').AsInteger;
   //lev_dbar:=frmdm.q1.FieldByName('lev_dbar').AsFloat;
   lev_m:=frmdm.q1.FieldByName('lev_m').AsFloat;
   val:=frmdm.q1.FieldByName('val').AsFloat;
   //PQF1:=frmdm.q1.FieldByName('PQF1').AsInteger;
   PQF2:=frmdm.q1.FieldByName('PQF2').AsInteger;
   //SQF:=frmdm.q1.FieldByName('SQF').AsInteger;
   //btl_num:=frmdm.q1.FieldByName('bottle_number').AsInteger;
   units_id:=frmdm.q1.FieldByName('units_id').AsInteger;
   instr_id:=frmdm.q1.FieldByName('instrument_id').AsInteger;
   prf_num:=frmdm.q1.FieldByName('profile_number').AsInteger;
   //best:=frmdm.q1.FieldByName('profile_best').AsBoolean;
   //if best=true then prf_best:=1 else prf_best:=0;

{PQF2}if PQF2>=strtoint(Edit1.Text) then begin

   if units_id=units_def then begin
     {statistics for not converted values}
       ncv1_count:=ncv1_count+1; //convereted value 1 count
       ncv1_md:=ncv1_md+val;
       if ncv1_min>val then ncv1_min:=val;
       if ncv1_max<val then ncv1_max:=val;

     {joint statistics for converted and not converted values}
       jv_count:=jv_count+1; //convereted value 1 count
       jv_md:=jv_md+val;
       if jv_min>val then jv_min:=val;
       if jv_max<val then jv_max:=val;
   end
{CONVERSION}else begin

{ICES}if CheckBox1.Checked then begin
     isconverted:=false;
     getdefaultunits(tbl,units_id,units_def,val,cv1,isconverted);
     {statistics for converted values}
{isconv}if isconverted=true then begin
       cv1_count:=cv1_count+1;
       cv1_md:=cv1_md+cv1;
       if cv1_min>cv1 then cv1_min:=cv1;
       if cv1_max<cv1 then cv1_max:=cv1;

       {joint statistics for converted and not converted values}
       jv_count:=jv_count+1;
       jv_md:=jv_md+cv1;
       if jv_min>cv1 then jv_min:=cv1;
       if jv_max<cv1 then jv_max:=cv1;
{isconv}end;
{ICES}end;

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

     isconverted:=false;
     GetDefaultUnitsExact(tbl,units_id,units_def,station_id,instr_id,prf_num,val,lat,lon,lev_m,cv2,isconverted);

{isconv}if isconverted=true then begin
       cv2_count:=cv2_count+1;
       cv2_md:=cv2_md+cv2;
       if cv2_min>cv2 then cv2_min:=cv2;
       if cv2_max<cv2 then cv2_max:=cv2;
{isconv}end;

{advanced}end;

{CONVERSION}end;

{PQF2}end;

      frmdm.q1.Next;
{S}end;
   Edit3.Text:=inttostr(sc);
{STEP}end;

  if ncv1_count<>0 then ncv1_md:=ncv1_md/ncv1_count;
  if cv1_count<>0  then cv1_md:=cv1_md/cv1_count;
  if cv2_count<>0  then cv2_md:=cv2_md/cv2_count;
  if jv_count<>0   then jv_md:=jv_md/jv_count;

  memo1.Lines.Add('');
  if CheckBox2.Checked then
  memo1.Lines.Add('...ICES statistics not converted/ converted/ joint values/ advances')
  else
  memo1.Lines.Add('...ICES statistics not converted/ converted/ joint values');
  memo1.Lines.Add('Joint statistics includes only values after simple ICES conversion !!!');
  memo1.Lines.Add('count'+#9+'md'+#9+'min'+#9+'max');
  memo1.Lines.Add(inttostr(ncv1_count)
  +#9+floattostrF(ncv1_md,ffFixed,12,3)
  +#9+floattostrF(ncv1_min,ffFixed,12,3)
  +#9+floattostrF(ncv1_max,ffFixed,12,3));
  memo1.Lines.Add(inttostr(cv1_count)
  +#9+floattostrF(cv1_md,ffFixed,12,3)
  +#9+floattostrF(cv1_min,ffFixed,12,3)
  +#9+floattostrF(cv1_max,ffFixed,12,3));
  memo1.Lines.Add(inttostr(jv_count)
  +#9+floattostrF(jv_md,ffFixed,12,3)
  +#9+floattostrF(jv_min,ffFixed,12,3)
  +#9+floattostrF(jv_max,ffFixed,12,3));
  if CheckBox2.Checked then
   memo1.Lines.Add(inttostr(cv2_count)
   +#9+floattostrF(cv2_md,ffFixed,12,3)
   +#9+floattostrF(cv2_min,ffFixed,12,3)
   +#9+floattostrF(cv2_max,ffFixed,12,3));
{C=T}end;


{.....without units conversion - only query }
{C=F}if convert=false then begin
  with frmdm.q2 do begin
   Close;
   SQL.Clear;
   SQL.Add(' Select count(distinct(ID)) as st_count, count(*) as samples_count, ');
   SQL.Add(' min(lev_m) as lm_min, max(lev_m) as lm_max,  ');
   SQL.Add(' min(val) as val_min, max(val) as val_max, avg(val) as val_avg ');
   SQL.Add(' from '+tbl);
   SQL.Add(' where PQF2>=:PQF2 ');
   ParamByName('PQF2').AsInteger:=strtoint(Edit1.Text);
   Open;
   st_count:=FieldByName('st_count').AsInteger;
   samples_count:=FieldByName('samples_count').AsInteger;
   lm_min:=FieldByName('lm_min').AsFloat;
   lm_max:=FieldByName('lm_max').AsFloat;
   val_min:=FieldByName('val_min').AsFloat;
   val_max:=FieldByName('val_max').AsFloat;
   val_avg:=FieldByName('val_avg').AsFloat;
   Close;
  end;

  memo1.Lines.Add('Statistics for single unit in table ');
  memo1.lines.Add(str);

  if (st_count<>0) then
   memo1.Lines.Add(tbl
   +#9+inttostr(st_count)
   +#9+inttostr(samples_count)
   +#9+floattostrF(lm_min,ffFixed,9,1)
   +#9+floattostrF(lm_max,ffFixed,9,1)
   +#9+floattostrF(val_min,ffFixed,9,3)
   +#9+floattostrF(val_max,ffFixed,9,3)
   +#9+floattostrF(val_avg,ffFixed,9,3));

   Application.ProcessMessages;

{C=F}end;


{C}end;
{T}end;

     GroupBox1.Caption:='';
     DT2:=NOW;
     memo1.Lines.Add('');
     memo1.Lines.Add('...stop: '+datetimetostr(DT2));
     memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;





end.

