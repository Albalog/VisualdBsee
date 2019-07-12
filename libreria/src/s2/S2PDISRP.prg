#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
// #include "Appevent.ch"
// #include "Font.ch"
#include "dfReport.ch"
#include "dfXbase.ch"
#include "dfMsg1.ch"

#define _LF (CHR(10))

// simone 18/2/08
// 0000652: i report di tipo reportmanager non hanno menu di stampa
// Dispositivo di stampa
// Stampante Windows

CLASS S2PrintDispRMPrinter FROM S2PrintDispWinPrinter
EXPORTED:
   METHOD create
   METHOD execute
   METHOD close

   // disattivo metodo per impostare i font
   INLINE METHOD imposta(); return self
ENDCLASS

METHOD S2PrintDispRMPrinter:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2PrintDispWinPrinter:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::btnSet:hide()
RETURN self


METHOD S2PrintDispRMPrinter:execute()
   LOCAL lRet      := .T.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oRMOut   := oRT:getOutput()
   LOCAL oRMPrint := oRT:getPrint()
   LOCAL aArrFName := oRMOut:getFName()
   LOCAL cArrFName := dfArr2Str(aArrFName, ", ")
   LOCAL nErr
   LOCAL nI
   LOCAL aTmpDbf
   LOCAL aRpt
   LOCAL cTmpRep
   LOCAL aOpt

   // Cancello il file TESTO temporaneo
   FERASE( ::aBuffer[REP_FNAME] )

   // Chiudo il file DBF contenente i dati
   oRMOut:close()

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

            // stampa da pag. a pag.
            IF ::aBuffer[REP_ALLPAGE]
               aOpt := NIL
            ELSE
               aOpt := {::aBuffer[REP_FROMPAGE], ::aBuffer[REP_TOPAGE]}
            ENDIF
            //? da testare 
            //::oPrinter:setNumCopies(::aBuffer[REP_COPY])
            //
            nErr := oRMPrint:print(cTmpRep, ::aBuffer[REP_NAME], ;
                                   ::aBuffer[REP_COPY], ;
                                   oRT:setFormula(), ::oPrinter, aOpt)

            lRet := nErr == 0

            IF ! lRet
               IF nErr == -1
                  //dbMsgErr(dfStdMsg1(MSG1_S2PDISCP02)+oRMOut:cRPT)
                  dbMsgErr(dfStdMsg1(MSG1_S2PDISCP02)+oRMPrint:cRepName)
               ELSE
                  //dbMsgErr(dfStdMsg1(MSG1_S2PDISCP05)+oRMOut:cRPT+"//"+;
                  dbMsgErr(dfStdMsg1(MSG1_S2PDISCP05)+oRMPrint:cRepName+"//"+;
                           ALLTRIM(STR(oRMPrint:nErrCode))+"-"+STRTRAN(oRMPrint:cErrMsg, _LF, "//") )
               ENDIF
      //      ELSEIF dfRMDesign()
      //         dfAlert(dfStdMsg1(MSG1_S2PDISCV03)+cArrFName)
            ENDIF
            FERASE(cTmpRep)
         ELSE
            dbMsgErr(dfMsgTran(dfStdMsg1(MSG1_DFREPTYP02), "file=" + cTmpRep))
         ENDIF
         lRet := .T.
      ENDIF

   ENDIF
   // Se sono in modalitÖ di DESIGN non cancello il file
   // DBF cosi posso costruirci sopra il REPORT con crystal

   //Gerr. 3438 30/10/03 Luca: Aggiunta la possibilitÖ di non cancellare il file
   // dbf temporaneo creato.
//   IF ! dfRMDesign()
      // Cancello il file DBF contenente i dati
      //FERASE(oRMOut:cFName)
   IF dfSet("XbaseRepManTempFileErase") == "NO"

   ELSE
      oRMOut:FErase()
   ENDIF
//   ENDIF

/*
   DO WHILE ::aBuffer[REP_COPY]-->0 .AND. lRet
      lRet := dfFile2WPrn( ::aBuffer[REP_FNAME], ::aBuffer[REP_NAME], ;
                             ::aBuffer[REP_XBASEPRINTOBJ], ;
                             ::aBuffer[REP_XBASEPRINTEXTRA], ;
                             IIF(::aBuffer[REP_COPY]>0, 2, 3) ) // Eseguo la cancellazione sull'ultima copia

      // 17:06:23 mercoledç 10 gennaio 2001
      // La scelta delle copie dovrebbe essere fatta a livello di
      // mashera dBsee, altrimenti crei doppioni
      //IF ::oPrinter:setNumCopies() != NIL
      //   EXIT
      //ENDIF
   ENDDO
*/
RETURN lRet

//Ger 4287 Luca 22/10/2004
// Inserito Per la chiusura delle dei file aperti quando non c'ä nulla da stampare
METHOD S2PrintDispRMPrinter:Close()
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