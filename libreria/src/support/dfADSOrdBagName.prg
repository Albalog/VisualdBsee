#include "common.ch"
#include "dll.ch"
#include "dfAdsDbe.ch"

/* Success return code */
#define AE_SUCCESS                      0

/* for retrieving file names of tables */
#define ADS_BASENAME             1
#define ADS_BASENAMEANDEXT       2
#define ADS_FULLPATHNAME         3
#define ADS_DATADICTIONARY_NAME  4
#define ADS_TABLE_OPEN_NAME      5

#define MAX_STR_LEN            512

// Simone 22/10/10 XL 2422
// FIX per funzione ORDBAGNAME di alaska che 
// non torna il valore corretto quando
// - si usa ADS 8 o inferiore oppure si usa ADS 9 o superiore e 
//   il flag apertura esclusiva tabella Š disattivo 
//   (per compatibilit… con ADS8 o inferiore)
// - si usa dizionario dati
// - la tabella ha un indice copiato tramite la dfIndexDup()

FUNCTION dfADSOrdBagName(n, nInfo)
   LOCAL nIH
   LOCAL nBuff := MAX_STR_LEN + 1
   LOCAL cBuff := SPACE(nBuff)
   LOCAL nCall

   DEFAULT n TO INDEXORD()
   DEFAULT nInfo TO DMLB_FILENAME

   nIH := dfADSGetIndexHandle(n)
   IF nIH <= 0 // non trovato
      RETURN ""
   ENDIF

   nCall := DLLCALL("ACE32.DLL", DLL_STDCALL, "AdsGetIndexFilename", nIH, ADS_FULLPATHNAME, @cBuff, @nBuff)
   IF nCall != AE_SUCCESS
      RETURN ""
   ENDIF

   cBuff := LEFT(cBuff, nBuff)
   IF nInfo == DMLB_FILENAME
      cBuff := dfFNameSplit(cBuff, 4+8) // solo nome file + estensione
   ENDIF
RETURN cBuff

// torna l'index handle di un indice (indicato come numero o nome tag)
FUNCTION dfADSGetIndexHandle(xIdx)
   LOCAL nTH   := 0
   LOCAL nIH   := -1
   LOCAL nBuff := 50
   LOCAL nLongLen := LEN(U2BIN(0))
   LOCAL cBuff := SPACE(nBuff*nLongLen)
   LOCAL nBuff2 
   LOCAL cBuff2 
   LOCAL nIdxHandle
   LOCAL nCall
   LOCAL nIdx

   IF VALTYPE(xIdx)=="N"
      IF xIdx <= 0
         RETURN nIH
      ENDIF
   ELSEIF VALTYPE(xIdx) $"CM"
      IF EMPTY(xIdx) // stringa vuota
         RETURN nIH
      ENDIF
   ELSE
      RETURN nIH
   ENDIF

   nTH := DbInfo(ADSDBO_TABLE_HANDLE)
   nCall := DLLCALL("ACE32.DLL", DLL_STDCALL, "AdsGetAllIndexes", nTH, @cBuff, @nBuff)
   IF nCall != AE_SUCCESS
      RETURN nIH
   ENDIF

   IF VALTYPE(xIdx) $ "CM"

      xIdx := UPPER(ALLTRIM(xIdx))

      // cerco l'indice con TAG = a quello passato
      FOR nIdx := 1 TO nBuff
         nIdxHandle := _Decode(cBuff, nIdx, nLongLen)

         IF nIdxHandle <= 0
            LOOP 
         ENDIF

         nBuff2 := MAX_STR_LEN+1
         cBuff2 := SPACE(nBuff2)
         nCall := DLLCALL("ACE32.DLL", DLL_STDCALL, "AdsGetIndexName", nIdxHandle, @cBuff2, @nBuff2)
         IF nCall != AE_SUCCESS
            LOOP
         ENDIF

         IF ! UPPER( LEFT(cBuff2, nBuff2) ) == xIdx
            LOOP
         ENDIF

         // trovato
         EXIT
      NEXT
   ELSE
      // numero indice
      nIdx := xIdx 
   ENDIF

   IF nIdx > nBuff
      RETURN nIH
   ENDIF

   // torno index handle
   nIH := _Decode(cBuff, nIdx, nLongLen)
RETURN nIH

STATIC FUNCTION _Decode(cBuff, nIdx, nLongLen)
   LOCAL nIH := -1

   nIdx--
   nIdx *= nLongLen
   cBuff := SUBSTR(cBuff, 1+nIdx, nLongLen)
   nIH:= BIN2U(cBuff)
RETURN nIH
