unit osprofile_flag;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  Tfrmparameters_flag = class(TForm)
    ListBox1: TListBox;

    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1MouseLeave(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmparameters_flag: Tfrmparameters_flag;
  ProfFlag:integer;

implementation

{$R *.lfm}

uses osmain;

procedure Tfrmparameters_flag.FormShow(Sender: TObject);
begin
 ProfFlag:=-9;
 ListBox1.SetFocus; // Передаем фокус на список флагов
end;

procedure Tfrmparameters_flag.ListBox1Click(Sender: TObject);
Var
k:integer;
F_str, buf_str:string;
begin
 if ListBox1.ItemIndex=-1 then exit;

 if ListBox1.ItemIndex<=8 then begin
  F_str:=ListBox1.Items.Strings[ListBox1.ItemIndex];
  k:=0; buf_str:='';
  repeat
   inc(k);
    if F_str[k]<>']' then buf_str:=buf_str+F_str[k];
  until F_str[k]=']';
  ProfFlag:=StrToInt(copy(trim(buf_str),2,length(buf_str)));
 end;

//showmessage(inttostr(ListBox1.ItemIndex));
if ListBox1.ItemIndex=10 then ProfFlag:=999; //below
if ListBox1.ItemIndex=11 then ProfFlag:=777; //above
Close;
end;

procedure Tfrmparameters_flag.ListBox1MouseLeave(Sender: TObject);
begin
 Close;
end;

end.
