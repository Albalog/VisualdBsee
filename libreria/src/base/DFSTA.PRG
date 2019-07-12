/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita' per Stampe
Programmatore  : Baccan Matteo
******************************************************************************/
#INCLUDE "Common.ch"   // CLIPPER
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
#INCLUDE "dfMsg.ch"    // Messaggistica


#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

STATIC aBuf, nCount := 1
#define SVIL_REC     1
#define SVIL_SEC     2
#define SVIL_LASTSEC 3
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE SvilLev( aVR, lMaster, nMode ) // Sviluppatore interno FILE
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lAllign, nRec, aPar := {,,}
LOCAL nStyle

DEFAULT lMaster TO .F.
DEFAULT nMode   TO PRINT_ALL


aBuf := dfPrnArr()

// Simone 06/10/08
// mantis 0001977: velocizzare le stampe 
nStyle := dfSet(AI_XBASEPRINTPROGRESSSTYLE)

IF lMaster
   IF nMode==PRINT_ALL      // Posiziono il FILE al 1' Record del master
      dfReportTOP( aVR )    // Solo se devo stampare tutto
   ENDIF
   aPar[SVIL_REC    ] := LASTREC()
   aPar[SVIL_SEC    ] := SECONDS()
   aPar[SVIL_LASTSEC] := aPar[SVIL_SEC]-2
   nCount := 1
ELSE
   dfReportTOP( aVR )
ENDIF

IF !Eof()
   nRec:=RECNO()
   WHILE !(lAllign := dfPrnAllign( aVr, .T., aBuf )) // NON sono allineato
      IF dfReportSKIP( aVR ) == 0              // Skippo
         EXIT
      ENDIF
   ENDDO
   IF lMaster .AND. nMode==PRINT_CURRENT .AND. nRec#RECNO()
      DBGOTO(nRec)
      lAllign:=.F.
   ENDIF

   IF lAllign // Se sono allineato stampo

      dfFleIni( aVR )       // Azzero variabili
      dfFlePre( aVR )       // Valorizzo le precalcolate
      dfFileHEADER( aVR )   // Stampo l'Header

      IF !EMPTY(aVR[VR_GRP_ARR])
         dfGrpIni( aVR, 1 )    // Azzero variabili di calcolo/precalcolo
         dfGrpPre( aVR, 1 )    // Valorizzo le precalcolate
         dfGrpHEADER( aVR )    // Valorizzo e intesto i Gruppi
      ENDIF

      WHILE lAllign    // Finche' sono allineato
         IF lMaster
            dfStaProg( aPar, nStyle ) // Stampa la progressione
         ENDIF

         IF !EMPTY(aVR[VR_GRP_ARR])
            dfGrpBrk( aVR, nRec ) // Controllo i gruppi e se e' il caso Footer/Header
         ENDIF

         // 27/09/95
         // Il calcolo delle variabili era effettuato a questo livello
         // ma se il body cambiava pagina avevo un totale non corrispondente
         // ai totali stampati
         // Le variabili di calcolo ora sono subito prima di stampare il body

         nRec:=RECNO()
         dfFileBODY( aVR ) // Stampo la riga

         IF !EMPTY(aVR[VR_CHILD]) // chiamo i sottofigli
            AEVAL( aVR[VR_CHILD], {|aLRec| (aLRec[VR_NAME])->(SvilLev(aLRec)) })
         ENDIF
         IF aBuf[REP_IS_ABORT] .OR. aBuf[REP_IS_QUIT]
            EXIT
         ENDIF

         IF lMaster .AND. nMode==PRINT_CURRENT; EXIT; ENDIF // In CURRENT non SKIPPO

         // skippo di 1
         IF dfReportSKIP( aVR ) == 0  // Se skip == 0 Sono in EOF
            lAllign := .F.            // allora non sono piu' allineato
         ELSE
            WHILE !(lAllign := dfPrnAllign( aVr, .T., aBuf )) // NON Sono Allineato
               IF dfReportSKIP( aVR ) == 0              // Skippo
                  EXIT
               ENDIF
            ENDDO
         ENDIF
      ENDDO
      IF !aBuf[REP_IS_ABORT] .AND. !aBuf[REP_IS_QUIT]
         aBuf[REP_IS_LAST] := .T.
         IF !EMPTY(aVR[VR_GRP_ARR])
            dfGrpFOOTER( aVR,, nRec )
         ENDIF
         dfFileFOOTER( aVR )
         aBuf[REP_IS_LAST] := .F.
      ENDIF
   ENDIF
