#include "common.ch"

// simone 20/11/09 
// gestione multithread per ora disabilitato
//#define _MULTITHREAD_

FUNCTION S2FormCurr( oXbp, lSet )
   STATIC oXb := NIL
   LOCAL oRet := oXb

/* simone 14/6/05 implementazione per FORM mdi (multithread)
   IF dfSet("XbaseMDIEnabled") == "YES"
      oRet := VDBFindDlgFocus()
      IF EMPTY(oRet) 
         oRet := oXb
      ENDIF
   ENDIF
*/
#ifdef _MULTITHREAD_
   STATIC aTh:={}
   LOCAL oC := ThreadObject()
   LOCAL nTh 

   IF .T. //! dfThreadIsMain() 
      nTh:= ASCAN(aTh, {|x|x[1]==oC})
      oRet := IIF(nTh==0, NIL, aTh[nTh][2])
      IF oXbp != NIL .OR. lSet != NIL
         IF nTh == 0
            AADD(aTh, {oC, oXbp})
         ELSE
            aTh[nTh][2]:=oXbp
         ENDIF
      ENDIF
      RETURN oRet
   ENDIF

#endif

   IF oXbp != NIL .OR. lSet != NIL
      oXb := oXbp

      IF oXbp != NIL .AND. IsMemberVar(oXbp, "oMenuBar")
         S2TreeMenuSet( oXbp:oMenuBar )
      ELSE
         S2TreeMenuSet( NIL )
      ENDIF

   ENDIF
RETURN oRet


/*
// Torna oggetto di classe xbpdialog che ha il focus
STATIC FUNCTION VDBFindDlgFocus(oXbp)
   LOCAL oRet := NIL
   LOCAL aLoop := {}    // Serve per evitare una eventuale ricorsione
   LOCAL nLoop := 2000  // Serve per evitare una eventuale ricorsione

   DEFAULT oXbp TO FixSetAppFocus()

   DO WHILE .T.

      IF EMPTY(oXbp) .OR. ;
         ASCAN(aLoop, oXbp) != 0 .OR. --nLoop < 0
         EXIT
      ENDIF

      IF S2XbpIsValid(oXbp) .AND. ;
         oXbp:setParent() == AppDesktop()
//         oXbp:isDerivedFrom("XbpDialog")

         oRet := oXbp
         EXIT
      ENDIF

      AADD(aLoop, oXbp)

      oXbp := oXbp:setParent()

   ENDDO

RETURN oRet
*/