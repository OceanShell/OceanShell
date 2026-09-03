unit test;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, IniFiles,
  dm, DB, IBConnection, sqldb,

  osmain, osprofile_station_single, osprofile_station_single_upd;

type

  { Tfrmtest }

  Tfrmtest = class(TForm)
    ListBox2: TListBox;

    procedure FormShow(Sender: TObject);
    procedure ListBox2DblClick(Sender: TObject);

  private

  public

  end;

var
  frmtest: Tfrmtest;
 { GlobalPath: string;
  IniFileName, CurrentParTable: string;
  depth_units: integer; //0-meters, 1-dBar
  depth_units_str, path_to_argo: string;

  current_station_id:int64;

  S_clr:Array[1..15] of TColor =
   (clBlue,clFuchsia,clMaroon,clBlack,clGreen,clNavy,clPurple,clTeal,
    clOlive,clGray,clSilver,clLime,clYellow,clAqua,clLtGray);

  PQF1_list: TStringList; // list for PQF1
  PQF2_list: TStringList; // list for PQF2
  SQF_list : TStringList; // list for SQF
  TempList:TListBox;

  frmprofile_station_single_open, frmprofile_station_single_open_upd: boolean;
  frmprofile_plot_all_open: boolean;

  netcdf,  libgswteos: TLibHandle;  }
  frmprofile_station_single_open_upd: boolean=false;


const
  NC_MAX_NAME  = 1024; // value from netcdf.h

implementation

{$R *.lfm}

{ Tfrmtest }

procedure Tfrmtest.FormShow(Sender: TObject);
Var
Ini, DBIni:TIniFile;
DBUser, DBPass, DBHost, DBPath, DBAlias, tbl_name: string;
k:integer;
TempList:TListBox;

TRt:TSQLTransaction;
Qt:TSQLQuery;
begin
   DBAlias:='Ocean_FB5';

  DBIni := TIniFile.Create(IniFileName+'_db');
  try
    DBUser :=DBIni.ReadString(DBAlias, 'user',     'SYSDBA');
    DBPass :=DBIni.ReadString(DBAlias, 'pass',     'masterkey');
    DBHost :=DBIni.ReadString(DBAlias, 'host',     'localhost');
    DBPath :=DBIni.ReadString(DBAlias, 'dbpath',   '');
  finally
    DBIni.Free;
  end;

  with frmdm.DBLoader do begin
    //  showmessage(globalpath);
    LibraryName:=GlobalPath+'fbclient.dll';
    Enabled:=true;
  end;

    with frmdm.IBDB do begin
      Connected:=false;
      UserName:=DBUser;
      Password:=DBPass;
      HostName:=DBHost;
      DatabaseName:=DBPath;
      Connected:=true;
    end;

   frmosmain.ListBox1.Clear;
   try
    TempList:=TListBox.Create(self);
    frmdm.IBDB.GetTableNames(TempList.Items,False);
    for k:=0 to TempList.Items.Count-1 do
     if (copy(TempList.Items.Strings[k], 1, 2)='P_') then
       frmosmain.ListBox1.Items.Add(TempList.Items.Strings[k]);
    finally
     TempList.Free;
    end;


      PQF1_list:=TStringList.Create;
   PQF2_list:=TStringList.Create;
   SQF_list:=TStringList.Create;

   TRt:=TSQLTransaction.Create(self);
  TRt.DataBase:=frmdm.IBDB;

  Qt :=TSQLQuery.Create(self);
  Qt.Database:=frmdm.IBDB;
  Qt.Transaction:=TRt;

  PQF1_list.Clear;
  PQF2_list.Clear;
  SQF_list.Clear;

  try
   for k:=2 to 4 do begin
    case k of
     2: tbl_name:='FLAG_PQF1';
     3: tbl_name:='FLAG_PQF2';
     4: tbl_name:='FLAG_SQF';
    end;

    with Qt do begin
     Close;
      SQL.Clear;
      SQL.Add(' SELECT ID, NAME FROM '+tbl_name+' ORDER BY ID ');
     Open;
    end;

    while not Qt.EOF do begin
     case k of
      2: PQF1_list.Add('['+inttostr(Qt.Fields[0].Value)+'] '+Qt.Fields[1].Value);
      3: PQF2_list.Add('['+inttostr(Qt.Fields[0].Value)+'] '+Qt.Fields[1].Value);
      4: SQF_list.Add ('['+inttostr(Qt.Fields[0].Value)+'] '+Qt.Fields[1].Value);
     end;
     Qt.Next;
    end;
   end;

     (* Getting ARGO and FDB tables *)
  with Qt do begin
   Close;
     SQL.Clear;
     SQL.Add(' select id, name_table, name_argo, units_id_default ');
     SQL.Add(' from database_tables ');
     SQL.Add(' where name_argo is not null ');
     SQL.Add(' order by id ');
   Open;
   Last;
   First;
  end;

  SetLength(ARGO_FDB_MAPPING, Qt.RecordCount);
  k:=-1;
  While not Qt.EOF do begin
   inc(k);
     ARGO_FDB_MAPPING[k].TBL_ID    :=Qt.FieldByName('id').Value;
     ARGO_FDB_MAPPING[k].NAME_FDB  :=Qt.FieldByName('name_table').Value;
     ARGO_FDB_MAPPING[k].NAME_ARGO :=Qt.FieldByName('name_argo').Value;
     ARGO_FDB_MAPPING[k].UNITS     :=Qt.FieldByName('units_id_default').Value;
   Qt.Next;
  end;
  Qt.Close;

  finally
   Trt.Commit;
   Qt.Free;
   Trt.Free;
  end;
end;



procedure Tfrmtest.ListBox2DblClick(Sender: TObject);
begin
  current_station_id:=StrToInt(ListBox2.Items.Strings[ListBox2.ItemIndex]);
//  showmessage(inttostr(current_station_id));

    if frmprofile_station_single_open=true then frmprofile_station_single.SetFocus else
     begin
       frmprofile_station_single := Tfrmprofile_station_single.Create(Self);
       frmprofile_station_single.Show;
     end;
    frmprofile_station_single_open:=true;
    frmprofile_station_single.ChangeID;

  if frmprofile_station_single_open_upd=true then frmprofile_station_single_upd.SetFocus else
     begin
       frmprofile_station_single_upd := Tfrmprofile_station_single_upd.Create(Self);
       frmprofile_station_single_upd.Show;
     end;
    frmprofile_station_single_open_upd:=true;
    frmprofile_station_single_upd.ChangeID;


end;


end.

