unit osload_argo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SQLDB, DB,
  DateUtils, Variants;

type

  { Tfrmload_argo }

  Tfrmload_argo = class(TForm)
    Button1: TButton;
    Button2: TButton;
    btnParameters: TButton;
    Button3: TButton;
    ePath: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    procedure btnParametersClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    procedure GetCodes(argo_code:string; Var country_id, institute_id, project_id:integer);
    procedure WriteCoreProfile(fname:string);
  public

  end;

var
  frmload_argo: Tfrmload_argo;

implementation

{$R *.lfm}

{ Tfrmload_argo }

uses osmain, dm, declarations_netcdf;

procedure Tfrmload_argo.Button1Click(Sender: TObject);
Var
  dat:text;
  c, k, cnt:integer;
  st, fname, prof_type, inst_code, date_upd, platf, buf_str:string;
  country_id, institute_id, project_id: integer;
  stdate_upd:TDateTime;

  Qtt:TSQLQuery;
  TRt:TSQLTransaction;
begin

     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;
     //Trt.

     Qtt:=TSQLQuery.Create(self);
     Qtt.Database:=frmdm.IBDB;
     Qtt.Transaction:=TRt;

try
  AssignFile(dat, epath.text+'ar_index_global_meta.txt');
  reset(dat);

  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';

  cnt:=0;
  repeat
   inc(cnt);
   readln(dat, st);

  // file,profiler_type,institution,date_update
  // aoml/13857/13857_meta.nc,845,AO,20181011200014

   c:=0;
   for k:=1 to 4 do begin
    buf_str:='';
    repeat
      inc(c);
      if st[c]<>',' then buf_str:=buf_str+st[c];
    until (st[c]=',') or (c=length(st));

    case k of
     1: fname:=buf_str;
     2: prof_type:=buf_str;
     3: inst_code:=buf_str;
     4: date_upd:=buf_str;
    end;
   end;

   stdate_upd:=EncodeDateTime(StrToInt(copy(date_upd, 1, 4)),
                          StrToInt(copy(date_upd, 5, 2)),
                          StrToInt(copy(date_upd, 7, 2)),
                          StrToInt(copy(date_upd, 9, 2)),
                          StrToInt(copy(date_upd, 11, 2)),
                          StrToInt(copy(date_upd, 13, 2)),
                          0);


   k:=Pos('/', fname);
   buf_str:='';
   repeat
    inc(k);
    if fname[k]<>'/' then buf_str:=buf_str+fname[k];
   until fname[k]='/';

   platf:=buf_str;

   GetCodes(inst_code, country_id, institute_id, project_id);

  { with Qtt do begin
       Close;
        Sql.Clear;
        SQL.Add('insert into PLATFORM');
        SQL.Add(' (ID, NAME, country_ID, DATE_ADDED) ');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :name, :country_id, :date_added) ');
        ParamByName('ID').Value:=cnt;
        ParamByName('name').Value:=platf;
        ParamByName('country_id').Value:=country_id;
        ParamByName('date_added').Value:=now;
       ExecSQL;
      end;  }

   {   with Qtt do begin
       Close;
        Sql.Clear;
        SQL.Add('insert into CRUISE');
        SQL.Add(' (ID, platform_id, source_id, institute_id, project_id, ');
        SQL.Add(' DATE_ADDED) ');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :platform_id, :source_id, :institute_id, :project_id, ');
        SQL.Add(' :DATE_ADDED) ');
        ParamByName('ID').Value:=cnt;
        ParamByName('platform_id').Value:=cnt;
       // ParamByName('cruise_number').Value:=5;
        ParamByName('source_id').Value:=5;
        ParamByName('institute_id').Value:=institute_id;
        ParamByName('project_id').Value:=project_id;
        ParamByName('date_added').Value:=now;
       ExecSQL;
      end; }

      with Qtt do begin
       Close;
        Sql.Clear;
        SQL.Add('update CRUISE set ');
        SQL.Add('cruise_number=:cruise_number, date_added=:d_add, date_updated=:d_upd ');
        SQL.Add('where id=:id ');
        ParamByName('ID').Value:=cnt;
        ParamByName('cruise_number').Value:=platf;
        ParamByName('d_add').Value:=stdate_upd;
        ParamByName('d_upd').Value:=stdate_upd;
       ExecSQL;
      end;

 {  memo1.lines.add(platf+'   '+
                   inttostr(country_id)+'   '+
                   inttostr(institute_id)+'   '+
                   inttostr(project_id));  }

  until eof(dat);
  finally
     Trt.Commit;
     Qtt.Free;
     Trt.Free;
     //Qt.EnableControls;
   end;

