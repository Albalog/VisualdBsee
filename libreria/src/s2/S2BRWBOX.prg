// ------------------------------------------------------------------------
// Classe S2BrowseBox
// Classe di browsing su DBF
//
// Super classes
//    S2Browser
//
// Sub classes
//    S2ArrayBox
// ------------------------------------------------------------------------
//
// Function/Procedure Prototype Table  -  Last Update: 06/11/98 @ 17.17.50
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Return Value         Function/Arguments
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// RETURN               METHOD S2BrowseBox:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
// self                 METHOD S2BrowseBox:Init( nTop, nLeft, nBott, nRight, nType, ;
// RETURN NIL           METHOD S2BrowseBox:tbEval(bEval)
// RETURN ::aTag        METHOD S2BrowseBox:tbReset( lFreeze )
// self                 METHOD S2BrowseBox:tbStab( lForce )

#include "dfWin.ch"
#include "dfMsg.ch"
#include "dfMenu.ch"
#include "dfCtrl.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Appevent.ch"
#include "font.ch"
#include "dfSet.ch"

#include "dfXBase.ch"

#pragma Library( "XppUi2.lib" )

MEMVAR ACT, A, SA

STATIC CLASS _MySuper FROM S2Window, S2Browser, S2BrowserCompatibility //, S2Control
ENDCLASS

CLASS S2BrowseBox FROM _MySuper

//CLASS S2BrowseBox FROM S2Window, S2Browser, S2BrowserCompatibility

PROTECTED:

EXPORTED:
   VAR W_TITLE
   VAR oPopUpMenu
   VAR oForm, oOwner
   VAR bOnFirstPos
   VAR nDispLoop
   VAR nCoordMode

   VAR cMes

   //////////////////////////////
   //////////////////////////////
   //Eventuale code block da assegnare per gestire caricamento Array Listbox dinamica con refresh del gruppo, 
   //quindi attivabile nella Dispitem()
   VAR W_LOADARRAYFUNCTION
   VAR W_TAGONLOAD
   //////////////////////////////
   //////////////////////////////

#ifdef __DFPROFILER_ENABLED__
   VAR W_TAGFUNCTION
   INLINE ACCESS ASSIGN METHOD W_TAGFUNCTION(xVar); RETURN IIF(xVar==NIL, ::bTagFunction, ::bTagFunction:=xVar)
   VAR W_TAGARRAY
   INLINE ACCESS ASSIGN METHOD W_TAGARRAY(xVar); RETURN IIF(xVar==NIL, ::aTag, ::aTag:=xVar)
   VAR W_ARRTOTAL
   INLINE ACCESS ASSIGN METHOD W_ARRTOTAL(xVar); RETURN IIF(xVar==NIL, ::aTotal, ::aTotal:=xVar)
#else
   ACCESSVAR W_TAGFUNCTION IN ::bTagFunction
   ACCESSVAR W_TAGARRAY IN ::aTag
   ACCESSVAR W_ARRTOTAL IN ::aTotal
#endif


   METHOD Init , Create, SetInputFocus, KillInputFocus //, SetTitle, Show,
   METHOD tbStab, tbEval // tbInk
   METHOD tbColPut, handleAction, keyboard
   METHOD DoStabilize, dispItm

   INLINE METHOD tbDisItm(); RETURN NIL
   INLINE METHOD tbDisRef(); RETURN NIL
   INLINE METHOD tbDisCal(); RETURN NIL
   INLINE METHOD tbDisGrp(); RETURN NIL

   INLINE METHOD tbTop()
      ::OptChk()
   RETURN ::_MySuper:tbTop()
   //RETURN ::S2Browser:tbTop()

   INLINE METHOD show()
      ::optChk()
   RETURN ::_MySuper:Show()
   //RETURN ::S2Browser:Show()


   INLINE METHOD destroy()
      ::optDel() 
      ::_MySuper:destroy()
      //::S2Window:destroy()
      //::S2Browser:destroy()
      //::S2BrowserCompatibility:destroy()
   RETURN self

   INLINE METHOD OptSet()
   RETURN tbBrwOptSet(self, NIL, ::oForm)

   INLINE METHOD OptChk()
   RETURN tbBrwOptChk(self, NIL, ::oForm)

   INLINE METHOD OptDel()
   RETURN tbBrwOptDel(self)

