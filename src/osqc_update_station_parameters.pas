unit osqc_update_station_parameters;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin;

type

  { TfrmQCUpdateStationParameters }

  TfrmQCUpdateStationParameters = class(TForm)
    btnUpdate: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    seIDMin: TSpinEdit;
    seIDMax: TSpinEdit;
    procedure btnUpdateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmQCUpdateStationParameters: TfrmQCUpdateStationParameters;

implementation

{$R *.lfm}

{ TfrmQCUpdateStationParameters }

uses osmain, osinfo;

procedure TfrmQCUpdateStationParameters.FormShow(Sender: TObject);
begin
  seIDMin.value:=StationIDMin;
  seIDMax.value:=StationIDMax;
end;

procedure TfrmQCUpdateStationParameters.btnUpdateClick(Sender: TObject);
Var
  cmd:string;
begin
  if MessageDlg('Stations with ID between '+
                seIDMin.Text+' and '+
                seIDMax.Text+' will be updated. Proceed?',
                mtConfirmation,[mbYes, mbNo], 0)=mrNo then exit;

  if frminfo_open=false then frmInfo := TfrmInfo.Create(Self) else frminfo.SetFocus;

  btnUpdate.Enabled:=false;

  cmd:=OceanToolsPath+'UpdateStationParameters.exe'+
       ' -d '+DBAlias+
       ' -b '+seIDMin.Text+
       ' -e '+seIDMax.Text;

//  showmessage(cmd);

  frmosmain.RunScript(0, cmd, frmInfo.memo1);
  btnUpdate.Enabled:=true;
end;

end.

