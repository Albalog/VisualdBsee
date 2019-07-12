#include "common.ch"
#include "S2CRWPRI.ch"

#ifdef _S2DEBUG_
// funzione presente i sorgente C
//static function _dfCRW_StartExport();return -1
#endif

// Funzioni per esportazione crystal
// ---------------------------------

// ritorna array di esportazioni disponibili sul PC
// in base alle DLL installate

//Luca 19/12/2003 Modificata per permettere di personalizzare l'esportazione.
//FUNCTION dfCrwGetExportTypes() 
FUNCTION dfCrwGetExportTypes(lset) 
   STATIC aExportTypes
   DEFAULT lSet TO .F.
   //Luca 19/12/2003 Modificata per permettere di personalizzare l'esportazione.
   //IF aExportTypes == NIL 
   IF aExportTypes == NIL .OR. lSet
      aExportTypes := initET()
   ENDIF
RETURN aExportTypes

STATIC FUNCTION initET()
   LOCAL aExpTyp
   LOCAL aET
   LOCAL aDLLPath 
   LOCAL uRNF := .T.
   LOCAL uRDF := .T.
   LOCAL nLinesPP := 10
   LOCAL sd := '"'
   LOCAL fd := CHR(9)
   LOCAL aRet
   LOCAL n

   aET := { ;
      {"ASCII Text"                   , ".txt", S2UXFTextType          , "u2ftext.dll"},;
      {"ASCII tab"                    , ".txt", S2UXFTabbedTextType    , "u2ftext.dll"},;
      {"Data Interchange Format (DIF)", ".dif", S2UXFDIFType           , "u2fdif.dll" , uRNF, uRDF},  ;
      {"Comma Separated Format (CSV)" , ".csv", S2UXFCharSeparatedType , "uxfsepv.dll", uRNF, uRDF, NIL,sd, fd},;
      {"Record"                       , ".rec", S2UXFRecordType        , "u2frec.dll" , uRNF, uRDF},;
      {"Text"                         , ".txt", S2UXFPaginatedTextType , "u2ftext.dll", NIL , NIL, nLinesPP},;
      {"Rich Text Format"             , ".rtf", S2UXFRichTextFormatType, "u2frtf.dll"},;
      {"Word"                         , ".doc", S2UXFWordWinType       , "u2fwordw.dll"},;
      {"Excel"                        , ".xls", S2UXFXls5Type          , "u2fxls.dll"},;
      {"PDF"                          , ".pdf", S2UXFPDFType           , "crxf_pdf.dll"},;
      {"XML"                          , ".xml", S2UXFXMLType           , "u2fxml.dll"},;
      {"Crystal Reports"              , ".rpt", S2UXFCrystalReportType , "u2fcr.dll"} ;
     }

// HTML esiste ma non funziona in Crystal 8.5
//      {"HTML"                         , ".htm", S2UXFHTML3Type         , "u2fhtml.dll"},;

   aExpTyp := {}

   aDLLPath := getDllPaths()
   FOR n := 1 TO LEN(aDLLPath)
      // controlla le DLL presenti nei path 
      // in modo da sapere quali esportazioni sono disponibili
      aRet := {}
      AEVAL(aET, {|x| IIF(FILE(aDLLPath[n]+x[DFCRWET_DLL]), AADD(aRet, x), NIL)})

      IF ! EMPTY(aRet)
         aExpTyp:=aRet
         EXIT
      ENDIF
   NEXT
RETURN aExpTyp

STATIC FUNCTION getDllPaths()
   LOCAL aRet   := {}
   // Non pi— usate
   //_addPath(aRet, GETENV("SYSTEMROOT"))
   //_addPath(aRet, dfGetWindowsDirectory())
  aRet := dfCrystalRunTimePaths()
RETURN aRet

