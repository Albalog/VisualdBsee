#include "Appevent.ch"
#include "Common.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "Font.ch"
#include "dfStd.ch"
#include "dll.ch"

//Maudp 12/06/2012 Funzione per la gestione della codifica di comunicazione BASE64 (nel mio caso per le API)

#define CRYPT_STRING_BASE64 0x00000001

static dll_tobase64
static dll_frombase64

//Inizializzazione delle funzioni di windows
FUNCTION dfBase64Init()

   BEGIN SEQUENCE 
      IF EMPTY(dll_tobase64)
         dll_tobase64   := dllpreparecall("crypt32.dll", DLL_CDECL, "CryptBinaryToStringA")
      ENDIF

      IF EMPTY(dll_frombase64)
         dll_frombase64 := dllpreparecall("crypt32.dll", DLL_CDECL, "CryptStringToBinaryA")
      ENDIF
   END SEQUENCE

RETURN (!EMPTY(DLL_TOBASE64) .AND. !EMPTY(DLL_FROMBASE64))


//CODIFICA
FUNCTION dfToBase64(cStr)
   LOCAL n
   LOCAL nLen:=0
   LOCAL nRet
   LOCAL cBuff

   n := LEN(cStr)

// creo un buffer abbastanza largo (base64 incrementa di 1/3, creo un buffer doppio)
   nLen  := n*2
   cBuff := SPACE(nLen)

   nRet  := dllexecutecall(dll_tobase64, @cStr, n, CRYPT_STRING_BASE64, @cBuff, @nLen )
   IF EMPTY(nRet)
      cBuff := cStr
      nLen  := LEN(cStr)
   ENDIF

RETURN LEFT(cBuff, nLen)

//DECODIFICA
FUNCTION dfFromBase64(cStr)
   LOCAL n
   LOCAL nLen:=0
   LOCAL nRet
   LOCAL cBuff
   LOCAL nSkip := 0

   n := LEN(cStr)

   nLen  := n
   cBuff := SPACE(nLen)

   nRet := dllexecutecall(dll_frombase64, @cStr, n, CRYPT_STRING_BASE64, @cBuff, @nLen,@nSkip,0 )

   IF EMPTY(nRet)
      cBuff := cStr
      nLen  := LEN(cStr)
   ENDIF

RETURN LEFT(cBuff,nLen)
