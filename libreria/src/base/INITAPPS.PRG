//*****************************************************************************
//Progetto       : dBsee 4.4
//Descrizione    : Funzioni di Inizializzazione
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "FileIO.ch"
#include "dfMsg.ch"
#include "dfMsg1.ch"
#include "dfSet.ch"
#include "dfDac.ch"

ANNOUNCE InitdBsee

#define INIT_PAL                  1
#define INIT_NAME                 2
#define INIT_HANDLE               3
#define INIT_ROW                  4
#define INIT_COL                  5
#define INIT_BLINK                6
#define INIT_OK                   7
#define INIT_BEAUTY               8
#define INIT_CRONO                9
#define INIT_LOADCOLOR           10
#define INIT_AUTHOR              11
#define INIT_FAST                12
#define INIT_PATH                13
#define INIT_WIN95               14
#define INIT_MOUSEVGAOFF         15
#define INIT_50ROWFORM           16
#define INIT_FASTPALETTE         17
#define INIT_SILENT              18
#define INIT_MACRO               19
#define INIT_MACROACT            19][1
#define INIT_MACROFILE           19][2
#define INIT_MACROHANDLE         19][3
#define INIT_MACROCOUNT          19][4
#define INIT_FORCEMOUSEVGA       20
#define INIT_ALTERNATEFONTLOAD   21
#define INIT_LOCALINI            22
#define INIT_TERMINAL            23

STATIC aInit := { NIL           ,; // INIT_PAL
                  ""            ,; // INIT_NAME
                  F_ERROR       ,; // INIT_HANDLE
                  NIL           ,; // INIT_ROW
                  NIL           ,; // INIT_COL
                  NIL           ,; // INIT_BLINK
                  .T.           ,; // INIT_OK
                  .F.           ,; // INIT_BEAUTY
                  .F.           ,; // INIT_CRONO
                  .T.           ,; // INIT_LOADCOLOR
                  .F.           ,; // INIT_AUTHOR
                  .F.           ,; // INIT_FAST
                  ""            ,; // INIT_PATH
                  .F.           ,; // INIT_WIN95
                  .F.           ,; // INIT_MOUSEVGAOFF
                  .F.           ,; // INIT_50ROWFORM
                  .F.           ,; // INIT_FASTPALETTE
                  .F.           ,; // INIT_SILENT
                  {NIL,NIL,0,0} ,; // INIT_MACRO
                  .F.           ,; // INIT_FORCEMOUSEVGA
                  .F.           ,; // INIT_ALTERNATEFONTLOAD
                  .F.           ,; // INIT_LOCALINI
                  .F.            } // INIT_TERMINAL

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
INIT PROCEDURE InitApps( cPath ) // Apre il File dbStart.ini
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL cIni := dfIniName(), nPar, nSec

nSec := SECONDS()

