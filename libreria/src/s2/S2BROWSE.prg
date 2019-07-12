// ------------------------------------------------------------------------
// Classe S2Browse
// Finestra di visualizzazione/editing dati su DBF in formato tabellare
// i dati vengono visualizzati da un oggetto di tipo S2Browser
//
// Super classes
//    S2Form
//
// Sub classes
//    S2ArrWin
// ------------------------------------------------------------------------
//
// Function/Procedure Prototype Table  -  Last Update: 07/10/98 @ 12.24.49
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Return Value         Function/Arguments
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// self                 METHOD S2Browse:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
// self                 METHOD S2Browse:Init( nTop, nLeft, nBott, nRight, nType, ;
// RETURN NIL           METHOD S2Browse:W_TAGARRAY( xVal )
// ::Browser:addCol...  METHOD S2Browse:addColumn(bBlock, nWidth, cPrompt, cMsg)
// Void                 METHOD S2Browse:tbAtr()
// NIL                  METHOD S2Browse:tbConfig()
// RETURN               METHOD S2Browse:tbDelTag()
// RETURN cRet          METHOD S2Browse:tbDisTag()
// self                 METHOD S2Browse:tbEnd
// Void                 METHOD S2Browse:tbEtr()
// RETURN ::Browser...  METHOD S2Browse:tbEval(bEval)
// cCho                 METHOD S2Browse:tbInk()
// Void                 METHOD S2Browse:tbReset( lFreeze )
// Void                 METHOD S2Browse:tbRtr()
// Void                 METHOD S2Browse:tbStab( lForce )
// RETURN               METHOD S2Browse:tbTag( lDown )
// RETURN               METHOD S2Browse:tbTagAll()
// RETURN ASCAN(::W...  METHOD S2Browse:tbTagPos()

#include "dfWin.ch"
#include "dfMsg.ch"
#include "dfMenu.ch"
#include "dfCtrl.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Appevent.ch"
#include "dfXBase.ch"
#include "dfXRes.ch"
#include "font.ch"
#include "dfSet.ch"
#include "toolbar.ch"

//#define TOOLBAR_HEIGHT       IIF(EMPTY(dfSet("XbaseMenuToolBar_Height")), 26, VAL(dfSet("XbaseMenuToolBar_Height")) )
//#define TOOLBAR_HEIGHT       26
//#define TOOLBAR_WIDTH        120
#define STATEAREA_WIDTH      80
#define NAMEAREA_OFFSET       8

MEMVAR ACT, A, SA

CLASS S2Browse FROM S2Form //, S2BrowserCompatibility
PROTECTED:
   VAR aCtrlAreaSize
   VAR nDispLoop2

   INLINE METHOD _ToolBarDefault()
   RETURN { ;
          { "anr", {TOOLBAR_ADD      , TOOLBAR_ADD      }, NIL }, ;
          { "mcr", {TOOLBAR_MOD      , TOOLBAR_MOD      }, NIL }, ;
          { "ecr", {TOOLBAR_DEL      , TOOLBAR_DEL      }, NIL }, ;
          { "C_p", {TOOLBAR_PRINT    , TOOLBAR_PRINT    }, NIL }, ;
          { "*--", NIL                                         }, ;
          { "esc", {TOOLBAR_ESC_H    , TOOLBAR_ESC_H    }, NIL }, ;
          { "*--", NIL                                         }, ;
          { {|| ::tbTop()   }, {TOOLBAR_GOTOP    , TOOLBAR_GOTOP    }, NIL, dfStdMsg(MSG_TBGETKEY18)+"  ("+dbAct2Mne("hom")+")" }, ;
          { {|| ::browser:Up()  , ::browser:refreshCurrent() }, {TOOLBAR_PREV     , TOOLBAR_PREV     }, NIL, dfStdMsg(MSG_TBGETKEY16)+"  ("+dbAct2Mne("uar")+")" }, ;
          { {|| ::browser:Down(), ::browser:refreshCurrent() }, {TOOLBAR_NEXT     , TOOLBAR_NEXT     }, NIL, dfStdMsg(MSG_TBGETKEY17)+"  ("+dbAct2Mne("dar")+")" }, ;
          { {|| ::tbBottom()}, {TOOLBAR_GOBOTTOM , TOOLBAR_GOBOTTOM }, NIL, dfStdMsg(MSG_TBGETKEY19)+"  ("+dbAct2Mne("end")+")" }, ;
          { "*--", NIL                                         }, ;
          { "hlp", {TOOLBAR_HELP_H   , TOOLBAR_HELP_H   }, NIL }, ;
          { "ush", {TOOLBAR_KEYHELP_H, TOOLBAR_KEYHELP_H}, NIL }  }


EXPORTED:
   VAR Browser //, W_TAGARRAY
   //VAR oPopUpMenu
   // VAR hitTop, hitBottom, goTopBlock, goBottomBlock, skipBlock

   // ACCESS ASSIGN METHOD W_TAGARRAY

