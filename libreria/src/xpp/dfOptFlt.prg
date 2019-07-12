// ----------------------------------------------------
// Queste funzioni sono derivate dalla LIBSCRIP.PRG 
// in S2000LIB
// Servono per interpretare un'espressione in modo che
// possa essere eseguita da ADS SERVER (espressione FOR o indice)
// ----------------------------------------------------
//
// Si potrebbe aggiungere: 
// - ottimizzione in caso parte del filtro sia in indice 
//   (vedi ottim. query di dBsee dfQryOpt())
//
// - ottimizzazione di espressioni
//   es. "totdoc <= (3+5)*2" -> diventa direttamente "totdoc <= 16"
//
// - rigirare automaticamente le espressioni per ottimiz. ADS
//   es. "10 > numdoc" -> "numdoc < 10"
//   oppure 
//       "qtamov>qtagiac" -> "(qtamov-qtagiac)>0"
//   perche la prima espr. non viene ottimizzata dal server ADS ma la 2^ si
//   vedi documentaizione ADS
//
// NOTA:
// all'inizio del programma:
// se si usa ADS (filtro valutato dal server): impostare cosi 
//  dfOptFltSetOpt(.T., .F., .T.)
//  dfOptFltUDF("S2CHKRANGE", {|aParam|_ChkRange(aParam)} ) // per queste fun vedi TEST.PRG
//  dfOptFltUDF("S2CHKVALUE", {|aParam|_ChkValue(aParam)} ) // per queste fun vedi TEST.PRG
//  dfOptFltAdsFunSet()
//
// se NON si usa ADS (filtro valutato in locale): impostare cosi 
//  dfOptFltSetOpt(.T., .T., .F.)
//  ed eventualmente si pu• aggiungere anche
//  dfOptFltUDF("S2CHKRANGE", {|aParam|_ChkRange(aParam)} )
//  dfOptFltUDF("S2CHKVALUE", {|aParam|_ChkValue(aParam)} )


#include "Common.ch"
#include "dfOptFlt.ch"
#include "dfStd.ch"

#define S2SCR_OK                          0
#define S2SCR_ERR_FILENOTFOUND           -1
#define S2SCR_ERR_SYNTAX                 -2
#define S2SCR_ERR_MANCAPARENTESI         -3
#define S2SCR_ERR_MANCAESPRESS           -4
#define S2SCR_ERR_MANCAUGUALE            -5
#define S2SCR_ERR_NONVARIAB              -6
#define S2SCR_ERR_TYPEMISMATCH           -7
#define S2SCR_ERR_MANCAENDIF             -8
#define S2SCR_ERR_MANCATO                -9
#define S2SCR_ERR_DBNOTUSED             -10
#define S2SCR_ERR_STRUTTNONCHIUSA       -11
#define S2SCR_ERR_FIELDNOTFOUND         -12
#define S2SCR_ERR_NOTLOGICALEXPR        -13
#define S2SCR_ERR_NOTARRAY              -14
#define S2SCR_ERR_SUBSCRIPTRANGE        -15


#define TAB                CHR(9)
#define CR                 CHR(13)

#define DELIMITER             1
#define VARIABLE              2
#define NUMBER                3
#define COMMAND               4
#define STRING                5
#define QUOTE                 6
#define FUNCTIONCALL          7
#define FIELDVAR              8
#define ARRAY_IDX             9
#define ALIAS_VAR            10
#define ALIAS_FUN            11


#define CMD_NIL                  19
#define CMD_TRUE                 20
#define CMD_FALSE                21
#define CMD_AND                  22
#define CMD_OR                   23
#define CMD_NOT                  24


#define CMD_EOL                1000
#define CMD_FINISHED           1001
#define CMD_END                1002

#define NOTOPTALIAS_MANTAIN       0
#define NOTOPTALIAS_DELETE        1


// Usate nell'ottimizzazione S2ScriptExe
STATIC lShortCircuit      := .T. // abilita ottim. short circuit es. 
                                 // ".T. .OR. .F." -> mette ".T."
STATIC lAllowAllFunctions := .T. // Abilita tutte le funzioni
STATIC lDelBaseAlias      := .F. // toglie l'alias base

// Imposto le funzioni che posso passare direttamente ad ADS (ALLTRIM, ecc)
// o che posso gestire localmente (S2CHKRANGE, ecc)

STATIC aUDFFunc := {}

// dfOptFltUDFGet()
// ritorna lista funzioni utente
FUNCTION dfOptFltUDFGet()
RETURN ACLONE(aUDFFunc)

// dfOptFltUDF()
// Permette di imposta delle funzioni utente 
// da usare durante l'ottimizzazione
// se necessario basta chiamarla solo 1 volta all'inizio
// -----------------------------------------------------
FUNCTION dfOptFltUDF(cFunc, bFunc, aArr)
   LOCAL nPos := 0
   LOCAL bRet

   DEFAULT aArr TO aUDFFunc

   IF VALTYPE(cFunc)=="C"

      IF bFunc != NIL .AND. ! VALTYPE(bFunc) == "B"
         bFunc := NIL
      ENDIF

      cFunc := UPPER(ALLTRIM(cFunc))
      nPos := ASCAN(aArr, {|x| IIF(VALTYPE(x)=="A", x[1], x) == cFunc})
      IF nPos == 0
         AADD(aArr, IIF(bFunc==NIL, cFunc, {cFunc, bFunc}))
      ELSE
         bRet := IIF(VALTYPE(aArr[nPos]) == "A", aArr[nPos][2], NIL)
         aArr[nPos] := IIF(bFunc==NIL, cFunc, {cFunc, bFunc})
      ENDIF
   ENDIF
RETURN bRet

// Imposta le funzioni ADS nell'elenco di quelle ottimizzate
FUNCTION dfOptFltADSFunSet(aArr)
   AEVAL(dfOptFltADSFunList(), {|x|dfOptFltUDF(x, NIL, aArr)} )
RETURN .T.

// Elenco delle funzioni disponibili in ADS
FUNCTION dfOptFltADSFunList()
RETURN { "ALLTRIM"     ,;  // Funzioni ADS vengono passate pari pari
         "AT"          ,;
         "CHR"         ,;
         "CTOD"        ,;
         "DATE"        ,;
         "DAY"         ,;
         "DELETED"     ,;
         "DESCEND"     ,;
         "DTOC"        ,;
         "EMPTY"       ,;
         "I2BIN"       ,;
         "IF"          ,;
         "IIF"         ,;
         "LEFT"        ,;
         "LEN"         ,;
         "LOWER"       ,;
         "LTRIM"       ,;
         "MONTH"       ,;
         "PAD"         ,;
         "PADC"        ,;
         "PADL"        ,;
         "PADR"        ,;
         "RAT"         ,;
         "RECNO"       ,;
         "RIGHT"       ,;
         "ROUND"       ,;
         "RTRIM"       ,;
         "SPACE"       ,;
         "STR"         ,;
         "STRZERO"     ,;
         "SUBSTR"      ,;
         "TIME"        ,;
         "TODAY"       ,;
         "TRANSFORM"   ,;
         "TRIM"        ,;
         "UPPER"       ,;
         "VAL"         ,;
         "YEAR"        ,;
         "ABS"         ,; // Simone 21/03/2005 gerr 4335 aggiunte funzioni ADS
         "DTOS"        ,;
         "STOD"        ,;
         "L2BIN"       ,;
         "MAX"         ,;
         "MIN"         }

//NOW() 
//CONTAINS() 	
//CTOT()	
//CTOTS()	
//REVERSE()
//STOTS()
//LOWERW()	
//UPPERW()

// attiva ottimizzazione "corto circuito" (short circuit)
FUNCTION dfOptFltSetOpt(lShort, lAllFunc, lDelBA)
   LOCAL aOld := {lShortCircuit, lAllowAllFunctions, lDelBaseAlias}
   IF VALTYPE(lShort) == "L"
      lShortCircuit := lShort
   ENDIF
   IF VALTYPE(lAllFunc) == "L"
      lAllowAllFunctions := lAllFunc
   ENDIF
   IF VALTYPE(lDelBA) == "L"
      lDelBaseAlias := lDelBA
   ENDIF
RETURN aOld

// dfOptFltNew()
// Crea un nuovo array contenente i filtri
// e' chiamata in automatico dal comando CREATE FILTER
// ---------------------------------------------------
FUNCTION dfOptFltNew(cAlias, cExp, bExp, bVarAcc)
   LOCAL aRet := ARRAY(OPTFLT_NUMELEM)

   DEFAULT cAlias TO ALIAS()

   IF cExp == NIL .AND. bExp == NIL
      RETURN {}
   ENDIF

   IF cExp == NIL .AND. bExp != NIL
      cExp := dfCodeBlock2String(bExp)
   ELSEIF cExp != NIL .AND. bExp == NIL
      bExp := DFCOMPILE(cExp)
   ENDIF

   aRet[OPTFLT_ALIAS]          := cAlias
   aRet[OPTFLT_STREXP]         := cExp
   aRet[OPTFLT_CBEXP]          := bExp
   aRet[OPTFLT_CBVARACCESS]    := bVarAcc
   aRet[OPTFLT_VAR_ARR]        := {}
   aRet[OPTFLT_STROPTEXP]      := NIL
   aRet[OPTFLT_CBOPTEXP]       := NIL
   aRet[OPTFLT_ERRNUM]         := S2SCR_OK
   aRet[OPTFLT_ERRMESSAGE]     := ""
   aRet[OPTFLT_NOTOPTFUNC]     := {}
   aRet[OPTFLT_STRNOTOPTEXP]   := NIL
   aRet[OPTFLT_CBNOTOPTEXP]    := NIL
   aRet[OPTFLT_OPTIMIZEALIAS]  := {}
   aRet[OPTFLT_CARGO]          := NIL // Simone 1/3/2005 GERR 4283

RETURN aRet

FUNCTION dfOptFltAddVar(aOpt1, aOpt2)
   AEVAL(aOpt2[OPTFLT_VAR_ARR], {|x| AADD(aOpt1[OPTFLT_VAR_ARR], x)} )

   IF VALTYPE(aOpt1[OPTFLT_CBVARACCESS]) == "B" .AND. ;
      VALTYPE(aOpt2[OPTFLT_CBVARACCESS]) == "B"

      aOpt1[OPTFLT_CBVARACCESS] := _localizeCB(aOpt1[OPTFLT_CBVARACCESS], ;
                                               aOpt2[OPTFLT_CBVARACCESS])

   ELSEIF VALTYPE(aOpt1[OPTFLT_CBVARACCESS]) != "B" .AND. VALTYPE(aOpt2[OPTFLT_CBVARACCESS]) == "B"
      aOpt1[OPTFLT_CBVARACCESS] := aOpt2[OPTFLT_CBVARACCESS]

   ENDIF

