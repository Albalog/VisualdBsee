#include "Common.ch"
#include "FileIo.ch"
#include "dfReport.ch"
#include "dfSet.ch"

//Mantis 2080
FUNCTION dfReportINIPath(cSet)
  STATIC cPATH
  LOCAL cRet := ""
  LOCAL lOpenIni

  lOpenIni  := dfIsIni()

  IF cPATH == NIL 
     IF !EMPTY(dfSet("xbaseUserReportiniPath"))
       cPATH := dfPathchk(dfSet("xbaseUserReportiniPath"))
     ELSE
       cPATH := dfInitPath()
     ENDIF 
     dfArrRep(.T.)
  ENDIF 
        
  IF cSet == NIL  .OR. VALTYPE(cSet) != "C"
     cRET := cPATH
  ELSE 
     cPATH := dfPathchk(cSET)
     cRET  := cPATH
     dfArrRep(.T.)
  ENDIF    

  IF lOpenIni .AND. !dfIsIni()
     dfIniOpen()
  ENDIF 

RETURN cRet 
