#include "xbp.ch"
#include "gra.ch"
#include "appevent.ch"
#include "common.ch"
#include "dfXRes.ch"

CLASS S2ToolClass2 FROM XbpInset
PROTECTED:
   VAR aBtns
   VAR oPage
   VAR nY
   VAR nStartY
   VAR nSizeMode
   VAR oBtn

   METHOD destroyButton
   METHOD createButton

EXPORTED:
   VAR nToolBarSize
   VAR bOnChangeSizeMode

   ACCESS ASSIGN METHOD nToolBarSize 

   METHOD create
   METHOD destroy
   METHOD currentPos
   METHOD currentSize
   METHOD setPos
   METHOD setSize
   METHOD setPosAndSize

   METHOD setSizeMode

   METHOD addTool
   METHOD addSeparator
   METHOD addGroup
   METHOD getStatic
   METHOD dispItm
ENDCLASS

METHOD S2ToolClass2:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   DEFAULT aPos  TO {NIL, NIL}
   DEFAULT aSize TO {NIL, NIL}

   DEFAULT aPos[1] TO (oParent:currentsize()[1] - ::nToolBarSize)
   DEFAULT aPos[2] TO 0

   DEFAULT aSize[1] TO ::nToolBarSize
   DEFAULT aSize[2] TO oParent:currentsize()[2]                  

   ::XbpInset:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   IF ! EMPTY(dfSet("XbaseToolbarFont"))
      ::setFontCompoundName(dfFontCompoundNameNormalize(dfSet("XbaseToolBarFont")))
   ENDIF
   ::border := 2
   ::type := XBPSTATIC_TYPE_RECESSEDRECT
   ::nSizeMode := 0

   ::addGroup("Azioni  >") //MSG

   // abilita la possibilit… di nascondere la toolbar
   ::getInset(1):getButton():activate := {|| ::setSizeMode(1)}

   IF ! EMPTY(dfSet("XbaseToolbarColor"))
       S2ItmSetColors({|n|::setColorFG(n)}, {|n| ::setColorBG(n)}, .T., dfSet("XbaseToolbarColor"))
   ENDIF

   // assicura che sia visibile, perche se la form viene chiusa 
   // con la toolbar in stato "pulsante", non si rivede
   ::show()
RETURN self

METHOD S2ToolClass2:nToolBarSize(n)
   IF VALTYPE(n) == "N"
      ::nToolBarSize := n
   ENDIF
RETURN ::nToolBarSize

METHOD S2ToolClass2:destroy()
   ::destroyButton()
   ::aBtns := NIL
   ::XbpInset:destroy()
RETURN self

METHOD S2ToolClass2:getStatic()
RETURN ::oPage

METHOD S2ToolClass2:setSizeMode(n)
   LOCAL nRet := ::nSizeMode
   LOCAL aOld, aNew

   IF VALTYPE(n) == "N" 
      ::nSizeMode := n
      IF ::nSizeMode == 0
         aOld := ::oBtn:currentsize()
         aNew := ::XbpInset:currentSize()
         ::destroyButton()
         ::show()
      ELSE
         ::hide()
         ::createButton()
         aOld := ::XbpInset:currentSize() 
         aNew := ::oBtn:currentsize()
      ENDIF

      IF nRet != ::nSizeMode .AND. ::bOnChangeSizeMode != NIL
         EVAL(::bOnChangeSizeMode, aOld, aNew, self)
      ENDIF
   ENDIF
RETURN nRet  

METHOD S2ToolClass2:destroyButton()
   IF ! EMPTY(::oBtn)
      IF ::oBtn:status() == XBP_STAT_CREATE
         ::oBtn:destroy()
      ENDIF
      ::oBtn := NIL
   ENDIF
RETURN self

METHOD S2ToolClass2:createButton()
   LOCAL oParent 
   LOCAL aPos
   LOCAL aSize   

   ::destroyButton()

   aSize := ::currentSize()
   aPos  := ::currentPos()
   aPos[1] += aSize[1]-16 // larghezza pulsante
   aSize[1] := 16 // larghezza pulsante
   oParent := ::setParent()

   ::oBtn := XbpPushButton():new(oParent, NIL, aPos, aSize)
