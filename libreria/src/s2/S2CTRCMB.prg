#include "dfCtrl.ch"
#include "dfMsg.ch"
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

// S2ComboBox: CTRL_CMB
// --------------------
CLASS S2ComboBox FROM XbpGet, S2Control, S2EditCtrl, S2PfkCtrl
   PROTECTED:
      VAR lDispLoop, lCalcSizeOnDisplay
      METHOD CtrlArrInit, DispItmCalcSize,ListboxStabilize 
      VAR oLsbForm 
      VAR xOLD
   EXPORTED:
      VAR bActive, bCond, bSys, oCombo, oPrompt, cMsg, cRefGrp, varName, oLsb
      VAR lLsbVisible, bDataChk
      METHOD Init, DispItm, SetInputFocus, KillInputFocus, Create, destroy
      METHOD SetFocus, hasFocus, CanSetFocus, Keyboard, enable, disable
      METHOD IsActive, PreGet, PostGet, ChkGet, ComboOpen, ComboClose
      METHOD DataChk
      METHOD /*handleEvent,*/ isShortCut //handleAction,
      METHOD updControl
      METHOD dfChkCombo, dfChkCol

      METHOD _Create
      METHOD dfComboGet

      METHOD GetData
      METHOD setParent, setOwner
      METHOD setPos, setSize, setPosAndSize
ENDCLASS

//Mantis 966
METHOD S2ComboBox:GetData()
   LOCAL xRet := ::XbpGet:GetData()
   LOCAL xVal := EVAL( ::oLsb:GETCOLUMN(1):BLOCK )
   IF VALTYPE(xRET) != VALTYPE(xVAL)
      DO CASE 
         CASE VALTYPE(xVAL) == "N"
            IF ISDIGIT(xRet)
               xRet  := VAL(xRet)
               xRet  := Transform( xRet, ::XbpGet:Picture   )
            ELSEIF EMPTY(xRet)
               xRet := 0
            ENDIF
         CASE VALTYPE(xVAL) == "D"
         CASE VALTYPE(xVAL) == "M"
              xRet :=  dfAny2Str(xRet,::picture)
         CASE VALTYPE(xVAL) == "C"
              xRet :=  dfAny2Str(xRet,::picture)
         CASE VALTYPE(xVAL) == "L"
      ENDCASE
   ENDIF

   // Simone 13/09/2006
   // mantis 0001143: Malfunzionamento combobox inserito su pagina 0 nel caso di form con multipagina.
   // su pagina 0 i combo su altre pagine 
   // non erano aggiornati
   IF ::aPage0 != NIL
      // Se Š pagina 0 aggiorno il buffer dei "fratelli"
      AEVAL(::aPage0, {|x|x:setData()})
   ENDIF
RETURN xRet

METHOD S2ComboBox:CtrlArrInit(aCtrl, oFormFather)
   IF EMPTY aCtrl[FORM_CMB_PICTUREGET] ASSIGN aCtrl[FORM_CMB_PICTURESAY]
   IF EMPTY aCtrl[FORM_CMB_PICTURESAY] ASSIGN aCtrl[FORM_CMB_PICTUREGET]
   IF EMPTY aCtrl[FORM_CMB_PICTUREGET] ASSIGN ""
   IF EMPTY aCtrl[FORM_CMB_PICTURESAY] ASSIGN ""
   DEFAULT aCtrl[FORM_CMB_PROMPT]     TO ""
   DEFAULT aCtrl[FORM_CMB_ACT]        TO ""
   DEFAULT aCtrl[FORM_CMB_CONDITION]  TO {||.T.}
   DEFAULT aCtrl[FORM_CMB_GAP]        TO 0
   DEFAULT aCtrl[FORM_CMB_SYS]        TO {||NIL}
   DEFAULT aCtrl[FORM_CMB_ACTIVE]     TO {||.T.}
   DEFAULT aCtrl[FORM_CMB_DATACHECK]  TO {||.T.}

   aCtrl[FORM_CMB_CTRLGRP] := dfChkGrp(aCtrl[FORM_CMB_CTRLGRP])

   DEFAULT aCtrl[FORM_CMB_CVAR]       TO ""
   DEFAULT aCtrl[FORM_CMB_MESSAGE]    TO ""
   DEFAULT aCtrl[FORM_CMB_CLRID]      TO {}
   ASIZE( aCtrl[FORM_CMB_CLRID], 6 )
   IF EMPTY aCtrl[FORM_CMB_CLRPROMPT] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_PROMPT   ]
   IF EMPTY aCtrl[FORM_CMB_CLRHOTKEY] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_HOTPROMPT]
   IF EMPTY aCtrl[FORM_CMB_CLRDATA  ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_COMBO    ]
   IF EMPTY aCtrl[FORM_CMB_CLRHILITE] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_CURSOR   ]
   IF EMPTY aCtrl[FORM_CMB_CLRICON  ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_GETCOMBO ]
   IF EMPTY aCtrl[FORM_CMB_PROMPT]    ASSIGN ""

   DEFAULT aCtrl[FORM_CMB_PFK]        TO {}

   IF !EMPTY(aCtrl[FORM_CMB_LISTBOX]) .AND. !TBISOPT(aCtrl[FORM_CMB_LISTBOX],W_MM_VSCROLLBAR)  
      aCtrl[FORM_CMB_LISTBOX]:W_RP_RIGHT++
      aCtrl[FORM_CMB_LISTBOX]:nRight++
      aCtrl[FORM_CMB_LISTBOX]:W_BG_RIGHT--
   ENDIF

#ifndef _NOFONT_
   ASIZE(aCtrl, FORM_CMB_CTRLARRLEN)
   aCtrl[FORM_CMB_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_CMB_FONTCOMPOUNDNAME ])
   aCtrl[FORM_CMB_PFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_CMB_PFONTCOMPOUNDNAME ])
   aCtrl[FORM_CMB_LFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_CMB_LFONTCOMPOUNDNAME ])
   IF EMPTY aCtrl[FORM_CMB_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseCmbFont")
   IF EMPTY aCtrl[FORM_CMB_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseGetFont")
   IF EMPTY aCtrl[FORM_CMB_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseCtrlFont")
   IF EMPTY aCtrl[FORM_CMB_FONTCOMPOUNDNAME ] ASSIGN APPLICATION_FONT
   IF aCtrl[FORM_CMB_FONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_CMB_FONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_CMB_FONTCOMPOUNDNAME ]))
      aCtrl[FORM_CMB_FONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_CMB_FONTCOMPOUNDNAME ])  
   ENDIF

   IF EMPTY aCtrl[FORM_CMB_PFONTCOMPOUNDNAME ] ASSIGN aCtrl[FORM_CMB_FONTCOMPOUNDNAME ]
   IF aCtrl[FORM_CMB_PFONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_CMB_PFONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_CMB_PFONTCOMPOUNDNAME ]))
      aCtrl[FORM_CMB_PFONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_CMB_PFONTCOMPOUNDNAME ]))
   ENDIF
   IF EMPTY aCtrl[FORM_CMB_PFONTCOMPOUNDNAME ] ASSIGN dfSet("XbasePromptGetFont")

   IF EMPTY aCtrl[FORM_CMB_LFONTCOMPOUNDNAME ] ASSIGN aCtrl[FORM_CMB_FONTCOMPOUNDNAME ]
   IF aCtrl[FORM_CMB_LFONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_CMB_LFONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_CMB_LFONTCOMPOUNDNAME ]))
      aCtrl[FORM_CMB_LFONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_CMB_LFONTCOMPOUNDNAME ])  
   ENDIF
