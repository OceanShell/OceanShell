unit osqc_wideranges;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  Grids, StdCtrls;

type

  { TfrmQC_WideRanges }

  TfrmQC_WideRanges = class(TForm)
    btnSetFlags: TBitBtn;
    btnSelectAll: TBitBtn;
    CheckBox1: TCheckBox;
    CheckGroup1: TCheckGroup;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    StringGrid1: TStringGrid;
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnSetFlagsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmQC_WideRanges: TfrmQC_WideRanges;

implementation

uses osmain,dm,osunitsconversion;

{$R *.lfm}

{ TfrmQC_WideRanges }



procedure TfrmQC_WideRanges.FormShow(Sender: TObject);
var
ktbl :integer;
tbl,var_name :string;
begin

  CheckGroup1.items:=frmosmain.ListBox1.Items;

  StringGrid1.ColCount:=6;
  StringGrid1.RowCount:=CheckGroup1.Items.Count+1;
  StringGrid1.ColWidths[0]:=200;
  StringGrid1.ColWidths[1]:=50;
  StringGrid1.ColWidths[2]:=50;
  StringGrid1.ColWidths[3]:=50;
  StringGrid1.ColWidths[4]:=100;
  StringGrid1.ColWidths[5]:=200;
  StringGrid1.Cells[0,0]:='variable';
  StringGrid1.Cells[1,0]:='min';
  StringGrid1.Cells[2,0]:='max';
  StringGrid1.Cells[3,0]:='unit_default';
  StringGrid1.Cells[4,0]:='unit_short';
  StringGrid1.Cells[5,0]:='unit_long';

{T}for ktbl:=0 to CheckGroup1.Items.Count-1 do begin
    tbl:=CheckGroup1.Items.Strings[ktbl];
    var_name:=copy(tbl,3,length(tbl));
    StringGrid1.Cells[0,ktbl+1]:=var_name;

    if tbl='P_ALKALINITY' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(404); //WOD18 table 11.9 x1000 milli-mol->micro-mol
      StringGrid1.Cells[2,ktbl+1]:=floattostr(3100);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol·kg-1';
      StringGrid1.Cells[5,ktbl+1]:='micromol per kilogram';
    end;
    if tbl='P_SALINITY' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(40);
      StringGrid1.Cells[3,ktbl+1]:='2';
      StringGrid1.Cells[4,ktbl+1]:='';
      StringGrid1.Cells[5,ktbl+1]:='Dimensionless or unit less';
    end;
    if tbl='P_TEMPERATURE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(40);
      StringGrid1.Cells[3,ktbl+1]:='1';
      StringGrid1.Cells[4,ktbl+1]:='°C';
      StringGrid1.Cells[5,ktbl+1]:='Degree centigrade';
    end;
    if tbl='P_OXYGEN' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(523);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol·kg-1';
      StringGrid1.Cells[5,ktbl+1]:='micromol per kilogram';
    end;
    if tbl='P_PHOSPHATE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(60);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol·kg-1';
      StringGrid1.Cells[5,ktbl+1]:='micromol per kilogram';
    end;
    if tbl='P_SILICATE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(360);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol·kg-1';
      StringGrid1.Cells[5,ktbl+1]:='micromol per kilogram';
    end;
    if tbl='P_NITRATE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(500);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol·kg-1';
      StringGrid1.Cells[5,ktbl+1]:='micromol per kilogram';
    end;
    if tbl='P_NITRATENITRITE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(500);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol·kg-1';
      StringGrid1.Cells[5,ktbl+1]:='micromol per kilogram';
    end;
    if tbl='P_PH' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(6.30);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(9.20);
      StringGrid1.Cells[3,ktbl+1]:='2';
      StringGrid1.Cells[4,ktbl+1]:='';
      StringGrid1.Cells[5,ktbl+1]:='Dimensionless or unit less';
    end;
    if tbl='P_CHLOROPHYLL' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(50);
      StringGrid1.Cells[3,ktbl+1]:='4';
      StringGrid1.Cells[4,ktbl+1]:='μg·l-1';
      StringGrid1.Cells[5,ktbl+1]:='Micro-gram per liter';
    end;

{T}end;

end;



procedure TfrmQC_WideRanges.btnSelectAllClick(Sender: TObject);
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




procedure TfrmQC_WideRanges.btnSetFlagsClick(Sender: TObject);
var
i,ktbl :integer;
unit_tbl,unit_default,val_c,val_nc,val_t :integer;
outliers_count :integer;
val,val_conv,val_min,val_max :real;
tbl,var_name :string;
range_unknown,isconverted,isoutlier :boolean;
DT1,DT2: TDateTime;

