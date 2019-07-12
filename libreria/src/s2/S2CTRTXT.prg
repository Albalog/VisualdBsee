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
#include "dfMsg.ch"

#define S2EDITBOX_OFFSET_LEFT   (IIF(::getType() == XBPSTATIC_TYPE_GROUPBOX, 5,  1))
#define S2EDITBOX_OFFSET_BOTTOM (IIF(::getType() == XBPSTATIC_TYPE_GROUPBOX, 10, 1))
#define S2EDITBOX_OFFSET_TOP    (IIF(::getType() == XBPSTATIC_TYPE_GROUPBOX, 3 * S2EDITBOX_OFFSET_BOTTOM, S2EDITBOX_OFFSET_BOTTOM+::headerHeight))
#define S2EDITBOX_OFFSET_RIGHT  (3 * S2EDITBOX_OFFSET_LEFT)

MEMVAR ACT, A, SA

// simone 02/07/07 funzionante ma per ora non attivo
// mantis 0001248: potrebbe essere comodo implementare una funzionalit… di autofill
#define _ENABLE_AUTOFILL_

// S2EditBox: CTRL_TEXTBOX
// -------------------------

CLASS S2EditBox FROM S2StaticGroupBoxWithFocus, S2EditCtrl, S2PfkCtrl
   PROTECTED:
      VAR lDispLoop
      METHOD CtrlArrInit
//#ifdef _ENABLE_AUTOFILL_
//      VAR oAutoFill
//#endif

   EXPORTED:
      VAR bActive, cMsg, bCond, bSys
      VAR oMle

#ifdef __DFPROFILER_ENABLED__
      VAR dataLink
      INLINE ACCESS ASSIGN METHOD dataLink(xVar); RETURN IIF(xVar==NIL, ::oMle:dataLink, ::oMle:dataLink:=xVar)
#else
      ACCESSVAR dataLink IN ::oMle:dataLink
#endif

      METHOD Init, Create //, Destroy
      METHOD SetInputFocus, DispItm, CanSetFocus, SetFocus, HasFocus
      METHOD Enable, Disable, Show, Hide, isShortCut
      METHOD SetData, GetData, IsActive, PreGet, PostGet, ChkGet
      METHOD setSize
      METHOD updControl
      METHOD Resize,_Keyboard 

      INLINE METHOD killInputFocus()
         ////////////////////////////////////////////////////
         //////////////////////////////////
         //Luca 23/11/2011 XLS  2739,1932
         //Correzione sul lostfocus sui campi GET e Memo: non vengono memorizzati i valori digitati se si preme un pulsante 
         //sulla toolbar nel caso di toolbar attiva solo sulla Mainform.
         //////////////////////////////////
         //IF ::isOnCurrentForm() .AND. ::CanSetPage()
         IF (::isOnCurrentForm() .AND. ::CanSetPage()) .OR.;
             (S2FormCurr()  == dfSetMainWin() .AND. S2UseMainToolbar())
         ////////////////////////////////////////////////////
            ::dehilite()
            ::getData()
//      #ifdef _ENABLE_AUTOFILL_
//            IF ::oAutoFill != NIL
//               ::oAutoFill:TextAdd(::editBuffer())
//               ::oAutoFill:closeListbox()
//            ENDIF
//      #endif
         ENDIF
      RETURN self

//#ifdef _ENABLE_AUTOFILL_
//      INLINE METHOD editBuffer(); RETURN ::oMle:editBuffer()
//      INLINE METHOD queryMarked(); RETURN ::oMle:queryMarked()
//      INLINE METHOD setMarked(x); RETURN ::oMle:setMarked(x)
//#endif

      INLINE METHOD findStyle()
         LOCAL nStyle := NIL
         IF LEN(::aCtrl) >= FORM_TXT_PAINTSTYLE
            nStyle := ::aCtrl[FORM_TXT_PAINTSTYLE]
         ENDIF
         IF EMPTY(nStyle)
            nStyle := dfSet(AI_XBASETXTBOXSTYLE)
         ENDIF
      RETURN nStyle
ENDCLASS

