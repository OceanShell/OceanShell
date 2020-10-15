unit ostimedepthdiagram;

{$mode objfpc}{$H+}

interface

uses  LCLIntf, LCLType, SysUtils, Variants, Classes,
      Graphics, Controls, Forms, StdCtrls, ExtCtrls, BufDataset, IniFiles,
      SQLDB, DB, Dialogs, DateUtils, Buttons, Spin, ComCtrls, Math;

type

  { Tfrmtimedepthdiagram }

  Tfrmtimedepthdiagram = class(TForm)
    btnGetData: TButton;
    btnPlot: TButton;
    rgVariable: TRadioGroup;
    rgDataFile: TRadioGroup;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    SEYY1: TSpinEdit;
    SEYY2: TSpinEdit;
    mLog: TMemo;
    lbMonthlyLevels: TListBox;
    Memo1: TMemo;
    btnSettings: TButton;
    btnOpenFolder: TBitBtn;
    btnOpenScript: TBitBtn;

    procedure FormShow(Sender: TObject);
    procedure btnPlotClick(Sender: TObject);
    procedure rgDataFileClick(Sender: TObject);
    procedure cbParametersSelect(Sender: TObject);

    procedure btnGetDataClick(Sender: TObject);

    procedure btnSettingsClick(Sender: TObject);
    procedure btnOpenFolderClick(Sender: TObject);
    procedure btnOpenScriptClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

  private

    procedure ClearAllRecords(ADataset: TBufDataset);
    procedure GetExactRecordCount(ADataset: TBufDataset; Var RecCnt:integer);

    procedure InitialDataFromDB;
    procedure MeanByMonthOnStandardLevels;
    procedure InitialDataOnStandardLevels;
    procedure SeasonalCycleRemoval;
    procedure BlnFileByData;
    procedure MeanProfileNoSeasons;
    procedure MonthlyMeanAndAnomaliesToFile;
    procedure AnnualMean;
    procedure MonthsDifference;
    procedure TimeSeriesAtLevels;

  public
    { Public declarations }
  end;

var
  frmtimedepthdiagram: Tfrmtimedepthdiagram;
  TDDPath, CurrentFile:string;

  TDDCDS, MCDS, cdsTTDMonth, cdsMeanPrf:TBufDataSet;

  Units_default: integer;
  Units_default_name, Parameter_name: string;

implementation

uses osmain, dm, surfer_settings, surfer_tdd, osunitsconversion,
     osverticalinterpolation;

{$R *.lfm}


procedure Tfrmtimedepthdiagram.ClearAllRecords(ADataset: TBufDataset);
begin
  ADataset.DisableControls;
  try
    ADataset.First;
    while not ADataset.EoF do
      ADataset.Delete;
  finally
    ADataset.EnableControls;
  end;
end;


procedure Tfrmtimedepthdiagram.GetExactRecordCount(ADataset: TBufDataset;
  Var RecCnt:integer);
begin
  RecCnt := 0;
  with ADataset do begin
    First;
    while not(EOF) do begin
      inc(RecCnt);
      Next;
    end;
  end;
end;


procedure Tfrmtimedepthdiagram.FormShow(Sender: TObject);
Var
 k: integer;
 Ini:TIniFile;

 Qt:TSQLQuery;
 TRt:TSQLTransaction;
begin
  memo1.Clear;
  mLog.clear;

 (* Устанавливаем пути *)
 TDDPath:=GlobalPath+'unload'+PathDelim+'tddiagrams'+PathDelim; // в папку с именем базы
 if not DirectoryExists(TDDPath) then CreateDir(TDDPath);
 if not DirectoryExists(TDDPath+'MonthlyProfiles'+PathDelim) then CreateDir(TDDPath+'MonthlyProfiles'+PathDelim);
 if not DirectoryExists(TDDPath+'SeriesAtSdLevelsInitial'+PathDelim) then CreateDir(TDDPath+'SeriesAtSdLevelsInitialPrf'+PathDelim);
 if not DirectoryExists(TDDPath+'SeriesAtSdLevelsMonthlyMean'+PathDelim) then CreateDir(TDDPath+'SeriesAtSdLevelsMonthlyMean'+PathDelim);

 (* Creading global client datasets *)
  TDDCDS:=TBufDataSet.Create(nil);
   with TDDCDS.FieldDefs do begin
      Add('ID'       ,ftInteger  ,0 ,false);
      Add('date_dec' ,ftFloat    ,0 ,false);
      Add('date_date',ftDateTime ,0 ,false);
      Add('yy'       ,ftInteger  ,0 ,false);
      Add('mn'       ,ftInteger  ,0 ,false);
      Add('dd'       ,ftInteger  ,0 ,false);
      Add('hh'       ,ftInteger  ,0 ,false);
      Add('mm'       ,ftInteger  ,0 ,false);
      Add('ss'       ,ftInteger  ,0 ,false);
      Add('lev'      ,ftInteger  ,0 ,false);
      Add('val'      ,ftFloat    ,0 ,false);
      Add('anom'     ,ftFloat    ,0 ,false);
   end;
  TDDCDS.CreateDataSet;

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


  cdsMeanPrf:=TBufDataSet.Create(nil);
   with cdsMeanPrf.FieldDefs do begin
      Add('lev'    ,ftInteger ,0 ,false);
      Add('n'      ,ftInteger ,0 ,false);
      Add('val'    ,ftFloat   ,0 ,false);
      Add('valSCR' ,ftFloat   ,0 ,false);
   end;
  cdsMeanPrf.CreateDataSet;

  Ini := TIniFile.Create(IniFileName);
   try
    seYY1.Value:=Ini.ReadInteger('tdd', 'YearMin', 1957);
    seYY2.Value:=Ini.ReadInteger('tdd', 'YearMax', 1990);
   finally
    Ini.Free;
   end;

  try
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

   with Qt do begin
    Close;
       SQL.Clear;
       SQL.Add(' SELECT ');
       SQL.Add(' DATABASE_TABLES.UNITS_ID_DEFAULT, ');
       SQL.Add(' DATABASE_TABLES.NAME, ');
       SQL.Add(' UNITS.NAME_SHORT FROM ');
       SQL.Add(' DATABASE_TABLES, UNITS WHERE  ');
       SQL.Add(' DATABASE_TABLES.UNITS_ID_DEFAULT=UNITS.ID AND  ');
       SQL.Add(' DATABASE_TABLES.NAME_TABLE='+QuotedStr(CurrentParTable));
      Open;
       Parameter_name:=Qt.FieldByName('NAME').AsString;
       Units_default:=Qt.FieldByName('UNITS_ID_DEFAULT').AsInteger;
       Units_default_name:=Qt.FieldByName('NAME_SHORT').AsString;
      Close;
   end;
   Trt.Commit;
  finally
   Qt.Free;
   Trt.Free;
  end;

 rgDataFile.Enabled:=false;
