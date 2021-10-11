unit PE_Files;

{$H+}
{$ALIGN OFF}

interface

uses
  Windows;

type
  P_DOS_HEADER = ^T_DOS_HEADER;
  T_DOS_HEADER = packed record
    e_magic: Word;
    e_cblp: Word;
    e_cp: Word;
    e_crlc: Word;
    e_cparhdr: Word;
    e_minalloc: Word;
    e_maxalloc: Word;
    e_ss: Word;
    e_sp: Word;
    e_csum: Word;
    e_ip: Word;
    e_cs: Word;
    e_lfarlc: Word;
    e_ovno: Word;
    e_res: packed array[0..3] of Word;
    e_oemid: Word;
    e_oeminfo: Word;
    e_res2: packed array[0..9] of Word;
    e_lfanew: DWORD;   
  end;

  P_PE_Header = ^T_PE_Header;
  T_PE_Header = packed record
    Signature: DWORD;
    CPU_Type: Word;
    Number_Of_Object: Word;
    Time_Date_Stamp: DWORD;
    Ptr_to_COFF_Table: DWORD;
    COFF_table_size: DWORD;
    NT_Header_Size: Word;
    Flags: Word;
    Magic: Word;
    Link_Major: Byte;
    Link_Minor: Byte;
    Size_Of_Code: DWORD;
    Size_Of_Init_Data: DWORD;
    Size_Of_UnInit_Data: DWORD;
    Entry_Point_RVA: DWORD;
    Base_Of_Code: DWORD;
    Base_Of_Data: DWORD;
    Image_Base: DWORD;
    Object_Align: DWORD;
    File_Align: DWORD;
    OS_Major: Word;
    OS_Minor: Word;
    User_Major: Word;
    User_Minor: Word;
    SubSystem_Major: Word;
    SubSystem_Minor: Word;
    Reserved_1: DWORD;
    Image_Size: DWORD;
    Header_Size: DWORD;
    File_CheckSum: DWORD;
    SubSystem: Word;
    DLL_Flags: Word;
    Stack_Reserve_Size: DWORD;
    Stack_Commit_Size: DWORD;
    Heap_Reserve_Size: DWORD;
    Heap_Commit_Size: DWORD;
    Loader_Flags: DWORD;
    Number_of_RVA_and_Sizes: DWORD;
    Export_Table_RVA: DWORD;
    Export_Data_Size: DWORD;
    Import_Table_RVA: DWORD;
    Import_Data_Size: DWORD;
    Resource_Table_RVA: DWORD;
    Resource_Data_Size: DWORD;
    Exception_Table_RVA: DWORD;
    Exception_Data_Size: DWORD;
    Security_Table_RVA: DWORD;
    Security_Data_Size: DWORD;
    Fix_Up_Table_RVA: DWORD;
    Fix_Up_Data_Size: DWORD;
    Debug_Table_RVA: DWORD;
    Debug_Data_Size: DWORD;
    Image_Description_RVA: DWORD;
    Desription_Data_Size: DWORD;
    Machine_Specific_RVA: DWORD;
    Machine_Data_Size: DWORD;
    TLS_RVA: DWORD;
    TLS_Data_Size: DWORD;
    Load_Config_RVA: DWORD;
    Load_Config_Data_Size: DWORD;
    Bound_Import_RVA: DWORD;
    Bound_Import_Size: DWORD;
    IAT_RVA: DWORD;
    IAT_Data_Size: DWORD;
    Reserved_3: array[1..8] of Byte;
    Reserved_4: array[1..8] of Byte;
    Reserved_5: array[1..8] of Byte;
  end;

  T_Object_Name =  array[0..7] of Char;

