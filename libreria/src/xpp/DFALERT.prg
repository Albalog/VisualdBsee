#include "Xbp.ch"
#include "dfSet.ch"
#include "dfMsg1.ch"
#include "common.ch"

FUNCTION dfAlert(cMsg, aOpt, nDefault, cTitle)
   STATIC lInit := .F., nFG, nBG
   LOCAL oFocus := SetAppFocus()
   LOCAL nRet := 0
   LOCAL aColor
   LOCAL oMainDisable 
   LOCAL cColorFG
   LOCAL cColorBG


   DEFAULT cTitle TO dfStdMsg1(MSG1_DFALERT01)

   IF lInit == .F. 
      lInit := .T.
                                               // Evito che mi possa dare
      aColor:=dfColor( "MessageColor" )        // Errore il messaggio d'errore
      IF EMPTY(aColor) .OR. LEN(aColor)<8      // ??? RICORDARSI ??? allineamento
         aColor := {"W+/B",  "GR/B", "RB+/B", "W+/B" ,;
                    "W+/B", "GR+/B", "GR+/B", "G/B"   }
      ENDIF

      S2ItmSetColors({|n| nFG:=n}, {|n| nBG:=n}, .T., aColor[AC_MSG_RESIDENTSAY])

      ////////////////////////////////////////////////////////
      //Luca del 27/09/2012
      //Mantis 2204
      cColorFG := dfSet("XbasedfAlertMsgColorFG")
      cColorBG := dfSet("XbasedfAlertMsgColorBG")

      IF cColorBG != NIL
         IF S2IsNumber(cColorBG) .AND. VAL(cColorBG) <> 0
            nBG  := INT(VAL(cColorBG))
         ENDIF
      ENDIF

      IF cColorFG != NIL
         IF S2IsNumber(cColorFG) .AND. VAL(cColorFG) <> 0
            nFG  := INT(VAL(cColorFG))
         ENDIF
      ENDIF
      ////////////////////////////////////////////////////////


   ENDIF

   // simone 20/11/08 mantis 2040
   // Disabilito il main menu!!
   IF dfAnd( dfSet(AI_XBASEMAINMENUMDI), AI_MENUMDI_ENABLED) != 0 .AND. ;
      dfSetMainWin() != NIL      .AND. ;
      dfSetMainWin():isEnabled() .AND. ;
      dfSetMainWin():isVisible()

      dfSetMainWin():disable()
      oMainDisable := dfSetMainWin()
   ENDIF

   nRet := AlertBox(S2FormCurr(), dbMMrg(dfAny2Str(cMsg)), aOpt, ;
                    XBPSTATIC_SYSICON_ICONINFORMATION, ;
                    cTitle, ;
                    nDefault, dfSet(AI_XBASEMESSAGECENTERED), ;
                    nFG, nBG)

   // simone 20/11/08 mantis 2040
   IF oMainDisable != NIL
      oMainDisable:enable()
   ENDIF

   IF oFocus != NIL
      SetAppFocus(oFocus)

      //Maudp-LucaC 28/06/2012 In alcuni casi arrivava in questo punto dopo l'alertbox, senza il W_currentGet impostato
      IF !S2FormCurr()==NIL .AND. isMethod(S2FormCurr(),"UpdateCurrentGet")
         S2FormCurr():UpdateCurrentGet()
      ENDIF
   ENDIF
RETURN nRet

