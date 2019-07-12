// Function/Procedure Prototype Table  -  Last Update: 07/10/98 @ 12.24.59
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
// Return Value         Function/Arguments
// 컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// self                 METHOD S2CrtDialog:CenterPos(oObj)
// RETURN self          METHOD S2CrtDialog:Init( nTop, nLeft, nBott, nRight, ;
// NIL                  METHOD S2CrtDialog:tbConfig()
// self                 METHOD S2CrtDialog:tbEnd

// Modal Dialog Class con conversione coordinate

#include "dfWin.ch"
#include "dfMenu.ch"
#include "dfCtrl.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Appevent.ch"
#include "dfxres.ch"
#include "dfXBase.ch"
#include "font.ch"

FUNCTION S2CrtOpen()
   LOCAL o := S2CrtDialog():new()

   o:create()
   o:centerPos()
   o:tbConfig()
   o:show()

RETURN o

FUNCTION S2CrtClose(o)
   o:tbEnd()
   o:destroy()
RETURN NIL


CLASS S2CrtDialog FROM XbpCrt //, AutoResize
   PROTECTED:

   VAR XbpPrev

   // INLINE METHOD resizeArea()
   // RETURN ::drawingArea

   EXPORTED:

   VAR nTop, nLeft, nBottom, nRight

   METHOD Init, tbConfig, tbEnd //, Create //, Destroy //, Show
   METHOD CenterPos

ENDCLASS


* **********************************************************************
* Init method
* **********************************************************************
METHOD S2CrtDialog:Init( nTop, nLeft, nBott, nRight, ;
                     oParent, oOwner, aPos, aSize, aPP, lVisible )

   LOCAL oPos := NIL

   //::nTop    := nTop
   //::nLeft   := nLeft
   //::nBottom := nBott
   //::nRight  := nRight
   ::nTop    := 0
   ::nLeft   := 0
   ::nBottom := 24
   ::nRight  := 79
   ::XbpPrev  := NIL

   // IF oParent == NIL
   //    IF S2CrtDialogMain() == NIL
   //       oParent := AppDesktop()
   //    ELSE
   //       oParent := S2CrtDialogMain():drawingArea
   //    ENDIF
   // ENDIF

   // DEFAULT oParent TO S2CrtDialogMain():drawingArea

   DEFAULT oParent TO AppDesktop()
   DEFAULT oOwner  TO S2FormCurr()

   // DEFAULT oOwner  TO SetAppWindow()

   DEFAULT lVisible TO .F.

   oPos := PosCvt():new(::nLeft, ::nBottom+1)
   //oPos := PosCvt():new(::nLeft, ::nBottom)
   oPos:Trasla(oParent)

   DEFAULT aPP TO {}

   DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}

   oPos:SetDos(::nRight - ::nLeft, ::nBottom - ::nTop + 1)
   //oPos:SetDos(::nRight - ::nLeft, ::nBottom - ::nTop )

   DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}

   * initialisation of base class

   ::XbpCrt:init( oParent, oOwner, aPos, NIL, NIL, NIL, lVisible )

   // ::border   := XBPDLG_SIZEBORDER
   ::border   := XBPDLG_DLGBORDER
   ::taskList := .T.
   //::maxButton:= .F.
   // ::sysMenu  := .F.

   // Set background color for drawing area
   //::drawingArea:SetColorBG( XBPSYSCLR_DIALOGBACKGROUND )

RETURN self

// METHOD S2CrtDialog:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
//    ::XbpCrt:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
//    ::resizeInit({})
// RETURN self


METHOD S2CrtDialog:tbConfig()
   LOCAL oWin := S2FormCurr()
   LOCAL lModal := .T. // ! dfSet("XbaseMDI") == "YES"

   // IF oWin != NIL .AND. lModal
   //    oWin:disable()
   // ENDIF

   IF lModal
      ::setModalState( XBP_DISP_APPMODAL )
   ENDIF

   IF ::XbpPrev == NIL
      ::xbpPrev := {SetAppFocus(), oWin}
   ENDIF

   SetAppWindow(self)
//Maudp-LucaC 17/04/2013 l'S2FormCurr deve memorizzare solo oggetti di tipo S2Form o derivati
//   S2FormCurr(self)
   SetAppFocus(self)

   // S2CrtDialogMain( self )

RETURN NIL

METHOD S2CrtDialog:tbEnd
   LOCAL oFocus := ::XbpPrev[1]
   LOCAL oWin   := ::XbpPrev[2]

   ::setModalState( XBP_DISP_MODELESS )

   IF oFocus != NIL
      SetAppFocus( oFocus )
   ENDIF
   ::hide()

   IF oWin != NIL
      SetAppWindow( oWin )
   ENDIF

   S2FormCurr( oWin, .T. )

   ::XbpPrev := NIL

RETURN self

METHOD S2CrtDialog:CenterPos(oObj)
   LOCAL aParentSize
   LOCAL aSize

   DEFAULT oObj TO ::setParent()
   DEFAULT oObj TO AppDesktop()

   aParentSize := oObj:currentSize()
   aSize := ::currentSize()

   aSize[1] := (aParentSize[1] - aSize[1]) / 2
   aSize[2] := (aParentSize[2] - aSize[2]) / 2

   ::setPos(aSize)

RETURN self

