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
// stampa su mail SMTP

CLASS S2PrintDispSMTPMail FROM S2PrintDisp
   EXPORTED:


      VAR txtEmail
      VAR txtOggetto
      VAR txtTesto
      VAR txtFile
      VAR sleEmail
      VAR sleOggetto
      VAR sleTesto
      VAR ckbAuto
      VAR ckbZIP
      VAR cMailTo, cServer, cFrom,cOggetto,cBody
      /////////////////////////////////////////
      //Luca  17/04/2015
      VAR cReplyto
      /////////////////////////////////////////
      VAR cUser, cPassword, nLoginMethod
      VAR cAutoCaption, lAuto, bAuto

      VAR lPdf
      VAR lZip
      VAR cmbPaper
      VAR txtPaper
      VAR cmbOrienta
      VAR txtOrienta

      VAR sleFile
      VAR txtSelection
      VAR cmbSelect

      VAR aForms
      VAR aOrientation

      // DA ATTIVARE
      //VAR btnBrowse

      METHOD init
      METHOD create
      METHOD exitMenu
      METHOD execute

      METHOD OutPutSelect

      INLINE METHOD canSupportFont(); RETURN ::lPdf
      INLINE METHOD canSupportImg() ; RETURN ::lPdf
      INLINE METHOD canSupportBox() ; RETURN ::lPdf

      METHOD End_Execute
      METHOD zipFile
      // DA ATTIVARE
      //METHOD rubrica

ENDCLASS


