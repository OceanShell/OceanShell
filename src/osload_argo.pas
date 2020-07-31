unit osload_argo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SQLDB, DB,
  DateUtils, Variants, BufDataset;

type

  { Tfrmload_argo }

  Tfrmload_argo = class(TForm)
    btnUpdateCruise: TButton;
    btnParametersBio: TButton;
    Button2: TButton;
    btnParameters: TButton;
    Button3: TButton;
    ePath: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    procedure btnParametersBioClick(Sender: TObject);
    procedure btnParametersClick(Sender: TObject);
    procedure btnUpdateCruiseClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    procedure GetCodes(argo_code:string; Var country_id, institute_id, project_id:integer);
    procedure WriteCoreProfile(fname:string);
  //  procedure WriteBioProfile(fname:string; ID: integer);
  public

  end;

var
  frmload_argo: Tfrmload_argo;

implementation

{$R *.lfm}

{ Tfrmload_argo }

uses osmain, dm, declarations_netcdf;

procedure Tfrmload_argo.btnUpdateCruiseClick(Sender: TObject);
Var
  dat:text;
  c, k, cnt_added, cnt_updated, cnt_removed, ID:integer;
  st, fname, prof_type, inst_code, date_upd, platf, buf_str:string;
  country_id, institute_id, project_id: integer;
  stdate_upd:TDateTime;

  Qt1, Qt2:TSQLQuery;
  TRt:TSQLTransaction;

  ID_buf:TBufDataset;
