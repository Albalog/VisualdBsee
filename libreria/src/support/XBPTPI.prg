#include "dfStd.ch"
#include "dfSet.ch"
#include "XBP.ch"
#include "GRA.ch"

// Modifica Simone 30/apr/04 
//  - adesso rilascia correttamente il thread dopo averlo usato

// #define PIBOX_TYPE            XBPSTATIC_TYPE_RECESSEDBOX 
// #define PIBOX_CLR_BACKGROUND  GRA_CLR_WHITE 

#define PIBOX_TYPE            XBPSTATIC_TYPE_RAISEDBOX

// Identica alla standard fornita da Alaska

/*
 * Class for visualizing a progressing process
 */
CLASS ThreadProgressBar FROM XbpStatic
   PROTECTED:
   VAR    squares, every, _current
   METHOD displayHoriz, displayVert

   EXPORTED:
   VAR           maxWait, color, colorBG,Thread,sig
   VAR           minimum, current, maximum
   ASSIGN METHOD minimum, current, maximum

   METHOD init   , create , destroy , setSize
   METHOD display, execute, increment
ENDCLASS



/*
 * Initialize the object and set Thread:interval() to zero. This way,
 * method :execute() is automatically repeated.
 */
METHOD ThreadProgressBar:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::Thread := Thread():New() // don't inherhit
//   ::Thread:init()
   ::Thread:setInterval( 1 ) // maybe the problem is with interval(0)-nope
   ::Thread:atStart := {|| ::xbpStatic:show() }
   ::Sig := Signal():New()  // don't inherhit
//   ::Signal:init()

   ::xbpStatic:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::xbpStatic:type  := PIBOX_TYPE
   ::xbpStatic:paint := {|| ::display() }

   ::color   := GRA_CLR_DARKBLUE
   ::colorBG := GRA_CLR_WHITE

   ::xbpStatic:setColorBG(::colorBG)

   ::squares := 1
   ::current := 0
   ::every   := 1
   ::maxWait := 100
   ::minimum := 0
   ::maximum := 100
RETURN self



/*
 * Request system resources; calculate the number or squares which
 * fit into the progress bar and start the thread.
 */
METHOD ThreadProgressBar:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::xbpStatic:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   aSize     := ::currentSize()
   ::squares := Int( aSize[1] / (aSize[2]+1) )
   ::Thread:start({||::execute()})
RETURN self



/*
 * Stop the thread of ThreadProgressBar and release system resources
 */
METHOD ThreadProgressBar:destroy

  /*
   * Turn off automatic repetition of :execute().
   */
   ::thread:setInterVal( NIL )


   IF ::thread:active
     /*
      * Thread is still active.
      * Signal thread to leave its :wait() state
      */
      ::Sig:signal()
   ENDIF


   IF ThreadObject() <> ::thread
     /*
      * The current thread is not the thread of ThreadProgressBar (self).
      * Therefore, the current thread must wait for the end of self:thread
      */
      ::thread:synchronize(0)
   ENDIF


  /*
   * System resources are released when self:thread has terminated
   */
   ::thread := NIL  // bingo this does release the thread!!!!
   ::xbpStatic:destroy()

RETURN self



/*
 * Change the size of ThreadProgressBar. Before the size is changed,
 * everything is overpainted with the background color.
 */
METHOD ThreadProgressBar:setSize( aSize )
   LOCAL oPS, aAttr[ GRA_AA_COUNT ], _aSize

   oPS       := ::lockPS()
   _aSize    := ::currentSize()
   _aSize[1] -= 2
   _aSize[2] -= 2
   aAttr [ GRA_AA_COLOR ] := ::colorBG
   GraSetAttrArea( oPS, aAttr )
   GraBox( oPS, {1,1}, _aSize, GRA_FILL )
   ::unlockPS( oPS )
   ::xbpStatic:setSize( aSize )

RETURN self



/*
 * ASSIGN method for :minimum
 */
METHOD ThreadProgressBar:minimum( nMinimum )

   IF ::maximum <> NIL .AND. nMinimum > ::maximum
      ::minimum := ::maximum
      ::maximum := nMinimum
   ELSE
      ::minimum := nMinimum
   ENDIF

   ::current := ::minimum
RETURN self



/*
 * ASSIGN method for :current
 */
METHOD ThreadProgressBar:current( nCurrent )

   IF Valtype( nCurrent ) == "N"
      ::current := nCurrent

      IF Valtype( ::maximum ) + Valtype( ::minimum ) == "NN"
         ::every    := Int( ( ::maximum - ::minimum ) / ::squares )
         ::_current := ::current
      ENDIF
   ENDIF

RETURN ::current



/*
 * ASSIGN method for :maximum
 */
METHOD ThreadProgressBar:maximum( nMaximum )

   IF ::minimum <> NIL .AND. nMaximum < ::minimum
      ::maximum := ::minimum
      ::minimum := nMaximum
   ELSE
      ::maximum := nMaximum
   ENDIF

   ::current := ::minimum

RETURN self



