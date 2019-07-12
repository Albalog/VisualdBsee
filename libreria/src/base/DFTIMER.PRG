//*****************************************************************************
// Projects       : dBsee 4.5
// Description    : Utility function to display a timer
// Programmer     : Original: Baccan Matteo
// Programmer     : Modified by: William G. Berndt, 4/6/1997
// Changes        : 1. Added a parameter for the window title
//                : 2. Added the ability to set the timer for countdown.
//                : 3. dfTimer will now play an  alarm sound when at 0.
//*****************************************************************************
#INCLUDE "dfCTRL.ch"                                 // Controls
#INCLUDE "dfMsg.ch"                                  // General messages
#INCLUDE "dfSet.ch"                                  // Environment settings
#INCLUDE "common.ch"                                 // Standard

STATIC cHh      := "00"   ,;
       cMm      := "01"   ,;
       cSs      := "00"   ,;
       cTimer   := ""     ,;
       nSeconds := 0      ,;
       cSetTime := ""     ,;
       chhmm    := "0000"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTimer( dfsTitle, lDown )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL uRet, nOld
DEFAULT lDown TO .F.

nOld := dfSet( AI_GETTIMEOUT, 999999 ) // Change Timeout to 277 hours.

uRet := _dfSTimer( lDown, dfsTitle )

dfSet( AI_GETTIMEOUT, nOld )       // Restore Timeout to 120 Seconds.

