#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "dfReport.ch"
#include "dfMsg1.ch"
#include "dfPdf.ch"
#include "dfWinRep.ch"

#include "s2crwpri.ch"

#define _LF (CHR(10))

// Dispositivo di stampa
// stampa su mail MAPI

CLASS S2PrintDispCRWMAPIMail FROM S2PrintDisp
   PROTECTED:
      METHOD createFile
      METHOD getExportTypes
      VAR xExportData
      VAR aTipOutput

   EXPORTED:

      VAR txtEmail
      VAR txtOggetto
      VAR txtTesto
      VAR txtFile
      VAR txtSelection

      VAR sleEmail
      VAR sleOggetto
      VAR sleTesto
      VAR sleFile

      VAR cmbSelect
      VAR ckbAuto
      VAR ckbZIP

      VAR cMailTo,cOggetto,cBody
      VAR cFrom,cReplyTo 


      VAR cAutoCaption

      VAR xProfile

      VAR nFmt
      VAR lZip
      VAR lAuto, bAuto

      // DA ATTIVARE
      //VAR btnBrowse

      METHOD init
      METHOD create
      METHOD exitMenu
      METHOD execute

      METHOD OutPutSelect

//      INLINE METHOD canSupportFont(); RETURN ::lPdf
//      INLINE METHOD canSupportImg() ; RETURN ::lPdf
//      INLINE METHOD canSupportBox() ; RETURN ::lPdf

      METHOD zipFile
      // DA ATTIVARE
      //METHOD rubrica
      METHOD Close
ENDCLASS

METHOD S2PrintDispCRWMAPIMail:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::dispName := dfStdMsg1(MSG1_S2PDISMM01)

   oXbp     := XbpStatic():new( self, , {0,98}, {85,14} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISMM02)
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

   oXbp              := XbpCombobox():new( self, , {500,-15}, {120,100}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:type         := XBPCOMBO_DROPDOWNLIST
   oXbp:tabStop      := .T.
   oXbp:itemSelected := {|| ::OutPutSelect() }
   ::addShortCut(::txtSelection:caption, oXbp)
   ::cmbSelect       := oXbp

   oXbp              := XbpCheckbox():new( self, , {500,30}, {60,23})
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISMM09) // "&ZIP file"
   oXbp:clipSiblings := .T.
   oXbp:tabStop      := .T.
   oXbp:selected := {|l| ::lZip := l}
   ::addShortCut(oXbp:caption, oXbp)
   ::ckbZip          := oXbp


  // DA ATTIVARE
  //  oXbp       := XbpPushButton():new( self, , {324,56}, {96,24} )
  //  oXbp:caption := "&Rubrica"
  //  oXbp:clipSiblings := .T.
  //  oXbp:tabStop := .T.
  //  oXbp:activate := {|| ::rubrica() }
  //  ::addShortCut(oXbp:caption, oXbp)
  //  ::btnBrowse := oXbp

   ::cMailTo := ""
   ::xProfile:= 0
   ::cBody   := ""
   ::cOggetto:= ""
   ::cFrom   := ""
   ::cReplyTo:= ""

   ::cAutoCaption := ""
   ::lAuto := .F.
   ::bAuto := NIL

   ::lZip := .F.

   //::sleEmail:type := XBPCOMBO_DROPDOWNLIST
   ::aTipOutPut := ::GetExportTypes() 

RETURN self

