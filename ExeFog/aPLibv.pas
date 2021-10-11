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

unit aPLibv;

interface

uses
  Windows, SysUtils, Classes, aPLib;

const
  aP_pack_break    : DWORD = 0;
  aP_pack_continue : DWORD = 1;

  aPLib_Error      : DWORD = DWORD(-1); 

type
  TaPLib = class(TComponent)
  private
    FWorkMem: Pointer;
    FLength: DWORD;
    FSource: Pointer;
    FDestination: Pointer;
  public
    CallBack: TaPack_Status;
    procedure Pack;
    procedure DePack;
    property Source: Pointer read FSource write FSource;
    property Destination: Pointer read FDestination write FDestination;
    property Length: DWORD read FLength write FLength;
  end;

  procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TaPLib]);
end;

procedure TaPLib.Pack;
begin
  if FDestination <> nil then
  begin
     FreeMem(FDestination);
     FDestination := nil;
  end;
  if FWorkMem <> nil then
  begin
     FreeMem(FWorkMem);
     FWorkMem := nil;
  end;
  GetMem(FDestination, _aP_max_packed_size(FLength));
  if FDestination = nil then
    raise Exception.Create('Out of memory');
  GetMem(FWorkMem, _aP_workmem_size(FLength));
  if FWorkMem = nil then
    raise Exception.Create('Out of memory');
  FLength:= _aP_pack(FSource^, FDestination^, FLength, FWorkMem^, CallBack, nil);
  if FLength = aPLib_Error then
    raise Exception.Create('Compression error');
end;

procedure TaPLib.DePack;
var
  DLength : DWORD;
begin
  if FDestination <> nil then
  begin
     FreeMem(FDestination);
     FDestination:= nil;
  end;
  DLength:= _aPsafe_get_orig_size(FSource^);
  if DLength = aPLib_Error then
    raise Exception.Create('File is not packed with aPLib');
  Getmem(FDestination, DLength);
  if FDestination = nil then
    raise Exception.Create('Out of memory');
  FLength:= _aPsafe_depack(FSource^, FLength, FDestination^, DLength);
  if FLength = aPLib_Error then
    raise Exception.Create('Decompression error');
end;

end.
