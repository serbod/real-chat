{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  TAsyncSock - асинхронный сокет на базе библиотеки Synapse. По возможности,
  унифицирован с TProxySocket
}
unit AsyncSock;

interface
uses Classes, SysUtils, ExtCtrls, BlckSock, ssl_openssl;

type
  TReaderCmd = (rcNone, rcConnect, rcSSLConnect, rcDisconnect, rcListen,
    rcRead, rcEvent, rcError);
  TSocketEvent = (seLookup, seConnecting, seConnect, seDisconnect, seListen,
    seAccept, seWrite, seRead);
  TErrorEvent = (eeGeneral, eeSend, eeReceive, eeConnect, eeDisconnect,
    eeAccept, eeLookup);
  TSocketEventEvent = procedure (Sender: TObject; Socket: TTCPBlockSocket;
    SocketEvent: TSocketEvent) of object;
  TSocketErrorEvent = procedure (Sender: TObject; Socket: TTCPBlockSocket;
    ErrorEvent: TErrorEvent; ErrorMsg: string) of object;

  TReaderThread = class(TThread)
  private
    NewSocket: integer;
    Socket: TTCPBlockSocket;
    LocalCmd: TReaderCmd;
    AEvent: TSocketEvent;
    AError: TErrorEvent;
    AErrorCode: integer;
    AErrorMsg: string;
    FOnSocketEvent: TSocketEventEvent;
    FOnErrorEvent: TSocketErrorEvent;
    procedure SyncProc();
    procedure Event(Event: TSocketEvent);
    procedure Error(Error: TErrorEvent);
  public
    Host: string;
    Port: string;
    Cmd: TReaderCmd;
    UseSSL: boolean;
    constructor Create(ASocket: TTCPBlockSocket);
    property OnSocketEvent: TSocketEventEvent read FOnSocketEvent write FOnSocketEvent;
    property OnErrorEvent: TSocketErrorEvent read FOnErrorEvent write FOnErrorEvent;
  protected
    procedure Execute(); override;
  end;

  TAsyncSock = class(TObject)
  private
    SSLType: string;
    Socket: TTCPBlockSocket;
    Reader: TReaderThread;
    Timer: TTimer;
    FTimeout: integer;
    FConnected: boolean;
    FOnSocketEvent: TSocketEventEvent;
    FOnErrorEvent: TSocketErrorEvent;
    procedure Event(Sender: TObject; Socket: TTCPBlockSocket; SocketEvent: TSocketEvent);
    procedure Error(Sender: TObject; Socket: TTCPBlockSocket; ErrorEvent: TErrorEvent; ErrorMsg: string);
  public
    constructor Create();
    destructor Destroy(); override;
    procedure SetSSL(sType, sUser, sPass, sKeyPass: string);
    procedure SetProxy(PrType: string; PrHost, PrPort, PrUser, PrPass: string);
    procedure Open(const Host, Port: string);
    procedure Close();
    function Listen(const Host, Port: string): boolean;
    function GetLastErrorStr(): string;
    property OnSocketEvent: TSocketEventEvent read FOnSocketEvent write FOnSocketEvent;
    property OnErrorEvent: TSocketErrorEvent read FOnErrorEvent write FOnErrorEvent;
    function ReceiveLength(): integer;
    function ReceiveBuf(var Buf; Count: Integer): Integer;
    function ReceiveText: string;
    function SendBuf(var Buf; Count: Integer): Integer;
    function SendText(const S: string): Integer;
    function LocalAddress(): string;
    function RemoteAddress(): string;
    property Connected: boolean read FConnected;
    property Timeout: integer read FTimeout write FTimeout;
  end;

var
  sSocketConnectError:string = 'Не удалось подключиться к серверу.';
  sSocketGeneralError:string = 'Ошибка соединения.';
  sSocketSendError:string = 'Не удалось отправить данные на сервер.';
  sSocketReceiveError:string = 'Не удалось принять данные с сервера.';
  sSocketOtherError:string = 'Ошибка сокета.';
  sHttpProxyError:string = 'Ошибка HTTP прокси';
  sSocks4ProxyError:string = 'Ошибка SOCKS4 прокси';
  sSocks5ProxyError:string = 'Ошибка SOCKS5 прокси';

  sSocketLookup:string = 'Определяем адрес сервера.';
  sSocketConnecting:string = 'Подключаемся к серверу.';
  sSocketConnect:string = 'Подключились к серверу.';

