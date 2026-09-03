unit ImportDatabaseFRM;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Menus, Dialogs, StdCtrls, CheckLst, Buttons, ExtCtrls, DB,
  ComCtrls, IBConnection, sqldb, DateUtils, Spin;

type

  { TImportDatabase }

  TImportDatabase = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    DB1: TIBConnection;
    DB2: TIBConnection;
    ib1q1: TSQLQuery;
    ib1q2: TSQLQuery;
    ib1qq1: TSQLQuery;
    ib2q1: TSQLQuery;
    ib2q2: TSQLQuery;
    DB1TableList: TListBox;
    Memo1: TMemo;
    TR1: TSQLTransaction;
    BtnMergeDatabases: TBitBtn;
    TR2: TSQLTransaction;


    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);

  private


  public
    { Public declarations }
  end;

var
  ImportDatabase: TImportDatabase;
  MCount:Integer;
  logf:text;

implementation


{$R *.lfm}

uses GibbsSeaWater;


procedure TImportDatabase.FormShow(Sender: TObject);
Var
  tmp:TStringList;
  K:integer;
begin
 try
  tmp:=TStringList.Create;
  DB1.GetTableNames(tmp, False);

  for k:=0 to tmp.Count-1 do
    if copy(tmp.Strings[k],1,2)='P_' then
    DB1TableList.Items.Add(tmp.Strings[k]);
 finally
   tmp.Free;
 end;

end;


procedure TImportDatabase.Button1Click(Sender: TObject);
Var
  dat: text;
  title, title1, st:string;
  platf:integer;
  descr:string;
