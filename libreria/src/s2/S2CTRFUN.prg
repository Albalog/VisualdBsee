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

// nPromptMode
#define PM_INTERNAL                0
#define PM_EXTERNAL                1

// SD 17/7/2007 visualizza come una GET
#define _ENABLE_SHOW_AS_GET_


#define HEADER_COLORBG      GraMakeRGBColor({193,210,238}) //XBPSYSCLR_INACTIVETITLE
#define DEFAULT_COLORBG     XBPSYSCLR_INFOBACKGROUND
#define HEADER_HEIGHT       20
#define HEADER_HEIGHTAUTO   -1
#define OFFSET              4


// definite in dfCtrl.ch di Visual dBsee
#ifndef FUN_BMP_NO_BMP
   #define FUN_BMP_NO_BMP              0
   #define FUN_BMP_AUTOSIZE            1
   #define FUN_BMP_NORMAL              2
   #define FUN_BMP_SCALE               3
   #define FUN_BMP_STRETCH             4
   #define FUN_BMP_OPTIONS             0x00FFFF
   #define FUN_BMP_CENTER              0x010000
   #define FUN_BMP_REPEAT              0x020000  // non implementato
#endif

// S2Func: CTRL_FUNCTION
// ---------------------

CLASS S2Func FROM S2Static, S2CompGrp
   PROTECTED:
      METHOD CtrlArrInit
      VAR aTextOffsets

   EXPORTED:
      VAR oPrompt, oText, bBefore, realTime, oBmp, oBmpPS, aInitPos
      VAR _aInitSize // Da non confondere con ::aInitSize definito in S2Control
      VAR evalFunc, picture
      VAR dataLink, caption, nBoxType, nBitmap, xBitmap
      VAR nPromptMode
      METHOD Init, DispItm, Create, destroy, setParent, setpos, createFancy2
      METHOD setCaption, paint, setPromptCaption
      METHOD resize

      INLINE ACCESS ASSIGN METHOD caption(xCapt)
         LOCAL xRet
         IF ::oText == NIL
            IF PCOUNT() > 0
               ::S2Static:caption := xCapt
            ENDIF
            xRet := ::S2Static:caption
         ELSE
#ifdef _ENABLE_SHOW_AS_GET_
         IF ::oText:isDerivedFrom("XbpStatic")
            IF PCOUNT() > 0
               ::oText:caption := xCapt
            ENDIF
            xRet := ::oText:caption
         ELSE
            IF PCOUNT() > 0
               ::oText:setData(xCapt)
            ENDIF
            xRet := ::oText:editbuffer()
         ENDIF
#else
            IF PCOUNT() > 0
               ::oText:caption := xCapt
            ENDIF
            xRet := ::oText:caption
#endif

         ENDIF
      RETURN xRet

      METHOD UpdControl

      INLINE METHOD getData(); RETURN EVAL( ::dataLink )
ENDCLASS

METHOD S2Func:CtrlArrInit( aCtrl, oFormFather )
   ASIZE(aCtrl, FORM_FUN_CTRLARRLEN)

   DEFAULT aCtrl[FORM_FUN_PICTURE]   TO ""
   DEFAULT aCtrl[FORM_FUN_BEFORE]    TO {||.T.}
   DEFAULT aCtrl[FORM_FUN_COMPEXP]   TO {||.T.}
   DEFAULT aCtrl[FORM_FUN_BOX]       TO 0
   DEFAULT aCtrl[FORM_FUN_CLRID]     TO {}
   ASIZE( aCtrl[FORM_FUN_CLRID], 6 )
   IF EMPTY aCtrl[FORM_FUN_CLRPROMPT     ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_PROMPT   ]
   IF EMPTY aCtrl[FORM_FUN_CLRHOTKEY     ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_HOTPROMPT]
   IF EMPTY aCtrl[FORM_FUN_CLRDATA       ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_FUNCTION ]
   IF EMPTY aCtrl[FORM_FUN_CLRTOPLEFT    ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_NORMALBOX]
   IF EMPTY aCtrl[FORM_FUN_CLRBOTTOMRIGHT] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_SHADOWBOX]
   IF EMPTY aCtrl[FORM_FUN_PROMPT]         ASSIGN ""
   DEFAULT aCtrl[FORM_FUN_ROW] TO aCtrl[FORM_FUN_BOTTOM]-aCtrl[FORM_FUN_TOP] -1  // Righe Colonne memo
   DEFAULT aCtrl[FORM_FUN_COL] TO aCtrl[FORM_FUN_RIGHT] -aCtrl[FORM_FUN_LEFT]-1

   IF LEN(aCtrl) >= FORM_FUN_BITMAP
      DEFAULT aCtrl[FORM_FUN_BITMAP] TO FUN_BMP_NO_BMP
   ENDIF

   IF aCtrl[FORM_FUN_COMPEXP]#NIL
      oFormFather:_tbUpdExp( aCtrl[FORM_FUN_COMPGRP], aCtrl[FORM_CTRL_ID] )
   ENDIF

   // Simone 8/4/2005
   // mantis 0000648: gestire caratteristiche ombra/raised ecc. su control say/exp/rel
   IF EMPTY aCtrl[FORM_FUN_ROTATION]    ASSIGN 0
   IF EMPTY aCtrl[FORM_FUN_SHADOWDEPTH] ASSIGN 0
   IF EMPTY aCtrl[FORM_FUN_PAINTSTYLE]  ASSIGN FUN_PS_STD

#ifndef _NOFONT_
   aCtrl[FORM_FUN_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_FUN_FONTCOMPOUNDNAME ])
   aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ])
   IF EMPTY aCtrl[FORM_FUN_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseFunFont")
   IF EMPTY aCtrl[FORM_FUN_FONTCOMPOUNDNAME ] ASSIGN APPLICATION_FONT
   IF aCtrl[FORM_FUN_FONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_FUN_FONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_FUN_FONTCOMPOUNDNAME ]))
      aCtrl[FORM_FUN_FONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_FUN_FONTCOMPOUNDNAME ])

   ENDIF

   IF EMPTY aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ] ASSIGN dfSet("XbasePromptFunFont")
   IF EMPTY aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ] ASSIGN dfSet("XbasePromptGetFont")
   IF EMPTY aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ] ASSIGN aCtrl[FORM_FUN_FONTCOMPOUNDNAME ]
   IF aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ]))
      aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ])

   ENDIF
   DEFAULT aCtrl[FORM_FUN_ALIGNMENT_TYPE]  TO XBPALIGN_DEFAULT

#endif

RETURN

