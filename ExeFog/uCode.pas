
{**************************************************************}
{                                                              }
{ This is a part of Morphine v2.7 by Holy_Father && Ratter/29A }
{                                                              }
{**************************************************************}

unit uCode;

interface

procedure GenerateRubbishCode(AMem: Pointer; ASize, AVirtAddr: Cardinal); stdcall;

implementation

const
  REG_EAX = 0;
  REG_ECX = 1;
  REG_EDX = 2;
  REG_EBX = 3;
  REG_ESP = 4;
  REG_EBP = 5;
  REG_ESI = 6;
  REG_EDI = 7;
  REG_NON = 255;

  Reg8Count  = 8;
  Reg16Count = 8;
  Reg32Count = 8;

type
  PByte = ^Byte;
  PWord = ^Word;
  PCardinal = ^Cardinal;

procedure GenerateRandomBuffer(ABuf: PByte; ASize: Cardinal);
var
  LI:Integer;
begin
  for LI:= 0 to ASize-1 do
  begin
    ABuf^:= Random($FE)+1;
    Inc(ABuf);
  end;
end;

procedure PutRandomBuffer(var AMem: PByte; ASize: Cardinal);
begin
  GenerateRandomBuffer(AMem, ASize);
  Inc(AMem, ASize);
end;

function RandomReg32All: Byte;
begin
  Result:= Random(Reg32Count);
end;

function RandomReg16All: Byte;
begin
  Result:= Random(Reg16Count);
end;

function RandomReg8ABCD: Byte;
begin
  Result:= Random(Reg8Count);
end;

function RandomReg32Esp: Byte;
begin
  Result:= Random(Reg32Count-1);
  if Result = REG_ESP then Result:= 7;
end;

function RandomReg32EspEbp: Byte;
begin
  Result:= Random(Reg32Count-2);
  if Result = REG_ESP then
    Result:= 6
  else
    if Result = REG_EBP then Result:= 7;
end;

procedure ThrowTheDice(var ADice: Cardinal; ASides: Cardinal = 6); overload;
begin
  ADice:= Random(ASides) + 1;
end;

procedure ThrowTheDice(var ADice: Word; ASides: Word = 6); overload;
begin
  ADice:= Random(ASides) + 1;
end;

procedure ThrowTheDice(var ADice: Byte; ASides: Byte = 6); overload;
begin
  ADice:= Random(ASides) + 1;
end;

