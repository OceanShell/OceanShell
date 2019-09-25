unit osload_itp;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DateUtils, FileCtrl;

type
  TfrmLoadITP = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;
    Button2: TButton;
    chkShow: TCheckBox;
    chkWrite: TCheckBox;

    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLoadITP: TfrmLoadITP;
  Path:string;
  Dat:text;

implementation

{$R *.lfm}

uses osmain, Procedures, dm, osstandartqueries;


procedure TfrmLoadITP.Button1Click(Sender: TObject);
Var
fdb:TSearchRec;
begin
SelectDirectory('Select folder', '' , path);
//path:='X:\OceanShell\data\ITP\_new\';
 if path<>'' then begin
   path:=path+'\';
   fdb.Name:='';
    listbox1.Clear;
     FindFirst(Path+'*.dat',faAnyFile, fdb);
   if fdb.Name<>'' then listbox1.Items.Add(fdb.Name);
  while findnext(fdb)=0 do Listbox1.Items.Add(fdb.Name);
 end;
memo1.Clear;
end;


{%ITP 10, profile 1: year day longitude(E+) latitude(N+) ndepths
2007  253.75003  -132.2286  84.9833  755
%pressure(dbar) temperature(C) salinity nobs
  5.9   -1.5629   28.9234  14
  6.9   -1.5627   28.9244   4
  8.0   -1.5628   28.9235   4}
procedure TfrmLoadITP.Button2Click(Sender: TObject);
Var
k,yyyy, ndepth, id, row, levnum, p, oxy_fl:integer;
hour, min, sec, msec:word;
hh,mm,ss,mss:real;
date1, lon, lat:real;
pres, lev, temp, sal, oxy:real;
st, CurFile:string;
stDate, StTime:TDateTime;
stvessel, stnumincruise:string;
withdepth:boolean;
begin
frmosmain.ProgressBar1.Position:=0;
frmosmain.ProgressBar1.Max:=ListBox1.Count;

 if chkWrite.Checked then begin
 {  With odbdm.ib1q1 do begin
    Close;
     SQL.Clear;
     SQL.Text:='Select max(absnum) from STATION';
    Open;
     ID:=odbdm.ib1q1.Fields[0].AsInteger;
    Close;
   end;   }
 end else id:=0;

  For k:=0 to ListBox1.Count-1 do begin

    CurFile:=ListBox1.Items.Strings[k];

    ListBox1.ItemIndex:=k;
    Application.ProcessMessages;

    p:=4; stvessel:='';
    while not (curFile[p]='g') do begin
      stvessel:=stvessel+curFile[p];
      inc(p);
    end;
    stvessel:='ITP'+stvessel;
    stNumincruise:=Inttostr(Strtoint(copy(curFile,length(curFile)-7,4)));

  //  showmessage(copy(curFile,length(curFile)-7,4));

    AssignFile(dat, Path+CurFile); Reset(dat);
    try
      readln(dat, st);
      readln(dat, st);
     // readln(dat, yyyy, date, lon, lat, ndepth);
    // 2008   68.26684  -109.6607  83.9657  757
      yyyy:=StrToInt(trim(copy(st, 1, 4)));
      if lowercase(trim(copy(st, 7, 9)))<>'nan'   then date1:=StrToFloat(trim(copy(st, 7, 9)))  else date1:=-999;
      if lowercase(trim(copy(st, 17, 10)))<>'nan' then lon :=StrToFloat(trim(copy(st, 17, 10))) else lon:=-999;
      if lowercase(trim(copy(st, 28, 8)))<>'nan'  then lat :=StrToFloat(trim(copy(st, 28, 8)))  else lat:=-999;
      if lowercase(trim(copy(st, 37, 4)))<>'nan'  then ndepth:=StrToInt(trim(copy(st, 37, 4)))  else ndepth:=-999;
     except
       Showmessage(CurFile);
    end;


  if (date1<>-999) and (lat<>-999) and (lon<>-999) then begin
    stDate:=EncodeDateDay(yyyy,trunc(date1));
    hh :=frac(date1)*24;  hour:=trunc(hh );
    mm :=frac(hour)*60;  min :=trunc(mm );
    ss :=frac(min )*60;  sec :=trunc(ss );
    mss:=frac(sec )*100; msec:=trunc(mss);
    stTime:=EncodeTime(hour,min,sec,msec);

    if chkShow.Checked then
      memo1.Lines.Add(inttostr(id)
      +#9+Datetostr(stDate)
      +#9+timetostr(sttime)
      +#9+floattostr(lon)
      +#9+floattostr(lat));

     if chkWrite.Checked then begin
      inc(id);
       osstandartqueries.InsertMetadata(ID, 0, Lat, Lon, StDate, StTime,
       'ITP',0,'UNITED STATES', stvessel,-9,'', '', stnumincruise, -9, -9,
       11, stnumincruise, 'WHOI', '');
     end;


     readln(dat, st);
     if copy(st, 1, 5)='%year' then withdepth:=true else withdepth:=false;
     if copy(st,50,3)='oxy' then oxy_fl:=1 else oxy_fl:=0;

     levnum:=0;
     For row:=1 to ndepth do begin
      inc(levnum);
      try

       if withdepth=true then begin
       readln(dat, st);
       // showmessage('true' +'   '+st);
        //%year day pressure(dbar) temperature(C) salinity
           //2009  263.06109    8   -1.8214   33.4690
        pres:=StrToFloat(trim(copy(st, 17, 4)));
        if lowercase(trim(copy(st, 22, 9)))<>'nan'  then temp:=StrToFloat(trim(copy(st, 22, 9))) else temp:=-999;
        if lowercase(trim(copy(st, 32, 9)))<>'nan'  then sal :=StrToFloat(trim(copy(st, 32, 9))) else sal:=-999;
       end;

       if withdepth=false then begin
       readln(dat, st);
           //   showmessage('false' +'   '+st);
        pres:=StrToFloat(trim(copy(st, 1, 5)));
        if lowercase(trim(copy(st, 7, 9)))<>'nan'  then temp:=StrToFloat(trim(copy(st, 7, 9))) else temp:=-999;
        if lowercase(trim(copy(st, 17, 9)))<>'nan' then sal :=StrToFloat(trim(copy(st, 17, 9))) else sal:=-999;
       end;

       if oxy_fl=1 then begin
         oxy:= StrToFloat(trim(copy(st, 42, 9)));
         //if oxy>0 then oxy:=oxy/44661E-3 else oxy:=-999;
       end;

       //Depth_to_pressure(pres,Lat,1,lev);

       except
       Showmessage(CurFile+#9+inttostr(levnum));
      end;


    {  if chkShow.Checked then
      memo1.Lines.Add(floattostrF(Lev,fffixed,5,1)
                  +#9+floattostr(temp)
                  +#9+floattostr(sal)); }
       if chkWrite.Checked then begin
          if temp<>-999 then InsertParameters('P_TEMPERATURE', ID, Lev, temp, 0);
          if sal<>-999  then InsertParameters('P_SALINITY',    ID, Lev, sal , 0);
          if (oxy_fl=1) and (oxy>0) then InsertParameters('P_OXYGEN',      ID, Lev, oxy , 0);
         //odbdm.IBTransaction1.CommitRetaining;
       end;
     End;
  end;
     frmosmain.ProgressBar1.Position:=frmosmain.ProgressBar1.Position+1;
     Application.processMessages;

     CloseFile(Dat);
 end;
 if chkWrite.Checked then begin
  //odbdm.IBTransaction1.Commit;
  frmosmain.UpdateDBContent;
 end;
Showmessage('Done!');
end;

end.
