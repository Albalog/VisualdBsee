#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "dfWait.ch"
//#include "VDBWait.ch"
//#include "VDBStyles.ch"

//#include "dfStd.ch"
#include "Common.ch"
#include "dfMsg1.ch"
#include "dfXRes.ch"

#include "dfset.ch"
#include "dfctrl.ch"

#define S2PI_MSG_BREAK        dfStdMsg1(MSG1_S2PI01) // "Interrompere ?"
#define S2PI_MSG_BTNOK        dfStdMsg1(MSG1_S2PI02) // "Annulla"
#define S2PI_MSG_BTNPRESSED   dfStdMsg1(MSG1_S2PI03) // "Attendere"
#define S2PI_MSG_WAIT         dfStdMsg1(MSG1_S2PI04) // "Attendere prego..."

#ifndef __TEST__
   // SE NON SONO IN TEST IGNORA LA FUNZIONE DI LOG!!
   #xtranslate printlog(<x>)  =>
#endif

#ifdef __TEST__


   static lOn := .F.
   static oLog

   func printlog(x)
     local o
     o:=setappwindow(olog)
     ? space(threadid()*20), ">", alltrim(Str(threadid())), procname(1), procname(2), x
     setappwindow(o)
   return 0

   #include "Gra.ch"
   #include "Xbp.ch"
   #include "Appevent.ch"
   #include "Font.ch"
   #include "thread.ch"


   PROC MAIN()
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL oDlg 
   LOCAL x

   set alternate on
   set alternate to "progressdialog.log"

   dfSet(AI_XBASEBUTSTYLE, BUT_PS_FLAT2)

   oLog := setAppWindow()

   oDlg := xbpdialog():new(appdesktop(), NIL, {300, 100}, {500, 200})
   VDBProgDialoginit()
   odlg:title := "Test finestre di WAIT seleziona il tipo"
   odlg:create()

   x:=xbppushbutton():new()
   x:activate :={||ciclo()}
   x:caption:="thread"
   x:create(odlg:drawingarea, NIL, NIL, {60, 30})

   x:=xbppushbutton():new()
   x:activate :={||ciclo2()}
   x:caption:="no thread"
   x:create(odlg:drawingarea, NIL, {140, 0}, {60, 30})

   ? "Elenco thread attivi"
      nEvent := 0
   setappfocus(odlg)
      DO WHILE nEvent <> xbeP_Close
   //      VDBProgDialogStep()

         nEvent := AppEvent( @mp1, @mp2, @oXbp )
         oXbp:handleEvent( nEvent, mp1, mp2 )
      ENDDO
   /*
      do while inkey()==0
   //     VDBProgDialogStep()
         sleep(100)
      enddo
   */
   RETURN

   FUNCTION ciclo()
   LOCAL n:= seconds()+10, x:=0, nevent, mp1, mp2, oxbp, lok
   local o
   ? ThreadInfo( THREADINFO_TID      + ;
                   THREADINFO_SYSTHND  + ;
                   THREADINFO_FUNCINFO + ;
                   THREADINFO_TOBJ       )

   ? "in corso..."
printlog("+ciclo")
   VDBProgDialogOn("", "Prova con thread",NIL,  .T.)
   lok :=.T.

   n:=60
   DO WHILE lOK
      lOk:=VDBProgDialogstep(++x, n)
      sleep(10)
      VDBProgDialogUpd("Attendere:"+alltrim(str(int(n-x))))
      if x >= n
         exit
      endif 
   ENDDO
      VDBProgDialogstep(n, n)
      sleep(200)
   VDBProgDialogOff()
