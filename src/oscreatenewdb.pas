unit oscreatenewdb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  IBConnection, SQLDB, DB, IniFiles;

type

  { Tfrmcreatenewdb }

  Tfrmcreatenewdb = class(TForm)
    btnCreateDB: TButton;
    chlbVariables: TCheckGroup;

    procedure FormShow(Sender: TObject);
    procedure btnCreateDBClick(Sender: TObject);
    procedure chlbVariablesItemClick(Sender: TObject; Index: integer);

  private
    procedure CreateNewDB(dbname:string);
    procedure PopulateSupportTables(dbname:string);
  public

  end;

var
  frmcreatenewdb: Tfrmcreatenewdb;
  DBOcean:string;

implementation

{$R *.lfm}

{ Tfrmcreatenewdb }

uses osmain, dm;


procedure Tfrmcreatenewdb.FormShow(Sender: TObject);
Var
  Ini: TIniFile;
  DB:TIBConnection;
  TR:TSQLTransaction;
  Q:TSQLQuery;
  DBName: string;
begin
try
   DB:=TIBConnection.Create(nil);
   TR:=TSQLTransaction.Create(nil);

   DB.Transaction:=TR;
   TR.Database:=DB;

   Q:=TSQLQuery.Create(self);
   Q.Database:=DB;
   Q.Transaction:=TR;

   Ini := TIniFile.Create(IniFileName);
   try
     DBOcean:=Ini.ReadString( 'main', 'OceanFDBPath',  '');
   finally
    Ini.free;
   end;

    DB.DatabaseName:=DBOcean;
    DB.UserName:='SYSDBA';
    DB.Password:='masterkey';
    DB.LoginPrompt:=False;
    DB.Connected:=True;

    With Q do begin
      Close;
        SQL.Clear;
        SQL.Add(' SELECT NAME_TABLE FROM DATABASE_TABLES ');
        SQL.Add(' ORDER BY NAME_TABLE ');
      Open;
    end;

    chlbVariables.Items.Clear;
    while not Q.eof do begin
     chlbVariables.Items.Add(Q.Fields[0].AsString);
     Q.Next;
    end;
    Q.Close;
 finally
  Q.Free;
  TR.Commit;
  TR.Free;
  DB.Connected:=false;
  DB.Free;
 end;
end;


(* Creating NEW EMPTY database *)
procedure Tfrmcreatenewdb.CreateNewDB(dbname:string);
Var
DB:TIBConnection;
TR:TSQLTransaction;
ST:TSQLScript;
k:integer;
tbl:string;