end;


procedure Tfrmtimedepthdiagram.btnGetDataClick(Sender: TObject);
var
  TimeStart0:TDateTime;
begin
 btnGetData.Enabled:=false;

 mLog.Clear;
 TimeStart0:=Now; //the very beginning of calculations

 mLog.Lines.Add('Start: '+TimeToStr(now));

 (* Cleaning up client datasets *)
 ClearAllRecords(TDDCDS);
 ClearAllRecords(MCDS);
 ClearAllRecords(cdsTTDMonth);
 ClearAllRecords(cdsMeanPrf);

  InitialDataFromDB;           // Unloading initial data into text

  MeanByMonthOnStandardLevels; // Calculating mean monthly values on standard levels

  InitialDataOnStandardLevels; // Unloading data on standard levels

  SeasonalCycleRemoval;        // Removing seasonal cycle

  BlnFileByData;               // Creating blank file

  MeanProfileNoSeasons;

  MonthlyMeanAndAnomaliesToFile;

  TimeSeriesAtLevels;          //unloading data to files by standard levels

  MonthsDifference;

  AnnualMean;


 mLog.Lines.Add('==================');
 mLog.Lines.Add('Done! Time spent: '+Timetostr(Now-TimeStart0));
 Application.ProcessMessages;

 rgDataFile.Enabled:=true;
 btnGetData.Enabled:=true;

 if rgDataFile.ItemIndex<>-1 then rgDataFile.OnClick(self);
end;


(* Exctracting data from DB and interpolating onto standard levels *)
procedure Tfrmtimedepthdiagram.InitialDataFromDB;
Var
  Ini: TIniFile;
  PQF1_st, PQF2_st, SQF_st, instr_st:string; // QC flags and instruments

  dat_real, dat_int:text; //output files

  Qt:TSQLQuery;
  TRt:TSQLTransaction;

  StDateAndTime: TDateTime;
  StLat:real;

  ID, k, fi, i, units: integer;
  yy, mn, dd, hh, mm, ss, ms:word;

  P, D: array of real; //arrays for pressure (P) and depth (D)
  date_dec, lev_m, lev_d, lev, val1, val_out:real;
  IntLev: integer;
  IntVal: real;

  isconverted, isinterpolated: boolean;
  TimeStart:TDateTime;
begin
 TimeStart:=now;

