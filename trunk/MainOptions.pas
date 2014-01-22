{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  Настройки основной части программы.
}
unit MainOptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Grids, ValEdit, Contnrs, Configs, Misc;

type
  TMainConfig = class(TConf)
  private
    procedure FillLanguagesList();
  public
    LangsList: TObjectList;
    fntArray: array [1..3] of TFont;
    PluginsNode: TConfNode;
    constructor Create();
    destructor Destroy(); override;
  end;

  TLangInfo = class
  public
    FileName: string;
    LangName: string;
    Author: string;
    InfoText: string;
  end;

  TfrmMainOptions = class(TForm)
    PageControl1: TPageControl;
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
    tsSmiles: TTabSheet;
    gbSmiles: TGroupBox;
    lbSmilesCount: TLabel;
    cbSmilesCloseAfterSelect: TCheckBox;
    editSmilesCount: TEdit;
    UpDownSmilesCount: TUpDown;
    tsPlugins: TTabSheet;
    gbPlugins: TGroupBox;
    lbPluginInfo: TLabel;
    lvPluginsList: TListView;
    tsNotesGrabber: TTabSheet;
    gbNotesGrabber: TGroupBox;
    lbNotesGrabberReadme: TLabel;
    memoGrabKeywords: TMemo;
    tsNotes: TTabSheet;
    gbNotes: TGroupBox;
    lbNotesReadme: TLabel;
    memoNotes: TMemo;
    cbShowNotesOnJoin: TCheckBox;
    tsMain: TTabSheet;
    gbMain: TGroupBox;
    cbCopySelected: TCheckBox;
    cbNotifyPrivates: TCheckBox;
    cbNotifyAllMessages: TCheckBox;
    cbUserlistCheckboxes: TCheckBox;
    cbPopupPrivate: TCheckBox;
    cbUseAvatars: TCheckBox;
    cbLogMessages: TCheckBox;
    cbSendMsgOnCtrlEnter: TCheckBox;
    tsIgnore: TTabSheet;
    gbIgnore: TGroupBox;
    lbIgnore1: TLabel;
    lbIgnore2: TLabel;
    lbIgnore3: TLabel;
    memoIgnore: TMemo;
    tsFonts: TTabSheet;
    gbFonts: TGroupBox;
    lbFontSelect: TListBox;
    tsFastMsg: TTabSheet;
    gbFastMsg: TGroupBox;
    lbFM1: TLabel;
    memoFastMsg: TMemo;
    tsProxy: TTabSheet;
    gbProxy: TGroupBox;
    gbProxyList: TGroupBox;
    lbProxyHost: TLabel;
    lbProxyPort: TLabel;
    btnAddProxy: TButton;
    btnDelProxy: TButton;
    edProxyHost: TEdit;
    edProxyPort: TEdit;
    tsAutojoin: TTabSheet;
    gbAutojoin: TGroupBox;
    lbAJList: TLabel;
    memoAutojoinList: TMemo;
    tsMessages: TTabSheet;
    gbMessages: TGroupBox;
    tsLanguage: TTabSheet;
    gbLanguage: TGroupBox;
    listboxLangs: TListBox;
    btnLoadLang: TButton;
    lbLangInfo: TLabel;
    lbHotkey: TLabel;
    edHotkey: TEdit;
    lbProxyUser: TLabel;
    lbProxyPass: TLabel;
    edProxyUser: TEdit;
    edProxyPass: TEdit;
    lbProxyType: TLabel;
    cboxProxyType: TComboBox;
    memoProxyList: TMemo;
    procedure lbFontSelectClick(Sender: TObject);
    procedure lvPluginsListSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure listboxLangsClick(Sender: TObject);
    procedure btnLoadLangClick(Sender: TObject);
    procedure edHotkeyKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnAddProxyClick(Sender: TObject);
    procedure btnDelProxyClick(Sender: TObject);
  private
    { Private declarations }
    SelectedLangInfo: TLangInfo;
    procedure FillSoundOptions();
  public
    { Public declarations }
    procedure vleSoundsEditButtonClick(Sender: TObject);
    procedure btnSoundTestClick(Sender: TObject);
    procedure FillConfigNodes(RootNode: TConfNode);
    procedure RefreshSettings(ConfNode: TConfNode);
    procedure ApplySettings(ConfNode: TConfNode);
    procedure OnApplySettingsHandler(Sender: TObject);
    procedure ChangeLanguage();
  end;

