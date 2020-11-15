unit osqc_wideranges;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  Grids, StdCtrls;

type

  { TfrmQC_WideRanges }

  TfrmQC_WideRanges = class(TForm)
    btnSetFlags: TBitBtn;
    btnSelectAll: TBitBtn;
    CheckBox1: TCheckBox;
    CheckGroup1: TCheckGroup;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    RadioGroup1: TRadioGroup;
    StringGrid1: TStringGrid;
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnSetFlagsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmQC_WideRanges: TfrmQC_WideRanges;

implementation

uses osmain,dm,osunitsconversion;

{$R *.lfm}

{ TfrmQC_WideRanges }



procedure TfrmQC_WideRanges.FormShow(Sender: TObject);
var
ktbl :integer;
tbl,var_name :string;
begin

  memo1.Clear;

  CheckGroup1.items:=frmosmain.ListBox1.Items;

  StringGrid1.ColCount:=6;
  StringGrid1.RowCount:=CheckGroup1.Items.Count+1;
  StringGrid1.ColWidths[0]:=200;
  StringGrid1.ColWidths[1]:=50;
  StringGrid1.ColWidths[2]:=50;
  StringGrid1.ColWidths[3]:=50;
  StringGrid1.ColWidths[4]:=100;
  StringGrid1.ColWidths[5]:=200;
  StringGrid1.Cells[0,0]:='variable';
  StringGrid1.Cells[1,0]:='min';
  StringGrid1.Cells[2,0]:='max';
  StringGrid1.Cells[3,0]:='unit_default';
  StringGrid1.Cells[4,0]:='unit_short';
  StringGrid1.Cells[5,0]:='unit_long';

