//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.CH"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

// Abiita il LOG
//#define __LOG__
//#define __LOG_SKIP__

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfSkip( n2Skip, bFilter, bBreak ) // dbSkip
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSkipped := 0, nActRec := IF(EOF(),0,RECNO())
LOCAL nAlias := SELECT()

DEFAULT n2Skip     TO 1
#ifdef __LOG_SKIP__
   __Log("skip10 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif
DO CASE
   CASE (LastRec() == 0) .OR. (n2Skip == 0)
#ifdef __LOG_SKIP__
   __Log("skip20 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif
        dbSkip(0)
        DBGOTO(nActRec)

   CASE (n2Skip > 0)
#ifdef __LOG_SKIP__
   __Log("skip30 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif
        DO WHILE nSkipped<n2Skip

#ifdef __LOG_SKIP__
   __Log("skip33 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif
           dbSkip(1)
#ifdef __LOG_SKIP__
   __Log("skip35 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif

           // simone 21/1/2010
           // XL 1709
           // salvo e ripristino alias in caso il codeblock lo cambi
           IF Eof() .OR. (nAlias)->( EVAL( bBreak ) )
              dbGoto( nActRec )
              // Simone 02/11/09
              // mantis 0002106: problema con ADS e set filter 
              // FIX perchè con ADS se c'è SET FILTER attivo
              // il dbgoto() non resetta il flag di EOF()
              IF EOF()
                 dbSkip(-1) // fa reset del EOF()
                 dbGoto( nActRec )
              ENDIF
              EXIT
           ENDIF

#ifdef __LOG_SKIP__
   __Log("skip37 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif

           // simone 21/1/2010
           // XL 1709
           // salvo e ripristino alias in caso il codeblock lo cambi
           IF ! (nAlias)->(EVAL( bFilter ))
              LOOP
           ENDIF

#ifdef __LOG_SKIP__
   __Log("skip40 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif


           nActRec := Recno()
           nSkipped++

        ENDDO

   CASE (n2Skip < 0)
#ifdef __LOG_SKIP__
   __Log("skip60 "+alltrim(str(n2skip))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif
        DO WHILE nSkipped>n2Skip
#ifdef __LOG_SKIP__
   __Log("skip63 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif
           dbSkip(-1)
#ifdef __LOG_SKIP__
   __Log("skip65 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif

           // simone 21/1/2010
           // XL 1709
           // salvo e ripristino alias in caso il codeblock lo cambi
           IF Bof() .OR. (nAlias)->(Eval( bBreak ))
              dbGoto( nActRec )
              // Simone 02/11/09
              // mantis 0002106: problema con ADS e set filter 
              // FIX perchè con ADS se c'è SET FILTER attivo
              // il dbgoto() non resetta il flag di BOF()
              IF BOF()
                 dbSkip(1) // fa reset del BOF()
                 dbGoto( nActRec )
              ENDIF

              EXIT
           ENDIF
#ifdef __LOG_SKIP__
   __Log("skip67 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif

           // simone 21/1/2010
           // XL 1709
           // salvo e ripristino alias in caso il codeblock lo cambi
           IF !(nAlias)->(Eval( bFilter ))
              LOOP
           ENDIF

#ifdef __LOG_SKIP__
   __Log("skip70 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif
           nActRec := Recno()
           nSkipped--

        ENDDO

ENDCASE

#ifdef __LOG_SKIP__
   __Log("skip99 "+alltrim(str(n2skip))+" "+alltrim(str(nSkipped))+" "+alltrim(str(nActRec)), NIL, bFilter, bBreak)
#endif

RETURN nSkipped
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfTop( bKey, bFilter, bBreak ) // GoTop
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lEof := .F.
LOCAL nAlias := SELECT()

#ifdef __LOG__
   __Log("top10", bKey, bFilter, bBreak)
#endif

IF bKey == NIL       // se row_key e' vuota
   DBGOTOP()            // vado al primo record
ELSE
   // simone 21/1/2010
   // XL 1709
   // salvo e ripristino alias in caso il codeblock lo cambi
   DBSEEK((nAlias)->(EVAL( bKey )), .T. )   // cerco la chiave in modo SOFT
   lEof := EOF()
ENDIF

#ifdef __LOG__
   __Log("top20", bKey, bFilter, bBreak)
#endif

IF !lEof // Solo se non sono a EOF
#ifdef __LOG__
   __Log("top30", bKey, bFilter, bBreak)
#endif
   // simone 21/1/2010
   // XL 1709
   // salvo e ripristino alias in caso il codeblock lo cambi
   IF ! (nAlias)->(EVAL( bFilter ))             // Se non sono in filtro
      dfSkip( 1, bFilter, bBreak )   // Skippo di 1
   ENDIF

#ifdef __LOG__
   __Log("top40", bKey, bFilter, bBreak)
#endif

   // simone 21/1/2010
   // XL 1709
   // salvo e ripristino alias in caso il codeblock lo cambi
   // Se Break o Filtro NON verificato
   IF (nAlias)->(EVAL( bBreak )) .OR. !(nAlias)->(EVAL( bFilter ))
      DBGOTO(0)
   ENDIF
ENDIF

#ifdef __LOG__
   __Log("top50", bKey, bFilter, bBreak)
#endif

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfBottom( bKey, bFilter, bBreak ) // GoBottom
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActRec, uKey
LOCAL nAlias := SELECT()

#ifdef __LOG__
   __Log("bot10", bKey, bFilter, bBreak)
#endif

IF bKey == NIL                      // se row_key e' vuota
   dbGoBottom()                            // vado al primo record
ELSE                                // se ho passato row_key
   // simone 21/1/2010
   // XL 1709
   // salvo e ripristino alias in caso il codeblock lo cambi
   uKey := (nAlias)->(Eval( bKey ))
   DO CASE
      CASE ValType( uKey ) == [C]        // se e' di tipo Carattere
           // Simone 28/10/2009 
           // 0002105: problema DBGOTO(0) , DBSKIP(-1) con ADS
           // correzione parziale, risolve il pattern indicato nel mantis
           // ma il problema DBGOTO(0), DBSKIP(-1) rimane aperto
           IF uKey==""
              dbGoBottom()
           ELSE
           dbSeek( dfChrInc( uKey ), .T. )
           dbSkip(-1)
           ENDIF
      CASE ValType( uKey ) $ [DN]        // se e' di tipo Data/Numerico
           dbSeek( uKey+1          , .T. )
           dbSkip(-1)
      CASE ValType( uKey ) == [L]        // se e' di tipo Logico
           dbSeek( !uKey           , .T. )
           dbSkip(-1)
   ENDCASE
ENDIF
#ifdef __LOG__
   __Log("bot20", bKey, bFilter, bBreak)
#endif

// simone 21/1/2010
// XL 1709
// salvo e ripristino alias in caso il codeblock lo cambi
IF !(nAlias)->(Eval( bFilter ))                 // Se non sono in filtro
   dfSkip( -1, bFilter, bBreak )       // Skippo di -1
ENDIF

#ifdef __LOG__
   __Log("bot30", bKey, bFilter, bBreak)
#endif


// simone 21/1/2010
// XL 1709
// salvo e ripristino alias in caso il codeblock lo cambi
// Se Break o Filtro NON verificato
IF (nAlias)->(EVAL( bBreak )) .OR. !(nAlias)->(EVAL( bFilter ))
   DBGOTO(0)
ENDIF

#ifdef __LOG__
   __Log("bot40", bKey, bFilter, bBreak)
#endif

RETURN

#ifdef __LOG__
STATIC FUNCTION  __Log(x, bKey, bFilter, bBreak)
LOCAL cMsg
//cMsg := DTOS(DATE())+" "+TIME()+" "+x+" "
cMsg := x
//cMsg += " "+VAR2CHAR(bKey)+":"+EVAL(bKey)
cMsg += " flt:"+VAR2CHAR(EVAL(bFilter))
cMsg += " brk:"+VAR2CHAR(EVAL(bBreak))
cMsg += " "+ALIAS()+ " "+ALLTRIM(STR(RECNO()))+IIF(EOF(), " EOF", "")+IIF(BOF(), " BOF", "")
dfLogMsg(cMsg, .T.)
RETURN .T.
#endif
