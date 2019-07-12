//*****************************************************************************
//Progetto       : dBsee for Xbase++
//Descrizione    : Classi per stampe
//Programmatore  : Simone Degl'Innocenti
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
#INCLUDE "dfCTRL.ch"   // Maschere di Data Entry
#INCLUDE "dfSet.ch"    // Settaggi d'ambiente
#INCLUDE "dfMsg.ch"    // Messaggistica
#INCLUDE "dfMsg1.ch"   // Messaggistica
#INCLUDE "dfStd.ch"    // Standard
#INCLUDE "dfWinRep.ch" // report windows

FUNCTION dfReportTypeDefault(oNew, cType)
   STATIC aRT := {}
   LOCAL oRT
   LOCAL oRet
   LOCAL n

   DEFAULT cType TO REP_XBASE_RT_DBSEE

   n := ASCAN(aRT, {|x| x[1] == cType})

   IF VALTYPE(oNew) == "O" .AND. oNew:isDerivedFrom("dfReportType")
      // imposta l'oggetto come oggetto di classe anche se passo una istanza
      // cioä questa funzione va chiamata con 
      //   o:= dfReportTypeCRW()
      //   dfReportTypeDefault(o)
      //
      // se la chiamo con 
      //   o:= dfReportTypeCRW():new()
      //   dfReportTypeDefault(o)
      // va bene uguale ma il valore ritornato successivamente 
      // dalla dfReportTypeDefault() sarÖ l'oggetto classe dfReportTypeCRW()
      oRT := oNew:classObject()

      IF n == 0
         AADD(aRT, {cType, oRT})
         n := LEN(aRT)
      ELSE
         aRT[n][2] := oRT
   ENDIF
   ENDIF


   IF n != 0
      oRet := aRT[n][2]
   ENDIF

//   IF oRT != NIL // crea una nuova istanza!
//      oRet := oRT:new()
//   ENDIF
RETURN oRet

// Inizializza elementi di aBuffer per stampa con Crystal Report
//cDbf     --> Nome file dbf Crystal da Creare
//cAlias   --> Alias file dbf Crystal da Creare
//cDbfName --> Alias file dbf di Origine della Banda di Report
FUNCTION dfCRWReportSet(aBuffer, cRpt, cDBF, cAlias, cRDD)
   LOCAL oRT := dfReportTypeDefault(NIL, REP_XBASE_RT_CRW)
   DEFAULT oRT TO dfReportTypeCRW()
   aBuffer[ REP_XBASEREPORTTYPE  ]  := oRT:new(cRpt, cDBF, cAlias, cRDD)
//   aBuffer[ REP_XBASEUSERPRNDISP ]  := { S2PrintDispCRWPrinter():new(), ; 
//                                         S2PrintDispCRWExport():new()   }
RETURN NIL

// Inizializza elementi di aBuffer per stampa con Report Manager
//cDbf     --> Nome file dbf Crystal da Creare
//cAlias   --> Alias file dbf Crystal da Creare
//cDbfName --> Alias file dbf di Origine della Banda di Report
FUNCTION dfRepManReportSet(aBuffer, cRpt, cDBF, cAlias, cRDD)
   LOCAL oRT := dfReportTypeDefault(NIL, REP_XBASE_RT_REPORTMANAGER)
   DEFAULT oRT TO dfReportTypeRepMan()
   aBuffer[ REP_XBASEREPORTTYPE  ]  := oRT:new(cRpt, cDBF, cAlias, cRDD)
RETURN NIL

// Definizione della classe generica di stampa report
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CLASS dfReportType
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   EXPORTED:
      DEFERRED CLASS METHOD reportType
      DEFERRED CLASS METHOD getDefaultDisp()
      DEFERRED CLASS METHOD getPreviewDisp(oParent)

      DEFERRED METHOD printMenu
      DEFERRED METHOD printStart
      INLINE METHOD printCfg(); RETURN dfPrnCfg()
ENDCLASS

