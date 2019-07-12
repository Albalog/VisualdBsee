//*****************************************************************************
//Progetto       : dBsee for Xbase++
//Descrizione    : Invio Email
//Programmatore  : Simone Degl'Innocenti
//*****************************************************************************

#include "common.ch"
#include "directry.ch"
#include "fileio.ch"
#include "dll.ch"
#include "nls.ch"

#define USA_CFUNC // il metoodo standard non funziona

// ------------------------------------------------------
// Imposta data/ora per un file
// xFile = handle o nome file
// dDate = data default=DATE()
// cTime = ora (formato oo:mm:ss:ms)
// lCT   = imposta creation time default=.F.
// lLAT  = imposta last access time default=.F.
// lLWT  = imposta last write time default=.T.
// ------------------------------------------------------
FUNCTION dfSetFileTime(xFile, dDate, cTime, lCT, lLAT, lLWT)
   LOCAL lOpen := .F.
   LOCAL lRet := .F.
   LOCAL aTime
   LOCAL cST
   LOCAL cFT
   LOCAL cFT1
   LOCAL nH := 0
   LOCAL nM := 0
   LOCAL nS := 0
   LOCAL nMS:= 0
   LOCAL cCT  := 0 // NULL
   LOCAL cLAT := 0 // NULL
   LOCAL cLWT := 0 // NULL
   LOCAL nAtr

   DEFAULT dDate TO DATE()
   DEFAULT cTime TO _dfTIME()
   DEFAULT lCT   TO .F.
   DEFAULT lLAT  TO .F.
   DEFAULT lLWT  TO .T.

   IF VALTYPE(xFile) == "C"
      xFile := FOPEN(xFile, FO_READWRITE)
      lOpen := .T.
   ENDIF

   IF xFile <= 0
      RETURN .F.
   ENDIF

   // converte ora nei vari "pezzi"
   aTime := dfStr2Arr(cTime, ":")

   IF LEN(aTime) >= 1
      nH := VAL(aTime[1]) 
   ENDIF
   IF LEN(aTime) >= 2
      nM := VAL(aTime[2]) 
   ENDIF
   IF LEN(aTime) >= 3
      nS := VAL(aTime[3]) 
   ENDIF
   IF LEN(aTime) >= 4
      nMS:= VAL(aTime[4]) 
   ENDIF


   cST := W2BIN( YEAR(dDate) )  + ;
          W2BIN( MONTH(dDate) )  + ;
          W2BIN( DOW(dDate)-1 )  + ;
          W2BIN( DAY(dDate) )  + ;
          W2BIN( nH ) + ;
          W2BIN( nM ) + ;
          W2BIN( nS ) + ;
          W2BIN( nMS ) 

#ifdef USA_CFUNC
   nAtr := 0
   IF lCT
      nAtr+=1
   ENDIF
   IF lLAT
      nAtr+=2
   ENDIF
   IF lLWT
      nAtr+=4
   ENDIF

   lRet := _DFSETFILETIME(cST, xFile, nAtr) != 0

#else
   cFT := W2BIN(0)+W2BIN(0)+W2BIN(0)+W2BIN(0)
   cFT1:= W2BIN(0)+W2BIN(0)+W2BIN(0)+W2BIN(0)

   lRet := DllCall("KERNEL32.DLL", DLL_STDCALL, "SystemTimeToFileTime", cST, @cFT) != 0

   // converte in orario UTC
   lRet := DllCall("KERNEL32.DLL", DLL_STDCALL, "LocalFileTimeToFileTime", @cFT, @cFT1) != 0

   IF lCT 
      cCT := cFT1
   ENDIF
   IF lLAT
      cLAT := cFT1
   ENDIF
   IF lLWT 
      cLWT := cFT1
   ENDIF

   IF lRet
      lRet := DllCall("KERNEL32.DLL", DLL_STDCALL, "SetFileTime", xFile, @cCT, @cLAT, @cLWT) != 0
   ENDIF
#endif

   IF lOpen
      FCLOSE(xFile)
   ENDIF
RETURN lRet

// ritorna array con 
// data, ora creazione file
// data, ora last access file
// data, ora last write file
// NOTA:
// il TIME Š ritornato sempre in un formato
// HH:MM:SS con il separatore=":"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfGetFileTime( cFile )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aFile, aRet:= {{CTOD(""), "00:00:00:00"}, ;
                     {CTOD(""), "00:00:00:00"}, ;
                     {CTOD(""), "00:00:00:00"}  }
LOCAL aOld
IF cFile != nil
   aOld := {SetLocale(NLS_STIME, ":"), SET(_SET_TIME, "HH:MM:SS") }
   aFile := DIRECTORY( cFile )
   AEVAL( aFile, {|x|aRet[1][1]:=x[F_CREATION_DATE], ;
                     aRet[1][2]:=x[F_CREATION_TIME], ;
                     aRet[2][1]:=x[F_ACCESS_DATE  ], ;
                     aRet[2][2]:=x[F_ACCESS_TIME  ], ;
                     aRet[3][1]:=x[F_WRITE_DATE   ], ;
                     aRet[3][2]:=x[F_WRITE_TIME   ]  } )

   SET(_SET_TIME, aOld[2])
   SetLocale(NLS_STIME, aOld[1])
ENDIF
RETURN aRet
