program OceanShell;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, osmain, dm, procedures, osload_itp, osstandartqueries, codesupdateqc,
  osload_GLODAP_2019_v2_product, oscreatenewdb, osstatistics, tachartlazaruspkg;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tfrmosmain, frmosmain);
  Application.CreateForm(Tfrmdm, frmdm);
  Application.Run;
end.

