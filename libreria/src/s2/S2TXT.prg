// Function/Procedure Prototype Table  -  Last Update: 07/10/98 @ 12.27.22
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
// Return Value         Function/Arguments
// 컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// aSize                METHOD S2Txt:CalcTextSize()
// RETURN self          METHOD S2Txt:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
// ::TextArea:caption   METHOD S2Txt:GetText()
// {nMaxWidth, nMax...  METHOD S2Txt:GetTextSize(cMsg)
// self                 METHOD S2Txt:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
// ::TextArea:SetSize(  METHOD S2Txt:SetSize( aSize )
// ::TextArea:SetCa...  METHOD S2Txt:SetText( cText )

#include "Common.ch"
#include "dfXBase.ch"
#include "dfStd.ch"
#include "Xbp.ch"
#include "Gra.ch"

CLASS S2Txt FROM XbpStatic

   EXPORTED:
      VAR TextArea
      METHOD Init, Create, SetText, GetText, SetSize, CalcTextSize, GetTextSize
       //, Destroy

ENDCLASS

METHOD S2Txt:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::XbpStatic:Init(oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::type := XBPSTATIC_TYPE_GROUPBOX

   ::TextArea := XbpStatic():new(self, NIL, {3,3})
   ::TextArea:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_LEFT
   ::TextArea:caption := ""

RETURN self

METHOD S2Txt:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::XbpStatic:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   // ::TextArea:SetColorBG(GRA_CLR_DARKGRAY)
   ::TextArea:Create(NIL, NIL, NIL, ::CalcTextSize())
   IF ! EMPTY( ::textArea:caption ) .AND. ::autoSize
      // ricalcolo la dimesione del control
      ::setText( ::textArea:caption )
   ENDIF

RETURN self

// METHOD S2Txt:Destroy()
//    ::TextArea:Destroy()
//    ::XbpStatic:Destroy()
// RETURN self

METHOD S2Txt:CalcTextSize()
   LOCAL aSize := ::currentSize()
   aSize[1] -= 6
   aSize[2] -= 12
RETURN aSize

METHOD S2Txt:SetSize( aSize )
   ::XbpStatic:SetSize( aSize )

RETURN ::TextArea:SetSize( ::CalcTextSize() )


METHOD S2Txt:SetText( cText )
   LOCAL aSize

   IF ::autoSize
      aSize := ::getTextSize( cText )
      aSize[1] += 6
      aSize[2] += 12
      ::setSize( aSize )
   ENDIF

RETURN ::TextArea:SetCaption( cText )

METHOD S2Txt:GetText()
RETURN ::TextArea:caption

METHOD S2Txt:GetTextSize(cMsg)
   LOCAL nMaxWidth  := 0
   LOCAL nMaxHeight := 0
   LOCAL aDim
   LOCAL oPS
   LOCAL nWidth
   LOCAL nHeight
   LOCAL aStr
   LOCAL nInd

   // Calcolo la dimensione della stringa
   oPS := ::TextArea:lockPS()

   IF oPS != NIL
      IF dfAnd(::TextArea:options, XBPSTATIC_TEXT_WORDBREAK) == 0

         // -----------------------
         // Testo su una sola linea
         // -----------------------

         aDim := GraQueryTextBox(oPS, cMsg)
         nMaxWidth  := MAX(aDim[3][1], aDim[4][1]) - MIN(aDim[1][1], aDim[2][1])
         nMaxHeight := MAX(aDim[3][2], aDim[4][2]) - MIN(aDim[1][2], aDim[2][2])

      ELSE

         // ----------------
         // Testo multilinea
         // ----------------

         aStr := dfStr2Arr(cMsg, CRLF)

         FOR nInd := 1 TO LEN(aStr)
            aDim := GraQueryTextBox(oPS, IIF(aStr[nInd] == "", " ", aStr[nInd]))

            nWidth  := MAX(aDim[3][1], aDim[4][1]) - MIN(aDim[1][1], aDim[2][1])
            nHeight := MAX(aDim[3][2], aDim[4][2]) - MIN(aDim[1][2], aDim[2][2])

            nMaxWidth  := MAX(nMaxWidth, nWidth)
            nMaxHeight += nHeight

         NEXT


      ENDIF
      ::TextArea:unlockPS(oPS)
   ENDIF

RETURN {nMaxWidth, nMaxHeight}

