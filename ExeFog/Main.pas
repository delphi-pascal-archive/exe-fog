unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, ShellAPI, XPTheme, aPLibv, uCode, PE_Files, Qpack;

const
  SC_ABOUT_ITEM = WM_USER + 100;
  WM_TRAYICON   = WM_USER + 101;

type
  TfrmMain = class(TForm)
    pnlFilePath: TPanel;
    lbFile: TLabel;
    edtFilePath: TEdit;
    btnBrowse: TButton;
    pnlSettings: TPanel;
    pnlActions: TPanel;
    btnQuit: TButton;
    btnProtect: TButton;
    brProgress: TProgressBar;
    line: TBevel;
    cbxBackup: TCheckBox;
    dlgOpen: TOpenDialog;
    cbxSaveoverlay: TCheckBox;
    btnTest: TButton;
    brStatus: TStatusBar;
    edtMutex: TEdit;
    cbxMutex: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnQuitClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure btnProtectClick(Sender: TObject);
    procedure cbxMutexClick(Sender: TObject);
  private
    FIconData: TNotifyIconData;
    FPacker: TaPLib; 
    procedure ShowAboutDlg;
    procedure ExceptHook(Sender: TObject; E: Exception);
    function ExecuteFile(const FileName, Params: string): Boolean;
    function PackTest(const FileName: string): Boolean;
    function CheckInputFile(const FileName: string): Boolean;
    function ProtectFile(const FileName: string): Boolean;
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure IconCallBackMessage(var Msg : TMessage); message WM_TRAYICON;  
    procedure WMWindowPosChanging(var Msg: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
  public
    procedure ShowMessage(const Msg: string);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

const
  PROG_NAME: string = '';
  PROG_VERS: string = '';
  PROG_MAIL: string = 'bagie@bk.ru';

var
  dwLastPos: DWORD;
  CurFileSize: DWORD;

function CallBack(w0, w1, w2: DWORD; cbParam: Pointer): DWORD; cdecl;
var
  dwPos: DWORD;
begin
  dwPos:= Round(w1/CurFileSize*100);
  if dwPos <> dwLastPos then
  begin
    dwLastPos:= dwPos;
    frmMain.brProgress.Position:= dwPos;
  end;
  Application.ProcessMessages;
  Result:= aP_pack_continue;
end;

const
  SIGN_CRY = $07010701;
  SIGN_BAS = $7030C095;
  SIGN_FLG = $01010101;
  SIGN_SZE = $02020202;
  SIGN_MUT = $03030303;
  SIGN_CRI = $AA00AA00;
  SIGN_IAT = $F1F1F1F1;
  SIGN_OEP = $13131313;
  SIGN_LLA = $0F0F0F0F;
  SIGN_GPA = $90999099;
  SIGN_NIM = $FAAAAAAF;
  SIGN_END = $01020304;

const
  CRY_START = 114;

procedure Loader;
asm
    dd 0,0,0,0
    dd 0,0,0,0                                                  
    dd 0,0,0,0
    dd 0,0,0,0
//-----------------------
    db $E8,$00,$00,$00,$00,$5D,$83,$C5
    db $12,$55,$C3,$20,$83,$B8,$ED,$20
    db $37,$EF,$C6,$B9,$79,$37,$9E,$90
//-----------------------
    jmp @next_000
    dd SIGN_CRY  // SIGN_CRY
@next_000:
    mov ebx,$12345678 // data
    mov ecx,$12345678 // size
    mov al,$00        // key
@xloop:
    xor [ebx+ecx],al
    mov al,[ebx+ecx]
    loop @xloop
//-----------------------       USER CODE HERE
 (*   xor eax,eax
    db $E8,$00,$00,$00,$00
    add dword [esp],$30
    push dword [fs:eax]
    mov [fs:eax],esp
    pushf
    pop eax
    or eax,$100
    {push 0
    push $FFFFFFFF
    push 0
    push 0}
    push eax
    {mov eax,$101
    lea esi,[esp-4]
    lea edx,[esp+4]
    mov dword [esi],$340F}
    popf
    jmp @retrn//esi
    mov esi,[esp+$0C]
    db $E8,$00,$00,$00,$00
    pop eax
    add eax,$0D
    mov [esi+$B8],eax
    xor eax,eax
    ret
    //add esp,16
    xor eax,eax
    pop dword [fs:eax]
    add esp,4    *)
//-----------------------
    db $E8,$00,$00,$00,$00,$5D,$83,$C5
    db $12,$55,$C3,$20,$83,$B8,$ED,$20
    db $37,$EF,$C6,$B9,$79,$37,$9E,$90
//-----------------------
    call @entry
@entry:
    pop eax
//-----------------------
    db $EB,$09
    nop
    nop
    nop
    pop eax
    db $EB,$38
    nop
    nop
    nop
    xor ecx,ecx
    add ecx,$10
    mov ebx,$77FFFFFF
    mov eax,fs:[ebx+$88000019]
    mov eax,[ecx*2+eax+$10]
    movzx eax,byte [eax+2]
    not eax
    and eax,1
    mov ebx,eax
    push $00C3FBF6
    db $E8,$00,$00,$00,$00
    sub dword [esp],$33
    mov esi,esp
    add esi,4
    jmp esi
//-----------------------
    mov ebp,$12345678
    jmp @next_001
    dd SIGN_BAS  // SIGN_BAS
@next_001:
//-----------------------
    push $002424FF
    db $E8,$00,$00,$00,$00
    add dword [esp],$0A
    lea ebx,[esp+4]
    jmp ebx
    pop ebx
    pop ebx
//-----------------------
    // LoadLibraryA('kernel32.dll')
    jmp @next_101
    dd SIGN_LLA
@next_101:
    mov eax,[$77E805D8] // LoadLibraryA
    test eax,eax
    jz @retrn
    call @lpkernel
    db 'kernel32.dll',0
@lpkernel:
    call eax
    test eax,eax
    jz @retrn
    mov ebx,eax
    //
    jmp @next_102
    dd SIGN_GPA
@next_102:
    mov eax,[$77E7A5FD] // GetProcAddress
    test eax,eax
    jz @retrn
    mov esi,eax
    xor eax,eax
    xor ecx,ecx
    xor edx,edx
    xor edi,edi
    cmp byte [esi],$CC
    je @retrn
//-----------------------
    xor ecx,ecx
    inc ecx     // nop - depack
    jecxz @depack
    jmp @next_002
    dd SIGN_FLG  // SIGN_FLG
@next_002:
    nop
    jmp @depack_end
@depack:
//-----------------------
{ depacking here }
    call @lpva
    db 'VirtualAlloc',0
@lpva:
    push ebx
    call esi
    test eax,eax
    jz @retrn
    cmp byte [eax],$CC
    je @retrn
    push PAGE_READWRITE
    push MEM_COMMIT	
    mov edi,$12345678
    jmp @next_003
    dd SIGN_SZE  // SIGN_SZE
@next_003:
    push edi
    push 0
    call eax
    test eax,eax
    jz @retrn
    push eax
    lea edx,[ebp+$1000]
    push eax
    push edx
    call @_aP_depack_asm
    add esp,8
    mov eax,[esp]
    mov ecx,edi
    dec ecx
    mov edx,eax
    push esi
    lea esi,[ebp+$1000]
@cloop:
    mov al,[edx+ecx]
    mov [esi+ecx],al
    loop @cloop
    pop esi
    pop eax
    push MEM_DECOMMIT
    push edi
    push eax
    call @lpvf
    db 'VirtualFree',0
@lpvf:
    push ebx
    call esi
    test eax,eax
    jz @depack_end
    cmp byte [eax],$CC
    je @depack_end
    call eax    
    jmp @depack_end
@retrn:
    ret
//-----------------------
@depack_end:
    nop
//-----------------------
    call @lpcma
    db 'CreateMutexA',0
@lpcma:
    push ebx
    call esi
    test eax,eax
    jz @final
    cmp byte [eax],$CC
    je @retrn
    jmp @next_004
    dd SIGN_MUT
@next_004:
    call @lpmn
    dd 0,0,0,0,0,0,0,0
@lpmn:
    push 0
    push 0
    call eax
@final:
//------------ IMPORT RECOVER -----------
    pushad
    jmp @next_008
    dd SIGN_CRI  // SIGN_CRY2
@next_008:
    mov ebx,$12345678 // data
    mov ecx,$12345678 // size
    mov al,$00        // key
@xloop2:
    xor [ebx+ecx],al
    loop @xloop2
    popad
//----------------
    call @lpl2a
    db 'LoadLibraryA',0
@lpl2a:
    push ebx
    call esi
    test eax,eax
    jz @retrn
    cmp byte [eax],$CC
    je @retrn
    mov edi,eax
    // edi -> LoadLibraryA
    // esi -> GetProcAddress
    jmp @next_009
    dd SIGN_IAT
@next_009:
    mov ecx,$12345678 // import rva
    add ecx,ebp
    cmp dword [ecx+$0C],0
    jne @l2fop
    jmp @next_005
@l2fop:
    mov ebx,[ecx+$0C]
    add ebx,ebp
    push ecx
    push ebx
    call edi
    pop ecx
    test eax,eax
    jz @retrn
    cmp byte [eax],$CC
    jz @retrn
    mov ebx,eax
    cmp dword [ecx+$10],0
    je @retrn
    // ebx -> lib handle
    mov edx,[ecx+$10]
    add edx,ebp
    push edi
    mov edi,[ecx]
    add edi,ebp
@eloop:
    cmp dword [edx],0
    je @thunkok
    push ecx
    push edx
    cmp dword [ecx],0
    jne @thunk_02        
    mov eax,[edx]
    test eax,$80000000
    je @1_name
    and eax,$0000FFFF
    push eax
    jmp @thunk_03
@1_name:
    add eax,ebp
    //...
    add eax,2
    push eax
    jmp @thunk_03
@thunk_02:    
    mov eax,[edi]
    add edi,4
    test eax,$80000000
    je @2_name
    and eax,$0000FFFF
    push eax
    jmp @thunk_03
@2_name:
    add eax,ebp
    //...
    add eax,2
@bad_02:
    push eax
@thunk_03:
    push ebx
    call esi
    pop edx
    pop ecx
    test eax,eax
    jz @retrn
    cmp byte [eax],$CC
    jz @retrn
    mov [edx],eax
    add edx,4
    jmp @eloop
@thunkok:
    pop edi
    //
    add ecx,$14
    cmp dword [ecx+$0C],0
    jne @l2fop
    nop
//-----------------------
    jmp @next_005
    dd $7065C095
@next_005:
    push $12345678
//-----------------------
    dd 0,0,0,0 
//-----------------------
    add [esp],ebp
    ret
    dd SIGN_OEP  // SIGN_OEP
//-----------------------
    dd 0,0,0,0
    dd 0,0,0,0
    dd 0,0,0,0
    dd 0,0,0,0
//-----------------------
{ ******************* _aP_depack_asm ******************* }
@_aP_depack_asm:
    pushad
    mov esi,[esp+36]
    mov edi,[esp+40]
    cld
    mov dl,$80
    xor ebx,ebx
@literal:
    movsb
    mov bl,2
@nexttag:
    call @getbit
    jnc @literal
    xor ecx,ecx
    call @getbit
    jnc @codepair
    xor eax,eax
    call @getbit
    jnc @shortmatch
    mov bl,2
    inc ecx
    mov al,$10
@getmorebits:
    call @getbit
    adc al,al
    jnc @getmorebits
    jnz @domatch
    stosb
    jmp @nexttag
@codepair:
    call @getgamma_no_ecx
    sub ecx, ebx
    jnz @normalcodepair
    call @getgamma
    jmp @domatch_lastpos
@shortmatch:
    lodsb
    shr eax,1
    jz @donedepacking
    adc ecx, ecx
    jmp @domatch_with_2inc
@normalcodepair:
    xchg eax,ecx
    dec eax
    shl eax,8
    lodsb
    call @getgamma
    cmp eax,32000
    jae @domatch_with_2inc
    cmp ah,5
    jae @domatch_with_inc
    cmp eax,$7F
    ja @domatch_new_lastpos
@domatch_with_2inc:
    inc ecx
@domatch_with_inc:
    inc ecx
@domatch_new_lastpos:
    xchg eax,ebp
@domatch_lastpos:
    mov eax,ebp
    mov bl,1
@domatch:
    push esi
    mov esi,edi
    sub esi,eax
    rep movsb
    pop esi
    jmp @nexttag
@getbit:
    add dl,dl
    jnz @stillbitsleft
    mov dl,[esi]
    inc esi
    adc dl,dl
@stillbitsleft:
    ret
@getgamma:
    xor ecx,ecx
@getgamma_no_ecx:
    inc ecx
@getgammaloop:
    call @getbit
    adc ecx,ecx
    call @getbit
    jc @getgammaloop
    ret
@donedepacking:
    sub edi,[esp+40]
    mov [esp+28],edi
    popad
    ret
//----------- IMPORT ------------
    dd SIGN_NIM
    {}
    dd 0,0,0
    dd $12345678  // libname
    dd $12345678  // thunk rva
    dd 0,0,0,0,0
    db 'kernel32.dll',0
    db 0,0,'LoadLibraryA',0,0
    db 0,0,'GetProcAddress',0,0
    dd $12345678 // iat
    dd $12345678
    dd 0
    {}
//-----------------------
    dd SIGN_END  // SIGN_END
//-----------------------
end; 

function SignPos(Func: Pointer; Sign: DWORD): DWORD; stdcall;
asm
    mov eax,Func
    mov edx,Sign
    mov ecx,$2000
@floop:
    cmp [eax],edx
    je @quit
    inc eax
    loop @floop
    xor eax,eax
@quit:
end;

function GetLoaderSize: DWORD;
begin
  Result:= SignPos(@Loader, SIGN_END) - DWORD(@Loader);
end;

procedure SetBase(Base: DWORD);
begin
  DWORD(Pointer(SignPos(@Loader, SIGN_BAS) - 6)^):= Base;
end;

procedure SetJump2OEP(OEP: DWORD);
begin
  DWORD(Pointer(SignPos(@Loader, SIGN_OEP) - 24)^):= OEP;
end;

procedure SetMode(APacked: Boolean);
begin
  if APacked then Byte(Pointer(SignPos(@Loader, SIGN_FLG) - 5)^):= $90;
end;

procedure SetSize(ASize: DWORD);
begin
  DWORD(Pointer(SignPos(@Loader, SIGN_SZE) - 6)^):= ASize;
end;

procedure SetMutex(AMutex: string);
begin
  if Length(AMutex) > 31 then SetLength(AMutex, 31);
  StrPCopy(Pointer(SignPos(@Loader, SIGN_MUT) + 9), AMutex);
end;

procedure SetImportRVA(IRVA: DWORD);
begin
  DWORD(Pointer(SignPos(@Loader, SIGN_IAT) + 5)^):= IRVA;
end;

function GetNewImportRVA(RVA: DWORD): DWORD;
begin
  Result:= SignPos(@Loader, SIGN_NIM) - DWORD(@Loader) + RVA + 4;
end;

function GetNewImportSize: DWORD;
begin
  Result:= SignPos(@Loader, SIGN_END) - SignPos(@Loader, SIGN_NIM) - 4;
end;

procedure ProcessImports(RVA, Base: DWORD);
begin
  DWORD(Pointer(SignPos(@Loader, SIGN_NIM) + 16)^):=
    GetNewImportRVA(RVA) + 40;
  DWORD(Pointer(SignPos(@Loader, SIGN_NIM) + 20)^):=
    GetNewImportRVA(RVA) + 87;
  DWORD(Pointer(SignPos(@Loader, SIGN_NIM) + 91)^):=
    GetNewImportRVA(RVA) + 53;
  DWORD(Pointer(SignPos(@Loader, SIGN_NIM) + 95)^):=
    GetNewImportRVA(RVA) + 69;
  DWORD(Pointer(SignPos(@Loader, SIGN_LLA) + 6)^):=
    GetNewImportRVA(RVA) + Base + 87;
  DWORD(Pointer(SignPos(@Loader, SIGN_GPA) + 6)^):=
    GetNewImportRVA(RVA) + Base + 91;
end;

procedure SetImportCryptData(VA, S: DWORD; K: Byte);
begin
  DWORD(Pointer(SignPos(@Loader, SIGN_CRI) + 5)^):= VA;
  DWORD(Pointer(SignPos(@Loader, SIGN_CRI) + 10)^):= S;
  Byte(Pointer(SignPos(@Loader, SIGN_CRI) + 15)^):= K;
end;

var
  S, D: Integer;
  K: Byte;

procedure CryptData(VA: DWORD);
begin
  K:= Random(255) + 1;
  S:= GetLoaderSize - GetNewImportSize - CRY_START - 1;
  DWORD(Pointer(SignPos(@Loader, SIGN_CRY) + 5)^):= VA;
  DWORD(Pointer(SignPos(@Loader, SIGN_CRY) + 10)^):= S;
  Byte(Pointer(SignPos(@Loader, SIGN_CRY) + 15)^):= K;
  D:= DWORD(@Loader) + CRY_START;
  asm
    mov ebx,D
    mov ecx,S
    mov al,K
  @xloop:
    mov ah,[ebx+ecx]
    xor [ebx+ecx],al
    mov al,ah
    loop @xloop
  end;
end;

procedure RestoreLoader;
begin
  asm
    mov ebx,D
    mov ecx,S
    mov al,K
  @xloop:
    xor [ebx+ecx],al
    mov al,[ebx+ecx]
    loop @xloop
  end;
end;

type
  TSectionData = packed record
    Data: Pointer;
    Size: DWORD;
  end;

function PackSection(ASource: Pointer; Size: DWORD): TSectionData;
begin
  Result.Data:= nil;
  Result.Size:= 0;
  CurFileSize:= Size;
  with frmMain.FPacker do
  begin
    Source:= ASource;
    Length:= Size;
    CallBack:= @CallBack;
    Pack;
    if Length = 0 then Exit;
    Result.Data:= Destination;
    Result.Size:= Length;
  end;
end;

function GetOSName: string;
begin
  case Win32Platform of
    VER_PLATFORM_WIN32s: Result:= 'Microsoft Windows';
    VER_PLATFORM_WIN32_WINDOWS:
    begin
      case Win32MinorVersion of
        0  : Result:= 'Microsoft Windows 95';
        10 : Result:= 'Microsoft Windows 98';
        90 : Result:= 'Microsoft Windows Millenium Edition';
        else Result:= 'Microsoft Windows';
      end;
    end;
    VER_PLATFORM_WIN32_NT:
    begin
      case Win32MajorVersion of
        3: Result:= 'Microsoft Windows NT 3.51';
        4: Result:= 'Microsoft Windows NT 4.0';
        5:
        case Win32MinorVersion of
          0:   Result:= 'Microsoft Windows 2000';
          1:   Result:= 'Microsoft Windows XP';
          else Result:= 'Microsoft Windows';
        end;
        else Result:= 'Microsoft Windows';
      end;
    end;
  end;
end;

procedure TfrmMain.ShowMessage(const Msg: string);
begin
  MessageBox(Handle, PChar(Msg),
    PChar(PROG_NAME), MB_OK or MB_SYSTEMMODAL);
end;

procedure TfrmMain.ShowAboutDlg;
begin
  MessageBox(Handle, PChar(PROG_NAME + #10#13 +
    'Copyright © 2005 by Bagie'), 'About...', MB_OK or MB_ICONINFORMATION);
end;

procedure TfrmMain.ExceptHook(Sender: TObject; E: Exception);
const
  ln = '%0d%0a';
var
  ErrStr: string;
  EIP: DWORD;
begin
  if MessageBox(Handle, PChar(E.Message + #10#13 +
    'Send error report to developer?'),
    PChar(PROG_NAME), MB_YESNO or MB_DEFBUTTON1 or MB_ICONWARNING) = ID_YES then
  begin
    asm
      mov edx,[esp+$48]
      mov EIP,edx
    end;
    ErrStr:= 'Time: ' + DateTimeToStr(Now) + ln +
             'Operating system: ' + GetOSName + ln +
             'Message: ' + E.Message + ln +
             'EIP: ' + IntToHEX(EIP, 8);
    ShellExecute(Handle, 'open', PChar('mailto:' + PROG_MAIL + '?subject=' +
      PROG_NAME + ' - Error report&Body=' + ErrStr), nil, nil, SW_SHOWNORMAL);
  end;
end;

function TfrmMain.ExecuteFile(const FileName, Params: string): Boolean;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  StartupInfo.cb:= SizeOf(StartupInfo);
  Result:= CreateProcess(PChar(FileName), PChar(Params), nil, nil, False, 0,
    nil, nil, StartupInfo, ProcessInfo);
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread); 
end;

