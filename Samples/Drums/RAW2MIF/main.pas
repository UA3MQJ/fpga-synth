unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
      Edit1.Text := OpenDialog1.FileName;
end;

procedure TForm1.Button2Click(Sender: TObject);
var f:file of byte;
    i:longint;
    b:byte;
begin
  i:=0;
  assignfile(f,edit1.Text);
  reset(f);
  while not(eof(f)) do begin
    read(f, b);
    i := i + 1;
  end;
  closefile(f);

  assignfile(f,edit1.Text);
  reset(f);
  memo1.Lines.Add('WIDTH=8;');
  memo1.Lines.Add('DEPTH='+inttostr(i)+';');
  memo1.Lines.Add('ADDRESS_RADIX=UNS;');
  memo1.Lines.Add('DATA_RADIX=UNS;');
  memo1.Lines.Add('CONTENT BEGIN');
  i:=0;
  while not(eof(f)) do begin
    read(f, b);
    memo1.Lines.Add(inttostr(i)+' : '+inttostr(b)+';');

    i := i + 1;
  end;
  closefile(f);
  memo1.Lines.Add('END;');
  
end;

end.
