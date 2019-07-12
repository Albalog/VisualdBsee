//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per NETWORK
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfMsg.CH"
#include "dfset.ch"
#include "inkey.ch"
#include "dfNet.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfNet( cNetOpe   ,; // Funzione da eseguire.
                nTimeOut  ,; // TimeOut o termine reiterati tentativi
                nRecno    ,; // Record su cui fare il LOCK
                lShowWin  ,; // Mostra la finestra di attesa
                lCanBreak ,; // abilita interruzione timeout
                lLocked    ) // by reference ritorna se ha fatto il lock
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL b

   b := dfSet({AI_XBASESTDFUNCTIONS,  AI_STDFUNC_DFNET})
   IF VALTYPE(b)=="B"
      RETURN EVAL(b, ;
                cNetOpe   ,; // Funzione da eseguire.
                nTimeOut  ,; // TimeOut o termine reiterati tentativi
                nRecno    ,; // Record su cui fare il LOCK
                lShowWin  ,; // Mostra la finestra di attesa
                lCanBreak ,; // abilita interruzione timeout
                @lLocked    ) // by reference ritorna se ha fatto il lock

   ENDIF
RETURN dfNet1( cNetOpe   ,; // Funzione da eseguire.
               nTimeOut  ,; // TimeOut o termine reiterati tentativi
               nRecno    ,; // Record su cui fare il LOCK
               lShowWin  ,; // Mostra la finestra di attesa
               lCanBreak ,; // abilita interruzione timeout
               @lLocked   ) // by reference ritorna se ha fatto il lock

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfNet1(cNetOpe   ,; // Funzione da eseguire.
                nTimeOut  ,; // TimeOut o termine reiterati tentativi
                nRecno    ,; // Record su cui fare il LOCK
                lShowWin  ,; // Mostra la finestra di attesa
                lCanBreak ,; // abilita interruzione timeout
                lLocked    ) // by reference ritorna se ha fatto il lock
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStrErr, nSecond ,lRet , lActive, nStartSec, cRdd
LOCAL nPrev, nNext
//LOCAL bNetwork := dfSet(AI_NETWORKCB)

DEFAULT nTimeOut  TO dfSet(AI_LOCKREPEATTIME) // Se non viene passato parametro
                                   // di TimeOut Usa TimeOut di configurazione
DEFAULT nRecno    TO RECNO()
DEFAULT lShowWin  TO .T.
DEFAULT lCanBreak TO .T.

// Simone 23/11/07
// by reference ritorna se ha fatto il lock
// in modo da poter successivamente evitare 
// l'unlock di un record non lockato
lLocked := .F.

cStrErr := "" ; nSecond := 0 ; lRet := .F.
lActive   := .F.
nStartSec := SECONDS()
cNetOpe   := LOWER(cNetOpe)
cRdd      := RDDNAME()

//IF EMPTY(bNetwork)
//   bNetwork := {|| .T.}
//ENDIF

//EVAL(bNetwork, cNetOpe, nRecno, 0)

WHILE .T.

   DO CASE
      CASE cNetOpe == NET_RECORDUNLOCK // SBLOCCO RECORD
           lRet:=.T.
          #ifdef __XPP__
           // Modificato per Xbase 1.6, aggiunto il controllo che sia
           // nella locklist
           IF !EOF() .AND. ASCAN(dfLockList(), nRecno) > 0
          #else
           // In clipper lascio standard perchŠ DBFCDX ha la dfLockList bucata!
           IF !EOF() 
          #endif
//              EVAL(bNetwork, cNetOpe, nRecno, 10, .T.)
              DBRUNLOCK( nRecno )
//              EVAL(bNetwork, cNetOpe, nRecno, 20, .T.)
              dfUserLog( ALIAS() +" RECORDUNLOCK" )
              lLocked := .T.
IF .F.
              dfGetLockInfo(nRecno) 
ENDIF 
           ENDIF

      CASE cNetOpe == NET_FILEUNLOCK   // SBLOCCO FILE
//           EVAL(bNetwork, cNetOpe, nRecno, 10, .T.)
           UNLOCK
