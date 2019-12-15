program OceanShell;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, osmain, dm, procedures, osload_itp, osstandartqueries, codesupdateqc,
  osload_GLODAP_2019_v2_product, oscreatenewdb, osstatistics, osparameters_all,
  tachartlazaruspkg, datetimectrls, osload_WOD18, osmap, osmap_globctrl,
  osmap_datastreams, osmap_geometry, osmap_wkt, osmap_kml, icons;

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tfrmosmain, frmosmain);
  Application.CreateForm(Tfrmdm, frmdm);
  Application.CreateForm(Tfrmicons, frmicons);
  Application.Run;
end.

