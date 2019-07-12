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

MEMVAR ACT, A, SA

// S2CheckBox: CTRL_CHECK
// ----------------------
CLASS S2CheckBox FROM XbpCheckBox, S2Control, S2EditCtrl
   PROTECTED:
      METHOD CtrlArrInit

   EXPORTED:
      VAR bActive, cMsg, cRefGrp, bVar, xValOn, xValOff, bClick
      METHOD Init, DispItm, SetInputFocus, KillInputFocus
      METHOD SetFocus, hasFocus, CanSetFocus, getData
      METHOD IsActive, isShortCut, selected, keyboard
      // METHOD HandleEvent
      METHOD UpdControl
      METHOD Create
      method enable, disable, refreshBMP
      VAR lUno 
ENDCLASS

METHOD S2CheckBox:CtrlArrInit(aCtrl, oFormFather )
   DEFAULT aCtrl[FORM_CHK_CVAR]       TO ""
   DEFAULT aCtrl[FORM_CHK_PROMPT]     TO ""
   DEFAULT aCtrl[FORM_CHK_GAP]        TO 0
   DEFAULT aCtrl[FORM_CHK_ACTIVE]     TO {||.T.}
   DEFAULT aCtrl[FORM_CHK_CLICKED]    TO {||.T.}

   aCtrl[FORM_CHK_CTRLGRP] := dfChkGrp(aCtrl[FORM_CHK_CTRLGRP])

   DEFAULT aCtrl[FORM_CHK_CLRID]      TO {}
   ASIZE( aCtrl[FORM_CHK_CLRID], 5 )
   IF EMPTY aCtrl[FORM_CHK_CLRPROMPT      ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_PROMPT   ]
   IF EMPTY aCtrl[FORM_CHK_CLRHOTKEY      ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_HOTPROMPT]
   IF EMPTY aCtrl[FORM_CHK_CLRHILITEPROMPT] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_RADCHK   ]
   IF EMPTY aCtrl[FORM_CHK_CLRICON        ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_GETCOMBO ]

#ifndef _NOFONT_
   ASIZE(aCtrl, FORM_CHK_CTRLARRLEN)
   aCtrl[FORM_CHK_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_CHK_FONTCOMPOUNDNAME ])
   IF EMPTY aCtrl[FORM_CHK_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseCkbFont")
   IF EMPTY aCtrl[FORM_CHK_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseCtrlFont")
   IF aCtrl[FORM_CHK_FONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_CHK_FONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_CHK_FONTCOMPOUNDNAME ]))
      aCtrl[FORM_CHK_FONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_CHK_FONTCOMPOUNDNAME ])  
   ENDIF
#endif

   IF EMPTY aCtrl[FORM_CHK_PAINTSTYLE     ] ASSIGN dfSet(AI_XBASECHKSTYLE)

 //   // Assicura che in aCtrl ci siano valori congruenti
 //   // ------------------------------------------------
 //   IF aCtrl[FORM_CHK_ACTIVE] == NIL
 //      aCtrl[FORM_CHK_ACTIVE] := {|| .T. }
 //   ENDIF
 //   IF aCtrl[FORM_CHK_CLICKED] == NIL
 //      aCtrl[FORM_CHK_CLICKED] := {|| .T. }
 //   ENDIF
 //   IF aCtrl[FORM_CHK_MESSAGE] == NIL
 //      aCtrl[FORM_CHK_MESSAGE] := ""
 //   ENDIF

RETURN

METHOD S2CheckBox:updControl(aCtrl)
   DEFAULT aCtrl TO ::aCtrl

   ::S2Control:updControl(aCtrl)

   ::setCaption( ::ChgHotKey( ::aCtrl[FORM_CHK_PROMPT] ) )
   ::bVar     := ::aCtrl[FORM_CHK_VAR]
   ::xValOn   := ::aCtrl[FORM_CHK_VALUEON]
   ::xValOff  := ::aCtrl[FORM_CHK_VALUEOFF]
   ::bClick   := ::aCtrl[FORM_CHK_CLICKED]
   ::bActive  := ::aCtrl[FORM_CHK_ACTIVE]
   ::cMsg     := ::aCtrl[FORM_CHK_MESSAGE]
   ::cRefGrp  := ::aCtrl[FORM_CHK_CTRLGRP]

#ifndef _NOFONT_
   aCtrl[FORM_CHK_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_CHK_FONTCOMPOUNDNAME ])
   ::UpdObjFont( aCtrl[FORM_CHK_FONTCOMPOUNDNAME  ] )
#endif

   // imposta i colori foreground/background
   S2ObjSetColors(self, ! ::oForm:hasBitmapBG(), aCtrl[FORM_CHK_CLRPROMPT], APPCOLOR_CHK)

