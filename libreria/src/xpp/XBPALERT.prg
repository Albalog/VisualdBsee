//////////////////////////////////////////////////////////////////////
//
//  ALERTBOX.PRG
//
//  Copyright:
//      Alaska Software Inc., (c) 1997. All rights reserved.
//
//  Contents:
//      Function AlertBox()
//
//      This function can be used to replace MsgBox() and ConfirmBox().
//      It works similar to the text mode Alert() function but only for
//      GUI applications. The AlertBox() window is modal.
//
//  Syntax:
//      AlertBox( [<oOwner>] , [<cText>]   , ;
//                [<aButton>], [<xSysIcon>], ;
//                [<cTitle>]                 ) -> nSelectedButton
//
//
//  Parameters:
//      <oOwner>   - Is the window on which the AlertBox() is centered.
//                   It defaults to SetAppWindow()
//
//      <cText>    - Message text like in Alert()
//                   Semicolon ; is used for line break
//
//      <aButton>  - Array with strings for pushbutton captions
//                   It defaults to { "Ok" }
//
//      <xSysIcon> - #define constant XBPSTATIC_SYSICON_* to display an icon
//                   oppure array di 2/3 elementi
//                   xSysIcon[1] = id immagine
//                   xSysIcon[2] = type immagine (ICON/BITMAP)
//                   xSysIcon[3] = (opzionale) NIL per autosize oppure array dimensioni 
//
//      <cTitle>   - Title for Alert box
//
//
//  Return:
//      The function returns the ordinal number of the pressed pushbutton
//      or zero if no selection is made (ESC key or Close window)
//
//
//  Remarks:
//      If no icon is displayed, the message text is centered in the alert
//      box. If an icon is displayed, the text is left aligned next to the
//      icon. Pushbuttons are centered below the message text.
//
//////////////////////////////////////////////////////////////////////

#include "Appevent.ch"
#include "Common.ch"
#include "Font.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "dfXBase.ch"
#include "dfCtrl.ch"

// simone 6/12/07 
// mantis 0001687: implementare visualizzazione HTML
//
// inizio di implementazione testo HTML 
// quando il caption Š tipo "[htmltext:ciao <b>grassetto</b>]"
// solo con Xbase 1.90
// per ora disattivato perche non completo 
// vedi anche S2StaticX() e S2HTMLTextParse()
//
// #define USE_HTMLTEXT

// Simone 27/10/05
// GERR 4538: errori grastringat          
// usa STATIC per display del testo
#define USE_STATIC

//#define CRLF (CHR(13)+CHR(10))
#define LINE_BREAK "//"

/*
 * Max. number of pushbuttons displayed in the Alert box
 */
//#define  MAX_BUTTONS         4
#define  MAX_BUTTONS         7


#define  BUTTON_FONT         (IIF(dfSet("XbaseAlertButtonFont")==NIL, FONT_DEFPROP_SMALL, dfFontCompoundNameNormalize(dfSet("XbaseAlertButtonFont")))) // FONT_HELV_SMALL
#define  TEXT_FONT           (IIF(dfSet("XbaseAlertFont")==NIL, FONT_DEFPROP_SMALL, dfFontCompoundNameNormalize(dfSet("XbaseAlertFont")))) // FONT_HELV_SMALL // FONT_TIMES_MEDIUM

//#define  ALERTSTYLE_SYSTEM        "0"
//#define  AI_ALERTSTYLE_FANCY        "1"
//
//#define  ICONSTYLE_SYSTEM         "0"
//#define  ICONSTYLE_FANCY1         "1"

#ifdef TEST_ALERT

/*
 * Testing environment for the AlertBox() function
 */
PROCEDURE AppSys
   LOCAL oDlg, oXbp, aPos[2], aSize

   aSize    := SetAppWindow():currentSize()
   aPos[1]  := 0.1 * aSize[1]
   aPos[2]  := 0.1 * aSize[2]
   aSize[1] *= 0.6
   aSize[2] *= 0.6

   oDlg       := XbpDialog():new( ,, aPos, aSize,, .F. )
   oDlg:title := "An MDI window"
   oDlg:close := {|| oDlg:destroy() }
   oDlg:create()
   oDlg:drawingArea:SetColorBG( GRA_CLR_PALEGRAY )
   SetAppWindow( oDlg )

   oDlg:show()
   SetAppFocus( oDlg )
