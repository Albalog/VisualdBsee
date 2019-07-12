/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

// 14/06/2002 Simone
//    Aggiunto parametro nPKType per gestione incremento anche
//    se la chiave primaria NON Š di tipo di incremento automatico
//    Per effettuare incremento, nPKType deve essere 1
#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif


#include "Common.ch"
#include "dfWin.ch"
#include "dfMsg.ch"

//
// TIPOLOGIA CHIAVE
// -------------------
// 0 = Nessun controllo
// 1 = Automatico progr.
// 2 = Digitato
// 3 = Automatico su file contatore
//
// aKeyStru[ 1] := "CODART"                 C  Nome        campo chiave
// aKeyStru[ 2] := 0                        N  Tipo   0-1-2-3    chiave
// aKeyStru[ 3] := {|| upper(codart) }      B  CodeBlock per valore chiave
// aKeyStru[ 4] := "N"                      C  Tipo        dato
// aKeyStru[ 5] := 6                        N  Lunghezza   campo chiave
// aKeyStru[ 6] := "upper(codart)"          C  espressione chiave
//

*******************************************************************************
FUNCTION dfPkNew(            ;  // CREA IL PROGRESSIVO DELLA CHIAVE PRIMARIA
                 iKeyVar    ,;  // Indirizzo variabile della chiave primaria
                 nFileOrde  ,;  // Numero indice
                 cKeyName   ,;  // Nome  campo chiave
                 aKeyStru   ,;  // Struttura campi chiave
                 nInc       ,;  // Incremento
                 nPKType     )  // Tipo chiave univoca 1/3
*******************************************************************************
LOCAL nCnt    := 0             ,;
      nAlen   := len(aKeyStru) ,;
      nKey    := 0             ,; // Numero struttura chiave corrente
      vPrkVal := ""            ,; // Epressione CHIAVE per la seek
      cPrkExp := ""            ,; // Epressione per confronto CHIAVE
      cPlus   := ""            ,; //
      cAlias  := UPPER(PADR(ALIAS(),8)) ,;
      bKeyVar                  ,; // CodeBlock della chiave primaria
      cVar    := ""
DEFAULT nInc    TO 1

IF VALTYPE(iKeyVar)=="B"
   bKeyVar := iKeyVar
ELSE
   bKeyVar := {|x|IF(x==NIL,iKeyVar,iKeyVar:=x)}
ENDIF

nKey := VkScan( aKeyStru ,cKeyName )

IF nKey == 0                      // Se non trovo la struttura della chiave
   RETURN .F.
ENDIF

DEFAULT nPKType TO aKeyStru[nKey,2]

IF nPKType == 0 .OR. ;    // Se il tipo 0 = nessun controllo o
   nPKType == 2           //            2 = digitato non ripetuto
   RETURN .F.                     // Non deve fare nulla STOP !!
END                               // Elabora solo tipo 1 - 3 con struttura

dfPushArea()                      // Salva Nøindice e record correnti
SET ORDER TO nFileOrde            // Seleziona nuovo indice

dbdd->(ORDSETFOCUS_XPP(1))            // Upper(RecTyp+file_name)+str(NdxIncN,3)
dbdd->(dbSeek( "NDX" +cAlias +STR(nFileOrde,3) ) )

                                  // VALORIZZA LA CHIAVE
FOR nCnt:=2 TO nAlen

    IF UPPER(aKeyStru[nCnt,1])==UPPER(cKeyName)
       EXIT
    ELSE
       vPrkVal += EVAL(aKeyStru[nCnt,3])     // Valore CHIAVE
       cPrkExp += cPlus +aKeyStru[nCnt,6]    // Espressione confronto
    ENDIF
    cPlus := "+"

NEXT
IF aKeyStru[1,3] != NIL                       // Somma espressione globale
   //
   // aKeyStru[1,3] --> {|x|UPPER(x)}
   // aKeyStru[1,6] --> "UPPER(%)"
   //
   vPrkVal := EVAL(aKeyStru[1,3],vPrkVal)     // Valore CHIAVE
   cPrkExp := dfPkExp( aKeyStru[1,6], cPrkExp )
ENDIF
                                  // ELABORA IL PROGRESSIVO
