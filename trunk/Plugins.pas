{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  Модуль работы с плагинами

  TPlugin - базовый класс для плагинов. Содержит информацию о плагине,
  функции для передачи-приема сообщений и функции управления.

  TPluginDLL - реализация плагина, использующего динамическую библиотеку DLL

  TPluginCMD - реализация плагина, использующего исполнимый файл и STDIO

  TPluginManager - служит для управления списком плагинов и рассылки собщений
  всем плагинам.

}
unit Plugins;

interface
uses Types, StdCtrls, Contnrs, Classes, Windows, SysUtils, Forms, ComCtrls,
     Masks, SyncObjs, Configs;

type
  TPluginMsg = function(MsgText: PChar): PChar; stdcall;

type
  TPlugin = class(TThread)
  public
    Name: string;
    Desc: string;
    Version: string;
    CmdList: string;
    ID: integer;
    OptionsBoxHandle: HWND;
    Conf: TConf;
    PagesIDCount: integer;
    PagesIDList: array of integer;
    Active: Boolean;
    // Передать команду в плагин
    procedure Say(MsgText: String); virtual; abstract;
    // Передать команду и сразу вернуть ответ
    function Ask(MsgText: String): String; virtual; abstract;
    // Проверка плагина
    function Test(): boolean; virtual; abstract;
    // Запуск плагина
    function Start(): boolean; virtual; abstract;
    // Останов плагина
    function Stop(): boolean; virtual; abstract;
    // Изменить список идентификаторов страниц
    procedure ModifyPagesList(PageID, Mode: integer);
    // Проверка наличия у плагина страницы с указанным ID
    function HavePageID(PageID: integer): boolean;
  end;

  TPluginDLL = class(TPlugin)
  public
    constructor Create(File_name: string; NewID: integer);
    destructor Destroy; override;
    procedure Say(MsgText: String); override;
    function Ask(MsgText: String): String; override;
    function Test(): boolean; override;
    function Start(): boolean; override;
    function Stop(): boolean; override;
  private
    Filename: string;
    Tested: boolean;
    AppHandle: THandle;
    LibHandle: THandle;
    PluginMsgFuncHandle: THandle;
    MsgFunc: TPluginMsg;
    LocalMsgFunc: TPluginMsg;
    Cmd: string;
    CmdResult: string;
    function FStart(): boolean;
    procedure FStop();
    procedure FWork();
    procedure FTest();
  protected
    procedure SyncSection();
    procedure Execute(); override;
  end;

type
  TPipeHandles = (IN_WRITE, IN_READ,
    OUT_WRITE, OUT_READ,
    ERR_WRITE, ERR_READ, TMP);
  TPipeArray = array[TPipeHandles] of THandle;

  TPluginCmdEvent = procedure(Text: string) of object;
  TPluginCmd = class(TPlugin)
  private
    { Private declarations }
    Pipes: TPipeArray;
    FProcInfo: TProcessInformation;
    FPluginEvent: TPluginCmdEvent;
    sText: string;
    Lock: boolean;
    AskMode: boolean;
    procedure SyncProc();
    function CreateChildProcess(FileName: string): boolean;
    function WriteToChild(Data: string; Timeout: Integer = 1000): Boolean;
    procedure CloseChildProc();
    function GetAnswer(s, sAnswerKey: string): string;
  public
    { Public declarations }
    constructor Create(FileName: string; NewID: integer);
    destructor Destroy(); override;
    procedure Say(Text: string); override;
    function Ask(Text: string): string; override;
    function Test(): boolean; override;
    function Start(): boolean; override;
    function Stop(): boolean; override;
    procedure Read(Text: string);
    property PluginEvent: TPluginCmdEvent read FPluginEvent write FPluginEvent;
  protected
    procedure Execute; override;
  end;

type
  TPluginsManager = class(TObjectList)
  public
    //MsgList: TThreadList;
    //Lock: TCriticalSection;
    procedure Start();
    procedure BroadcastMsg(MsgText: String);
    function GetNewID(): integer;
    function GetByID(ID: Integer): TPlugin;
    function AddPlugin(plug: TPlugin): integer;
    destructor Destroy; override;
  private
    LastID: integer;
  end;