METHOD S2Func:updControl(aCtrl)
   LOCAL oXbp
   LOCAL cColorBG
   LOCAL cColorFG

   DEFAULT aCtrl TO ::aCtrl

   ::S2Static:updControl(aCtrl)

   ::picture  := UPPER(::aCtrl[FORM_FUN_PICTURE])

   ::EvalFunc := ::aCtrl[FORM_FUN_VAR]
   ::bBefore  := ::aCtrl[FORM_FUN_BEFORE]
   ::realTime := ::aCtrl[FORM_FUN_REALTIME]

   IF ::oText   == NIL
      S2ObjSetColors(self, ! ::FormFather():hasBitmapBG(), aCtrl[FORM_FUN_CLRDATA], APPCOLOR_FUN)
   ELSE

      // simone 28/5/08
      // mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
      IF dfSet(AI_XBASEDISABLEDGETCOPY) == AI_DISABLEDGETCOPY_NO
         S2ObjSetColors(::oText, ! ::FormFather():hasBitmapBG(), aCtrl[FORM_FUN_CLRDATA], APPCOLOR_FUNBOX)
      ELSE
         oXbp := ::oText
         cColorFG := dfSet("XbaseGetDisabledColorFG")
         cColorBG := dfSet("XbaseGetDisabledColorBG")

         IF cColorBG != NIL 
            IF S2IsNumber(cColorBG)
               ::oText:setColorBG(VAL(cColorBG))
            ELSE
               S2ItmSetColors({|n|NIL}, {|n| oXbp:setColorBG(n)}, .T., cColorBG)
            ENDIF
         ENDIF

         IF cColorFG != NIL 
            IF S2IsNumber(cColorFG)
               ::oText:setColorFG(VAL(cColorFG))
            ELSE
               S2ItmSetColors({|n|NIL}, {|n| oXbp:setColorFG(n)}, .T., cColorFG)
            ENDIF
         ENDIF
      ENDIF

   ENDIF

   IF ::nPromptMode == PM_INTERNAL
      ::S2Static:setCaption( ::ChgHotKey( ::aCtrl[FORM_FUN_PROMPT] ) )
      // Aggiunto Luca 19/03/2008
      S2ObjSetColors(::S2Static, ! ::FormFather():hasBitmapBG(), aCtrl[FORM_FUN_CLRPROMPT], APPCOLOR_FUNPROMPT )
   ELSEIF ::oPrompt != NIL
      ::oPrompt:setCaption( ::ChgHotKey( ::aCtrl[FORM_FUN_PROMPT] ) )
      S2ObjSetColors(::oPrompt, ! ::FormFather():hasBitmapBG(), aCtrl[FORM_FUN_CLRPROMPT], APPCOLOR_FUNPROMPT )
   ENDIF

#ifndef _NOFONT_
   aCtrl[FORM_FUN_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_FUN_FONTCOMPOUNDNAME ])
   // Aggiunto Luca 19/03/2008
   IF ::nPromptMode == PM_INTERNAL .AND. !EMPTY(dfSet("XbasePromptGetFont"))
      // Aggiunto Luca 19/03/2008
      aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(dfSet("XbasePromptGetFont")) //::getDefaultFont(aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ])
   ELSE 
   aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_FUN_PFONTCOMPOUNDNAME ])
   ENDIF 
   ::UpdObjFont( aCtrl[FORM_FUN_FONTCOMPOUNDNAME  ] )
   IF ::oPrompt != NIL
      ::UpdObjFont( aCtrl[FORM_FUN_PFONTCOMPOUNDNAME  ], ::oPrompt )
   ENDIF
   IF ::oText   != NIL
      ::UpdObjFont( aCtrl[FORM_FUN_PFONTCOMPOUNDNAME  ], ::oText   )
   ENDIF
   // Aggiunto Luca 19/03/2008
   IF ::nPromptMode == PM_INTERNAL
      //aCtrl[FORM_FUN_PFONTCOMPOUNDNAME  ] := dfSet("XbasePromptGetFont")
      ::UpdObjFont( aCtrl[FORM_FUN_PFONTCOMPOUNDNAME  ],  ::S2Static   )
   ENDIF 
#endif


RETURN self

METHOD S2Func:setParent(o)
   LOCAL oRet
   IF PCOUNT() > 0
      oRet := ::S2Static:setParent(o)
      IF ::oPrompt != NIL
         ::oPrompt:setParent(o)
      ENDIF
   ELSE
      oRet := ::S2Static:setParent()
   ENDIF
RETURN oRet

METHOD S2Func:setPos(aPos, lPaint)
   LOCAL lRet
   LOCAL nXDiff
   LOCAL aCurPos
   DEFAULT lPaint TO .T.

   IF ::oPrompt != NIL 
      aCurPos := ::currentPos()
      aCurPos[1] := ::oPrompt:currentPos()[1] - aCurPos[1]
      aCurPos[2] := ::oPrompt:currentPos()[2] - aCurPos[2]
      ::oPrompt:setPos({aPos[1]+aCurPos[1], aPos[2]+aCurPos[2]}, lPaint)
   ENDIF

   lRet := ::S2Static:setPos(aPos, lPaint)

RETURN lRet



