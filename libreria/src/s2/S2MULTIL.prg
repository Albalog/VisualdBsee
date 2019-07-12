#include "dfStd.ch"

FUNCTION S2MultiLineCvt(cString)
RETURN STRTRAN(cString, "//", CRLF)
