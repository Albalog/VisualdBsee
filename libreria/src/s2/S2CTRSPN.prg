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

// S2SpinButton: CTRL_SPIN
// -----------------------
// Dato che l'XbpSpinButton funziona SOLO con valori numerici:
// - Non sono supportate le picture
// - Non sono supportati gli array

CLASS S2SpinButton FROM XbpSpinButton, S2Control, S2EditCtrl
   PROTECTED:
      VAR lCalcSizeOnDisplay
      METHOD CtrlArrInit, DispItmCalcSize

   EXPORTED:
      VAR bActive, oPrompt, cMsg, cRefGrp
      VAR nMin, nMax, nStep
      VAR nEnabledColorFG, nEnabledColorBG

      // VAR picture, bVar

      METHOD Init, DispItm, SetInputFocus, KillInputFocus, Create,setParent, setpos  //, destroy
      METHOD SetFocus, hasFocus, CanSetFocus //, enable, disable
      METHOD IsActive, getData, isShortCut, keyboard
      METHOD UpdControl, setData


      // METHOD HandleEvent

ENDCLASS

METHOD S2SpinButton:setParent(o)
   LOCAL oRet
   IF PCOUNT() > 0
      oRet := ::XbpSpinButton:setParent(o)
      IF ::oPrompt != NIL
         ::oPrompt:setParent(o)
      ENDIF
   ELSE
      oRet := ::XbpSpinButton:setParent()
   ENDIF
RETURN oRet


METHOD S2SpinButton:CtrlArrInit(aCtrl, oFormFather )
   DEFAULT aCtrl[FORM_SPN_CVAR]       TO ""
   DEFAULT aCtrl[FORM_SPN_PICTURESAY] TO ""
   DEFAULT aCtrl[FORM_SPN_GAP]        TO 0
   DEFAULT aCtrl[FORM_SPN_ACTIVE]     TO {||.T.}
   DEFAULT aCtrl[FORM_SPN_CLICKED]    TO {||.T.}
   DEFAULT aCtrl[FORM_SPN_STEP]       TO 1

   aCtrl[FORM_SPN_CTRLGRP] := dfChkGrp(aCtrl[FORM_SPN_CTRLGRP])

   DEFAULT aCtrl[FORM_SPN_CLRID]      TO {}
   ASIZE( aCtrl[FORM_SPN_CLRID], 6 )
   IF EMPTY aCtrl[FORM_SPN_CLRPROMPT] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_PROMPT   ]
   IF EMPTY aCtrl[FORM_SPN_CLRHOTKEY] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_HOTPROMPT]
   IF EMPTY aCtrl[FORM_SPN_CLRDATA  ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_GETNORMAL]
   IF EMPTY aCtrl[FORM_SPN_CLRHILITE] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_GETNORMAL]
   IF EMPTY aCtrl[FORM_SPN_CLRICON  ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_GETCOMBO ]
   IF EMPTY aCtrl[FORM_SPN_PROMPT]    ASSIGN ""

#ifndef _NOFONT_
   ASIZE(aCtrl, FORM_SPN_CTRLARRLEN)
   aCtrl[FORM_SPN_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_SPN_FONTCOMPOUNDNAME ])
   aCtrl[FORM_SPN_PFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_SPN_PFONTCOMPOUNDNAME ])
   IF EMPTY aCtrl[FORM_SPN_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseSpnFont")
   IF EMPTY aCtrl[FORM_SPN_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseCtrlFont")
   IF EMPTY aCtrl[FORM_SPN_FONTCOMPOUNDNAME ] ASSIGN APPLICATION_FONT
   IF aCtrl[FORM_SPN_FONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_SPN_FONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_SPN_FONTCOMPOUNDNAME ]))
      aCtrl[FORM_SPN_FONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_SPN_FONTCOMPOUNDNAME ])  
   ENDIF

   IF EMPTY aCtrl[FORM_SPN_PFONTCOMPOUNDNAME ] ASSIGN aCtrl[FORM_SPN_FONTCOMPOUNDNAME ]
   IF aCtrl[FORM_SPN_PFONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_SPN_PFONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_SPN_PFONTCOMPOUNDNAME ]))
      aCtrl[FORM_SPN_PFONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_SPN_PFONTCOMPOUNDNAME ])  
   ENDIF
#endif
RETURN

