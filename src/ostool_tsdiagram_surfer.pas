unit ostool_tsdiagram_surfer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, Math, IniFiles,

  osmain, dm, GibbsSeaWater;

procedure GetTSDiagramData;
procedure GetDensityContour(path:string; lat,lon,tmin,tmax,smin,smax,dmin,dmax:real);
procedure GetDensityProfile(ID:int64; pqf2_str: string; stlat, stlon:real;
  var tmin, tmax, smin, smax, dmin, dmax: real);
procedure GetTSDiagramScript(path: string);

type
  CDSDensity_rec=record
    lev:real;
    TVal:real;
    SVal:real;
    DVal:real;
  end;
  CDSDensity_arr=array of CDSDensity_rec;

Var
  CDSDensity: CDSDensity_arr;

implementation

procedure GetTSDiagramData;
var
  ID, ID_old: int64;
  k, ll:integer;
  lat,lon: real;
  tmin,tmax,smin,smax,dmin,dmax:double;
  Ini:TInifile;
  pqf2_str, tsdiagram_path:string;
  ts_out:text;
begin
  Ini := TIniFile.Create(IniFileName);
    try
      pqf2_str:='';
      for k:=0 to PQF2_list.Count-1 do
        if Ini.ReadBool('osparameters_list', 'PQF2_'+inttostr(k), true) =true then
          pqf2_str:=pqf2_str+','+ Copy(PQF2_list.Strings[k], 2, Pos(']', PQF2_list.Strings[k])-2);
      pqf2_str:=copy(pqf2_str, 2, length(pqf2_str));
   //   showmessage(pqf2_str);
    finally
     Ini.Free;
    end;

    tsdiagram_path:=GlobalUnloadPath+'tsdiagram';
    if not DirectoryExists(tsdiagram_path) then CreateDir(tsdiagram_path);

    AssignFile(ts_out, tsdiagram_path+PathDelim+'ts_diagram.dat'); rewrite(ts_out);
    writeln(ts_out, 'S':8, 'T':8, 'D':8, 'Lev':11, 'ID':8);

    tmin:=9999; tmax:=-9999;
    smin:=9999; smax:=-9999;
    dmin:=9999; dmax:=-9999;
     try
      ID_old:=frmdm.Q.FieldByName('ID').Value;
      frmdm.Q.DisableControls;
      frmdm.Q.First;
       While not frmdm.Q.Eof do begin
         ID:=frmdm.Q.FieldByName('ID').value;
         Lat:=frmdm.Q.FieldByName('latitude').value;
         Lon:=frmdm.Q.FieldByName('longitude').value;

         GetDensityProfile(frmdm.Q.FieldByName('ID').value, pqf2_str,
                          lat, lon, tmin, tmax, smin, smax, dmin, dmax);

         if length(CDSDensity) = 0 then Continue;

         for ll:=1 to high(CDSDensity) do begin

             writeln(ts_out, CDSDensity[ll].SVal:8:4,
                             CDSDensity[ll].TVal:8:4,
                             CDSDensity[ll].DVal:8:4,
                             CDSDensity[ll].Lev:11:4,
                             ID:8);
          end;
          frmdm.Q.Next;
       end;

     finally
      frmdm.Q.Locate('ID', ID_old, []);
      frmdm.Q.EnableControls;
     end;
     CloseFile(ts_out);

  // Density contour for Surfer
  GetDensityContour(tsdiagram_path,lat,lon,tmin,tmax,smin,smax,dmin,dmax);

  // Script for Surfer
  GetTSDiagramScript(tsdiagram_path);

  frmosmain.RunScript(2, Concat(' -x ', '"', tsdiagram_path+PathDelim+'script.bas"') , nil);
end;

procedure GetDensityProfile(ID:int64; pqf2_str: string; stlat, stlon:real;
  var tmin, tmax, smin, smax, dmin, dmax: real);
var
TFL,SFL,count_lev:integer;
lev,TVal,SVal,DVal,lat, lon, svan,p,Gr,Dbuf,Lbuf, ParF, TPot:real;
T_FlagIsSet, S_FlagIsSet:boolean;

lev_p, lev_m, atm_pref_dbar, SA : real;

TRt:TSQLTransaction;
Qt:TSQLQuery;

