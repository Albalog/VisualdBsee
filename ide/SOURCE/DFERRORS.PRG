//*****************************************************************************
//Progetto       : dBsee 5.0
//Descrizione    : Error System
//Programmatore  : Baccan Matteo
//*****************************************************************************
//
//      Errorsys.prg
//      Standard xbase error handler

#include "error.ch"
#include "Fileio.ch"
#include "Common.ch"
#include "Set.ch"
#include "dfSet.ch"
#include "dfmsg.ch"
#include "dfstd.ch"
#include "dmlb.ch"
#include "NTXDBE.CH"
#include "DBFDBE.CH"
#include "thread.ch"
#include "xbp.ch"
#include "class.ch"

// put messages to STDERR
#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)

// used below
#define NTRIM(n)                ( LTrim(Str(n)) )

#define INSPECT_MAX_LEVEL           4
#define INSPECT_MAX_OBJ_ELEMENTS   32
#define INSPECT_MAX_ARR_ELEMENTS  128

//#define CRLF          CHR(13)+CHR(10)

STATIC cLog    := NIL
STATIC nHandle := 0


#define EHS_CANCEL            "Cancel"
#define EHS_EXIT_WITH_LOG     "Exit with LOG file"
#define EHS_RETRY             "Retry"
#define EHS_IGNORE            "Ignore"
#define EHS_OS_ERROR          ";Operating system error : "
#define EHS_CALLED_FROM       "Called from"
#define EHS_XPP_ERROR_MESSAGE "Xbase++ Error Message"
#define EHS_ERROR             "Error "
#define EHS_WARNING           "Warning "
#define EHS_DESCRIPTION       ";Description : "
#define EHS_FILE              ";File : "
#define EHS_OPERATION         ";Operation : "
#define EHS_LOG_OPEN_FAILED   "Unable to open error log file"
#define EHS_ERROR_LOG_OF      "ERROR LOG of "
#define EHS_DATE              " Date:"
#define EHS_XPP_VERSION       "Xbase++ version     :"
#define EHS_OS_VERSION        "Operating system    :"
#define EHS_LOG_WRITTEN_TO(cFile) "Error log was written to the file "+ cFile

#define EHS_STEPRECORDER      "Creating step recorder file..."

STATIC FUNCTION _GetLogFName()
RETURN dfSet( AI_LOGFILE )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfOpenErr()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

dfCloseErr()

IF !FILE( _GetLogFName() )
   FCLOSE(FCREATE( _GetLogFName() ))
ENDIF
nHandle := FOPEN( _GetLogFName(), FO_READWRITE )
IF nHandle>0
   FSEEK( nHandle, 0, FS_END )
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfCloseErr()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF nHandle>0
   FCLOSE(nHandle)
   nHandle:=0
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfLogMsg( cMsg, lInfo )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DEFAULT lInfo TO .F.
dfOpenErr()
IF lInfo
   dfLogWrite( STR(SECONDS()) )
   dfLogWrite( "³(" +STR(PROCLINE(2),4) +")" +PADR(PROCNAME(2),10) +"->" )
   dfLogWrite( "(" +STR(PROCLINE(1),4) +")" +PADR(PROCNAME(1),10) +"³"  )
