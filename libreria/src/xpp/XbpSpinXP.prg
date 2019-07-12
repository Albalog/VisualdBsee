// -----------------------------
// Template per nuovo Xbase Part
// -----------------------------
#include "Common.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "AppEvent.ch"

// ------------------------------------------------
// XbpSpinXP()
// Classe derivata da XbpSLE() con in piu un pulsante
// simula la XbpSpinButton() ma supporta i temi XP
// dato che usa una scrollbar per UP/DOWN
//
// Versione Classe 1.0
//
// Cronologia delle modifiche alla classe
// --------------------------------------
//
// - 22/12/2003 - Simone
//    - Versione iniziale
//
// ------------------------------------------------
//
// Usa un template per classe derivata da altre classi
// Versione Template 1.0
//
// Cronologia delle modifiche al template
// --------------------------------------
//
// - 22/12/2003 - Simone
//    - Versione iniziale
//
// ------------------------------------------------


// Nome della classe
#define _THISXBP_NAME  XbpSpinXP

// Eredita da
#define _THISXBP_SUPER XbpSle

#ifdef _TEST_
   PROCEDURE Main()
      LOCAL oXbp

      oXbp := _THISXBP_NAME():New(NIL, NIL, {20, 50}, {80, 160})
      oXbp:caption := "test"
      oXbp:Create()
      Inkey(0)

   RETURN
#endif

#define _BUTTON_CLASS  XbpScrollBar

CLASS _THISXBP_NAME FROM _THISXBP_SUPER
   PROTECTED:
      VAR oBtn
      METHOD arrangeObjects

   EXPORTED:
      METHOD Init
      METHOD Create
      METHOD Destroy

      METHOD SetPosAndSize
      METHOD SetPos
      METHOD SetSize
      METHOD currentSize
      METHOD Show
      METHOD Hide
      METHOD Enable
      METHOD Disable
      METHOD KeyBoard
      METHOD setData
      METHOD getData
      METHOD editbuffer
      METHOD spinDown
      METHOD spinUp
      METHOD setNumLimits
      METHOD handleScroll
ENDCLASS

METHOD _THISXBP_NAME:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::_THISXBP_SUPER:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::oBtn := _BUTTON_CLASS():new()
   ::oBtn:scroll := {|n| ::handleScroll(n)}
   ::oBtn:type := XBPSCROLL_VERTICAL
   ::oBtn:autoTrack := .F.
   ::setNumLimits(0, 99)
RETURN self

METHOD _THISXBP_NAME:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::_THISXBP_SUPER:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   lVisible := ::isVisible()
   ::oBtn:create(::setParent(),NIL,NIL,NIL,NIL,lVisible)
//   ::oBtn:activate := {|| ::exeactivate()}

   IF ! ::editable
      ::oBtn:disable()
   ENDIF

   ::arrangeObjects()
RETURN self

METHOD _THISXBP_NAME:Destroy()
   ::_THISXBP_SUPER:Destroy()
   IF ::oBtn:status() == XBP_STAT_CREATE
      ::oBtn:destroy()
   ENDIF
RETURN self

METHOD _THISXBP_NAME:KeyBoard(nKey)
   IF nKey == xbeK_UP
      ::spinUp()
   ELSEIF nKey == xbeK_DOWN
      ::spinDown()
   ELSE //IF (nKey >= ASC("0") .AND. nKey <= ASC("9")) .OR. nKey < 0 .OR. nKey > 255
      ::_THISXBP_SUPER:KeyBoard(nKey)
      ::setData( ::editBuffer() )
   ENDIF
RETURN self


METHOD _THISXBP_NAME:show()
   ::_THISXBP_SUPER:show()
   IF ! EMPTY(::oBtn)
      ::oBtn:show()
   ENDIF
RETURN .T.

METHOD _THISXBP_NAME:hide()
   ::_THISXBP_SUPER:hide()
   ::oBtn:hide()
RETURN .T.

METHOD _THISXBP_NAME:enable()
   ::_THISXBP_SUPER:enable()
   ::oBtn:enable()
RETURN .T.

METHOD _THISXBP_NAME:disable()
   ::_THISXBP_SUPER:disable()
   ::oBtn:disable()
RETURN .T.

METHOD _THISXBP_NAME:setPos(aPos, lUpdate)
   LOCAL lRet := .T.

   DEFAULT lUpdate TO .T.
   lRet := ::_THISXBP_SUPER:setPos(aPos, .F.)

   IF lRet
      ::arrangeObjects(lUpdate)
   ENDIF

RETURN lRet

METHOD _THISXBP_NAME:setSize(aSize, lUpdate)
   LOCAL lRet := .T.

   DEFAULT lUpdate TO .T.
   lRet := ::_THISXBP_SUPER:setSize(aSize, .F.)

   IF lRet
      ::arrangeObjects(lUpdate)
   ENDIF
