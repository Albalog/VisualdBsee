// ------------------------------------------------------------------------
// Classe S2Form
// Finestra di visualizzazione/editing dati su DBF o su variabili
//
// Simone 20/giu/03 iniziato ad implementare FORM AUTORESIZE (gerr 3433)
//
// Super classes
//    XbpDialogBmpMenu, S2Window, S2FormCompatibility
//
// Sub classes
//    S2Browse
// ------------------------------------------------------------------------

#include "dfWin.ch"
#include "dfMenu.ch"
#include "dfCtrl.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Appevent.ch"
#include "dfMsg.ch"
#include "dfXBase.ch"
#include "dfXRes.ch"
#include "dfGFRes.ch"
#include "font.ch"
#include "toolbar.ch"
#include "dll.ch"

// simone 20/11/09 
// gestione multithread per ora disabilitato
//#define _MULTITHREAD_

// Simone 27/3/08 
// GERR 3069 - migliorare multipagina
// per control su pag.0 crea 1 solo control invece di 1 per ogni pagina
// cerca nei vari sorgenti _PAGE_ZERO_STD_
// 
// se definito, disattiva ottimizzazioni pag 0
//#define _PAGE_ZERO_STD_

// simone 4/11/10 XL2472
// il fix funziona per la GesFTC ma ä disattivato perchä mettendola nel DESTROY() 
// ä una modifica rischiosa.
// Fatta correzione solo nel GESFTC.PRG di Service (vedi doAdjustParents()). 
// Se poi si trova come viene fuori il problema anche nelle altre form (FPARCRM ecc)
// e il FIX sotto risolve allora si puï attivare per tutto e verificare
// per bene!
//
// #define _FIX_XL2472_



//#define _XBASE180_
//#define _XBASE182_



#define MENUITEM_SEPARATOR   {NIL, NIL, XBPMENUBAR_MIS_SEPARATOR, 0}
#define TOOLBAR_HEIGHT       IIF(EMPTY(dfSet("XbaseMenuToolBar_Height")), TOOLBAR_DEFAULT_HEIGHT, VAL(dfSet("XbaseMenuToolBar_Height")) )
//#define TOOLBAR_WIDTH        120
#define TOOLBAR_WIDTH        IIF(!EMPTY(dfSet("XbaseMenuToolbar_Width")),VAL(ALLTRIM(dfSet("XbaseMenuToolbar_Width"))), 120 )

#define MESSAGEAREA_HEIGHT   IIF(::UseMainStatusLine(), 0, 22)

#define STATEAREA_WIDTH      130 //90
#define NAMEAREA_OFFSET      28//28

#define PAGE_LABEL_HOFFSET   20//10
#define PAGE_LABEL_HEIGHT    IIF(::multiPageStyle == AI_MULTIPAGESTYLE_STD, 20, 26)
#define PAGE_LABEL_VOFFSET   10 + PAGE_LABEL_HEIGHT

// #define PAGE_LABEL_HEIGHT    ::tabHeight // 20
// #define PAGE_LABEL_VOFFSET   IIF(EMPTY(::tabHeight),0, 10 + PAGE_LABEL_HEIGHT) // 10 + PAGE_LABEL_HEIGHT

#define MENUBAR_HEIGHT       19  // Altezza del MENUBAR
                                 // (presunta, dovrebbe cambiare cambiando il font
                                 // bisognerebbe trovare un modo per trovarlo dinamicamente)

MEMVAR ACT, A, SA

#define TBR_EXE               1
#define TBR_LABEL             2
   #define TBR_IMG_STANDARD   2][1
   #define TBR_IMG_DISABLED   2][2
   #define TBR_IMG_FOCUS      2][3
#define TBR_WHEN              3
#define TBR_TOOLTIP           4
#define TBR_ID                5


// #include "dll.ch"
//
// DLLFUNCTION pnt( n ) USING STDCALL FROM USER32.DLL ;
//        NAME PaintDesktop



// #####################################################################
// # FWH 2021-10-08
// #####################################################################
//
// esiste un problema in xbase con l'istruzione SUPER
// che si manifesta quando una classe usa l'ereditarieta' multipla (come S2Form).
// In particolare le applicazioni vanno in crash quando viene chiamata
// S2Form:Destroy()
// esistono tre soluzioni temporanee al momento:
//
// 1) utilizzare xbase 2.0.1354 (problemi con univar dopo il passaggio da win7 -> win10)
//
// 2) modificare la catena di derivazione di S2Form in questo modo: CLASS S2Form FROM XbpDialogBmpMenu, S2Window, S2FormCompatibility
//
// 3) modificare xbparts.prg (2.0.1503) in questo modo:
//		METHOD XbpDialog:Destroy()
//		   IF ::GetFrameState() == XBPDLG_FRAMESTAT_KIOSK
//			  KioskSystemKeyHandler():deinstall()
//		   ENDIF
//		RETURN ::XbpBaseDialog:Destroy()
//
// Non avendo ricevuto risposta da Baccan sulle conseguenze della soluzione 2
// procedo con la soluzione 3 che sembra la meno invasiva in attesa di un fix ufficiale
// da parte di Alaska (ha confermato via email che sono al lavoro per correggere SUPER)

CLASS S2Form FROM S2Window, XbpDialogBmpMenu, S2FormCompatibility //, ServiceDialog //, AutoResize //, DbFilter
PROTECTED:
// EXPORTED:  // esporto tutto per funzioni__S2FORM_*
   VAR aOrigPosSize
   VAR aObjPos, aObjSize
   VAR XbpPrev
   VAR aPrevMsg
   VAR oCtrlFocus
   VAR aFormDim
   VAR aRealTime
   VAR lDispLoop
   VAR aMenuInForm
   VAR nDispLoop
   VAR aCompGrp
   //VAR oBackGroundBmp

   VAR oMenuStyle   // oggetto per Menu con Stile nuovo

   // Metodi di localizzazione degli Array nei codeblock
   INLINE METHOD ToolBarExecuteCB(cAct)
      LOCAL x := cAct
   RETURN {|| dbAct2Kbd(x) }

   INLINE METHOD ToolBarMtdCB(aMethod)
      LOCAL aMtd := aMethod
   RETURN {|| (aMtd[MTD_WHEN] == NIL .OR. EVAL(aMtd[MTD_WHEN], ::cState)) .AND. ;
            (aMtd[MTD_RUN ] == NIL .OR. EVAL(aMtd[MTD_RUN ])) }

   INLINE METHOD ToolBarMenuCB(aMnu)
      LOCAL aMenu := aMnu
   RETURN {|| dfMenuItemIsActive(aMenu) }

   // METHOD DOSDimChanged, DOSDIMUpdate
   METHOD RealTimeUpdate
   METHOD chkFreeRes

   METHOD _tbInk

   // SImone 13/6/05
   // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
   INLINE METHOD hasScrollBars(); RETURN ::CtrlArea:isDerivedFrom("S2ScrollArea")

   // Simone 13/3/06
   // mantis 0001003: migliorare resize nelle form
   //INLINE METHOD resizeArea()
   //RETURN ::drawingArea

   // 26/8/04 simone GERR 4244:
   // aggiunge azioni gotop/gobottom da visualizzare nella toolbar
   INLINE METHOD addTopBottomActions()
       LOCAL aMenu
       LOCAL bBlk
       LOCAL bBlk2
       LOCAL bRun

       // Evita la creazione dell'array se l'ha giÖ fatta!
       IF ::W_OBJSTABLE
          RETURN .F.
       ENDIF

       IF EMPTY(::W_ALIAS)
          RETURN .F.
       ENDIF

       IF ! dfSet(AI_XBASETOOLBARADDTOP)
          RETURN .F.
       ENDIF

       aMenu:= dfMenuFind(::W_MENUARRAY, "skp", .F.)
       IF EMPTY(aMenu)
          RETURN .F.
       ENDIF

       // codeblock di attivazione per azione SKIP
       bBlk := aMenu[MNI_BSECURITY]
       bRun := aMenu[MNI_BRUNTIME ]

       aMenu := dfMenuFind(::W_MENUARRAY, "Cho", .F.)
       IF ! EMPTY(aMenu)
          RETURN .F.
       ENDIF

       aMenu := dfMenuFind(::W_MENUARRAY, "Cen", .F.)
       IF ! EMPTY(aMenu)
          RETURN .F.
       ENDIF

       aMenu := ASCAN(::W_KEYBOARDMETHODS, {|aMtd| aMtd[MTD_ACT] == "Cho"})
       IF ! EMPTY(aMenu)
          RETURN .F.
       ENDIF

       aMenu := ASCAN(::W_KEYBOARDMETHODS, {|aMtd| aMtd[MTD_ACT] == "Cen"})
       IF ! EMPTY(aMenu)
          RETURN .F.
       ENDIF

       bBlk2 := {|n| n:=EVAL(bBlk), IIF(n==MN_ON, MN_SECRET, n)}

       ATTACH "ZY" TO MENU ::W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
               BLOCK    bBlk2  ; // Condizione di stato di attivazione
               RUNTIME  bRun ;
               PROMPT   dfStdMsg( MSG_TBGETKEY18)               ; // Etichetta
               SHORTCUT "Cho"                             ; // Shortcut
               EXECUTE  {||tbTop(self)}                    ; // Funzione
               MESSAGE  dfStdMsg( MSG_TBGETKEY18)       ; // Messaggio utente
               ID ""
       ATTACH "ZZ" TO MENU ::W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
               BLOCK    bBlk2  ; // Condizione di stato di attivazione
               RUNTIME  bRun ;
               PROMPT   dfStdMsg( MSG_TBGETKEY19)              ; // Etichetta
               SHORTCUT "Cen"                             ; // Shortcut
               EXECUTE  {||tbBottom(self)}                    ; // Funzione
               MESSAGE  dfStdMsg( MSG_TBGETKEY19)      ; // Messaggio utente
               ID ""

   RETURN .T.

   // METHOD NewSay, NewGroupBox, NewPushButton, ;
   //        NewFunc, NewGet, NewListBox,

   METHOD MenuCreate, _MenuFind, ChgHotKey, MultiPageCreate, ToolBarCreate
   METHOD addMenuToPopUp, isPopUp
   METHOD MenuInFormInit,  menuInFormScan

   // simone 1/6/05
   // mantis 0000760: abilitare nuovi stili per i controls
   METHOD adjustParents, resetParents
   VAR    aChgParents

   VAR objCtrl, editCtrl, RadioGrp, oMultiPage
   VAR CtrlArea, toolBarArea
   VAR statusLine
   VAR statusLineStyle

   VAR MessageArea
   VAR StateArea, NameArea, NameAreaWidth

   // VAR xTitle
   // VAR MsgArea, StateArea, BtnArea

   INLINE METHOD _ToolBarDefault()
   RETURN { ;
          { "add", {TOOLBAR_ADD      , TOOLBAR_ADD      }, NIL }, ;
          { "mod", {TOOLBAR_MOD      , TOOLBAR_MOD      }, NIL }, ;
          { "del", {TOOLBAR_DEL      , TOOLBAR_DEL      }, NIL }, ;
          { "*--", NIL                                         }, ;
          { "win", {TOOLBAR_FIND     , TOOLBAR_FIND     }, NIL }, ;
          { "A07", {TOOLBAR_FIND_WIN , TOOLBAR_FIND_WIN }, NIL }, ;
          { "*--", NIL                                         }, ;
          { "pgu", {TOOLBAR_PG_PREV  , TOOLBAR_PG_PREV  }, NIL }, ;
          { "pgd", {TOOLBAR_PG_NEXT  , TOOLBAR_PG_NEXT  }, NIL }, ;
          { "*--", NIL                                         }, ;
          { "wri", {TOOLBAR_WRITE_H  , TOOLBAR_WRITE_H  }, NIL }, ;
          { "esc", {TOOLBAR_ESC_H    , TOOLBAR_ESC_H    }, NIL }, ;
          { "*--", NIL                                         }, ;
          { "Cho", {TOOLBAR_GOTOP    , TOOLBAR_GOTOP    }, NIL }, ;
          { "skp", {TOOLBAR_PREV     , TOOLBAR_PREV     }, NIL }, ;
          { "skn", {TOOLBAR_NEXT     , TOOLBAR_NEXT     }, NIL }, ;
          { "Cen", {TOOLBAR_GOBOTTOM , TOOLBAR_GOBOTTOM }, NIL }, ;
          { "*--", NIL                                         }, ;
          { "hlp", {TOOLBAR_HELP_H   , TOOLBAR_HELP_H   }, NIL }, ;
          { "ush", {TOOLBAR_KEYHELP_H, TOOLBAR_KEYHELP_H}, NIL }  }

   METHOD adjustCoords()

   //Metodo che ricerca la voce di menó da visualizzare
   METHOD _FinSub()

EXPORTED:
   //////////////////////////////////
   //Luca 23/11/2011 XLS  2739,1932
   //Correzione sul lostfocus sui campi GET e Memo: non vengono memorizzati i valori digitati se si preme un pulsante 
   //sulla toolbar nel caso di toolbar attiva solo sulla Mainform.
   //////////////////////////////////
   //METHOD KillInputFocus()
   //////////////////////////////////
   //Spostata Luca 16/06/2004
   VAR aMinimized
   VAR goTopBlock, goBottomBlock, skipBlock

   VAR oPopUpMenu, aPopUpMenu, nPopUpMenuStart, oMenuBar
   VAR lFullScreen, lCenter
   VAR oMenuInForm
   VAR cImages

   VAR FormName
   VAR ShowMessageArea, ShowNameArea, ShowToolBar
   VAR W_TITLE
   VAR MDI
   VAR extStatus
   VAR bitmapBG
   VAR aToolBar, bToolBarHandler, lToolBarInit
   VAR MenuInFormWidth
   VAR SubMenuWidth IS MenuInFormWidth
   VAR lRealTimeStop
   VAR tabHeight
   VAR nOwnerFormDisplay
   VAR nCoordMode
   VAR MessageHeight
   VAR toolBarWidth  // larghezza toolbar
   VAR toolBarHeight // altezza toolbar
   VAR multiPageStyle
   VAR toolBarStyle
   VAR lSubMenuHidden

   VAR lAllPage

   // Inserito per gestire in modo autonomo il time out in modo personlaizzato
   VAR bTimeOutCodeBlock


   VAR lMenuExe // esegue voci di menu internamente alla tbInk()

   // Simone 13/6/05
   // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
   VAR lScrollBars

   // Simone 13/6/05
   VAR MenuStyle   // stile del menu

   //Luca 03/06/2013  Mantis 2224
   VAR lShowDisableMenu // dfset("xbaseShowdisablemenuitem")

   ////////////////////////////////////////////////////////////
   //Luca 14/11/2011 spostato qui per poter gestire meglio alcune personalizzazioni di gestione focus.
   METHOD SetFocus, FindFocusPos, handleShortCut, SetCtrlFocus
   METHOD AddObjCtrl, ChkGetCtrl
   ////////////////////////////////////////////////////////////


   INLINE METHOD IsOnCurrentForm()
      LOCAL l := S2FormCurr()==self
   RETURN l

   ////////////////////////////////////////////////////////////
   //Luca 22/06/2015
   ////////////////////////////////////////////////////////////
   INLINE METHOD GetStateArea()
   RETURN ::StateArea
   INLINE METHOD GetNameArea()
   RETURN ::NameArea
   ////////////////////////////////////////////////////////////

   // Simone 20/giu/03
   // Controllo se la finestra ha autoresize
   INLINE METHOD IsAutoResize()
      LOCAL lRet := .F.

      IF IsMemberVar(self,"W_MOUSEMETHOD") .AND.;
         VALTYPE(TBISOPT(self,W_MM_SIZE)) == "L"
         lRet := TBISOPT(self,W_MM_SIZE)
      ENDIF 
      //In alcuni casi da runtime errore
      //RETURN TBISOPT(self,W_MM_SIZE)
   RETURN lRet
//   RETURN ::border == XBPDLG_SIZEBORDER //.OR. ::border == XBPDLG_RAISEDBORDERTHICK

   INLINE METHOD DispItm()
      // Metodo fittizio per non dare errore in caso venga eseguito
      // questo metodo nella tbInk
   RETURN

   INLINE METHOD ToolBarDefault()
       LOCAL aToolBar := ::_ToolBarDefault()
       IF VALTYPE(::bToolBarHandler) == "B"
          aToolBar := EVAL(::bToolBarHandler, self, aToolBar, ::lToolBarInit)
       ENDIF
   RETURN aToolBar

   METHOD resize

   // Simone 13/3/06
   // mantis 0001003: migliorare resize nelle form
   METHOD resizeDrawingArea


   METHOD SetMsg, GetMsg, GetState, SetState, ShowState, SearchObj
   METHOD setFormName, getFormName

   METHOD Init, Create, Destroy //, Show
   METHOD tbDisItm, tbDisRef, tbDisCal, tbGet
   METHOD tbGetTop ,tbConfig, tbEnd //, tbGetVar
   METHOD realTime //, updSize
   METHOD setTitle

   INLINE METHOD getObjCtrl(); RETURN ::objCtrl

   INLINE METHOD getCtrlArea(lBase)
      LOCAL oRet

      DEFAULT lBase TO .F.

      oRet :=::CtrlArea

      IF ::hasScrollBars() .AND. ! lBase
         oRet := ::CtrlArea:drawingArea
      ENDIF
   RETURN oRet

   INLINE METHOD getMessageArea()
      IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
         RETURN ::MessageArea
      ENDIF
   RETURN ::statusLine

   INLINE METHOD getMultiPage(); RETURN ::oMultiPage

   INLINE METHOD UpdateCurrentGet()
      ::W_CURRENTGET := ::FindFocusPos()
   RETURN ::W_CURRENTGET

   INLINE METHOD getToolBar(lTBArea)
   RETURN IIF(VALTYPE(lTBArea)=="L" .AND. lTBArea, ;
              ::toolBarArea, ;
              ::toolBarArea:getStatic())

   INLINE METHOD setFullScreen()
       LOCAL aCoords := ::calcFullScreen()
       #ifdef _XBASE15_
         ::setPosAndSize(aCoords[1], aCoords[2])
       #else
         ::setSize(aCoords[2],.F.)
         ::setPos(aCoords[1])
       #endif
   RETURN self

   INLINE METHOD calcFullScreen()
       LOCAL aSize := S2AppDesktopSize()
       LOCAL aPos  := {0, S2WinStartMenuSize()[2]}
   RETURN {aPos, aSize}

   METHOD _tbUpdExp     // Messo con _ perchä ä STATIC PROCEDURE in tbConfig originale
   METHOD __tbUpdExp

#ifdef _PAGE_ZERO_STD_
#else
   VAR aCtrlPg0

   INLINE METHOD onPrePgChange(nOldPage, nCurrPage)
      LOCAL n, obj, oOld, oNew
      IF nOldPage  != NIL      .AND. ;
         nCurrPage != nOldPage .AND. ;
         ! EMPTY(::aCtrlPg0)

         oOld := ::oMultiPage:getPage(nOldPage)
         oNew := ::oMultiPage:getPage(nCurrPage)

         FOR n := 1 TO LEN(::aCtrlPg0)
            obj := ::objCtrl[ ::aCtrlPg0[n] ]
            IF obj:setParent() == oOld // cambio pagina all'oggetto
               obj:setParent(oNew)
            ENDIF
         NEXT
      ENDIF
   RETURN .T.
#endif

   INLINE METHOD showItem(nCurrPage,oPag, nOldPage)
   //RETURN AEVAL(::objCtrl, {|x|IIF(IsMethod( x, "ShowItem" ), x:showItem(nCurrPage,oPag), NIL) })
      LOCAL nN, xObj
      FOR nN := 1 TO LEN(::objCtrl)
          xObj := ::objCtrl[nN]
          IF IsMethod( xOBJ, "ShowItem" )
             xObj:showItem(nCurrPage,oPag)
          ENDIF 
      NEXT
   RETURN .T.

   INLINE METHOD tbTop(); RETURN EVAL(::goTopBlock)
   INLINE METHOD tbBottom(); RETURN EVAL(::goBottomBlock)
   INLINE METHOD tbDown(n); RETURN EVAL(::skipBlock, IIF(n==NIL,1,n))
   INLINE METHOD tbUp(n); RETURN EVAL(::skipBlock, IIF(n==NIL,-1,-n))

   // Protezione per parametro lTbGet, evito che
   // un'applicazione possa chiamare tbInk(.t.)
   INLINE METHOD tbInk(); RETURN ::_tbInk( .F. )

   ACCESS ASSIGN METHOD W_TITLE // VAR W_TITLE

   METHOD getActiveCtrl
   METHOD SkipFocus, MenuOpen, MenuFind , SubMenuFind
   METHOD tbGetGoto
   METHOD tbPgActual, tbPgGoto, tbPgSkip, tbPgMax, tbPgRefresh, tbPgLoop
   METHOD UpdControl
   METHOD changeAreaSize

   INLINE METHOD setMenuInForm(cId)
      AADD(::aMenuInForm, cId)
   RETURN self

   INLINE METHOD MenuInFormOpenCB(aMenu)
      LOCAL cMenu := aMenu[MNI_CHILD]
   RETURN {|| ::oMenuInForm:setMenu(cMenu) }

   INLINE METHOD CanSetPage(b)
   RETURN IIF(::oMultiPage==NIL, NIL, ::oMultiPage:canSetPage(b)  )
   //RETURN IIF(::oMultiPage==NIL, NIL, ::oMultiPage:aPage[::nCurrPage]:GetSelectCodeBlock()  )

   // C'ä una bitmap di backgroud?
   INLINE METHOD hasBitmapBG()
   #ifdef _XBASE16_
      RETURN ! EMPTY(::drawingArea:bitmap)
   #else
      RETURN ::drawingArea:bitmap != NIL
   #endif

   METHOD ExecMenuItem
   METHOD ExecSubMenuItem
   

#ifdef _MULTITHREAD_

   INLINE METHOD UseMainStatusLine(lCheckThread)
       DEFAULT lCheckThread TO .T.
   RETURN (!lCheckThread .OR. dfThreadIsMain()) .AND. dfSetMainWin() != NIL .AND. dfSetMainWin() != self .AND. ;
          dfAnd( dfSet(AI_XBASEMAINMENUMDI), AI_MENUMDI_SHOWSTATUS) != 0

   INLINE METHOD UseMainToolbar(lCheckThread)
       DEFAULT lCheckThread TO .T.
   RETURN (!lCheckThread .OR. dfThreadIsMain()) .AND. dfSetMainWin() != NIL .AND. dfSetMainWin() != self .AND. ;
          dfAnd( dfSet(AI_XBASEMAINMENUMDI), AI_MENUMDI_SHOWTOOLBAR) != 0 .AND. ;
          ! EMPTY( dfSetMainWin():getToolBar( .T. ):setParent() )
#else
   INLINE METHOD UseMainStatusLine()
   RETURN dfSetMainWin() != NIL .AND. dfSetMainWin() != self .AND. ;
          dfAnd( dfSet(AI_XBASEMAINMENUMDI), AI_MENUMDI_SHOWSTATUS) != 0

   INLINE METHOD UseMainToolbar()
   RETURN dfSetMainWin() != NIL .AND. dfSetMainWin() != self .AND. ;
          dfAnd( dfSet(AI_XBASEMAINMENUMDI), AI_MENUMDI_SHOWTOOLBAR) != 0 .AND. ;
          ! EMPTY( dfSetMainWin():getToolBar( .T. ):setParent() )
#endif
   METHOD addToolItem
   METHOD addToolSeparator

   //////////////////////////////////////////////////////////////////////////
   //11/07/2012
   //Inserito perche altrimenti la ricerca con ddkeyandwin da runtime error 
   INLINE METHOD CanSetFocus()
   RETURN .T.
   //////////////////////////////////////////////////////////////////////////



   // cerca un toolItem con questo ID
   // by reference torna in x il numero
   INLINE METHOD getToolItem(cID, x)
      LOCAL aTbr := ::aToolbar
      LOCAL n

      x:= 0

      IF EMPTY(aTbr)
         RETURN NIL
      ENDIF

      FOR n := 1 TO LEN(aTbr)
         IF LEN( aTbr[n] ) >= TBR_ID .AND. ;
            aTbr[n][TBR_ID] != NIL   .AND. ;
            aTbr[n][TBR_ID]== cID

            x:= n // by reference
            EXIT
         ENDIF
      NEXT
   RETURN IIF( x>0, aTbr[x], NIL)


   // Simone 4/11/10 XL2472
   INLINE METHOD doAdjustParents()
      IF ::isAutoResize() .AND. ! ::hasScrollBars()
         IF ::aChgParents == NIL // faccio solo 1 volta
            // cambio il parent dei control interni ai groupbox
            ::AdjustParents()
         ENDIF
      ENDIF
   RETURN self

   METHOD MenuRefresh
   INLINE METHOD getMenuStyleObj(); RETURN ::oMenuStyle
ENDCLASS

