//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Stampe
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfVRAddFle( aVRec, aEntry, aFile ) // Aggiunge Entry a VR
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos         // Posizione del file nel record virtuale

DEFAULT aEntry TO {}

IF !EMPTY( aEntry )    // se NON sono all'ultimo livello
   nPos := aScan( aVRec, {|aRow| aRow[VR_NAME] == UPPER(PADR(aEntry[1],8)) } )
   IF nPos # 0
      ADEL( aEntry, 1 ); ASIZE( aEntry, Len(aEntry)-1 )
      dfVRAddFle( aVRec[nPos][VR_CHILD], aEntry, aFile )
   END
ELSE
   aFile[VR_NAME]  := UPPER( PADR( aFile[VR_NAME], 8 ) )
   AADD( aVRec, aFile )
   dfDefBlock( aVRec ) // Imposto le bande da ripetere sui body
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfDefBlock( aVR )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActual, aFile
//
// Problema da risolvere con una release successiva
// Se disabilito la banda che credevo di dover intestare
// perdo la capacita' di intestare o footerare
//
FOR nActual := 1 TO LEN(aVR)
   aFile := aVR[nActual]
   IF !aFile[VR_STABLE]
      aFile[VR_STABLE] := .T.
      //-----------------------------------------------------------------------
      // Header
      //-----------------------------------------------------------------------
      dfGetHead( aFile )
      IF !aFile[VR_BODY2HEAD] .AND. aFile[VR_BODYPOSHEAD]!=0
         aFile[VR_BODYHEAD] :={||NIL} // Non stampa l'header, ma ne ho uno fisso
         aFile[VR_BODY2HEAD]:=.T.
      ENDIF
      IF aFile[VR_BODYHEAD]==NIL; aFile[VR_BODY2HEAD] := .F.; ENDIF

      //-----------------------------------------------------------------------
      // Footer
      //-----------------------------------------------------------------------
      dfGetFoot( aFile )
      IF !aFile[VR_BODY2FOOT] .AND. aFile[VR_BODYPOSFOOT]!=0
         aFile[VR_BODYFOOT] :=NIL // Non stampa il footer, ma ne ho uno fisso
         aFile[VR_BODY2FOOT]:=.T. // Il NIL serve solo per controllare il footer
      ELSEIF aFile[VR_BODYFOOT]==NIL
          aFile[VR_BODY2FOOT] := .F.
      ENDIF
   ENDIF
   dfDefBlock( aFile[VR_CHILD] )
NEXT
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfGetHead( aFile )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLen := LEN(aFile[VR_GRP_ARR])
IF aFile[VR_BODYHEAD]==NIL
   WHILE nLen>0
      IF aFile[VR_GRP_ARR][nLen][VR_GRP_HEADER] != NIL
         aFile[VR_BODYHEAD]    := aFile[VR_GRP_ARR][nLen][VR_GRP_HEADER]
         aFile[VR_BODYPOSHEAD] := aFile[VR_GRP_ARR][nLen][VR_GRP_POSHEADER]
         aFile[VR_BODYROWHEAD] := aFile[VR_GRP_ARR][nLen][VR_GRP_ROWHEADER]
         aFile[VR_BODYCANHEAD] := aFile[VR_GRP_ARR][nLen][VR_GRP_CANHEADER]
         nLen:=0
      ENDIF
      nLen--
   ENDDO
   IF nLen==0 // Non ho trovato un gruppo da utilizzare
      aFile[VR_BODYHEAD]    := aFile[VR_HEADER]
      aFile[VR_BODYPOSHEAD] := aFile[VR_POSHEADER]
      aFile[VR_BODYROWHEAD] := aFile[VR_ROWHEADER]
      aFile[VR_BODYCANHEAD] := aFile[VR_CANHEADER]
   ENDIF
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfGetFoot( aFile )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLen := LEN(aFile[VR_GRP_ARR])
IF aFile[VR_BODYFOOT]==NIL
   WHILE nLen>0
      IF aFile[VR_GRP_ARR][nLen][VR_GRP_FOOTER] != NIL
         aFile[VR_BODYFOOT]    := aFile[VR_GRP_ARR][nLen][VR_GRP_FOOTER]
         aFile[VR_BODYPOSFOOT] := aFile[VR_GRP_ARR][nLen][VR_GRP_POSFOOTER]
         aFile[VR_BODYROWFOOT] := aFile[VR_GRP_ARR][nLen][VR_GRP_ROWFOOTER]
         aFile[VR_BODYCANFOOT] := aFile[VR_GRP_ARR][nLen][VR_GRP_CANFOOTER]
         nLen:=0
      ENDIF
      nLen--
   ENDDO
   IF nLen==0 // Non ho trovato un gruppo da utilizzare
      aFile[VR_BODYFOOT]    := aFile[VR_FOOTER]
      aFile[VR_BODYPOSFOOT] := aFile[VR_POSFOOTER]
      aFile[VR_BODYROWFOOT] := aFile[VR_ROWFOOTER]
      aFile[VR_BODYCANFOOT] := aFile[VR_CANFOOTER]
   ENDIF
ENDIF
RETURN
