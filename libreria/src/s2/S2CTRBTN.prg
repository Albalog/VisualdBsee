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

#define BS_MULTILINE 0x2000
#define BS_CENTER    0x0300
#define BS_VCENTER   0x0C00
#define BS_BOTTOM    0x0800


MEMVAR ACT, A, SA

// -----------------------------------------------------------
// SIMONE 20/09/02
// NOTA I COLORI PER PUSHBUTTON NON SONO SUPPORTATI DA XBASE++
// PERO' IL CODICE PER IMPOSTARLI C'E' MA OVVIAMENTE
// I COLORI NON CAMBIANO
// -----------------------------------------------------------

// S2PushButton: CTRL_BUTTON
// -------------------------

#ifdef IE4_STYLE
   #define _SUPERCLASS ie4Button
#else
   #define _SUPERCLASS XbpPushButton
#endif

FUNCTION S2GetPushButtonStyle(aCtrl)
   LOCAL nRet   := BUT_PS_STD
   LOCAL cStyle

   IF ! EMPTY(aCtrl)                            .AND. ;
      LEN(aCtrl) >= FORM_BUT_PAINTSTYLE         .AND. ;
      VALTYPE(aCtrl[FORM_BUT_PAINTSTYLE]) == "N"

      RETURN aCtrl[FORM_BUT_PAINTSTYLE]
   ENDIF
RETURN dfSet(AI_XBASEBUTSTYLE)
/*
   cStyle := dfSet(AI_XBASEBUTSTYLE)

   DO CASE
      CASE EMPTY(cStyle)
        nRet := BUT_PS_SYSTEM
      CASE cStyle == "1"
        nRet := BUT_PS_FLAT1
      CASE cStyle == "2"
        nRet := BUT_PS_FLAT2
   ENDCASE
RETURN nRet
*/

FUNCTION S2GetPushButtonClass(aCtrl)
   LOCAL oBtn
   IF S2GetPushButtonStyle(aCtrl) == BUT_PS_STD
      oBtn := S2PushButton()
   ELSE
      oBtn := S2PushButtonX()
   ENDIF
RETURN oBtn

CLASS S2PushButton FROM XbpPushButton, _PushButton
EXPORTED:
   METHOD init

   INLINE METHOD SetInputFocus()
      ::__SetInputFocus()
   RETURN ::XbpPushButton:SetInputFocus()

   INLINE METHOD SetCaption(xCaption, nBmp, xBmpID)
      ::__SetCaption(@xCaption, @nBmp, @xBmpID)
      //////////////////////////////////////////////////////////////
      //Mantis 1254
      IF VALTYPE(xCaption) == "C"
         IF AT("//", xCaption)> 0 .OR. AT(CRLF, xCaption)> 0
            xCaption := STRTRAN(xCaption,"//", CRLF )
            //dfXBPSetStyle(::XbpPushButton,BS_MULTILINE , .T.)
            //dfXBPSetStyle(oOBJ,BS_CENTER, .T.)
            //dfXBPSetStyle(oOBJ,BS_BOTTOM, .T.)
         ENDIF
      ENDIF
      //////////////////////////////////////////////////////////////
   RETURN ::XbpPushButton:setCaption(::ChgHotKey(xCaption, nBmp, xBmpID))

   INLINE METHOD Keyboard(n)
      IF ! ::__Keyboard(n)
         ::XbpPushButton:Keyboard(n)
      ENDIF
   RETURN self
ENDCLASS