ENDIF
dfLogWrite( cMsg +CRLF )
dfCloseErr()
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfLogWrite( cMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

IF cLog!=NIL
   cLog += cMsg
ENDIF

IF nHandle>0
   FWRITE(nHandle,cMsg)
ENDIF

RETURN


//
//       ErrorSys()
//
//       Note:  automatically executes at startup
//

** Spostata in un OBJ separato per problemi con RTlink
** ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*PROCEDURE ErrorSys()
** ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfErrorSys()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
    ErrorBlock( {|e| dfError(e)} )
RETURN

// Prevent error in _dfError() function
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfError(e)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

// With Xbase add this code to prevent error during errorsys
LOCAL bErrorHandler := ErrorBlock( {|e| dfErrBreak(e, NIL, .T.)} )
LOCAL lRet          := .F.
LOCAL err

BEGIN SEQUENCE
   lRet := _dfError(e)

RECOVER USING err
   // errore in gestione errore?
   IF err:cargo != NIL
      dfErrLog(err, NIL, "-VER-ERROR-STACK-")
      MsgBox( dfStdMsg( MSG_ERRSYS15 )+CRLF+_GetLogFName())
      QUIT
   ENDIF
ENDSEQUENCE

ErrorBlock( bErrorHandler )

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION _dfError(e)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL i, cMessage, aOptions, nChoice, cErr
LOCAL lDefault, xRet
LOCAL oSession
LOCAL oDacSession

   // posso gestirla di default senza dare errore?
   xRet := dfErrHandleDefault(e, @lDefault)
   IF lDefault
      RETURN (xRet)
   ENDIF

   oSession := DbSession()
   IF oSession = NIL .AND. IsFunction("DacSession", FUNC_CLASS)
      oDacSession := &("DacSession()")
      oSession := oDacSession:getDefault()
   ENDIF
   IF oSession == NIL
      IF EMPTY(e:thread)
         oSession := dfAXSSession(NIL, ThreadID())
      ELSE
         oSession := dfAXSSession(NIL, e:thread)
ENDIF
             ENDIF
   IF oSession != NIL
       IF oSession:getLastError() != 0
           e:cargo := {e:cargo, ;
                            oSession:getLastError(),;
                            oSession:getLastMessage() }
          ENDIF
      ENDIF


// build error message
cMessage := ErrorMessage(e)
//
//-> Punto migliore per inviare email con info dell'errore generato (cMessage contiene le info da inserire nell'email)
//
cLog := "" // Inizia a loggare sulla variabile
// scrive su file l'errore
dfErrLog(e, cMessage)
IF dfSet( AI_ERRORCB )!=NIL
   EVAL( dfSet( AI_ERRORCB ), e, cLog )
ENDIF
cLog := NIL

// mostra errore
dfErrAlert(e, cMessage)

return .f.

// by reference torna nome file
STATIC FUNCTION dfErrSaveScreen(cPath)
   LOCAL oBmp
   LOCAL aName
   LOCAL l := .F.
   LOCAL nHandle

   oBmp := dfScreenCapture()

   IF VALTYPE(oBmp)=="O"
      aName := dfFnameSplit( _getLogFName() )
      cPath := aName[1]+aName[2]
      nHandle:= dfFileTemp(@cPath, aName[3], LEN(aName[3])+4, ".jpg") 
      IF nHandle != -1
         FCLOSE(nHandle)
         FERASE(cPath)
         l := oBmp:saveFile(cPath, XBPBMP_FORMAT_JPG, 60)
   ENDIF
ENDIF
RETURN l

// simone 13/11/09
// mantis 0002109: abilitare step recorder tipo Windows 7 
// by reference torna nome file
STATIC FUNCTION dfErrSaveStepRecorder(cPath)
   LOCAL aName
   LOCAL l := .F.
   LOCAL nHandle

   aName := dfFnameSplit( _getLogFName() )
   cPath := aName[1]+aName[2]
   nHandle:= dfFileTemp(@cPath, aName[3]+"rec", LEN(aName[3]+"rec")+4, ".zip") 
   IF nHandle != -1
      FCLOSE(nHandle)
      FERASE(cPath)
      dfWaitOn(EHS_STEPRECORDER)
      IF dfStepRecorderSave(cPath)==0
         l:=.T.
      ENDIF
      dfWaitOff()
   ENDIF
RETURN l


FUNCTION VDBErrorMessage(oErr, cSep, lArgs, lCargo)
   LOCAL cRet
   LOCAL i

   DEFAULT cSep       TO CRLF
   DEFAULT lArgs      TO .F.
   DEFAULT lCargo     TO .F.

   cRet := STRTRAN(ErrorMessage(oErr),"//",cSep)
   IF ! EMPTY(oErr:args) .AND. lArgs
      cRet += cSep + "Args: "+VAR2CHAR(oErr:args)
   ENDIF

   IF VALTYPE(oErr:cargo) $ "CM" .AND. lCargo 
      // aggiungo cargo (contiene il callstack)
      // vedi dfErrBreak()
      cRet += cSep+oErr:cargo
   ENDIF
RETURN cRet

//
//      ErrorMessage()
//
static function ErrorMessage(e)
local cMessage


        // start error message
        cMessage := if( e:severity > ES_WARNING, dfStdMsg(MSG_ERRSYS76), dfStdMsg(MSG_ERRSYS77) )


        // add subsystem name if available
        if ( ValType(e:subsystem) == "C" )
                cMessage += e:subsystem
        else
                cMessage += "???"
        end


        // add subsystem's error code if available
        if ( ValType(e:subCode) == "N" )
                cMessage += ("/" + NTRIM(e:subCode))
        else
                cMessage += "/???"
        end


        // add error description if available
        if ( ValType(e:description) == "C" )
                cMessage += ("  " + e:description)
        end


        // add either filename or operation
        if ( !Empty(e:filename) )
           cMessage += ("//file: " + e:filename)
   endif
   if ( !Empty(e:operation) )
           cMessage += ("//operation: " + e:operation)

        end

        /* Add Thread ID of the thread on which the error occured */
   cMessage += "//(Error Thread ID: " +LTrim(Str(e:thread)) + " current: "+LTrim(Str(ThreadID()))+")"

   IF ! Empty( e:osCode )
      cMessage +=  "//(" +dfStdMsg( MSG_ERRSYS73 ) +" " + LTrim(Str(e:osCode)) +;
                  " - " + DosErrorMessage(e:osCode) +")"
   ENDIF

   IF Valtype(e:cargo)="A" .AND. len(e:cargo) == 3
      IF ValType(e:cargo[1])=="C"
         cMessage += __LineSplit(e:cargo[1], 50)
      ENDIF
      cMessage += __LineSplit(e:cargo[3], 50)
   ENDIF
return (cMessage)

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfErrError( e )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

dfLogWrite( "Error Information"                            +CRLF )
dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"                            +CRLF )
dfLogWrite( "GenCode       : " +dfAny2Str(e:GenCode      ) +CRLF )
dfLogWrite( "SubCode       : " +dfAny2Str(e:SubCode      ) +CRLF )
dfLogWrite( "SubSystem     : " +dfAny2Str(e:SubSystem    ) +CRLF )
dfLogWrite( "Severity      : " +dfAny2Str(e:Severity     ) +CRLF +CRLF )

dfLogWrite( "CanDefault    : " +dfAny2Str(e:CanDefault   ) +CRLF )
dfLogWrite( "CanRetry      : " +dfAny2Str(e:CanRetry     ) +CRLF )
dfLogWrite( "CanSubstitute : " +dfAny2Str(e:CanSubstitute) +CRLF +CRLF )
dfErrArgs(e)

#ifdef __XPP__
dfLogWrite( "Current Thread: " +dfAny2Str(ThreadID()     ) +CRLF )
dfLogWrite( "Error Thread  : " +dfAny2Str(e:Thread       ) +CRLF )
#endif
dfLogWrite( "Cargo         : " +dfAny2Str(e:Cargo        ) +CRLF )
dfLogWrite( "Description   : " +dfAny2Str(e:Description  ) +CRLF )
dfLogWrite( "Filename      : " +dfAny2Str(e:Filename     ) +CRLF )
dfLogWrite( "Operation     : " +dfAny2Str(e:Operation    ) +CRLF )
dfLogWrite( "OSCode        : " +dfAny2Str(e:OSCode       ) +CRLF )
dfLogWrite( "Tries         : " +dfAny2Str(e:Tries        ) +CRLF +CRLF )

RETURN


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfErrArgs(e)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL oItem
   LOCAL ctitle

   oItem := ErrItem():new()
   BuildTree(oItem, e:args)

   cTitle := "Args          : "

   ErrItem():recurse(oItem, {|o, nLev| dfLogWrite(PAD(cTitle, 16+2*nLev)+IIF(nLev==0, "", o:caption+CRLF)), ;
                                                  cTitle:="" })

RETURN NIL

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfErrMemory()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

dfLogWrite( "Memory Statistics"                            +CRLF )
dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"                            +CRLF )
dfLogWrite( "Variables space (0)                  : " +STR(MEMORY(  0)             )+" Kb" +CRLF )
dfLogWrite( "Largest string object (1)            : " +STR(MEMORY(  1)             )+" Kb" +CRLF )
dfLogWrite( "Free RUN memory (2)                  : " +STR(MEMORY(  2)             )+" Kb" +CRLF )
dfLogWrite( "Size of virtual (SVOS) memory (3)    : " +STR(MEMORY(  3)             )+" Kb" +CRLF )
dfLogWrite( "Size of available EMS Memory (4+105) : " +STR(MEMORY(  4) +MEMORY(105))+" Kb" +CRLF )
dfLogWrite( "Fixed Heap size (101)                : " +STR(MEMORY(101)             )+" Kb" +CRLF )
dfLogWrite( "Segments in fixed Heap (102)         : " +STR(MEMORY(102)             )+" Kb" +CRLF )
dfLogWrite( "Free memory for swapping (0+103)     : " +STR(MEMORY(  0) +MEMORY(103))+" Kb" +CRLF )
dfLogWrite( "Unused Conventional-Memory (104)     : " +STR(MEMORY(104)             )+" Kb" +CRLF  )
dfLogWrite( "DS Available                         : " +STR(dfDSAvail()             )+" Bytes" +CRLF +CRLF )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfErrDosEnv()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cDisk

dfLogWrite( "DOS Environment"                                   +CRLF )
dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"                                   +CRLF )
dfLogWrite( "OS Version             : " +OS()                   +CRLF )
IF !dfWinIsNT4()
  dfLogWrite( "Available File Handles : " +dfAny2Str(dfFreeHnd()) +CRLF )
ENDIF

// simone 29/11/06
// mantis 0001175: supportare percorsi UNC
cDisk := dfPathGet()
dfLogWrite( "Current Directory      : " +cDisk                  +CRLF )
dfLogWrite( "Temp Directory         : " +GETENV("TEMP")         +CRLF )
dfLogWrite( "COMSPEC Directory      : " +GETENV("COMSPEC")      +CRLF )
dfLogWrite( "PATH Environment       : " +GETENV("PATH")      +CRLF )
cDisk := dfFNameSplit(cDisk)
cDisk := dfPathChk(cDisk[1])  // mappatura rete o UNC
dfLogWrite( "Disk Space Available   : " +dfAny2Str(DiskSpace(cDisk),"@ZE 999,999,999,999") +CRLF )
dfLogWrite( "NETNAME()              : " +NETNAME()              +CRLF )
dfLogWrite( "DOSERROR()             : " +dfAny2Str(DOSERROR())  +CRLF )
dfLogWrite( "FERROR()               : " +dfAny2Str(FERROR())    +CRLF )
dfLogWrite( "ISPRINTER()            : " +dfAny2Str(ISPRINTER()) +CRLF )
dfLogWrite( "ALIAS()                : " +dfAny2Str(ALIAS())     +CRLF +CRLF )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfErrClpEnv()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

dfLogWrite( "Xbase Environment"                                 +CRLF )
dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"                               +CRLF )
dfLogWrite( "Alternate    : " +dfAny2Str(SET(_SET_ALTERNATE  )) +CRLF )
dfLogWrite( "Altfile      : " +dfAny2Str(SET(_SET_ALTFILE    )) +CRLF )
dfLogWrite( "Bell         : " +dfAny2Str(SET(_SET_BELL       )) +CRLF )
dfLogWrite( "Cancel       : " +dfAny2Str(SET(_SET_CANCEL     )) +CRLF )
dfLogWrite( "Confirm      : " +dfAny2Str(SET(_SET_CONFIRM    )) +CRLF )
dfLogWrite( "Console      : " +dfAny2Str(SET(_SET_CONSOLE    )) +CRLF )
dfLogWrite( "Dateformat   : " +dfAny2Str(SET(_SET_DATEFORMAT )) +CRLF )
dfLogWrite( "Decimals     : " +dfAny2Str(SET(_SET_DECIMALS   )) +CRLF )
dfLogWrite( "Default      : " +dfAny2Str(SET(_SET_DEFAULT    )) +CRLF )
dfLogWrite( "Deleted      : " +dfAny2Str(SET(_SET_DELETED    )) +CRLF )
dfLogWrite( "Delimchars   : " +dfAny2Str(SET(_SET_DELIMCHARS )) +CRLF )
dfLogWrite( "Delimiters   : " +dfAny2Str(SET(_SET_DELIMITERS )) +CRLF )
dfLogWrite( "Device       : " +dfAny2Str(SET(_SET_DEVICE     )) +CRLF )
dfLogWrite( "Epoch        : " +dfAny2Str(SET(_SET_EPOCH      )) +CRLF )
dfLogWrite( "Escape       : " +dfAny2Str(SET(_SET_ESCAPE     )) +CRLF )
dfLogWrite( "Exact        : " +dfAny2Str(SET(_SET_EXACT      )) +CRLF )
dfLogWrite( "Exclusive    : " +dfAny2Str(SET(_SET_EXCLUSIVE  )) +CRLF )
dfLogWrite( "Exit         : " +dfAny2Str(SET(_SET_EXIT       )) +CRLF )
dfLogWrite( "Extra        : " +dfAny2Str(SET(_SET_EXTRA      )) +CRLF )
dfLogWrite( "Extrafile    : " +dfAny2Str(SET(_SET_EXTRAFILE  )) +CRLF )
dfLogWrite( "Fixed        : " +dfAny2Str(SET(_SET_FIXED      )) +CRLF )
dfLogWrite( "Insert       : " +dfAny2Str(SET(_SET_INSERT     )) +CRLF )
dfLogWrite( "Intensity    : " +dfAny2Str(SET(_SET_INTENSITY  )) +CRLF )
dfLogWrite( "Margin       : " +dfAny2Str(SET(_SET_MARGIN     )) +CRLF )
dfLogWrite( "Mcenter      : " +dfAny2Str(SET(_SET_MCENTER    )) +CRLF )
dfLogWrite( "Message      : " +dfAny2Str(SET(_SET_MESSAGE    )) +CRLF )
dfLogWrite( "Path         : " +dfAny2Str(SET(_SET_PATH       )) +CRLF )
dfLogWrite( "Printer      : " +dfAny2Str(SET(_SET_PRINTER    )) +CRLF )
dfLogWrite( "Printfile    : " +dfAny2Str(SET(_SET_PRINTFILE  )) +CRLF )
dfLogWrite( "Scoreboard   : " +dfAny2Str(SET(_SET_SCOREBOARD )) +CRLF )
dfLogWrite( "Softseek     : " +dfAny2Str(SET(_SET_SOFTSEEK   )) +CRLF )
dfLogWrite( "Typeahead    : " +dfAny2Str(SET(_SET_TYPEAHEAD  )) +CRLF )
dfLogWrite( "Unique       : " +dfAny2Str(SET(_SET_UNIQUE     )) +CRLF )
dfLogWrite( "Wrap         : " +dfAny2Str(SET(_SET_WRAP       )) +CRLF +CRLF )

RETURN

// simone 13/11/09
// mantis 0002109: abilitare step recorder tipo Windows 7
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfAreasInspect()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL cRet := ""
   LOCAL aPrev:={cLog, nHandle}

   cLog:=""
   nHandle := 0

   dfErrAreas()

   cRet:=cLog

   cLog := aPrev[1]
   nHandle:=aPrev[2]
RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfErrAreas(cRet)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL i, cErr, cAlias, nIdx
LOCAL nOrd

dfLogWrite( "Database Informations" +CRLF )
dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" +CRLF )
dfLogWrite( "Default RDD    : " + dfAny2Str(RDDSETDEFAULT()) + CRLF )
dfLogWrite( "Table LOCKDELAY: " + dfAny2Str(DbeInfo(COMPONENT_DATA ,DBFDBE_LOCKDELAY)) + CRLF )
dfLogWrite( "Table LOCKRETRY: " + dfAny2Str(DbeInfo(COMPONENT_DATA ,DBFDBE_LOCKRETRY)) + CRLF )
dfLogWrite( "Index LOCKDELAY: " + dfAny2Str(DbeInfo(COMPONENT_ORDER,NTXDBE_LOCKDELAY)) + CRLF )
dfLogWrite( "Index LOCKRETRY: " + dfAny2Str(DbeInfo(COMPONENT_ORDER,NTXDBE_LOCKRETRY)) + CRLF )
dfLogWrite( CRLF )

dfLogWrite( "Open Areas" +CRLF )
dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄ" +CRLF )

dfLogWrite( "ÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" +CRLF )
dfLogWrite( "Alias   ³Recno  ³Workarea information                                          " +CRLF )
dfLogWrite( "ÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" +CRLF )
FOR i := 1 TO 250
   cAlias := (i)->(ALIAS())
   IF !EMPTY(cAlias)
      dfLogWrite( PADR(cAlias,8)+ IF(ALIAS()==cAlias, "*", "³") +;
                      PADL(NTRIM((i)->(RECNO())),7)+ "³"  )
      // log delle informazioni area
      dfLogWrite("SELECT: "+NTRIM( i ) +" INDEXORD: "+NTRIM( (i)->(INDEXORD()))+" ")
      dfLogWrite( IF( (i)->(DELETED()),"(DELETED) ","")+;
                  IF( (i)->(BOF())    ,"(BOF) "    ,"")+;
                  IF( (i)->(EOF())    ,"(EOF) "    ,"")+;
                  IF( (i)->(FOUND())  ,"(FOUND) "  ,"")+;
                  IF( !EMPTY((i)->(DBFILTER()))  ,"(FILTER) "  ,"")+;
                  IF( (i)->(DBLOCKED()) ,"(FILELOCK) "  ,"")+;
                  "("+(i)->(RDDNAME())+")"              )


      IF LEN( (i)->(dfLockList()) ) > 0
         dfLogWrite(CRLF+"        ³       ³(Locks: ("+NTRIM(LEN((i)->(dfLockList())))+") -> ")
         AEVAL((i)->(dfLockList()), {|r,n| dfLogWrite(NTRIM(r) +;
                                                       IIF(n<LEN( (i)->(dfLockList()) ), ",", "")) })
         dfLogWrite(")")
      ELSE
         dfLogWrite(" (No locks)")
      ENDIF

      // log tutti gli indici
      FOR nIdx:= 1 TO (i)->(OrdCount())
         cErr := "(" +NTRIM(nIdx) + IIF(nIdx==(i)->(INDEXORD()), "*", "")+") " +(i)->(ORDKEY(nIdx))
         IF ! EMPTY( (i)->(ORDFOR(nIdx)) )
            cErr += " FOR: "+(i)->(ORDFOR(nIdx))
         ENDIF

         nOrd := (i)->(INDEXORD())
         (i)->(DBSETORDER(nIdx))
         IF ! EMPTY( (i)->(DBSCOPE(SCOPE_TOP)) )
            cErr += " SCOPE TOP: "+(i)->(DBSCOPE(SCOPE_TOP))
         ENDIF
         IF ! EMPTY( (i)->(DBSCOPE(SCOPE_BOTTOM)) )
            cErr += " SCOPE BOTTOM: "+(i)->(DBSCOPE(SCOPE_BOTTOM))
         ENDIF
         (i)->(DBSETORDER(nOrd))
         dfLogWrite( CRLF +"        ³       ³" )
//         IF (i)->(INDEXORD())>0
//            cErr := "(" +NTRIM( ) +") " +(i)->(ORDKEY(INDEXORD()))
         WHILE .T.
            dfLogWrite( LEFT(cErr,62) )
            cErr := SUBSTR(cErr,63)
            IF LEN(cErr)>0
               dfLogWrite( CRLF +"        ³       ³" )
               LOOP
            ENDIF
            EXIT
         ENDDO
//         ENDIF
      NEXT

      IF ! EMPTY((i)->( DBFILTER() ))
         // log del filtro
         dfLogWrite( CRLF +"        ³       ³" )
         cErr := "FILTER: "+ (i)->( DBFILTER() )
         WHILE .T.
            dfLogWrite( LEFT(cErr,62) )
            cErr := SUBSTR(cErr,63)
            IF LEN(cErr)>0
               dfLogWrite( CRLF +"        ³       ³" )
               LOOP
      ENDIF
            EXIT
         ENDDO
      ENDIF

      // log del record
      dfLogWrite( CRLF +"        ³       ³" )
      cErr := (i)->( _currRec() )
      WHILE .T.
         dfLogWrite( LEFT(cErr,62) )
         cErr := SUBSTR(cErr,63)
         IF LEN(cErr)>0
            dfLogWrite( CRLF +"        ³       ³" )
            LOOP
         ENDIF
         EXIT
      ENDDO
      dfLogWrite(CRLF)
   ENDIF
NEXT

dfLogWrite( CRLF )

RETURN

STATIC FUNCTION _currRec()
   LOCAL i
   LOCAL cRet :=""
   LOCAL xVal
   LOCAL cSep := ""

   FOR i := 1 TO FCOUNT()
      xVal := TRIM( VAR2CHAR(FIELDGET(i)) )
      xVal := MEMOTRAN(xVal, " ", " ")
      IF LEN(xVal) > 45
         xVal := LEFT(xVal, 45)+"..."
      ENDIF
      xVal := cSep+FIELDNAME(i)+"=["+xVal+"]"
      cRet += xVal
      cSep := " "
   NEXT
RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfErrScr()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL c
#ifndef __XPP__
IF !dbsee45win()
   dfLogWrite( "Video Informations" +CRLF )
   dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" +CRLF )
   dfLogWrite( "Video Mode (" +NTRIM(MAXROW()+1) +" lines, " +NTRIM(MAXCOL()+1) +" cols)" +CRLF +CRLF )

   dfLogWrite( "Screen Capture" +CRLF  )
   dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" +CRLF  )

   dfLogWrite( dfScrCapT( .T. ) +CRLF )
ENDIF
#endif

   IF dfSet(AI_ERRORSAVESCREEN)
      IF dfErrSaveScreen(@c) .AND. ! EMPTY(c)
         dfLogWrite( "Screen Capture" +CRLF  )
         dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" +CRLF  )
         dfLogWrite( "Screen File: "+c +CRLF+CRLF  )
      ENDIF
   ENDIF

   // simone 13/11/09
   // mantis 0002109: abilitare step recorder tipo Windows 7 
   IF dfStepRecorderEnabled()
      IF dfErrSaveStepRecorder(@c) .AND. ! EMPTY(c)
         dfLogWrite( "Step Recorder" +CRLF  )
         dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" +CRLF  )
         dfLogWrite( "Step File: "+c +CRLF+CRLF  )
      ENDIF
   ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfErrExe()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cPar := "", nPar

dfLogWrite( "Executable" +CRLF  )
dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄ" +CRLF  )
dfLogWrite( "Name      : " +dfExeName() +CRLF  )
FOR nPar := 1 TO dfArgC()
   cPar += dfArgV( nPar ) +" "
NEXT
dfLogWrite( "Parameter : " +cPar +CRLF +CRLF )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfErrWin()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF dfIsWin()
   dfLogWrite( "Windows Informations" +CRLF  )
   dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" +CRLF  )
   dfLogWrite( "Windows Version   : " +dfWinVer() +CRLF  )
   dfLogWrite( CRLF +CRLF )
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfErrStack(e)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aTID, nTID, i
LOCAL nID

i := 3
IF ! EMPTY(e) .AND. IsMethod( e, "getCallstack" )
dfLogWrite( "Call Stack"                                +CRLF )
dfLogWrite( "ÄÄÄÄÄÄÄÄÄÄ"                                +CRLF )
   dfLogWrite( e:getCallstack( CRLF ) )
ELSE
   aTID := ThreadInfo( THREADINFO_TID )

   nTID := ThreadID()
   IF ASCAN(aTID, nTID)==0
      AADD(aTID, nTID)
   ENDIF

   IF ! EMPTY(e:thread)
      nTID := e:thread
      IF ASCAN(aTID, nTID)==0
         AADD(aTID, nTID)
      ENDIF
   ENDIF
 
   FOR nTId := 1 TO LEN(aTID)
      nID := aTID[nTID][1]
      dfLogWrite( "Call Stack thread "+NTRIM(nID) )

      i := 0
      IF nID == ThreadID()
         dfLogWrite( " (current)")
i := 3
      ENDIF
      IF ! EMPTY(e:thread) .AND. nID == e:thread
         dfLogWrite( " (error)")
      ENDIF

      dfLogWrite( CRLF+"ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"+CRLF )
      while ( !Empty(ProcName(i, nID)) )
              dfLogWrite( "+ " +dfStdMsg(MSG_ERRSYS75) +" "+ Trim(ProcName(i, nID)) + ;
                                    "(" + NTRIM(ProcLine(i, nID)) + ")" +CRLF)
        i++
end
      dfLogWrite( CRLF )
   NEXT
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfErrVer( cMessage )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfLogWrite( "þ Error       : Date " +PADR(DTOC(DATE()),10) +"                                   Time " +TIME() +CRLF )
dfLogWrite( "þ Clipper     : " +VERSION()               +CRLF )
dfLogWrite( "þ Library     : " +dfVer()                 +CRLF )
dfLogWrite( REPLICATE("Ä",79)                           +CRLF )
dfLogWrite( "Extend Error  : " +STRTRAN(cMessage,"//", CRLF+"                ") +CRLF +CRLF )
RETURN


FUNCTION dfDefaultErrChk(e)
RETURN ValType(e:subsystem) == "C" .AND. ;
       e:subsystem == "BASE" .AND. ;
       ( (e:gencode == 940 .AND. e:subcode==8999 ) .OR. ;
         (e:gencode == 73  .AND. e:subcode==8037 ) .OR. ;
         (e:gencode == 79  .AND. e:subcode==8999 .AND. ;
          VALTYPE(e:operation)=="C" .AND. ;
          "DBAPPEND"$UPPER(e:operation) )    .OR. ;
         (e:gencode == 79  .AND. e:subcode==8999 .AND. ;
          VALTYPE(e:operation)=="C" .AND. ;
          "ORDLISTADD"$UPPER(e:operation) )  .OR. ;
         (e:gencode == 71  .AND. e:subcode==8999 .AND. ;
          VALTYPE(e:operation)=="C" .AND. ;
          "ORDLISTADD"$UPPER(e:operation) )  .OR. ;
         (e:gencode == 71  .AND. e:subcode==8999 .AND. ;  // Aggiunto 17/01/2006 Luca Gerr 4616
          VALTYPE(e:operation)=="C" .AND. ;
          "DBUSEAREA"$UPPER(e:operation)  )  .OR. ;
         (e:gencode == 41  .AND. e:subcode==   5 .AND. ;   // nuovo in Xbase 1.5
          VALTYPE(e:operation)=="C" .AND. ;
          "DBAPPEND"$UPPER(e:operation) )    .OR. ;
         (e:gencode == 41  .AND. e:subcode==   5 .AND. ;   // nuovo in Xbase 1.5
          VALTYPE(e:operation)=="C" .AND. ;
          "ORDLISTADD"$UPPER(e:operation) )    .OR. ;
         (e:gencode == 40  .AND. e:subcode==   4 .AND. ;   // nuovo in Xbase 1.5
          VALTYPE(e:operation)=="C" .AND. ;
          "DBUSEAREA"$UPPER(e:operation) )   .OR. ;
         (e:gencode == 40  .AND. e:subcode==   4 .AND. ;   // nuovo in Xbase 1.5
          VALTYPE(e:operation)=="C" .AND. ;
          "ORDCREATE"$UPPER(e:operation) )   .OR. ;
         (e:gencode == 40  .AND. e:subcode==   4 .AND. ;   // nuovo in Xbase 1.5
          VALTYPE(e:operation)=="C" .AND. ;
          "DBUSEAREA"$UPPER(e:operation) )   .OR. ;
         (e:gencode == 70  .AND. e:subcode== 8018 .AND. ;  // nuovo con ADS 1.5
          VALTYPE(e:operation)=="C" .AND. ;
          "DBUSEAREA"$UPPER(e:operation) )   .OR. ;
         (e:gencode == 40  .AND. e:subcode==   4 .AND. ;   // nuovo in Xbase 1.5
          VALTYPE(e:operation)=="C" .AND. ;
          "ORDLISTADD"$UPPER(e:operation) )  .OR. ;
         (e:gencode == 40  .AND. e:subcode==   4 .AND. ;   // Simone 26/4/05 gerr 4420
          VALTYPE(e:operation)=="C" .AND. ;                // nuovo in ADS e Xbase 1.82
          "DBAPPEND"$UPPER(e:operation) )    .OR. ;
         (e:gencode == 40  .AND. e:subcode==   4 .AND. ;   // Luca 18/1/06 gerr 4593
          VALTYPE(e:operation)=="C" .AND. ;                // nuovo in ADS e Xbase 1.82
          "DBGOTO"$UPPER(e:operation) )      .OR. ;
         (e:gencode == 40  .AND. e:subcode==   4 .AND. ;   // Luca 18/1/06 gerr 4593
          VALTYPE(e:operation)=="C" .AND. ;                // nuovo in ADS e Xbase 1.82
          "DBCOMMIT"$UPPER(e:operation) )    .OR. ;
         (e:gencode == 40  .AND. e:subcode==   4 .AND. ;   // Luca 18/1/06 gerr 4593
          VALTYPE(e:operation)=="C" .AND. ;                // nuovo in ADS e Xbase 1.82
          "DBRUNLOCK"$UPPER(e:operation) )      )

/* Split large line for Alert()-box output */
STATIC FUNCTION __LineSplit(cMessage, nMaxCol)
LOCAL i
LOCAL cLines := ""
LOCAL nLines

   nLines := MlCount(cMessage, nMaxCol,, .T.)
   FOR i:= 1 TO nLines
        cLines += "//"+Rtrim(MemoLine(cMessage, nMaxCol, i,,.T.)) 
   NEXT
RETURN cLines

FUNCTION dfErrLog(e, cMessage, cWhat)
   IF EMPTY(e)
      RETURN .F.
   ENDIF

   DEFAULT cMessage TO ErrorMessage(e)
   DEFAULT cWhat TO "-VER-ERROR-MEM-ENV-CLP-AREAS-SCREEN-EXE-WIN-STACK-"

   cWhat := UPPER(cWhat)

   dfOpenErr()
   dfLogWrite( "ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ> BEGIN ERROR LOG <ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ" +CRLF )
   IF "-VER-" $ cWhat
      dfErrVer(cMessage)
   ENDIF
   IF "-ERROR-" $ cWhat
      dfErrError( e )
   ENDIF
   IF "-MEM-" $ cWhat
      dfErrMemory()
   ENDIF
   IF "-ENV-" $ cWhat
      dfErrDosEnv()
   ENDIF
   IF "-CLP-" $ cWhat
      dfErrClpEnv()
   ENDIF
#ifndef __HARBOUR__
   IF "-AREAS-" $ cWhat
      dfErrAreas()
   ENDIF
#endif
   IF "-SCREEN-" $ cWhat
      dfErrScr()
   ENDIF
   IF "-EXE-" $ cWhat
      dfErrExe()
   ENDIF
   IF "-WIN-" $ cWhat
      dfErrWin()
   ENDIF
   IF "-STACK-" $ cWhat
      dfErrStack(e)
   ENDIF
   dfLogWrite( "ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ> END ERROR LOG <ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ" +CRLF +CRLF )
   dfCloseErr()
RETURN .T.

FUNCTION dfErrHandleDefault(e, lDefault)
   LOCAL cSessionError := ""

   lDefault := .T.

   //Luca
   IF (e:genCode == XPP_ERR_MEMORY_FULL)
      QUIT
   ENDIF

   // by default, division by zero yields zero
   IF ( e:genCode == EG_ZERODIV )
      return (0)
   ENDIF

   // for network open error, set NETERR() and subsystem default
   IF ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )
      NetErr(.t.)
      return (.f.)                                                                    // NOTE
   ENDIF

   // for lock error during APPEND BLANK, set NETERR() and subsystem default
   IF ( e:genCode == EG_APPENDLOCK .and. e:canDefault )
      NetErr(.t.)
      return (.f.)                                                                    // NOTE
   ENDIF

   if (e:gencode == 40  .AND. e:subcode==   4 .AND. ;    // Simone 30/06/05 gerr 4420
        VALTYPE(e:operation)=="C" .AND. ;                // nuovo in ADS e Xbase 1.82
        "DBAPPEND"$UPPER(e:operation) .and. e:canDefault )
      NetErr(.t.)
      return (.f.)                                                                    // NOTE
   endif