DO CASE
   CASE nPKType==1       // Progressivo automatico

        IF !EMPTY( vPrkVal )      // CHIAVE COMPOSTA SOLO CARATTERE

           // DBSEEK( vPrkVal +REPLICATE("±" ,aKeyStru[nKey,5] ), .T. ) // Seek Soft
           //
           // Dava dei problemi con Win400. Questa modifica dovrebbe
           // dare lo stesso risultato, ma almeno risolvere alcune
           // casistiche con win400
           // Il problema di data width error dovrebbe rimanere comunque se
           // il primo campo e' numerico
           //
           cVar := dfChrInc(vPrkVal)
           DBSEEK( cVar, .T. ) // Seek Soft

           IF dbdd->File_Typ!="D" // Indice descend
              DBSKIP( -1 )

              // SD 23/11/2010 fix per problema se nella tabella
              // esistono record tipo
              // STIPEND 001
              // STIPEND 002
              // STIPEND.001
              // XXXX
              // e voglio inserire un nuovo record in "STIPEND "
              // la dfChrInc() torna "STIPEND0" e la seek va su XXXX
              // ma la dfChrInc() dovrebbe tornare "STIPEND!" per
              // far funzionare tutto.
              // come workaround cerco il record con stessa chiave "STIPEND "
              // esco se non esiste
              DO WHILE .T.
                 IF EOF() .OR. BOF()
                    EXIT
                 ENDIF
                 IF &cPrkExp <= vPrkVal
                    EXIT
                 ENDIF
                 DBSKIP(-1)
              ENDDO
           ENDIF

           IF vPrkVal == &cPrkExp

              EVAL( bKeyVar, VkVal(aKeyStru[nKey,1] ,; // Nome
                                   aKeyStru[nKey,4] ,; // Tipo
                                   aKeyStru[nKey,5] ,; // Len
                                   nInc             )) // Incremento

           ELSE

              IF aKeyStru[nKey,4]=="N"
                 EVAL( bKeyVar, VAL(PADL( nInc, aKeyStru[nKey,5], "0" )) )
              ELSE
                 EVAL( bKeyVar,     PADL( nInc, aKeyStru[nKey,5], "0" )  )
              ENDIF

           ENDIF

        ELSE                      // CHIAVE SINGOLA
           IF dbdd->File_Typ=="D"    // Serve per i progressivi su chiavi
              DBGOTOP()              // di tipo descend
           ELSE
              DBGOBOTTOM()
           ENDIF
           EVAL( bKeyVar, VkVal(aKeyStru[nKey,1] ,; // Nome
                                aKeyStru[nKey,4] ,; // Tipo
                                aKeyStru[nKey,5] ,; // Len
                                nInc             )) // Incremento

        ENDIF

   CASE nPKType==3       // Progressivo automatico su file contatori


ENDCASE

dfPopArea()                       // Ripristina l'area precedente

RETU .T.

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION VkScan( aKeyStru ,cKeyName ) // Cerco la CHIAVE
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN ASCAN( aKeyStru, {|aSub| UPPER(aSub[1])==UPPER(cKeyName) }, 2 )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION VkVal( cKeyName ,cKeyTyp , nKeyLen, nInc ) // Incrementa chiave
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL vRet
IF cKeyTyp=="N"
   vRet := VAL(PadL(FieldGet(FieldPos(cKeyName))+nInc ,;    // Nome campo
                                 nKeyLen  ,"0"  ) )      // Len
ELSE
   vRet := PadL(Val(FieldGet(FieldPos(cKeyName)))+nInc ,; // Nome campo
                                 nKeyLen  ,"0"       ) // Len
END
RETURN vRet

*******************************************************************************
FUNCTION tbPkExp(      ; // Ritorna l'espressione della chiave primaria scandendo
                  oTbr ) // l'array con la struttura
*******************************************************************************
LOCAL aKeyStru := oTbr:W_PRIMARYKEY
LOCAL nCnt ,nAlen := LEN(aKeyStru) ,uExp := ""

IF nAlen==2
   uExp := EVAL( aKeyStru[2,3] )
ELSE
   FOR nCnt:=2 TO nAlen
       uExp += EVAL( aKeyStru[nCnt,3] )
   NEXT
ENDIF

IF aKeyStru[1,3] != NIL                    // Somma espressione globale
   uExp := EVAL(aKeyStru[1,3],uExp)
