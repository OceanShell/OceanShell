unit osqc_wideranges_upd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids,
  ExtCtrls, Buttons, SQLDB, Grids;

type

  { Tfrmwideranges_upd }

  Tfrmwideranges_upd = class(TForm)
    btnStart: TBitBtn;
    chkWrite: TCheckBox;
    DS: TDataSource;
    DBGridTables: TDBGrid;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure DBGridTablesCellClick(Column: TColumn);
    procedure DBGridTablesPrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure DBGridTablesUserCheckboxState(Sender: TObject; Column: TColumn;
      var AState: TCheckboxState);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure UpdateWideRanges(tbl: string);
  private

  public

  end;

var
  frmwideranges_upd: Tfrmwideranges_upd;
  RecList: TBookmarklist;
  isSelected:boolean=true;

implementation

{$R *.lfm}

{ Tfrmwideranges_upd }

uses osmain, dm, osinfo, osunitsconversion;

procedure Tfrmwideranges_upd.FormShow(Sender: TObject);
begin
  RecList := TBookmarkList.Create(DbGridTables);

   with frmdm.q2 do begin
    Close;
     SQL.Clear;
     SQL.Add(' SELECT ');
     SQL.Add(' DATABASE_TABLES.NAME_TABLE, DATABASE_TABLES.UNITS_RANGE_MIN, ');
     SQL.Add(' DATABASE_TABLES.UNITS_RANGE_MAX, UNITS.NAME_SHORT ');
     SQL.Add(' FROM DATABASE_TABLES, UNITS ');
     SQL.Add(' WHERE ');
     SQL.Add(' DATABASE_TABLES.UNITS_ID_DEFAULT=UNITS.ID ');
     SQL.Add(' ORDER BY DATABASE_TABLES.NAME_TABLE ');
    Open;
   end;

end;

procedure Tfrmwideranges_upd.Label1Click(Sender: TObject);
begin
  frmdm.q2.First;
    while not frmdm.q2.EOF do begin
      RecList.CurrentRowSelected := isSelected;
      frmdm.q2.Next;
    end;
  frmdm.q2.First;

  isSelected:=not isSelected;
end;


procedure Tfrmwideranges_upd.FormDestroy(Sender: TObject);
begin
  RecList.Free;
end;

procedure Tfrmwideranges_upd.DBGridTablesCellClick(Column: TColumn);
begin
 if Column.Index=0 then
    RecList.CurrentRowSelected := not RecList.CurrentRowSelected;
end;

procedure Tfrmwideranges_upd.DBGridTablesPrepareCanvas(sender: TObject;
  DataCol: Integer; Column: TColumn; AState: TGridDrawState);
begin
 if (gdRowHighlight in AState) then begin
    TDBGrid(Sender).Canvas.Brush.Color := clNavy;
    TDBGrid(Sender).Canvas.Font.Color  := clYellow;
    TDBGrid(Sender).Canvas.Font.Style  := [fsBold];
 end;
end;

procedure Tfrmwideranges_upd.DBGridTablesUserCheckboxState(Sender: TObject;
  Column: TColumn; var AState: TCheckboxState);
begin
  if RecList.CurrentRowSelected then
    AState := cbChecked
  else
    AState := cbUnchecked;
end;


procedure Tfrmwideranges_upd.btnStartClick(Sender: TObject);
Var
  cmd, tbl:string;
  tbl_cnt: integer;
  DateStart, DateStart1:int64;
begin
 //form to show log
 if frminfo_open=false then frmInfo := TfrmInfo.Create(Self) else frminfo.SetFocus;
 frminfo.memo1.Clear;
// frminfo.memo1.Lines.Add('Start: '+DateTimeToStr(Now));

 tbl_cnt:=0;
 DateStart:=getTickCount64;

 // loop over selected tables
   frmdm.q2.First;
    while not frmdm.q2.EOF do begin
      if RecList.CurrentRowSelected=true then begin
       inc(tbl_cnt);
       tbl:=frmdm.q2.FieldByName('NAME_TABLE').Value;

       frminfo.memo1.Lines.Add('Processing: '+tbl);
       DateStart1:=getTickCount64;
         UpdateWideRanges(tbl);
       frminfo.memo1.Lines.Add(('Done: '+DateTimeToStr(TimeStampToDateTime(MSecsToTimeStamp(getTickCount64-DateStart1)))));
       frminfo.memo1.Lines.Add('');

    {  {$IFDEF WINDOWS}
        Procedures.ProgressTaskbar(cnt, frmdm.Q.RecordCount-1);
      {$ENDIF}}

      { inc(tbl_count);
       cmd:=OceanToolsPath+'QCWideRanges.exe'+
            ' -d '+DBAlias+
            ' -p '+frmdm.q2.FieldByName('NAME_TABLE').Value;
       if chkWrite.Checked=true then cmd:=cmd+' -w'; //write

       frmosmain.RunScript(0, cmd, frmInfo.memo1);   }
      end;
      frmdm.q2.Next;
    end;
   frminfo.memo1.Lines.Add(Inttostr(tbl_cnt) +' tables processed');
   frminfo.memo1.Lines.Add('Overall time spent: '+DateTimeToStr(TimeStampToDateTime(MSecsToTimeStamp(getTickCount64-DateStart))));
