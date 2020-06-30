unit osqc_duplicates;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin;

type

  { Tfrmqc_duplicates }

  Tfrmqc_duplicates = class(TForm)
    btnFindDuplicates: TButton;
    cbSource: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    seLonMax: TFloatSpinEdit;
    procedure cbSourceChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmqc_duplicates: Tfrmqc_duplicates;

implementation

{$R *.lfm}

{ Tfrmqc_duplicates }

uses osmain, dm;

procedure Tfrmqc_duplicates.FormShow(Sender: TObject);
begin
 cbSource.Items:=frmosmain.cbSource.Items;
end;

procedure Tfrmqc_duplicates.cbSourceChange(Sender: TObject);
begin
  btnFindDuplicates.Enabled:=true;
end;

end.

