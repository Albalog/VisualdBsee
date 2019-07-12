/*****************************************************************************
*
*     PROYECTO: S2ScrollDialog
*     ARCHIVOS: Scroll.prg, Scroll.ch
*  Programador: J.A. Diego Kerejeta
*       Creado: 6-12-02
*
*
*  S2ScrollDialog Class ver 1.2
*
*  Variables:
*
*     :aSizeScrollArea - Establece el tama¤o del area "scrollable".
*                        ( array del tipo { nXsize, nYsize } )
*                      - Si no se define ninguno, se habilita por defecto
*                      - un area con el doble del tama¤o del drawingArea
*                      - estandar de la ventana.
*
*     :nSkipPixels - numero de pixels de desplazamiento por cada posicion de
*                    las barras de scroll.
*                  - Por defecto toma el valor 10
*  Metodos:
*
*     :New( oParent, [ oOwner ], aPos, aSize, [ aPP ], [ lVisible ] )
*                  - Inicializa la clase S2ScrollDialog
*                  - Esta clase deriva de XbpDialog, por lo que son
*                    accesibles todas las iVars y metodos estandares
*                  - La variable lVisible no tiene efecto. Como consecuencia
*                    siempre es necesario llamar al metodo :Show() para
*                    hacer visible un objeto de esta clase
*
*     :Create(oParent, [oOwner], aPos, aSize, [aPP], [lVisible])
*                  - Inicializa la clase S2ScrollDialog
*
*     :Show() - Hace visible los objetos de la clase. Siempre es necesario
*               llamar al metodo :Show().
*
*     :SetSizeScrollArea() - Cambia el tama¤o del area "scrollable".
*                            No afecta al tama¤o de la ventana.
*
*     :forceVisible( oXbp ) - En caso de que el objeto oXbp este situado
*                             en una parte no visible del area "scrollable",
*                             produce los desplazamientos necesarios del
*                             area para hacerlo visible.
*
*     :SkipVScroll( nSaltos ) - Desplaza verticalmente el area "scrollable"
*                             - Valores positivos de nSaltos producen
*                               desplazamiento hacia abajo del scroll
*                             - Valores negativos, hacia arriba.
*                             - Solo se produce desplazamiento si existe
*                               Scroll y es visible. El rango de desplazamiento
*                               posible se situa entre 0 y :range[ 2 ]
*
*     :GoToVScroll( nPos ) - Desplaza verticalmente el scroll a la posicion
*                            determinada.
*                          - Valores posibles:
*                                0....n
*                                SCROLL_TOP_POS
*                                SCROLL_BOTTOM_POS
*                          - Solo se produce desplazamiento si existe
*                            Scroll y es visible. El rango de desplazamiento
*                            posible se situa entre 0 y :range[ 2 ]
*
*     :GoPosRelVScroll( nPorc ) - Desplaza verticalmente el scroll a la posicion
*                                 relativa al porcentaje determinado.
*                               - Admite valores entre 0% y 100%.
*                               - Solo se produce desplazamiento si existe
*                                 Scroll y es visible.
*
*     :GetPosVScroll( lMax ) - Devuelve valores del Scroll vertical. Si no
*                              existe Scroll o no es visible, devuelve NIL.
*                              Si no pasamos ningun valor o este es FALSE
*                              devuelve la posicion actual del Scroll
*                              Si pasamos el valor TRUE, devuelve el valor
*                              maximo del Scroll (:range[ 2 ])
*
*     :SkipHScroll( nSaltos ) - Desplaza horizontalmente el area "scrollable"
*                             - Valores positivos de nSaltos producen
*                               desplazamiento hacia la derecha
*                             - Valores negativos, hacia la izquierda.
*                             - Solo se produce desplazamiento si existe
*                               Scroll y es visible. El rango de desplazamiento
*                               posible se situa entre 0 y :range[ 2 ]
*
*     :GoToHScroll( nPos ) - Desplaza horizontalmente el scroll a la posicion
*                            determinada.
*                          - Valores posibles:
*                                0....n
*                                SCROLL_TOP_POS
*                                SCROLL_BOTTOM_POS
*                          - Solo se produce desplazamiento si existe
*                            Scroll y es visible. El rango de desplazamiento
*                            posible se situa entre 0 y :range[ 2 ]
*
*     :GoPosRelHScroll( nPorc ) - Desplaza horizontalmente el scroll a la posicion
*                                 relativa al porcentaje determinado.
*                               - Admite valores entre 0% y 100%.
*                               - Solo se produce desplazamiento si existe
*                                 Scroll y es visible.
*
*     :GetPosHScroll( lMax ) - Devuelve valores del Scroll horizontal. Si no
*                              existe Scroll o no es visible, devuelve NIL.
*                              Si no pasamos ningun valor o este es FALSE
*                              devuelve la posicion actual del Scroll
*                              Si pasamos el valor TRUE, devuelve el valor
*                              maximo del Scroll (:range[ 2 ])
*
*  Defines en Scroll.ch:
*
*  #define SCROLL_TOP_POS     -1
*  #define SCROLL_BOTTOM_POS  9999
*  #define SCROLL_RANGE_MAX   .T.
*
*****************************************************************************/

