#include "dfWin.ch"
#include "dfMenu.ch"
#include "dfCtrl.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Appevent.ch"
#include "font.ch"
#include "dfXBase.ch"

MEMVAR ACT, A, SA

CLASS S2Window

   PROTECTED:
      METHOD ColorArray, ColorSpec

   EXPORTED:
      VAR nTop, nLeft, nBottom, nRight, cState
      VAR colorSpec

      // VAR Cargo

      VAR WOBJ_TYPE
      VAR W_ALIAS
      VAR W_ORDER
      VAR W_KEY
      VAR W_FILTER
      VAR W_BREAK
      VAR W_TAGARRAY
      VAR W_TITLE
      VAR W_COLORARRAY
      VAR W_SHADOW
      VAR W_CURRENTREC
      VAR W_BORDERGAP
      VAR W_RELATIVEPOS
      VAR W_CONTROL
      VAR W_MOUSEMETHOD
      VAR W_MENUARRAY
      VAR W_SAVESCREENID
      VAR W_AI_LENGHT
      VAR W_KEYBOARDMETHODS
      VAR W_PRIMARYKEY
      VAR W_REFRESH
      VAR W_CURRENTGET
      VAR W_MENUHIDDEN
      VAR W_CURRENTPAGE
      VAR W_PAGELABELS
      VAR W_BORDERTYPE
      VAR W_ARRTOTAL
      VAR W_CURRENTKEY
      VAR W_INHARRAY
      VAR W_OBJGOTOP
      VAR W_OBJREFRESH
      VAR W_OBJ2FORCE
      VAR W_CTRL2SYS
      VAR W_SYSSTABLE
      VAR W_DEFAULT
      VAR W_TAGFUNCTION
      VAR W_SYSFOOTER
      VAR W_BACKGROUND
      VAR W_IS2TOTAL
      VAR W_MENUPOS
      VAR W_CARGO
      VAR W_CTRL2CALC
      VAR W_PAGEMAX
      VAR W_OBJ2ADD
      VAR W_LINECURSOR
      VAR W_OBJSTABLE
      VAR W_FASTMODIFY
      VAR W_DEFAULTPOSITION
      VAR W_50ROWSUPPORT
      VAR W_ROWLINESEPARATOR
      VAR W_PAGECODEBLOCK
      VAR W_HEADERROWS        

      VAR W_OPTIMIZEMETHOD
      VAR W_OPTIMIZEOBJECT
      //VAR W_OPTIMIZEVAR

      VAR W_STRKEY
      VAR W_STRFILTER
      VAR W_STRBREAK


      // Simone 13/3/06
      // mantis 0001003: migliorare resize nelle form
      VAR W_PAGERESIZE




      METHOD Init
      METHOD handleAction
      // METHOD tbInh
      // METHOD tbTop, tbBottom, tbUp, tbDown
      // METHOD tbSetKey, tbAtr, tbEtr, tbRtr //, tbPkExp
      // ACCESS METHOD CargoGet VAR Cargo
      // ASSIGN METHOD CargoPut VAR Cargo


ENDCLASS

