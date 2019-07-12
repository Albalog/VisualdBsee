#include "dfMsg.CH"
#include "dfset.ch"
#include "inkey.ch"
#include "dfNet.ch"
#include "Common.ch"
#include "FileIO.ch"
#include "dfBackup.ch"
#include "dfIndex.ch"
#include "dfStd.ch"



FUNCTION dfGetVDBLogin()
  LOCAL lRet := .F.
  LOCAL cAzi, cUser , lFound , nCount, cDate, ctime , nRecno, nRecFree, cUserProg

  IF dbCfgOpen("DBLKINF")      // Open database

     cAzi      := PADR(dfVdbAzi()      , LEN(DBLKINF->AZI ))
     cUser     := PADR(dfVdbUser()     , LEN(DBLKINF->USER))
     cUserProg := PADR(dfVdbUserProg() , LEN(DBLKINF->USERPROG))

     lFound   := .F.
     nCount   := 1
     nRecFree := 0
     DBLKINF->(dfs(1,"A"+cAzi ))
     DO WHILE !DBLKINF->(EOF()) .AND. DBLKINF->RECTYPE == "A"  .AND.  DBLKINF->AZI == cAZI
        nRecno  := DBLKINF->(Recno())
        IF DBLKINF->USER == cUSER  .AND. DBLKINF->USERPROG == cUserProg
           nCount++
           cDate    := DTOC(DBLKINF->LOGDATE)
           cTime    := DBLKINF->LOGTIME
           IF DBLKINF->(DBRLOCK(nRecno))
              lFound   := .T.
              DBLKINF->(dbDelete())
              DBLKINF->(dbCommit())
              DBLKINF->(DBRUNLOCK(nRecno) )
           ENDIF 
        ENDIF 
        DBLKINF->(dbskip())
     ENDDO
     lRet := lFound
   ENDIF 
RETURN lRet 


FUNCTION dfSetVDBLogin(lCeckAccessiAzi,lCeckAccessiUsr)
  LOCAL lRet := .F.
  LOCAL cAzi, cUser , lFound , nCount, cDate, ctime , nRecno, nRecFree
                    
  DEFAULT  lCeckAccessiAzi  TO .T. //Creare un setaggio
  DEFAULT  lCeckAccessiUsr  TO .T. //Creare un setaggio


  IF dbCfgOpen("DBLKINF")      // Open database

     cAzi     := PADR(dfVdbAzi()  , LEN(DBLKINF->AZI ))
     cUser    := PADR(dfVdbUser() , LEN(DBLKINF->USER))

     lFound   := .F.
     nCount   := 1
     nRecFree := 0
     DBLKINF->(dfs(1,"A"+cAzi ))
     DO WHILE !DBLKINF->(EOF()) .AND. DBLKINF->RECTYPE == "A"  .AND.  DBLKINF->AZI == cAZI
        nRecno  := DBLKINF->(Recno())
        IF DBLKINF->USER == cUSER  
           nCount++
           nCount   := MAX(VAL(DBLKINF->USERPROG),nCount)
           cDate    := DTOC(DBLKINF->LOGDATE)
           cTime    := DBLKINF->LOGTIME


           //IF !DBLKINF->(DBRLOCK(nRecno))
           IF !( ASCAN( dfLockList(), nRecno )!=0 .OR. DBLKINF->(DBRLOCK(nRecno)))
              lFound   := .T.
           ELSE
              nRecFree :=  nRecNo
              //dfalert(nRecFree)
           ENDIF 
        ENDIF 
        DBLKINF->(dbskip())
     ENDDO

     IF lFound .AND. lCeckAccessiUsr //lCeckAccessiAzi 
        IF lCeckAccessiAzi 
           dbMsgErr("Un utente con lo stesso nome <"+Alltrim(cUser)+"> si Š loggato al sistema alla stessa azienda <"+Alltrim(cAzi)+">//alle " + cTime+ " del "+cDate )
        ELSE
           dbMsgErr("Un utente con lo stesso nome <"+Alltrim(cUser)+"> si Š loggato al sistema alle " + cTime+ " del "+cDate )
        ENDIF 
        //dbCfgClose("DBLKINF")     // Close LockInfo
        dfVdbUserProg(-1*nCount)
        RETURN lRet 
     ENDIF 

     IF nRecFree  > 0
        DBLKINF->(dbGoto(nRecFree))
        dfVdbUserProg(DBLKINF->USERPROG)
     ELSE 
        DBLKINF->(DBAPPEND())
     ENDIF 
     nRecno  := DBLKINF->(Recno())
     IF nRecno >0 .AND. ;
       (ASCAN( dfLockList(), nRecno )!=0 .OR. DBLKINF->(DBRLOCK(nRecno)))
        DBLKINF->RECTYPE    := "A"
        DBLKINF->USER       := cUSER
        DBLKINF->USERPROG   := STRZERO(nCount,LEN(DBLKINF->USERPROG) )
        DBLKINF->AZI        := cAZI
        DBLKINF->DBF        := ""
        DBLKINF->NUMREC     := 0
        DBLKINF->LOGDATE    := Date()
        DBLKINF->LOGTIME    := Time()
        DBLKINF->FREELOG    := ""
        DBLKINF->(dbCommit())
        DBLKINF->(dbSkip(0))
        //dfalert(time())
        dfVdbUserProg(STRZERO(nCount,LEN(DBLKINF->USERPROG) ))

     ENDIF 

  //ENDIF 
  ENDIF 

  //dbCfgClose("DBLKINF")     // Close LockInfo

  lRet := .T.