/* ----------------------------------------------------------------------------------------------
   Nuovo Metodo inserito: tbRefreshCol()
   ----------------------
   (int) nCol : Colonna da aggiornare
   (int) nRow : Riga da aggiornare
         xValue: Valore da settare
   ----------------------------------------------------------------------------------------------- */      
   INLINE METHOD tbRefreshCol(nCol, nRow, xValue)
          LOCAL oCol, i, cBack:=0, cFore:=0, lRetu := .F.
          DEFAULT nCol TO 0
          DEFAULT nRow TO 0
          IF nCol== 0 .OR. nRow==0; RETU .F.; END
          oCol := ::GetColumn(nCol)
          oCol:dataArea:GetCellColor(nRow, @cFore, @cBack)                        //Mi registro i colori della colonna prima che ::SetCell me li cambi
          lRetu := oCol:dataArea:SetCell(nRow, dfAny2Str(xValue, oCol:picture))
          oCol:DataArea:SetCellColor(nRow, cFore, cBack, .T.)                     //Reimposto i colori della colonna
   RETU lRetu

   /////////////////////////////////////
   //Luca 25/02/2014 Mantis 2241
   //Inserito metodo per settare dinamicamente il titolo di una liostbox su array.
   /////////////////////////////////////
   INLINE METHOD SetTitle(cTitle)
      LOCAL cRet := "" 
      self:oOwner:S2StaticGroupboxwithfocus:setCaption(cTitle)
   RETURN cRet  
   /////////////////////////////////////

   // METHOD Navigate
   // METHOD tbAtr, tbRtr, tbEtr
   // METHOD tbDisTag, tbTag, tbTagAll, tbDelTag, tbEval, tbTagPos
ENDCLASS

