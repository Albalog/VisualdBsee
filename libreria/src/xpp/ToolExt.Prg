#Include "Xbp.Ch"
#Include "Common.Ch"
#Include "Appevent.Ch"
#Include "Font.Ch"
#Include "Thread.Ch"
#Include "Gra.Ch"
#Include "ToolBar.Ch"
//#include "VdbI18N.ch"

********************************************************************************************
**  Class to manage toolbar extenstion dialog to view unvisible toolbar elements

CLASS ToolExt FROM XbpDialog
  HIDDEN
  VAR oBox
  VAR aObjects
  VAR Distance
  METHOD Organize
  EXPORTED
  VAR LeftMargin
  VAR Space
  VAR High
  VAR Offset
  METHOD Init
  METHOD Create
  METHOD Display
  METHOD Resize
  METHOD KillDisplayFocus
  METHOD DeleteObjects
  METHOD Add
ENDCLASS

METHOD ToolExt:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
::XbpDialog:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
::Border := XBPDLG_NO_BORDER
::MaxButton := .F.
::MinButton := .F.
::SysMenu := .F.
::TitleBar := .F.
::DrawingArea:SetColorBG(GRA_CLR_WHITE)
::oBox := XbpStatic():New(::drawingArea)
::oBox:Type := XBPSTATIC_TYPE_FGNDFRAME
::aObjects := {}
::High := 24
::Offset := 2
::LeftMargin := 5
::Space := 5
::Distance := 1
RETURN self

METHOD ToolExt:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
::XbpDialog:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
::oBox:Create(,, {0, 0}, {::DrawingArea:CurrentSize()[1], ::DrawingArea:CurrentSize()[2]})
RETURN self

METHOD ToolExt:Resize(aOld, aNew)
::XbpDialog:Resize(aOld, aNew)
::oBox:SetSize({::DrawingArea:CurrentSize()[1], ::DrawingArea:CurrentSize()[2]})
::Organize()
RETURN Self

METHOD ToolExt:Display(aPos)
IF LEN(::aObjects) > 0
  ::Organize()
  ::SetPos({aPos[1] - ::DrawingArea:CurrentSize()[1], aPos[2] - ::DrawingArea:CurrentSize()[2]})
  ::Show()
  FixSetAppFocus(self)
ENDIF
RETURN self

METHOD ToolExt:KillDisplayFocus
::XbpDialog:KillDisplayFocus()
::Hide()
RETURN self

METHOD ToolExt:DeleteObjects
::aObjects := {}
RETURN self

METHOD ToolExt:Add(oXbp)
AADD(::aObjects, oXbp)
RETURN self

METHOD ToolExt:Organize
LOCAL nCount := 0, nStart := ::LeftMargin, nRows := MAX(INT(Sqrt(LEN(::aObjects))), 1), nRow := 0, nObj := 1, nMaxStart := 0
LOCAL nSize
nRow := (nRows - 1) * (::High + ::Distance)
FOR nCount := 1 TO LEN(::aObjects)
  ::aObjects[nCount]:SetPos({nStart, nRow + ::Offset})
  ::aObjects[nCount]:Display()
  nSize := ::aObjects[nCount]:CurrentSize()[1]
  ::aObjects[nCount]:Show()
  nStart += nSize + ::Space
  nMaxStart := MAX(nMaxStart, nStart)
  IF ++nObj > nRows .AND. nRow > 0
    nStart := ::LeftMargin
    nRow -= (::High + ::Distance)
    nObj := 1
  ENDIF
NEXT
//::SetSize({nStart, ::High})
::SetSize({nMaxStart, nRows * (::High + ::Distance) - ::Distance})
RETURN self

