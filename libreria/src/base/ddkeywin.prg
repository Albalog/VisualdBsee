/******************************************************************************
 Progetto       : Tutorial
 Sottoprogetto  : Tutorial
 Programma      : C:\DBSEEWIN\SEARCH\TUTORIAL\source\ddKey.prg
 Template       : C:\DBSEEWIN\SEARCH\TUTORIAL\bin\form.tmp
 Descrizione    : Ricerca Informazioni
 Programmatore  : Demo
 Data           : 07-04-06
 Ora            : 17.21.45
******************************************************************************/

                                                     //<<000138>> File include del programma
#INCLUDE "Common.ch"                                 //<<000139>> Include define comunemente utilizzate
#INCLUDE "dfCtrl.ch"                                 //<<000140>>   "       "    per control
#INCLUDE "dfGenMsg.ch"                               //<<000141>>   "       "     "  messaggi
#INCLUDE "dfIndex.ch"                                //<<000142>>   "       "     "  ddIndex()
#INCLUDE "dfLook.ch"                                 //<<000143>>   "       "     "  dbLook()
#INCLUDE "dfMenu.ch"                                 //<<000144>>   "       "     "  menu di oggetto
#INCLUDE "dfNet.ch"                                  //<<000145>>   "       "     "  network
#INCLUDE "dfSet.ch"                                  //<<000146>>   "       "     "  settaggi di ambiente
#INCLUDE "dfWin.ch"                                  //<<000147>>   "       "     "  oggetti Visual dBsee

#INCLUDE "dfMsg.ch"
#INCLUDE "dfMsg1.ch"
#INCLUDE "dfOptFlt.ch"
#include "appevent.ch"
#include "DFXBASE.CH"

MEMVAR Act

// simone 19/4/06
// mantis 0001040: implementare nuova finestra di ricerca dati


//#define TAG_SEARCH "%search%"
//#define TAG_ALIAS  "%alias%"

#define IDX_NUMBER 1
#define IDX_DEX    2

#define MESSAGEAREA_HEIGHT   22

#define TAG_LIST_SEP "-"

// array necessario per gestione del filtro (DFCOMPILE())
// necessario se si implementano più ddKey aperte contemporaneamente
STATIC aDDKeys := {}

FUNCTION ddKeyArrFind(o)
RETURN ASCAN(aDDKeys,o)

FUNCTION ddKeyArrGet(n)
   IF VALTYPE(n)=="O"
      n := ddKeyArrFind(n)
   ENDIF
RETURN IIF(n>=1 .AND. n <= LEN(aDDKeys),aDDKeys[n],NIL)

// ritorna la stringa di ricerca standard (su pagina 1) 
// della ddKey con numero passato
FUNCTION ddKeyGetSearch(n, num)
   LOCAL o := ddKeyArrGet(n)
   LOCAL a, nI
   LOCAL xRet := NIL

   DO CASE
      CASE num == NIL
         xRet := IIF(o == NIL, "", o:cSearch)

      CASE num == 0  .AND. o == NIL // conta quanti token ci sono saltando i token vuoti
         xRet := 0

      CASE num == 0  .AND. o != NIL // conta quanti token ci sono saltando i token vuoti
         a := dfStr2Arr(o:cSearch, " ")
         xRet := 0
         AEVAL(a, {|x| xRet += iif(empty(x), 0, 1)})

      CASE num > 0   .AND. o == NIL // ritorna token <num>
         xRet := ""

      CASE num > 0   .AND. o != NIL // ritorna token <num> saltando i token vuoti
         xRet := ""

         a    := dfStr2Arr(o:cSearch, " ")
         nI   := 0
         DO WHILE ++nI <= LEN(a) 
            IF EMPTY(a[nI]) // salta vuoti
               LOOP
            ENDIF
            IF --num == 0  // trovato?
               xRet := a[nI]
               EXIT
            ENDIF
         ENDDO
   ENDCASE

RETURN xRet

// Imposta un'ottimizzazione ad un browse, in base ad apps.ini
// default=ottimiz. filtro
// by reference torna il tipo filtro (NO,INDEX,FILTER)
FUNCTION ddKeyFilterType(cNew,cRet,lForceFilter)
   STATIC cSet := NIL

   //Mantis 1631
   DEFAULT cSet TO IIF(dfSet( AI_DISABLEKEYINDEX ), "NO", "INDEX")
   DEFAULT lForceFilter TO .F.

   cRet := cSet

   IF VALTYPE(cNew)$"CM"
      cNew := UPPER(ALLTRIM(cNew))
      IF cNew =="NO" .OR. cNew=="INDEX" .OR. cNew == "FILTER"
         cSet := cNew
      ENDIF
   ELSEIF lForceFilter .AND. !cRet=="NO"
      cRet := "FILTER"
   ENDIF
   DO CASE
      CASE cRet == "NO"    // Disattiva
         RETURN NIL

      CASE cRet == "INDEX" // Usa indice
         RETURN ddKeyOptIndex():new()
   ENDCASE
RETURN ddKeyOptFilter():new()

// imposta/ritorna il nome del file XML delle impostazioni
// n=0 ritorna il file xml standard
// n=1 ritorna il file xml utente (per avere impostazioni diverse)
FUNCTION ddKeySettings(x)
   STATIC aFiles
   LOCAL aRet

   IF aFiles==NIL //  inizializza
      
      // Tommaso - Dovrebbe prendere sempre prima quello utente
      //           vedi uso nella funzione RecSearch:init()
      //           in extra i files da leggere vengono impostati dentro il menu.prg
      aFiles := { dbCfgPath("dbddPath")+"ddKeyUsr.xml", ;
                  dbCfgPath("dbddPath")+"ddKey.xml" }
//      aFiles := { dbCfgPath("dbddPath")+"ddKey.xml", ;
//                  dbCfgPath("dbddPath")+"ddKeyUsr.xml" }
   ENDIF

   aRet := aFiles
   IF VALTYPE(x) $ "A"
      aFiles := x
   ENDIF
RETURN aRet


*******************************************************************************
FUNCTION ddKeyAndWin( nTbOrd    ,; //<<000037>> Indice
                bTbKey    ,; //<<000038>> Chiave
                bTbFlt    ,; //<<000039>> Filtro
                bTbBrk    ,; //<<000040>> Break
                bEval     ,;  // Eval before seek
                lLockIndex,; // Abilita solo l'indice corrente
                oSearch   ,; 
                cSearch)  
*******************************************************************************
//STATIC nWin    := 0
LOCAL  lRet    := .F.                                //<<000044>> Valore ritornato
//LOCAL  oSearch
LOCAL  n
LOCAL aFile := {}
LOCAL cAlias:= ALIAS()
LOCAL cForm := M->EnvId
/////////////////////////////////////////////////////////////////////
//Mantis 2154 Luca 6/05/2011
LOCAL cOldSetGetAutofill := dfSet("XbaseGetAutoFill", "NO") 
/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////
LOCAL cOldAutoScroll := dfSet(AI_XBASEFORMSCROLL, AI_FORMSCROLL_DISABLED  )
/////////////////////////////////////////////////////////////////////
LOCAL oOriWin := S2FormCurr()
////////////////////////////////////////////////////////////////////////////////////////////
//Nuovo settaggio per permettere il merge del filtro ddkey con quello dalla form di chiamata
////////////////////////////////////////////////////////////////////////////////////////////
LOCAL lMergeddKeyFilter := dfSet("XbaseMergeFormAndddKeyFilter")  == "YES"
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

PRIVATE  EnvId:="ddKey" ,SubId:=""                   //<<000149>> Identificativi per help


////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
/* ---------------------------------------------------------------------
   Modifica effettuata per permettere l'ereditarieta'
   del tbSetKey() della Form di Origine
   --------------------------------------------------------------------- */
   IF lMergeddKeyFilter
      IF !EMPTY(oOriWin:W_ALIAS)                 .AND.;
         lower(oOriWin:W_ALIAS) == lower(cAlias) .AND.;
         Valtype(oOriWin:W_FILTER) == "B"
         IF !EMPTY(bTbFlt)
            bTbFlt := dfMergeBlocks(bTbFlt, oOriWin:W_FILTER, ".AND.")
         ELSE 
            bTbFlt := oOriWin:W_FILTER
         ENDIF 
         ddKeyFilterType("FILTER")
      ENDIF
   ENDIF
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////




//nWin++
//IF nWin==1

   IF dfUse(cAlias,NIL,aFile)
   
      DEFAULT oSearch TO RecSearch():new(cAlias,cForm, nTBOrd, bTBKey, bTbFlt, bTbBrk ,NIL)

      // aggiungo alla lista
      AADD(aDDKeys,oSearch)
      
      lRet := oSearch:exe(cSearch)
      IF (cAlias)->(EOF()) //se sono su EOF ripristino record
         ACT:="esc"
      ENDIF
      
      // tolgo da lista
      n := ddKeyArrFind(oSearch)
      IF n > 0
         // metto a NIL l'elemento
         aDDKeys[n] := NIL
         
         // tolgo tutti i NIL dalla lista partendo da fondo 
         DO WHILE .T.
            n := LEN(aDDKeys)
            IF n == 0 // se non ci sono elementi esco
               EXIT
            ENDIF
            IF aDDKeys[n] != NIL // se ne trovo uno non a NIL esco
               EXIT
            ENDIF
            AREMOVE(aDDKeys,n)
         ENDDO
      ENDIF
   ENDIF
   dfClose(aFile, ACT == "esc", ACT == "esc")
//ENDIF
//nWin--

  /////////////////////////////////////////////////////////////////////
  //Mantis 2154 Luca 6/05/2011
  IF !EMPTY(cOldSetGetAutofill)
     dfSet("XbaseGetAutoFill", cOldSetGetAutofill) 
  ENDIF 
  /////////////////////////////////////////////////////////////////////
  IF !EMPTY(cOldAutoScroll)
     dfSet(AI_XBASEFORMSCROLL, cOldAutoScroll )
  ENDIF 



RETURN lRet

* ----------------------------------------------------------
// Classe principale per gestione ricerca

CLASS RecSearch
PROTECTED:
   METHOD act
   METHOD get
   METHOD LoadLastSearch
   METHOD setupPage2
   METHOD LocalizeCB
   METHOD _addGlobalFilter
   METHOD _SetFilter
   METHOD buildFilter
   
//EXPORTED:
   VAR cAlias
   VAR cForm
   
   VAR oWin
   
   VAR cmbIdx
   VAR cmbSearch
   VAR lsbRec
   //~ VAR oFilter
   VAR aLastSearch
   VAR oData
   VAR cPrevFlt
   VAR cPrevSea
   VAR aKFB
   VAR lFilter // = .T. se ha filtro su pag.2

   VAR bFlt
   VAR bFlt1

   METHOD calcOffset

EXPORTED:
   VAR cSearch
   VAR nIndex
   VAR cIndex

   METHOD init
   METHOD create
   METHOD destroy
   METHOD exe
   METHOD print
   METHOD SetLastSearch
   METHOD SetIndex
   METHOD setFilter
   METHOD clearFilter
   METHOD isSetFilter
   METHOD optGetFlt
   METHOD cmbItemSelected
   METHOD cmbKeyboard
  
   METHOD Anr
   METHOD Mcr
   METHOD Ecr

   // simone 10/12/09
   // XL1509 - aggiunta espressione per eventualmente scegliere quale operazione fare
   METHOD checkValidAction
ENDCLASS

*******************************************************************************
METHOD RecSearch:init(cAlias, cForm, n, key,flt,brk, aSettings)
*******************************************************************************
   LOCAL cSearch
//   LOCAL aSettings
   LOCAL nInd
   LOCAL nErr

   DEFAULT cAlias TO ALIAS()
   DEFAULT cForm  TO M->EnvId
   DEFAULT n      TO (cAlias)->(INDEXORD())   
   
   // defaut a NIL perchè è gestito meglio quando si fa il merge con i codeblock 
   // di filtro generati nella ::_SetFilter() 
   // (se è NIL pu= mettere direttamente il codeblock generato)
   DEFAULT flt    TO NIL 
   
   DEFAULT brk    TO {|| .F.}
   
   cSearch  := space(60)

   ::cAlias := cAlias
   ::cForm  := cForm
   ::oWin   := NIL
   ::cmbIdx := NIL
   ::cmbSearch := NIL
   ::lsbRec := NIL
   ::cPrevFlt := NIL // inizializzo a NIL così forza il primo clearFilter nella ::create()
   ::cPrevSea := ""
   ::lFilter := .F.
   //~ ::oFilter:= RecSearchFilter():new()

   ::oData  := RecSearchData():new()
   
   ::aLastSearch := ::LoadLastSearch(cAlias,cForm)
   ::aKFB := {key,flt,brk}

   ::cSearch:= cSearch
   ::nIndex := n
   
   ::cIndex := space(60)
//   ::cFlt   := "" 

   IF ! EMPTY(aSettings)
      FOR nInd := 1 TO LEN(aSettings)
         nErr := aSettings[nInd]:load( ::oData, cAlias, cForm, aSettings[nInd], ::aKFB)
         IF nErr >= 0
            EXIT
         ELSEIF nErr != -10  // se errore non è form non trovata nel file XML
            dbMsgErr(dfStdMsg(MSG_ERRSYS11)+" "+cAlias+" ("+ALLTRIM(STR(nErr))+")")
         ENDIF
      NEXT
   ENDIF

   IF EMPTY(aSettings) .OR. nInd > LEN(aSettings)
   // prova a caricare info da file XML utente
   aSettings := ddKeySettings()
   FOR nInd := 1 TO LEN(aSettings)
      IF ! FILE( aSettings[nInd] )
         LOOP
      ENDIF
      nErr := RecSearchDataXML():load( ::oData, cAlias, cForm, aSettings[nInd], ::aKFB)
      IF nErr >= 0 
         EXIT
      ELSEIF nErr != -10  // se errore non è form non trovata nel file XML
         dbMsgErr(dfStdMsg(MSG_ERRSYS11)+" "+aSettings[nInd]+" ("+ALLTRIM(STR(nErr))+")")
      ENDIF
   NEXT
   ENDIF

   IF nInd > LEN(aSettings) // se non caricato da file XML?
      // se non riesce prova da file DBDD
      RecSearchDataDBDD():load( ::oData, cAlias, cForm)
   ENDIF
RETURN self

