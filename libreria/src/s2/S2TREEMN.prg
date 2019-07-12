#include "Appevent.ch"
#include "Xbp.ch"
#include "gra.ch"
#include "dfStd.ch"
#include "Common.ch"
#include "dfXbase.ch"
#include "dfXRes.ch"
#include "dfSet.ch"

#define TOOLBAR_HEIGHT       IIF(EMPTY(dfSet("XbaseMenuToolBar_Height")), 26, VAL(dfSet("XbaseMenuToolBar_Height")) )
//#define TOOLBAR_HEIGHT      26

STATIC oTreeMenu := NIL

FUNCTION S2TreeMenuGet()
   TreeMenuInit()
RETURN oTreeMenu

PROCEDURE S2TreeMenuSet(oMenu)
   TreeMenuInit()

   IF oTreeMenu != NIL
      oTreeMenu:setMenu(oMenu)
   ENDIF
RETURN

STATIC PROCEDURE TreeMenuInit()
   IF oTreeMenu==NIL .AND. dfSet("XbaseTreeMenu") == "YES"
      oTreeMenu := S2TreeMenu():new():create()
   ENDIF
RETURN

CLASS S2TreeMenu FROM XbpDialog
   PROTECTED
      METHOD buildTree

   EXPORTED
      VAR oTree, ToolBarArea
      METHOD Init, Create, setMenu
ENDCLASS

METHOD S2TreeMenu:init(oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL nYSize := AppDesktop():currentSize()[2]

   DEFAULT oParent TO AppDesktop()

   // 30 = altezza barra menu

   DEFAULT aPos    TO { 10, 30 }
   DEFAULT aSize   TO {150, nYSize - 30 }

   ::XbpDialog:Init(oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::oTree := XbpTreeView():new(::drawingArea ,, {0,0})
   ::toolBarArea := toolBar():new()

   // ::XbpDialog:DrawingArea:resize := {|aOld, aNew, aDelta| x:= ::drawingArea:currentSize(), x[2]-= TOOLBAR_HEIGHT, ::oTree:setSize(x) }

   ::XbpDialog:DrawingArea:resize := {|aOld, aNew, aDelta| aDelta := {aNew[1]-aOld[1], aNew[2]-aOld[2]}, ;
                                                           aNew := ::oTree:currentSize(), ;
                                                           aNew[1]+=aDelta[1], aNew[2]+=aDelta[2],;
                                                           ::oTree:setSize(aNew), ;
                                                           ::toolbarArea:resize() }
                                                           // aNew := ::toolbararea:currentPos(), ;
                                                           // aNew[1]+=aDelta[1], aNew[2]+=aDelta[2],;
                                                           // ::toolBarArea:setPos(aNew) }

   // simone 14/6/05 dovrebbe usare ::execMenuIten ma non Š indispensabile dato che questo treemenu non Š usato 
   ::oTree:itemMarked := {|o| IIF( EMPTY(o:cargo), NIL, PostAppEvent(xbeP_User+EVENT_MENU_SELECTION, o:cargo[1], NIL, o:cargo[2]) )}
   ::title := "Menu applicazione"

   ::oTree:hasLines   := .T.
   ::oTree:hasButtons := .T.
RETURN self

METHOD S2TreeMenu:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL nToolbarHeight

   ::XbpDialog:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )

   aSize := ::drawingArea:currentSize()

   // Simone 22/3/06
   // mantis 0001016: poter impostare altezza toolbar a livello di progetto per usare icone più grandi
   // trova altezza toolbar da dfSet()
   IF EMPTY(dfSet(AI_XBASETOOLBAROPTIONS))
      nToolBarHeight:= TOOLBAR_HEIGHT
   ELSE
      nToolBarHeight:= ASCAN(dfSet(AI_XBASETOOLBAROPTIONS), {|x|x[1]==AI_TOOLBAR_HEIGHT})
      IF nToolBarHeight== 0
         nToolBarHeight := TOOLBAR_HEIGHT
      ELSE
         nToolBarHeight:= dfSet(AI_XBASETOOLBAROPTIONS)[ nToolBarHeight][2]
      ENDIF
   ENDIF

   aSize[2] -= nToolBarHeight
   ::oTree:Create(NIL, NIL, NIL, aSize)

   ::toolBarArea:nToolBarSize   := nToolbarHeight
   ::toolBarArea:create(::drawingArea)

   // Add some tools, separators and extra space to the created object
   ::toolBarArea:addTool({TOOLBAR_WRITE_H  , TOOLBAR_WRITE_H  }, { || dbAct2Kbd("wri") }, "Conferma i dati" )
   ::toolBarArea:addTool({TOOLBAR_ESC_H    , TOOLBAR_ESC_H    }, { || dbAct2Kbd("esc") }, "Annulla" )
   ::toolBarArea:addSeparator()
   ::toolBarArea:addTool({TOOLBAR_HELP_H   , TOOLBAR_HELP_H   }, { || dfHlp(M->ENVID, M->SUBID) }, "Help in linea" )
   ::toolBarArea:addTool({TOOLBAR_KEYHELP_H, TOOLBAR_KEYHELP_H}, ;
                         { || IIF(S2FormCurr()==NIL, NIL, ;
                                  dfUsrHelp(S2FormCurr():W_KEYBOARDMETHODS, ;
                                            S2FormCurr():cState ) )}, ;
                         "Elenco tasti attivi" )

RETURN self

METHOD S2TreeMenu:setMenu(oMenu)
   ::oTree:destroy()
   ::oTree:create()

   IF ! EMPTY(oMenu)
      ::buildTree(::oTree:rootItem, oMenu, 0)
   ENDIF
RETURN self

METHOD S2TreeMenu:buildTree(oTree, oMenu, nLev)
   LOCAL nInd := 0
   LOCAL nPos := 0
   LOCAL aItm
   LOCAL cAdd
   LOCAL oObj

   FOR nInd := 1 TO oMenu:numItems()
      aItm := oMenu:getItem(nInd)
      cAdd := ""

      IF VALTYPE(aItm[1]) == "O"
         cAdd := aItm[1]:title

      ELSEIF VALTYPE(aItm[1]) == "C"
         cAdd := aItm[1]

      // ELSE
         //cAdd := "Bitmap"

      ENDIF

      IF ! EMPTY(cAdd)

         cAdd := STRTRAN(cAdd, STD_HOTKEYCHAR)
         IF (nPos := AT(CHR(9), cAdd)) > 0
            cAdd := LEFT(cAdd, nPos-1)
         ENDIF

         oObj := oTree:addItem(ALLTRIM(cAdd))

         IF nLev > 0 // Non faccio l'ADD per il primo livello di menu
            oObj:cargo := {nInd, oMenu}
         ENDIF
         // oObj:setData({|o|  })

      ENDIF

      IF VALTYPE(aItm[1]) == "O"
         ::buildTree(oObj, aItm[1], nLev+1)
      ENDIF
   NEXT
RETURN NIL

