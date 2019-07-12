// #include 'xbp.ch'
// #include 'gra.ch'
// #include 'font.ch'
// #include 'appevent.ch'
// #include 'tooltest.ch'
// // #include 'ToolBar.ch'
//
//
// function main()
// LOCAL oToolBar
// LOCAL oDlg, nEvent, mp1, mp2, oXbp
//
// // Create a ToolBar-object
// oToolBar := ToolBar():new():create()
//
// // Add some tools, separators and extra space to the created object
// oToolBar:addTool(ID_BMP_STARTF, { || msgbox('Start') } )
// oToolBar:addSeparator()
// oToolBar:addTool(ID_BMP_FAVOF , { || oToolBar:enable(ID_BMP_HISTF)  } )
// oToolBar:addTool(ID_BMP_HISTF , { || oToolBar:disable(ID_BMP_HISTF), MsgBox("Click on the 'Favorieten-tool' to enable me again") }, "Click me and i'm history" )
// oToolBar:addToolSpace(60)
// oToolBar:addTool(ID_BMP_STOPF , { || PostAppEvent( if(ConfirmBox(, 'Do you want to close this application?',,XBPMB_YESNO,XBPMB_QUESTION) == XBPMB_RET_YES, xbeP_Close, xbeM_Motion) ) }, 'Click me to end this application' )
// oToolBar:numtools()
//
// // Main event-loop
// do while .t.
//
//    nEvent := AppEvent( @mp1, @mp2, @oXbp, .1 )
//
//    IF nEvent <> xbe_None
//       oXbp:handleEvent( nEvent, mp1, mp2 )
//    ENDIF
//
//    IF nEvent == xbeP_Resize
//       sleep(10)
//    ENDIF
//
//    IF nEvent == xbeP_Close .or. nEvent == xbeK_ALT_F4
//       exit
//    ENDIF
//
// enddo
//
// RETURN (nil)



#include 'xbp.ch'
#include 'gra.ch'
#include 'font.ch'
#include 'appevent.ch'
#include 'common.ch'
// #include 'ToolBar.ch'

#if XPPVER < 01900000
#else
#PRAGMA LIBRARY( "ASCOM10.LIB" )
#endif

//---------------------------------------------------------------------------
CLASS ToolBar // from thread
   VAR oGroup                  READONLY
   VAR aIconInformation        READONLY
   VAR nStartPositionNextIcon  READONLY
   VAR nMouseOnIconTime        READONLY
   VAR HiddenButton            READONLY

   // METHODs
   // class METHOD init
   METHOD init

   VAR nOffSet

EXPORTED:
   VAR oAppWin
   VAR nToolBarSize
   VAR nButtonWidth
   VAR nButtonHeight
   VAR nVertSpace
   VAR nHorSpace

   METHOD Create
   METHOD addTool
   METHOD addToolSpace
   METHOD addSeparator
   METHOD numTools
   METHOD ClassName
   METHOD Version
   METHOD Disable
   METHOD Enable
   METHOD DispItm
   METHOD resize
   METHOD SetHorSpace
//   METHOD setSize
//   METHOD setPosAndSize
   //METHOD _KillinputFocus()

   INLINE METHOD getStatic(); RETURN ::oGroup
   INLINE METHOD hide(); RETURN IIF(EMPTY(::oGroup), .F., ::oGroup:hide())
   INLINE METHOD show(); RETURN IIF(EMPTY(::oGroup), .F., ::oGroup:show())
   INLINE METHOD status(); RETURN IIF(EMPTY(::oGroup), XBP_STAT_INIT, ::oGroup:status())
   INLINE METHOD destroy(); RETURN IIF(EMPTY(::oGroup), self, ::oGroup:destroy())
   INLINE METHOD setParent(x); RETURN IIF(EMPTY(::oGroup), NIL, IIF(EMPTY(x), ::oGroup:setParent(), ::oGroup:setParent(x)))
   INLINE METHOD currentSize(); RETURN IIF(EMPTY(::oGroup), {0, 0}, ::oGroup:currentSize())
   INLINE METHOD isEnabled(); RETURN IIF(EMPTY(::oGroup), .F., ::oGroup:isEnabled())

   INLINE METHOD getToolByID(cID)
       LOCAL n
       IF EMPTY(cID)
          RETURN NIL
       ENDIF

       n := ASCAN(::aIconInformation,  {|x| x[6]==cID})

       IF EMPTY(n)
          RETURN NIL
       ENDIF
   RETURN ::aIconInformation[n][1]
  
   INLINE METHOD EraseToolByID(cID)
       LOCAL n
       IF EMPTY(cID)
          RETURN NIL
       ENDIF

       n := ASCAN(::aIconInformation,  {|x| x[6]==cID})

       IF EMPTY(n)
          RETURN NIL
       ENDIF

       //Se l'item aggiunto Š l'ultimo allora aggiorno la posizione per il prossimo inserimento
       IF n == LEN(::aIconInformation)
          ::nStartPositionNextIcon -= ( ::aIconInformation[n][1]:currentSize()[1] + ::nHorSpace)
       ENDIF 

       ADEL(::aIconInformation,n)
       ASIZE(::aIconInformation, LEN(::aIconInformation)-1)
   RETURN n