RETURN



/*
 * Create a child window on which the AlertBox() is centered
 */

PROCEDURE Main
   LOCAL oDlg, aPos[2], aSize

   aSize    := SetAppWindow():currentSize()
   aPos[1]  := 0.1 * aSize[1]
   aPos[2]  := 0.1 * aSize[2]
   aSize[1] *= 0.6
   aSize[2] *= 0.6

   oDlg       := XbpDialog():new( ,, aPos, aSize,, .F. )
   oDlg:title := "Child window"
   oDlg:close := {|| oDlg:destroy() }
   oDlg:create()
   oDlg:drawingArea:SetColorBG( GRA_CLR_PALEGRAY )

   oDlg:show()
   SetAppFocus( oDlg )

   AlertBox( oDlg, "File exists already://"           + ;
                    CurDir() + "////What do you want to do?", ;
                    { "Overwrite", "Cancel" }        , ;
                    XBPSTATIC_SYSICON_ICONQUESTION   , ;
                    "Alert" )

   AlertBox( oDlg, "Overwrite//Append//Cancel"           , ;
                    { "Overwrite", "Append", "Cancel" }, ;
                    XBPSTATIC_SYSICON_ICONWARNING      , ;
                    "Test" )

   AlertBox( oDlg, "File exists already://"          + ;
                    CurDir() + "\" + CurDir() + "//What do you want to do?", ;
                    { "Continue", "Quit" }          , ;
                    XBPSTATIC_SYSICON_ICONQUESTION    )

   AlertBox( oDlg, "File exists already://"          + ;
                    CurDir() + "//What do you want to do?", ;
                    { "Continue", "Quit" } )

   AlertBox( , "This is the end!",,XBPSTATIC_SYSICON_ICONINFORMATION, "Quit" )

RETURN

function dfset(x)
if x == "XbaseAlertFont"
   return "10.Arial"
endif
return nil
function s2formcurr(); return nil
function s2hotcharcvt(x); return x
function dfappevent(mp1, mp2, oXbp, nTimeOut); return AppEvent( @mp1, @mp2, @oXbp, nTimeOut ) 
function s2xbpisvalid(); return .t.
#endif // DEBUG


/*
 * This function works like the text mode Alert() box but for GUI applications.
 * It displays centered on the specified window.
 */


