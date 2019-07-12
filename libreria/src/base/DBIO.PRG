/*******************************************************************************
Project     : dBsee 4.0
Description : Retrocompatibilita' con dBsee 3.0
Programmer  : Baccan Matteo
*******************************************************************************/

#include "common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±± I/O database
FUNCTION dBio( cOpeMem ,; // operazione da svolgere  rea-def-wri-rel-raw (Read And Write)
               nFieIni ,; // numero campo da cui iniziare
               nFieEnd ,; // numero campo su cui terminare
               cFieSeq ,; // sequenza di campi sui quali operare separata da chr(177) prima e dopo (per raw contiene l'alias from)
               cFieSuf )  // suffisso in testa alle variabili che utilizza
* ±±±±±±±±±±±±±±±±±±±±±±±±±±
*
*  esempio di chiamata :
*              ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*  sele ARTI   ³<<<===== obbligatorio       ³
*              ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*  dbIo( [rea] )              && legge in variabili pubbliche
*  dbIo( [wri] )              && fa il wri su tutti i campi
*  dbIo( [def] )              && fa il def su tutti i campi
*  dbIo( [rea],2,0,[],[jj] )  && fa rea dal 2§ in poi e aggiunge "jj" in testa al nome che crea
*  dbIo( [def],3 )            && fa il def dal 3§ in poi
*  dbIo( [wri],3,5)           && fa il wri sul  3§ 4± e 5§  campo
*  dbIo( [wri],0,0,[±cod_for±cod_tab±cod_par±])   && fa il wri sui campi in elenco
*
**
**    Valore ritornato :
**
** 1 operazione sconosciuta
** 2 errato valore minimo campo
** 3 errato valore massimo campo
** 4 tutto ok !
**
*
LOCAL cMod := "", cFieTyp, cFrom, nFie, cField, cPubNam
*
DEFAULT cOpeMem TO "und"
DEFAULT nFieIni TO 1
DEFAULT nFieEnd TO Fcount()
DEFAULT cFieSeq TO ""
DEFAULT cFieSuf TO []
*
IF nFieIni = 0
   nFieIni := 1
ENDIF
*
IF nFieEnd = 0
   nFieEnd := Fcount()
ENDIF
*
IF nFieIni < 1                  && controllo su valore minimo
   RETURN 2
ENDIF
*
IF nFieEnd > Fcount()           && controllo su valore massimo
   RETURN 3
ENDIF
*
cFieSeq := upper( cFieSeq )
*
DO CASE
   CASE "/" $ cFieSeq
        cMod="e"
   CASE "±" $ cFieSeq
        cMod="i"
ENDCASE
*
DO CASE
   CASE cOpeMem = [raw]
        FOR nFie = nFieIni to nFieEnd
            cField  := fieldname(nFie)
            cFrom   := cFieSeq+'->'+cField
            _FIELD->&cField := &cFrom
        NEXT
        *
   CASE cOpeMem = [rea]
        FOR nFie = nFieIni to nFieEnd
            IF !dbIoFie( nFie, cMod, cFieSeq )
               LOOP
            ENDIF
            cPubNam  := cFieSuf+FieldName(nFie)
            PUBLIC &cPubNam
            &cPubNam := FieldGet( nFie )
        NEXT
        *
   CASE cOpeMem = [rel]
        FOR nFie = nFieIni to nFieEnd
            IF !dbIoFie( nFie, cMod, cFieSeq )
               LOOP
            ENDIF
            RELEASE &(cFieSuf+fieldname(nFie))
        NEXT
        *
   CASE cOpeMem $ [±wri±upd±]
        FOR nFie = nFieIni to nFieEnd
            IF !dbIoFie( nFie, cMod, cFieSeq )
               LOOP
            ENDIF
            IF !(M->&(cFieSuf+FieldName(nFie)) == FieldGet( nFie ))
               FieldPut( nFie, M->&(cFieSuf+FieldName(nFie)) )
            ENDIF
        NEXT
        *
   CASE cOpeMem = [def]
        FOR nFie = nFieIni to nFieEnd
            IF !dbIoFie( nFie, cMod, cFieSeq )
               LOOP
            ENDIF
            cField  := fieldname(nFie)
            cPubNam := cFieSuf+cField
            cFieTyp := type(cField)
            *
            PUBLIC &cPubNam
            *
            DO CASE
               CASE cFieTyp=[M]
                    &cPubNam := " "
                    *
               CASE cFieTyp=[C]
                    &cPubNam := Space(Len( Fieldget( nFie )))  && Testare !!
                    *
               CASE cFieTyp=[D]
                    &cPubNam := ctod([  /  /  ])
                    *
               CASE cFieTyp=[L]
                    &cPubNam := .F.
                    *
               CASE cFieTyp=[N]
                    &cPubNam := 0
                    *
            ENDCASE
        NEXT
        *
ENDCASE
*
IF cOpeMem $ [±wri±upd±]
   dbCommit()
ENDIF
*
RETURN 4

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dbIoFie( nFie, cMod, cFieSeq ) // Funzione di servizio per dbIo
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.
*
IF !Empty( cFieSeq )
   IF cMod == [e]               && Escludi i campi della sequenza
      *
      IF "/"+Upper( FieldName(nFie) )+"/" $ cFieSeq
         lRet := .F.
      ENDIF
      *
   ELSE                          && Includi solo i campi della sequenza
      *
      IF !("±"+Upper( FieldName(nFie) )+"±" $ cFieSeq)
         lRet := .F.
      ENDIF
      *
   ENDIF
ENDIF

RETURN lRet