printlog("-ciclo, interrotto="+var2char(!lok))

   ? ThreadInfo( THREADINFO_TID      + ;
                   THREADINFO_SYSTHND  + ;
                   THREADINFO_FUNCINFO + ;
                   THREADINFO_TOBJ       )
   ? "attendere 10 sec..."
   sleep(1000)
   ? ThreadInfo( THREADINFO_TID      + ;
                   THREADINFO_SYSTHND  + ;
                   THREADINFO_FUNCINFO + ;
                   THREADINFO_TOBJ       )
   ?"***************"
   RETURN 0


   FUNCTION ciclo2()
   LOCAL n:= seconds()+10, x:=0
   LOCAL oDlg := setappfocus()
   ? ThreadInfo( THREADINFO_TID      + ;
                   THREADINFO_SYSTHND  + ;
                   THREADINFO_FUNCINFO + ;
                   THREADINFO_TOBJ       )

   ? "in corso..."

   VDBProgDialogOn("", "Prova senza thread",NIL,  .F.)
   
   DO WHILE seconds() < n
      sleep(50)
      VDBProgDialogstep(++x, 20)
      VDBProgDialogUpd("Attendere:"+alltrim(str(int(n-seconds()))))
   ENDDO
      VDBProgDialogstep(20, 20)
      sleep(200)
   VDBProgDialogOff()
   setappfocus(odlg)
   ? ThreadInfo( THREADINFO_TID      + ;
                   THREADINFO_SYSTHND  + ;
                   THREADINFO_FUNCINFO + ;
                   THREADINFO_TOBJ       )
   ? "attendere 10 sec..."
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


// ---------------------------------------
// CLASSE PER GESTIRE IL THREAD PER EVENTI
// (gestione pulsante per interruzione)
// ---------------------------------------

CLASS VDBProgDialogManager
EXPORTED:
   VAR oThread
   VAR oPD
   VAR aInit
   VAR lLoop


   METHOD init
   METHOD update
   METHOD dostep
   METHOD on
   METHOD off

   METHOD setCaption IS update
   METHOD getCaption

   METHOD execute
   METHOD setOwner

ENDCLASS

METHOD VDBProgDialogManager:init(oParent, oOwner, aPos, aSize, aPP, lVisible,cBackBMP )
   ::aInit := {oParent, oOwner, aPos, aSize, aPP, lVisible,cBackBMP}
RETURN self

METHOD VDBProgDialogManager:setOwner(x)
   IF ! EMPTY(x) .AND. ! EMPTY(::aInit)
      ::aInit[2] := x
   ENDIF
RETURN IIF(EMPTY(::aInit), NIL, ::aInit[2])

METHOD VDBProgDialogManager:On( cTitle, cMsg, lButton, cBackBMP )
printlog("+on")
   ::oThread := Thread():new()
   ::lLoop := .T.
   ::oThread:start({|| ::execute(cTitle, cMsg, lButton, cBackBMP)})
   DO WHILE ::oPD == NIL .OR. ! ::oPD:status() == XBP_STAT_CREATE // attende creazione
      sleep(10)
   ENDDO
printlog("-on")
RETURN self

METHOD VDBProgDialogManager:Off()
printlog("+off")
   IF ::oPD != NIL 
      IF ::oPD:oBtn:status()==XBP_STAT_CREATE .AND. ::oPD:oBtn:isEnabled()
         ::oPD:oBtn:disable()
      ENDIF
//      IF ::oPD:nPush==2 //se Š in attesa di risposta utente
//         dbAct2Kbd("esc") // butto un ESC
//      ENDIF
   ENDIF
   ::lLoop := .F.

   // attende termine del thread
   DO WHILE ::oThread:active
      sleep(20)
   ENDDO
   ::oThread:=NIL
printlog("-off")
RETURN self

METHOD VDBProgDialogManager:update(cMsg)
   IF ::oPD == NIL
      RETURN self
   ENDIF
   ::oPD:update(cMsg)
RETURN self

METHOD VDBProgDialogManager:DoStep(nCurr, nMax, cBrkMsg)
   IF ::oPD == NIL
      RETURN .F.
   ENDIF
   ::oPD:DoStep(nCurr, nMax, cBrkMsg)
printlog("dostep, "+var2char(::opd:lBrk))
RETURN ! ::oPD:lBrk

METHOD VDBProgDialogManager:execute(cTitle, cMsg, lButton, cBackBMP )
   LOCAL nEvent, mp1, mp2, oXbp
printlog("+execute")
   ::oPD := VDBProgDialog():new(::aInit[1], ::aInit[2], ::aInit[3], ::aInit[4], ::aInit[5], ::aInit[6], ::aInit[7] )
   ::oPD:On( cTitle, cMsg, lButton, cBackBMP  )
   DO WHILE ::lLoop
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp, 5) //, .1, ::oPD)
      IF oXbp != NIL //.AND. oXbp == ::oPD:oBtn
         oXbp:HandleEvent(nEvent, mp1, mp2)
      ENDIF
   ENDDO
   ::oPD:off()