type
  P_Object_Entry = ^T_Object_Entry;
  T_Object_Entry = packed record
    Object_Name: T_Object_Name;
    Virtual_Size: DWORD;
    Section_RVA: DWORD;
    Physical_Size: DWORD;
    Physical_Offset: DWORD;
    Reserved: array[1..$0C] of Byte;
    Object_Flags: DWORD;
  end;

  P_Resource_Directory_Table = ^T_Resource_Directory_Table;
  T_Resource_Directory_Table = packed record
    Flags: DWORD;
    Time_Date_Stamp: DWORD;
    Major_Version: Word;
    Minor_Version: Word;
    Name_Entry: Word;
    ID_Number_Entry: Word;
  end;

  P_Resource_Entry_Item = ^T_Resource_Entry_Item;
  T_Resource_Entry_Item = packed record
    Name_RVA_or_Res_ID: DWORD;
    Data_Entry_or_SubDir_RVA: DWORD;
  end;

  P_Resource_Entry = ^T_Resource_Entry;
  T_Resource_Entry = packed record
    Data_RVA: DWORD;
    Size: DWORD;
    CodePage: DWORD;
    Reserved: DWORD;
  end;

  P_Export_Directory_Table = ^T_Export_Directory_Table;
  T_Export_Directory_Table = packed record
    Flags: DWORD;
    Time_Date_Stamp: DWORD;
    Major_Version: Word;
    Minor_Version: Word;
    Name_RVA: DWORD;
    Ordinal_Base: DWORD;
    Number_of_Functions: DWORD;
    Number_of_Names: DWORD;
    Address_of_Functions: DWORD;
    Address_of_Names: DWORD;
    Address_of_Ordinals: DWORD;
  end;

  P_Import_Directory_Entry = ^T_Import_Directory_Entry;
  T_Import_Directory_Entry = packed record
    Original_First_Thunk: DWORD;
    Time_Date_Stamp: DWORD;
    Forward_Chain: DWORD;
    Name_RVA: DWORD;
    First_Thunk: DWORD;
  end;

const
  E_OK                  =  0;
  E_FILE_NOT_FOUND      =  1;
  E_CANT_OPEN_FILE      =  2;
  E_ERROR_READING       =  3;
  E_ERROR_WRITING       =  4;
  E_NOT_ENOUGHT_MEMORY  =  5;
  E_INVALID_PE_FILE     =  6;

  M_ERR_CAPTION         =  'PE File Error...';
  M_FILE_NOT_FOUND      =  'Can''t find file. ';
  M_CANT_OPEN_FILE      =  'Can''t open file. ';
  M_ERROR_READING       =  'Error reading file. ';
  M_ERROR_WRITING       =  'Error writing file. ';
  M_NOT_ENOUGHT_MEMORY  =  'Can''t alloc memory. ';
  M_INVALID_PE_FILE     =  'Invalid PE file. ';

  Minimum_File_Align    = $0200;
  Minimum_Virtual_Align = $1000;

type
  PE_File = class(TObject)
  public
    DOS_HEADER: P_DOS_HEADER;
    PE_Header: P_PE_Header;
    LastError: DWORD;
    ShowDebugMessages: Boolean;
    pMap: Pointer;
    PreserveOverlay: Boolean;
    IsDLL: Boolean;
    File_Size: DWORD;
    OverlayData: Pointer;
    OverlaySize: DWORD;
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(FileName: string);
    procedure SaveToFile(FileName: string);
    procedure FlushFileCheckSum;
    procedure OptimizeHeader(WipeJunk: Boolean);
    procedure OptimizeFileAlignment;
    procedure FlushRelocs(ProcessDll: Boolean);
    procedure OptimizeFile(AlignHeader,WipeJunk,KillRelocs,KillInDll: Boolean);
  private
    PObject: P_Object_Entry;
    Data_Size: DWORD;
    function IsPEFile(pMap: Pointer): Boolean;
    procedure DebugMessage(MessageText: string);
    procedure GrabInfo;
    function IsAlignedTo(Offs, AlignTo: DWORD): Boolean;
    function AlignBlock(Start: Pointer; Size: DWORD; AlignTo: DWORD): DWORD;
  end;

implementation

constructor PE_File.Create;
begin
  inherited Create;
  LastError:= E_OK;
  ShowDebugMessages:= False;
  DOS_HEADER:= nil;
  PE_Header:= nil;
  pMap:= nil;
  IsDLL:= False;
  File_Size:= 0;
  Data_Size:= 0;
  PreserveOverlay:= False;
  OverlayData:= nil;
  OverlaySize:= 0;
