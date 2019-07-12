#include "common.ch"
#include "dfMsg.ch"
#include "dfMsg1.ch"
#include "dfWinRep.ch"
#include "dfReport.ch"

MEMVAR ACT

// FUNCTION dfXPrnMenuDisp(xDisp)
//    STATIC oDisp := NIL
//    IF xDisp != NIL
//       oDisp := xDisp
//    ENDIF
// RETURN oDisp
//
// FUNCTION dfXPrnMenuDispExecute(oDisp)
//    LOCAL xRet  := NIL
//
//    DEFAULT oDisp TO dfXPrnMenuDisp()
//
//    IF ! EMPTY(oDisp)
//       xRet := oDisp:execute()
//    ENDIF
// RETURN xRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION _dfXPrnMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet  := .T., cDmm
LOCAL cFILE := ""
MEMVAR EnvId

DEFAULT nUserMenu   TO PM_MENU
DEFAULT cIdPrinter  TO aBuf[REP_PRINTERID  ]
DEFAULT cIdPort     TO aBuf[REP_PRINTERPORT]
dfPrnSet( aBuf, cIdPrinter, .T. )

cIdPort    := UPPER(ALLTRIM(cIdPort))
aBuf[REP_PRINTERPORT] := cIdPort

//Mantis 2131 23/08/2010
//CORRETTO problema di stampa su stampante di rete
IF !(LEFT(cIdPort,3)=="LPT"   .OR.;
     LEFT(cIdPort,3)=="COM"   .OR.;
     LEFT(cIdPort,5)=="VIDEO" .OR.;
     (LEFT(cIdPort,2)=="\\" .AND. dfUncPathIsPrinter(cIdPort) )) // Tommaso + Simone 08/04/10 - EXCEL 2058
//     LEFT(cIdPort,2)=="\\")   // porta UNC
   aBuf[REP_PRINTERPORT] := "FILE"
   aBuf[REP_FNAME]       := cIdPort
ENDIF

aBuf[REP_FNAME] := ALLTRIM(aBuf[REP_FNAME])
aBuf[REP_FNAME] := PADR(aBuf[REP_FNAME],MAX(50,LEN(aBuf[REP_FNAME])))
IF !dfSet( AI_DISABLEMGNOPT ) .AND. !EMPTY( aBuf[REP_VREC] )
   aBuf[REP_MGN_TOP] := dfPrnMaxTop( aBuf, aBuf[REP_VREC] )
ENDIF

// DO CASE
//    CASE EMPTY(dfWinPrinters())
//         dbMsgErr("Nessuna stampante installata.//"+;
//                  "E' necessario installare una stampante nel sistema.")
//         lRet := .F.
//
//    CASE nUserMenu == PM_MENU
//         IF dBsee45Win()
//            lRet := df5GetParam( aBuf )
//         ELSE
//            lRet := dfGetParam( aBuf )
//         ENDIF
//         IF lRet
//            dfUpdRep( EnvId, aBuf )
//            IF M->Act=="new"
//               aBuf[REP_PRINTERPORT] := "VIDEO"
//            ENDIF
//         ENDIF
//
//    CASE nUserMenu == PM_MESSAGE
//         dbMsgErr( dfStdMsg(MSG_DFPRNSTART02) +aBuf[REP_NAME] )
//
//    CASE nUserMenu == PM_NUL
//
// ENDCASE

IF EMPTY(dfWinPrinters()) .AND. ;
   ( EMPTY(aBuf[REP_XBASEREPORTTYPE]) .OR. ;
     ! isMethod(aBuf[REP_XBASEREPORTTYPE], "reportType") .OR. ;
     aBuf[REP_XBASEREPORTTYPE]:reportType() == REP_XBASE_RT_DBSEE)
   dbMsgErr(dfStdMsg1(MSG1_DFPRNMENU08))
   lRet := .F.
