//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbColWidth( oTbr, oCol )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nWidth
nWidth:=oCol:WIDTH
IF nWidth == NIL
   nWidth := 1
   IF !EMPTY(tbGetColFooting(oCol))
      nWidth := MAX( nWidth, LEN(dfAny2Str(tbGetColFooting(oCol))) )
   ENDIF
   IF !EMPTY(tbGetColHeading(oCol))
      nWidth := MAX( nWidth, LEN(dfAny2Str(tbGetColHeading(oCol))) )
   ENDIF
   IF !EMPTY(oCol:PICTURE)
      nWidth := MAX( nWidth, LEN(dfAny2Str(EVAL(oCol:BLOCK),oCol:PICTURE)) )
   ENDIF

   //nWidth := MAX( LEN(tbGetColHeading(oCol)), LEN(tbGetColFooting(oCol)) )
   //nWidth := MAX( LEN(dfAny2Str(EVAL(oCol:BLOCK),oCol:PICTURE)), nWidth )
ELSE
   //Mantis 2186
   //Inserito settaggio per decidere se utilizzare il calcolo originario (largezza della colonna )
   //o automatico in base header , footer o Picture
   //Correzione ampiezza colonna in stampa database.
   IF dfSet("XbaseTbColWidthAuto") == "NO"
      RETURN nWidth
   ENDIF
   //Correzione ampiezza colonna in stampa database.
   IF !EMPTY(tbGetColFooting(oCol))
      nWidth := MAX( nWidth, LEN(dfAny2Str(tbGetColFooting(oCol)) ))
   ENDIF
   IF !EMPTY(tbGetColHeading(oCol))
      nWidth := MAX( nWidth, LEN(dfAny2Str(tbGetColHeading(oCol)) ))
   ENDIF
   IF !EMPTY(oCol:PICTURE)
      nWidth := MAX( nWidth, LEN(dfAny2Str(EVAL(oCol:BLOCK),oCol:PICTURE)) )
   ENDIF
ENDIF
RETURN nWidth
