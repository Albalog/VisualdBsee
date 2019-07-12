#include "Common.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "Dll.ch"

#define CRLF (chr(13)+chr(10))

//---------------------------------------------------------------------------
/*
FUNCTION _S2ButtonX(aPos,aSize,cText,oParent,cFont,xColor,lAutoSize,;
                   xAction,xImage,aImageSize,cSound,lDisabled,lHide,;
                   nMouse,cDllFile,nMouseType,lPush,nStyle,nName,oSave,lSide)
  LOCAL lValid := .T., oXbp
  DEFAULT lAutoSize TO .F.
//  DEFAULT oParent TO _DefaultDialogParent
  IF aSize[1] == NIL
    lAutoSize := .T.
  ENDIF
  IF lAutoSize
    aSize := _TextSize(cText,oParent,cFont)
  ENDIF
  oXbp := S2ButtonX():new(oParent,,aPos,aSize)
  IF lPush
    oXbp:Style := 0
  ENDIF
  IF ! EMPTY(nStyle)
    oXbp:Style := nStyle
  ENDIF
  IF cFont != NIL
    oXbp:setFontCompoundName(cFont)
  ENDIF
  IF cText != NIL
    oXbp:type := XBPSTATIC_TYPE_TEXT
    oXbp:caption := cText
  ENDIF
  IF nName != NIL
    oXbp:setName(nName)
  ENDIF
  IF xImage != NIL
    oXbp:Image := xImage
    IF lSide
      oXbp:side := .T.
    ENDIF
  ENDIF
  IF aImageSize[1] != NIL
    oXbp:ImageSize := aImageSize
  ENDIF
  IF xColor != NIL
    DO CASE
    CASE VALTYPE(xColor) == "A"
      IF xColor[1] != NIL
        oXbp:setColorBG(xColor[1])
      ENDIF
      IF xColor[2] != NIL
        oXbp:setColorFG(xColor[2])
      ENDIF
      IF LEN(xColor) > 2
        oXbp:focusColor := xColor[3]
      ENDIF
    CASE VALTYPE(xColor) == "C"
      MSGBOX("char color not supported yet")
    CASE VALTYPE(xColor) == "N"
      oXbp:setColorFG(xColor)
      oXbp:setColorBG(oParent:setColorBG())
    ENDCASE
  ELSE
    IF ValType(oParent:setColorBG())=="N"
      oXbp:setColorBG(oParent:setColorBG())
    ENDIF
    IF ValType(oParent:setColorFG())=="N"
      oXbp:setColorFG(oParent:setColorFG())
    ENDIF
  ENDIF
  IF nMouse != NIL
    oXbp:setPointer(cDllFile,nMouse,nMouseType)
  ENDIF
  IF lAutoSize
    oXbp:autoSize := .T.
  ENDIF
  DO CASE
  CASE ValType(xAction) == "B"
    oXbp:activate := xAction
  ENDCASE
  IF cSound != NIL
    oXbp:sound := cSound
  ENDIF
  IF lHide
    oXbp:visible := .F.
  ENDIF
  oXbp:create()
  IF lDisabled
    oXbp:disable()
  ENDIF
  IF ValType(oSave) == "A"
    AADD(oSave,oXbp)
  ELSE
    oSave := oXbp
  ENDIF
RETURN lValid

//---------------------------------------------------------------------------

FUNCTION _BDUPDATEBUTTON(xName,aPos,aSize,cText,cFont,xColor,oParent,;
                         lAutoSize,xAction,cSound,lDisabled,lEnabled,;
                         lHide,lShow,nMouse,cDllFile,nMouseType,xImage,;
                         aImageSize)
  LOCAL lValid := .T., oXbp
//  DEFAULT oParent TO _DefaultDialogParent
  IF Valtype(xName) == "O"
    oXbp := xName
  ELSE
    oXbp := oParent:childFromName(xName)
  ENDIF
  IF aPos[1] != NIL
    oXbp:setPos(aPos)
  ENDIF
  IF aSize[1] != NIL
    oXbp:setSize(aPos)
  ENDIF
  IF cText != NIL
    oXbp:type := XBPSTATIC_TYPE_TEXT
    oXbp:caption := cText
  ENDIF
  IF lAutoSize
    oXbp:autoSize := .T.
  ENDIF
  IF cFont != NIL
    oXbp:setFontCompoundName(cFont)
  ENDIF
  IF nMouse != NIL
    oXbp:setPointer(cDllFile,nMouse,nMouseType)
  ENDIF
  IF xImage != NIL
    oXbp:Image := xImage
//    IF lSide
//      oXbp:side := .T.
//    ENDIF
  ENDIF
  IF aImageSize[1] != NIL
    oXbp:ImageSize := aImageSize
  ENDIF
  IF xColor != NIL
    DO CASE
    CASE VALTYPE(xColor) == "A"
      oXbp:setColorBG(xColor[1])
      oXbp:setColorFG(xColor[2])
      IF LEN(xColor) > 2
        oXbp:focusColor := xColor[3]
      ENDIF
    CASE VALTYPE(xColor) == "C"
      MSGBOX("char color not supported yet")
    CASE VALTYPE(xColor) == "N"
      oXbp:setColorFG(xColor)
      oXbp:setColorBG(oParent:setColorBG())
    ENDCASE
  ENDIF
  DO CASE
  CASE ValType(xAction) == "B"
    IF cSound != NIL
      oXbp:activate := {|a,b,c,d,e|_PlaySound(cSound),EVAL(xAction,a,b,c,d,e)}
    ELSE
      oXbp:activate := xAction
    ENDIF
  ENDCASE
  IF xAction == NIL .AND. cSound != NIL
    oXbp:activate := {||_PlaySound(cSound)}
  ENDIF
  IF (!lDisabled) .AND. (!lEnabled)
    lDisabled := (! oXbp:isEnabled())
  ENDIF
  oXbp:configure()
  IF lDisabled
    oXbp:disable()
  ENDIF
  IF lEnabled
    oXbp:enable()
  ENDIF
  IF lHide
    oXbp:hide()
  ENDIF
  IF lShow
    oXbp:show()
  ENDIF
RETURN lValid
*/
//---------------------------------------------------------------------------


