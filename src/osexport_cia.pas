unit osExport_CIA;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  DateUtils, dynlibs;

type

  { TfrmExport_CIA }

  TfrmExport_CIA = class(TForm)
    btnExport: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    procedure btnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure qf_ocean_to_woce(qf_ocean:integer; var qf_woce:integer);

  public

  end;

var
  frmExport_CIA: TfrmExport_CIA;
  fo1,fo2,fo3,fo4 :text;

implementation

{$R *.lfm}
uses osmain,dm,sortbufds,GibbsSeaWater,osunitsconversion, osunitsconversion_exact;

{ TfrmExport_CIA }

procedure TfrmExport_CIA.FormShow(Sender: TObject);
begin
  memo1.Clear;
  memo1.Lines.Add('number of selected cruises='+inttostr(frmdm.QCruise.RecordCount));

end;



procedure TfrmExport_CIA.btnExportClick(Sender: TObject);

type
datasource=record
  id: integer;
  name: string;
end;
DBS = array of datasource;

type
station=record
lev_dbar: real;
lev_m: real;
bottle_number: integer;
temperature_val: real;
temperature_PQF2: integer;
temperature_SQF: integer;
salinity_val: real;
salinity_PQF2: integer;
salinity_SQF: integer;
oxygen_val: real;
oxygen_PQF2: integer;
oxygen_SQF:integer;
aou_val: real;
aou_PQF2: integer;
aou_SQF: integer;
nitrate_val: real;
nitrate_PQF2: integer;
nitrate_SQF: integer;
nitrite_val: real;
nitrite_PQF2: integer;
nitrite_SQF: integer;
silicate_val: real;
silicate_PQF2: integer;
silicate_SQF: integer;
phosphate_val: real;
phosphate_PQF2: integer;
phosphate_SQF: integer;
tco2_val: real;
tco2_PQF2: integer;
tco2_SQF: integer;
talk_val: real;
talk_PQF2: integer;
talk_SQF: integer;
phts25p0_val: real;
phts25p0_PQF2: integer;
phts25p0_SQF: integer;
phtsinsitutp_val: real;
phtsinsitutp_PQF2: integer;
phtsinsitutp_SQF: integer;
cfc11_val: real;
cfc11_PQF2: integer;
cfc11_SQF: integer;
pcfc11_val: real;
pcfc11_PQF2: integer;
pcfc11_SQF: integer;
cfc12_val: real;
cfc12_PQF2: integer;
cfc12_SQF: integer;
pcfc12_val: real;
pcfc12_PQF2: integer;
pcfc12_SQF: integer;
cfc113_val: real;
cfc113_PQF2: integer;
cfc113_SQF: integer;
pcfc113_val: real;
pcfc113_PQF2: integer;
pcfc113_SQF: integer;
ccl4_val: real;
ccl4_PQF2: integer;
ccl4_SQF: integer;
pccl4_val: real;
pccl4_PQF2: integer;
pccl4_SQF: integer;
sf6_val: real;
sf6_PQF2: integer;
sf6_SQF: integer;
psf6_val: real;
psf6_PQF2: integer;
psf6_SQF: integer;
c13_val: real;
c13_PQF2: integer;
c13_SQF: integer;
c14_val: real;
   c14_err: real;
c14_PQF2: integer;
c14_SQF: integer;
h3_val: real;
   h3_err: real;
h3_PQF2: integer;
h3_SQF: integer;
he3_val: real;
   he3_err: real;
he3_PQF2: integer;
he3_SQF: integer;
he_val: real;
   he_err: real;
he_PQF2: integer;
he_SQF: integer;
neon_val: real;
   neon_err: real;
neon_PQF2: integer;
neon_SQF: integer;
o18_val: real;
o18_PQF2: integer;
o18_SQF: integer;
toc_val: real;
toc_PQF2: integer;
toc_SQF: integer;
doc_val: real;
doc_PQF2: integer;
doc_SQF: integer;
don_val: real;
don_PQF2: integer;
don_SQF: integer;
tdn_val: real;
tdn_PQF2: integer;
tdn_SQF: integer;
chlorophyll_val: real;
chlorophyll_PQF2: integer;
chlorophyll_SQF: integer;
end;
CombinedStation = array of station;


var
ds: DBS;
CS: CombinedStation;

i,ktbl,klev :integer;
source_id,cruise_id,platform_id,station_id :integer;
count_cruises,count_stations,dup_in_cruise :integer;
lev_index :integer;
YY,MM,DD,HH,M,SS,MS :word;
st_db,st_dup,s,cast_number,bottom_depth :integer;
qf_ocean,qf_woce :integer;
lastlevel_dbar,lat,lon :real;
new_lev,v_comp :boolean;

nodc_code :string[4];
user_path,fn,expocode,str,str_md: string;
DT1,DT2,cr_DT,st_DT:TDateTime;

{P_ tables}
PQF2,SQF,bottle_number,units_id,units_def,instr_id,prof_num :integer;
lev_dbar,lev_m,val,valerr :real;
tbl: string;
tbl_seq: array[1..34] of string; {GLODAP 2019.v2}

{GLODAP}
theta,sigma0,sigma1,sigma2,sigma3,sigma4,gamma :real;
column :array[1..102] of string;

{GibbsSeaWater}
sp,sa,t_insitu,ct :real;

{units conversion}
val_conv,val_rep :real;
isconverted :boolean;

gsw_sa_from_sp:Tgsw_z_from_p;
gsw_pt0_from_t:Tgsw_pt0_from_t;
gsw_ct_from_t:Tgsw_ct_from_t;
gsw_sigma0:Tgsw_sigma0;
gsw_sigma1:Tgsw_sigma1;
gsw_sigma2:Tgsw_sigma2;
gsw_sigma3:Tgsw_sigma3;
gsw_sigma4:Tgsw_sigma4;
begin

    DT1:=NOW;
    memo1.Lines.Add('...start: '+datetimetostr(DT1));

    tbl_seq[1]:='temperature';
    tbl_seq[2]:='salinity';
    tbl_seq[3]:='oxygen';
    tbl_seq[4]:='aou';
    tbl_seq[5]:='nitrate';
    tbl_seq[6]:='nitrite';
    tbl_seq[7]:='silicate';
    tbl_seq[8]:='phosphate';
    tbl_seq[9]:='tco2';
    tbl_seq[10]:='alkalinity';
    tbl_seq[11]:='phts25p0';
    tbl_seq[12]:='phtsinsitutp';
    tbl_seq[13]:='cfc11';
    tbl_seq[14]:='pcfc11';
    tbl_seq[15]:='cfc12';
    tbl_seq[16]:='pcfc12';
    tbl_seq[17]:='cfc113';
    tbl_seq[18]:='pcfc113';
    tbl_seq[19]:='ccl4';
    tbl_seq[20]:='pccl4';
    tbl_seq[21]:='sf6';
    tbl_seq[22]:='psf6';
    tbl_seq[23]:='c13';
    tbl_seq[24]:='c14';
    tbl_seq[25]:='h3';
    tbl_seq[26]:='he3';
    tbl_seq[27]:='he';
    tbl_seq[28]:='neon';
    tbl_seq[29]:='o18';
    tbl_seq[30]:='toc';
    tbl_seq[31]:='doc';
    tbl_seq[32]:='don';
    tbl_seq[33]:='tdn';
    tbl_seq[34]:='chlorophyll';





    {str:='cruise,station,cast,year,month,day,hour,minute,latitude,longitude,'
    +'bottomdepth,maxsampdepth,bottle,pressure,depth,temperature,theta,'
    +'salinity,salinityf,salinityqc,sigma0,sigma1,sigma2,sigma3,sigma4,gamma,'
    +'oxygen,oxygenf,oxygenqc,aou,aouf,nitrate,nitratef,nitrateqc,nitrite,nitritef,'
    +'silicate,silicatef,silicateqc,phosphate,phosphatef,phosphateqc,tco2,tco2f,tco2qc,'
    +'talk,talkf,talkqc,phts25p0,phts25p0f,phtsinsitutp,phtsinsitutpf,phtsqc,cfc11,'
    +'pcfc11,cfc11f,cfc11qc,cfc12,pcfc12,cfc12f,cfc12qc,cfc113,pcfc113,cfc113f,cfc113qc,'
    +'ccl4,pccl4,ccl4f,ccl4qc,sf6,psf6,sf6f,c13,c13f,c13qc,c14,c14f,c14err,h3,h3f,h3err,'
    +'he3,he3f,he3err,he,hef,heerr,neon,neonf,neonerr,o18,o18f,toc,tocf,doc,docf,don,donf,'
    +'tdn,tdnf,chla,chlaf'; }