METHOD S2Func:Init( aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos
   LOCAL oXbp
   LOCAL nWidth := 0
   LOCAL nHeight := 0
   LOCAL lInternalPrompt := ! (dfSet("XbasePromptMode") == "EXTERNAL") // GERR 3853 SD 21/7/03
   LOCAL aSize_Prompt := {}

   LOCAL cCaption     := aCtrl[FORM_FUN_PROMPT]

   ::CtrlArrInit( aCtrl, oFormFather )
   ::nBoxType := aCtrl[FORM_FUN_BOX]

   // 0=no bitmap
   // 1=bitmap normal
   // 2=bitmap con autosize alle dimensioni bitmap
   ::nBitmap := FUN_BMP_NO_BMP

   IF LEN(aCtrl) >= FORM_FUN_BITMAP
      ::nBitmap  :=  aCtrl[FORM_FUN_BITMAP]

      IF VALTYPE(::nBitmap) == "L"
         ::nBitmap := IIF(::nBitmap, FUN_BMP_AUTOSIZE, FUN_BMP_NO_BMP)
      ENDIF
   ENDIF

   // GERR 3583 SD 21/7/03
   IF ::nBitmap == FUN_BMP_NO_BMP .AND. lInternalPrompt .AND. ! EMPTY(::nBoxType) .AND. ! EMPTY(aCtrl[FORM_FUN_PROMPT])
      ::nPromptMode := PM_INTERNAL
   ELSE
      ::nPromptMode := PM_EXTERNAL
   ENDIF

   DO CASE
      CASE ::nBitmap != FUN_BMP_NO_BMP
         //13/05/04 Luca: Inserito per gestione pixel o Row/Column
         IF S2PixelCoordinate(aCtrl)
            DEFAULT aPos  TO {aCtrl[FORM_FUN_LEFT], aCtrl[FORM_FUN_TOP]}
            DEFAULT aSize TO {aCtrl[FORM_FUN_RIGHT], aCtrl[FORM_FUN_BOTTOM]}
         ELSE
            oPos := PosCvt():new(aCtrl[FORM_FUN_LEFT], aCtrl[FORM_FUN_TOP])

            oPos:Trasla(oParent)

            DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}

            oPos:SetDos( nWidth, nHeight )
         ENDIF

      CASE EMPTY(::nBoxType)
         //13/05/04 Luca: Inserito per gestione pixel o Row/Column
         IF S2PixelCoordinate(aCtrl)
            DEFAULT aPos TO  {aCtrl[FORM_FUN_LEFT] , aCtrl[FORM_FUN_TOP]}
            DEFAULT aSize TO {aCtrl[FORM_FUN_RIGHT], aCtrl[FORM_FUN_BOTTOM]}
            nWidth := aCtrl[FORM_FUN_RIGHT]
            nHeight :=  aCtrl[FORM_FUN_BOTTOM]
         ELSE
            IF aCtrl[FORM_FUN_RIGHT] == 0 .AND. aCtrl[FORM_FUN_LEFT] == 0
               nWidth := 0
            ELSE
               nWidth  := aCtrl[FORM_FUN_RIGHT] - aCtrl[FORM_FUN_LEFT] + 1
            ENDIF
            nHeight := MAX(1, aCtrl[FORM_FUN_BOTTOM] - aCtrl[FORM_FUN_TOP] + 1)

            IF nWidth <= 0
               nWidth := MAX(0, dfPictLen(aCtrl[FORM_FUN_PICTURE]))
            ENDIF

            oPos := PosCvt():new(aCtrl[FORM_FUN_LEFT], aCtrl[FORM_FUN_TOP]+nHeight)

            oPos:Trasla(oParent)

            DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}

            oPos:SetDos( nWidth, nHeight )

            IF oPos:nXWin > 0 .AND. oPos:nYWin > 0
               DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}
            ENDIF
         ENDIF
      OTHERWISE
         //13/05/04 Luca: Inserito per gestione pixel o Row/Column
         IF S2PixelCoordinate(aCtrl)
            DEFAULT aPos TO  {aCtrl[FORM_FUN_LEFT] , aCtrl[FORM_FUN_TOP]}
            DEFAULT aSize TO {aCtrl[FORM_FUN_RIGHT], aCtrl[FORM_FUN_BOTTOM]}
         ELSE
            oPos := PosCvt():new(aCtrl[FORM_FUN_LEFT]+.5, aCtrl[FORM_FUN_BOTTOM] + .5)
            oPos:Trasla(oParent)

            DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}
            DEFAULT lVisible TO .F.

            oPos:SetDos(aCtrl[FORM_FUN_RIGHT]  - aCtrl[FORM_FUN_LEFT] , ; // +1, ;
                        aCtrl[FORM_FUN_BOTTOM] - aCtrl[FORM_FUN_TOP]  ) // -1  )

            DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}
         ENDIF
   ENDCASE

   DEFAULT lVisible TO .F.


#ifndef _NOFONT_
   IF ! EMPTY(aCtrl[FORM_FUN_FONTCOMPOUNDNAME])
      DEFAULT aPP TO {}
      // Aggiunto Luca 19/03/2008
      IF ::nPromptMode == PM_INTERNAL .AND. !EMPTY(aCtrl[FORM_FUN_PFONTCOMPOUNDNAME])
         aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_FUN_PFONTCOMPOUNDNAME])
      ELSE 
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_FUN_FONTCOMPOUNDNAME])
      ENDIF 
      //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_FUN_FONTCOMPOUNDNAME]})
   ENDIF