METHOD S2SpinButton:updControl(aCtrl)
   DEFAULT aCtrl TO ::aCtrl

   ::S2Control:updControl(aCtrl)

   ::Datalink := ::aCtrl[FORM_SPN_VAR]
   ::bActive  := ::aCtrl[FORM_SPN_ACTIVE]
   ::cMsg     := ::aCtrl[FORM_SPN_MESSAGE]
   ::cRefGrp  := ::aCtrl[FORM_SPN_CTRLGRP]
   ::nMin := ::aCtrl[FORM_SPN_MIN]
   ::nMax := ::aCtrl[FORM_SPN_MAX]
   ::nStep:= ::aCtrl[FORM_SPN_STEP]

   // Imposta i colori nei pres. param. per foreground/background/disabled
   S2ObjSetColors(self, .T., ::aCtrl[FORM_SPN_CLRDATA], APPCOLOR_SPN)

   IF ::oPrompt != NIL
      ::oPrompt:setCaption( ::ChgHotKey( ::aCtrl[FORM_SPN_PROMPT] ) )
      S2ObjSetColors(::oPrompt, ! ::oForm:hasBitmapBG(), aCtrl[FORM_SPN_CLRPROMPT], APPCOLOR_SPN)
   ENDIF

#ifndef _NOFONT_
   aCtrl[FORM_SPN_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_SPN_FONTCOMPOUNDNAME ])
   aCtrl[FORM_SPN_PFONTCOMPOUNDNAME ] := ::getDefaultFont(aCtrl[FORM_SPN_PFONTCOMPOUNDNAME ])
   ::UpdObjFont( aCtrl[FORM_SPN_FONTCOMPOUNDNAME  ] )
   IF ::oPrompt != NIL
      ::UpdObjFont( aCtrl[FORM_SPN_PFONTCOMPOUNDNAME  ], ::oPrompt )
   ENDIF
#endif

RETURN self



METHOD S2SpinButton:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos, oXbp
   LOCAL nLen
   LOCAL cColorFG := dfSet("XbaseGetDisabledColorFG")
   LOCAL cColorBG := dfSet("XbaseGetDisabledColorBG")


   ::CtrlArrInit(aCtrl, oFormFather)

   nLen := dfPictLen(aCtrl[FORM_SPN_PICTURESAY])

   // Se non ho una picture oppure Š una picture del tipo "@!"
   // non posso sapere la larghezza reale e rimando tutto al primo display
   ::lCalcSizeOnDisplay := EMPTY(nLen)

   IF S2PixelCoordinate(aCtrl)
     DEFAULT aPos TO {aCtrl[FORM_SPN_COL], aCtrl[FORM_SPN_ROW]}
     IF LEN(aCTRL) >= FORM_SPN_SIZE
        DEFAULT aSize TO aCtrl[FORM_SPN_SIZE]
     ENDIF
     IF EMPTY(aSize)
        nLen+=4
        oPos := PosCvt():new(nLen, 1)
        DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}
     ENDIF
   ELSE
     // il +4 Š la larghezza dei 2 pulsanti per il + e il -
     nLen+=4

     oPos := PosCvt():new(nLen, 1)
     DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}

     oPos := PosCvt():new(aCtrl[FORM_SPN_COL], aCtrl[FORM_SPN_ROW]+1)
     oPos:Trasla(oParent)

     DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}
   ENDIF
   DEFAULT lVisible TO .F.

#ifndef _NOFONT_
   IF ! EMPTY(aCtrl[FORM_SPN_FONTCOMPOUNDNAME])
      DEFAULT aPP TO {}
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_SPN_FONTCOMPOUNDNAME])
      //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_SPN_FONTCOMPOUNDNAME]})
   ENDIF