{cruise,station,cast,year,month,day,hour,minute,latitude,longitude,}
column[1]:='cruise';
column[2]:='station';
column[3]:='cast';
column[4]:='year';
column[5]:='month';
column[6]:='day';
column[7]:='hour';
column[8]:='minute';
column[9]:='latitude';
column[10]:='longitude';
column[11]:='bottomdepth';
column[12]:='maxsampdepth';
{bottle,pressure,depth,temperature,theta,}
column[13]:='bottle';
column[14]:='pressure';
column[15]:='depth';
column[16]:='temperature';
column[17]:='theta';
{salinity,salinityf,salinityqc,sigma0,sigma1,sigma2,sigma3,sigma4,gamma,}
column[18]:='salinity';
column[19]:='salinityf';
column[20]:='salinityqc';
column[21]:='sigma0';
column[22]:='sigma1';
column[23]:='sigma2';
column[24]:='sigma3';
column[25]:='sigma4';
column[26]:='gamma';
{oxygen,oxygenf,oxygenqc,aou,aouf,nitrate,nitratef,nitrateqc,nitrite,nitritef,}
column[27]:='oxygen';
column[28]:='oxygenf';
column[29]:='oxygenqc';
column[30]:='aou';
column[31]:='aouf';
column[32]:='nitrate';
column[33]:='nitratef';
column[34]:='nitrateqc';
column[35]:='nitrite';
column[36]:='nitritef';
{silicate,silicatef,silicateqc,phosphate,phosphatef,phosphateqc,tco2,tco2f,tco2qc}
column[37]:='silicate';
column[38]:='silicatef';
column[39]:='silicateqc';
column[40]:='phosphate';
column[41]:='phosphatef';
column[42]:='phosphateqc';
column[43]:='tco2';
column[44]:='tco2f';
column[45]:='tco2qc';
{talk,talkf,talkqc,phts25p0,phts25p0f,phtsinsitutp,phtsinsitutpf,phtsqc,cfc11}
column[46]:='talk';
column[47]:='talkf';
column[48]:='talkqc';
column[49]:='phts25p0';
column[50]:='phts25p0f';
column[51]:='phtsinsitutp';
column[52]:='phtsinsitutpf';
column[53]:='phtsqc';
column[54]:='cfc11';
{pcfc11,cfc11f,cfc11qc,cfc12,pcfc12,cfc12f,cfc12qc,cfc113,pcfc113,cfc113f,cfc113qc}
column[55]:='pcfc11';
column[56]:='cfc11f';
column[57]:='cfc11qc';
column[58]:='cfc12';
column[59]:='pcfc12';
column[60]:='cfc12f';
column[61]:='cfc12qc';
column[62]:='cfc113';
column[63]:='pcfc113';
column[64]:='cfc113f';
column[65]:='cfc113qc';
{ccl4,pccl4,ccl4f,ccl4qc,sf6,psf6,sf6f,c13,c13f,c13qc,c14,c14f,c14err,h3,h3f,h3err}
column[66]:='ccl4';
column[67]:='pccl4';
column[68]:='ccl4f';
column[69]:='ccl4qc';
column[70]:='sf6';
column[71]:='psf6';
column[72]:='sf6f';
column[73]:='c13';
column[74]:='c13f';
column[75]:='c13qc';
column[76]:='c14';
column[77]:='c14f';
column[78]:='c14err';
column[79]:='h3';
column[80]:='h3f';
column[81]:='h3err';
{he3,he3f,he3err,he,hef,heerr,neon,neonf,neonerr,o18,o18f,toc,tocf,doc,docf,don,donf}
column[82]:='he3';
column[83]:='he3f';
column[84]:='he3err';
column[85]:='he';
column[86]:='hef';
column[87]:='heerr';
column[88]:='neon';
column[89]:='neonf';
column[90]:='neonerr';
column[91]:='o18';
column[92]:='o18f';
column[93]:='toc';
column[94]:='tocf';
column[95]:='doc';
column[96]:='docf';
column[97]:='don';
column[98]:='donf';
{tdn,tdnf,chla,chlaf}
column[99]:='tdn';
column[100]:='tdnf';
column[101]:='chla';
column[102]:='chlaf';

    str:='';
    for i:=1 to 102 do if i<102 then str:=str+column[i]+',' else str:=str+column[i];

    {...geographic region}
    memo1.Lines.Add('Latitude : '+floattostr(SLatMin)+'->'+floattostr(SLatMax));
    memo1.Lines.Add('Longitude: '+floattostr(SLonMin)+'->'+floattostr(SLonMax));

    user_path:=GlobalUnloadPath+PathDelim+'export'+PathDelim;
    if directoryexists(user_path)=false then mkdir(user_path);
    fn:=user_path+'expocode.csv';
    memo1.Lines.Add(fn);
    assignfile(fo1,fn);
    rewrite(fo1);

    fn:=user_path+'data.csv';
    memo1.Lines.Add(fn);
    assignfile(fo2,fn);
    rewrite(fo2);

    writeln(fo2,str);

    fn:=user_path+'new_levels.txt';
    memo1.Lines.Add(fn);
    assignfile(fo3,fn);
    rewrite(fo3);
    str:='cruise'+#9+'station'+#9+'tbl'+#9+'lev_dbar'+#9+'lev_m';
    writeln(fo3,str);

    fn:=user_path+'converted_units.txt';
    memo1.Lines.Add(fn);
    assignfile(fo4,fn);
    rewrite(fo4);
    str:='tbl'
    +#9+'cruise_id'
    +#9+'station_id'
    +#9+'unit_rep'
    +#9+'unit_default'
    +#9+'instrument_id'
    +#9+'profile_num'
    +#9+'lev_m'
    +#9+'val'
    +#9+'val_conv';
    writeln(fo4,str);

    memo1.Lines.Add('');
    if CheckBox1.Checked then
    memo1.Lines.Add('source'+#9+'cruise'+#9+'st#'+#9+'dup#'+#9+'expocode');


{.....store source.id and source.name in dynamic array ds}
    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' Select id, name from SOURCE ');
      Open;
    end;

    s:=1;
    setlength(ds,s);
    ds[s-1].id:=0;
    ds[s-1].name:='';
{ds}while not frmdm.q1.EOF do begin
     s:=s+1;
     setlength(ds,s);
     ds[s-1].id:=frmdm.q1.FieldByName('id').AsInteger;
     ds[s-1].name:=frmdm.q1.FieldByName('name').AsString;
     frmdm.q1.Next;
{ds}end;
     frmdm.q1.Close;


{.....selected cruises}
     count_cruises:=0;
     count_stations:=0;

     SortBufDataSet(frmdm.QCruise, 'ID');

     frmdm.QCruise.First;
{QC}while not frmdm.QCruise.EOF do begin

     dup_in_cruise:=frmdm.QCruise.FieldByName('stations_duplicates').AsInteger;
     //showmessage(inttostr(dup_in_cruise)+'->'+Edit1.Text);

{DUP}if dup_in_cruise<=strtoint(trim(Edit1.Text)) then begin

     count_cruises:=count_cruises+1;

     source_id:=frmdm.QCruise.FieldByName('source_id').AsInteger;
     cruise_id:=frmdm.QCruise.FieldByName('id').AsInteger;
     platform_id:=frmdm.QCruise.FieldByName('platform_id').AsInteger;
     st_db:=frmdm.QCruise.FieldByName('stations_database').AsInteger;
     st_dup:=frmdm.QCruise.FieldByName('stations_duplicates').AsInteger;
     cr_DT:=frmdm.QCruise.FieldByName('date_start_database').AsDateTime;
     DecodeDate(cr_DT,YY,MM,DD);

     with frmdm.q1 do begin
       Close;
       SQL.Clear;
       SQL.Add(' Select nodc_code from PLATFORM ');
       SQL.Add(' where id=:platform_id ');
       ParamByName('platform_id').AsInteger:=platform_id;
       Open;
       nodc_code:=FieldByName('nodc_code').AsString;
       Close;
     end;

     expocode:=' '+nodc_code+inttostr(YY)+inttostr(MM)+inttostr(DD)+'_'+ds[source_id].name;

     if CheckBox1.Checked then
     memo1.Lines.Add(inttostr(count_cruises)
     +#9+inttostr(source_id)
     +#9+ds[source_id].name
     +#9+inttostr(cruise_id)
     +#9+inttostr(st_db)
     +#9+inttostr(st_dup)
     +#9+expocode
     );

     writeln(fo1,inttostr(cruise_id),',',expocode);

