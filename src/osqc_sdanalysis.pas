unit osqc_sdanalysis;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons;

type

  { TfrmQC_SDanalysis }

  TfrmQC_SDanalysis = class(TForm)
    btnStartAnalysis: TBitBtn;
    btnSelectAll: TBitBtn;
    CheckGroup1: TCheckGroup;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnStartAnalysisClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmQC_SDanalysis: TfrmQC_SDanalysis;
  user_path :string;
  fo :text;

implementation

uses osmain, dm, osunitsconversion;

{$R *.lfm}

{ TfrmQC_SDanalysis }

procedure TfrmQC_SDanalysis.FormShow(Sender: TObject);
begin
   memo1.Clear;
   CheckGroup1.items:=frmosmain.ListBox1.Items;
   memo1.Lines.Add('number of selected cruises='+inttostr(frmdm.QCruise.RecordCount));
   memo1.Lines.Add('number of selected station='+inttostr(frmdm.Q.RecordCount));
end;



procedure TfrmQC_SDanalysis.btnSelectAllClick(Sender: TObject);
var
i: integer;
begin
  if btnSelectAll.Caption='Select all' then begin
    for i:=0 to CheckGroup1.Items.Count-1 do CheckGroup1.Checked[i]:=true;
    btnSelectAll.Caption:='Deselect all';
    Exit;
  end;
  if btnSelectAll.Caption='Deselect all' then begin
    for i:=0 to CheckGroup1.Items.Count-1 do CheckGroup1.Checked[i]:=false;
    btnSelectAll.Caption:='Select all';
    Exit;
  end;
end;



procedure TfrmQC_SDanalysis.btnStartAnalysisClick(Sender: TObject);
type
  layer=record
    bd_up :integer;
    bd_dw :integer;
    n :integer;
    s1 :double;
    s2 :double;
  end;
  SDinLayer=array of layer;

var
SDL :SDinLayer;

