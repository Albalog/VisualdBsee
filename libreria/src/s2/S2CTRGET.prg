#include "dfCtrl.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "Font.ch"
#include "dfMenu.ch"
#include "dfXBase.ch"
#include "Common.ch"
#include "AppEvent.ch"
#include "dfXRes.ch"
#include "dfLook.ch"

MEMVAR ACT, A, SA


// simone 02/07/07 funzionante ma per ora non attivo
// mantis 0001248: potrebbe essere comodo implementare una funzionalit… di autofill
#define _ENABLE_AUTOFILL_

// Simone 28/3/08
// mantis 0001804: visualizzare un pulsante accanto a campi numero/data per visualizzare calcolatrice e calendario
#define _ENABLE_HELPBTN_

// simone 14/11/06
// mantis 0001167: implementare evidenziazione dei campi obbligatori
#define MANDATORY_OFFSET_X          2
#define MANDATORY_OFFSET_Y          2

// simone 14/11/06
// abilita cambio colore per GET con focus
// #define _S2CTRGET_HILITE_ 

// simone 1/6/05
// mantis 0000760: abilitare nuovi stili per i controls
// Aggiunto BORDINO sottile
// con caratteristica nPaintstyle
//
#define _USA_STILE_STATIC

#ifdef _USA_STILE_STATIC

// Classe di supporto per utilizzo tooltip anche
// con colori di GET disabilitati personalizzati

STATIC CLASS _GetSupport FROM S2ShadowText
   EXPORTED:
      VAR cMsg
      METHOD init
ENDCLASS

METHOD _GetSupport:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2ShadowText:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
//   ::type := XBPSTATIC_TYPE_FGNDFRAME
   ::type := XBPSTATIC_TYPE_BGNDFRAME
RETURN self
#endif


#ifdef _USA_BITMAP
// Classe di supporto per utilizzo tooltip anche
// con colori di GET disabilitati personalizzati
STATIC CLASS _GetSupport FROM XbpStatic
   EXPORTED:
      VAR cMsg

      VAR oInside

      VAR oBmp
      METHOD paintBack
      METHOD destroy
      METHOD init
      METHOD create

      METHOD enable
      METHOD disable

ENDCLASS

METHOD _GetSupport:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::XbpStatic:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::type := XBPSTATIC_TYPE_FGNDRECT
RETURN self

METHOD _GetSupport:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::XbpStatic:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::oInside := XbpStatic():new(self, NIL, {1, 1}, {::currentSize()[1]-2, ::currentSize()[2]-2} )
RETURN self

METHOD _GetSupport:enable()
RETURN ::oInside:enable()

METHOD _GetSupport:disable()
RETURN ::oInside:disable()

METHOD _GetSupport:destroy()
   ::XbpStatic:destroy()

   IF ::oBmp != NIL
      IF ::oBmp:status() == XBP_STAT_CREATE
         ::oBmp:destroy()
      ENDIF
      ::oBmp := NIL
   ENDIF

   IF ::oInside != NIL
      IF ::oInside:status() == XBP_STAT_CREATE
         ::oInside:destroy()
      ENDIF
      ::oInside := NIL
   ENDIF
RETURN self

METHOD _GetSupport:paintBack(nPaintStyle, nLineWidth, xFG, xBG, aRound)
   LOCAL oPS //:= ::lockPS()
   LOCAL aSz //:= ::currentSize()
   LOCAL aAttr
   //LOCAL lHasFocus := ::hasFocus() //SetAppFocus()==::oSle .AND. ::oSle:editable
   LOCAL oBmp

   IF ::oBmp != NIL
      IF ::oBmp:status() == XBP_STAT_CREATE
         ::oBmp:destroy()
      ENDIF
      ::oBmp := NIL
   ENDIF

   IF nPaintStyle == GET_PS_STD
      RETURN self
   ENDIF

   IF ! ::status()==XBP_STAT_CREATE
      RETURN self
   ENDIF

   oBmp := dfBMPPaintBack(::currentSize(), nPaintStyle, nLineWidth, xFG, xBG, aRound)

   ::setCaption(oBmp)
   ::oBmp := oBmp
RETURN self
#endif

// CLASS S2PromptGet
//    EXPORTED:
//    VAR oPrompt, oGet
//    METHOD:Init()
// RETURN self


// S2Get: CTRL_GET
// ---------------
CLASS S2Get FROM XbpGet, S2Control, S2CompGrp, S2EditCtrl, S2PfkCtrl, S2GetNumeric

   PROTECTED:
      VAR _oComboStatic // oggetto STATIC per contenere il pulsante di lookup in modo che se disabilito il pulsante l'icona rimane visibile e non grigia
      VAR oStatic
      VAR oComboSle
      VAR lDispLoop, lCalcSizeOnDisplay, lFirstChar, lNumericInput, cNumPicture
      VAR nPaintStyle
#ifdef _ENABLE_AUTOFILL_
      VAR oAutoFill
#endif

      METHOD CtrlArrInit, DispItmCalcSize
      METHOD setDateFromCalendar, setNumericPicture

      METHOD getCheckBorderColor
      METHOD getMandatoryBackgroundColor
      METHOD combocreate

#ifdef _ENABLE_HELPBTN_
      CLASS VAR oBtnHelp
      CLASS VAR nBtnHelp        // tipo di pulsante da attivare (corrisponde al dfSet("XbaseGetAutoHelpBtn"))
      METHOD setBtnHelp
      CLASS METHOD hideBtnHelp
#endif

   EXPORTED:
      VAR bActive, bCond, bSys, oCombo, oPrompt, cMsg, cRefGrp, cInitVal
      VAR nDisabledColorFG, nDisabledColorBG, lExtCmb, lComboEnabled
      VAR nEnabledColorFG, nEnabledColorBG
      METHOD Init, DispItm, SetInputFocus, KillInputFocus, Create, destroy
      METHOD SetFocus, hasFocus, CanSetFocus, enable, disable
      METHOD Keyboard
      METHOD IsActive, PreGet, PostGet, ChkGet, getData, isShortCut //, setData
      METHOD lbDblClick
      METHOD _Create
      METHOD UpdControl, setPos, setSize, currentPos, setParent, setOwner, show, hide, isEnabled, setPosAndSize
      METHOD GETMANDATORYFOREGROUNDCOLOR

#ifdef _ENABLE_HELPBTN_
      // Simone 10/4/08
      // 0001812: migliorare il pulsante automatico per attivare la calcolatrice
      CLASS VAR bBtnHelpCheck   // codeblock per verificare se abilitare il pulsante
      CLASS VAR bBtnHelpEval    // codeblock valutato quando si clicca sul pulsante di help

      METHOD btnHelp
#endif

#ifdef _ENABLE_AUTOFILL_
      INLINE METHOD setMarked(a)
         ::XbpSle:setMarked(a)
         IF ::oAutoFill != NIL
         ::get:pos := a[1]
         ENDIF 
      RETURN .T.
      /////////////////////////////////////////////////////////////////
      //Aggiunta la possibilit… di prevalorizzare le get con Autofill dall'esterno
      /////////////////////////////////////////////////////////////////
      //Mantis 2136
      INLINE METHOD ADDAutoFillText(cText)
        IF Empty(cText)
           RETURN ::oAutoFill
        ENDIF 
        IF dfSet("XbaseGetAutoFill")=="STD" .AND.;
           ::aCtrl[FORM_GET_ALIGNMENT_TYPE]  == XBPALIGN_AUTOFILL
           ::oAutoFill:TextAdd(TRANSFORM(cText, ::picture))
        ENDIF
       // ::oAutoFill:TextAdd(TRANSFORM(cText, ::picture))
      RETURN ::oAutoFill
      /////////////////////////////////////////////////////////////////

#endif

      // METHOD HandleEvent
ENDCLASS

METHOD S2Get:setPosAndSize(aPos, aSize, lPaint)
   ::setPos(aPos, lPaint)
   ::setSize(aSize, lPaint)
RETURN .T.

METHOD S2Get:setPos(aPos, lPaint)
   LOCAL lRet
   LOCAL nXDiff
   LOCAL aCurPos
   //   LOCAL oObj := IIF(::oStatic == NIL, ::XbpGet, ::oStatic)

   DEFAULT lPaint TO .T.

   IF ::oCombo != NIL .AND. ::lExtCmb
      nXDiff := ::oCombo:currentPos()[1] - ::currentPos()[1]
   ENDIF

   IF ::oPrompt != NIL 
      aCurPos := ::currentPos()
      aCurPos[1] := ::oPrompt:currentPos()[1] - aCurPos[1]
      aCurPos[2] := ::oPrompt:currentPos()[2] - aCurPos[2]
      ::oPrompt:setPos({aPos[1]+aCurPos[1], aPos[2]+aCurPos[2]}, lPaint)
   ENDIF

   IF ::oStatic == NIL
      lRet := ::XbpGet:setPos(aPos, lPaint)
   ELSE
      lRet := ::oStatic:setPos(aPos, lPaint)
   ENDIF

   IF lRet .AND. nXDiff != NIL
      aPos[1] += nXDiff
      ::oCombo:setPos(aPos)
   ENDIF
RETURN lRet

METHOD S2Get:currentPos()
   // LOCAL oObj := IIF(::oStatic == NIL, ::XbpGet, ::oStatic)
   LOCAL aRet

   IF ::oStatic == NIL
      aRet := ::XbpGet:currentPos()
   ELSE
      aRet := ::oStatic:currentPos()
   ENDIF
RETURN aRet

METHOD S2Get:isEnabled()
   LOCAL lRet

   IF ! ::editable
      lRet := .F.
   ELSEIF ::oStatic == NIL
      lRet := ::XbpGet:isEnabled()
   ELSE
      lRet := ::oStatic:isEnabled()
   ENDIF
RETURN lRet

METHOD S2Get:setParent(o)
   LOCAL oRet
   // LOCAL oObj := IIF(::oStatic == NIL, ::XbpGet, ::oStatic)

   IF PCOUNT() > 0
      IF ::oStatic == NIL
         oRet := ::XbpGet:setParent(o)
      ELSE
         oRet := ::oStatic:setParent(o)
      ENDIF
      IF ::oPrompt != NIL
         ::oPrompt:setParent(o)
      ENDIF
      IF ::oCombo != NIL .AND. ::lExtCmb
         ::oCombo:setParent(o)
      ENDIF

   ELSE
      IF ::oStatic == NIL
         oRet := ::XbpGet:setParent()
      ELSE
         oRet := ::oStatic:setParent()
      ENDIF
   ENDIF
RETURN oRet

METHOD S2Get:setOwner(o)
   LOCAL oRet
   // LOCAL oObj := IIF(::oStatic == NIL, ::XbpGet, ::oStatic)

   IF PCOUNT() > 0
      IF ::oStatic == NIL
         oRet := ::XbpGet:setOwner(o)
      ELSE
         oRet := ::oStatic:setOwner(o)
      ENDIF
   ELSE
      IF ::oStatic == NIL
         oRet := ::XbpGet:setOwner()
      ELSE
         oRet := ::oStatic:setOwner()
      ENDIF
   ENDIF
RETURN oRet

METHOD S2Get:setSize(aSize, lPaint)
   LOCAL lRet
   LOCAL aPos
   LOCAL nXDiff

   DEFAULT lPaint TO .T.

   IF ::oCombo != NIL
      IF ::lExtCmb
         nXDiff := ::oCombo:currentPos()[1] - ::currentPos()[1]
      ELSE
         nXDiff := ::oCombo:currentPos()[1] - ::currentSize()[1]
      ENDIF
   ENDIF

   lRet := ::XbpGet:setSize(aSize, lPaint)
   IF ::oStatic != NIL
      // SimoD 12/02/07 fix per resize GET evidenziate
      IF ::getCheckBorderColor() != NIL
         lRet := ::oStatic:setSize({aSize[1]+MANDATORY_OFFSET_X*2, aSize[2]+MANDATORY_OFFSET_Y*2}, lPaint)
      ELSE
         lRet := ::oStatic:setSize(aSize, lPaint)
      ENDIF
   ENDIF

   IF lRet .AND. nXDiff != NIL
      IF ::lExtCmb
         aPos := ::currentPos()
      ELSE
         aPos := ACLONE(aSize)
         aPos[2] := ::oCombo:currentPos()[2]
      ENDIF
      aPos[1] += nXDiff
      aSize[1] := ::oCombo:currentSize()[1]
      ::oCombo:setPosAndSize(aPos, aSize)
   ENDIF
RETURN lRet

// ritorna il colore del bordo per evidenziare la GET
// o NIL se la GET non deve essere evidenziata
METHOD S2Get:getCheckBorderColor()
   LOCAL xClr

