unit osload_itp;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, DateUtils, DB, SQLDB, Math, Zipper;

type

  { TfrmLoadITP }

  TfrmLoadITP = class(TForm)
    btnOpenZIP: TButton;
    btnLoad: TButton;
    chkShowMetadata: TCheckBox;
    ListBox1: TListBox;
    ListBox2: TListBox;
    mLog: TMemo;

    procedure btnOpenZIPClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);

  private
    { Private declarations }
    procedure WriteData(ITP_ID:integer);
    procedure UpdateCruiseInfo(ITP_ID:integer);
  public
    { Public declarations }
  end;

var
  frmLoadITP: TfrmLoadITP;
  ITP_in_path, ITP_out_path, ITP_cruise:string;
  ITP_isfinal:boolean=false;


implementation

{$R *.lfm}

uses osmain, Procedures, dm, GibbsSeaWater;


procedure TfrmLoadITP.btnOpenZIPClick(Sender: TObject);
Var
  k: integer;
begin
 mLog.Clear;
 ListBox2.Clear;

 // Selecting data in ZIP archive
 frmosmain.OD.Filter:='Zip files|*.zip';
 frmosmain.OD.Options:=frmosmain.OD.Options+[ofAllowMultiSelect];
 if frmosmain.OD.Execute then begin
  for k:=0 to frmosmain.OD.Files.Count-1 do
    ListBox2.Items.Add(ExtractFileName(frmosmain.OD.Files[k]));

  ITP_in_path:=ExtractFilePath(frmosmain.OD.Files[0]);
  btnLoad.Enabled:=true;
 end;
end;


procedure TfrmLoadITP.btnLoadClick(Sender: TObject);
Var
  UnZipper: TUnZipper;
  fdb:TSearchRec;
  zipfile:string;
  k: integer;
begin
 // Path to temporal folder
 ITP_out_path:=GlobalUnloadPath+PathDelim+'temp'+PathDelim;
   if not DirectoryExists(ITP_out_path) then CreateDir(ITP_out_path);

 btnOpenZIP.Enabled:=false;
 btnLoad.Enabled:=false;

 // loop over ZIP files
 for k:=0 to listbox2.Items.Count-1 do begin
  ClearDir(ITP_out_path);

  zipfile:=ITP_in_path+listbox2.Items.Strings[k];

  ListBox2.ItemIndex:=k;

 // Unzipping data into temp folder
  UnZipper := TUnZipper.Create;
  try
    UnZipper.FileName := zipfile;
    UnZipper.OutputPath := ITP_out_path;
    UnZipper.Examine;
    UnZipper.UnZipAllFiles;
  finally
    UnZipper.Free;
  end;

  // Reading file names into listbox (only for CTD data)
   fdb.Name:='';
    listbox1.Clear;
     FindFirst(ITP_out_path+'*.dat',faAnyFile, fdb);
   if (fdb.Name<>'') and (pos('grd',fdb.Name)>0) then listbox1.Items.Add(fdb.Name);

   while findnext(fdb)=0 do
   if (pos('grd',fdb.Name)>0) then Listbox1.Items.Add(fdb.Name);

  // checking if the file is final or realtime
  if Pos('final', ExtractFileName(zipfile))>0 then ITP_isfinal:=true else ITP_isfinal:=false;


  // cruise number
  if ITP_isfinal=true then
   ITP_cruise:=copy(ExtractFileName(zipfile), 4, length(ExtractFileName(zipfile))-12) else
   ITP_cruise:=copy(ExtractFileName(zipfile), 4, length(ExtractFileName(zipfile))-14);

  mLog.Lines.Add('Processing '+ExtractFileName(zipfile)+'...');
  Application.ProcessMessages;

  (* THE MAIN PROCEDURE - WRITING DATA TO DB *)
  WriteData(StrToInt(ITP_cruise));

  UpdateCruiseInfo(StrToInt(ITP_cruise));

  mLog.Lines.Add('Done!');
  mLog.Lines.Add('');
  Application.ProcessMessages;
 end;

 frmosmain.DatabaseInfo;

 btnOpenZIP.Enabled:=true;
 btnLoad.Enabled:=true;

 Showmessage('Completed!');