#endif

   // Imposta i colori nei pres. param. per foreground/background/disabled
   aPP := S2PPSetColors(aPP, .T., aCtrl[FORM_SPN_CLRDATA], APPCOLOR_SPN)

   // Inizializza l'oggetto
   // ---------------------

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

   ::XbpSpinButton:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2Control:Init(aCtrl, nPage, oFormFather)
   ::S2EditCtrl:Init( aCtrl[FORM_SPN_CVAR] )

   //SD ::tabStop := .T.
   ::fastSpin := .T.
   ::autoSize := .F.

   ::autoKeyboard := .F.
   ::Datalink := aCtrl[FORM_SPN_VAR]

   // ::clipChildren := .T.
   // ::clipSiblings := .F.
   // ::bVar     := aCtrl[FORM_SPN_VAR]
   // ::Datalink := {|x| IIF( x==NIL, TRANSFORM(EVAL(::bVar), ::picture), EVAL(::bVar, x) ) }
   // ::Datalink := {|x| IIF( x==NIL, EVAL(::bVar), EVAL(::bVar, x) ) }
   // ::picture  := aCtrl[FORM_SPN_PICTURESAY]
   ::bActive  := aCtrl[FORM_SPN_ACTIVE]
   ::cMsg     := aCtrl[FORM_SPN_MESSAGE]
   ::cRefGrp  := aCtrl[FORM_SPN_CTRLGRP]
   //::group := XBP_WITHIN_GROUP
   //::BufferLength := dfPictLen(::Picture)

   ::nMin := aCtrl[FORM_SPN_MIN]
   DEFAULT ::nMin TO 0
   ::nMax := aCtrl[FORM_SPN_MAX]
   DEFAULT ::nMax TO 99999
   ::nStep:= aCtrl[FORM_SPN_STEP]

   ::rbDown := oParent:rbDown

   //S2ObjSetColors(self, , aCtrl[FORM_SPN_CLRDATA]) //, APPCOLOR_SPN)

   //////////////////////////////////////////////////////
   //Mantis 811
   ::endSpin        := aCtrl[FORM_SPN_CLICKED]
   //::keyBoard       := aCtrl[FORM_SPN_CLICKED]
   ::killInputFocus := aCtrl[FORM_SPN_CLICKED]
   //Fine mantis 811
   //////////////////////////////////////////////////////

   // PROMPT
   IF ! EMPTY(aCtrl[FORM_SPN_PROMPT])

      IF S2PixelCoordinate(aCtrl)
         aPos := {aCtrl[FORM_SPN_PCOL], aCtrl[FORM_SPN_PROW]}
      ELSE
         oPos := PosCvt():new(aCtrl[FORM_SPN_PCOL], aCtrl[FORM_SPN_PROW]+1)
         oPos:Trasla(oParent)
         aPos := {oPos:nXWin, oPos:nYWin}
      ENDIF
      aPP := NIL
   #ifndef _NOFONT_
      IF ! EMPTY(aCtrl[FORM_SPN_PFONTCOMPOUNDNAME])
         aPP := {}
         aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_SPN_PFONTCOMPOUNDNAME])
         //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_SPN_PFONTCOMPOUNDNAME]})
      ENDIF
   #endif
      // Imposta i colori nei pres. param. per foreground/background/disabled
      aPP := S2PPSetColors(aPP, ! oFormFather:hasBitmapBG(), aCtrl[FORM_SPN_CLRPROMPT], APPCOLOR_SPNPROMPT)

      oXbp := XbpStatic():new(oParent, oOwner , aPos, NIL, aPP )
      oXbp:autoSize := .T.
      oXbp:caption := ::ChgHotKey( aCtrl[FORM_SPN_PROMPT] )
      oXbp:clipSiblings := .F.
      oXbp:options := XBPSTATIC_TEXT_VCENTER

      IF ! S2PixelCoordinate(aCtrl)
         // Simone 7/12/05 gerr 4569 in alcune maschere i prompt delle GET hanno puntini "..."   
         // correzione per abilitare nuovamente visualizzazione prompt con autosize
         // solo per DOS
         //
         // Mantis 396
         // Allineamento a destra del prompt se Š sulla stessa riga
         IF aCtrl[FORM_SPN_PROW] == aCtrl[FORM_SPN_ROW] .AND. ;
            aCtrl[FORM_SPN_PCOL] <  aCtrl[FORM_SPN_COL] .AND. ;
            ! EMPTY(dfSet("XbasePromptAlign"))
        
            oXbp:options := VAL(dfSet("XbasePromptAlign"))
         ENDIF
      ENDIF

      oXbp:rbDown := ::rbDown

      //S2ObjSetColors(oXbp, , aCtrl[FORM_SPN_CLRPROMPT], APPCOLOR_SPN)

      ::oPrompt := oXbp
   ELSE
      ::oPrompt := NIL
   ENDIF

   IF S2CTRGET_HILITEON(NIL , .T., NIL )
      //::nEnabledColorFG := dfSet("XbaseGetEnabledColorFG")
      //::nEnabledColorBG := dfSet("XbaseGetEnabledColorBG")
      oXbp := S2PresParameter():new(aPP)
      ::nEnabledColorFG := oXbp:get(XBP_PP_FGCLR)
      ::nEnabledColorBG := oXbp:get(XBP_PP_BGCLR)
      DEFAULT ::nEnabledColorFG TO ::setColorFG()
      DEFAULT ::nEnabledColorBG TO ::setColorBG()
      DEFAULT ::nEnabledColorFG TO XBPSYSCLR_WINDOWSTATICTEXT
      DEFAULT ::nEnabledColorBG TO XBPSYSCLR_ENTRYFIELD

   ENDIF 