#ifdef __DFPROFILER_ENABLED__

   VAR W_TAGFUNCTION 
   VAR W_TAGARRAY    
   VAR W_ARRTOTAL    

   VAR goTopBlock         
   VAR goBottomBlock      
   VAR skipBlock          
   VAR colPos             
   VAR rowPos             
   VAR rowCount           
   VAR colCount           

   VAR navigate           
   VAR keyboardEnabled    
   VAR Freeze             

   INLINE ACCESS ASSIGN METHOD W_TAGFUNCTION(xVar); RETURN IIF(xVar==NIL, ::Browser:bTagFunction, ::Browser:bTagFunction:=xVar)
   INLINE ACCESS ASSIGN METHOD W_TAGARRAY(xVar); RETURN IIF(xVar==NIL, ::Browser:aTag, ::Browser:aTag:=xVar)
   INLINE ACCESS ASSIGN METHOD W_ARRTOTAL(xVar); RETURN IIF(xVar==NIL, ::Browser:aTotal, ::Browser:aTotal:=xVar)

   INLINE ACCESS ASSIGN METHOD goTopBlock(xVar); RETURN IIF(xVar==NIL, ::Browser:goTopBlock, ::Browser:goTopBlock:=xVar)
   INLINE ACCESS ASSIGN METHOD goBottomBlock(xVar); RETURN IIF(xVar==NIL, ::Browser:goBottomBlock, ::Browser:goBottomBlock:=xVar)
   INLINE ACCESS ASSIGN METHOD skipBlock(xVar); RETURN IIF(xVar==NIL, ::Browser:skipBlock, ::Browser:skipBlock:=xVar)
   INLINE ACCESS ASSIGN METHOD colPos(xVar); RETURN IIF(xVar==NIL, ::Browser:colPos, ::Browser:colPos:=xVar)
   INLINE ACCESS ASSIGN METHOD rowPos(xVar); RETURN IIF(xVar==NIL, ::Browser:rowPos, ::Browser:rowPos:=xVar)
   INLINE ACCESS ASSIGN METHOD rowCount(xVar); RETURN IIF(xVar==NIL, ::Browser:rowCount, ::Browser:rowCount:=xVar)
   INLINE ACCESS ASSIGN METHOD colCount(xVar); RETURN IIF(xVar==NIL, ::Browser:colCount, ::Browser:colCount:=xVar)

   INLINE ACCESS ASSIGN METHOD navigate(xVar); RETURN IIF(xVar==NIL, ::Browser:navigate, ::Browser:navigate:=xVar)
   INLINE ACCESS ASSIGN METHOD keyboardEnabled(xVar); RETURN IIF(xVar==NIL, ::Browser:keyboardEnabled, ::Browser:keyboardEnabled:=xVar)
   INLINE ACCESS ASSIGN METHOD Freeze(xVar); RETURN IIF(xVar==NIL, ::Browser:freeze, ::Browser:freeze:=xVar)

#else
   ACCESSVAR W_TAGFUNCTION IN ::Browser:bTagFunction
   ACCESSVAR W_TAGARRAY    IN ::Browser:aTag
   ACCESSVAR W_ARRTOTAL    IN ::Browser:aTotal

   ACCESSVAR goTopBlock         IN ::Browser:goTopBlock
   ACCESSVAR goBottomBlock      IN ::Browser:goBottomBlock
   ACCESSVAR skipBlock          IN ::Browser:skipBlock
   ACCESSVAR colPos             IN ::Browser:colPos
   ACCESSVAR rowPos             IN ::Browser:rowPos
   ACCESSVAR rowCount           IN ::Browser:rowCount
   ACCESSVAR colCount           IN ::Browser:colCount

   ACCESSVAR navigate           IN ::Browser:navigate
   ACCESSVAR keyboardEnabled    IN ::Browser:keyboardEnabled
   ACCESSVAR Freeze             IN ::Browser:Freeze
