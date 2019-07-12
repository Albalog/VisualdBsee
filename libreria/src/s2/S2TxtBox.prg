// Function/Procedure Prototype Table  -  Last Update: 07/10/98 @ 12.24.42
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
// Return Value         Function/Arguments
// 컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// RETURN self          METHOD S2TextBox:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
// Void                 METHOD S2TextBox:GetText()
// self                 METHOD S2TextBox:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
// NIL                  METHOD S2TextBox:SetText( cText )

#include "dfWin.ch"
#include "dfMenu.ch"
#include "dfCtrl.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Appevent.ch"
#include "dfXBase.ch"
#include "dfXRes.ch"
#include "font.ch"

// --------------------------------------------
// CLASSE S2TextBox: testo con un frame intorno
// --------------------------------------------
CLASS S2TextBox FROM XbpMle

   EXPORTED:
      VAR TextArea, Text
      METHOD Init, Create, SetText, GetText //, Destroy

ENDCLASS

METHOD S2TextBox:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::XbpMle:Init(oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::editable := .F.
   ::ignoreTab := .T.

   ::horizScroll := .F.
   ::vertScroll := .F.
   ::text := ""
   ::wordWrap := .T.
   ::dataLink := {|x| IIF(x==NIL, ::text, ::text:=x) }

   // ::type := XBPSTATIC_TYPE_GROUPBOX

   // ::TextArea := XbpStatic():new(self, NIL, {3,3})
   // ::TextArea:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_LEFT

RETURN self

METHOD S2TextBox:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::XbpMle:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   // aSize := ::currentSize()
   //aSize[1] -= 6
   //aSize[2] -= 12
   // ::TextArea:SetColorBG(GRA_CLR_DARKGRAY)
   //::TextArea:Create(NIL, NIL, NIL, aSize)
RETURN self

// METHOD S2TextBox:Destroy()
//    //::TextArea:Destroy()
//    ::XbpMle:Destroy()
// RETURN self

METHOD S2TextBox:SetText( cText )
   LOCAL lMustHaveVScroll

   DEFAULT cText TO ""

   ::SetData( cText )

   lMustHaveVScroll := ::lineFromChar(LEN(cText)) > 1

   IF lMustHaveVScroll != ::vertScroll
      ::vertScroll := lMustHaveVScroll

      // Simone 20/giu/03 GERR 3828
      IF ::Status() == XBP_STAT_CREATE
         ::configure()
      ELSE
         ::create()
      ENDIF

      ::SetData(cText)
      ::setFirstChar(1)
   ENDIF
RETURN NIL

METHOD S2TextBox:GetText()
RETURN ::getData()


