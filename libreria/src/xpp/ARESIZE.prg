///////////////////////////////////////////////////////////////////////////////
//
//                             A  C  S  N
//
// +---------------  Alaska Certified Solutions Network  -------------------+
// |                                                                        |
// |        This file is proved and certified by Alaska Software            |
// |                                                                        |
// |                   No: <Certification number>                           |
// |                          109xxx-04-0005                                |
// |                                                                        |
// |   For more information about ACSN read the appropriate announcement    |
// |      or scan for ACSN in the Alaska Support-LIBs on CompuServe or      |
// |                   at WWW.ALASKA-SOFTWARE.COM                           |
// |                                                                        |
// +------------------------------------------------------------------------+
//
// FILE NAME
//
//    AResize.prg
//
// AUTHOR
//
//    (c) Copyright 1997-98, Joerg Witzel
//
//    ALL RIGHTS RESERVED
//
//    This file is the property of AUTHOR. It participates in the
//    Alaska Certified Solutions Network program. Permission to use,
//    copy, modify, and distribute this software for any purpose and
//    without fee is hereby granted, provided that the above copyright
//    notice appear in all copies and that the name of the author or
//    Alaska Software not be used in advertising or publicity pertaining
//    to distribution of the software without specific, written prior
//    permission.
//
// WARRANTY
//
//    THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
//    AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
//    INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
//    FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL THE AUTHOR
//    OR ALASKA SOFTWARE BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT,
//    SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND,
//    INCLUDING WITHOUT LIMITATION, LOSS OF PROFIT AND LOSS OF USE.
//
// DESCRIPTION
//
//    Implementation of AutoResize class. This class can be used as base class
//    to add a automatic resize feature to Xbase Parts.
//
// REMARKS
//    This class uses the class C_SET internally.
//
//    To use this class you have to do the following steps (see also
//    the comments within the sample dialogs):
//    1.Add AutoResize as base class to your dialog class
//    2.Implement the deffered method resizeArea within your
//      dialog class. This method has to return the Xbase Part
//      whose childs will be resized. I.e. for a XbpDialog
//      this is the ::drawingArea
//    3.call resizeInit() within the create method of your class.
//      It should be called after the create() of the dialog and
//      before the show(). ResizeInit() just gets an array with
//      those childs of your dialog which should be resized by
//      the AutoResize class.
//
//
// HISTORY
//
//    14/01/98 Version 1.1 finshed: Complete reimplementation.
//    07/23/97 First implementation finished.
//
///////////////////////////////////////////////////////////////////////////////
#include "Common.ch"

//-----------------------------------------------------------------------------
CLASS AutoResize
//-----------------------------------------------------------------------------
EXPORTED:
   METHOD resizeDataArea      // called from the resize event callback slot

PROTECTED:
   DEFERRED METHOD resizeArea // this method has to return the Xbase Part which
                              // is the parent of the resize objects (resize parent)
                              // TO IMPLEMENT IN THE DERIVED CLASS !!!
   METHOD resizeInit          // see implementation

HIDDEN:
   METHOD findXDepends
   METHOD findYDepends
   METHOD issueResizeFraction
   METHOD issueMoveFraction

   VAR aChildList
   VAR aOrgSize               // original size of resize parent
   VAR aHDepend		      // horizontal dependencies for all childs
   VAR aVDepend		      // vertical dependencies for all childs
   VAR aTransform             // array of AR_TranformData objects for all childs
ENDCLASS

