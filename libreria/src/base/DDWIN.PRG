//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.CH"
#INCLUDE "dfWin.ch"
#INCLUDE "dfMsg.CH"
#INCLUDE "dfset.ch"
#INCLUDE "dfNet.ch"
#INCLUDE "dfCTRL.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

PROCEDURE ddWin( nTbOrd ,; // Indice dal quale prendere i dati
                 bTbKey ,; // Chiave
                 bTbFlt ,; // Filtro
                 bTbBrk ,; // Break
                 cAct   ,; // Azioni di sgancio
                 nIndPos ) // Eventuale indice per finestra. Settato da DDKEY
   LOCAL b
   //b := dfSet({AI_XBASESTDFUNCTIONS,  AI_STDFUNC_DDKEY})
   // 09:15:42 sabato 27 ottobre 2018
   // errato uso della AI_STDFUNC_DDKEY al posto di AI_STDFUNC_DDWIN
   b := dfSet({AI_XBASESTDFUNCTIONS,  AI_STDFUNC_DDWIN})
   IF VALTYPE(b)=="B"
      // simone 19/4/06
      // mantis 0001040: implementare nuova finestra di ricerca dati
      EVAL(b, nTbOrd   ,; //<<000037>> Indice
              bTbKey   ,; //<<000038>> Chiave
              bTbFlt   ,; //<<000039>> Filtro
              bTbBrk   ,; //<<000040>> Break
              cAct     ,;
              nIndPos   )
   ELSE

       _ddWin( nTbOrd ,; // Indice dal quale prendere i dati
               bTbKey ,; // Chiave
               bTbFlt ,; // Filtro
               bTbBrk ,; // Break
               cAct   ,; // Azioni di sgancio
               nIndPos ) // Eventuale indice per finestra. Settato da DDKEY
   ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE _ddWin( nTbOrd ,; // Indice dal quale prendere i dati
                 bTbKey ,; // Chiave
                 bTbFlt ,; // Filtro
                 bTbBrk ,; // Break
                 cAct   ,; // Azioni di sgancio
                 nIndPos ) // Eventuale indice per finestra. Settato da DDKEY
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aCol    := {}                            // Array Oggetti Colonna
LOCAL cAlias  := UPPER(PADR(ALIAS(),8))
LOCAL nInd    := 1000
LOCAL nAdd, cInt
LOCAL aAddCol := {}
LOCAL cWin    := ""
LOCAL cKey, cDefaultWin
LOCAL aMtd    := {}
LOCAL nSize, cHead, bBlock, nLeft, nRight
//Mantis 746
LOCAL nBottom := 23
MEMVAR EnvId
PRIVATE EnvId := ALLTRIM(cAlias)

DEFAULT nTbOrd  TO INDEXORD()
DEFAULT nIndPos TO nTbOrd

dbdd->(ORDSETFOCUS(1))     // Controllo se devo creare la finestra
                           // o (come diceva il buon Testo') comprarla
                           // gia' fatta

dBdd->(dbSeek( "NDX" +cAlias +STR(nTbOrd,3) ))
cDefaultWin := ddIndexWin()
IF !EMPTY(cDefaultWin) .AND. dfIsFun( cDefaultWin +"exe()" )
   cWin := "{|A,B,C,D|" +cDefaultWin +"EXE(A,B,C,D)}"
ENDIF