METHOD S2PushButton:Init( aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
  ::_PushButton:init(self, aCtrl, nPage, oFormFather, @oParent, @oOwner, @aPos, @aSize, @aPP, @lVisible )

   ::XbpPushButton:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::activate := aCtrl[FORM_BUT_FUNCTION]
   ::rbDown   := oParent:rbDown
   ::caption  := ::ChgHotKey(aCtrl[FORM_BUT_PROMPT], ;
                             aCtrl[FORM_BUT_BITMAP], ;
                             aCtrl[FORM_BUT_BITMAPID] )
RETURN self


CLASS S2PushButtonX FROM S2ButtonX, _PushButton
EXPORTED:
   METHOD init

   METHOD setInputFocus
   METHOD setCaption
   METHOD keyboard
ENDCLASS

METHOD S2PushButtonX:Init( aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL xCaption, oPS, cColor
   ::_PushButton:init(self, aCtrl, nPage, oFormFather, @oParent, @oOwner, @aPos, @aSize, @aPP, @lVisible )

   ::S2ButtonX:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::activate := aCtrl[FORM_BUT_FUNCTION]
   ::rbDown   := oParent:rbDown





   IF VALTYPE( ::_ChgHotKey(xCaption) ) == "N" // conversione standard Bitmaps di navigazione
      ::Image   := xCaption
      ::ImageType := XBPSTATIC_TYPE_BITMAP
      ::side := .T.
      ::caption := ""
   ELSE
      xCaption  := ::ChgHotKey(aCtrl[FORM_BUT_PROMPT], ;
                               aCtrl[FORM_BUT_BITMAP], ;
                               aCtrl[FORM_BUT_BITMAPID] )

      IF VALTYPE(xCaption) $ "CM"
         // bottone solo testo
         ::caption := xCaption
      ELSE
         // bottone immagine (e testo)

         // per maggiore compatibilit… con i pulsanti standard
         // abilito il testo solo se Š specificato sul pulsante ma
         // lo abilito se uso questa classe da default dbstart.ini
         // altrimenti l'immagine non viene centrata
         IF LEN(aCtrl) >= FORM_BUT_PAINTSTYLE .AND. ;
            VALTYPE(aCtrl[FORM_BUT_PAINTSTYLE]) == "N"
            ::caption   := ::_ChgHotKey(aCtrl[FORM_BUT_PROMPT])
            ::side := .T.
         ELSE
            ::caption   := ""
            ::side := .F.
         ENDIF
         ::Image     := xCaption
         ::ImageType := XBPSTATIC_TYPE_BITMAP
      ENDIF
   ENDIF
/*
   xCaption  := ::ChgHotKey(aCtrl[FORM_BUT_PROMPT], ;
                            aCtrl[FORM_BUT_BITMAP], ;
                            aCtrl[FORM_BUT_BITMAPID] )
   IF VALTYPE(xCaption) $ "CM"
      ::caption := xCaption
   ELSE
      ::Image   := xCaption
      ::ImageType := XBPSTATIC_TYPE_BITMAP
      ::side := .T.
   ENDIF
*/
   ::style    := S2GetPushButtonStyle( aCtrl )

   // questo tipo di pushbutton non supporta i presparameters
   IF ! EMPTY(aCtrl[FORM_BUT_FONTCOMPOUNDNAME])
      ::setFontCompoundName(aCtrl[FORM_BUT_FONTCOMPOUNDNAME])
   ENDIF
   IF ::oForm:hasBitmapBG()
      ::setColorBG(XBPSYSCLR_3DFACE) // colore di default, serve per sfondi con bitmap
   ENDIF

   ///////////////////////////////////////////////////////////////
   //Luca 16/02/2016 Gestione del colore per i bottoni stile flat
   ///////////////////////////////////////////////////////////////
   IF !EMPTY(aCtrl[FORM_BUT_CLRNULL])
      IF LEN(aCtrl[FORM_BUT_CLRNULL])>=2
         cColor := aCtrl[FORM_BUT_CLRNULL][1]
         IF VALTYPE(cColor) == "N"
            ::S2ButtonX:setColorFG(cColor)
            ::S2ButtonX:nPrevColorFG := cColor
         ELSE
            cColor := S2DbseeColorToRGB(cColor,.T.) //, "R")
            ::S2ButtonX:setColorFG(cColor)
            ::S2ButtonX:nPrevColorFG := cColor
         ENDIF
         cColor := aCtrl[FORM_BUT_CLRNULL][2]
         IF VALTYPE(cColor) == "N"
            ::S2ButtonX:setColorBG(cColor)
            ::S2ButtonX:nPrevColorBG := cColor
         ELSE
            cColor := S2DbseeColorToRGB(cColor,.T.) //, "R")
            ::S2ButtonX:setColorBG(cColor)
            ::S2ButtonX:nPrevColorBG := cColor
         ENDIF
      ENDIF
      IF LEN(aCtrl[FORM_BUT_CLRNULL])==3
         cColor := aCtrl[FORM_BUT_CLRNULL][3]
         IF VALTYPE(cColor) == "N"
            ::S2ButtonX:focusColorFG := cColor
         ELSE
            cColor := S2DbseeColorToRGB(cColor,.T.) //, "R")
            ::S2ButtonX:focusColorFG := cColor
         ENDIF
      ENDIF
   ENDIF
   ///////////////////////////////////////////////////////////////


RETURN self

METHOD S2PushButtonX:SetInputFocus()
   ::_PushButton:__SetInputFocus()
RETURN ::S2ButtonX:SetInputFocus()

METHOD S2PushButtonX:SetCaption(xCaption, nBmp, xBmpID)
   LOCAL xTCaption
   LOCAL xRet, nPOS
   ::_PushButton:__SetCaption(@xCaption, @nBmp, @xBmpID)

   xTCaption := ::ChgHotKey(xCaption, nBmp, xBmpID)

   IF VALTYPE(xTCaption) $ "CM"
      ::Image := NIL
      //////////////////////////////////////////////////////////////
      //Mantis 1254
      IF AT("//", xTCaption)> 0 .OR. AT(CRLF, xTCaption)> 0
         xTCaption := STRTRAN(xTCaption,"//", CRLF )
         //dfXBPSetStyle(::S2ButtonX,BS_MULTILINE , .T.)
      ENDIF
      //////////////////////////////////////////////////////////////

      xRet := ::S2ButtonX:setCaption(xTCaption)
      ::configure()
   ELSE
      xRet := ::S2ButtonX:setCaption("")
      ::Image := xTCaption
      ::ImageType := XBPSTATIC_TYPE_BITMAP
      ::side := .T.
      ::configure()
   ENDIF
RETURN xRet

METHOD S2PushButtonX:Keyboard(n)
   IF ! ::_PushButton:__Keyboard(n)
      ::S2ButtonX:Keyboard(n)
   ENDIF
RETURN self


*------------------
// CLASSE _PushButton CON METODI COMUNI A TUTTE LE CLASSI PushButton

STATIC CLASS _PushButton FROM S2Control, S2CtrlHelp

   PROTECTED:
      CLASS VAR aButCol // colori del pulsante
      CLASS METHOD initClass          // Declares class method


      VAR oBtn // riferimento alla classe pushbutton visuale

      VAR oBmp
      VAR cHotKey // contiene il prompt per il tasto "caldo"
      METHOD CtrlArrInit, ChgHotKey, _ChgHotKey, setHotKey

      // Deve usare l'oggetto XbpBitmap?
      // si se ID=carattere/array o se Š un numero ma devo fare autosize
      INLINE METHOD useBmpObject(nBmp, xBmpID)
     #ifdef _XBASE17_
      RETURN ::isBmpButton(nBmp) .AND. ;
             (VALTYPE(xBmpID) $"CMA" .OR. ;
              (VALTYPE(xBmpID) == "N"  .AND. nBmp==BUT_BMP_SIZE) )
     #else
      RETURN .F.
     #endif


      INLINE METHOD useBmpSize(nBmp, xBmpID)
     #ifdef _XBASE17_
      RETURN nBmp==BUT_BMP_SIZE .AND. VALTYPE(xBmpID) $"CMNA"
     #else
      RETURN .F.
     #endif

      INLINE METHOD getBmpSize(xBmpID)
         LOCAL aSize
         LOCAL oBmp := S2XbpBitmap():new():create()
         IF (VALTYPE(xBmpId) == "N" .AND. oBmp:load(NIL, xBmpId)) .OR. ;
            (VALTYPE(xBmpId) == "A" .AND. oBmp:load(xBmpId[1], xBmpId[2])) .OR. ;
            (VALTYPE(xBmpId) $  "CM" .AND. oBmp:loadFile(xBmpId))
            aSize := {oBmp:xSize, oBmp:ySize}
         ENDIF
         oBmp:destroy()
         oBmp:=NIL
      RETURN aSize

      INLINE METHOD isBmpButton(nBmp)
         DEFAULT nBmp  TO ::aCtrl[FORM_BUT_BITMAP]
      RETURN ! EMPTY(nBmp) .AND. ;
             (nBmp == BUT_BMP_YES .OR. nBmp == BUT_BMP_SIZE)

   EXPORTED:
      VAR bActive, cMsg
      METHOD Init, DispItm, isShortCut //, handleEvent
      METHOD SetFocus, hasFocus, CanSetFocus, IsActive
      METHOD UpdControl
      METHOD __SetInputFocus, __Keyboard, __setCaption

ENDCLASS

CLASS METHOD _PushButton:initClass      // Code for class method
   ::aButCol := dfColor( "ButtonDefault" )
RETURN self                        // class variables

METHOD _PushButton:Init( oBtn, aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos

   ::oBtn := oBtn

   ::CtrlArrInit( aCtrl, oFormFather )

   // Calcola le coordinate
   // ---------------------

   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF S2PixelCoordinate(aCtrl)

      DEFAULT aPos TO {aCtrl[FORM_BUT_LEFT], aCtrl[FORM_BUT_TOP]}
      DEFAULT aSize TO {aCtrl[FORM_BUT_RIGHT],aCtrl[FORM_BUT_BOTTOM] }
   ELSE
      oPos := PosCvt():new(aCtrl[FORM_BUT_LEFT]+.5, aCtrl[FORM_BUT_BOTTOM])
      oPos:Trasla(oParent)

      DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}

      IF ::useBmpSize(aCtrl[FORM_BUT_BITMAP], aCtrl[FORM_BUT_BITMAPID])
         aSize := ::getBmpSize(aCtrl[FORM_BUT_BITMAPID])
         IF ! EMPTY(aSize)
            aSize[1]+=2
            aSize[2]+=2
         ENDIF
      ENDIF

      oPos:SetDos(aCtrl[FORM_BUT_RIGHT]  - aCtrl[FORM_BUT_LEFT] , ; //+ 1, ;
                  aCtrl[FORM_BUT_BOTTOM] - aCtrl[FORM_BUT_TOP] -1)

      DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}

      DEFAULT lVisible TO .F.
   ENDIF

#ifndef _NOFONT_
   IF ! EMPTY(aCtrl[FORM_BUT_FONTCOMPOUNDNAME])
      DEFAULT aPP TO {}
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_BUT_FONTCOMPOUNDNAME])
      //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_BUT_FONTCOMPOUNDNAME]})
   ENDIF
