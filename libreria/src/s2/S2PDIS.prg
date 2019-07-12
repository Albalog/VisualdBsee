#include "common.ch"
#include "dfXbase.ch"
#include "dfMsg1.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
#include "XbpDev.ch"

// Dispositivo di stampa
// GENERICO

MEMVAR ACT

CLASS S2PrintDisp FROM XbpStatic
   PROTECTED
      VAR nError
      VAR cErrorMsg

   EXPORTED:
      VAR dispName
      VAR aBuffer
      VAR aKeys
      VAR oPrintMenu

      VAR nPaperOrientation

      METHOD addShortCut
      METHOD comboBoxWorkAround
      METHOD comboBoxKeyboard

      INLINE METHOD isDefault(); RETURN .F.

      INLINE METHOD init( oParent, oOwner, aPos, aSize, aPP, lVisible )

         DEFAULT lVisible TO .F.
         ::XbpStatic:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
         ::dispName := dfStdMsg1(MSG1_S2PDIS01)
         ::aKeys := {}
         ////////////////////////////////////////////////////////////
         ::nPaperOrientation :=  XBPPRN_ORIENT_PORTRAIT 
         ////////////////////////////////////////////////////////////

      RETURN self

      ///////////////////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////
      //Mantis 1238
      INLINE METHOD Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
          IF dfisWindowsVistaOrAfter() //dfisWindowsVista()
             Sleep(5)
          ENDIF
      RETURN ::XbpStatic:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
      ///////////////////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////

      // Imposta un riferimento al menu di stampa
      INLINE METHOD setPrintMenu(oPM)
         ::oPrintMenu := oPM
      RETURN self

      INLINE METHOD setDispOn(); ::toFront(); RETURN ::show()
      INLINE METHOD setDispOff(); ::toBack(); RETURN ::hide()
      INLINE METHOD execute(); RETURN .F.
      INLINE METHOD exitMenu(nAction, aBuf); RETURN nAction

      // errori di stampa impostabili dal metodo execute()
      // anche se valori non assegnati alle variabili torno 0 e ""
      INLINE METHOD getError()   ; RETURN IIF(EMPTY(::nError   ),  0, ::nError   ) 
      INLINE METHOD getErrorMsg(); RETURN IIF(EMPTY(::cErrorMsg), "", ::cErrorMsg)

      INLINE METHOD canSupportFont(); RETURN .F.
      INLINE METHOD canSupportImg() ; RETURN .F.
      INLINE METHOD canSupportBox() ; RETURN .F.

      //Ger 4287 Luca 22/10/2004
      // Inserito Per la chiusura delle dei file aperti quando non c'ä nulla da stampare
      METHOD Close

ENDCLASS

//Ger 4287 Luca 22/10/2004
// Inserito Per la chiusura delle dei file aperti quando non c'ä nulla da stampare
METHOD S2PrintDisp:Close()
   LOCAL lRet      := .F.
   LOCAL cFile     := IIF(!EMPTY(::aBuffer[REP_FNAME]),ALLTRIM(::aBuffer[REP_FNAME]),"")
   IF !EMPTY(cFile)
      // Cancello il file TESTO temporaneo
      FERASE( cFile )
   ENDIF
RETURN lRet

// Work around perchä sui combobox non viene chiamato il keyboard
// della form padre mentre per altri XbaseParts si...
// Va chiamato dai metodi ereditati alla fine della create()
// per un esempio vedi S2PDISWP.PRG

METHOD S2PrintDisp:comboBoxWorkAround(aObjList)
   LOCAL nInd
   LOCAL oXbp

   FOR nInd := 1 TO LEN(aObjList)
      oXbp := aObjList[nInd]

      IF oXbp:isDerivedFrom("XbpComboBox")
         // chiamo la gestione tastiera del form padre (S2PrintMenu)
         oXbp:keyboard := {|n,unil, o| ::comboBoxKeyboard(n, o) }
      ENDIF

      IF ! EMPTY(oXbp:childList())
         // Esamino i figli!
         ::comboBoxWorkAround(oXbp:childList())
      ENDIF

   NEXT

RETURN self

METHOD S2PrintDisp:comboBoxKeyboard(nKey, oXbp)
   LOCAL oPrn := dfGetParentForm(self)
   dbActSet( nKey )
   DO CASE
      CASE oPrn:handleShortCut( ACT, oPrn:aKeys )
         // non fa niente

      CASE oPrn:handleShortCut( ACT, ::aKeys )
         // non fa niente

      CASE ACT == "tab" .OR. ACT == "Stb" .OR. ACT == "uar" .OR. ACT == "dar"

      OTHERWISE
         // Gestione standard
         oXbp:keyboard(nKey)

   ENDCASE
RETURN self



METHOD S2PrintDisp:addShortCut(cString, oXbp)
   LOCAL nPos
   LOCAL cAct

   // Converto segnale di carattere sottolineato da "&" a "~"
   cString := STRTRAN(cString, "&", STD_HOTKEYCHAR)

   IF ( nPos := AT( STD_HOTKEYCHAR, cString) ) != 0
      cAct := "A_"+LOWER( SUBSTR( cString, nPos + 1, 1))
   ELSEIF dbAct2Ksc(cString) != 0
      cAct := cString
   ENDIF

   IF cAct != NIL
      AADD(::aKeys, {cAct, oXbp})
   ENDIF

RETURN self

