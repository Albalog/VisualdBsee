/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "dfWin.ch"
#include "dfMsg.ch"
#include "common.ch"

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
FUNCTION dfCol2Prn( oTbr, cTitle )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
LOCAL k,oC,aTag:={},aP:={}
LOCAL cH

DEFAULT cTitle TO dfStdMsg( MSG_DFCOL2PRN01 )

FOR k:=1 to oTbr:COLCOUNT
   oC:=oTbr:GETCOLUMN(k)
   //cH:=oC:HEADING
   cH:=tbGetColHeading(oC)

	// FWH: 2020-06-18 -------------------------------------------------
	// cH potrebbe essere un oggetto (per esempio 'S2CellGroup')
	if valtype(cH) # "C"
		cH = var2char(cH)
	endif
	// -----------------------------------------------------------------

//Maudp 30/05/2011 In caso di funzione eseguo la compile e poi la eval
   IF !EMPTY(cH) .AND. "_FX_" $ cH
      cH := ALLTRIM(STRTRAN(cH,"!",""))
      cH := EVAL(dfCompile(cH))
   ENDIF
//   AADD(aP,oC:HEADING)
   /////////////////////////////////////////
   //Mantis 2161
   //Se l'intestazione delle colonne ?vuoto allora si pu?avere un runtime error.
   /////////////////////////////////////////
   IF EMPTY(cH)
      cH := "Colonna_"+STRZERO(k,3,0)
   ENDIF
   /////////////////////////////////////////
   AADD(aP,cH)
   AADD(aTag,k)
NEXT
IF LEN( aP )>1
   dfArrWin(,,,,aP, cTitle,,aTag)
ENDIF

RETURN aTag
