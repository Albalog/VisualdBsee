#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "dfWait.ch"
//#include "VDBWait.ch"
//#include "VDBStyles.ch"

//#include "dfStd.ch"
#include "Common.ch"

//#define _IGNORE_THREADS_
/*
#ifdef STATIC_LINK
   #pragma Library("vdbsee1x.lib")
   #pragma Library("kernel32.lib")
   #pragma Library("user32.lib")
   #pragma Library("msvcrt.lib")
   #pragma Library("winspool.lib")
   #pragma Library("comdlg32.lib")
   #pragma Library("dblang.lib") // da nov2004 e' necessaria anche in static link
#else
   #pragma Library("vdbsee1s.lib")
   #pragma Library("vdbsee1o.lib")
   #pragma Library("dblang.lib")
#endif

#ifndef SINGLE_EXE
  #pragma Library("vdblib.lib")
#endif
*/
#define TIME_WAIT_STEP  30  // tempo attesa

STATIC oWaitStack


// Simone 29/3/2005
// mantis (riaperto) 0000464: Crash dell'applicazione spostandosi dalla gestione relazioni alla gestione Menu di progetto.
// gestisce 1 solo thread che esegue l'agg.to di tutti i vdbwait
// invece di avere threads che si avviano e terminano come era prima
#define USE_ONE_THREAD
#ifdef USE_ONE_THREAD
 #define THREAD_IDLE        0
 #define THREAD_RUNNING     1
 #define THREAD_CHANGING    2

 STATIC oSignal
 STATIC aThreads := {}
 STATIC nWaitThreadState := THREAD_IDLE
#endif

#ifdef __TEST__

   #include "Gra.ch"
   #include "Xbp.ch"
   #include "Appevent.ch"
   #include "Font.ch"
   #include "thread.ch"


   PROC MAIN()
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL oDlg := xbpdialog():new(appdesktop(), NIL, {300, 100}, {500, 200})
   LOCAL x

   odlg:title := "Test finestre di WAIT seleziona il tipo"
   odlg:create()

   x:=xbppushbutton():new()
   x:activate :={||ciclo()}
   x:caption:="thread"
   x:create(odlg:drawingarea, NIL, NIL, {60, 30})

   x:=xbppushbutton():new()
   x:activate :={||ciclo2()}
   x:caption:="no thread"
   x:create(odlg:drawingarea, NIL, {70, 0}, {60, 30})

   ? "Elenco thread attivi"
   setappfocus(odlg)
      nEvent := 0
      DO WHILE nEvent <> xbeP_Close
   //      VDBWaitStep()

         nEvent := AppEvent( @mp1, @mp2, @oXbp )
         oXbp:handleEvent( nEvent, mp1, mp2 )
      ENDDO
   /*
      do while inkey()==0
   //     VDBWaitStep()
         sleep(100)
      enddo
   */
   RETURN

   FUNCTION ciclo()
   LOCAL n:= seconds()+10

   ? ThreadInfo( THREADINFO_TID      + ;
                   THREADINFO_SYSTHND  + ;
                   THREADINFO_FUNCINFO + ;
                   THREADINFO_TOBJ       )

   VDBWaitOn("", "Prova con thread",NIL,  .T.)
   DO WHILE seconds() < n
      VdbWaitUpd("Attendere:"+alltrim(str(int(n-seconds()))))
   ENDDO
   vdbWaitOff()
   ? ThreadInfo( THREADINFO_TID      + ;
                   THREADINFO_SYSTHND  + ;
                   THREADINFO_FUNCINFO + ;
                   THREADINFO_TOBJ       )
   ? "attendere..."
   sleep(1000)
   ? ThreadInfo( THREADINFO_TID      + ;
                   THREADINFO_SYSTHND  + ;
                   THREADINFO_FUNCINFO + ;
                   THREADINFO_TOBJ       )
   ?"***************"
   RETURN 0

   FUNCTION ciclo2()
   LOCAL n:= seconds()+10
   ? ThreadInfo( THREADINFO_TID      + ;
                   THREADINFO_SYSTHND  + ;
                   THREADINFO_FUNCINFO + ;
                   THREADINFO_TOBJ       )
   VDBWaitOn("", "Prova senza thread",NIL,  .F.)
   DO WHILE seconds() < n
      vdbwaitstep()
      VdbWaitUpd("Attendere:"+alltrim(str(int(n-seconds()))))
   ENDDO
   vdbWaitOff()
   ? ThreadInfo( THREADINFO_TID      + ;
                   THREADINFO_SYSTHND  + ;
                   THREADINFO_FUNCINFO + ;
                   THREADINFO_TOBJ       )
   ? "attendere..."
   sleep(1000)
   ? ThreadInfo( THREADINFO_TID      + ;
                   THREADINFO_SYSTHND  + ;
                   THREADINFO_FUNCINFO + ;
                   THREADINFO_TOBJ       )
   ?"***************"
   RETURN 0

   FUNCTION dfCenterPos(aSize, aParentSize)
   RETURN { INT((aParentSize[1] - aSize[1]) / 2), ;
            INT((aParentSize[2] - aSize[2]) / 2)  }