METHOD S2PrintDispCRWMAPIMail:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL cPrinter, aBuf:= ::aBuffer
   LOCAL oXbp
   LOCAL aSizechk   := {0,0}
   LOCAL aSizeSle
   LOCAL aPosSle
   LOCAL aFile
   LOCAL nSel := 0
   LOCAL nPOS := 0
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
   IF ! EMPTY(::lAuto)  // simone d 17/1/07 gerr 4779
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
            ::sleOggetto:SetData(dfStdMsg1(MSG1_S2PDISMM05))
         ENDIF
      ENDIF 
      IF !EMPTY(::aBuffer[REP_EMAIL][REP_EMAIL_BODY])
         ::sleTesto:SetData(::aBuffer[REP_EMAIL][REP_EMAIL_BODY]+CRLF)
      ELSE 
         ::sleTesto:SetData(dfStdMsg1(MSG1_S2PDISMM06)+CRLF)
      ENDIF 
      IF EMPTY(::lAuto) .AND. !EMPTY(::aBuffer[REP_EMAIL][REP_EMAIL_TO])
         ::sleEmail:setData(::aBuffer[REP_EMAIL][REP_EMAIL_TO])
      ENDIF

   ELSE 
      IF !EMPTY(::aBuffer[REP_NAME])
         ::sleOggetto:SetData(::aBuffer[REP_NAME])
      ELSE
         ::sleOggetto:SetData(dfStdMsg1(MSG1_S2PDISMM05))
      ENDIF
      ::sleTesto:SetData(dfStdMsg1(MSG1_S2PDISMM06)+CRLF)
   ENDIF 
   //////////////////////////////////////////////////////////////////////////////////////////////

   ::txtFile:create()
   ::sleFile:create()

   ::txtSelection:create()

   ::cmbSelect:create()
   ::ckbZip:create()
   IF LEN(::aTipOutput)==0
      ::nFmt := 0
      ::sleEmail:setData(dfStdMsg1(MSG1_S2PDISCF06)) //"export not available"
      ::sleOggetto:setData("") //"export not available"
      ::sleTesto:setData("")
      ::cmbSelect:disable()

      ::sleEmail:disable()
      ::sleOggetto:disable()
      ::sleTesto:disable()
      ::sleFile:disable()

      ::cmbSelect:disable()
      ::ckbZIP:disable()
      IF ! EMPTY(::ckbAuto)
         ::ckbAuto:disable()
      ENDIF
   ELSE
      ::nFmt := 1
      ::cmbSelect:enable()
      AEVAL(::aTipOutPut, {|x| ::cmbSelect:addItem(x[DFCRWET_DEX]) })
      ::cmbSelect:XbpSLE:setData(::aTipOutPut[ ::nFmt ][DFCRWET_DEX])

      // SD 22/01/08 - GERR 5043
      // imposta la stampa in un path da settaggio .ini
      ************************************************************
      IF EMPTY(::aBuffer[REP_FNAME])
         ::aBuffer[REP_FNAME] := "File"+::aTipOutPut[ ::nFmt ][DFCRWET_EXT]
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

      //Modificato --->
      //::sleFile:setData(::aBuffer[REP_FNAME])
      IF EMPTY(::aBuffer[REP_FNAME])
         ::sleFile:setData("File"+::aTipOutPut[ ::nFmt ][DFCRWET_EXT])
      ELSE
         // SD 12/12/2005 gerr 4573
         aFile :=  dfFNameSplit(::aBuffer[REP_FNAME])
         //Mantis 2097 
         ////////////////////////////////////////////////////////////////
         //LC 31/05/2010 Richiesta di avere il defualt se richiesto in PDF
         IF !EMPTY(aFile[4]) .AND. Alltrim(UPPER(aFile[4])) == ".PDF" 
            nPOS  := ASCAN(::aTipOutPut, {|x|  UPPER(x[DFCRWET_EXT]) == ".PDF" })
            IF nPOS>0 .AND. ! UPPER(::aTipOutPut[ ::nFmt ][DFCRWET_EXT]) == ".PDF"
               ::nFmt := nPOS
               ::cmbSelect:XbpSLE:setData(::aTipOutPut[ ::nFmt ][DFCRWET_DEX])
            ENDIF 
         ENDIF 
         ////////////////////////////////////////////////////////////////

         // Gerr 3794 Luca 15/05/03
//         IF AT(".",::aBuffer[REP_FNAME]) <1
//            ::sleFile:setData(ALLTRIM(::aBuffer[REP_FNAME])+::aTipOutPut[ ::nFmt ][DFCRWET_EXT])
//         ENDIF
         IF EMPTY(aFile[4])
            ::sleFile:setData(ALLTRIM(::aBuffer[REP_FNAME])+::aTipOutPut[ ::nFmt ][DFCRWET_EXT])
         ELSE
            // SD 12/12/2005 gerr 4573
            ::sleFile:setData(ALLTRIM(::aBuffer[REP_FNAME]))
         ENDIF
      ENDIF
   ENDIF


RETURN self

METHOD S2PrintDispCRWMAPIMail:exitMenu(nAction, aBuf)
   LOCAL cFile       := ALLTRIM(::sleFile:getData())
   LOCAL aFName      := dfFNameSplit(cFile)
   //LOCAL cFileTxt    := aFName[1]+aFName[2]+aFName[3]+".Txt"
   LOCAL aSel,nSel

   ::cMailTo  := ::sleEmail:getData()
   ::xProfile := dfSet("XbaseMAPIProfile")
   ::cOggetto := ConvToAnsiCP(ALLTRIM(::sleOggetto:GetData()))
   ::cBody    := ConvToAnsiCP(ALLTRIM(::sleTesto:GetData()))

   DEFAULT ::xProfile TO 0

   IF nAction > 0
      DO CASE
         CASE ::nFmt == 0
            dbMsgErr(dfStdMsg1(MSG1_S2PDISCF06)) //"export not available"
            nAction := -1  // rimane nel menu

         CASE ! ::lAuto .AND. EMPTY(::cMailTo)
            dbMsgErr(dfStdMsg1(MSG1_S2PDISMM03))
            nAction := -1

         CASE EMPTY(aFName[3])
            dbMsgErr(dfStdMsg1(MSG1_S2PDISFI12))
            nAction := -1
         CASE EMPTY(::cOggetto) .OR. EMPTY(::cBody)
            IF !dfYesNO(dfStdMsg1(MSG1_S2PDISSM13)+"//"+;
                        IIF(EMPTY(::cOggetto)," - "+STRTRAN(STRTRAN(dfStdMsg1(MSG1_S2PDISSM10),"&"),":")+"//"  ,"" ) +;
                        IIF(EMPTY(::cBody   )," - "+STRTRAN(STRTRAN(dfStdMsg1(MSG1_S2PDISSM11),"&"),":")       ,"" )  ;
                         )
               nAction := -1
            ENDIF

      ENDCASE
      IF nAction > 0
         ::xExportData := {::aTipOutput[::nFmt][DFCRWET_ID], S2UXDDiskType, cFile}
      ENDIF
   ENDIF


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