//   IF ::aCtrl[FORM_GET_CHECKS] == GET_CHK_NOCHECK
//      RETURN NIL
//   ENDIF

   IF ! ::aCtrl[FORM_GET_CHECKS] == GET_CHK_MANDATORY  // evidenzio solo campi obbligatori
      RETURN NIL
   ENDIF

   IF ! dfSet("XbaseMandatoryFieldsMode") == "1" .AND. ! dfSet("XbaseMandatoryFieldsMode") == "3"
      RETURN NIL
   ENDIF

   xClr := dfSet("XbaseMandatoryBorderColor")
   IF !EMPTY(xClr)
      xClr := S2DbseeColorToRGB(xClr, .T.)
   ENDIF
   IF EMPTY(xClr)
      xClr := GRA_CLR_RED
   ENDIF

RETURN xClr

METHOD S2Get:getMandatoryBackgroundColor()
   LOCAL xClr


   IF ! ::aCtrl[FORM_GET_CHECKS] == GET_CHK_MANDATORY  // evidenzio solo campi obbligatori
      RETURN NIL
   ENDIF

   IF ! dfSet("XbaseMandatoryFieldsMode") == "2" .AND. ! dfSet("XbaseMandatoryFieldsMode") == "3"
      RETURN NIL
   ENDIF

   xClr := dfSet("XbaseMandatoryBackgroundColor") 
   IF !EMPTY(xClr)
      xClr := S2DbseeColorToRGB(xClr, .T.)
   ENDIF
   IF EMPTY(xClr)
      xClr := GRA_CLR_CYAN
   ENDIF

RETURN xClr

//Luca 13/05/2008 
//Mantis 1857
METHOD S2Get:GETMANDATORYFOREGROUNDCOLOR()
   LOCAL xClr


   IF ! ::aCtrl[FORM_GET_CHECKS] == GET_CHK_MANDATORY  // evidenzio solo campi obbligatori
      RETURN NIL
   ENDIF

   IF ! dfSet("XbaseMandatoryFieldsMode") == "2" .AND. ! dfSet("XbaseMandatoryFieldsMode") == "3"
      RETURN NIL
   ENDIF

   //Mantis 1857
   //xClr := dfSet("XbaseMandatoryFordergroundColor") 
   xClr := dfSet("XbaseMandatoryForegroundColor") 
   //Per compatibilit… con la stringa errata usata fino ad oggi: 24/09/2010
   IF EMPTY(xClr)
     xClr := dfSet("XbaseMandatoryFordergroundColor") 
   ENDIF 
   IF !EMPTY(xClr)
      xClr := S2DbseeColorToRGB(xClr, .T.)
   ENDIF
   //Si lascia il default
   //IF EMPTY(xClr)
   //   xClr := GRA_CLR_BLACK
   //ENDIF

RETURN xClr



METHOD S2Get:show()
   LOCAL lRet
   ::XbpGet:show()

   IF ::oStatic != NIL
      lRet := ::oStatic:show()
   ENDIF

   IF ::oPrompt != NIL
      ::oPrompt:show()
   ENDIF

   IF ::oCombo != NIL .AND. ::lExtCmb
      lRet := ::oCombo:show()
   ENDIF
RETURN lRet

METHOD S2Get:hide()
   LOCAL lRet
   ::XbpGet:hide()

   IF ::oStatic != NIL
      lRet := ::oStatic:hide()

      // E' da perfezionare, non so se il size e' ok
      // Serve per evitare che una condizione di VISUALIZZA se non funzioni
      IF ::FormFather():hasBitmapBG()
         ::setParent():setParent():invalidateRect(       ;
            {  ::oStatic:currentPos()[1]                      ,  ;
               ::oStatic:currentPos()[2]+22                   ,  ;
               ::oStatic:currentPos()[1]+::oStatic:currentSize()[1]   ,  ;
               ::oStatic:currentPos()[2]+::oStatic:currentSize()[2]+22 } ;
                                                 )
      ENDIF

   ENDIF

   IF ::oPrompt != NIL
      ::oPrompt:hide()

      // E' da perfezionare, non so se il size e' ok
      // Serve per evitare che una condizione di VISUALIZZA se non funzioni
      IF ::FormFather():hasBitmapBG()
         ::setParent():setParent():invalidateRect(       ;
            {  ::oPrompt:currentPos()[1]                      ,  ;
               ::oPrompt:currentPos()[2]+20                      ,  ;
               ::oPrompt:currentPos()[1]+::oPrompt:currentSize()[1]   ,  ;
               ::oPrompt:currentPos()[2]+::oPrompt:currentSize()[2]+20    } ;
                                                 )
      ENDIF
   ENDIF

   IF ::oCombo != NIL .AND. ::lExtCmb
      lRet := ::oCombo:hide()
   ENDIF
RETURN lRet


METHOD S2Get:CtrlArrInit(aCtrl, oFormFather )
   ASIZE(aCtrl, FORM_GET_CTRLARRLEN)
   IF EMPTY aCtrl[FORM_GET_PICTUREGET] ASSIGN aCtrl[FORM_GET_PICTURESAY]
   IF EMPTY aCtrl[FORM_GET_PICTURESAY] ASSIGN aCtrl[FORM_GET_PICTUREGET]
   IF EMPTY aCtrl[FORM_GET_PICTUREGET] ASSIGN ""
   IF EMPTY aCtrl[FORM_GET_PICTURESAY] ASSIGN ""
   DEFAULT aCtrl[FORM_GET_ACT]        TO ""
   DEFAULT aCtrl[FORM_GET_CONDITION]  TO {||.T.}
   DEFAULT aCtrl[FORM_GET_COMPEXP]    TO {||.T.}
   DEFAULT aCtrl[FORM_GET_GAP]        TO 0
   DEFAULT aCtrl[FORM_GET_SYS]        TO {||NIL}
   DEFAULT aCtrl[FORM_GET_ACTIVE]     TO {||.T.}
   DEFAULT aCtrl[FORM_GET_COMBO]      TO .F.

   aCtrl[FORM_GET_CTRLGRP] := dfChkGrp(aCtrl[FORM_GET_CTRLGRP])

   DEFAULT aCtrl[FORM_GET_CVAR]       TO ""
   DEFAULT aCtrl[FORM_GET_MESSAGE]    TO ""
   DEFAULT aCtrl[FORM_GET_CLRID]      TO {}
   ASIZE( aCtrl[FORM_GET_CLRID], 6 )
   IF EMPTY aCtrl[FORM_GET_CLRPROMPT] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_PROMPT   ]
   IF EMPTY aCtrl[FORM_GET_CLRHOTKEY] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_HOTPROMPT]
   IF EMPTY aCtrl[FORM_GET_CLRDATA  ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_GETNORMAL]
   IF EMPTY aCtrl[FORM_GET_CLRHILITE] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_CURSOR   ]
   IF EMPTY aCtrl[FORM_GET_CLRICON  ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_GETCOMBO ]
   IF EMPTY aCtrl[FORM_GET_PROMPT]    ASSIGN ""

   DEFAULT aCtrl[FORM_GET_PFK]        TO {}

   IF aCtrl[FORM_GET_COMPEXP]#NIL
      oFormFather:_tbUpdExp( aCtrl[FORM_GET_COMPGRP], aCtrl[FORM_CTRL_ID] )
   ENDIF
   //IF LEN(aCtrl)>=  FORM_GET_ALIGNMENT_TYPE
   //   DEFAULT aCtrl[FORM_GET_ALIGNMENT_TYPE] TO XBPALIGN_TOP + XBPALIGN_LEFT
   //ENDIF                                        
   DEFAULT aCtrl[FORM_GET_ALIGNMENT_TYPE]  TO XBPALIGN_DEFAULT
   IF EMPTY aCtrl[FORM_GET_PAINTSTYLE]  ASSIGN dfSet(AI_XBASEGETSTYLE)

#ifndef _NOFONT_
   //ASIZE(aCtrl, FORM_GET_CTRLARRLEN)
   aCtrl[FORM_GET_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_GET_FONTCOMPOUNDNAME ])
   aCtrl[FORM_GET_PFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_GET_PFONTCOMPOUNDNAME ])
   IF EMPTY aCtrl[FORM_GET_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseGetFont")
   IF EMPTY aCtrl[FORM_GET_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseCtrlFont")
   IF EMPTY aCtrl[FORM_GET_FONTCOMPOUNDNAME ] ASSIGN APPLICATION_FONT
   IF aCtrl[FORM_GET_FONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_GET_FONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_GET_FONTCOMPOUNDNAME ]))
      aCtrl[FORM_GET_FONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_GET_FONTCOMPOUNDNAME ])  
   ENDIF

   IF EMPTY aCtrl[FORM_GET_PFONTCOMPOUNDNAME ] ASSIGN dfSet("XbasePromptGetFont")
   IF EMPTY aCtrl[FORM_GET_PFONTCOMPOUNDNAME ] ASSIGN aCtrl[FORM_GET_FONTCOMPOUNDNAME ]
   IF aCtrl[FORM_GET_PFONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_GET_PFONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_GET_PFONTCOMPOUNDNAME ]))
      aCtrl[FORM_GET_PFONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_GET_PFONTCOMPOUNDNAME ]) 
   ENDIF

   // simone 14/11/06
   // mantis 0001167: implementare evidenziazione dei campi obbligatori
   DEFAULT aCtrl[FORM_GET_CHECKS] TO GET_CHK_NOCHECK
#endif

RETURN

METHOD S2Get:updControl(aCtrl)

   DEFAULT aCtrl TO ::aCtrl

   ::S2Control:updControl(aCtrl)

   ::Datalink := ::aCtrl[FORM_GET_VAR]
   ::picture  := UPPER(::aCtrl[FORM_GET_PICTUREGET])

   ::unReadable := .F.
   IF ! EMPTY(::picture)

      // IF "@S" $ UPPER(::picture) // Tolgo "@Snn"
      //
      // ENDIF

      IF "@P" $ ::picture                // Password
         ::picture := STRTRAN(::picture, "@P")
         ::unReadable := .T.
      ENDIF
   ENDIF
   //::get:picture := ::picture

   // Se Š gi… stato creato aggiorno la picture altrimenti verr…
   // impostata alla creazione
   IF ! ::status() == XBP_STAT_INIT

      IF EMPTY(::picture) .OR. (! ".9" $ ::picture) // se non ha decimali annullo il decPos
         ::get:setDecPos( 0 )
      ENDIF

      IF ::get:HasFocus
         ::get:killFocus()
//         ::initGet() simone 12/6/06 il metodo XbpGet:initGet() non esiste piu
//                     mantis 0001086: errore runtime su metodo s2get:updcontrol()
         //::get:Picture := ::picture
         ::get:setFocus()
      ELSE
//         ::initGet() simone 12/6/06 il metodo XbpGet:initGet() non esiste piu
//                     mantis 0001086: errore runtime su metodo s2get:updcontrol()
         //::get:Picture := ::picture
      ENDIF

      ::lNumericInput :=  ::get:TYPE=="N" .AND. ("@J" $ ::picture .OR. ;
                                                    dfSet( AI_CALCULATORGET ) )

      ::setNumericPicture()

   ENDIF

   ::bActive  := ::aCtrl[FORM_GET_ACTIVE]
   ::bCond    := ::aCtrl[FORM_GET_CONDITION]
   ::cMsg     := ::aCtrl[FORM_GET_MESSAGE]

   IF ::oStatic != NIL
      ::oStatic:cMsg := ::cMsg
   ENDIF

   ::cRefGrp  := ::aCtrl[FORM_GET_CTRLGRP]
   ::bSys     := ::aCtrl[FORM_GET_SYS]

   S2ObjSetColors(self, .T., aCtrl[FORM_GET_CLRDATA], APPCOLOR_GET)

   IF ::oPrompt != NIL
      ::oPrompt:setCaption( ::ChgHotKey( ::aCtrl[FORM_GET_PROMPT] ) )
      S2ObjSetColors(::oPrompt, ! ::FormFather():hasBitmapBG(), aCtrl[FORM_GET_CLRPROMPT], APPCOLOR_GETPROMPT)
   ENDIF

#ifndef _NOFONT_
   aCtrl[FORM_GET_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_GET_FONTCOMPOUNDNAME ])
   aCtrl[FORM_GET_PFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_GET_PFONTCOMPOUNDNAME ])

   ::UpdObjFont( aCtrl[FORM_GET_FONTCOMPOUNDNAME  ] )
   IF ::oPrompt != NIL
      ::UpdObjFont( aCtrl[FORM_GET_PFONTCOMPOUNDNAME  ], ::oPrompt )
   ENDIF
#endif

RETURN self


