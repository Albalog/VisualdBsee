//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"   // CLIPPER
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record

#ifdef __XPP__
   #include "dfWinRep.ch"
#endif

#define IB_VAR  1
#define IB_COL  2
#define IB_ATR  3
#define IB_PRE  4
#define IB_POST 5
#define IB_FILL 6

#define ROW_ARR    1
#define ROW_BAN    2

STATIC aRowBuffer := { {}, 0 }
STATIC aAllBuffer := {}

#ifndef __XPP__
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPrint( nRow  ,; // Riga
                   nCol  ,; // Colonna
                   uVar  ,; // Variabile
                   cPic  ,; // Picture
                   nAtr  ,; // Attributo
                   lMul  ,; // Multiriga
                   nLen  ,; // Lunghezza
                   cPre  ,; // Carattere che precede i MULTIRIGA
                   cPost ,; // Carattare che segue i MULTIRIGA
                   cFill  ) // Carattere di FILL per i MULTIRIGA
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

   _dfPrint( nRow  ,; // Riga
             nCol  ,; // Colonna
             uVar  ,; // Variabile
             cPic  ,; // Picture
             nAtr  ,; // Attributo
             lMul  ,; // Multiriga
             nLen  ,; // Lunghezza
             cPre  ,; // Carattere che precede i MULTIRIGA
             cPost ,; // Carattare che segue i MULTIRIGA
             cFill  ) // Carattere di FILL per i MULTIRIGA

RETURN
#endif



* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE _dfPrint( nRow  ,; // Riga
                    nCol  ,; // Colonna
                    uVar  ,; // Variabile
                    cPic  ,; // Picture
                    nAtr  ,; // Attributo
                    lMul  ,; // Multiriga
                    nLen  ,; // Lunghezza
                    cPre  ,; // Carattere che precede i MULTIRIGA
                    cPost ,; // Carattare che segue i MULTIRIGA
                    cFill  ) // Carattere di FILL per i MULTIRIGA
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSpace, nNewBan, cAtrIni := "", cAtrEnd := "", cSep
LOCAL aBuf:=dfPrnArr(), cVar

DEFAULT nRow TO  0
DEFAULT nCol TO  0
DEFAULT uVar TO ""
DEFAULT nAtr TO PRN_NORMAL
DEFAULT lMul TO .F.

nCol := MAX( 0, nCol )
nRow := MAX( 0, nRow )

// Quando mi sposto di riga provo a stampare il BUFFER
IF nRow+aBuf[REP_BAN_ROW]>aBuf[REP_ACT_ROW] .AND. ;
   !EMPTY( aRowBuffer[ROW_ARR] )                            // Flush Pending Buffer
   dfFlushBuf( aBuf )
END

IF !aBuf[REP_NO_EJECT]
   // Quando vado oltre la pagina scarico il BUFFER
   IF !aBuf[REP_IS_FOOTER]                           .AND. ; // No Printing FOOTER
      (aBuf[REP_BAN_ROW] +nRow) >= aBuf[REP_FOOTER_LINE]

      nNewBan := aBuf[REP_FOOTER_LINE] - aBuf[REP_BAN_ROW] -1

      dfPrnFOOTER(aBuf)                                          // Prn Footer
      dfPrnHEADER(aBuf)                                          // Prn Header

      aBuf[REP_BAN_ROW] := aBuf[REP_ACT_ROW] - nNewBan

   END
END

// Multirow ITEM
IF lMul .OR. VALTYPE(uVar)=="A"
   lMul := !VALTYPE(uVar)=="A"
   uVar := dfPrnBuffer( nCol, uVar, aRowBuffer[ROW_ARR], cPic, nAtr,;
                                       lMul, nLen, cPre, cPost, cFill )
   aRowBuffer[ROW_BAN] := aBuf[REP_BAN_ROW]
ENDIF

// Separo dalla riga precedente
cSep := REPLICATE( CRLF, nRow +aBuf[REP_BAN_ROW] -MAX(aBuf[REP_ACT_ROW],1) )

// Incremento riga
IF nRow+aBuf[REP_BAN_ROW] > aBuf[REP_ACT_ROW]
   aBuf[REP_ACT_ROW] := nRow+aBuf[REP_BAN_ROW]
   aBuf[REP_ACT_COL] := 0
   IF aBuf[REP_MGN_LEFT]>0
      cSep += SPACE(aBuf[REP_MGN_LEFT])
   ENDIF