#endif

RETURN

METHOD S2ComboBox:updControl(aCtrl)
   DEFAULT aCtrl TO ::aCtrl

   ::S2Control:updControl(aCtrl)

   ::Datalink := ::aCtrl[FORM_CMB_VAR]
   ::picture  := UPPER(::aCtrl[FORM_CMB_PICTUREGET])
   ::bActive  := ::aCtrl[FORM_CMB_ACTIVE]
   ::bCond    := ::aCtrl[FORM_CMB_CONDITION]
   ::bDataChk := ::aCtrl[FORM_CMB_DATACHECK]
   ::bSys     := ::aCtrl[FORM_CMB_SYS]
   ::cMsg     := ::aCtrl[FORM_CMB_MESSAGE]
   ::cRefGrp  := ::aCtrl[FORM_CMB_CTRLGRP]
   ::varName  := ::aCtrl[FORM_CMB_CVAR]
   ::oLsb     := ::aCtrl[FORM_CMB_LISTBOX]

   S2ObjSetColors(self, .T., aCtrl[FORM_CMB_CLRDATA], APPCOLOR_GET)

   IF ::oPrompt != NIL
      ::oPrompt:setCaption( ::ChgHotKey( ::aCtrl[FORM_CMB_PROMPT] ) )
      S2ObjSetColors(::oPrompt, ! ::oForm:hasBitmapBG(), aCtrl[FORM_CMB_CLRPROMPT], APPCOLOR_CMB)
   ENDIF

#ifndef _NOFONT_
   aCtrl[FORM_CMB_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_CMB_FONTCOMPOUNDNAME ])
   aCtrl[FORM_CMB_PFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_CMB_PFONTCOMPOUNDNAME ])
   aCtrl[FORM_CMB_LFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_CMB_LFONTCOMPOUNDNAME ])
   ::UpdObjFont( aCtrl[FORM_CMB_FONTCOMPOUNDNAME  ] )
   IF ::oPrompt != NIL
      ::UpdObjFont( aCtrl[FORM_CMB_PFONTCOMPOUNDNAME  ], ::oPrompt )
   ENDIF
   IF ::oLsb != NIL
      ::UpdObjFont( aCtrl[FORM_CMB_LFONTCOMPOUNDNAME  ], ::oLsb    )
   ENDIF
#endif
   //Mantis 634
   IF EMPTY(::bSys)
      ::bSys  := {||.T.}
   ENDIF


RETURN self


METHOD S2ComboBox:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos, oXbp
   LOCAL nLen, nLenSay
   LOCAL aSizeSle
   LOCAL cColorFG := dfSet("XbaseGetDisabledColorFG")
   LOCAL cColorBG := dfSet("XbaseGetDisabledColorBG")
   LOCAL aRealSize := {}
   ::CtrlArrInit(aCtrl, oFormFather)

   /////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////
   //Luca 09/10/2014 : effettuata correzione per avere la lunghezza 
   //                  del campo Combo in base la max tra picture in SAY o GET
   //nLen    := dfPictLen(aCtrl[FORM_CMB_PICTUREGET])
   /////////////////////////////////////////////////////////
   nLenSay := dfPictLen(aCtrl[FORM_CMB_PICTURESAY])
   nLen    := dfPictLen(aCtrl[FORM_CMB_PICTUREGET])
   nLen    := MAX(nLen,nLenSay )
   /////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////
 
   // Se non ho una picture oppure Š una picture del tipo "@!"
   // non posso sapere la larghezza reale e rimando tutto al primo display
   ::lCalcSizeOnDisplay := EMPTY(nLen)


   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF S2PixelCoordinate(aCtrl)
      DEFAULT aPos TO  {aCtrl[FORM_CMB_COL], aCtrl[FORM_CMB_ROW]}
      //IF LEN(aCTRL) >= FORM_CMB_SIZE
      //   DEFAULT aSize TO aCtrl[FORM_CMB_SIZE]
      //   IF !EMPTY(aSize)
      //     aSizeSle := {}
      //   ENDIF
      //ENDIF
      //IF EMPTY(aSize)
         nLen += 2.5
         oPos := PosCvt():new(nLen, 1)


         /////////////////////////////////////////////////////////////////////////////////
         //Mantis 688 
         //Luca 27/8/2014
         /////////////////////////////////////////////////////////////////////////////////
         //DEFAULT aSize TO {oPos:nXWin, oPos:nYWin)
         aRealSize := _GetRealSize(aCtrl[FORM_CMB_PICTUREGET], aCtrl[FORM_CMB_PFONTCOMPOUNDNAME])
         DEFAULT aSize TO {MAX(oPos:nXWin,aRealSize[1] ), MAX(oPos:nYWin,aRealSize[2] )}
         /////////////////////////////////////////////////////////////////////////////////
      //ENDIF
    
   ELSE
      // In caso di larghezza=1 o 2 allargo leggermente
      IF nLen <= 1
         nLen += .5
      ELSEIF nLen == 2
         nLen := 2.2
      ENDIF

      // box per il combo
      nLen += 2

      oPos := PosCvt():new(nLen, 1)
      DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}

      oPos := PosCvt():new(aCtrl[FORM_CMB_COL], aCtrl[FORM_CMB_ROW]+1)
      oPos:Trasla(oParent)

      DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}
   ENDIF

   DEFAULT lVisible TO .F.

#ifndef _NOFONT_
   IF ! EMPTY(aCtrl[FORM_CMB_FONTCOMPOUNDNAME])
      DEFAULT aPP TO {}
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_CMB_FONTCOMPOUNDNAME])
      //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_CMB_FONTCOMPOUNDNAME]})
   ENDIF
