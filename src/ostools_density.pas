unit ostools_density;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
  ExtCtrls, GibbsSeaWater, dynlibs;

{dynlibs}

type

  { Tfrmcompute_density }

  Tfrmcompute_density = class(TForm)
    btnStart: TBitBtn;
    btnTest: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure btnTestClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ComputeDensity;
    procedure PopulateDensityTable;
    procedure ComputePotentialDensity(atm_pref_dbar,lat,lon,lev_dbar,temp,salt:real;  var pot_dens:double);
  public

  end;

var
  frmcompute_density: Tfrmcompute_density;
  user_path,fn: string;
  fo,fi: text;

implementation

uses osmain, dm;
{procedures}

{$R *.lfm}

{ Tfrmcompute_density }

procedure Tfrmcompute_density.FormShow(Sender: TObject);
begin
    memo1.clear;
end;



procedure Tfrmcompute_density.btnStartClick(Sender: TObject);
var
DT1,DT2: TDateTime;
begin
  DT1:=NOW;
  memo1.Lines.Add('...start: '+datetimetostr(DT1));

  if CheckBox1.Checked then PopulateDensityTable;
  if CheckBox2.Checked then ComputeDensity;
  if (CheckBox1.Checked) and (CheckBox2.Checked) then begin
   ComputeDensity;
   PopulateDensityTable;
  end;

  DT2:=NOW;
  memo1.Lines.Add('');
  memo1.Lines.Add('...stop: '+datetimetostr(DT2));
  memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;



procedure Tfrmcompute_density.btnTestClick(Sender: TObject);
var
pref_dbar,lat,lon,lev_dbar,temp,salt :real;
pot_dens :double;
begin

  pref_dbar:=strtofloat(Edit5.Text);
  lat:=strtofloat(Edit6.Text);
  lon:=strtofloat(Edit7.Text);
  lev_dbar:=strtofloat(Edit1.Text);
  temp:=strtofloat(Edit2.Text);
  salt:=strtofloat(Edit3.Text);
  ComputePotentialDensity(pref_dbar,lat,lon,lev_dbar,temp,salt,pot_dens);

  memo1.Lines.Add('');
  memo1.Lines.Add('ref pressure: '+floattostr(pref_dbar));
  memo1.Lines.Add('latitude    : '+floattostr(lat));
  memo1.Lines.Add('longitude   : '+floattostr(lon));
  memo1.Lines.Add('level       : '+floattostr(lev_dbar));
  memo1.Lines.Add('temp        : '+floattostr(temp));
  memo1.Lines.Add('salt        : '+floattostr(salt));
  memo1.Lines.Add('pot density : '+floattostr(pot_dens));
end;