// ritorna i path dove potrebbero essere le DLL di crystal
// aggiunge una "\" finale
FUNCTION dfCrystalRunTimePaths()
   LOCAL aRet   := {}

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Mantis 1033
   LOCAL cPath      := ""
   LOCAL nHKey      := ""
   LOCAL cKeyName   := ""
   LOCAL cEntryName := ""
   //Mantis 2067
   IF dfSet("XbaseCrystalOldFilesRuntimePath") == "YES"
      _addPath(aRet, GETENV("SYSTEMROOT"))
      _addPath(aRet, dfGetWindowsDirectory())
      RETURN aRet
   ENDIF 

   cPath      :=  dfSet("XbaseCrystalCommuneFilesRuntimePath")
   IF !EMPTY(cPath)
      cPath      := dfpathchk(cPath)
      IF FILE(cpath + "CRPE32.DLL") 
         AADD(aRet ,cPath  ) 
         //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
         RETURN aRet
      ENDIF
   ENDIF

  

  


   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Modifica Luca 
   //Inserito il 10/01/2011
   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 12
   /////////////////////////////////////////////////////////////////////////////////////////////////
   cPath := GETENV("COMMONPROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\Common\3.5\bin"  
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   //Modifica inserita il 15/04/2011 per compatibilit… su Seven Mantis 2151
   cPath := GETENV("PROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\Common\3.5\bin"  
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Inserito il 2/06/2009
   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 12
   /////////////////////////////////////////////////////////////////////////////////////////////////
   cPath := GETENV("COMMONPROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\3.5\bin\" 
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   //Modifica inserita il 15/04/2011 per compatibilit… su seven Mantis 2151
   cPath := GETENV("PROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\3.5\bin\" 
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 12
   /////////////////////////////////////////////////////////////////////////////////////////////////
   nHKey      := "HKEY_LOCAL_MACHINE"
   cKeyName   := "SOFTWARE\Business Objects\Suite 11.5\Crystal Reports"
   cEntryName := "CommonFiles"
   cPath      := dfQueryRegistry(nHKey, cKeyName, cEntryName)
   IF !EMPTY(cPath )
      cPath      := dfpathchk(cPath)
      IF FILE(cpath + "CRPE32.DLL") 
         AADD(aRet ,cPath  ) 
         //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
         RETURN aRet
      ENDIF
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////


   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 11
   /////////////////////////////////////////////////////////////////////////////////////////////////
   nHKey      := "HKEY_LOCAL_MACHINE"
   cKeyName   := "SOFTWARE\Business Objects\Suite 11.0\Crystal Reports"
   cEntryName := "CommonFiles"
   cPath      := dfQueryRegistry(nHKey, cKeyName, cEntryName)
   IF !EMPTY(cPath )
      cPath      := dfpathchk(cPath)
      IF FILE(cpath + "CRPE32.DLL") 
         AADD(aRet ,cPath  ) 
         //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
         RETURN aRet
      ENDIF
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Modifica Luca 
   //Inserito il 10/01/2011
   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 11
   /////////////////////////////////////////////////////////////////////////////////////////////////
   cPath := GETENV("COMMONPROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\Common\3.0\bin"  
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   //Modifica inserita il 15/04/2011 per compatibilit… su seven Mantis 2151
   cPath := GETENV("PROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\Common\3.0\bin"  
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 11
   /////////////////////////////////////////////////////////////////////////////////////////////////
   cPath := GETENV("COMMONPROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\3.0\bin\" 
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   //Modifica inserita il 15/04/2011 per compatibilit… su seven Mantis 2151
   cPath := GETENV("PROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\3.0\bin\" 
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////


   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 10
   /////////////////////////////////////////////////////////////////////////////////////////////////
   nHKey      := "HKEY_LOCAL_MACHINE"
   cKeyName   := "SOFTWARE\Crystal Decisions\10.0\Crystal Reports"
   cEntryName := "CommonFiles"
   cPath      := dfQueryRegistry(nHKey, cKeyName, cEntryName)
   IF !EMPTY(cPath )
      cPath      := dfpathchk(cPath)
      IF FILE(cpath + "CRPE32.DLL") 
         AADD(aRet ,cPath  ) 
         //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
         RETURN aRet
      ENDIF
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////


   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Modifica Luca 
   //Inserito il 10/01/2011
   //Cerco Runtime Crystal 10
   /////////////////////////////////////////////////////////////////////////////////////////////////
   cPath := GETENV("COMMONPROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\Common\2.5\bin"  
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   //Modifica inserita il 15/04/2011 per compatibilit… su seven Mantis 2151
   cPath := GETENV("PROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\Common\2.5\bin"  
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 10
   /////////////////////////////////////////////////////////////////////////////////////////////////
   cPath := GETENV("COMMONPROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Crystal Decisions\2.5\bin\" 
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   //Modifica inserita il 15/04/2011 per compatibilit… su seven Mantis 2151
   cPath := GETENV("PROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Crystal Decisions\2.5\bin\" 
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 9
   /////////////////////////////////////////////////////////////////////////////////////////////////
   nHKey      := "HKEY_LOCAL_MACHINE"
   cKeyName   := "SOFTWARE\Crystal Decisions\9.0\Crystal Reports"
   cEntryName := "CommonFiles"
   cPath      := dfQueryRegistry(nHKey, cKeyName, cEntryName)
   IF !EMPTY(cPath )
      cPath      := dfpathchk(cPath)
      IF FILE(cpath + "CRPE32.DLL") 
         AADD(aRet ,cPath  ) 
         //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
         RETURN aRet
      ENDIF
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Modifica Luca 
   //Inserito il 10/01/2011
   //Cerco Runtime Crystal 9
   /////////////////////////////////////////////////////////////////////////////////////////////////
   cPath := GETENV("COMMONPROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\Common\2.0\bin"  
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   //Modifica inserita il 15/04/2011 per compatibilit… su seven Mantis 2151
   cPath := GETENV("PROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Business Objects\Common\2.0\bin"  
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 9
   /////////////////////////////////////////////////////////////////////////////////////////////////
   cPath := GETENV("COMMONPROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Crystal Decisions\2.0\bin\" 
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   cPath := GETENV("PROGRAMFILES") 
   cPath := dfpathChk(cPath )+ "Crystal Decisions\2.0\bin\" 
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////

//   /////////////////////////////////////////////////////////////////////////////////////////////////
//   //Cerco Runtime Crystal 8.5
//   /////////////////////////////////////////////////////////////////////////////////////////////////
//   cPath := GETENV("COMMONPROGRAMFILES") 
//   cPath := dfpathChk(cPath )+ "Crystal Decisions\1.0\bin\" 
//   IF FILE(cpath + "CRPE32.DLL") 
//      AADD(aRet ,cPath  ) 
//      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
//      RETURN aRet
//   ENDIF
//   /////////////////////////////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 8.5
   /////////////////////////////////////////////////////////////////////////////////////////////////
   cPath := dfGetSystemDirectory() 
   cPath := dfpathChk(cPath ) 
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////////////////////////////
   //Cerco Runtime Crystal 8.5
   /////////////////////////////////////////////////////////////////////////////////////////////////
   cPath := dfGetWindowsDirectory() 
   cPath := dfpathChk(cPath )+ "Crystal\" 
   IF FILE(cpath + "CRPE32.DLL") 
      AADD(aRet ,cPath  ) 
      //Esco altrimenti potrei caricare dll di versioni differenti con conseguenti malfunzionamenti.
      RETURN aRet
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////////////////////////////////////////
RETURN aRet

STATIC PROCEDURE _addPath(aRet, cPath)
   IF ! EMPTY(cPath)
      IF !RIGHT(cPath, 1)=="\"
         cPath+="\"
      ENDIF
      AADD(aRet, cPath+"CRYSTAL\")
   ENDIF
RETURN 

// Effettua l'esportazione con ID = nExpID
FUNCTION dfCrwStartExport(nJob, hWnd, nExpID, nDestination, cFileName )

IF nExpID == S2UXF_ASKUSER
   RETURN _dfCRW_StartExport(nJob, hWnd, nExpID, 0, "", .F., .F., 0, "", "") 
ENDIF

RETURN _startexport(nJob, hWnd, nExpID, nDestination, cFileName)

STATIC FUNCTION _startexport(nJob, hWnd, nExpID, nDestination, cFileName)
   LOCAL aET     := dfCrwGetExportTypes()
   LOCAL nExp    := ASCAN(aET, {|x| x[DFCRWET_ID]==nExpID})
   LOCAL aExport 

   IF nExp == 0
      RETURN -100
   ENDIF

   aExport := ACLONE(aET[nExp])
   ASIZE(aExport, DFCRWET_NUMELEM)

   DEFAULT aExport[DFCRWET_RNF] TO .T.
   DEFAULT aExport[DFCRWET_RDF] TO .T.
   DEFAULT aExport[DFCRWET_LPP] TO 10
   DEFAULT aExport[DFCRWET_SD ] TO '"'
   DEFAULT aExport[DFCRWET_FD ] TO CHR(9)

RETURN _dfCRW_StartExport(nJob, hWnd, aExport[DFCRWET_ID], nDestination, cFilename,;
                          aExport[DFCRWET_RNF], aExport[DFCRWET_RDF], aExport[DFCRWET_LPP],;
                          aExport[DFCRWET_SD ], aExport[DFCRWET_FD ])