* **********************************************************************
* Init method
* **********************************************************************
METHOD S2Form:Init( nTop, nLeft, nBott, nRight, nType, ;
                    oParent, oOwner, aPos, aSize, aPP, lVisible,nCoordMode )

   LOCAL oPos := NIL
   LOCAL xVal
   LOCAL cOwnerForm := dfSet("XbaseOwnerFormDisplay")
   LOCAL aUsrPP
   LOCAL aColor

   DEFAULT nType   TO W_OBJ_FRM
   DEFAULT nCoordMode  TO S2CoordModeDefault()

   ::nTop    := nTop
   ::nLeft   := nLeft
   ::nBottom := nBott
   ::nRight  := nRight

   ::nCoordMode  := nCoordMode
   // ::lDispLoop:= .F.
   ::objCtrl  := {}
   ::editCtrl := {}
   ::RadioGrp := {}
   ::aRealTime:= {}
   ::lRealTimeStop := .F.
   ::oMenuBar := NIL
   ::XbpPrev  := NIL
   ::aPrevMsg := NIL
   ::oMultiPage := NIL

   ::MDI         := .F.

   // Simone 14/6/05
   // gestione automatica Main Menu MDI se parent=MAIN menu
   IF dfAnd( dfSet(AI_XBASEMAINMENUMDI), AI_MENUMDI_ENABLED) != 0 .AND. ;
      dfSetMainWin() != NIL
      ::MDI := S2FormCurr() == dfSetMainWin()
   ENDIF

   // Tommaso 06/06/13 - Settaggio per incrementare l'altezza delle form di un numero di pixel a piacimento
   //                    Usato dalle API del CRM per avere l'interfaccia grafica lanciate da EXTRA ERP
   IF dfAnd( dfSet(AI_XBASEMAINMENUMDI), AI_MENUMDI_ENABLED) != 0 .AND.;
      dfSet("XbaseFormHeightIncrement") != NIL 
      
      ::nbottom += VAL(dfSet("XbaseFormHeightIncrement"))
      nBott     := ::nbottom
   
   ENDIF



   ::ShowMessageArea := .T.
   ::ShowNameArea    := dfSet(AI_WINDOWINFO)
   ::ShowToolBar     := dfSet("XBaseShowToolbar") == "YES"
   ::bToolBarHandler := dfSet("XbaseToolBarHandler")
   ::lFullScreen     := .F.
   ::lCenter := .F.
   ::nDispLoop := 0

   /*
   IF ::nCoordMode == W_COORDINATE_PIXEL
   //IF dfSet(AI_XBASExxxxx)
      ::minButton := TBISOPT(self,W_MM_MINIMIZE)
      ::maxButton := TBISOPT(self,W_MM_MAXIMIZE)
      //::minButton := FINIRE!!!!  TBISOPT(self,W_MM_MINIMIZE)
      //::maxButton := FINIRE!!!!  TBISOPT(self,W_MM_MAXIMIZE)
   ELSE
      ::maxButton:= .F.
   ENDIF
   */
   //::maxButton:= .F.


   ::goTopBlock := {|| (::W_ALIAS)->(DBSETORDER(::W_ORDER)), ;
                    (::W_ALIAS)->(dfTop(::W_KEY, ::W_FILTER, ::W_BREAK)) }
   ::goBottomBlock := {|| (::W_ALIAS)->(DBSETORDER(::W_ORDER)), ;
                    (::W_ALIAS)->(dfBottom(::W_KEY, ::W_FILTER, ::W_BREAK)) }
   ::skipBlock     := {|nRec|_tbFSkip(self,nRec)}

   ::FormName := ""
   ::cImages  := ""

   // IF oParent == NIL
   //    IF S2FormMain() == NIL
   //       oParent := AppDesktop()
   //    ELSE
   //       oParent := S2FormMain():drawingArea
   //    ENDIF
   // ENDIF

   // DEFAULT oParent TO S2FormMain():drawingArea

   //DEFAULT oParent TO S2BaseWindow()
   DEFAULT oParent TO AppDesktop()
   DEFAULT oOwner  TO __FormCurr(self)

   // DEFAULT oOwner  TO SetAppWindow()

   DEFAULT lVisible TO .F.

   ::aFormDim := {0,0}

   // Altezza della barra dei messaggi/stato
   ::MessageHeight := MESSAGEAREA_HEIGHT // oPos:nYMul


   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF ::nCoordMode == W_COORDINATE_PIXEL
     DEFAULT aPos TO  {::nLeft, ::nTop}
     DEFAULT aSize TO {::nRight  , ;//+ dfGetWinSizeOffset()[1], ;
                       ::nBottom }//+ MESSAGEAREA_HEIGHT + dfGetWinSizeOffset()[2]}
   ELSE
     oPos := PosCvt():new(::nLeft, ::nBottom+1)
     oPos:Trasla(oParent)
     DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}

     oPos:SetDos(::nRight - ::nLeft, ::nBottom - ::nTop)


     DEFAULT aSize TO {oPos:nXWin + dfGetWinSizeOffset()[1], ;
                       oPos:nYWin + ::MessageHeight + dfGetWinSizeOffset()[2]}
   ENDIF

   DEFAULT aPP TO {}


   * initialisation of base class
   ::XbpDialogBmpMenu:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2Window:Init( nType )
   ::S2FormCompatibility:init()
   ::close           := {|mp1,mp2,obj| dbAct2Kbd("esc") }

   ::border   := XBPDLG_DLGBORDER // PER default NON autoresize

   ::icon     := APPLICATION_ICON

   ::taskList := .T.
   ::maxButton:= .F.
   // ::sysMenu  := .F.


   // Salvo la larghezza, serve nel browse
   ::aObjPos  := aPos
   ::aObjSize := aSize


   // ::drawingArea:resize := {| aOld, aNew, oObj| ::updSize(aOld, aNew) }

   ADDKEY "Ctb" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| ::tbPgLoop( 1 )}  ; // Funzione sul tasto
         WHEN    {|s| LEN(::W_PAGELABELS) > 1}                    ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_TBBRWNEW23)

   ADDKEY "Cst" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| ::tbPgLoop( -1 )}  ; // Funzione sul tasto
         WHEN    {|s| LEN(::W_PAGELABELS) > 1}                    ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_TBBRWNEW32)

   ADDKEY "hlp" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| dfHlp(M->ENVID, M->SUBID )}  ; // Funzione sul tasto
         WHEN    {|s| .T. }                    ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_HLP16)

   ADDKEY "ush" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| dfUsrHelp(::W_KEYBOARDMETHODS, ::cState )}  ; // Funzione sul tasto
         WHEN    {|s| .T. }                    ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_HLP16)

   // IF tbChkPrn(self, "S2FORM-EXEC")
   //    ADDKEY "C_p" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
   //          BLOCK   {|| tbPrnWin(self) }  ; // Funzione sul tasto
   //          WHEN    {|s| ! EMPTY(::W_ALIAS) .AND. tbChkPrn(self, "S2FORM-WHEN")}                    ; // Condizione di stato di attivazione
   //          RUNTIME {||tbChkPrn(self, "S2FORM-RUNTIME")}                             ; // Condizione di runtime
   //          MESSAGE dfStdMsg(MSG_TBBRWNEW33)
   // ENDIF
   IF tbChkLab(self, "S2FORM-CHECK") 
      ADDKEY "C_l" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
            BLOCK   {|| tbPrnLab(self) }  ; // Funzione sul tasto
            WHEN    {|s| ! EMPTY(::W_ALIAS) .AND. tbChkLab(self, "S2FORM-WHEN") }                    ; // Condizione di stato di attivazione
            RUNTIME {|| tbChkLab(self, "S2FORM-RUNTIME")}                             ; // Condizione di runtime
            MESSAGE dfStdMsg(MSG_TBBRWNEW34)
   ENDIF

   IF tbChkSta(self, "S2FORM-CHECK")
      ADDKEY "C_t" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
            BLOCK   {|| tbFileStat(self) }  ; // Funzione sul tasto
            WHEN    {|s| ! EMPTY(::W_ALIAS) .AND. tbChkSta(self, "S2FORM-WHEN")}                    ; // Condizione di stato di attivazione
            RUNTIME {||tbChkSta(self, "S2FORM-RUNTIME")}                             ; // Condizione di runtime
            MESSAGE dfStdMsg(MSG_TBBRWNEW35)
   ENDIF

   // SImone 13/6/05
   // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
   ::lScrollBars := .F.
   IF dfSet(AI_XBASEFORMSCROLL) == AI_FORMSCROLL_ENABLED  .OR. dfSet(AI_XBASEFORMSCROLL) == AI_FORMSCROLL_ENABLED_ALWAYS
      ::lScrollBars := .T.
   ENDIF

//RESIZE
   //::CtrlArea := XbpStatic():new(::drawingArea, NIL, {0,0})
   ::CtrlArea := ResizeStatic():new(::drawingArea, NIL, {0,0})
//RESIZE
   ::ctrlArea:rbDown := {|aPos,x,obj| ::oPopUpMenu:popup(::cState, obj, aPos ) }

   // Imposta i colori nei pres. param. per foreground/background/disabled
   IF aColor==NIL                              // Evito che mi possa dare
      aColor:=dfColor( "UserLineColor" )       // Errore il messaggio d'errore
      IF EMPTY(aColor) .OR. LEN(aColor)<3      // ??? RICORDARSI ??? allineamento
         aColor := {"W+/B", "R/B", "GR/B"}
      ENDIF
   ENDIF

   ::StatusLineStyle := S2GetStatusLineStyle() // stile di default

   aUsrPP := S2PPSetColors(NIL, .T., aColor[AC_USR_NORMAL])

   IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
      ::MessageArea := S2TextBox():new(::drawingArea, NIL, {0,0}, NIL, aUsrPP)
      ::MessageArea:lbDblClick := {|| __author() }

      aUsrPP := S2PPSetColors(NIL, .T., aColor[AC_USR_STATE])
      ::StateArea := S2TextBox():new(::drawingArea, NIL, {0,0}, NIL, aUsrPP)

      ::NameArea := S2TextBox():new(::drawingArea, NIL, {0,0}, NIL, aUsrPP)
      ::NameAreaWidth := 0
      IF ! EMPTY(dfSet("XbaseStatusLineFont"))
         ::MessageArea:setFontCompoundName(dfFontCompoundNameNormalize(dfSet("XbaseStatusLineFont")))
         ::StateArea:setFontCompoundName(dfFontCompoundNameNormalize(dfSet("XbaseStatusLineFont")))
         ::NameArea:setFontCompoundName(dfFontCompoundNameNormalize(dfSet("XbaseStatusLineFont")))
      ENDIF
   ELSE
      ::statusLine := StatusLine():new(self)
      IF ! EMPTY(dfSet("XbaseStatusLineFont"))
         ::statusLine:setFontCompoundName(dfFontCompoundNameNormalize(dfSet("XbaseStatusLineFont")))
      ENDIF
   ENDIF

   ::toolBarStyle := S2GetToolBarStyle() // stile di default
   ::toolBarArea  := S2GetToolBarClass(::toolBarStyle):new( self )

   // trova larghezza toolbar da dfSet()
   IF EMPTY(dfSet(AI_XBASETOOLBAROPTIONS))
      ::toolBarWidth := TOOLBAR_WIDTH
   ELSE
      ::toolBarWidth := ASCAN(dfSet(AI_XBASETOOLBAROPTIONS), {|x|x[1]==AI_TOOLBARRIGHT_WIDTH})
      IF ::toolBarWidth == 0
         ::toolBarWidth := TOOLBAR_WIDTH
      ELSE
         ::toolBarWidth := dfSet(AI_XBASETOOLBAROPTIONS)[ ::toolBarWidth ][2]
      ENDIF
   ENDIF

   // Simone 22/3/06
   // mantis 0001016: poter impostare altezza toolbar a livello di progetto per usare icone pi˘ grandi
   // trova altezza toolbar da dfSet()
   IF EMPTY(dfSet(AI_XBASETOOLBAROPTIONS))
      ::toolBarHeight:= TOOLBAR_HEIGHT
   ELSE
      ::toolBarHeight:= ASCAN(dfSet(AI_XBASETOOLBAROPTIONS), {|x|x[1]==AI_TOOLBAR_HEIGHT})
      IF ::toolBarHeight== 0
         ::toolBarHeight := TOOLBAR_HEIGHT
      ELSE
         ::toolBarHeight:= dfSet(AI_XBASETOOLBAROPTIONS)[ ::toolBarHeight][2]
      ENDIF
   ENDIF

   ::multiPageStyle := S2GetMultiPageStyle() // stile di default

   ::oPopUpMenu := S2Menu():new( self )
   ::oPopUpMenu:title := "Popup"

   ::WOBJ_TYPE    := nType
   ::W_TITLE      := ""
   ::W_BORDERGAP  :={1,1,1,2}
   ::W_RELATIVEPOS:={ nTop    - ::W_BG_TOP, ;
                      nLeft   - ::W_BG_LEFT   ,;
                      nBott   - ::W_BG_BOTTOM ,;
                      nRight  - ::W_BG_RIGHT   }

   ::extStatus    := DBOBJ_ES_OK
   ::aMenuInForm  := {}

   // dfMenuAdd(::W_MENUARRAY, "0", MN_LABEL, NIL, NIL, "Sistema")
   dfMenuAdd(::W_MENUARRAY, "Z", MN_LABEL, {|| MN_SECRET }, NIL, "Tasti")

   //::aToolBar := ::ToolbarDefault()

   ::aCompGrp     := {}
   ::nOwnerFormDisplay := 0

   IF cOwnerForm == "HIDE"
      ::nOwnerFormDisplay := 1

   // ELSEIF cOwnerForm == "MOVE"  // NON SUPPORTATO, VEDI METODO ::MOVE
   //    ::nOwnerFormDisplay := 2

   ENDIF
   ::aChgParents := NIL
   ::lMenuExe    := .F. // esegue voci di menu uscendo da TBINK()
   ::MenuStyle  := W_MENU_STYLE_SYSTEM   // stile menu: default
   ::lToolBarInit := .F.  // toolbar inizializzata
   ::lSubMenuHidden := .F. // sottomenu nascosto

   ::lAllPage := dfSet("XbaseAutoChangePage") == "YES"
#ifdef _PAGE_ZERO_STD_
#else
   ::aCtrlPg0 := {}
#endif

   //Luca 03/06/2013  Mantis 2224
   ::lShowDisableMenu := .T.
   IF dfSet("Xbaseshowdisablemenuitem") == "NO"
      ::lShowDisableMenu := .F.
   ENDIF 
RETURN self

METHOD S2Form:chkFreeRes()
   LOCAL lRet := .T.
   LOCAL aResource := S2GetFreeRes95()

   IF ! EMPTY(aResource) .AND. ;
      (aResource[1] < 10 .OR. aResource[2] < 10 .OR. aResource[3] < 10)

      MsgBox("Impossibile aprire la finestra."+CRLF+;
             "Risorse di sistema insufficienti.")

      ::Status := XBP_STAT_FAILURE
      ::extStatus := DBOBJ_ES_ERR_RESOURCELOW
      lRet := .F.
   ENDIF

RETURN lRet

METHOD S2Form:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL nInd := 0
   LOCAL lChgSize := .F., aMtd
   LOCAL oXbp
   LOCAL xVal, cDll
   LOCAL aResizeList := {}
   LOCAL nySVal, nyPVal
   LOCAL lADD_Menuheight := .F.
   LOCAL nN , oOBJ
   // LOCAL aResizeList := {"B"}

   // S2ArrayShow(::W_MENUARRAY)

   // Controllo che ci siano abbastanza risorse libere
   IF ! ::chkFreeRes()
      RETURN self
   ENDIF

   DEFAULT lVisible TO .F.
   // Luca 16/01/2006
   //Disabilitato per il momento
   //IF ::isAutoResize()
   //   ::maxButton := .T.
   //ENDIF

#ifdef _MULTITHREAD_
/*
   IF ! dfThreadIsMain() 
      DEFAULT oParent TO AppDesktop()
      IF S2FormCurr()==NIL // se Ë la prima form del thread
         oOwner := AppDesktop()
      ENDIF
   ENDIF
*/
#endif

   IF ::lCenter
      IF EMPTY(oParent)
         oParent := AppDesktop()
      ENDIF
      aPos := dfCenterPos(::aObjSize, oParent:currentSize())
      ::aObjPos := aPos
   ENDIF


   // Creo la finestra
   ::XbpDialogBmpMenu:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF ::nCoordMode == W_COORDINATE_PIXEL
     /////////////////////////////////////
     //Correzione Ingrandimento finestra costante ad ogni apertura: Mantis 2202 del 25/09/2012
     /////////////////////////////////////
     IF ::aFormDim[1] == 0 .AND. ::aFormDim[2] == 0
        lADD_Menuheight :=.T.
     ENDIF
     /////////////////////////////////////
     ::aFormDim := { ::nRight, ::nBottom }
   ELSE
     ::aFormDim := { ::nRight - ::nLeft, ::nBottom - ::nTop }
   ENDIF

   IF ! ::W_OBJSTABLE .AND. ::lFullScreen
      ::setFullScreen()
   ENDIF

   // Creo il menu se non ä nascosto
   IF ! ::W_MENUHIDDEN

   #ifdef _S2DEBUGTIME_
      S2DebugTimePush()
   #endif
      ::MenuInFormInit()

      ::oMenuBar := ::MenuBar()
      //::oMenuBar := S2BaseWindowMenu()

      ::oMenuBar:itemSelected := {|nItm, uNIL, oXbp | ::ExecMenuItem(nItm, oXbp) }

//      ::oMenuBar:itemSelected := {|nItm, uNIL, oXbp | PostAppEvent(xbeP_User+EVENT_MENU_SELECTION, nItm, uNil, oXbp) }
      // ::oMenuBar:activateItem := {|nItm, uNIL, oXbp | PostAppEvent(xbeP_User+EVENT_MENU_SELECTION, nItm, uNil, oXbp) }

      ::MenuCreate( ::oMenuBar, ::W_MENUARRAY )

   #ifdef _S2DEBUGTIME_
      S2DebugOutString(::formName+":MAINMENU_CREATE"+STR(S2DebugTimePop()), .T. )
   #endif

   ENDIF

   IF ! ::W_OBJSTABLE
      // Aggiusto le dimensioni e posizione della finestra
      // in caso di menu nascosto o di multipagina
      aPos  := ::currentPos()
      aSize := ::currentSize()


      //13/05/04 Luca: Inserito per gestione pixel o Row/Column
      IF ::nCoordMode == W_COORDINATE_PIXEL

         IF ! ::W_MENUHIDDEN .AND. ! ::lFullScreen
            aPos[2]  -= INT(MENUBAR_HEIGHT/2)
            /////////////////////////////////////
            //Correzione Ingrandimento finestra costante ad ogni apertura: Mantis 2202 del 25/09/2012
            /////////////////////////////////////
            //aSize[2] += MENUBAR_HEIGHT
            IF lADD_Menuheight
               aSize[2] += MENUBAR_HEIGHT
            ENDIF 
            /////////////////////////////////////
            lChgSize := .T.
         ENDIF

#ifdef _MULTITHREAD_
         IF ! dfThreadIsMain() 
            IF ::UseMainToolbar(.F.) 
               aSize[2] += ::toolBarHeight
               aPos[2]  -= INT(::toolBarHeight/2)
               lChgSize := .T.
            ENDIF


            IF ::UseMainStatusLine(.F.)
               aSize[2] += ::MessageHeight
               aPos[2]  -= INT(::MessageHeight/2)
               lChgSize := .T.
            ENDIF
         ENDIF
#endif

      ELSE
         IF LEN(::W_PAGELABELS) > 1 .AND. ::tabHeight != 0
            aPos[2] -= PAGE_LABEL_VOFFSET / 2

            aSize[1] += PAGE_LABEL_HOFFSET
            aSize[2] += PAGE_LABEL_VOFFSET
            lChgSize := .T.
         ENDIF

         IF ::W_MENUHIDDEN .AND. ! ::lFullScreen
            aPos[2] -= ROW_SIZE - MENUBAR_HEIGHT
            aSize[2] += ROW_SIZE - MENUBAR_HEIGHT

            lChgSize := .T.
         ENDIF

         IF ::ShowToolBar .AND. ! ::lFullScreen .AND. ;
            ::nCoordMode == W_COORDINATE_ROW_COLUMN
            IF ::toolBarStyle == AI_TOOLBARSTYLE_RIGHT
               aSize[1] += IIF(::UseMainToolbar(), 0, ::toolBarWidth)
               aPos[1]  -= IIF(::UseMainToolbar(), 0, ::toolBarWidth)  / 2
            ELSE
               aSize[2] += IIF(::UseMainToolbar(), 0, ::toolBarHeight)
               aPos[2]  -= IIF(::UseMainToolbar(), 0, ::toolBarHeight) / 2
            ENDIF
            lChgSize := .T.
         ENDIF
      ENDIF
      IF lChgSize
         #ifdef _XBASE15_
            ::XbpDialogBmpMenu:setPosAndSize(aPos, aSize)
         #else
            ::XbpDialogBmpMenu:SetPos(aPos,.F.)
            ::XbpDialogBmpMenu:SetSize(aSize)
         #endif

      ENDIF

      IF ! ::ShowMessageArea
         ::MessageHeight := 0
      ENDIF
   ENDIF

   ::adjustCoords()

   // SImone 13/6/05
   // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
   IF ! ::W_OBJSTABLE
      // se ci sono scrollbar e la form non entra nello schermo faccio resize
      IF (::lScrollBars .AND. ::currentSize()[2] > S2AppDesktopSize()[2]) .OR.;
         dfSet(AI_XBASEFORMSCROLL) == AI_FORMSCROLL_ENABLED_ALWAYS
         oXbp        := S2ScrollArea():new(::drawingarea, NIL, {0,0})
         oXbp:rbDown := ::CtrlArea:rbDown

         // Calcola spazio necessario per visualizzare i controls
         oXbp:aSizeScrollArea:= ACLONE(::drawingArea:currentSize())

         // tolgo area Pagine
//         IF LEN(::W_PAGELABELS) > 1 .AND. ::tabHeight != 0
//            oXbp:aSizeScrollArea[2] -= IIF(::tabHeight==NIL, PAGE_LABEL_HEIGHT, ::tabHeight)
//         ENDIF
         IF ::ShowToolBar
            IF ::toolBarStyle == AI_TOOLBARSTYLE_RIGHT
               IF ::nCoordMode == W_COORDINATE_ROW_COLUMN
                  oXbp:aSizeScrollArea[1] -= IIF(::UseMainToolbar(), 0, ::toolBarWidth)
               ENDIF
            ELSE
               oXbp:aSizeScrollArea[2] -= IIF(::UseMainToolbar(), 0, ::toolBarHeight)
            ENDIF
         ENDIF
         oXbp:aSizeScrollArea[2] -= ::MessageHeight

         ::CtrlArea :=oXbp

         nySVal       := MIN(S2AppDesktopSize()[2],::currentSize()[2] )

         nyPVal       := MAX(S2WinStartMenuSize()[2],S2AppDesktopSize()[2]-nySVal   )

         IF dfSetMainWin() != NIL .AND. dfSetMainWin() != self
            nyPVal := MAX(nyPVal-30,0)
         ENDIF 
         //::setPosAndSize({::currentPos()[1], S2WinStartMenuSize()[2]}, ;
         //                {::currentSize()[1],S2AppDesktopSize()[2]})
         // sposto la finestra
         ::setPosAndSize({::currentPos()[1] , nyPVal}, ;
                         {::currentSize()[1], nySVal})
      ENDIF
   ENDIF

   // Creo le aree della finestra: CtrlArea, MessageArea e StateArea
   aSize := ::drawingArea:currentSize()

   IF ::ShowToolBar
      IF ::toolBarStyle == AI_TOOLBARSTYLE_RIGHT
         ::ToolBarCreate(::toolBarWidth, ::MessageHeight)
         aSize[1] -= IIF(::UseMainToolbar(), 0, ::toolBarWidth) // toolbar a destra
      ELSE
         // Simone 22/3/06
         // mantis 0001016: poter impostare altezza toolbar a livello di progetto per usare icone pi˘ grandi
         ::ToolBarCreate(::toolBarHeight, ::MessageHeight)
         aSize[2] -= IIF(::UseMainToolbar(), 0, ::toolBarHeight)  // toolbar in alto
      ENDIF
   ENDIF

   // abilita BITMAP nella scrollbar
   IF ::hasScrollBars()
      ::CtrlArea:drawingArea:bitmap := ::drawingArea:bitmap
   ENDIF

   ::CtrlArea:create(NIL, NIL, {0,::MessageHeight}, ;
                     {aSize[1], aSize[2]-::MessageHeight})


   IF ::ShowToolBar .AND. ;
      ::toolBarStyle == AI_TOOLBARSTYLE_RIGHT
      aSize[1] += IIF(::UseMainToolbar(), 0, ::toolBarWidth) // toolbar a destra
   ENDIF

   IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
     ::NameArea:create(NIL, NIL, {0,0}, ;
                        {0, ::MessageHeight}, ;
                        NIL, ::MessageHeight > 0 .AND. ::showNameArea)

     //::NameArea:SetText( ::formName )
     IF ::MessageHeight > 0 .AND. ::showNameArea

        ::NameAreaWidth := S2StringDim(::NameArea, ::FormName)[1] + NAMEAREA_OFFSET
        #ifdef _XBASE15_
           ::NameArea:setPosAndSize({aSize[1] - ::NameAreaWidth, 0}, { ::NameAreaWidth+2, ::MessageHeight})
        #else
           ::NameArea:setSize({ ::NameAreaWidth, ::MessageHeight})
           ::NameArea:setPos({aSize[1] - ::NameAreaWidth, 0})
        #endif
     ENDIF

     ::MessageArea:create(NIL, NIL, {0,0}, ;
                          {aSize[1] - STATEAREA_WIDTH - ::NameAreaWidth, ::MessageHeight}, ;
                          NIL, ::MessageHeight > 0)

     ::StateArea:create(NIL, NIL, {aSize[1] - STATEAREA_WIDTH - ::NameAreaWidth,0}, ;
                        {STATEAREA_WIDTH, ::MessageHeight}, ;
                        NIL, ::MessageHeight > 0)
   ELSE

      ::statusLine:high := ::MessageHeight
      ::statusLine:create()
      ::statusLine:Add(SL_TEXT, SL_MAXSIZE, "")
      ::statusLine:Add(SL_TEXT, SL_AUTO, "")
      IF ::showNameArea
         ::statusLine:Add(SL_TEXT, SL_AUTO, ::formName)
      ENDIF
   ENDIF

   ::setFormName( ::formName )

   IF ! EMPTY(::oMenuInForm)
      aSize := ::ctrlArea:currentSize()
      DEFAULT ::MenuInFormWidth TO MAX( INT(aSize[1]/3), 250 )

      aSize[1] := ::MenuInFormWidth
      ::oMenuInForm:create(::ctrlArea,NIL,{0,0}, aSize)
      //::oMenuInForm:setMenu(::aMenuInForm[1])
   ENDIF

