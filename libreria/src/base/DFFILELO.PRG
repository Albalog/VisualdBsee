//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per NETWORK
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfnet.ch"
#include "dfStd.ch"
#include "Common.ch"

STATIC aFile := {}, aFRec := {}
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFileLock( aLock )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T., cAlias := UPPER(ALLTRIM(ALIAS())), aRec := dfLockList()
IF ASCAN( aFile, {|c|c==cAlias} )==0
   IF (lRet:=dfNet( NET_FILELOCK ))
      AADD( aLock, cAlias )
      AADD( aFile, cAlias )
      AADD( aFRec, aRec   )
   ENDIF
ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfFileUnLock( aLock )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActual, nDel, nRec, lLock
FOR nActual := 1 TO LEN(aLock)
   lLock := ddFileLock( DD_CHECK, aLock[nActual] )
   IF lLock
      ddFileLock( DD_LOCK, aLock[nActual] )
   ENDIF
   (aLock[nActual])->(dfNet(NET_FILEUNLOCK))
   // simone 2/11/07 mantis 0001636: la dffileunlock pu• fallire se ci sono alias simili
   nDel := ASCAN( aFile, {|c|c==UPPER(ALLTRIM(aLock[nActual]))} )
   IF nDel>0
      FOR nRec := 1 TO LEN(aFRec[nDel]) // Rilocco i record in modo bloccante
         (aLock[nActual])->(dfNet(NET_RECORDLOCK,0,aFRec[nDel][nRec]))
      NEXT
      DFAERASE( aFile, nDel )
      DFAERASE( aFRec, nDel )
   ENDIF
   IF lLock
      ddFileLock( DD_UNLOCK, aLock[nActual] )
   ENDIF
NEXT
ASIZE(aLock,0)
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFileIsLock( cFile )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DEFAULT cFile TO ALIAS()
cFile := UPPER(ALLTRIM(cFile))
RETURN ASCAN( aFile, {|c|c==cFile} )!=0
