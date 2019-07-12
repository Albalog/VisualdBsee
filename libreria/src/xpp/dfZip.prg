#include "common.ch"
#include "dll.ch"
//#include "zipx.ch"
//#include "unzipx.ch"
#include "dfZip.ch"

// USA DLL di INFOZIP
// vedere http://www.info-zip.org/

#pragma library("kernel32.lib")

// la static e la classe servono solo per fare il
// SYNC method dato che la funzione NON Š THREAD SAFE
STATIC oZip

INIT PROCEDURE dfZIPInit()
   oZip := _dfZip():new()
RETURN

// Esegue ZIP di un file nella directory cPath.
// Torna 0 se ok
// per l'elenco delle opzioni vedere la documentazione di INFOZIP
// Al codeblock bBlk vengono passati "n" parametri; il primo
// corrisponde alla funzione ( PRINT, SERVICE, ECC), vedi WINDLL.TXT
// e ZIPX.CH
// dal secondo fino al 5ø dipende dalla funzione
//
// cOpt = "add", "upd", "fre"
//        add:default, upd=update, fre=freshen
// lRecurse = Recurse subdir
// nLevel = compression level 0-9 default=5
// Es.
//   crea pippo.zip di tutti i file c:\temp\*.db?
//   dfZipFile("pippo.zip", "c:\temp", NIL, "*.DB?")
//
//   crea pippo.zip di tutti i file c:\temp\*.db? e c:\temp\*.prg 
//   dfZipFile("pippo.zip", "c:\temp", NIL, {"*.DB?", "*.PRG"})

FUNCTION dfZipFile(cFile, cPath, bBlk, aFiles, cOpt, lRecurse, lMove, nLevel)
RETURN oZip:Zip(cFile, cPath, bBlk, aFiles, cOpt, lRecurse, lMove, nLevel)

FUNCTION dfUnZipFile(cFile, cPath, bBlk, nExtractOnlyNewer, ;
                 nSpaceToUnderscore, nPromptToOverwrite, ;
                 nfQuiet, nncflag, nntflag, nnvflag, nnfflag, ;
                 nnzflag, nndflag, nnoflag, nnaflag, nnZIflag, ;
                 nC_flag, nfPrivilege)



   IF dfSet("XbaseWindowsUnZip")== "YES"
      RETURN dfNewWinUnZip(cFile, cPath )
   ENDIF 

RETURN oZip:unZip(cFile, cPath, bBlk, nExtractOnlyNewer, ;
                 nSpaceToUnderscore, nPromptToOverwrite, ;
                 nfQuiet, nncflag, nntflag, nnvflag, nnfflag, ;
                 nnzflag, nndflag, nnoflag, nnaflag, nnZIflag, ;
                 nC_flag, nfPrivilege)


STATIC CLASS _dfZip
   PROTECTED
        VAR nZipDll
        VAR nUnZipDll

   EXPORTED:
	INLINE METHOD Init()
	   ::loadDLL()
	RETURN self

	INLINE METHOD destroy()
	   ::unloadDLL()
	RETURN self

	INLINE METHOD loadDLL()
	   ::unloadDLL()
	   ::nZipDLL   := DllLoad("DBZIP.DLL")
	   ::nUnZipDLL := DllLoad("DBUNZIP.DLL")
	RETURN self

	INLINE METHOD unLoadDLL()
	   IF ! EMPTY(::nZipDLL)
	      DllUnLoad(::nZipDLL)
	   ENDIF
	   IF ! EMPTY(::nUnZipDLL)
	      DllUnLoad(::nUnZipDLL)
	   ENDIF
	RETURN self

	SYNC METHOD Zip
	SYNC METHOD UnZip
ENDCLASS

// Esegue ZIP di un file nella directory cPath.
// Torna 0 se ok
// per l'elenco delle opzioni vedere la documentazione di INFOZIP
// Al codeblock bBlk vengono passati "n" parametri; il primo
// corrisponde alla funzione ( PRINT, SERVICE, ECC), vedi WINDLL.TXT
// e ZIPX.CH
// dal secondo fino al 5ø dipende dalla funzione
//
// cOpt = "add", "upd", "fre"
//        add:default, upd=update, fre=freshen
// lRecurse = Recurse subdir
// nLevel = compression level 0-9 default=5
// Es.
//   crea pippo.zip di tutti i file c:\temp\*.db?
//   dfZipFile("pippo.zip", "c:\temp", NIL, "*.DB?")
//
//   crea pippo.zip di tutti i file c:\temp\*.db? e c:\temp\*.prg 
//   dfZipFile("pippo.zip", "c:\temp", NIL, {"*.DB?", "*.PRG"})

