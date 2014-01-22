unit FilesFrame;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls, Menus, ActnPopupCtrl,
  Misc, DCC, Core;

type
  TFrameFiles = class(TFrame)
    FilesGrid:  TDrawGrid;
    InfoPanel:  TPanel;
    InfoText: TLabel;
    FilesGridMenu: TPopupMenu;
    mStartFileTransfer: TMenuItem;
    mStopFileTransfer: TMenuItem;
    mResendFile: TMenuItem;
    mDeleteFileTransfer: TMenuItem;
    N7: TMenuItem;
    mOpenFile: TMenuItem;
    mDeleteFile: TMenuItem;
    constructor Create(APage: TChatPage); reintroduce;
    procedure FilesGridOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FilesGridOnDrawCell(Sender: TObject; ACol, ARow: Longint; Rect: TRect; State: TGridDrawState);
    procedure FilesGridPopupClick(Sender: TObject);
  private
    { Private declarations }
    function GetCellText(ACol, ARow:integer): string;
    function ModColor(AColor: TColor; AMod: integer): TColor;
    procedure OnActivateHandler(Sender: TObject);
    procedure OnUpdateStyleHandler(Sender: TObject);
    procedure LoadLanguage();
  public
    { Public declarations }
    PageInfo: TPageInfo;
    procedure ShowStatus;
  end;

var
  sFilesPageCol0:string = 'Имя файла';
  sFilesPageCol1:string = 'Скачано байт';
  sFilesPageCol2:string = 'Всего байт';
  sFilesPageCol3:string = '% готово';
  sFilesPageCol4:string = 'Осталось';
  sFilesPageCol5:string = 'Полное имя файла';
  sFilesPageRcvFrom:string = 'Принимаем от:';
  sFilesPageRcvdFrom:string = 'Принято от:';
  sFilesPageSndgTo:string = 'Передаем для:';
  sFilesPageSndTo:string = 'Передано для:';
  sFilesPageFilename:string = 'Файл:';

implementation

uses Main;

{$R *.dfm}

constructor TFrameFiles.Create(APage: TChatPage);
begin
  inherited Create(APage.TabSheet);
  //self.Parent:=TWinControl(APage.TabSheet);
  //self.Page:=APage;
  APage.OnActivate:=OnActivateHandler;
  //APage.OnDeactivate:=OnDeactivateHandler;
  APage.OnUpdateStyle:=OnUpdateStyleHandler;
  //APage.OnClear:=btnClearClick;

  //PageControl := (AOwner as TPageControl);

  //InfoPanel := TPanel.Create(Self);
  {with InfoPanel do
  begin
    Parent := Self;
    Align := alBottom;
    Height := 48;
    //BorderStyle := bsNone;
  end;}

  {InfoText:=TLabel.Create(Self);
  with InfoText do
  begin
    Parent := InfoPanel;
    Align := alClient;
  end;}

  //FilesGrid := TDrawGrid.Create(Self);
  with FilesGrid do
  begin
    {Parent:=Self;
    Align :=alClient;
    ColCount:=6;
    RowCount:=50;
    FixedCols:=0;
    FixedRows:=1;}
    DefaultRowHeight:=Font.Size+8;
    {Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goColSizing,goRowSelect,goThumbTracking];
    ScrollBars:=ssBoth;
    OnDrawCell:=FilesGridOnDrawCell;}
    ColWidths[0]:=150;
    ColWidths[1]:=80;
    ColWidths[2]:=80;
    ColWidths[3]:=50;
    ColWidths[4]:=50;
    ColWidths[5]:=300;
    {OnMouseDown:=FilesGridOnMouseDown;}
  end;

end;

function TFrameFiles.GetCellText(ACol, ARow:integer): string;
var
  perc: integer;
  dd: double;
  di: integer;
