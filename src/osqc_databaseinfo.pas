unit osqc_databaseinfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection,

  osmain;

Procedure UpdateDatabaseInfo(DB_main:TIBConnection);

implementation

Procedure UpdateDatabaseInfo(DB_main:TIBConnection);
Var
  DBt:TIBConnection;
  TRt:TSQLTransaction;
  Qt:TSQLQuery;
begin
try
  TRt:=TSQLTransaction.Create(nil);
  DBt:=TIBConnection.Create(nil);
  With DBt do begin
    DatabaseName:=DB_main.DatabaseName;
    UserName:=DB_main.UserName;
    Password:=DB_main.Password;
    Params:=DB_main.Params;
    Transaction:=TRt;
  end;
  TRt.Database:=DBt;

  Qt:=TSQLQuery.Create(nil);
  Qt.Database:=DBt;
  Qt.Transaction:=TRt;

     with Qt do begin
      Close;
        SQL.Clear;
          SQL.Add(' select count(ID) as StCount, ');
          SQL.Add(' min(ID) as IDMin, max(ID) as IDMax, ');
          SQL.Add(' min(CRUISE_ID) as CrIDMin, max(CRUISE_ID) as CrIDMax, ');
          SQL.Add(' min(LATITUDE) as StLatMin, max(LATITUDE) as StLatMax, ');
          SQL.Add(' min(LONGITUDE) as StLonMin, max(LONGITUDE) as StLonMax, ');
          SQL.Add(' min(DATEANDTIME) as StDateMin, ');
          SQL.Add(' max(DATEANDTIME) as StDateMax, ');
          SQL.Add(' min(DATE_ADDED) as StDateAddedMin, ');
          SQL.Add(' max(DATE_ADDED) as StDateAddedMax, ');
          SQL.Add(' min(DATE_UPDATED) as StDateUpdatedMin, ');
          SQL.Add(' max(DATE_UPDATED) as StDateUpdatedMax ');
          SQL.Add(' from STATION');
      Open;
           StationCount   :=FieldByName('StCount').AsInteger;
           StationIDMin   :=FieldByName('IDMin').AsInteger;
           StationIDMax   :=FieldByName('IDMax').AsInteger;
           CruiseIDMin    :=FieldByName('CrIDMin').AsInteger;
           CruiseIDMax    :=FieldByName('CrIDMax').AsInteger;
           StationLatMin  :=FieldByName('StLatMin').AsFloat;
           StationLatMax  :=FieldByName('StLatMax').AsFloat;
           StationLonMin  :=FieldByName('StLonMin').AsFloat;
           StationLonMax  :=FieldByName('StLonMax').AsFloat;
           StationDateMin :=FieldByName('StDateMin').AsDateTime;
           StationDateMax :=FieldByName('StDateMax').AsDateTime;
           StationDateAddedMin :=FieldByName('StDateAddedMin').AsDateTime;
           StationDateAddedMax :=FieldByName('StDateAddedMax').AsDateTime;
           StationDateUpdatedMin :=FieldByName('StDateUpdatedMin').AsDateTime;
           StationDateUpdatedMax :=FieldByName('StDateUpdatedMax').AsDateTime;
      Close;
     end;

     with Qt do begin
       Close;
         SQL.Clear;
         SQL.Add(' select count(ID) as StCount, ');
         SQL.Add(' max(STATIONS_TOTAL) as ST_TOTAL_MAX, ');
         SQL.Add(' max(STATIONS_DATABASE) as ST_DATABASE_MAX, ');
         SQL.Add(' max(STATIONS_DUPLICATES) as ST_DUPLICATES_MAX ');
         SQL.Add(' FROM CRUISE');
       Open;
         CruiseCount:=FieldByName('StCount').AsInteger;
         CruiseStationsTotalMax:=FieldByName('ST_TOTAL_MAX').AsInteger;
         CruiseStationsDatabaseMax:=FieldByName('ST_DATABASE_MAX').AsInteger;
         CruiseStationsDuplicateMax:=FieldByName('ST_DUPLICATES_MAX').AsInteger;
       Close;
     end;

     with Qt do begin
       Close;
         SQL.Clear;
           SQL.Add(' UPDATE OR INSERT INTO DATABASE_INFO ');
           SQL.Add('(ID, STATION_COUNT, STATION_ID_MIN, STATION_ID_MAX, ');
           SQL.Add(' LATITUDE_MIN, LATITUDE_MAX, ');
           SQL.Add(' LONGITUDE_MIN, LONGITUDE_MAX, ');
           SQL.Add(' DATEANDTIME_MIN, DATEANDTIME_MAX, ');
           SQL.Add(' DATE_ADDED_MIN, DATE_ADDED_MAX, ');
           SQL.Add(' DATE_UPDATED_MIN, DATE_UPDATED_MAX, ');
           SQL.Add(' CRUISE_COUNT, CRUISE_ID_MIN, CRUISE_ID_MAX, ');
           SQL.Add(' CRUISE_ST_TOTAL_MAX, CRUISE_ST_DB_MAX, ');
           SQL.Add(' CRUISE_DUPLICATES_MAX) ');
           SQL.Add(' VALUES ');
           SQL.Add('(:ID, :STATION_COUNT, :STATION_ID_MIN, :STATION_ID_MAX, ');
           SQL.Add(' :LATITUDE_MIN, :LATITUDE_MAX, ');
           SQL.Add(' :LONGITUDE_MIN, :LONGITUDE_MAX, ');
           SQL.Add(' :DATEANDTIME_MIN, :DATEANDTIME_MAX, ');
           SQL.Add(' :DATE_ADDED_MIN, :DATE_ADDED_MAX, ');
           SQL.Add(' :DATE_UPDATED_MIN, :DATE_UPDATED_MAX, ');
           SQL.Add(' :CRUISE_COUNT, :CRUISE_ID_MIN, :CRUISE_ID_MAX, ');
           SQL.Add(' :CRUISE_ST_TOTAL_MAX, :CRUISE_ST_DB_MAX, ');
           SQL.Add(' :CRUISE_DUPLICATES_MAX) ');
           SQL.Add(' MATCHING (ID) ');
           ParamByName('ID').AsInteger:=1;
           ParamByName('STATION_COUNT').AsInteger:=StationCount;
           ParamByName('STATION_ID_MIN').AsInteger:=StationIDMin;
           ParamByName('STATION_ID_MAX').AsInteger:=StationIDMax;
           ParamByName('LATITUDE_MIN').AsFloat:=StationLatMin;
           ParamByName('LATITUDE_MAX').AsFloat:=StationLatMax;
           ParamByName('LONGITUDE_MIN').AsFloat:=StationLonMin;
           ParamByName('LONGITUDE_MAX').AsFloat:=StationLonMax;
           ParamByName('DATEANDTIME_MIN').AsDateTime:=StationDateMin;
           ParamByName('DATEANDTIME_MAX').AsDateTime:=StationDateMax;
           ParamByName('DATE_ADDED_MIN').AsDateTime:=StationDateAddedMin;
           ParamByName('DATE_ADDED_MAX').AsDateTime:=StationDateAddedMax;
           ParamByName('DATE_UPDATED_MIN').AsDateTime:=StationDateUpdatedMin;
           ParamByName('DATE_UPDATED_MAX').AsDateTime:=StationDateUpdatedMax;
           ParamByName('CRUISE_COUNT').AsInteger:=CruiseCount;
           ParamByName('CRUISE_ID_MIN').AsInteger:=CruiseIDMin;
           ParamByName('CRUISE_ID_MAX').AsInteger:=CruiseIDMax;
           ParamByName('CRUISE_ST_TOTAL_MAX').AsInteger:=CruiseStationsTotalMax;
           ParamByName('CRUISE_ST_DB_MAX').AsInteger:=CruiseStationsDatabaseMax;
           ParamByName('CRUISE_DUPLICATES_MAX').AsInteger:=CruiseStationsDuplicateMax;
       ExecSQL;
      end;
      Qt.Close;
      Trt.Commit;
finally
  Qt.Free;
  TRt.Free;
  DBt.Free;
end;


end;

end.

