#Include "Xbp.Ch"
#Include "Common.Ch"
#Include "Appevent.Ch"
#Include "Font.Ch"
#Include "Thread.Ch"
#Include "Gra.Ch"
#Include "ToolBar.Ch"
//#include "VdbI18N.ch"

#define THREAD_IDLE  0
#define THREAD_STOP  1

#define WAIT_READTIME  15

STATIC oThread
STATIC aToolbars:={}
STATIC nThreadState := THREAD_IDLE

// Simone 16/5/2005
// Mantis 0000551: errore xppfatal destroy toolbar form designer
// Mantis 0000568: chiusura improvvisa Visual dBsee in salvataggio Form da form designer
// gestione di un unico thread per tutte le toolbars

PROCEDURE ToolClassInit
   ToolBarThread()
RETURN 

// lancia thread secondario per gestione toolbar
FUNCTION ToolbarThread()
   IF oThread == NIL
      oThread := Thread():New()
      //oThread:SetStartTime(SECONDS() + ::Start)
      oThread:Start({|| ToolbarExecute() })
   ENDIF
RETURN NIL

// aggiunge una toolbar da gestire
// nel thread secondario
STATIC FUNCTION ToolbarThreadAdd(o)
   SyncStop() // mette il thread in stato di STOP
   AADD(aToolbars, o) 
   SyncIdle() // mette il thread in stato di IDLE
RETURN NIL

// toglie una toolbar da gestire
// nel thread secondario
STATIC FUNCTION ToolbarThreadDel(o)
   LOCAL n

   SyncStop() // mette il thread in stato di STOP

   n:=ASCAN(aToolbars, o)
   IF n>0
      AREMOVE(aToolbars, n)
   ENDIF

   SyncIdle() // mette il thread in stato di IDLE
RETURN NIL

// esegue il metodo execute per tutte le toolbars
// eseguito in thread secondario
STATIC FUNCTION ToolbarExecute()
   LOCAL nTB, oTB

   DO WHILE .T. 
      SyncIdle() // mette il thread in stato di IDLE

      Sleep(WAIT_READTIME)

      SyncStop() // mette il thread in stato di STOP

      FOR nTB := 1 TO LEN(aToolbars)
         aToolbars[nTB]:execute()
      NEXT
   ENDDO
RETURN NIL

STATIC FUNCTION SyncStop()
   // aspetta che il thread sia fermo
   DO WHILE nThreadState != THREAD_IDLE
      sleep(20)
   ENDDO
   
   nThreadState := THREAD_STOP // blocca il thread secondario
RETURN .T.

STATIC FUNCTION SyncIdle()
   nThreadState := THREAD_IDLE // sblocca il thread secondario
RETURN .T.

// Simone 9/giu/04
// - rinominata classe in toolbar100 per evitare conflitti
//   con la classe toolbar della libreria dbsee
// Simone 17/mag/04
// - migliorato l'uso del thread, quando si fa il destroy rilascia correttamente il thread
****************************************************************************************************************************
**        General class to organize tool bar
**        Inspired on XbpToolBar (author Markus Reuscher)
**        Implementation by Adrian Wykrota - Poland 2003
****************************************************************************************************************************

