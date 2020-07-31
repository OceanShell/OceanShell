unit osqc_meanprofile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  CheckLst;

type

  { TfrmQC_MeanProfile }

  TfrmQC_MeanProfile = class(TForm)
    btnComputeMeanProfile: TBitBtn;
    CheckBox1: TCheckBox;
    chklQCFlags: TCheckListBox;
    Edit1: TEdit;
    Edit2: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Memo1: TMemo;
    procedure btnComputeMeanProfileClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmQC_MeanProfile: TfrmQC_MeanProfile;

  //moved user_path into onshow
  user_path: string; // = 'c:\Users\ako071\AK\OceanShell-GIT\';
  fi,fo:text;

implementation

uses osmain,dm,osunitsconversion;

{$R *.lfm}

{ TfrmQC_MeanProfile }

procedure TfrmQC_MeanProfile.FormShow(Sender: TObject);
var
i,kt:integer;
begin
   user_path:=GlobalUnloadPath+PathDelim+'mean_profile';
   if not DirectoryExists(user_path) then CreateDir(user_path);

   memo1.Clear;
   frmdm.IBDB.GetTableNames(ListBox1.Items,False);
   for kt:=0 to ListBox1.Items.Count-1 do begin
    //if (copy(ListBox1.items.strings[kt],1,2)='P_') then ListBox2.items.add(ListBox1.items.strings[kt]);
    if ListBox1.items.strings[kt]='P_TEMPERATURE' then ListBox2.items.add(ListBox1.items.strings[kt]);
    if ListBox1.items.strings[kt]='P_SALINITY' then ListBox2.items.add(ListBox1.items.strings[kt]);
    if ListBox1.items.strings[kt]='P_OXYGEN' then ListBox2.items.add(ListBox1.items.strings[kt]);
   end;

   for i:=0 to chklQCFlags.Count-1 do chklQCFlags.Checked[i]:=true;
   chklQCFlags.Checked[1]:=false;
   chklQCFlags.Checked[2]:=false;
end;



procedure TfrmQC_MeanProfile.btnComputeMeanProfileClick(Sender: TObject);
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

var
MP: LS; {mean profile}
SSID: array of integer; {selected stations id}

i,kt,kl,mik :integer;
unit_id,station_id,pqf2,n,sd_factor,uid_count,count_profiles,count_samples: integer;
instrument_id,profile_number :integer;
s1,s2 :double;
lev_m,val,val_conv,L1,L2,LM: real;
sd1L,sd1R,sd2L,sd2R,sd3L,sd3R,sd4L,sd4R,sd5L,sd5R :real;
md,sd,sdL,sdR :real;
fn,fn_in,tbl:string;
vu,vf,val_outside_sd,new_id,isconverted:boolean;
DT1,DT2: TDateTime;