//Mantis 2181
//Maudp 11/01/2014 FIX per errore in dbAppend (errore 1024 ADS)
**************************************************************************
   if VALTYPE(e:operation)=="C" .AND. ;                
      "DBAPPEND"$UPPER(e:operation) .and. e:canDefault

//      IF dfAXSSessionError()==NIL
      IF !dbsee4Axs()
         IF e:gencode == 8999  .AND. e:subcode==   0

            NetErr(.t.)
            return (.f.)                                                     
         ENDIF
      ELSE
         cSessionError := SessionError()
         IF cSessionError == "1024"  .OR. ;
           (EMPTY(cSessionError) .AND. e:gencode == 8999  .AND. e:subcode== 0)
          

            NetErr(.t.)
            return (.f.)                                                     
         ENDIF
      ENDIF
   endif
**************************************************************************

   // If error in print : automatic retry
   IF e:GENCODE==EG_PRINT .AND. e:CANRETRY
      RETURN .T.
   ENDIF

   // If Lock timeout retry 5 times
   IF (e:subCode=1035 .and. e:tries<=5)
      dfinkey(.2) //FW
      RETURN .T.
   ENDIF

   // If Lock failure retry 5 times
   IF (e:subCode=1038 .and. e:tries<=5)
      dfinkey(.2) //FW
      RETURN .T.
   ENDIF

   //Mantis 9xx
   IF (e:canRetry .AND. e:tries <= 5)  .AND.;   
      dfDefaultErrChk(e)
      dfinkey(.2) //FW
      RETURN .T.
   ENDIF

   /* Check if error is handled automatically */
   DO CASE

      /* Division by zero results in 0 */
      CASE e:genCode == XPP_ERR_ZERODIV
         RETURN 0

      /* Zero divide by zero is also 0 and may occur
       * in operations like /, /=, % and %=
       */
      CASE e:genCode == XPP_ERR_NUMERR
         IF "/" $ e:operation .OR. "%" $ e:operation
             IF e:args[1] = 0
                IF len(e:args) = 1
                    RETURN 0
                ELSEIF e:args[2] = 0
                    RETURN 0
                ENDIF
             ENDIF
         ENDIF

      /* Error opening a file on a network */
      CASE e:genCode == XPP_ERR_OPEN  .AND. ;
           e:osCode  == 32            .AND. ;
           e:canDefault
         RETURN(.F.)

      /* No lock is set */
      CASE e:genCode == XPP_ERR_APPENDLOCK .AND. ;
           e:canDefault
         RETURN(.F.)

   ENDCASE

   // se arrivo qui NON Š un errore gestibile di default
   lDefault := .F.
