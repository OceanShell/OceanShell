//First of all, you need to create a new database
//as a clone of an existing database with additional variables

//Then you need to populate the CRUISE DBT in the "cruises" tab

//Then MD and Data have to be uploaded from GLODAPv2.2021_Merged_Master_File.csv
//in "main" tab

// module utilize several dynamical arrays
// GMD: to hold MD from GLODAP master file to devide file on stations
// GDBC: GLODAP Database considence to link columns in the file with DB tables
// NewSt: contains line numbers from file where new stations begin
// GSt: one station  size=[lev x 106]=[number of depth levels at station x number of columns in the file]
// StCast: casts at station

{steps in btnDownloadClick
#A: create GDBC: col/tbl_name/tbl_type/unit_id (columns with variables only)
#B: create GHeader from file header (first line)
#C1: create GMD: G_line/G_cruise/G_st/G_cast
#C2: create NewSt: :array of integer;
#C3: cruises and stations statistics
     output into file: kst/g_cruise/g_st/NewSt[kst]/stlevn/cast_min->cast_max/
     dt_min->dt_max/lat_min->lat_max/lon_min->lon_max
#D:  create GSt (to hold all data for one station)
#D1: create StCasts (to determine the number (and numbers)of casts for each GLODAP station)
#D2: sort StCasts
#F1: devide GSt on casts and populate STATION
#F2: populate STATION
#F3: populate P_ tables}

{steps in btnFixedStationsClick
#FS1: populate STATION from frmdm.Q
#FS2: populate FSTATION from STATION using coordinates limits
#FS3: test/populate ENTRY using arbitrarily defined time series constraints
#FS4: populate STATION_ENTRY using arbitrarily defined time series constraints
#FS5 update station_amount in ENTRY from STATION_ENTRY
#FS6: assign entries as cruises (optional)}




unit osload_GLODAP_v2_2021_product;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Buttons, comobj, variants, DateUtils, dynlibs;



type

  { TfrmloadGLODAP_v2_2021_product }

  TfrmloadGLODAP_v2_2021_product = class(TForm)
    btnFixedStations: TBitBtn;
    btnUpdateCruiseTable: TBitBtn;
    btnDownload: TBitBtn;
    btnPopulateCruiseTable: TBitBtn;
    btnUpdateExcelTable: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    procedure btnDownloadClick(Sender: TObject);
    procedure btnFixedStationsClick(Sender: TObject);
    procedure btnPopulateCruiseTableClick(Sender: TObject);
    procedure btnUpdateCruiseTableClick(Sender: TObject);
    procedure btnUpdateExcelTableClick(Sender: TObject);
  private

  public

  end;

var
  frmloadGLODAP_v2_2021_product: TfrmloadGLODAP_v2_2021_product;
  DT1,DT2 :TDateTime;
  fi,fo :text;


implementation

uses osmain, dm, procedures, GibbsSeaWater;

{$R *.lfm}

{ TfrmloadGLODAP_v2_2021_product }

procedure TfrmloadGLODAP_v2_2021_product.btnUpdateExcelTableClick(Sender: TObject);
var
XLApp: OLEVariant;
i,p,p1,p2,mik,y,gcrn,np: integer;
platform_id :integer;
expocode,ship_name :string;
gcruise_dates,ds_str,de_str,dsN_str,deN_str :string;
d_str,m_str,y_str :string;
excel_table,gship_name: variant;
nodc_code :string[4];
two_dates,new_format :boolean;
ds,de :TDateTime;
begin

DT1:=NOW;
memo1.Lines.Add('...start [GLODAP cruise table update]: '+datetimetostr(DT1));

excel_table:='c:\Users\Alexa\AK\datasets\GLODAP\v2.2021\GLODAPCruiseTable.xlsx';
memo1.Lines.Add('Exel file: '+excel_table);

 try
  XLApp := CreateOleObject('Excel.Application');
  XLApp.Visible := False;
  XLApp.DisplayAlerts := False;
 except
  Showmessage('MS Excel is not installed');
  Exit;
 end;

   label1.Visible:=true;

{T}try
     XLApp.Workbooks.Open(excel_table); //open the workbook
     y:=1; //skip header
     mik:=0;
{r}repeat
     inc(y); //row

     {...GLODAP cruise number }
     if trystrtoint(XLApp.Cells[y,1].Value,gcrn) then gcrn :=XLApp.Cells[y,1].Value else gcrn:=-9999;

     ds:=strtodate('1.01.1900');
     de:=strtodate('1.01.1900');
     two_dates:=false;
     new_format:=true;

     {...check for empty strings}
{C}if gcrn<>-9999 then begin
     inc(mik);
     label1.Caption:='cruise# '+inttostr(mik);
     Application.ProcessMessages;

     {...read}
     expocode:=XLApp.Cells[y,2].Value;  //expocode
     nodc_code:=copy(expocode,1,4);
     gcruise_dates:=XLApp.Cells[y,7].Value;
     gship_name:=XLApp.Cells[y,10].Value;  //expocode

       platform_id:=1;
       ship_name:='';
     with frmdm.q1 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select id, name from PLATFORM ');
       SQL.Add(' where nodc_code=:nodc_code ');
       ParamByName('nodc_code').AsString:=nodc_code;
       Open;
       platform_id:=FieldByName('id').AsInteger;
       ship_name:=FieldByName('name').AsString;
       Close;
     end;

       if ship_name='' then begin
            ship_name:='UNKNOWN';
            platform_id:=1; //UNKNOWN ship and country
       end;

     {...try convert cruise end date}
       p:=0; // position of -
     for i:=1 to length(gcruise_dates) do begin
       if gcruise_dates[i]='-' then p:=i;
       if gcruise_dates[i]=';' then two_dates:=true;
       if gcruise_dates[i]='/' then new_format:=false;
     end;

     ds_str:=trim(copy(gcruise_dates,1,p-1));
     de_str:=trim(copy(gcruise_dates,p+1,length(gcruise_dates)));


    {...old date format with / }
{F1}if new_format=false then begin
     {...try convert cruise end date}
     p1:=0; p2:=0; // position of /
     np:=0; //number of /
   for i:=1 to length(de_str) do begin
     if de_str[i]='/' then begin
        inc(np);
        if np=1 then p1:=i;
        if np=2 then p2:=i;
     end;
   end;
   {...de without year}
   if np=1 then begin
     d_str:=copy(de_str,p1+1,length(de_str));
     m_str:=copy(de_str,1,p1-1);
     deN_str:=d_str+'.'+m_str+'.'+y_str;
   end;
   {...de with year}
   if np=2 then begin
     d_str:=copy(de_str,p1+1,p2-p1-1);
     //showmessage('de_str='+de_str);
     //showmessage('p1/p2='+inttostr(p1)+'/'+inttostr(p2));
     //showmessage('d_str='+d_str);
     m_str:=copy(de_str,1,p1-1);
     y_str:=copy(de_str,p2+1,length(de_str));
     deN_str:=d_str+'.'+m_str+'.'+y_str;
   end;
//showmessage(de_str+'->'+d_str+'.'+m_str+'.'+y_str+'.');

     {...try convert cruise start date}
     p1:=0; p2:=0; // position of /
     np:=0; //number of /
   for i:=1 to length(ds_str) do begin
     if ds_str[i]='/' then begin
        inc(np);
        if np=1 then p1:=i;
        if np=2 then p2:=i;
     end;
   end;
   {...ds without year}
   if np=1 then begin
     d_str:=copy(ds_str,p1+1,length(ds_str));
     m_str:=copy(ds_str,1,p1-1);
     dsN_str:=d_str+'.'+m_str+'.'+y_str;
   end;
   {...ds with year}
   if np=2 then begin
     d_str:=copy(ds_str,p1+1,p2-p1-1);
     m_str:=copy(ds_str,1,p1-1);
     y_str:=copy(ds_str,p2+1,length(ds_str));
     dsN_str:=d_str+'.'+m_str+'.'+y_str;
   end;
{F1}end;



    {...new date format without / }
{F2}if new_format=true then begin
     d_str:=copy(ds_str,7,2);
     m_str:=copy(ds_str,5,2);
     y_str:=copy(ds_str,1,4);
     dsN_str:=d_str+'.'+m_str+'.'+y_str;

     d_str:=copy(de_str,7,2);
     m_str:=copy(de_str,5,2);
     y_str:=copy(de_str,1,4);
     deN_str:=d_str+'.'+m_str+'.'+y_str;
{F2}end;

     if trystrtodate(dsN_str,ds) then ds:=strtodate(dsN_str) else ds:=strtodate('1.01.1900');
     if trystrtodate(deN_str,de) then de:=strtodate(deN_str) else de:=strtodate('1.01.1900');
     if two_dates=true then ds:=strtodate('01.01.1900');

     memo1.Lines.Add(inttostr(mik)
     +#9+inttostr(gcrn)
     +#9+expocode
     +#9+nodc_code
     +#9+ship_name+'(id='+inttostr(platform_id)+') ->'+gship_name
     +#9+gcruise_dates
     +#9+dsN_str
     +#9+deN_str
     +#9+datetostr(ds)
     +#9+datetostr(de)
     );

     //XLApp.Cells[y,8].Value:='test2';
     //XLApp.Cells[y,9].Value:=QuotedStr(str);
     //XLApp.Cells[y,9].Value:=15;
     //XLApp.Cells[y,9].Value.AsString:=QuotedStr(str);
     //XLApp.Cells[y,9].Value:='"'+str+'"';
     XLApp.Cells[y,8].Value:=ds;
     XLApp.Cells[y,9].Value:=de;

{C}end;
{r}until trim(XLApp.Cells[y,1].Value)='#END';

  finally
    XLApp.ActiveWorkBook.Save; //saving
    XLApp.Quit;
    XLAPP := Unassigned;
{T}end;

    //XLApp.ActiveWorkBook.Save;
    //XLApp.Quit;
    //XLAPP := Unassigned;


DT2:=NOW;
memo1.Lines.Add('');
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+datetimetostr(DT2-DT1));
end;



procedure TfrmloadGLODAP_v2_2021_product.btnPopulateCruiseTableClick(Sender: TObject);
var
XLApp: OLEVariant;
excel_table,gship_name: variant;
mik,y,gcrn,platform_id :integer;
expocode,ship_name,crn_str,PI,notes :string;
nodc_code :string[4];
ds,de :TDateTime;
begin
DT1:=NOW;
memo1.Lines.Add('...start [populate CRUISE table]: '+datetimetostr(DT1));

excel_table:='c:\Users\Alexa\AK\datasets\GLODAP\v2.2021\excel\GLODAPCruiseTable_ed.xlsx';
memo1.Lines.Add('Exel file: '+excel_table);

 try
  XLApp := CreateOleObject('Excel.Application');
  XLApp.Visible := False;
  XLApp.DisplayAlerts := False;
 except
  Showmessage('MS Excel is not installed');
  Exit;
 end;

   label1.Visible:=true;

{T}try
     XLApp.Workbooks.Open(excel_table); //open the workbook
     y:=1; //skip header
     mik:=0;
{r}repeat
     inc(y); //row

     {...GLODAP cruise number }
     if trystrtoint(XLApp.Cells[y,1].Value,gcrn) then gcrn :=XLApp.Cells[y,1].Value else gcrn:=-9999;

     PI:='';
     notes:='';

     {...check for empty strings}
{C}if gcrn<>-9999 then begin
     inc(mik);
     label1.Caption:='cruise: '+inttostr(mik)+'->'+inttostr(gcrn);
     Application.ProcessMessages;

     {...read}
     expocode:=XLApp.Cells[y,2].Value;  //expocode
     nodc_code:=copy(expocode,1,4);
     crn_str:=XLApp.Cells[y,6].Value;  //cruise number
     crn_str:=trim(crn_str);
     crn_str:=copy(crn_str,1,100);
     gship_name:=XLApp.Cells[y,10].Value;  //expocode
     ds :=XLApp.Cells[y,8].Value;   //cruise start
     de :=XLApp.Cells[y,9].Value;   //cruise end

     if trim(XLApp.Cells[y,11].Value)<>'' then
     PI:=trim(XLApp.Cells[y,11].Value);

     notes:=notes+'region: '+trim(XLApp.Cells[y,5].Value)+#10;
     notes:=notes+'ship: '+trim(XLApp.Cells[y,10].Value)+#10;
     if trim(XLApp.Cells[y,11].Value)<>'' then
     notes:=notes+'shief scientist: '+trim(XLApp.Cells[y,11].Value)+#10;
     if trim(XLApp.Cells[y,12].Value)<>'' then
     notes:=notes+'carbon PI: '+trim(XLApp.Cells[y,12].Value)+#10;
     if trim(XLApp.Cells[y,13].Value)<>'' then
     notes:=notes+'hydrography PI: '+trim(XLApp.Cells[y,13].Value)+#10;
     if trim(XLApp.Cells[y,14].Value)<>'' then
     notes:=notes+'oxygen PI: '+trim(XLApp.Cells[y,14].Value)+#10;
     if trim(XLApp.Cells[y,15].Value)<>'' then
     notes:=notes+'nutriens PI: '+trim(XLApp.Cells[y,15].Value)+#10;
     if trim(XLApp.Cells[y,16].Value)<>'' then
     notes:=notes+'organic PI: '+trim(XLApp.Cells[y,16].Value)+#10;
     if trim(XLApp.Cells[y,17].Value)<>'' then
     notes:=notes+'isotopes PI: '+trim(XLApp.Cells[y,17].Value)+#10;
     if trim(XLApp.Cells[y,18].Value)<>'' then
     notes:=notes+'other PIs: '+trim(XLApp.Cells[y,18].Value)+#10;

       platform_id:=1;
       ship_name:='';
     with frmdm.q1 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select id, name from PLATFORM ');
       SQL.Add(' where nodc_code=:nodc_code ');
       ParamByName('nodc_code').AsString:=nodc_code;
       Open;
       platform_id:=FieldByName('id').AsInteger;
       ship_name:=FieldByName('name').AsString;
       Close;
     end;
       {??? id=1 (UNKNOWN ship and country) disappeared from PLATFORM}
       if ship_name='' then begin
            ship_name:='UNSPECIFIED PLATFORM';
            platform_id:=19439; //UNKNOWN country(id=488)
       end;

       memo1.Lines.Add(inttostr(mik)
       +#9+inttostr(gcrn)
       +#9+expocode
       +#9+nodc_code
       +#9+ship_name+'(id='+inttostr(platform_id)+') ->'+gship_name
       +#9+datetostr(ds)
       +#9+datetostr(de)
       );

       {...SOURCE GLODAP station_id_min=1 station_id_max=1000000}
{db}if CheckBox2.Checked then begin
    with frmdm.q2 do begin
      Close;
      SQL.Clear;
      SQL.Add('insert into CRUISE');
      SQL.Add(' (ID, platform_id, source_id, institute_id, project_id, expocode, PI, notes, ');
      SQL.Add(' DATE_ADDED, DATE_UPDATED, DATE_START_TOTAL, DATE_END_TOTAL,  ');
      SQL.Add(' DATE_START_DATABASE, DATE_END_DATABASE, CRUISE_NUMBER,');
      SQL.Add(' LATITUDE_MIN, LATITUDE_MAX, LONGITUDE_MIN, LONGITUDE_MAX,');
      SQL.Add(' STATIONS_TOTAL, STATIONS_DATABASE, STATIONS_DUPLICATES) ');
      SQL.Add(' VALUES ' );
      SQL.Add(' (:ID, :platform_id, :source_id, :institute_id, :project_id, :expocode, :PI, :notes, ');
      SQL.Add(' :DATE_ADDED, :DATE_UPDATED, :DATE_START_TOTAL, :DATE_END_TOTAL, ');
      SQL.Add(' :DATE_START_DATABASE, :DATE_END_DATABASE, :CRUISE_NUMBER, ');
      SQL.Add(' :LATITUDE_MIN, :LATITUDE_MAX, :LONGITUDE_MIN, :LONGITUDE_MAX,');
      SQL.Add(' :STATIONS_TOTAL, :STATIONS_DATABASE, :STATIONS_DUPLICATES) ');
      //ParamByName('ID').Value:=mik;
      ParamByName('ID').Value:=gcrn; //save the original cruise numbers as STATION ID
      ParamByName('platform_id').Value:=platform_id;
      ParamByName('source_id').Value:=1;
      ParamByName('institute_id').Value:=1; //UNKNOWN
      ParamByName('project_id').Value:=1;   //UNKNOWN
      ParamByName('expocode').Value:=expocode;
      ParamByName('date_added').Value:=now;
      ParamByName('date_updated').Value:=now;
      ParamByName('date_start_total').Value:=ds;
      ParamByName('date_end_total').Value:=de;
      //ParamByName('date_start_database').Value:=q3.FieldByName('date_start_database').Value;
      //ParamByName('date_end_database').Value:=q3.FieldByName('date_end_database').Value;
      ParamByName('cruise_number').Value:=crn_str;
      ParamByName('PI').Value:=PI;
      ParamByName('notes').Value:=notes;
      //ParamByName('latitude_min').Value:=q3.FieldByName('latitude_min').Value;
      //ParamByName('latitude_max').Value:=q3.FieldByName('latitude_max').Value;
      //ParamByName('longitude_min').Value:=q3.FieldByName('longitude_min').Value;
      //ParamByName('longitude_max').Value:=q3.FieldByName('longitude_max').Value;
      ParamByName('stations_total').Value:=0;
      ParamByName('stations_database').Value:=0;
      ParamByName('stations_duplicates').Value:=0;
      ExecSQL;
    end;
      frmdm.TR.CommitRetaining;
{db}end;

{C}end;
{r}until trim(XLApp.Cells[y,1].Value)='#END';

  finally
    //XLApp.ActiveWorkBook.Save; //saving
    XLApp.Quit;
    XLAPP := Unassigned;
{T}end;

DT2:=NOW;
memo1.Lines.Add('');
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+datetimetostr(DT2-DT1));
end;