#endif


   // Imposta i colori nei pres. param. per foreground/background/disabled
   aPP := S2PPSetColors(aPP, {.T., 0}, aCtrl[FORM_BUT_CLRPROMPT], APPCOLOR_BTN)

   S2ItmSetColors({|| NIL}, {|n|  aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_BGCLR, n) }, ;
                     .T., aCtrl[FORM_BUT_CLRDISABLEDPROMPT])


   ::S2Control:init(aCtrl, nPage, oFormFather)
   ::oBmp     := NIL
   ::setHotKey(aCtrl[FORM_BUT_PROMPT])
   ::bActive  := aCtrl[FORM_BUT_ACTIVE]
   ::cMsg     := aCtrl[FORM_BUT_MESSAGE]
RETURN self

METHOD _PushButton:ChgHotKey(xCaption, nBmp, xBmpID)
   LOCAL xRet
   LOCAL xTmp

   IF ::oBmp != NIL .AND. ::oBmp:status() == XBP_STAT_CREATE
      ::oBmp:destroy()
   ENDIF
   ::oBmp := NIL

   IF ::isBmpButton(nBmp)

      IF ::useBmpObject(nBmp, xBmpID)

      #ifdef _XBASE17_
         // Attivo solo da Xbase 1.7 in poi
         // -------------------------------

         ::oBmp := S2XbpBitmap():new():create()
         IF (VALTYPE(xBmpId) == "N" .AND. ::oBmp:load(NIL, xBmpId)) .OR. ;
            (VALTYPE(xBmpId) == "A" .AND. ::oBmp:load(xBmpId[1], xBmpId[2])) .OR. ;
            (VALTYPE(xBmpId) $  "CM" .AND. ::oBmp:loadFile(xBmpId))

            xRet := ::oBmp
         ELSE
            ::oBmp:destroy()
            ::oBmp := NIL
            xRet := ""
         ENDIF

      #else
         xRet := ""
      #endif

      ELSEIF VALTYPE(xBmpID) == "N"
        xRet := xBmpID

      ELSE
        xRet := ::_ChgHotKey(xCaption)

      ENDIF
   ELSE
      xRet := ::_ChgHotKey(xCaption)
   ENDIF

   // se Š un ID numerico
   // ed esiste una corrispondente risorsa utente (USERDEF IMAGES in file .ARC)
   // allora uso la risorsa utente
   IF VALTYPE(xRet) == "N"
      xTmp :=LoadResource(xRet, NIL, "IMAGES")
      IF EMPTY(xTmp)
         // se Š una risorsa standard metto trasparente il colore di background
         IF ASCAN({BTN_GOTOP, BTN_PREV, BTN_NEXT, BTN_PREV2, BTN_NEXT2, BTN_GOBOTTOM}, xRet) > 0
            xRet := dfGetImgObject(xRet, NIL, {192, 192, 192})
         ENDIF

      ELSE

         ::oBmp := S2XbpBitmap():new():create()
         IF (VALTYPE(xBmpId) == "N" .AND. ::oBmp:load(NIL, xBmpId)) .OR. ;
            (VALTYPE(xBmpId) == "A" .AND. ::oBmp:load(xBmpId[1], xBmpId[2])) .OR. ;
            (VALTYPE(xBmpId) $  "CM" .AND. ::oBmp:loadFile(xBmpId))

            xRet := ::oBmp
         ELSE
            ::oBmp:destroy()
            ::oBmp := NIL
            xRet := ""
         ENDIF

      ENDIF
   ENDIF

