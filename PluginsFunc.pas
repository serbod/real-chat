{ При использовании данных исходников или их фрагментов, ссылка на источник
  обязательна.
  http://irchat.ru

  Модуль обработки сообщений плагинов

  ParsePluginCmd() - это функция, которая разбирает и обрабатывает строку
  сообщения от плагина. Выполняется в потоке основной программы
}
unit PluginsFunc;

interface
uses SysUtils, Core, Plugins, Configs, Controls, ExtCtrls;

function ParsePluginCmd(Plug: TPlugin; cmd_text: string): string;

implementation
uses Misc, Main, OptionsForm;

function ParsePluginCmd(Plug: TPlugin; cmd_text: string): string;
var
  strMsg: string;
  strCmd: string;
  strPrm: string;
  sa: TStringArray;
  ParamsCount: integer;
  n, i, i1, i2, i3: integer;
  s, s1: string;
  PageInfo: TPageInfo;
  ChatPage: TChatPage;
begin
  result:='';
  sa:=ParseStr(cmd_text);
  ParamsCount:=Length(sa);
  if ParamsCount=0 then Exit
  else strMsg:=Copy(cmd_text, Pos(' ', cmd_text)+1, maxint);
  strCmd:=UpperCase(sa[0]);
  if strCmd='' then
  begin
  end

  // === Chat window commands ===
  else if strCmd='PUT_IRC_TEXT' then
  begin
    // PUT_IRC_TEXT <номер закладки> <текст> [номер панели закладок]
    // Вставка текста в окно, через парсер IRC-цветов.
    if ParamsCount < 3 then Exit;
    ParseIRCTextByPageID(StrToIntDef(sa[1], -1), sa[2]);
    Exit;
  end

  else if strCmd='SAY_IRC_MANUAL' then
  begin
    // SAY_IRC_MANUAL <текст>
    // Отправка текста так, как если бы мы его руками ввели в окно
    if ParamsCount < 2 then Exit;
    Core.Say(sa[1]);
    Exit;
  end

  else if strCmd='DEBUG_MSG' then
  begin
    // DEBUG_MSG <текст>
    // Отладочное сообщение, отображается в окне событий
    Core.DebugMessage('* '+Plug.Name+': '+strMsg);
    Exit;
  end

  else if strCmd='GET_TYPED_TEXT' then
  begin
    // GET_TYPED_TEXT
    // Получить набраный в поле ввода сообщения текст
    Exit;
  end

  else if strCmd='SET_TYPED_TEXT' then
  begin
    // SET_TYPED_TEXT <текст>
    // Установить текст в поле ввода сообщения
    Exit;
  end

  // === General commands ===
  else if strCmd='VERSION' then
  begin
    if ParamsCount < 2 then Exit;
    Plug.Version:=sa[1];
    Exit;
  end

  else if strCmd='ABOUT' then
  begin
    if ParamsCount < 2 then Exit;
    Plug.Desc:=sa[1];
    Exit;
  end

  else if strCmd='HELP' then
  begin
    Exit;
  end

  else if strCmd='CMD_LIST' then
  begin
    Plug.CmdList:=strMsg;
    Exit;
  end

  // === Options commands ===
  else if strCmd='GET_MAIN_OPTIONS' then
  begin
    result:='MAIN_OPTIONS ';
    for i:=0 to MainConf.AllConfItems.Count-1 do
    begin
      result:=result+MainConf.AllConfItems.Items[i].Name+'='+Norm(MainConf.AllConfItems.Items[i].ValueString)+' ';
    end;
    Exit;
  end

  else if strCmd='GET_OPTIONS' then
  begin
    if not Assigned(Plug.Conf) then Exit;
    result:='OPTIONS ';
    for i:=0 to Plug.Conf.AllConfItems.Count-1 do
    begin
      result:=result+Plug.Conf.AllConfItems.Items[i].Name+'='+Norm(Plug.Conf.AllConfItems.Items[i].ValueString)+' ';
    end;
    Exit;
  end

  else if strCmd='SET_OPTIONS' then
  begin
    if not Assigned(Plug.Conf) then Exit;
    for i:=0 to ParamsCount-1 do
    begin
      s:=sa[i];
      i2:=Pos('=', s);
      s1:=Copy(s, 1, i2-1);
      Plug.Conf[s1]:=Copy(s, i2+1, maxint);
    end;
    Exit;
  end

  else if strCmd='SET_MAIN_OPTIONS' then
  begin
    for i:=0 to ParamsCount-1 do
    begin
      s:=sa[i];
      i2:=Pos('=', s);
      s1:=Copy(s, 1, i2-1);
      MainConf[s1]:=Copy(s, i2+1, maxint);
    end;
    Exit;
  end

  else if strCmd='CREATE_PLUGIN_NODE' then
  begin
    if ParamsCount < 3 then Exit;
    if Assigned(Plug.Conf) then Exit;
    // Create config's root node
    Plug.Conf:=TConf.Create();
    Plug.Conf.FileName:=sa[2];
    Plug.Conf.RootNode:=TConfNode.Create(nil);
    Plug.Conf.RootNode.Name:='Plugin_Options';
    Plug.Conf.RootNode.FullName:=sa[1];
    Plug.Conf.RootNode.ConfItems:=TConfItems.Create(Plug.Conf.RootNode.Name);

    if not Assigned(MainConf.PluginsNode) then Exit;
    MainConf.PluginsNode.AddChild(Plug.Conf.RootNode);
    if ParamsCount > 3 then
    begin
      Plug.Conf.RootNode.Panel:=TPanel.Create(frmOptions);
      with TPanel(Plug.Conf.RootNode.Panel) do
      begin
        Align:=alClient;
        Caption:=sa[3];
        BevelOuter:=bvNone;
        Plug.Say('OPTIONS_PANEL_HANDLE '+IntToStr(Handle));
      end;
    end;
    frmOptions.RefreshConfTree();

    Exit;
  end

  // ADD_CONF_ITEM <name> <type> <full name> <value>
  else if strCmd='ADD_CONF_ITEM' then
  begin
    if ParamsCount < 5 then Exit;
    if not Assigned(Plug.Conf) then Exit;
    Plug.Conf.RootNode.ConfItems.Add(sa[1], sa[3], sa[4], sa[2][1]);
    Exit;
  end

  // === Page commands ===
  else if strCmd='GET_ACTIVE_PAGE' then
  begin
    // GET_ACTIVE_PAGE
    // Получение ID текущей активной страницы
    result:='ACTIVE_PAGE '+IntToStr(Core.PagesManager.GetActivePage.PageID);
    Exit;
  end

  else if strCmd='GET_ACTIVE_PAGE_NAME' then
  begin
    // GET_ACTIVE_PAGE
    // Получение ID текущей активной страницы
    result:='ACTIVE_PAGE_NAME '+Core.PagesManager.GetActivePage.PageInfo.Caption;
    Exit;
  end

  else if strCmd='SET_ACTIVE_PAGE' then
  begin
    // SET_ACTIVE_PAGE <номер закладки> [номер панели закладок]
    // Установка страницы активной.
    if ParamsCount < 2 then Exit;
    i:=StrToIntDef(sa[1], -1);
    if i=-1 then Exit;
    Core.PagesManager.ActivePageID:=i;
    Exit;
  end

  else if strCmd='CREATE_PAGE' then
  begin
    // CREATE_TAB <имя закладки> [номер панели закладок]
    // Создание новой закладки. В параметре имя. Возвращает её индекс
    if ParamsCount < 2 then Exit;
    //TabCreate(sa[1]);
    Core.ClearPageInfo(PageInfo);
    PageInfo.Caption:=sa[1];
    i:=Core.PagesManager.CreatePage(PageInfo);
    Plug.ModifyPagesList(i, 1);
    result:='NEW_PAGE '+IntToStr(i)+' '+sa[1];
    Exit;
  end

  else if strCmd='CREATE_CHAT_PAGE' then
  begin
    if ParamsCount < 2 then Exit;
    //TabCreate(sa[1]);
    Core.ClearPageInfo(PageInfo);
    PageInfo.Caption:=sa[1];
    PageInfo.PageType:=ciChatPageType;
    i:=Core.PagesManager.CreatePage(PageInfo);
    Plug.ModifyPagesList(i, 1);
    result:='NEW_PAGE '+IntToStr(i)+' '+sa[1];
    Exit;
  end

  else if strCmd='GET_PAGE_ID' then
  begin
    if ParamsCount < 2 then Exit;
    result:='PAGES_ID';
    for i:=0 to Core.PagesManager.PagesCount-1 do
    begin
      PageInfo:=Core.PagesManager.GetPageByIndex(i).PageInfo;
      if PageInfo.Caption=sa[1] then result:=result+' '+IntToStr(PageInfo.ID);
    end;
    Exit;
  end

  else if strCmd='GET_PAGES_ID' then
  begin
    s:='PAGES_ID';
    for i:=0 to Core.PagesManager.PagesCount-1 do
    begin
      s:=' '+IntToStr(Core.PagesManager.GetPageByIndex(i).PageID);
    end;
    result:=s;
    Exit;
  end

  else if strCmd='GET_PAGE_INFO' then
  begin
    if ParamsCount < 2 then Exit;
    if not PagesManager.GetPageInfo(StrToIntDef(sa[1], 0), PageInfo) then Exit;
    result:='PAGE_INFO '+IntToStr(PageInfo.ID)
    +' '+PageInfo.Caption
    +' '+IntToStr(PageInfo.PageType)
    +' '+BoolToStr(PageInfo.Visible);
    Exit;
  end

  else if strCmd='CLEAR_PAGE' then
  begin
    // CLEAR_PAGE <ID страницы>
    // Очищает заданую страницу
    if ParamsCount < 2 then Exit;
    ChatPage:=PagesManager.GetPage(StrToIntDef(sa[1], 0));
    if not Assigned(ChatPage) then Exit;
    ChatPage.Clear();
    Exit;
  end

  else if strCmd='DELETE_PAGE' then
  begin
    // DELETE_PAGE <ID страницы>
    // Удалить страницу чата
    if ParamsCount < 2 then Exit;
    i:=StrToIntDef(sa[1], 0);
    if not Plug.HavePageID(i) then Exit;
    PagesManager.RemovePage(i);
    Exit;
  end

  else if strCmd='GET_PAGE_HANDLE' then
  begin
    // GET_PAGE_HANDLE <ID страницы>
    // Получение handle окна страницы и закладки по ID закладки
    if ParamsCount < 2 then Exit;
    ChatPage:=PagesManager.GetPage(StrToIntDef(sa[1], 0));
    if not Assigned(ChatPage) then Exit;
    result:='PAGE_HANDLE '+sa[1]+' '+IntToStr(ChatPage.Frame.Handle)+' '+IntToStr(ChatPage.TabSheet.Handle);
    Exit;
  end

  // === Userlist commands ===
  else if strCmd='CREATE_NICK_LIST' then
  begin
    // CREATE_NICK_LIST <ID страницы> <список ников>
    // Заполнить список ников для заданной страницы
    if ParamsCount < 3 then Exit;
    i:=StrToIntDef(sa[1], 0);
    if not Plug.HavePageID(i) then Exit;
    s:='';
    for n:=2 to ParamsCount-1 do s:=s+sa[n]+' ';
    Core.AddNicks(i, s, 0, true);
    Exit;
  end

  else if strCmd='ADD_NICK_TO_LIST' then
  begin
    // ADD_NICK_TO_LIST <ID страницы> <ник>
    // Добавить ник в список
    if ParamsCount < 3 then Exit;
    i:=StrToIntDef(sa[1], 0);
    if not Plug.HavePageID(i) then Exit;
    Core.AddNick(i, sa[2]);
    Exit;
  end

  else if strCmd='DELETE_NICK_FROM_LIST' then
  begin
    // DELETE_NICK_FROM_LIST <ID страницы> <ник>
    // Удалить ник из списка
    if ParamsCount < 3 then Exit;
    i:=StrToIntDef(sa[1], 0);
    if not Plug.HavePageID(i) then Exit;
    Core.RemoveNick(i, sa[2]);
    Exit;
  end

  else if strCmd='CLEAR_USERLIST' then
  begin
    // CLEAR_USERLIST <ID страницы>
    // Очищает список юзеров для указаной закладки
    if ParamsCount < 2 then Exit;
    i:=StrToIntDef(sa[1], 0);
    if not Plug.HavePageID(i) then Exit;
    Core.RemoveNick(i, '', true);
    Exit;
  end

  else if strCmd='TEST' then
  begin
    Exit;
  end

  else if strCmd='TEST' then
  begin
    Exit;
  end

  else if strCmd='TEST' then
  begin
    Exit;
  end

  else if strCmd='TEST' then
  begin
    Exit;
  end

  else if strCmd='TEST' then
  begin
    Exit;
  end;
end;

end.
