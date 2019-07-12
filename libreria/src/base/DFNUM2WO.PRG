//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************
//
// Riadattamento di una funzione di Stephen Kurasch, Tom Rettig
// Riadattata Ferruccio Busca
// Riscritta per CA-CLIPPER da Baccan Matteo
//

#include "COMMON.CH"
#include "dfmsg.ch"

#define INT_ZERO     1
#define INT_MILLE    2
#define INT_MILIONE  3
#define INT_MILIARDO 4

// Esempi
// dfNum2Word(10.2 , 2, " virgola ", " centesimi") -> dieci virgola venti centesimi
// dfNum2Word(10.2 , 2, " virgola ") -> dieci virgola venti
// dfNum2Word(10.2 , 1, " virgola ") -> dieci virgola due
// dfNum2Word(10.02, 2, " virgola ", " centesimi") -> dieci virgola due centesimi
// dfNum2Word(10.02, 2, " virgola ") -> dieci virgola zerodue

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfNum2Word( nValue, nDec, cCommaSep, cUniMis )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL cRet := ""
   LOCAL nInt := 0, nD

   DEFAULT nDec      TO 0
   DEFAULT cCommaSep TO "/"
   DEFAULT cUniMis   TO ""

   IF nDec <= 0
      cRet := _Num2Word(nValue)
   ELSE
      nInt := INT(nValue)
      nD   := ROUND(nValue-nInt, nDec ) 

      DO WHILE nDec-- > 0
         nD *= 10
         IF EMPTY(cUniMis) .AND. INT(nD) == 0 .AND. nDec > 0
            cCommaSep += dfStdMsg( MSG_NUM2WORD32 )
         ENDIF
      ENDDO

      cRet := _Num2Word(nInt) + cCommaSep + _Num2Word(nD) + cUniMis
   ENDIF
RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION _Num2Word(nValue)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aUnita, aDecina, aDecine, aAttributi, aVarie, aCento
LOCAL cParole, cCifre, nGruppo, c3Cifre, cStringa, nCifra

IF aUnita == NIL
   aUnita := { dfStdMsg( MSG_NUM2WORD01 ) ,;
               dfStdMsg( MSG_NUM2WORD02 ) ,;
               dfStdMsg( MSG_NUM2WORD03 ) ,;
               dfStdMsg( MSG_NUM2WORD04 ) ,;
               dfStdMsg( MSG_NUM2WORD05 ) ,;
               dfStdMsg( MSG_NUM2WORD06 ) ,;
               dfStdMsg( MSG_NUM2WORD07 ) ,;
               dfStdMsg( MSG_NUM2WORD08 ) ,;
               dfStdMsg( MSG_NUM2WORD09 )  }

   aDecina := { dfStdMsg( MSG_NUM2WORD10 ) ,;
                dfStdMsg( MSG_NUM2WORD11 ) ,;
                dfStdMsg( MSG_NUM2WORD12 ) ,;
                dfStdMsg( MSG_NUM2WORD13 ) ,;
                dfStdMsg( MSG_NUM2WORD14 ) ,;
                dfStdMsg( MSG_NUM2WORD15 ) ,;
                dfStdMsg( MSG_NUM2WORD16 ) ,;
                dfStdMsg( MSG_NUM2WORD17 ) ,;
                dfStdMsg( MSG_NUM2WORD18 ) ,;
                dfStdMsg( MSG_NUM2WORD19 )  }

   aDecine := { dfStdMsg( MSG_NUM2WORD20 ) ,;
                dfStdMsg( MSG_NUM2WORD21 ) ,;
                dfStdMsg( MSG_NUM2WORD22 ) ,;
                dfStdMsg( MSG_NUM2WORD23 ) ,;
                dfStdMsg( MSG_NUM2WORD24 ) ,;
                dfStdMsg( MSG_NUM2WORD25 ) ,;
                dfStdMsg( MSG_NUM2WORD26 ) ,;
                dfStdMsg( MSG_NUM2WORD27 ) ,;
                dfStdMsg( MSG_NUM2WORD28 )  }

   aAttributi := { dfStdMsg( MSG_NUM2WORD29 ) ,;
                   dfStdMsg( MSG_NUM2WORD30 ) ,;
                   dfStdMsg( MSG_NUM2WORD31 )  }

   aVarie := { dfStdMsg( MSG_NUM2WORD32 ) ,;
               dfStdMsg( MSG_NUM2WORD33 ) ,;
               dfStdMsg( MSG_NUM2WORD34 ) ,;
               dfStdMsg( MSG_NUM2WORD35 )  }

   aCento := { dfStdMsg( MSG_NUM2WORD39 ) , ;   // here
               dfStdMsg( MSG_NUM2WORD40 ) , ;   // here
               dfStdMsg( MSG_NUM2WORD41 ) , ;   // here
               dfStdMsg( MSG_NUM2WORD42 ) , ;   // here
               dfStdMsg( MSG_NUM2WORD43 ) , ;   // here
               dfStdMsg( MSG_NUM2WORD44 ) , ;   // here
               dfStdMsg( MSG_NUM2WORD45 ) , ;   // here
               dfStdMsg( MSG_NUM2WORD46 ) , ;   // here
               dfStdMsg( MSG_NUM2WORD47 ) }     // here
