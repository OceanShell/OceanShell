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
    procedure WriteData;
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
  WriteData;

  mLog.Lines.Add('Done!');
  mLog.Lines.Add('');
  Application.ProcessMessages;
 end;

 frmosmain.DatabaseInfo;
 Showmessage('Completed!');
end;


procedure TfrmLoadITP.WriteData;
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

 //showmessage(inttostr(id_min)+'   '+inttostr(id_max));

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

    cruise_id:=10000000+strtoint(stvessel);

  //  showmessage(inttostr(id)+'   '+inttostr(cruise_id));


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
        ParamByName('DATE_ADDED'       ).Value:=Now;
        ParamByName('DATE_UPDATED'     ).Value:=Now;
        ExecSQL;
       end;
       inc(cnt_added);
       frmdm.TR.CommitRetaining;
      end;
    end;
    { except
       mLog.Lines.Add(CurFile);
       TrT.RollbackRetaining;
     end;  }
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
  //   frmosmain.ProgressBar1.Position:=frmosmain.ProgressBar1.Position+1;
  //   Application.processMessages;

     CloseFile(Dat);
  end;

  mLog.Lines.Add('Added '+IntToStr(cnt_added)+' stations');
  Application.ProcessMessages;
end;


end.
