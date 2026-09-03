unit osload_wod_netcdf;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, FileUtil, DateUtils, DB, SQLDB, Variants, Math;

type

  { Tfrmload_wod_netcdf }

  Tfrmload_wod_netcdf = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    chkWrite: TCheckBox;
    chk1800: TCheckBox;
    eDataPath: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    mLog: TMemo;
    rgInstrument: TRadioGroup;
    seYY1: TSpinEdit;
    seYY2: TSpinEdit;

    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure chk1800Change(Sender: TObject);
  private
    Procedure GetNCData(yy:integer; Var cnt_st, cnt_err:integer);
    Procedure GetDBData(yy:integer; Var cnt_st:integer);
    Procedure UpdateDB(cnt_nc, cnt_db: integer);
    Procedure FindCruise(nc_expocode:string; Var cruise_id:int64);
    Procedure AddNewCruise(mik:integer; fpath:string; cr_id:int64);

    Procedure GetAllNC(fname:string; Var mik:integer);
  public

  end;

Const
    strlensmall=40;
    strlen=170;


Type
  NCDATA=record
    wod_cast_id:int64;  //unique cast id
    cast_num:integer;
    cr_name:variant; //cruise WOD ID
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
    cr_name:variant; //cruise WOD ID
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
    expocode:variant;
end;
Type
  NCALL=record
    st_num:int64; //unique cast id
    wod_cast_id:int64; //unique cast id
    expocode:variant; //cruise WOD ID
    vessel:string; //vessel name
    institute:string; //institute name
end;

var
  frmload_wod_netcdf: Tfrmload_wod_netcdf;
  ncdata_arr: array of NCDATA;
  dbdata_arr: array of DBDATA;
  crdata_arr: array of CRDATA;
  ncall_arr:  array of NCALL;

implementation

{$R *.lfm}

{ Tfrmload_wod_netcdf }

uses osmain, dm, declarations_netcdf, driver_fdb, osqc_cruiseinfo;

procedure Tfrmload_wod_netcdf.chk1800Change(Sender: TObject);
begin
  seYY1.Enabled:=not chk1800.Checked;
  seYY2.Enabled:=not chk1800.Checked;
end;


procedure Tfrmload_wod_netcdf.Button1Click(Sender: TObject);
Var
  yy, mik, cnt_nc, cnt_db, cnt_err: integer;

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
   mLog.lines.add(inttostr(1800));
    GetNCData(1800, cnt_nc, cnt_err);
      mLog.lines.add('Stations NC: '+inttostr(cnt_nc)+', skipped: '+inttostr(cnt_err));
    GetDBData(1800, cnt_db);
      mLog.lines.add('Stations DB: '+inttostr(cnt_db));
    UpdateDB(cnt_nc, cnt_db);
   mLog.lines.add('=======');
  end;

  if chk1800.Checked=false then begin
    for yy:=seYY1.Value to seYY2.Value do begin
      mLog.lines.add(inttostr(yy));
        GetNCData(yy, cnt_nc, cnt_err);
         mLog.lines.add('Stations NC: '+inttostr(cnt_nc)+', skipped: '+inttostr(cnt_err));
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
  cruise_id, station_id, cruise_id_max:int64;
  cr_upd_cnt, lat_upd_cnt, lon_upd_cnt, date_upd_cnt, cast_upd_cnt, dep_upd_cnt: integer;
  cr_upd_fl, lat_upd_fl, lon_upd_fl, date_upd_fl, cast_upd_fl, dep_upd_fl: integer;