//-----------------------------------------------------------------------------
METHOD AutoResize:resizeInit( aResizeList )
//
// [aResizeList]: array with childs of the resize parent.
//
// All objects in this list will be resized according to their position in the
// window. All child not in this list will be moved according to their position
// in the window but will not change their size.
//-----------------------------------------------------------------------------
   LOCAL i, n
   LOCAL numResize := LEN( aResizeList )
   LOCAL numChilds
   LOCAL aNewFollow
   LOCAL oNoPrecede
   LOCAL cResizeMode, lHResize, lVResize

   ::aChildList := ::resizeArea():childList() 
   numChilds    := LEN( ::aChildList )
   ::aOrgSize   := ::resizeArea():currentSize()
   ::aHDepend   := ARRAY( numChilds )
   ::aVDepend   := ARRAY( numChilds )
   ::aTransform := ARRAY( numChilds )


   //
   // create XY-dependencies for all childs
   //
   FOR i:=1 TO numChilds
      ::aHDepend[i] := AR_DependData():new( ::findXDepends( i ) )
      ::aVDepend[i] := AR_DependData():new( ::findYDepends( i ) )
      ::aTransform[i] := AR_TransformData():new( ::aChildList[i] )
   NEXT

   //
   // evaluate resize list: mark resize mode of childs
   //
   lHResize := lVResize := .T.
   FOR i:=1 TO numResize
      IF VALTYPE(aResizeList[i]) == 'O'
         n := aScan( ::aChildList, aResizeList[i] )
         IF n > 0
            ::aHDepend[n]:lResize := lHResize
            ::aVDepend[n]:lResize := lVResize
         ENDIF
      ELSEIF VALTYPE(aResizeList[i]) == 'C'
         cResizeMode := UPPER(LEFT(aResizeList[i],1))
         DO CASE
         CASE cResizeMode == "B"
            lHResize := lVResize := .T.

         CASE cResizeMode == "H"
            lHResize := .T.
            lVResize := .F.

         CASE cResizeMode == "V"
            lHResize := .F.
            lVResize := .T.
         ENDCASE
      ENDIF
   NEXT

   //
   // for all childs i: remove the indirect dependencies
   //
   aNewFollow := ARRAY( numChilds )
   FOR i:=1 TO numChilds
      aNewFollow[i] := ::aHDepend[i]:getDirectDepends( ::aHDepend )
   NEXT
   FOR i:=1 TO numChilds
      ::aHDepend[i]:oFollow := aNewFollow[i]
   NEXT

   FOR i:=1 TO numChilds
      aNewFollow[i] := ::aVDepend[i]:getDirectDepends( ::aVDepend )
   NEXT
   FOR i:=1 TO numChilds
      ::aVDepend[i]:oFollow := aNewFollow[i]
   NEXT

   //
   // for all childs i: initialise the precede sets
   //
   FOR i:=1 TO numChilds
      ::aHDepend[i]:addPrecede( ::aHDepend, i )
      ::aVDepend[i]:addPrecede( ::aVDepend, i )
   NEXT

   //
   // calculate the resize-fraction for all resized objects
   // and set move-fractions
   //
   FOR i:=1 TO numChilds
      ::aHDepend[i]:maxResizePath( ::aHDepend )
      ::aVDepend[i]:maxResizePath( ::aVDepend )
   NEXT

   // get all objects which have no preceding objects
   oNoPrecede := C_Set():new()
   FOR i:=1 TO numChilds
      IF ::aHDepend[i]:oPrecede:numberOfElements() == 0
        oNoPrecede:addElement( i )
      ENDIF
   NEXT
   // issue resize and move fraction in horizontal direction
  ::issueResizeFraction( oNoPrecede, "H", 1 )
  ::issueMoveFraction( oNoPrecede, "H", 0 )

   // get all objects which have no preceding objects
   oNoPrecede := C_Set():new()
   FOR i:=1 TO numChilds
      IF ::aVDepend[i]:oPrecede:numberOfElements() == 0
        oNoPrecede:addElement( i )
      ENDIF
   NEXT
   // issue resize and move fraction in vertical direction
  ::issueResizeFraction( oNoPrecede, "V", 1 )
  ::issueMoveFraction( oNoPrecede, "V", 0 )

   FOR i:=1 TO numChilds
      IF .NOT. ::aHDepend[i]:lResize
         ::aTransform[i]:nResizeH := 0
      ENDIF
      IF .NOT. ::aVDepend[i]:lResize
         ::aTransform[i]:nResizeV := 0
      ENDIF
   NEXT

   // set the resize event callback slot
   ::resizeArea():Resize := { | mp1, mp2, obj | ::resizeDataArea( mp1, mp2 ) }

RETURN

//-----------------------------------------------------------------------------
METHOD AutoResize:findXDepends( nChildID )
//
// Parameter: index of a child
// Returns: object of class C_SET with child-list indices
//
// find all childs oc with
//    oc.x > or.x  and  oc.y < or.y+or.h  and  oc.y+oc.h > or.y
//-----------------------------------------------------------------------------
   LOCAL i
   LOCAL childPos, childSize
   LOCAL rPos, rSize
   LOCAL depend := C_Set():new()

   rPos := ::aChildList[nChildID]:currentPos()
   rSize := ::aChildList[nChildID]:currentSize()

   FOR i:=1 TO LEN(::aChildList)
      childPos := ::aChildList[i]:currentPos()
      childSize := ::aChildList[i]:currentSize()
      IF childPos[1] > rPos[1] ;
         .AND. childPos[2] < rPos[2]+rSize[2] ;
         .AND. childPos[2]+childSize[2] > rPos[2]
    	    depend:addElement( i )
      ENDIF
   NEXT
