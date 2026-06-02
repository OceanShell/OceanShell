unit osload_wod_netcdf;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  FileUtil, DateUtils, DB, SQLDB, Variants, Math;

type

  { Tfrmload_wod_netcdf }

  Tfrmload_wod_netcdf = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    chkWrite: TCheckBox;
    chk1800: TCheckBox;
    eDataPath: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    mLog: TMemo;
    seYY1: TSpinEdit;
    seYY2: TSpinEdit;

    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure chk1800Change(Sender: TObject);
  private
    Procedure GetNCData(yy:integer; Var cnt_st:integer);
    Procedure GetDBData(yy:integer; Var cnt_st:integer);
    Procedure UpdateDB(cnt_nc, cnt_db: integer);
    Procedure AddNewCruise(mik:integer; fpath:string; Var cr_id:int64);
   // Procedure AddNewStation();
  public

  end;

Const
    strlensmall=40;
    strlen=170;


Type
  NCDATA=record
    wod_cast_id:int64;  //unique cast id
    cast_num:integer;
    cr_name:string; //cruise WOD ID
    ve_name:string; //vessel name
    in_name:string; //institute
    st_num:integer; //station number
    lat:real;
    lon:real;
    date:tDateTime;
    botdep:real;
    f_name:string;
end;
Type
  DBDATA=record
    cruise_id:int64;
    station_id:int64;
    wod_cast_id:int64;  //unique cast id
    cast_num:integer;
    cr_name:string; //cruise WOD ID
   // ve_name:string; //vessel name
   // in_name:string; //institute
    lat:real;
    lon:real;
    date:TDateTime;
    botdep:real;
end;
Type
  CRDATA=record
    cruise_id:int64;
    expocode:string;
end;

var
  frmload_wod_netcdf: Tfrmload_wod_netcdf;
  ncdata_arr: array of NCDATA;
  dbdata_arr: array of DBDATA;
  crdata_arr: array of CRDATA;

implementation

{$R *.lfm}

{ Tfrmload_wod_netcdf }

uses osmain, dm, declarations_netcdf, driver_fdb;

procedure Tfrmload_wod_netcdf.Button1Click(Sender: TObject);
Var
  yy, mik, cnt_nc, cnt_db: integer;

  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
  mLog.Clear;
  Application.ProcessMessages;

   try
     TRt:=TSQLTransaction.Create(nil);
     TRt.DataBase:=frmdm.IBDB;

     Qt:=TSQLQuery.Create(nil);
     Qt.Database:=frmdm.IBDB;
     Qt.Transaction:=TRt;
     with Qt do begin
      Close;
        SQL.Clear;
        SQL.add(' SELECT ID, EXPOCODE FROM CRUISE ');
        SQL.add(' WHERE SOURCE_ID=7 ');
        SQL.add(' ORDER BY EXPOCODE ');
      Open;
     end;

    mik:=-1;
    while not Qt.EOF do begin
     inc(mik);
      setlength(crdata_arr, mik+1);
       crdata_arr[mik].cruise_id:=Qt.FieldByName('ID').Value;
       crdata_arr[mik].expocode:=Qt.FieldByName('EXPOCODE').Value;
     Qt.Next;
    end;
  finally
    Trt.Commit;
    Qt.Free;
    Trt.Free;
  end;

  if chk1800.Checked=true then begin
    GetNCData(1800, cnt_nc);
    GetDBData(1800, cnt_db);
    UpdateDB(cnt_nc, cnt_db);
  end;

  if chk1800.Checked=false then begin
    for yy:=seYY1.Value to seYY2.Value do begin
      mLog.lines.add(inttostr(yy));
        GetNCData(yy, cnt_nc);
         mLog.lines.add('Stations NC: '+inttostr(cnt_nc));
        GetDBData(yy, cnt_db);
         mLog.lines.add('Stations DB: '+inttostr(cnt_db));
        UpdateDB(cnt_nc, cnt_db);
      mLog.lines.add('=======');
    end;
  end;

end;