var
  frmMainOptions: TfrmMainOptions;

implementation
uses Core, Sounds, IniFiles;
{$R *.dfm}

// TMainConfig
constructor TMainConfig.Create;
var
  i: integer;
  ConfItems: TConfItems;
begin
  inherited Create();
  RootNode:=TConfNode.Create(nil);
  RootNode.Name:='RealChat';
  RootNode.FullName:='RealChat main config';
  self.AllConfItems:=TConfItems.Create('Main');

  for i:=1 to 3 do
  begin
    fntArray[i]:=TFont.Create();
  end;

  RootNode.ConfItems:=TConfItems.Create(RootNode.Name);
  ConfItems:=RootNode.ConfItems;

  // Заполнение значений по умолчанию
  ConfItems.Add('MyFullName', 'My full name', '', 'S');
  ConfItems.Add('MyNick', 'My nick', GetWinUserName(), 'S');
  ConfItems.Add('MySecondNick', 'My second nick', GetWinCompName(), 'S');
  //ConfItems.Add('ClientVersion', 'Client version', 'IRC client for iRC ver. 0.1', 'S');
  ConfItems.Add('AvatarURL', 'Avatar URL', '', 'S');
  ConfItems.Add('AwayMessage', 'Avay message', 'Меня здесь нет!', 'S');
  ConfItems.Add('Version', 'Version', 'RealChat', 'S');
  ConfItems.Add('QuitMessage', 'Quit message', 'RealChat - http://irchat.ru', 'S');
  ConfItems.Add('Hotkey', 'Hotkey', 'Ctrl+Alt+67', 'S');

  ConfItems.Add('SettingsFile', 'Settings file', 'Settings.ini', 'S');
  ConfItems.Add('LanguageFile', 'Language file', '', 'S');
  ConfItems.Add('SaveFilesDir', 'Patch for received files', 'Incoming', 'S');
  ConfItems.Add('SmilesPath', 'Patch for smiles', 'Smiles', 'S');
  ConfItems.Add('AvatarsPath', 'Patch for received avatars', 'Avatars', 'S');
  ConfItems.Add('LogsPath', 'Patch for log files', 'Logs', 'S');
  ConfItems.Add('PluginsPath', 'Patch for plugins', 'Plugins', 'S');

  ConfItems.Add('MainForm_Top', 'MainForm Top', '100', 'I');
  ConfItems.Add('MainForm_Left', 'MainForm Left', '100', 'I');
  ConfItems.Add('MainForm_Height', 'MainForm Height', '400', 'I');
  ConfItems.Add('MainForm_Width', 'MainForm Width', '600', 'I');

  ConfItems.Add('UseAvatars', 'Use avatars', '0', 'B');
  ConfItems.Add('AvatarQueryDelay', 'Delay between requests for avatar', '30', 'I');

  ConfItems.Add('SmilesCount', 'Max Smiles count', '10', 'I');
  ConfItems.Add('SmilesCloseAfterSelect', 'SmilesCloseAfterSelect', '1', 'B');

  ConfItems.Add('CopySelected', 'Copy selected text', '1', 'B');
  ConfItems.Add('NotifyPrivates', 'Notify private messages', '1', 'B');
  ConfItems.Add('NotifyAllMsg', 'Notify all messages', '0', 'B');
  ConfItems.Add('UserlistCheckboxes', 'UserlistCheckboxes', '0', 'B');
  ConfItems.Add('IgnorePrivates', 'IgnorePrivates', '0', 'B');
  ConfItems.Add('PopupPrivate', 'PopupPrivate', '0', 'B');
  ConfItems.Add('ServerPageVisible', 'ServerPageVisible', '1', 'B');
  ConfItems.Add('NotesPageVisible', 'NotesPageVisible', '0', 'B');
  ConfItems.Add('FilesPageVisible', 'FilesPageVisible', '0', 'B');
  ConfItems.Add('PlaySounds', 'PlaySounds', '0', 'B');
  ConfItems.Add('LogMessages', 'Log messages', '0', 'B');
  ConfItems.Add('SendMsgOnCtrlEnter', 'SendMsgOnCtrlEnter', '0', 'B');
  ConfItems.Add('DisableTextColors', 'Disable text colors', '0', 'B');
  ConfItems.Add('DisableSmiles', 'Disable smiles', '0', 'B');

  //ConfItems.Add('NotesList', 'Notes', '', 'T');
  //ConfItems.Add('TemplatesList', 'Templates', '', 'T');
  ConfItems.Add('NotesKeywordsList', 'Grab notes keywords', '', 'T');
  ConfItems.Add('FastMsgList', 'Notes', '', 'T');
  ConfItems.Add('ProxyList', 'Proxy servers list', '', 'T');
  ConfItems.Add('ChatClientsList', 'Chat clients list', '', 'T');
  //ConfItems.Add('', '', '', '');
  //ConfItems.Add('', '', '', '');
  //ConfItems.Add('', '', '', '');
  //ConfItems.Add('', '', '', '');

  ConfItems.Add('fntChatText_Name', 'Chat text font Name', fntArray[1].Name, 'S');
  ConfItems.Add('fntChatText_Size', 'Chat text font Size', IntToStr(fntArray[1].Size), 'I');
  ConfItems.Add('fntUserList_Name', 'User list font Name', fntArray[2].Name, 'S');
  ConfItems.Add('fntUserList_Size', 'User list font Size', IntToStr(fntArray[2].Size), 'I');
  ConfItems.Add('fntTxtToSend_Name', 'Send text font Name', fntArray[3].Name, 'S');
  ConfItems.Add('fntTxtToSend_Size', 'Send text font Size', IntToStr(fntArray[3].Size), 'I');

  frmMainOptions:= TfrmMainOptions.Create(nil);
  //frmMainOptions.FillConfItems(RootNode);
  frmMainOptions.FillConfigNodes(RootNode);

  // Fill languages list
  LangsList := TObjectList.Create();
  FillLanguagesList();

  // Set plugins node
  for i:=0 to RootNode.ChildCount-1 do
  begin
    if RootNode.ChildNodes[i].Name = frmMainOptions.tsPlugins.Caption then
    begin
      PluginsNode:=RootNode.ChildNodes[i];
      Break;
    end;
  end;
  //self['ConfFileName']:='';
