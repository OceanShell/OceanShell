unit osexport_ascii;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, osmain, dm, osbathymetry, procedures;

procedure ExportASCII;


implementation


procedure ExportASCII;
Var
ff, ID: integer;
tbl, source, plat, tbl_suf: string;
Lat, lon, lev_d, lev_m: real;
depth, gebco:integer;
dat1:TDateTime;
TRt:TSQLTransaction;
Qt1:TSQLQuery;

out1, out2, out3: text;
yy, mn, dd:word;
cnt:integer;
begin
TRt:=TSQLTransaction.Create(nil);
TRt.DataBase:=frmdm.IBDB;

Qt1:=TSQLQuery.Create(nil);
Qt1.Database:=frmdm.IBDB;
Qt1.Transaction:=TRt;

//Source:='ITP';
//tbl_suf:='ITP';
Source:='WOD2018';
tbl_suf:='OSD';

AssignFile(out1, GlobalUnloadPath+Source+'_MD_Full.txt'); rewrite(out1);
AssignFile(out2, GlobalUnloadPath+Source+'_MD.txt'); rewrite(out2);
AssignFile(out3, GlobalUnloadPath+Source+'_data.txt'); rewrite(out3);

try
 cnt:=0;

 frmdm.Q.DisableControls;
 frmdm.Q.First;
 while not frmdm.Q.EOF do begin
  inc(cnt);

  ID  := frmdm.Q.FieldByName('ID').AsInteger;
  lat := frmdm.Q.FieldByName('LATITUDE').AsFloat;
  lon := frmdm.Q.FieldByName('LONGITUDE').AsFloat;
  dat1:= frmdm.Q.FieldByName('DATEANDTIME').AsDateTime;

  decodedate(dat1, yy, mn, dd);

  Plat:= frmdm.Q.FieldByName('PLATF').AsString;

  gebco := -GetGEBCODepth(lon, lat);

  with Qt1 do begin
   Close;
    SQL.Clear;
    SQL.Add(' SELECT P_TEMPERATURE_'+tbl_suf+'.LEV_DBAR, ');
    SQL.Add(' P_TEMPERATURE_'+tbl_suf+'.VAL, P_SALINITY_'+tbl_suf+'.VAL ');
    SQL.Add(' FROM P_TEMPERATURE_'+tbl_suf+', P_SALINITY_'+tbl_suf+' ');
    SQL.Add(' WHERE P_TEMPERATURE_'+tbl_suf+'.ID=P_SALINITY_'+tbl_suf+'.ID ');
    SQL.Add(' AND P_TEMPERATURE_'+tbl_suf+'.LEV_DBAR=P_SALINITY_'+tbl_suf+'.LEV_DBAR ');
    SQL.Add(' AND P_TEMPERATURE_'+tbl_suf+'.ID=:ID ');
    SQL.Add(' AND P_TEMPERATURE_'+tbl_suf+'.PQF2=4 AND P_SALINITY_'+tbl_suf+'.PQF2=4 ');
    SQL.Add(' ORDER BY P_TEMPERATURE_'+tbl_suf+'.ID, P_TEMPERATURE_'+tbl_suf+'.LEV_DBAR ');
    ParamByName('ID').AsInteger:=ID;
   Open;
   Last;
   First;
  end;

  if (Qt1.RecordCount>3) and (gebco>10) then begin

  Writeln(out1, inttostr(cnt)+' '+
                floattostr(lat)+' '+
                floattostr(lon)+' '+
                inttostr(yy)+' '+
                inttostr(mn)+' '+
                inttostr(dd)+' '+
                inttostr(gebco)+' '+
                '"'+Source+'" '+
                '"'+Plat+'"');

  Writeln(out2, inttostr(cnt)+' '+
                floattostr(lat)+' '+
                floattostr(lon)+' '+
                inttostr(yy)+' '+
                inttostr(mn)+' '+
                inttostr(dd));



       Qt1.First;
       while not Qt1.eof do begin
         writeln(out3, inttostr(cnt)+' '+
                       floattostr(Qt1.Fields[0].AsFloat)+' '+
                       floattostr(Qt1.Fields[1].AsFloat)+' '+
                       floattostr(Qt1.Fields[2].AsFloat));

        Qt1.Next;
       end;
     end; //profile is not empty

    // if cnt =10 then break;

      {$IFDEF WINDOWS}
        Procedures.ProgressTaskbar(cnt, frmdm.Q.RecordCount-1);
      {$ENDIF}

      frmdm.Q.Next;
    end; //Q

  finally
     frmdm.Q.EnableControls;

     {$IFDEF WINDOWS}
        Procedures.ProgressTaskbar(0, 0);
     {$ENDIF}

    CloseFile(out1);
    CloseFile(out2);
    CloseFile(out3);

    Trt.Commit;
    Qt1.close;
    Qt1.Free;
    TrT.Free;
  end;
end;

end.

