/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

// Elenco modifiche:
// 18/02/2003 SD per GERR 3392
//            aggiunto parametro per specificare il nome del file
// 09/05/2002 SD per GERR 3042
//            modifica per utilizzare correttamente chiave/filtro/break

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

#include "Common.ch"
#include "fileio.ch"
#include "dbStruct.ch"
#include "dfReport.ch"
#include "dfMsg.ch"
#include "dfWin.ch"
#include "dfCtrl.ch"
#include "dfStd.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPrnLab( bKey, bFilter, bBreak, lSkipDesign, cLabel )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aBuffer, aCtrl := {}
LOCAL lPrint, aVirRec, VRLoc, cTit, cAlias := ALIAS(), nRow
LOCAL cMemo, nEti := 2, nInt := 5
LOCAL nMemoWidth := 120, nWidth := 39, aPfkItm  := {}
LOCAL cNewMemo, cPro, nAct

MEMVAR EnvID, SubID

DEFAULT cLabel TO cAlias+".LAB"
cMemo := MEMOREAD(cLabel)

PRIVATE EnvID := cLabel
PRIVATE SubID := ""


DEFAULT bFilter     TO {||.T.}
DEFAULT bBreak      TO {||.F.}
DEFAULT lSkipDesign TO .F.

nRow := MLCOUNT( cMemo, nMemoWidth )
IF nRow>0
   cPro := RTRIM(MEMOLINE( cMemo, nMemoWidth, 1 ))
   IF ","$cPro
      nEti   := VAL( dfToken( cPro, ",", 1 ) )
      nInt   := VAL( dfToken( cPro, ",", 2 ) )
      nWidth := VAL( dfToken( cPro, ",", 3 ) )
   ENDIF
   cNewMemo := ""
   FOR nAct := 2 TO nRow
      cNewMemo += RTRIM(MEMOLINE( cMemo, nMemoWidth, nAct ))
      IF nAct<nRow
         cNewMemo += CRLF
      ENDIF
   NEXT
   cMemo := cNewMemo
ENDIF

IF !FILE( cLabel )
   cMemo := (cAlias)->(dfPrnLabDef())
ENDIF

(cAlias)->(dfPushArea())
dfPushAct()

cTit := cLabel

ADDKEY "A_f" TO aPfkItm         ; // Tasto su Get
       BLOCK   {||(cAlias)->(dfPrnLabField())}         ; // Funzione sul tasto
       WHEN    {||.T. }         ; // Condizione di stato di attivazione
       RUNTIME {||dfIsInMemo()} ; // Condizione di runtime
       MESSAGE dfStdMsg(MSG_DDQRY12) +" " +cAlias  // Messaggio utente associato

ATTACH "label" TO aCtrl GET AS TEXTFIELD cMemo  AT 0, 0, 12, 61 BOX 1 MESSAGE dfStdMsg( MSG_DFPRNLAB04 ) PFK aPfkItm MEMOWIDTH nMemoWidth

IF dfSet( AI_NEWLABEL )
   //ATTACH "get"   TO aCtrl GET nEti   AT 14,  1 PICTURESAY "999"    PROMPT dfStdMsg( MSG_DFPRNLAB01 ) PROMPTAT 14, 8
   //ATTACH "get"   TO aCtrl GET nInt   AT 15,  1 PICTURESAY "999.99" PROMPT dfStdMsg( MSG_DFPRNLAB02 ) PROMPTAT 15, 8
   //ATTACH "get"   TO aCtrl GET nWidth AT 16,  1 PICTURESAY "999"    PROMPT dfStdMsg( MSG_DFPRNLAB03 ) PROMPTAT 16, 8
   //LUCAP - XLS 1958 - SPOSTATA UN PO A SX LE COORDINATE
   ATTACH "get"   TO aCtrl GET nEti   AT 14,  1 PICTURESAY "999"    PROMPT dfStdMsg( MSG_DFPRNLAB01 ) PROMPTAT 14, 13
   ATTACH "get"   TO aCtrl GET nInt   AT 15,  1 PICTURESAY "999.99" PROMPT dfStdMsg( MSG_DFPRNLAB02 ) PROMPTAT 15, 13
   ATTACH "get"   TO aCtrl GET nWidth AT 16,  1 PICTURESAY "999"    PROMPT dfStdMsg( MSG_DFPRNLAB03 ) PROMPTAT 16, 13

ELSE
   //ATTACH "get"   TO aCtrl GET nEti   AT 14,  1 PICTURESAY "999" PROMPT dfStdMsg( MSG_DFPRNLAB01 ) PROMPTAT 14, 4
   //ATTACH "get"   TO aCtrl GET nInt   AT 15,  1 PICTURESAY "999" PROMPT dfStdMsg( MSG_DFPRNLAB02 ) PROMPTAT 15, 4
   //ATTACH "get"   TO aCtrl GET nWidth AT 16,  1 PICTURESAY "999" PROMPT dfStdMsg( MSG_DFPRNLAB03 ) PROMPTAT 16, 4
   ATTACH "get"   TO aCtrl GET nEti   AT 14,  1 PICTURESAY "999"    PROMPT dfStdMsg( MSG_DFPRNLAB01 ) PROMPTAT 14, 8
   ATTACH "get"   TO aCtrl GET nInt   AT 15,  1 PICTURESAY "999" PROMPT dfStdMsg( MSG_DFPRNLAB02 ) PROMPTAT 15, 8
   ATTACH "get"   TO aCtrl GET nWidth AT 16,  1 PICTURESAY "999"    PROMPT dfStdMsg( MSG_DFPRNLAB03 ) PROMPTAT 16, 8
