#Include "Xbp.Ch"
#Include "Common.Ch"
#Include "Appevent.Ch"
#Include "Font.Ch"
#Include "Thread.Ch"
#Include "Gra.Ch"
#Include "ToolBar.Ch"
#Include "dfMsg1.Ch"
//#include "VdbI18N.ch"

********************************************************************************************
**  Class to manage toolbar elements

CLASS ToolButton FROM XbpStatic
  //Costretto a commentare HIDDEN altrimenti non funziona la VdbToolbottom
  //HIDDEN
  // Fine Definzioni modificate
  PROTECTED
  VAR High
  VAR IfShadow
  VAR lShadow
  VAR lBody
  VAR lExtend
  VAR lText
  VAR lCombo
  VAR nLastEvent
  VAR NormalColor
  VAR oBmp
  VAR OkBmp
  METHOD OutLine
  EXPORTED
  VAR Mode
  VAR Display
  VAR Action
  VAR Hit
  VAR Offset
  VAR Number
  VAR Body
  VAR Extend
  VAR Text
  VAR Parent
  VAR Combo
  METHOD Init
  METHOD Create
  METHOD SetCaption
  METHOD LbDown
  METHOD LbUp
  METHOD Display
  METHOD Bmp
  METHOD Shadow
  METHOD ToolNum
  METHOD SetNumber
  METHOD GetBody
  METHOD GetText
  METHOD GetExtend
  METHOD GetCombo
  METHOD UpdateEvent
  METHOD Menu
  METHOD SetNormalColor
  METHOD DisplayBmp
ENDCLASS

METHOD ToolButton:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
::XbpStatic:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
::High := oParent:CurrentSize()[2]
::Mode := 0
::Display := NIL
::Action := NIL
::Hit := ""
::Caption := ""
::Offset := 0
::IfShadow := .F.
::lShadow := .F.
::Number := 1
::Parent := NIL
::Body := XbpStatic():New(Self, Self)
::lBody := .F.
::Extend := XbpStatic():New(Self, Self)
::lExtend := .F.
::Text := XbpStatic():New(Self, Self)
::lText := .F.
::Combo := XbpComboBox():New(Self, Self)
::lCombo := .F.
::nLastEvent := SECONDS()
::NormalColor := GRA_CLR_WHITE
::oBmp := NIL
::OkBmp := .F.
RETURN self