#ifdef _S2DEBUGTIME_
   S2DebugTimePush()
#endif
   // Aggiungo i metodi della form al menu PopUp
   ::oPopUpMenu:create(NIL, NIL, NIL, ::W_KEYBOARDMETHODS, ::W_MENUARRAY )

   // Aggiungo il menu della form al menu PopUp
   ::addMenuToPopUp()

#ifdef _S2DEBUGTIME_
   S2DebugOutString(::formName+":POPUP_CREATE"+STR(S2DebugTimePop()), .T. )
#endif

#ifdef _S2DEBUGTIME_
   S2DebugTimePush()
#endif
   // Creo le pagine
   ::MultiPageCreate()
#ifdef _S2DEBUGTIME_
   S2DebugOutString(::formName+":MULTIPAGE_CREATE"+STR(S2DebugTimePop()), .T. )
#endif

#ifdef _S2DEBUGTIME_
   S2DebugTimePush()
#endif
   // Inserisco i control sulle pagine
   ::AddObjCtrl(aResizeList)
#ifdef _S2DEBUGTIME_
   S2DebugOutString(::formName+":ADDOBJCTRL"+STR(S2DebugTimePop()), .T. )
#endif

#ifdef _S2DEBUGTIME_
   S2DebugTimePush()
#endif

   // Creo i control
   //AEVAL(::objCtrl, {|obj| obj:create()})
   FOR nN := 1 TO LEN(::objCtrl)
       oOBJ := ::objCtrl[nN]
       oOBJ:create()
   NEXT

#ifdef _S2DEBUGTIME_
   S2DebugOutString(::formName+":CTRL_CREATE"+STR(S2DebugTimePop()), .T. )
#endif


   // Crea menu con stile nuovo
   IF ! EMPTY( ::oMenuStyle )
      ::oMenuStyle:create()
   ENDIF


   ////////////////////////////////////////////////////////////////////////////
   //Luca 24/07/2008. Workaround per fare il resize corretto della form
   //Attenzione va chiamata prima di assegnare il codeblock di resize!
   //Mantis 1866
   IF ::isAutoResize()
      _VDBWaitAllEvents(self,1)      
   ENDIf
   ////////////////////////////////////////////////////////////////////////////


//RESIZE
   // SImone 13/6/05
   // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
   IF (::isAutoResize() .AND. ! ::hasScrollBars() )
      // Simone 13/3/06
      // mantis 0001003: migliorare resize nelle form
//      IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
//        ::resizeInit({"B", ::ctrlArea, "H", ::getToolbar(), ::MessageArea, ::NameArea, ::StateArea, "V", ::oMenuInForm})
//      ELSE
//        ::resizeInit({"B", ::ctrlArea, "H", ::getToolbar(), "V", ::oMenuInForm})
//      ENDIF
//      ::ctrlArea:aResizeList := aResizeList

      
      ::drawingArea:resize := {|o, n| ::resizeDrawingArea(o, n)}
      ::ctrlArea:aResizeList := { aResizeList, ::W_PAGERESIZE}
   //Inserito Luca per CRM
   ELSEIF ::isAutoResize() .AND.  ::hasScrollBars()
           ::ctrlArea:DisableYPosset()
      // Luca: tolto perche fa casino
      //::drawingArea:resize := {|o, n| ::resizeDrawingArea(o, n) }
   ENDIF
//RESIZE



/* disattivato, qualcosa fa me Ë da rivedere per bene
   in ogni caso premendo ALT sia attivano gli hotkey e focus su pulsanti

   // visualizza sempre hotkey sui pulsanti
   IF dfSet("XbaseFormXPThemeShowFocus")=="YES"
      dfWinXPSetShowFocus(self)
   ENDIF
*/


RETURN self

// chiama una voce di menu direttamente o indirettamente
METHOD S2Form:execMenuItem(nItm, oXbp)
   LOCAL bRet
   LOCAL cCho
   LOCAL aCho
   LOCAL oMenuS

   IF ::lMenuExe
      // chiama subito
      IF VALTYPE(nItm) $ "CM"
         cCho := nItm
      ELSEIF oXbp:isderivedFrom("S2FormMenuItm")
         cCho := oXbp:cChoice
      ELSE
         aCho := ::MenuFind(oXbp, nItm)
         IF ! EMPTY(aCho)
            cCho := aCho[MNI_CHILD]
         ENDIF
      ENDIF
      IF ! Empty(cCho)
         EVAL( dfMenuBlock(::W_MENUARRAY,cCho) )
         //Maudp - LucaC 11/06/2013 Se l'azione viene richiamata dal menu di Extra, l'ACT deve essere "azzerato"
         //altrimenti rimane memorizzato e valutato sulle prossime finestre
         IF dfSetMainWin()==self 
            ACT := "rep"
         ENDIF
         /////////////////////////////////////////////////////
         //Aggiunto codice per impostare il focus sull'oggetto 
         /////////////////////////////////////////////////////
         ::SetFocus()
         //oMenuS := ::getMenuStyleObj()
         //IF !EMPTY(oMenuS)                     .AND. ;
         //   oMenuS:isDerivedfrom("MenuStyle1") .AND. ;
         //   !EMPTY(oMenuS:getSubMenuObj())     //.AND. ;
         //   //SetAppfocus() <> oMenuS:getSubMenuObj()
         //   Setappfocus( oMenuS:getSubMenuObj())
         //ENDIF 
         /////////////////////////////////////////////////////
         /////////////////////////////////////////////////////

      ENDIF
   ELSE
      PostAppEvent(xbeP_User+EVENT_MENU_SELECTION, nItm, NIL, oXbp)
   ENDIF
RETURN self

//////////////////////////////////////////////////////////
//Riscritta per Esecuzione submenó
//////////////////////////////////////////////////////////
// chiama una voce di menu direttamente o indirettamente
//////////////////////////////////////////////////////////
METHOD S2Form:execSubMenuItem(nItm, oXbp, cTestid)
   LOCAL bRet
   LOCAL cCho
   LOCAL aCho
   LOCAL aSub
   LOCAL cID
   ///////////////////////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////
   //Modifica per gestione menu form per xbase 182, segnalazione F.Cavallone 1509 
   #ifdef _XBASE182_
   ///////////////////////////////////////////////////////////////////////////////
   IF .T.
   ///////////////////////////////////////////////////////////////////////////////
   #else
   ///////////////////////////////////////////////////////////////////////////////
   IF ::lMenuExe
   ///////////////////////////////////////////////////////////////////////////////
   #endif
   ///////////////////////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////
      // chiama subito
      IF VALTYPE(nItm) $ "CM"
         cCho := nItm
      ELSEIF oXbp:isderivedFrom("S2FormMenuItm")
         cCho := oXbp:cChoice
      ELSE
         cID  := oXbp:ID
         aCho := ::SubMenuFind(oXbp, nItm)
         IF ! EMPTY(aCho)
            cCho := aCho[MNI_CHILD]
         ENDIF
      ENDIF
      IF ! Empty(cCho)
         EVAL( dfMenuBlock(::W_MENUARRAY,cCho) )
      ENDIF
   ELSE
      IF !EMPTY(oXbp:id) 
         IF VALTYPE(nItm)=="N" 
            aSub := ::SubMenuFind(oXbp, nItm)
            IF !EMPTY(aSub) .AND. LEN(aSub)>=1
              nITM := aSub[1]
            ELSE 
              nITM :=  S2STRforMenu(nItm)//STR(nItm,1,0)
              IF VALTYPE(oXbp:id)== "C" 
                 nITM := oXbp:id         + nItm
              ELSE 
                 nITM := S2STRforMenu(oXbp:id) +nItm //Str(oXbp:id,1,0)+ nItm
              ENDIF 
            ENDIF 
         ENDIF 
      ENDIF 
      IF !EMPTY(nItm)
         PostAppEvent(xbeP_User+EVENT_MENU_SELECTION, nItm, NIL, oXbp)
      ENDIF 
   ENDIF


RETURN self


// simone 1/6/05
// mantis 0000760: abilitare nuovi stili per i controls
// imposta i parent dei control che sono contenuti in un groupbox
// in modo che i colori di sfondo dei controls interni siano corretti
METHOD S2Form:adjustParents()
   LOCAL nInd
   LOCAL nInd2
   LOCAL nInd3
   LOCAL aGrpBox:= {}
   LOCAL oObj
   LOCAL aDim
   LOCAL oGrpBox, cCol
   LOCAL lXPTheme := _IsThemeActive()
/*
   // Workaroud: mi assicuro che tutti i controls siano creati
   // altrimenti cambiare il parent da dei problemi
   nInd2 := 0
   FOR nInd := 1 TO LEN(::objCtrl)
      IF ::objCtrl[nInd]:status() != XBP_STAT_CREATE
         nInd2 := 1
         EXIT
      ENDIF
   NEXT

   IF nInd2 == 1
      RETURN self
   ENDIF

*/
   ::aChgParents := {}

   FOR nInd := 1 TO LEN(::objCtrl)
      oObj := ::objCtrl[nInd]
      IF oObj:isDerivedFrom("S2GroupBox")
         // simone 9/3/06
         // mantis 0001001: con tema XP attivato i groupbox standard non visualizzano i control interni
         IF ! lXPTheme .AND. oObj:getType() == XBPSTATIC_TYPE_GROUPBOX
            IF EMPTY(oObj:setColorBG()) .AND. !EMPTY(oObj:Setparent():SetColorBG())
               oObj:setColorBG(oObj:Setparent():SetColorBG())
            ENDIF
         ELSE
            aDim := oObj:currentPos()
            AADD(aDim, oObj:currentPos()[1]+oObj:currentSize()[1]-1)
            AADD(aDim, oObj:currentPos()[2]+oObj:currentSize()[2]-1)

            // simone 9/3/06
            // mantis 0001001: con tema XP attivato i groupbox standard non visualizzano i control interni
            IF oObj:getType() != XBPSTATIC_TYPE_GROUPBOX
               ///////////////////////////////////////////////////////////////////////////
               //Modifica Luca 20/10/2005
               //Mantis 866


               IF IsMethod(oObj, "GetColorBG") .AND. ;
                  IsMethod(oObj, "SetColorBG")
                  oObj:setColorBG(oObj:GetColorBG())
               ENDIF
               ///////////////////////////////////////////////////////////////////////////
            ENDIF
            //::objCtrl[nInd]:setColorBG(oObj:GetColorBG())

            AADD(aDim, oObj)

            AADD(aGrpBox, aDim)
         ENDIF
      ENDIF
   NEXT

   IF EMPTY(aGrpBox)
      RETURN self
   ENDIF

   // cerca i controls con coordinate interne ai groupbox
   FOR nInd := 1 TO LEN(::objCtrl)
      oObj := ::objCtrl[nInd]

      // simone 9/3/06
      // mantis 0001001: con tema XP attivato i groupbox standard non visualizzano i control interni
      IF oObj:isDerivedFrom("S2GroupBox") .AND. ;
         !( ! lXPTheme .AND. oObj:getType() == XBPSTATIC_TYPE_GROUPBOX )

         LOOP
      ENDIF

      IF oObj:isDerivedFrom("S2RadioBtn")

         // workaround: assegno colore del GROUPBOX che lo contiene
         IF VALTYPE( oObj:setParent() ) == "O"                                 .AND. ;  // oggetto S2RadioGrp
            VALTYPE( oObj:setParent():setParent() ) == "O"                     .AND. ;  // eventuale groupbox che contiene S2RadioGrp
            oObj:setParent():setParent():isDerivedFrom("S2GroupBox")           .AND. ;  // eventuale groupbox che contiene S2RadioGrp
            oObj:setParent():setParent():getType() != XBPSTATIC_TYPE_GROUPBOX
            IF oObj:setParent():setParent():setColorBG() != NIL
               oObj:setColorBG( oObj:setParent():setParent():setColorBG())
            ENDIF
         ENDIF
         LOOP
      ENDIF

//      IF ! (oObj:isDerivedFrom("S2GroupBox") .AND. ;
//            oObj:getType() != XBPSTATIC_TYPE_GROUPBOX )

         // se non ä giÖ inserito in un groupbox
//         IF EMPTY(oObj:setParent()) .OR. ;
//            ! oObj:setParent():isDerivedFrom("S2GroupBox")

            aDim := oObj:currentPos()
            FOR nInd2 := 1 TO LEN(aGrpBox)
               IF _IsSamePage(oObj, aGrpBox[nInd2][5]) .AND. ; // se stessa pagina
                  (aDim[1] >= aGrpBox[nInd2][1] .AND. aDim[1] <= aGrpBox[nInd2][3]) .AND. ;
                  (aDim[2] >= aGrpBox[nInd2][2] .AND. aDim[2] <= aGrpBox[nInd2][4])
                  ///////////////////////////////////////////////////////////////////////////
                  //Modifica Luca 20/10/2005
                  //Mantis 866
                  //Verifico che non c'ä un altro group box all'interno
                  FOR nInd3 := 1 TO LEN(aGrpBox)
                      IF _IsSamePage(aGrpBox[nInd3][5], aGrpBox[nInd2][5]) .AND. ; // se stessa pagina
                         (aGrpBox[nInd3][1] > aGrpBox[nInd2][1] .AND. aGrpBox[nInd3][1] < aGrpBox[nInd2][3]) .AND. ;
                         (aGrpBox[nInd3][2] > aGrpBox[nInd2][2] .AND. aGrpBox[nInd3][2] < aGrpBox[nInd2][4])
                         IF _IsSamePage(oObj, aGrpBox[nInd3][5]) .AND. ; // se stessa pagina
                            (aDim[1] >= aGrpBox[nInd3][1] .AND. aDim[1] <= aGrpBox[nInd3][3]) .AND. ;
                            (aDim[2] >= aGrpBox[nInd3][2] .AND. aDim[2] <= aGrpBox[nInd3][4]) .AND. ;
                            nInd2 != nInd3
                            nInd2 := nInd3
                            EXIT
                         ENDIF
                      ENDIF
                  NEXT
                  ///////////////////////////////////////////////////////////////////////////

                  aDim := ACLONE(aDim)
                  aDim[1] -= aGrpBox[nInd2][1]
                  aDim[2] -= aGrpBox[nInd2][2]

                  oGrpBox := aGrpBox[nInd2][5]

                  // se ä un dbsee for xbase++ faccio un po di aggiustamenti
                  IF ::nCoordMode == W_COORDINATE_ROW_COLUMN
                     // ä un titolo?
                     IF (oObj:isDerivedFrom("S2Say") .AND. ;
                         aDim[1] <= 10 .AND. aDim[2] >= oGrpBox:currentSize()[2]-15)

                         // se ä un SAY in alto a sinistra ä un titolo
                         oObj:hide()
                         oObj:bDispIf := {||.F.}

                         oGrpBox:setCaption( oObj:caption )
                     ENDIF

                     aDim[2] := MAX(1, aDim[2]-11)
                  ENDIF

                  // salvo per ::resetParents()
                  AADD(::aChgParents, {oObj, oObj:setParent(), ACLONE(aDim)})

                  oObj:setPos(aDim, .F.)
                  oObj:setParent(oGrpBox)

                  ///////////////////////////////////////////////////////////////////////////
                  //Modifica Luca 20/10/2005
                  //Mantis 866
                  //IF oObj:isDerivedFrom("S2GET"       ) .OR. ;
                  //   oObj:isDerivedFrom("S2COMBOBOX"  ) .OR. ;
                  //IF oObj:isDerivedFrom("S2FUNC"      ) .OR. ;
                  //   oObj:isDerivedFrom("S2SPINBUTTON")
                  //   IF oObj:oPrompt != NIL
                  //      aDim := oObj:oPrompt:currentPos()
                  //      aDim := ACLONE(aDim)
                  //      aDim[1] -= aGrpBox[nInd2][1]
                  //      aDim[2] -= aGrpBox[nInd2][2]
                  //      oObj:oPrompt:setPos(aDim, .F.)
                  //      oObj:oPrompt:setParent(oGrpBox)
                  //      //oObj:oPrompt:toFront()
                  //   ENDIF
                  //ENDIF

                  // simone 9/3/06
                  // mantis 0001001: con tema XP attivato i groupbox standard non visualizzano i control interni
                  IF oGrpBox:getType() != XBPSTATIC_TYPE_GROUPBOX .AND. ;
                     oObj:isDerivedFrom("S2CHECKBOX")
                     oObj:setColorBG(oGrpBox:GetColorBG())
                  ENDIF
                  ///////////////////////////////////////////////////////////////////////////


                  EXIT
               ENDIF
            NEXT
//         ENDIF
//      ENDIF
   NEXT

RETURN self

// simone 1/6/05
// mantis 0000760: abilitare nuovi stili per i controls
// ripristina i parent impostati nel destroy
METHOD S2Form:resetParents()
   LOCAL nInd, nInd2, aChilds, aPos

   IF EMPTY(::aChgParents)
      RETURN self
   ENDIF

   FOR nInd := 1 TO LEN(::aChgParents)
//      aChilds := ::aChgParents[nInd]:childList()
//      FOR nInd2 := 1 TO LEN(aChilds)
//          aChilds[nInd2]:setParent( ::ctrlArea )
//      NEXT

      aPos := ::aChgParents[nInd][1]:setParent():currentPos()
      aPos[1] += ::aChgParents[nInd][3][1]
      aPos[2] += ::aChgParents[nInd][3][2]

      ::aChgParents[nInd][1]:setParent(::aChgParents[nInd][2])
      ::aChgParents[nInd][1]:setPos(aPos)
   NEXT
   //ASIZE(::aChgParents, 0)
   ::aChgParents := NIL
RETURN self


// Simone 11/10/10 XL2496
// modifica per gestione EXTRA.CFG per moduli aziendale
// aggiorno il menu
METHOD S2Form:MenuRefresh()
   LOCAL oMenu 
   LOCAL n 

   IF ! EMPTY(::W_MENUARRAY)
      // sistemo menu di sistema  (stupido gioco di parole)
      dfMenuEval( ::W_MENUARRAY ) // Voluto x' tocco l'oggetto nei control
   ENDIF

   // cancello il menu
   oMenu := ::oMenuBar
   IF ! EMPTY(oMenu) .AND. oMenu:numItems() > 0
      n := oMenu:numItems()
      DO WHILE n>0
         oMenu:delItem(n)
         n--
      ENDDO
      // ricreo i menu
      ::MenuCreate(::oMenuBar, ::W_MENUARRAY)
   ENDIF

   // cancello il menu
   oMenu := ::oPopUpMenu
   IF ! EMPTY(oMenu) .AND. oMenu:numItems() > 0
      n := oMenu:numItems()
      DO WHILE n>0
         oMenu:delItem(n)
         n--
      ENDDO
      ::addMenuToPopUp()
   ENDIF

RETURN self


// Creo il menu popup dal menu principale. Se ho solo un menu con "n" label
// es. File
//       inserimento
//       modifica
//       cancella
// lo aggiungo al menu popup senza creare la voce principale "File"

METHOD S2Form:addMenuToPopUp()
   LOCAL aLabel
   LOCAL nInd
   LOCAL aSaveLabel
   LOCAL nCount := 0

   // Conto quanti elementi visibili di primo livello
   FOR nInd := 1 TO LEN(::W_MENUARRAY)
       aLabel := ::W_MENUARRAY[nInd]
       IF aLabel[MNI_SECURITY] == MN_ON .OR. aLabel[MNI_SECURITY] == MN_OFF
          aSaveLabel := aLabel
          nCount++

          IF nCount > 1
             EXIT
          ENDIF
       ENDIF
   NEXT

   // Se ho solo un elemento visibile aggiungo solo il suo sottomenu
   // altrimenti aggiungo tutto il menu
   IF nCount == 1  .AND. ! EMPTY(aSaveLabel[MNI_ARRAY])
      ::oPopUpMenu:addItem( MENUITEM_SEPARATOR )
      ::aPopUpMenu := aSaveLabel
      ::nPopUpMenuStart:= ::oPopUpMenu:numItems()

      ::MenuCreate( ::oPopUpMenu, ::aPopUpMenu[MNI_ARRAY], .T.  )

      ::oPopUpMenu:itemSelected := {|nItm, uNIL, oXbp | ::ExecMenuItem(nItm, oXbp) }
      //::oPopUpMenu:itemSelected := {|nItm, uNIL, oXbp | PostAppEvent(xbeP_User+EVENT_MENU_SELECTION, nItm, uNil, oXbp) }
      // ::oPopUpMenu:ItemMarked   := {|nItm, uNIL, oXbp | uNil := ::Menufind(oXbp, nItm), ;
      //                                                 IIF(uNil==NIL, NIL, dfUsrMsg(uNil[MNI_HELP])) }

   ELSE
      //Gerr. 3033 30/10/03 Luca
      //::MenuCreate( ::oPopUpMenu, ::W_MENUARRAY, .T.  )
      ::MenuCreate( ::oPopUpMenu, ::W_MENUARRAY, .T. , .F. )
   ENDIF

RETURN self

METHOD S2Form:changeAreaSize( aOld, aNew )
   LOCAL nXDiff := aNew[1]-aOld[1]
   LOCAL nYDiff := aNew[2]-aOld[2]
   LOCAL nPage
   LOCAL aCSz
   LOCAL aCSy
   LOCAL aRect:= {0, 0, 0, 0}
   LOCAL oCtrlArea

   oCtrlArea := ::CtrlArea

   aCSz:=oCtrlArea:currentSize()
//   oCtrlArea:lockUpdate(.T.)
   aCSz[1] -= nXDiff
   aCSz[2] -= nYDiff
   IF ! EMPTY(::oMultiPage)
      ::oMultiPage:setSize(aCSZ, .F.)
   ENDIF
   oCtrlArea:setSize(aCSZ)
//   oCtrlArea:lockUpdate(.F.)

   // trova area da refreshare
//   aRect[1] := MIN(aOld[1], aNew[1])
//   aRect[2] := MIN(aOld[2], aNew[2])
//   aRect[3] := MAX(aOld[1], aNew[1])
//   aRect[4] := MAX(aOld[2], aNew[2])
//   oCtrlArea:invalidateRect(aRect)
RETURN self

METHOD S2Form:ToolBarCreate(nSize, nMessageHeight)
   LOCAL nInd
   LOCAL nTools
   LOCAL aMtd
   LOCAL aMenu
   LOCAL aToolBar
   LOCAL lOk
   LOCAL cMsg
   LOCAL cDex
   LOCAL bActive
   LOCAL cMsgShort
   LOCAL aPos
   LOCAL aSize
   LOCAL oWin
   LOCAL oTBParent
   LOCAL xIcon
   LOCAL oImgStd, oImgDisabled, oImgFocus
   LOCAL cTbrID
   LOCAL bExe
   
   // FWH 2021-03-19
   // Aggiungo una var local per contare quanti bottoni ho aggiunto
   // tramite template. I bottoni tramite template hanno ID che inizializza
   // col carattere '9'
   LOCAL i
   LOCAL infotel_buttons := array(0)
   LOCAL nSeparatori := 0

   // Parent della toolbar
   oWin := self
   oTBParent := oWin:drawingArea
   IF ::UseMainToolBar()
      // usa parent della toolbar del main
      oWin           := dfSetMainWin()
      oTBParent      := oWin:getToolBar( .T. ):setParent()
      nMessageHeight := dfSetMainWin():MessageHeight
   ENDIF

   ::toolBarArea:nToolBarSize   := nSize

   // toolbar a destra, tolgo altezza statusbar
   IF ::toolBarStyle == AI_TOOLBARSTYLE_RIGHT
      DEFAULT aPos  TO {NIL, NIL}
      DEFAULT aSize TO {NIL, NIL}

      DEFAULT aPos[1] TO (oTBParent:currentsize()[1] - nSize)
      DEFAULT aPos[2] TO nMessageHeight

      DEFAULT aSize[1] TO nSize
      DEFAULT aSize[2] TO oTBParent:currentsize()[2] - nMessageHeight

      ::toolBarArea:create(oTBParent, NIL, aPos, aSize)
      // se cambia dimensioni toolbar a destra, aggiorna la dimensione controlarea
      ::ToolBarArea:bOnChangeSizeMode := {|aOld, aNew, o| oWin:changeAreaSize(aOld, aNew)}

