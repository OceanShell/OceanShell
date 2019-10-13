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

const ScriptText=
   'CREATE TABLE ENTRY '+LineEnding+
   '( '+LineEnding+
   '    ID               BIGINT NOT NULL, '+LineEnding+
   '    ENTRIES_TYPE_ID  BIGINT NOT NULL, '+LineEnding+
   '    TITLE            VARCHAR(100) NOT NULL, '+LineEnding+
   '    DATE_BEGIN       TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_END         TIMESTAMP NOT NULL, '+LineEnding+
   '    STATIONS_NUMBER  BIGINT, '+LineEnding+
   '    DATE_ADDED       TIMESTAMP, '+LineEnding+
   '    CONSTRAINT ENTRY_PK PRIMARY KEY (ID) '+LineEnding+
   '); '+LineEnding+


   {  Add('CREATE TABLE ENTRY_TYPE');
   Add('(');
   Add('    ID           BIGINT NOT NULL,');
   Add('    NAME         VARCHAR(255) NOT NULL,');
   Add('    DESCRIPTION  BLOB SUB_TYPE 1 SEGMENT SIZE 16384');
   Add('    CONSTRAINT ENTRY_TYPE_PK PRIMARY KEY (ID)');
   Add(');');
   Add('');

   Add('CREATE TABLE METEO (');
   Add('    ID           BIGINT NOT NULL,');
   Add('    TEMPDRY      DECIMAL(5,2),');
   Add('    TEMPWET      DECIMAL(5,2),');
   Add('    PRESSURE     DECIMAL(5,1),');
   Add('    WINDDIR      SMALLINT,');
   Add('    WINDSPEED    NUMERIC(5,1),');
   Add('    CLOUDCOMMON  SMALLINT,');
   Add('    CLOUDLOW     SMALLINT,');
   Add('    CLOUDTYPE    VARCHAR(20),');
   Add('    VISIBILITY   SMALLINT,');
   Add('    HUMABS       DECIMAL(4,1),');
   Add('    HUMREL       SMALLINT,');
   Add('    WAVEHEIGHT   NUMERIC(5,1),');
   Add('    WAVEDIR      SMALLINT,');
   Add('    WAVEPERIOD   SMALLINT,');
   Add('    SEASTATE     SMALLINT,');
   Add('    WEATHER      SMALLINT,');
   Add('    WATERCOLOR   SMALLINT,');
   Add('    WATERTRANSP  SMALLINT,');
   Add('    SURFTEMP     DECIMAL(5,2),');
   Add('    SURFSALT     DECIMAL(5,2)');
   Add(');');
   Add('');
   Add('CREATE TABLE P_TEMPERATURE_BOTTLE (');
   Add('    ID             BIGINT NOT NULL,');
   Add('    LEVEL_         NUMERIC(9,4) NOT NULL,');
   Add('    VALUE_         DECIMAL(6,4) NOT NULL,');
   Add('    QCFLAG_ODB     SMALLINT NOT NULL,');
   Add('    QCFLAG_SOURCE  SMALLINT,');
   Add('    BOTTLE_NUMBER  SMALLINT,');
   Add('    CAST_NUMBER    SMALLINT,');
   Add('    UNIT_ID        BIGINT');
   Add(');');
   Add('');
   Add('CREATE TABLE P_TEMPERATURE_CTD (');
   Add('    ID             BIGINT NOT NULL,');
   Add('    LEVEL_         NUMERIC(9,4) NOT NULL,');
   Add('    VALUE_         DECIMAL(6,4) NOT NULL,');
   Add('    QCFLAG_ODB     SMALLINT NOT NULL,');
   Add('    QCFLAG_SOURCE  SMALLINT,');
   Add('    CAST_NUMBER    SMALLINT,');
   Add('    UNIT_ID        BIGINT');
   Add(');');
   Add('');
   Add('CREATE TABLE QCFLAG (');
   Add('    SOURCE_ID      BIGINT NOT NULL,');
   Add('    QCFLAG_ODB     SMALLINT NOT NULL,');
   Add('    QCFLAG_SOURCE  SMALLINT NOT NULL');
   Add(');');
   Add('');
   Add('CREATE TABLE STATION (');
   Add('    ID                  BIGINT NOT NULL,');
   Add('    STLAT               DECIMAL(8,5) NOT NULL,');
   Add('    STLON               DECIMAL(9,5) NOT NULL,');
   Add('    STDATE              TIMESTAMP NOT NULL,');
   Add('    STDEPTH             INTEGER,');
   Add('    STLASTLEVEL         INTEGER,');
   Add('    SOURCE_ID           BIGINT DEFAULT -9 NOT NULL,');
   Add('    COUNTRY_ID          BIGINT DEFAULT -9 NOT NULL,');
   Add('    PLATFORM_ID         BIGINT DEFAULT -9 NOT NULL,');
   Add('    CRUISE_ID           BIGINT DEFAULT -9 NOT NULL,');
   Add('    INSTRUMENT_ID       BIGINT DEFAULT -9 NOT NULL,');
   Add('    STNUMBER            VARCHAR(50),');
   Add('    ORIGINAL_SOURCE_ID  BIGINT,');
   Add('    STFLAG              SMALLINT NOT NULL,');
   Add('    STVERSION           SMALLINT NOT NULL,');
   Add('    MERGED              SMALLINT DEFAULT 0 NOT NULL,');
   Add('    DATE_ADDED          TIMESTAMP NOT NULL,');
   Add('    DATE_UPDATED        TIMESTAMP NOT NULL');
   Add(');');
   Add('');
   Add('CREATE TABLE STATION_ENTRY (');
   Add('    STATION_ID  BIGINT NOT NULL,');
   Add('    ENTRY_ID    BIGINT NOT NULL');
   Add(');');          }


 {
ALTER TABLE STATION ADD CONSTRAINT PK_STATION PRIMARY KEY (ID);
ALTER TABLE ENTRY ADD CONSTRAINT PK_ENTRY PRIMARY KEY (ID);
ALTER TABLE ENTRY_TYPE ADD CONSTRAINT PK_ENTRY_TYPE PRIMARY KEY (ID);


/******************************************************************************/
/***                              Foreign keys                              ***/
/******************************************************************************/

ALTER TABLE ENTRY ADD CONSTRAINT FK_ENTRY_1 FOREIGN KEY (ENTRIES_TYPE_ID) REFERENCES ENTRY_TYPE (ID);
ALTER TABLE P_TEMPERATURE_BOTTLE ADD CONSTRAINT FK_P_TEMPERATURE_BOTTLE_2 FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE P_TEMPERATURE_CTD ADD CONSTRAINT FK_P_TEMPERATURE_CTD_2 FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_1 FOREIGN KEY (STATION_ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_2 FOREIGN KEY (ENTRY_ID) REFERENCES ENTRY (ID) ON DELETE CASCADE ON UPDATE CASCADE;
}



   'COMMIT WORK '+LineEnding+
   'SET TERM ; '+LineEnding;

begin
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
