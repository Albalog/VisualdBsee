// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
// Description : Centralised file indexing functions
// *****************************************************************************
#include "Common.ch"
#include "dfSet.ch"
#include "dfStd.ch"
#include "dfMsg1.ch"
#include "dll.ch"
#include "dfAdsDbe.ch"

/* Success return code */
#define AE_SUCCESS                      0

/* Options for creating indexes - can be ORed together */
#define ADS_ASCENDING            0x00000000
#define ADS_UNIQUE               0x00000001
#define ADS_COMPOUND             0x00000002
#define ADS_CUSTOM               0x00000004
#define ADS_DESCENDING           0x00000008
#define ADS_USER_DEFINED         0x00000010
// 020 - 200 FTS index options below
#define ADS_NOT_AUTO_OPEN        0x00000400     // Don't make this an auto open index in data dictionary
#define ADS_CANDIDATE            0x00000800     // true unique CDX index (equivalent to ADS_UNIQUE for ADIs)


REQUEST DESCEND       // I'm asking for a Descend
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfMakeInd( cExp, cName, lAscend, lUnique, cTag, lDeleteFile, ;
                     lCandidate, lSubIndex )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL bEval, nEvery, nCurrent, nTotal, cScreen, bExp
LOCAL cRDD
LOCAL lRet
LOCAL cFor
LOCAL bFor

DEFAULT lAscend     TO .T.
DEFAULT lUnique     TO .F.
DEFAULT cTag        TO dfFindName( cName )
DEFAULT lDeleteFile TO .T.


cRDD := RDDNAME()
IF !dfAsDriver( cRDD )
   IF lDeleteFile
      FERASE( cName +dfIndExt( cRDD) ) // thus I'm using a RDD
      // I delete, because some index drivers
      // continue to increase the file's size
   ENDIF
ELSE
   cExp := dfASIndex( cExp )
ENDIF

bExp := &( "{|| "+cExp+" }" )

  //#ifdef __XPP__
   _dfMakeIndInit()
  //#endif

IF dfSet( AI_INDEXPROGRESSBAR )
   nCurrent := 0
   nTotal   := RECCOUNT()
   nEvery   := 10
   cScreen  := SAVESCREEN( MAXROW(), 0, MAXROW(), MAXCOL() )

     //#ifdef __XPP__
      if nTotal>100
         _dfMakeIndCreate(cName,nTotal)

         bExp := &( "{|| _dfMakeIndPB()," + cExp + "}" )

      endif
     //#else
     //   bEval    := {||dfPro( MAXROW(), 0, MAXCOL(), nCurrent+=nEvery, nTotal, "W+/B" ), .T. }
     //#endif

ENDIF

// Simone 26/10/09
// FIX per gestione indici CANDIDATI (senza chiavi duplicate)
IF ! EMPTY(lCandidate)
   cFor := "! DELETED()"
   bFor := {|| ! DELETED()}
ENDIF
lRet := dfMakeIndSub( cRDD  ,;
                      bEval ,;
                      nEvery,;
                      RECNO(),;
                      lAscend,;
                      cName,;
                      cTag,;
                      cExp,;
                      bExp,;
                      lUnique, ;
                      NIL, bFor, cFor, NIL, ;
                      lCandidate, lSubIndex )


  //#ifdef __XPP__
   _dfMakeIndDestroy()
  //#endif

IF cScreen!=NIL
   RESTSCREEN( MAXROW(), 0, MAXROW(), MAXCOL(), cScreen )
ENDIF

RETURN lRet

// Simone 09/12/02 GERR 3579
// L'indice temporaneo non veniva usato in Xbase
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfMakeIndSub( cRdd, bEval, nEvery, nRecno, lAscend, ;
                        cName, cTag, cExp, bExp, lUnique, bWhile, ;
                        bFor, cFor, nNext, lCandidate, lSubIndex, lTempIndex)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

//Mantis 808
//LOCAL bErr := ERRORBLOCK({|e| dfErrBreak(e)}),  oErr
LOCAL bErr 
LOCAL oErr
LOCAL lRet :=  .F.
////////////////////////////////////////////////
LOCAL nRetry := 5  // simone 7/5/09 migliorata gestione errore in creazione indice
LOCAL oShowErr
LOCAL nH, r, handle:=0, nOpt

bErr := ERRORBLOCK({|e| dfErrBreak(e, "//", .T.)})

