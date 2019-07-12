// esegue una conversione XSLT di un file XML
// lavora su stringhe:
//   es.
//   cXml := dfFileRead("test.xml")
//   cTransform := dfFileRead("test.xslt")
//   cHtml := dfXmlCvt(cXml, cTransform, oErr)
//   IF oErr != NIL
//      dfAlert("errore trasformazione "+oErr:description)
//   ELSE
//      dfFileWrite("test.html", cHtml)
//   ENDIF

FUNCTION dfXmlCvt(cXml, cXslt, oErr)
#if XPPVER < 01900000
   oErr := dfErrorCreate("Function dfXmlCvt() supported only on Xbase++ >= 1.90")
RETURN NIL
#else
   LOCAL oSrc, oTransform, cResult
   LOCAL bErr, o

   oErr := NIL

   bErr := ERRORBLOCK({|e| dfErrBreak(e)})
   BEGIN SEQUENCE
      oSrc := dfGetAX("MSXML2.DOMDocument",.T.)
      oSrc:async := .F.
      oSrc:loadXml(cXml)

      oTransform := dfGetAX("MSXML2.DOMDocument",.T.)
      oTransform:async := .F.
      oTransform:loadXml(cXslt)

      cResult := oSrc:transformNode(oTransform:documentElement)

   RECOVER USING o
      oErr    := o
      cResult := NIL

   END SEQUENCE

   BEGIN SEQUENCE
      IF ! EMPTY(oTransform)
         oTransform:destroy()
      ENDIF
   END SEQUENCE

   BEGIN SEQUENCE
      IF ! EMPTY(oSrc)
         oSrc:destroy()
      ENDIF
   END SEQUENCE

   ERRORBLOCK(bErr)

RETURN cResult
#endif