METHOD _dfZip:Zip(cFile, cPath, bBlk, aFiles, cOpt, lRecurse, lMove, nLevel)

// STATIC FUNCTION WIZ_ZipFile(cFile, cPath, bBlk, aFiles )

   LOCAL nRet := -1
   LOCAL cCmd := ""
   LOCAL nComp           , cFiles          , cDate           ,  ;
         cTmpDir         , nTemp           , nSuffix         ,  ;
         nEncrypt        , nSystem         , nVolume         ,  ;
         nExtra          , nNoDirEntries   , nExcludeDate    ,  ;
         nIncludeDate    , nVerbose        , nQuiet          ,  ;
         nCRLF_LF        , nLF_CRLF        , nJunkDir        ,  ;
         nGrow           , nForce          , nMove           ,  ;
         nDeleteEntries  , nUpdate         , nFreshen        ,  ;
         nJunkSFX        , nLatestTime     , nComment        ,  ;
         nOffsets        , nPrivilege      , nEncryption     ,  ;
         nRecurse        , nRepair         

   IF ! EMPTY(cFile)

      IF EMPTY(aFiles)
         aFiles := {"*.*"}
      ELSEIF ! VALTYPE( aFiles ) == "A"
         aFiles := {aFiles}
      ENDIF

      IF EMPTY(cPath)
         cPath := ""
      ELSEIF ! RIGHT(cPath, 1)=="\"
         cPath += "\"
      ENDIF

      nComp := LEN(aFiles)
      cFiles := ""
      AEVAL(aFiles, {|c| cFiles += c+CHR(0) } )

      DEFAULT bBlk   TO {|nID, p1, p2, p3, p4| DefZIPCB(nID, p1, p2, p3, p4)}

      IF VALTYPE(cOpt) $ "CM"
         cOpt := UPPER(ALLTRIM(cOpt))
         DO CASE
            CASE cOpt == WIZ_ZIP_OPT_UPD
               nUpdate := 1
            CASE cOpt == WIZ_ZIP_OPT_FRE
               nFreshen := 1
         ENDCASE
      ENDIF

      IF VALTYPE(lRecurse) == "L" .AND. lRecurse == .F.
         nRecurse := 0
      ENDIF

      IF VALTYPE(lMove) == "L" .AND. lMove
         nMove := 1
      ENDIF


      //DEFAULT nComp           TO 1  /* numero files da compattare */
      //DEFAULT cFiles          TO "*.*"+CHR(0) /* elenco files da compattare */
      DEFAULT cDate           TO "" /* Date to include after */

      DEFAULT cTmpDir         TO "" /* Temporary directory used during zipping */
      DEFAULT nTemp           TO 0  /* Use temporary directory '-b' during zipping */
      DEFAULT nSuffix         TO 0  /* include suffixes (not implemented in WiZ) */
      DEFAULT nEncrypt        TO 0  /* encrypt files */
      DEFAULT nSystem         TO 0  /* include system and hidden files */
      DEFAULT nVolume         TO 0  /* Include volume label */
      DEFAULT nExtra          TO 0  /* Exclude extra attributes */
      DEFAULT nNoDirEntries   TO 0  /* Do not add directory entries */
      DEFAULT nExcludeDate    TO 0  /* Exclude files earlier than specified date */
      DEFAULT nIncludeDate    TO 0  /* Include only files earlier than specified date */
      DEFAULT nVerbose        TO 0  /* Mention oddities in zip file structure */
      DEFAULT nQuiet          TO 0  /* Quiet operation */
      DEFAULT nCRLF_LF        TO 0  /* Translate CR/LF to LF */
      DEFAULT nLF_CRLF        TO 0  /* Translate LF to CR/LF */
      DEFAULT nJunkDir        TO 0  /* Junk directory names */
      DEFAULT nGrow           TO 0  /* Allow appending to a zip file */
      DEFAULT nForce          TO 0  /* Make entries using DOS names (k for Katz) */
      DEFAULT nMove           TO 0  /* Delete files added or updated in zip file */
      DEFAULT nDeleteEntries  TO 0  /* Delete files from zip file */
      DEFAULT nUpdate         TO 0  /* Update zip file--overwrite only if newer */
      DEFAULT nFreshen        TO 0  /* Freshen zip file--overwrite only */
      DEFAULT nJunkSFX        TO 0  /* Junk SFX prefix */
      DEFAULT nLatestTime     TO 0  /* Set zip file time to time of latest file in it */
      DEFAULT nComment        TO 0  /* Put comment in zip file */
      DEFAULT nOffsets        TO 0  /* Update archive offsets for SFX files */
      DEFAULT nPrivilege      TO 0  /* Use privileges (WIN32 only) */
      DEFAULT nEncryption     TO 0  /* TRUE if encryption supported, else FALSE.
                                       this is a read-only flag */
      DEFAULT nRecurse        TO 1  /* Recurse into subdirectories. 1 => -r, 2 => -R */
      DEFAULT nRepair         TO 0  /* Repair archive. 1 => -F, 2 => -FF */
      DEFAULT nLevel          TO 5  /* Compression level (0 - 9) */

      nLevel += 48 // trasformo in codice ASCII corrispondente:
                   // es. 1+48=49  - CHR(49) = "1"

      nRet := _WIZ_ZIPFILE(::nZipDLL       , ;  /* DLL HANDLE */
                           cFile           , ;  /* Nome file ZIP */
                           bBlk            , ;  /* codeblock eseguito durante compattamento */
                           nComp           , ;  /* numero files da compattare */
                           cFiles          , ;  /* elenco files da compattare */
                           cDate           , ;  /* Date to include after */
                           cPath           , ;  /* Directory to use as base for zipping */
                           cTmpDir         , ;  /* Temporary directory used during zipping */
                           nTemp           , ;  /* Use temporary directory '-b' during zipping */
                           nSuffix         , ;  /* include suffixes (not implemented in WiZ) */
                           nEncrypt        , ;  /* encrypt files */
                           nSystem         , ;  /* include system and hidden files */
                           nVolume         , ;  /* Include volume label */
                           nExtra          , ;  /* Exclude extra attributes */
                           nNoDirEntries   , ;  /* Do not add directory entries */
                           nExcludeDate    , ;  /* Exclude files earlier than specified date */
                           nIncludeDate    , ;  /* Include only files earlier than specified date */
                           nVerbose        , ;  /* Mention oddities in zip file structure */
                           nQuiet          , ;  /* Quiet operation */
                           nCRLF_LF        , ;  /* Translate CR/LF to LF */
                           nLF_CRLF        , ;  /* Translate LF to CR/LF */
                           nJunkDir        , ;  /* Junk directory names */
                           nGrow           , ;  /* Allow appending to a zip file */
                           nForce          , ;  /* Make entries using DOS names (k for Katz) */
                           nMove           , ;  /* Delete files added or updated in zip file */
                           nDeleteEntries  , ;  /* Delete files from zip file */
                           nUpdate         , ;  /* Update zip file--overwrite only if newer */
                           nFreshen        , ;  /* Freshen zip file--overwrite only */
                           nJunkSFX        , ;  /* Junk SFX prefix */
                           nLatestTime     , ;  /* Set zip file time to time of latest file in it */
                           nComment        , ;  /* Put comment in zip file */
                           nOffsets        , ;  /* Update archive offsets for SFX files */
                           nPrivilege      , ;  /* Use privileges (WIN32 only) */
                           nEncryption     , ;  /* TRUE if encryption supported, else FALSE.                                                   this is a read-only flag */
                           nRecurse        , ;  /* Recurse into subdirectories. 1 => -r, 2 => -R */
                           nRepair         , ;  /* Repair archive. 1 => -F, 2 => -FF */
                           nLevel            )  /* Compression level (0 - 9) */
   ENDIF
