#include "Xbp.ch"
#include "Gra.ch"
#include "Common.ch"
#include "dfWin.ch"
#include "dfXbase.ch"
#include "dfMenu.ch"

#define MENUTOOLBAR_HEIGHT         80
#define MENUTOOLBAR_BUTTON_HEIGHT (MENUTOOLBAR_HEIGHT-8)
#define MENUTOOLBAR_BUTTON_WIDTH   90
#define SUBMENUINSET_WIDTH        140

#define SUBMENUINSET_POS_LEFT       0
#define SUBMENUINSET_POS_RIGHT      1

#define SUBMENUSTYLE_INSET          0
#define SUBMENUSTYLE_TREE           1

#define MENUITEM_HEIGHT            30
#define DEFAULT_MENU_COLOR         "0/[193-210-238]"
#define DEFAULT_SUBMENU_COLOR      "0/[-57]"


// Cambia lo stile del MENU del FORM
// e lo imposta stile GIOIA/XP
// deve essere chiamata prima del TBCONFIG()
//

FUNCTION dfSetMenuStyle(oWin, n)
   LOCAL oRet

   DEFAULT n TO W_MENU_STYLE_SYSTEM

   DO CASE
      CASE EMPTY(oWin)
      CASE n == W_MENU_STYLE_TOOLBAR
        oRet := MenuStyle1():new(oWin)
        oRet:setup()

      // Simone 22/3/06
      // mantis 0001021: Implementare menu standard/submenu a schede stile outlook oppure tree
      // stile con main menu std e submenu a toolbar
      CASE n == W_MENU_STYLE_ONLYSUBTOOLBAR
        oRet := MenuStyle1():new(oWin, NIL, .F.)
        oRet:setup()
        oWin:lSubMenuHidden := .T.

      CASE n == W_MENU_STYLE_ONLYTOOLBAR
        oRet := MenuStyle1():new(oWin)
        oRet:setup()
        oWin:W_MENUHIDDEN := .T.
        oWin:lSubMenuHidden := .T.
   ENDCASE
RETURN oRet

CLASS MenuStyle1
PROTECTED:
   VAR oWin

   VAR oMenuTB
   VAR oSubMenuTB

   VAR cCurrID
//   VAR aMenuArr

   METHOD LoadMainMenu
   METHOD LoadSubMenu
   METHOD CreateSubMenu

EXPORTED:
   VAR nSubMenuOffset  // distanza del submenu dal main toolbar
   VAR nSubMenuPos     // posizione sub menu:0=sinistra, 1=destra
   VAR xSizeMainButton // xSizeMainButton (Array/logico): imposta le dimensioni dei pulsanti del toolbar orizzontale
                       //   .T. == usa autosize
                       //   .F. == usa dimensioni standard
                       //   {largh, altezza} = usa le dimensioni passate


   VAR nSubMenuStyle   // stile sottomenu SUBMENUSTYLE_INSET/SUBMENUSTYLE_TREE

   VAR SubMenuItemRBClick

   METHOD init
   METHOD create
   METHOD destroy
   METHOD setMenu
   METHOD resize

   INLINE METHOD getCurrID()    ; RETURN ::cCurrID
   INLINE METHOD getMenuObj()   ; RETURN ::oMenuTB
   INLINE METHOD getSubMenuObj(); RETURN ::oSubMenuTB

   INLINE METHOD MenuOpenCB(aMenu)
      LOCAL cMenu := aMenu[MNI_CHILD]
   RETURN {|| ::setMenu(cMenu) }

   INLINE METHOD Setup(xSizeMainButton)
      LOCAL nInd, aArr, aMenu

      aArr := ::oWin:W_MENUARRAY
      IF EMPTY(::oMenuTB)
         // Simone 22/3/06
         // mantis 0001021: Implementare menu standard/submenu a schede stile outlook oppure tree
         // stile con main menu std e submenu a toolbar
         // modifico il menu principale per far aprire il submenu in toolbar
         FOR nInd := 1 TO LEN(aArr)
            aMenu:=dfMenuItm(aArr, aArr[nInd][MNI_CHILD])
            IF ! EMPTY(aMenu)
               aMenu[MNI_BLOCK] := ::MenuOpenCB(aMenu)
            ENDIF
         NEXT

      ELSE
         ::LoadMainMenu(aArr, ::oMenuTB, ::xSizeMainButton)
      ENDIF
   RETURN self
ENDCLASS