{.....data file}
{.....all stations in cruise}
    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select * from STATION ');
      SQL.Add(' where cruise_id=:cruise_id ');
      SQL.Add(' and latitude>=:slatmin and latitude<:slatmax ');
      SQL.Add(' and longitude>=:slonmin and longitude<:slonmax ');
      ParamByName('cruise_id').AsInteger:=cruise_id;
      ParamByName('slatmin').AsFloat:=slatmin;
      ParamByName('slatmax').AsFloat:=slatmax;
      ParamByName('slonmin').AsFloat:=slonmin;
      ParamByName('slonmax').AsFloat:=slonmax;
      Open;
    end;

    str_md:='';
    str:='';

    {...stations}
{ST}while not frmdm.q1.EOF do begin

   {1 cruise,		md_1	cruise_id
    2 station,	        md_2	station_id or st_number_origin
    3 cast,		md_3	cast_number
    4 year,		md_4	dateandtime
    5 month,		md_5	dateandtime
    6 day,		md_6	dateandtime
    7 hour,		md_7	dateandtime
    8 minute,		md_8	dateandtime
    9 latitude,	        md_9	latitude
    10 longitude,	        md_10	longitude
    11 bottomdepth,	md_11	bottomdepth
    12 maxsampdepth,	md_12	lastlevel_dbar}

     count_stations:=count_stations+1;


    station_id:=frmdm.q1.FieldByName('id').AsInteger;
    st_DT:=frmdm.q1.FieldByName('dateandtime').AsDateTime;
    DecodeDateTime(st_DT,YY,MM,DD,HH,M,SS,MS);

    {station number символы нельзя?}
    cast_number   :=-9999;
    bottom_depth  :=-9999;
    lastlevel_dbar:=-9999;
    if frmdm.q1.FieldByName('cast_number').IsNull=false then
    cast_number:=frmdm.q1.FieldByName('cast_number').AsInteger;
    if frmdm.q1.FieldByName('bottomdepth').IsNull=false then
    bottom_depth:=frmdm.q1.FieldByName('bottomdepth').AsInteger;  {GEBCO если нет?}
    if frmdm.q1.FieldByName('lastlevel_dbar').IsNull=false then
    lastlevel_dbar:=frmdm.q1.FieldByName('lastlevel_dbar').AsFloat;

    lat:=frmdm.q1.FieldByName('latitude').AsFloat;
    lon:=frmdm.q1.FieldByName('longitude').AsFloat;

    str_md:=inttostr(cruise_id)+','
        +inttostr(station_id)+','
        +inttostr(frmdm.q1.FieldByName('cast_number').AsInteger)+','
        +inttostr(YY)+','
        +inttostr(MM)+','
        +inttostr(DD)+','
        +inttostr(HH)+','
        +inttostr(M)+','
        +floattostr(lat)+','
        +floattostr(lon)+','
        +inttostr(bottom_depth)+','
        +floattostr(lastlevel_dbar)+',';


    {bottle,
    pressure,
    depth,
    temperature,   v_1
    theta,
    salinity,      v_2
    salinityf,
    salinityqc,
    sigma0,
    sigma1,
    sigma2,
    sigma3,
    sigma4,
    gamma,
    oxygen,	   v_3
    oxygenf,
    oxygenqc,}


    bottle_number:=-9999;

    {...P_tables}
    s:=1;
    setlength(CS,s);
    CS[s-1].lev_dbar:=-9999;
    CS[s-1].lev_m:=-9999;
    CS[s-1].bottle_number:=-9999;
    CS[s-1].temperature_val:=-9999;
    CS[s-1].temperature_PQF2:=-9999;
    CS[s-1].temperature_SQF:=-9999;
    CS[s-1].salinity_val:=-9999;
    CS[s-1].salinity_PQF2:=-9999;
    CS[s-1].salinity_SQF:=-9999;
    CS[s-1].oxygen_val:=-9999;
    CS[s-1].oxygen_PQF2:=-9999;
    CS[s-1].oxygen_SQF:=-9999;
    CS[s-1].aou_val:=-9999;
    CS[s-1].aou_PQF2:=-9999;
    CS[s-1].aou_SQF:=-9999;
    CS[s-1].nitrate_val:=-9999;
    CS[s-1].nitrate_PQF2:=-9999;
    CS[s-1].nitrate_SQF:=-9999;
    CS[s-1].nitrite_val:=-9999;
    CS[s-1].nitrite_PQF2:=-9999;
    CS[s-1].nitrite_SQF:=-9999;
    CS[s-1].silicate_val:=-9999;
    CS[s-1].silicate_PQF2:=-9999;
    CS[s-1].silicate_SQF:=-9999;
    CS[s-1].phosphate_val:=-9999;
    CS[s-1].phosphate_PQF2:=-9999;
    CS[s-1].phosphate_SQF:=-9999;
    CS[s-1].tco2_val:=-9999;
    CS[s-1].tco2_PQF2:=-9999;
    CS[s-1].tco2_SQF:=-9999;
    CS[s-1].talk_val:=-9999;
    CS[s-1].talk_PQF2:=-9999;
    CS[s-1].talk_SQF:=-9999;
    CS[s-1].phts25p0_val:=-9999;
    CS[s-1].phts25p0_PQF2:=-9999;
    CS[s-1].phts25p0_SQF:=-9999;
    CS[s-1].phtsinsitutp_val:=-9999;
    CS[s-1].phtsinsitutp_PQF2:=-9999;
    CS[s-1].phtsinsitutp_SQF:=-9999;
    CS[s-1].cfc11_val:=-9999;
    CS[s-1].cfc11_PQF2:=-9999;
    CS[s-1].cfc11_SQF:=-9999;
    CS[s-1].pcfc11_val:=-9999;
    CS[s-1].pcfc11_PQF2:=-9999;
    CS[s-1].pcfc11_SQF:=-9999;
    CS[s-1].cfc12_val:=-9999;
    CS[s-1].cfc12_PQF2:=-9999;
    CS[s-1].cfc12_SQF:=-9999;
    CS[s-1].pcfc12_val:=-9999;
    CS[s-1].pcfc12_PQF2:=-9999;
    CS[s-1].pcfc12_SQF:=-9999;
    CS[s-1].cfc113_val:=-9999;
    CS[s-1].cfc113_PQF2:=-9999;
    CS[s-1].cfc113_SQF:=-9999;
    CS[s-1].pcfc113_val:=-9999;
    CS[s-1].pcfc113_PQF2:=-9999;
    CS[s-1].pcfc113_SQF:=-9999;
    CS[s-1].ccl4_val:=-9999;
    CS[s-1].ccl4_PQF2:=-9999;
    CS[s-1].ccl4_SQF:=-9999;
    CS[s-1].pccl4_val:=-9999;
    CS[s-1].pccl4_PQF2:=-9999;
    CS[s-1].pccl4_SQF:=-9999;
    CS[s-1].sf6_val:=-9999;
    CS[s-1].sf6_PQF2:=-9999;
    CS[s-1].sf6_SQF:=-9999;
    CS[s-1].psf6_val:=-9999;
    CS[s-1].psf6_PQF2:=-9999;
    CS[s-1].psf6_SQF:=-9999;
    CS[s-1].c13_val:=-9999;
    CS[s-1].c13_PQF2:=-9999;
    CS[s-1].c13_SQF:=-9999;
    CS[s-1].c14_val:=-9999;
    CS[s-1].c14_err:=-9999;
    CS[s-1].c14_PQF2:=-9999;
    CS[s-1].c14_SQF:=-9999;
    CS[s-1].h3_val:=-9999;
    CS[s-1].h3_err:=-9999;
    CS[s-1].h3_PQF2:=-9999;
    CS[s-1].h3_SQF:=-9999;
    CS[s-1].he_val:=-9999;
    CS[s-1].he_err:=-9999;
    CS[s-1].he_PQF2:=-9999;
    CS[s-1].he_SQF:=-9999;
    CS[s-1].neon_val:=-9999;
    CS[s-1].neon_err:=-9999;
    CS[s-1].neon_PQF2:=-9999;
    CS[s-1].neon_SQF:=-9999;
    CS[s-1].o18_val:=-9999;
    CS[s-1].o18_PQF2:=-9999;
    CS[s-1].o18_SQF:=-9999;
    CS[s-1].toc_val:=-9999;
    CS[s-1].toc_PQF2:=-9999;
    CS[s-1].toc_SQF:=-9999;
    CS[s-1].doc_val:=-9999;
    CS[s-1].doc_PQF2:=-9999;
    CS[s-1].doc_SQF:=-9999;
    CS[s-1].don_val:=-9999;
    CS[s-1].don_PQF2:=-9999;
    CS[s-1].don_SQF:=-9999;
    CS[s-1].tdn_val:=-9999;
    CS[s-1].tdn_PQF2:=-9999;
    CS[s-1].tdn_SQF:=-9999;
    CS[s-1].chlorophyll_val:=-9999;
    CS[s-1].chlorophyll_PQF2:=-9999;
    CS[s-1].chlorophyll_SQF:=-9999;

   {GLODAP data in 34 P_ tables }
   {OCEAN  data in 37 P_ tables }
{T}for ktbl:=1 to 34 do begin

     tbl:='P_'+Upcase(tbl_seq[ktbl]);

     with frmdm.q2 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select * from '+tbl);
      SQL.Add(' where id=:station_id ');
      ParamByName('station_id').AsInteger:=station_id;
      Open;
     end;

     {#NEW}
     {with frmdm.q2 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select * from STATION, '+tbl);
      SQL.Add(' where STATION.id='+tbl+'.id');
      SQL.Add(' STATION.id=:station_id ');
      ParamByName('station_id').AsInteger:=station_id;
      Open;
    end;}


{EMPTY}if frmdm.q2.IsEmpty=false then begin
    {цикл по горизотам в заданной таблице}
{L}while not frmdm.q2.EOF do begin
    lev_dbar:=frmdm.q2.FieldByName('lev_dbar').AsFloat;
    lev_m:=frmdm.q2.FieldByName('lev_m').AsFloat;

    val:=-9999;
    if frmdm.q2.FieldByName('val').IsNull=false
    then val:=frmdm.q2.FieldByName('val').AsFloat;
    PQF2:=frmdm.q2.FieldByName('PQF2').AsInteger;
    SQF:=frmdm.q2.FieldByName('SQF').AsInteger;
    bottle_number:=-9999;
    if frmdm.q2.FieldByName('bottle_number').IsNull=false
    then bottle_number:=frmdm.q2.FieldByName('bottle_number').AsInteger;
    units_id:=frmdm.q2.FieldByName('units_id').AsInteger;
    instr_id:=frmdm.q2.FieldByName('instrument_id').AsInteger;
    prof_num:=frmdm.q2.FieldByName('profile_number').AsInteger;

    {lat, lon from q1}

    {...five tables have additinal field - counting error}
    if (tbl='P_C14') or (tbl='P_H3') or (tbl='P_HE3') or (tbl='P_HE') or (tbl='P_NEON')
    then begin
       valerr:=-9999;
      if frmdm.q2.FieldByName('valerr').IsNull=false
      then valerr:=frmdm.q2.FieldByName('val').AsFloat;
    end;


    {здесь конвертация единиц базы в единицы по умолчанию GLODAP}



    {объеденяем данные из всех таблиц в динамическом массиве CS}
    {если горизонт уже есть то обновляем поля}
    {если горизонта нет то добавляем}
    {все горизонты (давление+метры), батометры, величины и два флага по всем заданным таблицам }
{ 1}
{P_}if tbl='P_TEMPERATURE' then begin
      s:=s+1;
      setlength(CS,s);
      CS[s-1].lev_dbar:=lev_dbar;
      CS[s-1].lev_m:=lev_m;
      CS[s-1].bottle_number:=bottle_number;
      CS[s-1].temperature_val:=val;
      CS[s-1].temperature_PQF2:=PQF2;
      CS[s-1].temperature_SQF:=SQF;

      CS[s-1].salinity_val:=-9999;
      CS[s-1].salinity_PQF2:=-9999;
      CS[s-1].salinity_SQF:=-9999;
      CS[s-1].oxygen_val:=-9999;
      CS[s-1].oxygen_PQF2:=-9999;
      CS[s-1].oxygen_SQF:=-9999;
      CS[s-1].aou_val:=-9999;
      CS[s-1].aou_PQF2:=-9999;
      CS[s-1].aou_SQF:=-9999;
      CS[s-1].nitrate_val:=-9999;
      CS[s-1].nitrate_PQF2:=-9999;
      CS[s-1].nitrate_SQF:=-9999;
      CS[s-1].nitrite_val:=-9999;
      CS[s-1].nitrite_PQF2:=-9999;
      CS[s-1].nitrite_SQF:=-9999;
      CS[s-1].silicate_val:=-9999;
      CS[s-1].silicate_PQF2:=-9999;
      CS[s-1].silicate_SQF:=-9999;
      CS[s-1].phosphate_val:=-9999;
      CS[s-1].phosphate_PQF2:=-9999;
      CS[s-1].phosphate_SQF:=-9999;
      CS[s-1].tco2_val:=-9999;
      CS[s-1].tco2_PQF2:=-9999;
      CS[s-1].tco2_SQF:=-9999;
      CS[s-1].talk_val:=-9999;
      CS[s-1].talk_PQF2:=-9999;
      CS[s-1].talk_SQF:=-9999;
      CS[s-1].phts25p0_val:=-9999;
      CS[s-1].phts25p0_PQF2:=-9999;
      CS[s-1].phts25p0_SQF:=-9999;
      CS[s-1].phtsinsitutp_val:=-9999;
      CS[s-1].phtsinsitutp_PQF2:=-9999;
      CS[s-1].phtsinsitutp_SQF:=-9999;
      CS[s-1].cfc11_val:=-9999;
      CS[s-1].cfc11_PQF2:=-9999;
      CS[s-1].cfc11_SQF:=-9999;
      CS[s-1].pcfc11_val:=-9999;
      CS[s-1].pcfc11_PQF2:=-9999;
      CS[s-1].pcfc11_SQF:=-9999;
      CS[s-1].cfc12_val:=-9999;
      CS[s-1].cfc12_PQF2:=-9999;
      CS[s-1].cfc12_SQF:=-9999;
      CS[s-1].pcfc12_val:=-9999;
      CS[s-1].pcfc12_PQF2:=-9999;
      CS[s-1].pcfc12_SQF:=-9999;
      CS[s-1].cfc113_val:=-9999;
      CS[s-1].cfc113_PQF2:=-9999;
      CS[s-1].cfc113_SQF:=-9999;
      CS[s-1].pcfc113_val:=-9999;
      CS[s-1].pcfc113_PQF2:=-9999;
      CS[s-1].pcfc113_SQF:=-9999;
      CS[s-1].ccl4_val:=-9999;
      CS[s-1].ccl4_PQF2:=-9999;
      CS[s-1].ccl4_SQF:=-9999;
      CS[s-1].pccl4_val:=-9999;
      CS[s-1].pccl4_PQF2:=-9999;
      CS[s-1].pccl4_SQF:=-9999;
      CS[s-1].sf6_val:=-9999;
      CS[s-1].sf6_PQF2:=-9999;
      CS[s-1].sf6_SQF:=-9999;
      CS[s-1].psf6_val:=-9999;
      CS[s-1].psf6_PQF2:=-9999;
      CS[s-1].psf6_SQF:=-9999;
      CS[s-1].c13_val:=-9999;
      CS[s-1].c13_PQF2:=-9999;
      CS[s-1].c13_SQF:=-9999;
      CS[s-1].c14_val:=-9999;
      CS[s-1].c14_err:=-9999;
      CS[s-1].c14_PQF2:=-9999;
      CS[s-1].c14_SQF:=-9999;
      CS[s-1].h3_val:=-9999;
      CS[s-1].h3_err:=-9999;
      CS[s-1].h3_PQF2:=-9999;
      CS[s-1].h3_SQF:=-9999;
      CS[s-1].he_val:=-9999;
      CS[s-1].he_err:=-9999;
      CS[s-1].he_PQF2:=-9999;
      CS[s-1].he_SQF:=-9999;
      CS[s-1].neon_val:=-9999;
      CS[s-1].neon_err:=-9999;
      CS[s-1].neon_PQF2:=-9999;
      CS[s-1].neon_SQF:=-9999;
      CS[s-1].o18_val:=-9999;
      CS[s-1].o18_PQF2:=-9999;
      CS[s-1].o18_SQF:=-9999;
      CS[s-1].toc_val:=-9999;
      CS[s-1].toc_PQF2:=-9999;
      CS[s-1].toc_SQF:=-9999;
      CS[s-1].doc_val:=-9999;
      CS[s-1].doc_PQF2:=-9999;
      CS[s-1].doc_SQF:=-9999;
      CS[s-1].don_val:=-9999;
      CS[s-1].don_PQF2:=-9999;
      CS[s-1].don_SQF:=-9999;
      CS[s-1].tdn_val:=-9999;
      CS[s-1].tdn_PQF2:=-9999;
      CS[s-1].tdn_SQF:=-9999;
      CS[s-1].chlorophyll_val:=-9999;
      CS[s-1].chlorophyll_PQF2:=-9999;
      CS[s-1].chlorophyll_SQF:=-9999;

{P_}end;

{ 2}
{P_}if tbl='P_SALINITY' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i; end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].salinity_val:=val;
           CS[lev_index].salinity_PQF2:=PQF2;
           CS[lev_index].salinity_SQF:=SQF;
        end;
        if new_lev=true then begin
           //showmessage('New level  cruise_id='+inttostr(cruise_id)
           //+' station_id='+inttostr(station_id)+'  '+tbl);
            writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[i].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].salinity_val:=val;
           CS[s-1].salinity_PQF2:=PQF2;
           CS[s-1].salinity_SQF:=SQF;
        end;
{P_}end;

