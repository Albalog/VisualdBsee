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

// S2RadioBtn: CTRL_RADIO
// ----------------------

// Simone 19/9/2003 per GERR 3895
// tolto eredita da classe autoresize perche
// crea problemi di visualizzazione in alcuni casi sporadici
// (Es. in SAT form qscad05.prg la scritta 
// "Matr. con contratti attivi e" a volte si cancella da se.


//CLASS S2RadioGrp FROM S2Static, AutoResize
CLASS S2RadioGrp FROM S2Static
   PROTECTED:
      METHOD CtrlArrInit
//      INLINE METHOD ResizeArea(); RETURN self

   EXPORTED:
      VAR Nome, nTop, nLeft, nBottom, nRight, aChild //, aValori
      METHOD Init, Create, AddChild, AddCoords //, ValFromPos, PosFromVal, AddValue
      METHOD DispItm

      METHOD SetCaption
ENDCLASS

METHOD S2RadioGrp:CtrlArrInit(aCtrl, oFormFather )
   DEFAULT aCtrl[FORM_RAD_CVAR]       TO ""
   DEFAULT aCtrl[FORM_RAD_PROMPT]     TO ""
   DEFAULT aCtrl[FORM_RAD_GAP]        TO 0
   DEFAULT aCtrl[FORM_RAD_ACTIVE]     TO {||.T.}
   DEFAULT aCtrl[FORM_RAD_CLICKED]    TO {||.T.}

   aCtrl[FORM_RAD_CTRLGRP] := dfChkGrp(aCtrl[FORM_RAD_CTRLGRP])

   DEFAULT aCtrl[FORM_RAD_CLRID]      TO {}
   ASIZE( aCtrl[FORM_RAD_CLRID], 5 )
   IF EMPTY aCtrl[FORM_RAD_CLRPROMPT      ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_PROMPT   ]
   IF EMPTY aCtrl[FORM_RAD_CLRHOTKEY      ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_HOTPROMPT]
   IF EMPTY aCtrl[FORM_RAD_CLRHILITEPROMPT] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_RADCHK   ]
   IF EMPTY aCtrl[FORM_RAD_CLRICON        ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_GETCOMBO ]

RETURN


METHOD S2RadioGrp:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL cFont   := dfSet("XbaseRadFont")
   LOCAL oXbp
   DEFAULT cFont TO dfSet("XbaseCtrlFont")
   DEFAULT aPP TO {}
   ::CtrlArrInit(aCtrl, oFormFather )

   // Inizializza l'oggetto
   // ---------------------

   lVisible := .T.

#ifndef _NOFONT_
   IF ! EMPTY(cFont)
      DEFAULT aPP TO {}
      cFont := dfFontCompoundNameNormalize(cFont)
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, cFont)
      // AADD(aPP, {XBP_PP_COMPOUNDNAME, cFont})
   ENDIF
#endif
   //////////////////////////////////////////////////////////////////
   //Mantis 984
   IF oFormFather:hasBitmapBG()
      AADD(aPP,{XBP_PP_DISABLED_BGCLR,XBPSYSCLR_TRANSPARENT})
   ENDIF
   //////////////////////////////////////////////////////////////////

   ::S2Static:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )

   //::type := XBPSTATIC_TYPE_GROUPBOX
   ::type := XBPSTATIC_TYPE_TEXT
   // ::setColorFG(GRA_CLR_PALEGRAY)
   // ::setColorBG(GRA_CLR_PALEGRAY)

   ::tabStop := .F.
   ::Nome    := ""
   ::aChild  := {}
   // ::tabStop := .T.
   // ::setInputFocus := {|| SetAppFocus(::aChild[1]) }
   // ::group := XBP_WITHIN_GROUP


RETURN self

METHOD S2RadioGrp:DispItm()
   // ::show()
   // AEVAL(::aChild, {|oXbp| oXbp:DispItm()  })
RETURN self

////////////////////////////////////////////////////
//Luca 2/1/2007
//Inserito metodo perche il primo elemento radiobutton e e di classe Groupbox e non permette di cambiare il prompt in modo dinamico.
METHOD S2RadioGrp:SetCaption(cStr)
    IF !EMPTY(::aChild) .AND. LEN(::aChild)>0
       ::aChild[1]:SetCaption(cStr)
    ENDIF
RETURN self
////////////////////////////////////////////////////