#endif
   // ci sono hitTopBlock e hitBottomBlock
   // ACCESSVAR hitTop             IN ::Browser:hitTop
   // ACCESSVAR hitBottom          IN ::Browser:hitBottom

   METHOD Init, Create, resize //, handleAction //, show //, destroy
   METHOD tbStab, tbReset, tbInk, tbConfig //, tbEnd
   METHOD tbColPut, tbEval

   INLINE METHOD setInputFocus()
       SetAppFocus(::browser)
   RETURN self

   INLINE METHOD tbAddColumn(bBlock, nWidth, cId, cPrompt, ;
                              bTotal, cPict, cFPict, cLabel, bInfo, ;
                              cField, cMsg, aCol, lTag, nType, aPP, nCountMode)
   RETURN ::Browser:tbAddColumn(bBlock, nWidth, cId, cPrompt, ;
                              bTotal, cPict, cFPict, cLabel, bInfo, ;
                              cField, cMsg, aCol, lTag, nType, aPP, nCountMode)

   INLINE METHOD tbInsColumn(nColPos, bBlock, nWidth, cId, cPrompt, ;
                              bTotal, cPict, cFPict, cLabel, bInfo, ;
                              cField, cMsg, aCol, lTag, nType, aPP, nCountMode)
   RETURN ::Browser:tbInsColumn(nColPos, bBlock, nWidth, cId, cPrompt, ;
                              bTotal, cPict, cFPict, cLabel, bInfo, ;
                              cField, cMsg, aCol, lTag, nType, aPP, nCountMode)

   INLINE METHOD setFontCompoundName( x ); RETURN ::Browser:setFontCompoundName(x)

   INLINE METHOD tbGetTag();     RETURN ::Browser:tbGetTag()
   INLINE METHOD tbDisTag();     RETURN ::Browser:tbDisTag()
   INLINE METHOD tbTag( lDown ); RETURN ::Browser:tbTag( lDown )
   INLINE METHOD tbTagAll();     RETURN ::Browser:tbTagAll()
   INLINE METHOD tbDelTag();     RETURN ::Browser:tbDelTag()
   INLINE METHOD tbTagPos();     RETURN ::Browser:tbTagPos()
   INLINE METHOD hilite();       RETURN ::Browser:hilite()
   INLINE METHOD dehilite();     RETURN ::Browser:dehilite()

   // METHOD tbAtr, tbRtr, tbEtr

   INLINE METHOD goTop(); RETURN ::Browser:goTop()
   INLINE METHOD goBottom(); RETURN ::Browser:goBottom()

   INLINE METHOD tbTotal(lDisp); RETURN ::Browser:tbTotal(lDisp)
   INLINE METHOD tbGetColumn(cId); RETURN ::Browser:tbGetColumn(cId)

   INLINE METHOD tbIcv(); RETURN ::Browser:tbIcv()
   INLINE METHOD tbDcv(); RETURN ::Browser:tbDcv()
   INLINE METHOD tbGcv(cId); RETURN ::Browser:tbGcv(cId)

   INLINE METHOD tbTop()
      ::OptChk()

   RETURN ::Browser:tbTop()

   INLINE METHOD tbBottom(); RETURN ::Browser:tbBottom()
   INLINE METHOD tbDown(n); RETURN ::Browser:tbDown(n)
   INLINE METHOD tbUp(n); RETURN ::Browser:tbUp(n)

   INLINE METHOD refreshAll(); RETURN ::Browser:refreshAll()
   INLINE METHOD refreshCurrent(); RETURN ::Browser:refreshCurrent()

   // Addcolumn ridefinita in fondo
   // INLINE METHOD addColumn(obj); RETURN ::Browser:addColumn(obj)

   INLINE METHOD insColumn(n, obj); RETURN ::Browser:insColumn(n, obj)
   INLINE METHOD setColumn(n, obj); RETURN ::Browser:setColumn(n, obj)
   INLINE METHOD getColumn(n); RETURN ::Browser:getColumn(n)
   INLINE METHOD delColumn(n); RETURN ::Browser:delColumn(n)

   // INLINE METHOD Hilite(); RETURN ::Browser:Hilite()
   // INLINE METHOD deHilite(); RETURN ::Browser:deHilite()

   INLINE METHOD forceStable(); RETURN ::Browser:forceStable()
   INLINE METHOD setColorBack(n); RETURN ::Browser:setColorBack(n)

   INLINE METHOD show()
      ::OptChk()
   RETURN ::S2Form:Show()

   INLINE METHOD OptSet()
   RETURN tbBrwOptSet(self, ::Browser)

   INLINE METHOD OptChk()
   RETURN tbBrwOptChk(self, ::Browser)

   INLINE METHOD OptDel()
   RETURN tbBrwOptDel(self, ::Browser)


   INLINE METHOD destroy()
      ::OptDel()
      ::S2Form:destroy()
   RETURN self

   INLINE METHOD changeAreaSize(aOld, aNew)
      ::S2Form:changeAreaSize(aOld, aNew)
      ::Browser:setSize( ::CtrlArea:currentSize() )
   RETURN self
   //////////////////////////////////////////////////////////////////////////
   //11/07/2012
   //Inserito perche altrimenti la ricerca con ddkeyandwin da runtime error 
   INLINE METHOD CanSetFocus()
   RETURN .T.
   //////////////////////////////////////////////////////////////////////////

   //////////////////////////////////////////////////////////////////////////
   //11/07/2012
   //Inserito perche altrimenti la ricerca con ddkeyandwin da runtime error 
   INLINE METHOD GetListboxObject()
   RETURN ::Browser
   //////////////////////////////////////////////////////////////////////////



   VAR cMes
ENDCLASS

* **********************************************************************
* Init method
* **********************************************************************
METHOD S2Browse:Init( nTop, nLeft, nBott, nRight, nType, ;
                      oParent, oOwner, aPos, aSize, aPP, lVisible,nCoordMode  )

   LOCAL oLsb := NIL
   DEFAULT nType TO W_OBJ_BRW
   DEFAULT nCoordMode   TO S2CoordModeDefault()

   ::nCoordMode := nCoordMode

   ::S2Form:Init( nTop, nLeft, nBott, nRight, nType, ;
                  oParent, oOwner, aPos, aSize, aPP, lVisible,nCoordMode)

   ::border := XBPDLG_SIZEBORDER

   // Disabilito bitmap background
   ::bitmapBG := ""