Class S2ButtonX from xbpstatic
  EXPORTED
    VAR Caption, Image, activate, Size, lastPos, button, Type, ImageType
    VAR focusColorFG, font, Imagesize, autosize, sound, Style, side
    VAR disabledColorFG
    VAR disabledColorBG
    VAR focusColorBG, focusColorBorder
    VAR UpOnClick
    VAR onFocusStyle
    VAR toolTipText
    VAR lInvertImageOnDisable

    METHOD init,create, focus, activate, disable, enable, Invert, destroy
    METHOD setFontCompoundName, isenabled, setColorBG
    METHOD setInputFocus, killInputFocus
    METHOD handleEvent
    METHOD paintFocus
    METHOD press
    METHOD setCaption
    METHOD configure
    METHOD setSize
    METHOD setPosAndSize

    INLINE METHOD GetoImage() ;RETURN ::oImage 
    INLINE METHOD GetoStatic();RETURN ::oStatic
    INLINE METHOD GetoBkGrd() ;RETURN ::oBkGrd
  
  HIDDEN
    VAR oImage, oStatic, oXbp, lFocus, enabled, originalcolor, ImageColor, oBkGrd
    VAR nPrevColorFG, nPrevColorBG, aPrevTextPos
    VAR aPrevFocusColor
    METHOD focusOn, focusOff


Endclass

method S2ButtonX:init( oParent, oOwner, aLoc, aSize, aPresParm, lVisible )
  ::xbpStatic:init( oParent, oOwner, aLoc, aSize, aPresParm, lVisible )
  ::XbpStatic:type := XBPSTATIC_TYPE_RAISEDRECT
  ::Style := 0
  ::side := .F.
  ::oStatic := xbpstatic():New( ::xbpstatic )
  ::oBkGrd := xbpstatic():New( ::xbpstatic )
  ::Caption := ''
  ::Image := 0
  ::ImageType := XBPSTATIC_TYPE_ICON
  ::activate := {|| nil }
  ::lFocus := .f.
  ::Size := aSize
  ::XbpStatic:Motion := {|aPos,u,oS| ::Focus( aPos ) }
  ::type := XBPSTATIC_TYPE_TEXT
  ::Lastpos := {-1,-1}
  ::enabled := .t.
  ::button := .f.
  ::autosize := .F.
  ::ImageSize := {}
  ::sound := NIL
//  ::tabStop := .T.
  ::disabledColorFG := GRA_CLR_DARKGRAY
//  ::disabledColorBG := XBPSYSCLR_INACTIVEBORDER
  ::disabledColorBG := NIL  // quando si imposta questo si deve impostaer anche ::setColorBG() !!!!
  ::UpOnclick := .T.
  ::OnFocusStyle := XBPSTATIC_TYPE_RAISEDRECT
  ::lInvertImageOnDisable := .T.
  IF ! EMPTY(oParent)
     ::font := oParent:setFontCompoundName()
  ENDIF

  ::focusColorFG := GRA_CLR_BLUE
//  ::focusColorBorder := GraMakeRgbColor({49,106,197})
//  ::focusColorBG     := GraMakeRGBColor({193,210,238})
  ::aPrevFocusColor  := NIL

Return self

method S2ButtonX:destroy()
   ::Lastpos := {-1,-1}
   ::button := .f.
   ::lfocus := .f.
   ::ImageSize := {}
   ::XbpStatic:destroy()
return self

Method S2ButtonX:setInputFocus()
::invalidateRect()
//  ::focusOn()
return self

Method S2ButtonX:killInputFocus()
::invalidateRect()
//  ::focusOff()
return self

Method S2ButtonX:Create( oParent, oOwner, aLoc, aSize, aPresParm, lVisible )
  LOCAL aTextSize := {0,0}, oTemp, oBitmap, oPS, nPos := 0, cString := ""
  LOCAL nStart := 1, aTemp := {}, cCaption := IIF(VALTYPE(cCaption) $ "CM", ::caption + CRLF, "")
  LOCAL aISize, aTarget, nAspect, aSource
  
  IF ::Style == 1
    ::XbpStatic:type := XBPSTATIC_TYPE_TEXT
  ELSEIF ::Style == 2
    ::XbpStatic:type := XBPSTATIC_TYPE_BGNDFRAME
  ENDIF

  if ::type == XBPSTATIC_TYPE_TEXT
    IF ! EMPTY(::font)
       ::oStatic:setFontCompoundName(::font)
    ENDIF
  endif
  IF VALTYPE(::caption) $ "CM" 
     nPos := AT(CHR(10),::caption)
     IF nPos == 0
       aTextSize := _TextSize(::Caption,::xbpStatic:setParent(),::font)
     ELSE
       DO WHILE nPos != 0
         cString := SUBSTR(cCaption,nStart,nPos)
         aTemp := _TextSize(cString,::xbpStatic:setParent(),::font)
         IF aTemp[1] > aTextSize[1]
           aTextSize[1] := aTemp[1]
         ENDIF
         aTextSize[2] += aTemp[2]
         nStart := nPos + 1
         cCaption := SUBSTR(cCaption,nStart)
         nPos := AT(CHR(10),cCaption)
       ENDDO
     ENDIF
  ENDIF
  IF EMPTY(::caption)
     ::side := .F.
     aTextSize := {0, 0}
  ENDIF
  IF EMPTY(::Image)
     ::ImageSize := {0, 0}
  
  ELSEIF EMPTY(::ImageSize)
    IF Valtype(::Image) == "C"
      oTemp := S2XbpBitmap():new():create()
      IF VALTYPE(::image) == "C"
         oTemp:loadfile(::Image)
      ELSE
         oTemp:load(NIL, ::Image)
      ENDIF
      ::ImageSize := {oTemp:xSize+2,oTemp:ySize+2}
