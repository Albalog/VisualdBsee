/******************************************************************************
Project     : dBsee for Xbase++
Description : Utilities Function
Programmer  : Simone Degl'Innocenti
******************************************************************************/

// Ritorna la stringa togliendo il chr(0)
// serve per leggere valori stringa di 
// ritorno da funzioni C
// modo di uso
//   dfGetCString(@cStr)             oppure
//   cStr := dfGetCString(cStr)      oppure
//   cStr := dfGetCString(cStr, @n)

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfGetCString(cStr, nInd)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   nInd := AT( CHR(0), cStr)
   IF nInd > 0
      cStr := LEFT(cStr, nInd-1)
   ENDIF
RETURN cStr