RETURN NIL



STATIC FUNCTION dfErrAlert(e, cMessage, nMode)
LOCAL aOptions
LOCAL nChoice
LOCAL aErr := {}
LOCAL i
LOCAL nOption
LOCAL nSeverity
LOCAL row, col

IF EMPTY(nMode) // modalit… visual dbsee standard
   // build options array
   // aOptions := {"Break", "Quit"}
   aOptions := { dfStdMsg( MSG_ERRSYS70 ) } // QUIT

   if (e:canRetry)
           AAdd(aOptions, dfStdMsg( MSG_ERRSYS71 )) // RETRY
   end

   if (e:canDefault)
           AAdd(aOptions, dfStdMsg( MSG_ERRSYS72 )) // DEFAULT
   end

   cMessage+="//"+dfStdMsg( MSG_ERRSYS15 )
   cMessage+="//"+_GetLogFName()     
   cMessage+="//"

   IF IsMethod( e, "getCallstack" )
      i := e:getCallstack( CRLF )
      dfStr2Arr(i, CRLF, aErr)
   ELSE
      i := 2
      while ( !Empty(ProcName(i)) )
         AADD( aErr, dfStdMsg(MSG_ERRSYS75) +" " +Trim(ProcName(i)) + ;
                      "(" + NTRIM(ProcLine(i)) + ")  " )
         i++
      end
   ENDIF

   IF LEN(aErr) > 16
      ASIZE(aErr, 15)
      AADD(aErr, "...")
   ENDIF

   cMessage += "//"+dfArr2Str(aErr, "//")

   // put up alert box
   nChoice := 0
   while ( nChoice == 0 )
      nChoice := ErrAlert( cMessage, aOptions )
      if ( nChoice == NIL )
         exit
      end
   end

   if ( !Empty(nChoice) )

           // do as instructed
           if ( aOptions[nChoice] == dfStdMsg(MSG_ERRSYS74) ) // BREAK
                   Break(e)

           elseif ( aOptions[nChoice] == dfStdMsg(MSG_ERRSYS71) )  // RETRY
                   return (.t.)

           elseif ( aOptions[nChoice] == dfStdMsg(MSG_ERRSYS72) )  // DEFAULT
                   return (.f.)

           end

   end

   dfSet( AI_ERRORINWINDOW, .T. )

   IF dfSet( AI_ERRORINWINDOW )
