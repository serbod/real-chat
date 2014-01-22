{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  Клиент Talaria.

}
unit Talaria;

interface
uses SysUtils, Misc, Core, Classes, Configs, Windows,
     TalariaOptions, Contnrs;

type
  // Структура, содержащая данные пользователя
  TTalariaUser = class(TObject)
  private
    function FGetBoardMsg(): string;
    procedure FSetBoardMsg(Msg: string);
  public
    ID: string;
    Nick: string;
    Login: string;
    Address: string;
    HelloMsg: string;
    StatusMsg: string;
    Version: string;
    Status: string;
    SilentTime: integer; // сколько секунд молчит
    MsgBoard: TStringList;
    property BoardMsg: string read FGetBoardMsg write FSetBoardMsg;
    constructor Create();
    destructor Destroy(); override;
  end;

  // Данные линии чата
  TTalariaChatLine = class(TObject)
  public
    Name: string;
    Password: string;
    PageID: integer;
    UsersCount: integer;
    UsersList: TObjectList;
    bActive: boolean;
    bPrivate: boolean;
  end;

  // Класс, реализующий функционал Talaria-клиента
  TTalariaClient = class(TChatClient)
  private
    DefaultServerPort: integer;
    bUseProxy: boolean;
    //bProxyConnected: boolean;
    FActive: boolean;
    bDebugInfo: boolean;
    FLocalAddress: string;
    sLocalHostName: string;
    sLocalLoginName: string;
    sMainLineName: string;
    sPrivateLineName: string;
    sBoardLineName: string;
    BoardPageID: integer;
    MainPageID: integer;
    //fsLog: TFileStream;
    fLog: Text;
    bLogAssigned: Boolean;
    iRefreshPeriod: integer; // период команды REFRESH в секундах
    iReplyTimeout: integer;  // таймаут ожидания ответов в секундах
    procedure DebugString(s: string);
    // Парсер сообщений с сервера (строка модифицируется!)
    procedure Interpret(var sData: string);
    procedure ParseData(strData: String; var parsed: TParsedData);
    procedure OnIChatMessage(parsed: TParsedData);
    // Процедуры для работы со списками пользователей и линий
    function GetLineByName(LineName: string; var ChatLine: TIChatLine): boolean;
    function GetUserByUserID(sUserID: string; var ChatUser: TIChatUser): boolean;
    function GetUserIDByNick(sNick: string): string;
    function GetNickByUserID(UserID: string): string;
    function CreateChatLine(sLineName: string; IsPrivate: boolean = false; sPassword: string = ''; sLineFullName: string = ''): boolean;
    function RemoveChatLine(sLineName: string): boolean;
    function AddUserToLine(sUserID, sLineName, sUserNick, sUserVersion, sUserStatus, sHelloMsg: string): boolean;
    function RemoveUserFromLine(sLineName, sUserID: string): boolean;
    function RenameUser(sUserID, sNewName: string): boolean;
    function ChangeUserStatus(sUserID, sNewStatus, sNewStatusMsg: string): boolean;
    procedure ShowUserInfo(sNick: string);
    procedure RefreshNames(LineID: string);
    procedure ResetUserTimer(UserID: string);
    // Набор процедур отправки разных видов стандартных сообщений
    procedure SendMsgConnect(sDest: string = ''; sLineName: string = '');
    procedure SendMsgDisconnect(sDest: string = ''; sLineName: string = '');
    procedure SendMsgRefresh(sDest: string = ''; sLineName: string = ''; sSender: string = '');
    procedure SendMsgRefreshReply(Parsed: TParsedData);
    procedure SendMsgStatus(sDest: string = '');
    procedure SendMsgStatusReq(sDest: string = '');
    procedure SendMsgBoard(sDest: string = '');
    procedure SendMsgBoardReq(sDest: string = '');
    procedure SendMsgRename(sDest: string = '');
    procedure SendMsgReceived(sDest: string = ''; sLineName: string = ''; sReply: string = '');
    procedure SendMsgText(sDest: string = ''; sLineName: string = ''; sText: string = ''; sNick: string = '');
    procedure SendMsgMe(sDest: string = ''; sLineName: string = ''; sText: string = '');
    procedure SendMsgCreate(sDest: string = ''; sLineID: string = ''; sReceiverID: string = '');
    // Процедура для работы с доской объявлений
    procedure AddBoardMsg(sNick, sMsg, sMsgNum: string);
    procedure RefreshBoard();
    // Обработчик локальных событий
    procedure LocalEvent(sEvent: string);
    procedure OnConnect();
    // Обработчик принятия изменений в конфиге
    procedure OnApplySettings(Sender: TObject);
  public
    ServerHost: string;
    ServerPort: string;
    ServerProxy: string;
    Myself: TIChatUser;
    Conf: TTalariaConf;
    constructor Create(ConfFileName: string); override;
    destructor Destroy(); override;
    function Connect(): boolean; override;
    function Disconnect(): boolean; override;
    property Active: boolean read FActive;
    // Return empty string if message processed succesfully
    function SendTextFromPage(PageInfo: TPageInfo; sText: string): string; override;
    // Send string directly to server
    function SendTextToServer(sText: string): boolean; override;
    //procedure SendDataToServer(sData: array of char; Len: integer);
    procedure SendMessageToServer(asData: array of string);
    // Show some text on chat page with specified ID
    //function ShowText(PageID: integer; sText: string): boolean;
    // Вызывается при закрытии страницы
    function ClosePage(PageID: integer): boolean; override;
    function GetConf(): TConf; override;
    // Получить список кнопок для общей панели инструментов
    function GetMainToolButtons(PageID: integer): TObjectList; override;
    procedure LoadLanguage(); override;
  protected
    procedure Event(EventText: string);
  end;

const
  ciIconNormal = 20; // Normal user
  ciIconBanned = 21; // Banned user
  ciIconAway   = 22; // User away

  ciIconTalaria  = 8; // IRC icon

var
  sConnConnect:string = 'Соединение установлено. Идентификация.';
  sConnError:string = 'Ошибка соединения:';
  sConnDisconnected:string = 'Отсоединение.';
  sConnOpenHost:string = 'Соединяемся с';
  sConnOpenPort:string = 'порт';

  {sSocketConectError:string = 'Не удалось подключиться к серверу.';
  sSocketGeneralError:string = 'Ошибка соединения.';
  sSocketSendError:string = 'Не удалось отправить данные на сервер.';
  sSocketReceiveError:string = 'Не удалось принять данные с сервера.';
  sSocketOtherError:string = 'Ошибка сокета.';
  sSocketLookup:string = 'Определяем адрес сервера.';
  sSocketConnecting:string = 'Подключаемся к серверу.';
  sSocketConnect:string = 'Подключились к серверу.';}

  sIChatNotConnected: string = 'Сперва нужно подключиться к серверу';
  sIChatServerDataTimeout: string = 'Что-то долго нет данных от сервера. Связь в порядке?';
  sIChatDefaultHelloMsg: string = 'Это тест. Не обращайте внимания..';
  sIChatDefaultStatusMsg: string = 'Принято.';
  sIChatBoardName: string = 'Объявления';
  sIChatConnect1: string = 'зашел на линию и сказал:';
  sIChatConnect: string = 'Появляется';
  sIChatCreateLine: string = 'создает новую линию';
  sIChatCreateLinePassw: string = 'создает новую линию c паролем';
  sIChatCreate: string = 'создает приватную линию';
  sIChatDisconnect: string = 'уходит с линии';
  sIChatRename: string = 'изменяет имя на';
  sIChatStatus: string = 'меняет статус на';
  sIChatReceivedReply: string = 'получил сообщение';
  //sIChat: string = '';
  //sIChat: string = '';
  //sIChat: string = '';

  sIChatSoundChannelMessage: string = 'Сообщение на канал';
  sIChatSoundPrivateMessage: string = 'Приватное сообщение';
  sIChatSoundMeMessage: string = 'Сообщение /ME';
  //sIChatSoundNoticeMessage: string = 'Сообщение /NOTICE';
  //sIChatSoundDccChat: string = 'Входящий DCC чат';
  //sIChatSoundDccFile: string = 'Входящий DCC файл';
  sIChatSoundServerConnect: string = 'Подключение к серверу';
  sIChatSoundServerDisconnect: string = 'Отключение от сервера';
  sIChatSoundJoinChannel: string = 'Заход на канал';
  sIChatSoundLeaveChannel: string = 'Уход с канала';
  sIChatSoundErrorMessage: string = 'Сообщение об ощибке';
  sIChatSoundOther: string = 'Прочее';

  sUserInfoNick: string = 'Имя';
  sUserInfoID: string = 'Хост';
  sUserInfoVersion: string = 'Версия';
  sUserInfoStatus: string = 'Статус';
  sUserInfoHelloMsg: string = 'Приветствие';

implementation

function GetRandomNumStr(): string;
var
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(Now, Hour, Min, Sec, MSec);
  result:=''+IntToStr(Hour)+IntToStr(Min)+IntToStr(Sec)+IntToStr(MSec);
end;

// ===== TTalariaClient =====
constructor TTalariaClient.Create(ConfFileName: string);
var
  i: integer;
  Key: array [0..16] of Char;
  PageInfo: TPageInfo;
begin
  inherited Create(ConfFileName);
  self.Conf:=TTalariaConf.Create(self, ConfFileName);
  self.Conf.OnApplySettings:=OnApplySettings;
  self.LoadLanguage();

  self.PagesIDCount:=0;
  SetLength(self.PagesIDList, self.PagesIDCount);

  ChatUsers:=TObjectList.Create(true);
  ChatLines:=TObjectList.Create(true);

  self.FInfoAbout:='Talaria protocol version 0.1';
  self.FInfoProtocolID:=ciIconTalaria;
  self.FInfoProtocolName:='Talaria';
  self.ServerHost:=Conf['ServerHost'];
  self.ServerPort:=Conf['ServerPort'];
  self.FInfoConnection:=self.FInfoProtocolName+' '+self.ServerHost+':'+self.ServerPort;
  self.Conf.RootNode.FullName:=self.FInfoConnection;

  bDebugInfo:=Conf.GetBool('DebugMessages');
  bLogAssigned:=False;

  self.DefaultServerPort := 4044;
  sLocalHostName:=Conf['HostName'];
  if sLocalHostName='' then sLocalHostName:=GetWinCompName();
  sLocalLoginName:=Conf['UserName'];
  if sLocalLoginName='' then sLocalLoginName:=GetWinUserName();
  //sLocalLoginName:='test_login';
  sMainLineName:='Main';
  sPrivateLineName:='Private';
  sBoardLineName:='Msg_Board';
  MsgCounter:=0;
  BoardPageID:=-1;
  MainPageID:=-1;

  Myself:=TTalariaChatUser.Create();
  Myself.Nick:=Conf['MyNick'];
  Myself.Version:='irchat';
  Myself.Status:='0';
  Myself.StatusMsg:=sIChatDefaultStatusMsg;
  Myself.HelloMsg:=sIChatDefaultHelloMsg;
  Myself.BoardMsg:=Conf['NotesList'];
  ChatUsers.Add(Myself);

  FActive := false;
  bUseProxy := false;
  //bProxyConnected := false;
  //bSendUTF8 := false;
  self.OnApplySettings(nil);

  // Создаем главную страницу
  self.CreateChatLine(sMainLineName, false, '', 'Main');

  // Создаем страницу объявлений
  Core.ClearPageInfo(PageInfo);
  PageInfo.Caption:=sIChatBoardName;
  PageInfo.PageType:=ciChatPageType;
  PageInfo.ImageIndex:=self.FInfoProtocolID;
  PageInfo.ImageIndexDefault:=self.FInfoProtocolID;
  self.BoardPageID:=PagesManager.CreatePage(PageInfo);
  self.ModifyPagesList(self.BoardPageID, 1);

  if Conf.GetBool('AutoConnect') then Core.ModTimerEvent(1, MainPageID, 200, '/SERVER');