Procedure Tfrmload_wod_netcdf.UpdateDB(cnt_nc, cnt_db:integer);
Var
  nc, db, fl, cc, mik: integer;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
  cruise_id, station_id:int64;
  cr_upd_cnt, lat_upd_cnt, lon_upd_cnt, date_upd_cnt, cast_upd_cnt: integer;
  cr_upd_fl, lat_upd_fl, lon_upd_fl, date_upd_fl, cast_upd_fl: integer;
begin

  try
    TRt:=TSQLTransaction.Create(nil);
    TRt.DataBase:=frmdm.IBDB;

    Qt:=TSQLQuery.Create(nil);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

    cr_upd_cnt:=0;
    lat_upd_cnt:=0;
    lon_upd_cnt:=0;
    date_upd_cnt:=0;
    cast_upd_cnt:=0;
    For nc:=0 to high(ncdata_arr) do begin
        fl:=0;
        for db:=0 to high(dbdata_arr) do begin
          if ncdata_arr[nc].wod_cast_id=dbdata_arr[db].wod_cast_id then begin
           fl:=1;
           break;
          end;
        end;

    (* New station *)
    if fl=0 then begin
        cruise_id:=-9;
         for cc:=0 to high(crdata_arr) do begin
           if ncdata_arr[nc].cr_name=crdata_arr[cc].expocode then begin
             cruise_id:=crdata_arr[cc].cruise_id;
             break;
           end;
         end;

         if cruise_id=-9 then AddNewCruise(nc, ncdata_arr[nc].f_name, cruise_id);

         with Qt do begin
           Close;
             SQL.Clear;
             SQL.add(' SELECT MAX(STATION.ID) FROM STATION, CRUISE, SOURCE ');
             SQL.add(' WHERE STATION.CRUISE_ID=CRUISE.ID AND ');
             SQL.add(' CRUISE.SOURCE_ID=SOURCE.ID AND SOURCE.ID=7 AND ');
             SQL.add(' CRUISE.ID BETWEEN STATION_ID_MIN AND STATION_ID_MAX ');
           Open;
             station_id:=Qt.Fields[0].Value+1;
           Close;
         end;

       if chkWrite.Checked then begin
        PutFDBStation(Qt, station_id, ncdata_arr[nc].lat, ncdata_arr[nc].lon,
          ncdata_arr[nc].date, ncdata_arr[nc].botdep, cruise_id, ncdata_arr[nc].st_num,
          ncdata_arr[nc].wod_cast_id, 0, 0, ncdata_arr[nc].cast_num,
          ncdata_arr[nc].f_name, now, now);
        Trt.CommitRetaining;
       end;

       mLog.lines.add('New station ID: '+inttostr(station_id)+', WOD: '+
                       inttostr(ncdata_arr[nc].wod_cast_id)+', EXPO: '+
                       ncdata_arr[nc].cr_name+', SHIP: '+
                       ncdata_arr[nc].ve_name);
    end;

    (* Existing station *)
    if fl=1 then begin
      cr_upd_fl:=0;
      lat_upd_fl:=0;
      lon_upd_fl:=0;
      date_upd_fl:=0;
      cast_upd_fl:=0;

      (* CRUISE CHANGED *)
       if (trim(ncdata_arr[nc].cr_name)<>'') and
          (ncdata_arr[nc].cr_name<>dbdata_arr[db].cr_name) then begin
         inc(cr_upd_cnt);

         cruise_id:=-9;
         for cc:=0 to high(crdata_arr) do begin
           if ncdata_arr[nc].cr_name=crdata_arr[cc].expocode then begin
             cruise_id:=crdata_arr[cc].cruise_id;
             break;
           end;
         end;

          if cruise_id=-9 then AddNewCruise(nc, ncdata_arr[nc].f_name, cruise_id);
          Trt.Commit;
          Trt.StartTransaction;

          if chkWrite.Checked then begin
           with Qt do begin
            Close;
              SQL.Clear;
              SQL.add(' UPDATE STATION SET ');
              SQL.add(' CRUISE_ID=:cr_id');
              SQL.add(' WHERE ID=:id ');
              ParamByName('id').Value:=dbdata_arr[db].station_id;
              ParamByName('cr_id').Value:=cruise_id;
            ExecSQL;
           end;
          end;

           mLog.lines.add('Station: '+inttostr(dbdata_arr[db].station_id)+', '+
                          'Cruise '+dbdata_arr[db].cr_name+' ['+
                          IntToStr(dbdata_arr[db].cruise_id)+'] -> '+
                          ncdata_arr[nc].cr_name+' ['+inttostr(cruise_id)+']');
       end;

       (* Latidude changes *)
       if abs(ncdata_arr[nc].lat-dbdata_arr[db].lat)>1E-6 then begin
        // showmessage(floattostr(ncdata_arr[nc].lat-dbdata_arr[db].lat));
         inc(lat_upd_cnt);
         lat_upd_fl:=1;
        {  mLog.lines.add('Latitude changed from '+
            Floattostr(dbdata_arr[db].lat)+' to '+
            Floattostr(ncdata_arr[nc].lat));  }
       end;

       (* Longitude changed *)
       if abs(ncdata_arr[nc].lon-dbdata_arr[db].lon)>1E-6 then begin
       //  showmessage(floattostr(ncdata_arr[nc].lon-dbdata_arr[db].lon));
         inc(lon_upd_cnt);
         lon_upd_fl:=1;
         { mLog.lines.add('Longitude changed from '+
            Floattostr(dbdata_arr[db].lon)+' to '+
            Floattostr(ncdata_arr[nc].lon));  }
       end;

       (* date changed *)
       if (YearOf(ncdata_arr[nc].date)>1700) and
          (ncdata_arr[nc].date<>dbdata_arr[db].date) then begin
         inc(date_upd_cnt);
         date_upd_fl:=1;
        {  mLog.lines.add('Date changed from '+
            DateTimeToStr(dbdata_arr[db].date)+' to '+
            DateTimeToStr(ncdata_arr[nc].date)); }
       end;

       (* cast number changed *)
       if ncdata_arr[nc].cast_num<>dbdata_arr[db].cast_num then begin
         inc(cast_upd_cnt);
         cast_upd_fl:=1;
      {  mLog.lines.add('Cast number changed: '+
          inttostr(ncdata_arr[nc].cast_num)+'   '+
          inttostr(dbdata_arr[db].cast_num)); }
       end;

       (* applying changes *)
       if (chkWrite.Checked=true) and
          ((lat_upd_fl=1) or (lon_upd_fl=1) or
           (date_upd_fl=1) or (cast_upd_fl=1)) then begin
        {  with Qt do begin
            Close;
              SQL.Clear;
              SQL.add(' UPDATE STATION SET ');
              if cast_upd_cnt>0 then SQL.add(' CAST_NUMBER=:cast, ');
              if lat_upd_cnt>0  then SQL.add(' LATITUDE=:lat, ');
              if lon_upd_cnt>0  then SQL.add(' LONGITUDE=:lon, ');
              if date_upd_cnt>0 then SQL.add(' DATEANDTIME=:dat0, ');
              if Copy(SQL.Text, length(SQL.Text)-1, 1)=',' then
                SQL.Text:=copy(SQL.Text, 1, length(SQL.Text)-1);
              SQL.add(' WHERE ID=:id ');
              ParamByName('id').Value:=dbdata_arr[db].station_id;
              if cast_upd_cnt>0  then ParamByName('cast').Value:=ncdata_arr[nc].cast_num;
              if lat_upd_cnt>0   then ParamByName('lat').Value :=ncdata_arr[nc].lat;
              if lon_upd_cnt>0   then ParamByName('lon').Value :=ncdata_arr[nc].lon;
              if date_upd_cnt>0  then ParamByName('dat0').Value:=ncdata_arr[nc].date;
            ExecSQL;
           end;   }
         end; //writing into DB

    end; //station exists
  end; //loop over casts
  if cast_upd_cnt>0 then mLog.lines.add('Cast updated: '+inttostr(cast_upd_cnt));
  if lat_upd_cnt>0  then mLog.lines.add('Lat  updated: '+inttostr(lat_upd_cnt));
  if lon_upd_cnt>0  then mLog.lines.add('Lon  updated: '+inttostr(lon_upd_cnt));
  if date_upd_cnt>0 then mLog.lines.add('Date updated: '+inttostr(date_upd_cnt));
  Trt.CommitRetaining;

  if cnt_db>cnt_nc then begin
   mLog.lines.add('Stations no longer in the source:');
   for db:=0 to high(dbdata_arr) do begin
    fl:=0;
    For nc:=0 to high(ncdata_arr) do begin
      if ncdata_arr[nc].wod_cast_id=dbdata_arr[db].wod_cast_id then begin
        fl:=1;
        break;
      end;
    end;
    if fl=0 then begin
      mLog.lines.add(inttostr(dbdata_arr[db].station_id)+'   '+
                     inttostr(dbdata_arr[db].wod_cast_id)+'   '+
                     dbdata_arr[db].cr_name);
      if chkWrite.checked then DeleteFDBStation(Qt, dbdata_arr[db].station_id); //removing station
    end;
   end;
  end;

  finally
    Trt.Commit;
    Qt.Free;
    Trt.Free;
  end;

