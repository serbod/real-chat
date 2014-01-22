{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  TPageInfo - подробная информация о странице и ее свойствах
    PageType - see ciXxxxxPageType

  TChatClient - базовый класс для протоколов клиентов чата. Содержит
  набор свойств и методов, которые обязательно должны быть у потомков.

  TChatPage - Объект, описывающий произвольную страницу. Это может быть
  страница чата, файлов, состояния, настроек, итд..

  TPagesManager - Менеджер страниц чата. Содержит список всех страниц чата 
  и методы для управления страницами.

  TClientsManager - Менеджер клиентов чата. Содержит список всех клиентов
  и методы для управления клиентами, рассылки сообщений.
}
unit Core;

interface
uses Contnrs, Types, Main, Misc, ComCtrls, Forms, Controls, SysUtils,
  Graphics, Classes, Menus, MainOptions, Configs, Plugins, IniFiles;

type
  TPageInfo = record
    ID: integer;
    sServer, sChan, sNick, sMode: string;
    sPassword: string;
    Caption: string;
    Hint: string;
    ImageIndexDefault: integer;
    ImageIndex: integer;
    Visible: boolean;
    PageType: integer; // see ciXxxxxPageType
    bUseStateImages: boolean;
  end;

  TClientToolButton = class(TObject)
  public
    Hint: string;
    ImageIndex: integer;
    Command: string;
    OnClick: TNotifyEvent;
  end;

  TChatClient = class(TObject)
  protected
    FInfoAbout: string;
    FInfoConnection: string;
    FInfoProtocolID: integer;
    FInfoProtocolName: string;
    FInfoConfName: string;
    //ClientConf: TObject;
    FActive: boolean;
  public
    PagesIDCount: integer;
    PagesIDList: array of integer;
    constructor Create(ConfFileName: string); virtual;
    property Active: boolean read FActive;
    property InfoAbout: string read FInfoAbout;
    property InfoConnection: string read FInfoConnection;
    property InfoProtocolID: integer read FInfoProtocolID;
    property InfoProtocolName: string read FInfoProtocolName;
    property InfoConfName: string read FInfoConfName;
    // Получить список кнопок для общей панели инструментов
    function GetMainToolButtons(PageID: integer): TObjectList; virtual;
    // Получить список меню для закладки страницы
    function GetTabMenuItems(PageID: integer): TObjectList; virtual;
    // Process text message and send it to server
    // Return empty string if message processed succesfully
    function SendTextFromPage(PageInfo: TPageInfo; sText: string): string; virtual; abstract;
    // Send string directly to server
    function SendTextToServer(sText: string): boolean; virtual; abstract;
    // Show some text on chat page with specified ID
    function ShowText(PageID: integer; sText: string): boolean;
    function Connect(): boolean; virtual; abstract;
    function Disconnect(): boolean; virtual; abstract;
    function GetOption(sName: string): string; virtual;
    procedure SetOption(sName, sData: string); virtual;
    // Вызывается при закрытии страницы
    function ClosePage(PageID: integer): boolean; virtual; abstract;
    // Изменить список идентификаторов страниц
    procedure ModifyPagesList(PageID, Mode: integer);
    function HavePageID(PageID: integer): boolean;
    function GetConf(): TConf; virtual;
    procedure On1sTimer(); virtual;
    procedure LoadLanguage(); virtual; abstract;
    // Обработчик контекстного меню списка пользователей
    function UserListContextMenu(PageID: integer; ulcm: TPopupMenu): boolean; virtual;
  end;

  TChatPage = class(TObject)
  private
    FOnActivate: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    FOnUpdateStyle: TNotifyEvent;
    FOnClear: TNotifyEvent;
  public
    PageID: integer;
    PageInfo: TPageInfo;
    Frame: TFrame;
    TabSheet: TTabSheet;
    destructor Destroy(); override;
    procedure SetActive(ActiveState: boolean);
    procedure UpdateStyle();
    procedure Clear();
    // Insert text in edit field
    procedure InsertText(InsText: string);
    //procedure LoadLanguage();
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnUpdateStyle: TNotifyEvent read FOnUpdateStyle write FOnUpdateStyle;
    property OnClear: TNotifyEvent read FOnClear write FOnClear;
  end;


  TPagesManager = class(TObject)
  private
    LastPageID: integer;
    FPagesCount: integer;
    FActivePageID: integer;
    procedure FSetActivePageID(PageID: integer);
  public
    PagesList: TObjectList;
    constructor Create();
    destructor Destroy(); override;
    property PagesCount: integer read FPagesCount;
    property ActivePageID: integer read FActivePageID write FSetActivePageID;
    function CreatePage(PageInfo: TPageInfo; Frame: TFrame = nil): integer;
    function RemovePage(PageID: integer): boolean;
    function GetPageInfo(PageID: integer; var PageInfo: TPageInfo): boolean;
    function GetPage(PageID: integer): TChatPage;
    function GetPageByIndex(Index: integer): TChatPage;
    function GetPagePassword(PageID: integer): string;
    function GetActivePage(): TChatPage;
    procedure SetPageVisible(PageID: integer; AVisible: boolean);
    function GetPageVisible(PageID: integer): boolean;
    function SetPageInfo(PageInfo: TPageInfo): boolean;
    procedure ActivatePage(PageID: integer);
    procedure ChangePageIcon(PageID, IconID: integer);
    procedure MovePage(PageID, ParentPageID: integer); // Move PageID next to ParentPageID
  end;

  TClientsManager = class(TObject)
  private
    FClientsCount: integer;
    FClientsList: TObjectList;
  public
    constructor Create();
    destructor Destroy(); override;
    property ClientsCount: integer read FClientsCount;
    procedure AddClient(NewClient: TChatClient);
    procedure RemoveClient(ChatClient: TChatClient);
    function GetClientByPageID(PageID: integer; var ChatClient: TChatClient): boolean;
    function SendMsgFromPage(PageID: integer; sText: string): string;
    //function SendMsgToAll(sText: string): string;
    //function DisconnectAll(): boolean;
    function GetClient(ClientIndex: integer): TChatClient;
  end;

  procedure CoreStart();
  procedure CoreStop();

  procedure AddChatClient(ClientName, ClientConfName: string);
  procedure Say(sText: string; PageID: integer = -1; AddToHistory: boolean = false);
  procedure DebugMessage(MsgText: string);
  procedure ShowRawText(PageID: integer; sText: string);
  procedure ParseIRCTextByPageID(PageID: integer; sText: string);
  function  TimeTemplate(): String;
  procedure FlashMessage(PageID: integer; strAuthor, strText: string; IsPrivate: boolean);
  procedure PlayNamedSound(SoundName: string; ChatClient: TChatClient = nil);
  procedure AddNote(sUserName, sNoteText: string);
  procedure GrabNotesByKeywords(AuthorName, Text: string);
  procedure ShowPrivateMsg(PageID: integer; sNick, sText:String);
  procedure DownloadAvatar(UserNick, AvatarURL: string);
  function AddIcon16(FileName: string): integer;
  // Userlist
  procedure AddNicks(PageID: integer; sNickList: String; ImgIndex: integer = -1; ClearList:boolean = false);
  procedure AddNick(PageID: integer; sNick: String; ImgIndex: integer = -1);
  procedure RemoveNick(PageID: integer; sNick: string; RemoveAll: boolean = false);
  function  ChangeNick(PageID: integer; sNick, sNewNick: string; ImgIndex: integer = -1): boolean;
  procedure SetUserlistStyle(PageID: integer; sStyle: string);

  procedure ShowOptions();
  procedure ShowSmiles();
  procedure HideSmiles();
  procedure ShowColors();
  procedure HideColors();

  procedure EnterCommandBox(Template, Caption, DefaultText: string; PageID: integer = -1);
  procedure ShowInfoList(InfoList: TInfoList; ChatClient: TChatClient);
  // Modify timer event
  procedure ModTimerEvent(Oper, PageID, Delay: integer; Cmd: string);
  procedure SetNewFonts();
  procedure ChangeLanguage();

  procedure ClearPageText(PageID: integer);
  procedure ClearPageInfo(var PageInfo: TPageInfo);

