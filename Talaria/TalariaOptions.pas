unit TalariaOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ValEdit, StdCtrls, ComCtrls, Core, Configs, Contnrs, Misc;

type
  TfrmTalariaOptions = class(TForm)
    pgcOptions: TPageControl;
    tsMain: TTabSheet;
    gbiChatMain: TGroupBox;
    gbMsgSettings: TGroupBox;
    lbQuitMessage: TLabel;
    lbAway: TLabel;
    editQuitMessage: TEdit;
    editAway: TEdit;
    cbSendUTF8: TCheckBox;
    cbReceiveUTF8: TCheckBox;
    gbOther: TGroupBox;
    cbAutoReconnect: TCheckBox;
    cbAutoConnect: TCheckBox;
    cbShowServerPing: TCheckBox;
    cbLogMessages: TCheckBox;
    cbShowStatusMessages: TCheckBox;
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
    editProxyServer: TEdit;
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
    tsNotes: TTabSheet;
    gbNotes: TGroupBox;
    lbNotesReadme: TLabel;
    memoNotes: TMemo;
    cbShowNotesOnJoin: TCheckBox;
    editHelloMessage: TEdit;
    lbHelloMessage: TLabel;
    cbDebugMessages: TCheckBox;
    cbLocalEcho: TCheckBox;
    procedure SetNewNick(Sender :TObject);
    procedure SetNewServer(Sender: TObject);
    procedure AddNickClick(Sender: TObject);
    procedure DelNickClick(Sender: TObject);
    procedure AddServerClick(Sender: TObject);
    procedure DelServerClick(Sender: TObject);
    procedure vleSoundsEditButtonClick(Sender: TObject);
    procedure btnSoundTestClick(Sender: TObject);
    procedure ToolButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure OnApplySettingsHandler(Sender: TObject);
    procedure OnRefreshSettingsHandler(Sender: TObject);
  public
    { Public declarations }
    ChatClient: TChatClient;
    procedure FillConfigNodes(RootNode: TConfNode);
    procedure RefreshSettings(ConfNode: TConfNode);
    procedure ApplySettings(ConfNode: TConfNode);
    procedure ChangeLanguage();
  end;

  TTalariaToolButtons = record
    tbtnConnect: TToolButton;
    tbtnChanList: TToolButton;
    tbtnOnline: TToolButton;
    tbtnAway: TToolButton;
  end;

  TTalariaConf = class(TConf)
  public
    ChatClient: TChatClient;
    frmTalariaOptions: TfrmiChatOptions;
    FToolButtons: TTalariaToolButtons;
    FToolButtonsList: TObjectList;
    constructor Create(ChatClient: TChatClient; ConfFileName: string);
    destructor Destroy(); override;
  end;

  procedure FillSoundOptions(ConfItems: TConfItems; vleSounds: TValueListEditor);

var
  frmTalariaOptions: TfrmTalariaOptions;

implementation
uses Sounds, iChatUnit;

{$R *.dfm}

constructor TIChatConf.Create(ChatClient: TChatClient; ConfFileName: string);
var
  sl: TStringList;
  ConfItems: TConfItems;
  TB: TToolButton;