RETURN  depend

//-----------------------------------------------------------------------------
METHOD AutoResize:findYDepends( nChildID )
//
// Parameter: index of a child
// Returns: object of class C_SET with child-list indices
//
// find all childs oc with
//        oc.y > or.y  and  oc.x < or.x+or.w  and  oc.x+oc.w > or.x
//-----------------------------------------------------------------------------
   LOCAL i
   LOCAL childPos, childSize
   LOCAL rPos, rSize
   LOCAL depend := C_Set():new()

   rPos := ::aChildList[nChildID]:currentPos()
   rSize := ::aChildList[nChildID]:currentSize()

   FOR i:=1 TO LEN(::aChildList)
      childPos := ::aChildList[i]:currentPos()
      childSize := ::aChildList[i]:currentSize()
      IF childPos[2] > rPos[2] ;
         .AND. childPos[1] < rPos[1]+rSize[1] ;
         .AND. childPos[1]+childSize[1] > rPos[1]
   	    depend:addElement( i )
      ENDIF
   NEXT
RETURN depend

//---------------------------------------------------------------------------
METHOD AutoResize:issueResizeFraction( osetID, cDir, nFrac )
//---------------------------------------------------------------------------
   LOCAL i, k, n, f
   LOCAL cResize := "nResize"+cDir
   LOCAL aDepend := ::&("a"+cDir+"Depend")

   n := osetID:numberOfElements()
   FOR i:=1 TO n

      k := osetID:getElement( i )

      // if object is already part of another resize path:
      // use smaller resize fraction

      // evito divisione per 0
      //f := nFrac / aDepend[k]:nMaxPath

      f := aDepend[k]:nMaxPath
      if f != 0
         f := nFrac / f
      endif

      IF ::aTransform[ k ]:&(cResize) > f
         ::aTransform[ k ]:&(cResize) := f
      ELSE
         f := ::aTransform[ k ]:&(cResize)
      ENDIF

      IF aDepend[k]:lResize
         // issue rest of resize fraction
         ::issueResizeFraction( aDepend[k]:oFollow, cDir, nFrac - f )
      ELSE
         // this object does not resize: issue complete resize fraction
         ::issueResizeFraction( aDepend[k]:oFollow, cDir, nFrac )
      ENDIF

   NEXT
RETURN

//-----------------------------------------------------------------------------
METHOD AutoResize:issueMoveFraction( osetID, cDir, nFrac )
//-----------------------------------------------------------------------------
   LOCAL i, k, f, n
   LOCAL cMove := "nMove"+cDir
   LOCAL cResize := "nResize"+cDir
   LOCAL aDepend := ::&("a"+cDir+"Depend")

   n := osetID:numberOfElements()
   FOR i:=1 TO n

      k := osetID:getElement( i )

      // if object is already part of another move dependency:
      // use bigger move fraction
      IF ::aTransform[ k ]:&(cMove) < nFrac
         ::aTransform[ k ]:&(cMove) := f := nFrac
      ELSE
         f := ::aTransform[ k ]:&(cMove)
      ENDIF

      // increase move fraction if this object does resize
      IF aDepend[k]:lResize
         f += ::aTransform[ k ]:&(cResize)
      ENDIF
      ::issueMoveFraction( aDepend[k]:oFollow, cDir, f )

   NEXT
RETURN

//-----------------------------------------------------------------------------
METHOD AutoResize:resizeDataArea( aOldSize, aNewSize )
//
// for all childs: calculate their new position and size relative to their
//                 original position
//-----------------------------------------------------------------------------
   LOCAL i, n := LEN( ::aChildList )
   LOCAL aOrgDelta

   // calculate delta between original size and new size
   aOrgDelta := { aNewSize[1] - ::aOrgSize[1], aNewSize[2] - ::aOrgSize[2] }

   ::resizeArea():lockUpdate(.T.)

   // set new position and size for all childs
   FOR i:=1 TO n
       ::aChildList[i]:SetPos( ::aTransform[i]:newPos( aOrgDelta ) )
       ::aChildList[i]:SetSize( ::aTransform[i]:newSize( aOrgDelta ) )
   NEXT
   ::resizeArea():lockUpdate(.F.)
   ::resizeArea():invalidateRect()
RETURN self