RETURN NIL

// Localizza elementi dell'array
STATIC FUNCTION _localizeCB(bCB1,bCB2)
   LOCAL myCB1 := bCB1
   LOCAL myCB2 := bCB2
RETURN {|cVar,xVal|_getVar(myCB1,myCB2,cVar,xVal)}

STATIC FUNCTION _getVar(bCB1,bCB2,cVar,xVal)
   LOCAL xRet := EVAL(bCB1,cVar,xVal)
   IF xRet == NIL
      xRet := EVAL(bCB2,cVar,xVal)
   ENDIF  
RETURN xRet

// dfOptFltSetVar()
// Imposta i nomi delle variabili utilizzate nel filtro
// e' chiamata in automatico dal comando CREATE FILTER
// ---------------------------------------------------
FUNCTION dfOptFltSetVar(aOpt)
   LOCAL nPar := PCOUNT()-1
   LOCAL nInd
   LOCAL aVar := {}
   LOCAL xParam

   IF nPar != LEN(aOpt[OPTFLT_VAR_ARR])
      ASIZE(aOpt[OPTFLT_VAR_ARR], nPar)
   ENDIF

   FOR nInd := 1 TO nPar
      // Assicura che l'elemento corrente sia un array di 2 elementi
      ChkArr(aOpt, nInd)
      xParam := PVALUE(nInd+1)
      IF VALTYPE(xParam) $ "CM"
         xParam := UPPER(ALLTRIM( xParam ))
         aOpt[OPTFLT_VAR_ARR][nInd][1] := xParam
      ENDIF
   NEXT
RETURN .T.

// dfOptFltSetVal()
// Associa i codeblock ai nomi delle variabili utilizzate nel filtro
// e' chiamata in automatico dal comando CREATE FILTER
// ---------------------------------------------------
FUNCTION dfOptFltSetVal(aOpt)
   LOCAL nPar := PCOUNT()-1
   LOCAL nInd
   IF nPar != LEN(aOpt[OPTFLT_VAR_ARR])
      ASIZE(aOpt[OPTFLT_VAR_ARR], nPar)
   ENDIF

   FOR nInd := 1 TO nPar
      // Assicura che l'elemento corrente sia un array di 2 elementi
      ChkArr(aOpt, nInd)
      aOpt[OPTFLT_VAR_ARR][nInd][2] := PVALUE(nInd+1)
   NEXT
RETURN .T.

STATIC FUNCTION ChkArr(aOpt, nInd)
   IF VALTYPE( aOpt[OPTFLT_VAR_ARR][nInd] ) == "A" 
      IF LEN(aOpt[OPTFLT_VAR_ARR][nInd]) < 2
         ASIZE(aOpt[OPTFLT_VAR_ARR][nInd], 2)
      ENDIF
   ELSE
      aOpt[OPTFLT_VAR_ARR][nInd] := {NIL, NIL}
   ENDIF
RETURN NIL

// dfOptFltSetAlias()
// Imposta l'elenco degli alias ottimizzabili
// e' chiamata in automatico dal comando CREATE FILTER
// ---------------------------------------------------
FUNCTION dfOptFltSetAlias(aOpt)
   LOCAL nPar := PCOUNT()-1
   LOCAL nInd
   IF nPar != LEN(aOpt[OPTFLT_OPTIMIZEALIAS])
      ASIZE(aOpt[OPTFLT_OPTIMIZEALIAS], nPar)
   ENDIF

   FOR nInd := 1 TO nPar
      aOpt[OPTFLT_OPTIMIZEALIAS][nInd] := PVALUE(nInd+1)
   NEXT
RETURN .T.

// dfOptFltOptimize()
// Esegue l'ottimizzione dell'espressione FOR impostata 
// dal comando CREATE FILTER
// creando una stringa che pu• essere interpretata dal 
// server ADS
// E' chiamata dal comando OPTIMIZE FILTER
// -----------------------------------------------------
FUNCTION dfOptFltOptimize(aOpt, bBlk, nMax)
   LOCAL cOpt := ""
   LOCAL cExp := ""
   LOCAL aVar := NIL
   LOCAL err
   LOCAL xVal := NIL
   LOCAL nInd := NIL
   LOCAL oErr
   LOCAL oOpt
   LOCAL lADS := dfAxsIsLoaded(aOpt[OPTFLT_ALIAS])
   LOCAL nSel

   DEFAULT bBlk TO IIF(lADS,  ;
                       {|| dfExpressionOptimizerADS():new() }, ;
                       {|| dfExpressionOptimizer():new() })

   oOpt := EVAL(bBlk)

   oOpt:SetMaxStringLen(nMax)
   oOpt:SetInitCB(bBlk) // per usare in _EVAL
   oOpt:SetOptAlias(aOpt[OPTFLT_OPTIMIZEALIAS])

   // Analizza stringa e ottimizza
//   cOpt := ...
//   S2ScriptExe(aOpt[1])
//? aopt

   // Simone 2/3/2005 gerr 4335
   // le query non erano ottimizzate perchŠ l'alias corrente
   // non era il master. Penso sia pi— giusto impostare l'alias MASTER
   IF ! EMPTY( aOpt[OPTFLT_ALIAS] )
      nSel := SELECT()
      DBSELECTAREA( aOpt[OPTFLT_ALIAS] )
   ENDIF

   nInd := oOpt:Optimize(aOpt[OPTFLT_STREXP], ;
                    aOpt[OPTFLT_ALIAS], aOpt[OPTFLT_VAR_ARR], ;
                    aOpt[OPTFLT_CBVARACCESS])
   cExp := oOpt:getRetValue()

   IF nSel != NIL
      DBSELECTAREA(nSel)
   ENDIF

//?nInd, S2ScriptErr(nInd)
//?cExp
//wait
//
//IF nInd == 0
//   oErr := ERRORBLOCK({|e|break(e)})
//   BEGIN SEQUENCE
//      ? EVAL( DFCOMPILE(cExp) )
//
//   RECOVER USING err
//      ? "ERRORE", err:message
//
//   END SEQUENCE
//   ERRORBLOCK(oErr)
//   wait
//ENDIF
   aOpt[OPTFLT_ERRNUM    ] := nInd
   aOpt[OPTFLT_ERRMESSAGE] := oOpt:getErrMsg(nInd)
   aOpt[OPTFLT_NOTOPTFUNC] := ACLONE(oOpt:getNotOptFunc())

   IF nInd == S2SCR_OK
      aOpt[OPTFLT_STROPTEXP ] := cExp
      aOpt[OPTFLT_CBOPTEXP  ] := DFCOMPILE(cExp)

      IF EMPTY( aOpt[OPTFLT_NOTOPTFUNC] ) 
         aOpt[OPTFLT_STRNOTOPTEXP ] := ".T."
         aOpt[OPTFLT_CBNOTOPTEXP  ] := {||.T.}
      ELSE
         // Quando l'ottimizzatore riuscir… a separare la parte
         // NON ottimizzabile da ADS, andr… salvata qui.
         aOpt[OPTFLT_STRNOTOPTEXP ] := aOpt[OPTFLT_STREXP ]
         aOpt[OPTFLT_CBNOTOPTEXP  ] := aOpt[OPTFLT_CBEXP ]
      ENDIF
   ELSE
      // Errore
      aOpt[OPTFLT_STROPTEXP ] := ".T."
      aOpt[OPTFLT_CBOPTEXP  ] := {|| .T. }
      aOpt[OPTFLT_STRNOTOPTEXP ] := aOpt[OPTFLT_STREXP ]
      aOpt[OPTFLT_CBNOTOPTEXP  ] := aOpt[OPTFLT_CBEXP ]
   ENDIF


RETURN .T.

// Funzioni che ritornano vari parametri dfOptFltGetXXX()
// possono essere usate dopo aver chiamato la 
// dfOptFltOptimize() o OPTIMIZE FILTER che Š la stessa cosa
// ----------------------------------------------------------

// Espressione ottimizzata
FUNCTION dfOptFltGetString(aOpt); RETURN aOpt[OPTFLT_STROPTEXP]

// Codeblock dell'espressione ottimizzata
FUNCTION dfOptFltGetCB(aOpt); RETURN aOpt[OPTFLT_CBOPTEXP]

// codice di errore in ottimizzazione
FUNCTION dfOptFltGetErrNum(aOpt); RETURN aOpt[OPTFLT_ERRNUM]

// messaggio di errore in ottimizazione
FUNCTION dfOptFltGetErrMsg(aOpt); RETURN aOpt[OPTFLT_ERRMESSAGE]

// Elenco funzioni non ottimizzabili (non presenti nella lista funzioni ADS)
// se Š vuoto vuol dire che il filtro Š stato tutto ottimizzato e il codeblock
// di filtro da usare nel successivo ciclo di scansione del DB Š inutile.
FUNCTION dfOptFltGetNotOptFunc(aOpt); RETURN aOpt[OPTFLT_NOTOPTFUNC]

// Espressione ottimizzata
FUNCTION dfOptFltGetNotOptString(aOpt); RETURN aOpt[OPTFLT_STRNOTOPTEXP]

// Codeblock dell'espressione ottimizzata
FUNCTION dfOptFltGetNotOptCB(aOpt); RETURN aOpt[OPTFLT_CBNOTOPTEXP]


// ------------------------------------------------------------------------
// Interprete
// ------------------------------------------------------------------------

CLASS dfExpressionOptimizerADS FROM dfExpressionOptimizer
   EXPORTED 
      INLINE METHOD Init(lShort, lAllFunc, lDelBA, aUDF, nMax)


          DEFAULT lShort   TO .T.
          DEFAULT lAllFunc TO .F.
          DEFAULT lDelBA   TO .T.
          DEFAULT aUDF     TO {}

          dfOptFltADSFunSet(aUDF)

          ::dfExpressionOptimizer:init(lShort, lAllFunc, lDelBA, aUDF, nMax)
          // elimina alias non ottimizz.
          // perche il server ADS non sa cosa sono!
          ::nDelNotOptAlias    := NOTOPTALIAS_DELETE 
      RETURN self
          
