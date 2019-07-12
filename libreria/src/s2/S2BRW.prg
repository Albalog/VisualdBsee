// ------------------------------------------------------------------------
// Classe S2XbpBrowser
// Classe generica di browsing con supporto colonna TAG e totali footer
//
// Super classes
//    XbpBrowse
//
// Sub classes
//    S2BrowseBox
// ------------------------------------------------------------------------
//
//
// Function/Procedure Prototype Table  -  Last Update: 06/11/98 @ 17.17.20
// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
// Return Value         Function/Arguments
// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
// self                 METHOD S2XbpBrowser:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
// ::Show()             METHOD S2XbpBrowser:DispItm()
// self                 METHOD S2XbpBrowser:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
// oCol                 METHOD S2XbpBrowser:addColumn(bBlock, nWidth, cPrompt, cMsg, cPicture)
// Void                 METHOD S2XbpBrowser:tbDelTag()
// cRet                 METHOD S2XbpBrowser:tbDisTag()
// Void                 METHOD S2XbpBrowser:tbTag( lDown )
// Void                 METHOD S2XbpBrowser:tbTagAll()
// RETURN NIL           METHOD S2XbpBrowser:tbTagPos()
// Void                 METHOD S2Column:SetInputFocus()

#include "inkey.ch"

#include "Font.ch"
#include "dfXBase.ch"
#include "dfXRes.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "dfStd.ch"
#include "DFCTRL.CH"
#include "dfSet.ch"

// Simone 14/9/2005
// mantis 0000883: poter definire header delle colonne su pi˘ righe
#define HEADER_MULTILINE_SEPARATOR ";"
#define FOOTER_MULTILINE_SEPARATOR ";"

//#define TAGCOLUMN_FONT   "14.WingDings"
//#define TAGCOLUMN_ON     IIF(SET(_SET_CHARSET) == CHARSET_ANSI, CHR(254), ConvToOemCP( CHR(254) ) )
//#define TAGCOLUMN_OFF    IIF(SET(_SET_CHARSET) == CHARSET_ANSI, CHR(168), ConvToOemCP( CHR(168) ) )

#define TAGCOLUMN_ON     COLUMN_TAG_SELECTED
#define TAGCOLUMN_OFF    COLUMN_TAG_NOT_SELECTED
#define TAGCOLUMN_WIDTH  3 // Larghezza colonna di TAG in caratteri

  /* defines for Column size mode */
  #define COLUMN_SIZEMODE_NONE       1
  #define COLUMN_SIZEMODE_LEFT       2
  #define COLUMN_SIZEMODE_RIGHT      3

//CLASS S2Browser FROM S2XbpBrowser  //, DbFilter
//EXPORTED:
//    INLINE METHOD setFontCompoundName(cFont)
//       cFont := S2ApplicationFont(cFont)
//    RETURN ::S2XbpBrowser:setFontCompoundName(cFont)
//ENDCLASS


// Nome della classe
#define _THISXBP_NAME  S2Browser

// Eredita da
#define _THISXBP_SUPER S2XbpBrowser

CLASS _THISXBP_NAME FROM _THISXBP_SUPER
PROTECTED:
   METHOD fitColumns
   METHOD endSizeColumn
   METHOD setColumnWidth
   METHOD CalcColSizes
   METHOD CalcInitWidth
   METHOD isFitColumns
   VAR _lFitColumns
   VAR _aOrigWidth

EXPORTED:
   VAR lFitColumns
   METHOD init
   METHOD create
   METHOD reSize
   ////////////////////////////////////////////////////
   //xl4665  -> problema scorrimento mouse su windows 10
   METHOD myWheel
   ////////////////////////////////////////////////////

   INLINE METHOD setFontCompoundName(cFont)
      cFont := S2ApplicationFont(cFont)
   RETURN ::S2XbpBrowser:setFontCompoundName(cFont)

ENDCLASS


METHOD _THISXBP_NAME:Init(oParent,oOwner,aPos,aSize,aPP,lVisible)
   LOCAL n
   ::_THISXBP_SUPER:init(oParent,oOwner,aPos,aSize,aPP,lVisible)

   // Simone 28/5/08
   // mantis 0001865: Ingrandendo Browser o Form con listbxo le colonne non si adattano allo spazio disponibile. Effetto grafico sgradevole.
   // gestire il resize delle colonne dei browse
   n := dfSet(AI_XBASEBRWAUTOFITCOLUMNS)
   IF n == AI_BRWAUTOFITCOLUMNS_NO
   ::lFitcolumns   := .F.
   ELSEIF n == AI_BRWAUTOFITCOLUMNS_YES
      ::lFitcolumns   := .T.
   ELSE
      ::lFitcolumns   := NIL // resize automatico
   ENDIF

   ::_lFitColumns  := .F.
   ::_aOrigWidth   := {0, 0} // larghezza iniziale
RETURN self


METHOD _THISXBP_NAME:Create(oParent,oOwner,aPos,aSize,aPP,lVisible)
   ::_THISXBP_SUPER:Create(oParent,oOwner,aPos,aSize,aPP,lVisible)

   // calcola larghezza iniziale browse e colonne
   ::calcInitWidth()

   IF ::isFitcolumns()
      ::fitColumns()
   ENDIF
RETURN self


/////////////////////////////////////////////////////////////////////////
//xl4665  Luca C. 16/11/2015 -> problema scorrimento mouse su windows 10
/////////////////////////////////////////////////////////////////////////
METHOD _THISXBP_NAME:myWheel(mp1, mp2, obj)
   LOCAL nRows
   IF EMPTY(mp2) .OR. EMPTY(mp2[2])
      RETURN self
   ENDIF
   nRows := mp2[2]/120
   IF nRows > 0
       ::tbUp(nRows*5)
   ELSE
       ::tbDown(ABS(nRows*5))
   ENDIF
RETURN self
/////////////////////////////////////////////////////////////////////////


METHOD _THISXBP_NAME:reSize(aOld,aNew)
   ::LockUpdate(.T.)
   ::_THISXBP_SUPER:resize(aOld,aNew)
   IF ::isFitColumns()
      ::fitcolumns()
   ENDIF
   ::LockUpdate(.F.)
   ::invalidateRect()
RETURN self

METHOD _THISXBP_NAME:fitColumns()
   LOCAL i,aCols
   aCols := ::CalcColSizes(self)
   FOR i := 1 TO LEN(aCols)
      ::setColumnWidth(::getColumn(i),aCols[i])
   NEXT
RETURN self

// Imposta la larghezza di una colonna
METHOD _THISXBP_NAME:setColumnWidth(oCol,nNewWidth)
   LOCAL nPos
   LOCAL aSize, n
   LOCAL nRest
    nPos := oCol:currentPos()[1]+oCol:currentSize()[1]

    // imposta la larghezza di 1 colonna

    ::nColumnSizeMode := COLUMN_SIZEMODE_RIGHT
    ::oColumnSize     := oCol
    ::nColumnCol      := nPos
    ::nColumnColOld   := ::nColumnCol
    aSize := ::oColumnSize:CurrentSize()

    ::nColumnCol := nNewWidth

    // the column itself is sized
//    nNewWidth := aSize[1] + ( ::nColumnCol - ::nColumnColOld )
    IF nNewWidth < ::nMinWidth
       nRest   :=(::nMinWidth - nNewWidth)
       nNewWidth := ::nMinWidth
       Return  nRest
    ENDIF
    ::oColumnSize:SetSize ( { nNewWidth, aSize[2] } )

    // we need to redraw the invisible columns since now former invisible
    // columns might need to be repainted
    ::RedrawInvisible()

    // now reset positions of the columns
    ::Rearrange( , TRUE )

    // reset column size mode and mouse pointer
    ::nColumnSizeMode := COLUMN_SIZEMODE_NONE
    ::oColumnSize := NIL

RETURN self

