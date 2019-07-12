// Inizializzazioni di Base per Ambiente XBase
// -------------------------------------------
#include "dfSwHouse.ch"
#include "common.ch"
#include "xbp.ch"
#include "dfMsg.ch"

PROCEDURE dfXBaseIni()
   LOCAL oPrn
   LOCAL oTooltip
#ifdef _EVAL_
   LOCAL oThr
#endif


   #ifdef _XBASE15_
      // In Xbase 1.5 per default Š ON...
      SET CENTURY OFF
   #endif

   #ifndef _S2DEBUG_
       oTooltip := MagicHelp():New()
      //#ifndef _XBASE182_
       // Simone GERR 3379 e 3738
       // correzione malfunzionamento gestione thread in xbase 1.5-1.8
       // chiuso in xbase 1.82 ma forse non per bene
       // PDR 5057
       Sleep(5)
      //#endif
       oTooltip:Start()
   #endif

   // Abilito il font "Alaska Crt"
   // CreateFont()

   // AboutBox("Informazioni", "dbSee++", "1.0", "Studio 2000 s.a.s", "", 30)
   dbMsgInit()
   dbFrameInit()
   dfPIInit()
   dfInitScreenInit()
   dfWaitInit()
   S2AppColorInit()
   S2GetRBMenuInit()
   // dbAct2KbdQueueInit()

  #ifdef _EVAL_
   //oStrExe := __StrExe():new()

   // Uscita dopo 10 minuti, avverte dopo 2 minuti
   _dfStringExe( 10 * 60, 2 * 60 )
 
   oThr:=Thread():new()
  //#ifndef _XBASE182_
   // Simone GERR 3379 e 3738
   // correzione malfunzionamento gestione thread in xbase 1.5-1.8
   // chiuso in xbase 1.82 ma forse non per bene
   // PDR 5057
   Sleep(5)
  //#endif
   oThr:setInterval(100)
   //oThr:Start({|| oStrExe:check() })
   oThr:Start({|| __StringChk() })
  #endif

   dfFontCompoundNameNormalizeINIT()
RETURN

#ifdef _EVAL_

/*
// Controllo scadenza DEMO, il nome funzione 
// non fa pensare al controllo demo
FUNCTION _dfStringExe( n1, n2, cChk )
RETURN oStrExe:call(n1, n2, @cChk )


STATIC CLASS __StrExe
EXPORTED
   SYNC METHOD check
   SYNC METHOD call
ENDCLASS

METHOD __StrExe:check()
RETURN __StringChk()

METHOD __StrExe:call(n1, n2, cChk)
RETURN __StringExe( n1, n2, @cChk )

*/

// Controllo uscita
STATIC FUNCTION __StringChk()
   LOCAL cTmp
   IF (_dfStringExe(, , @cTmp) + 5 < SECONDS()) .OR. ;
      (! cTmp == CHR(107)+CHR(53)+LEFT("eGdf", 1)+STR(0, 1, 0)+CHR(1+105)+UPPER(CHR(100+6))+CHR(110-4))
      S2RealTimeDelAll()
      CLOSE ALL
      QUIT
   ENDIF
RETURN NIL


FUNCTION _dfStringExe( n1, n2, cChk )
// STATIC FUNCTION __StringExe( n1, n2, cChk )
   LOCAL lOpen := .F.
   LOCAL nWait
   STATIC nShowCount := 0
   STATIC lShow := .F.
   STATIC nExit     := NIL
   STATIC nExitTime := NIL
   STATIC nAlertTime := NIL
   STATIC nAlert
   STATIC nThread := 0

   IF ! lShow
      // Evito ricorsione
      lShow := .T.
      IF n1 != NIL .OR. n2 != NIL