//var
  //PlugMan: TPluginsManager; // менеджер плагинов
  //PluginsLock: TCriticalSection;
  //lvPluginsList: TListView; // Список плагинов

procedure InitPlugins();
procedure StopPlugins();
//procedure AddPagesForPlugins();

implementation
uses Core, Main, Misc, PluginsFunc, MainOptions;

function PluginCallback(Plugin: TPlugin; MsgText: PChar): PChar; stdcall; forward;
function PluginMsgFunc(id: DWORD; MsgText: PChar): PChar; stdcall; forward;
procedure FindPluginsFiles(StartFolder, Mask: string; sl: TStringList); forward;
function LockOn(var Lock: boolean): boolean; forward;
function LockOff(var Lock: boolean): boolean; forward;

//=== TPlugin ===================
procedure TPlugin.ModifyPagesList(PageID, Mode: integer);
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

function TPlugin.HavePageID(PageID: integer): boolean;
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

//=== TPluginManager ===================
procedure TPluginsManager.BroadcastMsg(MsgText: String);
var
  i: integer;
begin
  for i:=0 to self.Count-1 do
  begin
    (self[i] as TPlugin).Say(MsgText);
  end;
end;

function TPluginsManager.GetByID(ID: Integer): TPlugin;
var
  i: integer;
begin
  result:=nil;
  for i:=0 to self.Count-1 do
  begin
    if (Assigned(self[i])) and ((self[i] as TPlugin).ID = ID) then
    begin
      result:=(self[i] as TPlugin);
      exit;
    end;
  end;
end;

function TPluginsManager.AddPlugin(plug: TPlugin): integer;
var
  li: TListItem;
begin
  result:=self.Add(plug);
  // Добавим в визуальный список плагинов
  li:=frmMainOptions.lvPluginsList.Items.Add;
  li.Caption:=plug.Name;
  li.Data:=plug;
  li.SubItems.Add(plug.Desc);
  li.SubItems.Add(plug.Version);
end;

function TPluginsManager.GetNewID(): integer;
begin
  Inc(LastID);
  result:=LastID;
end;

procedure TPluginsManager.Start();
var
  NewPlugin: TPlugin;
  i: Integer;
  slp: TStringList;
  s: string;
  NewHWND: HWND;
begin
  // Ищем и добавляем плагины
  slp:=TStringList.Create();
  FindPluginsFiles(glHomePath+MainConf['PluginsPath'], '*.exe', slp);

  for i:=0 to slp.Count-1 do
  begin
    NewPlugin:= TPluginCmd.Create(slp[i], self.GetNewID());
    if not NewPlugin.Test() then
    begin
      NewPlugin.Free();
      Continue;
    end;
    self.AddPlugin(NewPlugin);

    // Создаем окошко опций для плагина
    //NewHWND:=AddPluginPage(ExtractFileName(slp[i]));
    //NewPlugin.OptionsBoxHandle:=NewHWND;

    // Запускаем плагин
    NewPlugin.Start();

  end;
  slp.Free();
end;

destructor TPluginsManager.Destroy;
var i: integer;
begin
  //for i:=0 to Count-1 do (Items[i] as TPlugin).Terminate();
  //sleep(10);
  self.BroadcastMsg('QUIT');
  inherited Destroy;
end;

//=== TPluginDLL =========================
function TPluginDLL.FStart(): boolean;
type
  TInit = function(hp, h, hcb, id: HWnd): DWord; stdcall;
var
  Init: TInit;
  i: integer;
begin
  result:=false;
  if not Tested then Exit;

  Init:=GetProcAddress(LibHandle, 'Init');

  PluginMsgFunc(ID, PChar('TEXT Initialize plugin '+Name+' ...'));
  try
    Init(AppHandle, OptionsBoxHandle, PluginMsgFuncHandle, ID);
  except
    Terminate();
    Exit;
    //Result:=UnLoadPlugin(LibHandle);
  end;
  //self.cbMemo.Lines.Add('started');
  PluginMsgFunc(ID, PChar('TEXT Plugin '+Name+' started'));
  result:=true;