*******************************************************************************
METHOD RecSearch:exe(cSearch)
*******************************************************************************
   LOCAL lRet := .T.
   LOCAL aFile:= {}
   LOCAL nSel := SELECT()
   LOCAL lOk  := .T.
   LOCAL aTables
   LOCAL n
   LOCAL nRecno

   ///////////////////////////////
   //Correzione mantis 2212 per problema Focus su uscita dalla ddkeyandwin
   //luca 09/04/2012
   ///////////////////////////////
   LOCAL oWin := S2FormCurr()
   ///////////////////////////////

   aTables := ::oData:aTables
   IF ! EMPTY(aTables)
      // apertura tabelle collegate
      FOR n := 1 TO LEN(aTables)
         // se tabella principale la salto perchŠ non devo ripristinare il record nella dfClose()!
         IF ! UPPER(ALLTRIM(aTables[n])) == UPPER(ALLTRIM(::cAlias))
            IF ! dfUse(aTables[n], NIL, aFile)
               lOk := .F.
               EXIT
            ENDIF
         ENDIF
      NEXT
   ENDIF

   IF lOk
   ::create(cSearch)

   //////////////////////////////// 
   //Luca 10/07/2013  
   //Verificato che se richiamata la ddkey su Browser o windows si ha un strano sfarfallio.   
   _VDBWaitAllEvents(::oWin)
    /////////////////////////////
    lRet := ::Get(DE_STATE_MOD,cSearch )

      // simone 02/10/09 - XL981
      // il destroy Š lento se c'Š il filtro attivo
      // perchŠ nel destroy() richiama il setSize che 
      // fa un forceStable nella listbox e questo pu• 
      // essere lento
      nRecno := (::cAlias)->(RECNO())
      ::clearFilter()
      (::cAlias)->(DBGOTO(nRecno))

   ::destroy()
   ENDIF
   //dfClose(aFile, .T., .T.)
   dfClose(aFile, ACT == "esc", ACT == "esc")
   DBSELECTAREA(nSel)


   ///////////////////////////////
   //Correzione mantis 2212 per problema Focus su uscita dalla ddkeyandwin
   //luca 09/04/2012
   ///////////////////////////////
   IF !EMPTY(oWin) 
      oWin:setFocus()
   ENDIF 
   ///////////////////////////////

RETURN lRet

*******************************************************************************
METHOD RecSearch:calcOffSet(oWin)
*******************************************************************************
   LOCAL nPos := 0
   IF oWin:UseMainToolbar()
      nPos += oWin:toolBarHeight
   ELSE
      //luca:Mantis 2222 del 29/05/2013
      //Correzione posizione campi di ricerca troppo alti quando l'altezza della toolbar Š diversa dallo standard 26 px.
      ///////////////////////////////////////  
   	  IF oWin:toolBarHeight <> TOOLBAR_DEFAULT_HEIGHT
   	     nPos -= int(oWin:toolBarHeight -TOOLBAR_DEFAULT_HEIGHT)
   	  ENDIF   
      ///////////////////////////////////////  
   ENDIF
   IF oWin:UseMainStatusLine()
      nPos += MESSAGEAREA_HEIGHT // altezza statusline
   ENDIF
RETURN nPos

*******************************************************************************
METHOD RecSearch:create(cSearch)
*******************************************************************************
   LOCAL aLastSearch := ::aLastSearch
   LOCAL oWin 
   LOCAL aKeys
   LOCAL aIdx
   LOCAL oXbp
   LOCAL drawingArea
   LOCAL nX
   LOCAL aSize
   LOCAL aPos
   LOCAL nPos
   LOCAL oParent
   LOCAL aCtrl
   LOCAL objCtrl
   LOCAL aResizeList
   LOCAL cFocus := ""
   //aInh   := arrInh                                  //<<000055>> Riassegna array campi ereditati
   //cState := cMode                                   //<<000056>> Riassegna lo stato sulla modalit… operativa

   oWin := ::Act()                                     //<<000058>> Attivazione oggetto

   // descrizione indice corrente
   IF ::nIndex >= 1 .AND. ::nIndex <= LEN(::oData:aIdx)
      ::cIndex := ::oData:aIdx[::nIndex][IDX_DEX]
   ENDIF

   tbConfig( oWin )                               //<<000151>> Riconfigura i parametri interni dell'oggetto ( vedere Norton Guide )

   //////////////////////////////////////
   //Mantis 2194
   //Abilitata la gestione Full screen sulla apertura ddkey 
   IF !empty(dfSet("XbaseddKeyWinopenfullscreen")) .AND. dfSet("XbaseddKeyWinopenfullscreen") == "YES" 
      //oWin:lCenter     := .F.
      //oWin:lFullScreen := .T.
      oWin:setFullScreen()

   ENDIF 
   //////////////////////////////////////
   //////////////////////////////////////

/*
   // aggiusta dimensioni se non c'Š toolbar o statuline
   aSize := oWin:currentSize()
   IF oWin:UseMainToolbar()
      aSize[2] -= oWin:toolBarHeight
   ENDIF
   IF oWin:UseMainStatusLine()
      aSize[2]  -= MESSAGEAREA_HEIGHT // altezza statusline
   ENDIF
   oWin:setSize(aSize, .F.)
*/
   // aggiusta dimensioni se non c'Š toolbar o statuline
   nPos := ::calcOffSet(oWin)

   // invio su listbox = seleziona e chiude
   ::lsbRec:itemSelected := {||dbAct2Kbd("wri")}

   drawingArea := oWin:searchObj("btnDelFilter")[1]:setParent()
   oXbp := oWin:searchObj("saySearch")[1]
   nX := oXbp:currentPos()[1]+oXbp:currentSize()[1]
   nX += 4

   // se toolbar e/o statusbar su menu principale sposto tutto pi— in alto
   IF nPos != 0
      oXbp := oWin:searchObj("btnDelFilter")[1]
      aPos := oXbp:currentPos()
      aPos[2] += nPos
      oXbp:setPos(aPos)

      oXbp := oWin:searchObj("saySearch")[1]
      aPos := oXbp:currentPos()
      aPos[2] += nPos
      oXbp:setPos(aPos)

      oXbp := oWin:searchObj("sayIndex")[1]
      IF ! EMPTY(oXbp)
         aPos := oXbp:currentPos()
         aPos[2] += nPos
         oXbp:setPos(aPos)
      ENDIF

      oXbp := oWin:searchObj("lsbRec")[1]
      aSize:= oXbp:currentSize()
      aSize[2] += nPos
      oXbp:setSize(aSize)

      oXbp := oWin:searchObj("box0007")[1]
      IF ! EMPTY(oXbp)
         aSize:= oXbp:currentSize()
         aSize[2] += nPos
         oXbp:setSize(aSize)
      ENDIF
   ENDIF

   // crea combobox per ricerca standard
   //oXbp := _AddUsrControl(oWin,"XbpComboBox",{nX,300+nPos}, {370,150},1,.T., "tab,Stb,ret,rar,lar")
//FUNCTION _AddUsrControl  (oWin, cUsrClass, aUsrPos, aUsrSize,nPage,lEdit, cActs)
//FUNCTION dfUserControlNew(oWin, oParent, nPage, aCtrl, cUsrClass, xEdit, cActs)

   // metto i combo dove c'Š la listbox
   oParent     := oWin:searchObj("lsbRec")[1]:setParent()
   ///////////////////////////////////////////////////////
   IF IsMemberVar(oWin:getCtrlArea(.T.),"aResizeList")
      aResizeList := oWin:getCtrlArea(.T.):aResizeList[1]
   ELSE 
     oWin:lFullScreen := .F.
     aResizeList  := {}
   ENDIF 
   ///////////////////////////////////////////////////////
   objCtrl     := oWin:getObjCtrl()

   aCtrl := {}

   ATTACH "ctrl1" TO aCtrl USERCB        ; // ATTCMB.TMP
                    {|w, p, n, a, d| dfUserControlNew(w, p, n, a, "XbpComboBox", ;
                                                     .T., "tab,Stb,ret,rar,lar")   }  ;
                    AT  300+nPos, nX    ; // Coordinate dato in get
                    PAGE 1               ;
                    SIZE { 370, 150}       // <<000021>>Dimensioni Campo get

   aCtrl := aCtrl[1]


   // eseguo codeblock per creare un nuovo oggetto
   oXbp := EVAL(aCtrl[FORM_UCB_CB], oWin, oParent, aCtrl[FORM_CTRL_PAGE], aCtrl, NIL)
   oXbp:tabstop := .F.
   oXbp:create()
   oXbp:killInputFocus := {|u1,u2,o| ::cmbItemSelected(o)}
   oXbp:itemSelected   := {|u1,u2,o| ::cmbItemSelected(o) }
   oXbp:keyboard       := dfMergeBlocks({|k, u2, o| ::cmbKeyboard(k, o)},;
                                        oXbp:keyboard)
   
   AEVAL(aLastSearch,{|x| oXbp:addItem(x)})
   
   oXbp:xHotAct := "A_e" // Cerca

   // aggiungo a lista oggetti del form
   AADD(objCtrl, oXbp)
   IF LEN(aResizeList) >= 1
      AADD(aResizeList[1], ATAIL(objCtrl))
   ENDIF
   ::cmbSearch := oXbp
   
   aKeys   := ::oData:aIdx //::LoadIdx(::cAlias,::cForm)                                //
   IF LEN(aKeys) > 1 // se ha piu di 1 indice
      oXbp := oWin:searchObj("sayIndex")[1]
      nX := oXbp:currentPos()[1]+oXbp:currentSize()[1]
      nX += 4
      aIdx    := {}
      AEVAL(aKeys, {|x|AADD(aIdx, x[IDX_DEX])})
      
      // crea combobox per selezione indice
      //oXbp := _AddUsrControl(oWin,"XbpComboBox",{nX,270+nPos}, {370,150},1,.T., "tab,Stb,ret,rar,lar")
      aCtrl := {}

      ATTACH "ctrl2" TO aCtrl USERCB        ; // ATTCMB.TMP
                       {|w, p, n, a, d| dfUserControlNew(w, p, n, a, "XbpComboBox", ;
                                                        .T., "tab,Stb,ret,rar,lar")   }  ;
                       AT  270+nPos, nX    ; // Coordinate dato in get
                       PAGE 1               ;
                       SIZE { 370, 150}       // <<000021>>Dimensioni Campo get

      aCtrl := aCtrl[1]

      // eseguo codeblock per creare un nuovo oggetto
      oXbp := EVAL(aCtrl[FORM_UCB_CB], oWin, oParent, aCtrl[FORM_CTRL_PAGE], aCtrl, NIL)

      oXbp:tabstop := .F.
      oXbp:type := XBPCOMBO_DROPDOWNLIST
      oXbp:create()
      oXbp:killInputFocus := {|u1,u2,o| ::SetIndex() }
      oXbp:itemSelected  := {|u1,u2,o| ::SetIndex() }
      AEVAL(aIdx,{|x| oXbp:addItem(x)})
      oXbp:setData( ::nIndex )
      oXbp:xHotAct := "A_o" // Ordinamento
      
      // aggiungo a lista oggetti del form
      AADD(objCtrl, oXbp)
      IF LEN(aResizeList) >= 1
         AADD(aResizeList[1], ATAIL(objCtrl))
      ENDIF
      ::cmbIdx := oXbp
   ENDIF
   
   //tbDisItm( oWin ,"#") il refresh lo fa nella :clearFilter

   // imposta il filtro standard
 
   IF !EMPTY(cSearch)
      ::cSearch := cSearch
      ::cmbSearch:xbpsle:setData( cSearch )
      ::clearFilter( .T., .F. )
   ELSE
      ::clearFilter( .T. )
   ENDIF 


   IF !empty(dfSet("XbaseddKeyWinopenfullscreen")) .AND. dfSet("XbaseddKeyWinopenfullscreen") == "YES" 

      cFocus := dfSet("XbaseddKeyAndWinFocus")
      IF ! EMPTY( cFocus) .AND. UPPER(ALLTRIM(cFocus))=="SEARCH"
         //Setappfocus(::cmbSearch)
         tbGetGoto(::ACT(), "ctrl1")
         _VDBWaitAllEvents(::oWin)
      ENDIF
   ENDIF 

   
RETURN self

*******************************************************************************
METHOD RecSearch:cmbItemSelected(o)
*******************************************************************************
   ::cSearch := o:XbpSle:getData()
   ::SetLastSearch()
RETURN self

*******************************************************************************
METHOD RecSearch:cmbKeyboard(k, o)
*******************************************************************************
//   IF (k==xbeK_UP .OR. k==xbeK_DOWN)
//      IF EMPTY( o:XbpListbox:getData())
//         tbGetGoto(::ACT(), "lsbRec")
//         //PostAppEvent( xbeP_Keyboard, k, NIL, ::act():searchObj("lsbRec")[1])
//      ELSEIF M->ACT=="win"
//         o:listboxFocus(! o:listBoxFocus())
//      ENDIF
//   ENDIF
   IF M->ACT $"uar,dar"
      tbGetGoto(::ACT(), "lsbRec")
   ELSEIF M->ACT=="win"
      o:listboxFocus(! o:listBoxFocus())
   ENDIF
RETURN self

*******************************************************************************
METHOD RecSearch:destroy()
*******************************************************************************
   ::oWin   := tbEnd( ::oWin , W_OC_RESTORE)                         // <<000160>>( vedere Norton Guide )

   ::cmbSearch := NIL
   ::cmbIdx := NIL
   ::lsbRec := NIL
   //~ ::oFilter:= NIL
   ::oData  := NIL
   ::aKFB   := NIL
RETURN self

