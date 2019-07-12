//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per ARRAY
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfwin.ch"
//#include "class.ch"

////////////////////////////////////////////////////////////////////////////////////////////
//Mantis 1651
//09/11/2007 Corretto Problema su Array vuoto in presenza di listbox con Collonne con bitmap
//oTbr    -> Oggetto Listbox su Array
//aSource -> Array Dati Listbox
//nEle    -> Elemento Array Dati Listbox  
//nCol    -> Numero Colonna Listbox
////////////////////////////////////////////////////////////////////////////////////////////

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbGetArr( oTbr, aSource, nEle, nCol  )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL uVal := "", nPos := oTbr:W_CURRENTREC
LOCAL xRecord
LOCAL oCol

   ///////////////////////////////////////////////////////////////////////////////
   IF EMPTY(aSource) .AND. VALTYPE(nCOL) == "N"
      //Non Š possiible usare  questa soluzione perche con il cursore riga non funziona!
      //nCOL := oTbr:ColPos 

      uVal := _GetDefault(nCOL, oTbr)

      RETURN uVal
          
   ENDIF 

   ///////////////////////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////
   //Luca 01/07/2014 
   //Mantis 2248
   IF VALTYPE(aSource) == "A" 
      oTbr:W_AI_LENGHT := len(aSource)
   ENDIF 
   ///////////////////////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////

   IF nEle==NIL
      IF LEN(aSource)>=nPos .AND. nPos#0
         uVal := aSource[nPos]
      ELSE
         uVal := _GetDefault(nCOL, oTbr)
      ENDIF
   ELSE
      IF LEN(aSource)>=nPos .AND. nPos#0
         //aSource := aSource[nPos]
         xRecord := aSource[nPos]
         /////////////////////////////////////////////////////
         //Modifica per gestione Oggetti di classe per popolare listbox su array
         //IF LEN(aSource)>=nEle
         //   uVal := aSource[nEle]
         //ENDIF
         /////////////////////////////////////////////////////
         IF Valtype(xRecord) == "O"      
            uVal := _MemberValue(xRecord, nEle, oTbr, nCol) 
         ELSEIF LEN(xRecord) >= nEle
            uVal := xRecord[nEle]
         ELSE
             uVal := _GetDefault(nCOL, oTbr)
         ENDIF


      ELSE
         uVal := _GetDefault(nCOL, oTbr)
      ENDIF
   ENDIF
RETURN uVal


STATIC FUNCTION _GetDefault(nCOL, oTbr)
   LOCAL xRet := ""
   LOCAL oCol

   IF VALTYPE(nCOL) != "N"
      RETURN xRet
   ENDIF 

   IF nCOL >0 
      oCol := oTbr:getColumn(nCOL)
      IF  !EMPTY(oCol)
          DO CASE 
             CASE oCol:Type == XBPCOL_TYPE_TEXT   
                  xRet := ""
             CASE oCol:Type == XBPCOL_TYPE_BITMAP       .OR.;
                  oCol:Type == XBPCOL_TYPE_ICON         .OR.;
                  oCol:Type == XBPCOL_TYPE_SYSICON      .OR.;
                  oCol:Type == XBPCOL_TYPE_FILEICON     .OR.;
                  oCol:Type == XBPCOL_TYPE_FILEMINIICON 
                  xRet := 0

             OTHERWISE
                  xRet := ""
          ENDCASE 
      ENDIF 
   ENDIF 
RETURN xRet

STATIC FUNCTION _MemberValue(oClass, cEle, oTbr, nCol)
  LOCAL nPos  := 0
  LOCAL aVars := NIL
  LOCAL xRet  := _GetDefault(oTbr, nCol)

  IF VALTYPE(oClass)  <> "O"  
     RETURN xRet
  ENDIF 

  IF VALTYPE(cEle)    <> "C"  
     RETURN xRet
  ENDIF 
  cEle  := Upper(alltrim(cEle))

  IF IsMemberVar( oClass, cEle)
     xRet := oClass:&cEle 
  ENDIF 

RETURN xRet 


