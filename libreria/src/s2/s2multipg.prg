// Function/Procedure Prototype Table  -  Last Update: 07/10/98 @ 12.24.42
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Return Value         Function/Arguments
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// lSuccess             METHOD S2MultiPage:ActivatePage(oTab)
// ::nCurrPage          METHOD S2MultiPage:ActualPage()
// oTab                 METHOD S2MultiPage:AddPage(cCaption)
// Void                 METHOD S2MultiPage:Create()
// ::aPage[n]:drawi...  METHOD S2MultiPage:GetPage( n )
// self                 METHOD S2MultiPage:Init(oParent)
// Void                 METHOD S2MultiPage:LoopPage( n )
// self                 METHOD S2MultiPage:MinimizeAll()
// ::nNumPages          METHOD S2MultiPage:NumPages()
// Void                 METHOD S2MultiPage:ShowPage( n )
// Void                 METHOD S2MultiPage:SkipPage( n )
// RETURN self          METHOD S2TextBox:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
// Void                 METHOD S2TextBox:GetText()
// self                 METHOD S2TextBox:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
// NIL                  METHOD S2TextBox:SetText( cText )

#include "dfWin.ch"
#include "dfMenu.ch"
#include "dfCtrl.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Appevent.ch"
#include "dfXBase.ch"
#include "dfXRes.ch"
#include "font.ch"

#define PAGE_LABEL_HEIGHT    20

#define S2TABPAGE_OFFSET_LEFT   5
#define S2TABPAGE_OFFSET_BOTTOM 5
#define S2TABPAGE_OFFSET_TOP    2 * S2TABPAGE_OFFSET_BOTTOM  + PAGE_LABEL_HEIGHT
#define S2TABPAGE_OFFSET_RIGHT  2 * S2TABPAGE_OFFSET_LEFT


// disattiva ottimizzazioni pag 0
//#define _PAGE_ZERO_STD_

FUNCTION S2GetMultiPageStyle()
RETURN dfSet(AI_XBASEMULTIPAGESTYLE)
/*
   LOCAL nRet   := W_MULTIPAGE_STYLE_SYSTEM
   LOCAL cStyle

//   IF VALTYPE(nStyle) == "N"
//      RETURN nStyle
//   ENDIF

   cStyle := dfSet("XbaseMultiPageStyle")

   DO CASE
      CASE EMPTY(cStyle)
        nRet := W_MULTIPAGE_STYLE_SYSTEM
      CASE cStyle == "1"
        nRet := W_MULTIPAGE_STYLE_FLAT
   ENDCASE
RETURN nRet
*/

FUNCTION S2GetMultiPageClass(nStyle)
   LOCAL oBtn
   IF nStyle == AI_MULTIPAGESTYLE_STD
      oBtn := S2MultiPage()
   ELSE
      oBtn := S2MultiPageX()
   ENDIF
RETURN oBtn

// ------------------------------------------
// Classe __TabPage
// Caratteristiche comuni a tutti i TabPage
// ------------------------------------------
STATIC CLASS __TabPage
PROTECTED:
   //Mantis 320
   VAR bSelectCodeBlock


EXPORTED:
   VAR nPage
   VAR bCanMinimize

   //Mantis 320
   INLINE METHOD SetSelectCodeBlock(bNew)
       LOCAL bRet := ::bSelectCodeBlock
       IF bNew != NIL
          ::bSelectCodeBlock := bNew
       ENDIF
   RETURN bRet

   INLINE METHOD GetSelectCodeBlock()
   RETURN ::bSelectCodeBlock

   INLINE METHOD DispItm()
      // Metodo fittizio per non dare errore in caso venga eseguito
      // questo metodo nella tbInk
   RETURN self

ENDCLASS

// -----------------------------------------------
// CLASSE S2TabPage: pagina con un'area di disegno
// -----------------------------------------------
// Simone 20/giu/03
//   provato a implementare autoresize ma non
//   funziona bene, Š da rivedere
CLASS S2TabPage FROM XbpTabPage, __TabPage //, AutoResize
PROTECTED:
//   INLINE METHOD resizeArea(); RETURN self

EXPORTED:
   VAR drawingArea

   INLINE METHOD Minimize()
      LOCAL lRet := .F.
      IF EMPTY(::bCanMinimize) .OR. EVAL(::bCanMinimize)
         lRet := ::XbpTabPage:minimize()