// crea toolbar per il primo livello di menu
METHOD MenuStyle1:init(oWin, xSizeMainButton, lMainMenuTB)
   LOCAL aMenuArr, oMenuTB

   DEFAULT lMainMenuTB TO .T.

   // Simone 22/3/06
   // mantis 0001021: Implementare menu standard/submenu a schede stile outlook oppure tree
   // stile con main menu std e submenu a toolbar
   // abilita menu principale come toolbar orizzontale
   IF lMainMenuTB
      oMenuTB  := MenuToolbar():new()
   ENDIF

   // carica menu primo livello
//   ::LoadMainMenu(aMenuArr, oMenuTB, xSizeMainButton)

   ::oWin       := oWin
   ::oMenuTB    := oMenuTB
   IF dfSet("XbaseSubMenuToolbarStyle") == "TREE"
     ::nSubMenuStyle  := SUBMENUSTYLE_TREE
   ELSE
     ::nSubMenuStyle  := SUBMENUSTYLE_INSET
   ENDIF
   ::nSubMenuOffset := 0
   ::nSubMenuPos    := SUBMENUINSET_POS_LEFT
   ::xSizeMainButton:=.T. // autosize pulsanti main toolbar
//   ::oWin:W_MENUHIDDEN := .T.

   ::cCurrID    := ""
RETURN self

METHOD MenuStyle1:create()
   LOCAL aPos
   LOCAL aSize
   LOCAL oParent
   LOCAL o
   LOCAL cColor
   LOCAL nTbrH := IIF(EMPTY(::oMenuTB), 0, MENUTOOLBAR_HEIGHT)
   LOCAL aRet


   oParent := ::oWin:getCtrlArea()

   oParent:resize := dfMergeBlocks(oParent:resize, {|aOld, aNew, o| ::resize(aOld, aNew)} )

   aSize := oParent:currentSize()
   aPos  := {0, aSize[2]- nTbrH}

   aSize[2] := nTbrH

   cColor := IIF(EMPTY(dfSet("XbaseMenuToolbarColor")), DEFAULT_MENU_COLOR, dfSet("XbaseMenuToolbarColor"))

   IF ! EMPTY(::oMenuTB)
      o := ::oMenuTB
      S2ItmSetColors({|n|o:setColorFG(n)}, {|n| o:setColorBG(n)}, .T., cColor)

      IF ! EMPTY(dfSet("XbaseMenuToolbarFont"))
         ::oMenuTB:setFontCompoundName(dfFontCompoundNameNormalize(dfSet("XbaseMenuToolbarFont")))
      ENDIF

      ::oMenuTB:create(oParent, NIL, aPos, aSize)
   ENDIF


   //Luca 08/07/2013
   /////////////////////////////////////////////////////////////
   //Correzione per attivare il men— all'avvio solo se Š attivo.
   aRet := ::oWin:MenuFind(self, 1 )
   if dfMenuItemIsActive(aRet )
      ::setMenu( "1" ) // apre il primo submenu
   ELSE
      aRet := ::oWin:MenuFind(self, 2 )
      IF dfMenuItemIsActive(aRet )
         ::setMenu( "2" ) // apre il primo submenu
      ELSE
         ::setMenu( "3" ) // apre il primo submenu
      ENDIF
   ENDIF
   /////////////////////////////////////////////////////////////
RETURN self

METHOD MenuStyle1:destroy()
   //::oMenuTB:destroy()
RETURN self

METHOD MenuStyle1:resize(aOld, aNew)
   LOCAL aPos
   LOCAL aSize
   LOCAL nTbrH := IIF(EMPTY(::oMenuTB), 0, MENUTOOLBAR_HEIGHT)
   IF ! EMPTY(::oMenuTB)
      aSize := ACLONE(aNew)
      aPos  := {0, aSize[2]- nTbrH}

      aSize[2] := nTbrH
      ::oMenuTB:setPosAndSize(aPos, aSize)
   ENDIF
   IF ! EMPTY(::oSubMenuTB)
      aSize := ACLONE(aNew)
      aSize[1] := IIF(::oWin:MenuInFormWidth==NIL, SUBMENUINSET_WIDTH, ::oWin:MenuInFormWidth)
      aSize[2] -= (nTbrH+ ::nSubMenuOffset)

      aPos  := {0, 0}
      IF ::nSubMenuPos == SUBMENUINSET_POS_RIGHT // posiziona a destra
         aPos[1] := aNew[1]-aSize[1]
      ENDIF
      ::oSubMenuTB:setPosAndSize(aPos, aSize)
   ENDIF
