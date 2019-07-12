STATIC nCount := 0

FUNCTION S2DispBegin()
   nCount++

RETURN NIL

FUNCTION S2DispEnd()
   nCount--

RETURN NIL

FUNCTION S2DispCount()
RETURN nCount
