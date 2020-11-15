unit osviz_grapher_histogram;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons;

type

  { Tfrmviz_grapfer_histogram }

  Tfrmviz_grapfer_histogram = class(TForm)
    btnSetFlagOnDuplicates: TBitBtn;
    btnCreateFile: TBitBtn;
    btnSelectAll: TBitBtn;
    CheckBox1: TCheckBox;
    CheckGroup1: TCheckGroup;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
    procedure btnSetFlagOnDuplicatesClick(Sender: TObject);
    procedure btnCreateFileClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmviz_grapfer_histogram: Tfrmviz_grapfer_histogram;
  user_path :string;
  fo,fo1 :text;

implementation

uses osmain, dm, osunitsconversion;

{$R *.lfm}

{ Tfrmviz_grapfer_histogram }

procedure Tfrmviz_grapfer_histogram.FormShow(Sender: TObject);
begin
  memo1.Clear;
  Edit3.Text:='';
  Edit4.Text:='';
  Edit5.Text:='';
  CheckGroup1.items:=frmosmain.ListBox1.Items;
end;

procedure Tfrmviz_grapfer_histogram.btnSelectAllClick(Sender: TObject);
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



procedure Tfrmviz_grapfer_histogram.btnSetFlagOnDuplicatesClick(Sender: TObject);
var
kt :integer;
tbl_count,PQF2,PQF2_count :integer;
tbl :string;
DT1,DT2: TDateTime;
begin
DT1:=NOW;
memo1.Lines.Add('...start [histogram duplicates]: '+datetimetostr(DT1));

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


{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{C}if CheckGroup1.Checked[kt] then begin

   Edit3.Text:='';
   Edit4.Text:='';
   Edit5.Text:='';

   tbl:=CheckGroup1.Items.Strings[kt]; {selected table}
   Edit3.Text:=tbl;
   Application.ProcessMessages;

   with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' update '+tbl+' set PQF2=-1 ');
     SQL.Add(' where id in (select id from station where duplicate=true) ');
     SQL.Add(' and PQF2<>1 and PQF2<>2 ');
     ExecSQL;
   end;
     frmdm.TR.Commit;


   memo1.Lines.Add('');
   memo1.Lines.Add(tbl+'   PQF2 statistics ');
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


{C}end; {table is checked }
{T}end; {tables cycle}

DT2:=NOW;
memo1.Lines.Add('');
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;




procedure Tfrmviz_grapfer_histogram.btnCreateFileClick(Sender: TObject);
Type
  bin=record
    md :real;
    freq :integer;
    min :real;
    max :real;
  end;
  HistogramType=array of bin;
var
Histogram :HistogramType;
kt,ks,kb,mik :integer;
tbl_count,samples_total,def_count,sel_size,bn :integer;
units_def,units_id,PQF2,units_count,samples_count,row1,row2,step :integer;
val,val_min,val_max,val_conv,b_min,b_max,b_md,val_range,val_step :real;
tbl,fn,fstr,units_name,ustr :string;
convert,isconverted :boolean;
DT1,DT2: TDateTime;
begin
  DT1:=NOW;
  memo1.Lines.Add('...start [histogram create]: '+datetimetostr(DT1));

  memo1.Lines.Add('bins#='+Edit1.Text);
  memo1.Lines.Add('PQF2>='+Edit2.Text);
  memo1.Lines.Add('');

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

   user_path:=GlobalUnloadPath+PathDelim+'histogram'+PathDelim;
   if directoryexists(user_path)=false then mkdir(user_path);

   fn:=user_path+'_statistics.txt';
   assignfile(fo1,fn);
   rewrite(fo1);
   fstr:='tbl'+#9+'samples'+#9+'min'+#9+'max'+#9+'unit';
   writeln(fo1,fstr);