(* Читаем настройки из файла *)
 try
   Ini := TIniFile.Create(IniFileName);
    depth_units:=Ini.ReadInteger('main', 'depth_units', 0);

    Ini.ReadSection('standard_levels', memo1.Lines);

    if memo1.Lines.Count=0 then begin
      Ini.WriteString('standard_levels','0','');
      Ini.WriteString('standard_levels','10','');
      Ini.WriteString('standard_levels','20','');
      Ini.WriteString('standard_levels','30','');
      Ini.WriteString('standard_levels','50','');
      Ini.WriteString('standard_levels','75','');
      Ini.WriteString('standard_levels','100','');
      Ini.WriteString('standard_levels','125','');
      Ini.WriteString('standard_levels','150','');
      Ini.WriteString('standard_levels','200','');
      Ini.WriteString('standard_levels','250','');
      Ini.WriteString('standard_levels','300','');
      Ini.WriteString('standard_levels','400','');
      Ini.WriteString('standard_levels','500','');
      Ini.WriteString('standard_levels','600','');
      Ini.WriteString('standard_levels','700','');
      Ini.WriteString('standard_levels','800','');
      Ini.WriteString('standard_levels','900','');
      Ini.WriteString('standard_levels','1000','');
      Ini.WriteString('standard_levels','1100','');
      Ini.WriteString('standard_levels','1200','');
      Ini.WriteString('standard_levels','1300','');
      Ini.WriteString('standard_levels','1400','');
      Ini.WriteString('standard_levels','1500','');
      Ini.WriteString('standard_levels','1750','');
      Ini.WriteString('standard_levels','2000','');
      Ini.WriteString('standard_levels','2500','');
      Ini.WriteString('standard_levels','3000','');
      Ini.WriteString('standard_levels','3500','');
      Ini.WriteString('standard_levels','4000','');
      Ini.WriteString('standard_levels','4500','');
      Ini.WriteString('standard_levels','5000','');
      Ini.WriteString('standard_levels','5500','');

      Ini.ReadSection('standard_levels', memo1.Lines);
    end;

   PQF1_st:='';
   for k:=0 to 8 do
    if Ini.ReadBool('osparameters_list', 'PQF1_'+inttostr(k), true) then
      PQF1_st:=PQF1_st+','+inttostr(k);
   PQF1_st:=copy(PQF1_st, 2, length(PQF1_st));

   PQF2_st:='';
   for k:=0 to 8 do
    if Ini.ReadBool('osparameters_list', 'PQF2_'+inttostr(k), true) then
      PQF2_st:=PQF2_st+','+inttostr(k);
   PQF2_st:=copy(PQF2_st, 2, length(PQF2_st));

   SQF_st:='';
   for k:=0 to 1 do
    if Ini.ReadBool('osparameters_list', 'SQF_'+inttostr(k), true) then
      SQF_st:=SQF_st+','+inttostr(k);
   SQF_st:=copy(SQF_st, 2, length(SQF_st));

   instr_st:='';
   for k:=0 to 17 do
    if Ini.ReadBool('osparameters_list', 'Instrument'+inttostr(k), true) then
      instr_st:=instr_st+','+inttostr(k);

  finally
   Ini.Free;
  end;

  if (trim(PQF1_st)='') or (trim(PQF2_st)='') or (trim(SQF_st)='') then
   if MessageDlg('Please, set QC flags', mtWarning, [mbOk], 0)=mrOk then exit;


  instr_st:=copy(instr_st, 2, length(instr_st));
   if trim(instr_st)='' then
    if MessageDlg('Select at least one instrument', mtWarning, [mbOk], 0)=mrOk then exit;

  frmdm.Q.IndexFieldNames:='dateandtime'; //force sorting

  try
  // Assigning output files
  AssignFile(dat_real, TDDPath+'Real.dat');  Rewrite(dat_real); // real data
  writeln(dat_real, 'Date':10, 'lev':10, 'val':10, 'ID':10, 'date':11, 'time':9);

   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

 frmdm.Q.First;
 while not frmdm.Q.Eof do begin //w
  ID:=frmdm.Q.fieldByName('ID').Value;
  StDateAndTime:=frmdm.Q.fieldByName('DATEANDTIME').Value;
  StLat:=frmdm.Q.fieldByName('LATITUDE').Value;

  DecodeDateTime(StDateAndTime, yy, mn, dd, hh, mm, ss, ms);

  date_dec:=yy+(mn-1)/12+
            dd/DaysInAYear(yy)+
            hh/(24*DaysInAYear(yy))+
            mm/(3600*DaysInAYear(yy))+
            ss/(3600*60*DaysInAYear(yy));


   with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT LEV_DBAR, LEV_M, VAL, UNITS_ID ');
      SQL.Add(' FROM '+ CurrentParTable );
      SQL.Add(' WHERE ID=:ID AND ');
      SQL.Add(' PQF1 IN ('+PQF1_st+') AND ');
      SQL.Add(' PQF2 IN ('+PQF2_st+') AND ');
      SQL.Add(' SQF  IN ('+SQF_st+')  AND ');
      SQL.Add(' INSTRUMENT_ID IN ('+instr_st+') AND ');
      SQL.Add(' PROFILE_BEST=TRUE ');
      SQL.Add(' ORDER BY LEV_DBAR, LEV_M ');
      ParamByName('ID').AsInteger:=ID;
     Open;
     Last;
     First;
    end;

    SetLength(P, Qt.RecordCount);
    SetLength(D, Qt.RecordCount);

    k:=0;
    while not Qt.eof do begin
     lev_m :=Qt.FieldByName('LEV_M').AsFloat;
     lev_d :=Qt.FieldByName('LEV_DBAR').AsFloat;
     val1  :=Qt.FieldByName('VAL').AsFloat;
     units :=Qt.FieldByName('UNITS_ID').AsInteger;

     (* units for the vertical axis *)
     if depth_units=0 then lev:=lev_m else lev:=lev_d;

     (* units conversion *)
     if units<>units_default then begin
       osunitsconversion.GetDefaultUnits(CurrentParTable, units, units_default, val1, val_out, isconverted);
         if isConverted=true then val1:=val_out else val1:=-9999;
     end;

     if val1<>-9999 then begin
         D[k]:=Lev;
         P[k]:=Val1;
       inc(k);
     end;
    Qt.Next;
  end;


(* Initial data to real.dat  *)
  for fi:=0 to k-1 do
     writeln(dat_real, date_dec:10:5,  //date (decimal)
                       D[fi]:10:3,     //depth
                       P[fi]:10:3,     //value
                       ID:10,          //id
                       datetostr(stdateandtime):11,  //date
                       timetostr(stdateandtime):9); //time

 // showmessage(inttostr(k));


(* interpolation onto standard levels *)
 for fi:=0 to memo1.Lines.Count-1 do begin
   IntLev:=strtoint(Memo1.Lines.Strings[fi]);
  // showmessage(inttostr(intlev));
   IntVal:=-999;
   for i:=0 to k-1 do begin
     isinterpolated:=false;

     if (IntLev=0) and (D[i]<5) then begin
       IntVal:=P[i];
        isinterpolated:=true;
       break;
     end;

     if D[i]=IntLev then begin
       IntVal:=P[i];
       isinterpolated:=true;
      break;
     end;

     try  // trying to interpolate
     if (IntLev>D[i]) and (IntLev<D[i+1]) then begin
           //c - number of levels at profile;  i - sequential number of level
                                                  //       LU1     LU2    X      LD1      LD2     ->
       if (fi=2)              then ODBPr_VertInt(IntLev, -9,     D[i], D[i+1], -9,      -9,     P[i], P[i+1], -9,      IntVal, isinterpolated); //x + + x
       if (fi>2) and (i=1)    then ODBPr_VertInt(IntLev, -9,     D[i], D[i+1], D[i+2],  -9,     P[i], P[i+1], P[i+2],  IntVal, isinterpolated); //x + + +
       if (fi>2) and (i=fi-1) then ODBPr_VertInt(IntLev, D[i-1], D[i], D[i+1], -9,      P[i-1], P[i], p[i+1], -9,      IntVal, isinterpolated); //+ + + x
       if (fi>3) and (i<>1)  and (i<>fi-1)
                              then ODBPr_VertInt(IntLev, D[i-1], D[i], D[i+1], D[i+2],  P[i-1], P[i], P[i+1], P[i+2],  IntVal, isinterpolated); //+ + + +
       if isinterpolated=true then  break;
     end;
     except
       isinterpolated:=false;
     end;
   end;

     if (isinterpolated=true) and (IntVal<>-999) then begin
       with TDDCDS do begin
         Append;
           FieldByName('ID').AsInteger  :=ID;
           FieldByName('date_dec').AsFloat:=date_dec;
           FieldByName('date_date').AsDateTime :=stdateandtime;
           FieldByName('yy').AsInteger  :=yy;
           FieldByName('mn').AsInteger  :=mn;
           FieldByName('dd').AsInteger  :=dd;
           FieldByName('hh').AsInteger  :=hh;
           FieldByName('mm').AsInteger  :=mm;
           FieldByName('ss').AsInteger  :=ss;
           FieldByName('lev').AsInteger :=IntLev;
           FieldByName('val').AsFloat   :=IntVal;
         Post;
       end;
    end;
  end;

  // showmessage(inttostr(k));
 frmdm.Q.Next;
 end;  //w

 finally
  Trt.Commit;
  Qt.Close;
  Qt.Free;
  Trt.Free;

  CloseFile(dat_real);
  frmdm.Q.EnableControls;
 end;