#include "Appevent.ch"
#include "Common.ch"
#include "Font.ch"
#include "Xbp.ch"
#include 'gra.ch'

#define OFFSET_CENTER ROUND(::currentSize()[2]/4, 0) //40 // spazio verticale da visualizzare oltre al control in :forceStable()

#ifdef __DIALOG__

#define _THISXBP_NAME  S2ScrollDialog
#define _THISXBP_SUPER XbpDialog

************************************
************************************

CLASS _THISXBP_NAME  FROM _THISXBP_SUPER

************************************
************************************
PROTECTED:
   VAR oScrollArea

EXPORTED:
   VAR aSizeScrollArea
   VAR nSkipPixels
   VAR drawingArea
   VAR superDrawingArea IS drawingArea IN _THISXBP_SUPER


   INLINE METHOD init( oParent, oOwner, aPos, aSize, aPP, lVisible )
      ::_THISXBP_SUPER:init( oParent, oOwner, aPos, aSize, aPP, .F. )
      ::clipChildren := .T.
      ::superDrawingArea:resize := dfMergeBlocks({|mp1,mp2,obj| obj:childList()[1]:resize( mp1, mp2 )}, ::superDrawingArea:resize)
      ::nSkipPixels        := 10
      ::oScrollArea:= S2ScrollArea():new()
      ::drawingArea := ::oScrollArea
   RETURN self

   INLINE METHOD create( oParent, oOwner, aPos, aSize, aPP, lVisible )
      ::_THISXBP_SUPER:create( oParent, oOwner, aPos, aSize, aPP, .F. )
      aSize:= ::superDrawingArea:currentSize()

      IF ::aSizeScrollArea = NIL
         ::aSizeScrollArea:= { aSize[ 1 ] * 2, aSize[ 2 ] * 2 }
      ENDIF
      ::oScrollArea:aSizeScrollArea := ::aSizeScrollArea
      ::oScrollArea:nSkipPixels     := ::nSkipPixels

      ::oScrollArea:create( ::superDrawingArea,, { 0, 0 }, aSize )
   RETURN self

   INLINE METHOD destroy
      ::_THISXBP_SUPER:destroy()
      ::oScrollArea:= NIL
   RETURN self

   INLINE METHOD getScrollArea()
   RETURN ::oScrollArea


