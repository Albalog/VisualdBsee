//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "INKEY.CH"
#include "dfwin.ch"
#include "dfStd.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbRight( oTbr ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
tbGenMov( oTbr, K_RIGHT )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbLeft( oTbr ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
tbGenMov( oTbr, K_LEFT )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE tbGenMov( oTbr, nMov )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lStab
DFDISPBEGIN()
   DO CASE
      CASE nMov==K_LEFT   ;IF(lStab:=oTbr:COLPOS==1            ,,oTbr:LEFT())
      CASE nMov==K_RIGHT  ;IF(lStab:=oTbr:COLPOS==oTbr:COLCOUNT,,oTbr:RIGHT())
   ENDCASE
   IF !lStab .OR. !oTbr:STABLE
      tbStab( oTbr )
   ENDIF
  #ifndef __XPP__
   tbSayOpt( oTbr, W_MM_HSCROLLBAR )
  #endif
DFDISPEND()
RETURN
