#include "dfCtrl.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "Font.ch"
#include "dfMenu.ch"
#include "dfXBase.ch"
#include "Common.ch"
#include "AppEvent.ch"
#include "dfxres.ch"
#include "dfLook.ch"
#include "dfSet.ch"

// disattiva ottimizzazioni pag 0
//#define _PAGE_ZERO_STD_

// --------------------
// Define per S2ListBox
// --------------------
#define S2LISTBOX_OFFSET_LEFT   (IIF(::getType() == XBPSTATIC_TYPE_GROUPBOX, 3,  1))
#define S2LISTBOX_OFFSET_BOTTOM (IIF(::getType() == XBPSTATIC_TYPE_GROUPBOX, 4, 1))
#define S2LISTBOX_OFFSET_TOP    (IIF(::getType() == XBPSTATIC_TYPE_GROUPBOX, 24, S2LISTBOX_OFFSET_BOTTOM+::headerHeight))
#define S2LISTBOX_OFFSET_RIGHT  (IIF(::getType() == XBPSTATIC_TYPE_GROUPBOX, 11, 2))
//#define S2LISTBOX_OFFSET_RIGHT  (3 * S2LISTBOX_OFFSET_LEFT)



// S2ListBox: CTRL_LISTBOX
// -------------------------
CLASS S2ListBox FROM S2StaticGroupBoxWithFocus, S2CtrlHelp //, AutoResize
   PROTECTED:
      VAR lDispLoop
      METHOD CtrlArrInit

      //INLINE METHOD ResizeArea(); RETURN self

   EXPORTED:
      VAR bActive, oLsb
      METHOD Init, DispItm, Create //, Destroy //, SetInputFocus, KillInputFocus
      METHOD SetFocus, hasFocus, CanSetFocus, enable, disable, IsActive, isShortCut
      METHOD setInputFocus
      // METHOD hilite, dehilite
      METHOD updControl, resize, setSize

      INLINE METHOD getLsb(); RETURN ::oLsb

      INLINE METHOD getDefaultFont(c)
         LOCAL cFont := ::S2StaticGroupBoxWithFocus:getDefaultFont(c)
         IF EMPTY cFont ASSIGN dfSet("XbaseLsbFont")
         IF EMPTY cFont ASSIGN dfSet("XbaseCtrlFont")
         IF cFont != NIL
            // Simone 21/12/04
            // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
            //cFont := UPPER(ALLTRIM(cFont))
            cFont := dfFontCompoundNameNormalize(cFont)
         ENDIF
      RETURN cFont

      INLINE METHOD ShowItem(nCurrPage, oTab)
        LOCAL oPage, nPage 

        /////////////////////////////////////
        //Mantis 693
        IF ::aCtrl[FORM_CTRL_PAGE] == nCurrPage .OR.::aCtrl[FORM_CTRL_PAGE] == 0
           IF !EMPTY(Self:SetParent()) 
//              nPage := -1
//              IF ::setParent():isDerivedFrom("__TabPage")
//                 nPage := ::setParent():nPage
//              ELSEIF ::SetParent():SetParent():isDerivedFrom("__TabPage")
//                 nPage := ::SetParent():SetParent():nPage 
//              ENDIF
#ifdef _PAGE_ZERO_STD_
              IF ::nPage == nCurrPage
#else
              IF ::nPage == nCurrPage .OR. ::nPage==0
#endif
                 ::oLsb:SetParent(self)
              ENDIF
           ENDIF
        ENDIF
        /////////////////////////////////////
      RETURN .T.

      INLINE METHOD findStyle()
         LOCAL nStyle := NIL
         IF LEN(::aCtrl) >= FORM_LIST_PAINTSTYLE
            nStyle := ::aCtrl[FORM_LIST_PAINTSTYLE]
         ENDIF
         IF EMPTY(nStyle)
            nStyle := dfSet(AI_XBASELSBBOXSTYLE)
         ENDIF
      RETURN nStyle
ENDCLASS

METHOD S2ListBox:CtrlArrInit(aCtrl, oFormFather )
   DEFAULT aCtrl[FORM_LIST_ACTIVE] TO {||.T.} // Attivo
 //   IF !TBISOPT(aCtrl[FORM_LIST_OBJECT],W_MM_VSCROLLBAR)
 //      aCtrl[FORM_LIST_OBJECT]:W_RP_RIGHT++
 //      aCtrl[FORM_LIST_OBJECT]:nRight++
 //      aCtrl[FORM_LIST_OBJECT]:W_BG_RIGHT--
 //   ENDIF