begin
   DT1:=NOW;
   memo1.Lines.Add('...start: '+datetimetostr(DT1));
   memo1.Lines.Add('number of selected stations= '+inttostr(SCount));
   memo1.Lines.Add('');
   memo1.Lines.Add('tbl'+#9+'prf#'+#9+'samples# '+#9+'outside_sd#');


{.....STEP 1}
{T}for kt:=0 to ListBox2.Items.Count-1 do begin

    count_samples:=0;
    count_profiles:=0;

    setlength(MP,1);

    MP[0].l1:=0;
    MP[0].l2:=0;
    MP[0].n:=0;
    MP[0].md:=0;
    MP[0].s1:=0;
    MP[0].s2:=0;
    MP[0].sd:=0;
    MP[0].min:=9999;
    MP[0].max:=-9999;

{MP}for kl:=1 to 44 do begin
      setlength(MP,kl+1);

      {SEaDataNet global climatology  July 2019}
      case kl of
      1: begin  MP[kl].l1:=0;  MP[kl].l2:=10; end;
      2: begin  MP[kl].l1:=10;  MP[kl].l2:=20; end;
      3: begin  MP[kl].l1:=20;  MP[kl].l2:=30; end;
      4: begin  MP[kl].l1:=30;  MP[kl].l2:=40; end;
      5: begin  MP[kl].l1:=40;  MP[kl].l2:=50; end;
      6: begin  MP[kl].l1:=50;  MP[kl].l2:=60; end;
      7: begin  MP[kl].l1:=60;  MP[kl].l2:=70; end;
      8: begin  MP[kl].l1:=70;  MP[kl].l2:=80; end;
      9: begin  MP[kl].l1:=80;  MP[kl].l2:=90; end;
      10: begin  MP[kl].l1:=90;  MP[kl].l2:=100; end;
      11: begin  MP[kl].l1:=100;  MP[kl].l2:=125; end;
      12: begin  MP[kl].l1:=125;  MP[kl].l2:=150; end;
      13: begin  MP[kl].l1:=150;  MP[kl].l2:=175; end;
      14: begin  MP[kl].l1:=175;  MP[kl].l2:=200; end;
      15: begin  MP[kl].l1:=200;  MP[kl].l2:=225; end;
      16: begin  MP[kl].l1:=225;  MP[kl].l2:=250; end;
      17: begin  MP[kl].l1:=250;  MP[kl].l2:=275; end;
      18: begin  MP[kl].l1:=275;  MP[kl].l2:=300; end;
      19: begin  MP[kl].l1:=300;  MP[kl].l2:=325; end;
      20: begin  MP[kl].l1:=325;  MP[kl].l2:=350; end;
      21: begin  MP[kl].l1:=350;  MP[kl].l2:=375; end;
      22: begin  MP[kl].l1:=375;  MP[kl].l2:=400; end;
      23: begin  MP[kl].l1:=400;  MP[kl].l2:=425; end;
      24: begin  MP[kl].l1:=425;  MP[kl].l2:=450; end;
      25: begin  MP[kl].l1:=450;  MP[kl].l2:=475; end;
      26: begin  MP[kl].l1:=475;  MP[kl].l2:=500; end;
      27: begin  MP[kl].l1:=500;  MP[kl].l2:=600; end;
      28: begin  MP[kl].l1:=600;  MP[kl].l2:=700; end;
      29: begin  MP[kl].l1:=700;  MP[kl].l2:=800; end;
      30: begin  MP[kl].l1:=800;  MP[kl].l2:=900; end;
      31: begin  MP[kl].l1:=900;  MP[kl].l2:=1000; end;
      32: begin  MP[kl].l1:=1000;  MP[kl].l2:=1200; end;
      33: begin  MP[kl].l1:=1200;  MP[kl].l2:=1400; end;
      34: begin  MP[kl].l1:=1400;  MP[kl].l2:=1600; end;
      35: begin  MP[kl].l1:=1600;  MP[kl].l2:=1800; end;
      36: begin  MP[kl].l1:=1800;  MP[kl].l2:=2000; end;
      37: begin  MP[kl].l1:=2000;  MP[kl].l2:=2500; end;
      38: begin  MP[kl].l1:=2500;  MP[kl].l2:=3000; end;
      39: begin  MP[kl].l1:=3000;  MP[kl].l2:=3500; end;
      40: begin  MP[kl].l1:=3500;  MP[kl].l2:=4000; end;
      41: begin  MP[kl].l1:=4000;  MP[kl].l2:=4500; end;
      42: begin  MP[kl].l1:=4500;  MP[kl].l2:=5000; end;
      43: begin  MP[kl].l1:=5000;  MP[kl].l2:=5500; end;
      44: begin  MP[kl].l1:=5500;  MP[kl].l2:=6000; end;
      end;

      MP[kl].n:=0;
      MP[kl].md:=0;
      MP[kl].sd:=0;
      MP[kl].s1:=0;
      MP[kl].s2:=0;
      MP[kl].min:=9999;
      MP[kl].max:=-9999;
{MP}end;

    tbl:=ListBox2.items.strings[kt];
    //memo1.Lines.Add(tbl);

    if tbl = 'P_TEMPERATURE' then fn:=user_path+pathdelim+'temperature_data.txt';
    if tbl = 'P_SALINITY' then    fn:=user_path+pathdelim+'salinity_data.txt';
    if tbl = 'P_OXYGEN' then      fn:=user_path+pathdelim+'oxygen_data.txt';

    assignfile(fo,fn);
    rewrite(fo);
    writeln(fo,'lev_m'+#9+'val'+#9+'unit_id'+#9+'station_id'+#9+'instrument_id'+#9+'profile_number');

     frmdm.Q.DisableControls;
     frmdm.Q.First;
{ID}while not frmdm.Q.EOF do begin

     station_id:=frmdm.Q.FieldByName('ID').AsInteger;

     with frmdm.q1 do begin
       Close;
       SQL.Clear;
       SQL.Add(' Select * from '+tbl);
       SQL.Add(' where id=:station_id ');
       ParamByName('station_id').AsInteger:=station_id;
       Open;
     end;

     if frmdm.q1.IsEmpty=false then count_profiles:=count_profiles+1;

{.....MP}
     frmdm.q1.First;
{L}while not frmdm.q1.EOF do begin

    count_samples:=count_samples+1;

    lev_m:=frmdm.q1.FieldByName('lev_m').AsFloat;
    val:=frmdm.q1.FieldByName('val').AsFloat;
    pqf2:=frmdm.q1.FieldByName('pqf2').AsInteger;
    unit_id:=frmdm.q1.FieldByName('units_id').AsInteger;
    instrument_id:=frmdm.q1.FieldByName('instrument_id').AsInteger;
    profile_number:=frmdm.q1.FieldByName('profile_number').AsInteger;

    vu:=false; {valid unit}
    val_conv:=-999;
    isconverted:=false;

    if tbl = 'P_TEMPERATURE' then vu:=true;
    if tbl = 'P_SALINITY' then vu:=true;

    if tbl = 'P_OXYGEN' then begin
    if unit_id=3 then vu:=true
    else begin
      getdefaultunits(tbl,unit_id,3,val,val_conv,isconverted);
      if isconverted=true then begin  val:=val_conv; unit_id:=3; vu:=true; end;
    end;
    end;

    {if (unit_id=21) or (unit_id=3) then begin
    if unit_id=21 then begin
      val:=val*44.661/1.025;
      unit_id:=3;
    end;
    vu:=true;
    end;
    end;
    end;}

    vf:=false;  {valid(selected) QC flag}
    for i:=0 to chklQCFlags.Count-1 do if (chklQCFlags.Checked[i]) and (i=pqf2) then vf:=true;

{V}if (vu=true) and (vf=true) then begin
{MP}for kl:=1 to High(MP) do begin
     L1:=MP[kl].L1;
     L2:=MP[kl].L2;

{in}if (lev_m>=L1) and (lev_m<L2) then begin
     MP[kl].n:=MP[kl].n+1;
     MP[kl].s1:=MP[kl].s1+val;
     MP[kl].s2:=MP[kl].s2+val*val;
     if MP[kl].min>val then MP[kl].min:=val;
     if MP[kl].max<val then MP[kl].max:=val;

     writeln(fo,floattostrF(lev_m,ffFixed,7,1),
     #9,floattostrF(val,ffFixed,9,3),
     #9,inttostr(unit_id),
     #9,inttostr(station_id),
     #9,inttostr(instrument_id),
     #9,inttostr(profile_number)
     );

{in}end;

{MP}end;


{V}end;

    frmdm.q1.Next;
{L}end;
    frmdm.q1.Close;;

     frmdm.Q.Next;
{ID}end;
      frmdm.q1.Close;
      closefile(fo);
      frmdm.Q.EnableControls;

{.....MP output}
    if tbl = 'P_TEMPERATURE' then fn:=user_path+PathDelim+'temperature_MP_step1.txt';
    if tbl = 'P_SALINITY' then    fn:=user_path+PathDelim+'salinity_MP_step1.txt';
    if tbl = 'P_OXYGEN' then      fn:=user_path+PathDelim+'oxygen_MP_step1.txt';

    assignfile(fo,fn);
    rewrite(fo);
    writeln(fo,'LM'+#9+'md'+#9+'sd'+#9+'min'+#9+'max'+#9+'n'+#9+'L1'+#9+'L2'
    +#9+'1sdL'+#9+'1sdR'+#9+'2sdL'+#9+'2sdR'+#9+'3sdL'+#9+'3sdR'+#9+'4sdL'+#9+'4sdR'+#9+'5sdL'+#9+'5sdR');

{MP}for kl:=1 to High(MP) do begin
     L1:=MP[kl].L1;
     L2:=MP[kl].L2;
     LM:=(L2+L1)/2;

     n :=MP[kl].n;
     s1:=MP[kl].s1;
     s2:=MP[kl].s2;

{0}if n<>0 then begin

      //memo1.Lines.Add('sum of val and val*val  '+floattostr(s1)+'->'+floattostr(s2));
      MP[kl].md:=s1/n;
      MP[kl].sd:=(s2-s1*s1/n)/n;
      if MP[kl].sd<>0 then MP[kl].sd:=sqrt(abs(MP[kl].sd));

     //MP[kl].sd:=(MP[kl].sd-MP[kl].md*MP[kl].md/MP[kl].n)/MP[kl].n;

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

     if CheckBox1.Checked then
     memo1.Lines.Add(floattostr(L1)+'->'+floattostr(L2)
     +#9+inttostr(MP[kl].n)
     +#9+floattostrF(MP[kl].md,ffFixed,9,3)
     +#9+floattostrF(MP[kl].sd,ffFixed,9,3)
     +#9+floattostrF(MP[kl].min,ffFixed,9,3)
     +#9+floattostrF(MP[kl].max,ffFixed,9,3));

     {...how many measurements?}
     if MP[kl].n>=strtoint(Edit1.Text) then
     writeln(fo,floattostrF(LM,ffFixed,9,3),
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

{0}end;

{MP}end;
     closefile(fo);
     //memo1.Lines.Add(tbl+'  profiles#='+inttostr(count_profiles)
     //                   +'  samples#='+inttostr(count_samples));
{.....STEP 1 end}




{.....STEP 2}
{MP}for kl:=1 to 44 do begin
     MP[kl].n:=0;
     MP[kl].s1:=0;
     MP[kl].s2:=0;
{MP}end;

     frmdm.Q.DisableControls;
     frmdm.Q.First;
{ID}while not frmdm.Q.EOF do begin

     station_id:=frmdm.Q.FieldByName('ID').AsInteger;

     with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' Select * from '+tbl);
     SQL.Add(' where id=:station_id ');
     ParamByName('station_id').AsInteger:=station_id;
     Open;
     end;

{.....MP}
     frmdm.q1.First;
{L}while not frmdm.q1.EOF do begin

     lev_m:=frmdm.q1.FieldByName('lev_m').AsFloat;
     val:=frmdm.q1.FieldByName('val').AsFloat;
     pqf2:=frmdm.q1.FieldByName('pqf2').AsInteger;
     unit_id:=frmdm.q1.FieldByName('units_id').AsInteger;

     vu:=false; {valid unit}
     if tbl = 'P_TEMPERATURE' then vu:=true;
     if tbl = 'P_SALINITY' then vu:=true;
     if tbl = 'P_OXYGEN' then begin
     if (unit_id=21) or (unit_id=3) then begin
     if unit_id=21 then begin
       val:=val*44.661/1.025; {ml/l -> umol/kg}
       unit_id:=3;
     end;
       vu:=true;
     end;
     end;

     vf:=false;  {valid(selected) QC flag}
     for i:=0 to chklQCFlags.Count-1 do if (chklQCFlags.Checked[i]) and (i=pqf2) then vf:=true;

{V}if (vu=true) and (vf=true) then begin
{MP}for kl:=1 to High(MP) do begin
     L1:=MP[kl].L1;
     L2:=MP[kl].L2;

{in}if (lev_m>=L1) and (lev_m<L2) then begin

     MP[kl].n:=MP[kl].n+1;

     val:=val-MP[kl].md;  {переводим значения в аномалии}

     MP[kl].s1:=MP[kl].s1+val;
     MP[kl].s2:=MP[kl].s2+val*val;

     //writeln(fo,floattostrF(lev_m,ffFixed,7,1),
     //#9,floattostrF(val,ffFixed,9,3),
     //#9,inttostr(unit_id),
     //#9,inttostr(station_id));

{in}end;

{MP}end;


{V}end;

    frmdm.q1.Next;
{L}end;
    frmdm.q1.Close;;

    frmdm.Q.Next;
{ID}end;
    frmdm.q1.Close;
    //closefile(fo);
    frmdm.Q.EnableControls;

{.....MP output}
   if tbl = 'P_TEMPERATURE' then fn:=user_path+PathDelim+'temperature_MP.txt';
   if tbl = 'P_SALINITY' then    fn:=user_path+PathDelim+'salinity_MP.txt';
   if tbl = 'P_OXYGEN' then      fn:=user_path+PathDelim+'oxygen_MP.txt';

   assignfile(fo,fn);
   rewrite(fo);
   writeln(fo,'LM'+#9+'md'+#9+'sd'+#9+'min'+#9+'max'+#9+'n'+#9+'L1'+#9+'L2'
   +#9+'1sdL'+#9+'1sdR'+#9+'2sdL'+#9+'2sdR'+#9+'3sdL'+#9+'3sdR'+#9+'4sdL'+#9+'4sdR'+#9+'5sdL'+#9+'5sdR');


{MP}for kl:=1 to High(MP) do begin
     L1:=MP[kl].L1;
     L2:=MP[kl].L2;
     LM:=(L2+L1)/2;

     n :=MP[kl].n;
     s1:=MP[kl].s1;
     s2:=MP[kl].s2;

{0}if n<>0 then begin

 //memo1.Lines.Add('sum of val and val*val  '+floattostr(s1)+'->'+floattostr(s2));
     //MP[kl].md:=s1/n; {ставляем старое средние}
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

     if CheckBox1.Checked then
     memo1.Lines.Add(floattostr(L1)+'->'+floattostr(L2)
     +#9+inttostr(MP[kl].n)
     +#9+floattostrF(MP[kl].md,ffFixed,9,3)
     +#9+floattostrF(MP[kl].sd,ffFixed,9,3)
     +#9+floattostrF(MP[kl].min,ffFixed,9,3)
     +#9+floattostrF(MP[kl].max,ffFixed,9,3));

{...how many measurements?}
if MP[kl].n>=strtoint(Edit1.Text) then
     writeln(fo,floattostrF(LM,ffFixed,9,3),
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

{0}end;
{MP}end;

     closefile(fo);
{.....STEP 2 end}


{.....STEP 3 samples outside sd interval}
   sd_factor:=strtoint(Edit2.Text);
   PQF2:=2;

   if tbl = 'P_TEMPERATURE' then begin
     fn_in:=user_path+PathDelim+'temperature_data.txt';
     fn   :=user_path+PathDelim+'temperature_UPDATE_QCF.txt';
   end;
   if tbl = 'P_SALINITY' then begin
     fn_in:=user_path+PathDelim+'salinity_data.txt';
     fn:=   user_path+PathDelim+'salinity_UPDATE_QCF.txt';
   end;
   if tbl = 'P_OXYGEN' then begin
     fn_in:=user_path+PathDelim+'oxygen_data.txt';
     fn:=   user_path+PathDelim+'oxygen_UPDATE_QCF.txt';
   end;

   assignfile(fi,fn_in);
   reset(fi);

   assignfile(fo,fn);
   rewrite(fo);
   writeln(fo,'station_id'+#9+'lev_m'+#9+'val'+#9+'PQF2'+#9+'instrument_id'+#9+'profile_number');


     readln(fi);
     mik:=0;
     uid_count:=0; {unique station_id number count}
     setlength(SSID,1);
     SSID[0]:=0;
{W}while not EOF(fi) do begin

     readln(fi,lev_m,val,unit_id,station_id,instrument_id,profile_number);

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

{SD}if (lev_m>=L1) and (lev_m<L2) and val_outside_sd=true then begin
     mik:=mik+1;
     new_id:=true;
     for i:=0 to High(SSID) do if station_id=SSID[i] then new_id:=false;

{new}if new_id=true then begin
       uid_count:=uid_count+1;
       setlength(SSID,uid_count+1);
       SSID[uid_count]:=station_id;
{new}end;

     writeln(fo,inttostr(station_id),
     #9,floattostr(lev_m),
     #9,floattostr(val),
     #9,floattostr(PQF2),
     #9,inttostr(instrument_id),
     #9,inttostr(profile_number));

{SD}end;
{MP}end;
{W} end;
     closefile(fi);
     closefile(fo);

   if tbl = 'P_TEMPERATURE' then fn:=user_path+PathDelim+'temperature_SELECT_station_id.txt';
   if tbl = 'P_SALINITY' then    fn:=user_path+PathDelim+'salinity_SELECT_station_id.txt';
   if tbl = 'P_OXYGEN' then      fn:=user_path+PathDelim+'oxygen_SELECT_station_id.txt';

    assignfile(fo,fn);
    rewrite(fo);
    writeln(fo,'station_id');


     {...sort SSID?}
     for i:=1 to High(SSID) do writeln(fo,inttostr(SSID[i]));
     closefile(fo);

{.....STEP 3 end}

     memo1.Lines.Add(tbl
     +#9+inttostr(count_profiles)
     +#9+inttostr(count_samples)
     +#9+inttostr(mik));

     setlength(MP,0);
     setlength(SSID,0);
{T}end;

   DT2:=NOW;
   memo1.Lines.Add('');
   memo1.Lines.Add('...stop: '+datetimetostr(DT2));
   memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));


end;

end.

