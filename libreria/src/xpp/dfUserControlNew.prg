#include "dfCtrl.ch"
#include "common.ch"
#include "class.ch"

// crea un control utente nuovo
FUNCTION dfUserControlNew(oWin, oParent, nPage, aCtrl, cUsrClass, xEdit, cActs)
   LOCAL oClass
   LOCAL oXbp
   LOCAL aPos  
   LOCAL aSize 

   // crea combobox per ricerca standard
   oClass := _CreateUserControl(cUsrClass,xEdit)
   IF EMPTY(oClass)
      RETURN NIL
   ENDIF

   aPos  := {aCtrl[FORM_UCB_COL], aCtrl[FORM_UCB_ROW]}
   aSize := aCtrl[FORM_UCB_SIZE]

   oXbp := oClass:new( oParent, NIL, aPos, aSize)
   IF IsMethod(oXbp, "_CtrlInit")
      oXbp:_CtrlInit(aCtrl, nPage, oWin)
   ENDIF
   IF IsMethod(oXbp, "SetupKeyboard")
      // abilita gestione skip con TAB
      oXbp:setupKeyboard(cActs)
   ENDIF
RETURN oXbp

// simone 21/10/05
// mantis 0001013: aggiungere control utente 
STATIC FUNCTION _CreateUserControl(cClass,xEdit)
   LOCAL oClass, oCls1
   LOCAL aSuper := {}
   LOCAL nAttr
   LOCAL aMethod
   LOCAL cSuper := ""
   LOCAL n
   
   DEFAULT xEdit TO .F.
   IF VALTYPE(cClass) ==  "O"
      oClass := cClass:classObject()
      cClass := oClass:className()
   ELSE
      oClass := ClassObject(cClass)
   ENDIF

   IF ! EMPTY(oClass) .AND. ! oClass:isDerivedFrom("S2Control")

      cClass :="__"+cClass
      oCls1 := ClassObject(cClass)

      IF EMPTY(oCls1)
         AADD(aSuper, oClass)

         IF VALTYPE(xEdit)=="A"
            AEVAL(xEdit, {|x| AADD(aSuper, IIF(VALTYPE(x) $ "CM", ClassObject(x), x) )  })

         ELSEIF VALTYPE(xEdit)=="L"
            AADD(aSuper, ClassObject( IIF(xEdit,"__UsrEditSupport","__UsrObjSupport")) )
         ENDIF

         // creo stringa con nomi di superclassi 
         cSuper := ""
         FOR n := 1 TO LEN(aSuper)
            cSuper += ";"+aSuper[n]:className()
         NEXT
         cSuper := SUBSTR(cSuper, 2)

         nAttr   := CLASS_EXPORTED + METHOD_INSTANCE 
         aMethod := {{ "INIT" , nAttr, {|self, p01, p02, p03, p04, p05, p06, p07, p08, p09, p10, ; 
                                               p11, p12, p13, p14, p15, p16, p17, p18, p19, p20| ;
                                            __init(pcount()-1, cSuper, self, ;  // tolgo il primo parametro del codeblock (self)
                                               p01, p02, p03, p04, p05, p06, p07, p08, p09, p10, ; 
                                               p11, p12, p13, p14, p15, p16, p17, p18, p19, p20  ) } }  } 
         oClass := ClassCreate(cClass, aSuper, NIL, aMethod)
      ELSE
         oClass := oCls1
      ENDIF
   ENDIF
RETURN oClass

// simone 16/7/07 
// workaround per il metodo init chiamato solo per la prima classe
// e non per tutte le superclassi!

STATIC FUNCTION __init(nPars, cSuper, o)
   LOCAL aSup, n, c
   LOCAL p01, p02, p03, p04, p05, p06, p07, p08, p09, p10, ; 
         p11, p12, p13, p14, p15, p16, p17, p18, p19, p20