METHOD S2Get:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos, oXbp,  aSize_Prompt, aSize_Butt, aPos_Butt
   LOCAL nLen
   LOCAL lBorder  := ! (dfSet("XbaseGetBorder") == "NO")
   LOCAL cColorFG := dfSet("XbaseGetDisabledColorFG")
   LOCAL cColorBG := dfSet("XbaseGetDisabledColorBG")
   LOCAL aParam
   LOCAL oDmmPos
   LOCAL nHeight  := dfSet("XbaseGetDefaultHeight")   // altezza di default GET (per autoform)

   ::lExtCmb := dfSet("XbaseGetComboExternal") == "YES"

   ::CtrlArrInit(aCtrl, oFormFather )
   nLen := dfPictLen(aCtrl[FORM_GET_PICTUREGET])

   ::nPaintStyle := aCtrl[FORM_GET_PAINTSTYLE]
   IF ::nPaintStyle != GET_PS_STD
      lBorder := .F.
   ENDIF

   IF nHeight != NIL
      nHeight := VAL(nHeight)
   ENDIF

//   IF dfSet("XbaseGetBorder") == "FLAT"
//      lBorder := .F.
//      ::nPaintStyle := PS_BORDER
//   ELSEIF dfSet("XbaseGetBorder") == "ROUND"
//      lBorder := .F.
//      ::nPaintStyle := PS_ROUNDBORDER
//   ELSE
//      ::nPaintStyle := PS_STD
//   ENDIF

   // Se non ho una picture oppure Š una picture del tipo "@!"
   // non posso sapere la larghezza reale e rimando tutto al primo display
   ::lCalcSizeOnDisplay := EMPTY(nLen)

   // In caso di larghezza <= 2 allargo leggermente

   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF S2PixelCoordinate(aCtrl)
      ::lCalcSizeOnDisplay := .F.
      DEFAULT aPos  TO {aCtrl[FORM_GET_COL], aCtrl[FORM_GET_ROW]}
      IF LEN(aCTRL) >= FORM_GET_SIZE        
         //Mantis 737 Luca
         //DEFAULT aSize TO aCtrl[FORM_GET_SIZE]
         IF !EMPTY(aCtrl[FORM_GET_SIZE]) .AND. VALTYPE(aCtrl[FORM_GET_SIZE]) =="A"
            DEFAULT aSize TO ACLONE(aCtrl[FORM_GET_SIZE])
         ENDIF
         ::lCalcSizeOnDisplay := .F.
      ENDIF
      IF EMPTY(aSize)
         oPos := PosCvt():new(nLen, 1)
         DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}
      ENDIF

      //Mantis 658
      //In Visual dBsee ho disabilito il combo box con bottone esterno. Non serve pi—.
      /////////////////
      IF ::nPaintStyle == GET_PS_STD
         ::lExtCmb := .F.
      ELSE
         ::lExtCmb := dfSet("XbaseGetComboExternal") == "YES"
      ENDIF
  
      IF ::lExtCmb .AND. aCtrl[FORM_GET_COMBO]
         oDmmPos := PosCvt():new(2,1)
         aSize_Butt := { oDmmPos:nXWin, aSize[2] }

         aSize[1] -= aSize_butt[1]
      ENDIF
      //////////////////

   ELSE
      IF nLen <= 1
         nLen++

      ELSEIF nLen == 2
         //Luca 13/05/2005
         //E' un po troppo piccolo lo spazio per inserire due letere del tipo "WW"
         // utilizzato nelle dfAutoForm
         IF (dfSet("XbaseGetFixTwoCharLength") == "YES")
            nLen := 3
         ELSE
            nLen := 2.5
         ENDIF
         //nLen := 2.5
      ELSEIF nLen == 3
         IF (dfSet("XbaseGetFixThreeCharLength") == "YES")
            nLen := 4
         ELSE
            nLen := 3
         ENDIF
      ENDIF

      IF aCtrl[FORM_GET_COMBO] .AND. ! ::lExtCmb
         nLen += 2
      ENDIF

      oPos := PosCvt():new(nLen, 1)
      DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}

      oPos := PosCvt():new(aCtrl[FORM_GET_COL], aCtrl[FORM_GET_ROW]+1)
      oPos:Trasla(oParent)


      DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}

      // Simone 10/01/08
      // mantis 0001552: rivedere form gestite con dfAutoForm e S2AutoForm
      IF nHeight != NIL
         aPos[2]  += ROUND((aSize[2]-nHeight)/2, 0) // centro verticalmente
         aSize[2] := nHeight
      ENDIF

   ENDIF

   DEFAULT lVisible TO .F.

   // Se non c'Š bordo stringo i limiti sup/inf di 2 pixel
   IF ::nPaintStyle == GET_PS_STD .AND. ! lBorder
      aPos[2]+=2
      aSize[2]-=4
   ENDIF
   
   IF dfWinIs95()
      DO CASE
         // IN Windows 95 pare che il singolo carattere non si veda
         CASE aSize[1]>=8 .AND. aSize[1]<=16
              aSize[1]+=4
         CASE aSize[1]>16 .AND. aSize[1]<=24
              aSize[1]+=2
         CASE aSize[1]>24 .AND. aSize[1]<=32
              aSize[1]+=2
      ENDCASE
   ELSE
      DO CASE
         CASE aCtrl[FORM_GET_COMBO] .AND. ! ::lExtCmb
             // se c'Š il COMBO interno non allargo ancora
             // altrimenti Š troppo largo

         // Modificato Simone 4/10/01 per campo con
         // 5 caratteri che non vis. tutti i caratteri
         //CASE aSize[1]>=24 .AND. aSize[1]<=32
         CASE aSize[1]>=24 .AND. aSize[1]<=40
              aSize[1]+=4
      ENDCASE
   ENDIF


#ifndef _NOFONT_
   IF ! EMPTY(aCtrl[FORM_GET_FONTCOMPOUNDNAME])
      DEFAULT aPP TO {}
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_GET_FONTCOMPOUNDNAME])
      // AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_GET_FONTCOMPOUNDNAME]})
   ENDIF
#endif

   DEFAULT aPP TO {}
   aPP := S2PPSetColors(aPP, {.T., 0}, aCtrl[FORM_GET_CLRDATA], APPCOLOR_GET)

   // -----------------------
   // Inizializza l'oggetto
   // ---------------------
  #ifdef _XBASE15_
   // Questo usa meno risorse.. ma se Š definito anche cColorFG non verr… usato
   IF cColorBG != NIL
      DEFAULT aPP TO {}
      IF cColorBG != NIL 
         IF S2IsNumber(cColorBG)
            aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_BGCLR,VAL(cColorBG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_BGCLR, n)}, .T., cColorBG)
         ENDIF
         // AADD(aPP, {XBP_PP_DISABLED_BGCLR, VAL(cColorBG)})
      ENDIF
   ENDIF
  #endif

   aParam := {oParent, oOwner, aPos, aSize, aPP, lVisible}
   ::XbpGet:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2Control:Init(aCtrl, nPage, oFormFather)
   ::S2CompGrp:Init(aCtrl[FORM_GET_COMPGRP], aCtrl[FORM_GET_COMPEXP])
   ::S2EditCtrl:Init( aCtrl[FORM_GET_CVAR] )
   ::S2PfkCtrl:Init( aCtrl[FORM_GET_PFK] )

   //SD ::tabStop := .T.

   ::border := lBorder

   ::autoSize := .F.
   ::clipChildren := .T.
   ::clipSiblings := .F.
   ::Datalink := aCtrl[FORM_GET_VAR]
   ::picture  := UPPER(aCtrl[FORM_GET_PICTUREGET])
   ::lNumericInput := .F.
   ::lFirstChar := .F.     // Š utile solo quando lNumericInput = .T.
   ::cNumPicture := ""    // Š utile solo quando lNumericInput = .T.
   ::lComboEnabled := .T.
   IF ! EMPTY(::picture)

      // IF "@S" $ UPPER(::picture) // Tolgo "@Snn"
      //
      // ENDIF

      IF "@P" $ ::picture                // Password
         ::picture := STRTRAN(::picture, "@P")
         ::unReadable := .T.
      ENDIF
   ENDIF

   ::bActive  := aCtrl[FORM_GET_ACTIVE]
   ::bCond    := aCtrl[FORM_GET_CONDITION]
   ::cMsg     := aCtrl[FORM_GET_MESSAGE]
   ::cRefGrp  := aCtrl[FORM_GET_CTRLGRP]
   ::bSys     := aCtrl[FORM_GET_SYS]
   //::group    := XBP_WITHIN_GROUP

   ::cInitVal := ""
   ::lDispLoop := .F.


   // ::rbDown := oParent:rbDown

   IF aCtrl[FORM_GET_COMBO]