/*
   INLINE METHOD show
      LOCAL aChilds := ::drawingArea:childList()
      LOCAL nFin    := LEN( aChilds )
      LOCAL nCont, oXbp, aPos

      FOR nCont:= 2 TO nFin
         oXbp     := aChilds[ nCont ]
         aPos     := oXbp:currentPos()
         aPos[ 2 ]:= ::aSizeScrollArea[ 2 ] - aPos[ 2 ] - ;
                     oXbp:currentSize()[ 2 ]

         oXbp:setParent( ::oScrollArea:drawingArea )
         oXbp:setPos( aPos, .T. )
      NEXT
   RETURN ::_THISXBP_SUPER:show()
*/
   INLINE METHOD SetSizeScrollArea( aSize )
   RETURN ::oScrollArea:SetSizeScrollArea( aSize )

   INLINE METHOD forceVisible( oXbp )
   RETURN ::oScrollArea:forceVisible( oXbp )

   INLINE METHOD SkipVScroll( nSaltos )
   RETURN ::oScrollArea:SkipVScroll( nSaltos )

   INLINE METHOD GoToVScroll( nPos )
   RETURN ::oScrollArea:GoToVScroll( nPos )

   INLINE METHOD GoPosRelVScroll( nPorc )
   RETURN ::oScrollArea:GoPosRelVScroll( nPorc )

   INLINE METHOD GetPosVScroll( lMax )
   RETURN ::oScrollArea:GetPosVScroll( lMax )

   INLINE METHOD SkipHScroll( nSaltos )
   RETURN ::oScrollArea:SkipHScroll( nSaltos )

   INLINE METHOD GoToHScroll( nPos )
   RETURN ::oScrollArea:GoToHScroll( nPos )

   INLINE METHOD GoPosRelHScroll( nPorc )
   RETURN ::oScrollArea:GoPosRelHScroll( nPorc )

   INLINE METHOD GetPosHScroll( lMax )
   RETURN ::oScrollArea:GetPosHScroll( lMax )

ENDCLASS
#endif

*****************************************
*****************************************

CLASS S2ScrollArea FROM XbpStatic

*****************************************
*****************************************

PROTECTED:
   VAR oCorner
   VAR nYrelativa
   VAR nYsizeOriginal
   VAR nXrelativa
   VAR nXsizeOriginal
   VAR nDecrementox
   VAR nDecrementoy
   VAR lHShowPostHide
   VAR lHHide
   VAR lYPosSet
   VAR lXPosSet

   METHOD setPosAndSizeVisor
   METHOD setPosAndSizeScrollArea

EXPORTED:
   VAR oVisor
   VAR drawingArea

   VAR hScroll    READONLY
   VAR vScroll    READONLY

   VAR aSizeScrollArea
   VAR border
   VAR nSkipPixels

   METHOD init
   METHOD create
   METHOD destroy

   METHOD SetSizeScrollArea
   METHOD resize

   METHOD hScroll
   METHOD vScroll

   METHOD forceVisible

   METHOD GetPosVScroll
   METHOD SkipVScroll
   METHOD GoToVScroll
   METHOD GoPosRelVScroll

   METHOD GetPosHScroll
   METHOD SkipHScroll
   METHOD GoToHScroll
   METHOD GoPosRelHScroll

   /////////////////////////////////////////////////////////////
   //Inserito da Luca per CRM 
   INLINE METHOD DisableYPosset(); ::lYPosSet := .F.;RETURN SELF 
   INLINE METHOD  EnableYPosset(); ::lYPosSet := .T.;RETURN SELF 
   //Inserito da Luca per CRM 
   INLINE METHOD DisableXPosset(); ::lXPosSet := .F.;RETURN SELF 
   INLINE METHOD  EnableXPosset(); ::lXPosSet := .T.;RETURN SELF 
   /////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////
ENDCLASS

************************************************************************
METHOD S2ScrollArea:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
************************************************************************
::XbpStatic:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::clipChildren := .T.
   ::border       := XBPDLG_NO_BORDER
   ::nYrelativa   := 0
   ::nXrelativa   := 0
   ::nSkipPixels  := 10
   ::lYPosSet     := .T.
   ::lXPosSet     := .T.

