/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Thanks to Studio 2000
******************************************************************************/

#include "dfWin.ch"
#include "dfNet.ch"

#define INFO_LENGTH   (MAXROW() - 12)
#define MAX_SECONDS   3
#define ISLOCKED()    ( ASCAN( DBRLOCKLIST(), RECNO() ) > 0 )

MEMVAR ACT

PROCEDURE __DBFLIST()
   LOCAL aDbf  := {}
   LOCAL aMtd  := {}
   LOCAL nArea := 0


   DO WHILE (++nArea)->(USED())
      AADD(aDbf, PAD(ALIAS(nArea), 10)+" "+STR(nArea, 3, 0) + ;
                 IIF(nArea == SELECT(), "*", " "))
   ENDDO

   IF LEN(aDbf) > 0

      ADDKEY "A_w" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| CreaWin(oWin, aDbf)}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Window"                    // Messaggio utente associato

      ADDKEY "A_i" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (aDbf[tbRow(oWin)])->(ShowIndex(oWin), ShowInfo())}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Index"                   // Messaggio utente associato

      ADDKEY "A_k" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (aDbf[tbRow(oWin)])->(ShowLock(oWin))}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Lock"                  // Messaggio utente associato

      ADDKEY "A_s" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (aDbf[tbRow(oWin)])->(ShowStruct(oWin))}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Structure"                  // Messaggio utente associato

      ADDKEY "A_l" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (aDbf[tbRow(oWin)])->(LockRec(NET_RECORDLOCK), ShowInfo())}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Lock record"                  // Messaggio utente associato

      ADDKEY "A_u" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (aDbf[tbRow(oWin)])->(LockRec(NET_RECORDUNLOCK), ShowInfo())}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Unlock record"                  // Messaggio utente associato


      ADDKEY "A_1" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| ChangeOrder(oWin, 1, aDbf)}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Ordine by Area"                  // Messaggio utente associato

      ADDKEY "A_2" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| ChangeOrder(oWin, 2, aDbf)}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Ordine by Alias"                  // Messaggio utente associato


      ASORT(aDbf)

      dbScrSav()


      dbAct2Kbd("rep")

      nArea := dfArrWin(00, 00, MAXROW()-1, 18, aDbf, "Alias/Area", ;
               NIL, NIL, NIL, aMtd, {|nMode, oWin| DbfFunc(nMode, oWin, aDbf) }, NIL, .F.)

      dbScrRes()

      IF ! ACT == "esc" .AND. ;
         nArea > 0 .AND. nArea <= LEN(aDbf) .AND. ;
         dfYesNo("Do you want to set the file "+ALLTRIM(LEFT(aDbf[nArea], 10))+;
                 "//like default database ?")

         SELECT( ALLTRIM(LEFT(aDbf[nArea], 10)) )

      ENDIF
   ELSE
      dbMsgErr("No opened databases")
   ENDIF

RETURN

STATIC FUNCTION DbfFunc(nMode, oWin, aDbf)
   DO CASE
      CASE nMode == WO_EVENT_INKEY
         DO CASE

            // Fatto cos per evitare l'ombra della dfArrWin

            CASE ACT == "rep"
               ShowFixed()
               (aDbf[tbRow(oWin)])->(ShowInfo())
            CASE ACT $ "uar,dar"
               (aDbf[tbRow(oWin)])->(ShowInfo())
            CASE LEFT(ACT, 1) == "-"
               S2FastSeek(oWin, aDbf, ACT)
         ENDCASE
   ENDCASE

RETURN .F.

STATIC PROCEDURE CreaWin(oWin, aDbf)
   LOCAL nInd := tbRow(oWin)
   LOCAL cAlias:= ""
   LOCAL aMtd := {}
   IF nInd >= 1 .AND. nInd <= LEN(aDbf)
      cAlias := ALLTRIM(LEFT(aDbf[nInd], 10))

      ADDKEY "anr" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (cAlias)->(App(oWin))}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Insert"                  // Messaggio utente associato

      ADDKEY "mcr" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (cAlias)->(Mod(oWin))}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Modify"                  // Messaggio utente associato

      ADDKEY "ecr" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (cAlias)->(Del(oWin))}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Delete"                  // Messaggio utente associato

      ADDKEY "win" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (cAlias)->(ddKey()), tbStab(oWin, .T. )}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Search"                  // Messaggio utente associato

      ADDKEY "A_i" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (cAlias)->(ShowIndex(oWin))}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Index"                   // Messaggio utente associato

      ADDKEY "A_k" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (cAlias)->(ShowLock(oWin))}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Lock"                  // Messaggio utente associato

      ADDKEY "A_s" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (cAlias)->(ShowStruct(oWin))}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Structure"                  // Messaggio utente associato

      ADDKEY "A_l" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (aDbf[tbRow(oWin)])->(LockRec(NET_RECORDLOCK))}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Lock record"                  // Messaggio utente associato

      ADDKEY "A_u" TO aMtd        ; // Tasto su List Box
            BLOCK   {|oWin| (aDbf[tbRow(oWin)])->(LockRec(NET_RECORDUNLOCK))}  ; // Funzione sul tasto
            WHEN    {|s|s$"iam"}          ; // Condizione di stato di attivazione
            MESSAGE "Unlock record"                  // Messaggio utente associato



      (cAlias)->(dfWin(0, 0, MAXROW()-2, MAXCOL(), NIL, NIL, NIL, "File: "+cAlias, NIL, aMtd))
   ENDIF