#endif
   ::aTextOffsets := NIL

   // Imposta i colori nei pres. param. per foreground/background/disabled
   aPP := S2PPSetColors(aPP, ! oFormFather:hasBitmapBG(), aCtrl[FORM_FUN_CLRDATA], APPCOLOR_FUN)

   // Inizializza l'oggetto
   // ---------------------
   ::S2Static:Init( aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2CompGrp:Init(aCtrl[FORM_FUN_COMPGRP], aCtrl[FORM_FUN_COMPEXP])

   //::options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   ::oBmp := NIL
   ::oText := NIL

   DO CASE
      CASE ::nBitmap != FUN_BMP_NO_BMP
         ::caption := ""
         oXbp := S2XbpBitmap():new()
         ::oBmp := oXbp
         ::oBmpPS := XbpPresSpace():new()
         ::aInitPos := aPos
         ::_aInitSize := aSize

      CASE EMPTY(::nBoxType)
#ifdef _ENABLE_SHOW_AS_GET_
         IF aCtrl[FORM_FUN_PAINTSTYLE] == FUN_PS_GETLOOK
            oXbp := XbpSle():new(self, NIL, NIL, aSize, aPP)
            oXbp:autoSize := .F.
   //         IF _UseAlignment(aCtrl)
   //            oXbp := XbpSle():new(self, NIL, NIL, aSize, aPP)
   //            oXbp:autoSize := .F.
   //            oXbp:options := aCtrl[FORM_FUN_ALIGNMENT_TYPE]
   //         ELSE
   //            oXbp := XbpMle():new(self, NIL, NIL, aSize, aPP)
   //            oXbp:wordwrap := .T.
   //         ENDIF
            oXbp:editable := .F.
            //aCtrl[FORM_FUN_PAINTSTYLE] := FUN_PS_STD

            ::oText := oXbp
         ELSE
            //Luca 10/06/2004
            //Modificato per gestiona allinamento/centramento Funzioni 
            IF _UseAlignment(aCtrl)
               ::autoSize := .F.
               ::options := aCtrl[FORM_FUN_ALIGNMENT_TYPE]
            ELSE
               ::autoSize := nWidth <= 0 // .OR. dfSet("XbaseFunAutoSize") == "YES"
               ::options  := XBPSTATIC_TEXT_VCENTER
            ENDIF
         ENDIF
#else
         //Luca 10/06/2004
         //Modificato per gestiona allinamento/centramento Funzioni 
         IF _UseAlignment(aCtrl)
            ::autoSize := .F.
            ::options := aCtrl[FORM_FUN_ALIGNMENT_TYPE]
         ELSE
            ::autoSize := nWidth <= 0 // .OR. dfSet("XbaseFunAutoSize") == "YES"
            ::options  := XBPSTATIC_TEXT_VCENTER
         ENDIF
#endif
         ::picture  := UPPER(aCtrl[FORM_FUN_PICTURE])
         ::caption  := SPACE( MAX(nWidth, dfPictLen(::picture) ) )

      OTHERWISE
         ::type := XBPSTATIC_TYPE_GROUPBOX
         //13/05/04 Luca: Inserito per gestione pixel o Row/Column
         IF S2PixelCoordinate(aCtrl)
            //Mantis 335
            //aPos  := {.4, .3}
            //aSize := {aCtrl[FORM_FUN_RIGHT] ,aCtrl[FORM_FUN_BOTTOM] }
            aPos  := {4,5}
            aSize := {aCtrl[FORM_FUN_RIGHT] -9,aCtrl[FORM_FUN_BOTTOM] -20}
         ELSE
           oPos := PosCvt():new(.4, .3)
           //oPos:Trasla(oParent)
           aPos := {oPos:nXWin, oPos:nYWin}

           oPos:SetDos(aCtrl[FORM_FUN_RIGHT]  - aCtrl[FORM_FUN_LEFT] -1, ; // +1, ;
                       aCtrl[FORM_FUN_BOTTOM] - aCtrl[FORM_FUN_TOP] -1 ) // -1  )

           IF oPos:nXWin > 0 .AND. oPos:nYWin > 0
              aSize := {oPos:nXWin + 1, oPos:nYWin}
           ENDIF
         ENDIF
         aPP := {}
         aPP := S2PPSetColors(aPP, ! oFormFather:hasBitmapBG(), aCtrl[FORM_FUN_CLRDATA], APPCOLOR_FUNBOX)

         // Per il resize
         ::aTextOffsets := {aPos[1], aPos[2], ::currentSize()[1]-aSize[1], ::currentSize()[2]-aSize[2]}

         oXbp := XbpStatic():new(self, NIL, aPos, aSize, aPP)
         oXbp:autoSize := .F.
         IF _UseAlignment(aCtrl)
            oXbp:options := aCtrl[FORM_FUN_ALIGNMENT_TYPE]
         ELSE
            oXbp:options := XBPSTATIC_TEXT_VCENTER + XBPSTATIC_TEXT_WORDBREAK
         ENDIF
         //Mantis 976
         IF !(dfSet(AI_XBASEGETSTYLE) == GET_PS_STD)
            ::headerHeight  := HEADER_HEIGHTAUTO
            ::headerColorBG := HEADER_COLORBG
            ::headerAlign   := GRA_HALIGN_RIGHT
            ::borderColor   := NIL
         ENDIF


         //S2ObjSetColors(oXbp, ! oFormFather:hasBitmapBG(), aCtrl[FORM_FUN_CLRDATA], APPCOLOR_FUNBOX)
         ::oText   := oXbp
   ENDCASE
   ::aInitPos   := aPos
   ::_aInitSize := aSize


   ::EvalFunc := aCtrl[FORM_FUN_VAR]
   ::bBefore  := aCtrl[FORM_FUN_BEFORE]
   ::realTime := aCtrl[FORM_FUN_REALTIME]
   ::dataLink := {|x|IIF(x==NIL, ::caption, ::setCaption(x))}
   // S2ObjSetColors(self, ! oFormFather:hasBitmapBG(), aCtrl[FORM_FUN_CLRDATA], APPCOLOR_FUN)

   // Simone 8/4/2005
   // mantis 0000648: gestire caratteristiche ombra/raised ecc. su control say/exp/rel
   ::Rotation    := aCtrl[FORM_FUN_ROTATION]
   ::ShadowDepth := aCtrl[FORM_FUN_SHADOWDEPTH]

   // Simone 1/6/2005
   ::nPaintStyle := aCtrl[FORM_FUN_PAINTSTYLE]

   // PROMPT
   ::oPrompt := NIL
   IF ! EMPTY(aCtrl[FORM_FUN_PROMPT])
      IF ::nPromptMode == PM_INTERNAL
         // Metto il prompt interno al box
         // Aggiunto Luca 19/03/2008
         //::S2Static:caption := aCtrl[FORM_FUN_PROMPT]
         ::S2Static:setCaption( aCtrl[FORM_FUN_PROMPT])
      ELSE
         //13/05/04 Luca: Inserito per gestione pixel o Row/Column
         IF S2PixelCoordinate(aCtrl)
            aPos := {aCtrl[FORM_FUN_PCOL], aCtrl[FORM_FUN_PROW]}
            oPos := PosCvt():new(1, 1)
            oPos:SetDos(LEN(aCtrl[FORM_FUN_PROMPT]), 1)
            IF oPos:nXWin > 0 .AND. oPos:nYWin > 0
               aSize_Prompt := {oPos:nXWin + 1, aSize[2]}
            ENDIF
         ELSE

            oPos := PosCvt():new(aCtrl[FORM_FUN_PCOL], aCtrl[FORM_FUN_PROW]+1)
            oPos:Trasla(oParent)
            aPos := {oPos:nXWin, oPos:nYWin}
            oPos:SetDos(LEN(aCtrl[FORM_FUN_PROMPT]), 1)
            IF aCtrl[FORM_FUN_PROW] <= aCtrl[FORM_FUN_TOP] .AND. ;
               aCtrl[FORM_FUN_PCOL] ==  aCtrl[FORM_FUN_LEFT]
               aPos[2] += 1
            ENDIF
            IF aCtrl[FORM_FUN_PROW] == aCtrl[FORM_FUN_TOP] .AND. ;
               aCtrl[FORM_FUN_PCOL] <  aCtrl[FORM_FUN_LEFT]
               aPos[1] -=5
            ENDIF
            IF oPos:nXWin > 0 .AND. oPos:nYWin > 0
               aSize_Prompt := {oPos:nXWin+5 , oPos:nYWin}
            ENDIF
         ENDIF
         aPP := NIL
      #ifndef _NOFONT_
         IF ! EMPTY(aCtrl[FORM_FUN_PFONTCOMPOUNDNAME])
            aPP := {}
            aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_FUN_PFONTCOMPOUNDNAME])
            //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_FUN_PFONTCOMPOUNDNAME]})
         ENDIF
      #endif

         aPP := S2PPSetColors(aPP, ! oFormFather:hasBitmapBG(), aCtrl[FORM_FUN_CLRPROMPT], APPCOLOR_FUNPROMPT)
         oXbp := XbpStatic():new(oParent, oOwner, aPos, aSize_Prompt, aPP,.F. )
         oXbp:caption := aCtrl[FORM_FUN_PROMPT]
         oXbp:clipSiblings := .T. // .F.

         //Vi era un errore di allineamneto Prompt di campi relazionti Mantis 204
         ////Luca 10/06/2004
         ////Modificato per gestiona allinamento/centramento Funzioni 
         //IF _UseAlignment(aCtrl)
         //   oXbp:options := aCtrl[FORM_FUN_ALIGNMENT_TYPE]
         //ELSE
         oXbp:autoSize := dfSet("XbaseFPrAutoSize") == "YES"
  
         IF S2PixelCoordinate(aCtrl) 
            IF aCtrl[FORM_FUN_PROW] == aCtrl[FORM_FUN_TOP] .AND. ;
               aCtrl[FORM_FUN_PCOL] <  aCtrl[FORM_FUN_LEFT]
               //Vi era un errore di allineamneto Prompt di campi relazionti Mantis 204
               //oXbp:options := XBPSTATIC_TEXT_VCENTER
               // Mantis 707
               oXbp:autoSize := .T.
               ////////////////////////
               oXbp:options := XBPSTATIC_TEXT_RIGHT + XBPSTATIC_TEXT_VCENTER
            ELSEIF aCtrl[FORM_FUN_PROW] <= aCtrl[FORM_FUN_TOP] .AND. ;
               aCtrl[FORM_FUN_PCOL] ==  aCtrl[FORM_FUN_LEFT]
               oXbp:options  := XBPSTATIC_TEXT_TOP
               oXbp:autoSize := .T.
            ELSEIF aCtrl[FORM_FUN_PROW] == aCtrl[FORM_FUN_TOP] .AND. ;
               aCtrl[FORM_FUN_PCOL] >  aCtrl[FORM_FUN_LEFT]
               oXbp:options  := XBPSTATIC_TEXT_LEFT + XBPSTATIC_TEXT_VCENTER
               oXbp:autoSize := .T.
            ELSE
               oXbp:options  := XBPSTATIC_TEXT_VCENTER
               // Mantis 707
               oXbp:autoSize := .T.
               ////////////////////////
            ENDIF
         ELSE             
            IF aCtrl[FORM_FUN_PROW] == aCtrl[FORM_FUN_TOP] .AND. ;
               aCtrl[FORM_FUN_PCOL] <  aCtrl[FORM_FUN_LEFT]
               oXbp:options := XBPSTATIC_TEXT_RIGHT + XBPSTATIC_TEXT_VCENTER
            ELSEIF aCtrl[FORM_FUN_TOP] >= aCtrl[FORM_FUN_PROW] .AND. ;
               aCtrl[FORM_FUN_LEFT] ==  aCtrl[FORM_FUN_PCOL]
               oXbp:options  := XBPSTATIC_TEXT_TOP
            ELSEIF aCtrl[FORM_FUN_PROW] == aCtrl[FORM_FUN_ROW] .AND. ;
               aCtrl[FORM_FUN_PCOL] >  aCtrl[FORM_FUN_LEFT]
               oXbp:options  := XBPSTATIC_TEXT_LEFT + XBPSTATIC_TEXT_VCENTER
            ELSE
               oXbp:options  := XBPSTATIC_TEXT_VCENTER
            ENDIF
         ENDIF
         // Allineamento a destra del prompt se Š sulla stessa riga
         IF aCtrl[FORM_FUN_PROW] == aCtrl[FORM_FUN_TOP] .AND. ;
            aCtrl[FORM_FUN_PCOL] <  aCtrl[FORM_FUN_LEFT] .AND. ;
            ! EMPTY(dfSet("XbasePromptAlign"))

            oXbp:options := VAL(dfSet("XbasePromptAlign"))

         ENDIF
         //ENDIF                                        

         oXbp:rbDown := ::rbDown
         // S2ObjSetColors(oXbp, ! oFormFather:hasBitmapBG(), aCtrl[FORM_FUN_CLRPROMPT], APPCOLOR_FUNPROMPT)

         ::oPrompt := oXbp
      ENDIF
   ENDIF