end;


Procedure Tfrmload_wod_netcdf.GetNCData(yy:integer; Var cnt_st:integer);
Var
   fname: string;
   ncid, idp, idp_cr, idp_ve, idp_cast, idp_ins, idp_lat, idp_lon: integer;
   idp_date, idp_time, idp_dep, idp_stnum: integer;
   cast:int64;
   lenp: size_t;
   k, c, mik: integer;
   stlat, stlon, stdep, mm_f, sttime: real;
   stdate_int, st_num:integer;
   stdate:TDateTime;


   ncchar_arr: array of PAnsiChar;
   ncint_arr: array of Int64;
   ncfloat_arr: array of Single;

   start0, start: PArraySize_t;
   wod_cr, wod_ve, wod_ins, stdate_str: string;
   yy0, mn, dd, hh, mm, ss: word;
 begin
   ncdata_arr:=nil; //Cleaning
   cnt_st:=0;

   fname:=inttostr(yy)+PathDelim+'wod_osd_'+inttostr(yy)+'.nc';
   if not FileExists(eDataPath.Text+fname) then exit;

    try
     nc_open(pansichar(eDataPath.Text+fname), NC_NOWRITE, ncid);
     nc_inq_dimid(ncid, pAnsiChar('casts'), idp);
     nc_inq_dimlen(ncid, idp, lenp);

     nc_inq_varid(ncid, pAnsiChar('WOD_cruise_identifier'), idp_cr);
     nc_inq_varid(ncid, pAnsiChar('wod_unique_cast'), idp_cast);
     nc_inq_varid(ncid, pAnsiChar('Orig_Stat_Num'), idp_stnum);
    { nc_inq_varid(ncid, pAnsiChar('Platform'), idp_ve);
     nc_inq_varid(ncid, pAnsiChar('Institute'), idp_ins); }
     nc_inq_varid(ncid, pAnsiChar('lat'), idp_lat); //float
     nc_inq_varid(ncid, pAnsiChar('lon'), idp_lon); //float
 //    nc_inq_varid(ncid, pAnsiChar('time'), idp_time); //float
     nc_inq_varid(ncid, pAnsiChar('date'), idp_date); //int
     nc_inq_varid(ncid, pAnsiChar('GMT_time'), idp_time); //float
     nc_inq_varid(ncid, pAnsiChar('Bottom_Depth'), idp_dep); //float

     start0:=GetMemory(SizeOf(TArraySize_t));
     start :=GetMemory(SizeOf(TArraySize_t)*2);

     mik:=-1;
     for k:=0 to lenp-1 do begin  //loop over casts
       start^[0]:=k;
       start0^[0]:=k;

       setlength(ncint_arr, 1);
       nc_get_var1_long(ncid, idp_cast, start0^, ncint_arr);
       cast:=ncint_arr[0];

       setlength(ncint_arr, 1);
       nc_get_var1_long(ncid, idp_stnum, start0^, ncint_arr);
       st_num:=ncint_arr[0];

       setlength(ncfloat_arr, 1);
       nc_get_var1_float(ncid, idp_lat, start0^, ncfloat_arr);
       stlat:=ncfloat_arr[0];

       setlength(ncfloat_arr, 1);
       nc_get_var1_float(ncid, idp_lon, start0^, ncfloat_arr);
       stlon:=ncfloat_arr[0];

       setlength(ncfloat_arr, 1);
       nc_get_var1_float(ncid, idp_dep, start0^, ncfloat_arr);
       stdep:=ncfloat_arr[0];

       setlength(ncint_arr, 1);
       nc_get_var1_long(ncid, idp_date, start0^, ncint_arr);
       stdate_str:=IntToStr(ncint_arr[0]);
      // showmessage(stdate_str);
       yy0:=StrToInt(Copy(stdate_str, 1, 4));
       mn :=StrToInt(Copy(stdate_str, 5, 2));
       dd :=StrToInt(Copy(stdate_str, 7, 2));

       setlength(ncfloat_arr, 1);
       nc_get_var1_float(ncid, idp_time, start0^, ncfloat_arr);
       sttime:=ncfloat_arr[0];
       if sttime<24 then begin
         hh:=trunc(sttime);
         mm_f:=frac(sttime)*60;
         mm:=trunc(mm_f);
         ss:=round(frac(mm_f)*60);
         if ss=60 then begin
          mm:=mm+1;
          ss:=0;
         end;
       end else begin
        hh:=0;
        mm:=0;
        ss:=0;
       end;

       if (yy<>0) and (mn<>0) and (dd<>0) then
         StDate:=EncodeDateTime(yy0, mn, dd, hh, mm, ss, 0) else
         StDate:=EncodeDateTime(1000, 1, 1, 0, 0, 0, 0);

      // showmessage(inttostr(strlensmall)+'   '+inttostr(idp_cr));
       wod_cr:='';
       for c:=0 to strlensmall-1 do begin
         start^[1]:=c;
         setlength(ncchar_arr, 1);
         nc_get_var1_text(ncid, idp_cr, start^, ncchar_arr); //for char
         wod_cr:=wod_cr+pAnsiChar(ncchar_arr);
       end;
     //  showmessage(wod_cr);

       {
       wod_ve:='';
       for c:=0 to strlen do begin
         start^[1]:=c;
         setlength(ncchar_arr, 1);
         nc_get_var1_text(ncid, idp_ve, start^, ncchar_arr); //for char
         wod_ve:=wod_ve+pAnsiChar(ncchar_arr);
       end;

       wod_ins:='';
       for c:=0 to strlen do begin
         start^[1]:=c;
         setlength(ncchar_arr, 1);
         nc_get_var1_text(ncid, idp_ins, start^, ncchar_arr); //for char
         wod_ins:=wod_ins+pAnsiChar(ncchar_arr);
       end;  }

     //  showmessage('here');

       inc(mik);
       setlength(ncdata_arr, mik+1);

       ncdata_arr[mik].wod_cast_id:=cast;
       ncdata_arr[mik].cast_num:=k;
       ncdata_arr[mik].cr_name:=wod_cr;
       ncdata_arr[mik].st_num:=st_num;
    {   ncdata_arr[mik].ve_name:=wod_ve;
       ncdata_arr[mik].in_name:=wod_ins; }
       ncdata_arr[mik].lat:=roundto(stlat, -5);
       ncdata_arr[mik].lon:=roundto(stlon, -5);
       ncdata_arr[mik].date:=stdate;
       ncdata_arr[mik].botdep:=stdep;
       ncdata_arr[mik].f_name:=fname;
     end;

     if mik>0 then cnt_st:=mik else cnt_st:=0;

    finally
      FreeMemory(start);
      nc_close(ncid);
    end;
