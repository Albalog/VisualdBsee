// Gestione array ottimizzata per AADD consecutivi, 
// perche invece di fare sempre un AADD alloca una quantita 
// di dati prefissata

#include "common.ch"

CLASS S2Array
   PROTECTED:
   VAR aArray
   VAR Len
   VAR Size
   VAR Alloc

   EXPORTED:
   METHOD Init, Len, Add, ATail, IsEmpty
   METHOD Get, Set, AddTo, GetArr, SetArr
   METHOD Del, Size, Eval
ENDCLASS

METHOD S2Array:Init(nAlloc)
   ::Len := 0
   IF VALTYPE(nAlloc) == "N" .AND. nAlloc >= 1
      ::Alloc := INT(nAlloc)
   ELSE
      ::Alloc := 40
   ENDIF
   ::aArray := ARRAY(::Alloc)
   ::Size := ::Alloc
RETURN self

METHOD S2Array:Add( xVal )
   IF ++::Len > ::Size
      ASize( ::aArray, ::Size += ::Alloc )
   ENDIF
   ::aArray[ ::Len ] := xVal
RETURN ::Len

METHOD S2Array:ATail()
   LOCAL xRet

   IF ::Len > 0
      xRet := ::aArray[::Len]
   ENDIF
RETURN xRet

METHOD S2Array:Len()
RETURN ::Len

METHOD S2Array:IsEmpty()
RETURN ::Len == 0

METHOD S2Array:Get(n)
RETURN ::aArray[n]

METHOD S2Array:Set(n, xVal)
   ::aArray[n] := xVal
RETURN self

METHOD S2Array:AddTo( aArr )
   LOCAL n
   DEFAULT aArr TO {}

   FOR n := 1 TO ::Len
      AADD(aArr, ::aArray[n])
   NEXT
RETURN ::Len

METHOD S2Array:getArr( aArr )
  ::Size := ::Len
RETURN ASize( ::aArray, ::Size )

METHOD S2Array:setArr( aArr )
  ::aArray := aArr
  ::Len    := LEN(::aArray)
  ::Size   := ::Len
RETURN self

METHOD S2Array:Del( n, lResize)
   DEFAULT lResize TO .F.

   ADEL(::aArray, n)

   IF lResize
      ::Len--
   ENDIF
RETURN ::Len

METHOD S2Array:Size( n )
   IF n >= 0 .AND. n < ::Len 
      ::Len := INT(n)
   ENDIF
RETURN ::Len

METHOD S2Array:Eval(b, n, i, lAssign )
   DEFAULT n TO 1
   DEFAULT i TO ::Len

   n := INT(n)
   i := INT(i)

   IF n < 1 .OR. n > ::Len
      RETURN ::Len
   ENDIF

   IF i < 1
      RETURN ::Len
   ENDIF

   IF n + (i -1) > ::Len
      i := ::Len - n + 1
   ENDIF

RETURN AEVAL(::aArray, b, n, i, lAssign)

