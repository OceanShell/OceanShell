unit ostimedepthdiagram;

{$mode objfpc}{$H+}

interface

uses  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      StdCtrls, ExtCtrls, BufDataset, IniFiles, DB, Dialogs, DateUtils, Buttons, Spin,
      ComCtrls, Math;

type
  Tfrmtimedepthdiagram = class(TForm)
    btnPlot: TButton;
    rgParameters: TGroupBox;
    Label3: TLabel;
    Label5: TLabel;
    cbParameters: TComboBox;
    cbLvl: TComboBox;
    seX: TSpinEdit;
    seY: TSpinEdit;
    rgDataFile: TRadioGroup;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label6: TLabel;
    SEYY1: TSpinEdit;
    SEYY2: TSpinEdit;
    btnGetData: TButton;
    mLog: TMemo;
    lbMonthlyLevels: TListBox;
    Memo1: TMemo;
    btnSettings: TButton;
    btnOpenFolder: TBitBtn;
    btnOpenScript: TBitBtn;

    procedure btnPlotClick(Sender: TObject);
    procedure cbParametersChange(Sender: TObject);
    procedure TimeSeriesAtLevels;
    procedure TimeSeriesAtLevels_Prf;
    procedure rgDataFileClick(Sender: TObject);
    procedure cbParametersSelect(Sender: TObject);
 //   procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnGetDataClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnOpenFolderClick(Sender: TObject);
    procedure btnOpenScriptClick(Sender: TObject);


  private
    procedure MeanByMonth;
    procedure MeanByYear;
    procedure MonthsDifference;
    procedure GetScriptSmooth;

  public
    { Public declarations }
  end;

var
  frmtimedepthdiagram: Tfrmtimedepthdiagram;
  Script, dat, dat1, dat_r, dat_i, dat_m, dat_Month, dat_bln, dat_sdlev, dat_SdLevPRF:text;
  TDDCDS, MCDS, cdsMeanPrf,cdsTTDMonth,cdsLastLevBln,cdsSdLev:TBufDataSet;
  numcol,CountGap:integer;
  Koef, dif, kf_int,kf_real,StartDate:real;
  TDDPath, CurrentFile:string;
  MinDate:TDateTime;
  isNew:boolean=true;

implementation

uses osmain, dm, procedures, surfer_settings;

{$R *.lfm}


procedure Tfrmtimedepthdiagram.FormShow(Sender: TObject);
Var
 flist:TSearchRec;