#endif

   DEFAULT aPP TO {}
   aPP := S2PPSetColors(aPP, {.T., 0}, aCtrl[FORM_CMB_CLRDATA], APPCOLOR_GET)



   IF cColorBG != NIL
      DEFAULT aPP TO {}
      IF cColorBG != NIL 
         IF S2IsNumber(cColorBG)
            aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_BGCLR,VAL(cColorBG))
         ELSE
            S2ItmSetColors({|n|NIL}, {|n| aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_BGCLR, n)}, .T., cColorBG)
         ENDIF
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
      ENDIF
   ENDIF



   // Inizializza l'oggetto
   // ---------------------
   ::XbpGet:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2Control:Init(aCtrl, nPage, oFormFather)
   ::S2EditCtrl:Init( aCtrl[FORM_CMB_CVAR] )
   ::S2PfkCtrl:Init( aCtrl[FORM_CMB_PFK] )

   //SD ::tabStop := .T.
   ::autoSize := .F.
   ::clipChildren := .T.
   ::clipSiblings := .F.
   ::Datalink := aCtrl[FORM_CMB_VAR]
   ::picture  := UPPER(aCtrl[FORM_CMB_PICTUREGET])
   ::bActive  := aCtrl[FORM_CMB_ACTIVE]
   ::bCond    := aCtrl[FORM_CMB_CONDITION]
   ::bDataChk := aCtrl[FORM_CMB_DATACHECK]
   ::bSys     := aCtrl[FORM_CMB_SYS]
   ::cMsg     := aCtrl[FORM_CMB_MESSAGE]
   ::cRefGrp  := aCtrl[FORM_CMB_CTRLGRP]
   ::varName  := aCtrl[FORM_CMB_CVAR]
   ::oLsb     := aCtrl[FORM_CMB_LISTBOX]
   ::lLsbVisible := .F.
   // ::group := XBP_WITHIN_GROUP
   ::lDispLoop := .F.

   // S2ObjSetColors(self, , aCtrl[FORM_CMB_CLRDATA])

   // Pulsante esterno al GET
   // oPos := PosCvt():new(aCtrl[FORM_CMB_COL]+dfPictLen(::picture), aCtrl[FORM_CMB_ROW]+1)
   // oPos:Trasla(oParent)
   // aPos := {oPos:nXWin, oPos:nYWin}
   // oPos := PosCvt():new(2,1)
   // oXbp := XbpPushButton():new(oParent, oOwner, aPos, {oPos:nXWin, oPos:nYWin} )

   // Pulsante interno al GET
   oPos      := PosCvt():new(2,1)
   aPos  := { aSize[1] - oPos:nXWin, 0 }
   aSize := {oPos:nXWin-4, aSize[2]-4}
   #ifdef IE4_STYLE
   oXbp := ie4Button():new(self, NIL, aPos, aSize )
   #else
   oXbp := XbpPushButton():new(self, NIL, aPos, aSize )
   #endif

   oXbp:caption := GET_BTN_DOWNARROWBMP
   oXbp:clipSiblings := .F.
   oXbp:pointerFocus := .F.
   oXbp:tabStop := .F.

   //oXbp:activate := {|| ACT := "Ada", ::KeyBoard( dbAct2Ksc(ACT) ) }
   oXbp:activate := {|| IIF(::isOnCurrentForm() .AND. ::CanSetPage(), ;
                            (ACT := "Ada", ::KeyBoard( dbAct2Ksc(ACT))), NIL) }

   ::oCombo := oXbp

   // PROMPT
   IF ! EMPTY(aCtrl[FORM_CMB_PROMPT])

      //13/05/04 Luca: Inserito per gestione pixel o Row/Column
      IF S2PixelCoordinate(aCtrl)
         aPos := {aCtrl[FORM_CMB_PCOL], aCtrl[FORM_CMB_PROW]}
      ELSE
         oPos := PosCvt():new(aCtrl[FORM_CMB_PCOL], aCtrl[FORM_CMB_PROW]+1)
         oPos:Trasla(oParent)
         aPos := {oPos:nXWin, oPos:nYWin}
      ENDIF

      aPP := NIL
   #ifndef _NOFONT_
      IF ! EMPTY(aCtrl[FORM_CMB_PFONTCOMPOUNDNAME])
         aPP := {}
         aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_CMB_PFONTCOMPOUNDNAME])
         //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_CMB_PFONTCOMPOUNDNAME]})
      ENDIF
   #endif
      aPP := S2PPSetColors(aPP, ! oFormFather:hasBitmapBG(), aCtrl[FORM_CMB_CLRPROMPT], APPCOLOR_GET)
      ///////////////////////////////////////////////////////////
      //Mantis 672
      //oXbp:autoSize := .T.
      //oXbp := XbpStatic():new(oParent, oOwner , aPos, NIL, aPP )
      aSize := {Len(StrTran(Trim(aCtrl[FORM_CMB_PROMPT]),"^",""))*8,22 }
      oXbp := XbpStatic():new(oParent, oOwner , aPos, aSize, aPP )
      //oXbp:autoSize := .F.
      oXbp:autoSize := .T.

     ///////////////////////////////////////////////////////////

      oXbp:caption := ::ChgHotKey( aCtrl[FORM_CMB_PROMPT] )
      oXbp:clipSiblings := .F.

      ///////////////////////////////////////////////////////////
      //Mantis 672
      //oXbp:options := XBPSTATIC_TEXT_VCENTER
      oXbp:options := XBPSTATIC_TEXT_TOP + XBPSTATIC_TEXT_RIGHT
      ///////////////////////////////////////////////////////////

      // Allineamento a destra del prompt se Š sulla stessa riga
      IF aCtrl[FORM_CMB_PROW] == aCtrl[FORM_CMB_ROW] .AND. ;
         aCtrl[FORM_CMB_PCOL] <  aCtrl[FORM_CMB_COL] .AND. ;
         ! EMPTY(dfSet("XbasePromptAlign"))

         oXbp:options := VAL(dfSet("XbasePromptAlign"))
      ENDIF

      oXbp:rbDown := oParent:rbDown

      //S2ObjSetColors(oXbp, , aCtrl[FORM_CMB_CLRPROMPT], APPCOLOR_CMB)

      ::oPrompt := oXbp
   ELSE
      ::oPrompt := NIL
   ENDIF

   // Mantis 605
   IF S2PixelCoordinate(::aCtrl)
      ::oLsbForm  := XbpDialog():new()
      ::oLsbForm:titleBar      := .F.
      ::oLsbForm:border        := XBPDLG_THINBORDER //XBPDLG_NO_BORDER
      ::oLsbForm:movewithowner := .T.
      ::oLsbForm:drawingArea:setColorBG(GRA_CLR_PALEGRAY)
      ::oLsbForm:Tabstop       := .F.
      ::oLsbForm:origin        := XBPDLG_ORIGIN_OWNER
   ENDIF
   ::oLsb:tabStop := .F.
   ::oLsb:oForm := oFormFather

   DEFAULT ::bSys TO {||.T.}                       

   // Simone 13/09/2006 spostato nella :dispItm
   // mantis 0001143: Malfunzionamento combobox inserito su pagina 0 nel caso di form con multipagina.
   //Mantis 634
   //Non viene eseguita la funzione di Function Get  in BSys
   //::oLsb:itemSelected := {||::ComboClose(.T.), ::GetData(),  ::setFocus() }
//   ::oLsb:itemSelected := {||::ComboClose(.T.), ::GetData(),EVAL(::bSys, ::get),  ::setFocus() }
   //::oLsb:itemSelected := {||::ComboClose(.T.), ::GetData(),EVAL(::bSys, ::XbpGet),  ::setFocus() }