#endif

PROCEDURE VDBWaitInit()
#ifndef _WAA_
IF oWaitStack == NIL
   oWaitStack := S2Stack():new()
ENDIF
#endif
#ifdef USE_ONE_THREAD
WaitInitThread()
#endif
RETURN

#ifdef USE_ONE_THREAD
STATIC FUNCTION WaitInitThread()
   STATIC oThread
   IF oThread == NIL
      oSignal := Signal():new()
      oThread := Thread():new()
      oThread:start({|| WaitUpd() })
   ENDIF
RETURN oThread

STATIC PROCEDURE WaitUpd()
   LOCAL oWait
   DO WHILE .T.

      // attendo la possibilit… di eseguire i threads
      DO WHILE nWaitThreadState != THREAD_IDLE
         sleep(5)
      ENDDO

      IF EMPTY(aThreads) // se non ci sono VDBWait aperti
         oSignal:wait()  // attende che ci sia un VDBWait aperto
      ENDIF

      // interrompo la possibilit… di cambiare array threads
      nWaitThreadState := THREAD_RUNNING
      IF ! EMPTY(aThreads)  // eseguo l'agg.to ultimo vdbwait visualizzato
         oWait := ATAIL(aThreads)
         IF ! oWait:lPausa
            oWait:goOn()
         ENDIF
      ENDIF
      // riabilito la possibilit… di cambiare array threads
      nWaitThreadState := THREAD_IDLE

      // dovrebbe essere meglio dello sleep
      // perche appena si aggiunge un VDBWait fa il :goOn()
      oSignal:wait( TIME_WAIT_STEP  ) 
      //sleep( TIME_WAIT_STEP )
   ENDDO
RETURN 

STATIC PROCEDURE WaitAddThread(o)
   // attendo la possibilit… di cambiare array threads
   DO WHILE nWaitThreadState != THREAD_IDLE
      sleep(5)
   ENDDO

   // interrompo la possibilit… di far eseguire il thread
   nWaitThreadState := THREAD_CHANGING
   AADD(aThreads, o)
   // riabilito la possibilit… di far eseguire il thread
   nWaitThreadState := THREAD_IDLE

   // se era in wait, fa partire il thread che aggiorna il vdbwait
   oSignal:signal()
RETURN 

STATIC PROCEDURE WaitDelThread(o)
   LOCAL n
   // attendo la possibilit… di cambiare array threads
   DO WHILE nWaitThreadState != THREAD_IDLE
      sleep(5)
   ENDDO

   // interrompo la possibilit… di far eseguire il thread
   nWaitThreadState := THREAD_CHANGING
   n := ASCAN(aThreads, o)
   IF n > 0
      AREMOVE(aThreads, n)
   ENDIF
   // riabilito la possibilit… di far eseguire il thread
   nWaitThreadState := THREAD_IDLE
RETURN 
#endif