RETURN lRet 

FUNCTION dfGetLockInfo(nRec)
  LOCAL cRet, cRec
  LOCAL cAzi, cUser, cAlias
  LOCAL cDate, ctime , nRecno, nRecFree, lFound
  LOCAL cUserProg

  IF nRec  == NIL
     RETURN NIL
  ENDIF 

  cAlias    := Alias()
  dfPushArea()

  IF .T. //dbCfgOpen("DBLKINF")      // Open database

     cAlias    := PADR(cAlias,LEN(DBLKINF->DBF ) )
     cRec      := STR(nRec, LEN(STR(DBLKINF->NUMREC) ), 0)

     cAzi      := PADR(dfVdbAzi()      , LEN(DBLKINF->AZI ))
     cUser     := PADR(dfVdbUser()     , LEN(DBLKINF->USER))
     cUserProg := PADR(dfVdbUserProg() , LEN(DBLKINF->USERPROG))

     lFound    := DBLKINF->(dfs(1,"T"+cAzi+cAlias+cRec ))

     IF lFound  
        nRecno    := DBLKINF->(Recno())
        //cDate    := DTOS(DBLKINF->LOGDATE)
        //cTime    := DBLKINF->LOGTIME

        //dbMsgErr("L'utente <"+Alltrim(DBLKINF->USERPROG)+"> ha loccato il record <"+STR(DBLKINF->NUMREC)+"> dell'archivio <"+Alltrim(DBLKINF->DBF)+;
        //         "> dalle ore " + cTime " del "+cDate )
       
        //DBLKINF->(DBRLOCK(nRecno) )
        IF (ASCAN( dfLockList(), nRecno )!=0 .OR. DBLKINF->(DBRLOCK(nRecno))) 
           DBLKINF->(dbDelete())
           DBLKINF->(dbCommit())
           DBLKINF->(DBRUNLOCK(nRecno) )

        ENDIF 
     ENDIF 
  ENDIF 
  dfPopArea()

  //dbCfgClose("DBLKINF")     // Close LockInfo

RETURN cRet