//      //MANTIS 584
//      IF ("@J" $ ::picture .OR. "99" $ ::picture .OR. ::Align == XBPSLE_RIGHT) 
//         ::lExtCmb := .T.
//         aSize[1] -= 15
//      ENDIF

      IF ::lExtCmb
         // Pulsante esterno al GET
         IF S2PixelCoordinate(aCtrl)
            aPos  := { aSize[1] + aCtrl[FORM_GET_COL], aCtrl[FORM_GET_ROW]}
         ELSE
            aPos  := { aSize[1] + oPos:nXWin, oPos:nYWin }
         ENDIF

         oDmmPos := PosCvt():new(2,1)
         //aSize_Butt := { oDmmPos:nXWin, oDmmPos:nYWin }
         aSize_Butt := { oDmmPos:nXWin-4, aSize[2] }
         aPos_Butt  := {aPos[1],aPos[2]  }
         IF ::nPaintStyle == GET_PS_STD
            oXbp := XbpPushButton():new(oParent, oOwner, aPos_Butt, aSize_Butt )
         ELSE
            IF ::getCheckBorderColor() != NIL
               aSize_Butt[2] += 4
               aPos_Butt[1]  += 2
            ENDIF 
            oXbp := S2ButtonX():new(oParent, oOwner, aPos_Butt, aSize_Butt )
            //oXbp := ie4Button():new(oParent, oOwner, aPos, aSize_Butt )
         ENDIF
      ELSE

         // Simone 10/1/08
         // mantis 0001552: rivedere form gestite con dfAutoForm e S2AutoForm
         // uso sempre larghezza di 2*COL_SIZE invece che dinamico da PosCvt()
         // Pulsante interno al GET
         //oPos := PosCvt():new(2,1)
         //aPos  := { aSize[1] - oPos:nXWin, 0 }
         //aSize_Butt := {oPos:nXWin-4, aSize[2]-4}
         aPos  := { aSize[1] - 2*COL_SIZE, 0 }
         aSize_Butt := {2*COL_SIZE-4, aSize[2]-4}
         // Se non c'Š bordo metto il pulsante 4 pixel piu a destra
         IF ! lBorder
            aPos[1]+=4
            IF ::nPaintStyle == GET_PS_STD
               aSize_Butt[2] += 4
            ELSE
               // Modifica Luca per colore Mandatory con background
               //aSize_Butt[2] += 2
               aSize_Butt[2] += 4
            ENDIF
         ENDIF

         IF ::nPaintStyle == GET_PS_STD
            oXbp := XbpPushButton():new(self, NIL, aPos, aSize_Butt )
         ELSE
            oXbp := S2ButtonX():new(self, NIL, aPos, aSize_Butt )
            //oXbp := Ie4Button():new(self, NIL, aPos, aSize_Butt )
         ENDIF
      ENDIF


      IF ::nPaintStyle == GET_PS_STD
         oXbp:caption := GET_BTN_DOWNARROWBMP
         oXbp:pointerFocus := .F.
      ELSE
         oXbp:Image     := GET_BTN_DOWNARROWBMP
         oXbp:ImageType := XBPSTATIC_TYPE_BITMAP
         oXbp:side      := .T.
         oXbp:caption   := ""
         oXbp:style     := 2
         oXbp:lInvertImageOnDisable := .F.
         oXbp:disabledColorBG := XBPSYSCLR_INACTIVEBORDER  // quando si imposta questo si deve impostaer anche ::setColorBG() !!!!
         oXbp:setColorBG( XBPSYSCLR_3DFACE )
      ENDIF
      oXbp:clipSiblings := .F.
      oXbp:tabStop := .F.

      // Quando premo il pulsante:
      // - se il get non ha il focus lo imposto e poi ripremo il pulsante
      // - se il get ha il focus eseguo l'azione associata

      oXbp:activate := {|m1,m2,o| IIF(::lComboEnabled, ;
                                    IIF(::hasFocus(), ;
                                       (ACT := "Ada", ::KeyBoard( dbAct2Ksc(ACT) )),;
                                       (SetAppFocus(self), ;
                                        PostAppEvent(xbeP_Activate, m1, m2, o)) ;
                                     ), NIL)}
      // aggiunto SD 27/06/2002 GERR 3254
      oXbp:rbdown   := {|m1,m2,o| IIF(::lComboEnabled, ;
                                    IIF(::hasFocus(), ;
                                       (ACT := "Cda", ::KeyBoard( dbAct2Ksc(ACT) )),;
                                       (SetAppFocus(self), ;
                                        PostAppEvent(xbeM_RbDown, m1, m2, o)) ;
                                     ), NIL)}
      ::oCombo    := oXbp
   ELSE
      ::oCombo := NIL

   ENDIF

   // PROMPT
   IF ! EMPTY(aCtrl[FORM_GET_PROMPT])

      //13/05/04 Luca: Inserito per gestione pixel o Row/Column
      IF S2PixelCoordinate(aCtrl)
         aPos := {aCtrl[FORM_GET_PCOL], aCtrl[FORM_GET_PROW]}
         oPos := PosCvt():new(LEN(aCtrl[FORM_GET_PROMPT]), 1)
         IF oPos:nXWin > 0 .AND. oPos:nYWin > 0
            aSize_Prompt := {oPos:nXWin , aSize[2]}
         ENDIF
      ELSE

         oPos := PosCvt():new(aCtrl[FORM_GET_PCOL], aCtrl[FORM_GET_PROW]+1)
         oPos:Trasla(oParent)
         aPos := {oPos:nXWin, oPos:nYWin}

         oPos:SetDos(LEN(aCtrl[FORM_GET_PROMPT]), 1)
         IF aCtrl[FORM_GET_PROW] == aCtrl[FORM_GET_ROW] 
            aPos[1] -= 4
         ENDIF
         IF oPos:nXWin > 0 .AND. oPos:nYWin > 0
            aSize_Prompt := {oPos:nXWin+4 , aSize[2]}
         ENDIF
      ENDIF
      aPP := NIL
   #ifndef _NOFONT_
      IF ! EMPTY(aCtrl[FORM_GET_PFONTCOMPOUNDNAME])
         aPP := {}
         aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_GET_PFONTCOMPOUNDNAME])
         //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_GET_PFONTCOMPOUNDNAME]})
      ENDIF
   #endif
      aPP := S2PPSetColors(aPP, ! oFormFather:hasBitmapBG(), aCtrl[FORM_GET_CLRPROMPT], APPCOLOR_GETPROMPT)

      //Mantis 396
      //oXbp:autoSize := .F.
      IF S2PixelCoordinate(aCtrl)
         //Mantis 396
          oXbp := XbpStatic():new(oParent, oOwner , aPos, NIL, aPP , .F.)
          oXbp:autoSize := .T.
          oXbp:options := XBPSTATIC_TEXT_VCENTER
      ELSE
          //Mantis 396
          oXbp := XbpStatic():new(oParent, oOwner , aPos, aSize_Prompt, aPP, .F. )
          oXbp:autoSize := .F.
          IF aCtrl[FORM_GET_PROW] <> aCtrl[FORM_GET_ROW] 
              oXbp:options  := XBPSTATIC_TEXT_LEFT +XBPSTATIC_TEXT_VCENTER
          ELSE              
              oXbp:options  := XBPSTATIC_TEXT_RIGHT
          ENDIF

          // Simone 7/12/05 gerr 4569 in alcune maschere i prompt delle GET hanno puntini "..."   
          // correzione per abilitare nuovamente visualizzazione prompt con autosize
          // solo per DOS
          //
          // Allineamento a destra del prompt se Š sulla stessa riga
          IF aCtrl[FORM_GET_PROW] == aCtrl[FORM_GET_ROW] .AND. ;
             aCtrl[FORM_GET_PCOL] <  aCtrl[FORM_GET_COL] .AND. ;
             ! EMPTY(dfSet("XbasePromptAlign"))
        
             oXbp:options := VAL(dfSet("XbasePromptAlign"))
          ELSE
             oXbp:autoSize := dfSet("XbaseGPrAutoSize") == "YES"
          ENDIF

      ENDIF
      oXbp:caption      := ::ChgHotKey( aCtrl[FORM_GET_PROMPT] )
      oXbp:clipSiblings := .F.


      oXbp:rbDown := oParent:rbDown

      // S2ObjSetColors(oXbp, ! oFormFather:hasBitmapBG(), aCtrl[FORM_GET_CLRPROMPT], APPCOLOR_GETPROMPT)

      ::oPrompt := oXbp
   ELSE
      ::oPrompt := NIL
   ENDIF

   // S2ObjSetColors(self, .T., ::aCtrl[FORM_GET_CLRDATA], APPCOLOR_GET)

   // Mi salvo i colori di default per usarli anche nel killinputfocus
   // Prendo il colore da Pres.param o valore standard o default
   oXbp := S2PresParameter():new(aParam[5])
   ::nEnabledColorFG := oXbp:get(XBP_PP_FGCLR)
   ::nEnabledColorBG := oXbp:get(XBP_PP_BGCLR)
   DEFAULT ::nEnabledColorFG TO ::setColorFG()
   DEFAULT ::nEnabledColorBG TO ::setColorBG()
   DEFAULT ::nEnabledColorFG TO XBPSYSCLR_WINDOWSTATICTEXT
   DEFAULT ::nEnabledColorBG TO XBPSYSCLR_ENTRYFIELD

   // In Xbase > 1.5 controllo solo disabled FG
   IF (cColorFG != NIL) .OR. ::nPaintStyle != GET_PS_STD .OR. ;
      ::getCheckBorderColor() != NIL

   //IF (cColorFG != NIL .AND. S2IsNumber(cColorFG)) .OR. ::nPaintStyle != PS_STD

      IF cColorBG != NIL 
         IF S2IsNumber(cColorBG)
            ::nDisabledColorBG := VAL(cColorBG)
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| ::nDisabledColorBG := n}, .T., cColorBG)
         ENDIF
      ENDIF

      IF cColorFG != NIL 
         IF S2IsNumber(cColorFG)
            ::nDisabledColorFG := VAL(cColorFG)
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| ::nDisabledColorFG := n}, .T., cColorFG)
         ENDIF
      ENDIF

      ::oStatic := _GetSupport():new(aParam[1], aParam[2], aParam[3], ;
                                     aParam[4], NIL      , aParam[6]  )

      IF ::getCheckBorderColor() != NIL .AND. ::nPaintStyle != GET_PS_STD
         ::oStatic:type := XBPSTATIC_TYPE_TEXT
      ENDIF
      ::oStatic:cMsg := ::cMsg
   ENDIF
   IF S2PixelCoordinate(::aCtrl) .AND.; 
      ::oCombo  != NIL           .AND.;
      ::oStatic != NIL
      ::oComboSle := XbpGet():New(::oStatic,::oStatic,{0,0},::oStatic:Currentsize())
   ENDIF

   ::rbDown := {|mp1, mp2, obj| S2GetRBMenu():popUp(obj, mp1) }

#ifdef _ENABLE_AUTOFILL_
   IF dfSet("XbaseGetAutoFill")=="STD"
 //  ::oAutoFill := ImplementAutoFill():new({|c,o,nKey|FindStr(c,o,nKey)}, self)
      ::oAutoFill := ImplementAutoFillText():new(self)
   ENDIF
#endif
RETURN self

METHOD S2Get:Create()
RETURN self

METHOD S2Get:_Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL aPsize := {},aPpos := {}//, aPP := {} 
   LOCAL aSize_Prompt := {}, oPos
   LOCAL nGap := 0, xClr, oXbp
   
   IF ::status() == XBP_STAT_INIT

      IF "@J" $ ::picture
         ::align := XBPSLE_RIGHT
      ENDIF

      IF ::oStatic != NIL
         //Mantis 603
         IF S2PixelCoordinate(::aCtrl) .AND.;
            ::lExtCmb == .F.           .AND.;
            ::Align == XBPSLE_RIGHT    .AND.;
            ::oCombo != NIL            .AND.;
            ::oStatic != NIL
            ::border := .F.
         ENDIF
         // Fine 603
         ::oStatic:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
         ::XbpGet:Create(::oStatic, ::oStatic, {0,0})

         // simone 14/11/06
         // mantis 0001167: implementare evidenziazione dei campi obbligatori
         // allargo lo STATIC e lo coloro in modo da simulare un bordino
         xClr := ::getCheckBorderColor() 
         IF xClr != NIL
            IF EMPTY(::oStatic:cargo)              // se non ho gi… spostato
               aPos  := ::oStatic:currentPos()
               aSize := ::oStatic:currentSize()
               aPos[1] -= MANDATORY_OFFSET_X
               aPos[2] -= MANDATORY_OFFSET_Y
               aSize[1] += MANDATORY_OFFSET_X*2
               aSize[2] += MANDATORY_OFFSET_Y*2
               ::oStatic:setPosAndSize(aPos, aSize)
               ::oStatic:setColorBG(xClr)
               ::oStatic:cargo := 1  // serve per non farlo ancora!
            ENDIF
            ::Xbpget:setPos({MANDATORY_OFFSET_X, MANDATORY_OFFSET_Y}, .F.)
         ENDIF
      ELSE
         ::XbpGet:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
      ENDIF

      // IF ::oStatic != NIL
      //    ::oStatic:create(::XbpGet:setParent(), ::XbpGet:setOwner(), ;
      //                     ::XbpGet:currentPos(), ::XbpGet:currentSize(), ;
      //                     NIL, ::XbpGet:isVisible())
      //
      //    ::XbpGet:setParent(::oStatic)
      //    ::XbpGet:setOwner(::oStatic)
      //    ::XbpGet:setPos({0,0})
      // ENDIF

      ::lNumericInput :=  ::get:TYPE=="N" .AND. ("@J" $ ::picture .OR. ;
                                                 dfSet( AI_CALCULATORGET ) )

      // Allineo automaticamente a destra i numeri che
      // non sono gi… allineati a destra
      IF ::get:type=="N" .AND. ::Align != XBPSLE_RIGHT
         ::Align := XBPSLE_RIGHT
         //MANTIS 885
         ////Mantis 603
         //IF S2PixelCoordinate(::aCtrl) .AND.;
         //   ::lExtCmb == .F.           .AND.;
         //   ::Align == XBPSLE_RIGHT    .AND.;
         //   ::oCombo != NIL
         //   ::border := .F.
         //ENDIF
         // // Fine 603
         //::configure()
      ENDIF

      //Luca 10/06/2004
      //Modificato per gestiona allinamento/centramento Get 
      IF LEN(::aCtrl)>= FORM_GET_ALIGNMENT_TYPE    .AND. ;
         ::aCtrl[FORM_GET_ALIGNMENT_TYPE]>=0

         DO CASE
            CASE ::aCtrl[FORM_GET_ALIGNMENT_TYPE] == XBPALIGN_LEFT
              ::Align := XBPSLE_LEFT  
            CASE ::aCtrl[FORM_GET_ALIGNMENT_TYPE] == XBPALIGN_RIGHT
              ::Align := XBPSLE_RIGHT 
            CASE ::aCtrl[FORM_GET_ALIGNMENT_TYPE] == XBPALIGN_HCENTER
              ::Align := XBPSLE_CENTER
            OTHERWISE
              ::Align := XBPSLE_LEFT  
              IF ::get:type=="N" 
                 ::Align := XBPSLE_RIGHT
              ENDIF
         ENDCASE    
      ENDIF                                        
      //MANTIS 885
      //Mantis 603
      IF S2PixelCoordinate(::aCtrl) .AND.;
         ::lExtCmb == .F.           .AND.;
         ::Align == XBPSLE_RIGHT    .AND.;
         ::oCombo != NIL            .AND.;
         ::oStatic != NIL
         ::border := .F.
      ENDIF
       // Fine 603
      ::configure()

      ::setNumericPicture()

      // ::align := XBPSLE_LEFT
      //
      // // Il right Š supportato solo su win98.
      // // Lo attivo solo se "@J" Š nella picture e Š un campo carattere
      // // o numerico senza decimali
      //
      // IF dfWinIs98() .AND. "@J" $ ::get:picture .AND. ::get:decPos==0
      //
      //    ::picture := STRTRAN(::picture, "@J")
      //    ::get:picture := ::picture
      //
      //    ::Align := XBPSLE_RIGHT
      //
      // ELSE
      //
      //    // ::Align := XBPSLE_RIGHT
      //    ::Align := XBPSLE_LEFT
      // ENDIF
      //
      // ::configure() // per aggiornare ::Align
      
      IF ::oCombo != NIL .AND.;
         ::oCombo:status() == XBP_STAT_INIT
//       //MANTIS 584
         //Mantis 603
          IF S2PixelCoordinate(::aCtrl) .AND. ::lExtCmb == .F. .AND. ::Align == XBPSLE_RIGHT
              IF ::oStatic    != NIL .AND.;
                 ::oComboSle  != NIL .AND.;
                 ::oComboSle:status() == XBP_STAT_INIT

                 ::oComboSle:Create(::oStatic,::oStatic,{0,0},::oStatic:Currentsize())
                 ::oComboSle:Disable()
                 ::oComboSle:Editable := .F.
                 ::oComboSle:tabStop  := .F.
                 ::oComboSle:clipSiblings:= .F.	

                 ::XbpGet:setParent(::oComboSle)
                 ::XbpGet:setOwner(::oComboSle) 
                 ::XbpGet:SetPos({0,-2})
                 ::XbpGet:SetSize({::oStatic:Currentsize()[1]-17,::oStatic:Currentsize()[2]-2} )