var
  PagesManager: TPagesManager;
  ClientsManager: TClientsManager;
  PluginsManager: TPluginsManager;
  MainConf: TMainConfig;
  MainForm: TForm1;
  LangIni: TMemIniFile;

  added: boolean = False;        // признак того, что набраный текст добавлен в историю
  slLastTyped: TLastTypedList;   // Last typed text list
  olPrivWndList:TObjectList;     // Separate forms list.
  olThreadsList:TObjectList;

  ciDebugPageID: integer;
  ciNotesPageID: integer;
  ciFilesPageID: integer;
  ciInfoPageID: integer;
  glHomePath: string;
  glUserPath: string;

const
  sRealVersion    = 'RealChat 0.3.14';

  csDebugTabName  = 'Status';
  csNotesTabName  = 'Notes';
  csFilesTabName  = 'Files';
  csInfoTabName   = 'Info';

  ciUncheckedIndex    = 5;
  ciCheckedIndex      = 6;
  ciGroupIndex        = 9;

  ciIconIdPrivateMsg  = 7;
  ciIconIdHaveNewMsg  = 1;
  ciIconIdHavePvtMsg  = 2;

  ciChatPageType      = 0;
  ciClientsPageType   = 1;
  ciFilesPageType     = 2;
  ciChanListPageType  = 3;
  ciInfoPageType      = 4;

  ciIconNormal = 20; // Normal user
  ciIconBanned = 21; // Banned user
  ciIconAway   = 22; // User away
  ciIconOper   = 23; // Oper
  ciIconHidden = 24; // Hidden
  ciIconVoiced = 25; // Voiced


implementation
uses ChatPage, ClientsFrame, ChanListFrame, RichView, Sounds,
OptionsForm, IRC, iChatUnit, Colors, Timer, DCC, EnterCmd, InfoFrame,
FilesFrame, StartupWizard, Smiles;


//=======================
//===== TChatClient =====
constructor TChatClient.Create(ConfFileName: string);
begin
  inherited Create();
  FInfoConfName:=ConfFileName;
end;

function TChatClient.ShowText(PageID: integer; sText: string): boolean;
var
  i: integer;
begin
  result:=true;
  for i:=0 to self.PagesIDCount-1 do
  begin
    if self.PagesIDList[i]=PageId then
    begin
      ParseIRCTextByPageID(PageID, sText);
      Exit;
    end;
  end;
  if self.PagesIDCount > 0 then
  begin
    ParseIRCTextByPageID(self.PagesIDList[0], sText);
    Exit;
  end;
  result:=false;
  ParseIRCTextByPageID(ciDebugPageID, sText);
end;

procedure TChatClient.ModifyPagesList(PageID, Mode: integer);
// Mode 1-add, -1-del
var
  i: integer;
  found: boolean;
begin
  if Mode = 1 then
  begin
    Inc(self.PagesIDCount);
    SetLength(self.PagesIDList, self.PagesIDCount);
    self.PagesIDList[self.PagesIDCount-1]:=PageID;
  end
  else if Mode = -1 then
  begin
    found:=false;
    for i:=0 to self.PagesIDCount-1 do
    begin
      if self.PagesIDList[i] = PageID then found:=true;
      if found and (i < self.PagesIDCount-1) then self.PagesIDList[i]:=self.PagesIDList[i+1];
    end;
    if found then
    begin
      Dec(self.PagesIDCount);
      SetLength(self.PagesIDList, self.PagesIDCount);
    end;
  end;
end;

function TChatClient.HavePageID(PageID: integer): boolean;
var
  i: integer;
begin
  for i:=0 to self.PagesIDCount-1 do
  begin
    if self.PagesIDList[i] = PageID then
    begin
      result:=true;
      Exit;
    end;
  end;
  result:=false;
end;

function TChatClient.GetOption(sName: string): string;
begin
  result:='';
end;

procedure TChatClient.SetOption(sName, sData: string);
begin
end;

function TChatClient.GetConf(): TConf;
begin
  result:=nil;