FUNCTION dfSetLockInfo(nRec)
  LOCAL cRec
  LOCAL cAzi, cUser, cAlias  , lFound
  LOCAL cDate, ctime , nRecno, nRecFree
  LOCAL cUserProg
  LOCAL lRet  := .F.

  IF nRec  == NIL
     RETURN lREt
  ENDIF 

  cAlias    := Alias()
  dfPushArea()

  IF .T. //dbCfgOpen("DBLKINF")      // Open database



     cAzi      := PADR(dfVdbAzi()      , LEN(DBLKINF->AZI ))
     cUser     := PADR(dfVdbUser()     , LEN(DBLKINF->USER))
     cUserProg := PADR(dfVdbUserProg() , LEN(DBLKINF->USERPROG))

     cAlias    := PADR(cAlias,LEN(DBLKINF->DBF ) )
     cRec      := STR(nRec, LEN( STR(DBLKINF->NUMREC) ), 0)

     lFound    := DBLKINF->(dfs(1,"T"+cAzi+cAlias+cRec ))
     nRecno    := DBLKINF->(Recno())

     //IF lFound  .AND. DBLKINF->(DBRLOCK(nRecno) )
     IF lFound  .AND. ;
        (ASCAN( dfLockList(), nRecno )!=0 .OR. DBLKINF->(DBRLOCK(nRecno))) 

        cDate    := DTOS(DBLKINF->LOGDATE)
        cTime    := DBLKINF->LOGTIME

        IF DBLKINF->NUMREC >0
           dbMsgErr("L'utente <"+Alltrim(DBLKINF->USER) +"-"+Alltrim(DBLKINF->USERPROG)+"> ha loccato il record nø <"+Alltrim(STR(DBLKINF->NUMREC))+"> dell'archivio <"+Alltrim(DBLKINF->DBF)+;
                    "> dalle ore " + cTime +" del "+cDate )
        ELSE 
           dbMsgErr("L'utente <"+Alltrim(DBLKINF->USER) +"-"+Alltrim(DBLKINF->USERPROG)+"> ha loccato l'archivio <"+Alltrim(DBLKINF->DBF)+;
                    "> dalle ore " + cTime +" del "+cDate )
        ENDIF 

        lRet  := .F.
     ELSE 
        IF !lFound
           DBLKINF->(DBAPPEND())
           nRecno  := DBLKINF->(Recno())
        ENDIF 
        //DBLKINF->(DBRLOCK(nRecno) )
        IF (ASCAN( dfLockList(), nRecno )!=0 .OR. DBLKINF->(DBRLOCK(nRecno))) 
           DBLKINF->RECTYPE    := "T"                                       
           DBLKINF->USER       := cUSER                                     
           DBLKINF->USERPROG   := cUserProg //cUSER +"-"+STRZERO(nCount++,4 ) 
           DBLKINF->AZI        := cAZI                                      
           DBLKINF->DBF        := cAlias                                        
           DBLKINF->NUMREC     := nRec                                         
           DBLKINF->LOGDATE    := Date()                                  
           DBLKINF->LOGTIME    := Time()                                    
           DBLKINF->FREELOG    := ""
           DBLKINF->(dbCommit())
           DBLKINF->(dbSkip(0))
           lRet  := .T.
        ENDIF                     
     ENDIF                     
  ENDIF 

  //dbCfgClose("DBLKINF")     // Close LockInfo
  dfPopArea()

RETURN lREt