METHOD S2RadioGrp:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos 
   LOCAL nMaxWidth := 0
   LOCAL nMaxHight := 0
//   LOCAL aResizeList := {"B"}


   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF S2PixelCoordinate(::aCtrl)
      aPos  := {::nLeft ,::nBottom}
      aSize := {0,::nTop - ::nBottom }
   ELSE
      oPos := PosCvt():new(::nLeft, ::nBottom+1)
      oPos:Trasla(::SetParent())

      aPos := {oPos:nXWin, oPos:nYWin}

      oPos:SetDos(::nRight  - ::nLeft+ 1, ; // +1, ;
                  ::nBottom - ::nTop + 1 ) // -1  )

      aSize := {0      , oPos:nYWin}
   ENDIF

   // Crea l'oggetto
   // --------------

   ::S2Static:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )

   AEVAL(::aChild, {|oXbp| oXbp:create() })
//   AEVAL(::aChild, {|oXbp| oXbp:create(), AADD(aResizeList, oXbp)  })

   // nY := ::CurrentSize()[2]
   // Calcolo la massima larghezza degli oggetti contenuti
   nMaxHight := 0
   AEVAL(::aChild, {|oXbp| oXbp:UpdCoords( self ), ;
                           nMaxWidth := MAX(nMaxWidth, oXbp:currentPos()[1]+oXbp:currentSize()[1]),;
                           nMaxHight := MAX(nMaxHight, oXbp:currentPos()[2]+oXbp:currentSize()[2])})

   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF S2PixelCoordinate(::aCtrl)
      aSize[1] := nMaxWidth
      aSize[2] := nMaxHight 
   ELSE
      aSize[1] := nMaxWidth
   ENDIF
   ::SetSize(aSize)

//   ::resizeInit(aResizeList)
RETURN self

METHOD S2RadioGrp:AddChild(oRad)
   AADD(::aChild, oRad)
RETURN self

METHOD S2RadioGrp:AddCoords(nRow, nCol)
   // Modificato per adattamento a coordinate Pixel
   IF S2PixelCoordinate(::aCtrl)
      ::nTop    := IIF(::nTop    == NIL, nRow, MAX(::nTop    , nRow))
      ::nLeft   := IIF(::nLeft   == NIL, nCol, MIN(::nLeft   , nCol))
      ::nBottom := IIF(::nBottom == NIL, nRow, MIN(::nBottom , nRow))
      ::nRight  := IIF(::nRight  == NIL, nCol, MAX(::nRight  , nCol))
   ELSE
      ::nTop    := IIF(::nTop    == NIL, nRow, MIN(::nTop    , nRow))
      ::nLeft   := IIF(::nLeft   == NIL, nCol, MIN(::nLeft   , nCol))
      ::nBottom := IIF(::nBottom == NIL, nRow, MAX(::nBottom , nRow))
      ::nRight  := IIF(::nRight  == NIL, nCol, MAX(::nRight  , nCol))
   ENDIF
RETURN self

// METHOD S2RadioGrp:AddValue( xVal )
// RETURN AADD(::aValori, xVal)
//
// METHOD S2RadioGrp:PosFromVal( xVal )
// RETURN ASCAN(::aValori, {|x| EVAL(x) == xVal })
//
// METHOD S2RadioGrp:ValFromPos( xVal )
// RETURN ::aValori[xVal]

CLASS S2RadioBtn FROM XbpRadioButton, S2Control, S2EditCtrl
   PROTECTED:
      METHOD CtrlArrInit

   EXPORTED:
      VAR bActive, cMsg, cRefGrp, bVar, bClick, xValue, nRow, nCol
      VAR nenabledColorFG, nenabledColorBG
      METHOD Init, Create, DispItm, SetInputFocus, KillInputFocus
      METHOD SetFocus, hasFocus, CanSetFocus, selected
      METHOD IsActive, UpdCoords, getData, isShortCut, keyboard

      METHOD UpdControl
      METHOD enable, disable, refreshBMP
      // METHOD HandleEvent

ENDCLASS

