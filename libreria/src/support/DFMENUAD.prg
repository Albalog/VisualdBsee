#include "dfMenu.ch"
#include "Common.ch"

// simone 16/6/05
// aImages=array fino 3 elementi (immagine normale, immagine disabilitata, immagine con focus)

FUNCTION dfMenuAdd( aMenuArr, cId, nType, bBlock, bRun, ;
                    cPrompt, cAct, bExec, cMsg, cHlp, ;
                    lInForm, aImages)
   LOCAL aFather, aItem, cLab

   DEFAULT bBlock  TO {|| MN_ON  }
   DEFAULT bExec   TO {|| .T.  }
   DEFAULT cAct    TO ""
   DEFAULT lInForm TO .F.

   // valori accettati NIL o array, altrimenti crea array
   IF EMPTY(aImages)
      aImages := NIL
   ELSEIF VALTYPE(aImages) != "A"
      aImages := {aImages}
   ENDIF

   IF LEN(cID) == 1
      aFather := aMenuArr
   ELSE
      aFather := dfMenuItm(aMenuArr, LEFT(cId, LEN(cId)-1))
      IF EMPTY(aFather)
         aFather := aMenuArr
      ELSE
         aFather := aFather[MNI_ARRAY]
      ENDIF
   ENDIF

   aItem               := ARRAY( MNI_LEN )

   aItem[MNI_CHILD]    := cId
   aItem[MNI_LABEL]    := cPrompt
   aItem[MNI_TYPE]     := nType
   aItem[MNI_ARRAY]    := {}
   aItem[MNI_ID   ]    := cHlp
   aItem[MNI_BSECURITY]:= bBlock

   //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012 
   cLAB   := cPrompt
   IF VALTYPE(cLAB) == "B"
      cLAB := EVAL(cLAB)
   ENDIF 
   //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012 
   //aItem[MNI_SECURITY] := EVAL(bBlock,aItem[MNI_CHILD],aItem[MNI_LABEL],aItem[MNI_ID] )
   aItem[MNI_SECURITY] := EVAL(bBlock,aItem[MNI_CHILD],cLab,aItem[MNI_ID] )
   aItem[MNI_BLOCK]    := bExec
   aItem[MNI_BRUNTIME] := bRun
   aItem[MNI_ACTION]   := cAct
   aItem[MNI_SACTION]  := dbAct2Mne(cAct)
   aItem[MNI_HELP ]    := cMsg
   aItem[MNI_IN_FORM]  := lInForm
   aItem[MNI_IMAGES]   := aImages

   // #define MNI_HELP      15 // Help at last row
   // #define MNI_LENACTION 17 // Len of LABEL
   //
   // - #define MNI_LABEL      2 // Label string
   // - #define MNI_TYPE       3 // Label type
   // - #define MNI_ARRAY      4 // Array
   // #define MNI_TOP        5 // Coordinates
   // #define MNI_LEFT       6
   // #define MNI_BOTTOM     7
   // #define MNI_RIGHT      8
   // #define MNI_POS        9
   // - #define MNI_BLOCK     16 // Block to call
   // - #define MNI_ID        18 // LABEL ID
   // - #define MNI_BSECURITY 10 // block to valutate before seeing the label
   // - #define MNI_SECURITY  11 // return of bSecurity
   // - #define MNI_BRUNTIME  12 // Code Block to evaluate at RunTime
   // - #define MNI_ACTION    13 // Action to activate
   // - #define MNI_SACTION   14 // String Action to display

   AADD(aFather, aItem)

RETURN NIL