//      IF (!::AutoSize) .AND. ::side
//        IF ::ImageSize[1] > ::Size[1]-aTextSize[1]
//          ::ImageSize[1] := ::Size[1]-aTextSize[1] - 10
//        ENDIF
//        IF ::ImageSize[2] > ::Size[2]
//          ::ImageSize[2] := ::Size[2] - 6
//        ENDIF
//      ENDIF
    ELSE
        oTemp := XbpStatic():new(IIF(EMPTY(oParent), ::setParent(), oParent),,{0,0},{0,0})
        oTemp:autoSize := .T.
        oTemp:Type := ::Imagetype
        oTemp:Caption := ::Image
        oTemp:create()
        ::ImageSize := oTemp:currentSize()
    ENDIF
    oTemp:destroy()
  ENDIF
  IF ::AutoSize
    IF aSize == NIL
      aSize := {0,0}
    ENDIF
    IF ::side
      aSize[1] := aTextSize[1] + ::ImageSize[1] + 15
      aSize[2] := IF(aTextSize[2] > ::ImageSize[2],aTextSize[2],::ImageSize[2])+6
    ELSE
      aSize[1] := IF(aTextSize[1] > ::ImageSize[1],aTextSize[1],::ImageSize[1])+6
      aSize[2] := aTextSize[2] + ::ImageSize[2] + 10
    ENDIF
  ENDIF

  ::Size := iif( aSize <> nil, aSize, ::Size )

  ::xbpStatic:Create( oParent, oOwner, aLoc, aSize, aPresParm, lVisible )


  ::oBkGrd := XbpStatic():new()
  ::oBkGrd:type := XBPSTATIC_TYPE_TEXT
  ::oBkGrd:Motion := {|aPos,u,oS| ::Focus( {aPos[1]-2,aPos[2]-2 }) }
  ::oBkGrd:paint  := {|aPos,u,oS| ::PaintFocus(self) }

// Uncomment for thicker, but off colored border
//  ::oBkGrd:create(::XbpStatic,,{2,2},{::XbpStatic:currentSize()[1]-4,::XbpStatic:currentSize()[2]-4})
  ::oBkGrd:create(::XbpStatic,,{1,1},{::XbpStatic:currentSize()[1]-2,::XbpStatic:currentSize()[2]-2})
  IF ::oBkGrd:setParent():setcolorBG() != NIL
     ::oBkGrd:setColorBG(::oBkGrd:setParent():setcolorBG())
  ENDIF

  ::oStatic := xbpstatic():New( )
  ::oStatic:Type := ::type
  ::oStatic:Caption := ::Caption
  if ::type == XBPSTATIC_TYPE_TEXT
//    IF ! EMPTY(::font)
//       ::oStatic:setFontCompoundName(::font)
//    ENDIF
    IF VALTYPE(::caption) $ "CM"
       IF AT(CHR(10),::caption) == 0
         ::oStatic:Options := XBPSTATIC_TEXT_CENTER + XBPSTATIC_TEXT_VCENTER
       ELSE
         ::oStatic:Options := XBPSTATIC_TEXT_CENTER + XBPSTATIC_TEXT_WORDBREAK
       ENDIF
    ENDIF
  endif
  ::oStatic:Motion := {|aPos,u,oS| ::Focus( {aPos[1]-2,aPos[2]-2 }) }
  IF ::side
    ::oStatic:Create( ::oBkGrd, , { ::ImageSize[1] + 10, IF(::ImageSize[2] > aTextSize[2],((::Size[2]-aTextSize[2])/2),IF(::Size[2] > aTextSize[2],((::Size[2]-aTextSize[2])/2),2)) }, aTextSize)
  ELSE
    IF EMPTY(::image)  // se non c'Š immagine centra testo verticalmente
       ::oStatic:Create( ::oBkGrd, , {0, 0}, ::oBkGrd:currentSize())
    ELSE
       ::oStatic:Create( ::oBkGrd, , { ((::Size[1]-aTextSize[1])/2), 2 }, aTextSize)
    ENDIF
  ENDIF
  if ::type == XBPSTATIC_TYPE_TEXT
    IF ! EMPTY(::font)
       ::oStatic:setFontCompoundName(::font)
    ENDIF
  endif
  IF ::xbpStatic:setColorBG() != NIL
    ::oStatic:setColorBG(::oStatic:setParent():setcolorBG())
  ENDIF
  IF ValType(::oStatic:setParent():setcolorFG()) == "N"
    ::oStatic:setColorFG(::oStatic:setParent():setcolorFG())
  ENDIF
  ::oStatic:configure()

  ::oXbp := XbpStatic():New( ::xbpstatic, , {0,0}, ::Size  )