RETURN self

METHOD MenuStyle1:setMenu(cID, lForce)
   LOCAL aMenu
//   LOCAL cCaption
   LOCAL oSubMenuTB

   DEFAULT lForce TO .F.

   IF EMPTY(cID)
      RETURN self
   ENDIF

   IF cID == ::cCurrID .AND. ! lForce
      RETURN self
   ENDIF

   aMenu := dfMenuItm(::oWin:W_MENUARRAY, cID)

   IF ::nSubMenuStyle == SUBMENUSTYLE_INSET
      oSubMenuTB := SubMenuInset():new()
   ELSE
      oSubMenuTB := SubMenuTree():new()
   ENDIF

   oSubMenuTB:itemRBClick := ::subMenuItemRBClick

   ::createSubMenu(oSubMenuTB)

//   oSubMenuTB:addSubMenu(cCaption)
   ::LoadSubMenu(aMenu, oSubMenuTB)

   IF ! EMPTY(::oSubMenuTB) .AND. ::oSubMenuTB:status() == XBP_STAT_CREATE
      ::oSubMenuTB:destroy()
   ENDIF

   // apre primo menu
   oSubMenuTB:selectInset(1)

   ::oSubMenuTB := oSubMenuTB
   ::oSubMenuTB:show()

   ::cCurrID := cID
RETURN self

METHOD MenuStyle1:createSubMenu(oSubMenuTB)
   LOCAL aPos
   LOCAL aSize
   LOCAL oParent
   LOCAL cColor
   LOCAL nTbrH := IIF(EMPTY(::oMenuTB), 0, MENUTOOLBAR_HEIGHT)

   oParent := ::oWin:getCtrlArea()

   aSize := oParent:currentSize()
   IF ::oWin:MenuInFormWidth==NIL
      ::oWin:MenuInFormWidth := SUBMENUINSET_WIDTH
   ENDIF
   aSize[1] := ::oWin:MenuInFormWidth
   aSize[2] -= (nTbrH+ ::nSubMenuOffset)

   aPos  := {0, 0}
   IF ::nSubMenuPos == SUBMENUINSET_POS_RIGHT // posiziona a destra
      aPos[1] := oParent:currentSize()[1]-aSize[1]
   ENDIF

   oSubMenuTB:create(oParent, NIL, aPos, aSize, NIL, .F.)
   IF ! EMPTY(dfSet("XbaseSubMenuToolbarFont"))
      oSubMenuTB:setFontCompoundName(dfFontCompoundNameNormalize(dfSet("XbaseSubMenuToolbarFont")))
   ENDIF

   cColor := IIF(EMPTY(dfSet("XbaseSubMenuToolbarColor")), DEFAULT_SUBMENU_COLOR, dfSet("XbaseSubMenuToolbarColor"))
   S2ItmSetColors({|n|oSubMenuTB:setColorFG(n)}, {|n| oSubMenuTB:setColorBG(n)}, .T., cColor)


   IF oSubMenuTB:isDerivedFrom("SubMenuInset")
      // caratteristiche attive solo per submenu a schede
      IF ! EMPTY(dfSet("XbaseSubMenuToolbarFocusColor"))
         S2ItmSetColors({|n| oSubMenuTB:focusColorFG := n}, {|n| oSubMenuTB:focusColorBG := n}, .T., dfSet("XbaseSubMenuToolbarFocusColor"))
      ENDIF
      IF ! EMPTY(dfSet("XbaseSubMenuToolbarFocusBorder"))
         S2ItmSetColors(NIL, {|n| oSubMenuTB:focusColorBorder := n}, .T., dfSet("XbaseSubMenuToolbarFocusBorder"))
      ENDIF
   ENDIF
RETURN self


// carica menu primo livello
METHOD MenuStyle1:LoadMainMenu(aMenuArr, oMenuTB, xSizeMainButton)
   LOCAL cCaption
   LOCAL nInd
   LOCAL oBtn
   LOCAL aMenu
   LOCAL bActivate
   LOCAL aMaxLen := {MENUTOOLBAR_BUTTON_WIDTH, MENUTOOLBAR_BUTTON_HEIGHT}

   DEFAULT aMenuArr TO {}

   IF VALTYPE(xSizeMainButton) == "A"
      aMaxLen := xSizeMainButton  // usa dimensioni da parametro
   ELSEIF VALTYPE(xSizeMainButton) == "L" .AND. xSizeMainButton
      aMaxLen := NIL // esegue autosize
   ENDIF

   // trova la lungh. massima