begin
  self.ChatClient := ChatClient;
  self.FileName := glUserPath+ConfFileName;

  // Create config's root node
  RootNode:=TConfNode.Create(nil);
  RootNode.Name:='Talaria_Options';
  RootNode.FullName:='Talaria';
  RootNode.ConfItems:=TConfItems.Create(RootNode.Name);

  // Filll config items by default values
  ConfItems:=RootNode.ConfItems;
  //ConfItems.Add('Name', 'Full name', 'Value', 'Type');
  ConfItems.Add('MyNick', 'My nick', GetWinUserName(), 'S');
  ConfItems.Add('ServerHost', 'Server host addr', '', 'S');
  ConfItems.Add('ServerPort', 'Server port number', '4044', 'S');
  ConfItems.Add('ServerProxy', 'Proxy server', '', 'S');
  ConfItems.Add('ProxyType', 'Proxy type: 0-none, 1-HTTP, 5-Socks5', '1', 'I');
  ConfItems.Add('ProxyUser', 'Proxy username', '', 'S');
  ConfItems.Add('ProxyPass', 'Proxy password', '', 'S');
  ConfItems.Add('ClientVersion', 'Client version', 'Talaria client for RealChat ver. 0.1', 'S');
  ConfItems.Add('AvatarURL', 'Avatar URL', '', 'S');
  ConfItems.Add('HelloMessage', 'Hello message', 'Всем привет!', 'S');
  ConfItems.Add('AwayMessage', 'Avay message', 'Меня здесь нет!', 'S');
  ConfItems.Add('QuitMessage', 'Quit message', 'RealChat - http://irchat.ru', 'S');
  ConfItems.Add('HostName', 'Host name', '', 'S');
  ConfItems.Add('UserName', 'User name', '', 'S');

  ConfItems.Add('SaveFilesDir', 'Patch for received files', 'Incoming', 'S');
  ConfItems.Add('AvatarPath', 'Patch for received avatars', 'Avatars', 'S');
  ConfItems.Add('LogsPath', 'Patch for log files', 'Logs', 'S');

  ConfItems.Add('RefreshPeriod', 'Refresh period', '120', 'I');
  ConfItems.Add('ReplyTimeout', 'Reply timeout', '60', 'I');

  ConfItems.Add('AutoConnect', 'Auto connect', '0', 'B');
  ConfItems.Add('AutoReconnect', 'Auto reconnect', '1', 'B');
  ConfItems.Add('UseAvatars', 'Use avatars', '0', 'B');
  ConfItems.Add('LogMessages', 'Log messages', '0', 'B');
  ConfItems.Add('SendUTF8', 'Send text in UTF8 encoding', '0', 'B');
  ConfItems.Add('ReceiveUTF8', 'Receive text in UTF8 encoding', '0', 'B');
  ConfItems.Add('ShowServerPing', 'Show server Ping messages', '1', 'B');
  ConfItems.Add('ShowStatusMessages', 'Show status messages', '0', 'B');
  ConfItems.Add('PostMyBoardNotes', 'Post message board message', '0', 'B');
  ConfItems.Add('DebugMessages', 'Debug info messages', '0', 'B');
  ConfItems.Add('LocalEcho', 'Local echo messages', '0', 'B');
  ConfItems.Add('EnableCheats', 'Security test mode', '0', 'B');

  ConfItems.Add('NicksList', 'Recent nicks', '', 'T');
  ConfItems.Add('ServersList', 'Recent servers', '', 'T');
  ConfItems.Add('AutojoinList', 'Comands on connect', '', 'T');
  ConfItems.Add('NotesList', 'Notes', '', 'T');
  ConfItems.Add('IgnoreList', 'Ignore nicks', '', 'T');
  ConfItems.Add('TemplatesList', 'Templates', '', 'T');
  //ConfItems.Add('NotesKeywordsList', 'Grab notes keywords', '', 'T');
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
  {if FileExists(HomePath+'\templates.txt') then
  begin
    sl:=TStringList.Create();
    sl.LoadFromFile(HomePath+'\templates.txt');
    ConfItems['TemplatesList']:=sl.Text;
    sl.Free();
  end;}

  // Create iChat client options form
  frmTalariaOptions:=TfrmTalariaOptions.Create(Core.MainForm);
  frmTalariaOptions.ChatClient:=ChatClient;
  frmTalariaOptions.FillConfigNodes(RootNode);

  // Load saved options and refresh all options list
  self.Load();
  self.RefreshItemsList();

  // Создаем список кнопок
  FToolButtonsList:=TObjectList.Create();

  TB:=TToolButton.Create(frmTalariaOptions);
  TB.Hint:='Away';
  TB.ImageIndex:=2;
  TB.Caption:='/AWAY '+self['AwayMessage'];
  TB.OnClick:=frmTalariaOptions.ToolButtonClick;
  self.FToolButtons.tbtnAway:=TB;
  FToolButtonsList.Add(TB);

  TB:=TToolButton.Create(frmTalariaOptions);
  TB.Hint:='Online';
  TB.ImageIndex:=3;
  TB.Caption:='/AWAY';
  TB.OnClick:=frmTalariaOptions.ToolButtonClick;
  self.FToolButtons.tbtnOnline:=TB;
  FToolButtonsList.Add(TB);

  TB:=TToolButton.Create(frmTalariaOptions);
  TB.Caption:='---';
  TB.Style:=tbsSeparator;
  FToolButtonsList.Add(TB);

  {TB:=TToolButton.Create(frmiChatOptions);
  TB.Hint:='Channels';
  TB.ImageIndex:=9;
  TB.OnClick:=frmiChatOptions.menuChannelsShow;
  self.FToolButtons.tbtnChanList:=TB;
  self.FToolButtons.tbtnChanList.Enabled:=false;
  FToolButtonsList.Add(TB);}

  TB:=TToolButton.Create(frmTalariaOptions);
  TB.Hint:='Connect';
  TB.ImageIndex:=1;
  TB.Caption:='/CONNECT';
  TB.OnClick:=frmTalariaOptions.ToolButtonClick;
  self.FToolButtons.tbtnConnect:=TB;
  FToolButtonsList.Add(TB);

