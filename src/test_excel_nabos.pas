unit test_excel_nabos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, comobj, Dialogs;

procedure ExcelTest;

implementation

procedure ExcelTest;
Var
  XLApp: OLEVariant;
  x,y: byte;
  path, cruise: string;

  Stat,Lat,Lon,Depth,Lev,Lbl,pres,sal,temp,SBE43,Fluor,Turb,SUNA:real;
  Ba,WinklerO2_1,WinklerO2_2,WinklerO2_3,PO4,SiO4,NO2,NH4,NO3,DIN,Chl:real;
  Vinta,DIC,pCO2_1,pCO2_2,Sal1,Sal2:real;
begin

 //Showmessage('Here0');

 try
  XLApp := CreateOleObject('Excel.Application');
  XLApp.Visible := False;
  XLApp.DisplayAlerts := False;
 except
  Showmessage('MS Excel is not installed');
  Exit;
 end;

 try
   path := 'X:\OceanShell\data\NABOS\NABOS_CHEMISTRY_2013.xlsx';

   XLApp.Workbooks.Open(Path);     // Open the Workbook

 //  showmessage('here');


   y:=3; //skipping header
   repeat
     inc(y); //column position

     Cruise:=XLApp.Cells[y,1].Value;

       //checking for empty strings here
       if trim(Cruise)<>'' then begin
         Stat :=XLApp.Cells[y,2].Value;
         Lat:=  XLApp.Cells[y,3].Value;
         Lon:=  XLApp.Cells[y,4].Value;
         Depth:=XLApp.Cells[y,5].Value;
         Lev:=  XLApp.Cells[y,6].Value;
         Lbl:=  XLApp.Cells[y,7].Value;
         pres:= XLApp.Cells[y,8].Value;
         if trystrtofloat(XLApp.Cells[y,9].Value, sal) then sal := XLApp.Cells[y,9].Value else sal:=-9999; //salinity????
         if trystrtofloat(XLApp.Cells[y,10].Value,temp) then temp:= XLApp.Cells[y,10].Value else temp:=-9999;
         if trystrtofloat(XLApp.Cells[y,11].Value,sbe43) then SBE43:=XLApp.Cells[y,11].Value else SBE43:=-9999;
         if trystrtofloat(XLApp.Cells[y,12].Value, fluor) then Fluor:=XLApp.Cells[y,12].Value else Fluor:=-9999;
         if trystrtofloat(XLApp.Cells[y,13].Value, turb) then Turb:= XLApp.Cells[y,13].Value else Turb:=-9999;
         if trystrtofloat(XLApp.Cells[y,14].Value,suna) then SUNA:= XLApp.Cells[y,14].Value else SUNA:=-9999;
         // 15 is empty
         if trystrtofloat(XLApp.Cells[y,16].Value,ba) then Ba:=   XLApp.Cells[y,16].Value else Ba:=-9999;
         if trystrtofloat(XLApp.Cells[y,17].Value,WinklerO2_1) then WinklerO2_1:=XLApp.Cells[y,17].Value else WinklerO2_1:=-9999;
         if trystrtofloat(XLApp.Cells[y,18].Value,WinklerO2_2) then WinklerO2_2:=XLApp.Cells[y,18].Value else WinklerO2_2:=-9999;
         if trystrtofloat(XLApp.Cells[y,19].Value,WinklerO2_3) then WinklerO2_3:=XLApp.Cells[y,19].Value else WinklerO2_3:=-9999;
         if trystrtofloat(XLApp.Cells[y,20].Value, PO4) then PO4:=XLApp.Cells[y,20].Value else PO4:=-9999;
         if trystrtofloat(XLApp.Cells[y,21].Value, Sio4) then SiO4:=XLApp.Cells[y,21].Value else SiO4:=-9999;
         if trystrtofloat(XLApp.Cells[y,22].Value, No2) then NO2:=XLApp.Cells[y,22].Value else NO2:=-9999;
         if trystrtofloat(XLApp.Cells[y,23].Value, NH4) then NH4:=XLApp.Cells[y,23].Value else NH4:=-9999;
         if trystrtofloat(XLApp.Cells[y,24].Value, NO3) then NO3:=XLApp.Cells[y,24].Value else NO3:=-9999;
         if trystrtofloat(XLApp.Cells[y,25].Value, DIN) then DIN:=XLApp.Cells[y,25].Value else DIN:=-9999;
         if trystrtofloat(XLApp.Cells[y,26].Value, CHl) then Chl:=XLApp.Cells[y,26].Value else Chl:=-9999;
         if trystrtofloat(XLApp.Cells[y,27].Value, Vinta) then Vinta:=XLApp.Cells[y,27].Value else Vinta:=-9999;
         if trystrtofloat(XLApp.Cells[y,28].Value, DIC) then DIC:=XLApp.Cells[y,28].Value else DIC:=-9999;
         if trystrtofloat(XLApp.Cells[y,29].Value,pCO2_1) then pCO2_1:=XLApp.Cells[y,29].Value else pCO2_1:=-9999;
         if trystrtofloat(XLApp.Cells[y,30].Value,pCO2_2) then pCO2_2:=XLApp.Cells[y,30].Value else pCO2_2:=-9999;
         if trystrtofloat(XLApp.Cells[y,31].Value, sal1) then Sal1:=XLApp.Cells[y,31].Value else sal1:=-9999;  // ???
         if trystrtofloat(XLApp.Cells[y,32].Value, sal2) then Sal2:=XLApp.Cells[y,32].Value else sal2:=-9999;
     end;

     (* writing parameters to database here *)
   //
  //  showmessage(cruise+'   '+floattostr(temp));
   until trim(XLApp.Cells[y,1].Value)='';   // this is the end of station

 finally
   XLApp.Quit;
   XLAPP := Unassigned;
  end;
end;

end.

