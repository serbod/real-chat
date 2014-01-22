{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  TChatFrame - страница чата. Содержит основное поле чата, список юзеров, панель
  кнопок, поле ввода текста и (опционально) панель с аватаром.

  TODO: избавиться от Main (например, Main.ParseIRCTextToRV )
}
//{$DEFINE AVATARS}
unit ChatPage;

interface

uses StdCtrls, ComCtrls, ExtCtrls, Main, RVScroll, RichView, RVStyle, CRVFData,
 Classes, Controls, Forms, Graphics, Smiles, Types, Windows,
 SysUtils, Misc, ShellAPI, AdvPicture, ToolWin, Menus, ActnPopupCtrl,
 Dialogs, ImgList, RVTable, Core, Contnrs, ActnList;

type
  TChatFrame = class(TFrame)
    MesText:    TRichView;
    UserList:   TTreeView;
    SplitterV:  TSplitter;
    SplitterH:  TSplitter;
    RightPanel: TPanel;
    LeftPanel:  TPanel;
    MessPanel:  TPanel;
    TxtToolBar: TToolBar;
    TxtToSend:  TMemo;
    btnSmiles: TToolButton;
    btnColor: TToolButton;
    tbtnSeparator1: TToolButton;
    btnUnderline: TToolButton;
    btnItalic: TToolButton;
    btnBold: TToolButton;
{$IFDEF AVATARS}
    AvatarSplitter: TSplitter;
    AvatarPanel: TPanel;
{$ENDIF}
    TextWindowPopUp: TPopupMenu;
    mCtrlC: TMenuItem;
    mFreezeScrolling: TMenuItem;
    mHScroll: TMenuItem;
    UserListContextMenu: TPopupMenu;
    mInsertName: TMenuItem;
    mInsertPrivate: TMenuItem;
    mPrivateAll: TMenuItem;
    mPrivateWith: TMenuItem;
    mInfoAboutUser: TMenuItem;
    N4: TMenuItem;
    mSendFile: TMenuItem;
    mCreateLine: TMenuItem;
    mRefreshUserList: TMenuItem;
    N6: TMenuItem;
    mIgnorePersonal: TMenuItem;
    mIgnoreAll: TMenuItem;
    mIgnoreForTime: TMenuItem;
    N8: TMenuItem;
    mTemplates: TMenuItem;
    mActionsSubmenu: TMenuItem;
    mCreateUsersGroup: TMenuItem;
    mDeleteUsersGroup: TMenuItem;
    mRenameUsersGroup: TMenuItem;
    mDefineUserColor: TMenuItem;
    AvatarPopup: TPopupMenu;
    mGetAvatarFromFile: TMenuItem;
    mGetAvatarFromURL: TMenuItem;
    mCheckCurrentUserAvatar: TMenuItem;
    mCheckAllUsersAvatar: TMenuItem;
    tbtnSeparator2: TToolButton;
    btnClearText: TToolButton;
    btnFreezeScrolling: TToolButton;
    actlstChatFrame: TActionList;
    actCopy: TAction;
    actFreezeScrolling: TAction;
    actHScroll: TAction;
    actBold: TAction;
    actItalic: TAction;
    actUnderline: TAction;
    actColor: TAction;
    actSmiles: TAction;
    actClearText: TAction;
    actTranslit: TAction;
    btnTranslit: TToolButton;
    procedure TextWindowPopUpPopup(Sender: TObject);
    procedure UserListPopupClick(Sender: TObject);
    procedure mInsertNameClick(Sender: TObject);
    procedure UserListContext(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure mTemplatesClick(Sender: TObject);
    procedure AvatarPopupClick(Sender: TObject);
    procedure actlstChatFrameExecute(Action: TBasicAction;
      var Handled: Boolean);
    procedure actDummyExecute(Sender: TObject);
    procedure TxtToSendKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    //slUserList: TStringList;
    CheckChanged: boolean; // признак смены пометки напротив ника пользователя
    DragNode: TTreeNode;
    procedure CopyRusChar(Sender: TObject);
    procedure SendMultiPrivate(sText: string);
    procedure LoadLanguage();
    procedure OnActivateHandler(Sender: TObject);
    procedure OnDeactivateHandler(Sender: TObject);
    procedure OnUpdateStyleHandler(Sender: TObject);
    procedure OnClearHandler(Sender: TObject);
    procedure OnCompareHandler(Sender: TObject; Node1, Node2: TTreeNode; Data: Integer; var Compare: Integer);
  public
    { Public declarations }
    Page: TChatPage;
    TranslitMode: Boolean;
{$IFDEF AVATARS}
    AvatarUser: String;
    AvatarPicture: TAdvPicture;
    procedure UserListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure AvatarPictureContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure CheckAvatar(CheckAll:boolean=true);
{$ENDIF}
    constructor Create(APage: TChatPage); reintroduce;
    procedure DownKeySend(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure InsertPrivate();
    procedure CopyOnSelect(Sender: TObject);
    procedure onHLink(Sender: TObject; id: Integer);
    procedure ShowMemo(i: integer);
    //procedure ShowMemoDown(snd: integer; i: integer);
    procedure EditInsertSymbol(CSymbol: Char);
    procedure UserListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure UserListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure UserListDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure UserListClick(Sender: TObject);
    procedure UserListDblClick(Sender: TObject);
    procedure ToggleVScrollStop();
    procedure SetNewFont();
    procedure ShowTable(InfoList: TInfoList);
    procedure AddNote(sUserName, sNoteText: string);
    procedure ClearMesText();
    procedure InsertText(InsText: string);
    procedure AddNick(sNick: String; ImgIndex: integer = -1; Color: integer = 0);
    procedure AddNicks(sNickList: String; ImgIndex: integer = -1; Color: integer = 0;
              ClearList: boolean = false);
    function ChangeNick(sNick, sNewNick: string; ImgIndex: integer = -1; Color: integer = 0): boolean;
    procedure RemoveNick(sNick: string; RemoveAll: boolean = false);
    procedure SetUserlistStyle(sStyle: string);
    procedure CycleUserNamesByFirstLetters();
  end;

  {TNickList = class(TObjectList)
  public
    procedure AddNick(sNick: String; ImgIndex: integer = 0; Color: integer = 0);
    procedure AddNicks(sNickList: String; ImgIndex: integer = 0; Color: integer = 0;
     ClearList: boolean = false);
    function ChangeNick(sNick, sNewNick: string; ImgIndex: integer = -1): boolean;
    procedure RemoveNick(sNick: string; RemoveAll: boolean = false);
  end; }

  procedure AddMemoCmd(sMemo :String);


var
  sUserListIns:string = 'Вставить "%s" в мессагу';
  sUserListMsg:string = 'Мессага для %s';
  sUserListPvt:string = 'Приват с %s';
  sUserListInf:string = 'Инфа о %s';
  sUserListIgP:string = 'Игнорить личку от %s';
  sUserListIgA:string = 'Игнорить все мессаги от %s';

  sDlgAddGroupCaption:string = 'Название группы';
  sDlgAddGroupText:string = 'Группа';

implementation
{$R *.dfm}

uses EnterCmd;

///////////////////////////////////////////////////////////////////////////////
//  Методы фрейма чата
///////////////////////////////////////////////////////////////////////////////
constructor TChatFrame.Create(APage: TChatPage);
begin
  inherited Create(APage.TabSheet);
  //self.Parent:=TWinControl(APage.TabSheet);
  self.Page:=APage;
  APage.OnActivate:=OnActivateHandler;
  APage.OnDeactivate:=OnDeactivateHandler;
  APage.OnUpdateStyle:=OnUpdateStyleHandler;
  APage.OnClear:=OnClearHandler;
  self.Align:=alClient;
  self.DoubleBuffered:=true;

  {//RightPanel := TPanel.Create(Self);
  with RightPanel do
  begin
    Parent := Self;
    Width := 150;
    Align := alRight;
    BorderStyle := bsNone;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    DoubleBuffered:=true;
  end;}
  RightPanel.DoubleBuffered:=True;

  //UserList := TTreeView.Create(Self); // Список юзеров
  with UserList do
  begin
    Parent := RightPanel;
    Align := alClient;
    //Width := 150;
    //Images := Core.MainForm.UserListImages;
    //StateImages := Core.MainForm.UserListImages;
    Images := Core.MainForm.ImageList16;
    StateImages := Core.MainForm.ImageList16;
    ReadOnly := True;
    HotTrack:=true;
    SortType := stText;
    OnClick := UserListClick;
    OnDblClick := UserListDblClick;
    OnMouseDown := UserListMouseDown;
    OnDragDrop := UserListDragDrop;
    OnDragOver := UserListDragOver;
{$IFDEF AVATARS}
    OnMouseMove := UserListMouseMove;
{$ENDIF}
    //Tag := i;
    OnContextPopup := UserListContext;
    OnCompare:=OnCompareHandler;
    ShowLines:=false;
    ShowRoot:=false;
    DoubleBuffered:=true;
  end;

  {//SplitterV := TSplitter.Create(Self); // Разделитель
  with SplitterV do
  begin
    Parent := Self;
    Align := alRight;
    Width := 3;
    ResizeStyle := rsUpdate;
  end;}

  {//LeftPanel := TPanel.Create(Self);
  with LeftPanel do
  begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    DoubleBuffered:=true;
  end;}

  //MessPanel := TPanel.Create(Self);
  {with MessPanel do
  begin
    Parent := LeftPanel;
    Align := alBottom;
    Height := 48;
    BorderStyle := bsNone;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    DoubleBuffered:=true;
  end; }
  //MessPanel.DoubleBuffered:=True;

  {//TxtToolBar := TToolBar.Create(Self);
  with TxtToolBar do
  begin
    Parent := MessPanel;
    Align := alTop;
    //Align := alBottom;
    //Anchors := [akLeft,akTop,akRight,akBottom];
    //EdgeBorders := [ebTop,ebBottom];
    EdgeBorders := [];
    Height := 24;
    //Images := BottomToolBar;
    DoubleBuffered:=true;
  end;}
  TxtToolBar.DoubleBuffered:=True;

  //TxtToSend := TMemo.Create(Self);  // Поле ввода текста
  with TxtToSend do
  begin
    Parent := MessPanel;
    //Top := 28;
    Anchors := [akLeft,akTop,akRight,akBottom];
    Align := alClient;
    Font.Name := 'Tahoma';
    Font.Color := clNavy;
    //Tag := i;
    ScrollBars := ssVertical;
    WantReturns := false;
    WordWrap := false;
    OnKeyDown := DownKeySend;
  end;

  {//SplitterH := TSplitter.Create(Self); // Разделитель
  with SplitterH do
  begin
    Parent := LeftPanel;
    Align := alBottom;
    Width := 1;
    MinSize := 48;
    AutoSnap := false;
    ResizeStyle := rsUpdate;
  end; }

  //MesText := TRichView.Create(Self); // Табло чата
  with MesText do
  begin
    Parent := LeftPanel;
    Align := alClient;
    Style := Core.MainForm.MessStyle;
    BottomMargin := 2;
    LeftMargin := 2;
    RightMargin := 2;
    TopMargin := 2;
    PopupMenu := TextWindowPopUp;
    AnimationMode := rvaniOnFormat;
    HScrollVisible:=false;
    //tag := i;
    OnSelect := CopyOnSelect;
    OnCopy := CopyRusChar;
    OnJump := OnHLink;
    Format;
  end;

{$IFDEF AVATARS}
  {//AvatarSplitter:=TSplitter.Create(RightPanel); // Разделитель окна аватара
  with AvatarSplitter do
  begin
    Parent := RightPanel;
    Align := alBottom;
    Width := 2;
  end; }

  {//AvatarPanel:=TPanel.Create(RightPanel);
  with AvatarPanel do
  begin
    Parent := RightPanel;
    Align := alBottom;
    Height := 108;
    BorderStyle := bsNone;
    BevelInner := bvLowered;
    BevelOuter := bvNone;
    DoubleBuffered:=true;
  end; }

  AvatarPicture:=TAdvPicture.Create(AvatarPanel);
  with AvatarPicture do
  begin
    Parent := AvatarPanel;
    Animate := True;
    Picture.Stretch := False;
    Picture.Frame := 0;
    PicturePosition := bpCenter;
    Align := alClient;
    OnContextPopup:=AvatarPictureContextPopup;
    //DoubleBuffered := True;
  end;
  if not MainConf.GetBool('UseAvatars') then AvatarPanel.Height:=0;
{$ENDIF}
  SetNewFont();
  LoadLanguage();
end;

///////////////////////////////////////////////////////////////////////////////
//  Загрузка и обработка аватаров
///////////////////////////////////////////////////////////////////////////////
{$IFDEF AVATARS}

{procedure AddAvatar(FileName: string);
var
  bmp: TBitmap;
  rect: TRect;
begin
  with rect do
  begin
    Left:=0;
    Top:=0;
    Right:=24;
    Bottom:=24;
  end;
  bmp:=TBitmap.Create;
  bmp.LoadFromFile(FileName);
  bmp.Canvas.StretchDraw(rect, bmp);
  bmp.Height:=24;
  bmp.Width:=24;
  Avatars24.AddMasked(bmp, $00000000);
end;}

{procedure LoadAvatars;
begin
  Avatars24 := TCustomImageList.Create(Core.MainForm);
  Avatars24.Height:=24;
  Avatars24.Width:=24;
  AddAvatar('Avatars/normal.bmp');
  AddAvatar('Avatars/op.bmp');
  AddAvatar('Avatars/voiced.bmp');
  AddAvatar('Avatars/hidden.bmp');
end;}

procedure TChatFrame.CheckAvatar(CheckAll:boolean=true);
var
  i, n, Delay: integer;
begin
  n:=0;
  Delay:=MainConf.GetInteger('AvatarQueryDelay')*1000;
  begin
    if CheckAll then
      for i:=UserList.Items.Count-1 downto 0 do
      begin
        Core.ModTimerEvent(1, self.Page.PageID, Delay*n, '/CTCP '+Norm(UserList.Items[i].Text)+' AVATAR');
        Inc(n);
      end
    else
  end;
end;

procedure TChatFrame.UserListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
  AvatarName, AvatarsPath, FileName: string;
  ExtStr, str1: string;
  i: integer;
  FileFound: boolean;
begin
  if not MainConf.GetBool('UseAvatars') then Exit;
  if AvatarPanel.Height<=AvatarSplitter.MinSize then Exit;
  Node:=UserList.GetNodeAt(X,Y);
  if Node=nil then Exit;
  if AvatarUser<>Node.Text then AvatarUser:=Node.Text else Exit;
  // Показ аватара
  ExtStr:='gif,jpg,bmp,';
  AvatarName:=Node.Text+'.gif';
  AvatarsPath:=IncludeTrailingPathDelimiter(glUserPath+MainConf['AvatarsPath']);
  FileFound:=false;
  while (Length(ExtStr)>0) and (not FileFound) do
  begin
    i:=pos(',', ExtStr);
    str1:=copy(ExtStr, 1, i-1);
    Delete(ExtStr, 1, i);
    AvatarName:=AvatarUser+'.'+str1;
    FileFound:=FileExists(AvatarsPath+AvatarName);
  end;
  if not FileFound then
  begin
    AvatarName:='default.gif';
    case Node.ImageIndex of
      ciIconNormal: AvatarName:='normal.bmp';
      ciIconOper:   AvatarName:='op.bmp';
      ciIconHidden: AvatarName:='hidden.bmp';
      ciIconVoiced: AvatarName:='voiced.bmp';
    end;
    AvatarsPath:=IncludeTrailingPathDelimiter(glHomePath+MainConf['AvatarsPath']);
  end;
  if FileExists(AvatarsPath+AvatarName) then
  begin
    try
      AvatarPicture.Picture.LoadFromFile(AvatarsPath+AvatarName);
    except
    End;
  end;
  AvatarPanel.Repaint;
end;

procedure TChatFrame.AvatarPictureContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  AvatarPopup.Popup(AvatarPicture.ClientOrigin.X+MousePos.X+5, AvatarPicture.ClientOrigin.Y+MousePos.Y+5);
end;
{$ENDIF}

procedure TChatFrame.SendMultiPrivate(sText: string);
// рассылка приватов помеченым никам
var i: integer;
begin
  if (not Page.PageInfo.bUseStateImages) then Exit;
  for i:=0 to UserList.Items.Count-1 do
  begin
    if UserList.Items[i].StateIndex = ciCheckedIndex then
      Say('/MSG '+Norm(UserList.Items[i].Text)+' '+sText, Page.PageID);
  end;
end;

procedure AddMemoCmd(sMemo :String);
begin
  with (slLastTyped) do
  begin
    if Count>0 then
      if Trim(sMemo)=Trim(Strings[Count-1]) then Exit;
    Add(sMemo);
    if Count > 20 then Delete(0);
    Current := Count;
  end;
end;

procedure TChatFrame.CycleUserNamesByFirstLetters();
var
  s, sName, curInput: string;
  i, SelStart, NameStartPos: Integer;
begin
  SelStart := TxtToSend.SelStart;
  curInput := TxtToSend.Text;
  s:='';
  NameStartPos:=1;
  // Get current entered word
  for i := SelStart downto 1 do
  begin
    if curInput[i]=' ' then
    begin
      NameStartPos:=i+1;
      Break;
    end
    else s:=curInput[i]+s;
  end;
  if s='' then Exit;
  s:=AnsiLowerCase(s);

  // Get corresponding user name
  sName:='';
  for i:=0 to UserList.Items.Count-1 do
  begin
    sName:=UserList.Items[i].Text;
    if AnsiLowerCase(Copy(sName, 1, Length(s)))=s then
    begin
      Break;
    end;
    sName:='';
  end;

  if sName<>'' then
  begin
    Delete(curInput, NameStartPos, Length(s));
    Insert(sName, curInput, NameStartPos);
    TxtToSend.Text:=curInput;
    TxtToSend.SelStart:=NameStartPos+Length(sName);
  end;
end;

function Translit(s: string): string;
begin
  if Length(s)=0 then Exit;

  if s[1]='/' then
  begin
    Result:=s;
    Exit;
  end;
  Result:=TranslitAuto(s);
end;

procedure TChatFrame.DownKeySend(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i, n:   integer;
  snd:      String;
  Cpos:     TPoint;
  //TxtToSend :TMemo;
  SelStart  :Integer;

begin
  //i := Core.MainForm.PageControl1.ActivePageIndex;
  SelStart := TxtToSend.SelStart;
  case Key of
    VK_RETURN:    // Enter
    begin
      if TranslitMode then TxtToSend.Text:=Translit(TxtToSend.Text);

      //AddMemoCmd(TxtToSend.Text);
      if Shift = [ssAlt] then
        SendMultiPrivate(snd)
      else
      begin
        if (ssCtrl in Shift) and (not MainConf.GetBool('SendMsgOnCtrlEnter')) then Exit;
        if (not (ssCtrl in Shift)) and MainConf.GetBool('SendMsgOnCtrlEnter') then
        begin
          TxtToSend.Lines.Add('');
          Exit;
        end;
        //Core.MainForm.Say(TxtToSend.Text);
        for i:=0 to TxtToSend.Lines.Count-1 do
          Say(TxtToSend.Lines[i], Page.PageID, true);
      end;
      TxtToSend.Text := '';
    end;

    VK_TAB: // Tab
    begin
      CycleUserNamesByFirstLetters();
    end;

    VK_UP: // Ctrl-Up arrow
    begin
      if Shift = [ssCtrl] then
      begin
        if (Length(Trim(TxtToSend.Text)) > 0) And Not Added then
        begin
          AddMemoCmd(TxtToSend.Text);
          Added := true;
        end;
        ShowMemo(-1);
      end;
    end;

    VK_DOWN: // Ctrl-Down arrow
    begin
      if Shift = [ssCtrl] then
        ShowMemo(1);
    end;

    75: // Ctrl-K (выбор цвета)
    begin
      if Shift = [ssCtrl] then
      begin
        Core.ShowColors();
        TxtToSend.SetFocus;
        //ParseIRCText(IntToStr(Cpos.X) + '==' + IntToStr(Cpos.Y), 0);
      end;
    end;

    66:  // Ctrl-B  (bold)
    begin
      if Shift = [ssCtrl] then
      //if ((GetKeyState(VK_CONTROL) And 128)=128) then
      begin
        EditInsertSymbol(#2);
      end;
    end;

    73:   // Ctrl-I  (italic)
    begin
      if Shift = [ssCtrl] then
      begin
        EditInsertSymbol(#22);
      end;
    end;

    85:  // Ctrl-U  (underlined)
    begin
      if Shift = [ssCtrl] then
      begin
        EditInsertSymbol(#31);
      end;
    end;

    VK_F11: //122 = F11  (input translit)
    begin
      snd := Trim(TxtToSend.Text);
      if Pos('/', snd) = 1 then
      begin
        n := TailPos(snd, ' ', Pos(' ', snd) + 1);
        if n = 0 then  n := Pos(' ', snd);
        TxtToSend.Text := Copy(snd, 1, n) + TranslitRus2Lat(Copy(snd, n+1, length(snd)-n));
      end
      else
      begin
        TxtToSend.Text := TranslitRus2Lat(snd);
      end;
      TxtToSend.SelStart := SelStart;
    end;

    else // case
    begin
      Core.HideColors();
    end;
  end;
end;

/////////////////////////////////////////////////////////
//  Работа со списком последних набранных сообщений
/////////////////////////////////////////////////////////

procedure TChatFrame.ShowMemo(i: integer);
// i - index offset from end
var
  Cur: integer;
  maxCur: integer;
begin
  begin
    begin
      Cur:=slLastTyped.Current+i;
      maxCur:=slLastTyped.Count-1;
      //if (Cur) > maxCur then Cur := maxCur;
      if (Cur) > maxCur then Exit;
      if ((Cur)<0) then Exit;
      slLastTyped.Current := Cur;
      TxtToSend.Text := slLastTyped.Strings[Cur];
      //if (i>0) and (Cur=maxCur) then slLastTyped.Current:=Cur+1;
    end;
    TxtToSend.SelStart := Length(TxtToSend.Text);
  end;
end;

procedure TChatFrame.InsertPrivate();
var
  sName: string;
begin
  with UserList do
  begin
    if Selected = nil then Exit;
    sName := Selected.Text;
  end;
  with TxtToSend do
  begin
    Text := '/msg '+Norm(sName)+' ';
    SetFocus;
    SelStart := Length(Text);
  end;
end;

procedure TChatFrame.CopyOnSelect(Sender: TObject);
begin
  if not MainConf.GetBool('CopySelected') then Exit;
  with MesText do
  begin
    if SelectionExists then
    begin
      CopyDef;
      Deselect;
      Invalidate;
    end;
  end;
end;

procedure TChatFrame.onHLink(Sender: TObject; id: Integer);
var
  RVData: TCustomRVFormattedData;
  ItemNo: integer;
  s: string;
begin
  begin
    MesText.GetJumpPointLocation(id, RVData, ItemNo);
    s := MesText.GetItemTextA(ItemNo);
    if Copy(s, 0, 7) = 'http://' then
    begin
      ShellExecute(0, nil, PChar(s), '', '', SW_NORMAL);
      Exit;
    end;
    if Copy(s, 0, 1) = '#' then
    begin
      Say('/JOIN '+s, Page.PageID);
      Exit;
    end;

    begin
      TxtToSend.SetFocus;
      TxtToSend.Text:=s+': '+TxtToSend.Text;
      TxtToSend.SelStart:=Length(TxtToSend.Text);
    end;
  end;
end;
Procedure TChatFrame.EditInsertSymbol(CSymbol: Char);
var
  iSelStart, iSelLength: Integer;
  ColorText :String;
  StartText :String;

begin
  begin
    StartText := TxtToSend.text;
    iSelStart := TxtToSend.SelStart;
    iSelLength := TxtToSend.SelLength;
    if iSelLength = 0 then
    begin
      Insert(CSymbol, StartText, iSelStart+1);
      TxtToSend.text := StartText;
      TxtToSend.SelStart := iSelStart + 1;
    end
    else
    begin
      ColorText := copy(StartText, 1, iSelStart) + CSymbol;
      ColorText := ColorText + copy(StartText, iSelStart+1, iSelLength) + CSymbol;
      ColorText := ColorText + copy(StartText, (iSelStart + iSelLength + 1), (Length(StartText) - iSelStart - iSelLength));
      Self.TxtToSend.Text := ColorText;
      TxtToSend.SelStart := iSelStart + iSelLength + 1;
    end;
  end;
end;

procedure TChatFrame.ShowTable(InfoList: TInfoList);
var table: TRVTableItemInfo;
  r,c: Integer;
begin
  with MesText do
  begin
    table := TRVTableItemInfo.CreateEx(InfoList.Count, 2, RVData);
  end;

  table.Color := clSkyBlue;
  table.BorderStyle := rvtbColor;
  table.CellBorderStyle := rvtbColor;
  table.BorderColor := $002E1234;
  table.CellBorderColor := $002E1234;

  table.BorderWidth := 0;
  table.CellBorderWidth := 1;
  table.CellPadding := 1;
  table.CellVSpacing := 0;
  table.CellHSpacing := 0;

  table.Cells[0,0].BestWidth := 120;
  table.Cells[0,0].VisibleBorders.Right := False;

  for r:=0 to InfoList.Count-1 do
  begin
    table.Cells[r,0].AddNL(' '+InfoList.Items[r].Name, 6, -1);
    table.Cells[r,1].AddNL(' '+InfoList.Items[r].Data, 0, -1);
  end;

  for r := 0 to table.Rows.Count-1 do
  begin
    for c := 1 to table.Rows[r].Count-1 do
    begin
      table.Cells[r,c].Color := $00A5CCE7;
      if c>1 then
        table.Cells[r,c].VisibleBorders.Left := False;
      if c<table.Rows[r].Count-1 then
        table.Cells[r,c].VisibleBorders.Right := False;
    end;
    if r=0 then Continue;
    table.Cells[r,1].VisibleBorders.Top := False;
    table.Cells[r,0].VisibleBorders.Right := False;
    table.Cells[r,0].VisibleBorders.Top := False;
  end;

  with MesText do
  begin
    AddNL('', 0, 0);
    AddItem('', table);
    //AddNL('', 0, 0);
    Format;
    VScrollPos := VScrollMax;
  end;

end;

//===========================
// Drag'n'drop
//===========================
procedure TChatFrame.UserListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  nn: TTreeNode;
begin
  nn:=self.UserList.GetNodeAt(X, Y);
  if (nn = nil) then Exit;
  if Button = mbRight then self.UserList.Selected := nn;
  if (Button = mbLeft) and (ssShift in Shift) then
  begin
    self.DragNode := nn;
    //self.UserList.BeginDrag(false, 2);
    self.UserList.BeginDrag(false);
    CheckChanged:=true; // Для отключения обработки OnClick
    Exit;
  end;

  if Button<>mbLeft then Exit;
  if not Page.PageInfo.bUseStateImages then Exit;
  if (X > 0) and (X < 18) then
  begin
    CheckChanged:=true;
    with nn do
    begin
      if StateIndex=ciCheckedIndex then StateIndex:=ciUncheckedIndex
      else StateIndex:=ciCheckedIndex;
    end;
  end;
end;

function CanDrop(dst, src: TObject; X, Y: integer): boolean;
//var
  //dst_node: TTreeNode;
begin
  result:=false;
  if (src is TTreeView) and (dst is TTreeView) then
  begin
    if src <> dst then Exit;
    //dst_node:=((dst as TTreeView).GetNodeAt(X, Y) as TTreeNode);
    //if dst_node = nil then Exit;
    //if dst_node.ImageIndex <> 8 then Exit;
    ////if not dst_node.IsGroup then Exit;
    result:=true;
  end;
end;

procedure TChatFrame.UserListDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  //if State = dsDragMove   then
    Accept := CanDrop(Sender, Source, X, Y);
  //Accept:=true;
end;

procedure TChatFrame.UserListDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  dst_node: TTreeNode;
  stv: TTreeView;
begin
  if CanDrop(Sender, Source, X, Y) then
  begin
    stv:=(Sender as TTreeView);
    dst_node:=stv.GetNodeAt(X,Y);
    if dst_node = nil then
    begin
      DragNode.MoveTo(stv.Items.GetFirstNode(), naAdd);
    end
    else
    begin
      if dst_node.ImageIndex = ciGroupIndex then
        DragNode.MoveTo(dst_node, naAddChild)
      else
        DragNode.MoveTo(dst_node, naInsert);
    end;
    stv.AlphaSort();
  end;
end;

procedure TChatFrame.UserListClick(Sender: TObject);
var
  dst_node: TTreeNode;
begin
  dst_node:=(Sender as TTreeView).Selected;
  if dst_node = nil then Exit;
  if dst_node.ImageIndex = ciGroupIndex then Exit;
  mInsertNameClick(Sender);
end;

procedure TChatFrame.UserListDblClick(Sender: TObject);
var
  dst_node: TTreeNode;
begin
  dst_node:=(Sender as TTreeView).Selected;
  if dst_node = nil then Exit;
  if dst_node.ImageIndex = ciGroupIndex then Exit;
  InsertPrivate();
end;

procedure TChatFrame.SetNewFont();
begin
  // установка новых шрифтов
  MesText.Reformat();
  with UserList do
  begin
    Font.Name:=MainConf['fntUserList_Name'];
    Font.Size:=StrToIntDef(MainConf['fntUserList_Size'], Font.Size);
    Repaint();
    //Name:=MainConf.fntArray[2].Name;
    //Size:=MainConf.fntArray[2].Size;
  end;
  with TxtToSend do
  begin
    Font.Name:=MainConf['fntTxtToSend_Name'];
    Font.Size:=StrToIntDef(MainConf['fntTxtToSend_Size'], Font.Size);
    Repaint();
    //Name:=MainConf.fntArray[3].Name;
    //Size:=MainConf.fntArray[3].Size;
  end;
end;

procedure TChatFrame.CopyRusChar(Sender: TObject);
begin
  MesText.CopyTextW;
 {
 RusChars.SelectAll;
 RusChars.ClearSelection;
 RusChars.Lines.Add(Clipboard.AsText);
 RusChars.SelectAll;

 RusChars.Font.Name := 'Tahoma';
 RusChars.Font.Size := 8;
 RusChars.SelAttributes.Charset := RUSSIAN_CHARSET;
 RusChars.CopyToClipboard;
 }
end;

procedure TChatFrame.TextWindowPopUpPopup(Sender: TObject);
begin
{  with MesText do
  begin
    mFreezeScrolling.Checked := not (rvoScrollToEnd in Options);
    mHScroll.Checked := HScrollVisible;
  end;}
end;

procedure TChatFrame.ToggleVScrollStop();
begin
  with MesText do
  begin
    if actFreezeScrolling.Checked then
      Options := Options-[rvoScrollToEnd]
    else
      Options := Options+[rvoScrollToEnd];

    {if (rvoScrollToEnd in Options) then
      Options := Options-[rvoScrollToEnd]
    else
      Options := Options+[rvoScrollToEnd];
    mFreezeScrolling.Checked := not (rvoScrollToEnd in Options);
    tbtnVScrollStop.Down := not (rvoScrollToEnd in Options);}
  end;
end;

procedure TChatFrame.actlstChatFrameExecute(Action: TBasicAction;
  var Handled: Boolean);
begin
  if Action = actCopy then
  begin // Копировать (Ctrl+C)
    CopyRusChar(nil);
  end

  else if Action = actFreezeScrolling then
  begin // Пункт меню "Остановить прокрутку"
    ToggleVScrollStop();
  end

  else if Action = actHScroll then
  begin // Пункт меню "Горизонтальная прокрутка"
    with MesText do
    begin
      //MaxTextWidth:= 2000;
      if actHScroll.Checked then
      begin
        //Options:=Options - [rvoClientTextWidth];
        MinTextWidth:=2000;
        HScrollVisible:=true;
      end
      else
      begin
        //Options:=Options + [rvoClientTextWidth];
        MinTextWidth:=0;
        HScrollVisible:=false;
      end;
      Format;
      //actHScroll.Checked := HScrollVisible;
    end;

  end

  else if Action = actBold then
  begin // Жирный шрифт
    EditInsertSymbol(#2);
  end

  else if Action = actItalic then
  begin // Наклонный шрифт
    EditInsertSymbol(#22);
  end

  else if Action = actUnderline then
  begin // Подчеркнутый шрифт
    EditInsertSymbol(#31);
  end

  else if Action = actSmiles then
  begin // Смайлы
    Core.ShowSmiles();
  end

  else if Action = actColor then
  begin // Выбор цвета
    Core.ShowColors();
    TxtToSend.SetFocus();
  end

  else if Action = actClearText then
  begin // Очистка окна
    ClearMesText();
  end

  else if Action = actTranslit then
  begin // Транслит
    TranslitMode:=actTranslit.Checked;
  end;

end;

///////////////////////////////////////////////////////////////////////////////
// User list context menu
///////////////////////////////////////////////////////////////////////////////
// Вставка '<имя>:'
procedure TChatFrame.mInsertNameClick(Sender: TObject);
var
  sName :String;
  PageID: integer;
begin
  if CheckChanged then
  begin
    CheckChanged:=false;
    Exit;
  end;
  if UserList.Selected = nil then Exit;
  sName := UserList.Selected.Text;

  PageID:=Page.PageID;
  if PageID=ciNotesPageID then
  begin
    with MesText do
    begin
      ScrollTo(GetCheckpointY(GetCheckpointNo(FindCheckpointByName(sName))));
    end;
    Exit;
  end;

  with TxtToSend do
  begin
    if fsBold in UserList.Font.Style then
    //if PageID=ciDebugPageID then
      Text := sName+' '
    else
      Text := sName+': '+Text;
    SetFocus;
    SelStart := Length(Text);
  end;
end;

procedure TChatFrame.UserListPopupClick(Sender: TObject);
// Обработчик меню списка юзеров
var
  m: TMenuItem;
  i: integer;
  sName: string;
  tvUserList: TTreeView;
  GroupTreeNode: TTreeNode;
begin
  if (Sender is TMenuItem) then m:=TMenuItem(Sender) else Exit;
  if (UserList.Selected = nil) then Exit;
  tvUserList:=UserList;
  sName := UserList.Selected.Text;

  if m = mIgnoreAll then
  begin // Игнор всего
    if m.Checked then
    begin
      Core.Say('/UNIGNORE ALL '+sName, Page.PageID);
    end
    else
    begin
      Core.Say('/IGNORE ALL '+sName, Page.PageID);
    end;
  end

  else if m = mInsertPrivate then
  begin // Мессага для
    // Вставка '/msg <имя>'
    InsertPrivate();
  end

  else if m = mPrivateWith then
  begin // Приват с
    Core.Say('/PRIV_LINE '+sName, Page.PageID);
  end

  else if m = mCreateLine then
  begin // Создать линию (DCC chat)
    Core.Say('/DCC CHAT '+sName, Page.PageID);
  end

  else if m = mSendFile then
  begin // Послать файл (DCC send)
    Core.Say('/DCC SEND '+sName, Page.PageID);
  end

  else if m = mRefreshUserList then
  begin // Обновить список
    if (Page.PageID <> ciDebugPageID)
    and (Page.PageID <> ciNotesPageID)
    and (Page.PageInfo.sNick = '') then
    begin
      Core.Say('/REFRESH_NAMES', Page.PageID);
    end;
  end

  else if m = mInfoAboutUser then
  begin // Инфа о
    Core.Say('/WHOIS '+sName, Page.PageID);
  end

  else if m = mCreateUsersGroup then
  begin // Создать группу
    frmEnterCmd:=TfrmEnterCmd.Create(Core.MainForm);
    frmEnterCmd.Caption:=sDlgAddGroupCaption;
    frmEnterCmd.edText.Text:=sDlgAddGroupText;
    frmEnterCmd.modal:=true;
    Core.olPrivWndList.Add(frmEnterCmd);
    if frmEnterCmd.ShowModal() <> mrOK then Exit;
    sName:=frmEnterCmd.edText.Text;
    if Trim(sName)='' then Exit;

    GroupTreeNode:=TTreeNode.Create(tvUserList.Items);
    GroupTreeNode.ImageIndex:=ciGroupIndex;
    GroupTreeNode.SelectedIndex:=GroupTreeNode.ImageIndex;
    tvUserList.Items.AddNode(GroupTreeNode, tvUserList.Selected, sName, nil, naInsert);
    // Включаем иерархию
    tvUserList.ShowLines:=true;
    tvUserList.Refresh();
  end

  else if m = mDeleteUsersGroup then
  begin // Удалить группу
    GroupTreeNode:=tvUserList.Selected;
    if GroupTreeNode.ImageIndex <> ciGroupIndex then Exit;
    // Переносим все элементы группы в корень
    for i:=GroupTreeNode.Count-1 downto 0 do
    begin
      GroupTreeNode.Item[i].MoveTo(tvUserList.Items.GetFirstNode(), naAdd);
    end;
    GroupTreeNode.Delete();
    tvUserList.AlphaSort();
  end

  else if m = mRenameUsersGroup then
  begin // Переименовать
    GroupTreeNode:=tvUserList.Selected;
    if GroupTreeNode.ImageIndex <> ciGroupIndex then Exit;

    frmEnterCmd:=TfrmEnterCmd.Create(Core.MainForm);
    frmEnterCmd.Caption:=sDlgAddGroupCaption;
    frmEnterCmd.edText.Text:=GroupTreeNode.Text;
    frmEnterCmd.modal:=true;
    Core.olPrivWndList.Add(frmEnterCmd);
    if frmEnterCmd.ShowModal() <> mrOK then Exit;
    sName:=frmEnterCmd.edText.Text;
    if Trim(sName)='' then Exit;

    GroupTreeNode.Text:=sName;
  end;

end;

procedure TChatFrame.UserListContext(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  tmpNode: TTreeNode;
  CursPos :TPoint;
  NameOfNode : String;
  s: String;
  tmpMenuItem: TMenuItem;
  tmpSubMenuItem: TMenuItem;
  i: integer;
  ItemIsGroup: boolean;
  sl: TStringList;
  ChatClient: TChatClient;
  PageID: integer;
  pi: TPageInfo;
begin
  //TabCaption:=Core.MainForm.PageControl1.ActivePage.Caption;
  //PageID:=Core.PagesManager.GetActivePage().PageID;
  PageID:=self.Page.PageID;
  pi:=self.Page.PageInfo;
  //if (fsBold in TTreeView(Sender).Font.Style) then Exit;
  if not Core.ClientsManager.GetClientByPageID(PageID, ChatClient) then Exit;

  if not ChatClient.UserListContextMenu(PageID, UserListContextMenu) then Exit;

  tmpNode := (Sender as TTreeView).GetNodeAt(MousePos.X, MousePos.Y);
  if tmpNode <> nil then
  begin
    TTreeView(Sender).Selected := tmpNode;
    // Имя юзера в пунктах меню
    NameOfNode := TTreeView(Sender).Selected.Text;
    UserListContextMenu.Items[0].Caption := Format(sUserListIns, [NameOfNode]);
    UserListContextMenu.Items[1].Caption := Format(sUserListMsg, [NameOfNode]);
    UserListContextMenu.Items[3].Caption := Format(sUserListPvt, [NameOfNode]);
    UserListContextMenu.Items[4].Caption := Format(sUserListInf, [NameOfNode]);
    UserListContextMenu.Items[10].Caption := Format(sUserListIgP, [NameOfNode]);
    UserListContextMenu.Items[11].Caption := Format(sUserListIgA, [NameOfNode]);

    // Check ignored state for nick
    sl:=TStringList.Create();
    sl.NameValueSeparator:='>';
    sl.Text:=ChatClient.GetOption('IgnoreList');
    UserListContextMenu.Items[11].Checked := not (sl.IndexOfName(NameOfNode)=-1);

    // Заполняем список шаблонов
    sl.Text:=ChatClient.GetOption('TemplatesList');
    mTemplates.Clear;
    tmpSubMenuItem:=mTemplates;
    for i:=0 to sl.Count-1 do
    begin
      s:=sl.Strings[i];
      if Pos(':menu:', Trim(s))=1 then
      begin
        tmpSubMenuItem:=TMenuItem.Create(mTemplates);
        tmpSubMenuItem.Caption:=Copy(s, 7, maxint);
        mTemplates.Add(tmpSubMenuItem);
        Continue;
      end;
      s:=StringReplace(s,'&UserNick',NameOfNode, []);
      s:=StringReplace(s,'&MyNick', ChatClient.GetOption('MyNick'), []);
      s:=StringReplace(s,'&ChanName', pi.Caption, []);
      s:=StringReplace(s,'&s', '<?>', []);
      tmpMenuItem:=TMenuItem.Create(tmpSubMenuItem);
      //tmpMenuItem.AutoHotkeys:=maManual;
      tmpMenuItem.Caption:=s;
      tmpMenuItem.Tag:=i;
      tmpMenuItem.OnClick:=mTemplatesClick;
      tmpSubMenuItem.Add(tmpMenuItem);
    end;
    sl.Free();

    // Активность пунктов меню действий над группами
    ItemIsGroup:=false;
    if tmpNode.ImageIndex = ciGroupIndex then ItemIsGroup:=true;
    mDeleteUsersGroup.Enabled:=ItemIsGroup;
    mRenameUsersGroup.Enabled:=ItemIsGroup;

    GetCursorPos(CursPos);
    UserListContextMenu.Popup(CursPos.X+10,CursPos.Y+10);
    //UserListContextMenu.Popup(MousePos.X+10,MousePos.Y+10);
  end;
end;

procedure TChatFrame.mTemplatesClick(Sender: TObject);
// Обработчик меню шаблонов
var
  m: TMenuItem;
  s: string;
begin
  if Sender is TMenuItem then m:=(Sender as TMenuItem) else Exit;

  s:=StringReplace(m.Caption,'<?>', '&s', []);
  if Pos('&s', s)>0 then
  begin
    frmEnterCmd:=TfrmEnterCmd.Create(Core.MainForm);
    frmEnterCmd.Caption:=s;
    frmEnterCmd.template:=s;
    frmEnterCmd.PageID:=Self.Page.PageID;
    Core.olPrivWndList.Add(frmEnterCmd);
    frmEnterCmd.Show;
  end
  else
    Core.Say(s, Page.PageID);
end;

procedure TChatFrame.AvatarPopupClick(Sender: TObject);
// Обработчик меню аватаров
var
  m: TMenuItem;
  //i: integer;
  od: TOpenDialog;
  DstFileName: String;
begin
  if Sender is TMenuItem then m:=(Sender as TMenuItem) else Exit;
{$IFDEF AVATARS}
  if m = mGetAvatarFromFile then
  begin // Аватар из файла
    od:=TOpenDialog.Create(Core.MainForm);
    if od.Execute then
    begin
      DstFileName:=MainConf['AvatarPath']+AvatarUser+ExtractFileExt(od.FileName);
      CopyFile(od.FileName, DstFileName);
    end;
    Exit;
  end;

  if m = mGetAvatarFromURL then
  begin // Аватар из URL
    Exit;
  end;

  if m = mCheckCurrentUserAvatar then
  begin // Обновить аватар юзера
    //Say('/MSG ');
    CheckAvatar(false);
    Exit;
  end;

  if m = mCheckAllUsersAvatar then
  begin // Обновить аватар всех юзеров
    CheckAvatar(true);
    Exit;
  end;
{$ENDIF}
end;

procedure TChatFrame.AddNote(sUserName, sNoteText: string);
var
  cn, i, k: integer;
  there: boolean;
  //p: pointer;
  //s: string;
begin
  with UserList do
  begin
    k := Items.Count-1;
    there:=false;
        for i := k downto 0 do
            if AnsiLowerCase(Items[i].Text) = AnsiLowerCase(sUserName) then there:=true;
    if not there then
    begin
      // первое сообщение от юзера
      // добавляем отправителя записки в список юзеров
      Items.Add(nil, sUserName);
      AlphaSort;
    end;
  end;
  // добавляем записку
  if there then
  begin
    // юзер уже оставлял сообщения
    {p:=FindCheckpointByName(sUserName);
    cn:=GetCheckpointNo(p);
    ScrollTo(GetCheckpointY(cn));
    i:=GetCheckpointItemNo(p);
    s:=GetItemText(i);
    SetItemText(i+1, s+sNoteText);
    Format;}
    Main.ParseIRCTextToRV(MesText, sNoteText);
  end
  else
  begin
    // первое сообщение от юзера
    // добавляем чекпоинт
    //cn:=AddNamedCheckpointEx(sUserName, false);
    MesText.AddBreak;
    Main.ParseIRCTextToRV(MesText, #2+#3+'04'+sUserName);
    Main.ParseIRCTextToRV(MesText, sNoteText);
  end;
end;

procedure TChatFrame.ClearMesText();
begin
  MesText.Clear;
  MesText.Format;
end;

procedure TChatFrame.InsertText(InsText: string);
var
    SelStart: Integer;
  TheText: string;
begin
  TheText := TxtToSend.Text;
  SelStart := TxtToSend.SelStart;
  Insert(InsText, TheText, SelStart+1);

  TxtToSend.Text := TheText;
  TxtToSend.SelStart := SelStart+Length(InsText);
end;

///////////////////////////////////////////////////////////////////////////////
//  Работа со списком ников
///////////////////////////////////////////////////////////////////////////////
procedure TChatFrame.AddNick(sNick: String; ImgIndex: integer = -1; Color: integer = 0);
var
  i,m: integer;
  Found: boolean;
  Node: TTreeNode;
begin
  with UserList do
  begin
    Found:=false;
    for i:=0 to Items.Count-1 do
      if Items[i].Text=sNick then Found:= true;
    if Found then Exit;
    Node:=Items.Add(nil, sNick);
    Node.ImageIndex:=ImgIndex;
    Node.SelectedIndex:=ImgIndex;
    if Page.PageInfo.bUseStateImages then Node.StateIndex:=ciUncheckedIndex;
    AlphaSort;
  end;
end;

procedure TChatFrame.AddNicks(sNickList: String; ImgIndex: integer = -1; Color: integer = 0;
          ClearList: boolean = false);
var
  i,m: integer;
  users:  TSepRec;
  sNick: string;
  Found: boolean;
  Node: TTreeNode;
begin
  // возможно, это повторный вход на канал. Очистим список юзеров
  if ClearList then UserList.Items.Clear;
  users := SplitString(sNickList);
  for m := 1 to users.max do
  begin
    //AddNick(users.rec[i], sChan);
    sNick:=users.rec[m];
    with UserList do
    begin
      Found:=false;
      for i:=0 to Items.Count-1 do
        if Items[i].Text=sNick then Found:= true;
      if Found then Exit;
      Node:=Items.Add(nil, sNick);
      Node.ImageIndex:=ImgIndex;
      Node.SelectedIndex:=ImgIndex;
      if Page.PageInfo.bUseStateImages then Node.StateIndex:=ciUncheckedIndex;
      AlphaSort;
    end;
  end;
end;

function TChatFrame.ChangeNick(sNick, sNewNick: string; ImgIndex: integer = -1; Color: integer = 0): boolean;
var
  i: integer;
begin
  result:=false;
  with UserList do
  begin
    for i := Items.Count-1 downto 0 do
    begin
      if AnsiLowerCase(Items[i].Text) = AnsiLowerCase(sNick) then
      begin
        result:=true;
        Items[i].Text := sNewNick;
        if ImgIndex >= 0 then
        begin
          Items[i].ImageIndex:=ImgIndex;
          Items[i].SelectedIndex:=ImgIndex;
        end;
        if sNick<>sNewNick then AlphaSort;
        Repaint;
        Break;
      end;
    end;
  end;
end;

procedure TChatFrame.RemoveNick(sNick: string; RemoveAll: boolean = false);
var
  i: integer;
begin
  with UserList do
  begin
    if RemoveAll then Items.Clear;
    for i := 0 to Items.Count-1 do
      if AnsiLowerCase(Items[i].Text) = AnsiLowerCase(sNick) then
      begin
        Items[i].Delete;
        Exit;
      end;
  end;
end;

procedure TChatFrame.SetUserlistStyle(sStyle: string);
begin
  with UserList do
  begin
    if sStyle='bold' then
    begin
      //Images:= Avatars24;
      Font.Color:=clWindowText;
      Font.Style:=[fsBold];
    end;
  end;
end;


procedure TChatFrame.LoadLanguage();
var
  SectName: string;

procedure ReadIni(var s: string; Name: string);
begin
  s:=Core.LangIni.ReadString(SectName, Name, s);
end;

function GetStr(Name: string; s: string): string;
begin
  result:=Core.LangIni.ReadString(SectName, Name, s);
end;

begin
  if not Assigned(Core.LangIni) then Exit;
  SectName:='ChatPage';
  try
    actClearText.Hint:=GetStr('actClearText.Hint', actClearText.Hint);
    actSmiles.Hint:=GetStr('actSmiles.Hint', actSmiles.Hint);
    actColor.Hint:=GetStr('actColor.Hint', actColor.Hint);
    actUnderline.Hint:=GetStr('actUnderline.Hint', actUnderline.Hint);
    actItalic.Hint:=GetStr('actItalic.Hint', actItalic.Hint);
    actBold.Hint:=GetStr('actBold.Hint', actBold.Hint);

    ReadIni(sUserListIns, 'sUserListIns');
    ReadIni(sUserListMsg, 'sUserListMsg');
    ReadIni(sUserListPvt, 'sUserListPvt');
    ReadIni(sUserListInf, 'sUserListInf');
    ReadIni(sUserListIgP, 'sUserListIgP');
    ReadIni(sUserListIgA, 'sUserListIgA');

    ReadIni(sDlgAddGroupCaption, 'sDlgAddGroupCaption');
    ReadIni(sDlgAddGroupText, 'sDlgAddGroupText');

    // AvatarPopup
    mGetAvatarFromFile.Caption:=GetStr('mGetAvatarFromFile.Caption', mGetAvatarFromFile.Caption);
    mGetAvatarFromURL.Caption:=GetStr('mGetAvatarFromURL.Caption', mGetAvatarFromURL.Caption);
    mCheckCurrentUserAvatar.Caption:=GetStr('mCheckCurrentUserAvatar.Caption', mCheckCurrentUserAvatar.Caption);
    mCheckAllUsersAvatar.Caption:=GetStr('mCheckAllUsersAvatar.Caption', mCheckAllUsersAvatar.Caption);
    // TextWindowPopUp
    actCopy.Caption:=GetStr('actCopy.Caption', actCopy.Caption);
    actFreezeScrolling.Caption:=GetStr('actFreezeScrolling.Caption', actFreezeScrolling.Caption);
    actHScroll.Caption:=GetStr('actHScroll.Caption', actHScroll.Caption);
    // UserListContextMenu
    mInsertName.Caption:=GetStr('mInsertName.Caption', mInsertName.Caption);
    mInsertPrivate.Caption:=GetStr('mInsertPrivate.Caption', mInsertPrivate.Caption);
    mPrivateAll.Caption:=GetStr('mPrivateAll.Caption', mPrivateAll.Caption);
    mPrivateWith.Caption:=GetStr('mPrivateWith.Caption', mPrivateWith.Caption);
    mInfoAboutUser.Caption:=GetStr('mInfoAboutUser.Caption', mInfoAboutUser.Caption);
    mSendFile.Caption:=GetStr('mSendFile.Caption', mSendFile.Caption);
    mCreateLine.Caption:=GetStr('mCreateLine.Caption', mCreateLine.Caption);
    mRefreshUserList.Caption:=GetStr('mRefreshUserList.Caption', mRefreshUserList.Caption);
    mIgnorePersonal.Caption:=GetStr('mIgnorePersonal.Caption', mIgnorePersonal.Caption);
    mIgnoreAll.Caption:=GetStr('mIgnoreAll.Caption', mIgnoreAll.Caption);
    mIgnoreForTime.Caption:=GetStr('mIgnoreForTime.Caption', mIgnoreForTime.Caption);
    mTemplates.Caption:=GetStr('mTemplates.Caption', mTemplates.Caption);
    mActionsSubmenu.Caption:=GetStr('mActionsSubmenu.Caption', mActionsSubmenu.Caption);
  finally
  end;
end;

procedure TChatFrame.OnActivateHandler(Sender: TObject);
begin
  MesText.StartAnimation();
  // Почему-то функция CanFocus() неправильно работает.
  //if TxtToSend.CanFocus() then TxtToSend.SetFocus();
  if (Core.MainForm.Visible) then TxtToSend.SetFocus();
end;

procedure TChatFrame.OnDeactivateHandler(Sender: TObject);
begin
  MesText.StopAnimation();
end;

procedure TChatFrame.OnUpdateStyleHandler(Sender: TObject);
begin
  SetNewFont();
  LoadLanguage();
end;

procedure TChatFrame.OnClearHandler(Sender: TObject);
begin
  ClearMesText();
end;

procedure TChatFrame.OnCompareHandler(Sender: TObject; Node1, Node2: TTreeNode; Data: Integer; var Compare: Integer);
var
  n1, n2: integer;
begin
  Compare:=0;

  // Особенность - нулевой индекс должен быть максимумом
  n1:=Node1.ImageIndex;
  n2:=Node2.ImageIndex;
  if n1=0 then n1:=10;
  if n2=0 then n2:=10;

  if n1 > n2 then Compare:=1
  else if n1 < n2 then Compare:=-1;

  if Compare=0 then Compare:=AnsiCompareStr(Node1.Text, Node2.Text);
end;

procedure TChatFrame.actDummyExecute(Sender: TObject);
begin
  //
end;

procedure TChatFrame.TxtToSendKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_Tab then Key:=Chr(0);
end;

end.