RETURN nAction

METHOD S2PrintDispCRWMAPIMail:execute()
   LOCAL oMail
   LOCAL lRet := .F.
   LOCAL cFile       := ALLTRIM(::aBuffer[REP_FNAME])
   LOCAL aFName      := dfFNameSplit(cFile)
   LOCAL cFilePdf    := NIL//aFName[1]+aFName[2]+aFName[3]+".Pdf"
   LOCAL cTitle      := ::aBuffer[REP_NAME]
   //LOCAL aExtra      := NIL// Non viene utilizzato ::aBuffer[REP_XBASEPRINTEXTRA]
   LOCAL aExtra      := ::aBuffer[REP_XBASEPRINTEXTRA]
   LOCAL nOptions    := 1  //3
   LOCAL cTipoFormatoPagina
   LOCAL cVerso

   // Ricostruisco il nome del file con il percorso completo
   // in base al percorso corrente altrimenti posso avere
   // dei problemi con il send()
   cFile    := dfFNameBuild(UPPER(cFile))

   IF ::lAuto .AND. ::bAuto != NIL
      ::cMailTo := EVAL(::bAuto)
   ENDIF

   IF ! EMPTY(::cMailTo)

      IF nOptions <=1
         dbMsgOn(dfStdMsg1(MSG1_S2PDISMM04)+::cMailTo)
      ENDIF
      oMail:= S2Mapi():new()

      oMail:cSubject := ::cOggetto
      oMail:cBody    := ::cBody
      //////////////////////////////////
      //Luca  17/04/2015
      //oMail:cReplyTo := oMail:cFrom
      IF !EMPTY(::cFrom)
         oMail:cFROM    := ::cFrom
      ENDIF 
      oMail:cReplyTo := ::cReplyTo 
      //////////////////////////////////
      // Simone 5/set/03 gerr 3927
      AEVAL(S2EmailAddressNormalize(::cMailTo), {|cTo| oMail:addTo( cTO ) })
      //AEVAL(dfStr2Arr(::cMailTo, ";"), {|cTo| oMail:addTo( cTO ) })


      IF ::createFile()
         // Simone 05/set/03 gerr 3926
         IF ::lZip 
            cFile := ::zipFile(cFile)
         ENDIF
         oMail:addAttach( cFile )
         oMail:send()
         ::nError    := oMail:nError
         ::cErrorMsg := oMail:cMsg
         FERASE(cFile)
         lRet := .T.
      ENDIF
      IF nOptions <=1
         dbMsgOff()
      ENDIF

   ELSE
      dfAlert(dfStdMsg1(MSG1_S2PDISMM07)+ALLTRIM(STR(FERROR())))
      lRet := .F.
   ENDIF

RETURN lret


METHOD S2PrintDispCRWMAPIMail:createFile() // cFile, cTitle, xDevice)
   LOCAL lRet      := .T.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oCRWOut   := oRT:getOutput()
   LOCAL oCRWPrint := oRT:getPrint()
   LOCAL aArrFName := oCRWOut:getFName()
   LOCAL cArrFName := dfArr2Str(aArrFName, ", ")
   LOCAL oPrn
   LOCAL nErr       

   // Cancello il file TESTO temporaneo
   FERASE( ::aBuffer[REP_FNAME] )

   // Chiudo il file DBF contenente i dati
   oCRWOut:close()

   DEFAULT oPrn TO dfCRWPrinterObject()


   IF dfCRWEngineLoaded()

      // Preview
      //nErr := oCRWPrint:preview(oCRWOut:cRPT, ::aBuffer[REP_NAME], ;
      //                          oRT:setFormula(), oRT:setFlag(), ;
      //                          {oCRWOut:cFName}, oPrn)