FUNCTION AlertBox( oOwner, cText, aCaption, xSysIcon, cTitle, nScelta, ;
                   lTextCenter, nFG, nBG, nAlertStyle, nIconStyle)
   LOCAL nEvent   , mp1 , mp2, oXbp , lExit
   LOCAL oParent  , oDlg, oPS, oFont, oFocus, oDesktop
   LOCAL aPushBtn , aPbSize, nPbWidth, nPbDist, nSelect
   LOCAL oIcon    , aIconSize
   LOCAL aTextSize, aText
   LOCAL bSelect  , bKeyboard
   LOCAL i, imax  , nPos   , aPos    , aPos1  , aSize  , nXsize, nYsize
   LOCAL aFocus := {SetAppWindow(), SetAppFocus(), S2FormCurr()}
   LOCAL lTaskList
   LOCAL oLine
   LOCAL lError
   LOCAL oText
   LOCAL bCBLog

   IF ! EMPTY(aCaption)
      aCaption := ACLONE(aCaption)

      AEVAL(aCaption, {|a| a:= IIF(VALTYPE(a)=="A", a, {a, NIL}),  a[1] := S2HotCharCvt(a[1]) }, NIL, NIL, .T. )
   ENDIF

   DEFAULT oOwner   TO SetAppWindow(), ;
           cText    TO ""            , ;
           aCaption TO { {STD_HOTKEYCHAR+"Ok", BUTT_OK} }     , ;
           cTitle   TO " "

   DEFAULT nFG         TO GRA_CLR_BLACK
   DEFAULT nBG         TO XBPSYSCLR_DIALOGBACKGROUND

   DEFAULT lTextCenter TO .T.
   DEFAULT nScelta     TO 0
   DEFAULT nAlertStyle TO dfSet(AI_XBASEALERTSTYLE)
   DEFAULT nIconStyle  TO dfSet(AI_XBASEALERTICONS)

   oDeskTop         := AppDesktop()
   lTaskList        := ! CheckTaskList(oOwner)
   IF lTaskList
      oOwner := oDesktop
   ELSEIF nAlertStyle == AI_ALERTSTYLE_FANCY
      lTaskList := .T. // nuovo stile
   ENDIF

  /*
   * Create the Alert dialog window
   */
   oDlg             := XbpDialog():new( oDesktop, oOwner, NIL, { 100, 100 }, NIL, .F. )
   oDlg:minButton   := .F.
   oDlg:maxButton   := .F.
   oDlg:title       := cTitle
   oDlg:icon        := -1 //no icon
   oDlg:border      := XBPDLG_DLGBORDER
   //simone 6/10/04 correzione per refresh in visual dbsee
   //oDlg:close       := {|mp1,mp2,obj| obj:hide(), lExit := .T. }
   oDlg:close       := {|mp1,mp2,obj| lExit := .T. }
   // Se non esiste un padre che Š nella tasklist allora l'alert sar…
   // visibile nella tasklist
   oDlg:taskList    := lTaskList
   oDlg:create()
   oDlg:drawingArea:SetColorBG( nBG )

   #ifndef _NOFONT_
   oDlg:drawingArea:SetFontCompoundName( BUTTON_FONT )
   #endif
   oDlg:drawingArea:paint := {|| Repaint( aText ) }


  /*
   * Create icon if requested
   */
   IF xSysIcon <> NIL

      // Simone 28/6/2005 conversione automatica icone
      IF nIconStyle == AI_ALERTICONS_FANCY .AND. VALTYPE(xSysIcon) == "N"
         oIcon := NIL
         DO CASE
            CASE xSysIcon == XBPSTATIC_SYSICON_ICONINFORMATION
               oIcon := ICON_INFO_BMP

            CASE xSysIcon == XBPSTATIC_SYSICON_ICONQUESTION
               oIcon := ICON_QUESTION_BMP

            CASE xSysIcon == XBPSTATIC_SYSICON_ICONERROR
               oIcon := ICON_ERROR_BMP

            CASE xSysIcon == XBPSTATIC_SYSICON_ICONWARNING
               oIcon := ICON_WARNING_BMP
         ENDCASE
         IF oIcon != NIL
            oIcon := dfGetImgObject(oIcon, @lError)
            IF ! lError
               xSysIcon := {oIcon, XBPSTATIC_TYPE_BITMAP, NIL}
            ENDIF
         ENDIF
      ENDIF

      IF VALTYPE(xSysIcon) == "A"
         aIconSize := {32, 32}
         IF LEN(xSysIcon) >= 3 .AND. VALTYPE(xSysIcon[3])=="A"
            aIconSize := ACLONE(xSysIcon[3])
         ENDIF
         oIcon          := XbpStatic():new( oDlg:drawingArea, , {0,0}, aIconSize )
         oIcon:caption  := xSysIcon[1]
         oIcon:type     := xSysIcon[2]
         IF LEN(xSysIcon) >= 3 .AND. ! VALTYPE(xSysIcon[3])=="A"
            oIcon:autoSize := .T.
         ENDIF
      ELSE
         oIcon          := XbpStatic():new( oDlg:drawingArea, , {0,0}, {32,32} )
         oIcon:caption  := xSysIcon
         oIcon:type     := XBPSTATIC_TYPE_SYSICON
      ENDIF
      oIcon:create()
      aIconSize      := oIcon:currentSize()
   ELSE
      aIconSize      := {0,0}
   ENDIF


  /*
   * Create a presentation space with font to calculate pushbutton
   * size from font metrics
   */
   oPS    := XbpPresSpace():new():create( oDlg:drawingArea:winDevice() )
   #ifndef _NOFONT_
   oFont  := XbpFont():new( oPS ):create( BUTTON_FONT )
   oPS:setFont( oFont )
   #endif


  /*
   * Find longest button caption
   */
   imax   := Min( MAX_BUTTONS, Len( aCaption ) )
   nPos   := 0
   nXSize := 0

   FOR i:=1 TO imax
      IF Len( aCaption[i][1] ) > nXsize
         nXsize := Len( TRIM(aCaption[i][1]) )
         nPos   := i
      ENDIF
   NEXT


  /*
   * Determine size for pushbuttons
   */
   aPbSize    := GraQueryTextBox( oPS, aCaption[nPos][1] )
   aPbSize    := { aPbSize[3,1] - aPbSize[2,1] ;
                 , aPbSize[3,2] - aPbSize[2,2] }

   IF aCaption[nPos][2] != NIL  .AND. ;    // se c'Š anche immagine la includo nel calcolo
      S2GetPushButtonStyle() != BUT_PS_STD

      nPbDist := dfGetImgSize(aCaption[nPos][2])
      IF nPbDist != NIL
         aPBsize[1] += nPbDist[1] + 5
      ENDIF
   ENDIF

   //Inserito Luca per normalizzare dfalert con troppi bottoni
   IF imax > 3
      aPbSize[1] := Max(aPbSize[1], 27)
      aPbSize[1] := Min(aPbSize[1], 210)
      IF imax > 4
         aPbSize[1] := Min(aPbSize[1], 180)
      ENDIF 
   ELSE
   aPbSize[1] *= 1.5
   ENDIF
   aPbSize[1] := Min(aPbSize[1], 390)

   aPbSize[2] *= 2
   nPbDist    := aPbSize[1] / nXsize
   nPbWidth   := imax * ( aPbSize[1] + nPbDist )


  /*
   * Prepare the string for display and determine display size
   */
   #ifndef _NOFONT_
   oFont     := XbpFont():new( oPS ):create( TEXT_FONT )
   oPS:setFont( oFont )
   #endif
