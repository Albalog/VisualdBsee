// Test per report manager usando reportman.ocx
// vedi: http://reportman.sf.net
// nota:
// - non funziona bene il setparamvalue con valore integer
//
// simone 23/3/04

#include "Common.ch"
#include "dll.ch"
#include "dfStd.ch"
#include "error.ch"
#include "xbpdev.ch"

// metodi di accesso a reportmanager
#define _RM_NONE  0 // ne dll ne activex disponibili
#define _RM_DLL   1 // dll disponibile
#define _RM_AX    2 // activex disponibile

#ifdef _TEST_

   /* Overloaded AppSys which does nothing
    */
   PROCEDURE xxxAppSys

      /* use the ANSI charset by default */
      SET CHARSET TO ANSI

      /* $TODO: create your application container here */
   RETURN

   PROCEDURE Main

      /*
      ** $TODO: create your application logic here
      */
   LOCAL paramname
   LOCAL rhan
   LOCAL avar
   LOCAL ares
   LOCAL paramcount

   paramname = "                                  "
    rhan = rp_open("sample.rep")
    ? ("open:"+Str(rhan))
    IF rhan == 0
      ? ("error:"+str( rp_lasterror()))

    ELSE
     Avar = "TESTING PARAM"
     ares = rp_setparamvalue(rhan, "PARAMETER1", 256, Avar) //string
     ? "param1",ares

     Avar = 24
     ares = rp_setparamvalue(rhan, "PARAMETER2", 3, @avar) //integer
     ? "param2",ares

     paramcount:=0
     ares = rp_getparamcount(rhan, @paramcount)
     ? ("pcoun:"+str(paramcount))

     ares = rp_getparamname(rhan, 0, @paramname)
     ?("pname0:"+paramname)

     IF ares = 0
      ? ("error:"+str(rp_lasterror()))
     ELSE
      ares = rp_preview(rhan, "Hello from Xbase++")
      ? "preview:",ares
     ENDIF
     rp_close (rhan)
    ENDIF
   wait
   RETURN
#endif


// simone 18/2/08
// 0000652: i report di tipo reportmanager non hanno menu di stampa
// con Xbase 1.82 uso solo la DLL e vado solo in anteprima
// con Xbase 1.90
// - report manager activex non installato uso solo la DLL e vado solo in anteprima
// - report manager activex installato ma Š una versione vecchia (sotto la 2.3)
//   che non supporta la propriet… "defaultPrinter" uso solo la DLL e vado solo in anteprima
// - repot manager activex installato e uso una versione recente (sopra la 2.3)
//   attivo il menu di stampa, esportazione ecc.

#if XPPVER < 01900000

#else

  // con la 1.90 uso activeX report manager
  #define REPORTMAN_PROGID "ReportMan.ReportManX"

#endif

// simone 8/3/2005 mantis 599
// inizializza per attivare esportazione EXCEL


#ifdef REPORTMAN_PROGID

  #PRAGMA LIBRARY( "ASCOM10.LIB" )
  #include "dfRepMan.ch"

#endif

#define NULL                      0
#define COINIT_MULTITHREADED      0x0
#define COINIT_APARTMENTTHREADED  0x2
#define COINIT_DISABLE_OLE1DDE    0x4
#define COINIT_SPEED_OVER_MEMORY  0x8

INIT PROCEDURE InitReportManager()
   DllCall("ole32.dll", DLL_STDCALL, "CoInitializeEx", NULL, COINIT_APARTMENTTHREADED)
RETURN

EXIT PROCEDURE ExitReportManager()
   DllCall("ole32.dll", DLL_STDCALL, "CoUninitialize")
RETURN


CLASS dfReportManager
   PROTECTED:
      METHOD setError

      METHOD createCopy
      METHOD destroyCopy
      VAR cCopyFName

      METHOD setRepProp

      CLASS VAR _rm_method // 0=niente/non attivo, 1=usa DLL, 2 = usa ACTIVEX
      CLASS VAR nDLL

#ifdef REPORTMAN_PROGID
      CLASS METHOD loadExportTypes
      CLASS VAR aExportTypes

#endif

   EXPORTED:
      VAR cRepName
      VAR nErrCode
      VAR cErrMsg
      VAR bOnPrint
      VAR bOnExport
      VAR bOnPreview

      CLASS METHOD initClass

#ifdef REPORTMAN_PROGID
      CLASS METHOD getAX()
      CLASS METHOD destroyAX()
#endif
      CLASS METHOD Check
      CLASS METHOD isLoaded

      METHOD setPreviewToFront

      METHOD init
      CLASS METHOD listExportTypes
      CLASS METHOD canPreview()
      CLASS METHOD canPrint()
      CLASS METHOD canExport()


      SYNC METHOD preview
      SYNC METHOD print
      SYNC METHOD exportTo
      SYNC METHOD design
ENDCLASS

CLASS METHOD dfReportManager:initClass()
#ifdef REPORTMAN_PROGID
   LOCAL oAX

   oAX := ::getAX()

   // simone 20/2/08
   // se l'activeX è vecchio e non supporta la proprietà
   // "defaultPrinter", accedo tramite DLL (metodo vecchio)
   // perchè non posso impostare la stampante da utilizzare
   // e quindi non posso andare in stampa diretta
   IF ! EMPTY(oAX) .AND. oAX:getidsofnames("defaultPrinter") != NIL
      ::aExportTypes := ::loadExportTypes(oAX)
      ::_rm_method := _RM_AX  // ACTIVEX
   ELSE
      ::aExportTypes := {}
      ::_rm_method := _RM_DLL // DLL
   ENDIF
   ::destroyAX(oAX)

