unit oscreatenewdb;

interface

uses SysUtils, IBConnection, DB, sqldb, SQLScript, Dialogs;

procedure CreateNewDB(dbname:string);

implementation


procedure CreateNewDB(dbname:string);
Var
DB:TIBConnection;
TR:TSQLTransaction;
ST:TSQLScript;

(* Script for main tables *)
const ScriptText=

   'CREATE TABLE COUNTRY ('+LineEnding+
   '   ID            BIGINT NOT NULL,'+LineEnding+
   '   NODC_CODE     VARCHAR(4) CHARACTER SET UTF8,'+LineEnding+
   '   ISO3166_CODE  VARCHAR(2) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '   NAME          VARCHAR(50) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '   DATE_ADDED    TIMESTAMP NOT NULL,'+LineEnding+
   '   DATE_UPDATED  TIMESTAMP,'+LineEnding+
   '   NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 8192 CHARACTER SET UTF8'+LineEnding+
   ');'+LineEnding+


   'CREATE TABLE CRUISE ('+LineEnding+
   '   ID               BIGINT NOT NULL,'+LineEnding+
   '   PLATFORM_ID      BIGINT DEFAULT -9 NOT NULL,'+LineEnding+
   '   SOURCE_ID        BIGINT DEFAULT 1 NOT NULL,'+LineEnding+
   '   INSTITUTE_ID     BIGINT DEFAULT 1 NOT NULL,'+LineEnding+
   '   PROJECT_ID       BIGINT DEFAULT 445 NOT NULL,'+LineEnding+
   '   EXPOCODE         VARCHAR(50) CHARACTER SET UTF8,'+LineEnding+
   '   CRUISE_NUMBER    VARCHAR(100) CHARACTER SET UTF8,'+LineEnding+
   '   DATE_START       TIMESTAMP NOT NULL,'+LineEnding+
   '   DATE_END         TIMESTAMP NOT NULL,'+LineEnding+
   '   STATIONS_AMOUNT  BIGINT,'+LineEnding+
   '   "PI"             VARCHAR(255) CHARACTER SET UTF8 DEFAULT -9,'+LineEnding+
   '   NOTES            BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '   DATE_ADDED       TIMESTAMP NOT NULL,'+LineEnding+
   '   DATE_UPDATED     TIMESTAMP,'+LineEnding+
   '   COMPLETE         BOOLEAN DEFAULT false NOT NULL'+LineEnding+
   ');'+LineEnding+

   'CREATE TABLE DATABASE_TABLES ('+LineEnding+
   '    ID                BIGINT NOT NULL,'+LineEnding+
   '    NAME_TABLE        VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    NAME              VARCHAR(255) CHARACTER SET UTF8,'+LineEnding+
   '    UNITS_ID_DEFAULT  BIGINT DEFAULT 2,'+LineEnding+
   '    NOTES             BLOB SUB_TYPE 1 SEGMENT SIZE 8192 CHARACTER SET UTF8'+LineEnding+
   ');'+LineEnding+

   'CREATE TABLE ENTRY ('+LineEnding+
   '    ID               BIGINT NOT NULL, '+LineEnding+
   '    ENTRY_TYPE_ID    BIGINT NOT NULL, '+LineEnding+
   '    TITLE            VARCHAR(100) NOT NULL, '+LineEnding+
   '    DATE_START       TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_END         TIMESTAMP NOT NULL, '+LineEnding+
   '    STATIONS_AMOUNT  BIGINT, '+LineEnding+
   '    NOTES            BLOB SUB_TYPE 1 SEGMENT SIZE 16384  CHARACTER SET UTF8, '+LineEnding+
   '    DATE_ADDED       TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_UPDATED     TIMESTAMP '+LineEnding+
   '); '+LineEnding+

   'CREATE TABLE ENTRY_TYPE ('+LineEnding+
   '    ID           BIGINT NOT NULL, '+LineEnding+
   '    NAME         VARCHAR(255) NOT NULL, '+LineEnding+
   '    DESCRIPTION  BLOB SUB_TYPE 1 SEGMENT SIZE 16384  CHARACTER SET UTF8'+LineEnding+
   '); '+LineEnding+


   'CREATE TABLE INSTITUTE ('+LineEnding+
   '    ID            BIGINT NOT NULL,'+LineEnding+
   '    NODC_CODE     VARCHAR(4) CHARACTER SET UTF8,'+LineEnding+
   '    WOD_ID        BIGINT DEFAULT -9,'+LineEnding+
   '    NAME          VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    NAME_FULL     VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    DATE_ADDED    TIMESTAMP NOT NULL,'+LineEnding+
   '    DATE_UPDATED  TIMESTAMP'+LineEnding+
   ');'+LineEnding+


   'CREATE TABLE INSTRUMENT ('+LineEnding+
   '    ID            BIGINT NOT NULL,'+LineEnding+
   '    WOD_ID        BIGINT DEFAULT -9 NOT NULL,'+LineEnding+
   '    NAME          VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    DATE_ADDED    TIMESTAMP NOT NULL,'+LineEnding+
   '    DATE_UPDATED  TIMESTAMP'+LineEnding+
   ');'+LineEnding+

   'CREATE TABLE METEO ('+LineEnding+
   '    ID           BIGINT NOT NULL, '+LineEnding+
   '    TEMPDRY      DECIMAL(5,2), '+LineEnding+
   '    TEMPWET      DECIMAL(5,2), '+LineEnding+
   '    PRESSURE     DECIMAL(5,1), '+LineEnding+
   '    WINDDIR      SMALLINT, '    +LineEnding+
   '    WINDSPEED    DECIMAL(5,1), '+LineEnding+
   '    CLOUDCOMMON  SMALLINT, '    +LineEnding+
   '    CLOUDLOW     SMALLINT, '    +LineEnding+
   '    CLOUDTYPE    VARCHAR(20), ' +LineEnding+
   '    VISIBILITY   SMALLINT, '    +LineEnding+
   '    HUMABS       DECIMAL(4,1), '+LineEnding+
   '    HUMREL       SMALLINT, '    +LineEnding+
   '    WAVEHEIGHT   DECIMAL(5,1), '+LineEnding+
   '    WAVEDIR      SMALLINT, '    +LineEnding+
   '    WAVEPERIOD   SMALLINT, '    +LineEnding+
   '    SEASTATE     SMALLINT, '    +LineEnding+
   '    WEATHER      SMALLINT, '    +LineEnding+
   '    WATERCOLOR   SMALLINT, '    +LineEnding+
   '    WATERTRANSP  SMALLINT, '    +LineEnding+
   '    SURFTEMP     DECIMAL(5,2), '+LineEnding+
   '    SURFSALT     DECIMAL(5,2) ' +LineEnding+
   '); '+LineEnding+

   'CREATE TABLE PLATFORM ( '+LineEnding+
   '    ID            BIGINT NOT NULL,'+LineEnding+
   '    NODC_CODE     VARCHAR(4) CHARACTER SET UTF8,'+LineEnding+
   '    WOD_ID        BIGINT DEFAULT -9,'+LineEnding+
   '    IMO_ID        INTEGER DEFAULT -9,'+LineEnding+
   '    CALLSIGN      VARCHAR(20) CHARACTER SET UTF8,'+LineEnding+
   '    NAME          VARCHAR(50) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    NAME_NATIVE   VARCHAR(50) CHARACTER SET UTF8,'+LineEnding+
   '    COUNTRY_ID    BIGINT DEFAULT 0 NOT NULL,'+LineEnding+
   '    NOTES_ICES    BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    NOTES_WOD     BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    DATE_ADDED    TIMESTAMP NOT NULL,'+LineEnding+
   '    DATE_UPDATED  TIMESTAMP'+LineEnding+
   ');'+LineEnding+


   'CREATE TABLE PROJECT ('+LineEnding+
   '    ID            BIGINT NOT NULL,'+LineEnding+
   '    WOD_ID        BIGINT DEFAULT -9 NOT NULL,'+LineEnding+
   '    NAME          VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    NAME_FULL     VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    DATE_ADDED    TIMESTAMP NOT NULL,'+LineEnding+
   '    DATE_UPDATED  TIMESTAMP'+LineEnding+
   ');'+LineEnding+


   'CREATE TABLE SOURCE ( '+LineEnding+
   '    ID              BIGINT NOT NULL,'+LineEnding+
   '    NAME            VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    STATION_ID_MIN  BIGINT,'+LineEnding+
   '    STATION_ID_MAX  BIGINT,'+LineEnding+
   '    NOTES           BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    DATE_ADDED      TIMESTAMP NOT NULL,'+LineEnding+
   '    DATE_UPDATED    TIMESTAMP'+LineEnding+
   ');'+LineEnding+


   'CREATE TABLE STATION ( '+LineEnding+
   '   ID                BIGINT NOT NULL,'+LineEnding+
   '   LATITUDE          DECIMAL(8,5) NOT NULL,'+LineEnding+
   '   LONGITUDE         DECIMAL(9,5) NOT NULL,'+LineEnding+
   '   DATEANDTIME       TIMESTAMP NOT NULL,'+LineEnding+
   '   BOTTOMDEPTH       INTEGER,'+LineEnding+
   '   LASTLEVEL_M       INTEGER,'+LineEnding+
   '   LASTLEVEL_DBAR    INTEGER,'+LineEnding+
   '   CRUISE_ID         BIGINT NOT NULL,'+LineEnding+
   '   ST_NUMBER_ORIGIN  VARCHAR(50) CHARACTER SET UTF8,'+LineEnding+
   '   ST_ID_ORIGIN      BIGINT,'+LineEnding+
   '   CAST_NUMBER       SMALLINT DEFAULT 1 NOT NULL,'+LineEnding+
   '   QCFLAG            SMALLINT NOT NULL,'+LineEnding+
   '   STVERSION         SMALLINT NOT NULL,'+LineEnding+
   '   MERGED            BOOLEAN DEFAULT false NOT NULL,'+LineEnding+
   '   DUPLICATE         BOOLEAN DEFAULT false NOT NULL,'+LineEnding+
   '   ACCESSION_NUMBER  BIGINT,'+LineEnding+
   '   DATE_ADDED        TIMESTAMP NOT NULL,'+LineEnding+
   '   DATE_UPDATED      TIMESTAMP'+LineEnding+
   ');'+LineEnding+

   'CREATE TABLE STATION_ENTRY ('+LineEnding+
   '    STATION_ID  BIGINT NOT NULL, '+LineEnding+
   '    ENTRY_ID    BIGINT NOT NULL '+LineEnding+
   ');'+LineEnding+

   'CREATE TABLE UNITS ('+LineEnding+
   '   ID            BIGINT NOT NULL,'+LineEnding+
   '   NAME_SHORT    VARCHAR(20) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '   NAME          VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '   "LENGTH"      SMALLINT,'+LineEnding+
   '   SCALE         SMALLINT,'+LineEnding+
   '   NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '   DATE_ADDED    TIMESTAMP NOT NULL,'+LineEnding+
   '   DATE_UPDATED  TIMESTAMP'+LineEnding+
   ');'+LineEnding+

   //UNIQUE
   'ALTER TABLE ENTRY ADD CONSTRAINT UNQ1_ENTRY UNIQUE (ENTRY_TYPE_ID, TITLE, DATE_START, DATE_END);'+LineEnding+
   'ALTER TABLE STATION ADD CONSTRAINT UNQ1_STATION UNIQUE (LATITUDE, LONGITUDE, DATEANDTIME, CAST_NUMBER, STVERSION);'+LineEnding+
   'ALTER TABLE UNITS ADD CONSTRAINT UNQ1_UNITS UNIQUE (NAME_SHORT, NAME);'+LineEnding+

   //PRIMARY
   'ALTER TABLE COUNTRY ADD CONSTRAINT PK_COUNTRY_1 PRIMARY KEY (ID);'+LineEnding+
   'ALTER TABLE CRUISE ADD CONSTRAINT PK_CRUISE_1 PRIMARY KEY (ID);'+LineEnding+
   'ALTER TABLE DATABASE_TABLES ADD CONSTRAINT DATABASE_TABLES_PK PRIMARY KEY (ID);'+LineEnding+
   'ALTER TABLE ENTRY ADD CONSTRAINT ENTRY_PK PRIMARY KEY (ID);'+LineEnding+
   'ALTER TABLE ENTRY_TYPE ADD CONSTRAINT ENTRY_TYPE_PK PRIMARY KEY (ID);'+LineEnding+
   'ALTER TABLE INSTITUTE ADD CONSTRAINT PK_INSTITUTE_1 PRIMARY KEY (ID);'+LineEnding+
   'ALTER TABLE INSTRUMENT ADD CONSTRAINT PK_INSTRUMENT_1 PRIMARY KEY (ID);'+LineEnding+
   'ALTER TABLE PLATFORM ADD CONSTRAINT PK_PLATFORM_1 PRIMARY KEY (ID);'+LineEnding+
   'ALTER TABLE PROJECT ADD CONSTRAINT PK_PROJECT_1 PRIMARY KEY (ID);'+LineEnding+
   'ALTER TABLE SOURCE ADD CONSTRAINT PK_SOURCE_1 PRIMARY KEY (ID);'+LineEnding+
   'ALTER TABLE STATION ADD CONSTRAINT STATION_PK PRIMARY KEY (ID);'+LineEnding+
   'ALTER TABLE UNITS ADD CONSTRAINT PK_UNITS_1 PRIMARY KEY (ID);'+LineEnding+

   //FOREIGN
   'ALTER TABLE CRUISE ADD CONSTRAINT FK_CRUISE_1 FOREIGN KEY (PLATFORM_ID) REFERENCES PLATFORM (ID); '+LineEnding+
   //'ALTER TABLE CRUISE ADD CONSTRAINT FK_CRUISE_2 FOREIGN KEY (COUNTRY_ID) REFERENCES COUNTRY (ID); '+LineEnding+
   'ALTER TABLE CRUISE ADD CONSTRAINT FK_CRUISE_3 FOREIGN KEY (SOURCE_ID) REFERENCES SOURCE (ID); '+LineEnding+
   'ALTER TABLE CRUISE ADD CONSTRAINT FK_CRUISE_4 FOREIGN KEY (INSTITUTE_ID) REFERENCES INSTITUTE (ID); '+LineEnding+
   'ALTER TABLE CRUISE ADD CONSTRAINT FK_CRUISE_5 FOREIGN KEY (PROJECT_ID) REFERENCES PROJECT (ID); '+LineEnding+
   'ALTER TABLE METEO ADD CONSTRAINT FK_METEO FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE ENTRY ADD CONSTRAINT FK_ENTRY FOREIGN KEY (ENTRY_TYPE_ID) REFERENCES ENTRY_TYPE (ID); '+LineEnding+
   'ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_1 FOREIGN KEY (STATION_ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_2 FOREIGN KEY (ENTRY_ID) REFERENCES ENTRY (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE STATION ADD CONSTRAINT FK_STATION_1 FOREIGN KEY (CRUISE_ID) REFERENCES CRUISE (ID) ON DELETE CASCADE ON UPDATE CASCADE;'+LineEnding+
  // 'ALTER TABLE STATION ADD CONSTRAINT FK_STATION_2 FOREIGN KEY (INSTRUMENT_ID) REFERENCES INSTRUMENT (ID) ON DELETE CASCADE ON UPDATE CASCADE;'+LineEnding+

   'COMMIT WORK '+LineEnding+
   'SET TERM ; '+LineEnding;