mLog.Lines.Add('1. Initial data unloaded from database ('+timetostr(Now-TimeStart)+')');
Application.ProcessMessages;
end;

(* Monthly mean values on Standard levles *)
procedure Tfrmtimedepthdiagram.MeanByMonthOnStandardLevels;
Var
k, Lev, c, count:integer;
Mean, Val, Mean2:real;
vmd, vsd0, vsd, min, max, val1:real;
MonthlyProfilesFileName:string;
dat_m:text;
TimeStart:TDateTime;
begin
TimeStart:=now;

  for c:=0 to memo1.Lines.Count-1 do begin
   MCDS.Append;
    MCDS.FieldByName('level').AsInteger:=strtoint(Memo1.Lines.Strings[c]);
   MCDS.Post;
  end;


for k:=1 to 12 do begin
 for c:=0 to memo1.Lines.Count-1 do begin
   lev:=strtoint(Memo1.Lines.Strings[c]);

   // anomalies for user specified period
   TDDCDS.Filter:='Lev='+Memo1.Lines.Strings[c]+ ' and mn='+inttostr(k)+
                  ' and yy>='+SeYY1.Text+' and yy<='+SeYY2.Text; //Диапазон лет

   TDDCDS.Filtered:=true;
   TDDCDS.First;

   GetExactRecordCount(TDDCDS, Count);
  // mlog.Lines.add(inttostr(k)+'   '+inttostr(lev)+'   '+inttostr(count));

   if Count>0 then begin
    mean:=0; mean2:=0; val:=0;
    min:=9999; max:=-9999; vsd:=0; vmd:=0;

    TDDCDS.First;
    while not TDDCDS.Eof do begin
      val1:=TDDCDS.FieldByName('Val').asfloat;

      if val1>max then max:=val1;
      if val1<min then min:=val1;

      Mean:=Mean+Val1;
      mean2:=mean2+(Val1*Val1);
      TDDCDS.Next;
     end;

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
    {  showmessage(inttostr(k)+'   '+inttostr(lev)+'   '+
                  floattostr(MCDS.FieldByName(inttostr(k)+'_md').Asfloat)+'   '+
                  floattostr(MCDS.FieldByName(inttostr(k)+'_max').Asfloat)); }
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
      if not VarIsNull(MCDS.FieldByName(inttostr(k)+'_md').AsVariant) then begin
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

 mLog.Lines.Add('2. Monthly mean values calculated ('+timetostr(Now-TimeStart)+')');
 Application.ProcessMessages;
end;

(* Unloading data interpolated onto standard levels *)
procedure Tfrmtimedepthdiagram.InitialDataOnStandardLevels;
Var
dat_int:text;
ID, mn: integer;
lev, val1, date_dec, anom: real;
date_date:TDateTime;
TimeStart:TDateTime;
begin
TimeStart:=now;

try
  AssignFile(dat_int,  TDDPath+'StLev.dat'); Rewrite(dat_int);  // interpolated onto st. levels
  writeln(dat_int,  'Date_dec':10, 'Level':10, 'Value':10, 'Anomaly':10, 'ID':10, 'Date':11, 'Time':9);

  TDDCDS.first;
 while not TDDCDS.Eof do begin  //w
  ID       :=TDDCDS.FieldByName('ID').Value;
  date_dec :=TDDCDS.FieldByName('date_dec').Value;
  date_date:=TDDCDS.FieldByName('date_date').Value;
  lev      :=TDDCDS.FieldByName('lev').Value;
  val1     :=TDDCDS.FieldByName('val').Value;
  mn       :=TDDCDS.FieldByName('mn').Value;


  if not VarIsNull(MCDS.Locate('level', floattostr(lev),[])) and
     not VarIsNull(MCDS.FieldByName(inttostr(mn)+'_md').AsVariant) then begin

      anom:=Val1-MCDS.FieldByName(inttostr(mn)+'_md').Asfloat;

      with TDDCDS do begin
       Edit;
          FieldByName('anom').Value:=anom;
        Post;
      end;

   // Пишем файл на стандартных горизонтах
    writeln(dat_int, date_dec:10:5,
                     lev:10:0,
                     val1:10:3,
                     anom:10:3,
                     ID:10,
                     datetostr(date_date):11,
                     timetostr(date_date):9);
  end; //if not empty

   TDDCDS.Next;
  end;  //w
 finally
  CloseFile(dat_int);  //Закрываем файл на ст. горизонтах
 end;

 mLog.Lines.Add('3. Data on standard levels unloaded ('+timetostr(Now-TimeStart)+')');
 Application.ProcessMessages;
end;

(* Removing seasonal cycle *)
procedure Tfrmtimedepthdiagram.SeasonalCycleRemoval;
Var
  dat:text;
  i, mik, mik_lev, y, m, dSum, dYear, c, n: integer;
  lev: integer;
  yy, mn, dd: word;
  ymin, ymax, lmin, lmax, sdlev, ULev, DLev:integer;


  x1, x2, kf_int, x, val1, anom, valSCR, TimeTR: real;

  yb,mb,db,ye,me,de:word;
  date1, date2, dateb,datee:TDateTime;

  st_ex:boolean;
  TimeStart, stdt, dmin, dmax:TDateTime;
