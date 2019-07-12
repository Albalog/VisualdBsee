/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Appevent.ch"
#include "Common.ch"
#include "Font.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "dfXRes.ch"
#include "dfMsg.ch"

#include "dfSwHouse.ch"

#define  BITMAP_MAX_WIDTH          215
#define  BITMAP_MAX_HEIGHT         240



PROCEDURE __Author() 

   AboutBox( APPNAME+" Version Information " , ; // title
             APPNAME , ; // program + modalit…
             "Program Generated with "+ APPNAME        + Chr(13) + ;
             "Win 32 Form Designer and Database"       + Chr(13) + ;
             "development for 32bit operating systems" + Chr(13) + Chr(13) +;
             INFO_SWHOUSE                              + Chr(13) + ;
             "Copyright (c) 1999-2012"                 + Chr(13) + ;
             "Authors:                          "      + Chr(13) + ;
             "                Simone Degl'Innocenti"   + Chr(13) + ;
             "   Luca Caputo"                , ; 
             ;//Fine prima parte
             "Library Version: " +dfNumVer()+ " "+dfStdMsg(MSG_LANGUAGE)+ Chr(13) + ;
             "Library Date: " +dfLibDate()         + Chr(13) + ;
             VERSION() +IF( dfIsDebug(), " (DEBUG)", "" )+IF( dBsee4AXS()," ADS ", "" )+ Chr(13) + ;
             "CPU : "    +dfCpuID()               + Chr(13) + ;
             "Mem : "    +PADL(MEMORY(0),5) +"Kb" + Chr(13) + ; 
             OS()          ,;
             "http://www.VisualdBsee.com"               ,;                 
             DFAPPLICATION_LOGO) 

RETURN 


STATIC PROCEDURE AboutBox( cTitle, cProgram, cVersion, cMisc,cWww,  nBitmap,lTemp)
   LOCAL nEvent, mp1, mp2, oXbp, nDX, lExit := .F.
   LOCAL oDlg, drawingArea, oLogo, oBtn, aPos, aSize, oFocus
   LOCAL nOff
   DEFAULT cTitle TO "" , ;
         cProgram TO "" , ;
         cVersion TO "" , ;
            cMisc TO "" , ;
            lTemp TO .F.

   aSize := { 410, 315 }
   nOff  := 160
   aPos  := dfCenterPos( aSize, AppDesktop():currentSize() )

   oDlg := XbpDialog():new( AppDesktop(), SetAppWindow(), aPos, aSize, , .F.)
   oDlg:taskList := .F.
   oDlg:minButton:= .F.
   oDlg:maxButton:= .F.
   oDlg:border   := XBPDLG_DLGBORDER
   oDlg:title    := cTitle
   oDlg:create()
   oDlg:Close    := { || lExit := .T. }

   drawingArea := oDlg:drawingArea
   drawingArea:setFontCompoundName( FONT_HELV_SMALL )

   oXbp         := XbpStatic():new( drawingArea, , {16+nOff,264}, {216,24} )
   oXbp:caption := cProgram
   oXbp:setFontCompoundName( FONT_HELV_MEDIUM + FONT_STYLE_BOLD )
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_CENTER
   oXbp:create()

   oXbp := XbpStatic():new( drawingArea, , {16+nOff,137}, {216,126} )
   oXbp:caption := cVersion
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK+XBPSTATIC_TEXT_TOP+XBPSTATIC_TEXT_CENTER
   oXbp:create()

   oXbp := XbpStatic():new( drawingArea, , {16+nOff,135}, {216,2} )
   oXbp:type := XBPSTATIC_TYPE_RAISEDLINE
   oXbp:create()

   oXbp := XbpStatic():new( drawingArea, , {16+nOff,45}, {216,85} )
   oXbp:caption := cMisc
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK+XBPSTATIC_TEXT_TOP+XBPSTATIC_TEXT_CENTER
   oXbp:create()

   oXbp := XbpStatic():new( drawingArea, , {12,45}, {240,25} )
   oXbp:caption := cWww
   oXbp:options := XBPSTATIC_TEXT_LEFT
   oXbp:setFontCompoundName( FONT_HELV_SMALL+FONT_STYLE_BOLD )
   oXbp:create()

  /*
   * The pushbutton reacts to the Return and Esc keys due to
   * the :keyboard code block
   */
   oBtn := XbpPushButton():new( drawingArea, , {86+nOff,12}, {67,24} )
   oBtn:caption  := "Ok"
   oBtn:create()
   oBtn:activate := {|| lExit := .T. }
   oBtn:keyboard := {|nKey| IIF( nKey == xbeK_RETURN .OR. nKey == xbeK_ESC, ;
                                 lExit := .T., NIL ) }
   IF lTemp
      oBtn:Hide()
   ENDIF
   IF nBitmap <> NIL
      oXbp      := XbpStatic():new( drawingArea, ,{10,70}   )
      oXbp:type := XBPSTATIC_TYPE_RAISEDBOX
      oXbp:create()

      oLogo          := XbpStatic():new( oXbp, , {4,4}  )
      oLogo:type     := XBPSTATIC_TYPE_BITMAP
      oLogo:caption  := nBitmap
      oLogo:autoSize := .T.
      oLogo:create()

     /*
      * Size of the bitmap is limited
      */
      aSize    := oLogo:currentSize()
      aSize[1] := Min( BITMAP_MAX_WIDTH , aSize[1] )
      aSize[2] := Min( BITMAP_MAX_HEIGHT, aSize[2] )

      //ChangePos( oDlg, { -nDX / 2, 0 } )

      aSize[1] += 8
      aSize[2] += 8
      oXbp:setSize( aSize )
   ENDIF

   oDlg:show()
   oDlg:setModalState( XBP_DISP_APPMODAL )

   oFocus := SetAppFocus( oBtn )

   IF lTemp
      Sleep(300)
   ELSE
      DO WHILE ! lExit
         nEvent := dfAppEvent( @mp1, @mp2, @oXbp )
         oXbp:handleEvent( nEvent, mp1, mp2 )
      ENDDO
   ENDIF

   oDlg:setModalState( XBP_DISP_MODELESS )
   oDlg:destroy()
   SetAppFocus( oFocus )