// chiamato alla fine di resize di 1 colonna
METHOD _THISXBP_NAME:EndSizeColumn ( aPos )
   LOCAL oCol := ::oColumnSize
   LOCAL nMode := ::nColumnSizeMode
   LOCAL nCol :=  ::nColumnCol
   LOCAL nColOld := ::nColumnColOld
   LOCAL i
   LOCAL lResize
   LOCAL nRest
   LOCAL nStart,nCont

   IF ! ::_lFitColumns
      RETURN ::_THISXBP_SUPER:EndSizeColumn ( aPos )
   ENDIF

      // e' l'ultima colonna?
   IF ::colCount > 0 .AND. oCol == ::getColumn(::colCount)

      IF nMode == COLUMN_SIZEMODE_RIGHT

         // se ridimensiono la riga destra annullo
         aPos[1] += nColOld-nCol

         ::_THISXBP_SUPER:EndSizeColumn ( aPos )
      ELSE
         ::_THISXBP_SUPER:EndSizeColumn ( aPos )
         i := ::colCount
         nRest := ::setColumnwidth( ::getColumn(i), ::getColumn(i):currentSize()[1]+nColOld-nCol)
      ENDIF

   ELSE
      ::_THISXBP_SUPER:EndSizeColumn ( aPos )
      lResize := .F.
      FOR i := 1 TO ::colCount
         IF lResize
            nCont := 0
            DO WHILE nCont++ <10
               nRest := ::setColumnwidth( ::getColumn(i), ::getColumn(i):currentSize()[1]+nColOld-nCol)
               IF !EMPTY(nRest) .AND. VALTYPE(nRest) == "N" .AND. nRest>0
                  IF i <::colCount
                     i++
                  ELSE
                     i := nStart
                  ENDIF
               ELSE
                  EXIT
               ENDIF
            ENDDO
            EXIT
         ENDIF
         IF ::getColumn(i) == oCol
            lResize := .T.
            nStart  :=  i
         ENDIF
      NEXT i
   ENDIF

//   ::fitcolumns()
RETURN self

// Calcola la larghezza delle colonne in modo
// da riempire sempre completament il browse
METHOD _THISXBP_NAME:CalcColSizes()
   LOCAL oBrowse := self
   LOCAL nWidth := oBrowse:currentSize()[1]
   LOCAL aColSizes := ARRAY(oBrowse:colCount)
   LOCAL nTotcolWidth := 0
   LOCAL nTotNew := 0
   LOCAL i
   LOCAL oCol
   LOCAL nNew
   LOCAL aCols := {}

   IF ::VScroll
      nWidth-= ::oVSCroll:currentSize()[1]
   ENDIF

   FOR i := 1 TO oBrowse:colCount
      oCol := oBrowse:getcolumn(i)
      aColSizes[i] := {oCol,oCol:currentSize()}
      nTotColWidth += aColSizes[i][2][1] // larghezza
   NEXT i

   IF nTotColWidth != nWidth
      nTotNew := 0
      FOR i := 1 TO LEN(aColSizes)
         oCol := aColSizes[i][1]
         IF i == LEN(aColSizes)
            nNew := nWidth - nTotNew
         ELSE
            nNew := INT(nWidth * aColSizes[i][2][1] / nTotColWidth)
         ENDIF
         nTotNew+=nNew

         AADD(aCols, nNew)

         //oCol:setSize({nNew,aColSizes[i][2][2]},.F.)
      NEXT i
   ENDIF
RETURN aCols

// Simone 28/5/08
// mantis 0001865: Ingrandendo Browser o Form con listbxo le colonne non si adattano allo spazio disponibile. Effetto grafico sgradevole.
// gestire il resize delle colonne dei browse
//
// ritorna .T.
// se la somma delle dimensioni delle colonne < spazio totale del browse
// cioä se c'ä spazio vuoto a destra
METHOD _THISXBP_NAME:isFitColumns()
   LOCAL oBrowse := self
   LOCAL nWidth := oBrowse:currentSize()[1]
   LOCAL aColSizes := ARRAY(oBrowse:colCount)
   LOCAL nTotcolWidth := 0
   LOCAL nTotNew := 0
   LOCAL i
   LOCAL oCol
   LOCAL nNew
   LOCAL aCols := {}

   IF ::lFitColumns != NIL
      ::_lFitColumns := ::lFitColumns
      RETURN ::_lFitColumns
   ENDIF

   //_aOrigWidth[1] -> Larghezza originaria listbox
   //_aOrigWidth[2] -> Larghezza originaria colonne

   // se in origine c'ä spazio vuoto a destra abilito il riempimento
   IF ::_aOrigWidth[1] - ::_aOrigWidth[2] > 0
      ::_lFitColumns := .T.
      RETURN ::_lFitColumns
   ENDIF

   IF ::VScroll
      nWidth-= ::oVSCroll:currentSize()[1]
   ENDIF

   // se c'ä spazio vuoto a destra abilito il riempimento
   ::_lFitColumns  := ::_aOrigWidth[2] < nWidth

RETURN ::_lFitColumns

// Simone 28/5/08
// mantis 0001865: Ingrandendo Browser o Form con listbxo le colonne non si adattano allo spazio disponibile. Effetto grafico sgradevole.
// gestire il resize delle colonne dei browse
// calcola larghezze iniziali browse e colonne
METHOD _THISXBP_NAME:calcInitWidth()
   LOCAL oBrowse := self
   LOCAL nWidth := oBrowse:currentSize()[1]
   LOCAL aColSizes := ARRAY(oBrowse:colCount)
   LOCAL nTotcolWidth := 0
   LOCAL nTotNew := 0
   LOCAL i
   LOCAL oCol
   LOCAL nNew
   LOCAL aCols := {}

   IF ::VScroll
      nWidth-= ::oVSCroll:currentSize()[1]
   ENDIF

   FOR i := 1 TO oBrowse:colCount
      oCol := oBrowse:getcolumn(i)
      aColSizes[i] := {oCol,oCol:currentSize()}
      nTotColWidth += aColSizes[i][2][1] // larghezza
   NEXT i

   ::_aOrigWidth := {nWidth, nTotColWidth}
RETURN self

#undef _THISXBP_NAME
#undef _THISXBP_SUPER




CLASS S2XbpBrowser FROM XbpBrowse  //, DbFilter
PROTECTED:
   VAR lDispLoop, nTagColumn, nHeadRows, nFootRows, lObjStable
   VAR aWorkAround, aTempColumn, nDispLoop
   VAR oBackground, nColorBack

   METHOD calcRows
   METHOD configureColumns
   INLINE METHOD CalcHeadRows(); RETURN ::calcRows({|oCol| oCol:nHeadRows  })
   INLINE METHOD CalcFootRows(); RETURN ::calcRows({|oCol| oCol:nFootRows  })
   METHOD __tbInsColumn, _SetColorBack()
EXPORTED:

   ///////////////////////////////////////////////////////////////////////////////////////
   //Luca 17/06/2015 mantis ???
   INLINE METHOD SetScrollHeight(nHeight);  ::XbpBrowse:nScrollHeight := nHeight; Return .T.
   ///////////////////////////////////////////////////////////////////////////////////////


#if XPPVER > 01910000
   ///////////////////////////////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////////////
   //Luca 11/05/2016 : Creato questo metodo perche con xbase 2.00 si hanno dei runtime se si chiama la Configure()
   METHOD Configure()
   ///////////////////////////////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////////////
#endif
   //Spostate da Luca perche servono per assistenza
   METHOD FindBackground()
   METHOD calcInfo()

   VAR phyPosSet, bEval, aTag, aTotal, bTagFunction
   VAR hitTop, hitBottom, stable, freeze, keyboardEnabled, colCount, lRowLine

   VAR cMes

   METHOD Init, Create, navigate, keyboard //, , Configure //, forceStable, addColumn, insColumn
   METHOD DispItm, hasFocus //, itemSelected //, itemMarked

   METHOD tbAddColumn, tbInsColumn
   METHOD tbColWidth, initColumnData

   //MANTIS 1050
   METHOD dfTAGColZero,dfTAGTotalInc,dfTAGTotalDec

   // workaround per errore su delcolumn
   INLINE METHOD getColumn(n)
   RETURN ::aTempColumn[n]

   INLINE ACCESS METHOD colCount
   RETURN LEN(::aTempColumn)

   INLINE METHOD delColumn(n)
      LOCAL oCol := ::aTempColumn[n]
