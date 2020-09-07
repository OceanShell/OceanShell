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
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    RadioGroup1: TRadioGroup;
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

  memo1.Clear;

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
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-3);
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
i,ktbl,klt,kln :integer;
unit_tbl,unit_default,val_c,val_nc,val_t :integer;
outliers_count,step,sq_count :integer;
val,val_conv,val_min,val_max :real;
ltn,lts,lnw,lne :real;
tbl,var_name :string;
range_unknown,isconverted,isoutlier :boolean;
DT1,DT2: TDateTime;

{PQF2 update}
id,instr_id,prof_num,PQF2,PQF2_count: integer;
lev_m :real;

{lab density}
//lat,lon,lab_dens :real;

begin

  DT1:=NOW;
  memo1.Lines.Add('...start: '+datetimetostr(DT1));

  case RadioGroup1.ItemIndex of
     0: step:=10;
     1: step:=5;
     2: step:=1;
  end;


{T}for ktbl:=0 to CheckGroup1.Items.Count-1 do begin
{C}if CheckGroup1.Checked[ktbl] then begin

   Edit1.Text:='';
   Edit2.Text:='';
   Edit3.Text:='';
   Edit4.Text:='';
   Edit5.Text:='';
   Edit6.Text:='';
   Edit7.Text:='';

   tbl:=CheckGroup1.Items.Strings[ktbl]; {selected table}
   Edit1.Text:=tbl;
   Application.ProcessMessages;

   {...apply range}
{R}for i:=1 to StringGrid1.RowCount-1 do begin
    var_name:=StringGrid1.Cells[0,i];
{V}if tbl='P_'+var_name then begin

    range_unknown:=false;

    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select count(id) from '+tbl);
      Open;
      Edit2.Text:=inttostr(FieldByName('count').AsInteger);
      Close;
    end;

    if trystrtofloat(StringGrid1.Cells[1,i],val_min) then val_min:=strtofloat(StringGrid1.Cells[1,i]) else range_unknown:=true;
    if trystrtofloat(StringGrid1.Cells[2,i],val_max) then val_max:=strtofloat(StringGrid1.Cells[2,i]) else range_unknown:=true;
    if trystrtoint(StringGrid1.Cells[3,i],unit_default) then unit_default:=strtoint(StringGrid1.Cells[3,i]) else range_unknown:=true;

    if range_unknown=true then begin
     showmessage('Range for selected variable is unknown!');
     Exit;
    end;

{WF}if CheckBox1.Checked = false then begin

   memo1.Lines.Add(tbl+'   ...control run');

   sq_count:=0;
   val_t:=0;    {number of               values in a table}
   val_c:=0;    {number of     converted values}
   val_nc:=0;   {number of not converted values}
   outliers_count:=0;


     {.....squares to reduce selection size}
       klt:=0;
{Lt}repeat
       inc(klt);
       ltn:=90-step*(klt-1);
       lts:=90-step*klt;

       kln:=0;
{Ln}repeat
       inc(kln);
       lnw:=-180+step*(kln-1);
       lne:=-180+step*kln;

       sq_count:=sq_count+1;
       Edit3.Text:=inttostr(sq_count);
       Application.ProcessMessages;

    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select val,units_id from STATION,'+tbl);
      SQL.Add(' where station.id='+tbl+'.id ');
      SQL.Add(' and latitude>:lts and latitude<=:ltn ');
      {...select data from 180 meridian}
      if lne<>180 then SQL.Add(' and longitude>=:lnw and longitude<:lne ')
                  else SQL.Add(' and longitude>=:lnw and longitude<=:lne ');
      ParamByName('ltn').AsFloat:=ltn;
      ParamByName('lts').AsFloat:=lts;
      ParamByName('lnw').AsFloat:=lnw;
      ParamByName('lne').AsFloat:=lne;
      Open;
    end;

{w}while not frmdm.q1.EOF do begin
     //station_id:=frmdm.q1.FieldByName('station_id').AsInteger;
     val:=frmdm.q1.FieldByName('val').AsFloat;
     unit_tbl:=frmdm.q1.FieldByName('units_id').AsInteger;
     //id:=frmdm.q1.FieldByName('id').AsInteger;
     //lev_m:=frmdm.q1.FieldByName('lev_m').AsFloat;
     //instr_id:=frmdm.q1.FieldByName('instrument_id').AsInteger;
     //prof_num:=frmdm.q1.FieldByName('profile_number').AsInteger;

     val_t:=val_t+1;

     if  val_t mod 10000=0 then begin
       Edit4.Text:=inttostr(val_t);
       Application.ProcessMessages;
     end;

     //memo1.Lines.Add(inttostr(val_t)+#9+floattostr(val)+#9+inttostr(unit_tbl));

     isoutlier:=false;
   if unit_tbl=unit_default then begin
       if val<val_min then isoutlier:=true;
       if val>val_max then isoutlier:=true;
   end;

   if isoutlier=true then begin
     outliers_count:=outliers_count+1;
     Edit5.Text:=inttostr(outliers_count);
   end;

   {...conversion}
     isconverted:=false;
     val_conv:=9999;
{c}if unit_tbl<>unit_default then begin

     osunitsconversion.GetDefaultUnits(tbl, unit_tbl, unit_default,
                                       val, val_conv, isconverted);
     {osunitsconversion.GetDefaultUnitsExact(tbl, unit_tbl, unit_default, ID
                                       instr_id, prof_num, val, lat, lon,
                                       Lev_m, val_conv, isconverted);}

    if isconverted=true then begin
      val:=val_conv;
      val_c:=val_c+1;
      Edit6.Text:=inttostr(val_c);
      isoutlier:=false;
      if val<val_min then isoutlier:=true;
      if val>val_max then isoutlier:=true;
      if isoutlier=true then begin
        outliers_count:=outliers_count+1;
        Edit5.Text:=inttostr(outliers_count);
      end;
    end
    else begin
       val_nc:=val_nc+1;
       Edit7.Text:=inttostr(val_nc);
    end;
{c}end;

     frmdm.q1.Next;
{w}end;
     frmdm.q1.Close;


