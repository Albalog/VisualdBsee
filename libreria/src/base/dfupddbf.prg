//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dbStruct.ch"
#include "dfMsg.ch"
#include "dfStd.ch"
#include "dfSet.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfUpdDbf( cFile, cRDD, cPath, aStru, cStr, lToReindex ) // Aggiorna DBF
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cTmpPath := ""
LOCAL aSold, cNew, cOld 
LOCAL nCnt, nField, cOldRec, aNew, xValue, aSkipped := {}, aSoldCopy

// usato come valore di ritorno
lToReindex := .F.

DEFAULT cRdd  TO RDDSETDEFAULT()
DEFAULT cPath TO ""

IF EMPTY(cFile) .OR. EMPTY(aStru)
   RETURN .F. // nome file vuoto
ENDIF

cPath := dfPathChk(cPath)
cFile := ALLTRIM(cFile)
cNew  := cFile
cOld  := cPath+cFile

IF !dfRddFile( cOld +dfDbfExt(cRDD), cRDD )
   RETURN .T. // Non esiste il vecchio file
ENDIF

IF cStr == NIL
   cStr := dfStdMsg(MSG_DDUPDDBF01) +" " +cPath +ALLTRIM(cFile)
ENDIF

#ifdef __XPP__
 // Simone 28/11/03 GERR 4019
 IF (dfSet("XbaseADSFIXEmptyDbf") == "YES")
    dfADSFixEmptyDBF(cOld, cRDD, "fOld")
 ENDIF
#endif

IF !dfUseFile( cOld, "fOld", .T., cRdd ); RETURN .F.; END // Esco se non apro
aSold := fOld->(DBSTRUCT())
IF dfStruCmp( aSold, aStru,cRdd)
   CLOSE fOld
   RETURN .T.
ENDIF
aSoldCopy := ARRAY(LEN(aSold)) // Creo l'array
ACOPY( aSold, aSoldCopy )      // Copio solo i riferimenti


///////////////////////////////////////////////////////////////
//Mantis 2227 Luca 06/07/2013
///////////////////////////////////////////////////////////////
IF !(dfSet("XbaseFastUPDDBF") == "NO")
   IF dfCompareDBStruct(aSold,aStru ) == .T.
      CLOSE fOld
      RETURN .T.
   ENDIF 
ENDIF 
///////////////////////////////////////////////////////////////

// simone 20/08/04 gerr 4034
// Creo il sottodirettorio
cTmpPath := dfPathTemp(cPath)
// errore?
IF cTmpPath == NIL                     
   CLOSE fOld
   RETURN .F.
ENDIF

cNew := dfPathChk(cTmpPath)+cNew

DBCREATE( cNew, aStru, cRDD )           // e il nuovo file

#ifdef __XPP__
 // Simone 28/11/03 GERR 4019
 IF (dfSet("XbaseADSFIXEmptyDbf") == "YES")
    dfADSFixEmptyDBF(cNew, cRDD, "fNew")
 ENDIF
#endif

// simone 28/11/08
// supporto DBF criptati con ADS o ALS
IF dfADSGetPwd(cNew) != NIL
   dfADSTableEncrypt(cNew, .T.)
ENDIF

IF !dfUseFile( cNew, "fNew", .T., cRdd )
   CLOSE fOld
   FERASE( cNew +dfDbfExt(cRDD) )
   FERASE( cNew +dfMemoExt(cRDD) )
   dfRd( cTmpPath )
   RETURN .F.
END

aNew:={}
nCnt:=1
WHILE( nCnt <= LEN(aStru) )  // Scandisce struttura nuovo file per le posizioni
   nField := ASCAN( aSold ,{|nEl| UPPER(nEl[DBS_NAME]) ==       ;
                                  ALLTRIM(UPPER(aStru[nCnt][DBS_NAME])) })

   IF nField==0 .OR. ; // Non trovo il campo o NON lo riesco a processare
      !dfUpdDbfAdd( aSold[nField], nField, aStru[nCnt], nCnt, aNew )

      AADD( aSkipped, nCnt )   // memorizzo il campo che ho dovuto saltare
   ELSE
      aSoldCopy[nField] := NIL // Distruggo il campo dall'array del 2' giro
   ENDIF

   nCnt++
ENDDO