end;

function TChatClient.GetMainToolButtons(PageID: integer): TObjectList;
begin
  result:=nil;
end;

function TChatClient.GetTabMenuItems(PageID: integer): TObjectList;
begin
  result:=nil;
end;

procedure TChatClient.On1sTimer();
begin
end;

function TChatClient.UserListContextMenu(PageID: integer; ulcm: TPopupMenu): boolean;
begin
  result:=true;
end;

//=======================
//===== TChatPage
destructor TChatPage.Destroy();
begin
  if Assigned(self.Frame) then FreeAndNil(self.Frame);
  if Assigned(self.TabSheet) then FreeAndNil(Self.TabSheet);
  inherited Destroy();
end;

procedure TChatPage.SetActive(ActiveState: boolean);
begin
  if not Assigned(self.Frame) then Exit;
  if ActiveState then
  begin
    if Assigned(FOnActivate) then FOnActivate(self);
  end
  else
  begin
    if Assigned(FOnDeactivate) then FOnDeactivate(self);
  end;
end;

procedure TChatPage.UpdateStyle();
begin
  if Assigned(FOnUpdateStyle) then FOnUpdateStyle(self);
end;

//procedure TChatPage.LoadLanguage();
//begin
//end;

procedure TChatPage.Clear();
begin
  if Assigned(FOnClear) then FOnClear(self);
end;

procedure TChatPage.InsertText(InsText: string);
begin
  if (Self.Frame is TChatFrame) then (Self.Frame as TChatFrame).InsertText(InsText);
  // InfoFrame
  // ClientsFrame
  // ChanListFrame
end;

//=========================
//===== TPagesManager =====
//=========================
constructor TPagesManager.Create();
begin
  self.PagesList:=TObjectList.Create(true);
end;

destructor TPagesManager.Destroy();
begin
  self.PagesList.Clear();
  self.PagesList.Free();
end;

function TPagesManager.CreatePage(PageInfo: TPageInfo; Frame: TFrame = nil): integer;
var
  NewPage: TChatPage;
begin
  result:=-1;
  Inc(self.LastPageID);
  PageInfo.ID:=self.LastPageID;
  NewPage:=TChatPage.Create();
  NewPage.PageID:=self.LastPageID;
  NewPage.PageInfo:=PageInfo;
  NewPage.TabSheet:=TTabSheet.Create(Form1.PageControl1);
  NewPage.TabSheet.PageControl:=Form1.PageControl1;
  NewPage.TabSheet.Caption:=PageInfo.Caption;
  NewPage.TabSheet.ParentShowHint:=false;
  NewPage.TabSheet.ImageIndex:=PageInfo.ImageIndex;
  NewPage.TabSheet.TabVisible:=PageInfo.Visible;
  NewPage.TabSheet.Tag:=self.LastPageID;
  if PageInfo.PageType = ciChatPageType then
  begin
    if Frame=nil then Frame:=TChatFrame.Create(NewPage);
  end

  else if PageInfo.PageType = ciFilesPageType then
  begin
    if Frame=nil then Frame:=TFrameFiles.Create(NewPage);
  end

  else if PageInfo.PageType = ciChanListPageType then
  begin
    if Frame=nil then Frame:=TFrameChanList.Create(NewPage);
  end

  else if PageInfo.PageType = ciClientsPageType then
  begin
    if Frame=nil then Frame:=TFrameClients.Create(NewPage);
  end

  else if PageInfo.PageType = ciInfoPageType then
  begin
    if Frame=nil then Frame:=TFrameInfo.Create(NewPage);
  end

  else
  begin
    PageInfo.PageType := ciChatPageType;
    if Frame=nil then Frame:=TChatFrame.Create(NewPage);
  end;
  NewPage.Frame:=Frame;
  NewPage.Frame.Parent:=NewPage.TabSheet;
  NewPage.Frame.Align:=alClient;
  self.PagesList.Add(NewPage);
  FPagesCount:=PagesList.Count;
  result:=self.LastPageID;
  if Assigned(PluginsManager) then PluginsManager.BroadcastMsg('NEW_PAGE '+IntToStr(result)+' '+Norm(PageInfo.Caption));
end;

function TPagesManager.RemovePage(PageID: integer): boolean;
var
  i: integer;
  AChatPage: TChatPage;
  PageActive: boolean;
begin
  result:=false;
  PageActive:=false;
  AChatPage:=GetActivePage();
  if AChatPage <> nil then
  begin
    PageActive:=(AChatPage.PageID=PageID);
  end;
  for i:=self.PagesList.Count-1 downto 0 do
  begin
    if (self.PagesList[i] as TChatPage).PageID <> PageID then Continue;
    //(self.PagesList[i] as TChatPage).Free();
    self.PagesList.Delete(i);
    FPagesCount:=PagesList.Count;
    result:=true;
    if (PageActive) and (PagesList.Count>0) then
    begin
      self.ActivatePage((PagesList.Last as TChatPage).PageID);
    end;
    Exit;
  end;
end;

function TPagesManager.GetPageInfo(PageID: integer; var PageInfo: TPageInfo): boolean;
var
  i: integer;
begin
  result:=false;
  for i:=0 to self.PagesList.Count-1 do
  begin
    if (self.PagesList[i] as TChatPage).PageID = PageID then
    begin
      PageInfo:=(self.PagesList[i] as TChatPage).PageInfo;
      result:=true;
      Exit;
    end;
  end;
end;

function TPagesManager.SetPageInfo(PageInfo: TPageInfo): boolean;
var
  i: integer;
  CP: TChatPage;
begin
  result:=false;
  for i:=0 to self.PagesList.Count-1 do
  begin
    CP:=(self.PagesList[i] as TChatPage);
    if CP.PageID = PageInfo.ID then
    begin
      if CP.PageInfo.Caption<>PageInfo.Caption then
      begin
        CP.TabSheet.Caption:=PageInfo.Caption;
      end;
      CP.PageInfo:=PageInfo;
      result:=true;
      Exit;
    end;
  end;
end;