//      IF oCol:status() == XBP_STAT_CREATE
//         oCol:XbpColumn:destroy()
//      ENDIF
     ::XbpBrowse:delColumn(n)
      DFAERASE(::aTempColumn, n)
   RETURN oCol

   // METHOD setInputFocus, killInputFocus

   METHOD tbTotal, tbIcv, tbDcv, tbGcv, tbStab, tbGetColumn

   METHOD _Tag, _unTag, UseTagColumn
   //METHOD __Tag

   METHOD tbGetTag, tbDisTag, tbTag, tbTagAll, tbDelTag, tbTagPos //, tbEval
   METHOD dfColZero, tbColPut, dfTotalInc, dfTotalDec

   ACCESS INLINE METHOD hitTop(); RETURN ::hitTop
   ACCESS INLINE METHOD hitBottom(); RETURN ::hitBottom

   ACCESS ASSIGN METHOD Freeze VAR freeze

   METHOD tbGenMove, tbSysFooter

   INLINE METHOD tbTop(); RETURN ::tbGenMove(K_HOME)
   INLINE METHOD tbBottom(); RETURN ::tbGenMove(K_END)

   INLINE METHOD tbReset(lFreeze)
      // il :firstcol() non funziona con SL2 beta 1.20.197
      // ok con versione 1.20.178
      ::stable := .F.
      // ::firstCol()
      ::tbTotal()
   RETURN self

   // simone 21/3/06
   // eseguo refresh dopo tbUp/tbDown
   INLINE METHOD tbDown(n)
      LOCAL x
      n := IIF(n==NIL,1,n)
      ::navigate(XBPBRW_Navigate_Skip, n)
      ///////////////////////
      //Mantis 1059
      ::Forcestable()
      ///////////////////////
//      DEFAULT n TO 1
//      FOR x := 1 TO n
//         ::down()
//      NEXT
   RETURN self

   INLINE METHOD tbUp(n)
      LOCAL x
      n := IIF(n==NIL,-1,-n)
      ::navigate(XBPBRW_Navigate_Skip, n)
      ///////////////////////
      //Mantis 1059
      ::Forcestable()
      ///////////////////////
//      DEFAULT n TO 1
//      FOR x := 1 TO n
//         ::up()
//      NEXT
   RETURN self

//   INLINE METHOD tbDown(n); RETURN EVAL(::skipBlock, IIF(n==NIL,1,n))
//   INLINE METHOD tbUp(n); RETURN EVAL(::skipBlock, IIF(n==NIL,-1,-n))
   METHOD setColorBack()

   // WORKAROUND perche la setPosAndSize non riposiziona la colonne
   // mentre la setSize si!
   INLINE METHOD setPosAndSize(aPos, aSize, lRedraw)
      DEFAULT lRedraw TO .T.
      ::lockUpdate( .T. )
      ::setPosAndSize(aPos, aSize, .F.)
      ::setSize(aSize, .F.)
      ::lockUpdate( .F. )
      IF lRedraw
         ::invalidateRect()
      ENDIF
   RETURN .T.

   // WORKAROUND PDR4629
   INLINE METHOD setSize( aNewSize, lRedraw )
      IF ::XbpBrowse:aSize[ 1 ] == 0 .OR. ::XbpBrowse:aSize[ 2 ] == 0
         ::XbpBrowse:aSize := { -1, -1 }
      ENDIF
   RETURN( ::XbpBrowse:setSize( aNewSize, lRedraw ) )

   INLINE METHOD setHeadRows(n)
      LOCAL nRet := ::nHeadRows
      IF VALTYPE(n)=="N"
         ::nHeadRows := n
      ENDIF
   RETURN nRet
ENDCLASS

#if XPPVER > 01910000
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//Luca 11/05/2016 : Creato questo metodo perche con xbase 2.00 si hanno dei runtime se si chiama la Configure()
METHOD S2XbpBrowser:Configure( oParent, oOwner, aPos, aSize, aPP, lVisible )
       ::Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
RETURN Self
#endif


METHOD S2XbpBrowser:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
            //{XBP_PP_COL_FA_FRAMELAYOUT , XBPFRAME_RECESSED+XBPFRAME_BOX }, ;

      // PARAMETRI PER BROWSE CON RIGHE VERTICALI
   aPP := { {XBP_PP_COL_HA_FRAMELAYOUT , XBPFRAME_RAISED+XBPFRAME_BOX   }, ;
            {XBP_PP_COL_FA_FRAMELAYOUT , XBPFRAME_BOX                   }, ;
            {XBP_PP_COL_DA_ROWSEPARATOR, XBPCOL_SEP_NONE                }, ;
            {XBP_PP_COL_DA_COLSEPARATOR, XBPCOL_SEP_DASHED              }, ;
            {XBP_PP_FGCLR, XBPSYSCLR_WINDOWSTATICTEXT                   }, ;
            {XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD                         } }

            //Tolto per evidenziare le righe
            //{XBP_PP_COL_DA_CELLFRAMELAYOUT , XBPFRAME_BOX               }, ;

         //  {XBP_PP_COL_DA_CELLFRAMELAYOUT , XBPFRAME_BOX               }, ;
         //  {XBP_PP_COL_DA_FRAMELAYOUT , XBPFRAME_NONE                  }, ;

   #ifndef _NOFONT_
      AADD(aPP, {XBP_PP_COMPOUNDNAME       , BROWSE_FONT  })
   #endif

   // // PARAMETRI PER BROWSE CON RIGHE ORIZZONTALI E VERTICALI
   // aPP := { {XBP_PP_COL_HA_FRAMELAYOUT , XBPFRAME_RAISED+XBPFRAME_BOX   }, ;
   //          {XBP_PP_COL_FA_FRAMELAYOUT , XBPFRAME_BOX                   }, ;
   //          {XBP_PP_COL_DA_FRAMELAYOUT , XBPFRAME_DASHED                }, ;
   //          {XBP_PP_COL_DA_COLSEPARATOR, XBPCOL_SEP_DASHED              }, ;
   //          {XBP_PP_FGCLR, XBPSYSCLR_WINDOWSTATICTEXT                   }, ;
   //          {XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD                         } }

   // PARAMETRI PER BROWSE BIANCO, SENZA RIGHE ORIZZONTALI E VERTICALI
   // aPP := { {XBP_PP_COL_HA_FRAMELAYOUT , XBPFRAME_RAISED+XBPFRAME_BOX   }, ;
   //          {XBP_PP_COL_FA_FRAMELAYOUT , XBPFRAME_RECESSED+XBPFRAME_BOX }, ;
   //          {XBP_PP_COL_DA_CELLFRAMELAYOUT , XBPFRAME_BOX                  }, ;
   //          {XBP_PP_COL_DA_FRAMELAYOUT , XBPFRAME_NONE                  }, ;
   //          {XBP_PP_COL_DA_COLSEPARATOR, XBPCOL_SEP_DASHED              }, ;
   //          {XBP_PP_COL_DA_ROWSEPARATOR, XBPCOL_SEP_NONE                }, ;
   //          {XBP_PP_COMPOUNDNAME       , APPLICATION_FONT  }, ;
   //          {XBP_PP_FGCLR, XBPSYSCLR_WINDOWSTATICTEXT                   }, ;
   //          {XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD                         } }



   //          {XBP_PP_COL_DA_FRAMELAYOUT , XBPFRAME_NONE                  }, ;
   //          {XBP_PP_COL_DA_COLSEPARATOR, XBPCOL_SEP_NONE                }, ;
   //          {XBP_PP_COL_DA_ROWSEPARATOR, XBPCOL_SEP_NONE                }, ;
   // {XBP_PP_COL_DA_COLSEPARATOR, XBPCOL_SEP_DASHED              }, ;
   // {XBP_PP_COL_DA_HILITE_BGCLR, XBPSYSCLR_INACTIVETITLETEXTBGND}  }
   // {XBP_PP_COMPOUNDNAME       , APPLICATION_FONT  }, ;
   // {XBP_PP_COL_HA_FRAMELAYOUT , XBPFRAME_RAISED   }, ;
   // {XBP_PP_FGCLR, XBPSYSCLR_INACTIVETITLETEXT     }, ;
   // {XBP_PP_BGCLR, XBPSYSCLR_INACTIVETITLETEXTBGND  }  }

   ::XbpBrowse:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::hitTopBlock     := {|| ::hitTop := .T., ::stable    :=.F. , ::hitBottom := .T., EVAL(::phyPosSet, EVAL(::phyPosBlock)) }
   ::hitBottomBlock  := {|| ::hitTop := .F., ::stable    :=.F. , ::hitBottom := .T. }
   ::stableBlock     := {|| ::hitTop := .F., ::hitBottom :=.F. , ::stable    := .T. }
   // ::setFontCompoundName(APPLICATION_FONT)
   ::aTag := NIL
   ::bEval := {|| .F. }
   ::freeze := 0
   ::nTagColumn := 0
   ::hitTop := .F.
   ::hitBottom := .F.
   ::stable := .F.
   ::keyboardEnabled := .T.
   ::aTotal := {}
   ::lDispLoop := .F.
   ::nHeadRows := 0
   ::nFootRows := 0
   ::lObjStable := .F.
   ::aWorkAround := {}
   ::aTempColumn := {}
   ::nDispLoop := 0
   ::oBackground := NIL
   ::nColorBack  := XBPSYSCLR_3DFACE //GRA_CLR_WHITE
   ::lRowLine    := .F.