// 13:36:08 mercoledi' 28 marzo 2018
// MB: Fix provvisorio: nei form multipagina, il minimize torna .F. e non innesca l'evento di cambio pagina
#ifdef _XBASE200_
         lRet := .T.
#endif
      ENDIF
   RETURN lRet

   // METHOD HandleEvent

   // INLINE METHOD TabActivate()
   //    ::XbpTabPage:TabActivate()
   // RETURN self

   INLINE METHOD maximize()
      LOCAL lRet := ::XbpTabPage:maximize()
      //::invalidateRect()
      //::drawingArea:invalidateRect()
   RETURN lRet

   INLINE METHOD Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
      //Luca 01/11/2009
      //Corretto problema runtime in apertura Designer multipagina VDB
      IF ::XbpTabPage:Status() <= XBP_STAT_INIT
         //Non ancora creato
      ELSE
         ::XbpTabPage:Destroy()
         ::drawingArea:Destroy()
      ENDIF
      ::XbpTabPage:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
      ::drawingArea:Create()
//      ::resizeInit({"B", ::drawingArea})
   RETURN self

//Tolto perche con Xbase 190 da problemi in designer VDB
//
//   // WORKAROUND vedi PDR 2493
//   // Simone 10/giu/03
//   INLINE METHOD Configure(oParent, oOwner, aPos, aSize, aPP, lVisible)
//      ::drawingArea:hide()
//      ::drawingArea:setParent(AppDesktop())
//      ::XbpTabPage:configure(oParent, oOwner, aPos, aSize, aPP, lVisible)
//      ::drawingArea:setParent(self)
//      ::drawingArea:show()
//   RETURN self


   // WORKAROUND vedi PDR 2626
   // Simone 10/giu/03
   INLINE METHOD SetCaption(cCaption)
      ::caption := cCaption
      ::configure()
   RETURN self

   INLINE METHOD SetPosAndSize(aPos, aSize, l)
      DEFAULT l TO .T.
      ::XbpTabPage:setPos(aPos, l)
      ::SetSize(aSize, l)
   RETURN .T.

   INLINE METHOD SetSize(aSize, l)
      LOCAL aPos
      DEFAULT l TO .T.
      aSize := ACLONE(aSize)
      ::XbpTabPage:setSize(aSize, l)

      IF ::tabHeight == 0
         aPos := {0, 0}
      ELSE
         aPos := {S2TABPAGE_OFFSET_LEFT, S2TABPAGE_OFFSET_BOTTOM}
         aSize[1] -= S2TABPAGE_OFFSET_RIGHT
         aSize[2] -= S2TABPAGE_OFFSET_TOP
      ENDIF
      ::drawingArea:setPosAndSize(aPos, aSize, l)
   RETURN .T.

//   INLINE METHOD Configure(oParent, oOwner, aPos, aSize, aPP, lVisible)
//       LOCAL aChildList := {}
//       ::AddChildList(self, aChildList)
//       AEVAL(aChildList, {|o| o:destroy()})
//       ::XbpTabPage:configure(oParent, oOwner, aPos, aSize, aPP, lVisible)
//       AEVAL(aChildList, {|o| o:create()})
//   RETURN self
//
//   INLINE METHOD AddChildList(o, aChildList)
//      LOCAL a := o:childList()
//      LOCAL nInd
//      FOR nInd := 1 TO LEN(a)
//         AADD(aChildList, a[nInd])
//         ::AddChildList(a[nInd], aChildList)
//      NEXT
//   RETURN self


ENDCLASS




STATIC CLASS TabPageX FROM S2TabPageX, __TabPage
EXPORTED:
   VAR drawingarea
   VAR minimized
   VAR caption

