//////////////////////////////////////////////////////////////////////
//
//  RTF.PRG
//
//  Copyright:
//      Alaska Software, (c) 2002-2003. All rights reserved.
//
//  Contents:
//
//////////////////////////////////////////////////////////////////////

#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "Dll.ch"


FUNCTION dfViewRtfFile( oOwner,aPos,aSize,cFile, cTitle)
   DEFAULT cTitle TO cFile
RETURN dfViewRtfString( oOwner,aPos,aSize,MEMOREAD(cFile), cTitle)

FUNCTION dfViewRtfString( oOwner,aPos,aSize,cStr, cTitle)
   LOCAL aObj := dfViewRtfDlg(oOwner,aPos,aSize,cStr, cTitle)
   LOCAL oDlg := aObj[1]
RETURN dfViewRTFEventLoop(oDlg)

// Event loop
FUNCTION dfViewRTFEventLoop(oDlg)
   LOCAL oFocus := SetAppFocus()

//   oDlg:create()
   oDlg:tbConfig()
   oDlg:show()

   oDlg:tbInk()
   oDlg:tbEnd()

   IF oFocus != NIL
      SetAppFocus(oFocus)
   ENDIF

   oDlg:hide()
   oDlg:destroy()
RETURN NIL

FUNCTION dfViewRtfDlg( oOwner,aPos,aSize,cStr, cTitle)
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL oDlg
   LOCAL oMle

   DEFAULT cTitle   TO ""
   DEFAULT aSize    TO {AppDesktop():CurrentSize()[1]-300,AppDesktop():CurrentSize()[2]-150}
   DEFAULT aPos     TO dfCenterPos(aSize,AppDesktop():currentSize())

   oDlg  := S2ModalDialog1():New( AppDesktop(), oOwner, aPos, aSize,NIL,.T.) 
   oDlg:taskList := .T.
   oDlg:Title := cTitle
   oDlg:DrawingArea:ClipChildren := .T.
   oDlg:Create()

   /* create the help viewer */
   oMle    := XbpMLE():New( oDlg:DrawingArea )
#define  XBPMLE_FMT_RTF        3
   oMle:Format := XBPMLE_FMT_RTF
   oMle:horizScroll := .F.
   oMle:Create(,,, oDlg:DrawingArea:CurrentSize())
   oMle:SetPresParam( { { XBP_PP_DISABLED_BGCLR, GRA_CLR_WHITE } } )
   oMle:SetEditable(.F.)
   oMle:SetData( cStr )
   oDlg:DrawingArea:Resize := { | aOld, aNew | oMle:SetSize( aNew ) }
RETURN {oDlg, oMle}



