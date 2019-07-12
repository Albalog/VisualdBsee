#include "common.ch"
#include "xbp.ch"

// Torna se l'oggetto Š valido.. (creato e visibile)
FUNCTION S2XbpIsValid( oXbp )
   DEFAULT oXbp TO S2FormCurr()
RETURN ! EMPTY(oXbp) .AND. oXbp:status() == XBP_STAT_CREATE .AND. ;
       oXbp:isVisible()