//  ::xbpstatic:lBdown := {| aPos| IF(::sound != NIL,_PlaySound(::sound),NIL),::activate( aPos,.f.)  }
//  ::xbpstatic:lBUp := {| aPos| ::activate( aPos,.t.)  }
//  ::xbpstatic:keyboard:= {|n| IIF(n==xbeK_SPACE, (IF(::sound != NIL,_PlaySound(::sound),NIL), ::activate({0, 0}, .F.), sleep(10), ::activate({0, 0}, .T.)), NIL)  }
  ::button := .f.
  If !Empty(::Image)   // If ::Image <> 0
    IF ::side
      aLoc := {5, 0}
      IF ::ImageSize[2] > aTextSize[2]
         IF ::Size[2] > ::ImageSize[1] 
            aLoc[2] := (::Size[2]-::ImageSize[2])/2
         ELSE
            aLoc[2] := 2
         ENDIF
      ELSE
         aLoc[2] := (::Size[2]-::ImageSize[2])/2
      ENDIF

      IF aLoc[1] + ::ImageSize[1] > ::Size[1]
         aLoc[1] := MAX(0, ::Size[1] - ::ImageSize[1])
      ENDIF
      IF aLoc[2] + ::ImageSize[2] > ::Size[2]
         aLoc[2] := MAX(0, ::Size[2] - ::ImageSize[2])
      ENDIF
      ::oImage := xbpstatic():New( ::oBkGrd, , aLoc, ::ImageSize )
    ELSE
      //aLoc:={ ((::Size[1]-::ImageSize[1])/2) , 0 }
      aLoc:={ ((::oBkGrd:currentSize()[1]-::ImageSize[1])/2) , 0 }
      IF EMPTY(::caption)
         //aLoc[2] := ((::Size[2]-::ImageSize[2])/2) // centrato verticalmente
         aLoc[2] := ((::oBkGrd:currentSize()[2]-::ImageSize[2])/2) // centrato verticalmente
      ELSE
         aLoc[2] := aTextSize[2] + 2
      ENDIF
      ::oImage := xbpstatic():New( ::oBkGrd, , aLoc, ::ImageSize )
    ENDIF
    IF VALTYPE(::Image) == "C"
      ::oImage:Type := XBPSTATIC_TYPE_RECESSEDBOX
      ::oImage:paint := {||oBitmap:draw(oPS)}
    ELSE
      ::oImage:Type := ::Imagetype
      ::oImage:Caption := ::Image
    ENDIF
    ::oImage:Motion := {|aPos,u,oS|  ::Focus(  { aPos[1] - ( ( (::Size[1] - ::ImageSize[1])/2 ) )  ,  aPos[2]-( aTextSize[2] +2) } )   }
    ::oImage:Create()
    IF VALTYPE(::Image) == "C"
      oBitmap := BitmapRef():new( ::oImage,, {0,0}, ::oImage:CurrentSize() )
      oBitmap:backcolor := ::oStatic:setParent():setcolorBG()
      oBitmap:create()
      IF VALTYPE(::Image) == "C"
         oBitmap:loadfile(::Image)
      ELSE
         oBitmap:load(NIL, ::Image)
      ENDIF
      oBitmap:draw(oPS)
    ENDIF
  Endif
Return self

Method S2ButtonX:setFontCompoundName(cFont)
  IF cFont != NIL
    ::font := cFont
    ::configure()
  ENDIF
RETURN ::font

Method S2ButtonX:setCaption(cCaption)
   ::caption := cCaption
   ::oStatic:setCaption(cCaption)
   IF ::autoSize
      ::configure()
   ENDIF
RETURN .T.

Method S2ButtonX:configure()
   IF ::Status() == XBP_STAT_CREATE
      ::destroy()
      ::create()
      IF ::button
         ::press(.F.)
      ENDIF
   ENDIF
RETURN self

METHOD S2ButtonX:setSize(aSize, lUpdate)
   LOCAL aSz
   LOCAL lRet

   DEFAULT lUpdate TO .T.
   ::size := ACLONE(aSize)
   lRet := ::XbpStatic:setSize(aSize, lUpdate)
   ::configure()
RETURN lRet

METHOD S2ButtonX:setPosAndSize(aPos, aSize, lUpdate)
   LOCAL lRet1,lRet2
   DEFAULT lUpdate TO .T.

   lRet1 := ::SetPos(aPos, .F.)
   lRet2 := ::SetSize(aSize, .F.)

   IF lUpdate
      ::invalidateRect()
   ENDIF
RETURN lRet1 .AND. lRet2


Method S2ButtonX:setColorBG(nColor)
  IF nColor != NIL
    ::XbpStatic:setColorBG(nColor)
    ::oBkGrd:setColorBG(nColor)
    ::oStatic:setColorBG(nColor)
  ENDIF
RETURN ::XbpStatic:setColorBG()

Method S2ButtonX:paintFocus(obj)
  LOCAL aSz, oP, aAttr
  LOCAL n
  If obj <> nil .and. obj:status() <> XBP_STAT_INIT .AND. obj:hasInputFocus()
    aSz := obj:currentSize()
    aSz[1] -= 4
    aSz[2] -= 4
    oP := obj:LockPs()
    // disegno un rettangolo con pixel vicini
//    aAttr := Array( GRA_AL_COUNT )      // array for line 
//    aAttr[ GRA_AL_TYPE ] := GRA_LINETYPE_ALTERNATE
//    graSetAttrLine( oP, aAttr )     // set attributes 
//    GraBox(oP, {2, 2}, aSz)
    FOR n := 3 TO aSz[1] STEP 2
       GraLine(oP, {n, 3}, {n, 3})
    NEXT

    FOR n := 3 TO aSz[1] STEP 2
       GraLine(oP, {n, aSz[2]}, {n, aSz[2]})
    NEXT

    FOR n := 3 TO aSz[2] STEP 2
       GraLine(oP, {3, n}, {3, n})
    NEXT

    FOR n := 3 TO aSz[2] STEP 2
       GraLine(oP, {aSz[1], n}, {aSz[1], n})
    NEXT
    obj:unlockps( oP )
  endif