end;

procedure TPluginDLL.FStop();
type
  TOutit = function: DWord; stdcall;
var
  Outit: TOutit;
begin
  if LibHandle=0 then Exit;
  PluginMsgFunc(ID, PChar('TEXT Stopping plugin '+Name+' ...'));
  Outit:=GetProcAddress(LibHandle, 'Outit');
  try
    if @Outit<>nil then Outit();
  finally
    MsgFunc:= nil;
    try
      FreeLibrary(LibHandle);
    finally
      LibHandle:=0;
    end;
  end;
  PluginMsgFunc(ID, PChar('TEXT Plugin '+Name+' stopped.'));
end;

procedure TPluginDLL.FWork();
begin
  //PluginMsgFunc(ID, PChar('TEXT working...'));
  Sleep(1);
  Application.ProcessMessages();
end;

procedure TPluginDLL.FTest();
begin
  Tested:=false;
  PluginMsgFunc(ID, PChar('TEXT Testing plugin '+Filename+' ...'));
  try
    //LibHandle:=LoadLibrary(PChar(Filename));
    LibHandle:=LoadLibraryEx(PChar(Filename), 0, DONT_RESOLVE_DLL_REFERENCES);
  except
    Exit;
  end;
  if LibHandle=0 then Exit;

  MsgFunc:=GetProcAddress(LibHandle, 'Msg');
  if (@MsgFunc <> nil) then Tested:=True;

  try
    FreeLibrary(LibHandle);
  finally
    LibHandle:=0;
    MsgFunc:=nil;
  end;
end;

constructor TPluginDLL.Create(File_name: string; NewID: integer);
begin
  inherited Create(true);
  Filename:=File_name;
  Name:=ExtractFileName(File_name);
  ID:=NewID;
  Tested:=false;

  PluginMsgFuncHandle:=Cardinal(@PluginMsgFunc);
  AppHandle:=Application.Handle;

  FTest();
  if (Tested = false) then Exit;

  try
    LibHandle:=LoadLibrary(PChar(Filename));
    //LibHandle:=LoadLibraryEx(PChar(Filename), 0, DONT_RESOLVE_DLL_REFERENCES);
  except
    Exit;
  end;
  if LibHandle=0 then Exit;

  MsgFunc:=GetProcAddress(LibHandle, 'Msg');
  if (@MsgFunc = nil) then Tested:=False;

  //Start();
end;

destructor TPluginDLL.Destroy;
begin
  //gbOptionsBox.Free();
  if PluginsManager <> nil then PluginsManager.Extract(self); // Extract() don't free already freed object
  inherited Destroy;
end;

function TPluginDLL.Ask(MsgText: String): String;
begin
  result:='';
  if Assigned(MsgFunc) then
  try
    result:=MsgFunc(PChar(MsgText));
  except
    //FreeLibrary(LibH1);
  end;
end;

procedure TPluginDLL.Say(MsgText: String);
begin
  if Assigned(MsgFunc) then
  try
    MsgFunc(PChar(MsgText));
  except
    //FreeLibrary(LibH1);
  end;
end;

procedure TPluginDLL.Execute();
begin
  FStart();
  while not Terminated do FWork();
  FStop();
end;

function TPluginDLL.Test(): boolean;
begin
  result:=Tested;
end;

function TPluginDLL.Start(): boolean;
begin
  result:=FStart();
end;

function TPluginDLL.Stop(): boolean;
begin
  result:=True;
  FStop();
end;

// Выполняется в основном потоке
procedure TPluginDLL.SyncSection();
begin
end;