METHOD S2EditBox:CtrlArrInit(aCtrl, oFormFather )
   DEFAULT aCtrl[FORM_TXT_CVAR]       TO ""
   DEFAULT aCtrl[FORM_TXT_PROMPT]     TO ""
   DEFAULT aCtrl[FORM_TXT_BOX]        TO 0
   DEFAULT aCtrl[FORM_TXT_ACTIVE]     TO {||.T.}
   DEFAULT aCtrl[FORM_TXT_CONDITION]  TO {||.T.}
   DEFAULT aCtrl[FORM_TXT_SYS]        TO "" //IF( TYPE("dfMemo()")=="UI", "dfMemo", "" )
   DEFAULT aCtrl[FORM_TXT_MESSAGE]    TO ""
   DEFAULT aCtrl[FORM_TXT_CLRID]      TO {}
   ASIZE( aCtrl[FORM_TXT_CLRID], 7 )
   IF EMPTY aCtrl[FORM_TXT_CLRPROMPT     ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_PROMPT   ]
   IF EMPTY aCtrl[FORM_TXT_CLRHOTKEY     ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_HOTPROMPT]
   IF EMPTY aCtrl[FORM_TXT_CLRDATA       ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_TEXFIELD ]
   IF EMPTY aCtrl[FORM_TXT_CLRHILITE     ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_CURSOR   ]
   IF EMPTY aCtrl[FORM_TXT_CLRTOPLEFT    ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_NORMALBOX]
   IF EMPTY aCtrl[FORM_TXT_CLRBOTTOMRIGHT] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_SHADOWBOX]
   DEFAULT aCtrl[FORM_TXT_ROW] TO aCtrl[FORM_TXT_BOTTOM]-aCtrl[FORM_TXT_TOP] -1  // Righe Colonne memo
   DEFAULT aCtrl[FORM_TXT_COL] TO aCtrl[FORM_TXT_RIGHT] -aCtrl[FORM_TXT_LEFT]-1
   DEFAULT aCtrl[FORM_TXT_MEMOLEN] TO aCtrl[FORM_TXT_COL]

   DEFAULT aCtrl[FORM_TXT_PFK]        TO {}
   //Non utilizzato
   //IF LEN(aCtrl)>=  FORM_TXT_ALIGNMENT_TYPE
   //   DEFAULT aCtrl[FORM_TXT_ALIGNMENT_TYPE] TO XBPALIGN_TOP + XBPALIGN_LEFT
   //ENDIF                                        

#ifndef _NOFONT_
   ASIZE(aCtrl, FORM_TXT_CTRLARRLEN)
   aCtrl[FORM_TXT_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_TXT_FONTCOMPOUNDNAME ])
   aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ])
   aCtrl[FORM_TXT_FONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_TXT_FONTCOMPOUNDNAME ])
   IF EMPTY aCtrl[FORM_TXT_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseTxtFont")
   IF EMPTY aCtrl[FORM_TXT_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseCtrlFont")
   IF aCtrl[FORM_TXT_FONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_TXT_FONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_TXT_FONTCOMPOUNDNAME ]))
      aCtrl[FORM_TXT_FONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_TXT_FONTCOMPOUNDNAME ])  
   ENDIF

   aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ])
   IF EMPTY aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ] ASSIGN aCtrl[FORM_TXT_FONTCOMPOUNDNAME ]
   IF aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ]))
      aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ])  
   ENDIF
#endif
RETURN

METHOD S2EditBox:updControl(aCtrl)
   DEFAULT aCtrl TO ::aCtrl

   ::S2StaticGroupBoxWithFocus:updControl(aCtrl)

   ::setCaption( ::ChgHotKey( ::aCtrl[FORM_TXT_PROMPT] ) )
   ::bActive := ::aCtrl[FORM_TXT_ACTIVE]
   ::cMsg    := ::aCtrl[FORM_TXT_MESSAGE]
   ::bCond   := ::aCtrl[FORM_TXT_CONDITION]
   ::bSys    := ::aCtrl[FORM_TXT_SYS]
   ::oMle:DataLink := ::aCtrl[FORM_TXT_VAR]

   // Imposta i colori nei pres. param. per foreground/background/disabled
   S2ObjSetColors(::oMle, .T., aCtrl[FORM_TXT_CLRDATA], APPCOLOR_TXT)

   // Imposta i colori nei pres. param. per foreground/background/disabled
   S2ObjSetColors(self, .T., aCtrl[FORM_TXT_CLRPROMPT], APPCOLOR_TXTPROMPT)

