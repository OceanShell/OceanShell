unit osload_itp;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, IBConnection, DB, SQLDB, Math,
  dynlibs,

  dm, gibbsseawater, osqc_cruiseinfo, driver_fdb;

procedure ITP(DB_main:TIBConnection;
  DataPath, FolderName, buoytype, cruise_number:string;
  StatOnly, isfinal:boolean; var log:text;
  var cnt_add, cnt_upd, cnt_del: integer; var cruise_id:int64);

function GetCreationTime(fn:string):TDateTime;


implementation


procedure ITP(DB_main:TIBConnection;
  DataPath, FolderName, buoytype, cruise_number:string;
  StatOnly, isfinal:boolean; var log:text;
  var cnt_add, cnt_upd, cnt_del: integer; var cruise_id:int64);
var
  platform_id, country_id, source_id, institude_id, project_id: integer;
  station_id:int64;

  data_lst:TStringList;
  fdb:TSearchRec;

  DB:TIBConnection;
  TR:TSQLTransaction;
  Q, Q2, Q3:TSQLQuery;

  dat:text;
  yyyy, ndepth, levnum, pp, units_id, ff, c, md:integer;
  yy, mn, dd, hour, min, sec, msec:word;
  hh,mm,ss,mss:real;
  date1, lon, lat, tmp1, tmp2:real;
  pres, temp, sal, oxy, u, v, w, turb, chl, cdom, par, nobs, val, lev_m:real;
  st, buf_str, CurFile, tbl:string;
  stdate,date_added, date_updated:TDateTime;
  stnumincruise, st_param, platform_name, www, doi:string;
  cast_number, version: smallint;

  instrument_id, profile_number: integer;
  profile_best: boolean;
  expocode, primary_investigator: string;

  QCFlag, PQF1, PQF2, SQF: integer;

 // Func:Tgsw_z_from_p;

  D_itp, D_itp_min, D_add, D_upd: TDateTime;
  toWrite:boolean;