//   aSup := o:classDescribe(CLASS_DESCR_SUPERCLASSES)
//   FOR n := 1 TO LEN(aSup)
//      aSup[n] := aSup[n]:className()
//   NEXT
   aSup := dfStr2Arr(cSuper, ";") 

   n:=3 // salto i primi 3 parametri
   p01 := pvalue(++n)
   p02 := pvalue(++n)
   p03 := pvalue(++n)
   p04 := pvalue(++n)
   p05 := pvalue(++n)
   p06 := pvalue(++n)
   p07 := pvalue(++n)
   p08 := pvalue(++n)
   p09 := pvalue(++n)
   p10 := pvalue(++n)
   p11 := pvalue(++n)
   p12 := pvalue(++n)
   p13 := pvalue(++n)
   p14 := pvalue(++n)
   p15 := pvalue(++n)
   p16 := pvalue(++n)
   p17 := pvalue(++n)
   p18 := pvalue(++n)
   p19 := pvalue(++n)
   p20 := pvalue(++n)

   DO CASE
      CASE nPars == 0
         AEVAL(aSup, {|cn| o:&(cn):init() })
      CASE nPars == 1
         AEVAL(aSup, {|cn| o:&(cn):init(p01) })
      CASE nPars == 2
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02) })
      CASE nPars == 3
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03) })
      CASE nPars == 4                          
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04) })
      CASE nPars == 5
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05) })
      CASE nPars == 6
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06                    ) })
      CASE nPars == 7
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07               ) })
      CASE nPars == 8
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08          ) })
      CASE nPars == 9
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09     ) })
      CASE nPars == 10
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09, p10) })

      CASE nPars == 11
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09, p10, ;
                                        p11                    ) })
      CASE nPars == 12
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09, p10, ;
                                        p11, p12               ) })
      CASE nPars == 13
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09, p10, ;
                                        p11, p12, p13          ) })
      CASE nPars == 14
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09, p10, ;
                                        p11, p12, p13, p14     ) })
      CASE nPars == 15
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09, p10, ;
                                        p11, p12, p13, p14, p15) })
      CASE nPars == 16
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09, p10, ;
                                        p11, p12, p13, p14, p15, ;
                                        p16                    ) })
      CASE nPars == 17
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09, p10, ;
                                        p11, p12, p13, p14, p15, ;
                                        p16, p17               ) })
      CASE nPars == 18
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09, p10, ;
                                        p11, p12, p13, p14, p15, ;
                                        p16, p17, p18          ) })
      CASE nPars == 19
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09, p10, ;
                                        p11, p12, p13, p14, p15, ;
                                        p16, p17, p18, p19     ) })
      CASE nPars == 20
         AEVAL(aSup, {|cn| o:&(cn):init(p01, p02, p03, p04, p05, ;
                                        p06, p07, p08, p09, p10, ;
                                        p11, p12, p13, p14, p15, ;
                                        p16, p17, p18, p19, p20) })
   ENDCASE
RETURN o



CLASS __UsrObjSupport FROM S2Control
   EXPORTED:
     VAR bOnRefresh

     INLINE METHOD DispItm()
        IF VALTYPE(::bOnRefresh) == "B"
           EVAL( ::bOnRefresh, self)
        ENDIF
     RETURN self

     INLINE METHOD CanSetFocus(); RETURN .F.
     INLINE METHOD SetFocus(); RETURN .F.
     INLINE METHOD HasFocus(); RETURN .F.

   //  INLINE METHOD _ctrlarrinit(a, o)
   //  RETURN ::ctrlarrinit(a, o)
     INLINE METHOD _ctrlInit(a, n, o)
        ::S2Control:init(a, n, o)
     RETURN self

     INLINE METHOD init() //disabilita INIT standard, vedi _ctrlInit()
     RETURN self
ENDCLASS

CLASS __UsrEditSupport FROM S2Control, S2EditCtrl
   EXPORTED:
     VAR xHotAct
     VAR bOnRefresh
     VAR bActive
     VAR bCond

     INLINE METHOD DispItm()
        IF ::CanShow()
           ::show()
        ELSE
           ::hide()
        ENDIF
        IF ::IsActive()
           ::enable()
        ELSE
           ::disable()
        ENDIF

        IF VALTYPE(::bOnRefresh) == "B"
           EVAL( ::bOnRefresh, self)
        ENDIF
     RETURN self

     INLINE METHOD PreGet()
     RETURN ::bCond == NIL .OR. EVAL(::bCond, FORM_PREGET)

     INLINE METHOD PostGet()
     RETURN ::bCond == NIL .OR. EVAL(::bCond, FORM_POSTGET)

     INLINE METHOD ChkGet()
     RETURN ::bCond == NIL .OR. EVAL(::bCond, FORM_CHKGET)

     INLINE METHOD CanSetFocus()
     RETURN ::CanSetPage() .AND. ::IsActive() .AND. ::CanShow() .AND. ::PreGet()

     INLINE METHOD SetFocus()
      ::setHelpID(::cID)
      ::enable()
     RETURN SetAppFocus(self)

     INLINE METHOD HasFocus(); RETURN SetAppFocus() == self

   //  INLINE METHOD _ctrlarrinit(a, o)
   //  RETURN ::ctrlarrinit(a, o)
     INLINE METHOD _ctrlInit(a, n, o)
        ::S2Control:init(a, n, o)
     RETURN self

     INLINE METHOD init() //disabilita INIT standard, vedi _ctrlInit()
     RETURN self

     // abilita gestione skip con TAB
     // cActs = elenco azioni abilitate (es solo "tab,Stb,ret,rar,lar")
     INLINE METHOD setupKeyboard(cActs)
        LOCAL oObj :=self
        LOCAL bPrev := oObj:keyboard
        oObj:keyboard := {|nKey,u,o| o:keyboardskip(nKey,bPrev, cActs)}
     RETURN self

     INLINE METHOD KeyboardSkip(nKey,bPrev, cActs)
        LOCAL l := .T.
        IF M->ACT $ "dar,tab,ret,rar" .AND. (EMPTY(cActs) .OR. M->ACT $ cActs)
           IF ::PostGet()
              ::oForm:skipFocus(1)
           ENDIF

        ELSEIF M->ACT $ "uar,Stb,lar" .AND. (EMPTY(cActs) .OR. M->ACT $ cActs)
           ::oForm:skipFocus(-1)
        ELSE
           IF VALTYPE(bPrev)=="B"
              EVAL(bPrev,nKey)
           ENDIF
           l := .F.
        ENDIF
     RETURN l

     INLINE METHOD isShortCut(cAct)
        LOCAL cHotAct := ::xHotAct
        IF EMPTY(cHotAct)
           RETURN .F.
        ENDIF
        IF VALTYPE(cHotAct) $ "B"
           cHotAct := EVAL(cHotAct)
        ENDIF
        IF ! VALTYPE(cHotAct) $ "CM"
           RETURN .F.
        ENDIF
     RETURN ! EMPTY(cHotAct) .AND. cAct == cHotAct

     INLINE METHOD IsActive()
     RETURN ::bActive == NIL .OR. EVAL(::bActive)
