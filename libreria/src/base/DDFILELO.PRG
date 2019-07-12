//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per NETWORK
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include "dfMsg.CH"
#include "dfNet.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFileLock( cOpe ,cFile )  // Semaforo sul DBDD
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lLock, lRet := .T., cNetName
dfPushArea()
dbCfgOpen( "dbdd" )
cOpe:=LOWER(cOpe)
IF !DBSEEK( "DBF"+UPPER(cFile) )
   dbMsgErr( dfStdMsg(MSG_DFNET10) +" "+cFile)
ENDIF
DO CASE
   CASE cOpe==DD_LOCK
        lLock := ( ASCAN( dfLockList(), RECNO() )!=0 .OR. _DBRLOCK(RECNO()) )
        IF !lLock // Non ho lockato
           dfWaitOn( dfStdMsg(MSG_DFNET08)    +" " +;
                     ALLTRIM(dbdd->FIELD_DES) +" " +;
                     dfStdMsg(MSG_DFNET09) )
           WHILE !DBRLOCK(RECNO())
              dfWaitStep()
             #ifdef __XPP__
              // simone 5/11/04 
              // aspetto un po per evitare troppo consumo CPU
              sleep(10)
             #endif
           ENDDO
           dfWaitOff( )
        ENDIF

        cNetName := NETNAME()
        //Luca 11/11/2015 : se il nome della netname Š pi— lunga del campo ritorna un errore la routine di salvataggio info.
        cNetName := PADR(cNetName, LEN(dbdd->field_MSG))
        dbdd->field_MSG := cNetName

   CASE cOpe==DD_UNLOCK
        IF ASCAN( dfLockList(), RECNO() )#0 // Se il record e' lockato
           dbdd->field_MSG := ""
           DBCOMMIT()
           _DBRUNLOCK(RECNO())
        ENDIF

   CASE cOpe==DD_CHECK
        lRet := ASCAN( dfLockList(), RECNO() )#0

   OTHERWISE
        dBMsgErr( dfStdMsg(MSG_ATTBUTUND) )
        lRet := .F.
ENDCASE
dfPopArea()
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