//                 ::oCombo:setParent(::oComboSle)
//                 ::oCombo:setOwner(::oComboSle)
//                 ::oCombo:setPos({::oStatic:Currentsize()[1]-16,0})
                 ::comboCreate(::oComboSle,{::oStatic:Currentsize()[1]-16,0}) //::oCombo:Create(::oComboSle, NIL, {::oStatic:Currentsize()[1]-16,0} )

              ELSE
                 ::comboCreate() //::oCombo:Create()
                 IF !EMPTY(aSize)
                    ::XbpGet:setSize(aSize)
                 ENDIF
              ENDIF
          ELSE
             ::comboCreate() //oCombo:Create()
          ENDIF
          // Fine 603
      ENDIF
      IF ::oPrompt != NIL
         ::oPrompt:Create()
         //
         //Mantis 396
         IF S2PixelCoordinate(::aCtrl) .AND. LEN(::aCtrl[FORM_GET_PROMPT])>0
            aPsize := ::oPrompt:CurrentSize()
            aPpos  := ::oPrompt:CurrentPos()

            oPos   := PosCvt():new(LEN(::aCtrl[FORM_GET_PROMPT]), 1)
            aSize_Prompt := {oPos:nXWin ,aPsize[2]}
            //nGap => Distanza in pixel tra il promt e la get (sarebbe esprsso in caratteri x 8)
            DO CASE 
               CASE ::aCtrl[FORM_GET_PROW] == ::aCtrl[FORM_GET_ROW] .AND. ;
                    ::aCtrl[FORM_GET_PCOL] <  ::aCtrl[FORM_GET_COL] 
                    nGap  := ::aCtrl[FORM_GET_COL] - (::aCtrl[FORM_GET_PCOL]+8*Len(StrTran(Trim(::aCtrl[FORM_GET_PROMPT]),"^","")))
                    IF ::oStatic != NIL
                       aPpos[1] :=  ::aCtrl[FORM_GET_COL] - aPsize[1] - nGap
                       // Sbagliato --> aPpos[1] :=  aPpos[1] - (aPsize[1]-aSize_Prompt[1])
                       aPpos[2] :=  ::oStatic:CurrentPos()[2]+::oStatic:CurrentSize()[2]-aPSize[2]-2
                       //allinemento centrato ripetto alla Get
                       //aPpos[2] :=  ::oStatic:CurrentPos()[2]+::oStatic:CurrentSize()[2]/2-aPSize[2]/2
                    ELSE
                       aPpos[1] :=  ::aCtrl[FORM_GET_COL] - aPsize[1] - nGap
                       aPpos[2] :=  ::XbpGet:CurrentPos()[2]+::XbpGet:CurrentSize()[2]-aPSize[2]-2
                       //allinemento centrato ripetto alla Get
                       //aPpos[2] :=  ::XbpGet:CurrentPos()[2]+::XbpGet:CurrentSize()[2]/2-aPSize[2]/2
                    ENDIF
               CASE ::aCtrl[FORM_GET_PROW] == ::aCtrl[FORM_GET_ROW] .AND. ;
                    ::aCtrl[FORM_GET_PCOL] >  ::aCtrl[FORM_GET_COL] 
                    IF ::oStatic != NIL
                      //aPpos[1] :=  (aPsize[1]-aSize_Prompt[1]) +::aCtrl[FORM_GET_PCOL] 
                      aPpos[1] :=  ::aCtrl[FORM_GET_PCOL] 
                      aPpos[2] :=  ::oStatic:CurrentPos()[2]+::oStatic:CurrentSize()[2]-aPSize[2]-2
                       //allinemento centrato ripetto alla Get
                       //aPpos[2] :=  ::oStatic:CurrentPos()[2]+::oStatic:CurrentSize()[2]/2-aPSize[2]/2
                    ELSE
                       //aPpos[1] :=  (aPsize[1]-aSize_Prompt[1]) +::aCtrl[FORM_GET_PCOL] 
                       aPpos[1] :=  ::aCtrl[FORM_GET_PCOL] 
                       aPpos[2] :=  ::XbpGet:CurrentPos()[2]+::XbpGet:CurrentSize()[2]-aPSize[2]-2
                       //allinemento centrato ripetto alla Get
                       //aPpos[2] :=  ::XbpGet:CurrentPos()[2]+::XbpGet:CurrentSize()[2]/2-aPSize[2]/2
                    ENDIF
               CASE ::aCtrl[FORM_GET_PROW] >  ::aCtrl[FORM_GET_ROW] .AND. ;
                    ::aCtrl[FORM_GET_PCOL] >= ::aCtrl[FORM_GET_COL] 
                    IF ::oStatic != NIL
                      aPpos[1] :=  ::aCtrl[FORM_GET_PCOL] 
                      aPpos[2] :=  ::oStatic:CurrentPos()[2]+::oStatic:CurrentSize()[2] +1
                       //allinemento centrato ripetto alla Get
                       //aPpos[2] :=  ::oStatic:CurrentPos()[2]+::oStatic:CurrentSize()[2]/2-aPSize[2]/2
                    ELSE
                       aPpos[1] :=  ::aCtrl[FORM_GET_PCOL] 
                       aPpos[2] :=  ::XbpGet:CurrentPos()[2]+::XbpGet:CurrentSize()[2] +1
                       //allinemento centrato ripetto alla Get
                       //aPpos[2] :=  ::XbpGet:CurrentPos()[2]+::XbpGet:CurrentSize()[2]/2-aPSize[2]/2
                    ENDIF
               CASE ::aCtrl[FORM_GET_PROW] <  ::aCtrl[FORM_GET_ROW] .AND. ;
                    ::aCtrl[FORM_GET_PCOL] >= ::aCtrl[FORM_GET_COL] 
                    IF ::oStatic != NIL
                      aPpos[1] :=  ::aCtrl[FORM_GET_PCOL] 
                      aPpos[2] :=  ::oStatic:CurrentPos()[2] -aPSize[2] -1
                       //allinemento centrato ripetto alla Get
                       //aPpos[2] :=  ::oStatic:CurrentPos()[2]+::oStatic:CurrentSize()[2]/2-aPSize[2]/2
                    ELSE
                       aPpos[1] :=  ::aCtrl[FORM_GET_PCOL] 
                       aPpos[2] :=  ::XbpGet:CurrentPos()[2] -aPSize[2] -1
                       //allinemento centrato ripetto alla Get
                       //aPpos[2] :=  ::XbpGet:CurrentPos()[2]+::XbpGet:CurrentSize()[2]/2-aPSize[2]/2
                    ENDIF
            ENDCASE
            ::oPrompt:SetPos(aPpos)
            ::oPrompt:Show()
            //::oPrompt:Configure()
         ELSE

            // Simone 9/1/08
            // mantis 0001552: rivedere form gestite con dfAutoForm e S2AutoForm
            // calcolo nuove dimensioni e risposto per allienare prompt a destra
            // Allineamento a destra del prompt se Š sulla stessa riga
            IF ::aCtrl[FORM_GET_PROW] == ::aCtrl[FORM_GET_ROW] .AND. ;
               ::aCtrl[FORM_GET_PCOL] <  ::aCtrl[FORM_GET_COL] .AND. ;
               dfAnd(::oPrompt:options,XBPSTATIC_TEXT_RIGHT) != 0 // se allineo prompt a destra

               // ricalcolo e risposto
               IF dfSet("XbaseGPrAutoSize") == "YES" .AND. ! ::oPrompt:autoSize

                  // creo nuovo oggetto per calcolo dimensioni
                  oXbp := XbpStatic():new(self)
                  oXbp:caption := ::oPrompt:caption
                  // tolgo caratteri ~
                  oXbp:caption := STRTRAN(oXbp:caption, STD_HOTKEYCHAR, "")
                  oXbp:autoSize := .T.
                  oXbp:create()
                  aSize := oXbp:currentSize()
                  oXbp:destroy()

                  // riposiziono prompt in base al GET
                  aPPos := ::currentPos()
                  aPPos[1] -= aSize[1]+2+::aCtrl[FORM_GET_GAP]*COL_SIZE
                  //aPPos[2] := ::oPrompt:currentSize()[2]-aSize[2]
                  aSize[2] := ::currentSize()[2]
                  ::oPrompt:setPosAndSize(aPPos, aSize)
               ENDIF
            ENDIF

         ENDIF
      ENDIF
   ENDIF

RETURN self

// Simone + Tommaso 09/09/08 - Mantis 0001938: errore xbpstatic:create() nell'apertura di una maschera
// ---------------------------------------------------------------------------------------------------
// Aggiunto metodo per errore di run-time in alcuni casi in cui veniva chiamato
// il :create() di un XbpGet associato un Parent ancora in stato INIT
// succedeva con l'uso di oComboSle
// ---------------------------------------------------------------------------------------------------
METHOD S2Get:comboCreate(oParent,aPos)
   // simone 28/5/08
   // mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
   IF ::_oComboStatic != NIL .AND. ;
      ::_oComboStatic:status() == XBP_STAT_INIT

      ::_oComboStatic:create(oParent,NIL,aPos)
      ::_oComboStatic:disable()

      ::oCombo:setParent(::_oComboStatic)
      ::oCombo:setPos({0, 0})

      oParent := NIL
      aPos    := NIL
   ENDIF
   ::oCombo:create(oParent,NIL,aPos)
RETURN self

METHOD S2Get:setNumericPicture()
   LOCAL nLen

   IF ::lNumericInput

      ::cNumPicture := ::picture

      nLen         := LEN(::get:BUFFER)

      IF LEN(::cNumPicture)>2
         IF LEFT(::cNumPicture,2)=="@J"
            ::cNumPicture := SUBSTR(::cNumPicture,3)
         ENDIF
      ELSE
         ::cNumPicture := "@9"
      ENDIF

      IF LEN(::cNumPicture)==2 .AND. LEFT(::cNumPicture,1)=="@"
         ::cNumPicture := REPLICATE( RIGHT(::cNumPicture,1), nLen )
      ENDIF
   ENDIF

RETURN self


METHOD S2Get:isShortCut(cAct)
   LOCAL lRet := .F. , nPos

   IF ! EMPTY(::oPrompt) .AND. VALTYPE( ::oPrompt:caption ) == "C" .AND. ;
      ( nPos := AT( STD_HOTKEYCHAR, ::oPrompt:caption) ) != 0

      // nRet := dbAct2Ksc("A_"+LOWER( SUBSTR( ::oPrompt:caption, nPos + 1, 1)))
      lRet := cAct == "A_"+LOWER( SUBSTR( ::oPrompt:caption, nPos + 1, 1))

   ENDIF
RETURN lRet

METHOD S2Get:destroy()
   LOCAL o

   // simone 28/5/08
   // mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
   IF ! ::editable
      // workaround altrimenti i colori FG/BG non vengono assegnati la seconda volta!
      ::editable := .T.
//      IF ::_oComboStatic!=NIL
//         o := ::oCombo
//         o:setParent(::_oComboStatic:setParent())
//         o:setPos(::_oComboStatic:currentPos())
//         ::_oComboStatic:destroy()
//         ::_oComboStatic :=NIL
//      ENDIF
   ENDIF
   ::XbpGet:destroy()
RETURN self

// METHOD S2Get:destroy()
//
//    // IF ::oStatic == NIL
//    //    ::XbpGet:destroy()
//    // ELSE
//    //    ::oStatic:destroy()
//    // ENDIF
//    // IF ::oCombo != NIL
//    //    ::oCombo:destroy()
//    // ENDIF
//    // IF ::oPrompt != NIL
//    //    ::oPrompt:destroy()
//    // ENDIF
// RETURN self

METHOD S2Get:IsActive()
//RETURN EVAL(::bActive)
LOCAL lRet := EVAL(::bActive)
RETURN lRet

METHOD S2Get:PreGet()
//RETURN EVAL(::bCond, FORM_PREGET)
LOCAL lRet := EVAL(::bCond, FORM_PREGET)
RETURN lRet   


METHOD S2Get:PostGet()
//RETURN EVAL(::bCond, FORM_POSTGET)
LOCAL lRet := EVAL(::bCond, FORM_POSTGET)
RETURN lRet

METHOD S2Get:ChkGet()
//RETURN EVAL(::bCond, FORM_CHKGET)
LOCAL lRet := EVAL(::bCond, FORM_CHKGET)
RETURN lRet   

METHOD S2Get:getData()
   LOCAL cRet

   IF ::get:type == "C" .AND. "@0" $ ::get:picture .AND. !EMPTY(::get:BUFFER)
      ::get:BUFFER := PADL( STRTRAN(::get:BUFFER," ",""), LEN(::get:BUFFER), "0" )
      ::SetEditBuffer( ::Get:Buffer )

   ELSEIF ::get:type == "C" .AND. "@J" $ ::get:picture
      ::get:BUFFER := PADL( ALLTRIM(::get:BUFFER), LEN(::get:BUFFER) )
      ::SetEditBuffer( ::Get:Buffer )

   ENDIF

   cRet := ::XbpGet:getData()

   IF ::aPage0 != NIL
      // Se Š pagina 0 aggiorno il buffer dei "fratelli"
      AEVAL(::aPage0, {|x|x:setData()})
   ENDIF
