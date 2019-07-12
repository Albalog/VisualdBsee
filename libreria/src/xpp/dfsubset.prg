#include "common.ch"
#include "dmlb.ch"
#include "Appevent.ch"
#include "dfMsg.ch"

// dovrebbero garantire maggiore velocit…, vedi NOTA1.TXT
#command SAFECB <bCB> => IIF(<bCB>==NIL .OR. VALTYPE(<bCB>)=="B", NIL, (<bCB>:=NIL))
#command SAFECBEXE <bCB> [WITH <parList,...>] => IIF(<bCB>==NIL, NIL, EVAL(<bCB>, <parList>))
#command SAFECBEXE <bCB> [WITH <parList,...>] TO <xVar> => IIF(<bCB>==NIL, NIL, <xVar> := EVAL(<bCB>, <parList>))


CLASS dfSubset FROM dbSubSet

   PROTECTED:
      //VAR aFile
      VAR aWS
      METHOD atStart, execute, atEnd      // server-side methods
      METHOD dfTop, dfSkip
      VAR nError
      VAR bKeyExp
      METHOD _gotorec

   EXPORTED:
      VAR cAlias, nOrd, subsetKey, subsetBreak
      VAR bStart, bEval, bEnd, bOnFound
      VAR lPB
      VAR nProgress
      METHOD init, prepare
      INLINE METHOD getError(); RETURN ::nError
      METHOD notify, destroy
ENDCLASS

METHOD dfSubset:init( cAlias, nOrd, xKey, bSubset, bBrk )
   ::DbSubSet:init(bSubSet)
   ::subsetKey := xKey
   ::subsetBreak := bBrk
   ::cAlias := cAlias
   ::nOrd := nOrd
   //::aFile := {}
   ::aWS :={}
   ::nError := 0
   ::nProgress := 0 // no progress bar
   ::bKeyExp   := NIL
RETURN self


METHOD dfSubset:notify(nEvent, mp1, mp2)
    LOCAL lValid
    LOCAL cKey
    IF nEvent == xbeDBO_Notify             // Notify event 
        IF mp1 == DBO_TABLE_UPDATE .OR. ;
           mp1 == DBO_TABLE_APPEND .OR. ;
           mp1 == DBO_TABLE_DELETED

           // il Record Š valido?
           IF SET(_SET_DELETED) .AND. DELETED()
              lValid := .F.
           ELSE
              lValid := EVAL(::subsetBlock) .AND. ! EVAL(::subsetBreak)
           ENDIF

           // Esiste gi…?
           IF ::bKeyExp == NIL
              mp1 := ASCAN(::aRecno, RECNO() )
           ELSE
              mp1 := ASCAN(::aRecno, {|x|x[1]==RECNO()} )
           ENDIF
           IF mp1 > 0 .AND. ! lValid
              // esiste e non Š valido,  lo tolgo
              ::nLastRec--
             #ifdef _XBASE17_
              AREMOVE(::aRecno, mp1)
             #else
              ADEL(::aRecno, mp1)
              ASIZE(::aRecno, ::nLastRec)
             #endif
           ELSEIF lValid            // se e' valido
              IF mp1 == 0           // e non esisteva lo aggiungo nel punto giusto in base all'indice
                 // record nuovo
                 IF ::bKeyExp == NIL
                    AADD(::aRecno, RECNO())
                 ELSE
                    // Inserisco in posizione ordinata in base all'indice
                    cKey := EVAL(::bKeyExp)

                    // dato che Š ordinato si potrebbe usare un binary search
                    mp1 := ASCAN(::aRecno, {|a| a[2] > cKey})
                    IF mp1 == 0
                       AADD(::aRecno, {RECNO(), EVAL(::bKeyExp) })
                    ELSE
                       AINS(::aRecno, mp1, {RECNO(), EVAL(::bKeyExp) })
                    ENDIF
                 ENDIF
                 ::nLastRec++
              ELSE
                 // record modificato, devo aggiornare la chiave?
                 IF ::bKeyExp != NIL
                    mp2 := ::aRecno[mp1][2]
                    cKey := EVAL(::bKeyExp)
                    IF ! cKey == mp2
                       // chiave modificata,  devo aggiornare
                       ::aRecno[mp1][2] := cKey
                       ASORT(::aRecno, NIL, NIL,  {|x, y|x[2]<=y[2]})
                    ENDIF
                 ENDIF
                 
              ENDIF
           ENDIF
        ENDIF 
     ENDIF 

RETURN self


METHOD dfSubset:prepare( nFirstSubset )
   LOCAL aState := S2WorkSpaceSave()  // Salvo lo stato di tutte le aree 

   DBSELECTAREA(::cAlias)
   IF EMPTY(::nOrd)
      ::bKeyExp := NIL
   ELSE
      DBSETORDER(::nOrd)
      ::bKeyExp := DFCOMPILE(INDEXKEY())
   ENDIF

   ::aWS :=S2WorkSpaceGet()

   ::nError := 0
   ::dbSubSet:prepare( nFirstSubset )
   IF ::nError == 0
      DbRegisterclient(self)
   ENDIF
   S2WorkSpaceRest(aState) // ripristino
RETURN self

METHOD dfSubset:destroy()
   (::cAlias)->(DbDeregisterClient(self))
RETURN self


