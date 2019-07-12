/*******************************************************************************
Project     : dBsee 4.3
Description : Browse Search
Programmer  : Baccan Matteo
*******************************************************************************/
#include "dfWin.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbKey( oTbr, oMaster, lLockIndex )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF !EMPTY(oTbr:W_ALIAS)
   (oTbr:W_ALIAS)->(ddKey( TBREALTOP( oTbr )+1  ,;
                           TBREALLEFT( oTbr )+1 ,;
                           oTbr:W_ORDER         ,;
                           oTbr:W_KEY           ,;
                           oTbr:W_FILTER        ,;
                           oTbr:W_BREAK         ,;
                           NIL                  ,;
                           lLockIndex           ))

   IF oTbr:W_ORDER      # (oTbr:W_ALIAS)->(INDEXORD()) .OR.;
      oTbr:W_CURRENTREC # (oTbr:W_ALIAS)->(RECNO())

      // Sulle listbox con chiave NON cambio l'indice, ma anzi lo risincronizzo
      IF !( (oTbr:WOBJ_TYPE==W_OBJ_BROWSEBOX .OR. oTbr:WOBJ_TYPE==W_OBJ_BRW) .AND.;
           oTbr:W_KEY!=NIL .AND. EVAL(oTbr:W_KEY)!=NIL )
         oTbr:W_ORDER := (oTbr:W_ALIAS)->(INDEXORD())
      ELSE
         (oTbr:W_ALIAS)->(DBSETORDER( oTbr:W_ORDER ))
      ENDIF

      oTbr:W_CURRENTREC := (oTbr:W_ALIAS)->(RECNO())
      IF oTbr:WOBJ_TYPE==W_OBJ_BRW       .OR. ;
         oTbr:WOBJ_TYPE==W_OBJ_BROWSEBOX
         tbCONFIGURE(oTbr)
         tbRtr( oTbr, oMaster )
      ENDIF
   ENDIF
ENDIF
RETURN