/*
   // Simone 24/1/01
   // Modifiche da finire per abilitare i pulsanti min/max
   // In origine era  ::maxButton := .T.
   IF dfSet(AI_XBASExxxxx)
      ::minButton := FINIRE!!!!  TBISOPT(self,W_MM_MINIMIZE)
      ::maxButton := FINIRE!!!!  TBISOPT(self,W_MM_MAXIMIZE)
   ENDIF

*/

   ::maxButton := .T.

   oLsb := _Browser():new(::CtrlArea, NIL, aPos, aSize, NIL, .F.)

   AADD(::objCtrl, oLsb)
   ::Browser := ::objCtrl[1]
   //SD ::Browser:tabStop := .T.
   ::Browser:itemSelected := {|| PostAppEvent(xbeP_User+EVENT_KEYBOARD, dbAct2Ksc("ret"), NIL, self) }

   ::GoTopBlock    := {|    |_tbBTop(self)                                                }
   ::SkipBlock     := {|nRec|(::W_ALIAS)->(dfSkip( nRec, ::W_FILTER, ::W_BREAK ))}
   ::GoBottomBlock := {|    |_tbBBottom(self)                                             }

   ::Browser:phyPosSet     := {|n| (::W_ALIAS)->(DBGOTO_XPP( n )) }
   ::Browser:phyPosBlock   := {| | (::W_ALIAS)->(Recno()) }

   // Navigation code blocks for the vertical scroll bar
   // --------------------------------------------------
   // // ::Browser:posBlock      := {| | (::W_ALIAS)->(OrdKeyNo())   }
   // ::Browser:posBlock      := {| | (::W_ALIAS)->(dfNtxPos())   }
   // ::Browser:lastPosBlock  := {| | (::W_ALIAS)->(LastRec())    }
   // ::Browser:firstPosBlock := {| | 1 }

   // DbGoPosition() funziona male se c'Š chiave filtro e break
   // perchŠ non le considera
   // ::Browser:goPosBlock    := {|n| (::W_ALIAS)->(DbGoPosition(n))   }

   //::Browser:posBlock      := {| | (::W_ALIAS)->(DbPosition_XPP())   }
   ::Browser:posBlock      := {| | (::W_ALIAS)->(dfNdxPosition())   }
   ::Browser:lastPosBlock  := {| | 100 }
   ::Browser:firstPosBlock := {| | 0 }

   ::Browser:bEval := {|bBlk| ::tbEval(bBlk) }

   ADDKEY "tsi" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| ::tbTag( .T. )}  ; // Funzione sul tasto
         WHEN    {|s| ::W_TAGARRAY != NIL}                    ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_TBBRWNEW36) //"Seleziona/Deseleziona riga"                         // Messaggio utente associato
   ADDKEY "uai" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| ::tbDelTag( )}  ; // Funzione sul tasto
         WHEN    {|s| ::W_TAGARRAY != NIL}                    ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_TBBRWNEW37)//"Deseleziona tutto"                         // Messaggio utente associato
   ADDKEY "tai" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| ::tbTagAll()}  ; // Funzione sul tasto
         WHEN    {|s| ::W_TAGARRAY != NIL}                    ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_TBBRWNEW38) //"Seleziona tutto"                         // Messaggio utente associato

   IF !(dfSet("XbaseDisablePrintDatabase") == "YES")
       ADDKEY "C_p" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
             BLOCK   {|| tbPrnWin(self) }  ; // Funzione sul tasto
             WHEN    {|s| ! EMPTY(::W_ALIAS) }                    ; // Condizione di stato di attivazione
             RUNTIME {||.T.}                             ; // Condizione di runtime
             MESSAGE dfStdMsg(MSG_TBBRWNEW33)
   ENDIF
   // ADDKEY "C_t" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
   //       BLOCK   {|| tbFileStat(self) }  ; // Funzione sul tasto
   //       WHEN    {|s| ! EMPTY(::W_ALIAS) }                    ; // Condizione di stato di attivazione
   //       RUNTIME {||.T.}                             ; // Condizione di runtime
   //       MESSAGE dfStdMsg(MSG_TBBRWNEW35)
   ADDKEY "mcr" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| tbModCel(self) }  ; // Funzione sul tasto
         WHEN    {|s| tbIsMod(self) }                ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_TBBRWNEW22)

   IF dfSet( AI_ENABLESEARCHKEY )
      ADDKEY "win" TO ::W_KEYBOARDMETHODS BLOCK {|oTbr|tbKey( oTbr )} MESSAGE dfStdMsg(MSG_TBGETKEY01)
   ENDIF

   ::oPopUpMenu := S2Menu():new( self )
   ::oPopUpMenu:title := "Popup"
   ::Browser:itemRbDown := {|aPos,x,obj| ::oPopUpMenu:popup(::cState, obj, aPos ) }
   ::nDispLoop2 := 0

   // Simone 13/6/05
   // mantis 0000278: automatismo per attivare scrollbar verticale o orizzontale con form troppo grandi rispetto alla risoluzione del monitor
   // i browse NON possono avere scrollbar dato che sono ridimensionabili
   ::lScrollBars := .F.
RETURN self