begin

  TRt:=TSQLTransaction.Create(nil);
  TRt.DataBase:=frmdm.IBDB;

  Qt:=TSQLQuery.Create(nil);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

  try
   with Qt do begin
    Close;
    SQL.Clear;
    SQL.Add(' SELECT ');
    SQL.Add(' P_TEMPERATURE.LEV_DBAR as LEV_DBAR, ');
    SQL.Add(' P_TEMPERATURE.LEV_M as LEV_M, ');
    SQL.Add(' P_TEMPERATURE.VAL as TVAL, P_SALINITY.VAL as SVAL');
    SQL.Add(' FROM ');
    SQL.Add(' P_TEMPERATURE, P_SALINITY ');
    SQL.Add(' WHERE ');
    SQL.Add(' P_TEMPERATURE.ID=:ID ');
    SQL.Add(' AND P_TEMPERATURE.ID=P_SALINITY.ID ');
    SQL.Add(' AND P_TEMPERATURE.LEV_DBAR=P_SALINITY.LEV_DBAR ');
    SQL.Add(' AND P_TEMPERATURE.LEV_DBAR=P_SALINITY.LEV_DBAR ');
    SQL.Add(' AND P_TEMPERATURE.INSTRUMENT_ID=P_SALINITY.INSTRUMENT_ID ');
    SQL.Add(' AND P_TEMPERATURE.PROFILE_BEST IS TRUE ');
    SQL.Add(' AND P_SALINITY.PROFILE_BEST IS TRUE ');
    SQL.Add(' AND P_TEMPERATURE.PQF2 in ('+pqf2_str+') ');
    SQL.Add(' AND P_SALINITY.PQF2 in ('+pqf2_str+') ');
    SQL.Add(' ORDER BY ');
    SQL.Add(' P_TEMPERATURE.LEV_DBAR ');
    ParamByName('ID').AsInteger:=ID;
    Open;
   end;

   count_lev:=0;
   Qt.First;
   while not Qt.Eof do begin
    Lev_p :=Qt.FieldByName('LEV_DBAR').AsFloat;
    Lev_m :=Qt.FieldByName('LEV_DBAR').AsFloat;
    TVal  :=Qt.FieldByName('TVAL').AsFloat;
    SVal  :=Qt.FieldByName('SVAL').AsFloat;

    count_lev:=count_lev+1;
    SetLength(CDSDensity, count_lev+1);

    atm_pref_dbar:=10.1325;

    SA  := gsw_sa_from_sp(SVal, atm_pref_dbar, lon, lat); // absolute salinity
    p:=atm_pref_dbar+lev_p; //absolute pressure=atmospheric pressure+hydrostatic pressure
    Tpot:=gsw_pt_from_t(SA, TVal, p, atm_pref_dbar);  //potential temperature
    DVal:=gsw_rho_t_exact(SA, TPot, p); //potential density
    DVal:=DVal-1000;

     case depth_units_id of
      0: Lev := Lev_m;
      1: Lev := Lev_p
     end;

    CDSDensity[count_lev].lev :=Lev;
    CDSDensity[count_lev].TVal:=TVal;
    CDSDensity[count_lev].SVal:=SVal;
    CDSDensity[count_lev].DVal:=DVal;

    tmin:=min(tmin,Tval);
    tmax:=max(tmax,Tval);
    smin:=min(smin,Sval);
    smax:=max(smax,Sval);
    dmin:=min(dmin,Dval);
    dmax:=max(dmax,Dval);

    Qt.Next;
   end;
   Qt.Close;

   finally
    TRt.Commit;
    Qt.Free;
    TRt.Free;
   end;
end;


procedure GetDensityContour(path:string; lat,lon,tmin,tmax,smin,smax,dmin,dmax:real);
var
k1,k2,i,step:integer;
temp,salt,dens,dif,MinD:double;
atm_pref_dbar,lev_p,SA,p,Tpot,DVal,tst,sst: double;
dens_out:text;
dens_st, sName: string;
begin
  atm_pref_dbar:=10.1325;
  lev_p:=0; //surface

  if trunc(dmax)-trunc(dmin)<=2 then dif:=0.25;
  if (trunc(dmax)-trunc(dmin)>2) and
     (trunc(dmax)-trunc(dmin)<=5) then dif:=0.5;
  if trunc(dmax)-trunc(dmin)>5 then dif:=1;

 { minD:=trunc(dmin); k:=0;
  while not (MinD>trunc(dmax)) do begin
  //    series1.Levels.Add;
  //   series1.Levels[k].UpToValue:=minD;
    inc(k);
    MinD:=Mind+dif;
  end; }

  AssignFile(dens_out, path+PathDelim+'density_contour.grd'); rewrite(dens_out);

  writeln(dens_out, 'DSAA');
  writeln(dens_out, '51 51');
  writeln(dens_out, floattostr(smin)+' '+floattostr(smax));
  writeln(dens_out, floattostr(tmin)+' '+floattostr(tmax));
  writeln(dens_out, floattostr(dmin)+' '+floattostr(dmax));

  step:=50;
  //  series1.Clear;
  tst:=(tmax-tmin)/step;
  sst:=(smax-smin)/step;
  for k2:=1 to step+1 do begin
    temp:=tmin+tst*(k2-1);
    dens_st:='';

 //   sName:='d'+inttostr(k2);
