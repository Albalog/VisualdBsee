#include "Font.ch"
#include "Gra.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "dfWinRep.ch"
#include "dfMsg1.ch"

// Form generica di richiesta FONTS
FUNCTION dfWinPrnFontDialog(cTitle, oPrinter, oPS, aFonts)
   LOCAL oDlg
   LOCAL oFocus := SetAppFocus()

   oDlg := FormImposta():new()
   oDlg:aFonts := aFonts
   oDlg:title := cTitle

   oDlg:oPS := oPS

   oDlg:create()
   oDlg:tbConfig()
   oDlg:show()
   oDlg:tbInk()
   oDlg:tbEnd()
   oPS:destroy()

   IF oFocus != NIL
      SetAppFocus(oFocus)
   ENDIF

   oDlg:hide()
   oDlg:destroy()

RETURN oDlg

// ------------------------------------------------

STATIC CLASS FormImposta FROM S2Dialog
   EXPORTED:

      * Contained control elements
      VAR grpNormal
      VAR txtNormal
      VAR btnNormal
      VAR grpCompresso
      VAR txtCompresso
      VAR btnCompresso
      VAR grpGrassetto
      VAR txtGrassetto
      VAR btnGrassetto
      VAR grpComprGrass
      VAR txtComprGrass
      VAR btnComprGrass
      VAR btnOk
      VAR btnCancel
      VAR nAction
      VAR aFonts
      VAR oPS

      METHOD init
      METHOD create
      METHOD keyboard
      //METHOD LoadFont
      METHOD AskFont
      METHOD tbInk
ENDCLASS