end;


procedure Tfrmwideranges_upd.UpdateWideRanges(tbl: string);
Var
  TR_read, TR_write:TSQLTransaction;
  Q_read, Q_write:TSQLQuery;

  dat, dat2:text;

  DateStart:int64;
  DateStart_str, LogPath:string;

  ToWrite: boolean;

   klt,kln, Pct :integer;
   unit_tbl,unit_default,val_c,val_nc,val_t, val_o :integer;
   outliers_count,step,sq_count, sq_total:integer;
   val,val_conv,val_min,val_max :real;
   ltn,lts,lnw,lne :real;
   range_unknown,isconverted,isoutlier :boolean;

   {PQF2 update}
   id,instr_id,prof_num: integer;
   lev_m :real;
begin

 ToWrite:=chkWrite.Checked;

  try
  (* transaction for reading *)
   TR_read:=TSQLTransaction.Create(nil);
     with TR_read.Params do begin
       Clear;
        Add('isc_tpb_read');
        Add('isc_tpb_read_committed');
        Add('isc_tpb_nowait');
        Add('isc_tpb_rec_version');
     end;
   TR_read.Database:=frmdm.IBDB;

   Q_read:=TSQLQuery.Create(self);
   Q_read.Database:=frmdm.IBDB;
   Q_read.Transaction:=TR_read;

   (* transaction for writing *)
   TR_write:=TSQLTransaction.Create(nil);
   TR_write.Database:=frmdm.IBDB;

   Q_write:=TSQLQuery.Create(self);
   Q_write.Database:=frmdm.IBDB;
   Q_write.Transaction:=TR_write;

   //time in absolute units
   DateStart:=getTickCount64;
   DateStart_str:=IntToStr(DateStart); //mark for the log file


   //path to log files
   LogPath:=GlobalUnloadPath+'log'+PathDelim;
  // showmessage(logpath);
     if not DirectoryExists(LogPath) then CreateDir(LogPath);

   // Opening log file
   AssignFile(dat,  LogPath+'QCWideRanges_'+tbl+'_'+DateStart_str+'.txt');  rewrite(dat); // new sations
 //  AssignFile(dat1, LogPath+'QCWideRanges_'+tbl+'_'+'Converted_'+DateStart_str+'.txt');  rewrite(dat1); // new sations
   AssignFile(dat2, LogPath+'QCWideRanges_'+tbl+'_'+'NOTConverted_'+DateStart_str+'.txt');  rewrite(dat2); // new sations

 //  showmessage('files open');
   //getting ranges for the specified table
      range_unknown:=true;
      with Q_read do begin
       Close;
         SQL.Clear;
         SQL.Add(' SELECT UNITS_RANGE_MIN, UNITS_RANGE_MAX, ');
         SQL.Add(' UNITS_ID_DEFAULT  ');
         SQL.Add(' FROM DATABASE_TABLES ');
         SQL.Add(' WHERE NAME_TABLE='+QuotedStr(tbl)+' AND ');
         SQL.Add(' UNITS_RANGE_MIN IS NOT NULL AND ');
         SQL.Add(' UNITS_RANGE_MAX IS NOT NULL ');
       Open;
        if Q_read.isEmpty=false then begin
         val_min:=Q_read.FieldByName('UNITS_RANGE_MIN').Value;
         val_max:=Q_read.FieldByName('UNITS_RANGE_MAX').Value;
         unit_default:=Q_read.FieldByName('UNITS_ID_DEFAULT').Value;
         range_unknown:=false;
        end;
       Close;
       end;

      if range_unknown=true then begin
        frminfo.memo1.Lines.Add('Range is not defined, skipping');
        exit;
    {  // exit if no ranges
       if range_unknown=true then begin
        writeln('Range for selected variable is unknown!');
        halt;
       end;

       writeln('Range: '+floattostr(val_min)+'->'+floattostr(val_max));
       writeln('Default units: '+inttostr(unit_default));
       writeln();  }
      end;


      step:=10;      //10 by 10 degrees squares
      sq_count:=0;
      sq_total:=648; //number of squares

      val_t:=0;    {number of values in a table}
      val_c:=0;    {number of converted values}
      val_nc:=0;   {number of not converted values}
      val_o:=0;    {number of values with default units}
      outliers_count:=0;

   {.....squares to reduce selection size}
      klt:=0;
   {Lt}repeat
          inc(klt);
          ltn:=90-step*(klt-1);
          lts:=90-step*klt;

          kln:=0;
   {Ln}repeat
          inc(kln);
          lnw:=-180+step*(kln-1);
          lne:=-180+step*kln;

          sq_count:=sq_count+1;

          //printing number of processed squares
       {   Pct := Trunc((sq_count * 1.0 / sq_total) * 100);
          Write(Format(StatusMsg, [sq_count, sq_total, Pct]));}


       with Q_read do begin
         Close;
         SQL.Clear;
         SQL.Add(' select STATION.id as id, lev_m, val,units_id, ');
         SQL.Add(' instrument_id, profile_number from STATION,'+tbl);
         SQL.Add(' where station.id='+tbl+'.id ');
         SQL.Add(' and latitude>:lts and latitude<=:ltn ');
         {...select data from 180 meridian}
         if lne<>180 then SQL.Add(' and longitude>=:lnw and longitude<:lne ')
                     else SQL.Add(' and longitude>=:lnw and longitude<=:lne ');
         ParamByName('ltn').AsFloat:=ltn;
         ParamByName('lts').AsFloat:=lts;
         ParamByName('lnw').AsFloat:=lnw;
         ParamByName('lne').AsFloat:=lne;
         Open;
       end;

   {w}while not Q_read.EOF do begin
        id      :=Q_read.FieldByName('id').AsInteger;
        lev_m   :=Q_read.FieldByName('lev_m').AsFloat;
        val     :=Q_read.FieldByName('val').AsFloat;
        unit_tbl:=Q_read.FieldByName('units_id').AsInteger;
        instr_id:=Q_read.FieldByName('instrument_id').AsInteger;
        prof_num:=Q_read.FieldByName('profile_number').AsInteger;

        val_t:=val_t+1;

        //if units are default
        if unit_tbl=unit_default then begin
           val_conv:=val;
           inc(val_o);
        end;

        //if units have to be converted
        if unit_tbl<>unit_default then begin
           val_conv:=-9999;
           isconverted:=false;
           osunitsconversion.GetDefaultUnits(tbl, unit_tbl, unit_default,
                                             val, val_conv, isconverted);
           if isconverted=true then begin
              val_c:=val_c+1;
           {   writeln(dat1, inttostr(ID)+#9+
                floattostr(LEV_M)+#9+
                inttostr(unit_tbl)+#9+
                floattostr(val)+#9+
                floattostr(val_conv)); }
           end else begin
              val_nc:=val_nc+1;
              writeln(dat2, inttostr(ID)+#9+
                floattostr(LEV_M)+#9+
                inttostr(unit_tbl)+#9+
                floattostr(val)+#9+
                floattostr(val_conv));
           end;
        end;


     isoutlier:=false;
     if (val_conv<>-9999) and
       ((val_conv<val_min) or (val_conv>val_max)) then isoutlier:=true;


     if isoutlier=true then begin
        outliers_count:=outliers_count+1;

       // Updating flags in the table
       if ToWrite=true then begin
        with Q_write do begin
         Close;
          SQL.Clear;
          SQL.Add(' UPDATE '+tbl+' SET PQF2=:QF WHERE ');
          SQL.Add(' ID=:ID AND LEV_M=:LEV_M AND VAL=:VAL AND ');
          SQL.Add(' INSTRUMENT_ID=:INSTR_ID AND ');
          SQL.Add(' PROFILE_NUMBER=:PROF_NUM AND');
          SQL.Add(' PQF2<>:QF ');
          ParamByName('ID').Value:=id;
          ParamByName('QF').Value:=1;
          ParamByName('LEV_M').Value:=lev_m;
          ParamByName('VAL').Value:=val;
          ParamByName('INSTR_ID').Value:=instr_id;
          ParamByName('PROF_NUM').Value:=prof_num;
         ExecSQL;
        end;
       end;

    //   showmessage('file open?');
        writeln(dat, inttostr(ID)+#9+
                floattostr(LEV_M)+#9+
                inttostr(unit_tbl)+#9+
                floattostr(val)+#9+
                floattostr(val_conv));
     end; // is outlier

     Q_read.Next;
   end;
   Q_read.Close;
   until lne=180; //longitude
  until lts=-90; //latitude

 {  writeln();
   writeln();
   writeln('Total: '+inttostr(val_t));
   writeln('Default units: '+inttostr(val_o));
   writeln('Converted: '+inttostr(val_c));
   writeln('NOT converted: '+inttostr(val_nc));
   writeln('Outliers: '+inttostr(outliers_count));
   writeln('');
   writeln('Done: '+DateTimeToStr(Now));
   writeln('Overall time spent: '+DateTimeToStr(TimeStampToDateTime(MSecsToTimeStamp(getTickCount64-DateStart))));
  }
//  showmessage('before writing');

   writeln(dat, 'Total: '+inttostr(val_t));
   writeln(dat, 'Default units: '+inttostr(val_o));
   writeln(dat, 'Converted: '+inttostr(val_c));
   writeln(dat, 'NOT converted: '+inttostr(val_nc));
   writeln(dat, 'Outliers: '+inttostr(outliers_count));
   writeln(dat, '');
   writeln(dat, 'Done: '+DateTimeToStr(Now));
   writeln(dat, 'Overall time spent: '+DateTimeToStr(TimeStampToDateTime(MSecsToTimeStamp(getTickCount64-DateStart))));

  //   showmessage('writing done');


  finally
    CloseFile(dat);
    //CloseFile(dat1);
    CloseFile(dat2);

    TR_read.Commit;
    Q_read.Free;
    TR_read.Free;

    TR_write.Commit;
    Q_write.Free;
    TR_write.Free;
  end;
end;

end.