{3}
{P_}if tbl='P_OXYGEN' then begin


   {conversion units_default=3}
      units_def:=3;
{C}if (val<>-9999) and (units_id<>3) then begin
//showmessage('oxygen='+floattostr(val)+'  units_id='+inttostr(units_id));
      isconverted:=false;
      val_rep:=val;
      val_conv:=-9999;
{1}if CheckBox3.Checked then begin

      {writeln(fo4,tbl,
       #9,inttostr(cruise_id),
       #9,'station_id=',inttostr(station_id),
       #9,inttostr(units_id),
       #9,inttostr(units_def),
       #9,floattostr(lev_m),
       #9,floattostr(val),'->',floattostr(val_conv),
       #9,'lat=',floattostr(lat),
       #9,'lon=',floattostr(lon),
       #9,'inst_id=',inttostr(instr_id),
       #9,'prof_num=',inttostr(prof_num));}

     GetDefaultUnitsExact(tbl,units_id,units_def,station_id,instr_id,prof_num,val,lat,lon,lev_m,val_conv,isconverted);
     if isconverted=true then val:=val_conv;
{1}end
{2}else begin
     GetDefaultUnits(tbl,units_id,units_def,val,val_conv,isconverted);
     if isconverted=true then val:=val_conv;
{2}end;

   if isconverted=true then begin
        writeln(fo4,tbl,
        #9,inttostr(cruise_id),
        #9,inttostr(station_id),
        #9,inttostr(units_id),
        #9,inttostr(units_def),
        #9,inttostr(instr_id),
        #9,inttostr(prof_num),
        #9,floattostr(lev_m),
        #9,floattostr(val_rep),
        #9,floattostr(val_conv));
    end;
{C}end;

        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].oxygen_val:=val;
           CS[lev_index].oxygen_PQF2:=PQF2;
           CS[lev_index].oxygen_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].oxygen_val:=val;
           CS[s-1].oxygen_PQF2:=PQF2;
           CS[s-1].oxygen_SQF:=SQF;
        end;
{P_}end;

{4}
{P_}if tbl='P_AOU' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].aou_val:=val;
           CS[lev_index].aou_PQF2:=PQF2;
           CS[lev_index].aou_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].aou_val:=val;
           CS[s-1].aou_PQF2:=PQF2;
           CS[s-1].aou_SQF:=SQF;
        end;
{P_}end;