ELSE // Check EOF mode
   IF aVR[VR_EOF_MODE] == VR_ABORT
      aBuf[REP_IS_ABORT] := .T.
   ENDIF
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfStaProg( aPar, nStyle ) //(PER CAAF)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSec, nTotal
LOCAL cMsg
nCount++
IF SECONDS()-aPar[SVIL_LASTSEC]>1
   aPar[SVIL_LASTSEC] := SECONDS()

   nSec   := INT(SECONDS()-aPar[SVIL_SEC])
   nTotal := MAX(INT(aPar[SVIL_REC]*nSec/nCount),nSec)

   // Simone 06/10/08
   // mantis 0001977: velocizzare le stampe 
   DO CASE
      CASE nStyle == AI_PRINTPROGRESSSTYLE_FANCY           .OR. ;
           nStyle == AI_PRINTPROGRESSSTYLE_FANCY_THREAD

         cMsg := dfPIStack():top():getCaption()
         IF CRLF $ cMsg
            cMsg := LEFT(cMsg, AT(CRLF, cMsg)-1)
         ENDIF
         dfPIUpdMsg( cMsg+ CRLF+CRLF+CRLF+;
                    PADR(dfStdMsg(MSG_DFSTA01)+STR(nSec  ),30)+;
                         dfStdMsg(MSG_DFSTA02)+STR(nTotal))

         IF nStyle == AI_PRINTPROGRESSSTYLE_FANCY
            dfPIStep(nSec, nTotal)
         ENDIF
      OTHERWISE
         dbFrameUpd( PADR(dfStdMsg(MSG_DFSTA01)+STR(nSec  ),30)+;
                          dfStdMsg(MSG_DFSTA02)+STR(nTotal),-2 )
         dbFramePro( nCount, aPar[SVIL_REC] )

   ENDCASE

ENDIF

// Simone 06/10/08
// mantis 0001977: velocizzare le stampe 
IF nStyle == AI_PRINTPROGRESSSTYLE_FANCY_THREAD
   // supporta anche nSec=NIL, nTotal=NIL 
   // in questo modo controllo solo l'interruzione di stampa
   IF ! dfPIStep(nSec, nTotal)
      aBuf[REP_IS_QUIT]:=.T.
   ENDIF
ELSE
IF dfINKEY()#0 //FW
   IF dfYesNo( dfStdMsg(MSG_DFSVILLEV01), .F. )
      aBuf[REP_IS_QUIT]:=.T.
   ENDIF
ENDIF
ENDIF
RETURN