#ifndef _NOFONT_
   aCtrl[FORM_TXT_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_TXT_FONTCOMPOUNDNAME ])
   aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ])
   ::UpdObjFont( aCtrl[FORM_TXT_FONTCOMPOUNDNAME  ], ::oMle )
   ::UpdObjFont( aCtrl[FORM_TXT_PFONTCOMPOUNDNAME ] )
#endif

RETURN self

METHOD S2EditBox:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos, aDMM
   //Mantis 2192 
   LOCAL cColorFG := dfSet("XbaseGetDisabledColorFG")
   LOCAL cColorBG := dfSet("XbaseGetDisabledColorBG")

   //Mantis 2192 
   IF !EMPTY(dfSet("XbaseTxtDisabledColorFG"))
      cColorFG := dfSet("XbaseTxtDisabledColorFG")
   ENDIF 
   IF !EMPTY(dfSet("XbaseTxtDisabledColorBG"))
      cColorBG := dfSet("XbaseTxtDisabledColorBG")
   ENDIF 

   ::CtrlArrInit(aCtrl, oFormFather )

   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF S2PixelCoordinate(aCtrl)
      DEFAULT aPos  TO {aCtrl[FORM_TXT_LEFT], aCtrl[FORM_TXT_TOP]}
      DEFAULT aSize TO {aCtrl[FORM_TXT_RIGHT],aCtrl[FORM_TXT_BOTTOM]}
   ELSE
      oPos := PosCvt():new(aCtrl[FORM_TXT_LEFT]+.5, aCtrl[FORM_TXT_BOTTOM] +.5)
      oPos:Trasla(oParent)

      DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}
      oPos:SetDos(aCtrl[FORM_TXT_RIGHT]  - aCtrl[FORM_TXT_LEFT] , ; // +1, ;
                  aCtrl[FORM_TXT_BOTTOM] - aCtrl[FORM_TXT_TOP]  ) // -1  )

      DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}
   ENDIF

   DEFAULT lVisible TO .F.


#ifndef _NOFONT_
   IF ! EMPTY(aCtrl[FORM_TXT_PFONTCOMPOUNDNAME])
      DEFAULT aPP TO {}
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_TXT_PFONTCOMPOUNDNAME])
      //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_TXT_PFONTCOMPOUNDNAME]})
   ENDIF
#endif

   // Imposta i colori nei pres. param. per foreground/background/disabled
   aPP := S2PPSetColors(aPP, {.T., 0}, aCtrl[FORM_TXT_CLRPROMPT], APPCOLOR_TXTPROMPT)

   ::aCtrl := aCtrl // simone 13/6/05 assegno ora altrimenti il ::findStyle() da un errore

   // Inizializza l'oggetto
   // ---------------------
   ::S2StaticGroupBoxWithFocus:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2EditCtrl:Init( aCtrl[FORM_TXT_CVAR] )

   ::headerHeight := IIF( ::GetType() == XBPSTATIC_TYPE_GROUPBOX, 0, 20)

   aDMM := ACLONE( aCtrl[FORM_TXT_PFK] )

   ADDKEY "wis" TO aDMM BLOCK ::oMle:insert( NIL, dfMemoRead() ) MESSAGE dfStdMsg(MSG_DFMEMO02)

   IF !(dfSet("XbaseDisableSaveMemoOnDisk") == "YES")
      ADDKEY "new" TO aDMM BLOCK dfMemoWri( ::getData()           ) MESSAGE dfStdMsg(MSG_DFMEMO03)
   ENDIF

   ::S2PfkCtrl:Init( aDMM )

   //::type := XBPSTATIC_TYPE_GROUPBOX

   ::caption := ::ChgHotKey( aCtrl[FORM_TXT_PROMPT] )
   ::bActive := aCtrl[FORM_TXT_ACTIVE]
   ::cMsg    := aCtrl[FORM_TXT_MESSAGE]
   ::bCond   := aCtrl[FORM_TXT_CONDITION]
   ::bSys    := aCtrl[FORM_TXT_SYS]

   ::lDispLoop := .F.

   // ::group := XBP_END_GROUP
   // ::tabStop := .T.
   // ::setInputFocus := {|| SetAppFocus(::oMle) }
   // ::group := XBP_WITHIN_GROUP

   // Crea l'oggettox dentro il groupbox
   // ----------------------------------
   aPos := {S2EDITBOX_OFFSET_LEFT, S2EDITBOX_OFFSET_BOTTOM}
   aSize := ::currentSize()
   aSize[1] -= S2EDITBOX_OFFSET_RIGHT
   aSize[2] -= S2EDITBOX_OFFSET_TOP

   aPP := NIL