//            nShowCount++
//         _Show(NIL, NIL, IIF(n1==NIL, nExit, n1), IIF(n2==NIL, nAlert, n2))
         IF n1 != NIL
            nExit := n1
            nExitTime := SECONDS() + n1
            IF nExitTime > 86400 // passata la mezzanotte?
               nExitTime -= 86400
            ENDIF
         ENDIF

         IF n2 != NIL
            nAlert := n2

            // mostra il primo avvertimento al massimo 3 secondi dopo l'avvio
            // non visualizzo subito all'avvio per problemi 
            // di gestione del focus
            nAlertTime := SECONDS() + 3 
            IF nAlertTime > 86400 // passata la mezzanotte?
               nAlertTime -= 86400
            ENDIF
         ENDIF

      ELSE
         IF nShowCount == 0      .AND. ; // se ancora non ha visualizzato
            ! dfInitScreenOpen()         // e non c'Š l'init screen aperto
            nAlertTime := SECONDS()-1    // mostra il messaggio
            IF nAlertTime > 86400 // passata la mezzanotte?
               nAlertTime -= 86400
            ENDIF
         ENDIF

         IF nAlertTime != NIL .AND. SECONDS() > nAlertTime
            nShowCount++
            //Modificato Luca. La Prima volta si visualizza solo per un secondo la Finestra informativa
            IF nShowCount == 1
               nWait := 1
            ELSE
               nWait := 10
            ENDIF
            _Show(nWait, NIL, IIF(n1==NIL, nExit, n1), IIF(n2==NIL, nAlert, n2))
            //_Show(NIL, NIL, IIF(n1==NIL, nExit, n1), IIF(n2==NIL, nAlert, n2))
            nAlertTime := SECONDS() + nAlert
            IF nAlertTime > 86400 // passata la mezzanotte?
               nAlertTime -= 86400
            ENDIF
         ENDIF

         IF nExitTime != NIL .AND. SECONDS() > nExitTime
            S2RealTimeDelAll()
            CLOSE ALL
            nShowCount++
            _Show(NIL, 1, IIF(n1==NIL, nExit, n1), IIF(n2==NIL, nAlert, n2))
            QUIT
         ENDIF

      ENDIF
      lShow := .F.
   ENDIF
   cChk := "k"+"5"+SUBSTR("set", 2, 1)+"0"+"j"+"J"+"j"

RETURN SECONDS()

  STATIC FUNCTION _show(nWait, nMsg, nSecT, nSecA)
     LOCAL lOpen := .F.
     LOCAL cMsg  := ""
     LOCAL cMsg1 := ""
     LOCAL nSec  := 0
     LOCAL nTime := 0
     LOCAL nPrevTime := 0
     LOCAL aObj
     LOCAL oDlg := AppDesktop()
     LOCAL cMsgIta
     LOCAL cMsgEng
     LOCAL oOwner
     LOCAL nTm1
     LOCAL oFocus := SetAppFocus()
     LOCAL aMsg

     IF EMPTY(nWait)  // Default 10 secondi
        nWait := 10
     ENDIF

     IF dfInitScreenOpen()
        lOpen := .T.
        dfInitScreenOff()
     ENDIF

/*

%app% Demo

%app% Š attualmente attivo in modalit… Dimostrativa che ha i seguenti limiti:
ú	%app% terminer… dopo 30 minuti di utilizzo
ú	%app% non potr… essere utilizzato dopo 30 giorni dall'installazione
ú	le tabelle non possono avere pi— di 10 campi
ú	il progetto non pu• avere pi— di 20 oggetti/entit…
ú	Š possibile solo creare applicazioni usando lo static link 
ú	le applicazioni generate terminano dopo 30 minuti di utilizzo


Per acquistare %app% contattare %swhouse% tramite:
ú	Email 		%email%
ú	Sito  		%www%
ú	Telefono 	%tel%
ú	Fax 		%fax%

Grazie per utilizzare %app%.

Il tuo %app% Team

%endline%

*/


     IF dfStdMsg(MSG_LANGUAGE) == "ITALIANO"

        aMsg := {"Attendere %1% secondi"                                      , ;
                 "La versione DEMO e' scaduta - Premi un tasto per terminare" , ;
                 "Premi un tasto per continuare"}

