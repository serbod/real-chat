{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  Модуль работы со звуковыми событиями и всего прочего, что касается звуков
}
unit Sounds;

interface
uses Windows, Classes, SysUtils, Core, MMSystem, WavePlayer;

//procedure PlayChatSound(SoundEvent: ESoundEvent);
//procedure PlayNamedSound(SoundName: string; Conf: TConf);
procedure PlaySoundFile(Filename: string);

type
  TSoundPlayer = class(TThread)
  public
    Stopped: Boolean;
    Filename: string;
    wp: TWavePlayer;
    procedure OnFinishedPlayback(Sender: TObject);
  protected
    procedure Execute(); override;
  end;

{var
  sSoundEventChannelMessage: string = 'Сообщение на канал';
  sSoundEventPrivateMessage: string = 'Приватное сообщение';
  sSoundEventMeMessage: string = 'Сообщение /ME';
  sSoundEventNoticeMessage: string = 'Сообщение /NOTICE';
  sSoundEventDccChat: string = 'Входящий DCC чат';
  sSoundEventDccFile: string = 'Входящий DCC файл';
  sSoundEventServerConnect: string = 'Подключение к серверу';
  sSoundEventServerDisconnect: string = 'Отключение от сервера';
  sSoundEventJoinChannel: string = 'Заход на канал';
  sSoundEventLeaveChannel: string = 'Уход с канала';
  sSoundEventErrorMessage: string = 'Сообщение об ощибке';
  sSoundEventOther: string = 'Прочее'; }

implementation
{***************************************************************************
                            Sound support
***************************************************************************}
{ flag values for wFlags parameter }
const
  SND_SYNC            = $0000;  { play synchronously (default) }
  SND_ASYNC           = $0001;  { play asynchronously }
  SND_NODEFAULT       = $0002;  { don't use default sound }
  SND_MEMORY          = $0004;  { lpszSoundName points to a memory file }
  SND_LOOP            = $0008;  { loop the sound until next sndPlaySound }
  SND_NOSTOP          = $0010;  { don't stop any currently playing sound }

  SND_NOWAIT          = $00002000;  { don't wait if the driver is busy }
  SND_ALIAS           = $00010000;  { name is a registry alias }
  SND_ALIAS_ID        = $00110000;  { alias is a predefined ID }
  SND_FILENAME        = $00020000;  { name is file name }
  SND_RESOURCE        = $00040004;  { name is resource name or atom }
  SND_PURGE           = $0040;      { purge non-static events for task }
  SND_APPLICATION     = $0080;      { look for application specific association }

  SND_ALIAS_START     = 0;   { alias base }

function PlaySound(pszSound: PChar; hmod: HMODULE; fdwSound: DWORD): BOOL; stdcall; external 'winmm.dll' name 'PlaySoundA';

//-------------------
{procedure PlayChatSound(SoundEvent: ESoundEvent);
var
  //lpBuffer: PChar;
  //n: cardinal;
  sndFileName: string;
  sndType: string;
begin
  if not MainConf.GetBool('PlaySounds') then Exit;
  {
  n:=256;
  lpBuffer:=StrAlloc(n);
  GetWindowsDirectory(lpBuffer, n);
  sndFileName  := String(lpBuffer)+'\Media\ding.wav';
  }

  {// Get filename for given sound event
  sndType:=GetEnumName(TypeInfo(ESoundEvent), integer(SoundEvent));
  sndFileName:=MainConf.GetStrings('SoundFilesList').Values[sndType];
  if sndFileName = '' then Exit;

  PlaySound(PChar(sndFileName), 0, SND_ASYNC or SND_NOSTOP or SND_FILENAME);
end;}

procedure SendMCICommand(Cmd: string);
var
  RetVal: Integer;
  ErrMsg: array[0..254] of char;
begin
  RetVal := mciSendString(PChar(Cmd), nil, 0, 0);
  if RetVal <> 0 then
  begin
    {get message for returned value}
    mciGetErrorString(RetVal, ErrMsg, 255);
    //MessageDlg(StrPas(ErrMsg), mtError, [mbOK], 0);
  end;
end;

procedure PlaySoundFile(Filename: string);
begin
  PlaySound(PChar(Filename), 0, SND_ASYNC or SND_NOSTOP or SND_FILENAME);
end;

procedure PlaySoundFile2(Filename: string);
var
  sp: TSoundPlayer;
begin
  sp:=TSoundPlayer.Create(true);
  sp.FreeOnTerminate:=True;
  sp.Filename:=Filename;
  sp.Resume();
end;

{procedure TSoundPlayer.Execute();
begin
  Core.DebugMessage('Sound start: '+IntToStr(Self.ThreadID));
  PlaySound(PChar(Filename), 0, SND_NOSTOP or SND_FILENAME);
  Core.DebugMessage('Sound end: '+IntToStr(Self.ThreadID));
  Terminate();
end;}

{procedure TSoundPlayer.Execute();
begin
  Core.DebugMessage('Sound start: '+IntToStr(Self.ThreadID));
  SendMCICommand('open waveaudio shareable');
  SendMCICommand('play "'+Filename+'"');
  SendMCICommand('close waveaudio');
  Core.DebugMessage('Sound end: '+IntToStr(Self.ThreadID));
  Terminate();
end;}

procedure TSoundPlayer.Execute();
var
  fs: TFileStream;
  ms: TMemoryStream;
  Timeout: Integer;
begin
  Core.DebugMessage('Sound start: '+IntToStr(Self.ThreadID));
  ms:=TMemoryStream.Create();
  ms.LoadFromFile(FileName);
  wp:=TWavePlayer.Create();
  wp.Source:=ms;
  wp.OnFinishedPlayback:=OnFinishedPlayback;
  Timeout:=3000;
  Stopped:=False;
  wp.Play();
  //Stopped:=True;
  while not Stopped do
  begin
    if wp.State <> wpDone then
    begin
      if Timeout <= 0 then Stopped:=true;
      Dec(Timeout);
    end
    else Timeout:=0;
    Sleep(1);
  end;
  wp.Free();
  ms.Free();
  Core.DebugMessage('Sound end: '+IntToStr(Self.ThreadID));
  Terminate();
end;

procedure TSoundPlayer.OnFinishedPlayback(Sender: TObject);
begin
  Stopped:=True;
end;


end.