implementation

// === TReaderThread ===
constructor TReaderThread.Create(ASocket: TTCPBlockSocket);
begin
  inherited Create(true);
  self.Cmd:=rcNone;
  self.LocalCmd:=rcNone;
  self.Socket:=ASocket;
  self.Resume();
end;

procedure TReaderThread.Execute();
begin
  while (not Terminated) do
  begin
    if Cmd=rcConnect then
    begin
      Cmd:=rcNone;
      Event(seConnecting);

      Socket.Connect(Host, Port);

      if Socket.LastError<>0 then
      begin
        Error(eeConnect);
        Continue;
      end;

      if UseSSL then
      begin
        // SSL connect
        Socket.SSLDoConnect();
        if Socket.LastError<>0 then
        begin
          Error(eeConnect);
          Continue;
        end;
      end;

      Event(seConnect);
      Cmd:=rcRead;
    end

    else if Cmd=rcListen then
    begin
      Cmd:=rcNone;
      Event(seConnecting);

      Socket.Bind(Host, Port);
      Socket.Listen();

      if Socket.LastError<>0 then
      begin
        Error(eeGeneral);
      end;

      NewSocket:=Socket.Accept();
      //
    end

    else if Cmd=rcDisconnect then
    begin
      Cmd:=rcNone;
      Event(seDisconnect);

      Socket.CloseSocket();

      if Socket.LastError<>0 then
      begin
        Error(eeDisconnect);
      end;
    end

    else if Cmd=rcRead then
    begin
      if Socket.CanRead(1) then
      begin
        Event(seRead);
      end;

      if Socket.LastError<>0 then
      begin
        Error(eeReceive);
        Cmd:=rcNone;
      end;
    end;

    Sleep(1);
  end;
end;

procedure TReaderThread.SyncProc();
begin
  if LocalCmd=rcEvent then
  begin
    if Assigned(self.FOnSocketEvent) then FOnSocketEvent(self, Socket, AEvent);
  end
  else if LocalCmd=rcError then
  begin
    if Assigned(self.FOnErrorEvent) then FOnErrorEvent(self, Socket, AError, AErrorMsg);
  end;
end;

procedure TReaderThread.Event(Event: TSocketEvent);
begin
  LocalCmd:=rcEvent;
  AEvent:=Event;
  Synchronize(SyncProc);
end;

procedure TReaderThread.Error(Error: TErrorEvent);
begin
  LocalCmd:=rcError;
  AError:=Error;
  AErrorCode:=Socket.LastError;
  AErrorMsg:=Socket.GetErrorDescEx();
  Synchronize(SyncProc);
  Socket.CloseSocket();
end;

// === TAsyncSock ===
constructor TAsyncSock.Create();
begin
  FConnected:=false;
  SSLType:='';
  Socket:=TTCPBlockSocket.CreateWithSSL(TSSLOpenSSL);
  Reader:=TReaderThread.Create(Socket);
  //Timer:=TTimer.
  Reader.OnSocketEvent:=Event;
  Reader.OnErrorEvent:=Error;
end;

destructor TAsyncSock.Destroy();
begin
  Reader.Free();
  Socket.Free();
  inherited Destroy();
end;

{function TAsyncSock.OnSocketEvent(Socket: TTCPBlockSocket; SocketEvent: TSocketEvent): boolean;
begin
  self.Event(Socket, SocketEvent);
end;

function TAsyncSock.OnSocketError(Socket: TTCPBlockSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer): boolean;
begin
  self.Error(Socket, ErrorEvent, ErrorCode);
end;}

procedure TAsyncSock.SetSSL(sType, sUser, sPass, sKeyPass: string);
var
  UseSSL: boolean;