//      ::xExportData := dfSet("crwexport") //{1, 0, "appa"}
//      ::xExportData := &(::xExportData)
      nErr := oCRWPrint:exportTo(oCRWPrint:cRepName, ::xExportData, ;
                              oRT:setFormula(), aArrFName) 

      lRet := nErr == 0

      IF ! lRet  
         IF nErr == -1
            //dbMsgErr(dfStdMsg1(MSG1_S2PDISCF02)+oCRWOut:cRPT)
            dbMsgErr(dfStdMsg1(MSG1_S2PDISCF02)+oCRWPrint:cRepName)
         ELSEIF "CANCEL" $ UPPER(oCRWPrint:cErrMsg) .AND. ;
                "USER" $ UPPER(oCRWPrint:cErrMsg)
            // codice di errore USER CANCELLED (ha premuto ESC)
            // non do errore! per il controllo non uso oCRW:nErrCode 
            // perche pu• cambiare!!
         ELSE
            //dbMsgErr(dfStdMsg1(MSG1_S2PDISCF05)+oCRWOut:cRPT+"//"+;
            dbMsgErr(dfStdMsg1(MSG1_S2PDISCF05)+oCRWPrint:cRepName+"//"+;
                     ALLTRIM(STR(oCRWPrint:nErrCode))+"-"+STRTRAN(oCRWPrint:cErrMsg, _LF, "//"))
         ENDIF
      ELSEIF dfCRWDesign()
         //dfAlert(dfStdMsg1(MSG1_S2PDISCF03)+oCRWOut:cFName)
         dfAlert(dfStdMsg1(MSG1_S2PDISCF03)+cArrFName)

      ENDIF

   ELSE
      dbMsgErr(dfStdMsg1(MSG1_S2PDISCF04))
      lRet := .F.
   ENDIF

   // Se sono in modalit… di DESIGN non cancello il file
   // DBF cosi posso costruirci sopra il REPORT con crystal
   //Gerr. 3438 30/10/03 Luca: Aggiunta la possibilit… di non cancellare il file 
   // dbf temporaneo creato.
   //IF ! dfCRWDesign()
   IF ! dfCRWDesign() 
      // Cancello il file DBF contenente i dati
      //FERASE(oCRWOut:cFName)
      //////////////////////////////////////
      //Luca 11/02/2016
      IF dfSet("XbaseCRWTempFileErase") == "NO"

      ELSE
         oCRWOut:FErase() 
      ENDIF 
      //////////////////////////////////////
   ENDIF

RETURN lRet


// DA ATTIVARE
// METHOD S2PrintDispCRWMAPIMail:rubrica()
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

METHOD S2PrintDispCRWMAPIMail:OutPutSelect()
   LOCAL cFile, cPath

   ::nFmt := ::cmbSelect:XbpListBox:getData()[1]

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
   ::sleFile:SetData(cPath + cFile + ::aTipOutPut[ ::nFmt ][DFCRWET_EXT])


RETURN NIL

// Simone 05/set/03 gerr 3926
// Prova a creare un file ZIP con stesso nome
// del file di testo, se ci riesce cancella il file
// originario (move).
// Restituisce il nome di file da inviare in attach
METHOD S2PrintDispCRWMAPIMail:zipFile(cFileName)
   LOCAL cRet
   LOCAL aFName := dfFNameSplit(cFileName)
   LOCAL aZip   := ACLONE(aFName)
   LOCAL cZipName

   // Cambio estensione
   aZip[4] := ".zip"
   cZipName := aZip[1]+aZip[2]+aZip[3]+aZip[4]

   // display messaggio dopo 3 secondi
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

// tolgo il tipo XML perche non andrebbe bene perche 
// il file da generare viene messo in una cartella richiesta all'utente
METHOD S2PrintDispCRWMAPIMail:getExportTypes()
   LOCAL aET := ACLONE( dfCRWGetExportTypes() )
   LOCAL n := ASCAN(aET, {|x|x[DFCRWET_ID]==S2UXFXMLType})
   IF n > 0
      #ifdef _XBASE18_
        AREMOVE(aET, n)
      #else
        DFAERASE(aET, n)
      #endif
   ENDIF
RETURN aET

//Ger 4287 Luca 22/10/2004
// Inserito Per la chiusura delle dei file aperti quando non c'Š nulla da stampare
METHOD S2PrintDispCRWMAPIMail:Close()
   LOCAL lRet      := .F.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oCRWOut   := oRT:getOutput()
   // Eseguo Metodo di chiusura della classe padre
   ::S2PrintDisp:Close()
   // Chiudo il file DBF contenente i dati
   oCRWOut:close()
   // Cancello il file DBF contenente i dati
   IF ! dfCRWDesign() 
      oCRWOut:FErase() 
   ENDIF
   lRet := .T. 
RETURN lRet
  

