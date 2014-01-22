{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  Настройки IRC-клиента.
}
unit IRC_Options;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ValEdit, StdCtrls, ComCtrls, misc, Configs, Menus,
  ActnPopupCtrl, Core, ToolWin, Contnrs;

type
  TfrmIrcOptions = class(TForm)
    PageControl1: TPageControl;
    tsIRCMain: TTabSheet;
    gbIRCMain: TGroupBox;
    gbOtherNick: TGroupBox;
    lbOtherNick: TLabel;
    lbFullName: TLabel;
    editOtherNick: TEdit;
    editFullName: TEdit;
    gbIrcMessages: TGroupBox;
    lbQuitMessage: TLabel;
    lbAway: TLabel;
    editQuitMessage: TEdit;
    editAway: TEdit;
    cbSendUTF8: TCheckBox;
    cbReceiveUTF8: TCheckBox;
    tsNickServ: TTabSheet;
    gbNickServ: TGroupBox;
    lbNickServ1: TLabel;
    lbNickServ2: TLabel;
    lbNickServ3: TLabel;
    lbNickServ4: TLabel;
    eNServNick: TEdit;
    eNServPassw: TEdit;
    eNServEmail: TEdit;
    btnNickServ1: TButton;
    btnNickServ2: TButton;
    tsConnection: TTabSheet;
    gbConnection: TGroupBox;
    gbServer: TGroupBox;
    lbServerName: TLabel;
    lbServerPort: TLabel;
    btnAddServer: TButton;
    btnDelServer: TButton;
    editServerName: TEdit;
    editServerPort: TEdit;
    listServerList: TListBox;
    gbNick: TGroupBox;
    listNickList: TListBox;
    editNick: TEdit;
    btnAddNick: TButton;
    btnDelNick: TButton;
    gbProxy: TGroupBox;
    tsAutojoin: TTabSheet;
    gbAutojoin: TGroupBox;
    lbAJList: TLabel;
    mAutojoinList: TMemo;
    tsIgnore: TTabSheet;
    gbIgnore: TGroupBox;
    lbIgnore1: TLabel;
    lbIgnore2: TLabel;
    lbIgnore3: TLabel;
    memoIgnore: TMemo;
    tsTemplates: TTabSheet;
    gbTemplates: TGroupBox;
    lbTemplates1: TLabel;
    lbTemplates2: TLabel;
    lbTemplates3: TLabel;
    lbTemplates4: TLabel;
    lbTemplates5: TLabel;
    lbTemplates6: TLabel;
    lbTemplates7: TLabel;
    lbTemplates8: TLabel;
    lbTemplates9: TLabel;
    memoTemplates: TMemo;
    tsSounds: TTabSheet;
    gbSounds: TGroupBox;
    lbSoundTest: TLabel;
    vleSounds: TValueListEditor;
    btnSoundTest: TButton;
    cbPlaySounds: TCheckBox;
    gbOther: TGroupBox;
    cbAutoReconnect: TCheckBox;
    cbAutoConnect: TCheckBox;
    cbShowServerPing: TCheckBox;
    cbLogMessages: TCheckBox;
    cbShowStatusMessages: TCheckBox;
    tsNotes: TTabSheet;
    gbNotes: TGroupBox;
    lbNotesReadme: TLabel;
    memoNotes: TMemo;
    cbShowNotesOnJoin: TCheckBox;
    menuChannels: TPopupMenu;
    mAllChannels: TMenuItem;
    mChannelsByMask: TMenuItem;
    N5: TMenuItem;
    cbNServAutoLogin: TCheckBox;
    cboxSSLType: TComboBox;
    lbSSL: TLabel;
    cboxProxyServer: TComboBox;
    tsSimpleBot: TTabSheet;
    memoSimpleBot: TMemo;
    gbSimpleBot: TGroupBox;
    cbSimpleBotEnable: TCheckBox;
    lbSimpleBot: TLabel;
    lbSimpleBotExample: TLabel;
    procedure SetNewNick(Sender :TObject);
    procedure SetNewServer(Sender: TObject);
    procedure AddNickClick(Sender: TObject);
    procedure DelNickClick(Sender: TObject);
    procedure AddServerClick(Sender: TObject);
    procedure DelServerClick(Sender: TObject);
    procedure vleSoundsEditButtonClick(Sender: TObject);
    procedure btnSoundTestClick(Sender: TObject);
    procedure menuChannelsClick(Sender: TObject);
    procedure ToolButtonClick(Sender: TObject);
    procedure menuChannelsShow(Sender: TObject);
    procedure btnNickServClick(Sender: TObject);
    procedure cboxProxyServerDropDown(Sender: TObject);
  private
    { Private declarations }
    //procedure FillSoundOptions();
    procedure OnApplySettingsHandler(Sender: TObject);
    procedure OnRefreshSettingsHandler(Sender: TObject);
  public
    { Public declarations }
    ChatClient: TChatClient;
    constructor Create(AOwner: TComponent); override;
    procedure FillConfigNodes(RootNode: TConfNode);
    procedure RefreshSettings(ConfNode: TConfNode);
    procedure ApplySettings(ConfNode: TConfNode);
    procedure ChangeLanguage();
  end;

  TIrcToolButtons = record
    tbtnConnect: TToolButton;
    tbtnChanList: TToolButton;
    tbtnOnline: TToolButton;
    tbtnAway: TToolButton;
  end;

  TIrcConf = class(TConf)
  public
    ChatClient: TChatClient;
    frmIrcOptions: TfrmIrcOptions;
    FToolButtons: TIrcToolButtons;
    FToolButtonsList: TObjectList;
    constructor Create(ChatClient: TChatClient; ConfFileName: string);
    destructor Destroy(); override;
  end;

  procedure FillSoundOptions(ConfItems: TConfItems; vleSounds: TValueListEditor);

