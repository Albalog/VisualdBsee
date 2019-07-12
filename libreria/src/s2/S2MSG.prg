// Function/Procedure Prototype Table  -  Last Update: 07/10/98 @ 12.25.33
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Return Value         Function/Arguments
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// self                 METHOD S2Msg:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
// aDim                 METHOD S2Msg:GetTextSize(cMsg)
// RETURN self          METHOD S2Msg:Off()
// self                 METHOD S2Msg:On(cMsg)
// ::oTxt:SetSize(:...  METHOD S2Msg:SetSize(aSize)
// self                 METHOD S2Msg:init()
// Void                 METHOD S2Msg:update(cMsg)

#include "Common.ch"
#include "dfXBase.ch"
#include "dfStd.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "dfSet.ch"
#include "dfWin.ch"

CLASS S2Msg FROM _Msg
   PROTECTED 
      //VAR oThread  // Gestione avvio in ritardo
      VAR lActive
      VAR updatemsg

      METHOD _setFocus
      METHOD _lostFocus
   EXPORTED
      METHOD On()
      METHOD Off()
      METHOD show()
      METHOD showDlg()
      METHOD tbConfig
      METHOD tbEnd
      METHOD update
ENDCLASS

METHOD S2Msg:On(cMsg, nDelay)
   LOCAL oThread
   ::lActive := .T.
   ::updatemsg := cMsg
   IF VALTYPE(nDelay) != "N"
      ::_Msg:On(cMsg)
   ELSE

      // Visualizzazione ritardata del messaggio
      oThread := Thread():new()

      //#ifndef _XBASE182_
       // Simone GERR 3379 e 3738
       // correzione malfunzionamento gestione thread in xbase 1.5-1.8
       // chiuso in xbase 1.82 ma forse non per bene!
       // PDR 5057
       Sleep(5)
      //#endif

      oThread:setStartTime( SECONDS()+nDelay )
      oThread:start( {||::showDlg()} )

//if dfset("sleep")!=nil
//sleep(val(dfset("sleep")))
//endif
   ENDIF
RETURN self

METHOD S2Msg:showDlg()
 IF ::lActive == NIL   // Ho chiamato off() prima della visualizzazione???
    RETURN .F.
 ENDIF

 ::create()
 ::tbConfig()
 ::_Msg:update( ::updateMsg )
 ::show()
RETURN self

METHOD S2Msg:Off()

   ::lActive := NIL
   IF ::isVisible()
      ::_LostFocus()
   ENDIF

   ::tbEnd()

   IF ::status() == XBP_STAT_CREATE
      ::destroy()
   ENDIF

RETURN self

METHOD S2Msg:show()
   IF ::lActive == NIL   // Ho chiamato off() prima della visualizzazione???
      RETURN .F.
   ENDIF

   ::_setFocus()
   IF ! ::updateMsg == ::oTxt:getText()
      ::_Msg:update(::updateMsg)
   ENDIF
RETURN ::_Msg:show()


METHOD S2Msg:_SetFocus()
   LOCAL lModal := .T. // ! dfSet("XbaseMDI") == "YES"

   // IF oWin != NIL .AND. lModal
   //    oWin:disable()
   // ENDIF

   IF lModal
      ::setModalState( XBP_DISP_APPMODAL )
   ENDIF

   SetAppWindow(self)

//Maudp-LucaC 17/04/2013 l'S2FormCurr deve memorizzare solo oggetti di tipo S2Form o derivati
   //S2FormCurr(self)

// simone 19/9/03 non serve anzi pu• rompre le scatole
// impostare il focus su queste finestre di dialogo
//   SetAppFocus(self)
RETURN self

METHOD S2Msg:tbConfig()
   LOCAL oWin := S2FormCurr()

   IF ::XbpPrev == NIL
      ::xbpPrev := {SetAppFocus(), oWin}
   ENDIF

   // S2DialogMain( self )

RETURN NIL

METHOD S2Msg:_LostFocus()
   LOCAL oFocus := ::XbpPrev[1]
   LOCAL oWin := ::XbpPrev[2]

   ::setModalState( XBP_DISP_MODELESS )

   // IF oWin != NIL
   //    oWin:enable()
   // ENDIF