//   ::oBtn := S2ButtonX():new(oParent, NIL, aPos, aSize)
//   ::oBtn:image   := S2XbpBitmap():new()
//   ::oBtn:image:load(NIL, BTN_PREV)
//   ::oBtn:imageType := XBPSTATIC_TYPE_BITMAP
   ::oBtn:caption := "<"
   ::oBtn:create()
   ::oBtn:activate := {||::setSizeMode(0)}
RETURN self

METHOD S2ToolClass2:addGroup(cGroup)
   LOCAL oPage
   LOCAL oInset

   oInset := ::addInset(cGroup) //MSG
   oInset:resize := {|old, new| oPage:setSize(new)}


   oPage := XbpPageScroll():new(oInset, NIL, {0, 0}, oInset:currentSize( .F. ) )
//   oPage:lOverlappedButtons := .T.
//   oPage:style := 1

   oPage:oUp := S2ButtonX():new(self)
   oPage:oUp:caption := ""
   oPage:oUp:Image := FORMMENU_UP //SCROLLPAGE_UP
   oPage:oUp:Imagetype    := XBPSTATIC_TYPE_BITMAP
   oPage:oUp:Side         := .T.
   oPage:oUp:Style        := 2

   oPage:oDown := S2ButtonX():new(self)
   oPage:oDown:caption := ""
   oPage:oDown:Image := FORMMENU_DOWN //SCROLLPAGE_DOWN
   oPage:oDown:Imagetype    := XBPSTATIC_TYPE_BITMAP
   oPage:oDown:Side         := .T.
   oPage:oDown:Style        := 2


   oPage:create()

//   oPage:setDrawingAreaHeight(::nY)
//   oPage := oInset
   

//   oPage:drawingArea:setSize( oPage:currentSize(.F.) )
//   oPage:drawingArea:toBack()
//   oPage:oUp:toFront()
//   oPage:oDown:toFront()

   ::oPage := oPage:drawingArea
   ::nY := oPage:currentsize(.F.)[2]
   ::nStartY := ::nY
RETURN self

METHOD S2ToolClass2:addSeparator()
   LOCAL oXbp

//   ::addGroup("Gruppo")

   ::nY -= 4
   oXbp := XbpStatic():new(::oPage, NIL, {2, ::nY}, {::oPage:currentsize()[1]-4, 0} )
   oXbp:type := XBPSTATIC_TYPE_RECESSEDLINE
   oXbp:create()
   ::nY -= 4

RETURN self //::add(TB_SEPARATOR)

METHOD S2ToolClass2:addTool(aIconId, bAction, cToolTip, bActive, cMsgShort, cID)
   LOCAL xCaption
   LOCAL nType 
   LOCAL oBtn
   LOCAL n, aPos, oObj

//   LOCAL xIconDisabled

   DEFAULT cMsgShort TO cToolTip

   ::nY -= 30

   oBtn := S2ButtonX():new( ::oPage, NIL, {2, ::nY}, {::oPage:currentsize()[1]-4, 30} )

   IF VALTYPE(aIconID) == "C"
      xCaption := aIconId
   ELSE
      xCaption := cMsgShort
//      xIconDisabled:= aIconId[2]

      oBtn:Image:= aIconId[1]
      oBtn:ImageType := XBPSTATIC_TYPE_BITMAP
      oBtn:side := .T.
   ENDIF

   oBtn:caption := xCaption
   oBtn:style := 1
   oBtn:toolTipText := cToolTip