//   ::oLsb:killInputFocus := {|| ::ComboClose() }
//   ::oLsb:keyboard := {|n| IIF(ACT=="ret", EVAL(::oLsb:itemSelected), NIL) }

   ADDKEY "esc" TO ::oLsb:W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| ::ComboClose(), ::setFocus() }  ; // Funzione sul tasto
         WHEN    {|s| ::lLsbVisible }                    ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE ""




   ::rbDown := {|mp1, mp2, obj| S2GetRBMenu():popUp(obj, mp1) }
RETURN self

METHOD S2ComboBox:isShortCut(cAct)
   LOCAL lRet := .F. , nPos

   IF ! EMPTY(::oPrompt) .AND. ;
      VALTYPE( ::oPrompt:caption ) == "C" .AND. ;
      ( nPos := AT( STD_HOTKEYCHAR, ::oPrompt:caption) ) != 0

      // nRet := dbAct2Ksc("A_"+LOWER( SUBSTR( ::oPrompt:caption, nPos + 1, 1)))
      lRet := cAct == "A_"+LOWER( SUBSTR( ::oPrompt:caption, nPos + 1, 1))

   ENDIF
RETURN lRet

METHOD S2ComboBox:Create()


RETURN self

METHOD S2ComboBox:destroy()
   ::XbpGet:destroy()
   // simone 15/4/06
   // mantis 0001041: errore runtime in riaprendo una form che contiene combobox
   // mantis 0001042: alla chiusura della form non viene fatto destroy() della listbox del combo
   IF ! EMPTY(::oLsbForm) .AND. ::oLsbForm:status() == XBP_STAT_CREATE
      ::oLsbForm:destroy()
   ENDIF
RETURN self

METHOD S2ComboBox:_Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos
   LOCAL cFont
   LOCAL aPos_Sle
   LOCAL aPos_Prompt
   LOCAL oOwn
   LOCAL nSizeXReal, nSizeXTemp, nDiff, aPOsP
   IF ::status() == XBP_STAT_INIT

      IF S2PixelCoordinate(::aCtrl)
         aPos_Sle  := {::oLsb:nLeft, ::oLsb:nBottom +::oLsb:nTop - ::Xbpget:Currentsize()[2]  }
         ::XbpGet:Create( oParent, oOwner, aPos_Sle, aSize, aPP, lVisible )
      ELSE
         ::XbpGet:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
      ENDIF
      ::oCombo:Create()

      oParent := ::setParent()
      oOwner  := ::setOwner()

      IF ::oPrompt != NIL
         IF S2PixelCoordinate(::aCtrl)
            aPos_Prompt := {::aCtrl[FORM_CMB_PCOL],aPos_Sle[2] }
            ::oPrompt:Create(NIL, NIL, aPos_prompt)
            ///////////////////////////////////////////////////////////
            //Mantis 672
            ::oPrompt:autoSize := .T.
            nSizeXReal := ::oPrompt:Currentsize()[1] 
            nSizeXTemp := Len(StrTran(Trim(::aCtrl[FORM_CMB_PROMPT]),"^",""))*8
            //nDiff      := MAX((nSizeXTemp - nSizeXReal) , 0)
            nDiff      := (nSizeXTemp - nSizeXReal) 
            aPosP      := ::oPrompt:CurrentPos()
            aPosP[1]   += nDiff
            ::oPrompt:SetPos(aPosP)
            aPosP[2]   := ::XbpGet:CurrentPos()[2]+ ::XbpGet:Currentsize()[2] -::oPrompt:Currentsize()[2]
            ::oPrompt:SetPos(aPosP)
            ///////////////////////////////////////////////////////////
         ELSE
            ::oPrompt:Create()
         ENDIF
      ENDIF

      //13/05/04 Luca: Inserito per gestione pixel o Row/Column
      IF S2PixelCoordinate(::aCtrl)
         aPos  := {::oLsb:nLeft ,::oLsb:nTop - ::Xbpget:Currentsize()[2]  }
         aSize := {::oLsb:nRight, ::oLsb:nBottom}
      ELSE
         oPos := PosCvt():new(::oLsb:nLeft, ::oLsb:nBottom+1)
         oPos:Trasla(oParent)

         aPos := {oPos:nXWin, oPos:nYWin}

         oPos:SetDos(::oLsb:nRight - ::oLsb:nLeft, ::oLsb:nBottom - ::oLsb:nTop + 1)

         aSize := {oPos:nXWin, oPos:nYWin}
      ENDIF
   #ifndef _NOFONT_
      DEFAULT cFont TO ::aCtrl[FORM_CMB_LFONTCOMPOUNDNAME]
      DEFAULT cFont TO ::setFontCompoundName()
      IF ! EMPTY(cFont)
         DEFAULT aPP TO {}
         AADD(aPP, {XBP_PP_COMPOUNDNAME, cFont})
      ENDIF
   #endif

      // Mantis 605
      IF S2PixelCoordinate(::aCtrl) .AND. !EMPTY(::oLsbForm )
         aPos := dfCalcAbsolutePosition(aPos,oParent)
         ::oLsbForm:Create(AppDesktop(), oOwner,{aPos[1]+3, aPos[2]+2}, {aSize[1]+6,aSize[2]+2 },NIL ,.F.) 
         ::oLsbForm:Hide()
         // Dati per ListBox
         oParent  := ::oLsbForm
         // Simone 13/09/2006
         // mantis 0001143: Malfunzionamento combobox inserito su pagina 0 nel caso di form con multipagina.
         // oOwner   := ::setParent()
         oOwner   := NIL
         aPos     := {2, 2}
         aSize    := {aSize[1],aSize[2]-4}
      ENDIF

      ::oLsb:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ENDIF
RETURN self


METHOD S2ComboBox:IsActive()
RETURN EVAL(::bActive)

METHOD S2ComboBox:PreGet()
RETURN EVAL(::bCond, FORM_PREGET)

METHOD S2ComboBox:PostGet()
RETURN EVAL(::bCond, FORM_POSTGET)

METHOD S2ComboBox:ChkGet()
RETURN EVAL(::bCond, FORM_CHKGET)

METHOD S2ComboBox:DataChk()
   LOCAL lRet := .T.
   LOCAL xVal := ::getData()
   //Mantis 806
   //IF EVAL(::bDataChk) .AND. !::dfChkCombo( ::getData(), ::oLsb) .AND. !::PostGet() 
   IF EVAL(::bDataChk) .AND. (!::dfChkCombo( xVal, ::oLsb) .OR. !::PostGet()) 
      dbMsgErr( dfStdMsg(MSG_TBGET03)+"!" )
      //Mantis 806

      IF !EMPTY(::xOLD)
         xVal := ::xOLD
      ENDIF
      IF !::dfChkCombo( xVal, ::oLsb )
         IF ::oLsb:COLCOUNT>0
            xVal := EVAL( ::oLsb:GETCOLUMN(1):BLOCK )
            IF VALTYPE( xVal ) == "C"
               xVal := PADR( xVal, LEN( dfAny2Str(EVAL(::dataLink) ) ))
               xVal := dfAny2Str(xVal,::picture)
            ENDIF
         ENDIF
      ENDIF

      ::dfComboGet( xVal, ::oLsb)
      lRet := .F.
   ENDIF