METHOD S2RadioBtn:CtrlArrInit(aCtrl, oFormFather )
   DEFAULT aCtrl[FORM_RAD_CVAR]       TO ""
   DEFAULT aCtrl[FORM_RAD_PROMPT]     TO ""
   DEFAULT aCtrl[FORM_RAD_GAP]        TO 0
   DEFAULT aCtrl[FORM_RAD_ACTIVE]     TO {||.T.}
   DEFAULT aCtrl[FORM_RAD_CLICKED]    TO {||.T.}

   aCtrl[FORM_RAD_CTRLGRP] := dfChkGrp(aCtrl[FORM_RAD_CTRLGRP])

   DEFAULT aCtrl[FORM_RAD_CLRID]      TO {}
   ASIZE( aCtrl[FORM_RAD_CLRID], 5 )
   IF EMPTY aCtrl[FORM_RAD_CLRPROMPT      ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_PROMPT   ]
   IF EMPTY aCtrl[FORM_RAD_CLRHOTKEY      ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_HOTPROMPT]
   IF EMPTY aCtrl[FORM_RAD_CLRHILITEPROMPT] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_RADCHK   ]
   IF EMPTY aCtrl[FORM_RAD_CLRICON        ] ASSIGN oFormFather:W_COLORARRAY[AC_FRM_GETCOMBO ]

