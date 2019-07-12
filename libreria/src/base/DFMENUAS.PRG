//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' per Menu
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfMenu.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfMenuActStr( aMenu )  // Menu Valid Action Search
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLab, cLab := ""
FOR nLab := 1 TO LEN(aMenu)
   IF EMPTY(aMenu[nLab][MNI_ARRAY])            .AND.;
      (aMenu[nLab][MNI_SECURITY] == MN_ON .OR. ;      // e' attivato
       aMenu[nLab][MNI_SECURITY] == MN_SECRET ).AND.;
      EVAL(aMenu[nLab][MNI_BRUNTIME])                 // lo e' anche a runtime

      IF !EMPTY(aMenu[nLab][MNI_ACTION])
         cLab += "-" +aMenu[nLab][MNI_ACTION]
      ENDIF
   ELSEIF !EMPTY(aMenu[nLab][MNI_ARRAY])
      cLab += dfMenuActStr(aMenu[nLab][MNI_ARRAY])
   ENDIF
NEXT
RETURN cLab