RETURN nRet

STATIC FUNCTION DefZIPCB(nID, p1, p2, p3, p4)
   LOCAL xRet
   DO CASE
      CASE nID == WIZ_ZIP_CB_ID_PRINT
	 // int WINAPI DisplayBuf(LPSTR buf, unsigned long size)
	 //p1=filename, p2=dimensione
         //? p1, p2
         xRet := p2

      CASE nID == WIZ_ZIP_CB_ID_SVC
	 //int WINAPI ServCallBk(LPCSTR buf, unsigned long size)
	 //p1=filename, p2=dimensione
         //? p1, p2
         xRet := 0

      CASE nID == WIZ_ZIP_CB_ID_PWD
          // int WINAPI password(char *p, int n, const char *m, const char *name)
          //p1, p2, p3, p4
          xRet := 1

      CASE nID == WIZ_ZIP_CB_ID_COMMENT

   ENDCASE
RETURN xRet

// Esegue UNZIP di un file nella directory cPath.
// Torna 0 se ok
// per l'elenco delle opzioni vedere la documentazione di INFOZIP
// Al codeblock bBlk vengono passati "n" parametri; il primo
// corrisponde alla funzione (SOUND, PRINT, SERVICE, ECC), vedi WINDLL.TXT
// e UNZIPX.CH
// dal secondo fino al 14ø dipende dalla funzione