RETURN self

METHOD S2SpinButton:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL aPsize := {},aPpos := {}
   LOCAL aSize_Prompt := {}, oPos,nGap 

   * create the SLE and disable keyboard handling
   // ::XbpSle:autoKeyboard := .F.
   ::XbpSpinButton:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   // SIMONE 18/3/2002
   // il SetnumLimits ERA commentato: il commento Š stato tolto perchŠ
   // altrimenti NON c'era il limite in up/down. Per il problema
   // sotto riportato ho copiato la CREATE nella S2SpinArray togliendo
   // il setNumLimits.
   //
   // NON faccio fare il setnumlimits perchŠ da problemi con la classe
   // S2SpinArray (premendo la freccia a destra scrive il numero nell'edit!)
   //Mantis 1619
   // ::setNumLimits(::nMin, ::nMax)
   IF VALTYPE(::nMin) == "N" .AND. VALTYPE(::nMax) == "N"
      ::setNumLimits(::nMin, ::nMax)
   ENDIF

 //   * now the datalink must have been specified
 //   IF ! ValType( ::DataLink ) == "B"
 //      ::Status := XBP_STAT_FAILURE
 //      RETURN self
 //   ENDIF
 //
 //   * now initialize the get object
 //   ::Get := InvisibleGet():New(,, ::DataLink, "", ::Picture )
 //   ::BufferLength := dfPictLen(::Picture)
 //
 //   IF ::Get:Type == "N"
 //      ::Align := XBPSLE_RIGHT                  // not supported on WIN32
 //   ENDIF

   IF ::oPrompt != NIL
      ::oPrompt:Create()
       //Mantis 396
       IF S2PixelCoordinate(::aCtrl) .AND. LEN(::aCtrl[FORM_SPN_PROMPT])>0
          aPsize := ::oPrompt:CurrentSize()
          aPpos  := ::oPrompt:CurrentPos()

          oPos   := PosCvt():new(LEN(::aCtrl[FORM_SPN_PROMPT]), 1)
          aSize_Prompt := {oPos:nXWin ,aPsize[2]}
          DO CASE             
             CASE ::aCtrl[FORM_SPN_PROW] == ::aCtrl[FORM_SPN_ROW] .AND. ;
                  ::aCtrl[FORM_SPN_PCOL] <  ::aCtrl[FORM_SPN_COL] 
                  //Mantis 880 Il prompt tende a spostarsi verso destra.
                  //aPpos[1] :=  aPpos[1] - (aPsize[1]-aSize_Prompt[1])
                  nGap  := ::aCtrl[FORM_SPN_COL] - (::aCtrl[FORM_SPN_PCOL]+8*Len(StrTran(Trim(::aCtrl[FORM_SPN_PROMPT]),"^","")))
                  aPpos[1] :=  ::aCtrl[FORM_SPN_COL] - aPsize[1] - nGap
                  aPpos[2] :=  ::XbpSpinButton:CurrentPos()[2]+::XbpSpinButton:CurrentSize()[2]-aPSize[2]
                  //allinemento centrato ripetto alla Get
                  //aPpos[2] :=  ::oStatic:CurrentPos()[2]+::oStatic:CurrentSize()[2]/2-aPSize[2]/2
             CASE ::aCtrl[FORM_SPN_PROW] == ::aCtrl[FORM_SPN_ROW] .AND. ;
                  ::aCtrl[FORM_SPN_PCOL] >  ::aCtrl[FORM_SPN_COL] 
                  aPpos[1] :=  (aPsize[1]-aSize_Prompt[1]) +::aCtrl[FORM_SPN_PCOL] 
                  aPpos[2] :=  ::XbpSpinButton:CurrentPos()[2]+::XbpSpinButton:CurrentSize()[2]-aPSize[2]
                  //allinemento centrato ripetto alla Get
                  //aPpos[2] :=  ::oStatic:CurrentPos()[2]+::oStatic:CurrentSize()[2]/2-aPSize[2]/2
             CASE ::aCtrl[FORM_SPN_PROW] >  ::aCtrl[FORM_SPN_ROW] .AND. ;
                  ::aCtrl[FORM_SPN_PCOL] >= ::aCtrl[FORM_SPN_COL] 
                  aPpos[1] :=  ::aCtrl[FORM_SPN_PCOL] 
                  aPpos[2] :=  ::XbpSpinButton:CurrentPos()[2]+::XbpSpinButton:CurrentSize()[2] +1
                  //allinemento centrato ripetto alla Get
                  //aPpos[2] :=  ::oStatic:CurrentPos()[2]+::oStatic:CurrentSize()[2]/2-aPSize[2]/2
             CASE ::aCtrl[FORM_SPN_PROW] <  ::aCtrl[FORM_SPN_ROW] .AND. ;
                  ::aCtrl[FORM_SPN_PCOL] >= ::aCtrl[FORM_SPN_COL] 
                  aPpos[1] :=  ::aCtrl[FORM_SPN_PCOL] 
                  aPpos[2] :=  ::XbpSpinButton:CurrentPos()[2] -aPSize[2] -1
                  //allinemento centrato ripetto alla Get
                  //aPpos[2] :=  ::oStatic:CurrentPos()[2]+::oStatic:CurrentSize()[2]/2-aPSize[2]/2
          ENDCASE
          ::oPrompt:SetPos(aPpos)
          ::oPrompt:Configure()
       ENDIF


   ENDIF

