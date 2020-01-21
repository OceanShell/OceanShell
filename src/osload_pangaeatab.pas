unit osload_PangaeaTab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, FileCtrl,
  Buttons, ExtCtrls, Grids, CheckLst, ListFilterEdit, IBConnection, DB, sqldb,
  SQLScript;


type

  { TfrmloadPangaeaTab }

  TfrmloadPangaeaTab = class(TForm)
    btnCheckCompliance: TBitBtn;
    btnDeleteSelected: TBitBtn;
    btnUpdateStation: TBitBtn;
    btnCreatePangeaeaDB: TBitBtn;
    btnDownloadPrf: TBitBtn;
    btnDownloadMD: TBitBtn;
    btnPreprocessing: TBitBtn;
    btnSelectProfiles: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    FileListBox1: TFileListBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Memo1: TMemo;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    StringGrid4: TStringGrid;
    procedure btnCheckComplianceClick(Sender: TObject);
    procedure btnCreatePangeaeaDBClick(Sender: TObject);
    procedure btnDeleteSelectedClick(Sender: TObject);
    procedure btnDownloadMDClick(Sender: TObject);
    procedure btnDownloadPrfClick(Sender: TObject);
    procedure btnPreprocessingClick(Sender: TObject);
    procedure btnSelectProfilesClick(Sender: TObject);
    procedure btnUpdateStationClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private

  public

  end;

var
  frmloadPangaeaTab: TfrmloadPangaeaTab;
  stcount:integer;
  stLine:array[1..10000] of integer;   //lines numbers in file where a new station starts
  PathSource:string;
  PathOut:string;
  fi,f_station:text;
  f_temp_ctd,f_salt_ctd,f_oxyg_ctd:text;

implementation

uses osmain, procedures, dm;

{$R *.lfm}

{ TfrmloadPangaeaTab }

procedure TfrmloadPangaeaTab.FormShow(Sender: TObject);
var
i,col:integer;
fn,st,buf:string;
colTitle_arr:array[1..100] of string;
begin
  memo1.Clear;
  FileListBox1.Clear;
  PathSource:='c:\Users\ako071\AK\datasets\Partners\Pangaea\download\';
  PathOut:='c:\Users\ako071\AK\datasets\Partners\Pangaea\output\';
  FileListBox1.Directory:=PathSource;


  //StringGrid1: columns in file
  fn:=PathSource+FileListBox1.Items.Strings[0];
  AssignFile(fi,concat(fn));
  Reset(fi);
  memo1.Lines.Add(fn);

{.....find string with MD and Profiles titles.....}
{r}repeat
  readln(fi,st);
{r}until (copy(st,1,9)<>'Event(s):') and (copy(st,1,5)='Event');

{.....columns titles string analysis}
{.....ASCII code for tab is 9}
  col:=0;
  buf:='';
{s}for i:=1 to length(st) do begin
  if ord(st[i])<>9 then buf:=buf+st[i]
  else begin
    col:=col+1;
    colTitle_arr[col]:=buf;
    buf:='';
  end;
{s}end;
   col:=col+1;
   colTitle_arr[col]:=buf;

   StringGrid1.ColCount:=2;
   StringGrid1.RowCount:=col+1;
   StringGrid1.ColWidths[0]:=200;
   StringGrid1.ColWidths[1]:=40;
   StringGrid1.Cells[0,0]:='column name';
   StringGrid1.Cells[1,0]:='col#';


   for i:=1 to col do begin
    StringGrid1.Cells[0,i]:=colTitle_arr[i];
    StringGrid1.Cells[1,i]:=inttostr(i);
   end;
   closefile(fi);



   //StringGrid2: DB tables
   frmdm.IBDB.GetTableNames(ListBox1.Items,False);
   for i:=0 to ListBox1.Items.Count-1 do
   if (copy(ListBox1.items.strings[i],1,2)='P_')
   then ListBox2.Items.Add(ListBox1.items.strings[i]);

   StringGrid2.ColCount:=3;
   StringGrid2.RowCount:=ListBox2.Items.Count+1;
   StringGrid2.ColWidths[0]:=40;
   StringGrid2.ColWidths[1]:=200;
   StringGrid2.ColWidths[2]:=40;
   StringGrid2.Cells[0,0]:='#';
   StringGrid2.Cells[1,0]:='title';
   StringGrid2.Cells[2,0]:='col#';

   for i:=0 to ListBox2.Items.Count-1 do begin
    StringGrid2.Cells[0,i+1]:=inttostr(i);
    StringGrid2.Cells[1,i+1]:=ListBox2.Items.Strings[i];
    StringGrid2.Cells[2,i+1]:=inttostr(0);
   end;

   StringGrid3.ColCount:=3;
   StringGrid3.RowCount:=6;
   StringGrid3.ColWidths[0]:=40;
   StringGrid3.ColWidths[1]:=200;
   StringGrid3.ColWidths[2]:=40;
   StringGrid3.Cells[0,0]:='#';
   StringGrid3.Cells[1,0]:='MD field';
   StringGrid3.Cells[2,0]:='col#';

   StringGrid3.Cells[0,1]:='1';
   StringGrid3.Cells[0,2]:='2';
   StringGrid3.Cells[0,3]:='3';
   StringGrid3.Cells[0,4]:='4';
   StringGrid3.Cells[0,5]:='5';

   StringGrid3.Cells[1,1]:='Station=Event';
   StringGrid3.Cells[1,2]:='Date/Time';
   StringGrid3.Cells[1,3]:='Latitude';
   StringGrid3.Cells[1,4]:='Longitude';
   StringGrid3.Cells[1,5]:='BD = Elevation';

   StringGrid3.Cells[2,1]:='1';
   StringGrid3.Cells[2,2]:='2';
   StringGrid3.Cells[2,3]:='3';
   StringGrid3.Cells[2,4]:='4';
   StringGrid3.Cells[2,5]:='5';

   StringGrid4.ColCount:=3;
   StringGrid4.RowCount:=3;
   StringGrid4.ColWidths[0]:=40;
   StringGrid4.ColWidths[1]:=200;
   StringGrid4.ColWidths[2]:=40;
   StringGrid4.Cells[0,0]:='#';
   StringGrid4.Cells[1,0]:='title';
   StringGrid4.Cells[2,0]:='col#';