(* Script for main tables *)
const ScriptText=

   'CREATE TABLE COUNTRY ('+LineEnding+
   '   ID            BIGINT NOT NULL,'+LineEnding+
   '   NODC_CODE     VARCHAR(4) CHARACTER SET UTF8,'+LineEnding+
   '   ISO3166_CODE  VARCHAR(2) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '   NAME          VARCHAR(50) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '   DATE_ADDED    TIMESTAMP NOT NULL,'+LineEnding+
   '   DATE_UPDATED  TIMESTAMP NOT NULL,'+LineEnding+
   '   NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 8192 CHARACTER SET UTF8'+LineEnding+
   ');'+LineEnding+


   'CREATE TABLE CRUISE ('+LineEnding+
   '   ID               BIGINT NOT NULL,'+LineEnding+
   '   PLATFORM_ID      BIGINT DEFAULT 1 NOT NULL,'+LineEnding+
   '   SOURCE_ID        BIGINT DEFAULT 1 NOT NULL,'+LineEnding+
   '   INSTITUTE_ID     BIGINT DEFAULT 1 NOT NULL,'+LineEnding+
   '   PROJECT_ID       BIGINT DEFAULT 0 NOT NULL,'+LineEnding+
   '   EXPOCODE         VARCHAR(50) CHARACTER SET UTF8,'+LineEnding+
   '   CRUISE_NUMBER    VARCHAR(100) CHARACTER SET UTF8,'+LineEnding+
   '   DATE_START       TIMESTAMP NOT NULL,'+LineEnding+
   '   DATE_END         TIMESTAMP NOT NULL,'+LineEnding+
   '   STATIONS_AMOUNT  BIGINT,'+LineEnding+
   '   "PI"             VARCHAR(255) CHARACTER SET UTF8 DEFAULT -9,'+LineEnding+
   '   NOTES            BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '   DATE_ADDED       TIMESTAMP NOT NULL,'+LineEnding+
   '   DATE_UPDATED     TIMESTAMP NOT NULL,'+LineEnding+
   '   COMPLETE         BOOLEAN DEFAULT false NOT NULL'+LineEnding+
   ');'+LineEnding+

   'CREATE TABLE DATABASE_TABLES ('+LineEnding+
   '    ID                BIGINT NOT NULL,'+LineEnding+
   '    NAME_TABLE        VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    NAME              VARCHAR(255) CHARACTER SET UTF8,'+LineEnding+
   '    UNITS_ID_DEFAULT  BIGINT DEFAULT 2,'+LineEnding+
   '    NOTES             BLOB SUB_TYPE 1 SEGMENT SIZE 8192 CHARACTER SET UTF8,'+LineEnding+
   '    DATE_ADDED       TIMESTAMP NOT NULL,'+LineEnding+
   '    DATE_UPDATED     TIMESTAMP NOT NULL'+LineEnding+
   ');'+LineEnding+

   'CREATE TABLE ENTRY ('+LineEnding+
   '    ID               BIGINT NOT NULL, '+LineEnding+
   '    ENTRY_TYPE_ID    BIGINT NOT NULL, '+LineEnding+
   '    TITLE            VARCHAR(255) NOT NULL, '+LineEnding+
   '    DATE_START       TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_END         TIMESTAMP NOT NULL, '+LineEnding+
   '    STATIONS_AMOUNT  BIGINT, '+LineEnding+
   '    NOTES            BLOB SUB_TYPE 1 SEGMENT SIZE 16384  CHARACTER SET UTF8, '+LineEnding+
   '    DATE_ADDED       TIMESTAMP NOT NULL, '+LineEnding+
   '    DATE_UPDATED     TIMESTAMP NOT NULL'+LineEnding+
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
   '    DATE_UPDATED  TIMESTAMP NOT NULL'+LineEnding+
   ');'+LineEnding+


   'CREATE TABLE INSTRUMENT ('+LineEnding+
   '    ID            BIGINT NOT NULL,'+LineEnding+
   '    WOD_ID        BIGINT DEFAULT -9 NOT NULL,'+LineEnding+
   '    NAME          VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    DATE_ADDED    TIMESTAMP NOT NULL,'+LineEnding+
   '    DATE_UPDATED  TIMESTAMP NOT NULL'+LineEnding+
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
   '    CLOUDTYPE    VARCHAR(20) CHARACTER SET UTF8, ' +LineEnding+
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
   '    COUNTRY_ID    BIGINT DEFAULT 488 NOT NULL,'+LineEnding+
   '    NOTES_ICES    BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    NOTES_WOD     BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    DATE_ADDED    TIMESTAMP NOT NULL,'+LineEnding+
   '    DATE_UPDATED  TIMESTAMP NOT NULL'+LineEnding+
   ');'+LineEnding+


   'CREATE TABLE PROJECT ('+LineEnding+
   '    ID            BIGINT NOT NULL,'+LineEnding+
   '    WOD_ID        BIGINT DEFAULT -9 NOT NULL,'+LineEnding+
   '    NAME          VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    NAME_FULL     VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    NOTES         BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    DATE_ADDED    TIMESTAMP NOT NULL,'+LineEnding+
   '    DATE_UPDATED  TIMESTAMP NOT NULL'+LineEnding+
   ');'+LineEnding+


   'CREATE TABLE SOURCE ( '+LineEnding+
   '    ID              BIGINT NOT NULL,'+LineEnding+
   '    NAME            VARCHAR(255) CHARACTER SET UTF8 NOT NULL,'+LineEnding+
   '    STATION_ID_MIN  BIGINT,'+LineEnding+
   '    STATION_ID_MAX  BIGINT,'+LineEnding+
   '    NOTES           BLOB SUB_TYPE 1 SEGMENT SIZE 16384 CHARACTER SET UTF8,'+LineEnding+
   '    DATE_ADDED      TIMESTAMP NOT NULL,'+LineEnding+
   '    DATE_UPDATED    TIMESTAMP NOT NULL'+LineEnding+
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
   '   DATE_UPDATED      TIMESTAMP NOT NULL'+LineEnding+
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
   '   DATE_UPDATED  TIMESTAMP NOT NULL'+LineEnding+
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
   'ALTER TABLE CRUISE ADD CONSTRAINT FK_CRUISE_1 FOREIGN KEY (PLATFORM_ID) REFERENCES PLATFORM (ID) ON DELETE SET DEFAULT ON UPDATE CASCADE;'+LineEnding+
   'ALTER TABLE CRUISE ADD CONSTRAINT FK_CRUISE_3 FOREIGN KEY (SOURCE_ID) REFERENCES SOURCE (ID) ON DELETE SET DEFAULT ON UPDATE CASCADE;'+LineEnding+
   'ALTER TABLE CRUISE ADD CONSTRAINT FK_CRUISE_4 FOREIGN KEY (INSTITUTE_ID) REFERENCES INSTITUTE (ID) ON DELETE SET DEFAULT ON UPDATE CASCADE;'+LineEnding+
   'ALTER TABLE CRUISE ADD CONSTRAINT FK_CRUISE_5 FOREIGN KEY (PROJECT_ID) REFERENCES PROJECT (ID) ON DELETE SET DEFAULT ON UPDATE CASCADE;'+LineEnding+
   'ALTER TABLE DATABASE_TABLES ADD CONSTRAINT FK_DATABASE_TABLES_1 FOREIGN KEY (UNITS_ID_DEFAULT) REFERENCES UNITS (ID) ON DELETE SET DEFAULT ON UPDATE CASCADE;'+LineEnding+
   'ALTER TABLE ENTRY ADD CONSTRAINT FK_ENTRY_1 FOREIGN KEY (ENTRY_TYPE_ID) REFERENCES ENTRY_TYPE (ID) ON DELETE CASCADE ON UPDATE CASCADE;'+LineEnding+
   'ALTER TABLE METEO ADD CONSTRAINT FK_METEO FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE;'+LineEnding+
   'ALTER TABLE PLATFORM ADD CONSTRAINT FK_PLATFORM_1 FOREIGN KEY (COUNTRY_ID) REFERENCES COUNTRY (ID) ON DELETE SET DEFAULT ON UPDATE CASCADE;'+LineEnding+
   'ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_1 FOREIGN KEY (STATION_ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE STATION_ENTRY ADD CONSTRAINT FK_STATION_ENTRY_2 FOREIGN KEY (ENTRY_ID) REFERENCES ENTRY (ID) ON DELETE CASCADE ON UPDATE CASCADE; '+LineEnding+
   'ALTER TABLE STATION ADD CONSTRAINT FK_STATION_1 FOREIGN KEY (CRUISE_ID) REFERENCES CRUISE (ID) ON DELETE CASCADE ON UPDATE CASCADE;'+LineEnding+

   'COMMIT WORK '+LineEnding+
   'SET TERM ; '+LineEnding;