CLASS ToolBar100 FROM XbpDialog
  //Costretto a commentare HIDDEN altrimenti non funziona la VdbToolbar
  //HIDDEN
  // Fine Definzione modificata
  PROTECTED:
  VAR Parent
  VAR ParArea
  VAR ParPos
  VAR ParSize
  VAR oLine
  VAR aButtons
  VAR ThreadId
  VAR ToolNumber
  VAR oTip
  VAR aLastMotionPos
  VAR oLastMotionXbp
  VAR lTip
  VAR nTipRequest
  VAR nTipHide
  VAR lSetup
  VAR MyColorFg
  VAR Active
  VAR aClient
  VAR ToolActionObject
  VAR oThread
  METHOD Organize
  METHOD MyEvent
  METHOD EventOnRegisteredClient
  METHOD NormalColor
  METHOD ShowTip
  METHOD UpdateEvent
  METHOD Debug
  METHOD UpdateActionTool
  EXPORTED
  VAR ReadTime
  VAR LeftMargin
  VAR Space
  VAR High
  VAR Offset
  VAR Start
  VAR Debug
  VAR Sensivity
  VAR DelayTip
  VAR ExtDlg
  VAR lAddSetup
  METHOD Init
  METHOD Create
  METHOD GoWithParent
  METHOD Resize
  METHOD Add
  METHOD Set
  METHOD HideTip
  METHOD ShowMenuExt
  METHOD SetDisplayFocus
  METHOD KillDisplayFocus
  METHOD AddClient
  METHOD RegisterToolAction
  METHOD destroy
  METHOD Execute
ENDCLASS

METHOD toolbar100:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
::XbpDialog:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
::Border := XBPDLG_NO_BORDER
::MaxButton := .F.
::MinButton := .F.
::SysMenu := .F.
::TitleBar := .F.
//
::Parent := oParent
IF IsMemberVar(::parent, "DrawingArea")
   ::ParArea := ::Parent:DrawingArea
ELSE
   ::ParArea := ::Parent
ENDIF
::ParPos := ::ParArea:CurrentPos()
::ParSize := ::ParArea:CurrentSize()
//
::ReadTime := 15
::High := 24
::Offset := 2
::aButtons := {}
::LeftMargin := 5
::Space := 5
::Start := 1
::ToolNumber := 0
::aLastMotionPos := {}
::oLastMotionXbp := NIL
::lTip := .F.
::Debug := .F.
::nTipRequest := 0
::nTipHide := 0
::Sensivity := 1
::DelayTip := 3
::lSetup := .F.
::MyColorFg := GraMakeRGBColor({236,233,216})
::Active := .F.
::aClient := {}
::ToolActionObject := NIL
//
::ExtDlg := ToolExt():New(AppDeskTop(), AppDeskTop(), {0, 0}, {0, 0},, .F.)
//
::oLine := XbpStatic():New(::drawingArea)
::oLine:Type := XBPSTATIC_TYPE_RECESSEDLINE
::oTip := ToolTip():new(AppDesktop(),AppDesktop(), {0, 0}, {0, 0}):Create()
//
::ThreadId := ThreadID()
::lAddSetup := .T.
//::oThread := Thread():New()

oParent:Resize := dfMergeBlocks(oParent:resize, {|| ::GoWithParent()})
IF IsMemberVar(oParent, "SetDisplayFocus")
   oParent:KillDisplayFocus := {|| ::KillDisplayFocus()}
   oParent:SetDisplayFocus := {|| ::SetDisplayFocus()}
ENDIF
RETURN self

METHOD toolbar100:destroy()
  LOCAL n := ::readTime

  ToolBarThreadDel(self)

  // attesa termine thread
  ::active := .F.
  ::readTime := -1
//  ::oThread:synchronize(0)
//  DO WHILE ::oThread:active
//     sleep(20)
//  ENDDO
  ::oThread:=NIL
  ::readTime := n

  ::XbpDialog:destroy()
  IF VALTYPE(::ExtDlg) == "O" .AND. ::extDlg:status() == XBP_STAT_CREATE
     ::ExtDlg:destroy()
  ENDIF
RETURN self

METHOD toolbar100:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
aPos := IF(aPos = NIL, {::ParPos[1], ::ParSize[2] - ::High}, aPos)
aSize := IF(aSize = NIL, {::ParSize[1], ::High}, aSize)
::XbpDialog:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
::oLine:Create(,, {0, ::DrawingArea:CurrentSize()[2] - 2}, {::DrawingArea:CurrentSize()[1], 2})
::ExtDlg:High := ::High
::ExtDlg:Offset := ::Offset
::ExtDlg:LeftMargin := ::LeftMargin
::ExtDlg:Space := ::Space
::ExtDlg:Create()
::ToolNumber := 1
::Add(TB_START)
IF ! ::lSetup .AND. ::lAddSetup
   //Last element is setup element
   ::Add(TB_SETUP)
   ::lSetup := .T.