implementation
uses Sounds, IRC;
{$R *.dfm}

constructor TIrcConf.Create(ChatClient: TChatClient; ConfFileName: string);
var
  sl: TStringList;
  ConfItems: TConfItems;
  TB: TToolButton;
begin
  self.ChatClient := ChatClient;
  self.FileName := glUserPath+ConfFileName;

  // Create config's root node
  RootNode:=TConfNode.Create(nil);
  RootNode.Name:='IRC_Options';
  RootNode.FullName:='IRC';
  RootNode.Owner:=ChatClient;
  RootNode.ConfItems:=TConfItems.Create(RootNode.Name);

  // Filll config items by default values
  ConfItems:=RootNode.ConfItems;
  //ConfItems.Add('Name', 'Full name', 'Value', 'Type');
  ConfItems.Add('MyNick', 'My nick', GetWinUserName(), 'S');
  ConfItems.Add('MySecondNick', 'My second nick', GetWinCompName(), 'S');
  ConfItems.Add('MyFullName', 'My full name', 'RealChat new user :)', 'S');
  ConfItems.Add('ServerHost', 'Server host addr', '172.16.90.22', 'S');
  ConfItems.Add('ServerPort', 'Server port number', '6667', 'S');
  ConfItems.Add('ServerUser', 'Server username (NOT nick)', 'RealChat', 'S');
  ConfItems.Add('ServerPass', 'Server password', '', 'S');
  ConfItems.Add('ServerProxy', 'Proxy server', '', 'S');
  ConfItems.Add('ProxyType', 'Proxy type: NONE, HTTP, SOCKS5', 'NONE', 'S');
  ConfItems.Add('ProxyUser', 'Proxy username', '', 'S');
  ConfItems.Add('ProxyPass', 'Proxy password', '', 'S');
  ConfItems.Add('QuitMessage', 'Quit message', 'RealChat - http://irchat.ru', 'S');
  ConfItems.Add('ClientVersion', 'Client version', 'IRC client for RealChat ver. 2.3', 'S');
  ConfItems.Add('AvatarURL', 'Avatar URL', '', 'S');
  ConfItems.Add('AwayMessage', 'Avay message', 'Меня здесь нет!', 'S');
  ConfItems.Add('DccPingReply', 'Ping reply', 'В себя потыкай =)', 'S');
  ConfItems.Add('DccUserinfoReply', 'DCC USERINFO reply', '', 'S');
  ConfItems.Add('DccFingerReply', 'DCC FINGER reply', 'В себя потыкай =)', 'S');

  ConfItems.Add('SaveFilesDir', 'Patch for received files', 'Incoming', 'S');
  ConfItems.Add('AvatarPath', 'Patch for received avatars', 'Avatars', 'S');
  ConfItems.Add('LogsPath', 'Patch for log files', 'Logs', 'S');

  ConfItems.Add('SSLType', 'SSL type: AUTO, SSLv2, SSLv3, TLSv1, TLSv1.1, SSHv2', '', 'S');
  ConfItems.Add('SSLUser', 'SSL username', '', 'S');
  ConfItems.Add('SSLPass', 'SSL password', '', 'S');
  ConfItems.Add('SSLKeyPass', 'SSL key password', '', 'S');

  ConfItems.Add('NSAutoLogin', 'NickServ - Auto login', '0', 'B');
  ConfItems.Add('NSNick', 'NickServ - Nickname', '', 'S');
  ConfItems.Add('NSPassword', 'NickServ - Password', '', 'S');
  ConfItems.Add('NSEmail', 'NickServ - Email', '', 'S');
  ConfItems.Add('NSRegister', 'NickServ - Register template', '/msg NickServ REGISTER <passw> <email>', 'T');
  ConfItems.Add('NSLogin', 'NickServ - Login template', '/msg NickServ IDENTIFY <passw>', 'T');
  //ConfItems.Add('NSLogin', 'NickServ - Login template', '/msg NickServ GHOST <nick> <passw>', 'T');

  ConfItems.Add('KeepAlivePeriod', 'Keep-Alive period', '60', 'I');
  ConfItems.Add('ServerDataTimeout', 'Server data timeout', '60', 'I');
  ConfItems.Add('AutoReconnectDelay', 'Auto reconnect delay, sec', '30', 'I');
  ConfItems.Add('DCCIdle', 'DCC idle timeout', '60', 'I');

  ConfItems.Add('AutoConnect', 'Auto connect', '0', 'B');
  ConfItems.Add('AutoReconnect', 'Auto reconnect', '1', 'B');
  ConfItems.Add('UseAvatars', 'Use avatars', '0', 'B');
  ConfItems.Add('LogMessages', 'Log messages', '0', 'B');
  ConfItems.Add('PlaySounds', 'PlaySounds', '0', 'B');
  ConfItems.Add('SendUTF8', 'Send text in UTF8 encoding', '0', 'B');
  ConfItems.Add('ReceiveUTF8', 'Receive text in UTF8 encoding', '0', 'B');
  ConfItems.Add('ShowServerPing', 'Show server Ping messages', '1', 'B');
  ConfItems.Add('ShowStatusMessages', 'Show status messages', '0', 'B');
  ConfItems.Add('ShowNotesOnJoin', 'Show notes on join', '0', 'B');
  ConfItems.Add('ServerPageVisible', 'Server page visible', '1', 'B');

  ConfItems.Add('NicksList', 'Recent nicks', '', 'T');
  ConfItems.Add('ServersList', 'Recent servers', '', 'T');
  ConfItems.Add('AutojoinList', 'Comands on connect', '', 'T');
  ConfItems.Add('NotesList', 'Notes', '', 'T');
  ConfItems.Add('IgnoreList', 'Ignore nicks', '', 'T');
  ConfItems.Add('RecentChannelsList', 'Recent channels', '', 'T');
  ConfItems.Add('TemplatesList', 'Templates', '', 'T');
  ConfItems.Add('NotesKeywordsList', 'Grab notes keywords', '', 'T');
  ConfItems.Add('SimpleBot', 'Simple bot', '', 'T');
  ConfItems.Add('SimpleBotEnabled', 'Simple bot enabled', '0', 'B');
  //ConfItems.Add('', '', '', '');
  //ConfItems.Add('', '', '', '');
  //ConfItems.Add('', '', '', '');
  //ConfItems.Add('', '', '', '');

  // Add default usernames
  sl:=TStringList.Create();
  sl.Add(GetWinUserName());
  sl.Add(GetWinCompName());
  ConfItems['NicksList']:=sl.Text;
  sl.Free();

  // Add default templates
  if FileExists(glHomePath+'\IRC_templates.txt') then
  begin
    sl:=TStringList.Create();
    sl.LoadFromFile(glHomePath+'\IRC_templates.txt');
    ConfItems['TemplatesList']:=sl.Text;
    sl.Free();
  end;

  // Create IRC client options form
  frmIrcOptions:=TfrmIrcOptions.Create(Core.MainForm);
  frmIrcOptions.ChatClient:=ChatClient;
  frmIrcOptions.FillConfigNodes(RootNode);

  // Load saved options and refresh all options list
  self.Load();
  self.RefreshItemsList();

  // Create sound config items

  // Создаем список кнопок
  FToolButtonsList:=TObjectList.Create(true);

  TB:=TToolButton.Create(frmIrcOptions);
  TB.Hint:='Away';
  TB.ImageIndex:=2;
  TB.Caption:='/AWAY '+self['AwayMessage'];
  TB.OnClick:=frmIrcOptions.ToolButtonClick;
  self.FToolButtons.tbtnAway:=TB;
  FToolButtonsList.Add(TB);

  TB:=TToolButton.Create(frmIrcOptions);
  TB.Hint:='Online';
  TB.ImageIndex:=3;
  TB.Caption:='/AWAY';
  TB.OnClick:=frmIrcOptions.ToolButtonClick;
  self.FToolButtons.tbtnOnline:=TB;
  FToolButtonsList.Add(TB);

  TB:=TToolButton.Create(frmIrcOptions);
  TB.Caption:='---';
  TB.Style:=tbsSeparator;
  FToolButtonsList.Add(TB);

  TB:=TToolButton.Create(frmIrcOptions);
  TB.Hint:='Channels';
  TB.ImageIndex:=9;
  TB.OnClick:=frmIrcOptions.menuChannelsShow;
  self.FToolButtons.tbtnChanList:=TB;
  self.FToolButtons.tbtnChanList.Enabled:=false;
  FToolButtonsList.Add(TB);

  TB:=TToolButton.Create(frmIrcOptions);
  TB.Hint:='Connect';
  TB.ImageIndex:=1;
  TB.Caption:='/SERVER';
  TB.OnClick:=frmIrcOptions.ToolButtonClick;
  self.FToolButtons.tbtnConnect:=TB;
  FToolButtonsList.Add(TB);

