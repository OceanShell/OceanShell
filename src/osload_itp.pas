unit osload_itp;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, DateUtils, DB, SQLDB, Math;

type

  { TfrmLoadITP }

  TfrmLoadITP = class(TForm)
    btnLoadGridData: TButton;
    btnLoadMicro: TButton;
    btnLoadMicroSami: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    btnTimeReapload: TButton;
    Button4: TButton;
    chkShowMetadata: TCheckBox;
    chkShowProfiles: TCheckBox;
    chkWrite: TCheckBox;
    ListBox1: TListBox;
    Memo1: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;

    procedure btnLoadGridDataClick(Sender: TObject);
    procedure btnLoadMicroClick(Sender: TObject);
    procedure btnLoadMicroSamiClick(Sender: TObject);
    procedure btnTimeReaploadClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLoadITP: TfrmLoadITP;
  Path:string;
  Dat:text;

implementation

{$R *.lfm}

uses osmain, Procedures, dm;


procedure TfrmLoadITP.Button1Click(Sender: TObject);
Var
fdb:TSearchRec;
begin
SelectDirectory('Select folder', '' , path);
//path:='C:\_ITP\grddata\';
 if path<>'' then begin
   path:=path+'\';
   fdb.Name:='';
    listbox1.Clear;
     FindFirst(Path+'*.dat',faAnyFile, fdb);
   if fdb.Name<>'' then listbox1.Items.Add(fdb.Name);
  while findnext(fdb)=0 do Listbox1.Items.Add(fdb.Name);
 end;
memo1.Clear;
end;


{%ITP 10, profile 1: year day longitude(E+) latitude(N+) ndepths
2007  253.75003  -132.2286  84.9833  755
%pressure(dbar) temperature(C) salinity nobs
  5.9   -1.5629   28.9234  14
  6.9   -1.5627   28.9244   4
  8.0   -1.5628   28.9235   4}
procedure TfrmLoadITP.Button2Click(Sender: TObject);
Var
k,yyyy, ndepth, id, row, levnum, p, oxy_fl, c, ff, cast, pp, units_id:integer;
yy, mn, dd, hour, min, sec, msec:word;
hh,mm,ss,mss:real;
date1, lon, lat:real;
pres, lev, temp, sal, oxy, u, v, w, turb, chl, cdom, par, nobs, val:real;
st, CurFile, tbl:string;
stDate, StTime:TDateTime;
stvessel, stnumincruise, st_param, buf_str:string;
withdepth:boolean;

TRt:TSQLTransaction;
Qt:TSQLQuery;
TempList:TListBox;

cruise_id:integer;
begin