#ifndef _NOFONT_
   IF ! EMPTY(aCtrl[FORM_TXT_FONTCOMPOUNDNAME])
      aPP := {}
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_TXT_FONTCOMPOUNDNAME])
      //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_TXT_FONTCOMPOUNDNAME]})
   ENDIF
#endif
   ///////////////////////////////////////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////////////////////
   //Mantis 2192 
   //Modifica Luca 8/5/2012
   // Imposta i colori nei pres. param. per foreground/background/disabled
   aPP := S2PPSetColors(aPP, .T., aCtrl[FORM_TXT_CLRDATA], APPCOLOR_TXT)

   aPP := S2PPSetColors(aPP, {.T., 0}, aCtrl[FORM_GET_CLRDATA], APPCOLOR_GET)
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
   IF cColorFG != NIL
      DEFAULT aPP TO {}
      IF cColorFG != NIL 
         IF S2IsNumber(cColorFG)
            aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_FGCLR,VAL(cColorFG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_FGCLR, n)}, .T., cColorFG)
         ENDIF
         // AADD(aPP, {XBP_PP_DISABLED_BGCLR, VAL(cColorBG)})
      ENDIF
   ENDIF
   ///////////////////////////////////////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////////////////////


   ::oMle := _XbpMle():New(self, NIL, aPos, aSize, aPP)
   ::oMle:DataLink := aCtrl[FORM_TXT_VAR]
   //SD ::oMle:TabStop   := .T.
   ::oMle:IgnoreTab := .T.
   IF ! ::GetType() == XBPSTATIC_TYPE_GROUPBOX
      ::oMle:border := .F.
   ENDIF

   // 11/10/2000 - Gestione a capo automatico
   ::oMle:wordWrap := aCtrl[FORM_TXT_MEMOLEN] <= aCtrl[FORM_TXT_COL]
   ::oMle:horizScroll := ! ::oMle:wordWrap
   // SD 7/1/03 modificato con skipFocus per GERR 3605
   //::oMle:SetInputFocus := {|x1,x2,s| IIF(::isOnCurrentForm() .AND. ::CanSetPage() .AND. ::PreGet() .AND. ;
   //                                       EMPTY(::oMle:disableKeyboard), ;
   //                                   (::oForm:SetMsg(::cMsg), ::hilite()), ;
   //                                   ::oForm:skipFocus(1) ) }
             

   ::oMle:SetInputFocus := {|x1,x2,s| IIF( (::isOnCurrentForm().OR. (S2FormCurr()  == dfSetMainWin() .AND. S2UseMainToolbar())) .AND.;
                                            ::CanSetPage()     .AND. ::PreGet() .AND. ;
                                          EMPTY(::oMle:disableKeyboard), ;
                                      (::oForm:SetMsg(::cMsg), ::hilite()), ;
                                      ::oForm:skipFocus(1) ) }
   ::oMle:KillInputFocus := {|x1,x2,s| ::killInputFocus(), s} //::dehilite(), ::GetData()}
   //::oMle:keyboard := {|nKey, uNil, s| IIF(ACT=="ush", dfUsrHelp(::aMethod, ::formFather():cState ), ;
   //                                    IIF(::handleAction( ACT ),NIL,;
   //                                        IIF(ACT$"tab", ::oForm:skipFocus(1), ;
   //                                            IIF(ACT$"Stb", ::oForm:skipFocus(-1),;
   //                                                NIL )))) }
   ::oMle:keyboard := {|nKey, uNil, s| ::_Keyboard(nKey, uNil, s)  }

