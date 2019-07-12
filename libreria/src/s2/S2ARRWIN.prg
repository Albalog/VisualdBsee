// ------------------------------------------------------------------------
// Classe S2ArrWin
// Finestra di visualizzazione dati su Array in formato tabellare
//
// Super classes
//    S2Browse
//
// Sub classes
//    niente
// ------------------------------------------------------------------------
//
#include "dfWin.ch"
#include "Common.ch"
#include "dfXBase.ch"
#include "dfStd.ch"
#include "Xbp.ch"
#include "Gra.ch"

CLASS S2ArrWin FROM S2Browse
   // PROTECTED:
   EXPORTED:
   // VAR Array
   // VAR nIndex
   METHOD Init, tbEval //, ArrSkipper
ENDCLASS

METHOD S2ArrWin:Init( nTop, nLeft, nBott, nRight, nType, ;
                      oParent, oOwner, aPos, aSize, aPP, lVisible, nCoordMode )

   DEFAULT nType  TO W_OBJ_ARRWIN
   DEFAULT nCoordMode TO S2CoordModeDefault()
   ::nCoordMode := nCoordMode
   // ::Array := {}
   ::W_CURRENTREC := 1

   dfPushArea()

   DBSELECTAREA(0)

   ::S2Browse:Init( nTop, nLeft, nBott, nRight, nType, ;
                    oParent, oOwner, aPos, aSize, aPP, lVisible, nCoordMode )

   ::W_ALIAS := ""
   ::W_ORDER := 0

   ::W_MOUSEMETHOD := W_MM_PAGE + W_MM_ESCAPE+ W_MM_MINIMIZE+ W_MM_MAXIMIZE+ ;
                      W_MM_SIZE + W_MM_MOVE + W_MM_EDIT    // Inizializzazione ICONE per mouse

   ::Browser:bEval := {|bBlk| ::tbEval(bBlk) }

   // // Navigation code blocks for the browser
   // ::Browser:skipBlock     := {|n| ::ArrSkipper(n) }
   // ::Browser:goTopBlock    := {| | ::W_CURRENTREC := 1            }
   // ::Browser:goBottomBlock := {| | ::W_CURRENTREC := LEN(::Array)   }

   ::GoTopBlock    := {|    | ::W_CURRENTREC := 1                }
   ::SkipBlock     := {|nRec|_tbASkip(self,nRec)                   }
   ::GoBottomBlock := {|    | ::W_CURRENTREC := ::W_AI_LENGHT }

   ::W_AI_LENGHT   := 0
   ::W_CURRENTREC  := 1

   ::Browser:phyPosSet     := {|n| ::W_CURRENTREC := n }
   ::Browser:phyPosBlock   := {| | ::W_CURRENTREC }

   // Navigation code blocks for the vertical scroll bar
   ::Browser:posBlock      := {| | ::W_CURRENTREC   }
   // ::Browser:lastPosBlock  := {| | LEN(::Array)}
   ::Browser:firstPosBlock := {| | 1 }
   ::Browser:lastPosBlock  := {| | ::W_AI_LENGHT}

   dfPopArea()

RETURN self

// METHOD S2ArrWin:ArrSkipper( n )
//    IF n != 0
//       IF n > 0
//
//          IF ::W_CURRENTREC + n > LEN(::Array)
//             n := LEN(::Array) - ::W_CURRENTREC
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


METHOD S2ArrWin:tbEval(bEval)
   LOCAL xPos := EVAL(::Browser:phyPosBlock)
   LOCAL nSkip := 1

   EVAL(::Browser:GoTopBlock)

   DO WHILE nSkip == 1
      EVAL(bEval)
      nSkip := EVAL(::Browser:SkipBlock, 1)
   ENDDO

   EVAL(::Browser:phyPosSet, xPos)
RETURN NIL

