#include "common.ch"
#include "dll.ch"
#include "xbp.ch"

FUNCTION dfScreenCapture(aP, aSize)
RETURN dfXbp2Bitmap(Appdesktop(), aP, aSize)[1]

#ifdef _IGNORE_THIS_

// funziona ma l'altro metodo Š meglio perchŠ non usa il clipboard
DLLFUNCTION keybd_event(mvkey,nscan,flags,xtra) USING STDCALL FROM USER32.DLL

// cattura lo schermo
FUNCTION dfScreenCapture(aP, aSize)
//FUNCTION Snap(oDlg,lScan,o)
   LOCAL aFormats := {}
//   LOCAL aP       := GetCurAbsPos()
//   LOCAL aSize    := {270,280}
   LOCAL nInvert  := AppDeskTop():currentSize()[2]
   LOCAL oBmp     := nil
   LOCAL oCamera  := nil
   LOCAL oClip    := nil
   LOCAL aPrev

   DEFAULT aP TO {0, 0}
   DEFAULT aSize TO AppDesktop():currentSize()
/*
   IF !(lScan == nil) .AND. lScan
      ***** Reading BitMap display area to duplicate BMP
      ***** Get the location of the BMP window
      GetaPosaSize( o, @aP, @aSize)
      aP[2]:= nInvert - (aP[2]+aSize[2])
   ELSE
      ***** Use cursor position from Screen Location
      ***** to establish 'view window'
      aP[1]:= INT(aP[1] - aSize[1]/2)
      aP[2]:= INT(nInvert - aP[2] - aSize[2]/2)
   ENDIF
*/
   aPrev := {SetAppWindow(), SetAppFocus()}

   oCamera:= XbpDialog():new( AppDeskTop(),AppDeskTop(), aP, aSize,, .F.)
   oCamera:border       := XBPDLG_NO_BORDER
   oCamera:taskList     := .F.
   oCamera:sysmenu      := .F.
   oCamera:titleBar     := .F.
   oCamera:alwaysontop  := .T.
   oCamera:drawingArea:setColorFG( XBPSYSCLR_TRANSPARENT )
   oCamera:drawingArea:setColorBG( XBPSYSCLR_TRANSPARENT )
   oCamera:create()

   oCamera:show()
   SetAppWindow(oCamera)
   setAppFocus(oCamera)

   ***** CLICK!!
   keybd_event(44,0,0,0)

   oCamera:destroy()

   oClip := XbpClipBoard():new():create()
   oClip:open()
   aFormats := oClip:queryFormats()
   IF AScan( aFormats, XBPCLPBRD_BITMAP ) > 0
      oBmp := oClip:getBuffer( XBPCLPBRD_BITMAP )
   ENDIF
   oClip:close()

//   oDlg:enable()
//   oDlg:tofront()
//   oDlg:show()
//   SetAppWindow(oDlg)
   IF ! EMPTY(aPrev[1])
      SetAppWindow(aPrev[1])
   ENDIf
   IF ! EMPTY(aPrev[2])
      SetAppFocus(aPrev[2])
   ENDIf

   ***** Force it to the top in case the 'client' window was selected
   ***** after the camera button was pressed.
//   TopIt(oDlg,.T.)
//   setAppFocus(oDlg)
Return oBmp
#endif