ENDCLASS




#ifdef _OLD_MODE_DDKEYWIN // modalit… usata nella ddKeyWin

STATIC FUNCTION _AddUsrControl(oWin, cUsrClass, aUsrPos, aUsrSize,nPage,lEdit, cActs)
   LOCAL oClass
   LOCAL objCtrl
   LOCAL aPage0
   LOCAL oObj
   LOCAL oMultiPage
   LOCAL oFather
   LOCAL aCtrl
   LOCAL bPrev
   LOCAL aResizeList

   DEFAULT nPage TO 1

   objCtrl    := oWin:getObjCtrl()
   oMultiPage := oWin:getMultiPage()
   aResizeList:= oWin:getCtrlArea(.T.):aResizeList[1]

   // mantis 0001013: aggiungere control utente
   oClass := _CreateUserControl(cUsrClass,lEdit)

   IF ! EMPTY(oClass)
      aCtrl :=   { CTRL_USERCB ,;
                   "ctrl1",  "",  nPage, .F., NIL,;
                   cUsrClass, aUsrPos[2],  aUsrPos[1],;
                   W_COORDINATE_PIXEL, aUsrSize }

      IF oMultiPage == NIL
         // Simone 13/6/05
         // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
         oFather := oWin:getCtrlArea()
         nPage := 1
      ELSE
         IF nPage != 0
            oFather := oMultiPage:GetPage(nPage)
         ENDIF
      ENDIF

      IF nPage == 0
         aPage0 := {}
         FOR nPage := 1 TO oMultiPage:NumPages()
            oFather := oMultiPage:GetPage(nPage)
            oObj := oClass:new( aCtrl, nPage, oWin, oFather)
            AADD(objCtrl, oObj)
            AADD(aPage0, ATAIL(objCtrl))
         NEXT
         AEVAL(aPage0, {|x|x:aPage0 := aPage0})
      ELSE
         oObj := oClass:new( oFather, NIL, aUsrPos, aUsrSize)
         oObj:_CtrlInit(aCtrl, nPage, oWin)
         AADD(objCtrl, oObj)
         IF nPage >= 1 .AND. nPage <= LEN(aResizeList)
            AADD(aResizeList[nPage], ATAIL(objCtrl))
         ENDIF
      ENDIF
   ENDIF

   // abilita gestione skip con TAB
   oObj:setupKeyboard(cActs)
RETURN oObj

// simone 21/10/05
// mantis 0001013: aggiungere control utente
STATIC FUNCTION _CreateUserControl(cClass,lEdit)
   LOCAL oClass, oCls1
   LOCAL cBase

   DEFAULT lEdit TO .F.
   oClass := ClassObject(cClass)

   IF ! EMPTY(oClass) .AND. ! oClass:isDerivedFrom("S2Control")
      cBase  := IIF(lEdit,"__UsrEditSupport","__UsrObjSupport")
      cClass :="__"+cClass
      oCls1 := ClassObject(cClass)
      IF EMPTY(oCls1)
         oClass := ClassCreate(cClass, {oClass, ClassObject(cBase)})
      ELSE
         oClass := oCls1
      ENDIF
   ENDIF
RETURN oClass

#endif