METHOD ToolButton:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
LOCAL nSize := ::High - (::Offset * 2), nPointer := 0
aPos := IF(aPos = NIL, {0, 0}, aPos)
IF ::Mode > 0
  IF ::Mode = TB_START
    ::Type := XBPSTATIC_TYPE_RAISEDBOX
    aSize := IF(aSize = NIL, {2, nSize}, aSize)
    //::Hit := "Move tool bar"
    //nPointer := XBPSTATIC_SYSICON_SIZE
  ELSEIF ::Mode = TB_SETUP
    ::Body:Type := XBPSTATIC_TYPE_ICON
    ::Body:Caption := 2000
    ::Extend:Type := XBPSTATIC_TYPE_ICON
    ::Extend:Caption := 2002
    aSize := IF(aSize = NIL, {14, nSize}, aSize)
    ::lBody := .T.
    ::lExtend := .T.
    ::IfShadow := .T.
    ::Hit := dfStdMsg1(MSG1_TOOLCLASS01)      //::Hit := "Configure Toolbar" //MSG
    ::Action := {|| ::Parent:ShowMenuExt()}
  ELSEIF ::Mode = TB_SEPARATOR
    ::Type := XBPSTATIC_TYPE_RECESSEDBOX
    aSize := IF(aSize = NIL, {2, nSize}, aSize)
    //nPointer := XBPSTATIC_SYSICON_SIZEWE
  ELSEIF ::Mode = TB_BUTTON
    ::Body:paint := {| aClip | ::DisplayBmp( aClip ) }
    ::Bmp(::Display)
    aSize := IF(aSize = NIL, {nSize, nSize}, aSize)
    ::lBody := .T.
    ::IfShadow := .T.
  ELSEIF ::Mode = TB_ICON
    ::Body:Type := XBPSTATIC_TYPE_ICON
    ::Body:Caption := ::Display
    aSize := IF(aSize = NIL, {nSize, nSize}, aSize)
    ::IfShadow := .T.
    ::lBody := .T.
  ELSEIF ::Mode = TB_ICONTXT
    ::Body:Type := XBPSTATIC_TYPE_ICON
    ::Body:Caption := ::Display[TBD_ICON_ICON]
    ::Text:Options := XBPSTATIC_TEXT_CENTER + XBPSTATIC_TEXT_VCENTER
    ::Text:Options := XBPSTATIC_TEXT_VCENTER
    ::Text:Caption := ::Display[TBD_ICON_TEXT]
    aSize := IF(aSize = NIL, {100, nSize}, aSize)
    ::IfShadow := .T.
    ::lBody := .T.
    ::lText := .T.
  ELSEIF ::Mode = TB_TEXT
    ::Type := XBPSTATIC_TYPE_TEXT
    ::Options := XBPSTATIC_TEXT_CENTER + XBPSTATIC_TEXT_VCENTER
    ::Caption := ::Display
    aSize := IF(aSize = NIL, {100, nSize}, aSize)
    ::IfShadow := .T.
  ELSEIF ::Mode = TB_COMBO
    aSize := IF(aSize = NIL, {::Display[1] + 4, nSize}, aSize)
    ::IfShadow := .T.
    ::lCombo := .T.
  ELSEIF ::Mode = TB_EVENT
    ::Type := XBPSTATIC_TYPE_TEXT
    ::Options := XBPSTATIC_TEXT_CENTER + XBPSTATIC_TEXT_VCENTER
    ::Caption := EVAL(::Action)
    aSize := IF(aSize = NIL, {100, nSize}, aSize)
    ::IfShadow := .T.
  ENDIF
  ::XbpStatic:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
  IF nPointer <> 0
    ::SetPointer(, nPointer, XBPWINDOW_POINTERTYPE_SYSPOINTER)
  ENDIF
  IF ::lBody
    ::Body:Create()
    ::Body:SetPos({2, 2})
    ::Body:SetSize({aSize[2] - 4, aSize[2] - 4})
    ::Body:LbUp := {|| ::LbUp()}
    ::Body:LbDown := {|aPos, uNIL, oObj| ::LbDown(aPos)}
  ENDIF
  IF ::lExtend
    ::Extend:Create()
    ::Body:SetSize({aSize[1] - 4, aSize[1] - 4})
    ::Extend:SetPos({2, aSize[1] - 1})
    ::Extend:SetSize({aSize[1] - 4, aSize[1] - 4})
    ::Extend:LbUp := {|| ::LbUp()}
    ::Extend:LbDown := {|| ::LbDown()}
  ENDIF
  IF ::lText
    ::Text:Create()
    ::Text:SetPos({aSize[2] + 2, 2})
    ::Text:SetSize({aSize[1] - 4, aSize[2] - 4})
    ::Text:LbUp := {|| ::LbUp()}
    ::Text:LbDown := {|| ::LbDown()}
  ENDIF
  IF ::lCombo
    ::Combo:Type := XBPCOMBO_DROPDOWNLIST
    ::Combo:Create()
    ::Combo:SetPos({2, -196 + 2})
    ::Combo:SetSize({::Display[1], 196 + nSize - 4})
    AEVAL(::Display[2], {|x| ::Combo:AddItem(x)})
    ::Combo:SetData({::Display[3]})
    ::Combo:ItemSelected := ::Action
  ENDIF
ENDIF
RETURN self

METHOD ToolButton:UpdateEvent
LOCAL nSec := SECONDS()
IF ::Mode = TB_EVENT .AND. ::nLastEvent + ::Display < nSec
//IF ::Mode = TB_EVENT .AND. nSec + ::Display > ::nLastEvent
  ::SetCaption(EVAL(::Action))
  ::nLastEvent := nSec
ENDIF
RETURN self

METHOD ToolButton:ToolNum
RETURN (::Number)

METHOD ToolButton:SetNumber(nNumber)
::Number := nNumber
RETURN self

METHOD ToolButton:GetBody
RETURN (::Body)

METHOD ToolButton:GetText
RETURN (::Text)

METHOD ToolButton:GetExtend
RETURN (::Extend)

METHOD ToolButton:GetCombo
RETURN (::Combo)

METHOD ToolButton:Bmp(nRes)
::oBmp := XbpBitmap():new():Create()
IF ::oBmp:Load(NIL, nRes)
  ::OkBmp := .T.
ELSE
  ::OkBmp := .F.
ENDIF
RETURN (::oBmp)

METHOD ToolButton:OutLine
LOCAL oPS, aAttr := ARRAY(GRA_AL_COUNT)
IF ::lShadow
  Sleep(1)
  oPS := ::LockPs()
  aAttr[GRA_AL_COLOR] := GraMakeRgbColor({49,106,197})
  oPS:SetAttrLine(aAttr)
  GraBox(oPS, {0, 0}, {::CurrentSize()[1] - 1, ::CurrentSize()[2] - 1}, GRA_OUTLINE)
  ::UnLockPs(oPS)