RETURN self

// METHOD S2SpinButton:destroy()
//    ::XbpSpinButton:destroy()
//    IF ::oPrompt != NIL
//       ::oPrompt:destroy()
//    ENDIF
// RETURN self

METHOD S2SpinButton:setData(nVal)
   LOCAL xRet := .F.

   DEFAULT nVal TO EVAL(::dataLink)
   IF ! VALTYPE(nVal) == "N"
      nVal := 0
   ENDIF
   xRet := ::XbpSpinButton:setData(nVal)
RETURN xRet


METHOD S2SpinButton:setPos(aPos, lPaint)
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
   lRet := ::XbpSpinButton:setPos(aPos, lPaint)
RETURN lRet


METHOD S2SpinButton:getData()
   LOCAL cRet := ::XbpSpinButton:getData()
   IF ::aPage0 != NIL
      // Se Š pagina 0 aggiorno il buffer dei "fratelli"
      AEVAL(::aPage0, {|x|x:setData()})
   ENDIF
RETURN cRet

METHOD S2SpinButton:isShortCut(cAct)
   LOCAL lRet := .F. , nPos

   IF ! EMPTY(::oPrompt) .AND. ;
      VALTYPE( ::oPrompt:caption ) == "C" .AND. ;
      ( nPos := AT( STD_HOTKEYCHAR, ::oPrompt:caption) ) != 0

      // nRet := dbAct2Ksc("A_"+LOWER( SUBSTR( ::oPrompt:caption, nPos + 1, 1)))
      lRet := cAct == "A_"+LOWER( SUBSTR( ::oPrompt:caption, nPos + 1, 1))

   ENDIF
RETURN lRet

METHOD S2SpinButton:IsActive()
RETURN EVAL(::bActive)

METHOD S2SpinButton:KeyBoard( nKey )
   IF ACT $ "tab,ret"
      ::oForm:skipFocus(1)

   ELSEIF ACT $ "Stb"
      ::oForm:skipFocus(-1)
   ELSE
      ::XbpSpinButton:keyboard(nKey)
   ENDIF
   // IF dbKsc2Act(nKey) == "ret"
   //    PostAppEvent(xbeP_Activate, NIL, NIL, self)
   // ENDIF
RETURN self

METHOD S2SpinButton:DispItm() // ( cGrp, lRef )
   LOCAL lRet := .F.

   IF ::lCalcSizeOnDisplay

      ::DispItmCalcSize()

      // Evito il ricalcolo una seconda volta
      ::lCalcSizeOnDisplay := .F.
   ENDIF

   IF ::CanShow()
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
   IF ::IsActive()
      ::enable()
   ELSE
      ::disable()
   ENDIF

   ::SetData()
RETURN self

