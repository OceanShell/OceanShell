unit osload_ioras;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  IBConnection, DB, SQLDB, DateUtils;

type

  { TfrmLoadIORAS }

  TfrmLoadIORAS = class(TForm)
    Button1: TButton;
    btnStation: TButton;
    mLog: TMemo;
    procedure btnStationClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  frmLoadIORAS: TfrmLoadIORAS;

implementation

{$R *.lfm}

{ TfrmLoadIORAS }

uses dm, driver_fdb, procedures;

procedure TfrmLoadIORAS.Button1Click(Sender: TObject);
Var
  cruises: array [1..10] of integer = (62,67,68,71,75,80,84,89,93,96);
  cruise_id, platform_id, source_id, institute_id, project_id: integer;
  c, cruise_number: integer;

  DB:TIBConnection;
  TR:TSQLTransaction;
  Q, Q2, Q3:TSQLQuery;
begin

  platform_id:=19006; //16959 for USSR
  source_id:=13; //IORAS
  institute_id:=701; //IORAS
  project_id:= 0; //UNKNOWN

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

    for c:=1 to length(cruises) do begin
      cruise_number:=cruises[c];
      cruise_id:=6100000+c;

      PutFDBCruise(Q, cruise_id, platform_id, source_id, institute_id,
        project_id, null, cruise_number, null, null,
        null, null, null, null, now, now);
      TR.CommitRetaining;

      mlog.lines.Add(inttostr(cruise_id));
    end;

   finally
     TR.Commit;
     Q.Free;
     DB.Close(true);
     DB.Free;
     TR.Free;
   end;
end;

procedure TfrmLoadIORAS.btnStationClick(Sender: TObject);
Var
  dat, dat2: text;
 cruises: array [1..10] of integer = (62,67,68,71,75,80,84,89,93,96);
  main_path, meta_path, meta_file, st, buf_str, stnum, mns, tts, data_path: string;
  cruise_id, platform_id, source_id, institute_id, project_id: integer;
  c, cc, md, cruise_number, station_id, st_cnt: integer;
  dd, mn, yy, hh, mm, ss:word;
  stdate:TDateTime;
  lat, lon, ndepth: real;

  pres, lev_m, temp1, temp2, skip, turb, salt1, salt2, oxy1, fluo, chla: real;

  DB:TIBConnection;
  TR:TSQLTransaction;
  Q, Q2, Q3:TSQLQuery;

