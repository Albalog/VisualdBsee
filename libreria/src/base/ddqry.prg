//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Query
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dbStruct.ch"
#include "Common.ch"
#include "dfMsg.ch"
#include "dfStd.ch"

#define QRY_FIE          1
#define QRY_NAME         2
#define QRY_COND         3
#define QRY_VALUE        4
#define QRY_LOGIC        5
#define QRY_SX           6
#define QRY_DX           7

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddQry()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cAlias
LOCAL aCondStr := { "<", ">", "<=", ">=", "=", "#", "$", "œ" } ,;
      aLogici  := { ".AND." , ".OR.", ")" }
LOCAL cRet  := ""
LOCAL aStruct           // Array con la struttura del database
LOCAL aFieldDes := {}   // Array con le descrizioni dei campi
LOCAL nFie,nCond, nLeg  // Posizione del campo, condizione
LOCAL cPos              // Posizione di get
LOCAL uVar, cPic, lAS400
LOCAL aFilter := {}
LOCAL cParSx := "", cParDx := ""
LOCAL aLegami    := { dfStdMsg(MSG_DDQRY01) ,;
                      dfStdMsg(MSG_DDQRY02) ,;
                      dfStdMsg(MSG_DDQRY17) ,;
                      dfStdMsg(MSG_DDQRY03)  }
LOCAL aCondition := { dfStdMsg(MSG_DDQRY04) ,;
                      dfStdMsg(MSG_DDQRY05) ,;
                      dfStdMsg(MSG_DDQRY06) ,;
                      dfStdMsg(MSG_DDQRY07) ,;
                      dfStdMsg(MSG_DDQRY08) ,;
                      dfStdMsg(MSG_DDQRY09) ,;
                      dfStdMsg(MSG_DDQRY10) ,;
                      dfStdMsg(MSG_DDQRY11)  }
LOCAL nN
LOCAL lNew  := dfSet("XbaseddQuerydBddFiled") == "YES"

cAlias  := UPPER(ALLTRIM(ALIAS()))
lAS400  := dfAsDriver( RDDNAME() )



IF EMPTY(lNew)
   lNew := .F.
ENDIF 

//Mantis   27/09/2012
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
//AEVAL( aStruct, {|aSub|AADD( aFieldDes, aSub[DBS_ALEN+2])} )
IF lNew
   //Estraggo solo Camp iche sono definiti in Form
   aStruct := ddFileStruct(NIL, NIL, NIL, .T. )
ELSE 
   aStruct := ddFileStruct()
ENDIF 
//////////////////////////////////////////////////////////////////////////


AEVAL( aStruct, {|aSub|AADD( aFieldDes, aSub[DBS_ALEN+2])} )


AADD( aFieldDes, "(" )