kt,kL :integer;
tbl_count,prf_count,index,n :integer;
L1,L2,station_id,bd,bdG,LLm,PQF1,units_id :integer;
val,val_conv,md,sd,bd_md :real;
s1,s2 :double;
tbl,fn :string;
skip,vu,isconverted :boolean;
DT1,DT2: TDateTime;
begin

  DT1:=NOW;
  memo1.Lines.Add('...start: '+datetimetostr(DT1));


  tbl_count:=0;
{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{TC}if CheckGroup1.Checked[kt] then begin
  tbl_count:=tbl_count+1;
{TC}end;
{T} end;
if tbl_count=0 then begin
   showmessage('Variable does not selected!');
   Exit;
end;


  user_path:=GlobalUnloadPath+PathDelim+'standard_deviations'+PathDelim;
  if directoryexists(user_path)=false then mkdir(user_path);

  L1:=strtoint(trim(Edit1.text));
  L2:=strtoint(trim(Edit2.text));

{L}for kL:=1 to 500 do begin
    SetLength(SDL,kL);
    SDL[kL-1].bd_up:=10*(kL-1);
    SDL[kL-1].bd_dw:=10*kL;
    SDL[kL-1].n:=0;
    SDL[kL-1].s1:=0;
    SDL[kL-1].s2:=0;
{L}end;


{T}for kt:=0 to CheckGroup1.Items.Count-1 do begin
{C}if CheckGroup1.Checked[kt] then begin

     tbl:=CheckGroup1.Items.Strings[kt]; {selected table}
     memo1.Lines.Add(tbl);

     fn:=user_path+copy(tbl,3,length(tbl))+'_'+inttostr(L1)+'-'+inttostr(L2)+'_sd.txt';
     assignfile(fo,fn);
     rewrite(fo);
     writeln(fo,'bd'+#9+'up'+#9+'down'+#9+'n'+#9+'md'+#9+'sd');

     prf_count:=0;
     frmdm.Q.First;
{Q}while not frmdm.Q.EOF do begin

    station_id:=frmdm.Q.FieldByName('id').AsInteger;

    {...select bottom depth from STATION or GEBCO if >= depth of last level in profile}
    {...= skip profiles without bd and suspitious GEBCO}
    bd:=-9999;
    if frmdm.Q.FieldByName('bottomdepth').IsNull=false
    then bd:=frmdm.Q.FieldByName('bottomdepth').AsInteger;
    bdg:=-9999;
    if frmdm.Q.FieldByName('bottomdepth_gebco').IsNull=false
    then bdG:=frmdm.Q.FieldByName('bottomdepth_gebco').AsInteger;
    LLm:=-9999;
    if frmdm.Q.FieldByName('lastlevel_m').IsNull=false
    then LLm:=frmdm.Q.FieldByName('lastlevel_m').AsInteger;
    if (bd=-9999) and (bdg<>-9999) and (LLm<>-9999) and (bdg>=LLm) then bd:=bdg;
    //showmessage(inttostr(station_id)+'  bd='+inttostr(bd)+'  bdG='+inttostr(bdG));

{BD}if bd<>-9999 then begin

    prf_count:=prf_count+1;

    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select val,PQF1,units_id from '+tbl);
      SQL.Add(' where id=:id ');
      SQL.Add(' and lev_m>=:L1 and lev_m<:L2 ');
      SQL.Add(' and PQF2>=3 ');
      ParamByName('id').AsInteger:=station_id;
      ParamByName('L1').AsInteger:=L1;
      ParamByName('L2').AsInteger:=L2;
      Open;
    end;

{L}while not frmdm.q1.EOF do begin

     val:=frmdm.q1.FieldByName('val').AsFloat;
     PQF1:=frmdm.q1.FieldByName('PQF1').AsInteger;
     units_id:=frmdm.q1.FieldByName('units_id').AsInteger;

     {...skip unchecked samples from ITP and ARGO}
      skip:=false;
      if (station_id>=10000001) and (station_id<=15000001) and (PQF1=0) then skip:=true;  //ITP
      if (station_id>=20000001) and (station_id<=30000001) and (PQF1=0) then skip:=true;  //ARGO

{SKIP}if skip=false then begin


     {...units conversion}
     vu:=false; {valid unit}
     val_conv:=-999;
     isconverted:=false;

     if tbl = 'P_TEMPERATURE' then vu:=true;
     if tbl = 'P_SALINITY' then vu:=true;

     if tbl = 'P_OXYGEN' then begin
     if units_id=3 then vu:=true
     else begin
       getdefaultunits(tbl,units_id,3,val,val_conv,isconverted);
       if isconverted=true then begin  val:=val_conv; units_id:=3; vu:=true; end;
     end;
     end;

{U}if vu=true then begin
      index:=round(bd/10);
      if bd>4995 then index:=499; //last index bd>=5000 m

      //showmessage(inttostr(bdg)+'->'+inttostr(index));
      //memo1.Lines.Add(inttostr(station_id)+#9+floattostr(bdG)+#9+inttostr(index)+#9+floattostr(val));
      //if index>490 then showmessage(inttostr(bdg)+'->'+inttostr(index));
      if bd>=4990 then
      memo1.Lines.Add(inttostr(station_id)+#9+floattostr(bd)+#9+inttostr(index)+#9+floattostr(val));

      //writeln(fo, inttostr(station_id),#9,floattostr(bd),#9,inttostr(index),#9,floattostr(val));

      SDL[index].n:=SDL[index].n+1;
      SDL[index].s1:=SDL[index].s1+val;
      SDL[index].s2:=SDL[index].s2+val*val;

{U}end;

{SKIP}end;

     frmdm.q1.Next;
{L}end;
     frmdm.q1.Close;

{BD}end;
     frmdm.Q.Next;
{Q}end;

//showmessage('#######################');

{L}for kL:=1 to 500 do begin
    {...at least 3 measurements in the layer}
{n}if SDL[kL-1].n>=strtoint(Edit3.Text) then begin

    n :=SDL[kL-1].n;
    s1:=SDL[kL-1].s1;
    s2:=SDL[kL-1].s2;

    md:=s1/n;
    sd:=(s2-s1*s1/n)/n;
    if sd<>0 then sd:=sqrt(abs(sd));

    bd_md:=(SDL[kL-1].bd_up+SDL[kL-1].bd_dw)/2;

    writeln(fo,floattostr(bd_md)
    +#9+inttostr(SDL[kL-1].bd_up)
    +#9+inttostr(SDL[kL-1].bd_dw)
    +#9+inttostr(n)
    +#9+floattostrF(md,ffFixed,9,3)
    +#9+floattostrF(sd,ffFixed,9,3));

{n}end;
{L}end;
    closefile(fo);
{C}end; {table is checked }
{T}end; {tables cycle}



   DT2:=NOW;
   memo1.Lines.Add('');
   memo1.Lines.Add('number of selected station                     ='+inttostr(frmdm.Q.RecordCount));
   memo1.Lines.Add('number of profiles with reasonable bottom depth='+inttostr(prf_count));

   memo1.Lines.Add('...stop: '+datetimetostr(DT2));
   memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));


end;

end.

