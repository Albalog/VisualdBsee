///////////////////////////////////////////////////////////////////////////////
//
// FILE NAME
//
//    CRWCCO.PRG
//
// AUTHOR
//
//    Gernot Trautmann
//    (c) Copyright 1998-1999, Alaska Software
//
//    ALL RIGHTS RESERVED
//
//    This file is the property of AUTHOR. It participates in the
//    Alaska Certified Solutions Network program. Permission to use,
//    copy, modify, and distribute this software for any purpose and
//    without fee is hereby granted, provided that the above copyright
//    notice appear in all copies and that the name of the author or
//    Alaska Software not be used in advertising or publicity pertaining
//    to distribution of the software without specific, written prior
//    permission.
//
// WARRANTY
//
//    THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
//    AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
//    INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
//    FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL THE AUTHOR
//    OR ALASKA SOFTWARE BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT,
//    SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND,
//    INCLUDING WITHOUT LIMITATION, LOSS OF PROFIT AND LOSS OF USE.
//
// DESCRIPTION
//
//    How to view and print a report using the Crystal Reports Engine
//
// REMARKS
//
//    You need to have the Crystal Reports Version 5.0 or 6.0 installed.
//
// BUILD
//    pbuild
//
// HISTORY
//
//    01.11.99 GT resize
//    27.08.99 GT use XbpWinContainer
//    27.01.98 GT creation of file
//
///////////////////////////////////////////////////////////////////////////////
#include "dll.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "gra.ch"
#include "xbp.ch"

#define CW_USEDEFAULT 0x80000000 /* see winuser.h */
#define WS_VISIBLE    0x10000000
#define SW_HIDE       0x00000000


// Small class which serves as as container for the CRW window
// and receives all messages sent from the CRW window to its
// parent. We may now overload the default processing for these
// messages in the HandleEvent method.
// However, at the moment we will just echo the event
CLASS XbpCRWContainer FROM XbpWinContainer

  EXPORTED:

    // internal doc reference
    VAR nJob
    VAR lOpen
    VAR nErrCode
    // overloaded
    METHOD Init, destroy, Open, Close
    METHOD HandleEvent
    METHOD setSize
ENDCLASS

METHOD XbpCRWContainer:Init(oParent)
  ::XbpWinContainer:init(oParent)
  ::nJob := 0
  ::lOpen := .F.
  ::nErrCode := 0
RETURN self

METHOD XbpCRWContainer:destroy()
  ::close()
  ::XbpWinContainer:destroy()
RETURN self

// Create the DOC object
METHOD XbpCRWContainer:Open( cReport, cFormula, xFlag, aTabLocation, ;
                             oCRWPrinter, bOnPreview, aOpt )
   LOCAL nRc:=0
   LOCAL nHwnd := ::getHwnd()
   LOCAL nEvent := 0, mp1:=0, mp2:=0
   LOCAL xVal, cFlag

   ::nErrCode := 0
   IF PEOpenEngine() > 0
      ::lOpen := .T.

      ::nJob := PEOpenPrintJob( cReport )
      IF ::nJob > 0
          SecureEval({|| PEDiscardSavedData(::nJob) })

          IF cFormula != NIL .AND. ! EMPTY(ALLTRIM( cFormula ))
             PESetSelectionFormula( ::nJob, cFormula )
          ENDIF

          __PESetTableLocation(::nJob, aTabLocation)

          IF ! EMPTY(oCRWPrinter) .AND. oCRWPrinter:devName != NIL
             // Imposta stampante e devmode
             _DFCRW_PESELECTPRINTER(::nJob, ;
                                    oCRWPrinter:devName, ;
                                    oCRWPrinter:devPort, ;
                                    oCRWPrinter:devDriver, ;
                                    oCRWPrinter:getDMHandle())
          ENDIF

          IF ! EMPTY(aOpt)
             __PESetPrintOptions(::nJob, aOpt)
          ENDIF

          IF VALTYPE(xFlag) == "L" .AND. xFlag == .F.
             nRc = PEOutputToprinter(::nJob, 1)
          ELSE
             nRc := PEOutputToWindow(::nJob, "", ;
                                       CW_USEDEFAULT, CW_USEDEFAULT,;
                                       CW_USEDEFAULT,CW_USEDEFAULT,;
                                       WS_VISIBLE, nHWnd)
             IF nRc > 0
                IF ! VALTYPE(xFlag) == "O" // Oggetto XbpCRWWindowOptions
                   // default
                   xFlag := XbpCRWWindowOptions():new()
                   xFlag:hasCloseButton := .F.
                ENDIF

                cFlag := xFlag:getStruct()
                PESetWindowOptions ( ::nJob, @cFlag )
                //xVal := SecureEval({|| PESetWindowOptions ( ::nJob, @cFlag )})
             ENDIF
          ENDIF
          IF nRc > 0 .AND. ;
             (VALTYPE(bOnPreview) != "B" .OR. ;
              EVAL(bOnPreview, ::nJob, ;
                   cReport, cFormula, xFlag, aTabLocation, oCRWPrinter ) )

             nRc := PEStartPrintJob( ::nJob, .T.)
             IF nRc < 1
                ::nErrCode := PEGetErrorCode( ::nJob )
             ENDIF
          ELSE
             ::nErrCode := PEGetErrorCode( ::nJob )
          ENDIF
      ELSE
          ::nErrCode := PEGetErrorCode( ::nJob )
      ENDIF
   ENDIF

