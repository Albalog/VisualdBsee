//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per PRN
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfSet.ch"
#include "dfMsg.ch"
#include "dfReport.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIniPrn() // Array Stampanti
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aPrn := {}
dfScanIni( "printer", {|lMod|dfLoadPrn(aPrn,lMod)} )
RETURN aPrn

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfLoadPrn( aPrn, lMod )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr, cLeft, aRight, cRight

DEFAULT lMod TO .F.

IF dfSet( AI_INIMESSAGE )
   dfWaitOn( dfStdMsg(MSG_DFINIPRN01) ) // ON Message
ENDIF
DO WHILE !dfFEof()
   IF dfSet( AI_INIMESSAGE )
      dfWaitStep()           // Step message
   ENDIF
   cStr := ALLTRIM(dfFRead())
   DO CASE
      CASE !lMod .AND. Left(cStr,1) == "["                  // altra sezione
           EXIT

      OTHERWISE
           cLeft  := UPPER(dfLeft(cStr))
           aRight := dfRight( cStr, RT_ARRAY, RT_NUMBER )
           cRight := ""
           IF cLeft=="ID"    .OR.;
              cLeft=="INFO"  .OR.;
              ( LEN(aRight)==1 .AND. aRight[1]==0 )
              cRight:=dfRight( cStr )
           ELSE
              AEVAL( aRight, {|nSub|cRight+=CHR(nSub)} )
           ENDIF
           DO CASE
              CASE EMPTY(cRight)

              CASE cLeft=="ID"
                   AADD( aPrn, ARRAY(PRINTER_LEN) )
                   AFILL( ATAIL(aPrn), "" )
                   ATAIL(aPrn)[PRINTER_ID]     := cRight

              CASE EMPTY(aPrn)
              CASE cLeft=="INFO"           ; ATAIL(aPrn)[PRINTER_INFO          ] := cRight
              CASE cLeft=="SETUP"          ; ATAIL(aPrn)[PRINTER_SETUP         ] := cRight
              CASE cLeft=="RESET"          ; ATAIL(aPrn)[PRINTER_RESET         ] := cRight
              CASE cLeft=="BOLDON"         ; ATAIL(aPrn)[PRINTER_BOLDON        ] := cRight
              CASE cLeft=="BOLDOFF"        ; ATAIL(aPrn)[PRINTER_BOLDOFF       ] := cRight
              CASE cLeft=="ENLARGEDON"     ; ATAIL(aPrn)[PRINTER_ENLARGEDON    ] := cRight
              CASE cLeft=="ENLARGEDOFF"    ; ATAIL(aPrn)[PRINTER_ENLARGEDOFF   ] := cRight
              CASE cLeft=="UNDERLINEON"    ; ATAIL(aPrn)[PRINTER_UNDERLINEON   ] := cRight
              CASE cLeft=="UNDERLINEOFF"   ; ATAIL(aPrn)[PRINTER_UNDERLINEOFF  ] := cRight
              CASE cLeft=="SUPERSCRIPTON"  ; ATAIL(aPrn)[PRINTER_SUPERSCRIPTON ] := cRight
              CASE cLeft=="SUPERSCRIPTOFF" ; ATAIL(aPrn)[PRINTER_SUPERSCRIPTOFF] := cRight
              CASE cLeft=="SUBSCRIPTON"    ; ATAIL(aPrn)[PRINTER_SUBSCRIPTON   ] := cRight
              CASE cLeft=="SUBSCRIPTOFF"   ; ATAIL(aPrn)[PRINTER_SUBSCRIPTOFF  ] := cRight
              CASE cLeft=="CONDENSEDON"    ; ATAIL(aPrn)[PRINTER_CONDENSEDON   ] := cRight
              CASE cLeft=="CONDENSEDOFF"   ; ATAIL(aPrn)[PRINTER_CONDENSEDOFF  ] := cRight
              CASE cLeft=="ITALICON"       ; ATAIL(aPrn)[PRINTER_ITALICON      ] := cRight
              CASE cLeft=="ITALICOFF"      ; ATAIL(aPrn)[PRINTER_ITALICOFF     ] := cRight
              CASE cLeft=="NLQON"          ; ATAIL(aPrn)[PRINTER_NLQON         ] := cRight
              CASE cLeft=="NLQOFF"         ; ATAIL(aPrn)[PRINTER_NLQOFF        ] := cRight
              CASE cLeft=="USER01ON"       ; ATAIL(aPrn)[PRINTER_USER01ON      ] := cRight
              CASE cLeft=="USER01OFF"      ; ATAIL(aPrn)[PRINTER_USER01OFF     ] := cRight
              CASE cLeft=="USER02ON"       ; ATAIL(aPrn)[PRINTER_USER02ON      ] := cRight
              CASE cLeft=="USER02OFF"      ; ATAIL(aPrn)[PRINTER_USER02OFF     ] := cRight
              CASE cLeft=="USER03ON"       ; ATAIL(aPrn)[PRINTER_USER03ON      ] := cRight
              CASE cLeft=="USER03OFF"      ; ATAIL(aPrn)[PRINTER_USER03OFF     ] := cRight
              CASE cLeft=="PAGELENGHT"     ; ATAIL(aPrn)[PRINTER_PAGELENGHT    ] := cRight
           ENDCASE
   ENDCASE
   dfFSkip()
ENDDO
IF dfSet( AI_INIMESSAGE )
   dfWaitOff()               // OFF message
ENDIF

RETURN