TEXT INTO cMsg WRAP 
{\rtf1\ansi\ansicpg1252\deff0\deflang1040{\fonttbl{\f0\fswiss\fprq2\fcharset0 Verdana;}{\f1\fswiss\fcharset0 Arial;}}
{\*\generator Msftedit 5.41.15.1503;}\viewkind4\uc1\pard\nowidctlpar\qc\kerning28\b\f0\fs32\par
%app% Demo\par
\pard\nowidctlpar\qj\par
\kerning0\b0\fs20 Questa applicazione \'e8 stata creata con \b %app% in versione Dimostrativa\b0 .\par###'
%app% \'e8 un prodotto \b %swhouse%\b0 . \par###'
\par
Questa applicazione ha i seguenti limiti:\par
\pard\nowidctlpar\fi-360\li720\qj\tx720\'b7\tab visualizza questa finestra ogni %nminA% minuti\par###'
\'b7\tab termina dopo %nminT% minuti di utilizzo\par###'
\par
\pard\nowidctlpar\qj Per acquistare \b %app%\b0  contattare \b %swhouse%\b0  tramite:\par
\pard\nowidctlpar\fi-360\li720\qj\tx720\lang2057\'b7\tab Email \tab\tab\b %email%\b0\par###'
\'b7\tab Sito  \tab\tab\b %www%\par###'
\pard\nowidctlpar\fi-360\li720\qj\b0\'b7\tab Telefono \tab\b %tel%\par###'
\pard\nowidctlpar\fi-360\li720\qj\tx720\lang1040\b0\'b7\tab Fax \tab\tab\b %fax%\par###'
\pard\nowidctlpar\qj\b0\par
Grazie per utilizzare %app%.\par
\par
\i Il tuo %app% Team\par
\i0\par
\pard\nowidctlpar\qc\b %endline%\par
\pard\nowidctlpar\b0\par
\f1\par
}
ENDTEXT

     ELSE

        aMsg := {"Please wait %1% seconds"                                        , ;
                 "The evaluation period has expired - Press any key to quit"      , ;
                 "Press any key to continue"}


TEXT INTO cMsg WRAP 
{\rtf1\ansi\ansicpg1252\deff0\deflang1040{\fonttbl{\f0\fswiss\fprq2\fcharset0 Verdana;}{\f1\fswiss\fcharset0 Arial;}}
{\*\generator Msftedit 5.41.15.1503;}\viewkind4\uc1\pard\nowidctlpar\qc\kerning28\b\f0\fs32\par
%app% Demo\par
\pard\nowidctlpar\qj\par
\kerning0\b0\fs20 This application is  created with \b %app% Demo version\b0 .\par
\par
This application has the following limits:\par
\pard\nowidctlpar\fi-360\li720\qj\tx720\'b7\tab show this window every %nminA% minutes\par###'
\'b7\tab terminates after %nminT% minutes\par###'
\par
\pard\nowidctlpar\qj To buy \b %app%\b0  please contact \b %swhouse%\b0 :\par
\pard\nowidctlpar\fi-360\li720\qj\tx720\lang2057\'b7\tab Email \tab\tab\b %email%\b0\par###'
\'b7\tab Web site\tab\b %www%\par###'
\pard\nowidctlpar\fi-360\li720\qj\b0\'b7\tab Phone\tab\tab\b %tel%\par###'
\pard\nowidctlpar\fi-360\li720\qj\tx720\lang1040\b0\'b7\tab Fax \tab\tab\b %fax%\par###'
\pard\nowidctlpar\qj\b0\par
\i Your %app% Team\par
\i0\par
\pard\nowidctlpar\qc\b %endline%\par
\pard\nowidctlpar\b0\par
\f1\par
}
ENDTEXT

     ENDIF

     // Simone 29/11/04 vedi PDR 5432 di Alaska software
     // workaround, nel TEXT INTO ho dovuto aggiungere la stringa "###'"
     // perche altrimenti con Xbase 1.82 non viene compilato questo prg 
     // in modalit… *NON* EVAL.. provare per credere
     // il compilatore da errore 
     //  XPP\DFXBASEI.PRG(211:0): error XBT0525: Newline character detected in string

     cMsg := STRTRAN(cMsg, "###'", "")

     cMsg := STRTRAN(cMsg,"%app%",APPNAME)
     cMsg := STRTRAN(cMsg,"%swhouse%", INFO_SWHOUSE)
     cMsg := STRTRAN(cMsg,"%tel%", INFO_TELNUMBER)
     cMsg := STRTRAN(cMsg,"%fax%", INFO_FAXNUMBER)
     cMsg := STRTRAN(cMsg,"%email%", INFO_EMAIL_COMM)
     cMsg := STRTRAN(cMsg,"%www%", INFO_URL_WEBSITE)
     cMsg := STRTRAN(cMsg,"%nminT%", ALLTRIM(STR(ROUND(nSecT/60, 0))))
     cMsg := STRTRAN(cMsg,"%nminA%", ALLTRIM(STR(ROUND(nSecA/60, 0))))

