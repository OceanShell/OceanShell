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
#FS5: assign entries as cruises (optional)}




unit osload_glodap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Buttons, ExtCtrls, comobj, variants, DateUtils, dynlibs, SQLDB, DB;



type

  { TfrmloadGLODAP }

  TfrmloadGLODAP = class(TForm)
    btnDownload: TBitBtn;
    btnFixedStations_A2: TBitBtn;
    btnFixedStations_A1: TBitBtn;
    btnUpdateCruise: TBitBtn;
    btnUpdateDOI: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    GroupBox4: TGroupBox;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo2: TMemo;
    mLog: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet5: TTabSheet;
    procedure btnDownloadClick(Sender: TObject);
    procedure btnFixedStations_A1Click(Sender: TObject);
    procedure btnFixedStations_A2Click(Sender: TObject);
  //  procedure btnUpdateCruiseTableClick(Sender: TObject);
    procedure btnUpdateCruiseClick(Sender: TObject);
    procedure btnUpdateDOIClick(Sender: TObject);
  private

  public

  end;

var
  frmloadGLODAP: TfrmloadGLODAP;
  DT1,DT2 :TDateTime;
  fi,fo :text;


implementation

uses osmain, dm, procedures, GibbsSeaWater, driver_fdb;

{$R *.lfm}

{ TfrmloadGLODAP }

procedure TfrmloadGLODAP.btnUpdateCruiseClick(Sender: TObject);
var
dat: text;

PathToCodesSource, buf_str, piname, st, code_nodc:string;
c, k, i, absnum, ID:integer;
wod_country:string;
wod_id, country_ID, wod_institute_id, wod_platform_id, stnum: integer;
source_id, platform_id, institute_id, project_id: integer;

cruise_ind, start_date, end_date, wmo_id, date_str: string;
Glodap_ID, country_name, platform_name: string;
notes_str: widestring;

expocode, cr_alias, dates, platform, chiefSc, carbonPI, HydroPI, OxygenPI: widestring;
NutrientPI, CFCPI, OrganicsPI, IsotopesPI, OtherPI:widestring;
mn, dd, yy: word;

fl1, fl2:boolean;

XL: oleVariant;
XLTemplate:Variant;
date1, date2:TDateTime;