// Chiama l'inizializzazione dei calcoli per le variabili Pre/Post calcolate
// a livello di file
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfFleIni( aVR ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
EVAL(aVR[VR_PRECALC_CLEAR]) // Inizializzo Variabili precalcolate
EVAL(aVR[VR_CALC_CLEAR]   ) // Inizializzo Variabili di calcolo
RETURN

// Chiama l'inizializzazione dei calcoli per le variabili Pre/Post calcolate
// a livello di gruppo, partendo dal gruppo passato
// se il gruppo non e' specificato si parte dal primo
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfGrpIni( aVR, nStart ) // Inizializza precalcolate/calcolate
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
AEVAL( aVR[VR_GRP_ARR], {|aSub|EVAL(aSub[VR_GRP_PRECALC_CLEAR])}, nStart )
AEVAL( aVR[VR_GRP_ARR], {|aSub|EVAL(aSub[VR_GRP_CALC_CLEAR])   }, nStart )
RETURN


// Chiama step per le variabili di calcolo
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfAftCal( aVR ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF aVR[VR_CALC_ADD]!=NIL
   EVAL(aVR[VR_CALC_ADD]) // Incrementa variabili di calcolo
ENDIF
RETURN

// Controllo se ho variabili di calcolo nei gruppi
// se si le valorizzo a monte, e poi mi riposiziono sul file di partenza
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfGrpPre( aVR, nGroup ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActual

FOR nActual := nGroup TO LEN(aVR[VR_GRP_ARR]) // Per tutti i gruppi
   IF aVR[VR_GRP_ARR][nActual][VR_GRP_PRECALC_ADD]!=NIL // Se ho variabili di precalcolo
      dfSubPre( aVR, aVR[VR_GRP_ARR][nActual][VR_GRP_PRECALC_ADD] ,;
                     aVR[VR_GRP_ARR][nActual][VR_GRP_BLK]          )
   ENDIF
NEXT

RETURN

// Controllo se ho variabili di calcolo a livello di file
// se si le valorizzo a monte, e poi mi riposiziono sul file di partenza
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfFlePre( aVR ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF aVR[VR_PRECALC_ADD]!=NIL // Se ho variabili di precalcolo
   dfSubPre( aVR, aVR[VR_PRECALC_ADD], {||.T.} )
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfSubPre( aVR, bPre, bBlock ) // Precalcolo generalizzato
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRec, uGroup

uGroup := EVAL(bBLock) // Fotografo il BLOCCO
nRec   := RECNO()
WHILE .T.
   IF aBuf[REP_QRY_BLOCK]!=NIL .AND. ;   // Se NON ho figli, percui sono
      EMPTY(aVR[VR_CHILD])               // all'estremo del record virtuale
      IF !EVAL(aBuf[REP_QRY_BLOCK])      // valuto il filtro di QUERY
         IF dfReportSKIP( aVR )==0 .OR.; // ed eventualemnte SKIPPO
            EVAL(bBLock)#uGroup
            EXIT
         ENDIF
         LOOP
      ENDIF
   ENDIF
   EVAL( bPre ) // Incrementa variabili precalcolate
   IF dfReportSKIP( aVR ) == 0 .OR.;
      EVAL(bBLock)#uGroup
      EXIT
   ENDIF
ENDDO
DBGOTO( nRec )

RETURN

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//
//Questa funzione provvede a controllare se i record si possono allineare, o
//se bisogna eseguire un recover
//
//Torna .T. se tutto OK
//      .F. in caso di RECOVER
//
//
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPrnAllign( aVr, lFather, aBuf ) // Testo l'allineamento //(PER CAAF)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lAllign := .T., lQry := .T.

DEFAULT lFather TO .F.

IF !lFather                           // Se non sono su un padre faccio il TOP
   dfReportTOP( aVR )
ENDIF

IF !EOF()
   IF EMPTY(aVR[VR_CHILD]) // Se non ho dei figli verifico che
                           // la query sia soddisfatta
      IF aBuf[REP_QRY_BLOCK]!=NIL
         WHILE .T.
            IF !EVAL(aBuf[REP_QRY_BLOCK])
               nCount++
               IF dfReportSKIP( aVR ) == 0
                  lAllign:=.F.
                  EXIT
               ENDIF
            ELSE
               EXIT
            ENDIF
         ENDDO
      ENDIF
   ELSE
      WHILE aScan( aVR[VR_CHILD],;
            {|aLVR| !(lAllign := (aLVR[VR_NAME])->(dfPrnAllign(aLVR,,aBuf))) }) # 0
         IF dfReportSKIP( aVR ) == 0
            lAllign:=.F.
            EXIT
         ENDIF
      ENDDO
   ENDIF
ELSE
   IF aBuf[REP_QRY_BLOCK]!=NIL
      lQry := EVAL(aBuf[REP_QRY_BLOCK])
   ENDIF
   IF !lQry .OR. dfPrnRecover( aVR ) // Se non soddisfa la query
      lAllign := .F.                 // o sono in recover
   ENDIF
ENDIF

RETURN lAllign
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//
// Valuta in ricorsione se c'e' un recover sui figli
//
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfPrnRecover( aVR )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRecover
IF aVR[VR_EOF_MODE] == VR_RECOVER
   lRecover := .T.
ELSE
   lRecover := (ASCAN( aVR[VR_CHILD], {|aLVR| dfPrnRecover(aLVR) }) # 0)
ENDIF
RETURN lRecover
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfGrpHEADER( aVR ) // Inizializza gruppi e stampa header
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
AEVAL( aVR[VR_GRP_ARR], {|aGrp| aGrp[VR_GRP_COMPARE] := EVAL(aGrp[VR_GRP_BLK]) ,;
                                GrpHEADER(aGrp)                                })
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfGrpBrk( aVR, nRec ) // Se ci sono gruppi footerizza e hederizza
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLev
nLev := ASCAN( aVR[VR_GRP_ARR], {|aGrp|!(aGrp[VR_GRP_COMPARE]==EVAL(aGrp[VR_GRP_BLK]))})
IF nLev > 0 // Rottura
   dfGrpFOOTER( aVR, nLev, nRec ) // Stampa footer
   dfGrpIni( aVR, nLev )    // Azzera calcoli
   dfGrpPre( aVR, nLev )    // Calcola precalcoli

   AEVAL( aVR[VR_GRP_ARR], {|aGrp| GrpHEADER( aGrp )    }, nLev )
   AEVAL( aVR[VR_GRP_ARR], {|aGrp| aGrp[VR_GRP_COMPARE] := EVAL(aGrp[VR_GRP_BLK]) } )
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfGrpFOOTER( aVR, nLev, nRec ) // Stampa i footer dal livello nLev
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nFoo, nOldRec := RECNO()
DEFAULT nLev TO 1

DBGOTO(nRec)
FOR nFoo := LEN(aVR[VR_GRP_ARR]) TO nLev STEP -1
   GrpFOOTER( aVR[VR_GRP_ARR][nFoo] )
NEXT
DBGOTO(nOldRec)

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfReportFOOTER( aBuf )    // Stampa il Footer di REPORT
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfFileHF( aBuf[REP_RF], aBuf[REP_POSRF], .T., 0, .F., aBuf[REP_CANRF] )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE GrpHEADER( aGrp ) // Stampa header di gruppo
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfFileHF( aGrp[VR_GRP_HEADER]    ,;
          aGrp[VR_GRP_POSHEADER] ,;
          aGrp[VR_GRP_BRKHEADER] ,;
          aGrp[VR_GRP_ROWHEADER] , .F., aGrp[VR_GRP_CANHEADER] )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE GrpFOOTER( aGrp ) // Stampa footer di gruppo
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfFileHF( aGrp[VR_GRP_FOOTER]    ,;
          aGrp[VR_GRP_POSFOOTER] ,;
          aGrp[VR_GRP_BRKFOOTER] ,;
          aGrp[VR_GRP_ROWFOOTER] , aGrp[VR_GRP_EJECT], aGrp[VR_GRP_CANFOOTER] )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfFIleHEADER( aVr ) // Stampa l'HEADER di File
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, l2Skip
IF aVR[VR_BODY2FOOT]
   // Se .T. l'header non si stampa
   l2Skip := (aVR[VR_HEADER]==NIL .OR. !EVAL(aVR[VR_CANHEADER]))

   // Devo stampare un footer sul body
   // Verifico se la lunghezza dell'header +
   //             la lunghezza del body    +
   //             la lunghezza del footer
   // non riescono a risiedere nella pagina, in questo caso salto pagina
   nPos := aVR[VR_POSHEADER]

   // Se non ho posizionamento, oppure se non ho la banda o se
   // non la devo stampare, assegno alla banda alla iga successiva
   IF nPos==0 .OR. l2Skip
      nPos := aBuf[REP_ACT_ROW] +1
   ENDIF

   // Aggiungo righe di Header
   IF !l2Skip
      nPos += aVR[VR_ROWHEADER]
   ENDIF

   // Aggiungo righe di body
   nPos += aVR[VR_ROWBODY]

   // Aggiungo righe di footer
   nPos += aVR[VR_ROWFOOTER]

   IF nPos >= aBuf[REP_FOOTER_LINE]
      dfPrnNewPage()
   ENDIF
ENDIF
dfFileHF( aVR[VR_HEADER]    ,;
          aVR[VR_POSHEADER] ,;
          aVR[VR_BRKHEADER] ,;
          aVR[VR_ROWHEADER] , .F., aVR[VR_CANHEADER] )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfFIleFOOTER( aVr ) // Stampa il Footer di File
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfFileHF( aVR[VR_FOOTER]    ,;
          aVR[VR_POSFOOTER] ,;
          aVR[VR_BRKFOOTER] ,;
          aVR[VR_ROWFOOTER] , aVR[VR_EJECT], aVR[VR_CANFOOTER] )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfFIleBODY( aVr )   // Stampa il BODY di File
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPage
IF aVR[VR_BODY]#NIL .AND. EVAL(aVR[VR_CANBODY])
   IF !aBuf[REP_NO_EJECT] // Se non esiste il salto pagina non faccio controlli
      IF aVR[VR_BODY2FOOT]
         aBuf[REP_BAN_ROW] := aBuf[REP_ACT_ROW]+1    // Riga di Banda
         IF dfIs2Print( aBuf, aVR )
            dfFIleHF( aVR[VR_BODYFOOT]    ,;         // superano il footer meno
                      aVR[VR_BODYPOSFOOT] ,;         // l'altezza di footer
                      .T.                 ,;
                      aVR[VR_BODYROWFOOT] , .F., aVR[VR_BODYCANFOOT] )
            dfPrnNewPage()
            IF aVR[VR_BODY2HEAD]
               dfFIleHF( aVR[VR_BODYHEAD]    ,;
                         aVR[VR_BODYPOSHEAD] ,;
                         .T.                 ,;
                         aVR[VR_BODYROWHEAD] , .F., aVR[VR_BODYCANHEAD] )
            ENDIF
         ENDIF
      ENDIF

      IF !aVR[VR_BRKBODY]
         aBuf[REP_BAN_ROW] := aBuf[REP_ACT_ROW]+1    // Riga di Banda
         IF aBuf[REP_BAN_ROW] +aVR[VR_ROWBODY] >= aBuf[REP_FOOTER_LINE]
            dfPrnNewPage()
            IF aVR[VR_BODY2HEAD]
               dfFIleHF( aVR[VR_BODYHEAD]    ,;
                         aVR[VR_BODYPOSHEAD] ,;
                         .T.                 ,;
                         aVR[VR_BODYROWHEAD] , .F., aVR[VR_BODYCANHEAD] )
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   // Variabili di Calcolo
   dfAftCal( aVR )

   // Pagina & Riga di Banda
   nPage             := aBuf[REP_ACT_PAGE]
   aBuf[REP_BAN_ROW] := aBuf[REP_ACT_ROW]+1

   // Stampo la banda di body
   dfPrintBand( aVR[VR_BODY] )

   IF aVR[VR_EJECTBODY]
      dfPrnNewPage() // Nuova pagina
   ELSE
      IF !aVR[VR_FLOATBODY]
         IF aBuf[REP_ACT_PAGE] == nPage .AND. ;  // FILL
            aBuf[REP_BAN_ROW] +aVR[VR_ROWBODY] -1 > aBuf[REP_ACT_ROW]
            dfprint( aVR[VR_ROWBODY] -1 )
         ENDIF
      ENDIF
   ENDIF
ELSE
   dfAftCal( aVR )  // Se non esiste il body effettuo almeno
                    // le variabili di calcolo
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfIs2Print( aBuf, aVR )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.
IF aVR[VR_BODYPOSFOOT]==0
   lRet := (aBuf[REP_BAN_ROW]     +aVR[VR_ROWBODY]    -1) >= ;
           (aBuf[REP_FOOTER_LINE] -aVR[VR_BODYROWFOOT]  )
ELSE
   lRet := (aBuf[REP_BAN_ROW]     +aVR[VR_ROWBODY]    -1) >= ;
            aVR[VR_BODYPOSFOOT]
ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfFIleHF( bBand, nPos, lBreak, nRow, lEject, bPrint ) // Stampa H/F
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPage

aBuf[REP_BAN_ROW] := aBuf[REP_ACT_ROW] +1          // Riga di Banda
//IF bBand # NIL .AND. EVAL(bPrint)
IF bBand # NIL .AND. VALTYPE(bPrint)== "B" .AND.EVAL(bPrint)
   DO CASE
      CASE nPos#0            // Posizionamento Fisso
           //
           // Sul  posizionamento fisso NON ha piu' peso il fatto di dire che
           // la  banda  non  puo' essere interrotta  da  un salto pagina. Se
           // accade che una banda a posizionamento fisso viene interrotta da
           // un salto pagina e' perche' ho cazzato la lunghezza della pagina
           //
           IF aBuf[REP_BAN_ROW] > nPos
              dfPrnNewPage()
           ENDIF
           aBuf[REP_BAN_ROW] := nPos
      CASE !lBreak           // Salto banda interbanda NON consentito
           IF aBuf[REP_BAN_ROW] +nRow >= aBuf[REP_FOOTER_LINE]
              dfPrnNewPage()                              // New page
              aBuf[REP_BAN_ROW] := aBuf[REP_ACT_ROW] +1   // Allineo
           ENDIF
   ENDCASE
   nPage := aBuf[REP_ACT_PAGE]

   // Stampo la banda di H/F
   dfPrintBand( bBand )

   IF lEject
      dfPrnNewPage() // Nuova pagina
   ELSE
      IF aBuf[REP_ACT_PAGE] == nPage .AND. ;  // FILL
         aBuf[REP_BAN_ROW] +nRow -1 > aBuf[REP_ACT_ROW]
         dfprint( nRow-1 )
      ENDIF
   ENDIF
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfReportTOP( aVR )   // GoTop sul File //(PER CAAF)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF aVR[VR_SKIPARRAY]!=NIL
   aVR[VR_SKIPPOS]:=1
   IF LEN( aVR[VR_SKIPARRAY] ) == 0
      GOTO( 0 )                    // Manda in eof()
   ELSE
      GOTO( aVR[VR_SKIPARRAY][1] ) // Primo record
   ENDIF
ELSE
   dfTop( aVR[VR_KEY], aVR[VR_FILTER], aVR[VR_BREAK] )
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfReportSKIP( aVR )  // Skip  sul File //(PER CAAF)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL uRet := 0

IF aVR[VR_SKIPARRAY]!=NIL
   IF aVR[VR_SKIPPOS]<LEN(aVR[VR_SKIPARRAY])
      GOTO( aVR[VR_SKIPARRAY][ ++aVR[VR_SKIPPOS] ] ) // Prossimo record
      uRet := 1
   ENDIF
ELSE
   uRet := dfSkip( 1, aVR[VR_FILTER], aVR[VR_BREAK] )
ENDIF

RETURN uRet

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Intesta una nuova pagina
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfPrnNewPage()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF !aBuf[REP_NO_EJECT]
   dfPrnFOOTER(aBuf)  // Stampo un Footer
   dfPrnHEADER(aBuf)  // Reintesto
ENDIF
RETURN

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//
// Controllo se uno dei Master ha almeno una riga da stampare
//
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfPrnCheck( aVR, nMode ) // Controllo se c'e' qualcosa da Stampare
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF nMode==PRINT_ALL
   dfReportTOP( aVR )
ENDIF
RETURN !EOF()

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPrintBand( bBand ) // Stampo la banda // USATA da varie procedure
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cAlias := ALIAS()       // Devo memorizzare l'area di ingresso
EVAL( bBand )                 // per evitare che la stampa di una banda
IF !EMPTY(cAlias)             // possa spostare l'area di lavoro
   DBSELECTAREA( cAlias )     // e mandare in crisi il sistema
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPrnMaxTop( aBuf, aVR )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRet := aBuf[REP_MGN_TOP], nPos, nGroup

// Non controllo la condizione di banda perche'
// le condizioni potrebbero NON essere attive
// Inoltre la valutazione di MIN sul margine TOP
// DEVE essere fatta a livello generale

FOR nPos := 1 TO LEN(aVR)
   IF aVR[nPos][VR_HEADER]   #NIL .AND.;
      aVR[nPos][VR_POSHEADER]>0
      nRet := MIN( nRet, aVR[nPos][VR_POSHEADER]-1 )
   ENDIF

   IF aVR[nPos][VR_BODYHEAD]   #NIL .AND.;
      aVR[nPos][VR_BODYPOSHEAD]>0
      nRet := MIN( nRet, aVR[nPos][VR_BODYPOSHEAD]-1 )
   ENDIF

   IF aVR[nPos][VR_BODYFOOT]   #NIL .AND.;
      aVR[nPos][VR_BODYPOSFOOT]>0
      nRet := MIN( nRet, aVR[nPos][VR_BODYPOSFOOT]-1 )
   ENDIF

   IF aVR[nPos][VR_FOOTER]   #NIL .AND.;
      aVR[nPos][VR_POSFOOTER]>0
      nRet := MIN( nRet, aVR[nPos][VR_POSFOOTER]-1 )
   ENDIF

   FOR nGroup := 1 TO LEN(aVR[nPos][VR_GRP_ARR])
      IF aVR[nPos][VR_GRP_ARR][nGroup][VR_GRP_HEADER]   #NIL .AND.;
         aVR[nPos][VR_GRP_ARR][nGroup][VR_GRP_POSHEADER]>0
         nRet := MIN( nRet, aVR[nPos][VR_GRP_ARR][nGroup][VR_GRP_POSHEADER]-1 )
      ENDIF

      IF aVR[nPos][VR_GRP_ARR][nGroup][VR_GRP_FOOTER]   #NIL .AND.;
         aVR[nPos][VR_GRP_ARR][nGroup][VR_GRP_POSFOOTER]>0
         nRet := MIN( nRet, aVR[nPos][VR_GRP_ARR][nGroup][VR_GRP_POSFOOTER]-1 )
      ENDIF
   NEXT

   nRet := MIN( nRet, dfPrnMaxTop( aBuf, aVR[nPos][VR_CHILD] ) )
NEXT

RETURN nRet

/*

//
// Test variabili di calcolo
//

STATIC nSum    ,;                                   // Somma
       nCount  ,;                                   // Contatore
       nMedia  , nTotMedia , nSumMedia ,;           // Media
       nDev    , nTotDev   , nSumDev   , nAppDev ,; // Varianza
       nVar    , nTotVar   , nSumVar   , nAppVar ,; // Deviazione Standard
       nMin    ,;                                   // Minimo
       nMax    ,;                                   // Massimo
       nRange  , nRangeIni , nRangeEnd              // Range

#include "Common.ch"
STATIC  XXXXXX

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE Main()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLup

dfVarIni()

FOR nLup := 1 TO 3
   XXXXXX := nLup
   dfVarAdd()
NEXT

? nSum
? nCount
? nMedia  , nTotMedia , nSumMedia
? nDev    , nTotDev   , nSumDev   , nAppDev
? nVar    , nTotVar   , nSumVar   , nAppVar
? nMin
? nMax
? nRange  , nRangeIni , nRangeEnd

dfVarIni()
FOR nLup := 1 TO 3
   XXXXXX := nLup
   dfVarAdd()
NEXT

? nSum
? nCount
? nMedia  , nTotMedia , nSumMedia
? nDev    , nTotDev   , nSumDev   , nAppDev
? nVar    , nTotVar   , nSumVar   , nAppVar
? nMin
? nMax
? nRange  , nRangeIni , nRangeEnd

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfVarIni()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

nSum   := 0
nCount := 0
nMedia := 0; nTotMedia := 0; nSumMedia := 0
nDev   := 0; nTotDev   := 0; nSumDev   := 0; nAppDev := 0
nVar   := 0; nTotVar   := 0; nSumVar   := 0; nAppVar := 0
nMin   := NIL
nMax   := NIL
nRange := NIL; nRangeIni := NIL; nRangeEnd := NIL

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfVarAdd()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nDmm

// Somma
nSum += (XXXXXX)

// Contatore
nCount += (XXXXXX)

// Media
nSumMedia += (XXXXXX)
nMedia    := nSumMedia / ++nTotMedia

// Varianza
nSumVar += (XXXXXX)
nDmm    := nSumVar / ++nTotVar
nAppVar += ((XXXXXX) - nDmm) ^2
IF nTotVar==1
   nVar := 0
ELSE
   nVar := nAppVar/nTotVar -1
ENDIF

// Deviazione Standard
nSumDev += (XXXXXX)
nDmm    := nSumDev / ++nTotDev
nAppDev += ((XXXXXX) - nDmm) ^2
IF nTotDev==1
   nDev := 0
ELSE
   nDev := SQRT( nAppDev/nTotDev -1 )
ENDIF

// Minimo
DEFAULT nMin TO (XXXXXX)
IF nMin > (XXXXXX)
   nMin := (XXXXXX)
ENDIF

// Massimo
DEFAULT nMax TO (XXXXXX)
IF nMax < (XXXXXX)
   nMax := (XXXXXX)
ENDIF

// Range
DEFAULT nRangeIni TO (XXXXXX)
DEFAULT nRangeEnd TO (XXXXXX)
IF nRangeIni>(XXXXXX)
   nRangeIni:=(XXXXXX)
ENDIF
IF nRangeEnd<(XXXXXX)
   nRangeEnd:=(XXXXXX)
ENDIF
nRange := ABS( nRangeEnd -nRangeIni )

RETURN

*/