end;

destructor PE_File.Destroy;
begin
  if pMap <> nil then FreeMem(pMap);
  if OverlayData <> nil then FreeMem(OverlayData);
  inherited Destroy;
end;

procedure PE_File.DebugMessage(MessageText: string);
begin
  MessageBox(0, PChar(MessageText), M_ERR_CAPTION, MB_OK or MB_ICONSTOP);
end;

function PE_File.IsPEFile(pMap: Pointer): Boolean;
var
  DOS_Header: P_DOS_Header;
  PE_Header: P_PE_Header;
begin
  Result:= False;
  if pMap = nil then Exit;
  DOS_Header:= pMap;
  if DOS_Header.e_magic <> IMAGE_DOS_SIGNATURE  then Exit;
  if (DOS_Header.e_lfanew < $40) or (DOS_Header.e_lfanew > $F08) then Exit;
  PE_Header:= Pointer(DOS_Header.e_lfanew + DWORD(pMap));
  if PE_Header.Signature <> IMAGE_NT_SIGNATURE  then Exit;         
  Result:= True;
end;

procedure PE_File.GrabInfo;
var
  I: Integer;
begin
  IsDLL:= (PE_Header.Flags and IMAGE_FILE_DLL) <> 0;
  Data_Size:= PE_Header^.Header_Size;
  if PE_Header.Number_Of_Object > 0 then
  begin
    PObject:= Pointer(DWORD(PE_Header) + SizeOf(T_PE_Header));
    for I:= 1 to PE_Header.Number_Of_Object do
    begin
      if (PObject.Physical_Offset > 0) and (PObject.Physical_Size > 0) then
        Inc(Data_Size, PObject.Physical_Size);
      Inc(DWORD(PObject), SizeOf(T_Object_Entry));
    end;
  end;
end;

procedure PE_File.LoadFromFile(FileName: string);
var
  Header: Pointer;
  hFile: DWORD;
  Readed, I: DWORD;
  FindData: _WIN32_FIND_DATAA;