ENDIF
RETURN self

METHOD ToolButton:LbUp
::Parent:HideTip()
::SetColorBG(GraMakeRGBColor({193,210,238}))
::OutLine()
IF ::Action <> NIL .AND. ::Mode <> TB_EVENT
  EVAL(::Action)
ENDIF
RETURN self

METHOD ToolButton:LbDown(aPos)
::SetColorBG(GraMakeRGBColor({115,166,254}))
::OutLine()
IF ::Parent <> NIL
  ::Parent:HideTip()
ENDIF
RETURN self

METHOD ToolButton:Shadow(lSet)
LOCAL lRet := .F.
IF ::IfShadow
  IF lSet .AND. !::lShadow
    ::SetColorBG(GraMakeRGBColor({193,210,238}))
    ::lShadow := .T.
    lRet := .T.
    ::OutLine()
  ELSEIF !lSet .AND. ::lShadow
    ::SetColorBG(::NormalColor)
    ::lShadow := .F.
    lRet := .T.
  ENDIF
ENDIF
RETURN (lRet)

METHOD ToolButton:SetCaption(cTxt)
::XbpStatic:SetCaption(cTxt)
::OutLine()
RETURN self

METHOD ToolButton:Display(lOver)
LOCAL oPs, aPoints := {}
IF ::Mode = TB_TEXT .OR. ::Mode = TB_EVENT
  oPs := ::LockPs()
  aPoints := GraQueryTextBox(oPS, ::Caption)
  ::UnLockPs(oPs)
  ::SetSize({aPoints[3][1] + 10, ::CurrentSize()[2]})
ELSEIF ::Mode = TB_ICONTXT
  oPs := ::LockPs()
  aPoints := GraQueryTextBox(oPS, ::Text:Caption)
  ::UnLockPs(oPs)
  ::SetSize({::Body:CurrentSize()[1] + aPoints[3][1] + 10, ::CurrentSize()[2]})
ELSEIF ::Mode = TB_SETUP
  ::Extend:SetCaption(IF(lOver, 2002, 2001))
ENDIF
RETURN self

METHOD ToolButton:Menu
LOCAL Ret := NIL, oBmp
IF ::Mode = TB_START
  Ret := "UnKnown"
ELSEIF ::Mode = TB_SETUP
  Ret := ::Body:Caption
ELSEIF ::Mode = TB_SEPARATOR
  Ret := "Separator"
ELSEIF ::Mode = TB_BUTTON
  Ret := ::Body:Caption
ELSEIF ::Mode = TB_ICON
  oBmp := XbpBitmap():New()
  IF oBmp:Load(, ::Body:Caption)
    Ret := oBmp
  ELSE
    Ret := "Error"
  ENDIF
ELSEIF ::Mode = TB_ICONTXT
  Ret := ::Text:Caption
ELSEIF ::Mode = TB_TEXT
  Ret := ::Caption
ELSEIF ::Mode = TB_EVENT
  Ret := "Event"
ENDIF
RETURN (Ret)

METHOD ToolButton:SetNormalColor(nColor)
::NormalColor := nColor
::SetColorBG(::NormalColor)
RETURN self

METHOD ToolButton:DisplayBmp(aClip)
LOCAL lSuccess := .F., aSize := ::Body:currentSize(), aTarget, aSource, nAspect, oPS
IF ::oBmp <> NIL .AND. ::OkBmp
  oPS := ::LockPS()
  GraPathClip(oPS, .T. )
  aSource := {0, 0, ::oBmp:xSize, ::oBmp:ySize}
  aTarget := {2, 2, aSize[1], aSize[2]}
  nAspect    := aSource[3] / aSource[4]
  IF nAspect > 1
    aTarget[4] := aTarget[3] / nAspect
  ELSE
    aTarget[3] := aTarget[4] * nAspect
  ENDIF
  IF aTarget[3] < aSize[1] - 2
    nAspect := ( aSize[1] - 2 - aTarget[3] ) / 2
    aTarget[1] += nAspect
    aTarget[3] += nAspect
  ENDIF
  IF aTarget[4] < aSize[2] - 2
    nAspect := ( aSize[2] - 2 - aTarget[4] ) / 2
    aTarget[2] += nAspect
    aTarget[4] += nAspect
  ENDIF
  ::oBmp:Draw(oPS, aTarget, aSource,, GRA_BLT_BBO_IGNORE )
  Sleep(1)
  GraPathClip(oPS, .F. )
  ::UnLockPS(oPS)
ENDIF
RETURN lSuccess

