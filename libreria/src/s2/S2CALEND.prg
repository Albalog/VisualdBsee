#include "Appevent.ch"
#include "Xbp.ch"
#include "gra.ch"
#include "dfStd.ch"
#include "Common.ch"
#include "dfXbase.ch"
#include "dfXRes.ch"
#include "dfMsg1.ch"
#include "dfSet.ch"

#define CALENDAR_TITLE dfStdMsg1(MSG1_S2CALENDAR01)
#define CALENDAR_TODAY dfStdMsg1(MSG1_S2CALENDAR02)      
#define CALENDAR_EXIT  dfStdMsg1(MSG1_S2CALENDAR03)     

#define BTN_WIDTH      20
#define TITLE_HEIGHT   20

#define NUM_DAYS       7
#define NUM_WEEKS      7

// 8/6/00 Nuovo calendario da terminare
// CLASS S2Calendar FROM XbpDialog
//    PROTECTED
//       VAR aDays
//       VAR oTitle, oPrev, oNext
//       METHOD DayCalcCaption
//
//    EXPORTED
//       VAR date, nInkey
//       METHOD Init, Create, Inkey, DayCalcPos, NextMonth, PrevMonth
//
// ENDCLASS
//
// METHOD S2Calendar:init(oParent, oOwner, aPos, aSize, aPP, lVisible )
//    LOCAL nDay := 0
//    LOCAL nWeek := 0
//
//    DEFAULT oParent TO AppDesktop()
//    DEFAULT oOwner  TO S2FormCurr()
//    //DEFAULT aSize   TO {300, 300 }
//    DEFAULT aSize   TO {160, 150 }
//
//    DEFAULT lVisible TO .F.
//
//    aPos := oParent:currentSize()
//    aPos[1] := (aPos[1] - aSize[1]) / 2
//    aPos[2] := (aPos[2] - aSize[2]) / 2
//
//    ::XbpDialog:Init(oParent, oOwner, aPos, aSize, aPP, lVisible )
//    ::title := CALENDAR_TITLE
//    //::titleBar := .F.
//    ::close := {|| ::date := NIL, ::nInkey := -1 }
//    //::keyboard := {|n| IIF(n==xbeK_ESC, PostAppEvent(xbeP_Close, NIL, NIL, self), NIL) }
//    ::keyboard := {|n| IIF(n==xbeK_ESC, EVAL(::close), NIL) }
//
//    ::oTitle := XbpStatic():new(::drawingArea)
//    ::oTitle:options := XBPSTATIC_TEXT_CENTER+XBPSTATIC_TEXT_VCENTER
//    // ::oTitle:lbDown := {|aPos| ::DragStart(aPos) }
//    // ::oTitle:lbUp   := {|aPos| ::DragEnd(aPos) }
//    // ::oTitle:motion := {|aPos| ::DragMove(aPos) }
//
//    ::oPrev  := ie4Button():new(::drawingArea, NIL, NIL, {BTN_WIDTH,TITLE_HEIGHT})
//    ::oPrev:caption := BTN_PREV
//    ::oPrev:type := XBPSTATIC_TYPE_BITMAP
//    // ::oPrev:caption := "<"
//    ::oPrev:activate := {|| ::PrevMonth() }
//
//    ::oNext  := ie4Button():new(::drawingArea, NIL, NIL, {BTN_WIDTH,TITLE_HEIGHT})
//    // ::oNext:caption := ">"
//    ::oNext:caption := BTN_NEXT
//    ::oNext:type := XBPSTATIC_TYPE_BITMAP
//    ::oNext:activate := {|| ::nextMonth() }
//
//    ::drawingArea:resize := {|| ::dayCalcPos() }
//
//    // ::dragStartDlgPos := NIL
//    // ::dragStartPos := NIL
//
//    ::aDays := ARRAY(7,5)
//
//    ::nInkey := 0
//
//    // 1^ riga: nome dei giorni
//
//
//
//    FOR nDay := 1 TO 7
//       ::aDays[nDay, 1] := XbpStatic():new(::drawingArea)
//       ::aDays[nDay, 1]:options := XBPSTATIC_TEXT_CENTER+XBPSTATIC_TEXT_VCENTER
//       ::aDays[nDay, 1]:caption := LOWER(LEFT(dfNum2Day(nDay), 1))
//    NEXT
//
//          ::aDays[nDay, nWeek]:activate := {|u1,u2,o| ::date := o:cargo, ::nInkey := 1 }
//
//    FOR nWeek := 1 TO 5
//       FOR nDay := 1 TO 7
//          ::aDays[nDay, nWeek]:= ::CalcDayNum(nWeek, nDay)
//       NEXT
//    NEXT
//
//    ::oBrowse          := XbpQuickBrowse():new( oDialog:drawingArea,,, oDialog:drawingArea:currentSize(), aPP, .F. )
//    ::oBrowse:dataLink := DacPagedDataStore():new( ::aDays  )
//
// RETURN self
//
// METHOD S2Calendar:CalcDayNum(nWeek, nDay, dDate)
//    LOCAL nMonth
//    LOCAL nYear
//    LOCAL nDow
//
//    DEFAULT dDate TO ::date
//
//    nMonth := MONTH(dDate)
//    nYear  := YEAR(dDate)
//
//    nDow := DOW(dfNToD(1, nMonth, nYear))-1
//
//    IF nDow == 0
//       nDow := 7
//    ENDIF
//
//    nWeek--
//    nDay--
//
//    dDate := dDate - nDow + nWeek * 7 + nDay
//
// RETURN ALLTRIM(STR(DAY(dDate)))
//
//
// METHOD S2Calendar:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
//    LOCAL nDay
//    ::XbpDialog:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
//    ::oTitle:create()
//    ::oPrev:create()
//    ::oNext:create()
//
//    FOR nDay := 1 TO LEN(::aDays)
//       AEVAL(::aDays[nDay], {|x| x:create() })
//    NEXT
//
//    ::DayCalcPos()
//
// RETURN self
//
// METHOD S2Calendar:DayCalcPos()
//    LOCAL nWeek
//    LOCAL nDay
//    LOCAL aSize := ::drawingArea:currentSize()
//    LOCAL aPos  := {0, 0}
//
//    aSize[2] -= TITLE_HEIGHT
//
//    aPos[2] := aSize[2]
//    ::oPrev:setPos(aPos)
//
//    aPos[1] += BTN_WIDTH
//    ::oTitle:setPos(aPos)
//
//    aPos := { aSize[1], TITLE_HEIGHT}
//    aPos[1] -= 2*BTN_WIDTH
//    ::oTitle:setSize(aPos)
//
//    aPos[1] := aSize[1] - BTN_WIDTH
//    aPos[2] := aSize[2]
//    ::oNext:setPos(aPos)
//
//    aSize[1] := INT(aSize[1]) / 7
//    aSize[2] := INT(aSize[2]) / 6
//
//    FOR nWeek := 1 TO 6
//       aPos[1] := 0
//       aPos[2] -= aSize[2]
//       FOR nDay := 1 TO 7
//          ::aDays[nDay, nWeek]:setPos(aPos)
//          ::aDays[nDay, nWeek]:setSize(aSize)
//
//          aPos[1] += aSize[1]
//       NEXT
//    NEXT
//
// RETURN self
//
// METHOD S2Calendar:NextMonth()
//    ::Date := dfAddMonth(::date, 1)
//    ::DayCalcCaption()
// RETURN
//
// METHOD S2Calendar:PrevMonth()
//    ::Date := dfAddMonth(::date, -1)
//    ::DayCalcCaption()
// RETURN
//
// METHOD S2Calendar:DayCalcCaption( dDate )
//    LOCAL dFirst := NIL
//    LOCAL nFirst := 0
//    LOCAL nEOM   := 0
//    LOCAL nCount := 0
//    LOCAL nMonth := 0
//    LOCAL nYear  := 0
//    LOCAL nInd   := 0
//    LOCAL nWeek  := 0
//
//    DEFAULT dDate TO ::date
//
//    nMonth := MONTH(dDate)
//    nYear  := YEAR(dDate)
//
//    ::oTitle:setCaption(dfNum2Month(nMonth) + " "+ STR(nYear, 4))
//
//    dDate := dfNTod(1, nMonth, nYear)
//
//    nFirst := DOW( dDate ) -1
//    IF nFirst == 0
//       nFirst := 7
//    ENDIF
//
//    dDate := dfAddMonth(dDate, 1)-1
//    nEOM := DAY(dDate)
//
//    FOR nInd := 1 TO 7
//       IF nInd >= nFirst
//          ::aDays[nInd, 2]:setCaption( ALLTRIM(STR(++nCount)) )
//          ::aDays[nInd, 2]:cargo := dfNToD(nCount, nMonth, nYear)
//          ::aDays[nInd, 2]:show()
//       ELSE
//          ::aDays[nInd, 2]:setCaption( "" )
//          ::aDays[nInd, 2]:cargo := NIL
//          ::aDays[nInd, 2]:hide()
//       ENDIF
//    NEXT
//
//    FOR nWeek := 3 TO 5
//       FOR nInd := 1 TO 7
//          ::aDays[nInd, nWeek]:setCaption( ALLTRIM(STR(++nCount)) )
//          ::aDays[nInd, nWeek]:cargo := dfNToD(nCount, nMonth, nYear)
//          ::aDays[nInd, nWeek]:show()
//       NEXT
//    NEXT
//
//    FOR nInd := 1 TO 7
//       IF nCount >= nEOM
//          ::aDays[nInd, 6]:setCaption( "" )
//          ::aDays[nInd, 6]:cargo := NIL
//          ::aDays[nInd, 6]:hide()
//       ELSE
//          ::aDays[nInd, 6]:setCaption( ALLTRIM(STR(++nCount)) )
//          ::aDays[nInd, 6]:cargo := dfNToD(nCount, nMonth, nYear)
//          ::aDays[nInd, 6]:show()
//       ENDIF
//    NEXT
//
// RETURN self
//
// METHOD S2Calendar:inkey( dDate )
//    LOCAL oFocus := SetAppFocus( self )
//    LOCAL mp1, mp2, oXbp, nEvent
//
//    ::setModalState( XBP_DISP_APPMODAL )
//    ::date := dDate
//
//    ::dayCalcCaption()
//
//    ::show()
//
//
//    ::nInkey := 0
//
//    DO WHILE ::nInkey == 0
//       nEvent := dfAppEvent( @mp1, @mp2, @oXbp )
//
//       IF oXbp != NIL
//          oXbp:handleEvent( nEvent, mp1, mp2 )
//       ENDIF
//    ENDDO
//
//    ::setModalState( XBP_DISP_MODELESS )
//
//    SetAppFocus(oFocus)
//    ::hide()
//
// RETURN ::nInkey > 0