//   VAR TabActivate

   INLINE METHOD Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
       ::S2TabPageX:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
       ::__TabPage:Init()
       ::minimized := .T.
       ::drawingarea := self
   RETURN self

   INLINE METHOD destroy()
      ::S2TabPageX:destroy()
   #ifdef _PAGE_ZERO_STD_
      ::drawingarea := NIL
   #endif
   RETURN self

   INLINE METHOD Minimize()
      LOCAL lRet := .F.
      IF EMPTY(::bCanMinimize) .OR. EVAL(::bCanMinimize)
         lRet := .T.
      ENDIF
   RETURN lRet

   // METHOD HandleEvent

   // INLINE METHOD TabActivate()
   //    ::XbpTabPage:TabActivate()
   // RETURN self

   INLINE METHOD maximize()
      LOCAL lRet := ::setParent():selectPage( self )
      //::invalidateRect()
      //::drawingArea:invalidateRect()
   RETURN lRet

   INLINE METHOD setCaption(x)
      ::caption := x
      ::setParent():setSelectorCaption(self, x)
   RETURN .T.

   INLINE METHOD handleEvent(nEvent, mp1, mp2)
      IF nEvent == xbeTab_TabActivate
         IF VALTYPE(::tabActivate) == "B"
            EVAL(::tabActivate, mp1, mp2, self)
         ENDIF
      ELSE
         ::S2TabPageX:handleEvent(nEvent, mp1, mp2)
      ENDIF
   RETURN self
ENDCLASS


// METHOD S2TabPage:HandleEvent(n, m1, m2)
//    // IF ! n == xbeP_SetInputFocus
//       ::XbpTabPage:HandleEvent(n, m1, m2)
//    // ENDIF
// RETURN self


// ------------------------------------------
// Classe __MultiPage
// Caratteristiche comuni a tutti i MultiPage
// ------------------------------------------
STATIC CLASS __MultiPage
   PROTECTED:
      VAR bCanSetPage

      INLINE METHOD FindPageNumber(n)
      RETURN ASCAN(::aPage, {|o| o:nPage == n})

   EXPORTED:
      VAR aPage, oParent, nTabWidth, TabHeight, nCurrPage, nNumPages, bOnPgChange
      VAR bOnPrePgChange

      METHOD MinimizeAll
      METHOD Init
      METHOD Create
      METHOD GetPage
      METHOD NumPages
      METHOD ShowPage
      METHOD SkipPage
      METHOD LoopPage
      METHOD ActualPage
      METHOD ActivatePage
      METHOD GetTab

      DEFERRED METHOD addPage
      DEFERRED METHOD insPage
      DEFERRED METHOD delPage
      DEFERRED METHOD setSize
      DEFERRED METHOD setTabHeight
      DEFERRED METHOD currentSize

      INLINE METHOD CanSetPage(bNew)
          LOCAL bRet := ::bCanSetPage
          IF bNew != NIL
             ::bCanSetPage := bNew
          ENDIF
      RETURN bRet
ENDCLASS

METHOD __MultiPage:Init(oParent, nNumPages)

   DEFAULT nNumPages TO 5
   nNumPages := MAX(5, nNumPages)

   ::oParent   := oParent
   ::nTabWidth := INT( 100 / nNumPages )
   ::TabHeight := PAGE_LABEL_HEIGHT
   ::aPage := {}
   ::nCurrPage := 0
   ::nNumPages := 0
   ::bCanSetPage := {|nCurr, nNew, oCurr, oNew| .T. }
RETURN self

METHOD __MultiPage:Create()
   LOCAL nN := 0
   IF ::nCurrPage == 0 // Se Š la prima volta che la creo
      //Mantis 320
      FOR nN := 1 TO LEN(::aPage)
        IF EVAL(::aPage[nN]:GetSelectCodeBlock())
           ::nCurrPage := nN
           ::aPage[::nCurrPage]:minimized := .F.
           EXIT
        ENDIF
      NEXT
      IF ::nCurrPage == 0
         ::nCurrPage := 1
         ::aPage[::nCurrPage]:minimized := .F.
      ENDIF
   ENDIF
RETURN self