type
  IOBuf = array[0..4095] of Byte;

var
  FHandle: HFILE;
  FOutHandle: HFILE;
  IBuf, OBUf: IOBuf;
  TotalSize: DWORD;

procedure ReadNextBlock;
begin
  InPtr:= 0;
  ReadFile(FHandle, InBuf^, SizeOf(IBuf), InEnd, nil);
end;

procedure WriteNextBlock;
var
  wr: Cardinal;
begin
  WriteFile(FOutHandle, OutBuf^, OutPtr, wr, nil);
  OutPtr:= 0;
end;

procedure PackProgress(Progress: Cardinal);
begin
  frmMain.brProgress.Position:= Round(Progress/TotalSize * 100);
  Application.ProcessMessages;
end;

function GetBorder(Size: DWORD): Byte;
begin
  Result:= Round(Exp(Size / 100000) * 33);
end;

function TfrmMain.PackTest(const FileName: string): Boolean;
var
  OFS: TOFStruct;
  selBorder: Byte;
begin
  Result:= False;
  @ProgressEvent:= @PackProgress;
  FHandle:= OpenFile(PChar(FileName), OFS, OF_READ);
  if FHandle = INVALID_HANDLE_VALUE then
  begin
    ShowMessage('Open file error');
    Exit;
  end;
  TotalSize:= GetFileSize(FHandle, nil);
  if TotalSize < 512 then
  begin
    ShowMessage('File size error');
    CloseHandle(FHandle);
    Exit;
  end;
  if TotalSize > MAXWORD then TotalSize:= MAXWORD;
  FOutHandle:= CreateFileMapping($FFFFFFFF, nil, 0, 0, TotalSize, nil);
  if FOutHandle = INVALID_HANDLE_VALUE then
  begin
    ShowMessage('Mapping file error');
    CloseHandle(FHandle);
    Exit;
  end;
  try
    selBorder:= GetBorder(TotalSize);
    InBuf:= @IBuf;
    ReadToBuffer:= ReadNextBlock;
    ReadToBuffer;
    OutBuf:= @OBuf;
    OutEnd:= SizeOf(OBuf);
    OutPtr:= 0;
    WriteFromBuffer:= WriteNextBlock;
    Encode(TotalSize);
    if OutPtr > 0 then WriteNextBlock;
    CloseHandle(FHandle);
    CloseHandle(FOutHandle);              
    Result:= Round(CodeSize / TextSize * 100) >= selBorder;
    CodeSize:= 0;
    TextSize:= 0;
  except
    ShowMessage('Analizing file error');
    CloseHandle(FHandle);
    CloseHandle(FOutHandle);
  end;
  brProgress.Position:= 100;