/*
      AADD( aErr, dfStdMsg( MSG_ERRSYS15 ) )
      AADD( aErr, _GetLogFName()      )
      AADD( aErr, "" )
      IF IsMethod( e, "getCallstack" )
         i := e:getCallstack( CRLF )
         dfStr2Arr(i, CRLF, aErr)
         IF LEN(aErr) > 15
            ASIZE(aErr, 15)
         ENDIF
      ELSE
         i := 2
         while ( !Empty(ProcName(i)) ) .AND. i <=18
            AADD( aErr, dfStdMsg(MSG_ERRSYS75) +" " +Trim(ProcName(i)) + ;
                         "(" + NTRIM(ProcLine(i)) + ")  " )
            i++
         end
      ENDIF
      SET DEVICE TO SCREEN

      IF SetAppWindow() != NIL

         dfArrWin(,,,,aErr,"ERROR")

      ENDIF
*/
      CLOSE DATABASES

      SET COLOR TO
      CLS
   ELSE
      SET COLOR TO
      CLS
      // display message and traceback
      i := 2
      ? cMessage
      ? ""
      while ( !Empty(ProcName(i)) )
              ? dfStdMsg(MSG_ERRSYS75), Trim(ProcName(i)) + ;
                      "(" + NTRIM(ProcLine(i)) + ")  "
              i++
      end
      ? ""
      @ dfRow()+1, 0 SAY dfStdMsg( MSG_ERRSYS15 ) COLOR "N/W"
      @ dfRow()+1, 0 SAY _GetLogFName()      COLOR "N/W"
      ? ""
      ? dfStdMsg( MSG_ERRSYS16 )

      M_CurOff()
      dfINKEY(0) //FW
      M_CurOn()
   ENDIF

   // give up
   ErrorLevel(1)
   QUIT

   return (.f.)
