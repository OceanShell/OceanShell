unit osload_ices;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IniFiles, FileCtrl, DateUtils, Math, ComCtrls;

type
  Tfrmload_ices = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Merge: TTabSheet;
    btnOpen: TButton;
    btnStart: TButton;
    Memo1: TMemo;
    chkWrite: TCheckBox;
    lbC: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    eCTD: TEdit;
    Button1: TButton;
    btnMerge: TButton;
    Memo2: TMemo;

    procedure btnOpenClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnMergeClick(Sender: TObject);

  private
    { Private declarations }
    procedure MergeDB(ID1, ID2, Num2:integer);
  public
    { Public declarations }
  end;

var
  frmload_ices: Tfrmload_ices;
  DFile, Path:string;
  dat, dat2:text;

implementation

uses osmain, dm;

{$R *.lfm}

procedure Tfrmload_ices.btnOpenClick(Sender: TObject);
Var
fdb:TSearchRec;
begin
SelectDirectory('Select folder', '' , path);

//path:='X:\OceanShell\data\ICES';

if path<>'' then begin
   Path:=Path+'\';
   fdb.Name:='';
   lbC.Clear;
    FindFirst(Path+'*.csv',faAnyFile, fdb);
   if fdb.Name<>'' then lbC.Items.Add(fdb.Name);
  while findnext(fdb)=0 do lbC.Items.Add(fdb.Name);
end;

If lbC.Items.count>0 then btnStart.Enabled:=true;
end;


{Cruise,Station,Type,yyyy-mm-ddThh:mm,Latitude [degrees_north],Longitude [degrees_east],Bot. Depth [m],PRES [db],TEMP [deg C],PSAL [psu],ALKY [meq/l],AMON [umol/l],CPHL [ug/l],DOXY [ml/l],H2SX [umol/l],NTOT [umol/l],NTRA [umol/l],NTRI [umol/l],PHOS [umol/l],PHPH [],SLCA [umol/l],TPHS [umol/l]
06ME,0007,B,1929-08-15T17:00,65.38,-33.00,949,0,6.80,33.55,,,,7.30,,,0.4,,0.23,8.20,,
06ME,0007,B,1929-08-15T17:00,65.38,-33.00,949,25,10.43,35.15,,,,6.33,,,6.4,,0.36,8.20,,
06ME,0007,B,1929-08-15T17:00,65.38,-33.00,949,50,8.49,35.13,,,,6.17,,,14.3,,0.68,8.03,,
06ME,0007,B,1929-08-15T17:00,65.38,-33.00,949,76,7.69,35.14,,,,,,,,,,,,
06ME,0007,B,1929-08-15T17:00,65.38,-33.00,949,101,7.69,35.20,,,,5.88,,,16.4,,0.84,8.03,,}