function TPagesManager.GetPage(PageID: integer): TChatPage;
var
  i: integer;
begin
  result:=nil;
  for i:=0 to self.PagesList.Count-1 do
  begin
    if (self.PagesList[i] as TChatPage).PageID = PageID then
    begin
      result:=(self.PagesList[i] as TChatPage);
      Exit;
    end;
  end;
end;

function TPagesManager.GetPageByIndex(Index: integer): TChatPage;
begin
  result:=nil;
  if Index < self.PagesList.Count then
  begin
    result:=(self.PagesList[Index] as TChatPage);
  end;
end;

procedure TPagesManager.ChangePageIcon(PageID, IconID: integer);
var
  Page: TChatPage;
begin
  Page:=GetPage(PageID);
  if Page=nil then Exit;
  Page.PageInfo.ImageIndex:=IconID;
end;

function TPagesManager.GetPagePassword(PageID: integer): string;
var
  PageInfo: TPageInfo;
begin
  result:='';
  if GetPageInfo(PageID, PageInfo) then result:=PageInfo.sPassword;
end;

procedure TPagesManager.FSetActivePageID(PageID: integer);
var
  ChatClient: TChatClient;
  Page: TChatPage;
begin
  FActivePageID:=PageID;
  if Assigned(ClientsManager) and ClientsManager.GetClientByPageID(PageID, ChatClient) then
  begin
    Form1.FillToolBar(ChatClient.GetMainToolButtons(PageID));
  end
  else
  begin
    Form1.FillToolBar(nil);
  end;
  Page:=self.GetPage(PageID);
  Page.TabSheet.ImageIndex:=Page.PageInfo.ImageIndexDefault;
  Page.SetActive(true);
  if Assigned(PluginsManager) then PluginsManager.BroadcastMsg('ACTIVE_PAGE '+IntToStr(Page.PageInfo.ID));
end;

function TPagesManager.GetActivePage(): TChatPage;
begin
  result:=GetPage(FActivePageID);
end;

procedure TPagesManager.ActivatePage(PageID: integer);
var
  Page: TChatPage;
begin
  Page:=GetPage(PageID);
  if Page=nil then Exit;

  if (Page.Frame.Parent is TForm) then
  begin
    with (Page.Frame.Parent as TForm) do
    begin
      Show();
      //if CanFocus() then SetFocus();
    end;
  end

  else if (Page.Frame.Parent is TTabSheet) then
  begin
    with (Page.Frame.Parent as TTabSheet) do
    begin
      TabVisible:=true;
      Visible:=true;
      //Hint:=Page.PageInfo.Hint;
      Show();
      //if CanFocus() then SetFocus();
    end;
  end

  else
  begin
    Page.Frame.Parent := Page.TabSheet;
    with (Page.Frame.Parent as TTabSheet) do
    begin
      TabVisible:=true;
      Visible:=true;
      Show();
    end;
  end;
  FSetActivePageID(PageID);
end;

procedure TPagesManager.SetPageVisible(PageID: integer; AVisible: boolean);
var
  Page: TChatPage;
  Mode: integer;
begin
  Page:=GetPage(PageID);
  if Page=nil then Exit;

  Page.PageInfo.Visible:=AVisible;
  Mode:=0;
  if (Page.Frame.Parent is TTabSheet) then Mode:=1    // tab page
  else if (Page.Frame.Parent is TForm) then Mode:=2;  // separate window

  if Mode = 1 then // tab page
  begin
    with (Page.Frame.Parent as TTabSheet) do
    begin
      if TabVisible = AVisible then Exit;
      TabVisible:=AVisible;
      FSetActivePageID(Form1.PageControl1.ActivePage.Tag);
    end;
  end;

  if Mode = 2 then // separate window
  begin
    if AVisible then
    begin
      (Page.Frame.Parent as TForm).Close();
    end;
  end;
end;

function TPagesManager.GetPageVisible(PageID: integer): boolean;
var
  Page: TChatPage;
begin
  result:=False;
  Page:=GetPage(PageID);
  if Page=nil then Exit;
  result:=Page.PageInfo.Visible;
end;

procedure TPagesManager.MovePage(PageID, ParentPageID: integer);
var
  Page, ParentPage: TChatPage;
begin
  Page:=GetPage(PageID);
  ParentPage:=GetPage(ParentPageID);
  if (Page=nil) or (ParentPage=nil) then Exit;
  Page.TabSheet.PageIndex:=ParentPage.TabSheet.PageIndex+1;
end;

//===========================
//===== TClientsManager =====
//===========================
constructor TClientsManager.Create();
begin
  self.FClientsList:=TObjectList.Create(true);
  self.FClientsCount:=0;
end;

destructor TClientsManager.Destroy();
begin
  while self.FClientsList.Count>0 do
  begin
    self.RemoveClient(TChatClient(self.FClientsList.Last));
  end;
  self.FClientsList.Free();
end;

procedure TClientsManager.AddClient(NewClient: TChatClient);
var
  Conf: TConf;
begin
  self.FClientsList.Add(NewClient);
  self.FClientsCount:=self.FClientsList.Count;
  // Присоединение конфига клиента к дереву конфигов
  Conf:=NewClient.GetConf();
  if Assigned(Conf) then
  begin
    VisualConf.RootNode.AddChild(Conf.RootNode);
    frmOptions.RefreshConfTree();
  end;
end;

procedure TClientsManager.RemoveClient(ChatClient: TChatClient);
var
  Conf: TConf;
begin
  // отсоединение конфига клиента от дерева конфигов
  Conf:=ChatClient.GetConf();
  if Assigned(Conf) and Assigned(VisualConf) then
  begin
    VisualConf.RootNode.RemoveChild(Conf.RootNode);
    frmOptions.RefreshConfTree();
  end;

  // Убираем кнопки клиента
  if Assigned(PagesManager) then
  begin
    if ChatClient.HavePageID(PagesManager.GetActivePage.PageID) then
    begin
      Form1.FillToolBar(nil);
    end;
  end;

  self.FClientsList.Remove(ChatClient);
  self.FClientsCount:=self.FClientsList.Count;