#ifndef _NOFONT_
   ASIZE(aCtrl, FORM_LIST_CTRLARRLEN)
   aCtrl[FORM_LIST_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_LIST_FONTCOMPOUNDNAME ])
//   IF EMPTY aCtrl[FORM_LIST_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseLsbFont")
//   IF EMPTY aCtrl[FORM_LIST_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseCtrlFont")
//   IF aCtrl[FORM_LIST_FONTCOMPOUNDNAME ] != NIL
//      aCtrl[FORM_LIST_FONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_LIST_FONTCOMPOUNDNAME ]))
//   ENDIF
#endif
RETURN

METHOD S2ListBox:updControl(aCtrl)
   DEFAULT aCtrl TO ::aCtrl

   ::S2StaticGroupBoxWithFocus:updControl(aCtrl)

   ::setCaption( ::ChgHotKey( ::oLsb:W_TITLE ) )
   ::bActive := ::aCtrl[FORM_LIST_ACTIVE]

   // Imposta i colori per foreground/background del prompt
   S2ObjSetColors(self, .T., ::oLsb:W_COLORARRAY[AC_LSB_PROMPT], APPCOLOR_LSBPROMPT)

   S2ItmSetColors({|n| ::nHiliteColorFG := n}, {|n| ::nHiliteColorBG := n }, ;
                  .T., ::oLsb:W_COLORARRAY[AC_LSB_HILITE])

#ifndef _NOFONT_
   aCtrl[FORM_LIST_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_LIST_FONTCOMPOUNDNAME ])
   ::UpdObjFont( aCtrl[FORM_LIST_FONTCOMPOUNDNAME  ] )
#endif
RETURN self

METHOD S2ListBox:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos

   ::CtrlArrInit(aCtrl, oFormFather )

   ::oLsb := aCtrl[FORM_LIST_OBJECT]

   ::oLsb:oForm := oFormFather
   ::oLsb:oOwner := self
   ::oLsb:itemSelected := {|| dbAct2Kbd("mcr")} //::oForm:skipFocus(1) }

   // simone 19/6/09
   // mantis 0001910: il focus sulle listbox non Š gestito bene
   ::oLsb:setInputFocus := dfMergeBlocks(::oLsb:setInputFocus, {||::setInputFocus()})

   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF S2PixelCoordinate(aCtrl)
       DEFAULT aPos TO  {::oLsb:nLeft,  ::oLsb:nTop    }
       DEFAULT aSize TO {::oLsb:nRight, ::oLsb:nBottom }
   ELSE

      oPos := PosCvt():new(::oLsb:nLeft, ::oLsb:nBottom+.5)
      oPos:Trasla(oParent)

      DEFAULT aPos TO {oPos:nXWin-1, oPos:nYWin}

      oPos:SetDos(::oLsb:nRight            - ::oLsb:nLeft  +1        , ; // +1, ;
                  ::oLsb:nBottom           - ::oLsb:nTop                ) // -1  )

      DEFAULT aSize TO {oPos:nXWin+3, oPos:nYWin + 14}
   ENDIF

   DEFAULT lVisible TO .F.

#ifndef _NOFONT_
   IF ! EMPTY(aCtrl[FORM_LIST_FONTCOMPOUNDNAME])
      DEFAULT aPP TO {}
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_LIST_FONTCOMPOUNDNAME])
      //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_LIST_FONTCOMPOUNDNAME]})
   ENDIF
#endif

   // Imposta i colori nei pres. param. per foreground/background/disabled
   aPP := S2PPSetColors(aPP, {.T., 0}, ::oLsb:W_COLORARRAY[AC_LSB_PROMPT], APPCOLOR_LSBPROMPT)

   // Inizializza l'oggetto
   // ---------------------

   ::aCtrl := aCtrl // simone 13/6/05 assegno ora altrimenti il ::findStyle() da un errore
   ::S2StaticGroupBoxWithFocus:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::headerHeight := IIF( ::GetType() == XBPSTATIC_TYPE_GROUPBOX, 0, 20)

   S2ItmSetColors({|n| ::nHiliteColorFG := n}, {|n| ::nHiliteColorBG := n }, ;
                  .T., ::oLsb:W_COLORARRAY[AC_LSB_HILITE])

   // ::type := XBPSTATIC_TYPE_GROUPBOX
   ::caption := ::ChgHotKey( ::oLsb:W_TITLE )
   ::bActive := aCtrl[FORM_LIST_ACTIVE]
   ::rbDown  := ::oLsb:itemRbDown

   ::lDispLoop := .F.

   // ::oLsb:group := XBP_WITHIN_GROUP