#else
   ::_rm_method := _RM_DLL
#endif

   ::nDll := 0
   IF ::_rm_method == _RM_DLL // usa dll?
      ::nDll := dfDllLoad("reportMan.ocx")
      IF ::nDll == 0
         ::_rm_method := _RM_NONE
      ENDIF
   ENDIF
RETURN self

#ifdef REPORTMAN_PROGID

CLASS METHOD dfReportManager:loadExportTypes(oAX)
   LOCAL aRet := {}

   IF EMPTY(oAX)
      RETURN aRet
   ENDIF

   IF oAX:getidsofnames("saveToPDF") != NIL  // esiste il metodo?
      AADD(aRet, {"PDF"                          , ".pdf", RM_EXPORT_PDF})
   ENDIF
   IF oAX:getidsofnames("saveToText") != NIL    // esiste il metodo?
      AADD(aRet, {"Text"                         , ".txt", RM_EXPORT_TEXT})
   ENDIF
   IF oAX:getidsofnames("saveToExcel") != NIL   // esiste il metodo?
      AADD(aRet, {"Excel"                        , ".xls", RM_EXPORT_EXCEL})
   ENDIF
   IF oAX:getidsofnames("saveToExcel2") != NIL  // esiste il metodo?
      AADD(aRet, {"Excel one sheet"              , ".xls", RM_EXPORT_EXCEL2})
   ENDIF
   IF oAX:getidsofnames("saveToHTML") != NIL    // esiste il metodo?
      AADD(aRet, {"HTML"                         , ".htm", RM_EXPORT_HTML})
   ENDIF
   IF oAX:getidsofnames("saveToCSV") != NIL     // esiste il metodo?
      AADD(aRet, {"Comma Separated Format (CSV)" , ".csv", RM_EXPORT_CSV})
   ENDIF
   IF oAX:getidsofnames("saveToCSV2") != NIL    // esiste il metodo?
      AADD(aRet, {"Comma Separated Format 2 (CSV)",".csv", RM_EXPORT_CSV2})
   ENDIF
   IF oAX:getidsofnames("saveToSVG") != NIL     // esiste il metodo?
      AADD(aRet, {"Scalable Vector Graphics (SVG)",".svg", RM_EXPORT_SVG})
   ENDIF
   IF oAX:getidsofnames("saveToMetafile") != NIL // esiste il metodo?
      AADD(aRet, {"Metafile"                     , ".rpmf", RM_EXPORT_METAFILE})
   ENDIF
   IF oAX:getidsofnames("saveToCustomText") != NIL // esiste il metodo?
      AADD(aRet, {"Custom text"                  , ".txt", RM_EXPORT_CUSTOMTEXT})
   ENDIF
RETURN aRet


CLASS METHOD dfReportManager:getAX()
RETURN dfGetAx(REPORTMAN_PROGID, .F.)
//RETURN dfGetAx(REPORTMAN_PROGID, .T.)

CLASS METHOD dfReportManager:destroyAX(oAX)
   IF ! EMPTY(oAX)
      oAX:destroy()
   ENDIF
RETURN self
#endif

CLASS METHOD dfReportManager:canPreview()
RETURN .T.

CLASS METHOD dfReportManager:canPrint()
RETURN ::_rm_method == _RM_AX

CLASS METHOD dfReportManager:canExport()
RETURN ::_rm_method == _RM_AX

METHOD dfReportManager:init(cRepName)
   //DEFAULT cRepName TO dfCRWPath()+M->ENVID+".REP"
   DEFAULT cRepName TO dfReportManagerPath()+M->ENVID+".REP"
   ::nErrCode := 0     
   ::cErrMsg  := ""
   ::cRepName := cRepName

   // Simone 28/01/2005
   // mantis 0000509: In stampa Report Manager da una macchina dove non Š installato report manager si ha sempre un errore a causa 
   ::check()
RETURN self

CLASS METHOD dfReportManager:listExportTypes()
#ifdef REPORTMAN_PROGID
RETURN ACLONE(::aExportTypes)
#else
RETURN {}
#endif

METHOD dfReportManager:setError(nJob)
   ::nErrCode := 0
   ::cErrMsg  := ""
   IF nJob != NIL
#ifdef REPORTMAN_PROGID
      IF VALTYPE(nJob)=="O"
         ::nErrCode  := nJob:osCode
         ::cErrMsg   := VDBErrorMessage(nJob, NIL, .T., .T.)
      ELSE
         ::nErrCode := rp_lasterror()
      ENDIF
#else
      ::nErrCode := rp_lasterror()
#endif
   ENDIF
RETURN self