//#ifdef _ENABLE_AUTOFILL_
//   ::oAutoFill := ImplementAutoFillText():new(::oMle)
//#endif
RETURN self

METHOD S2EditBox:_Keyboard(nKey, uNil, s) 
  LOCAL nRet, cACT
  cACT := LOWER(ACT)

  DO CASE
//#ifdef _ENABLE_AUTOFILL_
//     CASE ::oAutoFill != NIL .AND. ;
//          ::oAutoFill:listBoxVisible() .AND. ACT $"uar,dar,ret"
//          ::oAutoFill:autoFill(nKey)
//#endif
     CASE cACT=="ush"
        nRet := dfUsrHelp(::aMethod, ::formFather():cState )
     CASE ::handleAction( cACT )
        //
     CASE cACT $"tab" 
        ::setFocus()
        nRet := ::oForm:skipFocus(1)
     CASE cACT$"stb"
       ::setFocus()
       nRet :=  ::oForm:skipFocus(-1)
//#ifdef _ENABLE_AUTOFILL_
//     CASE ::oAutoFill != NIL
//       ::oAutoFill:autoFill(nKey)
//#endif
  ENDCASE
RETURN nRet

METHOD S2EditBox:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2StaticGroupBoxWithFocus:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::oMle:Create( self )
   //::oMle:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
RETURN self


METHOD S2EditBox:isShortCut(cAct)
   LOCAL lRet := .F. , nPos

   IF VALTYPE( ::caption ) == "C" .AND. ;
      ( nPos := AT( STD_HOTKEYCHAR, ::caption) ) != 0

      // nRet := dbAct2Ksc("A_"+LOWER( SUBSTR( ::caption, nPos + 1, 1)))
      lRet := cAct == "A_"+LOWER( SUBSTR( ::caption, nPos + 1, 1))

   ENDIF
RETURN lRet

METHOD S2EditBox:IsActive()
RETURN EVAL(::bActive)

METHOD S2EditBox:SetInputFocus()
IF ::isOnCurrentForm() 
   IF ::CanSetPage() .AND. ::PreGet()
      ::oForm:SetMsg(::cMsg)
   ELSE
      // SD 7/1/03 modificato con skipFocus per GERR 3605
      ::oForm:skipFocus(1)
      //PostAppEvent(xbeP_KillInputFocus, NIL, NIL, self)
   ENDIF
ENDIF
RETURN self

METHOD S2EditBox:DispItm() // ( cGrp, lRef )
   LOCAL lRet := .F.
   IF ! ::lDispLoop
      ::lDispLoop := .T.

      IF ::CanShow()
         lRet := ::S2StaticGroupBoxWithFocus:DispItm() // (cGrp, lRef)
         ::show()
      ELSE
         ::hide()
      ENDIF

      IF ::IsActive() .AND. ;
         (!dfSet("XbaseDisableOnPreget") == "YES" .OR. ::PreGet())
         ::enable()
      ELSE
         ::disable()
      ENDIF

      ::SetData()

      ::lDispLoop := .F.
   ENDIF
RETURN lRet

METHOD S2EditBox:SetSize(aNew, lUpdate)
   DEFAULT lUpdate TO .T.

   ::S2StaticGroupBoxWithFocus:setSize(aNew, .F.)
   aNew[1] -= S2EDITBOX_OFFSET_RIGHT
   aNew[2] -= S2EDITBOX_OFFSET_TOP
   ::oMle:setSize(aNew, .F.)
   IF lUpdate
      ::invalidateRect() 
   ENDIF
RETURN .T.

METHOD S2EditBox:resize(aOld, aNew)
   ::S2StaticGroupBoxWithFocus:resize(aOld, aNew)
   aNew[1] -= S2EDITBOX_OFFSET_RIGHT
   aNew[2] -= S2EDITBOX_OFFSET_TOP
   ::oMle:setSize(aNew, .F.)

   ::invalidateRect()
RETURN self

  


METHOD S2EditBox:SetData() // cBuffer )
RETURN ::oMle:SetData() // cBuffer )

