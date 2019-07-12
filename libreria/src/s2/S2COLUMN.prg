// Classe S2Column
// Classe generica di colonna con visualizzazione messaggio
//
// Super classes
//    XbpColumn
//
// Sub classes
//    niente
// ------------------------------------------------------------------------

#include "Font.ch"
#include "dfXBase.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "dfStd.ch"

// Simone 14/9/2005
// mantis 0000883: poter definire header delle colonne su più righe
#define HEADER_MULTILINE_SEPARATOR ";"
#define FOOTER_MULTILINE_SEPARATOR ";"

CLASS S2Column FROM XbpColumn
    PROTECTED:
    METHOD calcRows

    EXPORTED:
    VAR cMsg //, Freeze
    VAR picture
    VAR width
    VAR block
    #ifdef _XBASE200_
        VAR cheading
        VAR cfooting
    #else
        VAR heading
        VAR footing
    #endif
    VAR nHeadRows
    VAR nFootRows
    VAR lTagColumn
    VAR aPP
    //Mantis 1050
    VAR CountMode

    VAR WC_ID
    VAR WC_PROMPT
    VAR WC_TOTALVALUE
    VAR WC_PICTURE
    VAR WC_FOOTERTOTALBLOCK
    VAR WC_FOOTERINFOBLOCK
    VAR WC_EDITFIELD
    // VAR WC_COLUMNMESSAGE
#ifdef __DFPROFILER_ENABLED__
      VAR WC_COLUMNMESSAGE
      INLINE ACCESS ASSIGN METHOD WC_COLUMNMESSAGE(xVar); RETURN IIF(xVar==NIL, ::cMsg, ::cMsg:=xVar)
#else
    ACCESSVAR WC_COLUMNMESSAGE IN ::cMsg
#endif
    VAR WC_COLUMNCOLOR

    METHOD Init //, SetInputFocus //, getData

    // Simone 14/9/2005
    // mantis 0000883: poter definire header delle colonne su più righe
    INLINE METHOD setHeadRows(n)
       ::XbpColumn:heading:nUseMaxRow := n
       ::XbpColumn:heading:cSep := IIF(n>1, HEADER_MULTILINE_SEPARATOR, NIL)
    RETURN self

    INLINE METHOD setFootRows(n)
       ::XbpColumn:footing:nUseMaxRow := n
    RETURN self

    INLINE METHOD IsId(cId)
    RETURN cId == ::WC_ID

    METHOD HasHeader, HasFooter, footUpdate
    METHOD addPP

    #ifdef _XBASE200_
        ACCESS ASSIGN METHOD cheading
        ACCESS ASSIGN METHOD cfooting
    #else
        ACCESS ASSIGN METHOD heading
        ACCESS ASSIGN METHOD footing
    #endif
    ACCESS ASSIGN METHOD WC_TOTALVALUE
    ACCESS ASSIGN METHOD WC_FOOTERINFOBLOCK

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Luca 10/06/2013 : Task 1713
    //Inserita variabile per gestire correttamente, se richiesto, CB di edit prima e dopo della modifica di un cella
    VAR WC_BEFOREDIT
    VAR WC_AFTEREDIT
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

ENDCLASS

METHOD S2Column:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::XbpColumn:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::picture               := ""
   ::block                 := {|| "" }
   ::dataLink              := {|| IIF(::picture==NIL, ;
                                      EVAL(::block), ;
                                      TRIM(TRANSFORM(EVAL(::block), ::picture))) }
   ::cMsg                  := ""
   ::width                 := 0
   #ifdef _XBASE200_
       ::cheading               := NIL
       ::cfooting               := NIL
   #else
       ::heading               := NIL
       ::footing               := NIL
   #endif
   ::nHeadRows             := 0
   ::nFootRows             := 0
   ::lTagColumn            := .F.
   ::WC_ID                 := ""
   ::WC_PROMPT             := ""
   ::WC_TOTALVALUE         := NIL
   ::WC_PICTURE            := NIL
   ::WC_FOOTERTOTALBLOCK   := 0
   ::WC_FOOTERINFOBLOCK    := NIL
   ::WC_EDITFIELD          := ""
   // ::WC_COLUMNMESSAGE      := ""
   ::WC_COLUMNCOLOR        := NIL
   ::aPP                   := {}
   ::CountMode             := 0

   ::WC_BEFOREDIT          := NIL
   ::WC_AFTEREDIT          := NIL

    // Simone 14/9/2005
   // mantis 0000883: poter definire header delle colonne su più righe
   ::XbpColumn:heading := S2Cellgroup():New( self )
   //::XbpColumn:heading:cSep := HEADER_MULTILINE_SEPARATOR per default non abilita multiriga su header

   ::XbpColumn:footing := S2Cellgroup():New( self )
   ::XbpColumn:footing:cSep := FOOTER_MULTILINE_SEPARATOR