TRt:TSQLTransaction;
Qt1, Qt2, Qt3:TSQLQuery;
begin
{$IFDEF WINDOWS}
try
mLog.Clear;

 btnUpdateCruise.Enabled:=false;


 frmosmain.OD.Filter:='GLODAPCruiseTable.xlsx|GLODAPCruiseTable.xlsx';
 if frmosmain.OD.Execute then PathToCodesSource:=frmosmain.OD.FileName else exit;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt1 :=TSQLQuery.Create(self);
  Qt1.Database:=frmdm.IBDB;
  Qt1.Transaction:=TRt;

  Qt2 :=TSQLQuery.Create(self);
  Qt2.Database:=frmdm.IBDB;
  Qt2.Transaction:=TRt;

  Qt3 :=TSQLQuery.Create(self);
  Qt3.Database:=frmdm.IBDB;
  Qt3.Transaction:=TRt;


  XLTemplate:=frmosmain.OD.FileName;

  try
   XL := CreateOleObject('Excel.Application');
   XL.Visible := False;
   XL.DisplayAlerts := False;
  except
   Showmessage('MS Excel is not installed');
   Exit;
  end;

  XL.WorkBooks.Open(XLTemplate);

   k:=1;
   repeat
    inc(k);

    if vartostr(Xl.Cells[k, 1].Value)='' then exit;

    expocode:=''; cr_alias:=''; dates:=''; platform_name:=''; chiefsc:='';
    CarbonPI:=''; HydroPI:=''; OxygenPI:=''; NutrientPI:=''; CFCPI:='';
    OrganicsPI:=''; IsotopesPI:=''; OtherPI:='';

 {   showmessage(vartostr(Xl.Cells[k, 1].Value)+#13+
    vartostr(Xl.Cells[k, 2].Value)+#13+
    vartostr(Xl.Cells[k, 3].Value)+#13+
    vartostr(Xl.Cells[k, 4].Value)+#13+
    vartostr(Xl.Cells[k, 5].Value)+#13+
    vartostr(Xl.Cells[k, 6].Value)+#13+
    vartostr(Xl.Cells[k, 7].Value)+#13+
    vartostr(Xl.Cells[k, 8].Value)+#13+
    vartostr(Xl.Cells[k, 9].Value)+#13+
    vartostr(Xl.Cells[k, 10].Value)+#13+
    vartostr(Xl.Cells[k, 11].Value)+#13+
    vartostr(Xl.Cells[k, 12].Value)+#13+
    vartostr(Xl.Cells[k, 13].Value)+#13+
    vartostr(Xl.Cells[k, 14].Value));     }

     Glodap_ID:= vartostr(Xl.Cells[k, 1].Value);

     with Qt1 do begin
       Close;
        SQL.Clear;
        SQL.Add(' select ID from CRUISE ');
        SQL.Add(' where id=:ID ');
        ParamByName('ID').AsString:=Glodap_ID;
       Open;
     end;

   if not Qt1.IsEmpty then Continue; //skipping existing rows
 //   if strtoint(glodap_id)<4000 then Continue; //skipping existing rows

     EXPOCODE:=  vartostr(Xl.Cells[k, 2].Value);
     Cr_Alias:=  vartostr(Xl.Cells[k, 3].Value);
     dates:=     vartostr(Xl.Cells[k, 4].Value);
     platform:=  vartostr(Xl.Cells[k, 5].Value);
     ChiefSc:=   vartostr(Xl.Cells[k, 6].Value);
     CarbonPI:=  vartostr(Xl.Cells[k, 7].Value);
     HydroPI:=   vartostr(Xl.Cells[k, 8].Value);
     OxygenPI:=  vartostr(Xl.Cells[k, 9].Value);
     NutrientPI:=vartostr(Xl.Cells[k, 10].Value);
     CFCPI:=     vartostr(Xl.Cells[k, 11].Value);
     OrganicsPI:=vartostr(Xl.Cells[k, 12].Value);
     IsotopesPI:=vartostr(Xl.Cells[k, 13].Value);
     OtherPI:=   vartostr(Xl.Cells[k, 14].Value);

    notes_str:='';
    if ChiefSc<>''    then notes_str:='Chief scientist: '+ChiefSc+LineEnding;
    if CarbonPI<>''   then notes_str:=notes_str+'Carbon PI: '+CarbonPI+LineEnding;
    if HydroPI<>''    then notes_str:=notes_str+'Hydro PI: '+HydroPI+LineEnding;
    if OxygenPI<>''   then notes_str:=notes_str+'Oxygen PI: '+OxygenPI+LineEnding;
    if NutrientPI<>'' then notes_str:=notes_str+'Nutrient PI: '+NutrientPI+LineEnding;
    if CFCPI<>''      then notes_str:=notes_str+'CFC PI: '+CFCPI+LineEnding;
    if OrganicsPI<>'' then notes_str:=notes_str+'Organics PI: '+OrganicsPI+LineEnding;
    if IsotopesPI<>'' then notes_str:=notes_str+'Isotopes PI: '+IsotopesPI;
    if OtherPI<>''    then notes_str:=notes_str+'Other PI: '+OtherPI;


  if (strtoint(Glodap_ID)<>396) and
     (strtoint(Glodap_ID)<=718) then begin
   date1:=DateEncode(StrToInt(copy(EXPOCODE, 5, 4)),
                     StrToInt(copy(EXPOCODE, 9, 2)),
                     StrToInt(copy(EXPOCODE, 11, 2)),
                     0, 0, fl1, fl2);

   date_str:=trim(copy(dates, Pos('-',dates)+1, length(dates)));

   i:=0;
   for c:=1 to 3 do begin
    buf_str:='';
      repeat
        inc(i);
            if (date_str[i]<>'/') then buf_str:=buf_str+date_str[i];
      until (date_str[i]='/') or (i=length(date_str));
        if c=1 then mn:=StrToInt(trim(buf_str));
        if c=2 then dd:=StrToInt(trim(buf_str));
        if c=3 then yy:=StrToInt(trim(buf_str));
   end;
   date2:=DateEncode(yy, mn, dd, 0, 0, fl1, fl2);
  end;

  if strtoint(Glodap_ID)=396 then begin
    date1:=DateEncode(1990, 01, 27, 0, 0, fl1, fl2);
    date2:=DateEncode(1995, 08, 01, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=719 then begin
    date1:=DateEncode(2005, 01, 01, 0, 0, fl1, fl2);
    date2:=DateEncode(2007, 12, 31, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=720 then begin
    date1:=DateEncode(1991, 08, 15, 0, 0, fl1, fl2);
    date2:=DateEncode(2006, 10, 02, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=721 then begin
    date1:=DateEncode(1991, 08, 08, 0, 0, fl1, fl2);
    date2:=DateEncode(2006, 02, 02, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=722 then begin
    date1:=DateEncode(1993, 04, 01, 0, 0, fl1, fl2);
    date2:=DateEncode(1995, 11, 30, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=723 then begin
    date1:=DateEncode(1997, 06, 01, 0, 0, fl1, fl2);
    date2:=DateEncode(1999, 09, 30, 0, 0, fl1, fl2);
  end;
  if strtoint(Glodap_ID)=724 then begin
    date1:=DateEncode(2005, 01, 01, 0, 0, fl1, fl2);
    date2:=DateEncode(2009, 12, 31, 0, 0, fl1, fl2);
  end;

  if (strtoint(Glodap_ID)>=1000) then begin
    yy:=StrToInt(copy(dates, 1, 4));
    mn:=StrToInt(copy(dates, 5, 2));
    dd:=StrToInt(copy(dates, 7, 2));

    date1:=DateEncode(yy, mn, dd, 0, 0, fl1, fl2);

    yy:=StrToInt(copy(dates, 12, 4));
    mn:=StrToInt(copy(dates, 16, 2));
    dd:=StrToInt(copy(dates, 18, 2));

    date2:=DateEncode(yy, mn, dd, 0, 0, fl1, fl2);
  end;


  {    mlog.lines.add(glodap_id+'   '+datetimetostr(date1)+'   '+datetimetostr(date2));
   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' UPDATE CRUISE SET DATE_START_TOTAL=:D1, DATE_END_TOTAL=:D2  ');
     SQL.Add(' where ID=:ID ');
     ParamByName('ID').Value:=strtoint(glodap_id);
     ParamByName('D1').Value:=date1;
     ParamByName('D2').Value:=date2;
    ExecSQL;
   end;
   TrT.CommitRetaining;   }



   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, name from COUNTRY ');
     SQL.Add(' where NODC_CODE=:ID ');
     ParamByName('ID').AsString:=copy(EXPOCODE, 1, 2);
    Open;
     if Qt1.IsEmpty=false then begin
       country_id:=Qt1.Fields[0].AsInteger;
       country_name:=Qt1.Fields[1].AsString;
     end else country_id:=0;   //UNKNOWN
    Close;
   end;

   with Qt1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select ID, name from PLATFORM');
     SQL.Add(' where NODC_CODE=:ID ');
     ParamByName('ID').AsString:=copy(EXPOCODE, 1, 4);
    Open;
     if Qt1.IsEmpty=false then begin
       platform_id:=Qt1.Fields[0].AsInteger;
       platform_name:=Qt1.Fields[1].AsString;
     end else platform_id:=0;  //UNKNOWN PLATFORM
    Close;
   end;


   institute_id:=1; //UNKNOWN
   source_id:=1; //GLODAP
   project_id:=0; //UNKNOWN

    try
      PutFDBCruise(Qt2, strtoint(glodap_id), platform_id, source_id, institute_id,
         project_id, expocode, Cr_alias, UpperCase(ChiefSc), notes_str, null, null,
         date1, date2, now, now);
      Trt.CommitRetaining;
      mLog.Lines.add('Insert successful: '+st);
     except
       on E: Exception do begin
         if MessageDlg(E.Message, mtWarning, [mbOk], 0)=mrOk then exit;
          mLog.Lines.add('Insert error: '+st);
       end;
     end;

    mLog.Lines.Add(Glodap_ID+'   '+
                  platform_name+'   '+
                  datetostr(date1)+'   '+
                  datetostr(date2)+'   '+
                  country_name+'   '+
                  expocode+'   '+
                  cr_alias);

  until vartostr(Xl.Cells[k, 1].Value)='';

 finally
  XL.Quit;
  XL:=UnAssigned;

  btnUpdateCruise.Enabled:=true;
  Qt1.Free;
  Qt2.Free;
  TrT.Commit;
  TrT.Free;
  Showmessage(SDone);
 end;
{$ENDIF}
end;

procedure TfrmloadGLODAP.btnUpdateDOIClick(Sender: TObject);
Var
  ID: int64;
  fname: string;
  fi:text;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
  str, EXPOCODE, DOI: string;
  to_write:boolean;
begin
try
mLog.Clear;

 frmosmain.OD.Filter:='*_DOIs.csv|*_DOIs.csv';
 if frmosmain.OD.Execute then fname:=frmosmain.OD.FileName else exit;

  TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

   AssignFile(fi, fname); reset(fi);
   readln(fi);
   repeat
     readln(fi, str);

     EXPOCODE:=copy(str, 1, pos(',', str)-1);
     DOI:= copy(str, pos(',', str)+1, length(str));

     if pos(';', DOI)>0 then DOI:=copy(DOI,1,pos(';', DOI)-1);

     to_write:=false;
     with Qt do begin
       Close;
         SQL.Clear;
         SQL.Add(' SELECT ID, DOI FROM CRUISE ');
         SQL.Add(' WHERE ');
         SQL.Add(' ID<1000000 AND EXPOCODE=:EXPOCODE ');
         ParamByName('EXPOCODE').AsString:=EXPOCODE;
       Open;
     end;
     if not Qt.IsEmpty then begin
       ID:= Qt.Fields[0].Value;
       to_write:=VarIsNull(Qt.Fields[1].Value);
       Close;
     end else begin
       mlog.lines.add('Skipped: '+EXPOCODE+' -> '+ DOI);
     end;


     if to_write=true then begin
       with Qt do begin
        Close;
         SQL.Clear;
         SQL.Add(' UPDATE CRUISE SET DOI=:DOI ');
         SQL.Add(' WHERE ID=:ID ');
         ParamByName('ID').Value:=ID;
         ParamByName('DOI').Value:=DOI;
        ExecSQL;
       end;
         TrT.CommitRetaining;
       mlog.lines.add('Updated: '+EXPOCODE+' -> '+ DOI);
     end;

   until eof(fi);

finally
  closefile(fi);
  Qt.Free;
  TrT.Commit;
  TrT.Free;
  Showmessage(SDone);
end;

end;


procedure TfrmloadGLODAP.btnDownloadClick(Sender: TObject);
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
d,m,y,hh,mm :word;
dt,dt_min,dt_max :TDateTime;
new_cast,DayChange,DateChange :boolean;
//FuncZ:Tgsw_z_from_p;

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
G2c13qc,G2sf6qc :integer;

to_write: boolean;

label 10;

begin
DT1:=NOW;
mLog.Lines.Add('...start [populate database]: '+datetimetostr(DT1));
application.ProcessMessages;

   gfile:='X:\_Z\OceanShell\data\GLODAPv2.2023\GLODAPv2.2023_Merged_Master_File.csv';
   AssignFile(fi, gfile);

   testfile:='X:\_Z\OceanShell\data\GLODAPv2.2023\test.dat';
   AssignFile(fo, testfile);
   rewrite(fo);

   mLog.Lines.Add('...files opened');

   {...first line}
   {G2expocode,G2cruise,G2region,G2station,G2cast,G2year,G2month,G2day,G2hour,G2minute,
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
   GDBC[tc-1].sqf_col:=77;
   GDBC[tc-1].tbl_name:='P_PSF6';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=18;  //ppt
   {77   G2c13}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=78;
   GDBC[tc-1].pqf1_col:=79;
   GDBC[tc-1].sqf_col:=80;
   GDBC[tc-1].tbl_name:='P_C13';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=11;  //‰
   {80   G2c14}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=81;
   GDBC[tc-1].pqf1_col:=82;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_C14';
   GDBC[tc-1].tbl_type:=2;
   GDBC[tc-1].unit_id:=11;  //‰
   {83   G2h3}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=84;
   GDBC[tc-1].pqf1_col:=85;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_H3';
   GDBC[tc-1].tbl_type:=2;
   GDBC[tc-1].unit_id:=8;  //TU
   {86   G2he3}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=87;
   GDBC[tc-1].pqf1_col:=88;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_HE3';
   GDBC[tc-1].tbl_type:=2;
   GDBC[tc-1].unit_id:=10;  //%
   {89   G2he}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=90;
   GDBC[tc-1].pqf1_col:=91;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_HE';
   GDBC[tc-1].tbl_type:=2;
   GDBC[tc-1].unit_id:=12;  //nmol·kg-1
   {92   G2neon}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=93;
   GDBC[tc-1].pqf1_col:=94;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_NEON';
   GDBC[tc-1].tbl_type:=2;
   GDBC[tc-1].unit_id:=12;  //nmol·kg-1
   {95   G2o18}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=96;
   GDBC[tc-1].pqf1_col:=97;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_O18';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=11;  //‰
   {97   G2toc}
   inc(tc);
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=98;
   GDBC[tc-1].pqf1_col:=99;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_TOC';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=15;  //μmol·l-1
   {99   G2doc}
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=100;
   GDBC[tc-1].pqf1_col:=101;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_DOC';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=15;  //μmol·l-1
   {101   G2don}
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=102;
   GDBC[tc-1].pqf1_col:=103;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_DON';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=15;  //μmol·l-1
   {103   G2tdn}
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=104;
   GDBC[tc-1].pqf1_col:=105;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_TDN';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=15;  //μmol·l-1
   {105   G2chla}
   SetLength(GDBC,tc);
   GDBC[tc-1].val_col:=106;
   GDBC[tc-1].pqf1_col:=107;
   GDBC[tc-1].sqf_col:=0;
   GDBC[tc-1].tbl_name:='P_CHLOROPHYLL';
   GDBC[tc-1].tbl_type:=1;
   GDBC[tc-1].unit_id:=14;  //μg·kg-1

   {...check GDBC}
   mLog.Lines.Add('');
   mLog.Lines.Add('vcol#'+#9+'pqf1#'+#9+'sqf#'+#9+'tbl_name'+#9+'tbl_type'+#9+'unit_id');
   for ktbl:=0 to high(GDBC) do begin
    mLog.Lines.Add(inttostr(GDBC[ktbl].val_col)
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

   //skipping expocode
   str:=copy(str, pos(',', str)+1, length(str));

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
     mLog.Lines.Add('');
     mLog.Lines.Add('col#'+#9+'col_name');
   for i:=0 to High(GHeader) do begin
     mLog.Lines.Add(inttostr(i+1)+#9+GHeader[i].col_name);
   end;



{...#C1}
   {...create GMD dynamical array to split file on GLODAP stations}
   mLog.Lines.Add('');
   mLog.Lines.Add('...reformatting MD');
   Label2.Caption:='...progress';
   Label2.Visible:=true;

   Reset(fi);
   readln(fi, str);
   ln:=1; //line number
   Label2.Caption:='line='+inttostr(ln);
   Application.ProcessMessages;
{W}repeat
     readln(fi, str);
     inc(ln);
     if ln mod(1000)=0 then begin
       Label2.Caption:='line='+inttostr(ln);
       Application.ProcessMessages;
     end;

     //skipping expocode
     str:=copy(str, pos(',', str)+1, length(str));
     i:=0;
     for vn:=1 to 4 do begin
        buf_str:='';
        repeat
          inc(i);
          if str[i]<>',' then buf_str:=buf_str+str[i];
        until str[i]=',';
        case vn of
          1:if trim(buf_str)<>'' then g_cruise := trunc(strtofloat(buf_str)) else g_cruise:=-99999;
          2:if trim(buf_str)<>'' then g_st     := trunc(strtofloat(buf_str)) else g_st:=-99999;
          3:if trim(buf_str)<>'' then g_region := trunc(strtofloat(buf_str)) else g_region:=-99999;
          4:if trim(buf_str)<>'' then g_cast   := trunc(strtofloat(buf_str)) else g_cast:=-99999;
        end; {case}
     end;

      SetLength(GMD,ln-1);
      GMD[ln-2].G_line:=ln;
      GMD[ln-2].G_cruise:=g_cruise;
      GMD[ln-2].G_st:=g_st;
      GMD[ln-2].G_cast:=g_cast;

      {...control md problems in master file}
      if g_cruise=-99999 then
      mLog.Lines.Add('cruise number is not integer in line='+inttostr(ln)+'  '+g_cruise_str);
      if g_st=-99999 then
      mLog.Lines.Add('station number is not integer in line='+inttostr(ln)
      +'  '+g_st_str+'  changed to '+inttostr(g_st));
      if g_cast=-99999 then
      mLog.Lines.Add('cast number is not integer in line='+inttostr(ln)+'  '+g_cast_str);
{W}until EOF(fi);
     closefile(fi);
     Label2.Caption:='line='+inttostr(ln);
     Application.ProcessMessages;

     mLog.Lines.Add('');
     mLog.Lines.Add('[GMD] lines#='+inttostr(length(GMD)));

     mLog.Lines.Add(inttostr(GMD[ln-2].G_cruise)+'   '+
                    inttostr(GMD[ln-2].G_st)+'   '+
                    inttostr(GMD[ln-2].G_cast));


{...#C2}
   {...create NewSt}
     stn:=1;
     stncr:=0;
     SetLength(NewSt,stn);
     NewSt[stn-1]:=2; //start of the first station
     crn:=0;
     mLog.Lines.Add('');
     mLog.Lines.Add('...GLODAP cruises ');
     mLog.Lines.Add('cruise#'+#9+'st#');
{L}for i:=0 to high(GMD)-1 do begin
     if (GMD[i].G_st<>GMD[i+1].G_st) or (i=high(GMD)-1) then begin
       stn:=stn+1;
       stncr:=stncr+1;
       SetLength(NewSt,stn);
       NewSt[stn-1]:=GMD[i+1].G_line;
     end;
     if (GMD[i].G_cruise<>GMD[i+1].G_cruise) or (i=high(GMD)-1) then begin
      crn:=crn+1;
      mLog.Lines.Add(inttostr(GMD[i].G_cruise)+#9+inttostr(stncr));
      stncr:=0;
     end;
{L}end;
   mLog.Lines.Add(inttostr(GMD[i].G_cruise)+#9+inttostr(stncr));

//showmessage('here');
 {
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
      dt_min:=encodedatetime(2099,1,1,0,0,0,0);
      dt_max:=encodedatetime(1900,1,1,0,0,0,0);
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

      //skipping expocode
      str:=copy(str, pos(',', str)+1, length(str));

{STR}for i:=1 to length(str) do begin
      symbol:=str[i];
      if (symbol<>',') then buf_str:=buf_str+symbol;
{COL}if (symbol=',') or (i=length(str)) then begin
      inc(vn);
     case vn of
       1:if trim(buf_str)<>'' then g_cruise := trunc(strtofloat(buf_str)) else g_cruise:=-99999;
       2:if trim(buf_str)<>'' then g_st     := trunc(strtofloat(buf_str)) else g_st:=-99999;
       3:if trim(buf_str)<>'' then g_region := trunc(strtofloat(buf_str)) else g_region:=-99999;
       4:if trim(buf_str)<>'' then g_cast   := trunc(strtofloat(buf_str)) else g_cast:=-99999;
       5: y:=trunc(strtofloat(trim(buf_str)));
       6: m:=trunc(strtofloat(trim(buf_str)));
       7: d:=trunc(strtofloat(trim(buf_str)));
       8: hh:=trunc(strtofloat(trim(buf_str)));
       9: mm:=trunc(strtofloat(trim(buf_str)));
      10: if trystrtofloat(buf_str,g_lat) then g_lat :=strtofloat(buf_str) else g_lat:=-99999;
      11: if trystrtofloat(buf_str,g_lon) then g_lon :=strtofloat(buf_str) else g_lon:=-99999;
     end;{case}
      buf_str:='';
{COL}end;
{STR}end;

      {...date}
      if (hh=-9999) or (hh=55537) then hh:=0;
      if (mm=-9999) or (mm=55537) then mm:=0;
      dt:=encodedatetime(y,m,d,hh,mm,0,0);

      if dt_min>dt then dt_min:=dt;
      if dt_max<dt then dt_max:=dt;
      if cast_min>g_cast then cast_min:=g_cast;
      if cast_max<g_cast then cast_max:=g_cast;
      if lat_min>g_lat   then lat_min:=g_lat;
      if lat_max<g_lat   then lat_max:=g_lat;
      if lon_min>g_lon   then lon_min:=g_lon;
      if lon_max<g_lon   then lon_max:=g_lon;

{LEV}end;

 {    writeln(fo,inttostr(kst+1)
     +#9+inttostr(g_cruise)
     +#9+inttostr(g_st)
     +#9+inttostr(NewSt[kst])
     +#9+inttostr(stlevn)
     +#9+inttostr(cast_min)+'->'+inttostr(cast_max)
     +#9+datetimetostr(dt_min)+'->'+datetimetostr(dt_max)
     +#9+floattostr(lat_min)+'->'+floattostr(lat_max)
     +#9+floattostr(lon_min)+'->'+floattostr(lon_max)
     );  }

{ST} end;
     //closefile(fo);
}
{...#D }
   {...create GSt}
 {  writeln(fo,'');
   writeln(fo,'...casts analysis');
   writeln(fo,'#'+#9+'cr#'+#9+'st#'+#9+'cast#'); }

   reset(fi);
   readln(fi,str);
   dsc:=0; //database stations count

   with frmdm.q1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT max(ID) FROM STATION WHERE ');
       SQL.Add(' ID<1000000 ');
      Open;
       dsc:=frmdm.q1.Fields[0].Value;
      Close;
     end;

// showmessage(inttostr(dsc));

{ST}for kst:=0 to high(NewSt)-1 do begin
     //label2.Caption:='station: '+inttostr(kst+1);
     //if kst mod 10=0 then Application.ProcessMessages;
     stlevn:=NewSt[kst+1]-NewSt[kst];
     SetLength(GSt,0,0);

{LEV}for kl:=1 to stlevn do begin
      readln(fi,str);
      buf_str:='';
      vn:=0;

      //skipping expocode
      str:=copy(str, pos(',', str)+1, length(str));

{STR}for i:=1 to length(str) do begin
      symbol:=str[i];
      if (symbol<>',') then buf_str:=buf_str+symbol;
{COL}if (symbol=',') or (i=length(str)) then begin
      inc(vn);
  case vn of
     1:if trim(buf_str)<>'' then g_cruise := trunc(strtofloat(buf_str)) else g_cruise:=-99999;
     2:if trim(buf_str)<>'' then g_st     := trunc(strtofloat(buf_str)) else g_st:=-99999;
     3:if trim(buf_str)<>'' then g_region := trunc(strtofloat(buf_str)) else g_region:=-99999;
     4:if trim(buf_str)<>'' then g_cast   := trunc(strtofloat(buf_str)) else g_cast:=-99999;
     5: y:=trunc(strtofloat(trim(buf_str)));
     6: m:=trunc(strtofloat(trim(buf_str)));
     7: d:=trunc(strtofloat(trim(buf_str)));
     8: hh:=trunc(strtofloat(trim(buf_str)));
     9: mm:=trunc(strtofloat(trim(buf_str)));
     10: if trystrtofloat(buf_str,g_lat) then g_lat:=strtofloat(buf_str) else g_lat:=-99999;
     11: if trystrtofloat(buf_str,g_lon) then g_lon:=strtofloat(buf_str) else g_lon:=-99999;
     12: if trystrtofloat(buf_str,G2bottomdepth) then G2bottomdepth:=strtofloat(buf_str) else G2bottomdepth:=-99999;
     13: if trystrtofloat(buf_str,G2maxsampdepth) then G2maxsampdepth:=strtofloat(buf_str) else G2maxsampdepth:=-99999;
     14: if trim(buf_str)<>'' then G2bottle:=trunc(strtofloat(buf_str)) else G2bottle:=-99999;
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
     77: if trystrtoint(buf_str,G2sf6qc) then G2sf6qc:=strtoint(buf_str) else G2sf6qc:=-99999;

     78: if trystrtofloat(buf_str,G2c13) then G2c13:=strtofloat(buf_str) else G2c13:=-99999;
     79: if trystrtoint(buf_str,G2c13f) then G2c13f:=strtoint(buf_str) else G2c13f:=-99999;
     80: if trystrtoint(buf_str,G2c13qc) then G2c13qc:=strtoint(buf_str) else G2c13qc:=-99999;

     81: if trystrtofloat(buf_str,G2c14) then G2c14:=strtofloat(buf_str) else G2c14:=-99999;
     82: if trystrtoint(buf_str,G2c14f) then G2c14f:=strtoint(buf_str) else G2c14f:=-99999;
     83: if trystrtofloat(buf_str,G2c14err) then G2c14err:=strtofloat(buf_str) else G2c14err:=-99999;

     84: if trystrtofloat(buf_str,G2h3) then G2h3:=strtofloat(buf_str) else G2h3:=-99999;
     85: if trystrtoint(buf_str,G2h3f) then G2h3f:=strtoint(buf_str) else G2h3f:=-99999;
     86: if trystrtofloat(buf_str,G2h3err) then G2h3err:=strtofloat(buf_str) else G2h3err:=-99999;

     87: if trystrtofloat(buf_str,G2he3) then G2he3:=strtofloat(buf_str) else G2he3:=-99999;
     88: if trystrtoint(buf_str,G2he3f) then G2he3f:=strtoint(buf_str) else G2he3f:=-99999;
     89: if trystrtofloat(buf_str,G2he3err) then G2he3err:=strtofloat(buf_str) else G2he3err:=-99999;

     90: if trystrtofloat(buf_str,G2he) then G2he:=strtofloat(buf_str) else G2he:=-99999;
     91: if trystrtoint(buf_str,G2hef) then G2hef:=strtoint(buf_str) else G2hef:=-99999;
     92: if trystrtofloat(buf_str,G2heerr) then G2heerr:=strtofloat(buf_str) else G2heerr:=-99999;

     93: if trystrtofloat(buf_str,G2neon) then G2neon:=strtofloat(buf_str) else G2neon:=-99999;
     94: if trystrtoint(buf_str,G2neonf) then G2neonf:=strtoint(buf_str) else G2neonf:=-99999;
     95: if trystrtofloat(buf_str,G2neonerr) then G2neonerr:=strtofloat(buf_str) else G2neonerr:=-99999;

     96: if trystrtofloat(buf_str,G2o18) then G2o18:=strtofloat(buf_str) else G2o18:=-99999;
     97: if trystrtoint(buf_str,G2o18f) then G2o18f:=strtoint(buf_str) else G2o18f:=-99999;

     98: if trystrtofloat(buf_str,G2toc) then G2toc:=strtofloat(buf_str) else G2toc:=-99999;
     99: if trystrtoint(buf_str,G2tocf) then G2tocf:=strtoint(buf_str) else G2tocf:=-99999;

     100: if trystrtofloat(buf_str,G2doc) then G2doc:=strtofloat(buf_str) else G2doc:=-99999;
     101: if trystrtoint(buf_str,G2docf) then G2docf:=strtoint(buf_str) else G2docf:=-99999;

     102: if trystrtofloat(buf_str,G2don) then G2don:=strtofloat(buf_str) else G2don:=-99999;
     103: if trystrtoint(buf_str,G2donf) then G2donf:=strtoint(buf_str) else G2donf:=-99999;

     104: if trystrtofloat(buf_str,G2tdn) then G2tdn:=strtofloat(buf_str) else G2tdn:=-99999;
     105: if trystrtoint(buf_str,G2tdnf) then G2tdnf:=strtoint(buf_str) else G2tdnf:=-99999;

     106: if trystrtofloat(buf_str,G2chla) then G2chla:=strtofloat(buf_str) else G2chla:=-99999;
     107: if trystrtoint(buf_str,G2chlaf) then G2chlaf:=strtoint(buf_str) else G2chlaf:=-99999
     end;{case}
      buf_str:='';
{COL}end;
{STR}end;

     if (g_lon>180) and (g_lon<>-99999) then g_lon:=g_lon-360;

      {...date}
      if (hh=-9999) or (hh=55537) then hh:=0;
      if (mm=-9999) or (mm=55537) then mm:=0;
      dt:=encodedatetime(y,m,d,hh,mm,0,0);

      {...GLODAPv2.2021_Merged_Master_File.csv contains 106 columns}
      SetLength(GSt,kl,106);

      GSt[kl-1,0]:=g_cruise; //col=1
      GSt[kl-1,1]:=g_region; //2
      GSt[kl-1,2]:=g_st; //3
      GSt[kl-1,3]:=g_cast;  //4
      GSt[kl-1,4]:=y;  //5
      GSt[kl-1,5]:=m;  //6
      GSt[kl-1,6]:=d;  //7
      GSt[kl-1,7]:=hh;  //8
      GSt[kl-1,8]:=mm;  //9
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
      GSt[kl-1,76]:=G2sf6qc; //77

      GSt[kl-1,77]:=G2c13; //77
      GSt[kl-1,78]:=G2c13f; //78
      GSt[kl-1,79]:=G2c13qc; //79

      GSt[kl-1,80]:=G2c14; //80
      GSt[kl-1,81]:=G2c14f; //81
      GSt[kl-1,82]:=G2c14err; //82

      GSt[kl-1,83]:=G2h3; //83
      GSt[kl-1,84]:=G2h3f; //84
      GSt[kl-1,85]:=G2h3err; //85

      GSt[kl-1,86]:=G2he3; //86
      GSt[kl-1,87]:=G2he3f; //87
      GSt[kl-1,88]:=G2he3err; //88

      GSt[kl-1,89]:=G2he; //89
      GSt[kl-1,90]:=G2hef; //90
      GSt[kl-1,91]:=G2heerr; //91

      GSt[kl-1,92]:=G2neon; //92
      GSt[kl-1,93]:=G2neonf; //93
      GSt[kl-1,94]:=G2neonerr; //94

      GSt[kl-1,95]:=G2o18; //95
      GSt[kl-1,96]:=G2o18f; //96

      GSt[kl-1,97]:=G2toc; //97
      GSt[kl-1,98]:=G2tocf; //98

      GSt[kl-1,99]:=G2doc; //99
      GSt[kl-1,100]:=G2docf; //100

      GSt[kl-1,101]:=G2don; //101
      GSt[kl-1,102]:=G2donf; //102

      GSt[kl-1,103]:=G2tdn; //103
      GSt[kl-1,104]:=G2tdnf; //104

      GSt[kl-1,105]:=G2chla; //105
      GSt[kl-1,106]:=G2chlaf; //106
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

  { writeln(fo);
   write(fo,'GLODAP :'
   +#9+inttostr(kst+1)
   +#9+inttostr(g_cruise)
   +#9+inttostr(g_st)
   +#9+inttostr(length(StCasts)));
   write(fo,#9,'casts:');
   for kc:=0 to high(StCasts) do write(fo,inttostr(StCasts[kc])+' ');
   writeln(fo);   }



{#F1 devide GSt on casts}
{kc  }for kc:=0 to high(StCasts) do begin
        g_cast:=StCasts[kc];
        mik:=0;
{kl}  for kl:=0 to high(GSt) do begin

{cast}if g_cast=trunc(GSt[kl,3]) then begin
       inc(mik);

{#F2: populate STATION if is empty}
{STATION}if mik=1 then begin

       {...encode datetime}
       dt:= procedures.DateEncode(trunc(GSt[kl,4]),
       trunc(GSt[kl,5]),
       trunc(GSt[kl,6]),
       trunc(GSt[kl,7]),
       trunc(GSt[kl,8]),
       DayChange,DateChange);
       if DayChange=true  then mLog.Lines.Add('procedures.DateEncode: day  change at station '+inttostr(kst+1));
       if DateChange=true then mLog.Lines.Add('procedures.DateEncode: date change at station '+inttostr(kst+1));
       {...last level}
     //  FuncZ:=Tgsw_z_from_p(GetProcedureAddress(libgswteos, 'gsw_z_from_p'));
       LLm:=-gsw_z_from_p(GSt[kl,12], GSt[kl,9], 0, 0);  //last level meters
       {...StVersion}
       StVersion:=0;
       CountDup:=0;

       // is station already in the database?
       with frmdm.q1 do begin
         Close;
           SQL.Clear;
           SQL.Add(' Select ID from STATION ');
           SQL.Add(' where ');
           SQL.Add(' STATION.CRUISE_ID=:cr_id AND ');
           SQL.Add(' STATION.CAST_NUMBER=:cast_number AND ');
           SQL.Add(' STATION.dateandtime=:dt and ');
           SQL.Add(' STATION.latitude=:lat and ');
           SQL.Add(' STATION.longitude=:lon ');
           ParamByName('cr_id').Value:=GSt[kl,0];
           ParamByName('dt'   ).Value:=dt;
           ParamByName('lat'  ).Value:=GSt[kl,9];
           ParamByName('lon'  ).Value:=GSt[kl,10];
           ParamByName('cast_number').AsInteger:=g_cast;
          Open;
       end;

       to_write:=false;
       if not frmdm.q1.IsEmpty then begin
         mLog.Lines.Add('Exists: '+floattostr(GSt[kl,0])+'->'+floattostr(GSt[kl,2])+'->'+inttostr(g_cast));
         to_write:=false;
       end else begin
         mLog.Lines.Add('Missing: '+floattostr(GSt[kl,0])+'->'+floattostr(GSt[kl,2])+'->'+inttostr(g_cast));
         to_write:=true;
       end;
       frmdm.q1.Close;

{DB}if (to_write=true) then begin
      // new ID
      inc(dsc);

      writeln(fo,'===========================================================');
      writeln(fo,'STATION:'
       +#9,inttostr(dsc)
       +#9,inttostr(trunc(GSt[kl,0]))
       +#9,inttostr(trunc(GSt[kl,2]))
       +#9,inttostr(g_cast)
       +#9,datetimetostr(dt)
       +#9,floattostr(GSt[kl,9])
       +#9,floattostr(GSt[kl,10])
       );
      flush(fo);

    if (CheckBox2.Checked) then begin
      PutFDBStation(frmdm.q1, dsc, GSt[kl,9], GSt[kl,10], dt, trunc(GSt[kl,11]),
         trunc(GSt[kl,0]), floattostr(trunc(GSt[kl,2])), null, 0, 0, g_cast,
         null, now, now);
      frmdm.TR.CommitRetaining;
    end;

{DB}end;

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

        if (pqf1=-99999) or (pqf1=-9999) then begin
          pqf1:=0;
          pqf2:=0;
          sqf:=0;
        end;

{DB}if (to_write=true) then begin
      writeln(fo,tbl
              +#9+inttostr(dsc)
              +#9+'dbar='+floattostr(GSt[kl,14])
              +#9+floattostr(GSt[kl,15])
              +#9+floattostr(GSt[kl,vcol])
              +#9+inttostr(PQF1)
              +#9+inttostr(PQF2)
              +#9+inttostr(SQF)
              +#9+'btl='+inttostr(trunc(GSt[kl,13]))
              +#9+inttostr(uid));
      flush(fo);

      if CheckBox2.Checked then
        PutFDBProfile(frmdm.q1, tbl, dsc, GSt[kl,14], GSt[kl,15], GSt[kl,vcol], pqf1,
          pqf2, sqf, trunc(GSt[kl,13]), uid, 7, 1, true);
{DB}end;



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
mLog.Lines.Add('');
mLog.Lines.Add('...stop: '+datetimetostr(DT2));
mLog.Lines.Add('...time spent: '+datetimetostr(DT2-DT1));
end;




procedure TfrmloadGLODAP.btnFixedStations_A1Click(Sender: TObject);

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
dt_min,dt_max :TDateTime;

begin

if frmdm.q.Active=false then begin
 showmessage('Stations not selected');
 Exit;
end;

DT1:=NOW;
mLog.Lines.Add('...find fixed stations in data: ');
mLog.Lines.Add('...start: '+datetimetostr(DT1));


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
    mLog.Lines.Add('');
    mLog.Lines.Add('Length(Station)='+inttostr(Length(Station)));



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
   Label3.Caption:='...find fixed stations: '+inttostr(i);
   Application.ProcessMessages;
{FS}for j:=0 to High(FStation) do begin

    if (Station[i].lat>=FStation[j].lat-pl) and (Station[i].lat<=FStation[j].lat+pl)
   and (Station[i].lon>=FStation[j].lon-pl) and (Station[i].lon<=FStation[j].lon+pl)
   then begin
     new:=false;
     FStation[j].stcount:=FStation[j].stcount+1;
     if FStation[j].time_min>=Station[i].time then FStation[j].time_min:=Station[i].time;
     if FStation[j].time_max<=Station[i].time then FStation[j].time_max:=Station[i].time;
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
     mLog.Lines.Add('');
     mLog.Lines.Add('Length(FStation)='+inttostr(Length(FStation)));




{#FS3: test/populate ENTRY using arbitrarily defined time series constraints}
     with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select max(id) as id_max from ENTRY ');
      Open;
      id_max:=FieldByName('id_max').AsInteger;
      Close;
     end;

    mLog.Lines.Add('');
    mLog.Lines.Add('#'+#9+'lat'+#9+'lon'+#9+'stcount'+#9+'days'+#9+'dt_min'+#9+'dt_max');
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
     str:='lat'+floattostr(FStation[i].lat)
     +'_lon'+floattostr(FStation[i].lon)
     +'_pl'+floattostr(pl);


     with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select count(id) as sa, min(dateandtime) as dt_min, max(dateandtime) as dt_max ');
      SQL.Add(' from STATION ');
      SQL.Add(' where latitude >=:lat_min and latitude <=:lat_max and ');
      SQL.Add('       longitude>=:lon_min and longitude<=:lon_max ');
      ParamByName('lat_min').AsFloat:=FStation[i].lat-pl;
      ParamByName('lat_max').AsFloat:=FStation[i].lat+pl;
      ParamByName('lon_min').AsFloat:=FStation[i].lon-pl;
      ParamByName('lon_max').AsFloat:=FStation[i].lon+pl;
      Open;
      sa:=FieldByName('sa').AsInteger;
      dt_min:=FieldByName('dt_min').AsDateTime;
      dt_max:=FieldByName('dt_max').AsDateTime;
      Close;
     end;

     mLog.Lines.Add(inttostr(fsc)
     +#9+floattostrF(FStation[i].lat,ffFixed,12,5)
     +#9+floattostrF(FStation[i].lon,ffFixed,12,5)
     +#9+inttostr(sa)
     +#9+inttostr(db)
     +#9+FormatDateTime('DD.MM.YYYY',dt_min)
     +#9+FormatDateTime('DD.MM.YYYY',dt_max));

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
        ParamByName('date_start').AsDateTime:=dt_min;
        ParamByName('date_end').AsDateTime:=dt_max;
        ParamByName('stations_amount').AsInteger:=sa;
        ParamByName('date_added').AsDateTime:=NOW;
        ParamByName('date_updated').AsDateTime:=NOW;
        ExecSQL;
      end;
        frmdm.TR.CommitRetaining;
{db}end;


{#FS4: populate STATION_ENTRY using arbitrarily defined time series constraints}
{S}for j:=0 to High(Station) do begin
{P}if  (Station[j].lat>=FStation[i].lat-pl) and (Station[j].lat<=FStation[i].lat+pl)
  and  (Station[j].lon>=FStation[i].lon-pl) and (Station[j].lon<=FStation[i].lon+pl)
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



{#FS5: assign entries as cruises}
{CB3}if CheckBox3.Checked then begin
mLog.Lines.Add('');
mLog.Lines.Add('entry -> cruises');
mLog.Lines.Add('new_cruise_id'+#9+'st#'+#9+'entry_title'
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

   mLog.Lines.Add(inttostr(ncn)
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

    //mLog.Lines.Add('source_id='+inttostr(source_id)+'  platform_id='+inttostr(platform_id));

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



mLog.Lines.Add('');
mLog.Lines.Add('Fixed stations criteria:');
mLog.Lines.Add('Position  +/- '+floattostr(pl)+' degrees');
mLog.Lines.Add('Duration    >'+Edit3.Text+' days');
mLog.Lines.Add('Min st. num >'+Edit4.Text);
mLog.Lines.Add('');
mLog.Lines.Add('Number of fixed stations: '+inttostr(fsc));
if CheckBox2.Checked then mLog.Lines.Add('DB was updated')
   else mLog.Lines.Add('DB was not updated ("Write into DB?" checkbox has to be checked on the settings page)');

mLog.Lines.Add('');
Label3.Caption:='...done';

DT2:=NOW;
mLog.Lines.Add('...stop: '+datetimetostr(DT2));
mLog.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;



{...stations amount in squares}
procedure TfrmloadGLODAP.btnFixedStations_A2Click(
  Sender: TObject);
var
ss :real;
begin
DT1:=NOW;
mLog.Lines.Add('...find fixed stations in data (squares): ');
mLog.Lines.Add('...start: '+datetimetostr(DT1));

ss:=strtofloat(Edit1.Text);  //square size
mLog.Lines.Add('...square size: '+floattostr(ss));

DT2:=NOW;
mLog.Lines.Add('...stop: '+datetimetostr(DT2));
mLog.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;



end.

