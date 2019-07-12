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
//    SET.PRG
//
// AUTHOR
//
//    (c) Copyright 1997, Joerg Witzel
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
//    Implementation of a Set-Class
//
// REMARKS
//
//    The set class implements a collection of elements. Each element
//    is unique within the set. There are methods to perform some mathematical
//    operations on set-instances.
//
// TODO
//    :isEmpty(), cursorInit(), cursorIsValid(), cursorElement(), cursorNext()
//    :clear()
//
// HISTORY
//
//    10/28/97 : Created by JW
//
///////////////////////////////////////////////////////////////////////////////

///////////
CLASS C_SET
///////////
EXPORTED:
   /////////////////////
   // Element operations
   /////////////////////
   SYNC METHOD addElement
   SYNC METHOD removeElement
   SYNC METHOD getElement
   METHOD isElement

   INLINE METHOD numberOfElements()
   RETURN LEN( ::aSet )

   /////////////////////
   // Set operations
   /////////////////////
   SYNC METHOD intersection
   SYNC METHOD join
   SYNC METHOD subtract

   ///////////////
   // Conversion
   ///////////////
   METHOD asArray

   ////////////////
   // Constructors
   ////////////////
   METHOD clone

PROTECTED:
   VAR aSet,nGet
   METHOD init

ENDCLASS

/////////////////////////////////////////
METHOD C_SET:init( x )
//
// [x]: oSetInstance|aInitElements|xInit
/////////////////////////////////////////
LOCAL i

   IF VALTYPE(x) == "O" .AND. x:isDerivedFrom( C_SET() )
      ::aSet := x:asArray()
   ELSEIF VALTYPE(x) == "A"
      ::aSet := {}
      FOR i := 1 TO LEN( x )
      ::addElement( x[i] )
      NEXT
   ELSEIF x != NIL
      ::aSet := {}
      ::addElement( x )
   ELSE
      ::aSet := {}
   ENDIF
   ::nGet := 1
RETURN self

////////////////////////////////////
METHOD C_SET:addElement( x )
//
// [x]: xElement
//
// Returns:
//   TRUE:  x is new element
//   FALSE: x is already an element
////////////////////////////////////

   IF aScan( ::aSet, x ) != 0
      RETURN .F.
   ELSE
      aAdd( ::aSet, x )
   ENDIF

RETURN .T.

////////////////////////////////////
METHOD C_SET:removeElement( x )
//
// [x]: xElement
//
// Returns:
//   TRUE:  x was an element
//   FALSE: x was not in set
////////////////////////////////////
LOCAL i

   i := aScan( ::aSet, x )
   IF i == 0
      RETURN .F.
   ELSE
      aDel( ::aSet, i )
      aSize( ::aSet, LEN(::aSet)-1 )
   ENDIF

RETURN .T.

////////////////////////////////////
METHOD C_SET:getElement( i )
//
// [i]: index of element. If no index
//      is given any element may be
//      returned
//
// Returns:
//   value of element i or NIL
//   if element could not be found
////////////////////////////////////
   IF empty( ::aSet )
      RETURN NIL
   ENDIF

   IF VALTYPE( i ) == "N"
      IF i > 0 .AND. i <= LEN( ::aSet )
         RETURN ::aSet[i]
      ENDIF
   ELSE
      i := ::nGet++
      IF ::nGet > LEN( ::aSet )
         ::nGet := 1
      ENDIF
      IF i <= LEN( ::aSet )
         RETURN ::aSet[i]
      ENDIF
   ENDIF

RETURN NIL

//////////////////////////////
METHOD C_SET:isElement( x )
//
// x : any value
//
// Returns:
//   TRUE if x is an element
//////////////////////////////
RETURN aScan( ::aSet, x ) != 0

////////////////////////////////////
METHOD C_SET:intersection( oSet )
//
// oSet: instance of C_SET class: only
//       elements which are part of
//       oSet and of self remain in
//       self
//
// Returns:
//   self
////////////////////////////////////
LOCAL i,l,lNew, p

   i := 1
   l := LEN( ::aSet )
   lNew := l
   WHILE l > 0
      p = aScan( oSet:aSet, ::aSet[i] )
      IF p == 0
         aDel( ::aSet, i )
	 lNew--
      ELSE
	 i++
      ENDIF
      l--
   END
   aSize( ::aSet, lNew )

RETURN self

////////////////////////////////////
METHOD C_SET:join( oSet )
//
// oSet: instance of C_SET class: all
//       elements of oSet are added
//       to self
//
// Returns:
//   self
////////////////////////////////////
LOCAL i

   FOR i := 1 TO LEN( oSet:aSet )
      IF aScan( ::aSet, oSet:aSet[i] ) == 0

         aAdd( ::aSet, oSet:aSet[i] )

      ENDIF
   NEXT

RETURN self

////////////////////////////////////
METHOD C_SET:subtract( oSet )
//
// oSet: instance of C_SET class: all
//       elements of oSet are removed
//       from self
//
// Returns:
//   self
////////////////////////////////////
LOCAL i,l,lNew, p

   i := 1
   l := LEN( ::aSet )
   lNew := l
   WHILE l > 0
      p = aScan( oSet:aSet, ::aSet[i] )
      IF p != 0
         aDel( ::aSet, i )
	 lNew--
      ELSE
	 i++
      ENDIF
      l--
   END
   aSize( ::aSet, lNew )

RETURN self

////////////////////////////////////
METHOD C_SET:asArray()
//
// Returns:
//   array with all set elements
////////////////////////////////////
RETURN aClone( ::aSet )

////////////////////////
METHOD C_SET:clone()
//
// Returns:
//   new C_SET instance
////////////////////////
RETURN ::new( self )

// EOF //