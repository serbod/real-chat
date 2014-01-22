{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  Клиент IRC.

  TIrcClient - IRC-клиент. Содержит процедуры для подключения, отправки сообщений
  на сервер. Принимаемые с сервера собщения передает в обработчик событий.

  TChanList - Список каналов с IRC-сервера. Содержит процедуры для добавления и
  сортировки каналов.

}
unit IRC;

interface

uses
    Controls, Windows, Classes, Forms, Misc, Core, Menus,
  DCC, Configs, IRC_Options, Contnrs, ComCtrls, AsyncSock, BlckSock;

// Класс для работы со списком каналов
type
  PChanRec = ^TChanRec;
  TChanRec = record
    ChanName   :string;
    ChanUsers  :integer;
    ChanDesc   :string;
    PageID     :integer;
    Password   :string;
    ChanType   :integer; // ciChanType
  end;
  TChanSortModes = (SortByNames, SortByUsers);
  function CompareChanNames(Item1, Item2: pointer): integer;
  function CompareChanUsers(Item1, Item2: pointer): integer;

type
  TChanList = class(TList)
  public
    function Add(ChanRec: TChanRec): integer;
    function AddRaw(RawChan: string): integer;
    procedure Delete(Index: integer);
    function GetChanRec(Index: integer): TChanRec;
    procedure SetChanRec(Index: integer; Value: TChanRec);
    function GetChanRecByName(sChanName: string; var ChanRec: TChanRec): boolean;
    function GetIndexByName(sChanName: string): integer;
    procedure Sort(SortMode: TChanSortModes);
    property Channels[Index: integer]: TChanRec read GetChanRec write SetChanRec;
    destructor Destroy; override;
  end;

// Структура, содержащая IRC сообщение
type
  TParsedData = record
    bHasPrefix :Boolean;
    strFullHost :String;
    strNick :String;
    strIdent :String;
    strHost :String;
    strCommand :String;
    strText :String;
    intParams :Integer;
    strParams :Array of String;
  end;