{5}
{P_}if tbl='P_NITRATE' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].nitrate_val:=val;
           CS[lev_index].nitrate_PQF2:=PQF2;
           CS[lev_index].nitrate_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].nitrate_val:=val;
           CS[s-1].nitrate_PQF2:=PQF2;
           CS[s-1].nitrate_SQF:=SQF;
        end;
{P_}end;


{6}
{P_}if tbl='P_NITRITE' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].nitrite_val:=val;
           CS[lev_index].nitrite_PQF2:=PQF2;
           CS[lev_index].nitrite_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].nitrite_val:=val;
           CS[s-1].nitrite_PQF2:=PQF2;
           CS[s-1].nitrite_SQF:=SQF;
        end;
{P_}end;

{7}
{P_}if tbl='P_SILICATE' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].silicate_val:=val;
           CS[lev_index].silicate_PQF2:=PQF2;
           CS[lev_index].silicate_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].silicate_val:=val;
           CS[s-1].silicate_PQF2:=PQF2;
           CS[s-1].silicate_SQF:=SQF;
        end;
{P_}end;

{8}
{P_}if tbl='P_PHOSPHATE' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].phosphate_val:=val;
           CS[lev_index].phosphate_PQF2:=PQF2;
           CS[lev_index].phosphate_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].phosphate_val:=val;
           CS[s-1].phosphate_PQF2:=PQF2;
           CS[s-1].phosphate_SQF:=SQF;
        end;
{P_}end;


{9}
{P_}if tbl='P_TCO2' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].tco2_val:=val;
           CS[lev_index].tco2_PQF2:=PQF2;
           CS[lev_index].tco2_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].tco2_val:=val;
           CS[s-1].tco2_PQF2:=PQF2;
           CS[s-1].tco2_SQF:=SQF;
        end;
{P_}end;


{10}
{P_}if tbl='P_ALKALINITY' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].talk_val:=val;
           CS[lev_index].talk_PQF2:=PQF2;
           CS[lev_index].talk_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].talk_val:=val;
           CS[s-1].talk_PQF2:=PQF2;
           CS[s-1].talk_SQF:=SQF;
        end;
{P_}end;


{11}
{P_}if tbl='P_PHTS25P0' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].phts25p0_val:=val;
           CS[lev_index].phts25p0_PQF2:=PQF2;
           CS[lev_index].phts25p0_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].phts25p0_val:=val;
           CS[s-1].phts25p0_PQF2:=PQF2;
           CS[s-1].phts25p0_SQF:=SQF;
        end;
{P_}end;


{12}
{P_}if tbl='P_PHTSINSITUTP' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].phtsinsitutp_val:=val;
           CS[lev_index].phtsinsitutp_PQF2:=PQF2;
           CS[lev_index].phtsinsitutp_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].phtsinsitutp_val:=val;
           CS[s-1].phtsinsitutp_PQF2:=PQF2;
           CS[s-1].phtsinsitutp_SQF:=SQF;
        end;
{P_}end;


{13}
{P_}if tbl='P_CFC11' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].cfc11_val:=val;
           CS[lev_index].cfc11_PQF2:=PQF2;
           CS[lev_index].cfc11_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].cfc11_val:=val;
           CS[s-1].cfc11_PQF2:=PQF2;
           CS[s-1].cfc11_SQF:=SQF;
        end;
{P_}end;


{14}
{P_}if tbl='P_PCFC11' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].pcfc11_val:=val;
           CS[lev_index].pcfc11_PQF2:=PQF2;
           CS[lev_index].pcfc11_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].pcfc11_val:=val;
           CS[s-1].pcfc11_PQF2:=PQF2;
           CS[s-1].pcfc11_SQF:=SQF;
        end;
{P_}end;


{15}
{P_}if tbl='P_CFC12' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].cfc12_val:=val;
           CS[lev_index].cfc12_PQF2:=PQF2;
           CS[lev_index].cfc12_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].cfc12_val:=val;
           CS[s-1].cfc12_PQF2:=PQF2;
           CS[s-1].cfc12_SQF:=SQF;
        end;
{P_}end;


{16}
{P_}if tbl='P_PCFC12' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].pcfc12_val:=val;
           CS[lev_index].pcfc12_PQF2:=PQF2;
           CS[lev_index].pcfc12_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].pcfc12_val:=val;
           CS[s-1].pcfc12_PQF2:=PQF2;
           CS[s-1].pcfc12_SQF:=SQF;
        end;
{P_}end;


{17}
{P_}if tbl='P_CFC113' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].cfc113_val:=val;
           CS[lev_index].cfc113_PQF2:=PQF2;
           CS[lev_index].cfc113_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].cfc113_val:=val;
           CS[s-1].cfc113_PQF2:=PQF2;
           CS[s-1].cfc113_SQF:=SQF;
        end;
{P_}end;


{18}
{P_}if tbl='P_PCFC113' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].pcfc113_val:=val;
           CS[lev_index].pcfc113_PQF2:=PQF2;
           CS[lev_index].pcfc113_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].pcfc113_val:=val;
           CS[s-1].pcfc113_PQF2:=PQF2;
           CS[s-1].pcfc113_SQF:=SQF;
        end;
{P_}end;


{19}
{P_}if tbl='P_CCL4' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].ccl4_val:=val;
           CS[lev_index].ccl4_PQF2:=PQF2;
           CS[lev_index].ccl4_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].ccl4_val:=val;
           CS[s-1].ccl4_PQF2:=PQF2;
           CS[s-1].ccl4_SQF:=SQF;
        end;
{P_}end;