CLASS S2Calendar FROM XbpDialog
   PROTECTED
      VAR aDays
      VAR oTitle, oPrev, oNext
      METHOD DayCalcCaption

   EXPORTED
      VAR date, nInkey
      METHOD Init, Create, Inkey, DayCalcPos, NextMonth, PrevMonth

  //  PROTECTED
  //     VAR dragStartPos, dragStartDlgPos
  //
  //  EXPORTED
  //     INLINE METHOD dragStart(aPos)
  //        IF ::dragStartPos == NIL
  //           ::dragStartPos := aPos
  //           ::dragStartDlgPos := ::currentPos()
  //           ::oTitle:captureMouse(.T.)
  //        ENDIF
  //     RETURN self
  //
  //     INLINE METHOD dragEnd(aPos)
  //        IF ! ::dragStartPos == NIL
  //           ::setPos({::dragStartDlgPos[1]+aPos[1]-::dragStartPos[1], ;
  //                     ::dragStartDlgPos[2]+aPos[2]-::dragStartPos[2]} )
  //           ::dragStartDlgPos := NIL
  //           ::dragStartPos := NIL
  //           ::oTitle:captureMouse(.F.)
  //        ENDIF
  //     RETURN self
  //
  //     INLINE METHOD dragMove(aPos)
  //        IF ! ::dragStartPos == NIL
  //           ::setPos({::dragStartDlgPos[1]+aPos[1]-::dragStartPos[1], ;
  //                     ::dragStartDlgPos[2]+aPos[2]-::dragStartPos[2]} )
  //           ::dragStartPos := aPos
  //           ::dragStartDlgPos := ::currentPos()
  //        ENDIF
  //     RETURN self
