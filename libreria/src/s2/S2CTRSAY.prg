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

// S2Say: CTRL_SAY
// ---------------

CLASS S2Say FROM S2Static

   CLASS VAR aProperties
   // CLASS METHOD InitClass()

   PROTECTED:
      METHOD CtrlArrInit
#ifdef _IGNORE_THIS_PROPERTIES_
      METHOD LoadProperties
#endif
      VAR oBmp, oPS

   EXPORTED:
      VAR dataLink

      METHOD Init, Create, destroy, paint //, show
      METHOD UpdControl

      INLINE METHOD getData(); RETURN EVAL(::dataLink)
ENDCLASS

// CLASS METHOD S2Say:InitClass()
//    ::aProperties := {}
//    AADD(::aProperties, {"FONT", {|x| ::setFontCompoundName(x) } })
// RETURN self

METHOD S2Say:CtrlArrInit(aCtrl, oFormFather)
   DEFAULT aCtrl[FORM_SAY_CLRID]     TO {}
   ASIZE( aCtrl[FORM_SAY_CLRID], 2 )
   IF EMPTY aCtrl[FORM_SAY_CLRTEXT] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_SAY]

#ifndef _NOFONT_
   ASIZE(aCtrl, FORM_SAY_CTRLARRLEN)
   aCtrl[FORM_SAY_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_SAY_FONTCOMPOUNDNAME ])
   IF EMPTY aCtrl[FORM_SAY_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseSayFont")
   IF EMPTY aCtrl[FORM_SAY_FONTCOMPOUNDNAME ] ASSIGN APPLICATION_FONT
   IF aCtrl[FORM_SAY_FONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_SAY_FONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_SAY_FONTCOMPOUNDNAME ]))
      aCtrl[FORM_SAY_FONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_SAY_FONTCOMPOUNDNAME ])  
   ENDIF
   DEFAULT aCtrl[FORM_SAY_ALIGNMENT_TYPE]  TO XBPALIGN_DEFAULT

   // Simone 8/4/2005
   // mantis 0000648: gestire caratteristiche ombra/raised ecc. su control say/exp/rel
   IF EMPTY aCtrl[FORM_SAY_ROTATION]    ASSIGN 0
   IF EMPTY aCtrl[FORM_SAY_SHADOWDEPTH] ASSIGN 0
   IF EMPTY aCtrl[FORM_SAY_PAINTSTYLE]  ASSIGN SAY_PS_STD

#endif

RETURN

METHOD S2Say:updControl(aCtrl)
   DEFAULT aCtrl TO ::aCtrl

   ::S2Static:updControl(aCtrl)
   ::SetCaption(dfAny2Str(::aCtrl[FORM_SAY_VAR]))

#ifndef _NOFONT_
   aCtrl[FORM_SAY_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_SAY_FONTCOMPOUNDNAME ])
   ::UpdObjFont( aCtrl[FORM_SAY_FONTCOMPOUNDNAME  ] )
#endif
   // imposta i colori foreground/background
   S2ObjSetColors(self, ! ::FormFather():hasBitmapBG(), aCtrl[FORM_SAY_CLRTEXT], APPCOLOR_SAY)

RETURN self

METHOD S2Say:init( aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos

   ::CtrlArrInit(aCtrl, oFormFather)
   
   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF S2PixelCoordinate(aCtrl)
      DEFAULT aPos TO {aCtrl[FORM_SAY_COL],aCtrl[FORM_SAY_ROW] }
      IF LEN(aCtrl)>= FORM_SAY_SIZE
         //Mantis 737 Luca
         //DEFAULT aSize TO aCtrl[FORM_SAY_SIZE]
         IF !EMPTY(aCtrl[FORM_SAY_SIZE]) .AND. VALTYPE(aCtrl[FORM_SAY_SIZE]) =="A"
            DEFAULT aSize TO ACLONE(aCtrl[FORM_SAY_SIZE])
         ENDIF
      ENDIF
      IF EMPTY(aSize)
         oPos := PosCvt():new(aCtrl[FORM_SAY_COL], aCtrl[FORM_SAY_ROW])
         oPos:SetDos(LEN(dfAny2Str(aCtrl[FORM_SAY_VAR])), 1)
         IF oPos:nXWin > 0 .AND. oPos:nYWin > 0
            aSize := {oPos:nXWin, oPos:nYWin}
         ENDIF
      ENDIF
   ELSE
      oPos := PosCvt():new(aCtrl[FORM_SAY_COL], aCtrl[FORM_SAY_ROW] +1)
      oPos:Trasla(oParent)
      DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}

      // simone 22/1/08 aggiunto per eventuale dimensione del SAY (in pixel)
      // anche per control con posizione in caratteri. 
      // usato in lib_albalog file appsettings.prg 
      IF LEN(aCtrl)>= FORM_SAY_SIZE
         //Mantis 737 Luca
         //DEFAULT aSize TO aCtrl[FORM_SAY_SIZE]
         IF !EMPTY(aCtrl[FORM_SAY_SIZE]) .AND. VALTYPE(aCtrl[FORM_SAY_SIZE]) =="A"
            DEFAULT aSize TO ACLONE(aCtrl[FORM_SAY_SIZE])
         ENDIF
      ENDIF
      IF EMPTY(aSize)
      oPos:SetDos(LEN(dfAny2Str(aCtrl[FORM_SAY_VAR])), 1)

      IF oPos:nXWin > 0 .AND. oPos:nYWin > 0
         aSize := {oPos:nXWin, oPos:nYWin}
      ENDIF
      ENDIF
   ENDIF

   DEFAULT lVisible TO .F.

