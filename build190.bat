@echo off

cls

echo Imposta variabili d'ambiente
echo per compilazione libreria Visual dBsee

echo.
echo Ricordarsi di impostare Alaska Xbase prima di lanciare questo .BAT
echo.

pause

set VDBLIB_MAINDIR=%CD%\libreria
set path=%VDBLIB_MAINDIR%\uti190;%path%
set include=%VDBLIB_MAINDIR%\INCLUDE;%include%
set include=%VDBLIB_MAINDIR%\SRC\EXTRA_CH;%include%
set lib=%VDBLIB_MAINDIR%\output\lib190\rel;%lib%

echo Ambiente impostato correttamente su %VDBLIB_MAINDIR%

cd libreria\src\

call gotutto190.bat