nCnt:=1
WHILE( nCnt <= LEN(aStru) )  // Scandisce struttura nuovo file per rename
   IF ASCAN(aSkipped,nCnt)>0
      nField := ASCAN( aSoldCopy ,{|nEl| nEl!=NIL                    .AND. ;
                  UPPER(nEl[DBS_TYPE])==UPPER(aStru[nCnt][DBS_TYPE]) .AND. ;
                        nEl[DBS_LEN ] ==      aStru[nCnt][DBS_LEN ]  .AND. ;
                        nEl[DBS_DEC ] ==      aStru[nCnt][DBS_DEC ]  })

      IF nField>0  // Anche il tentato sul rename NON e' andato a buon fine
         IF dfUpdDbfAdd( aSold[nField], nField, aStru[nCnt], nCnt, aNew )
            aSoldCopy[nField] := NIL // Distruggo il campo dall'array del 2' giro
         ENDIF
      ENDIF
   ENDIF
   nCnt++
ENDDO

cOldRec := PADL(fOld->(RECCOUNT()),7,"0")
fOld->(DBGOTOP())
WHILE( ! fOld->(EOF()) )                  // Scansione RECORDS vecchio FILE

   dfUsrMsg( PADL(fNew->(RECNO())+1,7,"0") +"/" +cOldRec +" " +cStr )

   fNew->(dbAppend())                     // APPEND nel nuovo FILE
   FOR nCnt := 1 TO LEN(aNew)
      xValue := fOld->(FIELDGET(aNew[nCnt][1]))
      IF aNew[nCnt][7]  // Changed
         xValue := EVAL( aNew[nCnt][2], xValue, aNew[nCnt][3], aNew[nCnt][4] )
         xValue := EVAL( aNew[nCnt][6], xValue)
      ENDIF
      IF !EMPTY(xValue)
         fNew->(FIELDPUT(aNew[nCnt][5],xValue))
      ENDIF
   NEXT
   fOld->(DBSKIP(1))
ENDDO

IF SELECT("fNew") > 0
   CLOSE fNew
ENDIF 
IF SELECT("fOld") > 0
   CLOSE fOld
ENDIF 


// Fa una copia di sicurezza
IF dfSet( AI_UPDCREATEBAK )
   FERASE( cOld +".bak" )
   FRENAME( cOld +dfDbfExt(cRDD), cOld +".bak" )
ENDIF

// RINOMINA .DBF
FERASE( cOld +dfDbfExt(cRDD) )
FRENAME( cNew +dfDbfExt(cRDD), cOld +dfDbfExt(cRDD) )

// RINOMINA .DBT
DO CASE
   CASE dfRddFile( cNew +dfMemoExt(cRDD), cRDD )     // Rinomino il memo
        IF dfSet( AI_UPDCREATEBAK )
           FERASE( cOld +".ba2" )
           FRENAME( cOld +dfMemoExt(cRDD), cOld +".ba2" )
        ENDIF
        FERASE(  cOld +dfMemoExt(cRDD)  )
        FRENAME( cNew +dfMemoExt(cRDD) ,;
                 cOld +dfMemoExt(cRDD)  )

   CASE dfRddFile( cNew +".DBT", cRDD )              // Alcuni RDD per compatibilita'
        IF dfSet( AI_UPDCREATEBAK )
           FERASE( cOld +".ba2" )
           FRENAME( cOld +".DBT", cOld +".ba2" )
        ENDIF
        FERASE(  cOld +".DBT"  )          // Hanno i memo DBT, anche se
        FRENAME( cNew +".DBT" ,;          // Il loro standard e' diverso
                 cOld +".DBT"  )

   OTHERWISE //---------------- C'ERA UN MEMO CHE E' STATO TOLTO
        IF dfRddFile( cOld +dfMemoExt(cRDD), cRDD )
           IF dfSet( AI_UPDCREATEBAK )
              FERASE( cOld +".ba2" )
              FRENAME( cOld +dfMemoExt(cRDD), cOld +".ba2" )
           ENDIF
           FERASE( cOld +dfMemoExt(cRDD) )
        ENDIF
ENDCASE

dfRd( cTmpPath )                     // Cancello il sottodirettorio

lToReindex := .T.

RETURN .T.


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfStruCmp( aNew, aOld,cRdd  ) // Confronto le due strutture
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .F., nFie

//DEFAULT cRDD TO "DBFNTX"

