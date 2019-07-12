#include "Common.ch"
#include "Gra.ch"
#include "xbp.ch"
#include "dfStd.ch"

// $DOC 
// Imposta uno o pi— presentation parameters
// $EXAMPLE
// aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, "24.Arial")
// oppure
// aPP := S2PresParameterSet(aPP, { {XBP_PP_FGCLR, XBPSYSCLR_3DFACE      }, ;
//                                  {XBP_PP_BGCLR, XBPSYSCLR_TRANSPARENT }  })
FUNCTION S2PresParameterSet(aPP, nItem, xVal)
   LOCAL oPP := S2PresParameter():new(aPP)

   IF VALTYPE(nItem)=="A"
      AEVAL(nItem, {|x| oPP:set(x[1], x[2]) })
   ELSE
      oPP:set(nItem, xVal)
   ENDIF
   aPP:=oPP:setPP()
RETURN aPP

// $DOC 
// Legge un valore da un array dei presentation parameters
FUNCTION S2PresParameterGet(aPP, nItem)
RETURN S2PresParameter():new(aPP):get(nItem)

// $DOC 
// Elimina un valore da un array dei presentation parameters
FUNCTION S2PresParameterDel(aPP, nItem)
RETURN S2PresParameter():new(aPP):del(nItem)

// Gestisce un array dei presentation parameters

CLASS S2PresParameter
   PROTECTED
      VAR aPP
      VAR Error
      METHOD _set
   EXPORTED

      METHOD init
      METHOD set
      METHOD setIfNotPresent
      METHOD get
      METHOD del
      METHOD getError
      METHOD setPP
ENDCLASS

METHOD S2PresParameter:init(aPP)
   DEFAULT aPP TO {}
   ::aPP := aPP
   ::Error := 0
RETURN self

METHOD S2PresParameter:getError()
RETURN ::Error

METHOD S2PresParameter:setPP(aPP)
   LOCAL aRet := ACLONE(::aPP)
   ::Error:= 0

   IF VALTYPE(aPP) == "A"
      ::aPP := ACLONE(aPP)
   ENDIF
RETURN aRet


METHOD S2PresParameter:_set(nItem, xVal, lCanModify)
   LOCAL nPos

   ::Error := 0

   IF nItem == NIL
      ::Error := -1
      RETURN ::aPP
   ENDIF

   nPos:= ASCAN(::aPP, {|a|a[1]==nItem})
   IF nPos == 0
      AADD(::aPP, {nItem, xVal})
   ELSEIF lCanModify
      ::aPP[nPos][2] := xVal
   ENDIF
RETURN ACLONE(::aPP)

METHOD S2PresParameter:setIfNotPresent(nItem, xVal)
RETURN ::_set(nItem, xVal, .F.)

METHOD S2PresParameter:set(nItem, xVal)
RETURN ::_set(nItem, xVal, .T.)

METHOD S2PresParameter:get(nItem)
   LOCAL nPos, xRet

   ::Error := 0

   IF nItem == NIL
      ::Error := -1
      RETURN ::aPP
   ENDIF

   nPos:= ASCAN(::aPP, {|a|a[1]==nItem})
   IF nPos == 0
      ::Error := -2
   ELSE
      xRet := ::aPP[nPos][2]
   ENDIF
RETURN xRet

METHOD S2PresParameter:del(nItem)
   LOCAL nPos, lRet := .F.

   ::Error := 0

   IF nItem == NIL
      ::Error := -1
      RETURN lRet
   ENDIF

   nPos:= ASCAN(::aPP, {|a|a[1]==nItem})
   IF nPos == 0
      ::Error := -2
   ELSE
      lRet := .T.
      #ifdef _XBASE18_
        AREMOVE(::aPP, nPos)
      #else
        DFAERASE(::aPP, nPos)
      #endif
   ENDIF
RETURN lRet



