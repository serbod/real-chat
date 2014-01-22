unit colors;

interface

uses
  SysUtils, Classes, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Types;

type
  TfrmColors = class(TForm)
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    StaticText12: TStaticText;
    StaticText13: TStaticText;
    StaticText14: TStaticText;
    StaticText15: TStaticText;
    StaticText16: TStaticText;
    procedure InsertColors(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmColors: TfrmColors;

implementation
uses ChatPage, Core;

{$R *.dfm}

procedure TfrmColors.InsertColors(Sender: TObject);
var
	ColorText, ColorStr :String;
  iSelStart  :Integer;
begin
  if not Assigned(PagesManager) then Exit;
  with (Core.PagesManager.GetActivePage.Frame as TChatFrame) do
  begin
    //EditInsertSymbol(IntToStr(TStaticText(Sender).Tag);
	  ColorText := TxtToSend.text;
    iSelStart := TxtToSend.SelStart;
    ColorStr:='0'+IntToStr(TStaticText(Sender).Tag);
    if Length(ColorStr)>2 then ColorStr := IntToStr(TStaticText(Sender).Tag);
    Insert(ColorStr, ColorText, iSelStart+1);
	  TxtToSend.text := ColorText;
    Close;
    TxtToSend.SelStart := iSelStart + Length(ColorStr);
  end;
end;

procedure TfrmColors.FormShow(Sender: TObject);
var
  ChatFrame: TChatFrame;
  CaretPos: TPoint;
begin
  if not Assigned(PagesManager) then Exit;
  if not (Core.PagesManager.GetActivePage.Frame is TChatFrame) then Exit;
  ChatFrame:=(Core.PagesManager.GetActivePage.Frame as TChatFrame);

  //ChatFrame.TxtToSend.GetCaretPos(Cpos);
  CaretPos:=ChatFrame.TxtToSend.CaretPos;
  self.Left := Core.MainForm.Left + ChatFrame.TxtToSend.Left + CaretPos.X;
  self.Top := Core.MainForm.Top + ChatFrame.TxtToSend.Top
  + ChatFrame.MessPanel.Top + CaretPos.Y
  + ChatFrame.TxtToolBar.Height - self.Height;

  ChatFrame.EditInsertSymbol(#3);
end;

end.