*******************************************************************************
METHOD RecSearch:Act()                                  // [ 03 ] <<000065>>INIZIALIZZA OGGETTO
*******************************************************************************
   LOCAL aPfkItm
   LOCAL oWin := ::oWin
   LOCAL aKeys
   LOCAL aIdx
   LOCAL cmbIdx
   LOCAL lsbRec
   //~ LOCAL oFilter 
   LOCAL n
   LOCAL cSort
   LOCAL aSortCol
   LOCAL nInd
   LOCAL nAdd
   LOCAL aCol
   LOCAL cHead
   LOCAL bBlock
   LOCAL nWidth
   LOCAL cmbSearch
   LOCAL aLastSearch
   LOCAL nHeight
   LOCAL cStdFlt
   LOCAL bKey
   LOCAL bFlt
   LOCAL bBrk
   LOCAL cAlias
   LOCAL nTotWidth
   LOCAL oData 

   IF oWin!=NIL
      RETURN oWin
   ENDIF                       //<<000068>> Si ritorna l'oggetto se gi… inizializzato

   M_Cless()                                            //<<000069>> Stato di attesa con mouse a clessidra

   //~ oFilter := ::oFilter
   cAlias  := ::cAlias
   aCol    := ::oData:aLsbCol 
   cStdFlt := ::oData:cStdFlt
   aKeys   := ::oData:aIdx 
   bKey    := ::aKFB[1]
   bFlt    := ::aKFB[2]
   bBrk    := ::aKFB[3]
   oData   := ::oData
   
   DEFAULT bFlt TO {||.T.}

   oWin := 0->(TbBrwNew(  760                        ,; // <<000007>>Prima  Riga
                            0                        ,; // <<000008>>Prima  Colonna
                          576                        ,; // <<000009>>Ultima Riga
                          630                        ,; // <<000010>>Ultima Colonna
                         W_OBJ_FRM                             ,; // <<000010>>Tipo oggetto ( form )
                         NIL ,; // <<000011>>Label
                         W_COORDINATE_PIXEL                    )) // <<000012>>Gestione in Pixel

   
   oWin:W_TITLE     := IIF(::oData:cTitle == NIL, dfStdMsg1(MSG1_DDKEYWIN0000), ::oData:cTitle)
   //////////////////////////////////////////////
   //Modifca luca del 6/9/2007 del 1576
   /////////////////////////////////////////////
   oWin:W_TITLE     := dbMMrg(oWin:W_TITLE)
   /////////////////////////////////////////////


           //<<000013>> Titolo oggetto
   oWin:W_KEY       := NIL                              //<<000016>> Non esegue la seek
   oWin:W_FILTER    := {||.T.}                          //<<000018>> CodeBlock per il filtro
   oWin:W_BREAK     := {||.F.}                          //<<000021>> CodeBlock per il break
   
   oWin:W_PAGELABELS:= {}                               //<<000022>> Array delle pagine
   oWin:W_PAGECODEBLOCK:= {}
   oWin:W_PAGERESIZE:= {}

   ATTACH PAGE LABEL dfStdMsg1(MSG1_DDKEYWIN0010) TO oWin:W_PAGELABELS 
   ATTACH PAGE CODEBLOCK {||.T.} TO oWin:W_PAGECODEBLOCK
   ATTACH PAGE RESIZE {271, 165} TO oWin:W_PAGERESIZE
   ATTACH PAGE LABEL dfStdMsg1(MSG1_DDKEYWIN0020)  TO oWin:W_PAGELABELS 
   ATTACH PAGE CODEBLOCK {||.T.} TO oWin:W_PAGECODEBLOCK
   ATTACH PAGE RESIZE {272, 165} TO oWin:W_PAGERESIZE

   oWin:W_MENUHIDDEN:= .T.                              //<<000023>> Stato attivazione barra azioni
   oWin:W_COLORARRAY[AC_FRM_BACK  ] := "B+/G"           //<<000024>> Colore di FONDO
   oWin:W_COLORARRAY[AC_FRM_BOX   ] := "B+/G"           //<<000025>> Colore di BOX
   oWin:W_COLORARRAY[AC_FRM_HEADER] := "RB+/B*"         //<<000026>> Colore di HEADER ON
   oWin:W_COLORARRAY[AC_FRM_OPTION] := "W+/BG"          //<<000027>> Colore di ICONE

   oWin:W_BG_TOP ++
   oWin:W_RP_TOP ++
   oWin:nTop++

   oWin:border   := XBPDLG_RAISEDBORDERTHICK
   oWin:lCenter  := .T.
   oWin:icon     := APPLICATION_ICON
   oWin:sysMenu  := .T.
   oWin:minButton:= .T.
   oWin:maxButton:= .T.


   oWin:W_MOUSEMETHOD := W_MM_PAGE + W_MM_SIZE + W_MM_MOVE +W_MM_MINIMIZE+ W_MM_MAXIMIZE   //<<000006>> Inizializzazione ICONE per mouse



   //~ ATTACH "1" TO MENU oWin:W_MENUARRAY AS MN_LABEL    ; // ACTMNU.TMP
           //~ BLOCK    {||MN_ON }  ; //<<000006>> Condizione di stato di attivazione
           //~ PROMPT   "^File"                           ; //<<000008>> Etichetta
           //~ EXECUTE  {||dbMsgErr( dfStdMsg( MSG_ADDMENUUND ) )}  ; //<<000010>> Funzione
           //~ MESSAGE  "Operazioni su file corrente"     ; //<<000011>> Messaggio utente
           //~ IMAGES  0                                  ; //
           //~ ID "0023000192"
   //ATTACH "Z1" TO MENU oWin:W_MENUARRAY AS MN_LABEL  ; //
   //        BLOCK    {||if((cState$"iam"),MN_SECRET,MN_OFF)}  ; //<<000071>> Condizione di stato di attivazione
   //        PROMPT   dfStdMsg( MSG_FORMESC )           ; // Label
   //        SHORTCUT "esc"                             ; //<<000074>> Azione (shortcut)
   //        EXECUTE  {||lBreak:=.T.}                   ; //<<000075>> Funzione
   //        MESSAGE  dfStdMsg( MSG_FORMESC )             // Message
   //ATTACH "Z2" TO MENU oWin:W_MENUARRAY AS MN_LABEL  ; //
   //        BLOCK    {||if((cState$"am"),MN_SECRET,MN_OFF)}  ; //<<000077>> Condizione di stato di attivazione
   //        PROMPT   dfStdMsg( MSG_FORMWRI )           ; // Label
   //        SHORTCUT "wri"                             ; //<<000080>> Azione (shortcut)
   //        EXECUTE  {||Act:="wri"}                    ; //<<000081>> Funzione
   //        MESSAGE  dfStdMsg( MSG_FORMWRI )             // Message
   ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
           EXECUTE {||dbAct2Kbd("wri")}               ; //
           WHEN    {|| .T. }              ; //
           RUNTIME {||.T.}                            ; //
           PROMPT  dfStdMsg1(MSG1_DDKEYWIN0050)            ;
           TOOLTIP dfStdMsg1(MSG1_DDKEYWIN0050)            ;
           IMAGES  TOOLBAR_WRITE_H                    ; //
           ID "0023000196"
   ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
           EXECUTE {||dbAct2Kbd("esc")}               ; //
           WHEN    {|| .T. }             ; //
           RUNTIME {||.T.}                            ; //
           PROMPT   dfStdMsg1(MSG1_DDKEYWIN0060)           ; //
           TOOLTIP dfStdMsg1(MSG1_DDKEYWIN0060)  ; //
           IMAGES  TOOLBAR_ESC_H                      ; //
           ID "0023000197"
   ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP


   // simone 13/12/10 XL 2319
   // poter mettere controllo accessi per utente su stampa tabella/stampa etichette
   nHeight := IIF(EMPTY(aKeys) .OR. LEN(aKeys) == 1,420,390)

   lsbRec := (cAlias)->(tbBrwNew(     0             ,; // <<000006>>Prima  Riga
                                     10             ,; // <<000007>>Prima  Colonna
                                    nHeight         ,; // <<000008>>Ultima Riga
                                    590             ,; // <<000009>>Ultima Colonna
                                   W_OBJ_BROWSEBOX  ,; // <<000010>>List-Box su FILE
                                   NIL              ,; // <<000011>>Label
                                   W_COORDINATE_PIXEL )) // <<000012>>Gestione in Pixel


   IF tbChkPrn(lsbRec, "DDKEYWIN-CHECK")
   ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
           EXECUTE {||::print()}                        ; //
              WHEN    {|| tbChkPrn(lsbRec, "DDKEYWIN-WHEN") }             ; //
              RUNTIME {|| tbChkPrn(lsbRec, "DDKEYWIN-RUNTIME")}                            ; //
           PROMPT  dfStdMsg1(MSG1_DDKEYWIN0030)                           ;
           TOOLTIP dfStdMsg1(MSG1_DDKEYWIN0040)            ;
           IMAGES  TOOLBAR_PRINT                      ; //
           ID "0023000201"
   ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
   ENDIF
   ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
           EXECUTE {||dbAct2Kbd("hlp")}               ; //
           WHEN    {|| .T. }             ; //
           RUNTIME {||.T.}                            ; //
           PROMPT   dfStdMsg1(MSG1_DDKEYWIN0070)                      ; //
           TOOLTIP dfStdMsg1(MSG1_DDKEYWIN0070)                       ; //
           IMAGES  TOOLBAR_HELP_H                     ; //
           ID "0023000199"
   ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
           EXECUTE {||dbAct2Kbd("ush")}               ; //
           WHEN    {|| .T. }             ; //
           RUNTIME {||.T.}                            ; //
           PROMPT   dfStdMsg1(MSG1_DDKEYWIN0080)                ; //
           TOOLTIP dfStdMsg1(MSG1_DDKEYWIN0080)                 ; //
           IMAGES  TOOLBAR_KEYHELP_H                  ; //
           ID "0023000200"

   ATTACH "box0007" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                    AT   10,  10, 435, 600            ; // Coordinate
                    BOXTEXT dfStdMsg1(MSG1_DDKEYWIN0090)    ; // BOX Text
                    COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                    BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                    PAGE  2                           ; // Pagina
                    COLOR {"W+/G","B+/G","N/G"}         // Array dei colori


   lsbRec:W_TITLE      := dfStdMsg1(MSG1_DDKEYWIN0100)                    //<<000011>> Titolo oggetto browse
   IF ! EMPTY(::nIndex)
      lsbRec:W_ORDER := ::nIndex
   ENDIF
   lsbRec:W_KEY        := bKey                         //<<000013>> Non esegue la seek
   lsbRec:W_FILTER     := bFlt                          //<<000015>> CodeBlock per il filtro
   lsbRec:W_BREAK      := bBrk                         //<<000018>> CodeBlock per il break
   lsbRec:W_COLORARRAY[AC_LSB_BACK  ]      := "N/W*"    //<<000019>> Colore fondo
   lsbRec:W_COLORARRAY[AC_LSB_TOPLEFT]     := "N/G"    //<<000020>>    "   bordo superiore
   lsbRec:W_COLORARRAY[AC_LSB_BOTTOMRIGHT] := "BG/G"    //<<000021>>    "   bordo inferiore
   lsbRec:W_COLORARRAY[AC_LSB_PROMPT]      := "GR+/G"    //<<000022>>    "   prompt
   lsbRec:W_COLORARRAY[AC_LSB_HILITE]      := "W+/BG"    //<<000023>>    "   prompt selezionato
   lsbRec:W_COLORARRAY[AC_LSB_HOTKEY]      := "G+/G"    //<<000024>>    "   hot key
   lsbRec:COLORSPEC    := "N/W*"
   ATTACH REFRESH GROUP "lsbRec" TO lsbRec:W_R_GROUP
   lsbRec:W_LINECURSOR:= .T.
   lsbRec:W_HEADERROWS := 1

   ADDKEY "ret" TO lsbRec:W_KEYBOARDMETHODS          ; // Tasto su List Box
          BLOCK   {||dbAct2Kbd("wri")}                ; // Funzione sul tasto
          WHEN    {|s| (s $ "iam") }                  ; // Condizione di stato di attivazione
          RUNTIME {||.T.}                             ; // Condizione di runtime
          MESSAGE dfStdMsg1(MSG1_DDKEYWIN0110)                         // Messaggio utente associato   
   ADDKEY "Ctb" TO lsbRec:W_KEYBOARDMETHODS          ; // Tasto su List Box
          BLOCK   {||tbPgSkip(oWin,1)}                ; // Funzione sul tasto
          WHEN    {|s| (s $ "iam") }                  ; // Condizione di stato di attivazione
          RUNTIME {||.T.}                             ; // Condizione di runtime
          MESSAGE dfStdMsg1(MSG1_DDKEYWIN0120)                         // Messaggio utente associato   
   ADDKEY "Cst" TO lsbRec:W_KEYBOARDMETHODS          ; // Tasto su List Box
          BLOCK   {||tbPgSkip(oWin,-1)}                ; // Funzione sul tasto
          WHEN    {|s| (s $ "iam") }                  ; // Condizione di stato di attivazione
          RUNTIME {||.T.}                             ; // Condizione di runtime
          MESSAGE dfStdMsg1(MSG1_DDKEYWIN0130)                   // Messaggio utente associato   


   // simone 10/12/09
   // XL1509 - aggiunto TIPO AZIONE per eventualmente scegliere quale operazione fare
   ADDKEY "ecr" TO lsbRec:W_KEYBOARDMETHODS ;
                WHEN {||dfSet(AI_FILEMODIFY) .AND. ;
                        EVAL( dfSet( AI_FILEINSERTCB ), ALLTRIM(cAlias), DE_STATE_DEL ) .AND. ;
                        ::checkValidAction(oData:cEnableEcr)} ;
                BLOCK {|oWin|(cAlias)->(::Ecr(lsbRec))} ;
                MESSAGE dfStdMsg(MSG_DE_STATE_DEL)

   ADDKEY "mcr" TO lsbRec:W_KEYBOARDMETHODS ;
                WHEN {||dfSet(AI_FILEMODIFY) .AND. ;
                        EVAL( dfSet( AI_FILEINSERTCB ), ALLTRIM(cAlias), DE_STATE_MOD ) .AND. ;
                        ::checkValidAction(oData:cEnableMcr)} ;
                BLOCK {|oWin|(cAlias)->(::Mcr(lsbRec))} ;
                MESSAGE dfStdMsg(MSG_DE_STATE_MOD)

   ADDKEY "anr" TO lsbRec:W_KEYBOARDMETHODS ;
                WHEN {||dfSet(AI_FILEMODIFY) .AND. ;
                        EVAL( dfSet( AI_FILEINSERTCB ), ALLTRIM(cAlias), DE_STATE_ADD ) .AND. ;
                        ::checkValidAction(oData:cEnableAnr)} ;
                BLOCK {|oWin|(cAlias)->(::Anr(lsbRec))} ;
                MESSAGE dfStdMsg(MSG_DE_STATE_ADD)

   // imposta filtro come codeblock
   //~ n := ddKeyArrFind(self)
   //~ cStdFlt := STRTRAN(::oData:cStdFlt,TAG_SEARCH,"ddKeyGetSearch("+ALLTRIM(STR(n))+")")

   //~ bFlt := dfMergeBlocks(bFlt,DFCOMPILE(cStdFlt))
   //~ DEFAULT bFlt TO {|| .T.}
   //~ lsbRec:W_FILTER := bFlt

   // filtro per ottimizzatore (COMMENTATO PERCHE' IGNORATO IN LIBRERIA)
   //~ cStdFlt := STRTRAN(::oData:cStdFlt,TAG_SEARCH,"cSearch")
   //~ lsbRec:W_STRFILTER     := cStdFlt
   //~ LsbRec:W_OPTIMIZEMETHOD:= {|oOpt| oOpt := ddKeyFilterType(), ;
                                     //~ IIF(EMPTY(oOpt),NIL,oOpt:AddVar( "cSearch", {|| ::cSearch} )), ;
                                     //~ oOpt}
   nTotWidth := 0
  //Mantis 2183
   LsbRec:W_OPTIMIZEMETHOD:= {|oOpt| oOpt := ddKeyFilterType()                  , ;
                                     IIF(oOpt<>NIL, oOpt:AddVar( "bFlt" , {|| ::optGetFlt() } ),NIL) , ;
                                     IIF(oOpt<>NIL, oOpt:AddVar( "bFlt1", {|| ::optGetFlt(1)} ),NIL) }

   // ordino in base all'indice
   aSortCol := {}
   cSort := ""
   IF (! EMPTY(lsbRec:W_ALIAS) .AND. ! EMPTY(lsbRec:W_ORDER))
      cSort := (lsbRec:W_ALIAS)->(ORDKEY(lsbRec:W_ORDER))
   ENDIF
   IF EMPTY(cSort)
      aSortCol := aCol
   ELSE
      // ordino le colonne in base all'indice
      nInd := 1000
   FOR n := 1 TO LEN(aCol)
         IF EMPTY(aCol[n][2][4]) .OR. ;
            (nAdd := AT( (UPPER( ALLTRIM(aCol[n][2][4])) + "+"), cSort + "+"))==0