begin
 ib2q1.SQL.Text:=' Select * from CATALOG order by title, date_begin';
 ib2q1.Open;


 while not ib2q1.EOF do begin
   TITLE:=ib2q1.FieldByName('TITLE').AsString;
   descr:=ib2q1.FieldByName('C_DESC').AsString;
  // memo1.lines.add(descr);

  if title='UNKNOWN' then
  platf:=1 else begin
   AssignFile(dat, 'AARI_vessels_combined.txt'); reset(dat);

   platf:=-9;
   repeat
     readln(dat, st);
     title1:=copy(st, 1, pos(#9, st)-1);
     if title1=title then platf:=StrToInt(copy(st, pos(#9, st)+1, length(st)));
   until (title=title1) or eof(dat);
   Closefile(dat);
   end;

   if platf=-9 then
   memo1.lines.add(title+'   '+inttostr(platf));


   try

    with ib1q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' select id from cruise where ID='+inttostr(ib2q1.FieldByName('ID').AsInteger));
     Open;
    end;

    if ib1q1.IsEmpty then begin
   with ib1q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' INSERT INTO CRUISE ');
       SQL.Add(' (ID, PLATFORM_ID, COUNTRY_ID, INSTITUTE_ID, PROJECT_ID, ');
       SQL.Add(' SOURCE_ID, CRUISE_NUMBER, DATE_START, DATE_END, STATIONS_AMOUNT, ');
       SQL.Add(' DATE_ADDED, NOTES) ');
       SQL.Add(' VALUES ');
       SQL.Add(' (:ID, :PLATFORM_ID, :COUNTRY_ID, :INSTITUTE_ID, :PROJECT_ID, ');
       SQL.Add(' :SOURCE_ID, :CRUISE_NUMBER, :DATE_START, :DATE_END, :STATIONS_AMOUNT, ');
       SQL.Add(' :DATE_ADDED, :NOTES) ');
       ParamByName('ID').AsInteger:=ib2q1.FieldByName('ID').AsInteger;
       ParamByName('PLATFORM_ID').AsInteger:=PLATF;
       ParamByName('COUNTRY_ID').AsInteger:=245;
       ParamByName('INSTITUTE_ID').AsInteger:=710;
       ParamByName('PROJECT_ID').AsInteger:=446;
       ParamByName('SOURCE_ID').AsInteger:=3;
       ParamByName('CRUISE_NUMBER').AsWideString:=ib2q1.FieldByName('TITLE2').AsString;
       ParamByName('DATE_START').AsDateTime:=ib2q1.FieldByName('Date_begin').AsDateTime;
       ParamByName('DATE_END').AsDateTime:=ib2q1.FieldByName('Date_end').AsDateTime;
       ParamByName('STATIONS_AMOUNT').AsInteger:=ib2q1.FieldByName('NUMST').AsInteger;
       ParamByName('DATE_ADDED').AsDateTime:=ib2q1.FieldByName('ADDED').AsDateTime;
       ParamByName('NOTES').AsWideString:=descr;
     ExecSQL;
   end;
   TR1.CommitRetaining;
   end;

   except
     TR1.RollbackRetaining;
     memo1.Lines.Add(inttostr(ib2q1.FieldByName('ID').AsInteger));
   end;

   ib2q1.Next;
  end;


 ib2q1.Close;
 TR2.Commit;
 TR1.Commit;
end;



procedure TImportDatabase.Button2Click(Sender: TObject);
Var
  dat: text;
  title, title1, st:string;
  platf, absnum, cruise_id:integer;
  descr:string;
  stdate, sttime, date1:Tdatetime;
  yy, mn, dd, hh, mm, ss, ms:word;
begin
 ib2q1.SQL.Text:=' Select * from STATION, station_info where '+
                 ' station.absnum=station_info.absnum '+
                 ' order by station.absnum';
 ib2q1.Open;


 while not ib2q1.EOF do begin
   absnum:=ib2q1.FieldByName('absnum').AsInteger;
   stdate:=ib2q1.FieldByName('stdate').AsDateTime;
   sttime:=ib2q1.FieldByName('sttime').AsDateTime;

   decodedate(stdate, yy, mn, dd);
   decodetime(sttime,hh, mm,ss,ms);

   date1:=encodedatetime(yy, mn, dd, hh, mm, ss, ms);

    with ib1q1 do begin
      Close;
        SQL.Clear;
        SQL.Add('SELECT ID FROM STATION WHERE ID='+inttostr(absnum));
      Open;
    end;

    if ib1q1.IsEmpty=true then begin
   cruise_id:=0;
   ib2q2.SQL.Text:=' Select ID from STATION_CATALOG where '+
                   ' absnum= '+inttostr(absnum);
   ib2q2.Open;
    cruise_ID:= ib2q2.Fields[0].AsInteger;
   ib2q2.close;

   if cruise_id=0 then memo1.lines.add(inttostr(absnum));

   if cruise_id>0 then begin
  // try
   with ib1q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' INSERT INTO STATION ' );
        SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ' );
        SQL.Add('  ST_NUMBER_ORIGIN, CAST_NUMBER, QCFLAG, BOTTOMDEPTH, ' );
        SQL.Add('  STVERSION, DUPLICATE, MERGED, DATE_ADDED)' );
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ' );
        SQL.Add('  :ST_NUMBER_ORIGIN, :CAST_NUMBER, :QCFLAG, :BOTTOMDEPTH, ' );
        SQL.Add('  :STVERSION, :DUPLICATE, :MERGED, :DATE_ADDED) ' );
        ParamByName('ID'               ).Value:=absnum;
        ParamByName('LATITUDE'         ).Value:=ib2q1.FieldByName('stlat').Asfloat;
        ParamByName('LONGITUDE'        ).Value:=ib2q1.FieldByName('stlon').Asfloat;
        ParamByName('DATEANDTIME'      ).Value:=Date1;
        ParamByName('CRUISE_ID'        ).Value:=Cruise_ID;
        ParamByName('BOTTOMDEPTH'     ).Value:=ib2q1.FieldByName('stdepthsource').AsInteger;
        ParamByName('ST_NUMBER_ORIGIN' ).Value:=ib2q1.FieldByName('sourceuniqueid').AsWideString;
        ParamByName('CAST_NUMBER'      ).Value:=1;
        ParamByName('QCFLAG'           ).Value:=4;
        ParamByName('STVERSION'        ).Value:=ib2q1.FieldByName('stversion').AsInteger;
        ParamByName('DUPLICATE'        ).Value:=false;
        ParamByName('MERGED'           ).Value:=0;
        ParamByName('DATE_ADDED'       ).Value:=Now;
        ExecSQL;
       end;
   TR1.CommitRetaining;

  { except
     TR1.RollbackRetaining;
     memo1.Lines.Add(inttostr(absnum));
   end; }

   end; //absnum
   end;

   ib2q1.Next;
 end;


 ib2q1.Close;
 TR2.Commit;
 TR1.Commit;
end;

procedure TImportDatabase.Button3Click(Sender: TObject);
Var
  k, ID, FL, PQF1, PQF2, units_id:integer;
  tbl: string;
  Lat, lev_m, lev_dbar, val1:real;
begin
  for k:=1 to DB1TableList.Count-1 do begin
    tbl:=DB1TableList.Items.Strings[k];
    //memo1.lines.Add(tbl);

    units_id:=4;
    if tbl='P_TEMPERATURE' then units_id:=1;
    if tbl='P_SALINITY' then units_id:=2;
    if tbl='P_OXYGEN' then units_id:=21;
    if tbl='P_PH' then units_id:=2;
    if tbl='P_ALKALINITY' then units_id:=5;

    with ib2q1 do begin
      Close;
        SQL.Clear;
        SQL.Add(' SELECT * from '+tbl+' order by absnum, level_');
      Open;
      Last;
      First;
    end;
    memo1.lines.add(tbl+': '+inttostr(ib2q1.recordcount));

    while not ib2q1.EOF do begin
      ID   :=ib2q1.FieldByName('absnum').AsInteger;
     // Lat  :=ib2q1.FieldByName('stlat').AsFloat;
      LEV_M:=ib2q1.FieldByName('level_').AsFloat;
      LEV_DBAR:=0; //GibbsSeaWater.gsw_p_from_z(lev_m, lat,0,0);
      VAL1 :=ib2q1.FieldByName('value_').AsFloat;
      FL   :=ib2q1.FieldByName('flag_').AsInteger;

      if fl>=16384 then begin
       pqf1:=2;
       pqf2:=2;
      end else begin
       pqf1:=4;
       pqf2:=4;
      end;

       with ib1q1 do begin
        Close;
        SQL.Clear;
        SQL.Add(' INSERT INTO '+tbl);
        SQL.Add(' (ID, LEV_M, LEV_DBAR, VAL, PQF1, PQF2, SQF, INSTRUMENT_ID, UNITS_ID, PROFILE_NUMBER)');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :LEV_M, :LEV_DBAR, :VAL, :PQF1, :PQF2, :SQF, :INSTRUMENT_ID, :UNITS_ID, :PROFILE_NUMBER)');
        ParamByName('ID').AsInteger:=id;
        ParamByName('LEV_DBAR').AsFloat:=lev_dbar;
        ParamByName('LEV_M').AsFloat:=lev_m;
        ParamByName('VAL').AsFloat:=val1;
        ParamByName('PQF1').AsInteger:=pqf1;
        ParamByName('PQF2').AsInteger:=pqf2;
        ParamByName('SQF').AsInteger:=0;
        ParamByName('INSTRUMENT_ID').AsInteger:=7;
        ParamByName('UNITS_ID').AsInteger:=units_id;
        ParamByName('PROFILE_NUMBER').AsInteger:=1;
        ExecSQL;
       end;
      ib2q1.Next;

    end;

  end;
  tr1.Commit;
  tr2.Commit;
end;



procedure TImportDatabase.Button4Click(Sender: TObject);
Var
  ff, ID: integer;
  tbl: string;
  Lat, lev_d, lev_m: real;
begin

  For ff:=1 to DB1TableList.Count-1 do begin
    tbl:=DB1TableList.Items.Strings[ff];

  with ib1q1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT ');
    SQL.Add(' STATION.ID, STATION.LATITUDE, '+tbl+'.LEV_M ');
    SQL.Add(' FROM STATION, '+tbl);
    SQL.Add(' WHERE STATION.ID='+tbl+'.ID ');
    SQL.Add(' ORDER BY STATION.ID, '+tbl+'.ID ');
   Open;
  end;

 // showmessage('here');

  while not ib1q1.EOF do begin
   ID:=ib1q1.FieldByName('ID').AsInteger;
   lat:=ib1q1.FieldByName('LATITUDE').AsFloat;
   lev_m:=ib1q1.FieldByName('LEV_M').AsFloat;

    lev_d:=gibbsseawater.gsw_p_from_z(-lev_m,lat,0,0);
  //  showmessage(floattostr(lev_d));

   with ib1q2 do begin
   Close;
    SQL.Clear;
    SQL.Add(' UPDATE '+tbl);
    SQL.Add(' SET LEV_DBAR=:lev_d ');
    SQL.Add(' WHERE ID=:ID and LEV_M=:lev_m ');
    ParamByName('ID').AsInteger:=ID;
    ParamByName('lev_m').Value:=lev_m;
    ParamByName('lev_d').Value:=lev_d;
   ExecSqL;
  end;

    ib1q1.Next;
  end;

  end;

  ib1q1.close;
  TR1.Commit;

end;

procedure TImportDatabase.Button5Click(Sender: TObject);
Var
  dat: text;
  title, title1, st:string;
  platf, ID:integer;
  descr:string;
begin

 ib2q1.SQL.Text:=' Select * from CATALOG order by title, date_begin';
 ib2q1.Open;

 {ib2q1.SQL.Text:=' Select * from CATALOG order by title, date_begin';
 ib2q1.Open; }


 while not ib2q1.EOF do begin
  ID:=ib2q1.FieldByName('ID').AsInteger;
  //platf2:=
  //plaft_num2:=


    with ib1q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' select id from cruise where ID='+inttostr(ID));
     Open;
    end;

    if ib1q1.IsEmpty then memo1.lines.add(inttostr(ID));

   ib2q1.Next;
  end;


 ib2q1.Close;
 TR2.Commit;
 TR1.Commit;
