//////////////////////////////////////////////////////////////////////
//
//  DBSUBSET.PRG
//
//  Copyright:
//      Alaska Software GmbH, (c) 1999-2000. All rights reserved.         
//  
//  Contents:
//      The DbSubset class.
//   
//////////////////////////////////////////////////////////////////////

#include "Dmlb.ch"

CLASS DbSubset FROM Thread
   PROTECTED:
   VAR cDbfFile, cIndexFile
   VAR aRecno  , nRecno, nLastRec
   VAR oSignal , nPrepare

   METHOD atStart, execute, atEnd      // server-side methods
   
   VAR bof
   METHOD _Gotorec()
  
   EXPORTED:
   VAR    alias, area
   VAR    subsetBlock
                                       // client-side methods:
   METHOD init, prepare, finish, clear // for subset creation

   METHOD bof , eof , recno, lastRec   // for dbf state and
   METHOD skip, goto, goTop, goBottom  // record navigation 
ENDCLASS


/*
 * Client-side methods for subset creation
 */
METHOD DbSubset:init( bSubset )
   ::thread:init()
   ::subsetBlock := bSubset
   ::nRecno      := 0
   ::nLastRec    := 0
   ::oSignal     := Signal():new()
   ::bof := .F.

RETURN self


METHOD DbSubset:prepare( nFirstSubset )
   IF Valtype( nFirstSubset ) <> "N"
      nFirstSubset := 25
   ENDIF

   ::alias      := Alias()
   ::area       := Select()

   ::nPrepare   := nFirstSubset
   ::cDbfFile   := DbInfo( DBO_FILENAME )
   ::cIndexFile := OrdbagName_xpp( OrdNumber() )
   ::aRecno     := Array( ::nPrepare )

   ::start()
   ::oSignal:wait()

   ::goTop()
RETURN self


METHOD DbSubset:finish
   ::oSignal:signal()
RETURN self


METHOD DbSubset:clear
   ::aRecno     := {}
   ::nRecno     := 0
   ::nLastRec   := 0
RETURN self

/*
 * Methods for server-side work area
 */
METHOD DbSubset:atStart
   DbSelectArea( ::area )
   USE (::cDbfFile) ALIAS (::alias) SHARED
   IF .NOT. Empty( ::cIndexFile )
      SET INDEX TO (::cIndexFile)
   ENDIF
RETURN self


METHOD DbSubset:atEnd
   DbCloseAll()
RETURN self


METHOD DbSubset:execute
   LOCAL nStep  := 500
   LOCAL nMax   := Len( ::aRecno )
   LOCAL nCount 

   DbLocate( ::subsetBlock )
   ::nLastRec := 0
   nCount     := 0

   DO WHILE Found()
      IF ++ nCount > nMax
         ASize( ::aRecno, nMax += nStep )
      ENDIF
      ::aRecno[ nCount ] := Recno()

      // This may only be incremented after the Recno() assignment.
      // Otherwise, the class is not thread safe due to
      //    DbGoto( ::aRecno[ ::nRecno ] ) in the :goto() method
      ::nLastRec ++
      DbContinue()

      IF ::nLastrec == ::nPrepare
         ::oSignal:signal()
         ::oSignal:wait(500)
      ENDIF
   ENDDO

   ASize( ::aRecno, ::nLastRec )
   ::oSignal:signal()
RETURN self


/*
 * State and navigation methods for client-side work area
 */
METHOD DbSubset:bof
RETURN ::bof .OR. ::nLastRec == 0 //::nRecno < 1


METHOD DbSubset:eof
RETURN ::nLastRec == 0 .OR. ::nRecno > ::nLastRec


METHOD DbSubset:recno
RETURN ::nRecno


METHOD DbSubset:lastRec
RETURN ::nLastRec


METHOD DbSubset:gotop
   IF ::nLastRec == 0
      ::nRecno := 0
   ELSE
      ::nRecno := 1
   ENDIF
RETURN ::skip(0) //::goto( 1 )


METHOD DbSubset:goBottom
RETURN ::goto( ::nLastRec )


METHOD DbSubset:skip( nSkip )
   LOCAL nPrev := ::recno()

   IF Valtype( nSkip ) <> "N"
      nSkip := 1
   ENDIF

   nSkip := ::goto(::nRecno + nSkip)
   // sono su eof 
   IF ::eof()
      ::goBottom()
      nSkip := ::recno() - nPrev
   ENDIF
RETURN nSkip


METHOD DbSubset:goto( nRecno )
   LOCAL nPrev
   nPrev := ::nRecno

   ::bof := .F.

   ::nRecno := nRecno

   IF ::nRecno < 1
      ::goTop()
      ::bof := .T.

   ELSEIF ::nRecno > ::nLastRec
      ::nRecno := ::nLastRec + 1
   ENDIF

   IF ::nRecno == 0 .OR. ::eof()
      DBGOBOTTOM()
      DBSKIP()
   ELSE
      ::_Gotorec()
   ENDIF
      
RETURN ::nRecno - nPrev

METHOD DbSubset:_Gotorec()
   DBGOTO_XPP(::aRecno[::nRecno])
RETURN
