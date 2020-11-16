unit osexport_comfort;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls;

type

  { TfrmExport_COMFORT }

  TfrmExport_COMFORT = class(TForm)
    btnExport: TBitBtn;
    btnSelectAll: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckGroup1: TCheckGroup;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    procedure btnExportClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure qf_ocean_to_woce(qf_ocean:integer; var qf_woce:integer);

  public

  end;

var
  frmExport_COMFORT: TfrmExport_COMFORT;
  user_path :string;
  fo :text;

implementation

uses osmain, dm, osunitsconversion;

{$R *.lfm}

{ TfrmExport_COMFORT }

procedure TfrmExport_COMFORT.FormShow(Sender: TObject);
begin
  memo1.Clear;
  CheckGroup1.items:=frmosmain.ListBox1.Items;
  memo1.Lines.Add('number of selected cruises='+inttostr(frmdm.QCruise.RecordCount));
  memo1.Lines.Add('number of selected station='+inttostr(frmdm.Q.RecordCount));
end;



procedure TfrmExport_COMFORT.btnSelectAllClick(Sender: TObject);
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


procedure TfrmExport_COMFORT.qf_ocean_to_woce(qf_ocean:integer; var qf_woce:integer);
begin
    {WOCE flags according Table 1 in GLODAP article}
    if qf_ocean =-9999 then qf_woce:=9; //there is no sample -> data not received/not used/sample not drawn/no data
    if qf_ocean =0     then qf_woce:=9; //not checked -> data not received/not used/sample not drawn/no data
    if qf_ocean =1     then qf_woce:=4; //        bad -> bad/not used
    if qf_ocean =2     then qf_woce:=3; // suspitious -> questionable/not used
    if qf_ocean =3     then qf_woce:=0; // calculated -> not used/interpolated or calculated value
    if qf_ocean>=4     then qf_woce:=2; // acceptable -> acceptable
end;



procedure TfrmExport_COMFORT.btnExportClick(Sender: TObject);
var
kt,mik :integer;
station_id :integer;
tbl_count,prf_count,units_count,samples :integer;
lat,lon :real;
tbl,fn,units_name :string;
convert,isconverted :boolean;
DT1,DT2: TDateTime;

{P_tables}
lev_dbar,lev_m,val,val_conv1,val_conv2 :real;
PQF1,PQF2,SQF,WQF :integer;
btl_num,units_id,units_def,instr_id,prf_num :integer;


begin

  DT1:=NOW;
  memo1.Lines.Add('...start: '+datetimetostr(DT1));

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

     tbl:=CheckGroup1.Items.Strings[kt]; {selected table}
     memo1.Lines.Add(tbl);

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

     memo1.Lines.Add(inttostr(units_id)
     +#9+inttostr(units_count)
     +#9+units_name);

     frmdm.q2.Next;
{U}end;
     frmdm.q2.Close;

     if mik=1 then convert:=false else convert:=true;

     fn:=user_path+copy(tbl,3,length(tbl))+'.txt';
     assignfile(fo,fn);
     rewrite(fo);
     if convert=true
     then
     writeln(fo,'id'+#9+'[dbar]'+#9+'[m]'+#9+'val'
     +#9+'PQF1'+#9+'PQF2'+#9+'SQF'+#9+'WOCEQF'
     +#9+'niskin'+#9+'units_id'+#9+'instrument_id'+#9+'prf_num'
     +#9+'units_def'+#9+'val_conv1'+#9+'val_conv2')
     else
     writeln(fo,'id'+#9+'[dbar]'+#9+'[m]'+#9+'val'
     +#9+'PQF1'+#9+'PQF2'+#9+'SQF'+#9+'WOCEQF'
     +#9+'niskin'+#9+'units_id'+#9+'instrument_id'+#9+'prf_num');

     prf_count:=0;
     samples:=0;
     frmdm.Q.First;
{Q}while not frmdm.Q.EOF do begin

    station_id:=frmdm.Q.FieldByName('id').AsInteger;
    lat:=frmdm.Q.FieldByName('latitude').AsFloat;
    lon:=frmdm.Q.FieldByName('longitude').AsFloat;

    prf_count:=prf_count+1;

    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select * from '+tbl);
      SQL.Add(' where id=:id ');
      ParamByName('id').AsInteger:=station_id;
      Open;
    end;


{L}while not frmdm.q1.EOF do begin

     samples:=samples+1;

     WQF:=9;
     val_conv1:=-9999;
     val_conv2:=-9999;

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

     {convert OCEAN QF to WOCE}
     qf_ocean_to_woce(PQF2,WQF);

    {.....units convertion}
{UC}if convert=true then begin
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

     if units_id=units_def then begin val_conv1:=val; val_conv2:=val; end
     else begin
      if CheckBox1.Checked then
       getdefaultunits(tbl,units_id,units_def,val,val_conv1,isconverted);
      if CheckBox2.Checked then
      GetDefaultUnitsExact(tbl,units_id,units_def,station_id,instr_id,prf_num,val,lat,lon,lev_m,val_conv2,isconverted);
     end;

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
     +#9+inttostr(units_def)
     +#9+floattostrF(val_conv1,ffFixed,12,5)
     +#9+floattostrF(val_conv2,ffFixed,12,5));

{UC}end;

    if convert=false then
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
     +#9+inttostr(prf_num));

     frmdm.q1.Next;
{L}end;
     frmdm.q1.Close;

     frmdm.Q.Next;
{Q}end;

     memo1.Lines.Add('uploaded: '
     +#9+inttostr(prf_count)+' profiles'
     +#9+inttostr(samples)+' samples');
     memo1.Lines.Add('');

     closefile(fo);
{C}end; {table is checked }
{T}end; {tables cycle}

  DT2:=NOW;
  memo1.Lines.Add('');
  memo1.Lines.Add('...stop: '+datetimetostr(DT2));
  memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;



end.

