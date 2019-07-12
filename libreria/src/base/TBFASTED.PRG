/*******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "dfWin.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbFastEdit( oTbr, oMaster )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nCol := oTbr:COLPOS
IF tbIsFast( oTbr ) .AND. tbIsMod( oTbr )
   KEYBOARD CHR(M->a)
   IF tbModCel( oTbr )
      DFDISPBEGIN()
      IF oTbr:COLPOS<oTbr:COLCOUNT
         oTbr:RIGHT()
         oTbr:FORCESTABLE()
         oTbr:HILITE()
         WHILE oTbr:COLPOS<oTbr:COLCOUNT .AND. !tbIsMod( oTbr )
            oTbr:RIGHT()
            oTbr:FORCESTABLE()
            oTbr:HILITE()
         END

         IF !tbIsMod( oTbr )
            oTbr:COLPOS := 1
         ENDIF
      ELSE
         oTbr:COLPOS := 1
      ENDIF
      oTbr:FORCESTABLE()
      oTbr:HILITE()

      WHILE oTbr:COLPOS<oTbr:COLCOUNT .AND. !tbIsMod( oTbr )
         oTbr:RIGHT()
         oTbr:FORCESTABLE()
         oTbr:HILITE()
      END
      IF !tbIsMod( oTbr )
         oTbr:COLPOS := nCol
         oTbr:FORCESTABLE()
         oTbr:HILITE()
      ENDIF
      tbStab( oTbr, .T. )
      tbRtr( oTbr, oMaster )
      DFDISPEND()
   ENDIF
ENDIF

RETURN