{T}for ktbl:=0 to CheckGroup1.Items.Count-1 do begin
    tbl:=CheckGroup1.Items.Strings[ktbl];
    var_name:=copy(tbl,3,length(tbl));
    StringGrid1.Cells[0,ktbl+1]:=var_name;

    {capacity of water to resist acidification}
    if tbl='P_ALKALINITY' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0); //WOD18 table 11.9: min=0 max=3.1 [milli-mol]->[micro-mol]  3.1x1000=3100
      StringGrid1.Cells[2,ktbl+1]:=floattostr(3239);//from literature: 3.32 [meq/L] (The Azov Sea) -> 3.32x1000/1.025=3239
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mol per kilogram';
    end;
    if tbl='P_AMMONIUM' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0); //from NABOS measurements in ARCTIC
      StringGrid1.Cells[2,ktbl+1]:=floattostr(22.1);//did not find anything useful in literature
      StringGrid1.Cells[3,ktbl+1]:='14';
      StringGrid1.Cells[4,ktbl+1]:='μg/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-gram per kilogram';
    end;
    if tbl='P_AOU' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-346); //from GLODAP(source)
      StringGrid1.Cells[2,ktbl+1]:=floattostr(328);//from WOA18 (vol.3 figures)  0->300 μmol/kg
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mole per kilogram';
    end;
    if tbl='P_ARGON' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(9); //from WOD18(source)
      StringGrid1.Cells[2,ktbl+1]:=floattostr(18);//I have not found the natural range in the ocean in the literature
      StringGrid1.Cells[3,ktbl+1]:='12';
      StringGrid1.Cells[4,ktbl+1]:='nmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='nano-mole per kilogram';
    end;
    if tbl='P_BARIUM' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0); //from NABOS(source) reported units can be wrong !!!
      StringGrid1.Cells[2,ktbl+1]:=floattostr(1);// 7->3   Milli-mole per liter->Micro-mole per kilogram
      StringGrid1.Cells[3,ktbl+1]:='3';          // 14->3  Micro-gram per kilogram->Micro-mole per kilogram
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mole per kilogram';
    end;
    if tbl='P_SALINITY' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(40);
      StringGrid1.Cells[3,ktbl+1]:='2';
      StringGrid1.Cells[4,ktbl+1]:='psu';
      StringGrid1.Cells[5,ktbl+1]:='dimensionless or unit less';
    end;
    if tbl='P_TEMPERATURE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-3);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(40);
      StringGrid1.Cells[3,ktbl+1]:='1';
      StringGrid1.Cells[4,ktbl+1]:='°C';
      StringGrid1.Cells[5,ktbl+1]:='Degree centigrade';
    end;
    if tbl='P_OXYGEN' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(523);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mol per kilogram';
    end;
    if tbl='P_PHOSPHATE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(60);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mol per kilogram';
    end;
    if tbl='P_SILICATE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(360);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mol per kilogram';
    end;
    if tbl='P_NITRATE' then begin //from GLODAP PQF=6,7
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.9);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(500);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mol per kilogram';
    end;
    if tbl='P_NITRITE' then begin //from GLODAP PQF=6
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.2);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(12);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mol per kilogram';
    end;
    if tbl='P_NITRATENITRITE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(500);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mol per kilogram';
    end;
    if tbl='P_PHOSPHATE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.3);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(60);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mol per kilogram';
    end;
    if tbl='P_SILICATE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-2.5);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(360);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mol per kilogram';
    end;
    if tbl='P_PH' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(6.30);
      StringGrid1.Cells[2,ktbl+1]:=floattostr(9.20);
      StringGrid1.Cells[3,ktbl+1]:='2';
      StringGrid1.Cells[4,ktbl+1]:='';
      StringGrid1.Cells[5,ktbl+1]:='dimensionless or unit less';
    end;
    if tbl='P_CHLOROPHYLL' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.1); //GLODAP + WOD
      StringGrid1.Cells[2,ktbl+1]:=floattostr(60);
      StringGrid1.Cells[3,ktbl+1]:='14';
      StringGrid1.Cells[4,ktbl+1]:='μg/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-gram per kilogram';
    end;
    {stable isotope carbon 13}
    if tbl='P_C13' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-27); //GLODAP + WOD
      StringGrid1.Cells[2,ktbl+1]:=floattostr(4.3);
      StringGrid1.Cells[3,ktbl+1]:='11';
      StringGrid1.Cells[4,ktbl+1]:='‰';
      StringGrid1.Cells[5,ktbl+1]:='per-mille deviation';
    end;
    {stable isotope carbon 14}
    if tbl='P_C14' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-300); //GLODAP + WOD
      StringGrid1.Cells[2,ktbl+1]:=floattostr(480);
      StringGrid1.Cells[3,ktbl+1]:='11';
      StringGrid1.Cells[4,ktbl+1]:='‰';
      StringGrid1.Cells[5,ktbl+1]:='per-mille deviation';
    end;
    {Carbone tetrachloride CCL4}
    if tbl='P_CCL4' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.3); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(17.5);
      StringGrid1.Cells[3,ktbl+1]:='13';
      StringGrid1.Cells[4,ktbl+1]:='pmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='pico-mole per kilogram';
    end;
    {partial pressure of carbone tetrachloride (CCL4)}
    if tbl='P_PCCL4' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-11); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(700);
      StringGrid1.Cells[3,ktbl+1]:='18';
      StringGrid1.Cells[4,ktbl+1]:='ppt';
      StringGrid1.Cells[5,ktbl+1]:='parts per trillion';
    end;
    {Colored dissolved organic matter (CDOM)}
    if tbl='P_CDOM' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0); //ITP after flagging some outliers
      StringGrid1.Cells[2,ktbl+1]:=floattostr(110);
      StringGrid1.Cells[3,ktbl+1]:='24';
      StringGrid1.Cells[4,ktbl+1]:='ppb';
      StringGrid1.Cells[5,ktbl+1]:='parts per billion';
    end;
    {Halogenated transient tracer chlorofluorocarbon 11 (CFC11)}
    if tbl='P_CFC11' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.2); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(10);
      StringGrid1.Cells[3,ktbl+1]:='13';
      StringGrid1.Cells[4,ktbl+1]:='pmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='Pico-mole per kilogram';
    end;
    {partial pressure of halogenated transient tracer chlorofluorocarbon 11 (CFC11)}
    if tbl='P_PCFC11' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-5); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(465);
      StringGrid1.Cells[3,ktbl+1]:='18';
      StringGrid1.Cells[4,ktbl+1]:='ppt';
      StringGrid1.Cells[5,ktbl+1]:='parts per trillion';
    end;
    {Halogenated transient tracer chlorofluorocarbon 113 (CFC113)}
    if tbl='P_CFC113' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.2); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(2.7);
      StringGrid1.Cells[3,ktbl+1]:='13';
      StringGrid1.Cells[4,ktbl+1]:='pmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='Pico-mole per kilogram';
    end;
    {partial pressure of halogenated transient tracer chlorofluorocarbon 113 (CFC113)}
    if tbl='P_PCFC113' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-22); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(250);
      StringGrid1.Cells[3,ktbl+1]:='18';
      StringGrid1.Cells[4,ktbl+1]:='ppt';
      StringGrid1.Cells[5,ktbl+1]:='parts per trillion';
    end;
    {Halogenated transient tracer chlorofluorocarbon 113 (CFC113)}
    if tbl='P_CFC12' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.1); //GLODAP + WOD
      StringGrid1.Cells[2,ktbl+1]:=floattostr(9);
      StringGrid1.Cells[3,ktbl+1]:='13';
      StringGrid1.Cells[4,ktbl+1]:='pmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='Pico-mole per kilogram';
    end;
    {partial pressure of halogenated transient tracer chlorofluorocarbon 113 (CFC113)}
    if tbl='P_PCFC12' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-11); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(1602);
      StringGrid1.Cells[3,ktbl+1]:='18';
      StringGrid1.Cells[4,ktbl+1]:='ppt';
      StringGrid1.Cells[5,ktbl+1]:='parts per trillion';
    end;
    {Dissolved inorganic carbon (DIC)}   //WOD18 + NABOS
    if tbl='P_DIC' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0); //GLODAP + WOD->0
      StringGrid1.Cells[2,ktbl+1]:=floattostr(2700);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mole per kilogram';
    end;
    {...DIC=TCO2 ???}
    {Total dissolved inorganic carbon (TCO2)} //GLODAP + OCADS
    if tbl='P_TCO2' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(140); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(2700);
      StringGrid1.Cells[3,ktbl+1]:='3';
      StringGrid1.Cells[4,ktbl+1]:='μmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-mole per kilogram';
    end;
    {Total organic carbon (TOC)}
    if tbl='P_TOC' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(28); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(506);
      StringGrid1.Cells[3,ktbl+1]:='15';
      StringGrid1.Cells[4,ktbl+1]:='μmol/L';
      StringGrid1.Cells[5,ktbl+1]:='micro-mole per liter';
    end;
    {Dissolved inorganic nitrogen (DIN)}
    if tbl='P_DIN' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0); //NABOS
      StringGrid1.Cells[2,ktbl+1]:=floattostr(36);
      StringGrid1.Cells[3,ktbl+1]:='14';
      StringGrid1.Cells[4,ktbl+1]:='μg/kg';
      StringGrid1.Cells[5,ktbl+1]:='micro-gram per kilogram';
    end;
    {Total Dissolved  nitrogen (TDN)}  //DIN+DON
    if tbl='P_TDN' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(1); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(53);
      StringGrid1.Cells[3,ktbl+1]:='15';
      StringGrid1.Cells[4,ktbl+1]:='μmol/L';
      StringGrid1.Cells[5,ktbl+1]:='micro-mole per liter';
    end;
    {Dissolved organic carbon (DOC)}
    if tbl='P_DOC' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(23); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(425);
      StringGrid1.Cells[3,ktbl+1]:='15';
      StringGrid1.Cells[4,ktbl+1]:='μmol/L';
      StringGrid1.Cells[5,ktbl+1]:='micro-mole per liter';
    end;
    {Dissolved organic carbon (DOC)}
    if tbl='P_DON' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(1); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(606);
      StringGrid1.Cells[3,ktbl+1]:='15';
      StringGrid1.Cells[4,ktbl+1]:='μmol/L';
      StringGrid1.Cells[5,ktbl+1]:='micro-mole per liter';
    end;
    {Fluorescence  9->22 no convertion formula}
    if tbl='P_FLUORESCENCE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.1); //NABOS
      StringGrid1.Cells[2,ktbl+1]:=floattostr(348);
      StringGrid1.Cells[3,ktbl+1]:='9';
      StringGrid1.Cells[4,ktbl+1]:='μg/m3';
      StringGrid1.Cells[5,ktbl+1]:='Micro-gram per cubic meter';
    end;
    {Radioisotop hydrogen 3 (tritium) H3}
    if tbl='P_H3' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.2); //GLODAP + WOD
      StringGrid1.Cells[2,ktbl+1]:=floattostr(300);
      StringGrid1.Cells[3,ktbl+1]:='8';
      StringGrid1.Cells[4,ktbl+1]:='TU';
      StringGrid1.Cells[5,ktbl+1]:='Tritium Unit';
    end;
    {Helium, counting error HE}
    if tbl='P_HE' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-2); //GLODAP + WOD
      StringGrid1.Cells[2,ktbl+1]:=floattostr(48);
      StringGrid1.Cells[3,ktbl+1]:='12';
      StringGrid1.Cells[4,ktbl+1]:='nmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='nano-mole per kilogram';
    end;
    {Radioisotop helium 3 HE3}
    if tbl='P_HE3' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-16); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(51);
      StringGrid1.Cells[3,ktbl+1]:='10';
      StringGrid1.Cells[4,ktbl+1]:='%';
      StringGrid1.Cells[5,ktbl+1]:='Percent ';
    end;
    {Neon}
    if tbl='P_NEON' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0); //GLODAP + WOD18
      StringGrid1.Cells[2,ktbl+1]:=floattostr(24);
      StringGrid1.Cells[3,ktbl+1]:='12';
      StringGrid1.Cells[4,ktbl+1]:='nmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='nano-mole per kilogram';
    end;
    {O18}
    if tbl='P_O18' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-27); //GLODAP + WOD18 + NERSC
      StringGrid1.Cells[2,ktbl+1]:=floattostr(13);
      StringGrid1.Cells[3,ktbl+1]:='11';
      StringGrid1.Cells[4,ktbl+1]:='‰';
      StringGrid1.Cells[5,ktbl+1]:='Per-mille deviation';
    end;
    {Photosynthetically active radiation PAR}
    {the number of photons in the 400-700 nm range received by a surface for a specified amount of time}
    if tbl='P_PAR' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-25); //ITP PQF2=4
      StringGrid1.Cells[2,ktbl+1]:=floattostr(41);
      StringGrid1.Cells[3,ktbl+1]:='23';
      StringGrid1.Cells[4,ktbl+1]:='µmol/m2 s1';
      StringGrid1.Cells[5,ktbl+1]:='micro-mole per sec and square m';
    end;
    {Total inorganic carbon (partial pressure) PCO2}
    if tbl='P_PCO2' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(90); //WOD18 NABOS
      StringGrid1.Cells[2,ktbl+1]:=floattostr(2700);
      StringGrid1.Cells[3,ktbl+1]:='6';
      StringGrid1.Cells[4,ktbl+1]:='µatm';
      StringGrid1.Cells[5,ktbl+1]:='micro-atmosphere';
    end;
    {PH}
    {'potential of hydrogen' or 'power of hydrogen}
    {a scale used to specify the acidity or basicity of an aqueous solution}
    if tbl='P_PH' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(6.3); //WOD18 table
      StringGrid1.Cells[2,ktbl+1]:=floattostr(9.2);
      StringGrid1.Cells[3,ktbl+1]:='2';
      StringGrid1.Cells[4,ktbl+1]:='unit less';
      StringGrid1.Cells[5,ktbl+1]:='Dimensionless or unit less';
    end;
    {PHTS25P0 PH total scale (25 deg C, 0 dbar)}
    if tbl='P_PHTS25P0' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(6.3); //WOD18 table
      StringGrid1.Cells[2,ktbl+1]:=floattostr(9.2);
      StringGrid1.Cells[3,ktbl+1]:='2';
      StringGrid1.Cells[4,ktbl+1]:='unit less';
      StringGrid1.Cells[5,ktbl+1]:='Dimensionless or unit less';
    end;
    {PHTSINSITUTP PH total scale (in situ temperature and pressure)}
    if tbl='P_PHTSINSITUTP' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(6.3); //WOD18 table
      StringGrid1.Cells[2,ktbl+1]:=floattostr(9.2);
      StringGrid1.Cells[3,ktbl+1]:='2';
      StringGrid1.Cells[4,ktbl+1]:='unit less';
      StringGrid1.Cells[5,ktbl+1]:='Dimensionless or unit less';
    end;
    {Sulfur hexafluoride SF6}
    if tbl='P_SF6' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.1); //GLODAP + PANGAEA
      StringGrid1.Cells[2,ktbl+1]:=floattostr(7);
      StringGrid1.Cells[3,ktbl+1]:='19';
      StringGrid1.Cells[4,ktbl+1]:='fmol/kg';
      StringGrid1.Cells[5,ktbl+1]:='femto-mole per kilogram';
    end;
    {Sulfur hexafluoride (partial pressure) PSF6}
    if tbl='P_PSF6' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(-0.3); //GLODAP
      StringGrid1.Cells[2,ktbl+1]:=floattostr(23);
      StringGrid1.Cells[3,ktbl+1]:='18';
      StringGrid1.Cells[4,ktbl+1]:='ppt';
      StringGrid1.Cells[5,ktbl+1]:='Parts per trillion';
    end;
    {Transmission of light Transmission}
    if tbl='P_TRANSMISSION' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(40); //NABOS + PANGAEA
      StringGrid1.Cells[2,ktbl+1]:=floattostr(101);
      StringGrid1.Cells[3,ktbl+1]:='10';
      StringGrid1.Cells[4,ktbl+1]:='%';
      StringGrid1.Cells[5,ktbl+1]:='persent';
    end;
    {Ocean turbidity}
    {ITP PQF2=0 bad profiles}
    if tbl='P_TURBIDITY' then begin
      StringGrid1.Cells[1,ktbl+1]:=floattostr(0); //ITP + PQF2=4 (PQF2=0 did not replaced)
      StringGrid1.Cells[2,ktbl+1]:=floattostr(16);
      StringGrid1.Cells[3,ktbl+1]:='22';
      StringGrid1.Cells[4,ktbl+1]:='(m-1 sr-1)10^4';
      StringGrid1.Cells[5,ktbl+1]:='Volume scattering coefficient';
    end;