RETURN

STATIC FUNCTION App(oWin)
   IF dfYesNo("Add an empty record?") .AND. ;
      dfNet(NET_APPEND)

      dfNet(NET_RECORDUNLOCK)
      tbAtr(oWin)
      dfAlert("Added record n. "+STR(RECNO()))
   ENDIF
RETURN NIL

STATIC FUNCTION Mod(oWin)
   LOCAL xVal      := tbItem(oWin)
   LOCAL cPict     := ""
   LOCAL nCol      := tbCol(oWin)
   LOCAL aStru     := (ALIAS())->(DBSTRUCT())
   LOCAL cType     := NIL
   LOCAL lIsLocked := .F.

   IF nCol > 0 .AND. nCol <= LEN(aStru)
      cType := aStru[nCol][2]
      DO CASE
         CASE cType == "C"
            IF aStru[nCol][3] > 40
               cPict := "@S40"
            ELSE
               cPict := REPLICATE("X", aStru[nCol][3])
            ENDIF
         CASE cType == "D"
            cPict := "99/99/9999"

         CASE cType == "L"
            cPict := "!"
         CASE cType == "N"
            IF aStru[nCol][4] == 0
               cPict := REPLICATE("9", aStru[nCol][3] )
            ELSE
               cPict := REPLICATE("9", aStru[nCol][3] - aStru[nCol][4] - 1) +;
                        "."+REPLICATE("9", aStru[nCol][4])
            ENDIF
      ENDCASE

      IF ! EMPTY(cPict)
         dfGetW(10, 10, aStru[nCol][1], ;
                {|x| IIF(x==NIL, xVal, xVal:=x) }, cPict)

         lIsLocked := ISLOCKED()

         IF ! ACT == "esc" .AND. ;
            (lIsLocked .OR. dfNet(NET_RECORDLOCK))

            FIELDPUT(nCol, xVal)

            IF !lIsLocked
               dfNet(NET_RECORDUNLOCK)
            ENDIF

            tbRtr(oWin)

         ENDIF
      ENDIF
   ENDIF
RETURN NIL

STATIC FUNCTION Del(oWin)
   LOCAL lIsLocked := ISLOCKED()
   IF dfYesNo("Delete the record ?") .AND. ;
      ( lIsLocked .OR. dfNet(NET_RECORDLOCK) )

      DBDELETE()

      IF ! lIsLocked
         dfNet(NET_RECORDUNLOCK)
      ENDIF
      tbEtr(oWin)
   ENDIF
RETURN NIL

STATIC FUNCTION ShowIndex(oWin)
   LOCAL aIndex := ArrayIndex(76)
   LOCAL nSce   := 0
   nSce := dfArrWin(00, 00, MAXROW()-2, MAXCOL(), aIndex, "Index of File: "+ALIAS())

   IF ! ACT == "esc" .AND. ;
      dfYesNo("Do you want to set the index n. "+STR(nSce, 4))

      tbSetKey(oWin, nSce)
      DBSETORDER(nSce)

      tbStab(oWin, .T. )
   ENDIF
RETURN NIL

STATIC FUNCTION ArrayIndex(nMax)
   LOCAL aIndex := {}
   LOCAL nOrd   := 0
   LOCAL cIndex := ""
   LOCAL cPad   := ""
   DO WHILE ! EMPTY( (cIndex := INDEXKEY(++nOrd)) )
      cIndex := IIF(nOrd == INDEXORD(), "*", " ") + ;
                STR(nOrd, 3, 0) + " " + cIndex
      cPad   := ""
      DO WHILE LEN(cIndex) > nMax
         AADD(aIndex, cPad+LEFT(cIndex, nMax))
         cIndex := SUBSTR(cIndex, nMax + 1)
         cPad   := "     "
      ENDDO
      IF LEN(cIndex) > 0
         AADD(aIndex, cPad+cIndex)
      ENDIF
   ENDDO

   IF LEN(aIndex) == 0
      AADD(aIndex, "No index on this area")
   ENDIF