#ifdef USE_HTMLTEXT
   S2HTMLTextParse(cText, @aTextSize)
   IF aTextSize==NIL
   aTextSize := PrepareText( oPS, @aText, cText, nFG )
   ENDIF
#else
   aTextSize := PrepareText( oPS, @aText, cText, nFG )
#endif   

  /*
   * Calculate frame size for the Alert box (XbpDialog window)
   */
   nXsize := Max( nPbWidth + 20, aTextSize[1] + 20 ) + aIconSize[1] * 1.5
   nYsize := aTextSize[2] + 2 * aPbSize[2] + 10

   IF xSysIcon != NIL .AND. aIconSize[2] > 32 // per icone > 32 aggiungo un po
      nYSize += aIconSize[2] - 32
   ENDIF
      
   aSize  := oDlg:calcFrameRect( { 0, 0, nXsize, nYsize } )

   IF nAlertStyle == AI_ALERTSTYLE_FANCY
      oDlg:setSize( { aSize[3], aSize[4]+20 } )
   ELSE
      oDlg:setSize( { aSize[3], aSize[4]} )
   ENDIF
   // MoveToOwner( oDlg )
   oDlg:setPos(CenterPos(oDlg:currentSize(), oDesktop:currentSize()))

   aSize := oDlg:drawingArea:currentSize()


   IF xSysIcon == NIL
     /*
      * No icon - Center text in window
      */
      aPos := CenterPos( aTextSize, aSize )
   ELSE
     /*
      * With icon - Align text next to icon
      */
      aPos    := { 0, 0 }
      aPos[1] := 1.75 * aIconSize[1]
   ENDIF
   aPos[2]    := 2.25 * aPbSize[2]

   IF nAlertStyle == AI_ALERTSTYLE_FANCY
      aPos[2] += 20
   ENDIF

#ifdef USE_STATIC
   // Simone 27/10/05
   // GERR 4538: errori grastringat          
   // come altra soluzione DEFINITIVA uso uno static per display del testo
   // la soluzione in AdjustPos() potrebbe funzionare ma non si pu• testare.
   // questa soluzione Š pi— sicura

   //oText := XbpStatic():new( oDlg:drawingArea, NIL, aPos,  {MAX(nPbWidth, aTextSize[1]+2), aTextSize[2]} ) 