begin

  try
    TRt:=TSQLTransaction.Create(nil);
    TRt.DataBase:=frmdm.IBDB;

    Qt:=TSQLQuery.Create(nil);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

    with Qt do begin
      Close;
        SQL.Clear;
        SQL.add(' SELECT MAX(STATION.ID) FROM STATION, CRUISE, SOURCE ');
        SQL.add(' WHERE STATION.CRUISE_ID=CRUISE.ID AND ');
        SQL.add(' CRUISE.SOURCE_ID=SOURCE.ID AND SOURCE.ID=7 AND ');
        SQL.add(' CRUISE.ID BETWEEN STATION_ID_MIN AND STATION_ID_MAX ');
      Open;
        station_id:=Qt.Fields[0].Value;
      Close;
    end;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.add(' SELECT MAX(CRUISE.ID) FROM CRUISE, SOURCE ');
      SQL.add(' WHERE CRUISE.SOURCE_ID=SOURCE.ID AND ');
      SQL.add(' CRUISE.ID BETWEEN STATION_ID_MIN AND STATION_ID_MAX ');
     Open;
       cruise_id_max:=Qt.Fields[0].Value;
     Close;
    end;

    cr_upd_cnt:=0;
    lat_upd_cnt:=0;
    lon_upd_cnt:=0;
    date_upd_cnt:=0;
    cast_upd_cnt:=0;
    dep_upd_cnt:=0;
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
      inc(station_id);

      if not VarIsNull(ncdata_arr[nc].cr_name) then begin
        FindCruise(ncdata_arr[nc].cr_name, cruise_id);
        if cruise_id=-9 then begin
          inc(cruise_id_max);
          AddNewCruise(nc, ncdata_arr[nc].f_name, cruise_id_max);
          cruise_id:=cruise_id_max;
        end;
      end else cruise_id:=50000000; //unknown cruise

      if chkWrite.Checked then begin
       Trt.Commit;
       Trt.StartTransaction;
        PutFDBStation(Qt, station_id, ncdata_arr[nc].lat, ncdata_arr[nc].lon,
          ncdata_arr[nc].date, ncdata_arr[nc].botdep, cruise_id, ncdata_arr[nc].st_num,
          ncdata_arr[nc].wod_cast_id, 0, 0, ncdata_arr[nc].cast_num,
          ncdata_arr[nc].f_name, now, now);
        Trt.CommitRetaining;
       end;

       mLog.lines.add('New station ID: '+inttostr(station_id)+', WOD: '+
                       inttostr(ncdata_arr[nc].wod_cast_id)+', EXPO: '+
                       VarToStr(ncdata_arr[nc].cr_name)+', SHIP: '+
                       ncdata_arr[nc].ve_name);
    end; //new station

    (* Existing station *)
    if fl=1 then begin
      cr_upd_fl:=0;
      lat_upd_fl:=0;
      lon_upd_fl:=0;
      date_upd_fl:=0;
      cast_upd_fl:=0;
      dep_upd_fl:=0;

   //   showmessage('here');

      (* CRUISE CHANGED *)
       if (ncdata_arr[nc].cr_name<>dbdata_arr[db].cr_name) then begin
          inc(cr_upd_cnt);

          if not VarIsNull(ncdata_arr[nc].cr_name) then begin
            FindCruise(ncdata_arr[nc].cr_name, cruise_id);
            if cruise_id=-9 then begin
              inc(cruise_id_max);
              AddNewCruise(nc, ncdata_arr[nc].f_name, cruise_id_max);
              cruise_id:=cruise_id_max;
            end;
          end else cruise_id:=50000000; //unknown cruise

      //    showmessage('here2');

         if chkWrite.Checked then begin
          Trt.Commit;
          Trt.StartTransaction;
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
                          VarToStr(ncdata_arr[nc].cr_name)+' ['+inttostr(cruise_id)+']');
       end;

       (* Latidude changes *)
       if abs(ncdata_arr[nc].lat-dbdata_arr[db].lat)>1E-6 then begin
        // showmessage(floattostr(ncdata_arr[nc].lat-dbdata_arr[db].lat));
         inc(lat_upd_cnt);
         lat_upd_fl:=1;
         { mLog.lines.add('Station: '+inttostr(dbdata_arr[db].station_id)+
          ', Latitude from '+ Floattostr(dbdata_arr[db].lat)+' to '+
            Floattostr(ncdata_arr[nc].lat)); }
       end;

       (* Longitude changed *)
       if abs(ncdata_arr[nc].lon-dbdata_arr[db].lon)>1E-6 then begin
       //  showmessage(floattostr(ncdata_arr[nc].lon-dbdata_arr[db].lon));
         inc(lon_upd_cnt);
         lon_upd_fl:=1;
       {   mLog.lines.add('Station: '+inttostr(dbdata_arr[db].station_id)+
          ', Longitude from '+Floattostr(dbdata_arr[db].lon)+' to '+
            Floattostr(ncdata_arr[nc].lon)); }
       end;

       (* depth changed *)
       if (ncdata_arr[nc].botdep<>dbdata_arr[db].botdep) then begin
         inc(dep_upd_cnt);
         dep_upd_fl:=1;
          {mLog.lines.add('Station: '+inttostr(dbdata_arr[db].station_id)+
          ', Depth changed from '+
            FloatToStr(dbdata_arr[db].botdep)+' to '+
            FloatToStr(ncdata_arr[nc].botdep));   }
       end;

       (* date changed *)
       if ncdata_arr[nc].date<>dbdata_arr[db].date then begin
           inc(date_upd_cnt);
           date_upd_fl:=1;
         { mLog.lines.add('Station: '+inttostr(dbdata_arr[db].station_id)+
          ', Date changed from '+
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
           (date_upd_fl=1) or (cast_upd_fl=1) or (dep_upd_fl=1)) then begin
          with Qt do begin
            Close;
              SQL.Clear;
              SQL.add(' UPDATE STATION SET ');
              SQL.add(' DATE_UPDATED=:dat0, ');
              if cast_upd_cnt>0 then SQL.add(' CAST_NUMBER=:cast, ');
              if lat_upd_cnt>0  then SQL.add(' LATITUDE=:lat, ');
              if lon_upd_cnt>0  then SQL.add(' LONGITUDE=:lon, ');
              if date_upd_cnt>0 then SQL.add(' DATEANDTIME=:dat0, ');
              if dep_upd_cnt>0  then SQL.add(' BOTTOMDEPTH=:dep, ');
              SQL.Text:=trim(SQL.Text);
              SQL.Text:=copy(SQL.Text, 1, length(SQL.Text)-3);
              SQL.add(' WHERE ID=:id ');
              ParamByName('id').Value:=dbdata_arr[db].station_id;
              ParamByName('dat0').Value:=now;
              if cast_upd_cnt>0  then ParamByName('cast').Value:=ncdata_arr[nc].cast_num;
              if lat_upd_cnt>0   then ParamByName('lat').Value :=ncdata_arr[nc].lat;
              if lon_upd_cnt>0   then ParamByName('lon').Value :=ncdata_arr[nc].lon;
              if date_upd_cnt>0  then ParamByName('dat0').Value:=ncdata_arr[nc].date;
              if dep_upd_cnt>0   then ParamByName('dep').Value :=ncdata_arr[nc].botdep;
            ExecSQL;
           end;
         end; //writing into DB
    end; //station exists
  // mLog.lines.add(inttostr(nc));
  end; //loop over casts
   // showmessage('here');
  if cast_upd_cnt>0 then mLog.lines.add('Cast  updated: '+inttostr(cast_upd_cnt));
  if lat_upd_cnt>0  then mLog.lines.add('Lat   updated: '+inttostr(lat_upd_cnt));
  if lon_upd_cnt>0  then mLog.lines.add('Lon   updated: '+inttostr(lon_upd_cnt));
  if date_upd_cnt>0 then mLog.lines.add('Date  updated: '+inttostr(date_upd_cnt));
  if dep_upd_cnt>0  then mLog.lines.add('Depth updated: '+inttostr(dep_upd_cnt));
  Trt.CommitRetaining;

  finally
    Trt.Commit;
    Qt.Free;
    Trt.Free;
  end;

end;


Procedure Tfrmload_wod_netcdf.GetNCData(yy:integer; Var cnt_st, cnt_err:integer);
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
   cnt_err:=0;

   fname:=inttostr(yy)+PathDelim+'wod_'+rgInstrument.Items[rgInstrument.ItemIndex]+'_'+inttostr(yy)+'.nc';
   if not FileExists(eDataPath.Text+fname) then exit;

    try
     nc_open(pansichar(eDataPath.Text+fname), NC_NOWRITE, ncid);
     nc_inq_dimid(ncid, pAnsiChar('casts'), idp);
     nc_inq_dimlen(ncid, idp, lenp);

     nc_inq_varid(ncid, pAnsiChar('WOD_cruise_identifier'), idp_cr);
     nc_inq_varid(ncid, pAnsiChar('wod_unique_cast'), idp_cast);
     nc_inq_varid(ncid, pAnsiChar('Orig_Stat_Num'), idp_stnum);
     nc_inq_varid(ncid, pAnsiChar('lat'), idp_lat); //float
     nc_inq_varid(ncid, pAnsiChar('lon'), idp_lon); //float
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
       if stlon>180 then stlon:=360-stlon;

       setlength(ncfloat_arr, 1);
       nc_get_var1_float(ncid, idp_dep, start0^, ncfloat_arr);
       stdep:=ncfloat_arr[0];
       if stdep=-10000000000 then stdep:=-9;

       setlength(ncint_arr, 1);
       nc_get_var1_long(ncid, idp_date, start0^, ncint_arr);
       stdate_str:=IntToStr(ncint_arr[0]);
      // showmessage(stdate_str);
       yy0:=StrToInt(Copy(stdate_str, 1, 4));
       mn :=StrToInt(Copy(stdate_str, 5, 2));
       dd :=StrToInt(Copy(stdate_str, 7, 2));

       if DaysinaMonth(yy,mn)<dd then dd:=dd-1;

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
         if mm=60 then begin
          hh:=hh+1;
          mm:=0;
         end;

       end else begin
        hh:=0;
        mm:=0;
        ss:=0;
       end;

       (* Incomplete metadata *)
       if (yy=0) or (mn=0) or (dd=0) or
          (stlat<-90) or (stlat>90) or
          (stlon<-180) or (stlon>180) then begin

           inc(cnt_err);
          Continue;
       end;

       StDate:=EncodeDateTime(yy0, mn, dd, hh, mm, ss, 0);

       wod_cr:='';
       for c:=0 to strlensmall-1 do begin
         start^[1]:=c;
         setlength(ncchar_arr, 1);
         nc_get_var1_text(ncid, idp_cr, start^, ncchar_arr); //for char
         wod_cr:=wod_cr+pAnsiChar(ncchar_arr);
       end;

       inc(mik);
       setlength(ncdata_arr, mik+1);

       ncdata_arr[mik].wod_cast_id:=cast;
       ncdata_arr[mik].cast_num:=k;
       if wod_cr='' then ncdata_arr[mik].cr_name:=null else ncdata_arr[mik].cr_name:=wod_cr;
       ncdata_arr[mik].st_num:=st_num;
       ncdata_arr[mik].lat:=roundto(stlat, -5);
       ncdata_arr[mik].lon:=roundto(stlon, -5);
       ncdata_arr[mik].date:=stdate;
       ncdata_arr[mik].botdep:=round(stdep);
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

Procedure Tfrmload_wod_netcdf.FindCruise(nc_expocode:string; Var cruise_id:int64);
Var
  cc: integer;
begin
  cruise_id:=-9;
  for cc:=0 to high(crdata_arr) do begin
    if nc_expocode=crdata_arr[cc].expocode then begin
      cruise_id:=crdata_arr[cc].cruise_id;
      break;
    end;
  end;
end;


Procedure Tfrmload_wod_netcdf.AddNewCruise(mik:integer; fpath:string; cr_id:int64);
Var
  platf, inst, proj, country_name, notes, orig_cr: string;
  platform_id, institute_id, country_id, project_id, c:integer;

  ncid, idp_ins, idp_ve, idp_pr, idp_orig_cr: integer;
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
     nc_inq_varid(ncid, pAnsiChar('Project'),   idp_pr);
     nc_inq_varid(ncid, pAnsiChar('originators_cruise_identifier'), idp_orig_cr);


     start :=GetMemory(SizeOf(TArraySize_t)*2);
     start^[0]:=mik;

       orig_cr:='';
       for c:=0 to strlensmall-1 do begin
         start^[1]:=c;
         setlength(ncchar_arr, 1);
         nc_get_var1_text(ncid, idp_orig_cr, start^, ncchar_arr); //for char
         orig_cr:=orig_cr+pAnsiChar(ncchar_arr);
       end;

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

       proj:='';
       for c:=0 to strlen-1 do begin
         start^[1]:=c;
         setlength(ncchar_arr, 1);
         nc_get_var1_text(ncid, idp_ins, start^, ncchar_arr); //for char
         proj:=proj+pAnsiChar(ncchar_arr);
       end;

    finally
      FreeMemory(start);
      nc_close(ncid);
    end;

    with Qt do begin
       Close;
        SQL.Clear;
        SQL.add(' SELECT ID, NAME FROM COUNTRY WHERE ');
        SQL.add(' ISO3166_CODE='+QuotedStr(UpperCase(copy(ncdata_arr[mik].cr_name, 1, 2))));
      //  showmessage(sql.Text);
        Open;
         if not Qt.IsEmpty then begin
           country_id:=Qt.Fields[0].Value;
           country_name:=Qt.Fields[1].Value;
         end else begin
          country_id:=0;
          country_name:='';
         end;
       Close;
    end;

    notes:='';
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
      if platform_id=0 then notes:=notes+'Platform: '+platf+#13;
    end;

    institute_id:=0;
    if trim(inst)<>'' then begin
      with Qt do begin
       Close;
        SQL.Clear;
        SQL.add(' SELECT ID FROM INSTITUTE WHERE NAME ');
        SQL.add(' LIKE ('+QuotedStr(UpperCase(copy(inst, 1, 25))+'%')+')');
       Open;
        if not Qt.IsEmpty then institute_id:=Qt.Fields[0].Value else institute_id:=0;
       Close;
      end;
      if institute_id=0 then notes:=notes+'Institute: '+inst+#13;
    end;

    project_id:=0;
    if trim(proj)<>'' then begin
      with Qt do begin
       Close;
        SQL.Clear;
        SQL.add(' SELECT ID FROM PROJECT WHERE NAME ');
        SQL.add(' LIKE ('+QuotedStr(UpperCase(copy(inst, 1, 25))+'%')+')');
       Open;
        if not Qt.IsEmpty then project_id:=Qt.Fields[0].Value else project_id:=0;
       Close;
      end;
      if project_id=0 then notes:=notes+'Project: '+proj+#13;
    end;

    mLog.lines.add('Adding new cruise: '+ncdata_arr[mik].cr_name+', '+
                   'Orig. cruise: '+orig_cr+', '+
                   'Platform: '+platf+' ['+inttostr(platform_id)+'], '+
                   'Country: '+country_name+' ['+inttostr(country_id)+'], '+
                   'Institute: '+inst+' ['+inttostr(institute_id)+']');


    if chkWrite.checked then begin
     PutFDBCruise(Qt, cr_id, platform_id, 7, institute_id, project_id,
      ncdata_arr[mik].cr_name, orig_cr, null, notes, null, null, now, now, now, now);
     Trt.CommitRetaining;
    end;

    setlength(crdata_arr, length(crdata_arr)+1);
    crdata_arr[high(crdata_arr)].cruise_id:=cr_id;
    crdata_arr[high(crdata_arr)].expocode:=ncdata_arr[mik].cr_name;
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

procedure Tfrmload_wod_netcdf.Button4Click(Sender: TObject);
Var
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
try
  TRt:=TSQLTransaction.Create(nil);
  TRt.DataBase:=frmdm.IBDB;

  Qt:=TSQLQuery.Create(nil);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

  with Qt do begin
   Close;
    SQL.Clear;
    SQL.add(' SELECT ID FROM CRUISE ');
    SQL.add(' WHERE SOURCE_ID=7 ');
    SQL.add(' ORDER BY ID ');
   Open;
  end;

  while not Qt.EOF do begin
      UpdateCruiseInfo(frmdm.IBDB, Qt.FieldByName('ID').Value);
    Qt.Next;
  end;

finally
  Trt.Commit;
  Qt.Free;
  Trt.Free;
end;
end;

procedure Tfrmload_wod_netcdf.Button5Click(Sender: TObject);
Var
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
   SQL.add(' SELECT CRUISE.ID, EXPOCODE FROM CRUISE, PLATFORM ');
   SQL.add(' WHERE CRUISE.PLATFORM_ID=PLATFORM.ID AND ');
   SQL.add(' SOURCE_ID=7 AND PLATFORM.NAME='+QuotedStr('UNKNOWN'));
   SQL.add(' AND Extract(year from CRUISE.DATE_ADDED)=2026');
   SQL.add(' ORDER BY EXPOCODE ');
  Open;
  Last;
  First;
 end;
 showmessage(inttostr(Qt.RecordCount));

 while not Qt.EOF do begin
  //id:=Qt.FieldByName('ID').Value;
 // expo0:=Qt.FieldByName('EXPOCODE').Value;



  Qt.Next;
 end;

finally
    Trt.Commit;
  Qt.Free;
  Trt.Free;
end;

end;

procedure Tfrmload_wod_netcdf.Button6Click(Sender: TObject);
Var
  dat: text;
  fname, f_ins:string;
  yy, mik, k, ii: integer;
begin
mLog.Clear;
mik:=-1;
ncall_arr:=nil; //Cleaning

for ii:=1 to 2 do begin
 case ii of
   1: f_ins:='osd';
   2: f_ins:='ctd';
   3: f_ins:='apb';
   4: f_ins:='drb';
   5: f_ins:='gld';
   6: f_ins:='mrb';
   7: f_ins:='xbt';
   8: f_ins:='pfl';
 end;

 mLog.lines.add('Processing '+f_ins);

  fname:=inttostr(1800)+PathDelim+'wod_'+f_ins+'_'+inttostr(1800)+'.nc';
  if FileExists(eDataPath.Text + fname) then begin
   GetAllNC(fname, mik);
   mLog.lines.add(inttostr(1800));
  end;

  for yy:=1900 to 2025 do begin
   fname:=inttostr(yy)+PathDelim+'wod_'+f_ins+'_'+inttostr(yy)+'.nc';
 //  mLog.lines.add(eDataPath.Text + fname);
   if FileExists(eDataPath.Text + fname) then begin
     GetAllNC(fname, mik);
     mLog.lines.add(inttostr(yy));
   end;
  end;
end; // 8 instruments
 Assignfile(dat, GlobalUnloadPath+'wod_'+f_ins+'_cruises.txt'); rewrite(dat);
 for k:=0 to mik-1 do begin
  writeln(dat,ncall_arr[k].expocode, #9,
              ncall_arr[k].st_num, #9,
              ncall_arr[k].vessel, #9,
              ncall_arr[k].institute);

 end;
 Closefile(dat);
end;

Procedure Tfrmload_wod_netcdf.GetAllNC(fname:string; Var mik:integer);
Var
  ncid, idp, idp_cr, idp_ve, idp_ins, idp_cast: integer;

  cast:int64;
  lenp: size_t;
  k, c, fl, cc: integer;

  ncchar_arr: array of PAnsiChar;
  ncint_arr: array of Int64;

  start0, start: PArraySize_t;
  wod_cr, wod_ve, wod_ins: string;
begin
try
   nc_open(pansichar(eDataPath.Text+fname), NC_NOWRITE, ncid);
   nc_inq_dimid(ncid, pAnsiChar('casts'), idp);
   nc_inq_dimlen(ncid, idp, lenp);

   nc_inq_varid(ncid, pAnsiChar('WOD_cruise_identifier'), idp_cr);
 //  nc_inq_varid(ncid, pAnsiChar('wod_unique_cast'), idp_cast);
   nc_inq_varid(ncid, pAnsiChar('Platform'), idp_ve);
   nc_inq_varid(ncid, pAnsiChar('Institute'), idp_ins);

   start0:=GetMemory(SizeOf(TArraySize_t));
   start :=GetMemory(SizeOf(TArraySize_t)*2);

   for k:=0 to lenp-1 do begin  //loop over casts
     start^[0]:=k;
     start0^[0]:=k;

  {   setlength(ncint_arr, 1);
     nc_get_var1_long(ncid, idp_cast, start0^, ncint_arr);
     cast:=ncint_arr[0];  }

     wod_cr:='';
     for c:=0 to strlensmall-1 do begin
       start^[1]:=c;
       setlength(ncchar_arr, 1);
       nc_get_var1_text(ncid, idp_cr, start^, ncchar_arr); //for char
       wod_cr:=wod_cr+pAnsiChar(ncchar_arr);
     end;

     fl:=0;
     for cc:=0 to high(ncall_arr) do
       if ncall_arr[cc].expocode=wod_cr then begin
        fl:=1;
        ncall_arr[cc].st_num:=ncall_arr[cc].st_num+1;
       end;

     if fl=0 then begin
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
      end;

       inc(mik);
       setlength(ncall_arr, mik+1);

       ncall_arr[mik].st_num:=1;
       ncall_arr[mik].expocode:=wod_cr;
       ncall_arr[mik].vessel:=wod_ve;
       ncall_arr[mik].institute:=wod_ins;
     end;

   //  showmessage('here');
   end;

  finally
    FreeMemory(start);
    nc_close(ncid);
  end;

end;



procedure Tfrmload_wod_netcdf.Button7Click(Sender: TObject);
Type
  DBCAST=record
    id:int64;
    wod_cast_id:int64;  //unique cast id
end;
Var
  wod_cast_id: array of int64;
  db_cast_arr: array of DBCAST;
  mik, ii, yy, k, db, nc, fl: integer;
  f_ins, fname:string;
  ncid, idp, idp_cast: integer;
  lenp: size_t;
  ncint_arr: array of Int64;
  start0: PArraySize_t;

  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
  mik:=-1;
  for ii:=1 to 2 do begin
   case ii of
     1: f_ins:='osd';
     2: f_ins:='ctd';
   end;
  // mLog.Lines.add(f_ins);

   for yy:=1800 to YearOf(now) do begin
     fname:=inttostr(yy)+PathDelim+'wod_'+f_ins+'_'+inttostr(yy)+'.nc';
     if not FileExists(eDataPath.Text+fname) then Continue;
     try
       nc_open(pansichar(eDataPath.Text+fname), NC_NOWRITE, ncid);
       nc_inq_dimid(ncid, pAnsiChar('casts'), idp);
       nc_inq_dimlen(ncid, idp, lenp);
       nc_inq_varid(ncid, pAnsiChar('wod_unique_cast'), idp_cast);

       start0:=GetMemory(SizeOf(TArraySize_t));

       for k:=0 to lenp-1 do begin  //loop over casts
         start0^[0]:=k;
         setlength(ncint_arr, 1);
         nc_get_var1_long(ncid, idp_cast, start0^, ncint_arr);
         inc(mik);
         setlength(wod_cast_id, mik+1);
         wod_cast_id[mik]:=ncint_arr[0];
       end;
     finally
       nc_close(ncid);
     end;
   end; //years
 end; //instruments
 mLog.Lines.add('Stations in netCDF: '+inttostr(mik));


  try
    TRt:=TSQLTransaction.Create(nil);
    TRt.DataBase:=frmdm.IBDB;

    Qt:=TSQLQuery.Create(nil);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

   with Qt do begin
    Close;
     SQL.Clear;
     SQL.add(' SELECT ID, ST_ID_ORIGIN FROM STATION ');
     SQL.add(' WHERE ID BETWEEN 30000001 AND 50000000 ');
     SQL.add(' ORDER BY ST_ID_ORIGIN ');
    Open;
   end;

   mik:=-1;
   while not Qt.EOF do begin
    inc(mik);
    setlength(db_cast_arr, mik+1);
    db_cast_arr[mik].id:=Qt.FieldByName('ID').Value;
    db_cast_arr[mik].wod_cast_id:=Qt.FieldByName('ST_ID_ORIGIN').Value;
    Qt.Next;
   end;
  finally
    Trt.Commit;
    Qt.Free;
    Trt.Free;
  end;
  mLog.Lines.add('Stations in DB: '+inttostr(mik));

  for db:=0 to length(db_cast_arr)-1 do begin
   fl:=0;
   for nc:=0 to length(wod_cast_id)-1 do begin
     if db_cast_arr[db].wod_cast_id=wod_cast_id[nc] then begin
      fl:=1;
      Delete(wod_cast_id, nc, 1);
      break;
     end;
   end;
   if fl=0 then begin
    mLog.Lines.Add('Removed: '+inttostr(db_cast_arr[db].id));

   end;
 //  if db mod 10000=0 then mLog.Lines.Add(inttostr(db));
  end;
end;

procedure Tfrmload_wod_netcdf.Button8Click(Sender: TObject);
Type
  DBCR=record
    id:int64;
    expocode:string;
end;
Var
  expocode: array of string;
  db_cr: array of DBCR;
  mik, ii, yy, k, db, nc, fl, c: integer;
  f_ins, fname, wod_cr:string;
  ncid, idp, idp_cr: integer;
  lenp: size_t;
  ncchar_arr: array of PAnsiChar;
  start: PArraySize_t;
  st_expo: variant;

  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
  mik:=-1;
  for ii:=1 to 2 do begin
   case ii of
     1: f_ins:='osd';
     2: f_ins:='ctd';
   end;

   for yy:=1800 to YearOf(now) do begin
     fname:=inttostr(yy)+PathDelim+'wod_'+f_ins+'_'+inttostr(yy)+'.nc';
     if not FileExists(eDataPath.Text+fname) then Continue;
     try
      nc_open(pansichar(eDataPath.Text+fname), NC_NOWRITE, ncid);
      nc_inq_dimid(ncid, pAnsiChar('casts'), idp);
      nc_inq_dimlen(ncid, idp, lenp);
      nc_inq_varid(ncid, pAnsiChar('WOD_cruise_identifier'), idp_cr);

      start :=GetMemory(SizeOf(TArraySize_t)*2);

    //  showmessage(inttostr(lenp));

      for k:=0 to lenp-1 do begin  //loop over casts
       start^[0]:=k;
       wod_cr:='';
       for c:=0 to strlensmall-1 do begin
         start^[1]:=c;
         setlength(ncchar_arr, 1);
         nc_get_var1_text(ncid, idp_cr, start^, ncchar_arr); //for char
         wod_cr:=wod_cr+pAnsiChar(ncchar_arr);
       end;

    //   showmessage(wod_cr);

       fl:=0;
       for c:=0 to length(expocode)-1 do begin
        if expocode[c]=wod_cr then begin
          fl:=1;
          break;
        end;
       end;
       if fl=0 then begin
         inc(mik);
         setlength(expocode, mik+1);
         expocode[mik]:=wod_cr;
       end
    end;
     finally
      FreeMemory(start);
      nc_close(ncid);
     end;
   end; //years
 end; //instruments
 mLog.Lines.add('Cruises in netCDF: '+inttostr(mik));

  try
    TRt:=TSQLTransaction.Create(nil);
    TRt.DataBase:=frmdm.IBDB;

    Qt:=TSQLQuery.Create(nil);
    Qt.Database:=frmdm.IBDB;
    Qt.Transaction:=TRt;

   with Qt do begin
    Close;
     SQL.Clear;
     SQL.add(' SELECT DISTINCT(EXPOCODE) FROM CRUISE ');
     SQL.add(' WHERE SOURCE_ID=7 ');
     SQL.add(' ORDER BY EXPOCODE ');
    Open;
   end;

   mik:=-1;
   while not Qt.EOF do begin
      inc(mik);
      setlength(db_cr, mik+1);
      //db_cr[mik].id:=Qt.FieldByName('ID').Value;
      db_cr[mik].expocode:=Qt.FieldByName('EXPOCODE').Value;
    Qt.Next;
   end;


  finally
    Trt.Commit;
    Qt.Free;
    Trt.Free;
  end;
  mLog.Lines.add('Cruises in DB: '+inttostr(mik));

  for db:=0 to length(db_cr)-1 do begin
   fl:=0;
   for nc:=0 to length(expocode)-1 do begin
     if db_cr[db].expocode=expocode[nc] then begin
      fl:=1;
      Delete(expocode, nc, 1);
      break;
     end;
   end;
   if fl=0 then begin
    mLog.Lines.Add('Removed: '+db_cr[db].expocode);

   end;
 //  if db mod 10000=0 then mLog.Lines.Add(inttostr(db));
  end;

end;

end.