IF LEN(aNew)==LEN(aOld)
   FOR nFie := 1 TO LEN(aNew)
      //Mantis 936
      //IF !(UPPER(ALLTRIM(aNew[nFie][1]))==UPPER(ALLTRIM(aOld[nFie][1])) .AND. ;
      //     UPPER(ALLTRIM(aNew[nFie][2]))==UPPER(ALLTRIM(aOld[nFie][2])) .AND. ;
      //                   aNew[nFie][3]  ==              aOld[nFie][3]   .AND. ;
      //                   aNew[nFie][4]  ==              aOld[nFie][4])
      //   EXIT
      //ENDIF
      IF !(UPPER(ALLTRIM(aNew[nFie][DBS_NAME]))==UPPER(ALLTRIM(aOld[nFie][DBS_NAME])) .AND. ;
           UPPER(ALLTRIM(aNew[nFie][DBS_TYPE]))==UPPER(ALLTRIM(aOld[nFie][DBS_TYPE])) .AND. ;
                         aNew[nFie][DBS_LEN]   ==              aOld[nFie][DBS_LEN ]   .AND. ; 
                         aNew[nFie][DBS_DEC]   ==              aOld[nFie][DBS_DEC ] )




         // In caso di campi memo in presenza di DBE CDX la lunghezza campo Š 4 e non 10 come per DBFNTX
         //IF !(ALLTRIM(UPPER(cRDD))          == "DBFCDX" .AND. ;
         //     ALLTRIM(UPPER(aNew[nFie][2])) == "M")
         //   EXIT
         //ENDIF

         IF UPPER(ALLTRIM(aNew[nFie][DBS_TYPE])) == UPPER(ALLTRIM(aOld[nFie][DBS_TYPE])) .AND. ; 
            ALLTRIM(UPPER(aNew[nFie][DBS_TYPE])) == "M"  .AND. ;
            (aNew[nFie][DBS_LEN] == 4 .OR. aNew[nFie][DBS_LEN] == 10 )
            //OK sono identici
         ELSEIF  UPPER(ALLTRIM(aNew[nFie][DBS_NAME])) == UPPER(ALLTRIM(aOld[nFie][DBS_NAME])) .AND. ;
                 UPPER(ALLTRIM(aNew[nFie][DBS_TYPE])) == UPPER(ALLTRIM(aOld[nFie][DBS_TYPE])) .AND. ;
                 UPPER(ALLTRIM(aNew[nFie][DBS_TYPE])) <> "N"                                  .AND. ; 
                               aNew[nFie][DBS_LEN]    ==               aOld[nFie][DBS_LEN ]   //.AND. ; 
                 //              aNew[nFie][DBS_DEC]    <>               aOld[nFie][DBS_DEC ]      
             //OK: trovato delle casistiche in cui nel dbddd i ltipo "C" ha un decimale e il DBF ovviamente no.
         ELSE
            EXIT
         ENDIF


      ENDIF
   NEXT
   IF nFie>LEN(aNew)
      lRet := .T.
   ENDIF
ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfUpdDbfAdd( aField, nField, aNewField, nCnt, aNew )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T., cData, cOldType, uFie, cNewType, uWrite, lChanged

// Trasforma il vecchio dato in carattere
cOldType := UPPER(aField[DBS_TYPE])
uFie     := fOld->(FIELDGET( nField ))
DO CASE
   CASE cOldType $ "CM"; cData := {|u    |     u}
   CASE cOldType == "D"; cData := {|u    |DTOC(u)}
   CASE cOldType == "L"; cData := {|u    |IF(  u, "T", "F" )}
   CASE cOldType == "N"; cData := {|u,l,d|STR( u,l,d)}
   OTHERWISE; lRet:=.F.
ENDCASE