//            (nAdd := AT( UPPER( ALLTRIM(aCol[n][2][4])), cSort))==0

            nAdd := nInd++
         ENDIF
         AADD(aSortCol, {nAdd, aCol[n][2]})
      NEXT
      ASORT(aSortCol,,,{|x,y|x[1]<y[1]})
   ENDIF
   FOR n := 1 TO LEN(aSortCol)
      cHead := aSortCol[n][2][1]
      cHead := dbMMrg(cHead)
      bBlock:= aSortCol[n][2][2]
      nWidth:= aSortCol[n][2][3]
      nTotWidth += nWidth
      tbAddColumn( lsbRec,                         ;// Oggetto padre
                   bBlock,              ;// Blocco
                   nWidth, ;// LarghezzaLEN(dfAny2Str(EVAL(bBlock)))
                   "",                           ;// ID
                   cHead,              ;// Intestazione di colonna
                   ,                             ;// Code Block per le totalizzazioni
                   ,                             ;// Picture per i dati
                   ,                             ;// Picture per i totali
                   ,                             ;// Label sul footer
                   ,                             ;// Code block da chiamare in SYS
                   ,                             ;// Edit di cella
                   ,                             ;// Messaggio associato
                   NIL)                        // Array dei colori
   NEXT

    //////////////////////////////////////
   //Mantis 2194
   //Abilitata la gestione Full screen sulla apertura ddkey 
   // abilito il fitcolumns solo se c'Š spazio vuoto a destra
   IF nTotWidth <= 60  .OR.;
     (nTotWidth <= 120  .AND. !empty(dfSet("XbaseddKeyWinopenfullscreen")) .AND. dfSet("XbaseddKeyWinopenfullscreen") == "YES" )
      lsbRec:lFitColumns := .T.
      lsbRec:W_MOUSEMETHOD:= W_MM_EDIT + W_MM_VSCROLLBAR
   ELSE
      lsbRec:W_MOUSEMETHOD:= W_MM_EDIT + W_MM_HSCROLLBAR + W_MM_VSCROLLBAR
   ENDIF
  
   
   ATTACH "lsbRec" TO oWin:W_CONTROL GET AS LISTBOX USING lsbRec  ; // <<000005>>ATTLSB.tmp
                    COORDINATE  W_COORDINATE_PIXEL    ; // <<000009>>Coordinate in Pixel
                    ACTIVE   {||.T. }           // <<000008>>Stato di attivazione

   ATTACH "saySearch" TO oWin:W_CONTROL SAY dfStdMsg1(MSG1_DDKEYWIN0140) ;
                 AT  430,  4                      ; // Coordinate dato in get
                 SIZE       { 70,22}              ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL   ; // Coordinate in Pixel
                 ALIGNMENT  XBPALIGN_RIGHT + XBPALIGN_VCENTER   

                 
   IF LEN(aKeys) > 1 // se ha piu di 1 indice
      ATTACH "sayIndex" TO oWin:W_CONTROL SAY dfStdMsg1(MSG1_DDKEYWIN0150) ;
                    AT  400,  4                     ; // Coordinate dato in get
                    SIZE       { 70, 22}            ; // Dimensioni Campo get
                    COORDINATE  W_COORDINATE_PIXEL  ; // Coordinate in Pixel
                    ALIGNMENT  XBPALIGN_RIGHT + XBPALIGN_VCENTER   
                    
   ENDIF
   ATTACH "btnDelFilter" TO oWin:W_CONTROL GET AS PUSHBUTTON dfStdMsg1(MSG1_DDKEYWIN0160)  ; // ATTBUT.TMP
                    AT  425, 509,  30, 100            ; // Coordinate
                    COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                    COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                    FUNCTION {|| ::clearFilter() }  ; // Funzione di controllo
                    MESSAGE ""                          // Messaggio utente

//                    ACTIVE   {|| ::isSetFilter() }         ; // Stato di attivazione

   ATTACH "btnSetFilter" TO oWin:W_CONTROL GET AS PUSHBUTTON dfStdMsg1(MSG1_DDKEYWIN0170)  ; // ATTBUT.TMP
                    AT   30, 490,  30, 100            ; // Coordinate
                    COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                    PAGE        2                     ; // Pagina
                    COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                    FUNCTION {||::setFilter()}            ; // Funzione di controllo
                    MESSAGE ""                          // Messaggio utente


   // aggiunta campi generici su pagina 2
   ::setupPage2(oWin, ::oData:aGetFie)

   M_Normal()                                           //<<000084>> Stato mouse normale

   //////////////////////////////////////
   //////////////////////////////////////
   //Mantis 2193
   //Abilitata la gestione di attivare anche sulla ddkey la gestione line di separazione come sulle listbox standard VDB
   IF !empty(dfSet("XbaseddKeyWinLineseparator")) .AND. dfSet("XbaseddKeyWinLineseparator") == "YES" 
      lsbRec:W_ROWLINESEPARATOR := .T.
   ENDIF 
   //////////////////////////////////////
   //////////////////////////////////////


   ::oWin   := oWin
   ::lsbRec := lsbRec
RETURN oWin

// aggiunta campi generici su pagina 2
*******************************************************************************
METHOD RecSearch:setupPage2(oWin, aGetFie)
*******************************************************************************
   LOCAL bActive := {|| .T.}
   LOCAL num := 0
   LOCAL nInd
   LOCAL oGet
   LOCAL cPrompt
   LOCAL cPicGet
   LOCAL cPicSay
   LOCAL bGet
   LOCAL cMsg
   LOCAL aForm
   LOCAL oCvt

   aForm := oWin:W_CONTROL
   num := 450-26-26 + ::calcOffSet(oWin)
   FOR nInd := 1 TO LEN(aGetFie)
      oGet := aGetFie[nInd]

      cPrompt := oGet:cPrompt

      cPicGet := oGet:cPic
      cPicSay := cPicGet
      bGet    := ::LocalizeCB(oGet)
      cMsg    := oGet:cMessage

      // imposta il buffer dei campi in input
      DO CASE
         CASE oGet:cType == "C"
            oGet:xBuffer := SPACE( oGet:nLen ) 
         CASE oGet:cType == "M"
            oGet:xBuffer := SPACE( 60 )
         CASE oGet:cType == "N"
            oGet:xBuffer := 0
         CASE oGet:cType == "L"
            oGet:xBuffer := .F.
         CASE oGet:cType == "D"
            oGet:xBuffer := CTOD("")
      ENDCASE

//ATTACH "CodCat" TO oWin:W_CONTROL GET CodCat AT  320, 130  ; // ATTGET.TMP
//                 SIZE       {  44,  22}            ; // Dimensioni Campo get
//                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
//                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
//                 PAGE        0                     ; // Pagina
//                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
//                 PROMPT   "Codice Categoria:"      ; // Prompt
//                 PROMPTAT  320 , -14               ; // Coordinate prompt
//                 PICTURESAY "!!"                   ; // Picture in say
//                 CONDITION {|ab|CodCat(ab)}        ; // Funzione When/Valid
//                 MESSAGE "Codice Categoria"        ; // Messaggio
//                 VARNAME "CodCat"                  ; //
//                 REFRESHID "Articoli"              ; // Appartiene ai gruppi di refresh
//                 COMBO                             ; // Icona combo
//                 ACTIVE {||cState $ "am" }          // Stato di attivazione
//ATTACH "say0033" TO oWin:W_CONTROL SAY "Ora:" AT   80, 420  ; // ATTSAY.TMP
//                 SIZE       {  30,  30}            ; // Dimensioni Campo get
//                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
//                 ALIGNMENT XBPALIGN_DEFAULT        ; // SAY ALIGNMENT
//                 PAGE      0                       ; // Pagina
//                 COLOR    {"N/G"}                    // Array dei colori
      oCvt :=PosCvt():new(LEN(cPicGet), 1)

      ATTACH "say"+ALLTRIM(STR(100+nInd))   TO aForm SAY cPrompt ;
                                AT Num, 14    ;
                                SIZE       { PosCvt():new(21, 0):nXWin-14 ,  oCvt:nYWin}            ; // Dimensioni Campo get
                                COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                                ALIGNMENT XBPALIGN_RIGHT ; // GET ALIGNMENT
                                PAGE 2                  

      ATTACH "X"+ALLTRIM(STR(100+nInd))   TO aForm GET bGet  ;
                                AT Num, PosCvt():new(22, 0):nXWin              ; // aPgPromptSize[nPGCounter] ;
                                SIZE       {  MAX(oCvt:nXWin, 50),  oCvt:nYWin}            ; // Dimensioni Campo get
                                COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                                ALIGNMENT XBPALIGN_LEFT ; // GET ALIGNMENT
                                PAGE 2                  ;
                                PICTUREGET cPicGet      ;
                                PICTURESAY cPicSay      ;
                                COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                                MESSAGE cMsg            ;
                                REFRESHID oWin:W_ALIAS  ; // Appartiene ai gruppi di refresh
                                ACTIVE bActive            // Stato di attivazione

//                                PROMPT  cPrompt         ;
//                                PROMPTAT Num, -14 ; //Num, 21-LEN(cPrompt)         ;

      // L'attach per default crea un codeblock di get su bGet
      // la cosa deve essere corretta
      ATAIL(aForm)[FORM_GET_VAR]       := bGet
      ATAIL(aForm)[FORM_GET_CONDITION] := {|| .T.}
      ATAIL(aForm)[FORM_GET_ACTIVE]    := bActive

      num-=26
      //~ IF nInd < ::oFGL:getNumFields() .AND. ;  // pagina nuova???
         //~ num * ROW_SIZE > aFormDim[2]
         //~ nPage++
         //~ AADD(oWin:W_PAGELABELS, cPageTitle +" ("+S2NTrim(++nPGCounter)+")")
         //~ num:=0
      //~ ENDIF
   NEXT
RETURN self   

*******************************************************************************
METHOD RecSearch:Get(cState, cSearch)
*******************************************************************************
   LOCAL  lRet    := .F.                                // <<000098>> Flag di registrazione dati se .T.
   LOCAL  oWin    := ::oWin
   LOCAL cFocus
 
   IF !EMPTY(cSearch)                                  
      tbGetVar( ::owin, "ctrl1",cSearch )
      tbDisItm( ::owin, "ctrl1")
      ::cmbSearch:xbpsle:setData( cSearch )
   ENDIF 
   tbGetTop(oWin,.T.)

   cFocus := dfSet("XbaseddKeyAndWinFocus")
   IF ! EMPTY( cFocus) .AND. UPPER(ALLTRIM(cFocus))=="SEARCH"
      dbAct2Kbd("A_e") // focus su Cerca!
   ENDIF

   DO WHILE( .T. )
      ////////////////////////////////////////////////////////////////////
      //Luca 14/10/2015 inserito per prossimo rilascio perche Š capitato un errore in questa fase sul caricamento di un caption .
      Sleep(10) 
      ////////////////////////////////////////////////////////////////////
      IF ! tbGet( oWin , NIL ,DE_STATE_MOD)       //  Modulo gestore delle get
         EXIT
      ENDIF

      // intercetto F10 su seconda pagina per attivare il filtro
      IF tbPgActual(oWin) != 1
         ::setFilter()
         LOOP
      ENDIF


      lRet := .T.
      EXIT                                              //  Uscita dopo aggiornamento dati
   ENDDO
RETURN lRet

*******************************************************************************
METHOD RecSearch:Print()
*******************************************************************************
   // simone 13/12/10 XL 2319
   // poter mettere controllo accessi per utente su stampa tabella/stampa etichette
   IF tbChkPrn(::lsbRec, "DDKEYWIN-EXEC")
   tbPrnWin(::lsbRec)
   ENDIF
RETURN .T.

// ricarica elenco ultimi testi ricercati
*******************************************************************************
METHOD RecSearch:LoadLastSearch(cAli,cForm)
*******************************************************************************
RETURN {}

// aggiorna elenco ultimi testi ricercati e imposta il filtro
*******************************************************************************
METHOD RecSearch:SetLastSearch()
*******************************************************************************
   LOCAL c := ALLTRIM(::cSearch)
   LOCAL aLastSearch := ::aLastSearch
//   LOCAL cFlt := ::oData:cStdFlt
//   LOCAL oErr

   IF ACT == "esc"
      RETURN .F.
   ENDIF

   IF c == ::cPrevSea // non faccio refresh se non ho cambiato ricerca
      RETURN .F.
   ENDIF
   ::cPrevSea := c

   // aggiorna array ultime ricerche
   IF ! EMPTY(c) .AND. ASCAN(aLastSearch,{|x|x==c}) == 0
      AADD(aLastSearch,c)
      ::cmbSearch:addItem(c)
   ENDIF
   //~ ::clearFilter()
   tbBrwRefresh(::lsbRec, .T.)
   // se sono su EOF e ho impostato il filtro do un messaggio
   IF ((::cAlias)->(EOF()) .OR. (::cAlias)->(BOF())) .AND. ;
      ! EMPTY(c) 
      dfAlert(dfStdMsg1(MSG1_DDKEYWIN0180))

      IF ::cmbSearch:isEnabled()
         dbAct2Kbd("A_e")
      ENDIF
   ENDIF
RETURN .T.

// imposta l'indice
*******************************************************************************
METHOD RecSearch:SetIndex()
*******************************************************************************
   LOCAL c 
//   LOCAL cFlt := ::oData:cStdFlt
//   LOCAL oErr

   IF ACT == "esc"
      RETURN .F.
   ENDIF

   c := ::cmbIdx:getData()
   IF EMPTY(c)
      RETURN .F.
   ENDIF
   c := c[1]
   IF c >= 1 .AND. c <= LEN(::oData:aIdx)
      c := ::oData:aIdx[c]
      IF ! c[1]  == ::lsbRec:W_ORDER
         tbSetKey(::lsbRec, c[1], NIL, ::lsbRec:W_FILTER)
         tbTop(::lsbRec)
         //tbBrwRefresh(::lsbRec, .T.) // posiziona la primo record
      ENDIF
   ENDIF
RETURN .T.

*******************************************************************************
METHOD RecSearch:LocalizeCB(o)
*******************************************************************************
   LOCAL oGet := o
RETURN {|x| IIF(x==NIL, oGet:xBuffer, oGet:xBuffer := x)}