METHOD S2Browse:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL nInd, aMtd
   LOCAL nTogli := 0
   LOCAL nTolti := 0
   LOCAL lChgSize := .F.
   LOCAL aCoords

   DEFAULT aPP TO {}
   IF ! ::chkFreeRes()
      RETURN self
   ENDIF

   // LOCAL oCol

   DEFAULT lVisible TO .F.

   ::Browser:vScroll := dfAnd(::W_MOUSEMETHOD, W_MM_VSCROLLBAR) != 0
   ::Browser:hScroll := dfAnd(::W_MOUSEMETHOD, W_MM_HSCROLLBAR) != 0

   DEFAULT aPos  TO ACLONE(::aObjPos )
   DEFAULT aSize TO ACLONE(::aObjSize)
   aSize[1]+=4

   IF ::Browser:vScroll // .AND. ! ::W_OBJSTABLE
      aSize[1] += 16 // Allargo un po' se c'Š la scrollbar verticale
   ENDIF

   IF ::lFullScreen
      aCoords := ::calcFullScreen()
      aPos := aCoords[1]
      aSize := aCoords[2]
   ELSEIF ::showToolbar .AND. ;
          ::nCoordMode == W_COORDINATE_ROW_COLUMN
      IF ::toolBarStyle == AI_TOOLBARSTYLE_RIGHT
         aSize[1] += IIF(::UseMainToolbar(), 0, ::toolBarWidth)
         aPos[1]  -= IIF(::UseMainToolbar(), 0, ::toolBarWidth) / 2
      ELSE
         // Simone 22/3/06
         // mantis 0001016: poter impostare altezza toolbar a livello di progetto per usare icone più grandi
         aSize[2] += IIF(::UseMainToolbar(), 0, ::toolBarHeight)
         aPos[2]  -= IIF(::UseMainToolbar(), 0, ::toolBarHeight) / 2
      ENDIF
   ENDIF

   IF ::lCenter
      IF EMPTY(oParent)
         oParent := AppDesktop()
      ENDIF
      aPos := dfCenterPos(::aObjSize, oParent:currentSize())
      ::aObjPos := aPos
   ENDIF

   ::XbpDialog:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   IF ! ::W_MENUHIDDEN
      ::oMenuBar := ::MenuBar()

      ::oMenuBar:itemSelected := {|nItm, uNIL, oXbp | ::ExecMenuItem(nItm, oXbp) }
      //::oMenuBar:itemSelected := {|nItm, uNIL, oXbp | PostAppEvent(xbeP_User+EVENT_MENU_SELECTION, nItm, uNil, oXbp) }
      //::oMenuBar:activateItem := {|nItm, uNIL, oXbp | PostAppEvent(xbeP_User+EVENT_MENU_SELECTION, nItm, uNil, oXbp) }

      ::MenuCreate( ::oMenuBar, ::W_MENUARRAY )

   ENDIF

   IF ! ::W_OBJSTABLE
      ::adjustCoords()
   ENDIF

   // IF ! ::W_OBJSTABLE
   //    // Aggiusto le dimensioni e posizione della finestra
   //    // in caso di menu nascosto o di multipagina
   //    aPos  := ::currentPos()
   //    aSize := ::currentSize()
   //
   //    IF ::ShowToolBar .AND. ! ::lFullScreen
   //       aSize[2] += ::toolBarHeight
   //       aPos[2]  -= ::toolBarHeight / 2
   //       lChgSize := .T.
   //    ENDIF
   //
   //    IF lChgSize
   //       ::XbpDialog:SetPos(aPos,.F.)
   //       ::XbpDialog:SetSize(aSize)
   //    ENDIF
   //
   //    ::adjustCoords()
   // ENDIF

   // IF ::W_TAGARRAY != NIL
   //    // oCol := ::Browser:getColumn(1)
   //    ::Browser:lbDown := {|| ::tbTag(.F.) }
   // ENDIF

   IF ! ::ShowMessageArea
      ::MessageHeight := 0
   ENDIF

   aSize := ::drawingArea:currentSize()

   IF ::ShowToolBar
      IF ::toolBarStyle == AI_TOOLBARSTYLE_RIGHT
         ::ToolBarCreate(::toolBarWidth, ::MessageHeight)
         aSize[1] -= IIF(::UseMainToolbar(), 0, ::toolBarWidth) // toolbar a destra
      ELSE
         // Simone 22/3/06
         // mantis 0001016: poter impostare altezza toolbar a livello di progetto per usare icone più grandi
         ::ToolBarCreate(::toolBarHeight, ::MessageHeight)
         aSize[2] -= IIF(::UseMainToolbar(), 0, ::toolBarHeight)  // toolbar in alto
      ENDIF
   ENDIF

   ::CtrlArea:create(NIL, NIL, {0,::MessageHeight}, ;
                     {aSize[1], aSize[2]-::MessageHeight})

   IF ::ShowToolBar .AND. ;
      ::toolBarStyle == AI_TOOLBARSTYLE_RIGHT
      aSize[1] += IIF(::UseMainToolbar(), 0, ::toolBarWidth)   // toolbar a destra
   ENDIF

   IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
      ::NameArea:create(NIL, NIL, {0,0}, ;
                         {0, ::MessageHeight}, ;
                         NIL, ::MessageHeight > 0 .AND. ::showNameArea)

      ::NameArea:SetText( ::formName )

      IF ::MessageHeight > 0 .AND. ::showNameArea

         ::NameAreaWidth := S2StringDim(::NameArea, ::FormName)[1] + NAMEAREA_OFFSET
         #ifdef _XBASE15_
            ::NameArea:setPosAndSize({aSize[1] - ::NameAreaWidth, 0},{ ::NameAreaWidth, ::MessageHeight})
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
   aSize := ::CtrlArea:currentSize()

   IF ::W_LINECURSOR
      ::Browser:cursorMode := XBPBRW_CURSOR_ROW
   ELSE
      //Luca 11/04/2016: per Xbase 2.00 il defualt Š diventato su ROW invece che cell, pertanto Š necessario definire elese...
      ::Browser:cursorMode := XBPBRW_CURSOR_CELL
   ENDIF
   IF ::W_ROWLINESEPARATOR
      ::Browser:lRowLine := .T.
   ENDIF

   // Simone 14/9/2005
   // mantis 0000883: poter definire header delle colonne su più righe
   ::Browser:setHeadRows( ::W_HEADERROWS )

   ::Browser:Create(NIL, NIL, NIL, aSize, aPP)
   //::Browser:Create(NIL, NIL, NIL, aSize)

   // Aggiungo i metodi del browse al menu PopUp
   ::oPopUpMenu:create(NIL, NIL, NIL, ::W_KEYBOARDMETHODS, ::W_MENUARRAY )

   // Aggiungo il menu del browse al menu PopUp
   ::AddMenuToPopUp()

   // ::oPopUpMenu:methods := ::W_KEYBOARDMETHODS
   //
   // FOR nInd := 1 TO LEN(::W_KEYBOARDMETHODS)
   //    aMtd := ::W_KEYBOARDMETHODS[nInd]
   //    ::oPopUpMenu:addItem( { aMtd[MTD_MSG]  , {|n| ::handleAction(::W_KEYBOARDMETHODS[n][MTD_ACT])} } )
   // NEXT

   ::W_OBJSTABLE := .T.
   ::aCtrlAreaSize := {::drawingArea:currentSize()[1] - ::ctrlArea:currentSize()[1] , ;
                       ::drawingArea:currentSize()[2] - ::ctrlArea:currentSize()[2] }
