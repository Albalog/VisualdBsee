#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "dfReport.ch"
#include "dfMsg1.ch"
#include "dfPdf.ch"
#include "dfWinRep.ch"

// Dispositivo di stampa
// stampa su Fax MAPI

CLASS S2PrintDispMAPIFax FROM S2PrintDisp
   EXPORTED:


      VAR txtFax
      VAR txtOggetto
      VAR txtTesto
      VAR txtPaper
      VAR txtOrienta

      VAR sleFax
      VAR sleOggetto
      VAR sleTesto

      VAR cmbPaper
      VAR cmbOrienta
      VAR chkSelect

      VAR ckbAuto
      VAR cFaxTo, xProfile
      VAR cAutoCaption, lAuto, bAuto

      VAR cOggetto,cBody
      // DA ATTIVARE
      // VAR btnBrowse

      VAR lPdf
      VAR aForms
      VAR aOrientation

      METHOD OutPutSelect

      METHOD init
      METHOD create
      METHOD exitMenu
      METHOD execute

      INLINE METHOD canSupportFont(); RETURN ::lPdf
      INLINE METHOD canSupportImg() ; RETURN ::lPdf
      INLINE METHOD canSupportBox() ; RETURN ::lPdf

      METHOD End_Execute
      // DA ATTIVARE
      // METHOD rubrica

ENDCLASS