IF EMPTY(cWin) // La faccio

   dbdd->(dbSeek( "DBF"+cAlias ))
   cInt := dfStdMsg(MSG_DDWIN01)+[ ]+TRIM(dbdd->field_des)+[ (a)]

   dbdd->(dbSeek( "FIE"+cAlias ))

   nSize := 0
   cKey  := UPPER( ORDKEY( nTbOrd ) )
   WHILE !dbdd->(eof()) .AND. "FIE"+cAlias == UPPER(dBdd->RecTyp+dBdd->file_name)

      IF dbdd->field_win = [1]

         IF (nAdd := AT( UPPER( ALLTRIM(dBdd->field_name) ), cKey))==0
            nAdd := nInd++
         ENDIF

         cHead  := ALLTRIM(dBdd->field_des)
         bBlock := FIELDBLOCK(alltrim(dBdd->field_name))
         AADD(aCol,{ nAdd, { cHead, bBlock }})
         //Mantis 746
         //nSize += MAX( LEN(cHead), LEN(dfAny2Str(EVAL(bBlock))) ) +1
         nSize += LEN(dfAny2Str(EVAL(bBlock)))  +1
      ENDIF
      dbdd->(DBSKIP())
   ENDDO
   ASORT(aCol,,,{|x,y|x[1]<y[1]})
   AEVAL( aCol, {|aRow| AADD( aAddCol, aRow[2] )})
   nSize   := MAX( LEN(cInt), nSize )
   //Mantis 746
   //nLeft   := INT( (MAXCOL()-2-nSize)/2 )
   nLeft   := INT( (90-2-nSize)/2 )
   nRight  := nLeft +nSize +1

   IF LEN(aCol)=0
      dbmsgerr(dfStdMsg(MSG_DDWIN01)+ cAlias +dfStdMsg(MSG_DDWIN02))
   ELSE
      // simone 10/12/09
      // XL1509 - aggiunto TIPO AZIONE per eventualmente scegliere quale operazione fare
      ADDKEY "ecr" TO aMtd ;
                   WHEN {||dfSet(AI_FILEMODIFY) .AND. EVAL( dfSet( AI_FILEINSERTCB ), ALLTRIM(cAlias), DE_STATE_DEL )} ;
                   BLOCK {|oWin|ddWinEtr( oWin )} MESSAGE dfStdMsg(MSG_DE_STATE_DEL)

      ADDKEY "mcr" TO aMtd ;
                   WHEN {||dfSet(AI_FILEMODIFY) .AND. EVAL( dfSet( AI_FILEINSERTCB ), ALLTRIM(cAlias), DE_STATE_MOD )} ;
                   BLOCK {|oWin|ddWinMtr( oWin )} MESSAGE dfStdMsg(MSG_DE_STATE_MOD)

      ADDKEY "anr" TO aMtd ;
                   WHEN {||dfSet(AI_FILEMODIFY) .AND. EVAL( dfSet( AI_FILEINSERTCB ), ALLTRIM(cAlias), DE_STATE_ADD )} ;
                   BLOCK {|oWin|ddWinAtr( oWin )} MESSAGE dfStdMsg(MSG_DE_STATE_ADD)

      // Setto l'indice
      SET ORDER TO nIndPos

      dfWin( ,nLeft,nBottom,nRight,; // Coordinate
             bTbKey,bTbFlt,bTbBrk,; // Chiave Filtro Break
             cInt            ,; // titolo
             aAddCol         ,;
             aMtd, NIL, cAct )
   ENDIF
ELSE // La compro gia' fatta
   EVAL( &cWin, nIndPos, bTbKey, bTbFlt, bTbBrk )
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE ddWinEtr( oWin ) // Erase
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cDel := ALLTRIM(ALIAS()) +"DID()" // Metodo del dbRid per cancellazione
LOCAL lDel := .F.

dfPushAct()
IF Bof() .OR. Eof()
   dbMsgErr( dfStdMsg(MSG_DDWIN03) )
ELSE
   IF dfYesNo( dfStdMsg(MSG_DDWIN04), .F. )
      IF dfIsFun( cDel )            // Se ho il metodo di DEL
         dfPushArea()
         lDel := &cDel
         dfPopArea()
      ELSE
         IF dfNet( NET_RECORDLOCK )     // Altrimenti uso un delete normale
            DBDELETE(); DBCOMMIT()
            dfNet( NET_RECORDUNLOCK )
            lDel := .T.
         ENDIF
      ENDIF
      IF lDel; tbEtr( oWin ); ENDIF
   ENDIF
ENDIF
dfPopAct()
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE ddWinMtr( oWin ) // Modify
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfPushAct()
IF Bof() .OR. Eof()
   dbMsgErr( dfStdMsg(MSG_DDWIN05) )
ELSE
   IF ddDe( DE_STATE_MOD )
      tbRtr( oWin )
   ENDIF
ENDIF
dfPopAct()
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE ddWinAtr( oWin ) // Append
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRec:=RECNO(), cAlias := ALIAS()
dfPushAct()
IF ddDe( DE_STATE_ADD )
   tbAtr( oWin )
ELSE
   (cAlias)->(DBGOTO(nRec))
ENDIF
dfPopAct()
RETURN