//   FOR nInd := 1 TO LEN(aMenuArr)
//      aMenu := aMenuArr[nInd]
//      cCaption := S2HotCharCvt(ALLTRIM(aMenu[MNI_LABEL]))
//      IF aMenu[MNI_SECURITY] == MN_ON .AND. LEN(aMenu[MNI_CHILD]) == 1
//         aMaxLen[1] := MAX(aMaxLen[1], S2StringDim(AppDesktop(), cCaption)[1])
//         aMaxLen[2] := MAX(aMaxLen[2], S2StringDim(AppDesktop(), cCaption)[2])
//      ENDIF
//   NEXT

   FOR nInd := 1 TO LEN(aMenuArr)
      aMenu := aMenuArr[nInd]

      /////////////////////////////////////////////////////////////////////////
      //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012
      //cCaption := S2HotCharCvt(ALLTRIM(aMenu[MNI_LABEL]))
      cCaption := aMenu[MNI_LABEL]
      IF VALTYPE(cCaption) == "B"
         cCaption := EVAL(cCaption)
      ENDIF
      cCaption := S2HotCharCvt(ALLTRIM(cCaption))
      ////////////////////////////////////////////////////////////////////////////

      DO CASE
         CASE aMenu[MNI_TYPE] == MN_LINE

         CASE aMenu[MNI_SECURITY] == MN_ON .AND. LEN(aMenu[MNI_CHILD]) == 1
//            cCaption := SPACE(5)+cCaption+SPACE(5) // allargo un po' il pulsante
//            IF nMaxLen > 0
//               cCaption := PADC(cCaption, nMaxLen)
//            ENDIF
            // menu di primo livello
            oBtn := oMenuTB:insSelector(cCaption, IIF(EMPTY(aMenu[MNI_IMAGES]), NIL, aMenu[MNI_IMAGES][1]), NIL, aMaxLen)
            oBtn:toolTipText := aMenu[MNI_HELP]
            oBtn:activate    := ::MenuOpenCB(aMenu)
//            oBtn:cargo       := aMenu[MNI_CHILD]
//            oBtn:activate    := {|u1, u2, oXbp| ::setMenu(oXbp:cargo)}
      ENDCASE
   NEXT
RETURN self

METHOD MenuStyle1:LoadSubMenu(aSubMenu, oSubMenuTB, cBaseCaption)
   LOCAL cCaption
   LOCAL nInd
   LOCAL oBtn
   LOCAL aMenu
   LOCAL bActivate
   LOCAL aMenuItems := {}
   LOCAL aSubMenus  := {}
   LOCAL aMenuArr
   LOCAL oCurrentSubMenu
   STATIC nLevel   := 1


   /////////////////////////////////////////////////////////////////////////
   //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012
   //cBaseCaption := S2HotCharCvt(ALLTRIM(aSubMenu[MNI_LABEL]))
   cBaseCaption := aSubMenu[MNI_LABEL]
   IF VALTYPE(cBaseCaption) == "B"
      cBaseCaption := EVAL(cBaseCaption)
   ENDIF
   cBaseCaption := S2HotCharCvt(ALLTRIM(cBaseCaption))
   ////////////////////////////////////////////////////////////////////////////



   aMenuArr     := aSubMenu[MNI_ARRAY]

   DEFAULT aMenuArr TO {}

   // primo ciclo, aggiungo tutte le etichette del menu
   FOR nInd := 1 TO LEN(aMenuArr)
      aMenu := aMenuArr[nInd]
      DO CASE
         CASE aMenu[MNI_TYPE] == MN_LINE

         CASE aMenu[MNI_SECURITY] == MN_ON .AND. ! EMPTY(aMenu[MNI_ARRAY])
            AADD(aSubMenus, aMenu)

//            oBtn := XbpStatic():new(::oBase, NIL, {nX, ::nY}, {BTN_WIDTH,BTN_HEIGHT})
//            oBtn:autoSize := .T.
//            oBtn:caption :=
//            oBtn:options := XBPSTATIC_TEXT_BOTTOM
//            oBtn:setFontCompoundName(  ALLTRIM(STR(nLev,3,0))+".Arial Bold Italic"  )
//            oBtn:create()
//            AADD(::aItems, oBtn)
//            AEVAL(aMenu[MNI_ARRAY], {|aMnu, nItm| ::buildMenu(aMnu, nX + 20, nItm, nLev-3) })
//
         CASE aMenu[MNI_SECURITY] == MN_ON .AND. EMPTY(aMenu[MNI_ARRAY])
            AADD(aMenuItems, aMenu)
      ENDCASE
   NEXT

   // aggiunge le voci di menu

