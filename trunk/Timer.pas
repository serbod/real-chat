unit Timer;

interface
uses Forms, Core, Contnrs;

// ������� �������. ����������� ������ �������
procedure On1sTimer();
// ������� �������. ����������� ������ 100 ��
procedure On100msTimer();
// ����� ��������� �������
procedure ResetTimer(TC: integer);
// ���������� ��������� �������
procedure DisableTimer(TC: integer);

type
  TTimerItem = class(TObject)
  public
    Delay: integer;
    Command: string;
    PageID: integer;
  end;

  TCmdSheduler = class(TObjectList)
  private
    Lock: boolean;
  public
    constructor Create();
    function AddTimerEvent(Delay: integer; Cmd: string; PageID: integer): integer;
    function ResetTimerEvent(Delay: integer; Cmd: string; PageID: integer): integer;
    function RemoveTimerEvent(Cmd: string; PageID: integer): integer;
    procedure TimerTick();
  end;

const
  TC_ServerPing     = 1;
  TC_ServerData     = 2;
  TC_DCCQuery       = 3;
  TC_ReconnectDelay = 4;
  TC_HTTPGet_Timeout = 5;

  TC_Count = 5;

var
  TimeCounters: array [1..TC_Count] of integer;
  MaxTimeCounters: array [1..TC_Count] of integer;
  CmdSheduler: TCmdSheduler;

implementation
uses DCC;

var n: integer;

procedure ResetTimer(TC: integer);
begin
  if TC <= TC_Count then TimeCounters[TC]:=MaxTimeCounters[TC];
end;

procedure DisableTimer(TC: integer);
begin
  if TC <= TC_Count then TimeCounters[TC]:=-1;
end;

procedure On1sTimer();
var
  i: integer;
begin
  //if not IrcClient.Active then Exit;
  // �������� ��������
  for i:=1 to TC_Count do
    if TimeCounters[i]>0 then Dec(TimeCounters[i]);

  // �������� ��������
  if (TimeCounters[TC_ServerPing] = 0) then
  begin
    // ������� ����� ��� ������ �� �������..
    ParseIRCTextByPageID(-1, #2+#3+'5���-�� ����� ��� ������ �� �������. ����� � �������?');
    ResetTimer(TC_ServerPing);
  end;

  if (TimeCounters[TC_ServerData] = 0) then
  begin
    // ������� ����� ��� ������ �� �������..
    ResetTimer(TC_ServerData);
    // ���������
    {if MainConf.GetBool('AutoReconnect') then
      if not IrcClient.Active then ReconnectServer()
    else
      ParseIRCTextByPageID(-1, #2+#3+'5���-�� ����� ��� ������ �� �������. ����� � �������?');}
  end;

  if (TimeCounters[TC_HTTPGet_Timeout] = 0) then
  begin
    // ������� ����� �� ����������� ����
    ParseIRCTextByPageID(-1, #2+#3+'05�� ������� ������� ���� �� HTTP - �������.');
    DisableTimer(TC_HTTPGet_Timeout);
    Core.MainForm.HTTPGet1.Abort;
    Core.MainForm.HTTPGet1.URL:='';
  end;

  DCC_CheckAlive();

  // Delete closed windows
  for i:=Core.olPrivWndList.Count-1 downto 0 do
    if not (Core.olPrivWndList[i] as TForm).Visible then Core.olPrivWndList.Delete(i);

  {// Delete stopped threads
  for i:=olThreadsList.Count-1 downto 0 do
    if olThreadsList[i]=nil then olThreadsList.Delete(i);
    //if (olThreadsList[i] as TThread).Terminated then olThreadsList.Delete(i);
  }
end;

procedure On100msTimer();
var
  i: integer;
begin
  CmdSheduler.TimerTick();
  if not Assigned(PagesManager) then Exit;
  if Core.PagesManager.GetActivePage.PageID = ciFilesPageID then
  begin
    Core.PagesManager.GetActivePage.SetActive(true);
  end;
end;

// TCmdSheduler
constructor TCmdSheduler.Create();
begin
  Lock:=false;
  inherited Create(true);
end;

function TCmdSheduler.AddTimerEvent(Delay: integer; Cmd: string; PageID: integer): integer;
var
  TimerItem: TTimerItem;
begin
  TimerItem:=TTimerItem.Create();
  TimerItem.Delay:=Delay;
  TimerItem.Command:=Cmd;
  TimerItem.PageID:=PageID;
  result:=self.Add(TimerItem);
end;

function TCmdSheduler.ResetTimerEvent(Delay: integer; Cmd: string; PageID: integer): integer;
var
  TimerItem: TTimerItem;
  i: integer;
begin
  result:=0;
  for i:=self.Count-1 downto 0 do
  begin
    TimerItem:=TTimerItem(self.Items[i]);
    if (TimerItem.PageID = PageID) and (TimerItem.Command = Cmd) then
    begin
      TimerItem.Delay:=Delay;
      result:=1;
      Exit;
    end;
  end;
  // not found
  self.AddTimerEvent(Delay, Cmd, PageID);
end;

function TCmdSheduler.RemoveTimerEvent(Cmd: string; PageID: integer): integer;
var
  TimerItem: TTimerItem;
  i: integer;
begin
  result:=0;
  for i:=self.Count-1 downto 0 do
  begin
    TimerItem:=TTimerItem(self.Items[i]);
    if (TimerItem.PageID = PageID) and ((TimerItem.Command = Cmd) or (Cmd='')) then
    begin
      self.Remove(TimerItem);
      result:=1;
      Exit;
    end;
  end;
end;

procedure TCmdSheduler.TimerTick();
var
  i: integer;
  TimerItem: TTimerItem;
  Cmd: string;
  PageID: integer;
begin
  // Lock protect procedure from occasionaly recursive call
  if Lock then Exit;
  Lock:=true;
  i:=self.Count;
  while i>0 do
  begin
    // dynamic cycle protect from recursively deleted entries
    if i>=Self.Count then i:=Self.Count;
    if i<=0 then Continue;
    Dec(i);
    //while i >= self.Count do Dec(i);
    TimerItem:=TTimerItem(self.Items[i]);
    if TimerItem.Delay < 100 then
    begin
      Cmd:=TimerItem.Command;
      PageID:=TimerItem.PageID;
      self.Remove(TimerItem);
      Core.Say(Cmd, PageID);
      Continue;
    end;
    Dec(TimerItem.Delay, 100);
  end;
  Lock:=false;
end;

initialization
begin
  MaxTimeCounters[TC_ServerPing]:= 120;        // ���������� ������ �������
  MaxTimeCounters[TC_ServerData]:= 300;        // ���������� ������ �������
  MaxTimeCounters[TC_DCCQuery]:= 120;           // ���������� ������ DCC
  MaxTimeCounters[TC_ReconnectDelay]:= 3;      // �������� ��� ����������
  MaxTimeCounters[TC_HTTPGet_Timeout]:= 60;    // �������� ������ �����

  for n:=1 to TC_Count do TimeCounters[n]:=-1; // ���������� ���� ���������

  // Create commands sheduler
  CmdSheduler:=TCmdSheduler.Create();
end;

finalization
begin
  CmdSheduler.Free();
end;

end.