RETURN cRet

METHOD S2Get:DispItm() // ( cGrp, lRef )
   LOCAL lRet := .F., oXbp

   IF ! ::lDispLoop
      ::lDispLoop := .T. // Evito ricorsione

      // Faccio qui la creazione perchŠ altrimenti ho
      // problemi con picture delle quali non so
      // la lunghezza nel tbConfig ("@S")
      ::_Create()

      IF ::lCalcSizeOnDisplay

         ::DispItmCalcSize()

         // Evito il ricalcolo una seconda volta
         ::lCalcSizeOnDisplay := .F.
      ENDIF

      ::Get:SetFocus()

      IF ::CanShow()
         ::show()
         lRet := .T.
      ELSE
         ::hide()
      ENDIF

      IF ::IsActive() .AND. ;
         (!dfSet("XbaseDisableOnPreget") == "YES" .OR. ::PreGet())

         ::enable()
      ELSE
         ::disable()
      ENDIF
      
      IF ::oStatic != NIL .AND. ::nPaintStyle != GET_PS_STD .AND. ::getCheckBorderColor()==NIL
#ifdef _USA_BITMAP
         ::oStatic:paintBack(::nPaintStyle, NIL, ::setColorFG(), ::setColorBG(), NIL )
#endif
         ::XbpGet:setPosAndSize({1, 1}, {::oStatic:currentSize()[1]-2, ::oStatic:currentSize()[2]-2})
//       simone 1/6/05 commentato perche non funziona, anche se in teoria dovrebbe essere corretto
//         IF ! EMPTY(dfSet("XbaseGetBorderColor"))
//             oXbp := ::oStatic
//             S2ItmSetColors({|n|NIL}, {|n| oXbp:setColorBG(n)}, .T., dfSet("XbaseGetBorderColor"))
//         ENDIF

      ENDIF


      IF ::getMandatoryBackgroundColor()  != NIL
         ::XbpGet:setColorBG(::getMandatoryBackgroundColor())
      ENDIF


      ::SetData()

      ::lDispLoop := .F.
   ENDIF

RETURN self

METHOD S2Get:DispItmCalcSize()
   LOCAL nLen
   LOCAL oPos
   LOCAL aSize

   nLen := dfPictLen(::picture)
   IF EMPTY(nLen)
      nLen := LEN(dfAny2Str(EVAL( ::dataLink )))
   ENDIF

   // In caso di larghezza <= 2 allargo leggermente
   IF nLen <= 1
      nLen++

   ELSEIF nLen == 2
      //nLen := 2.5
      nLen := 3

   ENDIF

   IF ::oCombo != NIL
      nLen += 2
   ENDIF

   oPos := PosCvt():new(nLen, 1)
   //aSize := {oPos:nXWin, oPos:nYWin}
   aSize := {oPos:nXWin, ::Currentsize()[2]}
   // Se non c'Š bordo stringo i limiti sup/inf di 2 pixel
   IF ! ::border
      aSize[2]-=4
   ENDIF

   ::setSize(aSize)

   IF ::oCombo != NIL
      oPos := PosCvt():new(2,1)
      aSize[1] -= oPos:nXWin
      aSize[2] := 0

      // Se non c'Š bordo metto il pulsante 4 pixel piu a destra
      IF ! ::border
         aSize[1]+=4
      ENDIF
      ::oCombo:setPos(aSize)
   ENDIF

RETURN self


METHOD S2Get:enable()
   LOCAL aRect
   LOCAL lRet, o

   // simone 28/5/08
   // mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
   IF dfSet(AI_XBASEDISABLEDGETCOPY) == AI_DISABLEDGETCOPY_YES
      ::editable:= .T.
      lRet := .T.
      //////////////////////////////////////////////////////////////////////////
      //Mantis 2199 Luca 12/09/2012
      IF dfSet(AI_XBASEGETSTYLE) ==  GET_PS_STD
      //////////////////////////////////////////////////////////////////////////

         IF ::_oComboStatic!=NIL .AND. ::_oComboStatic:status()==XBP_STAT_CREATE
            o := ::oCombo
            o:setParent(::_oComboStatic:setParent())
            o:setPos(::_oComboStatic:currentPos())
            IF ::_oComboStatic:status()==XBP_STAT_CREATE
               ::_oComboStatic:destroy()
            ENDIF
            ::_oComboStatic :=NIL
         ENDIF
      ENDIF
   ENDIF

   IF ::oStatic == NIL
      // simone 28/5/08
      // mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
      IF lRet == NIL
      lRet := ::XbpGet:enable()
      ENDIF
   ELSE
      aRect := {::oStatic:currentPos()[1], ;
                ::oStatic:currentPos()[2], ;
                ::oStatic:currentPos()[1] + ::oStatic:currentSize()[1], ;
                ::oStatic:currentPos()[2] + ::oStatic:currentSize()[2]}

      // simone 28/5/08
      // mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
      IF lRet == NIL
      lRet := ::oStatic:enable()
      ENDIF

      IF ::nEnabledColorFG != NIL
         ::XbpGet:setColorFG(::nEnabledColorFG)
      ENDIF
      IF ::nEnabledColorBG != NIL
         ::XbpGet:setColorBG(::nEnabledColorBG)
      ENDIF
      ::oStatic:setParent():invalidateRect(aRect)
   ENDIF

   IF ::oCombo!=NIL 
      IF ::lExtCmb
         ::oCombo:enable()
      ELSE
         //MANTIS 584
         IF S2PixelCoordinate(::aCtrl) .AND. !EMPTY(::oComboSle)
            ::oComboSle:Enable()
         ENDIF
     ENDIF
   ENDIF

RETURN lRet

METHOD S2Get:disable()
   LOCAL aRect
   LOCAL lRet, o

   // simone 28/5/08
   // mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
   IF dfSet(AI_XBASEDISABLEDGETCOPY) == AI_DISABLEDGETCOPY_YES
      //lRet := dfXbpSetEditable(self, .F.)
      ::editable:= .F.
      lRet := .T.

      //////////////////////////////////////////////////////////////////////////
      //Mantis 2199 Luca 12/09/2012
      IF dfSet(AI_XBASEGETSTYLE) ==  GET_PS_STD
      //////////////////////////////////////////////////////////////////////////

         IF ::oCombo!=NIL .AND. ::_oComboStatic==NIL .AND. ::oCombo:status() == XBP_STAT_CREATE
            o := ::oCombo
            ::_oComboStatic := XbpStatic():new( o:setParent(), NIL, o:currentPos(), o:currentSize()):create()
            ::_oComboStatic:disable()
            o:setParent(::_oComboStatic)
            o:setPos({0, 0})
            //IF o:status()==XBP_STAT_CREATE
            //   ::_oComboStatic:create()
            //ENDIF
         ENDIF
      ENDIF
   ENDIF
   IF ::oStatic == NIL
      // simone 28/5/08
      // mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
      IF lRet == NIL
         lRet := ::XbpGet:disable()
      ENDIF
   ELSE
      aRect := {::oStatic:currentPos()[1], ;
                ::oStatic:currentPos()[2], ;
                ::oStatic:currentPos()[1] + ::oStatic:currentSize()[1], ;
                ::oStatic:currentPos()[2] + ::oStatic:currentSize()[2]}
      // simone 28/5/08
      // mantis 0001871: aggiungere possibilit… di effettuare la copia del valore dai campi disabilitati
      IF lRet == NIL
         lRet := ::oStatic:disable()
      ENDIF
      IF ::nDisabledColorFG != NIL
         ::XbpGet:setColorFG(::nDisabledColorFG)
      ENDIF
      IF ::nDisabledColorBG != NIL
         ::XbpGet:setColorBG(::nDisabledColorBG)
      ENDIF
      ::oStatic:setParent():invalidateRect(aRect)
   ENDIF

   IF ::oCombo!=NIL 
      IF ::lExtCmb
         ::oCombo:disable()
      ELSE
         //MANTIS 584
         IF S2PixelCoordinate(::aCtrl) .AND. !EMPTY(::oComboSle)
            ::oComboSle:Disable()
         ENDIF
     ENDIF
   ENDIF


  #ifdef _ENABLE_HELPBTN_
 //   IF ::hasFocus()
       ::hideBtnHelp()
 //   ENDIF
  #endif
RETURN lRet


// Quando acquista il focus riposiziona al primo carattere
METHOD S2Get:SetInputFocus()
   LOCAL aMarked

   IF ::isOnCurrentForm()
      // IF ::canSetFocus() .AND. ::PreGet()

      // Attivo/Disattivo il pulsante
      ::lComboEnabled := ::CanSetPage()  .AND. ::Preget()
      IF ::lComboEnabled

         // Modificato il 7/9/2000 (tolto il ::enable() e messo il ::dispItm())
         // perche se nel :postGet() ho una dfYesNo() viene ridato il focus
         // a questo control e viene abilitato... invece non deve essere
         // abilitato.
         ::dispItm()
         //::enable()

         //#ifdef _S2CTRGET_HILITE_
         IF S2CTRGET_HILITEON()
            // cambia i colori quando riceve input focus,
            // funziona perfettamente ma Š disabilitato perchŠ
            // dovrebbe essere fatto anche per i combo/spin/ecc.
            IF ::isEnabled()
               // imposto i colori per input focus
               S2ObjSetColors(self, .T., ::aCtrl[FORM_GET_CLRHILITE], APPCOLOR_HILITE)
            ENDIF
         ENDIF
         //#endif

         ::oForm:SetMsg(::cMsg)

         // SD 27/02/03 GERR 3672
         // Aggiorna W_CURRENTGET
         ::oForm:UpdateCurrentGet()

         ::cInitVal := ::editBuffer()

         ::get:setFocus()
         IF ::get:TYPE=="C" .AND. "@J" $ ::picture
            ::setData( PADR( ALLTRIM(::get:BUFFER), LEN(::get:BUFFER) ) )

         ELSEIF ::lNumericInput //.OR. ::align == XBPSLE_RIGHT
            // Posiziono a destra
            IF ::get:decPos > 0 .AND. ::get:decPos < ::bufferLength
               ::get:POS     := ::get:DECPOS-1
            ELSE
               ::get:pos := ::bufferLength
            ENDIF

         ELSE
            ::setData()
         ENDIF

         // ::Get:Home()
         ::SetFirstChar( 1 )

         ::lFirstChar := .T.

         IF ! EMPTY(::picture) .AND. "K" $ ::picture .AND. ! EMPTY(::editBuffer())
            // @K nella picture: evidenzio tutto il campo
            ::get:end()
            aMarked := {1, ::get:pos+1}
            ::get:setFocus()

         ELSE
            IF Set( _SET_INSERT )
               aMarked := { ::Get:Pos, ::Get:Pos }
            ELSE
               aMarked := { ::Get:Pos, ::Get:Pos + 1 }
            ENDIF
         ENDIF

         ::SetMarked( aMarked )

        #ifdef _ENABLE_HELPBTN_
          ::setBtnHelp()
        #endif

      ELSE
         IF dfSet("XbaseDisableOnPreget") == "YES"
            ::disable()
         ENDIF

         ::oForm:skipFocus(1)
#ifdef _ENABLE_HELPBTN_
         ::hideBtnHelp()
#endif

         //PostAppEvent(xbeP_KillInputFocus, NIL, NIL, self)
      ENDIF
   ENDIF
RETURN self

