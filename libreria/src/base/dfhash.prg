/*********************************
* CVS File info
*  $Revision: 1.1.2.4 $
*  $Date: 2012/09/11 12:49:59 $
*  $Author: luca $
*  $Name:  $
*  $Id: dfhash.prg,v 1.1.2.4 2012/09/11 12:49:59 luca Exp $
***********************************/ 

#include "common.ch"
#include "dfStd.ch"
//#include "VdbI18N.ch"

#ifdef _TEST_

   func main(c)
      local x := memoread(IF(EMPTY(c), "FUNC.TXT", c))
      local n := mlcount(x)
      local i
      local cline, nmin, nmax, nmed
      local aht:=dfHTNew( 257 )

      set alternate to log
      set alternate on

      for i := 1 to n
         cline := trim(memoline(x, , i))
         ? cline, dfHash(cLine, 257) //hashdjb2(cline)
         dfHTAdd(aHT, cLine, cLine)
      next
      ?
      ? "aHT--------"
      nMin := 999999999999
      nMax := -1
      nMed := 0


      FOR i := 1 TO aHT[3]
         ? LEN(aHT[1][i])
         nMed += LEN(aHT[1][i])
         nMin := MIN(nMin, LEN(aHT[1][i]))
         nMax := MAX(nMax, LEN(aHT[1][i]))
      NEXT
      ? "num", aHT[3], "min", nMin, "max", nMax, "med", nMed/aHT[3]
   return 0

#endif

/* 
   // Esempio
   aHT := dfHTNew(257, {|a|a[1]})

   aVal := {"A2012", 3}
   dfHTAdd(aHT, aVal)

   aVal := {"A2212", 5}
   dfHTAdd(aHT, aVal)

   aVal := {"A1234", 2}
   dfHTAdd(aHT, aVal)

   ? dfHTFind("A2212") -> {"A2212", 5}
   ? dfHTFind("abcde") -> NIL
*/

// Nuova tabella di hash di lunghezza n
// b pu• essere un codeblock per ricavare 
// la chiave dal valore 
FUNCTION dfHTNew(n, b)
   LOCAL aRet 
   LOCAL i
   DEFAULT n TO 127
   aRet := ARRAY(n)
   FOR i := 1 TO n
     aRet[i] := ARRAY(0)
   NEXT
RETURN {aRet, b, n}

// aggiunge un valore/chiave
FUNCTION dfHTAdd(aHT, xVal, cKey)
   LOCAL nHash
   IF cKey == NIL .AND. aHT[2] != NIL 
      cKey := EVAL(aHT[2], xVal, aHT)
   ENDIF
   nHash := dfHash(cKey, aHT[3])+1
   AADD(aHT[1][nHash], {cKey, xVal})
RETURN NIL


// simone 19/05/2005 
// mantis 0000735: Non Š possibile personalizzare la lingua degli oggetti inserit o delle nuove entit… create in un progetto.
// supporto per traduzioni aggiuntive utente
// aggiunge/modifica un valore/chiave
FUNCTION dfHTMod(aHT, xVal, cKey, lCanAdd)
   LOCAL nHash
   LOCAL nPos

   DEFAULT lCanAdd TO .T.

   IF cKey == NIL .AND. aHT[2] != NIL 
      cKey := EVAL(aHT[2], xVal, aHT)
   ENDIF
   nHash := dfHash(cKey, aHT[3])+1
   nPos := ASCAN(aHT[1][nHash], {|x| x[1]==cKey})
   IF nPos == 0 .AND. lCanAdd
      AADD(aHT[1][nHash], {cKey, xVal})
   ELSE
      aHT[1][nHash][nPos][2] := xVal
   ENDIF
RETURN NIL

// trova una chiave
FUNCTION dfHTFind(aHT, cKey, lFound)
   LOCAL nHash, nPos
   IF EMPTY(aHT) .OR. LEN(aHT)<3
      lFound := .F.
      RETURN NIL
   ENDIF 
   nHash := dfHash(cKey, aHT[3])+1
   nPos := ASCAN(aHT[1][nHash], {|x| x[1]==cKey})
   IF nPos == 0
      lFound := .F.
      RETURN NIL
   ENDIF
   lFound := .T.
RETURN aHT[1][nHash][nPos][2]

// esegue un codeblock su tutti i valori della hash table
// all codeblock passa array {chiave, valore}
FUNCTION dfHTEval(aHT, bEval)
   LOCAL i

   FOR i := 1 TO LEN(aHT[1])
      AEVAL(aHT[1][i], bEval )
   NEXT
RETURN .T.

// copia i valori di una Hash Table in un array
FUNCTION dfHTToArr(aHT)
   LOCAL aRet := {}
   dfHTEval(aHT, {|x| AADD(aRet, x)})
RETURN aRet

// ritorna elenco chiavi
FUNCTION dfHTGetKeys(aHT)
   LOCAL aRet := {}
   dfHTEval(aHT, {|x| AADD(aRet, x[1])})
RETURN aRet


// ritorna statistica della hash table
// by reference la torna in formato stringa in cRet
FUNCTION dfHTStats(aHT, cRet, cSep)
   LOCAL aRet := {}
   LOCAL n, x
   
   DEFAULT cSep TO CRLF

   cRet := ""

   FOR n := 1 TO LEN(aHT[1])
      x := LEN(aHT[1][n])
      AADD(aRet, x)
      cRet += cSep+STR(n, 5)+" ("+STR(x, 5)+"): "+REPLICATE("*", x)
   NEXT

   // salto separatore iniziale
   cRet := SUBSTR(cRet, LEN(cSep)+1)

RETURN aRet


// ritorna il codice hash di una stringa
// oppure se passato nMax torna l'indice 
// della stringa in una tabella 
// 
// nMax Š meglio se Š numero primo!!!
// per un elenco dei numeri primi
// http://www.utm.edu/research/primes
FUNCTION dfHash(cStr, nMax)
   LOCAL nHash := INT(BIN2U( _dfHash(cStr, 2) ))
   IF EMPTY(nMax)
      RETURN nHash
   ENDIF

//   IF nHash <0 
//      nHash+= 0x10000000
//   ENDIF

RETURN INT(nHash % nMax)

/*
FUNCTION hashdjb2(cStr)
  LOCAL nHash := 5381
  LOCAL n     := 0
  LOCAL nMax  := LEN(cStr)

  DO WHILE ++n <= nMax
     nHash := nHash*33+ASC(cStr[n])
  ENDDO
RETURN nHash
*/
/*
    unsigned long
    hash(unsigned char *str)
    {
        unsigned long hash = 5381;
        int c;

        while (c = *str++)
            hash = ((hash << 5) + hash) + c; // hash * 33 + c 

        return hash;
    }

*/