RETURN uRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION _dfSTimer( lDown, dfTitle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aCTRL := {}

IF lDown
   cHh := "00" ; cMm := "01" ; cSs := "00"
   cTimer   := cHh+":"+cMm+":"+cSs
   nSeconds := INT(SECONDS())
   chhmm    := "000000"

   dfGetW( 10, 28, "Timer Setting Hh:Mm:Ss :", @chhmm, "@R 99:99:99")

   IF VAL(chhmm) == 0
      dbMsgErr( "To use the timer feature//you must enter a starting time")
      RETURN .F.
   ENDIF

   cHh := SUBSTR(chhmm,1,2)
   cMm := SUBSTR(chhmm,3,2)
   cSs := SUBSTR(chhmm,5,2)
ENDIF

ATTACH "01" TO aCTRL FUNCTION _dfTimer(1,lDown) AT 1, 1, 1, 52 REALTIME
ATTACH "02" TO aCTRL FUNCTION _dfTimer(2,lDown) AT 2, 1, 2, 52 REALTIME
ATTACH "03" TO aCTRL FUNCTION _dfTimer(3,lDown) AT 3, 1, 3, 52 REALTIME
ATTACH "04" TO aCTRL FUNCTION _dfTimer(4,lDown) AT 4, 1, 4, 52 REALTIME
ATTACH "05" TO aCTRL FUNCTION _dfTimer(5,lDown) AT 5, 1, 5, 52 REALTIME
ATTACH "06" TO aCTRL FUNCTION _dfTimer(6,lDown) AT 6, 1, 6, 52 REALTIME

// Taken from dfAutoForm

ATTACH "__WRI" TO aCTRL GET AS PUSHBUTTON dfStdMsg(MSG_DBMSGERR)     ;
                        AT  7, 27, 9, 38                             ; // Coordinates
                        FUNCTION {||dbAct2Kbd("wri")}   // Function of control

RETURN dfAutoForm( NIL, NIL, aCTRL, dfTitle,, "__WRI" )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION _dfTimer(nRow,lDown)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aTimer
LOCAL nPos := 0, aRet

IF nRow==1
   aTimer := {"","","","","",""}
   IF lDown
      IF nSeconds+1 <= INT(SECONDS())
         nSeconds := INT(SECONDS())
         DO CASE
            CASE VAL(cSs) > 0
                 cSs := PADL(ALLTRIM(STR( (VAL(cSs) - 1) )), 2, "0")

            CASE VAL(cSs) == 0 .AND. VAL(cMm) > 0
                 cSs := "59"
                 cMm := PADL(ALLTRIM(STR( (VAL(cMm) - 1) )), 2, "0")

            CASE VAL(cMm) == 0 .AND. VAL(cHh) > 0
                 cMm := "59"
                 cSs := "59"
                 cHh := PADL(ALLTRIM(STR( (VAL(cHh) - 1) )), 2, "0")

            CASE VAL(cHh) == 0 .AND. VAL(cMm) == 0 .AND. VAL(cSs) == 0
                 TONE( 832.36,1)
                 TONE( 832.36,1)
                 dfPause( 1 )
         END CASE
         cTimer := cHh+":"+cMm+":"+cSs
      ENDIF
   ELSE
      cTimer := TIME()
   ENDIF
   WHILE ++nPos<9
      aRet := _dfNum(SUBSTR(cTimer,nPos,1))
      aTimer[1] += aRet[1]
      aTimer[2] += aRet[2]
      aTimer[3] += aRet[3]
      aTimer[4] += aRet[4]
      aTimer[5] += aRet[5]
      aTimer[6] += aRet[6]
   ENDDO
ENDIF

RETURN aTimer[nRow]

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION _dfNum(cNum)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aRet := {}
DO CASE
   CASE cNum=="0"
        aRet := {"ÚÄÄÄÄÄÄ¿",;
                 "³ÚÄÄÄÄ¿³",;
                 "³³    ³³",;
                 "³³    ³³",;
                 "³ÀÄÄÄÄÙ³",;
                 "ÀÄÄÄÄÄÄÙ"}
   CASE cNum=="1"
        aRet := {" ÚÄÄÄ¿  ",;
                 " À¿  ³  ",;
                 "  ³  ³  ",;
                 "  ³  ³  ",;
                 "ÚÄÙ  ÀÄ¿",;
                 "ÀÄÄÄÄÄÄÙ"}
   CASE cNum=="2"
        aRet := {"ÚÄÄÄÄÄÄ¿",;
                 "ÀÄÄÄÄ¿ ³",;
                 "ÚÄÄÄÄÙ ³",;
                 "³ ÚÄÄÄÄÙ",;
                 "³ ÀÄÄÄÄ¿",;
                 "ÀÄÄÄÄÄÄÙ"}
   CASE cNum=="3"
        aRet := {"ÚÄÄÄÄÄÄ¿",;
                 "ÀÄÄÄÄ¿ ³",;
                 " ÚÄÄÄÙ ³",;
                 " ÀÄÄÄ¿ ³",;
                 "ÚÄÄÄÄÙ ³",;
                 "ÀÄÄÄÄÄÄÙ"}
   CASE cNum=="4"
        aRet := {"ÚÄ¿     ",;
                 "³ ³     ",;
                 "³ ³ ÚÄ¿ ",;
                 "³ ÀÄÙ À¿",;
                 "ÀÄÄÄ¿ ÚÙ",;
                 "    ÀÄÙ "}
   CASE cNum=="5"
        aRet := {"ÚÄÄÄÄÄÄ¿",;
                 "³  ÚÄÄÄÙ",;
                 "³  ÀÄÄÄ¿",;
                 "ÀÄÄÄ¿  ³",;
                 "ÚÄÄÄÙ  ³",;
                 "ÀÄÄÄÄÄÄÙ"}
   CASE cNum=="6"
        aRet := {"ÚÄÄÄÄÄÄ¿",;
                 "³ ÚÄÄÄÄÙ",;
                 "³ ÀÄÄÄÄ¿",;
                 "³ ÚÄÄ¿ ³",;
                 "³ ÀÄÄÙ ³",;
                 "ÀÄÄÄÄÄÄÙ"}
   CASE cNum=="7"
        aRet := {"ÚÄÄÄÄÄÄ¿",;
                 "ÀÄÄÄ¿  ³",;
                 "    ³  ³",;
                 "    ³  ³",;
                 "    ³  ³",;
                 "    ÀÄÄÙ"}
   CASE cNum=="8"
        aRet := {"ÚÄÄÄÄÄÄ¿",;
                 "³ ÚÄÄ¿ ³",;
                 "³ ÀÄÄÙ ³",;
                 "³ ÚÄÄ¿ ³",;
                 "³ ÀÄÄÙ ³",;
                 "ÀÄÄÄÄÄÄÙ"}
   CASE cNum=="9"
        aRet := {"ÚÄÄÄÄÄÄ¿",;
                 "³ ÚÄÄ¿ ³",;
                 "³ ÀÄÄÙ ³",;
                 "ÀÄÄÄÄ¿ ³",;
                 "ÚÄÄÄÄÙ ³",;
                 "ÀÄÄÄÄÄÄÙ"}
   OTHERWISE
        aRet := {"        ",;
                 "  ÚÄ¿   ",;
                 "  ÀÄÙ   ",;
                 "  ÚÄ¿   ",;
                 "  ÀÄÙ   ",;
                 "        "}
ENDCASE
RETURN aRet
