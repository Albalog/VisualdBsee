@echo off
xppload version

:: versione definitiva
strtran _gotutto.base  _gotutto.bat rel=..\output\lib200-832\rel   setreldate=reldate.exe defines="/d_XBASE200_" cur=%cd%\ lib="<<'XppRt0.lib'+chr(13)+chr(10)+'XppRt1.lib'+chr(13)+chr(10)+'XppUi2.lib'+chr(13)+chr(10)+'xppsys.lib'+chr(13)+chr(10)+'xppdui.lib'>>" xpprel=\alaska200-832\xpp20\lib\

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
::del ..\output\lib200-832\rel\obj\*.obj
del ..\output\lib200-832\rel\*.def
del ..\output\lib200-832\rel\*.exp
