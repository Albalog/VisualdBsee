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
// stampa su FILE

CLASS S2PrintDispFile FROM S2PrintDisp

   EXPORTED:
      VAR txtFile
      VAR txtSelection
      VAR sleFile
      VAR txtOrienta

      VAR btnBrowse
      VAR cmbSelect
      VAR chkBox
      VAR lOpen
      VAR lPdf
      VAR cmbPaper
      VAR txtPaper
      VAR cmbOrienta

      VAR aForms
      VAR aOrientation

      METHOD init
      METHOD create
      METHOD exitMenu
      METHOD execute
      METHOD isDefault

      METHOD sfoglia
      METHOD OutPutSelect
      METHOD End_Execute

      INLINE METHOD canSupportFont(); RETURN ::lPdf
      INLINE METHOD canSupportImg() ; RETURN ::lPdf
      INLINE METHOD canSupportBox() ; RETURN ::lPdf
ENDCLASS

METHOD S2PrintDispFile:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::dispName := dfStdMsg1(MSG1_S2PDISFI01)

   oXbp     := XbpStatic():new( self, , {12,92}, {72,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISFI02)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   ::txtFile := oXbp

   oXbp     := XbpSle():new( self, , {12,65}, {300,24}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:autoTab := .T.
   oXbp:tabStop := .T.
   oXbp:bufferLength := 250
   ::addShortCut(::txtFile:caption, oXbp)
   ::sleFile := oXbp

   oXbp       := XbpPushButton():new( self, , {324,65}, {96,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISFI03)
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:activate := {|| ::sfoglia() }
   ::addShortCut(oXbp:caption, oXbp)
   ::btnBrowse := oXbp

   //Implementato il 07/02/2003 per Stampa su Pdf. Luca
   oXbp     := XbpStatic():new( self, , {12,45}, {140,15} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISFI05)
   oXbp:clipSiblings := .T.
   oXbp:options      := XBPSTATIC_TEXT_BOTTOM
   ::txtSelection    := oXbp

   oXbp              := XbpCombobox():new( self, , {12,-58}, {120,100}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:type         := XBPCOMBO_DROPDOWNLIST
   oXbp:tabStop      := .T.
   oXbp:itemSelected := {|| ::OutPutSelect() }
   ::addShortCut(::txtSelection:caption, oXbp)
   ::cmbSelect       := oXbp

   oXbp              := XbpCheckbox():new( self, , {150,24}, {0,0} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISFI06)
   oXbp:clipSiblings := .T.
   oXbp:tabStop      := .T.
   oXbp:autoSize     := .T.
   oXbp:selected     := {|l| ::lOpen := l }
   ::addShortCut(oXbp:caption, oXbp)
   ::chkBox          := oXbp

   oXbp              := XbpStatic():new( self, , {324,44}, {80,15} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISWP05)
   oXbp:clipSiblings := .T.
   oXbp:options      := XBPSTATIC_TEXT_BOTTOM
   ::txtPaper        := oXbp

   oXbp              := XbpCombobox():new( self, , {324,-58}, {100,100}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:tabStop      := .T.
   oXbp:type         := XBPCOMBO_DROPDOWNLIST
   ::cmbPaper        := oXbp
   ::addShortCut(::txtPaper:caption, oXbp)

   oXbp              := XbpStatic():new( self, , {450,45}, {110,15} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISFI07)
   oXbp:clipSiblings := .T.
   oXbp:options      := XBPSTATIC_TEXT_BOTTOM
   ::txtOrienta      := oXbp

   oXbp              := XbpCombobox():new( self, , {450,-58}, {110,100}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:tabStop      := .T.
   oXbp:type         := XBPCOMBO_DROPDOWNLIST
   ::cmbOrienta      := oXbp
   ::addShortCut(::TxtOrienta:caption, oXbp)


   //::sleFile:type := XBPCOMBO_DROPDOWNLIST

RETURN self

METHOD S2PrintDispFile:isDefault()
RETURN UPPER(ALLTRIM(::aBuffer[REP_PRINTERPORT])) == "FILE"

METHOD S2PrintDispFile:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL cPrinter, aBuf:= ::aBuffer
   LOCAL aTipOutPut := {"*.Txt","*.Pdf"}
   LOCAL aFile
   LOCAL nSel := 0
   LOCAL cXBasePathPrintFile := ""

   ::S2PrintDisp:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

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

   //Modificato --->
   //::sleFile:setData(::aBuffer[REP_FNAME])
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

   ::btnBrowse:create()

   //Luca
   ::txtSelection:create()

   ::cmbSelect:create()
   AEVAL(aTipOutPut, {|x| ::cmbSelect:addItem(x) })

   aFile :=  dfFNameSplit(ALLTRIM(aBuf[REP_FNAME]))
   IF dfSet(AI_XBASEDISABLEPDFPRINT)        
      ::lPdf := .F.
   ELSE
      ::lPdf := UPPER(aFile[4]) ==  ".PDF"
   ENDIF
   ::cmbSelect:XbpSLE:setData(aTipOutPut[ IIF(::lPdf, 2, 1) ])

   ::chkBox:create()
   ::chkBox:enable()
   ::lOpen := .F.

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

      ::lOpen := .F.
      ::chkBox:hide()
   ELSE
      IF ::lPdf
         ::cmbPaper:enable()
         ::cmbOrienta:enable()
      ELSE
         ::cmbPaper:disable()
         ::cmbOrienta:disable()
      ENDIF
   ENDIF

RETURN self

METHOD S2PrintDispFile:exitMenu(nAction, aBuf)
   LOCAL cFile       := ALLTRIM(::sleFile:getData())
   LOCAL aFName      := dfFNameSplit(cFile)
   //LOCAL cFileTxt    := aFName[1]+aFName[2]+aFName[3]+".Txt"
   LOCAL aSel,nSel


   IF nAction > 0
      DO CASE
         CASE (EMPTY(cFile) .OR. Empty(aFName[3]))
            dbMsgErr(dfStdMsg1(MSG1_S2PDISFI12))
            nAction := -1
      ENDCASE
   ENDIF

   IF ::lPdf

      //Setto Parametri per creazione Pdf
      //E' necessario passsare i corretti parametri
      aBuf[REP_PRINTERPORT] := "FILE"
      //aBuf[REP_FNAME]       := cFileTxt
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
      aBuf[REP_FNAME]       := ::sleFile:getData()
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

METHOD S2PrintDispFile:execute()
   LOCAL lRet        := .F.
   LOCAL cFile       := IIF(!EMPTY(::aBuffer[REP_FNAME]),ALLTRIM(::aBuffer[REP_FNAME]),"FILE")
   LOCAL aFName      := dfFNameSplit(cFile)
   LOCAL cFileTxt    := aFName[1]+aFName[2]+aFName[3]+IIF(::lPdf,".Pdf" , ".Txt")
   LOCAL cFilePdf    := NIL
   LOCAL cTitle      := ::aBuffer[REP_NAME]
   //LOCAL aExtra      := NIL  //Non viene utilizato ::aBuffer[REP_XBASEPRINTEXTRA]
   LOCAL aExtra      := ::aBuffer[REP_XBASEPRINTEXTRA]
   LOCAL nOptions    := 1 // 3
   LOCAL cTipoFormatoPagina
   LOCAL cVerso
   LOCAL bEnd        := {|cFilePdf,lOk| ::End_Execute(cFilePdf,lOk,::lOpen,nOptions)}
   LOCAL cTmp

   cFileTxt := dfFNameBuild(UPPER(cFileTxt))
   cFile    := dfFNameBuild(UPPER(cFile))


   //IF EMPTY(dfFNameSplit(cFile, 8))
      IF ::lPdf
         aFName := dfFNameSplit(cFile)
         //cFile    := aFName[1]+aFName[2]+aFName[3]+".txt"
         cFilePdf := aFName[1]+aFName[2]+aFName[3]+".Pdf"
      ELSE
         //cFile := aFName[1]+aFName[2]+aFName[3]+".Txt"
      ENDIF 
   //ENDIF 


   IF ::lPdf
      //E' necessario rinominare il file altrimenti in input 
      //ci sara Nome.pdf e in output Nome.pdf
      //Quindi la funzione dftxt2pdf() da un errore e non crea il pdf
      // Rinomino il file temporaneo in .TXT
      IF UPPER(cFile) == UPPER(cFilePdf)
         cTmp := dfFNameSplit(cFilePdf, 1)+dfFNameSplit(cFilePdf, 2)+dfFNameSplit(cFilePdf, 4)+"._xt"
         FRENAME(cFile, cTmp )
         cFile := cTmp
      ENDIF
      cFiletxt :=  cFile  
      //IF !UPPER(cFile) == UPPER(cFileTxt)
      //   FERASE(cFileTxt)
      //   FRENAME(cFile, cFileTxt)
      //ENDIF

      cTipoFormatoPagina := ::aBuffer[REP_PDF_PAGE_FORMAT]
      cVerso             := ::aBuffer[REP_PDF_ORIENTATION]


      //IF dfTxt2Pdf( cFileTxt,@cFilePdf,cTitle, aExtra, nOptions,cTipoFormatoPagina,cVerso,bEnd)
      IF dfTxt2Pdf( cFile,@cFilePdf,cTitle, aExtra, nOptions,cTipoFormatoPagina,cVerso,bEnd)
         lRet := .T.
      ELSE
         //Errore creazione File Pdf
         dbMsgErr(dfStdMsg1(MSG1_S2PDISFI08))
         lRet := .F.
      ENDIF

   ELSE
      
      IF !UPPER(cFile) == UPPER(cFileTxt)
         FERASE(cFileTxt)
         FRENAME(cFile, cFileTxt)
         cFile := cFileTxt
      ENDIF

      lRet := .T.
      IF ::lOpen
         //IF FILE(cFileTxt)
         IF FILE(cFile)
            //S2OpenRegisteredFile( cFileTxt ) //Bisogna pasargli il path corrente
            S2OpenRegisteredFile( cFile ) //Bisogna pasargli il path corrente
         ENDIF
      ENDIF
   ENDIF
RETURN lRet

METHOD S2PrintDispFile:sfoglia()
   LOCAL cFile := ::sleFile:getData()
   LOCAL aFName
   LOCAL cPath := NIL
   LOCAL xRet  := ""

   // Simone 18/9/03 gerr 3937
   // il nome del file non viene prevalorizzato 
   // con quello impostato nel campo del menu di stampa.
   IF ! EMPTY(cFile)
      cFile := dfFNameBuild(cFile)
      aFName:= dfFNameSplit(cFile)
      cPath := aFName[1]+aFName[2]
      cFile := aFName[3]+aFName[4] // nome file
      IF EMPTY(cPath)
         cPath := NIL
      ENDIF
   ENDIF

   IF EMPTY(cFile)
      cFile := "File"+IIF(::lPdf, ".Pdf", ".Txt")
   ENDIF


   IF !EMPTY(dfset("XbaseDefaultSavePath")) 
      cPATH := dfpathchk(dfset("XbaseDefaultSavePath"))
   ENDIF 

   xRet  := dfWinFileDlg(cPath,NIL, dfStdMsg1(MSG1_S2PDISFI04), cFile, .T.)

   IF ! EMPTY(xRet)
      ::sleFile:setData(xRet)
   ENDIF

RETURN .F.

// simone 18/2/08
// 0000652: i report di tipo reportmanager non hanno menu di stampa
// aggiunta variabile "n"
METHOD S2PrintDispFile:OutPutSelect(n)
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
      //::chkBox:disable()  //Disabilito checkBox Selezione "Apertura Acrobat"
      ::lPdf := .F.       //Creo in Txt
      ::sleFile:SetData(cPath + cFile + ".Txt")
      ::cmbPaper:disable()
      ::cmbOrienta:disable()
   ELSE
      //::chkBox:enable()   //Abilito checkBox Selezione "Apertura Acrobat"
      ::lPdf := .T.       //Creo in Pdf
      ::sleFile:SetData(cPath + cFile + ".Pdf")
      ::cmbPaper:enable()
      ::cmbOrienta:enable()
   ENDIF
RETURN NIL

METHOD S2PrintDispFile:End_Execute(cFilePdf,lOk,lOpen,nOptions)
   IF lOk
      IF lOpen
         //S2OpenRegisteredFile(cFilePdf)
         // GERR 3911 - Simone 28/8/03
         dfPDFView(cFilePDF)
      ENDIF
      IF nOptions >=2 .AND. ! lOpen
         dfalert(dfStdMsg1(MSG1_S2PDISFI11))
      ENDIF
   ELSE
      //Errore creazione File Pdf
      dbMsgErr(dfStdMsg1(MSG1_S2PDISFI08))
   ENDIF
RETURN lOk
