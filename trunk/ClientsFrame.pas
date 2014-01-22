{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  TFrameClients - страница списка всех закладок, клиентов, отладочной информации.

}
unit ClientsFrame;

interface

uses
  Forms, ImgList, Controls, ComCtrls, StdCtrls, ExtCtrls,
  RVScroll, RichView, Classes, SysUtils, Misc, Core, ToolWin;

type
  TFrameClients = class(TFrame)
    tvClientsList: TTreeView;
    MesText: TRichView;
    panTop: TPanel;
    Splitter1: TSplitter;
    tbButtons: TToolBar;
    tbtnRefresh: TToolButton;
    tbtnConnect: TToolButton;
    tbtnClear: TToolButton;
    ToolButton4: TToolButton;
    tbtnAddIRCClient: TToolButton;
    tbtnAddIChatClient: TToolButton;
    tbtnRemoveClient: TToolButton;
    panRight: TPanel;
    tbtnVScrollStop: TToolButton;
    procedure tbtnRefreshClick(Sender: TObject);
    procedure tbtnConnectClick(Sender: TObject);
    procedure tvClientsListClick(Sender: TObject);
    procedure tbtnAddIRCClientClick(Sender: TObject);
    procedure tbtnRemoveClientClick(Sender: TObject);
    procedure tbtnAddIChatClientClick(Sender: TObject);
    procedure tbtnClearClick(Sender: TObject);
    procedure tvClientsListDblClick(Sender: TObject);
    procedure tbtnVScrollStopClick(Sender: TObject);
  private
    { Private declarations }
    LastPage: TChatPage;
    LastParent: TWinControl;
    procedure LoadLanguage();
    procedure OnActivateHandler(Sender: TObject);
    procedure OnDeactivateHandler(Sender: TObject);
    procedure OnUpdateStyleHandler(Sender: TObject);
    procedure AddClient(ClientName: string);
  public
    { Public declarations }
    Page: TChatPage;
    constructor Create(APage: TChatPage); reintroduce;
    procedure Refresh();
    procedure ClearMesText();
    procedure ToggleVScrollStop();
  end;

implementation
uses Main;

type
  TDataTreeNode = class(TTreeNode)
  public
    Client: TChatClient;
    PageID: integer;
  end;

{$R *.dfm}

constructor TFrameClients.Create(APage: TChatPage);
begin
  inherited Create(APage.TabSheet);
  self.Page:=APage;
  APage.OnActivate:=OnActivateHandler;
  APage.OnDeactivate:=OnDeactivateHandler;
  APage.OnUpdateStyle:=OnUpdateStyleHandler;
  MesText.Style:=Form1.MessStyle;
  self.tvClientsList.Images:=Form1.ImageList16;
  Refresh();
end;

procedure TFrameClients.Refresh();
var
  i, n: integer;
  tmpNode, tmpSubnode: TDataTreeNode;
  Client: TChatClient;
  PageInfo: TPageInfo;

procedure AddPageByID(ID: integer; AClient: TChatClient = nil);
begin
  if Core.PagesManager.GetPageInfo(ID, PageInfo) then
  begin
    tmpSubnode:=TDataTreeNode.Create(tvClientsList.Items);
    tmpSubnode.ImageIndex:=PageInfo.ImageIndex;
    tmpSubnode.SelectedIndex:=PageInfo.ImageIndex;
    tmpSubnode.PageID:=PageInfo.ID;
    tmpSubnode.Client:=AClient;
    tvClientsList.Items.AddNode(tmpSubnode, tmpNode, PageInfo.Caption, nil, naAddChild);
    tmpSubnode.MakeVisible;
  end;
end;

begin
  self.tvClientsList.Items.Clear;
  // добавляем верховный узел
  tmpNode:=TDataTreeNode.Create(tvClientsList.Items);
  //tmpNode:=tvClientsList.Items.Add(nil, 'RealChat');
  tmpNode.ImageIndex:=0;
  tmpNode.StateIndex:=6;
  tvClientsList.Items.AddNode(tmpNode, nil, 'RealChat', nil, naAdd);

  // Info page
  AddPageByID(ciInfoPageID);

  // Notes page
  AddPageByID(ciNotesPageID);

  // Files page
  AddPageByID(ciFilesPageID);

  // добавляем клиентов
  for i:=0 to ClientsManager.ClientsCount-1 do
  begin
    Client:=ClientsManager.GetClient(i);
    //tmpNode:=tvClientsList.Items.Add(nil, 'Client');
    tmpNode:=TDataTreeNode.Create(tvClientsList.Items);
    tmpNode.Text:=Client.InfoConnection;
    tmpNode.ImageIndex:=Client.InfoProtocolID;
    tmpNode.SelectedIndex:=Client.InfoProtocolID;
    tmpNode.StateIndex:=5;
    tmpNode.Client:=Client;
    if Client.Active then tmpNode.StateIndex:=6;
    tvClientsList.Items.AddNode(tmpNode, nil, tmpNode.Text, nil, naAdd);

    for n:=0 to Client.PagesIDCount-1 do
    begin
      AddPageByID(Client.PagesIDList[n], Client);
    end;
  end;

end;

procedure TFrameClients.tbtnRefreshClick(Sender: TObject);
begin
  Refresh();
end;

procedure TFrameClients.tbtnConnectClick(Sender: TObject);
var
  Client: TChatClient;