// cRepName = file .rep
// cRepTitle = Titolo finestra
// cRepFormula = formula di filtro crystal report
// oFlag = Flag di anteprima (oggetto di classe XbpCRWPrinterO)
// oRMPrinter = stampante da usare (oggetto di classe S2RMPrinter() va usato esattamente come XbpPrinter() )
// aOpt = array opzioni vedi PeSetPrintOptions
METHOD dfReportManager:preview(cRepName, cRepTitle, cRepFormula, ;
                               xFlag, oRMPrinter, aOpt)

   LOCAL nRet
   LOCAL oDlg
   LOCAL cDir
   LOCAL oParent 
   LOCAL nJob
   LOCAL aFName
   LOCAL oThread
   LOCAL oFocus := SetAppFocus()
   LOCAL oForm := S2FormCurr()
   LOCAL oAX, oErr, e

   DEFAULT cRepName TO ::cRepName
   DEFAULT cRepTitle TO ""

   IF EMPTY(cRepName); RETURN -1; ENDIF

   IF ! FILE(cRepName); RETURN -1; ENDIF

   oParent := S2FormCurr()

   // Azzero errori
   ::setError()

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Salvo path e Directory corrente
   cDir   := dfPathGet() 

   dfPushAct()

   // Simone 15/03/2005
   // Mantis 0000618: nell'app. generata lanciando reportmanager non disabilita la form che lo chiama
   IF EMPTY(oForm) .OR. ! IsMemberVar(oForm, "drawingArea")
      oForm := NIL
   ENDIF
   IF oForm != NIL
      //oForm:disable() // questo da dei refresh brutti quando finisce il preview
      oForm:drawingArea:disable()
   ENDIF

#ifdef REPORTMAN_PROGID
   oAX := ::GetAX()
   IF ! EMPTY(oAX)
      oErr := ERRORBLOCK({|e| dfErrBreak(e)} )
   BEGIN SEQUENCE

         ::setRepProp(cRepName, .T.) // anteprima a tutto schermo

         IF ! EMPTY( ::cCopyFName ) // se ho creato una copia uso quella
            cRepName := ::cCopyFName
         ENDIF

         aFname := dfFNameSplit(cRepName)

         dfCD(aFname[1]+aFName[2])

         oAX:fileName := cRepName

         oAX:preview  := .T.
         oAX:showProgress:=.T.
         oAX:showPrintDialog := .T.

         IF VALTYPE(cRepTitle) $ "CM"
            oAX:title := cRepTitle
         ENDIF

         IF ! EMPTY(oRMPrinter) .AND. oAX:getidsofnames("defaultPrinter") != NIL
            oAX:defaultPrinter := oRMPrinter:devName
         ENDIF

         IF oAX:getidsofnames("AsyncExecution") != NIL
            oAX:AsyncExecution := .T.
         ENDIF

         // simone 8/3/2005 workaround mantis 570
         // crea un thread per portare
         // la finestra di preview in foreground
         oThread := Thread():new()
         oThread:cargo := .T.
         oThread:start( {|| ::SetPreviewToFront(oThread)} )

         oAX:execute()

         // disattiva il thread
         oThread:cargo := .F.
         DO WHILE oThread:active
            sleep(20)
         ENDDO
         oThread := NIL

      RECOVER USING e
         // C'Š stato un errore
         ::setError( nJob )
      END SEQUENCE
      ERRORBLOCK(oErr)

      ::destroyAX(oAX)
   ENDIF
#endif

   IF EMPTY(oAX)
   BEGIN SEQUENCE

         ::setRepProp(cRepName, .T.) // anteprima a tutto schermo

         IF ! EMPTY( ::cCopyFName ) // se ho creato una copia uso quella
            cRepName := ::cCopyFName
         ENDIF

      aFname := dfFNameSplit(cRepName)

      dfCD(aFname[1]+aFName[2])

      nJob = rp_open(cRepName)
      IF nJob == 0; BREAK ; ENDIF

      // simone 8/3/2005 workaround mantis 570
      // crea un thread per portare
      // la finestra di preview in foreground
      oThread := Thread():new()
      oThread:cargo := .T.
      oThread:start( {|| ::SetPreviewToFront(oThread)} )

      rp_preview(nJob, cRepTitle)

      // disattiva il thread
      oThread:cargo := .F.
      DO WHILE oThread:active
         sleep(20)
      ENDDO
      oThread := NIL

      rp_close(nJob)

   RECOVER
      // C'Š stato un errore
      ::setError( nJob )
   END SEQUENCE
   ENDIF

   // se ho creato una copia la cancello
   ::destroyCopy()

   // Simone 15/03/2005
   // Mantis 0000618: nell'app. generata lanciando reportmanager non disabilita la form che lo chiama
   IF oForm != NIL
      oForm:drawingArea:enable()
   ENDIF

//   IF oFocus != NIL
//      SetAppFocus(oFocus)
//   ENDIF

   dfPopAct()

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Ripristino path e Directory corrente
   dfPathSet( cDir )
RETURN nRet