METHOD S2SpinButton:DispItmCalcSize()
   LOCAL nLen
   LOCAL oPos
   LOCAL aSize

   // 21:06:05 venerd 02 giugno 2000 # MATTEO
   // Ho commentato la cosa, fato che non Š supportata la picture
   //
   //nLen := dfPictLen(::picture)

   IF EMPTY(nLen)
      nLen := LEN(dfAny2Str(EVAL( ::dataLink )))
   ENDIF


   IF S2PixelCoordinate(::aCtrl)
     IF LEN(::aCTRL) >= FORM_SPN_SIZE
        aSize := {::aCtrl[FORM_SPN_SIZE_WIDTH],::aCtrl[FORM_SPN_SIZE_HEIGHT]}
     ENDIF
     IF EMPTY(aSize)
        nLen+=4
        oPos := PosCvt():new(nLen, 1)
        aSize := {oPos:nXWin, oPos:nYWin}
     ENDIF
   ELSE
      // il +4 Š la larghezza dei 2 pulsanti per il + e il -
      nLen+=4

      oPos := PosCvt():new(nLen, 1)
      aSize := {oPos:nXWin, oPos:nYWin}
   ENDIF
   ::setSize(aSize)

RETURN self

// METHOD S2SpinButton:enable()
//    LOCAL lRet := ::XbpSpinButton:enable()
//    // IF ::oPrompt != NIL   // Il prompt deve essere sempre abilitato
//    //    ::oPrompt:enable()
//    // ENDIF
// RETURN lRet
//
// METHOD S2SpinButton:disable()
//    LOCAL lRet := ::XbpSpinButton:disable()
//    // IF ::oPrompt != NIL   // Il prompt deve essere sempre abilitato
//    //    ::oPrompt:disable()
//    // ENDIF
// RETURN lRet


// Quando acquista il focus riposiziona al primo carattere
METHOD S2SpinButton:SetInputFocus()
   //LOCAL aMarked
   //LOCAL oForm
   // Simone gerr 3653 25/3/03
   IF ::isOnCurrentForm()
      IF ::CanSetPage()
         ::oForm:SetMsg(::cMsg)
      ELSE
         ::oForm:skipFocus(1)
      ENDIF
   ENDIF

   //#ifdef _S2CTRGET_HILITE_
   IF S2CTRGET_HILITEON(NIL , .T., NIL )
      // cambia i colori quando riceve input focus,
      // funziona perfettamente ma Š disabilitato perchŠ
      // dovrebbe essere fatto anche per i combo/spin/ecc.
      IF ::isEnabled()
         // imposto i colori per input focus
         S2ObjSetColors(self, .T., ::aCtrl[FORM_SPN_CLRHILITE], APPCOLOR_GETFOCUS)
      ENDIF                                
   ENDIF
   //#endif

//   ::oForm:SetMsg(::cMsg)

   // ::Get:Home()
   // ::SetFirstChar( 1 )
   //
   // IF Set( _SET_INSERT )
   //    aMarked := { ::Get:Pos, ::Get:Pos }
   // ELSE
   //    aMarked := { ::Get:Pos, ::Get:Pos + 1 }
   // ENDIF
   //
   // ::SetMarked( aMarked )

RETURN self


METHOD S2SpinButton:KillInputFocus()
   ////////////////////////////////////////////////////
   //Luca 23/11/2011 XLS  2739,1932
   //IF ::isOnCurrentForm() .AND. ::CanSetPage()
   IF (::isOnCurrentForm() .AND. ::CanSetPage()) .OR.;
       (S2FormCurr()  == dfSetMainWin() .AND. S2UseMainToolbar())
   ////////////////////////////////////////////////////
      ::getData()

      ::oForm:tbDisRef(::cId)
      IF ! EMPTY(::cRefGrp)
         ::oForm:tbDisRef(::cRefGrp)
      ENDIF

      IF S2CTRGET_HILITEON(NIL , .T., NIL )
          // cambia i colori quando riceve input focus,
         // funziona perfettamente ma è disabilitato perchè
         // dovrebbe essere fatto anche per i combo/spin/ecc.
         IF ::isEnabled()
            IF ::nEnabledColorFG != NIL
               ::setColorFG(::nEnabledColorFG)
            ENDIF
            IF ::nEnabledColorBG != NIL
               ::setColorBG(::nEnabledColorBG)
            ENDIF
         ENDIF
      ENDIF

   ENDIF
RETURN self

METHOD S2SpinButton:CanSetFocus()
//SD RETURN ::TabStop .AND. ::IsActive() .AND. ::CanShow() // .AND. ::PreGet() //::isEnabled() .AND. ::isVisible()
RETURN ::CanSetPage() .AND. ::IsActive() .AND. ::CanShow() // .AND. ::PreGet() //::isEnabled() .AND. ::isVisible()

METHOD S2SpinButton:SetFocus()
   ::setHelpID(::cID)
   ::enable()
RETURN SetAppFocus(self)

METHOD S2SpinButton:hasFocus()
RETURN SetAppFocus() == self


