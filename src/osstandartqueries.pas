unit osstandartqueries;

{$mode objfpc}{$H+}

interface


procedure InsertMetadata(Absnum, StFlag, StLat, StLon, StDate, StTime, StSource,
          StVersion, StCountryName, StVesselName, StDepthSource, CountryCode,
          VesselCode, StNumInCruise, ProjectCode, InstituteCode, Instrument,
          SourceUniqueID, SourceDataOrigin, VesselCruiseID:Variant);

procedure InsertParameters(tbl:string; Absnum:integer; LevVal, Value_:real; Flag_:integer);

procedure InsertMeteo(Absnum, TempDry, Tempwet, Pressure, Winddir, Windspeed,
          Cloudcommon, Cloudlow, Cloudtype, Visibility, Humabs, Humrel,
          Waveheight, Wavedir, Waveperiod, Seastate, Weather, Watercolor,
          WaterTransp, SurfTemp, SurfSalt:Variant);

implementation


uses dm, SysUtils, DateUtils, Classes, Dialogs;


procedure InsertMetadata(Absnum, StFlag, StLat, StLon, StDate, StTime, StSource,
          StVersion, StCountryName, StVesselName, StDepthSource, CountryCode,
          VesselCode, StNumInCruise, ProjectCode, InstituteCode, Instrument,
          SourceUniqueID, SourceDataOrigin, VesselCruiseID:Variant);
var
  CountDup:integer;
begin

  with frmdm.q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' Select count(absnum) as CountDup from STATION ');
    SQL.Add(' where StDate=:Date and Sttime=:time and ');
    SQL.Add(' StLat=:Lat and StLon=:Lon ');
    ParamByName('Date').AsDateTime:=StDate;
    ParamByName('Time').AsDateTime:=StTime;
    ParamByName('Lat' ).Asfloat:=StLat;
    ParamByName('Lon' ).AsFloat:=StLon;
    Open;
      CountDup:=FieldByName('CountDup').AsInteger;
    Close;
   end;

   if CountDup>0 then begin
     StVersion:=CountDup+1;
   end;

 with frmdm.q3 do begin
   Close;
    SQL.Clear;
    SQL.Add(' INSERT INTO STATION ' );
    SQL.Add(' (ABSNUM, STFLAG, STLAT, STLON, STDATE, STTIME, STSOURCE, STVERSION, ' );
    SQL.Add(' STCOUNTRYNAME, STVESSELNAME, STDEPTHSOURCE) ' );
    SQL.Add(' VALUES ' );
    SQL.Add(' (:ABSNUM, :STFLAG, :STLAT, :STLON, :STDATE, :STTIME, :STSOURCE, :STVERSION, ');
    SQL.Add(' :STCOUNTRYNAME, :STVESSELNAME, :STDEPTHSOURCE) ' );
    ParamByName('ABSNUM'       ).Value:=Absnum;
    ParamByName('STLAT'        ).Value:=StLat;
    ParamByName('STLON'        ).Value:=StLon;
    ParamByName('STDATE'       ).Value:=StDate;
    ParamByName('STTIME'       ).Value:=StTime;
    ParamByName('STSOURCE'     ).Value:=StSource;
    ParamByName('STVERSION'    ).Value:=StVersion;
    ParamByName('STCOUNTRYNAME').Value:=StCountryName;
    ParamByName('STVesselName' ).Value:=StVesselName;
    ParamByName('STDEPTHSOURCE').Value:=StDepthSource;
    ParamByName('STFlag'       ).Value:=StFlag;
   ExecSQL;
 end;

 frmdm.TR.CommitRetaining;

 with frmdm.q3 do begin
   Close;
    SQL.Clear;
    SQL.Add(' INSERT INTO STATION_Info ' );
    SQL.Add(' (Absnum,CountryCode,VesselCode,StNumInCruise,ProjectCode, ');
    SQL.Add('  InstituteCode, Instrument,SourceUniqueID, SourceDataOrigin, VesselCruiseID) ');
    SQL.Add(' VALUES ' );
    SQL.Add(' (:Absnum,:CountryCode,:VesselCode,:StNumInCruise,:ProjectCode, :InstituteCode, :Instrument, ');
    SQL.Add('  :SourceUniqueID, :SourceDataOrigin, :VesselCruiseID) ');
    ParamByName('ABSNUM'          ).Value:=Absnum;
    ParamByName('CountryCode'     ).Value:=CountryCode;
    ParamByName('VesselCode'      ).Value:=VesselCode;
    ParamByName('StNumInCruise'   ).Value:=StNumInCruise;
    ParamByName('ProjectCode'     ).Value:=ProjectCode;
    ParamByName('InstituteCode'   ).Value:=InstituteCode;
    ParamByName('Instrument'      ).Value:=Instrument;
    ParamByName('SourceUniqueID'  ).Value:=SourceUniqueID;
    ParamByName('SourceDataOrigin').Value:=SourceDataOrigin;
    ParamByName('VesselCruiseID'  ).Value:=VesselCruiseID;
   ExecSQL;
 end;