RETURN self

// overloaded HandleEvent method
METHOD XbpCRWContainer:HandleEvent( nEvent, mp1, mp2 )
RETURN ::XbpWinContainer:HandleEvent( nEvent, mp1, mp2 )

METHOD XbpCRWContainer:setSize( aNewSize )
   LOCAL nHwnd
   nHwnd := PEGetWindowHandle(::nJob)
   _winSetWindowSize(nHwnd, aNewSize)
RETURN ::XbpWinContainer:setSize(aNewSize)

METHOD XbpCRWContainer:Close()
   IF ::lOpen
      IF ::nJob > 0
         PECloseWindow( ::nJob )
         PEClosePrintJob( ::nJob )
         ::nJob := 0
      ENDIF
      PECloseEngine()
      ::lOpen := .F.
   ENDIF
RETURN self


CLASS XbpCRWWindowOptions
   EXPORTED:
      VAR   hasGroupTree
      VAR   canDrillDown
      VAR   hasNavigationControls
      VAR   hasCancelButton
      VAR   hasPrintButton
      VAR   hasExportButton
      VAR   hasZoomControl
      VAR   hasCloseButton
      VAR   hasProgressControls
      VAR   hasSearchButton
      VAR   hasPrintSetupButton
      VAR   hasRefreshButton
      VAR   showToolbarTips
      VAR   showDocumentTips
      VAR   hasLaunchButton

      METHOD getStruct()

      INLINE METHOD cvtVal(l)
          IF l == NIL
             l := -1   // PE_Unchanged
          ELSEIF l
             l := 1    // True
          ELSE
             l := 0    // False
          ENDIF
      RETURN I2BIN(l)

ENDCLASS

METHOD XbpCRWWindowOptions:getStruct()
   LOCAL cRet

   cRet :=  ::cvtVal( ::hasGroupTree          ) + ;
            ::cvtVal( ::canDrillDown          ) + ;
            ::cvtVal( ::hasNavigationControls ) + ;
            ::cvtVal( ::hasCancelButton       ) + ;
            ::cvtVal( ::hasPrintButton        ) + ;
            ::cvtVal( ::hasExportButton       ) + ;
            ::cvtVal( ::hasZoomControl        ) + ;
            ::cvtVal( ::hasCloseButton        ) + ;
            ::cvtVal( ::hasProgressControls   ) + ;
            ::cvtVal( ::hasSearchButton       ) + ;
            ::cvtVal( ::hasPrintSetupButton   ) + ;
            ::cvtVal( ::hasRefreshButton      ) + ;
            ::cvtVal( ::showToolbarTips       ) + ;
            ::cvtVal( ::showDocumentTips      ) + ;
            ::cvtVal( ::hasLaunchButton       )

RETURN W2BIN( LEN(W2BIN(0)) + LEN(cRet))+cRet

// Eseguo qualcosa evitando runtime error

STATIC FUNCTION SecureEval(bBlo, o)
   LOCAL bErr := ErrorBlock( {|e| break(e) } )
   LOCAL xRet

   BEGIN SEQUENCE
      xRet := EVAL(bBlo)

   RECOVER USING o

   END SEQUENCE

   ErrorBlock(bErr)
RETURN xRet