//           EVAL(bNetwork, cNetOpe, nRecno, 20, .T.)
           lRet    := .T.
           dfUserLog( ALIAS() +" FILEUNLOCK" )
           lLocked := .T.
IF .F.
           dfGetLockInfo(0)
ENDIF 
      CASE cNetOpe == NET_FILELOCK   // BLOCCO FILE
//           EVAL(bNetwork, cNetOpe, 10, .T.)
           IF dfASDriver( cRdd )
              lRet    := .T.
           ELSE
              lRet    := FLOCK()
              IF lRet
                 lLocked := .T.
              ENDIF
           ENDIF
//           EVAL(bNetwork, cNetOpe, nRecno, 20, lRet)
           cStrErr := dfStdMsg(MSG_DFNET01) +ALIAS() +[ ]
           dfUserLog( ALIAS() +" FILELOCK" )

IF .F.
           IF lRet
              dfSetLockInfo(0)
           ELSE
              dfCheckLockInfo(0)
           ENDIF
ENDIF 

      CASE cNetOpe == NET_RECORDLOCK // BLOCCO RECORD
           lRet:=.T.
           IF !EOF() // Se EOF vi e' un BLOCCO del sistema
              IF dfASDriver( cRdd )

                 nPrev:=nNext:=0

                 // Memorizzo record prima
                 DBSKIP(-1)
                 IF !BOF()
                    nPrev := RECNO()
                    DBSKIP(1)
                 ENDIF

                 // Memorizzo record dopo
                 DBSKIP(1)
                 IF !EOF()
                    nNext := RECNO()
                 ENDIF

                 // Refresh forzato
                 DBGOTOP()
                 DBGOTO( nRecno )

                 // Test Record Cancellato
                 IF RECNO()!=nRecno
                    // Posizionamento
                    DO CASE
                       CASE nPrev!=0; DBGOTO( nPrev )
                       CASE nNext!=0; DBGOTO( nNext )
                       OTHERWISE    ; DBGOTOP()
                    ENDCASE
                    lRet := .F.
                    EXIT
                 ENDIF
              ENDIF

              lRet := ASCAN(dfLockList(),nRecno)!=0 


              IF ! lRet 
//                 EVAL(bNetwork, cNetOpe, nRecno, 10, .T.)
                 lRet := DBRLOCK(nRecno) 
                 // Simone 23/11/07
                 // by reference ritorna se ha fatto il lock
                 IF lRet
                    lLocked := .T.
                 ENDIF
//                 EVAL(bNetwork, cNetOpe, nRecno, 20, lRet)
              ENDIF
              //Mantis 1623
              //cStrErr := dfStdMsg(MSG_DFNET02) +LTRIM(STR(nRecno,5))
              cStrErr := dfStdMsg(MSG_DFNET02)     
              cStrErr := STRTRAN(cStrErr,"%1%", ALIAS() )
              cStrErr := STRTRAN(cStrErr,"%2%", LTRIM(STRZERO(nRecno,5)) )
              dfUserLog( ALIAS() +" RECORDLOCK" )
IF .F.
              IF lLocked 
                 dfSetLockInfo(nRecno)
              ELSE
                 dfCheckLockInfo(nRecno)
                 lShowWin := .F.
              ENDIF 
ENDIF

           ENDIF

      CASE cNetOpe == NET_APPEND     // BLOCCO RECORD SU APPEND

//           EVAL(bNetwork, cNetOpe, nRecno, 10, .T.)
           IF "-"+UPPER(cRdd)+"-" $ "-DBFCDXAX-DBFNTXAX-"
              // AXS ha un BUG nelle aperture in esclusiva del file
              // Se in questi casi Š usata una DBAPPEND(.F.) l'unlock
              // non rilascia il record lockato
              DBAPPEND( dfAXSExclusive() )  // Dipende dall'apertura
           ELSE
              #IFDEF __XPP__
                 DBAPPEND(  1  )  // Per NON perdere i LOCK precedenti
              #ELSE
                 DBAPPEND( .F. )  // Per NON perdere i LOCK precedenti
              #ENDIF
           ENDIF

           IF dfASDriver( cRdd )
              DBCOMMIT()  // Forziamo la scrittura su disco
              DBSKIP( 0 ) // In modo che lo skip 0 possa leggere
                          // il numero di record corretto riaggiornando
                          // il puntatore di record
           ENDIF
           lRet    := !NETERR()
           // Simone 23/11/07
           // by reference ritorna se ha fatto il lock
           IF lRet
              lLocked := .T.
           ENDIF
