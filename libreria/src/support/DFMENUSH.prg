#include "dfMenu.ch"
#include "common.ch"

FUNCTION dfMenuSCut(aMenuArr, cAct)
   LOCAL cShCut := ""
   LOCAL aLabel := dfMenuFind(aMenuArr, cAct)

   IF ! EMPTY(aLabel)
      cShCut := aLabel[MNI_CHILD]
   ENDIF

RETURN cShCut

FUNCTION dfMenuFind(aMenuArr, cAct, lChk)
   LOCAL aLabel := NIL

   BEGIN SEQUENCE

      DEFAULT lChk TO .T.

      // Il BREAK Š dentro la FindSCut!!!!
      FindSCut(aMenuArr, cAct, @aLabel, lChk)

   END SEQUENCE

RETURN aLabel

STATIC PROCEDURE FindSCut(aMenuArr, cAct, aLabel, lChk)
   LOCAL nInd := 0
   LOCAL lFound := .F.
   //LOCAL nAttivo

   FOR nInd := 1 TO LEN(aMenuArr)

      IF cAct $ aMenuArr[nInd][MNI_ACTION]

         IF lChk
            IF dfMenuItemIsActive(aMenuArr[nInd])
               aLabel := aMenuArr[nInd]
            ENDIF
            // nAttivo := EVAL(aMenuArr[nInd][MNI_BSECURITY])
            // IF nAttivo == MN_ON .OR. nAttivo == MN_SECRET
            //    aLabel := aMenuArr[nInd]
            // ENDIF
         ELSE
            aLabel := aMenuArr[nInd]
         ENDIF
         BREAK

      ELSEIF ! EMPTY(aMenuArr[nInd][MNI_ARRAY])
         FindSCut(aMenuArr[nInd][MNI_ARRAY], cAct, @aLabel, lChk)

      ENDIF
   NEXT
RETURN