end;


procedure TfrmLoadITP.WriteData(ITP_ID:integer);
Var
dat:text;
k,yyyy, ndepth, id, row, levnum, p, oxy_fl, c, ff, cast, pp, units_id, maxID:integer;
yy, mn, dd, hour, min, sec, msec:word;
hh,mm,ss,mss:real;
date1, lon, lat:real;
pres, lev, temp, sal, oxy, u, v, w, turb, chl, cdom, par, nobs, val, lev_m:real;
st, CurFile, tbl:string;
stDate, StTime:TDateTime;
stvessel, stnumincruise, st_param, buf_str:string;
withdepth:boolean;

TempList:TListBox;

QCFlag, PQF1, PQF2, SQF: integer;
tmp1, tmp2:real;

cruise_id, ID_MIN, ID_MAX, cnt_added:integer;
begin
 ID_MIN:=10000000+strtoint(ITP_cruise)*10000;
 ID_MAX:=10000000+strtoint(ITP_cruise)*10000+9999;

 cnt_added:=0;

 cruise_id:=10000000+ITP_ID;

 //showmessage(inttostr(id_min)+'   '+inttostr(id_max));

   (* checking if buoy is already in the database *)
   with frmdm.q1 do begin
    Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM CRUISE WHERE ID=:ID ');
     ParamByName('ID').AsInteger:= cruise_id;
    Open;
   end;

   if frmdm.q1.IsEmpty=true then begin
     with frmdm.q2 do begin
       Close;
        Sql.Clear;
        SQL.Add(' SELECT ID FROM PLATFORM ');
        SQL.Add(' WHERE ID=:ID ');
        ParamByName('ID').Value:=cruise_id;
       Open;
      end;
     if frmdm.q2.IsEmpty then begin
      with frmdm.q3 do begin
       Close;
        Sql.Clear;
        SQL.Add(' INSERT INTO PLATFORM ');
        SQL.Add(' (ID, NAME, COUNTRY_ID) ');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :name, :country_id) ');
        ParamByName('ID').Value:=cruise_id;
        ParamByName('name').Value:='ITP '+ inttostr(ITP_ID);
        ParamByName('country_id').Value:=186;
       ExecSQL;
      end;
      frmdm.TR.CommitRetaining;
    end;

    with frmdm.Q2 do begin
     Close;
      SQL.Clear;
      SQL.Add('insert into CRUISE');
      SQL.Add(' (ID, platform_id, source_id, institute_id, project_id, ');
      SQL.Add(' DATE_ADDED, DATE_UPDATED, DATE_START_TOTAL, DATE_END_TOTAL, ');
      SQL.Add(' DATE_START_DATABASE, DATE_END_DATABASE, CRUISE_NUMBER,');
      SQL.Add(' STATIONS_TOTAL, STATIONS_DATABASE, STATIONS_DUPLICATES) ');
      SQL.Add(' VALUES ' );
      SQL.Add(' (:ID, :platform_id, :source_id, :institute_id, :project_id, ');
      SQL.Add(' :DATE_ADDED, :DATE_UPDATED, :DATE_START_TOTAL, :DATE_END_TOTAL, ');
      SQL.Add(' :DATE_START_DATABASE, :DATE_END_DATABASE, :CRUISE_NUMBER, ');
      SQL.Add(' :STATIONS_TOTAL, :STATIONS_DATABASE, :STATIONS_DUPLICATES) ');
      ParamByName('ID').Value:=Cruise_ID;
      ParamByName('platform_id').Value:=Cruise_ID;
      ParamByName('source_id').Value:=2;
      ParamByName('institute_id').Value:=244;
      ParamByName('project_id').Value:=165;
      ParamByName('date_added').Value:=now;
      ParamByName('date_updated').Value:=now;
      ParamByName('date_start_total').Value:=now;
      ParamByName('date_end_total').Value:=now;
      ParamByName('date_start_database').Value:=now;
      ParamByName('date_end_database').Value:=now;
      ParamByName('cruise_number').Value:=ITP_ID;
      ParamByName('stations_total').Value:=0;
      ParamByName('stations_database').Value:=0;
      ParamByName('stations_duplicates').Value:=0;
     ExecSQL;
    end;
    frmdm.TR.CommitRetaining;
  end;

  (* If FINAL then removing old (relatime) stations from the database *)
  if ITP_isfinal=true then begin
   QCFlag:=4;
   PQF1:=4;
   PQF2:=4;
   SQF:=0;
   with frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' DELETE FROM STATION ');
      SQL.Add(' WHERE ID BETWEEN :ID_MIN AND :ID_MAX ');
      ParamByName('ID_MIN').AsInteger:=ID_MIN;
      ParamByName('ID_MAX').AsInteger:=ID_MAX;
     ExecSQL;
    end;
    frmdm.TR.CommitRetaining;
  end;


  (* if realtime data then selecting the last exisitng station *)
  if ITP_isfinal=false then begin
   QCFlag:=0;
   PQF1:=0;
   PQF2:=0;
   SQF:=0;
   with frmdm.q1 do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT MAX(ID) FROM STATION ');
      SQL.Add(' WHERE ID BETWEEN :ID_MIN AND :ID_MAX ');
      ParamByName('ID_MIN').AsInteger:=ID_MIN;
      ParamByName('ID_MAX').AsInteger:=ID_MAX;
     Open;
      MaxID:=frmdm.q1.Fields[0].AsInteger;
     Close;
    end;
    frmdm.TR.CommitRetaining;
    if MaxID=0 then MaxID:=ID_MIN;
  end;