RETURN xRet

// Converto i pulsanti di default con le bitmap
METHOD _PushButton:_ChgHotKey(xCaption)
   LOCAL nPos
   LOCAL xRet
   LOCAL aChg := { {"|<" , BTN_GOTOP    }, ;
                   {"||<", BTN_GOTOP    }, ;
                   {"|<<", BTN_GOTOP    }, ;
                   {"<"  , BTN_PREV     }, ;
                   {">"  , BTN_NEXT     }, ;
                   {""  , BTN_PREV     }, ;
                   {""  , BTN_NEXT     }, ;
                   {"<<" , BTN_PREV2    }, ;
                   {">>" , BTN_NEXT2    }, ;
                   {">|" , BTN_GOBOTTOM }, ;
                   {">>|", BTN_GOBOTTOM }, ;
                   {">||", BTN_GOBOTTOM }  }
//                   {"^Ins."   , TOOLBAR_ADD }, ;
//                   {"^Mod."   , TOOLBAR_MOD }, ;
//                   {"C^anc."  , TOOLBAR_DEL }, ;
//                   {"^Ric."   , TOOLBAR_FIND }, ;
//                   {"^Stampa" , TOOLBAR_PRINT }, ;
//                   {"^Pag.Su" , TOOLBAR_PG_PREV }, ;
//                   {"Pag.^Gi—", TOOLBAR_PG_NEXT } }

   IF VALTYPE(xCaption) $ "CM"
      nPos := ASCAN(aChg, {|x| x[1]==xCaption })
      IF nPos > 0
         // Se Š un pulsante standard metto la bitmap
         xRet := aChg[nPos][2]
      ELSE
         // Altrimenti conversione standard

         // Se Š un multiriga diventa di una riga sola
         // (multiriga non supportato)!


         //////////////////////////////////////////////////////////////
         //Mantis 1254
         //IF "//" $ xCaption
         //   xCaption := LEFT(xCaption, AT("//", xCaption)-1)
         //ENDIF
         //////////////////////////////////////////////////////////////

         //////////////////////////////////////////////////////////////
         //Mantis 1254
         IF AT("//", xCaption)> 0 .OR. AT(CRLF, xCaption)> 0
            xCaption := STRTRAN(xCaption,"//", CRLF )
            dfXBPSetStyle(::oBtn,BS_MULTILINE , .T.)
         ENDIF
         //////////////////////////////////////////////////////////////

         xRet := ::S2Control:ChgHotKey(xCaption)
      ENDIF
   ELSE
      xRet := xCaption
   ENDIF
