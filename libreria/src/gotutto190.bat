@echo off
xppload version

:: versione definitiva
strtran _gotutto.base  _gotutto.bat rel=..\output\lib190\rel   setreldate=reldate.exe defines= cur=%cd%\ lib="<<'XppRt0.lib'+chr(13)+chr(10)+'XppRt1.lib'+chr(13)+chr(10)+'XppRt2.lib'+chr(13)+chr(10)+'XppUi2.lib'+chr(13)+chr(10)+'Xppui3.lib'+chr(13)+chr(10)+'Xppsys.lib'>>" xpprel=v:\alaska190\xppw32\lib\

echo "--- STATIC LIB ---"
call _gotutto.bat /STATIC %1 %2 %3
if errorlevel 1 goto exit
echo "--- STATIC LIB ---"

echo "--- DYNAMIC LIB ---"
call _gotutto.bat /DYNAMIC %1 %2 %3
if errorlevel 1 goto exit
echo "--- DYNAMIC LIB ---"

:exit
del _gotutto.bat > nul
::del ..\output\lib190\rel\obj\*.obj
del ..\output\lib190\rel\*.def
del ..\output\lib190\rel\*.exp