RETURN self


METHOD S2CheckBox:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos, oXbp

   ::CtrlArrInit(aCtrl, oFormFather )

   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF S2PixelCoordinate(aCtrl)
      DEFAULT aPos TO {aCtrl[FORM_CHK_COL], aCtrl[FORM_CHK_ROW]}
      IF LEN(aCtrl) >= FORM_CHK_SIZE
         //Mantis 737 Luca
         //DEFAULT aSize TO aCtrl[FORM_CHK_SIZE]
         IF !EMPTY(aCtrl[FORM_CHK_SIZE]) .AND. VALTYPE(aCtrl[FORM_CHK_SIZE]) =="A"
            DEFAULT aSize TO ACLONE(aCtrl[FORM_CHK_SIZE])
         ENDIF
      ENDIF
   ELSE
      oPos := PosCvt():new(aCtrl[FORM_CHK_COL], aCtrl[FORM_CHK_ROW]+1)
      oPos:Trasla(oParent)
      DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}
   ENDIF
   DEFAULT lVisible TO .F.

#ifndef _NOFONT_
   IF ! EMPTY(aCtrl[FORM_CHK_FONTCOMPOUNDNAME])
      DEFAULT aPP TO {}
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_CHK_FONTCOMPOUNDNAME])
      //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_CHK_FONTCOMPOUNDNAME]})
   ENDIF
#endif

   // Imposta i colori nei pres. param. per foreground/background/disabled
   aPP := S2PPSetColors(aPP, ! oFormFather:hasBitmapBG(), aCtrl[FORM_CHK_CLRPROMPT], APPCOLOR_CHK)

   // Inizializza l'oggetto
   // ---------------------
   IF oFormFather:hasBitmapBG()
      AADD(aPP,{XBP_PP_DISABLED_BGCLR,XBPSYSCLR_TRANSPARENT})
   ELSE
      //Luca 29/05/2013: Mantis 2220
      //Correzione colore trasparente di background Check box disabilitato. Deve prendere quello del fater sotto se non definito
      IF ASCAN(aPP,{|x|x[1]==XBP_PP_DISABLED_BGCLR })== 0
         AADD(aPP,{XBP_PP_DISABLED_BGCLR,XBPSYSCLR_TRANSPARENT})
      ENDIF
   ENDIF


   ::XbpCheckBox:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2Control:Init(aCtrl, nPage, oFormFather)
   ::S2EditCtrl:Init( aCtrl[FORM_CHK_CVAR] )

   ::rbDown := oParent:rbDown

   //SD ::tabStop := .T.

   // simone 24/9/04 mantis 113
   IF S2PixelCoordinate(aCtrl)
      ::autoSize := EMPTY(aSize)
   ELSE
      ::autoSize := .T.
   ENDIF
   ::clipSiblings := .F.
   //::group := XBP_WITHIN_GROUP

   ::caption  := ::ChgHotKey( aCtrl[FORM_CHK_PROMPT] )
   ::bVar     := aCtrl[FORM_CHK_VAR]
   ::xValOn   := aCtrl[FORM_CHK_VALUEON]
   ::xValOff  := aCtrl[FORM_CHK_VALUEOFF]
   ::bClick   := aCtrl[FORM_CHK_CLICKED]

   ::Datalink := {|xVal| IIF(xVal==NIL, ;
                             EVAL(::bVar) == ::xValOn, ;
                             EVAL(::bVar, IIF(xVal, ::xValOn, ::xValOff))) }
   ::bActive  := aCtrl[FORM_CHK_ACTIVE]
   ::cMsg     := aCtrl[FORM_CHK_MESSAGE]
   ::cRefGrp  := aCtrl[FORM_CHK_CTRLGRP]

   //S2ObjSetColors(self, ! oFormFather:hasBitmapBG(), aCtrl[FORM_CHK_CLRPROMPT], APPCOLOR_CHK)
   
   ::lUno  := .T.

RETURN self



