unit osload_odv_o4x;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DateUtils,
  DB, SQLDB, IBConnection, Variants, Math, LConvEncoding,

  osmain, dm, driver_fdb, GibbsSeaWater;

type

  { Tfrmload_odv_netcdf }

  Tfrmload_odv_netcdf = class(TForm)
    Button1: TButton;
    mLog: TMemo;
    procedure Button1Click(Sender: TObject);

  private

  public

  end;

var
  frmload_odv_netcdf: Tfrmload_odv_netcdf;

implementation

{$R *.lfm}

{ Tfrmload_odv_netcdf }


procedure Tfrmload_odv_netcdf.Button1Click(Sender: TObject);
Var
  station_id, cruise_id: int64;
  k, cc, md, ndepth, cnt: integer;
  fpath, st, cruise, station: string;
  buf_str, d_str, cr_name: string;
  lon, lat: real;
  dat:text;
  yy, mn, dd: word;
  stdate:TDateTime;
  lev_m, lev_fl, temp, temp_fl, salt, salt_fl, pres: real;
  to_write: boolean=false;

  DB:TIBConnection;
  TR:TSQLTransaction;
  Q, Q2, Q3:TSQLQuery;
begin
  fpath:='X:\Data_Oceanography\AARI_VV\for Sasha Smirnov\Data_2000-2009.o4x';

  cr_name:='Катер "Баренцбург"';
  cruise_id:=6200033;

  try
     TR:=TSQLTransaction.Create(nil);
     DB:=TIBConnection.Create(nil);
     With DB do begin
      DB.DatabaseName:=frmdm.IBDB.DatabaseName;
      DB.UserName:=frmdm.IBDB.UserName;
      DB.Password:=frmdm.IBDB.Password;
      DB.Params:=frmdm.IBDB.Params;
      DB.Transaction:=TR;
     end;

     TR.Database:=DB;

     Q:=TSQLQuery.Create(nil);
     Q.Database:=DB;
     Q.Transaction:=TR;

     with Q do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT MAX(ID) FROM STATION WHERE ');
       SQL.Add(' ID BETWEEN 6200001 AND 6500000 ');
      Open;
        if VarIsNull(Q.Fields[0].Value) then station_id:=6200000 else station_id:=Q.Fields[0].Value;
      Close;
     end;

  AssignFile(dat, fpath); Reset(dat);
  for k:=1 to 10 do readln(dat, st);

  repeat
    readln(dat, st);

    cruise:=trim(copy(CP1251ToUTF8(st), 2, 34));
//    mLog.Lines.Add(cruise+'   '+copy(st, 53, 4));

    yy:=StrToInt(copy(st, 53, 4));
    mn:=StrToInt(copy(st, 47, 2));
    dd:=StrToInt(copy(st, 50, 2));

    stdate:=EncodeDateTime(yy,mn,dd,0,0,0,0);

    lon:=StrToFloat(trim(copy(st, 58, 7)));
    lat:=StrToFloat(trim(copy(st, 66, 7)));
    ndepth:=StrToInt(trim(copy(st, 74, 5)));
    cnt:=StrToInt(trim(copy(st, 85, 5)));

   // mLog.Lines.Add(cruise);

    to_write:=false;
    if (cruise=cr_name) and (yy=2019) then begin
       mLog.Lines.Add(cruise+'   '+floattostr(lat)+'   '+floattostr(lon)+'   '+datetimetostr(stdate));

       inc(station_id);
        PutFDBStation(Q, station_id, lat, lon, stdate, ndepth, cruise_id, null,
           null, 0, 0, 1, null, now, now);
         TR.CommitRetaining;
         to_write:=true;
    end;

    readln(dat, st);

    for k:=1 to cnt do begin
      readln(dat, lev_m, lev_fl, temp, temp_fl, salt, salt_fl);

      if to_write=true then begin
        pres:=roundto(gsw_p_from_z(-lev_m, lat, 0, 0), -2);
        PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp, 0, 0, 0, null,  1, 4, 1, true);
        PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt, 0, 0, 0, null, 28, 4, 1, true);
      end;
    end;

  until eof(dat);

  CloseFile(dat);
  mLog.Lines.Add('=======');
  mLog.Lines.Add('Done!');
  finally
   TR.Commit;
   Q.Free;
   DB.Close(true);
   DB.Free;
   TR.Free;
 end;

end;

end.