printlog("-execute")
RETURN self

METHOD VDBProgDialogManager:getCaption()
   IF ::oPD == NIL
      RETURN ""
   ENDIF
RETURN ::oPD:getCaption()

// ---------------------------------------
// CLASSE PER PROGRESS DIALOG
// ---------------------------------------

CLASS VDBProgDialog FROM S2ModalDialog //XbpDialog //VDBDialog
PROTECTED:
   VAR oAnimate
   VAR cBmp

EXPORTED:
   VAR oBtn, nPush, lButton
   VAR cBrkMsg, lBrk
   METHOD BtnPressed, BtnKeyHandler

   VAR oTitle, oText //,oText2
   VAR cMsg,cMsg2, nIdx
   VAR nCurr, nMax

   METHOD goOn

   METHOD init
   METHOD create
   METHOD on
   METHOD off
   METHOD update
   METHOD doStep
   METHOD setTitle
   METHOD setBMPBackground
   METHOD setCaption IS update

   INLINE METHOD getCaption(); RETURN ::cMsg
ENDCLASS

METHOD VDBProgDialog:init(oParent, oOwner, aPos, aSize, aPP, lVisible,cBackBMP )
   LOCAL oDlg := self
   LOCAL oXbp, drawingArea
   LOCAL oBmp
   LOCAL oIcon, lError

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

   oXbp := XbpStatic():new( drawingArea,, { 10, 165}, { 280, 30},, .T.)
   oXbp:caption := "" //cTitle
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK
   oXbp:setColorFG( GRA_CLR_BLACK)
   oXbp:setFontCompoundName("14.Verdana")
   ::oTitle := oXbp

   // display some text to show the feature
   // this works due to the fact that the color for the XbpStatic
   // is inherited from the drawingArea
   oXbp := XbpStatic():new( drawingArea,, { 10, 45}, { 300, 90},, .T.)
   oXbp:caption := ""
   oXbp:options := XBPSTATIC_TEXT_WORDBREAK
   oXbp:setColorFG( GRA_CLR_BLACK)
   ::oText := oXbp

   IF S2GetPushButtonStyle() == BUT_PS_STD
      oXbp := XbpPushButton():new( drawingArea, , {296,10}, {20,20}, , .F. )
      oXbp:caption  := BUTT_CANCEL
      oXbp:preSelect := .T.
   ELSE
      oXbp := S2ButtonX():new( drawingArea, , {296,10}, {20,20}, , .F. )
      oXbp:caption  := ""
      oXbp:style := S2GetPushButtonStyle()
      oIcon := dfGetImgObject(BUTT_CANCEL, @lError)
      IF ! lError
         oXbp:image     := oIcon
         oXbp:imageType := XBPSTATIC_TYPE_BITMAP
      ELSE
         oXbp:caption  := "Esc"
      ENDIF
   ENDIF

   oXbp:tabStop  := .T.
   oXbp:activate := {|| ::BtnPressed() }
   oXbp:tabStop := .T.
   oXbp:keyboard := {|nKey,mp2,obj| ::BtnKeyHandler( nKey, obj ) }
   ::oBtn := oXbp

   oXbp := GradientProgressBar():new( drawingArea,, { 4, 12}, { 288, 16},, .T.)
   ::oAnimate:=oXbp

   ::cBmp := NIL

   ::setBMPBackground(cBackBMP)

   ::nIdx:=0
   ::cMsg := ""
   ::cMsg  := ""
//   ::cMsg2 := ""

   ::nCurr := 0
   ::nMax  := 100
   ::cBrkMsg := NIL
   ::lButton := .F. 
   ::nPush   := 0 // non pigiato
   ::lBrk    := .F.
RETURN self

METHOD VDBProgDialog:setTitle(cTitle)
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
METHOD VDBProgDialog:setBmpBackground(cBackBMP)
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

