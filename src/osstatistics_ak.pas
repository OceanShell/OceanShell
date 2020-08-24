unit osstatistics_AK;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls;

type

  { Tfrmosstatistics_AK }

  Tfrmosstatistics_AK = class(TForm)
    btnGetDuplicates: TBitBtn;
    btnSelectAll: TBitBtn;
    btnGetTblStatistics: TBitBtn;
    CheckGroup1: TCheckGroup;
    Edit1: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    procedure btnGetDuplicatesClick(Sender: TObject);
    procedure btnGetTblStatisticsClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmosstatistics_AK: Tfrmosstatistics_AK;

implementation

uses osmain,dm;

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
DS :DB_DataSource;

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



end.