METHOD S2PrintDispSMTPMail:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::dispName := dfStdMsg1(MSG1_S2PDISSM01)

   oXbp     := XbpStatic():new( self, , {0,98}, {85,14} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISSM02)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_RIGHT +XBPSTATIC_TEXT_VCENTER
   ::txtEmail := oXbp

   oXbp     := XbpSle():new( self, , {90,93}, {270,22}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:autoTab := .T.
   oXbp:tabStop := .T.
   oXbp:bufferLength := 250
   ::addShortCut(::txtEmail:caption, oXbp)
   ::sleEmail := oXbp

   oXbp     := XbpStatic():new( self, , {12,71}, {72,14} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISSM10)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_RIGHT +XBPSTATIC_TEXT_VCENTER
   ::txtOggetto := oXbp

   oXbp     := XbpSle():new( self, , {90,66}, {270,22}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:autoTab := .T.
   oXbp:tabStop := .T.
   oXbp:bufferLength := 250
   ::addShortCut(::txtOggetto:caption, oXbp)
   ::sleOggetto := oXbp

   oXbp     := XbpStatic():new( self, , {12,45}, {72,14} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISSM11)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_RIGHT +XBPSTATIC_TEXT_VCENTER
   ::txtTesto := oXbp

   oXbp     := XbpMle():new( self, , {90,01}, {270,62}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:editable   := .T.
   oXbp:ignoreTab  := .T.
   oXbp:HorizScroll:= .F.
   oXbp:tabStop    := .T.
   oXbp:VertScroll := .T.
   ::addShortCut(::txtTesto:caption, oXbp)
   ::sleTesto := oXbp



   oXbp     := XbpStatic():new( self, , {385,95}, {110,15} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISFI02)+":"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_RIGHT +XBPSTATIC_TEXT_VCENTER
   ::txtFile := oXbp

   oXbp     := XbpSle():new( self, , {500,91}, {120,23}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:autoTab := .T.
   oXbp:tabStop := .T.
   oXbp:bufferLength := 250
   ::addShortCut(::txtFile:caption, oXbp)
   ::sleFile := oXbp


   oXbp     := XbpStatic():new( self, , {365,65}, {130,15} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISFI05)+":"
   oXbp:clipSiblings := .T.
   oXbp:options      := XBPSTATIC_TEXT_RIGHT +XBPSTATIC_TEXT_VCENTER
   ::txtSelection    := oXbp

   oXbp              := XbpCombobox():new( self, , {500,-15}, {60,100}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:type         := XBPCOMBO_DROPDOWNLIST
   oXbp:tabStop      := .T.
   oXbp:itemSelected := {|| ::OutPutSelect() }
   ::addShortCut(::txtSelection:caption, oXbp)
   ::cmbSelect       := oXbp

   oXbp              := XbpCheckbox():new( self, , {562,60}, {60,23})
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISMM09) // "&ZIP file"
   oXbp:clipSiblings := .T.
   oXbp:tabStop      := .T.
   oXbp:selected := {|l| ::lZip := l}
   ::addShortCut(oXbp:caption, oXbp)
   ::ckbZip          := oXbp

/*--
   oXbp      := XbpCheckbox():new( ::grpSetup, , {12,48}, {108,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISDP08)
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:selected := {|l| ::aBuffer[REP_USEUSER1] := l}
   ::ckbUser01 := oXbp
   ::addShortCut(oXbp:caption, oXbp)

--*/

   oXbp              := XbpStatic():new( self, , {365,36}, {130,15} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISWP05)+":"
   oXbp:clipSiblings := .T.
   oXbp:options      := XBPSTATIC_TEXT_RIGHT +XBPSTATIC_TEXT_VCENTER
   ::txtPaper        := oXbp


   oXbp              := XbpCombobox():new( self, , {500,-42}, {120,100}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:tabStop      := .T.
   oXbp:type         := XBPCOMBO_DROPDOWNLIST
   ::cmbPaper        := oXbp
   ::addShortCut(::txtPaper:caption, oXbp)

   oXbp              := XbpStatic():new( self, , {365,10}, {130,15} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISFI07)+":"
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

   ::cMailTo := ""
   ::cServer := ""
   ::cFrom   := ""
   ::cBody   := ""
   ::cOggetto:= ""
   //Luca  17/04/2015
   ::cReplyto:= ""

   ::cUser   := ""
   ::cPassword:=""
   ::nLoginMethod:=NIL

   ::cAutoCaption := ""
   ::lAuto := .F.
   ::bAuto := NIL
   //::sleEmail:type := XBPCOMBO_DROPDOWNLIST
   ::lZip := .F.

RETURN self

METHOD S2PrintDispSMTPMail:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL cPrinter, aBuf:= ::aBuffer
   LOCAL oXbp
   LOCAL aTipOutPut := {"*.Txt","*.Pdf"}
   LOCAL aSizechk   := {0,0}
   LOCAL aSizeSle
   LOCAL aPosSle
   LOCAL aFile
   LOCAL nSel := 0
   LOCAL cXBasePathPrintFile := ""

   ::S2PrintDisp:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   IF ! EMPTY(::cAutoCaption)
      oXbp      := XbpCheckbox():new( self, , {250,96}, {0,0} )
      oXbp:caption := ::cAutoCaption
      oXbp:clipSiblings := .T.
      oXbp:tabStop := .T.
      oXbp:autoSize := .T.
      oXbp:selected := {|l| ::lAuto := l, ;
                            IIF(::lAuto, ;
                                ::sleEmail:disable(), ;
                                ::sleEmail:enable())}
      ::ckbAuto := oXbp
      ::addShortCut(oXbp:caption, oXbp)
      ::ckbAuto:create()
      ::ckbAuto:setData(::lAuto) // simone d 17/1/07 gerr 4779
      aSizechk := ::ckbAuto:CurrentSize()
   ENDIF


   ::txtEmail:create()
   ::txtOggetto:create()
   ::txtTesto:create()

   IF ! EMPTY(::cAutoCaption)
      aSizeSle := ::sleEmail:CurrentSize()
      IF (aSizeSle[1]-aSizeChk[1])<50
         aSizeChk[1] :=  aSizeSle[1] -50
      ENDIF
      ::sleEmail:create(NIL,NIL,NIL,{aSizeSle[1]-aSizeChk[1]+22,aSizeSle[2]})
      aSizeSle:= ::sleEmail:CurrentSize()
      aPosSle := ::sleEmail:CurrentPos()
      ::ckbAuto:SetPosAndSize({aPosSle[1]+aSizeSle[1] + 4,96},aSizechk)
   ELSE
      ::sleEmail:create()
   ENDIF

   ::sleEmail:setData("")
   IF ! EMPTY(::lAuto) // simone d 17/1/07 gerr 4779
      ::sleEmail:disable()
   ENDIF

   ::sleOggetto:create()
   ::sleTesto:create()

   //////////////////////////////////////////////////////////////////////////////////////////////
   //Modifica 06/04/2010 per poter inviare un email impostando da codice il testo body e Oggetto 
   //Mantis 2126
   IF LEN(::aBuffer) >= REP_EMAIL  .AND.; 
      !EMPTY(::aBuffer[REP_EMAIL]) .AND. LEN(::aBuffer[REP_EMAIL]) >= REP_EMAIL_ARRLEN
      IF !EMPTY(::aBuffer[REP_EMAIL][REP_EMAIL_OBJECT])
         ::sleOggetto:SetData(::aBuffer[REP_EMAIL][REP_EMAIL_OBJECT])
      ELSE 
         IF !EMPTY(::aBuffer[REP_NAME])
            ::sleOggetto:SetData(::aBuffer[REP_NAME])
         ELSE
            ::sleOggetto:SetData(dfStdMsg1(MSG1_S2PDISSM07))
         ENDIF
      ENDIF 
      IF !EMPTY(::aBuffer[REP_EMAIL][REP_EMAIL_BODY])
         ::sleTesto:SetData(::aBuffer[REP_EMAIL][REP_EMAIL_BODY]+CRLF)
      ELSE 
         ::sleTesto:SetData(dfStdMsg1(MSG1_S2PDISSM08)+CRLF)
      ENDIF 
      IF EMPTY(::lAuto) .AND. !EMPTY(::aBuffer[REP_EMAIL][REP_EMAIL_TO])
         ::sleEmail:setData(::aBuffer[REP_EMAIL][REP_EMAIL_TO])
      ENDIF
   ELSE 
      IF !EMPTY(::aBuffer[REP_NAME])
         ::sleOggetto:SetData(::aBuffer[REP_NAME])
      ELSE
         ::sleOggetto:SetData(dfStdMsg1(MSG1_S2PDISSM07))
      ENDIF
      ::sleTesto:SetData(dfStdMsg1(MSG1_S2PDISSM08)+CRLF)
   ENDIF 
   //////////////////////////////////////////////////////////////////////////////////////////////

   ::txtFile:create()
   ::sleFile:create()

   // SD 22/01/08 - GERR 5043
   // imposta la stampa in un path da settaggio .ini
   ************************************************************
   IF EMPTY(::aBuffer[REP_FNAME])
      ::aBuffer[REP_FNAME] := "file.txt"
   ENDIF
/*
   IF ! EMPTY( dfSet("XbasePathPrintFile") )
      ::aBuffer[REP_FNAME] := dfFNameBuild(::aBuffer[REP_FNAME], dfSet("XbasePathPrintFile"))
   ENDIF
*/

   cXBasePathPrintFile := dfSet("XbasePathPrintFile")
   IF ! EMPTY( cXBasePathPrintFile ) .AND. dfChkDir(cXBasePathPrintFile)
      ::aBuffer[REP_FNAME] := dfFNameBuild(::aBuffer[REP_FNAME], cXBasePathPrintFile)
   ENDIF
   ***********************************************************

   IF EMPTY(::aBuffer[REP_FNAME])
      ::sleFile:setData("File.Txt")
   ELSE
      // SD 12/12/2005 gerr 4573
      aFile :=  dfFNameSplit(::aBuffer[REP_FNAME])

      // Gerr 3794 Luca 15/05/03
      IF EMPTY(aFile[4])
         ::sleFile:setData(ALLTRIM(::aBuffer[REP_FNAME])+".Txt")
      ELSE
         // SD 12/12/2005 gerr 4573
         ::sleFile:setData(ALLTRIM(::aBuffer[REP_FNAME]))
      ENDIF
   ENDIF

   ::txtSelection:create()

   ::cmbSelect:create()
   AEVAL(aTipOutPut, {|x| ::cmbSelect:addItem(x) })
   aFile :=  dfFNameSplit(ALLTRIM(aBuf[REP_FNAME]))
   // Simone 15/4/03 gerr 3766
   IF dfSet(AI_XBASEDISABLEPDFPRINT)        
      ::lPdf := .F.
   ELSE
      ::lPdf := UPPER(aFile[4]) ==  ".PDF"
   ENDIF
   ::cmbSelect:XbpSLE:setData(aTipOutPut[ IIF(::lPdf, 2, 1) ])

   ::ckbZip:create()
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

   IF dfSet(AI_XBASEDISABLEPDFPRINT)
      ::txtSelection:hide()
      ::txtPaper:hide()
      ::txtOrienta:hide()
      ::cmbSelect:hide()
      ::cmbPaper:hide()
      ::cmbOrienta:hide()
   ELSE
      IF ::lPdf
         ::cmbPaper:Enable()
         ::cmbOrienta:Enable()
      ELSE
         ::cmbPaper:disable()
         ::cmbOrienta:disable()
      ENDIF
   ENDIF

   // DA ATTIVARE
   // ::btnBrowse:create()

RETURN self

METHOD S2PrintDispSMTPMail:exitMenu(nAction, aBuf)
   LOCAL cFile       := ALLTRIM(::sleFile:getData())
   LOCAL aFName      := dfFNameSplit(cFile)
   LOCAL cFileTxt    := aFName[1]+aFName[2]+aFName[3]+".Txt"
   LOCAL aSel,nSel

   ::cMailTo := ::sleEmail:getData()
   ::cServer := dfSet("XbaseSMTPServer")
   ::cFrom   := dfSet("XbaseSMTPFrom")
   /////////////////////////////////////////
   //Luca  17/04/2015
   ::cReplyto:= dfSet("XbaseSMTPReplyTo") 
   IF EMPTY(::cReplyto)
     ::cReplyto := dfSet("XbaseSMTPFrom")
   ENDIF 
   /////////////////////////////////////////
   ::cOggetto:= ConvToAnsiCP(ALLTRIM(::sleOggetto:GetData()))
   ::cBody   := ConvToAnsiCP(ALLTRIM(::sleTesto:GetData()))

   ::cUser    := dfSet("XbaseSMTPUser")
   ::cPassword:= dfSet("XbaseSMTPPassword")
   ::nLoginMethod := dfSet("XbaseSMTPLoginMethod")
   IF ::nLoginMethod != NIL
      ::nLoginMethod := VAL(::nLoginMethod)
   ENDIF

   DEFAULT ::cFrom    TO ""
   //Luca  17/04/2015
   DEFAULT ::cReplyto TO ""

   IF nAction > 0
      DO CASE
         CASE ! ::lAuto .AND. EMPTY(::cMailTo)
            dbMsgErr(dfStdMsg1(MSG1_S2PDISSM03))
            nAction := -1

         CASE EMPTY(::cServer)
            dbMsgErr(dfStdMsg1(MSG1_S2PDISSM04))
            nAction := -1

         CASE EMPTY(::cFrom)
            dbMsgErr(dfStdMsg1(MSG1_S2PDISSM05))
            nAction := -1

         CASE EMPTY(aFName[3])
            dbMsgErr(dfStdMsg1(MSG1_S2PDISFI12))
            nAction := -1
         CASE EMPTY(::cOggetto) .OR. EMPTY(::cBody)
            IF !dfYesNO(dfStdMsg1(MSG1_S2PDISSM13)+"//"+;
                        IIF(EMPTY(::cOggetto)," - "+STRTRAN(STRTRAN(dfStdMsg1(MSG1_S2PDISSM10),"&"),":")+"//" ,"" ) +;
                        IIF(EMPTY(::cBody   )," - "+STRTRAN(STRTRAN(dfStdMsg1(MSG1_S2PDISSM11),"&"),":")      ,"" )  ;
                         )
               nAction := -1
            ENDIF
      ENDCASE
   ENDIF

   IF ::lPdf

      //Setto Parametri per creazione Pdf
      //E' necessario passsare i corretti parametri
      aBuf[REP_PRINTERPORT] := "FILE"
      aBuf[REP_FNAME]       := cFile

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
      aBuf[REP_FNAME]       := cFile

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

METHOD S2PrintDispSMTPMail:execute()
   LOCAL oMail
   LOCAL lRet := .F.
   LOCAL cFile       := IIF(!EMPTY(::aBuffer[REP_FNAME]),ALLTRIM(::aBuffer[REP_FNAME]),"FILE")
   LOCAL aFName      := dfFNameSplit(cFile)
   LOCAL cFileTxt    := aFName[1]+aFName[2]+aFName[3]+".Txt"
   LOCAL cFilePdf    := NIL//aFName[1]+aFName[2]+aFName[3]+".Pdf"
   LOCAL cTitle      := ::aBuffer[REP_NAME]
   //LOCAL aExtra      := NIL // Non Viene utilizato ::aBuffer[REP_XBASEPRINTEXTRA]
   LOCAL aExtra      := ::aBuffer[REP_XBASEPRINTEXTRA]
   LOCAL nOptions    := 1   //3
   LOCAL cTipoFormatoPagina
   LOCAL cVerso
   LOCAL bEnd        := {|cFilePdf,lOk| ::End_Execute(cFilePdf,lOk,cFileTxt,cFile,oMail,nOptions) }

   cFileTxt := dfFNameBuild(UPPER(cFileTxt))
   cFile    := dfFNameBuild(UPPER(cFile))


   IF ::lAuto .AND. ::bAuto != NIL
      ::cMailTo := EVAL(::bAuto)
   ENDIF

   IF ! EMPTY(::cMailTo)

      IF nOptions <=1
         dbMsgOn(dfStdMsg1(MSG1_S2PDISSM06)+::cMailTo)
      ENDIF

      oMail:= S2Mail():new()

      oMail:cServer  := ::cServer
      oMail:cFROM    := ::cFrom
      oMail:cSubject := ::cOggetto
      oMail:cBody    := ::cBody
      //////////////////////////////////
      //Luca  17/04/2015
      //oMail:cReplyTo := oMail:cFrom
      oMail:cReplyTo := ::cReplyTo 
      IF EMPTY(oMail:cReplyTo)
         oMail:cReplyTo := oMail:cFrom
      ENDIF
      //////////////////////////////////
      oMail:cUser    := ::cUser
      oMail:cPassword:= ::cPassword
      oMail:nLoginMethod:=::nLoginMethod

      AEVAL(S2EmailAddressNormalize(::cMailTo), {|cTo| oMail:addTo( cTO ) })
      //AEVAL(dfStr2Arr(::cMailTo, ";"), {|cTo| oMail:addTo( cTO ) })

      // Rinomino in file con estensione .TXT
      IF !cFile == cFileTxt
         FERASE(cFileTxt)
         IF FRENAME(cFile, cFileTxt)!=0
            dbMsgErr(dfStdMsg1(MSG1_S2PDISSM09)+ALLTRIM(STR(FERROR())))
            lRet := .F.
         ENDIF
      ENDIF

      IF ::lPdf

         cTipoFormatoPagina := ::aBuffer[REP_PDF_PAGE_FORMAT]
         cVerso             := ::aBuffer[REP_PDF_ORIENTATION]

         IF dfTxt2Pdf( cFileTxt,@cFilePdf, cTitle, aExtra, nOptions,cTipoFormatoPagina,cVerso,bEnd)
            lRet := .T.
         ELSE
            //Errore creazione File Pdf
            dbMsgErr(dfStdMsg1(MSG1_S2PDISFI08))
            lRet := .F.
         ENDIF
      ELSE
         // Simone 05/set/03 gerr 3926
         IF ::lZip 
            cFileTxt := ::zipFile(cFileTxt)
         ENDIF
         oMail:addAttach( cFileTxt )
         oMail:send()
         ::nError    := oMail:nError
         ::cErrorMsg := oMail:cMsg
         FERASE(cFileTxt)
         FERASE(cFile)
         lRet := .T.
      ENDIF
      IF nOptions <=1
         dbMsgOff()
      ENDIF

   ELSE
      dfAlert(dfStdMsg1(MSG1_S2PDISSM09)+ALLTRIM(STR(FERROR())))
      lRet := .F.
   ENDIF
RETURN lRet

// simone 18/2/08
// 0000652: i report di tipo reportmanager non hanno menu di stampa
// aggiunta variabile "n"
METHOD S2PrintDispSMTPMail:OutPutSelect( n )
   LOCAL cFile, cPath

   cPath    := ::sleFile:GetData()
   cFile    := dfFindName(cPath)
   IF EMPTY(cFile)
      cFile := "File"
   ELSE
      cFile := ALLTRIM(cFILE)
   ENDIF
   cPath    := dfPathchk(LEFT(cPath,AT(cFile,cPath)-1))
   IF EMPTY(cPath)
      //cPath := dfPathchk(dfCurPath())
   ENDIF

   DEFAULT n TO ::cmbSelect:GetData()[1] 

   IF n == 1
      ::lPdf := .F.       //Creo in Txt
      ::sleFile:SetData(cPath + cFile + ".Txt")
      ::cmbPaper:disable()
      ::cmbOrienta:disable()
   ELSE
      ::lPdf := .T.       //Creo in Pdf
      ::sleFile:SetData(cPath + cFile + ".Pdf")
      ::cmbPaper:enable()
      ::cmbOrienta:enable()
   ENDIF

RETURN NIL

// DA ATTIVARE
// METHOD S2PrintDispSMTPMail:rubrica()
//    LOCAL xRet := ""
//
//    dfAlert("da fare...")
//    xRet := "hot@studio2000.net"
//
//    IF ! EMPTY(xRet)
//       ::sleEmail:setData(xRet)
//    ENDIF
//
// RETURN .F.

METHOD S2PrintDispSMTPMail:End_Execute(cFilePdf,lOk,cFileTxt,cFile,oMail,nOptions)
   IF lOk
      // Simone 05/set/03 gerr 3926
      IF ::lZip 
         cFilePdf := ::zipFile(cFilePdf)
      ENDIF
      oMail:addAttach( cFilePdf )
      oMail:send()
      ::nError    := oMail:nError
      ::cErrorMsg := oMail:cMsg
      FERASE(cFilePdf)
      FERASE(cFileTxt)
      FERASE(cFile)
      IF nOptions >=2
         dfalert(dfStdMsg1(MSG1_S2PDISSM12))
      ENDIF
   ELSE
      //Errore creazione File Pdf
      dbMsgErr(dfStdMsg1(MSG1_S2PDISFI08))
   ENDIF
RETURN .T.

// Simone 05/set/03 gerr 3926
// Prova a creare un file ZIP con stesso nome
// del file di testo, se ci riesce cancella il file
// originario (move).
// Restituisce il nome di file da inviare in attach
METHOD S2PrintDispSMTPMail:zipFile(cFileName)
   LOCAL cRet
   LOCAL aFName := dfFNameSplit(cFileName)
   LOCAL aZip   := ACLONE(aFName)
   LOCAL cZipName

   // Cambio estensione
   aZip[4] := ".zip"
   cZipName := aZip[1]+aZip[2]+aZip[3]+aZip[4]

   // display messaggio dopo 3 secondi
   //dbMsgOn("ZIP File:" + aFName[3]+aFName[4], 3)
   dbMsgOn( STRTRAN(dfStdMsg1(MSG1_S2PDISMM10), "%file%", aFName[3]+aFName[4] ), 3 )

   // "Muovo" il file nello zip
   IF dfZipFile(cZipName, aFName[1]+aFName[2], NIL, aFName[3]+aFName[4], NIL, .F., .T.) == 0
      //FERASE(cFileName)
      cRet := cZipName
   ELSE
      cRet := cFileName
   ENDIF
   dbMsgOff()
RETURN cRet