//===================================================
// TPluginCmd
constructor TPluginCmd.Create(FileName: string; NewID: integer);
begin
  self.Name:=ExtractFileName(FileName);
  if not CreateChildProcess(FileName) then
    raise Exception.Create('PluginCmd Init Error');

  self.ID:=NewID;
  sText:='';
  Lock:=false;
  AskMode:=false;
  inherited Create(false);
end;

destructor TPluginCmd.Destroy();
begin
  Terminate();
  WaitFor();
  CloseChildProc();
  inherited Destroy();
end;

procedure TPluginCmd.Say(Text: string);
begin
  self.WriteToChild(Text);
  //result:=self.GetAnswer(Text);
end;

function TPluginCmd.Ask(Text: string): string;
begin
  //self.WriteToChild(Text);
  result:=self.GetAnswer(Text, '');
end;

procedure TPluginCmd.Read(Text: string);
var
  s: string;
begin
  //Core.DebugMessage('Plugin '+self.Name+': '+Text);
  s:=PluginsFunc.ParsePluginCmd(self, Text);
  self.WriteToChild(s);
  if Assigned(FPluginEvent) then FPluginEvent(Text);
end;

function TPluginCmd.Test(): boolean;
begin
  result:=false;
  self.Desc:=self.GetAnswer('GET_ABOUT', 'ABOUT');
  self.Version:=self.GetAnswer('GET_VERSION', 'VERSION');
  if Length(''+self.Desc+self.Version)=0 then Exit;
  result:=true;
end;

function TPluginCmd.Start(): boolean;
begin
  result:=self.WriteToChild('START');
end;

function TPluginCmd.Stop(): boolean;
begin
  result:=self.WriteToChild('STOP');
end;

procedure TPluginCmd.SyncProc();
var
  b: integer;
  sTmp: string;