RETURN self

METHOD S2XbpBrowser:Create( oParent, oOwner, aPos, aSize, aPresParam, lVisible )
   LOCAL nInd, nRows, aWS
   LOCAL cColorFG, cColorBG

   IF ::Status() == XBP_STAT_INIT

      // S2WorkSpaceSave/Rest aggiunte 8/11/2000 - Simone
      // perche altrimenti alla tbConfig sposta il record
      // corrente per gli archivi definiti nelle colonne
      // es. colonna con "MATRICO->(dfS(1, CONTRAM->MATRICOLA)), MATRICO->DESART1"
      // e spostando il record di MATRICO sbaglia l'eredita da MATRICO..
      aWS := S2WorkSpaceSave()

      DEFAULT lVisible TO .F.

      // simone 20/09/2008
      // mantis 0001944: poter impostare colori dei browse e
      // mantis 0001692: rivedere colori listbox evidenziate
      // imposta colori riga evidenziata FG e BG
      cColorFG := dfSet("XbaseBrowseHiliteColorFG")
      cColorBG := dfSet("XbaseBrowseHiliteColorBG")

      IF cColorBG != NIL
         IF S2IsNumber(cColorBG)
            S2PresParameterSet(aPresParam, XBP_PP_HILITE_BGCLR,  VAL(cColorBG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| S2PresParameterSet(aPresParam, XBP_PP_HILITE_BGCLR, n)}, .T., cColorBG)
         ENDIF
      ENDIF

      IF cColorFG != NIL
         IF S2IsNumber(cColorFG)
            S2PresParameterSet(aPresParam, XBP_PP_HILITE_FGCLR, VAL(cColorFG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| S2PresParameterSet(aPresParam, XBP_PP_HILITE_FGCLR, n)}, .T., cColorFG)
         ENDIF
      ENDIF

      // simone 20/09/2008
      // mantis 0001944: poter impostare colori dei browse e
      // mantis 0001692: rivedere colori listbox evidenziate
      // imposta colori sfondo browse
      cColorFG := dfSet("XbaseBrowseColorFG")
      cColorBG := dfSet("XbaseBrowseColorBG")

      IF cColorBG != NIL
         IF S2IsNumber(cColorBG)
            S2PresParameterSet(aPresParam, XBP_PP_BGCLR,  VAL(cColorBG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| S2PresParameterSet(aPresParam, XBP_PP_BGCLR, n)}, .T., cColorBG)
         ENDIF
      ENDIF

      IF cColorFG != NIL
         IF S2IsNumber(cColorFG)
            S2PresParameterSet(aPresParam, XBP_PP_FGCLR, VAL(cColorFG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| S2PresParameterSet(aPresParam, XBP_PP_FGCLR, n)}, .T., cColorFG)
         ENDIF
      ENDIF

      // simone 20/09/2008
      // mantis 0001944: poter impostare colori dei browse e
      // mantis 0001692: rivedere colori listbox evidenziate
      // imposta colori heading browse
      cColorFG := dfSet("XbaseBrowseHeadingColorFG")
      cColorBG := dfSet("XbaseBrowseHeadingColorBG")

      IF cColorBG != NIL
         IF S2IsNumber(cColorBG)
            S2PresParameterSet(aPresParam, XBP_PP_COL_HA_BGCLR,  VAL(cColorBG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| S2PresParameterSet(aPresParam, XBP_PP_COL_HA_BGCLR, n)}, .T., cColorBG)
         ENDIF
      ENDIF

      IF cColorFG != NIL
         IF S2IsNumber(cColorFG)
            S2PresParameterSet(aPresParam, XBP_PP_COL_HA_FGCLR, VAL(cColorFG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| S2PresParameterSet(aPresParam, XBP_PP_COL_HA_FGCLR, n)}, .T., cColorFG)
         ENDIF
      ENDIF

      // simone 20/09/2008
      // mantis 0001944: poter impostare colori dei browse e
      // mantis 0001692: rivedere colori listbox evidenziate
      // imposta colori footing browse
      cColorFG := dfSet("XbaseBrowseFootingColorFG")
      cColorBG := dfSet("XbaseBrowseFootingColorBG")

      IF cColorBG != NIL
         IF S2IsNumber(cColorBG)
            S2PresParameterSet(aPresParam, XBP_PP_COL_FA_BGCLR,  VAL(cColorBG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| S2PresParameterSet(aPresParam, XBP_PP_COL_FA_BGCLR, n)}, .T., cColorBG)
         ENDIF
      ENDIF

      IF cColorFG != NIL
         IF S2IsNumber(cColorFG)
            S2PresParameterSet(aPresParam, XBP_PP_COL_FA_FGCLR, VAL(cColorFG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| S2PresParameterSet(aPresParam, XBP_PP_COL_FA_FGCLR, n)}, .T., cColorFG)
         ENDIF
      ENDIF

      // simone 20/09/2008
      // mantis 0001944: poter impostare colori dei browse e
      // mantis 0001692: rivedere colori listbox evidenziate
      // imposta colori footing browse
      cColorFG := dfSet("XbaseBrowseDataColorFG")
      cColorBG := dfSet("XbaseBrowseDataColorBG")

      IF cColorBG != NIL
         IF S2IsNumber(cColorBG)
            S2PresParameterSet(aPresParam, XBP_PP_COL_DA_BGCLR,  VAL(cColorBG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| S2PresParameterSet(aPresParam, XBP_PP_COL_DA_BGCLR, n)}, .T., cColorBG)
         ENDIF
      ENDIF

      IF cColorFG != NIL
         IF S2IsNumber(cColorFG)
            S2PresParameterSet(aPresParam, XBP_PP_COL_DA_FGCLR, VAL(cColorFG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| S2PresParameterSet(aPresParam, XBP_PP_COL_DA_FGCLR, n)}, .T., cColorFG)
         ENDIF
      ENDIF

      // Gerr. 3044 Luca 4/11/03: Inserito IF/Else/Endif per gestire correttamente aPresParameter
      IF ::lRowLine
         //AADD(aPresParam,  {XBP_PP_COL_DA_ROWSEPARATOR,XBPCOL_SEP_LINE})
         S2PresParameterDel(aPresParam, XBP_PP_COL_DA_CELLFRAMELAYOUT)
         S2PresParameterSet(aPresParam, XBP_PP_COL_DA_FRAMELAYOUT, XBPFRAME_BOX)
      ELSE
         S2PresParameterSet(aPresParam, XBP_PP_COL_DA_CELLFRAMELAYOUT, XBPFRAME_BOX)
         S2PresParameterDel(aPresParam, XBP_PP_COL_DA_FRAMELAYOUT)
      ENDIF

      // Simone 14/9/2005
      // mantis 0000883: poter definire header delle colonne su pi˘ righe
      //nRows := ::CalcHeadRows()
      nRows := ::setHeadRows()
      IF nRows > 1
         FOR nInd := 1 TO ::colCount
            ::getColumn(nInd):setHeadRows(nRows)
         NEXT
      ENDIF

      nRows := ::CalcFootRows()
      IF nRows > 1
         FOR nInd := 1 TO ::colCount
            ::getColumn(nInd):setFootRows(nRows)
         NEXT
      ENDIF

      IF LEN(::aTempColumn) == 0
         // Se non ho colonne ne aggiungo una fittizia
         // per evitare runtime error
         ::tbAddColumn( {|| "" }, 0, "_" )
      ENDIF

      IF ! ::lObjStable
         AEVAL(::aTempColumn, {|oCol, n| ::XbpBrowse:insColumn(n, oCol) })
         //AEVAL(::aTempColumn, {|oCol| ::XbpBrowse:addColumn(oCol) })
      ENDIF


      ::XbpBrowse:Create( oParent, oOwner, aPos, aSize, aPresParam, lVisible )

      IF ! ::lObjStable
         ::configureColumns()
         ::lObjStable := .T.
      ENDIF

      // Riassegno per far eseguire il setLeftFrozen nel metodo freeze
      ::freeze := ::freeze

      // Ricalcolo larghezza colonne perchä se ce n'ä una con :width < 5
      // non funziona
      // workaround PDR 109-2581
      AEVAL(::aWorkAround, {|a| a[1]:setSize(a[2]) })

      S2WorkSpaceRest(aWS)
      ::oBackground := ::findBackground()
      ::_setColorBack(::nColorBack)
   ENDIF
