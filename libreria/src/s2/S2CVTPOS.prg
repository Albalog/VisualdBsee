// Function/Procedure Prototype Table  -  Last Update: 07/10/98 @ 12.24.37
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
// Return Value         Function/Arguments
// 컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// Void                 METHOD PosCvt:Init(nXD, nYD)
// Void                 METHOD PosCvt:SetDos(nXD, nYD)
// Void                 METHOD PosCvt:SetWin(nXW, nYW)
// Void                 METHOD PosCvt:Trasla(oWin)

// Classe per conversione coordinate DOS->Windows

#include "font.ch"
#include "Common.ch"
#include "dfXBase.ch"

CLASS PosCvt
   EXPORTED:
      CLASS VAR _nXMul
      CLASS VAR _nYMul
      CLASS METHOD initClass

      VAR nXDos, nYDos
      VAR nXWin, nYWin
      VAR nXMul, nYMul
      METHOD Init, SetDos, SetWin, Trasla
ENDCLASS

CLASS METHOD PosCvt:InitClass()
   IF EMPTY(::_nXMul) .AND. dfSet("XbaseColWidth") != NIL
      ::_nXMul := VAL(dfSet("XbaseColWidth"))
   ENDIF
   IF EMPTY(::_nYMul) .AND. dfSet("XbaseRowHeight") != NIL
      ::_nYMul := VAL(dfSet("XbaseRowHeight"))
   ENDIF
   IF EMPTY(::_nXMul) .OR. ::_nXMul <= 0
      ::_nXMul := COL_SIZE  // oFont:width
   ENDIF
   IF EMPTY(::_nYMul) .OR. ::_nYMul <= 0
      ::_nYMul := ROW_SIZE  // oFont:height
   ENDIF
RETURN self

METHOD PosCvt:Init(nXD, nYD, nColWidth, nRowHeight)
   // LOCAL oFont := NIL, oClass
   //
   // oClass := XbpFont()
   // oFont := oClass:New()
   //
   // oFont:create()
   // oFont:configure()

   // Simone 10/01/08
   // mantis 0001552: rivedere form gestite con dfAutoForm e S2AutoForm
   DEFAULT nColWidth  TO ::_nXMul
   DEFAULT nRowHeight TO ::_nYMul

   ::nXMul := nColWidth
   ::nYMul := nRowHeight

   ::SetDos(nXD, nYD)

RETURN self

METHOD PosCvt:SetDos(nXD, nYD)

   DEFAULT nXD TO 0
   DEFAULT nYD TO 0

   ::nXDos := nXD
   ::nYDos := nYD

   ::nXWin := ::nXDos * ::nXMul
   ::nYWin := ::nYDos * ::nYMul
RETURN

METHOD PosCvt:SetWin(nXW, nYW)

   DEFAULT nXW TO 0
   DEFAULT nYW TO 0

   ::nXWin := nXW
   ::nYWin := nYW

   ::nXDos := ROUND( ::nXWin / ::nXMul, 0 )
   ::nYDos := ROUND( ::nYWin / ::nYMul, 0 )
RETURN

METHOD PosCvt:Trasla(oWin)
   LOCAL aDSize
   LOCAL nY

   DEFAULT oWin TO AppDeskTop()

   ::nYWin := oWin:CurrentSize()[2] - ::nYWin

   IF oWin == AppDeskTop()
      nY := S2WinStartMenuSize()[2]
      // Centro in base al desktop
      aDSize:= oWin:currentSize()

       ::nXWin += INT( (aDSize[1]-640)/2 )
       ::nYWin -= INT( (aDSize[2]-480-nY)/2 ) - nY // 450=480-30 altezza menu avvio

      //::nXWin += INT( (S2AppDesktopSize()[1] - aDSize[1]) /2 )
      //::nYWin -= INT( (aDSize[2]-480-nY)/2 ) - nY // 450=480-30 altezza menu avvio
   ENDIF
RETURN
