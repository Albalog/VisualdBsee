#Include "Xbp.Ch"
#Include "Common.Ch"
#Include "Appevent.Ch"
#Include "Font.Ch"
#Include "Thread.Ch"
#Include "Gra.Ch"
#Include "ToolBar.Ch"
//#include "VdbI18N.ch"

****************************************************************************************************************************
**        General class to organize status line
****************************************************************************************************************************

CLASS StatusLine FROM XbpDialog
  //Costretto a commentare HIDDEN altrimenti non funziona la VdbStatusLine
  //HIDDEN
  // Fine Definzione modificata
  PROTECTED
  VAR Parent
  VAR ParArea
  VAR ParPos
  VAR ParSize
  VAR Elements
  VAR Objects
  VAR nLastEvent
  VAR Refresh
  VAR aEvents
  VAR Line
  VAR nArea
  EXPORTED
  VAR LeftMargin
  VAR Offset
  VAR High
  VAR Space
  METHOD Init
  METHOD Create
  METHOD destroy
  METHOD GoWithParent
  METHOD Resize
  METHOD Add
  METHOD Set
  METHOD Get
  METHOD AddEvent
  METHOD Organize
  METHOD UpdateEvent
  METHOD AddClientArea
  METHOD SetToolTip
ENDCLASS

METHOD StatusLine:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
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
::Line := XbpStatic():New(::drawingArea)
::Line:Type := XBPSTATIC_TYPE_RECESSEDLINE
//
::Elements := {}
::Objects := {}
::aEvents := {}
::LeftMargin := 5
::High := 24
::Offset := 2
::Space := 5
::nLastEvent := SECONDS()
::Refresh := 2
::nArea := 0
//
oParent:Resize := dfMergeBlocks(oParent:resize, {|| ::GoWithParent()})
//oParent:Resize := {|| ::GoWithParent()}
RETURN self

METHOD StatusLine:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
aPos := IF(aPos = NIL, {0, 0}, aPos)
aSize := IF(aSize = NIL, {::ParSize[1], ::High}, aSize)
::XbpDialog:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
::Line:Create(,, {0, ::DrawingArea:CurrentSize()[2] - 2}, {::DrawingArea:CurrentSize()[1], 2})
RETURN self

METHOD StatusLine:destroy()
   ASIZE(::Elements, 0)
   ASIZE(::Objects, 0)
   ASIZE(::aEvents, 0)
   ::XbpDialog:destroy()
RETURN self


METHOD StatusLine:Resize(aOld, aNew)
::XbpDialog:Resize(aOld, aNew)
::Line:SetSize({::DrawingArea:CurrentSize()[1], 2})
::Organize(aNew[1])
RETURN Self

METHOD StatusLine:GoWithParent
LOCAL aSize
::ParSize := ::ParArea:CurrentSize()
aSize := {::ParSize[1], ::High}
::SetSize(aSize)
RETURN self

METHOD StatusLine:Add(nMode, nDetail, Obj, cHit)
LOCAL oBox
IF LEN(::Elements) > 0
  //Adding separator line after each object
  oBox := StatusBox():New(::DrawingArea)
  oBox:Mode := SL_SEPARATOR
  oBox:High := ::High - (::Offset * 2)
  oBox:Create()
  AADD(::Elements, oBox)
ENDIF
oBox := StatusBox():New(::DrawingArea)
oBox:Mode := nMode
oBox:Detail := nDetail
oBox:Object := Obj
oBox:High := ::High - (::Offset * 2)
oBox:Hit := IF(cHit <> NIL, cHit, "")
oBox:Create()
AADD(::Elements, oBox)
AADD(::Objects, oBox)
::Organize()
RETURN self

METHOD StatusLine:Set(nObject, Object, cHit)
IF VALTYPE(nObject) == "N"   .AND.;
   nObject <= LEN(::Objects) .AND.;
   nObject >= 1
   ::Objects[nObject]:SetCaption(Object)
   ::Objects[nObject]:Hit := IF(cHit <> NIL, cHit, "")
ENDIF 
RETURN self

METHOD StatusLine:Get(nObject)
LOCAL xRet 
IF VALTYPE(nObject) == "N"   .AND.;
   nObject <= LEN(::Objects) .AND.;
   nObject >= 1
   xRet := (::Objects[nObject]:Get())
ENDIF 
RETURN xRet

METHOD StatusLine:Organize(nNewArea)
LOCAL nCount, nStart := ::LeftMargin, nSize := 0, nArea := 0, nAuto := 0, nObject := 0
nArea := IF(nNewArea = NIL, ::DrawingArea:CurrentSize()[1], nNewArea)
nArea -= (::LeftMargin * 2)
FOR nCount := 1 TO LEN(::Elements)
  nSize := ::Elements[nCount]:Display()
  IF ::Elements[nCount]:Detail = SL_MAXSIZE
    nAuto++
  ELSE
    nArea -= (nSize + ::Space)
  ENDIF
NEXT
nObject := INT(nArea / MAX(nAuto, 1))
FOR nCount := 1 TO LEN(::Elements)
  ::Elements[nCount]:SetPos({nStart, ::Offset})
  nSize := ::Elements[nCount]:Display(nObject)
  nStart += nSize + ::Space
NEXT
RETURN self

METHOD StatusLine:AddEvent(nObject, nPeriod, Object)
::Objects[nObject]:Refresh := nPeriod
::Objects[nObject]:Action := Object
AADD(::aEvents, ::Objects[nObject])
RETURN Self

METHOD StatusLine:UpdateEvent
LOCAL nSec := SECONDS(),nCount := 0
FOR nCount := 1 TO LEN(::aEvents)
  ::aEvents[nCount]:UpdateEvent()
NEXT
IF ::nLastEvent + ::Refresh < nSec
  ::Organize()
  ::nLastEvent := nSec
ENDIF
RETURN self

METHOD StatusLine:AddClientArea(nArea, oXbp)
IF IsMethod(oXbp, "RegisterToolAction")
  oXbp:RegisterToolAction(Self)
  ::nArea := nArea
ENDIF
RETURN self

METHOD StatusLine:SetToolTip(cTip)
::Set(::nArea, cTip)
RETURN self