::oVisor:= XbpDialog():new( self )
   ::clipChildren      := .T.
   ::oVisor:minButton  := .F.
   ::oVisor:maxButton  := .F.
   ::oVisor:sysMenu    := .F.
   ::oVisor:titleBar   := .F.
   ::oVisor:border     := ::border
::drawingArea    := ::oVisor:drawingArea

RETURN self

**************************************************************************
METHOD S2ScrollArea:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
**************************************************************************
::XbpStatic:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

::oVisor:create( , , { 0, 0 }, ::currentSize(),, .T. )

aSize := ::drawingArea:currentSize()

::nXsizeOriginal := ::aSizeScrollArea[ 1 ]
::nYsizeOriginal := ::aSizeScrollArea[ 2 ]
IF ::aSizeScrollArea[ 2 ] > aSize[ 2 ]
   ::drawingArea:setPos( { 0, aSize[ 2 ] - 16 - ::aSizeScrollArea[ 2 ] } )
ENDIF
IF ::aSizeScrollArea[ 1 ] > aSize[ 1 ]
   //Riabilitato dopo segnalazione mario Garritano: task: 1572 
   ::drawingArea:setPos( { 0, aSize[ 1 ] - 16 - ::aSizeScrollArea[ 1 ] } )
ENDIF
::resize( aSize, aSize )

RETURN self

****************************
METHOD S2ScrollArea:destroy
****************************
::xbpStatic:destroy()

//::oCorner:= ::oVisor:= ::hScroll:= ;
//::vScroll:= ::drawingArea:= NIL

::oCorner:= ::hScroll:= ::vScroll :=  NIL

RETURN self

*************************************************
METHOD S2ScrollArea:resize( aOldSize, aNewSize )
*************************************************
LOCAL nY, nX,aChilds, nFin, nCont, aPos, lExito1, lExito2

::nDecrementox := MAX( aOldSize[ 1 ] - aNewSize[ 1 ], 0 )
::nDecrementoy := MAX( aOldSize[ 2 ] - aNewSize[ 2 ], 0 )

::drawingArea:LockUpdate( .T. )

lExito1:= ::setPosAndSizeVisor( aNewSize )
lExito2:= ::setPosAndSizeScrollArea()

IF aOldSize[ 2 ] <> aNewSize[ 2 ]
   nY      := ::drawingArea:currentSize()[ 2 ] - ::nYSizeOriginal
   aChilds := ::drawingArea:childList()
   nFin    := LEN( aChilds )

   IF ::lYPosSet
      FOR nCont:= 1 TO nFin
         aPos      := aChilds[ nCont ]:currentPos()
         aPos[ 2 ] += ( nY - ::nYrelativa )
         aChilds[ nCont ]:setPos( aPos, .F. )
      NEXT
      ::nYrelativa:= nY
   ENDIF

ENDIF


IF aOldSize[ 1 ] <> aNewSize[ 1 ]
   nX      := ::drawingArea:currentSize()[ 1 ] - ::nXSizeOriginal
   aChilds := ::drawingArea:childList()
   nFin    := LEN( aChilds )

   IF ::lXPosSet
      FOR nCont:= 1 TO nFin
         aPos      := aChilds[ nCont ]:currentPos()
         aPos[ 1 ] += ( nX - ::nXrelativa )
         aChilds[ nCont ]:setPos( aPos, .F. )
      NEXT
      ::nXrelativa:= nX
   ENDIF

ENDIF


::drawingArea:LockUpdate( .F. )
::drawingArea:invalidateRect()

RETURN lExito1 .AND. lExito2

***********************************************
METHOD S2ScrollArea:SetSizeScrollArea( aSize )
***********************************************
IF Valtype( aSize ) <> "A"
   RETURN self
ENDIF

::aSizeScrollArea := aSize