end;


Procedure Tfrmload_wod_netcdf.GetDBData(yy:integer; Var cnt_st:integer);
Var
  mik: integer;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
  dbdata_arr:=nil; //Cleaning

  try
    TRt:=TSQLTransaction.Create(nil);
    TRt.DataBase:=frmdm.IBDB;

    Qt:=TSQLQuery.Create(nil);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

   with Qt do begin
    Close;
     SQL.Clear;
     SQL.add(' SELECT ');
     SQL.add(' STATION.ID AS ST_ID, STATION.LATITUDE, STATION.LONGITUDE, ');
     SQL.add(' STATION.CAST_NUMBER, STATION.DATEANDTIME, STATION.BOTTOMDEPTH, ');
     SQL.add(' STATION.ST_ID_ORIGIN, CRUISE.ID AS CR_ID, CRUISE.EXPOCODE ');
     SQL.add(' FROM STATION, CRUISE ');
     SQL.add(' WHERE ');
     SQL.add(' (STATION.CRUISE_ID=CRUISE.ID) AND ');
     SQL.add(' (CRUISE.SOURCE_ID=7) AND ');
     if chk1800.Checked=true then
       SQL.add(' (Extract(year from STATION.DATEANDTIME)<1900) ') else
       SQL.add(' (Extract(year from STATION.DATEANDTIME)='+Inttostr(yy)+') ');
    Open;
   end;

   mik:=-1;
   while not Qt.EOF do begin
    inc(mik);

    setlength(dbdata_arr, mik+1);
    dbdata_arr[mik].cruise_id:=Qt.FieldByName('CR_ID').Value;
    dbdata_arr[mik].station_id:=Qt.FieldByName('ST_ID').Value;
    dbdata_arr[mik].wod_cast_id:=Qt.FieldByName('ST_ID_ORIGIN').Value;
    if not VarIsNull(Qt.FieldByName('CAST_NUMBER').Value) then
    dbdata_arr[mik].cast_num:=Qt.FieldByName('CAST_NUMBER').Value else
    dbdata_arr[mik].cast_num:=0;
    dbdata_arr[mik].cr_name:=Qt.FieldByName('EXPOCODE').Value;
   // dbdata_arr[mik].ve_name:=wod_ve;
   // dbdata_arr[mik].in_name:=wod_ins;
    dbdata_arr[mik].lat:=Qt.FieldByName('LATITUDE').Value;
    dbdata_arr[mik].lon:=Qt.FieldByName('LONGITUDE').Value;
    dbdata_arr[mik].date:=Qt.FieldByName('DATEANDTIME').Value;
    if not VarIsNull(Qt.FieldByName('BOTTOMDEPTH').Value) then
    dbdata_arr[mik].botdep:=Qt.FieldByName('BOTTOMDEPTH').Value else
    dbdata_arr[mik].botdep:=-9;

    Qt.Next;
   end;

   if mik>0 then cnt_st:=mik else cnt_st:=0;

  finally
    Trt.Commit;
    Qt.Free;
    Trt.Free;
  end;