RETURN self

METHOD S2Func:createFancy2()
   LOCAL aPos , aOldP
   LOCAL aSize, aOLdS
   LOCAL nBorderColor 
   LOCAL nHeaderHeight

   ::oHeadBG := XbpStatic():new(self, NIL, NIL, NIL, NIL, .F.)
   //::oHeadBG:type := XBPSTATIC_TYPE_BGNDRECT
   ::oHeadBG:create()
   ::setHFont( ::setHFont() )
   ::setHFontCompoundName( ::setHFontCompoundName() )

   nBorderColor := ::borderColor
   DEFAULT nBorderColor TO ::setColorFG()
   IF nBorderColor != NIL
      ::oHeadBG:setColorBG(nBorderColor)
   ENDIF

   aSize := ::currentsize()
   //aSize[1] -= 2

   nHeaderHeight := ::headerHeight
   IF nHeaderHeight == HEADER_HEIGHTAUTO
      IF EMPTY(::caption)
         nHeaderHeight := HEADER_HEIGHT
      ELSE
         nHeaderHeight := S2StringDim(::oHeadBG, ::caption)[2]
         nHeaderHeight := MAx(nHeaderHeight,HEADER_HEIGHT )
      ENDIF
   ENDIF

   aPos := {0, aSize[2]-nHeaderHeight}
   aSize[2] := nHeaderHeight
   //aSize[1] += - 0.5 

   ::oHeadBG:setPosAndSize(aPos, aSize)

   aSize[1] -= 2
   aSize[2] -= 2
   ::oHeadText := XbpStatic():new(::oHeadBG, NIL, {1, 1}, aSize)
   ::oHeadText:options := XBPSTATIC_TEXT_VCENTER 
   DO CASE
      CASE ::headerAlign == GRA_HALIGN_LEFT
         ::oHeadText:options += XBPSTATIC_TEXT_LEFT 

      CASE ::headerAlign == GRA_HALIGN_RIGHT
         ::oHeadText:options += XBPSTATIC_TEXT_RIGHT

      OTHERWISE  //centrato
         ::oHeadText:options += XBPSTATIC_TEXT_CENTER
   ENDCASE
   ::oHeadText:caption := ::caption 
   ::oHeadText:create()
   ::oHeadText:setColorBG(::headerColorBG)

   ::oHeadBG:show()
   aOldP := ::oText:CurrentPos()
   aOLdS := ::oText:CurrentSize()
   aOldP[1] += -2
   aOldP[2] += -2
   aOLdS[1] +=  4
   aOLdS[2] += -3
   ::oText:SETPOSANDSIZE(aOldP,aOLdS)
   //::setColorBG(GRA_CLR_BLACK)


   //Luca 03/09/2012
   ///////////////////////
   ::invalidateRect()
   ///////////////////////

RETURN self

METHOD S2Func:DispItm()
   LOCAL xVal
   LOCAL lRet := .F.
   LOCAL aDim
   LOCAL aPos
   LOCAL aSize
   LOCAL nDelta
   ////////////////////////////////////////////////
   // Modifica Luca del 2/03/2005
   //LOCAL aPosOrig  := ::currentPos()
   //LOCAL aSizeOrig := ::currentSize()
   ////////////////////////////////////////////////
   LOCAL aPosOrig  := ::aInitPos
   LOCAL aSizeOrig := ::_aInitSize
   LOCAL nBitmap   := ::nBitmap

   LOCAL cColorFG 
   LOCAL cColorBG 
   LOCAL oXbp

   EVAL(::bBefore)


   ////////////////////////////////////////////////
   // Modifica Luca del 2/03/2005
   DEFAULT aPosOrig  TO ::currentPos()
   DEFAULT aSizeOrig TO ::currentSize()
   ////////////////////////////////////////////////

   xVal := EVAL(::evalFunc)

   //Luca 10/06/2004
   //Modificato per gestiona allinamento/centramento Funzioni 
   IF !_UseAlignment(::aCtrl)
       // Allineamento automatico a destra per i numeri
       IF VALTYPE(xVal) == "N" .AND. dfAnd(::options,XBPSTATIC_TEXT_RIGHT) == 0
          ::options += XBPSTATIC_TEXT_RIGHT
          ::configure()