//           EVAL(bNetwork, cNetOpe, nRecno, 20, lRet)
           //Mantis 1623
           cStrErr := dfStdMsg(MSG_DFNET03)
           cStrErr := STRTRAN(cStrErr,"%1%", ALIAS() )
           dfUserLog( ALIAS() +" APPEND" )
IF .F.
           IF lRet
              dfSetLockInfo(Recno())
           ENDIF
ENDIF

      OTHERWISE                     // FUNZIONE SCONOSCIUTA
           dBMsgErr( dfStdMsg(MSG_ATTBUTUND) )
           RETURN lRet

   ENDCASE

   IF !(lRet)

      IF lShowWin
         IF !lActive
               DO CASE
                  CASE nTimeout==0 
//Mantis 1623
//                       dfWaitOn( cStrErr +" - " +dfStdMsg(MSG_DDUSE09) +;
//                                 STR(nTimeOut) +" "                   +;
//                                 dfStdMsg(MSG_DFNET07) )
                       dfWaitOn( cStrErr +"//" +dfStdMsg(MSG_DDUSE09) +"!" )
                  CASE nTimeOut>0
//Mantis 1623
//                       dfPIOn( dfStdMsg(MSG_DFNET06), ;
//                               cStrErr +" - " +dfStdMsg(MSG_DDUSE09) +;
//                               STR(nTimeOut) +" "+dfStdMsg(MSG_DFNET07), ;
//                               lCanBreak )
                       dfPIOn( dfStdMsg(MSG_DFNET06), ;
                               cStrErr +"//" +dfStdMsg(MSG_DDUSE09) +;
                               " ("+STR(nTimeOut) +" "+dfStdMsg(MSG_DFNET07)+").", ;
                               lCanBreak )
               ENDCASE
            lActive := .T.
         ELSE
            DO CASE
               CASE nTimeout==0
                    dfWaitStep()
               CASE nTimeOut>0
                    IF !dfPIStep( nSecond, nTimeout )
                       nStartSec := SECONDS() -nTimeout
                    ENDIF
            ENDCASE
         ENDIF
      ENDIF
      //Mantis 2063 
      // simone 10/2/09
      // attendo un secondo per scaricare la CPU che altrimenti 
      // pu• bloccare il PC, specialmente in ambiente Terminal Server
      sleep(100) 

      IF nTimeout == 0                      // Tentativi infiniti sino al
         LOOP                               // successo dell'operazione
      ENDIF

      nSecond := SECONDS() -nStartSec       // Incrementa i secondi
      IF nSecond >= nTimeout                // Se si raggiunge il valore di
         IF nTimeout>=0  .AND. lShowWin
            dfPIOff()  // Wait NON passa MAI
         ENDIF
         EXIT                               // TimeOut sospende l'operazione
      ENDIF

   ELSE
      IF lActive .AND. lShowWin
         DO CASE
            CASE nTimeout==0; dfWaitOff()
            CASE nTimeOut>0 ; dfPIOff()
         ENDCASE
      ENDIF

      EXIT

   ENDIF

ENDDO

//EVAL(bNetwork, cNetOpe, nRecno, 100, lRet, lLocked)

RETURN lRet


STATIC FUNCTION _DBRLOCK(nRec)
  LOCAL lRet  := DBRLOCK(nRec)
  IF lRet
  //   dfSetLockInfo(nRec)
  ENDIF 
RETURN lRet

STATIC FUNCTION _DBRUNLOCK(nRec)
  LOCAL lRet  := DBRUNLOCK(nRec)
  IF lRet
  //   dfGetLockInfo(nRec) 
  ENDIF 
RETURN lRet



