{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  Основной обьект модуля - мнеджер DCC соединений SockMan: TSockManager;
  Он создает входящие/исходящие соединения, а также удаляет заданые или неактивные
  соединения. Поскольку он не обьявлен в интерфейсе, использовать его напрямую
  из других модулей нельзя.

  Для входящих/исходящих соединений существуют отдельные классы, содержащие
  информацию о соединении (TConnInfo). Файлы представлены классом TDCCFile,
  содержащем подробную информацию о файле, включая поток самого файла.
  Файлы организованы в список файлов, который выдает конкретный файл по его
  идентификатору ID.

  Замечания:
  - Для TInSock и TOutSock описаны деструкторы, хотя они наверное и не нужны.
  - надо проверить прием файлов, содержащих в имени пробел (все имя взято в кавычки).
  - не реализована проверка принимаемой от удаленной стороны позиции файла
   (при отправке файла).
}
unit DCC;

interface
uses
  SysUtils, Classes, Forms, Contnrs, Windows, Core, Misc, ScktComp, WinSock,
  Dialogs;

procedure DCC_Start(sClientNick, sInfo: string; ChatClient: TChatClient);
procedure DCC_Stop(sClientNick: string; ID: integer = -1);
procedure DCC_Say(sNick, sText: string);
procedure DCC_CheckAlive();

const DCC_DefaultPort = 2200;
const DCC_RecvBufferSize = 4096;
const DCC_SendBufferSize = 4096;

type
  TDCCFile = class (TObject)
  public
    Name: string;
    FullName: string;
    Size: integer;
    FullSize: integer;
    Pos: integer;
    fs: TFileStream;
    id: integer;
    RemoteUserNick: string;
    Incoming: boolean;
    Active: boolean;
    Completed: boolean;
    PercCompleted: double;
    StartTime: double;
    EndTime: double;
    CPS: integer;
    destructor Destroy; override;
  end;

  TFileRec = record
    Name: string;
    FullName: string;
    Size: integer;
    FullSize: integer;
    Pos: integer;
    fs: TFileStream;
    id: integer;
    RemoteUserNick: string;
    Incoming: boolean;
    Active: boolean;
    Completed: boolean;
    PercCompleted: double;
    StartTime: double;
    EndTime: double;
    CPS: integer;
  end;

  TDCCFiles = class (TObjectList)
  public
    function GetNewID: integer;
    function GetByID(ID: integer): TDCCFile;
  end;

  TConnMode = set of (dcc_chat, dcc_send);
  TConnInfo = record
    ChatClient: TChatClient;
    sClientNick: string;
    sClientIP: string;
    sClientPort: string;
    sClientHost: string;
    ClientMode: TConnMode;
    sFileName: string;
    FilePos: longint;
    FileSize: longint;
    ID: integer;
    PageID: integer;
  end;

  TSockManager = class (TObjectList)
    procedure OpenServerConnection(sAddr: string; var sPort: string; ConInf: TConnInfo);
    procedure ModifyServerConnection(ConInf: TConnInfo);
    procedure OpenClientConnection(ConInf: TConnInfo);
    procedure CloseConnection(ConInf: TConnInfo);
    procedure CloseInactiveLinks();
  end;

var
  SockMan: TSockManager;
  //sDlPath: string = '\Incoming\';

procedure DCC_OpenDCCFileConn(ConInf: TConnInfo);

var
  UlFile: TFileRec;
  DlFile: TFileRec;
  DCCFiles: TDCCFiles;

implementation
uses Timer, DCC_FileAccept, ChatPage, Sounds;

type
  TInSock = class (TServerSocket)
  public
    ConnInfo: TConnInfo;
    IdleTime: integer;
    constructor Create(AOwner: TComponent); override;
    //destructor Destroy; override;
  private
    procedure EvOnClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure EvOnClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure EvOnClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure EvOnClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  end;

  TOutSock = class (TClientSocket)
  public
    ConnInfo: TConnInfo;
    IdleTime: integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  private
    procedure EvOnConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure EvOnRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure EvOnDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure EvOnError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  end;