METHOD S2PrintDispMAPIFax:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::dispName := dfStdMsg1(MSG1_S2PDISMF01)

   oXbp     := XbpStatic():new( self, , {1,98}, {94,14} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISMF02)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   ::txtFax := oXbp

   oXbp     := XbpSle():new( self, , {100,93}, {270,22}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:autoTab := .T.
   oXbp:tabStop := .T.
   oXbp:bufferLength := 250
   ::addShortCut(::txtFax:caption, oXbp)
   ::sleFax := oXbp

   oXbp     := XbpStatic():new( self, , {12,71}, {83,14} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISMF13)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_RIGHT +XBPSTATIC_TEXT_VCENTER
   ::txtOggetto := oXbp

   oXbp     := XbpSle():new( self, , {100,66}, {270,22}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:autoTab := .T.
   oXbp:tabStop := .T.
   oXbp:bufferLength := 250
   ::addShortCut(::txtOggetto:caption, oXbp)
   ::sleOggetto := oXbp

   oXbp     := XbpStatic():new( self, , {12,45}, {83,14} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISMF14)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_RIGHT +XBPSTATIC_TEXT_VCENTER
   ::txtTesto := oXbp

   oXbp     := XbpMle():new( self, , {100,01}, {270,62}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:editable   := .T.
   oXbp:ignoreTab  := .T.
   oXbp:HorizScroll:= .F.
   oXbp:tabStop    := .T.
   oXbp:VertScroll := .T.
   ::addShortCut(::txtTesto:caption, oXbp)
   ::sleTesto := oXbp


   oXbp              := XbpCheckbox():new( self, , {385,70}, {300,200} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISMF12)
   oXbp:clipSiblings := .T.
   oXbp:tabStop      := .T.
   oXbp:autoSize     := .T.
   oXbp:selected     := {|l| ::OutPutSelect(l) }
   ::chkSelect       := oXbp

   oXbp              := XbpStatic():new( self, , {375,38}, {120,15} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISMF11)
   oXbp:clipSiblings := .T.
   oXbp:options      := XBPSTATIC_TEXT_RIGHT +XBPSTATIC_TEXT_VCENTER
   ::txtPaper        := oXbp


   oXbp              := XbpCombobox():new( self, , {500,-42}, {120,100}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:tabStop      := .T.
   oXbp:type         := XBPCOMBO_DROPDOWNLIST
   ::cmbPaper        := oXbp
   ::addShortCut(::txtPaper:caption, oXbp)

   oXbp              := XbpStatic():new( self, , {375,10}, {120,15} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISMF10)
   oXbp:clipSiblings := .T.
   oXbp:options      := XBPSTATIC_TEXT_RIGHT +XBPSTATIC_TEXT_VCENTER
   ::txtOrienta      := oXbp

   oXbp              := XbpCombobox():new( self, , {500,-71}, {120,100}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:tabStop      := .T.
   oXbp:type         := XBPCOMBO_DROPDOWNLIST
   ::cmbOrienta      := oXbp
   ::addShortCut(::TxtOrienta:caption, oXbp)

  // DA ATTIVARE
  //  oXbp       := XbpPushButton():new( self, , {324,56}, {96,24} )
  //  oXbp:caption := "&Rubrica"
  //  oXbp:clipSiblings := .T.
  //  oXbp:tabStop := .T.
  //  oXbp:activate := {|| ::rubrica() }
  //  ::addShortCut(oXbp:caption, oXbp)
  //  ::btnBrowse := oXbp

   ::cFaxTo := ""
   ::xProfile := 0

   ::cAutoCaption := ""
   ::lAuto := .F.
   ::bAuto := NIL

   //::sleFax:type := XBPCOMBO_DROPDOWNLIST

RETURN self

METHOD S2PrintDispMAPIFax:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL cPrinter, aBuf:= ::aBuffer
   LOCAL oXbp
   LOCAL aFile
   LOCAL nSel := 0

   ::S2PrintDisp:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   IF ! EMPTY(::cAutoCaption)
      oXbp      := XbpCheckbox():new( self, , {385,97}, {0,0} )
      oXbp:caption := ::cAutoCaption
      oXbp:clipSiblings := .T.
      oXbp:tabStop := .T.
      oXbp:autoSize := .T.
      oXbp:selected := {|l| ::lAuto := l, ;
                            IIF(::lAuto, ;
                                ::sleFax:disable(), ;
                                ::sleFax:enable())}
      ::ckbAuto := oXbp
      ::addShortCut(oXbp:caption, oXbp)
      ::ckbAuto:create()
      ::ckbAuto:setData(::lAuto) // simone d 17/1/07 gerr 4779
   ENDIF

   ::txtFax:create()
   ::sleFax:create()
   ::sleFax:setData("")
   IF ! EMPTY(::lAuto) // simone d 17/1/07 gerr 4779
      ::sleFax:disable()
   ENDIF

   ::txtOggetto:create()
   ::txtTesto:create()

   ::sleOggetto:create()
   IF !EMPTY(::aBuffer[REP_NAME])
      ::sleOggetto:SetData(::aBuffer[REP_NAME] +" ("+ DTOC(DATE()) +" "+TIME()+")" )
   ELSE
      ::sleOggetto:SetData(dfStdMsg1(MSG1_S2PDISMF05) +" (" + DTOC(DATE()) +" "+TIME()+")")
   ENDIF


   ::sleTesto:create()
   //::sleTesto:SetData(dfStdMsg1(MSG1_S2PDISMF09))
   ::sleTesto:SetData("")

   ::chkSelect:create()

   ::cmbPaper:create()
   ::txtPaper:create()
   ::aForms := dfPdfGetForms()
   AEVAL(::aForms, {|x| ::cmbPaper:addItem(x) })
   nSel := ASCAN(::aForms, {|x| x== aBuf[REP_PDF_PAGE_FORMAT]})
   IF nSel == 0
      nSel := ASCAN(::aForms, {|x| x== PDF_PAGE_A4})
   ENDIF
   IF nSel == 0
      ::cmbPaper:XbpSLE:setData("")
   ELSE
      ::cmbPaper:XbpSLE:setData(::aForms[nSel])
      //MANTIS 327: runtime error dovuto ad un errore di sintassi
      //::cmbPaper:XbpSLE:setData(nSel)
      ::cmbPaper:setData(nSel)
   ENDIF

   ::cmbOrienta:create()
   ::txtOrienta:create()
   ::aOrientation := dfPdfGetOrientation()
   AEVAL(::aOrientation, {|x| ::cmbOrienta:addItem(x[2]) })
   nSel := ASCAN(::aOrientation, {|x| x[1]== aBuf[REP_PDF_ORIENTATION]})
   IF nSel == 0
      nSel := ASCAN(::aOrientation, {|x| x[1]== PDF_VERTICAL})
   ENDIF
   IF nSel == 0
      ::cmbOrienta:XbpSLE:setData("")
   ELSE
      ::cmbOrienta:XbpSLE:setData(::aOrientation[nSel][2])
   ENDIF

   aFile :=  dfFNameSplit(ALLTRIM(aBuf[REP_FNAME]))

   IF dfSet(AI_XBASEDISABLEPDFPRINT)
      ::lPdf := .F.
      ::txtPaper:hide()
      ::txtOrienta:hide()
      ::chkSelect:hide()
      ::cmbPaper:hide()
      ::cmbOrienta:hide()
   ELSE

      ::lPdf := UPPER(aFile[4]) ==  ".PDF"
      IF ::lPdf
         ::chkSelect:SetData(.T.)
         ::cmbOrienta:enable()
         ::cmbPaper:enable()
      ELSE
         ::chkSelect:SetData(.F.)
         ::cmbOrienta:disable()
         ::cmbPaper:disable()
      ENDIF
   ENDIF

   // DA ATTIVARE
   // ::btnBrowse:create()

RETURN self

METHOD S2PrintDispMAPIFax:exitMenu(nAction, aBuf)
   LOCAL aSel,nSel

   ::cFaxTo  := ::sleFax:getData()
   ::xProfile:= dfSet("XbaseMAPIProfile")
   ::cOggetto:= ConvToAnsiCP(ALLTRIM(::sleOggetto:GetData()))
   ::cBody   := ConvToAnsiCP(ALLTRIM(::sleTesto:GetData()))

   DEFAULT ::xProfile TO 0

   IF nAction > 0
      DO CASE
         CASE ! ::lAuto .AND. EMPTY(::cFaxTo)
            dbMsgErr(dfStdMsg1(MSG1_S2PDISMF03))
            nAction := -1
         CASE EMPTY(::cOggetto) .OR. EMPTY(::cBody)
            IF !dfYesNO(dfStdMsg1(MSG1_S2PDISMF16)+"//"+;
                        IIF(EMPTY(::cOggetto)," - "+STRTRAN(STRTRAN(dfStdMsg1(MSG1_S2PDISMF13),"&"),":") +"//"  ,"" ) +;
                        IIF(EMPTY(::cBody   )," - "+STRTRAN(STRTRAN(dfStdMsg1(MSG1_S2PDISMF14),"&"),":")        ,"" )  ;
                         )
               nAction := -1
            ENDIF
      ENDCASE
   ENDIF
   IF ::lPdf

      //Setto Parametri per creazione Pdf
      //E' necessario passsare i corretti parametri
      aBuf[REP_PRINTERPORT] := "FILE"
      aBuf[REP_FNAME]       := "FILE"

      dfPrnSet( aBuf, "", .T. )

      aBuf[REP_SETUP      ] := DFWINREP_SETUP
      aBuf[REP_RESET      ] := DFWINREP_RESET
      aBuf[REP_BOLD_ON    ] := DFWINREP_BOLDON
      aBuf[REP_BOLD_OFF   ] := DFWINREP_BOLDOFF
      aBuf[REP_ENL_ON     ] := DFWINREP_ENLARGEDON
      aBuf[REP_ENL_OFF    ] := DFWINREP_ENLARGEDOFF
      aBuf[REP_UND_ON     ] := DFWINREP_UNDERLINEON
      aBuf[REP_UND_OFF    ] := DFWINREP_UNDERLINEOFF
      aBuf[REP_SUPER_ON   ] := DFWINREP_SUPERSCRIPTON
      aBuf[REP_SUPER_OFF  ] := DFWINREP_SUPERSCRIPTOFF
      aBuf[REP_SUBS_ON    ] := DFWINREP_SUBSCRIPTON
      aBuf[REP_SUBS_OFF   ] := DFWINREP_SUBSCRIPTOFF
      aBuf[REP_COND_ON    ] := DFWINREP_CONDENSEDON
      aBuf[REP_COND_OFF   ] := DFWINREP_CONDENSEDOFF
      aBuf[REP_ITA_ON     ] := DFWINREP_ITALICON
      aBuf[REP_ITA_OFF    ] := DFWINREP_ITALICOFF
      aBuf[REP_NLQ_ON     ] := DFWINREP_NLQON
      aBuf[REP_NLQ_OFF    ] := DFWINREP_NLQOFF
      aBuf[REP_USER1ON    ] := DFWINREP_USER01ON
      aBuf[REP_USER1OFF   ] := DFWINREP_USER01OFF
      aBuf[REP_USER2ON    ] := DFWINREP_USER02ON
      aBuf[REP_USER2OFF   ] := DFWINREP_USER02OFF
      aBuf[REP_USER3ON    ] := DFWINREP_USER03ON
      aBuf[REP_USER3OFF   ] := DFWINREP_USER03OFF
      aBuf[REP_NO_LAST_EJECT]:= .T.

//Non Š gestito da qui per permettere di prendere i settaggi di dfWinPrnReset()
//       aBuf[REP_XBASEPRINTEXTRA]:= ARRAY(DFWINREP_EX_LEN)
//
//       aBuf[REP_XBASEPRINTEXTRA][DFWINREP_EX_MARGTOP   ] := 3//aBuf[REP_MGN_TOP    ]
//       aBuf[REP_XBASEPRINTEXTRA][DFWINREP_EX_MARGLEFT  ] := 1//aBuf[REP_MGN_LEFT   ]
//       aBuf[REP_XBASEPRINTEXTRA][DFWINREP_EX_INTERLINE ] := 11 * 1.08
//       aBuf[REP_XBASEPRINTEXTRA][DFWINREP_EX_PAGEHEIGHT] := NIL
//       IF ::aBuffer[REP_IS_CONDENSED]
//          aBuf[REP_XBASEPRINTEXTRA][DFWINREP_EX_FONTS     ] := "7.Courier"
//       ELSE
//          aBuf[REP_XBASEPRINTEXTRA][DFWINREP_EX_FONTS     ] := "11.Courier"
//       ENDIF

      //Devo passare qui altrimenti nella Execute mi danno un errore di posizionamneto
      aSel := ::cmbPaper:XbpListBox:getData()
      IF LEN(aSel) > 0
         aBuf[REP_PDF_PAGE_FORMAT] := ::cmbPaper:getItem(aSel[1])
      ELSE
         aBuf[REP_PDF_PAGE_FORMAT] := PDF_PAGE_A4
      ENDIF

      aSel := ::cmbOrienta:XbpListBox:getData()
      IF LEN(aSel) > 0
         nSel := ASCAN(::aOrientation, {|x| x[2]== ::cmbOrienta:getItem(aSel[1])})
         aBuf[REP_PDF_ORIENTATION] := ::aOrientation[nSel][1]
      ELSE
         aBuf[REP_PDF_ORIENTATION] := PDF_VERTICAL
      ENDIF


   ELSE

      aBuf[REP_PRINTERPORT] := "FILE"
      aBuf[REP_FNAME] := ""

      aBuf[REP_SETUP      ] := "" 
      aBuf[REP_RESET      ] := ""
      aBuf[REP_BOLD_ON    ] := ""
      aBuf[REP_BOLD_OFF   ] := ""
      aBuf[REP_ENL_ON     ] := ""
      aBuf[REP_ENL_OFF    ] := ""
      aBuf[REP_UND_ON     ] := ""
      aBuf[REP_UND_OFF    ] := ""
      aBuf[REP_SUPER_ON   ] := ""
      aBuf[REP_SUPER_OFF  ] := ""
      aBuf[REP_SUBS_ON    ] := ""
      aBuf[REP_SUBS_OFF   ] := ""
      aBuf[REP_COND_ON    ] := ""
      aBuf[REP_COND_OFF   ] := ""
      aBuf[REP_ITA_ON     ] := ""
      aBuf[REP_ITA_OFF    ] := ""
      aBuf[REP_NLQ_ON     ] := ""
      aBuf[REP_NLQ_OFF    ] := ""
      aBuf[REP_USER1ON    ] := ""
      aBuf[REP_USER1OFF   ] := ""
      aBuf[REP_USER2ON    ] := ""
      aBuf[REP_USER2OFF   ] := ""
      aBuf[REP_USER3ON    ] := ""
      aBuf[REP_USER3OFF   ] := ""
   ENDIF

RETURN nAction

// METHOD S2PrintDispMAPIFax:execute()
//    LOCAL oFax
//    LOCAL cFName := ::aBuffer[REP_FNAME]
//    LOCAL cName  := ::aBuffer[REP_NAME]
//    LOCAL cSubject := ""
//    LOCAL cTxt := MEMOREAD(cFName)
//    LOCAL lOk := .F.
//
//
//    IF ::lAuto .AND. ::bAuto != NIL
//       ::cFaxTo := EVAL(::bAuto)
//    ENDIF
//
//    IF ! EMPTY(::cFaxTo)
//       dbMsgOn("Invio messaggio in corso...//"+::cFaxTo)
//
//       oFax:= S2Mapi():new()
//
//       IF EMPTY(cName)
//          cSubject := "Stampa"
//       ELSE
//          cSubject := cName
//       ENDIF
//
//       AEVAL(dfStr2Arr(::cFaxTo, ";"), ;
//             {|cTo| oFax:sendFax( ::xProfile,0,0, "Fax", cTo, cSubject, cTxt ) })
//
//       dbMsgOff()
//
//       FERASE(cFName)
//       lOk := .T.
//    ENDIF
// RETURN lOk

METHOD S2PrintDispMapiFax:execute()
   LOCAL oMail
   LOCAL lRet := .F.
   LOCAL cFile       := IIF(!EMPTY(::aBuffer[REP_FNAME]),ALLTRIM(::aBuffer[REP_FNAME]),"FILE")
   LOCAL aFName      := dfFNameSplit(cFile)
   LOCAL cFileTxt    := aFName[1]+aFName[2]+aFName[3]+".Txt"
   LOCAL cFilePdf    := NIL 
   LOCAL cTitle      := ::aBuffer[REP_NAME]
   //LOCAL aExtra      := NIL //NON VIENE UTILIZZATO::aBuffer[REP_XBASEPRINTEXTRA]
   LOCAL aExtra      := ::aBuffer[REP_XBASEPRINTEXTRA]
   LOCAL nOptions    := 1 //3  1 senza Tread 3 con Tread
   LOCAL cTipoFormatoPagina
   LOCAL cVerso
   LOCAL cTxtAttach  := dfSet("XbaseTxtFaxAttach")
   LOCAL bEnd        := {|cFilePdf,lOk| ::End_Execute(cFilePdf,lOk,cFileTxt,cFile,oMail,nOptions) }

   cFileTxt := dfFNameBuild(UPPER(cFileTxt))
   cFile    := dfFNameBuild(UPPER(cFile))

   IF ::lAuto .AND. ::bAuto != NIL
      ::cFaxTo := EVAL(::bAuto)
   ENDIF

   IF ! EMPTY(::cFaxTo)

      IF nOptions <=1
         dbMsgOn(dfStdMsg1(MSG1_S2PDISMF04)+::cFaxTo)
      ENDIF

      oMail:= S2MapiFAX():new()


      // Rinomino in file con estensione .TXT
      IF !cFile == cFileTxt
         FERASE(cFileTxt)
         IF FRENAME(cFile, cFileTxt)!=0
            dbMsgErr(dfStdMsg1(MSG1_S2PDISMF07)+ALLTRIM(STR(FERROR())))
            lRet := .F.
         ENDIF
      ENDIF

      oMail:cSubject := ::cOggetto
      oMail:cBody    := ::cBody

      // Simone 5/set/03 gerr 3927
      //AEVAL(dfStr2Arr(::cFaxTo, ";"), {|cTo| oMail:addTo( cTO ) })
      AEVAL(S2EmailAddressNormalize(::cFaxTo), {|cTo| oMail:addTo( cTO ) })

      IF ::lPdf
         cTipoFormatoPagina := ::aBuffer[REP_PDF_PAGE_FORMAT]
         cVerso             := ::aBuffer[REP_PDF_ORIENTATION]

         IF dfTxt2Pdf( cFileTxt,@cFilePdf, cTitle, aExtra, nOptions,cTipoFormatoPagina,cVerso,bEnd)
            lRet := .T.
         ELSE
            //Errore creazione File Pdf
            dbMsgErr(dfStdMsg1(MSG1_S2PDISMF08))
            lRet := .F.
         ENDIF
      ELSE
         IF !EMPTY(cTxtAttach)
            cTxtAttach := UPPER(ALLTRIM(cTxtAttach))
         ELSE
            cTxtAttach := ""
         ENDIF
         IF cTxtAttach=="NO" .OR. cTxtAttach=="OFF"
            oMail:cBody+=  CRLF + dfFileRead(cFileTxt)
         ELSE
            oMail:addAttach(cFileTxt)
         ENDIF
         oMail:send()
         ::nError    := oMail:nError
         ::cErrorMsg := oMail:cMsg
         FERASE(cFileTxt)
         FERASE(cFile)
      ENDIF
      IF nOptions <=1
         dbMsgOff()
      ENDIF
   ELSE
      dbMsgErr(dfStdMsg1(MSG1_S2PDISMF07)+ALLTRIM(STR(FERROR())))
      lRet := .F.
   ENDIF
RETURN lRet

// DA ATTIVARE
// METHOD S2PrintDispMAPIFax:rubrica()
//    LOCAL xRet := ""
//
//    dfAlert("da fare...")
//    xRet := "hot@studio2000.net"
//
//    IF ! EMPTY(xRet)
//       ::sleFax:setData(xRet)
//    ENDIF
//
// RETURN .F.

METHOD S2PrintDispMAPIFax:OutPutSelect(lIn)
   ::lPdf := lIn
   IF ::lPdf == .F.       //Creo in Txt
      ::cmbPaper:disable()
      ::cmbOrienta:disable()
   ELSE
      ::cmbPaper:enable()
      ::cmbOrienta:enable()
   ENDIF

RETURN NIL

METHOD S2PrintDispMAPIFax:End_Execute(cFilePdf,lOk,cFileTxt,cFile,oMail,nOptions)
   IF lOk
      oMail:addAttach( cFilePdf )
      oMail:send()
      ::nError    := oMail:nError
      ::cErrorMsg := oMail:cMsg
      FERASE(cFilePdf)
      FERASE(cFileTxt)
      FERASE(cFile)
      IF nOptions >=2
         dfalert(dfStdMsg1(MSG1_S2PDISMF15))
      ENDIF
   ELSE
      //Errore creazione File Pdf
      dbMsgErr(dfStdMsg1(MSG1_S2PDISMF08))
   ENDIF
RETURN .T.
