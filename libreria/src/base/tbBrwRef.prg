//*****************************************************************************
//Progetto       : dBsee for Xbase++
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Simone Degl'Innocenti
//*****************************************************************************

#include "common.ch"

// Esegue il refresh di un browse anche se ha ottimizzazione
// Simone 15/04/03 GERR 3767

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION tbBrwRefresh(oLsb, lTop, lStab, lOptim)
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北

   DEFAULT lTop   TO .F.
   DEFAULT lStab  TO ! lTop
   DEFAULT lOptim TO .T.

  #ifdef __XPP__
   IF lOptim .AND. isMethod(oLsb, "OptSet") 
      // Forza nuovamente l'ottimizzazione 
      oLsb:OptSet()
   ENDIF
  #endif

   IF lTop
      tbTop(oLsb)
   ELSE
      tbSetKey(oLsb, oLsb:W_ORDER, oLsb:W_KEY, oLsb:W_FILTER, oLsb:W_BREAK)
   ENDIF
   IF lStab
      tbStab(oLsb,  .T. )
   ENDIF
RETURN .T.