/*
 * Increment the current value and refresh display if necessary
 */
METHOD ThreadProgressBar:increment( nIncrement )

   IF Valtype( nIncrement ) <> "N"
      nIncrement := 1
   ENDIF

  /*
   * While a progress is displayed, PROTECTED VAR :_current is incremented
   * to avoid the overhead of the ASSIGN method :current()
   */
   ::_current += nIncrement


   IF Int( ::_current % ::every ) == 0
     /*
      * This interrupts the ::wait( ::maxWait ) method in :execute().
      * The progress bar is then refreshed immediately in its own thread.
      * Since the display occurs in a separate thread, it does not
      * slow down the actual process whose progress is visualized.
      * Index creation, for example, does not update the display,
      * but only signals self:thread
      */
      ::Sig:signal()
   ENDIF
RETURN



/*
 * Refresh progress bar automatically every ::maxWait / 100 seconds
 * This method runs in self:thread and is automatically restarted
 * due to :setInterval(0)
 */
METHOD ThreadProgressBar:execute

   ::Sig:wait( ::maxWait )
   ::display()

RETURN self



/*
 * Visualize the current state of a process
 */
METHOD ThreadProgressBar:display
   LOCAL oPS   := ::lockPS()
   LOCAL aSize := ::currentSize()
   LOCAL aAttr [ GRA_AA_COUNT ]

   aSize[1] -= 2
   aSize[2] -= 2

   IF aSize[1] > aSize[2]
      ::displayHoriz( oPS, aSize, aAttr )
   ELSE
      ::displayVert ( oPS, aSize, aAttr )
   ENDIF

   ::unlockPS( oPS )
RETURN self



/*
 * Display squares from left to right (horizontal display)
 */
METHOD ThreadProgressBar:displayHoriz( oPS, aSize, aAttr )
   LOCAL nX, aPos1, aPos2, nCenter

  /*
   * Max. x coordinate for squares
   */
   nX := aSize[1] * ::_current / ( ::maximum - ::minimum )
   nX := Min( nX, aSize[1] )

  /*
   * Fill the area to the right of the squares with background color
   */
   aAttr [ GRA_AA_COLOR ] := ::colorBG
   GraSetAttrArea( oPS, aAttr )
   GraBox( oPS, {1+nX,1}, {aSize[1],aSize[2]}, GRA_FILL )

  /*
   * Define fill color for squares
   */
   aAttr [ GRA_AA_COLOR ] := ::color
   GraSetAttrArea( oPS, aAttr )

  /*
   * Calculate position for leftmost square (starting position)
   */
   aPos1     := { 2, 2 }
   ::squares := Int( aSize[1] / (aSize[2]+1) )
   nCenter   := 2 + ( aSize[1] - (::squares * (aSize[2]+1)) ) / 2
   aPos1[1]  := Max( 2, nCenter )
   aPos2     := { aPos1[1]+aSize[2]-2 , aSize[2]-1 }

  /*
   * Draw the squares
   */
   DO WHILE aPos2[1] < nX
      GraBox( oPS, aPos1, aPos2, GRA_FILL )
      aPos1[1] += aSize[2]+1
      aPos2[1] += aSize[2]+1
   ENDDO

   IF aPos2[1] < aSize[1]
      GraBox( oPS, aPos1, aPos2, GRA_FILL )
   ENDIF

RETURN self



/*
 * Display squares from bottom to top (vertical display)
 */
METHOD ThreadProgressBar:displayVert( oPS, aSize, aAttr )
   LOCAL nY, aPos1, aPos2, nCenter

  /*
   * Max. y coordinate for squares
   */
   nY := aSize[2] * ::_current / ( ::maximum - ::minimum )
   nY := Min( nY, aSize[2] )

  /*
   * Fill the area above the squares with background color
   */
   aAttr [ GRA_AA_COLOR ] := ::colorBG
   GraSetAttrArea( oPS, aAttr )
   GraBox( oPS, {1,nY}, {aSize[1],aSize[2]}, GRA_FILL )

  /*
   * Define fill color for squares
   */
   aAttr [ GRA_AA_COLOR ] := ::color
   GraSetAttrArea( oPS, aAttr )

  /*
   * Calculate position for lowest square (starting position)
   */
   aPos1     := { 2, 2 }
   ::squares := Int( aSize[2] / (aSize[1]+1) )
   nCenter   := 2 + (aSize[2] - (::squares * (aSize[1]+1)) ) / 2
   aPos1[2]  := Max( 2, nCenter )
   aPos2     := { aSize[1]-1, aPos1[2]+aSize[1]-2 }

  /*
   * Draw the squares
   */
   DO WHILE aPos2[2] < nY
      GraBox( oPS, aPos1, aPos2, GRA_FILL )
      aPos1[2] += aSize[1]+1
      aPos2[2] += aSize[1]+1
   ENDDO

   IF aPos2[2] < aSize[2]
      GraBox( oPS, aPos1, aPos2, GRA_FILL )
   ENDIF

RETURN self