end;

function TfrmMain.CheckInputFile(const FileName: string): Boolean;
var
  OFS: TOFStruct;
  FHandle: HFILE;
  DosHeader: TImageDosHeader;
  ImageNtHeaders: TImageNtHeaders;
  dwTemp: DWORD;
begin
  Result:= False;
  if not FileExists(FileName) then
  begin
    ShowMessage('Can not find a file');
    Exit;
  end;
  FHandle:= OpenFile(PChar(FileName), OFS, OF_READ);
  if (FHandle = INVALID_HANDLE_VALUE) then
  begin
    ShowMessage('Open file error');
    Exit;
  end;
  ReadFile(FHandle, DosHeader, SizeOf(DosHeader), dwTemp, nil);
  if DosHeader.e_magic <> IMAGE_DOS_SIGNATURE then
  begin
    ShowMessage('Invalid executable file');
    CloseHandle(FHandle);
    Exit;
  end;
  if DosHeader.e_lfarlc < $40 then
  begin
    ShowMessage('Incorrect file header');
    CloseHandle(FHandle);
    Exit;
  end;
  if DosHeader._lfanew = 0 then
  begin
    ShowMessage('Invalid PE file (1)');
    CloseHandle(FHandle);
    Exit;
  end;
  if DosHeader._lfanew < $40 then
  begin
    ShowMessage('Incorrect file header (2)');
    CloseHandle(FHandle);
    Exit;
  end;
  SetFilePointer(FHandle, DosHeader._lfanew, nil, FILE_BEGIN);
  ReadFile(FHandle, ImageNtHeaders, SizeOf(ImageNtHeaders), dwTemp, nil);
  if ImageNtHeaders.Signature <> IMAGE_NT_SIGNATURE then
  begin
    ShowMessage('Invalid PE file (2)');
    CloseHandle(FHandle);
    Exit;
  end;
  if ImageNtHeaders.FileHeader.Characteristics and IMAGE_FILE_DLL <> 0 then
  begin
    ShowMessage('Cannot protect a DLL');
    CloseHandle(FHandle);
    Exit;
  end;
  if ImageNtHeaders.FileHeader.NumberOfSections = 0 then
  begin
    ShowMessage('Invalid PE file (3)');
    CloseHandle(FHandle);
    Exit;
  end;
  if ImageNtHeaders.OptionalHeader.ImageBase < $10000 then
  begin
    ShowMessage('Invalid base of the image');
    CloseHandle(FHandle);
    Exit;
  end;
  if (ImageNtHeaders.OptionalHeader.SectionAlignment mod $200 <> 0) or
    (ImageNtHeaders.OptionalHeader.SectionAlignment = 0)  then
  begin
    ShowMessage('Invalid section alignment');
    CloseHandle(FHandle);
    Exit;
  end;
  if (ImageNtHeaders.OptionalHeader.FileAlignment mod $200 <> 0) or
    (ImageNtHeaders.OptionalHeader.FileAlignment = 0)  then
  begin
    ShowMessage('Invalid file alignment');
    CloseHandle(FHandle);
    Exit;
  end;
  if (ImageNtHeaders.OptionalHeader.SizeOfImage mod $200 <> 0) or
    (ImageNtHeaders.OptionalHeader.SizeOfImage = 0)  then
  begin
    ShowMessage('Invalid size of the image');
    CloseHandle(FHandle);
    Exit;
  end;
  if (ImageNtHeaders.OptionalHeader.AddressOfEntryPoint = 0) then
  begin
    ShowMessage('Incorrect entry point');
    CloseHandle(FHandle);
    Exit;
  end;
  CloseHandle(FHandle);
  Result:= True;
