#include "dfCtrl.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "Font.ch"
#include "dfMenu.ch"
#include "dfXBase.ch"
#include "Common.ch"
#include "AppEvent.ch"
#include "dfxres.ch"
#include "dfLook.ch"
// $BEGDOC--------------------------------------------------
//
// Classe per workaround su XbpStatic:setSize()
// Simone 21/5/04 aggiunto settaggio per disabilitare il workaround
//                Perche da problemi nel form designer di Visual Dbsee
//
// $ENDDOC--------------------------------------------------

// Simone 8/4/2005
// mantis 0000648: gestire caratteristiche ombra/raised ecc. su control say/exp/rel
STATIC CLASS FixXbpStatic FROM S2ShadowText
//STATIC CLASS FixXbpStatic FROM XbpStatic
EXPORTED:
   VAR setsize_offset

   EXPORTED:
      INLINE METHOD init(oParent, oOwner, aPos, aSize, aPP, lVisible)
         // Simone 8/4/2005
         // mantis 0000648: gestire caratteristiche ombra/raised ecc. su control say/exp/rel
         ::S2ShadowText:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
         IF dfSet("XbaseS2StaticSizeWorkAround")=="NO"
            ::setsize_offset := 0
         ELSE
            ::setsize_offset := 1
         ENDIF
      RETURN self
       
      METHOD setSize  // WorkAround per setSize,

      // Questo metodo dovrebbe servire per un BUG  ma non funziona
      //
      // Il BUG ä:
      // quando c'ä uno sfondo con BITMAP (colorBG = TRASPARENTE)
      // e cambia il caption le scritte si sovrappongono
      //
      // INLINE METHOD setCaption(x)
      //    LOCAL lOk := .F.
      //    LOCAL nCol := ::setColorBG()
      //
      //    ::setColorBG(GRA_CLR_WHITE)
      //    //::setColorFG(XBPSYSCLR_TRANSPARENT)
      //    ::XbpStatic:setCaption(::caption)
      //
      //    //::hide()
      //    ::setColorBG(XBPSYSCLR_TRANSPARENT)
      //    lOk := ::XbpStatic:setCaption(x)
      //    //::show()
      //    ::setPos(::currentPos(), .T. )
      //
      //
      // RETURN lOk

ENDCLASS

METHOD FixXbpStatic:setSize()  // WorkAround per setSize
   LOCAL aS := PVALUE(1)
   LOCAL lRet

   aS[1] := aS[1]+::setsize_offset

   IF PCOUNT() == 1
      lRet := ::S2ShadowText:setSize(aS)
   ELSE
      lRet := ::S2ShadowText:setSize(aS, PVALUE(2))
   ENDIF
RETURN lRet

// S2Static: CTRL_SAY / CTRL_GROUPBOX
// ----------------------------------
CLASS S2Static FROM FixXbpStatic, S2Control
   PROTECTED:
      VAR aInitSize
      VAR workaround_create

   EXPORTED:
/*
      INLINE METHOD init(oParent, oOwner, aPos, aSize, aPP, lVisible)
         ::FixXbpStatic:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
         IF dfSet("XbaseS2StaticCreateWorkAround") == "NO"
            ::workaround_create:= .F.
         ELSE
            ::workaround_create:= .T.
         ENDIF
      RETURN self
*/
      METHOD Init, DispItm, Create

      INLINE METHOD CanSetFocus(); RETURN .F.
      INLINE METHOD SetFocus(); RETURN .F.
      INLINE METHOD HasFocus(); RETURN .F.

ENDCLASS

METHOD S2Static:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::FixXbpStatic:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   IF dfSet("XbaseS2StaticCreateWorkAround") == "NO"
      ::workaround_create:= .F.
   ELSE
      ::workaround_create:= .T.
   ENDIF
   // simone 7/7/04 abilita workaround se sono in modalitÖ riga/colonna
   IF ! S2PixelCoordinate(aCtrl)
      ::setsize_offset := 1
      ::workaround_create := .T.
   ENDIF
   ::S2Control:Init(aCtrl, nPage, oFormFather )
   ::rbDown := oParent:rbDown
RETURN self

METHOD S2Static:DispItm() // ( cGrp, lRef )
   LOCAL lRet := .F.
   IF ::CanShow()
      ::show()
      lRet := .T.

   ELSE
      ::hide()
   ENDIF
RETURN lRet

METHOD S2Static:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::FixXbpStatic:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )

   //Luca 10/06/2004
   // Tolto perchä non c'ä motivo di fare il resize ...
   IF ::workaround_create .AND. ::type == XBPSTATIC_TYPE_TEXT
      IF EMPTY(::aInitSize)
         // Salvo dimensioni iniziali perchä il :setSize( :currentSize())
         // incrementa le dimensioni ogni volta che ä chiamato
         // (vedi FixXbpStatic:setSize())
         ::aInitSize := ::currentSize()
      ENDIF
      ::setSize({::aInitSize[1], ROW_SIZE })
   ENDIF
RETURN self

// ----------------------------------
CLASS S2StaticGroupBoxWithFocus FROM S2GroupBoxWithFocus, S2Control

   EXPORTED:
      METHOD Init

      INLINE METHOD CanSetFocus(); RETURN .F.
      INLINE METHOD SetFocus(); RETURN .F.
      INLINE METHOD HasFocus(); RETURN .F.

ENDCLASS

METHOD S2StaticGroupBoxWithFocus:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2GroupBoxWithFocus:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2Control:Init(aCtrl, nPage, oFormFather )
   ::rbDown := oParent:rbDown
RETURN self