RETURN lRet
////////////////////////////////////////////////////////////////                              
//Mantis 806
METHOD S2ComboBox:dfComboGet( uComboVar,oCmb)
//LOCAL xVal := ::GetData()

  EVAL( ::dataLink,uComboVar)
  ::setData(uComboVar )
RETURN Self

//IF oCmb:COLCOUNT>0
//   uComboVar := EVAL( oCmb:GETCOLUMN(1):BLOCK )
//   IF VALTYPE( uComboVar ) == "C"
//      uComboVar := PADR( uComboVar, LEN( dfAny2Str(EVAL(::dataLink) ) ))
//      uComboVar := dfAny2Str(uComboVar,::picture)
//   ENDIF
//   EVAL( ::dataLink,uComboVar)
//   ::setData(uComboVar )
//ENDIF
RETURN Self
////////////////////////////////////////////////////////////////                              


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD S2ComboBox:dfChkCombo( uVar, oCmb )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL lRet := .F., nRec := 0

   IF oCmb:COLCOUNT<1
      lRet := .T.
   ELSE
      tbScan( oCmb, {||(nRec:=::dfChkCol(oCmb,uVar,nRec))>0} )
      IF nRec#0
         IF !EMPTY(oCmb:W_ALIAS)
            (oCmb:W_ALIAS)->(DBGOTO_XPP(nRec))
         ELSE
            oCmb:W_CURRENTREC := nRec
         ENDIF
         lRet:=.T.
         ::xOLD := uVar
      ENDIF
   ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
METHOD S2ComboBox:dfChkCol( oCmb, uVar, nRec )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL uComboVar, lRet := .F.
   local cX1,cX2 
   IF nRec==0
      uComboVar := EVAL( oCmb:GETCOLUMN(1):BLOCK )
      IF VALTYPE( uComboVar ) == "C"
         uVar := ALLTRIM(UPPER( dfAny2Str(uVar) ))
         lRet := ALLTRIM(UPPER( uComboVar ))==uVar
         IF !lRet .AND. uVar==LEFT( ALLTRIM(UPPER(uComboVar)), LEN(uVar))
            lRet := .T.
         ENDIF
      ELSE
         //////////////////////////////////////////////
         //Mantis 966
         //lRet := uComboVar==uVar
         cX1:= dfAny2Str(uComboVar,::picture)
         cX2:= dfAny2Str(uVar     ,::picture) 
         lRet := cX1 == cX2
         //////////////////////////////////////////////
      ENDIF
      IF lRet
         IF !EMPTY(oCmb:W_ALIAS)
            nRec := (oCmb:W_ALIAS)->(RECNO())
         ELSE
            nRec := oCmb:W_CURRENTREC
         ENDIF
      ENDIF
   ENDIF
RETURN nRec

////////////////////////////////////////////////////
//MANTES 1061
METHOD S2ComboBox:ListboxStabilize()
   LOCAL nREC
   IF ::oLsb:W_KEY#NIL
      IF ::oLsb:W_CURRENTKEY #  EVAL( ::oLsb:W_KEY )
         ::oLsb:W_CURRENTKEY := EVAL( ::oLsb:W_KEY )
         ::oLsb:W_OBJREFRESH := .T.
         ::oLsb:W_OBJGOTOP   := .T.
      ENDIF
   ENDIF

   IF ::oLsb:W_OBJREFRESH      // Invalido

      // ::oLsb:refreshAll()

      // ::oLsb:INVALIDATE()         // Invalidate dell'oggetto
      //                            // Serve per il refresh del
      //                            // cambio pagina
   ENDIF

   nRec := ::oLsb:W_CURRENTREC    // Memorizzo il vecchio record

   IF ::oLsb:W_OBJGOTOP           // Go Top
      ::oLsb:W_OBJGOTOP := .F.
      tbPos( ::oLsb )
   ENDIF

   IF ::oLsb:W_OBJREFRESH // .OR. !::oLsb:STABLE
      tbStab( ::oLsb )
   ENDIF

   IF ::oLsb:W_CURRENTREC#nRec .OR.;
      ::oLsb:W_OBJREFRESH
      ::oLsb:W_OBJREFRESH  := .F.

      tbRecCng( ::oLsb) // Aggiorno W_CURRENTREC

      tbSys( ::oLsb, ::oForm )
   ENDIF
RETURN self
////////////////////////////////////////////////////

METHOD S2ComboBox:DispItm() // ( cGrp, lRef )
   LOCAL lRet := .F.,nRec 

   IF ! ::lDispLoop
      ::lDispLoop := .T.

      ::_Create() // Vedi S2Get:dispItm

      IF ::lCalcSizeOnDisplay

         ::DispItmCalcSize()

         // Evito il ricalcolo una seconda volta
         ::lCalcSizeOnDisplay := .F.
      ENDIF


      ::Get:SetFocus()

      IF ::CanShow()
         ///////////////////////////
         //MANTES 1061
         ::ListboxStabilize()
         ///////////////////////////
         ::show()
         IF ::oPrompt != NIL
            ::oPrompt:show()
         ENDIF
         lRet := .T.
      ELSE
         ::hide()
         IF ::oPrompt != NIL
            ::oPrompt:hide()
         ENDIF
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
RETURN self

METHOD S2ComboBox:DispItmCalcSize()
   LOCAL nLen
   LOCAL oPos
   LOCAL aSize

   nLen := dfPictLen(::picture)

   IF EMPTY(nLen)
      nLen := LEN(dfAny2Str(EVAL( ::dataLink )))
   ENDIF


   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF S2PixelCoordinate(::aCtrl)
      IF LEN(::aCTRL) >= FORM_CMB_SIZE
         aSize := ::aCtrl[FORM_CMB_SIZE]
      ENDIF
      IF EMPTY(aSize)
         nLen += 2.5
         oPos := PosCvt():new(nLen, 1)
         //aSize := {oPos:nXWin, oPos:nYWin}
         aSize := {oPos:nXWin, ::CurrentSize()[2]}
      ENDIF
   ELSE
      // In caso di larghezza<=1 o 2 allargo leggermente
      IF nLen <= 1
         nLen += .5
      ELSEIF nLen == 2
         nLen := 2.2
      ENDIF

      nLen += 2

      oPos := PosCvt():new(nLen, 1)
      aSize := {oPos:nXWin, oPos:nYWin}
   ENDIF

#ifdef _XBASE15_
   // Ottimizzazione per Xbase 1.5
   // uso setPosAndSize()

   IF ::oCombo == NIL
      ::XbpGet:setSize(aSize)
   ELSE
      oPos := PosCvt():new(2,1)
      ::XbpGet:setPosAndSize({aSize[1]-oPos:nXWin, 0}, aSize)
   ENDIF

#else
   ::setSize(aSize)

   IF ::oCombo != NIL
      oPos := PosCvt():new(2,1)

      aSize[1] -= oPos:nXWin
      aSize[2] := 0
      ::oCombo:setPos(aSize)
   ENDIF