ENDCLASS

METHOD ToolBar:init()

   ::aIconInformation      := {}
   ::nStartPositionNextIcon := 0
   ::oGroup                := 0

RETURN self

//Maudp - LucaC 15/01/2013 Funzione per diminuire lo spazio tra un pulsante/icona  e l'altro nella toolbar
METHOD ToolBar:SetHorSpace(nNewHorSpace)
   LOCAL nOldHorSpace := ::nHorSpace

   IF VALTYPE(nNewHorSpace)=="N"
      ::nHorSpace := nNewHorSpace
   ENDIF

RETURN nOldHorSpace

METHOD ToolBar:create(oParent, oOwner, aPos, aSize, aPP, lVisible)
   LOCAL nYPosition := 0     , ;
         nXPosition := 0     , ;
         nHeight    := 0     , ;
         nWidth     := 0     , ;
         aChilds    := {}

   DEFAULT ::oAppWin TO oParent
   DEFAULT ::nToolBarSize   TO 70

   DEFAULT aPos  TO {NIL, NIL}
   DEFAULT aSize TO {NIL, NIL}

   DEFAULT ::nVertSpace TO 2
   DEFAULT ::nHorSpace  TO 4

   // Simone 22/3/06
   // mantis 0001016: poter impostare altezza toolbar a livello di progetto per usare icone più grandi
   DEFAULT ::nButtonWidth  TO MIN(::nToolBarSize-2*::nHorSpace, 32)
//   DEFAULT ::nButtonHeight TO MIN(::nToolBarSize-2*::nVertSpace, 32)
   DEFAULT ::nButtonHeight TO (::nToolBarSize-2*::nVertSpace)

   ::nOffset := 0

   // Check if a menubar exists
   // aChilds := ::oAppWin:setParent():childlist()
   // ::nOffset := 0
   // IF ascan(aChilds, { |x| x:classname() == "XbpMenubar" }) > 0
   //    // Yes, place the ToolBar a little lower, below the ToolBar
   //    ::nOffset := 20
   // ELSE
   //    ::nOffset := 0
   // ENDIF

   DEFAULT aPos[1] TO 0
   DEFAULT aPos[2] TO (::oAppWin:currentsize()[2] - ::nToolBarSize - ::nOffset)

   DEFAULT aSize[1] TO ::oAppWin:currentsize()[1]                  // De breedte van het window
   DEFAULT aSize[2] TO ::nToolBarSize

   nXPosition := aPos[1]                                           // Tegen de linkerkant van het window
   nYPosition := aPos[2]
   nWidth     := aSize[1]
   nHeight    := aSize[2]

   ::oGroup := XbpStatic():new( ::oAppWin, ::oAppWin, {nXPosition,nYPosition}, {nWidth,nHeight}, aPP, lVisible)
   ::oGroup:caption := ""
   ::oGroup:clipSiblings := .T.
   ::oGroup:clipChildren := .T.


   // SD 25/02/2003 GERR 3616 dato che ad un oggetto
   // di tipo XBPSTATIC_TYPE_RAISEDBOX
   // non pu• essere impostato il colore
   // allora imposto un codeblock di disegno che simuli il tipo RAISEDBOX
   ::oGroup:paint:={|a, x, o| _paintBox(o, a, XBPSYSCLR_3DHIGHLIGHT, XBPSYSCLR_3DSHADOW)}
   //::oGroup:type := XBPSTATIC_TYPE_RAISEDBOX
   IF EMPTY(dfSet("XbaseToolbarColor"))
      ::oGroup:setColorBG( XBPSYSCLR_DIALOGBACKGROUND )
   ELSE
      ::oGroup:setColorBG( S2DbseeColorToRGB(dfSet("XbaseToolbarColor"), .T.) )
   ENDIF
   ::oGroup:setFontCompoundName( FONT_HELV_SMALL )
   ::oGroup:create()

   ::HiddenButton := XbpPushButton():new(::oGroup, ::oGroup, {1, 1}, {0, 0},, .F. )
   ::HiddenButton:caption := ''
   ::HiddenButton:activate := { || nil }

   //////////////////////////////////////////////////////////////
   //::HiddenButton:setInputFocus  := {||::_KillinputFocus()}
   //////////////////////////////////////////////////////////////

   ::HiddenButton:create()


   ::aIconInformation := {}

   ::nStartPositionNextIcon := 4

   ::addSeparator(.T.,3)
   ::addSeparator(.T.,3)