RETURN self

METHOD S2XbpBrowser:keyboard(nKey)
IF ::keyboardEnabled
   IF !dfSet("XbaseBrowseMove") == "YES"

      // Per default imposto i tasti di movimento come Dbsee invece
      // che come Windows

      DO CASE
         CASE nKey == xbeK_HOME
            nKey := xbeK_CTRL_PGUP

         CASE nKey == xbeK_END
            nKey := xbeK_CTRL_PGDN

         CASE nKey == xbeK_CTRL_PGUP
            nKey := xbeK_HOME

         CASE nKey == xbeK_CTRL_PGDN
            nKey := xbeK_END
      ENDCASE
   ENDIF

   ::XbpBrowse:keyboard(nKey)
ENDIF
RETURN self


// 21/12/99: QUESTO E' OK MA FUORI STANDARD DBSEE, PERCIO' TOLTO
// METHOD S2XbpBrowser:itemSelected()
//    // Se ho selezionato e c'ä una colonna di TAG e ho il cursore
//    // a riga oppure ero sulla colonna del tag effettuo la selezione
//    IF ::nTagColumn > 0 .AND. ;
//       (::cursorMode == XBPBRW_CURSOR_ROW .OR. ;
//        ::colPos == ::nTagColumn )
//
//       ::tbTag( .F. )
//    ELSE
//       ::XbpBrowse:itemSelected()
//    ENDIF
// RETURN self

// METHOD S2XbpBrowser:itemMarked()
//    ::XbpBrowse:itemMarked()
//
//    // Effettuo il tag anche se ho fatto un solo click sulla colonna
//    // del tag ed ho il cursore a cella
//
//    IF ::nTagColumn > 0 .AND. ;
//       ::cursorMode == XBPBRW_CURSOR_CELL .AND. ;
//       ::colPos == ::nTagColumn
//
//       ::tbTag( .F. )
//    ELSE
//
//    ENDIF
// RETURN self

METHOD S2XbpBrowser:navigate(n, s)
   ::XbpBrowse:navigate(n, s)
   ::calcInfo()
RETURN self

// Reimposta header/footer su tutte le colonne
METHOD S2XbpBrowser:configureColumns()
   LOCAL nInd := 0, aSz, aPP
   LOCAL oCol
   LOCAL oPos
   LOCAL cHead
   LOCAL cFoot

   // Numero massimo di righe nel footer in tutte le colonne
   //::nHeadRows := ::CalcHeadRows()

   // Numero massimo di righe nel footer in tutte le colonne
   ::nFootRows := ::CalcFootRows()

   FOR nInd := 1 TO ::colCount

      oCol  := ::getColumn(nInd)

      //aPP := oCol:aPP

      IF ! EMPTY(::nTagColumn)
         oCol:addPP({ XBP_PP_COL_DA_ROWHEIGHT, 18 })
      ENDIF

      // IF ::hasFocus()
      //    // {XBP_PP_COL_DA_HILITE_FGCLR, GRA_CLR_WHITE     }, ;
      //    aPP := { {XBP_PP_COL_DA_HILITE_BGCLR, XBPSYSCLR_ENTRYFIELD      }  }
      // ENDIF

      #ifdef _XBASE200_
          cHead := IF(oCol:cheading==NIL,"", oCol:cheading)
          cFoot := IF(oCol:cfooting==NIL,"", oCol:cfooting)
      #else
          cHead := IIF(oCol:heading==NIL,"", oCol:heading)
          cFoot := IIF(oCol:footing==NIL,"", oCol:footing)
      #endif

      IF ::nHeadRows > 0
         oCol:addPP({ XBP_PP_COL_HA_CAPTION, cHead })
      ENDIF

      IF ::nFootRows > 0
         // Se almeno una colonna ha il footer, aggiungo il footer
         // su tutte le colonne
         oCol:addPP({ XBP_PP_COL_FA_CAPTION, cFoot })
      ENDIF

      // Calcolo larghezza colonna
      IF EMPTY(oCol:width)

         oCol:width := LEN( dfAny2Str(EVAL( oCol:dataLink ) ) )

         IF ::nHeadRows > 0
            // Simone 14/9/2005
            // mantis 0000883: poter definire header delle colonne su pi˘ righe
            IF ::nHeadRows == 1
               oCol:width := MAX(oCol:width, LEN(dfAny2Str( cHead )))
            ELSE
               oCol:width := MAX(oCol:width, dfALen(dfStr2Arr( cHead, HEADER_MULTILINE_SEPARATOR )))
            ENDIF
         ENDIF

         IF ::nFootRows > 0
            oCol:width := MAX(oCol:width, dfALen(dfStr2Arr( cFoot, FOOTER_MULTILINE_SEPARATOR )))
         ENDIF

      ENDIF

      IF ! EMPTY(oCol:width)
         oCol:addPP({ XBP_PP_COL_DA_CHARWIDTH, oCol:width })
      ENDIF

      // Per numero/data allineo a destra
      IF ! EMPTY(oCol:block)                .AND. ;
         VALTYPE(oCol:block)=="B"           .AND. ;
         VALTYPE(EVAL(oCol:block)) $ "ND"

         oCol:addPP({ XBP_PP_COL_DA_CELLALIGNMENT, XBPALIGN_RIGHT + XBPALIGN_VCENTER })
      ENDIF

      // Se ci sono i totali sul footer allineo a destra
      IF ! EMPTY(oCol:WC_TOTALVALUE)
         oCol:addPP({ XBP_PP_COL_FA_ALIGNMENT, XBPALIGN_RIGHT + XBPALIGN_VCENTER })
      ENDIF

      // Simone 31/5/01 tolto perche le bitmap non vengono allineate
      // IF ::nTagColumn > 0 .AND. ::nTagColumn == nInd
      //    oCol:addPP({ XBP_PP_COL_DA_COMPOUNDNAME, TAGCOLUMN_FONT })
      //    oCol:addPP({ XBP_PP_COL_DA_CELLALIGNMENT, XBPALIGN_HCENTER })
      // ENDIF

      //13/05/04 Luca: Inserito per gestione pixel o Row/Column
      // Non funziona perche le dimensioni delle colonne sono in caratteri
      //IF S2UsePixelCoordinateDefault()
      //   aSz := {oCol:width, 0}
      //ELSE
         // aggiungo +1 per la colonna di separazione
         // Simone 10/01/08
         // mantis 0001552: rivedere form gestite con dfAutoForm e S2AutoForm
         // in questo caso uso le dimensioni standard e non quelle da dfSet("XbaseColSize") o dfSet("XbaseRowSize")
         oPos := PosCvt():new(0, 0, COL_SIZE, ROW_SIZE)
         aSz := {(oCol:width+1) * oPos:nXMul, 0}
      //ENDIF


      oCol:configure(nil,nil,nil,aSz,oCol:aPP)

      // Lo faccio sempre perchä con il font TAHOMA
      // ho il problema anche se la larghezza >= 5!
      // workaround PDR 109-2581
      //IF oCol:width < 5
         oCol:setSize(aSz)
         AADD(::aWorkAround, {oCol, aSz})
      //ENDIF

   NEXT

