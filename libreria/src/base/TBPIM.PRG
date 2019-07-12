//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per BROWSE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfWin.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbPim( oTbr ) // Put in the middle
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nBack, nRec:=oTbr:W_CURRENTREC, nSkipped
#ifndef __HARBOUR__
nBack       := ROUND(oTbr:ROWCOUNT/2,0) -oTbr:ROWPOS // numero di skip da fare

///////////////////////////////////////////////////////////////////////
//Luca Modifica per ripristino funzionamento in xbase 1.9 della tbPim() 
//Mantis 2195 del 30/05/2012 -> 23/06/2016 ripristinata funzione originaria tbpim() perchè era corretta prima 
/////////////////////////////////////////////////////////////////////
IF nBack<=0
   oTbr:ROWPOS := ROUND(oTbr:ROWCOUNT/2,0)       // Riga
ELSE
   //nBack += (oTbr:ROWPOS-1)
   nSkipped    := EVAL(oTbr:SKIPBLOCK, -nBack)
   oTbr:ROWPOS := ROUND(oTbr:ROWCOUNT/2,0)
   nSkipped    := nBack +nSkipped
   // VOLUTO PER ALASKA NON MODIFICARE
   oTbr:ROWPOS := oTbr:ROWPOS -nSkipped
ENDIF 

IF !EMPTY(oTbr:W_ALIAS) // Pim su file
   (oTbr:W_ALIAS)->(DBGOTO(nRec))
ENDIF
oTbr:W_CURRENTREC:=nRec
tbConfigure(oTbr)
#endif
tbStab( oTbr, .T. )    // Stabilize Forzato

RETURN