RETURN self

//METHOD Toolbar:_KillinputFocus()
//  LOCAL oWin     := S2FormCurr()
//  LOCAL oOBJCTRL := oWin:getObjCtrl()
//
//  IF oWin:W_CURRENTGET >= 1 .AND. oWin:W_CURRENTGET <= LEN(oOBJCTRL)
//     oOBJCTRL[oWin:W_CURRENTGET]:handleEvent(xbeP_KillInputFocus, NIL, NIL)
//  ENDIF
//RETURN self

METHOD Toolbar:resize()
   LOCAL aCurr
   LOCAL aNew
   LOCAL lRefresh := .F.

   aCurr := ::oGroup:currentPos()
   aNew  := {0, ::oAppWin:currentsize()[2]-::nToolBarSize-::nOffset}
   IF aCurr[1] != aNew[1] .OR. aCurr[2] != aNew[2]
      ::oGroup:setpos(aNew, .F.)
      lRefresh := .T.
   ENDIF

   aCurr := ::oGroup:currentSize()
   aNew  := {::oAppWin:currentsize()[1], ::nToolBarSize}
   IF aCurr[1] != aNew[1] .OR. aCurr[2] != aNew[2]
      ::oGroup:setSize(aNew, .F.)
      lRefresh := .T.
   ENDIF

   IF lRefresh
      ::oGroup:invalidateRect()
   ENDIF

RETURN self

//METHOD ToolBar:setSize(aSize, lRefresh)
//   ::resize()
//RETURN self
//
//METHOD ToolBar:setPosAndSize(aPos, aSize, lRefresh)
//   ::setPos(aPos, lRefresh)
//   ::resize()
//RETURN self



METHOD ToolBar:addSeparator(lRaised, nWidth)
   LOCAL oSeparator

   DEFAULT lRaised TO .F.
   DEFAULT nWidth   TO 2

   oSeparator := XbpStatic():new( ::oGroup, ::oGroup, {::nStartPositionNextIcon,4}, {nWidth,::oGroup:currentSize()[2]-8} )
   oSeparator:clipSiblings := .T.
   oSeparator:clipChildren := .T.
   IF lRaised
      oSeparator:type := XBPSTATIC_TYPE_RAISEDRECT
   ELSE
      oSeparator:type := XBPSTATIC_TYPE_RECESSEDRECT
   ENDIF
   oSeparator:create()

   ::nStartPositionNextIcon += oSeparator:currentSize()[1] +1

RETURN self

METHOD ToolBar:addToolSpace(nPixels)
   default nPixels to 30
   ::nStartPositionNextIcon += nPixels
RETURN self

METHOD ToolBar:addTool(aIconId, bAction, cToolTip, bActive, cMsgShort, cID)
   LOCAL oButton
   LOCAL aSz
   LOCAL nStyle
   LOCAL cFont
   LOCAL nResize := 0 

   DEFAULT bActive TO {|| .T. }

   IF ! EMPTY(aIconID) 
      // Simone 22/3/06
      // mantis 0001016: poter impostare altezza toolbar a livello di progetto per usare icone più grandi

      // prende dimensione testo/bitmap
      oButton := XbpStatic():new()
      oButton:autoSize := .T.
      IF VALTYPE(aIconID)=="A"
         oButton:caption := aIconID[1]
         oButton:type :=XBPSTATIC_TYPE_BITMAP 
      ELSE
         oButton:caption := aIconID
      ENDIF

      oButton:create(AppDesktop(), NIL, {-1000, -1000}, NIL, NIL, .F.)
      aSz := oButton:currentSize()
      oButton:destroy()
      oButton := NIL
      //-----