end;

procedure TImportDatabase.Button6Click(Sender: TObject);
Var
  dat: text;
  title, title1, st:string;
  platf, ID:integer;
  descr:string;
begin

 ib1q1.SQL.Text:=' Select * from CRUISE order by ID';
 ib1q1.Open;

 while not ib1q1.EOF do begin
  ID:=ib1q1.FieldByName('ID').AsInteger;
  //platf2:=
  //plaft_num2:=


    with ib2q1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' Select * from CATALOG where ID='+inttostr(ID));
     Open;
    end;

    if ib2q1.IsEmpty then memo1.lines.add(inttostr(ID));

   ib1q1.Next;
  end;


 ib1q1.Close;
 TR2.Commit;
 TR1.Commit;
end;

procedure TImportDatabase.Button7Click(Sender: TObject);
Var
  dat: text;
  title, title1, st:string;
  platf, ID, cnt:integer;
  descr:string;
begin

 ib1q1.SQL.Text:=' Select ID, st_ID_origin from STATION order by ST_ID_ORIGIN';
 ib1q1.Open;

 cnt:=0;
 while not ib1q1.EOF do begin
  //ID:=ib1q1.FieldByName('ID').AsInteger;
 inc(cnt);
 ID:=3000000+cnt;

 if ib1q1.Fields[0].AsInteger<3000000 then begin
 memo1.lines.add(inttostr(ID)+'   '+inttostr(ib1q1.Fields[0].AsInteger));
 application.ProcessMessages;

 try
   with ib1q2 do begin
     Close;
       SQL.Clear;
       SQL.Add(' update station set ID='+inttostr(ID));
       SQL.Add(' where ID='+Inttostr(ib1q1.Fields[0].AsInteger));
     ExecSQL;
    end;
  TR1.CommitRetaining;
  except
   tr1.RollbackRetaining;
  end;
  end;

   ib1q1.Next;
  end;

 ib1q1.Close;
 TR1.Commit;