// Imposta il filtro dei campi su pagina 2
*******************************************************************************
METHOD RecSearch:setFilter()
*******************************************************************************
   LOCAL cFlt := ::buildFilter( ::cAlias, ::oData:aGetFie )
   ::_SetFilter(cFlt)
   // se sono su EOF e ho impostato il filtro do un messaggio
   IF ((::cAlias)->(EOF()) .OR. (::cAlias)->(BOF())) .AND. ;
      ! EMPTY(cFlt) 
      dfAlert(dfStdMsg1(MSG1_DDKEYWIN0180))
   ENDIF
RETURN self

*******************************************************************************
METHOD RecSearch:clearFilter(lSaveRec,lReset )
*******************************************************************************
   DEFAULT lReset TO .T.

   IF lReset
   ::cSearch := ""
   ENDIF 

   ::cmbSearch:xbpsle:setData( ::cSearch )
   ::_SetFilter("", lSaveRec)
   ::SetLastSearch()
RETURN self

*******************************************************************************
METHOD RecSearch:optGetFlt(n)
******************************************************************************
IF EMPTY(n)
   RETURN ::bFlt
ENDIF
RETURN ::bFlt1

// Simone 21/09/09 XL 1352
// Modifica per assegnazione filtro globale alla ddkeyandwin
// altrimenti il filtro non veniva ottimizzato
*******************************************************************************
METHOD RecSearch:_addGlobalFilter(cFlt)
*******************************************************************************
   LOCAL cNewFilt
   LOCAL oRecSearch := self
   LOCAL xRet, oErr
   IF !EMPTY(oRecSearch:oData:cGlobalFilter) 

      cNewFilt := oRecSearch:oData:cGlobalFilterEvaluateIF
      IF EMPTY(cNewFilt) .OR. UPPER(ALLTRIM(cNewFilt))==".T."
         cNewFilt   := oRecSearch:oData:cGlobalFilter
      ELSE
         cNewFilt   := STRTRAN(cNewFilt, "%alias%", ALLTRIM(oRecSearch:cAlias))
         cNewFilt   := STRTRAN(cNewFilt, "%ALIAS%", ALLTRIM(oRecSearch:cAlias))

         xRet := dfMacro(oErr, cNewFilt)

         cNewFilt := ".T." // per default non applico il filtro globale
         IF ! EMPTY(oErr)
            // errore
            //dbMsgErr("Filtro non valido "+cNewFilt)
         ELSEIF VALTYPE(xRet)=="L" .AND. xRet
            // devo Applicare il filtro globale
            cNewFilt   := oRecSearch:oData:cGlobalFilter
         ENDIF
      ENDIF

      IF ! UPPER(ALLTRIM(cNewFilt)) == ".T."
         cNewFilt   := STRTRAN(cNewFilt, "%alias%", ALLTRIM(oRecSearch:cAlias))
         cNewFilt   := STRTRAN(cNewFilt, "%ALIAS%", ALLTRIM(oRecSearch:cAlias))
         IF EMPTY(cFlt) .OR. UPPER(ALLTRIM(cFlt))==".T."
            cFlt := cNewFilt
         ELSE
            cFlt := "("+cNewFilt+") .AND. ("+cFlt+")"
         ENDIF
      ENDIF 
   ENDIF 
RETURN cFlt


*******************************************************************************
METHOD RecSearch:_SetFilter(cFlt, lSaveRec)
*******************************************************************************
   LOCAL bFlt
   LOCAL bFlt1
   LOCAL bFlt2
   LOCAL lsbRec
   LOCAL oRecSearch := self
   LOCAL n, nI, nMax
   LOCAL cStdFlt
   LOCAL nCurrRec
   LOCAL nAtIni
   LOCAL nAtFin
   LOCAL bFltAgg
   LOCAL cFltAgg
   LOCAL cNewFlt
   
   IF ! cFlt == ::cPrevFlt

      // Simone 01/03/10 XL1869
      // abilitato il posizionamento al record corrente solo all'apertura 
      // della finestra di ricerca, in modo che le ricerche sia da ricerca 
      // generica su pagina 1 che ricerca avanzata su pagina 2 una volta impostate
      // mostrino sempre il primo record
      //
      // Simone 29/10/09 - XL 1117
      // al primo posizionamento lasciare il record corrente
      IF ! EMPTY(lSaveRec) .AND. ! (::cAlias)->(EOF())
      //IF  ! (::cAlias)->(EOF())
         nCurrRec := (::cAlias)->(RECNO())
      ENDIF

      ::cPrevFlt := cFlt
      
      lsbRec := oRecSearch:lsbRec
      bFlt := oRecSearch:aKFB[2]
      
//Maudp-LucaC 24/06/2013 Il filtro aggiuntivo deve andare appunto in aggiunta a quello standard
******************************************************************************************************
//      IF EMPTY(cFlt)
         // imposta il filtro standard su pagina 1
         n := ddKeyArrFind(self)
         
         // numero di parole da controllare
         // per ricerca generica full text
         nMax := oRecSearch:oData:nMaxWords
/*
         // es. XbaseDDKeyTextSearchMax=0 disabilita
         //     XbaseDDKeyTextSearchMax=10 abilita 10 parole
         // non funziona con ADS perchè c'è errore 
         // in creazione indice
         IF ! EMPTY( dfSet("XbaseDDKeyTextSearchMax") )
            nMax := VAL(dfSet("XbaseDDKeyTextSearchMax"))
         ENDIF
*/
         IF nMax > 1
            cStdFlt := ""
            FOR nI := 1 TO nMax
               cStdFlt += ".AND. ("+dfMsgTran(::oData:cStdFlt,;
                                    "search=ddKeyGetSearch("+ALLTRIM(STR(n))+", "+ALLTRIM(STR(nI))+")", ;
                                    "alias="+::cAlias)+")"
            NEXT
            cStdFlt := SUBSTR(cStdFlt, 6) //salto .AND. iniziale
         ELSE
            cStdFlt := dfMsgTran(::oData:cStdFlt,;
                        "search=ddKeyGetSearch("+ALLTRIM(STR(n))+")", ;
                        "alias="+::cAlias)
         ENDIF

         //Maudp 23/04/2013 XL 3927 Aggiunta gestione di un filtro aggiuntivo messo nella ddkey tramite la sintassi <<S2Filter()>>
         nAtIni := AT("<<",cStdFlt)
         IF nAtIni > 0
            nAtFin := AT(">>",cStdFlt, nAtIni+2)
            IF nAtFin > 0
               nAtIni += 2
               //Prelevo la funzione da eseguire
               cFltAgg    := SUBSTR(cStdFlt, nAtIni, nAtFin-nAtIni)
               IF !EMPTY(cFltAgg)
                  bFltAgg := &("{|p0,p1,p2,p3,p4,p5,p6,p7,p8|" + cFltAgg + "}")
                  cNewFlt := EVAL(bFltAgg,::cAlias)
                  IF !EMPTY(cNewFlt)
                     //Sostituisco la funzione con l'espressione da valutare
                     cStdFlt := STRTRAN(cStdFlt,"<<"+cFltAgg+">>",cNewFlt)
                  ENDIF
               ENDIF
            ENDIF
         ENDIF

//Maudp-LucaC 24/06/2013 Il filtro aggiuntivo deve andare appunto in aggiunta a quello standard
******************************************************************************************************
      IF !EMPTY(cFlt)
         IF !EMPTY(cStdFlt)
            cStdFlt += " .AND. (" + cFlt + ")"
         ELSE
            cStdFlt := cFlt
         ENDIF
      ENDIF
******************************************************************************************************

         // Simone 21/09/09 XL 1352
         //Modifica per assegnazione filtro globale alla ddkeyandwin
         bFlt1 := _DFCOMPILE(::_addGlobalFilter( cStdFlt) )
/*
      ELSE
         // Simone 21/09/09 XL 1352
         //Modifica per assegnazione filtro globale alla ddkeyandwin
         bFlt1 := _DFCOMPILE(::_addGlobalFilter(cFlt))
      ENDIF
*/

      IF bFlt == NIL .OR. UPPER(ALLTRIM(dfCodeBlock2String(bFlt))) == ".T."
         bFlt2 := bFlt1
         ::bFlt    := NIL
         ::bFlt1   := NIL

      ELSEIF bFlt1 == NIL .OR. UPPER(ALLTRIM(dfCodeBlock2String(bFlt1))) == ".T."
         bFlt2 := bFlt
         ::bFlt    := NIL
         ::bFlt1   := NIL

      ELSE
         bFlt2 := {|| EVAL(bFlt) .AND. EVAL(bFlt1) }
         ::bFlt    := bFlt
         ::bFlt1   := bFlt1
      ENDIF

      DEFAULT bFlt2 TO {|| .T.}

      ::lFilter := ! EMPTY(cFlt)

      tbPgGoto(oRecSearch:oWin, 1)

      // aggiorna il filtro sulla listbox
      tbSetKey(lsbRec, lsbRec:W_ORDER, NIL, bFlt2)
      tbDisItm(oRecSearch:oWin)

      // Simone 29/10/09 - XL 1117
      // al primo posizionamento lasciare il record corrente
      IF nCurrRec == NIL
      tbTop(lsbRec)
      ELSE
         (::cAlias)->(DBGOTO(nCurrRec))

         // Simone 01/03/10 XL1869
         // se il record corrente non rientra nel filtro dell'indice
         // faccio un TOP perchŠ altrimenti nella tbRtr() verrebbe 
         // fatto uno skip ed essendo un record che non rientra 
         // nell'indice va a EOF e quindi mostra gli ultimi record 
         // invece dei primi
         IF (::cAlias)->(! EMPTY(ORDFOR()) .AND. ! EVAL( dfCompile( ORDFOR() )))
            tbTop(lsbRec)
         ELSE
         // faccio 2 tbStab perchŠ se il record corrente
         // non rientra nel filtro allora al primo giro non ce la fa!
         //tbStab(lsbRec, .T.)
         tbRtr(lsbRec)
      ENDIF
      ENDIF

      //tbBrwRefresh(lsbRec)
      IF ! EMPTY(cFlt)
         oRecSearch:cmbSearch:disable()
         oRecSearch:cmbSearch:setData(dfStdMsg1(MSG1_DDKEYWIN0190))
      ELSE
         oRecSearch:cmbSearch:enable()
         oRecSearch:cmbSearch:setData("")
      ENDIF
   ENDIF
RETURN .T.


*******************************************************************************
METHOD RecSearch:isSetFilter()
*******************************************************************************
RETURN ::lFilter

*******************************************************************************
METHOD RecSearch:buildFilter(cAli,aCol)
*******************************************************************************
   LOCAL cFlt := ""
   LOCAL n
   LOCAL xValue
   LOCAL cMask
   LOCAL xBuffer
   
   //~ cFlt := ".OR. EMPTY(%sea%)"   

   FOR n := 1 TO LEN(aCol)
      xBuffer := aCol[n]:xBuffer
      IF EMPTY(xBuffer)
         // salto il campo vuoto
         cMask := ""
      ELSEIF aCol[n]:cType $ "CM"
         xValue := xBuffer
         xValue := UPPER(ALLTRIM(xBuffer))
         xValue := STRTRAN(xValue,'"','') // tolgo la "
         xValue := '"'+xValue+'"'
         
         cMask := ".AND. %search% $ UPPER(ALLTRIM(%alias%->%field%))" 
      ELSEIF aCol[n]:cType $ "N"
         xValue := ALLTRIM(STR(xBuffer))
         cMask := ".AND. %search% == %alias%->%field%"
      ELSEIF aCol[n]:cType $ "D"
         xValue := '"'+DTOS(xBuffer)+'"'
         cMask := ".AND. %search% == DTOS(%alias%->%field%)"
      ELSE
         cMask := ""
      ENDIF
      IF ! EMPTY(cMask)
         cFlt += dfMsgTran(cMask,"search="+xValue,;
                           "field="+aCol[n]:cName,;
                           "len="+ALLTRIM(STR(aCol[n]:nLen)),;
                           "dec="+ALLTRIM(STR(aCol[n]:nDec)))
      ENDIF
   NEXT
   cFlt := dfMsgTran(cFlt,"alias="+cAli)

   cFlt := SUBSTR(cFlt,6)
RETURN cFlt

// simone 10/12/09
// XL1509 - aggiunta espressione per eventualmente scegliere quale operazione fare
*******************************************************************************
METHOD RecSearch:checkValidAction(b) 
*******************************************************************************
   LOCAL cAlias := ::cAlias
   LOCAL cForm  := ::cForm
   LOCAL aKFB   := ::aKFB

   IF EMPTY(b) .OR. "-"+UPPER(ALLTRIM(b))+"-" $ "-TRUE-YES-.T.-" 
      RETURN .T.
   ENDIF
   IF "-"+UPPER(ALLTRIM(b))+"-" $ "-FALSE-NO-.F.-" 
      RETURN .F.
   ENDIF

   b := dfMsgTran(b, "alias=" + cAlias                , ;
                     "form="  + cForm                 , ;
                     "key="   + dfExpCastEval(aKFB[1], ""), ;
                     "filter="+ dfExpCast(aKFB[2], ""), ;
                     "break=" + dfExpCast(aKFB[3], "")  )
   b := _DFCOMPILE(b)
   b := _DFEVAL(b)
RETURN VALTYPE(b)=="L" .AND. b

*******************************************************************************
METHOD RecSearch:Ecr( oWin ) // Erase
*******************************************************************************
   LOCAL cDel := ALLTRIM(ALIAS()) +"DID()" // Metodo del dbRid per cancellazione
   LOCAL lDel := .F.

   IF ! ::checkValidAction(::oData:cEnableEcr)
      RETURN .F.
   ENDIF

   dfPushAct()
   IF Bof() .OR. Eof()
      dbMsgErr( dfStdMsg(MSG_DDWIN03) )
   ELSE
      IF dfYesNo( dfStdMsg(MSG_DDWIN04), .F. )
         IF dfIsFun( cDel )            // Se ho il metodo di DEL
            dfPushArea()
            lDel := &cDel
            dfPopArea()
         ELSE
            IF dfNet( NET_RECORDLOCK )     // Altrimenti uso un delete normale
               DBDELETE(); DBCOMMIT()
               dfNet( NET_RECORDUNLOCK )
               lDel := .T.
            ENDIF
         ENDIF
         IF lDel; tbEtr( oWin ); ENDIF
      ENDIF
   ENDIF
   dfPopAct()
RETURN lDel