//Maudp - LucaC 15/01/2013 Se Š un pulsante, riduco le dimensioni del pulsante, visto che con il font non proporzionale, rimane troppo
//spazio tra l'inizio e la fine della parola e rispettivamente l'inizio e la fine del pulsante
      IF !VALTYPE(aIconID)=="A"
         nResize := INT(aSz[1]*IIF(aSz[1]<60, 0.1, 0.2))
      ENDIF

      aSz[1] := MAX(aSz[1]+2*::nHorSpace-nResize, ::nButtonWidth)
      aSz[2] := ::nButtonHeight 
   ELSE
      aSz := {::nButtonWidth, ::nButtonHeight}
   ENDIF

   IF VALTYPE(aIconID) == "C" .AND. dfSet("XbaseToolBarButtonTextStyle") != NIL
      nStyle := VAL(dfSet("XbaseToolBarButtonTextStyle") )
   ELSEIF dfSet("XbaseToolBarButtonImageStyle") != NIL
      nStyle := VAL(dfSet("XbaseToolBarButtonImageStyle"))
   ELSE
      nStyle := 0
   ENDIF
   
   IF nStyle == 1

      oButton := XbpPushButton():new(::oGroup, ::oGroup, ;
                                 {::nStartPositionNextIcon+4, ::nVertSpace}, ;
                                 aSz)

#if XPPVER < 01900000
#else
   ELSEIF nStyle == 2 .AND. AXShadeButton():AXinstalled()
      oButton :=AXShadeButton():new(::oGroup, ::oGroup, ;
                                 {::nStartPositionNextIcon+4, ::nVertSpace}, ;
                                 aSz)
   ELSEIF nStyle == 3 .AND. XbpButtonPlus():AXinstalled()
      aSz[2] += ::nVertSpace*2
      oButton :=XbpButtonPlus():new(::oGroup, ::oGroup, ;
                                 {::nStartPositionNextIcon+4, 1}, ;
                                 aSz)
#endif
   ELSE

      oButton := Ie4Button():new(::oGroup, ::oGroup, ;
                                 {::nStartPositionNextIcon+4, ::nVertSpace}, ;
                                 aSz)
      oButton:lRaised := .T.
      oButton:lCenter := .T.
   ENDIF

   
   oButton:autoSize:= .F.

   IF VALTYPE(aIconID) == "C"
      oButton:caption   := aIconId
      IF nStyle == 0
         oButton:options := XBPSTATIC_TEXT_CENTER + XBPSTATIC_TEXT_VCENTER
      ENDIF
   ELSE
      oButton:caption   := aIconId[1]
      oButton:type      := XBPSTATIC_TYPE_BITMAP

      // Simone 28/8/06
      // mantis 0001130: dare possibilità di impostare icone toolbar disabilitate/focused   
      oButton:iconDisabled:= aIconId[2]
      IF LEN(aIconID) >= 3 .AND. ! EMPTY(aIconId[3])
         oButton:iconFocus:= aIconId[3]
      ENDIF
   ENDIF

   oButton:toolTipText := cToolTip
   if nStyle == 0
      oButton:activate    := bAction
   else
      oButton:lbdown := bAction
   endif
   oButton:create()
/*
   IF nStyle == 1
      cFont := dfSet("XbaseToolbarFont")
//      IF EMPTY(cFont)
//         cFont := dfSet("XbaseCtrlFont")
//      ENDIF
      IF ! EMPTY( cFont )
         cFont := dfFontCompoundNameNormalize(cFont)  
         oButton:setFontCompoundName( cFont )
      ENDIF
   ENDIF
*/

   AADD( ::aIconInformation, { oButton, aIconId, bAction, cToolTip, bActive, cID } )

   ::nStartPositionNextIcon += oButton:currentSize()[1] + ::nHorSpace

RETURN self

METHOD ToolBar:numTools()
RETURN LEN(::aIconInformation)

METHOD ToolBar:ClassName()
RETURN "ToolBar"

METHOD ToolBar:Version()
RETURN "0.93"