procedure Tfrmload_ices.btnStartClick(Sender: TObject);
Var
Ini:TIniFile;
k, i, count, absnum, levnum, k_file, instrument, num1:integer;
st, buf_str, DB2Name,oldNum, Inst:string;
plat, num, time:string;
lat, lon, lev, lev_old, oldLat, OldLon, Pres:real;
yy, mn, dd, hh, mm:word;
Temp, Salt, Oxy, Phos, NO3, NO2, Ph, Alk, H2S:real;
snd, totP, totN, Sil, Amm, Chl:real;
StDate, StTime, OldTime, OldDate:TDateTime;
StCountryname, StVesselName, StSource:string;
begin
 {
 (* Открываем SupportTable *)
   if SupportDB<>'' then begin
    ODBDM.IBDatabase2.Close;
    ODBDM.IBDatabase2.DatabaseName:=SupportDB;
    ODBDM.IBDatabase2.Open;
   end else begin
    Showmessage('Support database is not found');
     exit;
   end;
   ODBDM.IBTransaction2.StartTransaction;

   StSource:='ICES';
   memo1.Clear;

    if chkWrite.Checked then begin
     ODBDM.IBTransaction1.StartTransaction;

      with ODBDM.ib1q1 do begin
       Close;
        SQL.Clear;
        SQL.ADD(' Select gen_id(StAbsNum,0) from RDB$DataBase ');
       Open;
         absnum:=ODBDM.IB1q1.Fields[0].AsInteger;
       Close;
      end;
    end;


 for k_file:=0 to lbC.Count-1 do begin
  DFile:=Path+lbC.Items.Strings[k_file];

  AssignFile(dat, dFile); Reset(dat);
  readln(dat);

 lev_old:=-9; Count:=0;
 while not eof(dat) do begin
  readln(dat, st);

  Lat:=-9; Lon:=-9; snd:=-9;
  Lev:=-9; Temp:=-9; Salt:=-9; Oxy:=-9; Phos:=-9; NO3:=-9; NO2:=-9; Ph:=-9;
  Alk:=-9; H2S:=-9; totP:=-9; totN:=-9; Sil:=-9; Amm:=-9; Chl:=-9;


  i:=0; k:=0;
  repeat
   buf_str:='';
   repeat
     inc(i);
     if (st[i]<>',') then buf_str:=buf_str+st[i];
   until (st[i]=',') or (i=length(st));
   inc(k);

   if (trim(buf_str)<>'') and (copy(buf_str,1,1)<>'<') then begin
    if copy(DFile, length(DFile)-4, 1)='c' then begin
      Case k of
       1: Plat:=trim(buf_str);
       2: Num :=trim(buf_str);
       3: Inst:=trim(buf_str);
       4: Time:=trim(buf_str);
       5: Lat :=StrtoFloat(trim(buf_str));
       6: Lon :=StrtoFloat(trim(buf_str));
       7: Snd :=StrToFloat(trim(buf_str));
       8: Pres:=StrToFloat(trim(buf_str)); //pressure!!!
       9: Temp:=StrToFloat(trim(buf_str));
      10: Salt:=StrToFloat(trim(buf_str));
      11: Oxy :=StrToFloat(trim(buf_str));
     end;
     instrument:=4;
    end;


    if copy(DFile, length(DFile)-4, 1)='b' then begin
      Case k of
       1: Plat:=trim(buf_str);
       2: Num :=trim(buf_str);
       3: Inst:=trim(buf_str);
       4: Time:=trim(buf_str);
       5: Lat :=StrtoFloat(trim(buf_str));
       6: Lon :=StrtoFloat(trim(buf_str));
       7: Snd :=StrToFloat(trim(buf_str));
       8: Pres:=StrToFloat(trim(buf_str)); //pressure!!!
       9: Temp:=StrToFloat(trim(buf_str));
      10: Salt:=StrToFloat(trim(buf_str));
      11: Alk :=StrToFloat(trim(buf_str));
      12: Amm :=StrToFloat(trim(buf_str));
      13: Chl :=StrToFloat(trim(buf_str));
      14: Oxy :=StrToFloat(trim(buf_str));
      15: H2S :=StrToFloat(trim(buf_str));
      16: totN:=StrToFloat(trim(buf_str));
      17: NO3 :=StrToFloat(trim(buf_str));
      18: NO2 :=StrToFloat(trim(buf_str));
      19: Phos:=StrToFloat(trim(buf_str));
      20: PH  :=StrToFloat(trim(buf_str));
      21: Sil :=StrToFloat(trim(buf_str));
      22: totP:=StrToFloat(trim(buf_str));
     end;
    instrument:=7;
   end;
 end; // buf_str<>''

 until i=Length(St);

  //   if trystrtoint(num, num1)=true then inttostr(strtoint(num));

   yy:=StrToint(Copy(time, 1,4));
   mn:=StrToint(Copy(time, 6,2));
   dd:=StrToint(Copy(time, 9,2));
   hh:=StrToint(Copy(time,12,2));
   mm:=StrToint(Copy(time,15,2));

   StDate:=EncodeDate(yy,mn,dd);

   if hh=24 then hh:=0;
   if time<>'' then Sttime:=EncodeTime(hh,mm,0,0) else StTime:=Encodetime(0,0,0,0);

   if (Count=0) or (OldTime<>StTime) or (oldDate<>stdate) or
      (OldLat<>Lat) or (OldLon<>Lon) then begin

     StCountryName:='UNKNOWN';
     with ODBDM.ib2q1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' select CountryName from CountryCode_List ');
       SQL.Add(' where NODCCountryCode=:pNODCCode ');
       ParamByName('pNODCCode').AsString:=Copy(Plat,1,2);
      Open;
        if ODBDM.ib2q1.IsEmpty=false then StCountryName:=Fields[0].AsString;
      Close;
     end;

     StVesselName:='UNKNOWN';
     with ODBDM.ib2q1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' select ShipName from ShipCode_List ');
       SQL.Add(' where NODCShipCode=:pNODCCode ');
       ParamByName('pNODCCode').AsString:=Plat;
      Open;
        if ODBDM.ib2q1.IsEmpty=false then StVesselName:=Fields[0].AsString;
      Close;
     end;
     inc(absnum);

    if chkWrite.Checked then
     StandartQueries.InsertMetadata(Absnum, 0, Lat, Lon, StDate, StTime,
                   StSource, 0, StCountryName, stVesselName, Snd,
                   strtoint(Copy(plat,1,2)), plat, Num, -9, -9 ,
                   instrument, num, stsource, '');

        oldtime:=StTime;
        olddate:=StDate;
        oldnum:=num;
        oldLat:=Lat;
        oldLon:=Lon;

      inc(Count);
    //  label1.Caption:=IntToStr(Count);
    //  Application.ProcessMessages;

      levnum:=0;
    if chkWrite.Checked then  ODBDM.IBTransaction1.CommitRetaining;
    end;

    // m=0- depth to pressure, 1- pressure to depth
    Depth_to_Pressure(pres, lat, 1, lev);
  //  if instrument=7 then lev:=round(lev);
    if (chkWrite.Checked=true) and (lev<>-9) then begin

     if Temp<>-9 then InsertParameters('P_TEMPERATURE',     Absnum, lev, Temp, 0);
     if Salt<>-9 then InsertParameters('P_SALINITY',        Absnum, lev, Salt, 0);
     if Oxy<>-9  then InsertParameters('P_OXYGEN',          Absnum, lev, Oxy,  0);
     if Phos<>-9 then InsertParameters('P_PHOSPHATE',       Absnum, lev, Phos, 0);
 //    if totP<>-9 then InsertParameters('P_TOTALPHOSPHORUS', Absnum, lev, totP, 0);
     if Sil<>-9  then InsertParameters('P_SILICATE',        Absnum, lev, Sil,  0);
     if NO3<>-9  then InsertParameters('P_NITRATE',         Absnum, lev, NO3,  0);
     if NO2<>-9  then InsertParameters('P_NITRITE',         Absnum, lev, NO2,  0);
  //   if Amm<>-9  then InsertParameters('P_AMMONIUM',        Absnum, lev, Amm,  0);
  //   if totN<>-9 then InsertParameters('P_TOTALNITROGEN',   Absnum, lev, totN, 0);
   //  if H2S<>-9  then InsertParameters('P_SULPHIDE',        Absnum, lev, H2S,  0);
     if PH<>-9   then InsertParameters('P_PH',              Absnum, lev, ph,   0);
     if Alk<>-9  then InsertParameters('P_ALKALINITY',      Absnum, lev, Alk,  0);
  //   if Chl<>-9  then InsertParameters('P_CHLOROPHYLL',     Absnum, lev, Chl,  0);

     inc(levNum);
    end;
  end;
  memo1.Lines.Add(DFile+#9+inttostr(count));
  CloseFile(dat);
 end;

 ODBDM.IBTransaction2.Commit;
 if chkWrite.Checked then begin
   ODBDM.IBTransaction1.Commit;
    Main.UpdateIBContent;
 end;

 showmessage('Done!');  }