FUNCTION VDBWaitGetStack(); RETURN oWaitStack
FUNCTION VDBWaitGetTop(); RETURN oWaitStack:top()
FUNCTION VDBWaitPausa();oWaitStack:top():lPausa := .T. ; RETURN NIL
FUNCTION VDBWaitRun();oWaitStack:top():lPausa := .F. ; RETURN NIL

FUNCTION VDBWaitExit(); RETURN oWaitStack:top():SetExit()

FUNCTION VDBWaitOn(cMsg, cTitle, cBackBMP, lThread, bKeyBoard, oParent, oOwner)
#ifndef _WAA_
   LOCAL oWait

//Maudp-SimoneD 14/09/2010 FIX di errore runtime sulla "oWaitStack:push(oWait)"
********************************
   IF oWaitStack == NIL
      VDBWaitInit()
   ENDIF
********************************

   IF dfInitScreenOpen()
      dfInitScreenUpd(cMsg)
   ELSE
      // simone 3/4/08
      // mantis 0001798: in apertura della form c'è un refresh brutto
      IF oOwner == NIL
         oOwner :=S2FormCurr()
         DO WHILE oOwner != NIL .AND. ;
                  ! oOwner:isVisible()
            oOwner:=dfGetOwnerForm(oOwner)
         ENDDO
         IF oOwner == NIL
            oOwner :=S2FormCurr()
         ENDIF
      ENDIF
      //DEFAULT oOwner TO S2FormCurr() // aggiunta simone 31/8/06
      oWait := VDBWait():new(oParent,oOwner,NIL,NIL,NIL,NIL,cBackBMP)
      Sleep(0)
      oWaitStack:push(oWait)
      oWait:On(cMsg, cTitle, cBackBMP, lThread,bKeyBoard)
//      S2FormCurr(oWait)
   ENDIF
#endif
RETURN NIL

FUNCTION VDBWaitStep()
#ifndef _WAA_
LOCAL xRet := ""
  IF dfInitScreenOpen()
     xRet := dfInitScreenStep()
  ELSE
     IF EMPTY(oWaitStack) .OR. EMPTY(oWaitStack:top())
        xRet := ""
        sleep(0)
     ELSE
        xRet := oWaitStack:top():DoStep()
     ENDIF
  ENDIF
//RETURN IIF(dfInitScreenOpen(), dfInitScreenStep(), oWaitStack:top():DoStep())
RETURN  xRet
#else
RETURN NIL
#endif

FUNCTION VDBWaitStop()
#ifndef _WAA_
LOCAL xRet := ""
  IF dfInitScreenOpen()
     xRet := NIL
  ELSE
     IF EMPTY(oWaitStack) .OR. EMPTY(oWaitStack:top())
        xRet := ""
        sleep(1)
     ELSE
        xRet := oWaitStack:top():Stop()
     ENDIF
  ENDIF
//RETURN IIF(dfInitScreenOpen(), NIL, oWaitStack:top():Stop())
RETURN  xRet
#else
RETURN NIL
#endif


FUNCTION VDBWaitUpd(cMsg, cMsg2)
#ifndef _WAA_
LOCAL xRet := ""
  IF dfInitScreenOpen()
     xRet := dfInitScreenUpd(cMsg)
  ELSE
     IF EMPTY(oWaitStack) .OR. EMPTY(oWaitStack:top())
        xRet := ""
        sleep(1)
     ELSE
        xRet := oWaitStack:top():update(cMsg,cMsg2)
     ENDIF
  ENDIF
//RETURN IIF(dfInitScreenOpen(), dfInitScreenUpd(cMsg), oWaitStack:top():update(cMsg,cMsg2))
RETURN  xRet
#else
RETURN NIL
#endif

FUNCTION VDBWaitOff()
#ifndef _WAA_
   LOCAL oWait //, oOwner

   IF ! dfInitScreenOpen()
      IF EMPTY(oWaitStack)
         RETURN NIL
      ENDIF 
      oWait := oWaitStack:pop()
      IF ! EMPTY(oWait)
         //oOwner  := oWait:setOwner()
         oWait:Off()
         //S2FormCurr(oOwner, .T.)
      ENDIF
   ENDIF
