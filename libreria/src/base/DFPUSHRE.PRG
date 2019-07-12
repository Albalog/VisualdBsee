//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' Varie
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "common.ch"

STATIC aRec := {}
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPushRec( c2Del ) // Salva il record
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nCount, aTail, cFieldname

c2Del := UPPER("-" +dfChkGrp( c2Del ) +"-")

AADD( aRec, {} )

aTail := ATAIL(aRec)
FOR nCount := 1 TO FCOUNT()
   cFieldname := UPPER(FIELDNAME( nCount ))
   IF ! ("-" +cFieldname +"-"$c2Del)
      AADD( aTail, { nCount, FIELDGET(nCount) } )
   ENDIF
NEXT
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPopRec() // Ripristina il record
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nCount, aTail

IF LEN(aRec)>0
   IF !EMPTY(ALIAS())
      aTail := ATAIL(aRec)
      FOR nCount := 1 TO LEN(aTail)
         IF !( aTail[nCount][2]==FIELDGET( aTail[nCount][1] ) )
            FIELDPUT( aTail[nCount][1], aTail[nCount][2] )
         ENDIF
      NEXT
   ENDIF
   ASIZE(aRec,LEN(aRec)-1)
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPushRecNum(); RETURN LEN(aRec)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
