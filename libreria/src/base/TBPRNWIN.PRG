/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "common.ch"
#include "dfWin.ch"
#include "dfReport.ch"

#define PRN_HEADER     1
#define PRN_BLOCK      2
#define PRN_PICTURE    3
#define PRN_WIDTH      4
#define PRN_POS        5
#define PRN_FOOTER     6
#define PRN_TYPE       7
#define PRN_TOTAL      8
#define PRN_FOOTBLOCK  9
#define PRN_FOOTPIC   10
#define PRN_PRINT     11

STATIC aStruct
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbPrnWin( oTbr, lAll )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aVRec := {}, aVirRec := {}, VRloc, aBuffer, nCol, oCol, nPos, nWidth
LOCAL lPreview := .T., aCol, nTotal, cPic, nSize, cRemPort

DEFAULT lAll TO .F.

aStruct := {}

(oTbr:W_ALIAS)->(dfPushArea())

VRLoc := dfVRCreate()
VRLoc[VR_NAME  ]     := oTbr:W_ALIAS           // Nome del file

VRLoc[VR_EOF_MODE]   := VR_IGNORE
VRLoc[VR_EJECT ]     := .F.

VRLoc[VR_KEY   ]     := oTbr:W_KEY
VRLoc[VR_FILTER]     := oTbr:W_FILTER
VRLoc[VR_BREAK ]     := oTbr:W_BREAK

VRLoc[VR_HEADER]     := {||tbPrnHea(nSize)}
VRLoc[VR_ROWHEADER]  := 4
VRLoc[VR_BRKHEADER]  := .T.

VRLoc[VR_BODY  ]     := {||tbPrnBody()}
VRLoc[VR_ROWBODY  ]  := 1
VRLoc[VR_BRKBODY  ]  := .F.
VRLoc[VR_EJECTBODY]  := .F.
VRLoc[VR_BODY2HEAD]  := .T.

//IF !EMPTY(oTbr:FOOTSEP)
   //VRLoc[VR_FOOTER]     := {||tbPrnFoo()}
   //VRLoc[VR_ROWFOOTER]  := 2
   //VRLoc[VR_BRKFOOTER]  := .T.
//ENDIF

dfVrAddFle( aVirRec, {}, VRLoc )

aBuffer := dfPrnCfg()                      // Inizializzazione

aBuffer[ REP_NAME ]  := dbMMrg(STRTRAN(oTbr:W_TITLE,dfHot()))  //  Intestazione report
aBuffer[ REP_VREC ]  := aVirRec

IF !lAll
   aCol := dfCol2Prn( oTbr )
ENDIF

nSize := 0
FOR nCol := 1 TO oTbr:COLCOUNT
   oCol    := oTbr:GETCOLUMN( nCol )
   IF ASCAN( aCol, nCol )>0 .OR. lAll
      nWidth  := tbColWidth( oTbr, oCol )

      nTotal := NIL
      cPic   := NIL
     #ifdef __XPP__
      IF isMemberVar(oCol, "WC_TOTALVALUE")
     #else
      IF oCol:CARGO != NIL
     #endif
         nTotal := oCol:WC_TOTALVALUE
         cPic   := oCol:WC_PICTURE
      ENDIF
      AADD( aStruct, { PADR(tbGetColHeading(oCol),nWidth) ,;
                       oCol:BLOCK                ,;
                       oCol:PICTURE              ,;
                       nWidth                    ,;
                       nSize                     ,;
                       PADR(tbGetColFooting(oCol),nWidth) ,;
                       VALTYPE(EVAL(oCol:BLOCK)) ,;
                       0                         ,;
                       nTotal                    ,;
                       cPic                      ,;
                       .T.                       })

      IF !EMPTY( ALLTRIM( PADR(tbGetColFooting(oCol),nWidth) ) )
         VRLoc[VR_FOOTER]     := {||tbPrnFoo()}
         VRLoc[VR_ROWFOOTER]  := 2
         VRLoc[VR_BRKFOOTER]  := .T.
      ENDIF

      IF nCol==1 .AND. oTbr:W_TAGARRAY#NIL
         aStruct[1][PRN_BLOCK] := {||IF(tbGetTag(oTbr)," ¯","  ")}
      ENDIF
      nSize += (nWidth+1)
   ELSE
      AADD( aStruct, {,oCol:BLOCK,,,,,,,,,.F.} )
   ENDIF