ENDIF
//::oThread:SetStartTime(SECONDS() + ::Start)
//::oThread:Start({||::execute()})

ToolBarThreadAdd(self)

::Active := .T.
RETURN self

METHOD toolbar100:Resize(aOld, aNew)
::XbpDialog:Resize(aOld, aNew)
::oLine:SetSize({::DrawingArea:CurrentSize()[1], 2})
::Organize()
RETURN Self

METHOD toolbar100:GoWithParent
LOCAL aPos, aSize
::ParPos := ::ParArea:CurrentPos()
::ParSize := ::ParArea:CurrentSize()
aPos := {::ParPos[1], ::ParSize[2] - ::High}
aSize := {::ParSize[1], ::High}
::SetPos(aPos)
::SetSize(aSize)
RETURN self

METHOD toolbar100:EventOnRegisteredClient(oXbp)
LOCAL lRet := .F., nCount := 0
FOR nCount := 1 TO LEN(::aClient)
  IF ::MyEvent(::aClient[nCount], oXbp)
    lRet := .T.
    nCount := LEN(::aClient) + 1
  ENDIF
NEXT
RETURN (lRet)

METHOD toolbar100:MyEvent(oObj, oXbp)
LOCAL lRet := .F., aChilds := {}
IF oObj:STATUS() == XBP_STAT_CREATE
  aChilds := oObj:DrawingArea:ChildList()
  lRet := (ASCAN(aChilds, {|x| x == oXbp}) > 0)
  IF !lRet
    lRet := (ASCAN(aChilds, {|x| IsMethod(x, "GetBody") .AND. x:GetBody() == oXbp}) > 0)
    IF !lRet
      lRet := (ASCAN(aChilds, {|x| IsMethod(x, "GetText") .AND. x:GetText() == oXbp}) > 0)
      IF !lRet
        lRet := (ASCAN(aChilds, {|x| IsMethod(x, "GetExtend") .AND. x:GetExtend() == oXbp}) > 0)
        IF !lRet
          lRet := (ASCAN(aChilds, {|x| IsMethod(x, "GetCombo") .AND. x:GetCombo() == oXbp}) > 0)
        ENDIF
      ENDIF
    ENDIF
  ENDIF
ENDIF
RETURN (lRet)

METHOD toolbar100:NormalColor(nNumber)
LOCAL nStop := -1
DO WHILE nStop <> 0
  nStop := ASCAN(::aButtons, {|x| x[2]}, nStop + 1)
  IF (nStop > 0 .AND. nNumber = NIL) .OR. (nStop > 0 .AND. nStop <> nNumber)
    ::aButtons[nStop][TBD_OBJ]:Shadow(.F.)
    ::aButtons[nStop][TBD_SHADOW] := .F.
  ENDIF
ENDDO
RETURN self

METHOD toolbar100:Add(nMode, Disp, bAction, cHit)
LOCAL oButton
IF ::lSetup
  ::ToolNumber++
ENDIF
oButton := ToolButton():New(::drawingArea)
oButton:Mode := nMode
oButton:Display := Disp
oButton:Action := bAction
oButton:Hit := cHit
oButton:Offset := ::Offset
oButton:Number := (::ToolNumber)
oButton:Parent := self
oButton:Create()
IF ::lSetup
  AADD(::aButtons, {oButton, .F., .F.}, LEN(::aButtons))
  ::aButtons[LEN(::aButtons)][TBD_OBJ]:SetNumber(::ToolNumber + 1)
ELSE
  AADD(::aButtons, {oButton, .F., .F.})
ENDIF
::Organize()
RETURN oButton