#endif

RETURN self

METHOD S2ComboBox:enable()
   LOCAL lRet := ::XbpGet:enable()
RETURN lRet

METHOD S2ComboBox:disable()
   LOCAL lRet := ::XbpGet:disable()
RETURN lRet


// Quando acquista il focus riposiziona al primo carattere
METHOD S2ComboBox:SetInputFocus()
   LOCAL aMarked
   LOCAL oForm


   //IF ::isOnCurrentForm()  <- Questo da errore... perchŠ?
   IF S2FormCurr() == ::oForm

      IF ::CanSetPage() .AND. ::PreGet()
         ::oForm:SetMsg(::cMsg)

         ::Get:Home()
         ::SetFirstChar( 1 )

         IF Set( _SET_INSERT )
            aMarked := { ::Get:Pos, ::Get:Pos }
         ELSE
            aMarked := { ::Get:Pos, ::Get:Pos + 1 }
         ENDIF

         ::SetMarked( aMarked )
      ELSE
         ::oForm:skipFocus(1)
         //PostAppEvent(xbeP_KillInputFocus, NIL, NIL, self)
      ENDIF
      ::xOLD := ::GetData()
   ENDIF

RETURN self

METHOD S2ComboBox:ComboOpen()
   LOCAL aPos, o
   IF ! ::lLsbVisible

      IF ::oForm:hasBitmapBG()
         // Stop dei control in realtime per evitare brutti refresh
         // sopra la listbox
         ::oForm:lRealTimeStop := .T.
      ENDIF

      // Simone 27/3/03 gerr 3729 modificato ordine delle operazioni
      // per migliorare il display della listbox

      // Mantis 605
      ::setFocus()
      IF S2PixelCoordinate(::aCtrl) .AND. !EMPTY(::oLsbForm )
         aPos  := ::XbpGet:currentPos()
         aPos[1] += 3
         aPos[2] -= ::oLsb:currentSize()[2]+2

//         aPos  := {::oLsb:nLeft+3 ,::oLsb:nTop - ::Xbpget:Currentsize()[2]+2  }

         // simone 9/3/06
         // mantis 0001000: i combo box dentro groupbox in stile "flat" visualizzano la listbox di selezione in posizione errata
         //aPos := dfcalcAbsolutePosition(aPos,self:setparent())
//         o := ::setParent()
//         DO WHILE ! EMPTY(o) .AND. o:isDerivedFrom("S2GroupBox")
//            o := o:setParent()
//         ENDDO

//::oform:setTitle(dfany2str({aPos, ::oLsb:nleft, ::oLsb:ntop, dfCalcAbsolutePosition(aPos, o)}))

         aPos := dfCalcAbsolutePosition(aPos, ::setParent())

         ::oLsbForm:SetPos(aPos)
         ::oLsbForm:Show()
         ::oLsbForm:toFront()
         ::oLsb:toFront()
      ELSE
         ::oLsb:toFront()
      ENDIF
      ::oLsb:refreshAll()
      ::oLsb:dispItm()
      ::oLsb:invalidateRect()

      // Simone 13/09/2006
      // mantis 0001143: Malfunzionamento combobox inserito su pagina 0 nel caso di form con multipagina.
      // aggiornamento parent della listbox
      ::oLsb:setParent(::oLsbForm)
      ::oLsb:setOwner(::oLsbForm)

      // Simone 13/09/2006
      // mantis 0001143: Malfunzionamento combobox inserito su pagina 0 nel caso di form con multipagina.
      // imposta il combo collegato
      ::oLsb:itemSelected := {||::ComboClose(.T.), ::GetData(),EVAL(::bSys, ::get),  ::setFocus() }
      ::oLsb:killInputFocus := {|| ::ComboClose() }
      ::oLsb:keyboard := {|n| IIF(ACT=="ret", EVAL(::oLsb:itemSelected), NIL) }

      ::lLsbVisible := .T.
      ::setFocus()

   ENDIF
RETURN self

METHOD S2ComboBox:ComboClose(lAccept)
   LOCAL xVal
   IF ::lLsbVisible
      IF lAccept != NIL .AND. lAccept .AND. ::ChkGet()
         //Mantis 820
         //::setData( EVAL( ::oLsb:getColumn(1):dataLink ) )
         xVal := EVAL( ::oLsb:getColumn(1):block)
         IF VALTYPE(xVal) == "N" .AND. xVal == 0
            ::Get:Buffer := Transform ( xVal, ::Get:Picture )
            ::SetEditBuffer( ::Get:Buffer )
         ELSE
            ::setData(xVal)
         ENDIF
      ELSE
        ::PostGet()
      ENDIF


      // Mantis 605
      IF S2PixelCoordinate(::aCtrl) .AND. !EMPTY(::oLsbForm )
         ::oLsbForm:hide()
         ::setParent():setParent():invalidateRect(       ;
            {  ::oLsbForm:currentPos()[1]                      ,  ;
               ::oLsbForm:currentPos()[2]+20                   ,  ;
               ::oLsbForm:currentPos()[1]+::oLsbForm:currentSize()[1]+20   ,  ;
               ::oLsbForm:currentPos()[2]+::oLsbForm:currentSize()[2]+25 } )
         setappfocus(::Xbpget)
      ELSE
         ::oLsb:hide()
      ENDIF

      ::lLsbVisible := .F.

      // Simone 27/3/03 gerr 3729
      // esegue l'invalidateRect() anche su form multipagina e lo spazio
      // di invalidateRect() Š un po maggiore
      IF ::oForm:hasBitmapBG() .OR. ::oForm:tbPgMax() > 1
         ::setParent():setParent():invalidateRect(       ;
            {  ::oLsb:currentPos()[1]                      ,  ;
               ::oLsb:currentPos()[2]+20                   ,  ;
               ::oLsb:currentPos()[1]+::oLsb:currentSize()[1]+20   ,  ;
               ::oLsb:currentPos()[2]+::oLsb:currentSize()[2]+25 } ;
                                                )

         //::setParent():setParent():invalidateRect()
      ENDIF

      IF ::oForm:hasBitmapBG()
         // Riavvio dei control in realtime
         ::oForm:lRealTimeStop := .F.
      ENDIF

   ENDIF
RETURN self

METHOD S2ComboBox:KillInputFocus()
   //::ComboClose()

   // IF ::isOnCurrentForm() -> Questo da errore! MAH!
   IF S2FormCurr() == ::oForm .AND. ::CanSetPage()
      ::getData()
      ::PostGet()
      ::oForm:tbDisRef(::cId)
      IF ! EMPTY(::cRefGrp)
         ::oForm:tbDisRef(::cRefGrp)
      ENDIF
   ENDIF
RETURN self

METHOD S2ComboBox:CanSetFocus()
//SD RETURN ::TabStop .AND. ::IsActive() .AND. ::CanShow() .AND. ::PreGet() //::isEnabled() .AND. ::isVisible()
RETURN ::CanSetPage() .AND. ::IsActive() .AND. ::CanShow() .AND. ::PreGet() //::isEnabled() .AND. ::isVisible()

