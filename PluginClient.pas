{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  TPluginClient - клиент чата, использующий внешнюю библиотеку функций (плагин)

}
unit PluginClient;

interface
uses SysUtils, Misc, Core, Classes, Windows, Configs,
     Contnrs, Plugins;

type
  TPluginConf = class(TConf)
  public
    ChatClient: TChatClient;
    FToolButtonsList: TObjectList;
    constructor Create(ChatClient: TChatClient; ConfFileName: string);
    destructor Destroy(); override;
  end;

  TPluginClient = class(TChatClient)
  private
    Plugin: TPlugin;
    function IsActive(): boolean;
    function CmdToPlugin(Cmd: string): string;
    function OnPluginMsg(Msg: string): string;
    // Обработчик принятия изменений в конфиге
    procedure OnApplySettings(Sender: TObject);
  public
    Conf: TPluginConf;
    constructor Create(PluginFileName, ConfFileName: string); reintroduce;
    destructor Destroy(); override;
    function Connect(): boolean; override;
    function Disconnect(): boolean; override;
    property Active: boolean read IsActive;
    // Return empty string if message processed succesfully
    function SendTextFromPage(PageInfo: TPageInfo; sText: string): string; override;
    // Send string directly to server
    //function SendTextToServer(sText: string): boolean; override;
    // Show some text on chat page with specified ID
    //function ShowText(PageID: integer; sText: string): boolean;
    // Вызывается при закрытии страницы
    function ClosePage(PageID: integer): boolean; override;
    function GetConf(): TConf; override;
    // Получить список кнопок для общей панели инструментов
    function GetMainToolButtons(PageID: integer): TObjectList; override;
  protected
    //procedure Event(EventText: string);
  end;

implementation

// ===== TPluginConf =====
constructor TPluginConf.Create(ChatClient: TChatClient; ConfFileName: string);
begin
  self.ChatClient:=ChatClient;
  self.FileName := glUserPath+ConfFileName;

  // Create config's root node
  RootNode:=TConfNode.Create(nil);
  RootNode.Name:='Plugin_Options';
  RootNode.FullName:='Plugin options';
  RootNode.ConfItems:=TConfItems.Create(RootNode.Name);

  // Filll config items by default values

  // Создаем список кнопок
  FToolButtonsList:=TObjectList.Create();
end;

destructor TPluginConf.Destroy();
begin
  FToolButtonsList.Free();
  inherited Destroy();
end;

// ===== TPluginClient =====
constructor TPluginClient.Create(PluginFileName, ConfFileName: string);
var
  i: integer;
  NewID: integer;
  PageInfo: TPageInfo;
begin
  inherited Create(ConfFileName);

  NewID:=0;  // !!!
  self.Plugin:=TPluginDLL.Create(PluginFileName, NewID);

  self.Conf:=TPluginConf.Create(self, ConfFileName);
  self.Conf.OnApplySettings:=OnApplySettings;

  self.PagesIDCount:=0;
  SetLength(self.PagesIDList, self.PagesIDCount);

  // Получение информации о плагине
  self.FInfoAbout:='Plugin version 0.3';
  self.FInfoProtocolID:=8;
  self.FInfoProtocolName:='Plugin';
  self.FInfoConnection:='Plugin';
  self.Conf.RootNode.FullName:=self.FInfoConnection;


  self.OnApplySettings(nil);

end;

destructor TPluginClient.Destroy();
begin
  Disconnect();

  inherited Destroy();
end;

function TPluginClient.IsActive(): boolean;
begin
  result:=(CmdToPlugin('ACTIVE')='1');
end;

function TPluginClient.CmdToPlugin(Cmd: string): string;
begin
  result:=Plugin.Ask(Cmd);
end;

procedure TPluginClient.OnApplySettings(Sender: TObject);
begin
  CmdToPlugin('APPLY_SETTINGS');
end;