begin
  if Assigned(tvClientsList.Selected) then
  begin
    Client:=TDataTreeNode(tvClientsList.Selected).Client;
    if Assigned(Client) then Client.Connect();
  end;
  //Core.PagesManager.ActivatePage(PageID);
end;

procedure TFrameClients.tvClientsListClick(Sender: TObject);
var
  PageID: integer;
  ChatPage: TChatPage;
begin
  if not Assigned(tvClientsList.Selected) then Exit;
  if Assigned(LastPage) then LastPage.Frame.Parent:=LastParent;
  LastPage:=nil;
  PageID:=TDataTreeNode(tvClientsList.Selected).PageID;
  ChatPage:=PagesManager.GetPage(PageID);
  if Assigned(ChatPage) then
  begin
    if (ChatPage.Frame.Parent is TTabSheet) then
    begin
      MesText.Visible:=False;
      LastPage:=ChatPage;
      LastParent:=ChatPage.Frame.Parent;
      ChatPage.Frame.Parent := panRight;
      Core.PagesManager.ActivePageID:=PageID;
      Exit;
    end;
  end;
  MesText.Visible:=True;
  //Core.PagesManager.ActivatePage(PageID);
end;

procedure TFrameClients.tvClientsListDblClick(Sender: TObject);
var
  PageID: integer;
begin
  if Assigned(tvClientsList.Selected) then
  begin
    PageID:=TDataTreeNode(tvClientsList.Selected).PageID;
    Core.PagesManager.ActivatePage(PageID);
  end;
end;


procedure TFrameClients.ClearMesText();
begin
  MesText.Clear;
  MesText.Format;
end;

procedure TFrameClients.OnActivateHandler(Sender: TObject);
begin
  self.Refresh();
end;

procedure TFrameClients.OnDeactivateHandler(Sender: TObject);
begin
  if Assigned(LastPage) then LastPage.Frame.Parent:=LastParent;
  MesText.Visible:=True;
end;

procedure TFrameClients.AddClient(ClientName: string);
var
  sl: TStringList;
  IniName: string;
begin
  IniName:=ClientName+IntToStr(Core.ClientsManager.ClientsCount)+'.ini';
  Core.AddChatClient(ClientName, IniName);

  sl:=MainConf.GetStrings('ChatClientsList');
  sl.Add(ClientName+sl.NameValueSeparator+IniName);
  MainConf['ChatClientsList']:=sl.Text;

  self.Refresh();
end;

procedure TFrameClients.tbtnAddIRCClientClick(Sender: TObject);
begin
  AddClient('IRC');
end;

procedure TFrameClients.tbtnAddIChatClientClick(Sender: TObject);
begin
  AddClient('iChat');
end;

procedure TFrameClients.tbtnRemoveClientClick(Sender: TObject);
var
  PageID, i: integer;
  ChatClient: TChatClient;
  sl: TStringList;
  s: string;
begin
  if not Assigned(tvClientsList.Selected) then Exit;

  begin
    //PageID:=TDataTreeNode(tvClientsList.Selected).PageID;
    ChatClient:=TDataTreeNode(tvClientsList.Selected).Client;
    if not Assigned(ChatClient) then Exit;
    // Remove chat client record from MainConf clients list
    sl:=MainConf.GetStrings('ChatClientsList');
    s:=ChatClient.InfoProtocolName+sl.NameValueSeparator+ChatClient.InfoConfName;
    i:=sl.IndexOf(s);
    if i>=0 then sl.Delete(i);
    MainConf['ChatClientsList']:=sl.Text;

    Core.ClientsManager.RemoveClient(ChatClient);
    {if Core.ClientsManager.GetClientByPageID(PageID, ChatClient) then
    begin
      Core.ClientsManager.RemoveClient(ChatClient);
    end; }
  end;


  self.Refresh();
end;

procedure TFrameClients.LoadLanguage();

function GetStr(Name: string; s: string): string;
begin
  result:=Core.LangIni.ReadString('StatusPage', Name, s);
end;

begin
  if not Assigned(Core.LangIni) then Exit;
  try
    tbtnAddIChatClient.Hint:=GetStr('tbtnAddIChatClient.Hint', tbtnAddIChatClient.Hint);
    tbtnAddIRCClient.Hint:=GetStr('tbtnAddIRCClient.Hint', tbtnAddIRCClient.Hint);
    tbtnClear.Hint:=GetStr('tbtnClear.Hint', tbtnClear.Hint);
    tbtnConnect.Hint:=GetStr('tbtnConnect.Hint', tbtnConnect.Hint);
    tbtnRefresh.Hint:=GetStr('tbtnRefresh.Hint', tbtnRefresh.Hint);
    tbtnRemoveClient.Hint:=GetStr('tbtnRemoveClient.Hint', tbtnRemoveClient.Hint);
  finally
  end;
end;

procedure TFrameClients.OnUpdateStyleHandler(Sender: TObject);
begin
  LoadLanguage();
end;

procedure TFrameClients.tbtnClearClick(Sender: TObject);
begin
  ClearMesText();
end;

procedure TFrameClients.ToggleVScrollStop();
begin
  with MesText do
  begin
    if (rvoScrollToEnd in Options) then
      Options := Options-[rvoScrollToEnd]
    else
      Options := Options+[rvoScrollToEnd];
    //mFreezeScrolling.Checked := not (rvoScrollToEnd in Options);
    tbtnVScrollStop.Down := not (rvoScrollToEnd in Options);
  end;
end;

procedure TFrameClients.tbtnVScrollStopClick(Sender: TObject);
begin
  ToggleVScrollStop();
end;

end.