ENDCLASS

CLASS dfExpressionOptimizer
   PROTECTED 
      VAR nTokType 
      VAR nTokCmd 
      VAR cToken 

      VAR aVar 
      VAR cProg 
      VAR nIdx 
      VAR cErrToken 
      VAR nError   
      VAR bVarAccess 

      VAR xRetVal  
      VAR cBaseAlias 
      VAR aNotOptFunc 
      VAR bInitCB

      // Variabili per gestione alias ottimizzabili:
      // un alias Š ottimizzabile se invece del suo nome pu• essere preso
      // il valore del campo
      // ES: con alias base DOCMOVD
      //   docmovd->tipart==seledoc->tipart 
      // potrebbe diventare 
      //   "tipart=='A'" (se ottimizzato) oppure 
      //   "tipart==seledoc->tipart" (se NON ottimizzato)


      VAR nDelNotOptAlias    // Decide cosa fare quando un alias non Š ottimizzab.
                             // se = NOTOPTALIAS_MANTAIN gli alias non ottimizzabili rimangono
                             // nella stringa di output
                             // se = NOTOPTALIAS_DELETE gli alias non ottimizzabili vengono
                             // tolti dalla stringa di output


      // aOptAlias e lAutoNotOptAlias servono per decidere SE un alias Š ottimiz.

      // Elenco degli alias che pu• ottimizzare (es. SELEDOC, SELEANA, ecc.)
      // perche il puntatore su questi ALIAS non si sposta durante il filtro
      VAR aOptAlias

      VAR lAutoNotOptAlias   // disabilita la gestione automatica alias
                             // non ottimizzabili. 
                             // Attenzione se = .T. allora il default Š
                             // di considerare tutto ottimizzabile tranne
                             // quello che non Š esplicitamente NON ottimizzabile!


      // Se ::lAutoNotOptAlias == .T. allora
      // ::aNotOptAlias Š gestita in automatico nella ::CallFunc() 
      // e contiene Alias non ottimizzabili perche sull'alias
      // Š usata una funzione che presumibilmente pu• spostare 
      // il puntatore 
      // esempio il filtro:
      //   docmovd->tipart==seledoc->tipart .and. 
      //   articol->(dfS(1, docmovd->tipart+docmovd->codart)) .and.
      //   articol->codart>'AAA'
      // in questo caso seledoc->tipart deve essere sostituito con il
      // valore del campo ma articol->codart NO
      //
      // quindi se ::nDelNotOptAlias == NOTOPTALIAS_DELETE deve diventare
      //    docmovd->tipart=='A'
      //
      // oppure se ::nDelNotOptAlias == NOTOPTALIAS_MANTAIN deve diventare
      //   docmovd->tipart=='A' .and. 
      //   articol->(dfS(1, docmovd->tipart+docmovd->codart)) .and.
      //   articol->codart>'AAA'
      VAR aNotOptAlias

      VAR lOptimizeExp       // Abilita ottimizzazione espressioni
                             // se .T. la stringa "A"+"B" < anagraf->ragsoc1
                             // diventa "AB" < anagraf->ragsoc1

      VAR aUDFFunc           // elenco funzioni da tradurre in modo particolare
      VAR lShortCircuit      // abilita ottimizzazione "short-circuit" 
                             // (.T. .OR. qualcosa) diventa subito .T.
      VAR lDelBaseAlias      // mantiene l'alias di base nella stringa
                             // se .F. e alias base=EFFETTI allora
                             // effetti->tipana diventa TIPANA 
      VAR lAllowAllFunctions // Abilita l'uso di tutte le funzioni o solo
                             // delle funzioni impostate in ::aUDFFunc
      VAR nMaxStringLen      // lunghezza max stringa di output

      METHOD ClearVars()

      METHOD _Var2Char()

      METHOD SetVarValue()
      METHOD FindVar()
      METHOD FindVarPos()
      METHOD FindExtVar()
      METHOD SetExtVar()

      METHOD GetField()
      METHOD SetFieValue()

      METHOD isAlpha()
      METHOD isDigit()
      METHOD isWhite()
      METHOD isDelim()
      METHOD Lookup()
      METHOD PutBack()
//      METHOD CurrChar()
//      METHOD CurrCh()
      METHOD GetToken()
      METHOD _GetToken()
      METHOD SkipEOL()

      METHOD getExp()
      METHOD Level0()
      METHOD Level0b()
      METHOD Level1()
      METHOD Level2()
      METHOD Level3()
      METHOD Level4()
      METHOD Level5()
      METHOD Level6()
      METHOD Primitive()
      METHOD Arith()
      METHOD Arith2()
      METHOD LogicalNot()
      METHOD Unary()
      METHOD CallFunc()

      // Ritorna .T. se non Š un campo, nome var., nome funz.
      // NOTA: sbaglia alcuni casi tipo IsPrimitive('"X"+CODPROMAG')
//      INLINE METHOD IsPrimitive(xVal)
//         LOCAL cChk := UPPER(LEFT(ALLTRIM(xVal), 1))
//      RETURN !( (cChk >= "A" .AND. cChk <= "Z") .OR. cChk == "_" .OR. cChk == "(") .OR.;
//             xVal == "NIL" .OR. (LEFT(xVal, 6)) == 'STOD("' 


      INLINE METHOD IsPrimitive(xVal)
         LOCAL nTokType := 0
         LOCAL nTokCmd  := 0
         LOCAL cToken   := ""
         LOCAL nIdx     := 1
         LOCAL lRet     := .T.

         xVal += CRLF

         DO WHILE .T.

            nTokType := ::_GetToken(@xVal, NIL, ;
                                    @nTokCmd, @nIdx, @cToken)

            IF nTokType == DELIMITER .AND. ;
               (nTokCmd == CMD_FINISHED .OR. nTokCmd == CMD_EOL)
               EXIT
            ENDIF

            IF nTokType == VARIABLE  .OR. ;
               nTokType == ARRAY_IDX .OR. ;
               nTokType == FIELDVAR  .OR. ;
               nTokType == ALIAS_VAR .OR. ;
               nTokType == ALIAS_FUN

               lRet := .F.
               EXIT
            ENDIF

            // E' la funzione STOD()???
            IF nTokType == FUNCTIONCALL 
                IF UPPER(cToken) == "STOD"

                   nTokType := ::_GetToken(@xVal, NIL, ;
                                           @nTokCmd, @nIdx, @cToken)
                   // Controlla la "("
                   IF ! (nTokType == DELIMITER .AND. cToken == "(")
                      lRet := .F.
                      EXIT
                   ENDIF

                   nTokType := ::_GetToken(@xVal, NIL, ;
                                           @nTokCmd, @nIdx, @cToken)

                   // Deve essere una stringa, altrimenti esce
                   IF ! nTokType == QUOTE
                      lRet := .F.
                      EXIT
                   ENDIF

                   nTokType := ::_GetToken(@xVal, NIL, ;
                                           @nTokCmd, @nIdx, @cToken)
                   // Controlla la ")"
                   IF ! (nTokType == DELIMITER .AND. cToken == ")")
                      lRet := .F.
                      EXIT
                   ENDIF
                ELSE
                   // Non Š la funzione STOD, esco!
                   lRet := .F.
                   EXIT
                ENDIF
            ENDIF

         ENDDO
      RETURN lRet

//      INLINE METHOD IsString(xVal)
//         LOCAL cChk := ALLTRIM(xVal)
//      RETURN LEFT(cChk, 1) $ CHR(34)+CHR(39) // Š un " o '

      INLINE METHOD IsString(xVal)
         LOCAL nTokType := 0
         LOCAL nTokCmd  := 0
         LOCAL cToken   := ""
         LOCAL nIdx     := 1
         LOCAL lRet     := .T.

         xVal += CRLF

         nTokType := ::_GetToken(@xVal, NIL, ;
                                 @nTokCmd, @nIdx, @cToken)

      RETURN nTokType == QUOTE .AND. SUBSTR(xVal, nIdx) == CRLF

         

      METHOD _ChkEmpty


   EXPORTED
      METHOD Init
      METHOD Optimize
      METHOD GetErrMsg
 
      INLINE METHOD SetMaxStringLen(n)
         LOCAL nOld := ::nMaxStringLen
         IF VALTYPE(n)=="N" 
            ::nMaxStringLen := IIF( n >= 0, n, -1)
         ENDIF
      RETURN nOld

      INLINE METHOD SetInitCB(b)
         LOCAL bOld := ::bInitCB
         IF VALTYPE(b)=="B" 
            ::bInitCB := b
         ENDIF
      RETURN bOld

      INLINE METHOD SetOptAlias(a)
         LOCAL aOld := ::aOptAlias
         IF VALTYPE(a)=="A" 
            ::aOptAlias := a
         ENDIF
      RETURN aOld

      INLINE METHOD getNotOptFunc(); RETURN ::aNotOptFunc

      // Torna il valore di ritorno dello script
      INLINE METHOD GetRetValue(); RETURN IIF(EMPTY(::xRetVal), ".T.", ::xRetVal)

      METHOD _LocalExecute

      METHOD _Empty
      METHOD _Alltrim
      METHOD _Upper
      METHOD _IIF
      METHOD _Eval
      METHOD _FIELDPOS
      METHOD _FIELDNAME

ENDCLASS

METHOD dfExpressionOptimizer:Init(lShort, lAllFunc, lDelBA, aUDF, nMax)
   DEFAULT lShort   TO lShortCircuit
   DEFAULT lAllFunc TO lAllowAllFunctions
   DEFAULT lDelBA   TO lDelBaseAlias

   // Simone 2/10/03 gerr 3929
   // USO ACLONE altrimenti dopo 2 chiamate a _EVAL
   // dello stesso CB perdo il contesto!
   DEFAULT aUDF     TO ACLONE(aUDFFunc)
   DEFAULT nMax     TO -1

   ::lShortCircuit      := lShort
   ::lAllowAllFunctions := lAllFunc
   ::lDelBaseAlias      := lDelBA
   ::aUDFFunc           := aUDF
   ::nMaxStringLen      := nMax
   ::bInitCB            := NIL
   ::aOptAlias          := {}
   ::lAutoNotOptAlias   := .F. // per default non abilita
   ::lOptimizeExp       := .T.
   ::nDelNotOptAlias    := NOTOPTALIAS_MANTAIN // per default mantiene alias non ottimizz.

   // sostituisco le funzioni std
   dfOptFltUDF("EMPTY", {|aParam|::_Empty(aParam)}, ::aUDFFunc )
   dfOptFltUDF("UPPER", {|aParam|::_Upper(aParam)}, ::aUDFFunc )
   dfOptFltUDF("ALLTRIM", {|aParam|::_Alltrim(aParam)}, ::aUDFFunc )
   dfOptFltUDF("EVAL", {|aParam|::_Eval(aParam)}, ::aUDFFunc )
   dfOptFltUDF("IIF", {|aParam|::_IIF(aParam)}, ::aUDFFunc )
   dfOptFltUDF("IF", {|aParam|::_IIF(aParam)}, ::aUDFFunc )
   dfOptFltUDF("FIELDPOS", {|aParam|::_FIELDPOS(aParam)}, ::aUDFFunc )
   dfOptFltUDF("FIELDNAME", {|aParam|::_FIELDNAME(aParam)}, ::aUDFFunc )
