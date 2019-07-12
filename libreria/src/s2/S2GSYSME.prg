#include "dll.ch"
#include "dfXBase.ch"
// Declare Function GetSystemMetrics Lib "user32" (ByVal nIndex As Long)
// As Long

DLLFUNCTION S2GetSystemMetrics( n ) USING STDCALL FROM USER32.DLL ;
       NAME GetSystemMetrics