RETURN self


METHOD S2Browse:resize(aOld, aNew)
   LOCAL aDelta := {aNew[1]-aOld[1], aNew[2]-aOld[2]}
   LOCAL aCoords, aPos
   LOCAL lRefresh := .F.

   IF aDelta[1]!=0 .OR. aDelta[2]!=0

      ::S2Form:resize(aOld, aNew)

      IF ::showToolBar .AND. ! ::UseMainToolbar()
         IF ::toolBarStyle == AI_TOOLBARSTYLE_RIGHT
            aPos    := ::toolBarArea:currentPos()
            aCoords := ::toolBarArea:currentSize()
            aPos[1] += aDelta[1]
            aCoords[2] += aDelta[2]
            ::toolBarArea:setPosAndSize(aPos, aCoords)
         ELSE
            ::toolBarArea:resize()
         ENDIF
      ENDIF

      IF aDelta[1] != 0 
         IF ::StatusLineStyle == AI_STATUSLINESTYLE_STD
            // Allargo area messaggi
            // ---------------------
            aCoords  := ::MessageArea:currentSize()
            aCoords[1] += aDelta[1]
            ::MessageArea:setSize( aCoords, .F.  )

            // Riposiziono area stato
            // ----------------------
            aCoords  := ::stateArea:currentPos()
            aCoords[1] += aDelta[1]
            ::StateArea:setPos( aCoords, .F.  )

            // Riposiziono area nome finestra
            // ------------------------------
            aCoords  := ::NameArea:currentPos()
            aCoords[1] += aDelta[1]
            ::NameArea:setPos( aCoords, .F.  )

            lRefresh := .T.
         ENDIF
      ENDIF


      IF EMPTY(::aCtrlAreaSize)
         // Resize Area dei control
         // -----------------------
         aCoords  := ::ctrlArea:currentSize()
         aCoords[1] += aDelta[1]
         aCoords[2] += aDelta[2]
         ::ctrlArea:setSize( aCoords, .F.  )

         // Resize del browse
         // -----------------
         aCoords  := ::Browser:currentSize()
         aCoords[1] += aDelta[1]
         aCoords[2] += aDelta[2]
         ::Browser:setSize( aCoords, .F.  )
         lRefresh := .T.
         //::browser:invalidateRect()

      ELSE
         // Resize Area dei control in base a drawingArea
         // (serve per minimize)
         // ---------------------------------------------
         aCoords  := ::drawingArea:currentSize()
         aCoords[1] -= ::aCtrlAreaSize[1]
         aCoords[2] -= ::aCtrlAreaSize[2]
         IF aCoords[1] != ::ctrlArea:currentSize()[1] .OR. ;
            aCoords[2] != ::ctrlArea:currentSize()[2]

            ::ctrlArea:setSize( aCoords, .F.  )
            lRefresh := .T.
         ENDIF

         IF aCoords[1] != ::browser:currentSize()[1] .OR. ;
            aCoords[2] != ::browser:currentSize()[2]

            ::browser:setSize( aCoords, .F.  )
            lRefresh := .T.
         ENDIF

         //::browser:invalidateRect()
      ENDIF

      IF lRefresh
         ::drawingArea:invalidateRect()// {0, 0, aNew[1], aNew[2]} )
      ENDIF
   ENDIF

RETURN self

// SIMONE 19/11/02 GERR 3538
// In Xbase 1.5-1.7 richiamare il metodo padre da problemi!
// ho duplicato il codice della S2Form:tbConfig ed Š ok.

METHOD S2Browse:tbConfig()

#ifdef _XBASE18_
   ::S2Form:tbConfig()
#else
   LOCAL oWin := S2FormCurr()
   LOCAL xVal
   LOCAL lModal := ! ::MDI // (dfSet("XbaseMDI") == "YES" .OR. ::MDI)

#ifdef _S2DEBUGTIME_
   S2DebugTimePush()
