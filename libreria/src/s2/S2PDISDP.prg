#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "dfReport.ch"
#include "dfMsg1.ch"

// Dispositivo di stampa
// Stampante DOS

CLASS S2PrintDispDOSPrinter FROM S2PrintDisp
   EXPORTED:


      VAR txtPrinter
      VAR cmbPrinter
      VAR txtPort
      VAR cmbPort

      VAR grpQualita
      VAR rdbAlta
      VAR rdbNorm

      VAR grpSetup
      VAR ckbUser01
      VAR ckbUser02
      VAR ckbUser03

      VAR txtCopies
      VAR spnCopies
      VAR lNoPrinters

      METHOD init
      METHOD create
      METHOD exitMenu
      METHOD execute
      METHOD isDefault

ENDCLASS

METHOD S2PrintDispDOSPrinter:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::dispName := dfStdMsg1(MSG1_S2PDISDP01)

#ifdef _XBASE182_
   // Simone 2/9/03 GERR 3916 PDR 4873
   ::clipChildren := .T.
#endif

   oXbp     := XbpStatic():new( self, , {12,108}, {72,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISDP02) 
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   ::txtPrinter := oXbp

   oXbp     := XbpCombobox():new( self, , {12,0}, {300,108}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   ::cmbPrinter := oXbp
   ::addShortCut(::txtPrinter:caption, oXbp)

   oXbp    := XbpStatic():new( self, , {324,108}, {84,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISDP03)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   ::txtPort := oXbp

   oXbp    := XbpCombobox():new( self, , {324,0}, {192,108}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:tabStop := .T.
   ::cmbPort := oXbp
   ::addShortCut(::txtPort:caption, oXbp)

   // Simone 18 marzo 03 GERR 3706
   // Imposto il colore di sfondo disabilitato trasparente
   aPP := S2PPSetColors(NIL, .T.) //{0, .T.})

   oXbp     := XbpStatic():new( self, , {12,02}, {144,84}, aPP )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISDP04)
   oXbp:clipSiblings := .T.
   oXbp:type := XBPSTATIC_TYPE_GROUPBOX
   ::grpQualita := oXbp

   oXbp        := XbpRadiobutton():new( ::grpQualita, , {12,36}, {108,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISDP05)
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:selected := {|| ::aBuffer[REP_IS_NLQ] := .F. }
   ::rdbNorm := oXbp
   ::addShortCut(oXbp:caption, oXbp)

   oXbp        := XbpRadiobutton():new( ::grpQualita, , {12,12}, {108,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISDP06)
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:selected := {|| ::aBuffer[REP_IS_NLQ] := .T.  }
   ::rdbAlta := oXbp
   ::addShortCut(oXbp:caption, oXbp)

   // Imposto il colore di sfondo disabilitato trasparente
   oXbp       := XbpStatic():new( self, , {168,02}, {144,84}, aPP )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISDP07)
   oXbp:clipSiblings := .T.
   oXbp:type := XBPSTATIC_TYPE_GROUPBOX
   ::grpSetup := oXbp

   oXbp      := XbpCheckbox():new( ::grpSetup, , {12,48}, {108,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISDP08)
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:selected := {|l| ::aBuffer[REP_USEUSER1] := l}
   ::ckbUser01 := oXbp
   ::addShortCut(oXbp:caption, oXbp)

   oXbp      := XbpCheckbox():new( ::grpSetup, , {12,28}, {108,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISDP09)
   oXbp:tabStop := .T.
   oXbp:clipSiblings := .T.
   oXbp:selected := {|l| ::aBuffer[REP_USEUSER2] := l }
   ::ckbUser02 := oXbp
   ::addShortCut(oXbp:caption, oXbp)

   oXbp      := XbpCheckbox():new( ::grpSetup, , {12,08}, {108,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISDP10)
   oXbp:tabStop := .T.
   oXbp:clipSiblings := .T.
   oXbp:selected := {|l| ::aBuffer[REP_USEUSER3] := l }
   ::ckbUser03 := oXbp
   ::addShortCut(oXbp:caption, oXbp)

   oXbp      := XbpStatic():new( self, , {324,70}, {36,12} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISDP11)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   ::txtCopies := oXbp

   oXbp      := XbpSpinbutton():new( self, , {324,46}, {48,24}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 3
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   ::spnCopies := oXbp
   ::addShortCut(::txtCopies:caption, oXbp)

RETURN self

METHOD S2PrintDispDOSPrinter:isDefault()
RETURN ! UPPER(ALLTRIM(::aBuffer[REP_PRINTERPORT])) == "FILE" .AND. ;
       ! dfIsWinPrinter(::aBuffer)

METHOD S2PrintDispDOSPrinter:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL cPrinter, aBuf:= ::aBuffer
   LOCAL aPort
   LOCAL nPort := 0
   LOCAL nInd := 0

   ::S2PrintDisp:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::txtPrinter:create()
   ::cmbPrinter:create()

   AEVAL( dfArrPrn(), {|aSub|IF( dfIsWinPrinter(ALLTRIM(aSub[PRINTER_INFO])), NIL,  ::cmbPrinter:addItem(aSub[PRINTER_INFO])  ) } )

   ::lNoPrinters := .F.

   IF ::cmbPrinter:numItems() == 0
      ::cmbPrinter:addItem( dfStdMsg1(MSG1_S2PDISDP12) ) 
      ::lNoPrinters := .T.
   ENDIF

   ::txtPort:create()
   ::cmbPort:create()

   ::cmbPort:XbpSLE:setData("")

   // Aggiungo le porte evitando la porta "FILE"
   aPort := dfArrPor()
   FOR nInd := 1 TO LEN(aPort)

      IF ! aPort[nInd][1] == "FILE"
         ::cmbPort:addItem(aPort[nInd][1])

         IF UPPER(ALLTRIM(aPort[nInd][1])) == ;
            UPPER(ALLTRIM(aBuf[REP_PRINTERPORT]))

            nPort := ::cmbPort:numItems()
         ENDIF
      ENDIF

   NEXT

   // Se non  ho trovato la porta assegno la prima
   IF nPort == 0 .AND. ::cmbPort:numItems() >= 1
      nPort := 1
   ENDIF

   IF nPort > 0
      ::cmbPort:XbpSLE:setData(::cmbPort:getItem(nPort) )
   ENDIF

   cPrinter := aBuf[REP_PRINTERARR][PRINTER_INFO]

   IF dfIsWinPrinter(aBuf[REP_PRINTERARR][PRINTER_INFO]) .AND. ::cmbPrinter:numItems() > 0
      cPrinter := ::cmbPrinter:getItem(1)
   ENDIF
   ::cmbPrinter:XbpSLE:setData(cPrinter)

   IF aBuf[REP_IS_NLQ]
      ::rdbAlta:selection := .T.
   ELSE
      ::rdbNorm:selection := .T.
   ENDIF

   ::ckbUser01:selection := aBuf[REP_USEUSER1]
   ::ckbUser02:selection := aBuf[REP_USEUSER2]
   ::ckbUser03:selection := aBuf[REP_USEUSER3]

   ::grpQualita:create()
   ::rdbAlta:create()
   ::rdbNorm:create()

   ::grpSetup:create()
   ::ckbUser01:create()
   ::ckbUser02:create()
   ::ckbUser03:create()

   ::txtCopies:create()
   ::spnCopies:create()

   ::spnCopies:setData(aBuf[REP_COPY])

   IF ::lNoPrinters
      //::disable()

      ::cmbPrinter:disable()
      ::cmbPort:disable()

      //::grpQualita:disable()
      ::rdbAlta:disable()
      ::rdbNorm:disable()

      //::grpSetup:disable()
      ::ckbUser01:disable()
      ::ckbUser02:disable()
      ::ckbUser03:disable()

      ::spnCopies:disable()

   ENDIF

   IF dfAnd( ::aBuffer[REP_DISABLE], PRN_DISABLE_COPY ) != 0
      ::spnCopies:hide()
   ENDIF

   // WorkAround per gestione tastiera dei combobox
   ::ComboBoxWorkAround(::childList())
RETURN self

METHOD S2PrintDispDOSPrinter:exitMenu(nAction, aBuf)
   LOCAL aSel := ::cmbPrinter:XbpListBox:getData()
   LOCAL cPrinter

   IF LEN(aSel) > 0
      cPrinter := ::cmbPrinter:getItem(aSel[1])
      dfPrnSet( aBuf, dfGetPrnID( cPrinter ) )
   ENDIF

   aSel := ::cmbPort:XbpListBox:getData()
   IF LEN(aSel) > 0
      aBuf[REP_PRINTERPORT] := ::cmbPort:getItem(aSel[1])
   ENDIF

   aBuf[REP_COPY] := ::spnCopies:getData()

RETURN nAction

METHOD S2PrintDispDOSPrinter:execute() // cFile, cTitle, xDevice)
   LOCAL lPrint := .T.

   DO WHILE ::aBuffer[REP_COPY]-->0 .AND. lPrint
      lPrint := dfFile2Prn(::aBuffer[REP_FNAME], ;
                           ::aBuffer[REP_NAME] , ;
                           ::aBuffer[REP_PRINTERPORT] )
   ENDDO

   IF lPrint  // Se la stampa e' andata a buon fine
      FERASE( ::aBuffer[REP_FNAME] )
   ENDIF
RETURN lPrint

