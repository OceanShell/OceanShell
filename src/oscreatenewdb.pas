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
   (* STATION *)
   'CREATE TABLE STATION ('+LineEnding+
   '    ID                  BIGINT NOT NULL, '+LineEnding+
   '    LATITUDE            DECIMAL(8,5) NOT NULL, '+LineEnding+
   '    LONGITUDE           DECIMAL(9,5) NOT NULL, '+LineEnding+
   '    DATEANDTIME         TIMESTAMP NOT NULL, '+LineEnding+
   '    BOTTOMDEPTH         INTEGER, '+LineEnding+
   '    LASTLEVEL_M         INTEGER, '+LineEnding+
   '    LASTLEVEL_DBAR      INTEGER, '+LineEnding+
   '    CRUISE_ID           BIGINT NOT NULL, '+LineEnding+
   '    INSTRUMENT_ID       BIGINT NOT NULL, '+LineEnding+
   '    ST_NUMBER_ORIGIN    VARCHAR(50), '+LineEnding+
   '    ST_ID_ORIGIN        BIGINT, '+LineEnding+
   '    CAST_NUMBER         SMALLINT DEFAULT 1 NOT NULL, '+LineEnding+
   '    QCFLAG              SMALLINT NOT NULL, '+LineEnding+
   '    STVERSION           SMALLINT NOT NULL, '+LineEnding+
   '    MERGED              SMALLINT DEFAULT 0 NOT NULL, '+LineEnding+
   '    DATE_ADDED          TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_UPDATED        TIMESTAMP, '+LineEnding+
   '    CONSTRAINT STATION_PK PRIMARY KEY (ID) '+LineEnding+
   '); '+LineEnding+

   '   CREATE TABLE CRUISE ( '+LineEnding+
   '       ID               BIGINT NOT NULL, '+LineEnding+
   '       PLATFORM_ID      BIGINT DEFAULT 1 NOT NULL, '+LineEnding+
   '       CRUISE_NUMBER    VARCHAR(100), '+LineEnding+
   '       DATE_START       DATE NOT NULL, '+LineEnding+
   '       DATE_END         DATE NOT NULL, '+LineEnding+
   '       STATIONS_AMOUNT  BIGINT, '+LineEnding+
   '       COUNTRY_ID       BIGINT DEFAULT 488, '+LineEnding+
   '       PROJECT_ID       BIGINT DEFAULT 445 NOT NULL, '+LineEnding+
   '       INSTITUTE_ID     BIGINT DEFAULT 1 NOT NULL, '+LineEnding+
   '       "PI"             VARCHAR(255) DEFAULT -9 NOT NULL, '+LineEnding+
   '       NOTES            BLOB SUB_TYPE 1 SEGMENT SIZE 16384, '+LineEnding+
   '       DATE_ADDED       TIMESTAMP NOT NULL, '+LineEnding+
   '       DATE_UPDATED     TIMESTAMP '+LineEnding+
   '    CONSTRAINT CRUISE_PK PRIMARY KEY (ID) '+LineEnding+
   ');

   '   CREATE TABLE COUNTRY ( '+LineEnding+
   '       ID            BIGINT NOT NULL, '+LineEnding+
   '       NODC_CODE     VARCHAR(4), '+LineEnding+
   '       ISO3166_CODE  VARCHAR(2) NOT NULL, '+LineEnding+
   '       NAME          VARCHAR(50) NOT NULL, '+LineEnding+
   '       DATE_ADDED    TIMESTAMP NOT NULL, '+LineEnding+
   '       DATE_UPDATED  TIMESTAMP '+LineEnding+
   '    CONSTRAINT COUNTRY_PK PRIMARY KEY (ID) '+LineEnding+
   ');


   '   CREATE TABLE INSTITUTE (
   '       ID            BIGINT NOT NULL,
   '       NODC_CODE     VARCHAR(4),
   '       WOD_ID        BIGINT DEFAULT -9,
   '       NAME          VARCHAR(255) NOT NULL,
   '       NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384,
   '       DATE_ADDED    TIMESTAMP NOT NULL,
   '       DATE_UPDATED  TIMESTAMP
);


