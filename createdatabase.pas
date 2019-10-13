unit createdatabase;

interface

uses SysUtils, IBConnection, sqldb, SQLScript;

procedure CreateNewDB(dbname:string);

implementation


procedure CreateNewDB(dbname:string);
Var
DB:TIBConnection;
TR:TSQLTransaction;
ST:TSQLScript;
begin
 DB:=TIBConnection.Create(nil);
 TR:=TSQLTransaction.Create(nil);
 ST:=TSQLScript.Create(nil);

  DB.Transaction:=TR;
  TR.Database:=DB;
  ST.Transaction:=TR;
  ST.Database:=DB;

  DB.DatabaseName:=(dbname);
  DB.UserName:='SYSDBA';
  DB.Password:='masterkey';
  DB.params.Clear;
  DB.params.Add('page_size 16384');
  DB.params.Add('default character set win1251');
  DB.CreateDB;
  DB.Connected:=False;

  DB.LoginPrompt:=False;
  DB.Open;

 (* Заполняем скрипт *)
  //ST.Script.LoadFromFile(ScriptPath);
 With ST.Script do begin
  Clear;
   Add('SET SQL DIALECT 3;');
   Add('');

   // CATALOG
   Add('CREATE TABLE "CATALOG"');
   Add('(');
   Add('  "ID"         INTEGER NOT NULL,');
   Add('  "C_TYPE"     SMALLINT NOT NULL,');
   Add('  "TITLE"      VARCHAR(25) NOT NULL,');
   Add('  "TITLE2"     VARCHAR(15) NOT NULL,');
   Add('  "DATE_BEGIN" DATE NOT NULL,');
   Add('  "DATE_END"   DATE NOT NULL,');
   Add('  "NUMST"      SMALLINT,');
   Add('  "ADDED"      DATE NOT NULL,');
   Add(' PRIMARY KEY ("ID"),');
   Add(' UNIQUE ("C_TYPE", "TITLE", "TITLE2", "DATE_BEGIN", "DATE_END")');
   Add(');');
   Add('');
 {
   // CATALOG_DESCRIPTION
   Add(' CREATE TABLE "CATALOG_DESCRIPTION" ');
   Add('("ID"           SMALLINT NOT NULL, ');
   Add(' "DESCRIPTION"  VARCHAR(30) NOT NULL, ');
   Add(' CONSTRAINT "PK_CATALOG_DESCRIPTION" PRIMARY KEY ("ID"),');
   Add(' CONSTRAINT "UNQ1_CATALOG_DESCRIPTION" UNIQUE ("DESCRIPTION"));');
   Add('');

   // STATION_CATALOG
   Add('CREATE TABLE "STATION_CATALOG"');
   Add('(');
   Add('  "ABSNUM" INTEGER NOT NULL,');
   Add('  "ID"     SMALLINT NOT NULL,');
   Add(' UNIQUE ("ABSNUM", "ID")');
   Add(');');
   Add('');

   // LOG
   Add('CREATE TABLE "LOG"');
   Add('(');
   Add('  "ABSNUM"     INTEGER NOT NULL,');
   Add('  "FIELD"      VARCHAR(8) NOT NULL,');
   Add('  "U_TYPE"     VARCHAR(1) NOT NULL,');
   Add('  "OLD_VAL"    VARCHAR(15) CHARACTER SET UNICODE_FSS,');
   Add('  "NEW_VAL"    VARCHAR(15) CHARACTER SET UNICODE_FSS,');
   Add('  "DATE_TIME"  TIMESTAMP NOT NULL');
   Add(');');
   Add('');

   // METEO
   Add('CREATE TABLE "METEO"');
   Add('(');
   Add('  "ABSNUM"      INTEGER NOT NULL,');
   Add('  "TEMPDRY"     DECIMAL(5, 2),');
   Add('  "TEMPWET"     DECIMAL(5, 2),');
   Add('  "PRESSURE"    DECIMAL(5, 1),');
   Add('  "WINDDIR"     SMALLINT,');
   Add('  "WINDSPEED"   DECIMAL(5, 1),');
   Add('  "CLOUDCOMMON" SMALLINT,');
   Add('  "CLOUDLOW"    SMALLINT,');
   Add('  "CLOUDTYPE"   VARCHAR(20),');
   Add('  "VISIBILITY"  SMALLINT,');
   Add('  "HUMABS"      DECIMAL(4, 1),');
   Add('  "HUMREL"      SMALLINT,');
   Add('  "WAVEHEIGHT"  NUMERIC(5, 1),');
   Add('  "WAVEDIR"     SMALLINT,');
   Add('  "WAVEPERIOD"  SMALLINT,');
   Add('  "SEASTATE"    SMALLINT,');
   Add('  "WEATHER"     SMALLINT,');
   Add('  "WATERCOLOR"  SMALLINT,');
   Add('  "WATERTRANSP" SMALLINT,');
   Add('  "SURFTEMP"    DECIMAL(5, 2),');
   Add('  "SURFSALT"    DECIMAL(5, 2),');
   Add(' UNIQUE ("ABSNUM")');
   Add(');');
   Add('');

   // STATION
   Add(' CREATE TABLE "STATION"');
   Add('(');
   Add('  "ABSNUM"          INTEGER NOT NULL,');
   Add('  "STFLAG"          SMALLINT DEFAULT  0,');
   Add('  "STLAT"           DECIMAL(8, 5) NOT NULL,');
   Add('  "STLON"           DECIMAL(9, 5) NOT NULL,');
   Add('  "STDATE"          DATE NOT NULL,');
   Add('  "STTIME"          TIME NOT NULL,');
   Add('  "STSOURCE"        VARCHAR(12) NOT NULL,');
   Add('  "STVERSION"       SMALLINT NOT NULL,');
   Add('  "STCOUNTRYNAME"   VARCHAR(40) DEFAULT '+QuotedStr('UNKNOWN')+',');
   Add('  "STVESSELNAME"    VARCHAR(40) DEFAULT '+QuotedStr('UNKNOWN')+',');
   Add('  "STDEPTHSOURCE"   INTEGER DEFAULT -9,');
   Add('  "STLASTLEVEL"     SMALLINT DEFAULT -9,');
   Add('  "STDEPTHGRID"     SMALLINT DEFAULT -9,');
   Add('  "STDEPTHGRIDMIN"  SMALLINT DEFAULT -9,');
   Add('  "STDEPTHGRIDMAX"  SMALLINT DEFAULT -9,');
   Add(' PRIMARY KEY ("ABSNUM"),');
   Add(' UNIQUE ("STDATE", "STTIME", "STLAT", "STLON", "STSOURCE", "STVERSION")');
   Add(');');
   Add('');

   // STATION_INFO
   Add('CREATE TABLE "STATION_INFO"');
   Add('(');
   Add('  "ABSNUM"           INTEGER NOT NULL,');
   Add('  "COUNTRYCODE"      VARCHAR(2) DEFAULT '+QuotedStr('')+',');
   Add('  "VESSELCODE"       VARCHAR(4) DEFAULT '+QuotedStr('')+',');
   Add('  "STNUMINCRUISE"    VARCHAR(10) DEFAULT '+QuotedStr('')+',');
   Add('  "PROJECTCODE"      INTEGER DEFAULT -9,');
   Add('  "INSTITUTECODE"    INTEGER DEFAULT -9,');
   Add('  "INSTRUMENT"       INTEGER DEFAULT -9,');
   Add('  "SOURCEUNIQUEID"   VARCHAR(10) DEFAULT '+QuotedStr('')+',');
   Add('  "SOURCEDATAORIGIN" VARCHAR(15) DEFAULT '+QuotedStr('')+',');
   Add('  "VESSELCRUISEID"   VARCHAR(15) DEFAULT '+QuotedStr(''));
   Add(');');
   Add('');

   // P_ALKALINITY
   Add('CREATE TABLE "P_ALKALINITY"');
   Add('(');
   Add('  "ABSNUM"    INTEGER NOT NULL,');
   Add('  "LEVEL_"    DECIMAL(8, 3) NOT NULL,');
   Add('  "VALUE_"    DECIMAL(6, 3) NOT NULL,');
   Add('  "FLAG_"     SMALLINT NOT NULL');
   Add(');');
   Add('');
   // P_CHLOROPHYLL
   Add('CREATE TABLE "P_CHLOROPHYLL"');
   Add('(');
   Add('  "ABSNUM"    INTEGER NOT NULL,');
   Add('  "LEVEL_"    DECIMAL(8, 3) NOT NULL,');
   Add('  "VALUE_"    DECIMAL(5, 3) NOT NULL,');
   Add('  "FLAG_"     SMALLINT NOT NULL');
   Add(');');
   Add('');
   // P_NITRATE
   Add('CREATE TABLE "P_NITRATE"');
   Add('(');
   Add('  "ABSNUM"    INTEGER NOT NULL,');
   Add('  "LEVEL_"    DECIMAL(8, 3) NOT NULL,');
   Add('  "VALUE_"    DECIMAL(6, 2) NOT NULL,');
   Add('  "FLAG_"     SMALLINT NOT NULL');
   Add(');');
   Add('');
   // P_NITRITE
   Add('CREATE TABLE "P_NITRITE"');
   Add('(');
   Add('  "ABSNUM"    INTEGER NOT NULL,');
   Add('  "LEVEL_"    DECIMAL(8, 3) NOT NULL,');
   Add('  "VALUE_"    DECIMAL(5, 2) NOT NULL,');
   Add('  "FLAG_"     SMALLINT NOT NULL');
   Add(');');
   Add('');
   //  P_OXYGEN
   Add('CREATE TABLE "P_OXYGEN"');
   Add('(');
   Add('  "ABSNUM"    INTEGER NOT NULL,');
   Add('  "LEVEL_"    DECIMAL(8, 3) NOT NULL,');
   Add('  "VALUE_"    DECIMAL(5, 3) NOT NULL,');
   Add('  "FLAG_"     SMALLINT NOT NULL');
   Add(');');
   Add('');
   // P_PH
   Add('CREATE TABLE "P_PH"');
   Add('(');
   Add('  "ABSNUM"    INTEGER NOT NULL,');
   Add('  "LEVEL_"    DECIMAL(8, 3) NOT NULL,');
   Add('  "VALUE_"    DECIMAL(5, 2) NOT NULL,');
   Add('  "FLAG_"     SMALLINT NOT NULL');
   Add(');');
   Add('');
   // P_PHOSPHATE
   Add('CREATE TABLE "P_PHOSPHATE"');
   Add('(');
   Add('  "ABSNUM"    INTEGER NOT NULL,');
   Add('  "LEVEL_"    DECIMAL(8, 3) NOT NULL,');
   Add('  "VALUE_"    DECIMAL(5, 2) NOT NULL,');
   Add('  "FLAG_"     SMALLINT NOT NULL');
   Add(');');
   Add('');
   // P_SALINITY
   Add('CREATE TABLE "P_SALINITY"');
   Add('(');
   Add('  "ABSNUM"    INTEGER NOT NULL,');
   Add('  "LEVEL_"    DECIMAL(8, 3) NOT NULL,');
   Add('  "VALUE_"    DECIMAL(6, 4) NOT NULL,');
   Add('  "FLAG_"     SMALLINT NOT NULL');
   Add(');');
   Add('');
   // P_SILICATE
   Add('CREATE TABLE "P_SILICATE"');
   Add('(');
   Add('  "ABSNUM"    INTEGER NOT NULL,');
   Add('  "LEVEL_"    DECIMAL(8, 3) NOT NULL,');
   Add('  "VALUE_"    DECIMAL(6, 2) NOT NULL,');
   Add('  "FLAG_"     SMALLINT NOT NULL');
   Add(');');
   Add('');
   // P_TEMPERATURE
   Add('CREATE TABLE "P_TEMPERATURE"');
   Add('(');
   Add('  "ABSNUM"    INTEGER NOT NULL,');
   Add('  "LEVEL_"    DECIMAL(8, 3) NOT NULL,');
   Add('  "VALUE_"    DECIMAL(6, 4) NOT NULL,');
   Add('  "FLAG_"     SMALLINT NOT NULL');
   Add(');');
   Add('');

   (* Дополнительные таблицы
   CREATE TABLE P_AMMONIUM (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,1) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);


CREATE TABLE P_NITRATENITRITE (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,2) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);