end;

destructor TIrcConf.Destroy();
begin
  FToolButtonsList.Free();
  frmIrcOptions.Release();
end;

//======================================
// Connection page
//======================================
constructor TfrmIrcOptions.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  with cboxSSLType.Items do
  begin
    Clear();
    Add('NONE');
    Add('AUTO');
    Add('SSLv2');
    Add('SSLv3');
    Add('TLSv1');
    Add('TLSv1.1');
    Add('SSHv2');
  end;
end;

procedure TfrmIrcOptions.SetNewNick(Sender :TObject);
begin
  if listNickList.ItemIndex > (listNickList.Count-1) then Exit;
  if listNickList.ItemIndex < 0 then Exit;
    editNick.Text := listNickList.Items.Strings[listNickList.ItemIndex]
end;

procedure TfrmIrcOptions.SetNewServer(Sender: TObject);
var
    i : integer;
  n : string;
begin
  if listServerList.ItemIndex > (listServerList.Count-1) then Exit;
  if listServerList.ItemIndex < 0 then Exit;
    n := listServerList.Items.Strings[listServerList.ItemIndex];
    i := Pos(':', n);
  editServerName.Text := Copy(n, 1, i-1);
  editServerPort.Text := Copy(n, i+1, Length(n)-i+1);
end;