//      aToolBar := ::toolBarArea:currentPos()
//      aToolBar[2] += nMessageHeight
//      ::toolBarArea:setPos( aToolBar )
//
//      aToolBar := ::toolBarArea:currentSize()
//      aToolBar[2] -= nMessageHeight
//      ::toolBarArea:setSize( aToolBar )
   ELSE
      // simone 24/8/06 miglioramento per evitare refresh su toolbar solo su main window
      ::toolBarArea:create(oTBParent, NIL, NIL, NIL, NIL, .F.)

   ENDIF
   ::toolBarArea:hide()

   // Simone 08/07/09
   // correzione per il seguente problema:
   // se NON era definita una toolbar (quindi si usa la toolbar di default)
   // e si usava il :bToolBarHandler e nel :bToolBarHandler si usava il metodo
   // :addToolItem()  o :addToolSeparator() succedeva che
   // 1. la toolbar non conteneva l'item che si sarebbe dovuto aggiungere
   // 2. quando si rientrava la seconda volta nella form la toolbar era vuota
   // questo perchä i metodi :addToolXXX lavorano sulla variabile :aToolbar
   // inizializzandola a {} (questo procurava il problema 2) e la variabile :aToolbar
   // non era lo stesso array passato al :bToolbarHandler (questo procurava il problema 1.)
   //
   // come soluzione inizializzo sempre :aToolbar con l'array ritornato da :_ToolbarDefault()
   

   // FWH 2021-03-19
   // devo contare quanti bottoni sono stati aggiunti 
   // tramite template (hanno id che inizia con '9')
   
   IF .not. ::aToolBar == NIL

      FOR i := 1 TO len(::aToolBar)
		
		IF len(::aToolBar[i]) == 1
			nSeparatori += 1
			LOOP
		ENDIF
		
	    IF len(::aToolBar[i]) >= 5 .and. left(::aToolBar[i][5], 1) == "9"
		    aadd(infotel_buttons, ::aToolBar[i])
		ENDIF
		
	  NEXT

   ENDIF

   // FWH 2021-03-19
   // se la toolbar contiene sono bottoni inseriti tramite
   // template allora ne faccio il merge con la toolbar di default
   IF .not. ::aToolBar == NIL

	   IF len(::aToolBar) - len(infotel_buttons) - nSeparatori == 0
		  ::aToolBar := ::_ToolBarDefault()
		  
		  FOR i := 1 TO len(infotel_buttons)
			 aadd(::aToolBar, infotel_buttons[i])
		  NEXT

	   ENDIF
	   
	ENDIF
   
   IF ::aToolBar==NIL
      ::aToolBar := ::_ToolBarDefault()
   ENDIF

   aToolBar := ::aToolBar
   
   //Mantis 1153
   IF VALTYPE(::bToolBarHandler) == "B"
      aToolBar := EVAL(::bToolBarHandler, self, aToolBar, ::lToolBarInit)
   ENDIF

//   IF aToolBar == NIL
//      aToolBar := ::ToolbarDefault()
//   ELSE
//      //Mantis 1153
//      IF VALTYPE(::bToolBarHandler) == "B"
//         aToolBar := EVAL(::bToolBarHandler, self, aToolBar, ::lToolBarInit)
//      ENDIF
//   ENDIF
   IF ! EMPTY(aToolBar)
      ::lToolBarInit := .T.
      nTools := 0
      FOR nInd := 1 TO LEN(aToolBar)

         DO CASE
            CASE VALTYPE(aToolBar[nInd][TBR_EXE]) == "B"

               bActive := aToolBar[nInd][TBR_WHEN]
               cMsg    := ""
               IF LEN(aToolBar[nInd]) >= TBR_TOOLTIP .AND. ! EMPTY(aToolBar[nInd][TBR_TOOLTIP])
                  cMsg    := STRTRAN(aToolBar[nInd][TBR_TOOLTIP], dfHot(), "")
               ENDIF

               IF VALTYPE(aToolBar[nInd][TBR_LABEL]) $ "CM"
                  // pulsante di solo testo nella toolbar
                  xIcon := aToolBar[nInd][TBR_LABEL]
               ELSE
                  // Simone 28/8/06
                  // mantis 0001130: dare possibilit‡ di impostare icone toolbar disabilitate/focused
                  // Simone 6/9/2005
                  // mantis 0000877: le icone di spostamento record nella toolbar dei browse hanno sfondo grigio
                  oImgStd      := dfGetImgObject(aToolBar[nInd][TBR_IMG_STANDARD], NIL, {192, 192, 192})
                  oImgDisabled := dfGetImgObject(aToolBar[nInd][TBR_IMG_DISABLED], NIL, {192, 192, 192})
                  IF LEN(aToolBar[nInd][TBR_LABEL]) >= 3
                     oImgFocus    := dfGetImgObject(aToolBar[nInd][TBR_IMG_FOCUS], NIL, {192, 192, 192})
                  ELSE
                     oImgFocus    := NIL
                  ENDIF
                  xIcon := {oImgStd, oImgDisabled, oImgFocus}
               ENDIF

               cTbrID := IIF(LEN(aToolBar[nInd])>=TBR_ID, aToolBar[nInd][TBR_ID], NIL)
               
               // simone 6/11/08 mantis 2040
               bExe := dfMergeBlocks({|| ::isOnCurrentForm() }, aToolBar[nInd][TBR_EXE], "IIF")
               ::toolBarArea:addTool(xIcon, bExe, cMsg, bActive, NIL, cTbrID )
               nTools++

            CASE aToolBar[nInd][TBR_EXE] $ "---,*--"
               IF aToolBar[nInd][TBR_EXE] == "---" .OR. nTools > 0
                  ::toolBarArea:addSeparator()
                  nTools := 0
               ENDIF

            OTHERWISE

               // Pulsante Toolbar da AZIONE
               bActive := aToolBar[nInd][TBR_WHEN]

               lOk := .F.
               aMenu := dfMenuFind(::W_MENUARRAY, aToolBar[nInd][TBR_EXE], .F.)

               IF EMPTY(aMenu)

                  aMenu := ASCAN(::W_KEYBOARDMETHODS, {|aMtd| aMtd[MTD_ACT] == aToolBar[nInd][TBR_EXE]})
                  IF ! EMPTY(aMenu)
                     lOk := .T.
                     aMtd := ::W_KEYBOARDMETHODS[aMenu]
                     cMsg := aMtd[MTD_MSG]

                     DEFAULT bActive TO ::ToolBarMtdCB(aMtd)

                  ENDIF

               ELSE
                  lOk := .T.
                  cMsg := aMenu[MNI_LABEL]


                  DEFAULT bActive TO ::ToolBarMenuCB(aMenu)

               ENDIF


               IF lOk
                  DEFAULT cMsg TO ""
                  ///////////////////////////////////////////////////////////////////////////
                  //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012 
                  IF VALTYPE(cMsg) == "B"
                     cMsg := EVAL(cMsg)
                  ENDIF 
                  ///////////////////////////////////////////////////////////////////////////

                  cMsgShort := STRTRAN(cMsg, dfHot(), "")
                  cMsg := cMsgShort
                  cDex := dbAct2Mne(aToolBar[nInd][TBR_EXE])
                  IF ! EMPTY(cDex)
                     cMsg += "  ("+cDex+")"
                  ENDIF

                  IF VALTYPE(aToolBar[nInd][TBR_LABEL]) $ "CM"
                     // pulsante di solo testo nella toolbar
                     xIcon := aToolBar[nInd][TBR_LABEL]
                  ELSE
                     // Simone 28/8/06
                     // mantis 0001130: dare possibilit‡ di impostare icone toolbar disabilitate/focused
                     oImgStd      := dfGetImgObject(aToolBar[nInd][TBR_IMG_STANDARD], NIL, {192, 192, 192})
                     oImgDisabled := dfGetImgObject(aToolBar[nInd][TBR_IMG_DISABLED], NIL, {192, 192, 192})
                     IF LEN(aToolBar[nInd][TBR_LABEL]) >= 3
                        oImgFocus    := dfGetImgObject(aToolBar[nInd][TBR_IMG_FOCUS], NIL, {192, 192, 192})
                     ELSE
                        oImgFocus    := NIL
                     ENDIF
                     xIcon := {oImgStd, oImgDisabled, oImgFocus}
                  ENDIF

                  cTbrID := IIF(LEN(aToolBar[nInd])>=TBR_ID, aToolBar[nInd][TBR_ID], NIL)

                  // simone 6/11/08 mantis 2040
                  /////////////////////////////////////////////////////////////////////////////////////////////////////
                  bExe := dfMergeBlocks({|| ::isOnCurrentForm() }, ::ToolBarExecuteCB(aToolBar[nInd][TBR_EXE]), "IIF")
                  /////////////////////////////////////////////////////////////////////////////////////////////////////
                  ::toolBarArea:addTool(xIcon, bExe, cMsg, bActive, cMsgShort, cTbrID )

                  nTools++
               ENDIF
         ENDCASE
      NEXT

   ENDIF
RETURN self

METHOD S2Form:MultiPageCreate(lForce)
   LOCAL nInd
   LOCAL oTab
   LOCAL bBlock
   LOCAL oParent

   DEFAULT lForce TO .F.

   IF LEN(::W_PAGELABELS) > 1 .OR. lForce

      IF ::oMultiPage == NIL

         // Simone 13/6/05
         // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
         oParent := IIF(::hasScrollBars(), ::CtrlArea:drawingArea, ::CtrlArea)
         ::oMultiPage := S2GetMultiPageClass(::multiPageStyle):New( oParent, LEN(::W_PAGELABELS))
#ifdef _PAGE_ZERO_STD_
#else
         ::oMultiPage:bOnPrePgChange := {|nOld, nNew, oMultiPage| ::onPrePgChange(nOld,nNew) }
#endif
         ::oMultiPage:bOnPgChange := {|nOld, nNew, oMultiPage| ::showItem(nNew, oMultiPage:getTab(nNew), nOld), ::tbGetTop(.T.) }
         IF ::tabHeight != NIL
            ::oMultiPage:tabHeight := ::tabHeight
         ENDIF
         FOR nInd := 1 TO LEN(::W_PAGELABELS)
            oTab := ::oMultiPage:AddPage(::W_PAGELABELS[nInd])
            // Mantis 320
            IF LEN(::W_PAGECODEBLOCK)>= nInd
               DEFAULT ::W_PAGECODEBLOCK[nInd] TO ".T."
               IF VALTYPE(::W_PAGECODEBLOCK[nInd]) == "C"
                  bBlock :=  &(::W_PAGECODEBLOCK[nInd])
                  oTab:SetSelectCodeBlock(bBlock)
               ELSEIF VALTYPE(::W_PAGECODEBLOCK[nInd]) == "B"
                  oTab:SetSelectCodeBlock(::W_PAGECODEBLOCK[nInd])
               ENDIF
            ENDIF

            // Le multipage non hanno bitmap di sfondo...
            // In Xbase ä possibile perï non riesco ad attivarlo
            // qui.

            // IF ::hasBitmapBG()
            //    oTab:setColorBG(XBPSYSCLR_TRANSPARENT)
            //    oTab:drawingArea:setColorBG(XBPSYSCLR_TRANSPARENT)
            // ENDIF
            S2ObjSetColors( oTab, ! ::hasBitmapBG(), ::W_COLORARRAY[AC_FRM_BACK], APPCOLOR_BACKGROUND )

           #ifndef _XBASE182_
            oTab:drawingArea:clipChildren := .T.
           #endif
         NEXT

      ENDIF

      ::oMultiPage:Create()

      Eval(::oMultiPage:bOnPgChange, 1, 1, ::oMultiPage)

   ENDIF
RETURN self

// Serve a mettere ad icona la form base quando si riduce ad icona
// una qualsiasi form.
METHOD S2Form:Resize(aOld,aNew)
   LOCAL oObj
   LOCAL aStack := {}
   LOCAL nInd
   LOCAL nTo
   LOCAL nLoop := 2000  // Serve per evitare una eventuale ricorsione

#ifdef _MULTITHREAD_
IF dfThreadIsMain() .OR. ::setOwner() != AppDesktop()
#else
IF .T.
#endif
   IF ::getFrameState() == XBPDLG_FRAMESTAT_MINIMIZED
      oObj := self
      IF oObj:aMinimized == NIL

         // Torno indietro
         DO WHILE ! EMPTY(oObj:setOwner()) .AND. ;
                  ASCAN(aStack, {|x|x[1]==oObj:setOwner()}) == 0 .AND. ; // Aggiunto per problema in ricorsione
                  --nLoop > 0

            AADD(aStack, {oObj, oObj:currentPos()})
            oObj := oObj:setOwner()
         ENDDO
         AADD(aStack, {oObj, oObj:currentPos()})

         // Vado avanti! (perchä il primo obj potrebbe non essere un form)
         FOR nInd := LEN(aStack) TO 1 STEP -1
           oObj := aStack[nInd][1]
           IF oObj:isDerivedFrom("S2Form") .AND. ;
              oObj:isVisible() .AND. ;
              ! oObj:getFrameState() == XBPDLG_FRAMESTAT_MINIMIZED
              oObj:setFrameState(XBPDLG_FRAMESTAT_MINIMIZED)
              oObj:enable()
              oObj:aMinimized := aStack
              EXIT
           ENDIF
         NEXT
      ENDIF
   ELSE
      IF VALTYPE(::aMinimized) == "A"
         IF dfSetMainWin() != self
            ::disable()
         ENDIF

         aStack := ::aMinimized

         nTo := 2

       #ifdef _XBASE17_
         // SD 27/6/2002 per GERR 3220
         // da Xbase 1.7 in poi ä variato il modo di gestire  il minimized
         oObj := aStack[1][1]
         IF oObj:isDerivedFrom("XbpDialog") .AND. ;
            oObj:getFrameState() == XBPDLG_FRAMESTAT_NORMALIZED
            aStack[1][2] := oObj:currentPos()
            nTo := 1
         ENDIF
       #endif

         FOR nInd := LEN(aStack) TO nTo STEP -1
            oObj := aStack[nInd][1]
            oObj:setPos(aStack[nInd][2])
         NEXT

         oObj := aStack[1][1]
         IF oObj:isDerivedFrom("XbpDialog") .AND. ;
            oObj:getFrameState() == XBPDLG_FRAMESTAT_MINIMIZED
            oObj:setFrameState(XBPDLG_FRAMESTAT_NORMALIZED)
         ENDIF

         ::aMinimized := NIL
      ENDIF

   ENDIF
ENDIF
   /////////////////////////////////////////////////////////////////////////
   //Luca 6/6/2011
   //Mantis 2157: Correzione runtime error in apertura/resize della finestra.
   IF VALTYPE(aNew)=="A" .AND. LEN(aNew)>=2 .AND.;
      VALTYPE(aOld)=="A" .AND. LEN(aOld)>=2 
      //_VDBWaitAllEvents(self)
      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //Mantis 2159
      //Mantis 2160
      //Correzione Luca del 02/08/2011: Nel casi in cui la form non abbia toolbar si ottengono errori di resize. Segnalazione 1228
      //aNew[2] -= IIF(::UseMainToolbar() , 0, ::toolBarHeight) + ::MessageHeight +33//53
      //aOld[2] -= IIF(::UseMainToolbar() , 0, ::toolBarHeight) + ::MessageHeight +33//53
      aNew[2] -= IIF(::UseMainToolbar() .OR. EMPTY(::getToolBar()), 0, ::toolBarHeight) + ::MessageHeight +43//33//53
      aOld[2] -= IIF(::UseMainToolbar() .OR. EMPTY(::getToolBar()), 0, ::toolBarHeight) + ::MessageHeight +43//33//53
      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      IF !::W_MENUHIDDEN
         aNew[2] -= MENUBAR_HEIGHT
         aOld[2] -= MENUBAR_HEIGHT
      ENDIF 
   ENDIF 
   /////////////////////////////////////////////////////////////////////////

   ::XbpDialogBmpMenu:resize(aOld,aNew)
   IF ::isAutoResize()
      _VDBWaitAllEvents(self)      
   ENDIf
RETURN self

METHOD S2Form:destroy()
   LOCAL nInd

   IF ! EMPTY(::toolBarArea) .AND. ;
      ::toolBarArea:status() == XBP_STAT_CREATE .AND. ;
      ::UseMainToolbar()

      // la toolbar ha un parent diverso e quindi non viene distrutta automaticamente
      ::toolBarArea:destroy()
   ENDIF

   IF ::status() == XBP_STAT_CREATE

#ifdef _FIX_XL2472_
      // Simone 4/11/10 XL2472
      // prima del destroy inizializzo 
      ::doAdjustParents()
#endif

      // simone 28/5/08
      // ripristina le dimensioni originali
      IF ::aOrigPosSize != NIL .AND. VALTYPE(::drawingArea:resize)=="B"
         EVAL(::drawingArea:resize, ::drawingArea:currentSize(), ::aOrigPosSize[3], ::drawingArea)
         IF VALTYPE(::ctrlArea:resize)=="B"
            EVAL(::ctrlArea:resize, ::ctrlArea:currentSize(), ::aOrigPosSize[3], ::ctrlArea)
         ENDIF
         //::setPos(::aOrigPosSize[1], .F.)
         ::setPosAndSize(::aOrigPosSize[1], ::aOrigPosSize[2], .F.)
      ENDIF

      // simone 1/6/05
      // mantis 0000760: abilitare nuovi stili per i controls
      ::resetParents()

      // IF ::oBackGroundBmp != NIL
      //    ::oBackGroundBmp:destroy()
      //    ::oBackGroundBmp := NIL
      // ENDIF
      ::XbpDialogBmpMenu:destroy()
   ENDIF

   ::W_OBJSTABLE := .F.

RETURN self

// METHOD S2Form:destroy()
//    IF ::oPS != NIL
//       ::unlockPS(::oPS)
//       ::oPS := NIL
//    ENDIF
//    ::XbpDialogBmpMenu:destroy()
// RETURN self

METHOD S2Form:MenuInFormInit()
   LOCAL nInd
   LOCAL aMenu

   IF ! EMPTY(::aMenuInForm) .AND. LEN(::W_PAGELABELS) <= 1 //::oMultiPage == NIL
      ::oMenuInForm := S2FormMenu():new()
      ::oMenuInForm:aMenu := ::W_MENUARRAY
      ::oMenuInForm:oForm := self

      FOR nInd := 1 TO LEN(::aMenuInForm)
         aMenu:=dfMenuItm(::W_MENUARRAY, ::aMenuInForm[nInd])
         IF ! EMPTY(aMenu)
            aMenu[MNI_BLOCK] := ::MenuInFormOpenCB(aMenu)
         ENDIF
      NEXT

   ENDIF
RETURN self


METHOD S2Form:AddObjCtrl(aResizeList)
   LOCAL nInd     := 0, aCtrl, oObj, nPos, oFather, nPage
   LOCAL nMaxPage := 0, aPage0

   #ifdef _S2DEBUG_
      LOCAL aTest := {}, nTestPos, aTestShow := {}
   #endif

   ASIZE(aResizeList, 0)

   // Evita la creazione degli obj se l'ha giÖ fatta!
   IF ::W_OBJSTABLE
      RETURN self
   ENDIF

   ::objCtrl   := {}
   ::editCtrl  := {}
   ::RadioGrp  := {}
   ::aRealTime := {}
#ifdef _PAGE_ZERO_STD_
#else
   ::aCtrlPg0  := {}