end;

procedure Tfrmload_wod_netcdf.Button2Click(Sender: TObject);
Var
  expo0, expo1, expo_c: string;
  exponum:integer;
begin
  with frmdm.q1 do begin
    Close;
      SQL.Clear;
      SQL.add('SELECT ID, EXPOCODE ');
      SQL.add('FROM CRUISE WHERE CRUISE.SOURCE_ID=7 ');
      SQL.add('ORDER BY EXPOCODE ');
    Open;
  end;

  while not frmdm.q1.EOF do begin
    expo0:= frmdm.q1.FieldByName('EXPOCODE').Value;
    expo_c:=copy(expo0, 1, 2);
    exponum:=strtoint(trim(copy(expo0, 4, length(expo0))));

 //   mLog.Lines.add(expo_c+inttostr(exponum));

    if (exponum>=100000) then expo1:=expo_c+inttostr(exponum);
    if (exponum<100000) and (exponum>10000) then expo1:=expo_c+'0'   +inttostr(exponum);
    if (exponum<10000)  and (exponum>1000)  then expo1:=expo_c+'00'  +inttostr(exponum);
    if (exponum<1000)   and (exponum>100)   then expo1:=expo_c+'000' +inttostr(exponum);
    if (exponum<100)    and (exponum>10)    then expo1:=expo_c+'0000'+inttostr(exponum);
    if (exponum<10)     and (exponum>0)     then expo1:=expo_c+'00000'+inttostr(exponum);

   // mLog.Lines.add(expo0+' -> '+expo1);
   with frmdm.q2 do begin
    Close;
      SQL.Clear;
      SQL.add(' UPDATE CRUISE SET EXPOCODE=:expo ');
      SQL.add(' WHERE CRUISE.ID=:ID ');
      ParamByName('expo').Value:=expo1;
      ParamByName('ID').Value:=frmdm.q1.FieldByName('ID').Value;
    ExecSQL;
  end;

    frmdm.q1.Next;
  end;
  frmdm.TR.Commit;
