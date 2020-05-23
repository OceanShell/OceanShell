program OceanShell;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
    {$IFDEF UseCThreads}
     cthreads,
    {$ENDIF}
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, osmain, dm, icons, osprofile_station_single, osservicestatistics,
  osQC_test, osexport_ascii, test_excel_nabos;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tfrmosmain, frmosmain);
  Application.CreateForm(Tfrmdm, frmdm);
  Application.CreateForm(Tfrmicons, frmicons);
  Application.Run;
end.

