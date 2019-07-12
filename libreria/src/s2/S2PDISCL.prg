#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "dfReport.ch"
#include "dfMsg1.ch"

// Dispositivo di stampa
// stampa su ClipBoard (APPUNTI)

CLASS S2PrintDispClipBoard FROM S2PrintDisp
   EXPORTED:

      METHOD init
      METHOD exitMenu
      METHOD execute

ENDCLASS

METHOD S2PrintDispClipBoard:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::dispName := dfStdMsg1(MSG1_S2PDISCL01)
RETURN self

METHOD S2PrintDispClipBoard:exitMenu(nAction, aBuf)
   LOCAL cFile  := ""

   aBuf[REP_PRINTERPORT] := "FILE"
   ///////////////////////////////////////////
   //Riferimento riga mantis 2141
   //Correzione Luca del 29/11/2010
   FClose(dfFileTemp(@cFile, , , ".txt"))
   aBuf[REP_FNAME] := cFile  // "" 
   ///////////////////////////////////////////

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
   

RETURN nAction

METHOD S2PrintDispClipBoard:execute()
   LOCAL oClip
   LOCAL cFName := ::aBuffer[REP_FNAME]
   LOCAL cName  := ::aBuffer[REP_NAME]
   LOCAL cTxt := MEMOREAD(cFName)

   oClip := XbpClipBoard():new():create()
   oClip:open()

   // Simone 10/3/04 gerr 3635
   // stampa su appunti non funziona se appunti non vuoti 
   oClip:clear()

   oClip:setbuffer(cTxt)
   oClip:close()
   oClip:destroy()

   FERASE(cFName)
   dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cFName) )

RETURN .T.