*******************************************************************************
METHOD RecSearch:Mcr( oWin ) // Modify
*******************************************************************************
   LOCAL cExe:= "<unk>"
   LOCAL bEval
   LOCAL bErr
   LOCAL oErr
   LOCAL lOk

   IF ! ::checkValidAction(::oData:cEnableMcr)
      RETURN .F.
   ENDIF

   dfPushAct()
   IF Bof() .OR. Eof()
      dbMsgErr( dfStdMsg(MSG_DDWIN05) )
   ELSE
      cExe := ::oData:cEdit
      // simone 10/12/09 
      // aggiunta possibilità di cambiare/disattivare edit di default
      IF EMPTY(cExe)
         cExe := ::oData:cGlobalEdit
      ENDIF
      IF ! EMPTY(cExe)
         // uso dfExpCastEval per risoluzione se oWin:W_KEY = {||TIPART}
         cExe := dfMsgTran(cExe, "mode='"+DE_STATE_MOD+"'"                              , ;
                                          "index=" + dfAny2str(oWin:W_ORDER)      , ;
                                          "key="   + dfExpCastEval(oWin:W_KEY   , "") , ;
                                          "filter="+ dfExpCast(oWin:W_FILTER, "") , ;
                                          "break=" + dfExpCast(oWin:W_BREAK , "")   )
         bEval := _DFCOMPILE(cExe, @oErr)
         IF ! EMPTY(oErr)
            dfAlert(dfStdMsg1(MSG1_DDKEYWIN0200)+cExe)
         ENDIF
      ENDIF
      DEFAULT bEval TO {|x| ddDe(x)}
      lOk := _DFEVAL(bEval, @oErr, DE_STATE_MOD, oWin )
      IF ! EMPTY(oErr)
         dfAlert(dfStdMsg1(MSG1_DDKEYWIN0200)+cExe)
         lOk := .F.
      ENDIF
      IF lOk
         tbRtr( oWin )
      ENDIF
   ENDIF
   dfPopAct()
RETURN lOk

*******************************************************************************
METHOD RecSearch:Anr( oWin ) // Append
*******************************************************************************
   LOCAL nRec:=RECNO(), cAlias := ::cAlias
   LOCAL cExe:= "<unk>"
   LOCAL bEval
   LOCAL bErr
   LOCAL oErr
   LOCAL lOk
   
   IF ! ::checkValidAction(::oData:cEnableAnr)
      RETURN .F.
   ENDIF

   dfPushAct()
   cExe := ::oData:cEdit
   // simone 10/12/09 
   // aggiunta possibilità di cambiare/disattivare edit di default
   IF EMPTY(cExe)
      cExe := ::oData:cGlobalEdit
   ENDIF
   IF ! EMPTY(cExe)
      // uso dfExpCastEval per risoluzione se oWin:W_KEY = {||TIPART}
      cExe := dfMsgTran(cExe, "mode='"+DE_STATE_ADD+"'"                              , ;
                                       "index=" + dfAny2str(oWin:W_ORDER)      , ;
                                       "key="   + dfExpCastEval(oWin:W_KEY   , "") , ;
                                       "filter="+ dfExpCast(oWin:W_FILTER, "") , ;
                                       "break=" + dfExpCast(oWin:W_BREAK , "")   )
      bEval := _DFCOMPILE(cExe, @oErr)
      IF ! EMPTY(oErr)
         dfAlert(dfStdMsg1(MSG1_DDKEYWIN0200)+cExe)
      ENDIF
   ENDIF

   DEFAULT bEval TO {|x| ddDe(x)}
   lOk := _DFEVAL(bEval, @oErr, DE_STATE_ADD, oWin )
   IF ! EMPTY(oErr)
      dfAlert(dfStdMsg1(MSG1_DDKEYWIN0200)+cExe)
      lOk := .F.
   ENDIF
   IF lOk
      tbAtr( oWin )
   ELSE
      (cAlias)->(DBGOTO(nRec))
   ENDIF
   dfPopAct()
RETURN lOk


* -----------------------------------------
// Gestisce i dati letti da file .ini o DBDD
// - elenco indici
// - elenco colonne
// - filtro standard (su pagina 1)
// - elenco campi generici per filtro (su pagina 2)

CLASS RecSearchData
EXPORTED:
   VAR aIdx    // elenco indici
   VAR aLsbCol // elenco colonne listbox
   VAR aGetFie // elenco campi GET
   VAR cStdFlt // espressione filtro del campo "Cerca" 
               // es. "%search% $ ragsoc1" dove %search%=testo in input
   
   VAR cEdit   // form di edit
   VAR cTitle  // titolo finestra

   VAR nMaxWords // numero di parole da controllare
                 // per ricerca generica full text

   VAR cGlobalFilterEvaluateIF // espressione se dice se valutare il filtro globale.
                            // ad esempio "%alias->(fieldpos('anadatdis')) > 0 " (se esiste il campo ANADATDIS)
   VAR cGlobalFilter // Filtro Globale da applicare su 
                     // tutte le tabelle chiamate con la ddkeyandwin
                     // se valido ::cGlobalFilterEvaluateIF
                     // ad esempio "%alias->ANADATDIS > DATE()"

   VAR aTables // elenco tabelle collegate

   // simone 10/12/09
   // XL1509 - aggiunta espressione per eventualmente scegliere quale operazione fare
   VAR cEnableAnr    // espressione globale per abilitare ADD, default=.T.
   VAR cEnableMcr    // espressione globale per abilitare MOD, default=.T.
   VAR cEnableEcr    // espressione globale per abilitare DEL, default=.T.
   VAR cGlobalEdit

   METHOD Init
ENDCLASS

METHOD RecSearchData:init()
   ::aIdx    := {}
   ::aGetFie := {}
   ::aLsbCol := {}
   ::aTables := {}
   ::cStdFlt := ""
   ::cEdit   := ""
   ::cTitle  := NIL
   ::nMaxWords := 5  
   ::cGlobalFilter  := ""
   ::cGlobalFilterEvaluateIF  := ""

   ::cEnableAnr:=""
   ::cEnableMcr:=""
   ::cEnableEcr:=""

   ::cGlobalEdit:=""
RETURN self

* ----------------------------------
// riempie una struttura RecSearchData dal DBDD

CLASS RecSearchDataDBDD
PROTECTED:
   CLASS METHOD LoadIdx
   CLASS METHOD LoadLsbFields
   CLASS METHOD LoadStdFilter
   CLASS METHOD LoadGetFields
   
EXPORTED:
   CLASS METHOD Load 
ENDCLASS

CLASS METHOD RecSearchDataDBDD:Load(oRecSearch, cAlias, cForm)
   // carica elenco indici
   oRecSearch:aIdx    := ::LoadIdx(cAlias,cForm)
   
   // carica elenco colonne
   oRecSearch:aLsbCol := ::LoadLsbFields(cAlias,cForm)

   // carica espressione filtro standard su pagina 1
   oRecSearch:cStdFlt := ::LoadStdFilter(cAlias,cForm)

   // carica elenco campi su pagina 2
   oRecSearch:aGetFie := ::LoadGetFields(cAlias,cForm)
   
   //~ ::cEdit   := ::LoadEdit(cAlis,cForm)
RETURN self

CLASS METHOD RecSearchDataDBDD:LoadIdx(cAlias,cForm)
   LOCAL aKey   := {}

   cAlias := UPPER(PADR(cAlias, 8))

   dbdd->(ORDSETFOCUS_XPP(1))                       // posiziono dbdd
   dbdd->(DBSEEK( "NDX"+cAlias))
   WHILE "NDX"+cAlias == UPPER(dbDD->rectyp+dbDD->file_name) .AND. ;
         !dbdd->(EOF())
      IF UPPER(dbDD->Field_type)#"S" // if not Search Key
         dbdd->(DBSKIP())
         LOOP
      ENDIF

//      IF lLockIndex
//         IF DBDD->NdxIncN!=nOrd
//            nRemove++
//            dbdd->(DBSKIP())
//            LOOP
//         ENDIF
//      ENDIF

                    // Riformatto per WIN400
      AADD( aKey, { VAL(STR(DBDD->NdxIncN))  ,; // Numero idx
                    ALLTRIM(DBDD->FIELD_DES) }) // description

      dbdd->(DBSKIP())
   ENDDO
RETURN aKey

CLASS METHOD RecSearchDataDBDD:LoadLsbFields(cAli,cForm)
   LOCAL aCol     := {}
   LOCAL nInd     := 1000
   LOCAL cKey
   LOCAL nAdd
   LOCAL nTBOrd
   LOCAL cHead
   LOCAL bBlock
   LOCAL cAlias
   
   nTbOrd  := (cAli)->(INDEXORD())
   cAlias := UPPER(PADR(cAli, 8))

   dbdd->(ORDSETFOCUS_XPP(1))     // Controllo se devo creare la finestra
   dbdd->(dbSeek( "FIE"+cAlias ))

   cKey  := UPPER( ORDKEY( nTbOrd ) )
   WHILE !dbdd->(eof()) .AND. "FIE"+cAlias == UPPER(dBdd->RecTyp+dBdd->file_name)

      IF dbdd->field_win == "1"

         IF (nAdd := AT( UPPER( ALLTRIM(dBdd->field_name) ), cKey))==0
            nAdd := nInd++
         ENDIF

         cHead  := ALLTRIM(dBdd->field_des)
         bBlock := FIELDWBLOCK(alltrim(dBdd->field_name), cAli)
         AADD(aCol,{ nAdd, { cHead, bBlock,DBDD->FIELD_LEN, UPPER( ALLTRIM(dBdd->field_name) )}})
      ENDIF
      dbdd->(DBSKIP())
   ENDDO

   // mette prima i campi della chiave
   ASORT(aCol,,,{|x,y|x[1]<y[1]})
RETURN aCol

CLASS METHOD RecSearchDataDBDD:LoadGetFields(cAli,cForm)
   LOCAL aCol := {}
   LOCAL cAlias
   LOCAL oFie
   
   cAlias := UPPER(PADR(cAli, 8))

   dbdd->(ORDSETFOCUS_XPP(1))     // Controllo se devo creare la finestra
   dbdd->(dbSeek( "FIE"+cAlias ))

   WHILE !dbdd->(eof()) .AND. "FIE"+cAlias == UPPER(dBdd->RecTyp+dBdd->file_name)

      IF dbdd->field_frm == "1"
         oFie := RecSearchFie():new()
         oFie:cName    := ALLTRIM(dBdd->field_name)
         oFie:cType    := DBDD->FIELD_TYPE
         oFie:nLen     := DBDD->FIELD_LEN
         oFie:nDec     := DBDD->FIELD_DEC
         oFie:cPrompt  := ALLTRIM(DBDD->FIELD_DES)
         oFie:cPic     := TRIM(dbdd->FIELD_PIC) 
         oFie:cMessage := TRIM(dbdd->FIELD_MSG)
         oFie:cWin     := dbdd->field_win
         oFie:cForm    := dbdd->field_frm

         AADD(aCol, oFie)
      ENDIF
      dbdd->(DBSKIP())
   ENDDO
RETURN aCol
   
CLASS METHOD RecSearchDataDBDD:LoadStdFilter(cAli,cForm)
   LOCAL cFlt := ""
   LOCAL cMask
   LOCAL aCol := {}
   LOCAL n
   LOCAL cAlias
   aCol := ::LoadGetFields(cAli,cForm)
   
   IF EMPTY(aCol)
      RETURN ""
   ENDIF
   cFlt := ".OR. EMPTY(%search%)"   

   FOR n := 1 TO LEN(aCol)
      IF aCol[n]:cType $ "CM"
         cMask := ".OR. UPPER(ALLTRIM(%search%)) $ UPPER(ALLTRIM(%alias%->%field%))"
      ELSEIF aCol[n]:cType $ "N"
         cMask := ".OR. UPPER(ALLTRIM(%search%)) $ ALLTRIM(STR(%alias%->%field%,%len%,%dec%))"
      ELSEIF aCol[n]:cType $ "D"
         cMask := ".OR. UPPER(ALLTRIM(%search%)) $ DTOC(%alias%->%field%)"
      ELSE
         cMask := ""
      ENDIF
      IF ! EMPTY(cMask)
         cFlt += dfMsgTran(cMask,"field="+aCol[n]:cName,;
                           "len="+ALLTRIM(STR(aCol[n]:nLen)),;
                           "dec="+ALLTRIM(STR(aCol[n]:nDec)))
      ENDIF
   NEXT
   //cFlt := dfMsgTran(cFlt,"alias="+cAli) viene fatto dopo
   //cFlt := dfMsgTran(cFlt,"search="+TAG_SEARCH,"alias="+cAli)
   cFlt := SUBSTR(cFlt,6) // salto ".OR. " iniziale
RETURN cFlt

* ------------------------------

// riempie una struttura RecSearchData da file XML 
// con questa struttura
/*

<?xml version="1.0"?>
<search version="1.0" 
        fulltextsearchmaxwords="5"                                                      OPZIONALE
        globalfilterEvaluateIF="%alias%->(FIELDPOS('ANADATDIS')) > 0"                   OPZIONALE
        globalfilter="EMPTY(%alias%->ANADATDIS) .OR. %alias%->ANADATDIS > S2SysDat()"   OPZIONALE
        enableAnr=".T."                                                                 OPZIONALE
        enableMcr=".T."                                                                 OPZIONALE
        enableEcr=".F." >                                                               OPZIONALE

   <settings
      form  = "GesAna1-GesAna2"    OPZIONALE lista forms, il carattere da usare per separare Š solo il "-"
      check = "empty(%key%) .or. (valtype(%key%)$'CM' .and. %key%=='C') .or. (valtype(%key%)$'B' .and. eval(%key%)=='C')" OPZIONALE
      table = "Anagraf"
      relatedTables="progmag-caumaga-docmovd"  OPZIONALE lista tabella ad aprire
      filter= "empty(%search%) .or. (%search% $ %alias%->codana .OR. %search% $ %alias%->ragsoc1)"
      edit  = "GesAna1Exe(%mode%)"                                                      OPZIONALE
      enableAnr=".T."                                                                   OPZIONALE
      enableMcr=".T."                                                                   OPZIONALE
      enableEcr=".F." >                                                                 OPZIONALE
      <indexes>
         <index number="1" description="Ordinamento per cliente"/>
         <index number="2" description="Ordinamento per Ragione Sociale"/>
      </indexes>
      <columns>
         <column fname="codana"  [header="Cod. Cliente"] [len="6"]/>
         <column fname="ragsoc1" [header="Rag. Sociale"] [len="60"]/>
         <column expr="S2desart(articoli->codart)" header="Lookup" len="60"/>
      </columns>
      <getfields>
         <getfield fname="codcat" [prompt="codice cat."] [message="indicare codice"] [len="10"] [dec="2"] [picture="99999"]/>
         <getfield name="codana"/>
         <getfield name="desana"/>
      </getfields>
   </settings>

   <settings
      form  = "ArtFrm"
      table = "articol"
      filter= "empty(%search%) .OR. (upper(alltrim(%search%)) $ upper(alltrim(%alias%->codart)) .OR. upper(alltrim(%search%)) $ upper(alltrim(%alias%->desart)))"
      edit  = "GesAna1Exe(%mode%)">
      <indexes>
         <index number="1" description="Ordinamento per cliente"/>
         <index number="2" description="Ordinamento per Ragione Sociale"/>
      </indexes>
      <columns>
         <column fname="codart" header="Codice" len="6"/>
         <column fname="desart" header="Articolo" len="60"/>
         <column expr="S2desart(articoli->codart)" header="Lookup" len="60"/>
      </columns>
      <getfields>
         <getfield fname="codcat" [prompt="codice cat."] [message="indicare codice"] [len="10"] [dec="2"] [picture="99999"]/>
         <getfield fname="desart"/>
      </getfields>
   </settings>
</search>

*/

