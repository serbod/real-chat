unit IRC_ChanOptions;

interface

uses
  SysUtils, Controls, Forms, StdCtrls, CheckLst, Classes, IRC, Core;

type
  TfrmChanOptions = class(TForm)
    lbTopic: TLabel;
    btnSetTopic: TButton;
    memoTopic: TMemo;
    grpChanModes: TGroupBox;
    cbPrivate: TCheckBox;
    cbSecret: TCheckBox;
    cbNoExtMsg: TCheckBox;
    cbTopicOpsOnly: TCheckBox;
    cbModerated: TCheckBox;
    cbInviteOnly: TCheckBox;
    edLimit: TEdit;
    lbChanUserLimit: TLabel;
    edKeyword: TEdit;
    lbKeyword: TLabel;
    cbColorsDisabled: TCheckBox;
    cbRobots: TCheckBox;
    grpBanList: TGroupBox;
    lstBanList: TListBox;
    btnUnban: TButton;
    procedure btnSetTopicClick(Sender: TObject);
    procedure btnUnbanClick(Sender: TObject);
  private
    { Private declarations }
    procedure ReadModes(sModes: string);
    function ModeString(): string;
  public
    { Public declarations }
    ChanName: string;
    ChanTopic: string;
    ChanModes: string;
    IrcClient: TIrcClient;
    procedure Start();
    procedure ChangeLanguage();
    procedure AddBanId(sBanId: string);
  end;

var
  frmChanOptions: TfrmChanOptions;

implementation

{$R *.dfm}

//  ***** _-_ Channel Modes
//
//  +b <mask> - добавляет адрес бана по маске mask вида nick!ident@host.domain (доступна % и @).
//  +c - всем запрещает использовать цвета в сообщениях. Если в quit/part-мессаге человека есть цвета, то всем выдается сообщение о его выходе с канала, а не quit/part-мессаг (доступна % и @).
//  +e <mask> - добавляет адрес эксепта (исключения из бана) по маске nick!ident@host.domain (доступна % и @).
//  +i - делает вход на канал возможным только по приглашению (доступна % и @).
//  +j <m:n> - всем за n секунд возможен вход на канал не более m пользователей (доступна % и @).
//  +k <key> - задает пароль key для входа на канал (доступна % и @).
//  +l <x> - определяет верхний предел количества пользователей на канале (доступна % и @).
//  +m - включает режим модерации (право голоса/смены ников имеют только ирц-опы, @-, %- и +-пользователи) (доступна % и @).
//  +n - запрещает прием сообщений в канал извне (доступна % и @).
//  +p - скрывает канал из списка, выдаваемого сервисами и из /list (доступна % и @).
//  +r - определяет канал как зарегистрированный сервисами (доступна Серверу).
//  +s - скрывает канал из списка, выдаваемого по команде /list (доступна % и @).
//  +t - запрещает менять топик всем, кроме %- и @-пользователей (доступна % и @)
//  +f - channel forward, после выставление этого режима, разрешается выставлять бан вида: nick!ident@host.domain,#channel - если человек попадает под эту маску, то его перекидывает на указанный канал (доступна Глобальным IRCOp'ам).
//
//  +A - аналог +i, с тем условием, что ирц-опы могут войти без приглашения (доступна ирц-опам).
//  +H - запрещает вход на канал всем, кроме хелперов и ирц-опов (доступна хелперам и ирц-опам).
//  +I <mask> - добавляет адрес по маске nick!ident@host.domain, обладатель которого может свободно заходить на канал с режимом +i (доступна % и @).
//  +L - скрывает канал отовсюду (доступна Серверу).
//  +M - дает право голоса только зарегистрированным пользователям (доступна % и @).
//  +O - запрещает вход на канал всем, кроме ирц-опов (доступна ирц-опам).
//  +P - запрещает кикать пользователей с канала (доступна только Mystery: /mystery set #channel peace ON).
//  +R - разрешает вход на канал только зарегистрированным пользователям (доступна % и @).
//  +S - "вырезает" цвета из сообщений при попытке их использовать (доступна % и @).
//  +B - "вырезает" цвета, подчеркивание, жирный шрифт, инверсию из сообщений при попытке их использовать (доступна % и @).
//  +U - показывает вошедшему на канал только его @-пользователей, а также тех, кто войдет позже (доступна % и @).
//  +Z - заход на канал разрешен только пользовтелям с SSL-коннектом (доступна % и @).

