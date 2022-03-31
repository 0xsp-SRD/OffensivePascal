program springcore_sanner;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils,FPHTTPClient, openssl,
  opensslsockets, CustApp
  { you can add units after this };

type

  { Tspringscanner }

  Tspringscanner = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure scan; virtual;
    procedure multi_scan; virtual;
  end;

{ Tspringscanner }



function scan_vuln(url:string;app:string):string;
var
  FPHTTPClient: TFPHTTPClient;
  Resultget,magic_code,res: string;
  ok : integer;
begin

magic_code := '/?class.module.classLoader.URLs%5B0%5D=0';
FPHTTPClient := TFPHTTPClient.Create(nil);
FPHTTPClient.AllowRedirect := True;

  try
   FPHTTPClient.Get(url+magic_code); // test URL, real one is HTTPS

  except
      on E: exception do

      res := (E.Message)

   end;

       ok := pos('400',res);

       if ok > 0 then
        result := 'vulnerable'
        else
       result := 'not vulnerable';



FPHTTPClient.Free;

end;

procedure Tspringscanner.DoRun;
var
  ErrorMsg: String;
  msg : string;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h u p s m a', 'help');
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
  if hasoption('s') then   begin
   scan;
  end;
   if hasoption('m') then   begin
   multi_scan;
   end;

  { add your program here }



  // stop program loop
  Terminate;
end;

constructor Tspringscanner.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor Tspringscanner.Destroy;
begin
  inherited Destroy;
end;


procedure banner;
 var
   s : string;
begin
   s:= '[!] coded by @zux0x3a '#10+'[+] 0xsp SRD '+#10+'[!] thanks to : RandoriAttack'+#10;

   writeln(s);
end;

procedure Tspringscanner.multi_scan;
var
msg,url,port,app:string;
list: Tstringlist;
i: integer;
begin
  banner;
 url := getoptionvalue('u');
 port := getoptionvalue('p');
 app := getoptionvalue('a');

 try
 list := Tstringlist.Create;
 list.LoadFromFile(url);
   for i := 0 to list.Count -1 do begin ;
  if length(port) > 0 then begin

  msg := scan_vuln(list.Strings[i]+':'+port,app)

   end else

   msg := scan_vuln(list.Strings[i],app);

   writeln('[!] the following URL '+list.Strings[i] + ' is ' + msg);

   end;

   finally
     list.free;
   end;


end;

procedure Tspringscanner.scan;
var
  msg,url,port,app:string;

begin

 banner;
  url := getoptionvalue('u');
  port := getoptionvalue('p');
  app := getoptionvalue('a');

   if length(port) > 0 then begin
  msg := scan_vuln(url+':'+port,app)

   end else

   msg := scan_vuln(url,app);

  writeln('[+] the following URL '+url+' is '+msg);
 end;
procedure Tspringscanner.WriteHelp;
begin
  { add your help code here }
  writeln('Single scan: ', ExeName, ' -s -u http://host -p 8080 -a /');
  writeln('Multi scan : ', ExeName, ' -m -u target -p 8080 -a /application/index ');
  writeln('--------------------------');
  writeln('-s','-- single scan mode');
  writeln('-m','-- multi scan mode');
  writeln('-u','-- supply single HTTP/HTTPS or load a list from file');
  writeln('-p','-- specify a port ');
  writeln('-a','-- supply the path of application default e.g / ');


end;

var
  Application: Tspringscanner;
begin
  Application:=Tspringscanner.Create(nil);
  Application.Title:='scanner';
  Application.Run;
  Application.Free;
end.