METHOD ToolBar:DispItm()
   LOCAL aIconInformation := ::aIconInformation
   AEVAL(aIconInformation, ;
         {|aIcon,n| IIF(EVAL(aIcon[5], aIcon[1], aIcon, n, aIconInformation), ::enable(n), ::disable(n)), ;
                    aIcon[1]:show() })
RETURN self

METHOD ToolBar:Disable(nTool)
   // LOCAL nTool := 0
   // nTool := ascan( ::aIconInformation, { |x| x[2] == nIconId } )

   IF VALTYPE(nTool) == "N" .AND. nTool > 0 .AND. nTool <= LEN(::aIconInformation) .AND. ;
      ::aIconInformation[nTool, 1]:isEnabled()
/*
      IF LEN(::aIconInformation[nTool, 2]) >= 3
         //::aIconInformation[nTool, 1]:caption := ::aIconInformation[nTool, 2, 3]
         ::aIconInformation[nTool, 1]:setCaption( ::aIconInformation[nTool, 2, 3])
      ELSE
         ::aIconInformation[nTool, 1]:setCaption( ::aIconInformation[nTool, 2, 1])
      ENDIF
*/
     // ::aIconInformation[nTool, 1]:configure()
      ::aIconInformation[nTool, 1]:disable()
   ENDIF

   IF EMPTY(nTool) .AND. ! EMPTY(::oGroup)
//      FOR nTool := 1 TO LEN(::aIconInformation)
//         ::disable(nTool)
//      NEXT
      ::oGroup:disable()
   ENDIF
RETURN self

METHOD ToolBar:Enable(nTool)
   // LOCAL nTool := 0
   // nTool := ascan( ::aIconInformation, { |x| x[2] == nIconId } )
   IF VALTYPE(nTool) == "N" .AND. nTool > 0 .AND. nTool <= LEN(::aIconInformation) .AND. ;
      ! ::aIconInformation[nTool, 1]:isEnabled()
     // ::aIconInformation[nTool, 1]:caption := ::aIconInformation[nTool, 2, 1]
     // ::aIconInformation[nTool, 1]:configure()
//      ::aIconInformation[nTool, 1]:setCaption( ::aIconInformation[nTool, 2, 1] )
      ::aIconInformation[nTool, 1]:enable()
   ENDIF

   IF EMPTY(nTool) .AND. ! EMPTY(::oGroup)
//      FOR nTool := 1 TO LEN(::aIconInformation)
//         ::enable(nTool)
//      NEXT
      ::oGroup:enable()
   ENDIF
RETURN self

// SD 25/02/2003 GERR 3616 
// Disegna un box esattamente come 
// un XbpStatic con ::type=XBPSTATIC_TYPE_RAISEDBOX
STATIC FUNCTION _paintBox(oXbp, aRect, c1, c2)
   LOCAL oPs:= oXbp:lockPS()
   LOCAL aSz:= oXbp:currentSize()
   LOCAL aAttr 
   aSz[1]--
   aSz[2]--

   aAttr := ARRAY(GRA_AL_COUNT)
   aAttr[GRA_AL_COLOR] := c1 
   GraSetAttrLine(oPS, aAttr)
   GraLine(oPs, {0, 0}, {0, aSz[2]})
   GraLine(oPs, NIL   , aSz)

   aAttr := ARRAY(GRA_AL_COUNT)
   aAttr[GRA_AL_COLOR] := c2 
   GraSetAttrLine(oPS, aAttr)
   GraLine(oPs, {1, 0}, {aSz[1], 0})
   GraLine(oPs, NIL   , aSz)

   oXbp:unlockPS(oPS)
RETURN NIL

#if XPPVER < 01900000
#else
CLASS AXShadeButton FROM XbpActiveXControl
EXPORTED:
   VAR activate
   VAR autoSize
   VAR caption

   VAR type
   VAR iconFocus
   VAR iconDisabled

   CLASS METHOD AXInstalled

   ACCESS ASSIGN METHOD activate
//   ACCESS ASSIGN METHOD caption
   METHOD setCaption
   METHOD init
   METHOD create
ENDCLASS

METHOD AXShadeButton:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::XbpActiveXControl:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::clsid := "AXSHADEBUTTON.AxShadeButtonCtrl.1"
RETURN self

METHOD AXShadeButton:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::XbpActiveXControl:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
//   ::appearance := bpAppearanceFlat
//   ::focusStyle := bpFocusStyleControl
   ::setShade(7, 10, 10, 0, 0)