end;

function TClientsManager.GetClientByPageID(PageID: integer; var ChatClient: TChatClient): boolean;
var
  i, n: integer;
begin
  result:=false;
  for i:=0 to self.FClientsList.Count-1 do
  begin
    with (FClientsList.Items[i] as TChatClient) do
    begin
      for n:=0 to Length(PagesIDList)-1 do
      begin
        if PagesIDList[n]=PageID then
        begin
          result:=true;
          ChatClient:=(FClientsList.Items[i] as TChatClient);
          Exit;
        end;
      end;
    end;
  end;
end;

function TClientsManager.SendMsgFromPage(PageID: integer; sText: string): string;
var
  i, n: integer;
  PageInfo: TPageInfo;
begin
  result:=sText;
  if not Assigned(PagesManager) then Exit;
  for i:=0 to self.FClientsList.Count-1 do
  begin
    with (FClientsList.Items[i] as TChatClient) do
    begin
      for n:=0 to Length(PagesIDList)-1 do
      begin
        if PagesIDList[n]=PageID then
        begin
          if PagesManager.GetPageInfo(PageID, PageInfo) then
          begin
            result:=(FClientsList.Items[i] as TChatClient).SendTextFromPage(PageInfo, sText);
            Exit;
          end;
        end;
      end;
    end;
  end;
end;

function TClientsManager.GetClient(ClientIndex: integer): TChatClient;
begin
  result:=nil;
  if ClientIndex > self.FClientsCount then Exit;
  result:=(self.FClientsList.Items[ClientIndex] as TChatClient);
end;

//============================================================
// Core Global functions
//============================================================
procedure AddChatClient(ClientName, ClientConfName: string);
begin
  if not Assigned(ClientsManager) then Exit;
  DebugText('Creating '+ClientName+' client..');
  if ClientName='IRC' then
  begin
    ClientsManager.AddClient(TIrcClient.Create(ClientConfName));
  end;
  if ClientName='iChat' then
  begin
    ClientsManager.AddClient(TIChatClient.Create(ClientConfName));
  end;
  DebugText('Created '+ClientName+' client..');
end;

procedure CoreStart();
var
  i: integer;
  sl: TStringList;
begin
  // Fill and attach main conf to options tree
  // MainConf nodes added except root node
  //frmMainOptions.FillConfItems(MainConf.RootNode);
  //frmMainOptions.FillConfigNodes(MainConf.RootNode);
  for i:=0 to MainConf.RootNode.ChildCount-1 do
    VisualConf.RootNode.AddChild(MainConf.RootNode.ChildNodes[i]);
  //MainConf.Load();
  MainConf.RefreshItemsList();

  frmMainOptions.RefreshSettings(MainConf.RootNode);
  frmOptions.RefreshConfTree();
  SetNewFonts();
  ChangeLanguage();

  // Set main form size and position
  Form1.Top:=MainConf.GetInteger('MainForm_Top');
  Form1.Left:=MainConf.GetInteger('MainForm_Left');
  Form1.Height:=MainConf.GetInteger('MainForm_Height');
  Form1.Width:=MainConf.GetInteger('MainForm_Width');

  if Form1.Width > Screen.Width then Form1.Width:=Screen.Width-20;
  If (Form1.Left+Form1.Width)>Screen.Width then
  begin
    Form1.Left:=Screen.Width-Form1.Width;
  end;

  if Form1.Height > Screen.Height then Form1.Height:=Screen.Height-20;
  If (Form1.Top+Form1.Height)>Screen.Height then
  begin
    Form1.Top:=Screen.Height-Form1.Height;
  end;

  {// Запуск автокоманд
  sl:=MainConf.GetStrings('AutojoinList');
  for i:=0 to sl.Count-1 do
  begin
    ModTimerEvent(1, ciDebugPageID, i*200+200, sl[i]);
  end;}
  DebugText('Windows '+GetWinVersion());

  // Check for first run
  if Length(MainConf['ChatClientsList'])=0 then
  begin
    frmStartupWizard:=TfrmStartupWizard.Create(Application);
    frmStartupWizard.Show();
  end
  else
  begin
    // Add clients
    sl:=MainConf.GetStrings('ChatClientsList');
    for i:=0 to sl.Count-1 do
    begin
      AddChatClient(sl.Names[i], sl.ValueFromIndex[i]);
    end;
  end;

end;

procedure CoreStop();
var
  PageInfo: TPageInfo;
begin
  // Stopping timers
  Form1.Timer1.Enabled:=false;
  Form1.Timer2.Enabled:=false;

  // Видимость служебных окон
  if PagesManager.GetPageInfo(ciDebugPageID, PageInfo) then
    MainConf.SetBool('ServerPageVisible', PageInfo.Visible);

  if PagesManager.GetPageInfo(ciNotesPageID, PageInfo) then
    MainConf.SetBool('NotesPageVisible', PageInfo.Visible);

  if PagesManager.GetPageInfo(ciFilesPageID, PageInfo) then
    MainConf.SetBool('FilesPageVisible', PageInfo.Visible);

  // Размер и положение главного окна
  MainConf.SetInteger('MainForm_Top', Form1.Top);
  MainConf.SetInteger('MainForm_Left', Form1.Left);
  MainConf.SetInteger('MainForm_Height', Form1.Height);
  MainConf.SetInteger('MainForm_Width', Form1.Width);

  //frmOptions.SaveOptions();
  MainConf.Save();
end;

///////////////////////////////////////////////////////////////////////////////
//  Работа со списком ников
///////////////////////////////////////////////////////////////////////////////
procedure AddNicks(PageID: integer; sNickList: String; ImgIndex: integer = -1; ClearList:boolean = false);
var
  Page: TChatPage;
begin
  // Получим нужную страницу
  Page:=PagesManager.GetPage(PageID);
  if Page=nil then Exit;
  if not (Page.Frame is TChatFrame) then Exit;
  (Page.Frame as TChatFrame).AddNicks(sNickList, ImgIndex, 0, ClearList);
end;

procedure AddNick(PageID: integer; sNick: String; ImgIndex: integer = -1);
var
  Page: TChatPage;