begin
  result:='';
  if ARow=0 then
  begin
  case ACol of
    0: result:=sFilesPageCol0; //'Имя файла';
    1: result:=sFilesPageCol1; //'Скачано байт';
    2: result:=sFilesPageCol2; //'Всего байт';
    3: result:=sFilesPageCol3; //'% готово';
      {begin
        perc:=0;
        if DlFile.FullSize<>0 then
          perc:=Round(DlFile.Pos/(DlFile.FullSize/100));
        result:=intToStr(perc)+'%';
      end;}
    4: result:=sFilesPageCol4; //'Осталось';
    5: result:=sFilesPageCol5; //'Полное имя файла';
  end;
  end;

  if ARow>0 then
  begin
    if ARow>DCCFiles.Count then Exit;
    with (DCCFiles.Items[ARow-1] as TDCCFile) do
    begin
    //while Locked do sleep(1); //!!!
    //Locked:=true;
    case ACol of
      0: result:=Name;
      1: result:=IntToStr(Size);
      2: result:=IntToStr(FullSize);
      3:
      begin
        perc:=0;
        if FullSize<>0 then
          perc:=Round(Pos/(FullSize/100));
        result:=intToStr(perc);
      end;
      4:
      begin
        Result:='--:--';
        dd:=Now-StartTime;
        //di:=FullSize-Pos;
        if FullSize = 0 then Exit;
        PercCompleted:=Pos/(FullSize/100);
        if PercCompleted = 0 then Exit;
        //EndTime:=StartTime+((dd/PercCompleted)*(100-PercCompleted));
        EndTime:=((dd/PercCompleted)*(100-PercCompleted));
        if EndTime<>0 then Result:=TimeToStr(EndTime);
      end;
      5: result:=FullName;
    end;
    //Locked:=false;
    end;
  end;
end;

function TFrameFiles.ModColor(AColor: TColor; AMod: integer): TColor;
var
  RGB,R,G,B: integer;
begin
  RGB:=ColorToRGB(AColor);
  R:=(RGB and $FF0000) shr 16;
  G:=(RGB and $00FF00) shr 8;
  B:=(RGB and $0000FF);
  if (R+AMod) <= 255 then R:=R+AMod else R:=R-AMod;
  if (G+AMod) <= 255 then G:=G+AMod else G:=G-AMod;
  if (B+AMod) <= 255 then B:=B+AMod else B:=B-AMod;
  result:=$00000000 or (R shl 16) or (G shl 8) or B;
end;

procedure TFrameFiles.FilesGridOnDrawCell(Sender: TObject; ACol, ARow: Longint; Rect: TRect; State: TGridDrawState);
var
  text: string;
  X, BX, Y, BY, iperc, FillLines: integer;
  f1, f2: real;
  PrRect: TRect;
  TextSize: TSize;
  CurColor: TColor;
begin
  With FilesGrid.Canvas do
  begin
    Text:=GetCellText(ACol, ARow);
    //if Text='' then
    //  Text:=StringGrid1.Cells[ACol, ARow];
    TextSize:=TextExtent(Text);
    BX:=Rect.Left+1;
    BY:=Rect.Top+1;
    X:=BX;
    Y:=BY;
    if (ARow > 0) then
      if (ARow mod 2)>0 then
      begin
        CurColor:=Brush.Color;
        Brush.Color:=ModColor(CurColor, 20);
        FillRect(Rect);
      end;
    if (ACol=3) and (ARow>0) then
    begin
      iperc:=StrToIntDef(Text,0);
      f1:=Rect.Right-Rect.Left;
      FillLines:=Round(f1*(iperc/100));
      PrRect.Top:=Rect.Top;
      PrRect.Bottom:=Rect.Bottom;
      PrRect.Left:=Rect.Left;
      PrRect.Right:=(Rect.Left+FillLines);
      CurColor:=Brush.Color;
      Brush.Color:=ModColor(CurColor, 40);
      FillRect(PrRect);
      Brush.Color:=CurColor;
      if iperc<>0 then Text:=IntToStr(iperc)+'%'
      else Text:='';
    end;
    if (ACol=1) or (ACol=2) then
    begin
      X:=BX-4+(Rect.Right-Rect.Left)-TextSize.cx;
    end;
    if (ACol=4) or (ACol=3) then
    begin
      X:=BX-1+((Rect.Right-Rect.Left) div 2)-(TextSize.cx div 2);
    end;
    if (ARow=0) then
    begin
      X:=BX;
    end;
    Brush.Style:=bsClear;
    TextRect(Rect,X,Y,Text);
    //TextOut(X,Y,Text);
  end;
end;

procedure TFrameFiles.ShowStatus;
var
  CurRow: integer;
  s: string;
begin
  //if not (Form1.PageControl1.ActivePage is TFilesPage) then Exit;
  CurRow:=FilesGrid.Row;
  if CurRow>DCCFiles.Count then Exit;
  with (DCCFiles.Items[CurRow-1] as TDCCFile) do
  begin
    //while Locked do sleep(1); //!!!
    //Locked:=true;
    InfoText.Canvas.Brush.Color:=clBtnFace;
    InfoText.Canvas.FillRect(Rect(0,0,InfoPanel.Width,InfoPanel.Height));
    s:='';
    if Incoming and Active then s:=s+sFilesPageRcvFrom+' ';
    if Incoming and (not Active) then s:=s+sFilesPageRcvdFrom+' ';
    if (not Incoming) and Active then s:=s+sFilesPageSndgTo+' ';
    if (not Incoming) and (not Active) then s:=s+sFilesPageSndTo+' ';
    s:=s+RemoteUserNick;
    InfoText.Canvas.TextOut(1,1, s);
    InfoText.Canvas.TextOut(1,16, sFilesPageFilename+' '+FullName);
    InfoText.Canvas.TextOut(200,1, 'ID='+IntToStr(id));
    if fs = nil then Exit;
    //Locked:=false;
  end;