{T}end;

end;



procedure TfrmQC_WideRanges.btnSelectAllClick(Sender: TObject);
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




procedure TfrmQC_WideRanges.btnSetFlagsClick(Sender: TObject);
var
i,ktbl,klt,kln :integer;
unit_tbl,unit_default,val_c,val_nc,val_t :integer;
outliers_count,step,sq_count,tbl_count :integer;
val,val_conv,val_min,val_max :real;
ltn,lts,lnw,lne :real;
tbl,var_name :string;
range_unknown,isconverted,isoutlier :boolean;
DT1,DT2: TDateTime;

{PQF2 update}
id,instr_id,prof_num,PQF2,PQF2_count: integer;
lev_m :real;

{lab density}
//lat,lon,lab_dens :real;

begin

  DT1:=NOW;
  memo1.Lines.Add('...start [ranges]: '+datetimetostr(DT1));

  case RadioGroup1.ItemIndex of
     0: step:=10;
     1: step:=5;
     2: step:=1;
  end;

    tbl_count:=0;
{T}for ktbl:=0 to CheckGroup1.Items.Count-1 do begin
{TC}if CheckGroup1.Checked[ktbl] then begin
    tbl_count:=tbl_count+1;
{TC}end;
{T} end;
if tbl_count=0 then begin
    showmessage('Variable does not selected!');
    Exit;