RETURN



/*
//Non Š pi— usata
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE __Author() //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC nCall := 0
MEMVAR __RealTime
LOCAL aAuthor := {}, nTop := INT(MAXROW()/2), bRealTime, cLine
nCall++
IF nCall == 1
   dfPushCursor()
   dfPushAct()
   tbAddObj()
   SET CURSOR OFF

   IF TYPE( "__RealTime" ) # "U"
      bRealTime  := __RealTime
      __RealTime := NIL
   ENDIF


   AADD( aAuthor, VERSION() )
   AADD( aAuthor, "" )
   AADD( aAuthor, "CPU : "      +dfCpuID()               +;
                  "  Dos : "    +dfDosVer()              +;
                  "  Mem : "    +PADL(MEMORY(0),5) +"Kb" +;
                  "  Handle : " +PADL(dfFreeHnd(),3)     +;
                  "  DGROUP : " +PADL(dfDSAvail(),5)      )
   IF dfIsWin()
      cLine := "Windows version : " +dfWinVer()
      IF dfIsWinClp()
         cLine += "  Clipboard version : " +dfWinVer()
      ENDIF
      AADD( aAuthor, cLine )
   ENDIF
   AADD( aAuthor, "" )
   AADD( aAuthor, "Application Stacks" )
   AADD( aAuthor, "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" )
   AADD( aAuthor, "Action : "    +PADL(dfPushActNum(),2) +;
                  "  Palette : " +PADL(dfPushPalNum(),2) +;
                  "  Cursor : "  +PADL(dfPushCurNum(),2) +;
                  "  Screen : "  +PADL(dbScrNum(),2)      )
   AADD( aAuthor, "Record : "    +PADL(dfPushRecNum(),2) +;
                  "  Areas   : " +PADL(dfPushAreNum(),2) +;
                  "  Mouse  : "  +PADL(M_CURNUM()    ,2)  )
   AADD( aAuthor, "" )
   AADD( aAuthor, "^ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³ Program Generated with ³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" )
   AADD( aAuthor, "^³Û   Û   ³ ÚÄÄ¿                    ÚÄÄÄÄÄÄÄÄÄ> Authors <ÄÄÄÄÄÄÄÄ¿ ³" )
   AADD( aAuthor, "^³ÛÛ ÛÛ   ³ ³  ³  ÚÄÄÄÄ ÚÄÄÄÄ ÚÄÄÄÄ ³ Simone Degl'Innocenti      ³ ³" )
   AADD( aAuthor, "^³ Û Û ÚÄÄ´ ÃÄÄÁ¿ ÀÄÄÄ¿ ÃÄÄ   ÃÄÄ   ³ Luca Caputo                ³ ³" )
   AADD( aAuthor, "^³  Û  ÀÄÄÙ ÀÄÄÄÙ ÄÄÄÄÙ ÀÄÄÄÄ ÀÄÄÄÄ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ³" )
   AADD( aAuthor, "^³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   http://www.VisualdBsee.com      ³" )
   //AADD( aAuthor, "^ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ (C) Isa Italian Software Agency ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ" )
   AADD( aAuthor, "^ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   Albalog s.r.l.   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ" )
   AADD( aAuthor, "" )                
   #ifdef __XPP__
//      AADD( aAuthor, "^Alaska version by Matteo Baccan and Simone Degl'Innocenti" )
//      AADD( aAuthor, "" )
   #endif
   AADD( aAuthor, "^                   Press Any Key to Continue ...                   " )
   nTop -= INT((LEN(aAuthor)+2)/2)
   dbFrameOn( nTop,2, nTop+LEN(aAuthor)+1, MAXCOL()-3, dfVer() )
   FOR nTop := 1 TO LEN(aAuthor)
      dbFrameDis( aAuthor[nTop] )
      dfINKEY(0.01) //FW
   NEXT

   dbInk()

   dbFrameOff()
   IF bRealTime#NIL
      __RealTime := bRealTime
   ENDIF
   tbDelObj()
   dfPopAct()
   dfPopCursor()
ELSE
   dbSouErr()
ENDIF
nCall--

RETURN
*/