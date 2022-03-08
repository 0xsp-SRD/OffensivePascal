unit mini_dump_un;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  SysUtils,JwaTlHelp32,windows;
const
  //DbgHelp 6.1 and earlier:  This value is not supported.
  MemoryInfoListStream        = 16;
  ThreadInfoListStream        = 17;
  HandleOperationListStream   = 18;

  //MINIDUMP_TYPE
  MiniDumpWithoutOptionalData              = $00000400;
  MiniDumpWithFullMemoryInfo               = $00000800;
  MiniDumpWithThreadInfo                   = $00001000;
  MiniDumpWithCodeSegs                     = $00002000;
  MiniDumpWithoutAuxiliaryState            = $00004000;
  MiniDumpWithFullAuxiliaryState           = $00008000;
  MiniDumpWithPrivateWriteCopyMemory       = $00010000;
  MiniDumpIgnoreInaccessibleMemory         = $00020000;
  MiniDumpWithTokenInformation             = $00040000;

type
  PMINIDUMP_THREAD_INFO = ^MINIDUMP_THREAD_INFO;
  {$EXTERNALSYM PMINIDUMP_THREAD_INFO}
  _MINIDUMP_THREAD_INFO = record
    ThreadId,
    DumpFlags,                   //The flags that indicate the thread state. This member can be 0 or one of the MINIDUMP_THREAD_INFO_xxx values.
    DumpError,                   //An HRESULT value that indicates the dump status.
    ExitStatus: ULONG32;         //The thread termination status code.
    CreateTime,                  //The time when the thread was created, in 100-nanosecond intervals since January 1, 1601 (UTC).
    ExitTime,                    //The time when the thread exited, in 100-nanosecond intervals since January 1, 1601 (UTC).
    KernelTime,                  //The time executed in kernel mode, in 100-nanosecond intervals.
    UserTime,                    //The time executed in user mode, in 100-nanosecond intervals.
    StartAddress,                //The starting address of the thread.
    Affinity: ULONG64;           //The processor affinity mask.

    //MINIDUMP_THREAD_INFO.DumpFlags: The flags that indicate the thread state:
    const
      //A placeholder thread due to an error accessing the thread. No thread information exists beyond the thread identifier.
      MINIDUMP_THREAD_INFO_ERROR_THREAD = $00000001;
      //The thread has exited (not running any code) at the time of the dump.
      MINIDUMP_THREAD_INFO_EXITED_THREAD = $00000004;
      //Thread context could not be retrieved.
      MINIDUMP_THREAD_INFO_INVALID_CONTEXT = $00000010;
      //Thread information could not be retrieved.
      MINIDUMP_THREAD_INFO_INVALID_INFO = $00000008;
      //TEB information could not be retrieved.
      MINIDUMP_THREAD_INFO_INVALID_TEB = $00000020;
      //This is the thread that called MiniDumpWriteDump.
      MINIDUMP_THREAD_INFO_WRITING_THREAD = $00000002;
  end;
  {$EXTERNALSYM _MINIDUMP_THREAD_INFO}
  MINIDUMP_THREAD_INFO = _MINIDUMP_THREAD_INFO;
  {$EXTERNALSYM MINIDUMP_THREAD_INFO}
  TMinidumpThread_INFO = MINIDUMP_THREAD_INFO;
  PMinidumpThread_INFO = PMINIDUMP_THREAD_INFO;

  PMINIDUMP_THREAD_INFO_LIST = ^MINIDUMP_THREAD_INFO_LIST;
  _MINIDUMP_THREAD_INFO_LIST = record
    SizeOfHeader,                //The size of the header data for the stream, in bytes. This is generally sizeof(MINIDUMP_THREAD_INFO_LIST).
    SizeOfEntry: ULONG;          //The size of each entry following the header, in bytes. This is generally sizeof(MINIDUMP_THREAD_INFO).
    NumberOfEntries: ULONG64;    //The number of entries in the stream. These are generally MINIDUMP_THREAD_INFO structures. The entries follow the header.
    Threads: array[0..0] of _MINIDUMP_THREAD_INFO;
  end;
  MINIDUMP_THREAD_INFO_LIST = _MINIDUMP_THREAD_INFO_LIST;
  TMinidumpThread_INFO_LIST = MINIDUMP_THREAD_INFO_LIST;
  PMinidumpThread_INFO_LIST = PMINIDUMP_THREAD_INFO_LIST;




procedure MakeMinidump(aPID:DWORD; const aOutputFile: string);

implementation

uses
  JwaImageHlp;



function MiniDumpWriteDump(hProcess: THANDLE; ProcessId: DWORD; hFile: THANDLE; DumpType: DWORD; ExceptionParam: pointer; UserStreamParam: pointer; CallbackParam: pointer): BOOL; stdcall;
    external 'dbghelp.dll' name 'MiniDumpWriteDump';
//{$EXTERNALSYM MiniDumpWriteDump}

const
  SE_DEBUG_NAME = 'SeDebugPrivilege';     //this is needed for deugging memeory


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
  	  CloseHandle( snapshot );
  	End; { try }
    End;

  function NTSetPrivilege(sPrivilege: string; bEnabled: Boolean): Boolean;
  var
    hToken: THandle;
    TokenPriv: TOKEN_PRIVILEGES;
    PrevTokenPriv: TOKEN_PRIVILEGES;
    ReturnLength: Cardinal;
  begin
    Result := True;
    // Only for Windows NT/2000/XP and later.
    if not (Win32Platform = VER_PLATFORM_WIN32_NT) then Exit;
    Result := False;

    // obtain the processes token
    if OpenProcessToken(GetCurrentProcess(),
      TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
    begin
      try
        // Get the locally unique identifier (LUID) .
        if LookupPrivilegeValue(nil, PChar(sPrivilege),
          TokenPriv.Privileges[0].Luid) then
        begin
          TokenPriv.PrivilegeCount := 1; // one privilege to set

          case bEnabled of
            True: TokenPriv.Privileges[0].Attributes  := SE_PRIVILEGE_ENABLED;
            False: TokenPriv.Privileges[0].Attributes := 0;
          end;

          ReturnLength := 0; // replaces a var parameter
          PrevTokenPriv := TokenPriv;

          // enable or disable the privilege

          AdjustTokenPrivileges(hToken, False, TokenPriv, SizeOf(PrevTokenPriv),
            PrevTokenPriv, ReturnLength);
        end;
      finally
        CloseHandle(hToken);
      end;
    end;
    // test the return value of AdjustTokenPrivileges.
    Result := GetLastError = ERROR_SUCCESS;
    if not Result then
      raise Exception.Create(SysErrorMessage(GetLastError));
  end;

procedure MakeMinidump(aPID:DWORD; const aOutputFile: string);
var
  hProc,
  hFile,snapshotHandle: THandle;
  sFile: string;
begin
  NTSetPrivilege(SE_DEBUG_NAME,true);
   snapshotHandle := 0;

  sFile  := aOutputFile;
  hProc  := OpenProcess(PROCESS_ALL_Access, false, aPID);
  hFile  := CreateFile(PChar(sFile),
                      GENERIC_ALL,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
  try
    if not MiniDumpWriteDump(hproc,
        aPID,
        hFile,
       MiniDumpWithFullMemory,
        nil, nil ,nil)
    then
      RaiseLastOSError;
  finally
    FileClose(hfile);
  end;
end;
end.