end;

procedure TImportDatabase.Button8Click(Sender: TObject);
Var
  dat: text;
  title, title1, st:string;
  platf, ID, cnt:integer;
  descr:string;
begin

 ib1q1.SQL.Text:=' Select id, st_id_origin from station order by id ';
 ib1q1.Open;

 cnt:=0;
 while not ib1q1.EOF do begin

// cltype:=

 try
   with ib1q2 do begin
     Close;
       SQL.Clear;
       SQL.Add(' update meteo set ID=:ID ');
       SQL.Add(' where ID=:ID_st');
       Parambyname('ID').AsInteger:=ib1q1.FieldByName('ID').AsInteger;
       Parambyname('ID_ST').AsInteger:=ib1q1.FieldByName('st_id_origin').AsInteger;
     ExecSQL;
    end;
  TR1.CommitRetaining;
  except
   tr1.RollbackRetaining;
  end;

   ib1q1.Next;
  end;

 ib1q1.Close;
 TR1.Commit;

end;

procedure TImportDatabase.Button9Click(Sender: TObject);
Var
  dat: text;
  title, title1, st:string;
  platf, ID, cnt:integer;
  descr:string;
begin

 ib1q1.SQL.Text:=' Select * from meteo order by absnum ';
 ib1q1.Open;

 cnt:=0;
 while not ib1q1.EOF do begin

// cltype:=

 try
   with ib1q2 do begin
     Close;
       SQL.Clear;
       SQL.Add(' update meteo set cloudtype1=:cl ');
       SQL.Add(' where absnum=:ID');
       Parambyname('ID').AsInteger:=ib1q1.FieldByName('absnum').AsInteger;
       Parambyname('cl').Asstring:=ib1q1.FieldByName('CLOUDTYPE').AsWideString;
     ExecSQL;
    end;
  TR1.CommitRetaining;
  except
   tr1.RollbackRetaining;
  end;

   ib1q1.Next;
  end;

 ib1q1.Close;
 TR1.Commit;

end;



procedure TImportDatabase.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  DB1.Connected:=false;
  DB2.Connected:=false;
end;


end.