ENDIF

WHILE lSkipDesign .OR. dfAutoForm(,,aCtrl,cTit)
   MEMOWRIT( cLabel, ALLTRIM(STR(nEti))   +","  +;
                     ALLTRIM(STR(nInt))   +","  +;
                     ALLTRIM(STR(nWidth)) +CRLF +cMemo )
   nRow := MLCOUNT( cMemo, nMemoWidth )

   VRLoc := dfVRCreate()
   VRLoc[VR_NAME  ]     := cAlias                 // Nome del file

   VRLoc[VR_KEY   ]     := bKey
   VRLoc[VR_FILTER]     := bFilter
   VRLoc[VR_BREAK ]     := bBreak

   VRLoc[VR_EOF_MODE]   := VR_IGNORE
   VRLoc[VR_EJECT ]     := .F.

   IF !dfSet( AI_NEWLABEL )
      VRLoc[VR_BODY  ]     := {||(cAlias)->(dfLabelBody( VRLoc, aBuffer, cMemo, nRow, nMemoWidth, nEti, nInt, nWidth ))}
      VRLoc[VR_ROWBODY  ]  := nRow +nInt
      VRLoc[VR_BRKBODY  ]  := .F.
      VRLoc[VR_EJECTBODY]  := .F.
   ENDIF

   aVirRec := {}
   dfVrAddFle( aVirRec, {}, VRLoc )

   aBuffer := dfPrnCfg()           // Inizializzazione

   aBuffer[ REP_NAME ]  := cTit    //  Intestazione report
   aBuffer[ REP_VREC ]  := aVirRec

   // Configurazione con parametri di layout
   // Attenzione se il giochino del loop non dovesse funzionare
   // Clonare aBuffer e assegnarlo prina del dfPrnMenu
   IF dfPrnMenu( aBuffer )
      lPrint := M->Act=="wri"
      IF dfSet( AI_NEWLABEL )
         // Non uso il motore dBsee
         (cAlias)->(dfPrintLab( VRLoc, aBuffer, cMemo, nRow, nMemoWidth, nEti, nInt, nWidth ))
         //dfPrnStart( aVirRec )
      ELSE
         dfPrnStart( aVirRec )
      ENDIF
      IF lPrint
         EXIT
      ENDIF
   ELSE
      IF lSkipDesign
         EXIT
      ENDIF
   ENDIF
ENDDO

dfPopAct()
(cAlias)->(dfPopArea())

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfLabelBody( VRLoc, aBuffer, cMemo, nRow, nMemoWidth, nEti, nInt, nWidth )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aLabel, nAct, nPrn, nStart := 0

aLabel := {}
ASIZE( aLabel, nRow )
FOR nPrn := 1 TO nEti
   IF !EOF()
      FOR nAct := 1 TO nRow
         aLabel[nAct] := PADR(aLabel[nAct],nStart-1) +;
               RTRIM(PADR( dbMMrg(MEMOLINE(cMemo,nMemoWidth,nAct)), nWidth ))
      NEXT
      IF nPrn!=nEti
         nStart += nWidth

         // SD 09/05/2002 per GERR 3042
         // sostituito SKIP con dfReportSkip
         // altrimenti se le etichette successive non rientravano
         // nel filtro venivano stampate ugualmente
         // SKIP
         IF dfReportSKIP( VRLoc )==0
            EXIT
         ENDIF
         IF aBuffer[REP_QRY_BLOCK]!=NIL
            WHILE !EVAL(aBuffer[REP_QRY_BLOCK]) .AND. !EOF()
               IF dfReportSKIP( VRLoc )==0
                  DBGOTO( 0 )
                  EXIT
               ENDIF
            ENDDO
         ENDIF
      ENDIF
   ENDIF
NEXT
FOR nPrn := 1 TO nRow
   dfPrint( nPrn-1, 0, aLabel[nPrn] )
NEXT
IF nInt>0
   dfPrint( nInt+nRow-1, 0, "" )
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfPrnLabField()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aStruct := ddFileStruct(), aFieldDes := {}, nFie, cAlias := ALIAS(), cKey
LOCAL aFunc := { "UPPER(%)"         ,;
                 "LOWER(%)"         ,;
                 "ALLTRIM(%)"       ,;
                 "UPPER(ALLTRIM(%))",;
                 "LOWER(ALLTRIM(%))" }

#ifdef __XPP__
LOCAL oObj
#endif

