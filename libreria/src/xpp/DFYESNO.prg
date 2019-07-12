#include "dfSet.ch"
#include "Xbp.ch"
#include "dfMsg.ch"
#include "dfMsg1.ch"
#include "dfXRes.ch"
#include "Common.ch"

FUNCTION dfYesNo(cMsg, lDefault, cTitle)
   STATIC lInit := .F., nFG, nBG
   LOCAL oFocus := SetAppFocus()
   LOCAL nRet := 0
   LOCAL aColor
   LOCAL oMainDisable 
   LOCAL cColorFG
   LOCAL cColorBG

   DEFAULT lDefault TO .F.
   DEFAULT cTitle TO dfStdMsg1(MSG1_DFYESNO01)

   IF lInit == .F. 
      lInit := .T.
      aColor:=dfColor( "MessageColor" )        // Errore il messaggio d'errore
      IF EMPTY(aColor) .OR. LEN(aColor)<8      // ??? RICORDARSI ??? allineamento
         aColor := {"W+/B",  "GR/B", "RB+/B", "W+/B" ,;
                    "W+/B", "GR+/B", "GR+/B", "G/B"   }
      ENDIF
      S2ItmSetColors({|n| nFG:=n}, {|n| nBG:=n}, .T., aColor[AC_MSG_RESIDENTSAY])


      ////////////////////////////////////////////////////////
      //Luca del 27/09/2012
      //Mantis 2204
      cColorFG := dfSet("XbasedfYesNoMsgColorFG")
      cColorBG := dfSet("XbasedfYesNoMsgColorBG")

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

   nRet := AlertBox(S2FormCurr(), dbMMRg(dfAny2Str(cMsg)), ;
                    {{dfStdMsg(MSG_STD_YES), BUTT_OK}, {dfStdMsg(MSG_STD_NO), BUTT_CANCEL}}, ;
                    XBPSTATIC_SYSICON_ICONQUESTION, cTitle, IIF(lDefault, 1, 2), ;
                    dfSet(AI_XBASEMESSAGECENTERED), nFG, nBG)

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
 
RETURN nRet == 1


// FUNCTION dfYesNo(cMsg)
//    LOCAL oFocus := SetAppFocus()
//    LOCAL lRet := ConfirmBox(oFocus, S2MultiLineCvt(dbMMrg(cMsg)), NIL, ;
//                             XBPMB_YESNO, XBPMB_QUESTION) == XBPMB_RET_YES
//
//    IF oFocus != NIL
//       SetAppFocus(oFocus)
//    ENDIF
// RETURN lRet