{frmosmain.ProgressBar1.Position:=0;
frmosmain.ProgressBar1.Max:=ListBox1.Count;  }

 if chkWrite.Checked then begin
   (* temporary transaction for main database *)
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   (* temporary query for main database *)
   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;
 end;

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

    id:=strtoint(stvessel)*10000+strtoint(stnumincruise);

  //  showmessage(copy(curFile,length(curFile)-7,4));

    AssignFile(dat, Path+CurFile); Reset(dat);
    try
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
     except
       Showmessage(CurFile);
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

    if chkShowMetadata.Checked then
      memo1.Lines.Add(inttostr(id)
      +#9+DateTimetostr(stDate)
      +#9+floattostr(lon)
      +#9+floattostr(lat));

    cruise_id:={1000+}strtoint(stvessel);

     if chkWrite.Checked then begin
      try
       with Qt do begin
        Close;
        SQL.Clear;
        SQL.Add(' INSERT INTO STATION ' );
        SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ' );
        SQL.Add('  INSTRUMENT_ID, ST_NUMBER_ORIGIN, CAST_NUMBER, QCFLAG, ' );
        SQL.Add('  STVERSION, DUPLICATE, MERGED, DATE_ADDED)' );
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ' );
        SQL.Add('  :INSTRUMENT_ID, :ST_NUMBER_ORIGIN, :CAST_NUMBER, :QCFLAG, ' );
        SQL.Add('   :STVERSION, :DUPLICATE, :MERGED, :DATE_ADDED) ' );
        ParamByName('ID'               ).Value:=ID;
        ParamByName('LATITUDE'         ).Value:=lat;
        ParamByName('LONGITUDE'        ).Value:=lon;
        ParamByName('DATEANDTIME'      ).Value:=StDate;
        ParamByName('CRUISE_ID'        ).Value:=Cruise_ID; //ID from CRUISE_WOD found by <WOD cruise number identification number>
        ParamByName('INSTRUMENT_ID'    ).Value:=5;
        ParamByName('ST_NUMBER_ORIGIN' ).Value:=stnumincruise;
        ParamByName('CAST_NUMBER'      ).Value:=cast;
        ParamByName('QCFLAG'           ).Value:=4;
        ParamByName('STVERSION'        ).Value:=0;
        ParamByName('DUPLICATE'        ).Value:=false;
        ParamByName('MERGED'           ).Value:=0;
        ParamByName('DATE_ADDED'       ).Value:=Now;
        ExecSQL;
       end;

       Trt.CommitRetaining;
     except
       memo1.Lines.Add(CurFile);
       TrT.RollbackRetaining;
     end;
   end;
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

       if st_param='%pressure(dbar) temperature(C) salinity dissolved_oxygen nobs' then begin
         readln(dat, pres, temp, sal, oxy);
       end;

       if st_param='%pressure(dbar) temperature(C) salinity nobs' then  begin
         readln(dat, pres, temp, sal);
       end;

       if st_param='%pressure(dbar) temperature(C) salinity nobs east(cm/s) north(cm/s) vert(cm/s) nacm' then begin
         readln(dat, pres, temp, sal, oxy, nobs, u, v, w);
       end;

       if st_param='%pressure(dbar) temperature(C) salinity dissolved_oxygen(umol/kg) nobs turbidity(e-4) chlorophyll_a(ug/l) CDOM(ppb) nbio' then begin
         readln(dat, pres, temp, sal, oxy, turb, chl, cdom);
       end;

       if st_param='%pressure(dbar) temperature(C) salinity dissolved_oxygen nobs CDOM(ppb) PAR(uE/m^2/s) turbidity(/m/sr)x10^4 chlorophyll-a(ug/l)' then begin
         readln(dat, pres, temp, sal, oxy, cdom, par, turb, chl);
       end;



      if chkShowProfiles.Checked then
      memo1.Lines.Add(inttostr(levnum)
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
                  );

       if chkWrite.Checked then begin
        for pp:=1 to 7 do begin
         // showmessage('here');
          case pp of
            1: begin
               tbl:='P_TEMPERATURE_ITP';
                if not isNaN(temp) then val:=temp else val:=-9999;
               units_id:=1;
            end;
            2: begin
               tbl:='P_SALINITY_ITP';
                if not isNaN(sal)then val:=sal else val:=-9999;
               units_id:=2;
            end;
            3: begin
               tbl:='P_OXYGEN_ITP';
                if not isNaN(oxy) then val:=oxy else val:=-9999;
               units_id:=3;
            end;
            4: begin
              tbl:='P_CDOM_ITP';
               if not isNaN(cdom)then val:=cdom else val:=-9999;
              units_id:=23;
            end;
            5: begin
              tbl:='P_TURBIDITY_ITP';
               if not isNaN(turb)then val:=turb else val:=-9999;
              units_id:=21;
            end;
            6: begin
              tbl:='P_CHLA_ITP';
               if not isNaN(chl)then val:=chl else val:=-9999;
              units_id:=4;
            end;
            7: begin
              tbl:='P_PAR_ITP';
               if not isNaN(par)then val:=par else val:=-9999;
              units_id:=22;
            end;
          end;
         //  showmessage('here2'+'   '+floattostr(val));
         // memo1.lines.add(tbl+'   '+floattostr(val)+'   '+inttostr(units_id));



          if (val<>-9999) then begin
          try
           with Qt do begin
            Close;
             SQL.Clear;
             SQL.Add(' insert into ');
             SQL.Add(tbl);
             SQL.Add(' (ID, LEV_DBAR, VAL, PQF1, PQF2, UNITS_ID) ');
             SQL.Add(' values ');
             SQL.Add(' (:ID, :LEV_DBAR, :VAL, :PQF1, :PQF2, :UNITS_ID) ');
             ParamByName('ID').AsInteger:=id;
             ParamByName('LEV_DBAR').AsFloat:=pres;
             ParamByName('VAL').AsFloat:=val;
             ParamByName('PQF1').AsInteger:=4;
             ParamByName('PQF2').AsInteger:=4;
             ParamByName('UNITS_ID').AsInteger:=units_id;
            ExecSQL;
           end;
           Trt.CommitRetaining;
          except
           memo1.Lines.Add(CurFile+'   '+floattostr(pres));
           TrT.RollbackRetaining;
          end;
        end;

       end;

    end;
  end;
  //   frmosmain.ProgressBar1.Position:=frmosmain.ProgressBar1.Position+1;
  //   Application.processMessages;

     CloseFile(Dat);
  end;
 end;
 if chkWrite.Checked then begin
  Qt.Close;
  Qt.free;
  TrT.Commit;
  TrT.Free;

  //frmosmain.DatabaseInfo;
 end;
Showmessage('Done!');
end;



procedure TfrmLoadITP.btnLoadMicroClick(Sender: TObject);
begin
//%ITP 54, microcat 7521 at 6 dbar
//%year day latitude longitude temperature(C) salinity
//2011  218.96876  77.001 -140.100   -1.2267   25.8016
end;




procedure TfrmLoadITP.btnLoadGridDataClick(Sender: TObject);
Var
k,yyyy, ndepth, id, row, levnum, p, oxy_fl, c, ff, cast, pp, units_id:integer;
yy, mn, dd, hour, min, sec, msec:word;
hh,mm,ss,mss:real;
date1, lon, lat, tmp1, tmp2 :real;
pres, lev, temp, sal, oxy, u, v, w, turb, chl, cdom, par, nobs, val:real;
st, CurFile, tbl:string;
stDate, StTime:TDateTime;
stvessel, stnumincruise, st_param, buf_str:string;
withdepth:boolean;

TRt:TSQLTransaction;
Qt:TSQLQuery;
TempList:TListBox;

cruise_id:integer;
begin


{frmosmain.ProgressBar1.Position:=0;
frmosmain.ProgressBar1.Max:=ListBox1.Count;  }

 if chkWrite.Checked then begin
   (* temporary transaction for main database *)
   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   (* temporary query for main database *)
   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;
 end;

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

    id:=strtoint(stvessel)*10000+strtoint(stnumincruise);

  //  showmessage(copy(curFile,length(curFile)-7,4));

    AssignFile(dat, Path+CurFile); Reset(dat);
    try
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
     except
       Showmessage(CurFile);
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

   {
    memo1.lines.add(floattostr(hh)+'   '+inttostr(hour));
    memo1.lines.add(floattostr(mm)+'   '+inttostr(min));
    memo1.lines.add(floattostr(ss)+'   '+inttostr(sec));  }



    StDate:=EncodeDateTime(yy, mn, dd, hour, min, sec, msec);

   // memo1.lines.add(datetimetostr(stdate));

    if chkShowMetadata.Checked then
      memo1.Lines.Add(inttostr(id)
      +#9+DateTimetostr(stDate)
      +#9+floattostr(lon)
      +#9+floattostr(lat));

    cruise_id:={1000+}strtoint(stvessel);

     if chkWrite.Checked then begin
      try
       with Qt do begin
        Close;
        SQL.Clear;
        SQL.Add(' INSERT INTO STATION ' );
        SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ' );
        SQL.Add('  INSTRUMENT_ID, ST_NUMBER_ORIGIN, CAST_NUMBER, QCFLAG, ' );
        SQL.Add('  STVERSION, DUPLICATE, MERGED, DATE_ADDED)' );
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ' );
        SQL.Add('  :INSTRUMENT_ID, :ST_NUMBER_ORIGIN, :CAST_NUMBER, :QCFLAG, ' );
        SQL.Add('   :STVERSION, :DUPLICATE, :MERGED, :DATE_ADDED) ' );
        ParamByName('ID'               ).Value:=ID;
        ParamByName('LATITUDE'         ).Value:=lat;
        ParamByName('LONGITUDE'        ).Value:=lon;
        ParamByName('DATEANDTIME'      ).Value:=StDate;
        ParamByName('CRUISE_ID'        ).Value:=Cruise_ID; //ID from CRUISE_WOD found by <WOD cruise number identification number>
        ParamByName('INSTRUMENT_ID'    ).Value:=5;
        ParamByName('ST_NUMBER_ORIGIN' ).Value:=stnumincruise;
        ParamByName('CAST_NUMBER'      ).Value:=cast;
        ParamByName('QCFLAG'           ).Value:=4;
        ParamByName('STVERSION'        ).Value:=0;
        ParamByName('DUPLICATE'        ).Value:=false;
        ParamByName('MERGED'           ).Value:=0;
        ParamByName('DATE_ADDED'       ).Value:=Now;
        ExecSQL;
       end;

       Trt.CommitRetaining;
     except
       memo1.Lines.Add('Error: '+CurFile);
       TrT.RollbackRetaining;
     end;
   end;

{
%year day pressure(dbar) temperature(C) salinity
%year day pressure(dbar) temperature(C) salinity oxygen(umol/kg)
%year day pressure(dbar) temperature(C) salinity oxygen(umol/kg) turbidity(10e-4/m s/r) chlorophyll(ug/l) cdom(ppb) par(V)
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

       if st_param='%year day pressure(dbar) temperature(C) salinity' then begin
         readln(dat, tmp1, tmp2, pres, temp, sal);
       end;

       if st_param='%year day pressure(dbar) temperature(C) salinity oxygen(umol/kg)' then  begin
         readln(dat, tmp1, tmp2, pres, temp, sal, oxy);
       end;


       if st_param='%year day pressure(dbar) temperature(C) salinity oxygen(umol/kg) turbidity(10e-4/m s/r) chlorophyll(ug/l) cdom(ppb) par(V)' then begin
         readln(dat, tmp1, tmp2, pres, temp, sal, oxy, turb, chl, cdom, par);
       end;



      if chkShowProfiles.Checked then
      memo1.Lines.Add(inttostr(levnum)
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
                  );

       if chkWrite.Checked then begin
        for pp:=1 to 7 do begin
         // showmessage('here');
          case pp of
            1: begin
               tbl:='P_TEMPERATURE_ITP';
                if not isNaN(temp) then val:=temp else val:=-9999;
               units_id:=1;
            end;
            2: begin
               tbl:='P_SALINITY_ITP';
                if not isNaN(sal)then val:=sal else val:=-9999;
               units_id:=2;
            end;
            3: begin
               tbl:='P_OXYGEN_ITP';
                if not isNaN(oxy) then val:=oxy else val:=-9999;
               units_id:=3;
            end;
            4: begin
              tbl:='P_CDOM_ITP';
               if not isNaN(cdom)then val:=cdom else val:=-9999;
              units_id:=23;
            end;
            5: begin
              tbl:='P_TURBIDITY_ITP';
               if not isNaN(turb)then val:=turb else val:=-9999;
              units_id:=21;
            end;
            6: begin
              tbl:='P_CHLA_ITP';
               if not isNaN(chl)then val:=chl else val:=-9999;
              units_id:=4;
            end;
            7: begin
              tbl:='P_PAR_ITP';
               if not isNaN(par)then val:=par else val:=-9999;
              units_id:=22;
            end;
          end;
         //  showmessage('here2'+'   '+floattostr(val));
         // memo1.lines.add(tbl+'   '+floattostr(val)+'   '+inttostr(units_id));



          if (val<>-9999) then begin
          try
           with Qt do begin
            Close;
             SQL.Clear;
             SQL.Add(' insert into ');
             SQL.Add(tbl);
             SQL.Add(' (ID, LEV_DBAR, VAL, PQF1, PQF2, UNITS_ID) ');
             SQL.Add(' values ');
             SQL.Add(' (:ID, :LEV_DBAR, :VAL, :PQF1, :PQF2, :UNITS_ID) ');
             ParamByName('ID').AsInteger:=id;
             ParamByName('LEV_DBAR').AsFloat:=pres;
             ParamByName('VAL').AsFloat:=val;
             ParamByName('PQF1').AsInteger:=4;
             ParamByName('PQF2').AsInteger:=4;
             ParamByName('UNITS_ID').AsInteger:=units_id;
            ExecSQL;
           end;
           Trt.CommitRetaining;
          except
        //   memo1.Lines.Add(CurFile+'   '+floattostr(pres));
           TrT.RollbackRetaining;
          end;
        end;

       end;

    end;
  end;
  //   frmosmain.ProgressBar1.Position:=frmosmain.ProgressBar1.Position+1;
  //   Application.processMessages;

     CloseFile(Dat);
  end;
 end;
 if chkWrite.Checked then begin
  Qt.Close;
  Qt.free;
  TrT.Commit;
  TrT.Free;

  frmosmain.DatabaseInfo;
 end;
Showmessage('Done!');
end;





procedure TfrmLoadITP.btnLoadMicroSamiClick(Sender: TObject);
Var
TRt:TSQLTransaction;
Qt:TSQLQuery;
TempList:TListBox;

cruise_id:integer;
begin
 //
end;



procedure TfrmLoadITP.Button3Click(Sender: TObject);
var
k, i, c, fl:integer;
CurFile, buf_str, st:string;

begin

//%ITP 1, profile 1: year day longitude(E+) latitude(N+) ndepths
//2005  228.25001  -150.1313  78.8267  751
//%pressure(dbar) temperature(C) salinity nobs

   For k:=0 to ListBox1.Count-1 do begin
    CurFile:=ListBox1.Items.Strings[k];

    ListBox1.ItemIndex:=k;
    Application.ProcessMessages;

    AssignFile(dat, Path+CurFile); Reset(dat);

      readln(dat, st);
      readln(dat, st);
      readln(dat, st);

     { c:=1;
      repeat
        buf_str:='';
        repeat
         inc(c);
          if st[c]<>' ' then buf_str:=buf_str+st[c];
        until (st[c]=' ') or (c=length(st));

        fl:=0;
        for i:=0 to memo1.Lines.Count-1 do
          if memo1.Lines.Strings[i]=trim(buf_str) then fl:=1;

        if fl=0 then memo1.lines.add(trim(buf_str));
      until c=length(st);  }

        fl:=0;
        for i:=0 to memo1.Lines.Count-1 do
          if memo1.Lines.Strings[i]=trim(st) then fl:=1;

        if fl=0 then memo1.lines.add(trim(st));

   // check for microcats
     //   if copy(st, 1,1)<>'%' then memo1.lines.add(CurFile);


      closefile(dat);
   end;

end;



procedure TfrmLoadITP.btnTimeReaploadClick(Sender: TObject);
Var
TRt:TSQLTransaction;
Qt:TSQLQuery;

ff, id, p, yyyy:integer;
st, CurFile, stnumincruise, stvessel:string;
yy, mn, dd:word;
hh, mm, ss, mss: real;
hour, min, sec, msec: integer;
date1, StDate:TDateTime;
begin

   TRt:=TSQLTransaction.Create(self);
   TRt.DataBase:=frmdm.IBDB;

   (* temporary query for main database *)
   Qt:=TSQLQuery.Create(self);
   Qt.Database:=frmdm.IBDB;
   Qt.Transaction:=TRt;

  try
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
    id:=strtoint(stvessel)*10000+strtoint(stnumincruise);


    AssignFile(dat, Path+CurFile); Reset(dat);

      readln(dat, st);
      readln(dat, st);

      yyyy:=StrToInt(trim(copy(st, 1, 4)));
      if lowercase(trim(copy(st, 7, 9)))<>'nan'   then date1:=StrToFloat(trim(copy(st, 7, 9)))  else date1:=-999;


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

    memo1.lines.add(CurFIle+'   '+Datetimetostr(stdate));
    try
      with Qt do begin
        Close;
        SQL.Clear;
        SQL.Add(' UPDATE STATION SET DATEANDTIME=:DD WHERE ID=:ID ' );
        ParamByName('ID').Value:=ID;
        ParamByName('DD').Value:=StDate;
        ExecSQL;
       end;

       Trt.CommitRetaining;
     except
       memo1.Lines.Add(CurFile);
       TrT.RollbackRetaining;
     end;
    end;
  finally
  Qt.Close;
  Qt.free;
  TrT.Commit;
  TrT.Free;
  end;
  Showmessage('Done!');
end;



procedure TfrmLoadITP.Button4Click(Sender: TObject);
Var
 dat:text;
 st:string;
begin

 AssignFile(dat, 'X:\Data_Oceanography\_ITP\to_move.txt'); reset(dat);

 repeat
  readln(dat, st);

  RenameFile('C:\_ITP\grddata\'+st, 'C:\_ITP\grddata\bad\'+st);

 until eof(dat);
 closefile(dat);

end;

end.