METHOD S2Window:Init( nType )
   ::cState            := DE_STATE_INK

   ::W_TITLE           := ""

   // ::CARGO := ARRAY( W_STRUCTURELEN )

   ::W_ALIAS           := ALIAS()

   IF ! EMPTY(::W_ALIAS)
      ::W_ORDER           := INDEXORD()   // sono gia sull'area giusta
      ::W_CURRENTREC      := IIF( EOF(), 0, RECNO() )
   ENDIF
   ::W_KEY             := NIL
   ::W_FILTER          := {|| .T. }
   ::W_BREAK           := {|| .F. }
   // ::W_TAGARRAY        := NIL
   ::W_COLORARRAY      := ::ColorArray( nType )
   ::W_SHADOW          := .T.
   ::W_CONTROL         :={}
   ::W_MOUSEMETHOD     := W_MM_ESCAPE + W_MM_MOVE + ;
                          W_MM_HSCROLLBAR + W_MM_EDIT + W_MM_PAGE
   ::W_MENUARRAY       := {}
   ::W_SAVESCREENID    := "DMM0000"
   ::W_AI_LENGHT       := NIL
   ::W_KEYBOARDMETHODS := {}
      // AADD(::W_KEYBOARDMETHODS, ARRAY(5))
      // AADD(::W_KEYBOARDMETHODS, ARRAY(5))
   ::W_PRIMARYKEY      := {}
   ::W_REFRESH         := {{},{}}
   ::W_CURRENTGET      := 0
   ::W_MENUHIDDEN      := .F.
   ::W_CURRENTPAGE     := 1
   ::W_PAGELABELS      := {}
   ::W_PAGECODEBLOCK   := {}
   // Simone 13/3/06
   // mantis 0001003: migliorare resize nelle form
   ::W_PAGERESIZE:= {}

   ::W_BORDERTYPE      := W_BT_SIMPLE
   ::W_ARRTOTAL        := {}
   ::W_CURRENTKEY      := NIL
   ::W_INHARRAY        := {}
   ::W_OBJGOTOP        := .T.
   ::W_OBJREFRESH      := .T.
   ::W_OBJ2FORCE       := {}
   ::W_CTRL2SYS        := ""
   ::W_SYSSTABLE       := .F.
   ::W_DEFAULT         := ARRAY(7)
   ::W_TAGFUNCTION     := NIL
   ::W_SYSFOOTER       := {}
   ::W_BACKGROUND      := .T.
   ::W_IS2TOTAL        := .T.
   ::W_MENUPOS         := ""
   ::W_CARGO           := NIL
   ::W_CTRL2CALC       := ""
   ::W_PAGEMAX         := 1
   ::W_OBJ2ADD         := .T.
   ::W_LINECURSOR      := .F.
   ::W_ROWLINESEPARATOR:= .F.
   ::W_HEADERROWS      := 1
   ::W_OBJSTABLE       := .F.
   ::W_FASTMODIFY      := .F.
   ::W_DEFAULTPOSITION := 1
   ::W_50ROWSUPPORT    := .T.
   ::colorSpec         := ::ColorSpec(nType, ::W_COLORARRAY)

   ::W_OPTIMIZEMETHOD := dfSet("XbaseBrowseOptimizeMethod")

   IF dfSet("XbaseRowLineSeparator")=="YES"
      ::W_ROWLINESEPARATOR:= .T.
   ENDIF

   IF EMPTY( ::W_OPTIMIZEMETHOD )
      ::W_OPTIMIZEMETHOD := W_OPT_NOOPT
   ELSE
      ::W_OPTIMIZEMETHOD := VAL( ::W_OPTIMIZEMETHOD )
   ENDIF

   ::W_OPTIMIZEOBJECT  := NIL
 //  ::W_OPTIMIZEVAR     := {}
   ::W_STRKEY          := NIL
   ::W_STRFILTER       := NIL
   ::W_STRBREAK        := NIL
RETURN self

METHOD S2Window:ColorArray( nType )
RETURN S2ColorArray( nType )

METHOD S2Window:ColorSpec( nType, aColor )
   LOCAL cColor := ""
   IF nType == W_OBJ_BRW       .OR. ;   // Metodi solo per le BROWSE
      nType == W_OBJ_ARRAYBOX  .OR. ;
      nType == W_OBJ_ARRWIN    .OR. ;
      nType == W_OBJ_BROWSEBOX

      cColor :=  aColor[AC_FRM_NORMALBOX] ; // Label
                 +"," +aColor[AC_FRM_SHADOWBOX] ; // Normal
                 +"," +aColor[AC_FRM_FUNCTION ]   // Cursor
   ENDIF
RETURN cColor

