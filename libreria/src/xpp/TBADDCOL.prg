#include "common.ch"
#include "dfWin.ch"
#include "dfXbase.ch"
#include "xbp.ch"
#include "dfSet.ch"

FUNCTION tbAddColumn(oWin, bBlock, nWidth, cId, cPrompt, ;
                     bTotal, cPict, cFPict, cLabel, bInfo, ;
                     cField, cMsg, aColor, nType, nCountMode )
RETURN tbInsColumn(oWin, NIL, bBlock, nWidth, cId, cPrompt, ;
                     bTotal, cPict, cFPict, cLabel, bInfo, ;
                     cField, cMsg, aColor, nType, nCountMode)

/*
   LOCAL aPP
   LOCAL cFoot
   LOCAL lTag := ! EMPTY(cPrompt) .AND. ;
                 UPPER(cPrompt) == "TAG"

   IF aColor == NIL
      IF VALTYPE(oWin:colorSpec) $ "CM" .AND. ! EMPTY(oWin:colorSpec)
         aColor := dfStr2Arr(oWin:colorSpec, ",")
      ENDIF
   ENDIF

   IF VALTYPE(aColor)=="A" .AND. LEN(aColor) >= WC_CC_LEN 

      // posso passare un quarto elemento per il colore foot area
      // default=colore header
      cFoot := NIL
      IF LEN(aColor) > WC_CC_LEN
         cFoot := aColor[WC_CC_LEN+1]
      ENDIF

      DEFAULT cFoot TO aColor[WC_CC_HEADER]

      aPP := {}
   
      Clr2PP(aPP, aColor[WC_CC_HEADER], XBP_PP_COL_HA_FGCLR, XBP_PP_COL_HA_BGCLR)
      Clr2PP(aPP, aColor[WC_CC_DATA  ], XBP_PP_COL_DA_FGCLR, XBP_PP_COL_DA_BGCLR)
      Clr2PP(aPP, aColor[WC_CC_CURSOR], XBP_PP_COL_DA_HILITE_FGCLR, XBP_PP_COL_DA_HILITE_BGCLR)
      Clr2PP(aPP, cFoot               , XBP_PP_COL_FA_FGCLR, XBP_PP_COL_FA_BGCLR)
   ENDIF
   oWin:tbAddColumn(bBlock, nWidth, cId, cPrompt, ;
                    bTotal, cPict, cFPict, cLabel, bInfo, ;
                    cField, cMsg, aColor, lTag, nType, aPP, nCountMode )

             
RETURN NIL

STATIC FUNCTION Clr2PP(aPP, cClr, nFG, nBG)
   S2ItmSetColors({|n| AADD(aPP, {nFG, n})}, ;
                  {|n| AADD(aPP, {nBG, n})}, ;
                  .T., cClr)
RETURN NIL
*/