// SPIN
//
// ATTACH "spb0024" TO oWin:W_CONTROL GET AS SPINBUTTON ScnBol  ; // ATTSPB.TMP
//                  AT  19, 40                                  ; // Coordinate
//                  COLOR      {"W+/G*","N/G*","N/W*","W+/BG","N/W*"}  ; // Array dei colori
//                  PROMPT   "^Sconto %"                        ; // Prompt
//                  PROMPTAT  19 , 31                           ; // Coordinate prompt
//                  PICTURESAY "99"                             ; // Picture in say
//                  DISPLAYIF  {||.T.}                          ; // Visualizza se...
//                  MIN        5                                ; // Valore minimo
//                  MAX        60                               ; // Valore massimo
//                  STEP       5                                ; // Step
//                  REFRESHGRP "totale"                         ; // Comanda refresh del gruppo
//                  ACTIVE   {||cState $ "am" }                 ; // Stato di attivazione
//                  VARNAME "ScnBol"                            ; //
//                  MESSAGE ""                                    // Messaggio utente
//
// ATTACH "spb0026" TO oWin:W_CONTROL GET AS SPINBUTTON StdBol  ; // ATTSPB.TMP
//                  AT   5, 13                                  ; // Coordinate
//                  COLOR      {"N/G","G+/G","G+/GR*","N/W*","G+/GR*"}  ; // Array dei colori
//                  PROMPT   "Stato bolla"                      ; // Prompt
//                  PROMPTAT   5 ,  1                           ; // Coordinate prompt
//                  PICTURESAY "xxxxxxxxxxxxxxxxxxxx"           ; // Picture in say
//                  DISPLAYIF  {||.T.}                          ; // Visualizza se...
//                  ARRAY      {"Non evasa","Parzialmente evasa","Completamente evasa"}  ; // Array
//                  ACTIVE   {||cState $ "am" }                 ; // Stato di attivazione
//                  VARNAME "StdBol"                            ; //
//                  MESSAGE ""                                    // Messaggio utente
//
//    #COMMAND ATTACH <cId> TO <aParent> GET AS SPINBUTTON <uVar> ;
//                                       AT  <nRow>, <nCol> ;
//                                       [PAGE    <nPage>]  ;
//                                       [GAP         <nGap>];
//                                       [PICTURESAY <cPicSay>] ;
//                                       [DISPLAYIF <uDiIf>] ;
//                                       [ARRAY   <aSource>] ;
//                                       [MIN        <nMin>] ;
//                                       [MAX        <nMax>] ;
//                                       [STEP      <nStep>] ;
//                                       [REFRESHGRP  <uGrp>];
//                                       [MESSAGE <cMes>]    ;
//                                       [COLOR   <aCol>]    ;
//                                       [PROMPT  <cPrompt>] ;
//                                       [PROMPTAT <nPRow>, <nPCol>] ;
//                                       [REFRESHID <cRID>]  ;
//                                       [ACTIVE <uActive>]  ;
//                                       [VARNAME <cVarName>];
//                                       [WHENCLICKED <bClick>];
//                                                             ;
//      => aAdd( <aParent>, { CTRL_SPIN ,;
//                                <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
//                          {|uVal|IF(uVal==NIL, <uVar>, <uVar>:=uVal)},;
//                          <nRow>, <nCol>, ;
//                          <cPrompt>, <nPRow>, <nPCol>,;
//                          <cPicSay>, <cMes>, <cVarName>,;
//                          <{uActive}>,;
//                          <aCol>, <nGap>,;
//                          <uGrp>, <aSource>, <nMin>, <nMax>, <nStep>,;
//                          <{bClick}> })
//
//                                               //                     DEFAULT
//    #define FORM_SPN_VAR         7             // Var
//    #define FORM_SPN_ROW         8             // Row
//    #define FORM_SPN_COL         9             // Col
//    #define FORM_SPN_PROMPT     10             // Prompt                ""
//    #define FORM_SPN_PROW       11             // Prompt Row
//    #define FORM_SPN_PCOL       12             // Prompt Col
//    #define FORM_SPN_PICTURESAY 13             // Picture Say           ""
//    #define FORM_SPN_MESSAGE    14             // Message
//    #define FORM_SPN_CVAR       15             // Var Name
//    #define FORM_SPN_ACTIVE     16             // Active
//    #define FORM_SPN_CLRID      17             // COLOR ARRAY
//       #define FORM_SPN_CLRPROMPT  17][1       //       PROMPT
//       #define FORM_SPN_CLRHOTKEY  17][2       //       HOTKEY
//       #define FORM_SPN_CLRDATA    17][3       //       DATA
//       #define FORM_SPN_CLRHILITE  17][4       //       DATA HILITE
//       #define FORM_SPN_CLRICON    17][5       //       ICON
//       #define FORM_SPN_CLRNULL    17][6       //       NULL
//    #define FORM_SPN_GAP        18             // Gap                    0
//    #define FORM_SPN_CTRLGRP    19             // Refresh GRP            ""
//    #define FORM_SPN_ARRAY      20             // Array
//    #define FORM_SPN_MIN        21             // Min
//    #define FORM_SPN_MAX        22             // Max
//    #define FORM_SPN_STEP       23             // Step
//    #define FORM_SPN_CLICKED    24             // When Clicked        {||.T.}