procedure CreatePrivateChatTab(var ConnInfo: TConnInfo); forward;
procedure PostPrivateText(ConnInfo: TConnInfo; sText: string); forward;

procedure ShowDCCText(ConnInf: TConnInfo; PageID: integer; sText: string);
begin
  if Assigned(ConnInf.ChatClient) then
  begin
    ConnInf.ChatClient.ShowText(PageID, sText);
    Exit;
  end;
  Core.ParseIRCTextByPageID(PageID, sText);
end;

// ==== { TDCCFile }
destructor TDCCFile.Destroy;
begin
  fs.Free;
  fs:=nil;
  inherited Destroy;
end;

// ==== { TDCCFiles }
function TDCCFiles.GetNewID: integer;
var i: integer;
begin
  result:=0;
  for i:=0 to Count-1 do
    if (Items[i] as TDCCFile).id > result then result:=(Items[i] as TDCCFile).id;
  Inc(result);
end;

function TDCCFiles.GetByID(ID: integer): TDCCFile;
var i: integer;
begin
  result:=nil;
  for i:=0 to Count-1 do
    if (Items[i] as TDCCFile).id = ID then
    begin
      result:=(Items[i] as TDCCFile);
      Exit;
    end;
end;

// ==== Методы менеджера сокетов
procedure TSockManager.OpenServerConnection(sAddr: string; var sPort: string; ConInf: TConnInfo);
var
  i, n, nm: integer;
  DCCFile: TDCCFile;
begin
  n:=0;
  for i:=0 to Count-1 do
  begin
    if Items[i] is TInSock then
    begin
      if (ConInf.ClientMode=[dcc_chat]) and ((Items[i] as TInSock).ConnInfo.sClientNick=ConInf.sClientNick) then Exit;
      Inc(n);
    end;
  end;

  i:=Add(TInSock.Create(Application));
  with (Items[i] as TInSock) do
  begin
    nm:=n+4;
    ConnInfo:=ConInf;
    if ConnInfo.ClientMode=[dcc_send] then
    begin
      DCCFile:=TDCCFile.Create;
      DCCFile.Incoming:=false;
      DCCFile.Name:=ExtractFilename(ConnInfo.sFileName);
      DCCFile.FullSize:=ConnInfo.FileSize;
      DCCFile.FullName:=ConnInfo.sFileName;
      DCCFile.RemoteUserNick:=ConnInfo.sClientNick;
      DCCFile.id:=DCCFiles.GetNewID;
      ConnInfo.ID:=DCCFile.id;
      //ParseIRCText(TimeTemplate+#3+'07 '+'ID='+IntToStr(ConnInfo.ID), -1);

      DCCFiles.Add(DCCFile);
    end;

    while n < nm do
    begin
      Port:=StrToIntDef(sPort, DCC_DefaultPort)+n;
      try
        ResetTimer(TC_DCCQuery);
        Open;
      except
        Inc(n);
      end;
      if Active then
      begin
        //DisableTimer(TC_DCCQuery);
        n:=maxint;
        sPort:=IntToStr(Port);
        ConnInfo.sClientPort:=sPort;
      end;
    end;
  end;
end;

procedure TSockManager.ModifyServerConnection(ConInf: TConnInfo);
var
  i: integer;
  DeleteIt: boolean;
  ins: TInSock;
begin
  for i:=0 to Count-1 do
  begin
    if Items[i] is TInSock then
    begin
      ins:=(Items[i] as TInSock);
      if (ins.ConnInfo.ClientMode = ConInf.ClientMode)
      and (ins.ConnInfo.sClientNick = ConInf.sClientNick)
      and (ins.ConnInfo.sClientPort = ConInf.sClientPort)
      then
        ins.ConnInfo.FilePos := ConInf.FilePos;
    end;
  end;
end;

