#Include "Xbp.Ch"
#Include "Common.Ch"
#Include "Appevent.Ch"
#Include "Font.Ch"
#Include "Thread.Ch"
#Include "Gra.Ch"
#Include "ToolBar.Ch"
//#include "VdbI18N.ch"

// simone 18/05/06
// modificato colore tooltip
// usa xbpstatic invece di xbpdialog

********************************************************************************************
**  Class to manage toolbar tool tip object

CLASS ToolTip FROM _XbpDialog
  HIDDEN
  VAR oTip
  VAR oBox
  EXPORTED
  METHOD Init
  METHOD Create
  METHOD Resize
  METHOD PaintTip
ENDCLASS

METHOD ToolTip:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
::_XbpDialog:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
::Border := XBPDLG_NO_BORDER
::MaxButton := .F.
::MinButton := .F.
::SysMenu := .F.
::TitleBar := .F.
::oBox := XbpStatic():New(::drawingArea)
::oBox:Type := XBPSTATIC_TYPE_FGNDFRAME
::oTip := XbpStatic():new(::DrawingArea)
::oTip:Caption := ""
RETURN self

METHOD ToolTip:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
LOCAL aSz := {}
::_XbpDialog:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
::DrawingArea:SetColorFG(XBPSYSCLR_INFOTEXT) 
::DrawingArea:SetColorBG(XBPSYSCLR_INFOBACKGROUND) //GraMakeRgbColor({255,247,145}))
aSz := ::DrawingArea:CurrentSize()
::oBox:create()
::oBox:SetPos({0, 0})
::oBox:SetSize({aSz[1], aSz[2]})
::oTip:create()
::oTip:SetPos({1, 1})
::oTip:SetSize({aSz[1] - 2, aSz[2] - 2})
RETURN self

METHOD ToolTip:PaintTip(cTxt)
LOCAL oPS, aPoints := {}, aSize := {0,0}
oPS := ::lockPS()
aPoints := GraQueryTextBox(oPS, cTxt)
::unlockPS(oPS)
aSize := {(aPoints[3][1] - aPoints[1][1]) + 8, (aPoints[1][2] - aPoints[2][2]) + 4}
::setSize(aSize)
::oTip:SetCaption(cTxt)
RETURN self

METHOD ToolTip:Resize(aOld, aNew)
::_XbpDialog:Resize(aOld, aNew)
::oBox:SetSize({aNew[1], aNew[2]})
::oTip:SetSize({aNew[1] - 2, aNew[2] - 2})
RETURN self


STATIC CLASS _XbpDialog FROM XbpStatic
EXPORTED
  VAR border
  VAR maxbutton
  var minbutton
  var sysmenu
  var titlebar
  var drawingarea
  inline method Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
     lVisible := .F.
     DEFAULT aPP TO {}
     aadd(aPP, {XBP_PP_COMPOUNDNAME,FONT_DEFPROP_SMALL })
     ::xbpstatic:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
     ::drawingarea:=self
  return self

  inline method destroy(oParent, oOwner, aPos, aSize, aPP, lVisible)
     ::drawingarea:=nil
     ::xbpstatic:destroy()
  return self
ENDCLASS