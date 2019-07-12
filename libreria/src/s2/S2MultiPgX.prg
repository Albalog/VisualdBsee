// -----------------------------
// Template per nuovo Xbase Part
// -----------------------------
#include "Common.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "AppEvent.ch"
#include "dfStd.ch"

#define PAGE_LABEL_HEIGHT    26

// Nome della classe
#define _THISXBP_NAME  S2MultiPgX

// Eredita da
#define _THISXBP_SUPER XbpStatic

#ifdef _TEST_
   PROCEDURE Main()
      LOCAL oXbp 

      oXbp := _THISXBP_NAME():New(NIL, NIL, {20, 50}, {80, 160})
      oXbp:caption := "test"
      oXbp:Create()
      Inkey(0)

   RETURN 
#endif


CLASS _THISXBP_NAME FROM _THISXBP_SUPER
   PROTECTED: 
      VAR aPages
      VAR nCurrent
      VAR oPageSelector
      METHOD arrangePos
      METHOD calcPageSize

   EXPORTED:
      VAR TabSelectorHeight
      VAR lAutoActivatePage

      METHOD Init
      METHOD Create
      METHOD Destroy

      METHOD setSize           // aggiunta gestione minSize e maxSize
      METHOD SetPosAndSize
//      METHOD setCaption
      METHOD getNumPages
      METHOD getCurPage
      METHOD setCurPage
      METHOD insPage
      METHOD delPage
      METHOD activatePage
      METHOD selectPage
      METHOD setSelectorFont
      METHOD setSelectorHeight
      METHOD setSelectorCaption

      METHOD GetPageButton
ENDCLASS

METHOD _THISXBP_NAME:GetPageButton(nN)
  LOCAL oButt
  IF nN> 0 .AND. nN<= LEN(::aPages)
     oButt := ::aPages[nN][2]
  ENDIF
RETURN oButt 

METHOD _THISXBP_NAME:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::_THISXBP_SUPER:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::TabSelectorHeight := PAGE_LABEL_HEIGHT
   ::aPages    := {}
   ::oPageSelector := S2TabPageSelector():new(self)
   ::nCurrent  := 0
   ::lAutoActivatePage := .T.
RETURN self

METHOD _THISXBP_NAME:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL n

   DEFAULT lVisible TO .T.

   ::_THISXBP_SUPER:Create( oParent, oOwner, aPos, aSize, aPP, .F. )
   ::oPageSelector:Create()

   FOR n := 1 TO LEN(::aPages)
      ::aPages[n][1]:create()
   NEXT
   ::arrangePos()
   n := ::getCurPage()
   IF n != 0
      ::selectPage(n)
   ENDIF

   IF lVisible
      ::show()
   ENDIF
RETURN self

METHOD _THISXBP_NAME:arrangePos()
   LOCAL aPos
   LOCAL aSize
   LOCAL n

   aSize := ::currentSize()
   
   aPos := {0,aSize[2]-::TabSelectorHeight}

   aSize[2] := ::TabSelectorHeight
   ::oPageSelector:setPosAndSize(aPos, aSize)
   n:= ::getCurPage() 
   IF n != 0
      ::aPages[n][1]:setSize( ::calcPageSize() )
   ENDIF
RETURN self

METHOD _THISXBP_NAME:calcPageSize()
   LOCAL aSize
   aSize := ::currentSize()
   aSize[2] -= ::TabSelectorHeight
RETURN aSize

METHOD _THISXBP_NAME:Destroy()
//   ASIZE(::aPages, 0)
   ::_THISXBP_SUPER:Destroy()
RETURN self

METHOD _THISXBP_NAME:insPage(cCaption, xImage, nPos, oClass)
   LOCAL oPage
   LOCAL oSelector

   DEFAULT nPos TO ::GetNumPages()+1
   DEFAULT oClass TO S2TabPageX()

   oPage:= oClass:new(self, NIL, {0, 0}, ::calcPageSize(), NIL, .F.)

   IF ::status() == XBP_STAT_CREATE
      oPage:create()
   ENDIF

   oSelector := ::oPageSelector:insSelector(cCaption, xImage, nPos)
   oSelector:activate := {|mp1, mp2, o| ::activatePage(o) }

   AADD(::aPages, {oPage, oSelector}, nPos)
     
//   oSelector:cargo    := nPos

   IF ::status() == XBP_STAT_CREATE .AND. ::getCurPage() != 0 
      ::selectPage(::getCurPage())
   ENDIF
RETURN oPage