METHOD __MultiPage:ActivatePage(oTab)
   LOCAL lSuccess := .F.
   LOCAL nPage := ::FindPageNumber(oTab:nPage)
   LOCAL nPrev
   LOCAL nN, oOBJ,aOBJ

   IF EVAL(::bCanSetPage, ::nCurrPage, nPage, ::aPage[::nCurrPage], oTab) .AND. ;
      EVAL(oTab:GetSelectCodeBlock()) .AND.; //Mantis 320
      ! ::nCurrPage == nPage .AND. ::aPage[::nCurrPage]:minimize()

      ::MinimizeAll()
      IF VALTYPE(::bOnPrePgChange) == "B"
         EVAL(::bOnPrePgChange, ::nCurrPage, nPage, self)
      ENDIF
      oTab:maximize()

      nPrev := ::nCurrPage
      ::nCurrPage := nPage
      IF VALTYPE(::bOnPgChange) == "B"
         EVAL(::bOnPgChange, nPrev, nPage, self)
      ENDIF
      lSuccess := .T.

      //////////////////////////////////////////////////////////
      //Correzione Colore di sfondo checkbox
      //////////////////////////////////////////////////////////

      IF VALTYPE(S2FormCurr())=="O" .AND. IsMethod( S2FormCurr(),"getObjCtrl")

         aOBJ   := S2FormCurr():getObjCtrl()
         FOR nN := 1 TO LEN(aOBJ)
           oOBJ := aObj[nN]

           IF oOBJ:isDerivedFrom("S2CheckBox")
              IF oOBJ:nPage == nPage  .OR. oOBJ:nPage == 0//Cansetpage()
                 oOBJ:lUno  := .T.
              ENDIF
           ENDIF
         NEXT
      ENDIF
      //////////////////////////////////////////////////////////
      //////////////////////////////////////////////////////////




   ENDIF



RETURN lSuccess

METHOD __MultiPage:ActualPage()
RETURN ::nCurrPage

METHOD __MultiPage:GetPage( n )
RETURN ::aPage[n]:drawingArea

METHOD __MultiPage:GetTab( n )
RETURN ::aPage[n]

METHOD __MultiPage:ShowPage( n )

   IF ::nCurrPage != n
      EVAL(::aPage[n]:TabActivate, NIL, NIL, ::aPage[n])
      ::aPage[n]:Show()
   ENDIF



RETURN

METHOD __MultiPage:NumPages()
RETURN ::nNumPages

METHOD __MultiPage:MinimizeAll()
   AEVAL( ::aPage, {|oTab| oTab:minimize() })
RETURN self

METHOD __MultiPage:LoopPage( n )
   LOCAL nCP := ::nCurrPage

   IF ::nNumPages > 0
      nCP += n

      IF nCP > ::nNumPages
         nCP %= ::nNumPages

      ELSEIF nCP < 1

         nCP := ::nNumPages + (nCP % ::nNumPages)

      ENDIF

      ::ShowPage(nCP)

   ENDIF
RETURN

METHOD __MultiPage:SkipPage( n )
   LOCAL nCP := ::nCurrPage

   IF ::nNumPages > 0
      nCP += n

      IF nCP > ::nNumPages
         nCP := ::nNumPages

      ELSEIF nCP < 1
         nCP := 1

      ENDIF

      ::ShowPage(nCP)

   ENDIF
RETURN

// -------------------------------
// CLASSE S2MultiPage: multipagina
// -------------------------------
CLASS S2MultiPage FROM __MultiPage
PROTECTED:
   INLINE METHOD RecalcTabWidth(nNewPages)
      LOCAL nTabW
      LOCAL oTab

      DEFAULT nNewPages TO ::nNumPages
      nTabW := INT( 100 / MAX(nNewPages, 5) )

      IF nTabW <> ::nTabWidth
         ::nTabWidth := nTabW
         FOR nTabW := 1 TO ::nNumPages
            oTab := ::aPage[nTabW]
            oTab:preOffset  := ::nTabWidth * (nTabW-1)
            oTab:postOffset := 100 - (::nTabWidth * nTabW)
            oTab:Configure()
         NEXT
      ENDIF
   RETURN self

EXPORTED:
   METHOD addPage
   METHOD insPage
   METHOD delPage
   METHOD Create
   METHOD setSize
   METHOD setTabHeight
   METHOD currentSize
ENDCLASS

METHOD S2MultiPage:create()
   ::__MultiPage:create()
   AEVAL( ::aPage, {|oTab| oTab:Create()})
RETURN self

METHOD S2MultiPage:AddPage(cCaption, bCanMinimize, lRecalcTabWidth,bSelectCodeBlock)
//Mantis 320
//RETURN ::insPage(cCaption, bCanMinimize, ::nNumPages+1, lRecalcTabWidth)
RETURN ::insPage(cCaption, bCanMinimize, ::nNumPages+1, lRecalcTabWidth,bSelectCodeBlock)