/*
   oBtn := XbpPushButton():new( ::oPage, NIL, {2, ::nY}, {::oPage:currentsize()[1]-4, 24} )
   IF VALTYPE(aIconID) == "C"
      xCaption := aIconId
   ELSE
      xCaption := aIconId[1]
      xIconDisabled:= aIconId[2]
   ENDIF
   oBtn:caption := xCaption
*/

   oBtn:activate := bAction
   IF ::status() == XBP_STAT_CREATE
      oBtn:create()
   ENDIF

   IF ::aBtns == NIL
      ::aBtns := {}
   ENDIF
   AADD(::aBtns, {oBtn, bActive})

   // se manca spazio, incrementa e sposta in alto tutti i controls
   IF ::nY < 0

      ::oPage:setParent():setDrawingAreaHeight( ::nStartY + ABS(::nY) )

      FOR n := 1 TO LEN(::oPage:childList())
         oObj := ::oPage:childList()[n]
         aPos := oObj:currentPos()
         aPos[2] += ABS(::nY)
         oObj:setPos(aPos)
      NEXT
      ::nStartY += ABS(::nY)
      ::nY := 0
   ENDIF
RETURN self

METHOD S2ToolClass2:dispItm()
   LOCAL n
   LOCAL oBtn

   IF EMPTY(::aBtns)
      RETURN self
   ENDIF

   ::lockUpdate( .T. )
   FOR n := 1 TO LEN(::aBtns)
      oBtn := ::aBtns[n][1] 
      IF EMPTY(::aBtns[n][2]) .OR. EVAL(::aBtns[n][2])
//         IF ::aBtns[n][3] != NIL
//            oBtn:display := ::aBtns[n][3] 
//         ENDIF
//         IF oBtn:mode == TB_BUTTON
//            oBtn:bmp( oBtn:display )
//         ENDIF
         oBtn:enable()
      ELSE
//         IF ::aBtns[n][4] != NIL
//            oBtn:display := ::aBtns[n][4] 
//         ENDIF
//         IF oBtn:mode == TB_BUTTON
//            oBtn:bmp( oBtn:display )
//         ENDIF
         oBtn:disable()
      ENDIF
//      oBtn:invalidateRect()
   NEXT
   ::lockUpdate( .F. )
   ::invalidateRect()
RETURN self

METHOD S2ToolClass2:currentPos()
   LOCAL aRet
   IF EMPTY(::oBtn)
      aRet := ::XbpInset:currentPos()
   ELSE
      aRet := ::oBtn:currentPos()
   ENDIF
RETURN aRet

METHOD S2ToolClass2:currentSize()
   LOCAL aRet
   IF EMPTY(::oBtn)
      aRet := ::XbpInset:currentSize()
   ELSE
      aRet := ::oBtn:currentSize()
   ENDIF
RETURN aRet

METHOD S2ToolClass2:setPos(aPos, lUpdate)
   LOCAL lRet
   LOCAL aDiff
   
   DEFAULT lUpdate TO .T.
   IF EMPTY(::oBtn)
      lRet := ::XbpInset:SetPos(aPos, .F.)
   ELSE
      aDiff := ACLONE(aPos)
      aDiff[1] := ::XbpInset:currentPos()[1] - ::oBtn:currentPos()[1] 

      // sposto pulsante
      lRet := ::oBtn:SetPos(aPos, .F.)

      // sposto anche toolbar
      aPos[1] += aDiff[1]
      ::XbpInset:SetPos(aPos, .F.)
   ENDIF
   IF lUpdate
      ::invalidateRect()
   ENDIF
RETURN lRet

METHOD S2ToolClass2:setSize(aSize, lUpdate)
   LOCAL aDiff
   LOCAL lRet

   DEFAULT lUpdate TO .T.

   IF EMPTY(::oBtn)
      lRet := ::XbpInset:SetSize(aSize, .F.)
   ELSE
      lRet := ::oBtn:SetSize(aSize, .F.)

      // ridim. anche toolbar
      aSize := {::XbpInset:currentSize()[1], aSize[2]}
      ::XbpInset:SetSize(aSize, .F.)
   ENDIF
   IF lUpdate
      ::invalidateRect()
   ENDIF
RETURN lRet

METHOD S2ToolClass2:setPosAndSize(aPos, aSize, lUpdate)
   LOCAL lRet1,lRet2
   DEFAULT lUpdate TO .T.

   lRet1 := ::SetPos(aPos, .F.)
   lRet2 := ::SetSize(aSize, .F.)

   IF lUpdate
      ::invalidateRect()
   ENDIF

RETURN lRet1 .AND. lRet2

