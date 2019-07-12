#INCLUDE "Common.CH"
#INCLUDE "dfWin.ch"
#INCLUDE "dfNet.CH"
#INCLUDE "dfMsg.CH"
#INCLUDE "dfStd.CH"
#INCLUDE "dfCTRL.CH"
#include "dfSet.CH"
#include "dfTab.ch"


FUNCTION S2TabGetFie(nPos)
  LOCAL cRet := ""
  LOCAL aStr

  DEFAULT nPos TO 2
  nPos--

  IF nPos <= 0
     RETURN cRet
  ENDIF 

  aStr  := dfStr2arr(dbTabd->TabData,TAB_SEPARATORE )
  IF LEN(aStr) >= 1 .AND. LEN(aStr) >= nPos
     cRet := aStr[nPos]
  ENDIF 

RETURN cRet