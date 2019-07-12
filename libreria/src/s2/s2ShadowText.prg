/*    SHADOWTEXT Class
      Ver 1.1
      BY : James W. Loughner
           Made TO Order Software
      Derived from functions developed by
         Richard Hankins
         Head of Programming
         Auction Services, Inc.
      to display a shadow effect

      Displays text with Shadow effect

      USAGE: Call as you would any XbpStatic Class
             See Main-below for examples
      SPECIAL: If you don't include a size array
               the Static will auotsize to fit the
               Caption text.
               Text is allways centered in the static
               Also 'type' 'Options' have no meaning
               and should be left default.
      IVARS:
      :Rotation       - Rotation to print text 0-90
                     Note you can specify greater then 90
                     but I'm not sure all will work correctly
                     Also have not tested negitive Rotations
      :TextColor   - Color to render text
                     Note: SetColorFG should not be used!
                     Also the default is for the SeetColorBG
                     is Transparent. This can be chaged but the
                     shadow color is calculated from the color
                     of the parent.
      :ShadowDepth - number of pixels down and to the right the
                     shadow is displaced. Default is 3
                     Note: entering a negitive value will cause
                     the shadow to be up to the right.

Ver 1.1 - small adjustment for ActiveText class
*/

#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "Appbrow.ch"
#include "Dmlb.ch"
#include "dll.ch"
#include "inkey.ch"
#include "dfctrl.ch"

CLASS S2ShadowText FROM S2StaticX
PROTECTED:
   VAR IsAuto

   INLINE METHOD useStdStatic()
      LOCAL lRet := .F.
      IF (::Rotation == 0       .AND. ;
          ::ShadowDepth == 0 ) .OR. ;
         ! VALTYPE(::caption) $ "CM" .OR. ;
         ::type != XBPSTATIC_TYPE_TEXT
     
         lRet := .T.
      ENDIF
   RETURN lRet

EXPORTED:

   VAR caption
   VAR Rotation
   //VAR TextColor
   VAR ShadowDepth
   VAR nPaintStyle

   METHOD Init
   METHOD Create
   METHOD Paint
   METHOD setCaption

   METHOD setShadowDepth
   METHOD setRotation
ENDCLASS

METHOD S2ShadowText:Init(oParent,oOwner,aPos,aSize,aAttr,lVisible)
   ::S2StaticX:Init(oParent,oOwner,aPos,aSize,aAttr,lVisible)
   ::Rotation := 0
   ::ShadowDepth := 0
   //::TextColor := GraMakeRGBColor({0,0,0}) // default black
   ::IsAuto := .F.
   ::caption := NIL
   ::nPaintStyle := PS_STD
RETURN Self

METHOD S2ShadowText:create(oParent,oOwner,aPos,aSize,aAttr,lVisible)
   IF ::caption != NIL
      ::setCaption( ::caption )
   ENDIF
   ::S2StaticX:Create(oParent,oOwner,aPos,aSize,aAttr,lVisible)
RETURN self

METHOD S2ShadowText:setCaption(x)
   ::caption := x
   IF ::useStdStatic()
      ::S2StaticX:setCaption(x)
   ELSE
      ::S2StaticX:setCaption("")
      ::invalidateRect()
   ENDIF
RETURN self

METHOD S2ShadowText:Paint(aRect)
  LOCAL oPS, oFont,aPoints, aSize
  LOCAL aAttr, aRotation, nX, nY, oPP, aPC := {}, nBClr

  IF ::nPaintStyle != PS_STD
     oPS := ::lockPS()

     // disegna un box
     dfPSPaintBorder(oPS, NIL, ::currentSize(), ::nPaintStyle, NIL, ::setColorFG(), NIL, NIL )
  ENDIF

  IF ::useStdStatic() .OR. ::IsAuto
     IF oPS != NIL
        ::unlockPS( oPS )
     ENDIF
     ::S2StaticX:paint(aRect)
     RETURN self
  ENDIF

  IF oPS == NIL
     oPS := ::lockPS()
  ENDIF

  oPP := ::SetParent():SetColorBG()
  aPC := GraGetRGBIntensity(oPP)
  IF ! EMPTY(aPC)
     oPP := dfRGBToHSB(aPC)
     oPP[3] -= 20
     aPC := dfHSBToRGB(oPP)
     nBClr := GraMakeRGBColor({Int(aPC[1]),Int(aPC[2]),Int(aPC[3])})
  ENDIF

  aRotation := {100*dfCos(dfDtoR(::Rotation)),100* dfSin(dfDtoR(::Rotation))}

  aAttr := ARRAY( GRA_AS_COUNT )   // set various attributes

  //** the drop shadow
  aAttr[ GRA_AS_COLOR     ] := nBClr
  aAttr[ GRA_AS_ANGLE     ] := aRotation

  GraSetAttrString( oPS, aAttr )

  //** Size static
  aPoints := GraQueryTextBox(oPS,::Caption)
  IF ::AutoSize
     ::IsAuto := .T. // prevent infinit loops
     nX := MAX(MAX(ABS(aPoints[1,1]),ABS(aPoints[2,1])),MAX(ABS(aPoints[3,1]),ABS(aPoints[4,1])))+ABS(::ShadowDepth)+5
     nY := MAX(MAX(ABS(aPoints[3,2]),ABS(aPoints[4,2])+ABS(aPoints[1,2])),MAX(ABS(aPoints[1,2]),ABS(aPoints[2,2])))+ABS(::ShadowDepth)+5
     IF nX != ::CurrentSize()[1] .OR. nY != ::CurrentSize()[2]
        ::SetSize({nX,nY})
     ENDIF
     ::IsAuto := .F.
  ENDIF

  aSize := ::currentSize()