RETURN xRet


METHOD _PushButton:CtrlArrInit( aCtrl, oFormFather )
   DEFAULT aCtrl[FORM_BUT_ACTIVE]     TO {||.T.}
   DEFAULT aCtrl[FORM_BUT_FUNCTION]   TO {||.T.}
   DEFAULT aCtrl[FORM_BUT_MESSAGE]    TO ""
   DEFAULT aCtrl[FORM_BUT_CLRID]      TO {}
   ASIZE( aCtrl[FORM_BUT_CLRID], 9 )

   IF EMPTY aCtrl[FORM_BUT_CLRTOPLEFT     ]   ASSIGN ::aButCol[AC_BUT_TNORMAL  ]
   IF EMPTY aCtrl[FORM_BUT_CLRPROMPT      ]   ASSIGN ::aButCol[AC_BUT_NORMAL   ]
   IF EMPTY aCtrl[FORM_BUT_CLRHOTKEY      ]   ASSIGN ::aButCol[AC_BUT_HOTNORMAL]
   IF EMPTY aCtrl[FORM_BUT_CLRBOTTOMRIGHT ]   ASSIGN ::aButCol[AC_BUT_BNORMAL  ]
   IF EMPTY aCtrl[FORM_BUT_CLRHILITEPROMPT]   ASSIGN ::aButCol[AC_BUT_SELECTED ]
   IF EMPTY aCtrl[FORM_BUT_CLRHILITEHOTKEY]   ASSIGN ::aButCol[AC_BUT_SELECTED ]

   IF EMPTY aCtrl[FORM_BUT_CLRDISABLEDPROMPT] ASSIGN dfSet( AI_BUTDISABLEDPROMPT )
   IF EMPTY aCtrl[FORM_BUT_CLRDISABLEDHOTKEY] ASSIGN dfSet( AI_BUTDISABLEDHOTKET )
   IF EMPTY aCtrl[FORM_BUT_PROMPT]            ASSIGN ""