end;


Procedure InsertParameters(tbl:string; Absnum:integer;  LevVal, Value_:real; Flag_:integer);
Begin
 with frmdm.q3 do begin
  Close;
     SQL.Clear;
     SQL.Add(' insert into ');
     SQL.Add(tbl);
     SQL.Add(' (absnum, Level_, Value_, Flag_) ');
     SQL.Add(' values ');
     SQL.Add(' (:absnum, :Level_, :Value_, :Flag_) ');
    ParamByName('absnum').AsInteger:=absnum;
    ParamByName('Level_').AsFloat:=Levval;
    ParamByName('Value_').AsFloat:=Value_;
    ParamByName('Flag_').AsInteger:=Flag_;
   ExecSQL;
 end;
end;


procedure InsertMeteo(Absnum, TempDry, Tempwet, Pressure, Winddir, Windspeed,
          Cloudcommon, Cloudlow, Cloudtype, Visibility, Humabs, Humrel,
          Waveheight, Wavedir, Waveperiod, Seastate, Weather, Watercolor,
          WaterTransp, SurfTemp, SurfSalt:Variant);
begin

with frmdm.q3 do begin
  Close;
    SQL.Clear;
    SQL.Add(' insert into Meteo ');
    SQL.Add(' (absnum, tempdry, tempwet, pressure, winddir, windspeed, ');
    SQL.Add('  cloudcommon, cloudlow, cloudtype, visibility, humabs,  ');
    SQL.Add('  humrel, waveheight, wavedir, waveperiod, seastate, weather, ');
    SQL.Add('  Watercolor, watertransp, surftemp, surfsalt) ');
    SQL.Add(' values ');
    SQL.Add(' (:absnum, :tempdry, :tempwet, :pressure, :winddir, :windspeed, ');
    SQL.Add('  :cloudcommon, :cloudlow, :cloudtype, :visibility, :humabs,  ');
    SQL.Add('  :humrel, :waveheight, :wavedir, :waveperiod, :seastate, :weather, ');
    SQL.Add('  :watercolor, :watertransp, :surftemp, :surfsalt) ');
    ParamByName('ABSNUM'     ).AsInteger:=Absnum;
    ParamByName('TEMPDRY'    ).Value:=Tempdry;
    ParamByName('TEMPwet'    ).Value:=Tempwet;
    ParamByName('pressure'   ).Value:=pressure;
    ParamByName('winddir'    ).Value:=winddir;
    ParamByName('windspeed'  ).Value:=windspeed;
    ParamByName('Cloudcommon').Value:=Cloudcommon;
    ParamByName('Cloudlow'   ).Value:=Cloudlow;
    ParamByName('Cloudtype'  ).Value:=Cloudtype;
    ParamByName('Visibility' ).Value:=Visibility;
    ParamByName('Humabs'     ).Value:=humabs;
    ParamByName('HumRel'     ).Value:=humrel;
    ParamByName('waveheight' ).Value:=waveheight;
    ParamByName('wavedir'    ).Value:=wavedir;
    ParamByName('waveperiod' ).Value:=waveperiod;
    ParamByName('Seastate'   ).Value:=seastate;
    ParamByName('weather'    ).Value:=weather;
    ParamByName('watercolor' ).Value:=watercolor;
    ParamByName('watertransp').Value:=watertransp;
    ParamByName('SurfTemp'   ).Value:=surftemp;
    ParamByName('SurfSalt'   ).Value:=surfsalt;
   ExecSQL;
 end;
 frmdm.TR.CommitRetaining;
end;

end.