RETURN self

#ifdef _XBASE200_
METHOD S2Column:cheading( xVar )
   IF xVar != NIL
      ::cheading := xVar
      IF VALTYPE(xVar) == "C"
         ::nHeadRows := ::calcRows( ::cheading, HEADER_MULTILINE_SEPARATOR )
      ELSE
         ::nHeadRows := 0
      ENDIF
   ENDIF
RETURN ::cheading

METHOD S2Column:cfooting( xVar )
   IF xVar != NIL
      ::cfooting := xVar
      IF VALTYPE(xVar) == "C"
         ::nFootRows := ::calcRows( ::cfooting, FOOTER_MULTILINE_SEPARATOR )
      ELSE
         ::nFootRows := 0
      ENDIF

   ENDIF
RETURN ::cfooting
#else
METHOD S2Column:heading( xVar )
   IF xVar != NIL
      ::heading := xVar
      IF VALTYPE(xVar) == "C"
         ::nHeadRows := ::calcRows( ::heading, HEADER_MULTILINE_SEPARATOR )
      ELSE
         ::nHeadRows := 0
      ENDIF
   ENDIF
RETURN ::heading

METHOD S2Column:footing( xVar )
   IF xVar != NIL
      ::footing := xVar
      IF VALTYPE(xVar) == "C"
         ::nFootRows := ::calcRows( ::footing, FOOTER_MULTILINE_SEPARATOR )
      ELSE
         ::nFootRows := 0
      ENDIF

   ENDIF
RETURN ::footing
#endif

METHOD S2Column:WC_TOTALVALUE( xVar )
   IF xVar != NIL
      ::WC_TOTALVALUE := xVar
      ::nFootRows := 1
   ENDIF
RETURN ::WC_TOTALVALUE

METHOD S2Column:WC_FOOTERINFOBLOCK( xVar )
   IF xVar != NIL
      ::WC_FOOTERINFOBLOCK := xVar
      ::nFootRows := 1
      IF VALTYPE(xVar) == "B"
         xVar := EVAL(xVar)
         IF VALTYPE(xVar) == "C"
            ::nFootRows := ::calcRows(xVar, FOOTER_MULTILINE_SEPARATOR)
         ENDIF
      ENDIF
   ENDIF
RETURN ::WC_FOOTERINFOBLOCK

#ifdef _XBASE200_
METHOD S2Column:hasHeader()
RETURN ! ::cheading == NIL

METHOD S2Column:hasFooter()
RETURN ! ::cfooting == NIL            .OR. ;
       ::WC_TOTALVALUE != NIL        .OR. ;
       ::WC_FOOTERINFOBLOCK != NIL
#else
METHOD S2Column:hasHeader()
RETURN ! ::heading == NIL

METHOD S2Column:hasFooter()
RETURN ! ::footing == NIL            .OR. ;
       ::WC_TOTALVALUE != NIL        .OR. ;
       ::WC_FOOTERINFOBLOCK != NIL
#endif

// Rivisualizza il footer
// 22/2/99 - ATTENZIONE E' UN WORKAROUND. PDR 109-2800
// POTREBBE NON FUNZIONARE IN FUTURO
// --------------------------------------
METHOD S2Column:footUpdate(lReConfigure)
   LOCAL cFooting


   DEFAULT lReConfigure TO .F.

   // LOCAL nAt := AT(";", ::cfooting)     // Se Š multiriga, prende solo la 1^ riga
   //
   // IF nAt > 0
   //    cFooting := LEFT(::cfooting, nAt-1)
   //
   // ELSE
   //    cFooting := ::cfooting
   //    ::XbpColumn:footing:setCell(1, cFooting)
   // ENDIF

   #ifdef _XBASE200_
       cFooting := ::cfooting
   #else
       cFooting := ::footing
   #endif
   //Luca 03/06/2013
   //Mantis 2225
   //::XbpColumn:footing:setCell(1, cFooting)
   ::XbpColumn:footing:setCell(1, cFooting, NIL  , NIL     , lReConfigure)

   ::invalidateRect()

RETURN self

