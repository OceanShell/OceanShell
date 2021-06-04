unit osca_splitcruises;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Buttons, TAGraph, TASeries, TATypes, TAMultiSeries, TAStyles, TASources, DateUtils;

{TAGraph, TASeries, TATools, DB, BufDataSet,
  TAChartUtils, TAStyles, TALegendPanel, TANavigation, TATypes, Types;}

{TAGraph, TAMultiSeries, TASeries, TASources, TAStyles; }


type

  { TfrmSplitCruises }

  TfrmSplitCruises = class(TForm)
    btnFindFixedStations: TBitBtn;
    btnAddClustersToData: TBitBtn;
    btnSplitGraphToClusters: TBitBtn;
    btnEstimateNumberofClusters: TBitBtn;
    btnPlotMinTree: TBitBtn;
    btnCreateGraph: TBitBtn;
    btnFindShortestPath: TBitBtn;
    Chart1: TChart;
    Chart1FieldSeries1: TFieldSeries;
    Chart1LineSeries1: TLineSeries;
    CheckBox1: TCheckBox;
    CreateDataFile: TBitBtn;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    procedure btnAddClustersToDataClick(Sender: TObject);
    procedure btnCreateGraphClick(Sender: TObject);
    procedure btnFindFixedStationsClick(Sender: TObject);
    procedure btnFindShortestPathClick(Sender: TObject);
    procedure btnPlotMinTreeClick(Sender: TObject);
    procedure btnEstimateNumberofClustersClick(Sender: TObject);
    procedure btnSplitGraphToClustersClick(Sender: TObject);
    procedure CreateDataFileClick(Sender: TObject);
    procedure Edit1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmSplitCruises: TfrmSplitCruises;
  pathdata,fn :string;
  DT1,DT2 :TDateTime;
  fi,fo :text;

implementation

uses osmain, dm;

{$R *.lfm}

{ TfrmSplitCruises }

procedure TfrmSplitCruises.FormShow(Sender: TObject);
begin
  pathData:=GlobalDataPath+'CA'+PathDelim;
  if not DirectoryExists(pathData) then CreateDir(pathData);
  memo1.Clear;
end;



procedure TfrmSplitCruises.btnFindFixedStationsClick(Sender: TObject);
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
str :string;
new :boolean;

begin
DT1:=NOW;
memo1.Lines.Add('...find fixed stations in data: ');
memo1.Lines.Add('...start: '+datetimetostr(DT1));


frmdm.q.DisableControls;
frmdm.q.First;

    n:=0;
{Q}while not frmdm.q.EOF do begin
    inc(n);
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

    Showmessage('Length(Station)='+inttostr(Length(Station)));

   {...add first station to FStation}
   n:=1;
   SetLength(FStation,n);
   FStation[n-1].lat:=Station[0].lat;
   FStation[n-1].lon:=Station[0].lon;
   FStation[n-1].time_min:=Station[0].time;
   FStation[n-1].time_max:=Station[0].time;
   FStation[n-1].stcount:=1;

{S}for i:=1 to High(Station) do begin
   new:=true;
{FS}for j:=0 to High(FStation) do begin
    if (Station[i].lat=FStation[j].lat) and (Station[i].lon=FStation[j].lon) then begin
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
     frmdm.q.EnableControls;

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
    db:=Daysbetween(FStation[i].time_min,FStation[i].time_max);
    memo1.Lines.Add(inttostr(i)
    +#9+floattostrF(FStation[i].lat,ffFixed,10,5)
    +#9+floattostrF(FStation[i].lon,ffFixed,10,5)
    +#9+inttostr(FStation[i].stcount)
    +#9+inttostr(db)
    +#9+datetimetostr(FStation[i].time_min)
    +#9+datetimetostr(FStation[i].time_max)
    );

    {...fixed station: >1 day, >1 station}
{if}if (db>1) and (FStation[i].stcount>1) then begin
     inc(fsc);
     str:='FS_'+floattostr(FStation[i].lat)+'_'+floattostr(FStation[i].lon);

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

{S}for j:=0 to High(Station) do begin
{DB}if  (FStation[i].lat=Station[j].lat) and (FStation[i].lon=Station[j].lon)
   then begin

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

{DB}end;
{S}end;

{if}end;
{FC}end;

memo1.Lines.Add('number of fixed stations: '+inttostr(fsc));
memo1.Lines.Add('');

DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;




procedure TfrmSplitCruises.CreateDataFileClick(Sender: TObject);
var
i,n :integer;
cruise_id,station_id :int64;
lat,lon :real;
md,sd,s1,s2 :array[1..3] of double;
str :string;
st_dt :TDateTime;
begin

  if SCount=0 then begin
   showmessage('Stations not selected!');
   Exit;
  end;
  memo1.Lines.Add('...create data.txt ');

  DT1:=NOW;
  memo1.Lines.Add('...start: '+datetimetostr(DT1));
  memo1.Lines.Add('Number of selected stations: '+inttostr(SCount));

