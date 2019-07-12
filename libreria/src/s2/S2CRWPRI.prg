#include "xbp.ch"
#include "S2CrwPri.ch"
#include "common.ch"

// #define _SUPERCLASS S2Printer

// Classe che gestisce il DEVMODE,
// necessario per utilizzare correttamente Crystal Report
CLASS S2CRWPrinter // FROM _SUPERCLASS
   PROTECTED
      VAR aDevMode
      VAR xMomHandle
      VAR _myStatus
      VAR oPrn
      METHOD _updDevMode()
      METHOD _getHWnd()

   EXPORTED
      VAR devName, devPort
      VAR devDriver

      METHOD init(), create(),  destroy()
      INLINE METHOD status(); RETURN ::_myStatus

      METHOD setCollationMode()
      METHOD setColorMode()
      METHOD setDuplexMode()
      METHOD setFontMode()
      METHOD setFormSize()
      METHOD setNumCopies()
      METHOD setOrientation()
      METHOD setPaperBin()
      METHOD setPrintFile()
      METHOD setResolution()

      INLINE METHOD setupDialog()
        ::_updDevMode(.T.)
      RETURN self

      INLINE METHOD updDevMode()
        ::_updDevMode(.F.)
      RETURN self

      INLINE METHOD getDMHandle()
        ::updDevMode()
      RETURN ::xMomHandle

      INLINE METHOD forms()
      RETURN ::oPrn:forms()

      INLINE METHOD list()
      RETURN ::oPrn:list()

      INLINE METHOD paperBins()
      RETURN ::oPrn:paperBins()

ENDCLASS

METHOD S2CRWPrinter:init()
  ::devName := NIL
  ::devPort := NIL
  ::devDriver := NIL
  ::oPrn := S2Printer():new()

  ::_myStatus := XBP_STAT_INIT
RETURN self

METHOD S2CRWPrinter:create(cPrinter, nSpool, cPar)
   LOCAL nPrinter
   LOCAL aPrinters
   LOCAL cPort
   LOCAL cDriver
      // ::_SUPERCLASS:create(cDevice, nSpool, cPar)

   ::oPrn:create(cPrinter)

   cPrinter  := ::oPrn:devName
   DEFAULT cPrinter TO ""
   cPrinter  := UPPER(ALLTRIM(cPrinter))

   aPrinters := dfWinPrintersGet(6) // Stampanti locali e di rete
   nPrinter  := ASCAN(aPrinters, {|a| UPPER(ALLTRIM( a[2] ))==cPrinter } )

   IF nPrinter > 0
      DEFAULT cPort   TO aPrinters[nPrinter][4]
      DEFAULT cDriver TO aPrinters[nPrinter][5]
   ENDIF

   ::_myStatus := XBP_STAT_FAILURE

   IF ! EMPTY(::oPrn:devName) .AND. ! EMPTY(cPort) .AND. ! EMPTY(cDriver)
      // alloca memoria per la struttura DEVMODE
      ::xMomHandle := _S2CRWPRINTER_CREATE(::oPrn:devName, AppDesktop():getHWnd())
      IF ::xMomHandle != NIL
         ::devName    := ::oPrn:devName
         ::devPort    := cPort
         ::devDriver  := cDriver

         ::_myStatus := XBP_STAT_CREATE
      ENDIF
   ENDIF

RETURN self

METHOD S2CRWPrinter:destroy()
   // ::_SUPERCLASS:destroy()

   ::oPrn:destroy()

   // Rilascia la memoria per DEVMODE
   IF ::xMomHandle != NIL
      _S2CRWPRINTER_DESTROY(::xMomHandle)
      ::xMomHandle := NIL
   ENDIF
   ::_myStatus := XBP_STAT_INIT

RETURN self

METHOD S2CRWPrinter:setCollationMode( nMode )
   LOCAL xRet //:= ::_SUPERCLASS:setCollationMode( nMode )

   IF ::xMomHandle != NIL
      xRet := _S2CRWPRINTER_SET(::xMomHandle, S2DM_COLLATION, nMode)
   ENDIF
RETURN xRet

METHOD S2CRWPrinter:setColorMode( nMode )
   LOCAL xRet //:= ::_SUPERCLASS:setColorMode( nMode )

   IF ::xMomHandle != NIL
      xRet := _S2CRWPRINTER_SET(::xMomHandle, S2DM_COLOR, nMode)
   ENDIF