end;

{$ALIGN OFF}

type
  TImageSectionHeader = packed record
    Name: array[0..7] of Char;
    VirtualSize: DWORD;
    VirtualAddress: DWORD;
    PhysicalSize: DWORD;
    PhysicalOffset: DWORD;
    PointerToRelocations: DWORD;
    PointerToLinenumbers: DWORD;
    NumberOfRelocations: WORD;
    NumberOfLinenumbers: WORD;
    Characteristics: DWORD;
  end;

function TfrmMain.ProtectFile(const FileName: string): Boolean;
const
  SizeOfAddData = $2000;
  SizeOfAddStub = $1000;
var
  BackupFile: string;
  PE: PE_File;
  OFS: TOFStruct;
  FHandle: HFILE;
  DosHeader: TImageDosHeader;
  ImageNtHeaders: TImageNtHeaders;
  SectionHeader: TImageSectionHeader;
  SectionHeader2: TImageSectionHeader;
  SectionHeadersOffset: DWORD;
  OverlaySize: Integer;
  AddDataOffset: DWORD;
  AddDataRVA: DWORD;
  RelocsRVA: DWORD;
  StubSize: DWORD;
  SectionData: TSectionData;
  OldPhysicalSize: DWORD;
  SavedSize: Integer;
  I, J, K: Integer;
  K2: Byte;
  ByteBuf: Byte;
  Buf: Pointer;
  BufSize: DWORD;
  dwTemp: DWORD;

  function Bit(B: DWORD): Byte;
  begin
    if B <> 0 then
      Result:= 1
    else
      Result:= 0;
  end;

  function Align(Value, Factor: DWORD): DWORD;
  begin
    Result:= (Value div Factor) * Factor + Factor * Bit(Value mod Factor);
  end;

  function CheckDirRVA(Directory: Byte; SectionRVA, SectionSize: DWORD): Boolean;
  var
    DirRVA: DWORD;
  begin
    DirRVA:= ImageNtHeaders.OptionalHeader.DataDirectory[Directory].VirtualAddress;
    Result:= (DirRVA >= SectionRVA) and (DirRVA < SectionRVA + SectionSize);    
  end;

  function CheckAllDirRVA(SectionRVA, SectionSize: DWORD; AllowImport: Boolean): Boolean;
  var
    Dir: Integer;
  begin
    Result:= False;
    for Dir:= 0 to IMAGE_NUMBEROF_DIRECTORY_ENTRIES-1 do
      if CheckDirRVA(Dir, SectionRVA, SectionSize) and
        not (AllowImport and  (Dir <> IMAGE_DIRECTORY_ENTRY_IMPORT)) then Exit;
    Result:= True;
  end;

  function CheckRVA(Value, SectionRVA, SectionSize: DWORD): Boolean;
  begin
    Result:= (Value >= SectionRVA) and (Value < SectionRVA + SectionSize);    
  end;

  function RVA2RAW(RVA, SectionRVA, SectionOffset: DWORD): DWORD;
  begin
    Result:= RVA - SectionRVA + SectionOffset;
  end;

  function RAW2RVA(Offset, SectionRVA, SectionOffset: DWORD): DWORD;
  begin
    Result:= Offset + SectionRVA - SectionOffset; 
  end;

  function GetCurrRVA: DWORD;
  begin
    Result:= RAW2RVA(SetFilePointer(FHandle, 0, nil, FILE_CURRENT),
      AddDataRVA, AddDataOffset);
  end;

  function GetCurrRVA2(Sign, V: Integer): DWORD;
  begin
    Result:= AddDataRVA + (SignPos(@Loader, Sign) - DWORD(@Loader)) + DWORD(V);
  end;

  function GetImportOffset: DWORD;
  var
    I: Integer;
  begin
    Result:= 0;
    SetFilePointer(FHandle, SectionHeadersOffset, nil, FILE_BEGIN);
    for I:= 1 to ImageNtHeaders.FileHeader.NumberOfSections do
    begin
      ReadFile(FHandle, SectionHeader2, SizeOf(SectionHeader2), dwTemp, nil);
      if CheckDirRVA(IMAGE_DIRECTORY_ENTRY_IMPORT, SectionHeader2.VirtualAddress,
        SectionHeader2.VirtualSize) then
      begin
        Result:= RVA2RAW(ImageNtHeaders.OptionalHeader.
          DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress,
          SectionHeader2.VirtualAddress, SectionHeader2.PhysicalOffset);
      end;
    end;
  end;