procedure TfrmIrcOptions.AddNickClick(Sender: TObject);
var
    i: integer;
begin
  if Length(Trim(editNick.Text)) > 0 then
  begin
      for i := 0 to listNickList.Count - 1 do
      if AnsiLowerCase(listNickList.Items.Strings[i]) = AnsiLowerCase(editNick.Text) then exit;
    listNickList.Items.Add(editNick.Text);
  end;
end;

procedure TfrmIrcOptions.DelNickClick(Sender: TObject);
var
    i: integer;
begin
  i:=listNickList.ItemIndex;
  listNickList.Items.Delete(i);
  if i > 0 then listNickList.ItemIndex := i-1;
end;

procedure TfrmIrcOptions.AddServerClick(Sender: TObject);
var
    i: integer;
begin
  if (Length(Trim(editServerName.Text)) > 0) And (Length(Trim(editServerPort.Text)) > 0) then
  begin
    for i := 0 to listServerList.Count - 1 do
      if AnsiLowerCase(listServerList.Items.Strings[i]) = AnsiLowerCase(editServerName.Text+':'+editServerPort.Text) then exit;
    listServerList.Items.Add(editServerName.Text+':'+editServerPort.Text);
  end;
end;

procedure TfrmIrcOptions.DelServerClick(Sender: TObject);
var
    i: integer;
begin
  i:=listServerList.ItemIndex;
  listServerList.Items.Delete(i);
  if i > 0 then listServerList.ItemIndex := i-1;
end;

//======================================
// Sound page
//======================================
procedure FillSoundOptions(ConfItems: TConfItems; vleSounds: TValueListEditor);
var
  slSoundNames: TStringList;
  sd: char;
  sKey: string;
  i, n: integer;
  ItemProp: TItemProp;
begin
  //if not Assigned(Form2) then Exit;

  // Список названий звуковых событий
  slSoundNames:=TStringList.Create();
  sd:=slSoundNames.NameValueSeparator;
  with slSoundNames do
  begin
    slSoundNames.Add('sfxChanMsg'+sd+sIrcSoundChannelMessage);
    slSoundNames.Add('sfxPvtMsg' +sd+sIrcSoundPrivateMessage);
    slSoundNames.Add('sfxMeMsg'  +sd+sIrcSoundMeMessage);
    slSoundNames.Add('sfxNoteMsg'+sd+sIrcSoundNoticeMessage);
    slSoundNames.Add('sfxDccChat'+sd+sIrcSoundDccChat);
    slSoundNames.Add('sfxDccFile'+sd+sIrcSoundDccFile);
    slSoundNames.Add('sfxConnect'+sd+sIrcSoundServerConnect);
    slSoundNames.Add('sfxDisconnect'+sd+sIrcSoundServerDisconnect);
    slSoundNames.Add('sfxJoin'   +sd+sIrcSoundJoinChannel);
    slSoundNames.Add('sfxLeave'  +sd+sIrcSoundLeaveChannel);
    slSoundNames.Add('sfxError'  +sd+sIrcSoundErrorMessage);
    slSoundNames.Add('sfxOther'  +sd+sIrcSoundOther);
    //slSoundNames.Add(''+sd+'');
  end;

  // Очистка и заполнение визуального списка звуков
  // !! если Strings изначально пуст - будет ошибка!
  if Assigned(vleSounds) then
  begin
    for i:=vleSounds.RowCount-1 downto 1 do
    begin
      vleSounds.DeleteRow(i);
    end;
  end;

  for i:=0 to slSoundNames.Count-1 do
  begin
    sKey:=slSoundNames.Names[i];
    //n:=vleSounds.InsertRow(sKey, MainConf.slSoundFiles.Values[sKey], true);
    //!!
    if Assigned(vleSounds) then
    begin
      n:=vleSounds.InsertRow(sKey, '', true);
      ItemProp:=vleSounds.ItemProps[sKey];
      ItemProp.KeyDesc:=slSoundNames.ValueFromIndex[i];
      ItemProp.EditStyle:=esEllipsis;
      //ItemProp.MaxLength:=3;
      //ItemProp.EditMask:='!990';
    end;
    if Assigned(ConfItems) then
    begin
      ConfItems.Add(sKey, slSoundNames.ValueFromIndex[i], '');
    end;
  end;
  FreeAndNil(slSoundNames);
end;

// При клике кнопки выбора в списке звуков
procedure TfrmIrcOptions.vleSoundsEditButtonClick(Sender: TObject);
var
 fsd: TOpenDialog;
 curKey: string;
