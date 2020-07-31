unit surfer_field;

{$mode objfpc}{$H+}

interface


uses sysutils, IniFiles, dialogs, osmain, procedures;


procedure GetFieldScript(src: string; //full path to the data file
                         varnameunits: string; //name of the variable and its units
                         column: integer; //column to plot
                         ncols, nrows: integer; //# of columns and rows for interpolation
                         XMin, XMax, Ymin, YMax:real; //region limits
                         preset: string; //name of color preset (e.g. "Bathymetry")
                         clr: string; //path to predefined clr path
                         isreversed: boolean //reverse color scale
                         );


implementation


procedure GetFieldScript(src: string; //full path to the data file
                         varnameunits: string; //name of the variable and its units
                         column: integer; //column to plot
                         ncols, nrows: integer; //# of columns and rows for interpolation
                         XMin, XMax, Ymin, YMax:real; //region limits
                         preset: string; //name of color preset (e.g. "Bathymetry")
                         clr: string; //path to predefined clr path
                         isreversed: boolean //reverse color scale
                         );
Var
 Ini:TIniFile;
 f_scr, f_out:text;
 k, c:integer;
 FieldPath, IntMethod, contour, avunit, IniSet, levice, PolarGrd:string;
 grd, srf: string;
 lon, lat, x, y, val1, searchrad1, searchrad2:real;
 XL, YL: string;
 coastaline_gsb, coastaline_bln: string;
begin
 IniSet:='field';

 coastaline_gsb:=GlobalSupportPath+PathDelim+'bln'+PathDelim+'World.gsb';
 coastaline_bln:=GlobalSupportPath+PathDelim+'bln'+PathDelim+'World.bln';

 FieldPath:=ExtractFilePath(src); //Path to data
 grd:=ChangeFileExt(src, '.grd');
 srf:=ChangeFileExt(Src, '.srf');


 AssignFile(f_scr, FieldPath+'script.bas'); rewrite(f_scr);  // script file
 Ini := TIniFile.Create(IniFileName); // settings from file

 IntMethod:=Ini.ReadString   (IniSet, 'Algorithm', 'srfKriging');
 try
   WriteLn(f_scr, 'Sub Main');
   WriteLn(f_scr, 'Dim Surfer, Diagram, Doc As Object');
   WriteLn(f_scr, 'pathcoastaline_gsb ="' +coastaline_gsb+'"');
   WriteLn(f_scr, 'pathcoastaline_bln ="' +coastaline_bln+'"');
   WriteLn(f_scr, 'pathDataFile ="' +src+'"');
   WriteLn(f_scr, 'pathDataGrid ="' +grd+'"');
   WriteLn(f_scr, '');

   WriteLn(f_scr, 'Set Surfer=CreateObject("Surfer.Application")');
   WriteLn(f_scr, '    Surfer.Visible = True');
   WriteLn(f_scr, '');

   WriteLn(f_scr, 'Set Doc=Surfer.Documents.Add');
   WriteLn(f_scr, '    Doc.PageSetup.Orientation = srfLandscape'); // two plots
   WriteLn(f_scr, 'Set Diagram = Doc.Windows(1)');
   WriteLn(f_scr, '    Diagram.AutoRedraw = False');
   WriteLn(f_scr, '');

   (* Гридируем данные *)
    WriteLn(f_scr, 'Surfer.GridData(DataFile:=pathDataFile, _');
    WriteLn(f_scr, '       xCol:=1, _');
    WriteLn(f_scr, '       yCol:=2, _');
    WriteLn(f_scr, '       zCol:='+inttostr(column)+', _');
    WriteLn(f_scr, '       Algorithm:='        +IntMethod+', _');
    WriteLn(f_scr, '       NumCols:='          +inttostr(ncols)+', _');
    WriteLn(f_scr, '       Numrows:='          +inttostr(nrows)+', _');