end;

destructor TMainConfig.Destroy();
begin
  frmMainOptions.Release();
  LangsList.Free();
  inherited Destroy();
end;

procedure TMainConfig.FillLanguagesList();
var
  li: TLangInfo;
  sr: TSearchRec;
  LangIni: TMemIniFile;
  sFileName, s, s2: string;
  Done: boolean;
begin
  s2:=self.Values['LanguageFile'];
  if FindFirst(glHomePath+'\language_*.ini', faAnyFile, sr)=0 then
  begin
    Done:=false;
    while not Done do
    begin
      sFileName:=glHomePath+sr.Name;
      LangIni:=TMemIniFile.Create(sFileName);
      s:=LangIni.ReadString('Info', 'Name', '');
      if s<>'' then
      begin
        li:=TLangInfo.Create();
        li.FileName:=sFileName;
        li.LangName:=s;
        li.Author:=LangIni.ReadString('Info', 'Author', '');
        li.InfoText:=LangIni.ReadString('Info', 'Info', '');
        self.LangsList.Add(li);
        frmMainOptions.listboxLangs.AddItem(li.LangName, li);
        if sr.Name=s2 then frmMainOptions.listboxLangs.Selected[frmMainOptions.listboxLangs.Count-1]:=true;
      end;
      FreeAndNil(LangIni);
      Done := (FindNext(sr) <> 0);
    end;
  end;
  FindClose(sr);

  if s2<>'' then
  begin
    sFileName:=glHomePath+s2;
    Core.LangIni:=TMemIniFile.Create(sFileName);
  end;

end;

// === TfrmMainOptions ===
procedure TfrmMainOptions.FillSoundOptions();
var
  slSoundNames: TStringList;
  sd: char;
  sKey: string;
  i, n: integer;
  ItemProp: TItemProp;