//-----------------------------------------------------------------------------
STATIC CLASS AR_TransformData
//
// For each child an instance of this class will be calculated at init time
// The data in these instances is then used after every resize event
//-----------------------------------------------------------------------------
EXPORTED:
   VAR aOrgSize		// original size at init time
   VAR aOrgPos          // original position at init time
   VAR nMoveH           // newPos = orgPos + move * orgDeltaSize
   VAR nMoveV           //
   VAR nResizeH         // newSize = orgSize + resize * orgDeltaSize
   VAR nResizeV

   METHOD init()
   METHOD newPos()      // -> aNewPos
   METHOD newSize()     // -> aNewSize

ENDCLASS

//-----------------------------------------------------------------------------
METHOD AR_TransformData:init( oChild )
//-----------------------------------------------------------------------------
   ::aOrgSize := oChild:currentSize()
   ::aOrgPos := oChild:currentPos()
   ::nMoveH := ::nMoveV := 0
   ::nResizeH := ::nResizeV := 1
RETURN self

//-----------------------------------------------------------------------------
METHOD AR_TransformData:newPos(orgDeltaSize)
//-----------------------------------------------------------------------------
IF ::nMoveH != 0 .OR. ::nMoveV != 0
   RETURN { ::aOrgPos[1] + ::nMoveH * orgDeltaSize[1],;
            ::aOrgPos[2] + ::nMoveV * orgDeltaSize[2] }
ENDIF
RETURN ::aOrgPos

//-----------------------------------------------------------------------------
METHOD AR_TransformData:newSize(orgDeltaSize)
//-----------------------------------------------------------------------------
IF ::nResizeH != 0 .OR. ::nResizeV != 0
   RETURN { ::aOrgSize[1] + ::nResizeH * orgDeltaSize[1],;
            ::aOrgSize[2] + ::nResizeV * orgDeltaSize[2] }
ENDIF
RETURN ::aOrgSize

//-----------------------------------------------------------------------------
STATIC CLASS AR_DependData
//
// All member variables contain sets of child indices
//-----------------------------------------------------------------------------
EXPORTED:
   VAR oFollow	// all childs which directly depend on this one i.e. which are
                // are not also depend on childs which depend on this one
   VAR oPrecede // all childs which have this one in their oFollow set

   VAR lResize
   VAR nMaxPath
   VAR nMaxID

   METHOD init
   METHOD getDirectDepends
   METHOD addPrecede
   METHOD maxResizePath
ENDCLASS

//-----------------------------------------------------------------------------
METHOD AR_DependData:init( oFollow )
//-----------------------------------------------------------------------------
   ::oFollow := oFollow
   ::oPrecede := C_Set():new()
   ::lResize := .F.
RETURN self

//-----------------------------------------------------------------------------
METHOD AR_DependData:getDirectDepends( aDepend )
//-----------------------------------------------------------------------------
   LOCAL i, n, oDirectFollow

   // for all childs DD directly behind this child
   n := ::oFollow:numberOfElements()
   oDirectFollow := ::oFollow:clone()
   FOR i := 1 TO n
      // remove childs in follow(this) which are also in follow(DD)
      oDirectFollow:subtract( aDepend[ ::oFollow:getElement( i ) ]:oFollow )
   NEXT
RETURN oDirectFollow

//-----------------------------------------------------------------------------
METHOD AR_DependData:addPrecede( aDepend, nThisID )
//-----------------------------------------------------------------------------
   LOCAL i,n

   // for all childs x behind this child
   n := ::oFollow:numberOfElements()
   FOR i := 1 TO n
      // this child precedes child x
      aDepend[ ::oFollow:getElement( i ) ]:oPrecede:addElement( nThisID )
   NEXT
RETURN

//-----------------------------------------------------------------------------
METHOD AR_DependData:maxResizePath( aDepend )
//
// The longest resize path is the dependency path
// with the most resize-childs. A dependency path
// is a list of objects o1,o2,... with o2 in follow(o1)
//-----------------------------------------------------------------------------
   LOCAL i,n,nPath
   LOCAL followID, followMax

   IF ::nMaxPath != NIL
      RETURN ::nMaxPath
   ENDIF
   //
   // If this child has no max resize path so far then
   // calculate the path recursively for all childs in follow(this)
   //
   n := ::oFollow:numberOfElements()
   nPath := 0
   FOR i := 1 TO n
      followID := ::oFollow:getElement( i )
      followMax := aDepend[followID]:maxResizePath( aDepend )
      IF followMax > nPath
         nPath := followMax
         ::nMaxID := followID
      ENDIF
   NEXT
   IF ::lResize
      nPath++
   ENDIF
   ::nMaxPath := nPath

RETURN nPath