end;

procedure Tfrmload_argo.Button2Click(Sender: TObject);
Var
  dat:text;
  c, k, cnt, pp:integer;

  st, fname, prof_type, inst_code, date_str, platf, buf_str, date_upd:string;
  country_id, institute_id, project_id, cruise_id: integer;

  lat, lon:string;
  stlat, stlon:real;

  st_id_orig:Int64;


  Qtt, Qt1:TSQLQuery;
  TRt:TSQLTransaction;

  stdate, stdate_upd:TDateTime;
  stnum:string;

begin

     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;
     //Trt.

     Qtt:=TSQLQuery.Create(self);
     Qtt.Database:=frmdm.IBDB;
     Qtt.Transaction:=TRt;

     Qt1:=TSQLQuery.Create(self);
     Qt1.Database:=frmdm.IBDB;
     Qt1.Transaction:=TRt;


      with Qtt do begin
       Close;
        Sql.Clear;
        SQL.Add(' select id from platform ');
        SQL.Add(' where name=:name order by ID ');
       Prepare;
      end;

  {    with Qt1 do begin
       Close;
        Sql.Clear;
        SQL.Add(' insert into STATION ');
        SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ');
        SQL.Add(' ST_NUMBER_ORIGIN, DATE_ADDED, DATE_UPDATED)');
        SQL.Add(' VALUES ');
        SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ');
        SQL.Add(' :ST_NUMBER_ORIGIN, :DATE_ADDED, :DATE_UPDATED)');
       Prepare;
      end;  }