#ifndef _NOFONT_
   ASIZE(aCtrl, FORM_BUT_CTRLARRLEN)
   aCtrl[FORM_BUT_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_BUT_FONTCOMPOUNDNAME ])
   IF EMPTY aCtrl[FORM_BUT_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseBtnFont")
   IF EMPTY aCtrl[FORM_BUT_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseCtrlFont")
   IF aCtrl[FORM_BUT_FONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_BUT_FONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_BUT_FONTCOMPOUNDNAME ]))
      aCtrl[FORM_BUT_FONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_BUT_FONTCOMPOUNDNAME ])
   ENDIF
#endif
   IF EMPTY aCtrl[FORM_BUT_BITMAP]            ASSIGN BUT_BMP_NO

RETURN

METHOD _PushButton:updControl(aCtrl)
   LOCAL xCaption
   DEFAULT aCtrl TO ::aCtrl

   ::S2Control:updControl(aCtrl)


   //////////////////////////////////////////////////////////////
   //Mantis 1254
   xCaption := ::aCtrl[FORM_BUT_PROMPT]
   IF VALTYPE(xCaption) == "C" .AND. ;
      (AT("//", xCaption)> 0 .OR. AT(CRLF, xCaption)> 0)
      xCaption := STRTRAN(xCaption,"//", CRLF )
      //dfXBPSetStyle(::oBtn,BS_MULTILINE , .T.)
   ENDIF
   //////////////////////////////////////////////////////////////

   ::oBtn:setCaption( xCaption, ;
                 ::aCtrl[FORM_BUT_BITMAP], ;
                 ::aCtrl[FORM_BUT_BITMAPID] )

   IF ::useBmpSize(::aCtrl[FORM_BUT_BITMAP], ;
                   ::aCtrl[FORM_BUT_BITMAPID]) .AND. ;
      ::oBmp != NIL .AND. ::oBmp:status() == XBP_STAT_CREATE
      ::oBtn:setSize({::oBmp:xSize+2, ::oBmp:xSize+2})
   ENDIF

   ::oBtn:activate := ::aCtrl[FORM_BUT_FUNCTION]
   ::bActive       := ::aCtrl[FORM_BUT_ACTIVE]
   ::cMsg          := ::aCtrl[FORM_BUT_MESSAGE]

   // Imposta i colori nei pres. param. per foreground/background/disabled
   S2ObjSetColors(::oBtn, .T., aCtrl[FORM_BUT_CLRPROMPT], APPCOLOR_BTN)


