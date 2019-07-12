#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
// #include "Appevent.ch"
// #include "Font.ch"
#include "dfReport.ch"
#include "dfXbase.ch"
#include "dfMsg1.ch"
#include "dfRepMan.ch"

#define _LF (CHR(10))

// simone 18/2/08
// 0000652: i report di tipo reportmanager non hanno menu di stampa
// Dispositivo di stampa
// Stampante report manager smtp mail

CLASS S2PrintDispRMSmtpMail FROM S2PrintDispSmtpMail
EXPORTED:
   METHOD create
   METHOD execute
   METHOD close
   METHOD exportTo
   METHOD sendMail

ENDCLASS

METHOD S2PrintDispRMSmtpMail:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2PrintDispSmtpMail:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::txtPaper:hide()
   ::cmbPaper:hide()
   ::txtOrienta:hide()
   ::cmbOrienta:hide()

   // abilito solo invio PDF
   ::txtSelection:hide()
   ::cmbSelect:hide()

   // imposta PDF
   ::OutPutSelect( 2 )
RETURN self




//Ger 4287 Luca 22/10/2004
// Inserito Per la chiusura delle dei file aperti quando non c'Š nulla da stampare
METHOD S2PrintDispRMSmtpMail:Close()
   LOCAL lRet      := .F.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oRMOut   := oRT:getOutput()
   // Eseguo Metodo di chiusura della classe padre
   ::S2PrintDisp:Close()
   // Chiudo il file DBF contenente i dati
   oRMOut:close()
   // Cancello il file DBF contenente i dati
//   IF ! dfRMDesign()
      oRMOut:FErase()
//   ENDIF
   lRet := .T.
RETURN lRet


METHOD S2PrintDispRMSmtpMail:execute()
   LOCAL lRet        := .F.
   LOCAL cFile       := IIF(!EMPTY(::aBuffer[REP_FNAME]),ALLTRIM(::aBuffer[REP_FNAME]),"FILE")
   LOCAL aFName      := dfFNameSplit(cFile)
   LOCAL aExpType    := dfRMGetExportTypes()
   LOCAL oRT         := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oRMOut      := oRT:getOutput()
   LOCAL nPos
   LOCAL cFileOut

   // Cancello il file TESTO temporaneo
   FERASE( ::aBuffer[REP_FNAME] )
   dfXbaseExitProcAdd( dfExecuteActionDelFile():new(::aBuffer[REP_FNAME]) )

   // Chiudo il file DBF contenente i dati
   oRMOut:close()

//   IF ::lPDF
      cFileOut    := dfTemp()+aFName[3]+".PDF"
      nPos := ASCAN(aExpType,{|aArr| aArr[DFRMET_ID] == RM_EXPORT_PDF} )
//   ELSE
//      cFileOut    := dfTemp()+aFName[3]+".txt"
//      nPos := ASCAN(aExpType,{|aArr| aArr[DFRMET_ID] == RM_EXPORT_TEXT} )
//   ENDIF

   IF nPos != 0 .AND. ;
      ::exportTo( {aExpType[nPos][DFRMET_ID], cFileOut} ) .AND. ;
      ::sendMail(cFileOut)
      lRet := .T.
   ENDIF

   FERASE(cFileOut)
   dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cFileOut) )

RETURN lRet


METHOD S2PrintDispRMSmtpMail:exportTo(xExportData)
   LOCAL lRet      := .F.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oRMOut   := oRT:getOutput()
   LOCAL oRMPrint := oRT:getPrint()
   LOCAL aArrFName := oRMOut:getFName()
   LOCAL cArrFName := dfArr2Str(aArrFName, ", ")
//   LOCAL oPrn
   LOCAL nErr
   LOCAL aTmpDbf
   LOCAL aRpt
   LOCAL cTmpRep
   LOCAL cFilePDF

   //DEFAULT oPrn TO dfRMPrinterObject()
//   DEFAULT oPrn TO dfWinPrinterObject()

   IF ! EMPTY(aArrFName)
      // copio il file .REP nella cartella contenente i dbf temporanei
      aTmpDbf := dfFnameSplit(aArrFName[1])
      aRpt := dfFNameSplit( oRMPrint:cRepName )
      cTmpRep := aTmpDbf[1]+aTmpDbf[2]+aRpt[3]+aRpt[4]

      // Simone 28/1/2005
      // Mantis 0000512: se nell'applicazione generata la dll di gestione Report Manager non esiste si ha errore di runtime in stampa
      // Mantis 0000513: se l'applicazione generata non trova il file di layout report si ha un errore di runtime in stampa
      IF ! oRMPrint:isLoaded()
         //dbMsgErr("Report Manager print engine (reportman.ocx) non trovato//Impossibile stampare.")
         dbMsgErr(dfStdMsg1(MSG1_DFREPTYP01))
      ELSEIF ! FILE(oRMPrint:cRepName)
         //"Report File non trovato//"+::oPrint:cRepName)
         dbMsgErr(dfMsgTran(dfStdMsg1(MSG1_DFREPTYP02), "file=" + oRMPrint:cRepName))
      ELSE
         // simone 8/3/2005 la finestra di anteprima
         // non visualizza il titolo del report
         IF dfFileCopy(oRMPrint:cRepName, cTmpRep)

            //Mantis 1247
            //Inserito per permettere di eseguire una funzione prima della Stampa o preview
            EVAL(oRT:bDecodePrePrint, cTmpRep, self)

            nErr := oRMPrint:exportTo(cTmpRep, xExportData, ;
                                      oRT:setFormula())

            lRet := nErr == 0

            IF lRet