function Bswap(var AMem: PByte; AReg: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $0F;
  Inc(AMem);
  AMem^:= $C8 + AReg;
  Inc(AMem);
end;

function Pushad(var AMem: PByte): Byte;
begin
  Result:= 1;
  AMem^:= $60;
  Inc(AMem);
end;

function Stosd(var AMem: PByte): Byte;
begin
  Result:= 1;
  AMem^:= $AB;
  Inc(AMem);
end;

function Movsd(var AMem:PByte): Byte;
begin
  Result:= 1;
  AMem^:= $A5;                
  Inc(AMem);
end;

function Ret(var AMem: PByte): Byte;
begin
  Result:= 1;
  AMem^:= $C3;
  Inc(AMem);
end;

procedure Ret16(var AMem: PByte; AVal: Word);
begin
  AMem^:= $C2;
  Inc(AMem);
  PWord(AMem)^:= AVal;
  Inc(AMem,2);
end;

procedure RelJmpAddr32(var AMem: PByte; AAddr: Cardinal);
begin
  AMem^:= $E9;
  Inc(AMem);
  PCardinal(AMem)^:= AAddr;
  Inc(AMem,4);
end;

procedure RelJmpAddr8(var AMem: PByte; AAddr: Byte);
begin
  AMem^:= $EB;
  Inc(AMem);
  AMem^:= AAddr;
  Inc(AMem);
end; 

procedure RelJzAddr32(var AMem: PByte; AAddr: Cardinal);
begin
  AMem^:= $0F;
  Inc(AMem);
  AMem^:= $84;                       
  Inc(AMem);
  PCardinal(AMem)^:= AAddr;
  Inc(AMem,4);
end;

procedure RelJnzAddr32(var AMem: PByte; AAddr: Cardinal);
begin
  AMem^:= $0F;
  Inc(AMem);
  AMem^:= $85;
  Inc(AMem);
  PCardinal(AMem)^:= AAddr;
  Inc(AMem,4);
end;

procedure RelJbAddr32(var AMem: PByte; AAddr: Cardinal);
begin
  AMem^:= $0F;
  Inc(AMem);
  AMem^:= $82;
  Inc(AMem);
  PCardinal(AMem)^:= AAddr;
  Inc(AMem,4);
end;

procedure RelJzAddr8(var AMem: PByte; AAddr: Byte);
begin
  AMem^:= $74;
  Inc(AMem);
  AMem^:= AAddr;
  Inc(AMem);
end;

procedure RelJnzAddr8(var AMem: PByte; AAddr: Byte);
begin
  AMem^:= $75;
  Inc(AMem);
  AMem^:= AAddr;
  Inc(AMem);
end;

function JmpRegMemIdx8(var AMem: PByte; AReg, AIdx: Byte): Byte;
begin
  Result:= 3;
  AMem^:= $FF;
  Inc(AMem);
  AMem^:= $60+AReg;
  InC(AMem);
  if AReg = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;
    Inc(AMem);
  end;
  AMem^:= AIdx;
  Inc(AMem);
end;

function PushRegMem(var AMem: PByte; AReg: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $FF;
  Inc(AMem);
  if AReg = REG_EBP then
  begin
    Inc(Result);
    AMem^:=$75;
    Inc(AMem);
    AMem^:=$00;
  end else AMem^:= $30 + AReg;
  Inc(AMem);
  if AReg = REG_ESP then
  begin
    Inc(Result);
    AMem^:=$24;                       
    Inc(AMem);
  end;
end;

procedure PushReg32(var AMem: PByte; AReg: Byte);
begin
  AMem^:= $50 + AReg;
  Inc(AMem);
end;

function PushReg32Rand(var AMem: PByte): Byte;
begin
  Result:= RandomReg32Esp;
  PushReg32(AMem,Result);
end;

procedure PopReg32(var AMem: PByte; AReg: Byte);
begin
  AMem^:= $58 + AReg;
  Inc(AMem);
end;

function PopReg32Idx(var AMem: PByte; AReg: Byte; AIdx: Cardinal): Byte;
begin
  Result:= 6;
  AMem^:= $8F;
  Inc(AMem);
  AMem^:= $80 + AReg;
  Inc(AMem);
  if AReg = REG_ESP then
  begin
    AMem^:= $24;
    Inc(AMem);
    Inc(Result);
   end;
   PCardinal(AMem)^:= AIdx;
   InC(AMem,4);
end;

procedure RelCallAddr(var AMem: PByte; AAddr: Cardinal);
begin
  AMem^:= $E8;
  Inc(AMem);
  PCardinal(AMem)^:= AAddr;
  Inc(AMem,4);
end;

procedure MovReg32Reg32(var AMem: PByte; AReg1, AReg2: Byte);
begin
  AMem^:= $89;
  Inc(AMem);
  AMem^:= AReg2*8 + AReg1 + $C0;
  Inc(AMem);
end;

procedure AddReg32Reg32(var AMem: PByte; AReg1, AReg2: Byte);
begin
  AMem^:= $01;
  Inc(AMem);
  AMem^:= AReg2*8 + AReg1 + $C0;
  Inc(AMem);
end;

function AddReg32RegMem(var AMem: PByte; AReg1, AReg2: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $03;
  Inc(AMem);
  if AReg2 = REG_EBP then
  begin
    Inc(Result);
    AMem^:= AReg1*8 + $45;
    Inc(AMem);
    AMem^:= $00;
  end else
    AMem^:= AReg1*8 + AReg2;
  Inc(AMem);
  if AReg2 = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;                       
    Inc(AMem);
  end;
end;

function AddRegMemReg32(var AMem: PByte; AReg1, AReg2: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $01;
  Inc(AMem);
  if AReg1 = REG_EBP then
  begin
    Inc(Result);
    AMem^:= AReg2*8 + $45;
    Inc(AMem);
    AMem^:= $00;
  end else
    AMem^:= AReg2*8 + AReg1;
  Inc(AMem);
  if AReg1 = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;
    Inc(AMem);
  end;
end;

procedure AddReg32Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $83;                          
  Inc(AMem);
  AMem^:= $C0 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure MovReg32Num32(var AMem: PByte; AReg: Byte; ANum: Cardinal);
begin
  AMem^:= $B8 + AReg;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem,4);
end;

function MovReg32IdxNum32(var AMem: PByte; AReg: Byte; AIdx, ANum: Cardinal): Byte;
begin
  Result:= 10;
  AMem^:= $C7;
  Inc(AMem);
  AMem^:= $80 + AReg;
  Inc(AMem);
  if AReg = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;
    Inc(AMem);
  end;
  PCardinal(AMem)^:= AIdx;
  Inc(AMem,4);
  PCardinal(AMem)^:= ANum;
  Inc(AMem,4);
end;

procedure MovReg32Reg32IdxNum32(var AMem: PByte; AReg1, AReg2: Byte; ANum: Cardinal);
begin
  if AReg1 = REG_ESP then
  begin
    AReg1:= AReg2;
    AReg2:= REG_ESP;
  end;
  if AReg2 = REG_EBP then
  begin
    AReg2:= AReg1;
    AReg1:= REG_EBP;
  end;
  AMem^:= $C7;
  Inc(AMem);
  AMem^:= $04;
  Inc(AMem);
  AMem^:= AReg1*8 + AReg2;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;            
  Inc(AMem,4);
end;

function MovReg32RegMem(var AMem: PByte; AReg1, AReg2: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $8B;
  Inc(AMem);
  if AReg2 = REG_EBP then
  begin
    Inc(Result);
    AMem^:= AReg1*8 + $45;
    Inc(AMem);
    AMem^:= $00;
  end else
    AMem^:= AReg1*8 + AReg2;
  Inc(AMem);
  if AReg2 = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;
    Inc(AMem);
  end;
end;

function MovRegMemReg32(var AMem: PByte; AReg1, AReg2: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $89;                           //mov
  Inc(AMem);
  if AReg1 = REG_EBP then
  begin
    Inc(Result);
    AMem^:= AReg2*8 + $45;               
    Inc(AMem);
    AMem^:= $00;
  end else
    AMem^:= AReg2*8 + AReg1;
  Inc(AMem);
  if AReg1 = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;
    Inc(AMem);
  end;
end;

function MovReg32RegMemIdx8(var AMem: PByte; AReg1, AReg2, AIdx: Byte): Byte;
begin
  Result:= 3;
  AMem^:= $8B;
  Inc(AMem);
  AMem^:= AReg1*8 + AReg2 + $40;
  Inc(AMem);
  if AReg2 = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;
    Inc(AMem);
  end;
  AMem^:= AIdx;
  Inc(AMem);
end;

procedure PushNum32(var AMem: PByte; ANum: Cardinal);
begin
  AMem^:= $68;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem,4);
end;

procedure JmpReg32(var AMem: PByte; AReg: Byte);
begin
  AMem^:= $FF;
  Inc(AMem);
  AMem^:= $E0 + AReg;
  Inc(AMem);
end;

procedure CallReg32(var AMem: PByte; AReg: Byte);
begin
  AMem^:= $FF;
  Inc(AMem);
  AMem^:= $D0 + AReg;
  Inc(AMem);
end;

procedure Cld(var AMem: PByte);
begin
  AMem^:= $FC;
  Inc(AMem);
end;

procedure Std(var AMem: PByte);
begin
  AMem^:= $FD;
  Inc(AMem);
end;

procedure Nop(var AMem: PByte);
begin
  AMem^:= $90;
  Inc(AMem);
end;

procedure Stc(var AMem: PByte);
begin
  AMem^:= $F9;
  Inc(AMem);
end;

procedure Clc(var AMem: PByte);
begin
  AMem^:= $F8;
  Inc(AMem);
end;

procedure Cmc(var AMem: PByte);
begin
  AMem^:= $F5;
  Inc(AMem);
end;

procedure XchgReg32Rand(var AMem: PByte);
begin
  AMem^:= $87;
  Inc(AMem);
  AMem^:= $C0 + RandomReg32All*9;          
  Inc(AMem);
end;

function XchgReg32Reg32(var AMem: PByte; AReg1, AReg2: Byte): Byte;
begin
  if AReg2 = REG_EAX then
  begin
    AReg2:= AReg1;
    AReg1:= REG_EAX;
  end;
  if AReg1 = REG_EAX then
    ThrowTheDice(Result, 2)
  else
    Result:= 2;
  if Result = 2 then
  begin
    AMem^:= $87;
    Inc(AMem);
    AMem^:= $C0 + AReg2*8 + AReg1;
  end else
    AMem^:= $90 + AReg2;
  Inc(AMem);
end;

procedure MovReg32Rand(var AMem: PByte);
begin
  AMem^:= $8B;
  Inc(AMem);
  AMem^:= $C0 + RandomReg32All*9;
  Inc(AMem);
end;

procedure IncReg32(var AMem: PByte; AReg: Byte);
begin
  AMem^:= $40 + AReg;                     
  Inc(AMem);
end;

procedure DecReg32(var AMem: PByte; AReg: Byte);
begin
  AMem^:= $48 + AReg;
  Inc(AMem);
end;

function IncReg32Rand(var AMem: PByte): Byte;
begin
  Result:= RandomReg32All;
  IncReg32(AMem, Result);
end;

function DecReg32Rand(var AMem: PByte): Byte;
begin
  Result:= RandomReg32All;
  DecReg32(AMem, Result);
end;

function LeaReg32Reg32(var AMem: PByte; AReg1, AReg2: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $8D;
  Inc(AMem);
  if AReg2 = REG_EBP then
  begin
   Inc(Result);
   AMem^:= AReg1*8 + $45;
   Inc(AMem);
   AMem^:= $00;
  end else
    AMem^:= AReg1*8 + AReg2;
  Inc(AMem);
  if AReg2 = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;
    Inc(AMem);
  end;
end;

function LeaReg32Reg32MemIdx8(var AMem: PByte; AReg1, AReg2, AIdx: Byte): Byte;
begin
  Result:= 3;
  AMem^:= $8D;
  Inc(AMem);
  AMem^:= $40 + AReg1*8 + AReg2;
  Inc(AMem);
  if AReg2 = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;
    Inc(AMem);
  end;
  AMem^:= AIdx;
  Inc(AMem);
end;

procedure LeaReg32Rand(var AMem: PByte);
begin
  AMem^:= $8D;
  Inc(AMem);
  AMem^:= $00 + RandomReg32EspEbp*9;      
  Inc(AMem);
end;

procedure LeaReg32Addr32(var AMem: PByte; AReg, AAddr: Cardinal);
begin
  AMem^:= $8D;
  Inc(AMem);
  AMem^:= $05 + AReg*8;
  Inc(AMem);
  PCardinal(AMem)^:= AAddr;
  Inc(AMem,4);
end;

procedure TestReg32Rand(var AMem: PByte);
begin
  AMem^:= $85;
  Inc(AMem);
  AMem^:= $C0 + RandomReg32All*9;
  Inc(AMem);
end;

procedure OrReg32Rand(var AMem: PByte);
begin
  AMem^:= $0B;
  Inc(AMem);
  AMem^:= $C0 + RandomReg32All*9;
  Inc(AMem);
end;

procedure AndReg32Rand(var AMem: PByte);
begin
  AMem^:= $23;
  Inc(AMem);
  AMem^:= $C0 + RandomReg32All*9;          
  Inc(AMem);
end;

procedure TestReg8Rand(var AMem: PByte);
var
  LReg8: Byte;
begin
  LReg8:= RandomReg8ABCD;
  AMem^:= $84;
  Inc(AMem);
  AMem^:= $C0 + LReg8*9;                 
  Inc(AMem);
end;

procedure OrReg8Rand(var AMem: PByte);
var
  LReg8: Byte;
begin
  LReg8:= RandomReg8ABCD;
  AMem^:= $0A;
  Inc(AMem);
  AMem^:= $C0 + LReg8*9;
  Inc(AMem);
end;

procedure AndReg8Rand(var AMem: PByte);
var
  LReg8: Byte;
begin
  LReg8:= RandomReg8ABCD;
  AMem^:= $22;
  Inc(AMem);
  AMem^:= $C0 + LReg8*9;                 
  Inc(AMem);
end;

procedure CmpRegRegNum8Rand(var AMem: PByte);
var
  LRnd: Byte;
begin
  LRnd:= Random(3);
  AMem^:= $3A + LRnd;
  Inc(AMem);
  if LRnd < 2 then
    LRnd:= Random($40) + $C0
  else
    LRnd:= Random($100);
  AMem^:= LRnd;
  Inc(AMem);
end;

function CmpReg32Reg32(var AMem: PByte; AReg1, AReg2: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $39;
  Inc(AMem);
  AMem^:= $C0 + AReg1 + AReg2*8;
  Inc(AMem);
end;

procedure CmpReg32Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $83;
  Inc(AMem);
  AMem^:= $F8 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure CmpReg32RandNum8(var AMem: PByte; AReg: Byte);
begin
  CmpReg32Num8(AMem, AReg, Random($100));
end;

procedure CmpRandReg32RandNum8(var AMem: PByte);
begin
  CmpReg32RandNum8(AMem, RandomReg32All);
end;

procedure JmpNum8(var AMem: PByte; ANum: Byte);
var
  LRnd: Byte;
begin
  LRnd:= Random(16);
  if LRnd = 16 then
    AMem^:= $EB
  else
    AMem^:= $70 + LRnd;
  Inc(AMem);
  AMem^:= ANum;                       
  Inc(AMem);
end;

procedure SubReg32Reg32(var AMem: PByte; AReg1, AReg2: Byte);
begin
  AMem^:= $29;
  Inc(AMem);
  AMem^:= AReg2*8 + AReg1 + $C0;            
  Inc(AMem);
end;

procedure SubReg32Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $83;
  Inc(AMem);
  AMem^:= $E8 + AReg;
  Inc(AMem);
  AMem^:= ANum;                         
  Inc(AMem);
end;

function SubReg32Num8Rand(var AMem: PByte; ANum: Byte): Byte;
begin
  Result:= RandomReg32All;
  SubReg32Num8(AMem, Result, ANum);
end;

function AddReg32Num8Rand(var AMem: PByte; ANum: Byte): Byte;
begin
  Result:= RandomReg32All;
  AddReg32Num8(AMem, Result, ANum);
end;

procedure SubAlNum8(var AMem: PByte; ANum: Byte);
begin
  AMem^:= $2C;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure TestAlNum8(var AMem: PByte; ANum: Byte);
begin
  AMem^:= $A8;
  Inc(AMem);
  AMem^:= ANum;                        
  Inc(AMem);
end;

procedure TestAlNum8Rand(var AMem: PByte);
begin
  TestAlNum8(AMem, Random($100));
end;

procedure SubReg8Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:=$80;
  Inc(AMem);
  AMem^:=$E8 + AReg;
  Inc(AMem);
  AMem^:=ANum;
  Inc(AMem);
end;

procedure SubReg8Num8Rand(var AMem: PByte; ANum: Byte);
var
  LReg8: Byte;
begin
  LReg8:= RandomReg8ABCD;
  SubReg8Num8(AMem, LReg8, ANum);
end;

procedure TestReg8Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $F6;
  Inc(AMem);
  AMem^:= $C0+AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure TestReg8Num8Rand(var AMem: PByte);
begin
  TestReg8Num8(AMem, RandomReg8ABCD, Random($100));
end;

procedure AddReg8Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $80;
  Inc(AMem);
  AMem^:= $C0 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure AddReg8Num8Rand(var AMem: PByte; ANum: Byte);
var
  LReg8: Byte;
begin
  LReg8:= RandomReg8ABCD;
  AddReg8Num8(AMem, LReg8, ANum);
end;

procedure AddAlNum8(var AMem: PByte; ANum: Byte);
begin
  AMem^:= $04;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure FNop(var AMem: PByte);
begin
  AMem^:= $D9;
  Inc(AMem);
  AMem^:= $D0;
  Inc(AMem);
end;

procedure OrReg16Rand(var AMem:PByte);
var
  LReg16: Byte;
begin
  LReg16:= RandomReg16All;
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $0B;
  Inc(AMem);
  AMem^:= $C0 + LReg16*9;
  Inc(AMem);
end;

procedure TestReg16Rand(var AMem: PByte);
var
  LReg16: Byte;
begin
  LReg16:= RandomReg16All;
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $85;
  Inc(AMem);
  AMem^:= $C0 + LReg16*9;                 
  Inc(AMem);
end;

procedure AndReg16Rand(var AMem: PByte);
var
  LReg16: Byte;
begin
  LReg16:= RandomReg16All;
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $23;
  Inc(AMem);
  AMem^:= $C0 + LReg16*9;
  Inc(AMem);
end;

procedure Cdq(var AMem:PByte);
begin
  AMem^:= $99;
  Inc(AMem);
end;

procedure ShlReg32Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $C1;
  Inc(AMem);
  AMem^:= $E0 + AReg;
  Inc(AMem);
  AMem^:= ANum;                       
  Inc(AMem);
end;

procedure ShlReg32RandNum8FullRand(var AMem: PByte);
begin
  ShlReg32Num8(AMem, RandomReg32All, Random(8)*$20);
end;

procedure ShrReg32Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $C1;
  Inc(AMem);
  AMem^:= $E8 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure ShrReg32RandNum8FullRand(var AMem: PByte);
begin
  ShrReg32Num8(AMem, RandomReg32All, Random(8)*$20);
end;

procedure SalReg32Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $C1;
  Inc(AMem);
  AMem^:= $F0 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure SalReg32RandNum8FullRand(var AMem: PByte);
begin
  SalReg32Num8(AMem, RandomReg32All, Random(8)*$20);
end;

procedure SarReg32Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $C1;
  Inc(AMem);
  AMem^:= $F8 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure SarReg32RandNum8FullRand(var AMem: PByte);
begin
  SarReg32Num8(AMem, RandomReg32All, Random(8)*$20);
end;

procedure RolReg8Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $C0;
  Inc(AMem);
  AMem^:= $C0 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure RolReg8RandNum8FullRand(var AMem: PByte);
begin
  RolReg8Num8(AMem, RandomReg8ABCD, Random($20)*8);
end;

procedure RorReg8Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $C0;
  Inc(AMem);
  AMem^:= $C8 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure RorReg8RandNum8FullRand(var AMem: PByte);
begin
  RorReg8Num8(AMem, RandomReg8ABCD, Random($20)*8);
end;

procedure RolReg32Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $C1;
  Inc(AMem);
  AMem^:= $C0 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure RolReg32RandNum8FullRand(var AMem: PByte);
begin
  RolReg32Num8(AMem, RandomReg32All, Random(8)*$20);
end;

procedure RorReg32Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $C1;
  Inc(AMem);
  AMem^:= $C8 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure RorReg32RandNum8FullRand(var AMem: PByte);
begin
  RorReg32Num8(AMem, RandomReg32All, Random(8)*$20);
end;

procedure TestAxNum16(var AMem: PByte; ANum: Word);
begin
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $A9;
  Inc(AMem);
  PWord(AMem)^:= ANum;                   
  Inc(AMem,2);
end;

procedure TestAxNum16Rand(var AMem: PByte);
begin
  TestAxNum16(AMem, Random($10000));
end;

procedure CmpAxNum16(var AMem: PByte; ANum: Word);
begin
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $3D;
  Inc(AMem);
  PWord(AMem)^:= ANum;                  
  Inc(AMem,2);
end;

procedure CmpAxNum16Rand(var AMem: PByte);
begin
  TestAxNum16(AMem, Random($10000));
end;

procedure PushNum8(var AMem: PByte; ANum: Byte);
begin
  AMem^:= $6A;
  Inc(AMem);
  AMem^:= ANum;                         
  Inc(AMem);
end;

procedure PushNum8Rand(var AMem: PByte);
begin
  PushNum8(AMem, Random($100));
end;

function XorRand(var AMem: PByte): Word;
var
  LRnd: Byte;
  LRes: PWord;
begin
  LRes:= Pointer(AMem);
  LRnd:= Random(5);
  AMem^:= $30 + LRnd;
  Inc(AMem);
  if LRnd = 4 then
    AMem^:= Random($100)
  else
    AMem^:= Random(7)*9 + Random(8) + 1 + $C0; 
  Inc(AMem);
  Result:= LRes^;
end;

procedure InvertXor(var AMem: PByte; AXor: Word);
begin
  PWord(AMem)^:= AXor;
  Inc(AMem,2);
end;

procedure DoubleXorRand(var AMem: PByte);
begin
  InvertXor(AMem, XorRand(AMem));
end;

function NotReg32(var AMem: PByte; AReg: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $F7;
  Inc(AMem);
  AMem^:= $D0 + AReg;
  Inc(AMem);
end;

function NegReg32(var AMem: PByte; AReg: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $F7;
  Inc(AMem);
  AMem^:= $D8 + AReg;                     
  Inc(AMem);
end;

function NotRand(var AMem: PByte): Word;
var
  LRes: PWord;
begin
  LRes:= Pointer(AMem);
  AMem^:= $F6 + Random(1);
  Inc(AMem);
  AMem^:= $D0 + Random(8);
  Inc(AMem);
  Result:= LRes^;
end;

procedure InvertNot(var AMem: PByte; ANot: Word);
begin
  PWord(AMem)^:= ANot;
  Inc(AMem,2);
end;

procedure DoubleNotRand(var AMem: PByte);
begin
  InvertNot(AMem, NotRand(AMem));
end;

function NegRand(var AMem: PByte): Word;
var
  LRes: PWord;
begin
  LRes:= Pointer(AMem);
  AMem^:= $F6 + Random(1);
  Inc(AMem);
  AMem^:= $D8 + Random(8);                 
  Inc(AMem);
  Result:= LRes^;
end;

procedure InvertNeg(var AMem: PByte; ANeg: Word);
begin
  PWord(AMem)^:= ANeg;
  Inc(AMem,2);
end;

procedure DoubleNegRand(var AMem: PByte);
begin
  InvertNeg(AMem, NegRand(AMem));
end;

procedure AddReg16Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $66;                           
  Inc(AMem);
  AMem^:= $83;
  Inc(AMem);
  AMem^:= $C0 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure AddReg16Num8Rand(var AMem: PByte; ANum: Byte);
begin
  AddReg16Num8(AMem, RandomReg16All, ANum);
end;

procedure OrReg16Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $83;
  Inc(AMem);
  AMem^:= $C8 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure OrReg16Num8Rand(var AMem: PByte; ANum: Byte);
begin
  OrReg16Num8(AMem, RandomReg16All, ANum);
end;

procedure AndReg16Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $83;
  Inc(AMem);
  AMem^:= $E0 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure AndReg16Num8Rand(var AMem: PByte; ANum: Byte);
begin
  AndReg16Num8(AMem, RandomReg16All, ANum);
end;

procedure SubReg16Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $83;
  Inc(AMem);
  AMem^:= $E8 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure SubReg16Num8Rand(var AMem: PByte; ANum: Byte);
begin
  SubReg16Num8(AMem, RandomReg16All, ANum);
end;

procedure XorReg16Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $83;
  Inc(AMem);
  AMem^:= $F0 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure XorReg16Num8Rand(var AMem: PByte; ANum: Byte);
begin
  XorReg16Num8(AMem, RandomReg16All, ANum);
end;

procedure CmpReg16Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $83;
  Inc(AMem);
  AMem^:= $F8 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure CmpReg16Num8RandRand(var AMem: PByte);
begin
  CmpReg16Num8(AMem, RandomReg16All, Random($100));
end;

procedure RolReg16Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $C1;
  Inc(AMem);
  AMem^:= $C0 + AReg;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure RolReg16RandNum8FullRand(var AMem: PByte);
begin
  RolReg16Num8(AMem, RandomReg16All, Random($10)*$10);
end;

procedure RorReg16Num8(var AMem: PByte; AReg, ANum: Byte);
begin
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $C1;
  Inc(AMem);
  AMem^:= $C1 + AReg;
  Inc(AMem);
  AMem^:= ANum;                          
  Inc(AMem);
end;

procedure RorReg16RandNum8FullRand(var AMem: PByte);
begin
  RorReg16Num8(AMem, RandomReg16All, Random($10)*$10);
end;

function XchgRand(var AMem: PByte): Word;
var
  LRes: PWord;
  LRnd: Byte;
begin
  LRes:= Pointer(AMem);
  LRnd:= Random(4);
  case LRnd of
    0,1: AMem^:= $66 + LRnd;                
    2,3: AMem^:= $86 + LRnd - 2;
  end;
  Inc(AMem);
  case LRnd of
    0,1: AMem^:= $90 + Random(8);
    2,3: AMem^:= $C0 + Random($10);
  end;
  Inc(AMem);
  Result:= LRes^;
end;

procedure InvertXchg(var AMem: PByte; AXchg: Word);
begin
  PWord(AMem)^:= AXchg;
  Inc(AMem,2);
end;

procedure DoubleXchgRand(var AMem: PByte);
begin
  InvertXchg(AMem, XchgRand(AMem));
end;

procedure LoopNum8(var AMem: PByte; ANum: Byte);
begin
  AMem^:= $E2;
  Inc(AMem);
  AMem^:= ANum;
  Inc(AMem);
end;

procedure JecxzNum8(var AMem: PByte; ANum: Byte);
begin
  AMem^:= $E3;
  Inc(AMem);
  AMem^:= ANum;                         
  Inc(AMem);
end;

procedure MovzxEcxCl(var AMem: PByte);
begin
  AMem^:= $0F;
  Inc(AMem);
  AMem^:= $B6;
  Inc(AMem);
  AMem^:= $C9;
  Inc(AMem);
end;

procedure MovReg32Reg32Rand(var AMem: PByte; AReg: Byte);
begin
  AMem^:= $8B;
  Inc(AMem);
  AMem^:= $C0 + 8*AReg + RandomReg32All;
  Inc(AMem);
end;

procedure CmpEaxNum32(var AMem: PByte; ANum: Cardinal);
begin
  AMem^:= $3D;                          
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem, 4);
end;

procedure CmpEaxNum32Rand(var AMem: PByte);
begin
  CmpEaxNum32(AMem, Random($FFFFFFFF));
end;

procedure TestEaxNum32(var AMem: PByte; ANum: Cardinal);
begin
  AMem^:= $A9;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;              
  Inc(AMem, 4);
end;

procedure TestEaxNum32Rand(var AMem: PByte);
begin
  TestEaxNum32(AMem, Random($FFFFFFFF));
end;

procedure SubEaxNum32(var AMem: PByte; ANum: Cardinal);
begin
  AMem^:= $2D;                         
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem, 4);
end;

procedure AddEaxNum32(var AMem: PByte; ANum: Cardinal);
begin
  AMem^:= $05;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem, 4);
end;

procedure AndEaxNum32(var AMem: PByte; ANum: Cardinal);
begin
  AMem^:= $25;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem, 4);
end;

procedure OrEaxNum32(var AMem: PByte; ANum: Cardinal);
begin
  AMem^:= $0D;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem, 4);
end;

procedure XorEaxNum32(var AMem: PByte; ANum: Cardinal);
begin
  AMem^:= $35;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem, 4);
end;

procedure AddReg32Num32(var AMem: PByte; AReg: Byte; ANum: Cardinal);
begin
  AMem^:= $81;
  Inc(AMem);
  AMem^:= $C0 + AReg;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem, 4);
end;

procedure OrReg32Num32(var AMem: PByte; AReg: Byte; ANum: Cardinal);
begin
  AMem^:= $81;
  Inc(AMem);
  AMem^:= $C8 + AReg;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem, 4);