ENDIF

DEFAULT nValue TO 0

nValue := ABS(nValue)

DO CASE
   CASE nValue==0; cParole := aVarie[INT_ZERO] // filtrazione casi particolari
   CASE nValue==1; cParole := aUnita[1]        // (valori 0 e 1)
   OTHERWISE // conversione generalizzata da numero a caratteri
        cCifre  := STR(nValue,12,0)
        cParole := ""

        // ciclo di analisi dei 4 gruppi di 3 cifre ciascuno, da destra verso
        // sinistra; il gruppo 1 Š quello dei miliardi
        nGruppo := 4
        WHILE nGruppo#0
           // estrazione delle tre cifre del gruppo
           c3Cifre  := SUBSTR(cCifre,(nGruppo-1)*3+1,3)
           cStringa := ""
           DO CASE
              CASE EMPTY(c3Cifre);EXIT // condizione di fine ciclo prematura

              // filtrazione del caso anomalo di valore del gruppo uguale a 1
              CASE VAL(c3Cifre)==1
                   DO CASE
                      CASE nGruppo==4; cStringa := aUnita[1]
                      CASE nGruppo==3; cStringa := aVarie[INT_MILLE]
                      CASE nGruppo==2; cStringa := aVarie[INT_MILIONE]
                      CASE nGruppo==1; cStringa := aVarie[INT_MILIARDO]
                   ENDCASE

              // conversione generalizzata del valore del gruppo diverso da 0
              CASE VAL(c3Cifre)>1

                   // analisi della prima cifra a sinistra (centinaia)
                   nCifra := VAL(LEFT(c3Cifre,1))
                   IF nCifra#0
                      // ... here
                      // ... se Brasil
                      if dfStdMsg( MSG_LANGUAGE ) == "BRASIL"
                         // ... verefica se ‚ cem
                         if c3Cifre == "100"
                            cStringa += dfStdMsg( MSG_NUM2WORD36 )
                         else
                            cStringa := aCento[nCifra]
                         endif
                      else
                         IF nCifra>1
                            cStringa := aUnita[nCifra]
                         ENDIF

                         cStringa += dfStdMsg( MSG_NUM2WORD36 )

                         // controllo dell'eccezione "centoottanta"
                         IF dfStdMsg( MSG_LANGUAGE ) == "ITALIANO"
                            IF SUBSTR(c3Cifre,2,1)="8"
                               cStringa := LEFT(cStringa,LEN(cStringa)-1)
                            ENDIF
                         ENDIF

                      ENDIF

                   ENDIF

                   // analisi della cifra centrale (decine)
                   nCifra := VAL(SUBSTR(c3Cifre,2,1))
                   IF nCifra==1
                      // caso della prima decina
                      nCifra   := VAL(SUBSTR(c3Cifre,3,1))
                      cStringa := cStringa +aDecina[nCifra+1]
                   ELSE
                      // caso della decine successive alla prima
                      IF nCifra>1
                         cStringa += aDecine[nCifra]
                         // controllo delle eccezioni del tipo "ventiuno" e
                         // "ventiotto"
                         IF dfStdMsg( MSG_LANGUAGE ) == "ITALIANO"
                            IF SUBSTR(c3Cifre,3,1)$"18"
                               cStringa := LEFT(cStringa,LEN(cStringa)-1)
                            ENDIF
                         ENDIF
                      ENDIF

                      // analisi dell'ultima cifra a destra (unit…)
                      nCifra = VAL(SUBSTR(c3Cifre,3,1))
                      IF nCifra>0
                         cStringa += aUnita[nCifra]
                      ENDIF
                   ENDIF

                   // aggiunta dell'attributo del gruppo (miliardi, milioni,
                   // mila); il primo a destra deve essere escluso
                   IF nGruppo#4
                      cStringa += aAttributi[nGruppo]
                   ENDIF
           ENDCASE

           // composizione dei gruppi convertiti, con esclusione del valore 0
           IF LEN(cStringa)#0
              // aggiunta di uno spazio per separare le parole
              IF LEN(cParole)#0
                 cStringa += " "
              ENDIF
              cParole := cStringa +cParole
           ENDIF

           // decremento dell'indice del ciclo
           nGruppo--
        ENDDO
ENDCASE

if dfStdMsg( MSG_LANGUAGE ) == "BRASIL"
   // ... here
   // ... correcao da escrita
   if right( cParole , 3 ) == " e "
      cParole := substr( cParole , 1 , len( cParole ) - 3 )
   endif
endif

RETURN cParole
