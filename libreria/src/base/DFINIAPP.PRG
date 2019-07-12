//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' per APP
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "COMMON.CH"
#include "dfSet.ch"
#include "dfMsg.ch"

//
// Ho tolto la messaggistica perche' e' inconsistente
// prima del set dei colori
//
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIniApp() // Inizializzazione Applicazione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aApp := dfDefApp()   // Inizializzo Array
dfScanIni( "apps", {|lMod|dfLoadApp(aApp,lMod)} )
RETURN aApp

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfLoadApp( aApp, lMod )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr
LOCAL cStr1

DEFAULT lMod TO .F.

DO WHILE !dfFEof()
   cStr1 := dfFRead()
   cStr  := UPPER(ALLTRIM(cStr1))
   DO CASE
      CASE !lMod .AND. LEFT(cStr,1) == "["                  // altra sezione
           EXIT

      CASE cStr = "FILEPACK"       // Pack degli indici
           aApp[AI_INDEXPACK] := dfRight( cStr, RT_LOGICAL )

      CASE cStr = "LOCKREPEATTIME" // Time Out di RETE
           aApp[AI_LOCKREPEATTIME] := dfRight( cStr, RT_NUMBER )

      CASE cStr = "GETTIMEOUT"     // Time Out di RETE
           aApp[AI_GETTIMEOUT] := dfRight( cStr, RT_NUMBER )

      CASE cStr = "GETWARNING"     // Tempo di warning
           aApp[AI_GETWARNING] := dfRight( cStr, RT_NUMBER )

      CASE cStr = "MOUSEVGA"       // Mouse attivo in modalita' VGA
           aApp[AI_MOUSE] := dfRight( cStr, RT_LOGICAL )

      CASE cStr = "TABNAME"        // Nome Tabelle
           aApp[AI_TABNAME] := dfRight( cStr )

      CASE cStr = "TABINDEX1"      // Nome Tabelle
           aApp[AI_TABINDEX1] := dfRight( cStr )

      CASE cStr = "TABMODIFY"      // Modifica Tabelle
           aApp[AI_TABMODIFY] := dfRight( cStr, RT_LOGICAL )

      CASE cStr = "FILEMODIFY"     // Modifica File
           aApp[AI_FILEMODIFY] := dfRight( cStr, RT_LOGICAL )

      CASE cStr = "CONSOLELINES"   // Modifica Righe video
           aApp[AI_CONSOLELINES] := dfRight( cStr, RT_NUMBER )

      CASE cStr = "SHADOWCOLOR"    // Colore Ombra
           aApp[AI_SHADOWCOLOR] := dfRight( cStr )

      CASE cStr = "DEFAULTPRINTER" // Stampante di DEFAULT
           aApp[AI_DEFAULTPRINTER] := dfRight( cStr )

      CASE cStr = "DEFAULTPORT"    // Porta di DEFAULT
           aApp[AI_DEFAULTPORT] := dfRight( cStr )

      CASE cStr = "OBJECTOFFCOLOR" // Colore oggetto in OFF
           aApp[AI_OBJECTOFFCOLOR] := dfRight( cStr )

      CASE cStr = "INIVERSION"     // Versione dell'INI
           aApp[AI_INIVERSION] := dfRight( cStr )

      CASE cStr = "CLEARSCREEN"    // Cls
           aApp[AI_CLEARSCREEN] := dfRight( cStr, RT_LOGICAL )

      CASE cStr = "FONTREDEFINITION" // Ridefinizione font
           aApp[AI_FONTREDEFINITION] := dfRight( cStr, RT_LOGICAL )

      CASE cStr = "SCREENCOLOR"      // Versione dell'INI
           aApp[AI_SCREENCOLOR] := dfRight( cStr )

      CASE cStr = "INIMESSAGE"       // Messaggi durante l'ini
           aApp[AI_INIMESSAGE] := dfRight( cStr, RT_LOGICAL )

      CASE cStr = "SCREENSAVERACTIVE" // Messaggi durante l'ini
           aApp[AI_SCRSAVERACTIVE] := dfRight( cStr, RT_LOGICAL )

      CASE cStr = "SCREENSAVERTIME"  // Messaggi durante l'ini
           aApp[AI_SCRSAVERTIME] := dfRight( cStr, RT_NUMBER )

      CASE cStr = "EXITAPPSTIME"  // Tempo di uscita
           aApp[AI_EXITAPPSTIME] := dfRight( cStr, RT_NUMBER )

      CASE cStr = "EXITAPPS"  // Forza l'uscita dalle applicazioni
           aApp[AI_EXITAPPS] := dfRight( cStr, RT_LOGICAL )

/*
      // Simone 23/8/04 GERR 4014
      CASE cStr = "XBASESMTPUSER"
           dfSetAdd( dfLeft( cStr ), dfRight( ALLTRIM(cStr1) ) )  // non uso UPPER()

      // Simone 23/8/04 GERR 4014
      CASE cStr = "XBASESMTPPASSWORD"
           dfSetAdd( dfLeft( cStr ), dfRight( ALLTRIM(cStr1) ) )  // non uso UPPER()

*/
      // Simone 29/3/07 
      // mantis 0001216: in invio email SMTP il nome utente di default Š sempre in maiuscolo
      CASE "XBASESMTP" $ cStr
           dfSetAdd( dfLeft( cStr ), dfRight( ALLTRIM(cStr1) ) )  // non uso UPPER()

      OTHERWISE
           dfSetAdd( dfLeft( cStr ), dfRight( cStr ) )

   ENDCASE
   dfFSkip()
ENDDO

RETURN
