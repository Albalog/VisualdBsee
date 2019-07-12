#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
// #include "Appevent.ch"
// #include "Font.ch"
#include "dfWin.ch"
#include "dfCtrl.ch"
#include "dfReport.ch"
#include "dfWinRep.ch"
#include "dfMsg.ch"
#include "dfMsg1.ch"
#include "dfPDF.ch"
#include "XbpDev.ch"
#include "dfXBase.ch"

MEMVAR ACT

CLASS S2PrintMenu FROM S2ModalDialog
   EXPORTED:

      * Contained control elements
      VAR btnCancel
      VAR btnOK
      VAR btnPreview
      VAR btnFilter
      VAR grpDispositivi
      VAR grpOptions
      VAR nInitDisp

      VAR grpChar
      VAR rdbChNorm
      VAR rdbChComp
      VAR manifest1

      VAR lsbDispositivi
      VAR txtDispositivi
      VAR btnPages
      VAR btnMargini
      VAR aDispositivi
      VAR nAction
      VAR oCurrDisp
      VAR bDispMark
      VAR aBuffer
      VAR oPreview
      VAR aKeys
      VAR lBtnMargShow
      VAR lCharShow
      VAR lBtnPages


      METHOD init
      METHOD create
      METHOD tbInk
      METHOD dispMark
      METHOD addDisp
      METHOD HandleShortCut
      METHOD addShortCut

      METHOD dfChoSet
      METHOD dfPageRep
      METHOD dfMgnTop
      METHOD keyBoard
      INLINE METHOD getCurrDisp(); RETURN ::oCurrDisp
      INLINE METHOD getAllDisp() ; RETURN ::aDispositivi

      // Metodi per compatibilit… con funzione dfUsrState
      INLINE METHOD getState(); RETURN DE_STATE_MOD
      INLINE METHOD setState(); RETURN NIL


      METHOD SetPageAndOrientation
ENDCLASS

******************************************************************************
* Initialize form
******************************************************************************
METHOD S2PrintMenu:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp

   DEFAULT oParent  TO AppDesktop(), ;
           aPos     TO {215,187}, ;
           aSize    TO {645,348}, ;
           lVisible TO .F.

   DEFAULT aPP TO {}
   AAdd ( aPP, { XBP_PP_COMPOUNDNAME, FONT_HELV_SMALL } )
   //AAdd ( aPP, { XBP_PP_COMPOUNDNAME, "8.Arial" } )

   ::aKeys := {}
   ::lBtnMargShow := .T.
   ::lCharShow  := .T.

   ::lBtnPages := ! dfset("XbaseWinPrinterDisablePageButton") == "YES"
   DEFAULT ::lBtnPages  TO  .T.

   ::S2ModalDialog:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::taskList := .T.
   ::title := dfStdMsg1(MSG1_S2PRNMNU01) 
   ::maxButton := .F.
   ::minButton := .F.
#ifdef _XBASE182_
   ::drawingArea:clipChildren := .T. // Simone 2/9/03 PDR4873 GERR 3916