METHOD _THISXBP_NAME:delPage(xPage)
   LOCAL oPage
   LOCAL n := 0

   LOCAL lRet := .F.
   IF VALTYPE(xPage) == "N" 
      n:= xPage
      oPage := ::aPages[n][1]
   ELSE
      FOR n := 1 TO LEN(::aPages)
         IF ::aPages[n][1] == xPage
            oPage := xPage
            EXIT
         ENDIF
      NEXT
   ENDIF

   IF oPage != NIL
      DFAERASE(::aPages, n)
      IF ::status() == XBP_STAT_CREATE
         oPage:destroy()
      ENDIF
      ::oPageSelector:delSelector(n)
   ENDIF
RETURN lRet


METHOD _THISXBP_NAME:activatePage(oSel)
   LOCAL lOK := .T.
   LOCAL n
   LOCAL nPrev
   LOCAL oPG
   LOCAL b

//   n:= o:cargo
//   IF n>0 .AND. n <= ::getNumPages()
//      ::selectPage(o)
//   ENDIF

   // trova pagina associata ad un "selettore" (pulsante)
   FOR n := 1 TO LEN(::aPages)
      IF ::aPages[n][2]==oSel
         oPG := ::aPages[n][1]
         EXIT
      ENDIF
   NEXT

   nPrev := ::getCurPage()

   IF ::lAutoActivatePage
      lOK:= ::selectPage(oPG)
   ENDIF

   n:= ::getCurPage()
   IF ! EMPTY( n )
      b := ::aPages[n][1]:TabActivate
      IF VALTYPE(b) == "B"
         EVAL(b, nPrev, n, oPg)
      ENDIF
      // eventualmente ripristina il pulsante sulla pagina precedentemente selezionata
      ::oPageSelector:pressSelector( ::getCurPage() )
   ENDIF
RETURN self

METHOD _THISXBP_NAME:selectPage(n)
   LOCAL nOld
   LOCAL lRet := .F.
   LOCAL nN
   LOCAL aOBJ, oOBJ

   IF VALTYPE(n) == "O"
      FOR nOld := 1 TO LEN(::aPages)
         IF ::aPages[nOld][1]==n
            n:=nOld
            EXIT
         ENDIF
      NEXT
   ENDIF

   IF n>0 .AND. n <= ::getNumPages() 
      lRet := .T.
//      ::lockUpdate( .T. )
      nOld := ::getCurPage()
      IF nOld != 0
         ::aPages[ nOld ][1]:hide()
      ENDIF

      ::oPageSelector:pressSelector(n)
      ::setCurPage(n)


       //////////////////////////////////////////////////////////
       //Correzione Colore di sfondo checkbox
       //////////////////////////////////////////////////////////
       IF VALTYPE(S2FormCurr())=="O" .AND. IsMethod( S2FormCurr(),"getObjCtrl")

          aOBJ   := S2FormCurr():getObjCtrl()
          FOR nN := 1 TO LEN(aOBJ)
            oOBJ := aObj[nN] 

            IF oOBJ:isDerivedFrom("S2CheckBox") 
               IF oOBJ:nPage == N  .OR. oOBJ:nPage == 0//Cansetpage()
                  oOBJ:lUno  := .T.
               ENDIF   
            ENDIF 
          NEXT 
       ENDIF 
       //////////////////////////////////////////////////////////
       //////////////////////////////////////////////////////////

      ::aPages[n][1]:setSize( ::calcPageSize(), .F. )
      ::aPages[n][1]:show()
//      ::lockUpdate( .F. )
//      ::invalidateRect()

   ENDIF
RETURN lRet

METHOD _THISXBP_NAME:getNumPages()
RETURN LEN(::aPages)

METHOD _THISXBP_NAME:setCurPage(n)
   LOCAL lRet := .F.
   IF n > 0 .AND. n <= ::getNumPages()
      ::nCurrent := n
      lRet := .T.
   ENDIF
RETURN lRet

METHOD _THISXBP_NAME:getCurPage()
   LOCAL n := ::nCurrent
   IF n <= 0
      IF ::getNumPages() > 0
         n:= 1
      ELSE
         n:= 0
      ENDIF
   ELSE
      IF n > ::getNumPages()
         n := ::getNumPages()
      ENDIF
   ENDIF
RETURN n

METHOD _THISXBP_NAME:setSelectorFont(cFont)
RETURN ::oPageSelector:setFontCompoundName(cFont)

METHOD _THISXBP_NAME:setSelectorHeight(nHeight)
   IF VALTYPE(nHeight) == "N"
      ::TabSelectorHeight := nHeight
      ::arrangePos()
   ENDIF
RETURN self