#endif

   FOR nInd := 1 TO LEN(::W_CONTROL)

      aCtrl := ::W_CONTROL[nInd]
      #ifdef _S2DEBUG_
         // Obbligo sempre il controllo per ID duplicati nei control
         // dfSetAdd("XbaseControlIDCheck")
         // dfSet("XbaseControlIDCheck", "YES")

         IF dfSet("XbaseControlIDCheck")=="YES"
            nTestPos := ASCAN(aTest, {|x| x[1]==UPPER(aCtrl[FORM_CTRL_ID])})
            IF nTestPos == 0
               AADD(aTest, {UPPER(aCtrl[FORM_CTRL_ID]),1})
            ELSE
               aTest[nTestPos][2]++
            ENDIF
         ENDIF
      #endif


      IF ::oMultiPage == NIL
         // Simone 13/6/05
         // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
         IF ::hasScrollBars()
            oFather := ::CtrlArea:drawingArea
         ELSE
            oFather := ::CtrlArea
         ENDIF
         nPage := 1
      ELSE

         nPage := aCtrl[FORM_CTRL_PAGE]

         DEFAULT nPage TO 1

   #ifdef _PAGE_ZERO_STD_
         IF nPage != 0
            oFather := ::oMultiPage:GetPage(nPage)
         ENDIF
   #else
         oFather := ::oMultiPage:GetPage(IIF(nPage==0, 1, nPage))
   #endif

      ENDIF

      nMaxPage := MAX( IIF(::oMultiPage==NIL, nMaxPage, ::oMultiPage:NumPages()), ;
                       IIF(nPage <= 0, 1, nPage))

      // Simone 13/3/06
      // mantis 0001003: migliorare resize nelle form
      // inizializza ad array vuoto
      IF LEN(aResizeList) < nMaxPage
         ASIZE(aResizeList, nMaxPage)
         AEVAL(aResizeList, {|a, i| IIF(aResizeList[i]==NIL, aResizeList[i]:={}, NIL)})
      ENDIF

      IF aCtrl[FORM_CTRL_TYP] == CTRL_SAY
         IF VALTYPE(aCtrl[FORM_SAY_VAR]) == "C"  .AND. ;
            LEN(aCtrl[FORM_SAY_VAR])     == 1    .AND. ;
            aCtrl[FORM_SAY_VAR] $ "⁄¬ø√≈¥¿¡Ÿ≥ƒ"

            aCtrl[FORM_CTRL_DISPLAYIF] := {|| .F.  }
         ENDIF

   #ifdef _PAGE_ZERO_STD_
         IF nPage == 0

            aPage0 := {}

            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)
               AADD(::objCtrl, S2Say():new( aCtrl, nPage, self, oFather))
               AADD(aPage0, ATAIL(::objCtrl))
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})

         ELSE
            AADD(::objCtrl, S2Say():new( aCtrl, nPage, self, oFather))
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #else
         AADD(::objCtrl, S2Say():new( aCtrl, nPage, self, oFather))
         IF nPage == 0
            AADD(aResizeList[1], ATAIL(::objCtrl))
            AADD(::aCtrlPg0, LEN(::objCtrl))
         ELSE
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #endif


      ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_BOX
   #ifdef _PAGE_ZERO_STD_
         IF nPage == 0
            aPage0 := {}
            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)
               AADD(::objCtrl, S2GroupBox():new( aCtrl, nPage, self, oFather))
               AADD(aPage0, ATAIL(::objCtrl))
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})
         ELSE
            AADD(::objCtrl, S2GroupBox():new( aCtrl, nPage, self, oFather))
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #else

         AADD(::objCtrl, S2GroupBox():new( aCtrl, nPage, self, oFather))
         IF nPage == 0
            AADD(aResizeList[1], ATAIL(::objCtrl))
            AADD(::aCtrlPg0, LEN(::objCtrl))
         ELSE
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF

   #endif

      ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_GET
   #ifdef _PAGE_ZERO_STD_
         IF nPage == 0
            aPage0 := {}
            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)
               oObj := S2Get():new(aCtrl, nPage, self, oFather)
               AADD(::objCtrl, oObj)
               AADD(::editCtrl, {oObj, LEN(::objCtrl), .T. })
               AADD(aPage0, ATAIL(::objCtrl))
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})
         ELSE
            oObj := S2Get():new(aCtrl, nPage, self, oFather)
            AADD(::objCtrl, oObj)
            AADD(::editCtrl, {oObj, LEN(::objCtrl), .T. })
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #else
         oObj := S2Get():new(aCtrl, nPage, self, oFather)
         AADD(::objCtrl, oObj)
         AADD(::editCtrl, {oObj, LEN(::objCtrl), .T. })
         IF nPage == 0
            AADD(aResizeList[1], ATAIL(::objCtrl))
            AADD(::aCtrlPg0, LEN(::objCtrl))
         ELSE
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #endif

      ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_CMB
   #ifdef _PAGE_ZERO_STD_
         IF nPage == 0
            aPage0 := {}
            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)
               oObj := S2ComboBox():new(aCtrl, nPage, self, oFather)
               AADD(::objCtrl, oObj)
               AADD(::editCtrl, {oObj, LEN(::objCtrl), .T. })
               AADD(aPage0, ATAIL(::objCtrl))
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})
         ELSE
            oObj := S2ComboBox():new(aCtrl, nPage, self, oFather)
            AADD(::objCtrl, oObj)
            AADD(::editCtrl, {oObj, LEN(::objCtrl), .T. })
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #else
         oObj := S2ComboBox():new(aCtrl, nPage, self, oFather)
         AADD(::objCtrl, oObj)
         AADD(::editCtrl, {oObj, LEN(::objCtrl), .T. })
         IF nPage == 0
            AADD(aResizeList[1], ATAIL(::objCtrl))
            AADD(::aCtrlPg0, LEN(::objCtrl))
         ELSE
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #endif

      ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_SPIN
   #ifdef _PAGE_ZERO_STD_
         IF nPage == 0
            aPage0 := {}
            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)
               IF aCtrl[FORM_SPN_ARRAY] == NIL
                  oObj := S2SpinButton():new(aCtrl, nPage, self, oFather)
               ELSE
                  oObj := S2SpinArray():new(aCtrl, nPage, self, oFather)
               ENDIF
               AADD(::objCtrl, oObj)
               AADD(::editCtrl, {oObj, LEN(::objCtrl), .F. })
               AADD(aPage0, ATAIL(::objCtrl))
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})
         ELSE
            IF aCtrl[FORM_SPN_ARRAY] == NIL
               oObj := S2SpinButton():new(aCtrl, nPage, self, oFather)
            ELSE
               oObj := S2SpinArray():new(aCtrl, nPage, self, oFather)
            ENDIF
            AADD(::objCtrl, oObj)
            AADD(::editCtrl, {oObj, LEN(::objCtrl), .F. })
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #else
         IF aCtrl[FORM_SPN_ARRAY] == NIL
            oObj := S2SpinButton():new(aCtrl, nPage, self, oFather)
         ELSE
            oObj := S2SpinArray():new(aCtrl, nPage, self, oFather)
         ENDIF
         AADD(::objCtrl, oObj)
         AADD(::editCtrl, {oObj, LEN(::objCtrl), .F. })
         IF nPage == 0
            AADD(aResizeList[1], ATAIL(::objCtrl))
            AADD(::aCtrlPg0, LEN(::objCtrl))
         ELSE
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #endif

      ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_TEXT
   #ifdef _PAGE_ZERO_STD_
         IF nPage == 0
            aPage0 := {}
            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)
               oObj := S2EditBox():new(aCtrl, nPage, self, oFather)
               AADD(::objCtrl, oObj)
               AADD(::editCtrl, {oObj, LEN(::objCtrl), .T. })
               AADD(aPage0, ATAIL(::objCtrl))
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})
         ELSE
            oObj := S2EditBox():new(aCtrl, nPage, self, oFather)
            AADD(::objCtrl, oObj)
            AADD(::editCtrl, {oObj, LEN(::objCtrl), .T. })
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #else
         oObj := S2EditBox():new(aCtrl, nPage, self, oFather)
         AADD(::objCtrl, oObj)
         AADD(::editCtrl, {oObj, LEN(::objCtrl), .T. })
         IF nPage == 0
            AADD(aResizeList[1], ATAIL(::objCtrl))
            AADD(::aCtrlPg0, LEN(::objCtrl))
         ELSE
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #endif

      ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_CHECK
   #ifdef _PAGE_ZERO_STD_
         IF nPage == 0
            aPage0 := {}
            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)
               oObj := S2CheckBox():new(aCtrl, nPage, self, oFather)
               AADD(::objCtrl, oObj)
               AADD(::editCtrl, {oObj, LEN(::objCtrl), .F. })
               AADD(aPage0, ATAIL(::objCtrl))
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})
         ELSE
            oObj := S2CheckBox():new(aCtrl, nPage, self, oFather)
            AADD(::objCtrl, oObj)
            AADD(::editCtrl, {oObj, LEN(::objCtrl), .F. })
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #else
         oObj := S2CheckBox():new(aCtrl, nPage, self, oFather)
         AADD(::objCtrl, oObj)
         AADD(::editCtrl, {oObj, LEN(::objCtrl), .F. })
         IF nPage == 0
            AADD(aResizeList[1], ATAIL(::objCtrl))
            AADD(::aCtrlPg0, LEN(::objCtrl))
         ELSE
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #endif

      ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_RADIO
   #ifdef _PAGE_ZERO_STD_
         IF nPage == 0
            aPage0 := {}
            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)

               nPos := ASCAN(::RadioGrp, {|x| x:Nome  == aCtrl[FORM_RAD_CVAR] .AND. ;
                                              x:nPage == nPage})

               IF nPos == 0

                  oObj := S2RadioGrp():new( aCtrl, nPage, self, oFather)
                  oObj:Nome := aCtrl[FORM_RAD_CVAR]

                  AADD(::RadioGrp, oObj)
                  AADD(::objCtrl, oObj)

                  nPos := LEN(::RadioGrp)

                  AADD(aResizeList[nPage], ATAIL(::objCtrl))
               ENDIF

               oObj := S2RadioBtn():new(aCtrl, nPage, self, ::RadioGrp[nPos])
               AADD(::objCtrl, oObj)
               AADD(::editCtrl, {oObj, LEN(::objCtrl), .F. })
               AADD(aPage0, ATAIL(::objCtrl))
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})
         ELSE
            nPos := ASCAN(::RadioGrp, {|x| x:Nome  == aCtrl[FORM_RAD_CVAR] .AND. ;
                                           x:nPage == nPage})

            IF nPos == 0

               oObj := S2RadioGrp():new( aCtrl, nPage, self, oFather)
               oObj:Nome := aCtrl[FORM_RAD_CVAR]

               AADD(::RadioGrp, oObj)
               AADD(::objCtrl, oObj)

               nPos := LEN(::RadioGrp)
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            ENDIF

            oObj := S2RadioBtn():new(aCtrl, nPage, self, ::RadioGrp[nPos])
            AADD(::objCtrl, oObj)
            AADD(::editCtrl, {oObj, LEN(::objCtrl), .F. })
         ENDIF
   #else

         nPos := ASCAN(::RadioGrp, {|x| x:Nome  == aCtrl[FORM_RAD_CVAR] .AND. ;
                                        x:nPage == nPage})

         IF nPos == 0

            oObj := S2RadioGrp():new( aCtrl, nPage, self, oFather)
            oObj:Nome := aCtrl[FORM_RAD_CVAR]

            AADD(::RadioGrp, oObj)
            AADD(::objCtrl, oObj)

            nPos := LEN(::RadioGrp)

            IF nPage == 0
               AADD(aResizeList[1], ATAIL(::objCtrl))
               AADD(::aCtrlPg0, LEN(::objCtrl))
            ELSE
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            ENDIF

         ENDIF

         oObj := S2RadioBtn():new(aCtrl, nPage, self, ::RadioGrp[nPos])
         AADD(::objCtrl, oObj)
         AADD(::editCtrl, {oObj, LEN(::objCtrl), .F. })


   #endif


      ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_FUNCTION
   #ifdef _PAGE_ZERO_STD_
         IF nPage == 0
            aPage0 := {}
            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)
               oObj := S2Func():new( aCtrl, nPage, self, oFather)
               AADD(::objCtrl, oObj)
               AADD(aPage0, ATAIL(::objCtrl))
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})

         ELSE
            oObj := S2Func():new( aCtrl, nPage, self, oFather)
            AADD(::objCtrl, oObj)
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #else
         oObj := S2Func():new( aCtrl, nPage, self, oFather)
         AADD(::objCtrl, oObj)
         IF nPage == 0
            AADD(aResizeList[1], ATAIL(::objCtrl))
            AADD(::aCtrlPg0, LEN(::objCtrl))
         ELSE
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #endif

         // Installo nel ciclo del realtime
         IF oObj:realTime

            nPage++ // Il primo elemento ä per la pagina 0

            DO WHILE LEN(::aRealTime) < nPage
               AADD(::aRealTime, {})
            ENDDO

            AADD(::aRealTime[nPage], oObj)
         ENDIF

      ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_BUTTON
   #ifdef _PAGE_ZERO_STD_
         IF nPage == 0
            aPage0 := {}
            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)
               AADD(::objCtrl, S2GetPushButtonClass(aCtrl):new( aCtrl, nPage, self, oFather))
               AADD(aPage0, ATAIL(::objCtrl))
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})
         ELSE
            AADD(::objCtrl, S2GetPushButtonClass(aCtrl):new( aCtrl, nPage, self, oFather))
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #else
         AADD(::objCtrl, S2GetPushButtonClass(aCtrl):new( aCtrl, nPage, self, oFather))
         IF nPage == 0
            AADD(aResizeList[1], ATAIL(::objCtrl))
            AADD(::aCtrlPg0, LEN(::objCtrl))
         ELSE
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #endif

      ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_LISTBOX
   #ifdef _PAGE_ZERO_STD_
         IF nPage == 0
            aPage0 := {}
            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)

               oObj := aCtrl[FORM_LIST_OBJECT]
               oObj:W_MENUARRAY := ::W_MENUARRAY
               AADD(::objCtrl, S2ListBox():new( aCtrl, nPage, self, oFather))
               AADD(aPage0, ATAIL(::objCtrl))
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})
         ELSE
            oObj := aCtrl[FORM_LIST_OBJECT]
            oObj:W_MENUARRAY := ::W_MENUARRAY
            AADD(::objCtrl, S2ListBox():new( aCtrl, nPage, self, oFather))
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #else
         oObj := aCtrl[FORM_LIST_OBJECT]
         oObj:W_MENUARRAY := ::W_MENUARRAY
         AADD(::objCtrl, S2ListBox():new( aCtrl, nPage, self, oFather))
         IF nPage == 0
            AADD(aResizeList[1], ATAIL(::objCtrl))
            AADD(::aCtrlPg0, LEN(::objCtrl))
         ELSE
            AADD(aResizeList[nPage], ATAIL(::objCtrl))
         ENDIF
   #endif

      ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_USERCB
   #ifdef _PAGE_ZERO_STD_
         // Simone 21/06/2006
         // mantis 0001013: aggiungere control utente
         // abilita controllo utente tramite un Codeblock di setup
         IF nPage == 0
            aPage0 := {}
            FOR nPage := 1 TO ::oMultiPage:NumPages()
               oFather := ::oMultiPage:GetPage(nPage)
               oObj := EVAL(aCtrl[FORM_UCB_CB], self, oFather, nPage, aCtrl, aCtrl[FORM_UCB_USERDATA])
               IF ! EMPTY(oObj)
                  IF nPage == 1
                     dfUserControlDataSet(aCtrl[FORM_UCB_USERDATA], NIL, "_obj_", oObj, .T.)
                  ENDIF
                  AADD(::objCtrl, oObj)
                  AADD(aResizeList[nPage], ATAIL(::objCtrl))
                  AADD(aPage0, ATAIL(::objCtrl))
                  IF oObj:isDerivedFrom("S2EditCtrl") // Oggetto in EDIT?
                     AADD(::editCtrl, {oObj, LEN(::objCtrl), IsMethod(oObj, "ChkGet") })
                  ENDIF
               ENDIF
            NEXT
            AEVAL(aPage0, {|x|x:aPage0 := aPage0})
         ELSE
            oObj := EVAL(aCtrl[FORM_UCB_CB], self, oFather, nPage, aCtrl, aCtrl[FORM_UCB_USERDATA])
            IF ! EMPTY(oObj)
               dfUserControlDataSet(aCtrl[FORM_UCB_USERDATA],  NIL, "_obj_", oObj, .T.)
               AADD(::objCtrl, oObj)
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
               IF oObj:isDerivedFrom("S2EditCtrl") // Oggetto in EDIT?
                  AADD(::editCtrl, {oObj, LEN(::objCtrl), IsMethod(oObj, "ChkGet") })
               ENDIF
            ENDIF
         ENDIF
   #else
         oObj := EVAL(aCtrl[FORM_UCB_CB], self, oFather, nPage, aCtrl, aCtrl[FORM_UCB_USERDATA])
         IF ! EMPTY(oObj)
            dfUserControlDataSet(aCtrl[FORM_UCB_USERDATA],  NIL, "_obj_", oObj, .T.)
            AADD(::objCtrl, oObj)
            IF oObj:isDerivedFrom("S2EditCtrl") // Oggetto in EDIT?
               AADD(::editCtrl, {oObj, LEN(::objCtrl), IsMethod(oObj, "ChkGet") })
            ENDIF
            IF nPage == 0
               AADD(aResizeList[1], ATAIL(::objCtrl))
               AADD(::aCtrlPg0, LEN(::objCtrl))
            ELSE
               AADD(aResizeList[nPage], ATAIL(::objCtrl))
            ENDIF
         ENDIF
   #endif

      ENDIF
   NEXT
   #ifdef _S2DEBUG_
      IF dfSet("XbaseControlIDCheck")=="YES"
         AEVAL(aTest, {|x| IIF(x[2]>1, AADD(aTestShow, dfAny2Str(x)), NIL) })
         IF LEN(aTestShow) > 0
            dfArrWin(NIL,NIL,NIL,NIL,aTestShow,"Control duplicati nel form <"+::formName+">")
         ENDIF
      ENDIF
   #endif
   ::W_OBJSTABLE := .T.
   ::W_PAGEMAX := MAX( nMaxPage, LEN(::W_PAGELABELS) )

   // IF LEN(::W_PAGELABELS)<2 .AND. TBISOPT(self,W_MM_PAGE)
   //    ::W_MOUSEMETHOD -= W_MM_PAGE
   // ENDIF

   IF LEN(::aCompGrp) > 0
      AEVAL(::aCompGrp, {|a| ::__tbUpdExp(a[1],a[2]) })
   ENDIF
RETURN self

METHOD S2Form:tbConfig()
   LOCAL oWin 
   LOCAL xVal
   LOCAL lModal
   LOCAL oMenuS, aSize
#ifdef _MULTITHREAD_

   lModal := ! ::MDI

   // Simone 14/6/05
   // gestione automatica Main Menu MDI se parent=MAIN menu
   IF lModal .AND. ;
      dfAnd( dfSet(AI_XBASEMAINMENUMDI), AI_MENUMDI_ENABLED) != 0 .AND. ;
      dfSetMainWin() != NIL
      ::MDI := S2FormCurr() == dfSetMainWin()
      lModal := ! ::MDI
   ENDIF

   oWin := __FormCurr(self)
#else
   oWin := S2FormCurr()




   // Simone 14/6/05
   // gestione automatica Main Menu MDI se parent=MAIN menu
   IF dfAnd( dfSet(AI_XBASEMAINMENUMDI), AI_MENUMDI_ENABLED) != 0 .AND. ;
      dfSetMainWin() != NIL
      ::MDI := S2FormCurr() == dfSetMainWin()

      // simone 01/02/2011 XL 2656
      // fix per windows 7 (cliente COPER), 
      // se clicco su minimizza della finestra e poi riapro si blocca tutto
      // (funziona bene se clicco sulla finestra base)
      // come workaround disabilito il pulsante minimizza se non ä la finestra base
      IF dfSet("XbaseFormDisableMinButton")=="FIX_WIN7"
         ::minButton := .F.
      ENDIF
   ENDIF

   lModal := ! ::MDI
#endif

#ifdef _S2DEBUGTIME_
   S2DebugTimePush()
#endif

   // 26/8/04 simone GERR 4244:
   // aggiunge azioni gotop/gobottom da visualizzare nella toolbar
   ::addTopBottomActions()

   // sistemo menu di sistema  (stupido gioco di parole)
   dfMenuEval( ::W_MENUARRAY ) // Voluto x' tocco l'oggetto nei control

   // IF oWin != NIL .AND. lModal
   //    oWin:disable()
   // ENDIF

   //Gerr. 3719 Luca 24/10/03
   //Problema:  s2form con w_alias vuoto errore in tbup()/tbDown()
   //Soluzione: Inserito If/else/endif che controlla che ::W_Alias ä non vuoto.
   IF !EMPTY(::W_ALIAS)

      ::goTopBlock := {|| (::W_ALIAS)->(DBSETORDER(::W_ORDER)), ;
                       (::W_ALIAS)->(dfTop(::W_KEY, ::W_FILTER, ::W_BREAK)) }
      ::goBottomBlock := {|| (::W_ALIAS)->(DBSETORDER(::W_ORDER)), ;
                       (::W_ALIAS)->(dfBottom(::W_KEY, ::W_FILTER, ::W_BREAK)) }
      ::skipBlock     := {|nRec|_tbFSkip(self,nRec)}


      // ::skipBlock := {|n| (::W_ALIAS)->(DBSETORDER(::W_ORDER)), ;
      //                     (::W_ALIAS)->(dfSkip(n, ::W_FILTER, ::W_BREAK))}
   ELSE
      ::goTopBlock    := {||NIL }
      ::goBottomBlock := {||NIL }
      ::skipBlock     := {||NIL }
   ENDIF

   IF ::aPrevMsg == NIL .AND. ::UseMainStatusLine()
      ::aPrevMsg:= { ::getMsg(), ::getState(), ::getFormName() }
   ENDIF

   // nuovo stile Menu
   IF VALTYPE(::MenuStyle) == "O"
      ::oMenuStyle := ::MenuStyle
   ELSEIF ::MenuStyle != W_MENU_STYLE_SYSTEM
      ::oMenuStyle := dfSetMenuStyle(self, ::MenuStyle)
   ENDIF

   IF ::Status() == XBP_STAT_INIT

      IF ! lModal
         ::moveWithOwner := .F.
      ENDIF

      M_Cless()

      // Cerco e Creo il menu in form
      IF EMPTY(::aMenuInForm)
         // Creo il menu in form
         ::menuInFormScan(::W_MENUARRAY)
      ENDIF

      // la bitmap di sfondo non ä attiva per il multipagina
      // perchä non funziona bene.
      IF LEN(::W_PAGELABELS) <= 1

         xVal := ::bitmapBG
         DEFAULT xVal TO dfSet("XbaseBackgroundBmp")

         IF xVal != NIL .AND. S2IsNumber(xVal) .AND. ! EMPTY(xVal) .AND. ;
            ! dfIsTerminal()

            ::drawingArea:bitmap := VAL(xVal)
            ::drawingArea:setColorBG(XBPSYSCLR_TRANSPARENT)
         ENDIF
      ENDIF


      #ifdef _S2DEBUGTIME_
         S2DebugTimePush()
      #endif
         ::create(NIL, oWin)
      #ifdef _S2DEBUGTIME_
         S2DebugOutString(::formName+":CREATE"+STR(S2DebugTimePop()), .T. )
      #endif

      M_Normal()
   ELSEIF oWin != self .AND. oWin != NIL .AND. oWin != ::setOwner()
      M_Cless()

      #ifdef _S2DEBUGTIME_
         S2DebugTimePush()
      #endif
         ::configure(NIL, oWin, NIL, NIL, NIL, .F. )
      #ifdef _S2DEBUGTIME_
         S2DebugOutString(::formName+":CONFIGURE"+STR(S2DebugTimePop()), .T. )
      #endif
      M_Normal()
   ENDIF

   S2ObjSetColors( ::ctrlArea, ! ::hasBitmapBG(), ::W_COLORARRAY[AC_FRM_BACK], APPCOLOR_BACKGROUND )

   IF ::XbpPrev == NIL
      ::xbpPrev := {SetAppFocus(), oWin}

      IF ::UseMainToolbar()  // se deve usare toolbar del main
                             // salva e nasconde la toolbar precedente

         // simone 19/9/06 fix per errore se l'oggetto non ha il metodo getToolbar
         IF ! EMPTY(S2FormCurr()) .AND. ;
            IsMethod(S2FormCurr(), "getToolBar") .AND. ;
            ! EMPTY(S2FormCurr():getToolBar(.T.))

            AADD(::xbpPrev, S2FormCurr():getToolbar(.T.) )
            ATAIL(::xbpPrev):disable()
//            ATAIL(::xbpPrev):hide()
         ENDIF
      ENDIF
   ENDIF

   IF LEN(::aRealTime) > 0
      // Inserisco nel ciclo del realtime
      S2RealTimeAdd( self )
   ENDIF

   SetAppWindow(self)
   S2FormCurr(self)


   //SetAppFocus(self)

   oMenuS := ::getMenuStyleObj()
   IF !EMPTY(oMenuS)                     .AND. ;
      oMenuS:isDerivedfrom("MenuStyle1") .AND. ;
      !EMPTY(oMenuS:getSubMenuObj())     .AND. ;
      SetAppfocus() <> oMenuS:getSubMenuObj()
      Setappfocus( oMenuS:getSubMenuObj())
   ELSE 
      SetAppFocus(self)
   ENDIF 


//      oTree := owin:getMenuStyleObj()
//      oTree := oTree:getSubMenuObj()
//      SetAppfocus(oTree)




   IF lModal
      ::setModalState( XBP_DISP_APPMODAL )
   ENDIF

   IF oWin != NIL
      IF ::nOwnerFormDisplay == 1
         oWin:hide()

      // ELSEIF ::nOwnerFormDisplay == 2 // NON SUPPORTATO, VEDI METODO ::MOVE
      //    ::moveWithOwner := .F.
      ENDIF
   ENDIF

   // S2FormMain( self )

   // Da TBCONFIG.PRG
   // // Creo la label di save screen
   // IF oTbr:WOBJ_TYPE # W_OBJ_ARRAYBOX  .AND. ;  // List-BOX NON hanno
   //    ::WOBJ_TYPE # W_OBJ_BROWSEBOX          // SAVE-SCREEN
   //    DEFAULT ::W_SAVESCREENID TO dbScrLab()
   // ENDIF


#ifdef _S2DEBUGTIME_
   S2DebugOutString(::formName+":TBCONFIG"+STR(S2DebugTimePop()), .T. )
#endif
RETURN NIL

// Cerca i menu con attributo IN_FORM
METHOD S2Form:menuInFormScan(aMenu)
   LOCAL nInd := 0
   DEFAULT aMenu TO {}
   FOR nInd := 1 TO LEN(aMenu)

      IF aMenu[nInd][MNI_IN_FORM]
         ::setMenuInForm(aMenu[nInd][MNI_CHILD])
      ELSEIF ! EMPTY(aMenu[nInd][MNI_ARRAY])
         ::menuInFormScan(aMenu[nInd][MNI_ARRAY])
      ENDIF
   NEXT
RETURN self


METHOD S2Form:tbEnd
   LOCAL oFocus := ::XbpPrev[1]
   LOCAL oWin   := ::XbpPrev[2]

   IF LEN(::xbpPrev) >= 3
//      ATAIL(::xbpPrev):setParent():lockUpdate(.T.)
      IF ! EMPTY(::toolBarArea)
         ::toolBarArea:hide()
      ENDIF

      ATAIL(::xbpPrev):show()  // ripristina toolbar precedente
      IF ! ATAIL(::xbpPrev):isEnabled()
         ATAIL(::xbpPrev):enable()
      ENDIF
//      ATAIL(::xbpPrev):setParent():lockUpdate(.F.)
   ELSE
      IF ! EMPTY(::toolBarArea)
         ::toolBarArea:hide()
      ENDIF
   ENDIF

   // ripristina messaggi
   IF ::aPrevMsg != NIL
      ::setMsg( ::aPrevMsg[1] )
      ::setState( ::aPrevMsg[2] )
      ::setFormName( ::aPrevMsg[3] )
   ENDIF

   ::setModalState( XBP_DISP_MODELESS )

   IF LEN(::aRealTime) > 0
      S2RealTimeDel( self )
   ENDIF

   // IF oWin != NIL
   //    oWin:enable()
   // ENDIF

   IF oFocus != NIL
      SetAppFocus( oFocus )
   ENDIF

   ::hide()

   IF oWin != NIL
      SetAppWindow( oWin )

      IF ::nOwnerFormDisplay == 1
         oWin:show()
      ENDIF
   ENDIF

   S2FormCurr( oWin, .T. )

   ::XbpPrev := NIL

RETURN self

//  // Controllo dimensioni finestra cambiate
// METHOD S2Form:DOSDimChanged()
// RETURN !( ::aFormDim[1] == ::nRight - ::nLeft .AND. ;
//           ::aFormDim[2] == ::nBottom - ::nTop       )
//
// METHOD S2Form:updSize(aNew) //, aOld, aNew)
//    LOCAL aSize
//
//    // IF !( aOld[1] == aNew[1] .AND. aOld[2] == aNew[2] )
//
//       // FOR nInd := 1 TO LEN(aObj)
//       //
//       //    aSize := aObj[nInd]:currentSize()
//       //
//       //    aSize[1] += aNew[1] - aOld[1]
//       //    aSize[2] += aNew[2] - aOld[2]
//       //
//       //    aObj[nInd]:setSize(aSize)
//       // NEXT
//
//       // aSize := ::ctrlArea:currentSize()
//       //
//       // aSize[1] += aNew[1] - aOld[1]
//       // aSize[2] += aNew[2] - aOld[2]
//       //
//       // ::ctrlArea:setSize(aSize)
//       //
//       // aSize := ::MessageArea:currentSize()
//       //
//       // aSize[1] += aNew[1] - aOld[1]
//       // aSize[2] += aNew[2] - aOld[2]
//       //
//       // ::ctrlArea:setSize(aSize)
//
//       // aSize := ::drawingArea:currentSize()
//
//       // aNew := {aNew[1]-aOld[1], aNew[2]-aOld[2]}
//
//
//       aSize := ::ctrlArea:currentSize()
//       aSize[1] += aNew[1]
//       aSize[2] += aNew[2]
//       ::CtrlArea:SetSize(aSize)
//
//       //::CtrlArea:SetPos({0,::MessageHeight})
//
//       aSize := ::messageArea:currentSize()
//       aSize[1] += aNew[1]
//       ::messageArea:SetSize(aSize)
//
//       aSize := ::stateArea:currentPos()
//       aSize[1] += aNew[1]
//       ::stateArea:SetPos(aSize)
//
//    // ENDIF
//
//
// //    aSize := ::drawingArea:currentSize()
// //
// //    ::CtrlArea:create(NIL, NIL, {0,::MessageHeight}, ;
// //                      {aSize[1], aSize[2]-::MessageHeight})
// //
// //    ::MessageArea:create(NIL, NIL, {0,0}, ;
// //                         {aSize[1]-STATEAREA_WIDTH, ::MessageHeight}, ;
// //                         NIL, ::MessageHeight > 0)
// //    ::StateArea:create(NIL, NIL, {aSize[1]-STATEAREA_WIDTH,0}, ;
// //                       {STATEAREA_WIDTH, ::MessageHeight}, ;
// //                       NIL, ::MessageHeight > 0)
// //    //  // Aggiungo il menu PopUp
// //    // ::oPopUpMenu:create(self)
// //    // ::oPopUpMenu:addItem( { "Prova"  , {|| Alert("Prova") } } )
// //    //
// //    // FOR nInd := 1 TO LEN(::W_KEYBOARDMETHODS)
// //    //    aMtd := ::W_KEYBOARDMETHODS[nInd]
// //    //    ::oPopUpMenu:addItem( { aMtd[MTD_MSG]  , {|| EVAL(aMtd[MTD_BLOCK], ::cState) } } )
// //    // NEXT
// //
// //    // Creo le pagine
// //    IF LEN(::W_PAGELABELS) > 1
// //
// //       ::oMultiPage := S2MultiPage():New( ::CtrlArea )
// //
// //       FOR nInd := 1 TO LEN(::W_PAGELABELS)
// //          ::oMultiPage:AddPage(::W_PAGELABELS[nInd])
// //       NEXT
// //
// //       ::oMultiPage:Create()
// //
// //    ENDIF
//
// RETURN self
//
// // Aggiorna le dimensioni della finestra
// METHOD S2Form:DOSDimUpdate()
//    LOCAL aDelta
//    LOCAL aDim
//    LOCAL oPos
//
//
//    aDelta := { (::nRight - ::nLeft) - ::aFormDim[1],  ;
//                (::nBottom - ::nTop) - ::aFormDim[2]   }
//
//    oPos := PosCvt():new(aDelta[1], aDelta[2])
//
//    // Aggiorno dimensioni finestra
//    // ----------------------------
//
//    aDim := ::currentSize()
//
//    aDim[1] += oPos:nXWin
//    aDim[2] += oPos:nYWin
//
//    ::SetSize(aDim)
//
//    // Aggiorno posizione finestra
//    // ---------------------------
//
//    aDim := ::currentPos()
//
//    aDim[2] -= oPos:nYWin
//
//    ::SetPos(aDim)
//
//    ::updSize({oPos:nXWin, oPos:nYWin})
//
//    ::aFormDim := { ::nRight - ::nLeft, ::nBottom - ::nTop }
//
// RETURN