// simoned 13/2/07 abilita menu senza voci
//   IF ! EMPTY(aMenuItems)
      IF ! oSubMenuTB:hasPage()  // assicura abbia una pagina base
         oSubMenuTB:addSubMenu(cBaseCaption, aSubMenu[MNI_IMAGES])
      ENDIF

      //imposto altezza necessaria
      oSubMenuTB:setPageHeight( LEN(aMenuItems) * MENUITEM_HEIGHT)

      FOR nInd := 1 TO LEN(aMenuItems)
         aMenu := aMenuItems[nInd]

         /////////////////////////////////////////////////////////////////////////
         //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012
         //cCaption := S2HotCharCvt(ALLTRIM(aMenu[MNI_LABEL]))
         cCaption := aMenu[MNI_LABEL]
         IF VALTYPE(cCaption) == "B"
            cCaption := EVAL(cCaption)
         ENDIF
         cCaption := S2HotCharCvt(ALLTRIM(cCaption))
         ////////////////////////////////////////////////////////////////////////////

         bActivate := _menuCB(::oWin, aMenu[MNI_CHILD])
         oSubMenuTB:addMenuItem(cCaption, bActivate, aMenu[MNI_IMAGES], aMenu[MNI_HELP], aMenu[MNI_CHILD])
      NEXT
//   ENDIF


   // secondo giro, aggiungo tutti i sottomenu
   ////////////////////////////////////////////////////////////////////////////
   //Mantis 2217
   nLevel++
   ////////////////////////////////////////////////////////////////////////////
   FOR nInd := 1 TO LEN(aSubMenus)
      aMenu := aSubMenus[nInd]

      /////////////////////////////////////////////////////////////////////////
      //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012
      //cCaption := S2HotCharCvt(ALLTRIM(aMenu[MNI_LABEL]))
      cCaption := aMenu[MNI_LABEL]
      IF VALTYPE(cCaption) == "B"
         cCaption := EVAL(cCaption)
      ENDIF
      cCaption := S2HotCharCvt(ALLTRIM(cCaption))
      ////////////////////////////////////////////////////////////////////////////
      //Mantis 2217
      //oSubMenuTB:addSubMenu(cCaption, aMenu[MNI_IMAGES])
      ////////////////////////////////////////////////////////////////////////////

      // MB: 10:14:18 venerdi' 21 settembre 2018
      // salvo e ripristino il submenu corrente, per evitare un fastidioso svitch interno di contesto che non andrebbe fatto
      // Probabilmente la class dei submenu andrebbe refactorata
      oCurrentSubMenu := oSubMenuTB:oCurrItem

      oSubMenuTB:addSubMenu(cCaption, aMenu[MNI_IMAGES], nLevel)
      ::LoadSubMenu(aMenu, oSubMenuTB )

      // MB: 10:14:18 venerdi' 21 settembre 2018
      oSubMenuTB:oCurrItem := oCurrentSubMenu
   NEXT
   ////////////////////////////////////////////////////////////////////////////
   //Mantis 2217
   IF nLevel > 1; nLevel-- ; END
   ////////////////////////////////////////////////////////////////////////////

RETURN self


STATIC CLASS MenuToolBar FROM XbpStatic
PROTECTED:
    VAR oTabPageSelector
    METHOD arrangePos

EXPORTED:
    METHOD init
    METHOD create
    METHOD setSize
    METHOD setPosAndSize
    METHOD insSelector
ENDCLASS

METHOD MenuToolBar:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::XbpStatic:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::oTabPageSelector := S2TabPageSelector():new(self)
   ::type       := XBPSTATIC_TYPE_BGNDFRAME
RETURN self

METHOD MenuToolBar:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   DEFAULT lVisible TO .T.

   ::XbpStatic:create( oParent, oOwner, aPos, aSize, aPP, .F. )

   ::oTabPageSelector:create()

   ::arrangePos()

   IF lVisible
      ::show()
   ENDIF
RETURN self

METHOD MenuToolBar:insSelector(cCaption, xImage, nPos, aSize)
   LOCAL oSelector
   oSelector := ::oTabPageSelector:insSelector(cCaption, xImage, nPos, aSize)
   oSelector:side  := .F.
   oSelector:UpOnClick := .T.