RETURN self


// Torna il numero massimo di righe
METHOD S2XbpBrowser:CalcRows(bRows)
   LOCAL nRows:= 0
   LOCAL nInd := 0
   LOCAL oCol

   // Cerco se almeno una colonna ha il footer
   FOR nInd := 1 TO ::colCount
      nRows := MAX(nRows, EVAL(bRows, ::getColumn(nInd)))
   NEXT

RETURN nRows

   //Maudp-LucaC 21/03/2013 Aggiunto parametro per forzare il refresh del singolo record della listbox
//METHOD S2XbpBrowser:DispItm()
METHOD S2XbpBrowser:DispItm(lForce)
  LOCAL nPos
   // IF ! ::lDispLoop
   //
   //    ::lDispLoop := .T.  // Evito la ricorsione
   //    ::tbTotal()
   //    ::tbStab()
   //    ::lDispLoop := .F.
   // ENDIF
   LOCAL lRet := ::show(), aWS
   // ::refreshAll()
   // ::forceStable()

   //luca
   //Mantis 1050
   //////////////////
   LOCAL nCurrPos

   //Maudp-LucaC 21/03/2013 Aggiunto parametro per forzare il refresh del singolo record della listbox
   DEFAULT lForce TO .F.

   IF ::UseTagColumn()
//    Correzione Bis 1108 del 16/10/2006
//      ///////////////////////////////////
//      //Mantis 1108
      ::lockUpdate(.T. )
      aWS :=S2WorkSpaceSave()
      nPos:=EVAL(::phyPosBlock)
      ::dfTagColZero()
      AEVAL(::aTag, {|x|IIF(!EMPTY(x) .AND. VALTYPE(x)=="N" , (EVAL(::phyPosSet, x ) ,::dfTagTotalInc()), NIL )})
      ::tbColPut()
      S2WorkSpaceRest(aWS)
      IF nPos>0
         EVAL(::phyPosSet,nPos)
      ENDIF
      ::lockUpdate(.F. )
      ::Forcestable()
      ::invalidateRect()
      ::refreshAll()

//Maudp-LucaC XL 3878 21/03/2013 Aggiunto lForce per fare il refresh forzato sulle listbox (attualmente lo faceva solo in presenza di tag)
//   ENDIF
   ELSEIF lForce
      ::RefreshCurrent()
//      ::Forcestable()
   ENDIF
   ///////////////////////
RETURN lRet

METHOD S2XbpBrowser:UseTagColumn()
RETURN ::aTAG != NIL .AND. VALTYPE(::aTAG)== "A"

// METHOD S2XbpBrowser:forceStable()
//    LOCAL lRet := .F.
//
//    ::tbTotal()
//    lRet := ::XbpBrowse:forceStable()
//
// RETURN lRet

// Esegue il codeblock WC_FOOTERINFOBLOCK di tutte le colonne
METHOD S2XbpBrowser:calcInfo()
   LOCAL nInd
   LOCAL oCol
   LOCAL bBlk
   LOCAL lExec := .F.

   FOR nInd := 1 TO ::colCount
      oCol := ::getColumn(nInd)
      bBlk := oCol:WC_FOOTERINFOBLOCK
      IF ! EMPTY(bBlk)
         #ifdef _XBASE200_
             oCol:cfooting := EVAL(bBlk, self)
         #else
             oCol:footing := EVAL(bBlk, self)
         #endif
         lExec := .T.
      ENDIF
   NEXT

   IF lExec
      // Se ä cambiato qualcosa
      // riaggiorno

      ::calcFootRows()
      ::tbSysFooter()
   ENDIF

RETURN self

METHOD S2XbpBrowser:tbStab( lForce )

// Commentato perchä fa dei FLASH terribili
// #ifdef _XBASE15_
//    ::nDispLoop++
//
//    IF ::nDispLoop==1
//       ::lockUpdate(.T.)
//    ENDIF
// #endif

   IF ::rowPos < 1
      ::rowPos := 1
   ENDIF
   IF ::rowPos > ::rowCount
      ::rowPos := ::rowCount
   ENDIF

   ::dehilite()
   ::refreshAll()

   IF lForce != NIL .AND. lForce
      ::forceStable()
   ENDIF
   ::calcInfo()

// Commentato perchä fa dei FLASH terribili
// #ifdef _XBASE15_
//    ::nDispLoop--
//
//    IF ::nDispLoop==0
//       ::lockUpdate(.F.)
//       ::invalidateRect()
//    ENDIF
// #endif


RETURN self


METHOD S2XbpBrowser:tbColWidth( oCol )
   LOCAL nInd   := 0
   LOCAL nWidth := NIL

   FOR nInd := 1 TO ::colCount
      IF ::getColumn( nInd ) == oCol
         nWidth := ::getColumn( nInd ):width
         EXIT
      ENDIF
   NEXT

RETURN nWidth

METHOD S2XbpBrowser:tbGetColumn( cId )
   LOCAL oRet := NIL
   LOCAL oCol := NIL
   LOCAL nInd := 0

   IF ! EMPTY(cId)
      cId := UPPER(ALLTRIM(cId))

      FOR nInd := 1 TO ::colCount
         oCol := ::getColumn(nInd)

         IF oCol:IsId(cId)
            oRet := oCol
            EXIT
         ENDIF
      NEXT
   ENDIF

RETURN oRet

METHOD S2XbpBrowser:tbAddColumn(bBlock, nWidth, cId, cPrompt, ;
                             bTotal, cPict, cFPict, cLabel, bInfo, ;
                             cField, cMsg, aCol, lTag, nType, aPP, nCountMode)
RETURN ::__tbInsColumn(NIL,  bBlock, nWidth, cId, cPrompt, ;
                             bTotal, cPict, cFPict, cLabel, bInfo, ;
                             cField, cMsg, aCol, lTag, nType, aPP, nCountMode)

METHOD S2XbpBrowser:tbInsColumn(nColPos, bBlock, nWidth, cId, cPrompt, ;
                             bTotal, cPict, cFPict, cLabel, bInfo, ;
                             cField, cMsg, aCol, lTag, nType, aPP, nCountMode)
RETURN ::__tbInsColumn(nColPos,  bBlock, nWidth, cId, cPrompt, ;
                             bTotal, cPict, cFPict, cLabel, bInfo, ;
                             cField, cMsg, aCol, lTag, nType, aPP, nCountMode)

METHOD S2XbpBrowser:__tbInsColumn(nColPos, bBlock, nWidth, cId, cPrompt, ;
                                  bTotal, cPict, cFPict, cLabel, bInfo, ;
                                  cField, cMsg, aCol, lTag, nType, aPP, nCountMode)

   LOCAL oCol

   DEFAULT lTag    TO .F.

   oCol := S2Column():new(self, NIL, NIL, NIL, aPP)

   IF ! nType == NIL
      oCol:type := nType
   ENDIF

   IF nColPos == NIL
      nColPos := LEN(::aTempColumn) + 1
   ENDIF

   AADD(::aTempColumn, oCol, nColPos)

   // Inizializzo dopo aver aggiunto ad array aTempColumn
   // perche durante l'inizializzazione viene chiamato il
   // codeblock bInfo ecc. e se il codeblock fa riferimento
   // con la tbGetcolumn alla colonna corrente, la colonna
   // corrente non viene trovata perche ancora non ä aggiunta
   // all'array ::atempcolumn
   // (vedi funz. showTot() in gesdocb.prg di gioia )
   oCol := ::InitColumnData(oCol, bBlock, nWidth, cId, cPrompt, ;
                            bTotal, cPict, cFPict, cLabel, bInfo, ;
                            cField, cMsg, aCol, lTag, nType, aPP, nCountMode)

   IF bTotal != NIL
      AADD(::aTotal, oCol)
   ENDIF

   IF lTag
      ::nTagColumn := nColPos
   ENDIF


   /////////////////////////////////////////////////////////////////////////
   //mantsi 2262 Luca C. 16/11/2015
   //xl4665  Luca C. 16/11/2015 -> problema scorrimento mouse su windows 10
   oCol:DataArea:Wheel := {|mp1, mp2, obj| ::myWheel(mp1, mp2, obj)}
   /////////////////////////////////////////////////////////////////////////


