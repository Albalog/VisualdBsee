//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfWin.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbSetKey( oTbr   ,; // Oggetto Browse
                    nTbOrd ,; // Ordine
                    bTbKey ,; // Block key
                    bTbFlt ,; // Block Filter
                    bTbBrk ,; // Block Break
                    cStrKey,;
                    cStrFlt,;
                    cStrBrk )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF !EMPTY(oTbr:W_ALIAS)

   // Controllo formale dei parametri
   IF VALTYPE(nTbOrd)!="N"; nTbOrd:=NIL; ENDIF

// #ifdef __XPP__
//   IF VALTYPE(bTbKey)$"CM"
//      cStrKey := bTbKey
//      bTbKey:=DFCOMPILE(cStrKey)
//   ENDIF
//   IF VALTYPE(bTbFlt)$"CM"
//      cStrFlt := bTbFlt
//      bTbFlt:=DFCOMPILE(cStrFlt)
//   ENDIF
//   IF VALTYPE(bTbBrk)$"CM"
//      cStrBrk := bTbBrk
//      bTbBrk:=DFCOMPILE(cStrBrk)
//   ENDIF
// #endif

   IF VALTYPE(bTbKey)!="B"; bTbKey:=NIL; ENDIF
   IF VALTYPE(bTbFlt)!="B"; bTbFlt:=NIL; ENDIF
   IF VALTYPE(bTbBrk)!="B"; bTbBrk:=NIL; ENDIF

 #ifdef __XPP__
   IF !VALTYPE(cStrKey)$"CM"; cStrKey:=NIL; ENDIF
   IF !VALTYPE(cStrFlt)$"CM"; cStrFlt:=NIL; ENDIF
   IF !VALTYPE(cStrBrk)$"CM"; cStrBrk:=NIL; ENDIF
 #endif

   IF oTbr:W_DEF_ORDER==NIL               // Al primo giro aggiorno i DEFAULT
      oTbr:W_DEF_ORDER  := oTbr:W_ORDER      // di ORDER
      oTbr:W_DEF_KEY    := oTbr:W_KEY        //    KEY
      oTbr:W_DEF_FILTER := oTbr:W_FILTER     //    FILTER
      oTbr:W_DEF_BREAK  := oTbr:W_BREAK      //    BREAK
    #ifdef __XPP__
      oTbr:W_DEF_STRKEY    := oTbr:W_STRKEY        //    KEY
      oTbr:W_DEF_STRFILTER := oTbr:W_STRFILTER     //    FILTER
      oTbr:W_DEF_STRBREAK  := oTbr:W_STRBREAK      //    BREAK
    #endif
      IF oTbr:W_DEF_KEY!=NIL .AND. EVAL(oTbr:W_DEF_KEY) == NIL
         oTbr:W_DEF_KEY := NIL
      ENDIF
   ENDIF

   DEFAULT nTbOrd TO oTbr:W_DEF_ORDER    // DEFAULT presi dopo la prima
   DEFAULT bTbKey TO oTbr:W_DEF_KEY      // Inizializzazione
   DEFAULT bTbFlt TO oTbr:W_DEF_FILTER
   DEFAULT bTbBrk TO oTbr:W_DEF_BREAK
 #ifdef __XPP__
   DEFAULT cStrKey TO oTbr:W_DEF_STRKEY     
   DEFAULT cStrFlt TO oTbr:W_DEF_STRFILTER
   DEFAULT cStrBrk TO oTbr:W_DEF_STRBREAK
 #endif

   (oTbr:W_ALIAS)->(ORDSETFOCUS_XPP( nTbOrd ))

   oTbr:W_ORDER  := nTbOrd
   oTbr:W_KEY    := bTbKey
   IF oTbr:W_KEY!=NIL .AND. EVAL(oTbr:W_KEY) == NIL
      oTbr:W_KEY := NIL      // Assegno un valore significativo
   ENDIF
   oTbr:W_FILTER := bTbFlt
   oTbr:W_BREAK  := bTbBrk
   oTbr:W_CURRENTREC := NIL

 #ifdef __XPP__
   oTbr:W_STRKEY    := cStrKey
   oTbr:W_STRFILTER := cStrFlt
   oTbr:W_STRBREAK  := cStrBrk
   IF isMethod(oTbr, "OptChk")
      // Controllo ottimizzazione DOPO l'agg.to key/flt/brk
      oTbr:OptChk()
   ENDIF
 #endif

   IF oTbr:W_KEY # NIL       // se ho una chiave
      // Simone 14/6/06 per GIOIAXP aggiunto settaggio
      IF dfSet(AI_TBSETKEYTOP)
         EVAL( oTbr:GoTopBlock ) // il record attuale potrebbe essere fuiri filtro
      ELSE
         IF (oTbr:W_ALIAS)->(DELETED())  .OR. ; // Record Cancellato
            !EVAL(oTbr:W_FILTER)         .OR. ;  // O non Sono in filtro
            EVAL(oTbr:W_BREAK)

            EVAL( oTbr:GoTopBlock ) // il record attuale potrebbe essere fuiri filtro
         ENDIF
      ENDIF
   ELSE
      DO CASE
         CASE (oTbr:W_ALIAS)->(RECCOUNT())==0
              * File vuoto

         CASE (oTbr:W_ALIAS)->(EOF())          // EOF
              EVAL( oTbr:GoTopBlock )             // Vado al primo record

         CASE (oTbr:W_ALIAS)->(DELETED())  .OR. ; // Record Cancellato
              !EVAL(oTbr:W_FILTER)                // O non Sono in filtro
              tbValidRec( oTbr )

         CASE EVAL(oTbr:W_BREAK)               // BREAK
              (oTbr:W_ALIAS)->(DBGOTO(0))         // Mando a EOF
      ENDCASE
   ENDIF
   tbRecCng( oTbr )                            // Memorizzo Record
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbValidRec( oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nOldType
nOldType       := oTbr:WOBJ_TYPE  // Evito il messaggio di fine
oTbr:WOBJ_TYPE := W_OBJ_BRW       // file sui form
IF EVAL( oTbr:SkipBlock, 1 ) == 0  // NON ho RECORD Avanti
   IF EVAL( oTbr:SkipBlock, -1 ) == 0 // NON ho RECORD Indietro
      EVAL( oTbr:GoTopBlock )            // GOTOP
   ENDIF
ENDIF
oTbr:WOBJ_TYPE := nOldType
RETURN