{Ln}until lne=180;
{Lt}until lts=-90;

     Edit4.Text:=inttostr(val_t);

     memo1.Lines.Add(inttostr(i)
     +#9+tbl
     +#9+floattostr(val_min)+'->'
     +#9+floattostr(val_max)
     +#9+'unit_default='+inttostr(unit_default)
     +#9+'outliers='+inttostr(outliers_count)
     +#9+'total/converted/not_converted='+inttostr(val_t)+'/'+inttostr(val_c)+'/'+inttostr(val_nc));

{WF}end; {write false - control without flags writing}


{......update flags in DB}
{WT}if CheckBox1.Checked = true then begin

   memo1.Lines.Add('');
   memo1.Lines.Add(tbl+'   ...flags writing ');

   memo1.Lines.Add(tbl+'   PQF2 statistics: initial');
   with frmdm.q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select PQF2, count(PQF2) from '+tbl);
     SQL.Add(' group by PQF2 ');
     Open;
   end;
   while not frmdm.q3.EOF do begin
     PQF2:=frmdm.q3.FieldByName('PQF2').AsInteger;
     PQF2_count:=frmdm.q3.FieldByName('count').AsInteger;
     memo1.Lines.Add(inttostr(PQF2)+#9+inttostr(PQF2_count));
     frmdm.q3.Next;
   end;
     frmdm.q3.Close;


   sq_count:=0;
   val_t:=0;    {number of               values in a table}
   val_c:=0;    {number of     converted values}
   val_nc:=0;   {number of not converted values}
   outliers_count:=0;


     {.....squares to reduce selection size}
       klt:=0;
{Lt}repeat
       inc(klt);
       ltn:=90-step*(klt-1);
       lts:=90-step*klt;

       kln:=0;
{Ln}repeat
       inc(kln);
       lnw:=-180+step*(kln-1);
       lne:=-180+step*kln;

       sq_count:=sq_count+1;
       Edit3.Text:=inttostr(sq_count);
       Application.ProcessMessages;

    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select STATION.id as id,lev_m,val,units_id,instrument_id,profile_number from STATION,'+tbl);
      SQL.Add(' where station.id='+tbl+'.id ');
      SQL.Add(' and latitude>:lts and latitude<=:ltn ');
      {...select data from 180 meridian}
      if lne<>180 then SQL.Add(' and longitude>=:lnw and longitude<:lne ')
                  else SQL.Add(' and longitude>=:lnw and longitude<=:lne ');
      ParamByName('ltn').AsFloat:=ltn;
      ParamByName('lts').AsFloat:=lts;
      ParamByName('lnw').AsFloat:=lnw;
      ParamByName('lne').AsFloat:=lne;
      Open;
    end;

{w}while not frmdm.q1.EOF do begin
     id:=frmdm.q1.FieldByName('id').AsInteger;
     lev_m:=frmdm.q1.FieldByName('lev_m').AsFloat;
     val:=frmdm.q1.FieldByName('val').AsFloat;
     unit_tbl:=frmdm.q1.FieldByName('units_id').AsInteger;
     instr_id:=frmdm.q1.FieldByName('instrument_id').AsInteger;
     prof_num:=frmdm.q1.FieldByName('profile_number').AsInteger;

     val_t:=val_t+1;

     if  val_t mod 10000=0 then begin
       Edit4.Text:=inttostr(val_t);
       Application.ProcessMessages;
     end;

     //memo1.Lines.Add(inttostr(val_t)+#9+floattostr(val)+#9+inttostr(unit_tbl));

     isoutlier:=false;
   if unit_tbl=unit_default then begin
       if val<val_min then isoutlier:=true;
       if val>val_max then isoutlier:=true;
   end;

{OUT}if isoutlier=true then begin
     outliers_count:=outliers_count+1;
     Edit5.Text:=inttostr(outliers_count);
     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' UPDATE '+tbl+' SET PQF2=:QF WHERE ');
       SQL.Add(' ID=:ID AND LEV_M=:LEV_M AND VAL=:VAL AND ');
       SQL.Add(' INSTRUMENT_ID=:INSTR_ID AND ');
       SQL.Add(' PROFILE_NUMBER=:PROF_NUM ');
       ParamByName('ID').Value:=id;
       ParamByName('QF').Value:=1;
       ParamByName('LEV_M').Value:=lev_m;
       ParamByName('VAL').Value:=val;
       ParamByName('INSTR_ID').Value:=instr_id;
       ParamByName('PROF_NUM').Value:=prof_num;
      ExecSQL;
     end;
{OUT}end;

   {...conversion}
     isconverted:=false;
     val_conv:=9999;
{c}if unit_tbl<>unit_default then begin

     osunitsconversion.GetDefaultUnits(tbl, unit_tbl, unit_default,
                                       val, val_conv, isconverted);
     {osunitsconversion.GetDefaultUnitsExact(tbl, unit_tbl, unit_default, ID
                                       instr_id, prof_num, val, lat, lon,
                                       Lev_m, val_conv, isconverted);}
{conv}if isconverted=true then begin
      //val:=val_conv;
      val_c:=val_c+1;
      Edit6.Text:=inttostr(val_c);
      isoutlier:=false;
      if val_conv<val_min then isoutlier:=true;
      if val_conv>val_max then isoutlier:=true;

{OUT}if isoutlier=true then begin
     outliers_count:=outliers_count+1;
     Edit5.Text:=inttostr(outliers_count);

     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' UPDATE '+tbl+' SET PQF2=:QF WHERE ');
       SQL.Add(' ID=:ID AND LEV_M=:LEV_M AND VAL=:VAL AND ');
       SQL.Add(' INSTRUMENT_ID=:INSTR_ID AND ');
       SQL.Add(' PROFILE_NUMBER=:PROF_NUM ');
       ParamByName('ID').Value:=id;
       ParamByName('QF').Value:=1;
       ParamByName('LEV_M').Value:=lev_m;
       ParamByName('VAL').Value:=val;
       ParamByName('INSTR_ID').Value:=instr_id;
       ParamByName('PROF_NUM').Value:=prof_num;
      ExecSQL;
     end;
{OUT}end;