/*
  // simone 11/4/05
  // controlla allineamento, disabilitato perche da problemi se :rotation <> 0..
  // es. se rotation=180 e align =top/left, allora non si vede il testo perchä ä  totalmente a sinistra
  IF dfAnd(::options, XBPSTATIC_TEXT_RIGHT) != 0
     nX := (aSize[1]-MAX(MAX(aPoints[1,1],aPoints[2,1]),MAX(aPoints[3,1],aPoints[4,1]))-::ShadowDepth-5+ABS(aPoints[1,1]-aPoints[2,1]))
  ELSEIF dfAnd(::options, XBPSTATIC_TEXT_CENTER) != 0
     nX := (aSize[1]-MAX(MAX(aPoints[1,1],aPoints[2,1]),MAX(aPoints[3,1],aPoints[4,1]))-::ShadowDepth-5+ABS(aPoints[1,1]-aPoints[2,1]))/2
  ELSE
     nX := 0 // DEFAULT = LEFT
  ENDIF

  IF dfAnd(::options, XBPSTATIC_TEXT_BOTTOM) != 0
     nY  := ::shadowDepth
  ELSEIF dfAnd(::options, XBPSTATIC_TEXT_VCENTER) != 0
     // CENTRATO VERT.
     nY := (aSize[2]-MAX(MAX(aPoints[3,2],aPoints[4,2]),MAX(aPoints[1,2],aPoints[2,2]))+::ShadowDepth+5)/2
  ELSE
     // DEFAULT=TOP
     nY := (aSize[2]-MAX(MAX(aPoints[3,2],aPoints[4,2]),MAX(aPoints[1,2],aPoints[2,2]))+::ShadowDepth+5)
  ENDIF
*/

  //** Find center offset
  //** Find center offset
  nX := (aSize[1]-MAX(MAX(aPoints[1,1],aPoints[2,1]),MAX(aPoints[3,1],aPoints[4,1]))-::ShadowDepth-5+ABS(aPoints[1,1]-aPoints[2,1]))/2
  nY := (aSize[2]-MAX(MAX(aPoints[3,2],aPoints[4,2]),MAX(aPoints[1,2],aPoints[2,2]))+::ShadowDepth+5)/2
  IF ::Rotation < 0
     nX := (aSize[1] -ABS(aPoints[3,1])-ABS(::ShadowDepth)-5+ABS(aPoints[1,1]-aPoints[2,1]))/2
     nY := (aSize[2] +MAX(ABS(aPoints[3,2])+ABS(aPoints[1,2]),ABS(aPoints[4,2])+ABS(aPoints[2,2]))-ABS(::ShadowDepth)+5)/2
  ENDIF

  IF ::ShadowDepth != 0
     GraStringAt(oPS, {nX+::ShadowDepth,nY-::ShadowDepth}, ::Caption)
  ENDIF   

  //** the normal text
  aAttr[ GRA_AS_COLOR     ] := ::setColorFG()
  DEFAULT aAttr[ GRA_AS_COLOR ] TO GRA_CLR_DEFAULT

  GraSetAttrString( oPS, aAttr )

  GraStringAt(oPS, {nX,nY}, ::Caption)

  ::unlockPS(oPS)
RETURN Self


METHOD S2ShadowText:setShadowDepth(n)
   LOCAL nRet := ::shadowDepth
   IF VALTYPE(n) == "N"
      ::shadowDepth := n
      ::setCaption( ::caption )
      ::invalidateRect()
   ENDIF
RETURN nRet

METHOD S2ShadowText:setRotation(n)
   LOCAL nRet := ::Rotation
   IF VALTYPE(n) == "N"
      ::Rotation := n
      ::setCaption( ::caption )
      ::invalidateRect()
   ENDIF
RETURN nRet
