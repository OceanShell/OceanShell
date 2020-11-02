unit osselection_advanced;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Spin, ExtCtrls, DateTimePicker;

type

  { Tfrmadvancedselection }

  Tfrmadvancedselection = class(TForm)
    btnAdvancedSelect: TButton;
    chkinstrument: TCheckGroup;
    ComboBox1: TComboBox;
    GroupBox4: TGroupBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;

    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    procedure btnAdvancedSelectClick(Sender: TObject);

  private
    procedure SelectAroundPoint;
  public

  end;

var
  frmadvancedselection: Tfrmadvancedselection;

implementation

{$R *.lfm}

{ Tfrmadvancedselection }

procedure Tfrmadvancedselection.btnAdvancedSelectClick(Sender: TObject);
begin
  case PageControl1.TabIndex of
   0: SelectAroundPoint;
  end;
end;


///////////////////////A R O U N D    P O I N T/////////////////////////////////
procedure Tfrmadvancedselection.SelectAroundPoint;
var
  Lat0, Lon0, lat1, Lon1, Radius, Dist:real;
begin
 {Length_arr:=1;

   if Selection.ChkDegrees.Checked=false then begin
      Lat0:=strtofloat(Selection.eLatPoint.Text);
      Lon0:=strtofloat(Selection.eLonPoint.Text);
       end else begin
          Lat0:=trunc(strtofloat(Selection.eLatPoint.Text))+(frac(strtofloat(Selection.eLatPoint.Text))/60)*100;
          Lon0:=trunc(strtofloat(Selection.eLonPoint.Text))+(frac(strtofloat(Selection.eLonPoint.Text))/60)*100;
       end;
   Radius:=strtofloat(Selection.eRadius.Text);

   SLatP_arr[0]:=Lat0;
   SLonP_arr[0]:=Lon0;

      ODBDM.CDSMD.First;
        while not ODBDM.CDSMD.Eof do begin
         Lat1:=ODBDM.CDSMD.FieldByName('StLat').AsFloat;
         Lon1:=ODBDM.CDSMD.FieldByName('StLon').AsFloat;

           Distance(Lon0, Lon1, Lat0, Lat1, Dist);
             if (dist<=Radius) then begin
               ODBDM.CDSMD.Edit;
               ODBDM.CDSMD.FieldByName('StAccess').AsInteger:=Adv_K;
               ODBDM.CDSMD.Post;
             end;
         ODBDM.CDSMD.Next;
      end;
    ODBDM.CDSMD.Filter:=' StAccess>='+inttostr(Adv_k);
    ODBDM.CDSMD.Filtered:=true; }
end;

end.

