unit surfer_settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, Spin, ExtCtrls, IniFiles;

type

  { Tfrmsurfersettings }

  Tfrmsurfersettings = class(TForm)
    btnCancel: TButton;
    btnSave: TButton;
    cbKrigDrift: TComboBox;
    cbKrigType: TComboBox;
    cbMethod: TComboBox;
    chkShowColourScale: TCheckBox;
    chkSearch: TCheckBox;
    eAnisRatio: TEdit;
    eCurveTol: TEdit;
    eL2edist: TEdit;
    eL2ldist: TEdit;
    eMCBoundTens: TEdit;
    eMCMaxRes: TEdit;
    eMCRelFact: TEdit;
    eMCRelTens: TEdit;
    eMissingVal: TEdit;
    eSearchEllipseRad1: TEdit;
    eSearchEllipseRad2: TEdit;
    gbAnisotropy: TGroupBox;
    gbInverseDist: TGroupBox;
    gbKriging: TGroupBox;
    gbSearch: TGroupBox;
    gbSearchEllipse: TGroupBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox7: TGroupBox;
    label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl1: TPageControl;
    rgMinCurvature: TGroupBox;
    seAnisAngle: TSpinEdit;
    seFilter: TSpinEdit;
    seIDPower: TSpinEdit;
    seIDSmooth: TSpinEdit;
    sePlotWidth: TSpinEdit;
    sePlotHeight: TSpinEdit;
    seLevelFirst: TSpinEdit;
    seLevelSet: TSpinEdit;
    seLevelSkip: TSpinEdit;
    seMCMaxIter: TSpinEdit;
    seSearchDataSect: TSpinEdit;
    seSearchEllipseAngle: TSpinEdit;
    seSearchMaxData: TSpinEdit;
    seSearchMaxEmpty: TSpinEdit;
    seSearchMinData: TSpinEdit;
    seSearchNumSect: TSpinEdit;
    seColScaleLbFreq: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;

    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure cbMethodSelect(Sender: TObject);
    procedure eSearchEllipseRad1KeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);


  private
    { private declarations }
  public
    { public declarations }
    procedure LoadSettings(Src:string);
  end;

var
  frmsurfersettings: Tfrmsurfersettings;
  IntSrc:string; // settings source

implementation

{$R *.lfm}

uses osmain;

procedure Tfrmsurfersettings.FormShow(Sender: TObject);
begin
//  PageControl1.Page[1].TabVisible:=curve;
end;

procedure Tfrmsurfersettings.cbMethodSelect(Sender: TObject);
begin
  gbKriging.Color       :=clBtnFace;
  gbSearch.Color        :=clBtnFace;
  gbSearchEllipse.Color :=clBtnFace;
  gbInverseDist.Color   :=clBtnFace;
  gbAnisotropy.Color    :=clBtnFace;
  rgMinCurvature.Color  :=clBtnFace;

{srfShepards
srfRegression
srfLocalPolynomial }

  if cbMethod.Text='srfKriging' then begin
    gbKriging.Color       :=clMoneyGreen;
    gbSearch.Color        :=clMoneyGreen ;
    gbSearchEllipse.Color :=clMoneyGreen ;
  end;

  if cbMethod.Text='srfInverseDistanse' then begin
    gbSearch.Color        :=clMoneyGreen ;
    gbSearchEllipse.Color :=clMoneyGreen ;
    gbInverseDist.Color   :=clMoneyGreen ;
    gbAnisotropy.Color    :=clMoneyGreen ;
  end;

  if cbMethod.Text='srfNaturalNeighbor' then begin
    gbAnisotropy.Color    :=clMoneyGreen ;
  end;

  if cbMethod.Text='srfNearestNeighbor' then begin
    gbSearchEllipse.Color :=clMoneyGreen ;
  end;

  if cbMethod.Text='srfMinCurvature' then begin
    rgMinCurvature.Color  :=clMoneyGreen ;
    gbAnisotropy.Color    :=clMoneyGreen ;
  end;

  if cbMethod.Text='srfRadialBasis' then begin
    gbAnisotropy.Color    :=clMoneyGreen ;
  end;

  if cbMethod.Text='srfTriangulation' then begin
    gbAnisotropy.Color    :=clMoneyGreen ;
  end;

  if cbMethod.Text='srfInverseDistanse' then begin
    gbSearch.Color        :=clMoneyGreen ;
    gbSearchEllipse.Color :=clMoneyGreen ;
  end;
