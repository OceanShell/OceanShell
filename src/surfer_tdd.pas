unit surfer_tdd;

{$mode objfpc}{$H+}

interface


uses sysutils, IniFiles, DateUtils, math, osmain, dialogs;


procedure GetTDDScript(src: string; //full path to the source file
                    varnameunits: string; //name of the variable and its units
                    column: integer //column to plot
                    );


implementation


procedure GetTDDScript(src: string; //full path to the source file
                    varnameunits: string; //name of the variable and its units
                    column: integer //column to plot
                    );
Var
Ini:TIniFile;
dat, dat1: text;
DateMin, DateMax, LevMin, LevMax:real;
date1, lev, kf_int, DateTr:real;
IniSet, str, IntMethod, TDDPath, st:string;
StartDate:TDateTime;
ncols, nrows: integer;
begin
(* Ищем максимальные и минимальные даты и глубины *)
   AssignFile(Dat, src); Reset(Dat);
   readln(dat);

   DateMin:=9999; DateMax:=-9999; LevMin:=9999; LevMax:=-9999;
     repeat
      readln(dat, date1, lev);
       DateMin:=Min(date1, DateMin);
       DateMax:=Max(date1, DateMax);
       LevMin:=Min(lev, LevMin);
       LevMax:=Max(lev, LevMax);
     until eof(dat);
   CloseFile(dat);


   // Коэффициент трансформации
   kf_int:=(DateMax-DateMin)/(LevMax-LevMin);
   StartDate:=DateMin;

   TDDPath:=ExtractFilePath(src);

   // Формируем файл для построения
   AssignFile(Dat,  src); Reset(Dat);
    readln(Dat, str);
   AssignFile(Dat1, TDDPath+'Data.plt'); Rewrite(Dat1);
    writeln(Dat1, 'Date':10, 'Date_tr':20, Copy(str, 10, length(str)));

    repeat
      readln(Dat, str);
       Date1:=StrToFloat(trim(Copy(str, 1, 10)));
       DateTr:=((Date1-StartDate)/kf_int);
      writeln(Dat1, Date1:10:5, DateTr:20:5, Copy(str, 10, length(str)));
    until eof(Dat);
    CloseFile(Dat);
    CloseFile(Dat1);

 IniSet:='tdd';

 AssignFile(dat, TDDPath+'script.bas'); Rewrite(dat);
 try
   Ini := TIniFile.Create(IniFileName);
   IntMethod:=Ini.ReadString   (IniSet, 'Algorithm', 'srfKriging');

   if Ini.ReadBool(IniSet, 'CustomGridSize', false) = true then begin
     ncols:=Ini.ReadInteger(IniSet, 'Cols', 100);
     nrows:=Ini.ReadInteger(IniSet, 'Rows', 100);
   end else begin
     ncols:=100;
     nrows:=100;
   end;


     WriteLn(dat, 'Sub Main');
     WriteLn(dat, 'Dim Surf, Diagram, Doc, Var As Object');
     WriteLn(dat, '');
     WriteLn(dat, 'pathDataFile ="'+TDDPath+'Data.plt'+'"');
     WriteLn(dat, 'pathBlnFile ="'+TDDPath+'Blank.bln"');
     WriteLn(dat, 'PathGRD = "'+TDDPath+'Grid.grd"');

     WriteLn(dat, '');
     WriteLn(dat, 'Set Surf = CreateObject("Surfer.Application") ');
     WriteLn(dat, '');
     WriteLn(dat, 'Surf.Visible = True');
     WriteLn(dat, '  Set Doc = Surf.Documents.Add ');
     WriteLn(dat, '  Set Diagram = Doc.Windows(1)');
     WriteLn(dat, '  Diagram.AutoRedraw = False');
     WriteLn(dat, '  Doc.PageSetup.Orientation = srfLandscape');
     WriteLn(dat, '  Doc.DefaultFill.Pattern="Solid"');
     WriteLn(dat, '  Doc.DefaultFill.ForeColor=srfColorBlack20');
     WriteLn(dat, '');

             (* Анизотропия - АК*)
     writeln(dat, '  Set Var=Surf.NewVarioComponent( _');
     writeln(dat, '  VarioType:=srfVarLinear, _');
     writeln(dat, '  AnisotropyRatio:='+Ini.ReadString(IniSet, 'AnisotropyRatio', '1')+', _');
     writeln(dat, '  AnisotropyAngle:='+Ini.ReadString(IniSet, 'AnisotropyAngle', '0' )+')');
     writeln(dat, '');

