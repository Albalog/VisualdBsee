#include "Common.ch"
#include "dfStd.ch"
#include "dfSet.ch"
#include "Xbp.ch"
#include "dfMsg1.ch"

FUNCTION dbMsgErr(cMsg,cTitle,nIcon)
   STATIC lInit := .F., nFG, nBG
   LOCAL oFocus := SetAppFocus()
   LOCAL nRet := 0
   LOCAL aColor
   LOCAL oMainDisable 

   DEFAULT cTitle TO dfStdMsg1(MSG1_DBMSGERR01)
   DEFAULT nIcon  TO XBPSTATIC_SYSICON_ICONERROR

   IF lInit == .F. 
      lInit := .T.
      aColor:=dfColor( "MessageColor" )        // Errore il messaggio d'errore
      IF EMPTY(aColor) .OR. LEN(aColor)<8      // ??? RICORDARSI ??? allineamento
         aColor := {"W+/B",  "GR/B", "RB+/B", "W+/B" ,;
                    "W+/B", "GR+/B", "GR+/B", "G/B"   }
      ENDIF
      S2ItmSetColors({|n| nFG:=n}, {|n| nBG:=n}, .T., aColor[AC_MSG_RESIDENTSAY])
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

   nRet := AlertBox(S2FormCurr(), dbMMrg(dfAny2Str(cMsg)), NIL, nIcon, ;
                    cTitle, NIL, dfSet(AI_XBASEMESSAGECENTERED), nFG, nBG)

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