end;

procedure Tfrmload_wod_netcdf.Button3Click(Sender: TObject);
Var
  id: int64;
  expo0, expo_old, expo_new: string;
  expo1, expo_c: string;
  exponum:integer;


  TRt:TSQLTransaction;
  Qt, QT2:TSQLQuery;
begin
  try
    TRt:=TSQLTransaction.Create(nil);
    TRt.DataBase:=frmdm.IBDB;

    Qt:=TSQLQuery.Create(nil);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

    Qt2:=TSQLQuery.Create(nil);
    Qt2.Database:=frmdm.IBDB;
    Qt2.Transaction:=TRt;

   with Qt do begin
    Close;
     SQL.Clear;
     SQL.add(' SELECT ID, EXPOCODE ');
     SQL.add(' FROM CRUISE_20260526 ');
     SQL.add(' WHERE SOURCE_ID=7 ');
     SQL.add(' ORDER BY EXPOCODE ');
    Open;
   end;

   while not Qt.EOF do begin
    id:=Qt.FieldByName('ID').Value;
    expo0:=Qt.FieldByName('EXPOCODE').Value;

    expo_c:=copy(expo0, 1, 2);
    exponum:=strtoint(trim(copy(expo0, 4, length(expo0))));

 //   mLog.Lines.add(expo_c+inttostr(exponum));

    if (exponum>=100000) then expo1:=expo_c+inttostr(exponum);
    if (exponum<100000) and (exponum>10000) then expo1:=expo_c+'0'   +inttostr(exponum);
    if (exponum<10000)  and (exponum>1000)  then expo1:=expo_c+'00'  +inttostr(exponum);
    if (exponum<1000)   and (exponum>100)   then expo1:=expo_c+'000' +inttostr(exponum);
    if (exponum<100)    and (exponum>10)    then expo1:=expo_c+'0000'+inttostr(exponum);
    if (exponum<10)     and (exponum>0)     then expo1:=expo_c+'00000'+inttostr(exponum);

    expo_old:=expo1;

    with Qt2 do begin
     Close;
      SQL.Clear;
      SQL.add(' SELECT ID, EXPOCODE FROM CRUISE WHERE ID='+inttostr(ID));
     Open;
       expo_new:=Qt2.FieldByName('EXPOCODE').Value;
     Close;
    end;
    if expo_new<>expo_old then begin
      mLog.lines.add(expo_old+' -> '+expo_new);
      with Qt2 do begin
       Close;
        SQL.Clear;
        SQL.add(' UPDATE CRUISE SET EXPOCODE=:expo ');
        SQL.add(' WHERE ID='+inttostr(ID));
        ParamByName('EXPO').Value:=expo_old;
       ExecSQL;
      end;
    end;
    Qt.Next;
   end;
  finally
    Trt.Commit;
    Qt.Free;
    Qt2.Free;
    Trt.Free;
  end;