begin

  // Список названий звуковых событий
  slSoundNames:=TStringList.Create();
  sd:=slSoundNames.NameValueSeparator;
  with slSoundNames do
  begin
    {slSoundNames.Add('sfxChanMsg'+sd+sSoundEventChannelMessage);
    slSoundNames.Add('sfxPvtMsg' +sd+sSoundEventPrivateMessage);
    slSoundNames.Add('sfxMeMsg'  +sd+sSoundEventMeMessage);
    slSoundNames.Add('sfxNoteMsg'+sd+sSoundEventNoticeMessage);
    slSoundNames.Add('sfxDccChat'+sd+sSoundEventDccChat);
    slSoundNames.Add('sfxDccFile'+sd+sSoundEventDccFile);
    slSoundNames.Add('sfxConnect'+sd+sSoundEventServerConnect);
    slSoundNames.Add('sfxDisconnect'+sd+sSoundEventServerDisconnect);
    slSoundNames.Add('sfxJoin'   +sd+sSoundEventJoinChannel);
    slSoundNames.Add('sfxLeave'  +sd+sSoundEventLeaveChannel);
    slSoundNames.Add('sfxError'  +sd+sSoundEventErrorMessage);
    slSoundNames.Add('sfxOther'  +sd+sSoundEventOther); }
    //slSoundNames.Add(''+sd+'');
  end;

  // Очистка и заполнение визуального списка звуков
  // !! если Strings изначально пуст - будет ошибка!
  for i:=vleSounds.RowCount-1 downto 1 do
  begin
    vleSounds.DeleteRow(i);
  end;

  for i:=0 to slSoundNames.Count-1 do
  begin
    sKey:=slSoundNames.Names[i];
    //n:=vleSounds.InsertRow(sKey, conf.slSoundFiles.Values[sKey], true);
    ItemProp:=vleSounds.ItemProps[sKey];
    ItemProp.KeyDesc:=slSoundNames.ValueFromIndex[i];
    ItemProp.EditStyle:=esEllipsis;
    //ItemProp.MaxLength:=3;
    //ItemProp.EditMask:='!990';
  end;
  FreeAndNil(slSoundNames);
end;

// При клике кнопки выбора в списке звуков
procedure TfrmMainOptions.vleSoundsEditButtonClick(Sender: TObject);
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

procedure TfrmMainOptions.btnSoundTestClick(Sender: TObject);
begin
  PlaySoundFile(vleSounds.Values[vleSounds.Keys[vleSounds.Row]]);
end;

procedure TfrmMainOptions.lvPluginsListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if (Item = nil) then Exit;
  lbPluginInfo.Caption:=Item.SubItems[0];
end;

// Выбор шрифтов
procedure TfrmMainOptions.lbFontSelectClick(Sender: TObject);
var
  i: integer;
  MP: TPoint;
  FontSelector: TFontDialog;
begin
  with (Sender as TListBox) do
  begin
    MP.X:= Mouse.CursorPos.X - ClientOrigin.X;
    MP.Y:= Mouse.CursorPos.Y - ClientOrigin.Y;
    i:=ItemAtPos(MP, true);
  end;
  if (i < 0) or (i > 2) then Exit;
  FontSelector:=TFontDialog.Create(Self);
  if MainConf.fntArray[i+1] = nil then MainConf.fntArray[i+1]:=TFont.Create;
  FontSelector.Font.Assign(MainConf.fntArray[i+1]);
  if FontSelector.Execute then
  begin
    MainConf.fntArray[i+1].Assign(FontSelector.Font);
    Core.SetNewFonts();
    //MainConf.SetNewFonts;
  end;
  FontSelector.Destroy;
end;

procedure TfrmMainOptions.FillConfigNodes(RootNode: TConfNode);
var
  NewNode: TConfNode;
  NewNode2: TConfNode;