RETURN self

METHOD S2ListBox:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::S2StaticGroupBoxWithFocus:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   // Crea la listbox dentro il groupbox
   // ----------------------------------
   aPos := {S2LISTBOX_OFFSET_LEFT, S2LISTBOX_OFFSET_BOTTOM}
   aSize := ::currentSize()
   aSize[1] -= S2LISTBOX_OFFSET_RIGHT 
   aSize[2] -= S2LISTBOX_OFFSET_TOP

   ::oLsb:Create( self, self, aPos, aSize)

   IF !S2PixelCoordinate(::aCtrl) .AND. ::oLsb:vScroll // Recupero qualche pixel se c'Š la scroll bar verticale

      // simone 9/1/08
      // mantis 0001552: rivedere form gestite con dfAutoForm e S2AutoForm
      // faccio resize solo se ho tipo standard,
      // negli altri stili non ho spazio da recuperare
      IF ::getType() == XBPSTATIC_TYPE_GROUPBOX

      aPos := ::oLsb:currentPos()
      aPos[1]--

      aSize := ::oLsb:currentSize()
      aSize[1]+=8

      ::oLsb:setPos(aPos)
      ::oLsb:setSize(aSize)

      // Commentato per baco Xbase++
      // in quanto setPosAndSize() non sposta la vertical scroll bar
      // #ifdef _XBASE15_
      //    ::oLsb:setPosAndSize(aPos, aSize)
      // #else
      //    ::oLsb:setPos(aPos)
      //    ::oLsb:setSize(aSize)
      // #endif
      ENDIF
   ENDIF
   //::resizeInit({"B", ::oLsb})
RETURN self

// METHOD S2ListBox:Destroy()
//    ::S2StaticGroupBoxWithFocus:Destroy()
//    ::oLsb:Destroy()
// RETURN self

METHOD S2ListBox:isShortCut(cAct)
   LOCAL lRet := .F. , nPos

   IF VALTYPE( ::caption ) == "C" .AND. ;
      ( nPos := AT( STD_HOTKEYCHAR, ::caption) ) != 0

      // nRet := dbAct2Ksc("A_"+LOWER( SUBSTR( ::caption, nPos + 1, 1)))
      lRet := cAct == "A_"+LOWER( SUBSTR( ::caption, nPos + 1, 1))

   ENDIF
RETURN lRet

METHOD S2ListBox:IsActive()
RETURN EVAL(::bActive)

//Maudp-LucaC XL 3878 21/03/2013 Aggiunto lForce per fare il refresh forzato sulle listbox (attualmente lo faceva solo in presenza di tag)
//METHOD S2ListBox:DispItm() // ( cGrp, lRef )
METHOD S2ListBox:DispItm(lForce) // ( cGrp, lRef )
   LOCAL lRet := .F.
   LOCAl nRec

   DEFAULT lForce TO .F.

   IF ! ::lDispLoop
      ::lDispLoop := .T.

      IF ::CanShow()
         lRet := ::S2StaticGroupBoxWithFocus:DispItm() // (cGrp, lRef)

         // ::oLsb:DispItm() // show()

         IF ::oLsb:W_KEY#NIL
            IF ::oLsb:W_CURRENTKEY #  EVAL( ::oLsb:W_KEY )
               ::oLsb:W_CURRENTKEY := EVAL( ::oLsb:W_KEY )
               ::oLsb:W_OBJREFRESH := .T.
               ::oLsb:W_OBJGOTOP   := .T.
            ENDIF
         ENDIF

         IF ::oLsb:W_OBJREFRESH      // Invalido

            // ::oLsb:refreshAll()

            // ::oLsb:INVALIDATE()         // Invalidate dell'oggetto
            //                            // Serve per il refresh del
            //                            // cambio pagina
         ENDIF

         nRec := ::oLsb:W_CURRENTREC    // Memorizzo il vecchio record

         IF ::oLsb:W_OBJGOTOP           // Go Top
            ::oLsb:W_OBJGOTOP := .F.
            tbPos( ::oLsb )
         ENDIF

         IF ::oLsb:W_OBJREFRESH // .OR. !::oLsb:STABLE
            tbStab( ::oLsb )
         ENDIF

         IF ::oLsb:W_CURRENTREC#nRec .OR.;
            ::oLsb:W_OBJREFRESH
            ::oLsb:W_OBJREFRESH  := .F.

            tbRecCng( ::oLsb) // Aggiorno W_CURRENTREC

            tbSys( ::oLsb, ::oForm )
         ENDIF

         // IF nActual==nPos            // Effettuo ON/OFF
         //    tbOn( ::oLsb )
         // ELSE
         //    tbOff( ::oLsb )
         // ENDIF

