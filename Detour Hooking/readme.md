

## AMSI / ETW bypass 

The idea of this project is to use Detour library to intercept and redirect functions calls within dynamic link libraries (DLL) in order to bypass AMSI (AmsiScanBuffer) and intercept the (EventWrite) function of ETW to disallow ETW logging. The following project has been coded in Pascal(FPC) and huge thanks goes to https://github.com/MahdiSafsafi/DDetours for porting the library into Delphi. 

## How To use 
there are several of tools for injecting DLL into process, so you might need to have that on hand and do the following 

```
- compile the project into DLL (Release / Debug)
- inject the DLL into PowerShell Process
- Successfully bypass AMSI / ETW 
```


## Credits 

AmsiDLLHook - https://github.com/tomcarver16/AmsiHook/blob/master/AmsiHook/AmsiHook.cpp 

Delphi DDetours Library - https://github.com/MahdiSafsafi/DDetours/wiki 