//     oOwner := VDBFindDlgFocus()
     DEFAULT oOwner TO S2FormCurr()
     DEFAULT oOwner TO SetAppWindow()
     DEFAULT oOwner TO AppDesktop()

     aObj := dfViewRtfDlg( oOwner,NIL, {500,480}, cMsg, APPNAME)

     aObj[1]:setModalState(XBP_DISP_APPMODAL)

     aObj[2]:setData( STRTRAN(cMsg,"%endline%", STRTRAN(aMsg[1], "%1%", STR(nWait, 2, 0)) ) ) // "Attendere %1% secondi"

     SetAppFocus(aObj[1])

     nSec := SECONDS()+nWait

     DO WHILE (nTime := nSec - SECONDS()) >= 0
        
        IF nPrevTime != nTime
           nPrevTime := nTime

           aObj[2]:setData( STRTRAN(cMsg,"%endline%", STRTRAN(aMsg[1], "%1%", STR(nTime, 2, 0)) ) ) // "Attendere %1% secondi"

        ENDIF

        // tolgo eventi dalla coda
        nTm1 := SECONDS()+1
        do while SECONDS() <= nTm1
           AppEvent(NIL, NIL, NIL, 1)
        enddo
     ENDDO

     IF nMsg == 1
        cMsg1 := aMsg[2] // VDBI18N("Tempo di valutazione scaduto  - Premi un tasto per terminare")
     ELSE
        cMsg1 := aMsg[3] //VDBI18N("Premi un tasto per continuare")
     ENDIF
     aObj[2]:setData( STRTRAN(cMsg,"%endline%", cMsg1) )

     aObj[2]:lbDown  := {|| aObj[1]:breakEventLoop()}
     aObj[2]:rbDown  := {|| aObj[1]:breakEventLoop()}
//     aObj[2]:lbClick := {|| aObj[1]:breakEventLoop()}
//     aObj[2]:rbClick := {|| aObj[1]:breakEventLoop()}
     aObj[2]:keyboard:= {|| aObj[1]:breakEventLoop()}
     aObj[1]:keyboard:= {|| aObj[1]:breakEventLoop()}

     dfViewRTFEventLoop(aObj[1])

     IF lOpen
        dfInitScreenOn()
     ELSE
        IF oFocus != NIL
           SetAppFocus(oFocus)
        ENDIF
     ENDIF
  RETURN NIL

//  static func vdbi18n(c, p1)
//     if p1 == NIL
//        return c
//     endif
//  return dfMsgTran(c, "1="+p1)