//Maudp-LucaC XL 3878 21/03/2013 Aggiunto lForce per fare il refresh forzato sulle listbox (attualmente lo faceva solo in presenza di tag)
//         ::oLsb:dispItm()
         ::oLsb:dispItm(lForce)
      ELSE
         ::oLsb:hide()
      ENDIF

      IF ::IsActive()
         ::enable()
      ELSE
         ::disable()
      ENDIF

      // IF EVAL(::bDispIf)
      //    ::oLsb:show()
      // ELSE
      //    ::hide()
      //    ::oLsb:hide()
      //
      // ENDIF
      // IF ::IsActive()
      //    ::enable()
      //    ::oLsb:enable()
      // ELSE
      //    ::disable()
      //    ::oLsb:disable()
      // ENDIF
      ::lDispLoop := .F.
   ENDIF
RETURN lRet


METHOD S2ListBox:enable()
   LOCAL lRet := ::S2StaticGroupBoxWithFocus:enable()
   IF lRet
      ::oLsb:enable()
   ENDIF
RETURN lRet

METHOD S2ListBox:disable()
   LOCAL lRet := ::S2StaticGroupBoxWithFocus:disable()

   IF lRet
      ::oLsb:disable()
   ENDIF
RETURN lRet


METHOD S2ListBox:CanSetFocus()
//SD RETURN ::oLsb:TabStop .AND. ::IsActive() .AND. ::CanShow() //.AND. ::isEnabled() .AND. ::isVisible()
RETURN ::CanSetPage() .AND. ::IsActive() .AND. ::CanShow() //.AND. ::isEnabled() .AND. ::isVisible()

METHOD S2ListBox:SetFocus()
   ::setHelpID(::cID)
   ::enable()
RETURN SetAppFocus( ::oLsb )

// simone 19/6/09
// mantis 0001910: il focus sulle listbox non Š gestito bene
METHOD S2ListBox:setInputFocus()
   ::setHelpID(::cID)
   ::oForm:UpdateCurrentGet()
RETURN self

METHOD S2ListBox:hasFocus()
// RETURN ::oLsb:HasInputFocus()
RETURN SetAppFocus() == ::oLsb

// METHOD S2ListBox:hilite()
//    // ::setFontCompoundName( FONT_DEFPROP_SMALL + FONT_STYLE_BOLD)
//    // ::setCaption( ::caption )
//    ::setCaption("[ " + ::caption +" ]")
// RETURN self
//
// METHOD S2ListBox:dehilite()
//    // ::setFontCompoundName( APPLICATION_FONT )
//    // ::setCaption( ::caption )
//    ::setCaption( SUBSTR( ::caption, 3, LEN(::caption)-4 ))
// RETURN self

METHOD S2ListBox:setSize(aNew, lUpdate)
   DEFAULT lUpdate TO .T.

   ::S2StaticGroupBoxWithFocus:setSize(aNew, .F.)
   aNew[1] -= S2LISTBOX_OFFSET_RIGHT
   aNew[2] -= S2LISTBOX_OFFSET_TOP
   ::oLsb:setSize(aNew, .F.)

   IF lUpdate
      ::invalidateRect() 
   ENDIF
RETURN .T.

METHOD S2ListBox:resize(aOld, aNew)
//   ::lockUpdate( .T. )
   ::S2StaticGroupBoxWithFocus:resize(aOld, aNew)
   aNew[1] -= S2LISTBOX_OFFSET_RIGHT
   aNew[2] -= S2LISTBOX_OFFSET_TOP
   ::oLsb:setSize(aNew, .F.)
//   ::lockUpdate( .F. )
   ::invalidateRect()
RETURN self