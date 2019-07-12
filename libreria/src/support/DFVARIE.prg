#include "appevent.ch"
#include "nls.ch"


// Simone 23/04/2004 GERR 3833
// Toglie dalla coda dei messaggi i messaggi keyboard doppi
FUNCTION dfIgnoreKbdEvent(mp1, mp2, oXbp)
   LOCAL nEvent := xbeP_Keyboard
   LOCAL bErr := Errorblock({|e| dfErrBreak(e)})
   LOCAL nEvent2, mp12, mp22, oXbp2
  

   DO WHILE .T.   
      BEGIN SEQUENCE         
         nEvent2 := NextAppEvent(@mp12, @mp22, @oXbp2)
      RECOVER 
         nEvent2 := NextAppEvent() // sembra che cosi non dia errore IDSC

      END SEQUENCE

      IF PCOUNT() >= 3
         IF nEvent2 == nEvent .AND. mp12 == mp1 .AND. mp22 == mp2 .AND. ;
            oXbp2 != oXbp

            AppEvent(@mp12, @mp22, @oXbp2)
         ELSE

            EXIT
         ENDIF
      ELSE
         IF nEvent2 == nEvent .AND. mp12 == mp1 .AND. mp22 == mp2

            AppEvent(@mp12, @mp22, @oXbp2)
         ELSE

            EXIT
         ENDIF
      ENDIF
   ENDDO
   Errorblock(bErr)
RETURN NIL


// Simone 23/04/2004 GERR 3833
// Workaround per errore IDSC su NextAppEvent()
FUNCTION dfNextAppEvent(mp1, mp2, oXbp)
   LOCAL m1:=NIL, m2:=NIL, o:=NIL
   LOCAL nEvent
   LOCAL bErr := Errorblock({|e| dfErrBreak(e)})
   LOCAL nEvent2, mp12, mp22, oXbp2

   BEGIN SEQUENCE         
      nEvent := NextAppEvent(@mp12, @mp22, @oXbp2)
   RECOVER 
      nEvent := NextAppEvent() // sembra che cosi non dia errore IDSC
   END SEQUENCE

   mp1:=m1
   mp2:=m2
   oXbp:=o
   Errorblock(bErr)
RETURN nEvent
   
FUNCTION dfCenterPos(aSize, aParentSize)
RETURN { INT((aParentSize[1] - aSize[1]) / 2), ;
         INT((aParentSize[2] - aSize[2]) / 2)  }

// Serve per Visual dBsee, in modo da poter chiamare 
// la funzione di libreria dBsee for Xbase++
// invece di quella con lo stesso nome in OOL\dfSet.prg
FUNCTION db4x_dfSet(x, y, z); RETURN dfSet(x, y, z)

FUNCTION  dfBox()           ; RETURN NIL
FUNCTION  GETE(cVar)        ; RETURN GETENV(cVar)
FUNCTION  dBsee4FT()        ; RETURN .F.
FUNCTION  dfFTFile()        ; RETURN .F.
PROCEDURE dfFTInizialize()  ; RETURN

FUNCTION  dBsee4CR()        ; RETURN .F.
FUNCTION  dfCRIndExt()      ; RETURN ".NTX"
FUNCTION  dfCRRdd()         ; RETURN ""

FUNCTION  dBsee4AS()        ; RETURN .F.
FUNCTION  dfASFile()        ; RETURN .F.
PROCEDURE dfASAddFile()     ; RETURN
PROCEDURE dfASInizialize()  ; RETURN
FUNCTION  dfASConnec()      ; RETURN .F.
FUNCTION  dfASComman()      ; RETURN .F.
FUNCTION  dfASIndex(x)      ; RETURN x
FUNCTION  dfASCrtLib()      ; RETURN 1
FUNCTION  dfASDelLib()      ; RETURN 1
FUNCTION  dfASCloneEnv()    ; RETURN 1

FUNCTION  dBsee45Win()      ; RETURN .F.
FUNCTION  df5GetParam()     ; RETURN .T.
PROCEDURE df5Window()       ; RETURN
PROCEDURE tb5Config()       ; RETURN

