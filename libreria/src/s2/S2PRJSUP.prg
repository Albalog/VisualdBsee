STATIC aPrj := {}

FUNCTION S2PrjDllPath(cPrjName)
   LOCAL cRet := ""
   LOCAL nPos := ASCAN(aPrj, {|x| x[1]==cPrjName })

   IF nPos > 0
      cRet := aPrj[nPos][2]
   ENDIF
RETURN cRet

FUNCTION S2PrjRegister(cPrjName, cDllPath)
   LOCAL nPos := ASCAN(aPrj, {|x| x[1]==cPrjName })

   IF nPos == 0
      AADD(aPrj, {cPrjName, cDllPath})
   ELSE
      aPrj[nPos][1] := cPrjName
      aPrj[nPos][2] := cDllPath
   ENDIF
RETURN  nPos