ENDIF

// Aggiorno colonna
nSpace := MAX(nCol -aBuf[REP_ACT_COL], 0)
IF !EMPTY(cPic)
   cVar   := TRANSFORM( uVar, cPic )
ELSE
   cVar   := dfAny2Str( uVar, cPic )
ENDIF

#ifdef __XPP__

// Simone 29/8/03
// In Xbase se vado in anteprima 
// uso la dfCtrlStringDel che calcola la lunghezza di una stringa
// togliendo i caratteri di controllo (escSETUP,escBOLD, ecc)
// perche senno nella S2PDisPR() la carta usata (A3/A4) pu•
// essere sbagliata se stampo ad es. dfPrint(1, 1, "escBOLDONCIAOescBOLDOF")
//
// Sarebbe giusto farlo sempre, ma per non rallentare il sistema lo faccio solo
// se vado in anteprima e ho un ESC nella stringa
IF aBuf[REP_PRINTERPORT] == "VIDEO" .AND. DFWINREP_CODE $ cVar
   aBuf[REP_ACT_COL] := nCol + LEN( dfCtrlStringDel(cVar, aBuf) )
ELSE
   aBuf[REP_ACT_COL] := nCol +LEN( cVar )
ENDIF

#else
aBuf[REP_ACT_COL] := nCol +LEN( cVar )
#endif

IF !aBuf[REP_IS_FOOTER]         // Conto gli item stampati, ma non nel footer
   IF !EMPTY(uVar)                 // Evito di contare gli item vuoti
      aBuf[REP_ITEMINPAGE]++
   ENDIF
ENDIF

// Salvo su disco -------------------------------------------------------------

// Attributi prima della stampa
IF VALTYPE(nAtr)=="A" .AND. LEN(nAtr)==2
   cAtrIni := nAtr[1]
   cAtrEnd := nAtr[2]

ELSEIF nAtr#0
   IF dfAnd( nAtr, PRN_BOLD        ) # 0; cAtrIni +=aBuf[REP_BOLD_ON  ]; cAtrEnd +=aBuf[REP_BOLD_OFF ]; ENDIF
   IF dfAnd( nAtr, PRN_ENLARGED    ) # 0; cAtrIni +=aBuf[REP_ENL_ON   ]; cAtrEnd +=aBuf[REP_ENL_OFF  ]; ENDIF
   IF dfAnd( nAtr, PRN_UNDERLINE   ) # 0; cAtrIni +=aBuf[REP_UND_ON   ]; cAtrEnd +=aBuf[REP_UND_OFF  ]; ENDIF
   IF dfAnd( nAtr, PRN_SUPERSCRIPT ) # 0; cAtrIni +=aBuf[REP_SUPER_ON ]; cAtrEnd +=aBuf[REP_SUPER_OFF]; ENDIF
   IF dfAnd( nAtr, PRN_SUBSCRIPT   ) # 0; cAtrIni +=aBuf[REP_SUBS_ON  ]; cAtrEnd +=aBuf[REP_SUBS_OFF ]; ENDIF
   IF dfAnd( nAtr, PRN_CONDENSED   ) # 0; cAtrIni +=aBuf[REP_COND_ON  ]; cAtrEnd +=aBuf[REP_COND_OFF ]; ENDIF
   IF dfAnd( nAtr, PRN_ITALIC      ) # 0; cAtrIni +=aBuf[REP_ITA_ON   ]; cAtrEnd +=aBuf[REP_ITA_OFF  ]; ENDIF
   IF dfAnd( nAtr, PRN_NLQ         ) # 0; cAtrIni +=aBuf[REP_NLQ_ON   ]; cAtrEnd +=aBuf[REP_NLQ_OFF  ]; ENDIF
   IF dfAnd( nAtr, PRN_USER01      ) # 0; cAtrIni +=aBuf[REP_USER1ON  ]; cAtrEnd +=aBuf[REP_USER1OFF ]; ENDIF
   IF dfAnd( nAtr, PRN_USER02      ) # 0; cAtrIni +=aBuf[REP_USER2ON  ]; cAtrEnd +=aBuf[REP_USER2OFF ]; ENDIF
   IF dfAnd( nAtr, PRN_USER03      ) # 0; cAtrIni +=aBuf[REP_USER3ON  ]; cAtrEnd +=aBuf[REP_USER3OFF ]; ENDIF