RETURN self

METHOD dfExpressionOptimizer:Optimize( cString, cAlias, aVariab, bVarAcc )
   LOCAL nRet := S2SCR_OK
   LOCAL cLine := ""
   LOCAL nPos := 0
   LOCAL nInd := 0
   LOCAL _aVar, xVal

  #ifdef DEBUG
   altd()
  #endif

   ::ClearVars()
   ::xRetVal  := NIL
   ::cErrToken := ""
   ::nError   := S2SCR_OK
   ::aNotOptFunc := {}

   IF cAlias != NIL
      ::cBaseAlias := UPPER(ALLTRIM(cAlias))
   ENDIF
   ::bVarAccess := bVarAcc

   // Imposto le funzioni che posso passare direttamente ad ADS (ALLTRIM, ecc)
   // o che posso gestire localmente (S2CHKRANGE, ecc)

   // Imposto le variabili senza modificare
   // l'array passato perche altrimenti se viene
   // ripassato tramite la _EVAL l'array delle 
   // variabili viene modificato pi— volte
   FOR nInd := 1 TO LEN(aVariab)
      _aVar := aVariab[nInd]
      xVal := _aVar[2]

//      IF VALTYPE(xVal) == "B"
//         xVal := EVAL( xVal ) 
//      ENDIF
//      ::SetVarValue(UPPER(ALLTRIM(_aVar[1])), xVal)
        ::SetVarValue(_aVar[1], xVal)
   NEXT

   BEGIN SEQUENCE

      IF EMPTY(cString)   // Programma vuoto: OK
         BREAK S2SCR_OK
      ENDIF

      // Aggiungo il termine riga
      cString += CRLF
      ::cProg := cString

      ::nTokCmd := CMD_EOL

      ::getExp(@cLine)
      ::xRetVal := cLine

   RECOVER USING nRet

      ::nError := nRet
      IF ! nRet == S2SCR_OK           // Se c'e' un errore imposta la linea
         ::cErrToken := ::cToken
      ENDIF

   END SEQUENCE

   ::ClearVars()

RETURN nRet

METHOD dfExpressionOptimizer:GetErrMsg( nErr )
   LOCAL cRet := ""
   LOCAL aErr := {                                   ;
                   "File non trovato"              , ;
                   "Errore di sintassi"            , ;
                   "Parentesi non bilanciate"      , ;
                   "Nessuna espressione presente"  , ;
                   "Segno = atteso"                , ;
                   "Non una variabile"             , ;
                   "Tipi di dati non compatili"    , ;
                   "ENDIF non trovato"             , ;
                   "TO atteso"                     , ;
                   "Database non in uso"           , ;
                   "Struttura di controllo non chiusa", ;
                   "Campo non trovato"             , ;
                   "Non e' un'espressione logica"  , ;
                   "Non e' un array"               , ;
                   "Indice di array fuori dai limiti" ;
                 }
                 //  "Label doppia"                  , ;
                 //  "Label non definita"            , ;

   DEFAULT nErr TO ::nError

   nErr := ABS(nErr)

   IF nErr == S2SCR_OK
      cRet := "OK"

   ELSEIF nErr >= 1 .AND. nErr <= LEN(aErr)
      cRet := aErr[ ABS(nErr) ] + " : "+::cErrToken

   ELSE
      cRet := "Errore non riconosciuto "+STR(nErr) + ;
              + " : "+::cErrToken
   ENDIF

RETURN cRet



METHOD dfExpressionOptimizer:ClearVars()

   ::nTokType    := 0
   ::nTokCmd     := 0
   ::cToken      := ""

   ::aVar        := {}

   ::cProg       := ""
   ::nIdx        := 1
   ::cBaseAlias  := NIL
   ::aNotOptAlias := {}
RETURN


METHOD dfExpressionOptimizer:SetVarValue(cVar, xVal)
   LOCAL nPos
   cVar := UPPER(ALLTRIM(cVar))

   nPos := ::FindVarPos(cVar)

   IF nPos == 0
      IF ::FindExtVar(cVar)
         ::SetExtVar(cVar, xVal)
      ELSE
         AADD( ::aVar, {UPPER(cVar), xVal, VALTYPE(xVal)} )
      ENDIF
   ELSE
      ::aVar[nPos][2] := xVal
      ::aVar[nPos][3] := VALTYPE(xVal)
   ENDIF
RETURN nPos
//METHOD dfExpressionOptimizer:SetVarValue(cVar, xVal)
//   LOCAL nPos := ::FindVarPos(cVar)
//
//   IF nPos == 0
//      IF ::FindExtVar(cVar)
//         ::SetExtVar(cVar, xVal)
//      ELSE
//         AADD( ::aVar, {UPPER(cVar), xVal} )
//      ENDIF
//   ELSE
//      ::aVar[nPos][2] := xVal
//   ENDIF
//RETURN nPos

METHOD dfExpressionOptimizer:SetFieValue(cVar, xVal)
   LOCAL nPos := FIELDPOS(cVar)

   IF nPos == 0
      BREAK S2SCR_ERR_FIELDNOTFOUND
   ELSE
      FIELDPUT(nPos, xVal)
   ENDIF
RETURN

// ------------------------------------------------------------------------
// Parser
// ------------------------------------------------------------------------

METHOD dfExpressionOptimizer:SkipEOL()
   IF ::nTokType == DELIMITER .AND. ::cToken == ";"
      ::GetToken()
      IF ::nTokType == DELIMITER .AND. ::nTokCmd == CMD_EOL
         ::GetToken()
      ENDIF
   ENDIF
RETURN

METHOD dfExpressionOptimizer:GetExp(xVal)
   ::GetToken()
   ::SkipEOL()
   IF ::cToken == "" .AND. ! ::nTokType == QUOTE

      // Se non Š la stringa vuota errore
      BREAK S2SCR_ERR_MANCAESPRESS

   ENDIF

   ::Level0( @xVal )
   ::PutBack()

RETURN

// Processa AND e OR
METHOD dfExpressionOptimizer:Level0( xVal )
   LOCAL xHold := 0
   LOCAL cOp := ""

   ::Level0b( @xVal )
   DO WHILE ::nTokType == COMMAND .AND. ;
            (::nTokCmd == CMD_AND .OR. ::nTokCmd == CMD_OR)
      cOp := ::cToken
      ::GetToken()
      ::SkipEOL()
      ::Level0b( @xHold )
/*
      IF xVal  == ""
         xVal  := ".T."
      ENDIF
      IF xHold == ""
         xHold := ".T."
      ENDIF
*/
      ::arith( cOp, @xVal, @xHold )
   ENDDO

RETURN

// NOT logico
METHOD dfExpressionOptimizer:Level0b( xVal )
   LOCAL xHold := 0
   LOCAL cOp := ""

   IF (::nTokType == COMMAND   .AND. ::nTokCmd == CMD_NOT) .OR. ;
      (::nTokType == DELIMITER .AND. ::cToken == "!")

      cOp := ::cToken
      ::GetToken()
      ::SkipEOL()
   ENDIF

   ::Level1( @xVal )
   IF ! cOp == "" .AND. ! xVal == ""
      ::LogicalNot(@xVal)
   ENDIF
RETURN


// Processa "<", ">", "<=", ">=", "<>", "#", "!=", "$"
METHOD dfExpressionOptimizer:Level1( xVal )
   LOCAL xHold := 0
   LOCAL cOp := ""

   ::Level2( @xVal )
   DO WHILE ::nTokType == DELIMITER .AND. ::cToken $ "<=>!#$"

      cOp := ::cToken

      IF ::cToken $ "<=>!"
         // guardo se c'e' un un altro carattere (<=, >=, <>)
         ::GetToken()
         IF ::nTokType == DELIMITER .AND. ;
            ( ::cToken == "=" .OR. (cOp $ "<=" .AND. ::cToken == ">") .OR. ;
              (cOp == "=" .AND. ::cToken == "<") )

            cOp += ::cToken
         ELSE
            ::PutBack()
         ENDIF
      ENDIF

      ::GetToken()
      ::SkipEOL()
      ::Level2(@xHold)
      ::arith( cOp, @xVal, @xHold )
   ENDDO
RETURN

// Aggiunge o sottrae 2 termini
METHOD dfExpressionOptimizer:Level2( xVal )
   LOCAL xHold := 0
   LOCAL cOp := ""

   ::Level3( @xVal )
   DO WHILE ::nTokType == DELIMITER .AND. (::cToken == "+" .OR. ::cToken == "-")

      cOp := ::cToken
      ::GetToken()
      ::SkipEOL()
      ::Level3( @xHold )
      ::arith( cOp, @xVal, @xHold )
   ENDDO
RETURN

// Moltiplica o divide 2 fattori
METHOD dfExpressionOptimizer:Level3( xVal )
   LOCAL xHold := 0
   LOCAL cOp := ""

   ::Level4( @xVal )
   DO WHILE ::nTokType == DELIMITER .AND. ;
            (::cToken == "*" .OR. ::cToken == "/" .OR. ::cToken == "%")

      cOp := ::cToken
      ::GetToken()
      ::SkipEOL()
      ::Level4( @xHold )
      ::arith( cOp, @xVal, @xHold )
   ENDDO
RETURN

// Processa l'esponente intero
METHOD dfExpressionOptimizer:Level4( xVal )
   LOCAL xHold := 0

   ::Level5( @xVal )
   IF ::nTokType == DELIMITER .AND. ::cToken == "^"
      ::GetToken()
      ::SkipEOL()
      ::Level4( @xHold )
      ::arith( "^", @xVal, @xHold )
   ENDIF