METHOD _THISXBP_NAME:setSelectorCaption(n, cCaption)
   LOCAL oSel
   LOCAL nOld

   IF VALTYPE(n) == "O"
      FOR nOld := 1 TO LEN(::aPages)
         IF ::aPages[nOld][1]==n
            n:=nOld
            EXIT
         ENDIF
      NEXT
   ENDIF

   IF VALTYPE(n) == "N" .AND. VALTYPE(cCaption) $ "CM" 
      oSel := ::oPageSelector:getSelector(n)
      IF ! EMPTY(oSel)
         oSel:setCaption(cCaption)
         ::arrangePos()
      ENDIF
   ENDIF              
RETURN self


//METHOD _THISXBP_NAME:setCaption(c)
//   ::caption := c
//RETURN .T.

METHOD _THISXBP_NAME:setSize(aSize, lUpdate)
   LOCAL nX:=0
   LOCAL nY:=0
   LOCAL nMaxX:=NIL
   LOCAL nMaxY:=NIL
   LOCAL lRet
   LOCAL aOld := ::currentSize()

   DEFAULT lUpdate TO .T.

   lRet := ::_THISXBP_SUPER:SetSize(aSize, .F.)
   ::arrangePos()
   IF lUpdate
      ::invalidateRect()
   ENDIF
RETURN lRet

METHOD _THISXBP_NAME:setPosAndSize(aPos, aSize, lUpdate)
   LOCAL lRet1,lRet2
   DEFAULT lUpdate TO .T.

   lRet1 := ::SetPos(aPos, .F.)
   lRet2 := ::SetSize(aSize, .F.)

   IF lUpdate
      ::invalidateRect()
   ENDIF

RETURN lRet1 .AND. lRet2
//
//METHOD _THISXBP_NAME:resizeControls(aOld, aNew, lLock)
//RETURN self

#undef _THISXBP_NAME
#undef _THISXBP_SUPER

// Nome della classe
#define _THISXBP_NAME  S2TabPageSelector

// Eredita da
#define _THISXBP_SUPER XbpStatic


CLASS _THISXBP_NAME FROM _THISXBP_SUPER
   PROTECTED: 
      VAR oLine
      VAR aSelectors
      VAR aSeparators
      METHOD arrangeSelectors
      METHOD insSeparator

   EXPORTED:
      METHOD Init
      METHOD Create
      METHOD destroy
      METHOD insSelector
      METHOD delSelector
      METHOD getNumSelectors
      METHOD getSelector
      METHOD setSize           // aggiunta gestione minSize e maxSize
      METHOD SetPosAndSize
      METHOD pressSelector
ENDCLASS

METHOD _THISXBP_NAME:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::_THISXBP_SUPER:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   
   // simone 9/3/06
   // mantis 0000999: nei multipage in stile flat aggiungere una riga orizzontale di separazione dalla pagina
   ::oLine := XbpStatic():new(self)
   //::oLine:type :=XBPSTATIC_TYPE_RECESSEDLINE  
   ::oLine:type :=XBPSTATIC_TYPE_RAISEDLINE  

   ::aSelectors := {}
   ::aSeparators:= {}
RETURN self

METHOD _THISXBP_NAME:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL n

   DEFAULT lVisible TO .T.

   ::_THISXBP_SUPER:Create( oParent, oOwner, aPos, aSize, aPP, .F. )
   FOR n := 1 TO LEN(::aSelectors)
      ::aSelectors[n]:create(self)
   NEXT
   ::arrangeSelectors()

   // linea di separazione
   ::oLine:create(NIL, NIL, {0, 0}, {::currentSize()[1], 0})

   IF lVisible
      ::show()
   ENDIF
RETURN self


METHOD _THISXBP_NAME:destroy()
//   ASIZE( ::aSeparators, 0)
//   ASIZE( ::aSelectors, 0)
   ::_THISXBP_SUPER:destroy()
RETURN self

METHOD _THISXBP_NAME:insSelector(cCaption, xImage, nPos, aSize)
   LOCAL oSelector

   DEFAULT nPos TO ::GetNumSelectors()+1

   oSelector:= S2ButtonX():new(self, NIL, NIL, aSize)
   oSelector:setFontCompoundName( ::setFontCompoundName() )
   oSelector:caption:= cCaption
   oSelector:Image := xImage
   oSelector:side  := .T.
   oSelector:autoSize := (aSize == NIL)
   oSelector:style := 1
   oSelector:tabStop := .F.
   oSelector:UpOnClick := .F.
   oSelector:onFocusStyle := XBPSTATIC_TYPE_TEXT

   AADD(::aSelectors, oSelector, nPos)

   IF ::status() == XBP_STAT_CREATE
      oSelector:create()
      ::arrangeSelectors()
   ENDIF
RETURN oSelector