* **********************************************************************
* Init method
* **********************************************************************
METHOD S2BrowseBox:Init( nTop, nLeft, nBott, nRight, nType, ;
                         oParent, oOwner, aPos, aSize, aPP, lVisible,nCoordMode)


   LOCAL oPos := NIL

   DEFAULT nType TO W_OBJ_BROWSEBOX
   DEFAULT lVisible TO .F.
   DEFAULT nCoordMode   TO S2CoordModeDefault()
   ::nCoordMode  := nCoordMode

   ::nTop    := nTop
   ::nLeft   := nLeft
   ::nBottom := nBott
   ::nRight  := nRight


   // oPos := PosCvt():new(::nLeft, ::nBottom+1)
   // oPos:Trasla(oParent)

   // DEFAULT aPP TO {}

   // DEFAULT aPos TO {oPos:nXWin, oPos:nYWin}

   // oPos:SetDos(::nRight - ::nLeft, ::nBottom - ::nTop + 1)

   // DEFAULT aSize TO {oPos:nXWin, oPos:nYWin}

   * initialisation of base class

   ::S2Browser:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2Window:Init( nType )

   //SD ::TabStop := .T.

   ::GoTopBlock    := {|    |_tbBTop(self)                                                }
   ::SkipBlock     := {|nRec|(::W_ALIAS)->(dfSkip( nRec, ::W_FILTER, ::W_BREAK ))}
   ::GoBottomBlock := {|    |_tbBBottom(self)                                             }

   ::bEval         := {|bBlk| ::tbEval(bBlk) }

   ::phyPosSet     := {|n| (::W_ALIAS)->(DBGOTO_XPP( n )) }
   ::phyPosBlock   := {| | (::W_ALIAS)->(Recno()) }

   // Navigation code blocks for the vertical scroll bar
   // --------------------------------------------------
   // // ::posBlock      := {| | (::W_ALIAS)->(OrdKeyNo())   }
   // ::posBlock      := {| | (::W_ALIAS)->(dfNtxPos())   }
   // ::lastPosBlock  := {| | (::W_ALIAS)->(LastRec())    }
   // ::firstPosBlock := {| | 1 }

   // DbGoPosition() funziona male se c'Š chiave filtro e break
   // perchŠ non le considera
   // ::goPosBlock    := {|n| (::W_ALIAS)->(DbGoPosition(n))   }

   ::posBlock      := {| | (::W_ALIAS)->(dfNdxPosition())   }
   ::lastPosBlock  := {| | 100 }
   ::firstPosBlock := {| | 0 }

   ::stableBlock := {|| ::DoStabilize() }

   ::nDispLoop := 0

   ::WOBJ_TYPE := nType

   ::W_TITLE      := ""
   ::W_BORDERGAP  :={1,1,1,2}

   ::W_RELATIVEPOS:={ nTop    - ::W_BG_TOP, ;
                      nLeft   - ::W_BG_LEFT   ,;
                      nBott   - ::W_BG_BOTTOM ,;
                      nRight  - ::W_BG_RIGHT   }

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

   ADDKEY "tsi" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| ::tbTag( .T. )}  ; // Funzione sul tasto
         WHEN    {|s| ::W_TAGARRAY != NIL}                    ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_TBBRWNEW36)//"Seleziona/Deseleziona riga"                         // Messaggio utente associato

   ADDKEY "uai" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| ::tbDelTag( )}  ; // Funzione sul tasto
         WHEN    {|s| ::W_TAGARRAY != NIL}                    ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_TBBRWNEW37)//"Deseleziona tutto"                         // Messaggio utente associato

   ADDKEY "tai" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| ::tbTagAll()}  ; // Funzione sul tasto
         WHEN    {|s| ::W_TAGARRAY != NIL}                    ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_TBBRWNEW38)//"Seleziona tutto"                         // Messaggio utente associato

   // simone 13/12/10 XL 2319
   // poter mettere controllo accessi per utente su stampa tabella/stampa etichette
   IF tbChkPrn(self, "S2BRWBOX-CHECK")
   ADDKEY "C_p" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| tbPrnWin(self) }  ; // Funzione sul tasto
            WHEN    {|s| ! EMPTY(::W_ALIAS) .AND. tbChkPrn(self, "S2BRWBOX-WHEN")}                    ; // Condizione di stato di attivazione
            RUNTIME {||tbChkPrn(self, "S2BRWBOX-RUNTIME")}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_TBBRWNEW33)
   ENDIF
   IF tbChkLab(self, "S2BRWBOX-CHECK")
      ADDKEY "C_l" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
            BLOCK   {|| tbPrnLab(self) }  ; // Funzione sul tasto
            WHEN    {|s| ! EMPTY(::W_ALIAS) .AND. tbChkLab(self, "S2BRWBOX-WHEN")}                    ; // Condizione di stato di attivazione
            RUNTIME {||tbChkLab(self, "S2BRWBOX-RUNTIME")}                             ; // Condizione di runtime
            MESSAGE dfStdMsg(MSG_TBBRWNEW34)
   ENDIF

   IF tbChkSta(self, "S2BRWBOX-CHECK")
      ADDKEY "C_t" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
            BLOCK   {|| tbFileStat(self) }  ; // Funzione sul tasto
            WHEN    {|s| ! EMPTY(::W_ALIAS) .AND. tbChkSta(self, "S2BRWBOX-WHEN")}                    ; // Condizione di stato di attivazione
            RUNTIME {||tbChkSta(self, "S2BRWBOX-RUNTIME")}                             ; // Condizione di runtime
            MESSAGE dfStdMsg(MSG_TBBRWNEW35)
   ENDIF

   IF dfSet( AI_ENABLESEARCHKEY )
      ADDKEY "win" TO ::W_KEYBOARDMETHODS BLOCK {|oTbr|tbKey( oTbr )} MESSAGE dfStdMsg(MSG_TBGETKEY01)
   ENDIF

   ADDKEY "mcr" TO ::W_KEYBOARDMETHODS          ; // Tasto su List Box
         BLOCK   {|| tbModCel(self) }  ; // Funzione sul tasto
         WHEN    {|s| tbIsMod(self) }                ; // Condizione di stato di attivazione
         RUNTIME {||.T.}                             ; // Condizione di runtime
         MESSAGE dfStdMsg(MSG_TBBRWNEW22)

   ::oPopUpMenu := S2Menu():new( self )
   ::oPopUpMenu:title := "Popup"
   ::itemRbDown := {|aPos,x,obj| ::oPopUpMenu:popup(::cState, obj, aPos ) }

   //Inizzializato a Nil per mantenere tutto inalterato
   ::W_LOADARRAYFUNCTION  := NIL
   ::W_TAGONLOAD          := NIL
RETURN self

