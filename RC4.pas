{
***************************************************
* A binary compatible RC4 implementation          *
* written by Dave Barton (davebarton@bigfoot.com) *
***************************************************
* Stream encryption                               *
* Variable size key - up to 2048bit               *
***************************************************
}
unit RC4;

interface
uses
  Windows, Sysutils;

type
  TRC4Data= record
    Key: array[0..255] of byte;         { current key }
    OrgKey: array[0..255] of byte;      { original key }
  end;

function RC4SelfTest: boolean;
  { performs a self test on this implementation }
procedure RC4Init(var Data: TRC4Data; Key: pointer; Len: integer);
  { initializes the TRC4Data structure with the key information }
procedure RC4Burn(var Data: TRC4Data);
  { erases all information about the key }

procedure RC4Crypt(var Data: TRC4Data; InData, OutData: pointer; Len: integer);
  { encrypts/decrypts Len bytes of data }

procedure RC4Reset(var Data: TRC4Data);
  { resets the key information }


{******************************************************************************}
implementation

function RC4SelfTest;
const
  InBlock: array[0..4] of byte= ($dc,$ee,$4c,$f9,$2c);
  OutBlock: array[0..4] of byte= ($f1,$38,$29,$c9,$de);
  Key: array[0..4] of byte= ($61,$8a,$63,$d2,$fb);
var
  Block: array[0..4] of byte;
  Data: TRC4Data;
begin
  RC4Init(Data,@Key,5);
  RC4Crypt(Data,@InBlock,@Block,5);
  Result:= CompareMem(@Block,@OutBlock,5);
  RC4Reset(Data);
  RC4Crypt(Data,@Block,@Block,5);
  Result:= Result and CompareMem(@Block,@InBlock,5);
  RC4Burn(Data);
end;

procedure RC4Init(var Data: TRC4Data; Key: pointer; Len: integer);
var
  xKey: array[0..255] of byte;
  i, j: integer;
  t: byte;
begin
  if (Len<= 0) or (Len> 256) then
    raise Exception.Create('RC4: Invalid key length');
  for i:= 0 to 255 do
  begin
    Data.Key[i]:= i;
    xKey[i]:= PByte(integer(Key)+(i mod Len))^;
  end;
  j:= 0;
  for i:= 0 to 255 do
  begin
    j:= (j+Data.Key[i]+xKey[i]) and $FF;
    t:= Data.Key[i];
    Data.Key[i]:= Data.Key[j];
    Data.Key[j]:= t;
  end;
  Move(Data.Key,Data.OrgKey,256);
end;

procedure RC4Burn(var Data: TRC4Data);
begin
  FillChar(Data,Sizeof(Data),$FF);
end;

procedure RC4Crypt(var Data: TRC4Data; InData, OutData: pointer; Len: integer);
var
  t, i, j: byte;
  k: integer;
begin
  i:= 0;
  j:= 0;
  for k:= 0 to Len-1 do
  begin
    i:= (i+1) and $FF;
    j:= (j+Data.Key[i]) and $FF;
    t:= Data.Key[i];
    Data.Key[i]:= Data.Key[j];
    Data.Key[j]:= t;
    t:= (Data.Key[i]+Data.Key[j]) and $FF;
    PByteArray(OutData)[k]:= PByteArray(InData)[k] xor Data.Key[t];
  end;
end;

procedure RC4Reset(var Data: TRC4Data);
begin
  Move(Data.OrgKey,Data.Key,256);
end;

end.