begin
  if not (sender = vleSounds) then Exit;
  curKey:=vleSounds.Keys[vleSounds.Row];
  fsd:=TOpenDialog.Create(self);
  fsd.Filter:='WAV files|*.wav|All files|*.*';
  fsd.FileName:=vleSounds.Values[curKey];
  if fsd.Execute then vleSounds.Values[curKey]:=fsd.FileName;
  FreeAndNil(fsd);
end;

procedure TfrmIrcOptions.btnSoundTestClick(Sender: TObject);
begin
  PlaySoundFile(vleSounds.Values[vleSounds.Keys[vleSounds.Row]]);
end;

//======================================
// Options items list
//======================================
procedure TfrmIrcOptions.FillConfigNodes(RootNode: TConfNode);
var
  NewNode: TConfNode;
  NewNode2: TConfNode;
begin
  // IRC root node
  //NewNode:=TConfNode.Create(RootNode);
  RootNode.OnApplySettings:=OnApplySettingsHandler;
  RootNode.OnRefreshSettings:=OnRefreshSettingsHandler;
  RootNode.Panel:=gbConnection;
  //FillConfItems(RootNode);
  FillSoundOptions(RootNode.ConfItems, vleSounds);
  //NewNode.ConfItems:=TConfItems.Create(NewNode.Name);
  NewNode2:=RootNode;

  {// Connection
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:=tsConnection.Caption;
  NewNode.FullName:=gbConnection.Caption;
  //NewNode.ConfItems:=TConfItems.Create(NewNode.Name);
  //FillItems_AvatarsOptions(NewNode.ConfItems);
  NewNode.Panel:=gbConnection;}

  // IRC Main
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='IRCMain';
  NewNode.FullName:=gbIRCMain.Caption;
  NewNode.Panel:=gbIRCMain;

  // Autojoin
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Autojoin';
  NewNode.FullName:=gbAutojoin.Caption;
  NewNode.Panel:=gbAutojoin;

  // Templates
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Templates';
  NewNode.FullName:=gbTemplates.Caption;
  NewNode.Panel:=gbTemplates;

  // Ignore
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Ignore';
  NewNode.FullName:=gbIgnore.Caption;
  NewNode.Panel:=gbIgnore;

  // NickServ
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='NickServ';
  NewNode.FullName:=gbNickServ.Caption;
  NewNode.Panel:=gbNickServ;

  // Sounds
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Sounds';
  NewNode.FullName:=gbSounds.Caption;
  NewNode.Panel:=gbSounds;

  // Notes
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Notes';
  NewNode.FullName:=gbNotes.Caption;
  NewNode.Panel:=gbNotes;

  // Notes
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='SimpleBot';
  NewNode.FullName:=gbSimpleBot.Caption;
  NewNode.Panel:=gbSimpleBot;

  // Other options
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='AllOptions';
  NewNode.FullName:='All options';
  NewNode.ConfItems:=RootNode.ConfItems;
  //FillItems_AvatarsOptions(NewNode.ConfItems);
  //NewNode.Panel:=gbConnection;

  RefreshSettings(RootNode);
end;

procedure TfrmIrcOptions.RefreshSettings(ConfNode: TConfNode);
var
  conf: TConfItems;
  i: integer;
begin
  conf:=ConfNode.ConfItems;
  // установка значений
  cbAutoConnect.Checked      := (conf['AutoConnect']='1');
  cbAutoReconnect.Checked    := (conf['AutoReconnect']='1');
  cbShowServerPing.Checked   := (conf['ShowServerPing']='1');
  cbShowNotesOnJoin.Checked  := (conf['ShowNotesOnJoin']='1');
  //cbUseAvatars.Checked       := (conf['UseAvatars']='1');
  cbLogMessages.Checked      := (conf['LogMessages']='1');
  cbShowStatusMessages.Checked:= (conf['ShowStatusMessages']='1');
  cbPlaySounds.Checked       := (conf['PlaySounds']='1');
  cbSendUTF8.Checked         := (conf['SendUTF8']='1');
  cbReceiveUTF8.Checked      := (conf['ReceiveUTF8']='1');

    editAway.text              := conf['AwayMessage'];
  editQuitMessage.Text       := conf['QuitMessage'];
  editFullName.Text          := conf['MyFullName'];
  editOtherNick.Text         := conf['MySecondNick'];

  mAutojoinList.Lines.Text   := conf['AutojoinList'];
  //memoFastMSG.Lines.Text     := conf['FastMSGList'];
  memoNotes.Lines.Text       := conf['NotesList'];
  memoIgnore.Lines.Text      := conf['IgnoreList'];
  memoTemplates.Lines.Text   := conf['TemplatesList'];
  //memoGrabKeywords.Lines.Text:= conf['NotesKeywordsLit'];
  memoSimpleBot.Lines.Text    := conf['SimpleBot'];
  cbSimpleBotEnable.Checked   := (conf['SimpleBotEnabled']='1');

  listServerList.Items.Text  := conf['ServersList'];
  listNickList.Items.Text    := conf['NicksList'];
  editServerName.Text        := conf['ServerHost'];
  editServerPort.Text        := conf['ServerPort'];
  editNick.Text              := conf['MyNick'];
  cboxProxyServer.Text       := conf['ServerProxy'];

  cboxSSLType.ItemIndex:=cboxSSLType.Items.IndexOf(conf['SSLType']);
  //cboxSSLType.Text           := conf['SSLType'];

  eNServNick.Text            := conf['NSNick'];
  eNServPassw.Text           := conf['NSPassword'];
  eNServEmail.Text           := conf['NSEmail'];
  cbNServAutoLogin.Checked   := (conf['NSAutoLogin']='1');

  // Восстановление звуков
  for i:=1 to vleSounds.RowCount-1 do
  begin
    if Trim(conf[vleSounds.Keys[i]])<>'' then
    begin
      vleSounds.Values[vleSounds.Keys[i]]:=conf[vleSounds.Keys[i]];
    end;
  end;