// cRepName = file .rep
// nRepCopy  = numero di copie
// cRepFormula = formula di filtro crystal report
// oRMPrinter = stampante da usare (oggetto di classe S2CRWPrinter() va usato esattamente come XbpPrinter() )
// aOpt = array opzioni vedi PeSetPrintOptions
METHOD dfReportManager:print(cRepName, cRepTitle, nRepCopy, cRepFormula, ;
                             oRMPrinter, aOpt,nReportPrintMenu )
   LOCAL nJob        := 0
   LOCAL lResult     := .F. 
   LOCAL nCopy       := 0
   LOCAL lOpenEngine := .F.
   LOCAL lOpenJob    := .F.
   LOCAL nRet        := 0
   LOCAL cDir
   LOCAL aFName
   LOCAL oFocus := SetAppFocus()
   LOCAL oForm := S2FormCurr()
   LOCAL oAX, oErr, e

   DEFAULT nReportPrintMenu TO 1
   DEFAULT cRepName         TO ::cRepName

   DEFAULT nRepCopy    TO 1
   DEFAULT cRepFormula TO ""

   IF EMPTY(cRepName) ; RETURN -1; ENDIF
   IF ! FILE(cRepName); RETURN -1; ENDIF
   IF EMPTY(aOpt)
      aOpt := NIL
   ENDIF

   IF dfSet("XbaseDisableReportManagerPrintMenu") == "YES"
      nReportPrintMenu := 0
   ENDIF

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Salvo path e Directory corrente
   cDir   := dfPathGet()

   // Simone 15/03/2005
   // Mantis 0000618: nell'app. generata lanciando reportmanager non disabilita la form che lo chiama
   IF EMPTY(oForm) .OR. ! IsMemberVar(oForm, "drawingArea")
      oForm := NIL
   ENDIF
   IF oForm != NIL
      //oForm:disable() // questo da dei refresh brutti quando finisce il preview
      oForm:drawingArea:disable()
   ENDIF

   // Azzero errori
   ::setError()

#ifdef REPORTMAN_PROGID
   oAX := ::getAX()
   IF ! EMPTY(oAX)
      oErr := ERRORBLOCK({|e| dfErrBreak(e)} )
   BEGIN SEQUENCE

         IF ! EMPTY(oRMPrinter)
            nReportPrintMenu := 0
         ENDIF

         IF VALTYPE(aOpt)!="A"
            //Mantis 2178 
            // imposta numero copie, se passo aOpt non lo faccio
            //::setRepProp(cRepName, NIL, nRepCopy, )
            ::setRepProp(cRepName, NIL, nRepCopy, oRMPrinter)
         ENDIF

         IF ! EMPTY( ::cCopyFName ) // se ho creato una copia uso quella
            cRepName := ::cCopyFName
         ENDIF

         aFname := dfFNameSplit(cRepName)

         dfCD(aFname[1]+aFName[2])

         oAX:fileName := cRepName

         oAX:preview := .F.
         oAX:showProgress:=.T.
         oAX:showPrintDialog := (nReportPrintMenu != 0)
         IF VALTYPE(cRepTitle) $ "CM"
            oAX:title := cRepTitle
         ENDIF
         IF ! EMPTY(oRMPrinter) .AND. oAX:getidsofnames("defaultPrinter") != NIL
            oAX:defaultPrinter := oRMPrinter:devName
         ENDIF

         IF oAX:getidsofnames("AsyncExecution") != NIL
            oAX:AsyncExecution := .T.
         ENDIF

         IF VALTYPE(aOpt) == "A"
            aOpt := ACLONE(aOpt)
            ASIZE(aOpt, 4)

            DEFAULT aOpt[1] TO 1        // start page
            DEFAULT aOpt[2] TO 9999     // end page
            aOpt[3] := nRepCopy         // copies
            aOpt[4] := .F.              // collation
            IF ! EMPTY(oRMPrinter) .AND. oRMPrinter:setCollationMode() != NIL
               aOpt[4] := (oRMPrinter:setCollationMode() == XBPPRN_COLLATIONMODE_ON)
            ENDIF
            //Mantis 2178 
            //PrintRange(frompage:integer;topage:integer; copies:integer;collate:boolean):boolean;
            //oAX:PrintRange(aOpt[1], aOpt[2], aOpt[3], aOpt[4])
            FOR nCopy := 1 TO nRepCopy
                oAX:PrintRange(aOpt[1], aOpt[2], 1 , aOpt[4])
            NEXT
         ELSE
            FOR nCopy := 1 TO nRepCopy
                oAX:execute()
            NEXT
         ENDIF
      RECOVER USING e
         // C'Š stato un errore
         ::setError(e)

      END SEQUENCE
      ERRORBLOCK(oErr)

      ::destroyAX(oAX)
   ENDIF
#endif
   IF EMPTY(oAX)

   BEGIN SEQUENCE

         IF ! EMPTY(oRMPrinter)
            nReportPrintMenu := 0
         ENDIF

         // simone 19/2/08
         // imposta la stampante da usare (da perfezionare
         // perchŠ il file %appdata%\reportman.ini viene letto
         // all'avvio di report manager, quindi se cambio stampante
         // non la rilegge)
         ::setRepProp(cRepName, NIL, nRepCopy)
         //::setRepProp(cRepName, .F., oRMPrinter, nRepCopy)

         IF ! EMPTY( ::cCopyFName ) // se ho creato una copia uso quella
            cRepName := ::cCopyFName
         ENDIF

      aFname := dfFNameSplit(cRepName)

      dfCD(aFname[1]+aFName[2])

      nJob = rp_open(cRepName)
      IF nJob == 0; BREAK ; ENDIF

      rp_print(nJob, cRepName, 1, nReportPrintMenu)

      rp_close(nJob)

   RECOVER
      // C'Š stato un errore
      ::setError(nJob)

   END SEQUENCE
   ENDIF

   // se ho creato una copia la cancello
   ::destroyCopy()

   // Simone 15/03/2005
   // Mantis 0000618: nell'app. generata lanciando reportmanager non disabilita la form che lo chiama
   IF oForm != NIL
      oForm:drawingArea:enable()
   ENDIF