end;


{T}for ktbl:=0 to CheckGroup1.Items.Count-1 do begin
{C}if CheckGroup1.Checked[ktbl] then begin

   Edit1.Text:='';
   Edit2.Text:='';
   Edit3.Text:='';
   Edit4.Text:='';
   Edit5.Text:='';
   Edit6.Text:='';
   Edit7.Text:='';

   tbl:=CheckGroup1.Items.Strings[ktbl]; {selected table}
   Edit1.Text:=tbl;
   Application.ProcessMessages;

   {skip ITP}
   if (tbl='P_PAR') or (tbl='P_TURBIDITY') then begin
     showmessage(tbl+'  PQF2=0 should not be replaced in ITP real-time data');
     Exit;
   end;
   {...apply range}
{R}for i:=1 to StringGrid1.RowCount-1 do begin
    var_name:=StringGrid1.Cells[0,i];
{V}if tbl='P_'+var_name then begin

    range_unknown:=false;

    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select count(id) from '+tbl);
      Open;
      Edit2.Text:=inttostr(FieldByName('count').AsInteger);
      Close;
    end;

    if trystrtofloat(StringGrid1.Cells[1,i],val_min) then val_min:=strtofloat(StringGrid1.Cells[1,i]) else range_unknown:=true;
    if trystrtofloat(StringGrid1.Cells[2,i],val_max) then val_max:=strtofloat(StringGrid1.Cells[2,i]) else range_unknown:=true;
    if trystrtoint(StringGrid1.Cells[3,i],unit_default) then unit_default:=strtoint(StringGrid1.Cells[3,i]) else range_unknown:=true;

    if range_unknown=true then begin
     showmessage('Range for selected variable is unknown!');
     Exit;
    end;

