#include "Common.ch"
#include "dfWinRep.ch"

// Torna un array con le impostazioni di stampa
// per default la stampa avviene a MARGINE superiore della stampante 0
// e a MARGINE SINISTRO 0 della stampante
// con interlinea ad 1/6 di pollice

FUNCTION dfWinPrnExtra(nTop, nLeft, nLine, nPageH, bFont)
   LOCAL aExtra := ARRAY(DFWINREP_EX_LEN)

   // DEFAULT nTop   TO 0
   // DEFAULT nLeft  TO 0
   DEFAULT nLine  TO 42.3333   // Interlinea 1/6 di pollice in CM

   aExtra[DFWINREP_EX_MARGTOP    ] := nTop    // Margine sup. FISICO
   aExtra[DFWINREP_EX_MARGLEFT   ] := nLeft   // Margine sin. FISICO
   aExtra[DFWINREP_EX_INTERLINE  ] := nLine   // Interlinea
   aExtra[DFWINREP_EX_PAGEHEIGHT ] := nPageH  // lungh. pagina
   aExtra[DFWINREP_EX_FONTS      ] := bFont   // codeblock per impostare font

RETURN aExtra
