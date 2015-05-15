unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
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
var i:integer;
    b:byte;
    r:real;
begin
  form1.Memo1.Lines.Add('CONTENT BEGIN');
  for i:=0 to 255 do begin
    r:= (sin((i / 255)*2*pi))*127 + 127;
    b:= round(r);
    form1.PaintBox1.Canvas.Pixels[i,b] := rgb(0,0,0);
    form1.Memo1.Lines.Add(inttostr(i)+' : '+inttostr(b)+';');
  end;
  form1.Memo1.Lines.Add('END;');
  form1.Memo1.Lines.Add('');
end;

end.