try
  AssignFile(dat, ePath.text+'ar_index_global_prof.txt');
  reset(dat);

  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';

  cnt:=0;
 { repeat
   inc(cnt);
   readln(dat, st);
  until cnt=385958; }

  repeat
   inc(cnt);

  // caption:=inttostr(cnt);
  // application.ProcessMessages;

   readln(dat, st);

   c:=0; pp:=0;
   for k:=1 to 8 do begin
    buf_str:='';
    repeat
      inc(c);
      inc(pp);
      if st[c]<>',' then buf_str:=buf_str+st[c];
     // showmessage(st[c]);
    until (st[c]=',') or (c=length(st));

   // showmessage(buf_str);
    case k of
     1: fname:=buf_str;
     2: date_str:=buf_str;
     3: lat:=buf_str;
     4: lon:=buf_str;
     7: inst_code:=buf_str;
     8: date_upd:=buf_str;
    end;
   end;


   k:=Pos('/', fname);
   buf_str:='';
   repeat
    inc(k);
    if fname[k]<>'/' then buf_str:=buf_str+fname[k];
   until fname[k]='/';
   platf:=buf_str;

  // cruise_id:=20000000+StrToInt(platf);

   stnum:=copy(fname, pos('_', fname)+1, length(fname));
   stnum:=copy(stnum, 1, length(stnum)-3);
  // showmessage(stnum+'   '+copy(stnum, length(stnum), 1));
   if copy(stnum, length(stnum), 1)='D' then
   stnum:=copy(stnum,1, length(stnum)-1);
   stnum:=IntToStr(StrToInt(stnum));


   st_id_orig:=Strtoint(platf)*10000+Strtoint(stnum);

 // if st_id_orig>200000000 then showmessage(platf+'   '+stnum+'   '+inttostr(st_id_orig)


     if (trim(lat)<>'') and (trim(lon)<>'') and
        (length(date_str)=14) and (cruise_id>0) then begin

     try
       stlat:=StrToFloat(lat);
       stlon:=StrToFloat(lon);

       if (stlat>=-90) and (stlat<=90) and (stlon>=-180) and (stlon<=180) then begin

       stdate:=EncodeDateTime(StrToInt(copy(date_str, 1, 4)),
                          StrToInt(copy(date_str, 5, 2)),
                          StrToInt(copy(date_str, 7, 2)),
                          StrToInt(copy(date_str, 9, 2)),
                          StrToInt(copy(date_str, 11, 2)),
                          StrToInt(copy(date_str, 13, 2)),
                          0);

       stdate_upd:=EncodeDateTime(StrToInt(copy(date_upd, 1, 4)),
                          StrToInt(copy(date_upd, 5, 2)),
                          StrToInt(copy(date_upd, 7, 2)),
                          StrToInt(copy(date_upd, 9, 2)),
                          StrToInt(copy(date_upd, 11, 2)),
                          StrToInt(copy(date_upd, 13, 2)),
                          0);

      //  memo1.lines.add(platf+'   '+stnum+'   '+inttostr(st_id_orig));

     {   memo1.lines.add(platf+'   '+
                   inttostr(cruise_id)+'   '+
                   floattostr(Stlat)+'   '+
                   floattostr(Stlon)+'   '+
                   datetimetostr(stdate));}

   // try
   {  with Qt1 do begin
        ParamByName('ID').Value:=cnt;
        ParamByName('latitude').Value:=StLat;
        ParamByName('longitude').Value:=StLon;
        ParamByName('dateandtime').Value:=StDate;
        ParamByName('cruise_id').Value:=cruise_id;
        ParamByName('st_number_origin').Value:=stnum;
        ParamByName('date_added').Value:=stdate_upd;
        ParamByName('date_updated').Value:=stdate_upd;
       ExecSQL;
      end; }

      with Qt1 do begin
       Close;
        SQL.Clear;
        SQL.Add(' update station set ST_ID_ORIGIN=:ST_ID ');
        SQL.Add(' where ID=:ID ');
        ParamByName('ID').Value:=20000000+cnt;
        ParamByName('ST_ID').Value:=st_id_orig;
       ExecSQL;
      end;

     trt.CommitRetaining;

     end;  // coordinates in -90..90, -180..180
     except
      trt.RollbackRetaining;
      memo1.lines.add('insert error: '+st);
     end;
     end; // else memo1.lines.add('conditions: '+st);  //coords not empty

  until eof(dat);
  finally
     Trt.Commit;
     Qtt.Free;
     Trt.Free;
     //Qt.EnableControls;
   end;

end;


procedure Tfrmload_argo.GetCodes(argo_code:string; Var country_id, institute_id, project_id:integer);
begin
 country_id:=-9;
 institute_id:=-9;
 project_id:=-9;

   if argo_code='AO' then begin institute_id:=251; project_id:=422; country_id:=186; end;
   if argo_code='BO' then begin institute_id:=655; project_id:=31;  country_id:=229; end;
   if argo_code='CS' then begin institute_id:=48;  project_id:=27;  country_id:=164; end;
   if argo_code='HZ' then begin institute_id:=820; project_id:=69;  country_id:=231; end;
   if argo_code='IF' then begin institute_id:=388; project_id:=124; country_id:=190; end;
   if argo_code='IN' then begin institute_id:=821; project_id:=187; country_id:=196; end;
   if argo_code='JA' then begin institute_id:=538; project_id:=201; country_id:=204; end;
   if argo_code='JM' then begin institute_id:=539; project_id:=201; country_id:=204; end;
   if argo_code='KM' then begin institute_id:=125; project_id:=447; country_id:=179; end;
   if argo_code='KO' then begin institute_id:=124; project_id:=447; country_id:=179; end;
   if argo_code='ME' then begin institute_id:=822; project_id:=61;  country_id:=173; end;
   if argo_code='NM' then begin institute_id:=823; project_id:=69;  country_id:=231; end;