//   IF oFocus != NIL
//      SetAppFocus(oFocus)
//   ENDIF

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Ripristino path e Directory corrente
   dfPathSet( cDir )
RETURN ::nErrCode

// Funziona ma Š meglio gestire la struttura xExp con funzioni in C
METHOD dfReportManager:design(cRepName, xExp, cRepFormula, ;
                                aTabLocation, oRMPrinter, aOpt)
   LOCAL nJob        := 0
   LOCAL lResult     := .F. 
   LOCAL nCopy       := 0
   LOCAL lOpenEngine := .F.
   LOCAL lOpenJob    := .F.
   LOCAL nRet        := 0
   LOCAL cDir
   LOCAL oParent
   LOCAL hWnd
   LOCAL aFname
   LOCAL cExe
   LOCAL oFocus := SetAppFocus()
   LOCAL oForm := S2FormCurr()

   DEFAULT cRepName TO ::cRepName

   DEFAULT cRepFormula TO ""

   IF ! FILE(cRepName)
      RETURN -1
   ENDIF

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Salvo path e Directory corrente
   cDir   := dfPathGet()

   // Simone 15/03/2005
   // Mantis 0000618: nell'app. generata lanciando reportmanager non disabilita la form che lo chiama
   IF EMPTY(oForm) .OR. ! IsMemberVar(oForm, "drawingArea")
      oForm := NIL
   ENDIF
   IF oForm != NIL
      //oForm:disable() // questo da dei refresh brutti quando finisce il preview
      oForm:drawingArea:disable()
   ENDIF

   // Azzero errori
   ::setError()

   BEGIN SEQUENCE
     aFname := dfFNameSplit(cRepName)

     dfCD(aFname[1]+aFName[2])
     cExe := S2FindExecutable(aFname[3]+aFName[4],aFname[1]+aFName[2])
     RunShell('"'+cRepName+'"', cExe)
	
   RECOVER
      // C'Š stato un errore
      ::setError(nJob)

   END SEQUENCE

   // Simone 15/03/2005
   // Mantis 0000618: nell'app. generata lanciando reportmanager non disabilita la form che lo chiama
   IF oForm != NIL
      oForm:drawingArea:enable()
   ENDIF

//   IF oFocus != NIL
//      SetAppFocus(oFocus)
//   ENDIF

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Ripristino path e Directory corrente
   dfPathSet( cDir )

RETURN ::nErrCode

// cRepName = file .rep
// nRepCopy  = numero di copie
// cRepFormula = formula di filtro crystal report
// oRMPrinter = stampante da usare (oggetto di classe S2CRWPrinter() va usato esattamente come XbpPrinter() )
// aOpt = array opzioni vedi PeSetPrintOptions
METHOD dfReportManager:exportTo(cRepName, xExp, cRepFormula, ;
                                oRMPrinter, aOpt)
   LOCAL nJob        := 0
   LOCAL lResult     := .F. 
   LOCAL nCopy       := 0
   LOCAL lOpenEngine := .F.
   LOCAL lOpenJob    := .F.
   LOCAL nRet        := 0
   LOCAL cDir
   LOCAL oParent
   LOCAL hWnd
   LOCAL aFName
   LOCAL oFocus := SetAppFocus()
   LOCAL oForm := S2FormCurr()
   LOCAL oAX, oErr, e

   DEFAULT cRepName TO ::cRepName

   DEFAULT cRepFormula TO ""

   IF ! FILE(cRepName)
      RETURN -1
   ENDIF

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Salvo path e Directory corrente
   cDir   := dfPathGet()

   // Simone 15/03/2005
   // Mantis 0000618: nell'app. generata lanciando reportmanager non disabilita la form che lo chiama
   IF EMPTY(oForm) .OR. ! IsMemberVar(oForm, "drawingArea")
      oForm := NIL
   ENDIF
   IF oForm != NIL
      //oForm:disable() // questo da dei refresh brutti quando finisce il preview
      oForm:drawingArea:disable()
   ENDIF

   // Azzero errori
   ::setError()