IF ::hScroll <> NIL
   ::hScroll:cargo:= -1
   ::hScroll( { 0 } )
ENDIF
IF ::vScroll <> NIL
   ::vScroll:cargo:= -1
   ::vScroll( { 0 } )
ENDIF
RETURN ::resize( { 0, 0 }, ::currentSize() )

************************************************
METHOD S2ScrollArea:setPosAndSizeVisor( aSize )
************************************************
LOCAL lVScroll:= .F.
LOCAL lHScroll:= .F.

::setSize( aSize, .F. )

::lHShowPostHide:= ::lHHide:= .F.

IF ::aSizeScrollArea[ 1 ] > aSize[ 1 ]
   IF ::hScroll == NIL
      ::hScroll           := XbpScrollbar():new( self )
      ::hScroll:type      := XBPSCROLL_HORIZONTAL
      ::hScroll:cargo     := 0
      ::hScroll:create()
      ::hScroll:scroll    := {|mp1| ::hScroll( mp1 ) }
   ELSEIF ! ::hScroll:isVisible()
      ::hScroll:show()
      ::lHShowPostHide:= .T.
   ENDIF
   lHScroll   := .T.
   aSize[ 2 ] -= 16
   ::hScroll:setPosAndSize( { 0, 0 }, { aSize[ 1 ] - ;
                         IIF( ::aSizeScrollArea[ 2 ] > aSize[ 2 ], 16, 0 ), 16 } )
ELSEIF ::hScroll <> NIL .AND. ::hScroll:isVisible()
   ::hScroll:hide()
   ::lHHide:= .T.
ENDIF

IF ::aSizeScrollArea[ 2 ] > aSize[ 2 ]
   IF ::vScroll == NIL
      ::vScroll           := XbpScrollbar():new( self )
      ::vScroll:type      := XBPSCROLL_VERTICAL
      ::vScroll:cargo     := 0
      ::vScroll:create()
      ::vScroll:scroll := {|mp1| ::vScroll( mp1 ) }
   ELSEIF ! ::vScroll:isVisible()
      ::vScroll:show()
   ENDIF
   lVScroll   := .T.
   aSize[ 1 ] -= 16
   ::vScroll:setPosAndSize( { aSize[ 1 ], IIF( lHScroll, 16, 0 ) }, ;
                            { 16, aSize[ 2 ] } )
ELSEIF ::vScroll <> NIL .AND. ::vScroll:isVisible()
   ::vScroll:hide()
ENDIF

IF lHScroll .AND. lVScroll
   IF ::oCorner == NIL
      ::oCorner      := XbpStatic():new( self )
      ::oCorner:type := XBPSTATIC_TYPE_RECESSEDBOX
      ::oCorner:create()
   ELSEIF ! ::oCorner:isVisible()
      ::oCorner:show()
   ENDIF
   ::oCorner:setPosAndSize( { aSize[ 1 ],  0 }, { 16, 16 } )
ELSEIF ::oCorner <> NIL .AND. ::oCorner:isVisible()
   ::oCorner:hide()
ENDIF
RETURN ::oVisor:setPosAndSize( { 0, IIF( lHScroll, 16, 0 ) }, aSize )

********************************************
METHOD S2ScrollArea:setPosAndSizeScrollArea
********************************************
LOCAL aSize   := ::oVisor:calcClientRect( { 0, 0, ;
                 ::oVisor:currentSize()[ 1 ], ::oVisor:currentSize()[ 2 ] } )
LOCAL aSizeDA := { MAX( aSize[ 3 ], ::aSizeScrollArea[ 1 ] ), ;
                   MAX( aSize[ 4 ], ::aSizeScrollArea[ 2 ] ) }
LOCAL aPos, nValor, lExito

IF ::aSizeScrollArea[ 1 ] <= aSize[ 3 ] .AND. ::aSizeScrollArea[ 2 ] <= aSize[ 4 ]
   aPos:= { 0, 0 }