end;


procedure Tfrmload_argo.btnParametersClick(Sender: TObject);
Var
  dat:text;
  st, buf_str:string;
  cnt, c:integer;
begin
  AssignFile(dat, ePath.text+'ar_index_global_prof.txt'); reset(dat);

  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';

  cnt:=0;
  repeat
   inc(cnt);

   readln(dat, st);

   c:=0;
    buf_str:='';
    repeat
      inc(c);
      if st[c]<>',' then buf_str:=buf_str+st[c];
    until (st[c]=',') or (c=length(st));

    WriteCoreProfile(ePath.Text+buf_str);
  until eof(dat);
 CloseFile(dat);
end;


procedure Tfrmload_argo.WriteCoreProfile(fname:string);
Var
   c, k, cnt, pp, st_id_orig:integer;
  st, prof_type, inst_code, date_str, platf, buf_str, date_upd:string;
  country_id, institute_id, project_id, cruise_id: integer;

  lat, lon:string;
  stlat, stlon:real;


  Qtt, Qt1:TSQLQuery;
  TRt:TSQLTransaction;
begin
{TRt:=TSQLTransaction.Create(self);
TRt.DataBase:=frmdm.IBDB;

Qtt:=TSQLQuery.Create(self);
Qtt.Database:=frmdm.IBDB;
Qtt.Transaction:=TRt; }


 { nc_open(pansichar(AnsiString(fname)), NC_NOWRITE, ncid); // only for reading

  nc_inq_varid    (ncid, pAnsiChar(AnsiString('PRES_ADJUSTED')), varidp); // variable ID

  //nc_inq_vartype  (ncid, varidp, vtype);   // variable type
 // nc_inq_varndims (ncid, varidp, ndimsp);  // dimentions quantity

  DATE_CREATION = "20150609022709" ;
  DATE_UPDATE = "20170501170730" ;
  PLATFORM_NUMBER ="5904580 " ;
  CYCLE_NUMBER = 8
  DATA_MODE = "D" ;



  SetLength(fp, 1);
  nc_get_var1_float(ncid, varidp, start^, fp);
  Val0:=fp[0]; }

end;


procedure Tfrmload_argo.Button3Click(Sender: TObject);
Var
 Qtt, Qt1, qt2:TSQLQuery;
 TRt:TSQLTransaction;
 id:integer;
 id_str:string;
begin
 memo1.clear;

    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;

    Qtt:=TSQLQuery.Create(self);
    Qtt.Database:=frmdm.IBDB;
    Qtt.Transaction:=TRt;


     Qt1:=TSQLQuery.Create(self);
     Qt1.Database:=frmdm.IBDB;
     Qt1.Transaction:=TRt;


      with Qtt do begin
       Close;
        Sql.Clear;
        SQL.Add(' SELECT LIST( id ) ');
        SQL.Add(' FROM station ');
        SQL.Add(' GROUP BY latitude, longitude, dateandtime ');
        SQL.Add(' HAVING ( COUNT(*) > 1 )');
       Open;
      end;

      while not Qtt.eof do begin
      id_str:=Qtt.Fields[0].Value;
      id:=StrToInt(copy(id_str, Pos(',', id_str)+1, length(id_str)));
         with Qt1 do begin
           Close;
            Sql.Clear;
            SQL.Add(' update station set stversion= 1');
            SQL.Add(' where id='+inttostr(id));
           ExecSQL;
         end;
         trt.CommitRetaining;

       Qtt.Next;
      end;

    trt.Commit;
end;


end.