RETURN aIndex

STATIC FUNCTION ShowStruct(oWin)
   LOCAL nOrd   := 0
   LOCAL cType  := "  "
   LOCAL aStru  := DBSTRUCT()
   LOCAL aStruct:= {}
   AEVAL(aStru, {|x, n| AADD(aStruct, PAD(x[1], 10)+" "+x[2]+" "+;
                                      STR(x[3],4,0)+" "+STR(x[4],4,0)+": "+;
                                      dfAny2Str(FIELDGET(n)) )})
   IF LEN(aStruct) > 0
      nOrd := dfArrWin(NIL, NIL, NIL, NIL, aStruct, ;
                       "Structure of file: "+ALIAS(), NIL, NIL, NIL, NIL, ;
                       {|nMode, oWin| StructFunc(nMode, oWin, aStruct) }, NIL, .F.)
//                       {|nMode, oWin| StructFunc(nMode, oWin, aStruct) })
   ENDIF

RETURN NIL

STATIC FUNCTION StructFunc(nMode, oWin, aStruct)
   DO CASE
      CASE nMode == WO_EVENT_INKEY
         DO CASE
            CASE LEFT(ACT, 1) == "-"
               S2FastSeek(oWin, aStruct, ACT)
         ENDCASE
   ENDCASE
RETURN .F.

STATIC FUNCTION ShowLock(oWin)
   LOCAL aLock  := {}

   aLock  := DBRLOCKLIST()

   IF LEN(aLock) == 0
      AADD(aLock, "No active lock")
   ENDIF
   dfArrWin(NIL, NIL, NIL, NIL, aLock, "Lock in File: "+ALIAS(), NIL, NIL, NIL, NIL, NIL, NIL, .F.)
RETURN NIL

STATIC FUNCTION ShowInfo()
   LOCAL nParti := INFO_LENGTH
   LOCAL nInd := 0
   LOCAL nOrd := 0
   LOCAL nRow := 0
   LOCAL aIndex := ArrayIndex(55)

   /*
   @       01, 21 SAY "Default RDD: " +RDDSETDEFAULT() COLOR "GR+/B"
   IF dfASDriver( RDDNAME() )
      @ ROW()+01, 21 SAY SPACE(30)
   ELSE
      @ ROW()+01, 21 SAY "Index Ext : " +dfAny2Str(INDEXEXT()) COLOR "GR+/B"
   ENDIF
   IF dfASDriver( RDDNAME() )
      @ ROW()+01, 21 SAY SPACE(30)
   ELSE
      @ ROW()+01, 21 SAY "Lock Number : " +PADL( LEN( DBRLOCKLIST() ), 4) COLOR "GR+/B"
   ENDIF
   */
#ifdef _IGNORE_THIS_
   @       01, 21 SAY "Area : "+STR(SELECT(), 4)+" Alias: "+PAD(ALIAS(),15)+" RDD: "+PAD(RDDNAME(),15) COLOR "GR+/B"
   @ ROW()+01, 21 SAY "Recno: "+STR(RECNO(), 8)+"/"+STR(LASTREC(), 8) COLOR "GR+/B"
   @ ROW()   , 48 SAY "EOF: "+IIF(EOF(), ".T.", ".F.") COLOR "GR+/B"
   @ ROW()   , 57 SAY "BOF: "+IIF(BOF(), ".T.", ".F.") COLOR "GR+/B"
   @ ROW()   , 67 SAY "FOUND: "+IIF(FOUND(), ".T.", ".F.") COLOR "GR+/B"
   @ ROW()+01, 21 SAY "Lock : "+IIF(ASCAN(DBRLOCKLIST(), RECNO()) > 0, "Yes", "No ") COLOR "GR+/B"
   @ ROW()+01, 21 SAY "Index: " COLOR "GR+/B"

   nRow := ROW()+01
   FOR nInd := nRow TO nParti-2
      ++nOrd
      @ nInd, 21 SAY PAD( IIF(nOrd <= LEN(aIndex), ;
                                aIndex[nOrd], ;
                                ""            ;
                             ), 55) COLOR "GR+/B"
   NEXT
#endif
RETURN NIL

