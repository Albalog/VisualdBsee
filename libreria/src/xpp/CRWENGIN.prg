#include "dll.ch"
#include "common.ch"

// Funzioni base per accesso Crystal Report Print Engine

#define TPL_PEOPENENGINE                       1
#define TPL_PECLOSEENGINE                      2
#define TPL_PECANCLOSEENGINE                   3
#define TPL_PEGETERRORCODE                     4
#define TPL_PEGETERRORTEXT                     5
#define TPL_PEGETHANDLESTRING                  6
#define TPL_PEOPENPRINTJOB                     7
#define TPL_PECLOSEPRINTJOB                    8
#define TPL_PEDISCARDSAVEDDATA                 9
#define TPL_PESTARTPRINTJOB                   10
#define TPL_PEOUTPUTTOWINDOW                  11
#define TPL_PECLOSEWINDOW                     12
#define TPL_PEOUTPUTTOPRINTER                 13
#define TPL_PEGETWINDOWHANDLE                 14
#define TPL_PESETSELECTIONFORMULA             15
#define TPL_PEGETNTABLES                      16
#define TPL_PEGETNTHTABLELOCATION             17
#define TPL_PESETNTHTABLELOCATION             18
#define TPL_PESETWINDOWOPTIONS                19
#define TPL_PEGETWINDOWOPTIONS                20
#define TPL_PESELECTPRINTER                   21
#define TPL_PEEXPORTTO                        22
#define TPL_PEGETEXPORTOPTIONS                23
#define TPL_PESETDIALOGPARENTWINDOW           24
#define TPL_PEGETPRINTOPTIONS                 25
#define TPL_PESETPRINTOPTIONS                 26
#define TPL_PESETMARGINS                      27
#define TPL_PEGetSectionCode                  28
#define TPL_PEGetNSubreportsInSection         29
#define TPL_PEGetNthSubreportInSection        30
#define TPL_PEGetSubreportInfo                31
#define TPL_PEOpenSubreport                   32
#define TPL_PECloseSubreport                  33
#define TPL_PEGetNSections                    34
#define TPL_PEGetNthTableLogOnInfo            35

#define TPL_NUMFUNCTIONS                      35






// Defines di crystal report (CRPE.H)
// -----------------------------------

#define PE_WORD_LEN          2 // word  (2 bytes)
#define PE_USHORT_LEN        2 // unsigned short (2 bytes)

// A table's location is fetched and set using PEGetNthTableLocation and
// PESetNthTableLocation.  This name is database-dependent, and must be
// formatted correctly for the expected database.  For example:
//     - Paradox: "c:\crw\ORDERS.DB"
//     - SQL Server: "publications.dbo.authors"

#define PE_FILE_PATH_LEN           512

#define PE_TABLE_LOCATION_LEN      256
#define PE_SIZEOF_TABLE_LOCATION   PE_WORD_LEN + PE_TABLE_LOCATION_LEN

#define PE_PRINT_OPTIONS_LEN       (4*PE_USHORT_LEN+PE_FILE_PATH_LEN)
#define PE_SIZEOF_PRINT_OPTIONS    PE_WORD_LEN + PE_PRINT_OPTIONS_LEN
//Luca
#define PE_SUBREPORT_NAME_LEN      128
#define PE_SIZEOF_SUBREPORT_INFO   4 * PE_WORD_LEN + PE_SUBREPORT_NAME_LEN + 1
        
#define PE_ALLSECTIONS           0 
#define PE_SECT_PAGE_HEADER      2 
#define PE_SECT_PAGE_FOOTER      7 
#define PE_SECT_REPORT_HEADER    1 
#define PE_SECT_REPORT_FOOTER    8 
#define PE_SECT_GROUP_HEADER     3 
#define PE_SECT_GROUP_FOOTER     5 
#define PE_SECT_DETAIL           4 
 
STATIC nCRWHandle := NIL
STATIC saTemplate

STATIC FUNCTION _DllPrepareCall(nHandle, nCall, cFunc)
   LOCAL xRet
   BEGIN SEQUENCE
      // Se c'Š un errore il break ributta dopo END SEQUENCE
      xRet := DllPrepareCall(nHandle, nCall, cFunc) 

   END SEQUENCE
