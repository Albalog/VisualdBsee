//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STRINGHE
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfRound( nNumber, nRound )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nDiv, nDifSup, nDifInf, nRet

//Maudp 05/07/2011 Fixing per problema su INT,ritornava un valore errato, esempio:
//la INT di questo valore -143.14/0.01 ritornava -14313 invece di -14314

//nDiv := INT(nNumber/nRound)
nDiv := INTFix(nNumber/nRound)

nDifInf := nNumber - nDiv * nRound
nDifSup := nRound  - nDifInf

nRet := nDiv * nRound

IF nDifSup<nDifInf
   nRet += nRound
ENDIF

RETURN nRet


//Maudp 05/07/2011 Fixing per problema su INT,ritornava un valore errato, esempio:
//la INT di questo valore -143.14/0.01 ritornava -14313 invece di 14314
FUNCTION INTFix(nVal)
   nVal := VAL(STR( nVal, 30, 0 ) )
RETURN nVal

                   