return self

Method S2ButtonX:Focus( aPos )
  If ::xbpstatic <> nil .and. ::XbpStatic:Status() <> XBP_STAT_INIT
    if ! ::lFocus .and. aPos[1] >=0 .and. aPos[2] >=0 .and. aPos[1]<= ::Size[1] .and. aPos[2]<= ::Size[2]  .and. ::enabled
      ::focusOn()
    ElseIf !( aPos[1] >=0 .and. aPos[2] >=0 .and. aPos[1]<= ::Size[1] .and. aPos[2]<= ::Size[2] ) 
      IF ::button
         ::xbpStatic:CaptureMouse( .f. )
         ::lFocus := .f.
      ELSE
         ::focusOff()
      ENDIF
    Endif
  Endif
return nil

Method S2ButtonX:focusOn()
  LOCAL oPS, aAttr
  If ::xbpstatic <> nil .and. ::XbpStatic:Status() <> XBP_STAT_INIT
    if ! ::lFocus .AND. ::enabled .and. ! ::button
      ::oXbp:Type := ::OnFocusStyle //XBPSTATIC_TYPE_RAISEDRECT
      ::oXbp:Motion := {|aPos,u,oS| ::Focus( aPos ), ::xbpStatic:CaptureMouse( .t. ) }
      IF ::oXbp:status() == XBP_STAT_CREATE
         ::oXbp:configure()
      ELSE
         ::oXbp:Create()
      ENDIF
      ::lFocus := .t.
      ::xbpStatic:CaptureMouse( .t. )
      IF ::aPrevFocusColor == NIL
         ::aPrevFocusColor := {NIL, NIL}

         if ::oStatic:type == XBPSTATIC_TYPE_TEXT .AND. ::focusColorFG != NIL
            ::aPrevFocusColor[1] := ::oStatic:setColorFG()
            ::oStatic:SetColorFG( ::focusColorFG )
         Endif

         IF ::focusColorBG != NIL
            ::aPrevFocusColor[2] := ::setColorBG()
            ::SetColorBG(::focusColorBG)
         ENDIF
         IF ::focusColorBorder != NIL
            Sleep(1)
            aAttr := ARRAY(GRA_AL_COUNT)
            oPS := ::oXbp:LockPs()
            aAttr[GRA_AL_COLOR] := ::focusColorBorder
            oPS:SetAttrLine(aAttr)
            GraBox(oPS, {0, 0}, {::oXbp:CurrentSize()[1] - 1, ::oXbp:CurrentSize()[2] - 1}, GRA_OUTLINE)
            ::oXbp:UnLockPs(oPS)
         ENDIF
       ENDIF
    endif
  Endif
RETURN self

Method S2ButtonX:focusOff()
   If ::xbpstatic <> nil .and. ::XbpStatic:Status() <> XBP_STAT_INIT
      If ::oXbp <> nil .and. ::oXbp:Status() <> XBP_STAT_INIT //::lFocus   .and. 
         ::oXbp:Destroy()
         ::lFocus := .f.
         ::xbpStatic:CaptureMouse( .f. )
         IF ::aPrevFocusColor != NIL
            if ::oStatic:type == XBPSTATIC_TYPE_TEXT  .and. ::enabled
               IF ::aPrevFocusColor[1] != NIL
                  ::oStatic:SetColorFG(::aPrevFocusColor[1])
               ELSE
                  IF ValType(::oStatic:setParent():setColorFG()) == "N"
                     ::oStatic:SetColorFG( ::oStatic:setParent():setColorFG() )
                  ELSE
                     ::oStatic:SetColorFG(GRA_CLR_BLACK)
                  ENDIF
               ENDIF
           Endif
           IF ::aPrevFocusColor[2] != NIL
              ::SetColorBG(::aPrevFocusColor[2]) 
           ENDIF
           ::aPrevFocusColor := NIL
         ENDIF
      Endif
   Endif
RETURN self

Method S2ButtonX:isenabled()
RETURN ::enabled

Method S2ButtonX:Activate( aPos, lUp )
  LOCAL aMotion
  If ::xbpstatic <> nil .and. ::XbpStatic:Status() <> XBP_STAT_INIT  .and. ::Enabled .AND. ::xbpStatic:isEnabled()
    If lUp
      //If ::lFocus .AND. ::UpOnClick
      If ::UpOnClick
        ::press( .T. )
        ::focusOff()
      endif
//      if ::UpOnclick
//         ::button := .f.
//      endif
      if aPos[1] >=0 .and. aPos[2] >=0 .and. aPos[1]<= ::Size[1] .and. aPos[2]<= ::Size[2]
        ::xbpStatic:CaptureMouse( .f. )
        aMotion := {::XbpStatic:motion, ::oBkGrd:Motion, ::oStatic:motion, IIF(::oImage == NIL, NIL, ::oImage:motion), IIF(::oXbp== NIL, NIL, ::oXbp:motion)}
        ::XbpStatic:motion := NIL
        ::oBkGrd:motion  := NIL
        ::oStatic:motion := NIL
        IF aMotion[4] != NIL
          ::oImage:motion  := NIL
        ENDIF
        IF aMotion[5] != NIL
          ::oXbp:motion  := NIL
        ENDIF

        // disegna pulsante con FOCUS
        IF ::tabStop
           SetAppFocus(self)
          //::paintFocus()
        ENDIF

        eval( ::Activate, , , self )

        ::XbpStatic:motion := aMotion[1]
        ::oBkGrd:motion  := aMotion[2]
        ::oStatic:motion := aMotion[3]

        // se ripristino questo codeblock ho dei brutti refresh
        // su pushbutton con immagine (dopo il click)
        IF aMotion[4] != NIL