{20}
{P_}if tbl='P_PCCL4' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].pccl4_val:=val;
           CS[lev_index].pccl4_PQF2:=PQF2;
           CS[lev_index].pccl4_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].pccl4_val:=val;
           CS[s-1].pccl4_PQF2:=PQF2;
           CS[s-1].pccl4_SQF:=SQF;
        end;
{P_}end;


{21}
{P_}if tbl='P_SF6' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].sf6_val:=val;
           CS[lev_index].sf6_PQF2:=PQF2;
           CS[lev_index].sf6_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].sf6_val:=val;
           CS[s-1].sf6_PQF2:=PQF2;
           CS[s-1].sf6_SQF:=SQF;
        end;
{P_}end;


{22}
{P_}if tbl='P_PSF6' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].psf6_val:=val;
           CS[lev_index].psf6_PQF2:=PQF2;
           CS[lev_index].psf6_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].psf6_val:=val;
           CS[s-1].psf6_PQF2:=PQF2;
           CS[s-1].psf6_SQF:=SQF;
        end;
{P_}end;


{23}
{P_}if tbl='P_C13' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].c13_val:=val;
           CS[lev_index].c13_PQF2:=PQF2;
           CS[lev_index].c13_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].c13_val:=val;
           CS[s-1].c13_PQF2:=PQF2;
           CS[s-1].c13_SQF:=SQF;
        end;
{P_}end;


{24}
{P_}if tbl='P_C14' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].c14_val:=val;
           CS[lev_index].c14_err:=valerr;
           CS[lev_index].c14_PQF2:=PQF2;
           CS[lev_index].c14_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].c14_val:=val;
           CS[s-1].c14_err:=valerr;
           CS[s-1].c14_PQF2:=PQF2;
           CS[s-1].c14_SQF:=SQF;
        end;
{P_}end;


{25}
{P_}if tbl='P_H3' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].h3_val:=val;
           CS[lev_index].h3_err:=valerr;
           CS[lev_index].h3_PQF2:=PQF2;
           CS[lev_index].h3_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].h3_val:=val;
           CS[s-1].h3_err:=valerr;
           CS[s-1].h3_PQF2:=PQF2;
           CS[s-1].h3_SQF:=SQF;
        end;
{P_}end;


{26}
{P_}if tbl='P_HE3' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].he3_val:=val;
           CS[lev_index].he3_err:=valerr;
           CS[lev_index].he3_PQF2:=PQF2;
           CS[lev_index].he3_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].he3_val:=val;
           CS[s-1].he3_err:=valerr;
           CS[s-1].he3_PQF2:=PQF2;
           CS[s-1].he3_SQF:=SQF;
        end;
{P_}end;


{27}
{P_}if tbl='P_HE' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].he_val:=val;
           CS[lev_index].he_err:=valerr;
           CS[lev_index].he_PQF2:=PQF2;
           CS[lev_index].he_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].he_val:=val;
           CS[s-1].he_err:=valerr;
           CS[s-1].he_PQF2:=PQF2;
           CS[s-1].he_SQF:=SQF;
        end;
{P_}end;


{28}
{P_}if tbl='P_NEON' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].neon_val:=val;
           CS[lev_index].neon_err:=valerr;
           CS[lev_index].neon_PQF2:=PQF2;
           CS[lev_index].neon_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].neon_val:=val;
           CS[s-1].neon_err:=valerr;
           CS[s-1].neon_PQF2:=PQF2;
           CS[s-1].neon_SQF:=SQF;
        end;
{P_}end;


{29}
{P_}if tbl='P_O18' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].o18_val:=val;
           CS[lev_index].o18_PQF2:=PQF2;
           CS[lev_index].o18_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].o18_val:=val;
           CS[s-1].o18_PQF2:=PQF2;
           CS[s-1].o18_SQF:=SQF;
        end;
{P_}end;


{30}
{P_}if tbl='P_TOC' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].toc_val:=val;
           CS[lev_index].toc_PQF2:=PQF2;
           CS[lev_index].toc_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].toc_val:=val;
           CS[s-1].toc_PQF2:=PQF2;
           CS[s-1].toc_SQF:=SQF;
        end;
{P_}end;


{31}
{P_}if tbl='P_DOC' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].doc_val:=val;
           CS[lev_index].doc_PQF2:=PQF2;
           CS[lev_index].doc_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].doc_val:=val;
           CS[s-1].doc_PQF2:=PQF2;
           CS[s-1].doc_SQF:=SQF;
        end;
{P_}end;


{32}
{P_}if tbl='P_DON' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].don_val:=val;
           CS[lev_index].don_PQF2:=PQF2;
           CS[lev_index].don_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].don_val:=val;
           CS[s-1].don_PQF2:=PQF2;
           CS[s-1].don_SQF:=SQF;
        end;
{P_}end;


{33}
{P_}if tbl='P_TDN' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].tdn_val:=val;
           CS[lev_index].tdn_PQF2:=PQF2;
           CS[lev_index].tdn_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].tdn_val:=val;
           CS[s-1].tdn_PQF2:=PQF2;
           CS[s-1].tdn_SQF:=SQF;
        end;
{P_}end;