//Maudp-LucaC XL 3878 21/03/2013 Aggiunto lForce per fare il refresh forzato sulle listbox (attualmente lo faceva solo in presenza di tag)
//METHOD S2Form:tbDisItm(cGrp)
METHOD S2Form:tbDisItm(cGrp,lForce)
   LOCAL lCless := .F.
   LOCAL oTBParent
   LOCAL nN, oObj

   IF ! ::status() == XBP_STAT_CREATE
      RETURN NIL
   ENDIF

// Commentato perchä fa dei FLASH terribili
// #ifdef _XBASE15_
//    ::nDispLoop++
//
//    IF ::nDispLoop==1
//       ::lockUpdate(.T.)
//    ENDIF
// #endif
   // IF ::lDispLoop
   //    RETURN NIL
   // ENDIF
   //
   // ::lDispLoop := .T.


   // LOCAL oXbp := NIL
#ifdef _S2DEBUGTIME_
   S2DebugTimePush()
#endif
   DEFAULT cGrp TO "#"
   DEFAULT lForce TO .F.
   // IF ::DOSDimChanged()
   //    ::DOSDimUpdate()
   // ENDIF

   cGrp := UPPER(cGrp)

   IF cGrp == "#MENU#"
      // ricreo il menu
      ::MenuRefresh()
   ENDIF

   IF cGrp == "#" .OR. cGrp == "#TOOLBAR#"

      IF ! ::isVisible() .AND. ::XbpPrev != NIL .AND. !EMPTY(::XbpPrev[1])
         M_Cless(::XbpPrev[1])
         lCless := .T.
      ENDIF

      IF cGrp == "#"
//Maudp-LucaC XL 3878 21/03/2013 Aggiunto lForce per fare il refresh forzato sulle listbox (attualmente lo faceva solo in presenza di tag)
         //AEVAL(::objCtrl, {|obj| obj:DispItm() })
         FOR nN := 1 TO LEN(::objCtrl)
             oOBJ := ::objCtrl[nN]
             oOBJ:DispItm(lForce)
         NEXT

      ENDIF

      IF ::UseMainToolBar()
         IF ::toolBarArea  == NIL
            dfSetMainWin():getToolbar(.T.):disable()
         ELSE
            //dfSetMainWin():lockUpdate(.T.)
            dfSetMainWin():getToolbar(.T.):hide()

            IF VALTYPE(::getToolbar(.F.)) == "O" // correzione simone 9/11/06 la dfGetW() dava errore runtime
               //Modificato Luca il 29/09/2006
               /////////////////////////////////////////
               oTBParent := dfSetMainWin():getToolbar(.F.)

               ::getToolbar(.F.):SetParent(oTBParent:setParent()  )
               ::getToolbar(.F.):SetSize  (oTBParent:currentSize())
               ::getToolbar(.F.):Setpos   (oTBParent:currentpos() )
               /////////////////////////////////////////
            ENDIF
            ::toolBarArea:show()
            //dfSetMainWin():lockUpdate(.F.)
         ENDIF
      ELSE
         IF ::toolBarArea != NIL
            ::toolBarArea:show()
         ENDIF
      ENDIF


      // simone 1/6/05
      // mantis 0000760: abilitare nuovi stili per i controls
      IF ::aChgParents == NIL // faccio solo 1 volta
         // cambio il parent dei control interni ai groupbox
         ::AdjustParents()
      ENDIF

      IF ::aOrigPosSize == NIL
         ::aOrigPosSize := { ACLONE(::currentPos()), ACLONE(::currentSize()), ACLONE(::drawingArea:currentSize()) }
      ENDIF


      //IF ! ::isVisible() .AND. ::XbpPrev != NIL .AND. !EMPTY(::XbpPrev[1])
      IF lCless
         M_Normal(::XbpPrev[1])
      ENDIF
   ELSE
//Maudp-LucaC XL 3878 21/03/2013 Aggiunto lForce per fare il refresh forzato sulle listbox (attualmente lo faceva solo in presenza di tag)
      //AEVAL(::objCtrl, {|obj| IIF(obj:IsIdGrp(cGrp), obj:DispItm(), NIL) })
      FOR nN := 1 TO LEN(::objCtrl)
          oOBJ := ::objCtrl[nN]
          IF oObj:IsIdGrp(cGrp)
             oObj:DispItm(lForce)
          ENDIF 
      NEXT
   ENDIF

// SD 10/5/07 faccio il display solo se passo "#"
// altimenti ho dei casini se ha autoresize
// e ci sono listbox nel form (perche il display del listbox
// richiama la tbDisItm() prima che sia visibile )
//   IF cGrp == "#" .OR. ! ::isVisible()
   IF cGrp == "#"
      IF ! dfSet("XbaseCheckMenu") == "NO"
         // Abilito/disabilito il menu e la toolbar
         IF ::ShowToolBar
            ::toolBarArea:dispItm()
         ENDIF

      ENDIF

      ::setTitle(::W_TITLE)

      IF ! ::isVisible()

         // Simone 20/giu/03
         // Inizializzo adesso perche i GET sono creati allo SHOW
         // Simone 13/6/05
         // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
         IF ::isAutoResize() .AND. ! ::hasScrollBars()

            // simod 23/4/07 miglioramenti per resize
            // in caso ancora non abbia fatto lo eseguo perchä ä necessario farlo prima del :setResizeInit()
            IF ::aChgParents == NIL // faccio solo 1 volta
               // cambio il parent dei control interni ai groupbox
               ::AdjustParents()
            ENDIF

            ::ctrlArea:SetResizeInit()
         ENDIF

         ::show()
      ENDIF

   ENDIF

   ::ShowState()

   #ifdef _S2DEBUGTIME_
      S2DebugOutString(::formName+":TBDISITM"+STR(S2DebugTimePop()), .T. )
   #endif

// Commentato perchä fa dei FLASH terribili
// #ifdef _XBASE15_
//    ::nDispLoop--
//
//    IF ::nDispLoop==0
//       ::lockUpdate(.F.)
//       ::drawingArea:invalidateRect()
//    ENDIF
// #endif

   // ::lDispLoop := .F.
RETURN NIL

METHOD S2Form:tbDisRef(cGrp)
   LOCAL nN, oObj

   IF ! ::status() == XBP_STAT_CREATE
      RETURN NIL
   ENDIF

   DEFAULT cGrp TO "#"

   cGrp := UPPER(cGrp)

   IF cGrp == "#"
      //AEVAL(::objCtrl, {|obj| obj:DispItm() })
      FOR nN := 1 TO LEN(::objCtrl)
          oOBJ := ::objCtrl[nN]
          IF (oObj:isDerivedFrom("S2ListBox") .OR.; 
             oObj:isDerivedFrom("S2ComboBox")   )  .AND.; 
             oOBJ:oLsb:W_LOADARRAYFUNCTION <> NIL 
             //IF oOBJ:oLsb:WOBJ_TYPE == W_OBJ_ARRAYBOX
             //   oOBJ:oLsb:W_AI_LENGHT  := 1
             //ENDIF 
             oOBJ:oLsb:W_OBJREFRESH := .T.
          ENDIF 
          oOBJ:DispItm()
      NEXT

   ELSE
      cGrp := dfChkGrp(cGrp)
      //AEVAL(::objCtrl, {|obj| IIF(obj:IsRefrGrp(cGrp), obj:DispItm(), NIL) })
      FOR nN := 1 TO LEN(::objCtrl)
          oOBJ := ::objCtrl[nN]
          IF oObj:IsRefrGrp(cGrp)
             IF (oObj:isDerivedFrom("S2ListBox")  .OR.; 
                 oObj:isDerivedFrom("S2ComboBox")      )  .AND.; 
                 oOBJ:oLsb:W_LOADARRAYFUNCTION <> NIL 
                 //IF oOBJ:oLsb:WOBJ_TYPE == W_OBJ_ARRAYBOX
                 //   oOBJ:oLsb:W_AI_LENGHT  := 1
                 //ENDIF 
                 oOBJ:oLsb:W_OBJREFRESH := .T.
             ENDIF 
             oOBJ:DispItm()
          ENDIF 
      NEXT
   ENDIF
RETURN NIL

METHOD S2Form:UpdControl(cGrp)
   LOCAL nN, oObj
   IF ! ::status() == XBP_STAT_CREATE
      RETURN NIL
   ENDIF

   DEFAULT cGrp TO "#"

   cGrp := UPPER(cGrp)

   IF cGrp == "#"
      //AEVAL(::objCtrl, {|obj| obj:UpdControl() })
      FOR nN := 1 TO LEN(::objCtrl)
          oOBJ := ::objCtrl[nN]
          oOBJ:UpdControl() //DispItm()
      NEXT

   ELSE
      //AEVAL(::objCtrl, {|obj| IIF(obj:IsIdGrp(cGrp), obj:UpdControl(), NIL) })
      FOR nN := 1 TO LEN(::objCtrl)
          oOBJ := ::objCtrl[nN]
          IF oObj:IsRefrGrp(cGrp)
             oOBJ:UpdControl() //DispItm()
          ENDIF 
      NEXT

   ENDIF
RETURN NIL

METHOD S2Form:tbDisCal(cGrp)
   LOCAL nInd, oObj, aId := {}, aCompRef
   LOCAL lCalcLoop := .F.

   IF ! ::status() == XBP_STAT_CREATE
      RETURN NIL
   ENDIF


   IF ! lCalcLoop
      // Evito il loop
      lCalcLoop := .T.

      IF aCompRef == NIL

         aCompRef := {}

         aID := dfStr2Arr(cGrp, "-")

         FOR nInd := 1 TO LEN(aID)
            IF ! EMPTY(aID[nInd]) .AND. ! aID[nInd] $ "--"
               oObj := ::SearchObj( aID[nInd] )[1]
               IF oObj != NIL .AND. ASCAN( aCompRef, {|x|x==oObj} ) == 0
                  AADD(aCompRef, oObj)

                  EVAL(oObj:bCompExp)
                  oObj:DispItm()

                  // ha un gruppo di ricalcolo
                  IF oObj:isDerivedFrom("S2CompGrp") .AND. ;
                     oObj:hasCompGrp()
                     oObj:CompExpExe()
                  ENDIF
               ENDIF
            ENDIF
         NEXT

      ENDIF

      lCalcLoop := .F.
   ENDIF

RETURN NIL

// SkipFocus() dovrebbe funzionare. da provare per bene
METHOD S2Form:SkipFocus( n, nPos, lAllPage )
   LOCAL nIni
   LOCAL nMax := LEN(::objCtrl)
   LOCAL nVer := IIF(n > 0, 1, -1)
   LOCAL lLoop := .T.
   LOCAL nPage := ::tbPgActual()

   // Simone 01/04/2005
   // mantis 0000665: Run time Error nel Designer
   IF nMax <= 0
      RETURN self
   ENDIF

   DEFAULT nPos TO ::FindFocusPos()
 //  DEFAULT lAllPage TO .F.       // Per default cerca il control
                                 // successivo/precedente solo
                                 // nella pagina corrente

//Maudp-LucaC 15/04/2013 XL 3905 Se sono su una maschera in DE_STATE_INK e tutti i control sono disabilitati
//se clicco sopra un control, poi passa da qua e visto che la ::FindFocusPos() torna 0, si alluppa nel ciclo sotto
   ///////////////////////////
   //Visto con analisi su Extra con M .dp. il 19/04/2013 
   IF nPos <= 0
      RETURN self
   ENDIF
   ///////////////////////////



   // Simone 24/3/03 GERR 3653
   // se provengo da un control su pag.0 messo nella 2^/3^.. pagina
   // cerco solo nella pagina corrente
#ifdef _PAGE_ZERO_STD_
   IF (nPos >= 1 .AND. nPos <= LEN(::objCtrl)) .AND. ;
      (EMPTY(::objCtrl[nPos]:aPage0) .OR. ::objCtrl[nPos]:nPage==1)
#else
   IF (nPos >= 1 .AND. nPos <= LEN(::objCtrl)) .AND. ;
      (::objCtrl[nPos]:nPage != 0)
#endif
      DEFAULT lAllPage TO ::lAllPage
   ELSE
      DEFAULT lAllPage TO .F.
   ENDIF

   nIni := nPos
   DO WHILE lLoop

      nPos += nVer

      IF nPos == nIni
         // Ha giÖ fatto il giro di tutti i control e
         // non ha trovato nessun control che possa ricevere il
         // focus: ESCE
         lLoop := .F.

      ELSE

         IF nPos < 1
            nPos := nMax
         ELSEIF nPos > nMax
            nPos := 1
         ENDIF

#ifdef _PAGE_ZERO_STD_
         IF ::objCtrl[nPos]:canSetFocus() .AND. ;
            (lAllPage .OR. ::objCtrl[nPos]:nPage == nPage)
#else
         IF ::objCtrl[nPos]:canSetFocus() .AND. ;
            (lAllPage .OR. ::objCtrl[nPos]:nPage == 0 .OR. ;
             ::objCtrl[nPos]:nPage == nPage)
#endif

            n -= nVer
            IF n == 0
               // Ha trovato il control che puï prendere il
               // focus: ESCE

               // Simone 11/2/03 GERR 3653
               ::SetCtrlFocus(nPos)

               lLoop := .F.
            ENDIF
         ENDIF
      ENDIF

   ENDDO

RETURN self

// Imposta il focus sull'oggetto attivo (in ::W_CURRENTGET) o sul primo oggetto
// che puï prendere il focus
METHOD S2Form:SetFocus()
   LOCAL nInd
   LOCAL oMenuS
   LOCAL oXbp
   LOCAL lFound   := .F.
   LOCAL lAllPage := dfSet(AI_MULTIPAGE_FIND_CTRL)
   LOCAL nCurr    := 0
   LOCAL oCurr
   nInd := 0
   // Imposta il focus

   IF ::W_CURRENTGET >= 1 .AND. ::W_CURRENTGET <= LEN(::objCtrl) .AND. ;
      ::objCtrl[::W_CURRENTGET]:CanSetFocus()

      nCurr := ::W_CURRENTGET
      oCurr := ::objCtrl[::W_CURRENTGET]

      // (::oMultiPage == NIL .OR. ;
      //  ::objCtrl[::W_CURRENTGET]:nPage == ::oMultiPage:ActualPage()) .AND. ;

      IF ! ::objCtrl[::W_CURRENTGET]:HasFocus()
         //::SetCtrlFocus(::W_CURRENTGET)
         ::objCtrl[::W_CURRENTGET]:SetFocus()

         // Simone 13/6/05
         // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
         IF ::hasScrollBars()
            ::ctrlArea:forceVisible( ::objCtrl[::W_CURRENTGET] )
         ENDIF
      ENDIF

   ELSE

      DO WHILE ++nInd <= LEN(::objCtrl)
         // oXbp := ::drawingArea:ChildList()[nInd]
         oXbp := ::objCtrl[nInd]

         IF oXbp:CanSetFocus()

            // Simone 25/7/06
            // mantis 0001094: Se in un una form multipagina sull prima p non ho nessun campo in Get
            // allora all'apertura viene aperta sempre la seconda pagina
#ifdef _PAGE_ZERO_STD_
            IF lAllPage            .OR. ;
               ::oMultiPage == NIL .OR. ;
               oXbp:nPage == ::oMultiPage:ActualPage()

#else
            IF lAllPage            .OR. ;
               ::oMultiPage == NIL .OR. ;
               oXbp:nPage == 0     .OR. ;
               oXbp:nPage == ::oMultiPage:ActualPage()
#endif
               ::SetCtrlFocus(nInd)

               lFound := .T.
            ENDIF
            // fine mantis 1094
            //-----------------------------------

            EXIT

         ENDIF
      ENDDO

      IF ! lFound
         ::W_CURRENTGET := 0

         //////////////////////////////////////////////////////////////////////////
         //Luca  03/2012
         //////////////////////////////////////////////////////////////////////////
         //Correzione Focus Menu in chiusura finestre nel caso di menu con treeview
         //SetAppFocus(self)

         //IF S2FormCurr() == dfSetMainWin() 
            oMenuS := ::getMenuStyleObj()
            IF !EMPTY(oMenuS)                     .AND. ;
               oMenuS:isDerivedfrom("MenuStyle1") .AND. ;
               !EMPTY(oMenuS:getSubMenuObj())     //.AND. ;
               //SetAppfocus() <> oMenuS:getSubMenuObj()
               Setappfocus( oMenuS:getSubMenuObj())
            ELSE 
               SetAppFocus(self)
            ENDIF 
         //ELSE 
         //   SetAppFocus(self)
         //ENDIF 
         //////////////////////////////////////////////////////////////////////////
         //////////////////////////////////////////////////////////////////////////
      ENDIF
   ENDIF
RETURN

// Apre sempre il primo menu, dovrebbe aprire il cMenu
METHOD S2Form:MenuOpen(cMenu)
   LOCAL lOk := .F.
   LOCAL aItm
   LOCAL nPos
   LOCAL nAct := 0

   LOCAL nMenu := 1

   IF ::oMenuBar != NIL .AND. nMenu >= 1 .AND. nMenu <= ::oMenuBar:numItems()
      aItm := ::oMenuBar:getItem(nMenu)
      IF VALTYPE(aItm) == "A" .AND. VALTYPE(aItm[1]) == "O"

         IF VALTYPE(aItm[1]:title) == "C" .AND. ;
            (nPos := AT(STD_HOTKEYCHAR, aItm[1]:title)) > 0

            nAct := dbAct2Ksc("A_"+LOWER(SUBSTR(aItm[1]:title, nPos+1, 1)))
         ENDIF

         IF nAct > 0
            PostAppEvent(xbeP_User+EVENT_OPENMENU_EXEC, nAct, NIL, self)
         ELSE
            aItm[1]:popUp(::cState, ::drawingArea, ;
                          {0,::drawingArea:currentSize()[2]} )

         ENDIF

         lOk := .T.
      ENDIF
   ENDIF
RETURN lOk

METHOD S2Form:_tbInk( lTbGet )

   LOCAL cCho := ""
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL nEvent2, mp12, mp22, oXbp2
   // LOCAL aMnuArr := NIL //, bBlock
   LOCAL oMenu, nInd
   LOCAL oObj, bEval
   LOCAL nTimeOut
   LOCAL nWaitUser := dfSet(AI_GETWARNING)
   LOCAL oFocus
   // LOCAL mpQueue := {}
   // LOCAL nKsc
   // LOCAL cAct

   IF ! ::status() == XBP_STAT_CREATE

      // Imposto ESC
      dbActSet(xbeK_ESC)
      RETURN ACT
   ENDIF

   // #ifdef _S2DEBUG_
   //    LOCAL aR := S2GetFreeRes95()
   //    ::setTitle( STR(aR[1],3,0)+"% "+STR(aR[2],3,0)+"% "+STR(aR[3], 3,0)+"% - "+::W_TITLE)
   // #endif

   ACT := "   "
   A   := 0
   SA  := ""

   // DO WHILE nEvent <> xbeP_Close
   //    nEvent := AppEvent( @mp1, @mp2, @oXbp )
   //    oXbp:HandleEvent(nEvent, mp1, mp2)
   // ENDDO

   ::SetFocus()

   IF ! EMPTY(::W_MENUPOS) .AND. EMPTY(::aMenuInForm)   // Apro il menu
      dbAct2Kbd("smp")
   ENDIF

   DO WHILE .T.
      // IF LEN(mpQueue) > 0
      //    nEvent := xbeP_User+EVENT_KEYBOARD
      //    mp1 := mpQueue
      //    ADEL(mp1, 1)
      //    ASIZE(mp1, LEN(mp1)-1)
      //
      // ELSE
      //    nEvent := AppEvent( @mp1, @mp2, @oXbp )
      // ENDIF

      ////////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////////
      IF df_IS_TIMEOUT_ACTIVE() 
         nTimeOut := dfSet(AI_GETTIMEOUT)
         IF VALTYPE(::bTimeOutCodeBlock) == "B"
            nTimeOut := EVAL(::bTimeOutCodeBlock, SetAppFocus() )
            IF VALTYPE(nTimeOut) != "N"
               nTimeOut := NIL
            ENDIF 
         ENDIF 
      ELSE 
         nTimeOut := NIL
      ENDIF
      ////////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////////

      //nEvent := dfAppEvent( @mp1, @mp2, @oXbp, NIL, self )
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp, nTimeOut, self )

      #ifdef _S2DEBUG_
         S2DebugOut(oXbp, nEvent, mp1, mp2)
      #endif

      // Attiva il menu simulando ALT_n dove n ä la lettera attiva del
      // caption del menu da aprire
      IF nEvent == xbeP_User+EVENT_OPENMENU_EXEC
         ::handleEvent(xbeP_Keyboard, mp1, NIL)
         LOOP
      ENDIF

      // IF nEvent == xbeP_User+EVENT_KEYBOARD
      //
      //    IF VALTYPE(mp1) == "A"
      //       mpQueue := mp1
      //    ELSE
      //       mpQueue := {mp1}
      //    ENDIF
      //
      //
      //    IF LEN(mpQueue) == 0
      //       LOOP
      //    ENDIF
      //
      //    cAct := mpQueue[1]
      //
      //    nEvent := NIL
      //    mp1 := NIL
      //    mp2 := NIL
      //    oXbp := self
      //
      //    DO CASE
      //       CASE cAct == "tab"
      //          mp1 := ::findFocusPos()
      //          IF mp1 > 0
      //             nEvent := xbeP_KillInputFocus
      //             oXbp := ::objCtrl[mp1]
      //          ENDIF
      //          mp1 := NIL
      //
      //       CASE cAct == "smp"
      //          nEvent := xbeP_User+EVENT_OPENMENU
      //          mp1    := 1
      //
      //       OTHERWISE
      //          nKsc:= dbAct2Ksc(cAct)
      //          IF nKsc > 0
      //             nEvent := xbeP_User+EVENT_KEYBOARD
      //             mp1    := nKsc
      //          ENDIF
      //    ENDCASE
      // ENDIF


      IF (nEvent == xbeP_User+EVENT_KEYBOARD) .OR. ;
         (nEvent == xbeP_Keyboard)

         IF nEvent == xbeP_Keyboard

            // Simone 23/04/2004 GERR 3833
            // Toglie dalla coda dei messaggi i messaggi keyboard doppi
            dfIgnoreKbdEvent(mp1, mp2, oXbp)
            /*
            // Toglie dalla coda dei messaggi i messaggi doppi
            DO WHILE .T.
               nEvent2 := dfNextAppEvent(@mp12, @mp22, @oXbp2)

               IF nEvent2 == nEvent .AND. mp12 == mp1 .AND. mp22 == mp2 .AND. ;
                  oXbp2 != oXbp

                  AppEvent(@mp12, @mp22, @oXbp2)
               ELSE

                  EXIT
               ENDIF

            ENDDO
            */
         ELSE

            oXbp   := SetAppFocus()
            IF EMPTY(oXbp)
               oXbp := self
            ENDIF

            nEvent := xbeP_Keyboard
         ENDIF


         // Imposta variabili pubbliche ACT, A e SA
         dbActSet( mp1 )

         IF ACT == "A01"              .AND. ;
            ! TYPE("dfHotFun") == "U" .AND. ;   // Se ä definita la variabile dfHotFun
            dfFun2Do(M->dfHotFun)               // la eseguo
            LOOP
         ENDIF

         IF ! TYPE("BackFun") == "U" // Se ä definita la variabile BackFun
            dfFun2Do(M->BackFun)     // la eseguo
         ENDIF

         IF ACT=="A04"
            S2QuitApplication()
         ENDIF

         #ifdef _EVAL_
            // Controllo scadenza DEMO, il nome funzione
            // non fa pensare al controllo demo
            // inoltre controllo che il valore di ritorno e il parametro
            // per referenza siano messi per bene cosi sono sicuro che la
            // funzione _dfStringExe() non sia stata modificata dall'utente

            IF (_dfStringExe(, , @oXbp2) + 5 < SECONDS()) .OR. ;
               (! oXbp2 == CHR(107)+CHR(53)+LEFT("e5df", 1)+STR(0, 1, 0)+CHR(1+105)+UPPER(CHR(100+6))+CHR(110-4))
               S2RealTimeDelAll()
               CLOSE ALL
               QUIT
            ENDIF
         #endif

         // IF ACT == "tab"
         //    //::skipFocus(1)
         //    LOOP
         // ENDIF

         // IF ::HandleShortCut( mp1 )
         //    LOOP
         // ENDIF

         // Confronto con _XbpMle ä ok sia per XbpMle che per _XbpMle
         IF SetAppFocus():className() $ "S2BrowseBox,S2ArrayBox,S2ComboBox,_XbpMle"
            oObj := SetAppFocus()

            IF SetAppFocus():className() $ "_XbpMle"
               oObj := oObj:setParent()
               IF ! oObj:className() == "S2EditBox"
                  oObj := NIL
               ENDIF
            ENDIF

            // simone 13/3/09
            // mantis mantis 0002071: il tasto associato a listbox nelle form per ins/mod/canc non controlla lo stato del form 
            // correzione per i tasti associati a browsebox 
            // non controllano lo stato della form nel blocco WHEN 
            // ma usano sempre "DE_STATE_INK"
            //
            // simone 16/3/09 questo FIX ä commentato perche
            // questa modifica comporta di RIVEDERE TUTTI I BROWSE/LISTBOX
            // perchä alcuni tasti vengono disattivati ma non dovrebbe
            // inoltre se chiamata da menu popup NON passa di qui,  
            // quindi continua a ignorare lo stato della form, andrebbe
            // modificato il punto di richamo da menu popup (tasto destro mouse)
            //IF ! EMPTY(oObj) .AND. oObj:handleAction( ACT, ::cState )
            IF ! EMPTY(oObj) .AND. oObj:handleAction( ACT)
               LOOP
            ENDIF

         ELSEIF ::handleAction( ACT )
            LOOP
         ENDIF

         // IF SetAppFocus():handleAction( ACT, ::cState ) .OR. ;
         //    ::handleAction( ACT, ::cState )
         //
         //    LOOP
         // ENDIF

         IF lTbGet .AND. ACT $ "wri,new,esc"
            // Se provengo da tbGet e ho premuto wri,new,esc
            // non eseguo il menu associato ma vado avanti

         ELSE

            cCho := dfMenuSCut(::W_MENUARRAY, ACT)

            IF ! cCho == ""
               EXIT
            ENDIF
         ENDIF

         IF ! ACT $ "uar,dar,lar,rar,tab,Stb"

            IF ACT == "esc"
               EXIT
            ENDIF

            IF ACT $ "wri,new"

               // ------------------------------------------
               // Simone 21/08/2000
               // Questa riga attiva il menu della form
               // in caso si prema il tasto Ok invece che
               // F10... non ricordo perchä ä stata messa
               // quindi la tolgo sperando non dia problemi
               //
               // ------------------------------------------
               // oXbp:HandleEvent(nEvent, mp1, mp2)
               // ------------------------------------------

               EXIT
            ENDIF

            IF ::handleShortCut( ACT )
               EXIT
            ENDIF

         ENDIF

         IF ! EMPTY(::oMenuInForm)

            // Tolgo il capture mouse altrimenti non
            // vengono processati i tasti ALT-xxx per attivare
            // il menu
            ::oMenuInForm:captureMouse(.F.)

            ::oMenuInForm:HandleEvent(nEvent, mp1, mp2)

            LOOP
         ENDIF

      ELSEIF nEvent == xbeP_User+EVENT_REALTIME .AND. oXbp:isVisible()
         oXbp:realTime()

      ELSEIF nEvent == xbeP_User+EVENT_OPENMENU
         ::MenuOpen(mp1)

      ELSEIF nEvent == xbeP_User+EVENT_MENU_SELECTION
         IF VALTYPE(mp1) $ "CM"
            cCho := mp1
         ELSEIF oXbp:isDerivedFrom( "S2FormMenuItm" )
            cCho := oXbp:cChoice
         ELSE
            mp1 := ::MenuFind(oXbp, mp1)

            IF mp1 != NIL
               cCho := mp1[MNI_CHILD]
            ENDIF

            // Faccio riaprire il menu
            //::W_MENUPOS := cCho

         ENDIF

         ACT := "rep"
         EXIT

      ELSEIF nEvent == xbeP_Activate .AND. oXbp:isDerivedFrom("_PushButton") // className() == "S2PushButton"

         // Esco solo se ä un pulsante su un FORM
         // NON esco se ä un pulsante di lookup all'interno di un GET
         dfPushAct()
         oXbp:HandleEvent(nEvent, mp1, mp2)
         dfPopAct()
         EXIT

      ELSEIF nEvent == xbeP_KillDisplayFocus
         ::W_CURRENTGET := ::FindFocusPos()
      ELSEIF nEvent == xbeP_SetDisplayFocus
         // simone 24/6/06
         // modifica per correzione gestione focus fra le finestre
         // con main menu non modale
         IF ! EMPTY(oXbp) .AND. VALTYPE(oXbp)=="O" .AND. oXbp == self
            ::SetFocus()
         ENDIF

      ////////////////////////////////////////////////////////////////
      //Inserito Luca 09/04/2008 per gestione time out
      //Se vai in time out 
      ELSEIF nEvent == xbe_None  
         IF nTimeOut != NIL .AND. ! UPPER(M->EnvId ) $ "MENU,QIUT,"+ALLTRIM(dfSetMain())
            IF !dfUserEventWait(nWaitUser)
               dbAct2Kbd("esc")
            ENDIF 
         ENDIF 
      ////////////////////////////////////////////////////////////////
      ENDIF

      //Inserito Luca 31/03/2008
      IF !EMPTY(oXbp)
         oXbp:HandleEvent(nEvent, mp1, mp2)
      ENDIF
      // Repaint
      oFocus := SetAppFocus()
      IF ACT == "rep" .AND. isMethod(oFocus, "DispItm")
         oFocus:DispItm()
         ACT := "   "
      ENDIF

   ENDDO

   ::W_CURRENTGET := ::FindFocusPos()