RETURN oCol


METHOD S2XbpBrowser:InitColumnData(oCol, bBlock, nWidth, cId, cPrompt, ;
                                   bTotal, cPict, cFPict, cLabel, bInfo, ;
                                   cField, cMsg, aCol, lTag, nType, aPP, nCountMode)
   DEFAULT cId     TO ""
   //DEFAULT cPrompt TO ""
   DEFAULT cField  TO ""
   DEFAULT cMsg    TO ""
   //DEFAULT cLabel  TO ""
   DEFAULT lTag    TO .F.
   //Mantis 1050
   DEFAULT nCountMode TO COLUMN_DEFAULT_COUNT

   IF lTag
      nWidth    := TAGCOLUMN_WIDTH
   ENDIF

   cPrompt := dbMMrg( cPrompt )

   // aggiunge o inserisce colonna
//   IF nColPos != NIL
//      oCol := ::insColumn(nColPos, bBlock, nWidth, cPrompt, cLabel, nType, aPP)
//   ELSE
//      oCol := ::addColumn(bBlock, nWidth, cPrompt, cLabel, nType, aPP)
//   ENDIF

   oCol:cMsg        := cMsg
   oCol:picture     := cPict
   oCol:width       := nWidth
   oCol:block       := bBlock
   oCol:lTagColumn  := lTag
   ////////////////////////////////////////////
   //Mantis 1050
   oCol:CountMode   := nCountMode
   ////////////////////////////////////////////

   #ifdef _XBASE200_
       oCol:cheading( cPrompt )
       oCol:cfooting( cLabel  )
   #else
       oCol:heading( cPrompt )
       oCol:footing( cLabel  )
   #endif

   oCol:WC_ID                 := UPPER( ALLTRIM(cId) )
   oCol:WC_PICTURE            := cFPict
   oCol:WC_PROMPT             := cPrompt
   oCol:WC_FOOTERINFOBLOCK( bInfo )
   oCol:WC_EDITFIELD          := cField

   IF bTotal != NIL
      oCol:WC_TOTALVALUE( bTotal )
   ENDIF

   IF lTag
      oCol:XbpColumn:heading:lbClick := {|| ::tbTagAll() }
      oCol:XbpColumn:heading:rbClick := {|| ::tbDelTag() }
      oCol:dataArea:lbClick := {|| ::tbTag( .F. ) }

      oCol:type := XBPCOL_TYPE_BITMAP
   ENDIF

RETURN oCol

METHOD S2XbpBrowser:hasFocus()
RETURN SetAppFocus() == self

METHOD S2XbpBrowser:Freeze(nFreeze)
   LOCAL aFreeze

   IF ! nFreeze == NIL

      aFreeze := ARRAY(nFreeze)
      AEVAL(aFreeze, {|x,n| aFreeze[n] := n} )
      ::freeze := aFreeze

      IF ::Status() == XBP_STAT_CREATE
         ::setLeftFrozen( ::freeze )
      ENDIF

   ENDIF

   // IF aFreeze == NIL
   //    aFreeze := ::setLeftFrozen()
   // ENDIF

RETURN LEN(::freeze) //LEN(aFreeze)


// --------------------------
// Metodi per gestione TOTALI
// --------------------------
METHOD S2XbpBrowser:tbTotal( lDisplay )      // Totali di colonna
   IF !EMPTY(::aTotal)                    // Se ho colonne
     ::dfColZero()                        // Azzero i totali
     EVAL(::bEval, {||::dfTotalInc()} )   // Effettuo dei totali
     ::tbColPut( lDisplay )               // Metto i totali nel FOOTER
   ENDIF
RETURN self

METHOD S2XbpBrowser:tbIcv(lTag,lDisplay)                  // Incremento totali di colonna
   DEFAULT lTag TO .F.
   IF !EMPTY(::aTotal)                    // Se ho colonne
      IF lTag
         ::dfTAGTotalInc()                   // Incrementa i Totali Colonna TAG
      ELSE
         ::dfTotalInc()                      // Incrementa i Totali
      ENDIF
      ::tbColPut(lDisplay)                        // Metto i totali nel FOOTER
   ENDIF
RETURN self

METHOD S2XbpBrowser:tbDcv(lTag,lDisplay)                  // Cancella Totali di colonna
   DEFAULT lTag TO .F.
   IF !EMPTY(::aTotal)                    // Se ho colonne
      IF lTag
        ::dfTAGTotalDec()                      // Decrementa i Totali Colonne Tag
      ELSE
        ::dfTotalDec()                         // Decrementa i Totali
      ENDIF
      ::tbColPut(lDisplay)                        // Metto i totali nel FOOTER
   ENDIF
RETURN self

METHOD S2XbpBrowser:tbGcv( cId )                 // Get Totali di colonna
   LOCAL nValue := 0, nCol
   IF !EMPTY(::aTotal)                        // Se ho colonne
      cId := UPPER(cId)
      nCol := ASCAN( ::aTotal, {|oSub|oSub:WC_ID==cId} )
      IF nCol>0
         nValue := ::aTotal[nCol]:WC_FOOTERTOTALBLOCK
      ENDIF
   ENDIF
RETURN nValue

METHOD S2XbpBrowser:dfColZero()      // Inizializza i Totali
   AEVAL( ::aTotal, {|oSub|oSub:WC_FOOTERTOTALBLOCK:=0} )
RETURN self
METHOD S2XbpBrowser:dfTAGColZero()      // Inizializza i Totali Colonne Tag
   LOCAL nN,oSub
   FOR nN := 1 TO LEN(::aTotal)
       oSub:= ::aTotal[nN]
       IF oSub:CountMode==COLUMN_TAG_COUNT
          oSub:WC_FOOTERTOTALBLOCK := 0
       ENDIF
   NEXT
RETURN self


METHOD S2XbpBrowser:dfTAGTotalInc()     // Inc dei Totali  Colonne Tag
   LOCAL nN,oSub
   FOR nN := 1 TO LEN(::aTotal)
       oSub:= ::aTotal[nN]
       IF oSub:CountMode==COLUMN_TAG_COUNT
          EVAL(oSub:BLOCK)
          oSub:WC_FOOTERTOTALBLOCK+=EVAL(oSub:WC_TOTALVALUE)
       ENDIF
   NEXT

RETURN self
METHOD S2XbpBrowser:dfTAGTotalDec()     // Dec dei Totali  Colonne Tag
   LOCAL nN,oSub
   FOR nN := 1 TO LEN(::aTotal)
       oSub:= ::aTotal[nN]
       IF oSub:CountMode==COLUMN_TAG_COUNT
          EVAL(oSub:BLOCK)
          oSub:WC_FOOTERTOTALBLOCK-=EVAL(oSub:WC_TOTALVALUE)
       ENDIF
   NEXT
RETURN self

METHOD S2XbpBrowser:dfTotalInc()     // Inc dei Totali
   AEVAL( ::aTotal, {|oSub| EVAL(oSub:BLOCK) ,;
                            oSub:WC_FOOTERTOTALBLOCK+=EVAL(oSub:WC_TOTALVALUE)})
RETURN self



METHOD S2XbpBrowser:dfTotalDec()     // Dec dei Totali
   AEVAL( ::aTotal, {|oSub| EVAL(oSub:BLOCK) ,;
                            oSub:WC_FOOTERTOTALBLOCK-=EVAL(oSub:WC_TOTALVALUE)})
RETURN self