/*
               cFilePDF := xExportData[2]
               // Provo a visualizzare con acrobat, se non è installato
               // vado su visualizzazione standard
               IF dfPDFView(cFilePDF)
                  // Mi assicuro che alla fine il file temporaneo venga cancellato
               ELSE
                  FERASE(cFilePDF)
               ENDIF
               dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cFilePDF) )
*/
            ELSE
               IF nErr == -1
                  //dbMsgErr(dfStdMsg1(MSG1_S2PDISCF02)+oRMOut:cRPT)
                  dbMsgErr(dfStdMsg1(MSG1_S2PDISCF02)+oRMPrint:cRepName)
      //         ELSEIF "CANCEL" $ UPPER(oRMPrint:cErrMsg) .AND. ;
      //                "USER" $ UPPER(oRMPrint:cErrMsg)
                  // codice di errore USER CANCELLED (ha premuto ESC)
                  // non do errore! per il controllo non uso oRM:nErrCode
                  // perche pu• cambiare!!
               ELSE
                  //dbMsgErr(dfStdMsg1(MSG1_S2PDISCF05)+oRMOut:cRPT+"//"+;
                  dbMsgErr(dfStdMsg1(MSG1_S2PDISCF05)+oRMPrint:cRepName+"//"+;
                           ALLTRIM(STR(oRMPrint:nErrCode))+"-"+STRTRAN(oRMPrint:cErrMsg, _LF, "//"))
               ENDIF
            ENDIF
            FERASE(cTmpRep)
            dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cTmpRep) )

         ELSE
            dbMsgErr(dfMsgTran(dfStdMsg1(MSG1_DFREPTYP02), "file=" + cTmpRep))
         ENDIF
      ENDIF
   ENDIF

   IF dfSet("XbaseRepManTempFileErase") == "NO"

   ELSE
      oRMOut:FErase()
   ENDIF
RETURN lRet

METHOD S2PrintDispRMSmtpMail:sendMail(cFileOut)
   LOCAL oMail
   LOCAL lRet := .F.
//   LOCAL cFile       := ALLTRIM(::aBuffer[REP_FNAME])
//   LOCAL aFName      := dfFNameSplit(cFile)
//   LOCAL cFileTxt    := aFName[1]+aFName[2]+aFName[3]+".Txt"
//   LOCAL cFilePdf    := NIL//aFName[1]+aFName[2]+aFName[3]+".Pdf"
//   LOCAL cTitle      := ::aBuffer[REP_NAME]
   //LOCAL aExtra      := NIL// Non viene utilizzato ::aBuffer[REP_XBASEPRINTEXTRA]
//   LOCAL aExtra      := ::aBuffer[REP_XBASEPRINTEXTRA]
   LOCAL nOptions    := 1  //3
//   LOCAL cTipoFormatoPagina
//   LOCAL cVerso
//   LOCAL bEnd        := {|cFilePdf,lOk| ::End_Execute(cFilePdf,lOk,cFileTxt,cFile,oMail,nOptions) }

   // Ricostruisco il nome del file con il percorso completo
   // in base al percorso corrente altrimenti posso avere
   // dei problemi con il send()
//   cFileTxt := dfFNameBuild(UPPER(cFileTxt))
//   cFile    := dfFNameBuild(UPPER(cFile))

   IF ::lAuto .AND. ::bAuto != NIL
      ::cMailTo := EVAL(::bAuto)
   ENDIF

   IF ! EMPTY(::cMailTo)

      IF nOptions <=1
         dbMsgOn(dfStdMsg1(MSG1_S2PDISMM04)+::cMailTo)
      ENDIF

      oMail:= S2Mail():new()

      oMail:cServer  := ::cServer
      //oMail:cFROM    := ::cFrom
      oMail:cSubject := ::cOggetto
      oMail:cBody    := ::cBody
      //////////////////////////////////
      //Luca  17/04/2015
      //oMail:cReplyTo := oMail:cFrom
      oMail:cReplyTo := ::cReplyTo 
      IF !EMPTY(::cFrom)
         oMail:cFROM    := ::cFrom
      ELSE
         oMail:cFROM    := ""
      ENDIF 
      IF EMPTY(oMail:cReplyTo)
         oMail:cReplyTo := oMail:cFrom
      ENDIF
      //////////////////////////////////
      oMail:cUser    := ::cUser
      oMail:cPassword:= ::cPassword
      oMail:nLoginMethod:=::nLoginMethod

      AEVAL(S2EmailAddressNormalize(::cMailTo), {|cTo| oMail:addTo( cTO ) })

      // Rinomino in file con estensione .TXT
//      IF !cFile == cFileTxt
//         FERASE(cFileTxt)
//         FRENAME(cFile, cFileTxt)
//      ENDIF

      // Simone 05/set/03 gerr 3926
      IF ::lZip
         cFileOut := ::zipFile(cFileOut)
      ENDIF
      oMail:addAttach( cFileOut )
      oMail:send()
      ::nError    := oMail:nError
      ::cErrorMsg := oMail:cMsg
//      FERASE(cFile)
//      FERASE(cFileTxt)
      lRet := .T.

      IF ::lZip
         FERASE(cFileOut)
      ENDIF
      
      IF nOptions <=1
         dbMsgOff()
      ENDIF

   ELSE
      dfAlert(dfStdMsg1(MSG1_S2PDISMM07)+ALLTRIM(STR(FERROR())))
      lRet := .F.
   ENDIF

RETURN lret