ELSE

   IF dBsee45Win()
      lRet := df5GetParam( aBuf )
   ELSE
      lRet := dfGetParam( aBuf, nUserMenu )
   ENDIF
   IF lRet
      dfUpdRep( EnvId, aBuf )
      IF M->Act=="new"
         aBuf[REP_PRINTERPORT] := "VIDEO"
      ENDIF
   ENDIF

ENDIF

IF lRet

   aBuf[REP_FOOTER_LINE] := aBuf[REP_PAGELENGHT] -aBuf[REP_MGN_BOTTOM]
   aBuf[REP_PRINTERPORT] := UPPER(ALLTRIM( aBuf[REP_PRINTERPORT] ))

   // LAYOUT
   // IF aBuf[REP_PRINTERPORT]=="VIDEO"
   //    aBuf[REP_SETUP      ] := DFWINREP_SETUP
   //    aBuf[REP_RESET      ] := DFWINREP_RESET
   //    aBuf[REP_BOLD_ON    ] := DFWINREP_BOLDON
   //    aBuf[REP_BOLD_OFF   ] := DFWINREP_BOLDOFF
   //    aBuf[REP_ENL_ON     ] := DFWINREP_ENLARGEDON
   //    aBuf[REP_ENL_OFF    ] := DFWINREP_ENLARGEDOFF
   //    aBuf[REP_UND_ON     ] := DFWINREP_UNDERLINEON
   //    aBuf[REP_UND_OFF    ] := DFWINREP_UNDERLINEOFF
   //    aBuf[REP_SUPER_ON   ] := DFWINREP_SUPERSCRIPTON
   //    aBuf[REP_SUPER_OFF  ] := DFWINREP_SUPERSCRIPTOFF
   //    aBuf[REP_SUBS_ON    ] := DFWINREP_SUBSCRIPTON
   //    aBuf[REP_SUBS_OFF   ] := DFWINREP_SUBSCRIPTOFF
   //    aBuf[REP_COND_ON    ] := DFWINREP_CONDENSEDON
   //    aBuf[REP_COND_OFF   ] := DFWINREP_CONDENSEDOFF
   //    aBuf[REP_ITA_ON     ] := DFWINREP_ITALICON
   //    aBuf[REP_ITA_OFF    ] := DFWINREP_ITALICOFF
   //    aBuf[REP_NLQ_ON     ] := DFWINREP_NLQON
   //    aBuf[REP_NLQ_OFF    ] := DFWINREP_NLQOFF
   //    aBuf[REP_USER1ON    ] := DFWINREP_USER01ON
   //    aBuf[REP_USER1OFF   ] := DFWINREP_USER01OFF
   //    aBuf[REP_USER2ON    ] := DFWINREP_USER02ON
   //    aBuf[REP_USER2OFF   ] := DFWINREP_USER02OFF
   //    aBuf[REP_USER3ON    ] := DFWINREP_USER03ON
   //    aBuf[REP_USER3OFF   ] := DFWINREP_USER03OFF
   // ELSEIF aBuf[REP_PRINTERPORT]=="FILE"
   //    aBuf[REP_SETUP      ] := ""
   //    aBuf[REP_RESET      ] := ""
   //    aBuf[REP_BOLD_ON    ] := ""
   //    aBuf[REP_BOLD_OFF   ] := ""
   //    aBuf[REP_ENL_ON     ] := ""
   //    aBuf[REP_ENL_OFF    ] := ""
   //    aBuf[REP_UND_ON     ] := ""
   //    aBuf[REP_UND_OFF    ] := ""
   //    aBuf[REP_SUPER_ON   ] := ""
   //    aBuf[REP_SUPER_OFF  ] := ""
   //    aBuf[REP_SUBS_ON    ] := ""
   //    aBuf[REP_SUBS_OFF   ] := ""
   //    aBuf[REP_COND_ON    ] := ""
   //    aBuf[REP_COND_OFF   ] := ""
   //    aBuf[REP_ITA_ON     ] := ""
   //    aBuf[REP_ITA_OFF    ] := ""
   //    aBuf[REP_NLQ_ON     ] := ""
   //    aBuf[REP_NLQ_OFF    ] := ""
   //    aBuf[REP_USER1ON    ] := ""
   //    aBuf[REP_USER1OFF   ] := ""
   //    aBuf[REP_USER2ON    ] := ""
   //    aBuf[REP_USER2OFF   ] := ""
   //    aBuf[REP_USER3ON    ] := ""
   //    aBuf[REP_USER3OFF   ] := ""
   // ENDIF

   // File di Output
   IF !(aBuf[REP_PRINTERPORT]=="FILE" .AND. !EMPTY( aBuf[REP_FNAME] )) // Report Name
     // aBuf[REP_FHANDLE] := dfFileTemp( @cDmm )  // Report Handle
      cDmm  := dfFNameSplit(aBuf[REP_FNAME], 1+2)
      cFile := dfFNameSplit(aBuf[REP_FNAME], 4) 
      IF FILE(aBuf[REP_FNAME])
         aBuf[REP_FHANDLE] := dfFileTemp( @cDmm, cFile, LEN(cFile)+2, dfFNameSplit(aBuf[REP_FNAME], 8)  )  // Report Handle
         IF EMPTY(dfFNameSplit(cDMM, 4) )
            cDMM := "FILE"
         ENDIF 
         aBuf[REP_FNAME]   := cDmm
      ELSE
         aBuf[REP_FHANDLE] := FCREATE( aBuf[REP_FNAME] )
      ENDIF 
      FCLOSE( aBuf[REP_FHANDLE] )
   ELSE
      FCLOSE( FCREATE( aBuf[REP_FNAME] ) )
   ENDIF

   //FCLOSE( FCREATE( aBuf[REP_FNAME] ) )