{34}
{P_}if tbl='P_CHLOROPHYLL' then begin
        new_lev:=true;
    {cs}for i:=1 to High(CS) do begin
        if lev_dbar=CS[i].lev_dbar then begin new_lev:=false; lev_index:=i end;
    {cs}end;
        {update CS}
        if new_lev=false then begin
           CS[lev_index].chlorophyll_val:=val;
           CS[lev_index].chlorophyll_PQF2:=PQF2;
           CS[lev_index].chlorophyll_SQF:=SQF;
        end;
        if new_lev=true then begin
           writeln(fo3,inttostr(cruise_id),
           #9,inttostr(station_id),
           #9,tbl,
           #9,floattostr(lev_dbar),
           #9,floattostr(lev_m));
           s:=s+1;
           setlength(CS,s);
           CS[s-1].lev_dbar:=lev_dbar;
           CS[s-1].lev_m:=lev_m;
           CS[s-1].bottle_number:=bottle_number;
           CS[s-1].chlorophyll_val:=val;
           CS[s-1].chlorophyll_PQF2:=PQF2;
           CS[s-1].chlorophyll_SQF:=SQF;
        end;
{P_}end;
      {next table}
      frmdm.q2.Next;
{L}end;
{EMPTY}end;

     frmdm.q2.Close;
{T}end;

{.....UPLOAD INTO DATA.CSV}
{LEV}for klev:=1 to High(CS) do begin

    {ARE: We should use data from cruises with that has at least one of the following
    variables in addition to T+S: O2, PO4, NO3, Si, Alk, DIC; i.e. at least
    one of the biogeochemical variables of interest}
    {25.08.2020 I would definitely prefer using calculated density. }

      v_comp:=false; {variables composition at the depth level}

     if (CS[klev].temperature_val<>-9999) and (CS[klev].salinity_val<>-9999) then begin
       if (CS[klev].oxygen_val<>-9999) then v_comp:=true;
       if (CS[klev].phosphate_val<>-9999) then v_comp:=true;
       if (CS[klev].nitrate_val<>-9999) then v_comp:=true;
       if (CS[klev].silicate_val<>-9999) then v_comp:=true;
       if (CS[klev].talk_val<>-9999) then v_comp:=true;
       if (CS[klev].tco2_val<>-9999) then v_comp:=true;
     end;

{COMP}if v_comp=true then begin
     {...computed values THETA, SIGMA}
     theta:=-9999;
     sigma0:=-9999;
     sigma1:=-9999;
     sigma2:=-9999;
     sigma3:=-9999;
     sigma4:=-9999;
     gamma:=-9999;


{.....CALCULATED VALUES}
     lev_dbar:=CS[klev].lev_dbar;
     sp:=CS[klev].salinity_val;            //practical salinity
     t_insitu:=CS[klev].temperature_val;

    if (sp<>-9999) and (t_insitu<>-9999) then begin
     {absolute salinity (sa) from practical salinity (sp)}
      gsw_sa_from_sp:=Tgsw_z_from_p(GetProcedureAddress(libgswteos, 'gsw_sa_from_sp'));
      sa  := gsw_sa_from_sp(sp, lev_dbar, lon, lat); // absolute salinity

     {potential temperature}
      gsw_pt0_from_t:=Tgsw_pt0_from_t(GetProcedureAddress(libgswteos, 'gsw_pt0_from_t'));
      theta:=gsw_pt0_from_t(sa,t_insitu,lev_dbar);

      {conservative temperature}
      gsw_ct_from_t:=Tgsw_ct_from_t(GetProcedureAddress(libgswteos, 'gsw_ct_from_t'));
      ct:=gsw_ct_from_t(sa, t_insitu, lev_dbar);

      {... in-sity density}
      //gdv:=-9;
      //gdv:=GibbsSeaWater.gsw_rho_t_exact(sp,tv,lev_dbar);
      //gdv_sa:=GibbsSeaWater.gsw_rho_t_exact(sa,tv,lev_dbar);

      {... potential density}
     {sa     : Absolute Salinity                               [g/kg]
      t      : in-situ temperature                             [deg C]
      p      : sea pressure                                    [dbar]
      p_ref  : reference sea pressure                          [dbar]
      gsw_pot_rho_t_exact : potential density                  [kg/m^3]}

      //sigma0:=gsw_pot_rho_t_exact(sp,t_insitu,lev_dbar,0)-1000;
      {sigma0:=gsw_pot_rho_t_exact(sa,t_insitu,lev_dbar,0)-1000;
      sigma1:=gsw_pot_rho_t_exact(sa,t_insitu,lev_dbar,1000)-1000;
      sigma2:=gsw_pot_rho_t_exact(sa,t_insitu,lev_dbar,2000)-1000;
      sigma3:=gsw_pot_rho_t_exact(sa,t_insitu,lev_dbar,3000)-1000;
      sigma4:=gsw_pot_rho_t_exact(sa,t_insitu,lev_dbar,4000)-1000;}

      {sigma0:=gsw_pot_rho_t_exact(sa,theta,lev_dbar,0)-1000;
      sigma1:=gsw_pot_rho_t_exact(sa,theta,lev_dbar,1000)-1000;
      sigma2:=gsw_pot_rho_t_exact(sa,theta,lev_dbar,2000)-1000;
      sigma3:=gsw_pot_rho_t_exact(sa,theta,lev_dbar,3000)-1000;
      sigma4:=gsw_pot_rho_t_exact(sa,theta,lev_dbar,4000)-1000;}

     {potential density anomaly with reference to surface}
      gsw_sigma0:=Tgsw_sigma0(GetProcedureAddress(libgswteos, 'gsw_sigma0'));
      sigma0:=gsw_sigma0(sa,ct);
     {potential density anomaly with reference pressure of 1000 dbar}
      gsw_sigma1:=Tgsw_sigma1(GetProcedureAddress(libgswteos, 'gsw_sigma1'));
      sigma1:=gsw_sigma1(sa,ct);
     {potential density anomaly with reference pressure of 2000 dbar}
      gsw_sigma2:=Tgsw_sigma2(GetProcedureAddress(libgswteos, 'gsw_sigma2'));
      sigma2:=gsw_sigma2(sa,ct);
     {potential density anomaly with reference pressure of 3000 dbar}
      gsw_sigma3:=Tgsw_sigma3(GetProcedureAddress(libgswteos, 'gsw_sigma3'));
      sigma3:=gsw_sigma3(sa,ct);
     {potential density anomaly with reference pressure of 4000 dbar}
      gsw_sigma4:=Tgsw_sigma4(GetProcedureAddress(libgswteos, 'gsw_sigma4'));
      sigma4:=gsw_sigma4(sa,ct);
    end;


{.....PQF2 CONVERSION OCEAN.FDB -> WOCE}
{QF}if CheckBox2.Checked then begin
      qf_woce:=9;

      qf_ocean:=CS[klev].temperature_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].temperature_PQF2:=qf_woce;

      qf_ocean:=CS[klev].salinity_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].salinity_PQF2:=qf_woce;

      qf_ocean:=CS[klev].oxygen_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].oxygen_PQF2:=qf_woce;

      qf_ocean:=CS[klev].aou_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].aou_PQF2:=qf_woce;

      qf_ocean:=CS[klev].nitrate_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].nitrate_PQF2:=qf_woce;

      qf_ocean:=CS[klev].nitrite_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].nitrite_PQF2:=qf_woce;

      qf_ocean:=CS[klev].silicate_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].silicate_PQF2:=qf_woce;

      qf_ocean:=CS[klev].phosphate_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].phosphate_PQF2:=qf_woce;

      qf_ocean:=CS[klev].tco2_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].tco2_PQF2:=qf_woce;

      qf_ocean:=CS[klev].talk_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].talk_PQF2:=qf_woce;

      qf_ocean:=CS[klev].phts25p0_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].phts25p0_PQF2:=qf_woce;

      qf_ocean:=CS[klev].phtsinsitutp_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].phtsinsitutp_PQF2:=qf_woce;

      qf_ocean:=CS[klev].cfc11_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].cfc11_PQF2:=qf_woce;

      qf_ocean:=CS[klev].pcfc11_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].pcfc11_PQF2:=qf_woce;

      qf_ocean:=CS[klev].cfc12_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].cfc12_PQF2:=qf_woce;

      qf_ocean:=CS[klev].pcfc12_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].pcfc12_PQF2:=qf_woce;

      qf_ocean:=CS[klev].cfc113_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].cfc113_PQF2:=qf_woce;

      qf_ocean:=CS[klev].pcfc113_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].pcfc113_PQF2:=qf_woce;

      qf_ocean:=CS[klev].ccl4_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].ccl4_PQF2:=qf_woce;

      qf_ocean:=CS[klev].pccl4_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].pccl4_PQF2:=qf_woce;

      qf_ocean:=CS[klev].sf6_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].sf6_PQF2:=qf_woce;

      qf_ocean:=CS[klev].psf6_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].psf6_PQF2:=qf_woce;

      qf_ocean:=CS[klev].c13_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].c13_PQF2:=qf_woce;

      qf_ocean:=CS[klev].c14_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].c14_PQF2:=qf_woce;

      qf_ocean:=CS[klev].h3_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].h3_PQF2:=qf_woce;

      qf_ocean:=CS[klev].he_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].he_PQF2:=qf_woce;

      qf_ocean:=CS[klev].neon_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].neon_PQF2:=qf_woce;

      qf_ocean:=CS[klev].o18_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].o18_PQF2:=qf_woce;

      qf_ocean:=CS[klev].toc_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].toc_PQF2:=qf_woce;

      qf_ocean:=CS[klev].doc_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].doc_PQF2:=qf_woce;

      qf_ocean:=CS[klev].don_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].don_PQF2:=qf_woce;

      qf_ocean:=CS[klev].tdn_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].tdn_PQF2:=qf_woce;

      qf_ocean:=CS[klev].chlorophyll_PQF2;
      qf_ocean_to_woce(qf_ocean,qf_woce);
      CS[klev].chlorophyll_PQF2:=qf_woce;

     {SQF should not be changed}
     {there are only 0 or 1 in P_ tables}