METHOD S2XbpBrowser:tbColPut( lDisplay )    // Put dei totali nel FOOTER
   LOCAL nCount , cFoot, oSub
   LOCAL lReConfigure := .F.
   DEFAULT lDisplay TO .T.

   IF dfSet("XbaseReconfigurefooteritem") == "YES"
      lReConfigure := .T.
   ENDIF

   FOR nCount := 1 TO LEN(::aTotal)
      oSub  := ::aTotal[nCount]
      cFoot := TRANSFORM( oSub:WC_FOOTERTOTALBLOCK, oSub:WC_PICTURE )
      /////////////////////////////////
      //Mantis 983
      cFoot := ALLTRIM(cFoot)
      /////////////////////////////////
      cFoot := PADL( cFoot, ::tbColWidth( oSub ) )
      #ifdef _XBASE200_
          oSub:cFOOTING := cFoot
      #else
          oSub:FOOTING := cFoot
      #endif

      // rivisualizza il footer
      oSub:footUpdate(lReConfigure)
   NEXT

RETURN self

// Redisplay di tutti i footer
METHOD S2XbpBrowser:tbSysFooter()
   LOCAL nInd
   LOCAL oCol
   LOCAL lReConfigure := .F.

   IF dfSet("XbaseReconfigurefooteritem") == "YES"
      lReConfigure := .T.
   ENDIF


   FOR nInd := 1 TO ::colCount
      oCol := ::getColumn(nInd)
      // IF oCol:cfooting != NIL
      /////////////////////////////////////
      //Mantis 1610
      //IF oCol:cfooting != NIL .AND. oCol:cfooting == ""
      /////////////////////////////////////
      #ifdef _XBASE200_
      IF VALTYPE(oCol:cfooting) == "C"  .AND. oCol:cfooting == ""
         oCol:cfooting := " "
      ENDIF
      #else
      IF VALTYPE(oCol:footing) == "C"  .AND. oCol:footing == ""
         oCol:footing := " "
      ENDIF
      #endif
      oCol:footUpdate(lReConfigure)
      // ENDIF
   NEXT
RETURN self

// -------------------------------
// Metodi per gestione colonna TAG
// -------------------------------
METHOD S2XbpBrowser:tbGetTag()
RETURN ASCAN(::aTag, EVAL(::phyPosBlock)) > 0

METHOD S2XbpBrowser:tbDisTag()
   LOCAL cRet
   IF ASCAN(::aTag, EVAL(::phyPosBlock)) > 0
      cRet := TAGCOLUMN_ON
   ELSE
      cRet := TAGCOLUMN_OFF
   ENDIF
RETURN cRet

METHOD S2XbpBrowser:tbTag( lDown )
   LOCAL nPos := ::tbTagPos()
   LOCAL lTag := .F.

   DEFAULT lDown TO .T.

   IF nPos > 0
      ::_unTag(nPos)
   ELSE
      ::_Tag()
   ENDIF

   // mantis 1050
   // display totali su TAG
   IF ::UseTagColumn()
      ::tbColPut()
   ENDIF

   ::calcInfo()

   ::refreshCurrent()

   IF lDown
      ::down()
      ::refreshCurrent()
   ENDIF


RETURN

//non ä mai stata utilizzata
//METHOD S2XbpBrowser:__Tag(nPos)
//   IF LEN(::aTag)>0 .AND. nPOs>0
//      EVAL(::phyPosSet, nPos )
//      IF ::tbTagPos() <= 0
//         ::_Tag()
//      ENDIF
//   ENDIF
//RETURN self


METHOD S2XbpBrowser:_Tag()
   LOCAL xPos := EVAL(::phyPosBlock)

   // IF TOLTO per cambiamento posblock,lastposblock con percentuali
   //IF xPos <= EVAL(::lastPosBlock) // Se non sono in EOF effettuo il TAG
      AADD(::aTag, xPos)
      IF ! EMPTY(::bTagFunction)
         EVAL(::bTagFunction, .T. )
      ENDIF
   //ENDIF
    //Mantis 1050
    IF ::UseTagColumn() .AND. ;
       !EMPTY(::aTotal)                    // Se ho colonne
       ::dfTAGTotalInc()                   // Incrementa i Totali Colonna TAG
       //::tbIcv(.T.)
    ENDIF
RETURN self

METHOD S2XbpBrowser:_unTag(nPos)
   IF nPos > 0
      DFAERASE(::aTag, nPos)
      IF ! EMPTY(::bTagFunction)
         EVAL(::bTagFunction, .F. )
      ENDIF
      // Mantis 1050
      IF ::UseTagColumn() .AND. ;
         !EMPTY(::aTotal)                    // Se ho colonne
         ::dfTAGTotalDec()                   // Incrementa i Totali Colonna TAG
         //::tbDcv(.T.)
      ENDIF
   ENDIF
RETURN self


METHOD S2XbpBrowser:tbTagAll()
   EVAL(::bEval, {|| IIF(::tbTagPos() > 0, NIL, ::_Tag() ) })
   // mantis 1050
   // display totali su TAG
   IF ::UseTagColumn()
      ::tbColPut()
   ENDIF

   ::calcInfo()
   ::refreshAll()
RETURN

METHOD S2XbpBrowser:tbDelTag()

   IF ! ::UseTagColumn()
      RETURN
   ENDIF

   IF EMPTY(::bTagFunction)
      ASIZE(::aTag, 0)
   ELSE
//Mantis 2221
//Maudp 29/05/2013 L'untag di tutta la colonna lo effettuava senza tenere in considerazione il FILTER impostato sulla lsb
/*
      DO WHILE LEN(::aTag) > 0
         EVAL(::phyPosSet, ATAIL(::aTag) )
         ::_unTag(LEN(::aTag))
      ENDDO
*/
      IF LEN(::aTag) > 0
         EVAL(::bEval, {|| IIF(!::tbTagPos() > 0, NIL, ::_UnTag(::tbTagPos()) ) })
      ENDIF
   ENDIF

   ::dfTAGColZero()

   // mantis 1050
   // display totali su TAG
   // simone 23/10/08 messo il .F. per cercare di evitare dei refresh
   // eseguiti da s2brwbox:tbColPut() .. visto che fa il refreshAll() qui sotto
   ::tbColPut(.F.)  // Metto i totali nel FOOTER

   ::calcInfo()
   ::refreshAll()
RETURN

METHOD S2XbpBrowser:tbTagPos()
RETURN ASCAN(::aTag, EVAL(::phyPosBlock))


METHOD S2XbpBrowser:tbGenMove(nMove)
   LOCAL lStab
   DO CASE
      CASE nMove==K_HOME ;IF( lStab:=::HITTOP()   ,,::GOTOP()   )
      CASE nMove==K_END  ;IF( lStab:=::HITBOTTOM(),,::GOBOTTOM())

      // CASE nMove==K_HOME ;IF( lStab:=.F.             ,,::GOTOP()   )
      // CASE nMove==K_END  ;IF( lStab:=.F.             ,,::GOBOTTOM())

   ENDCASE
   IF !::STABLE .OR. !lStab
      IF nMove==K_HOME
         ::tbTotal()
         ::tbStab( .T. )
      ELSE
         ::tbStab()
      ENDIF
      // ::tbSysFooter()
   ENDIF
 // tbSayOpt( oTbr, W_MM_VSCROLLBAR )

RETURN self

// Imposta la variabile del colore dello sfondo del browse
METHOD S2XbpBrowser:setColorBack(nColor)
  LOCAL nRet := ::nColorBack

  IF nColor != NIL
     ::nColorBack := nColor
  ENDIF

  ::_setColorBack(::nColorBack)
RETURN nRet

// Imposta il colore di sfondo del browse
// e' attivo solo dopo il :create()
METHOD S2XbpBrowser:_setColorBack(nColor)
  IF ::oBackground != NIL .AND. nColor != NIL .AND. ;
     ::oBackground:setColorBG() != nColor

     ::oBackground:Type :=XBPSTATIC_TYPE_TEXT
     ::oBackground:Configure()
     ::oBackground:SetColorBG( nColor )

  ENDIF
RETURN self

// Cerca l'oggetto che contiene il background
// puï essere chiamato solo dopo il :create()
METHOD S2XbpBrowser:findBackground()
  LOCAL oBack
  LOCAL aChild
  LOCAL n
  aChild := ::ChildList()
  n := AScan( aChild, { | o | o:Type == XBPSTATIC_TYPE_BGNDRECT } )
  IF n > 0
     oBack := aChild[n]
  ENDIF
RETURN oBack