ENDIF

//------------------
   /* Array for selection */
#ifdef DEBUG
   aOptions := { EHS_CANCEL, EHS_EXIT_WITH_LOG }
#else
   aOptions := { EHS_CANCEL }
#endif

   IF e:canRetry
      AAdd( aOptions, EHS_RETRY )
   ENDIF

   IF e:canDefault
      AAdd( aOptions, EHS_IGNORE )
   ENDIF

//   IF ! Empty( e:osCode )
//      cMessage += EHS_OS_ERROR + LTrim(Str(e:osCode)) +;
//                  ";" + DosErrorMessage(e:osCode)
//   ENDIF

   IF AppType() <> APPTYPE_PM

      /* Display Alert() Box possible ? */
      IF SetAppWindow() != NIL
         i   := 0
         row := Row()
         col := Col()
         DO WHILE i == 0                     
            i := Alert( cMessage, aOptions )
         ENDDO
         SetPos( row, col )

         /* Perform selected option */
         IF ! Empty( i )            
            DO CASE
            CASE aOptions[i] == EHS_IGNORE
               RETURN .F.
            CASE aOptions[i] == EHS_RETRY
               RETURN .T.
            CASE aOptions[i] == EHS_CANCEL
               Break( e )
            CASE aOptions[i] == EHS_EXIT_WITH_LOG
               //ErrorLog( e, 2 )
            ENDCASE
         ENDIF
      ELSE
         /* There is no console window */