ELSEIF ::aSizeScrollArea[ 1 ] <= aSize[ 3 ]
   aPos:= { 0, ::drawingArea:currentPos()[ 2 ] }
   aPos[ 2 ] -= ::nDecrementoy
   IF ::lHHide;  aPos[ 2 ] += 16;   ENDIF
ELSEIF ::aSizeScrollArea[ 2 ] <= aSize[ 4 ]
   aPos:= { ::drawingArea:currentPos()[ 1 ], 0 }
ELSE
   aPos := ::drawingArea:currentPos()
   aPos[ 2 ] -= ::nDecrementoy
   IF ::lHShowPostHide
      aPos[ 2 ] -= 16
   ELSEIF ::lHHide
      aPos[ 2 ] += 16
   ENDIF
ENDIF

IF aPos[ 1 ] + aSizeDA[ 1 ] < aSize[ 3 ]
   aPos[ 1 ]:= aSize[ 3 ] - aSizeDA[ 1 ]
ENDIF
IF aPos[ 2 ] + aSizeDA[ 2 ] < aSize[ 4 ]
   aPos[ 2 ]:= aSize[ 4 ] - aSizeDA[ 2 ]
ENDIF

lExito:= ::drawingArea:setPosAndSize( aPos, aSizeDA )

IF ::vScroll <> NIL
   ::vScroll:setRange( { 0, INT( ( aSizeDA[ 2 ] - aSize[ 4 ] ) / ;
                                 ::nSkipPixels ) } )
   nValor:= INT( ( aSizeDA[ 2 ] + ::drawingArea:currentPos()[ 2 ] - ;
                   aSize[ 4 ] ) / ::nSkipPixels )
   ::vScroll:setData( nValor )
   ::vScroll:cargo:= nValor
ENDIF

IF ::hScroll <> NIL
   nValor:= INT( ( aSizeDA[ 1 ] - aSize[ 3 ] ) / ::nSkipPixels )
   ::hScroll:setRange( { 0, nValor } )
   nValor -= INT( ( aPos[ 1 ] + aSizeDA[ 1 ] - aSize[ 3 ] ) / ::nSkipPixels )
   ::hScroll:setData( nValor )
   ::hScroll:cargo:= nValor
ENDIF

RETURN lExito

***********************************
METHOD S2ScrollArea:hScroll( mp1 )
***********************************
LOCAL nPos := mp1[ 1 ]
LOCAL nXPos

IF nPos <> ::hScroll:cargo .AND. ::hScroll:isVisible()
   IF nPos = 0
      nXPos:= 0
   ELSEIF nPos = ::hScroll:range[ 2 ]
      nXPos:= ::oVisor:calcClientRect( { 0, 0, ::oVisor:currentSize()[ 1 ], ;
              ::oVisor:currentSize()[ 2 ] } )[ 3 ] - ::aSizeScrollArea[ 1 ]
   ELSE
      nXPos:=  - ::nSkipPixels * ( nPos  - ::hScroll:range[ 1 ] )
   ENDIF
   ::drawingArea:setPos( { nXPos, ::drawingArea:currentPos()[ 2 ] } )
   ::hScroll:cargo:= nPos
ENDIF
RETURN self

***********************************
METHOD S2ScrollArea:vScroll( mp1 )
***********************************
LOCAL nPos := mp1[ 1 ]
LOCAL nXPos

IF nPos <> ::vScroll:cargo .AND. ::vScroll:isVisible()
   IF nPos = 0
      nXPos:= ::oVisor:calcClientRect( { 0, 0, ::oVisor:currentSize()[ 1 ], ;
              ::oVisor:currentSize()[ 2 ] } )[ 4 ] - ::aSizeScrollArea[ 2 ]
   ELSEIF nPos = ::vScroll:range[ 2 ]
      nXPos:= 0
   ELSE
      nXPos:=  - ::nSkipPixels * ( ::vScroll:range[ 2 ] - nPos )
   ENDIF

   ::drawingArea:setPos( { ::drawingArea:currentPos()[ 1 ], nXPos } )
   ::vScroll:cargo:= nPos