RETURN cCho

//////////////////////////////////
//Luca 23/11/2011 XLS  2739,1932
//Correzione sul lostfocus sui campi GET e Memo: non vengono memorizzati i valori digitati se si preme un pulsante 
//sulla toolbar nel caso di toolbar attiva solo sulla Mainform.
//////////////////////////////////
/*
METHOD S2Form:KillInputFocus()
  //LOCAL oOBJCTRL := ::getObjCtrl()
  //LOCAL nGet     := ::W_CURRENTGET
  //LOCAL oFocus   := SetAppFocus()
  IF ::W_CURRENTGET >= 1 .AND. ::W_CURRENTGET <= LEN(::objCtrl)
     ::objCtrl[::W_CURRENTGET]:handleEvent(xbeP_KillInputFocus, NIL, NIL)
  ENDIF
RETURN .T.
*/
//////////////////////////////////
//////////////////////////////////


// METHOD S2Form:Keyboard(nKey)
//    IF ACT == "Ctb"
//       ::tbPgLoop(1)
//    ENDIF
// RETURN self

// Rimappata in S2FormFu.XPP per vedere di fare obj pió piccolo
// METHOD S2Form:handleShortCut( cAct )
// RETURN __S2FORM_handleShortCut( cAct, self )

METHOD S2Form:handleShortCut( cAct )
   LOCAL oXbp
   LOCAL nInd
   // LOCAL nMax := LEN(::drawingArea:ChildList())
   LOCAL nMax := LEN(::objCtrl)

   nInd := 0
   DO WHILE ++nInd <= nMax

      // oXbp := ::drawingArea:ChildList()[nInd]

      oXbp := ::objCtrl[nInd]

#ifdef _PAGE_ZERO_STD_
      IF oXbp:isShortCut( cAct ) .AND. ;
         oXbp:nPage == ::tbPgActual() .AND. ;
         oXbp:canSetFocus()
#else
      IF oXbp:isShortCut( cAct ) .AND. ;
         (oXbp:nPage == 0 .OR. oXbp:nPage == ::tbPgActual()) .AND. ;
         oXbp:canSetFocus()
#endif

         oXbp:setFocus()

         IF oXbp:isDerivedFrom( "_Pushbutton") //"XbpPushbutton")
            PostAppEvent( xbeP_Activate,,, oXbp)
            /////////////////////////////////////////////////////////////
            // Workaround per mantis 1655
            //Non prende l'evento <xbeP_Activate> !!
            IF oXbp:isDerivedFrom( "S2PushButtonX")
               RETURN  .F.
            ENDIF 
            /////////////////////////////////////////////////////////////
         ENDIF

         EXIT

      ENDIF

      // IF oXbp:ClassName() == "S2PushButton" .AND. ;
      //    nAsc == oXbp:GetShortCut() .AND. ;
      //    oXbp:isEnabled() .AND. oXbp:isVisible()
      //
      //    EVAL(oXbp:activate)
      //    EXIT
      // ENDIF
   ENDDO

RETURN nInd <= nMax

METHOD S2Form:getActiveCtrl()
   LOCAL nPos := ::FindFocusPos()
   LOCAL oRet
   IF nPos > 0
      oRet := ::objCtrl[nPos]
   ENDIF
RETURN oRet


METHOD S2Form:FindFocusPos()
   LOCAL nPos := 0
   LOCAL nInd := 0
   LOCAL nMax := LEN(::objCtrl)

   DO WHILE nPos == 0 .AND. ++nInd <= nMax

      IF ::objCtrl[nInd]:hasFocus()
         nPos := nInd
      ENDIF

   ENDDO

RETURN nPos

METHOD S2Form:tbGet(bDcc, cState, lCheckEsc)
   LOCAL cCho := ""
   LOCAL cMenu := ::W_MENUPOS

   ::W_MENUPOS := "" // Evito l'eventuale apertura del menu

   // LOCAL oObj

   DEFAULT cState TO DE_STATE_MOD
   DEFAULT bDcc   TO {|| .T. }

   ::cState := cState
   ::ShowState()

   DO WHILE .T.

      cCho := ::_tbink( .T. )                             //  Inkey di tastiera ( vedere Norton Guide )

      IF ACT == "esc"
         EXIT

      ELSEIF ACT $ "new,wri"

         // Tutti gli oggetti editabili devono avere
         // nel ::killInputFocus() il ::getData()
         // ----------------------------------------
         IF ::W_CURRENTGET >= 1 .AND. ::W_CURRENTGET <= LEN(::objCtrl)
            ::objCtrl[::W_CURRENTGET]:handleEvent(xbeP_KillInputFocus, NIL, NIL)
         ENDIF

       //   // Imposto nelle variabili il valore del buffer
       //   // Se la variabile ä su Pag0 lo imposto solo
       //   FOR nInd := 1 TO LEN(::editCtrl)
       //      oObj := ::editCtrl[nInd][1]
       //      IF oObj:nPage == 0
       //         IF ASCAN(aPage0, {|x|x==oObj}) == 0
       //            oObj:GetData()
       //            AADD(aPage0, oObj)
       //         ENDIF
       //      ELSE
       //         oObj:GetData()
       //      ENDIF
       //
       //   NEXT

       // -------------------------------------------------------------
       // Riga sottostante disabilitata il
       // 15/12/99 perchä se ho un campo in GET non visibile
       // e non editabile e in qualche parte del sorgente lo imposto con un
       // valore, facendo il GetData() lo reimposto con quelle che c'ä nel
       // buffer, cioä viene AZZERATO!
       //
       // AEVAL(::editCtrl, {|aObj| aObj[1]:GetData() })

         IF ::ChkGetCtrl() .AND. EVAL(bDcc)
            EXIT
         ENDIF
      ENDIF

      IF !Empty(cCho)                               //  Esegue azione sul menu
         EVAL( dfMenuBlock(::W_MENUARRAY,cCho) )    //  dfMenuBlock() ritorna il code block associato
      END
   ENDDO

   ::cState := DE_STATE_INK
   ::W_MENUPOS := cMenu

   // Imposto il focus sulla form... perchä se subito dopo la tbGet
   // ho una dfYesNo viene attivato in GET l'ultimo control
   // che aveva il focus.
   SetAppFocus( self )

RETURN ! ACT == "esc"

METHOD S2Form:ChkGetCtrl()
   LOCAL lOk := .T.
   LOCAL nInd := 0
   LOCAL nMax := LEN(::editCtrl)
   LOCAL oXbp := NIL

   DO WHILE lOk .AND. ++nInd <= nMax
      IF ::editCtrl[nInd][3]
         oXbp := ::editCtrl[nInd][1]
         IF oXbp:CanSetFocus() // .AND. oXbp:PreGet()
            lOk := oXbp:ChkGet()
         ENDIF
      ENDIF
   ENDDO

   IF ! lOk .AND. ! oXbp:hasFocus()
      ::SetCtrlFocus(::editCtrl[nInd][2])
   ENDIF
RETURN lOk


METHOD S2Form:tbGetTop(lCurrPage)
   LOCAL nInd
   LOCAL oXbp
   LOCAL nChkPage := 1
   LOCAL lFound := .F.

   IF ! ::status() == XBP_STAT_CREATE
      RETURN NIL
   ENDIF


   DEFAULT lCurrPage TO .F.

   IF ::oMultiPage != NIL

      IF lCurrPage
         nChkPage := ::oMultiPage:ActualPage()
      ELSEIF ::oMultiPage:ActualPage() != nChkPage
         ::oMultiPage:showPage(nChkPage)
         // ::tbDisItm()
      ENDIF

   ENDIF

   // Imposta il focus sul primo oggetto di tipo S2GET
   nInd := 0

   DO WHILE ++nInd <= LEN(::editCtrl)
      oXbp := ::editCtrl[nInd][1]

#ifdef _PAGE_ZERO_STD_
      IF oXbp:nPage == nChkPage .AND. oXbp:CanSetFocus() // .AND. oXbp:PreGet()
#else
      IF (oXbp:nPage == 0 .OR. oXbp:nPage == nChkPage) .AND. oXbp:CanSetFocus() // .AND. oXbp:PreGet()
#endif
         ::W_CURRENTGET := ::editCtrl[nInd][2]
         lFound := .T.
         // IF ! oXbp:hasFocus()
         //    ::SetCtrlFocus(::editCtrl[nInd][2])
         // ENDIF
         EXIT
      ENDIF
   ENDDO

   IF ! lFound
      nInd := 0
      DO WHILE ++nInd <= LEN(::objCtrl)
         oXbp := ::objCtrl[nInd]

#ifdef _PAGE_ZERO_STD_
         IF oXbp:nPage == nChkPage .AND. oXbp:CanSetFocus() // .AND. oXbp:PreGet()
#else
         IF (oXbp:nPage==0 .OR. oXbp:nPage == nChkPage) .AND. oXbp:CanSetFocus() // .AND. oXbp:PreGet()
#endif
            ::W_CURRENTGET := nInd
            lFound := .T.
            EXIT
         ENDIF
      ENDDO

   ENDIF

   ::setFocus()

RETURN NIL

METHOD S2Form:SetCtrlFocus(nInd)
   LOCAL n
   LOCAL oObj

#ifdef _PAGE_ZERO_STD_
   IF ::oMultiPage != NIL .AND. ;
      ::objCtrl[nInd]:nPage != ::oMultiPage:ActualPage()
#else
   IF ::oMultiPage != NIL .AND. ;
      ::objCtrl[nInd]:nPage != 0 .AND. ;
      ::objCtrl[nInd]:nPage != ::oMultiPage:ActualPage()
#endif

      ::oMultiPage:ShowPage(::objCtrl[nInd]:nPage)
   ENDIF

   // se ä in un groupbox lo illumino
//   IF ! EMPTY( ::aChgParents )
//     oObj := ::objCtrl[nInd]
//     n := ASCAN(::aChgParents, {|x|x[1] == oObj})
//     IF n > 0
//        oObj:setParent():headerColorBG := GRA_CLR_YELLOW
//        oObj:setParent():invalidateRect()
//     ENDIF
//   ENDIF

   ::objCtrl[nInd]:setFocus()
   ::W_CURRENTGET := nInd

   // Simone 13/6/05
   // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
   IF ::hasScrollBars()
      ::ctrlArea:forceVisible( ::objCtrl[nInd] )
   ENDIF
RETURN self

METHOD S2Form:tbGetGoto(cId)
   LOCAL aObj

   IF ! ::status() == XBP_STAT_CREATE
      RETURN self
   ENDIF

   aObj := ::searchObj(cId)

   // Modificato il 20/12/99 per
   // maggiore compatibilitÖ con DOS... controllare che non dia
   // problemi!
   // ---------------------------------------------------------
   // IF aObj[1] != NIL .AND. aObj[1]:canSetFocus()
   //    IF ! aObj[1]:HasFocus()
   //       ::setCtrlFocus(aObj[2])
   //    ENDIF
   // ENDIF
   // ---------------------------------------------------------

//Maudp 28/06/2012 Deve riassegnare sempre la W_CURRENTGET, altrimenti rischia di lasciarla a 0 e creare successivi problemi di focus
/*
   IF aObj[1] != NIL .AND. ! aObj[1]:HasFocus()
      ::W_CURRENTGET := aObj[2]
*/
   IF aObj[1] != NIL 
      ::W_CURRENTGET := aObj[2]

      IF !aObj[1]:HasFocus()
#ifdef _PAGE_ZERO_STD_
      IF ::oMultiPage != NIL .AND. ;
         aObj[1]:nPage != ::oMultiPage:ActualPage()
#else
      IF ::oMultiPage  != NIL .AND. ;
         aObj[1]:nPage != 0   .AND. ;
         aObj[1]:nPage != ::oMultiPage:ActualPage()
#endif

         ::oMultiPage:ShowPage(aObj[1]:nPage)
      ENDIF
      ::setFocus()
   ENDIF
   ENDIF

RETURN self

METHOD S2Form:SearchObj( cId )
   LOCAL oRet := NIL
   LOCAL oObj := NIL
   LOCAL nInd := 0

   IF ! EMPTY(cId) .AND. ! cId $ "--"

      cId := UPPER(cId)

      FOR nInd := 1 TO LEN(::objCtrl)
         oObj := ::objCtrl[nInd]

         IF oObj:IsId(cId)
            oRet := oObj
            EXIT
         ENDIF
      NEXT
   ENDIF

   IF oRet == NIL
      nInd := 0
   ENDIF

RETURN {oRet, nInd}


METHOD S2Form:MenuCreate( oMenu, aArr, lAllTrim, lMenuInForm )
   LOCAL nInd := 0
   LOCAL oSubMenu
   LOCAL cPrompt
   LOCAL aLabel
   LOCAL oOBJM
//   LOCAL lDisableSubMenu

   DEFAULT lAllTrim TO .F.
   DEFAULT lMenuInForm TO .T.

   // Simone 22/3/06
   // mantis 0001021: Implementare menu standard/submenu a schede stile outlook oppure tree
   // stile con main menu std e submenu a toolbar
   // disabilita il sottomenu standard se stile sottomenu a toolbar
//   lDisableSubMenu := ::MenuStyle == W_MENU_STYLE_ONLYSUBTOOLBAR .OR. ;
//                      ::MenuStyle == W_MENU_STYLE_ONLYTOOLBAR

   FOR nInd := 1 TO LEN(aArr)

      aLabel := aArr[nInd]

      IF aLabel[MNI_TYPE] == MN_LINE
         oMenu:addItem( MENUITEM_SEPARATOR )
      ELSE

         //Luca 03/06/2013  Mantis 2224
         //::lShowDisableMenu 
         // Inserisco solo le voci visibili
         IF aLabel[MNI_SECURITY] == MN_ON .OR. (aLabel[MNI_SECURITY] == MN_OFF .AND. ::lShowDisableMenu)
         //IF aLabel[MNI_SECURITY] == MN_ON 
            ///////////////////////////////////////////////////////////////////////////
            //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012 
            //cPrompt := ::ChgHotKey(aLabel[MNI_LABEL])
            cPrompt := aLabel[MNI_LABEL]
            IF VALTYPE(cPrompt) == "B"
               cPrompt := EVAL(cPrompt)
            ENDIF 
            cPrompt := ::ChgHotKey(Alltrim(cPrompt))
            ///////////////////////////////////////////////////////////////////////////

            IF ! EMPTY(aLabel[MNI_SACTION])
               cPrompt += CHR(9)+aLabel[MNI_SACTION]
            ENDIF

            IF lAllTrim
               cPrompt := ALLTRIM(cPrompt)
            ENDIF

            // ha un sottomenu ?
            // Non aggiungo il menu se ä definito come "MenuInForm"
            IF EMPTY(aLabel[MNI_ARRAY]) .OR. ;
               ::lSubMenuHidden         .OR. ;
               (lMenuInForm .AND. ASCAN(::aMenuInForm, {|x| x==aLabel[MNI_CHILD]}) > 0)
               //Modifica per gestire correttamente item di men˘ quando vi Ë solo una voce 
               IF !EMPTY(aLabel[MNI_BLOCK]) .AND. EMPTY(::aMenuInForm) .AND. EMPTY(aLabel[MNI_ARRAY])
                   oOBJM    := oMenu:addItem( {cPrompt, aLabel[MNI_BLOCK] }, aLabel[MNI_IMAGES] )
               ELSE 
                   oOBJM    := oMenu:addItem( {cPrompt}, aLabel[MNI_IMAGES]  )
               ENDIF 
               //oOBJM:id := aLabel[MNI_CHILD]

            ELSE

               oSubMenu := S2Menu():new( oMenu )
               oSubMenu:create()
               oSubMenu:title := IIF(lAllTrim, ALLTRIM(cPrompt), cPrompt)

               oSubMenu:Id    := aLabel[MNI_CHILD]

               //oSubMenu:itemSelected := {|nItm, uNIL, oXbp | PostAppEvent(xbeP_User+EVENT_MENU_SELECTION, nItm, uNil, oXbp) }
               //oSubMenu:itemSelected := {|nItm, uNIL, oXbp | ::ExecMenuItem(nItm, oXbp) }
               oSubMenu:itemSelected := {|nItm, uNIL, oXbp | ::ExecSubMenuItem(nItm, oXbp, oSubMenu:Id) }
               //oSubMenu:ItemMarked   := {|nItm, uNIL, oXbp | uNil := ::Menufind(oXbp, nItm), ;


               oSubMenu:ItemMarked   := {|nItm, uNIL, oXbp | uNil := ::SubMenufind(oXbp,nItm, oSubMenu:Id), ;
                                                             IIF(uNil==NIL, NIL, dfUsrMsg(uNil[MNI_HELP])) }

               ::MenuCreate( oSubMenu, aLabel[MNI_ARRAY] )

               oMenu:addItem( {oSubMenu}, aLabel[MNI_IMAGES]  )

            ENDIF

            IF aLabel[MNI_SECURITY] == MN_OFF  
               oMenu:disableItem(oMenu:numItems())
            ENDIF
         ELSE 
            IF aLabel[MNI_SECURITY] == MN_HIDDEN .OR. aLabel[MNI_SECURITY] == MN_SECRET
               //oMenu:addItem( MENUITEM_SEPARATOR )
            ENDIF
         ENDIF

      ENDIF

   NEXT

RETURN

METHOD S2Form:MenuFind(oXbp, nItm)
   LOCAL aMnuArr
   LOCAL aMenuArray := ::W_MENUARRAY

IF VALTYPE(oXbp) == "O" .AND. VALTYPE(nItm) == "N"
   IF oXbp:ClassName()=="S2Menu"

      // In caso venga dal menu PopUp modificato
      IF ! EMPTY(::aPopUpMenu) .AND. ::IsPopUp(oXbp)
         nItm -= ::nPopUpMenuStart
         aMnuArr := ::aPopUpMenu
      ELSE
         // 7/7/99 in GIOIA in QuitExe() ä successo che dfMenuItm non trovasse
         // l'elemento e quindi ci fosse un runtime error, la linea
         // sottostante ä stata modificata come segue
         // aMnuArr := dfMenuItm(aMenuArray, oXbp:ID)[MNI_ARRAY]

         aMnuArr := dfMenuItm(aMenuArray, oXbp:ID)
      ENDIF


   #ifdef _S2DEBUG_
      IF EMPTY(aMnuArr)
         dbMsgErr("S2FORM:TBINK-ERROR, menu non trovato: "+dfAny2Str(oXbp:ID))
      ELSE
         aMnuArr := aMnuArr[MNI_ARRAY]
      ENDIF
   #else
      IF ! EMPTY(aMnuArr)
         aMnuArr := aMnuArr[MNI_ARRAY]
      ENDIF
   #endif

   ELSE
      aMnuArr := aMenuArray
   ENDIF

   aMnuArr := ::_MenuFind(aMnuArr, nItm)
ENDIF

RETURN aMnuArr

//////////////////////////////////////////
//////////////////////////////////////////
METHOD S2Form:SubMenuFind(oXbp, nItm, nTestID)
   LOCAL aMnuArr , aMnuSub
   LOCAL aMenuArray := ::W_MENUARRAY
   LOCAL nPOS
   LOCAL cMenuItem
   LOCAL aSub 
   LOCAL cItm

   IF oXbp:ClassName()=="S2Menu"
      IF VALTYPE(nItm)== "N"
         cItm := S2STRforMenu(nItm)//STR(nItm,1,0)

         IF VALTYPE(oXbp:ID) == "C"

            nPOS := ASCAN(aMenuArray, {|x| x[1] == oXbp:ID}) 

            IF nPOS > 0                  
               aMnuSub := aMenuArray[nPOS]
            ELSE 
               aMnuSub := dfMenuItm(aMenuArray, oXbp:ID )
            ENDIF 

            IF !EMPTY(aMnuSub)  .AND. ;
               LEN(aMnuSub)>=4  .AND. ;
               LEN(aMnuSub[4]) >= nItm

               aSub       := aMnuSub[4]
               IF VALTYPE(aSub) == "A" .AND. LEN(aSub)>=nItm .AND.;
                  LEN(aSub[nItm])>= 1
                  //////////////////////////////////////////////////////
                  cMenuItem  := ::_FinSub(aSub,nItm) //  aSub[nItm][1] 
                  //////////////////////////////////////////////////////
               ELSE 
                  cMenuItem  := oXbp:ID+ cItm
               ENDIF 
            ELSE 
               cMenuItem  := oXbp:ID+ cItm
            ENDIF

            aMnuArr := dfMenuItm(aMenuArray, cMenuItem)
         ELSE 

            cMenuItem := S2STRforMenu(oXbp:ID)+nItm //STR(oXbp:ID,1,0)+ cItm
            aMnuArr   := dfMenuItm(aMenuArray, cMenuItem)

         ENDIF 
      ELSE 
         IF VALTYPE(nItm)== "C"
            cMenuItem := nItm
            aMnuArr   := dfMenuItm(aMenuArray, cMenuItem)
         ENDIF 
      ENDIF 
   ENDIF
   IF EMPTY(aMnuArr) .OR. LEN(aMnuArr) < MNI_LEN
      aMnuArr := NIL
   ENDIF 
