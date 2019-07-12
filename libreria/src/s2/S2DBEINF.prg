FUNCTION S2DbeInfo(cRdd, nComponent, nDefine, nNew)
   LOCAL cCurrRdd := DbeSetDefault()
   LOCAL xRet     := ""

   IF cRdd == NIL .OR. cCurrRdd == cRdd
      xRet := DbeInfo(nComponent, nDefine, nNew)

   ELSEIF ASCAN(DbeList(), {|x| x[1] == cRdd }) > 0
      DbeSetDefault(cRdd)
      xRet := DbeInfo(nComponent, nDefine, nNew)
      DbeSetDefault(cCurrRdd)
   ENDIF

RETURN xRet