METHOD _dfZip:unZip(cFile, cPath, bBlk, nExtractOnlyNewer, ;
                 nSpaceToUnderscore, nPromptToOverwrite, ;
                 nfQuiet, nncflag, nntflag, nnvflag, nnfflag, ;
                 nnzflag, nndflag, nnoflag, nnaflag, nnZIflag, ;
                 nC_flag, nfPrivilege)

// RETURN WIZ_UnzipFile(cFile, cPath, bBlk, nExtractOnlyNewer, ;
//                  nSpaceToUnderscore, nPromptToOverwrite, ;
//                  nfQuiet, nncflag, nntflag, nnvflag, nnfflag, ;
//                  nnzflag, nndflag, nnoflag, nnaflag, nnZIflag, ;
//                  nC_flag, nfPrivilege
// 
// STATIC FUNCTION WIZ_UnzipFile(cFile, cPath, bBlk, nExtractOnlyNewer, ;
//                        nSpaceToUnderscore, nPromptToOverwrite, ;
//                        nfQuiet, nncflag, nntflag, nnvflag, nnfflag, ;
//                        nnzflag, nndflag, nnoflag, nnaflag, nnZIflag, ;
//                        nC_flag, nfPrivilege      )

   LOCAL nRet
   LOCAL cCmd := ""

   IF ! EMPTY(cFile) //.AND. FILE(cFile)
      DEFAULT bBlk   TO {|nID, p1, p2, p3, p4, p5, p6, ;
                          p7, p8, p9, p10, p11, p12, p13| ;
                          DefUNZIPCB(nID, p1, p2, p3, p4, p5, p6, ;
                                p7, p8, p9, p10, p11, p12, p13)}

      DEFAULT nExtractOnlyNewer TO 0   // true for "update" without interaction
                                       // (extract only newer/new files, without queries)
      DEFAULT nSpaceToUnderscore TO 0  // true if convert space to underscore
      DEFAULT nPromptToOverwrite TO 0  // true if prompt to overwrite is wanted
      DEFAULT nfQuiet TO 0             // quiet flag. 1 = few messages, 2 = no messages, 0 = all messages
      DEFAULT nncflag TO 0             // write to stdout if true
      DEFAULT nntflag TO 0             // test zip file
      DEFAULT nnvflag TO 0             // verbose listing
      DEFAULT nnfflag TO 0             // "freshen" (replace existing files by newer versions)
      DEFAULT nnzflag TO 0             // display zip file comment
      DEFAULT nndflag TO 1             // all args are files/dir to be extracted
      DEFAULT nnoflag TO 1             // true if you are to always over-write files, false if not
      DEFAULT nnaflag TO 0             // do end-of-line translation
      DEFAULT nnZIflag TO 0            // get zip info if true
      DEFAULT nC_flag TO 1             // be case insensitive if TRUE
      DEFAULT nfPrivilege TO 1         // 1 => restore Acl's, 2 => Use privileges

      IF EMPTY(cPath)
         cPath := ""
      ELSEIF ! RIGHT(cPath, 1)=="\"
         cPath += "\"
      ENDIF

      nRet := _WIZ_UNZIPFILE(::nUnZipDLL       , ;  /* DLL HANDLE */
                             cFile, cPath, bBlk, 0, "", 0, "", ;
                             nExtractOnlyNewer, ;
                             nSpaceToUnderscore, nPromptToOverwrite, ;
                             nfQuiet, nncflag, nntflag, nnvflag, nnfflag, ;
                             nnzflag, nndflag, nnoflag, nnaflag, nnZIflag, ;
                             nC_flag, nfPrivilege )
   ENDIF
RETURN nRet