//          ::oImage:motion  := aMotion[4]
        ENDIF
        IF aMotion[5] != NIL
          ::oXbp:motion  := aMotion[5]
        ENDIF

        If ::lFocus .and. ::enabled //could have been turned off
          ::xbpStatic:CaptureMouse( .t. )
        Endif
//        IF ::tabStop
//           SetAppFocus(self)
//        ENDIF
        ::invalidateRect()
      endif
    Else //if ::lFocus .OR. ::hasInputFocus() //::button == NIL //If
      ::press( .F. )
    Endif
  Endif
Return nil

method S2ButtonX:press( lUp )
   IF lUp
      ::Button := .F.  
      IF ::lFocus
         ::oXbp:Type := XBPSTATIC_TYPE_RAISEDRECT
         ::oXbp:Configure()
      ELSE
         ::focusOff()   
      ENDIF
      if ::aPrevTextPos != NIL
         ::aPrevTextPos[1]:setPos(::aPrevTextPos[2])
         ::aPrevTextPos := NIL
         ::invalidateRect()
      endif
   ELSE

      ::Button := .T. 

      ::oXbp:Type :=  XBPSTATIC_TYPE_RECESSEDRECT
//      ::oXbp:Type :=  XBPSTATIC_TYPE_FGNDFRAME
//      ::oXbp:options := XBPSTATIC_FRAMETHICK 
      IF ::oXbp:status() == XBP_STAT_CREATE
         ::oXbp:Configure()
      ELSE
         ::oXbp:Create()
      ENDIF
      if ::aPrevTextPos == NIL
         IF EMPTY(::oStatic:caption) .AND. ! EMPTY(::oimage)
            ::aPrevTextPos := {::oImage, ::oImage:currentPos()}
         ELSE
            ::aPrevTextPos := {::oStatic, ::oStatic:currentPos()}
         ENDIF
         ::aPrevTextPos[1]:setPos({::aPrevTextPos[2][1]+1, ::aPrevTextPos[2][2]-1})
         ::invalidateRect()
      endif
   ENDIF
return self

method S2ButtonX:Disable()
  if ::nPrevColorFG == NIL
     ::nPrevColorFG := ::oStatic:SetColorFG()
     DEFAULT ::nPrevColorFG TO GRA_CLR_BLACK
  endif
  IF ::DisabledColorBG != NIL
     if ::nPrevColorBG == NIL
        ::nPrevColorBG := ::SetColorBG()
     endif
     ::SetColorBG( ::DisabledColorBG )
  ENDIF
  if ::oStatic:type <> XBPSTATIC_TYPE_TEXT
    IF ::lInvertImageOnDisable
       ::oStatic:Paint := {|x,y,obj| ::invert(obj) }
       ::oStatic:invalidaterect()
    ENDIF
  Else
    ::oStatic:SetColorFG( ::disabledColorFG )
  Endif
  if !EMPTY(::Image) //::Image <> 0
    IF ::lInvertImageOnDisable 
       ::oImage:Paint := {|x,y,obj| ::invert(obj)  }
       ::oImage:invalidateRect()
    ENDIF
  Endif
  ::enabled := .f.
  ::button := .F.
  ::xbpStatic:CaptureMouse( .f. )
  ::XbpStatic:disable()

  ::tofront() 
  ::invalidateRect() 

  ////////////////////////////////////////
  //Mantis 1637. Luca 5/11/2007 
  //::Show()
  ////////////////////////////////////////

return  .t.

Method S2ButtonX:Enable()
  if ::nPrevColorBG != NIL 
     ::SetColorBG( ::nPrevColorBG )
     ::nPrevColorBG := NIL
  endif
  If ::oStatic:type == XBPSTATIC_TYPE_TEXT
    IF ::nPrevColorFG != NIL //::oStatic:setParent():setColorFG() != NIL
       ::oStatic:SetColorFG( ::nPrevColorFG ) //::oStatic:setParent():setColorFG() )
       //::nPrevColorFG := NIL
    ENDIF
  endif
  ::oStatic:Paint := {|| nil }
  ::oStatic:invalidaterect()
  if !EMPTY(::Image) //::Image <> 0
    ::oImage:paint := {|| nil }
    ::oImage:invalidateRect()
  Endif
  ::enabled := .t.
  ::XbpStatic:enable()

  ::tofront() 
  ::invalidateRect() 

  ////////////////////////////////////////
  //Mantis 1637. Luca 5/11/2007 
  //::Show()
  ////////////////////////////////////////

Return  .t.

Method S2ButtonX:invert(obj)
  Local oP
  If obj <> nil .and. obj:status() <> XBP_STAT_INIT
    oP := obj:LockPs()
    GraBitBlt( oP, oP,{0,0,31,31},{0,0,31,31}, GRA_BLT_ROP_DSTINVERT  )
    obj:unlockps( oP )
  endif
Return nil