begin
  RootNode.OnApplySettings:=OnApplySettingsHandler;

  // Main
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Main';
  NewNode.FullName:=gbMain.Caption;
  NewNode.Panel:=gbMain;

  // Fonts
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Fonts';
  NewNode.FullName:=gbFonts.Caption;
  NewNode.Panel:=gbFonts;

  // Sounds
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Sounds';
  NewNode.FullName:=gbSounds.Caption;
  NewNode.Panel:=gbSounds;

  // Plugins
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Plugins';
  NewNode.FullName:=gbPlugins.Caption;
  NewNode.Panel:=gbPlugins;

  // Languages
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Language';
  NewNode.FullName:=gbLanguage.Caption;
  NewNode.Panel:=gbLanguage;

  // Proxy list
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Proxy';
  NewNode.FullName:=gbProxy.Caption;
  NewNode.Panel:=gbProxy;

  // Other
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Other';
  NewNode.FullName:='All main options';
  NewNode.ConfItems:=RootNode.ConfItems;
  NewNode.Panel:=nil;

  // Messages group
  NewNode:=TConfNode.Create(RootNode);
  NewNode.Name:='Messages';
  NewNode.FullName:=gbMessages.Caption;
  NewNode.Panel:=gbMessages;
  NewNode2:=NewNode;

  {// Autojoin
  NewNode:=TConfNode.Create(NewNode2);
  NewNode.Name:=tsAutojoin.Caption;
  NewNode.FullName:=gbAutojoin.Caption;
  NewNode.Panel:=gbAutojoin; }

  {// Templates
  NewNode:=TConfNode.Create(NewNode2);
  NewNode.Name:=tsTemplates.Caption;
  NewNode.FullName:=gbTemplates.Caption;
  NewNode.Panel:=gbTemplates;}

  // FastMsg
  NewNode:=TConfNode.Create(NewNode2);
  NewNode.Name:='FastMsg';
  NewNode.FullName:=gbFastMsg.Caption;
  NewNode.Panel:=gbFastMsg;

  {// Notes
  NewNode:=TConfNode.Create(NewNode2);
  NewNode.Name:=tsNotes.Caption;
  NewNode.FullName:=gbNotes.Caption;
  NewNode.Panel:=gbNotes;}

  // NotesGrabber
  NewNode:=TConfNode.Create(NewNode2);
  NewNode.Name:='NotesGrabber';
  NewNode.FullName:=gbNotesGrabber.Caption;
  NewNode.Panel:=gbNotesGrabber;

  self.RefreshSettings(RootNode);
end;

// Поскольку у MainConf настройки хранятся только в RootNode, работает только с ним
procedure TfrmMainOptions.RefreshSettings(ConfNode: TConfNode);
var
  ConfItems: TConfItems;
begin
  //if ConfNode<>MainConf.RootNode then Exit;
  ConfItems:=ConfNode.ConfItems;
  if not Assigned(ConfItems) then Exit;
  // установка значений

  cbCopySelected.Checked := (ConfItems['CopySelected']='1');
  cbNotifyPrivates.Checked := (ConfItems['NotifyPrivates']='1');
  cbNotifyAllMessages.Checked := (ConfItems['NotifyAllMsg']='1');
  cbUserlistCheckboxes.Checked := (ConfItems['UserlistCheckboxes']='1');
  cbShowNotesOnJoin.Checked := (ConfItems['ShowNotesOnJoin']='1');
  cbPopupPrivate.Checked := (ConfItems['PopupPrivate']='1');
  cbUseAvatars.Checked := (ConfItems['UseAvatars']='1');
  cbLogMessages.Checked := (ConfItems['LogMessages']='1');
  cbPlaySounds.Checked := (ConfItems['PlaySounds']='1');
  cbSendMsgOnCtrlEnter.Checked := (ConfItems['SendMsgOnCtrlEnter']='1');
  edHotkey.Text := ConfItems['Hotkey'];

  editSmilesCount.Text := ConfItems['SmilesCount'];
  cbSmilesCloseAfterSelect.Checked := (ConfItems['CloseAfterSelect']='1');

  memoTemplates.Lines.Text   := ConfItems['TemplatesList'];
  memoGrabKeywords.Lines.Text := ConfItems['NotesGrabberList'];
  memoNotes.Lines.Text       := ConfItems['NotesList'];
  memoIgnore.Lines.Text      := ConfItems['IgnoreList'];
  memoFastMsg.Lines.Text      := ConfItems['FastMsgList'];
  memoAutojoinList.Lines.Text := ConfItems['AutojoinList'];
  memoProxyList.Lines.Text    := ConfItems['ProxyList'];

  // Загрузка шрифтов
  if not Assigned(MainConf) then Exit;
  MainConf.fntArray[1].Name:=MainConf['fntChatText_Name'];
  MainConf.fntArray[1].Size:=StrToIntDef(MainConf['fntChatText_Size'], MainConf.fntArray[1].Size);
  MainConf.fntArray[2].Name:=MainConf['fntUserList_Name'];
  MainConf.fntArray[2].Size:=StrToIntDef(MainConf['fntUserList_Size'], MainConf.fntArray[2].Size);
  MainConf.fntArray[3].Name:=MainConf['fntTxtToSend_Name'];
  MainConf.fntArray[3].Size:=StrToIntDef(MainConf['fntTxtToSend_Size'], MainConf.fntArray[3].Size);
