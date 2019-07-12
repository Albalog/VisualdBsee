//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per nullificare
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfset.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfNullify( cFie )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos   := FIELDPOS( cFie )
LOCAL uField := FIELDGET( nPos )
LOCAL cType  := VALTYPE( uField )
// Tipi = "ABCDLMNOU"
DO CASE
   CASE cType == "C"; FIELDPUT( nPos, REPLICATE(dfSet(AI_NULLIFY_CHAR   ),LEN(uField)) )
   CASE cType == "D"; FIELDPUT( nPos, dfSet(AI_NULLIFY_DATE   ) )
   CASE cType == "L"; FIELDPUT( nPos, dfSet(AI_NULLIFY_LOGICAL) )
   CASE cType == "N"; FIELDPUT( nPos, dfSet(AI_NULLIFY_NUMERIC) )
ENDCASE
RETURN