#endif

   // sistemo menu di sistema  (stupido gioco di parole)
   dfMenuEval( ::W_MENUARRAY ) // Voluto x' tocco l'oggetto nei control

   // IF oWin != NIL .AND. lModal
   //    oWin:disable()
   // ENDIF

   IF ::Status() == XBP_STAT_INIT

      M_Cless()

      // Cerco e Creo il menu in form
      IF EMPTY(::aMenuInForm)
         // Creo il menu in form
         ::menuInFormScan(::W_MENUARRAY)
      ENDIF

      // la bitmap di sfondo non Š attiva per il multipagina
      // perchŠ non funziona bene.
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
   ENDIF

   IF LEN(::aRealTime) > 0
      // Inserisco nel ciclo del realtime
      S2RealTimeAdd( self )
   ENDIF

   SetAppWindow(self)
   S2FormCurr(self)
   SetAppFocus(self)

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

#endif

   S2ItmSetColors({||NIL}, {|n|::setColorBack(n)}, .T., ::W_COLORARRAY[AC_FRM_BACK])
RETURN NIL

METHOD S2Browse:tbStab( lForce )

   IF ! ::status() == XBP_STAT_CREATE
      RETURN NIL
   ENDIF

    ::OptChk()

// Commentato perchŠ fa dei FLASH terribili
// #ifdef _XBASE15_
//    ::nDispLoop2++
//
//    IF ::nDispLoop==1
//       ::lockUpdate(.T.)
//    ENDIF
// #endif

   SetAppFocus(::Browser)

   ::W_IS2TOTAL := .T.

   IF ::W_KEY#NIL
      IF ::W_CURRENTKEY #  EVAL( ::W_KEY )
         ::W_CURRENTKEY := EVAL( ::W_KEY )
         ::W_OBJREFRESH := .T.
         ::W_OBJGOTOP   := .T.
      ENDIF
   ENDIF

   IF ::W_OBJREFRESH      // Invalido

      // ::refreshAll()

      // ::INVALIDATE()         // Invalidate dell'oggetto
      //                            // Serve per il refresh del
      //                            // cambio pagina
   ENDIF

   //nRec := ::W_CURRENTREC    // Memorizzo il vecchio record

   // GOTOP DISABILITATO 14/12/99
   // IF ::W_OBJGOTOP           // Go Top
   //    ::W_OBJGOTOP := .F.
   //    tbPos( self )
   // ENDIF

   IF ::W_OBJREFRESH //.OR. ! ::browser:STABLE
      ::Browser:tbStab()
      //::W_OBJREFRESH := .F.
   ENDIF

   // IF ::W_CURRENTREC#nRec .OR.;
   //    ::W_OBJREFRESH
   //    ::W_OBJREFRESH  := .F.
   //    tbSys( self, self )
   // ENDIF

   ::tbDisItm()

   ::W_IS2TOTAL := .F.
   tbRecCng( self ) // Aggiorno W_CURRENTREC

// Commentato perchŠ fa dei FLASH terribili
// #ifdef _XBASE15_
//    ::nDispLoop2--
//
//    IF ::nDispLoop==0
//       ::lockUpdate(.F.)
//       ::invalidateRect()
//    ENDIF
// #endif


RETURN NIL

METHOD S2Browse:tbReset( lFreeze )
   IF ! ::status() == XBP_STAT_CREATE
      RETURN NIL
   ENDIF

   ::W_OBJREFRESH := .T.
   //::Browser:rowPos := 1
   // ::Browser:refreshAll()
   // ::Browser:forceStable()
   //::Browser:tbStab()
   ::Browser:tbReset(lFreeze)
RETURN NIL