#ifdef USE_HTMLTEXT
   oText := S2StaticX():new( oDlg:drawingArea, NIL, aPos, NIL) 
#else   
   oText := XbpStatic():new( oDlg:drawingArea, NIL, aPos, NIL) 
#endif   
   IF ! EMPTY(cText)
      oText:caption := STRTRAN(cText, LINE_BREAK, CRLF)
      // per compatibilit… con funzionalit… precedente
      // tolgo SOLO L'ULTIMO CRLF
      IF RIGHT(oText:caption, 2) == CRLF
         oText:caption := LEFT(oText:caption, LEN(oText:caption)-2)
      ENDIF
      oText:options := XBPSTATIC_TEXT_WORDBREAK + XBPSTATIC_TEXT_BOTTOM
   ENDIF
   oText:setFont( oFont )
   IF nFG != NIL
      oText:setColorFG(nFG)
   ENDIF
   IF lTextCenter
      oText:options+= XBPSTATIC_TEXT_CENTER
   ENDIF
   oText:autoSize := .T.
   oText:create()                   
   aTextSize := oText:currentSize()
   oText:setSize( {MAX(nPbWidth, aTextSize[1]), aTextSize[2]} ) 

   // disabilita codeblock di repaint
   oDlg:drawingArea:paint := NIL
#endif
   
   AdjustPos( aPos, {MAX(nPbWidth, aTextSize[1]), aTextSize[2]}, ;
              aText, lTextCenter )
              // aText, lTextCenter .OR. xSysIcon != NIL )

   IF nAlertStyle == AI_ALERTSTYLE_FANCY
      // linea di separazione
      //oLine := XbpStatic():new(oDlg:drawingArea, NIL, {aPos[1], aPos[2]-30}, {MAX(nPbWidth, aTextSize[1]), 2})
      oLine := XbpStatic():new(oDlg:drawingArea, NIL, {4, aPBSize[2]+8}, {aSize[1]-8, 2})
      oLine:type := XBPSTATIC_TYPE_RECESSEDRECT
      oLine:create()
   ENDIF

  /*
   * Position the icon to the upper left of the text
   */
   IF oIcon <> NIL
      aPos[1] := aIconSize[1] / 3
      aPos[2] := aSize[2] - 1.5 * aIconSize[2]
      oIcon:setPos( aPos )
   ENDIF


   IF xSysIcon == NIL
     /*
      * No icon - Center pushbutton in window
      */
      aPos    := CenterPos( {nPbWidth, 2 * aPbSize[2]}, aSize )
      aPos[1] += ( nPbDist / 2 )

   ELSEIF nPbWidth < aTextSize[1]
     /*
      * Width of all pushbuttons is less than text width.
      * Center pushbutton below text
      */
      aPos    := CenterPos( {nPbWidth, 2 * aPbSize[2]}, aTextSize )
      aPos[1] += ( 1.5 * aIconSize[1] + ( nPbDist / 2 ) )

   ELSE
     /*
      * Align pushbuttons with text
      */
      aPos[1] := 1.75 * aIconSize[1]
   ENDIF

   // Pulsanti sempre centrati rispetto alla window
   aPos    := CenterPos( {nPbWidth, 2 * aPbSize[2]}, aSize )
   aPos[1] += ( nPbDist / 2 )

   // IF xSysIcon == NIL
   //   /*
   //    * No icon - Center pushbutton in window
   //    */
   //    aPos    := CenterPos( {nPbWidth, 2 * aPbSize[2]}, aSize )
   //    aPos[1] += ( nPbDist / 2 )
   //
   // ELSEIF nPbWidth < aTextSize[1]
   //   /*
   //    * Width of all pushbuttons is less than text width.
   //    * Center pushbutton below text
   //    */
   //    aPos    := CenterPos( {nPbWidth, 2 * aPbSize[2]}, aTextSize )
   //    aPos[1] += ( 1.5 * aIconSize[1] + ( nPbDist / 2 ) )
   //
   // ELSE
   //   /*
   //    * Align pushbuttons with text
   //    */
   //    aPos[1] := 1.75 * aIconSize[1]
   // ENDIF


   aPushBtn   := Array( imax )
   IF nAlertStyle == AI_ALERTSTYLE_FANCY
      aPos[2]    := 4
   ELSE
      aPos[2]    := aPbSize[2] / 2
   ENDIF
   nSelect    := nScelta
   bSelect    := {|mp1 ,mp2,obj| nSelect := obj:cargo, lExit := .T. }
   bKeyBoard  := {|nKey,mp2,obj| lExit := KeyHandler( nKey, obj, aPushBtn ) }


  /*
   * Create the pushbuttons
   */
   FOR i:=1 TO imax
      IF S2GetPushButtonStyle() == BUT_PS_STD
         aPushBtn[i] := XbpPushButton():new( oDlg:drawingArea,, aPos, aPbSize )
      ELSE
         aPushBtn[i] := S2ButtonX():new( oDlg:drawingArea,, aPos, aPbSize )
         aPushBtn[i]:style    := S2GetPushButtonStyle()
         IF aCaption[i][2] != NIL

