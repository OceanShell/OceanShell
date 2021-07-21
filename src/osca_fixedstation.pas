unit osca_fixedstation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Buttons;

type

  { TfrmFixedStation }

  TfrmFixedStation = class(TForm)
    btnGetVarPrfStatistics: TBitBtn;
    CheckGroup1: TCheckGroup;
    CreateDataFile: TBitBtn;
    Memo1: TMemo;
    PageControl1: TPageControl;
    RadioGroup1: TRadioGroup;
    tab_data: TTabSheet;
    tab_graph: TTabSheet;
    tab_TSdiagram: TTabSheet;
    tab_memo: TTabSheet;
    tab_settings: TTabSheet;
    procedure btnGetVarPrfStatisticsClick(Sender: TObject);
    procedure CreateDataFileClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmFixedStation: TfrmFixedStation;
  pathUnload,fn :string;
  DT1,DT2 :TDateTime;
  fo: text;

implementation

uses osmain,dm;

{$R *.lfm}

{ TfrmFixedStation }

procedure TfrmFixedStation.FormShow(Sender: TObject);
begin
  pathUnload:=GlobalUnloadPath+'CA'+PathDelim;
  if not DirectoryExists(pathUnload) then CreateDir(pathUnload);
  memo1.Clear;
  CheckGroup1.items:=frmosmain.ListBox1.Items;
end;




procedure TfrmFixedStation.CreateDataFileClick(Sender: TObject);
var
n :integer;
station_id :integer;
begin

    if SCount=0 then begin
     showmessage('Stations not selected!');
     Exit;
    end;
    memo1.Lines.Add('...create data.txt ');

    DT1:=NOW;
    memo1.Lines.Add('...start: '+datetimetostr(DT1));
    memo1.Lines.Add('Number of selected stations: '+inttostr(SCount));

  {.....step1 create data.txt and compute statistics for lat,lon,timeR}
    fn:=pathUnload+'data.txt';
    assignfile(fo,fn);
    rewrite(fo);

    frmdm.q.DisableControls;
    frmdm.q.First;
    n:=0;
{Q}while not frmdm.q.EOF do begin
    inc(n);
    station_id:=frmdm.q.FieldByName('id').AsInteger;

    frmdm.q.Next;
{Q}end;
    closefile(fo);
    frmdm.q.First;
    frmdm.q.EnableControls;

    memo1.Lines.Add('');
    memo1.Lines.Add('stations: '+inttostr(n));


DT2:=NOW;
memo1.Lines.Add('...stop: '+datetimetostr(DT2));
memo1.Lines.Add('...time spent: '+timetostr(DT2-DT1));
end;



procedure TfrmFixedStation.btnGetVarPrfStatisticsClick(Sender: TObject);
type
  OnePrf=record
    name: string;
    count: integer;
  end;
  PrfDAR=array of OnePrf;

var
Prf:PrfDAR;
i,n :integer;
station_id :integer;
tbl :string;
begin

{tbl}for i:=0 to CheckGroup1.Items.Count-1 do begin
      tbl:=CheckGroup1.Items.Strings[i];
      SetLength(Prf,i+1);
      Prf[i].name:=tbl;
      Prf[i].count:=0;
{tbl}end;

    frmdm.q.DisableControls;
    frmdm.q.First;
    n:=0;
{Q}while not frmdm.q.EOF do begin
    inc(n);
    station_id:=frmdm.q.FieldByName('id').AsInteger;
    //showmessage(inttostr(n)+#9+inttostr(station_id));

{tbl}for i:=0 to High(Prf) do begin
      tbl:=Prf[i].name;
      with frmdm.q1 do begin
       Close;
       SQL.Clear;
       SQL.Add(' select count(distinct(id)) from '+tbl);
       SQL.Add(' where id=:station_id ');
       ParamByName('station_id').AsInteger:=station_id;
       Open;
       Prf[i].count:=Prf[i].count+FieldByName('count').AsInteger;
       Close;
      end;
{tbl}end;
    frmdm.q.Next;
{Q}end;
    frmdm.q.First;
    frmdm.q.EnableControls;

    memo1.Lines.Add('');
    memo1.Lines.Add('variable'+#9+'prf#');
    for i:=0 to High(Prf) do begin
      memo1.Lines.Add(inttostr(i)
      +#9+Prf[i].name
      +#9+inttostr(Prf[i].count));
    end;
end;

end.