ENDIF
RETURN self

******************************************
METHOD S2ScrollArea:GetPosVScroll( lMax )
******************************************
RETURN IIF( ::vScroll = NIL .OR. ! ::vScroll:isVisible(), NIL, ;
            IIF( lMax <> NIL .AND. lMax, ::vScroll:range[ 2 ], ;
                                         ::vScroll:cargo ) )

*******************************************
METHOD S2ScrollArea:SkipVScroll( nSaltos )
*******************************************
LOCAL nPos

IF ::vScroll = NIL .OR. ! ::vScroll:isVisible()
   RETURN NIL
ENDIF

nPos:= ::vScroll:cargo

IF nSaltos > 0
   nPos:= MIN( ::vScroll:range[ 2 ], nPos + nSaltos )
ELSEIF nSaltos < 0
   nPos:= MAX( 0, nPos + nSaltos )
ENDIF
::vScroll:cargo:= -1
::vScroll( { nPos } )
RETURN ::vScroll:setData( nPos )

****************************************
METHOD S2ScrollArea:GoToVScroll( nPos )
****************************************
IF ::vScroll = NIL .OR. ! ::vScroll:isVisible()
   RETURN NIL
ELSEIF nPos < 0
   nPos := 0
ELSEIF nPos > ::vScroll:range[ 2 ]
   nPos := ::vScroll:range[ 2 ]
ENDIF
::vScroll:cargo:= -1
::vScroll( { nPos } )
RETURN ::vScroll:setData( nPos )

*********************************************
METHOD S2ScrollArea:GoPosRelVScroll( nPorc )
*********************************************
LOCAL nPos

IF ::vScroll = NIL .OR. ! ::vScroll:isVisible()
   RETURN NIL
ELSEIF nPorc < 0
   nPorc := 0
ELSEIF nPorc > 100
   nPorc := 100
ENDIF

nPos:= INT( ::vScroll:range[ 2 ] * nPorc / 100 )

::vScroll:cargo:= -1
::vScroll( { nPos } )
RETURN ::vScroll:setData( nPos )

******************************************
METHOD S2ScrollArea:GetPosHScroll( lMax )
******************************************
RETURN IIF( ::hScroll = NIL .OR. ! ::hScroll:isVisible(), NIL, ;
            IIF( lMax <> NIL .AND. lMax, ::hScroll:range[ 2 ], ;
                                         ::hScroll:cargo ) )

*******************************************
METHOD S2ScrollArea:SkipHScroll( nSaltos )
*******************************************
LOCAL nPos

IF ::hScroll = NIL .OR. ! ::hScroll:isVisible()
   RETURN NIL
ENDIF

nPos:= ::hScroll:cargo

IF nSaltos > 0
   nPos:= MIN( ::hScroll:range[ 2 ], nPos + nSaltos )
ELSEIF nSaltos < 0
   nPos:= MAX( 0, nPos + nSaltos )
ENDIF

::hScroll:cargo:= -1
::hScroll( { nPos } )
RETURN ::hScroll:setData( nPos )

****************************************
METHOD S2ScrollArea:GoToHScroll( nPos )
****************************************
IF ::hScroll = NIL .OR. ! ::hScroll:isVisible()
   RETURN NIL
ELSEIF nPos < 0
   nPos := 0
ELSEIF nPos > ::hScroll:range[ 2 ]
   nPos := ::hScroll:range[ 2 ]
ENDIF
::hScroll:cargo:= -1
::hScroll( { nPos } )
RETURN ::hScroll:setData( nPos )

*********************************************
METHOD S2ScrollArea:GoPosRelHScroll( nPorc )
*********************************************
LOCAL nPos

