#include "dll.ch"
#include "common.ch"

#define HELP_CONTEXT      0x0001  /* Display topic in ulTopic */
#define HELP_QUIT         0x0002  /* Terminate help */
#define HELP_INDEX        0x0003  /* Display index */
#define HELP_CONTENTS     0x0003
#define HELP_HELPONHELP   0x0004  /* Display help on using help */
#define HELP_SETINDEX     0x0005  /* Set current Index for multi index help */
#define HELP_SETCONTENTS  0x0005
#define HELP_CONTEXTPOPUP 0x0008
#define HELP_FORCEFILE    0x0009
#define HELP_KEY          0x0101  /* Display topic for keyword in offabData */
#define HELP_COMMAND      0x0102
#define HELP_PARTIALKEY   0x0105
#define HELP_MULTIKEY     0x0201
#define HELP_SETWINPOS    0x0203

#define HELP_CONTEXTMENU  0x000A
#define HELP_FINDER       0x000B
#define HELP_WM_HELP      0x000C
#define HELP_SETPOPUP_POS 0x000D

#define HELP_TCARD              0x8000
#define HELP_TCARD_DATA         0x0010
#define HELP_TCARD_OTHER_CALLER 0x0011

// These are in winhelp.h in Win95.
#define IDH_NO_HELP                     28440
#define IDH_MISSING_CONTEXT             28441 // Control doesn't have matching help context
#define IDH_GENERIC_HELP_BUTTON         28442 // Property sheet help button
#define IDH_OK                          28443
#define IDH_CANCEL                      28444
#define IDH_HELP                        28445

// Questa classe Š in grado di chiamare un HELP RTF direttamente
// con il TOPIC senza doverlo mappare (come invece deve fare la
// classe XbpHelp per un bug)

CLASS S2XbpHelp FROM XbpHelp
   PROTECTED:
       VAR oOwner, cHelpFile, cTitle
       METHOD _showHelp, _canCall

   EXPORTED:
       METHOD Init
       METHOD Create
       METHOD Configure
       METHOD Destroy
       METHOD ShowHelp
ENDCLASS

METHOD S2XbpHelp:init(oOwner, cHelpFile, cTitle)
   DEFAULT oOwner TO SetAppWindow()

   ::oOwner    := oOwner
   ::cHelpFile := cHelpFile
   ::cTitle    := cTitle

   ::XbpHelp:init(oOwner, cHelpFile, cTitle)
RETURN self

METHOD S2XbpHelp:create(oOwner, cHelpFile, cTitle)
   DEFAULT oOwner    TO ::oOwner
   DEFAULT cHelpFile TO ::cHelpFile
   DEFAULT cTitle    TO ::cTitle

   ::oOwner    := oOwner
   ::cHelpFile := cHelpFile
   ::cTitle    := cTitle
   ::XbpHelp:create(oOwner, cHelpFile, cTitle)
RETURN self


METHOD S2XbpHelp:configure(oOwner, cHelpFile, cTitle)
   DEFAULT oOwner    TO ::oOwner
   DEFAULT cHelpFile TO ::cHelpFile
   DEFAULT cTitle    TO ::cTitle

   ::oOwner    := oOwner
   ::cHelpFile := cHelpFile
   ::cTitle    := cTitle
   ::XbpHelp:configure(oOwner, cHelpFile, cTitle)
RETURN self

METHOD S2XbpHelp:destroy()
   ::oOwner    := NIL
   ::cHelpFile := NIL
   ::cTitle    := NIL
   ::XbpHelp:destroy()
RETURN self


METHOD S2XbpHelp:showHelp(xTopic)
   LOCAL lRet
   IF ::_canCall(xTopic)
      lRet := ::_showHelp(xTopic)
   ELSE
      lRet := ::XbpHelp:showHelp(xTopic)
   ENDIF
RETURN lRet

// Correzione per BUG, solo se il topic Š carattere e
// l'help Š di tipo RTF (estensione del file di help = "HLP")

METHOD S2XbpHelp:_canCall(xTopic)
   LOCAL lOk := VALTYPE(xTopic) == "C"
   LOCAL nPos
   IF lOk
      nPos := RAT(".", ::cHelpFile)
      IF nPos > 0
         lOk := UPPER(SUBSTR(::cHelpFile, nPos+1)) == "HLP"
      ELSE
         lOk := .F.
      ENDIF
   ENDIF
RETURN lOk


METHOD S2XbpHelp:_showHelp(xTopic)
   LOCAL lOk := .F.
   LOCAL nHWND
   LOCAL nReturn
   LOCAL cCommand
   LOCAL oXbp

   IF VALTYPE(xTopic) == "C"
      IF ::oOwner != NIL .AND. ::oOwner:isDerivedFrom("XbpDialog")
         nHWND := ::oOwner:GetHWND()
      ELSE
         // dummy object to get HWND param
         oXbp := XbpStatic():New():Create()
         nHWND := oXbp:GetHWND()
      ENDIF

      cCommand := 'JI("", "' + xTopic + '")'
      nReturn := DllCall("USER32.DLL", DLL_STDCALL, "WinHelpA",  ;
                        nHWND, ::cHelpFile, HELP_COMMAND, cCommand)

      lOk := nReturn != 0

      IF oXbp != NIL
         oXbp:Destroy()
      ENDIF

   ENDIF
RETURN lOk

