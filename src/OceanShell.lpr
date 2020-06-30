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
  osQC_test, osexport_ascii, osselection_customsql, osunitsconversion,
  osload_argo, oscreatenewdb, osimport_fdb, osqc_dbar_meters_consistency, osqc_duplicates;

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

