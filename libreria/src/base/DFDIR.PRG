//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfDir( cDir, cAtt )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL aDir := DIRECTORY( cDir, cAtt )
LOCAL a2Ret := { {}, {}, {}, {}, {} }

AEVAL( aDir, {|aSub| AADD(a2Ret[1],aSub[1]) ,;
                     AADD(a2Ret[2],aSub[2]) ,;
                     AADD(a2Ret[3],aSub[3]) ,;
                     AADD(a2Ret[4],aSub[4]) ,;
                     AADD(a2Ret[5],aSub[5]) })

RETURN a2Ret
