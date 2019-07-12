/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfOrdList()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aIndex := {}, nIndex := 0, cName
WHILE !EMPTY(cName:=ORDBAGNAME_XPP(++nIndex)); AADD(aIndex,cName); END
RETURN aIndex

#ifdef __XPP__
   #include "dmlb.ch"
   #include "dbstruct.ch"

   // FIX per dfOrdList che in xbase restituisce il nome dell'indice
   // senza il path

   FUNCTION dfOrdList_xpp()
      LOCAL aIndex := {}, nIndex := 0, cName
      WHILE !EMPTY(cName:=_ORDBAGNAME(++nIndex)); AADD(aIndex,cName); END
   RETURN aIndex

   // Fix per OrdBagName che non ritorna il PATH
   // ma solo il nome dell'indice

   STATIC FUNCTION _OrdBagName(xName)
      #ifdef _XBASE17_
         LOCAL cName := OrdBagName_xpp(xName, DMLB_QUALIFIED_FILENAME )
      #else

         LOCAL cName := OrdBagName_xpp(xName)
         LOCAL aPath

         IF ! EMPTY(cName)

            // Trovo il path dell'indice
            aPath := dfFNameSplit(cName)

            // Se vuoto aggiungo quello del DBF,
            // presuppongo che l'indice sia nella stessa cartella del DBF

            IF EMPTY(aPath[1]) .AND. EMPTY(aPath[2])
               // Trovo il path del DBF
               aPath := dfFNameSplit(DbInfo(DBO_FILENAME))
               cName := aPath[1]+aPath[2]+cName
            ENDIF
         ENDIF
      #endif
   RETURN cName

#endif