RETURN oSelector

METHOD MenuToolBar:setSize(aSize, lUpdate)
   LOCAL lRet := .F.

   DEFAULT lUpdate TO .T.

   lRet := ::XbpStatic:SetSize(aSize, .F.)
   ::arrangePos()
   IF lUpdate
      ::invalidateRect()
   ENDIF
RETURN lRet

METHOD MenuToolbar:setPosAndSize(aPos, aSize, lUpdate)
   LOCAL lRet1,lRet2
   DEFAULT lUpdate TO .T.

   lRet1 := ::SetPos(aPos, .F.)
   lRet2 := ::SetSize(aSize, .F.)

   IF lUpdate
      ::invalidateRect()
   ENDIF
RETURN lRet1 .AND. lRet2

METHOD MenuToolbar:arrangePos()
   LOCAL aSize
   aSize := ::currentSize()
   ::oTabPageSelector:setPosAndSize({1, 1}, {aSize[1]-2, aSize[2]-2})
RETURN self

// -------------------------------------
// Sottomenu a schede
// -------------------------------------
STATIC CLASS SubMenuInset FROM XbpInset
PROTECTED:
   VAR nY
//   VAR nStartY
   VAR oPage

EXPORTED:
   VAR focusColorBorder
   VAR focusColorFG
   VAR focusColorBG

   METHOD init

   METHOD addSubMenu
   METHOD addMenuItem
   METHOD setPageHeight
   INLINE METHOD hasPage(); RETURN ! EMPTY( ::oPage )

   VAR itemRBClick
   METHOD handleRBClick
ENDCLASS

METHOD SubMenuInset:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::XbpInset:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::border := 1

RETURN self

METHOD SubMenuInset:setPageHeight(n)
   IF Empty(n)
   	  ::nY := NIL
   	  RETU Self
   ENDIF
   IF ::hasPage() .AND. VALTYPE(n)=="N" .AND. empty(::nY)   //Empty(::nY) serve x Impostare l'altezza solo alla prima chiamata
      ::oPage:setParent():setDrawingAreaHeight( n )
      ::nY := n
   ENDIF
RETURN self

METHOD SubMenuInset:addSubMenu(cGroup, xImg)
   LOCAL oPage
   LOCAL oInset

   oInset := ::addInset(cGroup) //MSG

   IF EMPTY(oInset)
      RETURN NIL
   ENDIF

   oInset:resize := {|old, new, o| oPage:setSize(new)}

   oPage := XbpPageScroll():new(oInset, NIL, {0, 0}, {oInset:currentSize( .F. )[1], MENUITEM_HEIGHT} )

   oPage:style := 1 // con scrollbar
   oPage:create()

   ::oPage := oPage:drawingArea
   ::nY := 0
RETURN oPage

METHOD SubMenuInset:addMenuItem(cMsgShort, bAction, aIconId, cToolTip, cID)
   LOCAL xCaption
   LOCAL nType
   LOCAL oBtn
   LOCAL n, aPos, oObj

   IF ! ::hasPage()
       //Modifica per gestire più subbenu
      //RETURN .F.
   ENDIF

   DEFAULT cToolTip TO cMsgShort

   ::nY -= MENUITEM_HEIGHT

   oBtn := S2ButtonX():new( ::oPage, NIL, {2, ::nY}, {::oPage:currentsize()[1]-4, MENUITEM_HEIGHT} )

   IF VALTYPE(aIconID) == "C"
      xCaption := aIconId
   ELSE
      xCaption := cMsgShort
//      xIconDisabled:= aIconId[2]
      IF ! EMPTY(aIconID)
         oBtn:Image:= aIconId[1]
         oBtn:ImageType := XBPSTATIC_TYPE_BITMAP
         oBtn:side := .T.
      ENDIF
   ENDIF

   oBtn:caption     := xCaption
   oBtn:style       := 1
   oBtn:toolTipText := cToolTip
   oBtn:cargo       := cID

   // attivo "illuminazione" se il mouse passa sopra
   IF ! EMPTY(::setColorBG())  .AND. ::focusColorBorder != NIL .AND. ::focusColorBG != NIL
//.AND. ! EMPTY(::setColorFG())
      IF ::focusColorFG != NIL
         oBtn:focusColorFG:= ::focusColorFG
      ENDIF
      oBtn:focusColorBorder := ::focusColorBorder
      oBtn:focusColorBG     := ::focusColorBG
      oBtn:setColorBG( ::setColorBG() ) // necessario per far ripristinare correttamente il colore dopo il focus
      //oBtn:setColorFG( ::setColorBG() )
   ENDIF

   oBtn:activate := bAction
   oBtn:rbClick  := {|mp1, mp2, o|::handleRBclick(mp1, mp2, o)}
   IF ::status() == XBP_STAT_CREATE
      oBtn:create()
   ENDIF