{CR}if CheckBox1.Checked = false then begin

   memo1.Lines.Add(tbl+'   ...control run');

   sq_count:=0;
   val_t:=0;    {number of               values in a table}
   val_c:=0;    {number of     converted values}
   val_nc:=0;   {number of not converted values}
   outliers_count:=0;


     {.....squares to reduce selection size}
       klt:=0;
{Lt}repeat
       inc(klt);
       ltn:=90-step*(klt-1);
       lts:=90-step*klt;

       kln:=0;
{Ln}repeat
       inc(kln);
       lnw:=-180+step*(kln-1);
       lne:=-180+step*kln;

       sq_count:=sq_count+1;
       Edit3.Text:=inttostr(sq_count);
       Application.ProcessMessages;

    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select val,units_id from STATION,'+tbl);
      SQL.Add(' where station.id='+tbl+'.id ');
      SQL.Add(' and latitude>:lts and latitude<=:ltn ');
      {...select data from 180 meridian}
      if lne<>180 then SQL.Add(' and longitude>=:lnw and longitude<:lne ')
                  else SQL.Add(' and longitude>=:lnw and longitude<=:lne ');
      ParamByName('ltn').AsFloat:=ltn;
      ParamByName('lts').AsFloat:=lts;
      ParamByName('lnw').AsFloat:=lnw;
      ParamByName('lne').AsFloat:=lne;
      Open;
    end;