end;

// Поскольку у MainConf настройки хранятся только в RootNode, работает только с ним
procedure TfrmMainOptions.ApplySettings(ConfNode: TConfNode);
var
  ConfItems: TConfItems;

function GetBoolStr(b: boolean): string;
begin
  result:='0';
  if b then result:='1';
end;

begin
  //if ConfNode<>MainConf.RootNode then Exit;
  ConfItems:=ConfNode.ConfItems;
  if not Assigned(ConfItems) then Exit;

    // установка значений
  ConfItems['CopySelected'] := GetBoolStr(cbCopySelected.Checked);
  ConfItems['NotifyPrivates'] := GetBoolStr(cbNotifyPrivates.Checked);
  ConfItems['NotifyAllMsg'] := GetBoolStr(cbNotifyAllMessages.Checked);
  ConfItems['UserlistCheckboxes'] := GetBoolStr(cbUserlistCheckboxes.Checked);
  ConfItems['ShowNotesOnJoin'] := GetBoolStr(cbShowNotesOnJoin.Checked);
  ConfItems['PopupPrivate'] := GetBoolStr(cbPopupPrivate.Checked);
  ConfItems['UseAvatars'] := GetBoolStr(cbUseAvatars.Checked);
  ConfItems['LogMessages'] := GetBoolStr(cbLogMessages.Checked);
  ConfItems['PlaySounds'] := GetBoolStr(cbPlaySounds.Checked);
  ConfItems['SendMsgOnCtrlEnter'] := GetBoolStr(cbSendMsgOnCtrlEnter.Checked);
  ConfItems['Hotkey'] := edHotkey.Text;

  ConfItems['SmilesCount'] := editSmilesCount.Text;
  ConfItems['CloseAfterSelect'] := GetBoolStr(cbSmilesCloseAfterSelect.Checked);

  ConfItems['TemplatesList'] := memoTemplates.Lines.Text;
  ConfItems['NotesGrabberList'] := memoGrabKeywords.Lines.Text;
  ConfItems['NotesList'] := memoNotes.Lines.Text;
  ConfItems['IgnoreList'] := memoIgnore.Lines.Text;
  ConfItems['FastMsgList'] := memoFastMsg.Lines.Text;
  ConfItems['AutojoinList'] := memoAutojoinList.Lines.Text;

  // Запись шрифтов
  if not Assigned(MainConf) then Exit;
  MainConf['fntChatText_Name']:=MainConf.fntArray[1].Name;
  MainConf['fntChatText_Size']:=IntToStr(MainConf.fntArray[1].Size);
  MainConf['fntUserList_Name']:=MainConf.fntArray[2].Name;
  MainConf['fntUserList_Size']:=IntToStr(MainConf.fntArray[2].Size);
  MainConf['fntTxtToSend_Name']:=MainConf.fntArray[3].Name;
  MainConf['fntTxtToSend_Size']:=IntToStr(MainConf.fntArray[3].Size);
end;

procedure TfrmMainOptions.OnApplySettingsHandler(Sender: TObject);
begin
  ApplySettings(TConfNode(Sender));
end;

procedure TfrmMainOptions.ChangeLanguage();

function GetStr(Name: string; s: string): string;
begin
  result:=Core.LangIni.ReadString('MainOptions', Name, s);
end;

procedure SetNodeCaption(sNodeName, sCaption: string);
var
  cn: TConfNode;
begin
  cn:=MainConf.RootNode.GetChildByName(sNodeName);
  if cn <> nil then cn.FullName:=sCaption;
end;