//Maudp-LucaC 21/03/2013 Aggiunto parametro per forzare il refresh del singolo record della listbox
//METHOD S2BrowseBox:dispItm()
METHOD S2BrowseBox:dispItm(lForce)
   LOCAL lOnFirst := ! ::isVisible()

   DEFAULT lForce TO .F.

   IF lOnFirst .AND. ! EMPTY(::bOnFirstPos)
      EVAL(::bOnFirstPos)
   ENDIF
//Maudp-LucaC 21/03/2013 Aggiunto parametro per forzare il refresh del singolo record della listbox
//   ::S2Browser:DispItm()
   ::S2Browser:DispItm(lForce)
RETURN self

METHOD S2BrowseBox:DoStabilize()
   LOCAL lRet := .T.
   LOCAL nEvent, mp1, mp2, oXbp

// Commentato perchŠ fa dei FLASH terribili
// #ifdef _XBASE15_
//    ::nDispLoop++
//
//    IF ::nDispLoop==1
//       ::lockUpdate(.T.)
//    ENDIF
// #endif

   // Simone 23/04/2004 GERR 3833
   nEvent := dfNextAppEvent( @mp1, @mp2, @oXbp )

   // Evito il refresh dei control collegati al browse
   // se il prossimo evento Š un tasto SU o GIU

   IF oXbp == self .AND. ;
      nEvent == xbeP_Keyboard .AND. ;
      (mp1 == xbeK_UP      .OR. mp1 == xbeK_DOWN  .OR. ;
       mp1 == xbeK_LEFT    .OR. mp1 == xbeK_RIGHT .OR. ;
       mp1 == xbeK_PGUP    .OR. mp1 == xbeK_PGDN  .OR. ;
       mp1 == xbeK_HOME    .OR. mp1 == xbeK_END     )

      lRet := .F.

   ENDIF

   ::hitTop:=.F.
   ::hitBottom:=.F.
   ::stable:= .T.

   tbRecCng( self ) // Aggiorno W_CURRENTREC

   IF lRet
      tbSys(self, ::oForm)
   ENDIF

// Commentato perchŠ fa dei FLASH terribili
// #ifdef _XBASE15_
//    ::nDispLoop--
//
//    IF ::nDispLoop==0
//       ::lockUpdate(.F.)
//       ::invalidateRect()
//    ENDIF
// #endif

RETURN self

METHOD S2BrowseBox:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL nInd, aMtd
   // LOCAL oCol
   DEFAULT aPP TO {}

   IF ::Status() == XBP_STAT_INIT

      IF ::W_LINECURSOR
         ::cursorMode := XBPBRW_CURSOR_ROW
      ELSE
         //Luca 11/04/2016: per Xbase 2.00 il defualt Š diventato su ROW invece che cell, pertanto Š necessario definire elese...
         ::cursorMode := XBPBRW_CURSOR_CELL
      ENDIF

      IF ::W_ROWLINESEPARATOR
         ::lRowLine := .T.
      ENDIF

      // Simone 14/9/2005
      // mantis 0000883: poter definire header delle colonne su più righe
      ::setHeadRows( ::W_HEADERROWS )

      ::vScroll := dfAnd(::W_MOUSEMETHOD, W_MM_VSCROLLBAR) != 0
      ::hScroll := dfAnd(::W_MOUSEMETHOD, W_MM_HSCROLLBAR) != 0

      ::S2Browser:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

      // Aggiungo il menu PopUp
      ::oPopUpMenu:create(NIL, NIL, NIL, ::W_KEYBOARDMETHODS)
      S2ItmSetColors({||NIL}, {|n|::setColorBack(n)}, .T., ::W_COLORARRAY[AC_FRM_BACK])
   ENDIF
RETURN self

METHOD S2BrowseBox:tbStab( lForce )
   LOCAL xRet
   DEFAULT lForce TO .F.

   //IF dfRecourse(); RETU self; END

   IF lForce .OR. ::W_OBJREFRESH

      IF ::W_LOADARRAYFUNCTION <> NIL .AND.; 
         VALTYPE(::W_LOADARRAYFUNCTION) == "B"
         xRet := EVAL(::W_LOADARRAYFUNCTION,Self,lForce )
         IF VALTYPE(xRet) == "A"
            //tbArrLen( self, LEN(xRet) ) 
            ::W_AI_LENGHT := LEN(xRet)
            /////////////////////////////////////////////////////////////////
            ////Mantis 2236 -> Aggiornato il 23/10/2013
            ////Inserito per correzione del 11/10/2013 segnalato da Cavallone.
            //IF LEN(xRet) < ::W_CURRENTREC //Se il numero dei righi da mostrare Š inferiore alla posizione del listbox
            //   ::W_CURRENTREC := 1
            //ENDIF 
            //

       // ------------------------------------------------------------------------------------------
       // Se non inizializzato, W_TAGARRAY deve essere NIL
       // ------------------------------------------------------------------------------------------   
          ::W_TAGARRAY   := IIF(Valtype(::W_TAGONLOAD)=="B", eval(::W_TAGONLOAD, xRet), IIF(Valtype(::W_TAGARRAY)=="A", {}, NIL))    
