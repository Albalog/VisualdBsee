//////////////////////////////////////////////////////////////////////
//
//  PROGRESS.PRG
//
//  Copyright:
//      Alaska Software Inc., (c) 1997. All rights reserved.
//
//  Contents:
//      The program contains the class ProgressBar for visualization
//      of a progressing process. This is accomplished by drawing
//      colored squares from left to right within the micro presentation
//      space of XbpStatic using GraBox() (-> horizontal display).
//
//      If the height of the progress bar exceeds its width, the squares
//      are drawn from bottom to top (-> vertical display).
//
//  Remarks:
//      - Automatic refresh
//
//        Drawing of the squares occurs in a separate thread and is initiated
//        by a signal in the method :increment(). If this method is not
//        invoked after :maxwait/100 seconds, the display is automatically
//        refreshed.
//
//      - Progress during DbCreateIndex() / OrdCreate()
//
//        The progress of creating an index file is displayed in the example.
//        If a ProgressBar object is used in this situation, the index file
//        must be closed after being created. This way, the code block where
//        the ProgressBar object is embedded is destroyed.
//
//        Note: A ProgressBar object refreshes display during indexing only
//        when an additional square must be drawn.
//
//////////////////////////////////////////////////////////////////////


#include "Appevent.ch"
#include "Gra.ch"
#include "Xbp.ch"

#define PIBOX_TYPE            XBPSTATIC_TYPE_RECESSEDBOX //XBPSTATIC_TYPE_RAISEDBOX


/*
 * Class for visualizing a progressing process
 */
CLASS ProgressBar FROM XbpStatic
   PROTECTED:
   VAR    squares, every, _current
   METHOD displayHoriz, displayVert

   VAR oPB

   EXPORTED:
   VAR           color, colorBG //, maxWait
   VAR           minimum, current, maximum
   ASSIGN METHOD minimum, current, maximum

   METHOD init   , create , setSize //, destroy
   METHOD display, increment        //, execute,
ENDCLASS



/*
 * Initialize the object and set Thread:interval() to zero. This way,
 * method :execute() is automatically repeated.
 */
METHOD ProgressBar:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::xbpStatic:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::xbpStatic:type  := PIBOX_TYPE
//   ::xbpStatic:paint := {|| IIF(::IsVisible(), ::display(), NIL) }
   ::oPB := _PBStatic():new(self, NIL, NIL, aSize)
   ::oPB:lGradientPaint := .T.
   ::oPB:setVertexColor(1,198,205,254)
   ::oPB:setVertexColor(2,14,23,92)
   ::color   := GRA_CLR_DARKBLUE
   ::colorBG := GRA_CLR_WHITE
   ::squares := 1
   ::current := 0
   ::every   := 1
   // ::maxWait := 100
   ::minimum := 0
   ::maximum := 100
RETURN



/*
 * Request system resources; calculate the number or squares which
 * fit into the progress bar and start the thread.
 */
METHOD ProgressBar:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::xbpStatic:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   aSize     := ::currentSize()

   ::oPB:create(self, NIL, NIL, {0, 0})

   ::squares := Int( aSize[1] / (aSize[2]+1) )
   // ::start()

RETURN



/*
 * Stop the thread of ProgressBar and release system resources
 */


/*
 * Change the size of ProgressBar. Before the size is changed,
 * everything is overpainted with the background color.
 */
METHOD ProgressBar:setSize( aSize )
   LOCAL oPS, aAttr[ GRA_AA_COUNT ], _aSize

//   oPS       := ::lockPS()
//   _aSize    := ::currentSize()
//   _aSize[1] -= 4
//   _aSize[2] -= 4
//   aAttr [ GRA_AA_COLOR ] := ::colorBG
//   GraSetAttrArea( oPS, aAttr )
//   GraBox( oPS, {1,1}, _aSize, GRA_FILL )
//   ::unlockPS( oPS )
   ::xbpStatic:setSize( aSize )
   ::display()
RETURN self



/*
 * ASSIGN method for :minimum
 */
METHOD ProgressBar:minimum( nMinimum )

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
METHOD ProgressBar:current( nCurrent )

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
METHOD ProgressBar:maximum( nMaximum )

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
METHOD ProgressBar:increment( nIncrement )

   IF Valtype( nIncrement ) <> "N"
      nIncrement := 1
   ENDIF

  /*
   * While a progress is displayed, PROTECTED VAR :_current is incremented
   * to avoid the overhead of the ASSIGN method :current()
   */
   ::_current += nIncrement

   ::display()

   // IF Int( ::_current % ::every ) == 0
   //   /*
   //    * This interrupts the ::wait( ::maxWait ) method in :execute().
   //    * The progress bar is then refreshed immediately in its own thread.
   //    * Since the display occurs in a separate thread, it does not
   //    * slow down the actual process whose progress is visualized.
   //    * Index creation, for example, does not update the display,
   //    * but only signals self:thread
   //    */
   //    ::signal()
   // ENDIF
RETURN



/*
 * Refresh progress bar automatically every ::maxWait / 100 seconds
 * This method runs in self:thread and is automatically restarted
 * due to :setInterval(0)
 */
// METHOD ProgressBar:execute
//
//    ::wait( ::maxWait )
//    ::display()
//
// RETURN self



/*
 * Visualize the current state of a process
 */
METHOD ProgressBar:display()
//   LOCAL oPS   := ::lockPS()
   LOCAL oPS
   LOCAL aSize := ::currentSize()
   LOCAL aAttr [ GRA_AA_COUNT ]

   aSize[1] -= 2
   aSize[2] -= 2

   IF aSize[1] > aSize[2]
      ::displayHoriz( oPS, aSize, aAttr )
   ELSE
      ::displayVert ( oPS, aSize, aAttr )
   ENDIF

//   ::unlockPS( oPS )
RETURN self



/*
 * Display squares from left to right (horizontal display)
 */
METHOD ProgressBar:displayHoriz( oPS, aSize, aAttr )
   LOCAL nX, aPos1, aPos2, nCenter

  /*
   * Max. x coordinate for squares
   */
   nX := aSize[1] * ::_current / ( ::maximum - ::minimum )
//   nX := Min( nX, aSize[1] )
   ::oPB:setSize({nX, aSize[2]})

RETURN self



/*
 * Display squares from bottom to top (vertical display)
 */
METHOD ProgressBar:displayVert( oPS, aSize, aAttr )
   LOCAL nY, aPos1, aPos2, nCenter

  /*
   * Max. y coordinate for squares
   */
   nY := aSize[2] * ::_current / ( ::maximum - ::minimum )
   nY := Min( nY, aSize[2] )
   ::oPB:setSize({aSize[1], nY})

RETURN self


STATIC CLASS _PBstatic FROM XbpStatic, GradientPaint
EXPORTED
    INLINE METHOD init(oParent, oOwner, aPos, aSize, aPP, lVisible)
       ::XbpStatic:init(oParent, oOwner, aPos, aSize, aPP, lVisible)
       ::GradientPaint:init(self)
       ::lGradientPaint := .T.
    RETURN self
ENDCLASS