end;

procedure TfrmIrcOptions.ApplySettings(ConfNode: TConfNode);
var
  conf: TConfItems;
  i: integer;

function GetBoolStr(b: boolean): string;
begin
  result:='0';
  if b then result:='1';
end;

begin
  conf:=ConfNode.ConfItems;

  // установка значений
  conf['AutoConnect']:=GetBoolStr(cbAutoConnect.Checked);
  conf['AutoReconnect']:=GetBoolStr(cbAutoReconnect.Checked);
  conf['ShowServerPing']:=GetBoolStr(cbShowServerPing.Checked);
  conf['ShowNotesOnJoin']:=GetBoolStr(cbShowNotesOnJoin.Checked);
  //conf['UseAvatars']:=GetBoolStr(cbUseAvatars.Checked);
  conf['LogMessages']:=GetBoolStr(cbLogMessages.Checked);
  conf['ShowStatusMessages']:=GetBoolStr(cbShowStatusMessages.Checked);
  conf['PlaySounds']:=GetBoolStr(cbPlaySounds.Checked);
  conf['SendUTF8']:=GetBoolStr(cbSendUTF8.Checked);
  conf['ReceiveUTF8']:=GetBoolStr(cbReceiveUTF8.Checked);

  conf['AwayMessage']:=editAway.text;
  conf['QuitMessage']:=editQuitMessage.Text;
  conf['MyFullName']:=editFullName.Text;
  conf['MySecondNick']:=editOtherNick.Text;

  conf['AutojoinList']:=mAutojoinList.Lines.Text;
  //conf['FastMSGList']:=memoFastMSG.Lines.Text;
  conf['NotesList']:=memoNotes.Lines.Text;
  conf['IgnoreList']:=memoIgnore.Lines.Text;
  conf['TemplatesList']:=memoTemplates.Lines.Text;
  //memoGrabKeywords.Lines.Text:= conf['NotesKeywordsLit'];
  conf['SimpleBot']:=memoSimpleBot.Lines.Text;
  conf['SimpleBotEnabled']:=GetBoolStr(cbSimpleBotEnable.Checked);

  conf['ServersList']:=listServerList.Items.Text;
  conf['NicksList']:=listNickList.Items.Text;
  conf['ServerHost']:=editServerName.Text;
  conf['ServerPort']:=editServerPort.Text;
  conf['MyNick']:=editNick.Text;
  conf['ServerProxy']:=cboxProxyServer.Text;
  conf['SSLType']:=cboxSSLType.Text;

  conf['NSNick']:=eNServNick.Text;
  conf['NSPassword']:=eNServPassw.Text;
  conf['NSEmail']:=eNServEmail.Text;
  conf['NSAutoLogin']:=GetBoolStr(cbNServAutoLogin.Checked);

  // Сохранение звуков
  for i:=1 to vleSounds.RowCount-1 do
  begin
    if Trim(vleSounds.Values[vleSounds.Keys[i]])<>'' then
    begin
      conf[vleSounds.Keys[i]]:=vleSounds.Values[vleSounds.Keys[i]];
    end;
  end;

end;

procedure TfrmIrcOptions.OnApplySettingsHandler(Sender: TObject);
begin
  ApplySettings(TConfNode(Sender));
end;

procedure TfrmIrcOptions.OnRefreshSettingsHandler(Sender: TObject);
begin
  RefreshSettings(TConfNode(Sender));
end;

//======================================
// Channel list button
//======================================
procedure TfrmIrcOptions.menuChannelsClick(Sender: TObject);
// Обработчик меню кнопки списка каналов
var
  m: TMenuItem;
  i: integer;
begin
  if Sender is TMenuItem then m:=(Sender as TMenuItem) else Exit;

  if m = mAllChannels then
  begin // Все каналы
    Say('/LIST');
    Exit;
  end;

  if m = mChannelsByMask then
  begin // Каналы по имени
    Core.EnterCommandBox('/RAW LIST *&s*', sChanListChanMask, '', Core.PagesManager.GetActivePage.PageID);
    Exit;
  end;

  // Канал
  Say('/JOIN '+m.Caption);

end;

procedure TfrmIrcOptions.ToolButtonClick(Sender: TObject);
var
  TB: TToolButton;
begin
  if Sender is TToolButton then TB:=(Sender as TToolButton) else Exit;

  if TB.Caption<>'' then Say(TB.Caption);
end;

procedure TfrmIrcOptions.menuChannelsShow(Sender: TObject);
var
  i: integer;
  mi: TMenuItem;
  sl: TStringList;
