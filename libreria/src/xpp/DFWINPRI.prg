// Torna la lista delle stampanti installate
#include "common.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record

FUNCTION dfWinPrinters()
   LOCAL aRet := {}
   IF WindowsPrinterEnabled()
      aRet := _dfWinPrinters()
   ENDIF
RETURN aRet

STATIC FUNCTION _dfWinPrinters()
   LOCAL oDc  := S2Printer():new()
   LOCAL aPrn := oDC:list()
   LOCAL aRet := {}

   IF ! EMPTY(aPrn)
      aRet := ACLONE(aPrn)
   ENDIF

   oDC := NIL

RETURN aRet

// Torna la stampante di default
FUNCTION dfWinPrinterDefault()
   LOCAL cDev := ""
   IF WindowsPrinterEnabled()
      cDev := _dfWinPrinterDefault()
   ENDIF
RETURN cDev

STATIC FUNCTION _dfWinPrinterDefault()
   LOCAL oDC := S2Printer():new():create()
   LOCAL cDev := oDC:devName

   oDC:destroy()
RETURN cDev

FUNCTION dfIsWinPrinter(cDevice)
   LOCAL lRet := .F.
   IF WindowsPrinterEnabled()
      IF VALTYPE( cDevice )=="A"
         lRet := _dfIsWinPrinter( ALLTRIM(cDevice[REP_PRINTERARR][PRINTER_INFO]) )
      ELSE
         lRet := _dfIsWinPrinter(cDevice)
      ENDIF
   ENDIF
RETURN lRet

STATIC FUNCTION _dfIsWinPrinter(cDevice)
   LOCAL oDc  := S2Printer():new()
   LOCAL aPrn := oDC:list()
   LOCAL lRet := .T. 


   IF !EMPTY(cDevice)
      cDevice := Upper(cDevice)
      lRet    := ! EMPTY(cDevice)                       .AND. ;
                 ! EMPTY(aPrn)                          .AND. ;
                  ASCAN(aPrn, {|x| Upper(x)==cDevice }) != 0

   ENDIF 


   oDC := NIL

RETURN lRet

FUNCTION dfWinPrinterObject(oObj)
   STATIC oPrn
   STATIC lInit

   IF lInit == NIL
      // lInit := dfSet("XbaseUseWindowsPrintMenu") == "YES" .AND. ;
      //          WindowsPrinterEnabled()
      lInit := WindowsPrinterEnabled()

      IF lInit

         // Creo una stampante di default
         oPrn := S2Printer():new()
         IF oPrn != NIL
            oPrn:create()
         ENDIF

      ENDIF
   ENDIF

   IF oObj != NIL

      IF oPrn != NIL .AND. oObj != oPrn
         oPrn:destroy()
      ENDIF

      oPrn := oObj
   ENDIF

RETURN oPrn

STATIC FUNCTION WindowsPrinterEnabled()
RETURN ! dfSet("XbaseEnableWinPrinters") == "NO"


FUNCTION dfWinPrinterObjSet(cPrinter, lReset)
   LOCAL lChg := .F.
   LOCAL oPrinter := dfWinPrinterObject()
   LOCAL nPageSize
   LOCAL nCopie
   LOCAL nOrientation 
   LOCAL bErr

   DEFAULT lReset TO .F.

//Maudp 19/03/2012 Aggiunto Codeblock di errore per skippare alcuni fatal error
//che ogni tanto vengono fuori da questa funzione
//ES TICKET 7222
//Mantis 2177
   bErr := ERRORBLOCK({|e| dfErrBreak(e)})

   BEGIN SEQUENCE

   IF ! EMPTY(cPrinter) .AND. ;
      ! EMPTY(oPrinter) .AND. ;
      (! cPrinter == oPrinter:devName .OR. lReset)

      /////////////////////////////////////////////
      //Correzione per settaggio passati ai Buffer 
      //Aggiunto luca il 14/10/2010
      /////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////////
      //Perde le info passate al momento dell'impostazione della stampante di defualt
   //      nOrientation := oPrinter:setFormSize()
   //      nPageSize    := oPrinter:setOrientation()
      nOrientation := oPrinter:setOrientation() 
      nPageSize    := oPrinter:setFormSize()
      nCopie       := oPrinter:setNumCopies()
      /////////////////////////////////////////////////////////////////////////////

      oPrinter:destroy()
      oPrinter:create( cPrinter )

      /////////////////////////////////////////////////////////////////////////////
      //Perde le info passate al momento dell'impostazione della stampante di defualt
      IF nOrientation != NIL 
         oPrinter:setOrientation(nOrientation)
      ENDIF 
      IF nPageSize != NIL
         oPrinter:setFormSize(nPageSize)
      ENDIF 
      IF nCopie != NIL
         oPrinter:setNumCopies(nCopie)
      ENDIF 
      /////////////////////////////////////////////////////////////////////////////

      lChg := .T.
   ENDIF

   END SEQUENCE

   ERRORBLOCK(bErr)

RETURN lChg

FUNCTION dfWinPrnGetPort(cPrinter)
   LOCAL cPort := ""
   LOCAL aPrn := dfWinPrintersGet( 6 )  // Stampanti locali e di rete
   LOCAL nPos

   IF ! EMPTY(cPrinter) .AND. ;
      ! EMPTY(aPrn)     .AND. ;
      (nPos := ASCAN(aPrn, {|x| x[2]==cPrinter })) > 0
      cPort := aPrn[nPos][4]
   ENDIF

RETURN cPort