{w}while not frmdm.q1.EOF do begin
     //station_id:=frmdm.q1.FieldByName('station_id').AsInteger;
     val:=frmdm.q1.FieldByName('val').AsFloat;
     unit_tbl:=frmdm.q1.FieldByName('units_id').AsInteger;
     //id:=frmdm.q1.FieldByName('id').AsInteger;
     //lev_m:=frmdm.q1.FieldByName('lev_m').AsFloat;
     //instr_id:=frmdm.q1.FieldByName('instrument_id').AsInteger;
     //prof_num:=frmdm.q1.FieldByName('profile_number').AsInteger;

     val_t:=val_t+1;

     if  val_t mod 10000=0 then begin
       Edit4.Text:=inttostr(val_t);
       Application.ProcessMessages;
     end;

     //memo1.Lines.Add(inttostr(val_t)+#9+floattostr(val)+#9+inttostr(unit_tbl));

     isoutlier:=false;
   if unit_tbl=unit_default then begin
       if val<val_min then isoutlier:=true;
       if val>val_max then isoutlier:=true;
   end;

   if isoutlier=true then begin
     outliers_count:=outliers_count+1;
     Edit5.Text:=inttostr(outliers_count);
   end;

   {...conversion}
     isconverted:=false;
     val_conv:=9999;
{c}if unit_tbl<>unit_default then begin

     osunitsconversion.GetDefaultUnits(tbl, unit_tbl, unit_default,
                                       val, val_conv, isconverted);
     {osunitsconversion.GetDefaultUnitsExact(tbl, unit_tbl, unit_default, ID
                                       instr_id, prof_num, val, lat, lon,
                                       Lev_m, val_conv, isconverted);}

    if isconverted=true then begin
      val:=val_conv;
      val_c:=val_c+1;
      Edit6.Text:=inttostr(val_c);
      isoutlier:=false;
      if val<val_min then isoutlier:=true;
      if val>val_max then isoutlier:=true;
      if isoutlier=true then begin
        outliers_count:=outliers_count+1;
        Edit5.Text:=inttostr(outliers_count);
      end;
    end
    else begin
       val_nc:=val_nc+1;
       Edit7.Text:=inttostr(val_nc);
    end;
{c}end;

     frmdm.q1.Next;
{w}end;
     frmdm.q1.Close;