#ifdef _ENABLE_SHOW_AS_GET_
          IF ::oText != NIL .AND. ! ::oText:isDerivedFrom("XbpStatic")
             ::oText:Align := XBPSLE_RIGHT
             ::oText:configure()

             // simone 28/5/08
             // mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
             IF dfSet(AI_XBASEDISABLEDGETCOPY) == AI_DISABLEDGETCOPY_NO
             ::oText:disable()
             ELSE
                oXbp := ::oText
                cColorFG := dfSet("XbaseGetDisabledColorFG")
                cColorBG := dfSet("XbaseGetDisabledColorBG")

                IF cColorBG != NIL 
                   IF S2IsNumber(cColorBG)
                      ::oText:setColorBG(VAL(cColorBG))
                   ELSE
                      S2ItmSetColors({|n|NIL}, {|n| oXbp:setColorBG(n)}, .T., cColorBG)
                   ENDIF
                ENDIF

                IF cColorFG != NIL 
                   IF S2IsNumber(cColorFG)
                      ::oText:setColorFG(VAL(cColorFG))
                   ELSE
                      S2ItmSetColors({|n|NIL}, {|n| oXbp:setColorFG(n)}, .T., cColorFG)
                   ENDIF
                ENDIF
             ENDIF

          ENDIF
#endif
       ENDIF
   ENDIF                                        

   IF ! EMPTY(::picture)
      IF xVal==NIL
         xVal := ""
      ENDIF
      xVal := TRANSFORM(xVal, ::picture)
   ENDIF

   IF nBitmap != FUN_BMP_NO_BMP
      IF ! xVal == ::xBitmap
         IF (VALTYPE(xVal) == "N" .AND. ::oBmp:load(NIL, xVal)) .OR. ;
            (VALTYPE(xVal) == "A" .AND. ::oBmp:load(xVal[1], xVal[2])) .OR. ;
            (VALTYPE(xVal) == "C" .AND. ::oBmp:loadFile(xVal))

            IF dfAnd(nBitmap, FUN_BMP_CENTER) != 0
               nBitmap -= FUN_BMP_CENTER
            ENDIF

            DEFAULT ::_aInitSize TO ::currentSize()

            IF nBitmap == FUN_BMP_AUTOSIZE
               IF S2PixelCoordinate(::aCtrl)

                  ::setPosAndSize({::aInitPos[1], ::aInitPos[2]+::_aInitSize[2]-::oBmp:ySize},{::oBmp:xSize, ::oBmp:ySize+1})

                  // potrebbe essere meglio cosi.. con orig. coordinate left, bottom
                  //::setPosAndSize(::aInitPos,{::oBmp:xSize, ::oBmp:ySize+1})

               ELSE
                 // NOTA: ySize + 1  altrimenti non si vede tutta la bitmap
                 #ifdef _XBASE15_
                  ::setPosAndSize({::aInitPos[1], ::aInitPos[2]-::oBmp:ySize},{::oBmp:xSize, ::oBmp:ySize+1})
                 #else
                  ::setSize({::oBmp:xSize, ::oBmp:ySize+1})
                  ::setPos({::aInitPos[1], ::aInitPos[2]-::oBmp:ySize})
                 #endif
               ENDIF

            ELSEIF ::currentpos()[1] != ::aInitPos[1] .OR.;
                   ::currentpos()[2] != ::aInitPos[2] .OR.;
                   ::currentsize()[1] != ::_aInitSize[1] .OR.;
                   ::currentsize()[2] != ::_aInitSize[2]
               ::setPosAndSize(::aInitPos,::_aInitSize)
            ENDIF

            ::xBitmap := xVal
            // SD 23/05/2002 per GERR 3222
            //tOLTO PERCHE LO FACCIO SEmpre dopo.
            //::invalidateRect()
         ENDIF
      ENDIF
   ELSE
      IF VALTYPE(xVal) $ "CM" .AND. ! xVal == ::caption

         // Simone 12/giu/2001 ricalcola sempre la grandezza
         // della stringa perchŠ se uso font non proporzionale
         // la dimensione pu• cambiare anche a parit… di
         // numero di lettere

         // Tolgo spazi a destra
         xVal := TRIM(xVal)
         //Aggiunto
         //Luca 10/06/2004
         //Modificato per gestione allinamento/centramento Funzioni 
         //Mantis
         //01/12/04 Luca: Inserito per gestione pixel o Row/Column
         //Il contenuto degli item di tipo funzione con font troppo grande venivono troncati con "..."
         IF !_UseAlignment(::aCtrl) .AND.;
            EMPTY(::nBoxType)       .AND.;
            ! xVal == ::caption     .AND.;// .AND. LEN(xVal) != LEN(::caption)
            !S2PixelCoordinate(::aCtrl)

            aDim := S2StringDim(self, xVal )
         //IF EMPTY(::nBoxType) .AND. ! xVal == ::caption // .AND. LEN(xVal) != LEN(::caption)
         //   aDim := S2StringDim(self, xVal )
         //Fine Aggiunto

            aSize := ::currentSize()
            nDelta := aDim[1] - aSize[1]

            // Simone 3/10/2005
            // fa sempre il workaround per i "..."
            // altrimenti ci possono essere casi in cui viene visualizzato ugualmente
            // es. xVal="     12,00" la s2stringdim() ritorna aDim={72, 22} con tutti i 
            // workaround diventa {75, 22}
            // poi xVal="    820,00" la s2stringdim() ritorna aDim={75, 22} che Š uguale
            // al currentsize() quindi non fa il workaround ma dovrebbe farlo infatti
            // il {75, 22} diventerebbe {78, 22}
            IF .T. //nDelta != 0

               // Cancello il caption precedente
               // altrimenti dato che vario le dimensioni
               // quello che c'era prima rimane sotto
               ::SetCaption("")

               // aDim[1] := MAX(aDim[1], ::currentSize()[1])
               aDim[2] := MAX(aDim[2], aSize[2])

               IF dfAnd(::options,XBPSTATIC_TEXT_RIGHT) == 0
                  ::setSize(aDim)
               ELSE

               #ifdef _XBASE15_
                  // Workaround
                  aDim[1]++   // Incremento perchŠ altrimenti visualizza "..." finali
                  nDelta++    // quindi sposto a sinistra
                  IF ! ::isVisible() // altro casino.. se non Š visibile lo deve spostare ancora!
                     nDelta++
                  ENDIF

                  // Allineamento a Sinistra, devo spostare il control
                  ////////////////////////////////////////////////
                  // Modifica Luca del 2/03/2005
                  //Ho aggiunto un altro pixel perche avvolte si hanno ancora "..." finali
                  aDim[1]++   // Incremento perchŠ altrimenti visualizza 
                  ////////////////////////////////////////////////
                  // Modifica Luca del 2/03/2005
                  // Eseguo ricalcolo in base coordinate di posizioni iniziali rispetto a quelle relative calcolate via via.
                  // aPos := ::currentPos()
                  // aPos[1] -= nDelta
                  aPos   := ::currentPos()
                  aPos[1]:= aPosOrig[1] +(aSizeOrig[1] - aDim[1] )
                  ////////////////////////////////////////////////

                  ::setPosAndSize(aPos,aDim)

               #else

                  nDelta++    // sposto a sinistra

                  // Allineamento a destra, devo spostare il control
                  aPos := ::currentPos()
                  aPos[1] -= nDelta

                  ::setPos(aPos,.F.)
                  ::setSize(aDim)
               #endif

               ENDIF

               //::setSize(aDim)
               ::aInitSize := ::currentSize()
            ENDIF
         ENDIF

         ::SetCaption( xVal )
      ENDIF

   ENDIF

   // E' da perfezionare, non so se il size Š ok
   IF ::FormFather():hasBitmapBG()
      ::setParent():setParent():invalidateRect(       ;
         {  aPosOrig[1]                      ,  ;
            aPosOrig[2]+20                   ,  ;
            aPosOrig[1]+aSizeOrig[1]   ,  ;
            aPosOrig[2]+aSizeOrig[2]+30 } )

   ENDIF

   lRet := ::S2Static:DispItm() // (fcGrp, lRef)

   IF ::oPrompt != NIL
      IF ::CanShow()
         ::oPrompt:show()
      ELSE
         ::oPrompt:hide()
      ENDIF
      IF ::FormFather():hasBitmapBG()
         aPosOrig := ::oPrompt:Currentpos()
         aSizeOrig:= ::oPrompt:Currentsize() 
         ::setParent():setParent():invalidateRect(       ;
            {  aPosOrig[1]                      ,  ;
               aPosOrig[2]+20                   ,  ;
               aPosOrig[1]+aSizeOrig[1]   ,  ;
               aPosOrig[2]+aSizeOrig[2]+30 } )
      ENDIF
   ENDIF

   //Luca 03/09/2012
   ///////////////////////
   ::invalidateRect()
   ///////////////////////

