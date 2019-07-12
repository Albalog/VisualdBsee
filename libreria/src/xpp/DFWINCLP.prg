/*******************************************************************************
Progetto       : dBsee 4.6
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/

#include "Common.ch"
#include "dfWindow.ch"
#include "xbp.ch"

STATIC oClipboard := NIL

// * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// FUNCTION Main(  )
// * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// 
//      IF dfIsWin() // Is in Windows Task
//         dfWinFullScr()  // Set to full screen
// 
//         ? "Windows Version ", dfWinVer()
// 
//         IF dfIsWinClp()
//            ? "Clipboard Supported"
//            ? "Clipboard Version : " , dfWinClpVer()
// 
//            dfWinClpOpen()  // Open Clipboard
//            ? "Clipboard Size    : " , dfWinClpSize()
//            ? "Clipboard Get     : " , dfWinClpGet()
// 
//            ? "Empty Clipboard"
//            dfWinClpEmpty() // Empty the old value
//            ? "Clipboard Size    : " , dfWinClpSize()
//            ? "Clipboard Get     : " , dfWinClpGet()
// 
//            ? "Clipboard Set     : This text is put "+;
//                                   "in Windows"
//            dfWinClpSet("This text is put in Windows")
// 
//            ? "Clipboard Size    : " , dfWinClpSize()
//            ? "Clipboard Get     : " , dfWinClpGet()
// 
//            dfWinClpClose() // Close ClipBoard
//         ENDIF
//      ENDIF
// 
// RETURN NIL


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIsWinClp()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DEFAULT oClipboard TO XbpClipBoard():new()
RETURN (oClipboard!=NIL)

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfWinClpOpen()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .F.

IF dfIsWinClp()
   oClipboard:CREATE()
   oClipboard:OPEN()
   lRet := .T.
ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfWinClpClose()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .F.

IF dfIsWinClp()
   oClipboard:DESTROY()
   oClipboard:CLOSE()
   lRet := .T.
ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfWinClpEmpty()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .F.

IF dfIsWinClp()
   lRet := dfWinClpSet( "" )
ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfWinClpGet( nType )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet := ""

IF dfIsWinClp()
   DEFAULT nType TO WIN_CLP_DATA_TEXT // Text

   nType := dfClp2Xpp( nType )

   cRet := oClipboard:getBuffer( nType )
ENDIF

RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfWinClpVer()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet := ""
IF dfIsWinClp()
   cRet := "2.0"
ENDIF
RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfWinClpSet( cBuffer, nType )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .F.

IF dfIsWinClp()
   lRet := oClipboard:setBuffer( cBuffer )
ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfWinClpSize( nType )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRet := 0

IF dfIsWinClp()
   nRet := LEN(dfWinClpGet( nType ))
ENDIF
RETURN nRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfClp2Xpp( nType )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRet := XBPCLPBRD_TEXT

DO CASE
   CASE nType==WIN_CLP_DATA_TEXT; nRet := XBPCLPBRD_TEXT
   CASE nType==WIN_CLP_DATA_BMP ; nRet := XBPCLPBRD_BITMAP
   CASE nType==WIN_CLP_DATA_META; nRet := XBPCLPBRD_METAFILE
ENDCASE

RETURN nRet