end;


procedure Tfrmload_ices.Button1Click(Sender: TObject);
begin
 // main.OpenDialog1.Filter:='*.FDB|*.FDB';
 // if main.OpenDialog1.Execute then eCTD.Text:=main.OpenDialog1.FileName;
end;


procedure Tfrmload_ices.btnMergeClick(Sender: TObject);
Var

  Date1, Date2, time1, time2:TDateTime;
  ID1, ID2, Num1, Num2, c:integer;
  ship1, ship2:string;
begin
  if (trim(eCTD.Text)='') then begin
      showmessage('Select CTD database');
    exit;
  end;
{
  AssignFile(dat, GlobalPath+'unload\MergeICESMDErrors.txt'); Rewrite(dat);
  writeln(dat, 'Date':11, 'Num':5, 'lat_b':10, 'lat_c':10, 'lon_b':10, 'lon_c':10,
               'time_b':9, 'time_c':9, 'Vessel':20);

  odbdm.IBDatabase2.DatabaseName:=eCTD.Text;
  odbdm.IBDatabase2.Open;

  odbdm.IBTransaction1.StartTransaction;
  odbdm.IBTransaction2.StartTransaction;
   with odbdm.ib2q1 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select * from Station, Station_info ');
     SQL.Add(' where station.absnum=station_info.absnum ');
     SQL.Add(' order by Stdate, StTime ');
    Open;
    FetchAll;
   end;

   c:=0;
   main.progressbar1.position:=0;
   main.progressbar1.max:=odbdm.ib2q1.RecordCount;
   while not odbdm.ib2q1.eof do begin
     ID2   :=odbdm.ib2q1.FieldByName('absnum').AsInteger;
     Date2 :=odbdm.ib2q1.FieldByName('stdate').AsDateTime;
     Time2 :=odbdm.ib2q1.FieldByName('sttime').AsDateTime;
     Num2  :=StrToInt(odbdm.ib2q1.FieldByName('stnumincruise').AsString);
     Ship2 :=odbdm.ib2q1.FieldByName('stvesselname').AsString;

     with ODBDM.ib1q1 do begin
      Close;
       SQL.Clear;
       SQL.Add(' select station.absnum, station_info.stnumincruise');
       SQL.Add(' from station, station_info where ');
       SQL.Add(' station.absnum=station_info.absnum and ');
       SQL.Add(' stdate between :date1 and :date2 and ');
       SQL.Add(' stvesselname=:ship and ');
       SQL.Add(' stnumincruise like '+QuotedStr('%'+Inttostr(Num2)));
       ParamByName('Date1').AsDateTime:=IncDay(Date2, -1);
       ParamByName('Date2').AsDateTime:=IncDay(Date2,  1);
       ParamByName('Ship').AsString:=Ship2;
      Open;
        if ODBDM.ib1q1.IsEmpty=true then ID1:=-9 else begin
         ID1 :=ODBDM.ib1q1.FieldByName('Absnum').AsInteger;
         Num1:=StrToInt(odbdm.ib1q1.FieldByName('stnumincruise').AsString);
        end;
      Close;
     end;

     if ID1=-9 then memo2.Lines.Add(inttostr(ID2)+'   '+datetostr(Date2)+'   '+timetostr(time2));
     if (ID1>-9) and (num1=num2) then begin
       try
         MergeDB(ID1, ID2, Num2);
       except
         showmessage(inttostr(iD2)+'   '+inttostr(ID1));
       end;
       inc(c);
     end;

    main.progressbar1.position:=main.progressbar1.position+1;
    Application.ProcessMessages;

    odbdm.ib2q1.Next;
   end;
  odbdm.ib2q1.Close;
  CloseFile(dat);

  ODBDM.IBTransaction1.Commit;
showmessage(inttostr(c)); }
end;