end;

destructor TIChatConf.Destroy();
begin
  FToolButtonsList.Free();
  frmTalariaOptions.Release();
  inherited Destroy();
end;

//======================================
// Connection page
//======================================
procedure TfrmTalariaOptions.SetNewNick(Sender :TObject);
begin
  if listNickList.ItemIndex > (listNickList.Count-1) then Exit;
  if listNickList.ItemIndex < 0 then Exit;
	editNick.Text := listNickList.Items.Strings[listNickList.ItemIndex]
end;

procedure TfrmTalariaOptions.SetNewServer(Sender: TObject);
var
	i : integer;
  n : string;
begin
  if listServerList.ItemIndex > (listServerList.Count-1) then Exit;
  if listServerList.ItemIndex < 0 then Exit;
	n := listServerList.Items.Strings[listServerList.ItemIndex];
	i := Pos(':', n);
  editServerName.Text := copy(n, 1, i-1);
  editServerPort.Text := copy(n, i+1, Length(n)-i+1);
end;

procedure TfrmTalariaOptions.AddNickClick(Sender: TObject);
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

procedure TfrmTalariaOptions.DelNickClick(Sender: TObject);
var
	i: integer;
begin
  i:=listNickList.ItemIndex;
  listNickList.Items.Delete(i);
  if i > 0 then listNickList.ItemIndex := i-1;
end;

procedure TfrmTalariaOptions.AddServerClick(Sender: TObject);
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

procedure TfrmTalariaOptions.DelServerClick(Sender: TObject);
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
    slSoundNames.Add('sfxChanMsg'+sd+sIChatSoundChannelMessage);
    slSoundNames.Add('sfxPvtMsg' +sd+sIChatSoundPrivateMessage);
    slSoundNames.Add('sfxMeMsg'  +sd+sIChatSoundMeMessage);
    //slSoundNames.Add('sfxNoteMsg'+sd+sIChatSoundNoticeMessage);
    //slSoundNames.Add('sfxDccChat'+sd+sIChatSoundDccChat);
    //slSoundNames.Add('sfxDccFile'+sd+sIChatSoundDccFile);
    slSoundNames.Add('sfxConnect'+sd+sIChatSoundServerConnect);
    slSoundNames.Add('sfxDisconnect'+sd+sIChatSoundServerDisconnect);
    slSoundNames.Add('sfxJoin'   +sd+sIChatSoundJoinChannel);
    slSoundNames.Add('sfxLeave'  +sd+sIChatSoundLeaveChannel);
    slSoundNames.Add('sfxError'  +sd+sIChatSoundErrorMessage);
    slSoundNames.Add('sfxOther'  +sd+sIChatSoundOther);
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
procedure TfrmTalariaOptions.vleSoundsEditButtonClick(Sender: TObject);
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

procedure TfrmTalariaOptions.btnSoundTestClick(Sender: TObject);
begin
  PlaySoundFile(vleSounds.Values[vleSounds.Keys[vleSounds.Row]]);
end;

//======================================
// Options items list
//======================================
procedure TfrmTalariaOptions.FillConfigNodes(RootNode: TConfNode);
var
  NewNode: TConfNode;
  NewNode2: TConfNode;