METHOD toolbar100:Set(nNumber, Disp, bAction, cHit)
//Skip first element
nNumber++
IF Disp <> NIL
  ::aButtons[nNumber][TBD_OBJ]:SetCaption(Disp)
ENDIF
IF bAction <> NIL
  ::aButtons[nNumber][TBD_OBJ]:Action := bAction
ENDIF
IF cHit <> NIL
  ::aButtons[nNumber][TBD_OBJ]:Hit := cHit
ENDIF
::Organize()
RETURN self

METHOD toolbar100:AddClient(oXbp)
AADD(::aClient, oXbp)
RETURN Self

METHOD toolbar100:UpdateEvent
LOCAL nCount := 0
FOR nCount := 1 TO LEN(::aButtons)
  IF ::aButtons[nCount][TBD_OBJ]:Mode = TB_EVENT
    ::aButtons[nCount][TBD_OBJ]:UpdateEvent()
  ENDIF
NEXT
FOR nCount := 1 TO LEN(::aClient)
  ::aClient[nCount]:UpdateEvent()
NEXT
RETURN self

METHOD toolbar100:Organize
LOCAL nCount := 0, nStart := ::LeftMargin, nArea := ::drawingArea:CurrentSize()[1], nSize := 0, lOver := .F.
::ExtDlg:DeleteObjects()
//Len a setup button plus right margin
nArea -= (14 + 5)
FOR nCount := 1 TO LEN(::aButtons) - 1
  ::aButtons[nCount][TBD_OBJ]:SetPos({nStart, ::Offset})
  ::aButtons[nCount][TBD_OBJ]:Display()
  nSize := ::aButtons[nCount][TBD_OBJ]:CurrentSize()[1]
  IF !lOver .AND. nStart + nSize < nArea
    ::aButtons[nCount][TBD_OBJ]:SetNormalColor(::MyColorFg)
    ::aButtons[nCount][TBD_OBJ]:SetParent(::DrawingArea)
    ::aButtons[nCount][TBD_OBJ]:Show()
    nStart += nSize + ::Space
  ELSE
    ::aButtons[nCount][TBD_OBJ]:SetNormalColor(GRA_CLR_WHITE)
    ::aButtons[nCount][TBD_OBJ]:SetParent(::ExtDlg:DrawingArea)
    ::ExtDlg:Add(::aButtons[nCount][TBD_OBJ])
    ::aButtons[nCount][TBD_OBJ]:Hide()
    lOver := .T.
  ENDIF
NEXT
//Configure setup element
::aButtons[LEN(::aButtons)][TBD_OBJ]:SetNormalColor(::MyColorFg)
::aButtons[LEN(::aButtons)][TBD_OBJ]:SetPos({nStart, ::Offset})
::aButtons[LEN(::aButtons)][TBD_OBJ]:Display(lOver)
RETURN self