begin
if not FileExists(epath.text+'ar_index_global_meta.txt') then
  if MessageDlg('ar_index_global_meta.txt cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

memo1.Clear;
try
    TRt:=TSQLTransaction.Create(self);
    TRt.DataBase:=frmdm.IBDB;

    Qt1:=TSQLQuery.Create(self);
    Qt1.Database:=frmdm.IBDB;
    Qt1.Transaction:=TRt;

    Qt2:=TSQLQuery.Create(self);
    Qt2.Database:=frmdm.IBDB;
    Qt2.Transaction:=TRt;


    ID_buf:=TBufDataSet.Create(nil);
      with ID_buf.FieldDefs do begin
       Add('id'   ,ftinteger, 0, false);
      end;
    ID_buf.CreateDataSet;


  AssignFile(dat, epath.text+'ar_index_global_meta.txt');
  reset(dat);

  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';

  cnt_added:=0;
  cnt_updated:=0;
  repeat
   readln(dat, st);


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

   ID:=20000000+strtoint(platf);

   with ID_buf do begin
    Append;
     FieldByName('ID').asInteger:=ID;
    Post;
   end;


    with Qt1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT ID, DATE_UPDATED FROM CRUISE WHERE ID=:ID ');
     ParamByName('ID').AsInteger:=ID;
    Open;
   end;

   if Qt1.IsEmpty=false then begin
    if stdate_upd>Qt1.FieldByName('DATE_UPDATED').AsDateTime then begin
    // showmessage(datetimetostr(stdate_upd)+'   '+datetimetostr(Qt1.FieldByName('DATE_UPDATED').AsDateTime));
      with Qt2 do begin
          Close;
           Sql.Clear;
           SQL.Add(' UPDATE CRUISE SET DATE_UPDATED=:DD ');
           SQL.Add(' WHERE ID=:ID ');
           ParamByName('ID').Value:=ID;
           ParamByName('DD').Value:=stdate_upd;
          ExecSQL;
      end;
     inc(cnt_updated);
     memo1.lines.add('Updated -> '+inttostr(ID));
     Trt.CommitRetaining;
    end;
   end;

   if Qt1.IsEmpty=true then begin
    GetCodes(inst_code, country_id, institute_id, project_id);

     with Qt2 do begin
       Close;
        Sql.Clear;
        SQL.Add(' INSERT INTO PLATFORM ');
        SQL.Add(' (ID, NAME, COUNTRY_ID, DATE_ADDED, NOTES) ');
        SQL.Add(' VALUES ' );
        SQL.Add(' (:ID, :name, :country_id, :date_added, :NOTES) ');
        ParamByName('ID').Value:=ID;
        ParamByName('name').Value:=platf;
        ParamByName('country_id').Value:=country_id;
        ParamByName('date_added').Value:=stdate_upd;
        ParamByName('NOTES').AsWideString:='https://fleetmonitoring.euro-argo.eu/float/'+platf;
       ExecSQL;
      end;
    Trt.CommitRetaining;

    with Qt2 do begin
     Close;
      SQL.Clear;
      SQL.Add('insert into CRUISE');
      SQL.Add(' (ID, platform_id, source_id, institute_id, project_id, ');
      SQL.Add(' DATE_ADDED, DATE_UPDATED, CRUISE_NUMBER) ');
      SQL.Add(' VALUES ' );
      SQL.Add(' (:ID, :platform_id, :source_id, :institute_id, :project_id, ');
      SQL.Add(' :DATE_ADDED, :DATE_UPDATED, :CRUISE_NUMBER) ');
      ParamByName('ID').Value:=ID;
      ParamByName('platform_id').Value:=ID;
      ParamByName('source_id').Value:=5;
      ParamByName('institute_id').Value:=institute_id;
      ParamByName('project_id').Value:=project_id;
      ParamByName('date_added').Value:=stdate_upd;
      ParamByName('date_updated').Value:=stdate_upd;
      ParamByName('cruise_number').Value:=platf;
     ExecSQL;
    end;
    inc(cnt_added);
    memo1.lines.add('New -> '+inttostr(ID));
   end;
  Qt1.Close;
  until eof(dat);



  (* removing any cruises which are not in the list any more *)
   with Qt1 do begin
     Close;
       SQL.Clear;
       SQL.Add(' SELECT ID FROM CRUISE ORDER BY ID ');
     Open;
   end;

   cnt_removed:=0;
   while not Qt1.EOF do begin
    if VarIsNull(ID_buf.Lookup('ID', Qt1.FieldByName('ID').asInteger,'ID')) then begin
      with Qt2 do begin
       Close;
        Sql.Clear;
        SQL.Add(' DELETE FROM CRUISE WHERE ID=:ID ');
        ParamByName('ID').Value:=Qt1.FieldByName('ID').asInteger;
       ExecSQL;
      end;

      with Qt2 do begin
       Close;
        Sql.Clear;
        SQL.Add(' DELETE FROM PLATFORM WHERE ID=:ID ');
        ParamByName('ID').Value:=Qt1.FieldByName('ID').asInteger;
       ExecSQL;
      end;
      Trt.CommitRetaining;

    memo1.lines.add('Removed -> '+inttostr(ID));
    inc(cnt_removed);
    end;
    Qt1.Next;
   end;
   Qt1.Close;


finally
   Trt.Commit;
   Qt1.Free;
   Qt2.Free;
   Trt.Free;
   ID_buf.Free;
   memo1.lines.add('=====');
   memo1.lines.add('Added: '+inttostr(cnt_added));
   memo1.lines.add('Updated: '+inttostr(cnt_updated));
   memo1.lines.add('Removed: '+inttostr(cnt_removed));
 end;

end;


procedure Tfrmload_argo.Button2Click(Sender: TObject);
Var
  dat:text;
  c, k, cnt, max_id, pp:integer;

  st, fname, prof_type, inst_code, date_str, platf, buf_str, date_upd:string;
  country_id, institute_id, project_id, cruise_id: integer;

  lat, lon:string;
  stlat, stlon:real;

  st_id_orig:Int64;


  Qt2, Qt1:TSQLQuery;
  TRt:TSQLTransaction;

  stdate, stdate_upd, max_date:TDateTime;
  stnum:string;

begin
if not FileExists(epath.text+'ar_index_global_prof.txt') then
  if MessageDlg('ar_index_global_prof.txt cannot be found', mtWarning, [mbOk], 0)=mrOk then exit;

  try
     TRt:=TSQLTransaction.Create(self);
     TRt.DataBase:=frmdm.IBDB;

     Qt1:=TSQLQuery.Create(self);
     Qt1.Database:=frmdm.IBDB;
     Qt1.Transaction:=TRt;

     Qt2:=TSQLQuery.Create(self);
     Qt2.Database:=frmdm.IBDB;
     Qt2.Transaction:=TRt;

      with Qt1 do begin
       Close;
        Sql.Clear;
        SQL.Add(' select max(id) from station where ID BETWEEN 20000000 AND 30000000  ');
       Open;
        max_id  :=Qt1.Fields[0].AsInteger;
       Close;
      end;


      with Qt1 do begin
       Close;
        Sql.Clear;
        SQL.Add(' select id, date_updated from station ');
        SQL.Add(' where st_id_origin=:id_orig ');
       Prepare;
      end;

      with Qt2 do begin
       Close;
        Sql.Clear;
        SQL.Add(' insert into STATION ');
        SQL.Add(' (ID, LATITUDE, LONGITUDE, DATEANDTIME, CRUISE_ID, ');
        SQL.Add(' ST_NUMBER_ORIGIN, ST_ID_ORIGIN, DATE_ADDED, DATE_UPDATED)');
        SQL.Add(' VALUES ');
        SQL.Add(' (:ID, :LATITUDE, :LONGITUDE, :DATEANDTIME, :CRUISE_ID, ');
        SQL.Add(' :ST_NUMBER_ORIGIN, :ST_ID_ORIGIN, :DATE_ADDED, :DATE_UPDATED)');
       Prepare;
      end;

  AssignFile(dat, ePath.text+'ar_index_global_prof.txt');
  reset(dat);

  cnt:=0;
  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';

 { repeat
   inc(cnt);
   readln(dat, st);
  until cnt=385958; }

  repeat
   readln(dat, st);

   c:=0; pp:=0;
   for k:=1 to 8 do begin
    buf_str:='';
    repeat
      inc(c);
      inc(pp);
      if st[c]<>',' then buf_str:=buf_str+st[c];
    until (st[c]=',') or (c=length(st));

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

   cruise_ID:=20000000+strtoint(platf);


   stnum:=copy(fname, pos('_', fname)+1, length(fname));
   stnum:=copy(stnum, 1, length(stnum)-3);
  // showmessage(stnum+'   '+copy(stnum, length(stnum), 1));

   if copy(stnum, length(stnum), 1)='D' then begin
     stnum:=copy(stnum,1, length(stnum)-1);
     stnum:=IntToStr(StrToInt(stnum))+'D';
   end else
     stnum:=IntToStr(StrToInt(stnum));


  // st_id_orig:=Strtoint(platf)*10000+Strtoint(stnum);


     if (trim(lat)<>'') and (trim(lon)<>'') and
        (length(date_str)=14) and (cruise_id>0) then begin

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

       inc(cnt);

           with Qt2 do begin
                 Close;
                  Sql.Clear;
                  SQL.Add(' UPDATE STATION SET ST_NUMBER_ORIGIN=:STNUM ');
                  SQL.Add(' WHERE latitude=:lat and longitude=:lon and ');
                  SQL.Add(' dateandtime=:date1');
                  ParamByName('Lat').Value:=stlat;
                  ParamByName('Lon').Value:=stlon;
                  ParamByName('date1').Value:=stdate;
                  ParamByName('STNUM').Value:=stnum;
                 ExecSQL;
             end;

   {   // showmessage(datetimetostr(stdate_upd)+'   '+datetimetostr(max_date));
       with Qt1 do begin
         ParamByName('ID_ORIG').Value:=st_id_orig;
        Open;
       end;

       if Qt1.IsEmpty=false then begin
        if Qt1.FieldByName('date_updated').AsDateTime>stdate_upd then begin
         memo1.lines.add('Existing: '+inttostr(st_id_orig));
        end;
       end;


       if Qt1.IsEmpty=true then begin
       inc(cnt);
       inc(max_id);
       //showmessage('here');
     //  try
        with Qt2 do begin
          ParamByName('ID').Value:=max_id;
          ParamByName('latitude').Value:=StLat;
          ParamByName('longitude').Value:=StLon;
          ParamByName('dateandtime').Value:=StDate;
          ParamByName('cruise_id').Value:=cruise_id;
          ParamByName('st_number_origin').Value:=stnum;
          ParamByName('st_id_origin').Value:=st_id_orig;
          ParamByName('date_added').Value:=stdate_upd;
          ParamByName('date_updated').Value:=stdate_upd;
         ExecSQL;
        end;

        trt.CommitRetaining;
        memo1.lines.add('added: '+
                        inttostr(cnt)+'   '+
                        floattostr(stlat)+'   '+
                        floattostr(stlon)+'   '+
                        datetimetostr(stdate)+'   '+
                        datetimetostr(stdate_upd)+'   '+
                        inttostr(st_id_orig));
     {   except
         trt.RollbackRetaining;
         memo1.lines.add('insert error: '+st);
        end;  }
       end; //q2
       Qt1.Close;    }

    // end;// date>max_date

     end; // coordinates in -90..90, -180..180

     end; // lat<>0

  until eof(dat);
  finally
     Trt.Commit;
     Qt1.Free;
     Qt2.Free;
     Trt.Free;
     memo1.lines.add('=====');
     memo1.lines.add('Done! Added: '+inttostr(cnt));
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



procedure Tfrmload_argo.btnParametersBioClick(Sender: TObject);
begin
{   AssignFile(dat, ePath.text+'argo_bio-profile_index.txt'); reset(dat);

  repeat
   readln(dat, st);
  until copy(st,1, 4)='file';


//aoml/1900722/profiles/BD1900722_001.nc,20061022021624,-40.316,73.389,I,846,AO,PRES TEMP_DOXY BPHASE_DOXY DOXY,RRRD,20200312153230
//aoml/1900722/profiles/BD1900722_002.nc,20061101064423,-40.390,73.528,I,846,AO,PRES TEMP_DOXY BPHASE_DOXY DOXY,RRRD,20200312153230
  cnt:=0;
  repeat
     readln(dat, st);

     c:=0; pp:=0;
     for k:=1 to 10 do begin
      buf_str:='';
      repeat
        inc(c);
        inc(pp);
        if st[c]<>',' then buf_str:=buf_str+st[c];
      until (st[c]=',') or (c=length(st));

      case k of
       1: fname:=buf_str;
       2: date_str:=buf_str;
       3: lat:=buf_str;
       4: lon:=buf_str;
     //5: ocean
     //6: profile type
       7: inst_code:=buf_str;
       8: param_str:=buf_str;
       9: patam_data_mode:=buf_str
      10: date_upd:=buf_str;
      end;
     end;

    WriteBioProfile(ePath.Text+buf_str, ID);
  until eof(dat);
 CloseFile(dat);   }
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