// Classe di stampa report standard dBsee
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CLASS dfReportTypeStandard FROM dfReportType
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   EXPORTED:
      INLINE CLASS METHOD reportType; RETURN REP_XBASE_RT_DBSEE

      INLINE CLASS METHOD getDefaultDisp()
      RETURN dfXPrnMenuDispDef()

      INLINE CLASS METHOD getPreviewDisp(oParent)
      RETURN NIL

      INLINE METHOD printMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
      RETURN dfRepDbseeMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )

      INLINE METHOD printStart(aVRec, nMode, bOut)
      RETURN dfRepDbseeStart( aVRec, @nMode, bOut )

ENDCLASS

STATIC CLASS FixReportType FROM dfReportType
PROTECTED:
   // Simone 26/8/04 gerr 4226
   // per risolvere il GERR faccio creare subito tutte
   // le tabelle temporanee necessarie.
   // Questo viene fatto solo se c'ä piu di 1 tabella, 
   // (cioä in caso di testata/dettaglio relazionate), 
   // perche se c'ä solo un body ä inutile in quanto il 
   // problema non si presenta.
   INLINE METHOD fix4226(aVRec, nMode, oCrwOut)
      LOCAL aBody := {}

      // disabilita questo fix che potrebbe portare problemi
      IF dfSet("XbaseEnableFix4226") == "NO"
         RETURN self
      ENDIF
         
      // trova di quanti body ä costituito questo report
      ::findAllBody(aVRec, aBody)

      IF LEN(aBody) <= 1
         RETURN self
      ENDIF
      // solo se deve stampare piu di un body

      // stampa tutti i body, in pratica
      // riempie il buffer di ::oCRWOut 
      // con i dati del record corrente 
      // (non mi interessa che siano dati coerenti perche 
      // tanto poi li ZAPPO)
      AEVAL(aBody, {|bBody| EVAL(bBody)})

      // adesso crea effettivamente la struttura del DB temporaneo
      // facendo append dei dati nel buffer e poi ZAP
      oCRWOut:createDBStruct()
   RETURN self

   // torna elenco dei body da stampare
   INLINE METHOD FindAllBody(aVRec, aBody)
      LOCAL n, VRloc
      LOCAL bBody

      FOR n := 1 TO LEN(aVrec)
         VRLoc := aVRec[n]
         bBody  := VRLoc[VR_BODY]
         IF ! EMPTY(bBody)
            AADD(aBody, bBody)
         ENDIF

         IF ! EMPTY(VRLoc[VR_CHILD]) 
            ::FindAllBody(VRLoc[VR_CHILD], aBody)
         ENDIF   
      NEXT
   RETURN self
ENDCLASS

// Classe di stampa report Crystal Report
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CLASS dfReportTypeCRW FROM FixReportType 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   PROTECTED:
      VAR oCRWOut
      VAR oCRWPrint
      VAR xFlag
      VAR cFormula

   EXPORTED:
      INLINE METHOD init(cRpt, cDBF, cAlias, cRDD, cDbfName)
          // Spostato dalla Classe dfCrwOut a qui.
          DEFAULT cRpt TO dfCRWPath()+M->ENVID+".RPT"

          ::oCRWOut   := dfCRWInit( cDBF, cAlias, cRDD)
          ::oCRWPrint := dfCrystalReport():new(cRpt)
          ::xFlag     := NIL
          ::cFormula  := NIL
          //::oPrinter  := S2Printer():new()
          //::cPrinter  := NIL
          //::nCopies   := 1
      RETURN self

      INLINE CLASS METHOD reportType; RETURN REP_XBASE_RT_CRW

      INLINE CLASS METHOD getDefaultDisp()
      RETURN dfXPrnMenuCRWDispDef()

      INLINE CLASS METHOD getPreviewDisp(oParent)
      RETURN S2PrintDispCRWPreview():new(oParent)

      INLINE METHOD printMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
         // Forzo il menu di stampa nuovo anche se non ho impostato
         // il flag AI_XBASEPRNMENUNEW
      RETURN _dfXPrnMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )

      INLINE METHOD printStart(aVRec, nMode)
         //Modifica Luca 26/03/2008
         LOCAL xRet
         //////////////////////////////////////////////////////////////////////

         // Forzo la routine di stampa nuova anche se non ho impostato
         // il flag AI_XBASEPRNMENUNEW

         // Simone 26/8/04 gerr 4226
         ::fix4226(aVRec, nMode, ::oCrwOut)
      //Mantis 679
      //RETURN dfRepDbseeStart( aVRec, @nMode, {|aBuf| _dfXPrnOut( aBuf ) } )
        xRet := dfRepDbseeStart( aVRec, @nMode, {|aBuf,lExecute | _dfXPrnOut( aBuf,lExecute) } )
      RETURN xRet

      //INLINE METHOD getOutput(cDbfName) ; RETURN ::oCRWOut:GetCRWObj(cDBFName)
      INLINE METHOD getOutput() ; RETURN ::oCRWOut
      INLINE METHOD getPrint()  ; RETURN ::oCRWPrint

      INLINE METHOD setOutput(o) ; ::oCRWOut := o    ; RETURN ::oCRWOut
      INLINE METHOD setPrint(o)  ; ::oCRWPrint := o; ; RETURN ::oCRWPrint

      INLINE METHOD setFlag(x, lSet)
         LOCAL xRet := ::xFlag
         IF x != NIL .OR. lSet != NIL
            ::xFlag := x
         ENDIF
      RETURN xRet

      INLINE METHOD setFormula(x, lSet)
         LOCAL xRet := ::cFormula
         IF x != NIL .OR. lSet != NIL
            ::cFormula := x
         ENDIF
      RETURN xRet