FOR nPar := 0 TO dfArgC()
   IF UPPER(dfArgV(nPar))=="//INFO"
   #ifdef __XPP__
      dbMsgErr( dfVer() )
   #else
      ?? dfVer()
   #endif
   ENDIF
   IF ".INI"$UPPER(dfArgV(nPar))
      cPath := UPPER(dfArgV(nPar))
   ENDIF
   IF UPPER(dfArgV(nPar))=="/FAST"
      aInit[INIT_FAST] := .T.
   ENDIF
   IF UPPER(dfArgV(nPar))=="/BEAUTY"
      aInit[INIT_BEAUTY] := .T.
   ENDIF
   IF UPPER(dfArgV(nPar))=="/DEFCOLOR"
      aInit[INIT_LOADCOLOR] := .F.
   ENDIF
   IF UPPER(dfArgV(nPar))=="/CRONO"
      aInit[INIT_CRONO] := .T.
   ENDIF
   IF UPPER(dfArgV(nPar))=="/AUTHOR"
      aInit[INIT_AUTHOR] := .T.
   ENDIF
   IF UPPER(dfArgV(nPar))=="/WIN95INTERFACE"
      aInit[INIT_WIN95] := .T.
   ENDIF
   IF UPPER(dfArgV(nPar))=="/MOUSEVGAOFF"
      aInit[INIT_MOUSEVGAOFF] := .T.
   ENDIF
   IF UPPER(dfArgV(nPar))=="/50ROWFORM"
      aInit[INIT_50ROWFORM] := (.T. .AND. MAXROW()>=49)
   ENDIF
   IF UPPER(dfArgV(nPar))=="/FASTPALETTE"
      aInit[INIT_FASTPALETTE] := .T.
   ENDIF
   IF UPPER(dfArgV(nPar))=="/SILENT"
      aInit[INIT_SILENT] := .T.
   ENDIF
   IF UPPER(dfArgV(nPar))=="/FORCEMOUSEVGA"
      aInit[INIT_FORCEMOUSEVGA] := .T.
   ENDIF
   IF UPPER(dfArgV(nPar))=="/ALTERNATEFONTLOAD"
      aInit[INIT_ALTERNATEFONTLOAD] := .T.
   ENDIF
   IF LEFT( UPPER(dfArgV(nPar)), 4 )=="/REC"
      aInit[INIT_MACROACT]  := .T.
      aInit[INIT_MACROFILE] := SUBSTR(dfArgV(nPar),6)
      IF EMPTY( aInit[INIT_MACROFILE] )
         aInit[INIT_MACROFILE] := dfNameUnique()
      ENDIF
   ENDIF
   IF LEFT( UPPER(dfArgV(nPar)), 5 )=="/PLAY"
      aInit[INIT_MACROACT]  := .F.
      aInit[INIT_MACROFILE] := SUBSTR(dfArgV(nPar),7)
   ENDIF
   IF UPPER(dfArgV(nPar))=="/FORCELOCALINI"
      aInit[INIT_LOCALINI]  := .T.
   ENDIF
   IF UPPER(dfArgV(nPar))=="/TERMINAL"
      aInit[INIT_TERMINAL]  := .T.
   ENDIF
NEXT

dfInitVar() // Crea le PUBLIC dell'applicazione

//Dalla versione 1.6.8 � stato disabilitato.
//IF cPath!=NIL .AND. (ALLTRIM(cPath)=="/?" .OR. UPPER(ALLTRIM(cPath))=="/H")
//   dfInfoApps()
//ENDIF

IF dfUseIni()   // USO L'INI
   aInit[INIT_NAME] := cPath         // file da cercare
   DEFAULT aInit[INIT_NAME] TO cIni

   // E' un INI e NON esiste
   IF ".INI"$UPPER( aInit[INIT_NAME] )
      IF !FILE( aInit[INIT_NAME] )
         IF aInit[INIT_NAME]#cIni; dfIniErr(); ENDIF
         aInit[INIT_NAME] := dfPathChk( GETENV( "dbStart" ) ) +cIni
      ENDIF
   ELSE
      aInit[INIT_NAME] := cIni
   ENDIF

   IF !(!FILE( aInit[INIT_NAME] ) .AND. UPPER(aInit[INIT_NAME])==cIni)
      dfIniOpen()               // Apro il File Col salto dei commenti
      IF !dfIsIni(); dfIniErr(); ENDIF
   ENDIF
ENDIF

IF aInit[INIT_LOCALINI]
   aInit[INIT_PATH] := ""