begin
  main_path:='X:\Data_Oceanography\ИОРАН\Гидрология ИО РАН\';
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

   st_cnt:=0;
  for c:=1 to length(cruises) do begin
    cruise_number:=cruises[c];
    cruise_id:=6100000+c;

    meta_path:=main_path+'AMK-'+inttostr(cruises[c])+'_'+inttostr(2014+c)+PathDelim;
    meta_file:='AMK-'+inttostr(cruises[c])+'_meta.dat';
    mlog.lines.Add(inttostr(cruise_id)+'   '+meta_path);

    AssignFile(dat, meta_path+meta_file); Reset(dat);
    readln(dat, st);

    repeat
      readln(dat, st);
  //    mlog.lines.Add('Start: '+st);

      inc(st_cnt);
      station_id:=6100000+st_cnt;

       cc:=0;
       for md:=1 to 8 do begin
        buf_str:='';
        repeat
          inc(cc);
          if st[cc]<>#9 then buf_str:=buf_str+st[cc];
        until (st[cc]=#9) or (cc=length(st));
      //  showmessage(buf_str);
         case md of
          1: lat:=StrToFloat(buf_str);
          2: lon:=StrToFloat(buf_str);
          3: ndepth:=StrToFloat(buf_str);
          4: stnum:=trim(buf_str);
          5: dd:=strtoint(trim(buf_str));
          6: mns:=trim(buf_str);
          7: yy:=strtoint(trim(buf_str));
          8: tts:=trim(buf_str);
         end;
       end;

       MonthToInd(mns, mn);
    //   showmessage(tts);
       cc:=0; md:=0;
       repeat
        buf_str:='';
        inc(md);
        repeat
          inc(cc);
          if tts[cc]<>':' then buf_str:=buf_str+tts[cc];
        until (tts[cc]=':') or (cc=length(tts));

         case md of
          1: hh:=StrToInt(buf_str);
          2: mm:=StrToInt(buf_str);
          3: if buf_str<>'' then ss:=StrToInt(buf_str) else ss:=0;
         end;
       until cc>=length(tts);

       stdate:=EncodeDateTime(yy,mn,dd,hh,mm,ss,0);

       stnum:=UTF8Decode(stnum);

      {  PutFDBStation(Q, station_id, lat, lon, stdate, ndepth, cruise_id, stnum,
           null, 0, 0, 1, null, now, now);
         TR.CommitRetaining; }

      data_path:=main_path+'AMK-'+inttostr(cruises[c])+'_'+
                 inttostr(2014+c)+PathDelim+
                 'AMK-'+inttostr(cruises[c])+'_data'+PathDelim+
                 stnum+'.dat';

      if not(fileexists(data_path)) then Continue;

      AssignFile(dat2, data_path); reset(dat2);
      readln(dat2);

      lev_m:=-9999; temp1:=-9999; temp2:=-9999; turb:=-9999;
      salt1:=-9999; salt2:=-9999; oxy1:=-9999; fluo:=-9999; chla:=-9999;
      repeat
      //  (62,67,68,71,75,80,84,89,93,96);
        if cruises[c]=62 then begin
          readln(dat2, pres, lev_m, temp1, temp2, skip, skip, skip, turb, salt1, skip, skip, oxy1);
       {   PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp1, 0, 0, 0, null,  1, 4, 1, true);
          PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp2, 0, 0, 0, null,  1, 4, 2, false);
          PutFDBProfile(Q, 'P_TURBIDITY',   station_id, pres, lev_m, turb,  0, 0, 0, null, 34, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt1, 0, 0, 0, null, 28, 4, 1, true);
          PutFDBProfile(Q, 'P_OXYGEN',      station_id, pres, lev_m, oxy1,  0, 0, 0, null, 21, 4, 1, true);
          }
          end;
        if cruises[c]=67 then begin
          readln(dat2, pres, temp1, skip, fluo, oxy1, turb, salt1, skip, lev_m, skip, skip);
          PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp1, 0, 0, 0, null,  1, 4, 1, true);
          PutFDBProfile(Q, 'P_FLUORESCENCE',station_id, pres, lev_m, fluo,  0, 0, 0, null,  9, 4, 1, true);
          PutFDBProfile(Q, 'P_TURBIDITY',   station_id, pres, lev_m, turb,  0, 0, 0, null, 34, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt1, 0, 0, 0, null, 28, 4, 1, true);
          PutFDBProfile(Q, 'P_OXYGEN',      station_id, pres, lev_m, oxy1,  0, 0, 0, null, 21, 4, 1, true);

        end;
        if cruises[c]=68 then begin
          readln(dat2, pres, lev_m, temp1, temp2, skip, skip, skip, turb, salt1, salt2, skip, skip, skip, skip, oxy1);
        {  PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp1, 0, 0, 0, null,  1, 4, 1, true);
          PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp2, 0, 0, 0, null,  1, 4, 2, false);
          PutFDBProfile(Q, 'P_FLUORESCENCE',station_id, pres, lev_m, fluo,  0, 0, 0, null,  9, 4, 1, true);
          PutFDBProfile(Q, 'P_TURBIDITY',   station_id, pres, lev_m, turb,  0, 0, 0, null, 34, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt1, 0, 0, 0, null, 28, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt2, 0, 0, 0, null, 28, 4, 2, false);
          PutFDBProfile(Q, 'P_OXYGEN',      station_id, pres, lev_m, oxy1,  0, 0, 0, null, 21, 4, 1, true);
          }
        end;
        if cruises[c]=71 then begin
          readln(dat2, pres, lev_m, temp1, temp2, skip, skip, skip, turb, salt1, salt2, skip, skip, oxy1);
        {  PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp1, 0, 0, 0, null,  1, 4, 1, true);
          PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp2, 0, 0, 0, null,  1, 4, 2, false);
          PutFDBProfile(Q, 'P_FLUORESCENCE',station_id, pres, lev_m, fluo,  0, 0, 0, null,  9, 4, 1, true);
          PutFDBProfile(Q, 'P_TURBIDITY',   station_id, pres, lev_m, turb,  0, 0, 0, null, 34, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt1, 0, 0, 0, null, 28, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt2, 0, 0, 0, null, 28, 4, 2, false);
          PutFDBProfile(Q, 'P_OXYGEN',      station_id, pres, lev_m, oxy1,  0, 0, 0, null, 21, 4, 1, true);
          }
          end;
        if cruises[c]=75 then begin
          readln(dat2, pres, lev_m, skip, temp1, salt1, oxy1, fluo, turb);
     {     PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp1, 0, 0, 0, null,  1, 4, 1, true);
          PutFDBProfile(Q, 'P_FLUORESCENCE',station_id, pres, lev_m, fluo,  0, 0, 0, null,  9, 4, 1, true);
          PutFDBProfile(Q, 'P_TURBIDITY',   station_id, pres, lev_m, turb,  0, 0, 0, null, 34, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt1, 0, 0, 0, null, 28, 4, 1, true);
          PutFDBProfile(Q, 'P_OXYGEN',      station_id, pres, lev_m, oxy1,  0, 0, 0, null, 21, 4, 1, true);
          }
        end;
        if cruises[c]=80 then begin
          readln(dat2, pres, temp1, skip, lev_m, salt1);
         { PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp1, 0, 0, 0, null,  1, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt1, 0, 0, 0, null, 28, 4, 1, true);
          }
        end;
        if cruises[c]=84 then begin
          readln(dat2, lev_m, temp1, salt1, turb, oxy1, skip, chla, skip, pres);
         { PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp1, 0, 0, 0, null,  1, 4, 1, true);
          PutFDBProfile(Q, 'P_CHLOROPHYLL', station_id, pres, lev_m, chla,  0, 0, 0, null, 14, 4, 1, true);
          PutFDBProfile(Q, 'P_TURBIDITY',   station_id, pres, lev_m, turb,  0, 0, 0, null, 34, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt1, 0, 0, 0, null, 28, 4, 1, true);
          }
        //  PutFDBProfile(Q, 'P_OXYGEN',      station_id, pres, lev_m, oxy1,  0, 0, 0, null, 21, 4, 1, true);
          end;
        if cruises[c]=89 then begin
          readln(dat2, pres, skip, temp1, fluo, turb, oxy1, skip, lev_m, salt1);
       {   PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp1, 0, 0, 0, null,  1, 4, 1, true);
          PutFDBProfile(Q, 'P_FLUORESCENCE',station_id, pres, lev_m, fluo,  0, 0, 0, null,  9, 4, 1, true);
          PutFDBProfile(Q, 'P_TURBIDITY',   station_id, pres, lev_m, turb,  0, 0, 0, null, 34, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt1, 0, 0, 0, null, 28, 4, 1, true);
          PutFDBProfile(Q, 'P_OXYGEN',      station_id, pres, lev_m, oxy1,  0, 0, 0, null, 21, 4, 1, true);
          }
          end;
        if cruises[c]=93 then begin
          readln(dat2, pres, temp1, fluo, turb, skip, skip, salt1, skip, skip, lev_m);
        {  PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp1, 0, 0, 0, null,  1, 4, 1, true);
          PutFDBProfile(Q, 'P_FLUORESCENCE',station_id, pres, lev_m, fluo,  0, 0, 0, null,  9, 4, 1, true);
          PutFDBProfile(Q, 'P_TURBIDITY',   station_id, pres, lev_m, turb,  0, 0, 0, null, 25, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt1, 0, 0, 0, null, 28, 4, 1, true);
          }
          end;
        if cruises[c]=96 then begin
          readln(dat2, temp1, salt1, skip, fluo, oxy1, turb, lev_m, pres);
       {   PutFDBProfile(Q, 'P_TEMPERATURE', station_id, pres, lev_m, temp1, 0, 0, 0, null,  1, 4, 1, true);
          PutFDBProfile(Q, 'P_FLUORESCENCE',station_id, pres, lev_m, fluo,  0, 0, 0, null,  9, 4, 1, true);
          PutFDBProfile(Q, 'P_TURBIDITY',   station_id, pres, lev_m, turb,  0, 0, 0, null, 34, 4, 1, true);
          PutFDBProfile(Q, 'P_SALINITY',    station_id, pres, lev_m, salt1, 0, 0, 0, null, 28, 4, 1, true);
          PutFDBProfile(Q, 'P_OXYGEN',      station_id, pres, lev_m, oxy1,  0, 0, 0, null, 21, 4, 1, true);
          }
          end;

        Tr.CommitRetaining;
      until eof(dat2);
      CloseFile(dat2);



     //  mlog.lines.Add('Start: '+st);
    until eof(dat);
    CloseFile(dat);

   //   mlog.lines.Add(inttostr(cruise_id)+'   '+meta_path);
    end;
    finally
     TR.Commit;
     Q.Free;
     DB.Close(true);
     DB.Free;
     TR.Free;
   end;
end;


end.

