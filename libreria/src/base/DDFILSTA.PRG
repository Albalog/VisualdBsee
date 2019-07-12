/******************************************************************************
Project     : dBsee 4.5
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "dbstruct.ch"
#include "dfWin.ch"
#include "dfmsg.ch"
#include "dfmsg1.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbFileStat(oTbr)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF !EMPTY( oTbr:W_ALIAS )
   (oTbr:W_ALIAS)->(ddFileStat( oTbr:W_KEY, oTbr:W_FILTER, oTbr:W_BREAK ))
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE ddFileStat( bKey, bFilter, bBreak )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aStruct, aFieldDes := {}, nFie, cAlias, nRec, cSeek, cInt
LOCAL cFile, cFile1, cFile2, aField := {}, aValue := {}

dfPushAct()
dfPushArea()

cAlias  := ALIAS()
IF !EMPTY(cAlias)
   aStruct := ddFileStruct()

   // simone 3/4/08
   // fix per funzione richiamata su tabella con campi aggiunti dinamicamente
   // es. vedi uso tabella STAT.DBF in ExtraService/Business 
   AEVAL( aStruct, {|aSub|AADD( aFieldDes, ;
                                IIF(aSub[DBS_ALEN+2]==NIL,;
                                   aSub[DBS_NAME],aSub[DBS_ALEN+2]))} )

   nFie := dfArrWin( ,,,, aFieldDes, dfStdMsg(MSG_DDFILEST01) )

   IF nFie>0
      cInt   := cAlias +" - " +aFieldDes[nFie]
      //MANTIS 932
      cFile  := dfNameUnique(dfTemp()+"f",dfdbfExt(DBESETDEFAULT()))
      cFile1 := dfNameUnique(dfTemp()+"i",dfindExt(DBESETDEFAULT()))
      cFile2 := dfNameUnique(dfTemp()+"i",dfindExt(DBESETDEFAULT()))
      //cFile  := dfNameUnique(dfTemp()+"f",dfdbfExt(RDDNAME()))
      //cFile1 := dfNameUnique(dfTemp()+"i",dfindExt(RDDNAME()))
      //cFile2 := dfNameUnique(dfTemp()+"i",dfindExt(RDDNAME()))
      IF EMPTY(cFile) .OR. EMPTY(cFile1) .OR. EMPTY(cFile2)
         dbMsgErr(dfMsgTran(dfStdMsg1(MSG1_DDFILESTA000), "file="+dfTemp()))
      ELSE
      DBCREATE( cFile, { {"cField","C",30,0},;
                         {"nNum"  ,"N",LEN(ALLTRIM(STR(RECCOUNT()))),0} } )


      dfUseFile( cFile, "dbstat", .T. )
      //MANTIS 932
      //dfMakeInd( "UPPER(cField)", SUBSTR(cFile1,1,LEN(cFile1)-LEN(dfindExt(RDDNAME()))),,,,.T.    )
      //dfMakeInd( "nNum"         , SUBSTR(cFile2,1,LEN(cFile2)-LEN(dfindExt(RDDNAME()))),.F.,,,.T. )
      dfMakeInd( "UPPER(cField)", SUBSTR(cFile1,1,LEN(cFile1)-LEN(dfindExt(DBESETDEFAULT()))),,,,.T.    )
      dfMakeInd( "nNum"         , SUBSTR(cFile2,1,LEN(cFile2)-LEN(dfindExt(DBESETDEFAULT()))),.F.,,,.T. )
      SET INDEX TO (cFile1),(cFile2)

      nFie := (cAlias)->(FIELDPOS( aStruct[nFie][DBS_NAME] ))

      dfPiOn("", dfStdMsg(MSG_DDKEY11) ,.F.)
      nRec := 0
      //(cAlias)->(DBGOTOP())
      (cAlias)->(dfTop( bKey, bFilter, bBreak ))
      WHILE !(cAlias)->(EOF())
         dfPiStep(nRec,(cAlias)->(RECCOUNT()))
         cSeek := dfAny2Str( (cAlias)->(FIELDGET(nFie)) )
         IF !dbstat->( DBSEEK( UPPER( cSeek ) ) )
            dbstat->( DBAPPEND() )
            dbstat->cField := cSeek
            dbstat->nNum   := 1
         ELSE
            dbstat->nNum   += 1
         ENDIF
         nRec++
         //(cAlias)->(DBSKIP())
         //(cAlias)->(dfSkip( 1, bFilter, bBreak ))
         IF (cAlias)->(dfSkip( 1, bFilter, bBreak ))==0 .OR. NEXTKEY()!=0
            EXIT
         ENDIF
      ENDDO
      dfPiOff()
      dfClearType()

      dbstat->(DBSETORDER(2))
      dbstat->(DBGOTOP())
      FOR nFie := 1 TO 15
         AADD( aField, "(" +ALLTRIM(STR(dbstat->nNum)) +") " +dbstat->cField )
         AADD( aValue, dbstat->nNum )
         nRec -= dbstat->nNum
         dbstat->(DBSKIP())
         IF dbstat->(EOF())
            EXIT
         ENDIF
      NEXT

      IF nRec>0
         AADD( aField, "(" +ALLTRIM(STR(nRec)) +") " +dfStdMsg(MSG_DDFILEST02) )
         AADD( aValue, nRec    )
      ENDIF

    #ifdef __XPP__
      dfGraph3( cInt, aField, aValue )
    #else
      dfPushPal()
      dfSetVGA()
      dfGraph3( cInt, aField, aValue )
      dfINKEY(0)
      dfTxtMode()
      dfPopPal()
    #endif

      CLOSE dbstat

      FERASE(cFile )
      FERASE(cFile1)
      FERASE(cFile2)
   ENDIF
ENDIF
ENDIF

dfPopArea()
dfPopAct()

RETURN