begin

  if not Assigned(Core.LangIni) then Exit;
  try
    // Templates
    {gbTemplates.Caption:=GetStr('gbTemplates.Caption', gbTemplates.Caption);
    lbTemplates1.Caption:=GetStr('lbTemplates1.Caption', lbTemplates1.Caption);
    lbTemplates6.Caption:=GetStr('lbTemplates6.Caption', lbTemplates6.Caption);
    lbTemplates7.Caption:=GetStr('lbTemplates7.Caption', lbTemplates7.Caption);
    lbTemplates8.Caption:=GetStr('lbTemplates8.Caption', lbTemplates8.Caption);
    lbTemplates9.Caption:=GetStr('lbTemplates9.Caption', lbTemplates9.Caption);}

    // Sounds
    gbSounds.Caption:=GetStr('gbSounds.Caption', gbSounds.Caption);
    cbPlaySounds.Caption:=GetStr('cbPlaySounds.Caption', cbPlaySounds.Caption);
    lbSoundTest.Caption:=GetStr('lbSoundTest.Caption', lbSoundTest.Caption);
    SetNodeCaption('Sounds', gbSounds.Caption);

    // Smiles
    gbSmiles.Caption:=GetStr('gbSmiles.Caption', gbSmiles.Caption);
    cbSmilesCloseAfterSelect.Caption:=GetStr('cbSmilesCloseAfterSelect.Caption', cbSmilesCloseAfterSelect.Caption);
    lbSmilesCount.Caption:=GetStr('lbSmilesCount.Caption', lbSmilesCount.Caption);

    // Plugins
    gbPlugins.Caption:=GetStr('gbPlugins.Caption', gbPlugins.Caption);
    SetNodeCaption('Plugins', gbPlugins.Caption);

    // NotesGrabber
    gbNotesGrabber.Caption:=GetStr('gbNotesGrabber.Caption', gbNotesGrabber.Caption);
    lbNotesGrabberReadme.Caption:=GetStr('lbNotesGrabberReadme.Caption', lbNotesGrabberReadme.Caption);
    SetNodeCaption('NotesGrabber', gbNotesGrabber.Caption);

    // Notes
    {gbNotes.Caption:=GetStr('gbNotes.Caption', gbNotes.Caption);
    cbShowNotesOnJoin.Caption:=GetStr('cbShowNotesOnJoin.Caption', cbShowNotesOnJoin.Caption);
    lbNotesReadme.Caption:=GetStr('lbNotesReadme.Caption', lbNotesReadme.Caption);}

    // Main
    gbMain.Caption:=GetStr('gbMain.Caption', gbMain.Caption);
    cbCopySelected.Caption:=GetStr('cbCopySelected.Caption', cbCopySelected.Caption);
    cbLogMessages.Caption:=GetStr('cbLogMessages.Caption', cbLogMessages.Caption);
    cbNotifyAllMessages.Caption:=GetStr('cbNotifyAllMessages.Caption', cbNotifyAllMessages.Caption);
    cbNotifyPrivates.Caption:=GetStr('cbNotifyPrivates.Caption', cbNotifyPrivates.Caption);
    cbPopupPrivate.Caption:=GetStr('cbPopupPrivate.Caption', cbPopupPrivate.Caption);
    cbSendMsgOnCtrlEnter.Caption:=GetStr('cbSendMsgOnCtrlEnter.Caption', cbSendMsgOnCtrlEnter.Caption);
    cbUseAvatars.Caption:=GetStr('cbUseAvatars.Caption', cbUseAvatars.Caption);
    cbUserlistCheckboxes.Caption:=GetStr('cbUserlistCheckboxes.Caption', cbUserlistCheckboxes.Caption);
    lbHotkey.Caption:=GetStr('lbHotkey.Caption', lbHotkey.Caption);
    SetNodeCaption('Main', gbMain.Caption);

    // Ignore
    {gbIgnore.Caption:=GetStr('gbIgnore.Caption', gbIgnore.Caption);
    lbIgnore1.Caption:=GetStr('lbIgnore1.Caption', lbIgnore1.Caption);
    lbIgnore2.Caption:=GetStr('lbIgnore2.Caption', lbIgnore2.Caption);
    lbIgnore3.Caption:=GetStr('lbIgnore3.Caption', lbIgnore3.Caption);}

    // Fonts
    gbFonts.Caption:=GetStr('gbFonts.Caption', gbFonts.Caption);
    SetNodeCaption('Fonts', gbFonts.Caption);
    lbFontSelect.Items[0]:=GetStr('Font_ChatWindow', lbFontSelect.Items[0]);
    lbFontSelect.Items[1]:=GetStr('Font_UserList', lbFontSelect.Items[1]);
    lbFontSelect.Items[2]:=GetStr('Font_PostWindow', lbFontSelect.Items[2]);

    // Messages
    gbMessages.Caption:=GetStr('gbMessages.Caption', gbMessages.Caption);
    SetNodeCaption('Messages', gbMessages.Caption);

    // Fast messages
    gbFastMsg.Caption:=GetStr('gbFastMsg.Caption', gbFastMsg.Caption);
    lbFM1.Caption:=GetStr('lbFM1.Caption', lbFM1.Caption);
    SetNodeCaption('FastMsg', gbFastMsg.Caption);

    // proxy
    gbProxy.Caption:=GetStr('gbProxy.Caption', gbProxy.Caption);
    gbProxyList.Caption:=GetStr('gbProxyList.Caption', gbProxyList.Caption);
    btnAddProxy.Caption:=GetStr('btnAddProxy.Caption', btnAddProxy.Caption);
    btnDelProxy.Caption:=GetStr('btnDelProxy.Caption', btnDelProxy.Caption);
    lbProxyHost.Caption:=GetStr('lbProxyHost.Caption', lbProxyHost.Caption);
    lbProxyPort.Caption:=GetStr('lbProxyPort.Caption', lbProxyPort.Caption);
    lbProxyUser.Caption:=GetStr('lbProxyUser.Caption', lbProxyUser.Caption);
    lbProxyPass.Caption:=GetStr('lbProxyPass.Caption', lbProxyPass.Caption);
    lbProxyType.Caption:=GetStr('lbProxyType.Caption', lbProxyType.Caption);
    SetNodeCaption('Proxy', gbProxy.Caption);

    // Autojoin
    {gbAutojoin.Caption:=GetStr('gbAutojoin.Caption', gbAutojoin.Caption);
    lbAJList.Caption:=GetStr('lbAJList.Caption', lbAJList.Caption);}

    // Language
    SetNodeCaption('Language', gbLanguage.Caption);
  finally
  end;