#ifdef DEBUG
    //ErrorLog( e, 2 )
#endif
      ENDIF

      /*
       * Program can not or should not be continued
       * Set error level and terminate program !
       */

      ErrorLevel(1)
      QUIT 
   ENDIF

   IF e:canDefault .AND. e:canRetry
      nOption := XBPMB_ABORTRETRYIGNORE
   ELSEIF e:canRetry
      nOption := XBPMB_RETRYCANCEL
   ELSEIF e:canDefault
      nOption := XBPMB_OKCANCEL
   ELSE
      nOption := XBPMB_CANCEL
   ENDIF

// nOption := XBPMB_ABORTRETRYIGNORE// interrompi=(XBPMB_RET_ABORT) , retry=4 (XBPMB_RET_RETRY), ignora=5 (XBPMB_RET_IGNORE)
// nOption := XBPMB_RETRYCANCEL //retry =4 (XBPMB_RET_RETRY), annulla=2 (XBPMB_RET_CANCEL)
// nOption := XBPMB_OKCANCEL->ok =1(XBPMB_RET_OK), annulla=2 (XBPMB_RET_CANCEL)
// nOption := XBPMB_CANCEL //ok-> 1 (XBPMB_RET_OK)

   /*
    * Get Callstack from error object or gather it together.
    */
   IF IsMethod( e, "getCallstack" )
     cMessage += e:getCallstack( ";" )
   ELSE
     i := 1
     DO WHILE ! Empty( ProcName(++i) )
        cMessage += ";" 
        cMessage += EHS_CALLED_FROM + " " 
        cMessage += Trim( ProcName(i) ) 
        cMessage += "(" + NTRIM( ProcLine(i) ) + ")"
     ENDDO
   ENDIF

   i := 0
   /* select icon for ConfirmBox() */
   DO CASE
      CASE e:severity == XPP_ES_FATAL
           nSeverity := XBPMB_CRITICAL
      CASE e:severity == XPP_ES_ERROR
           nSeverity := XBPMB_CRITICAL
      CASE e:severity == XPP_ES_WARNING
           nSeverity := XBPMB_WARNING
      OTHERWISE
           nSeverity := XBPMB_INFORMATION
   ENDCASE
   /* Display ConfirmBox() */
   i := ConfirmBox( , StrTran( cMessage, ";", Chr(13) ), ;
                    EHS_XPP_ERROR_MESSAGE , ;
                    nOption , ;
                    nSeverity + XBPMB_APPMODAL+XBPMB_MOVEABLE )

   DO CASE
   CASE i == XBPMB_RET_RETRY
      RETURN (.T.)
   CASE i == XBPMB_RET_IGNORE
      RETURN (.F.)
   CASE i == XBPMB_RET_CANCEL
#ifdef DEBUG
//         IF ConfirmBox(, EHS_EXIT_WITH_LOG, EHS_XPP_ERROR_MESSAGE, XBPMB_YESNO,;
//                  XBPMB_WARNING+XBPMB_APPMODAL+XBPMB_MOVEABLE ) != XBPMB_RET_YES
//              Break( e )
//         ENDIF
#else
         Break( e )
#endif
   ENDCASE

#ifdef DEBUG
   //ErrorLog( e, 2 )
#endif

   /* Set error level and terminate program ! */
   ErrorLevel(1)
   QUIT

RETURN .F. /* The compiler expects a return value */


STATIC FUNCTION BuildTree(oTree, xVal,cPre,aRef, nLev)
   LOCAL nInd := 0
   LOCAL aItm
   LOCAL cAdd
   LOCAL oObj
   LOCAL oItem
   LOCAL cType :=VALTYPE(xVal)
   LOCAL cTmp,aArr

   DEFAULT aRef TO {}
   DEFAULT nLev TO 0

   cAdd :=""
   IF cPre != NIL
      cAdd += cPre
   ENDIF

   cAdd += cType+": "
   DO CASE
      CASE cType == "D"
         cAdd += DTOC(xVal)

      CASE cType == "B"
         cAdd += var2char(xVal)

      CASE cType == "N"
         cAdd += var2char(xVal)

      CASE cType == "U"
         cAdd += "NIL"

      CASE cType == "L"
         cAdd += IIF(xVal,".T.",".F.")

      CASE cType $ "CM"
         cTmp := ALLTRIM(STRTRAN(HARDCR(xVal), CRLF, " "))
         IF LEN(cTmp) > 210
            cTmp := LEFT(cTmp, 100)+"..."+RIGHT(cTmp, 100)
         ENDIF
         cAdd += "("+ALLTRIM(STR(LEN(xVal)))+") "+'"'+cTmp+'"'

      CASE cType $ "A"
         cAdd += "array (len="+ALLTRIM(STR(LEN(xVal)))+")"
         IF nLev > INSPECT_MAX_LEVEL
            cAdd += " (not inspected)"
         ENDIF
      CASE cType $ "O"
         cAdd += "object (class="+xVal:className()+")"
         IF nLev > INSPECT_MAX_LEVEL
            cAdd += " (not inspected)" 
         ENDIF
   ENDCASE
   oItem := oTree:addItem(cAdd)

   IF nLev > INSPECT_MAX_LEVEL
      // salto per non andare troppo in profondit…
   ELSEIF cType=="A"
      aArr:=xVal
      FOR nInd := 1 TO LEN(aArr)
         BuildTree(oItem,aArr[nInd],ALLTRIM(STR(nInd))+" ",aRef, nLev+1)
         IF nInd >= INSPECT_MAX_ARR_ELEMENTS
            oItem:addItem("Skipped "+NTRIM(LEN(aArr)-INSPECT_MAX_ARR_ELEMENTS)+" elements...")
            EXIT
         ENDIF
      NEXT

   ELSEIF cType=="O"
      _obj(oItem, xVal,aRef, nLev)

   ENDIF