begin
  // iChat root node
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

  // iChat Main
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='iChatMain';
  NewNode.FullName:=gbiChatMain.Caption;
  NewNode.Panel:=gbiChatMain;

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

  // Other options
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='AllOptions';
  NewNode.FullName:='All options';
  NewNode.ConfItems:=RootNode.ConfItems;
  //FillItems_AvatarsOptions(NewNode.ConfItems);
  //NewNode.Panel:=gbConnection;

  RefreshSettings(RootNode);
end;

procedure TfrmTalariaOptions.RefreshSettings(ConfNode: TConfNode);
var
  conf: TConfItems;
  i: integer;
begin
  conf:=ConfNode.ConfItems;
  // установка значений
  cbAutoConnect.Checked      :=	(conf['AutoConnect']='1');
  cbAutoReconnect.Checked    :=	(conf['AutoReconnect']='1');
  cbShowServerPing.Checked   := (conf['ShowServerPing']='1');
  cbShowNotesOnJoin.Checked  := (conf['PostMyBoardNotes']='1');
  //cbUseAvatars.Checked       := (conf['UseAvatars']='1');
  cbLogMessages.Checked      := (conf['LogMessages']='1');
  cbShowStatusMessages.Checked:= (conf['ShowStatusMessages']='1');
  cbPlaySounds.Checked       := (conf['PlaySounds']='1');
  cbSendUTF8.Checked         := (conf['SendUTF8']='1');
  cbReceiveUTF8.Checked      := (conf['ReceiveUTF8']='1');
  cbDebugMessages.Checked    := (conf['DebugMessages']='1');
  cbLocalEcho.Checked        := (conf['LocalEcho']='1');

 	editAway.text              := conf['AwayMessage'];
  editQuitMessage.Text       := conf['QuitMessage'];
  editHelloMessage.Text      := conf['HelloMessage'];

  mAutojoinList.Lines.Text   := conf['AutojoinList'];
  //memoFastMSG.Lines.Text     := conf['FastMSGList'];
  memoNotes.Lines.Text       := conf['NotesList'];
  memoIgnore.Lines.Text      := conf['IgnoreList'];
  memoTemplates.Lines.Text   := conf['TemplatesList'];
  //memoGrabKeywords.Lines.Text:= conf['NotesKeywordsLit'];

  listServerList.Items.Text  := conf['ServersList'];
  listNickList.Items.Text    := conf['NicksList'];
  editServerName.Text        := conf['ServerHost'];
  editServerPort.Text        := conf['ServerPort'];
  editNick.Text              := conf['MyNick'];
  editProxyServer.Text       := conf['ServerProxy'];

  // Восстановление звуков
  for i:=0 to vleSounds.RowCount-1 do
  begin
    if Trim(conf[vleSounds.Keys[i]])<>'' then
    begin
      vleSounds.Values[vleSounds.Keys[i]]:=conf[vleSounds.Keys[i]];
    end;
  end;

end;

procedure TfrmTalariaOptions.ApplySettings(ConfNode: TConfNode);
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
  conf['PostMyBoardNotes']:=GetBoolStr(cbShowNotesOnJoin.Checked);
  //conf['UseAvatars']:=GetBoolStr(cbUseAvatars.Checked);
  conf['LogMessages']:=GetBoolStr(cbLogMessages.Checked);
  conf['ShowStatusMessages']:=GetBoolStr(cbShowStatusMessages.Checked);
  conf['PlaySounds']:=GetBoolStr(cbPlaySounds.Checked);
  conf['SendUTF8']:=GetBoolStr(cbSendUTF8.Checked);
  conf['ReceiveUTF8']:=GetBoolStr(cbReceiveUTF8.Checked);
  conf['DebugMessages']:=GetBoolStr(cbDebugMessages.Checked);
  conf['LocalEcho']:=GetBoolStr(cbLocalEcho.Checked);

 	conf['AwayMessage']:=editAway.text;
  conf['QuitMessage']:=editQuitMessage.Text;
  conf['HelloMessage']:=editHelloMessage.Text;

  conf['AutojoinList']:=mAutojoinList.Lines.Text;
  //conf['FastMSGList']:=memoFastMSG.Lines.Text;
  conf['NotesList']:=memoNotes.Lines.Text;
  conf['IgnoreList']:=memoIgnore.Lines.Text;
  conf['TemplatesList']:=memoTemplates.Lines.Text;
  //memoGrabKeywords.Lines.Text:= conf['NotesKeywordsLit'];

  conf['ServersList']:=listServerList.Items.Text;
  conf['NicksList']:=listNickList.Items.Text;
  conf['ServerHost']:=editServerName.Text;
  conf['ServerPort']:=editServerPort.Text;
  conf['MyNick']:=editNick.Text;
  conf['ServerProxy']:=editProxyServer.Text;

  // Сохранение звуков
  for i:=0 to vleSounds.RowCount-1 do
  begin
    if Trim(vleSounds.Values[vleSounds.Keys[i]])<>'' then
    begin
      conf[vleSounds.Keys[i]]:=vleSounds.Values[vleSounds.Keys[i]];
    end;
  end;