//создание грида
     WriteLn(dat, 'Surf.GridData(DataFile:=pathDataFile, _');
     WriteLn(dat, '  xCol:=2, _');  //трансформированное время
     WriteLn(dat, '  yCol:=3, _');  //реальная глубина с минусом
     WriteLn(dat, '  zCol:='+IntToStr(column)+', _');  //номер колонки
     WriteLn(dat, '  numRows:='+IntToStr(nRows)+', _');
     WriteLn(dat, '  numCols:='+IntToStr(nCols)+', _');
     WriteLn(dat, '  Algorithm:='+IntMethod+', _');
  (* Настройки для различных методов интерполяции *)
 if IntMethod='srfKriging'  then begin

      WriteLn(dat, '       KrigType:='         +Ini.ReadString(IniSet, 'KrigType',          'srfKrigPoint')+', _');
      WriteLn(dat, '       KrigDriftType:='    +Ini.ReadString(IniSet, 'KrigDriftType',     'srfDriftNone')+', _');
     (* Для анизотропии - АК*)
      writeln(dat, '       KrigVariogram:=Var, _');
      writeln(dat, '       AnisotropyRatio:='+Ini.ReadString(IniSet, 'AnisotropyRatio', '1')+', _');
      writeln(dat, '       AnisotropyAngle:='+Ini.ReadString(IniSet, 'AnisotropyAngle', '0' )+', _');

    if Ini.ReadBool(IniSet, 'SearchEnable', false)=true then begin
     WriteLn(dat, '       SearchEnable:= '    +Ini.ReadString(IniSet, 'SearchEnable',       '0') +', _');
     WriteLn(dat, '       SearchNumSectors:=' +Ini.ReadString(IniSet, 'SearchNumSectors',   '4') +', _');
     WriteLn(dat, '       SearchMinData:='    +Ini.ReadString(IniSet, 'SearchMinData',     '16') +', _');
     WriteLn(dat, '       SearchMaxData:='    +Ini.ReadString(IniSet, 'SearchMaxData',     '64') +', _');
     WriteLn(dat, '       SearchDataPerSect:='+Ini.ReadString(IniSet, 'SearchDataPerSect',  '8') +', _');
     WriteLn(dat, '       SearchMaxEmpty:='   +Ini.ReadString(IniSet, 'SearchMaxEmpty',     '3') +', _');
     WriteLn(dat, '       SearchRad1:='       +Ini.ReadString(IniSet, 'SearchRad1',         '1') +', _');
     WriteLn(dat, '       SearchRad2:='       +Ini.ReadString(IniSet, 'SearchRad2',         '1') +', _');
     WriteLn(dat, '       SearchAngle:='      +Ini.ReadString(IniSet, 'SearchAngle',        '0') +', _');
    end;
  end;
  if IntMethod='srfInverseDistanse' then begin
    WriteLn(dat, '       SearchEnable:='       +Ini.ReadString(IniSet, 'SearchEnable',      '0')  +', _');
    WriteLn(dat, '       SearchNumSectors:='   +Ini.ReadString(IniSet, 'SearchNumSectors',  '4')  +', _');
    WriteLn(dat, '       SearchMinData:='      +Ini.ReadString(IniSet, 'SearchMinData',     '16') +', _');
    WriteLn(dat, '       SearchMaxData:='      +Ini.ReadString(IniSet, 'SearchMaxData',     '64') +', _');
    WriteLn(dat, '       SearchDataPerSect:='  +Ini.ReadString(IniSet, 'SearchDataPerSect', '8')  +', _');
    WriteLn(dat, '       SearchMaxEmpty:='     +Ini.ReadString(IniSet, 'SearchMaxEmpty',    '3')  +', _');
    WriteLn(dat, '       SearchRad1:='         +Ini.ReadString(IniSet, 'SearchRad1',        '1')  +', _');
    WriteLn(dat, '       SearchRad2:='         +Ini.ReadString(IniSet, 'SearchRad2',        '1')  +', _');
    WriteLn(dat, '       SearchAngle:='        +Ini.ReadString(IniSet, 'SearchAngle',       '0')  +', _');
    WriteLn(dat, '       AnisotropyRatio:='    +Ini.ReadString(IniSet, 'AnisotropyRatio',   '1')  +', _');
    WriteLn(dat, '       AnisotropyAngle:='    +Ini.ReadString(IniSet, 'AnisotropyAngle',   '0')  +', _');
    WriteLn(dat, '       IDPower:='            +Ini.ReadString(IniSet, 'IDPower',           '2')  +', _');
    WriteLn(dat, '       IDSmoothing:='        +Ini.ReadString(IniSet, 'IDSmoothing',       '0')  +', _');
  end;
  if IntMethod='srfNaturalNeighbor' then begin
    WriteLn(dat, '       AnisotropyRatio:='    +Ini.ReadString(IniSet, 'AnisotropyRatio',   '1')  +', _');
    WriteLn(dat, '       AnisotropyAngle:='    +Ini.ReadString(IniSet, 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfNearestNeighbor' then begin
    WriteLn(dat, '       SearchRad1:='         +Ini.ReadString(IniSet, 'SearchRad1',        '1')  +', _');
    WriteLn(dat, '       SearchRad2:='         +Ini.ReadString(IniSet, 'SearchRad2',        '1')  +', _');
    WriteLn(dat, '       SearchAngle:='        +Ini.ReadString(IniSet, 'SearchAngle',       '0')  +', _');
  end;
  if IntMethod='srfMinCurvature' then begin
    WriteLn(dat, '       MCMaxResidual:='      +Ini.ReadString(IniSet, 'MCMaxResidual',     '1E-9')+', _');
    WriteLn(dat, '       MCMaxIterations:='    +Ini.ReadString(IniSet, 'MCMaxIterations',   '1E+5')+', _');
    WriteLn(dat, '       MCInternalTension:='  +Ini.ReadString(IniSet, 'MCInternalTension', '1')  +', _');
    WriteLn(dat, '       MCBoundaryTension:='  +Ini.ReadString(IniSet, 'MCBoundaryTension', '0')  +', _');
    WriteLn(dat, '       MCRelaxationFactor:=' +Ini.ReadString(IniSet, 'MCRelaxationFactor','0')  +', _');
    WriteLn(dat, '       AnisotropyRatio:='    +Ini.ReadString(IniSet, 'AnisotropyRatio',   '1')  +', _');
    WriteLn(dat, '       AnisotropyAngle:='    +Ini.ReadString(IniSet, 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfRadialBasis' then begin
    WriteLn(dat, '       AnisotropyRatio:='    +Ini.ReadString(IniSet, 'AnisotropyRatio',   '1')  +', _');
    WriteLn(dat, '       AnisotropyAngle:='    +Ini.ReadString(IniSet, 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfTriangulation' then begin
    WriteLn(dat, '       AnisotropyRatio:='    +Ini.ReadString(IniSet, 'AnisotropyRatio',   '1')  +', _');
    WriteLn(dat, '       AnisotropyAngle:='    +Ini.ReadString(IniSet, 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfInverseDistanse' then begin
    WriteLn(dat, '       SearchMinData:='      +Ini.ReadString(IniSet, 'SearchMinData',     '16') +', _');
    WriteLn(dat, '       SearchRad1:='         +Ini.ReadString(IniSet, 'SearchRad1',         '1') +', _');
    WriteLn(dat, '       SearchRad2:='         +Ini.Readstring(IniSet, 'SearchRad2',         '1') +', _');
    WriteLn(dat, '       SearchAngle:='        +Ini.ReadString(IniSet, 'SearchAngle',        '0') +', _');
  end;
     WriteLn(dat, '  DupMethod:=srfDupNone, _');
     WriteLn(dat, '  ShowReport:=False, _');
     WriteLn(dat, '  OutGrid:=PathGRD)');
     WriteLn(dat, '');

//создание трансформированного грида
     WriteLn(dat, 'Surf.GridTransform(InGrid:=PathGRD, _');
     WriteLn(dat, '  Operation:=srfGridTransScale, _');
     WriteLn(dat, '  XScale:='+floattostr(kf_int)+', _');  //коэффициент трансформации
     WriteLn(dat, '  YScale:=1, _');
     WriteLn(dat, '  OutGrid:=PathGRD)');
     WriteLn(dat, '');


//сглаживание -> фильтрация
  if Ini.ReadInteger(IniSet, 'Filter', 0)>0 then begin
     WriteLn(dat, 'Surf.GridFilter(InGrid:=PathGRD, _');
		 WriteLn(dat, '  Filter:=srfFilterGaussian, _');
		 WriteLn(dat, '  NumPasses:='+Ini.ReadString(IniSet, 'Filter', '0')+', _');    //число прогонов из формы
		 WriteLn(dat, '  OutGrid:=PathGRD)');
     WriteLn(dat, '');
  end;

//добавление сдвига
    WriteLn(dat, 'Surf.GridTransform(InGrid:=PathGRD, _');
    WriteLn(dat, '  Operation:=srfGridTransOffset, _');
    WriteLn(dat, '  XOffset:='+floattostr(StartDate)+', _');
    WriteLn(dat, '  YOffset:=1, _');
    WriteLn(dat, '  OutGrid:=PathGRD)');
    WriteLn(dat, '');

//бланковка по вернему/нижнему минимальному/максимальному горизонтам
//внутри заданного временного интервала
     WriteLn(dat, 'Surf.GridBlank(InGrid:=PathGRD, _');
     WriteLn(dat, '  BlankFile:=pathBlnFile, _');
     WriteLn(dat, '  Outgrid:=PathGRD, _');
     WriteLn(dat, '  outfmt:=1)');
     WriteLn(dat, '');


 (* Строим основной плот, убираем верхние и боковые метки*)
    WriteLn(dat, 'Set ContourMapFrame=Doc.Shapes.AddContourMap(PathGRD)');
    WriteLn(dat, 'Set Axes = ContourMapFrame.Axes');
    WriteLn(dat, 'Set Axis = Axes("left axis")');
    if Ini.ReadInteger('main', 'depth_units', 0)=0 then
      WriteLn(dat, '    Axis.Title = "Depth, m"') else
      WriteLn(dat, '    Axis.Title = "Depth, dBar"');
    WriteLn(dat, 'Axis.Reverse = True ');
    WriteLn(dat, 'Set Axis = Axes("top axis")');
    WriteLn(dat, 'Axis.MajorTickType = srfTickNone');
    WriteLn(dat, 'Set Axis = Axes("right axis")');
    WriteLn(dat, 'Axis.MajorTickType = srfTickNone');
    WriteLn(dat, '');


 //   WriteLn(dat, 'Set contour1 = ContourMapFrame.Overlays("Contours") ');
 //   WriteLn(dat, '');

//post1->положение узлов на диаграмме
    WriteLn(dat, 'Set PostMap2=Doc.Shapes.AddPostMap(DataFileName:=pathDataFile, _');
    WriteLn(dat, '   xCol:=1, _');  //Реальное время
    WriteLn(dat, '   yCol:=3)');    //Глубина
    WriteLn(dat, 'Set sampleMarks = PostMap2.Overlays(1)');
    WriteLn(dat, '    With SampleMarks');
    WriteLn(dat, '        .LabCol='+inttostr(Column));
    WriteLn(dat, '        .LabelFont.Size=4');
    WriteLn(dat, '        .Symbol.Index=15');
    WriteLn(dat, '        .Symbol.Size=0.03');
    WriteLn(dat, '        .Symbol.Color=srfColorBlue');
    WriteLn(dat, '        .Visible=False');
    WriteLn(dat, '        .LabelAngle=0');
    WriteLn(dat, '    End With');
    WriteLn(dat, '');
    WriteLn(dat, '');


//объединение объектов -> OverlayMaps
    WriteLn(dat, 'Doc.Shapes.SelectAll');
    WriteLn(dat, 'Set NewMap = Doc.Selection.OverlayMaps');
    WriteLn(dat, 'NewMap.xLength=20');
    WriteLn(dat, 'NewMap.yLength=10');

//фон->Background
   // WriteLn(dat, 'NewMap.BackgroundFill.Pattern = "6.25% Black"');
   // WriteLn(dat, 'NewMap.BackgroundFill.ForeColor = srfColorBlack30');

//определение положения левого нижнего угла
    WriteLn(dat, 'L = NewMap.Left');
    WriteLn(dat, 'B = NewMap.top-NewMap.Height');
    WriteLn(dat, 'Set ContourMap = NewMap.Overlays(1)');
    WriteLn(dat, 'With ContourMap ');

//цветная заливка->FillContours
  if Ini.ReadBool(IniSet, 'FillContour', true)=true then
      WriteLn(dat, '  .FillContours = True');

    if (Ini.ReadBool(IniSet, 'UseLVL', false)=true) and
       (FileExists(Ini.ReadString(IniSet, 'lvl',''))=true) then
         WriteLn(dat, '  .Levels.LoadFile("'+Ini.ReadString(IniSet, 'lvl','')+'")');

    if (Ini.ReadBool(IniSet, 'UseCLR', false)=true) and
       (FileExists(Ini.ReadString(IniSet, 'clr',''))=true) then
         WriteLn(dat, '  .FillForegroundColorMap.LoadFile("'+Ini.ReadString(IniSet, 'clr','')+'")');

    WriteLn(dat, '  .ApplyFillToLevels (FirstIndex:=1, NumberToSet:=1, NumberToSkip:=0)');
    WriteLn(dat, '  .LabelLabelDist ='+Ini.ReadString(IniSet, 'LevelToEdgeDist',  '1'));
    WriteLn(dat, '  .LabelEdgeDist  ='+Ini.ReadString(IniSet, 'LevelToLevelDist', '1'));
    WriteLn(dat, '  .LabelTolerance ='+Ini.ReadString(IniSet, 'CurveTolerance',   '15E-1'));
    WriteLn(dat, '  .LabelFont.Size = 6');
    WriteLn(dat, '  .Levels.SetLabelFrequency('+
                      'FirstIndex  :='+Ini.ReadString(IniSet, 'LevelFirst', '1')+','+
                      'NumberToSet :='+Ini.ReadString(IniSet, 'LevelSet',   '1')+','+
                      'NumberToSkip:='+Ini.ReadString(IniSet, 'LevelSkip',  '9')+')');
    if Ini.ReadBool(IniSet, 'ColourScaleShow', true)=true then begin
      WriteLn(dat, '  .ShowColorScale = True');
      WriteLn(dat, '  .ColorScale.Title = "'+VarNameUnits+'"');
      WriteLn(dat, '  .ColorScale.TitlePosition = srfColorScaleTitlePositionRight');
      WriteLn(dat, '  .ColorScale.TitleFont.Size = 10');
      WriteLn(dat, '  .ColorScale.Left = NewMap.Left+NewMap.Width+0.4');
      WriteLn(dat, '  .ColorScale.FrameLine.Style = "Invisible"');
      WriteLn(dat, '  .ColorScale.LabelFrequency = '+Ini.ReadString(IniSet, 'ColourScaleLbFreq',  '1'));
    end;
    WriteLn(dat, 'End With');
    WriteLn(dat, '');


//масштабирование
    WriteLn(dat, 'Diagram.Zoom(srfZoomFitToWindow)');
    WriteLn(dat, 'Diagram.AutoRedraw = True');
    WriteLn(dat, '');
    WriteLn(dat, 'End Sub');
 finally
   Ini.Free;
 end;

 CloseFile(dat);
end;


end.