IF lRet
   // Scrittura nuovo campo
   cNewType := UPPER( aNewField[DBS_TYPE] )
   DO CASE
      CASE cNewType $ "CM"; uWrite := {|u|     u}
      CASE cNewType == "D"; uWrite := {|u|CTOD(u)}
      CASE cNewType == "L"; uWrite := {|u|IF(  u=="T", .T., .F. )}
      CASE cNewType == "N"
           DO CASE
              CASE aNewField[DBS_LEN]-aNewField[DBS_DEC] >= aField[DBS_LEN]-aField[DBS_DEC] .AND.; // Int
                   aNewField[DBS_DEC]                    >= aField[DBS_DEC]                        // Dec
                   uWrite := {|u|VAL(u)}
              OTHERWISE
                   uWrite := &( "{|u|dfUpdFld(u," +STR(aNewField[DBS_LEN]-aNewField[DBS_DEC]) +"," +STR(aNewField[DBS_DEC]) +")}" )
           ENDCASE
      OTHERWISE; lRet:=.F.
   ENDCASE

   IF lRet
      lChanged := !(aField[DBS_TYPE]==aNewField[DBS_TYPE] .AND. ;
                    aField[DBS_LEN ]==aNewField[DBS_LEN ] .AND. ;
                    aField[DBS_DEC ]==aNewField[DBS_DEC ] )

      AADD( aNew, { nField          ,;
                    cData           ,;
                    aField[DBS_LEN] ,;
                    aField[DBS_DEC] ,;
                    nCnt            ,;
                    uWrite          ,;
                    lChanged        })
   ENDIF
ENDIF

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfUpdFld( cFie, nInt, nDec )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nVal := VAL(cFie), cDec

IF nDec>0             // If there are decimals decrease the int size
   nInt--
ENDIF

IF INT(nVal)>=10^nInt // If over the field delete the field
   nVal := 0
ENDIF
IF nDec==0            // If no decimal delete
   nVal := INT(nVal)
ELSE
   cDec := ALLTRIM( STR(nVal-INT(nVal)) ) // Reduce the number of decimals
   cDec := LEFT( cDec, nDec+2 )
   nVal := INT(nVal)+VAL(cDec)
ENDIF

RETURN nVal

/////////////////////////////////////////////////////
//Mantis 2227 Luca 06/07/2013
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
//Ritorna .T. se le due strututre sono identiche.
FUNCTION dfCompareDBStruct(aOld,aNew )
  LOCAL lRet := .T.
  LOCAL nN   := 0
  LOCAL nI   := 0
  LOCAL cFIE := ""
  IF LEN(aOLD) <> LEN(aNew)
     lRet := .F.
     RETURN lRet
  ENDIF 
  //Scritto solo per debug e ritolto
  //FOR nN := 1 TO LEN(aNew)
  //    cFIE := aNew[nN][DBS_NAME]
  //    cFie := Upper(alltrim(cFie))
  //    nI   := ASCAN(aOLD, {|x|Upper(alltrim(x[DBS_NAME] )) ==  cFIE })
  //    IF nI <= 0
  //       lRet := .F.
  //       RETURN lRet
  //    ENDIF 
  //
  //NEXT 

  FOR nN := 1 TO LEN(aOLD)
      cFIE := aOLD[nN][DBS_NAME]
      cFie := Upper(alltrim(cFie))
      nI   := ASCAN(aNew, {|x|Upper(alltrim(x[DBS_NAME] )) ==  cFIE })
      IF nI <= 0
         lRet := .F.
         RETURN lRet
      ENDIF 
      IF aOLD[nN][DBS_LEN]                  <> aNew[nI][DBS_LEN] .OR.;
         aOLD[nN][DBS_DEC]                  <> aNew[nI][DBS_DEC] .OR.;
         UPPER(ALLTRIM(aOLD[nN][DBS_TYPE])) <> UPPER(ALLTRIM(aNew[nI][DBS_TYPE] ))

         IF UPPER(ALLTRIM(aOLD[nN][DBS_TYPE]))  == UPPER(ALLTRIM(aNew[nI][DBS_TYPE] )) .AND.; 
            ALLTRIM(UPPER(aNew[ nI][DBS_TYPE])) == "M"    .AND. ;
            (aNew[nI][DBS_LEN] == 4 .OR. aNew[nI][DBS_LEN] == 10)
            //OK sono identici
            LOOP
         ENDIF

         IF  UPPER(ALLTRIM(aNew[nI][DBS_TYPE])) == UPPER(ALLTRIM(aOld[nN][DBS_TYPE])) .AND. ;
             UPPER(ALLTRIM(aNew[nI][DBS_TYPE])) <> "N"                                .AND. ; 
                           aNew[nI][DBS_LEN]    ==               aOld[nN][DBS_LEN ]   
            //Se non Š numerico ignoro l differenze sui decimali
            LOOP
         ENDIF

         lRet := .F.
         RETURN lRet
      ENDIF 
  NEXT 
RETURN lRet
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