CREATE TABLE P_OXYGENCHEMISTRY (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,2) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);


CREATE TABLE P_SALINITYCHEMISTRY (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,3) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);



CREATE TABLE P_SULPHIDE (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,1) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);



CREATE TABLE P_TEMPERATURECHEMISTRY (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,3) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);

CREATE TABLE P_TOTALNITROGEN (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,1) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);

CREATE TABLE P_TOTALPHOSPHORUS (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,1) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);


CREATE TABLE P_DENSITY (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,3) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);

CREATE TABLE P_DENSITY_C (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,3) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);

CREATE TABLE P_OXYGEN_P (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,2) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);

CREATE TABLE P_NH4 (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,2) NOT NULL,
    FLAG_     SMALLINT NOT NULL
);

CREATE TABLE P_H2S (
    ABSNUM    INTEGER NOT NULL,
    LEVEL_    DECIMAL(6,2) NOT NULL,
    VALUE_    DECIMAL(5,2) NOT NULL,
    FLAG_     SMALLINT NOT NULL
); *)



   // INDEXES - обязательные таблицы
   Add('CREATE INDEX "RDB$LOG" ON "LOG"("ABSNUM");');
   Add('ALTER TABLE "METEO"           ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "P_ALKALINITY"    ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "P_CHLOROPHYLL"   ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "P_NITRATE"       ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "P_NITRITE"       ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "P_OXYGEN"        ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "P_PH"            ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "P_PHOSPHATE"     ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "P_SALINITY"      ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "P_SILICATE"      ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "P_TEMPERATURE"   ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "STATION_CATALOG" ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "STATION_CATALOG" ADD FOREIGN KEY ("ID")     REFERENCES "CATALOG" ("ID")     ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('ALTER TABLE "STATION_INFO"    ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
//   Add('ALTER TABLE "PARAM_UNITS"     ADD FOREIGN KEY ("ABSNUM") REFERENCES "STATION" ("ABSNUM") ON UPDATE CASCADE ON DELETE CASCADE;');
   Add('');
   // GENERATORS
   Add('CREATE GENERATOR "CATNUM";');
   Add('CREATE GENERATOR "STABSNUM";');
   Add('SET TERM ^;');
   Add('');
   // TRIGGERS
   Add('CREATE TRIGGER "ABSNUMCATALOG" FOR "CATALOG"');
   Add('ACTIVE BEFORE INSERT POSITION 0');
   Add('AS');
   Add('begin');
   Add('  New.ID=gen_id(catnum,1);');
   Add('end');
   Add('^');
   Add('');
   Add('CREATE TRIGGER "ABSNUMSTATION" FOR "STATION"');
   Add('ACTIVE BEFORE INSERT POSITION 0');
   Add('AS');
   Add('begin');
   Add('  New.absnum=gen_id(stabsnum,1);');
   Add('end');
   Add('^');
   Add('');
   Add('CREATE TRIGGER "LOGINSERT" FOR "STATION"');
   Add('ACTIVE AFTER INSERT POSITION 0');
   Add('as');
   Add('begin');
   Add('   insert into log (absnum, field, u_type, old_val, new_val, date_time)');
   Add('          values (new.absnum, '+QuotedStr('ABSNUM')+', '+QuotedStr('I')+', null, null,'+QuotedStr('NOW')+');');
   Add('end');
   Add('^');
   Add('');
   Add('CREATE TRIGGER "LOGUPDATE" FOR "STATION"');
   Add('ACTIVE AFTER UPDATE POSITION 0');
   Add('as');
   Add('begin');
   Add('  if ((old.stlat is null and new.stlat is not null) or');
   Add('      (new.stlat is null and old.stlat is not null) or');
   Add('      (new.stlat is not null and old.stlat is not null and new.stlat <> old.stlat)) then');
   Add('     insert into log (absnum, field, u_type, old_val, new_val, date_time)');
   Add('          values (old.absnum, '+QuotedStr('STLAT')+', '+QuotedStr('U')+',old.stlat, new.stlat, '+QuotedStr('NOW')+');');
   Add('  if ((old.stlon is null and new.stlon is not null) or');
   Add('      (new.stlon is null and old.stlon is not null) or');
   Add('      (new.stlon is not null and old.stlon is not null and new.stlon <> old.stlon)) then');
   Add('     insert into log (absnum, field, u_type,old_val, new_val, date_time)');
   Add('          values (old.absnum, '+QuotedStr('STLON')+', '+QuotedStr('U')+',old.stlon, new.stlon, '+QuotedStr('NOW')+');');
   Add('  if ((old.stdate is null and new.stdate is not null) or');
   Add('      (new.stdate is null and old.stdate is not null) or');
   Add('      (new.stdate is not null and old.stdate is not null and new.stdate <> old.stdate)) then');
   Add('      insert into log (absnum, field, u_type,old_val, new_val, date_time)');
   Add('          values (old.absnum, '+QuotedStr('STDATE')+', '+QuotedStr('U')+',old.stdate, new.stdate, '+QuotedStr('NOW')+');');
   Add('  if ((old.sttime is null and new.sttime is not null) or');
   Add('      (new.sttime is null and old.sttime is not null) or');
   Add('      (new.sttime is not null and old.sttime is not null and new.sttime <> old.sttime)) then');
   Add('      insert into log (absnum, field, u_type,old_val, new_val, date_time)');
   Add('           values (old.absnum, '+QuotedStr('STTIME')+', '+QuotedStr('U')+',old.sttime, new.sttime, '+QuotedStr('NOW')+');');
   Add('end');
   Add('^');
   Add('');
   Add('CREATE TRIGGER "LOGDELETE" FOR "STATION"');
   Add('ACTIVE AFTER DELETE POSITION 0');
   Add('As');
   Add('begin');
   Add('  insert into log (absnum, field, u_type, old_val, new_val, date_time)');
   Add('          values (old.absnum, '+QuotedStr('ABSNUM')+', '+QuotedStr('D')+', null, null,'+QuotedStr('NOW')+');');
   Add('end');
   Add('^');   }
   Add('COMMIT WORK ^');
   Add('SET TERM ; ^');

   ST.Script.SaveToFile('X:\script.sql');
 ST.ExecuteScript;

 ST.Free;
 TR.Free;
 DB.Free;
 end;
end;

end.
