//*****************************************************************************
// Copyright (C) 1994 ISA - Italian Software Agency
// Descrizione : Ini Compiler, inizializza l'array della palette dei colori
//*****************************************************************************
#include "dfSet.ch"
#include "dfMsg.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIntCol()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aArr := {}
AADD( aArr, {[PALETTE00], { 0, 0, 0, dfStdMsg(MSG_INTCOL01) }})
AADD( aArr, {[PALETTE01], {18,18,18, dfStdMsg(MSG_INTCOL02) }})
AADD( aArr, {[PALETTE02], {38,38,42, dfStdMsg(MSG_INTCOL03) }})
AADD( aArr, {[PALETTE03], { 0, 0,20, dfStdMsg(MSG_INTCOL04) }})
AADD( aArr, {[PALETTE04], { 0,23,45, dfStdMsg(MSG_INTCOL05) }})
AADD( aArr, {[PALETTE05], { 0,46,63, dfStdMsg(MSG_INTCOL06) }})
AADD( aArr, {[PALETTE06], { 0,16, 0, dfStdMsg(MSG_INTCOL07) }})
AADD( aArr, {[PALETTE07], { 7,63, 6, dfStdMsg(MSG_INTCOL08) }})
AADD( aArr, {[PALETTE08], { 0,63,48, dfStdMsg(MSG_INTCOL09) }})
AADD( aArr, {[PALETTE09], {36, 0,30, dfStdMsg(MSG_INTCOL10) }})
AADD( aArr, {[PALETTE10], {63, 0, 0, dfStdMsg(MSG_INTCOL11) }})
AADD( aArr, {[PALETTE11], {63,43,63, dfStdMsg(MSG_INTCOL12) }})
AADD( aArr, {[PALETTE12], {63,35, 0, dfStdMsg(MSG_INTCOL13) }})
AADD( aArr, {[PALETTE13], {63,63, 0, dfStdMsg(MSG_INTCOL14) }})
AADD( aArr, {[PALETTE14], {63,60,40, dfStdMsg(MSG_INTCOL15) }})
AADD( aArr, {[PALETTE15], {63,63,63, dfStdMsg(MSG_INTCOL16) }})
AADD( aArr, {[BROWSE], {[N/GR*],[N/GR*],[W+/G],[BG/GR*],[W+/R],[BG/GR*],[W+/R],[W+/N],[W+/G],[N+/BG],[R+/BG],[B/W],[W+/BG],[R/BG],[W+/B],[W+/N]}})
AADD( aArr, {[BROWSEBOX], {[W+/R],[B/R],[G/B],[W+/R],[W+/G*],[W+/B],[W+/R],[W+/BG],[W+/R],[N+/BG],[R+/BG],[B/W],[W+/BG],[R/BG],[W+/B],[W+/N]}})
AADD( aArr, {[ARRAYBOX], {[W+/R],[B/R],[G/B],[W+/R],[W+/G*],[W+/B],[W+/R],[W+/R],[W+/BG],[N+/BG],[R+/BG],[B/W],[W+/BG],[R/BG],[W+/B],[W+/N]}})
AADD( aArr, {[ARRAYWINDOW], {[GR+/B],[GR+/B],[RB+/R+],[G/B],[GR/RB],[GR+/B],[W+/B],[W+/B],[W+/G],[N+/BG],[R+/BG],[B/W],[W+/BG],[R/BG],[W+/B],[W+/N]}})
AADD( aArr, {[WINDOW], {[GR/R],[GR/R],[RB+/B*],[BG/RB],[W+/R],[W+/RB],[W+/R],[W+/N],[W+/G],[N+/BG],[R+/BG],[B/W],[W+/BG],[R/BG],[W+/B],[W+/N]}})
AADD( aArr, {[FORM], {[B+/G],[B+/G],[RB+/B*],[W+/BG],[W+/G*],[BG/G],[W+/G],[B/G],[W+/R],[GR+/G],[G+/G],[W+/B],[W+/G],[W+/G],[BG+/R],[W+/G*]}})
AADD( aArr, {[MENUDEFAULT], {[BG/W*],[BG/W*],[G+/W*],[W+/N],[G+/N],[G/W*],[BG/W*]}})
AADD( aArr, {[BUTTONDEFAULT], {[BG/G],[G+/G],[W+/G],[B/G],[W+/G*],[W/G]}})
AADD( aArr, {[BUTTONMESSAGE], {[W+/B],[G+/B],[W+/B],[G/B],[W+/G*],[G/B]}})
AADD( aArr, {[WALLPAPERCOLOR], {[W+/B],[R+/B],[GR/B]}})
AADD( aArr, {[MESSAGECOLOR], {[W+/G],[RB+/G],[W+/G*],[RB+/G*],[N+/R],[W+/R],[N+/R],[W+/R]}})
AADD( aArr, {[USERLINECOLOR], {[W+/B],[W+/B],[RB+/B]}})
AADD( aArr, {[FRAMECOLOR], {[W+/RB],[G+/GB],[GR/RB],[GR/RB]}})
AADD( aArr, {[KEYCOLOR], {[N/RB],[W+/RB],[BG/RB],[G+/RB],[W+/RB],[W+/B],[RB/B]}})
AADD( aArr, {[TVIEWDEFAULT], {[W+/B],[W+/B*],[W+/BG],[W+/B],[W+/BG],[W+/R],[W+/G],[W+/B],[W+/W]}})
AADD( aArr, {[HELP], {[B+/G],[N/W*],[N/W*],[W+/R],[W+/BG],[N/W*],[W+/N],[G+/W*],[RB+/B*]}})
AADD( aArr, {[PROGRESSINDICATOR], {[W+/RB],[N/RB],[RB+/B*],[B+/RB],[GR/RB]}})
AADD( aArr, {[CALCULATOR], {[W+/R],[W+/N],[W+/N],[G+/R],[RB/R],[BG+/R],[R+/R],[RB+/R]}})
AADD( aArr, {[WAIT], {[W+/G],[N/G],[R/G]}})
AADD( aArr, {[DFLOGIN], {[W+/R*],[W+/R*],[W+/B*],[GR+/R*],[GR+/R*]}})
AADD( aArr, {[DFCALENDAR], {[W+/RB],[W+/B],[W+/B],[W+/G*],[W+/B]}})
RETURN aArr
