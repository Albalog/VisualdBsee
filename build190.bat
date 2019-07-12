@echo off

echo Imposta variabili d'ambiente
echo per compilazione libreria Visual dBsee

set VDBLIB_MAINDIR=%CD%\libreria
set path=%VDBLIB_MAINDIR%\uti190;%path%
set include=%include%;%VDBLIB_MAINDIR%\INCLUDE
set include=%include%;%VDBLIB_MAINDIR%\SRC\EXTRA_CH
set lib=%lib%;%VDBLIB_MAINDIR%\output\lib190\rel

echo Ambiente impostato correttamente su %VDBLIB_MAINDIR%

cd libreria\src\

call gotutto190.bat