{.....step1 create data.txt and compute statistics for lat,lon,timeR}
   fn:=pathData+'data.txt';
   assignfile(fo,fn);
   rewrite(fo);

   frmdm.q.DisableControls;
   frmdm.q.First;

   if CheckBox1.Checked then
   memo1.Lines.Add('node'+#9+'lat'+#9+'lon'+#9+'timeR'+#9+'station_id'+#9+'cruise_id'+#9+'time');
   writeln(fo,     'node'+#9+'lat'+#9+'lon'+#9+'timeR'+#9+'station_id'+#9+'cruise_id'+#9+'time');

   n:=0;
   for i:=1 to 3 do begin
    md[i]:=0;    sd[i]:=0;    s1[i]:=0;    s2[i]:=0;
   end;
{Q}while not frmdm.q.EOF do begin
   inc(n);
   station_id:=frmdm.q.FieldByName('id').AsInteger;
   lat:=frmdm.q.FieldByName('latitude').AsFloat;
   lon:=frmdm.q.FieldByName('longitude').AsFloat;
   st_dt:=frmdm.q.FieldByName('dateandtime').AsDateTime;
   cruise_id:=frmdm.q.FieldByName('cruise_id').AsInteger;

   s1[1]:=s1[1]+lat;
   s2[1]:=s2[1]+lat*lat;
   s1[2]:=s1[2]+lon;
   s2[2]:=s2[2]+lon*lon;
   s1[3]:=s1[3]+st_dt;
   s2[3]:=s2[3]+st_dt*st_dt;

   if CheckBox1.Checked then
   memo1.Lines.Add(inttostr(n)
   +#9+floattostr(lat)
   +#9+floattostr(lon)
   +#9+floattostrF(st_dt,ffFixed,12,5)
   +#9+inttostr(station_id)
   +#9+inttostr(cruise_id)
   +#9+datetimetostr(st_dt)
   );

   {...data.txt}
   writeln(fo,inttostr(n)
   +#9+floattostr(lat)
   +#9+floattostr(lon)
   +#9+floattostrF(st_dt,ffFixed,12,5)
   +#9+inttostr(station_id)
   +#9+inttostr(cruise_id)
   +#9+datetimetostr(st_dt)
   );

   frmdm.q.Next;
{Q}end;
   closefile(fo);
   frmdm.q.EnableControls;

    if CheckBox1.Checked then begin
    memo1.Lines.Add('');
    memo1.Lines.Add('par'+#9+'n'+#9+'md'+#9+'sd');
    end;
{i}for i:=1 to 3 do begin
    md[i]:=s1[i]/n;
    sd[i]:=(s2[i]-s1[i]*s1[i]/n)/n;
    if sd[i]<>0 then sd[i]:=sqrt(abs(sd[i]));
    case i of
    1: str:='lat';
    2: str:='lon';
    3: str:='timeR';
    end;
    if CheckBox1.Checked then
    memo1.Lines.Add(str
    +#9+inttostr(n)
    +#9+floattostr(md[i])
    +#9+floattostr(sd[i]));
{i}end;
{.....step1}


{.....step2 create norm.dat with normilized lat,lon,timeR}
   fn:=pathData+'dataN.txt';
   assignfile(fo,fn);
   rewrite(fo);

   frmdm.q.DisableControls;
   frmdm.q.First;

   if CheckBox1.Checked then begin
   memo1.Lines.Add('');
   memo1.Lines.Add('normalized lat,lon,timeR');
   memo1.Lines.Add('station_id'+#9+'nlat'+#9+'nlon'+#9+'ntimeR');
   end;

   writeln(fo,'node'+#9+'nlat'+#9+'nlon'+#9+'ntimeR');

   n:=0;
{Q}while not frmdm.q.EOF do begin
   inc(n);
   station_id:=frmdm.q.FieldByName('id').AsInteger;
   lat:=frmdm.q.FieldByName('latitude').AsFloat;
   lon:=frmdm.q.FieldByName('longitude').AsFloat;
   st_dt:=frmdm.q.FieldByName('dateandtime').AsDateTime;
   cruise_id:=frmdm.q.FieldByName('cruise_id').AsInteger;

   {normalization}
   lat:=(lat-md[1])/sd[1];
   lon:=(lon-md[2])/sd[2];
   st_dt:=(st_dt-md[3])/sd[3];

   if CheckBox1.Checked then
   memo1.Lines.Add(inttostr(station_id)
   +#9+floattostr(lat)
   +#9+floattostr(lon)
   +#9+floattostr(st_dt));

   {...dataN.txt}
   writeln(fo,inttostr(n)
   +#9+floattostrF(lat,ffFixed,12,5)
   +#9+floattostrF(lon,ffFixed,12,5)
   +#9+floattostrF(st_dt,ffFixed,12,5));

   frmdm.q.Next;
{Q}end;
   closefile(fo);
   frmdm.q.EnableControls;
{.....step2}

DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;





procedure TfrmSplitCruises.btnFindShortestPathClick(Sender: TObject);

type
segment=Record
  C:integer;
  F:Integer;
  r:real;
end;
SubTreeType=array of segment;

var
MainTree,SecondTree,MinTree :SubTreeType;
i,j,k1,k2,n,node,m,s,C1,F1,index,F1_index,last :integer;
nlat,nlon,ntimeR,r,rp,rmin :real;
NORM :array of array of real;
skip :boolean;
begin

memo1.Lines.Add('...shortest tree computing');
DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));

{.....step1: populate Norm from file}
 fn:=pathdata+'dataN.txt';
 memo1.Lines.Add(fn);
 AssignFile(fi,fn);
 reset(fi);
 readln(fi);

     n:=0;
{fi}while not EOF(fi) do begin
     inc(n);
     readln(fi,node, nlat, nlon, ntimeR);
     SetLength(NORM,n,3);
     NORM[n-1,0]:=node;
     NORM[n-1,1]:=nlat;
     NORM[n-1,2]:=nlon;
     NORM[n-1,3]:=ntimeR;
{fi}end;
     closefile(fi);

{m}if CheckBox1.Checked then begin
    memo1.Lines.Add('');
    memo1.Lines.Add('step1: normalized lat,lon,timeR');
    memo1.Lines.Add('#'+#9+'nlat'+#9+'nlon'+#9+'ntimeR');
   for i:=0 to High(NORM) do begin
    memo1.Lines.Add(inttostr(trunc(NORM[i,0]))
    +#9+floattostr(NORM[i,1])
    +#9+floattostr(NORM[i,2])
    +#9+floattostr(NORM[i,3]));
   end;
{m}end;
{.....step1}


{.....step2: create MainTree for the first node}
   {...populate MainTree}
{i}for i:=1 to High(NORM) do begin // not from 0!
{j}for j:=1 to 3 do begin          //lat,lon,time
    rp:=sqr(NORM[0,j]-NORM[i,j]);  //first line minus all the rest
    r:=r+rp;
{j}end;
    if r<>0 then r:=sqrt(r);
    SetLength(MainTree,i);
    MainTree[i-1].C:=trunc(NORM[0,0]);  // = line number in NORM array
    MainTree[i-1].F:=trunc(NORM[i,0]);
    MainTree[i-1].r:=r;
{i}end;

    {...first segment}
    rmin:=MainTree[0].r;
    C1:=MainTree[0].C;  //first node in MainTree and MinTree
    F1:=MainTree[0].F;

{m}if CheckBox1.Checked then begin
    memo1.Lines.Add('');
    memo1.Lines.Add('step2: compute distances from first node ');
    memo1.Lines.Add('#'+#9+'C'+#9+'F'+#9+'r');
{m}end;

   {...find minimum segment in MainTree}
{i}for i:=0 to High(MainTree) do begin
   if rmin>MainTree[i].r then begin
    rmin:=MainTree[i].r;
    index:=i; //index of the minimum segment in MainTree
    C1:=MainTree[i].C;
    F1:=MainTree[i].F;
   end;
{m}if CheckBox1.Checked then
    memo1.Lines.Add(inttostr(i+1)
    +#9+inttostr(MainTree[i].C)
    +#9+inttostr(MainTree[i].F)
    +#9+floattostr(MainTree[i].r));
{i}end;

{m}if CheckBox1.Checked then begin
    memo1.Lines.Add('');
    memo1.Lines.Add('...segment with minimum distance');
    memo1.Lines.Add('#'+#9+'C'+#9+'F'+#9+'r');
    memo1.Lines.Add(inttostr(index+1)
    +#9+inttostr(C1)
    +#9+inttostr(F1)
    +#9+floattostr(rmin));
{m}end;

    {...add minimum segment to MinTree}
    SetLength(MinTree,1);
    MinTree[0].C:=C1;
    MinTree[0].F:=F1;   //second node in the MinTree
    MinTree[0].r:=rmin;

    {...delete min segment from MainTree}
    last:=high(MainTree);
    if index<last then move(MainTree[index+1],MainTree[index], (last-index)*sizeof(MainTree[index]));
    setlength(MainTree,Last);
{.....step2}


    label1.Visible:=true;
{.....step3: find shortest MinTree}
{1}for k1:=0 to High(MainTree) do begin
    {2= first segment was delete + zero index}
    label1.Caption:='segment#='+inttostr(k1+2);
    Application.ProcessMessages;

   {...compute distances from added node}
   m:=0;
{2}for k2:=0 to High(NORM) do begin

   {...skip computing if node was used to compute distances or is the same }
   skip:=false;
   for i:=0 to High(MinTree) do begin
      if MinTree[i].C=NORM[k2,0] then skip:=true;
      if MinTree[i].F=NORM[k2,0] then skip:=true;
   end;
   if F1=NORM[k2,0] then skip:=true;

   {...determine NORM index where node=F1}
   for i:=1 to High(NORM) do if NORM[i,0]=F1 then F1_index:=i;
   //if k1=753 then showmessage('k2='+inttostr(k2)+'  F1='+inttostr(F1)+'  F1_index='+inttostr(F1_index) );

{<>}if skip=false then begin
{i}for i:=1 to 3 do begin
     rp:=sqr(NORM[F1_index,i]-NORM[k2,i]);
     r:=r+rp;
{i}end;
     if r<>0 then r:=sqrt(r) else showmessage('r=0  k1='+inttostr(k1)+'  k2='+inttostr(k2));

     {create SecondTree}
       inc(m);
       SetLength(SecondTree,m);
       SecondTree[m-1].C:=F1;
       SecondTree[m-1].F:=trunc(NORM[k2,0]);
       SecondTree[m-1].r:=r;
{<>}end;
{2}end;

    {...compare main and second trees}
{i}for i:=0 to High(MainTree) do begin
{j}for j:=0 to High(SecondTree) do begin
{F}if (MainTree[i].F=SecondTree[j].F) and (MainTree[i].r>SecondTree[j].r)
   then begin
    MainTree[i].C:=SecondTree[j].C;
    MainTree[i].r:=SecondTree[j].r;
{F}end;
{j}end;
{i}end;

    SetLength(SecondTree,0);

    {...find new minimum segment }
    index:=0;
    rmin:=MainTree[0].r;
    C1:=MainTree[0].C;
    F1:=MainTree[0].F;
{i}for i:=0 to High(MainTree) do begin
{min}if rmin>MainTree[i].r then begin
      rmin:=MainTree[i].r;
      index:=i;
      C1:=MainTree[i].C;
      F1:=MainTree[i].F;
{min}end;
{i}end;

    {...delete min segment from MainTree}
    last:=high(MainTree);
    if index<last then move(MainTree[index+1],MainTree[index], (last-index)*sizeof(MainTree[index]));
    setlength(MainTree,Last);

    {...add minimum segment to MinTree}
    s:=Length(MinTree)+1;
    SetLength(MinTree,s);
    MinTree[s-1].C:=C1;
    MinTree[s-1].F:=F1;   //second node in the MinTree
    MinTree[s-1].r:=rmin;

{k1}end;
{.....step3}


   {...MinTree}
{m}if CheckBox1.Checked then begin
    memo1.Lines.Add('');
    memo1.Lines.Add('...MinTree');
    for i:=0 to High(MinTree) do
    memo1.Lines.Add(inttostr(i+1)
      +#9+inttostr(MinTree[i].C)
      +#9+inttostr(MinTree[i].F)
      +#9+floattostr(MinTree[i].r));
{m}end;

   {...MinTree.txt}
   fn:=pathData+'MinTree.txt';
   assignfile(fo,fn);
   rewrite(fo);
   writeln(fo,'step',#9,'C',#9,'F',#9,'r');
   for i:=0 to High(MinTree) do
   writeln(fo,inttostr(i+1)
   +#9+inttostr(MinTree[i].C)
   +#9+inttostr(MinTree[i].F)
   +#9+floattostr(MinTree[i].r));
   closefile(fo);

DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;





procedure TfrmSplitCruises.btnCreateGraphClick(Sender: TObject);
type
GraphNode=Record
  step :integer;
  C :integer;
  Cx :real;
  Cy :real;
  degree :integer;
  angle :integer;
  F :integer;
  Fx :real;
  Fy :real;
  r :real;
  cluster :integer;
  lat :real;
  lon: real;
  timeR :real;
  time :TDateTime;
  station_id :integer;
  cruise_id :integer;
end;
GraphNodeType=array of GraphNode;

NodeMD=record
  C :integer;
  degree :integer;
end;
NodeMDType=array of NodeMD;

DataDA=Record
  node :integer;
  lat :real;
  lon: real;
  timeR :real;
  time :TDateTime;
  station_id :integer;
  cruise_id :integer;
end;
DataType=array of DataDA;


var
Graph :GraphNodeType;
Node :NodeMDType;
Data :DataType;

i,j :integer;
n,step,C,F,nd,s,angle :integer;
r,Cx,Cy,Fx,Fy,x,y :real;
new :boolean;

begin
memo1.Lines.Add('...create Graph');
DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));

 fn:=pathdata+'MinTree.txt';
 memo1.Lines.Add(fn);
 AssignFile(fi,fn);
 reset(fi);
 readln(fi);

{.....step1: populate Graph}
    {...Graph: first node}
     n:=1;
     readln(fi,step, C, F, r);
     SetLength(Graph,n);
     Graph[n-1].step:=0;
     Graph[n-1].degree:=0;
     Graph[n-1].angle:=0;
     Graph[n-1].C:=C;
     Graph[n-1].F:=C;
     Graph[n-1].r:=0;
     Graph[n-1].Cx:=0;
     Graph[n-1].Cy:=0;
     Graph[n-1].Fx:=0;
     Graph[n-1].Fy:=0;

     {...Node: first node}
     SetLength(Node,1);
     Node[0].C:=1;
     Node[0].degree:=0;


     {...Graph: second node the same segment}
     n:=2;
     //readln(fi,step, C, F, r);
     SetLength(Graph,n);
     Graph[n-1].step:=step;
     Graph[n-1].degree:=1;
     Graph[n-1].angle:=90;
     Graph[n-1].C:=C;
     Graph[n-1].F:=F;
     Graph[n-1].r:=r;

     {...x y}
     angle:=Graph[n-1].angle;
     Fx:=r*sin(angle*pi/180);
     Fy:=r*cos(angle*pi/180);
     //showmessage('angle='+inttostr(angle)+'  x='+floattostr(x)+'  y='+floattostrF(y,ffFixed,10,5));

    {...Node: second node}
    SetLength(Node,1);
    Node[0].C:=1;
    Node[0].degree:=1;

    Graph[n-1].Cx:=0;
    Graph[n-1].Cy:=0;
    Graph[n-1].Fx:=Fx;
    Graph[n-1].Fy:=Fy;

{fi}while not EOF(fi) do begin
     inc(n);
     readln(fi,step, C, F, r);
     SetLength(Graph,n);
     Graph[n-1].step:=step;
     Graph[n-1].C:=C;
     Graph[n-1].F:=F;
     Graph[n-1].r:=r;

    {...add node degree to Graph}
    new:=true;
{i}for i:=0 to High(Node) do begin
    if C=Node[i].C then begin
      Node[i].degree:=Node[i].degree+1;
      Graph[n-1].degree:=Node[i].degree;
      new:=false;
    end;
{i}end;
    if new=true then begin
     s:=Length(Node);
     SetLength(Node,s+1);
     Node[s].C:=C;
     Node[s].degree:=1;
     Graph[n-1].degree:=1;
    end;

    {...add segment angle}
    nd:=Graph[n-1].degree;
    if nd=1 then angle:=90;
    if nd>1 then begin
    if nd mod(2)=0 then angle:=90-10*(nd-1)
                   else angle:=90+10*(nd-2);
    end;
    Graph[n-1].angle:=angle;

   {...x y}
{i}for i:=0 to High(Graph) do begin
    if C=Graph[i].F then begin
     Cx:=Graph[i].Fx;
     Cy:=Graph[i].Fy;
     Graph[n-1].Cx:=Cx;
     Graph[n-1].Cy:=Cy;
    end;
{i}end;
    angle:=Graph[n-1].angle;
    Fx:=r*sin(angle*pi/180);
    Fy:=r*cos(angle*pi/180);
    x:=Cx+Fx;
    y:=Cy+Fy;
    //showmessage('angle='+inttostr(angle)+'  x='+floattostr(x)+'  y='+floattostrF(y,ffFixed,10,5));

    Graph[n-1].Fx:=x;
    Graph[n-1].Fy:=y;

{fi}end;
     closefile(fi);
{.....step1}

   {...free Node}
   SetLength(Node,0);

   {...create Data}
   fn:=pathdata+'data.txt';
   memo1.Lines.Add(fn);
   AssignFile(fi,fn);
   reset(fi);
   readln(fi);

   n:=0;
{D}while not EOF(fi) do begin
   inc(n);
   SetLength(Data,n);
   readln(fi,Data[n-1].node,Data[n-1].lat,Data[n-1].lon,Data[n-1].timeR,
             Data[n-1].station_id,Data[n-1].cruise_id);
   Data[n-1].time:=floattoDateTime(Data[n-1].timeR);
{D}end;

{.....output}
  fn:=pathdata+'Graph.txt';
  memo1.Lines.Add(fn);
  AssignFile(fo,fn);
  rewrite(fo);
  writeln(fo,'step'
  +#9+'C'
  +#9+'F'
  +#9+'degree'
  +#9+'angle'
  +#9+'segment_length'
  +#9+'C_node_x'
  +#9+'C_node_y'
  +#9+'F_node_x'
  +#9+'F_node_y'
  +#9+'cluster'
  +#9+'latitude'
  +#9+'longitude'
  +#9+'timeReal'
  +#9+'station_id'
  +#9+'cruise_id'
  +#9+'time'
  );

{i}for i:=0 to High(Graph) do begin

    step:=Graph[i].step;
    Cx:=Graph[i].Cx;
    Cy:=Graph[i].Cy;
    Fx:=Graph[i].Fx;
    Fy:=Graph[i].Fy;
    C:=Graph[i].C;
    F:=Graph[i].F;
    r:=Graph[i].r;
    nd:=Graph[i].degree;
    angle:=Graph[i].angle;

    Graph[i].cluster:=0;

{j}for j:=0 to High(Data) do begin
    if F=Data[j].node then begin
     Graph[i].lat:=Data[j].lat;
     Graph[i].lon:=Data[j].lon;
     Graph[i].timeR:=Data[j].timeR;
     Graph[i].time:=Data[j].time;
     Graph[i].station_id:=Data[j].station_id;
     Graph[i].cruise_id:=Data[j].cruise_id;
    end;
{j}end;

    if CheckBox1.Checked then
    memo1.Lines.Add(inttostr(step)
    +#9+inttostr(C)
    +#9+inttostr(nd)     //node degree
    +#9+inttostr(angle)  //segment angle
    +#9+inttostr(F)
    +#9+floattostr(Fx)
    +#9+floattostr(Fy)
    +#9+floattostr(r)
    );

    writeln(fo,inttostr(step),
    #9,inttostr(C),
    #9,inttostr(F),
    #9,inttostr(nd),
    #9,inttostr(angle),
    #9,floattostrF(r,ffFixed,15,10),
    #9,floattostrF(Cx,ffFixed,10,6),
    #9,floattostrF(Cy,ffFixed,10,6),
    #9,floattostrF(Fx,ffFixed,10,6),
    #9,floattostrF(Fy,ffFixed,10,6),
    #9,inttostr(Graph[i].cluster),
    #9,floattostrF(Graph[i].lat,ffFixed,10,5),
    #9,floattostrF(Graph[i].lon,ffFixed,10,5),
    #9,floattostrF(Graph[i].timeR,ffFixed,12,5),
    #9,inttostr(Graph[i].station_id),
    #9,inttostr(Graph[i].cruise_id),
    #9,datetimetostr(Graph[i].time)
    );

{i}end;
    closefile(fo);
{.....output}

DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;




procedure TfrmSplitCruises.btnPlotMinTreeClick(Sender: TObject);
type
 GraphNode=Record
  step :integer;
  C :integer;
  F :integer;
  degree :integer;
  angle :integer;
  r :real;
  Cx :real;
  Cy :real;
  Fx :real;
  Fy :real;
  cluster :integer;
  lat :real;
  lon: real;
  timeR :real;
  station_id :integer;
  cruise_id :integer;
  time :TDateTime;
end;
GraphNodeType=array of GraphNode;

var
Graph :GraphNodeType;
n :integer;

begin
memo1.Lines.Add('...create Graph');
DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));

 fn:=pathdata+'dataC_cl-8.txt';
 memo1.Lines.Add(fn);
 AssignFile(fi,fn);
 reset(fi);
 readln(fi);


 //Chart1LineSeries1.Pointer.Style:=psCircle;
 {Chart1LineSeries1.Pointer.Pen.Color:=clRed;
 Chart1LineSeries1.Pointer.HorizSize:=2;
 Chart1LineSeries1.Pointer.VertSize:=2;
 Chart1LineSeries1.Pointer.Brush.Color:=clRed;

 Chart1LineSeries1.ShowPoints:=true;
 Chart1LineSeries1.Marks.Visible:=true;
 Chart1LineSeries1.ShowLines:=true; }

 //VectorCoordKind = vckStartEnd

   {Chart1FieldSeries1.VectorCoordKind := vckStartEnd;
   Chart1FieldSeries1.Arrow.Width := 6;
   Chart1FieldSeries1.Arrow.Length := 15;
   Chart1FieldSeries1.Arrow.BaseLength := Chart1FieldSeries1.Arrow.Length;
   Chart1FieldSeries1.Pen.Color := clRed;
   Chart1fieldSeries1.Pen.Width := 3; }

{step	C	F	degree	angle	segment_length
C_node_x	C_node_y        F_node_x	F_node_y
cluster	latitude	longitude	timeReal
station_id	cruise_id	time}

 n:=0;
{D}while not EOF(fi) do begin
 inc(n);
 showmessage('n='+inttostr(n));
 SetLength(Graph,n);
 readln(fi,Graph[n-1].step,
           Graph[n-1].C,
           Graph[n-1].F,
           Graph[n-1].degree,
           Graph[n-1].angle,
           Graph[n-1].r,
           Graph[n-1].Cx,
           Graph[n-1].Cy,
           Graph[n-1].Fx,
           Graph[n-1].Fy,
           Graph[n-1].cluster,
           Graph[n-1].lat,
           Graph[n-1].lon,
           Graph[n-1].timeR,
           Graph[n-1].station_id,
           Graph[n-1].cruise_id);

           Graph[n-1].time:=floattodatetime(Graph[n-1].timeR);

 //Chart1LineSeries1.AddXY(Graph[n-1].Fx,Graph[n-1].Fy,inttostr(Graph[n-1].F));
 //AddVector(x,y: Double; vectorx, vectory: Double; ALabel: String = ''; AColor: TColor = clTAColor)

 Chart1FieldSeries1.AddVector(Graph[n-1].Cx,Graph[n-1].Cy,
                              Graph[n-1].Fx,Graph[n-1].Fy,
                              inttostr(Graph[n-1].F),clRed);

   //Chart1FieldSeries1.AddVector(P[0].X, P[0].Y, P[0].X + V[0].X, P[0].Y + V[0].Y);
   //Chart1FieldSeries1.AddVector(P[1].X, P[1].Y, P[1].X + V[1].X, P[1].Y + V[1].Y);
   //Chart1FieldSeries1.AddVector(P[2].X, P[2].Y, P[2].X + V[2].X, P[2].Y + V[2].Y);


 showmessage('Next?');

{D}end;
    closefile(fi);

end;




procedure TfrmSplitCruises.btnEstimateNumberofClustersClick(Sender: TObject);

type
segment=Record
  C:integer;
  F:Integer;
  r:real;
end;
SubTreeType=array of segment;

var
Graph :SubTreeType;
i,k,n,itr,count,cc :integer;
step,C,F,degree,angle :integer;
r,md,sd,rmin,rmax,r_step,r_max,r_limit :real;
s1,s2 :double;

begin
 memo1.Lines.Add('...estimate number of clusters');
 DT1:=NOW;
 memo1.Lines.Add('...start: '+datetimetostr(DT1));

  fn:=pathdata+'Graph.txt';
  memo1.Lines.Add(fn);
  AssignFile(fi,fn);
  reset(fi);
  readln(fi);

    n:=0;
    md:=0;    sd:=0;    s1:=0;    s2:=0; rmin:=9999; rmax:=0;
{D}while not EOF(fi) do begin
    inc(n);
    SetLength(Graph,n);
    readln(fi,step,C,F,degree,angle,r);
    Graph[n-1].C:=C;
    Graph[n-1].F:=F;
    Graph[n-1].r:=r;

    s1:=s1+r;
    s2:=s2+r*r;
    if r<rmin then rmin:=r;
    if r>rmax then rmax:=r;
{D}end;
    closefile(fi);

    md:=s1/n;
    sd:=(s2-s1*s1/n)/n;
    if sd<>0 then sd:=sqrt(abs(sd));

    Edit1.Text:=floattostrF(md,ffFixed,7,3);
    cc:=0; //count clusters
    for i:=1 to High(Graph) do if Graph[i].r>md then cc:=cc+1;
    Label3.Caption:='number of clusters: '+inttostr(cc);

    memo1.Lines.Add('');
    memo1.Lines.Add('n='+inttostr(n));
    memo1.Lines.Add('md='+floattostr(md));
    memo1.Lines.Add('sd='+floattostr(sd));
    memo1.Lines.Add('rmin='+floattostr(rmin));
    memo1.Lines.Add('rmax='+floattostr(rmax));


{.....Chart2 cluster number depending on threshold }
    r_max:=10*md;
    itr:=1000;  //iterations
    r_step:=rmax/itr;
{k}for k:=1 to itr do begin
    r_limit:=r_step*(k-1);
    count:=0;
    for i:=1 to High(Graph) do if Graph[i].r>=r_limit then count:=count+1;
    Chart1LineSeries1.AddXY(r_limit,count);
{k}end;

//Chart1LineSeries1.Marks.Style:=smsValue;    //выводит метку значение по оси y
//Chart1LineSeries1.Marks.Style:=smsLabel;    //выводит метку значение по оси y
Chart1LineSeries1.Pointer.Style:=psCircle;
Chart1LineSeries1.Pointer.Pen.Color:=clRed;
Chart1LineSeries1.Pointer.HorizSize:=2;
Chart1LineSeries1.Pointer.VertSize:=2;
Chart1LineSeries1.Pointer.Brush.Color:=clRed;
Chart1.Title.Text.Strings[0]:=('Cluster number/segment length dependence in the graph');
Chart1.Title.Visible:=true;
//Chart1LineSeries1.Pointer.Style:=psCircle;
Chart1LineSeries1.Pointer.Pen.Color:=clRed;
Chart1.BottomAxis.Marks.LabelFont.Orientation:=900; //поворачивает метку на оси на 90 градусов
Chart1.BottomAxis.Title.Caption:='Graph segment length';
Chart1.BottomAxis.Title.Visible:=true;
Chart1.LeftAxis.Title.Caption:='Number of clusters';
Chart1.LeftAxis.Title.Visible:=true;

DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;




procedure TfrmSplitCruises.Edit1DblClick(Sender: TObject);
var
cc :integer;
step,C,F,degree,angle :integer;
r,rt :real;
begin

fn:=pathdata+'Graph.txt';
memo1.Lines.Add(fn);
AssignFile(fi,fn);
reset(fi);
readln(fi);

    rt:=strtofloat(Edit1.Text);  //r threshold
    cc:=0; //count clusters
{D}while not EOF(fi) do begin
    readln(fi,step,C,F,degree,angle,r);
    if r>rt then cc:=cc+1;
{D}end;
    closefile(fi);
    cc:=cc+1;
    Label3.Caption:='number of clusters: '+inttostr(cc);
    Application.ProcessMessages;
end;


procedure TfrmSplitCruises.btnSplitGraphToClustersClick(Sender: TObject);
type
segment=Record
  C:integer;
  F:Integer;
  r:real;
end;
SubTreeType=array of segment;

Cluster=Record
  cluster :integer;
  nodes :integer;
  nodes_arr :array of integer;
end;
ClusterType=array of Cluster;

var
Graph,Tree :SubTreeType;
Classification :ClusterType;
i,j,k,n,s,cc,last,index,cs,cls,csi :integer;
step,C,F,degree,angle :integer;
r,rt :real;
str: string;
new :boolean;
label 10;

begin
memo1.Lines.Add('...split Graph into clusters');
DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));

 fn:=pathdata+'Graph.txt';
 memo1.Lines.Add(fn);
 AssignFile(fi,fn);
 reset(fi);
 readln(fi);
 readln(fi); //skip zero segment

   n:=0;
{D}while not EOF(fi) do begin
   inc(n);
   SetLength(Graph,n);
   readln(fi,step,C,F,degree,angle,r);
   Graph[n-1].C:=C;
   Graph[n-1].F:=F;
   Graph[n-1].r:=r;
{D}end;
   closefile(fi);

   rt:=strtofloat(Edit1.Text);
   cc:=0;
   for i:=1 to High(graph) do if Graph[i].r>rt then cc:=cc+1;
   cc:=cc+1;
   Label3.Caption:='number of clusters: '+inttostr(cc);
   Application.ProcessMessages;

    cls:=0; //classification RofDA size
{k}for k:=1 to cc do begin

    {...first node from C always belong to cluster}
    s:=1;
    SetLength(Tree,s);
    i:=0;
    Tree[s-1].C:=Graph[i].C;
    Tree[s-1].F:=Graph[i].F;
    Tree[s-1].r:=Graph[i].r;
    cs:=1; //cluster size

    //showmessage('##1 Length(Tree)='+inttostr(Length(Tree)));
    //showmessage('##1 Length(Graph)='+inttostr(Length(Graph)));

//showmessage('k='+inttostr(k)+'  Tree (0): '+inttostr(s-1)+'  '+inttostr(Tree[s-1].C)+'-'+inttostr(Tree[s-1].F)
//+'  r='+floattostr(Tree[s-1].r));

{...delete first segment from Graph}
last:=high(Graph);
if i<last then move(Graph[i+1],Graph[i], (last-i)*sizeof(Graph[i]));
setlength(Graph,last);

    csi:=0; //claster search index
10: cs:=Length(Tree);

//showmessage('csi='+inttostr(csi));

{i}for i:=csi to cs-1 do begin
   //showmessage('Tree: '+inttostr(i)+'  '+inttostr(Tree[i].C)+'-'+inttostr(Tree[i].F)
   //+'  r='+floattostr(Tree[i].r));

{j}for j:=0 to high(Graph) do begin
    new:=false;
   if (Tree[i].C=Graph[j].C) and (Graph[j].r<rt) and (csi=0) then new:=true;
   if (Tree[i].F=Graph[j].C) and (Graph[j].r<rt) then new:=true;

   if new=true then begin
   inc(s);
   SetLength(Tree,s);
   Tree[s-1].C:=Graph[j].C;
   Tree[s-1].F:=Graph[j].F;
   Tree[s-1].r:=Graph[j].r;
//   showmessage('Tree (add): '+inttostr(s-1)+'  '+inttostr(Tree[s-1].C)+'-'+inttostr(Tree[s-1].F)
//   +'  r='+floattostr(Tree[s-1].r));
   end;
{j}end;
{i}end;

//showmessage('cs='+inttostr(cs)+'  Length(Graph)='+inttostr(Length(Graph))
//+'  Length(Tree)='+inttostr(Length(Tree)));

   {...add segments until the Tree stops growing}
   if Length(Tree)>cs then begin
   csi:=cs;
//showmessage('goto 10');
   goto 10;
   end;

    memo1.Lines.Add('... Cluster#='+inttostr(k)+'  Length(Tree)='+inttostr(Length(Tree)));
    inc(cls);
    SetLength(Classification,cls);
    Classification[cls-1].cluster:=k;
    Classification[cls-1].nodes:=Length(Tree);
    {...first cluster includes the first C node}
    if cls=1 then Classification[cls-1].nodes:=Classification[cls-1].nodes+1;
    SetLength(Classification[cls-1].nodes_arr,Classification[cls-1].nodes);
{C}for j:=0 to High(Tree) do begin
    memo1.Lines.Add(inttostr(Tree[j].C)
    +#9+inttostr(Tree[j].F)
    +#9+floattostr(Tree[j].r));

    {...first cluster}
    if cls=1 then begin
     if j=0 then begin Classification[cls-1].nodes_arr[0]:=Tree[j].C;
                       Classification[cls-1].nodes_arr[1]:=Tree[j].F;
            end
            else Classification[cls-1].nodes_arr[j+1]:=Tree[j].F;
    end;

    {...all other}
    if cls>1 then
    Classification[cls-1].nodes_arr[j]:=Tree[j].F;

{C}end;


//showmessage('k='+inttostr(k)+'  Length(Tree-Graph)='+inttostr(Length(Tree))+'-'+inttostr(Length(Graph)));


{...delete segments from Graph}
{i}for i:=1 to high(Tree) do begin
{j}for j:=0 to high(Graph) do begin
   if (Tree[i].C=Graph[j].C) and (Tree[i].F=Graph[j].F) then index:=j;
{j}end;
   last:=high(Graph);
   if index<last then move(Graph[index+1],Graph[index], (last-index)*sizeof(Graph[index]));
   setlength(Graph,last);
{i}end;
{k}end;


{...output}
fn:=pathData+'clusters.txt';
assignfile(fo,fn);
rewrite(fo);
writeln(fo,'# first line: number of clusters ');
writeln(fo,'# each cluster consists of a number of nodes followed by node numbers');
writeln(fo,Length(Classification));


memo1.Lines.Add('');
memo1.Lines.Add('classification');
for i:=0 to High(Classification) do begin
   str:='';
   memo1.Lines.Add('cluster='+inttostr(Classification[i].cluster)+'  elements#='+inttostr(Classification[i].nodes));
   for j:=0 to Classification[i].nodes-1 do str:=str+inttostr(Classification[i].nodes_arr[j])+',';
   memo1.Lines.Add(str);

   writeln(fo,inttostr(Classification[i].nodes));
   for j:=0 to Classification[i].nodes-1 do writeln(fo,inttostr(Classification[i].nodes_arr[j]));
   writeln(fo,'------------------');

end;
   closefile(fo);

DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;



procedure TfrmSplitCruises.btnAddClustersToDataClick(Sender: TObject);
type
GraphNode=Record
  step :integer;
  C :integer;
  Cx :real;
  Cy :real;
  degree :integer;
  angle :integer;
  F :integer;
  Fx :real;
  Fy :real;
  r :real;
  cluster :integer;
  lat :real;
  lon: real;
  timeR :real;
  time :TDateTime;
  station_id :integer;
  cruise_id :integer;
end;
GraphNodeType=array of GraphNode;

Cluster=Record
  cluster :integer;
  nodes :integer;
  nodes_arr :array of integer;
end;
ClusterType=array of Cluster;

var
Graph :GraphNodeType;
Classification :ClusterType;
i,j,k,s,cc,nc,node: integer;
step,C,F,degree,angle,cln,station_id,cruise_id :integer;
r,Cx,Cy,Fx,Fy,lat,lon,timeR :real;
str :string;

begin
memo1.Lines.Add('...add clusters to data');
DT1:=NOW;
memo1.Lines.Add('...start: '+datetimetostr(DT1));

{.....1 create Graph DAofR}
fn:=pathdata+'Graph.txt';
memo1.Lines.Add(fn);
AssignFile(fi,fn);
reset(fi);
readln(fi);

    s:=0;
{G}while not EOF(fi) do begin
    readln(fi,step,C,F,degree,angle,r,Cx,Cy,
              Fx,Fy,cln,lat,lon,timeR,station_id,cruise_id);
    inc(s);
    SetLength(Graph,s);
    Graph[s-1].step:=step;
    Graph[s-1].degree:=degree;
    Graph[s-1].angle:=angle;
    Graph[s-1].C:=C;
    Graph[s-1].F:=F;
    Graph[s-1].r:=r;
    Graph[s-1].Cx:=Cx;
    Graph[s-1].Cy:=Cy;
    Graph[s-1].Fx:=Fx;
    Graph[s-1].Fy:=Fy;
    Graph[s-1].cluster:=cln;
    Graph[s-1].lat:=lat;
    Graph[s-1].lon:=lon;
    Graph[s-1].timeR:=timeR;
    Graph[s-1].time:=floattodatetime(timeR);
    Graph[s-1].station_id:=station_id;
    Graph[s-1].cruise_id:=cruise_id;
{G}end;
    closefile(fi);


{.....2: create Classification DAofR}
fn:=pathdata+'clusters.txt';
memo1.Lines.Add(fn);
AssignFile(fi,fn);
reset(fi);
readln(fi);
readln(fi);
readln(fi,cc); //clusters count

    s:=0;
{C}for k:=1 to cc do begin
    readln(fi,nc); //node count
    inc(s);
    SetLength(Classification,s);
    Classification[s-1].cluster:=k;
    Classification[s-1].nodes:=nc;
    SetLength(Classification[s-1].nodes_arr,nc);

{f}for i:=0 to nc-1 do begin
    readln(fi,node);
    Classification[s-1].nodes_arr[i]:=node;
{f}end;
    readln(fi); // -----------------
{C}end;
    closefile(fi);

    {...control}
    if CheckBox1.Checked then begin
    memo1.Lines.Add('');
    memo1.Lines.Add('classification');
    for i:=0 to High(Classification) do begin
       str:='';
       memo1.Lines.Add('cluster='+inttostr(Classification[i].cluster)+'  elements#='+inttostr(Classification[i].nodes));
       for j:=0 to Classification[i].nodes-1 do str:=str+inttostr(Classification[i].nodes_arr[j])+',';
       memo1.Lines.Add(str);
    end;
    end;


{.....3: add clusters from Classification to Graph}
{C}for k:=0 to High(Classification) do begin
   cc:=Classification[k].cluster;
   nc:=Classification[k].nodes;
{node}for i:=0 to nc do begin
       node:=Classification[k].nodes_arr[i];
{G}for j:=0 to High(Graph) do begin
    if node=Graph[j].F then Graph[j].cluster:=cc;
{G}end;
{node}end;
{C}end;


{.....4: output}
fn:=pathData+'dataC'+'_cl-'+inttostr(cc)+'.txt';
assignfile(fo,fn);
rewrite(fo);
writeln(fo,'step'
 +#9+'C'
 +#9+'F'
 +#9+'degree'
 +#9+'angle'
 +#9+'segment_length'
 +#9+'C_node_x'
 +#9+'C_node_y'
 +#9+'F_node_x'
 +#9+'F_node_y'
 +#9+'cluster'
 +#9+'latitude'
 +#9+'longitude'
 +#9+'timeReal'
 +#9+'station_id'
 +#9+'cruise_id'
 +#9+'time'
 );

{G}for i:=0 to High(Graph) do begin
    writeln(fo,inttostr(Graph[i].step),
    #9,inttostr(Graph[i].C),
    #9,inttostr(Graph[i].F),
    #9,inttostr(Graph[i].degree),
    #9,inttostr(Graph[i].angle),
    #9,floattostrF(Graph[i].r,ffFixed,15,10),
    #9,floattostrF(Graph[i].Cx,ffFixed,10,6),
    #9,floattostrF(Graph[i].Cy,ffFixed,10,6),
    #9,floattostrF(Graph[i].Fx,ffFixed,10,6),
    #9,floattostrF(Graph[i].Fy,ffFixed,10,6),
    #9,inttostr(Graph[i].cluster),
    #9,floattostrF(Graph[i].lat,ffFixed,10,5),
    #9,floattostrF(Graph[i].lon,ffFixed,10,5),
    #9,floattostrF(Graph[i].timeR,ffFixed,12,5),
    #9,inttostr(Graph[i].station_id),
    #9,inttostr(Graph[i].cruise_id),
    #9,datetimetostr(Graph[i].time));
{G}end;
    closefile(fo);

DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;




end.