#endif
RETURN NIL


CLASS VDBWait FROM S2ModalDialog //XbpDialog //VDBDialog
PROTECTED:
   VAR oAnimate
   VAR oAnimate2
   VAR cBmp

EXPORTED:
   VAR oTitle, oText,oText2
   VAR cMsg,cMsg2, nIdx, nNextSec, lExit, lPausa
   VAR lUseThread
   VAR oThread

   METHOD goOn

   METHOD init
   METHOD create
   METHOD on
   METHOD off
   METHOD update
   METHOD doStep
   METHOD setTitle
   METHOD setBMPBackground
   METHOD execute
   METHOD SetExit
ENDCLASS

METHOD VDBWait:init(oParent, oOwner, aPos, aSize, aPP, lVisible,cBackBMP )
   LOCAL oDlg := self
   LOCAL oXbp, drawingArea
   LOCAL oBmp
   LOCAL cFont

   DEFAULT oParent TO AppDesktop()
   DEFAULT aSize TO {320, 200}
   DEFAULT aPos TO dfCenterPos(aSize, oParent:currentSize())
   DEFAULT lVisible TO .F.
 

   ::XbpDialog:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
   oDlg:taskList := .F.
   oDlg:titlebar:=.F.
   oDlg:border := XBPDLG_NO_BORDER
   oDlg:title := ""
   //Mantis 223
   oDlg:movewithowner := .T.

   drawingArea := oDlg:drawingArea

   // switch the background to transparent
   drawingArea:setColorBG( XBPSYSCLR_TRANSPARENT)

   //Mantis 1633
   cFont := dfSet("XbaseWaitFormFont")
   IF EMPTY(cFont)
      cfont := "14.Verdana"
   ENDIF 

   oXbp := XbpStatic():new( drawingArea,, { 10, 165}, { 280, 30},, .T.)
   oXbp:caption := "" //cTitle
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK
   oXbp:setColorFG( GRA_CLR_BLACK)
   oXbp:setFontCompoundName(cFont)
   ::oTitle := oXbp

   // display some text to show the feature
   // this works due to the fact that the color for the XbpStatic
   // is inherited from the drawingArea
   oXbp := XbpStatic():new( drawingArea,, { 10, 45}, { 300, 90},, .T.)
   oXbp:caption := ""
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK
   oXbp:setColorFG( GRA_CLR_BLACK)
   ::oText := oXbp

   oXbp := XbpStatic():new( drawingArea,, { 10, 12}, { 300, 32},, .T.)
   oXbp:caption := ""
   oXbp:setColorFG( GRA_CLR_BLACK)
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK
   ::oText2 := oXbp
/*
   Simone 17/06/2005
   se necessario, in Visual dBsee per utilizzare gli stili si potrebbe derivare
   una classe da questa e ridefinire il metodo INIT in modo che 
   imposti le variabili ::oTitle, ::oText, ::oText2 come sotto:

   oXbp := StyleStatic():new( drawingArea,, { 10, 165}, { 280, 30},, .T.)
   oXbp:caption := "" //cTitle
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK
   oXbp:setColorFG( GRA_CLR_BLACK)
   oXbp:setStyle(VDB_STYLE_STATIC_TITLE2)
   ::oTitle := oXbp

   // display some text to show the feature
   // this works due to the fact that the color for the XbpStatic
   // is inherited from the drawingArea
   oXbp := StyleStatic():new( drawingArea,, { 10, 45}, { 300, 90},, .T.)
   oXbp:caption := ""
   oXbp:setStyle(VDB_STYLE_STATIC_NORMAL1)
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK
   oXbp:setColorFG( GRA_CLR_BLACK)
   ::oText := oXbp

   oXbp := StyleStatic():new( drawingArea,, { 10, 12}, { 300, 32},, .T.)
   oXbp:caption := ""
   oXbp:setColorFG( GRA_CLR_BLACK)
   oXbp:setStyle(VDB_STYLE_STATIC_NORMAL1)
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK
   ::oText2 := oXbp
*/
   //oXbp := XbpPushButton():new( drawingArea, , {255,15}, {50,20} )
   //oXbp:caption  := "Esc"
   //oXbp:tabStop  := .T.
   //oXbp:activate := {|| _butt(Self) }
   //::oButt := oXbp

   oXbp := _Static():new( drawingArea,, { 1, 1}, { 160, 10},, .T.)
   oXbp:lGradientPaint := .T.
   oXbp:setVertexColor(1,14,23,92)
   oXbp:setVertexColor(2,198,205,254)
   ::oAnimate:=oXbp


   oXbp := _Static():new( drawingArea,, { 161, 1}, { 318-160, 10},, .T.)
   oXbp:lGradientPaint := .T.
   oXbp:setVertexColor(1,198,205,254)
   oXbp:setVertexColor(2,14,23,92)
   ::oAnimate2:=oXbp
   ::cBmp := NIL

   ::setBMPBackground(cBackBMP)

   ::nIdx:=0
   ::nNextSec := -1
   ::cMsg := ""
   ::lUseThread := .F.
   ::cMsg  := ""
   ::cMsg2 := ""
   ::lExit := .F.
   ::lPausa:= .F. 