RETURN .T.

METHOD SubMenuInset:handleRBClick(aPos, uNil, oBtn)
   IF ::itemRBClick != NIL
      aPos := dfCalcAbsolutePosition(aPos, oBtn, self)
//      aPos[1] += oBtn:currentPos()[1]
//      aPos[2] += oBtn:currentPos()[2]
      EVAL(::itemRBClick, aPos, oBtn:cargo, self)
   ENDIF
RETURN self

// -------------------------------------
// Classe Sottomenu a Tree
// Simone 22/3/06
// mantis 0001021: Implementare menu standard/submenu a schede stile outlook oppure tree
// -------------------------------------
STATIC CLASS SubMenuTree FROM XbpTreeView
PROTECTED:
   VAR aImg
EXPORTED:

   METHOD init
   METHOD create

   METHOD addSubMenu
   METHOD addMenuItem
   METHOD setPageHeight
   METHOD selectInset
   METHOD itemSelected
   METHOD keyboard
   INLINE METHOD hasPage(); RETURN ! EMPTY( ::oCurrItem )

   VAR itemRBClick
   METHOD handleRBClick
   METHOD rbDown

   // MB: 10:14:18 venerdi' 21 settembre 2018
   VAR oCurrItem
ENDCLASS

METHOD SubMenuTree:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::XbpTreeView:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::alwaysShowSelection := .T.
   ::hasButtons := .F.
   ::hasLines   := .F.
   ::oCurrItem  := NIL

//   ::rbDown  := {|mp1, mp2, o|::handleRBclick(mp1, mp2, o)}
RETURN self