end;

procedure TfrmMainOptions.listboxLangsClick(Sender: TObject);
var
  li: TLangInfo;
begin
  with TListBox(Sender) do
  begin
    if ItemIndex<0 then Exit;
    li:=(Items.Objects[ItemIndex] as TLangInfo);
  end;
  lbLangInfo.Caption:=li.LangName+#13+#10+li.Author+#13+#10+li.InfoText;
  SelectedLangInfo:=li;
end;

procedure TfrmMainOptions.btnLoadLangClick(Sender: TObject);
begin
  if not Assigned(SelectedLangInfo) then Exit;
  if Assigned(Core.LangIni) then FreeAndNil(Core.LangIni);
  MainConf['LanguageFile']:=ExtractFilename(SelectedLangInfo.FileName);
  //Core.LangIni:=TMemIniFile.Create(SelectedLangInfo.FileName);
  Core.ChangeLanguage();
end;

procedure TfrmMainOptions.edHotkeyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  s: string;
begin
  s:='';
  if ssShift in Shift then s:=s+'Shift+';
  if ssAlt	 in Shift then s:=s+'Alt+';
  if ssCtrl	 in Shift then s:=s+'Ctrl+';
  s:=s+IntToStr(Key);
  edHotkey.Text:=s;
end;

procedure TfrmMainOptions.btnAddProxyClick(Sender: TObject);
var
  s: string;
begin
  s:=Misc.ComposeProxyURL(edProxyHost.Text, edProxyPort.Text, cboxProxyType.Text,
                          edProxyUser.Text, edProxyPass.Text);
  if memoProxyList.Lines.IndexOf(s)<0 then memoProxyList.Lines.Add(s);
  MainConf['ProxyList']:=memoProxyList.Lines.Text;
end;

procedure TfrmMainOptions.btnDelProxyClick(Sender: TObject);
begin
  if memoProxyList.CaretPos.Y>=0 then
    memoProxyList.Lines.Delete(memoProxyList.CaretPos.Y);
  MainConf['ProxyList']:=memoProxyList.Lines.Text;
end;

end.