{QF}end;

     str:=str_md                              {number of related fields in data file}
     +inttostr(CS[klev].bottle_number)+','    //P_TEMPERATURE(5)
     //+'  dbar: '
     +floattostr(CS[klev].lev_dbar)+','
     +floattostr(CS[klev].lev_m)+','
     //+'  1_temp: '
     +floattostr(CS[klev].temperature_val)+','
     +floattostrF(theta,ffFixed,7,3)+','
     //+'  2_salt: '
     +floattostr(CS[klev].salinity_val)+','  //P_SALINITY(9)
     +inttostr(CS[klev].salinity_PQF2)+','
     +inttostr(CS[klev].salinity_SQF)+','
     +floattostrF(sigma0,ffFixed,7,3)+','
     //+inttostr(CS[klev].salinity_PQF2)+','
     +floattostrF(sigma1,ffFixed,7,3)+','
     //+inttostr(CS[klev].salinity_PQF2)+','
     +floattostrF(sigma2,ffFixed,7,3)+','
     //+inttostr(CS[klev].salinity_PQF2)+','
     +floattostrF(sigma3,ffFixed,7,3)+','
     //+inttostr(CS[klev].salinity_PQF2)+','
     +floattostrF(sigma4,ffFixed,7,3)+','
     //+inttostr(CS[klev].salinity_PQF2)+','
     +floattostrF(gamma,ffFixed,7,3)+','
     //+inttostr(CS[klev].salinity_PQF2)+','
     //+'  3_oxygen: '
     +floattostr(CS[klev].oxygen_val)+','  //P_OXYGEN(3)
     +inttostr(CS[klev].oxygen_PQF2)+','
     +inttostr(CS[klev].oxygen_SQF)+','
     //+'  4_aou: '
     +floattostr(CS[klev].aou_val)+','  //P_AOU(2)
     +inttostr(CS[klev].aou_PQF2)+','
     //+'  5_nitrate: '
     +floattostr(CS[klev].nitrate_val)+','  //P_NITRATE(3)
     +inttostr(CS[klev].nitrate_PQF2)+','
     +inttostr(CS[klev].nitrate_SQF)+','
     //+'  6_nitrite: '
     +floattostr(CS[klev].nitrite_val)+','  //P_NITRITE(2)
     +inttostr(CS[klev].nitrite_PQF2)+','
     //+'  7_silicate: '
     +floattostr(CS[klev].silicate_val)+','  //P_SILICATE(3)
     +inttostr(CS[klev].silicate_PQF2)+','
     +inttostr(CS[klev].silicate_SQF)+','
     //+'  8_phosphate: '
     +floattostr(CS[klev].phosphate_val)+','  //P_PHOSPHATE(3)
     +inttostr(CS[klev].phosphate_PQF2)+','
     +inttostr(CS[klev].phosphate_SQF)+','
     //+'  9_tco2: '
     +floattostr(CS[klev].tco2_val)+','  //P_TCO2(3)
     +inttostr(CS[klev].tco2_PQF2)+','
     +inttostr(CS[klev].tco2_SQF)+','
     //+'  10_talk: '
     +floattostr(CS[klev].talk_val)+','  //P_ALKALINITY(3)
     +inttostr(CS[klev].talk_PQF2)+','
     +inttostr(CS[klev].talk_SQF)+','
     //+'  11_phts25p0: '
     +floattostr(CS[klev].phts25p0_val)+','  //P_PHTS25P0(3)
     +inttostr(CS[klev].phts25p0_PQF2)+','
     +inttostr(CS[klev].phts25p0_SQF)+','
     //+'  12_phtsinsitutp: '
     +floattostr(CS[klev].phtsinsitutp_val)+','  //P_PHTSINSITUTP(2)
     +inttostr(CS[klev].phtsinsitutp_PQF2)+','
     //+inttostr(CS[klev].phtsinsitutp_SQF)+',' //один флаг на оба PH
     //+'  13_cfc11: ' +'  14_pcfc11: '
     +floattostr(CS[klev].cfc11_val)+','  //P_CFC11+P_PCFC11(4): cfc11,pcfc11,cfc11f,cfc11qc
     +floattostr(CS[klev].pcfc11_val)+','
     +inttostr(CS[klev].cfc11_PQF2)+','
     +inttostr(CS[klev].cfc11_SQF)+','
     //+'  14_pcfc11: '
     //+floattostr(CS[klev].pcfc11_val)+','
     //+inttostr(CS[klev].pcfc11_PQF2)+','
     //+'  15_cfc12: ' +'  16_pcfc12: '
     +floattostr(CS[klev].cfc12_val)+','  //P_CFC12+P_PCFC12(4): cfc12,pcfc12,cfc12f,cfc12qc
     +floattostr(CS[klev].pcfc12_val)+','
     +inttostr(CS[klev].cfc12_PQF2)+','
     +inttostr(CS[klev].cfc12_SQF)+','
     //+'  16_pcfc12: ' +'  18_pcfc113: '
     //+floattostr(CS[klev].pcfc12_val)+','  //P_PCFC12(2)
     //+inttostr(CS[klev].pcfc12_PQF2)+','
     //+'  17_cfc113: '
     +floattostr(CS[klev].cfc113_val)+','  //P_CFC113+P_PCFC113(4): cfc113,pcfc113,cfc113f,cfc113qc
     +floattostr(CS[klev].pcfc113_val)+','
     +inttostr(CS[klev].cfc113_PQF2)+','
     +inttostr(CS[klev].cfc113_SQF)+','
     //+'  18_pcfc113: '
     //+floattostr(CS[klev].pcfc113_val)+','  //P_PCFC113(2)
     //+inttostr(CS[klev].pcfc113_PQF2)+','
     //+'  19_ccl4: ' +'  20_pccl4: '
     +floattostr(CS[klev].ccl4_val)+','  //P_CCL4+P_PCCL4(4): CCL4,pCCL4,CCL4f,CCL4qc
     +floattostr(CS[klev].pccl4_val)+','
     +inttostr(CS[klev].ccl4_PQF2)+','
     +inttostr(CS[klev].ccl4_SQF)+','
     //+'  20_pccl4: '
     //+floattostr(CS[klev].pccl4_val)+','  //P_PCCL4(2)
     //+inttostr(CS[klev].pccl4_PQF2)+','
     //+'  21_sf6: '+'  22_sf6: '
     +floattostr(CS[klev].sf6_val)+','  //P_SF6+P_PSF6(3)
     +floattostr(CS[klev].psf6_val)+','
     +inttostr(CS[klev].sf6_PQF2)+','
     //+'  22_sf6: '
     //+floattostr(CS[klev].psf6_val)+','  //P_PSF6(2)
     //+inttostr(CS[klev].psf6_PQF2)+','
     //+'  23_c13: '
     +floattostr(CS[klev].c13_val)+','  //P_C13(2)
     +inttostr(CS[klev].c13_PQF2)+','
     +inttostr(CS[klev].c13_SQF)+','
     //+'  24_c14: '
     +floattostr(CS[klev].c14_val)+','  //P_C14(3 val+QF+err)
     +inttostr(CS[klev].c14_PQF2)+','
     +floattostr(CS[klev].c14_err)+','
     //+'  25_h3: '
     +floattostr(CS[klev].h3_val)+','  //P_H3(3 val+QF+err)
     +inttostr(CS[klev].h3_PQF2)+','
     +floattostr(CS[klev].h3_err)+','
     //+'  26_he3: '
     +floattostr(CS[klev].he3_val)+','  //P_HE3(3 val+QF+err)
     +inttostr(CS[klev].he3_PQF2)+','
     +floattostr(CS[klev].he3_err)+','
     //+'  27_he3: '
     +floattostr(CS[klev].he_val)+','  //P_HE(3 val+QF+err)
     +inttostr(CS[klev].he_PQF2)+','
     +floattostr(CS[klev].he_err)+','
     //+'  28_neon: '
     +floattostr(CS[klev].neon_val)+','  //P_NEON(3 val+QF+err)
     +inttostr(CS[klev].neon_PQF2)+','
     +floattostr(CS[klev].neon_err)+','
     //+'  29_o18: '
     +floattostr(CS[klev].o18_val)+','  //P_O18(2)
     +inttostr(CS[klev].o18_PQF2)+','
     //+'  30_toc: '
     +floattostr(CS[klev].toc_val)+','  //P_TOC(2)
     +inttostr(CS[klev].toc_PQF2)+','
     //+'  31_doc: '
     +floattostr(CS[klev].doc_val)+','  //P_DOC(2)
     +inttostr(CS[klev].doc_PQF2)+','
     //+'  32_doc: '
     +floattostr(CS[klev].don_val)+','  //P_DON(2)
     +inttostr(CS[klev].don_PQF2)+','
     //+'  33_tdn: '
     +floattostr(CS[klev].tdn_val)+','  //P_TDN(2)
     +inttostr(CS[klev].tdn_PQF2)+','
     //+'  34_chlorophyll: '
     +floattostr(CS[klev].chlorophyll_val)+','  //P_CHLOROPHYLL(2)
     +inttostr(CS[klev].chlorophyll_PQF2)
     ;

     writeln(fo2,str);

{COMP}end;
{LEV}end;


      frmdm.q1.Next;
{st}end;
      frmdm.q1.Close;
{.....data file end}

{DUP}end;
     frmdm.QCruise.Next;
{QC}end;
     closefile(fo1);
     closefile(fo2);
     closefile(fo3);
     closefile(fo4);

    DT2:=NOW;
    memo1.Lines.Add('');
    memo1.Lines.Add('...cruises# ='+inttostr(count_cruises));
    memo1.Lines.Add('...stations#='+inttostr(count_stations));
    memo1.Lines.Add('...stop: '+datetimetostr(DT2));
    memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;


procedure TfrmExport_CIA.qf_ocean_to_woce(qf_ocean:integer; var qf_woce:integer);
begin
    {WOCE flags according Table 1 in GLODAP article}
    if qf_ocean =-9999 then qf_woce:=9; //there is no sample -> data not received/not used/sample not drawn/no data
    if qf_ocean =0     then qf_woce:=9; //not checked -> data not received/not used/sample not drawn/no data
    if qf_ocean =1     then qf_woce:=4; //        bad -> bad/not used
    if qf_ocean =2     then qf_woce:=3; // suspitious -> questionable/not used
    if qf_ocean =3     then qf_woce:=0; // calculated -> not used/interpolated or calculated value
    if qf_ocean>=4     then qf_woce:=2; // acceptable -> acceptable
end;


end.