begin
  if FindFirstFile(PChar(FileName), FindData) = INVALID_HANDLE_VALUE then
  begin
    LastError:= E_FILE_NOT_FOUND;
    if ShowDebugMessages then
      DebugMessage(M_FILE_NOT_FOUND + FileName);
    Exit;
  end;
  hFile:= CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if hFile = INVALID_HANDLE_VALUE then
  begin
    LastError:= E_CANT_OPEN_FILE;
    if ShowDebugMessages then
      DebugMessage(M_CANT_OPEN_FILE + FileName);
    Exit;
  end;
  GetMem(Header, $1000);
  if Header = nil then
  begin
    LastError:= E_NOT_ENOUGHT_MEMORY;
    if ShowDebugMessages then
      DebugMessage(M_NOT_ENOUGHT_MEMORY);
    Exit;
  end;
  ReadFile(hFile, Header^, $1000, Readed, nil);
  if (Readed < $200) or (not IsPEFile(Header)) then
  begin
    LastError:= E_INVALID_PE_FILE;
    if ShowDebugMessages then
      DebugMessage(M_INVALID_PE_FILE);
    CloseHandle(hFile);
    FreeMem(Header);
    Exit;
  end;
  DOS_Header:= Header;
  PE_Header:= Pointer(DOS_Header.e_lfanew + DWORD(Header));
  if pMap <> nil then FreeMem(pMap);
  if OverlayData <> nil then FreeMem(OverlayData);
  GetMem(pMap, PE_Header.Image_Size);
  if pMap = nil then
  begin
    LastError:= E_NOT_ENOUGHT_MEMORY;
    if ShowDebugMessages then
      DebugMessage(M_NOT_ENOUGHT_MEMORY);
    CloseHandle(hFile);
    FreeMem(Header);
    Exit;
  end;
  FillChar(pMap^, PE_Header.Image_Size, 0);
  Move(Header^, pMap^, PE_Header.Header_Size);
  FreeMem(Header);
  DOS_Header:= pMap;
  PE_Header:= Pointer(DOS_Header.e_lfanew + DWORD(pMap));
  PObject:= Pointer(DWORD(PE_Header) + SizeOf(T_PE_Header));
  for I:= 1 to PE_Header.Number_Of_Object do
  begin
    if PE_Header.Header_Size > PObject.Section_RVA then
      PE_Header.Header_Size:= PObject.Section_RVA;
    Inc(DWORD(PObject), SizeOf(T_Object_Entry));
  end;
  GrabInfo;
  File_Size:= GetFileSize(hFile, nil);
  if (PreserveOverlay = True) and (File_Size > Data_Size) then
  begin
    OverlaySize:= File_Size - Data_Size;
    GetMem(OverlayData, OverlaySize);
    if OverlayData = nil then
    begin
      LastError:= E_NOT_ENOUGHT_MEMORY;
      if ShowDebugMessages then
        DebugMessage(M_NOT_ENOUGHT_MEMORY);
      CloseHandle(hFile);
      Exit;
    end;
    SetFilePointer(hFile, Data_Size, nil, FILE_BEGIN);
    ReadFile(hFile, OverlayData^, OverlaySize, Readed, nil);
  end;
  if PE_Header.Number_Of_Object = 0 then begin
    LastError:= E_OK;
    CloseHandle(hFile);
    Exit;
  end; 
  PObject:= Pointer(DWORD(PE_Header) + SizeOf(T_PE_Header));
  for I:= 1 to PE_Header.Number_Of_Object do
  begin
    if (PObject.Physical_Offset = 0) and (PObject.Physical_Size <> 0) then
    begin
      PObject.Virtual_Size:= PObject.Physical_Size;
      PObject.Physical_Size:= 0;
    end;
    if (PObject.Physical_Offset > 0) and (PObject.Physical_Size > 0) then
    begin
      SetFilePointer(hFile, PObject.Physical_Offset, nil, FILE_BEGIN);
      ReadFile(hFile, Pointer(DWORD(pMap) + PObject.Section_RVA)^,
        PObject.Physical_Size, Readed, nil);
      if Readed <> PObject.Physical_Size then
      begin
        LastError:= E_ERROR_READING;
        if ShowDebugMessages then
          DebugMessage(M_ERROR_READING + FileName);
        CloseHandle(hFile);
        Exit;
      end;
    end;
    Inc(DWORD(PObject), SizeOf(T_Object_Entry));
  end;
  CloseHandle(hFile);
  LastError:= E_OK;
end;

procedure PE_File.SaveToFile(FileName: string);
var
  I: DWORD;
  hFile: DWORD;
  Written: DWORD;
begin
  if (pMap = nil) or (not IsPEFile(pMap)) then begin
    LastError:= E_INVALID_PE_FILE;
    if ShowDebugMessages then DebugMessage(M_INVALID_PE_FILE);
    Exit;
  end;
  hFile:= CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE, nil, CREATE_ALWAYS,
    FILE_ATTRIBUTE_NORMAL, 0);
  if hFile = INVALID_HANDLE_VALUE then
  begin
    LastError:= E_CANT_OPEN_FILE;
    if ShowDebugMessages then
      DebugMessage(M_CANT_OPEN_FILE + FileName);
    Exit;
  end;
  File_Size:= PE_Header.Header_Size;
  SetFilePointer(hFile, 0, nil, FILE_BEGIN);
  if (not WriteFile(hFile, pMap^, PE_Header.Header_Size, Written, nil)) or
    (Written <> PE_Header.Header_Size) then
  begin
    LastError:= E_ERROR_WRITING;
    if ShowDebugMessages then
      DebugMessage(M_ERROR_WRITING + FileName);
    CloseHandle(hFile);
    Exit;
  end;
  if PE_Header.Number_Of_Object > 0 then
  begin        
    PObject:= Pointer(DWORD(PE_Header) + SizeOf(T_PE_Header));
    for I:= 1 to PE_Header.Number_Of_Object do
    begin
      if (not WriteFile(hFile, Pointer(DWORD(pMap) + PObject.Section_RVA)^,
        PObject.Physical_Size, Written, nil))
        or (Written <> PObject.Physical_Size) then
      begin
        LastError:= E_ERROR_WRITING;
        if ShowDebugMessages then
          DebugMessage(M_ERROR_WRITING + FileName);
        CloseHandle(hFile);
        Exit;
      end;
      Inc(File_Size, PObject.Physical_Size);
      Inc(DWORD(PObject), SizeOf(T_Object_Entry));
    end;
  end;
  if (PreserveOverlay = True) and (OverlaySize > 0) then
  begin
    Inc(File_Size, OverlaySize);
    SetFilePointer(hFile, 0, nil, FILE_END);
    WriteFile(hFile, OverlayData^, OverlaySize, Written, nil);
  end;
  CloseHandle(hFile);
  LastError:= E_OK;