end;

procedure TfrmTalariaOptions.OnApplySettingsHandler(Sender: TObject);
begin
  ApplySettings(TConfNode(Sender));
end;

procedure TfrmTalariaOptions.OnRefreshSettingsHandler(Sender: TObject);
begin
  RefreshSettings(TConfNode(Sender));
end;

procedure TfrmTalariaOptions.ToolButtonClick(Sender: TObject);
var
  TB: TToolButton;
begin
  if Sender is TToolButton then TB:=(Sender as TToolButton) else Exit;

  if TB.Caption<>'' then Say(TB.Caption);
end;

procedure TfrmTalariaOptions.ChangeLanguage();
var
  RootNode: TConfNode;

function GetStr(Name: string; s: string): string;
begin
  result:=Core.LangIni.ReadString('iChat_Options', Name, s);
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
    // iChat Main
    gbiChatMain.Caption:=GetStr('gbiChatMain.Caption', gbiChatMain.Caption);
    SetNodeCaption('iChatMain', gbiChatMain.Caption);

    gbMsgSettings.Caption:=GetStr('gbMsgSettings.Caption', gbMsgSettings.Caption);
    lbAway.Caption:=GetStr('lbAway.Caption', lbAway.Caption);
    lbHelloMessage.Caption:=GetStr('lbHelloMessage.Caption', lbHelloMessage.Caption);
    lbQuitMessage.Caption:=GetStr('lbQuitMessage.Caption', lbQuitMessage.Caption);
    cbReceiveUTF8.Caption:=GetStr('cbReceiveUTF8.Caption', cbReceiveUTF8.Caption);
    cbSendUTF8.Caption:=GetStr('cbSendUTF8.Caption', cbSendUTF8.Caption);

    gbOther.Caption:=GetStr('gbOther.Caption', gbOther.Caption);
    cbAutoConnect.Caption:=GetStr('cbAutoConnect.Caption', cbAutoConnect.Caption);
    cbAutoReconnect.Caption:=GetStr('cbAutoReconnect.Caption', cbAutoReconnect.Caption);
    cbDebugMessages.Caption:=GetStr('cbDebugMessages.Caption', cbDebugMessages.Caption);
    cbLogMessages.Caption:=GetStr('cbLogMessages.Caption', cbLogMessages.Caption);
    cbShowServerPing.Caption:=GetStr('cbShowServerPing.Caption', cbShowServerPing.Caption);
    cbShowStatusMessages.Caption:=GetStr('cbShowStatusMessages.Caption', cbShowStatusMessages.Caption);
    cbLocalEcho.Caption:=GetStr('cbLocalEcho.Caption', cbLocalEcho.Caption);

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
    FillSoundOptions(nil, vleSounds);

    // Notes
    gbNotes.Caption:=GetStr('gbNotes.Caption', gbNotes.Caption);
    SetNodeCaption('Notes', gbNotes.Caption);
    cbShowNotesOnJoin.Caption:=GetStr('cbShowNotesOnJoin.Caption', cbShowNotesOnJoin.Caption);
    lbNotesReadme.Caption:=GetStr('lbNotesReadme.Caption', lbNotesReadme.Caption);
  finally
  end;
end;


end.