STATIC FUNCTION ShowFixed()
#ifdef _IGNORE_THIS_
   LOCAL nParti := INFO_LENGTH
   dfSayBorder(00, 19, nParti-1, MAXCOL(), "GR+/B")
   dfFill( 01, 20, nParti-2, MAXCOL()-1, " ", "GR+/B")

   dfSayBorder(nParti, 19, MAXROW()-1, MAXCOL(), "GR+/B")
   dfFill(nParti+1, 20, MAXROW()-2, MAXCOL()-1, " ", "GR+/B")
   @ nParti+01, 21 SAY "ALT-1 / ALT-2 Order by Area/Alias"
   @ nParti+02, 21 SAY "ALT-I         Index"
   @ nParti+03, 21 SAY "ALT-S         Structure"
   @ nParti+04, 21 SAY "ALT-K         LockList"
   @ nParti+05, 21 SAY "ALT-L / ALT-U Lock/Unlock record"
   @ nParti+06, 21 SAY "ALT-W         Window"
   @ nParti+07, 21 SAY " ÃÄ Ins        Insert"
   @ nParti+08, 21 SAY " ÃÄ Barra      Modify"
   @ nParti+09, 21 SAY " ÃÄ Del        Delete"
   @ nParti+10, 21 SAY " ÀÄ F7         Search"
#endif
RETURN NIL

STATIC FUNCTION S2FastSeek(oWin, aDbf, cCode)
   LOCAL cSeek := ""
   LOCAL nCode := 0
   LOCAL cAct  := ""
   LOCAL lCont := .T.
   LOCAL nInd  := 0

   DO WHILE lCont .AND. (! EMPTY(cCode) .OR. (nCode := dfInkey( MAX_SECONDS)) != 0)
      IF EMPTY(cCode)
         cAct := dbKsc2Act(nCode)
      ELSE
         cAct := cCode
         cCode := ""
      ENDIF

      DO CASE
         CASE cAct == "bks" .AND. LEN(cSeek) > 0
            cSeek := LEFT(cSeek, LEN(cSeek) -1 )
            dfUsrInfo(cSeek)

            nInd := ArraySeek( aDbf, cSeek, tbRow(oWin) )
            IF nInd > 0
               oWin:W_CURRENTREC := nInd
            ENDIF

            tbStab(oWin, .T.)

         CASE LEFT(cAct, 1) == "-"

            nInd := ArraySeek( aDbf, cSeek+UPPER(SUBSTR(cAct, 2, 1)), ;
                               tbRow(oWin) )
            IF nInd > 0
               cSeek+=UPPER(SUBSTR(cAct, 2, 1))
               dfUsrInfo(cSeek)
               oWin:W_CURRENTREC := nInd
               tbStab(oWin, .T.)
            ENDIF


         OTHERWISE
            lCont := .F.
      ENDCASE
   ENDDO

   dfUsrInfo("")
RETURN NIL


STATIC FUNCTION ArraySeek(aDbf, cSeek, nInd)

   LOCAL nInd2 := 0

   // Scan until the end
   nInd2 := nInd
   DO WHILE nInd2 <= LEN(aDbf) .AND. ;
            UPPER(LEFT(aDbf[nInd2], LEN(cSeek)) ) != cSeek
      nInd2++
   ENDDO

   IF nInd2 > LEN(aDbf)
      // No value found start from head
      nInd2 := 1
      DO WHILE nInd2 <= nInd .AND. ;
               UPPER(LEFT(aDbf[nInd2], LEN(cSeek)) ) != cSeek
         nInd2++
      ENDDO
   ENDIF

   IF nInd2 > LEN(aDbf)
      nInd2 := 0
   ENDIF
RETURN nInd2

STATIC FUNCTION ChangeOrder(oWin, nO, aDbf)
   LOCAL bSort := NIL
   IF nO == 1
      bSort := {|x, y| SUBSTR(x, 12, 3) < SUBSTR(y, 12, 3) }
   ENDIF
   ASORT(aDbf, NIL, NIL, bSort)
   tbStab(oWin, .T. )

RETURN NIL

STATIC FUNCTION LockRec(cLock)
   IF cLock == NET_RECORDLOCK
      IF dfNet(NET_RECORDLOCK)
         dfAlert("File: "+ALIAS()+" Record n. "+STR(RECNO())+" locked")
      ENDIF
   ELSE
      IF dfNet(NET_RECORDUNLOCK)
         dfAlert("File: "+ALIAS()+" Record n. "+STR(RECNO())+" unlocked")
      ENDIF
   ENDIF
RETURN NIL