begin
  // Получим нужную страницу
  Page:=PagesManager.GetPage(PageID);
  if Page=nil then Exit;
  if not (Page.Frame is TChatFrame) then Exit;
  (Page.Frame as TChatFrame).AddNick(sNick, ImgIndex);
end;

procedure RemoveNick(PageID: integer; sNick: string; RemoveAll: boolean = false);
var
  Page: TChatPage;
begin
  // Получим нужную страницу
  Page:=PagesManager.GetPage(PageID);
  if Page=nil then Exit;
  if not (Page.Frame is TChatFrame) then Exit;
  (Page.Frame as TChatFrame).RemoveNick(sNick, RemoveAll);
end;

function ChangeNick(PageID: integer; sNick, sNewNick: string; ImgIndex: integer = -1): boolean;
var
  Page: TChatPage;
begin
  result:=false;
  // Получим нужную страницу
  Page:=PagesManager.GetPage(PageID);
  if Page=nil then Exit;
  if not (Page.Frame is TChatFrame) then Exit;
  result:=(Page.Frame as TChatFrame).ChangeNick(sNick, sNewNick, ImgIndex);
end;

procedure SetUserlistStyle(PageID: integer; sStyle: string);
var
  Page: TChatPage;
begin
  // Получим нужную страницу
  Page:=PagesManager.GetPage(PageID);
  if Page=nil then Exit;
  if (Page.Frame is TChatFrame) then
  begin
    (Page.Frame as TChatFrame).SetUserlistStyle(sStyle);
  end;
end;

///////////////////////////////////////////////////////////////////////////////
//  Работа с текстом
///////////////////////////////////////////////////////////////////////////////
procedure ShowRawText(PageID: integer; sText: string);
var
  Page: TChatPage;
  MesText: TRichView;
begin
  if not Assigned(PagesManager) then Exit;
  // Получим MesText по ИД страницы
  MesText:=nil;
  // Получим нужную страницу
  Page:=PagesManager.GetPage(PageID);
  if Page=nil then Exit;
  if (Page.Frame is TChatFrame) then MesText:=(Page.Frame as TChatFrame).MesText;
  if (Page.Frame is TFrameChanList) then MesText:=(Page.Frame as TFrameChanList).MesText;
  if (Page.Frame is TFrameClients) then MesText:=(Page.Frame as TFrameClients).MesText;

  if MesText=nil then Exit;
  MesText.AddNL(sText, 0, 0);
  MesText.FormatTail;
end;

procedure ParseIRCTextByPageID(PageID: integer; sText: string);
var
  Page: TChatPage;
  MesText: TRichView;
begin
  if not Assigned(PagesManager) then Exit;
  // Получим MesText по ИД страницы
  MesText:=nil;
  // Получим нужную страницу
  Page:=PagesManager.GetPage(PageID);
  if Page=nil then
  begin
    DebugMessage('Page not available ('+IntToStr(PageID)+') text: '+sText);
    Exit;
  end;
  if (Page.Frame is TChatFrame) then MesText:=(Page.Frame as TChatFrame).MesText;
  if (Page.Frame is TFrameChanList) then MesText:=(Page.Frame as TFrameChanList).MesText;
  if (Page.Frame is TFrameClients) then MesText:=(Page.Frame as TFrameClients).MesText;

  ParseIRCTextToRV(MesText, sText);
end;


function TimeTemplate(): String;
var
  D: TDateTime;
  Hour, Min, Sec, MSec: Word;
  RealHour, RealMin, RealSec, RealMsec: String;
begin
  D := Now;
  DecodeTime( D, Hour, Min, Sec, MSec);
  RealHour := IntToStr(Hour);
  RealMin := IntToStr(Min);
  RealSec := IntToStr(Sec);
  RealMsec := IntToStr(MSec);
  if length(RealHour) = 1 then RealHour := '0'+RealHour;
  if length(RealMin) = 1 then RealMin := '0'+RealMin;
  if length(RealSec) = 1 then RealSec := '0'+RealSec;
  Result := '['+RealHour+':'+RealMin+':'+RealSec+']';
end;

{function AddIcon16(FileName: string): integer;
var
  Bitmap: TBitmap;
begin
  result:=-1;
  if not FileExists(Filename) then Exit;
  Bitmap:=TBitmap.Create();
  try
    Bitmap.LoadFromFile(FileName);
    result:=MainForm.ImageList16.Add(Bitmap, nil);
  finally
    Bitmap.Free();
  end;
end; }

function AddIcon16(FileName: string): integer;
var
  bmp: TBitmap;
  rect: TRect;
begin
  result:=-1;
  with rect do
  begin
    Left:=0;
    Top:=0;
    Right:=16;
    Bottom:=16;
  end;
  try
    bmp:=TBitmap.Create();
    bmp.LoadFromFile(FileName);
    bmp.Canvas.StretchDraw(rect, bmp);
    bmp.Height:=rect.Bottom;
    bmp.Width:=rect.Right;
    result:=MainForm.ImageList16.AddMasked(bmp, $00000000);
  finally
    FreeAndNil(bmp);
  end;
end;

procedure AddNote(sUserName, sNoteText: string);
var
  Page: TChatPage;
begin
  if Copy(Trim(sNoteText),1,6)='AVATAR' then
  begin
    DownloadAvatar(sUserName, Copy(Trim(sNoteText), 8, maxint));
    Exit;
  end;
  // проверяем наличие сообщений от данного юзера
  Page:=PagesManager.GetPage(ciNotesPageID);
  if Page=nil then Exit;

  (Page.Frame as TChatFrame).AddNote(sUserName, sNoteText);
end;

procedure FlashMessage(PageID: integer; strAuthor, strText: string; IsPrivate: boolean);
begin
  if IsPrivate then
  begin
    PagesManager.ChangePageIcon(PageID, ciIconIdPrivateMsg);
    MainForm.FlashIcon(strAuthor, strText, MainConf.GetBool('NotifyPrivates'));
  end
  else
  begin
    PagesManager.ChangePageIcon(PageID, ciIconIdHaveNewMsg);
    MainForm.FlashIcon(strAuthor, strText, MainConf.GetBool('NotifyAllMsg'));
  end;