FUNCTION  DFREALMODE()      ; RETURN .F.
FUNCTION  DFDSAVAIL()       ; RETURN 65535
FUNCTION  DFISINMEMO()      ; RETURN .T.
FUNCTION  DFFONTSTR()       ; RETURN ""
PROCEDURE DFFONTCHOICE()    ; RETURN
PROCEDURE dfFontRest()      ; RETURN
PROCEDURE DFSAY()           ; RETURN
PROCEDURE DFSAYBORDER()     ; RETURN
PROCEDURE DFSHADE()         ; RETURN
PROCEDURE _DFSAYBUT()       ; RETURN
PROCEDURE __DBZOOM()        ; RETURN
PROCEDURE dfMenu()          ; RETURN
PROCEDURE dfMenuSay()       ; RETURN
FUNCTION  dfFontDisk()      ; RETURN SPACE(4096)
PROCEDURE dfFontLoad()      ; RETURN
FUNCTION  dfIsShare()       ; RETURN .T.
FUNCTION  dfMemBase()       ; RETURN 0
FUNCTION  dfMemExt()        ; RETURN 0
FUNCTION  dfWorkBar()       ; RETURN .T.
PROCEDURE dfClsRGB()        ; RETURN
PROCEDURE df9BitFont()      ; RETURN
PROCEDURE dfFastKey()       ; RETURN
FUNCTION  dfIsCalc()        ; RETURN .F.
FUNCTION  dfIsDebug()       ; RETURN .F.
PROCEDURE dfFadeIn()        ; RETURN
PROCEDURE dfFadeOut()       ; RETURN
FUNCTION  _libtype()        ; RETURN "NETWORK"
PROCEDURE dbzoom()          ; RETURN
PROCEDURE dfactadd()        ; RETURN
PROCEDURE dfbkg()           ; RETURN
FUNCTION  dfcpu()           ; RETURN 5
FUNCTION  dfDosVer()        ; RETURN "7.0"
FUNCTION  dfFloppyType()    ; RETURN 0
PROCEDURE dfinifont()       ; RETURN
FUNCTION  dfIsIpx()         ; RETURN .F.
FUNCTION  dfisspl()         ; RETURN .F.
FUNCTION  dfSplfile()       ; RETURN NIL
FUNCTION  dfIsWin()         ; RETURN .T.
PROCEDURE dfmouact()        ; RETURN
PROCEDURE dfmourel()        ; RETURN
PROCEDURE dfPro()           ; RETURN
PROCEDURE dfpushpal()       ; RETURN
PROCEDURE dfpoppal()        ; RETURN
FUNCTION  dfpushpalnum()    ; RETURN 0
PROCEDURE dfPushCursor()    ; RETURN
PROCEDURE dfPopCursor()     ; RETURN
FUNCTION  dfPushCurNum()    ; RETURN 0
FUNCTION  dfSetDate()       ; RETURN .F.
FUNCTION  dfSetTime()       ; RETURN .F.
FUNCTION  dfStaHdr()        ; RETURN "000000000000"
PROCEDURE dfSetFont()       ; RETURN
PROCEDURE dfSetPal()        ; RETURN
FUNCTION  dfWinFullScr()    ; RETURN .T.
//FUNCTION  dfWinVer()        ; RETURN "4.0"
FUNCTION  dfRow()           ; RETURN 0   //ROW()
FUNCTION  dfCol()           ; RETURN 0   //COL()
FUNCTION  dfSetPos(x,y)     ; RETURN NIL //SETPOS(x,y)
FUNCTION  dfMemo()          ; RETURN NIL
FUNCTION  S2FU()            ; RETURN NIL                     
                            
// Screen saver             
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfScrSavRnd()     ; RETURN
PROCEDURE dfScrSav1()       ; RETURN
PROCEDURE dfScrSav2()       ; RETURN
PROCEDURE dfScrSav3()       ; RETURN
PROCEDURE dfScrSav4()       ; RETURN
PROCEDURE dfScrSav5()       ; RETURN
PROCEDURE dfScrSav6()       ; RETURN
PROCEDURE dfScrSav7()       ; RETURN
PROCEDURE dfScrSav8()       ; RETURN
PROCEDURE dfScrSav9()       ; RETURN
PROCEDURE dfScrSav10()      ; RETURN
PROCEDURE dfScrSav11()      ; RETURN
PROCEDURE dfScrSav12()      ; RETURN
PROCEDURE dfScrSav13()      ; RETURN
PROCEDURE dfScrSav14()      ; RETURN
PROCEDURE dfScrSav15()      ; RETURN
PROCEDURE dfScrSav16()      ; RETURN
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
                            
// Non servono, ma facilitano il porting dalla versione DOS alla versione
// Xbase++ di dBsee         
FUNCTION  DFPOPCURSO()      ; RETURN DFPOPCURSOR()
FUNCTION  DFPUSHACTN()      ; RETURN DFPUSHACTNUM()
FUNCTION  DFPUSHAREN()      ; RETURN DFPUSHARENUM()
FUNCTION  DFPUSHCURN()      ; RETURN DFPUSHCURNUM()
FUNCTION  DFPUSHCURS()      ; RETURN DFPUSHCURSOR()
FUNCTION  DFPUSHPALN()      ; RETURN DFPUSHPALNUM()
FUNCTION  DFPUSHRECN()      ; RETURN DFPUSHRECNUM()
FUNCTION  dbFrameLin(x)     ; RETURN dbFrameLine(x)

/*
FUNCTION dfGraph()          ; RETURN NIL
FUNCTION dfVgaCls()         ; RETURN NIL
FUNCTION dfGrfSay()         ; RETURN NIL
FUNCTION dfGrfLegend()      ; RETURN NIL
FUNCTION  dfTxtMode()       ; RETURN 0
FUNCTION  dfSetVga()        ; RETURN 0
*/
