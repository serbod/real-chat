unit TextDecoder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Clipbrd;

type
  TfrmTextDecoder = class(TForm)
    GroupBox1: TGroupBox;
    memoDecodedText: TMemo;
    trbarAlpha: TTrackBar;
    timer100ms: TTimer;
    procedure trbarAlphaChange(Sender: TObject);
    procedure timer100msTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    CurClipboard: String;
  public
    { Public declarations }
  end;

var
  frmTextDecoder: TfrmTextDecoder;

implementation

{$R *.dfm}

procedure TfrmTextDecoder.trbarAlphaChange(Sender: TObject);
begin
  AlphaBlendValue:=trbarAlpha.Position;
end;

procedure TfrmTextDecoder.timer100msTimer(Sender: TObject);
var
  s: string;
begin
  s:=Clipboard.AsText;
  if s=CurClipboard then Exit;
  CurClipboard:=s;
  memoDecodedText.Lines.Clear();

  memoDecodedText.Lines.Add(s);
  memoDecodedText.Lines.Add(UTF8Decode(s));
  memoDecodedText.Lines.Add(UTF8ToAnsi(s));
  memoDecodedText.Lines.Add(s);

end;

procedure TfrmTextDecoder.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Release();
end;

end.