#ifdef IGNORE_THIS_oldshow
STATIC FUNCTION _show(nWait, nMsg)
   LOCAL lOpen := .F.
   LOCAL cMsg  := ""
   LOCAL cMsg1 := ""
   LOCAL nSec  := 0
   LOCAL nTime := 0
   LOCAL nPrevTime := 0

   IF EMPTY(nWait)  // Default 10 secondi
      nWait := 10
   ENDIF

   IF dfInitScreenOpen()
      lOpen := .T.
      dfInitScreenOff()
   ENDIF

   // dfAlert("This is an evaluation version of dBsee for Xbase++")

   /*
   cMsg := "Questa applicazione Š stata creata con dBsee for Xbase++ in versione//" + ;
           "di valutazione.                                                     //" + ;
           "                                                                    //" + ;
           "dBsee for Xbase++ Š prodotto da Albalog s.r.l. Puo' ordinarlo       //" + ;
           "presso Albalog s.r.l. - Via De' Bosis, 23 Firenze Tel. 055-300311   //" + ;
           "Fax 055-307149, sito web www.dbsee.it                               //" + ;
           "                                                                    //" + ;
           "--------------------------------------------------------------------//" + ;
           "                                                                    //" + ;
           "This applications is made with dBsee for Xbase++ Evaluation version //" + ;
           "                                                                    //" + ;
           "dBsee for Xbase++ is produced by Albalog s.r.l. You can order it at://" + ;
           "Albalog s.r.l. - Via De' Bosis, 23 - Florence - Italy               //" + ;
           "Tel ++39-055-300311, FAX ++39-055-307149, web site www.dbsee.com    //" 
   */
   cMsg := "//"+;
           "This applications is made with Visual Visual dBsee Evaluation version//" + ;
           "//" + ;
           "Visual dBsee is produced by Albalog s.r.l.//" + ;
           "You can order it at Albalog s.r.l. - Via De' Bosis, 23 - Florence - Italy Tel ++39-055-300311, FAX ++39-055-307149, web site www.VisualdBsee.com//" + ;
           "//" + ;
           "--------------------------------------------------------------------//" + ;
           "//" + ;
           "Questa applicazione Š stata creata con Visual dBsee in versione di valutazione//" + ;
           "//" + ;
           "Visual dBsee Š prodotto da Albalog s.r.l.//" + ;
           "Puo' ordinarlo presso Albalog s.r.l. - Via De' Bosis, 23 Firenze Tel. 055-300311 Fax 055-307149, sito web www.VisualdBsee.it//" 

   cMsg1 :="//" + ;
           "Please wait "+STR(nWait, 2, 0)+" seconds - Attendere "+STR(nWait, 2, 0)+" secondi//" + ;
           "//"

   nSec := SECONDS()+nWait

   dbMsgOn( _Wrap(cMsg+cMsg1) )

   cMsg := _Wrap(cMsg)

   DO WHILE (nTime := nSec - SECONDS()) >= 0

      sleep(50)

      IF nPrevTime != nTime
         nPrevTime := nTime
         cMsg1 :="//" + ;
                 "Please wait "+STR(nTime, 2, 0)+" seconds - Attendere "+STR(nTime, 2, 0)+" secondi//" + ;
                 "//"

         dbMsgUpd(cMsg+ _Wrap(cMsg1) )
      ENDIF
   ENDDO

   //sleep(nWait*100)

   cMsg += "//"
   IF nMsg == 1
      cMsg += "Evaluation time expired       - Press any key to exit//"+;
              "Tempo di valutazione scaduto  - Premi un tasto per terminare//"
   ELSE
      cMsg += "Press any key to continue - Premi un tasto per continuare//"
   ENDIF
   //cMsg += "//"
   dbMsgUpd( _Wrap(cMsg) )
   dbInk()
   dbMsgOff()
   IF lOpen
      dfInitScreenOn()
   ENDIF
RETURN NIL
#endif


// Crea una stringa con "a capo" automatici
STATIC FUNCTION _Wrap(cMsg, nLineLen, cSep, cLineSep)
   LOCAL aMsg := NIL
   LOCAL nInd := 0
   LOCAL nSep := 0
   LOCAL nAt  := 0


   IF EMPTY(nLineLen)
      nLineLen := 84
   ENDIF

   IF EMPTY(cLineSep)
      cLineSep := "//"
   ENDIF

   IF EMPTY(cSep)
      cSep := " ,.)]"
   ENDIF

   aMsg := dfStr2Arr(cMsg, cLineSep)

   cMsg := ""
   FOR nInd := 1 TO LEN(aMsg)
      DO WHILE .T.
         IF LEN(aMsg[nInd]) < nLineLen
            cMsg += aMsg[nInd] + cLineSep
            EXIT
         ENDIF

         // Cerco un separatore
         nSep := 0
         nAt  := 0
         DO WHILE nAt == 0 .AND. ++nSep <= LEN(cSep)
            nAt := RAT(cSep[nSep], aMsg[nInd])
         ENDDO
         IF nAt == 0
            nAt := LEN(aMsg[nInd])
         ENDIF

         cMsg += LEFT(aMsg[nInd], nAt)+ cLineSep
         aMsg[nInd] := SUBSTR(aMsg[nInd], nAt+1)

      ENDDO
   NEXT
RETURN cMsg
#endif

// // Premessa:
// //     Creando una finestra di tipo XbpCrt viene reso utilizzabile
// //     il font "Alaska Crt", che verr… utilizzato nelle maschere
// //     del programma
// //
// // Questa procedura crea 1 XbpStatic NON visibile con
// // all'interno un XbpCrt.
// // L'oggetto XbpCrt viene creato per utilizzare il font "Alaska Crt";
// // l'oggetto XbpStatic viene creato perchŠ senn• l'XbpCrt
// // Š visibile (non c'Š modo di non visualizzarlo).
//
// STATIC PROCEDURE CreateFont()
//    LOCAL oCrt
//    LOCAL oStatic
//    oStatic := XbpStatic():new(NIL, NIL, NIL, NIL, NIL, .F. ):create()
//    oCrt := XbpCrt():new(oStatic):create():destroy()
//    oCrt := NIL
//    oStatic:destroy()
//    oStatic := NIL
// RETURN


