unit Qpack;

interface

type
  Bufar = array[0..0] of Byte;

var
  ProgressEvent: procedure(Progress: Cardinal);
  
var
  WriteFromBuffer,
  ReadToBuffer: procedure;
  InBuf, OutBuf: ^Bufar;
  InPtr, InEnd, OutPtr, OutEnd: Cardinal;

  TextSize: LongInt = 0;
  CodeSize: LongInt = 0;

procedure EnCode(Bytes: LongInt);

implementation

const
  N         = 4096;
  F         = 60;
  THRESHOLD = 2;
  NODENIL   = N;   
  N_CHAR    = 256 - THRESHOLD + F;
  T         = N_CHAR*2 - 1;
  R         = T - 1;
  MAX_Freq  = $8000;

P_Len: array[0..63] of Byte =
       ($03,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,
        $06,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07,$07,$07,$07,
        $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,
        $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08);

P_Code: array[0..63] of Byte =
       ($00,$20,$30,$40,$50,$58,$60,$68,$70,$78,$80,$88,$90,$94,$98,$9C,
        $A0,$A4,$A8,$AC,$B0,$B4,$B8,$BC,$C0,$C2,$C4,$C6,$C8,$CA,$CC,$CE,
        $D0,$D2,$D4,$D6,$D8,$DA,$DC,$DE,$E0,$E2,$E4,$E6,$E8,$EA,$EC,$EE,
        $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF);

  GetBuf: Word = 0;
  GetLen: Byte = 0;
  PutBuf: Word = 0;
  PutLen: Word = 0;

  PrintCount: LongInt = 0;

var
  Text_Buf: array[0..N + F - 2] of Byte;
  Match_Position, Match_Length: Word;
  lSon, dad: array[0..N] of Word;
  rSon:     array[0..N + 256] of Word;
  Freq: array[0..T] of Word;
  Prnt: array [0..T + N_CHAR - 1] of Word;
  Son: array[0..T-1] of Word;

function GetC: Byte;
begin
  GetC:= InBuf^[InPtr];
  Inc(InPtr);
  if InPtr = InEnd then ReadToBuffer;
end;

procedure PutC(C: Byte);
begin
  OutBuf^[OutPtr]:= C;
  Inc(OutPtr);
  if OutPtr = OutEnd then WriteFromBuffer;
end;

procedure InitTree;
var
  I: Word;
begin
  for I:= N + 1 to N + 256 do rSon[I]:= NODENIL;
  for I:= 0 to N - 1 do dad[I]:= NODENIL;
end;

procedure InsertNode(R: Word);
label
  Done;
var
  I, P: Word;
  geq: Boolean;
  C: Word;
begin
  geq:= true;
  P:= N + 1 + Text_Buf[R];
  rSon[R]:= NODENIL;
  lSon[R]:= NODENIL;
  Match_Length:= 0;
  while TRUE do
  begin
    if geq then
      if rSon[P] = NODENIL then
      begin
        rSon[P]:= R;
        dad[R]:= P;
        exit;
      end else
        P:= rSon[P]
    else
      if lSon[P] = NODENIL then
      begin
        lSon[P]:= R;
        dad[R]:= P;
        exit;
      end else
        P:= lSon[P];
    I:= 1;
    while (I < F) and (Text_Buf[R + I] = Text_Buf[P + I]) do Inc(I);
    geq:= (Text_Buf[R + I] >= Text_Buf[P + I]) or (I = F);
    if I > THRESHOLD then
    begin
      if I > Match_Length then
      begin
        Match_Position := (R - P) and (N - 1) - 1;
        Match_Length:= I;
        if Match_Length >= F then goto done;
      end;
      if I = Match_Length then
      begin
        C:= (R - P) and (N - 1) - 1;
        if C < Match_Position then Match_Position:= C;
      end
    end
  end;
  Done:
  dad[R]:= dad[P];
  lSon[R]:= lSon[P];
  rSon[R]:= rSon[P];
  dad[lSon[P]]:= R;
  dad[rSon[P]]:= R;
  if rSon[dad[P]] = P then
    rSon[dad[P]]:= R
  else
    lSon[dad[P]]:= R;
  dad[P]:= NODENIL;
end;

procedure DeleteNode(P: Word);
var
  Q: Word;
begin
  if dad[P] = NODENIL then exit;
  if rSon[P] = NODENIL then Q:= lSon[P] else
  if lSon[P] = NODENIL then Q:= rSon[P] else
  begin
    Q:= lSon[P];
    if rSon[Q] <> NODENIL then
    begin
      repeat
        Q:= rSon[Q];
      until
        rSon[Q] = NODENIL;
      rSon[dad[Q]]:= lSon[Q];
      dad[lSon[Q]]:= dad[Q];
      lSon[Q]:= lSon[P];
      dad[lSon[P]]:= Q;
    end;
    rSon[Q]:= rSon[P];
    dad[rSon[P]]:= Q;
  end;
  dad[Q]:= dad[P];
  if rSon[dad[P]] = P then
    rSon[dad[P]]:= Q
  else
    lSon[dad[p]]:= Q;
  dad[P]:= NODENIL;
end;

procedure PutCode(L: Byte; C: Word);
begin
  PutBuf:= PutBuf or (C shr PutLen);
  Inc(PutLen, L);
  if PutLen >= 8 then
  begin
    PutC(Hi(PutBuf));
    Dec(PutLen, 8);
    if PutLen >= 8 then
    begin
      PutC(Lo(PutBuf));
      Inc(CodeSize, 2);
      Dec(PutLen, 8);
      PutBuf:= C shl (L - PutLen);
    end else begin
      PutBuf:= Swap(PutBuf and $FF); 
      Inc(CodeSize);
    end
  end