//            oIcon:= S2XbpBitmap():new()
//            oIcon:create()
//            oIcon:load(NIL, aCaption[i][2])
//            oIcon:transparentClr := GraMakeRGBColor({128, 128, 128})

            oIcon := dfGetImgObject(aCaption[i][2], @lError)
            IF ! lError
               aPushBtn[i]:image     := oIcon
               aPushBtn[i]:imageType := IIF(LEN(aCaption[i]) >= 3, aCaption[i][3], XBPSTATIC_TYPE_BITMAP)
               aPushBtn[i]:side      := .T.
            ENDIF
         ENDIF
      ENDIF
      aPushBtn[i]:caption  := aCaption[i][1]
      aPushBtn[i]:cargo    := i
      aPushBtn[i]:tabstop  := .T.
      aPushBtn[i]:activate := bSelect
      aPushBtn[i]:keyboard := bKeyboard

      IF imax > 1
         IF i == 1
            aPushBtn[i]:group := XBP_BEGIN_GROUP
         ELSEIF i == imax
            aPushBtn[i]:group := XBP_END_GROUP
         ELSE
            aPushBtn[i]:group := XBP_WITHIN_GROUP
         ENDIF
      ENDIF

      aPushBtn[i]:create()
      aPos[1] += ( aPbSize[1] + nPbDist )
   NEXT


   S2FormCurr(oDlg)
   SetAppWindow(oDlg)

   oDlg:setModalState( XBP_DISP_APPMODAL )
   oDlg:show()

   IF nScelta>0 .AND. LEN(aPushBtn)>=nScelta
      oFocus := SetAppFocus( aPushBtn[nScelta] )
   ELSE
      IF LEN(aPushBtn)>0
         oFocus := SetAppFocus( aPushBtn[1] )
      ENDIF
   ENDIF

   bCBLog := dfAppEventLog()
   lExit := .F.
   DO WHILE ! lExit
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp, NIL, oDlg )
      IF bCBLog != NIL
         EVAL(bCBLog, 100, NIL, nEvent, @mp1, @mp2, @oXbp, oDlg)
      ENDIF
      oXbp:handleEvent( nEvent, mp1, mp2 )
      IF bCBLog != NIL
         EVAL(bCBLog, 101, NIL, nEvent, @mp1, @mp2, @oXbp, oDlg)
      ENDIF
   ENDDO

  /*
   * Cleanup: Reset modality, release graphical segment,
   *          dialog and set focus back.
   */
   oDlg:setModalState( XBP_DISP_MODELESS )
   GraSegDestroy( oPS, aText[2] )
   // #ifndef _NOFONT_
   // oFont:destroy()
   // #endif
   // oPS:destroy()

   IF aFocus[2] == NIL
      IF oFocus != NIL
         SetAppFocus( oFocus )
      ENDIF
   ELSE
      SetAppFocus(aFocus[2])
   ENDIF

   oDlg:hide()

   oDlg:destroy()

   IF aFocus[1] != NIL
      SetAppWindow(aFocus[1])
   ENDIF
   IF aFocus[3] != NIL
      S2FormCurr(aFocus[3])
   ENDIF