#ifdef REPORTMAN_PROGID
   oAX := ::getAx()
   IF ! EMPTY(oAX) // usa ACTIVEX
      oErr := ERRORBLOCK({|e| dfErrBreak(e)} )
   BEGIN SEQUENCE
      aFname := dfFNameSplit(cRepName)

      dfCD(aFname[1]+aFName[2])

         oAX:fileName := cRepName

         IF ! EMPTY(oRMPrinter) .AND. oAX:getidsofnames("defaultPrinter") != NIL
            oAX:defaultPrinter := oRMPrinter:devName
         ENDIF

         IF VALTYPE(xExp) == "A"
            IF LEN(xExp) >= 2

   //procedure SaveToPDF(filename:string;compressed:boolean=false);
   //
   //Since version 1.6 there are this interfaces available
   //procedure SaveToText(const filename, textdriver: String);
   //procedure SaveToExcel(const filename: String); // Needs Excel installation
   //
   //Since version 2.0
   //procedure SaveToHTML(const filename: String);
   //
   //Since version 2.1
   //procedure SaveToCustomText(const filename: String);
   //procedure SaveToCSV(const filename: String);
   //procedure SaveToSVG(const filename: String);
   //
   //Since version 2.3
   //procedure SaveToMetafile(const filename: String);
   //procedure SaveExcel2(const filename: String); // Save to excel in only one sheet
   //
   //Since version 2.5
   //procedure SaveToCSV2(const filename,separator: String);

               // xExp[1]=tipo
               // xExp[2]=nome file
               // xExp[3]=parametri
               ASIZE(xExp, 3)

               DO CASE
                  CASE (VALTYPE(xExp[1]) != "N") .OR. ;
                       (ASCAN(::aExportTypes, {|x| x[DFRMET_ID]==xExp[1]} ) == 0)
                   dfErrorThrow("unsupported export type: "+ALLTRIM(dfAny2Str(xExp[1])), NIL, ;
                                "export", -100, XPP_ES_ERROR, "REPORTMANAGER")

                  CASE EMPTY(xExp[2])
                    dfErrorThrow("export file name not specified", NIL, ;
                                 "export", -101, XPP_ES_ERROR, "REPORTMANAGER")
               ENDCASE

               // path partendo da percorso exe
               xExp[2] := dfFNameBuild(xExp[2], cDir)

               DO CASE
                  CASE xExp[1] == RM_EXPORT_PDF
                    DEFAULT xExp[3] TO .T.
                    oAX:saveToPdf(xExp[2], xExp[3]) // xExp[3]=compresso bool

                  CASE xExp[1] == RM_EXPORT_TEXT
                    DEFAULT xExp[3] TO ""
                    oAX:saveToText(xExp[2], xExp[3]) // xExp[3]=driver string

                  CASE xExp[1] == RM_EXPORT_EXCEL
                    oAX:saveToExcel(xExp[2])

                  CASE xExp[1] == RM_EXPORT_EXCEL2
                    oAX:saveToExcel2(xExp[2])

                  CASE xExp[1] == RM_EXPORT_HTML
                    oAX:saveToHTML(xExp[2])

                  CASE xExp[1] == RM_EXPORT_CSV
                    oAX:saveToCSV(xExp[2])

                  CASE xExp[1] == RM_EXPORT_CSV2
                    DEFAULT xExp[3] TO ";"
                    oAX:saveToCSV2(xExp[2], xExp[3]) //xExp[3]=separator string

                  CASE xExp[1] == RM_EXPORT_SVG
                    oAX:saveToSVG(xExp[2])

                  CASE xExp[1] == RM_EXPORT_METAFILE
                    oAX:saveToMetafile(xExp[2])

                  CASE xExp[1] == RM_EXPORT_CUSTOMTEXT
                    oAX:saveToCustomText(xExp[2])

               OTHERWISE
                   dfErrorThrow("unsupported export type: "+ALLTRIM(dfAny2Str(xExp[1])), NIL, ;
                                "export", -100, XPP_ES_ERROR, "REPORTMANAGER")
               ENDCASE
            ENDIF
         ENDIF

         //rp_execute(nJob, cRepName, 1, 1)

      RECOVER USING e
         // C'Š stato un errore
         ::setError(e)

      END SEQUENCE
      ERRORBLOCK(oErr)

      ::destroyAX(oAX)
   ENDIF
#endif

   IF EMPTY(oAX) // usa DLL
      BEGIN SEQUENCE
      aFname := dfFNameSplit(cRepName)

      dfCD(aFname[1]+aFName[2])

         nJob = rp_open(cRepName)
         IF nJob == 0; BREAK ; ENDIF

      //rp_execute(nJob, cRepName, 1, 1)

      rp_close(nJob)

   RECOVER
      // C'Š stato un errore
      ::setError(nJob)

   END SEQUENCE
   ENDIF

   // Simone 15/03/2005
   // Mantis 0000618: nell'app. generata lanciando reportmanager non disabilita la form che lo chiama
   IF oForm != NIL
      oForm:drawingArea:enable()
   ENDIF

//   IF oFocus != NIL
//      SetAppFocus(oFocus)
//   ENDIF

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Ripristino path e Directory corrente
   dfPathSet( cDir )
RETURN ::nErrCode

// Simone 28/01/2005
// mantis 0000509: In stampa Report Manager da una macchina dove non Š installato report manager si ha sempre un errore a causa 
CLASS METHOD dfReportManager:check()
   LOCAL cPath
   LOCAL cText
   IF ::isLoaded()
      cPath := dfPathChk( dfExePath() )
      cText := "; Report Manager Configuration File"+ CRLF + ;
               ";"+CRLF+;
               "; DO NOT REMOVE - NON CANCELLARE"+CRLF+;
               ";"

      IF ! FILE(cPath+"dbxdrivers.ini")
         dfFileWrite(cPath+"dbxdrivers.ini", cText)
      ENDIF
 
     IF ! FILE(cPath+"dbxconnections.ini")
         dfFileWrite(cPath+"dbxconnections.ini", cText)
      ENDIF
   ENDIF