begin
 TimeStart:=now;

 AssignFile(dat,  TDDPath+'blank.dat'); Rewrite(dat); //text file with uppest and lowest levels
 writeln(dat, 'Date_dec':10, 'ULev':10, 'DLev':10);


 TDDcds.First;
 mik:=0;
  while not TDDCDS.Eof do begin  //w
    mik:=mik+1;
    stdt:=TDDCDS.FieldByName('date_date').asDateTime;
    yy  :=TDDCDS.FieldByName('yy').asInteger;
    lev :=TDDCDS.FieldByName('lev').asInteger;

    if mik=1 then begin
      dmin:=stdt; dmax:=stdt;
      ymin:=yy;   ymax:=yy;
      lmin:=lev;  lmax:=lev;
   end;

   if stdt<dmin then dmin:=stdt;
   if stdt>dmax then dmax:=stdt;

   if yy<ymin then ymin:=yy;
   if yy>ymax then ymax:=yy;

   if lev<lmin then lmin:=lev;
   if lev>lmax then lmax:=lev;

  TDDCDS.Next;
 end; //w

// showmessage('calculated max/min');

{ kf_int:=(ymax-ymin)/lmax;

mLog.Clear;
mLog.Lines.Add('year min->max: '+inttostr(ymin)+'->'+inttostr(ymax));
mLog.Lines.Add('lev  min->max: '+floattostr(lmin)+'->'+floattostr(lmax));
mLog.Lines.Add('kf_int= '+floattostr(kf_int));
mLog.Lines.Add('date min->max: '+datetostr(dmin)+'->'+datetostr(dmax));
kf_int:=(dmax-dmin)/lmax;
mLog.Lines.Add('kf_int= '+floattostr(kf_int));  }

 DecodeDate(dmin, yy, mn, dd);
 dsum:=0;
 for i:=1 to mn-1 do dsum:=dsum+DaysInAMonth(yy, i);
 dsum:=dsum+15;           //число дней к середине месяца
 dYear:=DaysInAYear(yy); //число дней в году
 x1:=yy+dsum/dYear;


 DecodeDate(dmax, yy, mn, dd);
 dsum:=0;
 for i:=1 to mn-1 do dsum:=dsum+DaysInAMonth(yy,i);
 dsum:=dsum+15;           //число дней к середине месяца
 dYear:=DaysInAYear(yy); //число дней в году
 x2:=yy+dsum/dYear;

// showmessage(floattostr(x2)+#9+floattostr(x2)+#9+floattostr(lmax));
kf_int:=(x2-x1)/lmax;
//  mLog.Lines.Add('kf_int= '+floattostr(kf_int));

// showmessage(floattostr(kf_int));


  //1.добавляем среднемесячные значения в cdsTDDMonth
  for y:=ymin to ymax do begin //y
    for m:=1 to 12 do begin  //m
      dsum:=0;
      for i:=1 to m-1 do dsum:=dsum+DaysInAMonth(y,i);
      dsum:=dsum+15;           //число дней к середине месяца
      dYear:=DaysInAYear(y); //число дней в году
      x:=y+dsum/dYear;


      ClearAllRecords(cdsMeanPrf);
      for c:=0 to memo1.Lines.Count-1 do begin
        with cdsMeanPrf do begin
          Append;
            FieldByName('lev').AsInteger:=strtoint(Memo1.Lines.Strings[c]);
            FieldByName('n').AsInteger:=0;
            FieldByName('val').AsInteger:=0;
            FieldByName('valSCR').AsInteger:=0;
          Post;
        end;
      end;

       //three months centered mean
     case m of
        1:begin
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
       12: begin
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
    TDDcds.Filter:='yy='+inttostr(y)+' and mn='+inttostr(m);


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
       val1 :=TDDCDS.FieldByName('val').asfloat;
       anom :=TDDCDS.FieldByName('anom').asfloat;


       if not VarIsNull(cdsMeanPrf.Locate('lev',sdlev,[])) then begin
         //statistics stored in cdsMeanPrf
         cdsMeanPrf.Edit;
         cdsMeanPrf.FieldByName('n').AsInteger:=cdsMeanPrf.FieldByName('n').AsInteger+1;
         cdsMeanPrf.FieldByName('val').AsFloat:=cdsMeanPrf.FieldByName('val').AsFloat+val1;
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
      val1:=cdsMeanPrf.FieldByName('val').asfloat;
      valSCR:=cdsMeanPrf.FieldByName('valSCR').asfloat;


      if n>0 then begin  //i

      //создание бланковочного файла по последнему горизонту
      mik_lev:=mik_lev+1;
      if mik_lev=1 then Ulev:=sdlev;  //верхний горизонт
      Dlev:=sdlev;  //нижний горизонт


      val1:=val1/n;        //среднемес значение на гор
      valSCR:=valSCR/n; //среднемесячные значение с исключенным сезонным ходом


      TimeTr:=(x-x1)/kf_int;
  //writeln(dat_Month, TimeTR:10:5, -sdlev:8, x:12:5, val:15:4, n:8);
      with cdsTTDMonth do begin
        Append;
          FieldByName('timeTR').AsFloat:=TimeTR;
          FieldByName('sdlev').AsInteger:=sdlev;
          FieldByName('time').AsFloat:=x;
          FieldByName('val').AsFloat:=val1;
          FieldByName('valSCR').AsFloat:=valSCR; //val с искл сез ходом!!!
          FieldByName('an').AsFloat:=0;
          FieldByName('anSCR').AsFloat:=0;
          FieldByName('n').AsInteger:=n;
       Post;
      end;
     end; //i
    cdsMeanPrf.Next;
   end; //pr

   //заполняем бланковочный cds
   if st_ex=true then begin
     Writeln(dat, x:10:5, ULev:10, DLev:10)
    {with cdsLastLevBln do begin
      Append;
        FieldByName('time').AsFloat:=x;
        FieldByName('ULev').AsFloat:=ULev;
        FieldByName('DLev').AsFloat:=DLev;
      Post;
    end; }
   end;
   end; //within period  //p
  end; //m
 end; //y
 CloseFile(dat);

 mLog.Lines.Add('4. Seasonal cycle removed ('+timetostr(Now-TimeStart)+')');
 Application.ProcessMessages;
end;

(* Creating blank file by data *)
procedure Tfrmtimedepthdiagram.BlnFileByData;
Var
  dat:text;
  Ky, Ystep, CountStep, cnt: integer;
  ybeg, yend, Y1, Y2, x: real;
  ULevMin_all, DLevMax_all, ULevMin, DLevMax, ULev, DLev: integer;

  cdsLastLevBln:TBufDataSet;
  TimeStart:TDateTime;