// simone 19/9/03 non serve anzi pu• rompre le scatole
// impostare il focus su queste finestre di dialogo
//   IF oFocus != NIL
//      SetAppFocus( oFocus )
//   ENDIF
   ::hide()

   IF oWin != NIL
      SetAppWindow( oWin )
   ENDIF

   S2FormCurr( oWin, .T. )
RETURN self

METHOD S2Msg:tbEnd

   ::XbpPrev := NIL

RETURN self

METHOD S2Msg:update(cMsg)
  ::updatemsg := cMsg
  IF ::isVisible()
     ::_Msg:update(cMsg)
  ENDIF
RETURN self

STATIC CLASS _Msg FROM S2Dialog
   PROTECTED:
   VAR oTxt, aMsgDim

   EXPORTED:
   METHOD Init, Create, Update, GetTextSize, SetSize //, Clear, Destroy, Display
   METHOD On, Off
ENDCLASS

METHOD _Msg:init(aPP)
   LOCAL aColor


   ::S2Dialog:init(0,0,1,1,;
                   NIL    , NIL   , NIL , NIL  , NIL, NIL     ,W_COORDINATE_ROW_COLUMN)   
   ::taskList := .F.
   ::titleBar := .F.
   ::sysMenu  := .F.

   ::oTxt := S2Txt():new(::DrawingArea, NIL, {3, 3})
   //::oTxt:autosize := .T.
   //::oTxt:TextArea:autosize := .T.
   ::oTxt:TextArea:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_CENTER+XBPSTATIC_TEXT_WORDBREAK

   // ::oTxt:setFontCompoundName(APPLICATION_FONT)

   IF EMPTY(aPP) 
      aColor:=dfColor( "MessageColor" )        // Errore il messaggio d'errore
      IF EMPTY(aColor) .OR. LEN(aColor)<8      // ??? RICORDARSI ??? allineamento
         aColor := {"W+/B",  "GR/B", "RB+/B", "W+/B" ,;
                    "W+/B", "GR+/B", "GR+/B", "G/B"   }
      ENDIF
      S2ObjSetColors(::drawingArea, .T., aColor[AC_MSG_RESIDENTSAY])
      S2ObjSetColors(::oTxt:textArea, .T., aColor[AC_MSG_RESIDENTSAY])
   ENDIF

   ::aMsgDim := {0,0}

RETURN self

METHOD _Msg:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2Dialog:Create(oParent, oOwner, aPos, aSize, aPP, .F.  )
   ::oTxt:create(NIL,NIL,NIL,::drawingArea:currentSize())
RETURN self

METHOD _Msg:SetSize(aSize)
   LOCAL aBox
   ::S2Dialog:SetSize(aSize)
   aBox := ::drawingArea:currentSize()
   aBox[1]-=6
   //aBox[2]-=6
   ::oTxt:SetSize(aBox)
   ::invalidateRect()
RETURN 


METHOD _Msg:On(cMsg)
   ::Create()
   ::tbConfig()
   ::update(cMsg)
   ::show()
RETURN self

METHOD _Msg:Off()
   ::tbEnd()
   ::destroy()
RETURN self

// METHOD _Msg:Destroy()
//
//    ::oTxt:TextArea:unlockPS(::oPS)
//
//
//    // ::oTxt:destroy()
//    ::S2Dialog:destroy()
//
// RETURN self

METHOD _Msg:update(cMsg)
   LOCAL aSize := ::currentSize()
   DEFAULT cMsg TO ""

   cMsg := S2MultiLineCvt(cMsg)

   ::aMsgDim := ::GetTextSize(cMsg)

   IF ::aMsgDim[1] != aSize[1] .OR. ::aMsgDim[2] != aSize[2]
      //::hide()
      ::SetSize( ::aMsgDim)
      ::CenterPos()
      //::show()
   ENDIF

   ::oTxt:SetText( cMsg )
RETURN

METHOD _Msg:GetTextSize(cMsg)
   LOCAL aDim := ::oTxt:GetTextSize(cMsg)

   // Aggiungo un po' di margine
   aDim[1]  += 40
   aDim[2]  += 36 // Se c'Š la barra del titolo Š ok questo valore

RETURN aDim
