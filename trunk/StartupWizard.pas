unit StartupWizard;

interface

uses
  SysUtils, Classes, Controls, Forms,
  StdCtrls, ComCtrls, MainOptions;

type
  TfrmStartupWizard = class(TForm)
    pcWizardPages: TPageControl;
    tsLanguage: TTabSheet;
    tsUserData: TTabSheet;
    tsIRC: TTabSheet;
    lboxLang: TListBox;
    btn1_Next: TButton;
    lbFirstNick: TLabel;
    lbSecondNick: TLabel;
    lbUserFullName: TLabel;
    gbUserInfo: TGroupBox;
    edFirstNick: TEdit;
    edSecondNick: TEdit;
    edFullName: TEdit;
    gbAdditionalInfo: TGroupBox;
    lbAvatarURL: TLabel;
    edAvatarURL: TEdit;
    lbAwayMessage: TLabel;
    edAwayMessage: TEdit;
    lbQuitMessage: TLabel;
    edQuitMessage: TEdit;
    btn2_Next: TButton;
    btn2_Prev: TButton;
    gbIrcServer: TGroupBox;
    lbIrcHost: TLabel;
    edIrcHost: TEdit;
    lbIrcPort: TLabel;
    edIrcPort: TEdit;
    lbIrcProxy: TLabel;
    edIrcProxy: TEdit;
    cboxIrcProxyType: TComboBox;
    lbIrcProxyType: TLabel;
    btn3_Next: TButton;
    btn3_Prev: TButton;
    lbIrcReadme: TLabel;
    memoIrcChannels: TMemo;
    lbIrcChannels: TLabel;
    lbLangInfo: TLabel;
    tsFinish: TTabSheet;
    btn4_Next: TButton;
    btn4_Prev: TButton;
    lbFinalNote: TLabel;
    procedure lboxLangClick(Sender: TObject);
    procedure btnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    SelectedLangInfo: TLangInfo;
    procedure LangSelect();
    procedure DoFinish();
    procedure UserInfoComplete();
    procedure IrcSettingsComplete();
  public
    { Public declarations }
  end;

var
  frmStartupWizard: TfrmStartupWizard;

implementation
uses Core;

{$R *.dfm}

procedure TfrmStartupWizard.lboxLangClick(Sender: TObject);
var
  s: string;
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

procedure TfrmStartupWizard.FormCreate(Sender: TObject);
var
  i: integer;
  li: TLangInfo;
begin
  for i:=0 to MainConf.LangsList.Count-1 do
  begin
    li:=(MainConf.LangsList[i] as TLangInfo);
    lboxLang.AddItem(li.LangName, li);
  end;
  if lboxLang.Items.Count>0 then
  begin
    lboxLang.ItemIndex:=0;
    lboxLangClick(lboxLang);
  end;
  // hide tabs
  for i:=0 to pcWizardPages.PageCount-1 do
  begin
    pcWizardPages.Pages[i].TabVisible:=false;
  end;
  pcWizardPages.ActivePageIndex:=0;
  //pcWizardPages.TabHeight:=1; // almost hide

  edIrcPort.Text:='6667';
  cboxIrcProxyType.AddItem('No proxy', nil);
  cboxIrcProxyType.AddItem('HTTP', nil);
  cboxIrcProxyType.AddItem('Socks5', nil);
  cboxIrcProxyType.ItemIndex:=0;

  // default settings
  edFirstNick.Text:=MainConf['MyNick'];
  edSecondNick.Text:=MainConf['MySecondNick'];
  edAwayMessage.Text:=MainConf['AwayMessage'];
  edQuitMessage.Text:=MainConf['QuitMessage'];
end;

procedure TfrmStartupWizard.LangSelect();

function GetStr(Name: string; s: string): string;
begin
  result:=Core.LangIni.ReadString('StartupWizard', Name, s);
end;

