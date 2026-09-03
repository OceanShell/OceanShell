unit osexport_divand;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, DateUtils;

type
  TDIVA=record
    dat:string;
    lon:real;
    lat:real;
    lev:real;
    val:double;
    id:string;
end;
TDIVA_ARR = array of TDIVA;


  { Tfrmosexport_divand }

  Tfrmosexport_divand = class(TForm)
    btnExport: TButton;
    btnOpenFolder: TBitBtn;
    cbParameter: TComboBox;
    GroupBox1: TGroupBox;
    mLog: TMemo;

    procedure btnExportClick(Sender: TObject);
    procedure btnOpenFolderClick(Sender: TObject);
    procedure cbParameterSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private

  public

  end;

var
  frmosexport_divand: Tfrmosexport_divand;
  export_divand_path:string;
  DIVAnd_arr:array of TDIVA;


implementation

{$R *.lfm}

uses dm, osmain, driver__selector, osbathymetry, gibbsseawater, procedures;

{ Tfrmosexport_divand }


procedure Tfrmosexport_divand.FormCreate(Sender: TObject);
begin
  // output directory
  export_divand_path:=GlobalUnloadPath+'DIVAnd'+PathDelim;
    if not DirectoryExists(export_divand_path) then CreateDir(export_divand_path);

    cbParameter.Items:=frmosmain.cgParameters.Items;
end;


procedure Tfrmosexport_divand.btnExportClick(Sender: TObject);
Var
 f_out: text;
 f_out_name: string;

 ID, ID_old: Int64;
 ff, k, yymin, yymax, dec, GEBCO: integer;
 Lat, Lon, lev_m, lev_b, Val, dval, TVal, SVal, lev: real;
 yy, mn, dd, hh, mm, ss, ms:word;
 parname, fname, instr, mn_str, dd_str, hh_str, mm_str, id_str:string;

 d:string;
 x, y, LatMax, LonMax, LatMin, LonMin: real;
 ddd, ttt:TDateTime;

 prof_arr:TPROF_ARR;
 diva_arr:TDIVA_ARR;
 diva_length: integer;

 PQF1_str, PQF2_str, SQF_str:string;
 date_st: string;
begin

   GetQCFlags(PQF1_str, PQF2_str, SQF_str); //QC flags from settings

   try
      ID_old:=frmdm.Q.FieldByName('ID').Value;
      frmdm.Q.DisableControls;
      frmdm.QCruise.DisableControls;
      frmdm.Q.First;
      diva_length:=0;
       While not frmdm.Q.Eof do begin
         ID:=frmdm.Q.FieldByName('ID').value;
         Lat:=frmdm.Q.FieldByName('latitude').value;
         Lon:=frmdm.Q.FieldByName('longitude').value;
         ddd:=frmdm.Q.FieldByName('dateandtime').value;

         date_st:=FormatDateTime('YYYY-MM-DD', ddd)+'T'+FormatDateTime('hh:nn:ss', ddd);
       //  showmessage(date_st);

        // DecodeDateTime(ddd, yy, mn, dd, hh, mm, ss, ms);


         GetProfile(ID, cbParameter.Text, 1, PQF1_str, PQF2_str, SQF_str, prof_arr);

         for k:=low(prof_arr) to high(prof_arr) do begin
           inc(diva_length);
           SetLength(diva_arr, diva_length);
             diva_arr[diva_length-1].dat:=date_st;
             diva_arr[diva_length-1].lon:=lon;
             diva_arr[diva_length-1].lat:=lat;
             diva_arr[diva_length-1].lev:=prof_arr[k].lev_m;
             diva_arr[diva_length-1].val:=prof_arr[k].val;
             diva_arr[diva_length-1].id:=inttostr(id)+'_'+floattostr(prof_arr[k].lev_m);
         end;

         frmdm.Q.Next;
       end;

     finally
      frmdm.Q.Locate('ID', ID_old, []);
      frmdm.QCruise.EnableControls;
      frmdm.Q.EnableControls;
     end;


     AssignFile(f_out, export_divand_path+cbParameter.Text+'.bigfile'); rewrite(f_out);
     for k:=low(diva_arr) to high(diva_arr) do
        writeln(f_out,
          floattostr(diva_arr[k].Val)+' '+
          floattostr(diva_arr[k].Lon)+' '+
          floattostr(diva_arr[k].Lat)+' '+
          floattostr(diva_arr[k].Lev)+' '+
          diva_arr[k].dat+' '+
          diva_arr[k].id);
     Closefile(f_out);
end;

procedure Tfrmosexport_divand.btnOpenFolderClick(Sender: TObject);
begin
  OpenDocument(PChar(export_divand_path));
end;

procedure Tfrmosexport_divand.cbParameterSelect(Sender: TObject);
begin
  btnExport.Enabled:=true;
end;


end.