******************************************************************************
* Initialize form
******************************************************************************
METHOD FormImposta:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL aTxtPP := {}

   DEFAULT oParent  TO AppDesktop(), ;
           aPos     TO {240,185}, ;
           aSize    TO {377,380}, ;
           lVisible TO .F.

   DEFAULT aPP TO {}
   AAdd ( aPP, { XBP_PP_COMPOUNDNAME, FONT_HELV_SMALL} )

   AAdd ( aTxtPP, { XBP_PP_BGCLR, GRA_CLR_WHITE} )
   AAdd ( aTxtPP, { XBP_PP_FGCLR, GRA_CLR_BLACK} )

   ::S2Dialog:init( 0,0,30,15, oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::taskList := .T.
   ::setModalState( XBP_DISP_APPMODAL )
   ::maxButton := .F.
   ::minButton := .F.
   ::close := {|| ::nAction := 0 }

   ::grpNormal     := XbpStatic():new( ::drawingArea, , {12,288}, {348,60} )
   ::grpNormal:caption := dfStdMsg1(MSG1_DFWINPRD03)
   ::grpNormal:clipSiblings := .T.
   ::grpNormal:type := XBPSTATIC_TYPE_GROUPBOX

   ::txtNormal     := XbpStatic():new( ::grpNormal, , {12,12}, {216,24}, aTxtPP )
   ::txtNormal:caption := dfStdMsg1(MSG1_DFWINPRD01)
   ::txtNormal:clipSiblings := .T.

   ::btnNormal     := XbpPushButton():new( ::grpNormal, , {240,12}, {96,24} )
   ::btnNormal:caption := dfStdMsg1(MSG1_DFWINPRD02)
   ::btnNormal:clipSiblings := .T.
   ::btnNormal:activate := {|| ::AskFont(DFWINREP_FD_NORMAL, ::txtNormal) }

   ::grpGrassetto  := XbpStatic():new( ::drawingArea, , {12,216}, {348,60})
   ::grpGrassetto:caption := dfStdMsg1(MSG1_DFWINPRD04)
   ::grpGrassetto:clipSiblings := .T.
   ::grpGrassetto:type := XBPSTATIC_TYPE_GROUPBOX

   ::txtGrassetto    := XbpStatic():new( ::grpGrassetto, , {12,12}, {216,24}, aTxtPP )
   ::txtGrassetto:caption := dfStdMsg1(MSG1_DFWINPRD01)
   ::txtGrassetto:clipSiblings := .T.

   ::btnGrassetto    := XbpPushButton():new( ::grpGrassetto, , {240,12}, {96,24} )
   ::btnGrassetto:caption := dfStdMsg1(MSG1_DFWINPRD02)
   ::btnGrassetto:clipSiblings := .T.
   ::btnGrassetto:activate := {|| ::AskFont(DFWINREP_FD_BOLD, ::txtGrassetto) }

   ::grpCompresso  := XbpStatic():new( ::drawingArea, , {12,144}, {348,60} )
   ::grpCompresso:caption := dfStdMsg1(MSG1_DFWINPRD05)
   ::grpCompresso:clipSiblings := .T.
   ::grpCompresso:type := XBPSTATIC_TYPE_GROUPBOX

   ::txtCompresso    := XbpStatic():new( ::grpCompresso, , {12,12}, {216,24}, aTxtPP )
   ::txtCompresso:caption := dfStdMsg1(MSG1_DFWINPRD01)
   ::txtCompresso:clipSiblings := .T.

   ::btnCompresso    := XbpPushButton():new( ::grpCompresso, , {240,12}, {96,24} )
   ::btnCompresso:caption := dfStdMsg1(MSG1_DFWINPRD02)
   ::btnCompresso:clipSiblings := .T.
   ::btnCompresso:activate := {|| ::AskFont(DFWINREP_FD_CONDENSED, ::txtCompresso) }

   ::grpComprGrass := XbpStatic():new( ::drawingArea, , {12,72}, {348,60} )
   ::grpComprGrass:caption := dfStdMsg1(MSG1_DFWINPRD06)
   ::grpComprGrass:clipSiblings := .T.
   ::grpComprGrass:type := XBPSTATIC_TYPE_GROUPBOX

   ::txtComprGrass    := XbpStatic():new( ::grpComprGrass, , {12,12}, {216,24}, aTxtPP )
   ::txtComprGrass:caption := dfStdMsg1(MSG1_DFWINPRD01)
   ::txtComprGrass:clipSiblings := .T.

   ::btnComprGrass    := XbpPushButton():new( ::grpComprGrass, , {240,12}, {96,24} )
   ::btnComprGrass:caption := dfStdMsg1(MSG1_DFWINPRD02)
   ::btnComprGrass:clipSiblings := .T.
   ::btnComprGrass:activate := {|| ::AskFont(DFWINREP_FD_BOLDCOND, ::txtComprGrass) }

   ::btnOk         := XbpPushButton():new( ::drawingArea, , {80,12}, {96,24} )
   ::btnOk:caption := dfStdMsg1(MSG1_DFWINPRD07)
   ::btnOk:clipSiblings := .T.
   ::btnOk:activate := {|| ::nAction := 1 }

   ::btnCancel     := XbpPushButton():new( ::drawingArea, , {200,12}, {96,24} )
   ::btnCancel:caption := dfStdMsg1(MSG1_DFWINPRD08)
   ::btnCancel:clipSiblings := .T.
   ::btnCancel:activate := {|| ::nAction := 0}

RETURN self


******************************************************************************
* Request system resources
******************************************************************************
METHOD FormImposta:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::S2Dialog:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::centerPos()
   //::aFonts := ::LoadFont()

   ::grpNormal:create()
   ::txtNormal:caption := ::aFonts[DFWINREP_FD_NORMAL]
   ::txtNormal:create()
   ::txtNormal:setFontCompoundName(::aFonts[DFWINREP_FD_NORMAL])
   ::btnNormal:create()

   ::grpGrassetto:create()
   ::txtGrassetto:caption := ::aFonts[DFWINREP_FD_BOLD]
   ::txtGrassetto:create()
   ::txtGrassetto:setFontCompoundName(::aFonts[DFWINREP_FD_BOLD])
   ::btnGrassetto:create()

   ::grpCompresso:create()
   ::txtCompresso:caption := ::aFonts[DFWINREP_FD_CONDENSED]
   ::txtCompresso:create()
   ::txtCompresso:setFontCompoundName(::aFonts[DFWINREP_FD_CONDENSED])
   ::btnCompresso:create()

   ::grpComprGrass:create()
   ::txtComprGrass:caption := ::aFonts[DFWINREP_FD_BOLDCOND]
   ::txtComprGrass:create()
   ::txtComprGrass:setFontCompoundName(::aFonts[DFWINREP_FD_BOLDCOND])
   ::btnComprGrass:create()

   ::btnOk:create()
   ::btnCancel:create()
   ::nAction := -1
   SetAppFocus(self)
RETURN self

METHOD FormImposta:askFont(n, oTxt)
   LOCAL oFocus := SetAppFocus()
   LOCAL oDlg  := XbpFontDialog():new(self, NIL, NIL, ::oPS)
   LOCAL oFont
   LOCAL oTmpFont := XbpFont():new(::oPS)

   oDlg:title := ::title
   oDlg:fixedOnly := .T.
   oDlg:strikeOut := .F.
   oDlg:underScore := .F.
   oDlg:viewPrinterFonts := .T.
   oDlg:viewScreenFonts := .F.

   // Prendo il nome del font perchä se l'utente preme OK
   // e la casella NOME del font ä vuota da un Xbase da RUNTIME ERROR

   oTmpFont:create(::aFonts[n])
   oDlg:familyName := oTmpFont:familyName
   oDlg:nominalPointSize := oTmpFont:nominalPointSize
   oTmpFont:destroy()

   oDlg:create()

   oFont := oDlg:display(XBP_DISP_APPMODAL)

   IF oFocus != NIL
      SetAppFocus(oFocus)
   ENDIF
   oDlg:hide()
   oDlg:destroy()

   IF oFont != NIL
      //::aFonts[n] := ALLTRIM(STR(oFont:nominalPointSize))+"."+oFont:compoundName
      ::aFonts[n] := dfFont2CompoundName(oFont)
      oTxt:setFont(oFont)
      oTxt:setCaption(::aFonts[n])
      oTxt:invalidateRect()
   ENDIF

RETURN self

METHOD FormImposta:keyboard(nKey)
   LOCAL nSBPos, nSBSize, aRange
   DO CASE
      CASE nKey == xbeK_ESC
         ::nAction := 0

      OTHERWISE
         ::S2Dialog:keyboard(nKey)
   ENDCASE
RETURN self

METHOD FormImposta:tbInk()
   LOCAL nEvent, mp1, mp2, oXbp

   DO WHILE ::nAction == -1
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp, NIL, self )

      #ifdef _S2DEBUG_
         S2DebugOut(oXbp, nEvent, mp1, mp2)
      #endif

      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO

RETURN self


