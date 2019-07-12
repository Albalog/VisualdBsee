//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "Set.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
#INCLUDE "dfMsg.ch"    // Messaggistica
#INCLUDE "dfStd.ch"    // Standard

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfSpcPrn( aVRec, nMode )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aBuf, lRow := .F., nAbsPos := 0, cBuf, nPos, cFilStp, cDmm

DEFAULT nMode TO PRINT_ALL

aBuf := dfPrnArr()

// Filtri
dfPrnConfig( aBuf )

DEFAULT aBuf[REP_PRINTERPORT] TO "LPT1"   // Device di DEFAULT
aBuf[REP_FHANDLE] := 0

aBuf[REP_PRINTERPORT] := UPPER(aBuf[REP_PRINTERPORT])

DO CASE
   CASE aBuf[REP_PRINTERPORT]=="LPT1" ; aBuf[REP_FHANDLE] := PRN_LPT1
   CASE aBuf[REP_PRINTERPORT]=="LPT2" ; aBuf[REP_FHANDLE] := PRN_LPT2
   CASE aBuf[REP_PRINTERPORT]=="LPT3" ; aBuf[REP_FHANDLE] := PRN_LPT3
   CASE aBuf[REP_PRINTERPORT]=="LPT4" ; aBuf[REP_FHANDLE] := PRN_LPT4
   CASE aBuf[REP_PRINTERPORT]=="LPT5" ; aBuf[REP_FHANDLE] := PRN_LPT5
   CASE aBuf[REP_PRINTERPORT]=="LPT6" ; aBuf[REP_FHANDLE] := PRN_LPT6
   CASE aBuf[REP_PRINTERPORT]=="LPT7" ; aBuf[REP_FHANDLE] := PRN_LPT7
   CASE aBuf[REP_PRINTERPORT]=="LPT8" ; aBuf[REP_FHANDLE] := PRN_LPT8
   CASE aBuf[REP_PRINTERPORT]=="LPT9" ; aBuf[REP_FHANDLE] := PRN_LPT9
   CASE aBuf[REP_PRINTERPORT]=="COM1" ; aBuf[REP_FHANDLE] := PRN_COM1
   CASE aBuf[REP_PRINTERPORT]=="COM2" ; aBuf[REP_FHANDLE] := PRN_COM2
   CASE aBuf[REP_PRINTERPORT]=="COM3" ; aBuf[REP_FHANDLE] := PRN_COM3
   CASE aBuf[REP_PRINTERPORT]=="COM4" ; aBuf[REP_FHANDLE] := PRN_COM4
   CASE aBuf[REP_PRINTERPORT]=="VIDEO"
   OTHERWISE; aBuf[REP_PRINTERPORT] := aBuf[REP_FNAME]
ENDCASE

dbMsgOn( dfStdMsg( MSG_DFFILE2PRN02 ) )

IF aBuf[REP_PRINTERPORT]=="VIDEO"
   FCLOSE( dfFileTemp( @cDmm ) )  // Report Handle
   SET PRINTER TO (cDmm)
ELSE
   SET PRINTER TO (aBuf[REP_PRINTERPORT])
ENDIF

SET DEVICE  TO PRINTER
SETPRC(0,0)
cFilStp := SET( _SET_PRINTFILE )

dfSpcPri( {dfPrnIni( aBuf )} )
(aVRec[1][VR_NAME])->(dfSpcSvi(aVRec[1],.T.,nMode)) // Stampa
dfSpcPri( {dfPrnEnd( aBuf )} )

SET PRINTER TO
SET DEVICE TO SCREEN
dbMsgOff()

DO CASE
   CASE "VIDEO"==aBuf[REP_PRINTERPORT]
        dfTView( 0, 0, MAXROW()-2, MAXCOL(), cDmm+".PRN", aBuf[REP_NAME] )
        FERASE( cDmm+".PRN" )
        FERASE( cDmm )

        // Rinomino sul file che ha detto l'utente!
   CASE aBuf[REP_PRINTERPORT] == aBuf[REP_FNAME]
        FERASE( aBuf[REP_FNAME] )
        FRENAME( cFilStp, aBuf[REP_FNAME] )
ENDCASE

DEFAULT aBuf[REP_QRY_EXP] TO ""

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfSpcPri( aVar, nAtr, nRow )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cAtrIni:="", cAtrEnd:="", nAct, cRet := "", aBuf := dfPrnArr()

