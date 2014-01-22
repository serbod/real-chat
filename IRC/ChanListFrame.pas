unit ChanListFrame;

interface

uses
  Forms, Classes, Controls, RVScroll, RichView, ExtCtrls, StdCtrls, CRVFData,
  ShellAPI, Windows, SysUtils, Main, IRC, Core, Misc;

type
  TFrameChanList = class(TFrame)
    MesText:    TRichView;
    InfoPanel: TPanel;
    InfoText: TLabel;
    TxtToSend: TEdit;
    btnSortByNames: TButton;
    btnSortByUsers: TButton;
    lbChanCountName: TLabel;
    lbChanCount: TLabel;
    procedure ChanSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SortByNamesClick(Sender: TObject);
    procedure SortByUsersClick(Sender: TObject);
  private
    { Private declarations }
    //table: TRVTableItemInfo;
  public
    { Public declarations }
    Page: TChatPage;
    //slRawChannels: TStringList; // !!!
    ChatClient: TChatClient;
    ChanList: TChanList;
    iChanAdded:   integer; // количество добавленых в список каналов
    constructor Create(APage: TChatPage); reintroduce;
    destructor Destroy; override;
    procedure Redraw();
    procedure onHLink(Sender: TObject; id: Integer);
    procedure AddChanToList(sRawChanName, sRawChanDesc: string);
    procedure ClearMesText();
    procedure DrawTableHead();
    procedure DrawChan(ChanRec: TChanRec);
  end;

implementation

{$R *.dfm}

//====================================
// TChanListPage
constructor TFrameChanList.Create(APage: TChatPage);
begin
  inherited Create(APage.TabSheet);
  self.Parent:=TWinControl(APage.TabSheet);
  self.Page:=APage;

  with TxtToSend do
  begin
    //Parent := InfoPanel;
    Top := 28;
    Anchors := [akLeft,akTop,akRight,akBottom];
    Align := alBottom;
    Font.Name := 'Tahoma';
    //Font.Color := clNavy;
    //Tag := i;
    //OnKeyDown := ChanSearchKeyDown;
  end;

  with btnSortByNames do
  begin
    Caption:= sChanListSortByNames;
  end;

  with btnSortByUsers do
  begin
    Caption:= sChanListSortByUsers;
  end;

  with MesText do
  begin
    //Parent := Self;
    //Align := alClient;
    Style := Form1.MessStyle;
    //BottomMargin := 2;
    //LeftMargin := 2;
    //RightMargin := 2;
    //TopMargin := 2;
    //PopupMenu := Form1.TextWindowPopUp;
    //AnimationMode := rvaniOnFormat;
    //HScrollVisible:=false;
    //tag := i;
    //OnSelect := CopyOnSelect;
    //OnCopy := Form1.CopyRusChar;
    OnJump := OnHLink;
    Format;
  end;
  ChanList:=TChanList.Create;
  //slRawChannels:= TStringList.Create;
end;

destructor TFrameChanList.Destroy;
begin
  //slRawChannels.Free;
  ChanList.Free();
  inherited Destroy;
end;

procedure TFrameChanList.onHLink(Sender: TObject; id: Integer);
var
  RVData: TCustomRVFormattedData;
  ItemNo: integer;
  s: string;
begin
  //with (Form1.PageControl1.ActivePage as TChanListPage) do
  begin
    MesText.GetJumpPointLocation(id, RVData, ItemNo);
    s := MesText.GetItemTextA(ItemNo);
    if Copy(s, 0, 7) = 'http://' then
    begin
      ShellExecute(0, nil, PChar(s), '', '', SW_NORMAL);
      Exit;
    end;
    if Copy(s, 0, 1) = '#' then
    begin
      if not Assigned(ChatClient) then Exit;
      //ChatClient.SendTextFromPage(Page.PageInfo, '/JOIN '+s);
      Say('/JOIN '+s, Page.PageID);
    end;
  end;
end;

procedure TFrameChanList.DrawTableHead();
begin
  {table := TRVTableItemInfo.CreateEx(1, 3, MesText.RVData);

  table.Color := clSkyBlue;
  table.BorderStyle := rvtbColor;
  table.BorderColor := $002E1234;
  table.BorderWidth := 0;
  table.CellBorderStyle := rvtbColor;
  table.CellBorderColor := $002E1234;
  table.CellBorderWidth := 1;
  table.CellPadding := 1;
  table.CellVSpacing := 0;
  table.CellHSpacing := 0;

  table.Cells[0,0].BestWidth := 120;
  table.Cells[0,0].VisibleBorders.Right := False;

  // Добавление строки
  table.Cells[r,0].AddNL(' '+InfoList.Items[r].Name, 6, -1);
  table.Cells[r,1].AddNL(' '+InfoList.Items[r].Data, 0, -1);}
  Main.ParseIrcTextToRV(MesText, sChanListColChan+#09+sChanListColUsers+#09+sChanListColTopic, 2, false);

end;

procedure TFrameChanList.DrawChan(ChanRec: TChanRec);
begin
  Main.ParseIrcTextToRV(MesText, ChanRec.ChanName+#09+IntToStr(ChanRec.ChanUsers)+#09+ChanRec.ChanDesc, 2, false);
end;

procedure TFrameChanList.Redraw();
var
  i,n: integer;
  ChanRec: TChanRec;
begin
  MesText.Clear();
  DrawTableHead();
  n:=0;
  for i:=0 to ChanList.Count-1 do
  begin
    Inc(n);
    if n>50 then
    begin
      Application.ProcessMessages();
      n:=0;
    end;
    ChanRec:=ChanList.Channels[i];
    //Main.ParseIrcTextToRV(MesText, ChanRec.ChanName+' '+IntToStr(ChanRec.ChanUsers)+' '+ChanRec.ChanDesc);
    DrawChan(ChanRec);
  end;
  //MesText.Format();
end;

procedure TFrameChanList.SortByNamesClick(Sender: TObject);
begin
  ChanList.Sort(SortByNames);
  Redraw();
end;

procedure TFrameChanList.SortByUsersClick(Sender: TObject);
begin
  ChanList.Sort(SortByUsers);
  Redraw();
end;

procedure TFrameChanList.ChanSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=13 then MesText.SearchText(TxtToSend.Text,[rvsroDown]);
end;

procedure TFrameChanList.AddChanToList(sRawChanName, sRawChanDesc: string);
var
  i,n: integer;
  sChanName, sChanDesc: string;
begin
  if ChanList.Count=0 then DrawTableHead();

  n:=ChanList.AddRaw(sRawChanName);
  //slRawChannels.Add(sRawChanName);

  if sRawChanName<>'' then
  begin
    //Main.ParseIrcTextToRV(MesText, sRawChanName);
    DrawChan(ChanList.Channels[n]);
  end
  else
  begin
    iChanAdded:=maxint-1;
  end;

  Inc(iChanAdded);
  if iChanAdded>20 then
  begin
    iChanAdded:=0;
    //MesText.FormatTail();
    lbChanCount.Caption:=IntToStr(ChanList.Count);
    Application.ProcessMessages();
  end;
end;

procedure TFrameChanList.ClearMesText();
begin
  ChanList.Clear();
  lbChanCount.Caption:=IntToStr(ChanList.Count);
  MesText.Clear;
  MesText.Format;
end;

end.