end;

destructor TTalariaClient.Destroy();
begin
  Disconnect();

  ChatLines.Free();
  ChatUsers.Free();

  // Убираем доску объявлений
  Core.PagesManager.RemovePage(self.BoardPageID);
  // Убираем main
  Core.PagesManager.RemovePage(self.MainPageID);

  //fsLog.Free();
  if bLogAssigned then CloseFile(fLog);

  inherited Destroy();
end;

procedure TTalariaClient.DebugString(s: string);
var
  fn: string;
begin
  if not bDebugInfo then Exit;
  if not bLogAssigned then
  begin
    // Создаем лог-файл
    //fn:=glUserPath+MainConf['LogsPath']+'\iChat '+self.ServerHost+' debug.txt';
    fn:=glUserPath+'iChat '+self.ServerHost+' debug.txt';
    try
      AssignFile(fLog, fn);
      if FileExists(fn) then Append(fLog) else Rewrite(fLog);

      {if FileExists(fn) then
        //fsLog:=TFileStream.Create(fn, fmOpenReadWrite, fmShareDenyWrite)
      else
        fsLog:=TFileStream.Create(fn, fmCreate);
      fsLog.Position:=fsLog.Size;}
      bLogAssigned:=True;
    except
      bDebugInfo:=False;
      Exit;
    end;

  end;
  WriteLn(fLog, s);
  //Core.DebugMessage(s);
  //Exit;
  {if Assigned(fsLog) then
  begin
    s:=s+#13+#10;
    fsLog.Write(PChar(s)^, Length(s));
  end;}
end;

function TTalariaClient.Connect(): boolean;
var
  pHost, pPort: string;