{Ln}until lne=180;
{Lt}until lts=-90;

     Edit4.Text:=inttostr(val_t);

     memo1.Lines.Add(inttostr(i)
     +#9+tbl
     +#9+floattostr(val_min)+'->'
     +#9+floattostr(val_max)
     +#9+'unit_default='+inttostr(unit_default)
     +#9+'outliers='+inttostr(outliers_count)
     +#9+'total/converted/not_converted='+inttostr(val_t)+'/'+inttostr(val_c)+'/'+inttostr(val_nc));

{CR}end; {control run without flags writing}


{......update flags in DB}
{UF}if CheckBox1.Checked = true then begin

   memo1.Lines.Add('');
   memo1.Lines.Add(tbl+'   ...flags writing ');

   memo1.Lines.Add(tbl+'   PQF2 statistics: initial');
   with frmdm.q3 do begin
     Close;
     SQL.Clear;
     SQL.Add(' select PQF2, count(PQF2) from '+tbl);
     SQL.Add(' group by PQF2 ');
     Open;
   end;
   while not frmdm.q3.EOF do begin
     PQF2:=frmdm.q3.FieldByName('PQF2').AsInteger;
     PQF2_count:=frmdm.q3.FieldByName('count').AsInteger;
     memo1.Lines.Add(inttostr(PQF2)+#9+inttostr(PQF2_count));
     frmdm.q3.Next;
   end;
     frmdm.q3.Close;


   sq_count:=0;
   val_t:=0;    {number of               values in a table}
   val_c:=0;    {number of     converted values}
   val_nc:=0;   {number of not converted values}
   outliers_count:=0;


     {.....squares to reduce selection size}
       klt:=0;
{Lt}repeat
       inc(klt);
       ltn:=90-step*(klt-1);
       lts:=90-step*klt;

       kln:=0;
{Ln}repeat
       inc(kln);
       lnw:=-180+step*(kln-1);
       lne:=-180+step*kln;

       sq_count:=sq_count+1;
       Edit3.Text:=inttostr(sq_count);
       Application.ProcessMessages;

    with frmdm.q1 do begin
      Close;
      SQL.Clear;
      SQL.Add(' select STATION.id as id,lev_m,val,units_id,instrument_id,profile_number from STATION,'+tbl);
      SQL.Add(' where station.id='+tbl+'.id ');
      SQL.Add(' and latitude>:lts and latitude<=:ltn ');
      {...select data from 180 meridian}
      if lne<>180 then SQL.Add(' and longitude>=:lnw and longitude<:lne ')
                  else SQL.Add(' and longitude>=:lnw and longitude<=:lne ');
      ParamByName('ltn').AsFloat:=ltn;
      ParamByName('lts').AsFloat:=lts;
      ParamByName('lnw').AsFloat:=lnw;
      ParamByName('lne').AsFloat:=lne;
      Open;
    end;

{w}while not frmdm.q1.EOF do begin
     id:=frmdm.q1.FieldByName('id').AsInteger;
     lev_m:=frmdm.q1.FieldByName('lev_m').AsFloat;
     val:=frmdm.q1.FieldByName('val').AsFloat;
     unit_tbl:=frmdm.q1.FieldByName('units_id').AsInteger;
     instr_id:=frmdm.q1.FieldByName('instrument_id').AsInteger;
     prof_num:=frmdm.q1.FieldByName('profile_number').AsInteger;

     val_t:=val_t+1;

     if  val_t mod 10000=0 then begin
       Edit4.Text:=inttostr(val_t);
       Application.ProcessMessages;
     end;

     //memo1.Lines.Add(inttostr(val_t)+#9+floattostr(val)+#9+inttostr(unit_tbl));

     isoutlier:=false;
   if unit_tbl=unit_default then begin
       if val<val_min then isoutlier:=true;
       if val>val_max then isoutlier:=true;
   end;

{OUT}if isoutlier=true then begin
     outliers_count:=outliers_count+1;
     Edit5.Text:=inttostr(outliers_count);
     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' UPDATE '+tbl+' SET PQF2=:QF WHERE ');
       SQL.Add(' ID=:ID AND LEV_M=:LEV_M AND VAL=:VAL AND ');
       SQL.Add(' INSTRUMENT_ID=:INSTR_ID AND ');
       SQL.Add(' PROFILE_NUMBER=:PROF_NUM ');
       ParamByName('ID').Value:=id;
       ParamByName('QF').Value:=1;
       ParamByName('LEV_M').Value:=lev_m;
       ParamByName('VAL').Value:=val;
       ParamByName('INSTR_ID').Value:=instr_id;
       ParamByName('PROF_NUM').Value:=prof_num;
      ExecSQL;
     end;
{OUT}end;

   {...conversion}
     isconverted:=false;
     val_conv:=9999;
{c}if unit_tbl<>unit_default then begin

     osunitsconversion.GetDefaultUnits(tbl, unit_tbl, unit_default,
                                       val, val_conv, isconverted);
     {osunitsconversion.GetDefaultUnitsExact(tbl, unit_tbl, unit_default, ID
                                       instr_id, prof_num, val, lat, lon,
                                       Lev_m, val_conv, isconverted);}
{conv}if isconverted=true then begin
      //val:=val_conv;
      val_c:=val_c+1;
      Edit6.Text:=inttostr(val_c);
      isoutlier:=false;
      if val_conv<val_min then isoutlier:=true;
      if val_conv>val_max then isoutlier:=true;

{OUT}if isoutlier=true then begin
     outliers_count:=outliers_count+1;
     Edit5.Text:=inttostr(outliers_count);

     with frmdm.q2 do begin
      Close;
       SQL.Clear;
       SQL.Add(' UPDATE '+tbl+' SET PQF2=:QF WHERE ');
       SQL.Add(' ID=:ID AND LEV_M=:LEV_M AND VAL=:VAL AND ');
       SQL.Add(' INSTRUMENT_ID=:INSTR_ID AND ');
       SQL.Add(' PROFILE_NUMBER=:PROF_NUM ');
       ParamByName('ID').Value:=id;
       ParamByName('QF').Value:=1;   //all outliers outside physical range get QCF=1
       ParamByName('LEV_M').Value:=lev_m;
       ParamByName('VAL').Value:=val;
       ParamByName('INSTR_ID').Value:=instr_id;
       ParamByName('PROF_NUM').Value:=prof_num;
      ExecSQL;
     end;
{OUT}end;

{conv}end
      else begin
         val_nc:=val_nc+1;
         Edit7.Text:=inttostr(val_nc);
      end;
{c}end;

     frmdm.q1.Next;
{w}end;
     frmdm.q1.Close;


{Ln}until lne=180;
{Lt}until lts=-90;

     frmdm.TR.Commit;

     Edit4.Text:=inttostr(val_t);

     memo1.Lines.Add(inttostr(i)
     +#9+tbl
     +#9+floattostr(val_min)+'->'
     +#9+floattostr(val_max)
     +#9+'unit_default='+inttostr(unit_default)
     +#9+'outliers='+inttostr(outliers_count)
     +#9+'total/converted/not_converted='+inttostr(val_t)+'/'+inttostr(val_c)+'/'+inttostr(val_nc));


     memo1.Lines.Add('');
     memo1.Lines.Add(tbl+'   PQF2 statistics: after flags writing ');
     with frmdm.q3 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select PQF2, count(PQF2) from '+tbl);
       SQL.Add(' group by PQF2 ');
       Open;
     end;
     while not frmdm.q3.EOF do begin
       PQF2:=frmdm.q3.FieldByName('PQF2').AsInteger;
       PQF2_count:=frmdm.q3.FieldByName('count').AsInteger;
       memo1.Lines.Add(inttostr(PQF2)+#9+inttostr(PQF2_count));
       frmdm.q3.Next;
     end;
       frmdm.q3.Close;


     {...change all PQF2=0 to PQF2=4 }
     with frmdm.q3 do begin
      Close;
       SQL.Clear;
       SQL.Add(' UPDATE '+tbl+' SET PQF2=4 WHERE PQF2=0 ');
      ExecSQL;
     end;
       frmdm.TR.Commit;


       memo1.Lines.Add('');
       memo1.Lines.Add(tbl+'   PQF2 statistics: final ');
       with frmdm.q3 do begin
         Close;
         SQL.Clear;
         SQL.Add(' select PQF2, count(PQF2) from '+tbl);
         SQL.Add(' group by PQF2 ');
         Open;
       end;
       while not frmdm.q3.EOF do begin
         PQF2:=frmdm.q3.FieldByName('PQF2').AsInteger;
         PQF2_count:=frmdm.q3.FieldByName('count').AsInteger;
         memo1.Lines.Add(inttostr(PQF2)+#9+inttostr(PQF2_count));
         frmdm.q3.Next;
       end;
         frmdm.q3.Close;

{UF}end; {Upfate Flags in DB}


{V}end; {check if variable range is filled}
{R}end; {ranges cycle}


{C}end; {table is checked }
{T}end; {tables cycle}

    DT2:=NOW;
    memo1.Lines.Add('');
    memo1.Lines.Add('...stop: '+datetimetostr(DT2));
    memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;

end.