RETURN aMnuArr


               // oSubMenu:ItemHighLighted := {|nItm, uNIL, oXbp | uNil := dfMenuItm(::W_MENUARRAY, oXbp:ID), ;
               //                                                  IIF(EMPTY(uNil), NIL, ;
               //                                                      (uNil:=::MenuFind(uNil, nItm),;
               //                                                       IIF(uNil==NIL, NIL, ;
               //                                                      dfUsrMsg(uNil[MNI_HELP]))))}


// Salto le voci di menu inserite in array ma non nel Menu
// -------------------------------------------------------
METHOD S2Form:_MenuFind(aMnuArr, nMenu)
   LOCAL nI     := 0
   LOCAL aLabel

   DO WHILE nMenu > 0 .AND. ;
            ++nI <= LEN(aMnuArr)

      aLabel := aMnuArr[nI]
      IF aLabel[MNI_TYPE] == MN_LINE      .OR. ;
         aLabel[MNI_SECURITY] == MN_ON    .OR. ;
         aLabel[MNI_SECURITY] == MN_OFF
         nMenu--
      ENDIF
   ENDDO

   // Se non ho trovato torno NIL
   IF nI > LEN(aMnuArr)
      aLabel := NIL
   ENDIF

RETURN aLabel

// Controllo se la scelta del menu proviene da popUp o da menuBar()
METHOD S2Form:isPopUp(oXbp)
   LOCAL lRet := .F.
   LOCAL aLoop := {}    // Serve per evitare una eventuale ricorsione
   LOCAL nLoop := 2000  // Serve per evitare una eventuale ricorsione


   DO WHILE .T.

      IF EMPTY(oXbp) .OR. oXbp == ::oMenuBar .OR. oXbp == self .OR. ;
         ASCAN(aLoop, oXbp) != 0 .OR. --nLoop < 0
         EXIT
      ENDIF

      IF oXbp == ::oPopUpMenu
         lRet := .T.
         EXIT
      ENDIF

      AADD(aLoop, oXbp)

      oXbp := oXbp:setParent()

   ENDDO
RETURN lRet


METHOD S2Form:ChgHotKey(cPrompt)
RETURN S2HotCharCvt(cPrompt)

METHOD S2Form:SetMsg( cMsg )
   IF ::UseMainStatusLine() // usa statusline del main
      RETURN dfSetMainWin():setMsg(cMsg)
   ENDIF

   IF cMsg != NIL
      cMsg := dbMMrg(STRTRAN(cMsg,dfHot()))
   ENDIF

   IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
      RETURN ::MessageArea:SetText( cMsg )
   ENDIF
RETURN ::statusLine:set(1, cMsg )

METHOD S2Form:GetMsg()
   IF ::UseMainStatusLine() // usa statusline del main
      RETURN dfSetMainWin():getMsg()
   ENDIF

   IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
      RETURN ::MessageArea:GetText()
   ENDIF
RETURN ::statusLine:get(1)


METHOD S2Form:SetFormName( cMsg )
   LOCAL c
   IF ::UseMainStatusLine() // usa statusline del main
      RETURN dfSetMainWin():setFormName(cMsg)
   ENDIF

   IF ! ::showNameArea
      RETURN ""
   ENDIF

   IF !EMPTY(cMSG)
      c    := cMsg
      cMSG := LEFT(c, 1) + LOWER(RIGHT(c, LEN(c)-1))
   ENDIF
   IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
      RETURN ::NameArea:SetText( cMsg )
   ENDIF
RETURN ::statusLine:set(3, cMsg )

METHOD S2Form:GetFormName()
   IF ::UseMainStatusLine() // usa statusline del main
      RETURN dfSetMainWin():getFormName()
   ENDIF

   IF ! ::showNameArea
      RETURN ""
   ENDIF

   IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
      RETURN ::NameArea:GetText()
   ENDIF
RETURN ::statusLine:get(3)

METHOD S2Form:ShowState()
RETURN ::SetState( dbDeState(::cState) )

METHOD S2Form:SetState( cMsg )
   IF ::UseMainStatusLine() // usa statusline del main
      RETURN dfSetMainWin():setState(cMsg)
   ENDIF

   IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
      RETURN ::StateArea:SetText( cMsg )
   ENDIF
   ::statusLine:set(2, cMsg)
   // workaround: ricalcola dimensioni
   ::statusLine:organize( ::statusLine:currentSize()[1] )
RETURN .T.

METHOD S2Form:GetState()
   IF ::UseMainStatusLine() // usa statusline del main
      RETURN dfSetMainWin():getState()
   ENDIF

   IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
      RETURN ::StateArea:GetText()
   ENDIF
RETURN ::statusLine:get(2)

METHOD S2Form:tbPgActual()
   LOCAL nRet := 1

   IF ::oMultiPage != NIL
      nRet := ::oMultiPage:ActualPage()
   ENDIF
RETURN nRet

METHOD S2Form:tbPgGoto(nPage)
   IF ::oMultiPage != NIL
      ::oMultiPage:ShowPage(nPage)

      // Imposta il focus sul primo GET della pagina
      ::tbGetTop(.T.)
      ::tbPgRefresh()
      ::setFocus()
   ENDIF
RETURN

METHOD S2Form:tbPgSkip(nPage)
   IF ::oMultiPage != NIL
      DEFAULT nPage TO 1

      ::oMultiPage:SkipPage(nPage)

      // Imposta il focus sul primo GET della pagina
      ::tbGetTop(.T.)
      ::tbPgRefresh()
      ::setFocus()
   ENDIF
RETURN

METHOD S2Form:tbPgLoop(nPage)
   IF ::oMultiPage != NIL
      ::oMultiPage:LoopPage(nPage)

      // Imposta il focus sul primo GET della pagina
      ::tbGetTop(.T.)
      ::tbPgRefresh()
      ::setFocus()
   ENDIF
RETURN

METHOD S2Form:tbPgMax()
   LOCAL nRet := 1
   IF ::oMultiPage != NIL
      nRet := ::oMultiPage:NumPages()
   ENDIF
RETURN nRet

METHOD S2Form:tbPgRefresh()
   LOCAL nCurrPage := ::tbPgActual()
#ifdef _PAGE_ZERO_STD_
   AEVAL(::objCtrl, {|obj| IIF(obj:nPage == nCurrPage, obj:DispItm(), NIL) })
#else
   AEVAL(::objCtrl, {|obj| IIF(obj:nPage == 0 .OR. obj:nPage== nCurrPage, obj:DispItm(), NIL) })
#endif
RETURN

// Aggiornamento dei control in realtime
METHOD S2Form:realTimeUpdate(nPage)
   nPage++
   IF nPage >= 1 .AND. nPage <= LEN(::aRealTime)
      AEVAL(::aRealTime[nPage], {|oObj| oObj:dispItm() })
   ENDIF
RETURN self

METHOD S2Form:realTime()

IF ! ::lRealTimeStop
   // Aggiornamento del realtime su pagina 0 e su pagina attuale
   ::RealTimeUpdate( 0 )
   ::RealTimeUpdate( ::tbPgActual() )
ENDIF
RETURN

// Rimappata in S2FormFu.XPP per vedere di fare obj pió piccolo
// METHOD S2Form:_tbUpdExp(cGroup, cID)
//   __S2FORM_tbUpdExp(cGroup, cID, self)
// RETURN

METHOD S2Form:_tbUpdExp(cGroup, cID)
   IF ASCAN(::aCompGrp, {|a| a[1]==cGroup .AND. a[2]==cID  }) == 0
      AADD(::aCompGrp, {cGroup, cID})
   ENDIF
RETURN self

METHOD S2Form:__tbUpdExp(cGroup, cID)
   LOCAL nPos, aCtrl := ::objCtrl, oObj, aActCTRL

   IF ! EMPTY(cGroup)
      cGroup := UPPER("-" +dfChkGrp(cGroup) +"-")
      FOR nPos := 1 TO LEN(aCTRL)

         oObj := aCTRL[nPos]

         aActCTRL := oObj:aCtrl

         DO CASE
            CASE aActCTRL[FORM_CTRL_TYP]==CTRL_GET .AND.;
                 "-" +UPPER(aActCTRL[FORM_CTRL_ID])$cGroup

                 oObj:AddCtrl( cId )

                 aActCTRL[FORM_GET_COMPREF] := oObj:cCompRef

                 // aActCTRL[FORM_GET_COMPREF] += cID
                 // aActCTRL[FORM_GET_COMPREF] := ;
                 //               "-" +dfChkGrp(aActCTRL[FORM_GET_COMPREF]) +"-"

            CASE aActCTRL[FORM_CTRL_TYP]==CTRL_FUNCTION .AND.;
                 "-" +UPPER(aActCTRL[FORM_CTRL_ID])$cGroup

                 oObj:AddCtrl( cId )

                 aActCTRL[FORM_FUN_COMPREF] := oObj:cCompRef

                 // aActCTRL[FORM_FUN_COMPREF] += cID
                 // aActCTRL[FORM_FUN_COMPREF] := ;
                 //               "-" +dfChkGrp(aActCTRL[FORM_FUN_COMPREF]) +"-"


            CASE aActCTRL[FORM_CTRL_TYP]==CTRL_LISTBOX .AND.;
                 "-" +UPPER(aActCTRL[FORM_CTRL_ID])$cGroup
                 aActCTRL[FORM_LIST_OBJECT]:W_CTRL2CALC += cID
                 aActCTRL[FORM_LIST_OBJECT]:W_CTRL2CALC := ;
                   "-" +dfChkGrp(aActCTRL[FORM_LIST_OBJECT]:W_CTRL2CALC) +"-"

            CASE oObj:isDerivedFrom("S2CompGrp") .AND.;  // SD 16/7/07 altri control con gruppi ricalcolo
                 "-" +UPPER(aActCTRL[FORM_CTRL_ID])$cGroup

                 oObj:AddCtrl( cId )

         ENDCASE
      NEXT
   ENDIF

RETURN

METHOD S2Form:setTitle(cTit)
  DEFAULT cTit TO ::W_TITLE
RETURN ::XbpDialogBmpMenu:setTitle(dbMMrg(STRTRAN(cTit,dfHot())))

METHOD S2Form:W_TITLE(cTit)
   LOCAL cPrec := ::W_TITLE

   IF ! cTit == NIL
      ::W_TITLE := cTit
      ::setTitle(cTit)
   ENDIF

RETURN cPrec

METHOD S2Form:adjustCoords()
   LOCAL oOwner := ::setOwner()
   LOCAL aFree
   LOCAL aSize := ::currentSize()
   LOCAL nY

   // Se proviene da una form che ha il menu in form
   // cerco di allineare la finestra nello spazio rimasto
   // libero dal menu in form...
   IF ! EMPTY(oOwner)                .AND. ;
      oOwner:isDerivedFrom("S2Form") .AND. ;
      ! EMPTY(oOwner:oMenuInForm)

      aFree := oOwner:GetCtrlArea( .T. ):currentSize()
      aFree[1] -= oOwner:MenuInFormWidth
      IF aFree[1] >= aSize[1]
         aFree := oOwner:currentPos()

         // 3=dimensione del bordo sinistro..
         aFree[1] += oOwner:MenuInFormWidth + 3
         // Nessuna modifica in verticale
         aFree[2] := ::currentPos()[2]
         ::setPos(aFree)
      ENDIF
   ENDIF

   // Se la finestra non entra nello schermo verticalmente
   // la allineo in alto
   nY := ::currentPos()[2]+::currentSize()[2]
   nY := S2AppDesktopSize(.F.)[2] - nY
   IF nY < 0
      ::setPos({::currentPos()[1], ::currentPos()[2]+nY})
   ENDIF
RETURN self

// Simone 13/3/06
// mantis 0001003: migliorare resize nelle form
METHOD S2Form:resizeDrawingArea(o, n)
   LOCAL nXDiff := n[1]-o[1]
   LOCAL nYDiff := n[2]-o[2]
   LOCAL aPos
   LOCAL aSz
   LOCAL obj
   LOCAL aOri
   LOCAL oToolbar

   // simone 12/02/07
   // mantis 0001209: la toolbar si sposta se si ridimensiona una form e la toolbar S sul menu principale (MDI)
   // (aggiunto IF ! ::UseMainToolbar() )
   IF ! ::UseMainToolbar()
      obj    := ::getToolBar()
      IF ! EMPTY(obj)
         aPos   := obj:currentPos()
         aSz    := obj:currentSize()
         aSz[1] += nXDiff
         aPos[2]+= nYDiff    
         obj:setPosAndSize(aPos, aSz, .F.)
         //Correzione Mantis 2144 del 10/01/2011
         //obj:invalidateRect()
         //obj:Configure()
         oToolbar := OBJ
      ENDIF
    ENDIF

   obj    := ::oMenuInForm
   IF ! EMPTY(obj)
      aPos   := obj:currentPos()
      aSz    := obj:currentSize()
      aSz[2] += nYDiff
//      aPos[2]+= nYDiff
      //Mantis 2168 Luca 19/10/2011
      //dava runtime error perche non va passato aSz
      //obj:setSize(aPos, aSz, .F.)
      //Set pos ä inutile in quanto rimane sempre nella solita posiuzione
      //obj:setPos(aPos, .F.)
      obj:setSize(aSz, .F.)
   ENDIF

   IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
      obj    := ::MessageArea
      IF ! EMPTY(obj)
         aPos   := obj:currentPos()
         aSz    := obj:currentSize()
         aSz[1] += nXDiff
         obj:setPosAndSize(aPos, aSz, .F.)
      ENDIF
      obj    := ::NameArea
      IF ! EMPTY(obj)
         aPos   := obj:currentPos()
         aSz    := obj:currentSize()
         aPos[1] += nXDiff
         obj:setPosAndSize(aPos, aSz, .F.)
      ENDIF

      obj    := ::StateArea
      IF ! EMPTY(obj)
         aPos   := obj:currentPos()
         aSz    := obj:currentSize()
         aPos[1] += nXDiff
         obj:setPosAndSize(aPos, aSz, .F.)
      ENDIF
   ENDIF

   obj := ::CtrlArea

   aSz := obj:currentSize()
   aSz[1] += nXDiff
   aSz[2] += nYDiff 

   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //Correzione Luca del 02/08/2011: Nel casi in cui la form non abbia toolbar si ottengono errori di resize. Segnalazione 1228
   //IF dfSetMainWin() == Self
   IF .T.
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //aOri    := ::drawingArea:Currentsize()
      aOri    := ::Currentsize()
      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //Correzione Luca del 02/08/2011: Nel casi in cui la form non abbia toolbar si ottengono errori di resize. Segnalazione 1228
      //aOri[2] -= IIF(::UseMainToolbar() .OR. EMPTY(::getToolBar()) , 0, ::toolBarHeight) + ::MessageHeight +33//53
      aOri[2] -= IIF(::UseMainToolbar() .OR. EMPTY(::getToolBar()) , 0, ::toolBarHeight) + ::MessageHeight +43//33//53
      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      IF !::W_MENUHIDDEN
         aOri[2] -= MENUBAR_HEIGHT
      ENDIF 


      obj:setSize(aOri, .F.)
   ELSE
      obj:setSize(aSz, .F.)
   ENDIF

   obj := ::oMultiPage
   IF ! EMPTY(obj)
      aSz := obj:currentSize()
      aSz[1] += nXDiff
      aSz[2] += nYDiff
      obj:setSize(aSz, .F.)
   ENDIF

   //_VDBWaitAllEvents(self)

   ::drawingArea:invalidateRect()


   IF oToolbar != NIL
      _VDBWaitAllEvents(self)
      //::getToolBar(.T.):Configure()
      //::getToolBar(.F.):Configure()
      oToolbar:Configure()
   ENDIF 

RETURN self

// Simone 16/3/06
// mantis 0000051: poter personalizzare la toolbar
METHOD S2Form:addToolItem(cID, xImg, cPrompt, bExec, bWhen, bRun, cToolTip, nPos)
   LOCAL aTbr
   LOCAL xPrompt
   LOCAL b

   DEFAULT bWhen      TO {||.T.}
   DEFAULT ::aToolbar TO {}
   aTbr := ::aToolbar

// ToolBar standard piu icone per cambio utente e data
// Questa funzione imposta la proprieta oWin:aToolBar con un array
//    cosi formato:
// aArr[1] = puo essere uno fra:
//               - codeblock da eseguire
//               - codice dell'azione del menu (esempio "add", "mod")
//               - stringa "*--" per un separatore
// aArr[2] = Array di 2 elementi il primo e l'ID nel file .RES
//           dell'icona attiva, il secondo e l'ID dell'icona disattivata
// aArr[3] = codeblock che indica quando l'icona e attiva (si puo
//           lasciare a NIL)
// aArr[4] (opzionale) = messaggio visualizzato quando il mouse "sosta"
//           sull'icona
   IF VALTYPE(bRun)=="B"
      b := bExec
      bExec :={|mp1, mp2, oBtn| IIF(EVAL(bRun), EVAL(b, mp1, mp2, oBtn), .F.) }
   ENDIF

   IF EMPTY(xImg)
      xPrompt := cPrompt
   ELSE
       // Simone 28/8/06
       // mantis 0001130: dare possibilit‡ di impostare icone toolbar disabilitate/focused
       //         standard      disabled                  focused
       //          ||              ||                        ||
       //          \/              \/                        \/
      xPrompt := {xImg, dfGetRelatedImage(1, xImg), dfGetRelatedImage(2, xImg)}
   ENDIF
   DEFAULT xPrompt TO { TOOLBAR_HELP_H, TOOLBAR_HELP_H }
//   aImg := {TOOLBAR_ADD      , TOOLBAR_ADD      }
   AADD(aTbr, {bExec, xPrompt, bWhen, cToolTip, cID}, nPos)
RETURN self

METHOD S2Form:addToolSeparator(nPos)
   LOCAL aTbr

   DEFAULT ::aToolbar TO {}
   aTbr := ::aToolbar

   AADD(aTbr, {"---"}, nPos)
RETURN self

// FA CASINO! NON SO PERCHE SPOSTA SEMPRE LA SECONDA FINESTRA E VA IN LOOP
// METHOD S2Form:move(aOld, aNew)
//    LOCAL oOwner
//    LOCAL aDelta
//
//    //::XbpDialogBmpMenu:move(aOld,aNew)
//
//    IF ::nOwnerFormDisplay == 2
//
//       oOwner := ::setOwner()
//
//       IF ! EMPTY(oOwner) .AND. ;
//          oOwner:isDerivedFrom("XbpDialog") .AND. ;
//          ! oOwner == self
//
//          // Sposto il Owner
//          aDelta := oOwner:currentPos()
//          aDelta[1] += aNew[1]-aOld[1]
//          aDelta[2] += aNew[2]-aOld[2]
//          oOwner:setPos(aDelta)
//
//       ENDIF
//    ENDIF
//
// RETURN self

//RESIZE
STATIC CLASS ResizeStatic FROM XbpStatic, ResizeCenter
PROTECTED:
   INLINE METHOD resizeArea()
   RETURN self

EXPORTED:
   VAR aResizeList

   INLINE METHOD SetResizeInit()
      IF ! EMPTY(::aResizeList)
         // Simone 13/3/06
         // mantis 0001003: migliorare resize nelle form
         ::resizeInit(::aResizeList[1], ::aResizeList[2])
      ENDIF
   RETURN self
ENDCLASS
//RESIZE

// simone 9/3/06
// mantis 0001001: con tema XP attivato i groupbox standard non visualizzano i control interni
//////////////////////////////////////////////////////////////////////
/// <summary>
///  <para>
///    Check whether themes are enabled for the application. In this
///    case, UI elements are rendered using special visual styles.
///    This function returns TRUE if the operation system supports
///    themes and if themes are enabled for the application. If the
///    value FALSE is passed in parameter "bAppOnly", the function
///    checks whether themes are supported and enabled in Control
///    Panel.
///
///    Note: o Themes have been introduced with Windows XP
///          o To have Xbase Parts rendered using the visual styles
///            defined in a theme, a manifest file must be defined
///            for the application!
///  </para>
/// </summary>
/// <returns>
/// </returns>
//////////////////////////////////////////////////////////////////////
STATIC FUNCTION _IsThemeActive( bOnlyApp )

 LOCAL bReturn := .F.
 LOCAL nHandle
 LOCAL cBuf


   DEFAULT bOnlyApp TO .T.

   nHandle := DLLCall("KERNEL32.DLL", DLL_STDCALL, "GetModuleHandleA", "uxtheme.dll" )
   IF nHandle == 0
      RETURN .F.
   ENDIF

   bReturn := (DLLCall(nHandle, DLL_STDCALL, "IsThemeActive") != 0)

   IF bReturn == .F. .OR. bOnlyApp == .F.
      RETURN bReturn
   ENDIF

   bReturn := (DLLCall(nHandle, DLL_STDCALL, "IsAppThemed") != 0)
   IF bReturn == .F.
      RETURN .F.
   ENDIF

   // So far, we've determined that the system
   // supports themes and has them enabled for
   // the application. Now check whether a
   // a manifest is present for the app. To do
   // that, we'll check whether Common Controls
   // version 6.0 or better is loaded by the
   // app's process
   cBuf    := L2Bin(20) + Replicate(chr(0),16)
   nHandle := DLLCall("KERNEL32.DLL", DLL_STDCALL, "GetModuleHandleA", "comctl32.dll" )

   IF nHandle == 0
      RETURN .F.
   ENDIF

   bReturn := .F.
   IF DLLCall(nHandle, DLL_STDCALL,"DllGetVersion",@cBuf) == 0
      IF Bin2L(SubStr(cBuf,5,4)) > 5
         bReturn := .T.
      ENDIF
   ENDIF

RETURN bReturn

STATIC FUNCTION _IsSamePage(obj1, obj2)
RETURN obj1:nPage==obj2:nPage
//RETURN obj1:nPage==0 .OR. obj2:nPage==0 .OR. obj1:nPage==obj2:nPage



///////////////////////////////////////////////////////////////////////
//Luca 24/07/2008. Workaround per fare il resize corretto della form
// Funzione presa da sorgenti VDB
//Mantis 1866
STATIC FUNCTION _VDBWaitAllEvents(oDlg,nWait)
   LOCAL nEvent, oXbp, mp1, mp2
   LOCAL aSize

   //DEFAULT oDlg TO VDBMainDialog()
   DEFAULT nWait TO .1

   // simone 14/9/04 mantis 183
   //IF VALTYPE(oDlg) == "O" .AND. oDlg:IsDerivedFrom("XbpDialog")
   //   aSize :=oDlg:drawingArea:currentSize()
   //   aSize[1]--
   //   oDlg:drawingArea:setSize(aSize,.F.)
   //   aSize[1]++
   //   oDlg:drawingArea:setSize(aSize,.T.)
   //ENDIF


   // processo tutti gli eventi
   nEvent := NIL
   DO WHILE nEvent != xbe_None
      nEvent := AppEvent(@mp1,@mp2,@oXbp,nWait)
      IF nEvent !=xbe_None .AND. oXbp != NIL
         oXbp:handleEvent(nEvent,mp1,mp2)
      ENDIF
   ENDDO
RETURN .T.

///////////////////////////////////////////////////////////////////////


STATIC FUNCTION __formcurr(oWin)
#ifdef _MULTITHREAD_
LOCAL oo
IF oWin:MDI //.AND. ! EMPTY(oo:=dfSetMainWin())
//   RETURN oo
   RETURN AppDesktop()
ENDIF
#endif
RETURN S2FormCurr()


FUNCTION S2UseMainToolbar()
  STATIC lUse
  LOCAL lRET 

  IF lUSE == NIL
     lUSE := dfSetMainWin() != NIL .AND. dfSetMainWin() != S2FormCurr() .AND. ;
             dfAnd( dfSet(AI_XBASEMAINMENUMDI), AI_MENUMDI_SHOWTOOLBAR) != 0 .AND. ;
             ! EMPTY( dfSetMainWin():getToolBar( .T. ):setParent() )
  ENDIF 
  lRet := lUse

RETURN lRet 

FUNCTION S2STRforMenu(nNum)
LOCAL c1 := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  IF nNum <1 .OR.nNum>35 
     RETURN ""
  ENDIF 
RETURN c1[nNum]


METHOD S2Form:_FinSub(aSub,nItem)
 LOCAL xRet := aSub[nItem][1] 
 LOCAL nPOS, nN
  // Dovrebbe ritornare ...aSub[nItm][1] 
 nPOS := 0
 IF LEN(aSub) < nItem
    RETURN ""
 ENDIF 
 FOR nN := 1 TO LEN(aSub)

     //Luca 03/06/2013  Mantis 2224
     //lShowDisableMenu // dfset("xbaseShowdisablemenuitem")
     //IF aSub[nN][MNI_SECURITY] == MN_HIDDEN .OR. aSub[nN][MNI_SECURITY] == MN_SECRET .OR. aSub[nN][MNI_SECURITY] == MN_OFF
     IF aSub[nN][MNI_SECURITY] == MN_HIDDEN .OR. aSub[nN][MNI_SECURITY] == MN_SECRET .OR. (aSub[nN][MNI_SECURITY] == MN_OFF .AND. !::lShowDisableMenu)
        IF aSub[nN][MNI_TYPE] == MN_LINE
           nPOS++
        ENDIF 
     ELSE
        nPOS++
     ENDIF 

     IF nPOS == nItem
        xRet := aSub[nN][1] 
        EXIT
     ENDIF 
 NEXT 
RETURN xRet