#ifndef _NOFONT_
   IF ! EMPTY(aCtrl[FORM_SAY_FONTCOMPOUNDNAME])
      DEFAULT aPP TO {}
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_SAY_FONTCOMPOUNDNAME])
      //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_SAY_FONTCOMPOUNDNAME]})
   ENDIF
#endif

   // Imposta i colori nei pres. param. per foreground/background/disabled
   aPP := S2PPSetColors(aPP, ! oFormFather:hasBitmapBG(), aCtrl[FORM_SAY_CLRTEXT], APPCOLOR_SAY)

   // Inizializza l'oggetto
   // ---------------------
   ::S2Static:init( aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::autoSize := dfSet("XbaseSayAutoSize") == "YES"

   //Luca 10/06/2004
   //Modificato per gestiona allinamento/centramento Funzioni                        
   IF aCtrl[FORM_SAY_ALIGNMENT_TYPE] >= 0
      ::options := aCtrl[FORM_SAY_ALIGNMENT_TYPE]
   ELSE
      ::options := XBPSTATIC_TEXT_VCENTER
   ENDIF                                        

   // ::bCvt := {|x| ConvToOEMCp(x) }
   // ::bUnCvt := {|x| IIF(x==NIL, x, ConvToANSICp(x)) }
   //
   //
   // ::caption := ConvToOemCP( aCtrl[FORM_SAY_VAR] )
   // ::dataLink := {|x|IIF(x==NIL, ConvToAnsiCP(::caption), ;
   //                               ::setCaption(ConvToOemCP(x)))}

   ::caption := dfAny2Str(aCtrl[FORM_SAY_VAR])
   ::dataLink := {|x|IIF(x==NIL, ::caption, ::setCaption(x))}

   // Simone 8/4/2005
   // mantis 0000648: gestire caratteristiche ombra/raised ecc. su control say/exp/rel
   ::Rotation    := aCtrl[FORM_SAY_ROTATION]
   ::ShadowDepth := aCtrl[FORM_SAY_SHADOWDEPTH]

   ::nPaintStyle := aCtrl[FORM_SAY_PAINTSTYLE]
   // S2ObjSetColors(self, aCtrl[FORM_SAY_CLRTEXT], APPCOLOR_SAY)
   ::oBmp := NIL
   ::oPS  := NIL
RETURN self

METHOD S2Say:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2Static:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
#ifdef _IGNORE_THIS_PROPERTIES_
   ::LoadProperties()
#endif
RETURN self

#ifdef _IGNORE_THIS_PROPERTIES_
METHOD S2Say:LoadProperties()
   LOCAL xVal, cDll

   IF ::HasProperties( ::className() )

      xVal := ::GetProperty("FONT")
      IF xVal != NIL
         ::setFontCompoundName(ALLTRIM(xVal))
      ENDIF

      xVal := ::GetProperty("LEFT")
      IF xVal != NIL
         ::setPos({xVal, ::currentPos()[2]})
      ENDIF

      xVal := ::GetProperty("BOTTOM")
      IF xVal != NIL
         ::setPos({::currentPos()[1], xVal})
      ENDIF

      xVal := ::GetProperty("WIDTH")
      IF xVal != NIL
         ::setSize({xVal, ::currentSize()[2]})
      ENDIF

      xVal := ::GetProperty("HEIGHT")
      IF xVal != NIL
         ::setSize({::currentSize()[1], xVal})
      ENDIF

      xVal := ::GetProperty("COLORFG")
      IF xVal != NIL
         ::setColorFG(xVal)
      ENDIF

      xVal := ::GetProperty("COLORBG")
      IF xVal != NIL
         ::setColorBG(xVal)
      ENDIF

      xVal := ::GetProperty("VISIBLE")
      IF xVal != NIL
         IF ! xVal
            ::bDispIf := {|| .F. }
         ENDIF
      ENDIF

      xVal := ::GetProperty("BITMAP")
      IF xVal != NIL
         ::setCaption("")

         ::oPs := ::lockPS()

         ::oBmp := S2XbpBitMap():new():create(::oPS)

         IF "," $ xVal
            cDll := LEFT(xVal, AT(",", xVal)-1)
            IF EMPTY(cDll)
               cDll := NIL
            ELSE
               xVal := SUBSTR(xVal, AT(",", xVal)+1)
            ENDIF
            ::oBmp:Load(cDll, VAL(xVal))
         ELSE
            ::oBmp:LoadFile(xVal)
         ENDIF
         ::setSize({::oBmp:xSize, ::oBmp:ySize})

      ENDIF

   ENDIF
RETURN
#endif

// METHOD S2Say:show()
//    LOCAL lRet := ::S2Static:show()
//
//    IF ::oBmp != NIL   // Altrimenti non fa il primo display del bitmap
//       ::paint()
//    ENDIF
// RETURN lRet

METHOD S2Say:paint(aRect)
   IF ::oBmp == NIL
      ::S2Static:paint(aRect)
   ELSE
      ::oBmp:draw( ::oPS, {0, 0} )
   ENDIF
RETURN self

METHOD S2Say:destroy()
   IF ::oBmp != NIL
      ::oBmp:destroy()
      ::oBmp := NIL
   ENDIF

   IF ::oPS != NIL
      ::unlockPS(::oPS)
      ::oPS := NIL
   ENDIF

   ::S2Static:destroy()
RETURN self