//Mantis 320
//METHOD S2MultiPage:insPage(cCaption, bCanMinimize, nPos, lRecalcTabWidth  )
METHOD S2MultiPage:insPage(cCaption, bCanMinimize, nPos, lRecalcTabWidth,bSelectCodeBlock  )
   LOCAL oTab
   LOCAL aPos, aSize
   LOCAL nInd
   LOCAL nThisPage := 0

   DEFAULT lRecalcTabWidth TO .F.

   IF lRecalcTabWidth // Devo ricalcolare larghezza delle intestazioni?
      ::recalcTabWidth(::nNumPages+1)
   ENDIF

   IF ::nCurrPage > 0
      nThisPage := ::aPage[::nCurrPage]:nPage
   ENDIF

   aSize := ::oParent:currentSize()
   oTab := S2TabPage():new( ::oParent, NIL, aPos, aSize )

   oTab:caption    := cCaption
   oTab:nPage      := ::nNumPages+1

   //Mantis 320
   DEFAULT bSelectCodeBlock TO {||.T.}
   oTab:SetSelectCodeBlock(bSelectCodeBlock)

   // Assicuro che il numero di pagina sia univoco
   DO WHILE ::FindPageNumber(oTab:nPage) > 0
      oTab:nPage++
   ENDDO

   oTab:preOffset  := ::nTabWidth * (nPos-1)
   oTab:postOffset := 100 - (::nTabWidth * nPos)
   oTab:colorBG    := XBPSYSCLR_DIALOGBACKGROUND
   oTab:TabHeight  := ::TabHeight
   oTab:TabActivate := {|x1, x2, oTab| ::ActivatePage(oTab) }

   IF ! EMPTY(dfSet("XbaseMultiPageFont"))
      oTab:setFontCompoundName(dfFontCompoundNameNormalize(dfSet("XbaseMultiPageFont")))
   ENDIF

   IF ::tabHeight != 0
      aPos := {S2TABPAGE_OFFSET_LEFT, S2TABPAGE_OFFSET_BOTTOM}
      aSize[1] -= S2TABPAGE_OFFSET_RIGHT
      aSize[2] -= S2TABPAGE_OFFSET_TOP
   ENDIF

   oTab:drawingArea := XbpStatic():New(oTab, NIL, aPos, aSize)
   oTab:drawingArea:rbDown := ::oParent:rbDown

   oTab:bCanMinimize := bCanMinimize

   // oTab:drawingArea:type    := XBPSTATIC_TYPE_GROUPBOX
   AADD(::aPage, NIL)
   AINS(::aPage, nPos, oTab)

   ::nNumPages++

   // Sposto tutte le pagine successive
   FOR nInd := nPos+1 TO ::nNumPages
      ::aPage[nInd]:preOffset  := ::nTabWidth * (nInd-1)
      ::aPage[nInd]:postOffset := 100 - (::nTabWidth * nInd)
      ::aPage[nInd]:configure()
   NEXT
   IF nThisPage > 0
      ::nCurrPage := ::FindPageNumber(nThisPage)
   ENDIF

RETURN oTab

METHOD S2MultiPage:delPage(nPage, lRecalcTabWidth)
   LOCAL oTab
   LOCAL nCurr
   LOCAL nTabW
   LOCAL nThisPage

   DEFAULT lRecalcTabWidth TO .F.

   IF ::nNumPages > 1 .AND. nPage >= 1 .AND. nPage <= ::nNumPages

      // Se Š la pagina corrente seleziono pagina prec.
      nCurr := ::ActualPage()
      IF nPage == nCurr
         nCurr := nPage-1
         IF nCurr <= 0
            nCurr := nPage+1
         ENDIF
         ::ShowPage(nCurr)
      ENDIF

      nThisPage := ::aPage[::nCurrPage]:nPage

      // Cancello la pagina
      oTab:= ::aPage[nPage]
      ::nNumPages--
    #ifdef _XBASE18_
      AREMOVE(::aPage, nPage)
    #else
      ADEL(::aPage, nPage)
      ASIZE(::aPage, ::nNumPages)
    #endif

      oTab:destroy()

      // Reimposto la posizione per le pag. successive
      FOR nCurr := nPage TO ::nNumPages
        oTab := ::aPage[nCurr]
        oTab:preOffset  := ::nTabWidth * (nCurr-1)
        oTab:postOffset := 100 - (::nTabWidth * nCurr)
        oTab:configure()
      NEXT

      ::nCurrPage := ::FindPageNumber(nThisPage)

      IF lRecalcTabWidth // Devo ricalcolare larghezza delle intestazioni?
         ::recalcTabWidth()
      ENDIF

   ENDIF