begin
  Result:= False;
  brStatus.Panels.Items[0].Text:= 'Checking...';
  Application.ProcessMessages;
  if not CheckInputFile(FileName) then Exit;
  brStatus.Panels.Items[0].Text:= 'Analizing...';
  Application.ProcessMessages;
  if PackTest(FileName) then
  begin
    if MessageBox(Handle, 'This file is already may be packed. Do you wish to continue?',
      PChar(PROG_NAME), MB_YESNO or MB_SYSTEMMODAL or MB_DEFBUTTON2) <> IDYES then Exit;
  end;
  brProgress.Position:= 0;

  if cbxBackup.Checked then
  begin
    BackupFile:= FileName + '.bak';
    SetFileAttributes(PChar(BackupFile), 0);
    DeleteFile(PChar(BackupFile));
    CopyFile(PChar(FileName), PChar(BackupFile), False);
  end;

  brStatus.Panels.Items[0].Text:= 'Optimizing...';
  Application.ProcessMessages;

  PE:= PE_File.Create;
  PE.PreserveOverlay:= cbxSaveoverlay.Checked;
  PE.LoadFromFile(FileName);       
  RelocsRVA:= PE.PE_Header.Fix_Up_Table_RVA;
  PE.OptimizeFile(True, True, True, False);
  PE.SaveToFile(FileName);
  PE.Free;

  FHandle:= OpenFile(PChar(FileName), OFS, OF_READWRITE);
  if (FHandle = INVALID_HANDLE_VALUE) then
  begin
    ShowMessage('Open file error');
    Exit;
  end;

  ReadFile(FHandle, DosHeader, SizeOf(DosHeader), dwTemp, nil);
  SetFilePointer(FHandle, DosHeader._lfanew, nil, FILE_BEGIN);
  ReadFile(FHandle, ImageNtHeaders, SizeOf(ImageNtHeaders), dwTemp, nil);
  SectionHeadersOffset:= DosHeader._lfanew + SizeOf(ImageNtHeaders);

  SetFilePointer(FHandle, SectionHeadersOffset +
    DWORD((ImageNtHeaders.FileHeader.NumberOfSections - 1)) *
    SizeOf(SectionHeader), nil, FILE_BEGIN);
  ReadFile(FHandle, SectionHeader, SizeOf(SectionHeader), dwTemp, nil);
  OverlaySize:= GetFileSize(FHandle, nil) - (SectionHeader.PhysicalOffset +
    SectionHeader.PhysicalSize);
  AddDataOffset:= SectionHeader.PhysicalOffset + SectionHeader.PhysicalSize;
  AddDataRVA:= RAW2RVA(AddDataOffset,
    SectionHeader.VirtualAddress, SectionHeader.PhysicalOffset);  

  if OverlaySize < 0 then
  begin
    ShowMessage('Incorrect file size');
    CloseHandle(FHandle);
    Exit;
  end else begin
    BufSize:= OverlaySize;
    GetMem(Buf, BufSize);
    SetFilePointer(FHandle, AddDataOffset, nil, FILE_BEGIN);
    if not cbxSaveoverlay.Checked then
      SetEndOfFile(FHandle)
    else
      ReadFile(FHandle, Buf^, BufSize, dwTemp, nil);
    SetFilePointer(FHandle, AddDataOffset, nil, FILE_BEGIN);
    ByteBuf:= 0;
    for I:= 1 to SizeOfAddData do
      WriteFile(FHandle, ByteBuf, SizeOf(ByteBuf), dwTemp, nil);
    WriteFile(FHandle, Buf^, BufSize, dwTemp, nil);
    FreeMem(Buf);
  end;

  Inc(ImageNtHeaders.OptionalHeader.SizeOfImage, SizeOfAddData);

  ImageNtHeaders.FileHeader.TimeDateStamp:= 0;
  ImageNtHeaders.FileHeader.PointerToSymbolTable:= 0;
  ImageNtHeaders.FileHeader.NumberOfSymbols:= 0;
  ImageNtHeaders.OptionalHeader.MajorLinkerVersion:= 0;
  ImageNtHeaders.OptionalHeader.MinorLinkerVersion:= 0;
  ImageNtHeaders.OptionalHeader.CheckSum:= 0;
  ImageNtHeaders.OptionalHeader.BaseOfCode:= $1000;
  ImageNtHeaders.OptionalHeader.BaseOfData:= $1000;

  I:= 1;
  SetFilePointer(FHandle, SectionHeadersOffset, nil, FILE_BEGIN);
  while I <= ImageNtHeaders.FileHeader.NumberOfSections do
  begin
    ReadFile(FHandle, SectionHeader, SizeOf(SectionHeader), dwTemp, nil);

    if (SectionHeader.PhysicalSize mod
      ImageNtHeaders.OptionalHeader.SectionAlignment = 0)
      and (I < ImageNtHeaders.FileHeader.NumberOfSections)
      and (SectionHeader.PhysicalSize <> 0) then
    begin
      ReadFile(FHandle, SectionHeader2, SizeOf(SectionHeader2), dwTemp, nil);
      J:= Align(SectionHeader.VirtualSize,
        ImageNtHeaders.OptionalHeader.SectionAlignment);
      if DWORD(J) = SectionHeader.PhysicalSize then
      begin
        Inc(J, Align(SectionHeader2.VirtualSize,
        ImageNtHeaders.OptionalHeader.SectionAlignment));
        SectionHeader.VirtualSize:= J;
        Inc(SectionHeader.PhysicalSize, SectionHeader2.PhysicalSize);
        BufSize:= (ImageNtHeaders.FileHeader.NumberOfSections - I - 1) *
          SizeOf(SectionHeader);
        GetMem(Buf, BufSize);
        SetFilePointer(FHandle, SectionHeadersOffset +
          DWORD(I + 1) * SizeOf(SectionHeader), nil, FILE_BEGIN);
        ReadFile(FHandle, Buf^, BufSize, dwTemp, nil);
        SetFilePointer(FHandle, SectionHeadersOffset +
          DWORD(I) * SizeOf(SectionHeader), nil, FILE_BEGIN);
        WriteFile(FHandle, Buf^, BufSize, dwTemp, nil);
        FreeMem(Buf);
        Dec(ImageNtHeaders.FileHeader.NumberOfSections);
      end;
      SetFilePointer(FHandle, SectionHeadersOffset +
        DWORD(I - 1) * SizeOf(SectionHeader), nil, FILE_BEGIN);
      WriteFile(FHandle, SectionHeader, SizeOf(SectionHeader), dwTemp, nil);
    end;

    if CheckRVA(RelocsRVA,
      SectionHeader.VirtualAddress, SectionHeader.VirtualSize)
      and (SectionHeader.PhysicalSize = 0)
      and (ImageNtHeaders.FileHeader.NumberOfSections > 1)
      and (I > 1) then
    begin         
      BufSize:= (ImageNtHeaders.FileHeader.NumberOfSections - I) *
        SizeOf(SectionHeader);
      GetMem(Buf, BufSize);
      SetFilePointer(FHandle, SectionHeadersOffset +
        DWORD(I) * SizeOf(SectionHeader), nil, FILE_BEGIN);
      ReadFile(FHandle, Buf^, BufSize, dwTemp, nil);
      SetFilePointer(FHandle, SectionHeadersOffset +
        DWORD(I - 1) * SizeOf(SectionHeader), nil, FILE_BEGIN);
      WriteFile(FHandle, Buf^, BufSize, dwTemp, nil);
      FreeMem(Buf);
      SetFilePointer(FHandle, SectionHeadersOffset +
        DWORD(I - 2) * SizeOf(SectionHeader), nil, FILE_BEGIN);
      ReadFile(FHandle, SectionHeader2, SizeOf(SectionHeader2), dwTemp, nil);

      SectionHeader2.VirtualSize:= Align(SectionHeader2.VirtualSize,
        ImageNtHeaders.OptionalHeader.SectionAlignment) +
        Align(SectionHeader.VirtualSize,
        ImageNtHeaders.OptionalHeader.SectionAlignment);

      SetFilePointer(FHandle, -SizeOf(SectionHeader2), nil, FILE_CURRENT);
      WriteFile(FHandle, SectionHeader2, SizeOf(SectionHeader2), dwTemp, nil);

      Dec(ImageNtHeaders.FileHeader.NumberOfSections);
    end;
    Inc(I);
  end;

  SetFilePointer(FHandle, SectionHeadersOffset, nil, FILE_BEGIN);
  for I:= 1 to ImageNtHeaders.FileHeader.NumberOfSections do
  begin
    ReadFile(FHandle, SectionHeader, SizeOf(SectionHeader), dwTemp, nil);

    FillChar(SectionHeader.Name, SizeOf(SectionHeader.Name), #0);
    SectionHeader.Characteristics:= $E0000000 +
        SectionHeader.Characteristics mod $10000000;

    if CheckDirRVA(IMAGE_DIRECTORY_ENTRY_RESOURCE,
      SectionHeader.VirtualAddress, SectionHeader.VirtualSize) then
      StrPCopy(SectionHeader.Name, '.rsrc');

    if I = ImageNtHeaders.FileHeader.NumberOfSections then
    begin
      Inc(SectionHeader.VirtualSize, SizeOfAddData);
      Inc(SectionHeader.PhysicalSize, SizeOfAddData);
    end;

    SetFilePointer(FHandle, -SizeOf(SectionHeader), nil, FILE_CURRENT);
    WriteFile(FHandle, SectionHeader, SizeOf(SectionHeader), dwTemp, nil);
  end;

  J:= SetFilePointer(FHandle, SectionHeadersOffset +
    DWORD((ImageNtHeaders.FileHeader.NumberOfSections)) *
    SizeOf(SectionHeader), nil, FILE_BEGIN);
  ByteBuf:= 0;                  
  for I:= J to ImageNtHeaders.OptionalHeader.SizeOfHeaders - 1 do
    WriteFile(FHandle, ByteBuf, SizeOf(ByteBuf), dwTemp, nil);

  SetFilePointer(FHandle, SectionHeadersOffset +
    DWORD((ImageNtHeaders.FileHeader.NumberOfSections - 1)) *
    SizeOf(SectionHeader), nil, FILE_BEGIN);
  ReadFile(FHandle, SectionHeader, SizeOf(SectionHeader), dwTemp, nil);
  AddDataRVA:= RAW2RVA(AddDataOffset,
    SectionHeader.VirtualAddress, SectionHeader.PhysicalOffset);

  SetFilePointer(FHandle, AddDataOffset, nil, FILE_BEGIN);
  {****************************************************************************}
  VirtualProtect(@Loader, GetLoaderSize, PAGE_EXECUTE_READWRITE, @dwTemp);

  StubSize:= Random(SizeOfAddStub - 512) + 512;
  BufSize:= StubSize;
  GetMem(Buf, BufSize);

  J:= BufSize;
  while J > 0 do
  begin
    K:= Random(J) + 1;
    Dec(J, K);
    GenerateRubbishCode(Buf, K, AddDataRVA);
    WriteFile(FHandle, Buf^, K, dwTemp, nil);
  end;

  FreeMem(Buf);   
  Inc(AddDataRVA, StubSize);

  SetBase(ImageNtHeaders.OptionalHeader.ImageBase);
  SetJump2OEP(ImageNtHeaders.OptionalHeader.AddressOfEntryPoint);
  GenerateRubbishCode(@Loader, 64, AddDataRVA);
  GenerateRubbishCode(Pointer(SignPos(@Loader, SIGN_OEP) - 20),
    16, GetCurrRVA2(SIGN_OEP, -20));
  GenerateRubbishCode(Pointer(SignPos(@Loader, SIGN_OEP) + 4),
    64, GetCurrRVA2(SIGN_OEP, 4));
  if cbxMutex.Checked then SetMutex(edtMutex.Text);

  J:= SetFilePointer(FHandle, 0, nil, FILE_CURRENT);
  I:= GetImportOffset;
  if I <> 0 then
  begin
    K2:= Random(256) + 1;
    S:= ImageNtHeaders.OptionalHeader.
      DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].Size;
    D:= ImageNtHeaders.OptionalHeader.
      DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress +
      ImageNtHeaders.OptionalHeader.ImageBase;
    SetImportCryptData(D, S, K2);
    SetFilePointer(FHandle, I+1, nil, FILE_BEGIN);
    for K:= 1 to S do
    begin
      ReadFile(FHandle, ByteBuf, 1, dwTemp, nil);
      ByteBuf:= ByteBuf xor K2;
      SetFilePointer(FHandle, -1, nil, FILE_CURRENT);
      WriteFile(FHandle, ByteBuf, 1, dwTemp, nil);
    end;  
    SetImportRVA(ImageNtHeaders.OptionalHeader.
      DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);
    ImageNtHeaders.OptionalHeader.
      DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress:=
        GetNewImportRVA(AddDataRVA);    
    ImageNtHeaders.OptionalHeader.
      DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].Size:= GetNewImportSize;
    ProcessImports(AddDataRVA, ImageNtHeaders.OptionalHeader.ImageBase);
  end;

  J:= SetFilePointer(FHandle, J, nil, FILE_BEGIN);

  SetFilePointer(FHandle, SectionHeadersOffset, nil, FILE_BEGIN);
  I:= 1;
  begin
    ReadFile(FHandle, SectionHeader, SizeOf(SectionHeader), dwTemp, nil);

    if CheckAllDirRVA(SectionHeader.VirtualAddress, SectionHeader.VirtualSize, True) then
    begin
      OldPhysicalSize:= SectionHeader.PhysicalSize;
      BufSize:= OldPhysicalSize;
      GetMem(Buf, BufSize);
      SetFilePointer(FHandle, SectionHeader.PhysicalOffset, nil, FILE_BEGIN);
      ReadFile(FHandle, Buf^, BufSize, dwTemp, nil);
      brStatus.Panels.Items[0].Text:= 'Compressing...';
      Application.ProcessMessages;
      SectionData:= PackSection(Buf, BufSize);
      SetFilePointer(FHandle, SectionHeader.PhysicalOffset, nil, FILE_BEGIN);
      WriteFile(FHandle, SectionData.Data^, SectionData.Size, dwTemp, nil);
      SectionHeader.PhysicalSize:= Align(SectionData.Size,
        ImageNtHeaders.OptionalHeader.FileAlignment);
      SavedSize:= OldPhysicalSize - SectionHeader.PhysicalSize;
      FreeMem(Buf);

      BufSize:= GetFileSize(FHandle, nil) - (SectionHeader.PhysicalOffset +
        OldPhysicalSize);
      GetMem(Buf, BufSize);
      SetFilePointer(FHandle, SectionHeader.PhysicalOffset +
        OldPhysicalSize, nil, FILE_BEGIN);
      ReadFile(FHandle, Buf^, BufSize, dwTemp, nil);
      SetFilePointer(FHandle, SectionHeader.PhysicalOffset +
        SectionHeader.PhysicalSize, nil, FILE_BEGIN);
      WriteFile(FHandle, Buf^, BufSize, dwTemp, nil);
      SetEndOfFile(FHandle);
      FreeMem(Buf);
      Dec(J, SavedSize);
      Dec(AddDataOffset, SavedSize);

      if ImageNtHeaders.FileHeader.NumberOfSections > 1 then
      begin
        SetFilePointer(FHandle, SectionHeadersOffset +
          SizeOf(SectionHeader2), nil, FILE_BEGIN);
        for K:= 2 to ImageNtHeaders.FileHeader.NumberOfSections do
        begin
          ReadFile(FHandle, SectionHeader2, SizeOf(SectionHeader2), dwTemp, nil);
          Dec(SectionHeader2.PhysicalOffset, SavedSize);
          SetFilePointer(FHandle, -SizeOf(SectionHeader2), nil, FILE_CURRENT);
          WriteFile(FHandle, SectionHeader2, SizeOf(SectionHeader2), dwTemp, nil);
        end;
      end;
      SetMode(True);
      SetSize(SectionHeader.VirtualSize);
    end;

    SetFilePointer(FHandle, SectionHeadersOffset +
      DWORD(I - 1) * SizeOf(SectionHeader), nil, FILE_BEGIN);
    WriteFile(FHandle, SectionHeader, SizeOf(SectionHeader), dwTemp, nil);
  end;

  brStatus.Panels.Items[0].Text:= 'Encrypting...';
  Application.ProcessMessages;

  
  CryptData(AddDataRVA + ImageNtHeaders.OptionalHeader.ImageBase + CRY_START);
  Dec(AddDataRVA, StubSize);

  SetFilePointer(FHandle, J, nil, FILE_BEGIN);
  WriteFile(FHandle, Pointer(@Loader)^, GetLoaderSize, dwTemp, nil);
  RestoreLoader;

  BufSize:= AddDataOffset + SizeOfAddData -
    SetFilePointer(FHandle, 0, nil, FILE_CURRENT);
  GetMem(Buf, BufSize);
  GenerateRubbishCode(Buf, BufSize, GetCurrRVA);
  WriteFile(FHandle, Buf^, BufSize, dwTemp, nil);
  FreeMem(Buf);
  
  {****************************************************************************}
  ImageNtHeaders.OptionalHeader.AddressOfEntryPoint:= AddDataRVA;

  SetFilePointer(FHandle, DosHeader._lfanew, nil, FILE_BEGIN);
  WriteFile(FHandle, ImageNtHeaders, SizeOf(ImageNtHeaders), dwTemp, nil);
  CloseHandle(FHandle);
  brStatus.Panels.Items[0].Text:= 'Ready...';
  Application.ProcessMessages;
  Result:= True;