RETURN xRet


//INIT PROCEDURE LoadCRWEngine()

FUNCTION dfCRWEngineLoad()
   LOCAL oErr
   ////////////////////////////////////////////////
   //Mantis 1033
   LOCAL aPaths  := dfCrystalRunTimePaths()
   LOCAL cPath   := ""

   // scarica la DLL
   dfCRWEngineUnload()

   IF LEN(aPaths)>=1
      cPath := aPaths[1]
      cPath := dfPathChk(cPath  )
      nCRWHandle := DllLoad( cPath+"CRPE32.DLL" )
   ELSE
      nCRWHandle := DllLoad( "CRPE32.DLL" )
   ENDIF 
   //nCRWHandle := DllLoad( "CRPE32.DLL" )
   ////////////////////////////////////////////////
   saTemplate := ARRAY(TPL_NUMFUNCTIONS)

   IF nCRWHandle != 0
      oErr := ErrorBlock({|e| dfErrBreak(e)})

      saTemplate[ TPL_PEOPENENGINE           ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEOpenEngine")
      saTemplate[ TPL_PECLOSEENGINE          ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PECloseEngine")
      saTemplate[ TPL_PECANCLOSEENGINE       ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PECanCloseEngine")
      saTemplate[ TPL_PEGETERRORCODE         ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetErrorCode")
      saTemplate[ TPL_PEGETERRORTEXT         ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetErrorText")
      saTemplate[ TPL_PEGETHANDLESTRING      ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetHandleString")
      saTemplate[ TPL_PEOPENPRINTJOB         ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEOpenPrintJob")
      saTemplate[ TPL_PECLOSEPRINTJOB        ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEClosePrintJob")
      saTemplate[ TPL_PEDISCARDSAVEDDATA     ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEDiscardSavedData")
      saTemplate[ TPL_PESTARTPRINTJOB        ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEStartPrintJob")
      saTemplate[ TPL_PEOUTPUTTOWINDOW       ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEOutputToWindow")
      saTemplate[ TPL_PECLOSEWINDOW          ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PECloseWindow")
      saTemplate[ TPL_PEOUTPUTTOPRINTER      ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEOutputToPrinter")
      saTemplate[ TPL_PEGETWINDOWHANDLE      ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetWindowHandle")
      saTemplate[ TPL_PESETSELECTIONFORMULA  ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PESetSelectionFormula")
      saTemplate[ TPL_PEGETNTABLES           ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetNTables")
      saTemplate[ TPL_PEGETNTHTABLELOCATION  ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetNthTableLocation")
      saTemplate[ TPL_PESETNTHTABLELOCATION  ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PESetNthTableLocation")
      saTemplate[ TPL_PESELECTPRINTER        ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PESelectPrinter")
      saTemplate[ TPL_PESETWINDOWOPTIONS     ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PESetWindowOptions")
      saTemplate[ TPL_PEGETWINDOWOPTIONS     ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetWindowOptions")
      saTemplate[ TPL_PEEXPORTTO             ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEExportTo")          
      saTemplate[ TPL_PEGETEXPORTOPTIONS     ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetExportOptions")
      saTemplate[ TPL_PESETDIALOGPARENTWINDOW] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PESetDialogParentWindow")
      saTemplate[ TPL_PEGETPRINTOPTIONS      ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetPrintOptions")
      saTemplate[ TPL_PESETPRINTOPTIONS      ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PESetPrintOptions")
      saTemplate[ TPL_PESETMARGINS           ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PESetMargins")
      saTemplate[ TPL_PEGetSectionCode       ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetSectionCode")
      saTemplate[ TPL_PEGetNSubreportsInSection ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetNSubreportsInSection")
      saTemplate[ TPL_PEGetNthSubreportInSection] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetNthSubreportInSection")
      saTemplate[ TPL_PEGetSubreportInfo     ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetSubreportInfo")
      saTemplate[ TPL_PEOpenSubreport        ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEOpenSubreport")
      saTemplate[ TPL_PECloseSubreport       ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PECloseSubreport")
      saTemplate[ TPL_PEGetNSections         ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetNSections")
      saTemplate[ TPL_PEGetNthTableLogOnInfo ] := _DllPrepareCall(nCRWHandle, DLL_STDCALL, "PEGetNthTableLogOnInfo")


      ErrorBlock(oErr)
   ENDIF

RETURN nCRWHandle != 0

EXIT PROCEDURE UnloadCRWEngine()
   dfCRWEngineUnload()
RETURN

FUNCTION dfCRWEngineUnload()
   IF nCRWHandle != NIL .AND. nCRWHandle != 0
      DllUnLoad( nCRWHandle )
      nCRWHandle := NIL
   ENDIF
RETURN .T.

FUNCTION dfCRWEngineLoaded()
RETURN dfCRWEngineHandle() != 0

// Per ora supporta solo 
//  0 = LOAD 
// -1 = non LOAD (serve solo per controllare se caricato)
// se serve potrei anche mettere 1=load sempre

FUNCTION dfCRWEngineHandle( nLoad )
   DEFAULT nLoad TO 0

   IF nCRWHandle == NIL .AND. nLoad == 0
      dfCRWEngineLoad()
   ENDIF
RETURN nCRWHandle

  


// ------------------------------
// Wrapper delle funzioni Crystal
// ------------------------------

// Open and close print engine
// ---------------------------

FUNCTION PEOpenEngine()
   IF dfCRWEngineHandle() != 0
      RETURN DllExecuteCall(saTemplate[TPL_PEOPENENGINE])
   ENDIF
RETURN -1

FUNCTION PECloseEngine()
RETURN DllExecuteCall(saTemplate[TPL_PECLOSEENGINE])

FUNCTION PECanCloseEngine()
RETURN DllExecuteCall(saTemplate[TPL_PECANCLOSEENGINE])

FUNCTION PEGetNthTableLogOnInfo(nJob,nTable,LogOnInfo)
RETURN DllExecuteCall(saTemplate[TPL_PEGetNthTableLogOnInfo],nJob,nTable,@LogOnInfo)

FUNCTION PEGetNSections( nJob )
RETURN BIN2I(W2Bin(dfAnd(DllExecuteCall(saTemplate[TPL_PEGetNSections], nJob), 0xFFFF)))

FUNCTION PECloseSubreport( nJob )
RETURN DllExecuteCall(saTemplate[TPL_PECloseSubreport], nJob)

FUNCTION PEOpenSubreport( nParentJob,cSubreportName  )
RETURN DllExecuteCall(saTemplate[TPL_PEOpenSubreport], nParentJob,cSubreportName)

FUNCTION PEGetSectionCode( nJob, nSection )
RETURN DllExecuteCall(saTemplate[TPL_PEGetSectionCode], nJob, nSection )
         
FUNCTION PEGetNSubreportsInSection( nJob, xSectionCode )
RETURN BIN2I(W2Bin(dfAnd(DllExecuteCall(saTemplate[TPL_PEGetNSubreportsInSection], nJob, xSectionCode ) , 0xFFFF)))
         
FUNCTION PEGetNthSubreportInSection( nJob, xSectionCode, nSubReport )
RETURN DllExecuteCall(saTemplate[TPL_PEGetNthSubreportInSection], nJob, xSectionCode, nSubReport)

FUNCTION PEGetSubreportInfo( nJob, nSubReportHamdel, xSubreportInfo )
RETURN DllExecuteCall(saTemplate[TPL_PEGetSubreportInfo], nJob, nSubReportHamdel, @xSubreportInfo)


// Error Management Functions
// -------------------------------------------------------------------
FUNCTION PEGetErrorCode( nJob )
RETURN DllExecuteCall(saTemplate[TPL_PEGETERRORCODE])

FUNCTION PEGetErrorText( nJob, hText, nTextLength )
RETURN DllExecuteCall(saTemplate[TPL_PEGETERRORTEXT], nJob, @hText, @nTextLength )

FUNCTION PEGetHandleString( hText, cText, nTextLength )
  LOCAL cREt 
cRet  :=  DllExecuteCall(saTemplate[TPL_PEGETHANDLESTRING], hText, @cText, nTextLength )
cText :=  STRTRAN(cText, chr(0), "")
RETURN cRet

// Prepares to print a report.
FUNCTION PEOpenPrintJob( cReportFileName )
RETURN DllExecuteCall(saTemplate[TPL_PEOPENPRINTJOB], cReportFileName )

// Closes the print job.
FUNCTION PEClosePrintJob( nJob )
RETURN DllExecuteCall(saTemplate[TPL_PECLOSEPRINTJOB], nJob )

// discard prev. data
FUNCTION PEDiscardSavedData( nJob )
RETURN DllExecuteCall(saTemplate[TPL_PEDISCARDSAVEDDATA], nJob )

// Prints the report (customprint link).
FUNCTION PEStartPrintJob( nJob, lWait )
  LOCAL oErr := ERRORBLOCK({|e|dfErrBreak(e)})
  LOCAL x
  LOCAL xRet := 0

  BEGIN SEQUENCE
     xRet := DllExecuteCall(saTemplate[TPL_PESTARTPRINTJOB], nJob, lWait )

  RECOVER USING x
     dfAlert("Crystal Report Error code:DB0001//Check DBF file structure differs from structure stored in file .RPT")
     xRet := 1
  END SEQUENCE
  ERRORBLOCK(oErr)

RETURN xRet

// Determines if the current job is finished or still in progress
FUNCTION PEOutputToWindow( nJob, cTitle,x,y,z,u, hwnd, null)
RETURN DllExecuteCall(saTemplate[TPL_PEOUTPUTTOWINDOW], nJob, cTitle,x,y,z,u, hwnd, null)

// Close preview window
FUNCTION PECloseWindow( nHwnd)
RETURN DllExecuteCall(saTemplate[TPL_PECLOSEWINDOW], nHwnd)

// Determines if the current job is finished or still in progress.
FUNCTION PEOutputToPrinter( nJob, nd)
RETURN DllExecuteCall(saTemplate[TPL_PEOUTPUTTOPRINTER], nJob, nd)

FUNCTION PEGetWindowHandle(nJob)
RETURN DllExecuteCall(saTemplate[TPL_PEGETWINDOWHANDLE], nJob)

// Selection formula in crystal language
FUNCTION PESetSelectionFormula( nJob, cString)

   IF ! VALTYPE(cString) $ "CM" .OR. EMPTY(cString)
      RETURN .T.
   ENDIF

   // se la stringa inizia per CRW: non effettua la conversione
   // se la stringa inizia per XPP: effettua la conversione
   // altrimenti lo decide in automatico

   DO CASE
      CASE UPPER(LEFT(cString, 4)) == "CRW:"
         cString := SUBSTR(cString, 5)

      CASE LEFT(cString, 4) == "XPP:"
         cString := SUBSTR(cString, 5)

         // converte espressione xbase in formula
         cString := dfExp2CrwFormula(cString, nJob)

      OTHERWISE

        // se esistono queste tipiche espressioni Xbase
        // allora il filtro Š da convertire in formula Crystal
        IF "->"     $ cString        .OR. ;
           ".T."    $ UPPER(cString) .OR. ;
           ".F."    $ UPPER(cString) .OR. ;
           ".AND."  $ UPPER(cString) .OR. ;
           ".OR."   $ UPPER(cString) .OR. ;
           "UPPER(" $ UPPER(cString)

           // converte espressione xbase in formula
           cString := dfExp2CrwFormula(cString, nJob)
        ENDIF
   ENDCASE
RETURN DllExecuteCall(saTemplate[TPL_PESETSELECTIONFORMULA], nJob, cString)

FUNCTION PEGetNTables(nJob)
RETURN BIN2I(W2Bin(dfAnd( DllExecuteCall(saTemplate[TPL_PEGETNTABLES], nJob), 0xFFFF)))

FUNCTION PEGetNthTableLocation(nJob, nTable, cTLStru)
   IF saTemplate[TPL_PEGETNTHTABLELOCATION] == NIL
      RETURN NIL
   ENDIF
RETURN DllExecuteCall(saTemplate[TPL_PEGETNTHTABLELOCATION], nJob, nTable, @cTLStru)

FUNCTION PESetNthTableLocation(nJob, nTable, cTLStru)
   IF saTemplate[TPL_PESETNTHTABLELOCATION] == NIL
      RETURN NIL
   ENDIF
RETURN DllExecuteCall(saTemplate[TPL_PESETNTHTABLELOCATION], nJob, nTable, @cTLStru)

// Window options

FUNCTION PESetWindowOptions( nJob, a )
   IF saTemplate[TPL_PESETWINDOWOPTIONS] == NIL
      RETURN NIL
   ENDIF
RETURN DllExecuteCall(saTemplate[TPL_PESETWINDOWOPTIONS], nJob, @a )

FUNCTION PEGetWindowOptions( nJob, a )
   IF saTemplate[TPL_PEGETWINDOWOPTIONS] == NIL
      RETURN NIL
   ENDIF
RETURN DllExecuteCall(saTemplate[TPL_PEGETWINDOWOPTIONS], nJob, @a )

FUNCTION PESelectPrinter( nJob, driver, printer, port, devmode )
RETURN DllExecuteCall(saTemplate[TPL_PESELECTPRINTER], nJob, @driver, @printer, @port, @devmode )

FUNCTION PEExportTo( nJob, exp )
RETURN DllExecuteCall(saTemplate[TPL_PEEXPORTTO], nJob, @exp)

FUNCTION PEGetExportOptions( nJob, exp )
RETURN DllExecuteCall(saTemplate[TPL_PEGETEXPORTOPTIONS], nJob, @exp)

FUNCTION PESetDialogParentWindow(nJob, nHwnd)
   IF saTemplate[TPL_PESETDIALOGPARENTWINDOW] == NIL
      RETURN 1  // se non esiste ignora e non da errore
   ENDIF
RETURN DllExecuteCall(saTemplate[TPL_PESETDIALOGPARENTWINDOW], nJob, nHWND)

FUNCTION PESetMargins(nJob, nLeft, nRight, nTop, nBottom)
   IF saTemplate[TPL_PESETMARGINS] == NIL
      RETURN NIL
   ENDIF
RETURN DllExecuteCall(saTemplate[TPL_PESETMARGINS], nJob, nLeft, nRight, nTop, nBottom)

FUNCTION PESetPrintOptions(nJob, cStru)
   IF saTemplate[TPL_PESETPRINTOPTIONS] == NIL
      RETURN 1  // se non esiste ignora e non da errore
   ENDIF
RETURN DllExecuteCall(saTemplate[TPL_PESETPRINTOPTIONS], nJob, @cStru)

FUNCTION PEGetPrintOptions(nJob, cStru)
   IF saTemplate[TPL_PEGETPRINTOPTIONS] == NIL
      RETURN 0  // se non esiste da errore
   ENDIF
RETURN DllExecuteCall(saTemplate[TPL_PEGETPRINTOPTIONS], nJob, @cStru)

FUNCTION __PESetPrintOptions(nJob, aOptions)
   LOCAL cStru := W2BIN(PE_SIZEOF_PRINT_OPTIONS)+SPACE(PE_PRINT_OPTIONS_LEN)
   LOCAL aOpt

   IF EMPTY(aOptions)
      RETURN 1
   ENDIF

   IF !VALTYPE(aOptions) == "A"
      RETURN 1
   ENDIF

   IF PEGetPrintOptions(nJob, @cStru)==0
      RETURN 1
   ENDIF

   aOpt := ACLONE(aOptions)
   ASIZE(aOpt, 5)

   IF aOpt[1] != NIL // start page
      //Mantis 2242 Luca C. 04/03/2014
      IF aOpt[1] == 0
         aOpt[1] := 1
      ENDIF 
      IF !VALTYPE(aOpt[1]) == "N"
         aOpt[1] := 1
      ENDIF 
      aOpt[1] := INT(aOpt[1]) 
      cStru   := STUFF(cStru, 3, 2, W2BIN(aOpt[1]))
   ENDIF
   IF aOpt[2] != NIL // end page
      //Mantis 2242 Luca C. 04/03/2014
      IF aOpt[2] == 0
         aOpt[2] := 99
      ENDIF 
      IF !VALTYPE(aOpt[2]) == "N"
         aOpt[2] := 99
      ENDIF 
      aOpt[2] := INT(aOpt[2]) 
      cStru := STUFF(cStru, 5, 2, W2BIN(aOpt[2]))
   ENDIF
   IF aOpt[3] != NIL // copies
      //Mantis 2242 Luca C. 04/03/2014
      IF aOpt[3] == 0
         aOpt[3] := 1
      ENDIF 
      IF !VALTYPE(aOpt[3]) == "N"
         aOpt[3] := 1
      ENDIF 
      aOpt[3] := INT(aOpt[3]) 
      cStru := STUFF(cStru, 7, 2, W2BIN(aOpt[3]))
   ENDIF
   IF aOpt[4] != NIL // collation
      //Mantis 2242 Luca C. 04/03/2014
      IF !aOpt[3] == 0 .OR. !aOpt[3] == 1
         aOpt[3] := 0
      ENDIF 
      cStru := STUFF(cStru, 9, 2, W2BIN(aOpt[4]))
   ENDIF
   IF aOpt[5] != NIL // file name
      cStru := PAD(aOpt[5]+CHR(0), PE_FILE_PATH_LEN)
   ENDIF

RETURN PESetPrintOptions(nJob, cStru)

FUNCTION __PEGetTableList(nJob)
   LOCAL nTL         := 0
   LOCAL cTLStru     := ""
   LOCAL aOld        := {}
   LOCAL n
   LOCAL nTables     :=PEGetNTables(nJob)
   LOCAL cFname

   FOR nTL := 1 TO nTables
      // Fix 16/12/2003  Luca
      //cTLStru := SPACE(PE_SIZEOF_TABLE_LOCATION)
      cTLStru := W2BIN(PE_SIZEOF_TABLE_LOCATION) + SPACE(PE_TABLE_LOCATION_LEN)
      IF PEGetNThTableLocation(nJob, nTl-1, @cTLStru) == 0
         EXIT
      ENDIF

      cTLStru := SUBSTR(cTLStru, 3) // salto i primi 2 bytes
      n:=AT(CHR(0), cTLStru)
      IF n >0
         cTLStru := LEFT(cTLStru, n-1)
      ENDIF
      AADD(aOld, UPPER(dfFnameSplit(cTLStru)[3]))
   NEXT
RETURN aOld


STATIC FUNCTION SetTableLocation(nJob, aTabLocation)
   LOCAL nTL         := 0
   LOCAL cTLStru     := ""
   LOCAL aOld        := {}
   LOCAL nN, nRet
   LOCAL nTables     := PEGetNTables(nJob)
   LOCAL cFname      := ""
   LOCAL aTab        := {} 

   IF EMPTY(aTabLocation) .OR. LEN(aTabLocation) == 0
      RETURN NIL
   ENDIF

   AEVAL(aTabLocation,{|x|AADD(aTab,UPPER(dfFnameSplit(x)[3]))})

   FOR nTL := 1 TO nTables
      // Fix 16/12/2003  Luca
      //cTLStru := SPACE(PE_SIZEOF_TABLE_LOCATION)
      cTLStru := W2BIN(PE_SIZEOF_TABLE_LOCATION) + SPACE(PE_TABLE_LOCATION_LEN)
      IF PEGetNThTableLocation(nJob, nTl-1, @cTLStru) == 0
         EXIT
      ENDIF

      cTLStru := SUBSTR(cTLStru, 3) // salto i primi 2 bytes
      nN :=AT(CHR(0), cTLStru)
      IF nN >0
         cTLStru := LEFT(cTLStru, nN-1)
      ENDIF
      AADD(aOld, UPPER(dfFnameSplit(cTLStru)[3]))
   NEXT

                   
   IF nTables>0   // Imposta il percorso dove sono le tabelle
      FOR nTL    := 1 TO nTables
          // Nome Tabelle nel file RPT
          cFname := aOld[nTL]
          // Verifico se nel Array aTablocation (senza il path) esiste la Tabbella e la posizione 
          nN     := ASCAN(aTab, {|x| x==cFname })
          IF nN>0
             // Creo la stringa con il nuovo path da impostare
             cTLStru := W2BIN(PE_SIZEOF_TABLE_LOCATION)+PAD(aTabLocation[nN]+CHR(0), PE_TABLE_LOCATION_LEN)
             // Eseguo il SetTablocation sul Tabella (di posizione nTL) 
             nRet    := PESetNthTableLocation(nJob, nTL-1, @cTLStru)
             //PEGetNthTableLogOnInfo()
          ELSE
             // Se le tabelle del Report sono solo 1a, allora per compatibilit… con dBsee for xbase si ha aTabLocation[1]: 
             IF LEN(aTabLocation)== 1 
                // Creo la stringa con il nuovo path da impostare
                cTLStru := W2BIN(PE_SIZEOF_TABLE_LOCATION)+PAD(aTabLocation[1]+CHR(0), PE_TABLE_LOCATION_LEN)
                // Eseguo il SetTablocation sul Tabella (di posizione nTL) 
                nRet    := PESetNthTableLocation(nJob, 0, @cTLStru) //sul primo archivio
             ENDIF
          ENDIF
       NEXT
   //Vecchio codice 
   /*
     IF ! EMPTY(aTabLocation) // Imposta il percorso dove sono le tabelle
        FOR nTL := 1 TO LEN(aTabLocation)
           // Fix 16/12/2003  Luca
           //IF LEN(aOld) == 1
           IF LEN(aOld) <= 1
              n:=1 // se nel .RPT ho un solo file assegno quello
           ELSE
              // cerco il nome di file fra quelli inseriti nel file .RPT
              cFname := UPPER(dfFnameSplit(aTabLocation[nTL])[3])
              n := ASCAN(aOld, {|x|x==cFname })
           ENDIF
           IF n > 0
              cTLStru := W2BIN(PE_SIZEOF_TABLE_LOCATION)+PAD(aTabLocation[nTL]+CHR(0), PE_TABLE_LOCATION_LEN)
              PESetNthTableLocation(nJob, n-1, @cTLStru)
           ENDIF
        NEXT
     ENDIF
   */
   ENDIF
RETURN NIL

FUNCTION __PESetTableLocation(nJob, aTabLocation)
   LOCAL nRet, nN
   LOCAL nSectionCode    
   LOCAL nSubReports    
   LOCAL SubreportHandle
   LOCAL nSubJob
   LOCAL nSections 
   LOCAL cReportName
   LOCAL nSub 

   // Eseguo il SetTablocation del Report 
   SetTableLocation(nJob, aTabLocation)

   // Eseguo il SetTablocation dei SubReport se esistono
   nSections := PEGetNSections(nJob)
   //nSections := BIN2I(W2Bin(nSections))
   FOR nN   := 1 TO nSections
       nSectionCode    := PEGetSectionCode(nJob, (nN-1))
       IF nSectionCode >= 0   
          nSubReports     := PEGetNSubreportsInSection(nJob, nSectionCode)
          IF nSubReports>0
             For nSub := 0 TO nSubReports-1
                 SubreportHandle := PEGetNthSubreportInSection(nJob, nSectionCode, nSub)
                 IF SubreportHandle>0
                    cReportName := W2BIN(PE_SIZEOF_SUBREPORT_INFO) + SPACE(PE_SIZEOF_SUBREPORT_INFO)
                    PEGetSubreportInfo(nJob,SubreportHandle,@cReportName)
                    cReportName := SUBSTR(cReportName, 3) // salto i primi 2 bytes
                    cReportName := Alltrim(cReportName)
                    //Apro il SubReport 
                    nSubJob     := PEOpenSubreport(nJob,cReportName) 
                    IF nSubJob>0
                       // Eseguo il SetTablocation del Report 
                       __PESetTableLocation(nSubJob, aTabLocation)
                    ENDIF
                    // Chiudo il SubReport
                    nRet        := PECloseSubreport(nSubJob)
                 ENDIF
             NEXT
          ENDIF
       ENDIF
   NEXT
RETURN NIL