end;

Procedure Tfrmload_wod_netcdf.AddNewCruise(mik:integer;
  fpath:string; Var cr_id:int64);
Var
  id: int64;
  platf, inst: string;
  platform_id, institute_id, country_id, c:integer;

  ncid, idp_ins, idp_ve: integer;
  ncchar_arr: array of PAnsiChar;
  start: PArraySize_t;

  TRt:TSQLTransaction;
  Qt, QT2:TSQLQuery;
begin
  try
    TRt:=TSQLTransaction.Create(nil);
    TRt.DataBase:=frmdm.IBDB;

    Qt:=TSQLQuery.Create(nil);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

    try
     nc_open(pansichar(eDataPath.Text+fpath), NC_NOWRITE, ncid);

     nc_inq_varid(ncid, pAnsiChar('Platform'),  idp_ve);
     nc_inq_varid(ncid, pAnsiChar('Institute'), idp_ins);

     start :=GetMemory(SizeOf(TArraySize_t)*2);
     start^[0]:=mik;

       platf:='';
       for c:=0 to strlen-1 do begin
         start^[1]:=c;
         setlength(ncchar_arr, 1);
         nc_get_var1_text(ncid, idp_ve, start^, ncchar_arr); //for char
         platf:=platf+pAnsiChar(ncchar_arr);
       end;

       inst:='';
       for c:=0 to strlen-1 do begin
         start^[1]:=c;
         setlength(ncchar_arr, 1);
         nc_get_var1_text(ncid, idp_ins, start^, ncchar_arr); //for char
         inst:=inst+pAnsiChar(ncchar_arr);
       end;

    finally
      FreeMemory(start);
      nc_close(ncid);
    end;


    with Qt do begin
     Close;
      SQL.Clear;
      SQL.add(' SELECT MAX(CRUISE.ID) FROM CRUISE, SOURCE ');
      SQL.add(' WHERE CRUISE.SOURCE_ID=SOURCE.ID AND ');
      SQL.add(' CRUISE.ID BETWEEN STATION_ID_MIN AND STATION_ID_MAX ');
     Open;
       cr_id:=Qt.Fields[0].Value+1;
     Close;
    end;

    platf:=trim(copy(platf, 1, pos('(', platf)-1));

    platform_id:=0;
    if trim(platf)<>'' then begin
      with Qt do begin
       Close;
        SQL.Clear;
        SQL.add(' SELECT ID FROM PLATFORM WHERE ');
        SQL.add(' (NAME_WOD='+QuotedStr(UpperCase(platf))+') OR (');
        SQL.add(' NAME='+QuotedStr(UpperCase(platf))+')');
       Open;
         if not Qt.IsEmpty then platform_id:=Qt.Fields[0].Value else platform_id:=0;
       Close;
      end;
      with Qt do begin
       Close;
        SQL.Clear;
        SQL.add(' SELECT ID FROM COUNTRY WHERE ISO3166_CODE='+QuotedStr(UpperCase(copy(platf, 1, 2))));
       Open;
         if not Qt.IsEmpty then country_id:=Qt.Fields[0].Value else country_id:=0;
       Close;
      end;

      if platform_id=0 then begin
        PutFDBPlatform(Qt, cr_id, platf, country_id, null, now, now);
        mLog.lines.add('New platform: '+platf+', id= '+inttostr(platform_id));
      end;
    end;

    institute_id:=0;
    if trim(inst)<>'' then begin
      with Qt do begin
       Close;
        SQL.Clear;
        SQL.add(' SELECT ID FROM INSTITUTE WHERE NAME='+QuotedStr(UpperCase(inst)));
       Open;
        if not Qt.IsEmpty then institute_id:=Qt.Fields[0].Value else institute_id:=0;
       Close;
      end;
    end;

    mLog.lines.add('New cruise: '+inttostr(cr_id));

    PutFDBCruise(Qt, cr_id, platform_id, 7, institute_id, 0,
      ncdata_arr[mik].cr_name, null, null, null, null, null, now, now, now, now);
    Trt.CommitRetaining;

    setlength(crdata_arr, high(crdata_arr)+1);
    crdata_arr[high(crdata_arr)].cruise_id:=cr_id;
    crdata_arr[high(crdata_arr)].expocode:=ncdata_arr[mik].cr_name;

  finally
    Trt.Commit;
    Qt.Free;
    Trt.Free;
  end;
end;

procedure Tfrmload_wod_netcdf.chk1800Change(Sender: TObject);
begin
  seYY1.Enabled:=not chk1800.Checked;
  seYY2.Enabled:=not chk1800.Checked;
end;

end.