end;

procedure TfrmMain.WMSysCommand(var Msg: TWMSysCommand);
begin
  if Msg.CmdType = SC_ABOUT_ITEM then
    ShowAboutDlg
  else
    inherited;
end;

procedure TfrmMain.IconCallBackMessage(var Msg : TMessage);
begin
  case Msg.lParam of
    WM_LBUTTONDOWN,
    WM_RBUTTONDOWN:
    begin
      SetWindowPos(FindWindow(nil, PChar(PROG_NAME)), 0, 0, 0, 0, 0,
        SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOMOVE);
      SetForegroundWindow(Handle);
    end;
  end;
end; 

procedure TfrmMain.WMWindowPosChanging(var Msg: TWMWindowPosChanging);
var
  WorkArea: TRect;
  StickAt: Word;
begin
  StickAt:= 10;
  SystemParametersInfo(SPI_GETWORKAREA, 0, @WorkArea, 0);
  with WorkArea, Msg.WindowPos^ do
  begin
    Right:= Right - cx;
    Bottom:= Bottom - cy;
    if Abs(Left - x) <= StickAt then x:= 0;
    if Abs(Right - x) <= StickAt then x:= Right;
    if Abs(Top - y) <= StickAt then y:= 0;
    if Abs(Bottom - y) <= StickAt then y:= Bottom;
  end;
  inherited;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  hSysMenu: HMENU;
  VerInfo: Pointer;
  VerInfoSize: DWORD;
  VerValue: PVSFixedFileInfo;
  VerValueSize: DWORD;
  NameValue: PChar;
  NameValueSize: DWORD;
