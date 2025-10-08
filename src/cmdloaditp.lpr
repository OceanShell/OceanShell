program cmdloaditp;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, IBConnection, SQLDB,
  osload_itp, osqc_cruiseinfo;

type

  { TLoadITP }

  TLoadITP = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
  end;

{ TLoadITP }

procedure TLoadITP.DoRun;
Var
  AppPath, datapath:string;
  libgswteos:TLibHandle;
  DB:TIBConnection;
  TR:TSQLTransaction;
  Q, Q2, Q3:TSQLQuery;

  cruise_id: int64;

  DBUser, DBPass, DBHost, DBPath: string;

  folder_lst:TStringList;
  fdb:TSearchRec;
  ff:integer;
  StatOnly, isfinal:boolean;
  cnt_add, cnt_upd, cnt_del: integer;

  FolderName, buoytype, stvessel, isfinal_str:string;
begin

 StatOnly:=false; //Change!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   AppPath:=ExtractFilePath(ParamStr(0));

(* Loading dynamic libraries *)
  {$IFDEF WINDOWS}
   // IniFileName:=GetUserDir+'.climateshell_db';
    libgswteos:=LoadLibrary(PChar(AppPath+'libgswteos-10.dll'));
  {$ENDIF}
  {$IFDEF LINUX}
    IniFileName:=AppPath+'database.ini';
    libgswteos:=LoadLibrary(PChar(AppPath+'libgswteos-10.so'));
  {$ENDIF}

  {  if libgswteos=0 then begin
      writeln('GibbsSeaWater is not installed');
      readln();
      halt;
    end;
    if not FileExists(IniFileName) then begin
      writeln('database.ini is not found ');
      readln();
      halt;
    end;

    // reading the keys
    if HasOption('d','db') then DBAlias:=trim(GetOptionValue('d','db')) else DBAlias:='';
    if HasOption('p','pt') then DataPath:=trim(GetOptionValue('p','pt')) else DataPath:='';
    towrite := HasOption('w','wrt');

    writeln('Database: '+DBAlias);
    writeln('Data source: '+DataPath);
    if towrite then writeln('Writing data') else writeln('Showing statistics');
    writeln();

    if not DirectoryExists(DataPath) then begin
      writeln('Data folder is not found, exiting ');
      readln();
      halt;
    end;  }


    try
    DB:=TIBConnection.Create(nil);
    TR:=TSQLTransaction.Create(nil);

    DB.Transaction:=TR;
    TR.Database:=DB;

    Q:=TSQLQuery.Create(self);
    Q.Database:=DB;
    Q.Transaction:=TR;

    Q2:=TSQLQuery.Create(self);
    Q2.Database:=DB;
    Q2.Transaction:=TR;

    Q3:=TSQLQuery.Create(self);
    Q3.Database:=DB;
    Q3.Transaction:=TR;

  {  Ini := TIniFile.Create(IniFileName);
    try
      DBUser :=Ini.ReadString(DBAlias, 'user',     'SYSDBA');
      DBPass :=Ini.ReadString(DBAlias, 'pass',     'masterkey');
      DBHost :=Ini.ReadString(DBAlias, 'host',     'localhost');
      DBPath :=Ini.ReadString(DBAlias, 'dbpath',   '');
    finally
      Ini.Free;
    end; }

    DBUser :='SYSDBA';
    DBPass :='masterkey';
    DBHost :='localhost';
    DBPath :='Z:\OceanShell\databases\OCEAN.FDB';

    with DB do begin
     Params.Clear;
     Connected:=false;
     UserName:=DBUser;
     Password:=DBPass;
     HostName:=DBHost;
     DatabaseName:=DBPath;
     Connected:=true;
    end;


 datapath:='X:\Data_Oceanography\_ITP\data\unzipped\';


 folder_lst:=TStringList.Create;
 fdb.Name:='';
 if FindFirst(DataPath+PathDelim+'*',faAnyFile, fdb)=0 then
  Repeat
   if ((fdb.Attr and faDirectory)=faDirectory) and
      (length(fdb.Name)>2) then folder_lst.Add(fdb.Name);
  Until FindNext(fdb)<>0;
 FindClose(fdb);


 For ff:=0 to folder_lst.Count-1 do begin

  FolderName:= folder_lst.Strings[ff];

   //ITP or TOP
    buoytype:='';
    if copy(FolderName, 1, 3)='itp' then buoytype:='itp';
    if copy(FolderName, 1, 3)='top' then buoytype:='top';

    //Final?
    if Pos('final',FolderName)>0 then begin
      stvessel:=copy(FolderName, 4, Pos('final',FolderName)-4);
      isfinal:=true;
      isfinal_str:='final';
    end else begin
      stvessel:=copy(FolderName, 4, Pos('grddata',FolderName)-4);
      isfinal:=false;
      isfinal_str:='griddata';
    end;

  write('Cruise '+buoytype+stVessel+' ('+isfinal_str+')');

  cnt_add:=0; cnt_upd:=0; cnt_del:=0;
  osload_itp.ITP(libgswteos, DB, DataPath, FolderName, buoytype, stvessel,
               StatOnly, isfinal,
               cnt_add, cnt_upd, cnt_del, cruise_id);

    if (cnt_upd=0) and (cnt_add=0) and (cnt_del=0) then
      write(' is up to date') else begin
        if (cnt_add>0) then write(' added: '+inttostr(cnt_add));
        if (cnt_upd>0) then write(' updated: '+inttostr(cnt_upd));
        if (cnt_del>0) then write(' removed: '+inttostr(cnt_del));
        osqc_cruiseinfo.UpdateCruiseInfo(DB, cruise_id, true);
      end;

    writeln();
 end;
 folder_lst.Free;

 finally
  TR.Commit;
  Q.Free;
  DB.Connected:=false;
  DB.Free;
 end;

   writeln('Press any key to exit');
   readln();

  // stop program loop
  Terminate;
end;

var
  Application: TLoadITP;
begin
  Application:=TLoadITP.Create(nil);
  Application.Title:='loaditp';
  Application.Run;
  Application.Free;
end.