procedure TfrmChanOptions.Start();
begin
  ChangeLanguage();
  Self.Caption:=ChanName;
  memoTopic.Text:=ChanTopic;
  ReadModes(ChanModes);
  IrcClient.SendTextToServer('MODE '+ChanName+' +b'+#10);
  Show();
  //lstChanModes.Clear();
  //lstChanModes.AddItem('p Private', nil);
  //lstChanModes.AddItem('s Secret', nil);

  // People outside the channel cannot do /MSG #channel_name [whatever]
  // which would otherwise be sent to everybody on the channel
  //lstChanModes.AddItem('n No external messages to the channel', nil);

  // Only channel ops are allowed to change the topic
  //lstChanModes.AddItem('t Topic control', nil);

  // On a moderated channel, only channel operators can talk publicly,
  // others can only listen and will get "cannot send to channel" errors
  // if they try to talk. The exception is if you are given a voice (+v).
  // Moderated mode is useful for conferencing or keeping control over very
  // busy channels.
  //lstChanModes.AddItem('m Moderated', nil);

  // People can only join your channel if an op permits it. To set it:
  // /MODE #demo +i
  // Then to let buddy in, use the /INVITE command:
  // /INVITE buddy #demo  lstChanModes.AddItem('i Invite Only', nil);
  //lstChanModes.AddItem('i Invite Only', nil);

  //lstChanModes.AddItem('', nil);

  // ======================================
  // Limited (l [number])
  // Only that number of people are allowed to /JOIN the channel.
  // /MODE #demo +l 20
  //
  // Later to remove the limit (note you don't need to specify the number):
  // /MODE #demo -l.

  // ======================================
  // Keyword or Password Protected (k keyword)
  // You must know the keyword to /JOIN the channel. To set the keyword as "trustno1":
  // /MODE #demo +k trustno1
  //
  // Then in order for somebody outside to join, they must type:
  // /JOIN #demo trustno1
  //
  // And to remove the keyword:
  // /MODE #demo -k trustno1

  // ======================================
  // Channel ops (o [nickname])
  // Any op can give ops to anybody else, and once that other person gains ops, he has the same power as you do, including the ability to remove your ops or "deop" you, or even to kick you out. This is known as a takeover. Don't share ops with others unless you trust them fully!
  // /MODE #demo +o buddy
  //
  // You can also do a few of these together on the same line, such as:
  // /MODE #demo +ooo larry curley moe

end;

procedure TfrmChanOptions.ReadModes(sModes: string);
var
  i: integer;
  c: Char;
  SignPlus: Boolean;
begin
  SignPlus:=True;
  for i:=1 to Length(sModes) do
  begin
    c:=sModes[i];
    if c='+' then
    begin
      SignPlus:=True;
    end
    else if c='-' then
    begin
      SignPlus:=False;
    end
    else if c='p' then
    begin
      cbPrivate.Checked:=SignPlus;
    end
    else if c='s' then
    begin
      cbSecret.Checked:=SignPlus;
    end
    else if c='n' then
    begin
      cbNoExtMsg.Checked:=SignPlus;
    end
    else if c='t' then
    begin
      cbTopicOpsOnly.Checked:=SignPlus;
    end
    else if c='m' then
    begin
      cbModerated.Checked:=SignPlus;
    end
    else if c='i' then
    begin
      cbInviteOnly.Checked:=SignPlus;
    end
    else if c='r' then
    begin
      //cbColorsDisabled.Checked:=SignPlus;
    end
    else if c='c' then
    begin
      cbColorsDisabled.Checked:=SignPlus;
    end
    else if c='l' then
    begin
      // limit
      edLimit.Text := Copy(sModes, i+2, MaxInt);
    end
    else if c='k' then
    begin
      // keyword
      edKeyword.Text := Copy(sModes, i+2, MaxInt);
    end
    else
    begin
    end
  end;
end;

procedure TfrmChanOptions.AddBanId(sBanId: string);
begin
  lstBanList.AddItem(sBanId, nil);
end;

function TfrmChanOptions.ModeString(): string;
begin
  Result:='MODE '+ChanName+' ';
  if Trim(edKeyword.Text)<>'' then Result:=Result+'&'+Trim(edKeyword.Text)+' ';
end;

procedure TfrmChanOptions.btnSetTopicClick(Sender: TObject);
var
  s: string;
begin
  s:=memoTopic.Text;
  s:=StringReplace(s, #10, '', [rfReplaceAll]);
  s:=StringReplace(s, #13, ' ',[rfReplaceAll]);
  IrcClient.SendTextToServer('TOPIC '+ChanName+' :'+s+#10);
end;

procedure TfrmChanOptions.ChangeLanguage();

function GetStr(Name: string; s: string): string;
begin
  result:=Core.LangIni.ReadString('IRC_ChanOptions', Name, s);
end;

begin
  if not Assigned(Core.LangIni) then Exit;
  try
    lbTopic.Caption:=GetStr('lbTopic.Caption', lbTopic.Caption);

    grpChanModes.Caption:=GetStr('grpChanModes.Caption', grpChanModes.Caption);
    cbPrivate.Caption:=GetStr('cbPrivate.Caption', cbPrivate.Caption);
    cbSecret.Caption:=GetStr('cbSecret.Caption', cbSecret.Caption);
    cbNoExtMsg.Caption:=GetStr('cbNoExtMsg.Caption', cbNoExtMsg.Caption);
    cbTopicOpsOnly.Caption:=GetStr('cbTopicOpsOnly.Caption', cbTopicOpsOnly.Caption);
    cbModerated.Caption:=GetStr('cbModerated.Caption', cbModerated.Caption);
    cbInviteOnly.Caption:=GetStr('cbInviteOnly.Caption', cbInviteOnly.Caption);
    cbColorsDisabled.Caption:=GetStr('cbColorsDisabled.Caption', cbColorsDisabled.Caption);
    cbRobots.Caption:=GetStr('cbRobots.Caption', cbRobots.Caption);
    lbChanUserLimit.Caption:=GetStr('lbChanUserLimit.Caption', lbChanUserLimit.Caption);
    lbKeyword.Caption:=GetStr('lbKeyword.Caption', lbKeyword.Caption);

    grpBanList.Caption:=GetStr('grpBanList.Caption', grpBanList.Caption);
    btnUnban.Caption:=GetStr('btnUnban.Caption', btnUnban.Caption);
  finally
  end;
end;


procedure TfrmChanOptions.btnUnbanClick(Sender: TObject);
var
  s: string;
  i: Integer;
begin
  for i:=0 to lstBanList.Items.Count-1 do
  begin
    if not lstBanList.Selected[i] then Continue;
    s:=lstBanList.Items[i];
    IrcClient.SendTextToServer('MODE '+ChanName+' -b '+s+#10);
  end;
end;

end.