ENDIF

aBuf[REP_IS_ABORT] := !lRet

RETURN lRet



// Dispositivi di stampa di default
//
// Per memorizzare i disp. di default
// uso un codeblock invece di un array
// altrimenti ho problemi
// perchŠ gli array e/o oggetti rimangono
// inizializzati dopo la prima stampa

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfXPrnMenuDispDef(bDisp)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   STATIC bDef

   IF PCOUNT() > 0 // se ho un parametro
      bDef := bDisp
   ENDIF

   IF bDef == NIL
      bDef := {|| { S2PrintDispWinPrinter():new(), ;  // stampa su Stampante Windows
                    S2PrintDispDOSPrinter():new(), ;  // stampa su Stampante DOS
                    S2PrintDispFile():new()      , ;  // stampa su FILE
                    S2PrintDispClipboard():new() , ;  // stampa su Appunti
                    S2PrintDispMAPIFax():new()   , ;  // stampa su Fax (MAPI)
                    S2PrintDispMAPIMail():new()  , ;  // stampa su Email (MAPI)
                    S2PrintDispSMTPMail():new()    }} // stampa su Email (SMTP)
   ENDIF
RETURN EVAL(bDef)


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfXPrnMenuCRWDispDef(bDisp)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   STATIC bDef

   IF PCOUNT() > 0 // se ho un parametro
      bDef := bDisp
   ENDIF

   IF bDef == NIL
      bDef := {|| { S2PrintDispCRWPrinter():new(), ;  // stampa su Stampante Windows
                    S2PrintDispCRWFile():new()   , ;  // stampa su FILE (esportazione)
                    S2PrintDispCRWMAPIMail():new(),;  //  , ;  // stampa su Email (MAPI)
                    S2PrintDispCRWSMTPMail():new() }} // stampa su Email (SMTP)
//                    S2PrintDispMAPIFax():new()   , ;  // stampa su Fax (MAPI)
   ENDIF
RETURN EVAL(bDef)