CLASS RecSearchDataXML
   EXPORTED:
      CLASS VAR aXML
      CLASS METHOD load
ENDCLASS
      
CLASS METHOD RecSearchDataXML:load(oRecSearch, cAlias, cForm, cFile, aKFB)
   LOCAL oXML
   LOCAL bErr
   LOCAL nRet
   LOCAL xErr
   LOCAL nXml

   bErr := ERRORBLOCK({|e| break(e)})
   BEGIN SEQUENCE
      cFile := UPPER(ALLTRIM(cFile))

      IF ::aXML == NIL
         nXml := 0
         ::aXML := {}
      ELSE
         nXml := ASCAN(::aXml, {|x|x[1]==cFile })
      ENDIF


      IF nXml == 0
         oXML := dfXMLLoad(cFile, XmlNode2(), NIL, .T., 0)
         AADD(::aXml, {cFile, oXML})
      ELSE
         oXml := ::aXML[nXml][2]
      ENDIF

      IF EMPTY(oXml)
         BREAK -1
      ENDIF

      IF lower(oXml:getName()) == "?xml" .AND. len(oXml:children()) == 1
         oXml := oXml:children()[1]
      ENDIF

      IF !lower(oXml:getName()) == "search"
         BREAK  -2
      ENDIF

      IF !alltrim(oXml:version) == "1.0"
         BREAK -3
      ENDIF

      // load da XML versione 1.0
      nRet := RecSearchDataXML1_0():load(oRecSearch, oXml, cAlias, cForm, aKFB)

   RECOVER USING xErr
      IF VALTYPE(xErr)=="N"
         nRet := xErr
      ELSE
         nRet := -1000 // errore runtime
      ENDIF

   END SEQUENCE
   ERRORBLOCK(bErr)
RETURN nRet

* ----------------------------------------
// load da XML versione 1.0

CLASS RecSearchDataXML1_0
PROTECTED:
   CLASS METHOD LoadSettings
   CLASS METHOD checkValid
   
EXPORTED:
   CLASS METHOD Load
ENDCLASS

CLASS METHOD RecSearchDataXML1_0:load(oRecSearch, oXml, cAlias, cForm, aKFB)
   LOCAL aSettings
   LOCAL oSettings
   LOCAL lLoad := .F.
   LOCAL nRet
   LOCAL n, b
   
   //~ oRecSearch:aIdx    := {}
   //~ oRecSearch:aGetFie := {}
   //~ oRecSearch:aLsbCol := {}
   //~ oRecSearch:cStdFlt := ""
   //~ oRecSearch:cEdit   := ""

   DEFAULT cAlias TO ""
   DEFAULT cForm TO ""
   
   nRet := 0

   IF ! EMPTY(oXml:fulltextsearchmaxwords)
      oRecSearch:nMaxWords := VAL(oXml:fulltextsearchmaxwords)
   ENDIF
   IF ! EMPTY(oXml:globalfilter)
      oRecSearch:cGlobalFilter := Alltrim(oXml:globalfilter)
      IF ! EMPTY(oXml:globalFilterEvaluateIF)
         oRecSearch:cGlobalFilterEvaluateIF := Alltrim(oXml:globalFilterEvaluateIF)
      ENDIF
   ENDIF

   // simone 10/12/09
   // XL1509 - aggiunta espressione a livello globale
   // per eventualmente scegliere quale operazione fare
   IF ! EMPTY(oXml:enableAnr)
      IF EMPTY(oRecSearch:cEnableAnr)
         oRecSearch:cEnableAnr:=oXml:enableAnr
      ELSE
         oRecSearch:cEnableAnr:="("+oRecSearch:cEnableAnr+") .AND. ("+oXml:enableAnr+")"
      ENDIF
   ENDIF
   IF ! EMPTY(oXml:enableMcr)
      IF EMPTY(oRecSearch:cEnableMcr)
         oRecSearch:cEnableMcr:=oXml:enableMcr
      ELSE
         oRecSearch:cEnableMcr:="("+oRecSearch:cEnableMcr+") .AND. ("+oXml:enableMcr+")"
      ENDIF
   ENDIF
   IF ! EMPTY(oXml:enableEcr)
      IF EMPTY(oRecSearch:cEnableEcr)
         oRecSearch:cEnableEcr:=oXml:enableEcr
      ELSE
         oRecSearch:cEnableEcr:="("+oRecSearch:cEnableEcr+") .AND. ("+oXml:enableEcr+")"
      ENDIF
   ENDIF

   // simone 10/12/09 
   // aggiunta possibilità di cambiare/disattivare edit di default
   IF ! EMPTY(oXml:globalEdit)
      oRecSearch:cGlobalEdit := oXml:globalEdit
   ENDIF

   // lettura di tutti i tag <settings> fino a trovare quello 
   // per form corrente o per table=alias corrente
   aSettings := oXml:findAllChildrenFromName("settings")
   
   // cerco un setting per il form corrente su tabella passata
   IF ! EMPTY(cForm)
      cForm := UPPER(ALLTRIM(cForm))
      FOR n := 1 TO LEN(aSettings)
         oSettings := aSettings[n]
         IF ! EMPTY(oSettings:form) .AND. ;
            TAG_LIST_SEP+cForm+TAG_LIST_SEP $ TAG_LIST_SEP+UPPER(ALLTRIM(oSettings:form))+TAG_LIST_SEP .AND. ;
            ((EMPTY(cAlias) .AND. EMPTY(oSettings:table)) .OR. ;
             UPPER(ALLTRIM(cAlias)) == UPPER(ALLTRIM(oSettings:table))) .AND. ;
            ::checkValid(oSettings, cAlias, cForm, aKFB)
            nRet := ::loadSettings(oSettings, oRecSearch, cAlias, cForm)
            lLoad := .T.
            EXIT
         ENDIF
      NEXT
   ENDIF

   // se non ho trovato settings per il form corrente cerco 
   // per la tabella corrente
   IF ! lLoad .AND. ! EMPTY(cAlias)
      cAlias := UPPER(ALLTRIM(cAlias))
      FOR n := 1 TO LEN(aSettings)
         oSettings := aSettings[n]
         IF ! EMPTY(oSettings:table) .AND. ;
            UPPER(ALLTRIM(oSettings:table)) == cAlias .AND. ;
            ::checkValid(oSettings, cAlias, cForm, aKFB)
            nRet := ::loadSettings(oSettings, oRecSearch, cAlias, cForm)
            lLoad := .T.
            EXIT
         ENDIF
      NEXT
   ENDIF
   IF ! lLoad
      nRet := -10
   ENDIF
RETURN nRet

// controlla la clausola <settings check="xx">
CLASS METHOD RecSearchDataXML1_0:checkValid(oSettings, cAlias, cForm, aKFB)
   LOCAL b
   IF EMPTY(oSettings:check)
      RETURN .T.
   ENDIF
   b := oSettings:check
   // uso dfExpCastEval per risoluzione se aKFB[1] = {||TIPART}
   b := dfMsgTran(b, "alias=" + cAlias                , ;
                     "form="  + cForm                 , ;
                     "key="   + dfExpCastEval(aKFB[1], ""), ;
                     "filter="+ dfExpCast(aKFB[2], ""), ;
                     "break=" + dfExpCast(aKFB[3], "")  )
   b := _DFCOMPILE(b)
   b := _DFEVAL(b)
RETURN VALTYPE(b)=="L" .AND. b

CLASS METHOD RecSearchDataXML1_0:loadSettings(oSettings, oRecSearch, cAlias, cForm)
   LOCAL nRet := 0
   LOCAL bBlock
   LOCAL oNode
   LOCAL aList
   LOCAL aKey
   LOCAL oFie
   LOCAL n
   LOCAL nLen
   LOCAL nType
   LOCAL cPict
   
   IF ! EMPTY(oSettings:title)
      oRecSearch:cTitle := oSettings:title
   ENDIF
   IF ! EMPTY(oSettings:edit)
      oRecSearch:cEdit := oSettings:edit
   ENDIF
   IF ! EMPTY(oSettings:filter)
      oRecSearch:cStdFlt := oSettings:filter
   ENDIF
   IF ! EMPTY(oSettings:relatedTables)
      oRecSearch:aTables := dfStr2Arr(oSettings:relatedTables, TAG_LIST_SEP)
   ENDIF

   // simone 10/12/09
   // XL1509 - aggiunta espressione a livello di singolo settaggio
   // per eventualmente scegliere quale operazione fare
   IF ! EMPTY(oSettings:enableAnr)
      IF EMPTY(oRecSearch:cEnableAnr)
         oRecSearch:cEnableAnr:=oSettings:enableAnr
      ELSE
         oRecSearch:cEnableAnr:="("+oRecSearch:cEnableAnr+") .AND. ("+oSettings:enableAnr+")"
      ENDIF
   ENDIF
   IF ! EMPTY(oSettings:enableMcr)
      IF EMPTY(oRecSearch:cEnableMcr)
         oRecSearch:cEnableMcr:=oSettings:enableMcr
      ELSE
         oRecSearch:cEnableMcr:="("+oRecSearch:cEnableMcr+") .AND. ("+oSettings:enableMcr+")"
      ENDIF
   ENDIF
   IF ! EMPTY(oSettings:enableEcr)
      IF EMPTY(oRecSearch:cEnableEcr)
         oRecSearch:cEnableEcr:=oSettings:enableEcr
      ELSE
         oRecSearch:cEnableEcr:="("+oRecSearch:cEnableEcr+") .AND. ("+oSettings:enableEcr+")"
      ENDIF
   ENDIF

   // aggiunge indici di ricerca
   aKey  := oRecSearch:aIdx
   aList := oSettings:findAllChildrenFromName("indexes")
   IF ! EMPTY(aList)
      aList := aList[1]:findAllChildrenFromName("index")
      FOR n := 1 TO LEN(aList)
         oNode := aList[n]
         AADD( aKey, { VAL(oNode:number)  ,; // Numero idx
                       ALLTRIM(oNode:description) }) // description
      NEXT
   ENDIF
   
   // aggiunge colonne
   aKey  := oRecSearch:aLsbCol
   aList := oSettings:findAllChildrenFromName("columns")
   IF ! EMPTY(aList)
      aList := aList[1]:findAllChildrenFromName("column")
      FOR n := 1 TO LEN(aList)
         oNode := aList[n]
         IF ! EMPTY(oNode:expr) // .AND. ! EMPTY(oNode:header) .AND. ! EMPTY(oNode:len)
            IF EMPTY(oNode:header)
               oNode:header := ""
            ENDIF
            bBlock := _DFCOMPILE(oNode:expr)
            nLen   := oNode:len
            IF EMPTY(nLen)
               nLen := LEN(dfAny2Str(_DFEVAL(bBlock)))
            ELSE
               nLen := VAL(nLen)
            ENDIF

            //Maudp 18/04/2012 XL 3108-3113 Aggiunto campo TYPE per gestione colonne listbox di tipo ICON
            nType := oNode:type
            IF !EMPTY(nType)
               nType := VAL(nType)
            ENDIF

            cPict := oNode:picture

            AADD(aKey,{ n, { ALLTRIM(oNode:header), bBlock, nLen, NIL, nType,cPict}})

         ELSEIF ! EMPTY(oNode:fname)
            // INFO DA DBDD
            IF dbdd->(dfS(2, UPPER("fie"+;
                                   PAD(cAlias, LEN(dbdd->file_name))+;
                                   PAD(oNode:fname, LEN(dbdd->field_name)) )))
               IF DBDD->FIELD_TYPE $ "CM"
                  // per evitare "..." nelle colonne
                  bBlock := DFCOMPILE( "TRIM("+ALLTRIM(cAlias)+"->"+ALLTRIM(oNode:fname)+")"  )
               ELSE
                  bBlock := FIELDWBLOCK(alltrim(oNode:fname), cAlias)
               ENDIF
               IF EMPTY(oNode:header)
                  oNode:header := ALLTRIM(dbdd->field_des)
                  IF RIGHT(oNode:header, 1)==":" // tolgo ":" finale
                     oNode:header := LEFT(oNode:header, LEN(oNode:header)-1)
                  ENDIF
               ENDIF
               IF EMPTY(oNode:len)
                  nLen := dbdd->FIELD_LEN
               ELSE
                  nLen := VAL(oNode:len)
               ENDIF

               //Maudp 18/04/2012 XL 3108-3113 Aggiunto campo TYPE per gestione colonne listbox di tipo ICON
               nType := oNode:type
               IF !EMPTY(nType)
                  nType := VAL(nType)
               ENDIF

               cPict := oNode:picture

               //Controllo che bBlock non sia vuoto
               IF !EMPTY(bBlock)
                  AADD(aKey,{ n, { ALLTRIM(oNode:header), bBlock, nLen, UPPER(ALLTRIM(oNode:fname)), nType ,cPict}})
               ENDIF
     //         ELSE
     //            nRet := -20
            ELSE
               IF !EMPTY(oNode:type) .AND. oNode:type $ "CM"
                  // per evitare "..." nelle colonne
                  bBlock := DFCOMPILE( "TRIM("+ALLTRIM(cAlias)+"->"+ALLTRIM(oNode:fname)+")"  )
               ELSE
                  bBlock := FIELDWBLOCK(alltrim(oNode:fname), cAlias)
               ENDIF
               IF !EMPTY(oNode:header)
                  oNode:header := ALLTRIM(oNode:header)
                  IF RIGHT(oNode:header, 1)==":" // tolgo ":" finale
                     oNode:header := LEFT(oNode:header, LEN(oNode:header)-1)
                  ENDIF
               ELSE
                  oNode:header :=  oNode:fname
               ENDIF

               IF !EMPTY(oNode:len)
                  nLen := VAL(oNode:len)
               ELSE
                  nLen := 20
               ENDIF

               //Maudp 18/04/2012 XL 3108-3113 Aggiunto campo TYPE per gestione colonne listbox di tipo ICON
               nType := oNode:type
               IF !EMPTY(nType)
                  nType := VAL(nType)
               ENDIF

               cPict := oNode:picture
               //Controllo che bBlock non sia vuoto
               IF !EMPTY(bBlock)
                  AADD(aKey,{ n, { ALLTRIM(oNode:header), bBlock, nLen, UPPER(ALLTRIM(oNode:fname)), nType ,cPict}})
               ENDIF
            ENDIF
         ENDIF
      NEXT
   ENDIF
   
   // aggiunge campi get
   aKey  := oRecSearch:aGetFie
   aList := oSettings:findAllChildrenFromName("getfields")
   IF ! EMPTY(aList)
      aList := aList[1]:findAllChildrenFromName("getfield")
      FOR n := 1 TO LEN(aList)
         oNode := aList[n]
         
         // INFO DA DBDD
         IF dbdd->(dfS(2, UPPER("fie"+;
                                PAD(cAlias, LEN(dbdd->file_name))+;
                                PAD(oNode:fname, LEN(dbdd->field_name)) )))
                                
            oFie := RecSearchFie():new()
            oFie:cName    := oNode:fname
            oFie:cType    := DBDD->FIELD_TYPE

            IF EMPTY(oNode:len)
               oFie:nLen := dbdd->FIELD_LEN
            ELSE
               oFie:nLen := VAL(oNode:len)
            ENDIF
            IF EMPTY(oNode:dec)
               oFie:nDec := dbdd->FIELD_DEC
            ELSE
               oFie:nDec := VAL(oNode:dec)
            ENDIF
            IF EMPTY(oNode:prompt)
               oFie:cPrompt  := ALLTRIM(DBDD->FIELD_DES)
            ELSE
               oFie:cPrompt  := oNode:prompt
            ENDIF
            IF EMPTY(oNode:picture)
               oFie:cPic     := TRIM(dbdd->FIELD_PIC) 
            ELSE
               oFie:cPic     := oNode:picture
            ENDIF
            IF EMPTY(oNode:message)
               oFie:cMessage := TRIM(dbdd->FIELD_MSG)
            ELSE
               oFie:cMessage := oNode:message
            ENDIF
            
            oFie:cWin     :=  dbdd->field_win
            oFie:cForm    :=  dbdd->field_frm

            AADD(aKey, oFie)