ENDIF

IF aBuf[REP_ASCII_REPORT]
   cVar := dfStr2ASCII( cVar )
ENDIF

// GERR 3901 Simone 28/8/03
// salvo max col & row per decidere automaticamente
// la dimensione carta nel preview windows
aBuf[REP_MAX_ROW ] := MAX(aBuf[REP_ACT_ROW ], aBuf[REP_MAX_ROW ])
aBuf[REP_MAX_COL ] := MAX(aBuf[REP_ACT_COL ], aBuf[REP_MAX_COL ])
aBuf[REP_MAX_PAGE] := MAX(aBuf[REP_ACT_PAGE], aBuf[REP_MAX_PAGE])

// Item da Stampare
FWRITE( aBuf[REP_FHANDLE], cSep +SPACE(nSpace) +cAtrIni +cVar +cAtrEnd )

RETURN

//
// Entro in questa funzione solo per aggiornare il BUFFER
// All'interno sono sicuro che si tratta o di :
//
// 1) Un Multilinea
// 2) Un Array
//
// in base al primo o al 2' tipo faccio un resize dell'array e aggiungo le
// parti che mancano
//
// NB
//
// Se il 2' valore parte da una colonna occupata ne viene fatto l'OverWrite
//
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfPrnBuffer( nCol, uVar, aBuffer, cPic, nAtr,;
                                   lMul, nLen, cPre, cPost, cFill )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLine, nAct, cLine, nOldLen, nOldCol, aOldBuf, cOldFill, nOldRow
//
// Nella versione 4.0b il buffer prende una nuova struttura
//
// {  "Linea1",            "Linea2"            ... } // Vecchio
// { { {"Linea1"   ,nCol,nAtr,cPre,cPost,cFill},;
//     {"Linea1bis",nCol,nAtr,cPre,cPost,cFill} },;
//   { {"Linea2"   ,nCol,nAtr,cPre,cPost,cFill} } ... } // Nuovo
//
DEFAULT cPre  TO ""
DEFAULT cPost TO ""
DEFAULT cFill TO " "
DEFAULT nLen  TO 79

IF lMul              // Row Count
   IF LEN(uVar)==0
      uVar := " "
   ENDIF
   nLine := MLCOUNT( uVar, nLen )
ELSE
   IF LEN(uVar)==0
      uVar := {""}
   ENDIF
   nLine := LEN(uVar)
ENDIF

nOldLen := LEN(aBuffer)
IF nOldLen < nLine             // Update Buffer LEN
   ASIZE( aBuffer, nLine )
   FOR nOldRow := nOldLen+1 TO nLine
      aBuffer[nOldRow] := {}
      IF nOldLen>0
         FOR nOldCol := 1 TO LEN(aBuffer[nOldLen])
             aOldBuf  := aBuffer[nOldLen][nOldCol]
             cOldFill := REPLICATE( aOldBuf[IB_FILL], LEN(aOldBuf[IB_VAR]) -LEN(aOldBuf[IB_PRE]) -LEN(aOldBuf[IB_POST]) )
             AADD( aBuffer[nOldRow],{ ;
                aOldBuf[IB_PRE ] +cOldFill +aOldBuf[IB_POST] ,;
                aOldBuf[IB_COL ] ,;
                aOldBuf[IB_ATR ] ,;
                aOldBuf[IB_PRE ] ,;
                aOldBuf[IB_POST] ,;
                aOldBuf[IB_FILL] })
         NEXT
      ENDIF
   NEXT
ENDIF

FOR nAct := 1 TO nLine
   IF lMul
      cLine := MEMOLINE( uVar, nLen, nAct )
   ELSE
      cLine := uVar[nAct]
   END
   cLine := dfAny2Str( cLine, cPic )
   cLine := cPre +PADR( RTRIM( cLine ), LEN(cLine), cFill ) +cPost
   AADD( aBuffer[nAct], { cLine, nCol, nAtr, cPre, cPost, cFill })
NEXT