end;







procedure TfrmloadPangaeaTab.StringGrid1SelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
begin
    Edit1.text:=inttostr(StringGrid1.Row);
end;


//procedure TfrmloadPangaeaTab.StringGrid2SelectCell(Sender: TObject; aCol,
//  aRow: Integer; var CanSelect: Boolean);
//begin
//   StringGrid2.Cells[acol,arow]:=Edit1.text;
//end;


procedure TfrmloadPangaeaTab.btnCheckComplianceClick(Sender: TObject);
var
i,vcount:integer;
begin

     vcount:=0; //variables to download
   for i:=1 to StringGrid2.RowCount-1 do
   if strtoint(StringGrid2.Cells[2,i])<>0 then vcount:=vcount+1;

   StringGrid4.RowCount:=vcount+1;


     vcount:=0;
{i}for i:=1 to StringGrid2.RowCount-1 do begin
{v}if strtoint(StringGrid2.Cells[2,i])<>0 then begin
     vcount:=vcount+1;
     memo1.Lines.Add(StringGrid2.Cells[1,i]+' -> '+StringGrid2.Cells[2,i]);

     StringGrid4.Cells[0,vcount]:=inttostr(vcount);
     StringGrid4.Cells[1,vcount]:=StringGrid2.Cells[1,i];
     StringGrid4.Cells[2,vcount]:=StringGrid2.Cells[2,i];

{v}end;
{i}end;
end;








procedure TfrmloadPangaeaTab.btnPreprocessingClick(Sender: TObject);
var
  i,kfile,stn,mik,ln1,ln2,md_count:integer;
  fn,st,buf,md_str:string;
  md_str_arr:array[1..10000] of string;
begin