ELSE
   aInit[INIT_PATH] := LEFT( aInit[INIT_NAME], RAT( "\", aInit[INIT_NAME] ) )
ENDIF

SET DELETED    ON            // Tolgo i Record Cancellati
#ifndef __XPP__
SET CURSOR     OFF           // Spengo il Cursore
#endif
SET SCOREBOARD OFF           // Spengo i messaggi della GetSys
SET CONFIRM    ON            // Conferma nell get

IF aInit[INIT_FASTPALETTE]
   dfDacChoise( DAC_DIRECT )
ENDIF

#ifndef __XPP__
IF !dBsee45Win()
   aInit[INIT_ROW]   := MAXROW()   // Memorizzo row & col attuali
   aInit[INIT_COL]   := MAXCOL()
   aInit[INIT_BLINK] := SETBLINK() // Memorizzo SET BLINK
ENDIF
#endif

#ifdef __XPP__
dfInitScreenOn()
dfXbaseIni()
#endif


IF dfUseIni()   // USO L'INI
   IF !( ALLTRIM(UPPER(dfNumVer())) == ALLTRIM(UPPER(dfSet(AI_INIVERSION))) )
      #ifdef __XPP__
      dbMsgErr( aInit[INIT_NAME] +"//" +dfStdMsg(MSG_DFINI01) +"//" +dfStdMsg(MSG_DFINI02) )
      #else
      ALERT( aInit[INIT_NAME] +";"  +dfStdMsg(MSG_DFINI01) +";"  +dfStdMsg(MSG_DFINI02) )
      #endif
      QUIT
   ENDIF
ENDIF

IF dfExitApps()
   //Gerr 3855 Luca 24/07/03
   #ifdef __XPP__
   dfalert( dfStdMsg1( MSG1_INITAPPS01 ) +"//"+;
   dfStdMsg1( MSG1_INITAPPS02 )          +"//"+;
   dfStdMsg1( MSG1_INITAPPS03 ))
   #else
   ? dfStdMsg1( MSG1_INITAPPS01 )
   ? dfStdMsg1( MSG1_INITAPPS02 )
   ? dfStdMsg1( MSG1_INITAPPS03 )
   #endif
   QUIT
ENDIF

IF aInit[INIT_SILENT]
   dfSet( AI_CLEARSCREEN, .F. )
   dfSet( AI_INIMESSAGE , .F. )
ENDIF

IF dfSet( AI_CLEARSCREEN )
   #ifndef __XPP__
   SET COLOR TO dfSet( AI_SCREENCOLOR )
   CLS
   #endif
ENDIF

dfSet( AI_WIN95INTERFACE, aInit[INIT_WIN95]     )
dfSet( AI_50ROWFORM,      aInit[INIT_50ROWFORM] )

dfArrCol( aInit[INIT_LOADCOLOR] ) // Carico Palette
dfArrFont()                       // Carico i Font

IF dfSet( AI_CLEARSCREEN )
   dfBkg()
ENDIF

dfArrAct()                        // Carico le Action
dfArrPrn()                        // Array delle stampanti
dfArrPor()                        // Array delle porte fisiche
dfArrPath()                       // Array dei PATH dell'applicazione
dfArrRep()                        // Array dei profili di stampa
dfIniClose()                      // Chiudo il file di Configurazione
dfErrorSys()                      // Gestione degli errori da libreria

IF aInit[INIT_CRONO]
   dbMsgErr( dfStdMsg1( MSG1_INITAPPS04 ) +dfAny2Str( SECONDS()-nSec ) )
ENDIF

IF aInit[INIT_AUTHOR]
   __author()
ENDIF
dfMouAct()                        // Caricamento in memoria del mouse

#ifdef __XPP__
dfInitScreenOff()
#endif

RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
PROCEDURE dfIniOpen()            // Apre il file di INI
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
IF aInit[INIT_HANDLE] > 0
   RETURN
ENDIF 
aInit[INIT_HANDLE] := dfFOpen( aInit[INIT_NAME], FO_READ +FO_DENYWRITE,,,.T. )
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
PROCEDURE dfIniClose()           // Chiude il file di INI
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
dfFClose( aInit[INIT_HANDLE] )
aInit[INIT_HANDLE] := F_ERROR
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfIsIni()              // Riporto se e' selezionato il file di config
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN aInit[INIT_HANDLE]!=F_ERROR

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfInitSelect()         // Seleziono il file di configurazione
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN dfFSelect( aInit[INIT_HANDLE] )

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfInitName()           // Nome del file di INI col path
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN aInit[INIT_NAME]

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfInitPath( cNewPath ) // PATH del file di INI
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAl cRet := aInit[INIT_PATH]

IF cNewPath!=NIL
   aInit[INIT_PATH] := dfPathChk( cNewPath )
   aInit[INIT_NAME] := aInit[INIT_PATH] +dfFindName( aInit[INIT_NAME] ) +".INI"
ENDIF

RETURN cRet

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfInitBeauty()         // Start with /BEAUTY
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN aInit[INIT_BEAUTY]

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfInitFast()           // Start with /FAST
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN aInit[INIT_FAST]

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfInitMouOff()         // Mouse VGA OFF
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN aInit[INIT_MOUSEVGAOFF]

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfRecMacro()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN aInit[INIT_MACROACT]==.T.

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfRecPlay()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN aInit[INIT_MACROACT]==.F.

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
PROCEDURE dfRecStop()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
aInit[INIT_MACROACT]:=NIL
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
PROCEDURE dfRecStart()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
aInit[INIT_MACROACT]:=.F.
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfForceVGA()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN aInit[INIT_FORCEMOUSEVGA]

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfAltFont()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN aInit[INIT_ALTERNATEFONTLOAD]

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfIsTerminal()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN aInit[INIT_TERMINAL]

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfRecGet()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL nKey := 0, cBuff := "  "

IF dfRecPlay()
   // File open
   IF aInit[INIT_MACROHANDLE]==0 .AND. !EMPTY(aInit[INIT_MACROFILE])
      aInit[INIT_MACROHANDLE] := FOPEN( aInit[INIT_MACROFILE] )
   ENDIF

   IF aInit[INIT_MACROHANDLE]>0
      IF aInit[INIT_MACROCOUNT]>0
         nKey := 0
         aInit[INIT_MACROCOUNT]--
      ELSE
         nKey := FREAD( aInit[INIT_MACROHANDLE], @cBuff, 2 )
         IF nKey==2
            IF RIGHT(cBuff,1)==CHR(127)
               aInit[INIT_MACROCOUNT] := ASC(LEFT(cBuff,1))-1
               nKey := 0
            ELSE
               nKey := BIN2I(cBuff)
            ENDIF
         ELSE
            nKey := -999
         ENDIF
      ENDIF
   ENDIF
ENDIF

RETURN nKey

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
PROCEDURE dfRecPut( nKey )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL cBuff := "  "

IF dfRecMacro()
   // File open
   IF aInit[INIT_MACROHANDLE]==0 .AND. !EMPTY(aInit[INIT_MACROFILE])
      aInit[INIT_MACROHANDLE] := FCREATE( aInit[INIT_MACROFILE] )
   ENDIF

   IF aInit[INIT_MACROHANDLE]>0
      IF nKey==0
         aInit[INIT_MACROCOUNT]++
      ELSE
         IF aInit[INIT_MACROCOUNT]>0
            WHILE aInit[INIT_MACROCOUNT]>0
               IF aInit[INIT_MACROCOUNT]>255
                  aInit[INIT_MACROCOUNT]-=255
                  FWRITE( aInit[INIT_MACROHANDLE], CHR(255)+CHR(127), 2 )
               ELSE
                  FWRITE( aInit[INIT_MACROHANDLE], CHR(aInit[INIT_MACROCOUNT])+CHR(127), 2 )
                  aInit[INIT_MACROCOUNT] := 0
               ENDIF
            ENDDO
         ENDIF
         cBuff := I2BIN(nKey)
         FWRITE( aInit[INIT_MACROHANDLE], cBuff, 2 )
      ENDIF
   ENDIF
ENDIF

RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
PROCEDURE dfSavePal()           // Salvataggio Palette
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
aInit[INIT_PAL] := dfDacSave()
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfExitApps()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
RETURN dfSet( AI_EXITAPPS ) .AND. FILE(dfExePath()+"dbupdate.log")

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC PROCEDURE dfIniErr()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
#ifdef __XPP__
dfAlert( dfStdMsg( MSG_INITERROR ) +" " +aInit[INIT_NAME] )
#else
? dfStdMsg( MSG_INITERROR ) +" " +aInit[INIT_NAME]
#endif
RETURN

#ifndef __XPP__
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
EXIT PROCEDURE ExitApps()       // Chiudo il file di configurazione
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
#ifdef __HARBOUR__
dfFontRemove()
dfActRemove()
#endif
IF aInit[INIT_OK]
   IF aInit[INIT_MACROHANDLE]>0
      FCLOSE( aInit[INIT_MACROHANDLE] )
   ENDIF
   IF !dBsee45Win()
      SET CURSOR OFF
      IF aInit[INIT_PAL]!=NIL             // Ripristino Palette
         dfDacRest( aInit[INIT_PAL] )
      ENDIF
      dfMouRel()                          // Resetta il Mouse
      dfFontRest()                        // Resetta i Font
      SETMODE( aInit[INIT_ROW]+1, aInit[INIT_COL]+1 ) // Sistemo le righe
      SETBLINK( aInit[INIT_BLINK] )       // Risistemo SET BLINK
      SET CURSOR ON
   ENDIF
ENDIF
RETURN
#endif

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
STATIC PROCEDURE dfInfoApps()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL cName := dfExeName(), cStr := ""
cName := SUBSTR( cName, RAT("\",cName)+1 )
#ifdef __XPP__
cStr += dfExeName()                                         +"//"
cStr += STRTRAN( dfStdMsg(MSG_INFO08), "%VER%", dfNumVer() )+"//"
cStr += "//"
cStr += dfStdMsg(MSG_INFO01) +" " +cName +" " +dfStdMsg(MSG_INFO02) +"//"
cStr += "//"
cStr += dfStdMsg(MSG_INFO03) +"//"
cStr += dfStdMsg(MSG_INFO04) +"//"
cStr += dfStdMsg(MSG_INFO07) +"//"
cStr += "           /BEAUTY             /WIN95INTERFACE//"
cStr += "           /DEFCOLOR           /FASTPALETTE//"
cStr += "           /MOUSEVGAOFF        /50ROWFORM//"
cStr += "           /SILENT             /DOCTOR//"
cStr += "           /FORCEMOUSEVGA      /ALTERNATEFONTLOAD//"
cStr += "           /REC:<filename>     /PLAY:<filename>//"
cStr += "           /FORCELOCALINI      /TERMINAL//"
cStr += "//"
cStr += dfStdMsg(MSG_INFO05) +"//"
cStr += dfStdMsg(MSG_INFO06) +"//"
dfSet( AI_XBASEMESSAGECENTERED, .F. )
dbMsgErr(cStr)
#else
? "谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�"
? "巢卑" +PADC( dfExeName()                                         , 71 )  +"氨渤"
? "巢卑" +PADC( STRTRAN( dfStdMsg(MSG_INFO08), "%VER%", dfNumVer() ), 71 )  +"氨渤"
? "滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�"
? ""
? dfStdMsg(MSG_INFO01) +" " +cName +" " +dfStdMsg(MSG_INFO02)
? ""
? dfStdMsg(MSG_INFO03)
? dfStdMsg(MSG_INFO04)
? dfStdMsg(MSG_INFO07)
? "           /BEAUTY             /WIN95INTERFACE"
? "           /DEFCOLOR           /FASTPALETTE"
? "           /MOUSEVGAOFF        /50ROWFORM"
? "           /SILENT             /DOCTOR"
? "           /FORCEMOUSEVGA      /ALTERNATEFONTLOAD"
? "           /REC:<filename>     /PLAY:<filename>"
? "           /FORCELOCALINI      /TERMINAL"
? ""
? dfStdMsg(MSG_INFO05)
? dfStdMsg(MSG_INFO06)
? ""
#endif
aInit[INIT_OK] := .F.
QUIT
RETURN
