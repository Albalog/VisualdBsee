#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "common.ch"
#include "dfStd.ch"

// gestione di una progress bar a "gradiente"
// con indicazione della percentuale

#define PERC_TXT_WIDTH 30

CLASS GradientProgressBar FROM XbpStatic, GradientPaint
PROTECTED:
    VAR oPerc
    VAR nPerc

EXPORTED:
    VAR aVtxPos, aVtxSize
    VAR minimum, maximum, current
    VAR lShowPerc // mostra percentuale .T./.F.

    METHOD init
    METHOD create
    METHOD setCurrent
    METHOD getPerc
    METHOD increment

    METHOD buildVertex
ENDCLASS

METHOD GradientProgressBar:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::XbpStatic:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::type := XBPSTATIC_TYPE_FGNDFRAME

   ::aVtxPos := {0, 0}
   ::aVtxSize := {0, 0}

   ::GradientPaint:init(self)
   ::lGradientPaint := .T.

   ::setVertexColor(1,14,23,92)
   ::setVertexColor(2,198,205,254)

   ::oPerc := XbpStatic():new(self, , {1,1}, NIL, NIL, .F. )
   ::oPerc:options := XBPSTATIC_TEXT_CENTER
   ::oPerc:setColorBG(GRA_CLR_WHITE)
   ::oPerc:caption := ""

   ::minimum := 0
   ::maximum := 100
   ::current := 0
   ::nPerc   := 0
   ::lShowPerc:=.T.
RETURN self

METHOD GradientProgressBar:create(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::XbpStatic:create(oParent, oOwner, aPos, aSize, aPP, lVisible)
   aSize := ::currentSize()

   aSize[1] := PERC_TXT_WIDTH
   aSize[2] -= 2

   ::oPerc:create(NIL, NIL, NIL, aSize, NIL, ::lShowPerc)
   ::setCurrent()
RETURN self

METHOD GradientProgressBar:getPerc()
RETURN ::nPerc/100

METHOD GradientProgressBar:setCurrent(curr, max)
   LOCAL oXbp := self
   LOCAL aSz
   LOCAL nPos

   DEFAULT curr TO ::current
   ::current := curr

   DEFAULT max TO ::maximum
   ::maximum := max

   IF ::current > ::maximum
      ::current := ::maximum
   ENDIF

   // Simone 06/10/08
   // miglioramento per divisione per 0
   ::nPerc := INT(DFFIXDIV(10000*curr, max))
   ::oPerc:SetCaption(ALLTRIM(STR(::nPerc/100,10,0))+" %")

   nPos := IIF(::lShowPerc, PERC_TXT_WIDTH, 0)

   aSz := oXbp:currentSize()

   aSz[1]-= 1+nPos
   aSz[2]-= 2

   // Simone 06/10/08
   // miglioramento per divisione per 0
   aSz[1] := ROUND(DFFIXDIV(aSz[1]*curr, max), 0)

   oXbp:aVtxPos:={nPos,1}
   oXbp:aVtxSize := aSz
   oXbp:buildVertex()
   oXbp:gradientPaint()
RETURN self

METHOD GradientProgressBar:increment(nIncrement)
   IF Valtype( nIncrement ) <> "N"
      nIncrement := 1
   ENDIF

  /*
   * While a progress is displayed, PROTECTED VAR :_current is incremented
   * to avoid the overhead of the ASSIGN method :current()
   */

   ::current += nIncrement
   ::setCurrent(::current)
RETURN ::current


METHOD GradientProgressBar:buildVertex(aPos, aSize)
   ::vertex    := ::TriVertEx(1, ::aVtxPos[1], ::aVtxPos[2])+;
                  ::TriVertEx(2, ::aVtxPos[1]+::aVtxSize[1], ;
                                 ::aVtxPos[2]+::aVtxSize[2])
RETURN (self)
