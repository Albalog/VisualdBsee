#include "common.ch"

FUNCTION S2WinCenter(oWin, oObj)
   LOCAL aParentSize
   LOCAL aSize

   DEFAULT oObj TO oWin:setParent()
   DEFAULT oObj TO AppDesktop()

   aParentSize := oObj:currentSize()
   aSize := oWin:currentSize()

   aSize[1] := (aParentSize[1] - aSize[1]) / 2
   aSize[2] := (aParentSize[2] - aSize[2]) / 2

   oWin:setPos(aSize)

RETURN NIL
