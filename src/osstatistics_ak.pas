unit osstatistics_AK;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons;

type

  { Tfrmosstatistics_AK }

  Tfrmosstatistics_AK = class(TForm)
    btnGetTblStatistics: TBitBtn;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Memo1: TMemo;
    procedure btnGetTblStatisticsClick(Sender: TObject);
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
i,mik:integer;
source_id,count_cruise,source_id_min,source_id_max:integer;
stations_count,duplicate_count:integer;
source_name,str:string;
begin

memo1.Clear;
memo1.Lines.Add(IBName);
memo1.Lines.Add('');

frmdm.IBDB.GetTableNames(ListBox1.Items,False);
for i:=0 to ListBox1.Items.Count-1 do
if (copy(ListBox1.items.strings[i],1,2)='P_')
then ListBox2.Items.Add(ListBox1.items.strings[i]);



with frmdm.q1 do begin
  Close;
  SQL.Clear;
  SQL.Add(' select source_id, count(source_id) as count_cruise from CRUISE ');
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
    SQL.Add(' select count(*) from STATION ');
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


end;




procedure Tfrmosstatistics_AK.btnGetTblStatisticsClick(Sender: TObject);
var
ktbl,kfl:integer;
st_count,samples_count:integer;
lm_min,lm_max,val_min,val_max,val_avg:real;
tbl,str,str_flags:string;
count_flags:array[0..9] of integer;
begin

   memo1.lines.Add(datetimetostr(NOW));
   memo1.lines.Add('statistics by tables');

   str:='#'+#9+'tbl'+#9+'stations#'+#9+'samples#'+#9+'lev_m_min'+#9+'lev_m_max'+#9+'val_min'
           +#9+'val_max'+#9+'val_avg'+#9+'QC flags';
   memo1.lines.Add(str);



{tbl}for ktbl:=0 to ListBox2.Items.Count-1 do begin

   str_flags:='';
   tbl:=ListBox2.items.strings[ktbl];

   with frmdm.q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' Select count(distinct(ID)) as st_count, count(*) as samples_count, ');
    SQL.Add(' min(lev_m) as lm_min, max(lev_m) as lm_max,  ');
    SQL.Add(' min(val) as val_min, max(val) as val_max, avg(val) as val_avg ');
    SQL.Add(' from '+tbl);
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

{fl}for kfl:=0 to 9 do begin
   with frmdm.q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' Select count(PQF2) as QF_count ');
     SQL.Add(' from '+tbl);
     SQL.Add(' where PQF2= ' + inttostr(kfl));
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
    +#9+tbl+':'
    +#9+inttostr(st_count)
    +#9+inttostr(samples_count)
    +#9+floattostrF(lm_min,ffFixed,9,1)
    +#9+floattostrF(lm_max,ffFixed,9,1)
    +#9+floattostrF(val_min,ffFixed,9,3)
    +#9+floattostrF(val_max,ffFixed,9,3)
    +#9+floattostrF(val_avg,ffFixed,9,3)
    +#9+str_flags);

   Application.ProcessMessages;

{tbl}end;

     memo1.lines.Add('...done');
     memo1.lines.Add(datetimetostr(NOW));
end;



end.