end;

procedure AndReg32Num32(var AMem: PByte; AReg: Byte; ANum: Cardinal);
begin
  AMem^:= $81;
  Inc(AMem);
  AMem^:= $E0 + AReg;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem, 4);
end;

procedure SubReg32Num32(var AMem: PByte; AReg: Byte; ANum: Cardinal);
begin
  AMem^:= $81;
  Inc(AMem);
  AMem^:= $E8 + AReg;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem, 4);
end;

procedure XorReg32Num32(var AMem: PByte; AReg: Byte; ANum: Cardinal);
begin
  AMem^:= $81;
  Inc(AMem);
  AMem^:= $F0 + AReg;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem, 4);
end;

procedure XorReg32Reg32(var AMem: PByte; AReg1, AReg2: Byte);
begin
  AMem^:= $31;
  Inc(AMem);
  AMem^:= $C0+AReg2*8 + AReg1;
  Inc(AMem);
end;

function XorReg32RegMem(var AMem: PByte; AReg1, AReg2: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $33;                           
  Inc(AMem);
  if AReg2 = REG_EBP then
  begin
    Inc(Result);
    AMem^:= AReg1*8 + $45;
    Inc(AMem);
    AMem^:= $00;
  end else
    AMem^:= AReg1*8 + AReg2;
  Inc(AMem);
  if AReg2 = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;
    Inc(AMem);
  end;
end;

function XorRegMemReg32(var AMem: PByte; AReg1, AReg2: Byte): Byte;
begin
  Result:= 2;
  AMem^:= $31;                           //xor
  Inc(AMem);
  if AReg1 = REG_EBP then
  begin
    Inc(Result);
    AMem^:= AReg2*8 + $45;               
    Inc(AMem);
    AMem^:= $00;
  end else
    AMem^:= AReg2*8 + AReg1;
  Inc(AMem);
  if AReg1 = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;
    Inc(AMem);
  end;
end;

procedure CmpReg32Num32(var AMem: PByte; AReg: Byte; ANum: Cardinal);
begin
  AMem^:= $81;
  Inc(AMem);
  AMem^:= $F8 + AReg;
  Inc(AMem);
  PCardinal(AMem)^:= ANum;
  Inc(AMem,4);
end;

function TestReg32Num32(var AMem: PByte; AReg: Byte; ANum: Cardinal): Byte;
begin
  if AReg = REG_EAX then
    ThrowTheDice(Result, 2)
  else
    Result:= 2;
  Inc(Result, 4);
  if Result = 6 then
  begin
    AMem^:= $F7;
    Inc(AMem);
    AMem^:= $C0 + AReg;
    Inc(AMem);
    PCardinal(AMem)^:= ANum;
    Inc(AMem, 4);
  end else
    TestEaxNum32(AMem, ANum);
end;

procedure TestReg32Reg32(var AMem: PByte; AReg1, AReg2: Byte);
begin
  AMem^:= $85;
  Inc(AMem);
  AMem^:= AReg2*8 + AReg1 + $C0;             
  Inc(AMem);
end;

function TestRegMemNum32(var AMem: PByte; AReg: Byte; ANum: Cardinal): Byte;
begin
  Result:= 6;
  AMem^:= $F7;                          
  Inc(AMem);
  if AReg = REG_EBP then
  begin
    Inc(Result);
    AMem^:= $45;
    Inc(AMem);
    AMem^:= $00;
  end else
    AMem^:= AReg;
  Inc(AMem);
  if AReg = REG_ESP then
  begin
    Inc(Result);
    AMem^:= $24;
    Inc(AMem);
  end;
  PCardinal(AMem)^:= ANum;
  Inc(AMem,4);
end;

procedure AddReg32RandNum32(var AMem: PByte; ANum: Cardinal);
begin
  AddReg32Num32(AMem, RandomReg32All, ANum);
end;

procedure OrReg32RandNum32(var AMem: PByte; ANum: Cardinal);
begin
  OrReg32Num32(AMem, RandomReg32All, ANum);
end;

procedure AndReg32RandNum32(var AMem: PByte; ANum: Cardinal);
begin
  AndReg32Num32(AMem, RandomReg32All, ANum);
end;

procedure SubReg32RandNum32(var AMem: PByte; ANum: Cardinal);
begin
  SubReg32Num32(AMem, RandomReg32All, ANum);
end;

procedure XorReg32RandNum32(var AMem: PByte; ANum: Cardinal);
begin
  XorReg32Num32(AMem, RandomReg32All, ANum);
end;

procedure CmpReg32RandNum32Rand(var AMem: PByte);
begin
  CmpReg32Num32(AMem, RandomReg32All, Random($FFFFFFFF));
end;

procedure TestReg32RandNum32Rand6(var AMem: PByte);
var
  LLen: Byte;
begin
  LLen:= TestReg32Num32(AMem, RandomReg32All, Random($FFFFFFFF));
  if LLen = 5 then
  begin
    AMem^:= $90;
    Inc(AMem);
  end;
end;

procedure MovReg32Num32Rand(var AMem: PByte; AReg: Byte);
begin
  MovReg32Num32(AMem, AReg, Random($FFFFFFFF));
end;

procedure MovReg16Num16(var AMem: PByte; AReg: Byte; ANum: Word);
begin
  AMem^:= $66;
  Inc(AMem);
  AMem^:= $B8 + AReg;
  Inc(AMem);
  PWord(AMem)^:= ANum;
  Inc(AMem,2);
end;

procedure MovReg16Num16Rand(var AMem: PByte; AReg: Byte);
begin
  MovReg16Num16(AMem, AReg, Random($10000));
end;

procedure GenerateRubbishCode(AMem: Pointer; ASize, AVirtAddr: Cardinal); stdcall;

 procedure InsertRandomInstruction(var AMem:PByte; ALength: Byte; var ARemaining: Cardinal);
 var
   LRegAny: Byte;
   LMaxDice,LXRem: Cardinal;
 begin
   case ALength of
     1:
     begin
       ThrowTheDice(LMaxDice, 50);
       case LMaxDice of
         001..010: Cld(AMem);
         011..020: Nop(AMem);
         021..030: Stc(AMem);
         031..040: Clc(AMem);
         041..050: Cmc(AMem);
       end;
     end;
     2:
     begin
       ThrowTheDice(LMaxDice, 145);
       case LMaxDice of
         001..010: XchgReg32Rand(AMem);
         011..020: MovReg32Rand(AMem);
         021..030:
         begin
           LRegAny:= IncReg32Rand(AMem);
           DecReg32(AMem, LRegAny);
         end;
         031..040:
         begin
           LRegAny:= DecReg32Rand(AMem);
           IncReg32(AMem, LRegAny);
         end;
         041..050:
         begin
           LRegAny:= PushReg32Rand(AMem);
           PopReg32(AMem, LRegAny);
         end;
         051..060: LeaReg32Rand(AMem);
         061..070: TestReg32Rand(AMem);
         071..080: OrReg32Rand(AMem);
         081..090: AndReg32Rand(AMem);
         091..100: TestReg8Rand(AMem);
         101..110: OrReg8Rand(AMem);
         111..120: AndReg8Rand(AMem);
         121..130: CmpRegRegNum8Rand(AMem);
         131..132:
         begin
           Std(AMem);
           Cld(AMem);
         end;
         133..134: JmpNum8(AMem, 0);
         135..138: SubAlNum8(AMem, 0);
         139..140: TestAlNum8Rand(AMem);
         141..142: AddAlNum8(AMem, 0);
         143..145: FNop(AMem);
       end;
     end;
     3:
     begin
       ThrowTheDice(LMaxDice, 205);
       case LMaxDice of
         001..010:
         begin
           JmpNum8(AMem, 1);
           InsertRandomInstruction(AMem, 1, LXRem);
         end;
         011..020: SubReg32Num8Rand(AMem, 0);
         021..030: AddReg32Num8Rand(AMem, 0);
         031..040:
         begin
           LRegAny:= PushReg32Rand(AMem);
           IncReg32(AMem, LRegAny);
           PopReg32(AMem, LRegAny);
         end;
         041..050:
         begin
           LRegAny:= PushReg32Rand(AMem);
           DecReg32(AMem, LRegAny);
           PopReg32(AMem, LRegAny);
         end;
         051..060: CmpRandReg32RandNum8(AMem);
         061..070: TestReg8Num8Rand(AMem);
         071..080: SubReg8Num8Rand(AMem,0);
         081..090: AddReg8Num8Rand(AMem,0);
         091..100: AndReg16Rand(AMem);
         101..110: TestReg16Rand(AMem);
         111..120: OrReg16Rand(AMem);
         121..130: ShlReg32RandNum8FullRand(AMem);
         131..140: ShrReg32RandNum8FullRand(AMem);
         141..150: SalReg32RandNum8FullRand(AMem);
         151..160: SarReg32RandNum8FullRand(AMem);
         161..170: RolReg8RandNum8FullRand(AMem);
         171..180: RorReg8RandNum8FullRand(AMem);
         181..190: RolReg32RandNum8FullRand(AMem);
         191..200: RorReg32RandNum8FullRand(AMem);
         201..203:
         begin
           PushReg32(AMem, REG_EDX);
           Cdq(AMem);
           PopReg32(AMem, REG_EDX);
         end;
         204..205:
         begin
           LRegAny:= PushReg32Rand(AMem);
           InsertRandomInstruction(AMem, 1, LXRem);
           PopReg32(AMem, LRegAny);
         end;
       end;
     end;
     4:
     begin
       ThrowTheDice(LMaxDice, 170);
       case LMaxDice of
         001..020:
         begin
           JmpNum8(AMem, 2);
           InsertRandomInstruction(AMem, 2, LXRem);
         end;
         021..040:
         begin
           LRegAny:= PushReg32Rand(AMem);
           InsertRandomInstruction(AMem, 2, LXRem);
           PopReg32(AMem, LRegAny);
         end;
         041..050: TestAxNum16Rand(AMem);
         051..060: CmpAxNum16Rand(AMem);
         061..063: DoubleXorRand(AMem);
         064..066: DoubleNegRand(AMem);
         067..070: DoubleNotRand(AMem);
         071..080: AddReg16Num8Rand(AMem, 0);
         081..090: OrReg16Num8Rand(AMem, 0);
         091..100: AndReg16Num8Rand(AMem, $FF);
         101..110: SubReg16Num8Rand(AMem, 0);
         111..120: XorReg16Num8Rand(AMem, 0);
         121..130: CmpReg16Num8RandRand(AMem);
         131..140: RolReg16RandNum8FullRand(AMem);
         141..150: RorReg16RandNum8FullRand(AMem);
         151..155: DoubleXchgRand(AMem);
         156..160:
         begin
           LRegAny:= PushReg32Rand(AMem);
           MovReg32Reg32Rand(AMem,LRegAny);
           PopReg32(AMem, LRegAny);
         end;
         161..170:
         begin
           PushReg32Rand(AMem);
           AddReg32Num8(AMem, REG_ESP, 4);
         end;
       end;
     end;
     5:
     begin
       ThrowTheDice(LMaxDice, 150);
       case LMaxDice of
         001..030:
         begin
           JmpNum8(AMem, 3);
           InsertRandomInstruction(AMem, 3, LXRem);
         end;
         031..060:
         begin
           LRegAny:= PushReg32Rand(AMem);
           InsertRandomInstruction(AMem, 3, LXRem);
           PopReg32(AMem, LRegAny);
         end;
         061..070:
         begin
           LRegAny:= PushReg32Rand(AMem);
           PushNum8Rand(AMem);
           PopReg32(AMem, LRegAny);
           PopReg32(AMem, LRegAny);
         end;
         071..080:
         begin
           PushNum8Rand(AMem);
           AddReg32Num8(AMem, REG_ESP, 4);
         end;
         081..090: AddEaxNum32(AMem, 0);
         091..100: OrEaxNum32(AMem, 0);
         101..110: AndEaxNum32(AMem, $FFFFFFFF);
         111..120: SubEaxNum32(AMem, 0);
         121..130: XorEaxNum32(AMem, 0);
         131..140: CmpEaxNum32Rand(AMem);
         141..150: TestEaxNum32Rand(AMem);
       end;
     end;
     6:
     begin
       ThrowTheDice(LMaxDice, 161);
       case LMaxDice of
         001..040:
         begin
           JmpNum8(AMem, 4);
           InsertRandomInstruction(AMem, 4, LXRem);
         end;
         041..080:
         begin
           LRegAny:= PushReg32Rand(AMem);
           InsertRandomInstruction(AMem, 4, LXRem);
           PopReg32(AMem, LRegAny);
         end;
         081..090: AddReg32RandNum32(AMem, 0);
         091..100: OrReg32RandNum32(AMem, 0);
         101..110: AndReg32RandNum32(AMem, $FFFFFFFF);
         111..120: SubReg32RandNum32(AMem, 0);
         121..130: XorReg32RandNum32(AMem, 0);
         131..140: CmpReg32RandNum32Rand(AMem);
         141..150: TestReg32RandNum32Rand6(AMem);
         151..161:
         begin
           LRegAny:= PushReg32Rand(AMem);
           MovReg16Num16Rand(AMem, LRegAny);
           PopReg32(AMem, LRegAny);
         end;
       end;
     end;
     7:
     begin
       ThrowTheDice(LMaxDice, 110);
       case LMaxDice of
         001..050:
         begin
           JmpNum8(AMem, 5);
           InsertRandomInstruction(AMem, 5, LXRem);
         end;
         051..100:
         begin
           LRegAny:= PushReg32Rand(AMem);
           InsertRandomInstruction(AMem, 5, LXRem);
           PopReg32(AMem, LRegAny);
         end;
         101..110:
         begin
           LRegAny:= PushReg32Rand(AMem);
           MovReg32Num32Rand(AMem, LRegAny);
           PopReg32(AMem, LRegAny);
         end;
       end;
     end;
     8:
     begin
       ThrowTheDice(LMaxDice, 120);
       case LMaxDice of
         001..060:
         begin
           JmpNum8(AMem, 6);
           InsertRandomInstruction(AMem, 6, LXRem);
         end;
         061..120:
         begin
           LRegAny:= PushReg32Rand(AMem);
           InsertRandomInstruction(AMem, 6, LXRem);
           PopReg32(AMem, LRegAny);
         end;
       end;
     end;
     9..10:
     begin
       ThrowTheDice(LMaxDice, 200);
       case LMaxDice of
         001..100:
         begin
           JmpNum8(AMem, ALength - 2);
           InsertRandomInstruction(AMem, ALength - 2, LXRem);
         end;
         101..200:
         begin
           LRegAny:= PushReg32Rand(AMem);
           InsertRandomInstruction(AMem, ALength - 2, LXRem);
           PopReg32(AMem, LRegAny);
         end;
       end;
     end;
   end;
   if ALength < 11 then Dec(ARemaining, ALength);
 end;

var
  LPB: PByte;
  LReg: Byte;
  LDice, LDecSize, LSize, LAddr: Cardinal;

begin
  LPB:= AMem;
  LSize:= ASize;
  while LSize > 0 do
  begin
    ThrowTheDice(LDice, 6);
    if LSize < 32 then LDice:= 1;
    if AVirtAddr = 0 then LDice:= 1;
    if LDice < 6 then
    begin
      ThrowTheDice(LDice, LSize*100);
      if LSize = 1 then LDice:= 1;
      case LDice of
        001..002: InsertRandomInstruction(LPB, 1, LSize);
        101..104: InsertRandomInstruction(LPB, 2, LSize);
        201..208: InsertRandomInstruction(LPB, 3, LSize);
        301..316: InsertRandomInstruction(LPB, 4, LSize);
        401..432: InsertRandomInstruction(LPB, 5, LSize);
        501..564: InsertRandomInstruction(LPB, 6, LSize);
        else InsertRandomInstruction(LPB, (LDice + 99) div 100, LSize);
      end;
    end else begin
      ThrowTheDice(LDice, 63);
      if LDice < 57 then
        LDecSize:= LSize
      else
        LDecSize:= 0;
      case LDice of
        1..18:
        begin
          RelJmpAddr32(LPB, LSize - 5);
          PutRandomBuffer(LPB, LSize - 5);
        end;
        19..37:
        begin
          LReg:= PushReg32Rand(LPB);
          ThrowTheDice(LDice);
          if LDice > 3 then
            LAddr:= LSize - 8
          else
            LAddr:= LSize - 10;
          RelCallAddr(LPB,LAddr);
          PutRandomBuffer(LPB,LAddr);
          if LDice > 3 then
            PopReg32(LPB, LReg)
          else
            AddReg32Num8(LPB, REG_ESP, 4);
          PopReg32(LPB, LReg);
        end;
        38..56:
        begin
          if LSize-3 < $7D then
            LAddr:= LSize - 4
          else
            LAddr:= $7C;
          LAddr:= Random(LAddr) + 2;
          LoopNum8(LPB, LAddr);
          JecxzNum8(LPB, LAddr - 2);
          PutRandomBuffer(LPB, LAddr - 2);
          IncReg32(LPB, REG_ECX);
          LDecSize:= LAddr + 3;
        end;
        57..63:
        begin
          if LSize - 7 < $7D then
            LAddr:= LSize - 7
          else
            LAddr:= $75;
          LAddr:= Random(LAddr) + 3;
          PushReg32(LPB, REG_ECX);
          MovzxEcxCl(LPB);          
          GenerateRubbishCode(LPB, LAddr - 3, 0);
          Inc(LPB, LAddr - 3);
          LoopNum8(LPB, $FE - LAddr);
          PopReg32(LPB, REG_ECX);
          LDecSize:= LAddr + 4;
        end;
      end;
      Dec(LSize, LDecSize);
    end;
  end;
end;

initialization
  Randomize;
end.