end;

procedure GrabNotesByKeywords(AuthorName, Text: string);
var
  i: integer;
  slNotesKeywords: TStringList;
begin
  slNotesKeywords:=MainConf.GetStrings('NotesKeywordsList');
  //if conf.slNotesKeywords.Count=0 then Exit;
  for i:=0 to slNotesKeywords.Count-1 do
  begin
    if Pos(slNotesKeywords[i], Text)>0 then
    begin
      AddNote(AuthorName, Text);
      Exit;
    end;
  end;
end;

procedure PlayNamedSound(SoundName: string; ChatClient: TChatClient = nil);
var
  Conf: TConf;
  sndFileName: string;
begin
  if not MainConf.GetBool('PlaySounds') then Exit;
  Conf:=nil;
  if Assigned(ChatClient) then Conf:=ChatClient.GetConf();
  if not Assigned(Conf) then Conf:=MainConf;
  sndFileName:=Conf[SoundName];
  Sounds.PlaySoundFile(sndFileName);
end;

procedure ShowPrivateMsg(PageID: integer; sNick, sText:String);
var
  //PvtForm: TfrmPrivates;
  n: integer;
  Page: TChatPage;
  NewForm: TForm;
  PageOnForm: boolean;
begin
  // Проверяем, есть ли набраный текст в текущей странице
  if MainConf.GetBool('IgnorePrivates') then Exit;
  n:=0;
  Page:=PagesManager.GetActivePage();
  if (Page.Frame is TChatFrame) then n:=Length(TChatFrame(Page.Frame).TxtToSend.Text);

  if MainForm.Active then Exit;
  if (MainForm.btnPassive.Down) or (n>0) then
  begin
    MainForm.FlashIcon(sNick, sText, MainConf.GetBool('NotifyPrivates'));
    Exit;
  end;

  // Выделяем страницу привата
  // Действия те же, что при отсоединении страницы
  Page:=PagesManager.GetPage(PageID);
  if not Assigned(Page) then Exit;
  PageOnForm := (Page.Frame.Parent is TForm);
  // Меняем значок закладки
  if (not PageOnForm) and (Page<>PagesManager.GetActivePage()) then
  begin
    Page.TabSheet.ImageIndex:=ciIconIdHavePvtMsg;
  end;

  if not MainConf.GetBool('PopupPrivate') then Exit;
  if PageOnForm then Exit;
  // Popup private window
  with Page do
  begin
    NewForm := TForm.Create(MainForm);
    NewForm.OnClose := MainForm.SeparateFormClose;
    NewForm.OnActivate := Form1.SeparateFormActivate;
    NewForm.Caption := MainForm.Caption+' '+PageInfo.Caption;
    if (Frame is TChatFrame) then TChatFrame(Frame).RightPanel.Width:=0;
    NewForm.Height := 300;
    NewForm.Width := 400;
    NewForm.Tag := PageInfo.ID;
    NewForm.ScreenSnap := true;
    // Специфика
    NewForm.FormStyle := fsStayOnTop;
    NewForm.Position := poMainFormCenter;

    Frame.Parent := NewForm;
    olPrivWndList.Add(NewForm);
    NewForm.Show();
    TabSheet.TabVisible:=false;
  end;
  {
  //FormClass := TFormClass(FindClass('TfrmPrivates'));
  //SomeForm := FormClass.Create(Application);
  PvtForm := TfrmPrivates.Create(Application);
  PvtForm.sPrivateNick := sNick;
  PvtForm.sPrivateText := sText;
  PvtForm.sPrivateTime := TimeTemplate();
  PvtForm.Reset();
  slPrivWndList.Add(PvtForm);
  if slPrivWndList.Count>8 then slPrivWndList.Delete(0);
  //form1.Activate;
  PvtForm.Show;}
end;

procedure DebugMessage(MsgText: string);
begin
  if ciDebugPageID < 0 then
  begin
    Application.MessageBox(PChar(MsgText),PChar('Debug message'));
  end
  else
  begin
    ShowRawText(ciDebugPageID, MsgText);
  end;
end;

procedure DownloadAvatar(UserNick, AvatarURL: string);
begin
  MainForm.DownloadAvatar(UserNick, AvatarURL);
end;

procedure ClearPageInfo(var PageInfo: TPageInfo);
begin
  PageInfo.ID:=-1;
  PageInfo.sServer:='';
  PageInfo.sChan:='';
  PageInfo.Caption:='';
  PageInfo.Hint:='';
  PageInfo.sNick:='';
  PageInfo.sMode:='';
  PageInfo.sPassword:='';
  PageInfo.Visible:=true;
  PageInfo.ImageIndex:=-1;
  PageInfo.ImageIndexDefault:=-1;
  PageInfo.PageType:=0;
  PageInfo.bUseStateImages:=false;
end;

procedure Say(sText: string; PageID: integer = -1; AddToHistory: boolean = false);
var
  snd: string;
  rTurned:String;
  PageInfo: TPageInfo;
  ChatClient: TChatClient;
