// -----------------------------------------------
// Classe XbpInset per gestione a schede verticali
// Tipo Barra a sx di outlook
// -----------------------------------------------

#include "Common.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "AppEvent.ch"

// Nome della classe
#define _THISXBP_NAME  XbpInset

// Eredita da
#define _THISXBP_SUPER XbpStatic

#ifdef _TEST_
PROCEDURE Main()
   LOCAL oXbp 
   LOCAL oDlg

   oDlg := XbpDialog():new(AppDesktop(), NIL, {10, 100}, {300, 300})
   oDlg:sysmenu := .T.
   oDlg:taskList:= .T.
   oDlg:title := "test"
   oDlg:drawingArea:resize := {|o, n| oXbp:setPos({0, 0}), oXbp:setSize(n)}
   oDlg:create()

   oXbp := _THISXBP_NAME():New(oDlg:drawingarea, NIL, {20, 50}, {80, 160})
//   oXbp:caption := "test"
   oXbp:setColorBG(GRA_CLR_WHITE)
   oXbp:Create()

   oXbp:addInset("pippo")
   oXbp:getInset(1):setCaption("aaa")

   oXbp:addInset("pluto")
   oXbp:getInset(2):setCaption("bbb")

   oXbp:addInset("paperino")
   oXbp:getInset(3):setCaption("ccc")

   oXbp:addInset("tizio"):setCaption("ddd")
   oXbp:addInset("caio"):setCaption("eee")
   oXbp:addInset("sempronio"):setCaption("fff")

   oxbp:setpos({0, 0})
   oxbp:selectinset(3)
   oxbp:setsize({80,200})

   Inkey(0)
                        
RETURN 
#endif

CLASS _THISXBP_NAME FROM _THISXBP_SUPER
   PROTECTED:
      VAR aInsets
      VAR maxHeight
      VAR current

   EXPORTED:
      VAR border
      VAR lScroll

      METHOD Init
      METHOD Create
      METHOD Destroy

      METHOD AddInset
      METHOD SelectInset
      METHOD SetSize
      METHOD FindInset      // Cerca una pagina per Name

      INLINE METHOD NumInsets(); RETURN LEN(::aInsets)

      INLINE METHOD GetInset(n)
      RETURN IIF(n >= 1 .AND. n <= LEN(::aInsets), ::aInsets[n], NIL)

      INLINE METHOD ScrollInset(n, lScroll)
         DEFAULT lScroll TO ::lScroll
         ::selectInset(n, lScroll)
      RETURN self

      INLINE METHOD SetPosAndSize(x, y, lShow)
         DEFAULT lShow TO .T.
         ::lockupdate(.T.)
         ::SetPos(x)
         ::SetSize(y)
         ::lockupdate(.F.)
         IF lShow
            ::invalidateRect()
         ENDIF
      RETURN self


ENDCLASS

METHOD _THISXBP_NAME:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::_THISXBP_SUPER:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::aInsets := {}
   ::current := 0
   ::maxHeight := 0
   ::border   := 0
   ::type := XBPSTATIC_TYPE_BGNDFRAME
   ::lScroll := .F. // abilita scroll
RETURN self

METHOD _THISXBP_NAME:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::_THISXBP_SUPER:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::maxHeight := ::currentSize()[2]
RETURN self

METHOD _THISXBP_NAME:Destroy()
   ::_THISXBP_SUPER:Destroy()
   ASIZE(::aInsets, 0)
   ::current := 0
   ::maxHeight := 0
RETURN self

// By reference torna il numero 
METHOD _THISXBP_NAME:FindInset(cName, n)
   LOCAL oXbp

   n := ASCAN(::aInsets, {|o|o:Name == cName})

   IF n > 0
      oXbp := ::getInset(n)
   ENDIF
RETURN oXbp   

METHOD _THISXBP_NAME:SetSize(aSize, l)
   LOCAL nInd
   LOCAL oXbp
   LOCAL nDiff := aSize[2] - ::currentSize()[2] 

   IF ::maxHeight + nDiff < 0 
      RETURN .F.
   ENDIF

   DEFAULT l TO .T.

   ::lockUpdate(.T.)

   ::maxHeight += nDiff

   ::_THISXBP_SUPER:SetSize(aSize, .F.)

   FOR nInd := 1 TO LEN(::aInsets)
      oXbp := ::aInsets[nInd]
      oXbp:setSize({aSize[1]-2*::border, oXbp:currentSize()[2]+nDiff}, .F.)
      IF nInd > ::current
         oXbp:setPos({oXbp:currentPos()[1], oXbp:currentPos()[2]-nDiff}, .F.)
      ENDIF
   NEXT

   ::lockUpdate(.F.)
   IF l
      ::invalidateRect()
   ENDIF