#ifndef _NOFONT_
   ASIZE(aCtrl, FORM_RAD_CTRLARRLEN)
   aCtrl[FORM_RAD_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_RAD_FONTCOMPOUNDNAME ])
   IF EMPTY aCtrl[FORM_RAD_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseRadFont")
   IF EMPTY aCtrl[FORM_RAD_FONTCOMPOUNDNAME ] ASSIGN dfSet("XbaseCtrlFont")
   IF aCtrl[FORM_RAD_FONTCOMPOUNDNAME ] != NIL
      // Simone 21/12/04
      // mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
      //aCtrl[FORM_RAD_FONTCOMPOUNDNAME ] := UPPER(ALLTRIM(aCtrl[FORM_RAD_FONTCOMPOUNDNAME ]))
      aCtrl[FORM_RAD_FONTCOMPOUNDNAME ] := dfFontCompoundNameNormalize(aCtrl[FORM_RAD_FONTCOMPOUNDNAME ])  
   ENDIF
#endif
   IF EMPTY aCtrl[FORM_RAD_PAINTSTYLE       ] ASSIGN dfSet(AI_XBASERADSTYLE)

RETURN

METHOD S2RadioBtn:updControl(aCtrl)
   DEFAULT aCtrl TO ::aCtrl

   //::S2Static:updControl(aCtrl)
   ::S2Control:updControl(aCtrl)

   ::setCaption( ::ChgHotKey( ::aCtrl[FORM_RAD_PROMPT] ) )
   ::bVar     := ::aCtrl[FORM_RAD_VAR]
   ::xValue   := ::aCtrl[FORM_RAD_VALUE]
   ::bActive  := ::aCtrl[FORM_RAD_ACTIVE]
   ::cMsg     := ::aCtrl[FORM_RAD_MESSAGE]
   ::cRefGrp  := ::aCtrl[FORM_RAD_CTRLGRP]
   ::bClick   := ::aCtrl[FORM_RAD_CLICKED]
#ifndef _NOFONT_
   aCtrl[FORM_RAD_FONTCOMPOUNDNAME  ] := ::getDefaultFont(aCtrl[FORM_RAD_FONTCOMPOUNDNAME ])
   ::UpdObjFont( aCtrl[FORM_RAD_FONTCOMPOUNDNAME  ] )
#endif

   // imposta i colori foreground/background
   S2ObjSetColors(self, ! ::oForm:hasBitmapBG(), aCtrl[FORM_RAD_CLRPROMPT], APPCOLOR_RAD)
RETURN self


METHOD S2RadioBtn:Init(aCtrl, nPage, oFormFather, oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oPos, oXbp

   ::CtrlArrInit(aCtrl, oFormFather )

   //29/09/04 simone: Inserito per gestione pixel o Row/Column per mantis 113
   IF S2PixelCoordinate(aCtrl)
      IF LEN(aCtrl) >= FORM_RAD_SIZE
         DEFAULT aSize TO aCtrl[FORM_RAD_SIZE]
      ENDIF
   ENDIF
   DEFAULT lVisible TO .F.


#ifndef _NOFONT_
   IF ! EMPTY(aCtrl[FORM_RAD_FONTCOMPOUNDNAME])
      DEFAULT aPP TO {}
      aPP := S2PresParameterSet(aPP, XBP_PP_COMPOUNDNAME, aCtrl[FORM_RAD_FONTCOMPOUNDNAME])
      //AADD(aPP, {XBP_PP_COMPOUNDNAME, aCtrl[FORM_RAD_FONTCOMPOUNDNAME]})
   ENDIF
#endif

   // Imposta il colore trasparente per il control disabilitato
   //aPP := S2PPSetDisabledBGClr(aPP)
   aPP := S2PPSetColors(aPP, ! oFormFather:hasBitmapBG(), aCtrl[FORM_RAD_CLRPROMPT], APPCOLOR_RAD)

   // Inizializza l'oggetto
   // ---------------------

   ::XbpRadioButton:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2Control:Init(aCtrl, nPage, oFormFather)
   ::S2EditCtrl:Init( aCtrl[FORM_RAD_CVAR] )

   // simone 24/9/04 mantis 113
   IF S2PixelCoordinate(aCtrl)
      ::autoSize := EMPTY(aSize)
   ELSE
      ::autoSize := .T.
   ENDIF
   ::clipSiblings := .F.

   ::nRow     := aCtrl[FORM_RAD_ROW]
   ::nCol     := aCtrl[FORM_RAD_COL]

   ::caption  := ::ChgHotKey( aCtrl[FORM_RAD_PROMPT] )
   ::bVar     := aCtrl[FORM_RAD_VAR]
   ::xValue   := aCtrl[FORM_RAD_VALUE]

   ::Datalink := {|xVal| IIF(xVal==NIL, ;
                             EVAL(::bVar) == EVAL(::xValue), ;
                             IIF(xVal, EVAL(::bVar, EVAL(::xValue)), NIL) )}

   ::bActive  := aCtrl[FORM_RAD_ACTIVE]
   ::cMsg     := aCtrl[FORM_RAD_MESSAGE]
   ::cRefGrp  := aCtrl[FORM_RAD_CTRLGRP]
   ::bClick   := aCtrl[FORM_RAD_CLICKED]

   ::rbDown := oParent:rbDown

   //S2ObjSetColors(self, ! oFormFather:hasBitmapBG(), aCtrl[FORM_RAD_CLRPROMPT], APPCOLOR_RAD)
   IF VALTYPE(oParent)=="O" .AND. ;
      oParent:isDerivedFrom("S2RadioGrp")

      oParent:AddCoords(::nRow, ::nCol)
      oParent:AddChild(self)
   ENDIF

   IF S2CTRGET_HILITEON(NIL , NIL , .T.)
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

METHOD S2RadioBtn:selected(lCheck)
IF lCheck    // WorkAround
   ::getData()
   ::XbpRadioButton:selected(lCheck)
   EVAL(::bClick)
   ::oForm:tbDisItm("#")
ENDIF
RETURN self

METHOD S2RadioBtn:KeyBoard( nKey )
   IF ACT $ "dar,tab,ret,rar"
      ::oForm:skipFocus(1)

   ELSEIF ACT $ "uar,Stb,lar"
      ::oForm:skipFocus(-1)
   ELSE
      ::XbpRadioButton:keyboard(nKey)
   ENDIF
RETURN self

METHOD S2RadioBtn:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   IF ::Status() == XBP_STAT_INIT
      ::XbpRadioButton:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

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
      IF ::aCtrl[FORM_RAD_PAINTSTYLE] == RAD_PS_FLAT
         #define BS_FLAT      0x00008000
         dfXbpSetStyle(self, BS_FLAT, .T.)
      ENDIF

   ENDIF
RETURN self

METHOD S2RadioBtn:UpdCoords( oParent )
   LOCAL oPos
   // Modificato per adattamento a coordinate Pixel
   IF S2PixelCoordinate(::aCtrl)
      ::SetPos({::nCol - oParent:nLeft ,::nRow - oParent:nBottom }, .F. )
   ELSE
      oPos := PosCvt():new(::nCol - oParent:nLeft, oParent:nBottom - ::nRow )
      ::SetPos({oPos:nXWin, oPos:nYWin}, .F. )
   ENDIF
RETURN self

METHOD S2RadioBtn:isShortCut(cAct)
   LOCAL lRet := .F. , nPos

   IF VALTYPE( ::caption ) == "C" .AND. ;
      ( nPos := AT( STD_HOTKEYCHAR, ::caption) ) != 0

      lRet := cAct == "A_"+LOWER( SUBSTR( ::caption, nPos + 1, 1))

   ENDIF
RETURN lRet

METHOD S2RadioBtn:IsActive()
RETURN EVAL(::bActive)

METHOD S2RadioBtn:getData()
   LOCAL cRet := ::XbpRadioButton:getData()
   IF ::aPage0 != NIL
      // Se Š pagina 0 aggiorno il buffer dei "fratelli"
      AEVAL(::aPage0, {|x|x:setData()})
   ENDIF
RETURN cRet

METHOD S2RadioBtn:DispItm() // ( cGrp, lRef )
   LOCAL lRet := .F.

   IF ::CanShow()
      // IF ! ::IsVisible()
         ::show()
      // ENDIF
      lRet := .T.
   ELSE
      // IF ::IsVisible()
         ::hide()
      // ENDIF

   ENDIF
   IF ::IsActive()

      // IF ! ::IsEnabled()
         ::enable()
      // ENDIF

   ELSE
      // IF ::IsEnabled()
         ::disable()
      // ENDIF
   ENDIF

   ::SetData()
RETURN self

// Quando acquista il focus riposiziona al primo carattere
METHOD S2RadioBtn:SetInputFocus()
   // Simone gerr 3653 25/3/03
   IF ::isOnCurrentForm() 
      IF ::CanSetPage() 
         ::oForm:SetMsg(::cMsg)
      ELSE
         ::oForm:skipFocus(1)
      ENDIF

      //#ifdef _S2CTRGET_HILITE_
      IF S2CTRGET_HILITEON(NIL , NIL , .T.)
         // cambia i colori quando riceve input focus,
         // funziona perfettamente ma Š disabilitato perchŠ
         // dovrebbe essere fatto anche per i combo/spin/ecc.
         IF ::isEnabled()
            // imposto i colori per input focus
            S2ObjSetColors(self, .T., ::aCtrl[FORM_RAD_CLRHILITEPROMPT], APPCOLOR_HILITE )
         ENDIF
      ENDIF
      //#endif

   ENDIF
RETURN self

METHOD S2RadioBtn:KillInputFocus()
   IF ::isOnCurrentForm() .AND. ::CanSetPage()
      ::getData()
      ::oForm:tbDisRef(::cId)


      IF S2CTRGET_HILITEON(NIL , NIL , .T.)
          // cambia i colori quando riceve input focus,
         // funziona perfettamente ma è disabilitato perchè
         // dovrebbe essere fatto anche per i combo/spin/ecc.
         IF ::isEnabled()
            IF ::nEnabledColorFG != NIL
               ::XbpRadioButton:setColorFG(::nEnabledColorFG)
            ENDIF
            IF ::nEnabledColorBG != NIL
               ::XbpRadioButton:setColorBG(::nEnabledColorBG)
            ENDIF
         ENDIF
      ENDIF

      IF !EMPTY(::cRefGrp)
         ::oForm:tbDisRef(::cRefGrp)
      ENDIF
   ENDIF
RETURN self

METHOD S2RadioBtn:CanSetFocus()
RETURN ::CanSetPage() .AND. ::IsActive() .AND. ::CanShow() //::isEnabled() .AND. ::isVisible()

METHOD S2RadioBtn:SetFocus()
   ::setHelpID(::cID)
   ::enable()
RETURN SetAppFocus(self)

METHOD S2RadioBtn:hasFocus()
RETURN SetAppFocus() == self
// RETURN ::HasInputFocus()

// SIMONE 20/03/02 Per GERR 3103 aggiunti enable/disable/refreshBMP
METHOD S2RadioBtn:enable()
   LOCAL xRet := ::XbpRadioButton:enable()
   ::refreshBMP()
   ::ToFront()
RETURN xRet

METHOD S2RadioBtn:disable()
   LOCAL xRet := ::XbpRadioButton:disable()
   // Simone 20/3/02 in DISABLE() non lo chiamo
   // perche non serve a niente; probabilmente
   // Š collegato a PDR 4444 o 3159
   // ::refreshBMP()  
RETURN xRet

METHOD S2RadioBtn:refreshBMP()
   LOCAL aPos

   IF ::oForm:hasBitmapBG()
      aPos := ::setParent():currentPos()
      aPos[1] += ::currentPos()[1]
      aPos[2] += ::currentPos()[2]
      ::setParent():setParent():setParent():invalidateRect(       ;
         {  aPos[1]                      ,  ;
            aPos[2]+20                  ,  ;
            aPos[1]+::currentSize()[1]   ,  ;
            aPos[2]+::currentSize()[2]+25 } ;
                                             )    
   ENDIF

RETURN self


//
// ATTACH "rdb0048" TO oWin:W_CONTROL GET AS RADIOBUTTON RAD1  PROMPT 'Radio Button "A"'  ; // ATTRDB.tmp
//                  AT   7, 38                        ; // Coordinate
//                  VALUE    "A"                      ; // Valore
//                  GAP      1                        ; // Spazio ICONA / PROMPT
//                  COLOR    {"N/G","G+/G","W+/BG","W+/G"}  ; // Array dei colori
//                  ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
//                  VARNAME "RAD1"                    ; //
//                  MESSAGE "RAd1"                      // Messaggio utente
// ATTACH "rdb0049" TO oWin:W_CONTROL GET AS RADIOBUTTON RAD1  PROMPT 'Radio Button "B"'  ; // ATTRDB.tmp
//                  AT   8, 38                        ; // Coordinate
//                  VALUE    "B"                      ; // Valore
//                  GAP      1                        ; // Spazio ICONA / PROMPT
//                  COLOR    {"N/G","G+/G","W+/BG","W+/G"}  ; // Array dei colori
//                  ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
//                  VARNAME "RAD1"                    ; //
//                  MESSAGE "RAd2"                      // Messaggio utente
// ATTACH "rdb0050" TO oWin:W_CONTROL GET AS RADIOBUTTON RAD1  PROMPT 'Radio Button "C"'  ; // ATTRDB.tmp
//                  AT   9, 38                        ; // Coordinate
//                  VALUE    "C"                      ; // Valore
//                  GAP      1                        ; // Spazio ICONA / PROMPT
//                  COLOR    {"N/G","G+/G","W+/BG","W+/G"}  ; // Array dei colori
//                  ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
//                  VARNAME "RAD1"                    ; //
//                  MESSAGE "RAd3"                      // Messaggio utente
//
//    #COMMAND ATTACH <cId> TO <aParent> GET AS RADIOBUTTON <uVar> ;
//                                       PROMPT <cPrompt>;
//                                       AT  <nRow>, <nCol> ;
//                                       VALUE  <uVal>      ;
//                                       [ACTIVE <uActive>] ;
//                                       [DISPLAYIF <uDiIf>];
//                                       [REFRESHGRP  <uGrp>];
//                                       [PAGE    <nPage>]  ;
//                                       [GAP         <nGap>];
//                                       [COLOR   <aCol>]   ;
//                                       [MESSAGE    <cMes>];
//                                       [REFRESHID <cRID>] ;
//                                       [VARNAME <cVarName>];
//                                       [WHENCLICKED <bClick>];
//                                                    ;
//          => aAdd( <aParent>, { CTRL_RADIO ,;
//                                <cId>, <cRID>, <nPage>, .F., <{uDiIf}>,;
//                                <uGrp> ,;
//                                {|uVal|IF(uVal==NIL, <uVar>, <uVar>:=uVal)},;
//                                <cPrompt>, <nRow>, <nCol>,;
//                                <{uActive}>,;
//                                <aCol>,  <cMes>,;
//                                <nGap>, <{bClick}>, <cVarName>, <{uVal}> })
//
//                                               //                     DEFAULT
//    #define FORM_RAD_CTRLGRP    7              // Refresh GRP
//    #define FORM_RAD_VAR        8              // Var
//    #define FORM_RAD_PROMPT     9              // Prompt
//    #define FORM_RAD_ROW       10              // Row
//    #define FORM_RAD_COL       11              // Col
//    #define FORM_RAD_ACTIVE    12              // Active              {||.T.}
//    #define FORM_RAD_CLRID     13              // COLOR ARRAY
//       #define FORM_RAD_CLRPROMPT        13][1 //       PROMPT
//       #define FORM_RAD_CLRHOTKEY        13][2 //       HOTKEY
//       #define FORM_RAD_CLRHILITEPROMPT  13][3 //       HILITE PROMPT
//       #define FORM_RAD_CLRICON          13][4 //       ICON COLOR
//       #define FORM_RAD_CLRNULL          13][5 //       NULL
//    #define FORM_RAD_MESSAGE   14              // Message
//    #define FORM_RAD_GAP       15              // Gap                   0
//    #define FORM_RAD_CLICKED   16              // When Clicked        {||.T.}
//    #define FORM_RAD_CVAR      17              // Var Name
//    #define FORM_RAD_VALUE     18              // Value