#include "Common.ch"
#include "xbp.ch"

#define HELP_BASEDIR (dbCfgPath("HelpPath"))
// #define HELP_BASEDIR "RTF\"

#define RTF_HELP ".HLP"
#define RTF_EXT  ".RTF"

#define HTML_HELP ".CHM"
#define HTML_EXT  ".HTM"

#define HELP_FILENAME (IIF(EMPTY(aBlock[3]), HELP_BASEDIR+"dbhlp"+aHelpStyle[1], aBlock[3]) )

STATIC aBlock     := {NIL, NIL, NIL}
STATIC oXbpHelp
STATIC aHelpStyle := {RTF_HELP, RTF_EXT}  // Cambiare questi per l'help HTML
                                          // in {HTML_HELP, HTML_EXT}

// Tommaso 26/03/10 - EXCEL 19
STATIC bCBExe      := NIL

// Imposta delle informazioni per uso help RTF/CHM
// aNew[1] := codeblock per dire se l'help windows Š disponibile 
//            se NIL verr… controllata la presenza del file
//            indicato in aNew[3]
// aNew[2] := codeblock di collegamento finestra->help se NIL 
//            corrisponde a UPPER(ALLTRIM(cForm))
// aNew[3] := nome file, se NIL corrisponde a           
//            dbCfgPath("HelpPath")+"dbHlp.hlp"
//
// es.
//   aNew := {NIL, {|cForm, cID| UPPER(ALLTRIM(cForm))+".HTM"}, dbCfgPath("HelpPath")+"dbHlp.chm"}
//   dfHlpSetCB(aNew)
//
FUNCTION dfHlpSetCB(aNew)
   LOCAL aRet := ACLONE(aBlock)
   IF aNew != NIL
      aBlock := aNew
   ENDIF
RETURN aRet


// Tommaso 26/03/10 - EXCEL 19 - Implementata la possibilità di impostare un codeblock da eseguire in sostituzione dell'userguide
//                               Serve su EXTRA. E' stata implementata la documentazione on-line, e il tasto F1 non deve più
//                               aprire un chm a capitoli, ma aprire un file html su internet.
FUNCTION dfHlpSetCBExe(bExe)
LOCAL bOld := bCBExe
   bCBExe := bExe
RETURN bOld

FUNCTION dfHlp(cForm, cId)
   LOCAL aFocus := {SetAppWindow(), SetAppFocus(), S2FormCurr()}

// Tommaso 26/03/10 - EXCEL 19
   IF !EMPTY(bCBExe)
      EVAL(bCBExe)
      RETURN NIL
   ENDIF
   
   IF dfWinHelpAvailable()

      // Help Windows
      dfWinHelp(cForm, cId)

   ELSE

      // Help Standard
      _dfHlp(cForm, cId)
   //Mantis 676
   //ENDIF

   IF aFocus[2] != NIL
      SetAppFocus(aFocus[2])
   ENDIF

   IF aFocus[1] != NIL
      SetAppWindow(aFocus[1])
   ENDIF

   IF aFocus[3] != NIL
      S2FormCurr(aFocus[3])
   ENDIF
   //Mantis 676
   ENDIF

RETURN NIL

FUNCTION dfWinHelpAvailable()
RETURN IIF(VALTYPE(aBlock[1]) == "B", EVAL(aBlock[1]), FILE(HELP_FILENAME) )

FUNCTION dfWinHelpObj(oObj)
   LOCAL oRet := oXbpHelp
   IF VALTYPE(oObj) == "O" .AND. ;
      oObj:isDerivedFrom("XbpHelp") .AND. ;
      oObj:status() == XBP_STAT_CREATE
      oXbpHelp := oObj
   ENDIF
RETURN oRet

FUNCTION dfWinHelp(cForm, cId)
   LOCAL xHelpRef

   DEFAULT cForm TO M->EnvId
   DEFAULT cId   TO M->SubId

   DEFAULT cForm TO ""
   DEFAULT cID   TO ""

   //dfAlert(cForm+"//"+cID)
   BEGIN SEQUENCE
      IF EMPTY(cForm); BREAK; ENDIF

      IF oXbpHelp != NIL .AND. ;
         VALTYPE(oXbpHelp:setOwner()) == "O" .AND. ;
         oXbpHelp:setOwner():status() != XBP_STAT_CREATE

         // Simone 26/10/02 - GERR3375
         // workaround per probelmi su win9x se la form sulla quale
         // era stato aperto il primo help era una dfAutoForm() 
         oXbpHelp:destroy()
         oXbpHelp:=NIL

         // potrei usare il configure() ma da un errore di runtime!
         // oXbpHelp:configure(SetAppWindow())

      ENDIF

      // Provo ad inizializzare
      IF oXbpHelp == NIL

         oXbpHelp := HelpInit()

         // Inizializzazione non riuscita: esco
         IF oXbpHelp == NIL; BREAK; ENDIF
      ENDIF

      // Cerco l'argomento
      xHelpRef := GetHelpRef(cForm, cId)

      // Non esiste l'argomento: esco
      IF xHelpRef == NIL; BREAK; ENDIF

      // ok: mostro help
      oXbpHelp:showHelp(xHelpRef)

   END SEQUENCE

RETURN NIL

STATIC FUNCTION HelpInit()
   LOCAL oHelp

   IF dfWinHelpAvailable()
      oHelp := S2XbpHelp():New( NIL, HELP_FILENAME, "Help on line" )
      oHelp:Create()
   ENDIF

RETURN oHelp

// Help sul FORM
STATIC FUNCTION GetHelpRef(cForm, cID)
RETURN IIF(VALTYPE(aBlock[2]) == "B", ;
           EVAL(aBlock[2], cForm, cID), ;
           UPPER(ALLTRIM(cForm)))


// STATIC FUNCTION GetHelpRef(cForm, cID)
//    LOCAL xHelpRef
//
//    IF FILE(HELP_BASEDIR+cForm+"_"+cID+aHelpStyle[2])
//       xHelpRef := UPPER( cForm+"_"+cID )
//
//    ELSEIF FILE(HELP_BASEDIR+cForm+aHelpStyle[2])
//       xHelpRef := UPPER( cForm )
//
//    ENDIF
//
// RETURN xHelpRef


