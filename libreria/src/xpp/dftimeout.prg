#include "AppEvent.ch"
#include "dfXbase.ch"
#include "Common.ch"
#include "dfSet.ch"
#INCLUDE "dfMsg1.ch"   // Messaggistica

STATIC lTimeOUT_ACTIVE := NIL

FUNCTION dfACTIVETIMEOUT(nSec, lSet)
  DEFAULT lSET TO .F.
  IF lSET
     dfSet("XbaseActivateGetTimeout", "YES") 
  ENDIF 
  lTimeOUT_ACTIVE := dfSet("XbaseActivateGetTimeout") == "YES" 
  IF lTimeOUT_ACTIVE
     IF VALTYPE(nSec) == "N" 
        //Devo fare la conversione secondi a mili a secondi 
        dfSet(AI_GETTIMEOUT, nSec * 100)
     ELSE 
        IF EMPTY(dfSet(AI_GETTIMEOUT))
          dfSet(AI_GETTIMEOUT, 600 * 100)
        ENDIF  
     ENDIF  
  ENDIF 
RETURN .T.

FUNCTION dfDISABLETIMEOUT(lSET)
  DEFAULT lSET TO .F.
  IF lSET
     dfSet("XbaseActivateGetTimeout", "NO") 
  ENDIF 
  lTimeOUT_ACTIVE := .F.
RETURN lTimeOUT_ACTIVE

FUNCTION df_IS_TIMEOUT_ACTIVE()
  IF lTimeOUT_ACTIVE == NIL
     lTimeOUT_ACTIVE := dfSet("XbaseActivateGetTimeout") == "YES" 
  ENDIF 
RETURN lTimeOUT_ACTIVE

//Funzione ancora da implementare per bene 
FUNCTION dfUserEventWait(nSec, oDlg)
  LOCAL lMove  := .F.
  LOCAL nCount := 0
  LOCAL mp1,mp2,oXbp, nEvent
  LOCAL nOldStyle :=  dfSet(AI_XBASEMSGSTYLE)
  LOCAL nSecOut   :=  0
  LOCAL nKey      :=  0

  IF VALTYPE(nSec) != "N"
     nSec := NIL
  ELSE
     nSec := INT(nSec)
  ENDIF

  DEFAULT nSec TO 10
  nSecOut   :=  SECONDS() + nSec

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  //Luca 17/12/2007
  //Inserito perche la routine in basso non funziona correttamente dal punto di vista grafico.
  //////////////////////////////////////////////////////////////
  //RETURN lMove
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
     
  dfSet(AI_XBASEMSGSTYLE, AI_MSGSTYLE_FANCY_AUTO)

  dbMsgOn(dfMsgTran(dfStdMsg1(MSG1_DFUSEREVENTWAIT1),"count="+Str(nSec-nCount))  )
  sleep(10)

//  nEvent   := AppEvent(@mp1, @mp2, @oxbp, nSec *100)
//
//  IF ! nEvent == xbeP_Keyboard .OR. (nEvent >= xbeM_Enter .AND.  nEvent <= xbeM_RbMotion )
//     //nEvent== xbe_None
//     lMove := .F.
//  ELSE 
//     lMove := .T.
//  ENDIF 



  DO WHILE !lMove .AND.  nSecOut  >=  SECONDS()
     dbMsgUpd( dfMsgTran(dfStdMsg1(MSG1_DFUSEREVENTWAIT1),"count="+Str(nSecOut-SECONDS(), 3, 0 )) )
     sleep(10)
     //lMove := !EMPTY(dfINKEY())
     lMove := !EMPTY(dfINKEY(1))
  ENDDO
  dbMsgOff()

  IF nOldStyle != AI_MSGSTYLE_FANCY_AUTO
     dfSet(AI_XBASEMSGSTYLE,nOldStyle )
  ENDIF 
  
RETURN lMove