RETURN .T.

METHOD _THISXBP_NAME:AddInset(cCaption, nBtnHeight, cName)
   LOCAL oXbp
   LOCAL nInd
   LOCAL nDiff
   IF ::maxHeight <= 0
      RETURN NIL
   ENDIF

   DEFAULT cCaption TO ""
   DEFAULT nBtnHeight TO 20

   IF LEN(::aInsets) > 0
      // Ricalcolo le dimensioni dei control presenti
      nDiff := ATAIL(::aInsets):btnHeight
      FOR nInd := 1 TO LEN(::aInsets)
         oXbp := ::aInsets[nInd]
         oXbp:hide() // non nasconde il pulsante!
         oXbp:setSize({::currentSize()[1]-2*::border, ::maxHeight})
         oXbp:setPos({::border, oXbp:currentPos()[2]+nDiff})
      NEXT
   ENDIF

//   IF VALTYPE(cCaption) == "O"
//      oXbp:=cCaption
//      oXbp:setParent(self)
//      oXbp:setOwner(self)
//      oXbp:setPosAndSize({0, 0}, {::currentSize()[1], ::maxHeight})
//   ELSE
      oXbp := XbpSingleInset():new()
      oXbp:btnHeight := nBtnHeight
      oXbp:create(self, self, {::border, 0}, {::currentSize()[1]-2*::border, ::maxHeight})
      oXbp:setTitle(cCaption)
      IF cName != NIL
         oXbp:Name := cName
      ENDIF
//   ENDIF

   ::maxHeight -= oXbp:btnHeight

   AADD(::aInsets, oXbp)
   ::current++

RETURN oXbp

METHOD _THISXBP_NAME:SelectInset(n, lScroll)
   LOCAL oXbp
   LOCAL nInd
   LOCAL nHeight 
   LOCAL aPos, aSize
   LOCAL nInd2
   LOCAL nOld
   LOCAL nStep

   DEFAULT lScroll TO .F.

   IF VALTYPE(n) == "O"
      oXbp := n
      n:= ASCAN(::aInsets, oXbp) 

   ELSEIF VALTYPE(n) == "N"
      oXbp := ::getInset(n)      // Cerco per numero

   ELSEIF VALTYPE(n) == "C"      // Cerco per Nome
      oXbp := ::FindInset(n, @nInd)
      n := nInd
      nInd := NIL

   ELSE
      n:=0
   ENDIF

   IF n == 0 .OR. EMPTY(oXbp) .OR. n == ::current
      RETURN self
   ENDIF

   nHeight := ::maxHeight  // Spazio rimanente

IF lScroll
   // simone 4/7/2005
   // in caso di scroll fa un po schifo, Š da finire..
   nOld := ::current
   ::aInsets[n]:show()

   IF n < ::current

      nInd2 := 0
      DO WHILE nInd2 <= nHeight

         nStep := INT(nHeight/15)

         nInd2 += nStep
         IF nInd2 > nHeight
            nStep -= nInd2-nHeight
         ENDIF

         // Sposto verso il basso
         FOR nInd := n+1 TO ::current 
            aPos := ::aInsets[nInd]:currentPos()
            aPos[2] -= nStep
            ::aInsets[nInd]:setPos(aPos, .T.)
         NEXT
         //sleep(10)
      ENDDO

   ELSE

      nInd2 := 0
      DO WHILE nInd2 <= nHeight

         nStep := INT(nHeight/15)

         nInd2 += nStep
         IF nInd2 > nHeight
            nStep -= nInd2-nHeight
         ENDIF

         // Sposto verso l'alto
         FOR nInd := ::current+1 TO n
            aPos := ::aInsets[nInd]:currentPos()
            aPos[2] += nStep
            ::aInsets[nInd]:setPos(aPos, .T.)
         NEXT

         //sleep(10)
      ENDDO

   ENDIF

   ::current := n
   ::aInsets[nOld]:hide()
ELSE
   ::lockUpdate(.T.)
   ::aInsets[::current]:hide()

   IF n < ::current
      // Sposto verso il basso
      FOR nInd := n+1 TO ::current 
         aPos := ::aInsets[nInd]:currentPos()
         aPos[2] -= nHeight
         ::aInsets[nInd]:setPos(aPos)
      NEXT

   ELSE

      // Sposto verso l'alto
      FOR nInd := ::current+1 TO n
         aPos := ::aInsets[nInd]:currentPos()
         aPos[2] += nHeight
         ::aInsets[nInd]:setPos(aPos)
      NEXT

   ENDIF

   ::current := n
   ::aInsets[::current]:show()
   ::lockUpdate(.F.)
   //   ::invalidateRect()