procedure Tfrmcompute_density.ComputeDensity;
var
station_id: int64;
mik: integer;
PQF1,PQF1t,PQF1s,PQF2,PQF2t,PQF2s,SQF,SQFt,SQFs,btln,prfn,units_id,inst,prf_best :integer;
lat,lon,lev_dbar,lev_m,salt,temp,p_ref,pot_dens :real;
str :string;
prfb :boolean;
begin

   user_path:=GlobalUnloadPath+PathDelim+'density'+PathDelim;
   if directoryexists(user_path)=false then mkdir(user_path);
   fn:=user_path+'density.txt';
   memo1.Lines.Add(fn);
   assignfile(fo,fn);
   rewrite(fo);

   str:='Stations in P_Salinity with PQF2>=3: ';
   with frmdm.q1 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select count(distinct(id)) from P_SALINITY ');
    SQL.Add(' where PQF2>=3 ');
    Open;
    label1.Caption:=str+inttostr(FieldByName('count').AsInteger);
    Close;
    end;
    Label1.Visible:=true;

   with frmdm.q1 do begin
    Close;
    SQL.Clear;
    SQL.Add(' select distinct(id) as station_id from P_SALINITY ');
    SQL.Add(' where PQF2>=3 ');
    Open;
   end;

    units_id:=29; //kg/m3

     frmdm.q1.DisableControls;
     mik:=0;
     label3.Caption:=inttostr(mik);
     Label2.Visible:=true;
     Label3.Visible:=true;
     Application.ProcessMessages;
{St}while not frmdm.q1.EOF do begin
     station_id:=frmdm.q1.FieldByName('station_id').AsInteger;
     inc(mik);
     if mik mod 10000=0 then begin
      label3.Caption:=inttostr(mik);
      Application.ProcessMessages;
     end;

     with frmdm.q3 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select latitude, longitude from STATION ');
      SQL.Add(' where id=:station_id ');
      ParamByName('station_id').AsInteger:=station_id;
      Open;
      lat:=frmdm.q3.FieldByName('latitude').AsFloat;
      lon:=frmdm.q3.FieldByName('longitude').AsFloat;
      Close;
     end;

     {with frmdm.q2 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select * from p_salinity,p_temperature ');
      SQL.Add(' where p_salinity.id=:station_id ');
      SQL.Add(' and p_salinity.id=p_temperature.id  ');
      SQL.Add(' and p_salinity.instrument_id=p_temperature.instrument_id ');
      SQL.Add(' and p_salinity.profile_number=p_temperature.profile_number ');
      SQL.Add(' and p_salinity.lev_dbar=p_temperature.lev_dbar ');
      SQL.Add(' and p_salinity.pqf2>=3 and p_temperature.pqf2>=3 ');
      SQL.Add(' order by p_salinity.instrument_id,p_salinity.profile_number,p_salinity.lev_dbar ');
      ParamByName('station_id').AsInteger:=station_id;
      Open;
     end;}

     temp:=-9999;
     salt:=-9999;
     pot_dens:=-9999;

     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' SELECT ');
       SQL.Add(' P_TEMPERATURE.VAL as TVAL, P_SALINITY.VAL as SVAL, ');
       SQL.Add(' P_TEMPERATURE.LEV_DBAR as LEV_DBAR, ');
       SQL.Add(' P_TEMPERATURE.LEV_M as LEV_M, ');
       SQL.Add(' P_TEMPERATURE.PQF1 as TPQF1, ');
       SQL.Add(' P_TEMPERATURE.PQF2 as TPQF2, ');
       SQL.Add(' P_TEMPERATURE.SQF as TSQF, ');
       SQL.Add(' P_SALINITY.PQF1 as SPQF1, ');
       SQL.Add(' P_SALINITY.PQF2 as SPQF2, ');
       SQL.Add(' P_SALINITY.SQF as SSQF, ');
       SQL.Add(' P_SALINITY.BOTTLE_NUMBER as btln, ');
       SQL.Add(' P_TEMPERATURE.INSTRUMENT_ID as inst, ');
       SQL.Add(' P_TEMPERATURE.PROFILE_NUMBER as prfn, ');
       SQL.Add(' P_TEMPERATURE.PROFILE_BEST as prfb ');
       SQL.Add(' FROM P_TEMPERATURE, P_SALINITY ');
       SQL.Add(' WHERE ');
       SQL.Add(' P_SALINITY.ID=P_TEMPERATURE.ID AND ');
       SQL.Add(' P_SALINITY.LEV_DBAR=P_TEMPERATURE.LEV_DBAR AND ');
       SQL.Add(' P_SALINITY.INSTRUMENT_ID=P_TEMPERATURE.INSTRUMENT_ID AND ');
       SQL.Add(' P_SALINITY.PROFILE_NUMBER=P_TEMPERATURE.PROFILE_NUMBER AND ');
       SQL.Add(' P_TEMPERATURE.PQF2>=3  AND ');
       SQL.Add(' P_SALINITY.PQF2>3 AND ');
       SQL.Add(' P_SALINITY.ID=:ID ');
       SQL.Add(' order by p_salinity.instrument_id,p_salinity.profile_number,p_salinity.lev_dbar ');
       ParamByName('ID').AsInteger:=station_id;
      Open;
   end;

     //writeln(fo,inttostr(station_id)+#9+floattostr(lat));
     //writeln(fo,'st_id'+#9+'[dbar]'+#9+'[m]'+#9+'temp'+#9+'salt'+#9+'dens'+#9+
     //       'PQF1'+#9+'PQF2'+#9+'SQF'+#9+'btln#'+#9+'prfn#'+#9+'prfb'+#9+'unit'+#9+'inst');
{Lev}while not frmdm.q2.EOF do begin
       lev_dbar:=frmdm.q2.FieldByName('lev_dbar').AsFloat;
       lev_m:=frmdm.q2.FieldByName('lev_m').AsFloat;
       salt:=frmdm.q2.FieldByName('Sval').AsFloat;
       temp:=frmdm.q2.FieldByName('Tval').AsFloat;
       PQF1t:=frmdm.q2.FieldByName('TPQF1').AsInteger;
       PQF1s:=frmdm.q2.FieldByName('SPQF1').AsInteger;
       PQF2t:=frmdm.q2.FieldByName('TPQF2').AsInteger;
       PQF2s:=frmdm.q2.FieldByName('SPQF2').AsInteger;
       SQFt:=frmdm.q2.FieldByName('TSQF').AsInteger;
       SQFs:=frmdm.q2.FieldByName('SSQF').AsInteger;
       btln:=frmdm.q2.FieldByName('btln').AsInteger;
       prfn:=frmdm.q2.FieldByName('prfn').AsInteger;
       prfb:=frmdm.q2.FieldByName('prfb').AsBoolean;
       inst:=frmdm.q2.FieldByName('inst').AsInteger;

       PQF1:=PQF1t;
       if PQF1<PQF1s then PQF1:=PQF1s;
       PQF2:=PQF2t;
       if PQF2<PQF2s then PQF2:=PQF2s;
       SQF:=SQFt;
       if SQF<SQFs then SQF:=SQFs;

       {density computing}
       p_ref:=10.1325; //atmosheric pressure, dbar
       if (temp<>-9999) and (salt<>-9999) then
       ComputePotentialDensity(p_ref,lat,lon,lev_dbar,temp,salt,pot_dens);

       if prfb=true then prf_best:=1 else prf_best:=0;

       if (CheckBox2.Checked) and (pot_dens<>-9999) then
       writeln(fo,inttostr(station_id)
       +#9+floattostr(lev_dbar)
       +#9+floattostr(lev_m)
       +#9+floattostrF(temp,ffFixed,10,3)
       +#9+floattostrF(salt,ffFixed,10,3)
       +#9+floattostrF(pot_dens,ffFixed,10,5)
       +#9+inttostr(PQF1)
       +#9+inttostr(PQF2)
       +#9+inttostr(SQF)
       +#9+inttostr(btln)
       +#9+inttostr(prfn)
       +#9+inttostr(prf_best)
       +#9+inttostr(units_id)
       +#9+inttostr(inst));

       frmdm.q2.Next;
{Lev}end;
       frmdm.q2.Close;
       if CheckBox1.Checked then frmdm.TR.CommitRetaining;

     frmdm.q1.Next;
{St}end;
     label3.Caption:=inttostr(mik);
     Application.ProcessMessages;
     frmdm.q1.EnableControls;
     frmdm.q1.Close;
     closefile(fo);
end;



procedure Tfrmcompute_density.ComputePotentialDensity(atm_pref_dbar,lat,lon,lev_dbar,temp,salt:real;  var pot_dens:double);
var
p :real;
sa,pt :double;
gsw_sa_from_sp:Tgsw_sa_from_sp;
gsw_rho_t_exact:Tgsw_rho_t_exact;
gsw_pt_from_t:Tgsw_pt_from_t;
begin

gsw_sa_from_sp:=Tgsw_z_from_p(GetProcedureAddress(libgswteos, 'gsw_sa_from_sp'));
sa  := gsw_sa_from_sp(salt, atm_pref_dbar, lon, lat); // absolute salinity
p:=atm_pref_dbar+lev_dbar; //absolute pressure=atmospheric pressure+hydrostatic pressure
gsw_pt_from_t:=Tgsw_pt_from_t(GetProcedureAddress(libgswteos, 'gsw_pt_from_t'));
pt:=gsw_pt_from_t(SA, temp, p, atm_pref_dbar);  //potential temperature
gsw_rho_t_exact:=Tgsw_rho_t_exact(GetProcedureAddress(libgswteos, 'gsw_rho_t_exact'));
pot_dens:=gsw_rho_t_exact(sa, pt, p); //potential density
//pot_dens:=pot_dens/1000;
pot_dens:=pot_dens-1000;

end;



procedure Tfrmcompute_density.PopulateDensityTable;
var
i: integer;
tbl_exist :boolean;
station_id :int64;
PQF1,PQF2,SQF,btln,prfn,prf_best,units_id,inst :integer;
lev_dbar,lev_m,temp,salt,pot_dens :real;
prfb :boolean;
begin
   {...density.txt}
   user_path:=GlobalUnloadPath+PathDelim+'density'+PathDelim;
   fn:=user_path+'density.txt';
   if fileexists(fn)=false then begin
     showmessage('density.txt is not found');
     Exit;
   end;
   memo1.Lines.Add(fn);
   assignfile(fi,fn);
   reset(fi);

   {...P_Density table}
    tbl_exist:=false;
   for i:=0 to frmosmain.ListBox1.Items.Count-1 do begin
    if frmosmain.ListBox1.Items.Strings[i]='P_DENSITY' then tbl_exist:=true;
   end;

   if tbl_exist=false then begin
     showmessage('Table P_DENSITY does not exist in the database.  Create in IBExpert.');
     Exit;
   end;

     with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' delete from P_DENSITY ');
      ExecSQL;
     end;
      frmdm.TR.Commit;

      {...populate density table from file}
{fi}while not EOF(fi) do begin
     readln(fi,station_id,lev_dbar,lev_m,temp,salt,pot_dens,PQF1,PQF2,SQF,btln,
               prfn,prf_best,units_id,inst);
     //memo1.Lines.Add(inttostr(station_id)+#9+floattostr(lev_dbar));
     prfb:=true;
     if prf_best=0 then prfb:=false;

     with frmdm.q3 do begin
       Close;
        SQL.Clear;
        SQL.Add(' insert into ');
        SQL.Add(' P_DENSITY ');
        SQL.Add(' (ID, LEV_DBAR, LEV_M, VAL, PQF1, PQF2, SQF, BOTTLE_NUMBER, UNITS_ID, ');
        SQL.Add('  INSTRUMENT_ID, PROFILE_NUMBER, PROFILE_BEST) ');
        SQL.Add(' values ');
        SQL.Add(' (:ID, :LEV_DBAR, :LEV_M, :VAL, :PQF1, :PQF2, :SQF, :BOTTLE_NUMBER, :UNITS_ID, ');
        SQL.Add('  :INSTRUMENT_ID, :PROFILE_NUMBER, :PROFILE_BEST) ');
        ParamByName('ID').AsInteger:=station_id;
        ParamByName('LEV_DBAR').AsFloat:=lev_dbar;
        ParamByName('LEV_M').AsFloat:=lev_m;
        ParamByName('VAL').AsFloat:=pot_dens;
        ParamByName('PQF1').AsInteger:=PQF1;
        ParamByName('PQF2').AsInteger:=PQF2;
        ParamByName('SQF').AsInteger:=SQF;
        ParamByName('BOTTLE_NUMBER').AsInteger:=btln;
        ParamByName('UNITS_ID').AsInteger:=units_id;
        ParamByName('INSTRUMENT_ID').AsInteger:=inst;
        ParamByName('PROFILE_NUMBER').AsInteger:=prfn;
        ParamByName('PROFILE_BEST').AsBoolean:=prfb;
       ExecSQL;
      end;

{fi}end;
     closefile(fi);
     frmdm.TR.Commit;
end;

end.