function TPluginClient.Connect(): boolean;
begin
  result:=(CmdToPlugin('CONNECT')='');
end;

function TPluginClient.Disconnect(): boolean;
begin
  result:=(CmdToPlugin('DISCONNECT')='');
end;

function TPluginClient.SendTextFromPage(PageInfo: TPageInfo; sText: string): string;
begin
  result:=CmdToPlugin('TEXT '+IntToStr(PageInfo.ID)+' '+sText);
end;

function TPluginClient.ClosePage(PageID: integer): boolean;
begin
  result:=(CmdToPlugin('CLOSE_PAGE '+IntToStr(PageID))='');
end;

function TPluginClient.GetConf(): TConf;
begin
  CmdToPlugin('GET_CONF');
  result:=self.Conf;
end;

function TPluginClient.GetMainToolButtons(PageID: integer): TObjectList;
begin
  CmdToPlugin('GET_MAIN_TOOL_BUTTONS');
  result:=self.Conf.FToolButtonsList;
end;

function TPluginClient.OnPluginMsg(Msg: string): string;
var
  Params: TStringArray;
  ParamsCount: integer;
  PageInfo: TPageInfo;
  i, PageID: integer;
  Cmd, SubCmd, sTemp: string;
begin
  result:='';
  Params:=ParseStr(Msg);
  ParamsCount:=Length(Params);
  if ParamsCount = 0 then Exit;

  Cmd:=UpperCase(Params[0]);
  SubCmd:=Copy(Cmd, 1, Pos('_', Cmd)-1);
  sTemp:='';

  if Cmd = '' then Exit

  else if Cmd = 'SAY' then
  begin
    if ParamsCount < 3 then Exit;
    PageID:= StrToIntDef(Params[1], -1);
    sTemp:='/SAY';
    for i:=2 to ParamsCount-1 do sTemp:=sTemp+' '+Params[i];
    Core.Say(sTemp, PageID);
  end

  else if Cmd = 'PUT_IRC_TEXT' then
  begin
    // PUT_IRC_TEXT <номер закладки> <текст> [номер панели закладок]
    // Вставка текста в окно, через парсер IRC-цветов.
    if ParamsCount < 3 then Exit;
    PageID:= StrToIntDef(Params[1], -1);
    for i:=2 to ParamsCount-1 do sTemp:=sTemp+' '+Params[i];
    if self.ShowText(PageID, sTemp) then result:='OK';
    Exit;
  end

  else if Cmd = 'GET_ACTIVE_PAGE' then
  begin
    // GET_ACTIVE_PAGE
    // Получение номера текущей активной закладки
    result:=IntToStr(Core.PagesManager.GetActivePage.PageID);
  end

  else if Cmd = 'CREATE_TAB' then
  begin
    // CREATE_TAB <имя закладки> [номер панели закладок]
    // Создание новой закладки. В параметре имя. Возвращает её индекс
    if ParamsCount < 2 then Exit;
    //TabCreate(sa[1]);
    Core.ClearPageInfo(PageInfo);
    PageInfo.Caption:=Params[1];
    result:=IntToStr(Core.PagesManager.CreatePage(PageInfo));
  end

  else if Cmd = 'SET_ACTIVE_PAGE' then
  begin
    // SET_ACTIVE_PAGE <номер закладки> [номер панели закладок]
    // Установка активной страницы.
    if ParamsCount < 2 then Exit;
    i:=StrToIntDef(Params[1], -1);
    if i=-1 then Exit;
    Core.PagesManager.ActivePageID:=i;
    result:='OK';
  end

  else if Cmd = '' then
  begin
  end

  else if Cmd = '' then
  begin
  end

  else if Cmd = '' then
  begin
  end

  else if Cmd = '' then
  begin
  end

  else if Cmd = '' then
  begin
  end

  else if Cmd = '' then
  begin
  end

  else if Cmd = '' then
  begin
  end

  else
  begin
  end;

end;

end.