begin
  SetErrorMode(SEM_FAILCRITICALERRORS);
  VerInfoSize:= GetFileVersionInfoSize(PChar(ParamStr(0)), VerInfoSize);
  GetMem(VerInfo, VerInfoSize);          
  GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, 'StringFileInfo\040904E4\ProductName',
    Pointer(NameValue), NameValueSize);
  PROG_NAME:= NameValue;
  VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
  PROG_VERS:= Format('%d.%d',
    [VerValue^.dwProductVersionMS shr 16, VerValue^.dwProductVersionMS and $FFFF]);
  FreeMem(VerInfo, VerInfoSize);
  Application.Title:= PROG_NAME;
  PROG_NAME:= PROG_NAME + #32 + PROG_VERS;
  Application.OnException:= ExceptHook;
  if OpenMutex(MUTEX_ALL_ACCESS, False, PChar(PROG_NAME + '_MUTEX')) <> 0 then
  begin
    SetWindowPos(FindWindow(nil, PChar(PROG_NAME)), 0, 0, 0, 0, 0,
      SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOMOVE);
    SetForegroundWindow(FindWindow(nil, PChar(PROG_NAME)));
    FatalExit(1);
    Application.Restore;
  end else
    CreateMutex(nil, False, PChar(PROG_NAME + '_MUTEX')); 
  Caption:= PROG_NAME;
  hSysMenu:= GetSystemMenu(Handle, False);
  DeleteMenu(hSysMenu, SC_SIZE, MF_BYCOMMAND);
  DeleteMenu(hSysMenu, SC_MAXIMIZE, MF_BYCOMMAND);
  DeleteMenu(hSysMenu, SC_RESTORE, MF_BYCOMMAND);
  AppendMenu(hSysMenu, MF_SEPARATOR, 0, nil);
  AppendMenu(hSysMenu, MF_STRING, SC_ABOUT_ITEM, 'About...');
  hSysMenu:= GetSystemMenu(Application.Handle, False);
  DeleteMenu(hSysMenu, SC_SIZE, MF_BYCOMMAND);
  DeleteMenu(hSysMenu, SC_MAXIMIZE, MF_BYCOMMAND);
  DeleteMenu(hSysMenu, SC_RESTORE, MF_BYCOMMAND);
  //if OpenMutex(MUTEX_ALL_ACCESS, False, 'MUTEX_ID_00000001') = 0 then FatalExit(0);
  with FIconData do
  begin
    cbSize:= SizeOf(FIconData);
    Wnd:= Handle;
    uID:= 1;
    uFlags:= NIF_ICON or NIF_TIP or NIF_MESSAGE;
    hIcon:= Application.Icon.Handle;
    StrPCopy(szTip, Application.Title);
    uCallBackMessage:= WM_TRAYICON;
  end;
  Shell_NotifyIcon(NIM_ADD, @FIconData);
  Randomize;
  FPacker:= TaPLib.Create(nil);
  FPacker.CallBack:= CallBack;
  if ParamCount > 0 then
  begin
    dlgOpen.FileName:= ParamStr(1);
    if FileExists(dlgOpen.FileName) then
    begin
      edtFilePath.Text:= dlgOpen.FileName;
      brStatus.Panels.Items[0].Text:= 'Checking...';
      Application.ProcessMessages;
      btnProtect.Enabled:= CheckInputFile(edtFilePath.Text);
      brStatus.Panels.Items[0].Text:= 'Ready...';
      Application.ProcessMessages;
    end;
    if btnProtect.Enabled then
      if UpperCase(ParamStr(2)) = '\PN' then
        btnProtectClick(Sender);
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @FIconData);
  FPacker.Free;