{f}for kfile:=0 to FileListBox1.Items.Count-1 do begin
     fn:=PathSource+FileListBox1.Items.Strings[kfile];

     AssignFile(fi,concat(fn));
     Reset(fi);

     memo1.Lines.Add(inttostr(kfile+1)+#9+fn);

     stn:=0;
     mik:=0;
{w}while not EOF(fi) do begin
     readln(fi,st);
     mik:=mik+1;
     if copy(st,1,9)='Event(s):' then ln1:=mik;
     if copy(st,1,8)='Comment:'  then ln2:=mik;
{w}end;
     closefile(fi);

     stn:=ln2-ln1-1;
     memo1.Lines.Add('ln1:'+inttostr(ln1)+'   '+'Event(s):');
     memo1.Lines.Add('ln2:'+inttostr(ln2)+'   '+'Comment:');

     reset(fi);
     mik:=0;
     stn:=0;
{w}while not EOF(fi) do begin
     readln(fi,st);
     mik:=mik+1;
{m}if (mik>ln1) and (mik<ln2) then begin
     stn:=stn+1;

     st:=trim(st);

     md_count:=0;
     buf:='';
{s}for i:=1 to length(st) do begin
     if st[i]<>'*' then buf:=buf+st[i]
     else begin
          md_count:=md_count+1;
          md_str_arr[md_count]:=buf;
          buf:='';
     end;
{s}end;

     md_str:='';
   for i:=1 to md_count do md_str:=md_str+#9+md_str_arr[i];

     memo1.Lines.Add(inttostr(stn)+#9+md_str);
{m}end;
{w}end;


     closefile(fi);
     memo1.Lines.Add('st#:'+inttostr(stn));
{f}end;

end;





procedure TfrmloadPangaeaTab.btnDownloadMDClick(Sender: TObject);
var
i,kfile,kst,kline,kpr,kv,col,line,prfB,prfE,prfLn,fld,skln,mik:integer;
MDnum,vnum,fcol:integer;
ID,absnum:integer;
year,month,day,hour,min:integer;
DayChange,DateChange:Boolean;
fn,st,buf,StrOut,tbl:string;
//при объявлении слишком больших массивов возникает ошибка без четкой диагностики
colTitle_arr:array[1..100] of string;//depends on columns number in a file
Rec_arr:array[1..100] of string;     //depends on columns number in a file
stNum:array[1..2000000] of string;   //depends on lines number in a file

CruiseID,Instrument_ID,OrStID,OrCastNum,ST_QF,ST_VER,ST_DUP,ST_MERGED,ST_AcNum:integer;
StDepthSource:integer;
StLat,StLon,LastLev_m,LastLev_dbar:real;
OrStNum,DTst:string;
StDateTime:TDateTime;

PQF1,PQF2,SQF,BNum,UID:integer;
lev_m,lev_dbar,tempval_ctd,saltval_ctd,oxygval_ctd:real;

StVersion, countDup, MaxID:integer;
TEMPERATURE_CTD_Ex,SALINITY_CTD_Ex,OXYGEN_CTD_Ex:Boolean;



begin

     MDnum:=StringGrid3.RowCount-1;
     Vnum :=StringGrid4.RowCount-1;
     memo1.Lines.Add('Number of MD fields:'+inttostr(MDnum));
     memo1.Lines.Add('Number of variables:'+inttostr(Vnum));

     fn:=PathOut+'STATION.dat';
     AssignFile(f_station,fn);
     StrOut:='ID'+#9+'LATITUDE'+#9+'LONGITUDE'+#9+'DATEANDTIME'+#9+'BOTTOMDEPTH'
     +#9+'LASTLEV_M'+#9+'LASTLEV_DBAR'+#9+'CRUISE_ID'+#9+'INSTRUMENT_ID'
     +#9+'ST_NUM_ORIGIN'+#9+'ST_ID_ORIGIN'+#9+'CAST_NUMBER'
     +#9+'QCFLAG'+#9+'STVERSION'+#9+'DUPLICATE'
     +#9+'MERGED'+#9+'ACCESSION_NUMBER'
     +#9+'DATE_ADDED'+#9+'DATE_UPDATED';
     rewrite(f_station);
     writeln(f_station,strOut);

     StrOut:='ID'+#9+'DBAR'+#9+'M'+#9+'VAL'+#9+'PQF1'
     +#9+'PQF2'+#9+'SQF'+#9+'BOTTLE_NUMBER'+#9+'UNITS_ID';

     TEMPERATURE_CTD_Ex:=false;
     SALINITY_CTD_Ex:=false;
     OXYGEN_CTD_Ex:=false;

{kv}for kv:=1 to vnum do begin
     tbl:=StringGrid4.Cells[1,kv];
     fcol:=strtoint(StringGrid4.Cells[2,kv]);
     memo1.Lines.Add(tbl+' -> '+inttostr(fcol));

     if tbl='P_TEMPERATURE_CTD' then begin
       TEMPERATURE_CTD_Ex:=true;
       fn:=PathOut+tbl+'.dat';
       AssignFile(f_temp_ctd,fn); rewrite(f_temp_ctd); writeln(f_temp_ctd,StrOut);
     end;

     if tbl='P_SALINITY_CTD' then begin
       SALINITY_CTD_Ex:=true;
       fn:=PathOut+tbl+'.dat';
       AssignFile(f_salt_ctd,fn); rewrite(f_salt_ctd); writeln(f_salt_ctd,StrOut);
     end;

     if tbl='P_OXYGEN_CTD' then begin
       OXYGEN_CTD_Ex:=true;
       fn:=PathOut+tbl+'.dat';
       AssignFile(f_oxyg_ctd,fn); rewrite(f_oxyg_ctd); writeln(f_oxyg_ctd,StrOut);
     end;


{kv}end;



        absnum:=0;
     //if DB exist get ID
{ID}if checkBox1.Checked then begin
     with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' Select max(ID) as MaxID from STATION ');
        Open;
        MaxID:=FieldByName('MaxID').AsInteger;
        absnum:=MaxID;
        Close;
     end;
{ID}end;


{f}for kfile:=0 to FileListBox1.Items.Count-1 do begin
     fn:=PathSource+FileListBox1.Items.Strings[kfile];

     AssignFile(fi,concat(fn));
     Reset(fi);
     memo1.Lines.Add(inttostr(kfile+1)+#9+fn);

     for i:=1 to 2000000 do stNum[i]:='';
     line:=0; //line number in file

   {.....find string with MD and Profiles titles.....}
{r}repeat
     readln(fi,st);
     line:=line+1;
{r}until (copy(st,1,9)<>'Event(s):') and (copy(st,1,5)='Event');

   {.....columns titles string analysis}
   {.....ASCII code for tab is 9}
     //memo1.Lines.Add(st);
     col:=0;
     buf:='';
{s}for i:=1 to length(st) do begin
     if ord(st[i])<>9 then buf:=buf+st[i]
     else begin
       col:=col+1;
       colTitle_arr[col]:=buf;
       buf:='';
     end;
{s}end;
      col:=col+1;
      colTitle_arr[col]:=buf;

                      memo1.Lines.Add('fields:');
   for i:=1 to col do memo1.Lines.Add(inttostr(i)+#9+colTitle_arr[i]);

   {.....define stations start lines in file.....}
    fld:=line+1; //first line with data
{w}while not EOF(fi) do begin
    readln(fi,st);
    st:=trim(st);
    line:=line+1;
    col:=0;
    buf:='';
{s}for i:=1 to length(st) do begin
    if ord(st[i])<>9 then buf:=buf+st[i]
    else begin
      col:=col+1;
      Rec_arr[col]:=buf;
      buf:='';
    end;
{s}end;
      col:=col+1;
      Rec_arr[col]:=buf;

    stNum[Line]:=Rec_arr[1]; //запоминанием номера станций в массиве

{w}end;
     closefile(fi);

     {...new station/profile position in file}
     stcount:=1;
     stline[stcount]:=fld;
   for i:=fld to line-1 do begin
   if stNum[i]<>stNum[i+1] then begin
     stcount:=stcount+1;
     stline[stcount]:=i+1
   end;
   end;
     //last line in file
     stcount:=stcount+1;
     stline[stcount]:=line+1;

     {...profiles location in file}
     memo1.Lines.Add('');
     memo1.Lines.Add('st#  line1  line2  lev#');
   for i:=1 to stcount-1 do begin
      prfB:=stline[i];
      prfE:=stline[i+1]-1;
      prfLn:=prfE-prfB+1;

      memo1.Lines.Add(inttostr(i)
      +#9+inttostr(prfB)
      +#9+inttostr(prfE)
      +#9+inttostr(prfLn));
   end;

     reset(fi);
     memo1.Lines.Add('');
     memo1.Lines.Add('first lines from profiles');

     skln:=stline[1]-1; //number of lines to skip
     for kline:=1 to skln do readln(fi);


     mik:=skln;
     {.....prepare MD and profiles.....}
{st}for kst:=1 to stcount-1 do begin
      ID:=kst+absnum;

      prfB:=stline[kst];
      prfE:=stline[kst+1]-1;
      prfLn:=prfE-prfB+1;
      //showmessage('ID='+inttostr(ID)+'  prfcount='+inttostr(prfLn));
      //showmessage('ID='+inttostr(ID)+'  prfB='+inttostr(prfB)+'  prfE='+inttostr(prfE)+'  prfE='+inttostr(prfLn));
{pr}for kpr:=1 to prfln do begin

      mik:=mik+1;
      readln(fi,st);
      //memo1.Lines.Add(inttostr(absnum)+#9+st);

      {...string analysis}
      st:=trim(st);
      col:=0;
      buf:='';
      {s}for i:=1 to length(st) do begin
           if ord(st[i])<>9 then buf:=buf+st[i]
           else begin
           col:=col+1;
           Rec_arr[col]:=buf;
           buf:='';
           end;
      {s}end;
          col:=col+1;
          Rec_arr[col]:=buf;


   {...record analysis - MD only}
{r}for i:=1 to col do begin
         //memo1.Lines.Add(Rec_arr[i]+#9+' /'+colTitle_arr[i]);
     {...MD processing}
     case i of
       1: OrStNum:=trim(Rec_arr[i]);
       2: begin
           DTst:=trim(Rec_arr[i]);
           Year:=strtoint(copy(DTst,1,4));
           Month:=strtoint(copy(DTst,6,2));
           Day:=strtoint(copy(DTst,9,2));
           Hour:=strtoint(copy(DTst,12,2));
           Min:=strtoint(copy(DTst,15,2));
           //convert date and time into datetime
           StDateTime:= procedures.DateEncode(Year,Month,Day,Hour,Min,DayChange,DateChange);
           if DayChange=true then memo1.Lines.Add('Day was changed in line='
                             +Rec_arr[1]
                             +'  '+inttostr(day)+'.'+inttostr(month)+'.'+inttostr(year)
                             +'  '+inttostr(hour)+':'+inttostr(min));
           if DateChange=true then memo1.Lines.Add('Date was changed in line='
                             +Rec_arr[1]
                             +'  '+inttostr(day)+'.'+inttostr(month)+'.'+inttostr(year)
                             +'  '+inttostr(hour)+':'+inttostr(min));
          end;{2}
       3: StLat:=strtofloat(trim(Rec_arr[i]));
       4: StLon:=strtofloat(trim(Rec_arr[i]));
       5: StDepthSource:=-strtoint(trim(Rec_arr[i]));
       //6: Lev_m:=strtofloat(trim(Rec_arr[i]));
       //7: Lev_dbar:=strtofloat(trim(Rec_arr[i]));
       //8: TempVal:=strtofloat(trim(Rec_arr[i]));
      //10: SaltVal:=strtofloat(trim(Rec_arr[i]));
      //12: OxygVal:=strtofloat(trim(Rec_arr[i]));
       end; {case}

     {...profiles processing: levels in m and dbar}
     if i=strtoint(Edit2.Text) then Lev_m:=strtofloat(trim(Rec_arr[i]));
     if i=strtoint(Edit3.Text) then Lev_dbar:=strtofloat(trim(Rec_arr[i]));


     {...profiles processing: variables}
     {kv}for kv:=1 to vnum do begin
          fcol:=strtoint(StringGrid4.Cells[2,kv]);
     {fc}if (fcol=i) then begin
        tbl:=StringGrid4.Cells[1,kv];
        if tbl='P_TEMPERATURE_CTD' then TempVal_CTD:=strtofloat(trim(Rec_arr[i]));
        if tbl='P_SALINITY_CTD' then SaltVal_CTD:=strtofloat(trim(Rec_arr[i]));
        if tbl='P_OXYGEN_CTD' then OxygVal_CTD:=strtofloat(trim(Rec_arr[i]));
     {fc}end;
     {kv}end;

{r}end; {i variable from file line}

          LastLev_m:=0;
          LastLev_dbar:=0;
          CruiseID:=0;
          Instrument_ID:=4;
          OrStID:=0;
          OrCastNum:=1;
          ST_QF:=0;
          ST_VER:=1;
          ST_DUP:=0;
          ST_MERGED:=0;
          ST_AcNum:=0;

          PQF1:=0;
          PQF2:=0;
          SQF:=0;
          BNum:=0;

         //output into file
         //STATION
{md}if (mik=stline[kst+1]-1) then begin
         writeln(f_station,inttostr(ID),                 //ID
         #9,floattostr(StLat),                    //LATITUDE
         #9,floattostr(StLon),                    //LONGITUDE
         #9,datetimetostr(StDateTime),            //DATEANDTIME
         #9,inttostr(StDepthSource),              //BOTTOMDEPTH
         #9,floattostr(LastLev_m),                //LASTLEVEL_M
         #9,floattostrF(LastLev_dbar,ffFixed,7,1),//LASTLEVEL_DBAR
         #9,inttostr(CruiseID),         //CRUISEID <> WOD cruise number identification (Primary Header/Field 8: 'Cruise number'). Integer becouse it is NOT UNIQUE
         #9,inttostr(Instrument_ID),           //INSTRUMENT_ID
         #9,OrStNum,                         //ST_NUM_ORIGIN = station number assigned during the cruise (Secondary Header/Field 7: 'Originator's station number'). String
         #9,inttostr(OrStID),               //ST_ID_ORIGIN = WOD cast identification (Primary header/Field 5: 'WOD unique cast number'). Integer
         #9,inttostr(OrCastNum),             //CAST_NUMBER = station number assigned during the cruise (Secondary Header/Field 5: 'Cast/Tow number'). integer
         #9,inttostr(ST_QF),                 //0 - not checked, 2 - suspicious becouse one of WOD algotithms on variables failed
         #9,inttostr(ST_VER),                //STVERSION
         #9,inttostr(ST_DUP),               //DUPLICATE
         #9,inttostr(ST_MERGED),            //MERGED
         #9,inttostr(ST_AcNum),         //ACCESSION_NUMBER
         #9,datetimetostr(NOW),        //DATE_ADDED
         #9,datetimetostr(NOW));      //DATE_UPDATED




         //write MD into WOD.FDB
{DB}if CheckBox1.Checked then begin

      StVersion:=0;
      with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' Select count(ID) as CountDup from STATION ');
        SQL.Add(' where DATEANDTIME=:stDT and ');
        SQL.Add(' Latitude=:stlat and Longitude=:stlon and CAST_NUMBER=:CAST_NUMBER ');
        ParamByName('stDT').AsDateTime:=StDateTime;
        ParamByName('stlat' ).Asfloat:=stlat;
        ParamByName('stlon' ).AsFloat:=stlon;
        ParamByName('CAST_NUMBER').AsInteger:=OrCastNum;
        Open;
        CountDup:=FieldByName('CountDup').AsInteger;
        Close;
      end;
        if CountDup>0 then StVersion:=CountDup+1;

      with frmdm.q2 do begin
        Close;
        SQL.Clear;
        SQL.Add(' INSERT INTO STATION ' );
        SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, BOTTOMDEPTH, LASTLEVEL_M, ' );
        SQL.Add('  LASTLEVEL_DBAR, CRUISE_ID, INSTRUMENT_ID, ST_NUMBER_ORIGIN, ST_ID_ORIGIN, ' );
        SQL.Add('  CAST_NUMBER, QCFLAG, STVERSION, DUPLICATE, MERGED, ACCESSION_NUMBER, DATE_ADDED, DATE_UPDATED ) ' );
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :BOTTOMDEPTH, :LASTLEVEL_M, ' );
        SQL.Add('  :LASTLEVEL_DBAR, :CRUISE_ID, :INSTRUMENT_ID, :ST_NUMBER_ORIGIN, :ST_ID_ORIGIN, ' );
        SQL.Add('  :CAST_NUMBER, :QCFLAG, :STVERSION, :DUPLICATE, :MERGED, :ACCESSION_NUMBER, :DATE_ADDED, :DATE_UPDATED ) ' );
        ParamByName('ID'               ).Value:=ID;
        ParamByName('LATITUDE'         ).Value:=stlat;
        ParamByName('LONGITUDE'        ).Value:=stlon;
        ParamByName('DATEANDTIME'      ).Value:=StDateTime;
        ParamByName('BOTTOMDEPTH'      ).Value:=StDepthSource;
        ParamByName('LASTLEVEL_M'      ).Value:=LastLev_m;
        ParamByName('LASTLEVEL_DBAR'   ).Value:=LastLev_dbar;
        ParamByName('CRUISE_ID'        ).Value:=CruiseID; //ID from CRUISE_WOD found by <WOD cruise number identification number>
        ParamByName('INSTRUMENT_ID'    ).Value:=Instrument_ID;
        ParamByName('ST_NUMBER_ORIGIN' ).Value:=OrStNum;
        ParamByName('ST_ID_ORIGIN'     ).Value:=OrStID;
        ParamByName('CAST_NUMBER'      ).Value:=OrCastNum;
        ParamByName('QCFLAG'           ).Value:=ST_QF;
        ParamByName('STVERSION'        ).Value:=StVersion;
        ParamByName('DUPLICATE'        ).Value:=ST_DUP;
        ParamByName('MERGED'           ).Value:=ST_MERGED;
        ParamByName('ACCESSION_NUMBER' ).Value:=ST_AcNum;
        ParamByName('DATE_ADDED'       ).Value:=Now;
        ParamByName('DATE_UPDATED'     ).Value:=Now;
        ExecSQL;
        end;
        //frmdm.TR.CommitRetaining;
{wDB}end;
{md}end;


     if TEMPERATURE_CTD_Ex=true then begin
         UID:=1; //ocean.fdb unit ID: Degrees Celsius
         writeln(f_temp_ctd,inttostr(ID),
         #9,floattostrF(Lev_dbar,ffFixed,7,1),
         #9,floattostr(Lev_m),
         #9,floattostr(TempVal_CTD),
         #9,inttostr(PQF1),
         #9,inttostr(PQF2),
         #9,inttostr(SQF),
         #9,inttostr(BNum),
         #9,UID);
     end;

     if SALINITY_CTD_Ex=true then begin
         UID:=2; //ocean.fdb unit ID: Dimensionless (unitless)
         writeln(f_salt_ctd,inttostr(ID),
         #9,floattostrF(Lev_dbar,ffFixed,7,1),
         #9,floattostr(Lev_m),
         #9,floattostr(SaltVal_CTD),
         #9,inttostr(PQF1),
         #9,inttostr(PQF2),
         #9,inttostr(SQF),
         #9,inttostr(BNum),
         #9,UID);
     end;

     if OXYGEN_CTD_Ex=true then begin
         UID:=3; //ocean.fdb unit ID: Micromole per kilogram
         writeln(f_oxyg_ctd,inttostr(ID),
         #9,floattostrF(Lev_dbar,ffFixed,7,1),
         #9,floattostr(Lev_m),
         #9,floattostr(OxygVal_CTD),
         #9,inttostr(PQF1),
         #9,inttostr(PQF2),
         #9,inttostr(SQF),
         #9,inttostr(BNum),
         #9,UID);
     end;


{pr}end;
{st}end;
         if CheckBox1.Checked then begin
            frmdm.TR.Commit;
            frmosmain.OpenDatabase;
         end;

     closefile(fi);
     absnum:=ID;
{f}end;
     closefile(f_station);
     closefile(f_temp_ctd);
     closefile(f_salt_ctd);
     closefile(f_oxyg_ctd);

end;




procedure TfrmloadPangaeaTab.btnDownloadPrfClick(Sender: TObject);
var
kv,vnum:integer;
id,pqf1,pqf2,sqf,Nbn,unit_id:integer;
L_dbar,L_m,val:real;
tbl,fn:string;

begin
     memo1.Lines.Add('start: '+datetimetostr(NOW));

     Vnum :=StringGrid4.RowCount-1;


{v}for kv:=1 to vnum do begin
     tbl:=trim(StringGrid4.Cells[1,kv]);
     fn:=PathOut+tbl+'.dat';
     Application.ProcessMessages;
     assignfile(fi,fn);
     reset(fi);
     readln(fi);

{f}while not EOF(fi) do begin

      readln(fi,id,L_dbar,L_m,val,pqf1,pqf2,sqf,Nbn,unit_id);

      if CheckBox1.Checked then
      with frmdm.q3 do begin
       Close;
         SQL.Clear;
         SQL.Add(' insert into ');
         SQL.Add(tbl);
         SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF1, PQF2, SQF, BOTTLE_NUMBER, UNITS_ID) ');
         SQL.Add(' values ');
         SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF1, :PQF2, :SQF, :BOTTLE_NUMBER, :UNITS_ID) ');
         ParamByName('ID').AsInteger:=id;
         ParamByName('LEV_DBAR').AsFloat:=L_dbar;
         ParamByName('LEV_M').AsFloat:=L_m;
         ParamByName('VAL').AsFloat:=val;
         ParamByName('PQF1').AsInteger:=pqf1;
         ParamByName('PQF2').AsInteger:=pqf2;
         ParamByName('SQF').AsInteger:=sqf;
         ParamByName('BOTTLE_NUMBER').AsInteger:=Nbn;
         ParamByName('UNITS_ID').AsInteger:=unit_id;
         ExecSQL;
      end;

{f}end;
      closefile(fi);
      frmdm.TR.Commit;
{v}end;
      memo1.Lines.Add('end: '+datetimetostr(NOW));


end;





procedure TfrmloadPangaeaTab.btnSelectProfilesClick(Sender: TObject);
var
i:integer;
begin
  frmdm.IBDB.GetTableNames(ListBox1.Items,False);
  ListBox1.Visible:=true;


  for i:=0 to ListBox1.Items.Count-1 do
  if (copy(ListBox1.items.strings[i],1,2)='P_')
  then ListBox2.Items.Add(ListBox1.items.strings[i]);

  //if (copy(ListBox1.items.strings[i],1,2)='P_') then ListBox1.Items.Delete(ListBox1.ItemIndex);
  //if (copy(ListBox1.items.strings[i],1,2)='P_') then ListBox1.Items.Delete(i);

  ListBox1.Visible:=true;
  ListBox2.Visible:=true;
  btnDeleteSelected.Visible:=true;
  btnUpdateStation.Visible:=true;
end;




procedure TfrmloadPangaeaTab.btnDeleteSelectedClick(Sender: TObject);
begin
  ListBox1.DeleteSelected;
end;




procedure TfrmloadPangaeaTab.btnUpdateStationClick(Sender: TObject);
var
i,kst,kpr,MaxID:integer;
LLdbar,LLm,LLdbar_max,LLm_max:real;
tbl:string;
begin

    //showmessage('items in listbox: '+inttostr(ListBox2.Items.Count));

    with frmdm.q1 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select max(ID) as MaxID from station  ');
     Open;
     MaxID:=frmdm.q1.FieldByName('MAXID').AsInteger;
     Close;
    end;

     memo1.Lines.Add('...last levels in STATION will be updated');
     memo1.Lines.Add('Maximum ID in DB='+inttostr(MaxID));

{st}for kst:=1 to maxid do begin

    //max level from all profiles tables
{pr}for kpr:=0 to ListBox2.Items.Count-1 do begin
     tbl:=ListBox2.Items.Strings[kpr];

     LLdbar_max:=0;
     LLm_max:=0;

     with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select max(lev_dbar) as LL_dbar, max(lev_m) as LL_m  ');
      SQL.Add(' from  ');
      SQL.Add(tbl);
      SQL.Add(' where ID=:ID  ');
      ParamByName('ID').AsInteger:=kst;
      Open;
      LLdbar:=frmdm.q1.FieldByName('LL_dbar').AsFloat;
      LLm:=frmdm.q1.FieldByName('LL_m').AsFloat;
      Close;
     end;
      if LLdbar_max<LLdbar then LLdbar_max:=LLdbar;
      if LLm_max<LLm then LLm_max:=LLm;
      if CheckBox2.Checked then
      memo1.Lines.Add(inttostr(kst)+#9+floattostr(LLdbar_max)+' dbar '
      +#9+floattostr(LLm_max)+' m '
      +#9+tbl);
{pr}end;


      with frmdm.q1 do begin
       Close;
       SQL.Clear;
       SQL.Add(' update STATION set lastlevel_m=:LL_m, lastlevel_dbar=:LL_dbar  ');
       SQL.Add(' where ID=:ID  ');
       ParamByName('ID').AsInteger:=kst;
       ParamByName('LL_m').AsFloat:=LLm_max;
       ParamByName('LL_dbar').AsFloat:=LLdbar_max;
       ExecSQL;
       Close;
      end;

      //frmdm.TR.CommitRetaining;
{st}end;
       frmdm.TR.Commit;

       memo1.Lines.Add('...STATION has been updated');


end;




procedure TfrmloadPangaeaTab.btnCreatePangeaeaDBClick(Sender: TObject);
Var
DB:TIBConnection;
TR:TSQLTransaction;
ST:TSQLScript;

    (* Script for main tables *)
    const ScriptText=
       (* STATION *)
       'CREATE TABLE STATION ('+LineEnding+
       '    ID                  BIGINT NOT NULL, '+LineEnding+
       '    LATITUDE            DECIMAL(8,5) NOT NULL, '+LineEnding+
       '    LONGITUDE           DECIMAL(9,5) NOT NULL, '+LineEnding+
       '    DATEANDTIME         TIMESTAMP NOT NULL, '+LineEnding+
       '    BOTTOMDEPTH         INTEGER, '+LineEnding+
       '    LASTLEVEL_M         INTEGER, '+LineEnding+
       '    LASTLEVEL_DBAR      INTEGER, '+LineEnding+
       '    CRUISE_ID           BIGINT NOT NULL, '+LineEnding+
       '    INSTRUMENT_ID       BIGINT NOT NULL, '+LineEnding+
       '    ST_NUMBER_ORIGIN    VARCHAR(50), '+LineEnding+
       '    ST_ID_ORIGIN        BIGINT, '+LineEnding+
       '    CAST_NUMBER         SMALLINT DEFAULT 1 NOT NULL, '+LineEnding+
       '    QCFLAG              SMALLINT NOT NULL, '+LineEnding+
       '    STVERSION           SMALLINT NOT NULL, '+LineEnding+
       '    DUPLICATE           SMALLINT DEFAULT 0 NOT NULL, '+LineEnding+
       '    MERGED              SMALLINT DEFAULT 0 NOT NULL, '+LineEnding+
       '    ACCESSION_NUMBER    BIGINT, '+LineEnding+
       '    DATE_ADDED          TIMESTAMP NOT NULL, '+LineEnding+
       '    DATE_UPDATED        TIMESTAMP, '+LineEnding+
       '    CONSTRAINT STATION_PK PRIMARY KEY (ID) '+LineEnding+
       '); '+LineEnding+

       //   '    SOURCE_ID           BIGINT DEFAULT -9 NOT NULL, '+LineEnding+
    //   '    COUNTRY_ID          BIGINT DEFAULT -9 NOT NULL, '+LineEnding+
    //   '    PLATFORM_ID         BIGINT DEFAULT -9 NOT NULL, '+LineEnding+
       //   '    INSTRUMENT_ID       BIGINT DEFAULT -9 NOT NULL, '+LineEnding+

       (* ENTRY *)
       'CREATE TABLE ENTRY ('+LineEnding+
       '    ID               BIGINT NOT NULL, '+LineEnding+
       '    ENTRIES_TYPE_ID  BIGINT NOT NULL, '+LineEnding+
       '    TITLE            VARCHAR(100) NOT NULL, '+LineEnding+
       '    DATE_BEGIN       TIMESTAMP NOT NULL, '+LineEnding+
       '    DATE_END         TIMESTAMP NOT NULL, '+LineEnding+
       '    STATIONS_NUMBER  BIGINT, '+LineEnding+
       '    DATE_ADDED       TIMESTAMP NOT NULL, '+LineEnding+
       '    DATE_UPDATED     TIMESTAMP, '+LineEnding+
       '    CONSTRAINT ENTRY_PK PRIMARY KEY (ID) '+LineEnding+
       '); '+LineEnding+

       (* ENTRY_TYPE *)
       'CREATE TABLE ENTRY_TYPE ('+LineEnding+
       '    ID           BIGINT NOT NULL, '+LineEnding+
       '    NAME         VARCHAR(255) NOT NULL, '+LineEnding+
       '    DESCRIPTION  BLOB SUB_TYPE 1 SEGMENT SIZE 16384, '+LineEnding+
       '    CONSTRAINT ENTRY_TYPE_PK PRIMARY KEY (ID) '+LineEnding+
       '); '+LineEnding+

       (* STATION_ENTRY *)
       'CREATE TABLE STATION_ENTRY ('+LineEnding+
       '    STATION_ID  BIGINT NOT NULL, '+LineEnding+
       '    ENTRY_ID    BIGINT NOT NULL '+LineEnding+
       '); '+LineEnding+

       (* PARAMETERS *)
       'CREATE TABLE DATABASE_TABLES ('+LineEnding+
       '    ID            BIGINT NOT NULL, '+LineEnding+
       '    TABLENAME     VARCHAR(255) NOT NULL, '+LineEnding+
       '    VARIABLENAME  VARCHAR(255) NOT NULL, '+LineEnding+
       '    DESCRIPTION   VARCHAR(255), '+LineEnding+
       '    CONSTRAINT DATABASE_TABLES_PK PRIMARY KEY (ID) '+LineEnding+
       '); '+LineEnding+

          'CREATE TABLE P_TEMPERATURE_CTD ( '+LineEnding+
          '   ID             BIGINT NOT NULL, '+LineEnding+
          '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
          '   pQF1           SMALLINT, '+LineEnding+
          '   pQF2           SMALLINT, '+LineEnding+
          '   sQF            SMALLINT, '+LineEnding+
          '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
          '   UNITS_ID        BIGINT '+LineEnding+
          '); '+LineEnding+

          'CREATE TABLE P_TEMPERATURE_BOTTLE ( '+LineEnding+
          '   ID             BIGINT NOT NULL, '+LineEnding+
          '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
          '   pQF1           SMALLINT, '+LineEnding+
          '   pQF2           SMALLINT, '+LineEnding+
          '   sQF            SMALLINT, '+LineEnding+
          '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
          '   UNITS_ID        BIGINT '+LineEnding+
          '); '+LineEnding+

          'CREATE TABLE P_SALINITY_CTD ( '+LineEnding+
          '   ID             BIGINT NOT NULL, '+LineEnding+
          '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
          '   pQF1           SMALLINT, '+LineEnding+
          '   pQF2           SMALLINT, '+LineEnding+
          '   sQF            SMALLINT, '+LineEnding+
          '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
          '   UNITS_ID        BIGINT '+LineEnding+
          '); '+LineEnding+

       'CREATE TABLE P_SALINITY_BOTTLE ( '+LineEnding+
          '   ID             BIGINT NOT NULL, '+LineEnding+
          '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
          '   pQF1           SMALLINT, '+LineEnding+
          '   pQF2           SMALLINT, '+LineEnding+
          '   sQF            SMALLINT, '+LineEnding+
          '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
          '   UNITS_ID        BIGINT '+LineEnding+
          '); '+LineEnding+

       'CREATE TABLE P_OXYGEN_CTD ( '+LineEnding+
          '   ID             BIGINT NOT NULL, '+LineEnding+
          '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
          '   pQF1           SMALLINT, '+LineEnding+
          '   pQF2           SMALLINT, '+LineEnding+
          '   sQF            SMALLINT, '+LineEnding+
          '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
          '   UNITS_ID        BIGINT '+LineEnding+
          '); '+LineEnding+

       'CREATE TABLE P_OXYGEN_BOTTLE ( '+LineEnding+
          '   ID             BIGINT NOT NULL, '+LineEnding+
          '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
          '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
          '   pQF1           SMALLINT, '+LineEnding+
          '   pQF2           SMALLINT, '+LineEnding+
          '   sQF            SMALLINT, '+LineEnding+
          '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
          '   UNITS_ID        BIGINT '+LineEnding+
          '); '+LineEnding+

       'CREATE TABLE P_FLUORESCENCE_CTD ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_TURBIDITY_CTD ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_RADIATION_CTD ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_AMMONIUM_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_CF5CF3_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_C13_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       //   DISSOLVED INORGANIC CARBON
       'CREATE TABLE P_DIC_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       //   HYDROGEN
       'CREATE TABLE P_H_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_FREON12_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_NITRATE_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_NITRITE_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_NITROGEN_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_O18_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_PHOSPHATE_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_PH_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_SF6_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_SILICATE_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_SULFIDE_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+

       'CREATE TABLE P_TALK_BOTTLE ( '+LineEnding+
       '   ID             BIGINT NOT NULL, '+LineEnding+
       '   LEV_DBAR       DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   LEV_M          DECIMAL(9,4) NOT NULL, '+LineEnding+
       '   VAL            DOUBLE PRECISION NOT NULL, '+LineEnding+
       '   pQF1           SMALLINT, '+LineEnding+
       '   pQF2           SMALLINT, '+LineEnding+
       '   sQF            SMALLINT, '+LineEnding+
       '   BOTTLE_NUMBER  SMALLINT, '+LineEnding+
       '   UNITS_ID        BIGINT '+LineEnding+
       '); '+LineEnding+




       'ALTER TABLE STATION ADD CONSTRAINT UNQ1_STATION UNIQUE (LATITUDE,LONGITUDE,DATEANDTIME,CAST_NUMBER,STVERSION); '+LineEnding+
       'ALTER TABLE ENTRY ADD CONSTRAINT FK_ENTRY FOREIGN KEY (ENTRIES_TYPE_ID) REFERENCES ENTRY_TYPE (ID); '+LineEnding+
       'ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_1 FOREIGN KEY (STATION_ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_2 FOREIGN KEY (ENTRY_ID) REFERENCES ENTRY (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+

       'ALTER TABLE P_TEMPERATURE_CTD ADD CONSTRAINT FK_P_TEMPERATURE_CTD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_SALINITY_CTD ADD CONSTRAINT FK_P_SALINITY_CTD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_OXYGEN_CTD ADD CONSTRAINT FK_P_OXYGEN_CTD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_FLUORESCENCE_CTD ADD CONSTRAINT FK_P_FLUORESCENCE_CTD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_RADIATION_CTD ADD CONSTRAINT FK_P_RADIATION_CTD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_TURBIDITY_CTD ADD CONSTRAINT FK_P_TURBIDITY_CTD FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+

       'ALTER TABLE P_TEMPERATURE_BOTTLE ADD CONSTRAINT FK_P_TEMPERATURE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_SALINITY_BOTTLE ADD CONSTRAINT FK_P_SALINITY_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_OXYGEN_BOTTLE ADD CONSTRAINT FK_P_OXYGEN_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_AMMONIUM_BOTTLE ADD CONSTRAINT FK_P_AMMONIUM_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_CF5CF3_BOTTLE ADD CONSTRAINT FK_P_CF5CF3_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_C13_BOTTLE ADD CONSTRAINT FK_P_C13_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_DIC_BOTTLE ADD CONSTRAINT FK_P_DIC_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_H_BOTTLE ADD CONSTRAINT FK_P_H_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_FREON12_BOTTLE ADD CONSTRAINT FK_P_FREON12_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_NITRATE_BOTTLE ADD CONSTRAINT FK_P_NITRATE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_NITRITE_BOTTLE ADD CONSTRAINT FK_P_NITRITE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_NITROGEN_BOTTLE ADD CONSTRAINT FK_P_NITROGEN_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_O18_BOTTLE ADD CONSTRAINT FK_P_O18_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_PHOSPHATE_BOTTLE ADD CONSTRAINT FK_P_PHOSPHATE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_PH_BOTTLE ADD CONSTRAINT FK_P_PH_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_SF6_BOTTLE ADD CONSTRAINT FK_P_SF6_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_SILICATE_BOTTLE ADD CONSTRAINT FK_P_SILICATE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_SULFIDE_BOTTLE ADD CONSTRAINT FK_P_SULFIDE_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
       'ALTER TABLE P_TALK_BOTTLE ADD CONSTRAINT FK_P_TALK_BOTTLE FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+

       'COMMIT WORK '+LineEnding+
       'SET TERM ; '+LineEnding;

   begin

    // showmessage(ScriptText);
     try
       DB:=TIBConnection.Create(nil);
       TR:=TSQLTransaction.Create(nil);
       ST:=TSQLScript.Create(nil);

        DB.Transaction:=TR;
        TR.Database:=DB;
        ST.Transaction:=TR;
        ST.Database:=DB;
        ST.CommentsInSQL:=false;

        //DB.DatabaseName:=(dbname);
        IBName:='c:\Users\ako071\AK\OceanShell-GIT\OceanShell\databases\PANGAEA.fdb';
        DB.DatabaseName:=IBName;
        DB.UserName:='SYSDBA';
        DB.Password:='masterkey';
         With DB.Params do begin
          Clear;
           Add('SET SQL DIALECT 3');
           Add('SET NAMES UTF8');
           Add('PAGE_SIZE 16384');
           Add('DEFAULT CHARACTER SET UTF8 COLLATION UTF8');
         end;
        DB.CreateDB;
        DB.Connected:=False;
        DB.LoginPrompt:=False;
        DB.Open;

        ST.Script.Text:=ScriptText;
        ST.UseCommit:=true;
        ST.UseSetTerm:=true; // for Firebird ONLY
        ST.CommentsInSQL:=false;
         try
          ST.Execute;
          TR.Commit;
         except
          on E: EDataBaseError do begin
            ShowMessage('Error running script: '+E.Message);
            TR.Rollback;
          end;
         end;
     finally
      ST.Free;
      TR.Free;
      DB.Free;
     end;
       frmosmain.OpenDatabase;
       showmessage('PANGAEA database has been created ');
end;






end.