RETURN lRet

METHOD _THISXBP_NAME:setPosAndSize(aPos, aSize, lUpdate)
   LOCAL lRet1 := .F.
   LOCAL lRet2 := .F.

   DEFAULT lUpdate TO .T.

   lRet1 := ::SetPos(aPos, .F.)
   lRet2 := ::SetSize(aSize, .F.)
   IF lUpdate
      ::invalidateRect()
   ENDIF

RETURN lRet1 .AND. lRet2

METHOD _THISXBP_NAME:currentSize()
   LOCAL aSize := ::_THISXBP_SUPER:currentSize()
   aSize[1] += ::oBtn:currentSize()[1]
RETURN aSize


METHOD _THISXBP_NAME:arrangeObjects(lUpdate)
   LOCAL aSize
   LOCAL aPos
   LOCAL aBtnSz
   LOCAL nBtnW

   DEFAULT lUpdate TO .T.

   aPos     := ::currentPos()
   aSize    := ::_THISXBP_SUPER:currentSize()

   // larghezza identica all'altezza max 20 pixel
   nBtnW    := 0
   nBtnW := MIN(20, aSize[2])

   // SD 6/2/08  
   // mantis 0001757: clasee XbpSpinXP non funziona bene metodo hide()
   // se la larghezza pulsante >= larghezza totale, divido larghezza pulsante x2
   IF nBtnW >= aSize[1] 
      nBtnW := ROUND(aSize[1]/2, 0)
   ENDIF

   aBtnSz   := {nBtnW, aSize[2]}
   aSize[1] -= aBtnSz[1]

   aPos[1] += aSize[1]

   ::_THISXBP_SUPER:setSize(aSize, lUpdate)

   // Simone 19/5/04
   // Workaround.. altrimenti allargava
   // il pulsante alla larghezza
   // NOTA: il problema esiste ancora quando
   //       il ::buttontype <> empty!!

   ::oBtn:show()

   ::oBtn:setPosAndSize(aPos, aBtnSz, lUpdate)
RETURN self

METHOD _THISXBP_NAME:setData(n)
   ::oBtn:setData(n)
RETURN ::_THISXBP_SUPER:setData(ALLTRIM(STR( ::oBtn:getData() )))

METHOD _THISXBP_NAME:getData()
RETURN VAL( ::_THISXBP_SUPER:getData() )

METHOD _THISXBP_NAME:editBuffer()
RETURN VAL( ::_THISXBP_SUPER:editBuffer() )

METHOD _THISXBP_NAME:spinDown(n)
   DEFAULT n TO 1
   ::setData( ::getData() -n )
RETURN .T.

METHOD _THISXBP_NAME:spinUp(n)
   DEFAULT n TO 1
   ::setData( ::getData() +n )
RETURN .T.

METHOD _THISXBP_NAME:setNumLimits(n1, n2)
   LOCAL aNew := ACLONE( ::oBtn:setRange() )

   IF VALTYPE(n1) == "N"
      aNew[1] := n1
   ENDIF
   IF VALTYPE(n2) == "N"
      aNew[2] := n2
   ENDIF
RETURN ::oBtn:setRange(aNew)

METHOD _THISXBP_NAME:handleScroll(mp1)

   IF mp1[2] == XBPSB_PREVPOS
      ::spinUp()
   ELSEIF mp1[2] == XBPSB_NEXTPOS
      ::spinDown()
   ELSEIF mp1[2] == XBPSB_PREVPAGE
      ::spinUp()
   ELSEIF mp1[2] == XBPSB_NEXTPAGE
      ::spinDown()
   ENDIF

//   ::setData( ::oBtn:getData() )
RETURN self

#undef _THISXBP_NAME
#undef _THISXBP_SUPER



// Nome della classe
#define _THISXBP_NAME  _scrlbar

// Eredita da
#define _THISXBP_SUPER XbpScrollBar


CLASS _THISXBP_NAME FROM _THISXBP_SUPER
EXPORTED:
   METHOD handleEvent

ENDCLASS

METHOD _THISXBP_NAME:handleEvent(n, mp1, mp2)
   IF n != xbeSB_Scroll

   ELSEIF mp1[2] == XBPSB_PREVPOS
      mp1[2] := XBPSB_NEXTPOS
   ELSEIF mp1[2] == XBPSB_NEXTPOS
      mp1[2] := XBPSB_PREVPOS
   ELSEIF mp1[2] == XBPSB_PREVPAGE
      mp1[2] := XBPSB_NEXTPAGE
   ELSEIF n == XBPSB_NEXTPAGE
      mp1[2] := XBPSB_PREVPAGE
   ENDIF
RETURN ::_THISXBP_SUPER:handleEvent(n, mp1, mp2)

#undef _THISXBP_NAME
#undef _THISXBP_SUPER