// METHOD S2Window:tbAtr()
// RETURN
//
// METHOD S2Window:tbRtr()
// RETURN
//
// METHOD S2Window:tbEtr()
//    DO WHILE ! (::W_ALIAS)->(EOF()) .AND. ;
//             (::W_ALIAS)->(DELETED())
//       ::tbDown()
//    ENDDO
//
//    IF (::W_ALIAS)->(EOF())
//       ::tbTop()
//    ENDIF
// RETURN .T.

   // IF !EMPTY(oTbr:W_ALIAS)
   //    IF nObjType == W_OBJ_FRM
   //       oTbr:GoTopBlock    := {|    |(oTbr:W_ALIAS)->(dfTop( oTbr:W_KEY, oTbr:W_FILTER, oTbr:W_BREAK ))   }
   //       oTbr:SkipBlock     := {|nRec|_tbFSkip(oTbr,nRec)                                                  }
   //       oTbr:GoBottomBlock := {|    |(oTbr:W_ALIAS)->(dfBottom( oTbr:W_KEY, oTbr:W_FILTER, oTbr:W_BREAK ))}
   //    ELSE
   //       oTbr:GoTopBlock    := {|    |_tbBTop(oTbr)                                                }
   //       oTbr:SkipBlock     := {|nRec|(oTbr:W_ALIAS)->(dfSkip( nRec, oTbr:W_FILTER, oTbr:W_BREAK ))}
   //       oTbr:GoBottomBlock := {|    |_tbBBottom(oTbr)                                             }
   //    ENDIF
   // ENDIF

// METHOD S2Window:tbTop()
// RETURN EVAL(::goTopBlock)
//
// METHOD S2Window:tbBottom()
// RETURN EVAL(::goBottomBlock)
//
// METHOD S2Window:tbDown(n)
//    DEFAULT n TO 1
// RETURN EVAL(::skipBlock, n)
//
// METHOD S2Window:tbUp( n )
//    DEFAULT n TO 1
// RETURN EVAL(::skipBlock, -n)

// METHOD S2Window:tbTop()
//    (::W_ALIAS)->(DBSETORDER(::W_ORDER))
// RETURN (::W_ALIAS)->(dfTop(::W_KEY, ::W_FILTER, ::W_BREAK))
//
// METHOD S2Window:tbBottom()
//    (::W_ALIAS)->(DBSETORDER(::W_ORDER))
// RETURN (::W_ALIAS)->(dfBottom(::W_KEY, ::W_FILTER, ::W_BREAK))
//
// METHOD S2Window:tbDown(n)
//    DEFAULT n TO 1
//    (::W_ALIAS)->(DBSETORDER(::W_ORDER))
// RETURN (::W_ALIAS)->(dfSkip(n, ::W_FILTER, ::W_BREAK))
//
// METHOD S2Window:tbUp( n )
//    DEFAULT n TO 1
//    (::W_ALIAS)->(DBSETORDER(::W_ORDER))
// RETURN (::W_ALIAS)->(dfSkip(-n, ::W_FILTER, ::W_BREAK))


// METHOD S2Window:tbSetKey(nOrd, bKey, bFlt, bBrk)
//
//    IF nOrd != NIL
//       ::W_ORDER := nOrd
//    ENDIF
//
//
//    IF bKey != NIL
//       ::W_KEY := bKey
//    ENDIF
//
//    IF bFlt != NIL
//       ::W_FILTER := bFlt
//    ENDIF
//
//    IF bBrk != NIL
//       ::W_BREAK := bBrk
//    ENDIF
//
//    IF (::W_ALIAS)->(EOF()) .OR. EVAL(::W_BREAK) .OR. ! EVAL(::bFlt)
//       ::tbTop()
//    ENDIF
//
//    // (::W_ALIAS)
//
// RETURN NIL

// METHOD S2Window:tbInh()
// RETURN


METHOD S2Window:handleAction( cAct, cState )
//    LOCAL nPos  := ASCAN(::W_KEYBOARDMETHODS, {|aMtd| aMtd[MTD_ACT] == cAct})
//    LOCAL lEval := .F.
//    LOCAL aMtd  := NIL
//
//    IF nPos > 0
//       DEFAULT cState TO ::cState
//
//       aMtd := ::W_KEYBOARDMETHODS[nPos]
//
//       IF (aMtd[MTD_WHEN] == NIL .OR. EVAL(aMtd[MTD_WHEN], cState)) .AND. ;
//          (aMtd[MTD_RUN ] == NIL .OR. EVAL(aMtd[MTD_RUN ]))
//
//          EVAL(aMtd[MTD_BLOCK], S2FormCurr())
//          lEval := .T.
//
//       ENDIF
//
//    ENDIF
// RETURN lEval

   DEFAULT cState TO ::cState