//    AddLineSeries(Chart1, sName, clBlack, sName);
//    inc(mik);
    for k1:=1 to step+1 do begin
      salt:=smin+sst*(k1-1);

      SA := gsw_sa_from_sp(salt, atm_pref_dbar, lon, lat); // absolute salinity
      p:=atm_pref_dbar+lev_p; //absolute pressure=atmospheric pressure+hydrostatic pressure
      Tpot:=gsw_pt_from_t(SA, temp, p, atm_pref_dbar);  //potential temperature
      DVal:=gsw_rho_t_exact(SA, TPot, p); //potential density
      dens:=DVal-1000;

//      TLineSeries(Chart1.Series[mik]).AddXY(salt, temp, dens);
   //  series1.AddXYZ(x,z,y);

      dens_st:=dens_st+floattostr(dens)+' ';
    end;
    dens_st:=copy(dens_st, 1, length(dens_st)-1);
    writeln(dens_out, dens_st);
  end;
  Closefile(dens_out);
end;

procedure GetTSDiagramScript(path: string);
var
  dat:text;
begin

try
  AssignFile(dat, path+PathDelim+'script.bas'); Rewrite(dat);

    writeln(dat, 'Sub Main');
    writeln(dat, 'Dim Surf, Diagram, Doc, Var As Object');
    writeln(dat, '');
    writeln(dat, 'pathDataFile ="'+path+PathDelim+'ts_diagram.dat"');
    writeln(dat, 'pathDensity = "'+path+PathDelim+'density_contour.grd"');
    writeln(dat, '');
    writeln(dat, 'Set Surf = CreateObject("Surfer.Application")');
    writeln(dat, '');
    writeln(dat, 'Surf.Visible = True');
    writeln(dat, '  Set Doc = Surf.Documents.Add');
    writeln(dat, '  Set Diagram = Doc.Windows(1)');
    writeln(dat, '  Diagram.AutoRedraw = False');
    writeln(dat, '  Doc.PageSetup.Orientation = srfLandscape');
    writeln(dat, '  Doc.DefaultFill.Pattern="Solid"');
    writeln(dat, '  Doc.DefaultFill.ForeColor=srfColorBlack20');
    writeln(dat, '');
    writeln(dat, 'Set ContourMapFrame=Doc.Shapes.AddContourMap(pathDensity)');
    writeln(dat, 'Set Axes = ContourMapFrame.Axes');
    writeln(dat, 'Set Axis = Axes("left axis")');
    writeln(dat, '    Axis.Title = "Temperature, C"');
    writeln(dat, 'Set Axis = Axes("bottom axis")');
    writeln(dat, '    Axis.Title = "Salinity, PSU"');
    writeln(dat, 'Set Axis = Axes("top axis")');
    writeln(dat, '    Axis.MajorTickType = srfTickNone');
    writeln(dat, 'Set Axis = Axes("right axis")');
    writeln(dat, 'Axis.MajorTickType = srfTickNone');
    writeln(dat, '');
    writeln(dat, 'Set PostMap=Doc.Shapes.AddPostMap(DataFileName:=pathDataFile, _');
    writeln(dat, '   xCol:=1, _');
    writeln(dat, '   yCol:=2)');
    writeln(dat, 'Set sampleMarks = PostMap.Overlays(1)');
    writeln(dat, '    With SampleMarks');
    writeln(dat, '        .LabCol=0');
    writeln(dat, '        .LabelFont.Size=5');
    writeln(dat, '        .LabelAngle=0');
    writeln(dat, '        .Symbol.Index=12');
    writeln(dat, '        .Symbol.Size=0.1');
    writeln(dat, '        .Symbol.Color=srfColorBlack70');
    writeln(dat, '    End With');
    writeln(dat, '');
    writeln(dat, 'Doc.Shapes.SelectAll');
    writeln(dat, 'Set NewMap = Doc.Selection.OverlayMaps');
    writeln(dat, 'NewMap.xLength=15');
    writeln(dat, 'NewMap.yLength=15');
    writeln(dat, '');
    writeln(dat, 'Diagram.Zoom(srfZoomFitToWindow)');
    writeln(dat, 'Diagram.AutoRedraw = True');
    writeln(dat, '');
    writeln(dat, 'End Sub');

  finally
    CloseFile(dat);
  end;
end;

end.

