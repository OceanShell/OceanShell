Unit osmap_globctrl;

{$mode objfpc}{$H+}

{ Globe Display Control.

  Copyright (C) 2015 Paul Michell, Michell Computing.

  Modified by Alexander Smirnov (axline@mail.ru)

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by
  the Free Software Foundation; either version 2.1 of the License, or (at your
  option) any later version.

  This library is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
  for more details. }

Interface

Uses
  Classes, SysUtils, Forms, Controls, Graphics, LCLType, Math, IniFiles,
  osmain, dm, osmap_datastreams, osmap_geometry, osmap_wkt, Dialogs,
  Variants, LResources;

Type
  TPointArray = Array Of TPoint;
  TCountryGeometryArray = Array Of T2DCoordinatesArrayArray;

{ A definition of TCoordinates compatible with the Geodesy unit but not requiring it. }
Type
  TCoordinates = Packed Object(osmap_geometry.T3DCoordinates)
    Property Latitude: TCoordinate Read Y Write Y;
    Property Longitude: TCoordinate Read X Write X;
    Property Altitude: TCoordinate Read Z Write Z;
    Property Lat: TCoordinate Read Y Write Y;
    Property Lon: TCoordinate Read X Write X;
  End;

Type
  TGlobeControl = class(TCustomControl)
  Private
    { Private declarations. }
    FBufferBitmap: TBitmap;
    FCenter: TCoordinates;
    FLocation: TCoordinates;
    FMarker: TCoordinates;
    Function Transform(Lat, Lon: TCoordinate; Out P: TPoint): Boolean;
    Procedure ComputeViewParameters;
    Procedure CreateBackBuffer;
    Procedure DrawGlobe;
  Private
    { Private computed view parameters. }
    CX, CY: Integer; { The offset to the control's centre. }
    EZ: Integer; { Screen space view point z depth.}
    GR, GZ: Integer; { Screen space globe radius and z depth. }
    HD2: Integer; {Screen space square of the horizon distance. }
    R: Integer; { The projected radius of the globe. }
    VS: TCoordinate; { The view scaling factor. }
    Pointer_Radius:Integer; {Station pointer size in pixels}
    Color_Pointer_Inner:TColor; {Station pointer color}
    Color_Pointer_Border:TColor; {Station pointer border color}
    Pointer_Radius_Cruise:Integer; {Station pointer size in pixels}
    Color_Pointer_Inner_Cruise:TColor; {Station pointer color}
    Color_Pointer_Border_Cruise:TColor; {Station pointer border color}

    Color_Selection_Cross:TColor; {Selection cross color}
    Color_Map_Background:TColor;
    Color_Globe_Disc: TColor;
    Color_Land:TColor;
    Color_Land_Contour:TColor;
    Zoom_step:Integer; {how fast map zooms in/out }
    Show_Stars:Boolean; {hide/show stars in the background}
  Protected
    { Protected declarations. }
    OX, OY: Integer; { X,Y coordinates of prior mouse event. }
    Function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; Override;
    Procedure DoOnResize; Override;
    Procedure EraseBackground(DC: HDC); Override;
    Procedure KeyDown(var Key: Word; Shift: TShiftState); Override;
    Procedure MouseDown(Button: TMouseButton; Shift:TShiftState; X, Y:Integer); Override;
    Procedure MouseMove(Shift: TShiftState; X, Y: Integer); Override;
    Procedure Paint; Override;
    Procedure AdjustLocation(Lat, Lon: TCoordinate);
    Property BufferBitmap: TBitmap Read FBufferBitmap;
  Public
    { Public declarations. }
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Procedure ReCenter;
    Procedure Refresh;
    Procedure ShowAllStations;
    Procedure ShowSelectedStation;
    Procedure SetLocation(Lat, Lon: TCoordinate);
    Procedure ZoomIn;
    Procedure ZoomOut;
    Procedure ChangeID(ID:integer);
    Procedure CheckSettings;
    Property Center: TCoordinates Read FCenter Write FCenter; { Default view centre in geodesic degrees. }
    Property Location: TCoordinates Read FLocation Write FLocation; { Location of view centre in geodesic degrees. }
    Property Marker: TCoordinates Read FMarker Write FMarker;  { Position of marker in geodesic degrees. }
  End;

Implementation

Var
  CountryData: TCountryGeometryArray;


Constructor TGlobeControl.Create(AOwner: TComponent);
Var
DataStream: TDataStream;
Index, LastIndex: Integer;
Begin
  Inherited Create(AOwner);

  DataStream := TDataStream.Create;
  DataStream.FieldTerminator := #9;
  DataStream.LoadFromFile('00000.csv');

  SetLength(CountryData, DataStream.RecordCount);
  LastIndex := DataStream.RecordCount-1;
  For Index := 0 To LastIndex Do
    Begin
      WKTToMultiPolygon(DataStream.Fields[0], CountryData[Index]);
      DataStream.Next;
    End;
  FreeAndNil(DataStream);

  CreateBackBuffer;

  { Set initial view parameters. }
  EZ := 1000;  //1000
  GZ := 300;   //300
  GR := 1000;  //1000
End;

Destructor TGlobeControl.Destroy;
Begin
  FreeAndNil(FBufferBitmap);
  Inherited Destroy;
End;

Procedure TGlobeControl.ShowAllStations;
Begin
  EZ := 500; //1000
  GZ := 300;
  GR := 500; //1000

  Location.Lat := (SLatMin+SLatMax)/2;
  Location.Lon := (SLonMin+SLonMax)/2;
  Center := Location;

  ReCenter;
end;

Procedure TGlobeControl.ShowSelectedStation;
Begin
  EZ := 1200; //1000
  GZ := 300;
  GR := 1200; //1000

  Location.Lat := frmdm.Q.FieldByName('LATITUDE').AsFloat;
  Location.Lon := frmdm.Q.FieldByName('LONGITUDE').AsFloat;
  Center := Location;

  ReCenter;
end;

Procedure TGlobeControl.ReCenter;
Begin
//  GZ := 300;
  Location := Center;
  AdjustLocation(0, 0);
End;

Procedure TGlobeControl.ZoomIn;
Begin
  if (EZ<1000) and (GZ=Zoom_Step) then begin
    EZ:=1200;
    GR:=1200;
    GZ:=300;
  end;
//  showmessage(inttostr(gz));
  If GZ>Zoom_Step Then
    GZ -= Zoom_Step; //25
  AdjustLocation(0, 0);
End;

Procedure TGlobeControl.ZoomOut;
Begin
  GZ += Zoom_Step;  //25
  AdjustLocation(0, 0);
End;


Procedure TGlobeControl.CheckSettings;
Var
  Ini:TIniFile;
Begin
  Ini := TIniFile.Create(IniFileName);
 try
   Zoom_step     :=Ini.ReadInteger( 'osmap', 'zoom_step',  50);
   Show_Stars     :=Ini.ReadBool   ( 'osmap', 'show_stars', true);

   Pointer_Radius:=Ini.ReadInteger( 'osmap', 'pointer_size', 2)+1;
   Color_Pointer_Inner  :=StringToColor(Ini.ReadString( 'osmap', 'pointer_inner_color',   'clRed'));
   Color_Pointer_Border :=StringToColor(Ini.ReadString( 'osmap', 'pointer_border_color',  'clBlack'));

   Pointer_Radius_Cruise:=Ini.ReadInteger( 'osmap', 'pointer_size_cruise', 2)+1;
   Color_Pointer_Inner_Cruise :=StringToColor(Ini.ReadString( 'osmap', 'pointer_inner_color_cruise',   'clYellow'));
   Color_Pointer_Border_Cruise :=StringToColor(Ini.ReadString( 'osmap', 'pointer_border_color_cruise',  'clBlack'));


   Color_Selection_Cross:=StringToColor(Ini.ReadString( 'osmap', 'selection_cross_color', 'clRed'));
   Color_Map_Background :=StringToColor(Ini.ReadString( 'osmap', 'map_background_color',  'clNavy'));
   Color_Globe_Disc     :=StringToColor(Ini.ReadString( 'osmap', 'globe_disc_color',      'clAqua'));
   Color_Land           :=StringToColor(Ini.ReadString( 'osmap', 'land_color',            '$00D000')); //Light Green
   Color_Land_Contour   :=StringToColor(Ini.ReadString( 'osmap', 'land_contour_color',    '$004000')); //Dark Green
 finally
   Ini.Free;
 end;
 Randomize;
end;

Procedure TGlobeControl.Refresh;
Begin
  ComputeViewParameters;
  DrawGlobe;
  Repaint;
End;

Procedure TGlobeControl.SetLocation(Lat, Lon: TCoordinate);
Begin
  If Lon<-180 Then
    Lon := Lon+360;
  If Lon>180 Then
    Lon := Lon-360;
  If Lat<-90 Then
    Lat := -90;
  If Lat>90 Then
    Lat := 90;
  Location.Lat := Lat;
  Location.Lon := Lon;

  Refresh;
End;

Procedure TGlobeControl.ChangeID(ID:integer);
Begin
 if SCount>0 then begin
   Marker.Lat := frmdm.Q.FieldByName('LATITUDE').AsFloat;
   Marker.Lon := frmdm.Q.FieldByName('LONGITUDE').AsFloat;
 end;
Refresh;
end;

Function TGlobeControl.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
Begin
  If WheelDelta<0 Then
    GZ += Zoom_Step //25
  Else
    If GZ > Zoom_Step Then
      GZ -= Zoom_Step; //25
  AdjustLocation(0, 0);
  Result := Inherited DoMouseWheel(Shift, WheelDelta, MousePos);
End;

Procedure TGlobeControl.DoOnResize;
Begin
  Inherited DoOnResize;
  Refresh;
End;

Procedure TGlobeControl.EraseBackground(DC: HDC);
Begin
  { Do nothing here to avoid unnecessary erasing. }
End;

Procedure TGlobeControl.KeyDown(Var Key: Word; Shift: TShiftState);
Var
  DLon: TCoordinate;
  DLat: TCoordinate;
Begin
  DLon := 0;
  DLat := 0;
  Case Key Of
  vk_Left, vk_NUMPAD4:
    DLon :=  2.5;
  vk_Right, vk_NUMPAD6:
    DLon := -2.5;
  vk_Up, vk_NUMPAD8:
    DLat :=  2.5;
  vk_Down, vk_NUMPAD2:
    DLat := -2.5;
  vk_Add:
    If GZ > Zoom_Step Then
      GZ -= Zoom_Step;
  vk_Subtract:
    GZ += Zoom_Step;
  End;
  AdjustLocation(DLat, DLon);
  Inherited KeyDown(Key, Shift);
End;

Procedure TGlobeControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
  i: integer;
Begin
  OX := X;
  OY := Y;

  If ssLeft In Shift Then
    if cursor=crHandPoint then begin
      for i:=0 to High(MapDataset) do begin
        if (X>=MapDataset[i].x-Pointer_Radius) and (X<=MapDataset[i].x+Pointer_Radius) and
           (Y>=MapDataset[i].y-Pointer_Radius) and (Y<=MapDataset[i].y+Pointer_Radius) then begin
           if frmdm.Q.Locate('ID', MapDataset[i].ID, [])=true then begin
            frmosmain.CDSNavigation;
            break;
           end;
        end;
      end;
     end;

  Inherited MouseDown(Button, Shift, X, Y);
End;


Procedure TGlobeControl.MouseMove(Shift: TShiftState; X, Y: Integer);
Var
  DLat, DLon: TCoordinate;
Begin
 if (FBufferBitmap.Canvas.Pixels[X, Y]=Color_Pointer_Inner) or
    (FBufferBitmap.Canvas.Pixels[X, Y]=Color_Pointer_Inner_Cruise) then
     cursor:=crHandPoint else
     cursor:=crDefault;

  If ssLeft In Shift Then begin
    If (X<>OX) Or (Y<>OY) Then Begin
        DLon := (X-OX)*VS;
        DLat := (Y-OY)*VS;
        AdjustLocation(DLat, DLon);
        Update;
        OX := X;
        OY := Y;
    End;
  End;
  Inherited MouseMove(Shift, X, Y);
End;


Procedure TGlobeControl.Paint;
Begin
  Canvas.Draw(0, 0, BufferBitmap);
  Inherited Paint;
End;


Procedure TGlobeControl.ComputeViewParameters;
Var
  HD: Integer;
  GA: TCoordinate;
Begin
  { Calculate the view scaling factor. }
  VS := GZ/(2*EZ);
  { Calcuate the control centre (CX,CY). }
  CX := Width Div 2;
  CY := Height Div 2;
  { Calculate the projected radius (R) of the globe. }
  GA := ArcSin(GR/(GZ+EZ));
  R := Trunc(EZ*Tan(GA));
  { Calculate the square of the horizon distance. }
  HD := Trunc((GZ+EZ)*Cos(GA));
  HD2 := HD*HD;
End;

Procedure TGlobeControl.CreateBackBuffer;
Begin
  { Create a backbuffer bitmap capable of covering the screen. }
  FBufferBitmap := TBitmap.Create;
  With FBufferBitmap Do
    Begin
      Width := Screen.Width;
      Height := Screen.Height;
      Canvas.Clear;
    End;
End;


Function DistanceSquare(Start, Finish: TPoint): TCoordinate; Inline;
Var
  U, V: TCoordinate;
Begin
  { Calculate the square of the distance between two points. }
  U := Finish.X-Start.X;
  V := Finish.Y-Start.Y;
  Result := U*U+V*V;
End;


Function VertexReduction(Const VertexList: TPointArray; ToleranceSquare: TCoordinate; VertexLoop: Boolean): TPointArray; Inline;
Var
  NextResultIndex: Integer;
  CurrentIndex: Integer;
  NodeIndex, LastNodeIndex: Integer;
Begin
  LastNodeIndex := High(VertexList);
  { Initially, allow for all nodes in the result. }
  SetLength(Result, LastNodeIndex+1);
  Result[0] := VertexList[0];
  NextResultIndex := 1;
  CurrentIndex := 0;
  { For vertex loops, only consider the last node if it is also over the threshold distance from the start node. }
  If VertexLoop Then
    If DistanceSquare(VertexList[LastNodeIndex], VertexList[0])<ToleranceSquare Then
     LastNodeIndex := LastNodeIndex-1;
  { Remove nodes within the tolerance distance from the prior node. }
  For NodeIndex := 1 To LastNodeIndex Do
    If DistanceSquare(VertexList[NodeIndex], VertexList[CurrentIndex])>=ToleranceSquare Then
      Begin
        CurrentIndex := NodeIndex;
        Result[NextResultIndex] := VertexList[NodeIndex];
        Inc(NextResultIndex);
      End;
  { Reduce the size of the result to fit the actual number of nodes remaining. }
  SetLength(Result, NextResultIndex);
End;


Procedure TGlobeControl.DrawGlobe;
Var
  ID, Cr_ID,cur_id, i, k, X, Y: integer;
  P: TPoint;
  Lon: TCoordinate;
  Lat: TCoordinate;
  StepLon: TCoordinate;
  StepLat: TCoordinate;
  Index, LastIndex: Integer;
  Procedure DrawMultiPolygon(MultiPoly: T2DCoordinatesArrayArray);
  Var
    Poly: Array Of TPoint;
    SimplifiedPoly: Array Of TPoint;
    RingIndex, LastRingIndex: Integer;
    NodeIndex, LastNodeIndex: Integer;
    PolyIndex: Integer;
    RenderPolygon: Boolean;
    H: TCoordinate;
  Begin
    LastRingIndex := High(MultiPoly);
    For RingIndex := 0 To LastRingIndex Do
      Begin
        RenderPolygon := False;
        PolyIndex := 0;
        LastNodeIndex := High(MultiPoly[RingIndex]);
        SetLength(Poly, Length(MultiPoly[RingIndex]));
        For NodeIndex := 0 To LastNodeIndex Do
          Begin
            Lon := MultiPoly[RingIndex, NodeIndex].X;
            Lat := MultiPoly[RingIndex, NodeIndex].Y;
            If Transform(Lat, Lon, Poly[PolyIndex]) Then
              Begin
                RenderPolygon := True;
                Inc(PolyIndex);
              End
            Else
              With Poly[PolyIndex] Do
                Begin
                  X := X-CX;
                  Y := CY-Y;
                  H := Sqrt(X*X+Y*Y);
                  If H<>0 Then { Avoid divide by zero conditions and skip the node. }
                    Begin
                      X := CX+Trunc(X*R/H);
                      Y := CY-Trunc(Y*R/H);
                      Inc(PolyIndex);
                    End;
                End;
          End;
        If RenderPolygon Then
          Begin
            If PolyIndex<>Length(Poly) Then
              SetLength(Poly, PolyIndex);
            SimplifiedPoly := VertexReduction(Poly, 2, True);
            If Length(SimplifiedPoly)>=3 Then
              FBufferBitmap.Canvas.Polygon(SimplifiedPoly);
          End;
      End;
  End;
Begin
 //showmessage('9.1');
  With FBufferBitmap.Canvas Do
    Begin
      { Clear the background. }
      Brush.Style := bsSolid;
      Brush.Color := Color_Map_background; //clNavy;
      Clear;
      { Draw stars }
      if Show_Stars then begin
       Pen.Color   := clWhite;
       Pen.Style   := psSolid;
       Brush.Color := clWhite;
       for k:=1 to 1000 do begin
         X:=Random(FBufferBitmap.Width);
         Y:=Random(FBufferBitmap.Height);
           Ellipse(X, Y, X+2, Y+2);
       end;
      end;

 //      showmessage('9.2');
      { Draw the globe's disc. }
      Brush.Color := Color_Globe_Disc; //clAqua;
      Pen.Style := psSolid;
      Pen.Color := clBlack;
      EllipseC(CX, CY, R, R);

  //    showmessage('9.21');
      { Draw country polygons. }
      Brush.Style := bsSolid;
      Brush.Color := Color_Land; //TColor($00D000); { Light Green }
      Pen.Style := psSolid;
      Pen.Color := Color_Land_Contour; //TColor($004000); { Dark Green }
      LastIndex := High(CountryData);
      For Index := 0 To LastIndex Do DrawMultiPolygon(CountryData[Index]);

  //     showmessage('9.22');
      { Draw Lat/Lon grid. }
      Pen.Color := TColor($606060); { Dark Grey }
      Pen.Style := psDot;
      Brush.Style := bsClear;
      StepLon := 15;
      StepLat := 2.5*VS;
      Lon := -180;
      While Lon<=180 Do
        Begin
          Lat := -89;
          Transform(Lat, Lon, P);
          MoveTo(P);
          While Lat<89 Do
            Begin
              Lat += StepLat;
              If Lat>89 Then
                Lat := 89;
              If Transform(Lat, Lon, P) Then
                LineTo(P)
              Else
                MoveTo(P);
            End;
          Lon += StepLon;
        End;
      StepLon := 2.5*VS;
      StepLat := 10;
      Lat := -80;
      While Lat<=80 Do
        Begin
          Lon := -180;
          Transform(Lat, Lon, P);
          MoveTo(P);
          While Lon<180 Do
            Begin
              Lon += StepLon;
              If Transform(Lat, Lon, P) Then
                LineTo(P)
              Else
                MoveTo(P);
            End;
          Lat += StepLat;
        End;

  //     showmessage('9.3');
     { Draw stations }
     pen.Style := psSolid;

      if SCount>0 then begin
       cur_id:=frmdm.Q.FieldByName('ID').AsInteger;

       for k:=0 to high(MapDataset)-1 do begin

         ID:=MapDataset[k].ID;
         Cr_ID:=MapDataset[k].Cruise_ID;
         Lat:=MapDataset[k].Latitude;
         Lon:=MapDataset[k].Longitude;


            { If transformation successful }
            if Transform(Lat, Lon, P) then begin
             if Cr_ID=frmdm.QCruise.FieldByName('ID').Value then begin
                brush.Color := Color_Pointer_Inner_cruise;
                pen.Color   := Color_Pointer_Border_cruise;

                if Pointer_Radius_cruise=1 then pen.Color:=brush.Color;

                Ellipse(P.X-Pointer_Radius_cruise,
                        P.Y-Pointer_Radius_cruise,
                        P.X+Pointer_Radius_cruise,
                        P.Y+Pointer_Radius_cruise);
             end else begin
                brush.Color := Color_Pointer_Inner;
                pen.Color   := Color_Pointer_Border;

                if Pointer_Radius=1 then pen.Color:=brush.Color;

                Ellipse(P.X-Pointer_Radius,
                        P.Y-Pointer_Radius,
                        P.X+Pointer_Radius,
                        P.Y+Pointer_Radius);
             end;

             MapDataset[k].x:=P.X;
             MapDataset[k].y:=P.Y;
            end;
        end;

       frmdm.Q.Locate('ID', cur_id, []);


      { Draw marker cross. }
        If Transform(Marker.Lat, Marker.Lon, P) Then
        Begin
          Pen.Color := Color_Selection_Cross;
          Pen.Style := psSolid;
          Brush.Style := bsClear;
          MoveTo(P.X-1, P.Y+8);
          LineTo(P.X-1, P.Y+3);
          MoveTo(P.X, P.Y+8);
          LineTo(P.X, P.Y+2);
          MoveTo(P.X+1, P.Y+8);
          LineTo(P.X+1, P.Y+3);
          MoveTo(P.X-1, P.Y-8);
          LineTo(P.X-1, P.Y-3);
          MoveTo(P.X, P.Y-8);
          LineTo(P.X, P.Y-2);
          MoveTo(P.X+1, P.Y-8);
          LineTo(P.X+1, P.Y-3);
          MoveTo(P.X+8, P.Y-1);
          LineTo(P.X+3, P.Y-1);
          MoveTo(P.X+8, P.Y);
          LineTo(P.X+2, P.Y);
          MoveTo(P.X+8, P.Y+1);
          LineTo(P.X+3, P.Y+1);
          MoveTo(P.X-8, P.Y-1);
          LineTo(P.X-3, P.Y-1);
          MoveTo(P.X-8, P.Y);
          LineTo(P.X-2, P.Y);
          MoveTo(P.X-8, P.Y+1);
          LineTo(P.X-3, P.Y+1);
        End;
      End; // if Q is not empty
    End;

End;


Function TGlobeControl.Transform(Lat, Lon: TCoordinate; Out P: TPoint): Boolean;
Var
  { Extended is explicitly used as SinCos requires this data type on some platforms. }
  XP, YP, ZP: Extended;
  IR, NYP: Extended;
  S: Extended;
  DLon: Extended;
  SinLat, CosLat: Extended;
  SinDLon, CosDLon: Extended;
  SinVLat, CosVLat: Extended;
Begin
  DLon := Lon-Location.Lon;
  SinCos(DegToRad(Lat), SinLat, CosLat);
  SinCos(DegToRad(DLon), SinDLon, CosDLon);
  SinCos(DegToRad(Location.Lat), SinVLat, CosVLat);
  IR := (GR*CosLat);
  XP := (IR*SinDLon);
  YP := (GR*SinLat);
  ZP := -(IR*CosDLon);
  NYP := (YP*CosVLat+ZP*SinVLat);
  ZP := (ZP*CosVLat-YP*SinVLat);
  YP := NYP;
  ZP := GZ+ZP;
  S := EZ/(EZ+ZP);
  P.X := CX+Trunc(XP*S);
  P.Y := CY-Trunc(YP*S);
  Result := ((XP*XP+YP*YP+(ZP+EZ)*(ZP+EZ))<=HD2);
End;

Procedure TGlobeControl.AdjustLocation(Lat, Lon: TCoordinate);
Begin
  SetLocation(Location.Lat+(Lat/8), Location.Lon-(Lon/8));
End;


End.

