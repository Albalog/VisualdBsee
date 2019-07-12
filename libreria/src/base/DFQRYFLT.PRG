//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Query
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfReport.ch"
#include "dfMsg.ch"

#define QUERY_DES  1
#define QUERY_EXP  2

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfQryFltDes( aQuery, aSeq ) // Espressione della query Descrizione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN dfQryFlt( aQuery, aSeq, QUERY_DES )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfQryFltExp( aQuery, aSeq ) // Espressione della query espressione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN dfQryFlt( aQuery, aSeq, QUERY_EXP )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfQryFlt( aQuery, aSeq, nMode )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nQryLen, nField, cType, nError:=0
LOCAL nSeqLen
LOCAL cQryExp, cLocalExp
LOCAL cQryDes
LOCAL i, j
LOCAL cFie, cDes, lEmptyBef, lEmptyAft
LOCAL cFieNam, cFieCon
LOCAL c2Ret := "", lFilter

nQryLen := LEN(aQuery)
nSeqLen := LEN(aSeq)

cQryDes := ""                          // Descrizione della query
cQryExp := ""                          // Espressione della query
lEmptyBef := .F.                       // Vuoto campo prima di link
lEmptyAft := .F.                       // Vuoto campo dopo link
FOR i := 1 TO nSeqLen
    nField := aSeq[i][2]               // Numero campo in aQuery
    DO CASE
       CASE aSeq[i][1] = QRY_PAR       // se e' una parentesi
            cQryExp += aSeq[i][2]      // aggiunge all'espressione
            cQryDes += aSeq[i][2]      // aggiunge alla descrizione

       CASE aSeq[i][1] = QRY_FIELD     // se e' un campo
            if aSeq[i][2] > nQryLen    // controllo che il campo puntato
               nError := 1             // sia entro la dimensione di aQuery
               exit
            endif

            IF aSeq[i+1][1] # QRY_COND // se il prossimo elemento in sequenza
               nError := 2             // non e' una condizione
               EXIT                    // esco con errore = 2
            ENDIF

            IF EMPTY(aQuery[nField][3]) // se il campo e' vuoto
               lEmptyBef := .T.         // attivo il campo vuoto prima
               cQryExp += ".T."         // nella espressione di query metto comunque
               LOOP                     // un valore TRUE
            ENDIF
            lEmptyBef := .F.
            cFieNam := ""               // valorizzo il nome completo di alias
            if !EMPTY(aQuery[nField][4]) // se l'alias non e' vuoto
               cFieNam += aQuery[nField][4] +"->"
            endif
            cFieNam += aQuery[nField][2] // aggiungo il nome del campo dopo alias
            cQryDes += aQuery[nField][1] // aggiungo la descrizione del campo nella stringa descrittiva

            i++                        // passo alla sequenza successiva
            cQryDes += " "             // aggiungo uno spazio alla descrizione
            DO CASE
               CASE aSeq[i][2] == "<"    ;cQryDes += dfStdMsg(MSG_DFQRY01)
               CASE aSeq[i][2] == ">"    ;cQryDes += dfStdMsg(MSG_DFQRY02)
               CASE aSeq[i][2] == "<="   ;cQryDes += dfStdMsg(MSG_DFQRY03)
               CASE aSeq[i][2] == ">="   ;cQryDes += dfStdMsg(MSG_DFQRY04)
               CASE aSeq[i][2] == "="    ;cQryDes += dfStdMsg(MSG_DFQRY05)
               CASE aSeq[i][2] == "#"    ;cQryDes += dfStdMsg(MSG_DFQRY06)
               CASE aSeq[i][2] == "$"    ;cQryDes += dfStdMsg(MSG_DFQRY07)
               CASE aSeq[i][2] == "C"    ;cQryDes += dfStdMsg(MSG_DFQRY08)
               CASE aSeq[i][2] == "=="   ;cQryDes += dfStdMsg(MSG_DFQRY09)
               OTHERWISE                 ;cQryDes += "???"+aSeq[i][2]
            ENDCASE
            cQryDes += " "             // aggiungo uno spazio alla descrizione
            cFieCon := aSeq[i][2]      // memorizzo quale sara' la condizione di confronto sul campo

            cType   := UPPER(aQuery[nField][5]) // tipo di campo
            cFie    := ""
            cDes    := ""

            DO CASE
               CASE cType = "C"        // se il campo e' carattere
                    cDes := aQuery[nField][3]
                    cFie := "'"+RTRIM(ChkStr(cDes,"'"))+"'" // aggiungo i delimitatori in modo intelligente
                    //IF cFieCon=="=="
                    //Corretto su richiesta cliente
                    //Mantis 2079 
                    IF cFieCon=="==" .OR. cFieCon==">=" .OR. cFieCon=="<="
                       cFie := "'"+ChkStr(cDes,"'")+"'" // aggiungo i delimitatori in modo intelligente
                    ENDIF

               CASE cType = "N"        // Numerico
                    cFie := ALLTRIM(STR(aQuery[nField][3]))
                    cDes := cFie

               CASE cType = "D"        // Data
                    cDes := dtoc(aQuery[nField][3])
                    cFie := "CTOD('" + cDes + "')"

               CASE cType = "L"        // Logico
                    IF aQuery[nField][3]
                       cFie := ".T."
                       cDes := dfStdMsg(MSG_DFQRY10)
                    ELSE
                       cFie := ".F."
                       cDes := dfStdMsg(MSG_DFQRY11)
                    ENDIF

               OTHERWISE
                    nError := 3
                    EXIT
            ENDCASE

            DO CASE
               CASE (aSeq[i][2] == "$" .AND. !EMPTY(aQuery[nField][4])) .OR. ;// confronto DATI contenuti in campo
                    (aSeq[i][2] == "C" .AND.  EMPTY(aQuery[nField][4]))

                    IF cType#"C"
                       cLocalExp := "UPPER(ALLTRIM(dfAny2Str("+cFie+"))) $ UPPER(dfAny2Str("+cFieNam+"))"
                    ELSE
                       cLocalExp := "UPPER(ALLTRIM("+cFie+")) $ UPPER("+cFieNam+")"
                    ENDIF


               CASE (aSeq[i][2] == "$" .AND.  EMPTY(aQuery[nField][4])) .OR. ; // campo contenuto in DATI
                    (aSeq[i][2] == "C" .AND. !EMPTY(aQuery[nField][4]))

                    IF cType#"C"
                       cLocalExp := "UPPER(ALLTRIM(dfAny2Str("+cFieNam+"))) $ UPPER(dfAny2Str("+cFie+"))"
                    ELSE
                       cLocalExp := "UPPER(ALLTRIM("+cFieNam+")) $ UPPER("+cFie+")"
                    ENDIF

               OTHERWISE              // tutti gli altri casi
                    cLocalExp := cFieNam+cFieCon+cFie
                    IF EMPTY(aQuery[nField][4]) // se l'alias e' vuoto
                       cLocalExp := cFie+cFieCon+cFieNam
                    ENDIF

            ENDCASE
            IF LEN(aQuery[nField])>7
               IF !EMPTY(aQuery[nField][8])
                  cLocalExp := "(" +aQuery[nField][8] +" .AND. " +cLocalExp +")"
               ENDIF
            ENDIF

            cQryExp += cLocalExp
            cQryDes += cDes

       CASE aSeq[i][1] = QRY_LINK      // legame con elementi successivi della sequenza
            cQryExp += aSeq[i][2]

            IF i<nSeqLen .AND. aSeq[i+1][1]#QRY_EXP
               lEmptyAft := .T.
               FOR j = i TO nSeqLen
                   IF aSeq[j][1] = QRY_FIELD
                      nField := aSeq[j][2]
                      IF !empty(aQuery[nField][3]) // il campo non e' vuoto
                         lEmptyAft := .F.
                      ENDIF
                      * exit
                   ENDIF
               NEXT

               DO CASE
                  CASE lEmptyAft

                  CASE lEmptyBef

                  CASE aSeq[i][2] = ".AND."
                       cQryDes += dfStdMsg(MSG_DFQRY12)

                  CASE aSeq[i][2] = ".OR."
                       cQryDes += dfStdMsg(MSG_DFQRY13)

                  OTHERWISE
                       cQryDes += " <-?-> "

               ENDCASE
            ENDIF

       CASE aSeq[i][1] = QRY_EXP       // Espressione aggiunta
            cQryExp += aSeq[i][2]

    ENDCASE