(* Настройки для различных методов интерполяции *)
  if IntMethod='srfKriging'  then begin
    WriteLn(f_scr, '       KrigType:='         +Ini.ReadString(IniSet, 'KrigType',          'srfKrigPoint')+', _');
    WriteLn(f_scr, '       KrigDriftType:='    +Ini.ReadString(IniSet, 'KrigDriftType',     'srfDriftNone')+', _');
    if Ini.ReadBool(IniSet, 'SearchEnable', true)=true then begin
     WriteLn(f_scr, '       SearchEnable:=1, _');  //not Ini.ReadBool(IniSet, 'SearchEnable',       true);
     WriteLn(f_scr, '       SearchNumSectors:=' +Ini.ReadString(IniSet, 'SearchNumSectors',   '4') +', _');
     WriteLn(f_scr, '       SearchMinData:='    +Ini.ReadString(IniSet, 'SearchMinData',     '16') +', _');
     WriteLn(f_scr, '       SearchMaxData:='    +Ini.ReadString(IniSet, 'SearchMaxData',     '64') +', _');
     WriteLn(f_scr, '       SearchDataPerSect:='+Ini.ReadString(IniSet, 'SearchDataPerSect',  '8') +', _');
     WriteLn(f_scr, '       SearchMaxEmpty:='   +Ini.ReadString(IniSet, 'SearchMaxEmpty',     '3') +', _');
     WriteLn(f_scr, '       SearchRad1:='       +Ini.ReadString(IniSet, 'SearchRad1',         '1') +', _');
     WriteLn(f_scr, '       SearchRad2:='       +Ini.ReadString(IniSet, 'SearchRad2',         '1') +', _');
     WriteLn(f_scr, '       SearchAngle:='      +Ini.ReadString(IniSet, 'SearchAngle',        '0') +', _');
    end;
  end;
  if IntMethod='srfInverseDistanse' then begin
    WriteLn(f_scr, '       SearchEnable:='       +Ini.ReadString(IniSet, 'SearchEnable',      '0')  +', _');
    WriteLn(f_scr, '       SearchNumSectors:='   +Ini.ReadString(IniSet, 'SearchNumSectors',  '4')  +', _');
    WriteLn(f_scr, '       SearchMinData:='      +Ini.ReadString(IniSet, 'SearchMinData',     '16') +', _');
    WriteLn(f_scr, '       SearchMaxData:='      +Ini.ReadString(IniSet, 'SearchMaxData',     '64') +', _');
    WriteLn(f_scr, '       SearchDataPerSect:='  +Ini.ReadString(IniSet, 'SearchDataPerSect', '8')  +', _');
    WriteLn(f_scr, '       SearchMaxEmpty:='     +Ini.ReadString(IniSet, 'SearchMaxEmpty',    '3')  +', _');
    WriteLn(f_scr, '       SearchRad1:='         +Ini.ReadString(IniSet, 'SearchRad1',        '1')  +', _');
    WriteLn(f_scr, '       SearchRad2:='         +Ini.ReadString(IniSet, 'SearchRad2',        '1')  +', _');
    WriteLn(f_scr, '       SearchAngle:='        +Ini.ReadString(IniSet, 'SearchAngle',       '0')  +', _');
    WriteLn(f_scr, '       AnisotropyRatio:='    +Ini.ReadString(IniSet, 'AnisotropyRatio',   '1')  +', _');
    WriteLn(f_scr, '       AnisotropyAngle:='    +Ini.ReadString(IniSet, 'AnisotropyAngle',   '0')  +', _');
    WriteLn(f_scr, '       IDPower:='            +Ini.ReadString(IniSet, 'IDPower',           '2')  +', _');
    WriteLn(f_scr, '       IDSmoothing:='        +Ini.ReadString(IniSet, 'IDSmoothing',       '0')  +', _');
  end;
  if IntMethod='srfNaturalNeighbor' then begin
    WriteLn(f_scr, '       AnisotropyRatio:='    +Ini.ReadString(IniSet, 'AnisotropyRatio',   '1')  +', _');
    WriteLn(f_scr, '       AnisotropyAngle:='    +Ini.ReadString(IniSet, 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfNearestNeighbor' then begin
    WriteLn(f_scr, '       SearchRad1:='         +Ini.ReadString(IniSet, 'SearchRad1',        '1')  +', _');
    WriteLn(f_scr, '       SearchRad2:='         +Ini.ReadString(IniSet, 'SearchRad2',        '1')  +', _');
    WriteLn(f_scr, '       SearchAngle:='        +Ini.ReadString(IniSet, 'SearchAngle',       '0')  +', _');
  end;
  if IntMethod='srfMinCurvature' then begin
    WriteLn(f_scr, '       MCMaxResidual:='      +Ini.ReadString(IniSet, 'MCMaxResidual',     '1E-9')+', _');
    WriteLn(f_scr, '       MCMaxIterations:='    +Ini.ReadString(IniSet, 'MCMaxIterations',   '1E+5')+', _');
    WriteLn(f_scr, '       MCInternalTension:='  +Ini.ReadString(IniSet, 'MCInternalTension', '1')  +', _');
    WriteLn(f_scr, '       MCBoundaryTension:='  +Ini.ReadString(IniSet, 'MCBoundaryTension', '0')  +', _');
    WriteLn(f_scr, '       MCRelaxationFactor:=' +Ini.ReadString(IniSet, 'MCRelaxationFactor','0')  +', _');
    WriteLn(f_scr, '       AnisotropyRatio:='    +Ini.ReadString(IniSet, 'AnisotropyRatio',   '1')  +', _');
    WriteLn(f_scr, '       AnisotropyAngle:='    +Ini.ReadString(IniSet, 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfRadialBasis' then begin
    WriteLn(f_scr, '       AnisotropyRatio:='    +Ini.ReadString(IniSet, 'AnisotropyRatio',   '1')  +', _');
    WriteLn(f_scr, '       AnisotropyAngle:='    +Ini.ReadString(IniSet, 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfTriangulation' then begin
    WriteLn(f_scr, '       AnisotropyRatio:='    +Ini.ReadString(IniSet, 'AnisotropyRatio',   '1')  +', _');
    WriteLn(f_scr, '       AnisotropyAngle:='    +Ini.ReadString(IniSet, 'AnisotropyAngle',   '0')  +', _');
  end;
  if IntMethod='srfInverseDistanse' then begin
    WriteLn(f_scr, '       SearchMinData:='      +Ini.ReadString(IniSet, 'SearchMinData',     '16') +', _');
    WriteLn(f_scr, '       SearchRad1:='         +Ini.ReadString(IniSet, 'SearchRad1',         '1') +', _');
    WriteLn(f_scr, '       SearchRad2:='         +Ini.Readstring(IniSet, 'SearchRad2',         '1') +', _');
    WriteLn(f_scr, '       SearchAngle:='        +Ini.ReadString(IniSet, 'SearchAngle',        '0') +', _');
  end;
    WriteLn(f_scr, '       DupMethod:=srfDupNone, _');
    WriteLn(f_scr, '       ExclusionFilter:="z=' +Ini.ReadString(IniSet, 'MissingVal', '-9999')+'", _');
    WriteLn(f_scr, '       ShowReport:=False, _');
    WriteLn(f_scr, '       OutGrid:=PathDataGrid)');
    WriteLn(f_scr, '');

    (* blanking by coastaline *)
    WriteLn(f_scr, 'Surfer.GridBlank(InGrid:=PathDataGrid, _');
    WriteLn(f_scr, '       BlankFile:=pathcoastaline_bln, _');
    WriteLn(f_scr, '       OutGrid:=PathDataGrid, _');
    WriteLn(f_scr, '       OutFmt:=1)');
    WriteLn(f_scr, '');

    (* Filtering *)
   if Ini.ReadInteger(IniSet, 'Filter', 0)>0 then begin
    WriteLn(f_scr, 'Surfer.GridFilter(InGrid:=PathDataGrid, _');
		WriteLn(f_scr, '  Filter:=srfFilterGaussian, _');
		WriteLn(f_scr, '  NumPasses:='+Ini.ReadString(IniSet, 'Filter', '0')+', _');    //число прогонов из формы
		WriteLn(f_scr, '  OutGrid:=PathDataGrid)');
    WriteLn(f_scr, '');
   end;

   (* Вставляем основной контур *)
   WriteLn(f_scr, 'Set ContourMap=Doc.Shapes.AddContourMap(PathDataGrid)');
   WriteLn(f_scr, 'Set Axes = ContourMap.Axes');

   (* Убираем верхние и боковые метки с основного плота*)
   WriteLn(f_scr, 'Set Axis = Axes("top axis")');
   WriteLn(f_scr, 'Axis.ShowLabels=False');
   WriteLn(f_scr, 'Axis.AxisLine.ForeColorRGBA.Color = srfColorBlack50');
   WriteLn(f_scr, 'Axis.MajorTickLength=0');
   WriteLn(f_scr, 'Axis.LabelFont.Size=8');
   WriteLn(f_scr, 'Axis.LabelFormat.Postfix="'+#176+'"');
   WriteLn(f_scr, 'Axis.LabelFont.Color= srfColorBlack');

   WriteLn(f_scr, '');

   WriteLn(f_scr, 'Set Axis = Axes("bottom axis")');
   WriteLn(f_scr, 'Axis.ShowLabels=True');
   WriteLn(f_scr, 'Axis.MajorGridLine.ForeColorRGBA.Color =srfColorBlack');
   WriteLn(f_scr, 'Axis.AxisLine.ForeColorRGBA.Color = srfColorBlack50');
   WriteLn(f_scr, 'Axis.MajorTickLength=1E-1');
   WriteLn(f_scr, 'Axis.LabelFont.Size=8');
   WriteLn(f_scr, 'Axis.LabelFormat.Postfix="'+#176+'"');
   WriteLn(f_scr, 'Axis.LabelFont.Color= srfColorBlack');
   WriteLn(f_scr, '');

   WriteLn(f_scr, 'Set Axis = Axes("right axis")');
   WriteLn(f_scr, 'Axis.ShowLabels=False');
   WriteLn(f_scr, 'Axis.AxisLine.ForeColorRGBA.Color = srfColorBlack50');
   WriteLn(f_scr, 'Axis.MajorTickLength=0');
   WriteLn(f_scr, 'Axis.LabelFont.Size=8');
   WriteLn(f_scr, 'Axis.LabelFormat.Postfix="'+#176+'"');
   WriteLn(f_scr, 'Axis.LabelFont.Color= srfColorBlack');   //srfColorBlack50
   WriteLn(f_scr, '');

   WriteLn(f_scr, 'Set Axis = Axes("left axis")');
   WriteLn(f_scr, 'Axis.ShowLabels=True');
   WriteLn(f_scr, 'Axis.MajorGridLine.ForeColorRGBA.Color =srfColorBlack');
   WriteLn(f_scr, 'Axis.AxisLine.ForeColorRGBA.Color = srfColorBlack50');
   WriteLn(f_scr, 'Axis.MajorTickLength=1E-1');
   WriteLn(f_scr, 'Axis.LabelFont.Size=8');
   WriteLn(f_scr, 'Axis.LabelFormat.Postfix="'+#176+'"');
   WriteLn(f_scr, 'Axis.LabelFont.Color= srfColorBlack');


    (* Пост со значениями*)
   WriteLn(f_scr, 'Set PostMap=Doc.Shapes.AddPostMap(DataFileName:=pathDataFile, _');
   WriteLn(f_scr, 'xCol:=1, _');
   WriteLn(f_scr, 'yCol:=2)');
   WriteLn(f_scr, 'Set sampleMarks = PostMap.Overlays(1)');
   WriteLn(f_scr, 'With SampleMarks');
   WriteLn(f_scr, '  .Visible=False');
   WriteLn(f_scr, '  .LabelFont.Size=2');
   WriteLn(f_scr, '  .Symbol.Index=12');
   WriteLn(f_scr, '  .Symbol.Size=0.02');
   WriteLn(f_scr, '  .Symbol.Color=srfColorPurple');
   WriteLn(f_scr, '  .LabelAngle=0');
   WriteLn(f_scr, '  .CoordinateSystem = "World Geodetic System 1984"');
   WriteLn(f_scr, 'End With');
   WriteLn(f_scr, '');


   (* Определяем размеры поля *)
   WriteLn(f_scr, 'Doc.Shapes.SelectAll');
   WriteLn(f_scr, 'Set Border = Doc.Selection.OverlayMaps');
   WriteLn(f_scr, 'X1='+Floattostr(XMin));
   WriteLn(f_scr, 'X2='+Floattostr(XMax));
   WriteLn(f_scr, 'Y1='+Floattostr(YMin));
   WriteLn(f_scr, 'Y2='+Floattostr(YMax));
   WriteLn(f_scr, '');


   (* Карта - подложка: берега на нулевой изобате *)
   WriteLn(f_scr, 'Set BaseMap=Doc.Shapes.AddBaseMap(pathcoastaline_gsb)');
   WriteLn(f_scr, 'Set BaseMap1 = BaseMap.Overlays(1)');
    if Ini.ReadBool(IniSet, 'ContBackground', true)=true then begin
     WriteLn(f_scr, 'BaseMap1.Fill.Pattern="Solid"');
     WriteLn(f_scr, 'BaseMap1.Fill.ForeColor=srfColorBlack40');
     WriteLn(f_scr, 'BaseMap1.Line.ForeColorRGBA.Color=srfColorBlack80');
     WriteLn(f_scr, '');
    end;

   (* Объединяем и задаём общие свойства *)
   WriteLn(f_scr, 'Doc.Shapes.SelectAll');
   WriteLn(f_scr, 'Set NewMap = Doc.Selection.OverlayMaps');
   WriteLn(f_scr, 'With NewMap');
   WriteLn(f_scr, '  .SetLimits(xMin:=X1, xMax:=X2, yMin:=Y1, yMax:=Y2)');
   WriteLn(f_scr, '  .xLength = '+Ini.ReadString(IniSet, 'PlotWidth',  '22'));
   WriteLn(f_scr, '  .yLength = '+Ini.ReadString(IniSet, 'PlotHeight', '16'));
   WriteLn(f_scr, '  .Top= 19');
   WriteLn(f_scr, '  .Left= 2');
   WriteLn(f_scr, '  .BackgroundFill.Pattern = "10 Percent"');
   WriteLn(f_scr, '  .BackgroundFill.ForeColor = srfGold');
   WriteLn(f_scr, '    L = .Left');
   WriteLn(f_scr, '    B = .Top-.Height');
   WriteLn(f_scr, 'End With');
   WriteLn(f_scr, '');

   WriteLn(f_scr, 'Set ContourMap = NewMap.Overlays(1)');
   WriteLn(f_scr, 'With ContourMap');
   WriteLn(f_scr, '  .FillContours = True');
   if preset<>'' then
     WriteLn(f_scr, '  .FillForegroundColorMap.LoadPreset ("'+preset+'")');
   if clr<>'' then
     WriteLn(f_scr, '  .FillForegroundColorMap.LoadFile("'+clr+'")');
   if isreversed=true then
     WriteLn(f_scr, '  .FillForegroundColorMap.Reverse');
   WriteLn(f_scr, '  .ApplyFillToLevels (FirstIndex:=1, NumberToSet:=1, NumberToSkip:=0)');
   WriteLn(f_scr, '  .LabelLabelDist ='+Ini.ReadString(IniSet, 'LevelToEdgeDist',  '1'));
   WriteLn(f_scr, '  .LabelEdgeDist  ='+Ini.ReadString(IniSet, 'LevelToLevelDist', '1'));
   WriteLn(f_scr, '  .LabelTolerance ='+Ini.ReadString(IniSet, 'CurveTolerance',   '15E-1'));
   WriteLn(f_scr, '  .LabelFont.Size = 6');
   WriteLn(f_scr, '  .Levels.SetLabelFrequency('+
                     'FirstIndex  :='+Ini.ReadString(IniSet, 'LevelFirst', '1')+','+
                     'NumberToSet :='+Ini.ReadString(IniSet, 'LevelSet',   '1')+','+
                     'NumberToSkip:='+Ini.ReadString(IniSet, 'LevelSkip',  '9')+')');
   if Ini.ReadBool(IniSet, 'ColourScaleShow', true)=true then begin
     WriteLn(f_scr, '  .ShowColorScale = True');
     WriteLn(f_scr, '  .ColorScale.Title = "'+VarNameUnits+'"');
     WriteLn(f_scr, '  .ColorScale.TitlePosition = srfColorScaleTitlePositionRight');
     WriteLn(f_scr, '  .ColorScale.TitleFont.Size = 10');
     WriteLn(f_scr, '  .ColorScale.Left = NewMap.Left+NewMap.Width+0.4');
     WriteLn(f_scr, '  .ColorScale.FrameLine.Style = "Invisible"');
     WriteLn(f_scr, '  .ColorScale.LabelFrequency = '+Ini.ReadString(IniSet, 'ColourScaleLbFreq',  '1'));
   end;
   WriteLn(f_scr, 'End With');
   WriteLn(f_scr, '');

   {
  // Вставляем легенду
 if legend=true then begin
   WriteLn(f_scr, '');
   WriteLn(f_scr, ' Set Rectangle = Doc.Shapes.AddRectangle(Left:=13.8, Top:=19.8, Right:=17.45, Bottom:=18.10)');
   WriteLn(f_scr, '     Rectangle.Fill.Transparent = False');
   WriteLn(f_scr, '     Rectangle.Fill.Pattern = "Solid"');
   WriteLn(f_scr, '     Rectangle.Fill.ForeColorRGBA.Color = srfColorWhite');
   WriteLn(f_scr, '     Rectangle.Line.Style = "Solid"');
   WriteLn(f_scr, '     Rectangle.Line.ForeColorRGBA.Color = srfColorBlack50');
   WriteLn(f_scr, '');
   WriteLn(f_scr, ' Set Rectangle = Doc.Shapes.AddRectangle(Left:=13.85, Top:=19.75, Right:=17.40, Bottom:=18.15)');
   WriteLn(f_scr, '     Rectangle.Fill.Transparent = False');
   WriteLn(f_scr, '     Rectangle.Fill.Pattern = "Solid"');
   WriteLn(f_scr, '     Rectangle.Fill.ForeColorRGBA.Color = srfColorWhite');
   WriteLn(f_scr, '     Rectangle.Line.Style = "Solid"');
   WriteLn(f_scr, '     Rectangle.Line.ForeColorRGBA.Color = srfColorBlack50');
   WriteLn(f_scr, '');
   WriteLn(f_scr, ' Set Label =Doc.Shapes.AddText(x:=14.77, y:=19.70, Text:="'+avpar+' '+avunit+'")');
   WriteLn(f_scr, '     Label.Font.Face = "Arial"');
   WriteLn(f_scr, '     Label.Font.Size=7');
   WriteLn(f_scr, '     Label.Font.Bold=true');
   WriteLn(f_scr, '     Label.Font.ForeColorRGBA.Color = srfColorBlack80');
   WriteLn(f_scr, '');
   WriteLn(f_scr, ' Set Label =Doc.Shapes.AddText(x:=14.55, y:=19.40, Text:="'+avper+' mean: var. '+cvar+'")');
   WriteLn(f_scr, '     Label.Font.Face = "Arial"');
   WriteLn(f_scr, '     Label.Font.Size=7');
   WriteLn(f_scr, '     Label.Font.ForeColorRGBA.Color = srfColorBlack80');
   WriteLn(f_scr, '');
   WriteLn(f_scr, ' Set Label =Doc.Shapes.AddText(x:=14.10, y:=19.10, Text:="Time period: '+period+'")');
   WriteLn(f_scr, '     Label.Font.Face = "Arial"');
   WriteLn(f_scr, '     Label.Font.Size=7');
   WriteLn(f_scr, '     Label.Font.ForeColorRGBA.Color = srfColorBlack80');
   WriteLn(f_scr, '');
   WriteLn(f_scr, ' Set Label =Doc.Shapes.AddText(x:=14.95, y:=18.80, Text:="Depth: '+inttostr(depth)+' m")');
   WriteLn(f_scr, '     Label.Font.Face = "Arial"');
   WriteLn(f_scr, '     Label.Font.Size=7');
   WriteLn(f_scr, '     Label.Font.ForeColorRGBA.Color = srfColorBlack80');
   WriteLn(f_scr, '');
    if cvar='A' then begin
      WriteLn(f_scr, ' Set Label =Doc.Shapes.AddText(x:=14.25, y:=18.50, Text:="Number of stations: '+inttostr(stnum)+'")');
      WriteLn(f_scr, '     Label.Font.Face = "Arial"');
      WriteLn(f_scr, '     Label.Font.Size=7');
      WriteLn(f_scr, '     Label.Font.ForeColorRGBA.Color = srfColorBlack80');
    end;
 end;   }


   WriteLn(f_scr, 'Diagram.Zoom(srfZoomFitToWindow)');
   WriteLn(f_scr, 'Diagram.AutoRedraw = True');


   WriteLn(f_scr, 'Doc.SaveAs(FileName:="'+srf+'")');
   WriteLn(f_scr, 'End Sub');

 finally
   Ini.Free; // close settings file
   CloseFile(f_scr); // close script file
 end;
end;


end.