//   ::setShade(7, 10, 10, 0*256*256+0*256+250, 0)
   ::refresh()
RETURN self

METHOD AXShadeButton:activate(x)
   LOCAL xRet := ::activate

   IF VALTYPE(x)=="B"
      ::setProperty("click", x)
      ::activate := x
   ENDIF
RETURN xRet

METHOD AXShadeButton:setCaption(x)
  ::caption := x
RETURN .T.

CLASS METHOD AXShadeButton:AXinstalled()
RETURN dfAXInstalled( AXShadeButton() )


//METHOD AXShadeButton:caption(x)
//   LOCAL xRet := ::caption
//
//   IF VALTYPE(x)$"CM"
//      ::setProperty("caption", x)
//      ::refresh()
//      ::caption:= x
//   ENDIF
//RETURN xRet



***********************************************************************++

#include "activex.ch"

//#include "btnplus.ch"


////////////////////////////////////////////////////////////////////////////////
//
// Automatically generated Header File
//
// Program ID:             BUTTONPLUSCTL.BUTTONPLUS
//
// Creation Date:          24/07/2006
//
// Creation Tool:          Tlb2Ch.exe
//
//                         Copyright (c) Alaska Software. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

#ifndef _BUTTONPLUSCTL_BUTTONPLUS_HAEDER_DAEMON

// Enumeration ButtonPlusAppearanceConstants
//ButtonPlusCtl.ButtonPlusEnums
#DEFINE bpAppearanceFlat                                                       0
#DEFINE bpAppearance3D                                                         1
// Enumeration ButtonPlusStyleConstants
//ButtonPlusCtl.ButtonPlusEnums
#DEFINE bpStyleStandard                                                        0
#DEFINE bpStyleDropdown                                                        2
#DEFINE bpStyleDropdownRight                                                   3
#DEFINE bpStyleSplitDropdown                                                   4
// Enumeration ButtonPlusBorderStyleConstants
//ButtonPlusCtl.ButtonPlusEnums
#DEFINE bpBorderStyleNone                                                      0
#DEFINE bpBorderStyleStandard                                                  1
#DEFINE bpBorderStyleFlat                                                      2
#DEFINE bpBorderStyleHeavy                                                     3
#DEFINE bpBorderStyleLight                                                     4
#DEFINE bpBorderStyleThemed                                                    5
// Enumeration ButtonPlusOLEDropModeConstants
//ButtonPlusCtl.ButtonPlusEnums
#DEFINE bpOLEDropModeNone                                                      0
#DEFINE bpOLEDropModeManual                                                    1
// Enumeration ButtonPlusMousePointerConstants
//ButtonPlusCtl.ButtonPlusEnums
#DEFINE bpMousePointerDefault                                                  0
#DEFINE bpMousePointerArrow                                                    1
#DEFINE bpMousePointerCrosshair                                                2
#DEFINE bpMousePointerIbeam                                                    3
#DEFINE bpMousePointerIcon                                                     4
#DEFINE bpMousePointerSize                                                     5
#DEFINE bpMousePointerSizeNESW                                                 6
#DEFINE bpMousePointerSizeNS                                                   7
#DEFINE bpMousePointerSizeNWSE                                                 8
#DEFINE bpMousePointerSizeWE                                                   9
#DEFINE bpMousePointerUpArrow                                                 10
#DEFINE bpMousePointerHourglass                                               11
#DEFINE bpMousePointerNoDrop                                                  12
#DEFINE bpMousePointerArrowHourglass                                          13
#DEFINE bpMousePointerArrowQuestion                                           14
#DEFINE bpMousePointerSizeAll                                                 15
#DEFINE bpMousePointerCustom                                                  99
// Enumeration ButtonPlusAlignmentExConstants
//ButtonPlusCtl.ButtonPlusEnums
#DEFINE bpAlignmentExTopLeft                                                   0
#DEFINE bpAlignmentExTopCenter                                                 1
#DEFINE bpAlignmentExTopRight                                                  2
#DEFINE bpAlignmentExMiddleLeft                                                3
#DEFINE bpAlignmentExMiddleCenter                                              4
#DEFINE bpAlignmentExMiddleRight                                               5
#DEFINE bpAlignmentExBottomLeft                                                6
#DEFINE bpAlignmentExBottomCenter                                              7
#DEFINE bpAlignmentExBottomRight                                               8
// Enumeration ButtonPlusAlignmentConstants
//ButtonPlusCtl.ButtonPlusEnums
#DEFINE bpAlignmentLeft                                                        0
#DEFINE bpAlignmentRight                                                       1
#DEFINE bpAlignmentCenter                                                      2
// Enumeration ButtonPlusFocusStyleConstants
//ButtonPlusCtl.ButtonPlusEnums
#DEFINE bpFocusStyleNone                                                       0
#DEFINE bpFocusStyleControl                                                    1
#DEFINE bpFocusStyleText                                                       2
#DEFINE bpFocusStylePicture                                                    3
// Enumeration ButtonPlusBackStyleConstants
//ButtonPlusCtl.ButtonPlusEnums
#DEFINE bpBackStyleTransparent                                                 0
#DEFINE bpBackStyleOpaque                                                      1

