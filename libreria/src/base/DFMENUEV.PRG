//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' per Menu
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfMenu.ch"
#include "dfSet.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfMenuEval( aMenu )  // Eval Menu CodeBlock
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nMenu, nLen
LOCAL cLAB

nLen := LEN(aMenu)
FOR nMenu := 1 TO nLen
   //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012 
   cLAB   := aMenu[nMenu][MNI_LABEL]
   IF VALTYPE(cLAB) == "B"
      cLAB := EVAL(cLAB)
   ENDIF 
   //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012 
   //aMenu[nMenu][MNI_SECURITY] := EVAL( aMenu[nMenu][MNI_BSECURITY], aMenu[nMenu][MNI_CHILD], aMenu[nMenu][MNI_LABEL],aMenu[nMenu][MNI_ID])
   aMenu[nMenu][MNI_SECURITY] := EVAL( aMenu[nMenu][MNI_BSECURITY], aMenu[nMenu][MNI_CHILD], cLab,aMenu[nMenu][MNI_ID])

   IF dfSet( AI_HIDEMENUITEM )
      IF !EMPTY( aMenu[nMenu][MNI_ACTION] )
         IF !dbActState( aMenu[nMenu][MNI_ACTION] )
            aMenu[nMenu][MNI_SECURITY] := MN_HIDDEN
         ENDIF
      ENDIF
   ENDIF

   IF !EMPTY( aMenu[nMenu][MNI_ARRAY] )
      dfMenuEval( aMenu[nMenu][MNI_ARRAY] )
   ENDIF
NEXT

RETURN