#ifndef _NOFONT_
   aCtrl[FORM_BUT_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_BUT_FONTCOMPOUNDNAME ])
   ::UpdObjFont( aCtrl[FORM_BUT_FONTCOMPOUNDNAME  ] )
#endif

RETURN self


METHOD _PushButton:IsActive()
RETURN EVAL(::bActive, self)


METHOD _PushButton:isShortCut(cAct)
RETURN ! EMPTY(::cHotKey) .AND. cAct == "A_"+::cHotKey

// METHOD _PushButton:isShortCut(cAct)
//    LOCAL lRet := .F. , nPos
//    LOCAL cCaption := IIF(::isBmpButton(), ::_caption, ::caption)
//
//    IF VALTYPE( cCaption ) == "C" .AND. ;
//       ( nPos := AT( STD_HOTKEYCHAR, cCaption) ) != 0
//
//       lRet := cAct == "A_"+LOWER( SUBSTR( cCaption, nPos + 1, 1))
//
//    ENDIF
// RETURN lRet

METHOD _PushButton:setHotKey(xCaption)
   LOCAL nPos

   IF VALTYPE(xCaption) $ "CM"
      xCaption := ::S2Control:ChgHotKey(xCaption)

      IF VALTYPE( xCaption ) $ "CM" .AND. ;
         ( nPos := AT( STD_HOTKEYCHAR, xCaption) ) != 0
         ::cHotKey := LOWER( SUBSTR( xCaption, nPos + 1, 1))
      ELSE
         ::cHotKey := NIL
      ENDIF
   ENDIF
RETURN NIL



METHOD _PushButton:CanSetFocus()
   LOCAL lRet := .T.
   IF !EMPTY(::bCansetFocus) .AND. VALTYPE(::bCansetFocus) == "B"
      lRET := EVAL(::bCansetFocus, self)
   ENDIF
RETURN lRet .AND. ::CanSetPage() .AND. ::IsActive() .AND. ::CanShow() //::isEnabled() .AND. ::isVisible()
RETURN ::CanSetPage() .AND. ::IsActive() .AND. ::CanShow() //::isEnabled() .AND. ::isVisible()
//RETURN ::TabStop .AND. ::IsActive() .AND. ::CanShow() //::isEnabled() .AND. ::isVisible()

