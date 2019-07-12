//*****************************************************************************
// Copyright (C) 1994 ISA - Italian Software Agency
// Descrizione : Inizializza array delle sequenze di escape per le stampe
//*****************************************************************************
#include "dfSet.ch"
#include "dfMsg.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIntPrn()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aArr := {}
AADD( aArr, {;
             "0",;
             dfStdMsg( MSG_INTPRN01 ) ,;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             []})
AADD( aArr, {;
             "107",;
             "EPSON FX-80" ,;
             +CHR(27)+CHR(64),;
             [],;
             +CHR(27)+CHR(71),;
             +CHR(27)+CHR(72),;
             +CHR(27)+CHR(87)+CHR(1),;
             +CHR(27)+CHR(87)+CHR(0),;
             +CHR(27)+CHR(45)+CHR(1),;
             +CHR(27)+CHR(45)+CHR(0),;
             +CHR(27)+CHR(83)+CHR(1),;
             +CHR(27)+CHR(84),;
             +CHR(27)+CHR(83)+CHR(0),;
             +CHR(27)+CHR(84),;
             +CHR(15),;
             +CHR(27)+CHR(80)+CHR(18),;
             +CHR(27)+CHR(52),;
             +CHR(27)+CHR(53),;
             +CHR(27)+CHR(120)+CHR(1),;
             +CHR(27)+CHR(120)+CHR(0),;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             []})
AADD( aArr, {;
             "158",;
             "HP LASERJET PLUS" ,;
             +CHR(12),;
             [],;
             +CHR(27)+CHR(40)+CHR(115)+CHR(52)+CHR(66),;
             +CHR(27)+CHR(40)+CHR(115)+CHR(48)+CHR(66),;
             +CHR(27)+CHR(40)+CHR(115)+CHR(53)+CHR(72),;
             +CHR(27)+CHR(40)+CHR(115)+CHR(49)+CHR(48)+CHR(72),;
             +CHR(27)+CHR(38)+CHR(100)+CHR(68),;
             +CHR(27)+CHR(38)+CHR(100)+CHR(64),;
             +CHR(27)+CHR(40)+CHR(115)+CHR(45)+CHR(49)+CHR(85)+CHR(27)+CHR(40)+CHR(115)+CHR(54)+CHR(86),;
             +CHR(27)+CHR(40)+CHR(115)+CHR(48)+CHR(85)+CHR(27)+CHR(40)+CHR(115)+CHR(49)+CHR(50)+CHR(86),;
             +CHR(27)+CHR(40)+CHR(115)+CHR(43)+CHR(49)+CHR(85)+CHR(27)+CHR(40)+CHR(115)+CHR(54)+CHR(86),;
             +CHR(27)+CHR(40)+CHR(115)+CHR(48)+CHR(85)+CHR(27)+CHR(40)+CHR(115)+CHR(49)+CHR(50)+CHR(86),;
             +CHR(27)+CHR(38)+CHR(107)+CHR(50)+CHR(83),;
             +CHR(27)+CHR(38)+CHR(107)+CHR(48)+CHR(83),;
             +CHR(27)+CHR(40)+CHR(115)+CHR(49)+CHR(83),;
             +CHR(27)+CHR(40)+CHR(115)+CHR(48)+CHR(83),;
             +CHR(27)+CHR(40)+CHR(115)+CHR(50)+CHR(81),;
             +CHR(27)+CHR(40)+CHR(115)+CHR(49)+CHR(81),;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             []})

AADD( aArr, {;
             "999",;
             "HTML Driver" ,;
             "<HTML> <HEAD><TITLE>Visual dBsee Report</TITLE></HEAD> <BODY> <PRE>",;
             "</PRE> </BODY> </HTML>",;
             "<B>",;
             "</B>",;
             "<FONT SIZE=5>",;
             "</FONT>",;
             "<U>",;
             "</U>",;
             "<SUP>",;
             "</SUP>",;
             "<SUB>",;
             "</SUB>",;
             "<FONT SIZE=1>",;
             "</FONT>",;
             "<I>",;
             "</I>",;
             "<STRONG>",;
             "</STRONG>",;
             [],;
             [],;
             [],;
             [],;
             [],;
             [],;
             []})
RETURN aArr
