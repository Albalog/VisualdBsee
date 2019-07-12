/******************************************************************************
Project     : dBsee 4.5
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Common.ch"
#include "directry.ch"

#define DIR_NAM     1
#define DIR_PATH    2
#ifndef __XPP__
   #define T_BRANCH    'ÃÄ'
   #define L_BRANCH    'ÀÄ'
   #define I_BRANCH    '³ '
#else
   #define T_BRANCH    '+-'
   #define L_BRANCH    '+-'
   #define I_BRANCH    '| '
#endif
#define NO_BRANCH   '  '

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPathTree( cCurPath, l95 )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aName, nRet, cRet := ""

DEFAULT cCurPath TO dfCURPATH()
DEFAULT l95      TO .F.

cCurPath := dfPathChk(cCurPath)

dbMsgOn()
   aName := _dfPathTree( cCurPath, 1, l95 )
dbMsgOff()

nRet := dfArrWin( ,,,, aName[ DIR_NAM ] )
IF nRet>0
  cRet := aName[ DIR_PATH ][ nRet ]
ENDIF

RETURN cRet


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION _dfPathTree(cCurPath,nStep,l95)//, lSetSpin)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aDirLst:={}, aSubDirLst:={}
LOCAL lLastNam, cNextPath, cNextDir, aRetArr:={{},{}}

#ifndef __XPP__
IF l95
   aeval( dfWinDirectory( cCurPath + "*.*", "D" ), ;
          {|aDir| IF( "D" $(aDir[F_ATTR]) .AND. aDir[F_NAME] # ".", ;
              aadd( aDirLst, T_BRANCH + aDir[F_NAME] ), ) };
        )
ELSE
#endif
   aeval( DIRECTORY( cCurPath + "*.*", "D" ), ;
          {|aDir| IF( "D" $(aDir[F_ATTR]) .AND. aDir[F_NAME] # ".", ;
              aadd( aDirLst, T_BRANCH + aDir[F_NAME] ), ) };
        )
#ifndef __XPP__
ENDIF
#endif

IF !empty( aDirLst )
   asort( aDirLst )
   aDirLst[len( aDirLst )] = L_BRANCH + substr( aDirLst[len( aDirLst )], 3 )
endif

// now search each of these names for subdirectories

aeval( aDirLst, {|cNextDir|  dbMsgUpd( "Path ø " +STR(nStep++) ) ,; //Spinner(lSpin), lSpin:=.f., ;
;
; // create new search path by appending the name to our current path
;
      cNextPath := cCurPath + substr( cNextDir, 3 ) + "\", ;
;
; // save the directory and pathname to our return array
;
      aadd( aRetArr[DIR_NAM], cNextDir ), ;
      aadd( aRetArr[DIR_PATH], cNextPath ), ;
;
; // set a flag to indicate if this is last directory name in the list
;
      lLastNam := ( cNextDir == aDirLst[len( aDirLst )] ), ;
;
; // search next directory by making a recursive call
;
      aSubDirLst := _dfPathTree( cNextPath,@nStep,l95 ), ;
;
; // add the new subdirectories and pathnames to our return array
;
      aeval( aSubDirLst[DIR_NAM], {|cNewDirNam| ;
            aadd( aRetArr[DIR_NAM], IIF( lLastNam, NO_BRANCH, I_BRANCH ) + ;
                  cNewDirNam )} ), ;
      aeval( aSubDirLst[DIR_PATH], {|cNewDirPath| ;
            aadd( aRetArr[DIR_PATH], cNewDirPath )} )} ;
     )

// if this is the root then we're almost done

IF SUBSTR( cCurPath, 2 ) == ":\" .OR. cCurPath == "\"

   // root info gets inserted as first element of each subarray

   aadd( aRetArr[DIR_NAM], ); aadd( aRetArr[DIR_PATH], )
   ains( aRetArr[DIR_NAM], 1 ); ains( aRetArr[DIR_PATH], 1 )
   aRetArr[DIR_NAM, 1] := aRetArr[DIR_PATH, 1] := cCurPath

ENDIF

RETURN( aRetArr )
