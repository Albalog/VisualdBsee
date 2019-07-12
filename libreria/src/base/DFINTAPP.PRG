// Ini Compiler        (C) 1993  Italian Software Agency         Version 0.4
#include "dfSet.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIntApp()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aArr := {}
aArr := dfDefApp()
aArr[AI_INIVERSION]       := ALLTRIM(dfNumVer())
aArr[AI_INDEXPACK]        := .F.
aArr[AI_LOCKREPEATTIME]   := 60
aArr[AI_GETTIMEOUT]       := 60
aArr[AI_GETWARNING]       := 20
aArr[AI_MOUSE]            := .T.
aArr[AI_TABNAME]          := [DBTABD]
aArr[AI_TABINDEX1]        := [DBTABD1]
aArr[AI_TABMODIFY]        := .T.
aArr[AI_FILEMODIFY]       := .T.
aArr[AI_CONSOLELINES]     := 0
aArr[AI_SHADOWCOLOR]      := [B/N]
aArr[AI_DEFAULTPRINTER]   := [107]
aArr[AI_DEFAULTPORT]      := [LPT1]
aArr[AI_OBJECTOFFCOLOR]   := [G/B]
aArr[AI_CLEARSCREEN]      := .T.
aArr[AI_SCREENCOLOR]      := [R/W*]
aArr[AI_SCRSAVERACTIVE]   := .F.
aArr[AI_SCRSAVERTIME]     := 120
aArr[AI_FONTREDEFINITION] := .T.
aArr[AI_INIMESSAGE]       := .T.
RETURN aArr
