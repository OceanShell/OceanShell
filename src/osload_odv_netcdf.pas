unit osload_odv_netcdf;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  LConvEncoding, LazUTF8,

  osmain, declarations_netcdf, dm, driver_fdb;

type

  { Tfrmload_odv_netcdf }

  Tfrmload_odv_netcdf = class(TForm)
    mLog: TMemo;
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmload_odv_netcdf: Tfrmload_odv_netcdf;

implementation

{$R *.lfm}

{ Tfrmload_odv_netcdf }

procedure Tfrmload_odv_netcdf.FormShow(Sender: TObject);
Var
  N_stations, N_samples: size_t;
  ip: array of PAnsiChar;
  fpath, cruise, station: string;
  start: PArraySize_t;
  ncid, varidp, st_i, sp, fl, cr_cnt, idp:integer;
  cruise_arr: array [1..200] of string;
  cruise_id: integer;
begin
  fpath:='X:\Data_Oceanography\AARI_VV\2020-2024.nc';

  for sp:=1 to 200 do
    cruise_arr[sp]:='';

  try
    nc_open(pansichar(AnsiString(fpath)), 0, ncid); // only for reading

    nc_inq_dimid(ncid, pAnsiChar('N_STATIONS'), idp);
    nc_inq_dimlen(ncid, idp, N_STATIONS);
    nc_inq_dimid(ncid, pAnsiChar('N_SAMPLES'), idp);
    nc_inq_dimlen(ncid, idp, N_SAMPLES);

    nc_inq_varid (ncid, pAnsiChar('cruise_id'), varidp);

    start:=GetMemory(SizeOf(TArraySize_t)*2); // get memory for start pointer
    cr_cnt:=0;
    for st_i:=0 to n_stations do begin
      start^[0]:=st_i;
      cruise:='';
       for sp:=0 to 17 do begin
         start^[1]:=sp ;//n_sp;
         setlength(ip, 1);
         nc_get_var1_text(ncid, varidp, start^, ip);
         cruise:=cruise+pansichar(utf8string(ip));
       end;
       station:='';
       for sp:=0 to 20 do begin
         start^[1]:=sp ;//n_sp;
         setlength(ip, 1);
         nc_get_var1_text(ncid, varidp, start^, ip);
         station:=station+pansichar(utf8string(ip));
       end;
       mlog.Lines.Add(cruise);

       if trim(cruise)='R/V Severniy Polus' then begin
         cruise_id:=6200001;
         mlog.Lines.Add(station);


       end;

    {   fl:=0;
       for sp:=1 to 200 do
         if cruise_arr[sp]=cruise then fl:=1;

       if fl=0 then begin
         inc(cr_cnt);
         cruise_arr[cr_cnt]:=cruise;
         mlog.Lines.Add(inttostr(cr_cnt)+'   '+cruise);
       end;    }
      end;

   finally
    nc_close(ncid);
   end;

end;

end.