end;

function PE_File.IsAlignedTo(Offs, AlignTo: DWORD): Boolean;
begin
  Result:= (Offs mod AlignTo) = 0;
end;

function PE_File.AlignBlock(Start: Pointer; Size: DWORD; AlignTo: DWORD): DWORD;
var
  P: ^Byte;
begin
  Result:= 0;
  if Size = 0 then Exit;
  P:= Pointer(DWORD(Start) + Size - 1);
  while (P^ = 0) and (DWORD(P) > DWORD(Start)) do Dec(DWORD(P));
  if (DWORD(P) = DWORD(Start)) and (P^ = 0) then Exit;
  while (not IsAlignedTo(DWORD(P) - DWORD(Start), AlignTo))
    and (DWORD(P) < (DWORD(Start) + Size)) do Inc(DWORD(P));
  Result:= DWORD(P) - DWORD(Start);
end;

procedure PE_File.OptimizeHeader(WipeJunk: Boolean);
var
  AllObjSize: DWORD;
  NewHdrSize: DWORD;
  HdrSize, I: DWORD;
  NewHdrOffs: ^Word;
begin
  if (pMap = nil) or (not IsPEFile(pMap)) then
  begin
    LastError:= E_INVALID_PE_FILE;
    if ShowDebugMessages then
      DebugMessage(M_INVALID_PE_FILE);
    Exit;                                           
  end;
  NewHdrOffs:= Pointer(DWORD(pMap) + $40);
  while ((NewHdrOffs^ <> 0) or
    (not IsAlignedTo(DWORD(NewHdrOffs) - DWORD(pMap), 16)) and
    (DWORD(NewHdrOffs) < DWORD(PE_Header)) ) do Inc(DWORD(NewHdrOffs));
  AllObjSize:= PE_Header.Number_Of_Object * SizeOf(T_Object_Entry);
  if (DWORD(NewHdrOffs) - DWORD(pMap)) < DOS_Header^.e_lfanew then
  begin
    DOS_Header.e_lfanew:= DWORD(NewHdrOffs) - DWORD(pMap);
    Move(PE_Header^, NewHdrOffs^, SizeOf(T_PE_Header) + AllObjSize);
    PE_Header:= Pointer(NewHdrOffs);
    if WipeJunk = False then
      FillChar(Pointer(DWORD(NewHdrOffs) + SizeOf(T_PE_Header) + AllObjSize)^,
        DWORD(PE_Header) - DWORD(NewHdrOffs), 0);
  end;
  if WipeJunk = True then
  begin
    HdrSize:= DOS_Header.e_lfanew + SizeOf(T_PE_Header) + AllObjSize;
    FillChar(Pointer(DWORD(pMap) + HdrSize)^, PE_Header.Header_Size-HdrSize, 0);
    if (PE_Header.Bound_Import_RVA  <> 0) or
      (PE_Header.Bound_Import_Size <> 0) then
    begin
      PE_Header.Bound_Import_RVA:= 0;
      PE_Header.Bound_Import_Size:= 0;
    end;
  end;
  NewHdrSize:= AlignBlock(pMap, PE_Header.Header_Size, Minimum_File_Align);
  if NewHdrSize < PE_Header.Header_Size then
  begin
    if PE_Header.Number_Of_Object > 0 then
    begin
      PObject:= Pointer(DWORD(PE_Header) + SizeOf(T_PE_Header));
      for I:= 1 to PE_Header.Number_Of_Object do
      begin
        Dec(PObject.Physical_Offset, PE_Header.Header_Size - NewHdrSize);
        Inc(DWORD(PObject), SizeOf(T_Object_Entry));
      end;
    end;
    PE_Header.Header_Size:= NewHdrSize;
  end;
  LastError:= E_OK;