NEXT
IF nSize>79
   aBuffer[REP_IS_CONDENSED] := .T.
ENDIF

cRemPort := aBuffer[REP_PRINTERPORT]
WHILE lPreview .AND. nSize>0
   // Configurazione con parametri di layout
   // Attenzione se il giochino del loop non dovesse funzionare
   // Clonare aBuffer e assegnarlo prina del dfPrnMenu

   // Riassegno alcuni valori per evitare problemi se interrompo o
   // vado in preview
   aBuffer[REP_PRINTERPORT]   := cRemPort
   aBuffer[REP_IS_QUIT]       := .F.
   aBuffer[REP_IS_ABORT]      := .F.

   IF dfPrnMenu( aBuffer )
      FOR nPos := 1 TO LEN(aStruct)
         aStruct[nPos][PRN_TOTAL] := 0
      NEXT
      lPreview := (M->Act=="new")
      dfPrnStart( aVirRec )
   ELSE
      lPreview := .F.
   ENDIF
ENDDO

(oTbr:W_ALIAS)->(dfPopArea())

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE tbPrnHea(nSize)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, cTit

cTit := ALLTRIM(dfPrnArr()[REP_NAME])
cTit := PADR( cTit, nSize-9 ) +" PG " +PADL( dfPrnArr()[REP_ACT_PAGE], 4 )
dfPrint( 0, 0, cTit  )

FOR nPos := 1 TO LEN(aStruct)
   IF aStruct[nPos][PRN_PRINT]
      dfPrint( 2, aStruct[nPos][PRN_POS], aStruct[nPos][PRN_HEADER] )
   ENDIF
NEXT
FOR nPos := 1 TO LEN(aStruct)
   IF aStruct[nPos][PRN_PRINT]
      dfPrint( 3, aStruct[nPos][PRN_POS], REPLICATE("Ä",aStruct[nPos][PRN_WIDTH]) )
   ENDIF
NEXT
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE tbPrnBody()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, cStr
FOR nPos := 1 TO LEN(aStruct)
   cStr := dfAny2Str( EVAL(aStruct[nPos][PRN_BLOCK]), aStruct[nPos][PRN_PICTURE] )
   IF aStruct[nPos][PRN_PRINT]
      DO CASE
         CASE aStruct[nPos][PRN_TYPE]=="N"
              cStr := SPACE(aStruct[nPos][PRN_WIDTH]-LEN(cStr)) +cStr
         CASE aStruct[nPos][PRN_TYPE]=="L"
              cStr := PADC( cStr, aStruct[nPos][PRN_WIDTH] )
      ENDCASE
      cStr := PADR( cStr, aStruct[nPos][PRN_WIDTH] )
      dfPrint( 0, aStruct[nPos][PRN_POS], cStr )
      IF aStruct[nPos][PRN_FOOTBLOCK]!=NIL
         aStruct[nPos][PRN_TOTAL] += EVAL(aStruct[nPos][PRN_FOOTBLOCK])
      ENDIF
   ENDIF
NEXT
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE tbPrnFoo()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos
FOR nPos := 1 TO LEN(aStruct)
   IF aStruct[nPos][PRN_PRINT]
      dfPrint( 0, aStruct[nPos][PRN_POS], REPLICATE("Ä",aStruct[nPos][PRN_WIDTH]) )
   ENDIF
NEXT
FOR nPos := 1 TO LEN(aStruct)
   IF aStruct[nPos][PRN_PRINT]
      IF aStruct[nPos][PRN_FOOTBLOCK]!=NIL
         dfPrint( 1, aStruct[nPos][PRN_POS],;
            PADL( TRANSFORM( aStruct[nPos][PRN_TOTAL],;
                    aStruct[nPos][PRN_FOOTPIC] ), aStruct[nPos][PRN_WIDTH] ) )
      ELSE
         dfPrint( 1, aStruct[nPos][PRN_POS], aStruct[nPos][PRN_FOOTER] )
      ENDIF
   ENDIF
NEXT
RETURN