//             ::W_TAGARRAY   := IIF(Valtype(::W_TAGONLOAD)=="B", eval(::W_TAGONLOAD, xRet), {})    
          ELSE
            ::W_TAGARRAY   := IIF(Valtype(::W_TAGARRAY)=="A", {}, NIL)
//             ::W_TAGARRAY := {}   

          ENDIF 
          ::W_CURRENTREC   := 1

          // ------------------------------------------------------------------------------------
          //   Siamo all'interno di un lForce := .T. di un array dinamico
          //   tbstab(.T.) viene richiamato da un tbDisItm, ovvero dalla funzione da template xxxUPW() 
          //   ne consegue che siamo in navigazione della form xxx, per cui:
          //   o azzero ::W_TAGARRAY oppure lo valorizzo con ::W_TAGONLOAD
          //   ------------------------------------------------------------------------------------ 
          //IF lForce .OR. LEN(::W_TAGARRAY) > ::W_AI_LENGHT
          //  ::W_TAGARRAY      := {}     
          //ENDIF 
          //   ------------------------------------------------------------------------------------    
          /////////////////////////////////////////////////////////////////
      ENDIF 

      ::OptChk()

      ::W_IS2TOTAL := .T.
      ::S2Browser:tbStab(lForce)
      ::W_IS2TOTAL := .F.
      ::W_OBJREFRESH := .F.
      //tbRecCng( self ) // Aggiorno W_CURRENTREC   
      //Riattivato per problemi di refresh recnum corrente
      tbRecCng( self ) // Aggiorno W_CURRENTREC
   ENDIF
RETURN self

METHOD S2BrowseBox:tbColPut( lDisplay )

   DEFAULT lDisplay TO .T.

   ::S2Browser:tbColPut( lDisplay )

   // IF ::isVisible()
   IF !::W_IS2TOTAL // Se e' attivo questo flag sono in uno stabilize
      IF lDisplay
         ::tbStab( .T. )
      ENDIF
   ENDIF


RETURN self

METHOD S2BrowseBox:SetInputFocus()
   IF ::oOwner != NIL
      ::oOwner:hilite()
   ENDIF
RETURN self

METHOD S2BrowseBox:KillInputFocus()
   IF ::oOwner != NIL
      ::oOwner:dehilite()
   ENDIF
RETURN self

METHOD S2BrowseBox:tbEval(bEval)
   LOCAL xPos := EVAL(::phyPosBlock)
   LOCAL nSkip := 1

   EVAL(::GoTopBlock)

   DO WHILE ! ( (::W_ALIAS)->(EOF()) .OR. EVAL(::W_BREAK) .OR. nSkip <> 1)
      IF EVAL(::W_FILTER)
         EVAL(bEval)
      ENDIF

      nSkip := EVAL(::SkipBlock, 1)
   ENDDO

   EVAL(::phyPosSet,  xPos)
RETURN NIL

METHOD S2BrowseBox:handleAction( cAct, cState )
   LOCAL lAct := ::S2Window:handleAction( cAct, cState )
   IF ! lAct .AND. tbIsFast(self)
      tbFastSeek(self)
      lAct := .T.
   ENDIF
RETURN lAct

METHOD S2BrowseBox:KeyBoard( nKey )
   IF ACT $ "tab,ret"
      ::oForm:skipFocus(1)

   ELSEIF ACT $ "Stb"
      ::oForm:skipFocus(-1)
   ELSE
      ::S2Browser:keyboard(nKey)
   ENDIF
RETURN self

// Aggiungo le varibili per compatibilit…
CLASS S2BrowserCompatibility
   EXPORTED:
      VAR headSep, footSep, colSep
ENDCLASS