begin
  // if text is multi-string, process strings separately
  //Core.DebugMessage('Plugin '+self.Name+' say: '+sText);
  b:=Pos(#13+#10, sText);
  while b>0 do
  begin
    sTmp:=Copy(sText, 1, b-1);
    Delete(sText, 1, b+1);

    self.Read(sTmp);
    b:=Pos(#13+#10, sText);
  end;
end;

function TPluginCmd.GetAnswer(s, sAnswerKey: string): string;
var
  i,n,m,b: integer;
  c: Char;
  sAnswer, sTmp: string;
begin
  result:='';
  // Reset sText to empty
  //if not LockOn(Lock) then Exit;
  //sText:='';
  //LockOff(Lock);

  {self.WriteToChild(s);
  result:='OK';
  Exit;}

  AskMode:=true;
  // Send string to child
  self.WriteToChild(s);
  i:=50;  // timeout, ms
  while i>0 do
  begin
    if LockOn(Lock) then
    begin
      n:=Length(sText);
      if n>0 then
      begin
        //c:=Copy(sText, n-1, 1)[1];
        //if (c=#10) or (c=#13) then // tail symbol is CR/LF
        begin
          // if text is multi-string, process strings separately
          b:=Pos(#13+#10, sText);
          while b>0 do
          begin
            sTmp:=Copy(sText, 1, b+1);
            Delete(sText, 1, b+1);

            m:=Pos(' ', sTmp);
            if m=0 then sAnswer:=sTmp else sAnswer:=Copy(sTmp, 1, m-1);
            if sAnswer = sAnswerKey then
            begin
              result:=Trim(Copy(sTmp, m+1, maxint));
              LockOff(Lock);
              AskMode:=false;
              Exit;
            end;
            self.Read(sTmp);
            b:=Pos(#13+#10, sText);
          end;
        end;
      end;
      LockOff(Lock);
    end;
    Sleep(1);
    Dec(i);
  end;
  AskMode:=false;
end;

function TPluginCmd.CreateChildProcess(FileName: string):boolean;
var
  FStartInfo: TStartupInfo;
  FSecAttrs: TSecurityAttributes;
  sd: TSecurityDescriptor ; //структура security для пайпов
  ph: TPipeHandles;
  ExeName, CmdLine: string;
label
  Error;

function IsWinNT(): boolean; //проверка запуска под NT
var
  osv: TOsVersionInfo;
begin
  osv.dwOSVersionInfoSize := SizeOf(osv);
  GetVersionEx(osv);
  result:=(osv.dwPlatformId = VER_PLATFORM_WIN32_NT);
end;

begin
  result:=false;

  ExeName:=FileName;
  CmdLine:='';
  // Очищаем хендлы
  for ph := Low(TPipeHandles) to High(TPipeHandles) do
  begin
    Pipes[ph] := INVALID_HANDLE_VALUE;
  end;

  if (IsWinNT()) then //инициализация security для Windows NT
  begin
    InitializeSecurityDescriptor(@sd, SECURITY_DESCRIPTOR_REVISION);
    SetSecurityDescriptorDacl(@sd, true, nil, false);
    FSecAttrs.lpSecurityDescriptor := @sd;
  end
  else FSecAttrs.lpSecurityDescriptor := nil;

  // Заполняем атрибуты
  FSecAttrs.nLength := SizeOf(SECURITY_ATTRIBUTES);
  FSecAttrs.bInheritHandle := True;
  //FSecAttrs.lpSecurityDescriptor := nil;

  // Создаем пайпы
  if not CreatePipe(Pipes[IN_READ], Pipes[IN_WRITE], @FSecAttrs, 0) then goto Error;
  if not CreatePipe(Pipes[OUT_READ], Pipes[OUT_WRITE], @FSecAttrs, 0) then goto Error;
  if not CreatePipe(Pipes[ERR_READ], Pipes[ERR_WRITE], @FSecAttrs, 0) then goto Error;

  // Делаем НЕ наследуемые дубликаты
  // Это нужно, чтобы не тащить лишние хэндлы в дочерний процесс...
  if not DuplicateHandle(GetCurrentProcess(), Pipes[OUT_READ],
    GetCurrentProcess(), @Pipes[TMP], 0, False, DUPLICATE_SAME_ACCESS) then goto Error;
  CloseHandle(Pipes[OUT_READ]);
  Pipes[OUT_READ]:=Pipes[TMP];
  Pipes[TMP]:=INVALID_HANDLE_VALUE;

  if not DuplicateHandle(GetCurrentProcess(), Pipes[IN_WRITE],
    GetCurrentProcess(), @Pipes[TMP], 0, False, DUPLICATE_SAME_ACCESS) then goto Error;
  CloseHandle(Pipes[IN_WRITE]);
  Pipes[IN_WRITE]:=Pipes[TMP];
  Pipes[TMP]:=INVALID_HANDLE_VALUE;

  // Set up members of STARTUPINFO structure.
  ZeroMemory(@FStartInfo, SizeOf(TStartupInfo));
  FStartInfo.cb := sizeof(TStartupInfo);
  FStartInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  //FStartInfo.wShowWindow := SW_SHOW; // SW_HIDE если надо запустить невидимо
  FStartInfo.wShowWindow := SW_HIDE; // SW_HIDE если надо запустить невидимо
  FStartInfo.hStdInput := Pipes[IN_READ];
  FStartInfo.hStdOutput := Pipes[OUT_WRITE];
  FStartInfo.hStdError := Pipes[ERR_WRITE];

  // Create the child process.
  result:=CreateProcess(nil,
    PChar(ExeName+' '+CmdLine), // command line
    nil, // process security attributes
    nil, // primary thread security attributes
    TRUE, // handles are inherited
    0, // creation flags
    nil, // use parent's environment
    nil, // use parent's current directory
    FStartInfo, // STARTUPINFO pointer
    FProcInfo); // receives PROCESS_INFORMATION

  // Закрываем хендлы на другие концы пайпов.
  // Если этого не сделать, при закрытии дочернего процесса пайп не закроется
  CloseHandle(Pipes[IN_READ]);
  CloseHandle(Pipes[OUT_WRITE]);
  CloseHandle(Pipes[ERR_WRITE]);
  Pipes[IN_READ]:=INVALID_HANDLE_VALUE;
  Pipes[OUT_WRITE]:=INVALID_HANDLE_VALUE;
  Pipes[ERR_WRITE]:=INVALID_HANDLE_VALUE;

  Exit;

Error:
  CloseChildProc();
end;

function TPluginCmd.WriteToChild(Data: string; Timeout: Integer = 1000): Boolean;
var
  dwWritten, BufSize: DWORD;
  chBuf: PChar;
begin
  result:=false;
  if Length(Data)=0 then Exit;
  //Обратите внимание на Chr($0D)+Chr($0A)!!! Без них - будет работать с ошибками
  //На досуге - подумайте почему...
  //Для тех, кому думать лень - подскажу - это пара символов конца строки.
  //(вообще-то можно обойтись одним, но так надежнее, программы-то бывают разные)
  chBuf := PChar(Data+#13+#10);
  BufSize := Length(chBuf);
  Result := WriteFile(Pipes[IN_WRITE], chBuf^, BufSize, dwWritten, nil);
  Result := Result and (BufSize = dwWritten);
end;

procedure TPluginCmd.Execute();
var
  n: integer;

procedure ReadPipe();
const
  BufLen = 256;
var
  BufSize, ReadSize, ReadSize2, TotalSize: DWORD;
  Buf: array[0..BufLen] of Char;
  Done: boolean;
  i: integer;
begin
  if Pipes[OUT_READ] = INVALID_HANDLE_VALUE then Exit;
  BufSize:=SizeOf(Buf);
  TotalSize:=0;
  ReadSize:=0;

  //Проверяем, есть ли данные для чтения в stdout
  PeekNamedPipe(Pipes[OUT_READ], @Buf, BufSize-1, @ReadSize, @TotalSize, nil);

  //if (ReadSize = 0) then Exit;

  begin
    if (TotalSize > BufSize) then
    begin
      while (ReadSize >= BufSize) do
      begin
        //читаем из пайпа stdout
        ZeroMemory(@Buf, BufSize);
        //for i:=Low(Buf) to High(Buf) do Buf[i]:=#0;
        ReadFile(Pipes[OUT_READ], Buf, BufSize-1, ReadSize, nil);
        if LockOn(Lock) then
        begin
          sText := sText+StrPas(@Buf[0]);
          LockOff(Lock);
        end;
      end;
    end
    else
    begin
      ZeroMemory(@Buf, BufSize);
      //for i:=Low(Buf) to High(Buf) do Buf[i]:=#0;
      ReadFile(Pipes[OUT_READ], Buf, BufSize-1, ReadSize, nil);
      if LockOn(Lock) then
      begin
        sText := sText+StrPas(@Buf[0]);
        LockOff(Lock);
      end;
    end;
  end;
end;

begin
  while not Terminated do
  begin
    ReadPipe();
    if not AskMode then
    begin
      if Length(sText)>0 then Synchronize(SyncProc);
    end;
    Sleep(1);
  end;
end;

procedure TPluginCmd.CloseChildProc();
var
  ph: TPipeHandles;
  i: integer;
  lpdwFlags: Cardinal;
begin
  if FProcInfo.hProcess <> INVALID_HANDLE_VALUE then
  begin
    CloseHandle(FProcInfo.hThread);
    i := WaitForSingleObject(FProcInfo.hProcess, 1000);
    CloseHandle(FProcInfo.hProcess);
    if i <> WAIT_OBJECT_0 then
    begin
      FProcInfo.hProcess := OpenProcess(PROCESS_TERMINATE,
        FALSE,
        FProcInfo.dwProcessId);
      if FProcInfo.hProcess <> 0 then
      begin
        TerminateProcess(FProcInfo.hProcess, 0);
        CloseHandle(FProcInfo.hProcess);
      end;
    end;
  end;

  for ph := Low(TPipeHandles) to High(TPipeHandles) do
  begin
    if Pipes[ph] <> INVALID_HANDLE_VALUE then
    begin
      try
        CloseHandle(Pipes[ph]);
      except
      end;
    end;
  end;
end;

//======================================================
function LockOn(var Lock: boolean): boolean;
var
  i: integer;
begin
  i:=20;
  while i>0 do
  begin
    if not Lock then
    begin
      Lock:=true;
      result:=true;
      Exit;
    end;
    Dec(i);
    Sleep(1);
  end;
  result:=false;
end;

function LockOff(var Lock: boolean): boolean;
begin
  Lock:=false;
  result:=true;
end;

function PluginCallback(Plugin: TPlugin; MsgText: PChar): PChar; stdcall;
var
  strMsg: string;
  strCmd: string;
  strPrm: string;
  n: integer;
  //pf: TPluginFrame;
begin
  result:=PChar('');
  //if not Assigned(Plugin.PluginFrame) then exit;
  //pf:=(Plugin.PluginFrame as TPluginFrame);

  strMsg:=MsgText;
  n:=Pos(' ',strMsg);
  if n=0 then n:=maxint;
  strCmd:=Copy(strMsg, 1, n-1);
  strPrm:=Copy(strMsg, n+1, maxint);
  //Form1.lbPlugin1_1.Caption:='='+strMsg+'=';
  //Form1.lbPlugin1.Caption:='n='+IntToStr(n)+' strCmd='+strCmd+'= strPrm='+strPrm+'=';

  if strCmd='TEXT' then
  begin
    DebugText(Plugin.Name+' reporting: '+strPrm);
  end
  else if strCmd='BTN1' then
  begin
  end
  else if strCmd='BTN2' then
  begin
  end;
end;

function PluginMsgFunc(id: DWORD; MsgText: PChar): PChar; stdcall;
var
  plug: TPlugin;
  s: string;
begin
  //PluginsLock.Acquire();
  result:=PChar('');
  s:=MsgText;
  DebugText(s);

  //PluginsLock.Release();
  Exit;

  plug:=PluginsManager.GetByID(id);
  if Assigned(plug) then result:=PluginCallback(plug, MsgText);
  //PluginsLock.Release();
end;

procedure FindPluginsFiles(StartFolder, Mask: string; sl: TStringList);
var
  SearchRec: TSearchRec;
  FindResult, i: Integer;
begin
  StartFolder := IncludeTrailingPathDelimiter(StartFolder);
  FindResult := FindFirst(StartFolder + '*.*', faAnyFile, SearchRec);
  try
    while FindResult = 0 do
      with SearchRec do
      begin
        if (Attr and faDirectory) <> 0 then
        begin
          if (Name <> '.') and (Name <> '..') then
          begin
            FindPluginsFiles(StartFolder + Name, Mask, sl);
          end;
        end
        else
        begin
          if MatchesMask(Name, Mask) then
          begin
            sl.Add(StartFolder + Name);
          end;
        end;
        FindResult := FindNext(SearchRec);
      end;
  finally
    FindClose(SearchRec);
  end;
end;

function AddPluginPage(PlugName: string): HWND;
var
  NewItem: TListItem;
  NewTreeNode: TTreeNode;
  PluginsBaseNode: TTreeNode;
  PluginGroupBox: TGroupBox;
begin
 { PluginsBaseNode:=Form2.TreeView1.Items[18];  // !!!
  lvPluginsList := Form2.lvPluginsList;

  // Добавляем закладку плагина в дерево закладок
  NewTreeNode:= TTreeNode.Create(Form2.TreeView1.Items);
  NewTreeNode.Text:=PlugName;
  Form2.TreeView1.Items.AddNode(NewTreeNode, PluginsBaseNode, NewTreeNode.Text, nil, naAddChild);

  // Добавляем страницу плагина в виде TGroupBox
  PluginGroupBox:= TGroupBox.Create(Form2);
  PluginGroupBox.Caption:=PlugName;
  PluginGroupBox.Visible:=false;
  // Берем настройки страницы из другой страницы
  PluginGroupBox.Height:=Form2.gbMain.Height;
  PluginGroupBox.Left:=Form2.gbMain.Left;
  PluginGroupBox.Top:=Form2.gbMain.Top;
  PluginGroupBox.Width:=Form2.gbMain.Width;
  PluginGroupBox.Parent:=Form2.gbMain.Parent;

  // Увеличиваем массив закладок
  SetLength(MainFrame, Form2.TreeView1.Items.Count);
  MainFrame[Length(MainFrame)-1]:=PluginGroupBox;

  // Добавляем в список плагинов информацию о плагине
  NewItem:= lvPluginsList.Items.Add();
  NewItem.Caption:=PlugName;
  NewItem.SubItems.Add('Plugin description');
  NewItem.SubItems.Add('v0.01');
  //NewItem.Data:=PluginGroupBox;

  result:= PluginGroupBox.Handle;   }
  Result:=0;
end;

{procedure AddPagesForPlugins();
var
  i: integer;
  NewTreeNode: TTreeNode;
  NewItem: TListItem;
  PluginsBaseNode: TTreeNode;
  PluginGroupBox: TGroupBox;
  Plug: TPlugin;
begin
  PluginsBaseNode:=Form2.TreeView1.Items[18];  // !!!
  lvPluginsList := Form2.lvPluginsList;

  for i:=0 to PlugMan.Count-1 do
  begin
    Plug:=(PlugMan[i] as TPlugin);
    // Добавляем закладку плагина в дерево закладок
    NewTreeNode:= TTreeNode.Create(Form2.TreeView1.Items);
    NewTreeNode.Text:=Plug.Name;
    Form2.TreeView1.Items.AddNode(NewTreeNode, PluginsBaseNode, NewTreeNode.Text, nil, naAddChild);

    // Увеличиваем массив страниц
    SetLength(MainFrame, Form2.TreeView1.Items.Count);
    MainFrame[Length(MainFrame)-1]:=Plug.gbOptionsBox;

    // Добавляем в список плагинов информацию о плагине
    NewItem:= lvPluginsList.Items.Add();
    NewItem.Caption:=Plug.Name;
    NewItem.SubItems.Add('Plugin description');
    NewItem.SubItems.Add('v0.01');
    NewItem.Data:=Plug;
  end;
end; }

procedure InitPlugins();
var
  NewPluginDLL: TPluginDLL;
  i: Integer;
  slp: TStringList;
  NewHWND: HWND;
begin
  //PlugMan := TPluginsManager.Create(true);
  //PluginsLock := TCriticalSection.Create();

  // Копируем тестовый плагин
  //Misc.CopyFile('D:\work\PluginTest\Plugin1\Project2.dll', 'D:\work\RealChat\Plugins\Project2.dll');

  // Ищем и добавляем плагины
  slp:=TStringList.Create();
  FindPluginsFiles(glHomePath+MainConf['PluginsPath'], '*.dll', slp);
  //slp.Add('D:\work\PluginTest\Plugin2\Plugin2.dll');
  //slp.Add('D:\work\PluginTest\Plugin1\Project2.dll');

  for i:=0 to slp.Count-1 do
  begin
    NewPluginDLL:= TPluginDLL.Create(slp[i], PluginsManager.GetNewID);
    if not NewPluginDLL.Test() then
    begin
      NewPluginDLL.Free();
      Continue;
    end;
    PluginsManager.AddPlugin(NewPluginDLL);

    // Создаем окошко опций для плагина
    NewHWND:=AddPluginPage(ExtractFileName(slp[i]));
    NewPluginDLL.OptionsBoxHandle:=NewHWND;
    //NewPlugin.gbOptionsBox:= TGroupBox.Create(Form2);
    //NewPlugin.gbOptionsBox.Parent:=Form2;
    //NewPlugin.gbOptionsBox.Caption:=NewPlugin.Name;
    //NewPlugin.gbOptionsBox.Visible:=false;

    // Запускаем плагин
    NewPluginDLL.Resume();

  end;
  slp.Free();
end;

procedure StopPlugins();
begin
  //PlugMan.Free();
end;

end.
