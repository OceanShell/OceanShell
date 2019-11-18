unit osload_WOD18;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  FileCtrl;

type

  { TfrmloadWOD18 }

  TfrmloadWOD18 = class(TForm)
    btnPreprocessing: TBitBtn;
    FileListBox1: TFileListBox;
    Memo1: TMemo;
    procedure btnPreprocessingClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmloadWOD18: TfrmloadWOD18;
  f_dat: text;

implementation

{$R *.lfm}

{ TfrmloadWOD18 }

procedure TfrmloadWOD18.FormShow(Sender: TObject);
begin
  memo1.Clear;
  FileListBox1.Clear;
end;




procedure TfrmloadWOD18.btnPreprocessingClick(Sender: TObject);
var
i: integer;
count_st,StInFile,StInDataset:integer;
sym:char;
PathSource,FileForRead:string;
begin

  //PathSource:='c:\Users\ako071\AK\datasets\WOD18\YEARLY OSD OBS\test\';
  PathSource:='c:\Users\ako071\AK\datasets\WOD18\YEARLY OSD OBS\data\';
  FileListBox1.Directory:=PathSource;

      StInDataset:=0;
{FLB}for i:=0 to (FileListBox1.Items.Count-1) do begin
      FileForRead:=PathSource+trim(FileListBox1.Items.Strings[i]);
      AssignFile(f_dat,FileForRead);
      reset(f_dat);

      count_st:=0;
      while not EOF(f_dat) do begin
       readln(f_dat,sym);
       if sym='C' then count_st:=count_st+1;
      end;
       closefile(f_dat);
       StInFile:=count_st;
       StInDataset:=StInDataset+StInFile;

      Application.ProcessMessages;

      memo1.Lines.Add(inttostr(i)
      +#9+FileForRead
      +#9+inttostr(StInFile)
      );

      //reset(f_dat);
      //ConvertOSD;

{FLB}end;
       memo1.Lines.Add('StInDataset='+inttostr(StInDataset));

end;





end.