RETURN NIL


STATIC FUNCTION _Obj(oTree,obj,aRef, nLev)
   LOCAL nInd := 0
   LOCAL aItm
   LOCAL cAdd
   LOCAL oObj
   LOCAL oItem,aArr
   LOCAL aInfo := obj:classDescribe()

   IF ASCAN(aRef,obj)!=0
      RETURN NIL
   ENDIF

   //oTree:addItem("Classname: "+aInfo[1] )
/*
   aArr := ACLONE(aInfo[2])
   oItem := oTree:addItem("Superclasses: "+dfArr2Str(aInfo[2]) )
*/
/*   FOR nInd := 1 TO LEN(aArr)
      oItem:addItem(aArr[nInd][2])
   NEXT
   */


   aArr := ACLONE(aInfo[3])
   oItem := oTree:addItem("Members: "+ALLTRIM(STR(LEN(aArr))))
   ASort( aArr ,,,{|x,y| STR(x[CLASS_MEMBER_ATTR]) + Upper( x[CLASS_MEMBER_NAME] ) < ;
                         STR(x[CLASS_MEMBER_ATTR]) + Upper( y[CLASS_MEMBER_NAME] ) } )

   FOR nInd := 1 TO LEN(aArr)
      cAdd := ""
      IF dfAnd(aArr[nInd, CLASS_MEMBER_ATTR],VAR_INSTANCE) == 0
         cAdd+="CLASS VAR "
      ENDIF
      cAdd += aArr[nInd, CLASS_MEMBER_NAME]+"="
      IF aArr[nInd, CLASS_MEMBER_ATTR] == VAR_ASSIGN_HIDDEN
         oItem:addItem(cAdd +" (HIDDEN)")
      ELSEIF aArr[nInd, CLASS_MEMBER_ATTR] == VAR_ASSIGN_PROTECTED
         oItem:addItem(cAdd +" (PROTECTED)")
      ELSE

         IF !EMPTY(aArr[nInd, CLASS_MEMBER_NAME]) .AND.;
            IsMethod(obj,aArr[nInd, CLASS_MEMBER_NAME] )

            aItm :=obj:&( aArr[nInd, CLASS_MEMBER_NAME] )
            AADD(aRef,obj)
            BuildTree(oItem,aItm,cAdd,aRef, nLev+1)
         ENDIF 
         AREMOVE(aRef)
      ENDIF
      IF nInd >= INSPECT_MAX_OBJ_ELEMENTS
         oItem:addItem("Skipped "+NTRIM(LEN(aArr)-INSPECT_MAX_OBJ_ELEMENTS)+" elements...")
         EXIT
      ENDIF
   NEXT
/*
   aArr := ACLONE(aInfo[4])
   oItem := oTree:addItem("Methods:"+ALLTRIM(STR(LEN(aArr))))
   ASort( aArr ,,,{|x,y| STR(x[CLASS_METHOD_ATTR]) + Upper( x[CLASS_METHOD_NAME] ) < ;
                         STR(y[CLASS_METHOD_ATTR]) + Upper( y[CLASS_METHOD_NAME] ) } )
   FOR nInd := 1 TO LEN(aArr)
      cAdd := ""
//      IF dfAnd(aArr[nInd, CLASS_METHOD_ATTR],METHOD_INSTANCE) == 0
//         cAdd+="CLASS MTD "
//      ENDIF
      cAdd += aArr[nInd, CLASS_METHOD_NAME]+"()"
      IF aArr[nInd, CLASS_METHOD_ATTR] == CLASS_HIDDEN
         cAdd += " (HIDDEN)"
      ELSEIF aArr[nInd, CLASS_METHOD_ATTR] == CLASS_PROTECTED
         cAdd += " (PROTECTED)"
      ENDIF
      oItem:addItem(cAdd)
   NEXT
*/
RETURN NIL

// rimappo i messaggi usando una confirmbox
STATIC FUNCTION ErrAlert(cMessage, aOptions)
   LOCAL nOption
   LOCAL i

   IF LEN(aOptions) <= 1
      nOption := XBPMB_CANCEL
   ELSEIF LEN(aOptions) == 2 // cancel, retry
      nOption := XBPMB_RETRYCANCEL
   ELSE
      nOption := XBPMB_ABORTRETRYIGNORE
   ENDIF

   /* Display ConfirmBox() */
   i := ConfirmBox( , StrTran( cMessage, "//", Chr(13) ), ;
                    dfStdMsg(MSG_ERRSYS76), ;
                    nOption , ;
                    XBPMB_CRITICAL + XBPMB_APPMODAL+XBPMB_MOVEABLE )

   IF LEN(aOptions) <= 1
      i := 1
   ELSEIF LEN(aOptions) == 2 // cancel, retry
      i := IIF(i == XBPMB_RET_RETRY, 2, 1)
   ELSE
      IF i == XBPMB_RET_RETRY
         i := 2
      ELSEIF i == XBPMB_RET_IGNORE
         i := 3
      ELSE
         i := 1
      ENDIF
   ENDIF
RETURN i

STATIC CLASS ErrItem
EXPORTED:
   VAR aChilds
   VAR caption
   METHOD init
   METHOD addItem

   CLASS METHOD recurse
ENDCLASS

// esegue un codeblock su tutta la struttura
CLASS METHOD ErrItem:recurse( oItem, b, nLevel, nItem, oFather )
   LOCAL n

   DEFAULT nLevel TO 0
   DEFAULT nItem  TO 0

   EVAL(b, oItem, nLevel, nItem, oFather)

   IF ! EMPTY(oItem:aChilds)
      FOR n := 1 TO LEN(oItem:aChilds)
          ::recurse(oItem:aChilds[n], b, nLevel+1, n, oItem)
      NEXT
   ENDIF
RETURN self

METHOD ErrItem:init(x)
   DEFAULT x TO ""

   ::aChilds := {}
   ::caption := x
RETURN self

METHOD ErrItem:addItem(c)
   LOCAL oItem
   oItem := ErrItem():new(c)
   AADD(::aChilds, oItem)
RETURN oItem

//Mantis 2181
//Maudp 11/01/2012 FIX per errore QUARK in dbAppend (errore 1024 ADS)
STATIC FUNCTION SessionError()
   LOCAL cError := ""
   LOCAL oSession := DbSession()
   LOCAL oDacSession

   IF oSession = NIL .AND. IsFunction("DacSession", FUNC_CLASS)
      oDacSession := &("DacSession()")
      oSession := oDacSession:getDefault()     
   ENDIF

   IF !oSession == NIL .AND. ;
      !oSession:getLastError() == 0

      cError := ALLTRIM(STR( oSession:getLastError() ))                  
      
   ENDIF
RETURN cError