//  showmessage(inttostr(maxID));

  For ff:=0 to ListBox1.Count-1 do begin

    CurFile:=ListBox1.Items.Strings[ff];


    ListBox1.ItemIndex:=ff;
    Application.ProcessMessages;

    p:=4; stvessel:='';
    while not (curFile[p]='g') do begin
      stvessel:=stvessel+curFile[p];
      inc(p);
    end;
    stNumincruise:=Inttostr(Strtoint(copy(curFile,length(curFile)-7,4)));

    cast:=1;

    id:=10000000+strtoint(stvessel)*10000+strtoint(stnumincruise);


    AssignFile(dat, ITP_out_path+CurFile); Reset(dat);
  //  try
      readln(dat, st);

    //  if copy(st, 10, 10) = 'deployment' then cast:=strtoint(trim(copy(st,
      readln(dat, st);
     // readln(dat, yyyy, date, lon, lat, ndepth);
    // 2008   68.26684  -109.6607  83.9657  757
      yyyy:=StrToInt(trim(copy(st, 1, 4)));
      if lowercase(trim(copy(st, 7, 9)))<>'nan'   then date1:=StrToFloat(trim(copy(st, 7, 9)))  else date1:=-999;
      if lowercase(trim(copy(st, 17, 10)))<>'nan' then lon :=StrToFloat(trim(copy(st, 17, 10))) else lon:=-999;
      if lowercase(trim(copy(st, 28, 8)))<>'nan'  then lat :=StrToFloat(trim(copy(st, 28, 8)))  else lat:=-999;
      if lowercase(trim(copy(st, 37, 4)))<>'nan'  then ndepth:=StrToInt(trim(copy(st, 37, 4)))  else ndepth:=-999;
  //   except
  //     Showmessage(CurFile);
  //  end;


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

    if chkShowMetadata.Checked=true then
      mLog.Lines.Add(inttostr(id)
      +#9+DateTimetostr(stDate)
      +#9+floattostr(lon)
      +#9+floattostr(lat));

      // if final of realtime updated
      if (ITP_isfinal=true) or (ID>MaxID) then begin
       try
       with frmdm.q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' INSERT INTO STATION ' );
        SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ' );
        SQL.Add('  ST_NUMBER_ORIGIN, CAST_NUMBER, QCFLAG, ' );
        SQL.Add('  STVERSION, DUPLICATE, MERGED, DATE_ADDED, DATE_UPDATED)' );
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ' );
        SQL.Add('  :ST_NUMBER_ORIGIN, :CAST_NUMBER, :QCFLAG, ' );
        SQL.Add('   :STVERSION, :DUPLICATE, :MERGED, :DATE_ADDED, :DATE_UPDATED) ' );
        ParamByName('ID'               ).Value:=ID;
        ParamByName('LATITUDE'         ).Value:=lat;
        ParamByName('LONGITUDE'        ).Value:=lon;
        ParamByName('DATEANDTIME'      ).Value:=StDate;
        ParamByName('CRUISE_ID'        ).Value:=Cruise_ID;
        ParamByName('ST_NUMBER_ORIGIN' ).Value:=stnumincruise;
        ParamByName('CAST_NUMBER'      ).Value:=cast;
        ParamByName('QCFLAG'           ).Value:=QCFlag;
        ParamByName('STVERSION'        ).Value:=0;
        ParamByName('DUPLICATE'        ).Value:=false;
        ParamByName('MERGED'           ).Value:=0;
        ParamByName('DATE_ADDED'       ).Value:=filedatetodatetime(FileAge(CurFile));
        ParamByName('DATE_UPDATED'     ).Value:=filedatetodatetime(FileAge(CurFile));
        ExecSQL;
       end;
       inc(cnt_added);
       frmdm.TR.CommitRetaining;

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
       if st_param='%year day pressure(dbar) temperature(C) salinity' then begin
         readln(dat, tmp1, tmp2, pres, temp, sal);
       end;

       if st_param='%year day pressure(dbar) temperature(C) salinity oxygen(umol/kg)' then  begin
         readln(dat, tmp1, tmp2, pres, temp, sal, oxy);
       end;


       if st_param='%year day pressure(dbar) temperature(C) salinity oxygen(umol/kg) turbidity(10e-4/m s/r) chlorophyll(ug/l) cdom(ppb) par(V)' then begin
         readln(dat, tmp1, tmp2, pres, temp, sal, oxy, turb, chl, cdom, par);
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



          if (val<>-9999) then begin
            if (ITP_isfinal=true) or (ID>MaxID) then begin

          lev_m:=-gibbsseawater.gsw_z_from_p(pres, lat, 0, 0);
           with frmdm.q1 do begin
            Close;
             SQL.Clear;
             SQL.Add(' insert into ');
             SQL.Add(tbl);
             SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF1, PQF2, SQF, UNITS_ID, ');
             SQL.Add('  INSTRUMENT_ID, PROFILE_NUMBER, PROFILE_BEST) ');
             SQL.Add(' values ');
             SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF1, :PQF2, :SQF, :UNITS_ID, ');
             SQL.Add('  :INSTRUMENT_ID, :PROFILE_NUMBER, :PROFILE_BEST) ');
             ParamByName('ID').AsInteger:=id;
             ParamByName('LEV_DBAR').AsFloat:=pres;
             ParamByName('LEV_M').AsFloat:=lev_m;
             ParamByName('VAL').AsFloat:=val;
             ParamByName('PQF1').AsInteger:=PQF1;
             ParamByName('PQF2').AsInteger:=PQF2;
             ParamByName('SQF').AsInteger:=SQF;
             ParamByName('UNITS_ID').AsInteger:=units_id;
             ParamByName('INSTRUMENT_ID').AsInteger:=5;
             ParamByName('PROFILE_NUMBER').AsInteger:=1;
             ParamByName('PROFILE_BEST').AsBoolean:=true;
            ExecSQL;
           end;
           frmdm.TR.CommitRetaining;
          end;
        end;

    end;
  end;

       except
       frmdm.TR.RollbackRetaining;
       mLog.Lines.Add('Insert error: '+st);
       //exit;
       end;
      end;
    end;
  //   frmosmain.ProgressBar1.Position:=frmosmain.ProgressBar1.Position+1;
  //   Application.processMessages;

     CloseFile(Dat);
  end;

  mLog.Lines.Add('Added '+IntToStr(cnt_added)+' stations');
  Application.ProcessMessages;