end;

procedure PE_File.FlushRelocs(ProcessDll: Boolean);
begin
  if (pMap = nil) or (not IsPEFile(pMap)) then
  begin
    LastError:= E_INVALID_PE_FILE;
    if ShowDebugMessages then
      DebugMessage(M_INVALID_PE_FILE);
    Exit;
  end;
  LastError:= E_OK;
  if (not ProcessDll) and IsDLL then Exit;
  if (PE_Header.Fix_Up_Table_RVA = 0) or
    (PE_Header.Fix_Up_Data_Size = 0) then Exit;
  FillChar(Pointer(DWORD(pMap) + PE_Header^.Fix_Up_Table_RVA)^,
    PE_Header^.Fix_Up_Data_Size, 0);
  PE_Header^.Fix_Up_Table_RVA:= 0;
  PE_Header^.Fix_Up_Data_Size:= 0;
end;

procedure PE_File.OptimizeFileAlignment;
var
  OldSize: DWORD;
  NewSize: DWORD;
  LastOffs: DWORD;
  I: Integer;
begin
  if (pMap = nil) or (not IsPEFile(pMap)) then
  begin
    LastError:= E_INVALID_PE_FILE;
    if ShowDebugMessages then
      DebugMessage(M_INVALID_PE_FILE);
    Exit;
  end;
  LastError:= E_OK;
  PE_Header.File_Align:= Minimum_File_Align;
  if PE_Header.Number_Of_Object = 0 then Exit;
  LastOffs:= PE_Header.Header_Size;
  PObject:= Pointer(DWORD(PE_Header) + SizeOf(T_PE_Header));
  for I:= 1 to PE_Header.Number_Of_Object do
  begin
    if (PObject.Physical_Size > 0)
      and (PObject^.Physical_Offset >=  LastOffs) then
    begin
      OldSize:= PObject.Physical_Size;
      NewSize:= AlignBlock(Pointer(DWORD(pMap) + PObject.Section_RVA),
        PObject.Physical_Size, Minimum_File_Align);
      if NewSize < OldSize then
        PObject.Physical_Size:= NewSize;
    end;
    PObject.Physical_Offset:= LastOffs;
    Inc(LastOffs, PObject.Physical_Size);
    Inc(DWORD(PObject), SizeOf(T_Object_Entry));
  end;
end;

procedure PE_File.FlushFileCheckSum;
begin
  PE_Header.File_CheckSum:= 0;
end;

procedure PE_File.OptimizeFile(AlignHeader: Boolean; WipeJunk: Boolean;
  KillRelocs: Boolean; KillInDll: Boolean);
begin
  if (pMap = nil) or (not IsPEFile(pMap)) then
  begin
    LastError:= E_INVALID_PE_FILE;
    if ShowDebugMessages then
      DebugMessage(M_INVALID_PE_FILE);
    Exit;
  end;
  if AlignHeader then
  begin
    OptimizeHeader(WipeJunk);
    if LastError <> E_OK then
    begin
      if ShowDebugMessages then
        DebugMessage(M_INVALID_PE_FILE);
      Exit;
    end;
  end;
  if KillRelocs then
  begin
    FlushRelocs(KillInDll);
    if LastError <> E_OK then
    begin
      if ShowDebugMessages then
        DebugMessage(M_INVALID_PE_FILE);
      Exit;
    end;
  end;
  OptimizeFileAlignment;
  if LastError <> E_OK then
  begin
    if ShowDebugMessages then
      DebugMessage(M_INVALID_PE_FILE);
    Exit;
  end;
  FlushFileCheckSum; 
end;

end.            