RETURN self

// simone 8/3/2005 workaround mantis 570
// porta la finestra di preview di reportmanager in foreground
METHOD dfReportManager:SetPreviewToFront(oThread)
   LOCAL hWnd := 0

   DO WHILE oThread:cargo
      // cerca una finestra di classe preview
      hWnd := S2PrevWindowFind( "TFRpVPreview" )
      IF hWnd != 0
         // se la trova la porta in foreground e termina il thread
         BringWindowToTop( hWnd )
         SetForegroundWindow( hWnd )
         EXIT
      ENDIF
      sleep(20)
   ENDDO
RETURN NIL

CLASS METHOD dfReportManager:isLoaded()
RETURN ::_rm_method != _RM_NONE // ! EMPTY( _reportManLoad( .T. ) )


// imposta alcune proprietà direttamente nel file .rep
METHOD dfReportManager:setRepProp(cRepName, lMaxPreview, nRepCopy, oRMPrinter)
   LOCAL aVars := {}
   LOCAL cRep
   LOCAL cAppDataPath

   DEFAULT lMaxPreview TO .F.

   IF nRepCopy == NIL .AND. ! EMPTY(oRMPrinter)
      nRepCopy := oRMPrinter:setNumCopies()
   ENDIF

   // leggo file .rep
   cRep := dfFileRead(cRepName)
   IF EMPTY(cRep)
      RETURN .F.
   ENDIF

   // imposto variabili nel file .rep
   IF lMaxPreview
      AADD(aVars, {"TRpReport.PreviewWindow", "spwMaximized"})
   ENDIF

   IF VALTYPE(nRepCopy)=="N" // numero copie
      //Mantis 2178  
      //Modificata routine per gestire il numero delle copie direttamente nella routine di Execute. 
      //Purtroppo per diverse stampanti non funziona ne inserire il numero delle pagine e ne passare il setNumCopies() alla stampante
      //AADD(aVars, {"TRpReport.Copies", ALLTRIM(STR(nRepCopy))})
      //IF !nRepCopy == NIL .AND. ! EMPTY(oRMPrinter)
      //   oRMPrinter:setNumCopies(nRepCopy)
      //ENDIF
   ENDIF

#ifdef REPORTMAN_PROGID
#else
   IF ! EMPTY(oRMPrinter)
       // scrivo file reportman.ini nella cartella
       // application data dell'utente indicando la stampante di default
       cAppDataPath := GETENV("APPDATA")
       IF ! EMPTY(oRMPrinter:devName) .AND. ! EMPTY(cAppDataPath)

          // scarico e ricarico il reportman.ocx per far rileggere il file .ini!
          //_reportManLoad( .F. )
          //_reportManLoad( .T. )

          cAppDataPath := dfPathChk(cAppDataPath)
          IF WritePrivateProfileStringA("PrinterNames", ;
                                        "Printer15", oRMPrinter:devName, ;
                                        cAppDataPath+"reportman.ini") <> 0
             AADD(aVars, {"TRpReport.PrinterSelect", "pRpUserPrinter9"})
          ENDIF


       ENDIF

//      IF ! EMPTY( oRMPrinter:setPaperBin() )
//         AADD(aVars, {"TRpReport.PaperSource", ALLTRIM(STR(oRMPrinter:setPaperBin()))})
//      ENDIF
//
//      AADD(aVars, {"TRpReport.PageOrientation", "rpOrientationPortrait"})
//      AADD(aVars, {"TRpReport.PageOrientation", "rpOrientationLandscape"})
   ENDIF
#endif

   IF EMPTY(aVars) // nessuna modifica da fare
      RETURN .T.
   ENDIF

   cRep := dfRepManSetVar(cRep, aVars)

   // Simone+Luca 16/12/09
   // devo creare il file nello stesso path del file originale
   // altrimenti non viene trova l'XML temporaneo
   IF ! ::createCopy(cRep, dfFNameSplit(cRepName, 1+2))
      RETURN .F.
   ENDIF


RETURN .T.

METHOD dfReportManager:createCopy(cRep, cFname)
   LOCAL n

   ::destroyCopy()

   //n := dfFileTemp( @cFname )  // Report Handle
   n := dfFileTemp( @cFname , NIL, NIL, ".rep")  // Report Handle
   IF n < 0             

      RETURN .F.
   ENDIF
   FWRITE(n, cRep)
   FCLOSE(n)

//
//   IF EMPTY(cFName) .OR. ! FILE(cFName)
//      RETURN .F.
//   ENDIF
//
//   IF ! dfFileCopy(cRepName, cFName)
//      FERASE(cFName)
//      RETURN .F.
//   ENDIF

   ::cCopyFName := cFname
RETURN .T.

METHOD dfReportManager:destroyCopy()
   IF ! EMPTY(::cCopyFName)
      FERASE(::cCopyFName)
   ENDIF
   ::cCopyFName := NIL
RETURN self


FUNCTION dfRMGetExportTypes()
RETURN dfReportManager():listExportTypes()