RETURN self

METHOD S2MultiPage:setSize(aSz, l)
   LOCAL nCurr
   LOCAL oTab

   DEFAULT l TO .T.
   // Reimposto la posizione per le pag. successive
   FOR nCurr := 1 TO ::nNumPages
      oTab := ::aPage[nCurr]
      oTab:setSize(aSZ, l)
   NEXT
RETURN self

METHOD S2MultiPage:setTabHeight(nTabHeight)
   LOCAL oTab := ::getTab(1)
   IF ! EMPTY(oTab)
//   ::tabHeight := nTabHeight
//   IF oTab:tabHeight != nTabHeight
      oTab:tabHeight := nTabHeight
      oTab:configure()
      // Refresh TAB e drawingarea
      oTab:setSize(oTab:currentSize())
//   ENDIF
   ENDIF
RETURN self

METHOD S2MultiPage:currentSize()
   LOCAL oTab := ::getTab(1)
   LOCAL aSz := {0, 0}
   IF ! EMPTY(oTab)
      aSz := ACLONE( oTab:currentSize() )
   ENDIF
RETURN aSz

// -------------------------------
// CLASSE S2MultiPageX: multipagina
// -------------------------------
CLASS S2MultiPageX FROM __MultiPage
PROTECTED:
   VAR oMP

EXPORTED:
   METHOD Init
   METHOD Create
   METHOD destroy
   METHOD addPage
   METHOD insPage
   METHOD delPage
   METHOD setSize
   METHOD setTabHeight
   METHOD currentSize

   METHOD GetPageButton
ENDCLASS

METHOD S2MultiPageX:Init(oParent, nNumPages)
   LOCAL aSize
   aSize := oParent:currentSize()
   ::__MultiPage:Init(oParent, nNumPages)
   ::oMP := S2MultiPgX():new(oParent, NIL, NIL, aSize)
   ::oMP:lAutoActivatePage := .F.
   IF ! EMPTY(dfSet("XbaseMultiPageFont"))
      ::oMP:setSelectorFont(dfFontCompoundNameNormalize(dfSet("XbaseMultiPageFont")))
   ENDIF
   ::TabHeight := ::oMP:tabSelectorHeight // altezza per multipage stile FLAT
RETURN self

METHOD S2MultiPageX:create()
   // simone d. 16/1/07 correzione per gestione altezza 0
   IF ::tabHeight != ::oMP:tabSelectorHeight
      ::setTabHeight(::tabHeight)
   ENDIF

   ::__MultiPage:create()
   ::oMP:create()
RETURN self

METHOD S2MultiPageX:destroy()
   ::oMP:destroy()
//   ::oMP := NIL
RETURN self

METHOD S2MultiPageX:currentSize()
RETURN ::oMP:currentSize()

METHOD S2MultiPageX:AddPage(cCaption, bCanMinimize, lRecalcTabWidth,bSelectCodeBlock)
//Mantis 320
//RETURN ::insPage(cCaption, bCanMinimize, ::nNumPages+1, lRecalcTabWidth)
RETURN ::insPage(cCaption, bCanMinimize, ::nNumPages+1, lRecalcTabWidth,bSelectCodeBlock)

//Mantis 320
//METHOD S2MultiPage:insPage(cCaption, bCanMinimize, nPos, lRecalcTabWidth  )
METHOD S2MultiPageX:insPage(cCaption, bCanMinimize, nPos, lRecalcTabWidth,bSelectCodeBlock  )
   LOCAL oTab
   LOCAL aPos, aSize
   LOCAL nInd
   LOCAL nThisPage := 0

   IF ::nCurrPage > 0
      nThisPage := ::aPage[::nCurrPage]:nPage
   ENDIF

   aSize := ::oParent:currentSize()
   oTab := ::oMP:insPage(cCaption, NIL, nPos, TabPageX())

   oTab:nPage      := ::nNumPages+1
   oTab:caption    := cCaption

   //Mantis 320
   DEFAULT bSelectCodeBlock TO {||.T.}
   oTab:SetSelectCodeBlock(bSelectCodeBlock)

   // Assicuro che il numero di pagina sia univoco
   DO WHILE ::FindPageNumber(oTab:nPage) > 0
      oTab:nPage++
   ENDDO