METHOD S2ComboBox:SetFocus()
   ::setHelpID(::cID)
   ::enable()
RETURN SetAppFocus( IIF(::lLsbVisible, ::oLsb, self ) )


METHOD S2ComboBox:hasFocus()
RETURN SetAppFocus() == self .OR. SetAppFocus() == ::oCombo .OR. SetAppFocus() == ::oLsb

METHOD S2ComboBox:Keyboard( nKey )
   LOCAL aMarked, cChar, lHandled := .T.
   LOCAL setPos    := .T.
   LOCAL lEnter := .F.

   // Imposta variabili pubbliche ACT, A e SA

   aMarked := ::QueryMarked()

   DO CASE

   CASE ACT $ "uar,Stb"
        ::oForm:skipFocus(-1)
        lHandled := .T.

   CASE ACT == "tab" .OR. ACT == "ret" .OR. ACT == "Ada" .OR. ;
        ACT == "Cda" .OR. ACT == "win" .OR. ACT == "dar"

        IF ACT == "win"
           ACT := "Ada"
        ENDIF

        ::GetData()

        IF ACT $ "win,Ada,Cda"

           IF ::lLsbVisible
              ::ComboClose()
           ELSE
              ::ComboOpen()
           ENDIF

        ELSE

           IF ::DataChk()
              ::oForm:skipFocus(1)
           ELSE
              ACT := "rep"
           ENDIF
           //Mantis 806
           ::dfComboGet(::getData(), ::oLsb)
           //::setData()

        ENDIF

        lHandled := .T.

   CASE ACT == "Sra"

        ::Get:Pos ++
        aMarked[2] := ::Get:Pos
        ::SetMarked( aMarked )
        setPos := .F.

   CASE ACT == "Sla"
        ::Get:Pos --
        aMarked[1] := ::Get:Pos
        ::SetMarked( aMarked )
        setPos := .F.

   CASE ACT == "Snd"
        aMarked[2] := ::Bufferlength + 1
        ::Get:Pos  := ::Bufferlength
        ::SetMarked( aMarked )
        setPos := .F.

   CASE ACT == "Sho"
        ::Get:Pos  := 1
        aMarked[1] := 1
        ::SetMarked( aMarked )
        setPos := .F.

   CASE ACT == "C_u"
        ::Undo()

   CASE ACT == "rar"
        ::Get:Right()

   CASE ACT == "Cra"
        ::Get:WordRight()

   CASE ACT == "lar"
        ::Get:Left()

   CASE ACT == "Cla"
        ::Get:WordLeft()

   CASE ACT == "hom"
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

   CASE nKey >= 32 .AND. nKey <= 255
        cChar := CHR(nKey)

        IF ::Get:Type == "N" .AND. cChar $ ".,"
           ::Get:ToDecPos()
        ELSE

           IF ::editable
              IF Set(_SET_INSERT)
                 ::Get:Insert( cChar )
              ELSE
                 ::Get:Overstrike( cChar )
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

   IF ! lHandled
      RETURN ::XbpSLE:Keyboard( nKey )
   ENDIF

RETURN self

// Simone 19/4/06
// mantis 0001003: migliorare resize nelle form
METHOD S2ComboBox:setPosAndSize(aPos, aSize, lPaint)
   ::setPos(aPos, lPaint)
   ::setSize(aSize, lPaint)
RETURN .T.

METHOD S2ComboBox:setPos(aPos, lPaint)
   LOCAL lRet
   LOCAL aCurPos
   LOCAL oObj, o
   //   LOCAL oObj := IIF(::oStatic == NIL, ::XbpGet, ::oStatic)

   DEFAULT lPaint TO .T.

   // sposta prompt
   IF ::oPrompt != NIL 
      aCurPos := ::currentPos()
      aCurPos[1] := ::oPrompt:currentPos()[1] - aCurPos[1]
      aCurPos[2] := ::oPrompt:currentPos()[2] - aCurPos[2]
      ::oPrompt:setPos({aPos[1]+aCurPos[1], aPos[2]+aCurPos[2]}, lPaint)
   ENDIF

//   o := ::setParent()
//   DO WHILE ! EMPTY(o)
//      IF o:isDerivedFrom("S2GroupBox")
//         EXIT
//      ENDIF
//      o := o:setParent()
//   ENDDO
//
//   IF EMPTY(o) .OR. ;
//      ! o:isDerivedFrom("S2GroupBox") // se non sono dentro un groupbox
      // sposta listbox
      IF ! EMPTY(::oLsbForm) 
         aCurPos  := ::currentPos() 
         aCurPos[1] := ::oLsb:nLeft - aCurPos[1]
         aCurPos[2] := ::oLsb:nTop  - aCurPos[2]
         ::oLsb:nLeft := aPos[1] + aCurPos[1]
         ::oLsb:nTop  := aPos[2] + aCurPos[2]

      ELSEIF ! EMPTY(::oLsb)
         oObj := ::oLsb
         aCurPos := ::currentPos()
         aCurPos[1] := oObj:currentPos()[1] - aCurPos[1]
         aCurPos[2] := oObj:currentPos()[2] - aCurPos[2]
         oObj:setPos({aPos[1]+aCurPos[1], aPos[2]+aCurPos[2]}, lPaint)

      ENDIF
//   ENDIF

   // sposta get
   lRet := ::XbpGet:setPos(aPos, lPaint)
RETURN lRet

// nota: simone 18/4/06 il resize dovrebbe allargare 
// la listbox e non il combo, ma Š un casino e ora non
// ho tempo... bisogna vedere in 
// VDB\dbseexpp\dbcontrolcmb.prg come Š implementato!!
METHOD S2ComboBox:setSize(aSize, lPaint)
   LOCAL lRet
   LOCAL aPos
   LOCAL nXDiff
   LOCAL aOldSize 
   LOCAL aObjSize 
   LOCAL oObj
   LOCAL aCurPos

   DEFAULT lPaint TO .T.

   aOldSize := ::currentSize()

   IF ::oCombo != NIL
      nXDiff := ::oCombo:currentPos()[1] - ::currentSize()[1]
   ENDIF

   // ridimensiona GET solo in orizzontale
   aPos := ::currentPos()

   aPos[2] += aSize[2]-aOldSize[2]

   // sposta prompt in verticale
   IF ::oPrompt != NIL 
      aCurPos := ::currentPos()
      aCurPos[2] := ::oPrompt:currentPos()[2] - aCurPos[2]
      ::oPrompt:setPos({::oPrompt:currentPos()[1], aPos[2]+aCurPos[2]}, lPaint)
   ENDIF

   lRet := ::XbpGet:setSize(aSize, lPaint)

   // sposta combo solo in orizzontale
   IF lRet .AND. nXDiff != NIL
      aPos := ACLONE(aSize)
      aPos[2] := ::oCombo:currentPos()[2]
      aPos[1] += nXDiff
      aObjSize := {::oCombo:currentSize()[1], aSize[2]}
      ::oCombo:setPosAndSize(aPos, aObjSize, lPaint)