IF !EMPTY(aStruct)
   cPos := "fie"
   WHILE .T.
      dfSayFilter( aFilter, cParSx, cAlias )
      DO CASE
         CASE cPos=="fie"
              nFie := dfArrWin( ,,,, aFieldDes,;
                                     dfStdMsg(MSG_DDQRY12) +" " +ALIAS() )
              DO CASE
                 CASE EMPTY(nFie) // Ho premuto ESC
                      cPos :="leg"
                      IF EMPTY(aFilter)
                         EXIT
                      ENDIF
                      cParSx := ""
                 CASE nFie==LEN(aFieldDes)         // PARENTESI
                      cParSX += "("
                 CASE aStruct[nFie][DBS_TYPE]=="L" // NON uso i campi logici
                 OTHERWISE        // Confermo la selezione
                      cPos := "con"
                      AADD( aFilter, { nFie, aStruct[nFie][DBS_NAME], "", "", "", cParSx, "" } )
                      cParSx := ""
              ENDCASE

         CASE cPos=="con"
              ATAIL(aFilter)[QRY_COND] := ""
              nCond := dfArrWin( ,,,, aCondition, dfStdMsg(MSG_DDQRY13) )
              DO CASE
                 CASE EMPTY(nCond) // Ho premuto ESC
                      cPos := "fie"
                      ASIZE( aFilter, LEN(aFilter)-1 )
                 CASE ddQryInvalid( aCondStr[nCond],;
                                    aStruct[ATAIL(aFilter)[QRY_FIE]][DBS_TYPE],lAS400)
                 OTHERWISE        // Confermo la selezione
                      cPos := "get"
                      ATAIL(aFilter)[QRY_COND] := aCondStr[nCond]
              ENDCASE

         CASE cPos=="get"
              ATAIL(aFilter)[QRY_VALUE] := ""
              cPic := aStruct[ATAIL(aFilter)[QRY_FIE]][DBS_ALEN+1]
              DO CASE
                 CASE aStruct[ATAIL(aFilter)[QRY_FIE]][DBS_TYPE]=="C"
                      uVar := SPACE( aStruct[ATAIL(aFilter)[QRY_FIE]][DBS_LEN] )
                      IF EMPTY cPic ASSIGN REPLICATE( "X", aStruct[ATAIL(aFilter)[QRY_FIE]][DBS_LEN] )
                      IF ATAIL(aFilter)[QRY_COND] == "$"
                         uVar := SPACE( MAX(60,aStruct[ATAIL(aFilter)[QRY_FIE]][DBS_LEN]) )
                         cPic := REPLICATE("X", LEN(uVar) )
                      ENDIF

                 CASE aStruct[ATAIL(aFilter)[QRY_FIE]][DBS_TYPE]=="N"
                      uVar := 0
                      IF EMPTY cPic ASSIGN REPLICATE( "9", aStruct[ATAIL(aFilter)[QRY_FIE]][DBS_LEN] )

                 CASE aStruct[ATAIL(aFilter)[QRY_FIE]][DBS_TYPE]=="D"
                      uVar := CTOD("  /  /  ")
                      IF EMPTY cPic ASSIGN "99/99/99"

                 CASE aStruct[ATAIL(aFilter)[QRY_FIE]][DBS_TYPE]=="M"
                      uVar := SPACE(50)
                      // NON uso il DEFAULT che e' "!"
                      cPic := REPLICATE( "X", 50 )

              ENDCASE
			  
			  // FWH: 2021-09-02 -------------------------------------------------
			  // con alcune finestre (tipo quelle con il resize automatico)
              // maxrow() restituisce un numero molto (ma molto) grande. Questo
              // causa un malfunzionamento in dfGetW che, a cascata, impedisce
              // il corretto funzionamento delle finestre di stampa. In questi
              // casi bisognava terminare il programma forzatamente.
              // Ho sperimentato che 12 e' un valore accettabile quindi prendo
              // il minore tra 12 e MAXROW()/2			  
			  // -----------------------------------------------------------------
              dfGetW( min(12, MAXROW()/2), 1, ALLTRIM(aFieldDes[ATAIL(aFilter)[QRY_FIE]]) +" " +;
                                     ATAIL(aFilter)[QRY_COND],;
                                     {|x|IF(x==NIL,uVar,uVar:=x)}, cPic )
              
              DO CASE
                 CASE M->Act=="esc" .OR.;                    // Ho premuto ESC
                      (EMPTY(uVar) .AND. !VALTYPE(uVar)$"N") // o e' vuoto
                      cPos := "con"                 // e NON e' numerico

                 OTHERWISE           // Confermo la selezione
                      cPos := "leg"
                      ATAIL(aFilter)[QRY_VALUE] := uVar
              ENDCASE

         CASE cPos=="leg"
              ATAIL(aFilter)[QRY_LOGIC] := ""
              nLeg := dfArrWin( ,,,, aLegami, dfStdMsg(MSG_DDQRY14) )
              DO CASE
                 CASE EMPTY(nLeg)
                      cPos := "get"
                      ATAIL(aFilter)[QRY_DX] := ""
                 CASE nLeg==LEN(aLegami)-1
                      ATAIL(aFilter)[QRY_DX] += ")"
                 CASE nLeg==LEN(aLegami)
                      EXIT
                 OTHERWISE
                      cPos := "fie"
                     #ifdef __XPP__
                      // Simone 21/3/2005 gerr 4335
                      // funziona con ADS e filtri lato server
                      ATAIL(aFilter)[QRY_LOGIC] := " "+aLogici[nLeg]+" "
                     #else
                      ATAIL(aFilter)[QRY_LOGIC] := aLogici[nLeg]
                     #endif
              ENDCASE
      ENDCASE
   ENDDO
ENDIF

