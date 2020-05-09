unit osexport_divand;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ExtCtrls, CheckLst, IniFiles, DateUtils;

type

  { Tfrmosexport_divand }

  Tfrmosexport_divand = class(TForm)
    btnExport: TButton;
    chkInstrument: TCheckGroup;
    CheckListBox1: TCheckGroup;
    Edit1: TEdit;
    eYY1: TSpinEdit;
    eYY2: TSpinEdit;
    GroupBox1: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    Label1: TLabel;
    seLatMax: TFloatSpinEdit;
    seLatMin: TFloatSpinEdit;
    seLonMax: TFloatSpinEdit;
    seLonMin: TFloatSpinEdit;

    procedure btnExportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private

  public

  end;

var
  frmosexport_divand: Tfrmosexport_divand;
  DIVAndFPath:string;

implementation

{$R *.lfm}

uses dm, osmain, bathymetry, gibbsseawater;

{ Tfrmosexport_divand }


procedure Tfrmosexport_divand.FormCreate(Sender: TObject);
begin
  DIVAndFPath:=GlobalUnloadPath+'DIVAnd'+PathDelim;
    if not DirectoryExists(DIVAndFPath) then CreateDir(DIVAndFPath);
end;


procedure Tfrmosexport_divand.btnExportClick(Sender: TObject);
Var
 f: text;
 ID, ff, k, yymin, yymax, dec, GEBCO: integer;
 Lat, Lon, lev_m, lev_b, Val, dval, TVal, SVal, lev: real;
 yy, mn, dd, hh, mm, ss, ms:word;
 parname, fname, instr, mn_str, dd_str, hh_str, mm_str, id_str:string;
 d:string;
 x, y, LatMax, LonMax, LatMin, LonMin: real;
 ddd, ttt:TDateTime;
begin

   parname:='P_SALINITY';

    for dec:=6 to 6 do begin
      case dec of
        1: begin
           yymin:=1960;
           yymax:=1969;
        end;
        2: begin
           yymin:=1970;
           yymax:=1979;
        end;
        3: begin
           yymin:=1980;
           yymax:=1989;
        end;
        4: begin
           yymin:=1990;
           yymax:=1999;
        end;
        5: begin
           yymin:=2000;
           yymax:=2009;
        end;
        6: begin
           yymin:=2010;
           yymax:=2019;
        end;
      end;

 with frmdm.q do begin
  Close;
   SQL.Clear;
   SQL.Add(' SELECT ');
   SQL.Add(' STATION.ID, STATION.LATITUDE, STATION.LONGITUDE, ');
   SQL.Add(' STATION.DATEANDTIME, '+parname+'.LEV_M, '+parname+'.VAL ');
   SQL.Add(' from STATION, INSTRUMENT, '+parname);
   SQL.Add(' WHERE ');
   SQL.Add(' Station.ID='+parname+'.ID and ');
   SQL.Add(' Station.INSTRUMENT_ID=INSTRUMENT.ID and ');
   SQL.Add(' (STATION.LATITUDE>=80 or (STATION.LATITUDE>=70 and ');
   SQL.Add('  (STATION.LONGITUDE<=-100 or STATION.LONGITUDE>=100))) and ');
   SQL.Add(' Extract(Year from STATION.DATEANDTIME)>=:SSYear1 and ');
   SQL.Add(' Extract(Year from STATION.DATEANDTIME)<=:SSYear2 and ');
   SQL.Add(  parname+'.PQF2<=:QFL and ');
  // SQL.Add(' STATION.LASTLEVEL_M >=800 and ');
   SQL.Add(  parname+'.LEV_M>=100 and '+parname+'.LEV_M<=900 and ');
   SQL.Add(' STATION.INSTRUMENT_ID in (0,4,7,9,11,12) ');
   SQL.Add(' order by STATION.DATEANDTIME, STATION.ID, '+parname+'.LEV_M');
   ParamByName('SSYear1').AsInteger:=yymin;
   ParamByName('SSYear2').AsInteger:=yymax;
   ParamByName('QFL').AsInteger:=4;
  Open;
 end;


 AssignFile(f, DIVAndFPath+inttostr(yymin)+inttostr(yymax)+'.txt'); rewrite(f);

 frmdm.q.First;
 while not frmdm.q.Eof do begin
    ID   :=frmdm.q.FieldByName('ID').asInteger;
    Lat  :=frmdm.q.FieldByName('LATITUDE').asFloat;
    Lon  :=frmdm.q.FieldByName('LONGITUDE').asFloat;
    ddd  :=frmdm.q.FieldByName('DATEANDTIME').asDateTime;
    Lev  :=frmdm.q.FieldByName('LEV_M').asFloat;
   // Lev_b:=frmdm.q.FieldByName('LEV_DBAR').asFloat;
    Val  :=frmdm.q.FieldByName('VAL').asFloat;

    DecodeDateTime(ddd, yy, mn, dd, hh, mm, ss, ms);

    GEBCO := -GetBathymetry(lon, lat);

    x:= (90-Lat)*111.12*sin((Lon)*Pi/180);
    y:=-(90-Lat)*111.12*cos((Lon)*Pi/180);


    if GEBCO>=500 then
    writeln(f, inttostr(yy)+' '+
               inttostr(mn)+' '+
               inttostr(dd)+' '+
               Floattostr(Lon)+' '+
               Floattostr(Lat)+' '+
               Floattostr(Lev)+' '+
               Floattostr(Val)+' '+
               Floattostr(x)+' '+
               Floattostr(y)+' '+
               inttostr(ID));
  frmdm.q.Next;
 end;
 frmdm.q.Close;
 CloseFile(f);

    end;
end; //end of the loop for parameters


end.