RETURN lRet

// Imposta il testo del prompt
METHOD S2Func:setPromptCaption(x)
   LOCAL xRet
   IF ::nPromptMode == PM_INTERNAL
      xRet := ::S2Static:caption
      IF PCOUNT() > 0
         ::S2Static:setCaption(x)
      ENDIF

   ELSEIF ::oPrompt != NIL
      xRet := ::oPrompt:caption
      IF PCOUNT() > 0
         ::oPrompt:setCaption(x)
      ENDIF
   ENDIF
   //Luca 03/09/2012
   ///////////////////////
   ::invalidateRect()
   ///////////////////////

RETURN xRet

METHOD S2Func:setCaption(x)
   LOCAL lRet

   // WorkAround: se imposto una stringa "paolo & paolo"
   // a video ho "paolo _paolo" perchŠ la "&" sottolinea il
   // carattere seguente... per funzionare correttamente
   // devo mettere "&&"
#ifdef _ENABLE_SHOW_AS_GET_
   IF ::oText == NIL .OR. ::oText:isDerivedFrom("XbpStatic")
      IF ! EMPTY(x) .AND. VALTYPE(x) == "C"
         x:=STRTRAN(x, "&", "&&")
      ENDIF
   ENDIF
#else
   IF ! EMPTY(x) .AND. VALTYPE(x) == "C"
      x:=STRTRAN(x, "&", "&&")
   ENDIF
#endif

   IF ::oText == NIL
      lRet := ::S2Static:setCaption(x)
   ELSE
#ifdef _ENABLE_SHOW_AS_GET_
   IF ::oText:isDerivedFrom("XbpStatic")
      lRet := ::oText:setCaption(x)
   ELSE
      lRet := ::oText:setData(x)
   ENDIF
#else
      lRet := ::oText:setCaption(x)
#endif
   ENDIF
RETURN lRet

METHOD S2Func:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL cPrompt,aPpos,aPsize,oPos,aSize_Prompt, nGap
   LOCAL cStile   := dfSet(AI_XBASEGETSTYLE)
   LOCAL cColorFG := dfSet("XbaseGetDisabledColorFG")
   LOCAL cColorBG := dfSet("XbaseGetDisabledColorBG")
   LOCAL oXbp

   ::S2Static:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   IF ::oText != NIL
      DEFAULT aPP TO {}
      IF cColorBG != NIL 
         IF S2IsNumber(cColorBG)
            aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_BGCLR,VAL(cColorBG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_BGCLR, n)}, .T., cColorBG)
         ENDIF
      ENDIF
      IF cColorFG != NIL 
         IF S2IsNumber(cColorFG)
            aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_FGCLR,VAL(cColorFG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_FGCLR, n)}, .T., cColorFG)
         ENDIF
      ENDIF
      ::oText:Create(NIL,NIL ,NIL ,NIL ,aPP )
#ifdef _ENABLE_SHOW_AS_GET_
      IF ::oText:isDerivedFrom("XbpStatic")
         ///////////////////////////////////////////
         //Mantis 976
         IF cStile != GET_PS_STD
            ::createFancy2()
         ELSE
            IF ::nPromptMode == PM_INTERNAL
               S2ObjSetColors(::S2Static, ! ::FormFather():hasBitmapBG(), ::aCtrl[FORM_FUN_CLRPROMPT], APPCOLOR_FUNPROMPT )
            ENDIF 
         ENDIF
         ///////////////////////////////////////////
      ELSE
         // simone 28/5/08
         // mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
         IF dfSet(AI_XBASEDISABLEDGETCOPY) == AI_DISABLEDGETCOPY_NO
         ::oText:disable()
         ELSE
            oXbp := ::oText

            IF cColorBG != NIL 
               IF S2IsNumber(cColorBG)
                  ::oText:setColorBG(VAL(cColorBG))
               ELSE
                  S2ItmSetColors({|n|NIL}, {|n| oXbp:setColorBG(n)}, .T., cColorBG)
               ENDIF
            ENDIF

            IF cColorFG != NIL 
               IF S2IsNumber(cColorFG)
                  ::oText:setColorFG(VAL(cColorFG))
               ELSE
                  S2ItmSetColors({|n|NIL}, {|n| oXbp:setColorFG(n)}, .T., cColorFG)
               ENDIF
            ENDIF
         ENDIF
      ENDIF
#else
      ///////////////////////////////////////////
      //Mantis 976
      IF cStile != GET_PS_STD
         ::createFancy2()
      ENDIF
      ///////////////////////////////////////////