begin
 try
    TR:=TSQLTransaction.Create(nil);
    DB:=TIBConnection.Create(nil);
    With DB do begin
     DB.DatabaseName:=DB_main.DatabaseName;
     DB.UserName:=DB_main.UserName;
     DB.Password:=DB_main.Password;
     DB.Params:=DB_main.Params;
     DB.Transaction:=TR;
    end;

    TR.Database:=DB;

    Q:=TSQLQuery.Create(nil);
    Q.Database:=DB;
    Q.Transaction:=TR;

    Q2:=TSQLQuery.Create(nil);
    Q2.Database:=DB;
    Q2.Transaction:=TR;

    Q3:=TSQLQuery.Create(nil);
    Q3.Database:=DB;
    Q3.Transaction:=TR;

    if buoytype='itp' then cruise_id:=10000000+StrToInt(cruise_number);
    if buoytype='top' then cruise_id:=14000000+StrToInt(cruise_number);

    platform_name:=UpperCase(buoytype)+' '+ cruise_number;
    platform_id  :=cruise_id;
    country_id   :=186;
    source_id    :=2;
    institude_id :=244;
    project_id   :=165;
    doi:='https://doi.org/10.7289/v5mw2f7x';
    www:='https://www.whoi.edu/itp/'+buoytype+cruise_number+'data.html';
    expocode:='';
    primary_investigator:='';

    instrument_id:=11;
    profile_number:=1;
    profile_best:=true;
    cast_number:=1;
    version:=0;

    //Cruise exists?
    with Q do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT ID FROM CRUISE WHERE ID=:ID ');
      ParamByName('ID').Value:= cruise_id;
     Open;
    end;

    writeln(log, 'Cruise_id: '+inttostr(cruise_id));

    //if the cuise doesn't exist
    if Q.IsEmpty=true then begin
      //is platform in the DB?
      with Q2 do begin
        Close;
         Sql.Clear;
         SQL.Add(' SELECT ID FROM PLATFORM ');
         SQL.Add(' WHERE ID=:ID ');
         ParamByName('ID').Value:=cruise_id;
        Open;
       end;

      //if it's not, creating a new platform
      if Q2.IsEmpty then begin
        if not StatOnly then begin
          PutFDBPlatform(Q3, cruise_id, platform_name, country_id, null, now, now);
          TR.CommitRetaining;
        end;
        writeln(log, 'Adding new platform: '+platform_name);
      end;

     //... and a new cruise
     if not StatOnly then begin
       PutFDBCruise(Q3, cruise_id, platform_id, source_id, institude_id,
         project_id, expocode, cruise_number, primary_investigator, null,
         doi, www, null, null, now, now);
       TR.CommitRetaining;
     end;
    writeln(log, 'Adding new cruise: '+inttostr(Cruise_ID));
   end;

    if isfinal=true then begin
      QCFlag:=4;
      PQF1:=4;
      PQF2:=4;
      SQF:=0;
    end;
    if isfinal=false then begin
      QCFlag:=0;
      PQF1:=0;
      PQF2:=0;
      SQF:=0;
    end;

   //list of files
   data_lst:=TStringList.Create;

    // Reading file names into listbox (only for CTD data)
   fdb.Name:='';
     FindFirst(DataPath+PathDelim+FolderName+PathDelim+'*.dat',faAnyFile, fdb);
   if (fdb.Name<>'') and (pos('grd',fdb.Name)>0) then data_lst.Add(fdb.Name);

   while findnext(fdb)=0 do
   if (pos('grd',fdb.Name)>0) then data_lst.Add(fdb.Name);
   FindClose(fdb);


   cnt_add:=0; cnt_upd:=0;
  //showmessage(inttostr(id_min)+'   '+inttostr(id_max));
    For ff:=0 to data_lst.Count-1 do begin

     CurFile:=data_lst.Strings[ff];
     D_itp:=GetCreationTime(DataPath+PathDelim+FolderName+PathDelim+CurFile);
     if ff=0 then D_itp_min:=D_itp;

     stNumincruise:=Inttostr(Strtoint(copy(CurFile,length(CurFile)-7,4)));

     if buoytype='itp' then station_id:=10000000+strtoint(cruise_number)*10000+strtoint(stnumincruise);
     if buoytype='top' then station_id:=14000000+strtoint(cruise_number)*10000+strtoint(stnumincruise);

     with Q do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT DATE_ADDED, DATE_UPDATED FROM STATION WHERE ');
       SQL.Add(' ID=:ID ');
       ParamByName('ID').AsInteger:=station_id;
      Open;
     end;

     if not Q.IsEmpty then begin
       D_add:=Q.FieldByName('DATE_ADDED').AsDateTime;
       D_upd:=Q.FieldByName('DATE_UPDATED').AsDateTime;
       if D_ITP=D_ADD then begin
         writeln(log, inttostr(station_id)+' is up to date');
         towrite:=false;
       end;
       if (D_ITP<>D_ADD) {and (isfinal=true) }then begin
         writeln(log, CurFile+'   '+datetimetostr(D_ITP)+' -> '+DateTimeToStr(D_ADD));
          if not StatOnly then begin
            with Q2 do begin
             Close;
              SQL.Clear;
              SQL.Add(' DELETE FROM STATION ');
              SQL.Add(' WHERE ID=:ID ');
              ParamByName('ID').Value:=station_id;
             ExecSQL;
            end;
            TR.CommitRetaining;
            towrite:=true;
         end; //statonly
         inc(cnt_upd);
       end;

     {  if (D_ITP<>D_ADD) and (isfinal=false) then begin
         towrite:=false;
       end;  }

      Q.Close;
     end else begin
       writeln(log, inttostr(station_id)+' is not found in the DB');
       towrite:=true;
       inc(cnt_add);
     end;

     if towrite = true then begin
     // writeln(log, DataPath+PathDelim+FolderName+PathDelim+CurFile);
      //writeln(log, inttostr(statrion_id));
    //  readln();
      AssignFile(dat, DataPath+PathDelim+FolderName+PathDelim+CurFile); Reset(dat);
       readln(dat, st);
       readln(dat, st);

       c:=0;
       for md:=1 to 5 do begin
        buf_str:='';
        repeat
          inc(c);
          if st[c]<>' ' then buf_str:=buf_str+st[c];
        until (st[c]=' ') or (c=length(st));
         if md<5 then begin
           repeat
             inc(c);
           until (st[c]<>' ');
           c:=c-1;
         end;
         case md of
          1: yyyy:=StrToInt(buf_str);
          2: if lowercase(buf_str)<>'nan' then date1:=StrToFloat(buf_str) else date1:=-999;
          3: if lowercase(buf_str)<>'nan' then lon:=StrToFloat(buf_str) else lon:=-999;
          4: if lowercase(buf_str)<>'nan' then lat:=StrToFloat(buf_str) else lat:=-999;
          5: if lowercase(buf_str)<>'nan' then ndepth:=StrToInt(buf_str) else ndepth:=-999;
         end;
       end;

        if (date1<>-999) and (lat<>-999) and (lon<>-999) then begin
          stDate:=EncodeDateDay(yyyy,trunc(date1));
          decodeDate(stDate, yy, mn, dd);

          hh :=frac(date1)*24;
          hour:=trunc(hh);
          mm :=frac(hh)*60;
          min :=trunc(mm);
          ss :=frac(mm)*60;
          sec :=trunc(ss);
          mss:=frac(ss)*100;
          msec:=trunc(mss);

          StDate:=EncodeDateTime(yy, mn, dd, hour, min, sec, msec);

          date_added:=D_ITP;
          date_updated:=D_ITP;

         { write(#13+inttostr(id)
            +#9+DateTimetostr(stDate)
            +#9+floattostr(lon)
            +#9+floattostr(lat)); }

       (* writing down station *)
       if not StatOnly then begin
         PutFDBStation(Q3, station_id, lat, lon, stdate, null, cruise_id, stnumincruise,
           null, qcflag, version, cast_number, null, date_added, date_updated);
         TR.CommitRetaining;
       end;
       // inc(cnt_added);

             {
      %pressure(dbar) temperature(C) salinity dissolved_oxygen nobs
      %pressure(dbar) temperature(C) salinity nobs
      %pressure(dbar) temperature(C) salinity nobs east(cm/s) north(cm/s) vert(cm/s) nacm
      %pressure(dbar) temperature(C) salinity dissolved_oxygen(umol/kg) nobs turbidity(e-4) chlorophyll_a(ug/l) CDOM(ppb) nbio
      %pressure(dbar) temperature(C) salinity dissolved_oxygen nobs CDOM(ppb) PAR(uE/m^2/s) turbidity(/m/sr)x10^4 chlorophyll-a(ug/l)
      }
           readln(dat, st_param);

           For levnum:=1 to ndepth do begin

             pres:=-9999;
             temp:=-9999;
             sal:=-9999;
             oxy:=-9999;
             cdom:=-9999;
             chl:=-9999;
             turb:=-9999;
             par:=-9999;
             u:=-9999;
             v:=-9999;
             w:=-9999;

             (* FOR FINAL PROFILES *)
             if st_param='%pressure(dbar) temperature(C) salinity dissolved_oxygen nobs' then begin
               readln(dat, pres, temp, sal, oxy);
             end;

             if st_param='%pressure(dbar) temperature(C) salinity nobs' then  begin
               readln(dat, pres, temp, sal);
             end;

             if st_param='%pressure(dbar) temperature(C) salinity nobs east(cm/s) north(cm/s) vert(cm/s) nacm' then begin
               readln(dat, pres, temp, sal, nobs, u, v, w);
             end;

             if st_param='%pressure(dbar) temperature(C) salinity dissolved_oxygen(umol/kg) nobs turbidity(e-4) chlorophyll_a(ug/l) CDOM(ppb) nbio' then begin
               readln(dat, pres, temp, sal, oxy, turb, chl, cdom);
             end;

             if st_param='%pressure(dbar) temperature(C) salinity dissolved_oxygen nobs CDOM(ppb) PAR(uE/m^2/s) turbidity(/m/sr)x10^4 chlorophyll-a(ug/l)' then begin
               readln(dat, pres, temp, sal, oxy, cdom, par, turb, chl);
             end;


             (* FOR REALTIME PROFILES *)
             try
               if copy(st_param, 1, 9)='%year day' then begin

               readln(dat, st);
               c:=0;
               for md:=1 to 10 do begin
                 buf_str:='';
                 repeat
                   inc(c);
                   if st[c]<>' ' then buf_str:=buf_str+st[c];
                 until (st[c]=' ') or (c=length(st));
                 case md of
                   3: if trim(buf_str)<>'' then pres:=StrToFloat(buf_str) else pres:=-9999;
                   4: if trim(buf_str)<>'' then temp:=StrToFloat(buf_str) else temp:=-9999;
                   5: if trim(buf_str)<>'' then sal :=StrToFloat(buf_str) else sal :=-9999;
                   6: if trim(buf_str)<>'' then oxy :=StrToFloat(buf_str) else oxy :=-9999;
                   7: if trim(buf_str)<>'' then turb:=StrToFloat(buf_str) else turb:=-9999;
                   8: if trim(buf_str)<>'' then chl :=StrToFloat(buf_str) else chl :=-9999;
                   9: if trim(buf_str)<>'' then cdom:=StrToFloat(buf_str) else cdom:=-9999;
                  10: if trim(buf_str)<>'' then par :=StrToFloat(buf_str) else par :=-9999;
                 end;
                 if c=length(st) then break;
               end;

            { if st_param='%year day pressure(dbar) temperature(C) salinity' then begin
               readln(dat, tmp1, tmp2, pres, temp, sal);
             end;

             if st_param='%year day pressure(dbar) temperature(C) salinity oxygen(umol/kg)' then  begin
               readln(dat, tmp1, tmp2, pres, temp, sal, oxy);
             end;


             if st_param='%year day pressure(dbar) temperature(C) salinity oxygen(umol/kg) turbidity(10e-4/m s/r) chlorophyll(ug/l) cdom(ppb) par(V)' then begin
               readln(dat, tmp1, tmp2, pres, temp, sal, oxy, turb, chl, cdom, par);
             end;  }

               end;
             except
               writeln(log, floattostr(tmp1)+'   '+floattostr(tmp2)+'   '+
               floattostr(pres)+'   '+floattostr(sal)+'   '+floattostr(oxy));
             end;


            {
            mLog.Lines.Add(inttostr(levnum)
                        +#9+floattostr(pres)
                        +#9+floattostr(temp)
                        +#9+floattostr(sal)
                        +#9+floattostr(oxy)
                        +#9+floattostr(cdom)
                        +#9+floattostr(turb)
                        +#9+floattostr(chl)
                        +#9+floattostr(par)
                        +#9+floattostr(u)
                        +#9+floattostr(v)
                        +#9+floattostr(w)
                        );}

              for pp:=1 to 7 do begin
               // showmessage('here');
                case pp of
                  1: begin
                     tbl:='P_TEMPERATURE';
                      if not isNaN(temp) then val:=temp else val:=-9999;
                     units_id:=1;
                  end;
                  2: begin
                     tbl:='P_SALINITY';
                      if not isNaN(sal)then val:=sal else val:=-9999;
                     units_id:=2;
                  end;
                  3: begin
                     tbl:='P_OXYGEN';
                      if not isNaN(oxy) then val:=oxy else val:=-9999;
                     units_id:=3;
                  end;
                  4: begin
                    tbl:='P_CDOM';
                     if not isNaN(cdom)then val:=cdom else val:=-9999;
                    units_id:=24;
                  end;
                  5: begin
                    tbl:='P_TURBIDITY';
                     if not isNaN(turb)then val:=turb else val:=-9999;
                    units_id:=22;
                  end;
                  6: begin
                    tbl:='P_CHLOROPHYLL';
                     if not isNaN(chl)then val:=chl else val:=-9999;
                    units_id:=4;
                  end;
                  7: begin
                    tbl:='P_PAR';
                     if not isNaN(par)then val:=par else val:=-9999;
                    units_id:=21;
                  end;
                end;
               //  showmessage('here2'+'   '+floattostr(val));
               // mLog.lines.add(tbl+'   '+floattostr(val)+'   '+inttostr(units_id));



                if (val<>-9999) and (not StatOnly) then begin
                  //Func:=Tgsw_z_from_p(GetProcedureAddress(libgswteos, 'gsw_z_from_p'));
                  lev_m:=-gsw_z_from_p(pres, lat, 0, 0);

                  PutFDBProfile(Q3, tbl, station_id, pres, lev_m, val, pqf1,
                    pqf2, sqf, null, units_id, instrument_id, profile_number, profile_best);
                end; // val<>-9999

            end;// 7 parameters

          end; // levels
        end;//coord exist
        // writeln(CurFile+': profiles written');
          TR.CommitRetaining;
          CloseFile(Dat);
      end; //towrite

    end;

    // removing stations that have been deleted from the source
    with Q do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM STATION WHERE ');
       SQL.Add(' CRUISE_ID=:ID ');
       ParamByName('ID').Value:=Cruise_ID;
      Open;
     end;

    cnt_del:=0;
    While not Q.eof do begin
     station_id:=Q.FieldByName('ID').AsInteger;
     if buoytype='itp' then
       CurFile:='itp'+inttostr(strtoint(cruise_number))+
                'grd'+copy(inttostr(station_id), 5, 4)+'.dat';
     if buoytype='top' then
       CurFile:='top'+inttostr(strtoint(cruise_number))+
                'grd'+copy(inttostr(station_id), 5, 4)+'.dat';

     if not fileexists(DataPath+PathDelim+FolderName+PathDelim+CurFile) then begin
       if not StatOnly then begin
        with Q2 do begin
         Close;
           SQL.Clear;
           SQL.Add(' DELETE FROM STATION WHERE ');
           SQL.Add(' ID=:ID ');
           ParamByName('ID').AsInteger:=station_id;
          ExecSQL;
        end;
       TR.CommitRetaining;
      end;
      writeln(log, 'No longer exists: '+CurFile);
      inc(cnt_del);
     end;
     Q.next;
    end;
    Q.Close;

    UpdateCruiseInfo(frmdm.IBDB, cruise_id);

  finally
   TR.Commit;
   Q.Free;
   Q2.Free;
   DB.Close(true);
   DB.Free;
   TR.Free;
  end;
end;


function GetCreationTime(fn:string):TDateTime;
var
  fa:LongInt;
begin
 fa:=FileAge(fn);
 if fa<>-1 then
   Result:=FileDateToDateTime(fa);
end;


end.