METHOD toolbar100:Execute
LOCAL nEvent := 0, mp1 := 0, mp2 := 0, oXbp := NIL, nSec := 0
//DO WHILE ::readTime > 0
//  Sleep(::ReadTime)
  nSec := SECONDS()
  IF ::Active
    nEvent := LastAppEvent(@mp1, @mp2, @oXbp, ::ThreadId)
    ::UpdateEvent()
    ::Debug("Event : " + alltrim(str(nevent)))
    IF nEvent = xbeM_Motion
      ::aLastMotionPos := ACLONE(mp1)
      ::oLastMotionXbp := oXbp
      IF ::MyEvent(self, oXbp) .OR. ::MyEvent(::ExtDlg, oXbp) .OR. ::EventOnRegisteredClient(oXbp)
        IF !IsMethod(oXbp, "Shadow")
          oXbp := oXbp:SetParent()
        ENDIF
        IF IsMethod(oXbp, "Shadow")
          ::Debug("Motion")
          ::UpdateActionTool(oXbp:Hit)
          IF oXbp:Shadow(.T.)
            ::HideTip()
            ::nTipRequest := nSec + ::Sensivity
          ELSEIF nSec >= ::nTipRequest .AND. !::lTip
            ::ShowTip(oXbp:Hit)
            ::nTipHide := nSec + ::DelayTip
            //After 2 minutes tip is show once again
            ::nTipRequest += (60 * 2)
          ELSEIF nSec >= ::nTipHide
            ::HideTip()
          ENDIF
          IF IsMethod(oXbp, "ToolNum")
            ::aButtons[oXbp:ToolNum()][TBD_SHADOW] := .T.
            ::NormalColor(oXbp:ToolNum())
          ELSE
            ::NormalColor()
          ENDIF
        ELSE
          ::Debug("Unknown object")
          ::HideTip()
          ::NormalColor()
        ENDIF
      ELSE
        ::HideTip()
        ::NormalColor()
      ENDIF
    ELSEIF nEvent = xbeM_Idle
      oXbp := ::oLastMotionXbp
      IF ::MyEvent(self, oXbp) .OR. ::MyEvent(::ExtDlg, oXbp) .OR. ::EventOnRegisteredClient(oXbp)
        IF !IsMethod(oXbp, "Shadow")
          oXbp := oXbp:SetParent()
        ENDIF
        IF IsMethod(oXbp, "Shadow")
          ::Debug("Idle")
          ::UpdateActionTool(oXbp:Hit)
          IF nSec >= ::nTipRequest .AND. !::lTip
            ::ShowTip(oXbp:Hit)
            ::nTipHide := nSec + ::DelayTip
            //After 2 minutes tip is show once again
            ::nTipRequest += (60 * 2)
          ELSEIF nSec >= ::nTipHide
            ::HideTip()
          ENDIF
        ENDIF
      ELSE
        ::HideTip()
        ::NormalColor()
      ENDIF
    ENDIF
  ENDIF
//ENDDO
RETURN self

METHOD toolbar100:ShowTip(cTxt)
LOCAL aPos
aPos  := CalcAbsolutePosition(::aLastMotionPos, ::oLastMotionXbp)
::oTip:SetPos({aPos[1] + 6, aPos[2] - 33})
IF !EMPTY(cTxt)
  ::oTip:PaintTip(cTxt)
  ::oTip:Show()
  ::lTip := .T.
ENDIF
RETURN self

METHOD toolbar100:HideTip
IF ::lTip
  ::oTip:Hide()
  ::lTip := .F.
ENDIF
RETURN self

METHOD toolbar100:Debug(cText)
IF ::Debug
  ::aButtons[3][TBD_OBJ]:SetCaption(cText)
ENDIF
RETURN self

METHOD toolbar100:ShowMenuExt()
::ExtDlg:Display(CalcAbsolutePosition(::aLastMotionPos, ::oLastMotionXbp))
RETURN self

METHOD toolbar100:SetDisplayFocus
::XbpDialog:SetDisplayFocus()
::Active := .T.
RETURN self

METHOD toolbar100:KillDisplayFocus
::XbpDialog:KillDisplayFocus()
//Don't working with ToolExt dialog
//::Active := .F.
RETURN self

METHOD toolbar100:RegisterToolAction(oXbp)
::ToolActionObject := oXbp
RETURN self

METHOD toolbar100:UpdateActionTool(cHit)
IF ::ToolActionObject <> NIL .AND. IsMethod(::ToolActionObject, "SetToolTip")
  ::ToolActionObject:SetToolTip(cHit)
ENDIF
RETURN self

STATIC FUNCTION CalcAbsolutePosition(aPos,oXbp)
LOCAL aAbsPos := AClone(aPos), oParent := oXbp, oDesktop := AppDesktop()
DO WHILE oParent <> oDesktop
  aAbsPos[1] += oParent:currentPos()[1]
  aAbsPos[2] += oParent:currentPos()[2]
  oParent := oParent:setParent()
ENDDO
RETURN (aAbsPos)
