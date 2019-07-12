//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfSet.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbSayOpt( oTbr, nRefresh )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC cEsc, cMin, cMax, cSiz
LOCAL nOpt := 1, nActual, nTop, nLeft, nBottom, nRight, cColor, nGap

IF NEXTKEY()#LASTKEY() .OR. LASTKEY()==0 // A volte genera un GPF
   nTop    := TBREALTOP( oTbr )
   nLeft   := TBREALLEFT( oTbr )
   nBottom := TBREALBOTTOM( oTbr )
   nRight  := TBREALRIGHT( oTbr )
   cColor  := oTbr:W_COLORARRAY[AC_FRM_OPTION]
   nGap    := IF( dfSet( AI_WIN95INTERFACE ) , 2, 0 )

   DEFAULT nRefresh TO 255                  // Comprende tutte le opzioni
   IF cEsc==NIL
      cEsc := dfFontStr( "SystemMenuIcon" ) // ESC
      cMin := dfFontStr( "minimizeicon"   ) // MINIMIZE
      cMax := dfFontStr( "maximizeicon"   ) // MAXIMIZE
      cSiz := dfFontStr( "sizingicon"     ) // SIZE
   ENDIF

   M_CurOff()
   FOR nOpt := 0 TO 7
      nActual := 2^nOpt
      IF dfAnd( nRefresh, nActual ) !=0 .AND.;  // E' da refresshare
         TBISOPT( oTbr, nActual )               // E' previsto
                                                // nell'oggetto
         DO CASE
            CASE nActual==W_MM_VSCROLLBAR
                 tbVerBar( oTbr, cColor )

            CASE nActual==W_MM_HSCROLLBAR
                 IF oTbr:WOBJ_TYPE==W_OBJ_FRM
                    tbDisPage( oTbr, cColor )
                 ELSE
                    tbHorBar(  oTbr, cColor )
                 ENDIF

            CASE nActual==W_MM_ESCAPE
                 @ nTop   , nLeft          SAY cEsc COLOR cColor
                 IF nGap>0
                    @ nTop   , nRight-1       SAY cEsc COLOR cColor
                 ENDIF

            CASE nActual==W_MM_MINIMIZE
                 @ nTop   , nRight-3-nGap  SAY cMin COLOR cColor

            CASE nActual==W_MM_MAXIMIZE
                 @ nTop   , nRight-1-nGap  SAY cMax COLOR cColor

            CASE nActual==W_MM_SIZE
                 @ nBottom, nRight-1       SAY cSiz COLOR cColor

         ENDCASE
      ENDIF
   NEXT
   M_CurOn()
ENDIF
RETURN