CREATE TABLE INSTRUMENT (
    ID            BIGINT NOT NULL,
    WOD_ID        BIGINT DEFAULT -9 NOT NULL,
    NAME          VARCHAR(255) NOT NULL,
    NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384,
    DATE_ADDED    TIMESTAMP NOT NULL,
    DATE_UPDATED  TIMESTAMP
);


CREATE TABLE PROJECT (
    ID            BIGINT NOT NULL,
    WOD_ID        BIGINT DEFAULT -9 NOT NULL,
    NAME          VARCHAR(255) NOT NULL,
    NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384,
    DATE_ADDED    TIMESTAMP NOT NULL,
    DATE_UPDATED  TIMESTAMP
);


CREATE TABLE SOURCE (
    ID            BIGINT NOT NULL,
    NAME          VARCHAR(255),
    ID_MIN        BIGINT,
    ID_MAX        BIGINT,
    NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384,
    DATE_ADDED    TIMESTAMP NOT NULL,
    DATE_UPDATED  TIMESTAMP
);


CREATE TABLE UNITS (
    ID            BIGINT NOT NULL,
    NAME_SHORT    VARCHAR(20) NOT NULL,
    NAME          VARCHAR(255),
    "LENGTH"      SMALLINT,
    SCALE         SMALLINT,
    NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384,
    DATE_ADDED    TIMESTAMP NOT NULL,
    DATE_UPDATED  TIMESTAMP
);


   (* ENTRY *)
   'CREATE TABLE ENTRY ('+LineEnding+
   '    ID               BIGINT NOT NULL, '+LineEnding+
   '    ENTRIES_TYPE_ID  BIGINT NOT NULL, '+LineEnding+
   '    TITLE            VARCHAR(100) NOT NULL, '+LineEnding+
   '    DATE_BEGIN       TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_END         TIMESTAMP NOT NULL, '+LineEnding+
   '    STATIONS_NUMBER  BIGINT, '+LineEnding+
   '    DATE_ADDED       TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_UPDATED     TIMESTAMP, '+LineEnding+
   '    CONSTRAINT ENTRY_PK PRIMARY KEY (ID) '+LineEnding+
   '); '+LineEnding+

   (* ENTRY_TYPE *)
   'CREATE TABLE ENTRY_TYPE ('+LineEnding+
   '    ID           BIGINT NOT NULL, '+LineEnding+
   '    NAME         VARCHAR(255) NOT NULL, '+LineEnding+
   '    DESCRIPTION  BLOB SUB_TYPE 1 SEGMENT SIZE 16384, '+LineEnding+
   '    CONSTRAINT ENTRY_TYPE_PK PRIMARY KEY (ID) '+LineEnding+
   '); '+LineEnding+

   (* STATION_ENTRY *)
   'CREATE TABLE STATION_ENTRY ('+LineEnding+
   '    STATION_ID  BIGINT NOT NULL, '+LineEnding+
   '    ENTRY_ID    BIGINT NOT NULL '+LineEnding+
   '); '+LineEnding+

   (* METEO *)
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

   (* PARAMETERS *)
   'CREATE TABLE DATABASE_TABLES ('+LineEnding+
   '    ID            BIGINT NOT NULL, '+LineEnding+
   '    TABLENAME     VARCHAR(255) NOT NULL, '+LineEnding+
   '    VARIABLENAME  VARCHAR(255) NOT NULL, '+LineEnding+
   '    DESCRIPTION   VARCHAR(255), '+LineEnding+
   '    CONSTRAINT DATABASE_TABLES_PK PRIMARY KEY (ID) '+LineEnding+
   '); '+LineEnding+

   'ALTER TABLE STATION ADD CONSTRAINT UNQ1_STATION UNIQUE (LATITUDE,LONGITUDE,DATEANDTIME,CAST_NUMBER,STVERSION); '+LineEnding+
   'ALTER TABLE STATION ADD CONSTRAINT FK_STATION FOREIGN KEY (STATION_ID) REFERENCES CRUISE (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE METEO ADD CONSTRAINT FK_METEO FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE ENTRY ADD CONSTRAINT FK_ENTRY FOREIGN KEY (ENTRIES_TYPE_ID) REFERENCES ENTRY_TYPE (ID); '+LineEnding+
   'ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_1 FOREIGN KEY (STATION_ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_2 FOREIGN KEY (ENTRY_ID) REFERENCES ENTRY (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+

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

    //DB.DatabaseName:=(dbname);
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