begin
  UseSSL:=true;
  Socket.SSL.Username:=sUser;
  Socket.SSL.Password:=sPass;
  Socket.SSL.KeyPassword:=sKeyPass;
  self.SSLType:=sType;
  if (sType='ALL') or (sType='AUTO') then Socket.SSL.SSLType:=LT_all
  else if sType='SSLv2' then Socket.SSL.SSLType:=LT_SSLv2
  else if sType='SSLv3' then Socket.SSL.SSLType:=LT_SSLv3
  else if sType='TLSv1' then Socket.SSL.SSLType:=LT_TLSv1
  else if sType='TLSv1.1' then Socket.SSL.SSLType:=LT_TLSv1_1
  else if sType='SSHv2' then Socket.SSL.SSLType:=LT_SSHv2
  else
  begin
    UseSSL:=false;
  end;
  Reader.UseSSL:=UseSSL;
end;

procedure TAsyncSock.SetProxy(PrType: string; PrHost, PrPort, PrUser, PrPass: string);
var
  st: string;
begin
  st:=UpperCase(PrType);
  if (PrType='') or (PrType='NONE') then
  begin
    Socket.SocksIP:='';
    Socket.HTTPTunnelIP:='';
  end
  else if (PrType='HTTP') or (PrType='HTTPS') then
  begin
    Socket.SocksIP:='';
    Socket.HTTPTunnelIP:=PrHost;
    Socket.HTTPTunnelPort:=PrPort;
    Socket.HTTPTunnelUser:=PrUser;
    Socket.HTTPTunnelPass:=PrPass;
  end
  else if (PrType='SOCKS4') or (PrType='SOCKS5') then
  begin
    Socket.HTTPTunnelIP:='';
    Socket.SocksIP:=PrHost;
    Socket.SocksPort:=PrPort;
    Socket.SocksUsername:=PrUser;
    Socket.SocksPassword:=PrPass;
    if PrType='SOCKS4' then Socket.SocksType:=ST_Socks4;
    if PrType='SOCKS5' then Socket.SocksType:=ST_Socks5;
  end;
end;

procedure TAsyncSock.Open(const Host, Port: string);
begin
  Reader.Host:=Host;
  Reader.Port:=Port;
  Reader.Cmd:=rcConnect;
end;

function TAsyncSock.Listen(const Host, Port: string): boolean;
begin
  Reader.Host:=Host;
  Reader.Port:=Port;
  Reader.Cmd:=rcListen;
  Result:=True;
end;

procedure TAsyncSock.Close();
begin
  if FConnected then Reader.Cmd:=rcDisconnect;
end;

procedure TAsyncSock.Event(Sender: TObject; Socket: TTCPBlockSocket; SocketEvent: TSocketEvent);
begin
  if SocketEvent = seConnect then FConnected:=true
  else if SocketEvent = seDisconnect then FConnected:=false;

  if Assigned(self.FOnSocketEvent) then FOnSocketEvent(self, Socket, SocketEvent);
end;

procedure TAsyncSock.Error(Sender: TObject; Socket: TTCPBlockSocket; ErrorEvent: TErrorEvent; ErrorMsg: string);
begin
  FConnected:=false;
  if Assigned(self.FOnErrorEvent) then FOnErrorEvent(self, Socket, ErrorEvent, ErrorMsg);
end;

function TAsyncSock.GetLastErrorStr(): string;
begin
  result:=Socket.GetErrorDescEx();
end;

function TAsyncSock.ReceiveLength(): integer;
begin
  result:=Socket.WaitingData();
end;

function TAsyncSock.ReceiveBuf(var Buf; Count: Integer): Integer;
begin
  result:=Socket.RecvBuffer(@Buf, Count);
end;

function TAsyncSock.ReceiveText: string;
begin
  result:=Socket.RecvPacket(1);
end;

function TAsyncSock.SendBuf(var Buf; Count: Integer): Integer;
begin
  result:=Socket.SendBuffer(@Buf, Count);
end;

function TAsyncSock.SendText(const S: string): Integer;
begin
  Socket.SendString(S);
  result:=Length(S);
end;

function TAsyncSock.LocalAddress(): string;
begin
  //result:=Socket.LocalName();
  result:=Socket.GetLocalSinIP();
end;

function TAsyncSock.RemoteAddress(): string;
begin
  result:=Socket.GetRemoteSinIP();
end;


end.