// ID1 - bottle
// ID2 - CTD
procedure Tfrmload_ices.MergeDB(ID1, ID2, Num2:integer);
Var
  Lat1, Lon1, Lat2, Lon2:real;
  Date2, Time1, Time2:TDateTime;
  ship1, par:string;
  lev1, val1, lev2, val2, lev2_0, val2_0, int_val:real;
  pp, chem_ex, fl:integer;
begin
{
//memo2.Lines.Add('Start merging: '+inttostr(ID1)+'   '+inttostr(ID2));

   with odbdm.ib2q2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select stlat, stlon, sttime from Station ');
     SQL.Add(' where absnum=:ID2 ');
     Parambyname('ID2').AsInteger:=ID2;
    Open;
      Lat2  :=odbdm.ib2q1.FieldByName('stlat').AsFloat;
      Lon2  :=odbdm.ib2q1.FieldByName('stlon').AsFloat;
      Time2 :=odbdm.ib2q1.FieldByName('sttime').AsDateTime;
      Date2 :=odbdm.ib2q1.FieldByName('stdate').AsDateTime;
    Close;
   end;

  // showmessage('ctd done');

   with odbdm.ib1q2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' select stlat, stlon, sttime, stvesselname from Station ');
     SQL.Add(' where absnum=:ID1 ');
     Parambyname('ID1').AsInteger:=ID1;
    Open;
      Lat1  :=odbdm.ib1q2.FieldByName('stlat').AsFloat;
      Lon1  :=odbdm.ib1q2.FieldByName('stlon').AsFloat;
      Time1 :=odbdm.ib1q2.FieldByName('sttime').AsDateTime;
      Ship1 :=odbdm.ib1q2.FieldByName('stvesselname').AsString;
    Close;
   end;

 //  showmessage('bottle done');

   // if MD is different
   if (lat1<>lat2) or (lon1<>lon2) or (Time1<>Time2) then begin
    writeln(dat, DateToStr(Date2):11, Num2:5, lat1:10:5, lat2:10:5,
            lon1:10:5, lon2:10:5, TimeToStr(time1):9, TimeToStr(time2):9, ship1:20);

 //   showmessage(floattostr(lat1)+'   '+floattostr(lon1));

    with ODBDM.ib1qq1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' Update STATION set stlat=:Lat1, ');
      SQL.Add(' StLon=:Lon1, StTime=:Time1 ');
      SQL.Add(' where absnum=:ID1 ');
      ParamByName('ID1').AsInteger:=ID1;
      ParamByName('Lat1').AsFloat  :=Lat1;
      ParamByName('Lon1').AsFloat  :=Lon1;
      ParamByName('Time1').AsDateTime :=Time1;
     ExecQuery;
    end;
   end;
   // if MD is different

   //    showmessage('update instrument');

   // updating instrument
    with ODBDM.ib1qq1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' Update STATION_INFO set instrument=4 where absnum=:ID1 ');
      ParamByName('ID1').AsInteger:=ID1;
     ExecQuery;
    end;

    //    showmessage('chemestry');
    // check if there is chemistry
    chem_ex:=0;
    for pp := 1 to 6 do begin
      case pp of
       1: par:='P_PHOSPHATE';
       2: par:='P_SILICATE';
       3: par:='P_NITRATE';
       4: par:='P_NITRITE';
       5: par:='P_PH';
       6: par:='P_ALKALINITY';
      end;
      with ODBDM.ib1q2 do begin  // select profile from CTD
       Close;
        SQL.Clear;
        SQL.Add(' select 1 from '+par+' where ');
        SQL.Add(' absnum=:id1 ');
        ParamByName('id1').AsInteger:=ID1;
       Open;
        if ODBDM.ib1q2.IsEmpty=false then chem_ex:=1;
       Close;
     end;
    end;

  //  if chem_ex=0 then showmessage('chem=no') else showmessage('chem=yes');



   // Loop for parameters
    for pp := 1 to 3 do begin
      case pp of
       1: par:='P_TEMPERATURE';
       2: par:='P_SALINITY';
       3: par:='P_OXYGEN';
      end;

     //    showmessage(par);

    // NO chemistry
    if chem_ex=0 then begin
     with ODBDM.ib2q2 do begin  // select profile from CTD
      Close;
       SQL.Clear;
       SQL.Add(' select * from '+par+' where ');
       SQL.Add(' absnum=:id2 ');
       ParamByName('id2').AsInteger:=ID2;
      Open;
        if ODBDM.ib2q2.IsEmpty=false then begin
          with ODBDM.ib1qq1 do begin
           Close;
            SQL.Clear;
            SQL.Add(' delete from '+par+' where ');
            SQL.Add(' absnum=:id1 ');
            ParamByName('id1').AsInteger:=ID1;
           ExecQuery;
          end;

        ODBDM.ib2q2.First;
        while not ODBDM.ib2q2.eof do  begin
         Lev1:= ODBDM.ib2q2.FieldByName('Level_').AsFloat;
         val1:=ODBDM.ib2q2.FieldByName('Value_').AsFloat;
          InsertParameters(par, ID1, lev1, Val1, 0);
         ODBDM.ib2q2.Next;
        end;
        ODBDM.ib2q2.close;
       end;
      Close;
     end;
    end;
   // END of NO chemistry


   //Chemistry EXISTS
    if chem_ex=1 then begin

    //    showmessage('CHEM');
     with ODBDM.ib2q2 do begin  // select profile from CTD
      Close;
       SQL.Clear;
       SQL.Add(' select * from '+par+' where ');
       SQL.Add(' absnum=:id2 ');
       ParamByName('id2').AsInteger:=ID2;
      Open;
     End;

     with ODBDM.ib1q2 do begin  // select profile from bottles
      Close;
       SQL.Clear;
       SQL.Add(' select * from '+par+' where ');
       SQL.Add(' absnum=:id1 ');
       ParamByName('id1').AsInteger:=ID1;
      Open;
     End;

  //   showmessage('unique levels');
     // unique levels in bottles
     ODBDM.ib1q2.First;
     while not ODBDM.ib1q2.Eof do begin
      lev1:=ODBDM.ib1q2.FieldByName('level_').AsFloat;
      val1:=ODBDM.ib1q2.FieldByName('value_').AsFloat;

      ODBDM.ib2q2.First;
      lev2_0:=ODBDM.ib2q2.FieldByName('level_').AsFloat;
      val2_0:=ODBDM.ib2q2.FieldByName('value_').AsFloat;
      repeat
        lev2:=ODBDM.ib2q2.FieldByName('level_').AsFloat;
        val2:=ODBDM.ib2q2.FieldByName('value_').AsFloat;
         //linear interpolation
          int_val:=-999;
          if (lev2<>lev1) and (lev1>lev2_0) and (lev1<lev2) then begin
            int_val:=ODBPr_Line(lev1, lev2_0, lev2, val2_0, val2);
            if int_val<>-999 then begin
          //    showmessage(inttostr(ID1)+'   '+inttostr(ID2)+#13+
          //    floattostr(lev1)+'   '+floattostr(lev2_0)+'   '+floattostr(lev2)+#13+
          //    floattostr(val1)+'   '+floattostr(val2));
             with ODBDM.ib1qq1 do begin
              Close;
               SQL.Clear;
               SQL.Add(' Update '+par+' set value_=:val ');
               SQL.Add(' where absnum=:ID1 and level_=:lev ');
               ParamByName('ID1').AsInteger:=ID1;
               ParamByName('lev').AsFloat:=lev1;
               ParamByName('val').AsFloat:=roundTo(int_val, -4);
              ExecQuery;
             end; // qq1
             ODBDM.IBTransaction1.CommitRetaining;
            end; //-999
          end; //levels
         lev2_0:=lev2;
         val2_0:=val2;
        ODBDM.ib2q2.Next;
      until ODBDM.ib2q2.eof;
      ODBDM.ib1q2.next;
     end; //ib1q2
     ODBDM.ib1q2.Close;

  //   showmessage('start inserting levels');
      ODBDM.ib2q2.First;
      while not ODBDM.ib2q2.Eof do begin
        lev2:=ODBDM.ib2q2.FieldByName('level_').AsFloat;
        val2:=ODBDM.ib2q2.FieldByName('value_').AsFloat;

    //    memo2.Lines.Add(floattostr(lev2)+'   '+floattostr(val2));

           with ODBDM.ib1q2 do begin  // select profile from CTD
            Close;
             SQL.Clear;
             SQL.Add(' select * from '+par+' where ');
             SQL.Add(' absnum=:id1 and level_=:lev ');
             ParamByName('id1').AsInteger:=ID1;
             ParamByName('lev').AsFloat:=lev2;
            Open;
             if ODBDM.ib1q2.IsEmpty=true then begin
       //       showmessage('insert new level');
               InsertParameters(par, ID1, lev2, Val2, 0);
             end;
             if ODBDM.ib1q2.IsEmpty=false then begin
               val1:=ODBDM.ib1q2.FieldByName('value_').AsFloat;
               if val1<>val2 then begin
        //        showmessage('not the same');
                 with ODBDM.ib1qq1 do begin
                  Close;
                   SQL.Clear;
                   SQL.Add(' Update '+par+' set value_=:val ');
                   SQL.Add(' where absnum=:ID1 and level_=:lev ');
                   ParamByName('ID1').AsInteger:=ID1;
                   ParamByName('lev').AsFloat:=lev1;
                   ParamByName('val').AsFloat:=val2;
                  ExecQuery;
                 end; // qq1
                 ODBDM.IBTransaction1.CommitRetaining;
               end; //val1<>val2
             end; //empty
            Close;
           end; //ib1q2
        ODBDM.ib2q2.Next;
      end; //ib2q2
      ODBDM.ib2q2.Close;
    end; //chem_ex=1

   end;  //Loop for parameters

 ODBDM.IBTransaction1.CommitRetaining; }
end;


end.
