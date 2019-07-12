#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "AppEvent.ch"
#include "dfMsg1.ch"
#include "dfSet.ch"
#include "dfWin.ch"
#include "dfStd.ch"

#define S2PI_MSG_BREAK        dfStdMsg1(MSG1_S2PI01) // "Interrompere ?"
#define S2PI_MSG_BTNOK        dfStdMsg1(MSG1_S2PI02) // "Annulla"
#define S2PI_MSG_BTNPRESSED   dfStdMsg1(MSG1_S2PI03) // "Attendere"
#define S2PI_MSG_WAIT         dfStdMsg1(MSG1_S2PI04) // "Attendere prego..."
#define S2PI_BTNAREA_HEIGHT   30

CLASS S2ProgressIndicator FROM S2Dialog
   EXPORTED:
   VAR oText, oFrame, oPerc, PI, nPerc, oBtn, lPush, oIcon, lButton

   METHOD Init, Create, DoStep, On, Off, BtnPressed, BtnKeyHandler, chkEvent
   METHOD SetCaption
ENDCLASS

#ifdef OLD_STYLE
 METHOD S2ProgressIndicator:Init()
    ::S2Dialog:init(7,20,16,60,;
                   NIL    , NIL   , NIL , NIL  , NIL, NIL     ,W_COORDINATE_ROW_COLUMN)   

    ::oIcon := S2Icon():new(::drawingArea, , {10,130}, {60 ,60}, NIL, .T. )
    ::oIcon:SetIcon( XBPSTATIC_SYSICON_WAIT )

    ::oText:= S2Txt():new(::drawingArea, , {80,130}, {400,60}, NIL, .T. )
    ::oText:type := XBPSTATIC_TYPE_RECESSEDBOX
    ::oText:textArea:options := XBPSTATIC_TEXT_CENTER + XBPSTATIC_TEXT_VCENTER
    ::oText:textArea:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_CENTER+XBPSTATIC_TEXT_WORDBREAK

    ::oFrame:= XbpStatic():new(::drawingArea, , {10,60}, {470,60}, NIL, .T. )
    ::oFrame:type := XBPSTATIC_TYPE_RECESSEDBOX

    ::PI := ProgressBar():new(::oFrame, , {10,20}, {450,24}, NIL, .T. )

    ::oPerc := XbpStatic():new(::oFrame, , {10,2}, {450,14}, NIL, .T. )
    ::oPerc:options := XBPSTATIC_TEXT_CENTER

    ::oBtn := XbpPushButton():new( ::drawingArea, , {200, 10}, {100,30}, NIL, .F. )

    ::oBtn:caption := S2PI_MSG_BTNOK
    ::oBtn:activate := {|| ::BtnPressed() }
    ::oBtn:preSelect := .T.
    ::oBtn:tabStop := .T.
    ::oBtn:keyboard := {|nKey,mp2,obj| ::BtnKeyHandler( nKey, obj ) }

    ::nPerc := 0
    ::PI:minimum := 1
    ::PI:Maximum := 10000
    ::PI:current := 1
    ::lPush := .F.
 RETURN self

#else

METHOD S2ProgressIndicator:Init(lThread)
   LOCAL aPP, aColor

   DEFAULT lThread TO .F.

   aColor:=dfColor( "ProgressIndicator" )        // Errore il messaggio d'errore
   IF EMPTY(aColor) 
      aColor := {"W+/B",  "GR/B", "RB+/B", "B+/RB" , "GR/RB" }
   ENDIF
   ::S2Dialog:init(7,20,16,60,;
                   NIL    , NIL   , NIL , NIL  , NIL, NIL     ,W_COORDINATE_ROW_COLUMN) 

   IF aColor != NIL
      S2ObjSetColors(::drawingArea, .T., aColor[AC_PI_SAY])
   ENDIF


   ::oIcon := XbpStatic():new(::drawingArea, , { 5,114}, {32 ,32}, NIL, .T. )
   ::oIcon:type := XBPSTATIC_TYPE_SYSICON
   ::oIcon:SetCaption( XBPSTATIC_SYSICON_WAIT )

   ::oText:= XbpStatic():new(::drawingArea, , {45,92}, {300,60}, NIL, .T. )
   ::oText:options := XBPSTATIC_TEXT_WORDBREAK

   IF lThread
      ::PI := ThreadProgressBar():new(::drawingArea, , {45,66}, {350,16}, NIL, .T. )
   ELSE
      ::PI := ProgressBar():new(::drawingArea, , {45,66}, {350,16}, NIL, .T. )
   ENDIF

   IF aColor != NIL
      S2ItmSetColors({|n| ::PI:color:=n }, {|n| ::PI:colorBG:=n }, ;
                     .T., aColor[AC_PI_PROGRESS])
   ENDIF

   ::oPerc := XbpStatic():new(::drawingArea, , {45,46}, {350,14}, NIL, .T. )
   ::oPerc:options := XBPSTATIC_TEXT_CENTER

   ::oBtn := XbpPushButton():new( ::drawingArea, , {335, 10}, {60,26}, NIL, .F. )

   ::oBtn:caption := S2PI_MSG_BTNOK
   ::oBtn:activate := {|| ::BtnPressed() }
   ::oBtn:preSelect := .T.
   ::oBtn:tabStop := .T.
   ::oBtn:keyboard := {|nKey,mp2,obj| ::BtnKeyHandler( nKey, obj ) }

   ::nPerc := 0
   ::PI:minimum := 1
   ::PI:Maximum := 10000
   ::PI:current := 1
   ::lPush := .F.
