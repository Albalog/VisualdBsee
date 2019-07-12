//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfWin.ch"
#include "dfset.ch"

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbOn( oTbr )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
tbOnOff( oTbr, .T. )
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbOff( oTbr )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
tbOnOff( oTbr, .F. )
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
STATIC PROCEDURE tbOnOff( oTbr, lOn )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nLeft, nLen, cTitle

IF !EMPTY(oTbr:W_TITLE)
   nLeft  := TBREALLEFT( oTbr )                // recupero 2 char
   cTitle := dbMMrg( oTbr:W_TITLE )
   IF TBISOPT( oTbr, W_MM_ESCAPE )
      nLeft += 2
   ELSE
      IF oTbr:WOBJ_TYPE == W_OBJ_ARRAYBOX  .OR. ;
         oTbr:WOBJ_TYPE == W_OBJ_BROWSEBOX
         nLeft++
      ENDIF
   ENDIF

   // recupero fino a 2 char
   nLen := TBREALRIGHT( oTbr ) -nLeft -3 -IF( dfSet( AI_WIN95INTERFACE ) , 2, 0 )
   IF !TBISOPT( oTbr, W_MM_MINIMIZE )
      nLen += 2
      IF !TBISOPT( oTbr, W_MM_MAXIMIZE )
         nLen += 2
      ENDIF
   ENDIF

   M_CurOff()
   IF oTbr:WOBJ_TYPE == W_OBJ_ARRAYBOX  .OR. ; // allineo
      oTbr:WOBJ_TYPE == W_OBJ_BROWSEBOX

      nLen := MIN( nLen, LEN(cTitle) )
      IF lOn
         dfSay( TBREALTOP( oTbr ), nLeft         ,;
                PADR( cTitle, nLen )             ,;
                oTbr:W_COLORARRAY[AC_LSB_HILITE]  )
      ELSE
         dfSay( TBREALTOP( oTbr ), nLeft         ,;
                PADR( cTitle, nLen )             ,;
                oTbr:W_COLORARRAY[AC_LSB_PROMPT] ,;
                oTbr:W_COLORARRAY[AC_LSB_HOTKEY]  )
      ENDIF
   ELSE                                        // centro
      IF lOn
         @ TBREALTOP( oTbr ), nLeft SAY   PADC( cTitle, nLen ) ;
                                    COLOR oTbr:W_COLORARRAY[AC_FRM_HEADER]
      ELSE
         @ TBREALTOP( oTbr ), nLeft SAY   PADC( cTitle, nLen ) ;
                                    COLOR dfSet(AI_OBJECTOFFCOLOR)
      ENDIF
   ENDIF
   M_CurOn()
ENDIF

IF lOn
   tbSayOpt( oTbr )
ENDIF

RETURN