ENDIF

   
   // simone 23/09/04 
   // mantis 188
   aPos := ::currentPos()
   aSize := ::currentSize()
   aPos[2]++
   aSize[2]--
   ::setPosAndSize(aPos, aSize, .F.)

   aPos[2]--
   aSize[2]++
   ::setPosAndSize(aPos, aSize, .T.)

RETURN self


#undef _THISXBP_NAME
#undef _THISXBP_SUPER





// Nome della classe
#define _THISXBP_NAME  XbpSingleInset

// Eredita da
#define _THISXBP_SUPER XbpStatic


STATIC CLASS _THISXBP_NAME FROM _THISXBP_SUPER
   PROTECTED: 
      VAR oBtn

      METHOD AdjustSize  // Ritorna la dim. dello static in base al pulsante
      METHOD BtnPos      // Ritorna la pos. del pulsante in base allo static
      METHOD BtnSize     // Ritorna la dim. del pulsante in base allo static

   EXPORTED:
      VAR btnHeight      // Altezza del pulsante
      VAR Name           // Nome della pagina

      METHOD Init
      METHOD Create
      METHOD Destroy
      METHOD SetTitle    // Imposta il testo del pulsante
      METHOD SetPos
      METHOD SetSize
      METHOD currentSize
      METHOD getButton
ENDCLASS

METHOD _THISXBP_NAME:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::_THISXBP_SUPER:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::btnHeight := 20
   ::oBtn := XbpPushButton():new(oParent, oOwner, ::BtnPos(aPos, aSize), ::BtnSize(aSize))
   ::oBtn:activate := {|| ::setParent():ScrollInset(self) }
   ::oBtn:pointerFocus := .F.
   ::Name := NIL
RETURN self

METHOD _THISXBP_NAME:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::_THISXBP_SUPER:Create( oParent, oOwner, aPos, aSize, aPP, .F. )
   ::oBtn:Create(oParent, oOwner) //, ::BtnPos(aPos, aSize), ::BtnSize(aSize))
   ::setSize( ::_THISXBP_SUPER:currentSize() )
   //::_THISXBP_SUPER:setSize( ::AdjustSize(::_THISXBP_SUPER:currentSize()) )

   IF lVisible != .F.
      ::show()
   ENDIF
   
RETURN self

METHOD _THISXBP_NAME:Destroy()
   ::_THISXBP_SUPER:Destroy()
   ::oBtn := NIL
RETURN self

METHOD _THISXBP_NAME:getButton()
RETURN ::oBtn

METHOD _THISXBP_NAME:currentSize(lTotal)
   LOCAL aRet := ::_THISXBP_SUPER:currentSize()
   DEFAULT lTotal TO .T.
   IF lTotal
      aRet[2] += ::btnHeight
   ENDIF
RETURN aRet


METHOD _THISXBP_NAME:SetPos(aPos, l)
   DEFAULT l TO .F.
   ::lockUpdate(.T.)

   ::_THISXBP_SUPER:SetPos(aPos, .F.)
   aPos := {aPos[1], ;
            aPos[2]+::_THISXBP_SUPER:currentSize()[2] }
   ::oBtn:SetPos(aPos, .F.)
   // Refresh altrimenti non viene visualizzato bene
   ::lockUpdate(.F.)
   IF l
      ::invalidateRect()
   ENDIF
//   ::oBtn:invalidateRect()
RETURN self

METHOD _THISXBP_NAME:SetSize(aSize, l)
   DEFAULT l TO .F.
   ::lockUpdate(.T.)
   ::_THISXBP_SUPER:SetSize( ::AdjustSize(aSize), .F. )
   ::oBtn:SetPosAndSize(::BtnPos(::currentPos(), aSize), ::BtnSize(aSize), .F.)
   ::lockUpdate(.F.)
   IF l
      ::invalidateRect()
   ENDIF
RETURN self

METHOD _THISXBP_NAME:SetTitle(cCaption)
   IF cCaption != NIL
      ::oBtn:setCaption(cCaption)
   ENDIF
RETURN ::oBtn:caption

METHOD _THISXBP_NAME:AdjustSize(aSize)
   IF aSize == NIL
      RETURN NIL
   ENDIF
RETURN {aSize[1], aSize[2] - ::btnHeight}

METHOD _THISXBP_NAME:BtnPos(aPos, aSize)
   DEFAULT aPos TO {0, 0}

   IF aSize != NIL
      aPos := {aPos[1], aPos[2]+aSize[2]-::btnHeight}
   ENDIF
RETURN aPos

METHOD _THISXBP_NAME:BtnSize(aSize)
   IF aSize != NIL
      aSize := {aSize[1], ::btnHeight}
   ENDIF
RETURN aSize

#undef _THISXBP_NAME
#undef _THISXBP_SUPER