RETURN

// + e - unari
METHOD dfExpressionOptimizer:Level5( xVal )
   LOCAL cOp := ""

   IF ::nTokType == DELIMITER .AND. (::cToken == "+" .OR. ::cToken == "-")
      cOp := ::cToken
      ::GetToken()
   ENDIF

   ::Level6( @xVal )
   IF ! cOp == ""
      ::Unary(cOp, @xVal )
   ENDIF
RETURN

// Processa un'espressione parentesizzata
METHOD dfExpressionOptimizer:Level6( xVal )
   IF ::nTokType == DELIMITER .AND. ::cToken == "("
      ::GetToken()
      ::SkipEOL()
      ::Level0( @xVal )
      IF ::nTokType != DELIMITER .OR. ::cToken != ")"
         BREAK S2SCR_ERR_MANCAPARENTESI
      ENDIF
      IF ! xVal == "" .AND. ;
         !( ::lShortCircuit .AND. ( xVal == ".T." .OR. xVal == ".F.") )
         xVal := "("+xVal+")"
      ENDIF
      ::GetToken()
      ::SkipEOL()
   ELSE
      ::Primitive( @xVal )
   ENDIF
RETURN

// Trova il valore di un numero o di una variabile
METHOD dfExpressionOptimizer:Primitive( xVal )
   LOCAL nSel := 0
   LOCAL cSave := NIL
   DO CASE
      CASE ::nTokType == COMMAND
         DO CASE
            CASE ::nTokCmd == CMD_NIL
               xVal := NIL

            CASE ::nTokCmd == CMD_TRUE
               xVal := .T.

            CASE ::nTokCmd == CMD_FALSE
               xVal := .F.

            OTHERWISE
               BREAK S2SCR_ERR_SYNTAX
         ENDCASE
         xVal := ::_Var2Char( xVal )

      CASE ::nTokType == VARIABLE
         xVal := ::FindVar(::cToken)
         xVal := ::_Var2Char( xVal )

      CASE ::nTokType == ARRAY_IDX
         xVal := ::FindVar(::cToken)

         IF VALTYPE(xVal) != "A"
            BREAK S2SCR_ERR_NOTARRAY
         ENDIF

         ::GetToken()                     // Salto la "["

         ::GetExp(@nSel)

         IF VALTYPE(nSel) $ "CM"  // riconverto in numero
            nSel := VAL(nSel)
         ENDIF

         IF ! VALTYPE(nSel) == "N"
            BREAK S2SCR_ERR_SYNTAX
         ENDIF

         IF nSel <= 0 .OR. nSel > LEN(xVal)
            BREAK S2SCR_ERR_SUBSCRIPTRANGE
         ENDIF

         ::GetToken()  // Salto la "]"
         IF ! (::nTokType == DELIMITER .AND. ::cToken == "]")
            BREAK S2SCR_ERR_SYNTAX
         ENDIF

         xVal := xVal[nSel]
         xVal := ::_Var2Char( xVal )

      CASE ::nTokType == NUMBER
           xVal := ::cToken
//         xVal := VAL( ::cToken )
//         xVal := ::_Var2Char( xVal )

      CASE ::nTokType == QUOTE
         xVal := ::cToken
         xVal := ::_Var2Char( xVal )

      CASE ::nTokType == FUNCTIONCALL .OR. ::nTokType == ALIAS_FUN
         xVal := ::CallFunc()

      CASE ::nTokType == FIELDVAR
         xVal := ::GetField(::cToken, ALIAS())

/*
         IF xVal == NIL
            xVal := "" // campo su alias non ottimizzabile
         ELSE
            xVal := ::_Var2Char( xVal )
            IF ALIAS() == ::cBaseAlias
               IF ::lDelBaseAlias
                  // archivio base torno solo il nomecampo!
                  xVal := ::cToken
               ELSE
                  // archivio base torno alias->nomecampo!
                  xVal := ::cBaseAlias+"->"+::cToken
               ENDIF
            ENDIF
         ENDIF
*/
      CASE ::nTokType == ALIAS_VAR
         cSave := ::cToken  // Alias
         ::GetToken(.F.)    // Nome campo
         xVal := ::GetField(::cToken, cSave)

/*
         cSave := NIL
         IF UPPER(ALLTRIM(::cToken)) == ::cBaseAlias
            // archivio base torno solo il nomecampo!
            cSave := .T.
         ENDIF

         IF SELECT(::cToken) > 0

            nSel := SELECT()
            DBSELECTAREA(::cToken)
            ::GetToken(.F.)

            IF cSave != NIL
               cSave := ::cToken
            ENDIF

            IF ! ::nTokType == FIELDVAR
               BREAK S2SCR_ERR_FIELDNOTFOUND
            ENDIF
            xVal := ::GetField(::cToken)
            IF xVal == NIL
               xVal := "" // campo su alias non ottimizzabile
            ELSE
                  
               DBSELECTAREA(nSel)

               IF cSave == NIL
                  xVal := ::_Var2Char( xVal )
               ELSE
                  IF ::lDelBaseAlias
                     // archivio base torno solo il nomecampo!
                     xVal := cSave
                  ELSE
                     // archivio base torno alias->nomecampo!
                     xVal := ::cBaseAlias+"->"+cSave
                  ENDIF
               ENDIF
            ENDIF
         ELSE
            BREAK S2SCR_ERR_DBNOTUSED
         ENDIF
*/
      OTHERWISE
         BREAK S2SCR_ERR_SYNTAX
   ENDCASE

   IF xVal == "NIL" // il NIL non Š supportato!
      BREAK S2SCR_ERR_TYPEMISMATCH
   ENDIF

   ::GetToken()
   ::SkipEOL()
RETURN

METHOD dfExpressionOptimizer:GetField(cField, cAlias)
   LOCAL nPos := 0
   LOCAL xVal := NIL
   LOCAL nSel := SELECT()

   cAlias := UPPER(ALLTRIM(cAlias))
   cField := UPPER(ALLTRIM(cField))

   IF SELECT(cAlias) == 0
      BREAK S2SCR_ERR_DBNOTUSED
   ENDIF

   DBSELECTAREA(cAlias)

   nPos := FIELDPOS(cField)
   IF nPos == 0
      BREAK S2SCR_ERR_FIELDNOTFOUND
   ENDIF

   IF cAlias == ::cBaseAlias  // E' un campo dell'alias di base

      IF ::lDelBaseAlias
         // archivio base torno solo il nomecampo!
         xVal := cField
      ELSE
         // archivio base torno alias->nomecampo!
         xVal := cAlias+"->"+cField
      ENDIF

   ELSEIF ASCAN(::aOptAlias, {|x| x==cAlias}) > 0 .OR.; // Se Š' un alias ottimizzabile oppure 
         ( ::lAutoNotOptAlias .AND. ;                   // Se Ho attivato AutoNotOptAlias e
           ASCAN(::aNotOptAlias, {|x| x==cAlias}) == 0) // non appartiene ad alias non ottim.

      // Se Š un alias ottimizzabile torno il valore del campo
      xVal := FIELDGET(nPos)
      xVal := ::_Var2Char( xVal )

   ELSE

      // se non Š ottimizzabile ho 2 strade
      // - torno ""
      // - torno alias->campo

      IF ::nDelNotOptAlias == NOTOPTALIAS_MANTAIN
         // torno alias->nomecampo!
         xVal := cAlias+"->"+cField
      ELSE 
         xVal := ""

         IF EMPTY(::aNotOptFunc) // per obbligare ad impostare il codeblock di filtro
            AADD(::aNotOptFunc, "__EXPR_LEN_OVERFLOW__")
         ENDIF
      ENDIF

   ENDIF

   DBSELECTAREA(nSel)

RETURN xVal

METHOD dfExpressionOptimizer:Arith(cOp, xLeft, xRight)
   LOCAL a := {xLeft, xRight}
   cOp := UPPER(ALLTRIM(cOp))

   IF xLeft == "" .OR. xRight == ""
      // e' stata chiamata una funzione NON abilitata
      //IF ::lShortCircuit
         IF cOp == ".AND."
            IF xLeft == ""
               xLeft := xRight
            ENDIF
         ELSE
            xLeft := ""
         ENDIF
      //ENDIF

   ELSE
      IF ::lShortCircuit
         IF cOp == ".OR."
            IF xLeft == ".T." .OR. xRight == ".T."
               xLeft := ".T."

            ELSEIF xLeft == ".F." .AND. xRight == ".F."
               xLeft := ".F."
            ELSEIF xLeft == ".F." 
                xLeft := xRight
            ELSEIF ! xRight == ".F." 
               ::arith2(cOp, @xLeft, @xRight)
               //xLeft := xLeft + " "+ cOp +" "+ xRight //::_Var2Char(xRight)
            ENDIF

         ELSEIF cOp == ".AND."
            IF xLeft == ".F." .OR. xRight == ".F."
               xLeft := ".F."
            ELSEIF xLeft == ".T." .AND. xRight == ".T."
               xLeft := ".T."
            ELSEIF xLeft == ".T." 
                xLeft := xRight
            ELSEIF ! xRight == ".T." 
               ::arith2(cOp, @xLeft, @xRight)

               //xLeft := xLeft + " "+ cOp +" "+ xRight 
            ENDIF
         ELSE
            ::arith2(cOp, @xLeft, @xRight)
            //xLeft := xLeft + " "+ cOp +" "+ xRight 
         ENDIF

      ELSE
         ::arith2(cOp, @xLeft, @xRight)
         //xLeft := xLeft + " "+ cOp +" "+ xRight 
      ENDIF
   ENDIF

   IF cOp == ".AND." .AND. ::nMaxStringLen != -1 .AND. LEN(xLeft) > ::nMaxStringLen
      xLeft := IIF(EMPTY(a[1]), a[2], a[1])

      IF EMPTY(::aNotOptFunc) // per obbligare ad impostare il codeblock di filtro
         AADD(::aNotOptFunc, "__EXPR_LEN_OVERFLOW__")
      ENDIF
   ENDIF

RETURN 