METHOD dfSubset:execute
   LOCAL nStep  := 500
   LOCAL nMax   := Len( ::aRecno )
   LOCAL nCount 
   LOCAL lFound := .T.
   LOCAL nMaxPB := 0
   LOCAL nProgress := ::nProgress

   // Errore in apertura archivi
   IF ::nError != 0
      ::oSignal:signal()
      RETURN self
   ENDIF

   SAFECB ::bStart
   SAFECB ::bEval
   SAFECB ::bEnd
   SAFECB ::bOnFound

   SAFECBEXE ::bStart

   ::nLastRec := 0
   nCount     := 0

   IF ::nLastrec == ::nPrepare
      ::oSignal:signal()
      ::oSignal:wait(500)
   ENDIF

   IF nProgress == 1
      nMaxPB := ::nPrepare
      _dfMakeIndInit()
      _dfMakeIndCreate("", nMaxPB, .5) //RECCOUNT())
   ELSEIF nProgress == 2
      dbMsgOn( dfStdMsg(MSG_DDKEY12), .5 )
   ENDIF

   ::dfTop( ::subsetKey, ::subsetBlock, ::subsetBreak )

   lFound := ! EOF()

   DO WHILE lFound

      IF nProgress == 1 
         IF ::nLastRec < nMaxPB
            _dfMakeIndPB()
         ELSE
           _dfMakeIndDestroy()
            nProgress := 0
         ENDIF
      ENDIF

      IF ++ nCount > nMax
         ASize( ::aRecno, nMax += nStep )
      ENDIF

      IF ::bKeyExp == NIL
         ::aRecno[ nCount ] := Recno()
      ELSE
         // memorizzo anche la chiave per fare confronto in ::notify
         // Nota: questo a volte da un errore in aCreate() non so perche
         //       ::aRecno[ nCount ] := {Recno(), EVAL(::bKeyExp)}

         ::aRecno[ nCount ] := {NIL, NIL}
         ::aRecno[ nCount ][1] := Recno()
         ::aRecno[ nCount ][2] := EVAL(::bKeyExp)

      ENDIF

      // This may only be incremented after the Recno() assignment.
      // Otherwise, the class is not thread safe due to
      //    DbGoto( ::aRecno[ ::nRecno ] ) in the :goto() method
      ::nLastRec ++

      SAFECBEXE ::bOnFound

      lFound := ::dfSkip( 1, ::subsetBlock, ::subsetBreak ) > 0

      IF ::nLastrec == ::nPrepare
         ::oSignal:signal()
         ::oSignal:wait(500)
      ENDIF
   ENDDO

   IF nProgress == 1
      _dfMakeIndDestroy()
   ELSEIF nProgress == 2
      dbMsgOff()
   ENDIF

   ASize( ::aRecno, ::nLastRec )
   ::oSignal:signal()

   SAFECBEXE ::bEnd
RETURN self

METHOD dfSubset:atStart
   IF ! S2WorkSpaceSet(::aWS)
      ::nError := -1
   ENDIF
   //DbSelectArea( ::area )
   //IF dfUse(::cAlias, NIL, ::aFile) .AND. ! EMPTY(::nOrd)
   //   (::cAlias)->(DBSETORDER(::nOrd))
   //ENDIF
RETURN self


METHOD dfSubset:atEnd
   //dfClose(::aFile)
   //DbCloseAll()
   S2WorkSpaceDel(::aWS)
RETURN self



* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfSubSet:dfSkip( n2Skip, bFilter, bBreak ) // dbSkip
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSkipped := 0, nActRec := IF(EOF(),0,RECNO())

DEFAULT n2Skip     TO 1

DO CASE
   CASE (LastRec() == 0) .OR. (n2Skip == 0)
        dbSkip(0)
        DBGOTO_XPP(nActRec)

   CASE (n2Skip > 0)
        DO WHILE nSkipped<n2Skip
           dbSkip(1)

           IF ::bEval != NIL .AND. ! EVAL(::bEval) 
              dbGoto_XPP( nActRec )
              EXIT
           ENDIF
             
           IF Eof() .OR. EVAL( bBreak )
              dbGoto_XPP( nActRec )
              EXIT
           ENDIF

           IF !EVAL( bFilter )
              LOOP
           ENDIF

           nActRec := Recno()
           nSkipped++

        ENDDO

   CASE (n2Skip < 0)
        DO WHILE nSkipped>n2Skip

           dbSkip(-1)

           IF Bof() .OR. Eval( bBreak )
              dbGoto_XPP( nActRec )
              EXIT
           ENDIF

           IF !Eval( bFilter )
              LOOP
           ENDIF

           nActRec := Recno()
           nSkipped--

        ENDDO

ENDCASE

RETURN nSkipped

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD dfSubSet:dfTop( bKey, bFilter, bBreak ) // GoTop
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lEof := .F.

IF bKey == NIL       // se row_key e' vuota
   DBGOTOP()            // vado al primo record
ELSE
   DBSEEK(EVAL( bKey ), .T. )   // cerco la chiave in modo SOFT
   lEof := EOF()
ENDIF

IF !lEof // Solo se non sono a EOF
   IF !EVAL( bFilter )             // Se non sono in filtro
      ::dfSkip( 1, bFilter, bBreak )   // Skippo di 1
   ENDIF

   // Se Break o Filtro NON verificato
   IF EVAL( bBreak ) .OR. !EVAL( bFilter )
      DBGOTO_XPP(0)
   ENDIF
ENDIF

RETURN


METHOD dfSubset:_Gotorec()
   IF ::bKeyExp == NIL
      DBGOTO_XPP(::aRecno[::nRecno])
   ELSE
      DBGOTO_XPP(::aRecno[::nRecno][1])
   ENDIF
RETURN
