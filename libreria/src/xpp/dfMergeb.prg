#include "common.ch"

// simone 6/11/08 mantis 2040
// cMode usato per s2form.prg
FUNCTION dfMergeBlocks(b1, b2, cMode)
   LOCAL b

   IF b1 == NIL
      RETURN b2
   ENDIF

   IF b2 == NIL
      RETURN b1
   ENDIF
   
   DEFAULT cMode TO ""

   IF ! EMPTY(cMode) 
      cMode := UPPER(cMode)

      IF cMode == "IIF"
         RETURN {|p1, p2, p3, p4, p5, p6, p7, p8, p9, p10| ;
                  IIF( EVAL(b1, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10), ;
                          EVAL(b2, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10), ;
                          NIL)  }

      ELSEIF cMode == ".AND." 
         RETURN {|p1, p2, p3, p4, p5, p6, p7, p8, p9, p10| ;
                  EVAL(b1, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) .AND. ;
                  EVAL(b2, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)  }


      ELSEIF cMode == ".OR." 
         RETURN {|p1, p2, p3, p4, p5, p6, p7, p8, p9, p10| ;
                  EVAL(b1, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10) .OR. ;
                  EVAL(b2, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)  }


      ENDIF
   ENDIF

RETURN {|p1, p2, p3, p4, p5, p6, p7, p8, p9, p10| ;
         EVAL(b1, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10), ;
         EVAL(b2, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)  }