RETURN dfMkeStr( aFilter, cAlias )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfSayFilter( aFilter, cParSx, cAlias )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr := dfMkeStr( aFilter, cAlias ), cValid, nPad
LOCAL cOk  := dfStdMsg( MSG_DDQRY15 )
LOCAL cKO  := dfStdMsg( MSG_DDQRY16 )

cValid := IF( TYPE( cStr )=="L", cOK, cKO )
nPad   := LEN(dfUsrState()) +MAX( LEN(cOK), LEN(cKO) )

dfUsrInfo( PADR( RIGHT(cStr +cParSx,70-nPad ),70-nPad ) +" " +cValid )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfMkeStr( aFilter, cAlias )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, cStr:="", cSub, lUpper, nDx := 0, nSX := 0, cType, cField

FOR nPos := 1 TO LEN(aFilter)
   cField := cAlias+"->"+aFilter[nPos][QRY_NAME]
   cType  := TYPE( cField )
   nSx  += LEN(aFilter[nPos][QRY_SX])
   nDx  += LEN(aFilter[nPos][QRY_DX])
   cStr += aFilter[nPos][QRY_SX]
   IF aFilter[nPos][QRY_COND]!="œ"
      cSub := cField
      IF (aFilter[nPos][QRY_COND]=="$" .OR. ;
          aFilter[nPos][QRY_COND]=="#" ) .AND.;
          !cType$"DN"
         cSub := "UPPER(" +cSub +")"
      ENDIF
      cStr += (cSub +aFilter[nPos][QRY_COND])
   ENDIF

   lUpper := .F.
   IF aFilter[nPos][QRY_COND]=="œ" .OR.;
      aFilter[nPos][QRY_COND]=="$" .OR.;
      aFilter[nPos][QRY_COND]=="#"
      lUpper := .T.
   ENDIF

   DO CASE
      CASE cType=="C" .OR. cType=="M"
           #ifdef __XPP__
           //Gerr. 3792 Se si inserisce nella ricerca CTRL-F8
           // con costruzione della stringa e si inserisce un
           // nome con un apice finale('), allora si ha un runtime error
           // LUCA 14/05/03
           // Per evitare runtime error elimino gli i doppi apici dentro la chiave
           //cSub := "'" +RTRIM(aFilter[nPos][QRY_VALUE]) +"'"
           cSub := '"' +STRTRAN( RTRIM(aFilter[nPos][QRY_VALUE]),'"',"") +'"'
           #else
           cSub := "[" +RTRIM(aFilter[nPos][QRY_VALUE]) +"]"
           #endif

      CASE cType == "N"
           cSub := ALLTRIM(dfAny2Str(aFilter[nPos][QRY_VALUE]))
           lUpper := .F.

      CASE cType == "D"
          #ifdef __XPP__
           // Simone 21/3/2005 gerr 4335
           // funziona con ADS e filtri lato server
           cSub := aFilter[nPos][QRY_VALUE]
           cSub := IIF(VALTYPE(cSub)=="D", DTOS(cSub), "")
           cSub := 'STOD("'+cSub+'")'
          #else
           cSub := "CTOD([" +dfAny2Str(aFilter[nPos][QRY_VALUE]) +"])"
          #endif
           lUpper := .F.

      OTHERWISE
           cSub := ""
   ENDCASE

   IF lUpper
      cSub := UPPER( cSub )
   ENDIF

   cStr += cSub

   IF aFilter[nPos][QRY_COND]=="œ"
      cStr += "$"
      cStr += "UPPER(" +cField +")"
   ENDIF
   cStr += aFilter[nPos][QRY_DX] +aFilter[nPos][QRY_LOGIC]
NEXT
IF nSx>nDx
   cStr += REPLICATE(")",nSX-nDX)
ELSE
   cStr := REPLICATE("(",nDX-nSX) +cStr
ENDIF
RETURN cStr

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION ddQryInvalid( cCond, cType, lAS400 )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet:=.F.
DO CASE
   CASE lAS400
        IF cCond$"œ"
           lRet:=.T.
        ENDIF

   CASE cType == "N" // Numerico
        IF cCond$"$œ"
           lRet:=.T.
        ENDIF

   CASE cType == "D" // Data
        IF cCond$"$œ"
           lRet:=.T.
        ENDIF
ENDCASE

RETURN lRet