#ifdef _ENABLE_HELPBTN_
// mostra/nasconde il pulsante di help su data/numero
METHOD S2Get:setBtnHelp()
   LOCAL aPos, aSize, oXbp, lShow

   IF ::nBtnHelp == NIL

   //   XbaseGetAutoHelpBtn= 1 // abilita help su date
   //   XbaseGetAutoHelpBtn= 2 // abilita help su numeri
   //   XbaseGetAutoHelpBtn= 3 // abilita help su date e numeri

      ::nBtnHelp := dfSet("XbaseGetAutoHelpBtn")
      IF EMPTY( ::nBtnHelp )
         ::nBtnHelp := 0
      ELSE
         ::nBtnHelp := VAL(::nBtnHelp)
      ENDIF

      //::oBtnHelp := XbpStatic():new() //XbpPushButton():new()
      //::oBtnHelp := XbpPushButton():new()
      //::oBtnHelp:setColorBG(GRA_CLR_BLUE)
      //::oBtnHelp:setColorFG(GRA_CLR_WHITE)
      /*
      IF ::nPaintStyle == GET_PS_STD
         oXbp := XbpPushButton():new(self)
         oXbp:caption := GET_BTN_DOWNARROWBMP
         oXbp:pointerFocus := .F.
      ELSE
         oXbp := S2ButtonX():new(self)
         oXbp:Image     := GET_BTN_DOWNARROWBMP
         oXbp:ImageType := XBPSTATIC_TYPE_BITMAP
         oXbp:side      := .T.
         oXbp:caption   := ""
         oXbp:style     := 2
         oXbp:lInvertImageOnDisable := .F.
         oXbp:disabledColorBG := XBPSYSCLR_INACTIVEBORDER  // quando si imposta questo si deve impostaer anche ::setColorBG() !!!!
         oXbp:setColorBG( XBPSYSCLR_3DFACE )
      ENDIF
      */
      IF ::nBtnHelp != 0 .OR. ::bBtnHelpCheck != NIL
         oXbp := XbpPushButton():new(self)
         oXbp:caption := GET_BTN_DOWNARROWBMP
         //oXbp:pointerFocus := .F.
         oXbp:clipSiblings := .T.
         oXbp:tabStop := .F.
         ::oBtnHelp := oXbp
      ENDIF
   ENDIF

   IF ::oBtnHelp == NIL  // non abilitato da parametro
      RETURN self
   ENDIF

   IF ::oBtnHelp:status() != XBP_STAT_CREATE
      ::oBtnHelp:create(self,NIL,NIL,NIL,NIL,.F.)
   ENDIF

   //reimposto qui il codeblock in modo che esegua il codeblock sul GET corrente
   ::oBtnHelp:setInputFocus:= {|| ::btnHelp()}
   //::oBtnHelp:activate := {|| ::btnHelp()}
   //::oBtnHelp:lbClick:= {|| ::btnHelp()}

   // Simone 10/4/08
   // 0001812: migliorare il pulsante automatico per attivare la calcolatrice
   IF ::bBtnHelpCheck == NIL
      lShow := ::isEnabled() .AND. ;
              ((::get:type == "D" .AND. dfAnd( ::nBtnHelp, 1) != 0) .OR. ;
               (::get:type == "N" .AND. dfAnd( ::nBtnHelp, 2) != 0))
   ELSE
      lShow := EVAL(::bBtnHelpCheck, self, ::oBtnHelp, ::get, ::aCtrl)
   ENDIF

   IF lShow

/*
      IF ::get:type == "D"
         ::oBtnHelp:setCaption("...")
      ELSE
         ::oBtnHelp:setCaption("*")
      ENDIF
*/
/*
      aPos := ::currentPos()
      aSize := ::currentSize()

      aPos[1]+=aSize[1]-8
      aPos[2]-=4

      IF ::getCheckBorderColor() != NIL
         aPos[1]+=2
      ENDIF
      aSize := {12, 12}
*/
/*
      aPos := ::currentPos()
      aPos[2]-=4

      aSize := ::currentSize()
      aSize[2] := 8
      IF ::getCheckBorderColor() != NIL
         aPos[1]+=2
      ENDIF
*/

      aPos := ::currentPos()
      aPos[1]+=::currentSize()[1]
      IF ::getCheckBorderColor() != NIL
         aPos[1]+=4
         aPos[2]++
      ENDIF
      aSize := ::currentSize()
      aSize[1] := 2*COL_SIZE-4 //MAX(18,::currentSize()[2])

/*      aPos := dfCalcAbsolutePosition(aPos, ::setParent(), AppDesktop()) //::setParent():setParent())
      aPos[1]+=2
      aPos[2]++
      ::oBtnHelp:setParent( AppDesktop()) //::setParent():setParent() )
      */
      ::oBtnHelp:setParent( ::setParent() )
      ::oBtnHelp:setPosAndSize(aPos, aSize)

      ::oBtnHelp:show()
      //dfSetXbpOnTop(::oBtnHelp)
   ELSE
      ::hideBtnHelp()
   ENDIF
RETURN self

CLASS METHOD S2Get:hideBtnHelp()
   IF ::oBtnHelp != NIL
      ::oBtnHelp:hide()
   ENDIF
RETURN self


METHOD S2Get:btnHelp()
   ::hideBtnHelp()

   // Simone 10/4/08
   // 0001812: migliorare il pulsante automatico per attivare la calcolatrice
   IF (::bBtnHelpEval != NIL .AND. EVAL(::bBtnHelpEval, self, ::oBtnHelp, ::get, ::aCtrl))

   ELSEIF ::get:type == "D"
      ::lbDblClick()

   ELSEIF ::get:type == "N"
      ::lbDblClick()

   ELSE
      //PostAppEvent(xbeM_RbClick, NIL, NIL, self)
   ENDIF
RETURN self

#endif

METHOD S2Get:KillInputFocus()
   LOCAL xVal

   IF ::isOnCurrentForm() .AND. ::CanSetPage()
      xVal := ::getData()

      ::SetEditBuffer( TRANSFORM(xVal, ::picture) )

#ifdef _ENABLE_AUTOFILL_
      IF ::oAutoFill != NIL .AND. ::get:type $ "CM" .AND. ! ::unReadable
         ::oAutoFill:TextAdd(TRANSFORM(xVal, ::picture))
      ENDIF
#endif

      //#ifdef _S2CTRGET_HILITE_
      IF S2CTRGET_HILITEON()
          // cambia i colori quando riceve input focus,
         // funziona perfettamente ma è disabilitato perchè
         // dovrebbe essere fatto anche per i combo/spin/ecc.
         IF ::isEnabled()
            IF ::nenabledColorFG != NIL
               ::XbpGet:setColorFG(::nenabledColorFG)
            ENDIF
            IF ::nenabledColorBG != NIL
               ::XbpGet:setColorBG(::nenabledColorBG)
            ENDIF
         ENDIF
      ENDIF
      //#endif

      ::oForm:tbDisRef(::cId)
      IF ! EMPTY(::cRefGrp)
         ::oForm:tbDisRef(::cRefGrp)
      ENDIF

      ////////////////////////////////////////
      // 25/08/2011 mantis 2150
      //Inserito e commentato perchŠ pu• portare problemi di stabilit…
      ////////////////////////////////////////
      //::PostGet()
      ////////////////////////////////////////
      ////////////////////////////////////////

   ////////////////////////////////////////////////////
   //Spostato la posizione del Endif in maniera da eseguire sempre l'evenutale ricalcolo
   //Mantis 893 

   ENDIF
   ////////////////////////////////////////////////////

   IF ! (::cInitVal == ::editBuffer())

      // 02/09/2002 simone
      // GERR 3398 aggiunto ::IsActive()
      IF ::IsActive() .AND. ::HasCompGrp()
         ::CompExpExe()
         /////////////////////////////////////////////////
         /////////////////////////////////////////////////
         //Mantis 982
         // Inserito per test per il mioli
         // Luca 7/02/2006
         IF xVAL != NIL
            ::SetData(xVal)
            EVAL(::Datalink,xVal)
         ENDIF
         /////////////////////////////////////////////////
         /////////////////////////////////////////////////
      ENDIF

      IF dfSet(AI_XBASEREFRESH)
         ::oForm:tbDisItm("#") // Refresh totale
      ENDIF
   ENDIF

   ::cInitVal := SPACE(LEN(::editBuffer()))

   ////////////////////////////////////////////////////
   //Spostato la posizione del Endif in maniera da eseguire sempre l'evenutale ricalcolo
   //Mantis 893 
   //ENDIF
   ////////////////////////////////////////////////////

#ifdef _ENABLE_AUTOFILL_
   IF ::oAutoFill != NIL
      ::oAutoFill:closeListbox()
   ENDIF
#endif

#ifdef _ENABLE_HELPBTN_
   IF ::oBtnHelp != NIL
      IF ::oBtnHelp:status() == XBP_STAT_CREATE
         ::oBtnHelp:hide() //destroy()
      ENDIF
      //::oBtnHelp := NIL
   ENDIF

#endif
RETURN self


METHOD S2Get:CanSetFocus()
  LOCAL lRet := ::CanSetPage() .AND. ::IsActive() .AND. ::CanShow() .AND. ::PreGet() //::isEnabled() .AND. ::isVisible()
//RETURN ::CanSetPage() .AND. ::IsActive() .AND. ::CanShow() .AND. ::PreGet() //::isEnabled() .AND. ::isVisible()
RETURN lRet

METHOD S2Get:SetFocus()
   ::setHelpID(::cID)
   ::enable()
RETURN SetAppFocus(self)

METHOD S2Get:hasFocus()
//RETURN SetAppFocus() == self .OR. (::oCombo != NIL .AND. SetAppFocus() == ::oCombo)
  LOCAL lRet := SetAppFocus() == self .OR. (::oCombo != NIL .AND. SetAppFocus() == ::oCombo)
RETURN lRet

METHOD S2Get:setDateFromCalendar()
   LOCAL dDate 
  
   dDate := dfCalendar( CTOD(::Get:BUFFER), self)

   // IF M->A#K_ESC
   IF ACT # "esc" .AND. dDate != CTOD(::Get:BUFFER)
      ::Get:BUFFER := DTOC(dDate)
      ::SetEditBuffer( ::Get:Buffer )
      EVAL(::bSys, ::get)
      ::getData()
      //lucap-simoned - in caso di inserimento di una data tramite l'oggetto calendario deve essere eseguito l'eventuale gruppo di refresh
      // qui altrimenti quando il focus torna sul campo questo è gia cambiato e quando il focus viene nuovamente tolto non essendo stato
      //ulteriormente modificato il campo non viene eseguito il gruppo di refresh
      IF ::HasCompGrp()
         ::CompExpExe()
      ENDIF
   ENDIF
RETURN self

METHOD S2Get:lbDblClick(aPos)
   LOCAL aMarked, n, cStr
   IF ::Get:type $ "DN"    .AND. ;
      ::isOnCurrentForm()  .AND. ;
      ::CanSetPage()       .AND. ;
      ::isEnabled()        .AND. ;
      ::canSetFocus()

      IF ::get:type == "D"
      ::setDateFromCalendar()
      ELSE
         dfCalc()
      ENDIF

   ELSEIF ::isOnCurrentForm() .AND. ::CanSetPage()

      // doppio click seleziona parola
     ::get:wordLeft()
     aMarked := {1, 1}
     aMarked[1] :=  ::get:pos

     cStr := ::editBuffer()
     n := aMarked[1]
     DO WHILE ++n <= LEN(cStr) .AND. ;
             ! DFCHAR(cStr, n)==" "
     ENDDO
     ::get:pos := n
     aMarked[2] :=  ::get:pos
     ::SetMarked( aMarked )
   ENDIF
RETURN self

METHOD S2Get:Keyboard( nKey )
   LOCAL aMarked, cChar, lHandled := .T., nPos := 0
   LOCAL setPos    := .T.
   LOCAL xPrec
   LOCAL lChkCalc  := .F.
   LOCAL lPost
   LOCAL uDmm, dDate
   LOCAL cAct
   // MATTEO
   // 14:44:32 marted 14 marzo 2000
   LOCAL nOldPos
   // ----------

   IF ::isOnCurrentForm() .AND. ::CanSetPage()
      IF ! ::editable
         IF nKey == xbeK_CTRL_INS .OR. nKey == xbeK_CTRL_C
            ::copyMarked()
         ELSE
            // tasti abilitati quando GET non editabile
            xPrec := {xbeK_SH_RIGHT, xbeK_SH_LEFT, xbeK_SH_END, xbeK_SH_HOME, ;
                      xbeK_CTRL_LEFT, xbeK_CTRL_RIGHT, xbeK_LEFT, xbeK_RIGHT, ;
                      xbeK_HOME, xbeK_END, xbeK_INS}

            IF ASCAN(xPrec, nKey) > 0
               ::XbpGet:keyboard(nKey)
            ENDIF
         ENDIF
         RETURN self
      ENDIF
      aMarked := ::QueryMarked()

      DO CASE
      CASE ::handleAction( ACT )
#ifdef _ENABLE_AUTOFILL_
      CASE ::oAutoFill != NIL .AND. ;
           ::oAutoFill:listBoxVisible() .AND. ACT $"uar,dar,ret"
           // non faccio niente, gestisco dopo con autofill!
#endif

      CASE ACT $ "uar,Stb"
           ::oForm:skipFocus(-1)
#ifdef _ENABLE_HELPBTN_
         ::hideBtnHelp()