//   oTab:preOffset  := ::nTabWidth * (nPos-1)
//   oTab:postOffset := 100 - (::nTabWidth * nPos)
//   oTab:colorBG    := XBPSYSCLR_DIALOGBACKGROUND
//   oTab:TabHeight  := ::TabHeight
   oTab:TabActivate := {|x1, x2, oTab| ::ActivatePage(oTab) }
//   oTab:Activate := {|x1, x2, oTab| ::ActivatePage(oTab) }

   IF ::tabHeight != 0
      aPos := {S2TABPAGE_OFFSET_LEFT, S2TABPAGE_OFFSET_BOTTOM}
      aSize[1] -= S2TABPAGE_OFFSET_RIGHT
      aSize[2] -= S2TABPAGE_OFFSET_TOP
   ENDIF

//   oTab:drawingArea := XbpStatic():New(oTab, NIL, aPos, aSize)
//   oTab:drawingArea:rbDown := ::oParent:rbDown
   oTab:rbDown := ::oParent:rbDown

   oTab:bCanMinimize := bCanMinimize

   // oTab:drawingArea:type    := XBPSTATIC_TYPE_GROUPBOX
   AADD(::aPage, NIL)
   AINS(::aPage, nPos, oTab)

   ::nNumPages++

   // Sposto tutte le pagine successive
//   FOR nInd := nPos+1 TO ::nNumPages
//      ::aPage[nInd]:preOffset  := ::nTabWidth * (nInd-1)
//      ::aPage[nInd]:postOffset := 100 - (::nTabWidth * nInd)
//      ::aPage[nInd]:configure()
//   NEXT
   IF nThisPage > 0
      ::nCurrPage := ::FindPageNumber(nThisPage)
   ENDIF

RETURN oTab

METHOD S2MultiPageX:delPage(nPage, lRecalcTabWidth)
   LOCAL oTab
   LOCAL nCurr
   LOCAL nTabW
   LOCAL nThisPage

   DEFAULT lRecalcTabWidth TO .F.

   IF ::nNumPages > 1 .AND. nPage >= 1 .AND. nPage <= ::nNumPages

      // Se Š la pagina corrente seleziono pagina prec.
      nCurr := ::ActualPage()
      IF nPage == nCurr
         nCurr := nPage-1
         IF nCurr <= 0
            nCurr := nPage+1
         ENDIF
         ::ShowPage(nCurr)
      ENDIF

      nThisPage := ::aPage[::nCurrPage]:nPage

      // Cancello la pagina
      oTab:= ::aPage[nPage]
      ::nNumPages--
    #ifdef _XBASE18_
      AREMOVE(::aPage, nPage)
    #else
      ADEL(::aPage, nPage)
      ASIZE(::aPage, ::nNumPages)
    #endif

//      oTab:destroy()
      ::oMP:delPage(oTab)
      // Reimposto la posizione per le pag. successive
//      FOR nCurr := nPage TO ::nNumPages
//        oTab := ::aPage[nCurr]
//        oTab:preOffset  := ::nTabWidth * (nCurr-1)
//        oTab:postOffset := 100 - (::nTabWidth * nCurr)
//        oTab:configure()
//      NEXT

      ::nCurrPage := ::FindPageNumber(nThisPage)

   ENDIF
RETURN self

METHOD S2MultiPageX:setSize(aSz, l)
   DEFAULT l TO .T.
   ::oMP:setSize(aSZ, l)
RETURN self

METHOD S2MultiPageX:setTabHeight(nTabHeight)
//   ::tabHeight := nTabHeight
//   IF oTab:tabHeight != nTabHeight
   ::oMP:setSelectorHeight(nTabHeight)
//   ENDIF
RETURN self

//Inserito Luca il 16/10/2006
METHOD S2MultiPageX:GetPageButton(nPage)
   LOCAL oButt
   IF nPage >0 .AND. nPage <= ::nNumPages
      oButt := ::oMP:GetPageButton(nPage)
   ENDIF
RETURN oButt
