/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
PROCEDURE ddSemLock()
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
dfPushArea()
dbCfgOpen( "dbdd" )
DBDD->(DBGOTO(0))
WHILE !DBDD->(RLOCK()); END
dfPopArea()
RETURN

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
PROCEDURE ddSemUnlock()
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
DBDD->(dfPushArea())
DBDD->(DBGOTO(0))
DBDD->(DBRUNLOCK(RECNO()))
DBDD->(dfPopArea())
RETURN

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION ddSemIslock()
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL lRet
DBDD->(dfPushArea())
DBDD->(DBGOTO(0))
lRet := ASCAN( DBDD->(dfLockList()), DBDD->(RECNO()) )>0
DBDD->(dfPopArea())
RETURN lRet
