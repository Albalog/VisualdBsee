//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' per Menu
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfMenu.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfMenuScan( aMenu, nRow, nCol )  // Menu Search
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLab, cLab := ""
FOR nLab := 1 TO LEN(aMenu)
   IF nRow == aMenu[nLab][MNI_TOP]   .AND. ;
      nCol >= aMenu[nLab][MNI_LEFT]  .AND. ;
      nCol <= aMenu[nLab][MNI_RIGHT]
      cLab := aMenu[nLab][MNI_CHILD]
      EXIT
   ENDIF
NEXT
RETURN cLab
