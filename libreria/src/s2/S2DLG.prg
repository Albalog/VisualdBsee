// Function/Procedure Prototype Table  -  Last Update: 07/10/98 @ 12.24.59
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
// Return Value         Function/Arguments
// 컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// self                 METHOD S2Dialog:CenterPos(oObj)
// RETURN self          METHOD S2Dialog:Init( nTop, nLeft, nBott, nRight, ;
// NIL                  METHOD S2Dialog:tbConfig()
// self                 METHOD S2Dialog:tbEnd

// Modal Dialog Class con conversione coordinate

#include "dfWin.ch"
#include "dfMenu.ch"
#include "dfCtrl.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Appevent.ch"
#include "dfXBase.ch"
#include "font.ch"

CLASS S2Dialog FROM S2ModalDialog //, AutoResize

EXPORTED:

   VAR nTop, nLeft, nBottom, nRight, nCoordMode

   METHOD Init

ENDCLASS

* **********************************************************************
* Init method
* **********************************************************************
METHOD S2Dialog:Init( nTop, nLeft, nBott, nRight, ;
                     oParent, oOwner, aPos, aSize, aPP, lVisible,nCoordMode)

   LOCAL oPos := NIL

   DEFAULT nCoordMode   TO S2CoordModeDefault()
   ::nCoordMode := nCoordMode

   ::nTop    := nTop
   ::nLeft   := nLeft
   ::nBottom := nBott
   ::nRight  := nRight


   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF ::nCoordMode == W_COORDINATE_PIXEL
      DEFAULT aPos  TO {::nLeft , ::nTop    }
      DEFAULT aSize TO {::nRight, ::nBottom }
   ELSE

      oPos := PosCvt():new(::nLeft, ::nBottom+1)
      oPos:Trasla(oParent)

      DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}

      oPos:SetDos(::nRight - ::nLeft, ::nBottom - ::nTop + 1)

      DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}
   ENDIF

   ::S2ModalDialog:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

RETURN self


// Classe Finestra MODALE
// ----------------------
CLASS S2ModalDialog FROM XbpDialog //, AutoResize
   PROTECTED:

   VAR XbpPrev

   // INLINE METHOD resizeArea()
   // RETURN ::drawingArea

   EXPORTED:

   METHOD Init, tbConfig, tbEnd //, Create //, Destroy //, Show
   METHOD CenterPos

ENDCLASS


* **********************************************************************
* Init method
* **********************************************************************
METHOD S2ModalDialog:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )


   // IF oParent == NIL
   //    IF S2DialogMain() == NIL
   //       oParent := AppDesktop()
   //    ELSE
   //       oParent := S2DialogMain():drawingArea
   //    ENDIF
   // ENDIF

   // DEFAULT oParent TO S2DialogMain():drawingArea

   DEFAULT oParent TO AppDesktop()
   DEFAULT oOwner  TO S2FormCurr()

   // DEFAULT oOwner  TO SetAppWindow()

   DEFAULT lVisible TO .F.
   DEFAULT aPP TO {}

   ::XbpPrev  := NIL

   * initialisation of base class
   ::XbpDialog:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   // ::border   := XBPDLG_SIZEBORDER
   ::border   := XBPDLG_DLGBORDER
   ::taskList := .T.
   ::maxButton:= .F.
   // ::sysMenu  := .F.

   // Set background color for drawing area
   ::drawingArea:SetColorBG( XBPSYSCLR_DIALOGBACKGROUND )

RETURN self

// METHOD S2ModalDialog:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
//    ::XbpDialog:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
//    ::resizeInit({})
// RETURN self


METHOD S2ModalDialog:tbConfig()
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
   //S2FormCurr(self)
   SetAppFocus(self)

   // S2DialogMain( self )

RETURN NIL

METHOD S2ModalDialog:tbEnd
   LOCAL oFocus := ::XbpPrev[1]
   LOCAL oWin := ::XbpPrev[2]

   ::setModalState( XBP_DISP_MODELESS )

   // IF oWin != NIL
   //    oWin:enable()
   // ENDIF


   IF oFocus != NIL
      //msgBox("DLG1 ")
      SetAppFocus( oFocus )
      //sleep(300)
      //msgBox("DLG2 ")
   ENDIF
   ::hide()

   IF oWin != NIL
      SetAppWindow( oWin )
   ENDIF

   S2FormCurr( oWin, .T. )

   ::XbpPrev := NIL

RETURN self

METHOD S2ModalDialog:CenterPos(oObj)
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


// Con gestione tbInk
CLASS S2ModalDialog1 FROM S2ModalDialog
EXPORTED: 
   VAR nAction

   INLINE METHOD Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
      ::S2ModalDialog:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
      ::nAction := 0
      ::close := {|| ::breakEventLoop() }
   RETURN self

   INLINE METHOD breakEventLoop(n)
      DEFAULT n TO -1
      ::nAction := n
   RETURN ::nAction

   INLINE METHOD tbInk()
      LOCAL nEvent, mp1, mp2, oXbp

      DO WHILE ::nAction == 0
         nEvent := dfAppEvent( @mp1, @mp2, @oXbp, NIL, self )

         #ifdef _S2DEBUG_
            S2DebugOut(oXbp, nEvent, mp1, mp2)
         #endif

         oXbp:handleEvent( nEvent, mp1, mp2 )
      ENDDO
   RETURN self

   INLINE METHOD keyboard(nKey)
      DO CASE
         CASE nKey == xbeK_ESC
            ::breakEventLoop()

         OTHERWISE
            ::S2ModalDialog:keyboard(nKey)
      ENDCASE
   RETURN self
ENDCLASS