RETURN nSelect



/*
 * Key handling for pushbuttons in alert box
 * The array containing the pushbuttons is not used here
 * (but may be useful for others...)
 */
STATIC FUNCTION KeyHandler( nKey, oButton, aPushButtons )
   LOCAL cKey := "", nInd, nPos, cCaption, cHot
   LOCAL lExit := .F.

   DO CASE
   CASE nKey == xbeK_ESC
      lExit := .T.
      // La linea sottostante faceva attivare una form diversa
      // (ottenendo un FLASH) premendo ESC...
      //PostAppEvent( xbeP_Close,,, oButton:setParent():setParent() )
   CASE nKey == xbeK_RETURN
      PostAppEvent( xbeP_Activate,,, oButton )
   OTHERWISE
      cKey := UPPER(CHR(nKey))
      IF cKey >= "A" .AND. cKey <= "Z"
         FOR nInd := 1 TO LEN(aPushButtons)
            cCaption := aPushButtons[nInd]:caption
            nPos := AT(STD_HOTKEYCHAR, cCaption)
            IF nPos > 0
               cHot := UPPER(SUBSTR(cCaption, nPos+1, 1))
               IF cHot == cKey
                  oButton := aPushButtons[nInd]
                  PostAppEvent( xbeP_Activate,,, oButton )
                  EXIT
               ENDIF
            ENDIF
         NEXT
      ENDIF
   ENDCASE

RETURN lExit



/*
 * Calculate entire display area for text to be displayed
 */
STATIC FUNCTION PrepareText( oPS, aText, cText, nFG )
   LOCAL aAttr, aTextBox, nMaxWidth, nMaxHeight, cLine, aLine

   aText         := {}
   nMaxWidth     := 80   // larghezza minima = 80 prima era 0, ma con
                         // messaggi corti i pulsanti si sovrapponevano all'icona
   nMaxHeight    := 0
   aAttr         := Array( GRA_AS_COUNT )

   aAttr[ GRA_AS_COLOR ] := nFG

   oPS:setAttrString( aAttr )

   DO WHILE ! Empty( cText )
      cLine      := CutStr( LINE_BREAK, @cText )
      IF Empty( cLine )
         cLine   := " "
      ENDIF
      aLine      := { {0,0}, cLine, 0, 0 }
      aTextBox   := GraQueryTextBox( oPS, aLine[2] )
      aLine[3]   := aTextBox[3,1] - aTextBox[2,1]  // width of substring
      aLine[4]   := aTextBox[3,2] - aTextBox[2,2]  // height of substring
      nMaxWidth  := Max( nMaxWidth, aLine[3] )
      nMaxHeight += ( 2 + aLine[4] )
      AAdd( aText, aLine )
   ENDDO

   aText         := { oPS, 0, aText, aAttr }

RETURN { nMaxWidth, nMaxheight }



/*
 * Adjust GraStringAt() positions for centered display or left alignment
 */
STATIC PROCEDURE AdjustPos( aPos, aSize, aText, lTextCenter )
   LOCAL aLines  := aText[3]
   LOCAL i, imax := Len( aLines )

   // Simone 27/10/05
   // GERR 4538: errori grastringat          
   // dal supporto alaska hanno suggerito di fare un ROUND() o un INT() delle coordinate 
   // perche per lo schermo le coordinate con decimali es. {56.00,58.50} non sono supportate.
   IF lTextCenter
     /*
      * No Icon - Display text centered
      */
      FOR i := 1 TO imax
         aLines[i,1,1] := ROUND(aPos[1] + ( (aSize[1] - aLines[i,3]) / 2 ), 0)
         aLines[i,1,2] := ROUND(aPos[2] + aSize[2] - i * ( 2 + aLines[i,4] ), 0)
      NEXT
   ELSE
     /*
      * With Icon - Display text left aligned
      */
      FOR i := 1 TO imax
         aLines[i,1,1] := ROUND(aPos[1], 0)
         aLines[i,1,2] := ROUND(aPos[2] + aSize[2] - i * ( 2 + aLines[i,4] ), 0)
      NEXT
   ENDIF