end;

procedure TFrameFiles.FilesGridOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: integer;
begin
  if Button<>mbRight then Exit;
  //with (Form1.PageControl1.ActivePage as TFilesPage) do
  begin
    FilesGrid.MouseToCell(X, Y, ACol, ARow);
    if ARow < 1 then Exit;
    FilesGrid.Row:=ARow;
    //...
    FilesGridMenu.Popup(Form1.Left+Left+X+10, Form1.Top+Top+Y+10);
  end;
end;

procedure TFrameFiles.FilesGridPopupClick(Sender: TObject);
// Обработчик меню таблицы файлов
var
  m: TMenuItem;
  i: integer;
begin
  if Sender is TMenuItem then m:=(Sender as TMenuItem) else Exit;
  i:=FilesGrid.Row;
  if i>DCCFiles.Count then Exit;

  if m = mStopFileTransfer then
  begin // Остановить
    with (DCCFiles[i-1] as TDCCFile) do
    begin
      if not Active then Exit;
      DCC_Stop(RemoteUserNick, ID);
    end;
    Exit;
  end;

  if m = mResendFile then
  begin // Начать заново
    with (DCCFiles[i-1] as TDCCFile) do
    begin
      if Active or Incoming then Exit;
      DCC_Start(RemoteUserNick, 'resume '+Name+' '+IntToStr(FullSize)+' '+IntToStr(ID), nil);
    end;
  end;

  if m = mDeleteFileTransfer then
  begin // Удалить загрузку
    if (DCCFiles[i-1] as TDCCFile).Active then Exit;
    DCCFiles.Delete(i-1);
  end;

  if m = mDeleteFile then
  begin // Удалить файл (!!!)
  end;
end;

procedure TFrameFiles.OnActivateHandler(Sender: TObject);
begin
  FilesGrid.Repaint;
  ShowStatus;
  Application.ProcessMessages;
end;

procedure TFrameFiles.LoadLanguage();

function GetStr(Name: string; s: string): string;
begin
  result:=Core.LangIni.ReadString('FilesFrame', Name, s);
end;

begin
  if not Assigned(Core.LangIni) then Exit;
  try
    // FilesGridMenu
    mStartFileTransfer.Caption:=GetStr('mStartFileTransfer.Caption', mStartFileTransfer.Caption);
    mStopFileTransfer.Caption:=GetStr('mStopFileTransfer.Caption', mStopFileTransfer.Caption);
    mResendFile.Caption:=GetStr('mResendFile.Caption', mResendFile.Caption);
    mDeleteFileTransfer.Caption:=GetStr('mDeleteFileTransfer.Caption', mDeleteFileTransfer.Caption);
    mOpenFile.Caption:=GetStr('mOpenFile.Caption', mOpenFile.Caption);
    mDeleteFile.Caption:=GetStr('mDeleteFile.Caption', mDeleteFile.Caption);
    // Other
    sFilesPageCol0:=GetStr('sFilesPageCol0', sFilesPageCol0);
    sFilesPageCol1:=GetStr('sFilesPageCol1', sFilesPageCol1);
    sFilesPageCol2:=GetStr('sFilesPageCol2', sFilesPageCol2);
    sFilesPageCol3:=GetStr('sFilesPageCol3', sFilesPageCol3);
    sFilesPageCol4:=GetStr('sFilesPageCol4', sFilesPageCol4);
    sFilesPageCol5:=GetStr('sFilesPageCol5', sFilesPageCol5);
    sFilesPageRcvFrom:=GetStr('sFilesPageRcvFrom', sFilesPageRcvFrom);
    sFilesPageRcvdFrom:=GetStr('sFilesPageRcvdFrom', sFilesPageRcvdFrom);
    sFilesPageSndgTo:=GetStr('sFilesPageSndgTo', sFilesPageSndgTo);
    sFilesPageSndTo:=GetStr('sFilesPageSndTo', sFilesPageSndTo);
    sFilesPageFilename:=GetStr('sFilesPageFilename', sFilesPageFilename);
  finally
  end;
end;

procedure TFrameFiles.OnUpdateStyleHandler(Sender: TObject);
begin
  LoadLanguage();
end;

end.
