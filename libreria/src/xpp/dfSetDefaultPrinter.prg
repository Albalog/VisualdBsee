#include "dll.ch"

DLLFUNCTION SetDefaultPrinterA(pPrinter) USING OSAPI FROM WINSPOOL.DRV

DLLFUNCTION GetDefaultPrinterA(@pPrinter,@pwdBufferSize) USING OSAPI;
       FROM WINSPOOL.DRV

FUNCTION dfGetDefaultPrinter()
   local cPrinter := Space(250)
   local pwdBufferSize := 250

   GetDefaultPrinterA(@cPrinter,@pwdBufferSize)
   cPrinter := LEFT(cPrinter, pwdBufferSize-1)
RETURN (cPrinter)

FUNCTION dfSetDefaultPrinter(cPrinter)
   IF EMPTY(cPrinter)
      RETURN .F.
   ENDIF
RETURN SetDefaultPrinterA(cPrinter)