FUNCTION dfCheckLockInfo(nRec)
  LOCAL cRec
  LOCAL cAzi, cUser, cAlias  , lFound
  LOCAL cDate, ctime , nRecno, nRecFree
  LOCAL cUserProg
  LOCAL lRet  := .F.

  IF nRec  == NIL
     RETURN lREt
  ENDIF 

  cAlias    := Alias()
  dfPushArea()

  IF dbCfgOpen("DBLKINF")      // Open database

     cAzi      := PADR(dfVdbAzi()      , LEN(DBLKINF->AZI ))
     cUser     := PADR(dfVdbUser()     , LEN(DBLKINF->USER))
     cUserProg := PADR(dfVdbUserProg() , LEN(DBLKINF->USERPROG))

     cAlias    := PADR(cAlias,LEN(DBLKINF->DBF ) )
     cRec      := STR(nRec, LEN( STR(DBLKINF->NUMREC) ), 0)

     lFound    := DBLKINF->(dfs(1,"T"+cAzi+cAlias+cRec ))
     nRecno    := DBLKINF->(Recno())

     IF lFound  .AND. !DBLKINF->(DBRLOCK(nRecno) )
        cDate    := DTOS(DBLKINF->LOGDATE)
        cTime    := DBLKINF->LOGTIME

        IF DBLKINF->NUMREC >0
           dbMsgErr("L'utente <"+Alltrim(DBLKINF->USER) +"-"+Alltrim(DBLKINF->USERPROG)+"> ha loccato il record nø <"+Alltrim(STR(DBLKINF->NUMREC))+"> dell'archivio <"+Alltrim(DBLKINF->DBF)+;
                    "> dalle ore " + cTime +" del "+cDate )
        ELSE 
           dbMsgErr("L'utente <"+Alltrim(DBLKINF->USER) +"-"+Alltrim(DBLKINF->USERPROG)+"> ha loccato l'archivio <"+Alltrim(DBLKINF->DBF)+;
                    "> dalle ore " + cTime +" del "+cDate )
        ENDIF 
        lRet  := .F.
     ELSE
        lRet  := .T.
     ENDIF                     
  ENDIF 
  dfPopArea()

  //dbCfgClose("DBLKINF")     // Close LockInfo

RETURN lREt













* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfLockInfoRdd( cRdd )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC cLockInfoRdd := NIL
DEFAULT cLockInfoRdd TO RDDSETDEFAULT()
IF cRdd!=NIL
   cLockInfoRdd := cRdd
ENDIF
// Simone 18/12/2009
// per uso ADS e CDX con XbaseAxsAutoUse=YES
// altrimenti controlla con il driver del DBDD (es DBFNTX)
// e quindi controlla esistenza file .NTX invece di .CDX
IF dfAxsLoaded(dbCfgPath( "DBLKINFPath" ), cLockInfoRdd)
   cLockInfoRdd := dfAXSDriver()
ENDIF
RETURN cLockInfoRdd

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfLockInfoPath()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cPath := dbCfgPath( "DBLKINFPath" )
IF dfASDriver( dfLockInfoRdd() )
   cPath := LEFT( cPath, LEN(cPath)-1 )           // Rimuovo lo slash \ finale
   IF RIGHT(cPath,1)#":" .AND. LEN(cPath)>1       // Se ho un path
      cPath += ":"                                   // Aggiungo i : finali
   ENDIF
ENDIF
RETURN cPath

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfLockInfoExt()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN dfDbfExt(dfLockInfoRdd())

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfLockInfoOnAS( lAS )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lDriver

DEFAULT lAS TO .F.

lDriver := dfASDriver( dfLockInfoRdd() )
IF lAS
   dfLockInfoRdd( "WIN400" )
ENDIF

RETURN lDriver


FUNCTION dfVdbAzi(cSet) 
 STATIC cCODAZI
 LOCAL cRet := ""
 cRET := cCODAZI
 IF VALTYPE(cSet) == "C"
    cCODAZI  := Alltrim(Upper(cSet))
 ENDIF 
 DEFAULT cRet TO ""
RETURN cREt

FUNCTION dfVdbUser(cSet)
   STATIC cCODUSER
   LOCAL cRet := ""

   cRET := cCODUSER
   IF VALTYPE(cSet) == "C"
      cCODUSER  := Alltrim(Upper(cSet))
   ENDIF 
   DEFAULT cRet TO ""
RETURN cREt

FUNCTION dfVdbUserProg(cSet)
   STATIC cCODUSERPROG
   LOCAL cRet := ""
   cRET := cCODUSERPROG
   IF VALTYPE(cSet) == "C"
      cCODUSERPROG  := cSet
   ENDIF 
   DEFAULT cRet TO ""
RETURN cREt



