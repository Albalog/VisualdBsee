// ------------------------------------------------------------------------
// Classe S2ArrayBox
// Classe di browsing su Array
//
// Super classes
//    S2BrowseBox
//
// Sub classes
//    niente
// ------------------------------------------------------------------------
//
// Function/Procedure Prototype Table  -  Last Update: 06/11/98 @ 17.19.50
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
// Return Value         Function/Arguments
// 컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// RETURN n             METHOD S2ArrayBox:Init( nTop, nLeft, nBott, nRight, nType, ;
// RETURN cCho          METHOD S2ArrayBox:tbEval(bEval)

#include "dfWin.ch"
#include "Common.ch"
#include "dfXBase.ch"
#include "dfStd.ch"
#include "Xbp.ch"
#include "Gra.ch"

CLASS S2ArrayBox FROM S2BrowseBox
   // PROTECTED:
   EXPORTED:
   // VAR Array
   // VAR nIndex
   METHOD Init, tbEval //, ArrSkipper
ENDCLASS

METHOD S2ArrayBox:Init( nTop, nLeft, nBott, nRight, nType, ;
                        oParent, oOwner, aPos, aSize, aPP, lVisible, nCoordMode )

   DEFAULT nType TO W_OBJ_ARRAYBOX
   DEFAULT nCoordMode   TO S2CoordModeDefault()
   ::nCoordMode := nCoordMode
   // ::Array := {}
   ::W_CURRENTREC := 1

   dfPushArea()

   DBSELECTAREA(0)

   ::S2BrowseBox:Init( nTop, nLeft, nBott, nRight, nType, ;
                       oParent, oOwner, aPos, aSize, aPP, lVisible,nCoordMode )

   ::W_ALIAS := ""
   ::W_ORDER := 0

   // // Navigation code blocks for the browser

   ::GoTopBlock    := {|    | ::W_CURRENTREC := 1             }
   //::skipBlock     := {|n| ::ArrSkipper(n) }
   ::SkipBlock     := {|nRec| _tbASkip(self, nRec)            }
   ::GoBottomBlock := {|    | ::W_CURRENTREC := ::W_AI_LENGHT }
   ::W_AI_LENGHT   := 0
   ::W_CURRENTREC  := 1

   ::phyPosSet     := {|n| ::W_CURRENTREC := n }
   ::phyPosBlock   := {| | ::W_CURRENTREC }

   // Navigation code blocks for the vertical scroll bar
   ::posBlock      := {| | ::W_CURRENTREC    }
   ::lastPosBlock  := {| | ::W_AI_LENGHT}

   ::firstPosBlock := {| | 1 }

   ::bEval := {|bBlk| ::tbEval(bBlk) }

   dfPopArea()

RETURN self

// METHOD S2ArrayBox:ArrSkipper( n )
//    LOCAL nLen := MAX(1,::W_AI_LENGHT)
//    IF n != 0
// 
//       IF n > 0
// 
//          IF ::W_CURRENTREC + n > nLen
//             n := nLen - ::W_CURRENTREC
//          ENDIF
// 
//       ELSE
// 
//          IF ::W_CURRENTREC + n < 1
//             n := -::W_CURRENTREC + 1
//          ENDIF
// 
//       ENDIF
// 
//       ::W_CURRENTREC += n
//    ENDIF
// RETURN n

METHOD S2ArrayBox:tbEval(bEval)
   LOCAL xPos := EVAL(::phyPosBlock)
   LOCAL nSkip := 1

   EVAL(::GoTopBlock)

   DO WHILE nSkip == 1
      EVAL(bEval)

      nSkip := EVAL(::SkipBlock, 1)
   ENDDO

   EVAL(::phyPosSet,  xPos)
RETURN NIL