#endif
           lHandled := .T.

      CASE ACT == "tab" .OR. ACT == "ret" .OR. ACT == "Ada" .OR. ;
           ACT == "Cda" .OR. ACT == "win" .OR. ACT == "dar" .OR. ;
           ACT == "C07" .OR. ACT == "A07" .OR. ACT == "wri" .OR. ;
           ACT == "new"

           IF ACT == "win"
              ACT := "Ada"
           ENDIF

           IF ACT == "C07"
              ACT := "Cda"
           ENDIF

           cAct := ACT

           ::GetData()


           // Modifica Simone 1/3/2001 (MESSO COMMENTO ALL'IF SOTTOSTANTE)
           // Faccio sempre fare il ricalcolo come
           // dbsee x DOS che lo fa sempre.
           // IF ACT $ "Ada,wri,new"
              // In caso di richiamo finestra di lookup
              // faccio effettuare il ricalcolo
              xPrec := EVAL(::dataLink)
              lChkCalc := .T.
           // ENDIF

           lPost := ::PostGet()
           IF ! lPost
              ACT := "rep"
           ENDIF
           ::setData()

           IF lPost

              IF lChkCalc .AND. (! xPrec == EVAL(::dataLink))
                 IF ::HasCompGrp()
                    ::CompExpExe()
                 ENDIF

                 IF dfSet(AI_XBASEREFRESH)
                    ::oForm:tbDisItm("#") // Refresh totale
                 ENDIF
              ENDIF

              // SD 27/02/03 GERR 3672 commentato questo pezzo
              //
              // IF ! cAct $ "wri,new,esc"
              //    IF ::oCombo != NIL .OR. ;
              //       cAct $ "tab,ret,dar"
              //       ::oForm:skipFocus(1)
              //    ENDIF
              // ENDIF

              IF cAct $ "tab,ret,dar"
                 ::oForm:skipFocus(1)
#ifdef _ENABLE_HELPBTN_
                 ::hideBtnHelp()
#endif
              ENDIF

           ENDIF

           lHandled := .T.

      CASE ACT == "Sra"

           IF ! Set( _SET_INSERT)
              aMarked[2]--
           ENDIF

           nPos := ::get:pos

           ::Get:right()

           IF nPos != ::get:pos

              IF nPos == aMarked[2]
                 aMarked[2] := ::Get:Pos
              ELSE
                 aMarked[1] := ::Get:Pos
              ENDIF
           ENDIF

           IF ! Set( _SET_INSERT )
              aMarked[2]++
           ENDIF

           ::SetMarked( aMarked )
           setPos := .F.


      CASE ACT == "Sla"

           IF ! Set( _SET_INSERT)
              aMarked[2]--
           ENDIF

           nPos := ::get:pos

           ::Get:left()

           IF nPos != ::get:pos

              IF nPos == aMarked[1]
                 aMarked[1] := ::Get:Pos
              ELSE
                 aMarked[2] := ::Get:Pos
              ENDIF
           ENDIF

           IF ! Set( _SET_INSERT )
              aMarked[2]++
           ENDIF

           ::SetMarked( aMarked )
           setPos := .F.


      CASE ACT == "Snd"

           ::get:end()
           aMarked[2] := ::get:pos + 1

           // aMarked[2] := ::Bufferlength + 1
           // ::Get:Pos  := ::Bufferlength
           ::SetMarked( aMarked )

           setPos := .F.

      CASE ACT == "Sho"
           ::Get:Pos  := 1
           aMarked[1] := 1
           ::SetMarked( aMarked )
           setPos := .F.

      CASE ACT == "C_u"
           ::Undo()
      //Mantis 641
      CASE Act=="A01" .AND. ::Get:type == "N"
           dfCalc()

      CASE ::lNumericInput

            DO CASE
               // Simone 27/3/08
               // mantis 0000667: Migliorare la libreria e la gestione delle GET numeriche.
               CASE ::dfGetFirst( ::lFirstChar, nKey, ::get ) .OR. ;
                    (::lFirstChar .AND. ACT $ "ecr,bks,rar,lar")
                  IF ! ACT $ "rar,lar"
                  ::get:BUFFER := SPACE(LEN(::get:BUFFER))
                  ENDIF
                  // Posiziono a destra
                  IF ::get:decPos > 0 .AND. ::get:decPos < ::bufferLength
                     ::get:POS     := ::get:DECPOS-1
                  ELSE
                     ::get:pos := ::bufferLength
                  ENDIF

                  PostAppEvent(xbeP_Keyboard, nKey, NIL, self)


               // Simone 27/3/08
               // mantis 0000667: Migliorare la libreria e la gestione delle GET numeriche.
               // commentato tutto
               // //Gerr. 3169 Luca 29/10/03 Malfunzionamento della selezione
               // //e cancellazione nelle get Numeriche.
               // // Inserito un nuovo CASE OF...
               // CASE nKey == xbeK_DEL  .AND. ACT == "ecr" .AND. ;
               //     ::Get:decPos > 0 .AND. ::get:pos > ::get:decPos
               //     ::DeleteMarked()
               CASE ::get:DECPOS>0 .AND. M->Sa$",."
                  // Simone 27/3/08
                  // mantis 0000667: Migliorare la libreria e la gestione delle GET numeriche.
                  ::dfPutBuf(::get, ::cNumPicture) // write buffer
                  ::get:POS := ::get:DECPOS+1

               CASE ACT == "end"
                  IF ::get:DECPOS>0 .AND. ::get:DECPOS<LEN(::get:BUFFER)
                     IF ::get:pos > ::get:DECPOS
                        ::get:Pos := LEN(::get:BUFFER)
                     ELSE
                        ::get:Pos := ::get:DECPOS - 1
                     ENDIF
                  ELSE
                     ::get:Pos := LEN(::get:BUFFER)
                  ENDIF

               CASE ACT == "hom"
                  IF ::get:DECPOS>0 .AND. ::get:DECPOS<LEN(::get:BUFFER)
                     IF ::get:pos > ::get:DECPOS
                        ::get:pos := ::get:DECPOS +1
                     ELSE
                        ::get:pos := 1
                     ENDIF
                  ELSE
                     ::get:pos := 1
                  ENDIF

               CASE ACT == "lar" .AND. ::get:pos > 1
                  IF !SUBSTR(::get:Buffer,::get:Pos,1) $ " -" .OR. ;
                     ::get:pos > ::get:decPos

                     IF SUBSTR(::get:Buffer,::get:Pos-1,1) $ ".," .OR. ;
                        SUBSTR(::get:PICTURE,::get:Pos+2,1) $ ".,"
                        IF ::get:pos > 2
                           ::get:pos -= 2
                        ENDIF
                     ELSE
                        ::get:pos--
                     ENDIF
                  ENDIF

               CASE ACT == "rar"
                  IF ::get:Pos<LEN(::get:BUFFER)
                     ::get:pos++
                  ENDIF
                  IF SUBSTR(::get:Buffer,::get:Pos,1) $ ".,"
                     ::get:Pos++
                  ENDIF

               CASE ACT $ "ecr,bks" .OR. M->Sa$"1234567890-+"
                  ::dfPutBuf(::get, ::cNumPicture) // write buffer

               CASE SA=="*"
                  // KEYBOARD "000"

               CASE nKey>32
               CASE ACT == "C_y"
                  ::get:BUFFER := SPACE(LEN(::get:BUFFER))
                  ::get:POS    := ::get:DECPOS-1

            ENDCASE
            ::lFirstChar := .F.


      CASE ACT == "rar"
           ::Get:Right()

      CASE ACT == "Cra"
           ::Get:WordRight()

      CASE ACT == "lar"
           // MATTEO
           // 14:44:17 marted 14 marzo 2000
           nOldPos := ::Get:pos
           // ----------

           ::Get:Left()

           // MATTEO
           // 14:20:15 marted 14 marzo 2000
           // Aggiunto perche', se ho delle get corte, non riesco ad andare
           // al primo valore
           IF ::Get:pos==1 .AND. nOldPos!=1
              ::disable()
              ::setfocus()
           ENDIF
           // -----------

      CASE ACT == "Cla"
           ::Get:WordLeft()

      CASE ACT == "hom"
           // 14:17:11 marted 14 marzo 2000
           // Aggiunto perche', se ho delle get corte, non riesco ad andare
           // al primo valore
           IF ::Get:pos!=1
              ::disable()
              ::setfocus()
           ENDIF
           // --------

           ::Get:Home()
           ::SetFirstChar( 1 )

      CASE ACT == "end"
           ::Get:_End()

      CASE ACT == "anr"
           Set( _SET_INSERT, ! Set( _SET_INSERT) )

      CASE ACT == "Sin" .OR. ACT == "C_v"
           IF ::editable
              ::PasteMarked()
           ENDIF

      CASE ACT == "Cin" .OR. ACT == "C_c"
           ::CopyMarked()

      CASE ACT == "bks"
           IF ::editable
              ::Get:BackSpace()
           ENDIF

      CASE nKey == xbeK_SH_DEL .OR. ACT == "C_x"
           IF ::editable
              ::CutMarked()
           ENDIF

      CASE ACT == "ecr"
           IF ::editable
              ::DeleteMarked()
           ENDIF

      CASE ACT == "C_t"
           IF ::editable
              ::Get:DelWordRight()
           ENDIF

      CASE ACT == "C_y"
           IF ::editable
              ::Get:DelEnd()
           ENDIF

      CASE ACT == "Cbs"
           IF ::editable
              ::Get:DelWordLeft()
           ENDIF

      CASE ::Get:type == "D" .AND. ((! EMPTY(SA) .AND. SA $ "-+") .OR. ACT="A02")
           uDmm:=SET( _SET_DATEFORMAT )
           DO CASE
              CASE M->Sa=="+"
                   DO CASE
                      CASE SUBSTR(uDmm,::get:POS,1)=="d"
                           ::get:buffer := DTOC(CTOD(::get:buffer)+1)

                      CASE SUBSTR(uDmm,::get:POS,1)=="m"
                           ::get:buffer := DTOC(dfAddMonth(CTOD(::get:buffer),1))

                      CASE SUBSTR(uDmm,::get:POS,1)=="y"
                           ::get:buffer := DTOC(dfAddYear(CTOD(::get:buffer),1))

                   ENDCASE

                   lHandled := .T.

              CASE M->Sa=="-"
                   DO CASE
                      CASE SUBSTR(uDmm,::get:POS,1)=="d"
                           ::get:buffer := DTOC(CTOD(::get:buffer)-1)

                      CASE SUBSTR(uDmm,::get:POS,1)=="m"
                           ::get:buffer := DTOC(dfAddMonth(CTOD(::get:buffer),-1))

                      CASE SUBSTR(uDmm,::get:POS,1)=="y"
                           ::get:buffer := DTOC(dfAddYear(CTOD(::get:buffer),-1))

                   ENDCASE
                   lHandled := .T.

              CASE Act=="A02"
                   ::setDateFromCalendar()
                   lHandled := .T.
           ENDCASE

      CASE nKey >= 32 .AND. nKey <= 255
           cChar := CHR(nKey)

           IF ::Get:Type == "N" .AND. cChar $ ".," .AND. ::get:decPos > 0
              // workaround per PDR 4732 (Get:ToDecPos() will delete minus character )
              //::Get:ToDecPos()
              ::Get:condClear()
              ::Get:end()
              DO WHILE ::Get:pos > (::Get:decPos + 1)
                 ::Get:left()
              ENDDO


           ELSE

              // IF ::editable
              //    IF Set(_SET_INSERT)
              //       ::Get:Insert( cChar )
              //    ELSE
              //       ::Get:Overstrike( cChar )
              //    ENDIF
              // ENDIF

               IF ::editable

                  IF (Set( _SET_INSERT) .AND. aMarked[1] < aMarked[2]) .OR. ;
                     (!Set( _SET_INSERT) .AND. aMarked[1] < aMarked[2]-1)

                     IF ! ::get:type == "N"
                        // Se c'Š la selezione
                        ::get:pos := aMarked[1]

                        DO WHILE aMarked[1] < aMarked[2]
                           ::get:delete()
                           aMarked[2]--
                        ENDDO
                     ENDIF

                  ENDIF

                  IF Set(_SET_INSERT)
                     ::Get:Insert( cChar )
                  ELSE
                     ::Get:Overstrike( cChar )
                  ENDIF

                  // No space remaining to the right of the cursor to type
                  IF ::Get:typeOut
                     IF !SET(_SET_CONFIRM)
                        dbAct2Kbd( "ret" )
                     ENDIF
                  ENDIF
               ENDIF

           ENDIF

      OTHERWISE
           lHandled := .F.

      ENDCASE

      IF ! ::EditBuffer() == ::Get:Buffer
         ::SetEditBuffer( ::Get:Buffer )
         EVAL(::bSys, ::get)
      ENDIF

      IF setPos
         IF Set( _SET_INSERT )
            aMarked := { ::Get:Pos, ::Get:Pos }
         ELSE
            aMarked := { ::Get:Pos, ::Get:Pos + 1 }
         ENDIF
      ENDIF
      ::SetMarked( aMarked )

#ifdef _ENABLE_AUTOFILL_
      IF ::oAutoFill != NIL .AND. ::get:type $ "CM" .AND. ! ::unReadable
         ::oAutoFill:autoFill(@nKey,NIL,NIL,LEFT(::editBuffer(),::get:pos-1))
//         IF nKey==NIL // evito gestione standard
//            lHandled := .T.
//         ENDIF
      ENDIF
#endif

      IF ! lHandled
         RETURN ::XbpGet:Keyboard( nKey )
      ENDIF

   ENDIF

RETURN self