//      ::oCombo:setPos(aPos, lPaint)
   ENDIF

   // sposta listbox
   oObj := ::oLsbForm
   IF ! EMPTY(oObj)
      aObjSize := oObj:currentSize()
      aObjSize[1] += (aSize[1]-aOldSize[1])
      ::oLsb:nTop += (aSize[2]-aOldSize[2])
      oObj:setSize(aObjSize, lPaint)
   ENDIF
   oObj := ::oLsb
   IF ! EMPTY(oObj)
      aObjSize := oObj:currentSize()
      aObjSize[1] += (aSize[1]-aOldSize[1])
      oObj:setSize(aObjSize, lPaint)
   ENDIF
RETURN lRet

METHOD S2ComboBox:setParent(o)
   LOCAL oRet, aPos1, aPos2
   // LOCAL oObj := IIF(::oStatic == NIL, ::XbpGet, ::oStatic)

   IF PCOUNT() > 0
      oRet := ::XbpGet:setParent(o)
      IF ::oPrompt != NIL
         ::oPrompt:setParent(o)
      ENDIF
      IF ! EMPTY(::oLsbForm)
         // simone 1/6/06
         // correzione per combo dentro box piatti che si spostano
         // alla seconda apertura della form
         // ::oLsb:nLeft += o:currentPos()[1]
         // ::oLsb:nTop  += o:currentPos()[2]
         aPos1 := dfCalcAbsolutePosition({0, 0}, oRet)
         aPos2 := dfCalcAbsolutePosition({0, 0}, o)
         ::oLsb:nLeft += aPos2[1]-aPos1[1]
         ::oLsb:nTop  += aPos2[2]-aPos1[2]
      ENDIF

   ELSE
      oRet := ::XbpGet:setParent()
   ENDIF
RETURN oRet

METHOD S2ComboBox:setOwner(o)
   LOCAL oRet

   IF PCOUNT() > 0
      oRet := ::XbpGet:setOwner(o)
   ELSE
      oRet := ::XbpGet:setOwner()
   ENDIF
RETURN oRet

// DA FARE COMBO
//
//    #COMMAND ATTACH <cId> TO <aParent> GET AS COMBO <uVar>;
//                                       AT  <nRow>, <nCol> ;
//                                       [PAGE    <nPage>]  ;
//                                       [PICTUREGET <cPicGet>] ;
//                                       [PICTURESAY <cPicSay>] ;
//                                       [CONDITION <uCond>] ;
//                                       [ACTIVE <uActive>]   ;
//                                       [PROMPT  <cPrompt>] ;
//                                       [PROMPTAT <nPRow>, <nPCol>] ;
//                                       [DISPLAYIF <uDiIf>] ;
//                                       [SYSFUNCTION <uSys>];
//                                       [REFRESHGRP  <uGrp>];
//                                       [LISTBOX <oList>]   ;
//                                       [MESSAGE <cMes>]    ;
//                                       [GAP     <nGap>]    ;
//                                       [PFK <aPfk>]        ;
//                                       [VARNAME <cVarName>];
//                                       [ACT <cAct>]        ;
//                                       [COLOR   <aCol>]    ;
//                                       [DATACHECK <bChk>]  ;
//                                       [REFRESHID <cRID>]  ;
//                                                           ;
//      => aAdd( <aParent>, { CTRL_CMB ,;
//                                <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
//                          {|uVal|IF(uVal==NIL, <uVar>, <uVar>:=uVal)},;
//                          <nRow>, <nCol>, ;
//                          <cPrompt>, <nPRow>, <nPCol>,;
//                          <cPicGet>, <cPicSay>,;
//                          <cMes>, <aPfk>, <cVarName>, <{uCond}>,;
//                          <{uActive}>,;
//                          <aCol>, <{uSys}>, <oList>,;
//                          <nGap>, <cAct>, <uGrp>, <{bChk}> })
//
//                                              //                      DEFAULT
//    #define FORM_CMB_VAR         7            // Var
//    #define FORM_CMB_ROW         8            // Row
//    #define FORM_CMB_COL         9            // Col
//    #define FORM_CMB_PROMPT     10            // Prompt                  ""
//    #define FORM_CMB_PROW       11            // Prompt Row
//    #define FORM_CMB_PCOL       12            // Prompt Col
//    #define FORM_CMB_PICTUREGET 13            // Picture GET           PICSAY
//    #define FORM_CMB_PICTURESAY 14            // Picture SAY           PICGET
//    #define FORM_CMB_MESSAGE    15            // Message                 ""
//    #define FORM_CMB_PFK        16            // PFK Array               {}
//    #define FORM_CMB_CVAR       17            // Var Name
//    #define FORM_CMB_CONDITION  18            // Condition             {||.T.}
//    #define FORM_CMB_ACTIVE     19            // Active                {||.T.}
//    #define FORM_CMB_CLRID      20            // COLOR ARRAY
//       #define FORM_CMB_CLRPROMPT  20][1      //       PROMPT
//       #define FORM_CMB_CLRHOTKEY  20][2      //       HOT KEY
//       #define FORM_CMB_CLRDATA    20][3      //       DATA
//       #define FORM_CMB_CLRHILITE  20][4      //       DATA HILITE
//       #define FORM_CMB_CLRICON    20][5      //       ICON
//       #define FORM_CMB_CLRNULL    20][6      //       NULL
//    #define FORM_CMB_SYS        21            // Function SYS          {||NIL}
//    #define FORM_CMB_LISTBOX    22            // LISTBOX
//    #define FORM_CMB_GAP        23            // Combo GAP
//    #define FORM_CMB_ACT        24            // Exit ACTION
//    #define FORM_CMB_CTRLGRP    25            // Refresh GRP             ""
//    #define FORM_CMB_DATACHECK  26            // Data Check


/////////////////////////////////////////////////////////////////////////////////
//Mantis 688 
//Luca 27/8/2014
/////////////////////////////////////////////////////////////////////////////////
Static FUNCTION _GetRealSize(cCaption, cFont)
   LOCAL aSize, oXbp
   LOCAL bErr := ErrorBlock( {|e| break(e) } )
   LOCAL xO
   LOCAL aPP := {}

   DEFAULT cCaption TO "XX"

   IF !EMPTY(cFont)
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, cFont)
   ENDIF 


   BEGIN SEQUENCE
    aSize := {0,0}
    // creo nuovo oggetto per calcolo dimensioni

    oXbp := XbpStatic():new(NIL, NIL, {-100,-100},NIL, aPP )
    oXbp:caption := cCaption
    // tolgo caratteri ~
    oXbp:caption  := STRTRAN(oXbp:caption, STD_HOTKEYCHAR, "")
    oXbp:autoSize := .T.
    oXbp:visible  := .F.
    oXbp:create()

    aSize := oXbp:currentSize()
    oXbp  := NIL 

   RECOVER USING xO
    aSize := {0,0}
   END SEQUENCE

   ErrorBlock(bErr)

RETURN  aSize