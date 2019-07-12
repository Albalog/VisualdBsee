#include "Common.ch"
#include "dfXBase.ch"
#include "dfStd.ch"
#include "Xbp.ch"
#include "Gra.ch"

#define ICON_WIDTH   32
#define ICON_HEIGHT  32

// Icona centrata all'interno di un box

CLASS S2Icon FROM XbpStatic

   EXPORTED:
      VAR IconArea
      METHOD Init, Create, SetIcon, GetIcon //, Destroy

ENDCLASS

METHOD S2Icon:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::XbpStatic:Init(oParent, oOwner, aPos, aSize, aPP, lVisible )
   // ::type := XBPSTATIC_TYPE_GROUPBOX
   ::type := XBPSTATIC_TYPE_RECESSEDBOX

   ::IconArea := XbpStatic():new(self, NIL)
   ::IconArea:type    := XBPSTATIC_TYPE_SYSICON

RETURN self

METHOD S2Icon:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL aCoords

   ::XbpStatic:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   aCoords := ::currentSize()
   aCoords[1] := (aCoords[1] - ICON_WIDTH ) / 2
   aCoords[2] := (aCoords[2] - ICON_HEIGHT) / 2

   // ::IconArea:SetColorBG(GRA_CLR_DARKGRAY)
   ::IconArea:Create(NIL, NIL, aCoords, {ICON_WIDTH, ICON_HEIGHT})
RETURN self

// METHOD S2Icon:Destroy()
//    ::IconArea:Destroy()
//    ::XbpStatic:Destroy()
// RETURN self

METHOD S2Icon:SetIcon( cIcon )
RETURN ::IconArea:SetCaption( cIcon )

METHOD S2Icon:GetIcon()
RETURN ::IconArea:caption