AEVAL( aStruct, {|aSub|AADD( aFieldDes, aSub[DBS_ALEN+2])} )

nFie := dfArrWin( ,,,, aFieldDes, dfStdMsg(MSG_DDQRY12) +" " +cAlias )

IF nFie>0
   cKey := cAlias +"->" +aStruct[nFie][DBS_NAME]
   IF aStruct[nFie][DBS_TYPE]$"CM"
      nFie := dfArrWin( ,,,, aFunc, dfStdMsg( MSG_DFPRNLAB05 ) )
      IF nFie>0
         cKey := STRTRAN( aFunc[nFie], "%", cKey )
      ENDIF
   ENDIF
   #ifdef __XPP__
      oObj := SetAppFocus()
      IF oObj:classname() == "_XbpMle"
         oObj:insert(NIL, "<<" +cKey +">>" )
      ENDIF
   #else
      KEYBOARD "<<" +cKey +">>"
   #endif
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfPrnLabDef()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cMemo := ""
LOCAL aStruct := ddFileStruct(), aFieldDes := {}, nFie, cAlias := ALIAS(), cKey

FOR nFie := 1 TO MIN( LEN(aStruct), 5 )
   cKey := ALIAS() +"->" +aStruct[nFie][DBS_NAME]
   IF nFie>1
      cMemo += CRLF
   ENDIF
   cMemo += "<<" +cKey +">>"
NEXT

RETURN cMemo

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfPrintLab( VRLoc, aBuf, cMemo, nRow, nMemoWidth, nEti, nInt, nWidth )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aLabel, nAct, nPrn, nStart, nPos, nDif

// Filtri
dfPrnConfig( aBuf )

// File
aBuf[REP_FHANDLE] := FOPEN( aBuf[REP_FNAME], FO_READWRITE )

nDif := 0
aBuf[REP_ACT_ROW]:=0
// SD 09/05/2002 per GERR 3042
// sostituito DBGOTOP con dfReportTop
// altrimenti stampava sempre tutto il file senza 
// considerare il filtro 
// DBGOTOP()
dfReportTop( VRLoc )
IF aBuf[REP_QRY_BLOCK]!=NIL
   WHILE !EVAL(aBuf[REP_QRY_BLOCK]) .AND. !EOF()
      IF dfReportSKIP( VRLoc )==0
         DBGOTO( 0 )
         EXIT
      ENDIF
   ENDDO
ENDIF

// Margine

WHILE !EOF()
   IF aBuf[REP_ACT_ROW]==0
      nPos = aBuf[REP_MGN_TOP]
      WHILE nPos>0
         nPos--
         FWRITE( aBuf[REP_FHANDLE], CRLF )
         aBuf[REP_ACT_ROW]++
      ENDDO
   ENDIF

   nStart := 0
   aLabel := {}
   ASIZE( aLabel, nRow )
   FOR nPrn := 1 TO nEti
      IF !EOF()
         FOR nAct := 1 TO nRow
            aLabel[nAct] := PADR(aLabel[nAct],nStart-1) +;
                  RTRIM(PADR( dbMMrg(MEMOLINE(cMemo,nMemoWidth,nAct)), nWidth ))
         NEXT
            nStart += nWidth
            // SD 09/05/2002 per GERR 3042
            // sostituito SKIP con dfReportSkip
            // altrimenti se le etichette successive non rientravano
            // nel filtro venivano stampate ugualmente
            // SKIP
            IF dfReportSKIP( VRLoc )==0
               DBGOTO( 0 )
               EXIT
            ENDIF
            IF aBuf[REP_QRY_BLOCK]!=NIL
               WHILE !EVAL(aBuf[REP_QRY_BLOCK]) .AND. !EOF()
                  IF dfReportSKIP( VRLoc )==0
                     DBGOTO( 0 )
                     EXIT
                  ENDIF
               ENDDO
            ENDIF
      ENDIF
   NEXT

   FOR nPrn := 1 TO nRow
      FWRITE( aBuf[REP_FHANDLE], aLabel[nPrn] +CRLF )
      aBuf[REP_ACT_ROW]++
   NEXT

   IF aBuf[REP_PAGELENGHT]>=aBuf[REP_ACT_ROW]+INT(nDif)+INT(nInt-nRow)+nRow
      WHILE nDif>=1
         nDif--
         FWRITE( aBuf[REP_FHANDLE], CRLF )
         aBuf[REP_ACT_ROW]++
      ENDDO

      nPos = nRow
      WHILE nPos<INT(nInt)
         nPos++
         FWRITE( aBuf[REP_FHANDLE], CRLF )
         aBuf[REP_ACT_ROW]++
      ENDDO

      nDif += nInt-nPos
   ELSE
      // SALTO PAGINA
      nDif := 0
      FWRITE( aBuf[REP_FHANDLE], NEWPAGE )
      aBuf[REP_ACT_ROW]:=0
   ENDIF

ENDDO

FCLOSE( aBuf[REP_FHANDLE] )                       // Close Handle



dfPrnOut( aBuf )

RETURN