#endif
   ENDIF

   IF ::oBmp != NIL
      ::oBmpPS:create( self:windevice() )
      ::oBmp:create( ::oBmpPS )
   ENDIF

   IF ::oPrompt != NIL
      ::oPrompt:Create()
      // Mantis 707
      IF S2PixelCoordinate(::aCtrl) .AND. !EMPTY(::aCtrl[FORM_FUN_PROMPT]) .AND. LEN(::aCtrl[FORM_FUN_PROMPT]) > 0
         aPsize := ::oPrompt:CurrentSize()
         aPpos  := ::oPrompt:CurrentPos()

         oPos   := PosCvt():new(LEN(::aCtrl[FORM_FUN_PROMPT]), 1)
         aSize_Prompt := {oPos:nXWin ,aPsize[2]}
         //nGap => Distanza in pixel tra il promt e la get (sarebbe esprsso in caratteri x 8)
         DO CASE 
            CASE ::aCtrl[FORM_FUN_PROW] == ::aCtrl[FORM_FUN_TOP] .AND. ; 
                 ::aCtrl[FORM_FUN_PCOL] <  ::aCtrl[FORM_FUN_LEFT]       
                 nGap  := ::aCtrl[FORM_FUN_COL] - (::aCtrl[FORM_FUN_PCOL]+8*Len(StrTran(Trim(::aCtrl[FORM_FUN_PROMPT]),"^","")))
                 aPpos[1] :=  ::aCtrl[FORM_FUN_COL] - aPsize[1] - nGap

                 // Simone D. 1/3/07 
                 // mantis 0001211: le espressioni hanno il prompt allineato in alto rispetto all'espressione, sarebbe meglio centrarlo verticalmente
                 // centro verticalmente invece di allineare in alto
                 //aPpos[2] :=  ::S2Static:CurrentPos()[2]+::S2Static:CurrentSize()[2]-aPSize[2]
                 aPpos[2] :=  ::S2Static:CurrentPos()[2]+ ROUND( (::S2Static:CurrentSize()[2]-aPSize[2])/2, 0)

            CASE ::aCtrl[FORM_FUN_PROW] == ::aCtrl[FORM_FUN_TOP] .AND. ;
                 ::aCtrl[FORM_FUN_PCOL] >  ::aCtrl[FORM_FUN_LEFT] 
                 aPpos[1] :=  (aPsize[1]-aSize_Prompt[1]) +::aCtrl[FORM_FUN_PCOL] 

                 // Simone D. 1/3/07 
                 // mantis 0001211: le espressioni hanno il prompt allineato in alto rispetto all'espressione, sarebbe meglio centrarlo verticalmente
                 // centro verticalmente invece di allineare in alto
                 //aPpos[2] :=  ::S2Static:CurrentPos()[2]+::S2Static:CurrentSize()[2]-aPSize[2]
                 aPpos[2] :=  ::S2Static:CurrentPos()[2]+ ROUND( (::S2Static:CurrentSize()[2]-aPSize[2])/2, 0)

            CASE ::aCtrl[FORM_FUN_PROW] >  ::aCtrl[FORM_FUN_TOP] .AND. ;
                 ::aCtrl[FORM_FUN_PCOL] >= ::aCtrl[FORM_FUN_LEFT] 
                 aPpos[1] :=  ::aCtrl[FORM_FUN_PCOL] 
                 aPpos[2] :=  ::S2Static:CurrentPos()[2]+::S2Static:CurrentSize()[2] +1
            CASE ::aCtrl[FORM_FUN_PROW] <  ::aCtrl[FORM_FUN_TOP] .AND. ;
                 ::aCtrl[FORM_FUN_PCOL] >= ::aCtrl[FORM_FUN_LEFT] 
                 aPpos[1] :=  ::aCtrl[FORM_FUN_PCOL] 
                 aPpos[2] :=  ::S2Static:CurrentPos()[2] -aPSize[2] -1
         ENDCASE
         ::oPrompt:SetPos(aPpos)
         ::oPrompt:Show()
      ENDIF
   ENDIF
RETURN self

METHOD S2Func:destroy()
   ::xBitmap := NIL
   IF ::oBmp != NIL
      ::oBmp:destroy()
   ENDIF
   IF ::oBmpPS != NIL
      ::oBmpPS:destroy()
   ENDIF
   ::S2Static:destroy()
RETURN self

METHOD S2Func:paint(aRect)
   LOCAL aSource
   LOCAL aTarget
   LOCAL nAspect
   LOCAL aSize := ::currentSize()
   LOCAL lCenter
   LOCAL nBitmap

   IF ::oBmp != NIL
      //::oBmp:draw(::oBmpPS, {0,0})
       nBitmap := ::nBitmap
       lCenter := dfAnd(nBitmap, FUN_BMP_CENTER) != 0
       IF lCenter
          nBitmap -= FUN_BMP_CENTER
       ENDIF

      /*
       * A bitmap file is loaded
       */
       aSource := {0,0,::oBmp:xSize,::oBmp:ySize}
       aTarget := {1,1,aSize[1]-2,aSize[2]-2}
       DO CASE
          CASE nBitmap == FUN_BMP_STRETCH

          CASE nBitmap == FUN_BMP_SCALE

             /*
              * Bitmap is scaled to the size of ::oCanvas
              */
              IF aSource[3] == 0 .OR. aSource[4]  == 0

              ELSE
                 nAspect    := aSource[3] / aSource[4]
                 IF nAspect > 1
                    aTarget[4] := aTarget[3] / nAspect
                 ELSE
                    aTarget[3] := aTarget[4] * nAspect
                 ENDIF
              ENDIF

          CASE nBitmap == FUN_BMP_NORMAL
              aTarget[3] := aSource[3]
              aTarget[4] := aSource[4]

          CASE nBitmap == FUN_BMP_AUTOSIZE
              aTarget := {0,0, aSource[3], aSource[4]}

       ENDCASE

       IF lCenter

          /*
           * Center bitmap horizontally or vertically in ::oCanvas
           */
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
       ELSEIF nBitmap != FUN_BMP_AUTOSIZE
           IF aTarget[3] < aSize[1]-2
              nAspect := ( aSize[1]-2-aTarget[3] )
              aTarget[1] += nAspect
              aTarget[3] += nAspect
           ENDIF

           IF aTarget[4] < aSize[2]-2
              nAspect := ( aSize[2]-2-aTarget[4] )
              aTarget[2] += nAspect
              aTarget[4] += nAspect
           ENDIF
       ENDIF
       ::oBmp:draw( ::oBmpPS, aTarget, aSource, , GRA_BLT_BBO_IGNORE )

   ENDIF
   ::S2Static:paint(aRect)

   //Luca 03/09/2012
   ///////////////////////
   //::invalidateRect() // da problemi di refresh enormi.
   ///////////////////////

RETURN self

METHOD S2Func:resize(aOld, aNew)
   ::S2Static:resize(aOld, aNew)
   IF ::oText != NIL .AND. ::aTextOffsets != NIL
      aNew[1] -= ::aTextOffsets[3]
      aNew[2] -= ::aTextOffsets[4]
      ::oText:setSize(aNew, .F.)
   ENDIF
   ::invalidateRect()
RETURN self

STATIC FUNCTION _UseAlignment(aCtrl)
RETURN LEN(aCtrl)>= FORM_FUN_ALIGNMENT_TYPE .AND.;
       aCtrl[FORM_FUN_ALIGNMENT_TYPE] >= 0
//.AND.;
//       !EMPTY(aCtrl[FORM_FUN_ALIGNMENT_TYPE])