{lab density}
id,instr_id,prof_num: integer;
lev_m,lat,lon,lab_dens :real;

begin

  DT1:=NOW;
  memo1.Lines.Add('...start: '+datetimetostr(DT1));


{T}for ktbl:=0 to CheckGroup1.Items.Count-1 do begin
{C}if CheckGroup1.Checked[ktbl] then begin

   tbl:=CheckGroup1.Items.Strings[ktbl]; {selected table}
   val_t:=0;    {number of               values in a table}
   val_c:=0;    {number of     converted values}
   val_nc:=0;   {number of not converted values}
   outliers_count:=0;

   {...apply range}
{R}for i:=1 to StringGrid1.RowCount-1 do begin
    var_name:=StringGrid1.Cells[0,i];
{P}if tbl='P_'+var_name then begin

    memo1.Lines.Add(inttostr(i)+#9+tbl);
    range_unknown:=false;


    if trystrtofloat(StringGrid1.Cells[1,i],val_min) then val_min:=strtofloat(StringGrid1.Cells[1,i]) else range_unknown:=true;
    if trystrtofloat(StringGrid1.Cells[2,i],val_max) then val_max:=strtofloat(StringGrid1.Cells[2,i]) else range_unknown:=true;
    if trystrtoint(StringGrid1.Cells[3,i],unit_default) then unit_default:=strtoint(StringGrid1.Cells[3,i]) else range_unknown:=true;

    if range_unknown=true then begin
     showmessage('Range for selected variable is unknown!');
     Exit;
    end;

{CF}if CheckBox1.Checked = false then begin

    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select * from '+tbl);
      Open;
    end;


{w}while not frmdm.q1.EOF do begin
     id:=frmdm.q1.FieldByName('id').AsInteger;
     lev_m:=frmdm.q1.FieldByName('lev_m').AsFloat;
     val:=frmdm.q1.FieldByName('val').AsFloat;
     unit_tbl:=frmdm.q1.FieldByName('units_id').AsInteger;
     instr_id:=frmdm.q1.FieldByName('instrument_id').AsInteger;
     prof_num:=frmdm.q1.FieldByName('profile_number').AsInteger;

     with frmdm.q2 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select latitude, longitude from STATION ');
       SQL.Add(' where id=:id ');
       ParamByName('id').AsInteger:=id;
       Open;
       Lat:=frmdm.q2.FieldByName('latitude').AsFloat;
       Lon:=frmdm.q2.FieldByName('longitude').AsFloat;
       Close;
     end;

     val_t:=val_t+1;

     if  val_t mod 10000=0 then begin
       Edit1.Text:=inttostr(val_t);
       Application.ProcessMessages;
     end;

     //memo1.Lines.Add(inttostr(val_t)+#9+floattostr(val)+#9+inttostr(unit_tbl));

      {...conversion}
      isconverted:=false;
      val_conv:=-9999;
   if unit_tbl=unit_default then begin val_c:=val_c+1; isconverted:=true; end;
   if unit_tbl<>unit_default then begin

     // default old procedure with dens=1025
     osunitsconversion.GetDefaultUnits(tbl, unit_tbl, unit_default,
                                       val, val_conv, isconverted);

     // new procedure calculating lab density
  (*   osunitsconversion.GetDefaultUnitsExact(tbl, unit_tbl, unit_default, ID
                                       instr_id, prof_num, val, lat, lon,
                                       Lev_m, val_conv, isconverted); *)


       if isconverted=true then begin val:=val_conv; isconverted:=true; end
     else val_nc:=val_nc+1;
   end;

     isoutlier:=false;
   if (isconverted=true) then begin
   if val<val_min then isoutlier:=true;
   if val>val_max then isoutlier:=true;
   end;

   if isoutlier=true then outliers_count:=outliers_count+1;

     frmdm.q1.Next;
{w}end;
     frmdm.q1.Close;

     memo1.Lines.Add(inttostr(i)
     +#9+tbl
     +#9+floattostr(val_min)+'->'
     +#9+floattostr(val_max)
     +#9+'unit_default='+inttostr(unit_default)
     +#9+'outliers='+inttostr(outliers_count)
     +#9+'total/converted/not_converted='+inttostr(val_t)+'/'+inttostr(val_c)+'/'+inttostr(val_nc)
     );


{CF}end;


{P}end;
{R}end;


{C}end;
{T}end;

    DT2:=NOW;
    memo1.Lines.Add('');
    memo1.Lines.Add('...stop: '+datetimetostr(DT2));
    memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;

end.