begin
  if not Assigned(PagesManager) then Exit;
  if PageID < 0 then PageID:=Core.PagesManager.GetActivePage.PageID;
  if not Core.PagesManager.GetPageInfo(PageID, PageInfo) then Exit;

  if Assigned(PluginsManager) then PluginsManager.BroadcastMsg('USER_SAY '+IntToStr(PageID)+' '+sText);

  snd := UpperCase(Trim(sText));
  //// убираем пробелы спереди
  //while snd[1]=' ' do snd := Copy(snd, 2, MaxInt);
  Core.HideColors(); // закроем выбор цвета
  if Length(snd) = 0 then Exit;
  if (snd = '/EXIT') or (snd = '/Q') then Form1.Close;

  Added := false;
  if AddToHistory then AddMemoCmd(sText);

  if (not ClientsManager.GetClientByPageID(PageID, ChatClient)) then
  begin
    ParseIRCTextByPageID(ciDebugPageID, TimeTemplate()+#2+#3+'04 '+sInfoClientForPageNotFound);
    Exit;
  end;

  if snd = '/DISCONNECT' then
  begin
    ChatClient.Disconnect;
    Exit;
  end
  else if snd = '/CONNECT' then
  begin
    ChatClient.Connect;
    Exit;
  end
  else if snd='/CLEAR' then
  begin
    Core.PagesManager.GetActivePage.Clear();
    Exit;
  end;


  rTurned := ChatClient.SendTextFromPage(PageInfo, sText);
  if rTurned<>'' then ParseIRCTextByPageID(PageID, rTurned);
end;

procedure ShowOptions();
var
  SomeChatClient: TChatClient;
begin
  frmOptions.Show();
  // Pre-select config node for for current page
  if ClientsManager.GetClientByPageID(PagesManager.ActivePageID, SomeChatClient) then
  begin
    frmOptions.SelectItemByOwner(SomeChatClient);
  end;
end;

procedure ShowSmiles();
//var
//  frmSmiles: TfrmSmiles;
begin
  if Assigned(frmSmiles) then
  begin
    frmSmiles.Show();
    Exit;
  end;

  frmSmiles:=TfrmSmiles.Create(MainForm);
  //olPrivWndList.Add(frmSmiles);
  frmSmiles.Show();
end;

procedure HideSmiles();
begin
  if Assigned(frmSmiles) then
  begin
    if frmSmiles.Visible then frmSmiles.Close();
  end;
end;

procedure ShowColors();
begin
  if Assigned(frmColors) then
  begin
    frmColors.Show();
    Exit;
  end;

  frmColors:=TfrmColors.Create(MainForm);
  //olPrivWndList.Add(frmSmiles);
  frmColors.Show();
end;

procedure HideColors();
begin
  if Assigned(frmColors) then
  begin
    if frmColors.Visible then frmColors.Close();
  end;
end;


procedure EnterCommandBox(Template, Caption, DefaultText: string; PageID: integer = -1);
begin
  //Main.EnterCommandBox(Template, Caption, DefaultText, PageID);
  frmEnterCmd:=TfrmEnterCmd.Create(Form1);
  frmEnterCmd.Caption:=Caption;
  frmEnterCmd.template:=Template;
  frmEnterCmd.default:=DefaultText;
  frmEnterCmd.PageID:=PageID;
  olPrivWndList.Add(frmEnterCmd);
  frmEnterCmd.Show;
end;

procedure ShowInfoList(InfoList: TInfoList; ChatClient: TChatClient);
var
  AChatClient: TChatClient;
  Page: TChatPage;
begin
  if not Assigned(ChatClient) then Exit;
  Page:=PagesManager.GetActivePage();
  // Проверим наличие текущей страницы у переданого клиента
  if not ClientsManager.GetClientByPageID(Page.PageID, AChatClient) then
  begin
    // Если текущая сраница не от этого клиента, то получим первую страницу клиента
    if ChatClient.PagesIDCount=0 then Exit;
    Page:=PagesManager.GetPage(ChatClient.PagesIDList[0]);
    if not Assigned(Page) then Exit;
  end;
  if (Page.Frame is TChatFrame) then
  begin
    (Page.Frame as TChatFrame).ShowTable(InfoList);
  end;
end;

procedure ModTimerEvent(Oper, PageID, Delay: integer; Cmd: string);
// Oper: 1-add, 0-reset, -1-remove
// Delay: milliseconds
// Cmd: some text. if (Oper = -1) and (Cmd='') then remove all strings
begin
  if not Assigned(CmdSheduler) then Exit;
  if Oper=1 then        CmdSheduler.AddTimerEvent(Delay, Cmd, PageID)
  else if Oper=0 then   CmdSheduler.ResetTimerEvent(Delay, Cmd, PageID)
  else if Oper=-1 then  CmdSheduler.RemoveTimerEvent(Cmd, PageID);
end;

procedure SetNewFonts();
var
  i,n: integer;
  //Font: TFont;
  Page: TChatPage;
begin
  // установка новых шрифтов
  for n:=0 to Form1.MessStyle.TextStyles.Count-1 do
  begin
    with Form1.MessStyle.TextStyles.Items[n] do
    begin
      FontName := MainConf.fntArray[1].Name;
      Size := MainConf.fntArray[1].Size;
      //Color := Font.Color;
      //Style := Font.Style;
      Charset := MainConf.fntArray[1].Charset;
    end;
  end;
  for i:=0 to PagesManager.PagesCount-1 do
  begin
    Page:=PagesManager.GetPageByIndex(i);
    if Assigned(Page) then Page.UpdateStyle();
  end;
end;

procedure ClearPageText(PageID: integer);
var
  Page: TChatPage;
begin
  Page:=PagesManager.GetPage(PageID);
  if not Assigned(Page) then Exit;
  if (Page.Frame is TChatFrame) then
    (Page.Frame as TChatFrame).ClearMesText()
  else if (Page.Frame is TFrameChanList) then
    (Page.Frame as TFrameChanList).ClearMesText()
  else if (Page.Frame is TFrameClients) then
    (Page.Frame as TFrameClients).ClearMesText();
end;

procedure ChangeLanguage();
var
  i: integer;
  sFileName: string;
begin
  sFileName:=MainConf['LanguageFile'];
  if Length(Trim(sFileName))=0 then Exit;
  sFileName:=glHomePath+sFileName;
  if Assigned(LangIni) then FreeAndNil(LangIni);
  LangIni:=TMemIniFile.Create(sFileName);

  Form1.LoadLanguage();
  frmMainOptions.ChangeLanguage();
  frmOptions.ChangeLanguage();
  // Pages
  for i:=0 to PagesManager.PagesCount-1 do
  begin
    PagesManager.GetPageByIndex(i).UpdateStyle();
  end;
  // Clients
  for i:=0 to ClientsManager.ClientsCount-1 do
  begin
    ClientsManager.GetClient(i).LoadLanguage();
  end;
  frmOptions.RefreshConfTree();
end;


end.