IF ::hScroll = NIL .OR. ! ::hScroll:isVisible()
   RETURN NIL
ELSEIF nPorc < 0
   nPorc := 0
ELSEIF nPorc > 100
   nPorc := 100
ENDIF

nPos:= INT( ::hScroll:range[ 2 ] * nPorc / 100 )

::hScroll:cargo:= -1
::hScroll( { nPos } )
RETURN ::hScroll:setData( nPos )

*****************************************
METHOD S2ScrollArea:forceVisible( oXbp )
*****************************************
LOCAL aPos       := {0, 0}
LOCAL aSize      := oXbp:currentSize()
LOCAL aPosArea   := ::drawingArea:currentPos()
LOCAL aSizeVisor := ::oVisor:currentSize()
LOCAL nCont, nTmp
LOCAL oTmp

nCont := 0
oTmp := oXbp
DO WHILE .T.
   aPos[1]       += oTmp:currentPos()[1]
   aPos[2]       += oTmp:currentPos()[2]

   IF ++nCont >1000
      nCont := -1 // errore
      EXIT
   ENDIF

   IF EMPTY(oTmp:setParent())
      nCont := -1 // errore
      EXIT
   ENDIF

   IF oTmp == AppDesktop()
      nCont := -1 // errore
      EXIT
   ENDIF

   IF oTmp:setParent() == ::drawingArea
      EXIT // OK
   ENDIF

   oTmp := oTmp:setParent()
ENDDO


IF nCont < 0  // errore?
   RETURN self
ENDIF

nCont := NIL

IF ::vScroll <> NIL .AND. ::vScroll:isVisible()
   IF aPos[ 2 ] < ABS( aPosArea[ 2 ] )
      aPos[ 2 ] -= OFFSET_CENTER
      FOR nCont:= ::vScroll:cargo TO ::vScroll:range[ 2 ]
         ::SkipVScroll( 1 )
         IF aPos[ 2 ] >= ABS( ::drawingArea:currentPos()[ 2 ] )
            EXIT
         ENDIF
      NEXT
   ELSEIF aPos[ 2 ] + OFFSET_CENTER + aSize[ 2 ] > ABS( aPosArea[ 2 ] ) + aSizeVisor[ 2 ]
      aPos[ 2 ] += OFFSET_CENTER
      FOR nCont:= ::vScroll:cargo TO 0 STEP -1
         ::SkipVScroll( -1 )
         nTmp:= ABS( ::drawingArea:currentPos()[ 2 ] )
         IF aPos[ 2 ] < nTmp
            ::SkipVScroll( 1 )
            EXIT
         ELSEIF aPos[ 2 ] + aSize[ 2 ] <= nTmp + aSizeVisor[ 2 ]
            EXIT
         ENDIF
      NEXT
   ENDIF
ENDIF

IF ::hScroll <> NIL .AND. ::hScroll:isVisible()
   IF aPos[ 1 ] < ABS( aPosArea[ 1 ] )
      FOR nCont:= ::hScroll:cargo TO ::hScroll:range[ 2 ]
         ::SkipHScroll( 1 )
         IF aPos[ 1 ] >= ABS( ::drawingArea:currentPos()[ 1 ] )
            EXIT
         ENDIF
      NEXT
   ELSEIF aPos[ 1 ] + aSize[ 1 ] > ABS( aPosArea[ 1 ] ) + aSizeVisor[ 1 ]
      FOR nCont:= ::hScroll:cargo TO 0 STEP -1
         ::SkipHScroll( -1 )
         nTmp:= ABS( ::drawingArea:currentPos()[ 1 ] )
         IF aPos[ 1 ] < nTmp
            ::SkipHScroll( 1 )
            EXIT
         ELSEIF aPos[ 1 ] + aSize[ 1 ] <= nTmp + aSizeVisor[ 1 ]
            EXIT
         ENDIF
      NEXT
   ENDIF
ENDIF
RETURN self