RETURN self

METHOD VDBWait:setTitle(cTitle)
   DEFAULT cTitle TO ""
   ::oTitle:setCaption(cTitle)
RETURN self

/* Valori validi per cBackBmp
   vedi VDBWait.ch
   #define VDBWAIT_BMPSTD     "WAITBACKSTD"
   #define VDBWAIT_BMPINFO    "WAITBACKINFO"
   #define VDBWAIT_BMPTIME    "WAITBACKTIME"
   #define VDBWAIT_BMPCROSS   "WAITBACKCROSS"
   #define VDBWAIT_BMPGENERA  "WAITBACKGENERA"
                               
*/
METHOD VDBWait:setBmpBackground(cBackBMP)
   LOCAL oBmp

   DEFAULT cBackBMP TO VDBWAIT_BMPTIME

   IF ! cBackBmp == ::cBmp
      oBmp:= dBBitmap():new()
      oBmp:load(NIL, cBackBMP, "IMAGES")
      ::drawingArea:bitmap := obmp

      ::cBmp := cBackBmp
   ENDIF

   IF ::status()==XBP_STAT_CREATE
      IF cBackBMP == VDBWAIT_BMPSTD
         ::oTitle:setPosAndSize({ 10, 165}, { 280, 30})
      ELSE
         // C'Š una icona quindi sposto il titolo
         ::oTitle:setPosAndSize({ 60, 165}, { 230, 30})
      ENDIF
   ENDIF
RETURN self