NEXT

// Elimino le inconsistenze
cQryExp := ALLTRIM(cQryExp)
lFilter := .T.
WHILE lFilter
   DO CASE
      // ---------------------------------------------------------------------
      // Ottimizzazione espressione di filtro
      // ---------------------------------------------------------------------
      CASE "(.T..AND..T.)" $ cQryExp
           cQryExp := ALLTRIM(STRTRAN( cQryExp, "(.T..AND..T.)", ".T."))

      CASE "(.T.)"         $ cQryExp
           cQryExp := ALLTRIM(STRTRAN( cQryExp, "(.T.)"        , ".T."))

      CASE ".AND..T."      $ cQryExp
           cQryExp := ALLTRIM(STRTRAN( cQryExp, ".AND..T."     , ""   ))

      CASE ".OR..T."       $ cQryExp
           cQryExp := ALLTRIM(STRTRAN( cQryExp, ".OR..T."      , ""   ))

      CASE ".T..AND."      $ cQryExp
           cQryExp := ALLTRIM(STRTRAN( cQryExp, ".T..AND."     , ""   ))

      CASE ".T..OR."       $ cQryExp
           cQryExp := ALLTRIM(STRTRAN( cQryExp, ".T..OR."      , ""   ))

      CASE ".AND.()"       $ cQryExp
           cQryExp := ALLTRIM(STRTRAN( cQryExp, ".AND.()"      , ""   ))

      CASE ".OR.()"        $ cQryExp
           cQryExp := ALLTRIM(STRTRAN( cQryExp, ".OR.()"       , ""   ))

      CASE "(()"           $ cQryExp
           cQryExp := ALLTRIM(STRTRAN( cQryExp, "(()"          , "("  ))

      CASE "()()"          $ cQryExp
           cQryExp := ALLTRIM(STRTRAN( cQryExp, "()()"         , "()" ))

      CASE cQryExp == "()"
           cQryExp := ""

      CASE RIGHT(cQryExp,5)==".AND." // NON capitano mai sono solo
           cQryExp := LEFT( cQryExp, LEN(cQryExp)-5 ) // ERRORI a monte

      CASE RIGHT(cQryExp,4)==".OR."  // NON capitano mai sono solo
           cQryExp := LEFT( cQryExp, LEN(cQryExp)-4 ) // ERRORI a monte

      // ---------------------------------------------------------------------
      // ottimizzazione filtro letterale
      // ---------------------------------------------------------------------
      CASE "()"            $ cQryDes
           cQryDes := ALLTRIM(STRTRAN( cQryDes, "()"           , ""   ))
      // ---------------------------------------------------------------------

      OTHERWISE
           IF EMPTY(cQryExp)         // Assegno un DEFAULT
              cQryExp:=".T."
           ENDIF
           lFilter := .F.
   ENDCASE
ENDDO

IF nError==0
   c2Ret := cQryDes
   IF nMode==QUERY_EXP
      c2Ret:=cQryExp
   ENDIF
ENDIF

RETURN c2Ret

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION ChkStr(cStr, cDelim)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF cDelim = "[" .and. !( "[" $ cStr .or. "]" $ cStr)
   RETURN cStr
ELSE
   IF !cDelim $ cStr
      RETURN cStr
   ENDIF
ENDIF

DO CASE
   CASE cDelim = "'"
        cStr := strtran(cStr, cDelim, "'+[']+'")

   CASE cDelim = '"'
        cStr := strtran(cStr, cDelim, '"+["]+"')

   CASE cDelim = '['
        cStr := strtran(cStr, cDelim, ']+"["+[') // Probabilmente bisogna
        cStr := strtran(cStr, cDelim, ']+"]"+[') // controllare questo GIRO !!

ENDCASE
RETURN cStr
