//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfWin.ch"
#include "dfSet.ch"
STATIC aObject := {}
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbAddObj( oTbr ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfUserLog( "(" +ALLTRIM(m->EnvID) +") OPEN" )
IF (oTbr==NIL .OR. oTbr:W_OBJ2ADD)
   IF ATAIL(aObject) # NIL
      DFDISPBEGIN()
      tbOff( ATAIL(aObject) )             // OFF
      IF LEN(aObject)==1               .AND. ;
         dfSet(AI_MENUSCREENFILL )#NIL .AND. ;
         dfSet(AI_MENUSCREENCOLOR)#NIL
         dbScrSav("___OBJ___")
         dfFill( 0, 0, MAXROW()-1, MAXCOL(),;
                  dfSet(AI_MENUSCREENFILL ),;
                  dfSet(AI_MENUSCREENCOLOR),;
                  dfSet(AI_MENUSCREENCOLOR) )
      ENDIF
      DFDISPEND()
   ENDIF
   AADD( aObject, oTbr )                  // ADD
   IF oTbr#NIL
      oTbr:W_OBJ2ADD := .F.
   ENDIF
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbDelObj( oTbr ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF LEN(aObject) > 1                   // Se ho oggetti
   IF aObject[LEN(aObject)-1]#NIL     // metto in on
      DFDISPBEGIN()
      IF LEN(aObject)-1==1             .AND. ;
         dfSet(AI_MENUSCREENFILL )#NIL .AND. ;
         dfSet(AI_MENUSCREENCOLOR)#NIL
         dbScrRes("___OBJ___")
      ENDIF
      tbOn( aObject[LEN(aObject)-1] )
      DFDISPEND()
   ENDIF
ENDIF
ASIZE(aObject,LEN(aObject)-1)         // elimino
dfUserLog( "(" +ALLTRIM(m->EnvID) +") CLOSE" )
RETURN

//* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//PROCEDURE dfAddObj()
//* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//tbAddObj()
//RETURN

//* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//PROCEDURE dfDelObj()
//* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//tbDelObj()
//RETURN
