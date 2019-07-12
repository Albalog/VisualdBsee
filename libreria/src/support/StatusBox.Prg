#Include "Xbp.Ch"
#Include "Common.Ch"
#Include "Appevent.Ch"
#Include "Font.Ch"
#Include "Thread.Ch"
#Include "Gra.Ch"
#Include "ToolBar.Ch"
//#include "VdbI18N.ch"

********************************************************************************************
**  Class to manage status bar elements

CLASS StatusBox FROM XbpStatic
  HIDDEN
  VAR nSize
  VAR nLastEvent
  VAR oBmp
  VAR OkBmp
  VAR ResBmp
  METHOD Bmp
  EXPORTED
  VAR Mode
  VAR Detail
  VAR Object
  VAR High
  VAR Refresh
  VAR Action
  VAR Hit
  METHOD Init
  METHOD Create
  METHOD Display
  METHOD UpdateEvent
  METHOD SetCaption
  METHOD Get
  METHOD Shadow
  METHOD DisplayBmp
ENDCLASS

METHOD StatusBox:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
::XbpStatic:Init(oParent, oOwner, aPos, aSize, aPP, lVisible)
::Mode := 0
::Detail := 0
::Object := ""
::High := 24
::nSize := 0
::nLastEvent := SECONDS()
::Refresh := 2
::Action := NIL
::Hit := ""
::ResBmp := 0
::oBmp := NIL
::OkBmp := .F.
RETURN self

METHOD StatusBox:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
IF ::Mode = SL_SEPARATOR
  ::Type := XBPSTATIC_TYPE_RAISEDBOX
  ::nSize := 2
ELSEIF ::Mode = SL_TEXT
  ::Type := XBPSTATIC_TYPE_TEXT
  IF ::Detail = SL_AUTO
    ::Options := XBPSTATIC_TEXT_CENTER + XBPSTATIC_TEXT_VCENTER
  ELSE
    ::Options := XBPSTATIC_TEXT_VCENTER
  ENDIF
  ::Caption := ::Object
  ::nSize := ::Detail
ELSEIF ::Mode = SL_ICON
  ::Type := XBPSTATIC_TYPE_ICON
  ::Caption := ::Object
  ::nSize := ::High
ELSEIF ::Mode = SL_BITMAP
  ::paint := {| aClip | ::DisplayBmp( aClip ) }
  ::Bmp(::Object)
  ::nSize := ::High
ENDIF
aSize := IF(aSize = NIL, {::nSize, ::High}, aSize)
::XbpStatic:Create(oParent, oOwner, aPos, aSize, aPP, lVisible)
RETURN self

METHOD StatusBox:Display(nLength)
LOCAL oPs, aPoints := {}
IF ::Mode = SL_TEXT .AND. ::Detail = SL_AUTO
  oPs := ::LockPs()
  aPoints := GraQueryTextBox(oPS, ::Caption)
  ::UnLockPs(oPs)
  ::nSize := aPoints[3][1] + 10
  ::SetSize({::nSize, ::High})
ELSEIF ::Mode = SL_TEXT .AND. ::Detail = SL_MAXSIZE
  ::nSize := IF(nLength = NIL, 10, nLength)
  ::SetSize({::nSize, ::High})
ENDIF
RETURN (::nSize)

METHOD StatusBox:UpdateEvent
LOCAL nSec := SECONDS()
IF ::nLastEvent + ::Refresh < nSec
  IF ::Action <> NIL
    ::SetCaption(EVAL(::Action))
  ENDIF
  ::nLastEvent := nSec
ENDIF
RETURN self

METHOD StatusBox:SetCaption(cTxt)
IF ::Mode = SL_BITMAP
  ::Bmp(cTxt)
  ::DisplayBmp()
ELSE
  ::XbpStatic:SetCaption(cTxt)
ENDIF
RETURN Self

METHOD StatusBox:Get
LOCAL Ret := NIL
IF ::Mode = SL_BITMAP
  Ret := ::ResBmp
ELSE
  Ret := ::Caption
ENDIF
RETURN Ret

METHOD StatusBox:Shadow
LOCAL lRet := .F.
IF !EMPTY(::Hit)
  lRet := .T.
ENDIF
RETURN (lRet)

METHOD StatusBox:Bmp(nRes)
IF ::oBmp = NIL
  ::oBmp := XbpBitmap():new():Create()
ENDIF
::ResBmp := 0
IF ::oBmp:Load(NIL, nRes)
  ::OkBmp := .T.
  ::ResBmp := nRes
ELSE
  ::OkBmp := .F.
ENDIF
RETURN (::oBmp)

METHOD StatusBox:DisplayBmp(aClip)
LOCAL lSuccess := .F., aSize := ::currentSize(), aTarget, aSource, nAspect, oPS
IF ::oBmp <> NIL .AND. ::OkBmp
  oPS := ::LockPS()
  GraPathClip(oPS, .T. )
  aSource := {0, 0, ::oBmp:xSize, ::oBmp:ySize}
  aTarget := {0, 0, aSize[1] - 1, aSize[2] - 1}
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

