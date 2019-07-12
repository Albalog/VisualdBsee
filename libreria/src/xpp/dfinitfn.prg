//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include "common.ch"
#include "nls.ch"
#include "font.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfInitFont()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   IF EMPTY(dfSet("XbaseApplicationFont"))
      dfSet("XbaseApplicationFont", FONT_DEFPROP_SMALL)
   ENDIF
   IF EMPTY(dfSet("XbaseAlertFont"))
      dfSet("XbaseAlertFont", FONT_DEFPROP_SMALL)
   ENDIF
   IF EMPTY(dfSet("XbaseBrowseFont"))
      dfSet("XbaseBrowseFont", dfSet("XbaseApplicationFont"))
   ENDIF
RETURN .T.