METHOD S2CheckBox:create(oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   ::XbpCheckBox:create(oParent, oOwner, aPos, aSize, aPP, lVisible )

   // simone 9/1/08
   // mantis 0001713: nelle form automatiche i radio button vengono troncati
   // workaround per autosize che non funziona in 1.90
   IF ::autoSize
      oXbp := XbpStatic():new(self, NIL, NIL, NIL, NIL, .F.)
      oXbp:autoSize := .T.
      oXbp:caption := ::caption
      // tolgo caratteri ~
      oXbp:caption := STRTRAN(oXbp:caption, STD_HOTKEYCHAR, "")
      IF EMPTY(oXbp:caption)
         aSize := {16, 16}
      ELSE
         oXbp:create()
         aSize := oXbp:currentSize()
         oXbp:destroy()
         aSize[1] += 32 // aggiugo spazio per il cerchietto
         IF aSize[2] < 16  
            aSize[2] := 16
         ENDIF
      ENDIF
      ::setSize(aSize)
   ENDIF

   // Simone 16/6/05
   // imposta stile FLAT
   IF ::aCtrl[FORM_CHK_PAINTSTYLE] == CHK_PS_FLAT
      #define BS_FLAT      0x00008000
      dfXbpSetStyle(self, BS_FLAT, .T.)
   ENDIF

   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //Work around per problema checkbox diabilitato. 
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //Mantis 2234 Luca 09/09/2013
   ::XbpCheckBox:paint := dfMergeBlocks({||IIF(::lUno, (::lUno:= .F., ::XbpCheckBox:enable(),::XbpCheckBox:show(), ::DispItm()),NIL)  } , ::XbpCheckBox:paint)
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

RETURN self

METHOD S2CheckBox:selected(lCheck)

 ::XbpCheckBox:selected(lCheck)
 ::getData()
 EVAL(::bClick)
 ::oForm:tbDisItm("#")

RETURN self

METHOD S2CheckBox:isShortCut(cAct)
   LOCAL lRet := .F. , nPos

   IF VALTYPE( ::caption ) == "C" .AND. ;
      ( nPos := AT( STD_HOTKEYCHAR, ::caption) ) != 0

      // nRet := dbAct2Ksc("A_"+LOWER( SUBSTR( ::caption, nPos + 1, 1)))
      lRet := cAct == "A_"+LOWER( SUBSTR( ::caption, nPos + 1, 1))

   ENDIF
RETURN lRet

METHOD S2CheckBox:IsActive()
RETURN EVAL(::bActive)

METHOD S2CheckBox:getData()
   LOCAL cRet := ::XbpCheckBox:getData()
   IF ::aPage0 != NIL
      // Se Š pagina 0 aggiorno il buffer dei "fratelli"
      AEVAL(::aPage0, {|x|x:setData()})
   ENDIF
RETURN cRet

METHOD S2CheckBox:DispItm() // ( cGrp, lRef )
   LOCAL lRet := .F.



   IF ::CanShow()
      ::show()
      lRet := .T.
   ELSE
      ::hide()
   ENDIF

   IF ::IsActive()
      ::enable()
   ELSE
      ::disable()
   ENDIF

   ::SetData()
RETURN self


// Quando acquista il focus riposiziona al primo carattere
// Simone gerr 3653 25/3/03
METHOD S2CheckBox:SetInputFocus()
IF ::isOnCurrentForm() 
   IF ::CanSetPage() 
      ::oForm:SetMsg(::cMsg)
   ELSE
      ::oForm:skipFocus(1)
   ENDIF
ENDIF
RETURN self

METHOD S2CheckBox:KillInputFocus()
   ////////////////////////////////////////////////////
   //Luca 23/11/2011 XLS  2739,1932
   //Correzione sul lostfocus sui campi GET e Memo: non vengono memorizzati i valori digitati se si preme un pulsante 
   //sulla toolbar nel caso di toolbar attiva solo sulla Mainform.
   //IF ::isOnCurrentForm() .AND. ::CanSetPage()
   IF (::isOnCurrentForm() .AND. ::CanSetPage()) .OR.;
       (S2FormCurr()  == dfSetMainWin() .AND. S2UseMainToolbar()) 
   ////////////////////////////////////////////////////

      ::getData()
      ::oForm:tbDisRef(::cId)
      IF ! EMPTY(::cRefGrp)
         ::oForm:tbDisRef(::cRefGrp)
      ENDIF
   ENDIF
RETURN self

METHOD S2CheckBox:KeyBoard( nKey )
   IF ACT $ "dar,tab,ret,rar"
      ::oForm:skipFocus(1)

   ELSEIF ACT $ "uar,Stb,lar"
      ::oForm:skipFocus(-1)
   ELSE
      ::XbpCheckBox:keyboard(nKey)
   ENDIF
   // IF dbKsc2Act(nKey) == "ret"
   //    PostAppEvent(xbeP_Activate, NIL, NIL, self)
   // ENDIF
RETURN self

METHOD S2CheckBox:CanSetFocus()
//SD RETURN ::TabStop .AND. ::IsActive() .AND. ::CanShow() //::isEnabled() .AND. ::isVisible()
RETURN ::CanSetPage() .AND. ::IsActive() .AND. ::CanShow() //::isEnabled() .AND. ::isVisible()

METHOD S2CheckBox:SetFocus()
   ::setHelpID(::cID)
   ::enable()
RETURN SetAppFocus(self)

METHOD S2CheckBox:hasFocus()
RETURN SetAppFocus() == self


// SIMONE 20/03/02 Per GERR 3103 aggiunti enable/disable/refreshBMP
METHOD S2CheckBox:enable()
   LOCAL xRet := ::XbpCheckBox:enable()
   ::refreshBMP()
RETURN xRet

METHOD S2CheckBox:disable()
   LOCAL xRet := ::XbpCheckBox:disable()
   // Simone 20/3/02 in DISABLE() non lo chiamo
   // perche non serve a niente; probabilmente 
   // Š collegato a PDR 4444 o 3159
   // ::refreshBMP()  
RETURN xRet

METHOD S2CheckBox:refreshBMP()

   IF ::oForm:hasBitmapBG()
      ::setParent():setParent():invalidateRect(       ;
         {  ::currentPos()[1]                      ,  ;
            ::currentPos()[2]+20                   ,  ;
            ::currentPos()[1]+::currentSize()[1]   ,  ;
            ::currentPos()[2]+::currentSize()[2]+25 } ;
                                             )

      //::setParent():setParent():invalidateRect()
   ENDIF

RETURN self

// RETURN ::HasInputFocus()


// ATTACH "ckb0046" TO oWin:W_CONTROL GET AS CHECKBOX CHK1  PROMPT "Check Box 1"  ; // ATTCKB.TMP
//                  AT   4, 38                        ; // Coordinate
//                  VALUEON  "S"                      ; // Valore in ON
//                  VALUEOFF "N"                      ; // Valore in OFF
//                  GAP      1                        ; // Spazio ICONA / PROMPT
//                  COLOR    {"N/G","G+/G","W+/BG","BG+/G"}  ; // Array dei colori
//                  ACTIVE   {||cState $ "am" }       ; // Stato di attivazione
//                  VARNAME "CHK1"                    ; //
//                  MESSAGE "chk1"                      // Messaggio utente
//
//
//    #COMMAND ATTACH <cId> TO <aParent> GET AS CHECKBOX <uVar> ;
//                                       PROMPT <cPrompt>;
//                                       AT  <nRow>, <nCol> ;
//                                       VALUEON  <uValOn>  ;
//                                       VALUEOFF <uValOff> ;
//                                       [ACTIVE <uActive>] ;
//                                       [DISPLAYIF <uDiIf>];
//                                       [REFRESHGRP  <uGrp>];
//                                       [GAP         <nGap>];
//                                       [PAGE    <nPage>]  ;
//                                       [COLOR   <aCol>]   ;
//                                       [MESSAGE    <cMes>];
//                                       [REFRESHID <cRID>] ;
//                                       [VARNAME <cVarName>];
//                                       [WHENCLICKED <bClick>];
//                                                          ;
//          => aAdd( <aParent>, { CTRL_CHECK ,;
//                                <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
//                              <uGrp> ,;
//                              {|uVal|IF(uVal==NIL, <uVar>, <uVar>:=uVal)},;
//                              <cPrompt>, <nRow>, <nCol>,;
//                              <{uActive}>,;
//                              <aCol>, <cMes>, <nGap>, <{bClick}>, <cVarName>,;
//                              <uValOn>, <uValOff> })
//
//                                               //                     DEFAULT
//    #define FORM_CHK_CTRLGRP    7              // Refresh GRP
//    #define FORM_CHK_VAR        8              // Var
//    #define FORM_CHK_PROMPT     9              // Prompt                ""
//    #define FORM_CHK_ROW       10              // Row
//    #define FORM_CHK_COL       11              // Col
//    #define FORM_CHK_ACTIVE    12              // Active              {||.T.}
//    #define FORM_CHK_CLRID     13              // COLOR ARRAY
//       #define FORM_CHK_CLRPROMPT        13][1 //       PROMPT
//       #define FORM_CHK_CLRHOTKEY        13][2 //       HOTKEY
//       #define FORM_CHK_CLRHILITEPROMPT  13][3 //       HILITE PROMPT
//       #define FORM_CHK_CLRICON          13][4 //       ICON COLOR
//       #define FORM_CHK_CLRNULL          13][5 //       NULL
//    #define FORM_CHK_MESSAGE   14              // Message
//    #define FORM_CHK_GAP       15              // Gap                   0
//    #define FORM_CHK_CLICKED   16              // When Clicked        {||.T.}
//    #define FORM_CHK_CVAR      17              // Var Name
//    #define FORM_CHK_VALUEON   18              // Value ON
//    #define FORM_CHK_VALUEOFF  19              // Value OFF

