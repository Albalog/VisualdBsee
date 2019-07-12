/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "Common.ch"
#include "dfStd.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfRddFile( cFile, cRdd )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet

DEFAULT cRdd TO RDDSETDEFAULT()

DO CASE
   CASE dfFTDriver( cRdd ) ; lRet := dfFTFile( cFile )
   CASE dfASDriver( cRdd ) ; lRet := dfASFile( cFile )
   //OTHERWISE               ; lRet :=     FILE( cFile )
   //Modifica Luca per path relativi
   OTHERWISE               


#ifdef __IGNORE_THIS__
     // ignorato perchŠ si usa la SLEEP() nel S2SetLogon di EXTRA

     // Simone 21/09/09
     // controlla esistenza file con funzione di ADS
     // per vedere se si risolve il problema di TADDEI (LaTecnocopie)
     // su PC Vista con ADS su Windows Server2008
     // If the AXS is loaded change the RDD to the default RDD of the AXS
     IF VALTYPE(cRdd) == "O"
        IF dfADSFile(cFile, cRDD)
           lRet := .T.
        ENDIF
        // Š gi… una DACSession, non faccio niente
     //ELSEIF dfDACConnADSDDSession(@cFile, @cRdd) disattivato perche vengono aperti anche gli indici e potrebbe dare problemi!
        // esiste una DACSession, non faccio niente
     ELSEIF dfAXSLoaded( cFile, cRdd ) .AND. dfADSFile(cFile)
        lRet := .T.
     ENDIF
     IF lRet == NIL // se non trovo con dfADSFile uso comunque la FILE()
        lRet := FILE( cFile ) .OR. FEXISTS(cFile)
        IF !lRet 
           cFile := dfFNameBuild( cFile )
           lRet  := FILE( cFile ) .OR. FEXISTS(cFile)
           IF ! lRet
              lRet := ! EMPTY(DIRECTORY(cFile))
           ENDIF
        ENDIF
     ENDIF
#endif

     lRet :=     FILE( cFile )
     IF !lRet 
        cFile :=  dfFNameBuild(cFile )
        lRet :=     FILE( cFile )
     ENDIF
ENDCASE

RETURN lRet