IF LEN(aBuffer)>nLine
   aOldBuf  := ATAIL(aBuffer[nLine])
   cOldFill := REPLICATE( aOldBuf[IB_FILL], LEN(aOldBuf[IB_VAR ]) -LEN(aOldBuf[IB_PRE]) -LEN(aOldBuf[IB_POST]) )
   FOR nAct := nLine+1 TO LEN(aBuffer)
      AADD( aBuffer[nAct], { ;
                   aOldBuf[IB_PRE ] +cOldFill +aOldBuf[IB_POST] ,;
                   aOldBuf[IB_COL ] ,;
                   aOldBuf[IB_ATR ] ,;
                   aOldBuf[IB_PRE ] ,;
                   aOldBuf[IB_POST] ,;
                   aOldBuf[IB_FILL] })
   NEXT
ENDIF

RETURN ATAIL(aBuffer[1])[IB_VAR]

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfFlushBuf( aBuf ) // Scarica il buffer in memoria sulla stampante
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRow, nSub, aPrnBuf, lInc, nAct
IF !EMPTY(aRowBuffer[ROW_ARR])
   aPrnBuf := aRowBuffer[ROW_ARR]
   aRowBuffer[ROW_ARR]:= {}

   lInc:=aBuf[REP_BAN_ROW]==aRowBuffer[ROW_BAN]

   nAct := MAX(aBuf[REP_ACT_ROW]-aBuf[REP_BAN_ROW],0)

   FOR nRow := 2 TO LEN(aPrnBuf)
      IF lInc; aBuf[REP_BAN_ROW]++; ENDIF
      FOR nSub := 1 TO LEN(aPrnBuf[nRow])
         dfPrint( nAct                        ,;
                  aPrnBuf[nRow][nSub][IB_COL] ,;
                  aPrnBuf[nRow][nSub][IB_VAR] ,;
                  NIL                         ,;
                  aPrnBuf[nRow][nSub][IB_ATR]  )
      NEXT
      IF !lInc; aBuf[REP_BAN_ROW]++; ENDIF
   NEXT
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfisPrnBuf(); RETURN LEN(aRowBuffer[ROW_ARR])>0
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPrintBuf( aBuf, nBufRow ) // Scarica n' righe del buffer interno
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSub, aPrnBuf, nOfs:=1
aPrnBuf := aRowBuffer[ROW_ARR]
dfPushBuffer()
WHILE nBufRow>0
   IF LEN(aPrnBuf)>=2
      aBuf[REP_BAN_ROW] := aBuf[REP_ACT_ROW] +nOfs
      FOR nSub := 1 TO LEN(aPrnBuf[2])
         dfPrint( 0                        ,;
                  aPrnBuf[2][nSub][IB_COL] ,;
                  aPrnBuf[2][nSub][IB_VAR] ,;
                  NIL                      ,;
                  aPrnBuf[2][nSub][IB_ATR]  )
      NEXT
      ADEL( aPrnBuf, 2 ); ASIZE( aPrnBuf, LEN(aPrnBuf)-1 )
      dfPrint(1)
      nOfs := 0
   ELSE
      dfPrint(nBufRow)
      nBufRow:=1
   END
   nBufRow--
ENDDO
dfPopBuffer()
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPushBuffer()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
AADD( aAllBuffer, aRowBuffer )
aRowBuffer := { {}, 0 }
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPopBuffer()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
aRowBuffer := ATAIL(aAllBuffer)
ASIZE(aAllBuffer,LEN(aAllBuffer)-1)
RETURN

#ifdef __XPP__

// toglie caratteri di controllo dalla stringa (escSETUP,escBOLD, ecc)
STATIC FUNCTION dfCtrlStringDel(cVar, aBuf)
   cVar := STRTRAN(cVar, aBuf[REP_SETUP     ], "")
   cVar := STRTRAN(cVar, aBuf[REP_RESET     ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_BOLD_ON   ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_BOLD_OFF  ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_ENL_ON    ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_ENL_OFF   ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_UND_ON    ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_UND_OFF   ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_SUPER_ON  ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_SUPER_OFF ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_SUBS_ON   ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_SUBS_OFF  ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_COND_ON   ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_COND_OFF  ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_ITA_ON    ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_ITA_OFF   ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_NLQ_ON    ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_NLQ_OFF   ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_USER1ON   ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_USER1OFF  ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_USER2ON   ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_USER2OFF  ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_USER3ON   ], "") 
   cVar := STRTRAN(cVar, aBuf[REP_USER3OFF  ], "") 
RETURN cVar
#endif