begin
  memo1.Clear;
  mLog.clear;

 (* Устанавливаем пути *)
 TDDPath:=GlobalPath+'unload\tddiagrams\'+ExtractFileName(IBName)+'\'; // в папку с именем базы
 if not DirectoryExists(GlobalPath+'unload\tddiagrams\') then CreateDir(GlobalPath+'unload\tddiagrams\');
 if not DirectoryExists(TDDPath) then CreateDir(TDDPath);
 if not DirectoryExists(TDDPath+'MonthlyProfiles\') then CreateDir(TDDPath+'MonthlyProfiles\');
 if not DirectoryExists(TDDPath+'SeriesAtSdLevelsInitialPrf\') then CreateDir(TDDPath+'SeriesAtSdLevelsInitialPrf\');
 if not DirectoryExists(TDDPath+'SeriesAtSdLevelsMonthlyMean\') then CreateDir(TDDPath+'SeriesAtSdLevelsMonthlyMean\');

 (* загружаем список *.lvl файлов *)
 cbLvl.Clear;
 cbLvl.Items.Add('');
 flist.Name:='';
  FindFirst(GlobalPath+'support\lvl\'+'*.lvl',faAnyFile, flist);
   if flist.Name<>'' then cbLvl.Items.Add(flist.Name);
  while findnext(flist)=0 do cbLvl.Items.Add(flist.Name);
 if cbLvl.Items.Count=0 then cbLvl.Enabled:=false;
 FindClose(flist);

 seYY1.Text:=Copy(frmosmain.sbselection.Panels[5].Text, 7, 4);
 seYY2.Text:=Copy(frmosmain.sbselection.Panels[6].Text, 7, 4);

 rgParameters.Enabled:=false;
 rgDataFile.Enabled:=false;
end;


procedure Tfrmtimedepthdiagram.btnGetDataClick(Sender: TObject);
var
Ini:TIniFile;
mik,mik_lev:integer;
StDateTime, D1,D2, T1, T2,dmin,dmax, TimeStart:TDateTime;
Year, month, day, hour, min, sec, msec:word;
ymin,ymax,y,m,n,sdlev,dsum,dyear:integer;
absnum, k, TFl,SFl,l, i, c, fi, IntLev:integer;
Enable, FlagIsSet, st_ex:boolean;
TransLev,  year_m,  MaxDate,  MaxDepth,TimeTR,x1,x2:real;
an,anSCR,valSCR,ULev,DLev,st_time,st_timeTR, time1:real;
SVan,Lev, TVal, SVal, StLat, pres, DVal, IntVal,lmin,lmax,x:real;
P, D, N2:array[1..10000] of real;
Mean, Val, anom:real;
st,str,buf_str:string;

CountStep,ky:integer;
Ystep,YBeg,Yend,Y1,Y2,ULevMin,DLevMax :real;

yb,mb,db,ye,me,de:word;
date1,date2,dateb,datee:TDateTime;
begin
 btnGetData.Enabled:=false;

 mLog.Clear;
 mLog.lines.add('Start: '+TimetoStr(Now));
 TimeStart:=Now;

 (* Читаем настройки из файла *)
 try
   Ini := TIniFile.Create(IniFileName);
    Ini.ReadSection('Standart levels', memo1.Lines);
  finally
   Ini.Free;
  end;


  frmdm.Q.IndexFieldNames:='dateandtime'; //force sorting

  // creading client datasets
  TDDCDS:=TBufDataSet.Create(nil);
   with TDDCDS.FieldDefs do begin
      Add('absnum' ,ftInteger  ,0 ,false);
      Add('date'   ,ftDateTime ,0 ,false);
      Add('time'   ,ftDateTime ,0 ,false);
      Add('year'   ,ftInteger  ,0 ,false);
      Add('month'  ,ftInteger  ,0 ,false);
      Add('day'    ,ftInteger  ,0 ,false);
      Add('hour'   ,ftInteger  ,0 ,false);
      Add('min'    ,ftInteger  ,0 ,false);
      Add('lev'    ,ftInteger  ,0 ,false);
      Add('val'    ,ftFloat    ,0 ,false);
      Add('anom'   ,ftFloat    ,0 ,false);
   end;
  TDDCDS.CreateDataSet;
//  TDDCDS.LogChanges:=false;

  cdsMeanPrf:=TBufDataSet.Create(nil);
   with cdsMeanPrf.FieldDefs do begin
      Add('lev'    ,ftInteger ,0 ,false);
      Add('n'      ,ftInteger ,0 ,false);
      Add('val'    ,ftFloat   ,0 ,false);
      Add('valSCR' ,ftFloat   ,0 ,false);
   end;
  cdsMeanPrf.CreateDataSet;
//  cdsMeanPrf.LogChanges:=false;

  cdsTTDMonth:=TBufDataSet.Create(nil);
   with cdsTTDMonth.FieldDefs do begin
      Add('timeTR' ,ftInteger ,0 ,false);
      Add('sdlev'  ,ftInteger ,0 ,false);
      Add('time'   ,ftFloat   ,0 ,false);
      Add('val'    ,ftFloat   ,0 ,false);
      Add('valSCR' ,ftFloat   ,0 ,false);
      Add('an'     ,ftFloat   ,0 ,false);
      Add('anSCR'  ,ftFloat   ,0 ,false);
      Add('n'      ,ftInteger ,0 ,false);
   end;
  cdsTTDMonth.CreateDataSet;
 // cdsTTDMonth.LogChanges:=false;


    cdsLastLevBln:=TBufDataSet.Create(nil);
   with cdsLastLevBln.FieldDefs do begin
    Add('time',ftFloat,0,true);
    Add('timeTR',ftFloat,0,true);
    Add('ULev',ftFloat,0,true);
    Add('DLev',ftFloat,0,true);
   end;
    cdsLastLevBln.CreateDataSet;
  //  cdsLastLevBln.LogChanges:=false;


// Assigning output files
AssignFile(dat_r,     TDDPath+'Real.dat');  Rewrite(dat_r);     // real data
AssignFile(dat_i,     TDDPath+'StLev.dat'); Rewrite(dat_i);     // interpolated onto st. levels
AssignFile(dat_month, TDDPath+'Month.dat'); Rewrite(dat_month); // monthly averaged
AssignFile(dat_bln,   TDDPath+'Month.bln'); Rewrite(dat_bln);   // blank file

writeln(dat_r,    'Date':15, 'lev':10, 'val':10, 'absnum':10, 'date':15, 'time':15);
writeln(dat_i,    'Date':15, 'lev':10, 'val':10, 'absnum':10, 'date':15, 'time':15, 'anomaly':10);
writeln(dat_month,'Date':15, 'lev':10, 'val':15, 'valSCR':15, 'anom':15, 'anSCR':15, 'n':8);

frmdm.Q.DisableControls;
frmdm.Q.First;
D2:=frmdm.Q.FieldByName('StDate').AsDateTime;
T2:=frmdm.Q.FieldByName('StTime').AsDateTime;
frmdm.Q.Last;
D1:=frmdm.Q.FieldByName('StDate').AsDateTime;
T1:=frmdm.Q.FieldByName('StTime').AsDateTime;

MaxDepth:=frmdm.Q.FieldValues['LevelMax'];

DecodeDate(D1, Year, month, day);
DecodeTime(T1,hour,min,sec,msec);
MaxDate:=Year+(month-1)/12+day/365+hour/(24*365)+min/(3600*365);
DecodeDate(D2, Year, month, day);
DecodeTime(T2,hour,min,sec,msec);
MinDate:=Year+(month-1)/12+day/365+hour/(24*365)+min/(3600*365);

 mLog.lines.add('Unloading data from database... ');
 Application.ProcessMessages;

 try
 //ODBDM.IBTransaction1.StartTransaction;
 frmdm.Q.First;
 while not frmdm.Q.Eof do begin //w
    absnum:=frmdm.Q.fieldByName('ID').Value;
    StDateTime:=frmdm.Q.fieldByName('DATEANDTIME').Value;
    StLat:=frmdm.Q.fieldByName('LATITUDE').Value;

    DecodeDateTime(Stdatetime, Year, month, day, hour, min, sec, msec);

    year_m:=year+(month-1)/12+
            day/DaysInAYear(year)+
            hour/(24*DaysInAYear(year))+
            min/(3600*DaysInAYear(year));


     // Обнуляем массивы
     for k:=1 to 10000 do begin
      D[k]:=0;
      P[k]:=0;
      N2[k]:=0;
     end;

 if (CurrentParTable<>'DENSITY') and (CurrentParTable<>'BUOYANCY') then begin  //p
  { with ODBDM.ib1q2 do begin
     Close;
       SQL.Clear;
       SQL.Add(' Select level_, value_, flag_ from ');
       SQL.Add(CurrentParTable);
       SQL.Add(' where absnum=:absnum ');
       SQL.Add(' order by level_ ');
       ParamByName('absnum').AsInteger:=absnum;
     Open;
   end;

    k:=0;
    while not ODBDM.ib1q2.eof do begin
     Lev :=ODBDM.ib1q2.FieldByName('level_').AsFloat;
     TVal:=ODBDM.ib1q2.FieldByName('value_').AsFloat;
     TFL :=ODBDM.ib1q2.FieldByName('flag_').AsInteger;

       FlagIsSet:=false;
    if TFL>0 then ProfilesSelection.FlagAnalysis(TFL,FlagIsSet);
      if FlagIsSet=false then begin
       inc(k);
         D[k]:=Lev;
         P[k]:=TVal;
     end;
    ODBDM.ib1q2.Next;
  end;      }
 end; //p


 if (CurrentParTable='DENSITY') or (CurrentParTable='BUOYANCY') then begin //d
//showmessage('...density');
  { with ODBDM.ib1q2 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select * ');
    SQL.Add(' from P_TEMPERATURE, P_SALINITY ');
    SQL.Add(' where P_TEMPERATURE.absnum=:absnum ');
    SQL.Add(' and P_TEMPERATURE.absnum=P_SALINITY.absnum ');
    SQL.Add(' and P_TEMPERATURE.Level_=P_SALINITY.Level_ ');
    SQL.Add(' order by P_TEMPERATURE.Level_ ');
    ParamByName('Absnum') .AsInteger:=Absnum;
    Open;
   end;
    k:=0;
    while not ODBDM.ib1q2.eof do begin
         Lev :=ODBDM.ib1q2.FieldByName('level_').AsFloat;
         TVal:=ODBDM.ib1q2.FieldByName('value_').AsFloat;
         TFL :=ODBDM.ib1q2.FieldByName('flag_').AsInteger;
         SVal:=ODBDM.ib1q2.FieldByName('value_1').AsFloat;
         SFL :=ODBDM.ib1q2.FieldByName('flag_1').AsInteger;

    FlagIsSet:=false;
    if TFL>0 then ProfilesSelection.FlagAnalysis(TFL,FlagIsSet);
    if SFL>0 then ProfilesSelection.FlagAnalysis(SFL,FlagIsSet);

   if (FlagIsSet=false) then begin
        Depth_to_Pressure(lev,stLat,0,pres);
        pres:=0;  //depth to pressure
        IEOS80(pres,TVal,SVal,svan,DVal);   //International Eq. Of State 1980
//showmessage('dval='+floattostr(dval));
         if DVal>0 then begin
           inc(k);
            D[k]:=Lev;
            P[k]:=DVal;
         end;
    end;
    ODBDM.ib1q2.Next; }
   end;

   if (CurrentParTable='BUOYANCY') then begin
    for i:=1 to k-1 do N2[i]:=Pi/((P[i+1]+P[i])/2)*(P[i+1]-P[i])/(D[i+1]-D[i]);
     for i:=1 to k-1 do P[i]:=1000*N2[i]; //Умножаем на 1000 для наглядности
     P[k]:=P[k-1];
    end;
  end; //d


(* Исходные профили в файл real.dat.  k-число горизонтов *)
  for fi:=1 to k do
     writeln(dat_r,  year_m:15:5,         //реальная дата
                    -D[fi]:10:1,          //глубина
                     P[fi]:10:3,          //параметр
                     absnum:10,           //абсолютный номер
                     datetostr(stdatetime):25); //время наблюдения


(* интерполяция на стандартный горизонт *)
 for c:=0 to memo1.Lines.Count-1 do begin
   IntLev:=strtoint(Memo1.Lines.Strings[c]);
    IntVal:=-999;
   for i:=1 to k do begin
     Enable:=false;
     //Интерполируем на ст. гор-т
     if (IntLev=0) and (D[i]<5) then begin
       IntVal:=P[i];
        Enable:=true;
       break;
     end;

     if D[i]=IntLev then begin
       IntVal:=P[i];
       Enable:=true;
      break;
     end;

     try  // trying to interpolate
     if (IntLev>D[i]) and (IntLev<D[i+1]) then begin
           //c - number of levels at profile;  i - sequential number of level
                                                  //       LU1     LU2    X      LD1      LD2     ->
       if (c=2)             then ODBPr_VertInt(IntLev, -9,     D[i], D[i+1], -9,      -9,     P[i], P[i+1], -9,      IntVal, Enable); //x + + x
       if (c>2) and (i=1)   then ODBPr_VertInt(IntLev, -9,     D[i], D[i+1], D[i+2],  -9,     P[i], P[i+1], P[i+2],  IntVal, Enable); //x + + +
       if (c>2) and (i=c-1) then ODBPr_VertInt(IntLev, D[i-1], D[i], D[i+1], -9,      P[i-1], P[i], p[i+1], -9,      IntVal, Enable); //+ + + x
       if (c>3) and (i<>1)  and (i<>c-1)
                            then ODBPr_VertInt(IntLev, D[i-1], D[i], D[i+1], D[i+2],  P[i-1], P[i], P[i+1], P[i+2],  IntVal, Enable); //+ + + +
       if enable=true then  break;
     end;
     except
       enable:=false;
     end;
   end;

     if (Enable=true) and (IntVal<>-999) then begin
      MaxDepth:=IntLev;

     {  with TDDCDS do begin
         Append;
           FieldByName('absnum').AsInteger:=absnum;
           FieldByName('date').AsDateTime :=stdate;
           FieldByName('time').AsDateTime :=sttime;
           FieldByName('year').AsInteger  :=year;
           FieldByName('month').AsInteger :=month;
           FieldByName('day').AsInteger   :=day;
           FieldByName('hour').AsInteger  :=hour;
           FieldByName('min').AsInteger   :=min;
           FieldByName('lev').AsInteger   :=IntLev;
           FieldByName('val').AsFloat     :=IntVal;
         Post;
       end;
    end;  }
  end;
 frmdm.Q.Next;
 end;  //w
 finally
 // ODBDM.IBTransaction1.Commit;
  frmdm.Q.EnableControls;
 end;

 MeanByMonth;


 {
  TDDCDS.first;
  while not TDDCDS.Eof do begin  //w
   absnum :=TDDCDS.FieldByName('absnum').asInteger;
   stdate :=TDDCDS.FieldByName('date').AsDateTime;
   sttime :=TDDCDS.FieldByName('time').asDateTime;
   lev    :=TDDCDS.FieldByName('lev').asInteger;
   Val    :=TDDCDS.FieldByName('Val').asfloat;
   year   :=TDDCDS.FieldByName('year').asInteger;
   Month  :=TDDCDS.FieldByName('month').asInteger;
   Hour   :=TDDCDS.FieldByName('hour').asInteger;
   Min    :=TDDCDS.FieldByName('min').asInteger;

     //исключение сезонного хода
   if not VarIsNull(MCDS.Locate('level', floattostr(lev),[])) and
      not VarIsNull(MCDS.FieldByName(inttostr(month)+'_md').AsVariant) then begin

       anom:=Val-MCDS.FieldByName(inttostr(month)+'_md').Asfloat;

       with TDDCDS do begin
        Edit;
           FieldByName('anom').AsFloat:=anom;
         Post;
       end;

        year_m:=TDDCDS.FieldByName('year').asInteger+
               (TDDCDS.FieldByName('month').asInteger-1)/12+
                TDDCDS.FieldByName('day').asInteger/DaysInAYear(TDDCDS.FieldByName('year').asInteger)+
                TDDCDS.FieldByName('hour').asInteger/(24*DaysInAYear(TDDCDS.FieldByName('year').asInteger))+
                TDDCDS.FieldByName('min').asInteger/(3600*DaysInAYear(TDDCDS.FieldByName('year').asInteger));

    // Пишем файл на стандартных горизонтах
     writeln(dat_i, year_m:15:5,
                    -lev:10:1,
                    val:10:3,
                    absnum:10,
                    datetostr(stdate):15,
                    timetostr(sttime):15,
                    anom:10:3);
   end; //if not empty

    TDDCDS.Next;
   end;  //w

   CloseFile(dat_r);  //Закрываем файл с начальными данными
   CloseFile(dat_i);  //Закрываем файл на ст. горизонтах



(* расчет среднемесячных аномалий с исключенным сезонным ходом *)
    TDDcds.First;
    mik:=0;
  while not TDDCDS.Eof do begin  //w
   mik:=mik+1;
    stdate:=TDDCDS.FieldByName('date').asDateTime;
    year  :=TDDCDS.FieldByName('year').asInteger;
    lev   :=TDDCDS.FieldByName('lev').asInteger;

   if mik=1 then begin
    dmin:=stdate; dmax:=stdate;
    ymin:=year; ymax:=year;
    lmin:=lev;  lmax:=lev;
   end;

   if stdate<dmin then dmin:=stdate;
   if stdate>dmax then dmax:=stdate;
   if year<ymin then ymin:=year;
   if year>ymax then ymax:=year;
   if lev<lmin then lmin:=lev;
   if lev>lmax then lmax:=lev;

   TDDCDS.Next;
  end; //w

  { kf_int:=(ymax-ymin)/lmax;

   mLog.Clear;
   mLog.Lines.Add('year min->max: '+inttostr(ymin)+'->'+inttostr(ymax));
   mLog.Lines.Add('lev  min->max: '+floattostr(lmin)+'->'+floattostr(lmax));
   mLog.Lines.Add('kf_int= '+floattostr(kf_int));
   mLog.Lines.Add('date min->max: '+datetostr(dmin)+'->'+datetostr(dmax));
   kf_int:=(dmax-dmin)/lmax;
   mLog.Lines.Add('kf_int= '+floattostr(kf_int));  }

    DecodeDate(dmin, year, month, day);
    dsum:=0;
    for i:=1 to month-1 do dsum:=dsum+DaysInAMonth(year,i);
    dsum:=dsum+15;           //число дней к середине месяца
    dYear:=DaysInAYear(year); //число дней в году
    x1:=year+dsum/dYear;
   // StartDate:=x1;

    DecodeDate(dmax, year, month, day);
    dsum:=0;
    for i:=1 to month-1 do dsum:=dsum+DaysInAMonth(year,i);
    dsum:=dsum+15;           //число дней к середине месяца
    dYear:=DaysInAYear(year); //число дней в году
    x2:=year+dsum/dYear;

  // showmessage(floattostr(x2)+#9+floattostr(x2)+#9+floattostr(lmax));
   kf_int:=(x2-x1)/lmax;
  // mLog.Lines.Add('kf_int= '+floattostr(kf_int));


//1.добавляем среднемесячные значения в cdsTDDMonth
 for y:=ymin to ymax do begin //y
  for m:=1 to 12 do begin  //m
    dsum:=0;
    for i:=1 to m-1 do dsum:=dsum+DaysInAMonth(y,i);
    dsum:=dsum+15;           //число дней к середине месяца
    dYear:=DaysInAYear(y); //число дней в году
    x:=y+dsum/dYear;

    cdsMeanPrf.EmptyDataSet;
    //
  for c:=0 to memo1.Lines.Count-1 do begin
   cdsMeanPrf.Append;
   cdsMeanPrf.FieldByName('lev').AsInteger:=strtoint(Memo1.Lines.Strings[c]);
   cdsMeanPrf.FieldByName('n').AsInteger:=0;
   cdsMeanPrf.FieldByName('val').AsInteger:=0;
   cdsMeanPrf.FieldByName('valSCR').AsInteger:=0;
   cdsMeanPrf.Post;
  end;


    //three months centered mean
    case m of
    1:     begin
            yb:=y-1; mb:=12; db:=1;
            ye:=y;   me:=2;  de:=DaysInAMonth(ye,me);
            date1:=encodedate(yb,mb,db);
            date2:=encodedate(ye,me,de);
           end;
    2..11: begin
            yb:=y; mb:=m-1; db:=1;
            ye:=y; me:=m+1; de:=DaysInAMonth(ye,me);
            date1:=encodedate(yb,mb,db);
            date2:=encodedate(ye,me,de);

             (*showmessage('  yb= '+inttostr(yb)
               +'  ye= '+inttostr(ye)
               +'  mb= '+inttostr(mb)
               +'  me= '+inttostr(me)
               +'  db= '+inttostr(db)
               +'  de= '+inttostr(de));*)
        end;
    12:    begin
            yb:=y;   mb:=11; db:=1;
            ye:=y+1; me:=1;  de:=DaysInAMonth(ye,me);
            date1:=encodedate(yb,mb,db);
            date2:=encodedate(ye,me,de);
           end;
     end; //case

     //если есть хоть одно наблюдение внутри месяца, расчет средних
     //исключение экстрополяции за пределы периода наблюдений
     de:=DaysInAMonth(y,m);
     dateb:=encodedate(y,m,de);
     datee:=encodedate(y,m,1);

   //monthly mean
   TDDcds.Filter:='year='+inttostr(y)+' and month='+inttostr(m);


    //three months centered mean
   // centered mean if data within measured period
   //showmessage('datemin='+datetostr(dmin)+'  datemax='+datetostr(dmax));
 if (dateb>=dmin) and (datee<=dmax) then begin  //p
    TDDcds.Filtered:=true;
    TDDCDS.First;
    st_ex:=false;
  while not TDDCDS.Eof do begin  //w
    st_ex:=true;

    sdlev:=TDDCDS.FieldByName('lev').asInteger;
    val  :=TDDCDS.FieldByName('val').asfloat;
    anom :=TDDCDS.FieldByName('anom').asfloat;


   if not VarIsNull(cdsMeanPrf.Locate('lev',sdlev,[])) then begin
    //statistics stored in cdsMeanPrf
    cdsMeanPrf.Edit;
    cdsMeanPrf.FieldByName('n').AsInteger:=cdsMeanPrf.FieldByName('n').AsInteger+1;
    cdsMeanPrf.FieldByName('val').AsFloat:=cdsMeanPrf.FieldByName('val').AsFloat+val;
    cdsMeanPrf.FieldByName('valSCR').AsFloat:=cdsMeanPrf.FieldByName('valSCR').AsFloat+anom;

    cdsMeanPrf.Post;
   end;

    TDDCDS.Next;
  end;  //w

    cdsMeanPrf.First;  //средний профиль для данного месяца данного года
    mik_lev:=0;
  while not cdsMeanPrf.Eof do begin  //pr
    n:=cdsMeanPrf.FieldByName('n').asInteger;
    sdlev:=cdsMeanPrf.FieldByName('lev').asInteger;
    val:=cdsMeanPrf.FieldByName('val').asfloat;
    valSCR:=cdsMeanPrf.FieldByName('valSCR').asfloat;


  if n>0 then begin  //i

     //создание бланковочного файла по последнему горизонту
     mik_lev:=mik_lev+1;
     if mik_lev=1 then Ulev:=-sdlev;  //верхний горизонт
                       Dlev:=-sdlev;  //нижний горизонт


     val:=val/n;        //среднемес значение на гор
     valSCR:=valSCR/n; //среднемесячные значение с исключенным сезонным ходом


    (* mLog.Lines.Add(inttostr(y)
     +#9+inttostr(m)
     +#9+inttostr(sdlev)
     +#9+inttostr(n)
     +#9+floattostrF(val,ffFixed,10,5)); *)

     TimeTr:=(x-x1)/kf_int;
     //writeln(dat_Month, TimeTR:10:5, -sdlev:8, x:12:5, val:15:4, n:8);
     cdsTTDMonth.Append;
     cdsTTDMonth.FieldByName('timeTR').AsFloat:=TimeTR;
     cdsTTDMonth.FieldByName('sdlev').AsInteger:=sdlev;
     cdsTTDMonth.FieldByName('time').AsFloat:=x;
     cdsTTDMonth.FieldByName('val').AsFloat:=val;
     cdsTTDMonth.FieldByName('valSCR').AsFloat:=valSCR; //val с искл сез ходом!!!
     cdsTTDMonth.FieldByName('an').AsFloat:=0;
     cdsTTDMonth.FieldByName('anSCR').AsFloat:=0;
     cdsTTDMonth.FieldByName('n').AsInteger:=n;
     cdsTTDMonth.Post;

  end; //i

    cdsMeanPrf.Next;
  end; //pr


   //заполняем бланковочный cds
   if st_ex=true then begin
    cdsLastLevBln.Append;
    cdsLastLevBln.FieldByName('time').AsFloat:=x;
    cdsLastLevBln.FieldByName('timeTR').AsFloat:=TimeTR;
    cdsLastLevBln.FieldByName('ULev').AsFloat:=ULev;
    cdsLastLevBln.FieldByName('DLev').AsFloat:=DLev;
    cdsLastLevBln.Post;
   end;

   end; //within period  //p
  end; //m
  end; //y

   mLog.Lines.Add('...monthly mean values added to cdsTTDMonth');
   Application.ProcessMessages;

//1a. проверка на дырки
    Ystep:=2;
    cdsLastLevBln.First;
    Ybeg:=cdsLastLevBln.FieldByName('time').AsFloat;
    cdsLastLevBln.Last;
    Yend:=cdsLastLevBln.FieldByName('time').AsFloat;
    CountStep:=trunc((Yend-Ybeg)/Ystep)+1;

    { mLog.Lines.Add('');
     mLog.Lines.Add('Ybeg='+floattostrF(ybeg,ffFixed,10,3));
     mLog.Lines.Add('Yend='+floattostrF(yend,ffFixed,10,3));
     mLog.Lines.Add('CountStep='+inttostr(CountStep));
     mLog.Lines.Add('step y1 y2 countGap'); }

     CountGap:=0;
    for ky:=1 to CountStep do begin
     Y1:=Ybeg+Ystep*(ky-1);
     Y2:=Ybeg+Ystep*ky;

     cdsLastLevBln.Filter:='time>='+floattostr(Y1)+' and time<='+floattostr(Y2);
     cdsLastLevBln.Filtered:=true;
     if cdsLastLevBln.RecordCount=0 then CountGap:=CountGap+1;

    { mLog.Lines.Add(inttostr(ky)
        +#9+floattostrF(y1,ffFixed,10,3)
        +#9+floattostrF(y2,ffFixed,10,3)
        +#9+inttostr(CountGap)
        );  }
     end;
      cdsLastLevBln.Filtered:=false;

//1b. в файл без дырок
  if CountGap=0 then begin  //g

    writeln(dat_bln,(CountStep*4+1):5, 0:5);

    //последовательно верхние горизонты
  for ky:=1 to CountStep do begin  //y

    ULevMin:=-9999;
    DLevMax:=9999;

    Y1:=Ybeg+Ystep*(ky-1);
    Y2:=Ybeg+Ystep*ky;

    cdsLastLevBln.First;
    cdsLastLevBln.Filter:='time>='+floattostr(Y1)+' and time<='+floattostr(Y2);
    cdsLastLevBln.Filtered:=true;
    //минимальный горизонт за заданный промежуток времени
   while not cdsLastLevBln.Eof do begin
    ULev:=cdsLastLevBln.FieldByName('ULev').AsFloat;
    if ULev>ULevMin then ULevMin:=ULev;
    cdsLastLevBln.Next;
   end;
    writeln(dat_bln,Y1:12:5,ULevMin:10:1);
    writeln(dat_bln,Y2:12:5,ULevMin:10:1);
  end; //y
      cdsLastLevBln.Filtered:=false;

    //нижние горизонты в обратном порядке
  for ky:=1 to CountStep do begin  //y

    ULevMin:=-9999;
    DLevMax:=9999;

    Y1:=Yend-Ystep*(ky-1);
    Y2:=Yend-Ystep*ky;

    cdsLastLevBln.First;
    cdsLastLevBln.Filter:='time>='+floattostr(Y2)+' and time<='+floattostr(Y1);
    cdsLastLevBln.Filtered:=true;
    //минимальный горизонт за заданный промежуток времени
   while not cdsLastLevBln.Eof do begin
    DLev:=cdsLastLevBln.FieldByName('DLev').AsFloat;
    if DLev<DLevMax then DLevMax:=DLev;
    //showmessage(floattostr(dlev)+'  '+floattostr(dlevMax));
    cdsLastLevBln.Next;
   end;
    writeln(dat_bln,Y1:12:5,DLevMax:10:1);
    writeln(dat_bln,Y2:12:5,DLevMax:10:1);
  end;  //y
      cdsLastLevBln.Filtered:=false;
    //первая станция верхний горизонт
    cdsLastLevBln.First;
    writeln(dat_bln,cdsLastLevBln.FieldByName('time').AsFloat:12:5,
                  cdsLastLevBln.FieldByName('ULev').AsFloat:10:1);

  end;  //g


//1c. в файл c пропусками
  if CountGap>0 then begin  //h


   //определяем min/max горизонт по всему набору данных
    cdsLastLevBln.First;
   while not cdsLastLevBln.Eof do begin
    ULev:=cdsLastLevBln.FieldByName('ULev').AsFloat;
    DLev:=cdsLastLevBln.FieldByName('DLev').AsFloat;
    if DLev<DLevMax then DLevMax:=DLev;
    if ULev>ULevMin then ULevMin:=ULev;
    cdsLastLevBln.Next;
   end;

   mLog.Lines.Add('lev min/max= '+floattostr(ULevMin)+'/'+floattostr(DLevMax));
   Application.ProcessMessages;


    writeln(dat_bln,(CountStep*4+1):5, 0:5);

    //последовательно верхние горизонты
  for ky:=1 to CountStep do begin  //y

    //ULevMin:=-9999;
    //DLevMax:=9999;

    Y1:=Ybeg+Ystep*(ky-1);
    Y2:=Ybeg+Ystep*ky;

    cdsLastLevBln.First;
    cdsLastLevBln.Filter:='time>='+floattostr(Y1)+' and time<='+floattostr(Y2);
    cdsLastLevBln.Filtered:=true;
    //минимальный горизонт за заданный промежуток времени
   while not cdsLastLevBln.Eof do begin
    ULev:=cdsLastLevBln.FieldByName('ULev').AsFloat;
    if ULev>ULevMin then ULevMin:=ULev;
    cdsLastLevBln.Next;
   end;
    writeln(dat_bln,Y1:12:5,ULevMin:10:1);
    writeln(dat_bln,Y2:12:5,ULevMin:10:1);


  end;  //y
      cdsLastLevBln.Filtered:=false;

    //нижние горизонты в обратном порядке
  for ky:=1 to CountStep do begin  //y

    ULevMin:=-9999;
    DLevMax:=9999;

    Y1:=Yend-Ystep*(ky-1);
    Y2:=Yend-Ystep*ky;

    cdsLastLevBln.First;
    cdsLastLevBln.Filter:='time>='+floattostr(Y2)+' and time<='+floattostr(Y1);
    cdsLastLevBln.Filtered:=true;
    //минимальный горизонт за заданный промежуток времени
   while not cdsLastLevBln.Eof do begin
    DLev:=cdsLastLevBln.FieldByName('DLev').AsFloat;
    if DLev<DLevMax then DLevMax:=DLev;
    //showmessage(floattostr(dlev)+'  '+floattostr(dlevMax));
    cdsLastLevBln.Next;
   end;
    writeln(dat_bln,Y1:12:5,DLevMax:10:1);
    writeln(dat_bln,Y2:12:5,DLevMax:10:1);
  end;  //y
      cdsLastLevBln.Filtered:=false;
    //первая станция верхний горизонт
    cdsLastLevBln.First;
    writeln(dat_bln,cdsLastLevBln.FieldByName('time').AsFloat:12:5,
                  cdsLastLevBln.FieldByName('ULev').AsFloat:10:1);

  end;  //h

    closefile(dat_bln);
    cdsLastLevBln.EmptyDataSet;
    cdsLastLevBln.Free;


//2. расчет средних на стандартных горизонтах по среднемесячным данным



(*===================СРЕДНИЙ ПРОФИЛЬ. УКАЗЫВАЕМ ПЕРИОД ОСРЕДНЕНИЯ=============*)
(*===================ВАЖНО!!! ПРОФИЛЬ ИСПОЛЬЗУЕТСЯ ПРИ РАСЧЕТЕ АНОМАЛИЙ=======*)
// Очищаем набор данных для среднего профиля
    cdsMeanPrf.First;
   while not cdsMeanPrf.Eof do begin
    cdsMeanPrf.Edit;
    cdsMeanPrf.FieldByName('n').AsInteger:=0;
    cdsMeanPrf.FieldByName('val').AsFloat:=0;
    cdsMeanPrf.FieldByName('valSCR').AsFloat:=0;
    cdsMeanPrf.Post;
    cdsMeanPrf.Next;
   end;

 (* Рассчитываем средний профиль для заданного периода *)
  cdsTTDMonth.First;
   while not cdsTTDMonth.Eof do begin
    time1  :=cdsTTDMonth.FieldByName('time').AsFloat;

    // Если дата в диапазоне, считаем среднее
    if (time1>=seYY1.Value) and (time1<=seYY2.Value) then begin
      sdlev  :=cdsTTDMonth.FieldByName('sdlev').AsInteger;
      val    :=cdsTTDMonth.FieldByName('val').AsFloat;
      valSCR :=cdsTTDMonth.FieldByName('valSCR').AsFloat;

       with cdsMeanPrf do begin
         if not VarIsNull(Locate('lev',sdlev,[])) then begin
          Edit;
            FieldByName('n').AsInteger:=FieldByName('n').AsInteger+1; //число значений на горизонте
            FieldByName('val').AsFloat:=FieldByName('val').AsFloat+val;
            FieldByName('valSCR').AsFloat:=FieldByName('valSCR').AsFloat+valSCR;
          Post;
         end;
       end;
    end;
    cdsTTDMonth.Next;
   end;

   //среднемноголетний профиль значений и значений с искл. сезонным ходом
   //для выбранного диапазона лет!!!
   cdsMeanPrf.First;
  while not cdsMeanPrf.Eof do begin  //w
    lev:=cdsMeanPrf.FieldByName('lev').AsInteger;
    n:=cdsMeanPrf.FieldByName('n').AsInteger;
    val:=cdsMeanPrf.FieldByName('val').AsFloat;
    valSCR:=cdsMeanPrf.FieldByName('valSCR').AsFloat;

    if n>0 then begin
     cdsMeanPrf.Edit;
      cdsMeanPrf.FieldByName('val').AsFloat:=val/n;
      cdsMeanPrf.FieldByName('valSCR').AsFloat:=valSCR/n;
     cdsMeanPrf.Post;
    end;

    cdsMeanPrf.Next;
  end; //w

  mLog.Lines.Add('...mean values at sdlev added to cdsMeanPrf');
  Application.ProcessMessages;
(*========================КОНЕЦ РАСЧЕТА СРЕДНЕГО ПРОФИЛЯ======================*)



(*===============================АНОМАЛИИ=====================================*)
  cdsTTDMonth.First;
  while not cdsTTDMonth.Eof do begin  //w
    sdlev:=cdsTTDMonth.FieldByName('sdlev').AsInteger;
    val:=cdsTTDMonth.FieldByName('val').AsFloat;
    valSCR:=cdsTTDMonth.FieldByName('valSCR').AsFloat;
    cdsMeanPrf.Locate('lev',sdlev,[]);

    cdsTTDMonth.Edit;
    cdsTTDMonth.FieldByName('an').AsFloat:=
       cdsTTDMonth.FieldByName('val').AsFloat-cdsMeanPrf.FieldByName('val').AsFloat;
    cdsTTDMonth.FieldByName('anSCR').AsFloat:=
       cdsTTDMonth.FieldByName('valSCR').AsFloat-cdsMeanPrf.FieldByName('valSCR').AsFloat;
    cdsTTDMonth.Post;

   { if sdlev=1400 then
     showmessage(floattostr(cdsTTDMonth.FieldByName('valSCR').AsFloat)+'   '+
                 floattostr(cdsMeanPrf.FieldByName('valSCR').AsFloat)+'   '+
                 floattostr(cdsTTDMonth.FieldByName('anSCR').AsFloat)); }

    cdsTTDMonth.Next;
  end; //w
  mLog.Lines.Add('...anomalies are computed');
  Application.ProcessMessages;
(*======================КОНЕЦ РАСЧЕТА АНОМАЛИЙ================================*)


//3. в файл среднемесячные значения
  try
    cdsTTDMonth.First;
   while not cdsTTDMonth.Eof do begin  //w
    timeTR :=cdsTTDMonth.FieldByName('timeTR').AsFloat;
    sdlev  :=cdsTTDMonth.FieldByName('sdlev' ).AsInteger;
    time1  :=cdsTTDMonth.FieldByName('time'  ).AsFloat;
    val    :=cdsTTDMonth.FieldByName('val'   ).AsFloat;
    valSCR :=cdsTTDMonth.FieldByName('valSCR').AsFloat;
    an     :=cdsTTDMonth.FieldByName('an'    ).AsFloat;
    anSCR  :=cdsTTDMonth.FieldByName('anSCR' ).AsFloat;
    n      :=cdsTTDMonth.FieldByName('n'     ).AsInteger;

    (* пишем среднемесячные значения в файл *)
     writeln(dat_Month, time1:15:5,
                       -sdlev:10,
                        val:15:4,
                        valSCR:15:4,
                        an:15:4,
                        anSCR:15:4,
                        n:8);

    cdsTTDMonth.Next;
   end; //w
   mLog.Lines.Add('...file month.dat has been created');
  except
   mLog.Lines.Add('...file month.dat - FAILED!');
  end;
  Application.ProcessMessages;


   try
    TimeSeriesAtLevels;
     mLog.Lines.Add('...files with Monthly Mean time series - SUCCESS!');
   except
     mLog.Lines.Add('...files with Monthly Mean time series - FAILED!');
   end;
   Application.ProcessMessages;


   try
    TDDCDS.Filtered:=false;
    TimeSeriesAtLevels_PRF;
     mLog.Lines.Add('...files with INITIAL time series - SUCCESS!');
   except
     mLog.Lines.Add('...files with INITIAL time series - FAILED!');
   end;
   Application.ProcessMessages;


    closefile(dat_Month);
    cdsMeanPrf.EmptyDataSet;
    cdsMeanPrf.Free;
    TDDCDS.Free;
    cdsTTDMonth.Free;
    MCDS.Free;

    AssignFile(dat_month, TDDPath+'Month.dat'); reset(dat_month);
    cbParameters.clear;
    cbParameters.Text:='Select column...';
    readln(dat_month, st);
    buf_str:='';
    k:=0;
   repeat
    inc(k);
       if (st[k]<>' ') and (ord(st[k])<>0) then
          buf_str:=buf_str+st[k];
       if (st[k]=' ') or (ord(st[k])=0) then begin
       cbParameters.Items.Add(trim(buf_str));
       buf_str:='';
       end;
   until (ord(st[k])=0) or (eof(dat_month));

  Closefile(dat_month); // Закрываем файл с бланковкой

  for k:=0 to 2 do cbParameters.Items.Delete(0);


 (* Файл с разницей значений по месяцам *)
 try
  MonthsDifference;
   mLog.Lines.Add('...monthly difference - SUCCESS!');
 except
   mLog.Lines.Add('...monthly difference - FAILED!');
 end;

 (* Средние по годам *)
 try
  MeanByYear;
   mLog.Lines.Add('...mean by years - SUCCESS!');
 except
   mLog.Lines.Add('...mean by years - FAILED!');
 end;

 mLog.Lines.Add('==================');
 mLog.Lines.Add('Done! Time spent: '+Timetostr(Now-TimeStart));
 Application.ProcessMessages;

 rgDataFile.Enabled:=true;
 btnGetData.Enabled:=true;
if rgDataFile.ItemIndex<>-1 then rgDataFile.OnClick(self);  }
end;
////////////////////////////////////////////////////////////////////////////////
///////////////////////////////END OF GET_DATA///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////// }



(* Среднемесячные значения на стандартных горизонтах *)
procedure Tfrmtimedepthdiagram.MeanByMonth;
Var
k, Lev,c, count:integer;
Mean, Val, Mean2:real;
vmd, vsd0, vsd, min, max:real;
MonthlyProfilesFileName:string;
begin
 MCDS:=TBufDataSet.Create(nil);
   with MCDS.FieldDefs do begin
      Add('level',ftInteger,0,false);
     for k:=1 to 12 do begin
        Add(inttostr(k)+'_n',ftFloat,0,false);
        Add(inttostr(k)+'_md',ftFloat,0,false);
        Add(inttostr(k)+'_sd',ftFloat,0,false);
        Add(inttostr(k)+'_min',ftFloat,0,false);
        Add(inttostr(k)+'_max',ftFloat,0,false);
     end;
       Add('year_n',ftFloat,0,false);
       Add('year_md',ftFloat,0,false);
       Add('year_sd',ftFloat,0,false);
       Add('year_min',ftFloat,0,false);
       Add('year_max',ftFloat,0,false);
   end;
  MCDS.CreateDataSet;
 // MCDS.LogChanges:=false;

  for c:=0 to memo1.Lines.Count-1 do begin
   MCDS.Append;
    MCDS.FieldByName('level').AsInteger:=strtoint(Memo1.Lines.Strings[c]);
   MCDS.Post;
  end;


for k:=1 to 12 do begin
 for c:=0 to memo1.Lines.Count-1 do begin
   lev:=strtoint(Memo1.Lines.Strings[c]);

   //Считаем аномалии по заданному периоду!!!
   TDDCDS.Filter:='Lev='+Memo1.Lines.Strings[c]+ ' and month='+inttostr(k)+
                  ' and Year>='+SeYY1.Text+' and Year<='+SeYY2.Text; //Диапазон лет

   TDDCDS.Filtered:=true;
   TDDCDS.First;


   if TDDCDS.RecordCount>0 then begin
    mean:=0; mean2:=0; val:=0;
    min:=9999; max:=-9999; vsd:=0; vmd:=0;
     while not TDDCDS.Eof do begin
      val:=TDDCDS.FieldByName('Val').asfloat;

      if val>max then max:=val;
      if val<min then min:=val;

      Mean:=Mean+Val;
      mean2:=mean2+(Val*Val);
      TDDCDS.Next;
     end;

    count:=TDDCDS.RecordCount;
    vmd:=mean/Count;
    vsd0:=(mean2-mean*mean/count)/count;
    if vsd0>0 then vsd:=sqrt(vsd0);

    MCDS.Locate('level', lev, []);
      with MCDS do begin
         Edit;
           FieldByName(inttostr(k)+'_n').Asfloat:=Count;
           FieldByName(inttostr(k)+'_md').Asfloat:=vmd;
           FieldByName(inttostr(k)+'_sd').Asfloat:=vsd;
           FieldByName(inttostr(k)+'_min').Asfloat:=min;
           FieldByName(inttostr(k)+'_max').Asfloat:=max;
         Post;
       end;
     // showmessage(inttostr(k)+'   '+inttostr(lev)+'   '+
     //             floattostr(MCDS.FieldByName(inttostr(k)+'_md').Asfloat)+'   '+
    //              floattostr(MCDS.FieldByName(inttostr(k)+'_max').Asfloat));
   end;

    TDDCDS.Filtered:=false;
 end;
 end;


  MCDS.First;
  for c:=0 to memo1.Lines.Count-1 do begin
   lev:=strtoint(Memo1.Lines.Strings[c]);
   MCDS.Locate('level', Memo1.Lines.Strings[c],[]);

     mean:=0; count:=0; mean2:=0;
     min:=9999; max:=-9999;
     vsd:=0; vmd:=0;
     For k:=1 to 12 do
      if MCDS.FieldByName(inttostr(k)+'_md').AsVariant<>null then begin
          Val:=MCDS.FieldByName(inttostr(k)+'_md').AsFloat;
           if val>max then max:=val;
           if val<min then min:=val;
           Mean:=Mean+Val;
           mean2:=mean2+(Val*Val);
           inc(count);
       end;

      if count>0 then begin
         vmd:=mean/Count;
         vsd0:=(mean2-mean*mean/count)/count;
         if vsd0>0 then vsd:=sqrt(vsd0);
       with MCDS do begin
         Edit;
           FieldByName('year_n').Asfloat:=count;
           FieldByName('year_md').Asfloat:=vmd;
           FieldByName('year_sd').Asfloat:=vsd;
           FieldByName('year_min').Asfloat:=min;
           FieldByName('year_max').Asfloat:=max;
         Post;
       end;
      end;
   end;


    (* Пишем средние по месяцам профили *)
   for k:=1 to 12 do begin

   if k<10 then MonthlyProfilesFileName:='0'+inttostr(k) else MonthlyProfilesFileName:=inttostr(k);

    AssignFile(dat_m, TDDPath+'MonthlyProfiles\'+MonthlyProfilesFileName+'.dat'); Rewrite(dat_m);
    writeln(dat_m, 'Level':10, 'n':10, 'md':10, 'sd':10, 'min':10, 'max':10);
     MCDS.first;
      while not MCDS.Eof do begin

         if  MCDS.FieldByName(inttostr(k)+'_n').Asfloat>0 then
            writeln(dat_m, MCDS.FieldByName('level').AsInteger:10,
                  MCDS.FieldByName(inttostr(k)+'_n').Asinteger:10,
                  MCDS.FieldByName(inttostr(k)+'_md').Asfloat:10:3,
                  MCDS.FieldByName(inttostr(k)+'_sd').Asfloat:10:3,
                  MCDS.FieldByName(inttostr(k)+'_min').Asfloat:10:3,
                  MCDS.FieldByName(inttostr(k)+'_max').Asfloat:10:3);

        MCDS.Next;
     end;
    CloseFile(dat_m);
  end;

  AssignFile(dat_m, TDDPath+'MonthlyProfiles\Year.dat'); Rewrite(dat_m);
  writeln(dat_m, 'Level':10, 'n':10, 'md':10, 'sd':10, 'min':10, 'max':10);
     MCDS.first;
      while not MCDS.Eof do begin
         if  MCDS.FieldByName('year_n').Asfloat>0 then
            writeln(dat_m, MCDS.FieldByName('level').AsInteger:10,
                  MCDS.FieldByName('year_n').AsInteger:10,
                  MCDS.FieldByName('year_md').Asfloat:10:3,
                  MCDS.FieldByName('year_sd').Asfloat:10:3,
                  MCDS.FieldByName('year_min').Asfloat:10:3,
                  MCDS.FieldByName('year_max').Asfloat:10:3);
        MCDS.Next;
     end;
 CloseFile(dat_m);
end;


(* Выбираем файл для построения и читаем первую строчку *)
procedure Tfrmtimedepthdiagram.rgDataFileClick(Sender: TObject);
Var
k, NumPar:integer;
st, buf_str:string;
begin
 Case rgDataFile.ItemIndex of
  -1: Exit;
   0: CurrentFile:=TDDPath+'Real.dat';
   1: CurrentFile:=TDDPath+'StLev.dat';
   2: CurrentFile:=TDDPath+'Month.dat';
   3: CurrentFile:=TDDPath+'Year.dat';
   4: CurrentFile:=TDDPath+'Month_dif.dat';
   5: CurrentFile:=TDDPath+'Year_dif.dat';
 End;

 cbParameters.Clear;
 AssignFile(Dat, CurrentFile); Reset(dat);
  readln(dat, st);
   buf_str:=''; NumPar:=0;
   For k:=1 to length(st) do begin
     if (st[k]<>' ') then buf_str:=buf_str+st[k];
       if ((st[k]=' ') and (buf_str<>'')) or (k=length(st))  then begin
         inc(NumPar); // Убираем первые три поля
          if NumPar>2 then cbParameters.Items.Add(trim(buf_str));
          buf_str:='';
       end;
   end;
  CloseFile(Dat);
  cbParameters.Text:='Select parameter...';
  cbParameters.Enabled:=true;
  rgParameters.Enabled:=true;
end;


procedure Tfrmtimedepthdiagram.GetScriptSmooth;
Var
Ini:TIniFile;
DateMin, DateMax, LevMin, LevMax:real;
date1, lev, kf_int, DateTr:real;
str, IntMethod:string;
begin
(* Ищем максимальные и минимальные даты и глубины *)
   AssignFile(Dat, CurrentFile); Reset(Dat);
   DateMin:=9999; DateMax:=-9999; LevMin:=9999; LevMax:=-9999;
    readln(dat);
     repeat
     readln(dat, date1,  lev);
       DateMin:=Min(date1, DateMin);
       DateMax:=Max(date1, DateMax);
       LevMin:=Min(lev, LevMin);
       LevMax:=Max(lev, LevMax);
     until eof(dat);
   CloseFile(dat);


   // Коэффициент трансформации
   kf_int:=(DateMax-DateMin)/(LevMax-LevMin);
   StartDate:=DateMin;

   // Формируем файл для построения
   AssignFile(Dat,  CurrentFile); Reset(Dat);
    readln(Dat, str);
   AssignFile(Dat1, TDDPath+'Data.plt'); Rewrite(Dat1);
    writeln(Dat1, 'Date':15, 'Date_tr':15, Copy(str, 15, length(str)));

    repeat
      readln(Dat, str);
       Date1:=StrToFloat(Copy(str, 1, 15));
       DateTr:=((Date1-StartDate)/kf_int);
      writeln(Dat1, Date1:15:5, DateTr:15:5, Copy(str, 15, length(str)));
    until eof(Dat);
    CloseFile(Dat);
    CloseFile(Dat1);

    AssignFile(Script, TDDPath+'Script.bas'); Rewrite(Script);

(* Читаем настройки из файла *)
 try
   Ini := TIniFile.Create(IniFileName);
   IntMethod:=Ini.ReadString   ('TDD', 'Algorithm', 'srfKriging');

     WriteLn(Script, 'Sub Main');
     WriteLn(Script, 'Dim Surf, Diagram, Doc, Var As Object');
     WriteLn(Script, '');
     WriteLn(Script, 'pathDataFile ="'+TDDPath+'Data.plt'+'"');
    // WriteLn(Script, 'pathDataFile ="'+TDDPath+'Month.dat"');
     WriteLn(Script, 'pathBlnFile ="'+TDDPath+'Month.bln"');
     WriteLn(Script, 'PathGRD = "'+TDDPath+'Grid.grd"');

     WriteLn(Script, '');
     WriteLn(Script, 'Set Surf = CreateObject("Surfer.Application") ');
     WriteLn(Script, '');
     WriteLn(Script, 'Surf.Visible = True');
     WriteLn(Script, '  Set Doc = Surf.Documents.Add ');
     WriteLn(Script, '  Set Diagram = Doc.Windows(1)');
     WriteLn(Script, '  Diagram.AutoRedraw = False');
     WriteLn(Script, '  Doc.PageSetup.Orientation = srfLandscape');
     WriteLn(Script, '  Doc.DefaultFill.Pattern="Solid"');
     WriteLn(Script, '  Doc.DefaultFill.ForeColor=srfColorBlack20');
     WriteLn(Script, '');

     (* Анизотропия - АК*)
     writeln(script, '  Set Var=Surf.NewVarioComponent( _');
     writeln(script, '  VarioType:=srfVarLinear, _');
     writeln(script, '  AnisotropyRatio:='+Ini.ReadString('TDD', 'AnisotropyRatio', '1')+', _');
     writeln(script, '  AnisotropyAngle:='+Ini.ReadString('TDD', 'AnisotropyAngle', '0' )+')');
     writeln(Script, '');

//создание грида
     WriteLn(Script, 'Surf.GridData(DataFile:=pathDataFile, _');
     WriteLn(Script, '	xCol:=2, _');  //трансформированное время
     WriteLn(Script, '  yCol:=3, _');  //реальная глубина с минусом
     WriteLn(Script, '  zCol:='+inttostr(cbParameters.ItemIndex+4)+', _');  //номер колонки
     WriteLn(Script, '  numRows:='+IntToStr(seY.Value)+', _');
     WriteLn(Script, '  numCols:='+IntToStr(seX.Value)+', _');
     WriteLn(Script, '  Algorithm:='+IntMethod+', _');

     (* Для анизотропии - АК*)
     writeln(script, '  KrigVariogram:=Var, _');
     writeln(script, '  AnisotropyRatio:='+Ini.ReadString('TDD', 'AnisotropyRatio', '1')+', _');
     writeln(script, '  AnisotropyAngle:='+Ini.ReadString('TDD', 'AnisotropyAngle', '0' )+', _');

     (* Настройки для различных методов интерполяции *)
  (* Настройки для различных методов интерполяции *)
  if IntMethod='srfKriging'  then begin
    WriteLn(script, '       KrigType:='          +Ini.ReadString('TDD', 'KrigType',          'srfKrigPoint')+', _');
    WriteLn(script, '       KrigDriftType:='     +Ini.ReadString('TDD', 'KrigDriftType',     'srfDriftNone')+', _');
    WriteLn(script, '       SearchEnable:=1, _');  //not Ini.ReadBool('Fields', 'SearchEnable',       true);
    WriteLn(script, '       SearchNumSectors:='  +Ini.ReadString('TDD', 'SearchNumSectors',  '4')  +', _');
    WriteLn(script, '       SearchMinData:='     +Ini.ReadString('TDD', 'SearchMinData',     '16') +', _');
    WriteLn(script, '       SearchMaxData:='     +Ini.ReadString('TDD', 'SearchMaxData',     '64') +', _');
    WriteLn(script, '       SearchDataPerSect:=' +Ini.ReadString('TDD', 'SearchDataPerSect', '8')  +', _');
    WriteLn(script, '       SearchMaxEmpty:='    +Ini.ReadString('TDD', 'SearchMaxEmpty',    '3')  +', _');
    WriteLn(script, '       SearchRad1:='        +Ini.ReadString('TDD', 'SearchRad1',        '1')  +', _');
    WriteLn(script, '       SearchRad2:='        +Ini.ReadString('TDD', 'SearchRad2',        '1')  +', _');
    WriteLn(script, '       SearchAngle:='       +Ini.ReadString('TDD', 'SearchAngle',       '0')  +', _');
  end;
  if IntMethod='srfInverseDistanse' then begin
    WriteLn(script, '       SearchEnable:='       +Ini.ReadString('TDD', 'SearchEnable',      '0')  +', _');
    WriteLn(script, '       SearchNumSectors:='   +Ini.ReadString('TDD', 'SearchNumSectors',  '4')  +', _');
    WriteLn(script, '       SearchMinData:='      +Ini.ReadString('TDD', 'SearchMinData',     '16') +', _');
    WriteLn(script, '       SearchMaxData:='      +Ini.ReadString('TDD', 'SearchMaxData',     '64') +', _');
    WriteLn(script, '       SearchDataPerSect:='  +Ini.ReadString('TDD', 'SearchDataPerSect', '8')  +', _');
    WriteLn(script, '       SearchMaxEmpty:='     +Ini.ReadString('TDD', 'SearchMaxEmpty',    '3')  +', _');
    WriteLn(script, '       SearchRad1:='         +Ini.ReadString('TDD', 'SearchRad1',        '1')  +', _');
    WriteLn(script, '       SearchRad2:='         +Ini.ReadString('TDD', 'SearchRad2',        '1')  +', _');
    WriteLn(script, '       SearchAngle:='        +Ini.ReadString('TDD', 'SearchAngle',       '0')  +', _');
    WriteLn(script, '       AnisotropyRatio:='    +Ini.ReadString('TDD', 'AnisotropyRatio',   '1')  +', _');
    WriteLn(script, '       AnisotropyAngle:='    +Ini.ReadString('TDD', 'AnisotropyAngle',   '0')  +', _');
    WriteLn(script, '       IDPower:='            +Ini.ReadString('TDD', 'IDPower',           '2')  +', _');
    WriteLn(script, '       IDSmoothing:='        +Ini.ReadString('TDD', 'IDSmoothing',       '0')  +', _');
  end;
  if IntMethod='srfNaturalNeighbor' then begin
    WriteLn(script, '       AnisotropyRatio:='    +Ini.ReadString('TDD', 'AnisotropyRatio',   '1')  +', _');
    WriteLn(script, '       AnisotropyAngle:='    +Ini.ReadString('TDD', 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfNearestNeighbor' then begin
    WriteLn(script, '       SearchRad1:='         +Ini.ReadString('TDD', 'SearchRad1',        '1')  +', _');
    WriteLn(script, '       SearchRad2:='         +Ini.ReadString('TDD', 'SearchRad2',        '1')  +', _');
    WriteLn(script, '       SearchAngle:='        +Ini.ReadString('TDD', 'SearchAngle',       '0')  +', _');
  end;
  if IntMethod='srfMinCurvature' then begin
    WriteLn(script, '       MCMaxResidual:='      +Ini.ReadString('TDD', 'MCMaxResidual',     '1E-9')+', _');
    WriteLn(script, '       MCMaxIterations:='    +Ini.ReadString('TDD', 'MCMaxIterations',   '1E+5')+', _');
    WriteLn(script, '       MCInternalTension:='  +Ini.ReadString('TDD', 'MCInternalTension', '1')  +', _');
    WriteLn(script, '       MCBoundaryTension:='  +Ini.ReadString('TDD', 'MCBoundaryTension', '0')  +', _');
    WriteLn(script, '       MCRelaxationFactor:=' +Ini.ReadString('TDD', 'MCRelaxationFactor','0')  +', _');
    WriteLn(script, '       AnisotropyRatio:='    +Ini.ReadString('TDD', 'AnisotropyRatio',   '1')  +', _');
    WriteLn(script, '       AnisotropyAngle:='    +Ini.ReadString('TDD', 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfRadialBasis' then begin
    WriteLn(script, '       AnisotropyRatio:='    +Ini.ReadString('TDD', 'AnisotropyRatio',   '1')  +', _');
    WriteLn(script, '       AnisotropyAngle:='    +Ini.ReadString('TDD', 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfTriangulation' then begin
    WriteLn(script, '       AnisotropyRatio:='    +Ini.ReadString('TDD', 'AnisotropyRatio',   '1')  +', _');
    WriteLn(script, '       AnisotropyAngle:='    +Ini.ReadString('TDD', 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfInverseDistanse' then begin
    WriteLn(script, '       SearchMinData:='      +Ini.ReadString('TDD', 'SearchMinData',     '16') +', _');
    WriteLn(script, '       SearchRad1:='         +Ini.ReadString('TDD', 'SearchRad1',        '1')  +', _');
    WriteLn(script, '       SearchRad2:='         +Ini.ReadString('TDD', 'SearchRad2',        '1')  +', _');
    WriteLn(script, '       SearchAngle:='        +Ini.ReadString('TDD', 'SearchAngle',       '0')  +', _');
  end;
     WriteLn(Script, '  DupMethod:=srfDupNone, _');
     WriteLn(Script, '  ShowReport:=False, _');
     WriteLn(Script, '  OutGrid:=PathGRD)');
     WriteLn(Script, '');

//создание трансформированного грида
     WriteLn(Script, 'Surf.GridTransform(InGrid:=PathGRD, _');
     WriteLn(Script, '  Operation:=srfGridTransScale, _');
     WriteLn(Script, '  XScale:='+floattostr(kf_int)+', _');  //коэффициент трансформации
     WriteLn(Script, '  YScale:=1, _');
     WriteLn(Script, '  OutGrid:=PathGRD)');
     WriteLn(Script, '');


//сглаживание -> фильтрация
  if Ini.ReadInteger('TDD', 'Filter', 0)>0 then begin
     WriteLn(Script, 'Surf.GridFilter(InGrid:=PathGRD, _');
		 WriteLn(Script, '  Filter:=srfFilterGaussian, _');
		 WriteLn(Script, '  NumPasses:='+Ini.ReadString('TDD', 'Filter', '0')+', _');    //число прогонов из формы
		 WriteLn(Script, '  OutGrid:=PathGRD)');
     WriteLn(Script, '');
  end;

//добавление сдвига
    WriteLn(Script, 'Surf.GridTransform(InGrid:=PathGRD, _');
    WriteLn(Script, '  Operation:=srfGridTransOffset, _');
    WriteLn(Script, '  XOffset:='+floattostr(StartDate)+', _');
    WriteLn(Script, '  YOffset:=1, _');
    WriteLn(Script, '  OutGrid:=PathGRD)');
    WriteLn(Script, '');

if CountGap=0 then begin
//бланковка по вернему/нижнему минимальному/максимальному горизонтам
//внутри заданного временного интервала
     WriteLn(Script, 'Surf.GridBlank(InGrid:=PathGRD, _');
     WriteLn(Script, '  BlankFile:=pathBlnFile, _');
     WriteLn(Script, '  Outgrid:=PathGRD, _');
     WriteLn(Script, '  outfmt:=1)');
     WriteLn(Script, '');
end;

//NEW?
if CountGap>0 then begin
//бланковка по вернему/нижнему минимальному/максимальному горизонтам
//внутри заданного временного интервала
     WriteLn(Script, 'Surf.GridBlank(InGrid:=PathGRD, _');
     WriteLn(Script, '  BlankFile:=pathBlnFile, _');
     WriteLn(Script, '  Outgrid:=PathGRD, _');
     WriteLn(Script, '  outfmt:=1)');
     WriteLn(Script, '');
end;

 (* Строим основной плот, убираем верхние и боковые метки*)
    WriteLn(Script, 'Set ContourMapFrame=Doc.Shapes.AddContourMap(PathGRD)');
    WriteLn(Script, 'Set Axes = ContourMapFrame.Axes');
    WriteLn(Script, 'Set Axis = Axes("top axis")');
    WriteLn(Script, 'Axis.MajorTickType = srfTickNone');
    WriteLn(Script, 'Set Axis = Axes("right axis")');
    WriteLn(Script, 'Axis.MajorTickType = srfTickNone');
    WriteLn(Script, '');


 //   WriteLn(Script, 'Set contour1 = ContourMapFrame.Overlays("Contours") ');
 //   WriteLn(Script, '');

//post1->положение узлов на диаграмме
    WriteLn(Script, 'Set PostMap2=Doc.Shapes.AddPostMap(DataFileName:=pathDataFile, _');
    WriteLn(Script, '   xCol:=1, _');  //Реальное время
    WriteLn(Script, '   yCol:=3)');    //Глубина
    WriteLn(Script, 'Set sampleMarks = PostMap2.Overlays(1)');
    WriteLn(Script, '    With SampleMarks');
    WriteLn(Script, '        .LabCol='+inttostr(numcol));
    WriteLn(Script, '        .LabelFont.Size=4');
    WriteLn(Script, '        .Symbol.Index=15');
    WriteLn(Script, '        .Symbol.Size=0.03');
    WriteLn(Script, '        .Symbol.Color=srfColorBlue');
    WriteLn(Script, '        .Visible=False');
    WriteLn(Script, '        .LabelAngle=0');
    WriteLn(Script, '    End With');
    WriteLn(Script, '');
    WriteLn(Script, '');


//объединение объектов -> OverlayMaps
    WriteLn(Script, 'Doc.Shapes.SelectAll');
    WriteLn(Script, 'Set NewMap = Doc.Selection.OverlayMaps');
    WriteLn(Script, 'NewMap.xLength=20');
    WriteLn(Script, 'NewMap.yLength=10');

//фон->Background
   // WriteLn(Script, 'NewMap.BackgroundFill.Pattern = "6.25% Black"');
   // WriteLn(Script, 'NewMap.BackgroundFill.ForeColor = srfColorBlack30');

//определение положения левого нижнего угла
    WriteLn(Script, 'L = NewMap.Left');
    WriteLn(Script, 'B = NewMap.top-NewMap.Height');
    WriteLn(Script, 'Set ContourMap = NewMap.Overlays(1)');

//цветная заливка->FillContours
 if (cbLvl.Enabled) and (cblvl.ItemIndex>-1) and (cblvl.Text<>'') then begin
    WriteLn(Script, '   With ContourMap');
    WriteLn(Script, '     .Levels.LoadFile("'+GlobalPath+'support\lvl\'+cbLvl.Text+'")');
    WriteLn(Script, '     .FillContours = True');
    WriteLn(Script, '     .ShowColorScale = True');
    WriteLn(Script, '     .ColorScale.Top = NewMap.Top-0.2');
    WriteLn(Script, '     .ColorScale.Height = NewMap.Height-0.7');
    WriteLn(Script, '     .ColorScale.Left = NewMap.Left+NewMap.Width+0.4');
    WriteLn(Script, '    End With');
 end;

//масштабирование
    WriteLn(Script, 'Diagram.Zoom(srfZoomFitToWindow)');
    WriteLn(Script, 'Diagram.AutoRedraw = True');
    WriteLn(Script, '');
    WriteLn(Script, 'End Sub');
 finally
   Ini.Free;
 end;

 CloseFile(script);
 btnPlot.Enabled:=true;
end;


(* Временные серии на стандартных горизонтах, пишем в файлы *)
procedure Tfrmtimedepthdiagram.TimeSeriesAtLevels;
var
n,sdlev:integer;
timeTR,time1,val1,valSCR,an,anscr:real;
LookupRes:variant;
fName:string;
begin

    cdsSdLev:=TBufDataSet.Create(nil);
   with cdsSdLev.FieldDefs do begin
      Add('sdlev',ftInteger,0,false);
   end;
    cdsSdLev.CreateDataSet;
  //  cdsSdLev.LogChanges:=false;


   //определяем стандартные горизонты
    cdsTTDMonth.First;
{w}while not cdsTTDMonth.Eof do begin
    sdlev:=cdsTTDMonth.FieldByName('sdlev').AsInteger;

    cdsSdLev.Lookup('sdlev',sdlev,'sdlev');

    LookupRes:=cdsSdLev.Lookup('sdlev',sdlev,'sdlev');
    if VarIsNull(LookupRes) then begin
     cdsSdLev.Append;
     cdsSdLev.FieldByName('sdlev').AsFloat:=sdlev;
     cdsSdLev.Post;
    end;
    LookupRes:='';

     //writeln(dat_Month, TimeTR:10:5, -sdlev:8, time:12:5,
     // val:15:4,an:15:4,anSCR:15:4, n:8);

    cdsTTDMonth.Next;
{w}end;

    //пишем временные серии
     cdsSdLev.First;
{L}while not cdsSdLev.Eof do begin
    sdLev:=cdsSdLev.FieldByName('sdlev').AsInteger;

    cdsTTDMonth.Filter:='sdlev='+inttostr(sdlev);
    cdsTTDMonth.Filtered:=true;

    if sdLev=0 then fName:='0000';
    if Length(Inttostr(sdlev))=1 then fName:='000'+inttostr(sdlev);
    if Length(Inttostr(sdlev))=2 then fName:='00' +inttostr(sdlev);
    if Length(Inttostr(sdlev))=3 then fName:='0'  +inttostr(sdlev);
    if Length(Inttostr(sdlev))=4 then fName:=inttostr(sdlev);

    //Series at standard levels
    AssignFile(dat_sdlev, TDDPath+'SeriesAtSdLevelsMonthlyMean\'+fName+'.dat'); Rewrite(dat_sdlev);
    writeln(dat_sdlev,'time':12, 'val':9, 'valSCR':9, 'anom':9, 'anSCR':9, 'n':7);

{w}while not cdsTTDMonth.Eof do begin
    timeTR :=cdsTTDMonth.FieldByName('timeTR').AsFloat;
    sdlev  :=cdsTTDMonth.FieldByName('sdlev').AsInteger;
    time1  :=cdsTTDMonth.FieldByName('time').AsFloat;
    val1   :=cdsTTDMonth.FieldByName('val').AsFloat;
    valSCR :=cdsTTDMonth.FieldByName('valSCR').AsFloat;
    an     :=cdsTTDMonth.FieldByName('an').AsFloat;
    anSCR  :=cdsTTDMonth.FieldByName('anSCR').AsFloat;
    n      :=cdsTTDMonth.FieldByName('n').AsInteger;

    writeln(dat_sdlev, time1:12:5, val1:9:3,valSCR:9:3,an:9:3,anscr:9:3,n:7);

    cdsTTDMonth.Next;
{w}end;
     closefile(dat_sdlev);
     cdsSdLev.Next;
{L}end;

  //  cdsSdLev.EmptyDataSet;
    cdsSdLev.Free;
end;



//output
//time series at standard levels
//initial interpolated profiles
procedure Tfrmtimedepthdiagram.TimeSeriesAtLevels_Prf;
var
n,sdlev,absnum:integer;
year,month,hour,min:word;
timePRF,val,valSCR,an,anscr:real;
LookupRes:variant;
prfdate,prftime:TDateTime;
ftemp:string;
begin
    cdsSdLev:=TBufDataSet.Create(nil);
   with cdsSdLev.FieldDefs do begin
      Add('sdlev',ftInteger,0,false);
   end;
    cdsSdLev.CreateDataSet;
  //  cdsSdLev.LogChanges:=false;


   //определяем стандартные горизонты
    TDDcds.First;
{w}while not TDDcds.Eof do begin
    sdlev:=TDDcds.FieldByName('lev').AsInteger;

    cdsSdLev.Lookup('sdlev',sdlev,'sdlev');

    LookupRes:=cdsSdLev.Lookup('sdlev',sdlev,'sdlev');
    if VarIsNull(LookupRes) then begin
     cdsSdLev.Append;
     cdsSdLev.FieldByName('sdlev').AsFloat:=sdlev;
     cdsSdLev.Post;
    end;
    LookupRes:='';
    TDDcds.Next;
{w}end;


    //пишем временные серии
     cdsSdLev.First;
{L}while not cdsSdLev.Eof do begin
    sdLev:=cdsSdLev.FieldByName('sdlev').AsInteger;

    TDDcds.Filter:='lev='+inttostr(sdlev);
    TDDcds.Filtered:=true;


    if sdLev=0 then ftemp:='0000';
    if Length(Inttostr(sdlev))=1 then ftemp:='000'+inttostr(sdlev);
    if Length(Inttostr(sdlev))=2 then ftemp:='00' +inttostr(sdlev);
    if Length(Inttostr(sdlev))=3 then ftemp:='0'  +inttostr(sdlev);
    if Length(Inttostr(sdlev))=4 then ftemp:=inttostr(sdlev);

    //Series at standard levels
    AssignFile(dat_sdlevPrf, TDDPath+'SeriesAtSdLevelsInitialPrf\'+ftemp+'.dat'); Rewrite(dat_sdlevPrf);
    writeln(dat_sdlevPrf,'time_tr':12, 'val':10, 'absnum':10, 'Date':12, 'Time':10);

{w}while not TDDcds.Eof do begin

   absnum:=TDDCDS.FieldByName('absnum').asInteger;
   prfdate:=TDDCDS.FieldByName('date').AsDateTime;
   prftime:=TDDCDS.FieldByName('time').asDateTime;
   sdlev:=TDDCDS.FieldByName('lev').asInteger;
   Val:=TDDCDS.FieldByName('Val').asfloat;
   year:=TDDCDS.FieldByName('year').asInteger;
   Month:=TDDCDS.FieldByName('month').asInteger;
   Hour:=TDDCDS.FieldByName('hour').asInteger;
   Min:=TDDCDS.FieldByName('min').asInteger;

        timePRF:=TDDCDS.FieldByName('year').asInteger+
               (TDDCDS.FieldByName('month').asInteger-1)/12+
               TDDCDS.FieldByName('day').asInteger/365+
               TDDCDS.FieldByName('hour').asInteger/(24*365)+
               TDDCDS.FieldByName('min').asInteger/(3600*365);

    writeln(dat_sdlevPrf,timePRF:12:5,val:10:3,absnum:10,datetostr(prfdate):12,
            timetostr(prftime):10);

    TDDcds.Next;
{w}end;
     closefile(dat_sdlevPrf);
     cdsSdLev.Next;
{L}end;

  //  cdsSdLev.EmptyDataSet;
    cdsSdLev.Free;
end;



(* Берем средние профили и вычитаем последовательно месяцы *)
procedure Tfrmtimedepthdiagram.MonthsDifference;
Var
k, c:integer;
timetr, date1, date_old, lev, val1, val_old:real;
fdb:TSearchRec;
Path:string;
DateMin, DateMax, LevMin, LevMax, DateMid:real;
begin
 //Загружаем список файлов
  path:=TDDPath+'SeriesAtSdLevelsMonthlyMean\';
   fdb.Name:='';
   lbMonthlyLevels.Clear;
    FindFirst(Path+'*.dat',faAnyFile, fdb);
   if fdb.Name<>'' then lbMonthlyLevels.Items.Add(fdb.Name);
  while findnext(fdb)=0 do lbMonthlyLevels.Items.Add(fdb.Name);


  AssignFile(dat1, TDDPath+'Month_dif.dat'); Rewrite(dat1);
  Writeln(dat1, 'Date':15, 'lev':10, 'valDif':10);

  for k:=0 to lbMonthlyLevels.Count-1 do begin
   AssignFile(dat, Path+lbMonthlyLevels.Items.Strings[k]); Reset(dat);
    Lev:=StrToFloat(Copy(lbMonthlyLevels.Items.Strings[k],1,4));
    readln(dat); c:=0;
     repeat
      inc(c);
       readln(dat, date1,  val1);
        if c=1 then begin
          date_old:=Date1;
          val_old:=val1;
        end;
        if c>1 then begin
        //  if Date1-Date_old<=0.2 then begin //Если разница по времени больше 2х месяцев - пропускаем
             writeln(dat1, Date_old:15:5, -lev:10:1, (Val_old-Val1):10:3);
          Val_old:=Val1;
          Date_old:=Date1;
        end;
     until eof(dat);
    Closefile(dat);
  end;
 CloseFile(dat1);
end;



procedure Tfrmtimedepthdiagram.MeanByYear;
Var
YCDS:TBufDataSet;
k, c, YY, YY_old, count:integer;
Path:string;
timetr, date1, lev, val1, val_old, lev1:real;
ValMean, Sum:real;
fdb:TSearchRec;
DateMin, DateMax, LevMin, LevMax, DateMid:real;
begin
 (* Загружаем список файлов *)
  path:=TDDPath+'SeriesAtSdLevelsMonthlyMean\';
   fdb.Name:='';
   lbMonthlyLevels.Clear;
    FindFirst(Path+'*.dat',faAnyFile, fdb);
   if fdb.Name<>'' then lbMonthlyLevels.Items.Add(fdb.Name);
  while findnext(fdb)=0 do lbMonthlyLevels.Items.Add(fdb.Name);


  AssignFile(dat1, TDDPath+'Year.dat'); Rewrite(dat1);
  Writeln(dat1, 'Date':15, 'lev':10, 'YearVal':10, 'YearAnom':10);

  for k:=0 to lbMonthlyLevels.Count-1 do begin
    Lev:=StrToFloat(Copy(lbMonthlyLevels.Items.Strings[k],1,4));

    YCDS:=TBufDataSet.Create(nil);
     with YCDS.FieldDefs do begin
       Add('year',ftInteger ,0 ,false);
       Add('n'   ,ftFloat   ,0 ,false);
       Add('md'  ,ftFloat   ,0 ,false);
     end;
    YCDS.CreateDataSet;
   // YCDS.LogChanges:=false;

    AssignFile(dat, Path+lbMonthlyLevels.Items.Strings[k]); Reset(dat);
    readln(dat);

    c:=0; Sum:=0;
    Count:=0;
     repeat
      inc(c);
       readln(dat, date1,  val1);
      (* Для одного горизонта *)
       YY:=trunc(date1);
        if c=1 then YY_old:=YY;
        if YY_old=YY then begin
         Sum:=Sum+Val1;
         inc(Count);
        end;

        if (YY_old<>YY) or (eof(dat)) then begin
          with YCDS do begin
           Append;
             FieldByName('year').AsFloat:=YY_old;
             FieldByName('n').AsFloat:=Count;
             FieldByName('md').AsFloat:=Sum/Count;
           Post;
          end;
          Sum:=Val1; Count:=1;
          YY_old:=YY;
        end;
     until eof(dat);
    Closefile(dat);

       Sum:=0; Count:=0;
        YCDS.first;
        while not YCDS.Eof do begin
         YY  :=YCDS.FieldByName('year').AsInteger;
         Val1:=YCDS.FieldByName('md').AsFloat;
          if (YY>=seYY1.Value) and (YY<=seYY2.Value) then begin
            Sum:=Sum+Val1;
            inc(count);
          end;
         YCDS.Next;
        end;

     if count>0 then begin
       ValMean:=sum/Count; //Среднее для горизонта за указанныйпериод

        YCDS.first;
        while not YCDS.Eof do begin
         YY  :=YCDS.FieldByName('year').AsInteger;
         Val1:=YCDS.FieldByName('md').AsFloat;
            Writeln(dat1, YY:15, -lev:10:0, Val1:10:3, (Val1-ValMean):10:3);
         YCDS.Next;
        end;
     end;
      YCDS.Free;
  end;
 CloseFile(dat1);
end;


procedure Tfrmtimedepthdiagram.cbParametersSelect(Sender: TObject);
begin
  btnPlot.Enabled:=true;
  btnOpenScript.Enabled:=true;
end;


procedure Tfrmtimedepthdiagram.cbParametersChange(Sender: TObject);
begin
   numcol:=cbParameters.ItemIndex+4;
  // showmessage('numcol='+inttostr(numcol));
end;


procedure Tfrmtimedepthdiagram.btnOpenFolderClick(Sender: TObject);
begin
   OpenDocument(PChar(TDDPath)); { *Converted from ShellExecute* }
end;


procedure Tfrmtimedepthdiagram.btnOpenScriptClick(Sender: TObject);
Var
ScriptFile:string;
begin
 //GetScript; // Пересоздаем скрипт
 GetScriptSmooth;
 ScriptFile:=TDDPath+'Script.bas';
  if FileExists(ScriptFile) then  OpenDocument(PChar(ScriptFile)); { *Converted from ShellExecute* }
end;


procedure Tfrmtimedepthdiagram.btnSettingsClick(Sender: TObject);
begin
frmsurfersettings:=Tfrmsurfersettings.Create(Self);
 frmsurfersettings.LoadSettings('TDD');
  try
   if not frmsurfersettings.ShowModal = mrOk then exit;
  finally
    frmsurfersettings.Free;
    frmsurfersettings := nil;
  end;
end;


procedure Tfrmtimedepthdiagram.btnPlotClick(Sender: TObject);
var
cmd, Scripter:string;
StartupInfo:  TStartupInfo;
//ProcessInfo:  TProcessInformation;
Ini:TIniFile;
begin
if cbParameters.itemIndex=-1 then exit;

 GetScriptSmooth;

  Ini := TIniFile.Create(IniFileName); // settings from file
  try
   scripter:=Ini.ReadString('Main', 'SurferPath', '');
  finally
    Ini.Free;
  end;

{ If FileExists(Scripter)=false then
   if MessageDlg('Check Surfer Scripter path', mtWarning, [mbOk], 0)=mrOk then begin
    Preferences:= TPreferences.Create(Self);
     Preferences.pcPreferences.ActivePageIndex:=0;
     try
      if  Preferences.ShowModal = mrOk then
     finally
      Preferences.Free;
      Preferences := nil;
     end;
   exit;
  end; }

 (*Запуск скрипта на исполнение*)
 { cmd:=Concat('"'+Scripter, '"', ' -x ', '"', TDDPath+'script.bas"');
  Fillchar(startupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb:=Sizeof(StartupInfo);
   if CreateProcess(nil, Pchar(cmd), nil, nil, false,
      CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then begin
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      FileClose(ProcessInfo.hProcess); { *Converted from CloseHandle* }
   end; }
end;


{procedure Tfrmtimedepthdiagram.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  isNew:=true;
  TDDOpen:=false;
end;}

end.
