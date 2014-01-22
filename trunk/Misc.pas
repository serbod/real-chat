unit Misc;
{$DEFINE DEBU}

interface
uses
  Classes, Windows, SysUtils, base64;
type
  TStringArray = array of string;

  TStrPair = record
    Name: string;
    Data: string;
  end;

  TInfoList = record
    Count: integer;
    Items: array of TStrPair;
  end;

  TSepRec = record
    Rec: TStringArray; // сами "записи"
    Max: integer; // количество полученных "записей"
  end;

// Прекодировка аццкой абракадабры в няшную и кавайную. ^^v
const
  rus: array[0..32] of string = ('а','б','в','г','д','е','ё','ж','з','и','й','к','л','м','н','о','п','р','с','т','у','ф','х','ц','ч','ш','щ','ь','ы','ъ','э','ю','я');
  // Современный транслит
  //lat: array of string = ('a','b','v','g','d','e','e','zh','z','i','j','k','l','m','n','o','p','r','s','t','u','f','h','c','ch','sh','shch','','y','''','e','yu','ya');
  // Современный двусторонний транслит
  lat: array[0..32] of string = ('a','b','v','g','d','e','yo','zh','z','i','j','k','l','m','n','o','p','r','s','t','u','f','kh','tc','ch','sh','shc','''','y','''','e''','yu','ya');
  lat2: array[0..6] of string = ('y','z','k','t','c','s','e');

// Транслит русский -> латинский
function TranslitRus2Lat(const Str: string): string;
// Транслит латинский -> русский
function TranslitLat2Rus(const str: string): string;
// Транслит с автоопределением
function TranslitAuto(const str: string): string;


// Возвращает композитный цвет RGB по номеру цвета ANSI
function AnsiColor(intColNum :Integer) :Integer;

//Ищет в строке S строку SubStr и возвращает номер, с которого начинается.
function TailPos(const S, SubStr: AnsiString; fromPos: integer): integer;
// Синтаксис: Где, Что, На_Что.
function StrReplace(const Str, Str1, Str2: string): string;
// Секунды в формат ЧЧ:ММ:СС
function SecToTime(Sec: Integer): String;
// Вычисление часового пояса
function TimeZone():integer;
// Преобразование UNIX-времени в нормальное, ламерское :)
function UNIXtoDateTime(Seconds :String): String;
//Мелкие функции в помощь :)
function LeftR(strData :String; intMin :Integer) :String;
function RightR(strData :String; intMin :Integer) :String;
function SplitString(sRows: string; cSeparator: char = ' '): TSepRec;
function SplitString2(var sRows: string; cSeparator: char = ' '): TSepRec;
// Парсит строку с пробелами, с учетом двойных кавычек (")
function ParseStr(s: String; bAddEmpty: boolean = false): TStringArray;
// Нормализует строку (добавляет двойные кавычки)
function Norm(s: string): string;
// Из указанной строки возвращает параметр по его номеру
function ParamFromStr(s: string; ParamNum: integer): string;

// Строка IP-адреса в строку числового значения IP-адреса
function IP2IntStr(sIP: string): string;
// Строка числового значения IP-адреса в строку IP-адреса
function IntStr2IP(IntIP: string): string;
// Разделяет строку на массив строк по строке-разделителю
// Сам разделитель в массив не попадает
function SeparateStrings(sText, sSeparator: string): TStringArray;
function SeparateStrings2(sText: string; cSeparator: char=' '; cDelimiter:char='"'): TStringArray;
// Возвращает строку описания кода ошибки сокета
function GetSocketErrorDescription(var ErrorCode: Integer): String;
// эту функцию можно удалить
//function  GetIPAddress(name: string): string;

// Шифрует текст заданным паролем
procedure EncryptText(var Text: string; Password: string);
// Дешифрует текст заданным паролем
procedure DecryptText(var Text: string; Password: string);

// Копирует один файл в другой
function CopyFile(FileNameSrc, FileNameDst: string): boolean;

// Возвращает имя пользователя windows
function GetWinUserName(): string;
// Возвращает имя компьютера
function GetWinCompName(): string;
// Возвращает версию Windows
function GetWinVersion(): string;

function ParseProxyURL(const ProxyURL: string; var Proto, Host, Port, User, Pass: string): boolean;
function ComposeProxyURL(Host, Port, Proto, User, Pass: string): string;

implementation
uses RC4, synautil;

type
  RC4_KEY_ST = record
    x,y: cardinal;
    data: array[0..255] of cardinal;
  end;

type
  TRC4_set_key = procedure(var RC4_key: RC4_KEY_ST; len: cardinal; data: PChar); cdecl;
  TRC4 = procedure(var RC4_key: RC4_KEY_ST; len: longint; indata: PChar; outdata: PChar); cdecl;

//==== Functions for interface ==================
function GetIndexR(s: string): integer;
begin
  for Result:=0 to Length(rus)-1 do
  begin
    if rus[Result] = s then Exit;
  end;
  Result:=-1;
end;

function GetIndexL(s: string): integer;
begin
  for Result:=0 to Length(lat)-1 do
  begin
    if lat[Result] = s then Exit;
  end;
  Result:=-1;
end;

function GetIndexL2(s: string): integer;
begin
  for Result:=0 to Length(lat2)-1 do
  begin
    if lat2[Result] = s then Exit;
  end;
  Result:=-1;
end;

// Прекодировка кириллицы в транслит
function TranslitRus2Lat(const str: string): string;
var
  i, iPos: Integer;
  s1, s2, s3: string;
  LenS: Integer;

begin
  result := '';
  LenS := Length(str);
  iPos:=0;
  while iPos < Length(str) do
  begin
    s1:=Str[iPos+1];
    s2:=AnsiLowerCase(s1);
    i := GetIndexR(s2);
    if i = -1 then Result:=Result+s1
    else
    begin
      s3:=lat[i];
      if s2<>s1 then
      begin
        // Caps
        s3[1]:=AnsiUpperCase(s3[1])[1];
      end;
      Result:=Result+s3;
    end;
    Inc(iPos);
  end;
end;

// Прекодировка транслита в кириллицу
function TranslitLat2Rus(const str: string): string;
const
  lat3: string = 'shc';

var
  i, i2, iPos: Integer;
  s1, s2, s3, s0: string;
  LenS: Integer;

begin
  result := '';
  LenS := Length(str);
  iPos:=0;
  while iPos < Length(str) do
  begin
    s0:=Copy(str, iPos+1, 1);
    s1:=AnsiLowerCase(s0);
    // Проверка на двухсимвольность
    i:=-1;
    i2:=GetIndexL2(s1);
    if i2 <> -1 then
    begin
      s2:=AnsiLowerCase(Copy(str, iPos+1, 2));
      if s2='sh' then
      begin
        // Проверка на трехсимвольность
        s3:=AnsiLowerCase(Copy(str, iPos+1, 3));
        if s3 = lat3 then s2:=s3;
      end;
      i2:=GetIndexL(s2);
      if i2 <> -1 then
      begin
        i:=i2;
        Inc(iPos, Length(s2));
      end;
    end;
    if i = -1 then
    begin
      // Односимвольная буква?
      i:=GetIndexL(s1);
      Inc(iPos, 1);
    end;

    if i = -1 then Result:=Result+s1
    else
    begin
      s3:=rus[i];
      if s0<>s1 then
      begin
        // Caps
        s3[1]:=AnsiUpperCase(s3[1])[1];
      end;
      Result:=Result+s3;
    end;
  end;
end;

function TranslitAuto(const str: string): string;
begin
  if Length(str)=0 then Exit;
  if (GetIndexL(AnsiLowerCase(str[1])) <> -1) or (GetIndexL2(AnsiLowerCase(str[1])) <> -1) then
  begin
    Result:=TranslitLat2Rus(str);
    Exit;
  end
  else
  begin
    if GetIndexR(AnsiLowerCase(str[1])) <> -1 then
    begin
      Result:=TranslitRus2Lat(str);
      Exit;
    end;
  end;
  Result:=str;
end;

function AnsiColor(intColNum :Integer) :Integer;
begin
  Case intColNum of
    0: Result := 16777215;          //(255, 255, 255)
    1: Result := 0;                 //RGB(0, 0, 0)
    2: Result := 8323072;           //RGB(0, 0, 127)
    3: Result := 32512;             //RGB(0, 127, 0)
    4: Result := 255;               //RGB(255, 0, 0)
    5: Result := 127;               //RGB(127, 0, 0)
    6: Result := 8323199;           //RGB(127, 0, 127)
    7: Result := 32767;             //RGB(255, 127, 0)
    8: Result := 65535;             //RGB(255, 255, 0)
    9: Result := 65280;             //RGB(0, 255, 0)
    10: Result := 8421440;          //RGB(64, 128, 128)
    11: Result := 16776960;         //RGB(0, 255, 255)
    12: Result := 16711680;         //RGB(0, 0, 255)
    13: Result := 16711935;         //RGB(255, 0, 255)
    14: Result := 6052956;          //RGB(92, 92, 92)
    15: Result := 12105912;         //RGB(184, 184, 184)
    else Result := 0;               //RGB(0, 0, 0)
  end;
end;

//==== Functions for IRC =============
function TailPos(const S, SubStr: AnsiString; fromPos: integer): integer;
asm
        PUSH EDI
        PUSH ESI
        PUSH EBX
        PUSH EAX
        OR EAX,EAX
        JE @@2
        OR EDX,EDX
        JE @@2
        DEC ECX
        JS @@2

        MOV EBX,[EAX-4]
        SUB EBX,ECX
        JLE @@2
        SUB EBX,[EDX-4]
        JL @@2
        INC EBX

        ADD EAX,ECX
        MOV ECX,EBX
        MOV EBX,[EDX-4]
        DEC EBX
        MOV EDI,EAX
@@1: MOV ESI,EDX
        LODSB
        REPNE SCASB
        JNE @@2
        MOV EAX,ECX
        PUSH EDI
        MOV ECX,EBX
        REPE CMPSB
        POP EDI
        MOV ECX,EAX
        JNE @@1
        LEA EAX,[EDI-1]
        POP EDX
        SUB EAX,EDX
        INC EAX
        JMP @@3
@@2: POP EAX
        XOR EAX,EAX
@@3: POP EBX
        POP ESI
        POP EDI
end;

function StrReplace(const Str, Str1, Str2: string): string;
var
  P, L: Integer;
begin
  Result := str;
  L := Length(Str1);
  repeat
    P := Pos(Str1, Result);
    if P > 0 then
    begin
      Delete(Result, P, L);
      Insert(Str2, Result, P);
    end;
  until P = 0;
end;

function TimeZone():integer;
var time:_TIME_ZONE_INFORMATION;
    z:integer;
begin
  GetTimeZoneInformation(time);
  z:=time.Bias;
  z:=z div 60;
  z:=abs(z);
  if time.bias>0 then Result:=-z else Result:=z;
end;

function UNIXtoDateTime(Seconds :String): String;
var
	TheRealTime: TDateTime;
const
  UnixStartDate: TDateTime = 25569.0;
begin
	TheRealTime := ((StrToIntDef(Seconds,0) + TimeZone*3600)/ 86400) + UnixStartDate;
  Result := DateTimeToStr(TheRealTime);
end;

function SecToTime(Sec: Integer): String;
var
  H, M, S: INTEGER;
  HS, MS, SS: string;
begin
  S := Sec;
  M := Round(INT(S / 60));
  S := S - M * 60; //Seconds
  H := Round(INT(M / 60)); //Hours
  M := M - H * 60; //Minutes
  if H < 10 then
    HS := '0' + Inttostr(H)
  else
    HS := inttostr(H);
  if M < 10 then
    MS := '0' + Inttostr(M)
  else
    MS := inttostr(M);
  if S < 10 then
    SS := '0' + inttostr(S)
  else
    SS := inttostr(S);
  RESULT := HS + ':' + MS + ':' + SS;
end;

function LeftR(strData :String; intMin :Integer) :String;
begin
  Result := copy(strData, 2, Length(strData) - intMin);
end;

function RightR(strData :String; intMin :Integer) :String;
begin
  Result := copy(strData, intMin, Length(strData) - intMin);
end;

function SplitString(sRows: string; cSeparator: char = ' '): TSepRec;
var
  i, n, x, xLen: integer;
begin
  n:=0;
  x:=1;
  xLen:=0;
  for i:=1 to Length(sRows) do
  begin
    Inc(xLen);
    if sRows[i] = cSeparator then
    begin
      Inc(n);
      SetLength(result.Rec, n+1);
      result.Rec[n]:= Copy(sRows, x, xLen-1);
      Inc(x, xLen);
      xLen:=0;
    end;
  end;
  if xLen > 0 then
  begin
    Inc(n);
    SetLength(result.Rec, n+1);
    result.Rec[n]:= Copy(sRows, x, xLen);
  end;
  result.max:=n;
end;

function SplitString2(var sRows: string; cSeparator: char = ' '): TSepRec;
var
  i, n, x, xLen, maxLen: integer;
begin
  n:=0;
  x:=1;
  XLen:=0;
  maxLen:=0;
  for i:=1 to Length(sRows) do
  begin
    Inc(xLen);
    if sRows[i] = cSeparator then
    begin
      Inc(n);
      SetLength(result.Rec, n+1);
      result.Rec[n]:= Copy(sRows, x, xLen);
      Inc(x, xLen);
      Inc(maxLen, xLen);
      xLen:=0;
    end;
  end;
  result.max:=n;
  Delete(sRows, 1, maxLen);
end;

//==== Functions for DCC ==================
function IP2IntStr(sIP: string): string;
// доработать на прочность
var
  s1, s2: string;
  i, n: integer;
  r,r2: Int64;
begin
  s1:=sIP;
  n:=3;
  r:=0;
  while (s1 <> '') do
  begin
    i:=Pos('.',s1);
    if i>0 then
    begin
      s2:=Copy(s1, 1, i-1);
      s1:=Copy(s1, i+1, 999);
    end
    else
    begin
      s2:=s1;
      s1:='';
    end;
    r2:=StrToIntDef(s2,0);
    for i:=1 to n do r2:=r2*256;
    r:=r+r2;
    Dec(n);
  end;
  result:=IntToStr(r);
end;

function IntStr2IP(IntIP: string): string;
var
  s: string;
  i, n, k: Int64;
  ii: integer;
begin
  i:=StrToInt64Def(IntIP,0);
  if i=0 then
  begin
    result:='';
    Exit;
  end;
  k:=1;
  for ii:=1 to 4 do k:=k * 256;
  s:='';
  while k > 1 do
  begin
    k:=k div 256;
    n:=0;
    if i >= k then
    begin
      n:=i div k;
      i:=i mod k;
    end;
    s:=s+IntToStr(n)+'.';
  end;
  result:=Copy(s, 1, Length(s)-1);
end;

function SeparateStrings(sText, sSeparator: string): TStringArray;
var
  n, l, sl: integer;
  //s1, s2: string;
begin
  sl:=Length(sSeparator);
  n:=Pos(sSeparator, sText);
  l:=1;
  while n > 0 do
  begin
    SetLength(result, l);
    result[l-1]:=Copy(sText, 1, n-1);
    sText:=Copy(sText, n+sl, maxint);
    n:=Pos(sSeparator, sText);
    Inc(l);
  end;
  SetLength(result, l);
  result[l-1]:=sText;
end;

function SeparateStrings2(sText: string; cSeparator: char=' '; cDelimiter:char='"'): TStringArray;
var
  l, i: integer;
  InDelimiters: boolean;
  BeginPos, EndPos: integer;
  //s1, s2: string;
begin
  InDelimiters:=false;
  BeginPos:=0;
  EndPos:=0;
  l:=1;
  for i:=0 to Length(sText) do
  begin
    if (sText[i]=cSeparator) and (not InDelimiters) then
    begin
      EndPos:=i-1;
      SetLength(result, l);
      Inc(l);
      result[l-1]:=Copy(sText, BeginPos, (EndPos-BeginPos));
      BeginPos:=i+1;
    end;
    if sText[i]=cSeparator then
    begin
      if not InDelimiters then InDelimiters:=true
      else
      begin
      EndPos:=i-1;
      SetLength(result, l);
      Inc(l);
      result[l-1]:=Copy(sText, BeginPos, (EndPos-BeginPos));
      BeginPos:=i+1;

      end;
    end;

  end;
end;

function GetSocketErrorDescription(var ErrorCode: Integer): String;
var
  str: array[1..200] of char;
  n: integer;
begin
  n:=FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, ErrorCode, 0, @str, 200, nil);
  result:=StringReplace(Copy(str, 1, n), #13#10, ' ', [rfReplaceAll]);

  Exit;
  case ErrorCode of
    10013: Result:='Permission denied';
    10048: Result:='Address already in use.';
    10049: Result:='Cannot assign requested address.';
    10047: Result:='Address family not supported by protocol family.';
    10037: Result:='Operation already in progress.';
    10053: Result:='Software caused connection abort.';
    10061: Result:='Connection refused.';
    10054: Result:='Connection reset by peer.';
    10039: Result:='Destination address required.';
    10014: Result:='Bad address.';
    10064: Result:='Host is down.';
    10065: Result:='No route to host.';
    10036: Result:='Operation now in progress.';
    10004: Result:='Interrupted function call.';
    10022: Result:='Invalid argument.';
    10056: Result:='Socket is already connected.';
    10024: Result:='Too many open files.';
    10040: Result:='Message too long.';
    10050: Result:='Network is down.';
    10052: Result:='Network dropped connection on reset.';
    10051: Result:='Network is unreachable.';
    10055: Result:='No buffer space available.';
    10042: Result:='Bad protocol option.';
    10057: Result:='Socket is not connected.';
    10038: Result:='Socket operation on non-socket.';
    10045: Result:='Operation not supported.';
    10046: Result:='Protocol family not supported.';
    10067: Result:='Too many processes.';
    10043: Result:='Protocol not supported.';
    10041: Result:='Protocol wrong type for socket.';
    10058: Result:='Cannot send after socket shutdown.';
    10044: Result:='Socket type not supported.';
    10060: Result:='Connection timed out.';
    10035: Result:='Resource temporarily unavailable.';
    11001: Result:='Host not found.';
    10091: Result:='Network subsystem is unavailable.';
    10092: Result:='WINSOCK.DLL version out of range.';
    10094: Result:='Graceful shutdown in progress.';
    11003: Result:='This is a non-recoverable error.';
    11004: Result:='Valid name, no data record of requested type.';
  else
    Result:=IntToStr(ErrorCode);
  end;
end;

{*******************Удалить-не удалить?********************}
{function GetIPAddress(name: string): string;
var
  WSAData: TWSAData;
  p: PHostEnt;
const
  WINSOCK_VERSION = $0101;
begin
  WSAStartup(WINSOCK_VERSION, WSAData);
  p := GetHostByName(PChar(name));
  try
    Result := inet_ntoa(PInAddr(p.h_addr_list^)^);
  except
    Result := 'бла-бла';
  end;
  WSACleanup;
end;
{*******************Удалить-не удалить?********************}

//  LoadLibrary
// Процедуры шифрования
// Используется библиотека libeay32.dll (OpenSSL)
//
//procedure RC4_set_key(var RC4_key: RC4_KEY_ST; len: cardinal; data: PChar); cdecl; external 'libeay32.dll';
//procedure RC4(var RC4_key: RC4_KEY_ST; len: longint; indata: PChar; outdata: PChar); cdecl; external 'libeay32.dll';

procedure EncryptTextDll(var Text: string; Password: string);
var
  enc_str: array of char;
  s: string;
  RC4_set_key: TRC4_set_key;
  RC4: TRC4;
  key: RC4_KEY_ST;
  h: THandle;
begin
  s:=Trim(Text);
  h:=LoadLibrary('libeay32.dll');
  //s2:=IntToStr(h);
  if h=0 then Exit;
  @RC4_set_key:=GetProcAddress(h, 'RC4_set_key');
  @RC4:=GetProcAddress(h, 'RC4');
  {$IFDEF DEBUG}
  Text:=CodeStringBase64(s);
  Exit;
  {$ENDIF}
  RC4_set_key(key, Length(Password), PChar(Password));
  SetLength(enc_str, Length(s));
  RC4(key, Length(s), PChar(s), PChar(enc_str));
  Text:=CodeStringBase64(String(enc_str));
  FreeLibrary(h);
end;

procedure DecryptTextDll(var Text: string; Password: string);
var
  enc_str: array of char;
  s: string;
  key: RC4_KEY_ST;
  RC4_set_key: TRC4_set_key;
  RC4: TRC4;
  h: THandle;
begin
  Text:=Trim(Text);
  if ThisIsBase64(Text) then
    s:=DecodeStringBase64(Text)
  else Exit;
  h:=LoadLibrary('libeay32.dll');
  if h=0 then Exit;
  RC4_set_key:=GetProcAddress(h, 'RC4_set_key');
  RC4:=GetProcAddress(h, 'RC4');
  {$IFDEF DEBUG}
  Text:=s;
  Exit;
  {$ENDIF}
  RC4_set_key(key, Length(Password), PChar(Password));
  SetLength(enc_str, Length(s));
  RC4(key, Length(s), PChar(s), PChar(enc_str));
  Text:=String(enc_str);
  FreeLibrary(h);
end;

// Процедуры шифрования
// Используется модуль RC4.pas
procedure EncryptText(var Text: string; Password: string);
var
  enc_str: array of char;
  s: string;
  RC4_Data: TRC4Data;
begin
  s:=Trim(Text);
  if Length(s)=0 then Exit;
  {$IFDEF DEBUG}
  Text:=CodeStringBase64(s);
  Exit;
  {$ENDIF}
  RC4Init(RC4_Data, PChar(Password), Length(Password));
  SetLength(enc_str, Length(s));
  RC4Crypt(RC4_Data, PChar(s), PChar(enc_str), Length(s));
  Text:=CodeStringBase64(String(enc_str));
end;

procedure DecryptText(var Text: string; Password: string);
var
  enc_str: array of char;
  s: string;
  RC4_Data: TRC4Data;
begin
  Text:=Trim(Text);
  if ThisIsBase64(Text) then s:=DecodeStringBase64(Text) else Exit;
  if Length(s)=0 then Exit;
  {$IFDEF DEBUG}
  Text:=s;
  Exit;
  {$ENDIF}
  RC4Init(RC4_Data, PChar(Password), Length(Password));
  SetLength(enc_str, Length(s));
  RC4Crypt(RC4_Data, PChar(s), PChar(enc_str), Length(s));
  Text:=String(enc_str);
end;

// Копирует один файл в другой
function CopyFile(FileNameSrc, FileNameDst: string): boolean;
var
  fss, fsd: TFileStream;
  buf: array[1..2048] of byte;
  i: integer;
begin
  Result:=False;
  fss:=nil;
  fsd:=nil;
  try
    fss:=TFileStream.Create(FileNameSrc, fmOpenRead);
    fsd:=TFileStream.Create(FileNameDst, fmCreate);
    repeat
      i:=fss.Read(buf, SizeOf(buf));
      fsd.Write(buf, i);
    until i<=0;
    Result:=true;
  finally
    fsd.Free();
    fss.Free();
  end;
end;

// Парсит строку с пробелами, с учетом двойных кавычек (")
// bAddEmpty - признак добавления пустых строк
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

function ParamFromStr(s: string; ParamNum: integer): string;
var
  sa: TStringArray;
begin
  Result:='';
  sa:=ParseStr(s);
  if Length(sa)<ParamNum then Exit;
  Result:=sa[ParamNum];
end;

// Возвращает имя пользователя windows
function GetWinUserName(): string;
var
  lpBuffer: PChar;
  n: cardinal;
begin
  n:=20;
  lpBuffer:=StrAlloc(n);
  GetUserName(lpBuffer, n);
  result := String(lpBuffer);
end;

// Возвращает имя компьютера
function GetWinCompName(): string;
var
  lpBuffer: PChar;
  n: cardinal;
begin
  n:=20;
  lpBuffer:=StrAlloc(n);
  GetComputerName(lpBuffer, n);
  result := String(lpBuffer);
end;

function GetWinVersion(): string;
var
  dwVersion: DWORD;
  lw: WORD;
begin
  dwVersion := GetVersion();
  lw:=Word(dwVersion);
  Result := ''+IntToStr(Byte(lw))+'.'+IntToStr(HiByte(lw))+'.'+IntToStr(HiWord(dwVersion));
end;  

// Нормализует строку
function Norm(s: string): string;
begin
  if (Pos(' ', s)=0) and (s<>'') then result:=s
  else
  begin
    result:='"'+StringReplace(s, '"', '""', [rfReplaceAll])+'"';
  end;
end;

// Parse proxy URL string
{function ParseProxyStr(const ProxyStr: string; var ProxyHost, ProxyPort, ProxyType: string): boolean;
var
  s, s2: string;
  pUser, pPass: string;
  i, i2: integer;
begin
  result:=true;
  s:=LowerCase(ProxyStr);
  ProxyPort:='3128';
  ProxyHost:='';
  ProxyType:='';
  pUser:='';
  pPass:='';

  // Proxy type
  i:=Pos('://', s);
  if i>=0 then
  begin
    s2:=Copy(s, 1, i-1);
    if Pos(s2+':', 'http:https:socks:socks5:')>=0 then
    begin
      ProxyType:=UpperCase(s2);
    end
    else
    begin
      ProxyType:='HTTP';
    end;
  end;

  // Username & password
  s:=Copy(s, i+1, maxint);
  i:=Pos(':', s);
  i2:=Pos('@', s);
  if i<i2 then
  begin
  end;

  // Host & port
  s:=Copy(s, i+1, maxint);
  ProxyHost:=s;
  i:=Pos(':', s);
  if i>=0 then
  begin
    ProxyHost:=Copy(s, 1, i-1);
    ProxyPort:=Copy(s, i+1, maxint);
  end;
end;}

function ParseProxyURL(const ProxyURL: string; var Proto, Host, Port, User, Pass: string): boolean;
var
  Path, Para: string;
begin
  synautil.ParseURL(ProxyURL, Proto, User, Pass, Host, Port, Path, Para);
  result:=true;
end;

function ComposeProxyURL(Host, Port, Proto, User, Pass: string): string;
begin
  result:='';
  if Length(Host)=0 then Exit;

  if Length(Proto)>0 then
  begin
    result:=result+LowerCase(Proto)+'://';
  end;

  if Length(User)>0 then
  begin
    result:=result+Trim(User);
    if Length(Pass)>0 then
    begin
      result:=result+':'+Trim(Pass);
    end;
    result:=result+'@';
  end;

  result:=result+Trim(LowerCase(Host));

  if Length(Port)>0 then
  begin
    result:=result+':'+Trim(Port);
  end;

end;



end.
