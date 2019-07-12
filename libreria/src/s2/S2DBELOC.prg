#include "common.ch"

#include "dbfdbe.ch"
#include "foxdbe.ch"
#include "ntxdbe.ch"
#include "cdxdbe.ch"

// Imposta il tempo di lock e il retry in base a APPS.INI
// per default lo mette rispettivamente a 10 e 100, 
// dovrebbe essere sufficiente
// per evitare il runtime error 8999

FUNCTION S2DbeLockSet(cRdd)
   LOCAL cCurrRdd := DbeSetDefault()
   LOCAL aRet

   IF cRdd == NIL .OR. cCurrRdd == cRdd
      aRet := LockSet()

   ELSEIF ASCAN(DbeList(), {|x| x[1] == cRdd }) > 0
      DbeSetDefault(cRdd)
      aRet := LockSet()
      DbeSetDefault(cCurrRdd)
   ENDIF

RETURN aRet

// Simone 20/11/03 modificati i default come
// descritto in GERR 3691
//Tabella dei valori impostati per default
//versione Xbase++	1.3  	1.5	1.6 e succ.
//DBFDBE_LOCKDELAY	500	 15	    15
//DBFDBE_LOCKRETRY	  3	100	100000
//NTXDBE_LOCKDELAY	100	 15	    15
//NTXDBE_LOCKRETRY	 10	100	100000

STATIC FUNCTION LockSet()
   LOCAL aRet := {NIL, NIL, NIL, NIL}
   LOCAL cRdd := DbeSetDefault()
   LOCAL cSet
   LOCAL nPos
   LOCAL nType
   LOCAL aDbe :=  { {"DBFDBE", COMPONENT_DATA , {DBFDBE_LOCKRETRY, DBFDBE_LOCKDELAY}}, ;
                    {"FOXDBE", COMPONENT_DATA , {FOXDBE_LOCKRETRY, FOXDBE_LOCKDELAY}}, ;
                    {"NTXDBE", COMPONENT_ORDER, {NTXDBE_LOCKRETRY, NTXDBE_LOCKDELAY}}, ;
                    {"CDXDBE", COMPONENT_ORDER, {CDXDBE_LOCKRETRY, CDXDBE_LOCKDELAY}}  }


   // Qui la dfSet non funziona perchŠ questa funzione Š
   // chiamata dalla DbeSys, prima delle inizializzazioni della lib dbsee.
   // Imposto comunque il default retry:100 e delay:10

   // cSet := dfSet("Xbase"+cRdd+"DataLockRetry")
   cSet := NIL
   DEFAULT cSet TO "100000"
   aRet[1] := cSet

   // cSet := dfSet("Xbase"+cRdd+"DataLockDelay")
   cSet := NIL
   DEFAULT cSet TO "15"
   aRet[2] := cSet

   // cSet := dfSet("Xbase"+cRdd+"OrderLockRetry")
   cSet := NIL
   DEFAULT cSet TO "100000"
   aRet[3] := cSet

   // cSet := dfSet("Xbase"+cRdd+"OrderLockDelay")
   cSet := NIL
   DEFAULT cSet TO "15"
   aRet[4] := cSet

   nType := COMPONENT_DATA
   cSet := DbeInfo(nType, DBE_NAME)
   nPos := ASCAN(aDbe, {|x| x[1] == cSet .AND. x[2] == nType })
   IF nPos > 0
      DbeInfo(nType, aDbe[nPos][3][1], VAL(aRet[1]) )
      DbeInfo(nType, aDbe[nPos][3][2], VAL(aRet[2]) )
   ENDIF

   nType := COMPONENT_ORDER
   cSet := DbeInfo(nType, DBE_NAME)
   nPos := ASCAN(aDbe, {|x| x[1] == cSet .AND. x[2] == nType })
   IF nPos > 0
      DbeInfo(nType, aDbe[nPos][3][1], VAL(aRet[3]) )
      DbeInfo(nType, aDbe[nPos][3][2], VAL(aRet[4]) )
   ENDIF

RETURN aRet