ENDCLASS

// Classe di stampa report Report Manager
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
CLASS dfReportTypeRepMan FROM FixReportType 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   PROTECTED:
      VAR oCRWOut
      VAR oPrint
      VAR xFlag
      VAR cFormula

   EXPORTED:
      //Mantis 1247
      VAR bDecodePrePrint

      INLINE METHOD init(cRpt, cDBF, cAlias, cRDD, cDbfName)
          // Spostato dalla Classe dfCrwOut a qui.
          //DEFAULT cRpt TO dfCRWPath()+M->ENVID+".REP"
          DEFAULT cRpt TO dfReportManagerPath()+M->ENVID+".REP"
          //Mantis 650
          IIF(dfSet(AI_XBASEREPORTMANTMPFILE)==AI_REPORTMANAGER_TEMPFILE_XML,cRDD:= "XML", NIL)

          ::oCRWOut   := dfCRWInit( cDBF, cAlias, cRDD)
          ::oPrint := dfReportManager():new(cRpt)
          ::xFlag     := NIL
          ::cFormula  := NIL
          //Codeblock che viene eseguito proma di lancaire la stampa o anteprima
          ::bDecodePrePrint := {||.T.}
          //::oPrinter  := S2Printer():new()
          //::cPrinter  := NIL
          //::nCopies   := 1
      RETURN self

      INLINE CLASS METHOD reportType; RETURN REP_XBASE_RT_REPORTMANAGER

      INLINE CLASS METHOD getDefaultDisp()
      RETURN dfXPrnMenuRMDispDef()

      INLINE CLASS METHOD getPreviewDisp(oParent)
      RETURN S2PrintDispRMPreview():new(oParent)

      INLINE METHOD printMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
         LOCAL cDMM
         LOCAL lRet
         // Forzo il menu di stampa nuovo anche se non ho impostato
         // il flag AI_XBASEPRNMENUNEW
         IF dfReportManager():canPrint() .OR. dfReportManager():canExport()
            // apre menu di stampa
         ELSE
            // anteprima automatica (come prima)
            nUserMenu := PM_NUL
            cIdPort   := "VIDEO"
         ENDIF
         lRet := _dfXPrnMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
      RETURN lRet

/*
      INLINE METHOD printMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
         LOCAL cDMM
         aBuf[REP_FHANDLE] := dfFileTemp( @cDmm )  // Report Handle
         aBuf[REP_FNAME]   := cDmm
         ///////////////////////////////////////////////////////////
         //Mantis 627
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
         ///////////////////////////////////////////////////////////

         FCLOSE( aBuf[REP_FHANDLE] )

         FCLOSE( FCREATE( aBuf[REP_FNAME] ) )
      RETURN .T.
*/
      INLINE METHOD printStart(aVRec, nMode)
         LOCAL xRet
         // Simone 15/03/05 
         // mantis  0000617: report 1:n con relazione IGNORE puï dare un messaggio di errore nell'applicazione generata
         // vedi gerr 4226
         ::fix4226(aVRec, nMode, ::oCrwOut)
      //Mantis 679
      //RETURN dfRepDbseeStart( aVRec, @nMode, {|aBuf | ::_out( aBuf  ) } )
      //RETURN dfRepDbseeStart( aVRec, @nMode, {|aBuf,lExecute | ::_out( aBuf,lExecute  ) } )
      RETURN dfRepDbseeStart( aVRec, @nMode, {|aBuf,lExecute | _dfXPrnOut( aBuf,lExecute) } )