RETURN



/*
 * Repaint text using a graphical segment
 */
STATIC PROCEDURE Repaint( aText )
   // STATIC nConta := 0
   LOCAL oPS    := aText[1]
   LOCAL nID    := aText[2]
   LOCAL aLines := aText[3]
   LOCAL aAttr  := aText[4]

   oPS:setAttrString( aAttr )

   IF nID == 0
      nID := GraSegOpen( oPS )
      AEval( aLines, {|a| GraStringAt( oPS, a[1], a[2] ) } )
      GraSegClose( oPS )
      aText[2] := nID
   ENDIF

   GraSegDraw( oPS, nID )
   // oDlg:setTitle(STR(++nConta))

RETURN



/*
 * Move a window within its parent according to the origin of
 * its owner window. Default position is centered on the owner.
 */
// STATIC PROCEDURE MoveToOwner( oDlg, aPos )
//    LOCAL oOwner  := oDlg:setOwner()
//    LOCAL oParent := oDlg:setParent()
//    LOCAL aPos1, nWidth
//
//    DEFAULT aPos TO CenterPos( oDlg:currentSize(), oOwner:currentSize() )
//
//    DO WHILE oOwner <> oParent
//       aPos1   := oOwner:currentPos()
//
//       aPos[1] += aPos1[1]
//       aPos[2] += aPos1[2]
//
//       IF oOwner:isDerivedFrom( "XbpDialog" )
//         /*
//          * Adjust for thickness of the owner window's frame
//          */
//          nWidth  := ( oOwner:currentSize()[1] - oOwner:drawingArea:currentSize()[1] ) / 4
//          aPos[1] += nWidth
//          aPos[2] += nWidth
//       ENDIF
//       oOwner := oOwner:setParent()
//    ENDDO
//
//    oDlg:setPos( aPos )
// RETURN



/*
 * Calculate the center position from size and reference size
 */
STATIC FUNCTION CenterPos( aSize, aRefSize )
RETURN { Int( (aRefSize[1] - aSize[1]) / 2 ) ;
       , Int( (aRefSize[2] - aSize[2]) / 2 ) }



/*
 * Cut a string at a given delimiter and remove delimiter from string
 */
STATIC FUNCTION CutStr( cCut, cString )
   LOCAL cLeftPart, i := At( cCut, cString )

   IF i > 0
      cLeftPart := Left( cString, i-1 )
      cString   := SubStr( cString, i+Len(cCut) )
   ELSE
      cLeftPart := cString
      cString   := ""
   ENDIF

RETURN cLeftPart

// Cerco se ha un padre che sia visibile nella taskList
STATIC FUNCTION CheckTaskList(oXbp)
   LOCAL lRet := .F.
   LOCAL aLoop := {}    // Serve per evitare una eventuale ricorsione
   LOCAL nLoop := 2000  // Serve per evitare una eventuale ricorsione

   DO WHILE .T.
      IF EMPTY(oXbp) .OR. ;
         ASCAN(aLoop, oXbp) != 0 .OR. --nLoop < 0
         EXIT
      ENDIF

      IF S2XbpIsValid(oXbp) .AND. ;
         oXbp:isDerivedFrom("XbpDialog") .AND. ;
         oXbp:taskList

         lRet := .T.
         EXIT
      ENDIF

      AADD(aLoop, oXbp)

      // Simone 20/5/2005
      // collegato a mantis 0000740: La generazione si blocca se una finestra di alert viene chiamata in fase di generazione con la finestra di scorrimento aperta.
      // uso owner perchŠ Š pi— giusto
      // (Es. se oxbp Š una dialog con parent=desktop ma owner=altra dialog)
      // Š corretto che l'owner della ALERT sia la oXbp e non il Desktop
      //oXbp := oXbp:setParent()
      oXbp := oXbp:setOwner()
   ENDDO
RETURN lRet