procedure TfrmloadGLODAP_v2_2021_product.btnDownloadClick(Sender: TObject);
Type
  Col=record
    col_name :string;
    col_val :real;
  end;
  Line = array of Col;

  MD=record
    G_line :integer;
    G_cruise :integer;
    G_st :integer;
    G_cast :integer;
  end;
  MetaData = array of MD;

  Coincidence = record
    val_col :integer;
    pqf1_col :integer;
    sqf_col :integer;
    tbl_name :string;
    tbl_type :integer;
    unit_id :integer;
  end;
   DBC = array of Coincidence;

var
GHeader :Line;
GMD :MetaData;
NewSt,StCasts :array of integer;
GSt :array of array of real;
GDBC :DBC; //GLODAP DataBase Coinsidence

i,mik,kst,kl,ktbl,kc,tc,csc,cb,dsc :integer;
vn,ln,stn,stncr,crn,stlevn :integer;
g_cruise,g_st,g_cast,cast_min,cast_max :integer;
StVersion,CountDup: integer;
vcol,pcol,scol,tt,uid,PQF1,PQF2,SQF :integer;
g_stR :real;
g_lat,lat_min,lat_max,g_lon,lon_min,lon_max,LLm :real;
symbol :char;
gfile,str,buf_str,testfile,tbl :string;
g_cruise_str,g_st_str,g_cast_str :string;
d,m,y,hh,mm :string;
dt,dt_min,dt_max :TDateTime;
new_cast,DayChange,DateChange :boolean;
FuncZ:Tgsw_z_from_p;

G2bottomdepth,G2maxsampdepth,G2pressure,G2depth :real;
G2temperature,G2salinity,G2oxygen,G2aou,G2nitrate,G2nitrite,G2silicate :real;
G2phosphate,G2tco2,G2talk,G2fco2,G2fco2temp,G2phts25p0,G2phtsinsitutp :real;
G2cfc11,G2pcfc11,G2cfc12,G2pcfc12,G2cfc113,G2pcfc113,G2ccl4,G2pccl4,G2c13,G2c14,G2h3,G2he3,G2he,G2neon :real;
G2sf6,G2psf6,G2o18,G2toc,G2doc,G2don,G2tdn,G2chla :real;
G2c14err,G2h3err,G2he3err,G2heerr,G2neonerr :real;
G2theta,G2sigma0,G2sigma1,G2sigma2,G2sigma3,G2sigma4,G2gamma :real;

G2bottle,g_region :integer;
G2salinityf,G2oxygenf,G2aouf,G2nitratef,G2nitritef,G2silicatef :integer;
G2phosphatef,G2tco2f,G2talkf,G2fco2f,G2phts25p0f,G2phtsinsitutpf :integer;
G2cfc11f,G2cfc12f,G2cfc113f,G2ccl4f,G2sf6f,G2c13f,G2o18f,G2tocf,G2docf :integer;
G2c14f,G2h3f,G2he3f,G2hef,G2neonf,G2donf,G2tdnf,G2chlaf :integer;
G2salinityqc,G2oxygenqc,G2nitrateqc,G2silicateqc,G2phosphateqc :integer;
G2tco2qc,G2talkqc,G2phtsqc,G2cfc11qc,G2cfc12qc,G2cfc113qc,G2ccl4qc :integer;
G2c13qc :integer;

label 10;

begin
DT1:=NOW;
memo1.Lines.Add('...start [populate database]: '+datetimetostr(DT1));

   gfile:='c:\Users\Alexa\AK\datasets\GLODAP\v2.2021\GLODAPv2.2021_Merged_Master_File.csv';
   AssignFile(fi, gfile);

   testfile:='c:\Users\Alexa\AK\datasets\GLODAP\v2.2021\test.dat';
   AssignFile(fo, testfile);
   rewrite(fo);

   {...first line}
   {G2cruise,G2region,G2station,G2cast,G2year,G2month,G2day,G2hour,G2minute,
   G2latitude,G2longitude,G2bottomdepth,G2maxsampdepth,G2bottle,
   G2pressure,G2depth,
   G2temperature,G2theta,G2salinity,G2salinityf,G2salinityqc,
   G2sigma0,G2sigma1,G2sigma2,G2sigma3,G2sigma4,G2gamma,
   G2oxygen,G2oxygenf,G2oxygenqc,G2aou,G2aouf,G2nitrate,G2nitratef,G2nitrateqc,
   G2nitrite,G2nitritef,G2silicate,G2silicatef,G2silicateqc,
   G2phosphate,G2phosphatef,G2phosphateqc,G2tco2,G2tco2f,G2tco2qc,
   G2talk,G2talkf,G2talkqc,G2fco2,G2fco2f,G2fco2temp,
   G2phts25p0,G2phts25p0f,G2phtsinsitutp,G2phtsinsitutpf,G2phtsqc,
   G2cfc11,G2pcfc11,G2cfc11f,G2cfc11qc,G2cfc12,G2pcfc12,G2cfc12f,G2cfc12qc,
   G2cfc113,G2pcfc113,G2cfc113f,G2cfc113qc,G2ccl4,G2pccl4,G2ccl4f,G2ccl4qc,
   G2sf6,G2psf6,G2sf6f,G2c13,G2c13f,G2c13qc,G2c14,G2c14f,G2c14err,
   G2h3,G2h3f,G2h3err,G2he3,G2he3f,G2he3err,G2he,G2hef,G2heerr,
   G2neon,G2neonf,G2neonerr,G2o18,G2o18f,G2toc,G2tocf,G2doc,G2docf,
   G2don,G2donf,G2tdn,G2tdnf,G2chla,G2chlaf}