// VALUTA I DATI 
METHOD dfExpressionOptimizer:arith2(cOp, xLeft1, xRight1)
   LOCAL xLeft, xRight

   IF ! ::lOptimizeExp .OR. ;
      ! (::isPrimitive(xLeft1) .AND. ::isPrimitive(xRight1))

      IF cOp == "$" // Per correzione errore Xbase su SET FILTER "x $ y" -> AT(x, y) >0
         xLeft1 := "(AT("+ xLeft1 + ","+ xRight1+") > 0)"
      ELSE
         xLeft1 := xLeft1 + cOp + xRight1
      ENDIF
      RETURN

   ENDIF

   xLeft := &(xLeft1)
   xRight := &(xRight1)

   DO CASE
      CASE cOp == "+"
         IF (VALTYPE(xLeft) == "C" .AND. VALTYPE(xRight) == "C") .OR. ;
            (VALTYPE(xLeft) == "N" .AND. VALTYPE(xRight) == "N") .OR. ;
            (VALTYPE(xLeft) == "D" .AND. VALTYPE(xRight) == "N")

            xLeft := xLeft + xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == "-"
         IF (VALTYPE(xLeft) == "N" .AND. VALTYPE(xRight) == "N") .OR. ;
            (VALTYPE(xLeft) == "D" .AND. VALTYPE(xRight) == "N")

            xLeft := xLeft - xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == "*"
         IF (VALTYPE(xLeft) == "N" .AND. VALTYPE(xRight) == "N")

            xLeft := xLeft * xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == "/"
         IF (VALTYPE(xLeft) == "N" .AND. VALTYPE(xRight) == "N")

            xLeft := xLeft / xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == "%"
         IF (VALTYPE(xLeft) == "N" .AND. VALTYPE(xRight) == "N")

            xLeft := xLeft % xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == "^"
         IF (VALTYPE(xLeft) == "N" .AND. VALTYPE(xRight) == "N")

            xLeft := xLeft ^ xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == "$"
         IF (VALTYPE(xLeft) == "C" .AND. VALTYPE(xRight) == "C")
            xLeft := xLeft $ xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == "<"
         IF (VALTYPE(xLeft) == VALTYPE(xRight))
            xLeft := xLeft < xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == "<=" .OR. cOp == "=<"
         IF (VALTYPE(xLeft) == VALTYPE(xRight))
            xLeft := xLeft <= xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == ">"
         IF (VALTYPE(xLeft) == VALTYPE(xRight))
            xLeft := xLeft > xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == ">=" .OR. cOp == "=>"
         IF (VALTYPE(xLeft) == VALTYPE(xRight))
            xLeft := xLeft >= xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == "=" .OR. cOp == "=="
         IF (VALTYPE(xLeft) == VALTYPE(xRight))
            xLeft := xLeft == xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == "<>" .OR. cOp == "#" .OR. cOp == "!="
         IF (VALTYPE(xLeft) == VALTYPE(xRight))
            xLeft := ! xLeft == xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == ".AND."
         IF (VALTYPE(xLeft) == "L" .AND. VALTYPE(xRight) == "L")
            xLeft := xLeft .AND. xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      CASE cOp == ".OR."
         IF (VALTYPE(xLeft) == "L" .AND. VALTYPE(xRight) == "L")
            xLeft := xLeft .OR. xRight
         ELSE
            BREAK S2SCR_ERR_TYPEMISMATCH
         ENDIF

      OTHERWISE
         BREAK S2SCR_ERR_SYNTAX
   ENDCASE

   xLeft1 := ::_VAR2CHAR(xLeft)

RETURN


METHOD dfExpressionOptimizer:Unary(cOp, xVal)
   IF ! xVal == ""
      xVal := " -"+xVal 
   ENDIF
RETURN

METHOD dfExpressionOptimizer:LogicalNot(xVal)
//   IF xVal == ""
//      xVal := ".T."
//   ELSE
//      xVal := " .NOT. "+xVal 
//   ENDIF
   IF ::lShortCircuit .AND. (xVal == ".T." .OR. xVal == ".F.")
      IF xVal == ".T."
         xVal := ".F."
      ELSE
         xVal := ".T."
      ENDIF
   ELSE
      xVal := " .NOT.("+xVal+")"
   ENDIF
RETURN

METHOD dfExpressionOptimizer:FindVar( cVar )
   LOCAL nPos := 0


   IF ! ::IsAlpha(LEFT(cVar, 1))
      BREAK S2SCR_ERR_NONVARIAB
   ENDIF

   nPos := ::FindVarPos(cVar)
   IF nPos == 0
      IF ::FindExtVar(cVar)
         RETURN ::SetExtVar(cVar)
      ENDIF

      BREAK S2SCR_ERR_NONVARIAB
   ENDIF

RETURN IIF(::aVar[nPos][3]=="B", EVAL(::aVar[nPos][2]), ::aVar[nPos][2])

METHOD dfExpressionOptimizer:FindVarPos( cVar )
   cVar := UPPER(cVar)
RETURN ASCAN(::aVar, {|x| x[1] == cVar })

METHOD dfExpressionOptimizer:FindExtVar(cVar)
   cVar := UPPER(cVar)
RETURN ::bVarAccess != NIL .AND. EVAL(::bVarAccess, cVar) != NIL

METHOD dfExpressionOptimizer:SetExtVar(cVar, xVal)
   cVar := UPPER(cVar)
   IF ! ::FindExtVar(cVar)
      RETURN NIL
   ENDIF
   IF VALTYPE(xVal)=="B"
      xVal := EVAL(xVal)
   ENDIF
RETURN EVAL(::bVarAccess, cVar, xVal)


// Chiama una funzione di Clipper
METHOD dfExpressionOptimizer:CallFunc()
   LOCAL xRet      := NIL
   LOCAL xVal      := ""
   LOCAL nInd      := 0
   LOCAL nSel      := NIL
   LOCAL cFuncName := ""
   LOCAL nNumPar   := 0
   LOCAL bEval     := NIL
   LOCAL lOk       := .F.
   LOCAL aParam    := {}
   LOCAL nInternal := 0
   LOCAL lBaseFun  := .F.
   LOCAL cAlias    := ""
   LOCAL lAddAlias := .F.
   LOCAL lIsFunc   := .T.
   LOCAL lParamErr := .F.
   LOCAL cLocalExecFunc:= ""
    
   IF ::nTokType == ALIAS_FUN .AND. UPPER(ALLTRIM(::cToken)) == ::cBaseAlias
      cAlias := IIF(::lDelBaseAlias, "", ::cBaseAlias)
      lBaseFun := .T.
      ::GetToken()
      IF ! ::nTokType == FUNCTIONCALL
         BREAK S2SCR_ERR_SYNTAX
      ENDIF
   ENDIF

   IF ::nTokType == ALIAS_FUN .AND. ! lBaseFun
      IF SELECT(::cToken) > 0
         cAlias := ::cToken
         nSel := SELECT()
         DBSELECTAREA(::cToken)
         ::GetToken()
         IF ! ::nTokType == FUNCTIONCALL
            BREAK S2SCR_ERR_SYNTAX
         ENDIF
      ELSE
         BREAK S2SCR_ERR_DBNOTUSED
      ENDIF
   ENDIF
   cFuncName := UPPER(::cToken)

   lIsFunc := IsFunction(cFuncName)
   // Simone 21/09/09 XL 1352
   // aggiunta possibilit… di definire delle funzioni come 
   // da eseguirle immediatamente e non nel filtro
   // prefisso per esecuzione immediata
   // esempio: _LOCALEXECUTE_S2SysDat()
   IF UPPER(LEFT(cFuncName, 11))=="_LOCALEXEC_" 
      cLocalExecFunc:= SUBSTR(cFuncName, 12)
   ENDIF

   //IF ::lAllowAllFunctions .OR. lBaseFun
      nInternal := ASCAN(::aUDFFunc, {|x| IIF(VALTYPE(x)=="A", x[1], x) == cFuncName })
   //ENDIF

//   IF nInternal == 0 .AND. !(::lAllowAllFunctions .AND. lIsFunc)
//      AADD(::aNotOptFunc, cFuncName)
//   ENDIF

   // Controlla la "("
   ::GetToken()
   IF ! (::nTokType == DELIMITER .AND. ::cToken == "(")
      BREAK S2SCR_ERR_SYNTAX
   ENDIF

   IF ! lBaseFun .AND. ! EMPTY(cAlias)
      cFuncName := cAlias+"->("+UPPER(cFuncName)
      IF ::lAutoNotOptAlias
         AADD(::aNotOptAlias, UPPER(ALLTRIM(cAlias)))
      ENDIF
   ENDIF

   cFuncName += "("

   // Cerco la ")"
   nInd := ::nIdx

   DO WHILE ::isWhite( ::cProg[nInd] ) //::CurrCh(nInd) )
      nInd++
   ENDDO

   nNumPar := 0

   IF ::cProg[nInd] == ")" //::CurrCh(nInd) == ")"

      // Se c'e' la ")" la salto
      ::GetToken()

   ELSE

      // Se non c'e' la ")" prende i parametri
      DO WHILE .T.

         ::GetExp(@xVal)

         IF xVal == ""  // uno dei parametri Š NON gestibile
            lParamErr := .T.
         ENDIF

         AADD(aParam, xVal)
         nNumPar++
         cFuncName += xVal

         // Se dopo c'e' la ")" esce
         ::GetToken()
         IF ::nTokType == DELIMITER .AND. ::cToken==")"
            EXIT
         ENDIF

         // Se non c'e' la "," errore
         IF !( ::nTokType == DELIMITER .AND. ::cToken == "," )
            BREAK S2SCR_ERR_SYNTAX
         ENDIF

         // Prende il prossimo parametro
         cFuncName += ","
      ENDDO

   ENDIF

   IF nSel != NIL .OR. lBaseFun

      // Se era un alias cerco la ")" finale
      ::GetToken()
      IF ! (::nTokType == DELIMITER .AND. ::cToken==")")
         BREAK S2SCR_ERR_SYNTAX
      ENDIF
   ENDIF

   cFuncName += ")"
   IF ! EMPTY(cAlias)
      cFuncName += ")"
   ENDIF

   IF lParamErr // errore in un parametro, salto tutta la funzione
      xRet := ""

   ELSEIF ! EMPTY(cLocalExecFunc)
      // Simone 21/09/09 XL 1352
      // aggiunta possibilit… di definire delle funzioni come 
      // da eseguirle immediatamente e non nel filtro
      // esegue immediatamente
      xRet := ::_LocalExecute(cLocalExecFunc, aParam)

   ELSEIF nInternal == 0 .AND. ::lAllowAllFunctions .AND. lIsFunc
      xRet := cFuncName

   ELSEIF nInternal == 0
      xRet := ""

   ELSEIF VALTYPE(::aUDFFunc[nInternal]) == "A"
      xRet := EVAL(::aUDFFunc[nInternal][2], aParam)

   ELSE
      xRet := cFuncName

   ENDIF

   IF xRet == ""
      AADD(::aNotOptFunc, cFuncName)
   ENDIF

   IF nSel != NIL
      DBSELECTAREA(nSel)
   ENDIF