#endif
   ::close := {|| ::nAction := 0 }

   oXbp     := XbpPushButton():new( ::drawingArea, , {204,12}, {96,24})
   oXbp:caption := dfStdMsg1(MSG1_S2PRNMNU02) 
   oXbp:activate := {|u1,u2,o| IIF(o:isVisible(), dfFltRep( ::aBuffer ), NIL) }
   oXbp:tabStop := .T.
   ::addShortCut(oXbp:caption, oXbp)
   ::addShortCut("A_f", oXbp)
   ::btnFilter := oXbp

   oXbp     := XbpPushButton():new( ::drawingArea, , {312,12}, {96,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PRNMNU03) 
   oXbp:activate := {|| ::oPreview:setCurrDisp(::oCurrDisp), ;
                        ::oCurrDisp := ::oPreview, ;
                        ::nAction := 2 }
   oXbp:tabStop := .T.
   ::addShortCut(oXbp:caption, oXbp)
   ::addShortCut("new", oXbp)
   ::btnPreview := oXbp

   oXbp          := XbpPushButton():new( ::drawingArea, , {420,12}, {96,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PRNMNU04) 
   oXbp:activate := {|| ::nAction := 1}
   oXbp:tabStop := .T.
   ::addShortCut(oXbp:caption, oXbp)
   ::addShortCut("wri", oXbp)
   ::btnOK := oXbp

   oXbp      := XbpPushButton():new( ::drawingArea, , {528,12}, {96,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PRNMNU05) 
   oXbp:activate := {|| ::nAction := 0}
   oXbp:tabStop := .T.
   ::btnCancel := oXbp
   ::addShortCut(oXbp:caption, oXbp)
   ::addShortCut("esc", oXbp)

   oXbp        := XbpStatic():new( ::drawingArea, , {0,204}, {636,114} )
   oXbp:caption := dfStdMsg1(MSG1_S2PRNMNU06) 
   oXbp:type := XBPSTATIC_TYPE_GROUPBOX
   ::grpOptions := oXbp

   oXbp        := XbpStatic():new( ::grpOptions, , {12,84}, {84,14} )
   oXbp:caption := dfStdMsg1(MSG1_S2PRNMNU07)
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   ::txtDispositivi := oXbp

   oXbp := XbpListBox():new( ::grpOptions, , {12,12}, {384,72}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:itemMarked := {|| ::DispMark() }
   oXbp:tabStop := .T.
   ::addShortCut(::txtDispositivi:caption, oXbp)
   ::lsbDispositivi := oXbp

   // Per GERR 3916 aggiungo uno static con clipChildren=.t.
   oXbp        := XbpStatic():new( ::grpOptions, , {412,12}, {100,84} )
#ifdef _XBASE182_
   oXbp:clipChildren := .T. // Simone 2/9/03 PDR4873 GERR 3916
#endif
   ::manifest1 := oXbp

   oXbp        := XbpStatic():new( ::manifest1, , {0,0}, {100,84} )
   //oXbp        := XbpStatic():new( ::grpOptions, , {412,12}, {100,84} )
   oXbp:caption := dfStdMsg1(MSG1_S2PRNMNU08) 
   oXbp:type := XBPSTATIC_TYPE_GROUPBOX
   ::grpChar := oXbp

   oXbp      := XbpRadiobutton():new( ::grpChar, , {12,36}, {80,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PRNMNU09) 
   oXbp:selected := {|| ::aBuffer[REP_IS_CONDENSED] := .F. }
   oXbp:tabStop := .T.
   ::rdbChNorm := oXbp

   oXbp      := XbpRadiobutton():new( ::grpChar, , {12,12}, {80,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PRNMNU10) 
   oXbp:selected := {|| ::aBuffer[REP_IS_CONDENSED] := .T. }
   oXbp:tabStop := .T.
   ::rdbChComp := oXbp


   IF ::lBtnPages
      oXbp       := XbpPushButton():new( ::grpOptions, , {528,60}, {96,24} )
      oXbp:caption := dfStdMsg1(MSG1_S2PRNMNU11) 
      oXbp:activate := {|| ::dfPageRep( ::aBuffer ) }
      oXbp:tabStop := .T.
      ::addShortCut(oXbp:caption, oXbp)
      ::btnPages := oXbp
   ENDIF

   oXbp     := XbpPushButton():new( ::grpOptions, , {528,24}, {96,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PRNMNU12) 
   oXbp:activate := {|| ::dfChoSet( ::aBuffer ) }
   oXbp:tabStop := .T.
   ::addShortCut(oXbp:caption, oXbp)
   ::btnMargini := oXbp

   oXbp        := XbpStatic():new( ::drawingArea, , {0,60}, {636,138} )
   oXbp:type := XBPSTATIC_TYPE_GROUPBOX
   ::grpDispositivi := oXbp

   oXbp := S2PrintDispPreview():new(::grpDispositivi)
   ::oPreview := oXbp

   ::aBuffer := NIL

   ::aDispositivi := {}
   ::oCurrDisp := NIL
   ::bDispMark := {|| .T. }
   ::nInitDisp := 1
RETURN self


******************************************************************************
* Request system resources
******************************************************************************
METHOD S2PrintMenu:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL nInd, oDisp, cDispName
   ::S2ModalDialog:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::btnFilter:create(NIL,NIL,NIL,NIL,NIL, dfPrnFlt( ::aBuffer ))
   ::btnPreview:create()
   ::btnOK:create()
   ::btnCancel:create()

   ::grpOptions:create()
   ::lsbDispositivi:create()
   ::txtDispositivi:create()

   IF ::aBuffer[REP_IS_CONDENSED]
      ::rdbChComp:selection := .T.
   ELSE
      ::rdbChNorm:selection := .T.
   ENDIF

   IF ::lCharShow
      ::manifest1:create()
      ::grpChar:create()
      ::rdbChNorm:create()
      ::rdbChComp:create()
   ENDIF

   IF ::lBtnPages
      ::btnPages:create()
   ENDIF
   IF ::lBtnMargShow
      ::btnMargini:create()
   ENDIF

   ::grpDispositivi:create()

   IF LEN(::aDispositivi) > 0

      aPos := {3,3}

      aSize := ::grpDispositivi:currentSize()

      aSize[1] -= aPos[1]*2
      aSize[2] -= aPos[2]*5

      FOR nInd := 1 TO LEN(::aDispositivi)
         oDisp := ::aDispositivi[nInd]

         cDispName := IIF(oDisp:dispName==NIL,;
                        dfStdMsg1(MSG1_S2PRNMNU13) +ALLTRIM(STR(nInd)), ;
                        oDisp:dispName)

         oDisp:create(::grpDispositivi, ::grpDispositivi, aPos, aSize)
         oDisp:setPrintMenu(self)
         ::lsbDispositivi:addItem(cDispName)

         IF oDisp:isDefault()
            ::nInitDisp := ::lsbDispositivi:numItems()
         ENDIF

      NEXT

      ::lsbDispositivi:setData({::nInitDisp}, .T. )
   ENDIF

   ::oPreview:aBuffer := ::aBuffer
   ::oPreview:create()
   ::oPreview:setPrintMenu(self)

   ::CenterPos()

   ::dispMark()

   ::nAction := -1
RETURN self

METHOD S2PrintMenu:addDisp(oDisp)
   AADD(::aDispositivi, oDisp)
   oDisp:aBuffer := ::aBuffer

   //::lsbDispositivi:addItem(IIF(oDisp:dispName==NIL,dfStdMsg1(MSG1_S2PRNMNU13) +ALLTRIM(STR(LEN(::aDispositivi))), oDisp:dispName))
   // oDisp:setOwner(::grpDispositivi)
   // oDisp:setParent(::grpDispositivi)
   // oDisp:setPos({0,0})
   // oDisp:setSize(::grpDispositivi:currentSize())
   // oDisp:setFontCompoundName(::setFontCompoundName())
RETURN self

METHOD S2PrintMenu:tbInk()
   LOCAL nEvent, mp1, mp2, oXbp
   // Modifica Luca 21/05/03 In modo che quando 
   // parte ha il focus sul pulsante stampa come era nella versione dos
   // SetAppFocus(::lsbDispositivi)
   SetAppFocus(::btnOK)

   // Valori di :nAction
   // -1 = rimane nel loop
   //  0 = esce dal loop e annulla (ESC)
   //  1 = esce dal loop e avvia la stampa sul dispositivo scelto
   //  2 = esce dal loop e avvia la stampa sul dispositivo di anteprima

   ::nAction := -1

   DO WHILE ::nAction == -1

      nEvent := dfAppEvent( @mp1, @mp2, @oXbp )

      #ifdef _S2DEBUG_
         S2DebugOut(oXbp, nEvent, mp1, mp2)
      #endif

      oXbp:handleEvent( nEvent, mp1, mp2 )

      IF ::nAction != -1
         ::nAction := ::oCurrDisp:exitMenu(::nAction, ::aBuffer)
      ENDIF

   ENDDO

RETURN self

METHOD S2PrintMenu:keyboard(nKey)
   dbActSet( nKey )
   DO CASE
      CASE ACT == "ret" .AND. ;
          (SetAppFocus():isDerivedFrom("XbpPushButton") .OR. ;
           SetAppFocus():isDerivedFrom("_PushButton"))
        // 13/07/04 simone GERR 4087
         EVAL(SetAppFocus():activate, NIL, NIL, SetAppFocus())

      CASE ::handleShortCut( ACT, ::aKeys )
         // non fa niente

      CASE ! EMPTY(::oCurrDisp) .AND. ;
           ::handleShortCut( ACT, ::oCurrDisp:aKeys )
         // non fa niente

      CASE ACT == "dar" .OR. ACT == "rar"
         PostAppEvent(xbeP_Keyboard, xbeK_TAB, NIL, self)

      CASE ACT == "uar" .OR. ACT == "lar"
         PostAppEvent(xbeP_Keyboard, xbeK_SH_TAB, NIL, self)

      OTHERWISE
         // Gestione standard
         ::S2ModalDialog:keyboard(nKey)

   ENDCASE
RETURN self


METHOD S2PrintMenu:dispMark()
   LOCAL aMark := ::lsbDispositivi:getData()
   LOCAL nNewDisp := IIF(LEN(aMark) == 1, aMark[1], 0)

   IF EVAL(::bDispMark, nNewDisp, aMark)
      IF nNewDisp != 0 .AND. ::aDispositivi[nNewDisp] != ::oCurrDisp

         IF ::oCurrDisp != NIL
            ::oCurrDisp:setDispOff()
         ENDIF

         ::oCurrDisp := ::aDispositivi[nNewDisp]
         ::oCurrDisp:setDispOn()
         ::grpDispositivi:setCaption(::lsbDispositivi:getItem(nNewDisp))

         ///////////////////////////////////////////////////////////////////////
         //Luca 03/10/2012
         ///////////////////////////////////////////////////////////////////////
         ::SetPageAndOrientation()
         ///////////////////////////////////////////////////////////////////////
         ///////////////////////////////////////////////////////////////////////
      ENDIF
   ENDIF
RETURN self

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD S2PrintMenu:SetPageAndOrientation() // Settaggio Pagina e Orientamento 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  LOCAL oPrn
  LOCAL oCurrDisp
  LOCAL nPage
  LOCAL nOrient
  LOCAL oErr
  LOCAL aFormati
  LOCAL nCurr

  DEFAULT ::aBuffer[REP_PAGE_FORMAT ]  TO XBPPRN_FORM_A4 
  DEFAULT ::aBuffer[REP_ORIENTATION ]  TO XBPPRN_ORIENT_PORTRAIT 

  nPage   :=  ::aBuffer[REP_PAGE_FORMAT]
  nOrient :=  ::aBuffer[REP_ORIENTATION]

  ::aBuffer[REP_PDF_PAGE_FORMAT  ] := S2ConvPrinterWintoPDFPage(       nPage  )
  ::aBuffer[REP_PDF_ORIENTATION  ] := S2ConvPrinterWintoPDFOrientation(nOrient)

  oCurrDisp := ::getCurrDisp()
  IF !EMPTY(oCurrDisp ) .AND. nPage <> 0
     IF IsMemberVar(oCurrDisp,"oPrinter") 
        oPrn := oCurrDisp:oPrinter

        oCurrDisp:nPaperOrientation := nOrient

        oErr := ERRORBLOCK({|e| dfErrBreak(e)})

        BEGIN SEQUENCE

          IF !EMPTY(oPrn)
              oPrn:setFormSize(    nPage   )
              oPrn:setOrientation( nOrient )
          ENDIF 


          IF IsMemberVar(oCurrDisp,"cmbPaper") 
             aFormati  := oPrn:forms()
             nCurr     := ASCAN(aFormati, {|x| x[1] == nPage})
             IF nCurr == 0 .OR. LEN(aFormati) <1 
                oCurrDisp:cmbPaper:XbpSLE:setData( SPACE(30) )
             ELSE
                oCurrDisp:cmbPaper:SetData(nCurr)
             ENDIF
          ENDIF


        END SEQUENCE
        ErrorBlock(oErr)
     ENDIF 

  ENDIF 


RETURN Self


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD S2PrintMenu:dfChoSet( aBuf ) // Settaggio Margini
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF ::lBtnMargShow
   dfChoSet( aBuf )
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD S2PrintMenu:dfMgnTop( nPrePost, aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN dfMgnTop( nPrePost, aBuf )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD S2PrintMenu:dfPageRep( aBuf ) // Settaggio Pagine
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfPageRep( aBuf )
RETURN

METHOD S2PrintMenu:addShortCut(cString, oXbp)
   LOCAL nPos
   LOCAL cAct

   // Converto segnale di carattere sottolineato da "&" a "~"
   cString := STRTRAN(cString, "&", STD_HOTKEYCHAR)

   IF ( nPos := AT( STD_HOTKEYCHAR, cString) ) != 0
      cAct := "A_"+LOWER( SUBSTR( cString, nPos + 1, 1))
   ELSEIF dbAct2Ksc(cString) != 0
      cAct := cString
   ENDIF

   IF cAct != NIL
      AADD(::aKeys, {cAct, oXbp})
   ENDIF

RETURN self

METHOD S2PrintMenu:handleShortCut( cAct, aKeys )
   LOCAL oXbp
   LOCAL nInd
   LOCAL nMax := LEN(aKeys)

   nInd := 0
   DO WHILE ++nInd <= nMax

      oXbp := aKeys[nInd][2]

      IF cAct == aKeys[nInd][1] .AND. oXbp:isVisible()
         SetAppFocus(oXbp)

         IF oXbp:isDerivedFrom( "XbpPushbutton") .OR. oXbp:isDerivedFrom("_PushButton")
            PostAppEvent( xbeP_Activate,,, oXbp)
         ENDIF

         EXIT

      ENDIF

   ENDDO

RETURN nInd <= nMax