end;

procedure TfrmMain.btnQuitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmMain.btnBrowseClick(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    if FileExists(dlgOpen.FileName) then
    begin
      edtFilePath.Text:= dlgOpen.FileName;
      brStatus.Panels.Items[0].Text:= 'Checking...';
      Application.ProcessMessages;
      btnProtect.Enabled:= CheckInputFile(edtFilePath.Text);
      brStatus.Panels.Items[0].Text:= 'Ready...';
      Application.ProcessMessages;
    end;
  end;
end;

procedure TfrmMain.btnTestClick(Sender: TObject);
begin
  if not ExecuteFile(edtFilePath.Text, '') then
    ShowMessage('Can not execute this file');
end;

procedure TfrmMain.btnProtectClick(Sender: TObject);
begin
  btnProtect.Enabled:= False;
  btnBrowse.Enabled:= False;
  pnlSettings.Enabled:= False;
  btnTest.Enabled:= False;
  btnTest.Enabled:= ProtectFile(edtFilePath.Text);
  if btnTest.Enabled then
    ShowMessage('File were successfully protected');
  brStatus.Panels.Items[0].Text:= 'Ready...';
  Application.ProcessMessages;
  pnlSettings.Enabled:= True;
  btnProtect.Enabled:= True;
  btnBrowse.Enabled:= True;
end;

procedure TfrmMain.cbxMutexClick(Sender: TObject);
begin
  edtMutex.Enabled:= cbxMutex.Checked;
end;

end.