DO WHILE .T.

   ////////////////////////////////////////////////
   //Mantis 808
   ////////////////////////////////////////////////
   BEGIN SEQUENCE

      // Simone 16/12/09
      // fix per diz. dati ADS, se creo un indice che NON appartiene al dizionario dati 
      // (es. indice temporaneo) l'indice viene creato e aperto ma quando si fa ORDLISTCLEAR()
      // l'indice nuovo viene CANCELLATO e ci sono errori successivi quando si cerca di usare l'indice.
      // Invece con il parametro lTempIndex l'indice NON viene cancellato
      IF ! EMPTY(lTempIndex) .AND. dfADSUseDD()
         // parametro WHILE non supportato
         bWhile := ""
         IF ! VALTYPE(cFor) $ "CM"
            cFor := ""
         ENDIF
         //IF EMPTY(bWhile)
         //   bWhile := ""
         //ELSE
         //   bWhile := dfCodeBlock2String(bWhile)
         //ENDIF
         nOpt := 0
         IF dfRddIsCompound(cRDD)
            nOpt += ADS_COMPOUND //ADS_DEFAULT
         ENDIF
         IF !EMPTY(lCandidate)
            nOpt += ADS_CANDIDATE
         ENDIF
         IF !EMPTY(lUnique)
            nOpt += ADS_UNIQUE
         ENDIF
         IF !EMPTY(lTempIndex)
            nOpt+=ADS_NOT_AUTO_OPEN
         ENDIF
         IF EMPTY(lAscend)
            nOpt += ADS_DESCENDING
         ENDIF
         nH := DbInfo(ADSDBO_TABLE_HANDLE)
         r:=DllCall("ACE32.DLL", DLL_STDCALL, "AdsCreateIndex",nH,cName,cTag,cExp,cFor,bWhile,nOpt,@handle)
         IF r == AE_SUCCESS
            // chiudo l'indice altrimenti per ADS Š aperto ma per XBase++ NO e si generano problemi dopo
            r:=DllCall("ACE32.DLL", DLL_STDCALL, "AdsCloseIndex",handle)
            // per compatibilità con funzionamento standard Xbase++
            // apro IL SOLO indice appena creato
            ORDLISTCLEAR()
            ORDLISTADD(cName)
         ELSE
            dfErrorThrow("ADS Error "+ALLTRIM(STR(r))+" creating index", {cName, cTag, cExp, cFor}, "AdsCreateIndex", NIL, NIL, "ADS")
         ENDIF
      ELSE

      // Index Parameter
      #ifndef __HARBOUR__
      IF !(UPPER(ALLTRIM(cRdd))=="DBFNDX")
      #ifdef __XPP__
         // Simone 7/marzo/06
         // mantis 0000995: abilitare indici "candidati" di xbase 1.90 per indici primari/univoci
         ORDCONDSET(      cFor ,; //  1 <cForCondition>
                          bFor ,; //  2 <bForCondition>
                           NIL ,; //  3 <lAll>
                        bWhile ,; //  4 <bWhileCondition>
                         bEval ,; //  5 <bEval>
                        nEvery ,; //  6 <nInterval>
                        nRecno ,; //  7 <nStart>
                         nNext ,; //  8 <nNext>
                           NIL ,; //  9 <nRecord>
                           NIL ,; // 10 <lRest>
                      !lAscend ,; // 11 <lDescend>
                     lCandidate,; // 12 <lAdditive>  // xbase 1.90
                      lSubIndex,; // 13 <lSubIndex>  // xbase 1.90
                           NIL  ) // 14 <lCustom>
      #else
         ORDCONDSET(      cFor ,; //  1 <cForCondition>
                          bFor ,; //  2 <bForCondition>
                           NIL ,; //  3 <lAll>
                        bWhile ,; //  4 <bWhileCondition>
                         bEval ,; //  5 <bEval>
                        nEvery ,; //  6 <nInterval>
                        nRecno ,; //  7 <nStart>
                         nNext ,; //  8 <nNext>
                           NIL ,; //  9 <nRecord>
                           NIL ,; // 10 <lRest>
                      !lAscend ,; // 11 <lDescend>
                           NIL ,; // 12 <lAdditive>
                           NIL ,; // 13 <lCurrent>
                           NIL ,; // 14 <lCustom>
                           NIL  ) // 15 <lNoOptimize>
      #endif
      ENDIF
      #endif

      // Index Creation
      #ifdef __XPP__
         // This fix an error with alaska 1.2, we hope to solve this ASAP
         IF (UPPER(ALLTRIM(cRdd))=="DBFNTX")
            cTag := NIL
         ENDIF
      #endif

      ORDCREATE(      cName ,; //  1 <cOrderBagName>
                       cTag ,; //  2 <cOrderName>
                       cExp ,; //  3 <cExpKey>
                       bExp ,; //  4 <bExpKey>
                    lUnique  ) //  5 <lUnique>

      ENDIF
      lRet :=  .T.

   RECOVER USING oErr

     IF oShowErr == NIL // salvo errore
        oShowErr := oErr
     ENDIF

     dfErrLog(oErr) // log in dbstart.log

     lRet :=  .F. 
  END SEQUENCE

   IF lRet .OR. --nRetry <= 0
      EXIT
   ENDIF

   sleep(50) // attendo 1/2 secondo e riprovo
ENDDO

   // mostro errore
   IF ! lRet .AND. oShowErr != NIL
      dbMsgErr(dfMsgTran( dfStdMsg1(MSG1_DFMAKEIND000), "file="+cName) )
      dbMsgErr(VDBErrorMessage(oShowErr, "//", .T., .T.))
   ENDIF

   ERRORBLOCK(bErr)
   ////////////////////////////////////////////////
   ////////////////////////////////////////////////

RETURN lRet