//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' per Menu
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfMenu.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfMenuAct( aMenu, cAct )  // Menu Search
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLab, cLab := "", c2Scan := UPPER(dfHot() +RIGHT(cAct,1))
IF LEFT(cAct,2) == "A_"
   FOR nLab := 1 TO LEN(aMenu)
     //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012 
      IF aMenu[nLab][MNI_SECURITY]        == MN_ON .AND. ;
         VALTYPE(aMenu[nLab][MNI_LABEL])  == "C"   .AND. ;
         c2Scan $ UPPER(aMenu[nLab][MNI_LABEL])
         cLab   := aMenu[nLab][MNI_CHILD]
         EXIT
      ENDIF
   NEXT
ENDIF
RETURN cLab