begin
  TimeStart:=now;

  cdsLastLevBln:=TBufDataSet.Create(nil);
   with cdsLastLevBln.FieldDefs do begin
    Add('time',  ftFloat,0,true);
    Add('ULev',  ftInteger,0,true);
    Add('DLev',  ftInteger,0,true);
   end;
  cdsLastLevBln.CreateDataSet;

  ULevMin_all:=99999;
  DLevMax_all:=0;

  AssignFile(dat,  TDDPath+'Blank.dat'); Reset(dat);  // blank file
  readln(dat);
  repeat
    readln(dat, x, ULev, DLev);

    ULevMin_all:=min(ULevMin_all, ULev);
    DLevMax_all:=max(DLevMax_all, DLev);

    with cdsLastLevBln do begin
      Append;
        FieldByName('time').Value:=x;
        FieldByName('ULev').Value:=ULev;
        FieldByName('DLev').Value:=DLev;
      Post;
    end;
  until eof(dat);
  CloseFile(dat);

//  showmessage(inttostr(ULevMin_all)+'   '+inttostr(DLevMax_all));

  AssignFile(dat,  TDDPath+'Blank.bln'); Rewrite(dat);  // blank file

    // проверка на дырки
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

  {   CountGap:=0;
    for ky:=1 to CountStep do begin
     Y1:=Ybeg+Ystep*(ky-1);
     Y2:=Ybeg+Ystep*ky;

     cdsLastLevBln.Filter:='time>='+floattostr(Y1)+' and time<='+floattostr(Y2);
     cdsLastLevBln.Filtered:=true;

     GetExactRecordCount(cdsLastLevBln, cnt);
     if cnt=0 then CountGap:=CountGap+1;

    { mLog.Lines.Add(inttostr(ky)
        +#9+floattostrF(y1,ffFixed,10,3)
        +#9+floattostrF(y2,ffFixed,10,3)
        +#9+inttostr(CountGap)
        ); }
     end;
     cdsLastLevBln.Filtered:=false;  }

  writeln(dat,(CountStep*4+1):5, 0:5);

    //последовательно верхние горизонты
  for ky:=1 to CountStep do begin  //y

    Y1:=Ybeg+Ystep*(ky-1);
    Y2:=Ybeg+Ystep*ky;

    cdsLastLevBln.First;
    cdsLastLevBln.Filter:='time>='+floattostr(Y1)+' and time<='+floattostr(Y2);
    cdsLastLevBln.Filtered:=true;

    GetExactRecordCount(cdsLastLevBln, cnt);

   // showmessage(inttostr(cnt));

    if cnt>0 then begin

    ULevMin:=99999;
    //минимальный горизонт за заданный промежуток времени
    cdsLastLevBln.First;
     while not cdsLastLevBln.Eof do begin
      ULev:=cdsLastLevBln.FieldByName('ULev').Value;
       ULevMin:=min(ULev, ULevMin);
      // showmessage(inttostr(ulev)+'   '+inttostr(ulevmin));
      cdsLastLevBln.Next;
     end;
  //   showmessage('final: inttostr(ulevmin));
      writeln(dat,Y1:12:5,ULevMin:10);
      writeln(dat,Y2:12:5,ULevMin:10);
    end else begin
     writeln(dat,Y1:12:5,ULevMin_all:10);
     writeln(dat,Y2:12:5,ULevMin_all:10);
    end;
  end;  //y
  cdsLastLevBln.Filtered:=false;

    //нижние горизонты в обратном порядке
  for ky:=1 to CountStep do begin  //

    Y1:=Yend-Ystep*(ky-1);
    Y2:=Yend-Ystep*ky;

    cdsLastLevBln.First;
    cdsLastLevBln.Filter:='time>='+floattostr(Y2)+' and time<='+floattostr(Y1);
    cdsLastLevBln.Filtered:=true;

    GetExactRecordCount(cdsLastLevBln, cnt);

    if cnt>0 then begin

     DLevMax:=0;
    //минимальный горизонт за заданный промежуток времени
     cdsLastLevBln.First;
     while not cdsLastLevBln.Eof do begin
      DLev:=cdsLastLevBln.FieldByName('DLev').VAlue;
      DLevMax:=max(DLevMax,DLev);
   // showmessage(floattostr(dlev)+'  '+floattostr(dlevMax));
      cdsLastLevBln.Next;
     end;
      writeln(dat,Y1:12:5,DLevMax:10);
      writeln(dat,Y2:12:5,DLevMax:10);
     end else begin
      writeln(dat,Y1:12:5,ULevMin_all:10);
      writeln(dat,Y2:12:5,ULevMin_all:10);
     end;
     end;  //y
      cdsLastLevBln.Filtered:=false;
    //первая станция верхний горизонт
    cdsLastLevBln.First;
    writeln(dat,cdsLastLevBln.FieldByName('time').AsFloat:12:5,
                  cdsLastLevBln.FieldByName('ULev').Value:10);

//  end;  //h

  cdsLastLevBln.Free;
  CloseFile(dat);


  mLog.Lines.Add('5. Blank file created ('+timetostr(Now-TimeStart)+')');
  Application.ProcessMessages;
end;

(* Mean profile for data without seasonal cycle *)
procedure Tfrmtimedepthdiagram.MeanProfileNoSeasons;
Var
  sdlev, n: integer;
  Time1, Val1, ValSCR: real;
  TimeStart:TDateTime;