method S2ButtonX:handleEvent(nEvent, mp1, mp2)
//  ::xbpstatic:lBdown := {| aPos| IF(::sound != NIL,_PlaySound(::sound),NIL),::activate( aPos,.f.)  }
//  ::xbpstatic:lBUp := {| aPos| ::activate( aPos,.t.)  }
//  ::xbpstatic:keyboard:= {|n| IIF(n==xbeK_SPACE, (IF(::sound != NIL,_PlaySound(::sound),NIL), ::activate({0, 0}, .F.), sleep(10), ::activate({0, 0}, .T.)), NIL)  }
   DO CASE
      CASE (nEvent == xbeP_Keyboard .AND. mp1 == xbeK_SPACE)
         PostAppEvent(xbeP_Activate, NIL, NIL, self) //::activate(mp1, .T.)

      CASE nEvent == xbeP_Activate  //.OR. (nEvent == xbeP_Keyboard .AND. mp1 == xbeK_SPACE)
         IF ! ::button 
            IF ::sound != NIL
              _PlaySound(::sound)
            ENDIF
            ::activate({0, 0}, .F.)
            sleep(10)
         ENDIF
         ::activate({0, 0}, .T.)

      CASE nEvent == xbeM_LbDown
         IF ! ::button
            IF ::sound != NIL
              _PlaySound(::sound)
            ENDIF
            ::activate(mp1, .F.)
         ENDIF

      CASE nEvent == xbeM_LbUp
         PostAppEvent(xbeP_Activate, NIL, NIL, self) //::activate(mp1, .T.)

      OTHERWISE
         ::XbpStatic:handleEvent(nEvent, mp1, mp2)
   ENDCASE
return self

//-----------------------------------------------------------------------------

STATIC FUNCTION _TextSize(cText,oXbp,cFont)
  LOCAL oPS, oFont, aPoints := {}
  oPS := oXbp:lockPS()

  DEFAULT cFont TO oXbp:setFontCompoundName()
  IF ! EMPTY(cFont)
     oFont := XbpFont():new(oPS)
     oFont:create(cFont)
     GraSetFont(oPS,oFont)
  ENDIF
  aPoints := GraQueryTextBox(oPS,cText)
  oXbp:unlockPS()
RETURN {aPoints[3,1]-aPoints[1,1]+4,aPoints[1,2]-aPoints[2,2]+2}


//-----------------------------------------------------------------------------
/*
STATIC FUNCTION CR(nTimes)
  LOCAL cCR := "" , I := 0
  IF nTimes == NIL
    nTimes := 1
  ENDIF
  FOR I := 1 TO nTimes
    cCR += CHR(13) + CHR(10)
  NEXT
RETURN cCR
*/
//-----------------------------------------------------------------------------

STATIC PROCEDURE _PlaySound(cFileName)
RETURN 
/*
    S2WaveStopSound()
    S2WavePlayFile(cFileName)
RETURN


#define SND_SYNC 0
#define SND_ASYNC 1
#define SND_FILENAME 131072
#define SND_PURGE 64

PROCEDURE _StopSound()
  DllCall("WINMM.DLL",DLL_STDCALL,"PlaySoundA",0,0,0)
  DllCall("WINMM.DLL",DLL_STDCALL,"PlaySoundA",0,0,SND_PURGE)
RETURN

PROCEDURE _PlayWaveFile(cFileName)
  DllCall("WINMM.DLL",DLL_STDCALL,"PlaySoundA",cFileName,0,SND_FILENAME+SND_ASYNC)
RETURN

DLLFUNCTION MessageBeep(nMsgType) USING STDCALL FROM "USER32.DLL"

DLLFUNCTION waveOutGetNumDevs() USING STDCALL FROM "WINMM.DLL"
*/

//-----------------------------------------------------------------------------

/*
 * Class for managing database fields which store bitmap data
 */
CLASS BitmapRef FROM XbpStatic, DataRef
   PROTECTED:
   VAR oBmp
   VAR oPS
   VAR lIsEmpty

   EXPORTED:
   VAR autoScale
   VAR Scaled
   VAR backcolor
   METHOD init, create, destroy
   METHOD setdata, getdata, editbuffer, draw, loadFile, load
   METHOD Save
//   METHOD update
ENDCLASS



/*
 * Initialize the object
 */
METHOD BitmapRef:init( oParent, oOwner, aPos, aSize, aPresParem, lVisible )
   ::dataRef:init()
   ::xbpStatic:init( oParent, oOwner, aPos, aSize, aPresParem, lVisible )
   ::autoScale := .T.
   ::lIsEmpty  := .T.
   ::oPS       := XbpPresSpace():new()
   ::oBmp      := S2XbpBitmap():new()
   ::backcolor := GRA_CLR_BACKGROUND
RETURN self



/*
 * Request system resources and define color for displaying
 * an empty database field
 */
METHOD BitmapRef:create( oParent, oOwner, aPos, aSize, aPresParem, lVisible )
   LOCAL aAttr[ GRA_AA_COUNT ]
   ::xbpStatic:create( oParent, oOwner, aPos, aSize, aPresParem, lVisible )
   IF ::backcolor != NIL
      ::xbpStatic:setcolorBG(::backcolor)
   ENDIF
   ::oPS:create( ::xbpStatic:winDevice() )
   ::oBmp:create( ::oPS )

//   aAttr[ GRA_AA_COLOR ] := GRA_CLR_WHITE
   aAttr[ GRA_AA_COLOR ] := ::backcolor
   ::oPS:setAttrArea( aAttr )
   ::xbpStatic:paint := {||::draw()}
RETURN self

/*
 * Release system resources
 */
METHOD BitmapRef:destroy
   ::oBmp:destroy()
   ::oPS:destroy()
   ::xbpStatic:destroy()
RETURN self

/*
 * Transfer bitmap data from field into buffer
 */