DEFAULT nAtr TO 0
DEFAULT nRow TO 0

// Attributi prima della stampa
IF nAtr#0
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

IF nRow#0
   IF EMPTY cRet ASSIGN CRLF
ENDIF

FOR nAct := 1 TO LEN(aVar)
   IF aBuf[REP_FHANDLE]#0
      WHILE !dfPrnChk(aBuf[REP_FHANDLE]) .AND. !aBuf[REP_IS_QUIT]
         IF dfINKEY()#0 //FW
            // In 4.4 non serve piu'
            //SET DEVICE TO SCREEN
            aBuf[REP_IS_QUIT] := dfYesNo( dfStdMsg(MSG_DFFILE2PRN03), .F. )
            //SET DEVICE TO PRINTER
         ENDIF
      ENDDO
   ELSE
      IF dfINKEY()#0 //FW
         // In 4.4 non serve piu'
         //SET DEVICE TO SCREEN
         aBuf[REP_IS_QUIT] := dfYesNo( dfStdMsg(MSG_DFFILE2PRN03), .F. )
         //SET DEVICE TO PRINTER
      ENDIF
   ENDIF
   IF !aBuf[REP_IS_QUIT]
      IF aVar[nAct] == NIL
         aVar[nAct] := ""
      ENDIF
      @ PROW(), PCOL() SAY cRet+cAtrIni+aVar[nAct]+cAtrEnd
      IF EMPTY cRet ASSIGN CRLF
   ENDIF
NEXT

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfSpcSvi( aVR, lMaster, nMode ) // Sviluppatore interno FILE
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lAllign, nRec, aPar := {,,,,,,,,}, aBuf, nAct := 0

DEFAULT lMaster TO .F.
DEFAULT nMode   TO PRINT_ALL

aBuf := dfPrnArr()

IF lMaster
   IF nMode==PRINT_ALL      // Posiziono il FILE al 1' Record del master
      dfReportTOP( aVR )    // Solo se devo stampare tutto
   ENDIF
ELSE
   dfReportTOP( aVR )
ENDIF

IF !Eof()
   nRec:=RECNO()
   WHILE !(lAllign := dfPrnAllign( aVr, .T., aBuf )) // NON sono allineato
      IF dfReportSKIP( aVR ) == 0              // Skippo
         EXIT
      END
   END
   IF lMaster .AND. nMode==PRINT_CURRENT .AND. nRec#RECNO()
      DBGOTO(nRec)
      lAllign:=.F.
   ENDIF

   IF lAllign // Se sono allineato stampo
      IF aVR[VR_HEADER]#NIL; EVAL( aVR[VR_HEADER] ); END  // Stampo l'Header
      WHILE lAllign    // Finche' sono allineato
         IF lMaster
            dfPro( MAXROW(), 0, MAXCOL(), ++nAct, RECCOUNT(), "B+/G" )
         ENDIF
         IF aVR[VR_BODY]#NIL; dfPrintBand( aVR[VR_BODY] ); END // Stampo la riga

         IF !EMPTY(aVR[VR_CHILD]) // chiamo i sottofigli
            AEVAL( aVR[VR_CHILD], {|aLRec| (aLRec[VR_NAME])->(dfSpcSvi(aLRec)) })
         ENDIF
         IF aBuf[REP_IS_ABORT] .OR. aBuf[REP_IS_QUIT]
            EXIT
         END

         IF lMaster .AND. nMode==PRINT_CURRENT ; EXIT; ENDIF // In CURRENT non SKIPPO

         // skippo di 1
         IF dfReportSKIP( aVR ) == 0  // Se skip == 0 Sono in EOF
            lAllign := .F.            // allora non sono piu' allineato
         ELSE
            WHILE !(lAllign := dfPrnAllign( aVr, .T., aBuf )) // NON Sono Allineato
               IF dfReportSKIP( aVR ) == 0              // Skippo
                  EXIT
               END
            END
         END
      END
      IF !aBuf[REP_IS_ABORT] .AND. !aBuf[REP_IS_QUIT]
         aBuf[REP_IS_LAST] := .T.
         IF aVR[VR_FOOTER]#NIL; EVAL( aVR[VR_FOOTER] ); END
         aBuf[REP_IS_LAST] := .F.
      END
   END
ELSE // Check EOF mode
   IF aVR[VR_EOF_MODE] == VR_ABORT
      aBuf[REP_IS_ABORT] := .T.
   END
END

RETURN
