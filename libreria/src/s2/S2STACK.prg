// Function/Procedure Prototype Table  -  Last Update: 13/10/98 @ 19.02.21
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
// Return Value         Function/Arguments
// 컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// self                 METHOD S2Stack:Init()
// ::Len == 0           METHOD S2Stack:IsEmpty()
// ::Ok                 METHOD S2Stack:IsOk()
// ::Len                METHOD S2Stack:Length()
// xRet                 METHOD S2Stack:Pop()
// ::Len                METHOD S2Stack:Push( xVal )
// xRet                 METHOD S2Stack:Top()

#include "appevent.ch"

CLASS S2Stack
   PROTECTED:
   VAR aStack, Len, Ok

   EXPORTED:
   METHOD Init, Push, Pop, Top, Length, IsOk, IsEmpty
ENDCLASS

METHOD S2Stack:Init()
   ::aStack := {}
   ::Len := 0
   ::Ok := .T.
RETURN self

METHOD S2Stack:Push( xVal )
   ::Ok := .T.
   AADD(::aStack, xVal)
   ::Len++
RETURN ::Len

METHOD S2Stack:Pop()
   LOCAL xRet
   IF ::Len > 0
      xRet := ATAIL( ::aStack )
      ::Len--
      ASIZE(::aStack, ::Len)
      ::Ok := .T.
   ELSE
      ::Ok := .F.
   ENDIF
RETURN xRet

METHOD S2Stack:Top()
   LOCAL xRet

   IF ::Len > 0
      xRet := ATAIL( ::aStack )
      ::Ok := .T.
   ELSE
      ::Ok := .F.
   ENDIF
RETURN xRet

METHOD S2Stack:Length()
RETURN ::Len

METHOD S2Stack:IsEmpty()
RETURN ::Len == 0

METHOD S2Stack:IsOk()
RETURN ::Ok