METHOD SubMenuTree:create(oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL xImg
   ::XbpTreeView:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::aImg := {}

   // carica icone di default
   xImg := S2XbpBitmap():new()
   IF xImg:load(NIL, "MENUOPEN")
      xImg:create()
      xImg:transparentClr := GRA_CLR_WHITE
   ELSE
      xImg := NIL
   ENDIF
   AADD(::aImg, xImg)

   xImg := S2XbpBitmap():new()
   IF xImg:load(NIL, "MENUCLOSE")
      xImg:create()
      xImg:transparentClr := GRA_CLR_WHITE
   ELSE
      xImg := NIL
   ENDIF
   AADD(::aImg, xImg)

   xImg := S2XbpBitmap():new()
   IF xImg:load(NIL, "MENUEXE")
      xImg:create()
      xImg:transparentClr := GRA_CLR_WHITE
   ELSE
      xImg := NIL
   ENDIF
   AADD(::aImg, xImg)

   xImg := S2XbpBitmap():new()
   IF xImg:load(NIL, "MENUSEL")
      xImg:create()
      xImg:transparentClr := GRA_CLR_WHITE
   ELSE
      xImg := NIL
   ENDIF
   AADD(::aImg, xImg)

RETURN self

METHOD SubMenuTree:setPageHeight(n)
RETURN self

// esegue l'azione
METHOD SubMenuTree:itemSelected(o)
   IF VALTYPE(o) == "O"
      IF VALTYPE(o:getData()) == "A"
         EVAL(o:getData()[1])
//      ELSE
//         o:expand( ! o:isExpanded() )
      ENDIF
   ENDIF
RETURN self

METHOD SubMenuTree:keyboard(n)
   LOCAL o
   IF (n == xbeK_ENTER .OR. n == xbeK_SPACE) .AND. ;
      ! EMPTY( o:= ::getData())

      IF VALTYPE(o:getData())=="A" //se ha codeblock lo esegue
         PostAppEvent(xbeTV_ItemSelected, o, NIL, self)
      ENDIF

   ELSE
      ::XbpTreeView:keyboard(n)
   ENDIF
RETURN self

METHOD SubMenuTree:selectInset(n)
   LOCAL aChilds
   aChilds := ::rootItem:getChildItems()
   IF n >= 1 .AND. n <= LEN(aChilds)
      aChilds[n]:expand(.T.)
   ENDIF
RETURN self

////////////////////////////////////////////////////////////////////////////
//Mantis 2217
//METHOD SubMenuTree:addSubMenu(cGroup, aIconID)
////////////////////////////////////////////////////////////////////////////
METHOD SubMenuTree:addSubMenu(cGroup, aIconID, nLevel)
   LOCAL n1, n2
   LOCAL xImg
   LOCAL xImgSel

   IF VALTYPE(cGroup) $ "CM"
      cGroup := STRTRAN(cGroup, dfHot(), "")
      cGroup := STRTRAN(cGroup, STD_HOTKEYCHAR, "")
   ENDIF

   IF ! EMPTY(aIconID)
      xImg    := aIconId[1]
      IF LEN(aIconID) >= 2
         xImgSel := aIconId[2]
      ENDIF
   ENDIF

   IF xImg == NIL .AND. ::aImg[2] != NIL
      xImg    := ::aImg[2]
      xImgSel := ::aImg[1]
   ENDIF

   IF VALTYPE(xImg) $ "CMA"
      xImg := dfGetImgObject(xImg) // legge il file bmp/jpg/ecc
   ENDIF
   IF VALTYPE(xImgSel) $ "CMA"
      xImgSel := dfGetImgObject(xImgSel) // legge il file bmp/jpg/ecc
   ENDIF
   DEFAULT xImgSel TO xImg
   DEFAULT ::oCurrItem TO ::RootItem
   DEFAULT nLevel TO 1
   ////////////////////////////////////////////////////////////////////////////
   //Mantis 2217
   IF nLevel == 1
      ::oCurrItem := ::rootItem:addItem(cGroup, xImg, xImg, xImgSel)
   ELSE
     ::oCurrItem := ::oCurrItem:addItem(cGroup, xImg, xImg, xImgSel)
   ENDIF
   ////////////////////////////////////////////////////////////////////////////
RETURN ::oCurrItem

METHOD SubMenuTree:addMenuItem(cMsgShort, bAction, aIconId, cToolTip, cID)
   LOCAL xCaption
   LOCAL xImg, xImgSel
   LOCAL oItem

   IF ! ::hasPage()
      RETURN .F.
   ENDIF

   DEFAULT cToolTip TO cMsgShort

   IF VALTYPE(aIconID) == "C"
      xCaption := aIconId
   ELSE
      xCaption := cMsgShort
      IF ! EMPTY(aIconID)
         xImg    := aIconId[1]
         IF LEN(aIconID) >= 2
            xImgSel := aIconId[2]
         ENDIF
      ENDIF
   ENDIF

//   oBtn:toolTipText := cToolTip
   IF VALTYPE(xCaption) $ "CM"
      xCaption := STRTRAN(xCaption, dfHot(), "")
      xCaption := STRTRAN(xCaption, STD_HOTKEYCHAR, "")
   ENDIF

   IF xImg == NIL .AND. ::aImg[3] != NIL
      xImg    := ::aImg[3]
      xImgSel := ::aImg[4]
   ENDIF


   IF VALTYPE(xImg) $ "CMA"
      xImg := dfGetImgObject(xImg) // legge il file bmp/jpg/ecc
   ENDIF
   IF VALTYPE(xImgSel) $ "CMA"
      xImgSel := dfGetImgObject(xImgSel) // legge il file bmp/jpg/ecc
   ENDIF
   DEFAULT xImgSel TO xImg

   oItem := ::oCurrItem:addItem(xCaption, xImg, xImgSel, xImg)
   oItem:setData({bAction, cID})

   // sd 5/2/08 togliere commento per avere menu sempre aperto
   // da vedere:
   // - refresh brutti
   // - sul selectItem(1) dovrebbe posizionare sul primo elemento
   //::oCurrItem:expand(.T.)
RETURN .T.

METHOD SubMenuTree:rbDown(aPos)
   ::handleRBClick(aPos, NIL, self)
RETURN self

METHOD SubMenuTree:handleRBClick(aPos, uNil, oTree)
   LOCAL oItem
   IF ::itemRBClick != NIL
      oItem := ::itemFromPos(aPos)

      IF ! EMPTY(oItem)
         ::setData(oItem) // seleziona item
      ENDIF

      IF ! EMPTY(oItem) .AND. VALTYPE(oItem:getData())=="A"
         oItem := oItem:getData()[2]
      ELSE
         oItem := NIL
      ENDIF
      EVAL(::itemRBClick, aPos, oItem, self)
   ENDIF
RETURN self

STATIC FUNCTION _menuCB(oWin, cID)
   LOCAL c:=cID
RETURN {|| oWin:execMenuItem(c)}