end;


procedure TfrmLoadITP.UpdateCruiseInfo(ITP_ID:integer);
Var
TRt:TSQLTransaction;
Qt1:TSQLQuery;

cnt, cruise_id: integer;
latmin, latmax, lonmin, lonmax:real;
datemin, datemax, dateupd:TDateTime;
begin

  cruise_id:=10000000+ITP_ID;

  try
      TRt:=TSQLTransaction.Create(self);
      TRt.DataBase:=frmdm.IBDB;

      Qt1:=TSQLQuery.Create(self);
      Qt1.Database:=frmdm.IBDB;
      Qt1.Transaction:=TRt;

      cnt:=0;
      with Qt1 do begin
        Close;
          SQL.Clear;
          SQL.Add(' SELECT ');
          SQL.Add(' min(LATITUDE) as LatMin, ');
          SQL.Add(' max(LATITUDE) as LatMax, ');
          SQL.Add(' min(LONGITUDE) as LonMin, ');
          SQL.Add(' max(LONGITUDE) as LonMax, ');
          SQL.Add(' min(DATEANDTIME) as DateMin, ');
          SQL.Add(' max(DATEANDTIME) as DateMax, ');
          SQL.Add(' max(DATE_UPDATED) as DateUpd, ');
          SQL.Add(' count(ID) as cnt ');
          SQL.Add(' FROM STATION ');
          SQL.Add(' where CRUISE_ID=:CR_ID ');
          ParamByName('CR_ID').AsInteger:=cruise_id;
        Open;
        if Qt1.FieldByName('cnt').AsInteger>0 then begin
          LatMin:=Qt1.FieldByName('LatMin').Value;
          LatMax:=Qt1.FieldByName('LatMax').Value;
          LonMin:=Qt1.FieldByName('LonMin').Value;
          LonMax:=Qt1.FieldByName('LonMax').Value;
          DateMin:=Qt1.FieldByName('DateMin').Value;
          DateMax:=Qt1.FieldByName('DateMax').Value;
          DateUpd:=Qt1.FieldByName('DateUpd').Value;
          cnt:=Qt1.FieldByName('cnt').Value;
        end;
        if Qt1.FieldByName('cnt').AsInteger=0 then begin
          LatMin:=0;
          LatMax:=0;
          LonMin:=0;
          LonMax:=0;
          DateMin:=EncodeDate(1900, 01, 01);
          DateMax:=EncodeDate(1900, 01, 01);
          DateUpd:=EncodeDate(1900, 01, 01);
          cnt:=0;
        end;
      Close;
  end;

        with frmdm.q1 do begin
         Close;
          SQL.Clear;
          SQL.Add(' UPDATE CRUISE SET ');
          SQL.Add(' LATITUDE_MIN=:LatMin, ');
          SQL.Add(' LATITUDE_MAX=:LatMax, ');
          SQL.Add(' LONGITUDE_MIN=:LonMin, ');
          SQL.Add(' LONGITUDE_MAX=:LonMax, ');
          SQL.Add(' DATE_UPDATED=:DateUpd, ');
          SQL.Add(' DATE_START_DATABASE=:DateMin, ');
          SQL.Add(' DATE_START_TOTAL=:DateMin, ');
          SQL.Add(' DATE_END_DATABASE=:DateMax, ');
          SQL.Add(' DATE_END_TOTAL=:DateMax, ');
          SQL.Add(' STATIONS_DATABASE=:cnt, ');
          SQL.Add(' STATIONS_TOTAL=:cnt ');
          SQL.Add(' WHERE ID=:CR_ID ');
          ParamByName('CR_ID').AsInteger:=cruise_id;
          ParamByName('LatMin').Value:=LatMin;
          ParamByName('LatMax').Value:=LatMax;
          ParamByName('LonMin').Value:=LonMin;
          ParamByName('LonMax').Value:=LonMax;
          ParamByName('DateMin').Value:=DateMin;
          ParamByName('DateMax').Value:=DateMax;
          ParamByName('DateUpd').Value:=DateUpd;
          ParamByName('cnt').Value:=cnt;
         ExecSQL;
        end;

        finally
          Qt1.Close;
          Trt.Commit;
          Qt1.Free;
          Trt.Free;
          frmdm.TR.CommitRetaining;
        end;
end;

end.