//         ELSE
//            nRet := -30
         ENDIF
      NEXT
   ENDIF
RETURN nRet



* -----------------------------------------
// memorizza i dati dei campi da aggiungere su pagina 2 
// o delle colonne listbox
CLASS RecSearchFie
   PROTECTED:
   EXPORTED:
      //~ VAR nControl
      //~ VAR aControlSize

      VAR xBuffer
      
      VAR cName
      VAR cType
      VAR nLen
      VAR nDec
      VAR cPic
      VAR cPrompt
      VAR cMessage
      VAR cWin
      VAR cForm

ENDCLASS

* -----------------------------------------
// Supporto per ottimizzatore filtro su ADS


STATIC CLASS ddKeyOptFilter FROM tbBrowseOptimizeFilter
   PROTECTED
      VAR aOptVar          // elenco var. static/local e codeblock di accesso

   EXPORTED
      METHOD OptimizeFilter()

      INLINE METHOD Init()
         ::tbBrowseOptimizeFilter:Init()
         ::aOptVar :=  {}
         ::cOptFlt := ""
         ::bOptFlt := NIL
      RETURN self

      INLINE METHOD AddVar(cVar,bVar)
         Aadd(::aOptVar, {Upper(cVar),bVar})
      RETURN self

      VAR cOptFlt          // filtro ottimizz. impostabile da utente
      VAR bOptFlt          // filtro non ottimizz. impostabile da utente
ENDCLASS

METHOD ddKeyOptFilter:OptimizeFilter(cNewFilter, bFilter, oBrw, oForm)
   LOCAL xFilter
   LOCAL aArr := {}
   LOCAL bVarAcc := {|cVar, xVal| tbGetVar(oForm, cVar, xVal)}
   LOCAL nInd, cFunc, bFunc
   LOCAL bBlk
   //~ LOCAL cShow

   IF EMPTY(cNewFilter)
      RETURN NIL
   ENDIF

   // Disabilita globalmente ottimizzazione browse
   // simone 17/09/04 gerr 4257
   //~ IF ! ddKeyOptFltEnabled(.T.)
      //~ RETURN NIL
   //~ ENDIF

   //~ cShow := dfSet("XbaseBrowseOptimizeShow")

   //~ DEFAULT cShow TO ""

   IF ! EMPTY(::cOptFlt)
      cNewFilter := ::cOptFlt
   ENDIF

   xFilter := dfOptFltNew(oBrw:W_ALIAS, cNewFilter, bFilter, bVarAcc)

   AEVAL(::aOptVar, {|x| AADD(aArr, {UPPER(x[1]), IIF(LEN(x) < 3 .OR. x[3]==NIL, x[2], x[3])} ) })

   xFilter[OPTFLT_VAR_ARR] := aArr

   bBlk := IIF(dfAxsIsLoaded(xFilter[OPTFLT_ALIAS]),  ;
               {|| ddKeyExpressionOptimizerADS():new() }, ;
               {|| ddKeyExpressionOptimizerSTD():new() })
   
   //dfOptFltOptimize(xFilter, bBlk, 240 )
   dfOptFltOptimize(xFilter, bBlk)
   IF dfOptFltGetErrNum(xFilter) == 0

      //~ IF ! EMPTY(::bOptFlt) .AND. ;
         //~ ! xFilter[OPTFLT_STRNOTOPTEXP ] == ".T." .AND. ;
         //~ dfSet("XbaseBrowseOptimizeShowErrors")=="YES"

         //~ dfAlert("Filtro non completamente ottimizzabile//"+cNewFilter)
      //~ ENDIF
      IF ::bOptFlt != NIL
         xFilter[OPTFLT_CBNOTOPTEXP]:= ::bOptFlt
      ENDIF
   ELSE
      //~ IF dfSet("XbaseBrowseOptimizeShowErrors")=="YES"
         //~ dfAlert(  dfOptFltGetErrMsg(xFilter)  )
      //~ ENDIF
   ENDIF

   //~ IF "DEBUG" $ cShow
      //~ _MemoShow(xFilter[2]+CRLF+;
               //~ str(len(xFilter[2]))+CRLF+;
               //~ "------------------"+CRLF+;
               //~ dfOptFltGetString(xFilter)+CRLF+;
               //~ str(len(dfOptFltGetString(xFilter)))+CRLF+;
               //~ var2char(xFilter[OPTFLT_CBNOTOPTEXP]))
   //~ ENDIF

RETURN xFilter

CLASS ddKeyOptIndex FROM tbBrowseOptimizeIndex
   PROTECTED
      VAR aOptVar          // elenco var. static/local e codeblock di accesso

   EXPORTED
      METHOD OptimizeFilter()

      INLINE METHOD Init()
         ::tbBrowseOptimizeIndex:Init()
         ::aOptVar :=  {}
         ::cOptFlt := ""
         ::bOptFlt := NIL
      RETURN self

      INLINE METHOD AddVar(cVar,bVar)
         Aadd(::aOptVar, {Upper(cVar),bVar})
      RETURN self

      INLINE METHOD Create(oBrw, oBrowser, oForm)
         LOCAL aSave
         //Mantis 1630
         IF dfSet( AI_DISABLEKEYOPT )
            // disattivazione ottimizzazione key/break
            aSave := {oBrw:bKey, oBrw:bBreak}
            oBrw:bKey   := NIL
            oBrw:bBreak := NIL
            ::tbBrowseOptimizeIndex:Create(oBrw, oBrowser, oForm)
            oBrw:bKey   := aSave[1]
            oBrw:bBreak := aSave[2]
         ELSE
            ::tbBrowseOptimizeIndex:Create(oBrw, oBrowser, oForm)
         ENDIF
      RETURN self

      VAR cOptFlt          // filtro ottimizz. impostabile da utente
      VAR bOptFlt          // filtro non ottimizz. impostabile da utente
ENDCLASS

METHOD ddKeyOptIndex:OptimizeFilter(cNewFilter, bFilter, oBrw, oForm)
   LOCAL xFilter
   LOCAL aArr := {}
   LOCAL bVarAcc := {|cVar, xVal| tbGetVar(oForm, cVar, xVal)}
   LOCAL nInd, cFunc, bFunc
   LOCAL bBlk
   //~ LOCAL cShow

   IF EMPTY(cNewFilter)
      RETURN NIL
   ENDIF

   // Disabilita globalmente ottimizzazione browse
   // simone 17/09/04 gerr 4257
   //~ IF ! ddKeyOptFltEnabled(.T.)
      //~ RETURN NIL
   //~ ENDIF

   //~ cShow := dfSet("XbaseBrowseOptimizeShow")

   //~ DEFAULT cShow TO ""

   IF ! EMPTY(::cOptFlt)
      cNewFilter := ::cOptFlt
   ENDIF

   xFilter := dfOptFltNew(oBrw:W_ALIAS, cNewFilter, bFilter, bVarAcc)

   AEVAL(::aOptVar, {|x| AADD(aArr, {UPPER(x[1]), IIF(LEN(x) < 3 .OR. x[3]==NIL, x[2], x[3])} ) })

   xFilter[OPTFLT_VAR_ARR] := aArr

   bBlk := IIF(dfAxsIsLoaded(xFilter[OPTFLT_ALIAS]),  ;
               {|| ddKeyExpressionOptimizerADS():new() }, ;
               {|| ddKeyExpressionOptimizerSTD():new() })
   
   dfOptFltOptimize(xFilter, bBlk, 240 )
   IF dfOptFltGetErrNum(xFilter) == 0

      //~ IF ! EMPTY(::bOptFlt) .AND. ;
         //~ ! xFilter[OPTFLT_STRNOTOPTEXP ] == ".T." .AND. ;
         //~ dfSet("XbaseBrowseOptimizeShowErrors")=="YES"

         //~ dfAlert("Filtro non completamente ottimizzabile//"+cNewFilter)
      //~ ENDIF
      IF ::bOptFlt != NIL
         xFilter[OPTFLT_CBNOTOPTEXP]:= ::bOptFlt
      ENDIF
   ELSE
      //~ IF dfSet("XbaseBrowseOptimizeShowErrors")=="YES"
         //~ dfAlert(  dfOptFltGetErrMsg(xFilter)  )
      //~ ENDIF
   ENDIF

   //~ IF "DEBUG" $ cShow
      //~ _MemoShow(xFilter[2]+CRLF+;
               //~ str(len(xFilter[2]))+CRLF+;
               //~ "------------------"+CRLF+;
               //~ dfOptFltGetString(xFilter)+CRLF+;
               //~ str(len(dfOptFltGetString(xFilter)))+CRLF+;
               //~ var2char(xFilter[OPTFLT_CBNOTOPTEXP]))
   //~ ENDIF

RETURN xFilter

*--------------

STATIC CLASS ddKeyExpressionOptimizerSTD FROM dfExpressionOptimizer
   EXPORTED
      METHOD Init
      METHOD getSearch
ENDCLASS

METHOD ddKeyExpressionOptimizerSTD:Init(lShort, lAllFunc, lDelBA, aUDF, nMax)
    // Simone 21/09/09 XL 1352
    // Modifica per assegnazione filtro globale alla ddkeyandwin
    // altrimenti il filtro non veniva ottimizzato
    // DEFAULT aUDF     TO {}
    DEFAULT aUDF     TO dfOptFltUDFGet()
    dfOptFltUDF("ddKeyGetSearch", {|aParam|::getSearch(aParam)}, aUDF )
    ::dfExpressionOptimizer:init(lShort, lAllFunc, lDelBA, aUDF, nMax)
RETURN self

METHOD ddKeyExpressionOptimizerSTD:getSearch(aParam)
RETURN _getSearch(aParam)

*--------------

STATIC CLASS ddKeyExpressionOptimizerADS FROM dfExpressionOptimizerADS
   EXPORTED
      METHOD Init
      METHOD getSearch
ENDCLASS

METHOD ddKeyExpressionOptimizerADS:Init(lShort, lAllFunc, lDelBA, aUDF, nMax)
    // Simone 21/09/09 XL 1352
    // Modifica per assegnazione filtro globale alla ddkeyandwin
    // altrimenti il filtro non veniva ottimizzato
    // DEFAULT aUDF     TO {}
    DEFAULT aUDF     TO dfOptFltUDFGet()
    dfOptFltUDF("ddKeyGetSearch", {|aParam|::getSearch(aParam)}, aUDF )
    ::dfExpressionOptimizerADS:init(lShort, lAllFunc, lDelBA, aUDF, nMax)
RETURN self

METHOD ddKeyExpressionOptimizerADS:getSearch(aParam)
RETURN _getSearch(aParam)

*--------------

STATIC FUNCTION _getSearch(aParam)
   LOCAL xRet := ""
   LOCAL cChk, cChk2, xR1

   IF LEN(aParam) >= 1
      cChk := aParam[1]
      IF LEN(aParam) >= 2
         cChk2:= aParam[2]
      ENDIF
   ENDIF

   IF EMPTY(cChk)
      RETURN ""
   ENDIF

   IF EMPTY(cChk2) .OR. ;
      (! VALTYPE(cChk2) $ "CM") .OR. ;
      UPPER(ALLTRIM(cChk2))=="NIL"
      cChk2 := NIL
   ELSE
      cChk2 := VAL(cChk2)
   ENDIF
   xRet := ddKeyGetSearch( VAL(cChk), cChk2 )
RETURN dfExpCast(xRet)

STATIC FUNCTION _dfcompile(c, oErr)
   LOCAL bEval
   LOCAL bErr
   LOCAL e
   bErr := ERRORBLOCK({|e| break(e)})
   BEGIN SEQUENCE
      bEval := DFCOMPILE(c)
      //bEval := __DFCOMPILE(c)
   RECOVER USING e
      oErr := e
   END SEQUENCE
   ERRORBLOCK(bErr)
RETURN bEval


//Modifica alla funzione dfcompile per avere codceblock con parametri.
//STATIC FUNCTION __DFCOMPILE(c)
//   LOCAL bEval
//   IF EMPTY(c)
//      RETURN {||.T.} 
//   ENDIF
//   //allora Š gi… formatato come codeblock
//   c := Alltrim(c)
//   IF LEFT(c,1 ) == "|" .AND. AT("|",c, 2 ) >0
//      bEval := &("{"+c+"}")
//   ELSE
//      bEval := dfCompile(c)
//   ENDIF
//RETURN bEval

STATIC FUNCTION _dfeval(b, oErr, p1, p2, p3, p4, p5, p6, p7, p8, p9)
   LOCAL bEval
   LOCAL bErr
   LOCAL e
   LOCAL xRet
   bErr := ERRORBLOCK({|e| break(e)})
   BEGIN SEQUENCE
      xRet := EVAL(b, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9)
   RECOVER USING e
      oErr := e
   END SEQUENCE
   ERRORBLOCK(bErr)
RETURN xRet


STATIC FUNCTION _VDBWaitAllEvents(oDlg,nWait)
   LOCAL nEvent, oXbp, mp1, mp2
   LOCAL aSize

   
   DEFAULT nWait TO .1

   // processo tutti gli eventi
   nEvent := NIL
   DO WHILE nEvent != xbe_None
      nEvent := AppEvent(@mp1,@mp2,@oXbp,nWait)
      IF nEvent !=xbe_None .AND. oXbp != NIL
         oXbp:handleEvent(nEvent,mp1,mp2)
      ENDIF
   ENDDO
RETURN .T.