METHOD VDBWait:create(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::XbpDialog:create(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::oTitle:create()
   ::oText:create()
   ::oText2:create()
   //::oButt:create()
   ::oAnimate:create()
   ::oAnimate2:create()

   // this is NEEDed because we overloaded AppSys()
   //SetAppWindow(::VDBDialog)
   FixSetAppFocus(::XbpDialog)
   //SetAppFocus( ::oButt )

RETURN self


METHOD VDBWait:On( cMsg, cTitle, cBackBMP, lThread, bKeyBoard )
   LOCAL nEvent, mp1, mp2, oXbp
   DEFAULT cMsg TO ""
   ::create()
   sleep(0)

   ::tbConfig()

   ::update(cMsg)
   IF ! EMPTY(cTitle)
      ::setTitle(cTitle)
   ENDIF
   IF !EMPTY(bKeyBoard) .AND. VALTYPE(bKeyBoard) == "B"
      ::XbpDialog:Keyboard := bKeyBoard 
   ELSE
      //::oButt:Hide()
   ENDIF

   ::setBMPBackground(cBackBMP)

#ifdef _IGNORE_THREADS_
   IF .F.
#else
   IF EMPTY(bKeyboard) .AND. !EMPTY(lThread)
#endif
      ::lUseThread := .T.
#ifdef USE_ONE_THREAD
      WaitAddThread(self)
#else
      ::oThread := Thread():new()
      ::oThread:start({||::execute()})
#endif
   ENDIF
   ::show()

   ::goOn() // simone 29/3/2005 visualizza primo step 

   IF !EMPTY(bKeyBoard) .AND. VALTYPE(bKeyBoard) == "B"
      DO WHILE (nEvent <> xbeP_Close) .AND. !::lExit           
         nEvent := dfAppEvent( @mp1, @mp2, @oXbp, 5 )
         // Simone 20/5/2005
         // mantis 0000742: durante la generazione la risposta al tasto ESC non Š immediata
         IF oXbp != NIL .AND. nEvent != xbe_None
            oXbp:handleEvent( nEvent, mp1, mp2 )
            ::doStep()
         ELSE
            ::doStep()
            sleep( TIME_WAIT_STEP )
         ENDIF
      ENDDO
      ::Off()
   ENDIF
     
RETURN self


METHOD VDBWait:SetExit()
   ::lExit := .T.

   // Simone 18/03/2005
   // mantis 0000598: Fatal Error in generazione
   //PostAppEvent(xbeP_Close,,, self)
RETURN self

METHOD VDBWait:Off()
   LOCAL err, oErr

   IF ::XbpPrev != NIL
      ::tbEnd() //::hide()
   ENDIF

#ifdef USE_ONE_THREAD
   IF ::lUseThread
      WaitDelThread(self)
   ENDIF
#else
   IF ::lUseThread .AND. !EMPTY(::oThread)
      ::lUseThread := .F.

      //oErr := ERRORBLOCK({|e|dfErrBreak(e)})
      //BEGIN SEQUENCE
         sleep(0)
         ::oThread:synchronize(0)
         sleep(0)
      //RECOVER USING err
      //    dbMsgErr("Errore in ::oThread:synchronize(0) di VDBWait()")
      //END SEQUENCE

      DO WHILE ::oThread:active
         sleep(20)
      ENDDO
      ::oThread:=NIL
   ENDIF
#endif
   // simone 17/03/2005
   // correzione mantis 0000625: errore runtime in apertura progetto
   IF ::status()==XBP_STAT_CREATE
      ::destroy()
   ENDIF
RETURN self

METHOD VDBWait:update( cMsg,cMsg2)
   DEFAULT cMsg  TO ::cMsg
   DEFAULT cMsg2 TO ::cMsg2
   ::oText:setCaption(cMsg)
   ::oText2:setCaption(cMsg2)
   ::cMsg  := cMsg
   ::cMsg2 := cMsg2
RETURN self

METHOD VDBWait:execute()
LOCAL nEvent, mp1, mp2
#ifndef USE_ONE_THREAD
  DO WHILE ::lUseThread
     IF !::lPausa
        ::goOn()
     ENDIF
     sleep( TIME_WAIT_STEP )
  ENDDO
#endif
RETURN self

METHOD VDBWait:goOn()
   LOCAL oXbp, oXbp2, n
   oXbp  := ::oAnimate
   oXbp2 := ::oAnimate2

   ::nIdx+=10
   IF ::nIdx > oXbp:setparent():currentSize()[1]
      ::nIdx:=0
   ENDIF

   n:=::nIdx

   oXbp:setSize( {n, 10}, .F.)
   oXbp:buildVertex()
   oXbp:gradientPaint()

   oXbp2:setPosandSize({n+1, 1}, {318-n, 10}, .F.)
   oXbp2:buildVertex()
   oXbp2:gradientPaint()

RETURN self


METHOD VDBWait:DoStep()
   IF !::lUseThread .AND. SECONDS() > ::nNextSec
      ::goOn()
      ::nNextSec := SECONDS() + (TIME_WAIT_STEP / 100)
   ENDIF
RETURN NIL

STATIC CLASS _static FROM XbpStatic, GradientPaint
EXPORTED
    INLINE METHOD init(oParent, oOwner, aPos, aSize, aPP, lVisible)
       ::XbpStatic:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
       ::GradientPaint:init(self)
       ::lGradientPaint := .F.
    RETURN self
ENDCLASS

//
//STATIC FUNCTION dfCenterPos(aSize, aParentSize)
//RETURN { INT((aParentSize[1] - aSize[1]) / 2), ;
//         INT((aParentSize[2] - aSize[2]) / 2)  }

/*
PROCEDURE VDBWait(cMsg, cTitle, cBackBMP)
   LOCAL nEvent, mp1, mp2
   LOCAL oDlg, oXbp, drawingArea
   LOCAL oBmp
   LOCAL aPos, aSize := {320, 200}
   LOCAL oThread, oAnimate, oAnimate2
   LOCAL n

   aPos := dfCenterPos(aSize, AppDesktop():currentSize())

   DEFAULT cTitle TO "Attendere..." //MSG
   DEFAULT cMsg TO ""
   DEFAULT cBackBMP TO "BACK"

        // generate a XbpDialog as application window
   oDlg := XbpDialog():new( AppDesktop(), NIL,aPos, aSize, NIL, .F.)
   oDlg:taskList := .f.
   oDlg:titlebar:=.F.
   oDlg:border := XBPDLG_NO_BORDER
   oDlg:title := "transparent XbpStatic"

   drawingArea := oDlg:drawingArea

   oBmp:= dBBitmap():new()
   oBmp:load(NIL, cBackBMP, "IMAGES")
   drawingArea:bitmap := obmp

   oDlg:create()

        // switch the background to transparent
   drawingArea:setColorBG( XBPSYSCLR_TRANSPARENT)
   oDlg:show()

        // this is NEEDed because we overloaded AppSys()
   SetAppWindow(oDlg)
   SetAppFocus(oDlg)

   oXbp := XbpStatic():new( drawingArea,, { 10, 155}, { 280, 40},, .F.)
   oXbp:caption := cTitle
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK
   oXbp:create()
//        oXbp:setFontCompoundName( "")
   oXbp:setColorFG( GRA_CLR_BLACK)
   oXbp:show()

   // display some text to show the feature
   // this works due to the fact that the color for the XbpStatic
   // is inherited from the drawingArea
   //oXbp := XbpStatic():new( drawingArea,, { 10, 25}, { 300, 120},, .F.)
   oXbp := XbpStatic():new( drawingArea,, { 10, 25}, { 280, 120},, .F.)
   oXbp:caption := cMsg
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK
   oXbp:create()
//        oXbp:setFontCompoundName( "")
   oXbp:setColorFG( GRA_CLR_BLACK)
   oXbp:show()

   oXbp := _Static():new( drawingArea,, { 1, 1}, { 160, 10},, .T.)
   oXbp:lGradientPaint := .t.
   oXbp:setVertexColor(1,14,23,92)
   oXbp:setVertexColor(2,198,205,254)
   oXbp:create()
   oAnimate:=oXbp

	
   oXbp := _Static():new( drawingArea,, { 161, 1}, { 318-160, 10},, .T.)
   oXbp:lGradientPaint := .t.
   oXbp:setVertexColor(1,198,205,254)
   oXbp:setVertexColor(2,14,23,92)
   oXbp:create()
   oAnimate2:=oXbp


   n:=0
   do while .t.
      _animate3(@n, oAnimate, oAnimate2)
      sleep(40)
   enddo
RETURN


FUNCTION dfCenterPos(aSize, aParentSize)
RETURN { INT((aParentSize[1] - aSize[1]) / 2), ;
         INT((aParentSize[2] - aSize[2]) / 2)  }







STATIC FUNCTION _animate3(n, oXbp, oXbp2)
   n+=10
   if n > oXbp:setparent():currentSize()[1]
      n:=0
   endif
   oXbp:setSize( {n, 10}, .f.)
   oXbp:buildVertex()
   oXbp:gradientPaint()

   oXbp2:setPosandSize({n+1, 1}, {318-n, 10}, .f.)
   oXbp2:buildVertex()
   oXbp2:gradientPaint()
RETURN n

*/