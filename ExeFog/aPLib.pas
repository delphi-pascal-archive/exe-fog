(*
 * aPLib compression library  -  the smaller the better :)
 *
 * Delphi interface to aPLib Delphi objects
 *
 * Copyright (c) 1998-2004 by Joergen Ibsen / Jibz
 * All Rights Reserved
 *
 * http://www.ibsensoftware.com/
 *)

unit aPLib;

interface

uses
  Windows;

const
  aP_pack_break    : DWORD = 0;
  aP_pack_continue : DWORD = 1;

  aPLib_Error      : DWORD = DWORD(-1); 

type

  TaPack_Status = function(w0, w1, w2: DWORD; cbparam: Pointer): DWORD;cdecl;

  function _aP_pack(var Source; var Destination; Length: DWORD; var WorkMem;
    Callback: TaPack_Status; cbparam: Pointer): DWORD; cdecl;

  function _aP_workmem_size(InputSize: DWORD): DWORD; cdecl;

  function _aP_max_packed_size(InputSize: DWORD): DWORD; cdecl;

  function _aP_depack_asm(var Source, Destination): DWORD; cdecl;

  function _aP_depack_asm_fast(var Source, Destination): DWORD; cdecl;

  function _aP_depack_asm_safe(var Source; SrcLen: DWORD; var Destination;
    DstLen: DWORD): DWORD; cdecl;

  function _aP_crc32(var Source; Length: DWORD): DWORD; cdecl;

  function _aPsafe_pack(var Source; var Destination; Length: DWORD; var WorkMem;
    Callback: TaPack_Status; cbparam: Pointer): DWORD; cdecl;

  function _aPsafe_check(var Source): DWORD; cdecl;

  function _aPsafe_get_orig_size(var Source): DWORD; cdecl;

  function _aPsafe_depack(var Source; SrcLen: DWORD; var Destination;
    DstLen: DWORD): DWORD; cdecl;

implementation

  function _aP_pack(var Source; var Destination; Length: DWORD; var WorkMem;
    CallBack: TaPack_Status; cbparam: Pointer): DWORD; external;

  function _aP_workmem_size(InputSize: DWORD): DWORD; external;

  function _aP_max_packed_size(InputSize: DWORD): DWORD; external;

  function _aP_depack_asm(var Source, Destination): DWORD; external;

  function _aP_depack_asm_fast(var Source, Destination): DWORD; external;

  function _aP_depack_asm_safe(var Source; SrcLen: DWORD; var Destination;
    DstLen: DWORD): DWORD; external;

  function _aP_crc32(var Source; Length : DWORD): DWORD; external;

  function _aPsafe_pack(var Source; var Destination; Length: DWORD; var WorkMem;
    CallBack: TaPack_Status; cbparam: Pointer): DWORD; external;

  function _aPsafe_check(var Source): DWORD; external;

  function _aPsafe_get_orig_size(var Source): DWORD; external;

  function _aPsafe_depack(var Source; SrcLen: DWORD; var Destination;
    DstLen: DWORD): DWORD; external;

{$L aplib\aplib.obj}
{$L aplib\depack.obj}
{$L aplib\depackf.obj}
{$L aplib\depacks.obj}
{$L aplib\crc32.obj}
{$L aplib\spack.obj}
{$L aplib\scheck.obj}
{$L aplib\sgetsize.obj}
{$L aplib\sdepack.obj}

end.
