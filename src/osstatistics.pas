unit osstatistics;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, CheckLst, ExtCtrls,ComCtrls, Spin, IniFiles, Dialogs, DateUtils, ToolWin,
  Menus, FileUtil, TAGraph, TASeries, TAMultiSeries;

type

  { Tfrmosstatistics }

  Tfrmosstatistics = class(TForm)
    btnGetStatistics: TButton;
    clbStatList: TCheckGroup;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo4: TMemo;
    PageControl1: TPageControl;
    Splitter1: TSplitter;
    tabBarHorisontal: TTabSheet;
    tabBarPoints: TTabSheet;
    tabBarVertical: TTabSheet;
    TabControl1: TTabControl;
    TabControl2: TTabControl;
    TabControl3: TTabControl;
    tabLog: TTabSheet;
    tabSelection: TTabSheet;
    ToolBar1: TToolBar;
    btnCopyToClip: TToolButton;
    btnSaveMap: TToolButton;
    ToolButton2: TToolButton;
    PopupMenu1: TPopupMenu;
    Preferences1: TMenuItem;
    Standardchartsettings1: TMenuItem;

    procedure clbStatListItemClick(Sender: TObject; Index: integer);
    procedure FormShow(Sender: TObject);
    procedure btnGetStatisticsClick(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure TabControl2Change(Sender: TObject);
    procedure TabControl3Change(Sender: TObject);
//    procedure clbStatListClick(Sender: TObject);
//    procedure Label3Click(Sender: TObject);
    procedure btnSaveMapClick(Sender: TObject);
    procedure btnCopyToClipClick(Sender: TObject);
    procedure Standardchartsettings1Click(Sender: TObject);
  //  procedure lbAllSourcesClick(Sender: TObject);
//    procedure Label4Click(Sender: TObject); // перестраиваем карты

  private
    procedure YearStatistics;
    procedure MonthStatistics;
    procedure VesselBar;
    procedure CountryBar;
    procedure SourceBar;
    procedure InstrumentBar;
    procedure ParameterBar;
    procedure DayTimeDiagram;
    procedure HorizontalBar;
    procedure YearBySources;
    procedure YearByCountries;
    procedure AllStationsMap;
    procedure AllStationsMapByYear;
    procedure MonthYearStatistics;

  public
    { Public declarations }
  end;

var
  frmosstatistics: Tfrmosstatistics;
  f_dat:text;
  Count:integer;
  PathStatistics:string;

implementation

{$R *.lfm}

uses osmain, dm;


procedure Tfrmosstatistics.FormShow(Sender: TObject);
Var
  k:integer;
begin
 PathStatistics:=GlobalUnloadPath+'statistics'+PathDelim;
  if not DirectoryExists(PathStatistics) then CreateDir(PathStatistics);

   tabBarVertical.TabVisible:=false;
   tabBarHorisontal.TabVisible:=false;
   tabBarPoints.TabVisible:=false;

 for k:=2 to clbStatList.Items.Count-1 do
  clbStatList.CheckEnabled[k]:=false;
end;


procedure Tfrmosstatistics.clbStatListItemClick(Sender: TObject; Index: integer);
Var
  I: Integer;
  Flag:boolean;
begin
  Flag:=false;
   for I:=0 to clbStatList.Items.Count-1 do
     if clbStatList.Checked[I] then Flag:=true;
  btnGetStatistics.Enabled:=flag;
end;


procedure Tfrmosstatistics.btnGetStatisticsClick(Sender: TObject);
var
Ini:TIniFile;
CommonTime:TDateTime;
begin
btnGetStatistics.Enabled:=false;
PageControl1.ActivePageIndex:=1;
Application.ProcessMessages;

 try
  Ini := TIniFile.Create(IniFileName);
   Ini.ReadSection('Standart levels', memo4.Lines);
 finally
  Ini.Free;
 end;

//   showmessage(PathStatistics);
   memo1.Clear;
   TabControl1.Tabs.Clear;
   TabControl2.Tabs.Clear;
   TabControl3.Tabs.Clear;

   tabBarVertical.TabVisible:=false;
   tabBarHorisontal.TabVisible:=false;
   tabBarPoints.TabVisible:=false;

 {  frmmain.ProgressBar1.Position:=0;
   frmmain.ProgressBar1.Max:=Count;
   Application.ProcessMessages;  }

   CommonTime:=Now;

   try
    if clbStatList.Checked[0]  then YearStatistics;
    if clbStatList.Checked[1]  then MonthStatistics;
    if clbStatList.Checked[2]  then ParameterBar;
    if clbStatList.Checked[3]  then VesselBar;
    if clbStatList.Checked[4]  then CountryBar;
    if clbStatList.Checked[5]  then SourceBar;
    if clbStatList.Checked[6]  then HorizontalBar;
    if clbStatList.Checked[7]  then DayTimeDiagram;
    if clbStatList.Checked[8]  then YearBySources;
    if clbStatList.Checked[9]  then YearByCountries;
    if clbStatList.Checked[10] then InstrumentBar;
    if clbStatList.Checked[11] then AllStationsMap;
    if clbStatList.Checked[12] then AllStationsMapByYear;
    if clbStatList.Checked[13] then MonthYearStatistics;
   finally
    frmdm.TR.Commit;
    btnGetStatistics.Enabled:=true;
   end;
   memo1.Lines.Add('Done!');
   memo1.Lines.Add('Common time: '+TimeToStr(Now-CommonTime));

  OpenDocument(PChar(PathStatistics));
end;


procedure Tfrmosstatistics.YearStatistics;
var
dat:text;
k, cnt: integer;
StartTime, dat1:TDateTime;
yy1, mn1, dd1, yy2, mn2, dd2, yy, mn, dd:word;
begin

StartTime:=Now;
Assignfile(dat,PathStatistics+'Year.dat'); rewrite(dat);
writeln(dat, 'Year'+#9+'Stations');

memo1.Lines.Add('STATION DISTRIBUTION BY YEAR:');

  DecodeDate(SDateMin, yy1, mn1, dd1);
  DecodeDate(SDateMax, yy2, mn2, dd2);

  for k:=yy1 to yy2 do begin
   cnt:=0;
   frmdm.Q.First;
   while not frmdm.Q.EOF do begin
    dat1:=frmdm.Q.FieldByName('DATEANDTIME').AsDateTime;
     DecodeDate(dat1, yy, mn, dd);
     if yy=k then inc(cnt);
    frmdm.Q.Next;
   end;
   writeln(dat, k, #9, cnt);
  end;
 Closefile(dat);

memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

TabControl1.Tabs.Add('Year');
TabControl1.OnChange(Self);
tabBarVertical.TabVisible:=true;
Application.ProcessMessages;
end;


procedure Tfrmosstatistics.MonthYearStatistics;
var
k, mn, CountSt, CountYear, YearCurrent, i, j:integer;
YearMin, YearMax:integer;
StartTime:TDateTime;
instr, source1:string;
st_arr:array [1..12, 1..125] of integer;
begin
StartTime:=Now;

for I := 1 to 12 do begin
 for j := 1 to 125 do begin
  st_arr[i, j]:=0;
 end;
end;

memo1.Lines.Add('STATION DISTRIBUTION BY YEAR BY MONTH:');

{if CatalogStatistics=false then begin
  YearMin:=SpinEdit5.Value;
  YearMax:=SpinEdit6.Value;
   with odbdm.ib1q2 do begin
    Close;
      SQL.Clear;
      SQL.Add(' Select station.absnum from Station, Station_info where ');
      SQL.Add(' Station.absnum=Station_info.absnum and ' );
      SQL.Add(' StLat between :LatMin and  :LatMax and ' );
      SQL.Add(' StLon between :LonMin and  :LonMax and ' );
      SQL.Add(' Extract(Year from StDate)= :CurrentYear and ' );
      SQL.Add(' Extract(Month from StDate)=:CurrentMonth ');
      if rgQC.ItemIndex=1 then SQL.Add(' and StFlag<16384 ');

       instr:='';
        for k:=0 to chkInstrument.Items.Count-1 do
         if chkInstrument.Checked[k]=true then if instr='' then instr:=inttostr(k) else instr:=instr+','+inttostr(k);
       SQL.Add(' and INSTRUMENT in ('+instr+')');

      source1:='';
       for k:=0 to clbsources.Items.Count-1 do
        if clbsources.Checked[k]=true then if source1='' then source1:=QuotedStr(clbsources.Items.strings[k]) else
        source1:=source1+','+QuotedStr(clbsources.Items.strings[k]);
      SQL.Add(' and StSource in ('+source1+')');

    Prepare;
   end;
 end;

 CountYear:=YearMax-YearMin+1;

  for k:=1 to CountYear do begin
    YearCurrent:=YearMin+k-1;
   for mn:=1 to 12 do begin

   with odbdm.ib1q2 do begin
    if CatalogStatistics=false then begin
     ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
     ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
     ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
     ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
     ParamByName('CurrentYear').AsInteger:=YearCurrent;
     ParamByName('CurrentMonth').AsInteger:=mn;
    end;
    if CatalogStatistics=true then begin
     ParamByName('CurrentYear').AsInteger:=YearCurrent;
     ParamByName('CurrentMonth').AsInteger:=mn;
    end;
   Open;
   end;

   CountSt:=0;
   While not odbdm.ib1q2.Eof do begin
     inc(CountSt);
     odbdm.ib1q2.Next;
   end;
   odbdm.ib1q2.Close;
   st_arr[mn, k]:=CountSt;
  end;
  end;

  Assignfile(f_dat,PathStatistics+'\MonthYear.dat'); rewrite(f_dat);
  //writeln(f_dat, 'Date'+#9+'Stations');

  for k := 1 to CountYear do
   writeln(f_dat, (YearMin+k-1):5,
                   st_arr[1,  k]:6,
                   st_arr[2,  k]:6,
                   st_arr[3,  k]:6,
                   st_arr[4,  k]:6,
                   st_arr[5,  k]:6,
                   st_arr[6,  k]:6,
                   st_arr[7,  k]:6,
                   st_arr[8,  k]:6,
                   st_arr[9,  k]:6,
                   st_arr[10, k]:6,
                   st_arr[11, k]:6,
                   st_arr[12, k]:6);

CloseFile(f_dat);   }

//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
memo1.Lines.Add(PathStatistics+'\MonthYear.dat');
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

TabControl1.Tabs.Add('MonthYear');
TabControl1.OnChange(Self);
tabBarVertical.TabVisible:=true;
Application.ProcessMessages;
end;



procedure Tfrmosstatistics.MonthStatistics;
var
k,countst,monthcurrent:integer;
StartTime:TDateTime;
instr, source1:string;
begin
StartTime:=Now;
Assignfile(f_dat,PathStatistics+'\Month.dat'); rewrite(f_dat);
writeln(f_dat, 'Month', #9, 'Stations');

memo1.Lines.Add('STATION DISTRIBUTION BY MONTH:');

{ if CatalogStatistics=false then begin
   with odbdm.ib1q2 do begin
    Close;
      SQL.Clear;
      SQL.Add(' Select station.absnum from Station, Station_info where');
      SQL.Add(' Station.absnum=Station_info.absnum and ' );
      SQL.Add(' StLat between :LatMin and  :LatMax and ' );
      SQL.Add(' StLon between :LonMin and  :LonMax and ' );
      SQL.Add(' Extract(Day from StDate) between :DayMin and :DayMax and ' );
      SQL.Add(' Extract(Month from StDate)=:CurrentMonth and ' );
      SQL.Add(' Extract(Year from StDate) between :YearMin and :YearMax ' );
      if rgQC.ItemIndex=1 then SQL.Add(' and StFlag<16384 ');

       instr:='';
        for k:=0 to chkInstrument.Items.Count-1 do
         if chkInstrument.Checked[k]=true then if instr='' then instr:=inttostr(k) else instr:=instr+','+inttostr(k);
       SQL.Add(' and INSTRUMENT in ('+instr+')');

      source1:='';
       for k:=0 to clbsources.Items.Count-1 do
        if clbsources.Checked[k]=true then if source1='' then source1:=QuotedStr(clbsources.Items.strings[k]) else
        source1:=source1+','+QuotedStr(clbsources.Items.strings[k]);
      SQL.Add(' and StSource in ('+source1+')');

    Prepare;
   end;
 end;


  for k:=1 to 12 do begin
    MonthCurrent:=k;
   with odbdm.ib1q2 do begin
    if CatalogStatistics=false then begin
      ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
      ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
      ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
      ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
      ParamByName('DayMin').AsInteger:=SpinEdit1.Value;
      ParamByName('DayMax').AsInteger:=SpinEdit2.Value;
      ParamByName('CurrentMonth').AsInteger:=MonthCurrent;
      ParamByName('YearMin').AsInteger:=SpinEdit5.Value;
      ParamByName('YearMax').AsInteger:=SpinEdit6.Value;
    end;

    if CatalogStatistics=true then begin
     ParamByName('CurrentMonth').AsInteger:=MonthCurrent;
    end;
    Open;
   end;
   CountSt:=0;
   While not odbdm.ib1q2.Eof do begin
     inc(CountSt);
     odbdm.ib1q2.Next;
   end;
   odbdm.ib1q2.Close;
    writeln(f_dat, MonthCurrent, #9, CountSt, ' ');
  end;
CloseFile(f_dat);    }

//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
memo1.Lines.Add(PathStatistics+'\Month.dat');
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

TabControl1.Tabs.Add('Month');
tabBarVertical.TabVisible:=true;
TabControl1.OnChange(Self);
Application.ProcessMessages;
end;


procedure Tfrmosstatistics.ParameterBar;
Var
PrfCount:integer;
k_Prf:integer;
tblPar:string;
StartTime:TDateTime;
begin
StartTime:=Now;
Assignfile(f_dat,PathStatistics+'\Parameter.dat'); rewrite(f_dat);
WriteLn(f_dat, 'Parameter'+#9+'Stations');

memo1.Lines.Add('STATIONS BY PARAMETER:');

{  for k_prf:=0 to frmmain.ListBox2.Items.Count-1 do begin
    tblPar:=frmmain.ListBox2.Items.Strings[k_prf];

    if odbdm.ib1q1.Active=false then SelectAllFromStation;

     prfCount:=0;
     odbdm.ib1q1.First;
   while not odbdm.ib1q1.Eof do begin
      with odbdm.ib1q2 do begin
       Close;
           SQL.Clear;
           SQL.Add(' select absnum from ');
           SQL.Add(tblPar);
           SQL.Add(' where absnum=:absnum ');
           ParamByName('absnum').AsInteger:=odbdm.ib1q1.FieldByName('absnum').AsInteger;
       Open;
         if odbdm.ib1q2.IsEmpty=false then prfCount:=prfCount+1;
       Close;
       end;
     odbdm.ib1q1.Next;
  end;
    if prfCount>0 then writeln(f_dat, k_prf, #9, inttostr(PrfCount), #9, Copy(tblPar,3,length(tblpar)));
  end;
CloseFile(f_dat);  }

//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
memo1.Lines.Add(PathStatistics+'\Parameter.dat');
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

TabControl1.Tabs.Add('Parameter');
tabBarVertical.TabVisible:=true;
TabControl1.OnChange(Self);
Application.ProcessMessages;
end;


procedure Tfrmosstatistics.VesselBar;
var
k,count_VN:integer;
VN, instr, source1:string;
StartTime:TDateTime;
begin
StartTime:=Now;
AssignFile(f_dat,PathStatistics+'\Vessel.dat'); rewrite(f_dat);
writeln(f_dat, 'Vessel'+#9+'Stations');

memo1.Lines.Add('STATION DISTRIBUTION BY VESSEL:');

 {  with odbdm.ib1q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select StVesselName as VN, count(StVesselName) as count_VN ');
    SQL.Add(' from Station, station_info where ');
    SQL.Add(' Station.absnum=Station_info.absnum and ' );
    SQL.Add(' StLat between :LatMin and  :LatMax and ' );
    SQL.Add(' StLon between :LonMin and  :LonMax and ' );
    SQL.Add(' Extract(Day from StDate) between :DayMin and :DayMax and ' );
    SQL.Add(' Extract(Month from StDate) between :MonthMin and :MonthMax and ' );
    SQL.Add(' Extract(Year from StDate) between :YearMin and :YearMax ' );
    if rgQC.ItemIndex=1 then SQL.Add(' and StFlag<16384 ');

     instr:='';
      for k:=0 to chkInstrument.Items.Count-1 do
       if chkInstrument.Checked[k]=true then if instr='' then instr:=inttostr(k) else instr:=instr+','+inttostr(k);
     SQL.Add(' and INSTRUMENT in ('+instr+')');

      source1:='';
       for k:=0 to clbsources.Items.Count-1 do
        if clbsources.Checked[k]=true then if source1='' then source1:=QuotedStr(clbsources.Items.strings[k]) else
        source1:=source1+','+QuotedStr(clbsources.Items.strings[k]);
      SQL.Add(' and StSource in ('+source1+')');

    SQL.Add(' group by StVesselName ' );

    ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
    ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
    ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
    ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
    ParamByName('DayMin').AsInteger:=SpinEdit1.Value;
    ParamByName('DayMax').AsInteger:=SpinEdit2.Value;
    ParamByName('MonthMin').AsInteger:=SpinEdit3.Value;
    ParamByName('MonthMax').AsInteger:=SpinEdit4.Value;
    ParamByName('YearMin').AsInteger:=SpinEdit5.Value;
    ParamByName('YearMax').AsInteger:=SpinEdit6.Value;
    Open;
   end;

    k:=0;
    while not odbdm.ib1q2.Eof do begin
      inc(k);
      VN:=odbdm.ib1q2.FieldByName('VN').AsString;
      count_VN:=odbdm.ib1q2.FieldByName('count_VN').AsInteger;
        writeln(f_dat, k, #9, count_VN, #9, VN );
     odbdm.ib1q2.Next;
    end;
     odbdm.ib1q2.Close;
CloseFile(f_dat);      }

//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
memo1.Lines.Add(PathStatistics+'\Vessel.dat');
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

TabControl1.Tabs.Add('Vessel');
tabBarVertical.TabVisible:=true;
TabControl1.OnChange(Self);
Application.ProcessMessages;
end;


procedure Tfrmosstatistics.InstrumentBar;
var
k,count_VN, VN:integer;
IType, instr, source1:string;
StartTime:TDateTime;
begin
StartTime:=Now;
AssignFile(f_dat,PathStatistics+'\Instrument.dat'); rewrite(f_dat);
writeln(f_dat, 'Instrument'+#9+'Stations');

memo1.Lines.Add('STATION DISTRIBUTION BY INSTRUMENT:');

{   with odbdm.ib1q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select Instrument as VN, count(Instrument) as count_VN ');
    SQL.Add(' from Station, Station_info where ');
    SQL.Add(' Station.absnum=Station_info.absnum and ' );
    SQL.Add(' StLat between :LatMin and  :LatMax and ' );
    SQL.Add(' StLon between :LonMin and  :LonMax and ' );
    SQL.Add(' Extract(Day from StDate) between :DayMin and :DayMax and ' );
    SQL.Add(' Extract(Month from StDate) between :MonthMin and :MonthMax and ' );
    SQL.Add(' Extract(Year from StDate) between :YearMin and :YearMax ' );
    if rgQC.ItemIndex=1 then SQL.Add(' and StFlag<16384 ');

    instr:='';
    for k:=0 to chkInstrument.Items.Count-1 do
     if chkInstrument.Checked[k]=true then if instr='' then instr:=inttostr(k) else instr:=instr+','+inttostr(k);
    SQL.Add(' and INSTRUMENT in ('+instr+')');

      source1:='';
       for k:=0 to clbsources.Items.Count-1 do
        if clbsources.Checked[k]=true then if source1='' then source1:=QuotedStr(clbsources.Items.strings[k]) else
        source1:=source1+','+QuotedStr(clbsources.Items.strings[k]);
      SQL.Add(' and StSource in ('+source1+')');

    SQL.Add(' group by Instrument ' );

    ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
    ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
    ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
    ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
    ParamByName('DayMin'  ).AsInteger:=SpinEdit1.Value;
    ParamByName('DayMax'  ).AsInteger:=SpinEdit2.Value;
    ParamByName('MonthMin').AsInteger:=SpinEdit3.Value;
    ParamByName('MonthMax').AsInteger:=SpinEdit4.Value;
    ParamByName('YearMin' ).AsInteger:=SpinEdit5.Value;
    ParamByName('YearMax' ).AsInteger:=SpinEdit6.Value;
    Open;
   end;

    k:=0;
    while not odbdm.ib1q2.Eof do begin
      inc(k);
      VN:=odbdm.ib1q2.FieldByName('VN').AsInteger;
      count_VN:=odbdm.ib1q2.FieldByName('count_VN').AsInteger;
       IType:='';
        Case VN of
         0:  Itype:='UNKNOWN';
         1:  Itype:='MBT';
         2:  Itype:='XBT';
         3:  Itype:='DBT';
         4:  Itype:='CTD';
         5:  Itype:='STD';
         6:  Itype:='XCTD';
         7:  Itype:='Bottle';
         8:  Itype:='Underway';
         9:  Itype:='Profiling float';
         10: Itype:='Moored buoy';
         11: Itype:='Drifting buoy';
         12: Itype:='Towed CTD';
         13: Itype:='Animal mounted';
         14: Itype:='Bucket';
         15: Itype:='Glider';
         16: Itype:='mBT';
        end;

        writeln(f_dat, k, #9, count_VN, #9, IType );
     odbdm.ib1q2.Next;
    end;
     odbdm.ib1q2.Close;
CloseFile(f_dat);     }

//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
memo1.Lines.Add(PathStatistics+'\Instrument.dat');
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

TabControl1.Tabs.Add('Instrument');
tabBarVertical.TabVisible:=true;
TabControl1.OnChange(Self);
Application.ProcessMessages;
end;


procedure Tfrmosstatistics.CountryBar;
var
k, Count_CN:integer;
CN, instr, source1:string;
StartTime:TDateTime;
begin
StartTime:=Now;
AssignFile(f_dat,PathStatistics+'\Country.dat'); rewrite(f_dat);
writeln(f_dat, 'Country'+#9+'Stations');

memo1.Lines.Add('STATION DISTRIBUTION BY COUNTRY:');

{ with odbdm.ib1q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select StCountryName as CN, count(StCountryName) as count_CN ');
    SQL.Add(' from Station, Station_info where ');
    SQL.Add(' Station.absnum=Station_info.absnum and ' );
    SQL.Add(' StLat between :LatMin and  :LatMax and ' );
    SQL.Add(' StLon between :LonMin and  :LonMax and ' );
    SQL.Add(' Extract(Day from StDate) between :DayMin and :DayMax and ' );
    SQL.Add(' Extract(Month from StDate) between :MonthMin and :MonthMax and ' );
    SQL.Add(' Extract(Year from StDate) between :YearMin and :YearMax ' );
    if rgQC.ItemIndex=1 then SQL.Add(' and StFlag<16384 ');

    instr:='';
    for k:=0 to chkInstrument.Items.Count-1 do
     if chkInstrument.Checked[k]=true then if instr='' then instr:=inttostr(k) else instr:=instr+','+inttostr(k);
    SQL.Add(' and INSTRUMENT in ('+instr+')');

      source1:='';
       for k:=0 to clbsources.Items.Count-1 do
        if clbsources.Checked[k]=true then if source1='' then source1:=QuotedStr(clbsources.Items.strings[k]) else
        source1:=source1+','+QuotedStr(clbsources.Items.strings[k]);
      SQL.Add(' and StSource in ('+source1+')');

    SQL.Add(' group by StCountryName ' );

    ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
    ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
    ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
    ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
    ParamByName('DayMin').AsInteger:=SpinEdit1.Value;
    ParamByName('DayMax').AsInteger:=SpinEdit2.Value;
    ParamByName('MonthMin').AsInteger:=SpinEdit3.Value;
    ParamByName('MonthMax').AsInteger:=SpinEdit4.Value;
    ParamByName('YearMin').AsInteger:=SpinEdit5.Value;
    ParamByName('YearMax').AsInteger:=SpinEdit6.Value;
    Open;
   end;

    k:=0;
    while not odbdm.ib1q2.Eof do begin
      inc(k);
     CN:=odbdm.ib1q2.FieldByName('CN').AsString;
     count_CN:=odbdm.ib1q2.FieldByName('count_CN').AsInteger;
       writeln(f_dat,k, #9, count_CN, #9, CN);
     odbdm.ib1q2.Next;
    end;
odbdm.ib1q2.Close;
CloseFile(f_dat); }

//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
memo1.Lines.Add(PathStatistics+'\Country.dat');
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

TabControl1.Tabs.Add('Country');
TabControl1.OnChange(Self);
tabBarVertical.TabVisible:=true;
Application.ProcessMessages;
end;


procedure Tfrmosstatistics.SourceBar;
var
k, count_SN:integer;
SN, instr, source1:string;
StartTime:TDateTime;
begin
StartTime:=Now;
AssignFile(f_dat,PathStatistics+'\Source.dat'); rewrite(f_dat);
writeln(f_dat, 'Source'+#9+'Stations');

memo1.Lines.Add('STATION DISTRIBUTION BY SOURCE:');

{ with odbdm.ib1q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select StSource as SN, count(StSource) as count_SN ');
    SQL.Add(' from Station, Station_info where ');
    SQL.Add(' Station.absnum=Station_info.absnum and ' );
    SQL.Add(' StLat between :LatMin and  :LatMax and ' );
    SQL.Add(' StLon between :LonMin and  :LonMax and ' );
    SQL.Add(' Extract(Day from StDate) between :DayMin and :DayMax and ' );
    SQL.Add(' Extract(Month from StDate) between :MonthMin and :MonthMax and ' );
    SQL.Add(' Extract(Year from StDate) between :YearMin and :YearMax ' );
    if rgQC.ItemIndex=1 then SQL.Add(' and StFlag<16384 ');

    instr:='';
    for k:=0 to chkInstrument.Items.Count-1 do
     if chkInstrument.Checked[k]=true then if instr='' then instr:=inttostr(k) else instr:=instr+','+inttostr(k);
    SQL.Add(' and INSTRUMENT in ('+instr+')');

      source1:='';
       for k:=0 to clbsources.Items.Count-1 do
        if clbsources.Checked[k]=true then if source1='' then source1:=QuotedStr(clbsources.Items.strings[k]) else
        source1:=source1+','+QuotedStr(clbsources.Items.strings[k]);
      SQL.Add(' and StSource in ('+source1+')');


    SQL.Add(' group by StSource ' );

    ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
    ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
    ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
    ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
    ParamByName('DayMin').AsInteger:=SpinEdit1.Value;
    ParamByName('DayMax').AsInteger:=SpinEdit2.Value;
    ParamByName('MonthMin').AsInteger:=SpinEdit3.Value;
    ParamByName('MonthMax').AsInteger:=SpinEdit4.Value;
    ParamByName('YearMin').AsInteger:=SpinEdit5.Value;
    ParamByName('YearMax').AsInteger:=SpinEdit6.Value;
    Open;
   end;

    k:=0;
    while not odbdm.ib1q2.Eof do begin
      inc(k);
     SN:=odbdm.ib1q2.FieldByName('SN').AsString;
     count_SN:=odbdm.ib1q2.FieldByName('count_SN').AsInteger;
        writeln(f_dat,k, #9, count_SN, #9, SN);
     odbdm.ib1q2.Next;
    end;
    odbdm.ib1q2.Close;
CloseFile(f_dat);   }

//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
memo1.Lines.Add(PathStatistics+'\Source.dat');
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

TabControl1.Tabs.Add('Source');
TabControl1.OnChange(Self);
tabBarVertical.TabVisible:=true;
Application.ProcessMessages;
end;


procedure Tfrmosstatistics.Standardchartsettings1Click(Sender: TObject);
begin
 //CE.Execute;
// UpdateStationMap;
end;

procedure Tfrmosstatistics.HorizontalBar;
var
k,k_lev,countPar,countLev,absnum:integer;
lev,Lev1,Lev2,Lev3,upLev,dwLev:real;
X,Y:real;
tblPar,ParName:string;
sdlev_arr:array[0..33] of real;
sdNum_arr:array[1..33] of integer;
StartTime:TDateTime;
begin
StartTime:=Now;
memo1.Lines.Add('MEASUREMENTS IN LAYERS:');

countLev:=0;
sdLev_arr[0]:=0;

  for k:=0 to Memo4.Lines.Count-1 do begin
    sdLev_arr[k+1]:=strtofloat(memo4.Lines.Strings[k]);
    countLev:=countLev+1;
  end;

  for k_lev:=1 to countLev-1 do begin
    Lev1:=sdLev_arr[k_lev-1];
    Lev2:=sdLev_arr[k_lev];
    Lev3:=sdLev_arr[k_lev+1];
    upLev:=Lev2-(Lev2-Lev1)/2;
    dwLev:=Lev2+(Lev3-Lev2)/2;
  end;

{    TabControl3.Tabs.Clear;
for k:=0 to frmmain.ListBox2.Items.Count-1 do begin
    tblPar:=frmmain.ListBox2.Items.Strings[k];

    for k_lev:=1 to countLev do sdNum_arr[k_lev]:=0;

    CountPar:=frmmain.ListBox2.Count;
    ParName:=copy(tblPar,3,length(tblPar));
    TabControl3.Tabs.Add(ParName);

    AssignFile(f_dat,PathStatistics+'\Layer_'+ParName+'.dat'); rewrite(f_dat);
    memo1.Lines.Add(PathStatistics+'\Layer_'+ParName+'.dat');

   with odbdm.ib1q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select * from ');
    SQL.Add(tblPar);
    SQL.Add(' where absnum=:absnum ');
    Prepare;
   end;

   if odbdm.ib1q1.Active=false then SelectAllFromStation;

    odbdm.ib1q1.First;
  while not odbdm.ib1q1.Eof do begin
    Absnum:=odbdm.ib1q1.FieldByName('Absnum').AsInteger;
   with odbdm.ib1q2 do begin
    ParamByName('absnum').AsInteger:=absnum;
    Open;
   end;
 if odbdm.ib1q2.IsEmpty= false then begin
 while not odbdm.ib1q2.Eof do begin
    Lev:=odbdm.ib1q2.FieldByName('Level_').AsFloat;
 for k_lev:=1 to countLev-1 do begin
    Lev1:=sdLev_arr[k_lev-1];
    Lev2:=sdLev_arr[k_lev];
    Lev3:=sdLev_arr[k_lev+1];
    upLev:=Lev2-(Lev2-Lev1)/2;
    dwLev:=Lev2+(Lev3-Lev2)/2;
    if (Lev>=upLev) and (Lev<dwLev) then
    sdNum_arr[k_lev]:=sdNum_arr[k_lev]+1;
 end;
    odbdm.ib1q2.Next;
 end;
 end;
    odbdm.ib1q2.Close;
    odbdm.ib1q1.Next;
 end;

   for k_lev:=1 to countLev do begin
     if (sdNum_arr[k_lev]>0) then begin
        x:=sdLev_arr[k_lev];
        y:=sdNum_arr[k_lev];
           writeln(f_dat,x:7:0,y:8:0);
     end;
   end;
    closefile(f_dat);
end;              }

//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

tabBarHorisontal.TabVisible:=true;
TabControl3.OnChange(Self);
Application.ProcessMessages;
end;


procedure Tfrmosstatistics.DayTimeDiagram;
var
k_month,DayCount,absnum:integer;
DateCurrent:real;
YearSt,MonthSt,DaySt,HourSt,MinSt,SecSt,mSecSt:word;
StDate,StTime:TDateTime;
StartTime:TDateTime;
begin
StartTime:=Now;
AssignFile(f_dat,PathStatistics+'\TimeDayDiagram.dat'); rewrite(f_dat);
{try
writeln(f_dat, 'Current date', #9, 'Days count');

memo1.Lines.Add('TIME DAY DIAGRAM:');

 //if odbdm.ib1q1.Active=false then SelectAllFromStation;

   odbdm.ib1q1.First;
  while not odbdm.ib1q1.Eof do begin
    Absnum:=odbdm.ib1q1.FieldByName('Absnum').AsInteger;
    StDate:=odbdm.ib1q1.FieldByName('StDate').AsDateTime;
    StTime:=odbdm.ib1q1.FieldByName('StTime').AsDateTime;

    DecodeDate(StDate,YearSt,MonthSt,DaySt);
    DecodeTime(StTime,HourSt,MinSt,SecSt,mSecSt);

    DayCount:=0;
    DateCurrent:=0;
    for k_month:=1 to MonthSt-1 do DayCount:=DayCount+DaysInaMonth(YearSt,k_month);
    DayCount:=DayCount+DaySt;
    DateCurrent:=DayCount+HourSt/24+MinSt/60/24;
    DateCurrent:=YearSt+DateCurrent/365;

    writeln(f_dat, FloatToStrF(DateCurrent, fffixed,15,5), #9, DayCount);

    odbdm.ib1q1.Next;
  end;
finally
 Closefile(f_dat);
end;     }


//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
memo1.Lines.Add(PathStatistics+'\TimeDayDiagram.dat');
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

tabBarPoints.TabVisible:=true;
TabControl2.OnChange(Self);
Application.ProcessMessages;
end;


procedure Tfrmosstatistics.YearBySources;
var
ky, Count, k:integer;
YearMin, YearMax:integer;
StartTime:TDateTime;
instr, source1:string;
begin
StartTime:=Now;
AssignFile(f_dat,PathStatistics+'\YearBySources.dat'); rewrite(f_dat);
Write(f_dat, 'Year');
memo1.Lines.Add('STATIONS IN YEAR BY SOURCES:');

 { with odbdm.ib1q2 do begin
    Close;
      SQL.Clear;
      SQL.Add(' select distinct(stsource) from Station ');
      SQL.Add(' where ');
      SQL.Add(' StLat between :LatMin and  :LatMax and ' );
      SQL.Add(' StLon between :LonMin and  :LonMax and ' );
      SQL.Add(' Extract(Year from StDate)  between :YearMin  and :YearMax ' );

      ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
      ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
      ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
      ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
      ParamByName('YearMin').AsInteger:=SpinEdit5.Value;
      ParamByName('YearMax').AsInteger:=SpinEdit6.Value;
    Open;
   end;

   Count:=0;
   While not odbdm.ib1q2.eof do begin
     inc(Count);
       Write(f_dat, #9, odbdm.ib1q2.Fields[0].AsString);
     odbdm.ib1q2.Next;
   end;
   writeln(f_dat);
   
   with odbdm.ib1q3 do begin
    Close;
      SQL.Clear;
      SQL.Add(' select station.absnum from station, station_info ');
      SQL.Add(' where ');
      SQL.Add(' Station.absnum=Station_info.absnum and ' );
      SQL.Add(' StLat between :LatMin and  :LatMax and ' );
      SQL.Add(' StLon between :LonMin and  :LonMax and ' );
      SQL.Add(' Extract(Year from StDate)=:CurrentYear ' );
      SQL.Add(' and stSource=:CurrentSource ');
      if rgQC.ItemIndex=1 then SQL.Add(' and StFlag<16384 ');

      instr:='';
      for k:=0 to chkInstrument.Items.Count-1 do
       if chkInstrument.Checked[k]=true then if instr='' then instr:=inttostr(k) else instr:=instr+','+inttostr(k);
      SQL.Add(' and INSTRUMENT in ('+instr+')');

      source1:='';
       for k:=0 to clbsources.Items.Count-1 do
        if clbsources.Checked[k]=true then if source1='' then source1:=QuotedStr(clbsources.Items.strings[k]) else
        source1:=source1+','+QuotedStr(clbsources.Items.strings[k]);
      SQL.Add(' and StSource in ('+source1+')');

    Prepare;
   end;

   YearMin:=SpinEdit5.Value;
   YearMax:=SpinEdit6.Value;

  for ky:=YearMin to YearMax do begin
    write(f_dat, ky);

     odbdm.ib1q2.First;
   while not odbdm.ib1q2.Eof do begin
     with odbdm.ib1q3 do begin
       ParamByName('CurrentYear').AsInteger:=ky;
       ParamByName('CurrentSource').AsString:=odbdm.ib1q2.Fields[0].AsString;
       ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
       ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
       ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
       ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
      Open;
     end;

      Count:=0;
      while not odbdm.ib1q3.eof do begin
        inc(Count);
       odbdm.ib1q3.next;
      end;
      odbdm.ib1q3.close;
    write(f_dat, #9, Count);
   odbdm.ib1q2.Next;
  end;
   writeln(f_dat);
  end;
CloseFile(f_dat);
odbdm.ib1q2.Close;
odbdm.ib1q3.UnPrepare;      }

memo1.Lines.Add(PathStatistics+'\YearBySources.dat');
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
Application.ProcessMessages;
end;


(* Станции по годам и по странам *)
procedure Tfrmosstatistics.YearByCountries;
var
ky, Count, k:integer;
YearMin, YearMax:integer;
StartTime:TDateTime;
instr, source1:string;
begin
StartTime:=Now;
AssignFile(f_dat,PathStatistics+'\YearByCountries.dat'); rewrite(f_dat);
Write(f_dat, 'Year');
memo1.Lines.Add('STATIONS IN YEAR BY COUNTRIES:');

 { with odbdm.ib1q2 do begin
    Close;
      SQL.Clear;
      SQL.Add(' select distinct(stcountryname) from Station ');
      SQL.Add(' where ');
      SQL.Add(' StLat between :LatMin and  :LatMax and ' );
      SQL.Add(' StLon between :LonMin and  :LonMax and ' );
      SQL.Add(' Extract(Year from StDate)  between :YearMin  and :YearMax ' );
      if rgQC.ItemIndex=1 then SQL.Add(' and StFlag<16384 ');
      ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
      ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
      ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
      ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
      ParamByName('YearMin').AsInteger:=SpinEdit5.Value;
      ParamByName('YearMax').AsInteger:=SpinEdit6.Value;
    Open;
   end;

   Count:=0;
   While not odbdm.ib1q2.eof do begin
     inc(Count);
       Write(f_dat, #9, odbdm.ib1q2.Fields[0].AsString);
     odbdm.ib1q2.Next;
   end;
   writeln(f_dat);

   with odbdm.ib1q3 do begin
    Close;
      SQL.Clear;
      SQL.Add(' select station.absnum from station, station_info ');
      SQL.Add(' where Station.absnum=Station_info.absnum and ');
      SQL.Add(' StLat between :LatMin and  :LatMax and ' );
      SQL.Add(' StLon between :LonMin and  :LonMax and ' );
      SQL.Add(' Extract(Year from StDate)=:CurrentYear ' );
      SQL.Add(' and stCountryname=:CurrentCountry ');
      if rgQC.ItemIndex=1 then SQL.Add(' and StFlag<16384 ');

      instr:='';
      for k:=0 to chkInstrument.Items.Count-1 do
       if chkInstrument.Checked[k]=true then if instr='' then instr:=inttostr(k) else instr:=instr+','+inttostr(k);
      SQL.Add(' and INSTRUMENT in ('+instr+')');

      source1:='';
       for k:=0 to clbsources.Items.Count-1 do
        if clbsources.Checked[k]=true then if source1='' then source1:=QuotedStr(clbsources.Items.strings[k]) else
        source1:=source1+','+QuotedStr(clbsources.Items.strings[k]);
      SQL.Add(' and StSource in ('+source1+')');

    Prepare;
   end;

   YearMin:=SpinEdit5.Value;
   YearMax:=SpinEdit6.Value;

  for ky:=YearMin to YearMax do begin
    write(f_dat, ky);

     odbdm.ib1q2.First;
   while not odbdm.ib1q2.Eof do begin
     with odbdm.ib1q3 do begin
       ParamByName('CurrentYear').AsInteger:=ky;
       ParamByName('CurrentCountry').AsString:=odbdm.ib1q2.Fields[0].AsString;
       ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
       ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
       ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
       ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
      Open;
     end;

      Count:=0;
      while not odbdm.ib1q3.eof do begin
        inc(Count);
       odbdm.ib1q3.next;
      end;
      odbdm.ib1q3.close;
    write(f_dat, #9, Count);
   odbdm.ib1q2.Next;
  end;
   writeln(f_dat);
  end;
CloseFile(f_dat);
odbdm.ib1q2.Close;
odbdm.ib1q3.UnPrepare;    }

memo1.Lines.Add(PathStatistics+'\YearByCountries.dat');
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
Application.ProcessMessages;
end;



(*Stations on map *)
procedure Tfrmosstatistics.AllStationsMap;
Var
k:integer;
lon, lat:real;
StartTime:TDateTime;
instr, source1:string;
begin
StartTime:=Now;

AssignFile(f_dat,PathStatistics+'\StationsMap.dat'); rewrite(f_dat);
writeln(f_dat, 'Latitude':15, 'Longitude':15 );
 memo1.Lines.Add('STATIONS MAP:');

 {  With odbdm.ib1q2 do begin
    Close;
      SQL.clear;
      SQL.Add(' Select StLat, StLon from Station, Station_info where ');
      SQL.Add(' Station.absnum=Station_info.absnum and ' );
      SQL.Add(' StLat between :LatMin and  :LatMax and ' );
      SQL.Add(' StLon between :LonMin and  :LonMax and ' );
      SQL.Add(' Extract(Day from StDate) between :DayMin and :DayMax and ' );
      SQL.Add(' Extract(Month from StDate) between :MonthMin and :MonthMax and ' );
      SQL.Add(' Extract(Year from StDate) between :YearMin and :YearMax ' );
      if rgQC.ItemIndex=1 then SQL.Add(' and StFlag<16384 ');

       instr:='';
       for k:=0 to chkInstrument.Items.Count-1 do
        if chkInstrument.Checked[k]=true then if instr='' then instr:=inttostr(k) else instr:=instr+','+inttostr(k);
      SQL.Add(' and INSTRUMENT in ('+instr+')');

      source1:='';
       for k:=0 to clbsources.Items.Count-1 do
        if clbsources.Checked[k]=true then if source1='' then source1:=QuotedStr(clbsources.Items.strings[k]) else
        source1:=source1+','+QuotedStr(clbsources.Items.strings[k]);
      SQL.Add(' and StSource in ('+source1+')');

      SQL.Add(' Order by StLat, StLon ');

      ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
      ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
      ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
      ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
      ParamByName('DayMin'  ).AsInteger:=SpinEdit1.Value;
      ParamByName('DayMax'  ).AsInteger:=SpinEdit2.Value;
      ParamByName('MonthMin').AsInteger:=SpinEdit3.Value;
      ParamByName('MonthMax').AsInteger:=SpinEdit4.Value;
      ParamByName('YearMin' ).AsInteger:=SpinEdit5.Value;
      ParamByName('YearMax' ).AsInteger:=SpinEdit6.Value;
    Open;
   end;

  While not odbdm.ib1q2.Eof do begin
   lon:=odbdm.ib1q2.FieldByName('StLon').AsFloat;
   lat:=odbdm.ib1q2.FieldByName('StLat').AsFloat;
     writeln(f_dat, lat:15:5, lon:15:5);
   odbdm.ib1q2.Next;
  end;
 odbdm.ib1q2.Close;
 CloseFile(f_dat); }

//frmmain.ProgressBar1.Position:=frmmain.ProgressBar1.Position+1;
memo1.Lines.Add(PathStatistics+'\StationsMap.dat');
memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');

//tabMap.TabVisible:=true;
Application.ProcessMessages;

//UpdateStationMap; // Набрасываем данные на карту
end;


(*Stations on map by year*)
procedure Tfrmosstatistics.AllStationsMapByYear;
Var
Ini:TIniFile;
k, yy, fl, Projection:integer;
lon, lat:real;
StartTime, DateB, DateE:TDateTime;
instr, source1:string;
begin
StartTime:=Now;

Ini := TIniFile.Create(IniFileName);
 try
  Projection:= Ini.ReadInteger ( 'Map',  'Projection', 0);
 finally
   Ini.Free;
 end;
//ChartSettings;
{
WindowState:=wsMaximized;
Application.ProcessMessages;

memo1.Lines.Add('STATIONS MAP BY YEAR:');
 For yy:=SpinEdit5.Value to SpinEdit6.Value do begin
  AssignFile(f_dat,PathStatistics+'\StationsMap_'+inttostr(yy)+'.dat'); rewrite(f_dat);
  writeln(f_dat, 'Lat', #9, 'Lon' );
   DateB:=EncodeDate(yy, SpinEdit3.Value, SpinEdit1.Value);
   DateE:=EncodeDate(yy, SpinEdit4.Value, SpinEdit2.Value);

   With odbdm.ib1q2 do begin
    Close;
      SQL.clear;
      SQL.Add(' Select StLat, StLon, StFlag from Station, Station_info where ');
      SQL.Add(' Station.absnum=Station_info.absnum and ' );
      SQL.Add(' StLat between :LatMin and  :LatMax and ' );
      SQL.Add(' StLon between :LonMin and  :LonMax and ' );
      SQL.Add(' StDate between :DMin and :DMax ' );

      instr:='';
      for k:=0 to chkInstrument.Items.Count-1 do
       if chkInstrument.Checked[k]=true then if instr='' then instr:=inttostr(k) else instr:=instr+','+inttostr(k);
      SQL.Add(' and INSTRUMENT in ('+instr+')');

      source1:='';
       for k:=0 to clbsources.Items.Count-1 do
        if clbsources.Checked[k]=true then if source1='' then source1:=QuotedStr(clbsources.Items.strings[k]) else
        source1:=source1+','+QuotedStr(clbsources.Items.strings[k]);
      SQL.Add(' and StSource in ('+source1+')');

      SQL.Add(' Order by StLat, StLon ');

      ParamByName('LatMin').AsFloat:=strtofloat(Edit1.Text);
      ParamByName('LatMax').AsFloat:=strtofloat(Edit2.Text);
      ParamByName('LonMin').AsFloat:=strtofloat(Edit3.Text);
      ParamByName('LonMax').AsFloat:=strtofloat(Edit4.Text);
      ParamByName('DMin'  ).AsDateTime:=DateB;
      ParamByName('DMax'  ).AsDateTime:=DateE;
    Open;
   end;

   if not odbdm.ib1q2.IsEmpty then begin
   //  PointSeries1.Clear;
  //   PointSeries4.Clear;
     k:=0;
      While not odbdm.ib1q2.Eof do begin
        inc(k);
         lon:=odbdm.ib1q2.FieldByName('StLon').AsFloat;
         lat:=odbdm.ib1q2.FieldByName('StLat').AsFloat;
         fl :=odbdm.ib1q2.FieldByName('StFlag').AsInteger;

          if Projection=1 then begin
           Lon:=2*6388.015*sin(Pi/4-lat/2*Pi/180)*Sin(Pi/180*lon)/10;
           Lat:=-2*6388.015*sin(Pi/4-lat/2*Pi/180)*Cos(Pi/180*lon)/10;
          end;

      //  if fl>=16384 then PointSeries4.AddXY(Lon, Lat) else PointSeries1.AddXY(Lon, Lat);
        writeln(f_dat, FloattostrF(lon,ffGeneral,10,5), #9, FloattostrF(lon,ffGeneral,10,5));

       odbdm.ib1q2.Next;
     end;
     odbdm.ib1q2.Close;
     CloseFile(f_dat);

   //  DBChart1.Title.Caption:=IntToStr(yy)+', '+Inttostr(k)+' stations';
  //   DBChart1.SaveToBitmapFile(PathStatistics+'\StationsMap_'+inttostr(yy)+'.bmp');
     memo1.Lines.Add(PathStatistics+'\StationsMap_'+inttostr(yy)+'.bmp');
       if not tabMap.TabVisible then begin
        tabMap.TabVisible:=true;
        PageControl1.ActivePageIndex:=4;
       end; // else DBChart1.Repaint;
   end;
 end;

memo1.Lines.Add('Spent: '+TimeToStr(Now-StartTime));
memo1.Lines.Add('===');
memo1.Lines.Add('');
WindowState:=wsNormal;
Application.ProcessMessages;    }
end;


procedure Tfrmosstatistics.btnSaveMapClick(Sender: TObject);
begin
//frmmain.SD.DefaultExt:='bmp';
//if frmmain.SD.Execute then
 //  DBChart1.SaveToBitmapFile(frmmain.SaveDialog1.FileName);
end;

procedure Tfrmosstatistics.btnCopyToClipClick(Sender: TObject);
begin
 //DBChart1.CopyToClipboardBitmap;
end;
(*End of Stations on map *)


procedure Tfrmosstatistics.TabControl1Change(Sender: TObject);
var
x,y:integer;
z,st, FilePath:string;
begin
memo2.Clear;
memo2.Visible:=false;
Splitter1.Align:=alNone;

FilePath:=PathStatistics+'\'+TabControl1.Tabs[TabControl1.TabIndex]+'.dat';
AssignFile(f_dat,FilePath); reset(f_dat);
readln(f_dat, st);

  {Chart1.Series[0].Clear;
   while not EOF(f_dat) do begin
     readln(f_dat, x, y, z);
       if z<>' ' then begin
          memo2.Lines.Add(inttostr(x)+' '+z);
          memo2.Visible:=true;
          Splitter1.Align:=alRight;
       end;
    Chart1.Series[0].AddXY(x, y);
   end;  }
CloseFile(f_dat);
end;


procedure Tfrmosstatistics.TabControl3Change(Sender: TObject);
var
ParName, FilePath:string;
X,Y:real;
begin
ParName:=TabControl3.Tabs.Strings[TabControl3.TabIndex];
FilePath:=concat(PathStatistics,'\Layer_',ParName,'.dat');
AssignFile(f_dat,FilePath); Reset(f_dat);

 {Series3.Clear;
  while not EOF(f_dat) do begin
    readln(f_dat,X,Y);
   Series3.AddXY(Y,X,'',clRed);
  end;  }
CloseFile(f_dat);
end;


procedure Tfrmosstatistics.TabControl2Change(Sender: TObject);
var
daycount:integer;
datecurrent:real;
st, FilePath:string;
begin
//Series2.Clear;
 FilePath:=concat(PathStatistics,'\TimeDayDiagram.dat');
 AssignFile(f_dat,FilePath); reset(f_dat);
 readln(f_dat, st);
   while not EOF(f_dat) do begin
     readln(f_dat, datecurrent, daycount);
  //  Series2.AddBubble(DateCurrent,DayCount,2,'',clRed);
   end;
CloseFile(f_dat);
end;



// if odbdm.ib1q1.Active=true then odbdm.ib1q1.Close;

end.