/*
      //Mantis 679
      //INLINE METHOD _out(aBuf )
      INLINE METHOD _out(aBuf,lExecute )
         LOCAL aArrFName := ::oCRWOut:getFName()
         LOCAL aTmpDbf
         LOCAL aRpt
         LOCAL cTmpRep
         LOCAL lRet := .F.
         //Mantis 679
         DEFAULT lExecute TO .T.
         FERASE( aBuf[REP_FNAME] )

         // Chiudo il file DBF contenente i dati
         ::oCRWOut:close()


         //Mantis 679
         //IF ! EMPTY(aArrFName)
         IF ! EMPTY(aArrFName) .AND. lExecute
            // copio il file .REP nella cartella contenente i dbf temporanei
            aTmpDbf := dfFnameSplit(aArrFName[1])
            aRpt := dfFNameSplit( ::oPrint:cRepName )
            cTmpRep := aTmpDbf[1]+aTmpDbf[2]+aRpt[3]+aRpt[4]

            // Simone 28/1/2005
            // Mantis 0000512: se nell'applicazione generata la dll di gestione Report Manager non esiste si ha errore di runtime in stampa
            // Mantis 0000513: se l'applicazione generata non trova il file di layout report si ha un errore di runtime in stampa
            IF ! ::getPrint():isLoaded()
               //dbMsgErr("Report Manager print engine (reportman.ocx) non trovato//Impossibile stampare.") 
               dbMsgErr(dfStdMsg1(MSG1_DFREPTYP01)) 
            ELSEIF ! FILE(::oPrint:cRepName)
               //"Report File non trovato//"+::oPrint:cRepName) 
               dbMsgErr(dfMsgTran(dfStdMsg1(MSG1_DFREPTYP02), "file=" + ::oPrint:cRepName)) 
            ELSE 
               // simone 8/3/2005 la finestra di anteprima 
               // non visualizza il titolo del report
               IF dfFileCopy(::oPrint:cRepName, cTmpRep)

                  //Mantis 1247
                  //Inserito per permettere di eseguire una funzione prima della Stampa o preview
                  EVAL(::bDecodeprePrint, cTmpRep, self)

                  ::getPrint():preview(cTmpRep, aBuf[REP_NAME])
                  FERASE(cTmpRep)
               ELSE
                  dbMsgErr(dfMsgTran(dfStdMsg1(MSG1_DFREPTYP02), "file=" + cTmpRep)) 
               ENDIF
               lRet := .T.
            ENDIF
         ENDIF
         IF dfSet("XbaseRepManTempFileErase") == "NO"

         ELSE
            ::oCRWOut:FErase() 
         ENDIF
      RETURN lRet
*/
      //INLINE METHOD getOutput(cDbfName) ; RETURN ::oCRWOut:GetCRWObj(cDBFName)
      INLINE METHOD getOutput() ; RETURN ::oCRWOut
      INLINE METHOD getPrint()  ; RETURN ::oPrint

      INLINE METHOD setOutput(o) ; ::oCRWOut := o ; RETURN ::oCRWOut
      INLINE METHOD setPrint(o)  ; ::oPrint := o; ; RETURN ::oPrint

      INLINE METHOD setFlag(x, lSet)
         LOCAL xRet := ::xFlag
         IF x != NIL .OR. lSet != NIL
            ::xFlag := x
         ENDIF
      RETURN xRet

      INLINE METHOD setFormula(x, lSet)
         LOCAL xRet := ::cFormula
         IF x != NIL .OR. lSet != NIL
            ::cFormula := x
         ENDIF
      RETURN xRet

ENDCLASS