end;


procedure Tfrmsurfersettings.eSearchEllipseRad1KeyPress(Sender: TObject;
  var Key: char);
begin
    if not (key in['0'..'9',decimalseparator,#8]) then key:=#0;
end;


procedure Tfrmsurfersettings.LoadSettings(Src: string);
Var
  Ini:TIniFile;
begin
  (* Читаем настройки из файла *)
Ini := TIniFile.Create(IniFileName);
 try
  sePlotWidth.Value          :=Ini.ReadInteger  (src, 'PlotWidth',         20);
  sePlotHeight.Value         :=Ini.ReadInteger  (src, 'PlotHeight',        15);

  cbMethod.Text              :=Ini.ReadString   (src, 'Algorithm',         'srfKriging');
  eMissingVal.Text           :=Ini.ReadString   (src, 'MissingVal',        '-9999');
  seFilter.Value             :=Ini.ReadInteger  (src, 'Filter',            0 );
  cbKrigType.Text            :=Ini.ReadString   (src, 'KrigType',          'srfKrigPoint');
  cbKrigDrift.Text           :=Ini.ReadString   (src, 'KrigDriftType',     'srfDriftNone');
  chkSearch.Checked          :=Ini.ReadBool     (src, 'SearchEnable',       false);
  seSearchNumSect.Value      :=Ini.ReadInteger  (src, 'SearchNumSectors',   4);
  seSearchMinData.Value      :=Ini.ReadInteger  (src, 'SearchMinData',      16);
  seSearchMaxData.Value      :=Ini.ReadInteger  (src, 'SearchMaxData',      64);
  seSearchDataSect.Value     :=Ini.ReadInteger  (src, 'SearchDataPerSect',  8);
  seSearchMaxEmpty.Value     :=Ini.ReadInteger  (src, 'SearchMaxEmpty',     3);
  eSearchEllipseRad1.Text    :=Ini.ReadString   (src, 'SearchRad1',         '1' );
  eSearchEllipseRad2.Text    :=Ini.ReadString   (src, 'SearchRad2',         '1' );
  seSearchEllipseAngle.Value :=Ini.ReadInteger  (src, 'SearchAngle',        0 );
  eAnisRatio.Text            :=Ini.ReadString   (src, 'AnisotropyRatio',    '1');
  seAnisAngle.Value          :=Ini.ReadInteger  (src, 'AnisotropyAngle',    0 );
  seIDPower.Value            :=Ini.ReadInteger  (src, 'IDPower',            2 );
  seIDSmooth.Value           :=Ini.ReadInteger  (src, 'IDSmoothing',        0 );
  eMCMaxRes.Text             :=Ini.ReadString   (src, 'MCMaxResidual',      '1E-9');
  seMCMaxIter.Value          :=Ini.ReadInteger  (src, 'MCMaxIterations',    100000 );
  eMCRelTens.Text            :=Ini.ReadString   (src, 'MCInternalTension',  '1' );
  eMCBoundTens.Text          :=Ini.ReadString   (src, 'MCBoundaryTension',  '0' );
  eMCRelFact.Text            :=Ini.ReadString   (src, 'MCRelaxationFactor', '0' );

  eCurveTol.Text             :=Ini.ReadString   (src, 'CurveTolerance',     '15E-1' );
  eL2ldist.Text              :=Ini.ReadString   (src, 'LevelToLevelDist',   '1' );
  eL2edist.Text              :=Ini.ReadString   (src, 'LevelToEdgeDist',    '1' );

 // seIntervalX.Value          :=Ini.ReadInteger  (src, 'IntervalX',           20 );
 // seIntervalY.Value          :=Ini.ReadInteger  (src, 'IntervalY',           5  );

  seLevelFirst.Value         :=Ini.ReadInteger  (src, 'LevelFirst',          1 );
  seLevelSet.Value           :=Ini.ReadInteger  (src, 'LevelSet',            1 );
  seLevelSkip.Value          :=Ini.ReadInteger  (src, 'LevelSkip',           4 );

  chkShowColourScale.Checked :=Ini.ReadBool     (src, 'ColourScaleShow',     true);
 // rgOrientation.ItemIndex    :=Ini.ReadInteger  (src, 'ColourScaleOrient',   0);
  seColScaleLbFreq.Value     :=Ini.ReadInteger  (src, 'ColourScaleLbFreq',   1);


 finally
   Ini.Free;
 end;
 IntSrc:=Src;

 Caption:='Surfer Settings: '+IntSrc;
 cbMethod.OnSelect(self);
end;


procedure Tfrmsurfersettings.btnSaveClick(Sender: TObject);
Var
 Ini:TIniFile;
begin
 Ini := TIniFile.Create(IniFileName);
  try
    Ini.WriteInteger(IntSrc, 'PlotWidth',           sePlotWidth.Value);
    Ini.WriteInteger(IntSrc, 'PlotHeight',          sePlotHeight.Value);

    Ini.WriteString (Intsrc, 'MissingVal',          eMissingVal.Text);
    Ini.WriteString (IntSrc, 'Filter',              IntToStr(seFilter.Value));
    Ini.WriteString (IntSrc, 'Algorithm',           cbMethod.Text);
    Ini.WriteString (IntSrc, 'KrigType',            cbKrigType.Text);
    Ini.WriteString (IntSrc, 'KrigDriftType',       cbKrigDrift.Text);

    Ini.WriteBool   (IntSrc, 'SearchEnable',        chkSearch.Checked);

    Ini.WriteString (IntSrc, 'SearchNumSectors',    IntToStr(seSearchNumSect.Value));
    Ini.WriteString (IntSrc, 'SearchMinData',       IntToStr(seSearchMinData.Value));
    Ini.WriteString (IntSrc, 'SearchMaxData',       IntToStr(seSearchMaxData.Value));
    Ini.WriteString (IntSrc, 'SearchDataPerSect',   IntToStr(seSearchDataSect.Value));
    Ini.WriteString (IntSrc, 'SearchMaxEmpty',      IntToStr(seSearchMaxEmpty.Value));
    Ini.WriteString (IntSrc, 'SearchRad1',          eSearchEllipseRad1.Text);
    Ini.WriteString (IntSrc, 'SearchRad2',          eSearchEllipseRad2.Text);
    Ini.WriteString (IntSrc, 'SearchAngle',         IntToStr(seSearchEllipseAngle.Value));
    Ini.WriteString (IntSrc, 'AnisotropyRatio',     eAnisRatio.Text);
    Ini.WriteString (IntSrc, 'AnisotropyAngle',     IntToStr(seAnisAngle.Value));
    Ini.WriteString (IntSrc, 'IDPower',             IntToStr(seIDPower.Value));
    Ini.WriteString (IntSrc, 'IDSmoothing',         IntToStr(seIDSmooth.Value));
    Ini.WriteString (IntSrc, 'MCMaxResidual',       eMCMaxRes.Text);
    Ini.WriteString (IntSrc, 'MCMaxIterations',     IntToStr(seMCMaxIter.Value));
    Ini.WriteString (IntSrc, 'MCInternalTension',   eMCRelTens.Text);
    Ini.WriteString (IntSrc, 'MCBoundaryTension',   eMCBoundTens.Text);
    Ini.WriteString (IntSrc, 'MCRelaxationFactor',  eMCRelFact.Text);

    Ini.WriteString (IntSrc, 'CurveTolerance',      eCurveTol.Text);
    Ini.WriteString (IntSrc, 'LevelToLevelDist',    eL2ldist.Text);
    Ini.WriteString (IntSrc, 'LevelToEdgeDist',     eL2edist.Text);

 //   Ini.WriteString (IntSrc, 'IntervalX',           seIntervalX.Text);
 //   Ini.WriteString (IntSrc, 'IntervalY',           seIntervalY.Text);

    Ini.WriteString (IntSrc, 'LevelFirst',          seLevelFirst.Text);
    Ini.WriteString (IntSrc, 'LevelSet',            seLevelSet.Text);
    Ini.WriteString (IntSrc, 'LevelSkip',           seLevelSkip.Text);

    Ini.WriteBool   (IntSrc, 'ColourScaleShow',     chkShowColourScale.Checked);
  //  Ini.WriteInteger(IntSrc, 'ColourScaleOrient',   rgOrientation.ItemIndex);
    Ini.WriteInteger(IntSrc, 'ColourScaleLbFreq',   seColScaleLbFreq.Value);
  finally
   Ini.Free;
  end;

  Close;
end;


procedure Tfrmsurfersettings.btnCancelClick(Sender: TObject);
begin
  Close;
end;

end.