begin
  if not (Sender is TToolButton) then Exit;
  with menuChannels do
  begin
    if Items.Count>2 then
      for i:=Items.Count-1 downto 2 do Items.Delete(i);
    sl:=TStringList.Create();
    sl.Text:=ChatClient.GetOption('RecentChannelsList');
    if sl.Count>0 then
    begin
      mi:=TMenuItem.Create(self);
      mi.Caption:='-';
      Items.Add(mi);
      for i:=0 to sl.Count-1 do
      begin
        mi:=TMenuItem.Create(self);
        mi.AutoHotkeys:=maManual;
        mi.Caption:=sl[i];
        mi.OnClick:=menuChannelsClick;
        Items.Add(mi);
      end;
    end;
    sl.Free();
    Popup(TButton(Sender).ClientOrigin.X, TButton(Sender).ClientOrigin.Y);
  end;
end;

procedure TfrmIrcOptions.ChangeLanguage();
var
  RootNode: TConfNode;

function GetStr(Name: string; s: string): string;
begin
  result:=Core.LangIni.ReadString('IRC_Options', Name, s);
end;

procedure SetNodeCaption(sNodeName, sCaption: string);
var
  cn: TConfNode;
begin
  cn:=RootNode.GetChildByName(sNodeName);
  if cn <> nil then cn.FullName:=sCaption;
end;

begin

  if not Assigned(Core.LangIni) then Exit;
  try
    RootNode:=self.ChatClient.GetConf().RootNode;
    // IRC Main
    gbIRCMain.Caption:=GetStr('gbIRCMain.Caption', gbIRCMain.Caption);
    SetNodeCaption('IRCMain', gbIRCMain.Caption);

    gbIrcMessages.Caption:=GetStr('gbIrcMessages.Caption', gbIrcMessages.Caption);
    lbAway.Caption:=GetStr('lbAway.Caption', lbAway.Caption);
    lbQuitMessage.Caption:=GetStr('lbQuitMessage.Caption', lbQuitMessage.Caption);
    cbReceiveUTF8.Caption:=GetStr('cbReceiveUTF8.Caption', cbReceiveUTF8.Caption);
    cbSendUTF8.Caption:=GetStr('cbSendUTF8.Caption', cbSendUTF8.Caption);

    gbOtherNick.Caption:=GetStr('gbOtherNick.Caption', gbOtherNick.Caption);
    lbFullName.Caption:=GetStr('lbFullName.Caption', lbFullName.Caption);
    lbOtherNick.Caption:=GetStr('lbOtherNick.Caption', lbOtherNick.Caption);

    gbOther.Caption:=GetStr('gbOther.Caption', gbOther.Caption);
    cbAutoConnect.Caption:=GetStr('cbAutoConnect.Caption', cbAutoConnect.Caption);
    cbAutoReconnect.Caption:=GetStr('cbAutoReconnect.Caption', cbAutoReconnect.Caption);
    cbLogMessages.Caption:=GetStr('cbLogMessages.Caption', cbLogMessages.Caption);
    cbShowServerPing.Caption:=GetStr('cbShowServerPing.Caption', cbShowServerPing.Caption);
    cbShowStatusMessages.Caption:=GetStr('cbShowStatusMessages.Caption', cbShowStatusMessages.Caption);

    // NickServ
    gbNickServ.Caption:=GetStr('gbNickServ.Caption', gbNickServ.Caption);
    SetNodeCaption('NickServ', gbNickServ.Caption);
    btnNickServ1.Caption:=GetStr('btnNickServ1.Caption', btnNickServ1.Caption);
    btnNickServ2.Caption:=GetStr('btnNickServ2.Caption', btnNickServ2.Caption);
    cbNServAutoLogin.Caption:=GetStr('cbNServAutoLogin.Caption', cbNServAutoLogin.Caption);
    lbNickServ1.Caption:=GetStr('lbNickServ1.Caption', lbNickServ1.Caption);
    lbNickServ2.Caption:=GetStr('lbNickServ2.Caption', lbNickServ2.Caption);
    lbNickServ3.Caption:=GetStr('lbNickServ3.Caption', lbNickServ3.Caption);
    lbNickServ4.Caption:=GetStr('lbNickServ4.Caption', lbNickServ4.Caption);

    // Connection
    gbConnection.Caption:=GetStr('gbConnection.Caption', gbConnection.Caption);
    SetNodeCaption('Connection', gbConnection.Caption);
    gbNick.Caption:=GetStr('gbNick.Caption', gbNick.Caption);
    btnAddNick.Caption:=GetStr('btnAddNick.Caption', btnAddNick.Caption);
    btnDelNick.Caption:=GetStr('btnDelNick.Caption', btnDelNick.Caption);
    gbProxy.Caption:=GetStr('gbProxy.Caption', gbProxy.Caption);
    gbServer.Caption:=GetStr('gbServer.Caption', gbServer.Caption);
    btnAddServer.Caption:=GetStr('btnAddServer.Caption', btnAddServer.Caption);
    btnDelServer.Caption:=GetStr('btnDelServer.Caption', btnDelServer.Caption);
    lbServerName.Caption:=GetStr('lbServerName.Caption', lbServerName.Caption);
    lbServerPort.Caption:=GetStr('lbServerPort.Caption', lbServerPort.Caption);

    // Autojoin
    gbAutojoin.Caption:=GetStr('gbAutojoin.Caption', gbAutojoin.Caption);
    SetNodeCaption('Autojoin', gbAutojoin.Caption);
    lbAJList.Caption:=GetStr('lbAJList.Caption', lbAJList.Caption);

    // Ignore
    gbIgnore.Caption:=GetStr('gbIgnore.Caption', gbIgnore.Caption);
    SetNodeCaption('Ignore', gbIgnore.Caption);
    lbIgnore1.Caption:=GetStr('lbIgnore1.Caption', lbIgnore1.Caption);
    lbIgnore2.Caption:=GetStr('lbIgnore2.Caption', lbIgnore2.Caption);
    lbIgnore3.Caption:=GetStr('lbIgnore3.Caption', lbIgnore3.Caption);

    // Templates
    gbTemplates.Caption:=GetStr('gbTemplates.Caption', gbTemplates.Caption);
    SetNodeCaption('Templates', gbTemplates.Caption);
    lbTemplates1.Caption:=GetStr('lbTemplates1.Caption', lbTemplates1.Caption);
    lbTemplates6.Caption:=GetStr('lbTemplates6.Caption', lbTemplates6.Caption);
    lbTemplates7.Caption:=GetStr('lbTemplates7.Caption', lbTemplates7.Caption);
    lbTemplates8.Caption:=GetStr('lbTemplates8.Caption', lbTemplates8.Caption);
    lbTemplates9.Caption:=GetStr('lbTemplates9.Caption', lbTemplates9.Caption);

    // Sounds
    gbSounds.Caption:=GetStr('gbSounds.Caption', gbSounds.Caption);
    SetNodeCaption('Sounds', gbSounds.Caption);
    cbPlaySounds.Caption:=GetStr('cbPlaySounds.Caption', cbPlaySounds.Caption);
    lbSoundTest.Caption:=GetStr('lbSoundTest.Caption', lbSoundTest.Caption);
    //FillSoundOptions(RootNode.ConfItems, vleSounds);
    FillSoundOptions(nil, vleSounds);

    // Notes
    gbNotes.Caption:=GetStr('gbNotes.Caption', gbNotes.Caption);
    SetNodeCaption('Notes', gbNotes.Caption);
    cbShowNotesOnJoin.Caption:=GetStr('cbShowNotesOnJoin.Caption', cbShowNotesOnJoin.Caption);
    lbNotesReadme.Caption:=GetStr('lbNotesReadme.Caption', lbNotesReadme.Caption);

    // SimpleBot
    gbSimpleBot.Caption:=GetStr('gbSimpleBot.Caption', gbSimpleBot.Caption);
    SetNodeCaption('SimpleBot', gbSimpleBot.Caption);
    cbSimpleBotEnable.Caption:=GetStr('cbSimpleBotEnable.Caption', cbSimpleBotEnable.Caption);
    lbSimpleBot.Caption:=GetStr('lbSimpleBot.Caption', lbSimpleBot.Caption);
    lbSimpleBotExample.Caption:=GetStr('lbSimpleBotExample.Caption', lbSimpleBotExample.Caption);

    // Channels button menu
    mAllChannels.Caption:=GetStr('mAllChannels.Caption', mAllChannels.Caption);
    mChannelsByMask.Caption:=GetStr('mChannelsByMask.Caption', mChannelsByMask.Caption);
  finally
  end;
