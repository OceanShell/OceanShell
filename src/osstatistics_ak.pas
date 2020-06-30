unit osstatistics_AK;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { Tfrmosstatistics_AK }

  Tfrmosstatistics_AK = class(TForm)
    Memo1: TMemo;
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
mik:integer;
source_id,count_cruise,source_id_min,source_id_max:integer;
stations_count,duplicate_count:integer;
source_name,str:string;
begin

memo1.Clear;
memo1.Lines.Add(IBName);
memo1.Lines.Add('');

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

end.