METHOD VDBProgDialog:create(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::XbpDialog:create(oParent, oOwner, aPos, aSize, aPP, lVisible)
   ::oTitle:create()
   ::oText:create()
//   ::oText2:create()
   ::oBtn:create()
   IF ::lButton
//      aSize := {254, 16}
      aSize := {288, 16}
   ELSE
//      aSize := {278, 16}
      aSize := {312, 16}
   ENDIF
   ::oAnimate:create(NIL, NIL, NIL, aSize)
   //::oPerc:create()
//   ::oAnimate2:create()

   // this is NEEDed because we overloaded AppSys()
   //SetAppWindow(::VDBDialog)
   IF ::lButton
      ::oBtn:show()
      FixSetAppFocus(::oBtn)
   ELSE
      FixSetAppFocus(::XbpDialog)
   ENDIF
RETURN self


METHOD VDBProgDialog:On( cTitle, cMsg, lButton, cBackBMP )
   LOCAL nEvent, mp1, mp2, oXbp

   DEFAULT cTitle  TO ""
   DEFAULT cMsg    TO S2PI_MSG_WAIT
   DEFAULT lButton TO .T.

   ::lButton := lButton

   ::create()
   sleep(0)

   ::tbConfig()

   ::update(cMsg)
   IF ! EMPTY(cTitle)
      ::setTitle(cTitle)
   ENDIF

   ::setBMPBackground(cBackBMP)

   ::show()     
RETURN self


METHOD VDBProgDialog:Off()
   LOCAL err, oErr

   ::tbEnd() //::hide()

   // simone 17/03/2005
   // correzione mantis 0000625: errore runtime in apertura progetto
   IF ::status()==XBP_STAT_CREATE
      ::destroy()
   ENDIF
RETURN self


METHOD VDBProgDialog:update( cMsg) //,cMsg2)
   DEFAULT cMsg  TO ::cMsg
//   DEFAULT cMsg2 TO ::cMsg2
   ::oText:setCaption(cMsg)
//   ::oText2:setCaption(cMsg2)
   ::cMsg  := cMsg
//   ::cMsg2 := cMsg2
RETURN self


METHOD VDBProgDialog:goOn()
   LOCAL oXbp, oXbp2, n, aSz
   LOCAL cMsg
   LOCAL lRet := .T.
   LOCAL nPerc, oPrev

   oXbp  := ::oAnimate
//   oXbp2 := ::oAnimate2

printlog("+goon")

   IF ::lButton 

      IF ::nPush==1 //pigiato
         ::nPush := 2 // in attesa
printlog("+yesno")
         cMsg := ::cBrkMsg
         DEFAULT cMsg TO S2PI_MSG_BREAK

         oPrev := S2FormCurr()
         S2FormCurr( self )

         ::lBrk := dfYesNo(cMsg)

         S2FormCurr(oPrev, .T.)
         lRet := ! ::lBrk

         ::oBtn:SetCaption(S2PI_MSG_BTNOK)
         ::oBtn:enable()
         ::oBtn:setParent():invalidateRect()
         FixSetAppFocus(::oBtn)
printlog("-yesno="+var2char(lRet))

         ::nPush := 0
      ENDIF
   ENDIF

   oXbp:setCurrent(::nCurr, ::nMax)

printlog("-goon")

RETURN lRet

METHOD VDBProgDialog:DoStep(nCurr, nMax, cBrkMsg)
   LOCAL lRet := .T.

   // Simone 06/10/08
   // mantis 0001977: velocizzare le stampe 
   IF nCurr != NIL
   ::nCurr := nCurr
   ENDIF
   IF nMax != NIL
   ::nMax  := nMax
   ENDIF
   IF cBrkMsg != NIL
   ::cBrkMsg := cBrkMsg
   ENDIF
   lRet := ::goOn()
RETURN lRet

METHOD VDBProgDialog:BtnKeyHandler( nKey, oButton, aPushButtons )
   IF nKey == xbeK_ESC .OR. nKey == xbeK_RETURN
      PostAppEvent( xbeP_Activate,,, oButton )
   ENDIF
RETURN self

METHOD VDBProgDialog:BtnPressed()
   IF ::nPush == 0 // se non pigiato
      ::nPush := 1 // imposta a pigiato
      ::oBtn:SetCaption(S2PI_MSG_BTNPRESSED)
      ::oBtn:disable()
   ENDIF
RETURN self