// simone 18/2/08
// 0000652: i report di tipo reportmanager non hanno menu di stampa
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfXPrnMenuRMDispDef(bDisp)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   STATIC bDef

   IF PCOUNT() > 0 // se ho un parametro
      bDef := bDisp
   ENDIF            

   IF bDef == NIL
      bDef := {|| { S2PrintDispRMPrinter():new() , ;  // stampa su Stampante Windows
                    S2PrintDispRMFile():new(), ;  //  , ;  // stampa su FILE (esportazione)
                    S2PrintDispRMMAPIMail():new(), ;  //  , ;  // stampa su Email (MAPI)
                    S2PrintDispRMSMTPMail():new()  ;  //  , ;  // stampa su Email (SMTP)
                  } }
//                    S2PrintDispMAPIFax():new()   , ;  // stampa su Fax (MAPI)
   ENDIF
RETURN EVAL(bDef)

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfGetParam( aBuf, nUserMenu )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   STATIC aColor

   LOCAL oPrn
   LOCAL lRet
   LOCAL aDisp
   LOCAL nPos
   LOCAL nAction
   LOCAL oPrinter
   LOCAL cPrinter

   IF aColor == NIL
      aColor:=dfColor( "MessageColor" )        // Errore il messaggio d'errore
      IF EMPTY(aColor) .OR. LEN(aColor)<8      // ??? RICORDARSI ??? allineamento
         aColor := {"W+/B",  "GR/B", "RB+/B", "W+/B" ,;
                    "W+/B", "GR+/B", "GR+/B", "G/B"   }
      ENDIF
   ENDIF

   oPrn := S2PrintMenu():New()

   // simone 27/6/2005
   // mantis 0000794: il menu di stampa windows non visualizza il nome della stampa
   IF ! EMPTY(aBuf[REP_NAME])
      oPrn:title += " - "+aBuf[REP_NAME]
   ENDIF

   IF ! EMPTY(aBuf[REP_FNAME])
      oPrn:title += " - "+aBuf[REP_FNAME]
   ENDIF

   oPrn:aBuffer := aBuf

   IF VALTYPE(aBuf[REP_XBASEUSERPRNDISP])== "A"
      aDisp := aBuf[REP_XBASEUSERPRNDISP]
   ENDIF

   DO CASE
      CASE EMPTY(aBuf[REP_XBASEREPORTTYPE]) 

           DEFAULT aDisp TO dfXPrnMenuDispDef() // Utilizzo dispositivi di default

      CASE aBuf[REP_XBASEREPORTTYPE]:reportType() == REP_XBASE_RT_DBSEE
           // dispositivi di default del Report standard 

           DEFAULT aDisp TO aBuf[REP_XBASEREPORTTYPE]:getDefaultDisp() //dfXPrnMenuDispDef() // Utilizzo dispositivi di default

      CASE aBuf[REP_XBASEREPORTTYPE]:reportType() == REP_XBASE_RT_CRW
           // Crystal report

           oPrn:lBtnMargShow := .F.
           oPrn:lCharShow := .F.

           // Dispositivo di anteprima
           oPrn:oPreview := aBuf[REP_XBASEREPORTTYPE]:getPreviewDisp(oPrn:grpDispositivi) //S2PrintDispCRWPreview():new(oPrn:grpDispositivi)

           DEFAULT aDisp TO aBuf[REP_XBASEREPORTTYPE]:getDefaultDisp() //dfXPrnMenuCRWDispDef() // Utilizzo dispositivi di default

      CASE aBuf[REP_XBASEREPORTTYPE]:reportType() == REP_XBASE_RT_REPORTMANAGER
           // simone 18/2/08
           // 0000652: i report di tipo reportmanager non hanno menu di stampa
           // ReportManager

           oPrn:lBtnMargShow := .F.
           oPrn:lCharShow := .F.

           // Dispositivo di anteprima
           oPrn:oPreview := aBuf[REP_XBASEREPORTTYPE]:getPreviewDisp(oPrn:grpDispositivi) // S2PrintDispRMPreview():new(oPrn:grpDispositivi)
           /////////////////////////////////////////////
           //Correzione per settaggio passati ai Buffer 
           //Aggiunto luca il 14/10/2010
           /////////////////////////////////////
           oPrn:oPreview:aBuffer := aBuf
           /////////////////////////////////////////////
           /////////////////////////////////////

           DEFAULT aDisp TO aBuf[REP_XBASEREPORTTYPE]:getDefaultDisp() // dfXPrnMenuRMDispDef() // Utilizzo dispositivi di default

   ENDCASE

   AEVAL(aDisp, {|oDisp| oPrn:addDisp(oDisp) })

   S2ObjSetColors(oPrn:drawingArea, .T., aColor[AC_MSG_RESIDENTSAY])

   oPrn:Create()

   oPrn:tbConfig()

   IF nUserMenu == PM_MENU
      oPrn:show()

      oPrn:tbInk()

   ELSE

      // PM_MESSAGE o PM_NUL
      IF nUserMenu == PM_MESSAGE
         dfAlert( dfStdMsg(MSG_DFPRNSTART02) +aBuf[REP_NAME] )
      ENDIF

      nAction := 1

      // SD 4/mar/03 GERR 3353
      IF UPPER(ALLTRIM(aBuf[REP_PRINTERPORT]))=="VIDEO"
         oPrn:oPreview:setCurrDisp(oPrn:oCurrDisp)
         oPrn:oCurrDisp := oPrn:oPreview
         nAction := 2
      ENDIF

      // LC 4/mar/08 
      IF UPPER(ALLTRIM(aBuf[REP_PRINTERPORT]))=="FILE"
         oPrn:oPreview:setCurrDisp(oPrn:oCurrDisp)
         //oPrn:oCurrDisp := oPrn:oPreview
         DO CASE
            CASE EMPTY(aBuf[REP_XBASEREPORTTYPE]) .OR. ; 
                 aBuf[REP_XBASEREPORTTYPE]:reportType() == REP_XBASE_RT_DBSEE
              oPrn:oCurrDisp :=  aDisp[3]
            CASE aBuf[REP_XBASEREPORTTYPE]:reportType() == REP_XBASE_RT_REPORTMANAGER
              oPrn:oCurrDisp :=  aDisp[2]//S2PrintDispRMFile():new()
            CASE aBuf[REP_XBASEREPORTTYPE]:reportType() == REP_XBASE_RT_CRW
              oPrn:oCurrDisp :=  aDisp[2]// S2PrintDispCRWFile():new()
         ENDCASE
         nAction := 2
      ENDIF


      oPrn:nAction := oPrn:oCurrDisp:exitMenu(nAction, oPrn:aBuffer)
   ENDIF

   IF oPrn:nAction > 0
      // dfXPrnMenuDisp(oPrn:oCurrDisp)
      aBuf[REP_XBASEPRINTDISP] := oPrn:oCurrDisp
      lRet := .T.
      ACT  := "ret"

      ////////////////////////////////////////
      //Luca 13/07/2015 Effettuata correzione per settare stampante utilizzata per prossimo riutilizzo
      IF IsMemberVar(aBuf[REP_XBASEPRINTDISP],"oPrinter") 
        oPrinter := aBuf[REP_XBASEPRINTDISP] 
        IF IsMemberVar(oPrinter,"oPrinter") 
           oPrinter  := oPrinter:oPrinter
           cPrinter := oPrinter:devName
           cPrinter :=  dfGetPrnID( cPrinter )
           dfPrnSet( aBuf,  cPrinter  )
        ENDIF 
      ENDIF 
      ////////////////////////////////////////
   ELSE
      lRet := .F.
      ACT := "esc"
   ENDIF

   //dfPrnSet( aBuf, dfGetPrnID( cPrinter ) )
   //Luca 13/07/2015 disabilitato da questo puntio perche non salva la stamapnte corretta 
   //   dfPrnSet( aBuf, dfGetPrnID( "" ) )
   oPrn:tbEnd()

   oPrn:destroy()

RETURN lRet