{...#A}
   {...GDBC: variable value column in file/ DBTable/ Table type/ reported unit}
   tc:=0; //tables count
   {17   G2temperature}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=17;
   GDBC[tc-1].pqf1_col:=0;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_TEMPERATURE';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=1;  //°C
   {19   G2salinity}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=19;
   GDBC[tc-1].pqf1_col:=20;
   GDBC[tc-1].sqf_col:=21;
   GDBC[tc-1].tbl_name:='P_SALINITY';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=28;  //psu
   {28   G2oxygen}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=28;
   GDBC[tc-1].pqf1_col:=29;
   GDBC[tc-1].sqf_col:=30;
   GDBC[tc-1].tbl_name:='P_OXYGEN';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=3;  //μmol·kg-1
   {31   G2aou}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=31;
   GDBC[tc-1].pqf1_col:=32;
   GDBC[tc-1].sqf_col:=30;
   GDBC[tc-1].tbl_name:='P_AOU';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=3;  //μmol·kg-1
   {33   G2nitrate}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=33;
   GDBC[tc-1].pqf1_col:=34;
   GDBC[tc-1].sqf_col:=35;
   GDBC[tc-1].tbl_name:='P_NITRATE';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=3;  //μmol·kg-1
   {36   G2nitrite}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=36;
   GDBC[tc-1].pqf1_col:=37;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_NITRITE';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=3;  //μmol·kg-1
   {38   G2silicate}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=38;
   GDBC[tc-1].pqf1_col:=39;
   GDBC[tc-1].sqf_col:=40;
   GDBC[tc-1].tbl_name:='P_SILICATE';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=3;  //μmol·kg-1
   {41   G2phosphate}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=41;
   GDBC[tc-1].pqf1_col:=42;
   GDBC[tc-1].sqf_col:=43;
   GDBC[tc-1].tbl_name:='P_PHOSPHATE';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=3;  //μmol·kg-1
   {44   G2tco2}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=44;
   GDBC[tc-1].pqf1_col:=45;
   GDBC[tc-1].sqf_col:=46;
   GDBC[tc-1].tbl_name:='P_TCO2';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=3;  //μmol·kg-1
   {47   G2talk}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=47;
   GDBC[tc-1].pqf1_col:=48;
   GDBC[tc-1].sqf_col:=49;
   GDBC[tc-1].tbl_name:='P_ALKALINITY';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=3;  //μmol·kg-1
   {50   G2fco2}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=50;
   GDBC[tc-1].pqf1_col:=51;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_FCO2';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=6;  //μatm
   {52   G2fco2temp}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=52;
   GDBC[tc-1].pqf1_col:=51;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_FCO2TEMP';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=1;  //°C
   {53   G2phts25p0}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=53;
   GDBC[tc-1].pqf1_col:=54;
   GDBC[tc-1].sqf_col:=57;
   GDBC[tc-1].tbl_name:='P_PHTS25P0';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=2;  //unit less
   {55   G2phtsinsitutp}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=55;
   GDBC[tc-1].pqf1_col:=56;
   GDBC[tc-1].sqf_col:=57;
   GDBC[tc-1].tbl_name:='P_PHTSINSITUTP';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=2;  //unit less
   {58   G2cfc11}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=58;
   GDBC[tc-1].pqf1_col:=60;
   GDBC[tc-1].sqf_col:=61;
   GDBC[tc-1].tbl_name:='P_CFC11';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=13;  //pmol·kg-1
   {59   G2pcfc11}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=59;
   GDBC[tc-1].pqf1_col:=60;
   GDBC[tc-1].sqf_col:=61;
   GDBC[tc-1].tbl_name:='P_PCFC11';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=18;  //ppt
   {62   G2cfc12}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=62;
   GDBC[tc-1].pqf1_col:=64;
   GDBC[tc-1].sqf_col:=65;
   GDBC[tc-1].tbl_name:='P_CFC12';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=13;  //pmol·kg-1
   {63   G2pcfc12}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=63;
   GDBC[tc-1].pqf1_col:=64;
   GDBC[tc-1].sqf_col:=65;
   GDBC[tc-1].tbl_name:='P_PCFC12';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=18;  //ppt
   {66   G2cfc113}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=66;
   GDBC[tc-1].pqf1_col:=68;
   GDBC[tc-1].sqf_col:=69;
   GDBC[tc-1].tbl_name:='P_CFC113';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=13;  //pmol·kg-1
   {67   G2pcfc113}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=67;
   GDBC[tc-1].pqf1_col:=68;
   GDBC[tc-1].sqf_col:=69;
   GDBC[tc-1].tbl_name:='P_PCFC113';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=18;  //ppt
   {70   G2ccl4}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=70;
   GDBC[tc-1].pqf1_col:=72;
   GDBC[tc-1].sqf_col:=73;
   GDBC[tc-1].tbl_name:='P_CCL4';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=13;  //pmol·kg-1
   {71   G2pccl4}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=71;
   GDBC[tc-1].pqf1_col:=72;
   GDBC[tc-1].sqf_col:=73;
   GDBC[tc-1].tbl_name:='P_PCCL4';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=18;  //ppt
   {74   G2sf6}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=74;
   GDBC[tc-1].pqf1_col:=76;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_SF6';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=19;  //fmol·kg-1
   {75   G2psf6}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=75;
   GDBC[tc-1].pqf1_col:=76;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_PSF6';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=18;  //ppt
   {77   G2c13}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=77;
   GDBC[tc-1].pqf1_col:=78;
   GDBC[tc-1].sqf_col:=79;
   GDBC[tc-1].tbl_name:='P_C13';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=11;  //‰
   {80   G2c14}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=80;
   GDBC[tc-1].pqf1_col:=81;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_C14';
   GDBC[tc-1].tbl_type:=2;
   GDBC[tc-1].unit_id:=11;  //‰
   {83   G2h3}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=83;
   GDBC[tc-1].pqf1_col:=84;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_H3';
   GDBC[tc-1].tbl_type:=2;
   GDBC[tc-1].unit_id:=8;  //TU
   {86   G2he3}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=86;
   GDBC[tc-1].pqf1_col:=87;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_HE3';
   GDBC[tc-1].tbl_type:=2;
   GDBC[tc-1].unit_id:=10;  //%
   {89   G2he}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=89;
   GDBC[tc-1].pqf1_col:=90;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_HE';
   GDBC[tc-1].tbl_type:=2;
   GDBC[tc-1].unit_id:=12;  //nmol·kg-1
   {92   G2neon}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=92;
   GDBC[tc-1].pqf1_col:=93;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_NEON';
   GDBC[tc-1].tbl_type:=2;
   GDBC[tc-1].unit_id:=12;  //nmol·kg-1
   {95   G2o18}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=95;
   GDBC[tc-1].pqf1_col:=96;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_O18';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=11;  //‰
   {97   G2toc}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=97;
   GDBC[tc-1].pqf1_col:=98;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_TOC';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=15;  //μmol·l-1
   {99   G2doc}
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=99;
   GDBC[tc-1].pqf1_col:=100;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_DOC';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=15;  //μmol·l-1
   {101   G2don}
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=101;
   GDBC[tc-1].pqf1_col:=102;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_DON';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=15;  //μmol·l-1
   {103   G2tdn}
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=103;
   GDBC[tc-1].pqf1_col:=104;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_TDN';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=15;  //μmol·l-1
   {105   G2chla}
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=105;
   GDBC[tc-1].pqf1_col:=106;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_CHLOROPHYLL';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=14;  //μg·kg-1

   {...check GDBC}
   memo1.Lines.Add('');
   memo1.Lines.Add('vcol#'+#9+'pqf1#'+#9+'sqf#'+#9+'tbl_name'+#9+'tbl_type'+#9+'unit_id');
   for ktbl:=0 to high(GDBC) do begin
    memo1.Lines.Add(inttostr(GDBC[ktbl].val_col)
    +#9+inttostr(GDBC[ktbl].pqf1_col)
    +#9+inttostr(GDBC[ktbl].sqf_col)
    +#9+GDBC[ktbl].tbl_name
    +#9+inttostr(GDBC[ktbl].tbl_type)
    +#9+inttostr(GDBC[ktbl].unit_id));
   end;


{...#B}
   {...populate GHeader from header}
   Reset(fi);
   readln(fi, str);
   str:=trim(str);
   closefile(fi);

     vn:=0; //variable number
     buf_str:='';
   for i:=1 to length(str) do begin
     symbol:=str[i];
     if (symbol<>',') then buf_str:=buf_str+symbol;
     if (symbol=',') or (i=length(str)) then begin
      inc(vn);
      SetLength(GHeader,vn);
      GHeader[vn-1].col_name:=buf_str;
      buf_str:='';
     end;
   end;
     memo1.Lines.Add('');
     memo1.Lines.Add('col#'+#9+'col_name');
   for i:=0 to High(GHeader) do begin
     memo1.Lines.Add(inttostr(i+1)+#9+GHeader[i].col_name);
   end;



{...#C1}
   {...create GMD dynamical array to split file on GLODAP stations}
   memo1.Lines.Add('');
   memo1.Lines.Add('...reformating MD');
   Label2.Caption:='...progress';
   Label2.Visible:=true;

   Reset(fi);
   readln(fi, str);
   ln:=1; //line number
   Label2.Caption:='line='+inttostr(ln);
   Application.ProcessMessages;
{W}while not EOF(fi) do begin
     readln(fi, str);
     inc(ln);
     if ln mod(1000)=0 then begin
       Label2.Caption:='line='+inttostr(ln);
       Application.ProcessMessages;
     end;

     buf_str:='';
     vn:=0;
   for i:=1 to length(str) do begin
     symbol:=str[i];
     if (symbol<>',') then buf_str:=buf_str+symbol;
   if (symbol=',') or (i=length(str)) then begin
      inc(vn);
   case vn of
      1:begin
          g_cruise_str:=buf_str;
          if trystrtoint(buf_str,g_cruise) then g_cruise :=strtoint(buf_str)
                                           else g_cruise:=-99999;
        end;
      3:begin
          g_st_str:=buf_str;
          {...file contains real values instead integer -> tranc}
          if trystrtofloat(buf_str,g_stR) then begin
                                            g_stR :=strtofloat(buf_str);
                                            g_st:=trunc(g_stR);
                                          end
                                          else g_st:=-99999;
        end;
      4:begin
          g_cast_str:=buf_str;
          {...cruise 644: lines with cast number = -9999 do not have measurements}
          if trystrtoint(buf_str,g_cast) then g_cast :=strtoint(buf_str)
                                         else g_cast:=-99999;
        end;
   end; {case}
      buf_str:='';
   end;
   end;

      SetLength(GMD,ln-1);
      GMD[ln-2].G_line:=ln;
      GMD[ln-2].G_cruise:=g_cruise;
      GMD[ln-2].G_st:=g_st;
      GMD[ln-2].G_cast:=g_cast;

      {...control md problems in master file}
      if g_cruise=-99999 then
      memo1.Lines.Add('cruise number is not integer in line='+inttostr(ln)+'  '+g_cruise_str);
      if g_st=-99999 then
      memo1.Lines.Add('station number is not integer in line='+inttostr(ln)
      +'  '+g_st_str+'  changed to '+inttostr(g_st));
      if g_cast=-99999 then
      memo1.Lines.Add('cast number is not integer in line='+inttostr(ln)+'  '+g_cast_str);
{W}end;
     closefile(fi);
     Label2.Caption:='line='+inttostr(ln);
     Application.ProcessMessages;

     {...add last line}
      inc(ln);
      SetLength(GMD,ln-1);
      GMD[ln-2].G_line:=ln;
      GMD[ln-2].G_cruise:=g_cruise;
      GMD[ln-2].G_st:=g_st;
      GMD[ln-2].G_cast:=g_cast;

     memo1.Lines.Add('');
     memo1.Lines.Add('[GMD] lines#='+inttostr(length(GMD)));


{...#C2}
   {...create NewSt}
     stn:=1;
     stncr:=0;
     SetLength(NewSt,stn);
     NewSt[stn-1]:=2; //start of the first station
     crn:=0;
     memo1.Lines.Add('');
     memo1.Lines.Add('...GLODAP cruises ');
     memo1.Lines.Add('cruise#'+#9+'st#');
{L}for i:=0 to high(GMD)-1 do begin
   if (GMD[i].G_st<>GMD[i+1].G_st) then begin
    stn:=stn+1;
    stncr:=stncr+1;
    SetLength(NewSt,stn);
    NewSt[stn-1]:=GMD[i+1].G_line;
  end;
  if (GMD[i].G_cruise<>GMD[i+1].G_cruise) then begin
    crn:=crn+1;
    memo1.Lines.Add(inttostr(crn)+#9+inttostr(stncr));
    stncr:=0;
  end;
{L}end;

{...#C3}
   {...get stations statistics and write into file for control}
   label2.Caption:='...compute statistics and write into file';
   Application.ProcessMessages;
    writeln(fo,'#'+#9+'crnum'+#9,'stnum'+#9+'stline'+#9+'lev'
    +#9+'cast:min->max'
    +#9+'lat:min->max'
    +#9+'lon:min->max'
    );
    reset(fi);
    readln(fi,str);
{ST}for kst:=0 to high(NewSt)-1 do begin
      stlevn:=NewSt[kst+1]-NewSt[kst];
      dt_min:=strtodatetime('1.01.2099 0:00');
      dt_max:=strtodatetime('1.01.1900 0:00');
      cast_min:=9999;
      cast_max:=-9999;
      lat_min:=9999;
      lat_max:=-9999;
      lon_min:=9999;
      lon_max:=-9999;

{LEV}for kl:=1 to stlevn do begin
      readln(fi,str);
//showmessage(inttostr(kl)+'  '+str);
      buf_str:='';
      vn:=0;
{STR}for i:=1 to length(str) do begin
      symbol:=str[i];
      if (symbol<>',') then buf_str:=buf_str+symbol;
{COL}if (symbol=',') or (i=length(str)) then begin
      inc(vn);
     case vn of
     1:begin
         g_cruise_str:=buf_str;
         if trystrtoint(buf_str,g_cruise) then g_cruise :=strtoint(buf_str)
                                          else g_cruise:=-99999;
       end;
     3:begin
         g_st_str:=buf_str;
         {...file contains real values instead integer -> tranc}
         if trystrtofloat(buf_str,g_stR) then begin
                                           g_stR :=strtofloat(buf_str);
                                           g_st:=trunc(g_stR);
                                         end
                                         else g_st:=-99999;
       end;
     4:begin
         g_cast_str:=buf_str;
         {...cruise 644: lines with cast number = -9999 do not have measurements}
         if trystrtoint(buf_str,g_cast) then g_cast :=strtoint(buf_str)
                                        else g_cast:=-99999;
       end;

     5: y:=trim(buf_str);
     6: m:=trim(buf_str);
     7: d:=trim(buf_str);
     8: hh:=trim(buf_str);
     9: mm:=trim(buf_str);

     10: if trystrtofloat(buf_str,g_lat) then g_lat :=strtofloat(buf_str) else g_lat:=-99999;
     11: if trystrtofloat(buf_str,g_lon) then g_lon :=strtofloat(buf_str) else g_lon:=-99999;


     end;{case}
      buf_str:='';
{COL}end;
{STR}end;

      {...date}
      if hh='-9999' then hh:='0';
      if mm='-9999' then mm:='0';
      str:=d+'.'+m+'.'+y+'.'+' '+hh+':'+mm;
      dt:=strtodatetime(str);

      if dt_min>dt then dt_min:=dt;
      if dt_max<dt then dt_max:=dt;
      if cast_min>g_cast then cast_min:=g_cast;
      if cast_max<g_cast then cast_max:=g_cast;
      if lat_min>g_lat   then lat_min:=g_lat;
      if lat_max<g_lat   then lat_max:=g_lat;
      if lon_min>g_lon   then lon_min:=g_lon;
      if lon_max<g_lon   then lon_max:=g_lon;

{LEV}end;

     writeln(fo,inttostr(kst+1)
     +#9+inttostr(g_cruise)
     +#9+inttostr(g_st)
     +#9+inttostr(NewSt[kst])
     +#9+inttostr(stlevn)
     +#9+inttostr(cast_min)+'->'+inttostr(cast_max)
     +#9+datetimetostr(dt_min)+'->'+datetimetostr(dt_max)
     +#9+floattostr(lat_min)+'->'+floattostr(lat_max)
     +#9+floattostr(lon_min)+'->'+floattostr(lon_max)
     );

{ST} end;
     //closefile(fo);



{...#D }
   {...create GSt}
   writeln(fo,'');
   writeln(fo,'...casts analysis');
   writeln(fo,'#'+#9+'cr#'+#9+'st#'+#9+'cast#');

   reset(fi);
   readln(fi,str);
   dsc:=0; //database stations count
{ST}for kst:=0 to high(NewSt)-1 do begin
     //label2.Caption:='station: '+inttostr(kst+1);
     //if kst mod 10=0 then Application.ProcessMessages;
     stlevn:=NewSt[kst+1]-NewSt[kst];
     SetLength(GSt,0,0);

{LEV}for kl:=1 to stlevn do begin
      readln(fi,str);
      buf_str:='';
      vn:=0;
{STR}for i:=1 to length(str) do begin
      symbol:=str[i];
      if (symbol<>',') then buf_str:=buf_str+symbol;
{COL}if (symbol=',') or (i=length(str)) then begin
      inc(vn);
     case vn of
     1:if trystrtoint(buf_str,g_cruise) then g_cruise :=strtoint(buf_str)
                                          else g_cruise:=-99999;
     2:if trystrtoint(buf_str,g_region) then g_region :=strtoint(buf_str)
                                          else g_region:=-99999;
     3:if trystrtofloat(buf_str,g_stR) then begin
                                           g_stR :=strtofloat(buf_str);
                                           g_st:=trunc(g_stR);
                                         end
                                         else g_st:=-99999;
     4:if trystrtoint(buf_str,g_cast) then g_cast :=strtoint(buf_str)
                                        else g_cast:=-99999;
     5: y:=trim(buf_str);
     6: m:=trim(buf_str);
     7: d:=trim(buf_str);
     8: hh:=trim(buf_str);
     9: mm:=trim(buf_str);
     10: if trystrtofloat(buf_str,g_lat) then g_lat:=strtofloat(buf_str) else g_lat:=-99999;
     11: if trystrtofloat(buf_str,g_lon) then g_lon:=strtofloat(buf_str) else g_lon:=-99999;
     12: if trystrtofloat(buf_str,G2bottomdepth) then G2bottomdepth:=strtofloat(buf_str) else G2bottomdepth:=-99999;
     13: if trystrtofloat(buf_str,G2maxsampdepth) then G2maxsampdepth:=strtofloat(buf_str) else G2maxsampdepth:=-99999;
     14: if trystrtoint(buf_str,G2bottle) then G2bottle:=strtoint(buf_str) else G2bottle:=-99999;
     15: if trystrtofloat(buf_str,G2pressure) then G2pressure:=strtofloat(buf_str) else G2pressure:=-99999;
     16: if trystrtofloat(buf_str,G2depth) then G2depth:=strtofloat(buf_str) else G2depth:=-99999;
     17: if trystrtofloat(buf_str,G2temperature) then G2temperature:=strtofloat(buf_str) else G2temperature:=-99999;
     18: if trystrtofloat(buf_str,G2theta) then G2theta:=strtofloat(buf_str) else G2theta:=-99999;
     19: if trystrtofloat(buf_str,G2salinity) then G2salinity:=strtofloat(buf_str) else G2salinity:=-99999;
     20: if trystrtoint(buf_str,G2salinityf) then G2salinityf:=strtoint(buf_str) else G2salinityf:=-99999;
     21: if trystrtoint(buf_str,G2salinityqc) then G2salinityqc:=strtoint(buf_str) else G2salinityqc:=-99999;

     22: if trystrtofloat(buf_str,G2sigma0) then G2sigma0:=strtofloat(buf_str) else G2sigma0:=-99999;
     23: if trystrtofloat(buf_str,G2sigma1) then G2sigma1:=strtofloat(buf_str) else G2sigma1:=-99999;
     24: if trystrtofloat(buf_str,G2sigma2) then G2sigma2:=strtofloat(buf_str) else G2sigma2:=-99999;
     25: if trystrtofloat(buf_str,G2sigma3) then G2sigma3:=strtofloat(buf_str) else G2sigma3:=-99999;
     26: if trystrtofloat(buf_str,G2sigma4) then G2sigma4:=strtofloat(buf_str) else G2sigma4:=-99999;
     27: if trystrtofloat(buf_str,G2gamma)  then G2gamma :=strtofloat(buf_str) else G2gamma :=-99999;

     28: if trystrtofloat(buf_str,G2oxygen) then G2oxygen:=strtofloat(buf_str) else G2oxygen:=-99999;
     29: if trystrtoint(buf_str,G2oxygenf) then G2oxygenf:=strtoint(buf_str) else G2oxygenf:=-99999;
     30: if trystrtoint(buf_str,G2oxygenqc) then G2oxygenqc:=strtoint(buf_str) else G2oxygenqc:=-99999;

     31: if trystrtofloat(buf_str,G2aou) then G2aou:=strtofloat(buf_str) else G2aou:=-99999;
     32: if trystrtoint(buf_str,G2aouf) then G2aouf:=strtoint(buf_str) else G2aouf:=-99999;

     33: if trystrtofloat(buf_str,G2nitrate) then G2nitrate:=strtofloat(buf_str) else G2nitrate:=-99999;
     34: if trystrtoint(buf_str,G2nitratef) then G2nitratef:=strtoint(buf_str) else G2nitratef:=-99999;
     35: if trystrtoint(buf_str,G2nitrateqc) then G2nitrateqc:=strtoint(buf_str) else G2nitrateqc:=-99999;

     36: if trystrtofloat(buf_str,G2nitrite) then G2nitrite:=strtofloat(buf_str) else G2nitrite:=-99999;
     37: if trystrtoint(buf_str,G2nitritef) then G2nitritef:=strtoint(buf_str) else G2nitritef:=-99999;

     38: if trystrtofloat(buf_str,G2silicate) then G2silicate:=strtofloat(buf_str) else G2silicate:=-99999;
     39: if trystrtoint(buf_str,G2silicatef) then G2silicatef:=strtoint(buf_str) else G2silicatef:=-99999;
     40: if trystrtoint(buf_str,G2silicateqc) then G2silicateqc:=strtoint(buf_str) else G2silicateqc:=-99999;

     41: if trystrtofloat(buf_str,G2phosphate) then G2phosphate:=strtofloat(buf_str) else G2phosphate:=-99999;
     42: if trystrtoint(buf_str,G2phosphatef) then G2phosphatef:=strtoint(buf_str) else G2phosphatef:=-99999;
     43: if trystrtoint(buf_str,G2phosphateqc) then G2phosphateqc:=strtoint(buf_str) else G2phosphateqc:=-99999;

     44: if trystrtofloat(buf_str,G2tco2) then G2tco2:=strtofloat(buf_str) else G2tco2:=-99999;
     45: if trystrtoint(buf_str,G2tco2f) then G2tco2f:=strtoint(buf_str) else G2tco2f:=-99999;
     46: if trystrtoint(buf_str,G2tco2qc) then G2tco2qc:=strtoint(buf_str) else G2tco2qc:=-99999;

     47: if trystrtofloat(buf_str,G2talk) then G2talk:=strtofloat(buf_str) else G2talk:=-99999;
     48: if trystrtoint(buf_str,G2talkf) then G2talkf:=strtoint(buf_str) else G2talkf:=-99999;
     49: if trystrtoint(buf_str,G2talkqc) then G2talkqc:=strtoint(buf_str) else G2talkqc:=-99999;

     50: if trystrtofloat(buf_str,G2fco2) then G2fco2:=strtofloat(buf_str) else G2fco2:=-99999;
     51: if trystrtoint(buf_str,G2fco2f) then G2fco2f:=strtoint(buf_str) else G2fco2f:=-99999;
     52: if trystrtofloat(buf_str,G2fco2temp) then G2fco2temp:=strtofloat(buf_str) else G2fco2temp:=-99999;

     53: if trystrtofloat(buf_str,G2phts25p0) then G2phts25p0:=strtofloat(buf_str) else G2phts25p0:=-99999;
     54: if trystrtoint(buf_str,G2phts25p0f) then G2phts25p0f:=strtoint(buf_str) else G2phts25p0f:=-99999;
     55: if trystrtofloat(buf_str,G2phtsinsitutp) then G2phtsinsitutp:=strtofloat(buf_str) else G2phtsinsitutp:=-99999;
     56: if trystrtoint(buf_str,G2phtsinsitutpf) then G2phtsinsitutpf:=strtoint(buf_str) else G2phtsinsitutpf:=-99999;
     57: if trystrtoint(buf_str,G2phtsqc) then G2phtsqc:=strtoint(buf_str) else G2phtsqc:=-99999;

     58: if trystrtofloat(buf_str,G2cfc11) then G2cfc11:=strtofloat(buf_str) else G2cfc11:=-99999;
     59: if trystrtofloat(buf_str,G2pcfc11) then G2pcfc11:=strtofloat(buf_str) else G2pcfc11:=-99999;
     60: if trystrtoint(buf_str,G2cfc11f) then G2cfc11f:=strtoint(buf_str) else G2cfc11f:=-99999;
     61: if trystrtoint(buf_str,G2cfc11qc) then G2cfc11qc:=strtoint(buf_str) else G2cfc11qc:=-99999;

     62: if trystrtofloat(buf_str,G2cfc12) then G2cfc12:=strtofloat(buf_str) else G2cfc12:=-99999;
     63: if trystrtofloat(buf_str,G2pcfc12) then G2pcfc12:=strtofloat(buf_str) else G2pcfc12:=-99999;
     64: if trystrtoint(buf_str,G2cfc12f) then G2cfc12f:=strtoint(buf_str) else G2cfc12f:=-99999;
     65: if trystrtoint(buf_str,G2cfc12qc) then G2cfc12qc:=strtoint(buf_str) else G2cfc12qc:=-99999;

     66: if trystrtofloat(buf_str,G2cfc113) then G2cfc113:=strtofloat(buf_str) else G2cfc113:=-99999;
     67: if trystrtofloat(buf_str,G2pcfc113) then G2pcfc113:=strtofloat(buf_str) else G2pcfc113:=-99999;
     68: if trystrtoint(buf_str,G2cfc113f) then G2cfc113f:=strtoint(buf_str) else G2cfc113f:=-99999;
     69: if trystrtoint(buf_str,G2cfc113qc) then G2cfc113qc:=strtoint(buf_str) else G2cfc113qc:=-99999;

     70: if trystrtofloat(buf_str,G2ccl4) then G2ccl4:=strtofloat(buf_str) else G2ccl4:=-99999;
     71: if trystrtofloat(buf_str,G2pccl4) then G2pccl4:=strtofloat(buf_str) else G2pccl4:=-99999;
     72: if trystrtoint(buf_str,G2ccl4f) then G2ccl4f:=strtoint(buf_str) else G2ccl4f:=-99999;
     73: if trystrtoint(buf_str,G2ccl4qc) then G2ccl4qc:=strtoint(buf_str) else G2ccl4qc:=-99999;

     74: if trystrtofloat(buf_str,G2sf6) then G2sf6:=strtofloat(buf_str) else G2sf6:=-99999;
     75: if trystrtofloat(buf_str,G2psf6) then G2psf6:=strtofloat(buf_str) else G2psf6:=-99999;
     76: if trystrtoint(buf_str,G2sf6f) then G2sf6f:=strtoint(buf_str) else G2sf6f:=-99999;

     77: if trystrtofloat(buf_str,G2c13) then G2c13:=strtofloat(buf_str) else G2c13:=-99999;
     78: if trystrtoint(buf_str,G2c13f) then G2c13f:=strtoint(buf_str) else G2c13f:=-99999;
     79: if trystrtoint(buf_str,G2c13qc) then G2c13qc:=strtoint(buf_str) else G2c13qc:=-99999;

     80: if trystrtofloat(buf_str,G2c14) then G2c14:=strtofloat(buf_str) else G2c14:=-99999;
     81: if trystrtoint(buf_str,G2c14f) then G2c14f:=strtoint(buf_str) else G2c14f:=-99999;
     82: if trystrtofloat(buf_str,G2c14err) then G2c14err:=strtofloat(buf_str) else G2c14err:=-99999;

     83: if trystrtofloat(buf_str,G2h3) then G2h3:=strtofloat(buf_str) else G2h3:=-99999;
     84: if trystrtoint(buf_str,G2h3f) then G2h3f:=strtoint(buf_str) else G2h3f:=-99999;
     85: if trystrtofloat(buf_str,G2h3err) then G2h3err:=strtofloat(buf_str) else G2h3err:=-99999;

     86: if trystrtofloat(buf_str,G2he3) then G2he3:=strtofloat(buf_str) else G2he3:=-99999;
     87: if trystrtoint(buf_str,G2he3f) then G2he3f:=strtoint(buf_str) else G2he3f:=-99999;
     88: if trystrtofloat(buf_str,G2he3err) then G2he3err:=strtofloat(buf_str) else G2he3err:=-99999;

     89: if trystrtofloat(buf_str,G2he) then G2he:=strtofloat(buf_str) else G2he:=-99999;
     90: if trystrtoint(buf_str,G2hef) then G2hef:=strtoint(buf_str) else G2hef:=-99999;
     91: if trystrtofloat(buf_str,G2heerr) then G2heerr:=strtofloat(buf_str) else G2heerr:=-99999;

     92: if trystrtofloat(buf_str,G2neon) then G2neon:=strtofloat(buf_str) else G2neon:=-99999;
     93: if trystrtoint(buf_str,G2neonf) then G2neonf:=strtoint(buf_str) else G2neonf:=-99999;
     94: if trystrtofloat(buf_str,G2neonerr) then G2neonerr:=strtofloat(buf_str) else G2neonerr:=-99999;

     95: if trystrtofloat(buf_str,G2o18) then G2o18:=strtofloat(buf_str) else G2o18:=-99999;
     96: if trystrtoint(buf_str,G2o18f) then G2o18f:=strtoint(buf_str) else G2o18f:=-99999;

     97: if trystrtofloat(buf_str,G2toc) then G2toc:=strtofloat(buf_str) else G2toc:=-99999;
     98: if trystrtoint(buf_str,G2tocf) then G2tocf:=strtoint(buf_str) else G2tocf:=-99999;

     99: if trystrtofloat(buf_str,G2doc) then G2doc:=strtofloat(buf_str) else G2doc:=-99999;
     100: if trystrtoint(buf_str,G2docf) then G2docf:=strtoint(buf_str) else G2docf:=-99999;

     101: if trystrtofloat(buf_str,G2don) then G2don:=strtofloat(buf_str) else G2don:=-99999;
     102: if trystrtoint(buf_str,G2donf) then G2donf:=strtoint(buf_str) else G2donf:=-99999;

     103: if trystrtofloat(buf_str,G2tdn) then G2tdn:=strtofloat(buf_str) else G2tdn:=-99999;
     104: if trystrtoint(buf_str,G2tdnf) then G2tdnf:=strtoint(buf_str) else G2tdnf:=-99999;

     105: if trystrtofloat(buf_str,G2chla) then G2chla:=strtofloat(buf_str) else G2chla:=-99999;
     106: if trystrtoint(buf_str,G2chlaf) then G2chlaf:=strtoint(buf_str) else G2chlaf:=-99999
     end;{case}
      buf_str:='';
{COL}end;
{STR}end;

      {...date}
      if hh='-9999' then hh:='0';
      if mm='-9999' then mm:='0';
      str:=d+'.'+m+'.'+y+'.'+' '+hh+':'+mm;
      dt:=strtodatetime(str);

      {...GLODAPv2.2021_Merged_Master_File.csv contains 106 columns}
      SetLength(GSt,kl,106);

      GSt[kl-1,0]:=g_cruise; //col=1
      GSt[kl-1,1]:=g_region; //2
      GSt[kl-1,2]:=g_st; //3
      GSt[kl-1,3]:=g_cast;  //4
      GSt[kl-1,4]:=strtoint(trim(y));  //5
      GSt[kl-1,5]:=strtoint(trim(m));  //6
      GSt[kl-1,6]:=strtoint(trim(d));  //7
      GSt[kl-1,7]:=strtoint(trim(hh));  //8
      GSt[kl-1,8]:=strtoint(trim(mm));  //9
      GSt[kl-1,9]:=g_lat; //10
      GSt[kl-1,10]:=g_lon; //11
      GSt[kl-1,11]:=trunc(G2bottomdepth);  //12
      GSt[kl-1,12]:=trunc(G2maxsampdepth); //13
      GSt[kl-1,13]:=G2bottle; //14
      GSt[kl-1,14]:=G2pressure; //15
      GSt[kl-1,15]:=G2depth; //16
      GSt[kl-1,16]:=G2temperature; //17
      GSt[kl-1,17]:=G2theta; //18

      GSt[kl-1,18]:=G2salinity; //19
      GSt[kl-1,19]:=G2salinityf; //20
      GSt[kl-1,20]:=G2salinityqc; //21

      GSt[kl-1,21]:=G2sigma0; //22
      GSt[kl-1,22]:=G2sigma1; //23
      GSt[kl-1,23]:=G2sigma2; //24
      GSt[kl-1,24]:=G2sigma3; //25
      GSt[kl-1,25]:=G2sigma4; //26
      GSt[kl-1,26]:=G2gamma; //27

      GSt[kl-1,27]:=G2oxygen; //28
      GSt[kl-1,28]:=G2oxygenf; //29
      GSt[kl-1,29]:=G2oxygenqc; //30

      GSt[kl-1,30]:=G2aou; //31
      GSt[kl-1,31]:=G2aouf; //32

      GSt[kl-1,32]:=G2nitrate; //33
      GSt[kl-1,33]:=G2nitratef; //34
      GSt[kl-1,34]:=G2nitrateqc; //35

      GSt[kl-1,35]:=G2nitrite; //36
      GSt[kl-1,36]:=G2nitritef; //37

      GSt[kl-1,37]:=G2silicate; //38
      GSt[kl-1,38]:=G2silicatef;  //39
      GSt[kl-1,39]:=G2silicateqc;  //40

      GSt[kl-1,40]:=G2phosphate; //41
      GSt[kl-1,41]:=G2phosphatef; //42
      GSt[kl-1,42]:=G2phosphateqc; //43

      GSt[kl-1,43]:=G2tco2; //44
      GSt[kl-1,44]:=G2tco2f;  //45
      GSt[kl-1,45]:=G2tco2qc;  //46

      GSt[kl-1,46]:=G2talk; //47
      GSt[kl-1,47]:=G2talkf; //48
      GSt[kl-1,48]:=G2talkqc; //49

      GSt[kl-1,49]:=G2fco2; //50
      GSt[kl-1,50]:=G2fco2f; //51
      GSt[kl-1,51]:=G2fco2temp; //52

      GSt[kl-1,52]:=G2phts25p0; //53
      GSt[kl-1,53]:=G2phts25p0f; //54
      GSt[kl-1,54]:=G2phtsinsitutp; //55
      GSt[kl-1,55]:=G2phtsinsitutpf; //56
      GSt[kl-1,56]:=G2phtsqc; //57

      GSt[kl-1,57]:=G2cfc11; //58
      GSt[kl-1,58]:=G2pcfc11; //59
      GSt[kl-1,59]:=G2cfc11f; //60
      GSt[kl-1,60]:=G2cfc11qc; //61

      GSt[kl-1,61]:=G2cfc12; //62
      GSt[kl-1,62]:=G2pcfc12; //63
      GSt[kl-1,63]:=G2cfc12f; //64
      GSt[kl-1,64]:=G2cfc12qc; //65

      GSt[kl-1,65]:=G2cfc113; //66
      GSt[kl-1,66]:=G2pcfc113; //67
      GSt[kl-1,67]:=G2cfc113f; //68
      GSt[kl-1,68]:=G2cfc113qc; //69

      GSt[kl-1,69]:=G2ccl4; //70
      GSt[kl-1,70]:=G2pccl4; //71
      GSt[kl-1,71]:=G2ccl4f; //72
      GSt[kl-1,72]:=G2ccl4qc; //73

      GSt[kl-1,73]:=G2sf6; //74
      GSt[kl-1,74]:=G2psf6; //75
      GSt[kl-1,75]:=G2sf6f; //76

      GSt[kl-1,76]:=G2c13; //77
      GSt[kl-1,77]:=G2c13f; //78
      GSt[kl-1,78]:=G2c13qc; //79

      GSt[kl-1,79]:=G2c14; //80
      GSt[kl-1,80]:=G2c14f; //81
      GSt[kl-1,81]:=G2c14err; //82

      GSt[kl-1,82]:=G2h3; //83
      GSt[kl-1,83]:=G2h3f; //84
      GSt[kl-1,84]:=G2h3err; //85

      GSt[kl-1,85]:=G2he3; //86
      GSt[kl-1,86]:=G2he3f; //87
      GSt[kl-1,87]:=G2he3err; //88

      GSt[kl-1,88]:=G2he; //89
      GSt[kl-1,89]:=G2hef; //90
      GSt[kl-1,90]:=G2heerr; //91

      GSt[kl-1,91]:=G2neon; //92
      GSt[kl-1,92]:=G2neonf; //93
      GSt[kl-1,93]:=G2neonerr; //94

      GSt[kl-1,94]:=G2o18; //95
      GSt[kl-1,95]:=G2o18f; //96

      GSt[kl-1,96]:=G2toc; //97
      GSt[kl-1,97]:=G2tocf; //98

      GSt[kl-1,98]:=G2doc; //99
      GSt[kl-1,99]:=G2docf; //100

      GSt[kl-1,100]:=G2don; //101
      GSt[kl-1,101]:=G2donf; //102

      GSt[kl-1,102]:=G2tdn; //103
      GSt[kl-1,103]:=G2tdnf; //104

      GSt[kl-1,104]:=G2chla; //105
      GSt[kl-1,105]:=G2chlaf; //106
{LEV}end;

//#D1 devide GSt on casts and populate STATION
     {...create StCasts containing cast numbers at the station}
     csc:=1; //count station casts
     SetLength(StCasts,csc);
     StCasts[csc-1]:=trunc(GSt[0,3]);
{kl}for kl:=0 to high(GSt) do begin
     g_cast:=trunc(GSt[kl,3]);
     new_cast:=true;
     for kc:=0 to high(StCasts) do if StCasts[kc]=g_cast then new_cast:=false;
    if new_cast=true then begin
     inc(csc);
     SetLength(StCasts,csc);
     StCasts[csc-1]:=g_cast;
    end;
{kl}end;


//#D2:  sort StCasts
{sc}if length(StCasts)>1 then begin
10:
{kc} for kc:=0 to high(StCasts)-1 do begin
    if StCasts[kc]>StCasts[kc+1] then begin
      cb:=StCasts[kc];
      StCasts[kc]:=StCasts[kc+1];
      StCasts[kc+1]:=cb;
    end;
{kc}end;
    for kc:=0 to high(StCasts)-1 do if StCasts[kc]>StCasts[kc+1] then goto 10;
{sc}end;

   writeln(fo);
   write(fo,'GLODAP :'
   +#9+inttostr(kst+1)
   +#9+inttostr(g_cruise)
   +#9+inttostr(g_st)
   +#9+inttostr(length(StCasts)));
   write(fo,#9,'casts:');
   for kc:=0 to high(StCasts) do write(fo,inttostr(StCasts[kc])+' ');
   writeln(fo);



{#F1 devide GSt on casts}
{kc  }for kc:=0 to high(StCasts) do begin
        g_cast:=StCasts[kc];
        mik:=0;
{kl}  for kl:=0 to high(GSt) do begin

{cast}if g_cast=trunc(GSt[kl,3]) then begin
       inc(mik);

{#F2: populate STATION if is empty}
{STATION}if mik=1 then begin
       inc(dsc);

       {...encode datetime}
       dt:= procedures.DateEncode(trunc(GSt[kl,4]),
       trunc(GSt[kl,5]),
       trunc(GSt[kl,6]),
       trunc(GSt[kl,7]),
       trunc(GSt[kl,8]),
       DayChange,DateChange);
       if DayChange=true  then memo1.Lines.Add('procedures.DateEncode: day  change at station '+inttostr(kst+1));
       if DateChange=true then memo1.Lines.Add('procedures.DateEncode: date change at station '+inttostr(kst+1));
       {...last level}
       FuncZ:=Tgsw_z_from_p(GetProcedureAddress(libgswteos, 'gsw_z_from_p'));
       LLm:=-FuncZ(GSt[kl,12], GSt[kl,9], 0, 0);  //last level meters
       {...StVersion}
       StVersion:=0;
       CountDup:=0;

{DB}if CheckBox2.Checked then begin
    with frmdm.q1 do begin
       Close;
       SQL.Clear;
       SQL.Add(' Select count(id) from STATION ');
       SQL.Add(' where dateandtime=:st_DT and ');
       SQL.Add(' latitude=:lat and longitude=:lon and cast_number=:cast_number ');
       ParamByName('st_DT').AsDateTime:=dt;
       ParamByName('lat' ).Asfloat:=GSt[kl,9];
       ParamByName('lon' ).AsFloat:=GSt[kl,10];
       ParamByName('cast_number').AsInteger:=g_cast;
       Open;
       if not IsEmpty then
       CountDup:=FieldByName('count').AsInteger;
       Close;
      end;
       if CountDup>0 then StVersion:=CountDup+1;

       with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' INSERT INTO STATION ' );
        SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ' );
        SQL.Add(' BottomDepth, LastLevel_m, LastLevel_dbar, ' );
        SQL.Add('  ST_NUMBER_ORIGIN, CAST_NUMBER, QCFLAG, ' );
        SQL.Add('  STVERSION, DUPLICATE, DATE_ADDED, DATE_UPDATED)' );
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ' );
        SQL.Add(' :BottomDepth, :LastLevel_m, :LastLevel_dbar, ' );
        SQL.Add('  :ST_NUMBER_ORIGIN, :CAST_NUMBER, :QCFLAG, ' );
        SQL.Add('   :STVERSION, :DUPLICATE, :DATE_ADDED, :DATE_UPDATED) ' );
        ParamByName('ID'               ).Value:=dsc;
        ParamByName('LATITUDE'         ).Value:=GSt[kl,9];
        ParamByName('LONGITUDE'        ).Value:=GSt[kl,10];
        ParamByName('DATEANDTIME'      ).Value:=dt;
        if GSt[kl,11]>-9999 then
        ParamByName('BottomDepth'      ).Value:= trunc(GSt[kl,11]);
        ParamByName('CRUISE_ID'        ).Value:=trunc(GSt[kl,0]);
        ParamByName('LastLevel_m'        ).Value:=trunc(LLm);
        ParamByName('LastLevel_dbar'     ).Value:=trunc(GSt[kl,12]);
        ParamByName('ST_NUMBER_ORIGIN' ).Value:=trunc(GSt[kl,2]);
        ParamByName('CAST_NUMBER'      ).Value:=g_cast;
        ParamByName('QCFLAG'           ).Value:=0;
        ParamByName('STVERSION'        ).Value:=StVersion;
        ParamByName('DUPLICATE'        ).Value:=false;
        ParamByName('DATE_ADDED'       ).Value:=now;
        ParamByName('DATE_UPDATED'     ).Value:=now;
        ExecSQL;
       end;
       frmdm.TR.CommitRetaining;
{DB}end;
       writeln(fo,'STATION:'
       +#9,inttostr(dsc)
       +#9,inttostr(trunc(GSt[kl,0]))
       +#9,inttostr(trunc(GSt[kl,2]))
       +#9,inttostr(g_cast)
       +#9,datetimetostr(dt)
       +#9,floattostr(GSt[kl,9])
       +#9,floattostr(GSt[kl,10])
       );
{STATION}end;

{#F3: populate P_ tables}
{ktbl}for ktbl:=0 to high(GDBC) do begin
        vcol:=GDBC[ktbl].val_col;    //value
        pcol:=GDBC[ktbl].pqf1_col;   //f=PQF1
        scol:=GDBC[ktbl].sqf_col;    //qc=SQF
        tbl:=GDBC[ktbl].tbl_name;
        tt:=GDBC[ktbl].tbl_type;
        uid:=GDBC[ktbl].unit_id;

        {file col->GSt index}
        vcol:=vcol-1;
        pcol:=pcol-1;
        scol:=scol-1;

{Pval}if GSt[kl,vcol]>-9999 then begin

        PQF1:=trunc(GSt[kl,pcol]);
        PQF2:=0;
        SQF:=trunc(GSt[kl,scol]);

        {...covert PQF1(datasource convention) to PQF2(DB convention)}
        case pqf1 of
        0: pqf2:=3;
        2: pqf2:=4;
        9: pqf2:=0;
        end;
        {...convert SQF to PQF2}
        if SQF=1 then PQF2:=7; //passed secondary QC

{DB}if CheckBox2.Checked then begin
    with frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' insert into ');
      SQL.Add(tbl);
      SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, ');
      if tt=2 then SQL.Add(' VALERR, ');
      SQL.Add('  PQF1, PQF2, SQF, BOTTLE_NUMBER, UNITS_ID, ');
      SQL.Add('  INSTRUMENT_ID, PROFILE_NUMBER, PROFILE_BEST) ');
      SQL.Add(' values ');
      SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL,  ');
      if tt=2 then SQL.Add(' :VALERR, ');
      SQL.Add('  :PQF1, :PQF2, :SQF, :BOTTLE_NUMBER, :UNITS_ID, ');
      SQL.Add('  :INSTRUMENT_ID, :PROFILE_NUMBER, :PROFILE_BEST) ');
      ParamByName('ID').AsInteger:=dsc;
      ParamByName('LEV_DBAR').AsFloat:=GSt[kl,14];
      ParamByName('LEV_M').AsFloat:=GSt[kl,15];
      ParamByName('VAL').AsFloat:=GSt[kl,vcol];
      if tt=2 then ParamByName('VALERR').AsFloat:=GSt[kl,vcol+2];
      ParamByName('PQF1').AsInteger:=PQF1;
      ParamByName('PQF2').AsInteger:=PQF2;
      ParamByName('SQF').AsInteger:=SQF;
      ParamByName('BOTTLE_NUMBER').AsInteger:=trunc(GSt[kl,13]);
      ParamByName('UNITS_ID').AsInteger:=uid;
      ParamByName('INSTRUMENT_ID').AsInteger:=7;
      ParamByName('PROFILE_NUMBER').AsInteger:=1;
      ParamByName('PROFILE_BEST').AsBoolean:=true;
      ExecSQL;
     end;
{DB}end;

writeln(fo,tbl
+#9+inttostr(dsc)
+#9+'dbar='+floattostr(GSt[kl,14])
+#9+floattostr(GSt[kl,15])
+#9+floattostr(GSt[kl,vcol])
+#9+inttostr(PQF1)
+#9+inttostr(PQF2)
+#9+inttostr(SQF)
+#9+'btl='+inttostr(trunc(GSt[kl,13]))
+#9+inttostr(uid)
);

{pval}end;
{ktbl}end;

{cast}end;
      if CheckBox2.Checked then frmdm.TR.CommitRetaining;
{kl}  end;
{ks}  end;

     label2.Caption:='G/DB station: '+inttostr(kst+1)+'->'+inttostr(dsc);
     Application.ProcessMessages;
     //if kst mod 10=0 then Application.ProcessMessages;

{ST} end;
     closefile(fo);
     closefile(fi);

     label2.Caption:='G/DB station: '+inttostr(kst+1)+'->'+inttostr(dsc);
     Application.ProcessMessages;

DT2:=NOW;
memo1.Lines.Add('');
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+datetimetostr(DT2-DT1));
end;




{update cruises dates and limits using information from STATION}
procedure TfrmloadGLODAP_v2_2021_product.btnUpdateCruiseTableClick(
  Sender: TObject);
var
mik,cr_id,st_cr :integer;
lat_min,lat_max,lon_min,lon_max :real;
dt_min,dt_max :TDateTime;

begin
DT1:=NOW;
memo1.Lines.Add('...start [CRUISE DBT update]: '+datetimetostr(DT1));

    with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select id from CRUISE ');
     Open;
    end;

     mik:=0;
     label2.Visible:=true;
     memo1.Lines.Add('#'+#9+'cr#'+#9+'st#'+#9+'dt_min'+#9+'dt_max'
     +#9+'lat_min'+#9+'lat_max'+#9+'lon_min'+#9+'lon_max');
{cr}while not frmdm.q1.EOF do begin
     inc(mik);
     cr_id:=frmdm.q1.FieldByName('id').AsInteger;
     label2.Caption:='cruise #/ID: '+inttostr(mik)+'->'+inttostr(cr_id);
     Application.ProcessMessages;

     with frmdm.q2 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select count(id) as st_cr, ');
      SQL.Add(' min(dateandtime) as dt_min, max(dateandtime) as dt_max, ');
      SQL.Add(' min(latitude) as lat_min, max(latitude) as lat_max, ');
      SQL.Add(' min(longitude) as lon_min, max(longitude) as lon_max ');
      SQL.Add(' from STATION ');
      SQL.Add(' where cruise_id=:cruise_id ');
      ParamByName('cruise_id').AsInteger:=cr_id;
      Open;
      st_cr:=FieldByName('st_cr').AsInteger;
      dt_min:=FieldByName('dt_min').AsDateTime;
      dt_max:=FieldByName('dt_max').AsDateTime;
      lat_min:=FieldByName('lat_min').AsFloat;
      lat_max:=FieldByName('lat_max').AsFloat;
      lon_min:=FieldByName('lon_min').AsFloat;
      lon_max:=FieldByName('lon_max').AsFloat;
      Close;
     end;

     memo1.Lines.Add(inttostr(mik)
     +#9+inttostr(cr_id)
     +#9+inttostr(st_cr)
     +#9+datetimetostr(dt_min)
     +#9+datetimetostr(dt_max)
     +#9+floattostr(lat_min)
     +#9+floattostr(lat_max)
     +#9+floattostr(lon_min)
     +#9+floattostr(lon_max)
     );

{db}if CheckBox2.Checked then begin
 with frmdm.q2 do begin
  Close;
  SQL.Clear;
  SQL.Add(' update CRUISE ');
  SQL.Add(' set stations_database=:st_cr, ');
  SQL.Add(' date_start_database=:dt_min, date_end_database=:dt_max, ');
  SQL.Add(' latitude_min=:lat_min, latitude_max=:lat_max, ');
  SQL.Add(' longitude_min=:lon_min, longitude_max=:lon_max ');
  SQL.Add(' where id=:cr_id ');
  ParamByName('cr_id').AsInteger:=cr_id;
  ParamByName('st_cr').AsInteger:=st_cr;
  ParamByName('dt_min').AsDateTime:=dt_min;
  ParamByName('dt_max').AsDateTime:=dt_max;
  ParamByName('lat_min').AsFloat:=lat_min;
  ParamByName('lat_max').AsFloat:=lat_max;
  ParamByName('lon_min').AsFloat:=lon_min;
  ParamByName('lon_max').AsFloat:=lon_max;
  ExecSQL;
 end;
  frmdm.TR.CommitRetaining;
{db}end;

     frmdm.q1.Next;
{cr}end;
     frmdm.q1.Close;

DT2:=NOW;
memo1.Lines.Add('');
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+datetimetostr(DT2-DT1));
end;




procedure TfrmloadGLODAP_v2_2021_product.btnFixedStationsClick(Sender: TObject);

type
  OneStation=record
    cruise_id :integer;
    station_id :integer;
    platform_id :integer;
    lat :real;
    lon :real;
    time :TDateTime;
  end;
  StationType=array of OneStation;

  FixedStation=record
    lat :real;
    lon :real;
    time_min :TDateTime;
    time_max :TDateTime;
    stcount :integer;
  end;
  FixedStationType=array of FixedStation;

var
Station :StationType;
FStation :FixedStationType;
i,j,n,platform_id,fsc,db,id_max :integer;
mcn,ncn,ec,entry_id,stinc,source_id,cruise_id,sincr,sa :integer;
pl :real;
str,entry_title :string;
new :boolean;
minDT,maxDT :TDateTime;
minlat,maxlat,minlon,maxlon :real;

begin

if frmdm.q.Active=false then begin
 showmessage('Stations not selected');
 Exit;
end;

DT1:=NOW;
memo1.Lines.Add('...find fixed stations in data: ');
memo1.Lines.Add('...start: '+datetimetostr(DT1));


frmdm.q.DisableControls;
frmdm.q.First;

Label3.Caption:='...progress';
Label3.Visible:=true;
Application.ProcessMessages;

{#FS1: populate STATION from frmdm.Q}
    n:=0;
{Q}while not frmdm.q.EOF do begin
    inc(n);

    Label3.Caption:='...station# '+inttostr(n);
    Application.ProcessMessages;

    SetLength(Station,n);
    Station[n-1].station_id:=frmdm.q.FieldByName('id').AsInteger;
    Station[n-1].cruise_id:=frmdm.q.FieldByName('cruise_id').AsInteger;
    Station[n-1].lat:=frmdm.q.FieldByName('latitude').AsFloat;
    Station[n-1].lon:=frmdm.q.FieldByName('longitude').AsFloat;
    Station[n-1].time:=frmdm.q.FieldByName('dateandtime').AsDateTime;

    with frmdm.q1 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select platform_id from Cruise ');
       SQL.Add(' where id=:cruise_id ');
       ParamByName('cruise_id').AsInteger:=Station[n-1].cruise_id;
       Open;
       platform_id:=FieldByName('platform_id').AsInteger;
       Close;
     end;

    Station[n-1].platform_id:=platform_id;

    frmdm.q.Next;
{Q}end;
    frmdm.q.EnableControls;
    memo1.Lines.Add('');
    memo1.Lines.Add('Length(Station)='+inttostr(Length(Station)));



{#FS2: populate FSTATION from STATION using coordinates limits}
   {...add first station to FStation}
   n:=1;
   SetLength(FStation,n);
   FStation[n-1].lat:=Station[0].lat;
   FStation[n-1].lon:=Station[0].lon;
   FStation[n-1].time_min:=Station[0].time;
   FStation[n-1].time_max:=Station[0].time;
   FStation[n-1].stcount:=1;

   {...position limit}
   pl:=strtofloat(Edit2.Text);

{S}for i:=1 to High(Station) do begin
   new:=true;
   Label3.Caption:='...station: '+inttostr(i);
   Application.ProcessMessages;
{FS}for j:=0 to High(FStation) do begin

    if (Station[i].lat>FStation[j].lat-pl) and (Station[i].lat<FStation[j].lat+pl)
   and (Station[i].lon>FStation[j].lon-pl) and (Station[i].lon<FStation[j].lon+pl)
   then begin
     new:=false;
     FStation[j].stcount:=FStation[j].stcount+1;
     if FStation[j].time_min>Station[i].time then FStation[j].time_min:=Station[i].time;
     if FStation[j].time_max<Station[i].time then FStation[j].time_max:=Station[i].time;
    end;
{FS}end;
    if new=true then begin
     inc(n);
     SetLength(FStation,n);
     FStation[n-1].lat:=Station[i].lat;
     FStation[n-1].lon:=Station[i].lon;
     FStation[n-1].time_min:=Station[i].time;
     FStation[n-1].time_max:=Station[i].time;
     FStation[n-1].stcount:=1;
    end;
{S}end;
     memo1.Lines.Add('');
     memo1.Lines.Add('Length(FStation)='+inttostr(Length(FStation)));




{#FS3: test/populate ENTRY using arbitrarily defined time series constraints}
     with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select max(id) as id_max from ENTRY ');
      Open;
      id_max:=FieldByName('id_max').AsInteger;
      Close;
     end;

    memo1.Lines.Add('');
    memo1.Lines.Add('#'+#9+'lat'+#9+'lon'+#9+'stcount'+#9+'days'+#9+'dt_min'+#9+'dt_max');
    fsc:=0; //fixed stations count
    db:=0; //days between
{FS}for i:=0 to High(FStation) do begin

    Label3.Caption:='...fixed station: '+inttostr(i);
    Application.ProcessMessages;

    db:=Daysbetween(FStation[i].time_min,FStation[i].time_max);

    {...definition of a fixed station using time series constraints}
{if}if (db>=strtoint(Edit3.Text)) and (FStation[i].stcount>=strtoint(Edit4.Text))
    then begin
     inc(fsc);
     str:='FS_'+floattostr(FStation[i].lat)+'_'+floattostr(FStation[i].lon);

     memo1.Lines.Add(inttostr(fsc)
     +#9+floattostrF(FStation[i].lat,ffFixed,12,5)
     +#9+floattostrF(FStation[i].lon,ffFixed,12,5)
     +#9+inttostr(FStation[i].stcount)
     +#9+inttostr(db)
     //+#9+datetimetostr(FStation[i].time_min)
     //+#9+datetimetostr(FStation[i].time_max)
     +#9+FormatDateTime('DD.MM.YYYY',FStation[i].time_min)
     +#9+FormatDateTime('DD.MM.YYYY',FStation[i].time_max)
     );

{db}if CheckBox2.Checked then begin
     with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' insert into ENTRY ');
        SQL.Add(' (id, entry_type_id, title, date_start, date_end,  ');
        SQL.Add(' stations_amount, date_added, date_updated) ');
        SQL.Add(' values ');
        SQL.Add(' (:entry_id, :entry_type_id, :title, :date_start, :date_end,  ');
        SQL.Add(' :stations_amount, :date_added, :date_updated) ');
        ParamByName('entry_id').AsInteger:=fsc+id_max;
        ParamByName('entry_type_id').AsInteger:=2;  //fixed station
        ParamByName('title').AsString:=str;
        ParamByName('date_start').AsDateTime:=FStation[i].time_min;
        ParamByName('date_end').AsDateTime:=FStation[i].time_max;
        ParamByName('stations_amount').AsInteger:=FStation[i].stcount;
        ParamByName('date_added').AsDateTime:=NOW;
        ParamByName('date_updated').AsDateTime:=NOW;
        ExecSQL;
      end;
        frmdm.TR.CommitRetaining;
{db}end;


{#FS4: populate STATION_ENTRY using arbitrarily defined time series constraints}
{S}for j:=0 to High(Station) do begin
{P}if  (Station[j].lat>FStation[i].lat-pl) and (Station[j].lat<FStation[i].lat+pl)
  and  (Station[j].lon>FStation[i].lon-pl) and (Station[j].lon<FStation[i].lon+pl)
  then begin
{db}if CheckBox2.Checked then begin
    with frmdm.q2 do begin
      Close;
      SQL.Clear;
      SQL.Add(' insert into STATION_ENTRY ');
      SQL.Add(' (station_id, entry_id) ');
      SQL.Add(' values ');
      SQL.Add(' (:station_id, :entry_id) ');
      ParamByName('station_id').AsInteger:=Station[j].station_id;
      ParamByName('entry_id').AsInteger:=fsc+id_max;
      ExecSQL;
    end;
      frmdm.TR.CommitRetaining;
{db}end;

{P}end;
{S}end;

{if}end;
{FC}end;


{#FS5 update station_amount in ENTRY from STATION_ENTRY}
{db}if CheckBox2.Checked then begin
     Label3.Caption:='...update ENTRY (stations_amount)';
     Application.ProcessMessages;        memo1.Lines.Add('');
     memo1.Lines.Add('Update ENTRY set stations_amount');
     with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select entry_id, count(entry_id) from STATION_ENTRY ');
      SQL.Add(' group by entry_id ');
      Open;
     end;
{SE}while not frmdm.q1.EOF do begin
    entry_id:=frmdm.q1.FieldByName('entry_id').AsInteger;
    sa:=frmdm.q1.FieldByName('count').AsInteger;
    memo1.Lines.Add(inttostr(entry_id)+#9+ inttostr(sa));
    with frmdm.q2 do begin
     Close;
     SQL.Clear;
     SQL.Add(' update ENTRY set stations_amount=:sa ');
     SQL.Add(' where id=:entry_id ');
     ParamByName('sa').AsInteger:=sa;
     ParamByName('entry_id').AsInteger:=entry_id;
     ExecSQL;
    end;
      frmdm.q1.Next;
{SE}end;
      frmdm.q1.Close;
      frmdm.TR.CommitRetaining;
{db}end;

{#FS6 assign entries as cruises}
{CB3}if CheckBox3.Checked then begin
memo1.Lines.Add('');
memo1.Lines.Add('entry -> cruises');
memo1.Lines.Add('new_cruise_id'+#9+'st#'+#9+'entry_title'
                +#9+'lat_min'+#9+'lat_max'+#9+'lon_min'+#9+'lon_max'
                +#9+'date_start'+#9+'date_end');

     with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select max(id) as mcn from CRUISE ');
      Open;
      mcn:=FieldByName('mcn').AsInteger;  //max cruise number
      Close;
    end;

    with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select id,title from ENTRY ');
     Open;
    end;

     ec:=0; //entry count
{q1}while not frmdm.q1.EOF do begin
    inc(ec);
    entry_id:=frmdm.q1.FieldByName('id').AsInteger;
    entry_title:=frmdm.q1.FieldByName('title').AsString;
    ncn:=mcn+ec; //new cruise number

   with frmdm.q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select count(id) as stinc, ');
    SQL.Add(' min(dateandtime) as minDT, max(dateandtime) as maxDT, ');
    SQL.Add(' min(latitude) as minlat, max(latitude) as maxlat, ');
    SQL.Add(' min(longitude) as minlon, max(longitude) as maxlon ');
    SQL.Add(' from STATION ');
    SQL.Add(' where id in (select station_id from STATION_ENTRY where entry_id=:entry_id) ');
    ParamByName('entry_id').AsInteger:=entry_id;
    Open;
    stinc:=FieldByName('stinc').AsInteger;       //stations in cruise
    minDT:=FieldByName('minDT').AsDateTime;
    maxDT:=FieldByName('maxDT').AsDateTime;
    minlat:=FieldByName('minlat').AsFloat;
    maxlat:=FieldByName('maxlat').AsFloat;
    minlon:=FieldByName('minlon').AsFloat;
    maxlon:=FieldByName('maxlon').AsFloat;
    Close;
   end;

   memo1.Lines.Add(inttostr(ncn)
   +#9+inttostr(stinc)
   +#9+entry_title
   +#9+floattostrF(minlat,ffFixed,10,5)
   +#9+floattostrF(maxlat,ffFixed,10,5)
   +#9+floattostrF(minlon,ffFixed,10,5)
   +#9+floattostrF(maxlon,ffFixed,10,5)
   +#9+FormatDateTime('DD.MM.YYYY',minDT)
   +#9+FormatDateTime('DD.MM.YYYY',maxDT)
   //+#9+datetimetostr(minDT)
   //+#9+datetimetostr(maxDT)
   );

   {...update cruise}
{db}if CheckBox2.Checked then begin

  Label3.Caption:='...assign fixed stations as cruises';
  Application.ProcessMessages;

    platform_id:=20547; //multiple ships, miscellaneous organization
    source_id:=9999; //multiple sources
    with frmdm.q2 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select cruise_id, count(cruise_id) from STATION ');
      SQL.Add(' where id in (select station_id from STATION_ENTRY where entry_id=:entry_id) ');
      SQL.Add(' group by cruise_id ');
      ParamByName('entry_id').AsInteger:=entry_id;
      Open;
      cruise_id:=FieldByName('cruise_id').AsInteger; //most frequent cruise in the entry
      Close;
    end;

    with frmdm.q2 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select platform_id, source_id from CRUISE ');
      SQL.Add(' where id=:cruise_id ');
      ParamByName('cruise_id').AsInteger:=cruise_id;
      Open;
      platform_id:=FieldByName('platform_id').AsInteger;
      source_id:=FieldByName('source_id').AsInteger;
      Close;
    end;

    //memo1.Lines.Add('source_id='+inttostr(source_id)+'  platform_id='+inttostr(platform_id));

    with frmdm.q2 do begin
      Close;
      SQL.Clear;
      SQL.Add(' insert into CRUISE ');
      SQL.Add(' (id, platform_id, source_id, expocode, cruise_number,  ');
      SQL.Add(' date_start_database, date_end_database,  ');
      SQL.Add(' notes,  ');
      SQL.Add(' latitude_min, latitude_max, longitude_min, longitude_max,  ');
      SQL.Add(' date_added, date_updated, ');
      SQL.Add(' stations_total)  ');
      SQL.Add(' values ');
      SQL.Add(' (:id, :platform_id, :source_id, :expocode, :cruise_number,  ');
      SQL.Add(' :date_start_database, :date_end_database,  ');
      SQL.Add(' :notes,  ');
      SQL.Add(' :latitude_min, :latitude_max, :longitude_min, :longitude_max,  ');
      SQL.Add(' :date_added, :date_updated, ');
      SQL.Add(' :stations_total)  ');
      ParamByName('id').AsInteger:=ncn;
      ParamByName('platform_id').AsInteger:=platform_id;
      ParamByName('source_id').AsInteger:=source_id;
      ParamByName('expocode').AsString:='Was added from ENTRY'+' ID='+inttostr(ec);
      ParamByName('cruise_number').AsString:=entry_title;
      ParamByName('date_start_database').AsDateTime:=minDT;
      ParamByName('date_end_database').AsDateTime:=maxDT;
      ParamByName('notes').AsString:='source_id and platform_id defined as most frequent in the entry';
      ParamByName('latitude_min').AsFloat:=minlat;
      ParamByName('latitude_max').AsFloat:=maxlat;
      ParamByName('longitude_min').AsFloat:=minlon;
      ParamByName('longitude_max').AsFloat:=maxlon;
      ParamByName('date_added').AsDateTime:=NOW;
      ParamByName('date_updated').AsDateTime:=NOW;
      ParamByName('stations_total').AsInteger:=stinc;
      ExecSQL;
    end;
      frmdm.TR.CommitRetaining;

     {...update cruise_id in STATION}
     {...cruise_id foreign key should be deleted drom STATION manually in IBExpert }
    with frmdm.q2 do begin
      Close;
      SQL.Clear;
      SQL.Add(' update STATION set cruise_id=:ncn ');
      SQL.Add(' where station.id in ');
      SQL.Add(' (select station_id from station_entry where entry_id=:ec) ');
      ParamByName('ncn').AsInteger:=ncn;
      ParamByName('ec').AsInteger:=ec;
      ExecSQL;
    end;
      frmdm.TR.CommitRetaining;
{db}end;

    frmdm.q1.Next;
{q1}end;
    frmdm.q1.Close;

   {...update CRUISE.stations_database }
{q1}with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select id from CRUISE ');
     Open;
   end;
   while not frmdm.q1.EOF do begin
     cruise_id:=frmdm.q1.FieldByName('id').AsInteger;

      sincr:=0; //stations in cruise
     with frmdm.q2 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select count(id) as sincr from STATION ');
       SQL.Add(' where cruise_id=:cruise_id ');
       ParamByName('cruise_id').AsInteger:=cruise_id;
       Open;
       sincr:=FieldByName('sincr').AsInteger;
       Close;
     end;

      with frmdm.q2 do begin
       Close;
       SQL.Clear;
       SQL.Add(' update CRUISE set stations_database=:sincr ');
       SQL.Add(' where id=:cruise_id ');
       ParamByName('cruise_id').AsInteger:=cruise_id;
       ParamByName('sincr').AsInteger:=sincr;
       ExecSql;
     end;
       frmdm.TR.CommitRetaining;

     frmdm.q1.Next;
{q1}end;
    frmdm.q1.Close;

{CB3}end;



memo1.Lines.Add('');
memo1.Lines.Add('Fixed stations criteria:');
memo1.Lines.Add('Position  +/- '+floattostr(pl)+' degrees');
memo1.Lines.Add('Duration    >'+Edit3.Text+' days');
memo1.Lines.Add('Min st. num >'+Edit4.Text);
memo1.Lines.Add('');
memo1.Lines.Add('Number of fixed stations: '+inttostr(fsc));
if CheckBox2.Checked then memo1.Lines.Add('DB was updated')
   else memo1.Lines.Add('DB was not updated ("Write into DB?" checkbox has to be checked on the settings page)');

memo1.Lines.Add('');
Label3.Caption:='...done';

DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));

end;



end.