begin

 try
 (* Creating database *)
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

    (* Creating basic structure common for every DB *)
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


 (* Adding parameters *)
 ST.Script.Clear;
 For k:=0 to chlbVariables.Items.Count-1 do begin
    if chlbVariables.Checked[k] then begin
     tbl:=chlbVariables.Items.Strings[k];
      with ST.Script do begin
        Add('CREATE TABLE '+tbl+' ( ');
        Add('ID              BIGINT NOT NULL, ');
        Add('LEV_DBAR        DECIMAL(9,4) NOT NULL, ');
        Add('LEV_M           DECIMAL(9,4) NOT NULL, ');
        Add('VAL             DOUBLE PRECISION NOT NULL, ');
        Add('PQF1            SMALLINT, ');
        Add('PQF2            SMALLINT, ');
        Add('SQF             SMALLINT, ');
        Add('BOTTLE_NUMBER   SMALLINT, ');
        Add('UNITS_ID        BIGINT NOT NULL, ');
        Add('INSTRUMENT_ID   BIGINT DEFAULT 0 NOT NULL, ');
        Add('PROFILE_NUMBER  SMALLINT DEFAULT 1 NOT NULL ');
        Add('); ');
        Add('ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_1 FOREIGN KEY (ID) REFERENCES STATION (ID) ON DELETE CASCADE ON UPDATE CASCADE; ');
        Add('ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_2 FOREIGN KEY (UNITS_ID) REFERENCES UNITS (ID) ON DELETE SET DEFAULT ON UPDATE CASCADE; ');
        Add('ALTER TABLE '+tbl+' ADD CONSTRAINT FK_'+tbl+'_3 FOREIGN KEY (INSTRUMENT_ID) REFERENCES INSTRUMENT (ID) ON DELETE SET DEFAULT ON UPDATE CASCADE; ');
      end;
    end;
 end;
 ST.Script.Add('SET TERM ^ ;');
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

