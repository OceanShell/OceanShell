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
   '    STATIONID           VARCHAR(50), '+LineEnding+
   '    STATIONID_ORIG      BIGINT, '+LineEnding+
   '    QCFLAG              SMALLINT NOT NULL, '+LineEnding+
   '    STVERSION           SMALLINT NOT NULL, '+LineEnding+
   '    MERGED              SMALLINT DEFAULT 0 NOT NULL, '+LineEnding+
   '    DATE_ADDED          TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_UPDATED        TIMESTAMP, '+LineEnding+
   '    CONSTRAINT STATION_PK PRIMARY KEY (ID) '+LineEnding+
   '); '+LineEnding+

   //   '    SOURCE_ID           BIGINT DEFAULT -9 NOT NULL, '+LineEnding+
//   '    COUNTRY_ID          BIGINT DEFAULT -9 NOT NULL, '+LineEnding+
//   '    PLATFORM_ID         BIGINT DEFAULT -9 NOT NULL, '+LineEnding+
   //   '    INSTRUMENT_ID       BIGINT DEFAULT -9 NOT NULL, '+LineEnding+

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
   'CREATE TABLE "PARAMETER" ('+LineEnding+
   '    ID            BIGINT NOT NULL, '+LineEnding+
   '    TABLENAME     VARCHAR(255) NOT NULL, '+LineEnding+
   '    PARAMETERNAME VARCHAR(255) NOT NULL, '+LineEnding+
   '    DESCRIPTION   VARCHAR(255), '+LineEnding+
   '    CONSTRAINT PARAMETER_PK PRIMARY KEY (ID) '+LineEnding+
   '); '+LineEnding+

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