STATIC FUNCTION DefUNZIPCB(nID, p1, p2, p3, p4, p5, p6, ;
                           p7, p8, p9, p10, p11, p12, p13)
   LOCAL xRet
   DO CASE
      CASE nID == WIZ_UNZIP_CB_ID_SOUND
	 //void WINAPI mysound(void)
	 // NON ha valore di ritorno

      CASE nID == WIZ_UNZIP_CB_ID_PRINT
	 // int WINAPI DisplayBuf(LPSTR buf, unsigned long size)
	 //p1=filename, p2=dimensione
         //? p1, p2
         xRet := p2

      CASE nID == WIZ_UNZIP_CB_ID_SVC
	 //int WINAPI ServCallBk(LPCSTR buf, unsigned long size)
	 //p1=filename, p2=dimensione
         //? p1, p2
         xRet := 0

      CASE nID == WIZ_UNZIP_CB_ID_PWD
          // int WINAPI password(char *p, int n, const char *m, const char *name)
          //p1, p2, p3, p4
          xRet := 1

      CASE nID == WIZ_UNZIP_CB_ID_REPLACE
	  // int WINAPI GetReplaceDlgRetVal(char *filename)
          // p1 = Filename
          xRet := 1

      CASE nID == WIZ_UNZIP_CB_ID_MESSAGE
          // chiamata se nnvflag = 1
          // NON ha valore di ritorno
          // void WINAPI ReceiveDllMessage(unsigned long ucsize, unsigned long csiz,
          //     unsigned cfactor,
          //     unsigned mo, unsigned dy, unsigned yr, unsigned hh, unsigned mm,
          //     char c, LPSTR filename, LPSTR methbuf, unsigned long crc, char fCrypt)
 
   ENDCASE
RETURN xRet


//////////////////////////////////////////////////////
//Luca 15/12/2014
//Funzione sostitutiva dell'unZIP da attivare con un settagio. Essa utilizza le funzioni di Windows per fare unzip
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
FUNCTION dfNewWinUnZip(cFile, cPathOut )
  LOCAL oZip       := CreateObject("Shell.Application","localhost")
  LOCAL xRet       := 1
  LOCAL oZipItem  
  LOCAL aFileinZip
  LOCAL isFolder
  LOCAL nCount
  LOCAL oItem
  LOCAL cName
  LOCAL cNew

  //dfalert("1- New Windows Unzip Function:" +cFile)

  IF !(dfChkDir(cPathOut) .OR. _S2MD(cPathOut) == 0)
     dfalert("Directory non creata di output: " +cPathOut)
     RETURN xRet
  ENDIF 

  cNew := dfTemp() + dfFNameSplit(cFILE, 4)+ ".zip"
  dfFileCopy(cFILE, cNew, .f., .F.)
  cFile       := cNew 
  IF !File(cFile) 
     dfalert("File non copiato per Unzip!")
     xRet := 1
     RETURN xRet 
  ENDIF 
  //dfalert(cFile)
  //dfalert(cPathOut)


  oZipItem    := oZip:NameSpace(cFile)
  aFileinZip  := oZipItem:Items() 

  oZipItem    := oZip:NameSpace(cPathOut)
  oZipItem:CopyHere(aFileinZip, 16 ) //16 indica che deve sovrascrivere senza chiedere i file trovati.

  nCount   := aFileinZip:Count()

  xRet := 1
  IF nCount == 0
     FERASE(cNew)
     RETURN xRet 
  ENDIF 

  oItem    := aFileinZip:Item(0)
  cName    := oItem:name
  isFolder := oItem:isFolder()

  IF nCount == 0
     FERASE(cNew)
     RETURN xRet 
  ENDIF 

  //dfalert("2- New Windows Unzip Function:" +cName)

  IF isFolder
     cName := dfpathchk(dfpathchk(cPathOut)+ cName)
     IF dfChkDir(cName) 
        xRet := 0
     ELSE
        xRet := 1
     ENDIF 
  ELSE 
     cName :=  dfpathchk(cPathOut)+ cName

     IF File(cName) 
        xRet := 0
     ELSE
        xRet := 1
     ENDIF 
  ENDIF 
  FERASE(cNew)
  //dfalert(xRet)

RETURN xRet 

// Come la dfMd, pero' funziona anche se l'ultimo carattere e' un "\"
STATIC FUNCTION _S2Md(cDir)

   cDir := dfPathChk(cDir)                      // Normalizza il PATH
                                                // (con "\" finale)

   IF LEN(cDir) > 3                             // Se non e' la dir. radice
      cDir := LEFT(cDir, LEN(cDir) - 1)         // Toglie "\" finale
   ENDIF

RETURN dfMd(cDir)

//////////////////////////////////////////////////////
//////////////////////////////////////////////////////