METHOD _THISXBP_NAME:delSelector(xSelector)
   LOCAL oSelector
   LOCAL n := 0

   LOCAL lRet := .F.
   IF VALTYPE(xSelector) == "N" 
      n:= xSelector
      oSelector := ::aSelectors[n]
   ELSE
      FOR n := 1 TO LEN(::aSelectors)
         IF ::aSelectors[n] == xSelector
            oSelector := xSelector
            EXIT
         ENDIF
      NEXT
   ENDIF

   IF oSelector != NIL
      DFAERASE(::aSelectors, n)
      IF ::status() == XBP_STAT_CREATE
         oSelector:destroy()
         ::arrangeSelectors()
      ENDIF
   ENDIF
RETURN lRet

METHOD _THISXBP_NAME:insSeparator(aPos)
   LOCAL oXbp
   LOCAL aSize
   aSize := ::currentSize()
   aSize[1] := 2
   aSize[2] -= aPos[2] * 2 // offset verticale
   oXbp := XbpStatic():new(self, NIL, aPos, aSize)
   oXbp:type := XBPSTATIC_TYPE_RECESSEDRECT

   AADD(::aSeparators, oXbp)
   IF ::status() == XBP_STAT_CREATE
      oXbp:create()
   ENDIF
RETURN self

METHOD _THISXBP_NAME:pressSelector(xSel)
   LOCAL n
   LOCAL o
   IF VALTYPE(xSel) == "O"
      o := xSel
   ELSE
      o := ::aSelectors[xSel]
   ENDIF

   FOR n := 1 TO LEN(::aSelectors)
      IF ::aSelectors[n] == o
         ::aSelectors[n]:press( .F. )
      ELSE
         ::aSelectors[n]:press( .T. )
      ENDIF
   NEXT
RETURN self

METHOD _THISXBP_NAME:arrangeSelectors()
   LOCAL oSelector
   LOCAL aSel 
   LOCAL n
   LOCAL nX
   LOCAL nY
   LOCAL aPos

   nX := 2 // offset iniziale
   nY := 2 // offset iniziale
//   ::lockUpdate( .F. )

   // Cancella separatori
   aSel := ::aSeparators
   FOR n := 1 TO LEN(aSel)
      IF aSel[n]:status() == XBP_STAT_CREATE
         aSel[n]:destroy()
      ENDIF
   NEXT
   ASIZE(aSel, 0)

   // ricalcola coordinate pulsanti
   aSel := ::aSelectors
   FOR n := 1 TO LEN(aSel)
      aPos := aSel[n]:currentPos()
      IF nX != aPos[1] .OR. nY != aPos[2]
         aPos[1] := nX
         aPos[2] := nY
         aSel[n]:setPos(aPos, .F.)
      ENDIF
      nX += aSel[n]:currentSize()[1] + 4 // offset
      IF LEN(aSel) > 1 .AND. n < LEN(aSel)
         ::insSeparator({nX, nY})
         nX += 4
      ENDIF
   NEXT
//   ::lockUpdate( .T. )
   ::invalidateRect()
RETURN .T.

METHOD _THISXBP_NAME:getNumSelectors()
RETURN LEN(::aSelectors)

METHOD _THISXBP_NAME:getSelector(n)
RETURN IIF(n>0 .AND. n <= ::getNumSelectors(), ::aSelectors[n], NIL)

METHOD _THISXBP_NAME:setSize(aSize, lUpdate)
   LOCAL nX:=0
   LOCAL nY:=0
   LOCAL nMaxX:=NIL
   LOCAL nMaxY:=NIL
   LOCAL lRet
   LOCAL aOld := ::currentSize()

   DEFAULT lUpdate TO .T.

   lRet := ::_THISXBP_SUPER:SetSize(aSize, .F.)
   ::arrangeSelectors()

   ::oLine:setSize({aSize[1], ::oLine:currentSize()[2]}, .F.)

   IF lUpdate
      ::invalidateRect()
   ENDIF
RETURN lRet

METHOD _THISXBP_NAME:setPosAndSize(aPos, aSize, lUpdate)
   LOCAL lRet1,lRet2
   DEFAULT lUpdate TO .T.

   lRet1 := ::SetPos(aPos, .F.)
   lRet2 := ::SetSize(aSize, .F.)

   IF lUpdate
      ::invalidateRect()
   ENDIF

RETURN lRet1 .AND. lRet2

#undef _THISXBP_NAME
#undef _THISXBP_SUPER


// Nome della classe
#define _THISXBP_NAME  S2TabPageX

// Eredita da
#define _THISXBP_SUPER XbpStatic


CLASS _THISXBP_NAME FROM _THISXBP_SUPER
   PROTECTED: 
   EXPORTED:
      METHOD init
      VAR TabActivate
ENDCLASS

METHOD _THISXBP_NAME:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::_THISXBP_SUPER:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
RETURN self

#undef _THISXBP_NAME
#undef _THISXBP_SUPER