RETURN dfMtdEval( ::W_KEYBOARDMETHODS, cState, self, cAct )

// METHOD S2Window:tbPkExp()
//    LOCAL nInd := 0
//    LOCAL xVal := NIL
//    LOCAL cVal := ""
//
//    IF LEN( ::W_PRIMARYKEY ) > 1
//       // Salto il primo elemento (che Š "globalexp")
//       FOR nInd := 2 TO LEN( ::W_PRIMARYKEY )
//          xVal := EVAL(::W_PRIMARYKEY[nInd][PK_BLOCK])
//          IF VALTYPE(xVal) == "C"
//             cVal += PAD(xVal, ::W_PRIMARYKEY[nInd][PK_LEN])
//
//          ELSEIF VALTYPE(xVal) == "N"
//             cVal += STR(xVal, ::W_PRIMARYKEY[nInd][PK_LEN])
//
//          ELSEIF VALTYPE(xVal) == "D"
//             cVal += DTOS(xVal)
//          ENDIF
//       NEXT
//    ENDIF
// RETURN cVal

// METHOD S2Window:CargoGet()
//    LOCAL nInd
//    LOCAL cStr := "CARGOGET//"
//    LOCAL aRet := {}
//
//    nInd := 1
//
//    DO WHILE ! EMPTY(PROCNAME(nInd))
//       cStr+= PROCNAME(nInd)+" ("+ALLTRIM(STR(PROCLINE(nInd)))+")//"
//       nInd++
//    ENDDO
//
//
//    aRet := ARRAY(49)
//
//    aRet[ 1] := ::WOBJ_TYPE
//    aRet[ 2] := ::W_ALIAS
//    aRet[ 3] := ::W_ORDER
//    aRet[ 4] := ::W_KEY
//    aRet[ 5] := ::W_FILTER
//    aRet[ 6] := ::W_BREAK
//    aRet[ 7] := ::W_TAGARRAY
//    aRet[ 8] := ::W_TITLE
//    aRet[ 9] := ::W_COLORARRAY
//    aRet[10] := ::W_SHADOW
//    aRet[11] := ::W_CURRENTREC
//    aRet[12] := ::W_BORDERGAP
//    aRet[13] := ::W_RELATIVEPOS
//    aRet[14] := ::W_CONTROL
//    aRet[15] := ::W_MOUSEMETHOD
//    aRet[16] := ::W_MENUARRAY
//    aRet[17] := ::W_SAVESCREENID
//    aRet[18] := ::W_AI_LENGHT
//    aRet[19] := ::W_KEYBOARDMETHODS
//    aRet[20] := ::W_PRIMARYKEY
//    aRet[21] := ::W_REFRESH
//    aRet[22] := ::W_CURRENTGET
//    aRet[23] := ::W_MENUHIDDEN
//    aRet[24] := ::W_CURRENTPAGE
//    aRet[25] := ::W_PAGELABELS
//    aRet[26] := ::W_BORDERTYPE
//    aRet[27] := ::W_ARRTOTAL
//    aRet[28] := ::W_CURRENTKEY
//    aRet[29] := ::W_INHARRAY
//    aRet[30] := ::W_OBJGOTOP
//    aRet[31] := ::W_OBJREFRESH
//    aRet[32] := ::W_OBJ2FORCE
//    aRet[33] := ::W_CTRL2SYS
//    aRet[34] := ::W_SYSSTABLE
//    aRet[35] := ::W_DEFAULT
//    aRet[36] := ::W_TAGFUNCTION
//    aRet[37] := ::W_SYSFOOTER
//    aRet[38] := ::W_BACKGROUND
//    aRet[39] := ::W_IS2TOTAL
//    aRet[40] := ::W_MENUPOS
//    aRet[41] := ::W_CARGO
//    aRet[42] := ::W_CTRL2CALC
//    aRet[43] := ::W_PAGEMAX
//    aRet[44] := ::W_OBJ2ADD
//    aRet[45] := ::W_LINECURSOR
//    aRet[46] := ::W_OBJSTABLE
//    aRet[47] := ::W_FASTMODIFY
//    aRet[48] := ::W_DEFAULTPOSITION
//    aRet[49] := ::W_50ROWSUPPORT
//
// RETURN aRet
//
// METHOD S2Window:CargoPut(xVal)
//    LOCAL nInd
//    LOCAL cStr := "CARGOPUT//"
//    LOCAL aRet := {}
//
//    cStr+="xVal: "+dfAny2Str(xVal)+"//"
//
//    cStr+="----//"
//
//    nInd := 1
//
//    DO WHILE ! EMPTY(PROCNAME(nInd))
//       cStr+= PROCNAME(nInd)+" ("+ALLTRIM(STR(PROCLINE(nInd)))+")//"
//       nInd++
//    ENDDO
//
//    Alert(cStr)
//
//    // aRet := ARRAY(49)
//    //
//    // aRet[ 1] := ::WOBJ_TYPE
//    // aRet[ 2] := ::W_ALIAS
//    // aRet[ 3] := ::W_ORDER
//    // aRet[ 4] := ::W_KEY
//    // aRet[ 5] := ::W_FILTER
//    // aRet[ 6] := ::W_BREAK
//    // aRet[ 7] := ::W_TAGARRAY
//    // aRet[ 8] := ::W_TITLE
//    // aRet[ 9] := ::W_COLORARRAY
//    // aRet[10] := ::W_SHADOW
//    // aRet[11] := ::W_CURRENTREC
//    // aRet[12] := ::W_BORDERGAP
//    // aRet[13] := ::W_RELATIVEPOS
//    // aRet[14] := ::W_CONTROL
//    // aRet[15] := ::W_MOUSEMETHOD
//    // aRet[16] := ::W_MENUARRAY
//    // aRet[17] := ::W_SAVESCREENID
//    // aRet[18] := ::W_AI_LENGHT
//    // aRet[19] := ::W_KEYBOARDMETHODS
//    // aRet[20] := ::W_PRIMARYKEY
//    // aRet[21] := ::W_REFRESH
//    // aRet[22] := ::W_CURRENTGET
//    // aRet[23] := ::W_MENUHIDDEN
//    // aRet[24] := ::W_CURRENTPAGE
//    // aRet[25] := ::W_PAGELABELS
//    // aRet[26] := ::W_BORDERTYPE
//    // aRet[27] := ::W_ARRTOTAL
//    // aRet[28] := ::W_CURRENTKEY
//    // aRet[29] := ::W_INHARRAY
//    // aRet[30] := ::W_OBJGOTOP
//    // aRet[31] := ::W_OBJREFRESH
//    // aRet[32] := ::W_OBJ2FORCE
//    // aRet[33] := ::W_CTRL2SYS
//    // aRet[34] := ::W_SYSSTABLE
//    // aRet[35] := ::W_DEFAULT
//    // aRet[36] := ::W_TAGFUNCTION
//    // aRet[37] := ::W_SYSFOOTER
//    // aRet[38] := ::W_BACKGROUND
//    // aRet[39] := ::W_IS2TOTAL
//    // aRet[40] := ::W_MENUPOS
//    // aRet[41] := ::W_CARGO
//    // aRet[42] := ::W_CTRL2CALC
//    // aRet[43] := ::W_PAGEMAX
//    // aRet[44] := ::W_OBJ2ADD
//    // aRet[45] := ::W_LINECURSOR
//    // aRet[46] := ::W_OBJSTABLE
//    // aRet[47] := ::W_FASTMODIFY
//    // aRet[48] := ::W_DEFAULTPOSITION
//    // aRet[49] := ::W_50ROWSUPPORT
//
// RETURN NIL //aRet


// Metodo funzionante ma inutile. Trova se l'oggetto corrente
// Š padre di un oXbp
// METHOD S2Window:isChild( oXbp )
//    LOCAL oXPart := oXbp
//
//    DO WHILE oXPart != NIL .AND. oXPart != self
//       oXPart := oXPart:SetParent()
//    ENDDO
//
// RETURN oXPart == self