begin
  TimeStart:=now;

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
      val1   :=cdsTTDMonth.FieldByName('val').Value;
      valSCR :=cdsTTDMonth.FieldByName('valSCR').Value;

       with cdsMeanPrf do begin
         if not VarIsNull(Locate('lev',sdlev,[])) then begin
          Edit;
            FieldByName('n').AsInteger:=FieldByName('n').AsInteger+1; //число значений на горизонте
            FieldByName('val').AsFloat:=FieldByName('val').AsFloat+val1;
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
   // sdlev:=cdsMeanPrf.FieldByName('lev').AsInteger;
    n:=cdsMeanPrf.FieldByName('n').AsInteger;
    val1:=cdsMeanPrf.FieldByName('val').AsFloat;
    valSCR:=cdsMeanPrf.FieldByName('valSCR').AsFloat;

    if n>0 then begin
     cdsMeanPrf.Edit;
      cdsMeanPrf.FieldByName('val').AsFloat:=val1/n;
      cdsMeanPrf.FieldByName('valSCR').AsFloat:=valSCR/n;
     cdsMeanPrf.Post;
    end;

    cdsMeanPrf.Next;
  end; //w

  (* anomalies *)
  cdsTTDMonth.First;
  while not cdsTTDMonth.Eof do begin  //w
    sdlev:=cdsTTDMonth.FieldByName('sdlev').AsInteger;
    val1:=cdsTTDMonth.FieldByName('val').AsFloat;
    valSCR:=cdsTTDMonth.FieldByName('valSCR').AsFloat;
    cdsMeanPrf.Locate('lev',sdlev,[]);

    cdsTTDMonth.Edit;
    cdsTTDMonth.FieldByName('an').AsFloat:=
       cdsTTDMonth.FieldByName('val').AsFloat-cdsMeanPrf.FieldByName('val').AsFloat;
    cdsTTDMonth.FieldByName('anSCR').AsFloat:=
       cdsTTDMonth.FieldByName('valSCR').AsFloat-cdsMeanPrf.FieldByName('valSCR').AsFloat;
    cdsTTDMonth.Post;

    cdsTTDMonth.Next;
  end; //w

  mLog.Lines.Add('6. Anomalies with seasonal cycle removed ('+timetostr(Now-TimeStart)+')');
  Application.ProcessMessages;
end;


(* Writing monthly results to file *)
procedure Tfrmtimedepthdiagram.MonthlyMeanAndAnomaliesToFile;
Var
  dat:text;
  TimeStart:TDateTime;
begin
  TimeStart:=now;

  AssignFile(dat, TDDPath+'Month.dat'); Rewrite(dat);   // monthly averaged
  writeln(dat, 'Date':10, 'lev':10, 'val':10, 'valSCR':10, 'anom':10, 'anSCR':10, 'n':8);


   cdsTTDMonth.First;
   while not cdsTTDMonth.Eof do begin  //w
  //  timeTR :=cdsTTDMonth.FieldByName('timeTR').AsFloat;


    (* пишем среднемесячные значения в файл *)
     writeln(dat, cdsTTDMonth.FieldByName('time'  ).AsFloat:10:5,
                  cdsTTDMonth.FieldByName('sdlev' ).AsInteger:10,
                  cdsTTDMonth.FieldByName('val'   ).AsFloat:10:3,
                  cdsTTDMonth.FieldByName('valSCR').AsFloat:10:3,
                  cdsTTDMonth.FieldByName('an'    ).AsFloat:10:3,
                  cdsTTDMonth.FieldByName('anSCR' ).AsFloat:10:3,
                  cdsTTDMonth.FieldByName('n'     ).AsInteger:8);

    cdsTTDMonth.Next;
   end; //w
   CloseFile(dat);

   mLog.Lines.Add('7. File month.dat has been created ('+timetostr(Now-TimeStart)+')');
   Application.ProcessMessages;
end;

(* Временные серии на стандартных горизонтах, пишем в файлы *)
procedure Tfrmtimedepthdiagram.TimeSeriesAtLevels;
var
k, cnt, n, sdlev:integer;
fName:string;
dat:text;
TimeStart:TDateTime;
begin
TimeStart:=now;

  //пишем временные серии
for k:=0 to memo1.Lines.Count-1 do begin
  sdLev:=StrToInt(memo1.Lines.Strings[k]);

    if sdLev=0 then fName:='0000';
    if Length(Inttostr(sdlev))=1 then fName:='000'+inttostr(sdlev);
    if Length(Inttostr(sdlev))=2 then fName:='00' +inttostr(sdlev);
    if Length(Inttostr(sdlev))=3 then fName:='0'  +inttostr(sdlev);
    if Length(Inttostr(sdlev))=4 then fName:=inttostr(sdlev);

  cdsTTDMonth.Filtered:=false;
  cdsTTDMonth.Filter:='sdlev='+inttostr(sdlev);
  cdsTTDMonth.Filtered:=true;

  GetExactRecordCount(cdsTTDMonth, cnt);

  if cnt>0 then begin
    AssignFile(dat, TDDPath+'SeriesAtSdLevelsMonthlyMean'+PathDelim+fName+'.dat'); Rewrite(dat);
    writeln(dat,'time':10, 'val':10, 'valSCR':10, 'anom':10, 'anSCR':10, 'n':8);

    cdsTTDMonth.First;
    while not cdsTTDMonth.Eof do begin
     writeln(dat, cdsTTDMonth.FieldByName('time').AsFloat:10:5,
                  cdsTTDMonth.FieldByName('val').AsFloat:10:3,
                  cdsTTDMonth.FieldByName('valSCR').AsFloat:10:3,
                  cdsTTDMonth.FieldByName('an').AsFloat:10:3,
                  cdsTTDMonth.FieldByName('anSCR').AsFloat:10:3,
                  cdsTTDMonth.FieldByName('n').AsInteger:8);

     cdsTTDMonth.Next;
    end;
     closefile(dat);
  end; // cnt cdsTTDMonth >0


  TDDcds.Filtered:=false;
  TDDcds.Filter:='lev='+inttostr(sdlev);
  TDDcds.Filtered:=true;

  GetExactRecordCount(cdsTTDMonth, cnt);

  if cnt>0 then begin
    AssignFile(dat, TDDPath+'SeriesAtSdLevelsInitialPrf'+PathDelim+fName+'.dat'); Rewrite(dat);
    writeln(dat,'time':10, 'val':10, 'ID':10, 'Date':11, 'Time':9);

    TDDcds.First;
    while not TDDcds.Eof do begin

    writeln(dat,TDDCDS.FieldByName('date_dec').AsFloat:10:5,
                TDDCDS.FieldByName('Val').asfloat:10:3,
                TDDCDS.FieldByName('ID').asInteger:10,
                datetostr(TDDCDS.FieldByName('date_date').asDateTime):11,
                timetostr(TDDCDS.FieldByName('date_date').asDateTime):9);

    TDDcds.Next;
    end;
   closefile(dat);
  end; // cnt TDDCDS >0

 end; //levels

