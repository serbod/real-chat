unit Base64;

interface
uses
  SysUtils;

Const
  base64ABC='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-';
Type
  TBase64 = Record
    ByteArr  : Array [0..2] Of Byte;
    ByteCount:Byte;
  End;

Function CodeBase64(Base64:TBase64):String;
Function DecodeBase64(StringValue:String):TBase64;
procedure CodeFile(InFileName, OutFileName: string);
procedure DecodeFile(InFileName, OutFileName: string);
function CodeStringBase64(InString: string): string;
function DecodeStringBase64(InString: string): string;
function ThisIsBase64(Text: string): boolean;

implementation

Function CodeBase64(Base64:TBase64):String;
Var
  N,M:Byte;
  Dest, Sour:Byte;
  NextNum:Byte;// флаг-счетчик для начала работы со следующим 6-ти битным числом
  Temp:Byte;   //вспомогательная переменная используется для проверки старшего байта
             //8-ми битного исходного числа
Begin
  Result:='';
  NextNum:=1;
  Dest:=0;
  For N:=0 To 2 Do
  Begin
    Sour:=Base64.ByteArr[N];
    For M:=0 To 7 Do
    Begin
      Temp:=Sour;
      Temp:=Temp SHL M;
      Dest:=Dest SHL 1;
      If (Temp And 128) = 128 Then Dest:=Dest Or 1;
      Inc(NextNum);
      If NextNum > 6 Then
      Begin
        Result:=Result+base64ABC[Dest+1];
        NextNum:=1;
        Dest:=0;
      End;
    End;
  End;
  If Base64.ByteCount < 3 Then
    For N:=0 To (2 - Base64.ByteCount) Do Result[4-N]:='=';
End;

Function DecodeBase64(StringValue:String):TBase64;
Var
  M,N:Integer;
  Dest, Sour:Byte;
  NextNum:Byte;   //флаг-счетчик перехода к следующему 8-ми битному байту
  CurPos:Byte;    //текущая позиция в массиве TBase64.ByteArr обрабатываемого
                 //8-ми битного байта-приемника
Begin
  CurPos:=0;
  Dest:=0;
  NextNum:=1;
  FillChar(Result,SizeOf(Result),#0);
  if Trim(StringValue)='' then Exit;
  For N:=1 To 4 Do
  Begin
    For M:=0 To 5 Do
    Begin
      If StringValue[N]='=' Then Sour:=0
      Else Sour:=Pos(StringValue[N],base64ABC)-1;
      Sour:=Sour SHL M;
      Dest:=Dest SHL 1;
      If (Sour And 32)=32 Then Dest:=Dest Or 1;
      Inc(NextNum);
      If NextNum > 8 Then
      Begin
        NextNum:=1;
        Result.ByteArr[CurPos]:=Dest;
        If StringValue[N]='=' Then Result.ByteArr[CurPos]:=0
        Else Result.ByteCount:=CurPos+1;
        Inc(CurPos);
        Dest:=0;
      End;
    End;
  End;
End;

procedure CodeFile(InFileName, OutFileName: string);
Const
  Base64MaxLength = 72;
Var
  hFile, iFileLength:Integer;
  base64String:String;
  base64File:TextFile;
  Base64:TBase64;
  Buf:Array[0..2] Of Byte;
begin
  base64String:='';
  hFile:=FileOpen(InFileName,fmOpenReadWrite);
  iFileLength := FileSeek(hFile,0,2);
  if iFileLength > (1024*1024) then Exit;
  FileSeek(hFile,0,0);
  AssignFile(base64File,OutFileName);
  Rewrite(base64File);
  FillChar(Buf,SizeOf(Buf),#0);
  Repeat
    Base64.ByteCount:=FileRead(hFile,Buf,SizeOf(Buf));
    Move(Buf, Base64.ByteArr, SizeOf(Buf));
    base64String:=base64String+CodeBase64(Base64);
    If Length(base64String)=Base64MaxLength Then
    Begin
      Writeln(base64File, base64String);
      base64String:='';
    End;
  Until Base64.ByteCount < 3;

  Writeln(base64File,base64String);
  CloseFile(base64File);
  FileClose(hFile);
end;

procedure DecodeFile(InFileName, OutFileName: string);
Var
  base64File:TextFile;
  BufStr:String;
  base64String:String;
  Base64:TBase64;
  hFile:Integer;
begin
  AssignFile(base64File,InFileName);
  Reset(base64File);
  hFile:=FileCreate(OutFileName);
  While Not EOF(base64File) Do
  Begin
    Readln(base64File, BufStr);
    While Length(BufStr) > 0 Do
    Begin
      base64String:=Copy(BufStr,1,4);
      Delete(BufStr,1,4);
      Base64:=DecodeBase64(base64String);
      FileWrite(hFile, Base64.ByteArr, Base64.ByteCount);
    End;
  End;
  FileClose(hFile);
  CloseFile(base64File);
end;

function CodeStringBase64(InString: string): string;
Const
  Base64MaxLength = 72;
Var
  i, c, n, l: integer;
  Base64:TBase64;
  Buf:Array[0..2] Of Byte;
begin
  result:='';
  n:=1;
  l:=Length(InString);
  Repeat
    c:=3;
    if (n+3) > l then c:=l-n+1;
    for i:=0 to c-1 do
      Base64.ByteArr[i]:=byte(InString[n+i]);
    //Base64.ByteArr:=Copy(InString, n, c);
    Inc(n, c);
    Base64.ByteCount:=c;
    result:=result+CodeBase64(Base64);
    {If Length(base64String)=Base64MaxLength Then
    Begin
      Writeln(base64File, base64String);
      base64String:='';
    End;}
  Until Base64.ByteCount < 3;
end;

function DecodeStringBase64(InString: string): string;
Const
  Base64MaxLength = 72;
Var
  i, c, n, l: integer;
  Base64:TBase64;
  BufStr, B64Str: string;
begin
  result:='';
  n:=1;
  c:=4;
  l:=Length(InString);
  //BufStr:=InString;
  //while Length(BufStr) > 0 do
  while c > 0 do
  begin
    //B64Str:=Copy(BufStr,1,4);
    //Delete(BufStr,1,4);
    c:=4;
    if (n+4) > l then c:=l-n+1;
    b64Str:=Copy(InString,n,c);
    Inc(n, c);
    Base64:=DecodeBase64(B64Str);
    for i:=0 to Base64.ByteCount-1 do
      result:=result+Char(Base64.ByteArr[i]);
  end;
end;

function ThisIsBase64(Text: string): boolean;
var
  i, l: integer;
  Filter: string;
begin
  result:=false;
  Filter:=base64ABC+'=';
  l:=Length(Text);
  if l mod 4 > 0 then Exit;
  for i:=1 to l do
    if Pos(Text[i], Filter)<=0 then Exit;
  result:=true;
end;

end.