(* Copying support data from OCEAN.FDB into the NEW database *)
procedure Tfrmcreatenewdb.PopulateSupportTables(dbname:string);
Var
DB_NEW, DB_OCEAN:TIBConnection;
TR_NEW, TR_OCEAN:TSQLTransaction;
Q_NEW, Q_OCEAN:TSQLQuery;
k:integer;
tbl:string;
begin
 try

   (* Opening NEW database *)
   DB_NEW:=TIBConnection.Create(nil);
   TR_NEW:=TSQLTransaction.Create(nil);
   Q_NEW:=TSQLQuery.Create(nil);

   DB_NEW.Transaction:=TR_NEW;
   TR_NEW.Database:=DB_NEW;
   Q_NEW.Transaction:=TR_NEW;
   Q_NEW.Database:=DB_NEW;

   DB_NEW.DatabaseName:=(dbname);
   DB_NEW.UserName:='SYSDBA';
   DB_NEW.Password:='masterkey';
   DB_NEW.LoginPrompt:=False;
   DB_NEW.Connected:=True;

   (* Opening OCEAN.FDB database *)
   DB_OCEAN:=TIBConnection.Create(nil);
   TR_OCEAN:=TSQLTransaction.Create(nil);
   Q_OCEAN:=TSQLQuery.Create(nil);

   DB_OCEAN.Transaction:=TR_OCEAN;
   TR_OCEAN.Database:=DB_OCEAN;
   Q_OCEAN.Transaction:=TR_OCEAN;
   Q_OCEAN.Database:=DB_OCEAN;

   DB_OCEAN.DatabaseName:=DBOcean;
   DB_OCEAN.UserName:='SYSDBA';
   DB_OCEAN.Password:='masterkey';
   DB_OCEAN.LoginPrompt:=False;
   DB_OCEAN.Connected:=True;


   for k:=1 to 8 do begin
     case k of
      1: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM COUNTRY ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO COUNTRY ');
             SQL.Add(' (ID, NODC_CODE, ISO3166_CODE, NAME, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NODC_CODE, :ISO3166_CODE, :NAME, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NODC_CODE').Value:=Q_OCEAN.FieldByName('NODC_CODE').Value;
             ParamByName('ISO3166_CODE').Value:=Q_OCEAN.FieldByName('ISO3166_CODE').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      2: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM INSTITUTE ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO INSTITUTE ');
             SQL.Add(' (ID, NODC_CODE, WOD_ID, NAME, NAME_FULL, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NODC_CODE, :WOD_ID, :NAME, :NAME_FULL, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NODC_CODE').Value:=Q_OCEAN.FieldByName('NODC_CODE').Value;
             ParamByName('WOD_ID').Value:=Q_OCEAN.FieldByName('WOD_ID').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('NAME_FULL').Value:=Q_OCEAN.FieldByName('NAME_FULL').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;
      3:begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM INSTRUMENT ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO INSTRUMENT ');
             SQL.Add(' (ID, WOD_ID, NAME, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :WOD_ID, :NAME, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('WOD_ID').Value:=Q_OCEAN.FieldByName('WOD_ID').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      4: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM PROJECT ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO PROJECT ');
             SQL.Add(' (ID, WOD_ID, NAME, NAME_FULL, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :WOD_ID, :NAME, :NAME_FULL, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('WOD_ID').Value:=Q_OCEAN.FieldByName('WOD_ID').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('NAME_FULL').Value:=Q_OCEAN.FieldByName('NAME_FULL').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      5: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM SOURCE ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO SOURCE ');
             SQL.Add(' (ID, NAME, STATION_ID_MIN, STATION_ID_MAX, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NAME, :STATION_ID_MIN, :STATION_ID_MAX, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('STATION_ID_MIN').Value:=Q_OCEAN.FieldByName('STATION_ID_MIN').Value;
             ParamByName('STATION_ID_MAX').Value:=Q_OCEAN.FieldByName('STATION_ID_MAX').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      6: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM UNITS ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO UNITS ');
             SQL.Add(' (ID, NAME_SHORT, NAME, LENGTH, SCALE, DATE_ADDED, ');
             SQL.Add(' DATE_UPDATED, NOTES) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NAME_SHORT, :NAME, :LENGTH, :SCALE, :DATE_ADDED, ');
             SQL.Add(' :DATE_UPDATED, :NOTES) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NAME_SHORT').Value:=Q_OCEAN.FieldByName('NAME_SHORT').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('LENGTH').Value:=Q_OCEAN.FieldByName('LENGTH').Value;
             ParamByName('SCALE').Value:=Q_OCEAN.FieldByName('SCALE').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      7: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM PLATFORM ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO PLATFORM ');
             SQL.Add(' (ID, NODC_CODE, WOD_ID, IMO_ID, CALLSIGN, NAME, ');
             SQL.Add(' NAME_NATIVE, COUNTRY_ID, DATE_ADDED, DATE_UPDATED, ');
             SQL.Add(' NOTES, NOTES_ICES, NOTES_WOD) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NODC_CODE, :WOD_ID, :IMO_ID, :CALLSIGN, :NAME, ');
             SQL.Add(' :NAME_NATIVE, :COUNTRY_ID, :DATE_ADDED, :DATE_UPDATED, ');
             SQL.Add(' :NOTES, :NOTES_ICES, :NOTES_WOD) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NODC_CODE').Value:=Q_OCEAN.FieldByName('NODC_CODE').Value;
             ParamByName('WOD_ID').Value:=Q_OCEAN.FieldByName('WOD_ID').Value;
             ParamByName('IMO_ID').Value:=Q_OCEAN.FieldByName('IMO_ID').Value;
             ParamByName('CALLSIGN').Value:=Q_OCEAN.FieldByName('CALLSIGN').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('NAME_NATIVE').Value:=Q_OCEAN.FieldByName('NAME_NATIVE').Value;
             ParamByName('COUNTRY_ID').Value:=Q_OCEAN.FieldByName('COUNTRY_ID').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('NOTES_ICES').Value:=Q_OCEAN.FieldByName('NOTES_ICES').Value;
             ParamByName('NOTES_WOD').Value:=Q_OCEAN.FieldByName('NOTES_WOD').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

      8: begin
        Q_OCEAN.Close;
        Q_OCEAN.SQL.Text:='SELECT * FROM DATABASE_TABLES ORDER BY ID';
        Q_OCEAN.Open;

        while not Q_OCEAN.EOF do begin
          With Q_NEW do begin
            Close;
             SQL.Clear;
             SQL.Add(' INSERT INTO DATABASE_TABLES ');
             SQL.Add(' (ID, NAME_TABLE, NAME, UNITS_ID_DEFAULT, NOTES, ');
             SQL.Add(' DATE_ADDED, DATE_UPDATED) ');
             SQL.Add(' VALUES ');
             SQL.Add(' (:ID, :NAME_TABLE, :NAME, :UNITS_ID_DEFAULT, :NOTES, ');
             SQL.Add(' :DATE_ADDED, :DATE_UPDATED) ');
             ParamByName('ID').Value:=Q_OCEAN.FieldByName('ID').Value;
             ParamByName('NAME_TABLE').Value:=Q_OCEAN.FieldByName('NAME_TABLE').Value;
             ParamByName('NAME').Value:=Q_OCEAN.FieldByName('NAME').Value;
             ParamByName('UNITS_ID_DEFAULT').Value:=Q_OCEAN.FieldByName('UNITS_ID_DEFAULT').Value;
             ParamByName('NOTES').Value:=Q_OCEAN.FieldByName('NOTES').Value;
             ParamByName('DATE_ADDED').Value:=Q_OCEAN.FieldByName('DATE_ADDED').Value;
             ParamByName('DATE_UPDATED').Value:=Q_OCEAN.FieldByName('DATE_UPDATED').Value;
           ExecSQL;
          end;
          Q_OCEAN.Next;
        end;
        TR_OCEAN.CommitRetaining;
      end;

     end; //end of case
   end; // 1-8

 finally
  TR_NEW.Commit;
  TR_OCEAN.Commit;
  Q_NEW.Free;
  Q_OCEAN.Free;
  TR_NEW.Free;
  TR_OCEAN.Free;
  DB_NEW.Connected:=false;
  DB_NEW.Free;
  DB_OCEAN.Connected:=false;
  DB_OCEAN.Free;
 end;

end;



procedure Tfrmcreatenewdb.btnCreateDBClick(Sender: TObject);
begin
frmosmain.SD.Filter:='Firebird database|*.FDB';
frmosmain.SD.DefaultExt:='FDB';
 if frmosmain.SD.Execute then begin
  frmcreatenewdb.Enabled:=false;
  Application.ProcessMessages;

   CreateNewDB(frmosmain.SD.FileName);
   PopulateSupportTables(frmosmain.SD.FileName);

    frmdm.IBDB.Close;
    frmdm.IBDB.DatabaseName:=frmosmain.SD.FileName;
    IBName:=frmdm.IBDB.DatabaseName;
  frmosmain.OpenDatabase;
  Close;
 end;
end;

procedure Tfrmcreatenewdb.chlbVariablesItemClick(Sender: TObject; Index: integer);
Var
 k:integer;
 fl:boolean;
begin
  fl:=false;
  for k:=0 to chlbVariables.Items.Count-1 do
    if chlbVariables.Checked[k] then fl:=true;

 btnCreateDB.Enabled:=fl;
end;



end.