end;

procedure StartHuff;
var
  I, J: Word;
begin
  for I:= 0 to N_CHAR - 1 do
  begin
    Freq[I]:= 1;
    Son[I] := I + T;
    Prnt[I+T]:= I;
  end;
  I:= 0; J:= N_CHAR;
  while J <= R do
  begin
    Freq[J]:= Freq[I] + Freq[I+1];
    Son[J] := I;
    Prnt[I]:= J;
    Prnt[I+1]:= J;
    Inc(I, 2);
    Inc(J);
  end;
  Freq[T]:= $FFFF;
  Prnt[R]:= 0;
end;

procedure ReConst;
var
  I, J, K, F, L: Word;
begin
  J:= 0;
  for I:= 0 to T - 1 do
    if Son[I] >= T then
    begin
      Freq[J]:= (Freq[I] + 1) shr 1;
      Son[J]:= Son[I];
      Inc(J);
    end;
  I:= 0; J:= N_CHAR;
  while J < T do
  begin
    K:= I + 1;
    F:= Freq[I] + Freq[K];
    Freq[J]:= F;
    K:= J - 1;
    while F < Freq[K] do Dec(K);
    Inc(K);
    L:= (J - K) * 2;
    Move(Freq[K], Freq[K + 1],L);
    Freq[K]:= F;
    Move(Son[K], Son[K+1], L);
    Son[K]:= I;
    Inc(I, 2);
    Inc(J)
  end;
  for I:= 0 to T - 1 do
  begin
    K:= Son[I];
    Prnt[K]:= I;
    if K < T then Prnt[K+1]:= I;
  end
end;

procedure Update(C: Word);
var
  I, J, K, L: Word;
begin
  if Freq[R] = MAX_Freq then ReConst;
  C:= Prnt[C+T];
  repeat
    Inc(Freq[C]);
    K:= Freq[C];
    L:= C + 1;
    if K > Freq[L] then
    begin
      while K > Freq[L+1] do Inc(L);
      Freq[C]:= Freq[L];
      Freq[L]:= K;
      I:= Son[C];
      Prnt[I]:= L;
      if I < T then Prnt[I+1]:= L;
      J:= Son[L];
      Son[L]:= I;
      Prnt[J]:= C;
      if J < T  then Prnt[J + 1]:= C;
      Son[C]:= J;
      C:= L;
    end;
    C:= Prnt[C];
  until C = 0;
end;

procedure EnCodeChar(C: Word);
var
  Code, Len, K: Word;
begin
  Code:= 0;
  Len:= 0;
  K:= Prnt[C+T];
  repeat
    Code:= Code shr 1;
    if (K and 1) > 0 then Inc(Code, $8000);
    Inc(Len);
    K:= Prnt[K];
  until K = R;
  PutCode(Len, Code);
  Update(C);
end;

procedure EnCodePosition(c: Word);
var
  I: Word;
begin
  I:= C shr 6;
  PutCode(P_Len[I], Word(P_Code[I]) shl 8);
  PutCode(6, (C and $3F) shl 10);
end;

procedure EnCodeEnd;
begin
  if PutLen > 0 then
  begin
    PutC(Hi(PutBuf));
    Inc(CodeSize);
  end
end;

procedure EnCode(Bytes: LongInt);
type
  ByteRec = record
    b0,b1,b2,b3: Byte;
  end;
var
  I, C, Len, R, S, Last_Match_Length: Word;
begin
  with ByteRec(Bytes) do
  begin
    PutC(b0);
    PutC(b1);
    PutC(b2);
    PutC(b3)
  end;
  if Bytes = 0 then exit;
  TextSize:= 0;
  StartHuff;
  InitTree;
  S:= 0;
  R:= N - F;
  FillChar(Text_Buf[0], R, #32);
  Len:= 0;
  while (Len < F) and (InPtr or InEnd > 0) do
  begin
    Text_Buf[R + Len]:= GetC;
    Inc(Len)
  end;
  TextSize:= Len;
  for I:= 1 to F do InsertNode(R-I);
  InsertNode(R);
  repeat
    if Match_Length > Len then Match_Length:= Len;
    if Match_Length <= THRESHOLD then
    begin
      Match_Length:= 1;
      EnCodeChar(Text_Buf[R])
    end else begin
      EnCodeChar(255 - THRESHOLD + Match_Length);
      EnCodePosition(Match_Position)
    end;
    Last_Match_Length:= Match_Length;
    I:= 0;
    while (I < Last_Match_Length) and (InPtr or InEnd > 0) do
    begin
      Inc(I);
      DeleteNode(S);
      C:= GetC;
      Text_Buf[S]:= C;
      if S < F-1 then Text_Buf[S+N]:= C;
      S:= (S+1) and (N-1);
      R:= (R+1) and (N-1);
      InsertNode(R);
    end;
    Inc(TextSize, I);
    if TextSize > PrintCount then  
    begin
      if Assigned(ProgressEvent) then
        ProgressEvent(TextSize);
      Inc(PrintCount, 1024);
    end;
    while I < Last_Match_Length do
    begin
      Inc(I);
      DeleteNode(s);
      S:= (S+1) and (N-1);
      R:= (R+1) and (N-1);
      Dec(Len);
      if Len > 0 then InsertNode(R);
    end;
  until Len = 0;
  EnCodeEnd;
  PrintCount:= 0;
end;

end.