METHOD S2EditBox:GetData()
   LOCAL cRet := ::oMle:getData()
   IF ::aPage0 != NIL
      // Se Š pagina 0 aggiorno il buffer dei "fratelli"
      AEVAL(::aPage0, {|x|x:setData()})
   ENDIF
RETURN cRet

METHOD S2EditBox:CanSetFocus()
//SD RETURN ::oMle:TabStop .AND. ::IsActive() .AND. ::CanShow() .AND. ::PreGet() //::isEnabled() .AND. ::isVisible()
RETURN ::CanSetPage() .AND. ::IsActive() .AND. ::CanShow() .AND. ::PreGet() //::isEnabled() .AND. ::isVisible()

METHOD S2EditBox:SetFocus()
   ::setHelpID(::cID)
   ::enable()
RETURN SetAppFocus(::oMle)

METHOD S2EditBox:hasFocus()
RETURN SetAppFocus() == ::oMle

METHOD S2EditBox:show()
   LOCAL lRet := ::S2StaticGroupBoxWithFocus:show()
   ::oMle:show()
RETURN lRet

METHOD S2EditBox:hide()
   LOCAL lRet := ::S2StaticGroupBoxWithFocus:hide()
   ::oMle:hide()
RETURN lRet

METHOD S2EditBox:enable()
   LOCAL lRet := ::S2StaticGroupBoxWithFocus:enable()
   IF lRet
      ::oMle:enable()
   ENDIF
RETURN lRet

METHOD S2EditBox:disable()
   LOCAL lRet := ::S2StaticGroupBoxWithFocus:disable()
   IF lRet
      ::oMle:disable()
   ENDIF
RETURN lRet

METHOD S2EditBox:PreGet()
RETURN EVAL(::bCond, FORM_PREGET)

METHOD S2EditBox:PostGet()
RETURN EVAL(::bCond, FORM_POSTGET)

METHOD S2EditBox:ChkGet()
RETURN EVAL(::bCond, FORM_CHKGET)

// -----------------------------
STATIC CLASS _XbpMle FROM XbpMle

EXPORTED:
   VAR disableKeyboard
   VAR cID

#ifdef _ENABLE_AUTOFILL_
      VAR oAutoFill
#endif
   INLINE METHOD init(oParent, oOwner, aPos, aSize, aPP, lVisible)
       ::XbpMle:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
       ::cID := ::setParent():cID
#ifdef _ENABLE_AUTOFILL_
       IF dfSet("XbaseTxtAutoFill")=="STD"
          ::oAutoFill := ImplementAutoFillText():new(self)
       ENDIF
#endif
   RETURN self

   INLINE METHOD Keyboard(nKey)
      LOCAL l := .T.
//Maudp 04/11/2011 XL 2383 Se il TXTBOX Š disabilitato non deve far apparire l'autofill
//      IF EMPTY(::disableKeyboard)
      IF EMPTY(::disableKeyboard) .AND. ::editable

#ifdef _ENABLE_AUTOFILL_
         IF ::oAutoFill != NIL .AND. ;
            ::oAutoFill:listBoxVisible() .AND. (nKey==xbeK_UP .OR. nKey==xbeK_DOWN)
            ::oAutoFill:autoFill(nKey)
            l := .F.
         ENDIF
#endif
         IF l
            ::XbpMle:keyboard(nKey)
#ifdef _ENABLE_AUTOFILL_
            IF ::oAutoFill != NIL
              ::oAutoFill:autoFill(nKey)
            ENDIF
#endif
         ENDIF
      ENDIF
   RETURN self

   INLINE METHOD killInputFocus()

   //////////////////////////////////
   //Luca 23/11/2011 XLS  2739,1932
   //Correzione sul lostfocus i valori dei campi Memo non vengono memorizzati se si preme sulla toolbar 
   //nel caso di tollbar attiva solo sulla Mainform.
   //////////////////////////////////
   ::getData()
   //////////////////////////////////
   //////////////////////////////////

   #ifdef _ENABLE_AUTOFILL_
      IF ::oAutoFill != NIL
         ::oAutoFill:TextAdd(::editBuffer())
         ::oAutoFill:closeListbox()
      ENDIF
   #endif
   RETURN self


ENDCLASS

