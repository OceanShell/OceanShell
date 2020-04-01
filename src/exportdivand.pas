unit exportdivand;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ExtCtrls, CheckLst, IniFiles;

type

  { Tfrmexportdivand }

  Tfrmexportdivand = class(TForm)
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

  private

  public

  end;

var
  frmexportdivand: Tfrmexportdivand;
  DIVAndFPath, GlobalPath:string;

implementation

{$R *.lfm}

uses dm, main;

{ Tfrmexportdivand }


procedure Tfrmexportdivand.btnExportClick(Sender: TObject);
Var
 f: text;
 ID, ff, k, yymin, yymax, dec: integer;
 Lat, Lon, lev, Val, dval, TVal, SVal: real;
 yy, mn, dd, hh, mm, ss, ms:word;
 parname, fname, instr, mn_str, dd_str, hh_str, mm_str, id_str:string;
 d:string;
 x, y, LatMax, LonMax, LatMin, LonMin: real;
 ddd, ttt:TDateTime;
begin

   parname:='P_SALINITY';

    for dec:=5 to 5 do begin
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
    end;

 with frmdm.q do begin
  Close;
   SQL.Clear;
   SQL.Add(' Select Station.Absnum, stlat, stlon, stdate, sttime, level_, value_');
   SQL.Add(' from STATION, STATION_INFO, '+parname);
   SQL.Add(' where ');
   SQL.Add(' Station.Absnum=Station_info.absnum and ');
   SQL.Add(' Station.Absnum='+parname+'.absnum and ');
   SQL.Add(' StLat >= 75 and ');
  // SQL.Add(' StLon between :SSLonMin and :SSLonMax and ');
   SQL.Add(' Extract(Year from StDate)>=:SSYear1 and ');
   SQL.Add(' Extract(Year from StDate)<=:SSYear2 and ');
   SQL.Add(' flag_<=8192 and ');
   SQL.Add(' INSTRUMENT in (0,4,7,9,10,11,12) ');
   SQL.Add(' order by stdate, stlat, stlon, level_ ');
   ParamByName('SSYear1').AsInteger:=yymin;
   ParamByName('SSYear2').AsInteger:=yymax;
  Open;
 end;


 AssignFile(f, inttostr(yymin)+inttostr(yymax)+'.txt'); rewrite(f);

 frmdm.q.First;
 while not frmdm.q.Eof do begin
    ID :=frmdm.q.FieldByName('Absnum').asInteger;
    Lat:=frmdm.q.FieldByName('StLat').asFloat;
    Lon:=frmdm.q.FieldByName('StLon').asFloat;
    Lev:=frmdm.q.FieldByName('level_').asFloat;
    Val:=frmdm.q.FieldByName('value_').asFloat;
    ddd:=frmdm.q.FieldByName('StDate').asDateTime;
    ttt:=frmdm.q.FieldByName('Sttime').asDateTime;

    DecodeDate(ddd, yy, mn, dd);
    DecodeTime(ttt, hh, mm, ss, ms);

    if mn<10 then mn_str:='0'+inttostr(mn) else mn_str:=inttostr(mn);
    if dd<10 then dd_str:='0'+inttostr(dd) else dd_str:=inttostr(dd);
    if hh<10 then hh_str:='0'+inttostr(hh) else hh_str:=inttostr(hh);
    if mm<10 then mm_str:='0'+inttostr(mm) else mm_str:=inttostr(mm);

    d:='';
    d:=inttostr(yy)+'-'+mn_str+'-'+dd_str+'T'+hh_str+':'+mm_str;

    id_str:=inttostr(id)+'_'+floattostr(lev);

    //value,lon,lat,depth,time,obsid = loadbigfile(filename)
    writeln(f, Floattostr(Val)+' '+
               Floattostr(Lon)+' '+
               Floattostr(Lat)+' '+
               Floattostr(Lev)+' '+
               d+' '+
               id_str);
//               inttostr(id)+'_'+Floattostr(lev));
  frmdm.q.Next;
 end;
 frmdm.q.Close;
 CloseFile(f);
end; //end of the loop for parameters


end.