mLog.Lines.Add('8. Time series on st. levels ('+timetostr(Now-TimeStart)+')');
Application.ProcessMessages;
end;



(* Берем средние профили и вычитаем последовательно месяцы *)
procedure Tfrmtimedepthdiagram.MonthsDifference;
Var
k, c:integer;
timetr, date1, date_old, lev, val1, val_old:real;
fdb:TSearchRec;
Path:string;
DateMin, DateMax, LevMin, LevMax, DateMid:real;

dat, dat1:text;
TimeStart:TDateTime;
begin
TimeStart:=now;
 //Загружаем список файлов
  path:=TDDPath+'SeriesAtSdLevelsMonthlyMean\';
   fdb.Name:='';
   lbMonthlyLevels.Clear;
    FindFirst(Path+'*.dat',faAnyFile, fdb);
   if fdb.Name<>'' then lbMonthlyLevels.Items.Add(fdb.Name);
  while findnext(fdb)=0 do lbMonthlyLevels.Items.Add(fdb.Name);


  AssignFile(dat1, TDDPath+'Month_dif.dat'); Rewrite(dat1);
  Writeln(dat1, 'Date':10, 'lev':10, 'valDif':10);

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
             writeln(dat1, Date_old:10:5, lev:10:0, (Val_old-Val1):10:3);
          Val_old:=Val1;
          Date_old:=Date1;
        end;
     until eof(dat);
    Closefile(dat);
  end;
 CloseFile(dat1);

 mLog.Lines.Add('9. Difference between two seq. months ('+timetostr(Now-TimeStart)+')');
 Application.ProcessMessages;
end;



procedure Tfrmtimedepthdiagram.AnnualMean;
Var
YCDS:TBufDataSet;
k, c, YY, YY_old, count:integer;
Path:string;
timetr, date1, lev, val1, val_old, lev1:real;
ValMean, Sum:real;
fdb:TSearchRec;
DateMin, DateMax, LevMin, LevMax, DateMid:real;
dat, dat1:text;
TimeStart:TDateTime;
begin
TimeStart:=now;
 (* Загружаем список файлов *)
  path:=TDDPath+'SeriesAtSdLevelsMonthlyMean'+PathDelim;
   fdb.Name:='';
   lbMonthlyLevels.Clear;
    FindFirst(Path+'*.dat',faAnyFile, fdb);
   if fdb.Name<>'' then lbMonthlyLevels.Items.Add(fdb.Name);
  while findnext(fdb)=0 do lbMonthlyLevels.Items.Add(fdb.Name);


  AssignFile(dat1, TDDPath+'Year.dat'); Rewrite(dat1);
  Writeln(dat1, 'Date':10, 'lev':10, 'Value':10, 'Anom':10);

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
            Writeln(dat1, YY:10, lev:10:0, Val1:10:3, (Val1-ValMean):10:3);
         YCDS.Next;
        end;
     end;
      YCDS.Free;
  end;
 CloseFile(dat1);

 mLog.Lines.Add('9. Yearly averaged data ('+timetostr(Now-TimeStart)+')');
 Application.ProcessMessages;
end;


(* Выбираем файл для построения и читаем первую строчку *)
procedure Tfrmtimedepthdiagram.rgDataFileClick(Sender: TObject);
begin

 rgVariable.Items.Clear;
 Case rgDataFile.ItemIndex of
  -1: Exit;
   0: begin
       CurrentFile:=TDDPath+'Real.dat';
       rgVariable.Items.Add('Value');
      end;
   1: begin
       CurrentFile:=TDDPath+'StLev.dat';
       rgVariable.Items.Add('Value');
       rgVariable.Items.Add('Anomaly');
      end;
   2: begin
       CurrentFile:=TDDPath+'Month.dat';
       rgVariable.Items.Add('Value');
       rgVariable.Items.Add('Value SCR');
       rgVariable.Items.Add('Anomaly');
       rgVariable.Items.Add('Anomaly SCR');
      end;
   3: begin
       CurrentFile:=TDDPath+'Year.dat';
       rgVariable.Items.Add('Value');
       rgVariable.Items.Add('Anomaly');
      end;
   4: begin
       CurrentFile:=TDDPath+'Month_dif.dat';
       rgVariable.Items.Add('Value');
      end;
 End;

 rgVariable.ItemIndex:=0;
 btnPlot.Enabled:=true;
 btnOpenScript.Enabled:=true;
end;

procedure Tfrmtimedepthdiagram.cbParametersSelect(Sender: TObject);
begin
  btnPlot.Enabled:=true;
  btnOpenScript.Enabled:=true;
end;


procedure Tfrmtimedepthdiagram.btnOpenFolderClick(Sender: TObject);
begin
   OpenDocument(PChar(TDDPath));
end;


procedure Tfrmtimedepthdiagram.btnOpenScriptClick(Sender: TObject);
Var
ScriptFile:string;
begin
 ScriptFile:=TDDPath+'Script.bas';
  if FileExists(ScriptFile) then  OpenDocument(PChar(ScriptFile));
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
cmd:string;
col: integer;
begin

 col:=rgVariable.ItemIndex+4;

 surfer_tdd.GetTDDScript(CurrentFile,
                         Parameter_name+', '+trim(Units_default_name),
                         col
                         );


 cmd:=Concat(' -x ', '"', TDDPath+'script.bas"');

 frmosmain.RunScript(2, cmd, nil);
end;


procedure Tfrmtimedepthdiagram.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
Var
  Ini:TIniFile;
begin

 Ini := TIniFile.Create(IniFileName);
 try
  Ini.WriteInteger('tdd', 'YearMin', seYY1.Value);
  Ini.WriteInteger('tdd', 'YearMax', seYY2.Value);
 finally
  Ini.Free;
 end;

  TDDCDS.Free;
  cdsTTDMonth.Free;
  MCDS.Free;
  cdsMeanPrf.Free;
end;

end.