// Класс, реализующий функционал IRC-клиента
type

  TIrcEvent = procedure (Sender: TObject; EventText: string) of object;

  TIrcClient = class(TChatClient)
  private
    DefaultServerPort: integer;
    //Socket: TProxySocket;
    Socket: TAsyncSock;
    FIrcEvent: TIrcEvent;
    bUseProxy: boolean;
    bProxyConnected: boolean;
    bDebugInfo: boolean;
    FMyNick: string;
    FServerHost: string;
    FServerPort: string;
    FLocalAddress: string;
    ServerProxy: string;
    FServerPageID: integer;
    FChanListPageID: integer;
    FChanList: TChanList;
    FKeepConnection: boolean;
    KeepAlivePeriod: integer;
    ServerDataTimeout: integer;
    sBuf: string;  // глобальная, чтобы сохранялась при повторном вызове процедуры
    IrcConf: TIrcConf;
    flagHop: boolean;  // признак перезахода на канал
    InfoList: TInfoList;
    SimpleBotLines: TStringList;
    {// Обработчик событий сокета
    procedure OnSocketEvent(Sender: TObject; Socket: TCustomWinSocket; SocketEvent: TSocketEvent);
    // Обработчик ошибок сокета
    procedure OnSocketErrorEvent(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    // Обработчик события подключения к серверу
    procedure OnSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    // Обработчик события чтения из сокета
    procedure OnSocketRead(Sender: TObject; Socket: TCustomWinSocket);}
    function StartConnection(): boolean;
    function StopConnection(): boolean;

    // Обработчик событий сокета
    procedure OnSocketEvent(Sender: TObject; ASocket: TTCPBlockSocket; SocketEvent: TSocketEvent);
    // Обработчик ошибок сокета
    procedure OnSocketErrorEvent(Sender: TObject; ASocket: TTCPBlockSocket; ErrorEvent: TErrorEvent; ErrorMsg: string);
    // Обработчик события подключения к серверу
    procedure OnSocketConnect(Sender: TObject; ASocket: TTCPBlockSocket);
    // Обработчик события чтения из сокета
    procedure OnSocketRead(Sender: TObject; ASocket: TTCPBlockSocket);

    // Парсер сообщений с сервера
    procedure Interpret(strData :String);
    // Внутренние функции
    function CreateChannelPage(Name: string; ImageID: integer = -1): integer;
    function CreatePrivatePage(UserName: string): integer;
    function RemovePage(Name: string): boolean;
    procedure SendNoticeAction(strTarget: String; strText: String);
    procedure SendCtcpAction(strTarget: String; strText: String);
    procedure HandleCTCP(strNick :String; strData :String);
    procedure OnPrivmsg(strSender, strTarget, strText: string);
    procedure ParseData(strData: String; var parsed: TParsedData);
    procedure AddChanToList(sRawChanName, sRawChanDesc: string);
    procedure RejoinChannel(sChan: string);
    procedure AddNicks(sNicks, sChan: string);
    procedure ChangeNick(sNick, sNewNick: string);
    procedure ChangeNickMode(sNick, sNewMode, sChan: string);
    procedure ModifyIgnoreList(Action: integer; sText: string);
    // Выполняется после успешного захода на сервер
    procedure OnLogin();
    // Выполняется при заходе на канал
    procedure OnJoin(sChanName: string);
    // Обработчик локальных событий
    procedure LocalEvent(sEvent: string);
    // Обработчик принятия изменений в конфиге
    procedure OnApplySettings(Sender: TObject);

  public
    //MyNick: string;     // Ник пользователя
    bSendUTF8: boolean;  // Отправка текста в UTF-8
    bReceiveUTF8: boolean;  // Прием текста в UTF-8
    constructor Create(ConfFileName: string); override;
    destructor Destroy(); override;
    function Connect(): boolean; override;
    function Disconnect(): boolean; override;
    property OnIrcEvent: TIrcEvent read FIrcEvent write FIrcEvent;
    property LocalAddress: string read FLocalAddress;
    function SendTextFromPage(PageInfo: TPageInfo; sText: string): string; override;
    function SendTextToServer(sText: string): boolean; override;
    // Возвращает ID страницы по ее имени
    function GetPageIDByName(sName: string): integer;
    // Возвращает индекс иконки статуса юзера по его префиксу
    function GetUserStatusIconIndex(s: string): integer;
    // Возвращает индекс иконки статуса юзера по букве его режима (MODE)
    function GetUserModeIconIndex(s: string): integer;
    procedure ModActiveChanList(ChanName: string; PageID: integer; ChanType: integer; DoAdd: integer = 1);
    function GetConf(): TConf; override;
    function GetOption(sName: string): string; override;
    procedure SetOption(sName, sData: string); override;
    function ClosePage(PageID: integer): boolean; override;
    procedure LoadLanguage(); override;
    // Обработчик контекстного меню списка пользователей
    function UserListContextMenu(PageID: integer; ulcm: TPopupMenu): boolean; override;
    // Получить список кнопок для общей панели инструментов
    function GetMainToolButtons(PageID: integer): TObjectList; override;
    // Получить список меню для закладки страницы
    function GetTabMenuItems(PageID: integer): TObjectList; override;

  protected
    procedure Event(EventText: string);
  end;

  //Заменяем в никах "%", "@", "+"
  function ReplaceOps(sNick: String): String;
  function StripIRCCodes(sText: string): string;

const
  ciChanTypeChannel = 0;
  ciChanTypePrivate = 1;
  ciChanTypeDCCChat = 2;

  ciIconNormal = 20; // Normal user
  ciIconBanned = 21; // Banned user
  ciIconAway   = 22; // User away
  ciIconOper   = 23; // Oper
  ciIconHidden = 24; // Hidden
  ciIconVoiced = 25; // Voiced
  ciIconPrivOp = 23; // Privileged oper
  ciIconOwner  = 24; // Channel owner

  ciIconIRC    = 7; // IRC icon

  ciRecentChannelsCount = 8;

var
  strAction: string = #1;

  sConnConnect:string = 'Соединение установлено. Идентификация.';
  sConnError:string = 'Ошибка соединения:';
  sConnDisconnected:string = 'Отсоединение.';
  sConnOpenHost:string = 'Соединяемся с';
  sConnOpenPort:string = 'порт';
  sIrcNotConnected:string = 'Сперва нужно подключиться к серверу.';
  sIrcUncnownCommand:string = 'Неизвестная команда или не хватает параметров:';
  sIrcServerDataTimeout:string = 'Что-то долго нет данных от сервера. Связь в порядке?';
  sDccRequestTimeout:string = 'Нет ответа на запрос DCC. Возможно, порты вашего компьютера заблокированы.';
  sReconnectEvent:string = 'Переподключение через %s секунд';

  sIrcSocketConectError:string = 'Не удалось подключиться к серверу.';
  sIrcSocketGeneralError:string = 'Ошибка соединения.';
  sIrcSocketSendError:string = 'Не удалось отправить данные на сервер.';
  sIrcSocketReceiveError:string = 'Не удалось принять данные с сервера.';
  sIrcSocketOtherError:string = 'Ошибка сокета.';
  sIrcSocketLookup:string = 'Определяем адрес сервера.';
  sIrcSocketConnecting:string = 'Подключаемся к серверу.';
  sIrcSocketConnect:string = 'Подключились к серверу.';

  sUserInfoNick:string = 'Ник:';
  sUserInfoName:string = 'Имя:';
  sUserInfoComp:string = 'Комп:';
  sUserInfoChan:string = 'Сидит на каналах:';
  sUserInfoServ:string = 'Сервер:';
  sUserInfoIdle:string = 'Молчит:';
  sUserInfoOnln:string = 'В сети с:';

  sIrcSoundChannelMessage: string = 'Сообщение на канал';
  sIrcSoundPrivateMessage: string = 'Приватное сообщение';
  sIrcSoundMeMessage: string = 'Сообщение /ME';
  sIrcSoundNoticeMessage: string = 'Сообщение /NOTICE';
  sIrcSoundDccChat: string = 'Входящий DCC чат';
  sIrcSoundDccFile: string = 'Входящий DCC файл';
  sIrcSoundServerConnect: string = 'Подключение к серверу';
  sIrcSoundServerDisconnect: string = 'Отключение от сервера';
  sIrcSoundJoinChannel: string = 'Заход на канал';
  sIrcSoundLeaveChannel: string = 'Уход с канала';
  sIrcSoundErrorMessage: string = 'Сообщение об ощибке';
  sIrcSoundOther: string = 'Прочее';

  sComeToChannel:string = 'зашел на канал';
  sLeaveChannel:string = 'свалил с канала';
  sUserSetMode:string = 'устанавливает режим:';
  sMeSetMode:string = 'устанавливает режим:';
  sKickedYou:string = 'кикнул тебя с канала';
  sKickedSomeone:string = 'кикнул %s с канала';
  sChannelTopic:string = 'Топик канала:';
  sSomeoneChangeTopic:string = '%s изменил топик на ''%s''';
  sTopicSetBy:string = 'Топик установлен %s, %s';
  sChannelName:string = '*** Канал';
  sChannelModes:string = 'режимы:';
  sNameInUse:string = 'Имя уже занято, пробуем другое имя:';
  sMOTD:string = 'MOTD';
  sMOTD2:string = 'Снова MOTD';
  sSomeoneAskVersion:string = '%s захотел узнать версию твоего клиента.';
  sSomeonePingMe:string = '%s попытался аццки пингануть тебя, но ему это не удалось :)';
  sSomeoneFingerMe:string = '%s попытался пощупать тебя пальчиком :)';
  sSomeoneAddNote:string = '%s добавил объявление:';
  sYouCannotWriteToChannel:string = 'вам запретили писать на канал %s';
  sYouCannotJoinChannel:string = 'вам запретили заходить на канал %s';
  sPasswordSet:string = 'Пароль установлен - шифрование включено.';
  sLibeay32NotFound:string = 'Не найдена библиотека шифрования libeay32.dll';
  sPasswordUnset:string = 'Пароль НЕ установлен - шифрование отключено.';
  sSomeoneChangeNick:string = 'меняет ник на';
  sSomeoneLeaveChat:string = 'свалил насовсем (%s)';

  sChanListCaption:string = 'Каналы';
  sChanListChanMask:string = 'Укажите часть имени канала';
  sChanListSortByNames:string = 'По именам';
  sChanListSortByUsers:string = 'По юзерам';
  sChanListColChan:string = 'Канал';
  sChanListColUsers:string = 'Юзеров';
  sChanListColTopic:string = 'Описание';

  sTabMenuDisconnect: string = 'Отключить';
  sTabMenuChanOptions: string = 'Свойства канала';
  sTabMenuChanHop: string = 'Перезайти на';

implementation
uses
  SysUtils, Base64, ChanListFrame, IRC_ChanOptions;

// === TIRCClass ===
constructor TIrcClient.Create(ConfFileName: string);
var
  PageInfo: TPageInfo;
  //TB: TToolButton;
begin
  inherited Create(ConfFileName);
  self.IrcConf:=TIrcConf.Create(self, ConfFileName);
  self.IrcConf.OnApplySettings:=OnApplySettings;
  self.LoadLanguage();

  FChanList:=TChanList.Create();

  self.PagesIDCount:=0;
  SetLength(self.PagesIDList, self.PagesIDCount);

  self.FInfoAbout:='RealChat IRC client version 2.3';
  self.FInfoProtocolID:=ciIconIRC;
  self.FInfoProtocolName:='IRC';
  self.FServerHost := IrcConf['ServerHost'];
  self.FServerPort := IrcConf['ServerPort'];
  self.FInfoConnection:=self.FInfoProtocolName+' '+self.FServerHost+':'+self.FServerPort;
  self.IrcConf.RootNode.FullName:=self.FInfoConnection;
  self.FMyNick := IrcConf['MyNick'];
  self.DefaultServerPort := 6667;
  self.FKeepConnection:=false;
  SimpleBotLines:=TStringList.Create();

  self.Socket := TAsyncSock.Create();
  self.Socket.OnSocketEvent := self.OnSocketEvent;
  self.Socket.OnErrorEvent := self.OnSocketErrorEvent;
  FActive := false;
  //bUseProxy := false;
  bProxyConnected := false;
  bDebugInfo:= false;
  bSendUTF8 := false;
  FChanListPageID := -1;
  KeepAlivePeriod:=0;
  ServerDataTimeout:=0;
  self.OnApplySettings(nil);

  // Список информации о пользователе
  InfoList.Count:=7;
  SetLength(InfoList.Items, InfoList.Count);
  InfoList.Items[0].Name:=sUserInfoNick;
  InfoList.Items[1].Name:=sUserInfoName;
  InfoList.Items[2].Name:=sUserInfoComp;
  InfoList.Items[3].Name:=sUserInfoChan;
  InfoList.Items[4].Name:=sUserInfoServ;
  InfoList.Items[5].Name:=sUserInfoIdle;
  InfoList.Items[6].Name:=sUserInfoOnln;

  // Создаем панель сервера

  Core.ClearPageInfo(PageInfo);
  PageInfo.Caption:=self.FServerHost;
  PageInfo.Hint:=self.FInfoConnection;
  PageInfo.PageType:=ciChatPageType;
  PageInfo.ImageIndex:=self.FInfoProtocolID;
  PageInfo.ImageIndexDefault:=self.FInfoProtocolID;
  PageInfo.Visible:=IrcConf.GetBool('ServerPageVisible');
  self.FServerPageID:=PagesManager.CreatePage(PageInfo);

  self.ModifyPagesList(self.FServerPageID, 1);

  // В список ников окна #debug добавляем команды IRC
  Core.SetUserlistStyle(self.FServerPageID, 'bold');
  Core.AddNicks(self.FServerPageID, '/SERVER /JOIN /LIST /PART /QUIT /NICK /AWAY /WHOIS /INVITE /KICK /TOPIC /ME /MSG /QUERY /NOTICE /NOTIFY /IGNORE /MODE /CTCP /RAW /HOP /DEBUG /DECODER /PING /OPER /CLEAR', ciIconNormal);
  //Core.PagesManager.ActivatePage(self.FServerPageID);

  if IrcConf.GetBool('AutoConnect') then Core.ModTimerEvent(1, FServerPageID, 200, '/SERVER');
end;

destructor TIrcClient.Destroy();
begin
  self.Disconnect();
  IrcConf.SetBool('ServerPageVisible', Core.PagesManager.GetPageVisible(self.FServerPageID));
  IrcConf.Save();
  self.Socket.Free();
  //FreeAndNil(FToolButtonsList);
  FreeAndNil(SimpleBotLines);

  FChanList.Free();

  // Убираем закладку сервера

  //FreeAndNil(frmIrcOptions);
  IrcConf.Free();
  if self.FChanListPageID > 0 then PagesManager.RemovePage(self.FChanListPageID);
  PagesManager.RemovePage(self.FServerPageID);
  inherited Destroy();
end;

function TIrcClient.GetOption(sName: string): string;
begin
  result:=self.IrcConf[sName];
end;

procedure TIrcClient.SetOption(sName, sData: string);
begin
  self.IrcConf[sName]:=sData;
end;

function TIrcClient.GetConf(): TConf;
begin
  result:= IrcConf;
end;

function TIrcClient.GetMainToolButtons(PageID: integer): TObjectList;
begin
  result:=nil;
  if Assigned(self.IrcConf) then  result:=self.IrcConf.FToolButtonsList;
end;

function TIrcClient.GetTabMenuItems(PageID: integer): TObjectList;
var
  NewMenuItem: TMenuItem;
  PageInfo: TPageInfo;

procedure AddMenuItem(sCaption, sHint: string);
begin
  NewMenuItem:=TMenuItem.Create(Core.MainForm);
  NewMenuItem.Caption:=sCaption;
  NewMenuItem.Hint:=sHint;
  Result.Add(NewMenuItem);
end;

begin
  Result:=nil;
  if not Core.PagesManager.GetPageInfo(PageID, PageInfo) then Exit;
  Result:=TObjectList.Create();
  if PageID = self.FServerPageID then
  begin
    AddMenuItem(sTabMenuDisconnect+' '+PageInfo.sServer, '/DISCONNECT');
  end
  else if PageID = Self.FChanListPageID then
  begin

  end
  else
  begin
    if Length(PageInfo.sChan)>0 then
    begin
      if PageInfo.sChan[1]='#' then
      begin
        AddMenuItem(sTabMenuChanOptions, '/CHAN_OPTIONS');
        AddMenuItem(sTabMenuChanHop+' '+PageInfo.sChan, '/HOP');
      end;
    end;
  end;
end;

//==============================
// Вспомогательные функции
//==============================
function TIrcClient.GetPageIDByName(sName: string): integer;
var
  ChanRec: TChanRec;
begin
  result:=-1;
  if self.FChanList.GetChanRecByName(sName, ChanRec) then result:=ChanRec.PageID;
end;

function TIrcClient.GetUserStatusIconIndex(s: string): integer;
begin
  Result:=ciIconNormal;
  case s[1] of
    '@': Result:=ciIconOper;   // Oper
    '%': Result:=ciIconHidden; // Hidden
    '+': Result:=ciIconVoiced; // Voiced
    '&': Result:=ciIconPrivOp; // Privileged oper
    '~': Result:=ciIconOwner;  // Channel creator
  end;
end;

function TIrcClient.GetUserModeIconIndex(s: string): integer;
begin
  Result:=ciIconNormal;
  case s[1] of
    'o': Result:=ciIconOper;   // Oper
    'h': Result:=ciIconHidden; // Hidden
    'v': Result:=ciIconVoiced; // Voiced
    'p': Result:=ciIconPrivOp; // Privileged oper
    'q': Result:=ciIconOwner;  // Channel creator
  end;
end;

//----
procedure TIrcClient.AddNicks(sNicks, sChan: string);
var
  i, k, n: integer;
  sNick, sTmp, sn: string;
begin
  //
  sn:=sNicks+' ';
  n:=1;
  while n>0 do
  begin
    n:=Pos(' ', sn);
    sNick:=Copy(sn, 1, n-1);
    sn:=Copy(sn, n+1, maxint);
    if sNick<>'' then
    begin
      k:=GetUserStatusIconIndex(sNick[1]);
      if k<>ciIconNormal then sNick:=Copy(sNick, 2, maxint);
      i:=self.FServerPageID;
      if sChan<>'' then i:=self.GetPageIDByName(sChan);
      Core.AddNicks(i, sNick, k);
    end;
  end;
end;

//----
procedure TIrcClient.ChangeNick(sNick, sNewNick: string);
var
  i: integer;
  sl: TStringList;
  bFlag: boolean;
begin
  bFlag:=(sNick = self.FMyNick); // My nick changed
  for i:=0 to self.FChanList.Count-1 do
  begin
    if Core.ChangeNick(self.FChanList.Channels[i].PageID, sNick, sNewNick) then
    begin
      if IrcConf.GetBool('ShowStatusMessages') or bFlag then
      begin
        ShowText(self.FChanList.Channels[i].PageID, TimeTemplate()+#2+#3+'03 '+sNick+#2+' '+sSomeoneChangeNick+' '+#2+sNewNick+#2);
      end;
    end;
  end;
  // Change my nick
  if bFlag then
  begin
    self.FMyNick := sNewNick;
    IrcConf['MyNick'] := sNewNick;
    ShowText(self.FServerPageID, TimeTemplate()+#2+#3+'03 '+sNick+#2+' '+sSomeoneChangeNick+' '+#2+sNewNick+#2);
  end;

  // Change nick in ignore list
  sl:=IrcConf.GetStrings('IgnoreList');
  if Assigned(sl) then
  begin
    with sl do
    begin
      for i:=0 to Count-1 do
        if Names[i]=sNick then Strings[i]:=sNewNick+NameValueSeparator+ValueFromIndex[i];
    end;
  end;
end;

//----
procedure TIrcClient.ChangeNickMode(sNick, sNewMode, sChan: string);
var
  i, k, n:            integer;
  s, s1, sMode, sNickList: string;
begin
  s1:=Copy(sNewMode, 1, Pos(' ', sNewMode)-1);


  // Вариант 1: sNick='ChanServer'  sNewMode='#local +v Hunter2'
  // Вариант 1: sNick='ChanServer'  sNewMode='#local +qo Hunter Hunter'
  if s1 = sChan then
  begin
    s:=Copy(sNewMode, Pos(' ', sNewMode)+1, maxInt);
    sMode := Copy(s, 1, Pos(' ', s)-1);
    sNick := Copy(s, Pos(' ', s)+1, maxInt);
  end

  // Вариант 2: ??
  else if sNick = sNewMode then
  begin
    s := sNewMode;
    sMode := Copy(s, 1, Pos(' ', s)-1);
    sNick := Copy(s, Pos(' ', s)+1, maxInt);
  end
  // Вариант 0: sNick='Hunter2'  sNewMode='+iwx'
  else sMode := sNewMode;

  if sChan='' then
    n:=self.FServerPageID
  else
    n:=self.GetPageIDByName(sChan);

  k:=ciIconNormal;
  if Length(sMode)>1 then
  begin
    if sMode[1]='+' then
    begin
      sNickList:=sNick;
      for i:=2 to Length(sMode) do
      begin
        k:=GetUserModeIconIndex(sMode[i]);
        if k=ciIconNormal then Continue;
        sNick:=ParamFromStr(sNickList, i-1);
        Core.ChangeNick(n, sNick, sNick, k);
      end;
    end
    else Core.ChangeNick(n, sNick, sNick, k);
  end;
end;

//----
function TIrcClient.CreateChannelPage(Name: string; ImageID: integer = -1): integer;
var
  PageInfo: TPageInfo;
  PageID: integer;
begin
  if ImageID = -1 then ImageID:=FInfoProtocolID;
  result:=GetPageIDByName(Name);
  if result > 0 then Exit;
  Core.ClearPageInfo(PageInfo);
  PageInfo.sServer:=IrcConf['ServerHost'];
  PageInfo.sChan:=Name;
  PageInfo.Caption:=Name;
  PageInfo.sMode:='IRC CHAN';
  PageInfo.ImageIndex:=ImageID;
  PageInfo.ImageIndexDefault:=ImageID;
  PageInfo.PageType:=ciChatPageType;
  PageID:=PagesManager.CreatePage(PageInfo);
  Core.PagesManager.MovePage(PageID, self.FServerPageID);

  self.ModifyPagesList(PageID, 1);
  self.ModActiveChanList(Name, PageID, ciChanTypeChannel, 1);
  Core.PagesManager.ActivatePage(PageID);
  result:=PageID;
end;

function TIrcClient.CreatePrivatePage(UserName: string): integer;
var
  PageInfo: TPageInfo;
  PageID: integer;
  ChanRec: TChanRec;
begin
  if self.FChanList.GetChanRecByName(UserName, ChanRec) then
  begin
    result:=ChanRec.PageID;
    Exit;
  end;
  // Создаем закладку привата
  Core.ClearPageInfo(PageInfo);
  PageInfo.sServer:=self.FInfoConnection;
  PageInfo.Caption:='>'+UserName;
  PageInfo.sNick:=UserName;
  PageInfo.ImageIndex:=ciIconIRC;
  PageInfo.sMode:='IRC PRIV';
  //self.FChanList.GetChanRecByName();
  PageID:=PagesManager.CreatePage(PageInfo);
  Core.PagesManager.MovePage(PageID, self.FServerPageID);
  Core.AddNicks(PageID, IrcConf['MyNick']+' '+UserName);

  self.ModActiveChanList('>'+UserName, PageID, ciChanTypePrivate, 1);
  self.ModifyPagesList(PageID, 1);
  result:=PageID;
end;

//----
function TIrcClient.RemovePage(Name: string): boolean;
var
  PageInfo: TPageInfo;
  PageID: integer;
begin
  result:=false;
  PageID:=GetPageIDByName(Name);
  if PageID < 0 then Exit;

  if Core.PagesManager.RemovePage(PageID) then
  begin
    self.ModifyPagesList(PageID, -1);
    self.FChanList.Delete(self.FChanList.GetIndexByName(Name));
    self.ModActiveChanList(Name, 0, 0, -1);
  end;

  result:=true;
end;

//----
procedure TIrcClient.AddChanToList(sRawChanName, sRawChanDesc: string);
var
  Page: TChatPage;
  PageInfo: TPageInfo;
begin
  // TODO: предусмотреть повторную загрузку списка каналов
  Page:=Core.PagesManager.GetPage(self.FChanListPageID);
  if not Assigned(Page) then
  begin
    Core.ClearPageInfo(PageInfo);
    PageInfo.sServer:=IrcConf['ServerHost'];
    PageInfo.Caption:=sChanListCaption;
    PageInfo.sMode := 'CHAN LIST';
    //PageInfo.ImageIndex:=ImageID;
    PageInfo.ImageIndex:=-1;
    PageInfo.ImageIndexDefault:=-1;
    PageInfo.PageType:=ciChanListPageType;
    self.FChanListPageID:=PagesManager.CreatePage(PageInfo);
    Core.PagesManager.MovePage(self.FChanListPageID, self.FServerPageID);
    self.ModifyPagesList(self.FChanListPageID, 1);
    Core.PagesManager.ActivatePage(self.FChanListPageID);
    Page:=Core.PagesManager.GetPage(self.FChanListPageID);
    with TFrameChanList(Page.Frame) do
    begin
      MesText.MinTextWidth:=2000;
      MesText.HScrollVisible:=true;
      iChanAdded:=0;
      ChatClient:=self;
    end;
  end;
  if not Assigned(Page) then Exit;
  TFrameChanList(Page.Frame).AddChanToList(sRawChanName, sRawChanDesc);
end;

//----
procedure TIrcClient.ModActiveChanList(ChanName: string; PageID: integer; ChanType: integer; DoAdd: integer = 1);
// Modify channel list
// DoAdd - 1 add, -1 remove
// if ChanName empty, PageID used
var
  ChanRec: TChanRec;
  i: integer;
begin
  ChanRec.ChanName:=ChanName;
  ChanRec.PageID:=PageID;
  ChanRec.Password:='';
  ChanRec.ChanType:=ChanType;
  if DoAdd=1 then
  begin
    self.FChanList.Add(ChanRec);
  end
  else if DoAdd=-1 then
  begin
    if ChanName='' then
    begin
      for i:=FChanList.Count-1 downto 0 do
      begin
        if FChanList.GetChanRec(i).PageID = PageID then
        begin
           FChanList.Delete(i);
           Exit;
        end;
      end;
    end
    else
    begin
      self.FChanList.Delete(FChanList.GetIndexByName(ChanName));
    end;
  end;

end;

//----
function TIrcClient.ClosePage(PageID: integer): boolean;
var
  PageInfo: TPageInfo;
begin
  result:=false;

  if PageID = FServerPageID then Exit;
  if not Core.PagesManager.GetPageInfo(PageID, PageInfo) then Exit;
  if PageInfo.sMode='IRC CHAN' then SendTextToServer('PART '+PageInfo.sChan+#10);
  if PageInfo.sMode='DCC CHAT' then
  begin
    DCC_Stop(PageInfo.sNick);
  end;
  if Core.PagesManager.RemovePage(PageID) then
  begin
    self.ModActiveChanList('', PageID, 0, -1);
    self.ModifyPagesList(PageID, -1);
  end;

  result:=true;
end;

function TIrcClient.UserListContextMenu(PageID: integer; ulcm: TPopupMenu): boolean;
begin
  result:=true;
  if PageID = self.FServerPageID then result:=False;
end;

//==============================
// Работа с сокетом
//==============================
function TIrcClient.StartConnection(): boolean;
var
  pHost, pPort, pType, pUser, pPass: string;
begin
  result:=false;
  self.FServerHost:=IrcConf['ServerHost'];
  self.FServerPort:=IrcConf['ServerPort'];
  self.FInfoConnection:=self.FInfoProtocolName+' '+self.FServerHost+':'+self.FServerPort;
  self.IrcConf.RootNode.FullName:=self.FInfoConnection;

  bUseProxy:=true;
  bProxyConnected:=false;
  if Trim(self.ServerProxy)='' then bUseProxy:=false;

  Core.ModTimerEvent(-1, Self.FServerPageID, 0, '/CONNECT');
  self.Socket.SetSSL(IrcConf['SSLType'], IrcConf['SSLUser'], IrcConf['SSLPass'], IrcConf['SSLKeyPass']);

  if bUseProxy then
  begin
    Event('irceDebugMessage '+sConnOpenHost+' '+#2+self.FServerHost+#2+' '+sConnOpenPort+' '+self.FServerPort+' (proxy: '+self.ServerProxy+')');
    self.ShowText(FServerPageID, TimeTemplate()+#3+'04 '+sConnOpenHost+' '+#2+self.FServerHost+#2+' '+sConnOpenPort+' '+self.FServerPort+' (proxy: '+self.ServerProxy+')');

    Misc.ParseProxyURL(self.ServerProxy, pType, pHost, pPort, pUser, pPass);
    //self.Socket.SetProxy(IrcConf.GetInteger('ProxyType'), pHost, pPort, IrcConf['ProxyUser'], IrcConf['ProxyPass']);
    self.Socket.SetProxy(IrcConf['ProxyType'], pHost, pPort, IrcConf['ProxyUser'], IrcConf['ProxyPass']);
    {try
      self.Socket.Open(pHost, '', '', StrToIntDef(pPort, 3128), false);
      result:=true;
    except
      Self.Event('irceSocketConnectError '+sIrcSocketConectError{+' '+GetSocketErrorDescription(ErrorCode));
    end;
    Exit;}
  end
  else
  begin
    Event('irceDebugMessage '+sConnOpenHost+' '+#2+self.FServerHost+#2+' '+sConnOpenPort+' '+self.FServerPort);
    self.ShowText(FServerPageID, TimeTemplate()+#3+'04 '+sConnOpenHost+' '+#2+self.FServerHost+#2+' '+sConnOpenPort+' '+self.FServerPort);
  end;

  try
    //self.Socket.Open(self.FServerHost, '', '', StrToIntDef(self.FServerPort, 6667), false);
    self.Socket.Open(self.FServerHost, self.FServerPort);
    result:=true;
    IrcConf.FToolButtons.tbtnConnect.Down:=true;
    IrcConf.FToolButtons.tbtnConnect.Caption:='/DISCONNECT';
  except
    Self.Event('irceSocketConnectError '+sIrcSocketConectError{+' '+GetSocketErrorDescription(ErrorCode)});
  end;
end;

function TIrcClient.StopConnection(): boolean;
begin
  Result:=True;
  if self.FActive then self.ShowText(FServerPageID, TimeTemplate()+#2+#3+'04 '+sConnDisconnected);
  if Socket.Connected then SendTextToServer('QUIT : '+IrcConf['QuitMessage']+#10);
  Core.ModTimerEvent(-1, FServerPageID, 0, '/* SERV_TIMEOUT');
  Core.ModTimerEvent(-1, FServerPageID, 0, '/* KEEP_ALIVE');
  IrcConf.FToolButtons.tbtnConnect.Down:=false;
  IrcConf.FToolButtons.tbtnConnect.Caption:='/SERVER';
  IrcConf.FToolButtons.tbtnChanList.Enabled:=false;
  IrcConf.FToolButtons.tbtnOnline.Down:=false;
  IrcConf.FToolButtons.tbtnAway.Down:=false;
  Socket.Close();
  self.FActive := false;
  IrcConf['LocalIP']:='';
  Core.PlayNamedSound('sfxDisconnect', self);
end;

function TIrcClient.SendTextToServer(sText: string): boolean;
begin
  result:=false;
  if not Socket.Connected then Exit;
  if KeepAlivePeriod > 0 then Core.ModTimerEvent(0, FServerPageID, KeepAlivePeriod, '/* KEEP_ALIVE');
  if bSendUTF8 then
    Socket.SendText(AnsiToUtf8(sText))
  else
    Socket.SendText(sText);
  result:=true;
end;

function TIrcClient.Connect(): boolean;
begin
  FKeepConnection:=IrcConf.GetBool('AutoReconnect');
  result:=StartConnection;
end;

function TIrcClient.Disconnect(): boolean;
begin
  FKeepConnection:=False;
  result:=StopConnection();
end;

procedure TIrcClient.Event(EventText: string);
begin
  Core.DebugMessage(EventText);
  if Assigned(FIrcEvent) then FIrcEvent(Self, EventText);
end;

//procedure TIrcClient.OnSocketEvent(Sender: TObject; Socket: TCustomWinSocket; SocketEvent: TSocketEvent);
procedure TIrcClient.OnSocketEvent(Sender: TObject; ASocket: TTCPBlockSocket; SocketEvent: TSocketEvent);
begin
  case SocketEvent of
  seLookup:
    begin
      Self.Event('irceSocketEvent '+sIrcSocketLookup);
    end;
  seConnecting:
    begin
      Self.Event('irceSocketEvent '+sIrcSocketConnecting);
    end;
  seConnect:
    begin
      Self.OnSocketConnect(Sender, ASocket);
      //Self.Event(irceSocketEvent, sIrcSocketConnect);
    end;
  seRead:
    begin
      Self.OnSocketRead(Sender, ASocket);
      //Self.Event(irceSocketEvent, sIrcSocketRead);
    end;
  else
    begin
      //Self.Event('irceSocketEvent'+sIrcSocketOtherEvent);
      //FActive := Socket.Connected;
    end;
  end;
end;

procedure TIrcClient.OnSocketErrorEvent(Sender: TObject; ASocket: TTCPBlockSocket; ErrorEvent: TErrorEvent; ErrorMsg: string);
var
  n: Integer;
begin
  //Self.Event('irceSocketProxyError '+self.Socket.GetLastErrorStr());
  Self.Event('irceSocketError '+ErrorMsg);
  {case ErrorEvent of
  eeGeneral:
    begin
      Self.Event('irceSocketError '+sIrcSocketGeneralError+' '+ErrorMsg);
    end;
  eeSend:
    begin
      Self.Event('irceSocketError '+sIrcSocketSendError+' '+ErrorMsg);
    end;
  eeReceive:
    begin
      Self.Event('irceSocketError '+sIrcSocketReceiveError+' '+ErrorMsg);
    end;
  eeConnect:
    begin
      Self.Event('irceSocketError '+sIrcSocketConectError+' '+ErrorMsg);
    end;
  else
    begin
      Self.Event('irceSocketError '+sIrcSocketOtherError+' '+ErrorMsg);
    end;
  end;}
  self.Socket.Close();
  self.StopConnection();
  if FKeepConnection then
  begin
    n:=IrcConf.GetInteger('AutoReconnectDelay');
    ShowText(Self.FServerPageID, TimeTemplate()+#3+'04 '+Format(sReconnectEvent, [IntToStr(n)]));
    Core.ModTimerEvent(1, Self.FServerPageID, n*1000, '/CONNECT');
  end;
end;

procedure TIrcClient.OnSocketConnect(Sender: TObject; ASocket: TTCPBlockSocket);
var
  sUserInfo: string;
  sPassword: string;
  sUser: string;
begin
  self.FActive:=true;
  self.FLocalAddress := self.Socket.LocalAddress;
  IrcConf['LocalIP']:=self.FLocalAddress;

  {if bUseProxy and (not bProxyConnected) then
  begin
    SendTextToServer('CONNECT '+IrcConf['ServerHost']+':'+IrcConf['ServerPort']+' HTTP/1.0'+#13+#10+#13+#10);
    Exit;
  end;}
  Self.Event('irceSocketConnected '+#3+'03'+sConnConnect);
  IrcConf.FToolButtons.tbtnChanList.Enabled:=true;
  IrcConf.FToolButtons.tbtnOnline.Down:=true;
  IrcConf.FToolButtons.tbtnAway.Down:=false;

  sPassword := IrcConf['ServerPass'];
  if Length(Trim(sPassword))>0 then
  begin
    SendTextToServer('PASS ' + sPassword + chr($0A));
  end;
  sUser:=IrcConf['ServerUser'];
  if Length(Trim(sPassword))=0 then sUser:='RealChat';

  self.FMyNick:=IrcConf['MyNick'];
  SendTextToServer('NICK ' + IrcConf['MyNick'] + chr($0A));
  sUserInfo:=IrcConf['MyFullName'];
  if Trim(sUserInfo)='' then sUserInfo:='RealChat user';
  Self.Event('irce: '+'USER '+sUser+' '+self.Socket.RemoteAddress+' irc :'+sUserInfo);
  SendTextToServer('USER '+sUser+' '+self.Socket.RemoteAddress+' irc :'+sUserInfo+chr($0A));
  Core.PlayNamedSound('sfxConnect', self);
end;

procedure TIrcClient.OnSocketRead(Sender: TObject; ASocket: TTCPBlockSocket);
var
  dat :TSepRec;
  i   :Integer;
begin
  if ServerDataTimeout > 0 then Core.ModTimerEvent(0, FServerPageID, ServerDataTimeout, '/* SERV_TIMEOUT');
  while Socket.ReceiveLength() > 0 do
  begin
    //Application.ProcessMessages;
    sBuf:=sBuf + Socket.ReceiveText();
  end;
  dat := SplitString2(sBuf, #10);
  {if bUseProxy and (not bProxyConnected) then
  begin
    if dat.max>0 then
      if Pos('200', dat.rec[1])>0 then
      begin
        Self.Event('irceDebugMessage '+'Proxy connected');
        bProxyConnected:=true;
        OnSocketConnect(Sender, Socket);
        Exit;
      end
      else if Pos('407', dat.rec[1])>0 then
      begin
        Self.Event('irceDebugMessage '+'Proxy authentication required');
        SendTextToServer('CONNECT '+IrcConf['ServerHost']+':'+IrcConf['ServerPort']+' HTTP/1.0'
        +#13+#10+'proxy-authorization: Basic '+CodeStringBase64(IrcConf['ProxyUser']+':'+IrcConf['ProxyPass'])
        +#13+#10+'proxy-connection: Keep-Alive'
        +#13+#10+#13+#10);
        Exit;
      end
      else
      begin
        Self.Event('irceDebugMessage '+'Proxy not connected: '+dat.rec[1]);
        Self.Socket.Close();
        Exit;
      end;
  end; }
  //dat := SplitString(Socket.ReceiveText, Chr(10));
  if dat.max < 1 then Exit;
  for i := 1 to dat.max do
  begin
    //Application.ProcessMessages;
    interpret(dat.rec[i]);
  end;
end;

//=====================================================================
// Parse IRC messages and commands
//=====================================================================
procedure TIrcClient.ParseData(strData: String; var parsed: TParsedData);
var
  n,i: integer;
  s, st: string;
begin
  //Обнуляем переменные
  with parsed do
  begin
    bHasPrefix := False;
    strFullHost := '';
    strNick := '';
    strIdent := '';
    strHost := '';
    strCommand := '';
    strText := '';
    intParams := 0;
    //Устанавливаем размер массива
    SetLength(strParams, intParams);
  end;
  st:=strData;

//  RFC 1459

//  <message>  ::= [':' <prefix> <SPACE> ] <command> <params> <crlf>
//  <prefix>   ::= <servername> | <nick> [ '!' <user> ] [ '@' <host> ]
//  <command>  ::= <letter> { <letter> } | <number> <number> <number>
//  <SPACE>    ::= ' ' { ' ' }
//  <params>   ::= <SPACE> [ ':' <trailing> | <middle> <params> ]
//  <middle>   ::= <Any *non-empty* sequence of octets not including SPACE
//                 or NUL or CR or LF, the first of which may not be ':'>
//  <trailing> ::= <Any, possibly *empty*, sequence of octets not including
//                   NUL or CR or LF>
//  <crlf>     ::= CR LF


  // Определяем наличие префикса
  n:=Pos(':', st);
  if n=1 then
  begin
    parsed.bHasPrefix := True;
    st:=Copy(st, n+1, maxint); // остаток строки
    // Выделяем префикс
    i:=Pos(' ', st);
    s:=Copy(st, 1, i-1);
    parsed.strFullHost := s;
    parsed.strHost := s;

    // разделяем префикс на части (сервер/ник, юзер, хост)
    n:=Pos('!', s);
    if n > 0 then
    begin
      // Выделяем ник
      parsed.strNick:=Copy(s, 1, n-1);
      // Выделяем имя и хост
      s:=Copy(parsed.strFullHost, n+1, maxint);
      n:=Pos('@', s);
      parsed.strIdent:=Copy(s, 1, n-1);
      parsed.strHost:=Copy(s, n+1, maxint);
    end;
    st:=Copy(st, i+1, maxint); // остаток строки
  end;

  // Выделяем команду
  n:=Pos(' ', st);
  //if n=0 then Exit;
  parsed.strCommand:=Copy(st, 1, n-1);
  st:=Copy(st, n+1, maxint); // остаток строки
  parsed.strText := st;

  // выделяем прочие параметры
  n:=1;
  while n > 0 do
  begin
    if copy(st, 1, 1)=':' then
    begin
      //parsed.strParams[parsed.intParams-1] := copy(st, 2, maxint);
      parsed.strText := copy(st, 2, maxint);
      Exit;
    end;
    Inc(parsed.intParams);
    SetLength(parsed.strParams, parsed.intParams);
    n:=Pos(' ', st);
    if n = 0 then
      parsed.strParams[parsed.intParams-1] := copy(st, 1, maxint)
    else
      parsed.strParams[parsed.intParams-1] := copy(st, 1, n-1);
    st:=Copy(st, n+1, maxint);
  end;
end;

procedure TIrcClient.Interpret(strData :String);
var
  Parsed    :TParsedData;
  AllParams :String;
  strTemp   :String;
  strCmd    :String;
  strSender, strTarget, strText: string;
  numCmd, i: integer;
  sl: TStringList;
  bFlag: boolean;
  pi: TPageInfo;
begin
  if bDebugInfo then self.Event('irceRawMessage '+strData);

  strData := StrReplace(strData, #13, '');
  strData := StrReplace(strData, #10, '');
  if self.bReceiveUTF8 then
  begin
    strTemp:=UTF8ToAnsi(strData);
    if Trim(strTemp)<>'' then strData:=strTemp;
  end;
  ParseData(strData, parsed);
  if parsed.strCommand = '' then Exit;

  // Посылаем событие с командой
  //OnIrcMessageEvent(self, parsed);
  //ResetTimer(TC_ServerData);
  //Exit;

  strCmd:=UpperCase(parsed.strCommand);
  numCmd:=StrToIntDef(strCmd, 0);
  strText:=parsed.strText;
  strSender:=parsed.strNick;
  strTarget:='';
  if Length(parsed.strParams)>0 then
  begin
    strTarget := parsed.strParams[0];
    for i:=0 to parsed.intParams-1 do AllParams:=AllParams+parsed.strParams[i]+' ';
    SetLength(AllParams, Length(AllParams)-1);
  end;

  // Send message to plugins
  if Assigned(Core.PluginsManager) then
  begin
    strTemp:='IRC '+Norm(self.FInfoConnection)+' '+strCmd;
    if strSender='' then strTemp:=strTemp+' IRC' else strTemp:=strTemp+' '+Norm(strSender);
    strTemp:=strTemp+' '+IntToStr(parsed.intParams);
    for i:=0 to parsed.intParams-1 do strTemp:=strTemp+' '+Norm(parsed.strParams[i]);
    strTemp:=strTemp+' '+Norm(strText);
    Core.PluginsManager.BroadcastMsg(strTemp);
  end;

  if strCmd='' then Exit

  else if strCmd='PING' then
  begin
    self.SendTextToServer('PONG :'+strText+chr($0A));
    if IrcConf.GetBool('ShowServerPing') then
    begin
      ShowText(self.FServerPageID, TimeTemplate()+#3+'03PiNG? PONG! ['+strText+']');
    end;
    //ResetTimer(TC_ServerPing);
  end

  else if strCmd='PONG' then
  begin
    //ResetTimer(TC_ServerPing);
    //if not conf.bShowServerPing then Exit;
  end

  // :Hunter!~Miranda@82.211.176.11 JOIN :#local
  else if strCmd='JOIN' then
  begin
    if AnsiLowerCase(strSender) = AnsiLowerCase(IrcConf['MyNick']) then
    begin
      i:=self.CreateChannelPage(strText);
      //SendTextToServer('MODE ' + AllParams + chr($0A));
      OnJoin(strText);
    end
    else
    begin
      if IrcConf.GetBool('ShowStatusMessages') then
      begin
        ShowText(GetPageIDByName(strText), TimeTemplate()+#3+'07 '+#2+strSender+#2+' ('+parsed.strHost+') '+sComeToChannel);
      end;
      //Core.AddNicks(GetPageIDByName(strText), strSender);
      self.AddNicks(strSender, strText);
    end;
  end

  else if strCmd='PRIVMSG' then
  begin
    OnPrivmsg(strSender, strTarget, strText);
  end

  // :LEON!~ExCluSiVe@local.26.205.tvkursk.ru NICK :FANATIK
  else if strCmd='NICK' then
  begin
    ChangeNick(strSender, strText);
  end

  else if strCmd='PART' then
  begin
    i:=GetPageIDByName(strTarget);
    if i < 0 then Exit;
        if AnsiLowerCase(strSender) = AnsiLowerCase(IrcConf['MyNick']) then
    begin // our nick
      if flagHop then
      begin
        Core.RemoveNick(i, '', true);
      end
      else
      begin
        //TabsRemove(ReturnChanIndex(strTarget));
        self.RemovePage(strTarget);
      end;
    end
    else
    begin // someone nick
      if IrcConf.GetBool('ShowStatusMessages') then
      begin
        ShowText(i, TimeTemplate()+#3+'07 '+#2+strSender+#2+' '+sLeaveChannel);
      end;
      Core.RemoveNick(i, ReplaceOps(strSender));
    end;
  end

  // :ChanServ!services@serbod.com MODE #local +qo Hunter Hunter
  else if strCmd='MODE' then
  begin
    if Length (strSender) > 0 then
    begin
      if IrcConf.GetBool('ShowStatusMessages') then
      begin
        ShowText(GetPageIDByName(strTarget), TimeTemplate()+#3+'03 '+#2+strSender+#2+' '+sUserSetMode+' '+strText);
      end;
      self.ChangeNickMode(strSender, strText, strTarget);
    end
    else
    begin
      ShowText(self.FServerPageID, TimeTemplate()+#3+'03 '+#2+strTarget+#2+' '+sMeSetMode+' '+strText);
      self.ChangeNickMode(strTarget, strText, '');
    end;
  end

  else if strCmd='QUIT' then
  begin
    for i:=0 to self.FChanList.Count-1 do
    begin
      Core.RemoveNick(self.FChanList.Channels[i].PageID, ReplaceOps(strSender));
      if IrcConf.GetBool('ShowStatusMessages') then
      begin
        ShowText(self.FChanList.Channels[i].PageID, TimeTemplate+#2+#3+'07 '+strSender+#2+' '+Format(sSomeoneLeaveChat,[strText]));
      end;
    end;
  end

  // KICK #Finnish John :Speaking English
  // :WiZ KICK #Finnish John
  else if strCmd='KICK' then
  begin
    if parsed.strParams[1] = IrcConf['MyNick'] then
    begin
      ShowText(GetPageIDByName(strTarget), TimeTemplate()+#3+'06 '+#2+strSender+#2+' '+sKickedYou+' '+#2+strTarget+#2+' ['+strText+']');
      Core.RemoveNick(GetPageIDByName(strTarget), '', true); // Clear nicklist
    end
    else
    begin
      ShowText(GetPageIDByName(strTarget), TimeTemplate()+#3+'06 '+#2+strSender+#2+' '+Format(sKickedSomeone, [parsed.strParams[1]])+' '+#2+strTarget+#2+' ['+strText+']');
      Core.RemoveNick(GetPageIDByName(strTarget), ReplaceOps(parsed.strParams[1]));
    end;
  end

  // TOPIC #test :another topic
  // :Wiz TOPIC #test :New topic
  else if strCmd='TOPIC' then
  begin
    ShowText(GetPageIDByName(strTarget), TimeTemplate()+#3+'03 '+Format(sSomeoneChangeTopic, [strSender, strText]));
  end

  else if strCmd='NOTICE' then
  begin
    strText:=StrReplace(parsed.strText, strAction, '');
    i:=self.FServerPageID;
    if Copy(parsed.strParams[0], 1, 1)='#' then i:=GetPageIDByName(parsed.strParams[0]);
    if strSender = '' then
      ShowText(i, TimeTemplate()+#2+#3+'05'+'Server NOTICE'+#3+#2+': '+strText)
    else
    begin
      Core.AddNote(strSender, strText);
      ShowText(i, TimeTemplate()+#2+#3+'05'+'NOTiCE'+#3+#2+': '+strSender+' '+strText);
      Core.PlayNamedSound('sfxNoteMsg', self);
    end;
  end

  else if strCmd='ERROR' then
  begin
    if Pos('Closing', strText) > 0 then
    begin
      self.Disconnect();
    end
    else
    begin
      ShowText(self.FServerPageID, TimeTemplate()+#3+'03 '+'ERROR~~~'+strText);
    end;
  end

  else if numCmd=1 then  // 001
  begin
    self.FMyNick := strTarget;
    IrcConf['MyNick'] := strTarget;
    ShowText(self.FServerPageID, TimeTemplate()+#3+'05* '+strText);
    OnLogin();
  end

  else if numCmd in [2..5] then
  begin
    ShowText(self.FServerPageID, TimeTemplate()+#3+'05* '+AllParams+' '+strText);
  end

  else if numCmd=324 then  // RPL_CHANNELMODEIS // "<channel> <mode> <mode params>"
  begin
        if Length(TrimRight(strText)) > 1 then
    begin
      ShowText(self.FServerPageID, TimeTemplate()+sChannelName+' '+#2+parsed.strParams[1]+#2+' '+sChannelModes+' '+strText);
    end;
    OnJoin(parsed.strParams[1]);
  end

  // 344 // Name in use
  // :irc.heavy-online.ru 433 * Hunter :Nickname is already in use.
  else if numCmd=433 then
  begin
    strTemp:=Trim(parsed.strParams[1]);
    if (strTemp = IrcConf['MySecondNick']) then
    begin
      //strTemp := strTemp+Chr(65+Random(21));
      strTemp := strTemp+Chr(97+Random(21));
    end
    else
    begin
      strTemp:=IrcConf['MySecondNick'];
    end;
    self.FMyNick:=strTemp;
    IrcConf['MyNick']:=strTemp;
    ShowText(self.FServerPageID, TimeTemplate()+#3+'06 '+sNameInUse+' '+strTemp);
    SendTextToServer('NICK '+strTemp+chr($0A));
  end

  // 252  RPL_LUSEROP // "<integer> :operator(s) online"
  // 253  RPL_LUSERUNKNOWN // "<integer> :unknown connection(s)"
  // 254  RPL_LUSERCHANNELS // "<integer> :channels formed"
  // 256  RPL_ADMINME // "<server> :Administrative info"
  else if (numCmd=252) or (numCmd=253) or (numCmd=254) or (numCmd=256) then
  begin
    ShowText(self.FServerPageID, TimeTemplate()+#3+'06 '+strTarget+' '+strText);
  end

  // 251  RPL_LUSERCLIENT // ":There are <integer> users and <integer> \
  //                         invisible on <integer> servers"
  // 255  RPL_LUSERME //  ":I have <integer> clients and <integer> servers"
  // 257  RPL_ADMINLOC1 // ":<admin info>"
  // 257  RPL_ADMINLOC1 // ":<admin info>"
  // 258  RPL_ADMINLOC2 // ":<admin info>"
  // 259  RPL_ADMINEMAIL // ":<admin info>"
  else if (numCmd=251) or (numCmd=255) or (numCmd=257) or (numCmd=258) or (numCmd=259)
  or (numCmd=265) or (numCmd=266) then
  begin
    ShowText(self.FServerPageID, TimeTemplate()+#3+'06 '+strText);
  end

  else if numCmd=305 then // :irc.amnet 305 HUNTER2 :You are no longer marked as being away
  begin
    IrcConf.FToolButtons.tbtnOnline.Down:=true;
    IrcConf.FToolButtons.tbtnAway.Down:=false;
  end

  else if numCmd=306 then // :irc.amnet 306 HUNTER2 :You have been marked as being away
  begin
    IrcConf.FToolButtons.tbtnOnline.Down:=false;
    IrcConf.FToolButtons.tbtnAway.Down:=true;
  end

  else if numCmd=307 then // :irc.ru 307 HUNTER2 kerhS :has identified for this nick
  begin
  end

  else if numCmd=311 then // RPL_WHOISUSER // "<nick> <user> <host> * :<real name>"
  begin
    InfoList.Items[0].Name:=sUserInfoNick;
    InfoList.Items[0].Data:=parsed.strParams[1]+' (ident: '+parsed.strParams[2]+')'; // Ник
    InfoList.Items[1].Name:=sUserInfoName;
    InfoList.Items[1].Data:=strText; // Имя
    InfoList.Items[2].Name:=sUserInfoComp;
    InfoList.Items[2].Data:=parsed.strParams[3]; //Хост
  end

  else if numCmd=312 then // RPL_WHOISSERVER // "<nick> <server> :<server info>"
  begin
    InfoList.Items[4].Name:=sUserInfoServ;
    InfoList.Items[4].Data:=strText;
  end

  {else if numCmd=313 then // RPL_WHOISOPERATOR //"<nick> :is an IRC operator"
  begin
    InfoList.Items[3].Name:=sUserInfoChan;
    InfoList.Items[3].Data:=strText;
  end}

  else if numCmd=317 then // RPL_WHOISIDLE // "<nick> <integer> <integer >:seconds idle, signon time"
  begin
    InfoList.Items[5].Name:=sUserInfoIdle;
    InfoList.Items[5].Data:=SecToTime(StrToIntDef(parsed.strParams[2], 0));
    InfoList.Items[6].Name:=sUserInfoOnln;
    InfoList.Items[6].Data:=UNIXtoDateTime(parsed.strParams[3]);
  end

  else if numCmd=318 then  // RPL_ENDOFWHOIS // "<nick> :End of /WHOIS list"
  begin
    //Event('ShowUserInfo');
    Core.ShowInfoList(InfoList, self);
    for i:=0 to 6 do InfoList.Items[i].Data:='';
  end

  else if numCmd=319 then // RPL_WHOISCHANNELS // "<nick> :{[@|+]<channel><space>}"
  begin
    InfoList.Items[3].Name:=sUserInfoChan;
    InfoList.Items[3].Data:=strText;
  end

  else if numCmd=321 then // RPL_LISTSTART // "Channel :Users  Name"
  begin
  end

  else if numCmd=322 then // RPL_LIST // "<channel> <# visible> :<topic>"
  begin
    AddChanToList(parsed.strParams[1]+' '+parsed.strParams[2]+' '+strText, strText);
  end

  else if numCmd=323 then // RPL_LISTEND // ":End of /LIST"
  begin
    AddChanToList('','');
  end

  // :irc.sovtest.ru 332 HUNTER2 #windows :Topic text
  else if numCmd=332 then // RPL_TOPIC // "<nick> <channel> :<topic>"
  begin
    if Core.PagesManager.GetPageInfo(GetPageIDByName(parsed.strParams[1]), pi) then
    begin
      ShowText(pi.ID, TimeTemplate()+#3+'03'+sChannelTopic+' '+strText);
      pi.Hint:=StripIRCCodes(strText);
      Core.PagesManager.SetPageInfo(pi);
      //DebugText(Params(parsed, 3, -1));
    end;
  end

  // :irc.sovtest.ru 333 HUNTER2 #windows ses 1192005271
  else if numCmd=333 then // topic set by
  begin
    ShowText(GetPageIDByName(parsed.strParams[1]), TimeTemplate()+#3+'03'+Format(sTopicSetBy, [parsed.strParams[2], UNIXtoDateTime(parsed.strParams[3])]));
  end

  // :irc.sovtest.ru 353 HUNTER2 = #windows :HUNTER2 @ses @Murzilka_away
  // 353  RPL_NAMREPLY //  "( "=" / "*" / "@" ) <channel> :[ "@" / "+" ] <nick> *( " " [ "@" / "+" ] <nick> )
                       // - "@" is used for secret channels, "*" for private channels, and "=" for others (public channels).
  else if numCmd=353 then
  begin
     //CreateNickList(strText, parsed.strParams[2], false);
     //Core.AddNicks(GetPageIDByName(parsed.strParams[2]), strText, 0, false);
     self.AddNicks(strText, parsed.strParams[2]);
  end

  else if numCmd=366 then // <nick> <channel> :End of /NAMES list.
  begin
  end

  else if numCmd=367 then // RPL_BANLIST // "<channel> <banid>"
  begin
    if Assigned(frmChanOptions) then frmChanOptions.AddBanId(parsed.strParams[2]);
  end

  else if numCmd=368 then // RPL_ENDOFBANLIST // "<channel> :End of channel ban list"
  begin
  end

  else if numCmd=372 then // RPL_MOTD // ":- <text>"
  begin
    ShowText(self.FServerPageID, TimeTemplate()+#2+sMOTD+#2+' '+strText);
  end

  else if numCmd=375 then // RPL_MOTDSTART // ":- <server> Message of the day - "
  begin
    ShowText(self.FServerPageID, TimeTemplate()+#2+sMOTD+#2+' '+strText);
  end

  else if numCmd=376 then // RPL_ENDOFMOTD // ":End of /MOTD command"
  begin
  end

  else if numCmd=404 then // ERR_CANNOTSENDTOCHAN // "<channel name> :Cannot send to channel"
  begin
    ShowText(GetPageIDByName(strTarget), TimeTemplate()+#3+'05 '+Format(sYouCannotWriteToChannel, [strTarget])+' - '+strText);
  end

  else if numCmd=442 then // ERR_NOTONCHANNEL // "<channel> :You're not on that channel"
  begin
    self.RemovePage(strTarget);
  end

  else if numCmd=474 then // ERR_BANNEDFROMCHAN // "<channel> :Cannot join channel (+b)"
  begin
    ShowText(self.FServerPageID, TimeTemplate()+#3+'05 '+Format(sYouCannotJoinChannel, [strTarget]));
  end

  else // неопознаная команда
  begin
    for i:=1 to Length(parsed.strParams)-1 do strTarget:=strTarget+' '+parsed.strParams[i];
    ShowText(self.FServerPageID, TimeTemplate()+'*** '+#2+parsed.strCommand+#2+' '+strTarget+' : '+strText);
  end;

end;

function TIrcClient.SendTextFromPage(PageInfo: TPageInfo; sText: string): string;
var
  strCom, strPassw, strTrimText, strTarget: string;
  strResult, strCmdText, strTemp, strTemp2: string;
  ChanRec: TChanRec;
  i: integer;
  TmpPageInfo: TPageInfo;
  sl: TStringList;
begin
  Result:='';
  strTrimText:=Trim(sText);
  if Length(strTrimText)<1 then Exit;

  strTarget:=PageInfo.sNick;
  if strTarget='' then strTarget:=PageInfo.sChan;

  // Если это не команда
  if Copy(strTrimText, 1, 1)<>'/' then
  begin
    ShowText(PageInfo.ID, TimeTemplate()+#2+'<'+IrcConf['MyNick']+'>'+#2+' '+sText);
    strPassw:=PageInfo.sPassword;
    if Length(Trim(strPassw))>0 then
    try
      EncryptText(sText, strPassw);
    except
    end;

    if PageInfo.sMode='IRC PRIV' then // Страница привата
      SendTextToServer('PRIVMSG '+PageInfo.sNick+' :'+sText+chr($0A))
    else if PageInfo.sMode='DCC CHAT' then // Страница DCC чата
      DCC_Say(PageInfo.sNick, sText)
    else // Обычное сообщение
      SendTextToServer('PRIVMSG '+strTarget+' :'+sText+chr($0A));
    Exit;
  end;

  i:=Pos(' ', strTrimText);
  if i=0 then
  begin
    strCom:=UpperCase(copy(strTrimText, 2, maxint));
    strCmdText:='';
  end
  else
  begin
    strCom:=UpperCase(copy(strTrimText, 2, i-2));
    strCmdText:=copy(strTrimText, i+1, maxint);
  end;
  strResult:='';

  if not self.FActive then
  begin
    strTemp:='CONNECT DEBUG SERVER QUIT';
    if Pos(strCom, strTemp) = 0 then
    begin
      ShowText(FServerPageID, TimeTemplate()+#2+#3+'04 '+sIrcNotConnected);
      Exit;
    end;
  end;

  if strCom='' then Exit

  else if strCom='*' then LocalEvent(strCmdText)

  else if strCom='JOIN' then
  begin
    flagHop:=false;
    strResult := 'JOIN ' + Trim(strCmdText);
    sl:=IrcConf.GetStrings('RecentChannelsList');
    if Assigned(sl) then
    begin
      strCmdText:=Trim(strCmdText);
      strCmdText:=StringReplace(strCmdText, '&', '', [rfReplaceAll]);
      with sl do
      begin
        i:=IndexOf(strCmdText);
        if i<0 then
          Insert(0, strCmdText)
        else
          Move(i, 0);
        if Count>ciRecentChannelsCount then Delete(ciRecentChannelsCount);
      end;
    end;
    IrcConf['RecentChannelsList']:=sl.Text;
  end

  else if strCom='PART' then
  begin
    if PageInfo.sChan <> '' then
    begin
        strResult := 'PART '+PageInfo.sChan;
    end;
  end

  else if strCom='ME' then
  begin
    strResult := 'PRIVMSG '+strTarget+' :'+strAction+'ACTION '+strCmdText+strAction;
    ShowText(PageInfo.ID, TimeTemplate()+' * '+IrcConf['MyNick']+' '+strCmdText);
  end

  else if strCom='MSG' then
  begin
    i:=Pos(' ',strCmdText);
    strResult := 'PRIVMSG '+Copy(strCmdText, 1, i-1)+' :'+Copy(strCmdText, i+1, maxint);
    ShowText(PageInfo.ID, #3+'03'+TimeTemplate()+'<'+IrcConf['MyNick']+'><'+Copy(strCmdText, 1, i-1)+'> '+Copy(strCmdText, i+1, maxint));
  end

  else if strCom='QUERY' then
  begin
    strResult := 'WHOIS '+strCmdText;
  end

  else if strCom='WHOIS' then
  begin
    strResult := 'WHOIS '+strCmdText;
  end

  else if strCom='PING' then
  begin
    strResult := 'PING '+IrcConf['ServerHost'];
  end

  else if strCom='RAW' then
  begin
    strResult := Trim(strCmdText);
    ShowText(self.FServerPageID, #3'02-> Server: '+#3+' '+strCmdText);
  end

  else if strCom='QUIT' then
  begin
    strResult := 'QUIT :'+IrcConf['QuitMessage'];
  end

  else if strCom='CONNECT' then
  begin
    self.Connect();
  end

  else if strCom='DISCONNECT' then
  begin
    self.Disconnect();
  end

  else if strCom='PRIV_LINE' then
  begin
    self.CreatePrivatePage(strCmdText);
  end

  else if strCom='SERVER' then
  begin
    strCmdText := Trim(strCmdText);
    if Length(strCmdText) = 0 then
    begin
      self.Disconnect;
      self.Connect;
      Exit;
    end
    else
    begin
      i:=Pos(':', strCmdText);
      if i > 1 then
      begin
        IrcConf['ServerHost'] := Trim(copy(strCmdText, 1, i-1));
        IrcConf['ServerPort'] := Trim(copy(strCmdText, i+1, maxint));
      end
      else
      begin
        IrcConf['ServerPort'] := '6667';
        IrcConf['ServerHost'] := strCmdText;
      end;
      self.Disconnect;
      self.Connect;
      Exit;
    end;
  end

  else if strCom='NOTICE' then
  begin
    i:=Pos(' ',strCmdText);
    strResult := 'NOTICE '+Copy(strCmdText, 1, i-1)+' :'+Copy(strCmdText, i+1, maxint);
    ShowText(PageInfo.ID, TimeTemplate()+#3+'05 NOTICE '+Copy(strCmdText, 1, i-1)+' : '+Copy(strCmdText, i+1, maxint));
  end

  else if strCom='NICK' then
  begin
    if Length(strCmdText) > 0 then
    begin
        strResult := 'NICK ' + strCmdText;
    end;
  end

  else if strCom='ID' then
  begin
    strResult := 'PRIVMSG NickServ :IDENTIFY '+strCmdText;
  end

  else if strCom='LIST' then
  begin
    strResult := 'LIST '+strCmdText;
  end

  else if strCom='TOPIC' then
  begin
    if PageInfo.sChan<>'' then
      strResult := 'TOPIC '+PageInfo.sChan+' :'+strCmdText;
  end

  else if strCom='MODE' then
  begin
    if (Length(strCmdText)>0) and ((strCmdText[1]='+') or (strCmdText[1]='-')) then
    begin
      if (PageInfo.sChan <> '') then
        strResult := 'MODE '+PageInfo.sChan+' '+strCmdText
      else
        strResult := 'MODE '+IrcConf['MyNick']+' '+strCmdText;
    end
    else
      strResult := 'MODE '+strCmdText;
  end

  else if strCom='KICK' then
  begin
    if PageInfo.sChan<>'' then
      strResult := 'KICK '+PageInfo.sChan+' '+strCmdText;
  end

  else if strCom='CTCP' then
  begin
    i:=Pos(' ',strCmdText);
    strResult := 'PRIVMSG '+Copy(strCmdText, 1, i-1)+' :'+strAction+Copy(strCmdText, i+1, maxint)+strAction;
    ShowText(PageInfo.ID, #3+'05'+TimeTemplate()+' CTCP '+Copy(strCmdText, 1, i-1)+': '+Copy(strCmdText, i+1, maxint));
  end

  else if strCom='REFRESH_NAMES' then
  begin
    Core.RemoveNick(PageInfo.ID, '', true);
    strResult := 'NAMES '+PageInfo.sChan;
  end

  else if strCom='HOP' then
  begin
    if (PageInfo.sChan <> '')
    then RejoinChannel(PageInfo.sChan);
    Exit;
  end

  else if strCom='AWAY' then
  begin
    strResult := 'AWAY '+strCmdText;
  end

  else if strCom='OPER' then
  begin
    strResult := 'OPER '+strCmdText;
  end

  else if strCom='DEBUG' then
  begin
    bDebugInfo := not bDebugInfo;
    if bDebugInfo then strCom:='ON' else strCom:='OFF';
    ShowText(self.FServerPageID, #2+'Debug: '+strCom);
    Exit;
  end

  else if strCom='PASS' then
  begin
    if (PageInfo.sMode='IRC CHAN') or (PageInfo.sMode='IRC PRIV') then
    begin
      if strCmdText='' then
      begin
        // Encription disabled
        ShowText(PageInfo.ID, #2+sPasswordUnset);
      end
      else
      begin
        // Testing encription..
        strTemp:='test';
        EncryptText(strTemp, strTemp);
        if strTemp<>'test' then
        begin
          ShowText(PageInfo.ID, #2+sPasswordSet);
        end
        else
        begin
          ShowText(PageInfo.ID, #2+sLibeay32NotFound);
          Exit;
        end;
      end;
      PageInfo.sPassword:=strCmdText;
      Core.PagesManager.SetPageInfo(PageInfo);
    end;
    //ShowText(PageInfo.ID, #2+sPasswordUnset);
    Exit;
  end

  else if strCom='DECODER' then
  begin
    {//if Assigned(frmTextDecoder) then Exit;
    FreeAndNil(frmTextDecoder);
    frmTextDecoder:=TfrmTextDecoder.Create(Form1);
    frmTextDecoder.Show();}
    Exit;
  end

  else if strCom='IGNORE' then
  begin
    ModifyIgnoreList(1, strCmdText);
    Exit;
  end

  else if strCom='UNIGNORE' then
  begin
    ModifyIgnoreList(-1, strCmdText);
    Exit;
  end

  else if strCom='DCC' then
  begin
    i:=Pos(' ',strCmdText);
    strTemp:=UpperCase(Copy(strCmdText, 1, i-1));
    //strResult := 'NOTICE '+Copy(strCmdText, 1, i-1)+' :'+Copy(strCmdText, i+1, maxint);
    if strTemp='CHAT' then
    begin
      DCC_Start(Copy(strCmdText, i+1, maxint), 'chat', self);
      Exit;
    end;
    if strTemp='SEND' then
    begin
      DCC_Start(Copy(strCmdText, i+1, maxint), 'send', self);
      Exit;
    end;
  end

  else if strCom='CHAN_OPTIONS' then
  begin
    if Assigned(frmChanOptions) then FreeAndNil(frmChanOptions);
    frmChanOptions:=TfrmChanOptions.Create(Core.MainForm);
    frmChanOptions.ChanName:=PageInfo.sChan;
    frmChanOptions.ChanTopic:=PageInfo.Hint;
    frmChanOptions.ChanModes:=PageInfo.sMode;
    frmChanOptions.IrcClient:=self;
    frmChanOptions.Start();
    Exit;
  end

  else
  begin
    Result:=''+#3+'04'+sIrcUncnownCommand+' '+sText;
  end;

  if strResult <> '' then SendTextToServer(strResult + #10);
end;

//=====================================================================
// Messages, actions
//=====================================================================

procedure TIrcClient.SendNoticeAction(strTarget: String; strText: String);
begin
  SendTextToServer('NOTICE '+strTarget+' :'+strAction+strText+StrAction+chr($0A));
end;

procedure TIrcClient.SendCtcpAction(strTarget: String; strText: String);
begin
  SendTextToServer('PRIVMSG '+strTarget+' :'+strAction+strText+StrAction+chr($0A));
end;

procedure TIrcClient.HandleCTCP(strNick :String; strData :String);
var
    strCom, strParam, s :String;
  i: integer;
begin
  //strData := RightR(strData, 1);
  //strData := LeftR(strData, 1);

  i:=Pos(' ', strData);
  if i=0 then strCom:=Trim(strData)
  else strCom:=UpperCase(Copy(strData, 1, i-1));
  strParam:=Copy(strData, i+1, maxint);

  if strCom='' then Exit

  else if strCom='VERSION' then
  begin
    s:=Trim(IrcConf['ClientVersion']);
    if s='' then s:=self.FInfoAbout;
    ShowText(self.FServerPageID, TimeTemplate()+#3+'05 '+Format(sSomeoneAskVersion,[strNick]));
    SendNoticeAction(strNick, 'VERSION ' + s);
  end

  else if strCom='PING' then
  begin
    ShowText(self.FServerPageID, TimeTemplate()+#3+'05 '+Format(sSomeonePingMe,[strNick]));
    SendNoticeAction(strNick, 'PING '+Trim(strParam));
  end

  else if strCom='USERINFO' then
  begin
    SendNoticeAction(strNick, 'USERINFO '+IrcConf['DccUserinfoReply']);
  end

  else if strCom='DCC' then
  begin
    i:=Pos(' ', strParam);
    s:=Copy(strParam, 1, i-1); // Первое слово параметров
    DCC_Start(strNick, strData, self);
    if s='RESUME' then
    begin
      s:=Copy(strParam, i+1, maxint); // Все, что после "RESUME"
      SendCtcpAction(strNick, 'DCC ACCEPT "'+Copy(s, 1, Pos(' ', s)-1)+'" '+Trim(Copy(s, Pos(' ', s)+1, maxint)));
    end;
  end

  else if strCom='TIME' then
  begin
    SendNoticeAction(strNick, 'TIME '+TimeTemplate());
  end

  else if strCom='FINGER' then
  begin
    ShowText(self.FServerPageID, TimeTemplate()+#3+'05 '+Format(sSomeoneFingerMe,[strNick]));
    SendNoticeAction(strNick, 'FINGER '+IrcConf['DccFingerReply']);
  end

  else if strCom='CLIENTINFO' then
  begin
    SendNoticeAction(strNick, 'CLIENTINFO '+self.FInfoAbout);
  end

  else if strCom='AVATAR' then
  begin
    if Length(Trim(IrcConf['AvatarURL']))>0 then
      SendNoticeAction(strNick, 'AVATAR ' + IrcConf['AvatarURL']);
  end

  else
  begin
    AddNote(strNick, strData);
  end;
end;

// Обработка входящего сообщения PRIVMSG
procedure TIrcClient.OnPrivmsg(strSender, strTarget, strText: string);
var
  strPassw: string;
  bCTCP, bTargetIsNick: boolean;
  PageID, i: integer;
begin
  bTargetIsNick := true;
  if copy(strTarget, 1, 1) = '#' then bTargetIsNick:=false; // Target is channel

  bCTCP:=false;
  if Copy(strText, 1, 1) = #1 then
  begin
    strText:=StrReplace(strText, #1, '');
    bCTCP:=true;
  end;

  // === CTCP to Nick ===
  if bCTCP and bTargetIsNick then // CTCP to nick
  begin
    //HandleCTCP(strTarget, strText);
    HandleCTCP(strSender, strText);
  end

  // === CTCP to # ===
  else if bCTCP and (not bTargetIsNick) then // CTCP to #
  begin
    if copy(strText, 1, 7) = 'ACTION ' then // /ME ...
    begin
      strText:=copy(strText, 8, maxint);
      ShowText(self.GetPageIDByName(strTarget), TimeTemplate()+' * '+strSender+' '+strText);
      Core.FlashMessage(self.GetPageIDByName(strTarget), strTarget, strSender+' '+StripIRCCodes(strText), false);
      Core.PlayNamedSound('sfxMeMsg', self);
      Exit;
    end
    else
    begin
      Core.AddNote(strSender, strText);
      ShowText(self.GetPageIDByName(strTarget), TimeTemplate()+#3+'03 '+Format(sSomeoneAddNote,[strSender]));
      ShowText(self.GetPageIDByName(strTarget), TimeTemplate()+'<'+#11+strSender+#11+'> '+strText);
      //LogMessage(TimeTemplate+'<'+#11+ReqData+#11+'> '+ReqData2, ReqData3, '');
      Core.FlashMessage(self.GetPageIDByName(strTarget), strTarget, StripIRCCodes(strText), false);
    end;
  end

  // === MSG to Nick ===
  else if (not bCTCP) and bTargetIsNick then // MSG to nick
  begin
    PageID:=GetPageIDByName('>'+strSender);
    //if (PageID < 0) and (MainConf.GetBool('PopupPrivate')) then
    if (PageID < 0) then
    begin
      PageID:=self.CreatePrivatePage(strSender);
    end;
    strPassw:=Core.PagesManager.GetPagePassword(PageID);
    if Length(Trim(strPassw))>0 then
      try
        DecryptText(strText, strPassw);
      except
      end;
    // Показ приватного сообщения
    Core.GrabNotesByKeywords(strSender, strText);
    Core.PlayNamedSound('sfxPvtMsg', self);

    // Если страница привата не найдена то приват отобразится на странице сервера
    ShowText(PageID, #3+'05'+TimeTemplate()+'<'+strSender+'> '+strText);
    Core.FlashMessage(PageID, strSender, StripIRCCodes(strText), true);
    // { TODO: смена значка у неактивной страницы }
    if self.IrcConf.FToolButtons.tbtnAway.Down then Exit;
    Core.ShowPrivateMsg(PageID, strSender, strText);
  end

  // === MSG to # ===
  else if (not bCTCP) and (not bTargetIsNick) then // MSG to #
  begin
    if IrcConf.GetStrings('IgnoreList').IndexOfName(strSender)>-1 then
    begin
      Exit;
    end;
    strPassw:=Core.PagesManager.GetPagePassword(self.GetPageIDByName(strTarget));
    if Length(Trim(strPassw))>0 then
      try
        DecryptText(strText, strPassw);
      except
      end;
    // Если это вдруг аватар..
    if Copy(Trim(strText),1,6)='AVATAR' then
    begin
      Core.DownloadAvatar(strSender, Copy(Trim(strText), 8, maxint));
      Exit;
    end;
    //
    Core.GrabNotesByKeywords(strSender, strText);
    PageID:=GetPageIDByName(strTarget);
    ShowText(PageID, TimeTemplate()+'<'+#11+strSender+#11+'> '+strText);
    Core.FlashMessage(PageID, strTarget, strSender+'> '+StripIRCCodes(strText), false);
    Core.PlayNamedSound('sfxChanMsg', self);
    // Simple bot
    if strSender <> FMyNick then
    begin
      for i:=0 to SimpleBotLines.Count-1 do
      begin
        if Pos(SimpleBotLines.Names[i], strText)>0 then
        begin
          Core.Say(SimpleBotLines.ValueFromIndex[i], PageID, False);
          Break;
        end;
      end;
    end;
  end;

end;

procedure TIrcClient.LocalEvent(sEvent: string);
var
  //i: integer;
  Cmd: string;
begin
  Cmd:=Trim(sEvent);
  Core.PluginsManager.BroadcastMsg('IRC '+Norm(self.FInfoConnection)+' '+Norm(sEvent));

  if Cmd = '' then Exit

  else if Cmd = 'KEEP_ALIVE' then
  begin
    self.SendTextToServer('PING '+IrcConf['ServerHost']+#10);
    //ShowText(self.FServerPageID, TimeTemplate()+#2+#3+'03 '+'Прошло '+IntToStr(KeepAlivePeriod div 1000)+' сек. Пингуем сервер..');
  end

  else if Cmd = 'SERV_TIMEOUT' then
  begin
    // реконнект
    if IrcConf.GetBool('AutoReconnect') then
    begin
      if not FActive then Connect();
    end
    else
    begin
      ShowText(self.FServerPageID,  TimeTemplate()+#2+#3+'5'+sIrcServerDataTimeout);
    end;
  end

  else if Cmd = 'DCC_TIMEOUT' then
  begin
    ShowText(self.FServerPageID, TimeTemplate()+#2+#3+'5'+sDccRequestTimeout);
    DCC_CheckAlive();
  end;

end;

procedure TIrcClient.OnApplySettings(Sender: TObject);
var
  pi: TPageInfo;
begin
  self.KeepAlivePeriod:=IrcConf.GetInteger('KeepAlivePeriod')*1000;
  self.ServerDataTimeout:=IrcConf.GetInteger('ServerDataTimeout')*1000;
  self.bSendUTF8:=IrcConf.GetBool('SendUTF8');
  self.bReceiveUTF8:=IrcConf.GetBool('ReceiveUTF8');
  self.ServerProxy:=IrcConf['ServerProxy'];
  self.FInfoConnection:='IRC '+IrcConf['ServerHost']+':'+IrcConf['ServerPort'];
  self.SimpleBotLines.Clear();
  if IrcConf.GetBool('SimpleBotEnabled') then self.SimpleBotLines.Text:=IrcConf['SimpleBot'];

  if self.FMyNick<>IrcConf['MyNick'] then
  begin
    if FActive then Core.Say('/NICK '+IrcConf['MyNick'], self.FServerPageID);
  end;

  if (self.FServerHost<>IrcConf['ServerHost']) or (self.FServerPort<>IrcConf['ServerPort']) then
  begin
    self.FServerHost := IrcConf['ServerHost'];
    self.FServerPort := IrcConf['ServerPort'];
    self.FInfoConnection:=self.FInfoProtocolName+' '+self.FServerHost+':'+self.FServerPort;
    if Core.PagesManager.GetPageInfo(self.FServerPageID, pi) then
    begin
      pi.Hint:=self.FInfoConnection;
      pi.Caption:=self.FServerHost;
      Core.PagesManager.SetPageInfo(pi);
    end;
    self.IrcConf.RootNode.FullName:=self.FInfoConnection;
    if FActive then Core.Say('/SERVER', self.FServerPageID);
  end;
end;

//==============================================
// Работа со списком каналов
function CompareChanNames(Item1, Item2: pointer): integer;
var
  P1, P2: PChanRec;
begin
  P1:=Item1;
  P2:=Item2;
  result:=CompareStr(P1^.ChanName, P2^.ChanName);
end;

function CompareChanUsers(Item1, Item2: pointer): integer;
var
  P1, P2: PChanRec;
begin
  P1:=Item1;
  P2:=Item2;
  result:=0;
  if P1^.ChanUsers>P2.ChanUsers then result:=-1;
  if P1^.ChanUsers<P2.ChanUsers then result:=1;
end;

function TChanList.Add(ChanRec: TChanRec): integer;
var
  P: PChanRec;
begin
  New(P);
  P^:=ChanRec;
  result:=inherited Add(P);
end;

function TChanList.AddRaw(RawChan: string): integer;
var
  ChanRec: TChanRec;
begin
  result:=0;
  if Trim(RawChan)='' then Exit;
  ChanRec.ChanName:=Copy(RawChan, 1, Pos(' ', RawChan)-1);
  RawChan:=Copy(RawChan, Pos(' ', RawChan)+1, maxint);
  ChanRec.ChanUsers:=StrToIntDef(Copy(RawChan, 1, Pos(' ', RawChan)-1),0);
  RawChan:=Copy(RawChan, Pos(' ', RawChan)+1, maxint);
  ChanRec.ChanDesc:=RawChan;
  result:=Add(ChanRec);
end;

procedure TChanList.Delete(Index: integer);
begin
  Dispose(Items[Index]);
  inherited Delete(Index);
end;

function TChanList.GetChanRec(Index: integer): TChanRec;
var
  P: PChanRec;
begin
  P:=Items[Index];
  Result:=P^;
end;

procedure TChanList.SetChanRec(Index: integer; Value: TChanRec);
begin
  Dispose(Items[Index]);
  Items[Index]:=@Value;
end;

procedure TChanList.Sort(SortMode: TChanSortModes);
begin
  if SortMode = SortByNames then inherited Sort(@CompareChanNames);
  if SortMode = SortByUsers then inherited Sort(@CompareChanUsers);
end;

function TChanList.GetChanRecByName(sChanName: string; var ChanRec: TChanRec): boolean;
var
  P: PChanRec;
  i: integer;
begin
  result:=false;
  for i:=0 to self.Count-1 do
  begin
    P:=Items[i];
    if P^.ChanName=sChanName then
    begin
      ChanRec:=P^;
      Result:=true;
      Exit;
    end;
  end;
end;

function TChanList.GetIndexByName(sChanName: string): integer;
var
  P: PChanRec;
  i: integer;
begin
  result:=-1;
  for i:=0 to self.Count-1 do
  begin
    P:=Items[i];
    if P^.ChanName=sChanName then
    begin
      Result:=i;
      Exit;
    end;
  end;
end;

destructor TChanList.Destroy;
begin
  While Count>0 do
  begin
    Delete(Count-1);
  end;
  inherited Destroy;
end;

//================================
function ReplaceOps(sNick: String): string;
var
  s: string;
begin
  s:='@+%&~';
  if Pos(sNick[1], s)>0 then Result:=Copy(sNick, 2, MaxInt) else Result:=sNick;
end;

function StripIRCCodes(sText: string): string;
var
  i, n: Integer;
  c: AnsiChar;
begin
  Result:='';
  i:=1;
  n:=0;
  while i<Length(sText) do
  begin
    c:=sText[i];
    Inc(i);
    case c of
      #2, #22, #31, #11:
      begin
        Continue;
      end;
      #3, #4:
      begin
        n:=1;
        Continue;
      end;
    end;
    if n>0 then
    begin
      if (c in ['0'..'9']) then Inc(n) else n:=0;
      if n>2 then n:=0;
      if n>0 then Continue;
    end;
    Result:=Result+c;
  end;
end;

procedure TIrcClient.RejoinChannel(sChan: string);
var
  PageID: integer;
begin
  PageID:=self.GetPageIDByName(sChan);
  flagHop:=true;
  Core.ModTimerEvent(1, PageID, 0, '/PART');
  Core.ModTimerEvent(1, PageID, 1000, '/JOIN '+sChan);
end;

procedure TIrcClient.OnLogin;
var
  i: integer;
  sl: TStringList;
begin
  if IrcConf.GetBool('NSAutoLogin') then self.IrcConf.frmIrcOptions.btnNickServ2.Click();
  sl:=IrcConf.GetStrings('AutojoinList');
  if not Assigned(sl) then Exit;
  for i:=0 to sl.Count-1 do
  begin
    Core.ModTimerEvent(1, self.FServerPageID, (i*200), sl[i]);
  end;
end;

procedure TIrcClient.OnJoin(sChanName: string);
var
  i: integer;
  sl: TStringList;
begin
  sl:=IrcConf.GetStrings('NotesList');
  if not Assigned(sl) then Exit;
  if not IrcConf.GetBool('ShowNotesOnJoin') then Exit;
  for i:=0 to sl.Count-1 do
  begin
    Core.ModTimerEvent(1, self.FServerPageID, (i*200), '/NOTICE '+sChanName+' '+sl[i]);
  end;
end;

procedure TIrcClient.ModifyIgnoreList(Action: integer; sText: string);
var
  i, n: integer;
  sNick, sMode, sTmp: string;
  sl: TStringList;

procedure AddToList(sName, sValue: string);
begin
  sTmp:=sValue;
  if n >= 0 then
  begin
    sTmp:=sl.Values[sName];
    if Pos(sValue, sTmp)=0 then sTmp:=sTmp+sValue;
  end;
  sl.Values[sName]:=sTmp;
end;

procedure RemoveFromList(sName, sValue: string);
begin
  if n < 0 then Exit;
  sTmp:=sl.Values[sName];
  if Pos(sValue, sTmp)=0 then Exit;
  sTmp:=StringReplace(sTmp, sValue, '', [rfReplaceAll]);
  sl.Values[sName]:=sTmp;
  //if sTmp='' then sl.Delete(n);
end;

begin
  i:=Pos(' ',sText);
  sMode:=UpperCase(Copy(sText, 1, i-1)); // mode
  sNick:=Copy(sText, i+1, maxint);   // Nick
  sl:=IrcConf.GetStrings('IgnoreList');
  sl.NameValueSeparator:='>';
  n:=sl.IndexOfName(sNick);

  if Action = 1 then
  begin
    if sMode = 'ALL' then
    begin
      AddToList(sNick, 'a');
    end
    else if sMode = 'PVT' then
    begin
      AddToList(sNick, 'p');
    end;
  end
  else if Action = -1 then
  begin
    if sMode = 'ALL' then
    begin
      RemoveFromList(sNick, 'a');
    end
    else if sMode = 'PVT' then
    begin
      RemoveFromList(sNick, 'p');
    end;
  end;
  IrcConf['IgnoreList']:=sl.Text;
end;

procedure TIrcClient.LoadLanguage();

procedure ReadIni(var s: string; Name: string);
begin
  s:=Core.LangIni.ReadString('IRC', Name, s);
end;

begin

  if not Assigned(Core.LangIni) then Exit;
  try
    //with IRC do     // IRC
    begin
      ReadIni(sConnConnect, 'sConnConnect');
      ReadIni(sConnError, 'sConnError');
      ReadIni(sConnDisconnected, 'sConnDisconnected');
      ReadIni(sConnOpenHost, 'sConnOpenHost');
      ReadIni(sConnOpenPort, 'sConnOpenPort');
      ReadIni(sIrcNotConnected, 'sIrcNotConnected');
      ReadIni(sIrcUncnownCommand, 'sIrcUncnownCommand');
      ReadIni(sIrcServerDataTimeout, 'sIrcServerDataTimeout');
      ReadIni(sDccRequestTimeout, 'sDccRequestTimeout');

      ReadIni(sIrcSocketConectError, 'sIrcSocketConectError');
      ReadIni(sIrcSocketGeneralError, 'sIrcSocketGeneralError');
      ReadIni(sIrcSocketSendError, 'sIrcSocketSendError');
      ReadIni(sIrcSocketReceiveError, 'sIrcSocketReceiveError');
      ReadIni(sIrcSocketOtherError, 'sIrcSocketOtherError');
      ReadIni(sIrcSocketLookup, 'sIrcSocketLookup');
      ReadIni(sIrcSocketConnecting, 'sIrcSocketConnecting');
      ReadIni(sIrcSocketConnect, 'sIrcSocketConnect');

      ReadIni(sUserInfoNick, 'sUserInfoNick');
      ReadIni(sUserInfoName, 'sUserInfoName');
      ReadIni(sUserInfoComp, 'sUserInfoComp');
      ReadIni(sUserInfoChan, 'sUserInfoChan');
      ReadIni(sUserInfoServ, 'sUserInfoServ');
      ReadIni(sUserInfoIdle, 'sUserInfoIdle');
      ReadIni(sUserInfoOnln, 'sUserInfoOnln');

      ReadIni(sIrcSoundChannelMessage, 'sIrcSoundChannelMessage');
      ReadIni(sIrcSoundPrivateMessage, 'sIrcSoundPrivateMessage');
      ReadIni(sIrcSoundMeMessage, 'sIrcSoundMeMessage');
      ReadIni(sIrcSoundNoticeMessage, 'sIrcSoundNoticeMessage');
      ReadIni(sIrcSoundDccChat, 'sIrcSoundDccChat');
      ReadIni(sIrcSoundDccFile, 'sIrcSoundDccFile');
      ReadIni(sIrcSoundServerConnect, 'sIrcSoundServerConnect');
      ReadIni(sIrcSoundServerDisconnect, 'sIrcSoundServerDisconnect');
      ReadIni(sIrcSoundJoinChannel, 'sIrcSoundJoinChannel');
      ReadIni(sIrcSoundLeaveChannel, 'sIrcSoundLeaveChannel');
      ReadIni(sIrcSoundErrorMessage, 'sIrcSoundErrorMessage');
      ReadIni(sIrcSoundOther, 'sIrcSoundOther');

      ReadIni(sComeToChannel, 'sComeToChannel');
      ReadIni(sLeaveChannel, 'sLeaveChannel');
      ReadIni(sUserSetMode, 'sUserSetMode');
      ReadIni(sMeSetMode, 'sMeSetMode');
      ReadIni(sKickedYou, 'sKickedYou');
      ReadIni(sKickedSomeone, 'sKickedSomeone');
      ReadIni(sChannelTopic, 'sChannelTopic');
      ReadIni(sSomeoneChangeTopic, 'sSomeoneChangeTopic');
      ReadIni(sTopicSetBy, 'sTopicSetBy');
      ReadIni(sChannelName, 'sChannelName');
      ReadIni(sChannelModes, 'sChannelModes');
      ReadIni(sNameInUse, 'sNameInUse');
      ReadIni(sMOTD, 'sMOTD');
      ReadIni(sMOTD2, 'sMOTD2');
      ReadIni(sSomeoneAskVersion, 'sSomeoneAskVersion');
      ReadIni(sSomeonePingMe, 'sSomeonePingMe');
      ReadIni(sSomeoneFingerMe, 'sSomeoneFingerMe');
      ReadIni(sSomeoneAddNote, 'sSomeoneAddNote');
      ReadIni(sYouCannotWriteToChannel, 'sYouCannotWriteToChannel');
      ReadIni(sYouCannotJoinChannel, 'sYouCannotJoinChannel');
      ReadIni(sPasswordSet, 'sPasswordSet');
      ReadIni(sLibeay32NotFound, 'sLibeay32NotFound');
      ReadIni(sPasswordUnset, 'sPasswordUnset');
      ReadIni(sSomeoneChangeNick, 'sSomeoneChangeNick');
      ReadIni(sSomeoneLeaveChat, 'sSomeoneLeaveChat');

      ReadIni(sChanListCaption, 'sChanListCaption');
      ReadIni(sChanListChanMask, 'sChanListChanMask');
      ReadIni(sChanListSortByNames, 'sChanListSortByNames');
      ReadIni(sChanListSortByUsers, 'sChanListSortByUsers');
      ReadIni(sChanListColChan, 'sChanListColChan');
      ReadIni(sChanListColUsers, 'sChanListColUsers');
      ReadIni(sChanListColTopic, 'sChanListColTopic');

      ReadIni(sTabMenuDisconnect, 'sTabMenuDisconnect');
      ReadIni(sTabMenuChanOptions, 'sTabMenuChanOptions');
      ReadIni(sTabMenuChanHop, 'sTabMenuChanHop');
    end;
  except
  end;
  IrcConf.frmIrcOptions.ChangeLanguage();
end;

end.
