// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
// Description : Centralised Automatic Lookup function
// *****************************************************************************
#include "dfWin.ch"

// STATIC bCheck := {|nKey| nKey >= 32 .AND. nKey <= 132 } // Check the range

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbIsFast( oTbr ) // Utility function for FASTSEEK and FASTEDIT
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN (! dfSet(AI_DISABLEFASTSEEK) .AND. ;  // enabled?
        !EMPTY(oTbr:W_ALIAS)  .AND. ; // Check the alias
        M->A <> 32            .AND. ; // Remove key spacebar " "
        M->A <> 43            .AND. ; // Remove Skip key "+" and "-"
        M->A <> 45            .AND. ;
        tbFastSChkKey( M->A ) .AND. ;      // check the range
        (oTbr:WOBJ_TYPE==W_OBJ_BRW .OR.;   // Check The type
         oTbr:WOBJ_TYPE==W_OBJ_BROWSEBOX))  // Only listbox or browse
/*
        M->A>=33             .AND. ; // Check the range
        M->A<=125            .AND. ; //
        M->A#43              .AND. ; // Remove Skip key "+" and "-"
        M->A#45              .AND. ;
*/


FUNCTION tbFastSChkKey(nKey)
RETURN EVAL( _trnKey( dfSet(AI_FASTSEEKVALIDKEY) ), nKey )

STATIC FUNCTION _trnKey(bNew)
   LOCAL bRet := {|nKey| nKey >= 32 .AND. nKey <= 132 } // default: Check the range
   DO CASE 
      CASE bNew == NIL
          // usa il default

      CASE VALTYPE(bNew) == "B"
          bRet   := bNew

      CASE VALTYPE(bNew) $ "CM"
          bRet   := {|nKey| CHR(nKey) $ bNew }
   ENDCASE
RETURN bRet



/*
FUNCTION tbFastSChkKey(nKey)
RETURN EVAL(bCheck, nKey)

// set the valid keys
STATIC FUNCTION tbFastSSetKey(bNew)
//   LOCAL bRet := bCheck
   DO CASE 
      CASE VALTYPE(bNew) == "B"
          bCheck := bNew

      CASE VALTYPE(bNew) == "L"    
          IF bNew
             // reset to default
             bCheck := {|nKey| nKey >= 32 .AND. nKey <= 132 } // Check the range
          ELSE
             // disable
             bCheck := {|nKey| .F.}
          ENDIF

      CASE VALTYPE(bNew) $ "CM"
          bCheck := {|nKey| CHR(nKey) $ bNew }
   ENDCASE
RETURN bRet
*/