RETURN xRet

METHOD S2CRWPrinter:setDuplexMode( nMode )
   LOCAL xRet //:= ::_SUPERCLASS:setDuplexMode( nMode )

   IF ::xMomHandle != NIL
      xRet := _S2CRWPRINTER_SET(::xMomHandle, S2DM_DUPLEX, nMode )
   ENDIF
RETURN xRet

METHOD S2CRWPrinter:setFontMode( nMode )
   LOCAL xRet //:= ::_SUPERCLASS:setFontMode( nMode )

   IF ::xMomHandle != NIL
      xRet := _S2CRWPRINTER_SET(::xMomHandle, S2DM_FONT, nMode )
   ENDIF
RETURN xRet

METHOD S2CRWPrinter:setFormSize( nFormID )
   LOCAL xRet //:= ::_SUPERCLASS:setFormSize( nFormID )

   IF ::xMomHandle != NIL
      xRet := _S2CRWPRINTER_SET(::xMomHandle, S2DM_FORMSIZE, nFormID)
   ENDIF
RETURN xRet

METHOD S2CRWPrinter:setNumCopies( nNumCopies )
   LOCAL xRet //:= ::_SUPERCLASS:setNumCopies( nNumCopies )

   IF ::xMomHandle != NIL
      xRet := _S2CRWPRINTER_SET(::xMomHandle, S2DM_NUMCOPIES, nNumCopies)
   ENDIF
RETURN xRet

METHOD S2CRWPrinter:setOrientation( nOrientation )
   LOCAL xRet //:= ::_SUPERCLASS:setOrientation( nOrientation )

   IF ::xMomHandle != NIL
      xRet := _S2CRWPRINTER_SET(::xMomHandle, S2DM_ORIENTATION, nOrientation)
   ENDIF
RETURN xRet

METHOD S2CRWPrinter:setPaperBin( nBin )
   LOCAL xRet //:= ::_SUPERCLASS:setPaperBin( nBin )

   IF ::xMomHandle != NIL
      xRet := _S2CRWPRINTER_SET(::xMomHandle, S2DM_PAPERBIN, nBin)
   ENDIF
RETURN xRet

METHOD S2CRWPrinter:setPrintFile( cFileName )
   LOCAL xRet //:= ::_SUPERCLASS:setPrintFile( cFileName )

   IF ::xMomHandle != NIL
      xRet := _S2CRWPRINTER_SET(::xMomHandle, S2DM_PRINTFILE, cFileName	)
   ENDIF
RETURN xRet

METHOD S2CRWPrinter:setResolution( xResolution )
   LOCAL xRet //:= ::_SUPERCLASS:setResolution( xResolution )
   IF ::xMomHandle != NIL
      IF VALTYPE(xRet)=="N"
         xRet := _S2CRWPRINTER_SET(::xMomHandle, S2DM_RESOLUTION1, xResolution)
      ELSE
         xRet := _S2CRWPRINTER_SET(::xMomHandle, S2DM_RESOLUTION2, xResolution)
      ENDIF
   ENDIF
RETURN xRet

METHOD S2CRWPrinter:_updDevMode(lSetup)
   LOCAL xRet
   IF ::xMomHandle != NIL
      // Simone 20/11/03 gerr 3943 e gerr 3505
      //xRet := _S2CRWPRINTER_UPDATEDEVMODE(::devName, AppDesktop():getHWnd(), ::xMomHandle, lSetup)
      xRet := _S2CRWPRINTER_UPDATEDEVMODE(::devName, ::_getHWnd(), ::xMomHandle, lSetup)
   ENDIF
RETURN xRet

// Simone 20/11/03 gerr 3943 e gerr 3505
METHOD S2CRWPrinter:_gethWnd(oParent)
   LOCAL n:= 0 //AppDesktop():getHwnd()

   // questo dovrebbe essere un workaround al seguente problema
   // se si fa anteprima e poi si fa esportazione, la finestrella
   // di richiesta esportazione Š visualizzata "sotto" la finestra
   // di menu.. ma il workaroudn non funziona..
   DEFAULT oParent TO SetAppWindow()
   IF ! EMPTY(oParent)
      IF oParent:isDerivedFrom("XbpDialog")
         oParent:=oParent:drawingArea
      ENDIF
      n := oParent:getHWnd()
   ENDIF
RETURN n