RETURN xRet

METHOD dfExpressionOptimizer:GetToken(lPreferVARS)
   ::nTokType := ::_GetToken(@::cProg, lPreferVARS, ;
                             @::nTokCmd, @::nIdx, @::cToken)
RETURN ::nTokType

//   LOCAL nTemp := 0
//
//   DEFAULT lPreferVARS TO .T.
//
//   ::nTokType := 0
//   ::nTokCmd := 0
//
//   IF ::nIdx > LEN( ::cProg )
//      ::cToken := ""
//      ::nTokCmd := CMD_FINISHED
//      ::nTokType := DELIMITER
//      RETURN ::nTokType
//   ENDIF
//
//   DO WHILE ::isWhite( ::CurrChar() )
//      ::nIdx++
//   ENDDO
//
//   IF ::CurrChar() == CR  // CRLF
//      ::nIdx++
//      ::nIdx++
//
//      ::nTokCmd := CMD_EOL
//      ::cToken := CRLF
//      ::nTokType := DELIMITER
//      RETURN ::nTokType
//   ENDIF
//
//   IF ::CurrChar() $ "+-*^/%=;:(),><!$[]{|}"
//
//      ::cToken := ::CurrChar()
//      ::nTokType := DELIMITER
//
//      ::nIdx++
//      RETURN ::nTokType
//   ENDIF
//
//   IF ::CurrChar() == '"'  // Stringa
//      ::nIdx++
//
//      ::cToken := ""
//      DO WHILE ! ::CurrChar() == '"' .AND. ;
//               ! ::CurrChar() == CR  .AND. ;
//               ! ::CurrChar() == ""
//         ::cToken += ::CurrChar()
//         ::nIdx++
//      ENDDO
//
//      IF ! ::CurrChar() == '"'
//         BREAK S2SCR_ERR_MANCAPARENTESI
//      ENDIF
//
//      ::nIdx++
//
//      ::nTokType := QUOTE
//      RETURN ::nTokType
//   ENDIF
//
//   IF ::isDigit( ::CurrChar() )
//      ::cToken := ""
//      DO WHILE ! ::isDelim( ::CurrChar() )
//         ::cToken += ::CurrChar()
//         ::nIdx++
//      ENDDO
//      ::nTokType := NUMBER
//      RETURN ::nTokType
//   ENDIF
//
//   IF ::IsAlpha( ::CurrChar() )
//      ::cToken := ""
//      DO WHILE ! ::isDelim( ::CurrChar() )
//         ::cToken += ::CurrChar()
//         ::nIdx++
//      ENDDO
//      ::nTokType := STRING
//   ENDIF
//
//   IF ::nTokType == STRING
//      DO CASE
//
//         CASE (::nTokCmd := ::Lookup( ::cToken )) > 0
//            ::nTokType := COMMAND
//
//         OTHERWISE
//            IF ::CurrChar() == "-"  // Guardo se e' un alias
//
//               ::nIdx++
//               IF ::CurrChar() == ">"
//                  ::nTokType := ALIAS_VAR
//
                  // Se e' un alias guardo se chiama una funzione
//                  ::nIdx++
//
//                  IF ::CurrChar() == "("
//                     ::nTokType := ALIAS_FUN
//                     ::nIdx++
//
//                  ENDIF
//
//               ELSE
//                  ::nIdx--
//               ENDIF
//
//            ENDIF
//
//            IF ::nTokType == STRING   // Non e' un alias
//               nTemp := ::nIdx
//               DO WHILE ::isWhite( ::CurrChar() )
//                  ::nIdx++
//               ENDDO
//
//               DO CASE
//                  CASE ::CurrChar() == "("
//                     ::nTokType := FUNCTIONCALL
//
//                  CASE ::CurrChar() == "["
//                     ::nTokType := ARRAY_IDX
//
//                  CASE lPreferVARS .AND. (::FindVarPos(::cToken) > 0 .OR. ::FindExtVar(::cToken))
//                     ::nTokType := VARIABLE
//
//                  CASE ! EMPTY(ALIAS()) .AND. FIELDPOS(::cToken) > 0
//                     ::nTokType := FIELDVAR
//
//                  OTHERWISE
//                     ::nTokType := VARIABLE
//               ENDCASE
//
//               ::nIdx := nTemp
//            ENDIF
//
//      ENDCASE
//
//   ELSE
//      BREAK S2SCR_ERR_SYNTAX
//   ENDIF
//RETURN ::nTokType



METHOD dfExpressionOptimizer:_GetToken(cProg, lPreferVARS, ;
                                       nTokCmd, nIdx, cToken)
   LOCAL nTemp := 0
   LOCAL nTokType 
   LOCAL cDel

   DEFAULT lPreferVARS TO .T.

   nTokType := 0
   nTokCmd := 0

   IF nIdx > LEN( cProg )
      cToken := ""
      nTokCmd := CMD_FINISHED
      nTokType := DELIMITER
      RETURN nTokType
   ENDIF

   DO WHILE ::isWhite( cProg[nIdx] )
      nIdx++
   ENDDO

   IF cProg[nIdx] == CR  // CRLF
      nIdx++
      nIdx++

      nTokCmd := CMD_EOL
      cToken := CRLF
      nTokType := DELIMITER
      RETURN nTokType
   ENDIF

   IF cProg[nIdx] $ "+-*^/%=;:(),><!$[]{|}"

      cToken := cProg[nIdx]
      nTokType := DELIMITER

      nIdx++
      RETURN nTokType
   ENDIF

   IF cProg[nIdx] == '"' .OR.  cProg[nIdx] == "'" // Stringa
      cDel := cProg[nIdx]
      nIdx++
      cToken := ""
      DO WHILE ! cProg[nIdx] == cDel .AND. ;
               ! cProg[nIdx] == CR   .AND. ;
               ! cProg[nIdx] == ""
         cToken += cProg[nIdx]
         nIdx++
      ENDDO

      IF ! cProg[nIdx] == cDel
         BREAK S2SCR_ERR_MANCAPARENTESI
      ENDIF

      nIdx++

      nTokType := QUOTE
      RETURN nTokType
   ENDIF

   IF ::isDigit( cProg[nIdx] )
      cToken := ""
      DO WHILE ! ::isDelim( cProg[nIdx] )
         cToken += cProg[nIdx]
         nIdx++
      ENDDO
      nTokType := NUMBER
      RETURN nTokType
   ENDIF

   IF ::IsAlpha( cProg[nIdx] )
      cToken := ""
      DO WHILE ! ::isDelim( cProg[nIdx] )
         cToken += cProg[nIdx]
         nIdx++
      ENDDO
      nTokType := STRING
   ENDIF

   IF nTokType == STRING
      DO CASE

         CASE (nTokCmd := ::Lookup( cToken )) > 0
            nTokType := COMMAND

         OTHERWISE
            IF cProg[nIdx] == "-"  // Guardo se e' un alias

               nIdx++
               IF cProg[nIdx] == ">"
                  nTokType := ALIAS_VAR

                  // Se e' un alias guardo se chiama una funzione
                  nIdx++

                  IF cProg[nIdx] == "("
                     nTokType := ALIAS_FUN
                     nIdx++

                  ENDIF

               ELSE
                  nIdx--
               ENDIF

            ENDIF

            IF nTokType == STRING   // Non e' un alias
               nTemp := nIdx
               DO WHILE ::isWhite( cProg[nIdx] )
                  nIdx++
               ENDDO

               DO CASE
                  CASE cProg[nIdx] == "("
                     nTokType := FUNCTIONCALL

                  CASE cProg[nIdx] == "["
                     nTokType := ARRAY_IDX

                  CASE lPreferVARS .AND. (::FindVarPos(cToken) > 0 .OR. ::FindExtVar(cToken))
                     nTokType := VARIABLE

                  CASE ! EMPTY(ALIAS()) .AND. FIELDPOS(cToken) > 0
                     nTokType := FIELDVAR

                  OTHERWISE
                     nTokType := VARIABLE
               ENDCASE

               nIdx := nTemp
            ENDIF

      ENDCASE

   ELSE
      BREAK S2SCR_ERR_SYNTAX
   ENDIF
RETURN nTokType



//METHOD dfExpressionOptimizer:CurrChar()
//RETURN SUBSTR(::cProg, ::nIdx, 1)
//
//METHOD dfExpressionOptimizer:CurrCh(nInd)
//RETURN SUBSTR(::cProg, nInd, 1)


METHOD dfExpressionOptimizer:PutBack()
   ::nIdx -= LEN(::cToken)
   IF ::nTokType==QUOTE
      ::nIdx-=2 // torno indietro anche dei delimitatori
   ENDIF
RETURN

METHOD dfExpressionOptimizer:LookUp( cTkn )
   LOCAL aCmd := {                           ;
                   { "nil"    , CMD_NIL    }   , ;
                   { ".t."    , CMD_TRUE   }   , ;
                   { ".f."    , CMD_FALSE  }   , ;
                   { ".and."  , CMD_AND    }   , ;
                   { ".or."   , CMD_OR    }   , ;
                   { ".not."  , CMD_NOT    }   , ;
                   { ""       , CMD_END    }     ;
                 }
                 //   { "gosub"  , CMD_GOSUB  }   , ;
                 //   { "goto"   , CMD_GOTO   }   , ;

   LOCAL cT   := LOWER( cTkn )
   LOCAL nPos := ASCAN( aCmd, {|a| a[1] == cT })
RETURN IIF(nPos == 0, 0, aCmd[nPos][2])

METHOD dfExpressionOptimizer:IsDelim( cCh )
RETURN cCh $ " :;,+-<>/*%^=()!$[]{|}"+TAB+CR

METHOD dfExpressionOptimizer:IsWhite( cCh )
RETURN cCh == " " .OR. cCh == TAB

METHOD dfExpressionOptimizer:IsDigit( cCh )
RETURN cCh >= "0" .AND. cCh <= "9"