// S2SpinArray: CTRL_SPIN su array
// -------------------------------

CLASS S2SpinArray FROM S2SpinButton

   EXPORTED:

      VAR DataLinkArr, aSource, nIdx //, picture

      METHOD Init, create, dispItm
      METHOD getData, setData, up, down
ENDCLASS


METHOD S2SpinArray:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::CtrlArrInit(aCtrl, oFormFather )

   DEFAULT lVisible TO .F.

   ::aSource := aCtrl[FORM_SPN_ARRAY]

   aCtrl[FORM_SPN_MIN ] := 1
   aCtrl[FORM_SPN_MAX ] := LEN(::aSource)
   aCtrl[FORM_SPN_STEP] := 1

   ::S2SpinButton:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::nIdx := 0

   // ::DataLink := {|x| IIF( x==NIL, ::nIdx, ::nIdx := x) }
   ::DataLink := aCtrl[FORM_SPN_VAR]

   // ::picture  := aCtrl[FORM_SPN_PICTURESAY]

RETURN self

// METHOD S2SpinArray:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
//    ::S2SpinButton:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
//
//    ::autoKeyboard := .F.
//    ::XbpSLE:configure()
//
// RETURN self

METHOD S2SpinArray:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   * create the SLE and disable keyboard handling
   ::XbpSpinButton:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   // NON faccio fare il setnumlimits perchŠ da problemi con la classe
   // S2SpinArray (premendo la freccia a destra scrive il numero nell'edit!)
   //::setNumLimits(::nMin, ::nMax)

 //   * now the datalink must have been specified
 //   IF ! ValType( ::DataLink ) == "B"
 //      ::Status := XBP_STAT_FAILURE
 //      RETURN self
 //   ENDIF
 //
 //   * now initialize the get object
 //   ::Get := InvisibleGet():New(,, ::DataLink, "", ::Picture )
 //   ::BufferLength := dfPictLen(::Picture)
 //
 //   IF ::Get:Type == "N"
 //      ::Align := XBPSLE_RIGHT                  // not supported on WIN32
 //   ENDIF

   IF ::oPrompt != NIL
      ::oPrompt:Create()
   ENDIF

RETURN self


METHOD S2SpinArray:setData(xBuffer)
   LOCAL xVal

   DEFAULT xBuffer TO EVAL( ::dataLink )

   IF xBuffer == NIL
      xVal := ::XbpSLE:setData()
   ELSE
      xVal := ::XbpSLE:setData(xBuffer)
   ENDIF

   // IF xBuffer == NIL
   //    xVal := ::XbpSLE:setData()
   // ELSE
   //    xVal := ::XbpSLE:setData(xBuffer)
   // ENDIF
RETURN xVal

METHOD S2SpinArray:dispItm()
   ::nIdx := 0
   ::S2SpinButton:dispItm()
RETURN self

METHOD S2SpinArray:getData()
RETURN ::XbpSLE:getData()

METHOD S2SpinArray:down()
   IF ::nIdx > 1
      ::nIdx--
   ELSE
      ::nIdx := ::nMax
   ENDIF
   ::setData( ::aSource[ ::nIdx ] )
RETURN self


METHOD S2SpinArray:up()

   IF ::nIdx < ::nMax
      ::nIdx++
   ELSE
      ::nIdx := ::nMin
   ENDIF

   ::setData( ::aSource[ ::nIdx ] )
RETURN self

// METHOD S2SpinArray:keyboard(nKey)
//    // LOCAL x := 1
//    // x++ ,
// RETURN self

// METHOD S2SpinArray:endSpin()
//    LOCAL x := 1
//    x++ .
// RETURN self