{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{C}if CheckGroup1.Checked[kt] then begin

   Edit3.Text:='';
   Edit4.Text:='';
   Edit5.Text:='';

   tbl:=CheckGroup1.Items.Strings[kt]; {selected table}
   Edit3.Text:=tbl;
   if CheckBox1.Checked then memo1.Lines.Add(tbl);

   fn:=user_path+copy(tbl,3,length(tbl))+'.txt';
   assignfile(fo,fn);
   rewrite(fo);
   fstr:='bin_md'+#9+'frequency'+#9+'samples'+#9+'bin_min'+#9+'bin_max'+#9+'default unit';
   writeln(fo,fstr);

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

   {...default unit name}
   with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select name_short as ns from UNITS ');
     SQL.Add(' where id=:units_id ');
     ParamByName('units_id').AsInteger:=units_def;
     Open;
     units_name:=frmdm.q2.FieldByName('ns').AsString;
     Close;
   end;

   {...units composition in table}
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
     if CheckBox1.Checked then memo1.Lines.Add(inttostr(units_id)+' ('+units_name+'): '+#9+inttostr(units_count));
     frmdm.q2.Next;
{U}end;
     frmdm.q2.Close;

     {...conversion creterion}
     if mik=1 then convert:=false else convert:=true;

   {...samples in table}
   with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select count(id) as samples_count from '+tbl);
     Open;
     samples_total:=FieldByName('samples_count').AsInteger;
     Edit4.Text:=inttostr(samples_total);
     Close;
   end;
     Application.ProcessMessages;

     sel_size:=5000000;
     if samples_total>sel_size then step:=trunc(samples_total/sel_size) else step:=1;

     samples_count:=0;
     def_count:=0;
     val_min:=9999;
     val_max:=-9999;

{.....A define min and max}
{STEP}for ks:=1 to step do begin
   row1:=1+sel_size*(ks-1);
   row2:=sel_size*ks;
   if ks=step then row2:=samples_total;
   if CheckBox1.Checked then memo1.Lines.Add('step='+inttostr(ks)+'  '+inttostr(row1)+'->'+inttostr(row2));

   with frmdm.q1 do begin
     Close;
     SQL.Clear;
     //SQL.Add(' select id,val,PQF2,units_id from '+tbl);
     SQL.Add(' select * from '+tbl);
     SQL.Add(' rows :row1 to :row2 ');
     ParamByName('row1').AsInteger:=row1;
     ParamByName('row2').AsInteger:=row2;
     Open;
   end;

   {.....units convertion TRUE}
//{UCT}if convert=true then begin
    frmdm.q1.First;
{Samples}while not frmdm.q1.EOF do begin

   samples_count:=samples_count+1;

   if samples_count mod 1000=0 then begin
     Edit5.Text:=inttostr(samples_count);
     Application.ProcessMessages;
   end;
   if (samples_count<1000000) and (samples_count mod 1000=0) then begin
     Edit5.Text:=inttostr(samples_count);
     Application.ProcessMessages;
   end;

   //station_id:=frmdm.q1.FieldByName('id').AsInteger;
   //lev_m:=frmdm.q1.FieldByName('lev_m').AsFloat;
   val:=frmdm.q1.FieldByName('val').AsFloat;
   //PQF1:=frmdm.q1.FieldByName('PQF1').AsInteger;
   PQF2:=frmdm.q1.FieldByName('PQF2').AsInteger;
   units_id:=frmdm.q1.FieldByName('units_id').AsInteger;
   //instr_id:=frmdm.q1.FieldByName('instrument_id').AsInteger;
   //prf_num:=frmdm.q1.FieldByName('profile_number').AsInteger;
   //best:=frmdm.q1.FieldByName('profile_best').AsBoolean;

   //if station_id=3022261 then showmessage('PQF2='+inttostr(PQF2));

{PQF2}if PQF2>=strtoint(trim(Edit2.Text)) then begin

   if units_id=units_def then begin
     def_count:=def_count+1;
     if val_min>val then val_min:=val;
     if val_max<val then val_max:=val;
   end
{CONVERSION}else begin
     isconverted:=false;
     val_conv:=-9999;
     {ICES}
     getdefaultunits(tbl,units_id,units_def,val,val_conv,isconverted);
     if isconverted=true then begin
       def_count:=def_count+1;
       if val_min>val_conv then val_min:=val_conv;
       if val_max<val_conv then val_max:=val_conv;

       {if val_conv>1000 then
       memo1.Lines.Add(inttostr(samples_count)
       +' station_id='+inttostr(station_id)
       +' lev_m='+floattostr(lev_m)
       +' val='+floattostr(val)
       +' PQF2='+inttostr(PQF2)
       +' units='+inttostr(units_id)
       +' val_conv='+floattostr(val_conv));}

     end;
{CONVERSION}end;


{PQF2}end;

   frmdm.q1.Next;
{Samples}end;
   Edit5.Text:=inttostr(samples_count);
//{UCT}end;   //table includes units have to be converted
{STEP}end;
{.....A define min and max}

{.....B create Histogram = dynamic array}
   bn:=strtoint(Edit1.Text); //bins number

    val_range:=val_max-val_min;
    val_step:=val_range/bn;
   for kb:=0 to bn-1 do begin
     SetLength(Histogram,kb+1);
     b_min:=val_min+val_step*(kb);
     b_max:=val_min+val_step*(kb+1);
     b_md:=(b_min+b_max)/2;
     Histogram[kb].md:=b_md;
     Histogram[kb].freq:=0;
     Histogram[kb].min:=b_min;
     Histogram[kb].max:=b_max;
   end;

{.....C populate Histogram}
   def_count:=0;
   samples_count:=0;

{STEP}for ks:=1 to step do begin
   row1:=1+sel_size*(ks-1);
   row2:=sel_size*ks;
   if ks=step then row2:=samples_total;
   if CheckBox1.Checked then memo1.Lines.Add('step='+inttostr(ks)+'  '+inttostr(row1)+'->'+inttostr(row2));

   with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select val,PQF2,units_id from '+tbl);
     SQL.Add(' rows :row1 to :row2 ');
     ParamByName('row1').AsInteger:=row1;
     ParamByName('row2').AsInteger:=row2;
     Open;
   end;

   {.....units convertion TRUE}
    frmdm.q1.First;
{Samples}while not frmdm.q1.EOF do begin

   samples_count:=samples_count+1;

   if samples_count mod 1000=0 then begin
     Edit5.Text:=inttostr(samples_count);
     Application.ProcessMessages;
   end;
   if (samples_count<1000000) and (samples_count mod 1000=0) then begin
     Edit5.Text:=inttostr(samples_count);
     Application.ProcessMessages;
   end;

   val:=frmdm.q1.FieldByName('val').AsFloat;
   //PQF1:=frmdm.q1.FieldByName('PQF1').AsInteger;
   PQF2:=frmdm.q1.FieldByName('PQF2').AsInteger;
   units_id:=frmdm.q1.FieldByName('units_id').AsInteger;
   //instr_id:=frmdm.q1.FieldByName('instrument_id').AsInteger;
   //prf_num:=frmdm.q1.FieldByName('profile_number').AsInteger;
   //best:=frmdm.q1.FieldByName('profile_best').AsBoolean;

{PQF2}if PQF2>=strtoint(Edit2.Text) then begin

{def}if units_id=units_def then begin
     def_count:=def_count+1;
{bin}for kb:=0 to High(Histogram) do begin
     if (val>=Histogram[kb].min) and (val<Histogram[kb].max) then Histogram[kb].freq:=Histogram[kb].freq+1;
     if (kb=High(Histogram)) and (val=Histogram[kb].max) then Histogram[kb].freq:=Histogram[kb].freq+1;
{bin}end;
{def}end
{CONVERSION}else begin
     isconverted:=false;
     val_conv:=-9999;
     {ICES}
     getdefaultunits(tbl,units_id,units_def,val,val_conv,isconverted);
{true}if isconverted=true then begin
     def_count:=def_count+1;
{bin}for kb:=0 to High(Histogram) do begin
     if (val_conv>=Histogram[kb].min) and (val_conv<Histogram[kb].max) then Histogram[kb].freq:=Histogram[kb].freq+1;
     if (kb=High(Histogram)) and (val_conv=Histogram[kb].max) then Histogram[kb].freq:=Histogram[kb].freq+1;
{bin}end;
{true}end;
{CONVERSION}end;

{PQF2}end;

   frmdm.q1.Next;
{Samples}end;
   Edit5.Text:=inttostr(samples_count);
{STEP}end;
{.....C populate Histogram}

   for kb:=0 to High(Histogram) do begin
     writeln(fo,floattostrF(Histogram[kb].md,ffFixed,12,3)
     +#9+inttostr(Histogram[kb].freq)
     +#9+inttostr(def_count)
     +#9+floattostrF(Histogram[kb].min,ffFixed,12,3)
     +#9+floattostrF(Histogram[kb].max,ffFixed,12,3)
     +#9+units_name
     );
   end;

   if convert=true then ustr:='multiple units' else ustr:='one unit';

   memo1.Lines.Add(tbl
   +#9+inttostr(def_count)
   +#9+floattostrF(val_min,ffFixed,12,3)
   +'->'
   +floattostrF(val_max,ffFixed,12,3)
   +#9+'['+units_name+']'
   +#9+ustr);

   {...QC ranges}
   writeln(fo1,tbl
   +#9+inttostr(def_count)
   +#9+floattostrF(val_min,ffFixed,12,3)
   +#9+floattostrF(val_max,ffFixed,12,3)
   +#9+units_name);

   closefile(fo);

   SetLength(Histogram,0);

{C}end; {table is checked }
{T}end; {tables cycle}
   closefile(fo1);

DT2:=NOW;
memo1.Lines.Add('');
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;



end.