END
RETU  uExp


*******************************************************************************
FUNCTION ddPkChk(              ; // DATA DRIVEN KEY CHECK
                 nNdxOrde     ,; // Id-seek e numero ordine indice
                 cKeyExpr     ,; // Espressione della chiave da validare
                 cMessage     ,; // Messaggio  ( facoltativo )
                 cState        ) // Stato form ( facoltativo )
*******************************************************************************
LOCAL nOldOrd := 0     ,;
      nOldRec := 0     ,;
      cFileId := ""    ,;
      cKeyTyp := ""    ,; // Tipo chiave Primaria - Univoca
      cKeyDes := ""    ,; // Descrizione tipo chiave
      lRet    := .T.

DEFAULT cState TO DE_STATE_MOD

cFileId := UPPER(PADR(ALIAS(),8))
nOldOrd:=INDEXORD(); nOldRec:=Recno()  // Salva Nøindice e record correnti

dbdd->(ORDSETFOCUS_XPP(1))                 // Upper(RecTyp+file_name)+str(NdxIncN,3)

dbdd->(dbSeek( "NDX"+cFileId+str(nNdxOrde,3) ) )
cKeyTyp := upper(dbdd->FILE_MODE)      // Tipo chiave Primaria o Univoca
IF !cKeyTyp $ "PU"                     // Se non e' Primaria o Univoca (eof()="")
   RETURN lRet                         // Nulla da validare tutto OK !! stop
END
cKeyDes := iif(cKeyTyp=="P" ,dfStdMsg(MSG_DFPK01) ,dfStdMsg(MSG_DFPK02) )

SET ORDER TO nNdxOrde                  // Imposta l'indice
dbSeek( cKeyExpr )                     // Esegue la ricerca

DO CASE
   CASE EMPTY( cKeyExpr ); lRet:=.F.   // la chiave e' vuota STOP!!
   CASE EOF()            ; lRet:=.T.   // OK
   CASE RECNO()==nOldRec .AND. cKeyTyp=="U"; lRet:= (cState==DE_STATE_MOD) // Modifica chiave UNIQUE
   //CASE RECNO()==nOldRec .AND. cKeyTyp=="U"; lRet:=.T. // Modifica chiave UNIQUE
   OTHERWISE
        lRet:=!FOUND()
ENDCASE

IF !lRet
   IF EMPTY(cMessage) // Se non viene passato un messaggio lo sviluppa
      IF EMPTY(cKeyExpr)
         cMessage := dfStdMSg(MSG_DFPK03) + UPPER(cKeyDes) + dfStdMSg(MSG_DFPK05)
         cMessage += dfStdMSg(MSG_DFPK06)  //Riga con< //>
         cMessage += dfStdMSg(MSG_DFPK07)
      ELSE 
         cMessage := dfStdMSg(MSG_DFPK03) + UPPER(cKeyDes) + dfStdMSg(MSG_DFPK04) 
      cMessage += dfStdMSg(MSG_DFPK06)
         cMessage += "("
      dbdd->(dbSeek( "KEY"+cFileId+str(nNdxOrde,3) ) )
      WHILE( UPPER(dbdd->RecTyp+dbdd->File_Name+str( dbdd->NdxIncN,3)) == ;
                        "KEY"+cFileId+str(nNdxOrde,3) .AND. !dbdd->(EOF()) )

            cMessage += ALLTRIM(dbdd->field_des)+ " + "

         dbdd->(dbSkip(1))

      ENDDO
         cMessage := LEFT(cMessage, LEN(cMessage)-3)
         cMessage += ")"
         cMessage += " <=> "//dfStdMSg(MSG_DFPK06)
         cMessage += " ("+trans( cKeyExpr ,"@X" )+") //"
      cMessage += dfStdMSg(MSG_DFPK06)
      cMessage += dfStdMSg(MSG_DFPK07)
      ENDIF 

   END
   dBmsgErr( cMessage )
   lRet = .F.
ENDIF

SET ORDER TO nOldOrd
dbGoto( nOldRec )
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPkExp( cExp, cKey )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cPrkExp
IF "%N"$cExp
   cPrkExp := STRTRAN( cExp, "%N", cKey )
ELSE
   cPrkExp := STRTRAN( cExp, "%", cKey )
ENDIF
RETURN cPrkExp