METHOD _PushButton:SetFocus()
   //::setHelpID("")
   // 00:37:09 martedi' 24 gennaio 2017
   // Impostato l'id di help sul pushbutton
   ::setHelpID(::cID)
   ::oBtn:enable()
RETURN SetAppFocus(::oBtn)

METHOD _PushButton:hasFocus()
// RETURN ::HasInputFocus()
RETURN SetAppFocus() == ::oBtn

METHOD _PushButton:__SetInputFocus()
   // Simone gerr 3653 25/3/03
   IF ::isOnCurrentForm()
      IF ::CanSetPage()
         ::oForm:SetMsg(::cMsg)
         // 01:02:37 martedi' 24 gennaio 2017
         // Impostato anche all'input focus, dato che solo il focus non avviene
         // quando faccio click su un pulsante
         ::setHelpID(::cID)
      ELSE
         ::oForm:skipFocus(1)
      ENDIF
   ENDIF
RETURN self

METHOD _PushButton:DispItm() // ( cGrp, lRef )
   LOCAL lRet := .F.
   LOCAL xCaption

   IF ::CanShow()

      //////////////////////////////////////////////////////////////
      //Mantis 1254
      xCaption  := ::oBtn:setCaption()
      IF VALTYPE(xCaption) == "C" .AND. AT(CRLF, xCaption)> 0
         dfXBPSetStyle(::oBtn,BS_MULTILINE , .T.)
      ENDIF
      //////////////////////////////////////////////////////////////

      ::oBtn:show()
      lRet := .T.
   ELSE
      ::oBtn:hide()
   ENDIF

   IF ::IsActive()
      ::oBtn:enable()
   ELSE
      ::oBtn:disable()
   ENDIF
RETURN lRet


*------------------
METHOD _PushButton:__setCaption(xCaption, nBmp, xBmpID)
   DEFAULT xCaption TO ::aCtrl[FORM_BUT_PROMPT]
   DEFAULT nBmp     TO ::aCtrl[FORM_BUT_BITMAP]
   DEFAULT xBmpID   TO ::aCtrl[FORM_BUT_BITMAPID]

   /////////////////////////////////////////////
   //Mantis 1653
   //Modifica Luca del 12/11/2007
   //O xCaption Š identico a ::aCtrl[FORM_BUT_PROMPT] o diverso deve essere riassegnato.
   //xCaption puo essere diverso perche impostato da iniezione di codice!
   //Deve aggiornare ::aCtrl[FORM_BUT_PROMPT] altriemnti in dispitme() viene persa l'informazione assegnata.
   ::aCtrl[FORM_BUT_PROMPT] := xCaption
   /////////////////////////////////////////////

   ::setHotKey(xCaption)
RETURN self


METHOD _PushButton:__KeyBoard( nKey )
   LOCAL lRet := .T.

   // sd 27/7/07 mantis 0001542
   //XbaseBtnActivate=elenco tasti per attivare il pulsante esempio ("mcr","f07",ecc)
   //per disattivare il "ret" impostare un codice azione non eseguibile ad esempio
   //XbaseBtnActivate=*

   IF ! EMPTY(dfSet("XbaseBtnActivate")) .AND. ;
      ACT $ dfSet("XbaseBtnActivate")                          // sd 27/7/07 mantis 0001542
      PostAppEvent(xbeP_Activate, NIL, NIL, self)

   ELSEIF EMPTY(dfSet("XbaseBtnActivate")) .AND. ACT == "ret"  // sd 27/7/07 mantis 0001542
      PostAppEvent(xbeP_Activate, NIL, NIL, self)

   ELSEIF ACT $ "ret,dar,tab,rar" // sd 27/7/07 mantis 0001542 aggiunto "ret"
      ::oForm:skipFocus(1)

   ELSEIF ACT $ "uar,Stb,lar"
      ::oForm:skipFocus(-1)
   ELSE
      lRet := .F.
   ENDIF
   // IF dbKsc2Act(nKey) == "ret"
   //    PostAppEvent(xbeP_Activate, NIL, NIL, self)
   // ENDIF
RETURN lRet