METHOD S2Column:CalcRows( cStr, cSep )
   LOCAL nRows := 0
   IF VALTYPE( cStr ) == "C"

      // Simone 14/9/2005
      // mantis 0000883: poter definire header delle colonne su più righe
      IF cSep $ cStr
         nRows := dfStrNumLines( cStr, cSep )

      ELSE
         nRows := 1  // Se non c'Š un separatore il footer Š composto da 1 riga
      ENDIF

   ENDIF
RETURN nRows


// Inserisce un pres. param se non Š gi… definito
METHOD S2Column:addPP(a, lForce)
   LOCAL nPos := 0
   LOCAL lVar := .F.

   DEFAULT lForce TO .F.

   nPos := ASCAN(::aPP, {|x| x[1] == a[1] })
   IF nPos > 0
      IF lForce
         ::aPP[nPos] := a
         lVar := .T.
      ENDIF
   ELSE
      AADD(::aPP, a)
      lVar := .T.
   ENDIF

RETURN lVar


// METHOD S2Column:SetInputFocus()
//    S2FormCurr():SetMsg(::cMsg)
//    ::XbpColumn:setInputFocus()
// RETURN self

CLASS S2CellGroup FROM XbpCellGroup
EXPORTED:
  VAR nUseMaxRow
  VAR cSep
  METHOD setCell
  METHOD create
  METHOD init
ENDCLASS


METHOD S2CellGroup:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::XbpCellGroup:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
RETURN self

METHOD S2CellGroup:create(oParent, oOwner, aPos, aSize, aPP, lVisible)
//   IF ! EMPTY(::setParent()) .AND. IsMemberVar(::setParent(), "nHeadRows")
//      ::nUseMaxRow := ::setParent():nHeadRows
//   ENDIF
   IF ::nUseMaxRow != NIL
      ::maxRow := ::nUseMaxRow
   ENDIF

   ::XbpCellGroup:create(oParent, oOwner, aPos, aSize, aPP, lVisible)
RETURN self

METHOD S2CellGroup:setCell(nRowPos, xValue, nType, lRepaint, lReConfigure)
    LOCAL lRet := .F.
    LOCAL aShow
    LOCAL nInd
    LOCAL nMax
    LOCAL nBackCol, nForeCol
    LOCAL aPP  := {}

    DEFAULT lReConfigure TO .F.

    AADD(aPP,{ XBP_PP_CGRP_CELLALIGNMENT, XBPALIGN_RIGHT + XBPALIGN_VCENTER })

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Riconfiguro il footing in quanto, se è presente un'etichetta variabile, lo scorrere delle pagine non cancella l'etichetta
    // andando a sovrapporre i valori.
    // Devo passare anche aPP in quanto lo perde
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    nBackCol := dfSet('XbaseBrowseFootingColorBG')
    nForeCol := dfSet('XbaseBrowseFootingColorFG')

    IF !EMPTY(nBackCol) .AND. Valtype(nBackCol) == "C"
       nBackCol := Val(nBackCol)
       IF !EMPTY(nBackCol)
          AADD(aPP, {XBP_PP_BGCLR              , nBackCol })
       ENDIF
    ENDIF

    IF !EMPTY(nForeCol) .AND. Valtype(nForeCol) == "C"
       nForeCol := Val(nForeCol)
       IF !EMPTY(nForeCol)
          AADD(aPP, {XBP_PP_FGCLR              , nForeCol })
       ENDIF
    ENDIF

    //A cosa le serve? Dovrebbe essere parametrizato il suo inserimento o lasciato escluso come standard
    //AADD(aPP, {XBP_PP_CGRP_FRAMELAYOUT   , XBPFRAME_NONE})


    //Luca 03/06/2013
    //Mantis 2225
    IF lReConfigure
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////
       //::XbpCellGroup:Configure(NIL, NIL, NIL, NIL, {{ XBP_PP_CGRP_CELLALIGNMENT, XBPALIGN_RIGHT + XBPALIGN_VCENTER }}, .T.)
       ::XbpCellGroup:Configure(NIL, NIL, NIL, NIL, aPP, .T.)
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    ENDIF

    IF VALTYPE(xValue) == "C" .AND. ::cSep != NIL

        // Simone 14/9/2005
        // mantis 0000883: poter definire header delle colonne su più righe
        aShow := dfStr2Arr(xValue, ::cSep)
        nMax := LEN(aShow)
        nInd := 0

        DO WHILE ++nInd <= nMax .AND. ;
                (lRet := ::XbpCellGroup:setCell(nRowPos+nInd-1, ;
                                                aShow[nInd], ;
                                                nType, lRepaint))
        ENDDO

    ELSE
       lRet := ::XbpCellGroup:setCell(nRowPos, xValue, nType, lRepaint)
    ENDIF
RETURN lRet


