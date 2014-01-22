{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru
}
//{$DEFINE AVATARS}
unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RichView, RVStyle, ToolWin,
  ImgList, ExtCtrls, jpeg, XPMan, RVGifAnimate,
  CoolTrayIcon, Menus, ActnPopupCtrl, ComCtrls, HTTPGet, AppEvnts,
  GifImage, XPStyleActnCtrls, ActnList, StdStyleActnCtrls,
  Clipbrd, CRVFData, Misc, Grids, Contnrs, IniFiles;

type
  TForm1 = class(TForm)
    MessStyle:      TRVStyle;
    ImageList24: TImageList;
    RightPanel:     TPanel;
    Image2:         TImage;
    Image1:         TImage;
    MainPanel:      TPanel;
    ToolBar1:       TToolBar;
    btnClear: TToolButton;
    btnRefresh: TToolButton;
    btnPassive: TToolButton;
    XPManifest1:    TXPManifest;
    btnActive: TToolButton;
    btnMemo: TToolButton;
    btnSettings: TToolButton;
    btnSmiles: TToolButton;
    btnAbout: TToolButton;
    btnExit: TToolButton;
    btnSeparator2: TToolButton;
    btnSeparator1: TToolButton;
    btnSeparator3: TToolButton;
    TrayIcon: TCoolTrayIcon;
    TrayPopUp: TPopupMenu;
    mExit: TMenuItem;
    N12: TMenuItem;
    mOptionsMenu: TMenuItem;
    mHideChatWindow: TMenuItem;
    mShowConfigWindow: TMenuItem;
    N16: TMenuItem;
    mStatusMenu: TMenuItem;
    mActive: TMenuItem;
    mNoPrivates: TMenuItem;
    mPassive: TMenuItem;
    mEnableMsgFilter: TMenuItem;
    mNotifyPrivates: TMenuItem;
    N25: TMenuItem;
    TrayPopUpFlash: TImageList;
    MinBtnNormal: TImage;
    MinBtnClicked: TImage;
    imgMinBtn: TImage;
    imgOnTopBtn: TImage;
    OnTopNormal: TImage;
    OnTopClicked: TImage;
    PageControl1: TPageControl;
    debug: TTabSheet;
    TabsPopup: TPopupMenu;
    mCloseTab: TMenuItem;
    mRefreshTab: TMenuItem;
    mRejoinTab: TMenuItem;
    FastMsgMenu: TPopupMenu;
    mNotifyAllMessages: TMenuItem;
    Timer1: TTimer;
    mHideTab: TMenuItem;
    PageControlPopup: TPopupMenu;
    mShowAllTabs: TMenuItem;
    mHideAllTabs: TMenuItem;
    N3: TMenuItem;
    Timer2: TTimer;
    ApplicationEvents1: TApplicationEvents;
    btnChannels: TToolButton;
    N9: TMenuItem;
    mDetachTab: TMenuItem;
    ImageList16: TImageList;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PageControl1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure PageControl1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PageControl1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShowHideChatClick(Sender: TObject);
    procedure AppDeactivate(Sender: TObject);
    procedure AppActivate(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure TrayIconBalloonHintClick(Sender: TObject);
    procedure imgMinBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgMinBtnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgOnTopBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgOnTopBtnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnAboutClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure btnMemoClick(Sender: TObject);
    procedure btnSmilesClick(Sender: TObject);
    procedure OnFastMsgMenuClick(Sender: TObject);
    procedure TrayPopUpMenuClick(Sender: TObject);
    procedure TrayPopUpPopup(Sender: TObject);
    procedure TabsPopupMenuClick(Sender: TObject);
    procedure OnTimer(Sender: TObject);
    procedure PageControlPopupPopup(Sender: TObject);
    procedure PageControlPopupClick(Sender: TObject);
    procedure MainPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure SeparateFormClose(Sender: TObject; var Action: TCloseAction);
    procedure SeparateFormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ApplicationEvents1ShowHint(var HintStr: String;
      var CanShow: Boolean; var HintInfo: THintInfo);
    procedure TabsPopupPopup(Sender: TObject);
  private
    ToolButtonsList: TObjectList;
    procedure WMHotkey( var msg: TWMHotkey ); message WM_HOTKEY;
    procedure HTTPGet1DoneFile(Sender: TObject; FileName: String;
      FileSize: Integer);
    procedure HTTPGet1Error(Sender: TObject);
    procedure HTTPGet1Progress(Sender: TObject; TotalSize, Readed: Integer);
  public
    HTTPGet1: THTTPGet;
    procedure LoadLanguage();
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FillToolBar(NewButtons: TObjectList);
    procedure OnToolBtnClick(Sender: TObject);
    procedure RegisterHotkeyString(HotkeyStr: string);
    procedure FlashIcon(sNick, sMes :String; ballons :boolean);
    procedure StopFlashing();
    procedure DownloadAvatar(UserNick, AvatarURL: string);
    procedure ParseBBTextToRV(MesText: TRichView; s: string; DefParaNo: Integer=0; bUseSmiles: boolean=true; bUseColors: boolean=true);
  end;

  function  GetStyleNo(CommandChar: Char; Color, StyleNo: Integer; MessStyle: TRVStyle): Integer;
  procedure ParseIRCTextToRVSimple(MesText: TRichView; s: string);
  procedure ParseIRCTextToRV(MesText: TRichView; s: string; DefParaNo: Integer=0; bUseSmiles: boolean=true; bUseColors: boolean=true);
  function FindTheSmile(StartFolder, FileName: string): string;
  procedure LogMessage(Text, PageName, ServerName: string);
  procedure OnProgramStart();
  procedure OnProgramStop();
  procedure DebugText(sText: string);
  function GetRealTabIndex(PageControl: TPageControl; X, Y: integer): integer;
  //procedure EnterCommandBox(Template, Caption, DefaultText: string; PageID: integer = -1);

type
  TLastTypedList = class(TStringList)
  public
    Current: integer;
  end;

  TColorArray = array of TColor;
  TColorStack = class
  private
    ColorArray: TColorArray;
    Current: Integer;
  public
    constructor Create();
    destructor Destroy; override;
    procedure Put(Color: TColor);
    function Get(): TColor;
    function Look(): TColor;
  end;

var
  Draging:      Boolean;         // true, when something dragged
  X0, Y0:       integer;
  Form1:        TForm1;

  Avatars24: TCustomImageList;  // custom avatars

{resourcestring
  sBtnSmilesHint = 'Смайлы';
  sBtnColorsHint = 'Цвета';
  sBtnUnderlinedHint = 'Подчеркнутый текст';
  sBtnItalicHint = 'Наклонный текст';
  sBtnBoldHint = 'Жирный текст';
  sLoadingAvatar = 'Загружаем аватар: %s для %s';}

var
  sAvatarLoading:string = 'Загружаем аватар: %s для %s';
  sAvatarLoaded:string = 'Аватар %s (%s байт) загружен.';
  sAvatarLoadError:string = 'Ошибка загрузки аватара';
  sTrayPopupShowChatWnd:string = 'Показать окно чата';
  sTrayPopupHideChatWnd:string = 'Скрыть окно чата';
  sBtnConnOn:string = 'Соединиться';
  sBtnConnOff:string = 'Разъединиться';
  sInfoDisconnected:string = '*** Рассоединён ***';
  sInfoCannotClose:string = 'C main-канала уйти пока что нельзя. Как вы потом джойниться-то куда-нить будете? :)';
  sInfoUncnownCommand:string = 'Неизвестная команда или не хватает параметров:';
  sInfoNotConnected:string = 'Ну и кому ты это сказал? Подключиться не забудь. :)';
  sInfoProgramError:string = 'Ошибка программы:';
  sInfoClientForPageNotFound:string = 'Не найден клиент чата для текущей страницы.';

  //:string = '';
const
  ciTabMenuBaseCount = 4;


implementation

uses Core, EnterCmd, ChatPage, Sounds, Plugins, ClientsFrame, FilesFrame,
  ChanListFrame, MainOptions, Smiles, Timer, DCC;

{$R *.dfm}

constructor TColorStack.Create();
begin
  SetLength(ColorArray, 0);
end;

destructor TColorStack.Destroy;
begin
  SetLength(ColorArray, 0);
  inherited Destroy();
end;

procedure TColorStack.Put(Color: TColor);
begin
  SetLength(ColorArray, Length(ColorArray)+1);
  ColorArray[Length(ColorArray)-1]:=Color;
end;

function TColorStack.Get(): TColor;
begin
  if Length(ColorArray)=0 then Result:=0
  else
  begin
    Result:=ColorArray[Length(ColorArray)-1];
    SetLength(ColorArray, Length(ColorArray)-1);
  end;
end;

function TColorStack.Look(): TColor;
begin
  if Length(ColorArray)=0 then Result:=0
  else
  begin
    Result:=ColorArray[Length(ColorArray)-1];
  end;
end;


//========================================================
procedure TForm1.AppActivate(Sender: TObject);
//var
//  n,i :Integer;
begin
  if not Assigned(PagesManager) then Exit;
  PagesManager.GetActivePage.SetActive(true);
  StopFlashing;
end;

procedure TForm1.AppDeactivate(Sender: TObject);
var
  i :Integer;
begin
  if not Assigned(PagesManager) then Exit;
  for i:=0 to PagesManager.PagesCount-1 do
  begin
    TChatPage(PagesManager.PagesList[i]).SetActive(false);
  end;
  StopFlashing;
end;

//Создание формы без заголовка
procedure TForm1.Createparams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := (Style or WS_POPUP) and (not WS_DLGFRAME);
end;

//Сворачивание по ESC
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Mgs: TMsg;
begin
  if not Assigned(PagesManager) then Exit;
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    PeekMessage(Mgs, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
    Application.Minimize;
    TrayIcon.HideMainForm;
    TrayPopUp.Items[0].Caption := sTrayPopupShowChatWnd;
  end

  else if Key = VK_F1   then
  begin
    Core.PagesManager.ActivatePage(ciInfoPageID);
  end

  else if Key = VK_F2   then
  begin
    Core.PagesManager.ActivatePage(ciDebugPageID);
  end

  else if Key = VK_F3   then
  begin
    Core.PagesManager.ActivatePage(ciNotesPageID);
  end

  else if Key = VK_F4   then
  begin
    Core.PagesManager.ActivatePage(ciFilesPageID);
  end

  else if (Key = VK_LEFT) and (Shift = [ssAlt]) then
  begin
    PageControl1.SelectNextPage(false, true);
    //Core.PagesManager.ActivatePage(PageControl1.ActivePage.Tag);
  end
  
  else if (Key = VK_RIGHT) and (Shift = [ssAlt]) then
  begin
    PageControl1.SelectNextPage(true, true);
    //Core.PagesManager.ActivatePage(PageControl1.ActivePage.Tag);
  end;
end;


// Показать записку из трея
procedure TForm1.FlashIcon(sNick, sMes :String; ballons :boolean);
begin
  //if IsIconic(Application.Handle) then
  begin
    if (not Application.Active)
    //and (not IsIconic(Application.Handle))
    then
    begin
      TrayIcon.IconList := TrayPopUpFlash;
      TrayIcon.CycleInterval := 400;
      TrayIcon.CycleIcons := True;
      if ballons then
        TrayIcon.ShowBalloonHint(sNick, copy(sMes, 1, 250) + '...', bitInfo, 15);
    end;
    TrayIcon.Hint := '<' + sNick + '> ' + copy(sMes, 1, 50)+'...';
  end;
end;

//Обработка хоткея на вызов проги
procedure TForm1.WMHotkey( var msg: TWMHotkey );
begin
  if msg.hotkey = 1 then
  begin
    ShowHideChatClick(self);
  end;
end;

//===================================================
// создание основной формы
//===================================================
procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  HTTPGet1:=THTTPGet.Create(self);
  HTTPGet1.OnDoneFile:=HTTPGet1DoneFile;
  HTTPGet1.OnProgress:=HTTPGet1Progress;
  HTTPGet1.OnError:=HTTPGet1Error;

  Self.DoubleBuffered:=true;
  self.RightPanel.DoubleBuffered:=true;
  self.PageControl1.DoubleBuffered:=true;
  self.ToolBar1.DoubleBuffered:=true;

  //LoadLanguageMain();
  TrayPopUpFlash.GetIcon(0, Form1.Icon);
  TrayPopUpFlash.GetIcon(0, TrayIcon.Icon);

  imgMinBtn.Picture := MinBtnNormal.Picture;
  imgOnTopBtn.Picture := OnTopNormal.Picture;

  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW or WS_EX_TOPMOST);
  ShowWindow(Application.Handle, SW_SHOW);

  Application.OnDeactivate := AppDeactivate;
  Application.OnActivate := AppActivate;
  btnActive.Down:=true;

  //LoadAvatars;
  // Убираем все панели
  for i:=0 to PageControl1.PageCount-1 do PageControl1.Pages[i].Free();

  OnProgramStart();

end;

//Перетаскивание за любое место. (Надо переписать)
procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture();
  Perform(WM_SYSCOMMAND, $F012, 0);
end;

// Шрифт в строку
function FontToStr(font: TFont): string;
begin
  Result:=font.Name+', '+IntToStr(font.Size);
  if (fsBold in font.Style) then Result:=Result+', bold';
  if (fsItalic in font.Style) then Result:=Result+', italic';
  if (fsUnderline in font.Style) then Result:=Result+', underline';
end;

// Строку в шрифт
function StrToFont(s: string; font: TFont): Boolean;
var
  ss, sn: string;

function GetParam(var sr: string): string;
var
  i: integer;
begin
  Result:='';
  i:=Pos(',', sr);
  if i=0 then i := maxint-1;
  Result:=Trim(Copy(sr, 1, i-1));
  Delete(sr, 1, i);
  sr:=Trim(sr);
end;

begin
  Result:=False;
  if not Assigned(font) then Exit;
  ss:=s;
  font.Name:=GetParam(ss);
  font.Size:=StrToIntDef(GetParam(ss), font.Size);
  while ss<>'' do
  begin
    sn:=GetParam(ss);
    if sn='bold' then font.Style:=font.Style + [fsBold];
    if sn='italic' then font.Style:=font.Style + [fsItalic];
    if sn='underline' then font.Style:=font.Style + [fsUnderline];
  end;
  Result:=True;
end;

// Шрифт в строку
function FontInfoToStr(font: TFontInfo): string;
begin
  Result:=font.FontName+', '+IntToStr(font.Size);
  if (fsBold in font.Style) then Result:=Result+', bold';
  if (fsItalic in font.Style) then Result:=Result+', italic';
  if (fsUnderline in font.Style) then Result:=Result+', underline';
  if (fsStrikeOut in font.Style) then Result:=Result+', strikeout';
end;

// Строку в шрифт
function StrToFontInfo(s: string; font: TFontInfo): Boolean;
var
  ss, sn: string;

function GetParam(var sr: string): string;
var
  i: integer;
begin
  Result:='';
  i:=Pos(',', sr);
  if i=0 then i := maxint-1;
  Result:=Trim(Copy(sr, 1, i-1));
  Delete(sr, 1, i);
  sr:=Trim(sr);
end;

begin
  Result:=False;
  if not Assigned(font) then Exit;
  ss:=s;
  font.FontName:=GetParam(ss);
  font.Size:=StrToIntDef(GetParam(ss), font.Size);
  while ss<>'' do
  begin
    sn:=GetParam(ss);
    if sn='bold' then font.Style:=font.Style + [fsBold];
    if sn='italic' then font.Style:=font.Style + [fsItalic];
    if sn='underline' then font.Style:=font.Style + [fsUnderline];
    if sn='strikeout' then font.Style:=font.Style + [fsStrikeOut];
  end;
  Result:=True;
end;

// Получить номер стиля по коду IRC. Если такой стиль не определен, то он добавляется
function GetStyleNo(CommandChar: Char; Color, StyleNo: Integer; MessStyle: TRVStyle): Integer;
var
  fi: TFontInfo;
begin
  fi := TFontInfo.Create(nil);
  //fi.FontName := conf.fntArray[1].Name;
  //fi.Size := conf.fntArray[1].Size;
  fi.Assign(MessStyle.TextStyles[StyleNo]);
  case CommandChar of
    #2:
      if fsBold in fi.Style then
        fi.Style := fi.Style-[fsBold]
      else
        fi.Style := fi.Style+[fsBold];
    #22:
      if fsItalic in fi.Style then
        fi.Style := fi.Style-[fsItalic]
      else
        fi.Style := fi.Style+[fsItalic];
    #31:
      if fsUnderline in fi.Style then
        fi.Style := fi.Style-[fsUnderline]
      else
        fi.Style := fi.Style+[fsUnderline];
    #3:
      fi.Color := Color;
    #4:
      fi.BackColor := Color;
    #1:
    if fi.Jump then
    begin
      fi.Jump := false;
      fi.Color := Color;
      fi.Style := fi.Style-[fsUnderline];
    end
    else
    begin
      fi.Jump := true;
      fi.Color := clBlue;
      fi.Style := fi.Style+[fsUnderline];
    end;
    #11:
    if fi.Jump then
    begin
      fi.Jump:=false;
      fi.HoverColor := clNone;
    end
    else
    begin
      fi.Jump:=true;
      fi.HoverColor := Color;
    end;
  end;
  Result := MessStyle.TextStyles.FindSuchStyle(StyleNo, fi, RVAllFontInfoProperties);
  if Result<0 then
  begin
    MessStyle.TextStyles.Add();
    Result := MessStyle.TextStyles.Count-1;
    MessStyle.TextStyles[Result].Assign(fi);
    MessStyle.TextStyles[Result].Standard := False;
  end;
  fi.Free();
end;

function FindTheSmile(StartFolder, FileName: string): string;
var
  SearchRec: TSearchRec;
  FindResult: Integer;
begin
  result:='';
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
            result:=FindTheSmile(StartFolder+Name, FileName);
            if result <> '' then Exit;
          end;
        end
        else
        begin
          if Name = FileName then
          begin
            result := StartFolder+FileName;
            Exit;
          end;
        end;
        FindResult := FindNext(SearchRec);
      end;
  finally
    FindClose(SearchRec);
  end;
end;

procedure ParseIRCTextToRVSimple(MesText: TRichView; s: string);
var
  i, StartIndex: integer;
  ParaNo, StyleNo: integer;
  ColorValue: String;
  bColorValue: String;
  sResult: string;
  bHLink: boolean;
{*****************************************************************************}
procedure AddString(StartIndex :integer; EndIndex: integer);
var
  str: String;
begin
  str := Copy(s, StartIndex, EndIndex-StartIndex+1);
  sResult:=sResult+str;
end;

{*****************************************************************************}
begin
  sResult:='';
  StartIndex := 1;
  for i := 1 to Length(s) do
  begin
    // Обработка значения цвета фона
    if Length(bColorValue) > 0 then
    begin
      if (s[i] in ['0'..'9']) and (Length(bColorValue) < 3) then
        bColorValue := bColorValue + s[i]
      else
      begin
        StartIndex := i;
        //if bColorValue='0' then bColorValue:='0';
        bColorValue :='';
      end;
    end;
    // Обработка значения цвета текста
    if Length(ColorValue) > 0 then
    begin
      if (s[i] in ['0'..'9']) and (Length(ColorValue) < 3) then
        ColorValue := ColorValue + s[i]
      else
      begin
        if s[i] = ',' then bColorValue :='0';
        StartIndex := i;
        if ColorValue='0' then ColorValue:='1';
        ColorValue :='';
      end;
    end;

    case s[i] of
      #2, #22, #31:
      begin
        AddString(StartIndex, i-1);
        StartIndex := i+1;
      end;
      #3:
      begin
        AddString(StartIndex, i-1);
        ColorValue := '0';
      end;
      #4:
      begin
        AddString(StartIndex, i-1);
        bColorValue := '0';
      end;
      #11:
      begin
        AddString(StartIndex, i-1);
        StartIndex := i+1;
      end;
    end;
  end;

  if Length(ColorValue+bColorValue) = 0 then
    AddString(StartIndex, Length(s));

  MesText.AddNL(sResult, 0, 0);
  //MesText.FormatTail;
end;

// Вставка текста с учетом смайлов и цветовых кодов.
// p - номер закладки (-1 = текущая)
// Коды:
// #2  - жирный текст
// #22 - наклонный текст
// #31 - подчеркнутый текст
// #3 - цвет текста
// #4 - цвет фона
procedure ParseIRCTextToRV(MesText: TRichView; s: string; DefParaNo: Integer=0; bUseSmiles: boolean=true; bUseColors: boolean=true);
var
  i, sml, StartIndex:    Integer;
  ParaNo, StyleNo:       Integer;
  ColorValue, SmileName, SmileFilename: string;
  bColorValue: string;
  bHLink, bSmile: boolean;

{*****************************************************************************}
procedure AddString(StartIndex :integer; EndIndex: integer);
var
  str: String;
begin
  //if EndIndex = 0 then EndIndex:=StartIndex;
  str := Copy(s, StartIndex, EndIndex-StartIndex+1);
  MesText.AddNL(Str, StyleNo, ParaNo);
  ParaNo := -1;
end;

procedure AddSmile(Smile :String);
var
  gif: TGifImage;
  //gif: TPicture;
begin
  gif := TGIFImage.Create;
  gif.LoadFromFile(Smile);
  //gif := TPicture.Create;
  //gif.LoadFromFile(Smile);
  with MesText do
  begin
    AddPictureEx('', gif, ParaNo, rvvaBaseLine);
    //AddPictureEx('', gif.Graphic, ParaNo, rvvaBaseLine);
  end;
end;

procedure ReplaceWords();
var i: integer;
begin
  // линк на имя из списка
  s:=StringReplace(s, 'http://', '#http://', [rfReplaceAll]);

  if not bUseSmiles then Exit;
  // Подстановка смайлов
  if smList = nil then LoadSmilesIni;
  for i:=0 to smList.Count-1 do
  begin
    //s:=AnsiReplaceStr(s, ':-)', ':base_1:');
    s:=StringReplace(s, smList.ValueFromIndex[i], ':'+smList.Names[i]+':', [rfReplaceAll]);
  end;

end;
{*****************************************************************************}

begin
  if MainConf.GetBool('DisableTextColors') then bUseColors:=false;
  if MainConf.GetBool('DisableSmiles') then bUseSmiles:=false;
  sml := 0;
  ParaNo := DefParaNo;
  StyleNo := 0;
  StartIndex := 1;
  SmileName := '';
  bSmile := false;
  bHLink:=false;
  ReplaceWords;
  for i := 1 to Length(s) do
  begin
    // Обработка значения цвета фона
    if Length(bColorValue) > 0 then
    begin
      if (s[i] in ['0'..'9']) and (Length(bColorValue) < 3) then
        bColorValue := bColorValue + s[i]
      else
      begin
        StartIndex := i;
        //if bColorValue='0' then bColorValue:='0';
        if bUseColors then
          StyleNo := GetStyleNo(#4, AnsiColor(StrToIntDef(bColorValue, 0)), StyleNo, MesText.Style);
        bColorValue :='';
      end;
    end;
    // Обработка значения цвета текста
    if Length(ColorValue) > 0 then
    begin
      if (s[i] in ['0'..'9']) and (Length(ColorValue) < 3) then
        ColorValue := ColorValue + s[i]
      else
      begin
        if s[i] = ',' then bColorValue :='0';
        StartIndex := i;
        if ColorValue='0' then ColorValue:='1';
        if bUseColors then
          StyleNo := GetStyleNo(#3, AnsiColor(StrToIntDef(ColorValue,0)), StyleNo, MesText.Style);
        ColorValue :='';
      end;
    end;
    // Обработка имени смайла
    if bSmile and (sml < StrToIntDef(MainConf['SmilesCount'], 5)) then
    begin
      if (s[i] <> ':') then
        SmileName := SmileName + s[i]
      else
      begin
        SmileFilename:=FindTheSmile(Core.glHomePath+MainConf['SmilesPath'], SmileName+'.gif');
        if (Length(SmileName) > 0) And (Length(SmileFilename) > 0) then //и если файл существует
        begin
          AddString(StartIndex, i-Length(SmileName)-2);
          AddSmile(SmileFilename);
          StartIndex := i+1;
          SmileName :='';
          bSmile := false;
          sml := sml + 1;
        end
        else
        begin

        end;
      end;
    end;
    if bHLink then
    begin
      // обработка имени канала
      //if s[i]=' ' then
      if (s[i] in [' ',',',#9,#11]) then
      begin
        AddString(StartIndex, i-1);
        StartIndex := i;
        StyleNo := GetStyleNo(#1, 0, StyleNo, MesText.Style);
        bHLink:=false;
      end;
    end;

    case s[i] of
      #2, #22, #31:
      begin
        AddString(StartIndex, i-1);
        StartIndex := i+1;
        if bUseColors then
          StyleNo := GetStyleNo(LowerCase(s[i])[1], clNone, StyleNo, MesText.Style);
      end;
      #3:
      begin
        AddString(StartIndex, i-1);
        ColorValue := '0';
      end;
      #4:
      begin
        AddString(StartIndex, i-1);
        bColorValue := '0';
      end;
      '#':
      begin
        AddString(StartIndex, i-1);
        if Copy(s, i+1, 7) = 'http://' then StartIndex := i+1
        else StartIndex := i;

        StyleNo := GetStyleNo(#1, 0, StyleNo, MesText.Style);
        bHLink := true;
      end;
      #9:
      begin
        AddString(StartIndex, i-1);
        StartIndex := i+1;
        MesText.AddTab(StyleNo, ParaNo);
      end;
      #11:
      begin
        AddString(StartIndex, i-1);
        StartIndex := i+1;
        StyleNo := GetStyleNo(#11, clMaroon, StyleNo, MesText.Style);
        bHLink := true;
      end;
      ':':
      begin
        if bUseSmiles and (not bHLink) then
          bSmile := true;
        SmileName := '';
      end;
    end;
  end;

  if Length(ColorValue+bColorValue) = 0 then
    AddString(StartIndex, Length(s));

  MesText.FormatTail;
end;

// Вставка текста с учетом смайлов и цветовых кодов.
// Коды:
// [b][/b] - жирный текст
// [i][/i] - наклонный текст
// [u][/u] - подчеркнутый текст
// [s][/s] - зачеркнутый текст
// [color=red][/color] - цвет текста [c=][/c]
// [bgcolor=xx] [bgc=xx]- цвет фона  [bgc=][/bgc]
// [url=xxx]text[/url] - ссылка
// [size=15][/size] - размер шрифта (в пикселях)
// [code][/code] - моноширинный текст с подсветкой фона
procedure TForm1.ParseBBTextToRV(MesText: TRichView; s: string; DefParaNo: Integer=0; bUseSmiles: boolean=true; bUseColors: boolean=true);
var
  i, n: Integer;
  ss: string;
  ParaNo, StyleNo: Integer;

  tagOpen: Boolean;
  tagStartPos, tagEndPos: Integer;
  tagName, tagParam: string;
  TmpColor: TColor;
  fi, CurStyle, DefStyle: TFontInfo;
  AttrStack: TStringList;

{*****************************************************************************}
procedure WriteString(var str: string);
begin
  MesText.AddNL(Str, StyleNo, ParaNo);
  ParaNo := -1;
  str:='';
end;

function GetCurStyleNo(): integer;
var
  fi: TFontInfo;
begin
  Result := MessStyle.TextStyles.FindSuchStyle(StyleNo, CurStyle, RVAllFontInfoProperties);
  if Result<0 then
  begin
    // Создаем новый стиль и заполняем его по текущему
    MessStyle.TextStyles.Add();
    Result := MessStyle.TextStyles.Count-1;
    MessStyle.TextStyles[Result].Assign(CurStyle);
    MessStyle.TextStyles[Result].Standard := False;
  end;
end;

function PopAttr(AttrName: string; defValue: string = ''): string;
var
  i: integer;
begin
  Result:=defValue;
  for i:=AttrStack.Count-1 downto 0 do
  begin
    if AttrStack.Names[i]=AttrName then
    begin
      Result:=AttrStack.ValueFromIndex[i];
      AttrStack.Delete(i);
      Break;
    end;
  end;
end;

function PopAttrInt(AttrName: string; defValue: Integer = 0): Integer;
begin
  Result:=StrToIntDef(PopAttr(AttrName), defValue);
end;

{*****************************************************************************}
// Принцип работы:
// Запоминаем текущий стиль и стиль по умолчанию.
// Читаем по одному символу, если нашли открывающую скобку, то ставим признак тега, запоминаем позицию его начала
// Если нашли закрывающую скобку, то читаем тег от позиции начала и выделяем его параметр (после знака "=")
// В зависимости от тега устанеавливаем параметры текущего стиля текста
begin
  if MainConf.GetBool('DisableTextColors') then bUseColors:=false;
  if MainConf.GetBool('DisableSmiles') then bUseSmiles:=false;
  ParaNo := DefParaNo;
  StyleNo := 0;

  tagOpen:=False;
  tagStartPos:=0;
  tagEndPos:=0;
  ss:='';
  // Current style
  CurStyle:=TFontInfo.Create(nil);
  CurStyle.Assign(MesText.Style.TextStyles[StyleNo]);
  // Default style
  DefStyle:=TFontInfo.Create(nil);
  DefStyle.Assign(MesText.Style.TextStyles[StyleNo]);
  // Attributes stack
  AttrStack:=TStringList.Create();

  for i := 1 to Length(s) do
  begin
    // Начало тега
    if s[i]='[' then
    begin
      WriteString(ss);
      tagOpen:=True;
      tagStartPos:=i;
    end

    // Конец тэга
    else if s[i]=']' then
    begin
      if tagOpen then
      begin
        tagOpen:=False;
        tagEndPos:=i;
        ss:=Copy(s, tagStartPos+1, tagEndPos-tagStartPos-1);

        n:=Pos('=', ss);
        if n=0 then n:=MaxInt;
        tagName:=LowerCase(Copy(ss, 1, n-1));
        tagParam:=Copy(ss, n+1, MaxInt);
        ss:='';
        if Length(tagName)=0 then Continue;

        // Обработка тегов
        if tagName[1] <> '/' then
        begin
          // открывающие теги
          if (tagName='b') then
          begin
            CurStyle.Style := CurStyle.Style+[fsBold];
          end

          else if (tagName='i') then
          begin
            CurStyle.Style := CurStyle.Style+[fsItalic];
          end

          else if (tagName='u') then
          begin
            CurStyle.Style := CurStyle.Style+[fsUnderline];
          end

          else if (tagName='s') then
          begin
            CurStyle.Style := CurStyle.Style+[fsStrikeOut];
          end

          else if (tagName='color') or (tagName='c') then
          begin
            // save current color
            AttrStack.Add('c='+IntToStr(CurStyle.Color));
            CurStyle.Color:=AnsiColor(StrToIntDef(tagParam, DefStyle.Color));
          end

          else if (tagName='bgcolor') or (tagName='bgc') then
          begin
            // save current color
            AttrStack.Add('bgc='+IntToStr(CurStyle.BackColor));
            CurStyle.BackColor:=AnsiColor(StrToIntDef(tagParam, DefStyle.BackColor));
          end

          else if tagName = 'url' then
          begin
            AttrStack.Add('jc='+IntToStr(CurStyle.Color));
            AttrStack.Add('ju='+BoolToStr((fsUnderline in CurStyle.Style)));
            CurStyle.Jump := true;
            CurStyle.Color := clBlue;
            CurStyle.Style := CurStyle.Style+[fsUnderline];
          end

          else if (tagName='size') then
          begin
            // save current size
            AttrStack.Add('size='+IntToStr(CurStyle.Size));
            CurStyle.Size:=StrToIntDef(tagParam, DefStyle.Size);
          end

          else if tagName = 'code' then
          begin
            // save font attributes
            AttrStack.Add('code_c='+IntToStr(CurStyle.Color));
            AttrStack.Add('code_bgc='+BoolToStr((fsUnderline in CurStyle.Style)));
            AttrStack.Add('code_font='+FontInfoToStr(CurStyle));
            // Set CODE font style
            fi:=MessStyle.TextStyles[5];
            CurStyle.Assign(fi); // Monospace
            CurStyle.FontName:='Courier New';
            {CurStyle.Color := DefStyle.Color;
            CurStyle.BackColor := DefStyle.BackColor;
            CurStyle.FontName:='Courier';
            CurStyle.Size:=DefStyle.Size;
            CurStyle.Style := CurStyle.Style-[fsBold];
            CurStyle.Style := CurStyle.Style-[fsItalic];
            CurStyle.Style := CurStyle.Style-[fsUnderline];
            CurStyle.Style := CurStyle.Style-[fsStrikeOut];}
          end

          else
          begin
            // Неизвестный тег - выводим без изменений
            ss:=Copy(s, tagStartPos, tagEndPos-tagStartPos+1);
          end;

        end
        else
        begin
          // закрывающие теги
          if (tagName='/b') then
          begin
            CurStyle.Style := CurStyle.Style-[fsBold];
          end

          else if (tagName='/i') then
          begin
            CurStyle.Style := CurStyle.Style-[fsItalic];
          end

          else if (tagName='/u') then
          begin
            CurStyle.Style := CurStyle.Style-[fsUnderline];
          end

          else if (tagName='/s') then
          begin
            CurStyle.Style := CurStyle.Style-[fsStrikeOut];
          end

          else if (tagName='/color') or (tagName='/c') then
          begin
            CurStyle.Color:=PopAttrInt('c', DefStyle.Color);
          end

          else if (tagName='/bgcolor') or (tagName='/bgc') then
          begin
            CurStyle.BackColor:=PopAttrInt('bgc', DefStyle.BackColor);
          end

          else if tagName = '/url' then
          begin
            CurStyle.Jump := false;
            // Restore text color
            CurStyle.Color:=PopAttrInt('jc', DefStyle.Color);
            // Restore underline attr
            tagParam:=PopAttr('ju', '0');
            if tagParam='0' then
              CurStyle.Style := CurStyle.Style-[fsUnderline]
            else
              CurStyle.Style := CurStyle.Style+[fsUnderline];
          end

          else if (tagName='/size') then
          begin
            CurStyle.Size:=PopAttrInt('size', DefStyle.Size);
          end

          else if tagName = '/code' then
          begin
            // Restore font attributes
            CurStyle.Color := PopAttrInt('code_c', DefStyle.Color);
            CurStyle.BackColor := PopAttrInt('code_bgc', DefStyle.BackColor);
            tagParam:=PopAttr('code_font', '');
            if tagParam<>'' then StrToFontInfo(tagParam, CurStyle);
          end

          else
          begin
            // Неизвестный тег - выводим без изменений
            ss:=Copy(s, tagStartPos, tagEndPos-tagStartPos+1);
          end;
        end;
        // Получаем номер текущего стиля
        StyleNo:=GetCurStyleNo();
        Continue;
      end;
    end

    // Начало или конец смайла
    else if s[i]=':' then
    begin
    end;
    ss:=ss+s[i];

  end;
  WriteString(ss);
  //MesText.FormatTail;
  AttrStack.Free();
end;


///////////////////////////////////////////////////////////////////////////////
//  Подключение-отключение
///////////////////////////////////////////////////////////////////////////////

procedure TForm1.btnExitClick(Sender: TObject);
begin
  Close();
end;

{procedure pause(dwMilliseconds :integer);
var
  iStart, iStop: DWORD;
begin
  iStart := GetTickCount;
  repeat
    iStop := GetTickCount;
    Application.ProcessMessages;
  until (iStop - iStart) >= dwMilliseconds;
end; }

procedure TForm1.btnClearClick(Sender: TObject);
begin
  if not Assigned(PagesManager) then Exit;
  if (PagesManager.GetActivePage.Frame is TChatFrame) then
    (PagesManager.GetActivePage.Frame as TChatFrame).ClearMesText();
  if (PagesManager.GetActivePage.Frame is TFrameChanList) then
    (PagesManager.GetActivePage.Frame as TFrameChanList).ClearMesText();
  if (PagesManager.GetActivePage.Frame is TFrameClients) then
    (PagesManager.GetActivePage.Frame as TFrameClients).ClearMesText();
end;

procedure TForm1.FormShow(Sender: TObject);
var
  ap: TTabSheet;
begin
  ap:=self.PageControl1.ActivePage;
  if Assigned(ap) and Assigned(PagesManager) then PagesManager.ActivatePage(ap.Tag);
end;

///////////////////////////////////////////////////////////////////////////////
//  Перетаскивание закладок
///////////////////////////////////////////////////////////////////////////////

procedure TForm1.PageControl1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if Sender is TPageControl then
    Accept := True;
end;

procedure TForm1.PageControl1DragDrop(Sender, Source: TObject; X,Y: Integer);
var
  i: integer;
begin
  if not (Sender is TPageControl) then Exit;
  with PageControl1 do
  begin
    i:=GetRealTabIndex((Sender as TPageControl), X, Y);

    if i <> ActivePage.PageIndex then
      ActivePage.PageIndex := i;
  end;
end;

procedure TForm1.PageControl1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  n: integer;
  PageID: integer;
begin
  PageID:=-1;
  n:=GetRealTabIndex(PageControl1, X, Y);
  if n >= 0 then
  begin;
    PageControl1.ActivePageIndex:=n;
    PageID:=PageControl1.ActivePage.Tag;
    Core.PagesManager.ActivatePage(PageID);
  end;

  if Button = mbRight then
  begin
    TabsPopup.Tag:=PageID;
    TabsPopup.Popup(Form1.Left+X, Form1.Top+Y+5);
  end
  else
  begin
    PageControl1.BeginDrag(False);
  end;
end;

procedure TForm1.PageControl1Change(Sender: TObject);
var i: integer;
begin
  if not Assigned(PagesManager) then Exit;
  for i:=0 to PagesManager.PagesCount-1 do
  begin
    (PagesManager.PagesList[i] as TChatPage).SetActive(false);
  end;

  Core.PagesManager.ActivePageID:=PageControl1.ActivePage.Tag;
//  for i:=0 to PageControl1.PageCount-1 do
//  begin
//    if PageControl1.Pages[i].TabIndex = PageControl1.TabIndex then
//    begin
//      Core.PagesManager.SetActivePage(PageControl1.Pages[i].Tag);
//    end;
//  end;
end;

///////////////////////////////////////////////////////////////////////////////
//  Обработчики нажатия кнопок
///////////////////////////////////////////////////////////////////////////////

procedure TForm1.btnSmilesClick(Sender: TObject);
begin
  Core.ShowSmiles();
end;

procedure TForm1.OnFastMsgMenuClick(Sender: TObject);
begin
  // из-за автоматического назначения хоткеев,
  // caption лучше не использовать
  Say(MainConf.GetStrings('FastMsgList').Strings[(Sender as TMenuItem).Tag]);
end;

procedure TForm1.btnMemoClick(Sender: TObject);
// показ "быстрых сообщений" в виде меню
var
  tmpMenuItem: TMenuItem;
  slFastMsgList: TStringList;
  i: integer;
begin
  FastMsgMenu.Items.Clear;
  slFastMsgList:=MainConf.GetStrings('FastMsgList');
  if slFastMsgList=nil then Exit;
  for i:=0 to slFastMsgList.Count-1 do
  begin
    tmpMenuItem:=TMenuItem.Create(Self);
    tmpMenuItem.Caption:=slFastMsgList.Strings[i];
    tmpMenuItem.tag:=i;
    tmpMenuItem.OnClick:=OnFastMsgMenuClick;
    FastMsgMenu.Items.Add(tmpMenuItem);
  end;
  FastMsgMenu.Popup(btnMemo.ClientOrigin.X, btnMemo.ClientOrigin.Y);
end;

// Кнопка настроек
procedure TForm1.btnSettingsClick(Sender: TObject);
begin
  Core.ShowOptions();
end;

procedure TForm1.ShowHideChatClick(Sender: TObject);
begin

  if Not IsIconic(Application.Handle) then
  //SetForegroundWindow(Application.Handle)
  begin
    Application.Minimize;
    TrayIcon.HideMainForm;
    TrayPopUp.Items[0].Caption := sTrayPopupShowChatWnd;
  end
  else
  begin
    Application.Restore;
    TrayIcon.ShowMainForm;
    TrayPopUp.Items[0].Caption := sTrayPopupHideChatWnd;
  end;
end;

procedure TForm1.StopFlashing();
begin
  if TrayIcon.CycleIcons then
  begin
    TrayIcon.Hint := Caption;
    TrayIcon.CycleIcons := False;
    TrayIcon.IconList := nil;
    //TrayPopUpImage.GetIcon(2, TrayIcon.Icon);
    ImageList16.GetIcon(0, TrayIcon.Icon);
  end;
end;

procedure TForm1.TrayIconClick(Sender: TObject);
begin
  StopFlashing;
  if (not Application.Active)
  and (not IsIconic(Application.Handle)) then
    Application.BringToFront;

end;

procedure TForm1.TrayIconBalloonHintClick(Sender: TObject);
begin
  //TrayIconClick(Sender);
end;

procedure TForm1.imgMinBtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  imgMinBtn.Picture := MinBtnClicked.Picture;
end;

procedure TForm1.imgMinBtnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  imgMinBtn.Picture := MinBtnNormal.Picture;
  if (imgMinBtn.Width > X)  And (X > 0) And (imgMinBtn.Height > Y) And (Y > 0) then
  begin
    if Form1.FormStyle = fsStayOnTop then
    begin
      Form1.FormStyle := fsNormal;
      imgOnTopBtn.Picture := OnTopClicked.Picture
    end;
    //Application.Minimize;
    ShowHideChatClick(Sender);
  end;
end;

procedure TForm1.imgOnTopBtnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Form1.FormStyle = fsNormal then
    imgOnTopBtn.Picture := OnTopClicked.Picture
  else
    imgOnTopBtn.Picture := OnTopNormal.Picture;
end;

procedure TForm1.imgOnTopBtnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (imgOnTopBtn.Width > X)  And (X > 0) And (imgOnTopBtn.Height > Y) And (Y > 0) then
  begin
    if Form1.FormStyle = fsStayOnTop then
      Form1.FormStyle := fsNormal
    else
      Form1.FormStyle := fsStayOnTop;
  end;
  if Form1.FormStyle = fsStayOnTop then
    imgOnTopBtn.Picture := OnTopClicked.Picture
  else
    imgOnTopBtn.Picture := OnTopNormal.Picture;
end;

procedure TForm1.btnAboutClick(Sender: TObject);
begin
  if Assigned(PagesManager) then PagesManager.ActivatePage(ciInfoPageID);
end;

procedure TForm1.OnToolBtnClick(Sender: TObject);
begin
  if (Sender is TToolButton) then
  begin
    Say((Sender as TToolButton).Caption);
  end;
end;

procedure TForm1.FillToolBar(NewButtons: TObjectList);
var
  i: integer;
  NewTB: TToolButton;
  ClientTB: TClientToolButton;
begin
  //ToolBar1.Visible:=false;
  if not Assigned(ToolButtonsList) then ToolButtonsList:=TObjectList.Create(false);

  // detach all predefined buttons
  btnClear.Parent:=nil;
  btnRefresh.Parent:=nil;
  btnChannels.Parent:=nil;
  btnSeparator1.Parent:=nil;
  btnActive.Parent:=nil;
  btnPassive.Parent:=nil;
  btnSeparator2.Parent:=nil;

  // detach current buttons
  for i:=ToolButtonsList.Count-1 downto 0 do
  begin
    TToolButton(ToolButtonsList[i]).Parent:=nil;
  end;
  ToolButtonsList.Clear();

  if Assigned(NewButtons) then
  begin

    NewTB:=TToolButton.Create(ToolBar1);
    NewTB.Width:=8;
    NewTB.Wrap:=true;
    NewTB.Style:=tbsSeparator;
    NewTB.Parent:=ToolBar1;
    ToolButtonsList.Add(NewTB);

    for i:=0 to NewButtons.Count-1 do
    begin
      NewTB:=TToolButton(NewButtons[i]);
      if NewTB.Caption='---' then
      begin
        NewTB.Width:=8;
      end
      else
      begin
        NewTB.AutoSize:=true;
        NewTB.ShowHint:=true;
      end;
      NewTB.Wrap:=true;
      NewTB.Parent:=ToolBar1;
      ToolButtonsList.Add(NewTB);
    end;
  end;
  ToolBar1.Height:=ToolBar1.Height-1;
  //ToolBar1.Visible:=true;
end;



///////////////////////////////////////////////////////////////////////////////
//  Обработчики особых событий
///////////////////////////////////////////////////////////////////////////////

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //AnimateWindow(TForm(Sender).Handle, 500, AW_HIDE or AW_BLEND);
end;

procedure TForm1.SeparateFormClose(Sender: TObject; var Action: TCloseAction);
var
  i: integer;
  Page: TChatPage;
begin
  if not Assigned(PagesManager) then Exit;
  //AnimateWindow(TForm(Sender).Handle, 500, AW_HIDE or AW_BLEND);
  Page:=Core.PagesManager.GetPage(TForm(Sender).Tag);
  Page.Frame.Parent := Page.TabSheet;
  Core.PagesManager.ActivatePage(Page.PageID);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  OnProgramStop();
  UnRegisterHotkey(self.Handle, 1 );
end;

procedure DebugText(sText: string);
begin
  Core.ShowRawText(Core.ciDebugPageID, sText);
end;

procedure TForm1.TrayPopUpMenuClick(Sender: TObject);
// Обработчик меню иконки в трее
var
  m: TMenuItem;
begin
  if Sender is TMenuItem then m:=(Sender as TMenuItem) else Exit;

  if m = mExit then
  begin // Пункт меню "Выход"
    btnExit.Click;
  end;

  if m = mActive then
  begin // Пункт меню "Я дома"
    //ClientsManager.SendMsgToAll('/AWAY');
    //btnActive.Click;
    //btnActive.Down:=true;
    //btnPassive.Down:=not btnActive.Down;
    //m.Checked:=true;
    //mPassive.Checked:=false;
  end;

  if m = mNoPrivates then
  begin // Пункт меню "Нафиг приваты"
    m.Checked := not m.Checked;
    MainConf.SetBool('IgnorePrivates', m.Checked);
  end;

  if m = mPassive then
  begin // Пункт меню "Нет меня"
    //btnPassive.Click;
    //btnActive.Down:=false;
    //btnPassive.Down:=not btnActive.Down;
    //m.Checked:=true;
    //mActive.Checked:=false;
  end;

  if m = mHideChatWindow then
  begin // Пункт меню "Скрыть/показать окно чата"
    ShowHideChatClick(Sender);
  end;

  if m = mShowConfigWindow then
  begin // Пункт меню настроек
    Core.ShowOptions();
  end;

  if m = mNotifyPrivates then
  begin
    m.Checked := not m.Checked;
    MainConf.SetBool('NotifyPrivates', m.Checked);
  end;

  if m = mNotifyAllMessages then
  begin
    m.Checked := not m.Checked;
    MainConf.SetBool('NotifyAllMsg', m.Checked);
  end;
end;

procedure TForm1.TrayPopUpPopup(Sender: TObject);
begin
  mNotifyPrivates.Checked := MainConf.GetBool('NotifyPrivates');
  mNotifyAllMessages.Checked := MainConf.GetBool('NotifyAllMsg');
end;

procedure TForm1.TabsPopupPopup(Sender: TObject);
var
  i: integer;
  tmpMenuitem: TMenuItem;
  NewItems: TObjectList;
  ChatClient: TChatClient;
begin
  with TabsPopup do
  begin
    while Items.Count > ciTabMenuBaseCount do
    begin
      Items[Items.Count-1].Free;
      //Items.Delete(Items.Count-1);
    end;
    Items[Items.Count-1].Visible:=False;
  end;

  if not ClientsManager.GetClientByPageID(PagesManager.GetActivePage.PageID, ChatClient) then Exit;
  NewItems:=ChatClient.GetTabMenuItems(PagesManager.GetActivePage.PageID);
  if not Assigned(NewItems) then Exit;

  TabsPopup.Items[TabsPopup.Items.Count-1].Visible:=True;
  for i:=0 to NewItems.Count-1 do
  begin
    tmpMenuItem:=(NewItems[i] as TMenuItem);
    //tmpMenuItem.Caption:=Form1.PageControl1.Pages[i].Caption;
    tmpMenuItem.tag:=i+1;
    //tmpMenuItem.Checked:=Form1.PageControl1.Pages[i].TabVisible;
    tmpMenuItem.OnClick:=TabsPopupMenuClick;
    TabsPopup.Items.Add(tmpMenuItem);
  end;
  NewItems.OwnsObjects:=False;
  NewItems.Free();
end;

procedure TForm1.TabsPopupMenuClick(Sender: TObject);
// Обработчик контекстного меню закладок
var
  m: TMenuItem;
  i: integer;
  DoRemove: boolean;
  NewForm: TForm;
  Page: TChatPage;
  ChatClient: TChatClient;
begin
  if Sender is TMenuItem then m:=(Sender as TMenuItem) else Exit;
  i := m.GetParentMenu.Tag;
  if not Assigned(PagesManager) then Exit;
  Page:=PagesManager.GetPage(i);
  if not Assigned(Page) then Exit;

  if m = mCloseTab then
  begin // Пункт меню "Закрыть"
    DoRemove:=false;
    if Core.ClientsManager.GetClientByPageID(Page.PageID, ChatClient) then
    begin
      DoRemove:=ChatClient.ClosePage(Page.PageID);
    end;

    if DoRemove then PagesManager.RemovePage(i)
    else Core.PagesManager.SetPageVisible(Page.PageID, false);
    Exit;
  end;

  if m = mHideTab then
  begin // Пункт меню "Спрятать"
    Core.PagesManager.SetPageVisible(Page.PageID, false);
    //Page.TabSheet.TabVisible:=False;
  end;

  if m = mDetachTab then
  begin // Пункт меню "Отсоединить"
    with Page do
    begin
      NewForm := TForm.Create(Form1);
      NewForm.Height := Frame.Height+16;
      NewForm.Width := Frame.Width+4;
      NewForm.OnClose := Form1.SeparateFormClose;
      NewForm.OnActivate := Form1.SeparateFormActivate;
      NewForm.Caption := Caption+' '+PageInfo.Caption;
      if Page.PageInfo.sNick<>'' then
      begin
        //NewForm.Caption := Caption+' '+PageInfo.sNick;
        if (Frame is TChatFrame) then TChatFrame(Frame).RightPanel.Width:=0;
        NewForm.Height := 300;
        NewForm.Width := 400;
      end
      else if Page.PageInfo.sChan<>'' then
      begin
        //NewForm.Caption := Caption+' '+PageInfo.sChan;
        NewForm.Height := 300;
        NewForm.Width := 500;
      end
      else
      begin
        //NewForm.Caption := Caption+' '+PageInfo.sServer;
        NewForm.Height := 200;
        NewForm.Width := 400;
      end;
      NewForm.Tag := PageInfo.ID;
      NewForm.ScreenSnap := true;
      Frame.Parent := NewForm;
      Core.olPrivWndList.Add(NewForm);
      NewForm.Show();
      TabSheet.TabVisible:=false;
    end;
  end;

  if m.Tag > 0 then
  begin // Дополнительные пункты
    Say(m.Hint);
  end;

  if m = mRejoinTab then
  begin // Пункт меню "Зайти снова"
    Say('/HOP');
  end;

end;

procedure TForm1.OnTimer(Sender: TObject);
begin
  if (Sender = Timer1) then On1sTimer();
  if (Sender = Timer2) then On100msTimer();
end;

procedure TForm1.PageControlPopupPopup(Sender: TObject);
var
  i: integer;
  tmpMenuitem: TMenuItem;
begin
  with PageControlPopup do
  begin
    while Items.Count > 3 do
    begin
      Items[Items.Count-1].Free;
      //Items.Delete(Items.Count-1);
    end;

    for i:=0 to Form1.PageControl1.PageCount-1 do
    begin
      tmpMenuItem:=TMenuItem.Create(Self);
      tmpMenuItem.Caption:=Form1.PageControl1.Pages[i].Caption;
      tmpMenuItem.tag:=i+1;
      tmpMenuItem.Checked:=Form1.PageControl1.Pages[i].TabVisible;
      tmpMenuItem.OnClick:=PageControlPopupClick;
      Items.Add(tmpMenuItem);
    end;
  end;
end;

procedure TForm1.PageControlPopupClick(Sender: TObject);
// Обработчик меню контроля закладок
var
  m: TMenuItem;
  i: integer;
begin
  if Sender is TMenuItem then m:=(Sender as TMenuItem) else Exit;
  if not Assigned(PagesManager) then Exit;

  if m = mShowAllTabs then
  begin // Пункт меню "Показать все"
    for i:=0 to PageControl1.PageCount-1 do
    begin
      //PageControl1.Pages[i].TabVisible:=True;
      Core.PagesManager.SetPageVisible(PageControl1.Pages[i].Tag, true);
    end;
  end;

  if m = mHideAllTabs then
  begin // Пункт меню "Спрятать все"
    for i:=PageControl1.PageCount-1 downto 0 do
    begin
      //PageControl1.Pages[i].TabVisible:=False;
      Core.PagesManager.SetPageVisible(PageControl1.Pages[i].Tag, false);
    end;
  end;

  if m.Tag > 0 then
  begin
    //PageControl1.Pages[m.Tag-1].TabVisible := not m.Checked;
    Core.PagesManager.SetPageVisible(PageControl1.Pages[m.Tag-1].Tag, (not m.Checked));
  end;
end;

procedure TForm1.MainPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbRight then
    PageControlPopup.Popup(Left+X,Top+Y+5);
end;

procedure TForm1.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  DebugText(sInfoProgramError+' '+E.Message);
end;

procedure TForm1.HTTPGet1DoneFile(Sender: TObject; FileName: String;
  FileSize: Integer);
begin
  //ParseIRCText(Format(sAvatarLoaded, [FileName, IntToStr(FileSize)]), ReturnChanIndex(csDebugTabName));
  DisableTimer(TC_HTTPGet_Timeout);
  HTTPGet1.URL:='';
end;

procedure TForm1.HTTPGet1Error(Sender: TObject);
begin
  //ParseIRCText(sAvatarLoadError+' '+HTTPGet1.URL, ReturnChanIndex(csDebugTabName));
  DisableTimer(TC_HTTPGet_Timeout);
  HTTPGet1.URL:='';
end;

procedure TForm1.HTTPGet1Progress(Sender: TObject; TotalSize,
  Readed: Integer);
begin
  //ParseIRCText('Загрузка аватара - ('+IntToStr(Readed)+'/'+IntToStr(TotalSize)+')', ReturnChanIndex(csDebugTabName));
  ResetTimer(TC_HTTPGet_Timeout);
end;

procedure LogMessage(Text, PageName, ServerName: string);
var
  LogFile: TStream;
  LogFileName: String;
  s: string;
  OpenMode: Word;
begin
  if not Assigned(MainConf) then Exit;
  if not MainConf.GetBool('LogMessages') then Exit;
  if Copy(PageName,1,1)='>' then Exit;
  if ServerName='' then ServerName:=MainConf['strHost'];
  s:=glUserPath+MainConf['LogsPath']+'\'+ServerName;
  if (not DirectoryExists(s)) then
    if (not CreateDir(s)) then Exit;
  s:=s+'\'+ServerName;
  if (not DirectoryExists(s)) then
    if (not CreateDir(s)) then Exit;
  LogFileName:=s+'\'+PageName+'.log';
  OpenMode:=fmOpenReadWrite;
  if (not FileExists(LogFileName)) then OpenMode:=fmCreate;
  LogFile:=TFileStream.Create(LogFileName, OpenMode, fmShareDenyWrite);
  LogFile.Seek(0, soFromEnd);
  s:=Text+#13+#10;
  LogFile.WriteBuffer(Pointer(s)^, Length(s));
  LogFile.Free;
end;

procedure TForm1.RegisterHotkeyString(HotkeyStr: string);
var
  s, s2: string;
  i: integer;
  ModState, Key: Word;
begin
  if Trim(HotkeyStr)='' then Exit;
  ModState:=0;
  s:=HotkeyStr;
  i:=Pos('+', s);
  while i>0 do
  begin
    s2:=Copy(s, 1, i-1);
    if s2='Shift' then ModState := (ModState or MOD_SHIFT)
    else if s2='Alt' then ModState := (ModState or MOD_ALT)
    else if s2='Ctrl' then ModState := (ModState or MOD_CONTROL);
    s:=Copy(s, i+1, maxint);
    i:=Pos('+', s);
  end;
  Key:=StrToIntDef(s, 0);

  if not RegisterHotkey(Handle, 1, ModState, Key) then
  begin
    //ShowMessage('Невозможно зарегистрировать хоткей! Запущена еще одна копия?');
  end;
end;

//------------------------
procedure OnProgramStart();
var
  PageInfo: TPageInfo;
begin
  MainForm:=Form1;

  glHomePath:=ExtractFilePath(ParamStr(0));
  // Autodetect portable mode
  if FileExists(glHomePath+'\MainConf.ini') then
  begin
    glUserPath:=IncludeTrailingPathDelimiter(glHomePath);
  end
  else
  begin
    glUserPath:=GetEnvironmentVariable('APPDATA')+'\RealChat\';
    if (not DirectoryExists(glUserPath)) then
      if (not CreateDir(glUserPath)) then
      begin
        glUserPath:=glHomePath;
      end;
  end;

  // Создаем динамические обьекты (Create dynamic objects)
  slLastTyped:=TLastTypedList.Create; // последние набранные команды
  Core.olPrivWndList:=TObjectList.Create(true);   // список окон приватов
  Core.olThreadsList:=TObjectList.Create(true);   // список потоков
  //LangIni:=TMemIniFile.Create(glHomePath+'language.ini'); // Языковые данные
  // DCC
  DCC.DCCFiles:=TDCCFiles.Create;         // Создаем список файлов DCC
  DCC.SockMan:=TSockManager.Create(true);

  MainConf:=TMainConfig.Create;       // Разворачиваем конфиг
  MainConf.FileName:=glUserPath+'\MainConf.ini';
  MainConf.Load();
  MainConf.RefreshItemsList();

  PagesManager:=TPagesManager.Create();      // Диспетчер страниц
  ClientsManager:=TClientsManager.Create();  // Диспетчер клиентов

  // Добавляем страницу клиентов
  Core.ClearPageInfo(PageInfo);
  PageInfo.Caption:=csDebugTabName;
  PageInfo.ImageIndex:=0;
  PageInfo.ImageIndexDefault:=0;
  PageInfo.PageType:=ciClientsPageType;
  PageInfo.Visible:=MainConf.GetBool('ServerPageVisible');
  ciDebugPageID:=PagesManager.CreatePage(PageInfo);
  //Core.DebugMessage('Status page added..');
  PagesManager.ActivePageID:=ciDebugPageID;

  // Добавляем страницу информации
  Core.ClearPageInfo(PageInfo);
  PageInfo.Caption:=csInfoTabName;
  PageInfo.ImageIndex:=0;
  PageInfo.ImageIndexDefault:=0;
  PageInfo.PageType:=ciInfoPageType;
  PageInfo.Visible:=MainConf.GetBool('InfoPageVisible');
  ciInfoPageID:=PagesManager.CreatePage(PageInfo);
  //Core.DebugMessage('Info page added..');
  //PagesManager.SetActivePage(ciInfoPageID);

  // Добавляем доску объявлений
  Core.ClearPageInfo(PageInfo);
  PageInfo.Caption:=csNotesTabName;
  PageInfo.ImageIndex:=3;
  PageInfo.ImageIndexDefault:=3;
  PageInfo.PageType:=ciChatPageType;
  PageInfo.Visible:=MainConf.GetBool('NotesPageVisible');
  ciNotesPageID:=PagesManager.CreatePage(PageInfo);
  //Core.DebugMessage('Notes page added..');

  // Добавляем страницу файлов
  Core.ClearPageInfo(PageInfo);
  PageInfo.Caption:=csFilesTabName;
  PageInfo.ImageIndex:=4;
  PageInfo.ImageIndexDefault:=4;
  PageInfo.PageType:=ciFilesPageType;
  PageInfo.Visible:=MainConf.GetBool('FilesPageVisible');
  ciFilesPageID:=PagesManager.CreatePage(PageInfo);
  //Core.DebugMessage('Files page added..');

  //Form1.PageControl1.ActivePageIndex:=0;

  Core.MainForm.RegisterHotkeyString(MainConf['Hotkey']);

  // Загрузка языка для интерфейса
  //LoadLanguage(glHomePath+'\language.ini');
  // Init plugins
  PluginsManager:=TPluginsManager.Create();
  PluginsManager.Start();

end;

procedure OnProgramStop();
begin
  Core.CoreStop();

  FreeAndNil(PluginsManager);

  FreeAndNil(ClientsManager);
  FreeAndNil(PagesManager);
  FreeAndNil(MainConf);

  FreeAndNil(DCC.SockMan);
  FreeAndNil(DCC.DCCFiles);
  if Assigned(LangIni) then FreeAndNil(LangIni);
  FreeAndNil(Core.olThreadsList);
  FreeAndNil(Core.olPrivWndList);
  FreeAndNil(slLastTyped);
end;

function GetRealTabIndex(PageControl: TPageControl; X, Y: integer): integer;
var
  k, n, m: integer;
begin
  k:=PageControl.IndexOfTabAt(X, Y); // номер видимой закладки
  n:=-1;
  m:=-1;
  while m<k do
  begin
    Inc(n);
    if PageControl.Pages[n].TabVisible then Inc(m);
  end;
  result:=n;
end;

procedure TForm1.SeparateFormActivate(Sender: TObject);
begin
  if not Assigned(PagesManager) then Exit;
  Core.PagesManager.ActivePageID:=TForm(Sender).Tag;
end;

procedure TForm1.DownloadAvatar(UserNick, AvatarURL: string);
var
  FileExt, AvatarPath: string;
  i: integer;
begin
{$IFDEF AVATARS}
  if not MainConf.GetBool('UseAvatars') then Exit;
  if HTTPGet1.URL<>'' then Exit; // уже качаем
  FileExt:='';
  for i:=Length(AvatarURL) downto 1 do
  begin
    if AvatarURL[i]='.' then Break;
    Insert(AvatarURL[i], FileExt, 1);
    //FileExt:=FileExt+AvatarURL[i];
  end;
  if Length(FileExt)<>3 then FileExt:='gif';
  AvatarPath:=IncludeTrailingPathDelimiter(glUserPath+MainConf['AvatarsPath']);
  if not DirectoryExists(AvatarPath) then CreateDir(AvatarPath);
  HTTPGet1.URL:=AvatarURL;
  HTTPGet1.FileName:=AvatarPath+UserNick+'.'+FileExt;
  ParseIRCTextByPageID(-1, Format(sAvatarLoading, [HTTPGet1.URL, UserNick]));
  //ParseIRCText('в файл '+HTTPGet1.FileName, ReturnChanIndex(csDebugTabName));
  HTTPGet1.GetFile();
  { В исходниках HTTPGet нужно в InternetOpen() исправить флаг типа запроса на INTERNET_OPEN_TYPE_DIRECT
    иначе на некоторых компах могут быть проблемы.
  }
{$ENDIF}
end;

procedure TForm1.ApplicationEvents1ShowHint(var HintStr: String;
 var CanShow: Boolean; var HintInfo: THintInfo);

var
  k, i: integer;
  pi: TPageInfo;
  p, p2: TPoint;
begin
  if (HintStr = PageControl1.Hint) then
  begin
    GetCursorPos(p);
    p2:= PageControl1.ScreenToClient(p);
    k:=GetRealTabIndex(PageControl1, p2.X, p2.Y); // реальный номер видимой закладки
    if k<0 then
    begin
      CanShow:=false;
      HintStr:='';
      Exit;
    end;
    i:=PageControl1.Pages[k].Tag;
    if not Assigned(PagesManager) then Exit;
    if not PagesManager.GetPageInfo(i, pi) then Exit;
    HintStr:=pi.Hint;
    //if PageControl1.Hint='' then PageControl1.Hint:=PageControl1.Pages[k].Caption;
  end;
end;

procedure TForm1.LoadLanguage();

function GetStr(Name: string; s: string): string;
begin
  result:=Core.LangIni.ReadString('Main', Name, s);
end;

begin
  if not Assigned(Core.LangIni) then Exit;
  try
    sAvatarLoading:=GetStr('sAvatarLoading', sAvatarLoading);
    sAvatarLoaded:=GetStr('sAvatarLoaded', sAvatarLoaded);
    sAvatarLoadError:=GetStr('sAvatarLoadError', sAvatarLoadError);
    sTrayPopupShowChatWnd:=GetStr('sTrayPopupShowChatWnd', sTrayPopupShowChatWnd);
    sTrayPopupHideChatWnd:=GetStr('sTrayPopupHideChatWnd', sTrayPopupHideChatWnd);
    sBtnConnOn:=GetStr('sBtnConnOn', sBtnConnOn);
    sBtnConnOff:=GetStr('sBtnConnOff', sBtnConnOff);
    sInfoDisconnected:=GetStr('sInfoDisconnected', sInfoDisconnected);
    sInfoCannotClose:=GetStr('sInfoCannotClose', sInfoCannotClose);
    sInfoUncnownCommand:=GetStr('sInfoUncnownCommand', sInfoUncnownCommand);
    sInfoNotConnected:=GetStr('sInfoNotConnected', sInfoNotConnected);
    sInfoProgramError:=GetStr('sInfoProgramError', sInfoProgramError);
    sInfoClientForPageNotFound:=GetStr('sInfoClientForPageNotFound', sInfoClientForPageNotFound);

    // Header
    imgMinBtn.Hint:=GetStr('imgMinBtn.Hint', imgMinBtn.Hint);
    imgOnTopBtn.Hint:=GetStr('imgOnTopBtn.Hint', imgOnTopBtn.Hint);
    // Main buttons hints
    btnAbout.Hint:=GetStr('btnAbout.Hint', btnAbout.Hint);
    btnActive.Hint:=GetStr('btnActive.Hint', btnActive.Hint);
    btnChannels.Hint:=GetStr('btnChannels.Hint', btnChannels.Hint);
    btnClear.Hint:=GetStr('btnClear.Hint', btnClear.Hint);
    btnExit.Hint:=GetStr('btnExit.Hint', btnExit.Hint);
    btnMemo.Hint:=GetStr('btnMemo.Hint', btnMemo.Hint);
    btnPassive.Hint:=GetStr('btnPassive.Hint', btnPassive.Hint);
    btnRefresh.Hint:=GetStr('btnRefresh.Hint', btnRefresh.Hint);
    btnSettings.Hint:=GetStr('btnSettings.Hint', btnSettings.Hint);
    btnSmiles.Hint:=GetStr('btnSmiles.Hint', btnSmiles.Hint);
    // Page control popup menu
    mShowAllTabs.Caption:=GetStr('mShowAllTabs.Caption', mShowAllTabs.Caption);
    mHideAllTabs.Caption:=GetStr('mHideAllTabs.Caption', mHideAllTabs.Caption);
    // Tabs popup menu
    mCloseTab.Caption:=GetStr('mCloseTab.Caption', mCloseTab.Caption);
    mDetachTab.Caption:=GetStr('mDetachTab.Caption', mDetachTab.Caption);
    mHideTab.Caption:=GetStr('mHideTab.Caption', mHideTab.Caption);
    mRefreshTab.Caption:=GetStr('mRefreshTab.Caption', mRefreshTab.Caption);
    mRejoinTab.Caption:=GetStr('mRejoinTab.Caption', mRejoinTab.Caption);
    // Tray icon popup menu
    mHideChatWindow.Caption:=GetStr('mHideChatWindow.Caption', mHideChatWindow.Caption);
    mStatusMenu.Caption:=GetStr('mStatusMenu.Caption', mStatusMenu.Caption);
    mOptionsMenu.Caption:=GetStr('mOptionsMenu.Caption', mOptionsMenu.Caption);
    mExit.Caption:=GetStr('mExit.Caption', mExit.Caption);
    mActive.Caption:=GetStr('mActive.Caption', mActive.Caption);
    mNoPrivates.Caption:=GetStr('mNoPrivates.Caption', mNoPrivates.Caption);
    mPassive.Caption:=GetStr('mPassive.Caption', mPassive.Caption);
    mShowConfigWindow.Caption:=GetStr('mShowConfigWindow.Caption', mShowConfigWindow.Caption);
    mNotifyPrivates.Caption:=GetStr('mNotifyPrivates.Caption', mNotifyPrivates.Caption);
    mNotifyAllMessages.Caption:=GetStr('mNotifyAllMessages.Caption', mNotifyAllMessages.Caption);
    mEnableMsgFilter.Caption:=GetStr('mEnableMsgFilter.Caption', mEnableMsgFilter.Caption);

    //.Caption:=GetStr('.Caption', .Caption);
    //:=GetStr('', );
  finally
  end;
end;


initialization

end.