/*
STATIC FUNCTION _reportManLoad( lLoad )
#ifdef REPORTMAN_PROGID
   IF _AX_reportManLoad(lLoad) // prova con ACTIVEX
      RETURN .T.
   ENDIF
#endif
   IF _DLL_reportManLoad(lLoad) // se non riesce prova con DLL
      RETURN .T.
   ENDIF
RETURN .F.

#ifdef REPORTMAN_PROGID

STATIC FUNCTION _AX_reportManLoad( lLoad )
   STATIC lCanLoad
   LOCAL oAX

   IF lLoad .AND. lCanLoad == NIL
      oAX := dfReportManager():getAX()
      lCanLoad := ! EMPTY(oAX)
      dfReportManager():destroyAX(oAX)
   ELSEIF ! lLoad
      lCanLoad := NIL
   ENDIF
RETURN lCanLoad

//FUNCTION rp_open(); return 0
//FUNCTION rp_close(); return 0
//FUNCTION rp_execute(); return 0
//FUNCTION rp_lasterror(); return 0
//FUNCTION rp_preview(); return 0
//FUNCTION rp_print(); return 0
//FUNCTION rp_setparamvalue(); return 0
//FUNCTION rp_getparamcount(); return 0
//FUNCTION rp_getparamname(); return 0
//FUNCTION rp_setadoconnectionstring(); return 0

#endif


// carica dll reportman.ocx
STATIC FUNCTION _DLL_reportManLoad( lLoad )
   STATIC nDll

   IF lLoad .AND. nDll == NIL
      nDll := dfDllLoad("reportMan.ocx")

   ELSEIF ! lLoad .AND. nDll != NIL
      DLLUnload("reportMan.ocx")
      nDll := NIL
   ENDIF
RETURN nDll
*/

DLLFUNCTION rp_open(cFile) USING STDCALL FROM "reportman.ocx"
DLLFUNCTION rp_close(hReport) USING STDCALL FROM "reportman.ocx"
DLLFUNCTION rp_execute(hReport,cOut,nMetafile,ncompressed) USING STDCALL FROM "reportman.ocx"
DLLFUNCTION rp_lasterror() USING STDCALL FROM "reportman.ocx"
DLLFUNCTION rp_preview( hreport ,  title ) USING STDCALL FROM "reportman.ocx"
DLLFUNCTION rp_print( hreport ,  title ,  ShowProgress ,  ShowPrintDialog ) USING STDCALL FROM "reportman.ocx"
DLLFUNCTION rp_setparamvalue( hreport ,  paramname ,  paramtype ,  paramvalue ) USING STDCALL FROM "reportman.ocx"
DLLFUNCTION rp_getparamcount(hreport , @paramcount ) USING STDCALL FROM "reportman.ocx"
DLLFUNCTION rp_getparamname(hreport ,  index ,  @abuffer ) USING STDCALL FROM "reportman.ocx"
DLLFUNCTION rp_setadoconnectionstring(hreport , conname , constring ) USING STDCALL FROM "reportman.ocx"


/*
#command  DLLFUNCTION <Func>([<x,...>]) ;
                USING <sys:CDECL,OSAPI,STDCALL,SYSTEM> ;
                 FROM <(Dll)> ;
       => ;
             FUNCTION <FUNC>([<x>]);;
                LOCAL nDll:=DllLoad(<(Dll)>);;
                LOCAL xRet:=DllCall(nDll,__Sys(<sys>),<(FUNC)>[,<x>]);;
                      DllUnLoad(nDll);;
               RETURN xRet


int rp_open(char *filename);
int rp_execute(int hreport,char *outputfilename,int metafile,int compressed);


int rp_setparamvalue(int hreport,char *paramname,int paramtype,
 void *paramvalue);
   dove il paramtype pu• essere:
      1: Null;
      3: integer
      5: double
      6: Currency
      7: TDateTime
      8: WideCharToString
      11:Boolean
      // non usare 14:Integer o int64--
      256: String

int rp_getparamcount(int hreport:integer;int *paramcount);
int rp_getparamname(int hreport,int index,char *abuffer);
int rp_close(int hreport);
char * rp_lasterror(void);
int rp_print(int hreport,char *title,int showprogress,int showprintdialog);
int rp_preview(int hreport,char *title);
int rp_executeremote(char *hostname,int port,char *user,char *password,
 char *aliasname,char *reportname,char *outputfilename,int metafile,
 int compressed);
int rp_previewremote(char *hostname,int port,char *user,char *password,
 char *aliasname,char *reportname,char *title);
int rp_printremote(char *hostname,int port,char *user,char *password,
 char *aliasname,char *reportname,char *title,int showprogress,
 int showprintdialog);

//nt rp_setparamvaluevar(int hreport,char *paramname,OleVariant paramvalue);
int rp_setadoconnectionstring(int hreport,char *conname,char *constring);
*/

// simone 21/07/2008 convertita da DLLFUNCTION in funzione STATIC per conflitto con Visual Dbsee
//DLLFUNCTION WritePrivateProfileStringA(ASection, AKey, AString, AFileName) USING STDCALL FROM "kernel32.dll"
STATIC FUNCTION WritePrivateProfileStringA(ASection, AKey, AString, AFileName) 

   LOCAL nDll:=DllLoad("kernel32.dll")
   LOCAL xRet:=DllCall(nDll,DLL_STDCALL,"WritePrivateProfileStringA", ASection, AKey, AString, AFileName)
   DllUnLoad(nDll)
RETURN xRet