{conv}end
      else begin
         val_nc:=val_nc+1;
         Edit7.Text:=inttostr(val_nc);
      end;
{c}end;

     frmdm.q1.Next;
{w}end;
     frmdm.q1.Close;


{Ln}until lne=180;
{Lt}until lts=-90;

     frmdm.TR.Commit;

     Edit4.Text:=inttostr(val_t);

     memo1.Lines.Add(inttostr(i)
     +#9+tbl
     +#9+floattostr(val_min)+'->'
     +#9+floattostr(val_max)
     +#9+'unit_default='+inttostr(unit_default)
     +#9+'outliers='+inttostr(outliers_count)
     +#9+'total/converted/not_converted='+inttostr(val_t)+'/'+inttostr(val_c)+'/'+inttostr(val_nc));


     memo1.Lines.Add('');
     memo1.Lines.Add(tbl+'   PQF2 statistics: after flags writing ');
     with frmdm.q3 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select PQF2, count(PQF2) from '+tbl);
       SQL.Add(' group by PQF2 ');
       Open;
     end;
     while not frmdm.q3.EOF do begin
       PQF2:=frmdm.q3.FieldByName('PQF2').AsInteger;
       PQF2_count:=frmdm.q3.FieldByName('count').AsInteger;
       memo1.Lines.Add(inttostr(PQF2)+#9+inttostr(PQF2_count));
       frmdm.q3.Next;
     end;
       frmdm.q3.Close;


     {...change all PQF2=0 to PQF2=4 }
     with frmdm.q3 do begin
      Close;
       SQL.Clear;
       SQL.Add(' UPDATE '+tbl+' SET PQF2=4 WHERE PQF2=0 ');
      ExecSQL;
     end;
       frmdm.TR.Commit;


       memo1.Lines.Add('');
       memo1.Lines.Add(tbl+'   PQF2 statistics: final ');
       with frmdm.q3 do begin
         Close;
         SQL.Clear;
         SQL.Add(' select PQF2, count(PQF2) from '+tbl);
         SQL.Add(' group by PQF2 ');
         Open;
       end;
       while not frmdm.q3.EOF do begin
         PQF2:=frmdm.q3.FieldByName('PQF2').AsInteger;
         PQF2_count:=frmdm.q3.FieldByName('count').AsInteger;
         memo1.Lines.Add(inttostr(PQF2)+#9+inttostr(PQF2_count));
         frmdm.q3.Next;
       end;
         frmdm.q3.Close;




{WT}end; {write true - control without flags writing}


{V}end; {check if variable range is filled}
{R}end; {ranges cycle}


{C}end; {table is checked }
{T}end; {tables cycle}

    DT2:=NOW;
    memo1.Lines.Add('');
    memo1.Lines.Add('...stop: '+datetimetostr(DT2));
    memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;

end.