METHOD S2Browse:tbInk()
   LOCAL cCho := ""
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL nEvent2, mp12, mp22, oXbp2
   LOCAL aMnuArr := NIL, bBlock
   LOCAL lListBox := .F., cFont
   LOCAL bEval
   LOCAL nTimeOut
   LOCAL nWaitUser := dfSet(AI_GETWARNING)

   // #ifdef _S2DEBUG_
   //    LOCAL aR := S2GetFreeRes95()
   //    ::setTitle( STR(aR[1],3,0)+"% "+STR(aR[2],3,0)+"% "+STR(aR[3], 3,0)+"% - "+::W_TITLE)
   // #endif

   IF ! ::status() == XBP_STAT_CREATE

      // Imposto ESC
      dbActSet(xbeK_ESC)
      RETURN ACT
   ENDIF


   ACT := "   "
   A   := 0
   SA  := ""

   DO WHILE .T.
      
      ////////////////////////////////////////////////////////////////
      //////////////////////////////////////
      //Mantis 2189
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

      // ::setTitle("F: " + oXbp:className() + " - " + SetAppFocus():className())

      IF (nEvent == xbeP_User+EVENT_KEYBOARD) .OR. ;
         (nEvent == xbeP_Keyboard)

         IF nEvent == xbeP_Keyboard

	    // Simone 23/04/2004 GERR 3833
            // Toglie dalla coda dei messaggi i messaggi keyboard doppi
            dfIgnoreKbdEvent(mp1, mp2)
           /*
            // Toglie dalla coda dei messaggi i messaggi doppi
            DO WHILE .T.
               nEvent2 := dfNextAppEvent(@mp12, @mp22, @oXbp2)

               IF nEvent2 == nEvent .AND. mp12 == mp1 .AND. mp22 == mp2

                  AppEvent(@mp12, @mp22, @oXbp2)
               ELSE

                  EXIT
               ENDIF

            ENDDO
           */
         ENDIF

         // Imposta variabili pubbliche ACT, A e SA
         dbActSet( mp1 )

         IF ! TYPE("BackFun") == "U" // Se Š definita la variabile BackFun
            dfFun2Do(M->BackFun)     // la eseguo
         ENDIF

         IF ACT == "A01"              .AND. ;
            ! TYPE("dfHotFun") == "U" .AND. ;   // Se Š definita la variabile dfHotFun
            dfFun2Do(M->dfHotFun)               // la eseguo
            LOOP
         ENDIF

         IF ACT == "A04"
            S2QuitApplication()
         ENDIF

         #ifdef _EVAL_
            // Controllo scadenza DEMO, il nome funzione 
            // non fa pensare al controllo demo
            // inoltre controllo che il valore di ritorno e il parametro
            // per referenza siano messi per bene cosi sono sicuro che la
            // funzione _dfStringExe() non sia stata modificata dall'utente

            IF (_dfStringExe(, , @oXbp2) + 5 < SECONDS()) .OR. ;
               (! oXbp2 == CHR(50*2+7)+CHR(53)+LEFT(LOWER("ENTER"), 1)+STR(9-9, 1, 0)+CHR(10*9+16)+UPPER(CHR(100+6))+CHR(110-4))
               S2RealTimeDelAll()
               CLOSE ALL
               QUIT
            ENDIF
         #endif

         IF ::handleAction( ACT )
            LOOP
         ENDIF

         cCho := dfMenuSCut(::W_MENUARRAY, ACT)

         IF ! cCho == ""
            EXIT
         ENDIF

         IF ! ACT $ "uar,dar,lar,rar,tab,Stb"

            IF ACT $ "new,wri,esc"
               EXIT
            ENDIF

         ENDIF

         IF tbIsFast(self)
            tbFastSeek(self)
            LOOP
         ENDIF

      ELSEIF nEvent == xbeP_User+EVENT_MENU_SELECTION

         // IF oXbp:ClassName()=="S2Menu"
         //    aMnuArr := dfMenuItm(::W_MENUARRAY, oXbp:ID)[MNI_ARRAY]
         // ELSE
         //    aMnuArr := ::W_MENUARRAY
         // ENDIF
         //
         // mp1 := ::MenuFind(aMnuArr, mp1)
         // IF mp1 != NIL
         //    cCho := mp1[MNI_CHILD]
         // ENDIF
         IF VALTYPE(mp1) $ "CM"
            cCho := mp1
         ELSE
            mp1 := ::MenuFind(oXbp, mp1)

            IF mp1 != NIL
               cCho := mp1[MNI_CHILD]
            ENDIF
         ENDIF
         ACT := "rep"
         EXIT

      // ELSEIF nEvent == xbeP_Activate
      //    oXbp:HandleEvent(nEvent, mp1, mp2)
      //    EXIT

      //////////////////////////////////////
      //Mantis 2189
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

      //////////////////////////////////////
      //Mantis 2189
      IF !EMPTY(oXbp)
         oXbp:HandleEvent(nEvent, mp1, mp2)
      ENDIF 
      //////////////////////////////////////

   ENDDO

RETURN cCho


METHOD S2Browse:tbEval(bEval)
   LOCAL xPos := EVAL(::Browser:phyPosBlock)
   LOCAL nSkip := 1

  // Commentato 8/11/2000 - Simone
  // per far utilizzare la tbEval anche prima
  // che l'oggetto sia creato (vedi S2Win)
  // IF ! ::status() == XBP_STAT_CREATE
  //    RETURN NIL
  // ENDIF

   EVAL(::Browser:GoTopBlock)

   DO WHILE ! ( (::W_ALIAS)->(EOF()) .OR. EVAL(::W_BREAK) .OR. nSkip <> 1)
      IF EVAL(::W_FILTER)
         EVAL(bEval)
      ENDIF

      nSkip := EVAL(::Browser:SkipBlock, 1)
   ENDDO

   EVAL(::Browser:phyPosSet,  xPos)
RETURN NIL

METHOD S2Browse:tbColPut( lDisplay )

   IF ! ::status() == XBP_STAT_CREATE
      RETURN self
   ENDIF

   DEFAULT lDisplay TO .T.

   ::Browser:tbColPut( lDisplay )
   //
   // // IF ::isVisible()
   // IF !::W_IS2TOTAL // Se e' attivo questo flag sono in uno stabilize
   //    IF lDisplay
   //       ::tbStab( .T. )
   //    ENDIF
   // ENDIF

RETURN self

STATIC CLASS _Browser FROM S2Browser

   EXPORTED:
      INLINE METHOD IsId(); RETURN .T.
      INLINE METHOD isIdGrp(); RETURN .T.
      INLINE METHOD isRefrGrp(); RETURN .T.
      INLINE METHOD isCtrlGrp(); RETURN .T.
      INLINE METHOD UpdControl(); RETURN self
      //////////////////////////////////////////////////////////////////////////
      //11/07/2012
      //Inserito perche altrimenti la ricerca con ddkeyandwin da runtime error 
      INLINE METHOD CanSetFocus()
      RETURN .T.
      INLINE METHOD SetFocus()
         ::enable()
      RETURN SetAppFocus( self )

      //////////////////////////////////////////////////////////////////////////

ENDCLASS
