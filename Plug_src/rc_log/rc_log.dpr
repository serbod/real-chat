{
  ������ �������� ����������� ������� ��� RealChat.

  ���� ������ ������� - ���������� � ��������� ����� ��� ����������, �����������
  �� �������� ���������. ��������� �� ������ ���������� ������������ � ������
  �����.
}
program rc_log;

{$APPTYPE CONSOLE}

uses
  SysUtils;

type
  TStringArray = array of string;
  TLogs = record
    Items: array of Text;
    Names: array of string;
    Count: integer;
  end;

var
  i: integer;
  sIn, sCmd: string;
  Logs: TLogs;
  sLogsPath: string;

const
  sVersion = '1.0';
  sDesc = 'Logger console plugin. http://irchat.ru';

{ === ��������� � ������� === }
{ ��� ������ ��������� � STDOUT, ��� ������������. ������� Flush() ������� �����
  � ��������� ������������ ��� �������� }
procedure Say(s: string);
begin
  WriteLn(s);
  Flush(Output);
end;

// ������ ������ � ���������, � ������ ������� ������� (")
// bAddEmpty - ������� ���������� ������ �����
function ParseStr(s: String; bAddEmpty: boolean = false): TStringArray;
var
  i,l,rl: integer;
  InBracket: boolean;
  TmpStr: String;

procedure AddStr;
begin
  if (TmpStr='') and (not bAddEmpty) then Exit;
  Inc(rl);
  SetLength(result, rl);
  result[rl-1]:=TmpStr;
  TmpStr:='';
end;

begin
  i:=0;
  l:=Length(s);
  rl:=0;
  InBracket:=false;
  TmpStr:='';
  SetLength(result, rl);
  while i<l do
  begin
    Inc(i);
    case s[i] of
    ' ':
      if not InBracket then AddStr()
      else TmpStr:=TmpStr+s[i];
    '"':
    begin
      if (i+1<l) and (s[i+1]='"') then
      begin
        if ((i+2<l) and (s[i+2]=' ')) or (i+2=l) then
        begin
          // empty brackets
          InBracket:=false;
          AddStr();
          Inc(i, 2);
          continue;
        end;
        // two brackets as one bracket
        TmpStr:=TmpStr+'"';
        Inc(i);
        continue;
      end;
      if InBracket then
      begin
        InBracket:=false;
        AddStr();
      end
      else
      begin
        InBracket:=true;
        continue;
      end;
    end;
    else
    // normal char
    TmpStr:=TmpStr+s[i];
    end;
  end;
  AddStr();
end;

// ���������� ������ � ��������������� ��������� ���-����
// � �������� ����� ���� ������������ ������ �������� ������
procedure WriteLog(s: string);
var
  i, n: integer;
  sCmd, sName, sMsg, sFileName: string;
  sa: TStringArray;
  found: boolean;
begin
  sa:=ParseStr(s, true);
  n:=Length(sa);
  if n<2 then Exit;
  sCmd:=sa[0];
  sName:=sa[1];
  sMsg:='';
  for i:=2 to n-1 do
  begin
    sMsg:=sMsg+sa[i]+' ';
  end;

  // get text file
  found:=false;
  for i:=0 to Logs.Count-1 do
  begin
    if Logs.Names[i]=sName then
    begin
      WriteLn(Logs.Items[i], sMsg);
      Flush(Logs.Items[i]);
      found:=true;
      break;
    end;
  end;

  if not found then
  begin
    sFileName:=sLogsPath+StringReplace(sName, ':', '-', [rfReplaceAll])+'.log';

    Inc(Logs.Count);
    SetLength(Logs.Items, Logs.Count);
    SetLength(Logs.Names, Logs.Count);

    i:=Logs.Count-1;
    Logs.Names[i]:=sName;
    AssignFile(Logs.Items[i], sFileName);
    if FileExists(sFileName) then Append(Logs.Items[i]) else Rewrite(Logs.Items[i]);

    WriteLn(Logs.Items[i], sMsg);
    Flush(Logs.Items[i]);
  end;

end;

{ === ���� ��������� === }
begin
  { TODO -oUser -cConsole Main : Insert code here }
  // ������� ������ �����
  Logs.Count:=0;
  SetLength(Logs.Items, Logs.Count);
  SetLength(Logs.Names, Logs.Count);

  sLogsPath:=ExtractFilePath(ParamStr(0))+'\Logs\';
  if not FileExists(sLogsPath) then CreateDir(sLogsPath);

  // ��������� ��� ������������
  Say('// This file is STDIO plugin for RealChat. Enter "q" for quit.');

  // ���� ������ ��������� �� STDIN
  while true do
  begin
    ReadLn(sIn);

    // �������� ������� (������ �������� ������)
    if Pos(' ', sIn)>0 then
      sCmd:=UpperCase(Copy(sIn, 1, Pos(' ', sIn)-1))
    else
      sCmd:=UpperCase(sIn);

    // �������� � ����������� �� �������
    if sCmd='' then Break

    else if (sCmd='Q') or (sCmd='QUIT') then Break

    // ���������� ������ �������
    else if (sCmd='GET_VERSION') then
    begin
      WriteLog('LOG rc '+sIn);
      Say('VERSION '+sVersion);
    end

    // ���������� ���������� � �������
    else if (sCmd='GET_ABOUT') then
    begin
      WriteLog('LOG rc '+sIn);
      Say('ABOUT '+sDesc);
    end

    // ������� ���� �������� � ��������� ���������
    else if (sCmd='START') then
    begin
      WriteLog('LOG rc '+sIn);
      Say('CREATE_PLUGIN_NODE "Logger plugin" "rc_log.ini"');
      Say('ADD_CONF_ITEM Enabled B "Plugin enabled" 1');
      Say('ADD_CONF_ITEM LogsPath S "Logs path" "'+sLogsPath+'"');
      Say('ADD_CONF_ITEM LogLevel N "Logs level" 5');
      Say('ADD_CONF_ITEM AddTimestamp B "Add timestamp to every record" 0');
     end

    // ���������� � ��� ��������� IRC
    else if (sCmd='IRC') then
    begin
      WriteLog(sIn);
      //Say(sDesc);
      //Say('DEBUG_MSG IRC '+sIn);
    end

    // ���������� � ��� ������ ���������
    else
    begin
      WriteLog('LOG rc '+sIn);
      //Say('DEBUG_MSG Cmd='+sCmd);
    end;
  end;

  // �������� ����
  for i:=0 to Logs.Count-1 do
  begin
    WriteLn(Logs.Items[i], '');
    CloseFile(Logs.Items[i]);
  end;
  Logs.Count:=0;
  SetLength(Logs.Items, Logs.Count);
  SetLength(Logs.Names, Logs.Count);
end.