METHOD dfExpressionOptimizer:IsAlpha( cCh )
   cCh := UPPER(cCh)
RETURN (cCh >= "A" .AND. cCh <= "Z") .OR. cCh == "." .OR. cCh == "_"

// Converte un valore in una stringa di cui si pu• fare il MACRO
METHOD dfExpressionOptimizer:_Var2Char(xVal)
RETURN dfExpCast(xVal)
/* simone 18/4/06 creata una funzione
   LOCAL cDel
   LOCAL cTip := VALTYPE(xVal)
   LOCAL cRet
   LOCAL nPos

   DO CASE
      CASE cTip == "U"
         cRet := "NIL"

      CASE cTip == "N"
         cRet := ALLTRIM(VAR2CHAR(xVal)) //ALLTRIM( STR(xVal, 25, 10) )

      CASE cTip $ "CM"
         cDel:='"'       // ritorna "xxx"
         IF cDel $ xVal
            cDel := "'"  // ritorna 'xxx'
         ENDIF
         cRet := cDel+xVal+cDel

      CASE cTip == "D"
         cRet := 'STOD("'+DTOS(xVal)+'")'

      CASE cTip == "L"
         cRet := IIF(xVal, ".T.", ".F." )

      CASE cTip == "A"
         cRet := "{"
         FOR nPos := 1 TO LEN( xVal )
            cRet += ::_Var2Char( xVal[nPos] )
            IF nPos<LEN( xVal )
               cRet += ","
            ENDIF
         NEXT
         cRet += "}"

      CASE cTip == "B"
         cRet := ALLTRIM(VAR2CHAR(xVal))

      CASE cTip == "O"
         cRet := ALLTRIM(VAR2CHAR(xVal))

   ENDCASE
RETURN cRet
*/

METHOD dfExpressionOptimizer:_Empty(aParam)
   LOCAL xRet := ".T."
   LOCAL cChk, xR1

   IF LEN(aParam) == 1 .AND. ! aParam[1] == ""
      cChk := UPPER(LEFT(ALLTRIM(aParam[1]), 1))

      IF !( (cChk >= "A" .AND. cChk <= "Z") .OR. cChk == "_")
         // se non Š un campo o una funzione (se non inizia per _ o A-Z)
         // valuto l'EMPTY()
         xRet := IIF(::_ChkEmpty(aParam[1]), ".T.", ".F.")
      ELSE
         xRet := "EMPTY("+aParam[1]+")"
      ENDIF
   ELSE
      // questo sarebbe un errore runtime.. skip
      xRet := ""
   ENDIF
RETURN xRet

METHOD dfExpressionOptimizer:_Alltrim(aParam)
   LOCAL xRet := ".T."
   LOCAL cChk, xR1, cApici

   IF LEN(aParam) == 1 .AND. ! aParam[1] == ""
      cChk := ALLTRIM(aParam[1])
      IF ::isString(cChk)
         // simone 12/2/08
         // correzione per ALLTRIM("L'ABETE") tradotto in ALLTRIM('L'ABETE')  (errore stringa)
         cApici := LEFT(cChk, 1)

         cChk := SUBSTR(cChk, 2, LEN(cChk)-2)
         // se non Š un campo o una funzione (se non inizia per _ o A-Z)
         // valuto l'EMPTY()
         xRet := cApici+ ALLTRIM(cChk)+cApici
      ELSE
         xRet := "ALLTRIM("+aParam[1]+")"
      ENDIF
   ELSE
      // questo sarebbe un errore runtime.. skip
      xRet := ""
   ENDIF
RETURN xRet


METHOD dfExpressionOptimizer:_Upper(aParam)
   LOCAL xRet := ".T."
   LOCAL cChk, xR1

   IF LEN(aParam) == 1 .AND. ! aParam[1] == ""
      cChk := ALLTRIM(aParam[1])
      IF ::isString(cChk)
         // simone 12/2/08
         // correzione per UPPER("L'ABETE") tradotto in UPPER('L'ABETE') (errore stringa)
         //cChk := SUBSTR(cChk, 2, LEN(cChk)-2)
         // se non Š un campo o una funzione (se non inizia per _ o A-Z)
         // valuto l'EMPTY()
         //xRet := "'"+ UPPER(cChk)+"'"
         xRet := UPPER(cChk)
      ELSE
         xRet := "UPPER("+aParam[1]+")"
      ENDIF
   ELSE
      // questo sarebbe un errore runtime.. skip 
      xRet := ""
   ENDIF
RETURN xRet

METHOD dfExpressionOptimizer:_Eval(aParam)
   LOCAL xRet := ".T."
   LOCAL cChk, xR1
   LOCAL aOpt, nErr
   LOCAL aNotOptFunc

   // Ottimizzo il codeblock
   IF LEN(aParam) == 1 .AND. ! aParam[1] == ""

      aOpt := dfOptFltNew(::cBaseAlias, NIL, aParam[1], ;
                          ::bVarAccess)

      aOpt[OPTFLT_VAR_ARR] := ACLONE(::aVar)

      dfOptFltOptimize(aOpt, ::bInitCB, ::nMaxStringLen)

      nErr := dfOptFltGetErrNum(aOpt)

      // Se ci sono state funzioni non ottimizzabili le aggiungo
      // altrimenti la stringa finale potrebbe risultare tutta ottimizzata
      // anche se in realt… non lo e'!!
      aNotOptFunc := ::aNotOptFunc
      AEVAL(dfOptFltGetNotOptFunc(aOpt), {|x|AADD(aNotOptFunc, x)})

      //IF nErr != S2SCR_OK // Errore
      //   BREAK nErr
      //ENDIF

      IF nErr != S2SCR_OK // Errore
         RETURN ""
      ENDIF

      // Parte ottimizzata, la parte non ottimizzata Š inutile tanto
      // Š presente nel codeblock iniziale
      xRet := dfOptFltGetString(aOpt)
      IF ! ::isPrimitive(xRet)
         xRet := "("+xRet+")"
      ENDIF
   ELSE
      // questo sarebbe un errore runtime.. skip 
      xRet := ""
   ENDIF
RETURN xRet

METHOD dfExpressionOptimizer:_IIF(aParam)
   LOCAL xRet := ".T."
   LOCAL cChk, xR1

   IF LEN(aParam) == 3 
      IF aParam[1] == "" .OR. aParam[2] == "" .OR. aParam[3] == ""
         // questo sarebbe un errore runtime.. skip
         xRet := ""
      ELSE
         cChk := ALLTRIM(aParam[1])
         IF ::isPrimitive(cChk)
            xRet := "("+IIF(&(cChk), aParam[2], aParam[3])+")"

         ELSE
            xRet := "IIF("+aParam[1]+", "+aParam[2]+", "+aParam[3]+")"
         ENDIF
      ENDIF
   ELSE
      // questo sarebbe un errore runtime.. skip
      xRet := ""
   ENDIF
RETURN xRet

METHOD dfExpressionOptimizer:_FIELDPOS(aParam)
   LOCAL xRet := ".T."
   LOCAL cChk, xR1, cApici

   IF LEN(aParam) == 1 .AND. ! aParam[1] == ""
      cChk := ALLTRIM(aParam[1])
      IF ::isString(cChk)
         cChk := SUBSTR(cChk, 2, LEN(cChk)-2)
         xRet := ALLTRIM(STR(FIELDPOS(cChk)))
      ELSE
         xRet := "FIELDPOS("+aParam[1]+")"
      ENDIF
   ELSE
      // questo sarebbe un errore runtime.. skip
      xRet := ""
   ENDIF
RETURN xRet

METHOD dfExpressionOptimizer:_FIELDNAME(aParam)
   LOCAL xRet := ".T."
   LOCAL cChk, xR1, cApici

   IF LEN(aParam) == 1 .AND. ! aParam[1] == ""
      cChk := ALLTRIM(aParam[1])
      IF dfIsDigit(cChk)
         xRet := '"'+FIELDNAME(cChk)+'"'
      ELSE
         xRet := "FIELDNAME("+aParam[1]+")"
      ENDIF
   ELSE
      // questo sarebbe un errore runtime.. skip
      xRet := ""
   ENDIF
RETURN xRet

// Simone 21/09/09 XL 1352
// aggiunta possibilit… di definire delle funzioni come 
// da eseguirle immediatamente e non nel filtro
// esempio
//   'DOCMOVD->DATDOC <=_LOCALEXEC_S2SysDat()'
// viene tradotto in
//   'DATDOC <= STOD("20090922")'
// tanto S2SysDat() non varia durante l'esecuzione del filtro
METHOD dfExpressionOptimizer:_LocalExecute(cLocalExec, aParam)
   LOCAL xRet   := ""
   LOCAL n
   LOCAL oErr

   // ricostruisco stringa dei parametri
   cLocalExec += "("
   FOR n := 1 TO LEN(aParam)
      cLocalExec += IIF(n==1, "", ", ")+aParam[n]
   NEXT
   cLocalExec += ")"
   xRet := dfMacro(@oErr, cLocalExec)

   IF EMPTY(oErr) 
      // se non c'Š errore trasformo in stringa
      xRet :=::_Var2Char(xRet)
   ELSE
      // questo sarebbe un errore runtime.. skip
      xRet := ""
   ENDIF
RETURN xRet


// ritorna se una stringa convertita
// dalla _Var2Char Š EMPTY
METHOD dfExpressionOptimizer:_ChkEmpty(xVal)

   // Š vuota
   IF EMPTY(xVal)
      RETURN .T.
   ENDIF

   xVal := UPPER(ALLTRIM(xVal))

   // NIL Š empty
   IF xVal == "NIL"
      RETURN .T.
   ENDIF

   // empty su logico
   IF xVal == ".F." .OR. xVal == ".T."
      RETURN xVal == ".F."
   ENDIF

   // empty su array
   IF xVal == "{}" 
      RETURN .T.
   ENDIF

   // empty su stringa
   IF ::IsString(xVal) // Š un " o '
      RETURN EMPTY( SUBSTR(xVal, 2, LEN(xVal)-2) )
   ENDIF

   // empty su data
   IF UPPER(LEFT(xVal, 6)) == 'STOD("'
      RETURN SUBSTR(xVal, 7, 8) == SPACE(8)
   ENDIF

   IF dfIsDigit(xVal)
      RETURN EMPTY( VAL(xVal) )
   ENDIF

RETURN EMPTY( &xVal. )