ENDCLASS

METHOD S2Calendar:init(oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL nDay := 0
   LOCAL nWeek := 0
   LOCAL aColor

   DEFAULT oParent TO AppDesktop()
   DEFAULT oOwner  TO S2FormCurr()
   //DEFAULT aSize   TO {300, 300 }
   DEFAULT aSize   TO {160, 180 }

   DEFAULT lVisible TO .F.

   aPos := oParent:currentSize()
   aPos[1] := (aPos[1] - aSize[1]) / 2
   aPos[2] := (aPos[2] - aSize[2]) / 2

   ::XbpDialog:Init(oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::title := CALENDAR_TITLE

   aColor:=dfColor( "dfCalendar" )
   IF EMPTY(aColor) 
      aColor := {"W+/RB",  "W+/B", "W+/B", "W+/G*" , "W+/B" }
   ENDIF


   //::titleBar := .F.
   ::close := {|| ::date := NIL, ::nInkey := -1 }
   //::keyboard := {|n| IIF(n==xbeK_ESC, PostAppEvent(xbeP_Close, NIL, NIL, self), NIL) }
   ::keyboard := {|n| IIF(n==xbeK_ESC, EVAL(::close), NIL) }

   ::oTitle := XbpStatic():new(::drawingArea)
   ::oTitle:options := XBPSTATIC_TEXT_CENTER+XBPSTATIC_TEXT_VCENTER

   IF aColor != NIL
      S2ObjSetColors(::drawingArea, .T., aColor[AC_CALC_BACK])
      S2ObjSetColors(::oTitle, .T., aColor[AC_CALC_MONTH])
   ENDIF

   // ::oTitle:lbDown := {|aPos| ::DragStart(aPos) }
   // ::oTitle:lbUp   := {|aPos| ::DragEnd(aPos) }
   // ::oTitle:motion := {|aPos| ::DragMove(aPos) }

   ::oPrev  := ie4Button():new(::drawingArea, NIL, NIL, {BTN_WIDTH,TITLE_HEIGHT})
   ::oPrev:caption := BTN_PREV
   ::oPrev:type := XBPSTATIC_TYPE_BITMAP
   // ::oPrev:caption := "<"
   ::oPrev:activate := {|| ::PrevMonth() }

   ::oNext  := ie4Button():new(::drawingArea, NIL, NIL, {BTN_WIDTH,TITLE_HEIGHT})
   // ::oNext:caption := ">"
   ::oNext:caption := BTN_NEXT
   ::oNext:type := XBPSTATIC_TYPE_BITMAP
   ::oNext:activate := {|| ::nextMonth() }

   ::drawingArea:resize := {|| ::dayCalcPos() }

   // ::dragStartDlgPos := NIL
   // ::dragStartPos := NIL

   ::aDays := ARRAY(NUM_DAYS, NUM_WEEKS)

   ::nInkey := 0

   // 1^ riga: nome dei giorni

   FOR nDay := 1 TO NUM_DAYS
      ::aDays[nDay, 1] := XbpStatic():new(::drawingArea)
      ::aDays[nDay, 1]:options := XBPSTATIC_TEXT_CENTER+XBPSTATIC_TEXT_VCENTER
      ::aDays[nDay, 1]:caption := LOWER(LEFT(dfNum2Day(nDay), 1))
   NEXT

   FOR nWeek := 2 TO NUM_WEEKS
      FOR nDay := 1 TO NUM_DAYS
         ::aDays[nDay, nWeek] := XbpPushButton():new(::drawingArea)
         ::aDays[nDay, nWeek]:activate := {|u1,u2,o| ::date := o:cargo, ::nInkey := 1 }
      NEXT
   NEXT

RETURN self

METHOD S2Calendar:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL nDay
   ::XbpDialog:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::oTitle:create()
   ::oPrev:create()
   ::oNext:create()

   FOR nDay := 1 TO LEN(::aDays)
      AEVAL(::aDays[nDay], {|x| x:create() })
   NEXT

   ::DayCalcPos()

RETURN self

METHOD S2Calendar:DayCalcPos()
   LOCAL nWeek
   LOCAL nDay
   LOCAL aSize := ::drawingArea:currentSize()
   LOCAL aPos  := {0, 0}

   aSize[2] -= TITLE_HEIGHT

   aPos[2] := aSize[2]
   ::oPrev:setPos(aPos)

   aPos[1] += BTN_WIDTH
   ::oTitle:setPos(aPos)

   aPos := { aSize[1], TITLE_HEIGHT}
   aPos[1] -= 2*BTN_WIDTH
   ::oTitle:setSize(aPos)

   aPos[1] := aSize[1] - BTN_WIDTH
   aPos[2] := aSize[2]
   ::oNext:setPos(aPos)

   aSize[1] := INT(aSize[1]) / NUM_DAYS
   aSize[2] := INT(aSize[2]) / NUM_WEEKS

   FOR nWeek := 1 TO NUM_WEEKS
      aPos[1] := 0
      aPos[2] -= aSize[2]
      FOR nDay := 1 TO NUM_DAYS
         ::aDays[nDay, nWeek]:setPos(aPos)
         ::aDays[nDay, nWeek]:setSize(aSize)

         aPos[1] += aSize[1]
      NEXT
   NEXT

RETURN self

METHOD S2Calendar:NextMonth()
   ::Date := dfAddMonth(::date, 1)
   ::DayCalcCaption()
RETURN

METHOD S2Calendar:PrevMonth()
   ::Date := dfAddMonth(::date, -1)
   ::DayCalcCaption()
RETURN

METHOD S2Calendar:DayCalcCaption( dDate )
   LOCAL dFirst := NIL
   LOCAL nFirst := 0
   LOCAL nEOM   := 0
   LOCAL nCount := 0
   LOCAL nMonth := 0
   LOCAL nYear  := 0
   LOCAL nInd   := 0
   LOCAL nWeek  := 0

   DEFAULT dDate TO ::date

   nMonth := MONTH(dDate)
   nYear  := YEAR(dDate)

   ::oTitle:setCaption(dfNum2Month(nMonth) + " "+ STR(nYear, 4))

   dDate := dfNTod(1, nMonth, nYear)

   nFirst := DOW( dDate ) -1
   IF nFirst == 0
      nFirst := 7
   ENDIF

   dDate := dfAddMonth(dDate, 1)-1
   nEOM := DAY(dDate)

   FOR nInd := 1 TO NUM_DAYS
      IF nInd >= nFirst
         ::aDays[nInd, 2]:setCaption( ALLTRIM(STR(++nCount)) )
         ::aDays[nInd, 2]:cargo := dfNToD(nCount, nMonth, nYear)
         ::aDays[nInd, 2]:show()
      ELSE
         ::aDays[nInd, 2]:setCaption( "" )
         ::aDays[nInd, 2]:cargo := NIL
         ::aDays[nInd, 2]:hide()
      ENDIF
   NEXT

   FOR nWeek := 3 TO NUM_WEEKS
      FOR nInd := 1 TO NUM_DAYS

         IF nCount >= nEOM
            ::aDays[nInd, nWeek]:setCaption( "" )
            ::aDays[nInd, nWeek]:cargo := NIL
            ::aDays[nInd, nWeek]:hide()
         ELSE
            ::aDays[nInd, nWeek]:setCaption( ALLTRIM(STR(++nCount)) )
            ::aDays[nInd, nWeek]:cargo := dfNToD(nCount, nMonth, nYear)
            ::aDays[nInd, nWeek]:show()
         ENDIF

         // ::aDays[nInd, nWeek]:setCaption( ALLTRIM(STR(++nCount)) )
         // ::aDays[nInd, nWeek]:cargo := dfNToD(nCount, nMonth, nYear)
         // ::aDays[nInd, nWeek]:show()
      NEXT
   NEXT

   // FOR nInd := 1 TO NUM_DAYS
   //    IF nCount >= nEOM
   //       ::aDays[nInd, NUM_WEEKS]:setCaption( "" )
   //       ::aDays[nInd, NUM_WEEKS]:cargo := NIL
   //       ::aDays[nInd, NUM_WEEKS]:hide()
   //    ELSE
   //       ::aDays[nInd, NUM_WEEKS]:setCaption( ALLTRIM(STR(++nCount)) )
   //       ::aDays[nInd, NUM_WEEKS]:cargo := dfNToD(nCount, nMonth, nYear)
   //       ::aDays[nInd, NUM_WEEKS]:show()
   //    ENDIF
   // NEXT

RETURN self

METHOD S2Calendar:inkey( dDate )
   LOCAL oFocus := SetAppFocus( self )
   LOCAL mp1, mp2, oXbp, nEvent

   ::setModalState( XBP_DISP_APPMODAL )
   ::date := dDate

   ::dayCalcCaption()

   ::show()


   ::nInkey := 0

   DO WHILE ::nInkey == 0
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp )

      IF oXbp != NIL
         oXbp:handleEvent( nEvent, mp1, mp2 )
      ENDIF
   ENDDO

   ::setModalState( XBP_DISP_MODELESS )

   SetAppFocus(oFocus)
   ::hide()

RETURN ::nInkey > 0

