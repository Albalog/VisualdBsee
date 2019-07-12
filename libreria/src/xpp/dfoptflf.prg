#include "common.ch"
// Simone 1/3/2005 GERR 4283
// questa funzione serve come FIX prima di impostare un filtro
// e fare un GOTOP.
// In pratica imposta il DBSETORDER(0) (ordine naturale) 
// per non bloccare l'indice durante il SET FILTER
// questo metodo ha l'inconveniente che il GOTOP viene fatto
// sull'ordine naturale e non sull'ordine dell'indice (come
// avveniva prima)
//
// Come altro metodo di FIX che non risente di questo problema,
// può effettuare una copia dell'indice corrente.. però è un po più
// gravoso in termini di elaborazione (dato che deve fare la copia..)
//
// e comunque se si effettua la copia dell'indice PRIMA di tutta 
// l'elaborazione, questa cosa è inutile.
//
// Comunque è implementata questa logica (vedi dfSetFilter.prg):
// - sul clear Filter non esegue FIX
// - quando NON si deve fare il GOTOP
//   viene usato sempre il METODO 1 (ordine naturale) dato 
//   che non influisce in niente
// - quando si deve fare il GOTOP viene usato il FIX metodo definito
//   da dfFilterFixMtd() (cioè letto da apps.ini), ma per default
//   non abilita il FIX 


// metodo da usare per FIX blocchi CITRIX
// 0=disabilitato (default)
// 1=usa ordine naturale (pu• esserci un problema, vedi sotto)
// 2=copia/crea indice temp. e lo usa (per workaround al metodo 1)
FUNCTION dfFilterFixMtd(xPar)
   STATIC cMtd := NIL
   LOCAL cRet

   IF cMtd == NIL
      cMtd := dfSet("XbaseFilterFixMethod")
      DEFAULT cMtd TO "0"  // default = disabilitato
   ENDIF

   cRet := cMtd

   IF VALTYPE(xPar) $ "CM" .AND. xPar $ "012"
      cMtd := xPar
   ENDIF

RETURN cRet

// Simone 24/02/2005
// fix per evitare problemi blocchi su citrix
// xPar DEVE essere .T. o ARRAY
// se .T. -> ritorna situazione
FUNCTION dfFilterFixSet(nMtd)
   LOCAL cMtd 

   IF VALTYPE(nMtd) == "N" 
      cMtd := "0"
      DO CASE
         CASE nMtd == 1
           cMtd := "1"
         CASE nMtd == 2
           cMtd := "2"
      ENDCASE
   ELSE
      cMtd := dfFilterFixMtd()
   ENDIF

   // disabilitato
   IF cMtd == "0"
      RETURN NIL
   ENDIF

RETURN {cMtd, IIF( cMtd=="1", _FilterFix1(NIL), _FilterFix2(NIL) )}

FUNCTION dfFilterFixDel(xPar)
   LOCAL cMtd

   // parametro non valido
   IF ! VALTYPE(xPar) == "A"
      RETURN NIL
   ENDIF

   cMtd := xPar[1]

   // metodo non valido 
   IF ! (cMtd == "1" .OR. cMtd == "2")
      RETURN NIL
   ENDIF


RETURN IIF( cMtd=="1", _FilterFix1(xPar[2]), _FilterFix2(xPar[2]))


// metodo 1
// imposta ordine naturale prima di impostare il filtro 
// ci pu• essere un problema perch‚ quando nella dfOptFltSet() ecc.
// viene fatto il GOTOP si posiziona al primo record FISICO e non
// primo record in base all'indice
STATIC FUNCTION _FilterFix1(xPar)
   LOCAL xRet
   IF xPar == NIL
      // salva contesto
      xRet := {ALIAS(), ORDNUMBER()}

      // imposta ordine naturale
      ORDSETFOCUS( 0 )
   ELSE
      // ripristina contesto
      (xPar[1])->(ORDSETFOCUS( xPar[2] ))
   ENDIF
RETURN xRet

// metodo 2
// copia/crea nuovo indice uguale a indice corrente prima di impostare il filtro 
// questo dovrebbe fare da workaround al metodo 1, per• Š pi— peso da eseguire
// dato che fa sempre copia e cancellazione di un indice
STATIC FUNCTION _FilterFix2(xPar)
   LOCAL xRet
   LOCAL oIdx
   LOCAL nIdx
   LOCAL nTmp

   IF xPar == NIL
      // salva contesto
      nIdx := ORDNUMBER()
      nTmp:= nIdx

      // crea nuovo indice uguale a indice corrente
      oIdx:= dfIndexDup():new()
      oIdx:create(@nTmp)

      // se creato, imposta indice nuovo
      IF nTmp != nIdx
         ORDSETFOCUS( nTmp )
      ENDIF

      xRet := {ALIAS(), oIdx, nIdx}

   ELSE

      // ripristina contesto
      oIdx := xPar[2]
      nIdx := xPar[3]
      (xPar[1])->(ORDSETFOCUS( nIdx ))
      oIdx:destroy()

   ENDIF
RETURN xRet