end;


procedure TfrmIrcOptions.btnNickServClick(Sender: TObject);
var
  i: integer;
  sl: TStringList;
  s, sNick, sPass, sEmail: string;
  pi: TPageInfo;
begin
  // get server page info
  if ChatClient.PagesIDCount=0 then Exit;
  i:=ChatClient.PagesIDList[0];
  if not Core.PagesManager.GetPageInfo(i, pi) then Exit;

  sNick:=eNServNick.Text;
  sPass:=eNServPassw.Text;
  sEmail:=eNServEmail.Text;

  // Send text
  sl:=TStringList.Create();
  if Sender=btnNickServ1 then
    sl.Text:=ChatClient.GetOption('NSRegister')
  else if Sender=btnNickServ2 then
    sl.Text:=ChatClient.GetOption('NSLogin')
  else
  begin
    sl.Free();
    Exit;
  end;
  for i:=0 to sl.Count-1 do
  begin
    s:=sl[i];
    s:=StringReplace(s, '<nick>', sNick, [rfReplaceAll]);
    s:=StringReplace(s, '<passw>', sPass, [rfReplaceAll]);
    s:=StringReplace(s, '<email>', sEmail, [rfReplaceAll]);
    ChatClient.SendTextFromPage(pi, s);
    //Say(s);
  end;
  sl.Free();
end;

procedure TfrmIrcOptions.cboxProxyServerDropDown(Sender: TObject);
begin
  // Fill proxy list
  cboxProxyServer.Items.BeginUpdate();
  cboxProxyServer.Items:=MainConf.GetStrings('ProxyList');
  cboxProxyServer.Items.EndUpdate();
end;

end.
