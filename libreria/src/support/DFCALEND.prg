#include "dfXbase.ch"
#include "gra.ch"
#include "Xbp.ch"
#include "common.ch"
#include "dfMsg1.ch"

#define XBPMVIEW_CLSID     "MSComCtl2.MonthView"

#define CALENDAR_TITLE dfStdMsg1(MSG1_S2CALENDAR01)


// FUNCTION dfCalendar(dData)
//    LOCAL oCal,nEvent:=0,mp1,mp2,oEventCal
//    LOCAL lExit := .F.
//
//    oCal := Calendar():new()
//    oCal:BackGroundColor := GRA_CLR_WHITE
//    oCal:ApptDayColor := GRA_CLR_BLUE
//    oCal:Create()
//
//    oCal:close := {|| lExit := .T. }
//
//    oCal:show()
//    SetAppFocus(oCal)
//
//    //Example of checking for appointments
//    //periodicly (ever 30 seconds)
//    oEventCal:=oCal //Needs to be assigned to a non changeing object varaible???
//  //  SetTimerEvent(3000,{||Checkit(oEventcal)})
//    DO WHILE ! lExit
//       nEvent := AppEvent( @mp1, @mp2, @oCal )  //oCal can change here!
//       oCal:handleEvent( nEvent, mp1, mp2 )
//    ENDDO
//
//    oCal:hide()
//    oCal:destroy()
//
//  //  SetTimerEvent(0)
// RETURN oCal:currDate()

MEMVAR ACT

STATIC nStyle := 1 // default=stile nuovo!

FUNCTION dfCalendarStyle(nNew)
   LOCAL nOld := nStyle
   IF VALTYPE(nNew) == "N"
      nStyle := nNew 
   ENDIF
RETURN nOld

FUNCTION dfCalendar(dData, lTitle)
#if XPPVER < 01900000
#else
   IF nStyle == 1 .AND. dfAXInstalled(XBPMVIEW_CLSID)
      RETURN dfCalendar1(dData, lTitle)
   ENDIF
#endif
RETURN dfCalendar0(dData)

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfCalendar0(dData)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL dDate := IIF(EMPTY(dData), DATE(), dData)
   LOCAL oCal := S2Calendar():new():create()
   LOCAL oPrev := S2FormCurr()

   S2FormCurr(oCal)

   IF oCal:inkey( dDate )
      dDate := oCal:date
      ACT := "ret"
   ELSE
      ACT := "esc"
   ENDIF

   oCal:destroy()

   IF oPrev != NIL
      S2FormCurr(oPrev)
   ENDIF

RETURN dDate

#if XPPVER < 01900000
#else

#include "activex.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfCalendar1(dData, lTitle)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL dDate := IIF(EMPTY(dData), DATE(), dData)
   LOCAL oPrev := S2FormCurr()

   DEFAULT lTitle TO .T.

   IF DisplayCalendar(oPrev, @dData, lTitle)
      dDate := dData
      ACT := "ret"
   ELSE
      ACT := "esc"
   ENDIF


   IF oPrev != NIL
      S2FormCurr(oPrev)
   ENDIF

RETURN dDate

******************************************************************************
* Display calendar with current booking
******************************************************************************
STATIC FUNCTION DisplayCalendar( oOwner, dData, lTitle )

   LOCAL oDlg
   LOCAL oXbp
   LOCAL oStat
   LOCAL aRect
   LOCAL l := .F.
   LOCAL oGet
   LOCAL aPos := NIL

   IF VALTYPE(lTitle)=="O"
      oGet := lTitle
      lTitle := .F.
   ENDIF

     oDlg := XbpDialog():New( AppDesktop(), oOwner )
     oDlg:Title       := CALENDAR_TITLE
     oDlg:Border      := XBPDLG_NO_BORDER //XBPDLG_RAISEDBORDERTHIN_FIXED
     oDlg:titleBar    := lTitle
     oDlg:Create( ,,,{100,100},, .F. )
     oDlg:drawingArea:setColorBG(GRA_CLR_BLACK)

     oStat := XbpStatic():new(oDlg:DrawingArea, NIL, {1, 1})
     oStat:create()

     oXbp := XbpActiveXControl():New( oStat )
     oXbp:CLSID   := XBPMVIEW_CLSID
     oXbp:Create()
     oXbp:titleBackColor := AutomationTranslateColor( XBPSYSCLR_APPWORKSPACE, .F.)
     oXbp:ShowWeekNumbers := .T.

     IF ! EMPTY(dData)
        oXbp:value := dData
     ENDIF

     oXbp:SetPos( {-3,-3} )

     aRect := oXbp:CurrentSize()
     aRect := {0,0,aRect[1],aRect[2]}
     aRect := oDlg:CalcFrameRect( aRect )
     IF lTitle
        aRect[3] -= 5
        aRect[4] -= 5
     ELSE
        aRect[3] -= 6
        aRect[4] -= 6
     ENDIF
     oStat:SetSize( {aRect[3],aRect[4]} )
     oDlg:setSize( {aRect[3]+2,aRect[4]+2}  )
     IF oGet == NIL
        CenterControl( oDlg, oOwner )
     ELSE
        aPos := dfCalcAbsolutePosition({0, 4}, oGet)
        aPos[2] -= oDlg:currentSize()[2]
        aPos[2] := MAX(S2WinStartMenuSize()[2], aPos[2])
        oDlg:setPos(aPos)
     ENDIF

     IF ! lTitle
        oDlg:killDisplayFocus := {|| oDlg:modalResult := XBP_MRESULT_CANCEL }
     ENDIF

     oDlg:Keyboard := {|n|IIF(n=xbeK_ESC, oDlg:modalResult := XBP_MRESULT_CANCEL, NIL)}
     oDlg:close := {|n|oDlg:modalResult := XBP_MRESULT_CANCEL}
     oXbp:dateDblClick:= {||dfPostAppEventCB({|| oDlg:modalResult := XBP_MRESULT_OK, XBASE_APPEVENT_IGNORE })}
     oXbp:keyboard := oDlg:keyboard

     SetAppFocus(oXbp)

     IF _evLoop(oDlg) == XBP_MRESULT_OK
        dData := oXbp:value
        l := .T.
     ENDIF
//     sleep(20)
     oDlg:Destroy()
RETURN l

STATIC FUNCTION _evLoop(oDlg)
   LOCAL oXbp, nEvent, mp1, mp2

   IF oDlg:killDisplayFocus==NIL
      oDlg:setModalState(XBP_DISP_APPMODAL)
   ENDIF

   oDlg:show()

   DO WHILE oDlg:modalResult == XBP_MRESULT_NONE
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp, NIL, oDlg )
      IF oXbp != NIL
         oXbp:handleEvent( nEvent, mp1, mp2 )
      ENDIF
   ENDDO

   // tolgo il "modale" altrimenti non ho il focus
   // sulla dialog base quando faccio il destroy()
   oDlg:setModalState(XBP_DISP_MODELESS)
RETURN oDlg:modalResult


#endif