procedure TSockManager.OpenClientConnection(ConInf: TConnInfo);
var
  i: integer;
  DCCFile: TDCCFile;
begin
  i:=Add(TOutSock.Create(Application));
  with (Items[i] as TOutSock) do
  begin
    IdleTime:=0;
    ConnInfo:=ConInf;
    Address:=ConInf.sClientIP;
    Port:=StrToIntDef(ConInf.sClientPort,0);
    if Port=0 then
    begin
      ShowDCCText(ConInf, 0, #2+#3+'04'+TimeTemplate()+' Ошибка входящего соединения DCC: Некорректный номер порта - '+ConInf.sClientPort);
      Exit;
    end;
    if ConnInfo.ClientMode=[dcc_send] then
    begin
      DCCFile:=TDCCFile.Create;
      DCCFile.Incoming:=true;
      DCCFile.Name:=ExtractFileName(ConnInfo.sFileName);
      DCCFile.FullSize:=ConnInfo.FileSize;
      DCCFile.FullName:=ConnInfo.sFileName;
      DCCFile.RemoteUserNick:=ConnInfo.sClientNick;
      DCCFile.id:=DCCFiles.GetNewID;
      ConnInfo.ID:=DCCFile.id;

      DCCFiles.Add(DCCFile);
    end;
    DisableTimer(TC_DCCQuery);
    Open;
  end;
end;

procedure TSockManager.CloseConnection(ConInf: TConnInfo);
var
  i: integer;
  DeleteIt: boolean;
begin
  for i:=Count-1 downto 0 do
  begin
    DeleteIt:=false;
    if Items[i] is TInSock then
      with (Items[i] as TInSock) do
        if (ConnInfo.ClientMode = ConInf.ClientMode)
        and (ConnInfo.sClientNick = ConInf.sClientNick)
        and (((ConInf.ID>=0) and (ConnInfo.ID=ConInf.ID)) or (ConInf.ID<0))
        then
          DeleteIt:=true;
    if Items[i] is TOutSock then
      with (Items[i] as TOutSock) do
        if (ConnInfo.ClientMode = ConInf.ClientMode)
        and (ConnInfo.sClientNick = ConInf.sClientNick)
        and (((ConInf.ID>=0) and (ConnInfo.ID=ConInf.ID)) or (ConInf.ID<0))
        then DeleteIt:=true;
    if DeleteIt then Delete(i);
  end;
end;

procedure TSockManager.CloseInactiveLinks();
var
  i: integer;
  DeleteIt: boolean;
begin
  for i:=Count-1 downto 0 do
  begin
    DeleteIt:=false;
    if Items[i] is TInSock then
      with (Items[i] as TInSock) do
      begin
        if not Active then DeleteIt:=true;
        if IdleTime>StrToIntDef(ConnInfo.ChatClient.GetOption('DCCIdle'), 60) then DeleteIt:=true;
        if IdleTime>=0 then Inc(IdleTime);
      end;
    if Items[i] is TOutSock then
      with (Items[i] as TOutSock) do
      begin
        if not Active then DeleteIt:=true;
        if IdleTime > StrToIntDef(ConnInfo.ChatClient.GetOption('DCCIdle'), 60) then DeleteIt:=true;
        if IdleTime>=0 then Inc(IdleTime);
      end;
    if DeleteIt then Delete(i);
  end;
end;

// ==== Методы входящих сокетов
procedure TInSock.EvOnClientConnect(Sender: TObject; Socket: TCustomWinSocket);
var
  buf: array[1..DCC_SendBufferSize] of byte;
  i: integer;
begin
  //Socket.SendText('101 '+strNick+#10);
  DisableTimer(TC_DCCQuery);

  if ConnInfo.ClientMode = [dcc_chat] then
  begin
    IdleTime:=-1;
    CreatePrivateChatTab(ConnInfo);
    ShowDCCText(ConnInfo, ConnInfo.PageID, TimeTemplate()+#3+'07 '+#2+ConnInfo.sClientNick+#2+' ('+Socket.RemoteHost+') присоединился.');
   end;

  if ConnInfo.ClientMode = [dcc_send] then
  begin
    ShowDCCText(ConnInfo, 0, TimeTemplate()+#3+'07 '+#2+ConnInfo.sClientNick+#2+' ('+Socket.RemoteHost+') присоединился для DCC SEND.');
    IdleTime:=0;
    with DCCFiles.GetByID(ConnInfo.ID) do
    begin
      fs:=TFileStream.Create(FullName, fmOpenRead);
      fs.Position:=ConnInfo.FilePos;
      Active:=True;
      StartTime:=Now;
      Completed:=False;

      i:=fs.Read(buf, SizeOf(buf));
      Pos:=fs.Position;
      Size:=Pos;
      Socket.SendBuf(buf, i);
    end;
  end;
end;

procedure TInSock.EvOnClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if ConnInfo.ClientMode = [dcc_chat] then
  begin
    if Assigned(ConnInfo.ChatClient) then
      ShowDCCText(ConnInfo, ConnInfo.PageID, TimeTemplate()+#3+'07 '+#2+ConnInfo.sClientNick+#2+' отсоединился.');
  end;

  if ConnInfo.ClientMode = [dcc_send] then
  begin
    ShowDCCText(ConnInfo, 0, TimeTemplate()+#3+'07 '+#2+ConnInfo.sClientNick+#2+' отсоединился (DCC SEND).');
    with DCCFiles.GetByID(ConnInfo.ID) do
    begin
      Active:=false;
      if FullSize=Size then Completed:=true;
      fs.Free;
      fs:=nil;
    end;
  end;
  Close;
end;

procedure TInSock.EvOnClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  buf: array[1..DCC_SendBufferSize] of byte;
  i: integer;
  //txt: string;
begin
  if ConnInfo.ClientMode = [dcc_chat] then
  begin
    PostPrivateText(ConnInfo, Socket.ReceiveText);
  end;

  if ConnInfo.ClientMode = [dcc_send] then
  begin
    with DCCFiles.GetByID(ConnInfo.ID) do
    begin
      IdleTime:=0;
      // принимаем число всего принятых байтов
      //DebugInfo(Socket.ReceiveText);
      //txt:=Socket.ReceiveText;
      i:=Socket.ReceiveBuf(buf, SizeOf(Buf));
      //ParseIRCText('Received '+IntToStr(i), ReturnChanIndex(csDebugTabName));

      i:=fs.Read(buf, SizeOf(buf));
      Pos:=fs.Position;
      Size:=fs.Position;
      Socket.SendBuf(buf, i);
      if Pos>=FullSize then
      begin
        fs.Free;
        fs:=nil;
        Self.Close;
      end;
    end;
  end;
end;

procedure TInSock.EvOnClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  if ConnInfo.ClientMode = [dcc_chat] then
  begin
    ShowDCCText(ConnInfo, ConnInfo.PageID, #2+#3+'04'+TimeTemplate()+' Ошибка входящего соединения DCC Chat: ' + GetSocketErrorDescription(ErrorCode));
  end;
  if ConnInfo.ClientMode = [dcc_send] then
  begin
    with DCCFiles.GetByID(ConnInfo.ID) do
    begin
      Active:=false;
      if FullSize=Size then Completed:=true;
      fs.Free;
      fs:=nil;
    end;
    ShowDCCText(ConnInfo, 0, #2+#3+'04'+TimeTemplate+' Ошибка входящего соединения DCC Send: ' + GetSocketErrorDescription(ErrorCode));
  end;
  Close;
  ErrorCode:=0;
end;

constructor TInSock.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //Port := 1025;
  ServerType := stNonBlocking;
  OnClientConnect := EvOnClientConnect;
  OnClientRead := EvOnClientRead;
  OnClientDisconnect := EvOnClientDisconnect;
  OnClientError := EvOnClientError;
end;

{destructor TInSock.Destroy;
begin
  Close;
  OnClientConnect := nil;
  OnClientRead := nil;
  OnClientDisconnect := nil;
  OnClientError := nil;
  inherited Destroy;
end;}

// ==== Методы исходящих сокетов
procedure TOutSock.EvOnConnect(Sender: TObject; Socket: TCustomWinSocket);
var
  i: integer;
  found: boolean;
begin
  //Socket.SendText('101 '+strNick+#10);
  DisableTimer(TC_DCCQuery);

  if ConnInfo.ClientMode = [dcc_chat] then
  begin
    IdleTime:=-1;
    CreatePrivateChatTab(ConnInfo);
    ShowDCCText(ConnInfo, ConnInfo.PageID, TimeTemplate()+#3+'07 '+#2+ConnInfo.sClientNick+#2+' ('+Socket.RemoteHost+') присоединился.');
  end;

  if ConnInfo.ClientMode = [dcc_send] then
  begin
    IdleTime:=0;
    with DCCFiles.GetByID(ConnInfo.ID) do
    begin
      if not DirectoryExists(ExtractFilePath(FullName)) then
        if not CreateDir(ExtractFilePath(FullName)) then
          raise Exception.Create('Cannot create '+ExtractFilePath(FullName));
      fs:=TFileStream.Create(FullName, fmCreate);
      Pos:=fs.Position;
      Active:=True;
      StartTime:=Now;
      Completed:=False;
    end;
  end;
end;

procedure TOutSock.EvOnDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if ConnInfo.ClientMode = [dcc_chat] then
  begin
    if Assigned(ConnInfo.ChatClient) then
      ShowDCCText(ConnInfo, ConnInfo.PageID, TimeTemplate()+#3+'07 '+#2+ConnInfo.sClientNick+#2+' отсоединился.');
  end;

  if ConnInfo.ClientMode = [dcc_send] then
  begin
    with DCCFiles.GetByID(ConnInfo.ID) do
    begin
      Active:=false;
      if FullSize=Size then Completed:=true;
      fs.Free;
      fs:=nil;
    end;
  end;
end;

procedure TOutSock.EvOnRead(Sender: TObject; Socket: TCustomWinSocket);
var
  buf: array [1..DCC_RecvBufferSize] of byte;
  buf2: array[1..4] of byte;
  i, i2: integer;
  n: Longword;
begin
  if ConnInfo.ClientMode = [dcc_chat] then
  begin
    PostPrivateText(ConnInfo, Socket.ReceiveText);
  end;

  if ConnInfo.ClientMode = [dcc_send] then
  begin
    IdleTime:=0;
    with DCCFiles.GetByID(ConnInfo.ID) do
    begin
      i2:=0;
      While Socket.ReceiveLength > i2 do
      begin
        try
          i:=Socket.ReceiveBuf(buf, SizeOf(buf));
        except
          i:=0;
          i2:=maxint;
        end;
        if i>0 then
        begin
          Inc(i2, i);
          if i>0 then fs.Write(buf, i);
          Pos:=fs.Position;
          Size:=fs.Size;
        end
        else i2:=maxint;
      end;
      // после каждого принятого куска данных нужно посылать ответ в виде
      // 4-байтного размера принятых данных с начала приема.
      n:=Longword(Size);
      for i:=1 to 4 do
      begin
        buf2[4-i+1]:=Byte(n);
        n:=n shr 8;
      end;
      Socket.SendBuf(buf2, SizeOf(buf2));
      if Size=FullSize then Socket.Close;
    end;
  end;
end;

procedure TOutSock.EvOnError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  if ConnInfo.ClientMode = [dcc_chat] then
  begin
    ShowDCCText(ConnInfo, ConnInfo.PageID, #2+#3+'04'+TimeTemplate+' Ошибка исходящего соединения DCC Chat: ' + GetSocketErrorDescription(ErrorCode));
  end;

  if ConnInfo.ClientMode = [dcc_send] then
  begin
    with DCCFiles.GetByID(ConnInfo.ID) do
    begin
      ShowDCCText(ConnInfo, 0, #2+#3+'04'+TimeTemplate()+' Ошибка исходящего соединения DCC Send: ' + GetSocketErrorDescription(ErrorCode));
      Active:=false;
      if FullSize=Size then Completed:=true;
      fs.Free;
      fs:=nil;
    end;
  end;
  ErrorCode:=0;
end;

constructor TOutSock.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ClientType := ctNonBlocking;
  OnConnect := EvOnConnect;
  OnRead := EvOnRead;
  OnDisconnect := EvOnDisconnect;
  OnError := EvOnError;
end;

destructor TOutSock.Destroy;
begin
  Close;
  inherited Destroy;
end;

// ==== Общие процедуры для событий сокетов
procedure CreatePrivateChatTab(var ConnInfo: TConnInfo);
var
  i: integer;
  PageInfo: TPageInfo;
begin
  if ConnInfo.PageID > 0 then Exit;
  if not Assigned(PagesManager) then Exit;
  Core.ClearPageInfo(PageInfo);
  PageInfo.sServer:=ConnInfo.sClientHost;
  PageInfo.sNick:=ConnInfo.sClientNick;
  PageInfo.sMode:='DCC CHAT';
  PageInfo.Caption:='>>'+ConnInfo.sClientNick;
  PageInfo.ImageIndex:=3;
  PageInfo.ImageIndexDefault:=7;
  i:=PagesManager.CreatePage(PageInfo);
  ConnInfo.PageID:=i;
  ConnInfo.ChatClient.ModifyPagesList(i, 1);
  Core.AddNicks(i, ConnInfo.sClientNick+' '+ConnInfo.ChatClient.GetOption('MyNick'));
end;

procedure PostPrivateText(ConnInfo: TConnInfo; sText: string);
begin
  while (sText[Length(sText)]=#10)
  or (sText[Length(sText)]=#13)
  do
    sText:=Copy(sText,1, Length(sText)-1);

  ShowDCCText(ConnInfo, ConnInfo.PageID, #3+'05'+TimeTemplate()+'<'+ConnInfo.sClientNick+'> '+sText);
end;

procedure MakeFilesTabVisible();
begin
  if not Assigned(PagesManager) then Exit;
  PagesManager.ActivatePage(ciFilesPageID);
end;

// ==== Глобальные процедуры работы с DCC
procedure DCC_Start(sClientNick: string; sInfo: string; ChatClient: TChatClient);
var
  StrArr: TStringArray;
  sIP, sPort, sHost: string;
  i,l: integer;
  ConInf: TConnInfo;
  DCCAcceptForm: TDCCFileAccept;

  OpenDialog1: TOpenDialog;
  sFileName, sFileSize: string;
  fs: TFileStream;
begin
  // !!! Если имя файла в кавычках, то игнорируем (надо исправить!!!)
  // Исправлено. Надо проверить.
  //if Pos(sInfo, '"')>0 then Exit;

  // !!! ChatClient может быть = nil

  ConInf.PageID:=0;
  ConInf.ChatClient:=ChatClient;

  //if SockMan = nil then SockMan:=TSockManager.Create(true);
  if sInfo='chat' then
  begin
    // исходящее соединение, открываем порт и ждем клиента
    sIP := IP2IntStr(ConInf.ChatClient.GetOption('LocalIP'));
    sPort := IntToStr(DCC_DefaultPort);
    ConInf.sClientNick:=sClientNick;
    ConInf.ClientMode:=[dcc_chat];
    SockMan.OpenServerConnection(sIP, sPort, ConInf);
    ChatClient.SendTextToServer('PRIVMSG '+sClientNick+' :'+#1+'DCC CHAT chat '+ sIP+' '+sPort+#1+#10);
    ChatClient.ShowText(-1, #3+'05'+TimeTemplate()+' Отправлен запрос на прямой чат c '+sClientNick+' (port='+sPort+')');
    Exit;
  end;

  if sInfo='send' then
  begin
    OpenDialog1:=TOpenDialog.Create(Core.MainForm);
    OpenDialog1.Title:='Выберите файл для отправки';
    if not OpenDialog1.Execute then Exit;
    sFileName := OpenDialog1.FileName;
    fs:=TFileStream.Create(sFileName, fmOpenRead);
    ConInf.FileSize:=fs.Size;
    fs.Free;

    // в sInfo строка вида: send
    // исходящее соединение, открываем порт и ждем клиента
    sIP := IP2IntStr(ConInf.ChatClient.GetOption('LocalIP'));
    sPort := IntToStr(DCC_DefaultPort);
    ConInf.sClientNick:=sClientNick;
    ConInf.ClientMode:=[dcc_send];
    ConInf.sFileName:=sFileName;
    SockMan.OpenServerConnection(sIP, sPort, ConInf);

    sFileName:=ExtractFilename(ConInf.sFileName);
    if Pos(' ', sFileName)>0 then sFileName:='"'+sFileName+'"';

    ChatClient.SendTextToServer('PRIVMSG '+sClientNick+' :'+#1+'DCC SEND '+sFileName+' '+ sIP+' '+sPort+' '+IntToStr(ConInf.FileSize)+#1+#10);
    ChatClient.ShowText(-1, #3+'05'+TimeTemplate()+' Отправлен запрос на отправку файла для '+sClientNick+' (port='+sPort+')');
    MakeFilesTabVisible;
    Exit;
  end;

  StrArr:=ParseStr(sInfo);
  l:=Length(StrArr);

  if StrArr[0]='resume' then
  begin
    // в sInfo строка вида: send <file_name> <file_size> [ID]
    // исходящее соединение, открываем порт и ждем клиента
    sIP := IP2IntStr(ConInf.ChatClient.GetOption('LocalIP'));
    sPort := IntToStr(DCC_DefaultPort);
    ConInf.sClientNick:=sClientNick;
    ConInf.ClientMode:=[dcc_send];
    ConInf.sFileName:=StrArr[1];
    ConInf.FileSize:=StrToIntDef(StrArr[2], 0);
    if l>3 then
    begin
      i:=StrToIntDef(StrArr[3],-1);
      if i>0 then ConInf.ID:=i;
    end;
    SockMan.OpenServerConnection(sIP, sPort, ConInf);
    ChatClient.SendTextToServer('PRIVMSG '+sClientNick+' :'+#1+'DCC SEND '+ExtractFilename(ConInf.sFileName)+' '+ sIP+' '+sPort+' '+StrArr[2]+#1+#10);
    ChatClient.ShowText(-1, #3+'05'+TimeTemplate()+' Отправлен запрос на продолжение файла для '+sClientNick+' (port='+sPort+')');
    MakeFilesTabVisible;
    Exit;
  end;

  // в sInfo строка вида:
  // DCC CHAT chat <ip_integer> <port>
  // DCC SEND <file_name> <ip_integer> <port> <file_size>
  // DCC RESUME <file_name> <port> <file_pos>
  if l<4 then Exit;
  //sHost:=inet_ntoa(Form1.ServerConnect.Socket.LookupName(sIP));
  if StrArr[3]='' then Exit;

  if StrArr[1] = 'CHAT' then
  begin
    ChatClient.ShowText(-1, #3+'05'+TimeTemplate()+' Принят запрос на прямой чат от '+sClientNick+'('+sIP+':'+sPort+')');
    Core.PlayNamedSound('sfxDccChat', ChatClient);

    ConInf.sClientNick:=sClientNick;
    ConInf.ClientMode:=[dcc_chat];
    ConInf.sClientIP:=IntStr2IP(StrArr[3]);
    ConInf.sClientPort:=StrArr[4];
    SockMan.OpenClientConnection(ConInf);
  end;

  if StrArr[1] = 'SEND' then
  begin
    ChatClient.ShowText(-1, #3+'05'+TimeTemplate()+' Принят запрос на прием файла от '+sClientNick+'('+sIP+':'+sPort+')');
    Core.PlayNamedSound('sfxDccFile', ChatClient);

    sIP:=IntStr2IP(StrArr[3]);
    sHost:=inet_ntoa(in_addr(inet_addr(PChar(sIP))));
    //if Application.MessageBox(PChar('Будем принимать файл?'), PChar('Будем принимать файл?'), MB_YESNO) <> 6 then Exit;
    ConInf.sClientNick:=sClientNick;
    ConInf.sClientIP:=sIP;
    ConInf.sClientPort:=StrArr[4];
    ConInf.sClientHost:=sHost;
    ConInf.ClientMode:=[dcc_send];
    ConInf.sFileName:=glUserPath+ChatClient.GetOption('SaveFilesDir')+StrArr[2];
    ConInf.FileSize:=StrToIntDef(StrArr[5], 0);
    DCCAcceptForm:=TDCCFileAccept.Create(Core.MainForm);
    DCCAcceptForm.ConnInfo:=ConInf;
    Core.olPrivWndList.Add(DCCAcceptForm);
    //DCCAcceptForm.BringToFront;
    DCCAcceptForm.Show;
    Exit;
    // по идее, это нужно запустить из DCCAcceptForm
    //SockMan.OpenClientConnection(sIP, sPort, ConInf);
    //MakeFilesTabVisible;
  end;

  if StrArr[1] = 'RESUME' then
  begin
    ChatClient.ShowText(-1, #3+'05'+TimeTemplate()+' Принят запрос на продолжение файла от '+sClientNick+'('+sIP+':'+sPort+')');
    Core.PlayNamedSound('sfxDccFile', ChatClient);
    ConInf.sClientNick:=sClientNick;
    ConInf.sClientPort:=StrArr[3];
    ConInf.ClientMode:=[dcc_send];
    ConInf.sFileName:=glUserPath+ChatClient.GetOption('SaveFilesDir')+StrArr[2];
    ConInf.FilePos:=StrToIntDef(StrArr[4], 0);

    SockMan.ModifyServerConnection(ConInf);
    MakeFilesTabVisible;
  end;
end;

procedure DCC_Stop(sClientNick: string; ID: integer=-1);
var
  ConInf: TConnInfo;
begin
  ConInf.sClientNick:=sClientNick;
  if ID<0 then
    ConInf.ClientMode:=[dcc_chat]
  else
    ConInf.ClientMode:=[dcc_send];
  ConInf.ID:=ID;
  SockMan.CloseConnection(ConInf);
end;

procedure DCC_Say(sNick, sText: string);
var
  i: integer;
begin
  //if SockMan = nil then Exit;
  for i:=0 to SockMan.Count-1 do
  begin
    if SockMan.Items[i] is TInSock then
      with (SockMan[i] as TInSock) do
      begin
        if (ConnInfo.ClientMode<>[dcc_chat]) or (ConnInfo.sClientNick <> sNick) then Continue;
        if Socket.ActiveConnections > 0 then Socket.Connections[0].SendText(sText+#10);
      end;
    if SockMan.Items[i] is TOutSock then
      with (SockMan[i] as TOutSock) do
      begin
        if (ConnInfo.ClientMode<>[dcc_chat]) or (ConnInfo.sClientNick <> sNick) then Continue;
        Socket.SendText(sText+#10);
      end;
  end;
end;

procedure DCC_CheckAlive();
begin
  if not Assigned(SockMan) then Exit;
  SockMan.CloseInactiveLinks();
end;

procedure DCC_OpenDCCFileConn(ConInf: TConnInfo);
begin
  SockMan.OpenClientConnection(ConInf);
  MakeFilesTabVisible;
end;


initialization
  //SockMan:=TSockManager.Create(true);
finalization
  //SockMan.Free;
end.
