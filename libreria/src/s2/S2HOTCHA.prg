#include "dfXBase.ch"

FUNCTION S2HotCharCvt(cString)
RETURN STRTRAN(cString, dfHot(), STD_HOTKEYCHAR)