METHOD BitmapRef:setdata( cBuffer )
   IF cBuffer == NIL
      cBuffer := Eval( ::dataLink )
   ENDIF

   IF ! Empty( cBuffer )
      ::oBmp:setBuffer( cBuffer, XBPBMP_FORMAT_WIN3X )
      ::lIsEmpty := .F.
   ELSE
      ::lIsEmpty := .T.
   ENDIF
   ::changed :=  .F.
   ::draw()
RETURN cBuffer

/*
 * Transfer the bitmap buffer into field
 */
METHOD BitmapRef:getdata
   LOCAL cBuffer := ::oBmp:setBuffer()

   IF Valtype( ::dataLink ) == "B" .AND. .NOT. ::lIsEmpty
      Eval( ::dataLink, cBuffer )
   ENDIF
RETURN cBuffer

METHOD BitmapRef:save(cFileName)
//  ::scaled := GraSaveScreen(::oPS,{0,0},{150,150})
//  SaveBitmap(::oBmp,cFileName)  //This line saves the normal sized image
//  SaveBitmap(::scaled,cFileName)  //This line saves the scaled image
RETURN

METHOD BitmapRef:editbuffer
RETURN ::oBmp:setBuffer()


/*
 * Draw the bitmap and maintain the aspect ratio
 */
METHOD BitmapRef:draw
   LOCAL aSize    := ::currentSize()
   LOCAL aTarget, aSource, nAspect

   GraBox( ::oPS, {1,1}, {aSize[1]-2,aSize[2]-2}, GRA_FILL )

   IF ::lIsEmpty
      RETURN .F.
   ENDIF

   aSource := {0,0,::oBmp:xSize,::oBmp:ySize}
   aTarget := {1,1,aSize[1]-2,aSize[2]-2}

   IF ::autoScale
      nAspect    := aSource[3] / aSource[4]
      IF nAspect > 1
         aTarget[4] := aTarget[3] / nAspect
      ELSE
         aTarget[3] := aTarget[4] * nAspect
      ENDIF
   ELSE
      aTarget[3] := aSource[3]
      aTarget[4] := aSource[4]
   ENDIF

   IF aTarget[3] < aSize[1]-2
      nAspect := ( aSize[1]-2-aTarget[3] ) / 2
      aTarget[1] += nAspect
      aTarget[3] += nAspect
   ENDIF

   IF aTarget[4] < aSize[2]-2
      nAspect := ( aSize[2]-2-aTarget[4] ) / 2
      aTarget[2] += nAspect
      aTarget[4] += nAspect
   ENDIF

RETURN ::oBmp:draw( ::oPS, aTarget, aSource, , GRA_BLT_BBO_IGNORE )

/*
 * Load an external bitmap file
 */
METHOD BitmapRef:loadFile( cBitmap )
   IF ( ::changed := ::oBmp:loadFile( cBitmap ) )
      ::lIsEmpty := .F.
   ENDIF
RETURN ::changed

METHOD BitmapRef:load( cDll, nID, cType)
   IF ( ::changed := ::oBmp:load( cDll, nID, cType) )
      ::lIsEmpty := .F.
   ENDIF
RETURN ::changed


//-----------------------------------------------------------------------------
/*
FUNCTION SaveBitmap( oXbpBitmap, cFileName )
   LOCAL cBitmap, cHeader, nHandle, nBytes, lOk := .F.

   IF Valtype( oXbpBitMap ) + Valtype( cFileName ) != "OC"
      RETURN .F.                       // Illegal parameters
   ENDIF                               // ** RETURN **

   IF ! "." $ cFileName
      cFileName += ".BMP"
   ENDIF

   nHandle := FCreate( cFileName )
   IF FError() <> 0
      RETURN .F.                       // Error creating file
   ENDIF                               // ** RETURN **

   cBitmap := oXbpBitmap:setBuffer( , XBPBMP_FORMAT_DEFAULT )

   // bitmap info header has 40 bytes
   cBitmap := U2Bin( 40 ) + SubStr( cBitmap, 5 )

   // Create 14 byte bitmap header
   //  1- 2  2 Byte -> "BM"
   //  3- 6  4 Byte -> File size
   //  7- 8  2 Byte -> Chr(0)
   //  9-10  2 Byte -> Chr(0)
   // 11-14  4 Byte -> Offset image data
   cHeader := "BM" + ;
               U2Bin( 14 + Len(cBitmap) ) + ;
               U2Bin( 0 ) + ;
               U2Bin( oXbpBitmap:bufferOffset + 14)

   nBytes  := Len( cHeader ) + Len( cBitmap )
   lOk     := (nBytes == FWrite( nHandle, cHeader + cBitmap, nBytes ))

   FClose( nHandle )

RETURN lOk

//-----------------------------------------------------------------------------

FUNCTION GraSaveScreen( oSourcePS, aPos, aSize )
  LOCAL oBitmap   := XbpBitmap():new():create( oSourcePS )
  LOCAL oTargetPS := XbpPresSpace():new():create()
  LOCAL aSourceRect[4], aTargetRect

  aSourceRect[1] := aSourceRect[3] := aPos[1]
  aSourceRect[2] := aSourceRect[4] := aPos[2]
  aSourceRect[3] += aSize[1]
  aSourceRect[4] += aSize[2]
  aTargetRect    := {0, 0, aSize[1], aSize[2]}

  oBitmap:presSpace( oTargetPS )
  oBitmap:make( aSize[1], aSize[2] )

  GraBitBlt( oTargetPS, oSourcePS, aTargetRect, aSourceRect )
RETURN oBitmap

// The function GraRestScreen() redisplays a saved
// section of screen. It just uses the :draw() method

FUNCTION GraRestScreen( oTargetPS, aPos, oBitmap )
  oBitmap:draw( oTargetPS, aPos )
RETURN NIL

*/