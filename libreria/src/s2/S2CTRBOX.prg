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
#include "dfSet.ch"

// S2GroupBox: CTRL_GROUPBOX
// -------------------------

CLASS S2GroupBox FROM S2Static
   PROTECTED:
      METHOD CtrlArrInit

   EXPORTED:
      METHOD Init, Create, DispItm
ENDCLASS

METHOD S2GroupBox:CtrlArrInit( aCtrl, oFormFather )
   ASIZE(aCtrl, FORM_BOX_CTRLARRLEN)

   DEFAULT aCtrl[FORM_BOX_TYPE]      TO 1
   DEFAULT aCtrl[FORM_BOX_CLRID]     TO {}
   ASIZE( aCtrl[FORM_BOX_CLRID], 4 )
   IF EMPTY aCtrl[FORM_BOX_CLRTOPLEFT    ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_NORMALBOX]
   IF EMPTY aCtrl[FORM_BOX_CLRFILLER     ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_SAY]
   IF EMPTY aCtrl[FORM_BOX_CLRBOTTOMRIGHT] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_SHADOWBOX]
   DEFAULT aCtrl[FORM_BOX_FILL]      TO ""

   DEFAULT aCtrl[FORM_BOX_COORDINATE_MODE]   TO S2CoordModeDefault()
   DEFAULT aCtrl[FORM_BOX_ALIGNMENT_TYPE]    TO XBPALIGN_DEFAULT
   DEFAULT aCtrl[FORM_BOX_TEXT]              TO ""
   DEFAULT aCtrl[FORM_BOX_TYPEOUTPUT]        TO XBPSTATIC_TYPE_DEFAULT 

RETURN

METHOD S2GroupBox:init( aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos

   ::CtrlArrInit( aCtrl, oFormFather )

   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF S2PixelCoordinate(aCtrl)
      DEFAULT aPos  TO {aCtrl[FORM_BOX_LEFT] , aCtrl[FORM_BOX_TOP]    }
      DEFAULT aSize TO {aCtrl[FORM_BOX_RIGHT], aCtrl[FORM_BOX_BOTTOM] }
   ELSE
      oPos := PosCvt():new(aCtrl[FORM_BOX_LEFT]+.5, aCtrl[FORM_BOX_BOTTOM] + .5)
      oPos:Trasla(oParent)

      DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}

      oPos:SetDos(aCtrl[FORM_BOX_RIGHT]  - aCtrl[FORM_BOX_LEFT] , ; // +1, ;
                  aCtrl[FORM_BOX_BOTTOM] - aCtrl[FORM_BOX_TOP]  ) // -1  )

      DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}

      aSize[1] := MAX(1,aSize[1])
      //aSize[2] := MAX(1,aSize[2])
   ENDIF

   DEFAULT lVisible TO .F.


   // Inizializza l'oggetto
   // ---------------------

   ::S2Static:init( aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )

   //Luca 10/06/2004
   //Modificato per gestiona allinamento/centramento Funzioni 
   //IF LEN(aCtrl)>=  FORM_BOX_TYPEOUTPUT .AND. aCtrl[FORM_BOX_TYPEOUTPUT] != XBPSTATIC_TYPE_DEFAULT 
   IF aCtrl[FORM_BOX_TYPEOUTPUT] == XBPSTATIC_TYPE_DEFAULT 
      IF EMPTY(aSize[1]) .OR. EMPTY(aSize[2])
         ::type := XBPSTATIC_TYPE_RECESSEDLINE
      ELSE
         ::type := dfSet(AI_XBASEGRPBOXSTYLE)
      ENDIF
   ELSE
      ::type    := aCtrl[FORM_BOX_TYPEOUTPUT]
   ENDIF                                        

   // Non implementato allineamento nei BOX
   //IF LEN(aCtrl)>=  FORM_BOX_ALIGNMENT_TYPE  .AND.;
   //   !EMPTY(aCtrl[FORM_BOX_ALIGNMENT_TYPE]) .AND.;
   //   aCtrl[FORM_BOX_ALIGNMENT_TYPE]>= 0
   //   ::options := aCtrl[FORM_BOX_ALIGNMENT_TYPE]
   //ENDIF                                        

   //IF LEN(aCtrl)>=FORM_BOX_TEXT  .AND. !EMPTY(aCTRL[FORM_BOX_TEXT])
   IF ! EMPTY(aCTRL[FORM_BOX_TEXT])
      ::Caption := aCTRL[FORM_BOX_TEXT]
   ENDIF

   //::type := IIF( EMPTY(aSize[1]) .OR. EMPTY(aSize[2]), ;
   //               XBPSTATIC_TYPE_RECESSEDLINE,;
   //               XBPSTATIC_TYPE_HALFTONERECT)

   //S2ObjSetColors(self, , aCtrl[FORM_BOX_CLRFILLER])

   // simone 1/6/05
   // mantis 0000760: abilitare nuovi stili per i controls
   IF ! EMPTY(dfSet(AI_XBASEGRPBOXFONT))
      ::setHFontCompoundName( dfSet(AI_XBASEGRPBOXFONT) )
   ENDIF
   IF dfSet("XbaseBoxHeaderAlign") != NIL
      IF UPPER(dfSet("XbaseBoxHeaderAlign")) == "LEFT"
         ::headerAlign := GRA_HALIGN_LEFT
      ELSEIF UPPER(dfSet("XbaseBoxHeaderAlign")) == "CENTER"
         ::headerAlign := GRA_HALIGN_CENTER
      ENDIF
   ENDIF  
   IF ! EMPTY(dfSet("XbaseBoxHeaderColorBG"))
       S2ItmSetColors({|n|NIL}, {|n| ::headerColorBG := n}, .T., dfSet("XbaseBoxHeaderColorBG"))
   ENDIF
   IF ! EMPTY(dfSet("XbaseBoxColorBG"))
       S2ItmSetColors({|n|NIL}, {|n| ::setColorBG(n)}, .T., dfSet("XbaseBoxColorBG"))
   ENDIF
   IF ! EMPTY(dfSet("XbaseBoxBorderColor"))
       S2ItmSetColors({|n|NIL}, {|n| ::borderColor := n}, .T., dfSet("XbaseBoxBorderColor"))
   ENDIF
RETURN self

METHOD S2GroupBox:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2Static:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::toBack()
RETURN self

METHOD S2GroupBox:DispItm()

#ifndef _XBASE16_
   // In Xbase 1.6 fa un refresh strano
   ::toBack()
#endif

RETURN ::S2Static:DispItm()