RETURN self
#endif

METHOD S2ProgressIndicator:BtnKeyHandler( nKey, oButton, aPushButtons )
   IF nKey == xbeK_ESC .OR. nKey == xbeK_RETURN
      PostAppEvent( xbeP_Activate,,, oButton )
   ENDIF
RETURN self

METHOD S2ProgressIndicator:setCaption(cMsg)
   LOCAL lRet
   #ifdef OLD_SYTLE
   lRet := ::oText:SetText(S2MultiLineCvt(cMsg))
   #else
   lRet := ::oText:SetCaption(S2MultiLineCvt(cMsg))
   #endif
RETURN lRet

METHOD S2ProgressIndicator:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oFocus := SetAppFocus() // WorkAround

   // S2FocusPush()

   ::S2Dialog:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::oText:create()
   ::oIcon:create()

   #ifdef OLD_STYLE
      ::oFrame:create()
   #endif
   ::oPerc:create()
   ::PI:create()
   ::oBtn:create()  // <- Attenzione: Questo cambia l'oggetto che ha il focus!

   IF oFocus != NIL
      SetAppFocus(oFocus)
   ENDIF

   // S2FocusPop()  // <- il focus POP non funge con alaska 1.165

RETURN self

METHOD S2ProgressIndicator:On(cTitle, cMsg, lButton)
   LOCAL aCoords, aSize

   DEFAULT cTitle  TO ""
   DEFAULT cMsg    TO S2PI_MSG_WAIT
   DEFAULT lButton TO .T.

   ::title := cTitle
   ::sysMenu:=.F.
   ::taskList := .F.
   ::Create()

   ::setSize({420,180})
   ::centerPos()

   ::tbConfig()

   ::setCaption(cMsg)

   ::lButton := lButton

   IF ! lButton
      aSize := ::CurrentSize()
      aSize[2] -= S2PI_BTNAREA_HEIGHT

      aCoords := ::CurrentPos()
      aCoords[2] -= S2PI_BTNAREA_HEIGHT/2
      #ifdef _XBASE15_
         ::setPosAndSize(aCoords, aSize)
      #else
         ::setSize(aSize)
         ::setPos(aCoords)
      #endif

      aCoords := ::oIcon:CurrentPos()
      aCoords[2] -= S2PI_BTNAREA_HEIGHT
      ::oIcon:SetPos(aCoords)

      aCoords := ::oText:CurrentPos()
      aCoords[2] -= S2PI_BTNAREA_HEIGHT
      ::oText:SetPos(aCoords)

      #ifdef OLD_STYLE
         aCoords := ::oFrame:CurrentPos()
         aCoords[2] -= S2PI_BTNAREA_HEIGHT
         ::oFrame:SetPos(aCoords)
      #endif

   ENDIF
   ::show()

   IF lButton
      ::oBtn:show()
      SetAppFocus(::oBtn)
   ENDIF
RETURN self

METHOD S2ProgressIndicator:Off()
   ::tbEnd()
   ::destroy()
RETURN self

METHOD S2ProgressIndicator:BtnPressed()
   IF ! ::lPush
      ::lPush := .T.
      ::oBtn:SetCaption(S2PI_MSG_BTNPRESSED)
      ::oBtn:disable()
   ENDIF
RETURN

METHOD S2ProgressIndicator:DoStep(nCurr, nMax, cMsg)
   LOCAL nPerc := INT(DFFIXDIV(10000*nCurr, nMax))
   LOCAL lRet := .T.

   IF ::lButton
      ::chkEvent()

      IF ::lPush
         DEFAULT cMsg TO S2PI_MSG_BREAK
         lRet := ! dfYesNo(cMsg)

         ::lPush := .F.

         ::oBtn:SetCaption(S2PI_MSG_BTNOK)
         ::oBtn:enable()
         SetAppFocus(::oBtn)

      ENDIF
   ENDIF


   ::PI:increment( nPerc - ::nPerc )

   ::nPerc := nPerc

   ::oPerc:SetCaption(ALLTRIM(STR(::nPerc/100,10,0))+" %")

RETURN lRet

METHOD S2ProgressIndicator:chkEvent()
   LOCAL nEvent, mp1, mp2, oXbp

   nEvent := dfAppEvent( @mp1, @mp2, @oXbp, 1, self)
   IF oXbp != NIL
      oXbp:HandleEvent(nEvent, mp1, mp2)
   ENDIF
RETURN self