begin
  result:=false;
  if Assigned(Socket) then Socket.Free();
  self.ServerHost:=Conf['ServerHost'];
  self.ServerPort:=Conf['ServerPort'];
  self.bUseMailslots:=(Trim(self.ServerHost)='');
  self.FInfoConnection:=self.FInfoProtocolName+' '+self.ServerHost+':'+self.ServerPort;
  if self.bUseMailslots then self.FInfoConnection:='Mailslots';
  self.Conf.RootNode.FullName:=self.FInfoConnection;

  if self.bUseMailslots then
  begin
    MailslotThread:=TMailslotThread.Create(sMailslotName);

    MailslotThread.OnMailslotEvent := self.OnMailslotRead;
    MailslotThread.OnMailslotError := self.OnMailslotError;
    MailslotThread.Resume();

    OnConnect();
    result:=true;
    Exit;
  end;

  self.Socket := TAsyncSock.Create();
  self.Socket.OnSocketEvent := self.OnSocketEvent;
  self.Socket.OnErrorEvent := self.OnSocketErrorEvent;

  bUseProxy:=true;
  //bProxyConnected:=false;
  if Trim(self.ServerProxy)='' then bUseProxy:=false;

  if bUseProxy then
  begin
    Event('iChat DebugMessage '+sConnOpenHost+' '+#2+self.ServerHost+#2+' '+sConnOpenPort+' '+self.ServerPort+' (proxy: '+self.ServerProxy+')');

    pPort:='3128';
    pHost:=self.ServerProxy;
    if Pos(':',pHost)>=0 then
    begin
      pHost:=Copy(self.ServerProxy, 1, Pos(':',self.ServerProxy)-1);
      pPort:=Copy(self.ServerProxy, Pos(':',self.ServerProxy)+1, maxint);
    end;

    self.Socket.SetProxy(Conf['ProxyType'], pHost, pPort, Conf['ProxyUser'], Conf['ProxyPass']);
    {try
      self.Socket.Open(pHost, '', '', StrToIntDef(pPort, 3128), false);
      result:=true;
    except
      Self.Event('iChat SocketConnectError '+sSocketConectError{+' '+GetSocketErrorDescription(ErrorCode));
    end;
    Exit;}
  end;

  Event('iChat DebugMessage '+sConnOpenHost+' '+#2+self.ServerHost+#2+' '+sConnOpenPort+' '+self.ServerPort);
  try
    self.Socket.Open(self.ServerHost, self.ServerPort);
    result:=true;
  except
    Self.Event('iChat SocketConnectError '+sSocketConnectError{+' '+GetSocketErrorDescription(ErrorCode)});
  end;
end;

function TTalariaClient.Disconnect(): boolean;
var
  i: integer;
  ChatLine: TIChatLine;
begin
  result:=false;
  Core.ModTimerEvent(-1, MainPageID, 0, '');
  Conf.FToolButtons.tbtnConnect.Down:=false;
  Conf.FToolButtons.tbtnConnect.Caption:='/CONNECT';
  Conf.FToolButtons.tbtnOnline.Down:=false;
  Conf.FToolButtons.tbtnAway.Down:=false;
  self.ShowText(MainPageID, TimeTemplate()+#2+#3+'04 '+sConnDisconnected);

  if not FActive then Exit;
  for i:=self.ChatLines.Count-1 downto 0 do
  begin
    ChatLine:=TIChatLine(self.ChatLines[i]);
    SendMsgDisconnect('*', ChatLine.Name);
    self.RemoveChatLine(ChatLine.Name);
  end;

  if self.bUseMailslots then
  begin
    //while Assigned(MailslotThread) do
    self.MailslotThread.Terminate();
  end
  else
  begin
    Socket.Close();
    //Socket.Free();
  end;
  self.FActive := false;
  Core.PlayNamedSound('sfxDisconnect', self);
  result:=true;
end;

procedure TTalariaClient.OnSocketEvent(Sender: TObject; ASocket: TTCPBlockSocket; SocketEvent: TSocketEvent);
begin
  case SocketEvent of
  seLookup:
    begin
      //Self.Event(irceSocketEvent, sIrcSocketLookup);
    end;
  seConnecting:
    begin
      //Self.Event(irceSocketEvent, sIrcSocketConnecting);
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
      //Self.Event('irceSocketEvent '+sSocketOtherEvent);
      //FActive := Socket.Connected;
    end;
  end;
end;

procedure TTalariaClient.OnSocketErrorEvent(Sender: TObject; ASocket: TTCPBlockSocket; ErrorEvent: TErrorEvent; ErrorMsg: string);
begin
  case ErrorEvent of
  eeGeneral:
    begin
      //Self.Event(irceSocketError, sIrcSocketGeneralError+' '+GetSocketErrorDescription(ErrorCode));
    end;
  eeSend:
    begin
      //Self.Event(irceSocketError, sIrcSocketSendError+' '+GetSocketErrorDescription(ErrorCode));
    end;
  eeReceive:
    begin
      //Self.Event(irceSocketError, sIrcSocketReceiveError+' '+GetSocketErrorDescription(ErrorCode));
    end;
  eeConnect:
    begin
      //Self.Event(irceSocketConnectError, sIrcSocketConectError+' '+GetSocketErrorDescription(ErrorCode));
    end;
  else
    begin
      //Self.Event(irceSocketError, sIrcSocketOtherError+' '+GetSocketErrorDescription(ErrorCode));
    end;
  end;
  // Закрыть соединение, чтобы не выпадать в рекурсию
  FActive:=false;
  if self.bUseMailslots then
  begin
    self.MailslotThread.Free();
  end
  else
  begin
    self.Socket.Close();
  end;
  self.Disconnect();
end;

procedure TTalariaClient.OnSocketConnect(Sender: TObject; ASocket: TTCPBlockSocket);
begin
  FLocalAddress := Socket.LocalAddress;
  {if bUseProxy and (not bProxyConnected) then
  begin
    //SendTextToServer('CONNECT '+self.ServerHost+':'+self.ServerPort+' HTTP/1.0'+#13+#10+#13+#10);
    Exit;
  end; }
  Self.Event('iChat SocketConnected '+#3+'03'+sConnConnect);
  OnConnect();
end;

procedure TTalariaClient.OnConnect();
var
  i: integer;
begin
  FActive := true;
  if bUseMailslots then Myself.ID:=self.sLocalHostName
  else self.Myself.ID:=self.FLocalAddress+'/'+self.sLocalHostName+'/'+self.sLocalLoginName;

  Conf.FToolButtons.tbtnConnect.Down:=true;
  Conf.FToolButtons.tbtnConnect.Caption:='/DISCONNECT';
  Conf.FToolButtons.tbtnOnline.Down:=true;
  Conf.FToolButtons.tbtnAway.Down:=false;

  // Send disconnect message
  SendMsgDisconnect();

  // send connect message
  SendMsgConnect();

  Core.PlayNamedSound('sfxConnect', self);

  // Start REFRESH pinger
  i:=Conf.GetInteger('RefreshPeriod')*1000;
  if i>0 then Core.ModTimerEvent(0, MainPageID, i, '/* REFRESH');
end;

// =======================================
{procedure TIChatClient.SendDataToServer(sData: array of char; Len: integer);
var
  F: File;
  Count: integer;
begin
  if self.bUseMailslots then
  begin
    Count:=0;
    AssignFile(F, '\\.\mailslot\'+sMailslotName);
    Reset(F);
    BlockWrite(F, sData, Len, Count);
    CloseFile(F);
    Exit;
  end;
  Socket.SendBuf(sData, Len);
end;}

procedure TTalariaClient.OnMailslotRead(Sender: TObject; sData: array of char; Len: integer);
var
  Parsed: TParsedData;
  i: integer;
  s: string;
begin
  for i:=0 to Len do s:=s+sData[i];
  //Interpret(s);
  Parsed.bFromClient := true;
  ParseData(s, Parsed);
  OnIChatMessage(Parsed);
end;

procedure TTalariaClient.OnMailslotError(Sender: TObject; sError: string);
begin
  self.Event('iChat MailslotError: '+sError);
  self.Disconnect();
end;

procedure TTalariaClient.OnSocketRead(Sender: TObject; ASocket: TTCPBlockSocket);
var
  i, n: integer;
  RecvBuf: array [0..2048] of char;
begin
  while Socket.ReceiveLength > 0 do
  begin
    n:=Socket.ReceiveBuf(RecvBuf, SizeOf(RecvBuf));
    for i:=0 to n-1 do sBuf:=sBuf + RecvBuf[i];
  end;
  {if bUseProxy and (not bProxyConnected) then
  begin
    // !!!
    Exit;
  end; }
  Interpret(sBuf);
end;

procedure TTalariaClient.Interpret(var sData: string);
{ Получаем строку, которая может содержать несколько сообщений,
 а может содержать только часть сообщения. Обработаные сообщения "отрезаем". }
var
  Parsed: TParsedData;
  sMsg: string;
  sMsgLen: string;
  i,n: integer;
begin
  // Получим длину сообщения
  i:=1;
  while i>0 do
  begin
    i:=Pos(#0, sData);
    if i<=0 then Exit;
    sMsgLen:=Copy(sData, 1, i-1);
    n:=StrToIntDef(sMsgLen, 0);
    if n=0 then
    begin
      sData:='';
      Exit;
    end;

    sMsg:=Copy(sData, 1, n+i);
    Parsed.bFromClient := false;
    ParseData(sMsg, Parsed);
    OnIChatMessage(Parsed);

    Delete(sData, 1, n+Length(sMsgLen)+1);
  end;
end;

procedure TTalariaClient.Event(EventText: string);
begin
  Core.DebugMessage(EventText);
  if Assigned(FIChatEvent) then FIChatEvent(Self, EventText);
end;

procedure TTalariaClient.SendMessageToServer(asData: array of string);
var
  i, n: integer;
  DataCount: integer;
  sMsgAll, sMsg: string;
  sSep: string;
begin
  if not FActive then Exit;
  sSep:=#19+#19;
  Inc(MsgCounter);
  DataCount:=Length(asData);
  if DataCount < 2 then Exit;
  sMsgAll:=#0+Myself.ID+#0+'FORWARD'+#0+asData[0]+#0;
  sMsg:=#19+'iChat'+#19+#19+IntToStr(MsgCounter)+#19+#19+Myself.ID+#19+#19;
  for i:=1 to DataCount-1 do
  begin
    if i>1 then sMsg:=sMsg+#19+#19;
    sMsg:=sMsg+asData[i];
  end;
  sMsg:=sMsg+#19;
  n:=Length(sMsg);
  DebugString('> '+IntToStr(Length(sMsgAll)+n-1)+sMsgAll+sMsg);

  RC4Reset(RC4KeyData);
  RC4Crypt(RC4KeyData, PChar(sMsg), PChar(sMsg), n);

  if self.bUseMailslots then
  begin
    SendTextToServer(sMsg);
  end
  else
  begin
    sMsgAll:=IntToStr(Length(sMsgAll)+n-1)+sMsgAll+sMsg;
    SendTextToServer(sMsgAll);
  end;
end;

function TTalariaClient.SendTextToServer(sText: string): boolean;
var
  n: integer;
  h: THandle;
  BytesWrite: dword;
  sText2: string;
  //msg: string[255];
begin
  result:=true;
  if Conf.GetBool('LocalEcho') then
  begin
    sText2:=sText;
    Interpret(sText2);
  end;
  n:=Length(sText);
  if self.bUseMailslots then
  begin
    h:=CreateFile(PChar('\\*\mailslot\'+sMailslotName), GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_ALWAYS, 0, 0);
    if h=INVALID_HANDLE_VALUE then
    begin
      //raise Exception.Create('Error create mailslot: '+GetSysErrorDescription(GetLastError));
      Exit;
    end;
    //msg:=sText;
    if not WriteFile(h, PChar(sText)^, Length(sText)+1, DWORD(BytesWrite), nil) then
    begin
      //raise Exception.Create('Error write mailslot: '+GetSysErrorDescription(GetLastError));
    end;
    CloseHandle(h);
    Exit;
  end
  else
  begin
    if Assigned(Socket) then
    begin
      if Socket.Connected then Socket.SendBuf(PChar(sText)^, n);
    end;
  end;
end;

function TTalariaClient.GetConf(): TConf;
begin
  Result:=self.Conf;
end;

function TTalariaClient.ClosePage(PageID: integer): boolean;
var
  i: integer;
  sLineName: string;
begin
  result:=false;
  if (PageID=self.MainPageID)
  or (PageID=self.BoardPageID) then Exit;

  Core.Say('/PART', PageID);
  result:=true;
  {sLineName:='';
  for i:=ChatLines.Count-1 downto 0 do
  begin
    if TIChatLine(ChatLines[i]).PageID=PageID then
    begin
      sLineName:=TIChatLine(ChatLines[i]).Name;
      Break;
    end;
  end;
  if sLineName <> '' then
  begin
    RemoveChatLine(sLineName);
  end;
  Core.PagesManager.RemovePage(PageID); }
end;

{function ShowText(PageID: integer; sText: string): boolean;
begin
end;}

// ================================
// ===== Send messages procedures
// ================================
procedure TTalariaClient.SendMsgConnect(sDest: string = ''; sLineName: string = '');
var
  saMessage: array of string;
begin
  // send connect message
  if sLineName = '' then sLineName:=self.sMainLineName;
  if sDest = '' then sDest:='*';
  SetLength(saMessage, 10);
  saMessage[0]:=sDest;
  saMessage[1]:='CONNECT';
  saMessage[2]:=sLineName;
  saMessage[3]:=self.sLocalLoginName;
  saMessage[4]:=Myself.Nick;
  saMessage[5]:='';
  saMessage[6]:=Myself.HelloMsg;
  saMessage[7]:=sDest;
  saMessage[8]:=Myself.Version;
  saMessage[9]:=Myself.Status;

  self.SendMessageToServer(saMessage);
end;

procedure TTalariaClient.SendMsgDisconnect(sDest: string = ''; sLineName: string = '');
var
  saMessage: array of string;
begin
  // send connect message
  if sLineName = '' then sLineName:=self.sMainLineName;
  if sDest = '' then sDest:='*';
  SetLength(saMessage, 3);
  saMessage[0]:=sDest;
  saMessage[1]:='DISCONNECT';
  saMessage[2]:=sLineName;
  self.SendMessageToServer(saMessage);
end;

procedure TTalariaClient.SendMsgRefresh(sDest: string = ''; sLineName: string = ''; sSender: string = '');
var
  saMessage: array of string;
begin
  // send connect message
  if sLineName = '' then sLineName:=self.sMainLineName;
  if sDest = '' then sDest:='*';
  if sSender = '' then sSender:='*';
  SetLength(saMessage, 10);
  saMessage[0]:=sDest;
  saMessage[1]:='REFRESH';
  saMessage[2]:=sLineName;
  saMessage[3]:=self.sLocalLoginName;
  saMessage[4]:=Myself.Nick;
  saMessage[5]:='';
  saMessage[6]:=Myself.HelloMsg;
  saMessage[7]:=sSender;
  saMessage[8]:=Myself.Version;
  saMessage[9]:=Myself.Status;

  self.SendMessageToServer(saMessage);
end;

procedure TTalariaClient.SendMsgRefreshReply(Parsed: TParsedData);
//var
//  saMessage: array of string;
begin
  {// send Refresh reply
  SetLength(saMessage, 10);
  saMessage[0]:=Parsed.sMsgSender;
  saMessage[1]:='REFRESH';
  saMessage[2]:=Parsed.MsgParams[0];    // Line name
  saMessage[3]:=self.sLocalLoginName;   // Login
  saMessage[4]:=self.FMyNick;           // Nick
  saMessage[5]:='';
  saMessage[6]:=Parsed.MsgParams[4];
  saMessage[7]:=Parsed.sMsgSender;
  saMessage[8]:=Parsed.MsgParams[6];
  saMessage[9]:=Parsed.MsgParams[7];

  self.SendMessageToServer(saMessage);}
end;

procedure TTalariaClient.SendMsgStatus(sDest: string = '');
var
  saMessage: array of string;
begin
  // send status message
  if sDest = '' then sDest:='*';
  SetLength(saMessage, 4);
  saMessage[0]:=sDest;
  saMessage[1]:='STATUS';
  saMessage[2]:=Myself.Status;
  saMessage[3]:=Myself.HelloMsg;
  self.SendMessageToServer(saMessage);
end;

procedure TTalariaClient.SendMsgStatusReq(sDest: string = '');
var
  saMessage: array of string;
begin
  // send status message
  if sDest = '' then sDest:='*';
  SetLength(saMessage, 2);
  saMessage[0]:=sDest;
  saMessage[1]:='STATUS_REQ';
  self.SendMessageToServer(saMessage);
end;

procedure TTalariaClient.SendMsgBoard(sDest: string = '');
var
  saMessage: array of string;
begin
  // send board message
  if not Conf.GetBool('PostMyBoardNotes') then Exit;
  if sDest = '' then sDest:='*';
  SetLength(saMessage, 4);
  saMessage[0]:=sDest;
  saMessage[1]:='BOARD';
  saMessage[2]:='0';
  saMessage[3]:=Myself.BoardMsg;
  self.SendMessageToServer(saMessage);
end;

procedure TTalariaClient.SendMsgBoardReq(sDest: string = '');
var
  saMessage: array of string;
begin
  // send refresh board request
  if sDest = '' then sDest:='*';
  SetLength(saMessage, 4);
  saMessage[0]:=sDest;
  saMessage[1]:='REFRESH_BOARD';
  self.SendMessageToServer(saMessage);
end;

procedure TTalariaClient.SendMsgRename(sDest: string = '');
var
  saMessage: array of string;
begin
  // send status message
  if sDest = '' then sDest:='*';
  SetLength(saMessage, 3);
  saMessage[0]:=sDest;
  saMessage[1]:='RENAME';
  saMessage[2]:=self.Myself.Nick;
  self.SendMessageToServer(saMessage);
end;

procedure TTalariaClient.SendMsgText(sDest: string = ''; sLineName: string = ''; sText: string = ''; sNick: string = '');
var
  saMessage: array of string;
begin
  // send TEXT message
  if sDest = '' then sDest:='*';
  //if sNick = '' then sNick:='*';
  if sLineName = '' then sLineName:=self.sMainLineName;
  SetLength(saMessage, 5);
  saMessage[0]:=sDest;
  saMessage[1]:='TEXT';
  saMessage[2]:=sLineName;
  saMessage[3]:=sText;
  saMessage[4]:=sNick;
  self.SendMessageToServer(saMessage);
end;

procedure TTalariaClient.SendMsgReceived(sDest: string = ''; sLineName: string = ''; sReply: string = '');
var
  saMessage: array of string;
begin
  // send RECEIVED message
  if sDest = '' then sDest:='*';
  if sReply = '' then sReply:=Myself.StatusMsg;
  if sLineName = '' then sLineName:=self.sMainLineName;
  SetLength(saMessage, 4);
  saMessage[0]:=sDest;
  saMessage[1]:='RECEIVED';
  saMessage[2]:=sLineName;
  saMessage[3]:=sReply;
  self.SendMessageToServer(saMessage);
end;

procedure TTalariaClient.SendMsgMe(sDest: string = ''; sLineName: string = ''; sText: string = '');
var
  saMessage: array of string;
begin
  // send ME message
  if sDest = '' then sDest:='*';
  if sText = '' then sText:=Myself.StatusMsg;
  if sLineName = '' then sLineName:=self.sMainLineName;
  SetLength(saMessage, 4);
  saMessage[0]:=sDest;
  saMessage[1]:='ME';
  saMessage[2]:=sText;
  saMessage[3]:=sLineName;
  saMessage[4]:=sDest;
  self.SendMessageToServer(saMessage);
end;

procedure TTalariaClient.SendMsgCreate(sDest: string = ''; sLineID: string = ''; sReceiverID: string = '');
var
  saMessage: array of string;
begin
  //if sLineName = '' then sLineName:=self.sMainLineName;
  if sDest = '' then sDest:='*';
  SetLength(saMessage, 5);
  saMessage[0]:=sDest;
  saMessage[1]:='CREATE';
  saMessage[2]:=sLineID;
  saMessage[3]:='';
  saMessage[4]:=sReceiverID;
  self.SendMessageToServer(saMessage);
end;

// ================================
// ===== Chat lines functions
// ================================
function TTalariaClient.GetLineByName(LineName: string; var ChatLine: TIChatLine): boolean;
var
  i: integer;
begin
  result:=false;
  for i:=0 to self.ChatLines.Count-1 do
  begin
    if TIChatLine(self.ChatLines[i]).Name = LineName then
    begin
      ChatLine:=TIChatLine(self.ChatLines[i]);
      result:=true;
      Exit;
    end;
  end;
end;

function TTalariaClient.GetUserByUserID(sUserID: string; var ChatUser: TIChatUser): boolean;
var
  i: integer;
begin
  result:=false;
  for i:=0 to self.ChatUsers.Count-1 do
  begin
    if TIChatUser(self.ChatUsers[i]).ID = sUserID then
    begin
      ChatUser:=TIChatUser(self.ChatUsers[i]);
      result:=true;
      Exit;
    end;
  end;
end;

function TTalariaClient.GetUserIDByNick(sNick: string): string;
var
  i: integer;
begin
  result:='';
  for i:=0 to self.ChatUsers.Count-1 do
  begin
    if TIChatUser(self.ChatUsers[i]).Nick = sNick then
    begin
      result:=TIChatUser(self.ChatUsers[i]).ID;
      Exit;
    end;
  end;
end;

function TTalariaClient.GetNickByUserID(UserID: string): string;
var
  i: integer;
begin
  result:='';
  for i:=0 to self.ChatUsers.Count-1 do
  begin
    if TIChatUser(self.ChatUsers[i]).ID = UserID then
    begin
      result:=TIChatUser(self.ChatUsers[i]).Nick;
      Exit;
    end;
  end;
end;

function TTalariaClient.CreateChatLine(sLineName: string; IsPrivate: boolean = false; sPassword: string = ''; sLineFullName: string = ''): boolean;
var
  NewLine: TIChatLine;
  NewPageInfo: TPageInfo;
  PageID: integer;
begin
  result := false;
  if GetLineByName(sLineName, NewLine) then Exit;
  if sLineFullName='' then sLineFullName:=sLineName;
  //Inc(ChatLinesCount);
  //SetLength(ChatLines, ChatLinesCount);
  NewLine:=TIChatLine.Create();
  NewLine.Name := sLineName;
  NewLine.Password := sPassword;
  NewLine.UsersList:=TObjectList.Create(false);
  //NewLine.UsersCount := 0;
  //SetLength(NewLine.UsersList, NewLine.UsersCount);
  NewLine.bActive := true;
  NewLine.bPrivate := IsPrivate;

  Core.ClearPageInfo(NewPageInfo);
  NewPageInfo.sChan := sLineName;
  NewPageInfo.sPassword := sPassword;
  NewPageInfo.Caption := sLineFullName;
  NewPageInfo.PageType:=ciChatPageType;
  NewPageInfo.bUseStateImages := MainConf.GetBool('UserlistCheckboxes');
  NewPageInfo.ImageIndex:=self.FInfoProtocolID;
  NewPageInfo.ImageIndexDefault:=self.FInfoProtocolID;
  if IsPrivate then NewPageInfo.sMode:='PVT';
  PageID:=PagesManager.CreatePage(NewPageInfo);
  if self.BoardPageID >=0 then Core.PagesManager.MovePage(PageID, self.BoardPageID);
  self.ModifyPagesList(PageID, 1);

  NewLine.PageID:=PageID;
  self.ChatLines.Add(NewLine);

  if sLineName = self.sMainLineName then self.MainPageID:=PageID;

  result := true;
end;

function TTalariaClient.RemoveChatLine(sLineName: string): boolean;
var
  i, n: integer;
  ChatLine: TIChatLine;
begin
  result := false;
  for i:=self.ChatLines.Count-1 downto 0 do
  begin
    ChatLine:=TIChatLine(self.ChatLines[i]);
    if ChatLine.Name = sLineName then
    begin
      if sLineName=self.sMainLineName then
      begin
        // clear userlist
        ChatLine.UsersList.Clear();
        Core.RemoveNick(ChatLine.PageID, '', true);
        Exit;
      end;
      // remove chat page
      Core.PagesManager.RemovePage(ChatLine.PageID);

      // clear userlist
      //self.ChatLines[i].UsersCount := 0;
      //SetLength(self.ChatLines[i].UsersList, self.ChatLines[i].UsersCount);
      // remove element of array
      //self.ChatLines.Remove(self.ChatLines[i]);
      self.ChatLines.Delete(i);
      //for n:=i to ChatLinesCount-2 do ChatLines[n]:=ChatLines[n+1];
      //Dec(ChatLinesCount);
      //SetLength(ChatLines, ChatLinesCount);

      result := true;
      Exit;
    end;
  end;
end;

function TTalariaClient.AddUserToLine(sUserID, sLineName, sUserNick, sUserVersion, sUserStatus, sHelloMsg: string): boolean;
var
  i, n, ui: integer;
  ChatUser: TIChatUser;
begin
  result:=false;
  // Найдем юзера в общем списке
  ChatUser:=nil;
  for i:=0 to self.ChatUsers.Count-1 do
  begin
    if TIChatUser(self.ChatUsers[i]).ID = sUserID then
    begin
      ChatUser:=TIChatUser(self.ChatUsers[i]);
      Break;
    end;
  end;

  // If user not found, add it to list
  if not Assigned(ChatUser) then
  begin
    //Inc(self.ChatUsersCount);
    //SetLength(self.ChatUsers, self.ChatUsersCount);
    //ui:=self.ChatUsersCount-1;
    ChatUser:=TIChatUser.Create();
    ChatUser.ID:=sUserID;
    ChatUser.Nick:=sUserNick;
    ChatUser.Version:=sUserVersion;
    ChatUser.Status:=sUserStatus;
    ChatUser.HelloMsg:= sHelloMsg;
    self.ChatUsers.Add(ChatUser);
  end;

  ChatUser.Nick := sUserNick;
  ChatUser.Version := sUserVersion;
  ChatUser.Status := sUserStatus;
  //ChatUser.HelloMsg := ;

  for i:=0 to self.ChatLines.Count-1 do
  with TIChatLine(self.ChatLines[i]) do
  begin
    if Name <> sLineName then Continue;
    // Try to find user in line's userlist
    if UsersList.IndexOf(ChatUser) < 0 then
    begin
      // Add user to line's userlist
      UsersList.Add(ChatUser);
      //Inc(UsersCount);
      //SetLength(UsersList, UsersCount);
      //UsersList[UsersCount-1] := @self.ChatUsers[ui];
      result:=true;
    end;
  end;
end;

function TTalariaClient.RemoveUserFromLine(sLineName, sUserID: string): boolean;
var
  ChatLine: TIChatLine;
  i, n: integer;
begin
  result := false;
  if not GetLineByName(sLineName, ChatLine) then Exit;
  for i:=ChatLine.UsersList.Count-1 downto 0 do
  begin
    if TIChatUser(ChatLine.UsersList[i]).ID = sUserID then
    begin
      // remove element of array
      ChatLine.UsersList.Delete(i);
      //for n:=i to ChatLine.UsersCount-2 do ChatLine.UsersList[n]:=ChatLine.UsersList[n+1];
      //Dec(ChatLine.UsersCount);
      //SetLength(ChatLine.UsersList, ChatLine.UsersCount);
    end;
  end;
  result := true;
end;

function TTalariaClient.RenameUser(sUserID, sNewName: string): boolean;
var
  i, n: integer;
  sOldName: string;
  ChatUser: TIChatUser;
begin
  // Переименование в списке свойств юзеров
  result:=false;
  sOldName:=sNewName;
  ChatUser:=nil;
  for i:=0 to self.ChatUsers.Count-1 do
  begin
    if TIChatUser(self.ChatUsers[i]).ID = sUserID then
    begin
      ChatUser:=TIChatUser(self.ChatUsers[i]);
      sOldName:=ChatUser.Nick;
      ChatUser.Nick := sNewName;
      result:=(sOldName<>sNewName);
      Break;
    end;
  end;

  // Переименование в списке юзеров линий
  for i:=0 to self.ChatLines.Count-1 do
  begin
    with TIChatLine(self.ChatLines[i]) do
    begin
      if UsersList.IndexOf(ChatUser) < 0 then Continue;
      Core.ChangeNick(PageID, sOldName, sNewName);
    end;
  end;

end;

function TTalariaClient.ChangeUserStatus(sUserID, sNewStatus, sNewStatusMsg: string): boolean;
var
  i: integer;
  ChatUser: TIChatUser;
begin
  result:=false;
  for i:=0 to self.ChatUsers.Count-1 do
  begin
    if TIChatUser(self.ChatUsers[i]).ID = sUserID then
    begin
      ChatUser:=TIChatUser(self.ChatUsers[i]);
      result:=(ChatUser.Status <> sNewStatus) or (ChatUser.StatusMsg <> sNewStatusMsg);
      ChatUser.Status := sNewStatus;
      ChatUser.StatusMsg := sNewStatusMsg;
      Break;
    end;
  end;
end;

procedure TTalariaClient.ResetUserTimer(UserID: string);
var
  ChatUser: TIChatUser;
begin
  if not GetUserByUserID(UserID, ChatUser) then Exit;
  ChatUser.SilentTime:=0;
end;

// ===================
procedure TTalariaClient.ParseData(strData: String; var parsed: TParsedData);
var
  i, ih, MsgLen: integer;
  s, st, str: string;
  n: integer;

procedure ParseIdent(sIdent: string; var sIP, sHost, sName: string);
var
  n: integer;
  s: string;
begin
  s:=sIdent;

  // IP
  n:=Pos('/', s);
  if n=0 then
  begin
    sIP:=s;
    Exit;
  end;
  sIP:=Copy(s, 1, n-1);
  s:=Copy(st, n+1, maxint); // остаток строки

  // Host
  n:=Pos('/', s);
  if n=0 then
  begin
    sHost:=s;
    Exit;
  end;
  sHost:=Copy(s, 1, n-1);
  s:=Copy(st, n+1, maxint); // остаток строки

  // Name
  sName:=s;
end;

begin
  //Обнуляем переменные
  with parsed do
  begin
    bHasErrors:= true;
    sSenderID := '';
    sReceiverID := '';
    sCommand := '';
    sMsgCommand := '';
    sMsgText := '';
    sMsgSenderID := '';
    //Устанавливаем размер массива
    SetLength(MsgParams, 0);
  end;
  st:=strData;
  ih:=0; // индекс конца заголовка
{
[Длина сообщения] [0x00] [Отправитель] [0x00] [Команда] [0x00] [Получатель | "*"] [0x00] [Сообщение]

Длина сообщения — количество байт, начиная с первого байта команды до завершения пакета.
0x00 — разделитель параметров (символ с кодом 0).
Отправитель — строка, определяющая отправителя сообщения. Строка должна иметь вид IP-ADDRESS[/NETBIOS-NAME][/LOGIN].

IP-ADDRESS — текстовое представление IP-адреса отправителя.
NETBIOS-NAME — нетбиос-имя компьютера-отправителя.
LOGIN — имя пользователя, под аккаунтом которого работает отправитель.
Поля NETBIOS-NAME и LOGIN могут не заполняться.
(В дальнейшем мы будем называть строки такого вида IDENT). В IChatAPI для представления IDENT’а используется класс IChatSender.

Команда — команда серверу, в данном случае (для обёртки) всегда FORWARD. Получатель — IDENT получателя сообщения или же "*" (звёздочка) в случае, если сообщение адресовано всем.
Сообщение — зашифрованное сообщение или пакет сообщений.

Формат сообщения, отправляемого сервером клиенту:

[Длина сообщения] [0x00] [Команда] [0x00] [Сообщение]

}

  if not self.bUseMailslots then
  begin
    // Определяем длину сообщения
    i:=Pos(#0, st);
    MsgLen:=StrToIntDef(Copy(st, 1, i-1), 0);
    st:=Copy(st, i+1, maxint); // остаток строки
    Inc(ih, i);

    // Первый аргумент
    i:=Pos(#0, st);
    s:=Copy(st, 1, i-1);
    st:=Copy(st, i+1, maxint); // остаток строки
    Inc(ih, i);

    if UpperCase(s) = 'FORWARD' then
    begin
      // Команда
      Parsed.sCommand:=s;
    end
    else
    begin
      // Отправитель
      Parsed.sSenderID:=s;
      //ParseIdent(Parsed.sSenderID, Parsed.SenderIP, Parsed.SenderHost, Parsed.SenderName);

      // Команда
      i:=Pos(#0, st);
      Parsed.sCommand:=Copy(st, 1, i-1);
      st:=Copy(st, i+1, maxint); // остаток строки
      Inc(ih, i);

      // Получатель
      i:=Pos(#0, st);
      Parsed.sReceiverID:=Copy(st, 1, i-1);
      //ParseIdent(Parsed.sReceiverID, Parsed.ReceiverIP, Parsed.ReceiverHost, Parsed.ReceiverName);
      st:=Copy(st, i+1, maxint); // остаток строки
      Inc(ih, i);
    end;
  end;

  // st содержит зашифрованое внутреннее сообщение
{
[0x13] "ichat" [0x13] [0x13] [Счетчик ASCII] [0x13][0x13] [Отправитель] [0x13][0x13] [Команда] [0x13][0x13] [параметры команды] [0x13]

0x13 — это разделитель для «внутренней команды». Два разделителя подряд отделяют поля команды друг от друга, в то время как один разделитель означает конец команды.
Команда — имя команды (см. ниже).
Параметры команды — специфические параметры для каждой команды (см. ниже).
}

  if LowerCase(Copy(st, 2, 5))<>'ichat' then
  begin
    n:=Length(st);
    str:=Copy(st,1, MaxInt);
    RC4Reset(RC4KeyData);
    RC4Crypt(RC4KeyData, PChar(str), PChar(str), n);

    //DebugString('Decode1: '+st);
    //DebugString('Decode2: '+str);
    st:=str;
  end;

  DebugString('< '+Copy(strData, 1, ih)+'='+st);

  i:=Pos(#19, st);
  if i=1 then st:=Copy(st, i+1, maxint) // остаток строки
  else
  begin
    DebugString('Wrong packet');
    Exit;
  end;

  n:=0;
  while i>0 do
  begin
    Inc(n);
    i:=Pos(#19+#19, st);
    if i=0 then
    begin
      if n=4 then  // Команда без параметров
      begin
        i:=Pos(#19, st);
        if i>1 then Parsed.sMsgCommand := Copy(st, 1, i-1);
        parsed.bHasErrors:=false;
        Exit;
      end;
      Break;
    end;
    s:=Copy(st, 1, i-1);
    case n of
    // "iChat"
    1:
      begin
        // Описание протокола
        //if s <> 'iChat' then Exit;
      end;
    // Счетчик ASCII
    2:
      begin
      end;
    // Отправитель
    3:
      begin
        Parsed.sMsgSenderID:=s;
        //ParseIdent(Parsed.sMsgSenderID, Parsed.MsgSenderIP, Parsed.MsgSenderHost, Parsed.MsgSenderName);
      end;
    // Команда
    4: Parsed.sMsgCommand:=s;
    else
      SetLength(parsed.MsgParams, Length(parsed.MsgParams)+1);
      parsed.MsgParams[Length(parsed.MsgParams)-1] := s;
    end;
    st:=Copy(st, i+2, maxint); // остаток строки
  end;
  i:=Pos(#19, st);
  if i>1 then
  begin
    SetLength(parsed.MsgParams, Length(parsed.MsgParams)+1);
    parsed.MsgParams[Length(parsed.MsgParams)-1] := Copy(st, 1, i-1);
  end;
  parsed.bHasErrors:=false;

end;

procedure TTalariaClient.OnIChatMessage(parsed: TParsedData);
var
  DebugPageIndex: integer;
  AllParams, strTarget, strText: string;
  strCmd, strChan, strTemp: string;
  numCmd, i, n: integer;
  ParamsCount: integer;
  sLineName, sSenderName: string;
  SomeChatLine: TIChatLine;
  PageID: integer;

procedure DebugMessage(sLineName, sInfoText: string);
begin
  if not bDebugInfo then Exit;
  Core.ParseIRCTextByPageID(ciDebugPageID, TimeTemplate()+''+#2+#3+'05'+sLineName+#3+#2+' '+#3+'03'+sInfoText);
  //self.ShowText(ciDebugPageID, TimeTemplate()+''+#2+#3+'05'+sLineName+#3+#2+' '+sInfoText);
end;

begin
  //ResetTimer(TC_ServerData);
  ResetUserTimer(Parsed.sMsgSenderID);

  strCmd:=UpperCase(parsed.sMsgCommand);
  ParamsCount:=Length(parsed.MsgParams);
  sSenderName:=GetNickByUserID(Parsed.sMsgSenderID);

  // Send message to plugins
  if Assigned(Core.PluginsManager) then
  begin
    strTemp:='iChat '+Norm(self.FInfoConnection)+' '+strCmd;
    if Parsed.sMsgSenderID='' then strTemp:=strTemp+' iChat' else strTemp:=strTemp+' '+Norm(Parsed.sMsgSenderID);
    strTemp:=strTemp+' '+IntToStr(ParamsCount);
    for i:=0 to ParamsCount-1 do strTemp:=strTemp+' '+Norm(Parsed.MsgParams[i]);
    Core.PluginsManager.BroadcastMsg(strTemp);
  end;

  if strCmd='' then Exit

  { ALERT [0x13][0x13] [текст сообщения]
  — алерт-сообщение (клиент может быть настроен на различные действие при получении алертов от пользователей).}
  else if strCmd='ALERT' then
  begin
  end

  { BOARD [0x13][0x13] [номер блока, начиная с нуля] [0x13][0x13] [текс блока]
  — сообщение для доски объявлений. Сообщения разбиваются на блоки по 300 (?) символов каждый.}
  else if strCmd='BOARD' then
  begin
    if ParamsCount < 2 then Exit;
    DebugMessage(self.sBoardLineName,''+Parsed.sMsgSenderID+' <'+Parsed.MsgParams[0]+'> '+Parsed.MsgParams[1]);

    self.AddBoardMsg(sSenderName, Parsed.MsgParams[1], Parsed.MsgParams[0]);
    self.RefreshBoard();
  end

  { CONNECT [0x13][0x13] [Имя линии] [0x13][0x13] [логин пользователя]
  [0x13][0x13] [никнейм] [0x13][0x13] [не используется]
  [0x13][0x13] [приветственное сообщение] [0x13][0x13] [получатель]
  [0x13][0x13] [версия] [0x13][0x13] [статус]
  — сообщение о подключении (как к общему чату, так и к линии). Поле получателя играет особую роль.
  При подключении клиент отправляет сообщение о подключении с полем получателя равным "*".
  Получив такое сообщение каждый клиент в свою очередь отправляет ответное сообщение о подключении
  с полем получателя, равным IDENT’у нашего клиента. Таким образом, необходимо анализировать
  это поле для того чтобы вовремя отправить сообщение о собственном подключении, иначе мы
  не попадём в список контактов новоподключившегося клиента.}
  else if strCmd='CONNECT' then
  begin
    sLineName:=Parsed.MsgParams[0];
    DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' '+sIChatConnect1+' '+Parsed.MsgParams[4]);
    if ParamsCount < 8 then Exit;

    if not self.GetLineByName(sLineName, SomeChatLine) then Exit;

    // Добавляем новичка в список
    if self.AddUserToLine(Parsed.sMsgSenderID, sLineName, Parsed.MsgParams[2], Parsed.MsgParams[6], Parsed.MsgParams[7], Parsed.MsgParams[4]) then
    begin
      if self.Conf.GetBool('ShowStatusMessages') then
      begin
        self.ShowText(SomeChatLine.PageID, #3+'04'+TimeTemplate()+' '+sIChatConnect+' '+Parsed.MsgParams[2]+'. '+Parsed.MsgParams[4]);
      end;
    end;
    Core.AddNick(SomeChatLine.PageID, Parsed.MsgParams[2], ciIconNormal);

    if self.Cheats.bUseInvisibleConnect then Exit;
    if Parsed.MsgParams[5]='*' then
    begin
      // Кто-то зашел на канал. Отправляем новичку ответ о себе
      self.SendMsgConnect(Parsed.sMsgSenderID, sLineName);
      self.SendMsgStatusReq(Parsed.sMsgSenderID);
      self.SendMsgBoard(Parsed.sMsgSenderID);
      //self.SendMsgBoardReq(Parsed.sMsgSenderID);
    end
    else if Parsed.MsgParams[5]=self.Myself.ID then
    begin
      // Кто-то откликнулся на наше приветствие. Нужно спросить его статус.
      self.SendMsgStatusReq(Parsed.sMsgSenderID);
      //self.SendMsgBoard(Parsed.sMsgSenderID);
      self.SendMsgBoardReq(Parsed.sMsgSenderID);
    end
    else
    begin
    end;
  end

  { CREATE_LINE [0x13][0x13] [имя линии] [пароль для входа в линию] [отправитель]
  — создание линии. }
  else if strCmd='CREATE_LINE' then
  begin
    if ParamsCount < 3 then Exit;
    sLineName:=Parsed.MsgParams[0];
    DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' '+sIChatCreateLinePassw+': '+Parsed.MsgParams[2]);
    if not self.CreateChatLine(sLineName, false, Parsed.MsgParams[1]) then Exit;
    //if not self.GetLineByName(sLineName, SomeChatLine) then Exit;
    if Parsed.MsgParams[2]='' then
    begin
      self.ShowText(MainPageID, TimeTemplate()+''+sSenderName+' '+sIChatCreateLine);
    end
    else
    begin
      if self.Cheats.bShowPasswords then
      begin
        self.ShowText(MainPageID, TimeTemplate()+''+sSenderName+' '+sIChatCreateLinePassw+': '+Parsed.MsgParams[2]);
      end
      else
      begin
        self.ShowText(MainPageID, TimeTemplate()+''+sSenderName+' '+sIChatCreateLinePassw);
      end;
    end;
  end

  { CREATE [0x13][0x13] [идентификатор приватной линии] [0x13][0x13] [не используется?]
  [0x13][0x13] [получатель] — создание личного чата. }
  else if strCmd='CREATE' then
  begin
    if ParamsCount < 3 then Exit;
    sLineName:=Parsed.MsgParams[0];
    DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' '+sIChatCreate);

    if Parsed.MsgParams[2] <> self.Myself.ID then
    begin
      if not self.Cheats.bInterceptPrivates then Exit;
    end;

    if not self.CreateChatLine(sLineName, true) then Exit;
    self.ShowText(MainPageID, TimeTemplate()+''+sSenderName+' '+sIChatCreate);
  end

  { DISCONNECT [0x13][0x13] [имя линии] — выход из линии. }
  else if strCmd='DISCONNECT' then
  begin
    if ParamsCount < 1 then Exit;
    sLineName:=Parsed.MsgParams[0];
    DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' '+sIChatDisconnect);

    self.RemoveUserFromLine(sLineName, parsed.sMsgSenderID);
    if self.GetLineByName(sLineName, SomeChatLine) then
    begin
      if self.Conf.GetBool('ShowStatusMessages') then
      begin
        self.ShowText(SomeChatLine.PageID, #3+'04'+TimeTemplate()+' '+sSenderName+' '+sIChatDisconnect);
      end;
      Core.RemoveNick(SomeChatLine.PageID, sSenderName);

      // Если на линии не осталось юзеров - убираем ее
      if sLineName = self.sMainLineName then Exit;
      if SomeChatLine.UsersList.Count=0 then
      begin
        //Core.PagesManager.RemovePage(SomeChatLine.PageID);
        self.RemoveChatLine(SomeChatLine.Name);
      end;
    end;
  end

  { ME [0x13][0x13] [сообщение] [0x13][0x13] [имя линии] [0x13][0x13] [получатель]
  — аналог ACTION в IRC (команда /me сообщение).  }
  else if strCmd='ME' then
  begin
    if ParamsCount < 3 then Exit;
    sLineName:=Parsed.MsgParams[1];
    DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' '+Parsed.MsgParams[0]);
    if self.GetLineByName(sLineName, SomeChatLine) then
    begin
      self.ShowText(SomeChatLine.PageID, #3+'02'+TimeTemplate()+' '+sSenderName+' '+Parsed.MsgParams[0]);
      Core.FlashMessage(SomeChatLine.PageID, sSenderName, Parsed.MsgParams[0], false);
      Core.GrabNotesByKeywords(sSenderName, Parsed.MsgParams[0]);
      Core.PlayNamedSound('sfxMeMsg', self);
    end;
  end

  { RECEIVED [0x13][0x13] [имя линии] [0x13][0x13] [текст подтверждения]
  — подтверждение получения сообщения.  }
  else if strCmd='RECEIVED' then
  begin
    if ParamsCount < 2 then Exit;
    sLineName:=Parsed.MsgParams[0];
    DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' receive msg and reply: '+Parsed.MsgParams[1]);
    if sLineName = self.sPrivateLineName then
    begin
      self.ShowText(self.MainPageID, #3+'04'+TimeTemplate()+' '+sSenderName+' '+Parsed.MsgParams[1]);
    end
    else
    begin
      if self.GetLineByName(sLineName, SomeChatLine) then
      begin
        self.ShowText(SomeChatLine.PageID, #3+'04'+TimeTemplate()+' '+sSenderName+' '+Parsed.MsgParams[1]);
      end
    end;
  end

  { REFRESH_BOARD — запрос на обновление доски объявлений. }
  else if strCmd='REFRESH_BOARD' then
  begin
    DebugMessage(sBoardLineName,''+Parsed.sMsgSenderID+' ask for msg_board update');
    self.SendMsgBoard(Parsed.sMsgSenderID);
  end

  { REFRESH [0x13][0x13] [имя линии] [0x13][0x13] [логин пользователя]
  [0x13][0x13] [никнейм] [0x13][0x13] [не используется]
  [0x13][0x13] [приветствие] [0x13][0x13] [получатель]
  [0x13][0x13] [версия] [0x13][0x13] [статус]
  — обновление списка контактов. Как и в случае с CONNECT, поле «получатель» несёт особую нагрузку.
  Клиент периодически отправляет запрос на обновление списка контактов, в этом случае поле
  получатель будет содержать "*" (звёздочку). В ответ на это сообщение каждый клиент,
  подключённый к данной линии должен отправить ответное REFRESH сообщение, но в
  поле «получатель» будет содержаться IDENT нашего клиента. Таким образом, опять же,
  нам необходимо анализировать это поле чтобы вовремя сигнализировать запрашивающему
  клиенту о своём присутствии на линии. }
  else if strCmd='REFRESH' then
  begin
    if ParamsCount < 8 then Exit;
    sLineName:=Parsed.MsgParams[0];
    DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' do REFRESH');
    //InfoMessage(sLineName, ''+Parsed.sMsgSender+'> '+Parsed.MsgParams[4]);
    // Добавляем новичка в список
    self.AddUserToLine(Parsed.sMsgSenderID, sLineName, Parsed.MsgParams[2], Parsed.MsgParams[6], Parsed.MsgParams[7], Parsed.MsgParams[5]);
    if sLineName<>'*' then
      if self.GetLineByName(sLineName, SomeChatLine) then
        Core.AddNick(SomeChatLine.PageID, Parsed.MsgParams[2], ciIconNormal);

    if self.Cheats.bUseInvisibleConnect then Exit;
    // Отправляем новичку ответ о себе
    if Parsed.MsgParams[5]='*' then
    begin
      self.SendMsgRefresh(Parsed.sMsgSenderID, sLineName, Myself.ID);
      //self.SendMsgRefreshReply(Parsed);
    end;
  end

  { RENAME [0x13][0x13] [новый никнейм] — сообщение о смене имени пользователя. }
  else if strCmd='RENAME' then
  begin
    sLineName:='*';
    DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' '+sIChatRename+' '+Parsed.MsgParams[0]);
    if self.RenameUser(parsed.sMsgSenderID, Parsed.MsgParams[0]) then
    begin
      // Ник изменился
      //if self.Conf.GetBool('ShowStatusMessages') then
      begin
        self.ShowText(MainPageID, #3+'04'+TimeTemplate()+' '+sSenderName+' '+sIChatRename+' '+Parsed.MsgParams[0]);
      end;
    end;
  end

  { STATUS [0x13][0x13] [новый статус] [0x13][0x13] [сообщение статуса]
  — сообщение о смене пользователем статуса. «Сообщение статуса» — сообщение,
  которое будет выдано пользователю в ответ на попытку отправить личное сообщение. }
  else if strCmd='STATUS' then
  begin
    if ParamsCount < 2 then Exit;
    sLineName:='*';
    DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' '+sIChatStatus+' '+Parsed.MsgParams[0]+' :'+Parsed.MsgParams[1]);
    if self.ChangeUserStatus(parsed.sMsgSenderID, Parsed.MsgParams[0], Parsed.MsgParams[1]) then
    begin
      // статус или сообщение статуса изменились
      if self.Conf.GetBool('ShowStatusMessages') then
      begin
        self.ShowText(MainPageID, #3+'04'+TimeTemplate()+' '+sSenderName+' '+sIChatStatus+' '+Parsed.MsgParams[0]+': '+Parsed.MsgParams[1]);
      end;
    end;
  end

  { STATUS_REQ — запрос статуса пользователя. }
  else if strCmd='STATUS_REQ' then
  begin
    sLineName:='*';
    DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' ask for STATUS');
    self.SendMsgStatus(Parsed.sMsgSenderID);
    self.SendMsgBoard(Parsed.sMsgSenderID);
  end

  { TEXT [0x13][0x13] [имя линии] [0x13][0x13] [текст сообщения]
  [0x13][0x13] [имя получателя (не IDENT)]
  — текст сообщения. Вид сообщения (общее или личное регулируется с помощью имени
  линии, см. ниже). Обратите внимание на то, что имя получателя в данном случае
  — это НЕ IDENT-строка. Это обращение, которое будет указано в теле сообщения,
  выводимого пользователю (в случае личного сообщения). Имя пользователя для личного
  сообщения может быть любым. Для публичного сообщение поле обычно содержит "*" (звёздочку). }
  else if strCmd='TEXT' then
  begin
    if ParamsCount < 2 then Exit;
    strTarget:='';
    if ParamsCount >= 3 then strTarget:='<'+Parsed.MsgParams[2]+'>';

    sLineName:=Parsed.MsgParams[0];
    PageID:=MainPageID;
    if self.GetLineByName(sLineName, SomeChatLine) then PageID:=SomeChatLine.PageID;
    if sLineName = self.sMainLineName then
    begin
      // #Main
      DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' ('+Parsed.MsgParams[0]+') '+strTarget+' :'+Parsed.MsgParams[1]);
      self.ShowText(MainPageID, #3+'02'+TimeTemplate()+' <'+sSenderName+'>'+strTarget+' '+Parsed.MsgParams[1]);
      Core.FlashMessage(MainPageID, sSenderName, Parsed.MsgParams[1], false);
      Core.GrabNotesByKeywords(sSenderName, Parsed.MsgParams[1]);
      Core.PlayNamedSound('sfxChanMsg', self);
    end
    else if sLineName = self.sPrivateLineName then
    begin
      // Private msg
      DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' ('+Parsed.MsgParams[0]+') '+strTarget+' :'+Parsed.MsgParams[1]);
      self.ShowText(PageID, #3+'03'+TimeTemplate()+' <'+sSenderName+'>'+strTarget+' '+Parsed.MsgParams[1]);
      Core.FlashMessage(PageID, sSenderName, Parsed.MsgParams[1], true);
      Core.ShowPrivateMsg(PageID, sSenderName, Parsed.MsgParams[1]);
      Core.GrabNotesByKeywords(sSenderName, Parsed.MsgParams[1]);
      Core.PlayNamedSound('sfxPvtMsg', self);
      if Parsed.sMsgSenderID <> Myself.ID then
        self.SendMsgReceived(Parsed.sMsgSenderID, sLineName, sIChatReceivedReply);
    end
    else
    begin
      // Private line
      DebugMessage(sLineName, ''+Parsed.sMsgSenderID+' ('+Parsed.MsgParams[0]+') '+strTarget+' :'+Parsed.MsgParams[1]);
      if Parsed.sMsgSenderID = Myself.ID then
      begin
        // My own message
        self.ShowText(PageID, #3+'02'+TimeTemplate()+' <'+sSenderName+'>'+strTarget+' '+Parsed.MsgParams[1]);
        Core.FlashMessage(PageID, sSenderName, Parsed.MsgParams[1], false);
        Core.GrabNotesByKeywords(sSenderName, Parsed.MsgParams[1]);
        Core.PlayNamedSound('sfxChanMsg', self);
      end
      else
      begin
        // other user's message
        self.ShowText(PageID, TimeTemplate()+' <'+sSenderName+'>'+strTarget+' '+Parsed.MsgParams[1]);
        Core.FlashMessage(PageID, sSenderName, Parsed.MsgParams[1], false);
        Core.GrabNotesByKeywords(sSenderName, Parsed.MsgParams[1]);
        Core.PlayNamedSound('sfxChanMsg', self);
      end;
    end;
  end

  else
  begin
  end;
end;

function TTalariaClient.SendTextFromPage(PageInfo: TPageInfo; sText: string): string;
var
  strCom, strPassw, strTrimText, strTarget: string;
  strResult, strCmdText, strTemp, strNick: string;
  i: integer;
  Params: TStringArray;

begin
  Result:='';
  strResult:='';

  strTrimText:=Trim(sText);
  if Length(strTrimText)<1 then Exit;

  strTarget:=PageInfo.sNick;
  if strTarget='' then strTarget:=PageInfo.sChan;

  // Если это не команда
  if Copy(strTrimText, 1, 1)<>'/' then
  begin
    //ShowText(PageInfo.ID, TimeTemplate()+#2+'<'+Conf['MyNick']+'>'+#2+' '+sText);
    if PageInfo.sNick <> '' then // Страница привата
    begin
      SendMsgText(GetUserIDByNick(PageInfo.sNick), self.sPrivateLineName, sText, PageInfo.sNick);
    end
    else if PageInfo.sChan <> '' then // Общая линия
    begin
      SendMsgText('*', PageInfo.sChan, sText, '');
    end
    else
    begin
      SendMsgText('', '', sText, '');
    end;
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

  if not self.FActive then
  begin
    strTemp:='CONNECT DEBUG SERVER QUIT';
    if Pos(strCom, strTemp) = 0 then
    begin
      ShowText(MainPageID, TimeTemplate()+#2+#3+'04 '+sIChatNotConnected);
      Exit;
    end;
  end;

  if strCom='' then Exit

  else if strCom='*' then LocalEvent(strCmdText)

  else if strCom='JOIN' then
  begin
    if bUseMailslots then
    begin
      //TabCreate(Trim(strCmdText));
    end;
    SendMsgConnect('*', Trim(strCmdText));
    Exit;
    {strResult := 'JOIN ' + strCmdText;
    with conf.slRecentChannels do
    begin
      i:=Indexof(Trim(strCmdText));
      if i<0 then
        Insert(0, Trim(strCmdText))
      else
        Move(i, 0);
      if Count>8 then Delete(8);}
  end

  else if strCom='PART' then
  begin
    strTemp:=PageInfo.sChan;
    // Если команда с параметром, то она сработает в любом случае
  	if Trim(strCmdText) <> '' then strTemp:=Trim(strCmdText)
    else if strTemp = self.sMainLineName then Exit;

    begin
      if bUseMailslots then
      begin
        //TabsRemove(ReturnChanIndex(strTemp));
      end;
      SendMsgDisconnect('*', strTemp);
    end;
  end

  else if strCom='ME' then
  begin
    if bUseMailslots then
    begin
      ShowText(PageInfo.ID, ' * '+self.Conf['MyNick']+' '+strCmdText);
    end;
    SendMsgMe(PageInfo.sNick, PageInfo.sChan, strCmdText);
  end

  else if strCom='MSG' then
  begin
    Params:=ParseStr(strCmdText);
    if Length(Params)<2 then Exit;
    strNick:=Params[0];
    strTemp:='';
    for i:=1 to Length(Params)-1 do strTemp:=strTemp+Params[i];
    //i:=Pos(' ',strCmdText);
    //strNick:=Copy(strCmdText, 1, i-1);
    //strTemp:=Copy(strCmdText, i+1, maxint);
    if bUseMailslots then
    begin
      ShowText(PageInfo.ID, #3+'03'+'<'+self.Conf['MyNick']+'><'+strNick+'> '+strTemp);
    end;

    if PageInfo.sChan = self.sMainLineName then
    begin
      // Приват с главного канала
      SendMsgText(GetUserIDByNick(strNick), sPrivateLineName, strTemp, strNick);
    end
    else if PageInfo.sNick <> '' then
    begin
      // приват со страницы привата
      SendMsgText(GetUserIDByNick(PageInfo.sNick), sPrivateLineName, strTemp, PageInfo.sNick);
    end
    else
    begin
      // приват непонятно откуда
      SendMsgText(GetUserIDByNick(strNick), sPrivateLineName, strTemp, strNick);
    end;

    //strResult := 'PRIVMSG '+Copy(strCmdText, 1, i-1)+' :'+Copy(strCmdText, i+1, maxint);
    //ParseIRCText(#3+'03'+TimeTemplate()+'<'+conf.strNick+'><'+Copy(strCmdText, 1, i-1)+'> '+Copy(strCmdText, i+1, maxint), ReturnChanIndex(strTarget));
  end

  else if strCom='PRIV_LINE' then
  begin
    strTemp:=GetRandomNumStr();
    self.CreateChatLine(strTemp, true, '', '>'+strCmdText);
    self.SendMsgCreate(GetUserIDByNick(strCmdText), strTemp, GetUserIDByNick(strCmdText));
    self.SendMsgConnect('', strTemp);
  end

  else if strCom='WHOIS' then
  begin
    self.ShowUserInfo(strCmdText);
  end

  else if strCom='RAW' then
  begin
    //strResult := Trim(strCmdText);
    //ParseIRCText(#3'02-> Server: '+#3+' '+strCmdText, ReturnChanIndex(csDebugTabName));
  end

  else if strCom='CONNECT' then
  begin
    self.Connect();
  end

  else if strCom='DISCONNECT' then
  begin
    self.Disconnect();
  end

  else if strCom='QUIT' then
  begin
    self.Conf['QuitMessage']:=strCmdText;
    self.Disconnect();
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
      	Conf['ServerHost'] := Trim(copy(strCmdText, 1, i-1));
      	Conf['ServerPort'] := Trim(copy(strCmdText, i+1, maxint));
      end
      else
      begin
      	Conf['ServerPort'] := '6667';
        Conf['ServerHost'] := strCmdText;
      end;
      self.Disconnect;
      self.Connect;
      Exit;
    end;
  end

  else if (strCom='NOTICE') or (strCom='TOPIC') then
  begin
  	if Length(strCmdText) > 0 then
    begin
      self.Myself.BoardMsg:=StrCmdText;
    end;
    self.SendMsgBoard();
  end

  else if strCom='NICK' then
  begin
  	if Length(strCmdText) > 0 then
    begin
      Myself.Nick:=strCmdText;
      self.SendMsgRename();
    end;
  end

  else if strCom='REFRESH_NAMES' then
  begin
    self.RefreshNames(PageInfo.sChan);
  end

  else if strCom='ID' then
  begin
    self.Myself.ID:= strCmdText;
  end

  else if strCom='LIST' then
  begin
    //strResult := 'LIST '+strCmdText;
  end

  else if strCom='KICK' then
  begin
    //if PageInfo.sChan<>'' then
    //  strResult := 'KICK '+PageInfo.sChan+' '+strCmdText;
  end

  else if strCom='HOP' then
  begin
  	//if (PageInfo.sChan <> '')
    //then RejoinChannel(PageInfo.sChan);
    //Exit;
  end

  else if strCom='AWAY' then
  begin
    //strResult := 'AWAY '+strCmdText;
  end

  else if strCom='DEBUG' then
  begin
    bDebugInfo := Conf.GetBool('DebugMessages');
    bDebugInfo := not bDebugInfo;
    Conf.SetBool('DebugMessages', bDebugInfo);
    if bDebugInfo then strTemp:='ON' else strTemp:='OFF';
    Self.ShowText(MainPageID, #2+'Debug: '+strTemp);
    // Debug smiles
    Exit;
  end
  {
  else if strCom='PASSWD' then
  begin
    if SetChanPassword(strTarget, strCmdText) then
    begin
      strTemp:='test';
      EncryptText(strTemp, strTemp);
      if strTemp<>'test' then
        ParseIRCText(#2+sPasswordSet, ReturnChanIndex(strTarget))
      else
      begin
        SetChanPassword(strTarget, '');
        ParseIRCText(#2+sLibeay32NotFound , ReturnChanIndex(strTarget));
      end;
    end
    else
      ParseIRCText(#2+sPasswordUnset, ReturnChanIndex(strTarget));
    Exit;
  end

  else
  begin
    Result:='ERR';
  end;

  }
end;

procedure TTalariaClient.OnApplySettings(Sender: TObject);
begin
  // период команды REFRESH в секундах
  self.iRefreshPeriod:=Conf.GetInteger('RefreshPeriod')*1000;
  // таймаут ожидания ответов в секундах
  self.iReplyTimeout:=Conf.GetInteger('ReplyTimeout')*1000;
  //self.bSendUTF8:=Conf.GetBool('SendUTF8');
  //self.bReceiveUTF8:=Conf.GetBool('ReceiveUTF8');
  self.ServerProxy:=Conf['ServerProxy'];
  //self.FInfoConnection:='iChat '+Conf['ServerHost']+':'+Conf['ServerPort'];

  self.bDebugInfo:=Conf.GetBool('DebugMessages');

  if self.Myself.Nick<>Conf['MyNick'] then
  begin
    //if FActive then Core.Say('/NICK '+Conf['MyNick'], self.MainPageID);
    if FActive then Core.ModTimerEvent(0, self.MainPageID, 100, '/NICK '+Conf['MyNick']);
  end;

  if self.Myself.BoardMsg <> Conf['NotesList'] then
  begin
    self.Myself.BoardMsg := Conf['NotesList'];
    //self.SendMsgBoard();
    if FActive then Core.ModTimerEvent(0, self.MainPageID, 100, '/NOTICE');
  end;

  if (self.ServerHost<>Conf['ServerHost']) or (self.ServerPort<>Conf['ServerPort']) then
  begin
    self.ServerHost := Conf['ServerHost'];
    self.ServerPort := Conf['ServerPort'];
    if Trim(self.ServerHost)='' then
      self.FInfoConnection:='Mailslots'
    else
      self.FInfoConnection:=self.FInfoProtocolName+' '+self.ServerHost+':'+self.ServerPort;
    self.Conf.RootNode.FullName:=self.FInfoConnection;
    //if FActive then Core.Say('/SERVER', self.MainPageID);
    if FActive then Core.ModTimerEvent(0, self.MainPageID, 100, '/SERVER');
  end;
end;

procedure TTalariaClient.LocalEvent(sEvent: string);
var
  Cmd: string;
  i: integer;
begin
  Cmd:=Trim(sEvent);
  if Cmd = '' then Exit

  else if Cmd = 'REFRESH' then
  begin
    self.SendMsgRefresh();
    i:=Conf.GetInteger('RefreshPeriod')*1000;
    if i>0 then Core.ModTimerEvent(0, MainPageID, i, '/* REFRESH');
  end

  else if Cmd = 'SERV_TIMEOUT' then
  begin
    // реконнект
    if Conf.GetBool('AutoReconnect') then
    begin
      if not FActive then Connect();
    end
    else
    begin
      ShowText(MainPageID,  TimeTemplate()+#2+#3+'5'+sIChatServerDataTimeout);
    end;
  end;

end;

procedure TTalariaClient.AddBoardMsg(sNick, sMsg, sMsgNum: string);
var
  i, n: integer;
  ChatUser: TIChatUser;
begin
  // Ищем юзера по его нику
  ChatUser:=nil;
  for i:=0 to self.ChatUsers.Count-1 do
  begin
    if TIChatUser(self.ChatUsers[i]).Nick = sNick then
    begin
      ChatUser:=TIChatUser(self.ChatUsers[i]);
      Break;
    end;
  end;
  if ChatUser = nil then Exit;

  // Добавление сообщения
  //if sMsgNum = '0' then ChatUser.BoardMsg:='';
  //ChatUser.BoardMsg:=ChatUser.BoardMsg+sMsg;

  i:=StrToIntDef(sMsgNum, 0);
  while ChatUser.MsgBoard.Count < (i+1) do ChatUser.MsgBoard.Add('');
  //if ChatUser.MsgBoard.Count-1 < i then ChatUser.MsgBoard.Capacity:=i+1;
  ChatUser.MsgBoard[i]:=sMsg;
end;

procedure TTalariaClient.RefreshBoard();
var
  i, n: integer;
  ChatUser: TIChatUser;
  strText: string;
begin
  Core.ClearPageText(self.BoardPageID);
  Core.RemoveNick(self.BoardPageID, '', true);
  for i:=0 to self.ChatUsers.Count-1 do
  begin
    ChatUser:=TIChatUser(self.ChatUsers[i]);
    strText:=ChatUser.BoardMsg;
    if Trim(strText)='' then Continue;

    Core.AddNick(self.BoardPageID, ChatUser.Nick, ciIconNormal);
    Self.ShowText(self.BoardPageID, #3+'04'+ChatUser.Nick);
    Self.ShowText(self.BoardPageID, '----');
    n:=Pos(#13+#10, strText);
    while n > 0 do
    begin
      Self.ShowText(self.BoardPageID, #3+'02'+Copy(strText, 1, n-1));
      strText:=Copy(strText, n+2, maxint);
      n:=Pos(#13+#10, strText);
    end;
    Self.ShowText(self.BoardPageID, #3+'02'+strText);
    Self.ShowText(self.BoardPageID, '====');
  end;
end;

procedure TTalariaClient.ShowUserInfo(sNick: string);
var
  InfoList: TInfoList;
  ChatUser: TIChatUser;
begin
  if not self.GetUserByUserID(self.GetUserIDByNick(sNick), ChatUser) then Exit;
  // Список информации о пользователе
  InfoList.Count:=5;
  SetLength(InfoList.Items, InfoList.Count);

  InfoList.Items[0].Name:=sUserInfoNick;
  InfoList.Items[0].Data:=ChatUser.Nick;
  InfoList.Items[1].Name:=sUserInfoID;
  InfoList.Items[1].Data:=ChatUser.ID;
  InfoList.Items[2].Name:=sUserInfoVersion;
  InfoList.Items[2].Data:=ChatUser.Version;
  InfoList.Items[3].Name:=sUserInfoStatus;
  InfoList.Items[3].Data:=ChatUser.Status+' - '+ChatUser.StatusMsg;
  InfoList.Items[4].Name:=sUserInfoHelloMsg;
  InfoList.Items[4].Data:=ChatUser.HelloMsg;

  Core.ShowInfoList(InfoList, self);
end;

procedure TTalariaClient.RefreshNames(LineID: string);
begin
  self.SendMsgRefresh('*', LineID);
end;

function TTalariaClient.GetMainToolButtons(PageID: integer): TObjectList;
begin
  result:=nil;
  if Assigned(self.Conf) then result:=self.Conf.FToolButtonsList;
end;

procedure TTalariaClient.LoadLanguage();

procedure ReadIni(var s: string; Name: string);
begin
  s:=Core.LangIni.ReadString('iChat', Name, s);
end;

begin

  if not Assigned(Core.LangIni) then Exit;
  try
    begin
      ReadIni(sConnConnect, 'sConnConnect');
      ReadIni(sConnError, 'sConnError');
      ReadIni(sConnDisconnected, 'sConnDisconnected');
      ReadIni(sConnOpenHost, 'sConnOpenHost');
      ReadIni(sConnOpenPort, 'sConnOpenPort');

      ReadIni(sIChatNotConnected, 'sIChatNotConnected');
      ReadIni(sIChatServerDataTimeout, 'sIChatServerDataTimeout');
      ReadIni(sIChatDefaultHelloMsg, 'sIChatDefaultHelloMsg');
      ReadIni(sIChatDefaultStatusMsg, 'sIChatDefaultStatusMsg');
      ReadIni(sIChatBoardName, 'sIChatBoardName');
      ReadIni(sIChatConnect1, 'sIChatConnect1');
      ReadIni(sIChatConnect, 'sIChatConnect');
      ReadIni(sIChatCreateLine, 'sIChatCreateLine');
      ReadIni(sIChatCreateLinePassw, 'sIChatCreateLinePassw');
      ReadIni(sIChatCreate, 'sIChatCreate');
      ReadIni(sIChatDisconnect, 'sIChatDisconnect');
      ReadIni(sIChatRename, 'sIChatRename');
      ReadIni(sIChatStatus, 'sIChatStatus');
      ReadIni(sIChatReceivedReply, 'sIChatReceivedReply');

      ReadIni(sUserInfoNick, 'sUserInfoNick');
      ReadIni(sUserInfoID, 'sUserInfoID');
      ReadIni(sUserInfoVersion, 'sUserInfoVersion');
      ReadIni(sUserInfoStatus, 'sUserInfoStatus');
      ReadIni(sUserInfoHelloMsg, 'sUserInfoHelloMsg');

      ReadIni(sIChatSoundChannelMessage, 'sIChatSoundChannelMessage');
      ReadIni(sIChatSoundPrivateMessage, 'sIChatSoundPrivateMessage');
      ReadIni(sIChatSoundMeMessage, 'sIChatSoundMeMessage');
      //ReadIni(sIChatSoundNoticeMessage, 'sIChatSoundNoticeMessage');
      //ReadIni(sIChatSoundDccChat, 'sIChatSoundDccChat');
      //ReadIni(sIChatSoundDccFile, 'sIChatSoundDccFile');
      ReadIni(sIChatSoundServerConnect, 'sIChatSoundServerConnect');
      ReadIni(sIChatSoundServerDisconnect, 'sIChatSoundServerDisconnect');
      ReadIni(sIChatSoundJoinChannel, 'sIChatSoundJoinChannel');
      ReadIni(sIChatSoundLeaveChannel, 'sIChatSoundLeaveChannel');
      ReadIni(sIChatSoundErrorMessage, 'sIChatSoundErrorMessage');
      ReadIni(sIChatSoundOther, 'sIChatSoundOther');
    end;
  except
  end;
  Conf.frmIChatOptions.ChangeLanguage();
end;

end.