#define _BUTTONPLUSCTL_BUTTONPLUS_HAEDER_DAEMON
#endif //_BUTTONPLUSCTL_BUTTONPLUS_HAEDER_DAEMON


CLASS XbpButtonPlus FROM XbpActiveXControl
EXPORTED:
   VAR activate
   VAR caption

   VAR autoSize
   VAR type
   VAR iconFocus
   VAR iconDisabled

   CLASS METHOD AXInstalled

   METHOD init
   METHOD create
   METHOD enable
   METHOD disable
   METHOD setCaption
   METHOD isEnabled
   ACCESS ASSIGN METHOD activate
ENDCLASS

METHOD XbpButtonPlus:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::XbpActiveXControl:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::clsid   := "ButtonPlusCtl.ButtonPlus"
   ::caption := NIL
RETURN self

METHOD XbpButtonPlus:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::XbpActiveXControl:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)

   ::appearance      := bpAppearanceFlat
   ::focusStyle      := bpFocusStyleControl
//   ::borderStyle     := bpBorderStyleThemed

   ::useVisualStyles := .T.
//   ::hotImageEffects := .T.
   ::hotEffects      := .T.
   ::wordWrap        := .T.

   // WORK-AROUND #2 FOR PDR 5580
   ::ControlFlags := BXOr( ::ControlFlags, OLECTRL_ACTSLIKEBUTTON )
   IF ::caption != NIL
      ::setCaption( ::caption )
   ENDIF
RETURN self

METHOD XbpButtonPlus:activate(b)
   LOCAL bRet := ::activate
   IF b != NIL
      ::activate := b
      ::click := b
   ENDIF   
RETURN bRet

METHOD XbpButtonPlus:enable()
   ::enabled := .T.
RETURN .T.

METHOD XbpButtonPlus:disable()
   ::enabled := .F.
RETURN .T.

METHOD XbpButtonPlus:isEnabled()
RETURN ::enabled 

METHOD XbpButtonPlus:setCaption(x)
   LOCAL nClr
   ::caption := x

   IF ::status() == XBP_STAT_CREATE
      IF VALTYPE(x) $ "CM"
         ::setProperty("caption", x)
      ELSEIF VALTYPE(x) $ "O" .AND. x:isDerivedFrom("XbpBitmap")
         ::setProperty("picture", x:getIPicture())

         // cerca il colore di sfondo
         nClr := x:transparentClr
         IF nClr == GRA_CLR_INVALID  // check transparency of bitmap
            nClr := x:getDefaultBGColor()
         ENDIF
         IF ! EMPTY(nClr) .AND. nClr != GRA_CLR_INVALID
            nClr := AutomationTranslateColor( nClr, .F. )
            ::maskColor := nClr // imposta il colore sfondo per la trasparenza
         ENDIF
      ENDIF
   ENDIF
RETURN .T.

CLASS METHOD XbpButtonPlus:AXinstalled()
RETURN dfAXInstalled( XbpButtonPlus() )


/*
STATIC FUNCTION AXInstalled(oClass)
   LOCAL lOk := .F.
   LOCAL oAX
   LOCAL oErr 

   oErr := ERRORBLOCK({|e| dfErrBreak(e)})
   BEGIN SEQUENCE
      oAX := oClass:New():create()
      IF ! EMPTY(oAX)
         oAX:destroy()
      ENDIF
      lOk := .T.
   END SEQUENCE
   ERRORBLOCK(oErr)
RETURN lOk
*/
#endif