begin



// showmessage(ScriptText);
 try
   DB:=TIBConnection.Create(nil);
   TR:=TSQLTransaction.Create(nil);
   ST:=TSQLScript.Create(nil);

    DB.Transaction:=TR;
    TR.Database:=DB;
    ST.Transaction:=TR;
    ST.Database:=DB;
    ST.CommentsInSQL:=false;

    DB.DatabaseName:=(dbname);
    DB.UserName:='SYSDBA';
    DB.Password:='masterkey';
     With DB.Params do begin
      Clear;
       Add('SET SQL DIALECT 3');
       Add('SET NAMES UTF8');
       Add('PAGE_SIZE 16384');
       Add('DEFAULT CHARACTER SET UTF8 COLLATION UTF8');
     end;
    DB.CreateDB;
    DB.Connected:=False;
    DB.LoginPrompt:=False;
    DB.Open;

    ST.Script.Text:=ScriptText;
    ST.UseCommit:=true;
    ST.UseSetTerm:=true; // for Firebird ONLY
    ST.CommentsInSQL:=false;
   // St.Script.SaveToFile('X:\test.sql');
     try
      ST.Execute;
      TR.Commit;
     except
      on E: EDataBaseError do begin
        ShowMessage('Error running script: '+E.Message);
        TR.Rollback;
      end;
     end;
 finally
  ST.Free;
  TR.Free;
  DB.Free;
 end;
end;

end.