begin
  // Apply language
  if not Assigned(SelectedLangInfo) then Exit;
  if Assigned(Core.LangIni) then FreeAndNil(Core.LangIni);
  MainConf['LanguageFile']:=ExtractFilename(SelectedLangInfo.FileName);
  Core.ChangeLanguage();

  // User info
  gbUserInfo.Caption:=GetStr('gbUserInfo.Caption', gbUserInfo.Caption);
  lbFirstNick.Caption:=GetStr('lbFirstNick.Caption', lbFirstNick.Caption);
  lbSecondNick.Caption:=GetStr('lbSecondNick.Caption', lbSecondNick.Caption);
  lbUserFullName.Caption:=GetStr('lbUserFullName.Caption', lbUserFullName.Caption);

  gbAdditionalInfo.Caption:=GetStr('gbAdditionalInfo.Caption', gbAdditionalInfo.Caption);
  lbAvatarURL.Caption:=GetStr('lbAvatarURL.Caption', lbAvatarURL.Caption);
  lbAwayMessage.Caption:=GetStr('lbAwayMessage.Caption', lbAwayMessage.Caption);
  lbQuitMessage.Caption:=GetStr('lbQuitMessage.Caption', lbQuitMessage.Caption);
  edAwayMessage.Text:=GetStr('defaultAwayMessage', edAwayMessage.Text);

  // IRC
  gbIrcServer.Caption:=GetStr('gbIrcServer.Caption', gbIrcServer.Caption);
  lbIrcHost.Caption:=GetStr('lbIrcHost.Caption', lbIrcHost.Caption);
  lbIrcPort.Caption:=GetStr('lbIrcPort.Caption', lbIrcPort.Caption);
  lbIrcProxy.Caption:=GetStr('lbIrcProxy.Caption', lbIrcProxy.Caption);
  lbIrcProxyType.Caption:=GetStr('lbIrcProxyType.Caption', lbIrcProxyType.Caption);
  lbIrcChannels.Caption:=GetStr('lbIrcChannels.Caption', lbIrcChannels.Caption);
  lbIrcReadme.Caption:=GetStr('lbIrcReadme.Caption', lbIrcReadme.Caption);

  // Final
  lbFinalNote.Caption:=GetStr('lbFinalNote.Caption', lbFinalNote.Caption);

  pcWizardPages.SelectNextPage(true, false);
end;

procedure TfrmStartupWizard.UserInfoComplete();
begin
  if Length(Trim(edFirstNick.Text))=0 then
  begin
    edFirstNick.SetFocus();
    Exit;
  end;

  if Length(Trim(edSecondNick.Text))=0 then
  begin
    edSecondNick.Text:=Trim(edFirstNick.Text)+'2';
  end;

  pcWizardPages.SelectNextPage(true, false);
end;

procedure TfrmStartupWizard.IrcSettingsComplete();
begin
  if Length(Trim(edIrcHost.Text))=0 then
  begin
    edIrcHost.SetFocus();
    Exit;
  end;

  if Length(Trim(edIrcPort.Text))=0 then
  begin
    edIrcPort.Text:='6667';
  end;

  pcWizardPages.SelectNextPage(true, false);
end;

procedure TfrmStartupWizard.DoFinish();
var
  sl: TStringList;
  ChatClient: TChatClient;
  i: integer;
  s: string;
begin
  // Save settings
  MainConf['MyNick']:=edFirstNick.Text;
  MainConf['MySecondNick']:=edSecondNick.Text;
  MainConf['MyFullName']:=edFullName.Text;

  MainConf['AvatarURL']:=edAvatarURL.Text;
  MainConf['AwayMessage']:=edAwayMessage.Text;
  MainConf['QuitMessage']:=edQuitMessage.Text;

  // Setup IRC server
  Core.AddChatClient('IRC', 'IRC.ini');

  sl:=MainConf.GetStrings('ChatClientsList');
  sl.Add('IRC'+sl.NameValueSeparator+'IRC.ini');
  MainConf['ChatClientsList']:=sl.Text;

  ChatClient:=Core.ClientsManager.GetClient(0);
  ChatClient.SetOption('MyNick', MainConf['MyNick']);
  ChatClient.SetOption('MySecondNick', MainConf['MySecondNick']);
  ChatClient.SetOption('MyFullName', MainConf['MyFullName']);

  ChatClient.SetOption('AvatarURL', MainConf['AvatarURL']);
  ChatClient.SetOption('AwayMessage', MainConf['AwayMessage']);
  ChatClient.SetOption('QuitMessage', MainConf['QuitMessage']);

  ChatClient.SetOption('ServerHost', edIrcHost.Text);
  ChatClient.SetOption('ServerPort', edIrcPort.Text);
  ChatClient.SetOption('ServerProxy', edIrcProxy.Text);
  ChatClient.SetOption('ProxyType', IntToStr(cboxIrcProxyType.ItemIndex));
  ChatClient.SetOption('AutoConnect', '1');

  // Fill autojoin list
  sl:=ChatClient.GetConf.GetStrings('AutojoinList');
  for i:=0 to memoIrcChannels.Lines.Count-1 do
  begin
    s:='/JOIN '+Trim(memoIrcChannels.Lines[i]);
    if sl.IndexOf(s)<0 then sl.Add(s);
  end;
  ChatClient.SetOption('AutojoinList', sl.Text);

  ChatClient.Connect();

  // Quit
  self.Release();
end;

procedure TfrmStartupWizard.btnClick(Sender: TObject);
begin
  if Sender=btn1_Next then LangSelect()
  else if Sender=btn2_Next then UserInfoComplete()
  else if Sender=btn2_Prev then pcWizardPages.SelectNextPage(false, false)
  else if Sender=btn3_Next then IrcSettingsComplete()
  else if Sender=btn3_Prev then pcWizardPages.SelectNextPage(false, false)
  else if Sender=btn4_Next then DoFinish()
  else if Sender=btn4_Prev then pcWizardPages.SelectNextPage(false, false);
end;

end.
