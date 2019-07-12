#include "common.ch"

FUNCTION dfCRWPrinterObject(oObj)
   LOCAL cDir
   STATIC oPrn
   STATIC lInit


   IF lInit == NIL
      lInit := .T.

      // Gerr. 3606 29/10/03
      // Avvolte l'aplicazione perde il path corrente
      // Salvo path e Directory corrente
      cDir   := dfPathGet()

      // Creo una stampante di default
      oPrn := S2CRWPrinter():new()
      IF oPrn != NIL
         oPrn:create()
      ENDIF

      // Gerr. 3606 29/10/03
      // Avvolte l'aplicazione perde il path corrente
      // Ripristino path e Directory corrente
      dfPathSet( cDir )

   ENDIF

   IF oObj != NIL

      // Gerr. 3606 29/10/03
      // Avvolte l'aplicazione perde il path corrente
      // Salvo path e Directory corrente
      cDir   := dfPathGet()

      IF oPrn != NIL .AND. oObj != oPrn
         oPrn:destroy()
      ENDIF

      oPrn := oObj

      // Gerr. 3606 29/10/03
      // Avvolte l'aplicazione perde il path corrente
      // Ripristino path e Directory corrente
      dfPathSet( cDir )

   ENDIF

RETURN oPrn


FUNCTION dfCRWPrinterObjSet(cPrinter, lReset)
   LOCAL lChg := .F.
   LOCAL oPrinter := dfCRWPrinterObject()
   LOCAL cDir

   DEFAULT lReset TO .F.

   IF ! EMPTY(cPrinter) .AND. ;
      ! EMPTY(oPrinter) .AND. ;
      (! cPrinter == oPrinter:devName .OR. lReset)

      // Gerr. 3606 29/10/03
      // Avvolte l'aplicazione perde il path corrente
      // Salvo path e Directory corrente
      cDir   := dfPathGet()

      oPrinter:destroy()
      oPrinter:create( cPrinter )

      lChg := .T.
      // Gerr. 3606 29/10/03
      // Avvolte l'aplicazione perde il path corrente
      // Ripristino path e Directory corrente
      dfPathSet( cDir )

   ENDIF

RETURN lChg


