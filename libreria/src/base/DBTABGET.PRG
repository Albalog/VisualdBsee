//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni per tabelle
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfMsg.ch"
#include "dfTab.ch"
#include "dfStd.ch"
#include "dfSet.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dBTabGet( cTabID  ,; // id tabella
                   cTabChk ,; // Codice da ricercare
                   cFieRet  ) // Campo di ritorno
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aFie := {}

LOCAL cRet := "", nFie := 0, lOpen := .F.
LOCAL aStr := {}

IF !DFISSELECT( "dbdd" ) .OR. !DFISSELECT( "dbTabd" )
   lOpen := .T.
   dfPushArea()                   // salvo la posizione del file in ingresso
   IF !dbCfgOpen( "dbdd" )        // se non apro il dizionario
      dbMsgErr( dfStdMsg(MSG_TABGET03) )
      dfPopArea()
      RETURN ""
   ENDIF

   IF !dbCfgOpen( "dbtabd" )      // se non apro file tabellari
      dbMsgErr( dfStdMsg(MSG_TABGET04) )
      dfPopArea()
      RETURN ""
   ENDIF
ENDIF

cTabID  := UPPER(PADR(cTabID, 8))   // Sistemo i parametri
cFieRet := UPPER(PADR(cFieRet,10))
///////////////////////////////////////////////////////////////////////
// Fare l'espressione secca   cTabChk := UPPER( dfAny2Str(cTabChk) ) //
// non funziona su AS400                                             //
///////////////////////////////////////////////////////////////////////
DO CASE
   CASE VALTYPE(cTabChk)=="C"
        cTabChk := UPPER( cTabChk )
   OTHERWISE
        WHILE dbdd->(DBSEEK( "FIE"+ cTabID )) .AND. !dbdd->(EOF())
           IF dbdd->TabFieSod==-1
              EXIT
           ENDIF
           dbdd->(DBSKIP())
        ENDDO
        DO CASE
           CASE VALTYPE(cTabChk)=="N"
                cTabChk := STR( cTabChk, dbdd->field_len, dbdd->field_dec )
           CASE VALTYPE(cTabChk)=="D"
                cTabChk := DTOS(cTabChk)
           CASE VALTYPE(cTabChk)=="L"
                cTabChk := IF(cTabChk,"T","F")
        ENDCASE
ENDCASE

IF (nFie := ASCAN( aFie, {|aInd|aInd[1]= (cTabID+cFieRet)})) == 0  // cerco
   dbdd->(ORDSETFOCUS(2))                                          // il campo
   dbdd->(DBSEEK( "FIE"+ cTabID+ cFieRet ))
   dbdd->(ORDSETFOCUS(1))
   IF !(dbdd->(eof()))
      AADD(aFie,{ (cTabID+cFieRet) ,;
                  dbdd->TabFieSod  ,;
                  dbdd->field_len  ,;
                  dbdd->field_type })
      nFie := LEN(aFie)
   ENDIF
ENDIF

IF nFie = 0
   dbMsgErr( dfStdMsg(MSG_TABGET01) +;
             cTabID                 +;
             "->"                   +;
             cFieRet                +;
             dfStdMsg(MSG_TABGET02) )
ELSE
   dbtabd->(DBSEEK( cTabID+ TAB_PRK+ cTabChk )) // posiziono il record dati
   //vecchio metodo
   //cRet := dfTab2Str( aFie[nFie][2], aFie[nFie][3], aFie[nFie][4] )
   aStr  := dfStr2arr(dbTabd->TabData,TAB_SEPARATORE )
   IF LEN(aStr) > 1
      cRet := aStr[nFie]
      cRet := dbTabConv( cRet, aFie[nFie][4] )
   ELSE 
      cRet := dfTab2Str( aFie[nFie][2], aFie[nFie][3], aFie[nFie][4] )
   ENDIF 

ENDIF

IF lOpen
   dfPopArea()                        // ripristino la situazione
ENDIF

IF ! EMPTY( dfSet( AI_MAXMEM ) )
   ASIZE(aFie, 0)
   aFie := {}
ENDIF

RETURN cRet
