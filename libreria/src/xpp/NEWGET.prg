//////////////////////////////////////////////////////////////////////
//
//  XBPGET.PRG
//
//  Copyright:
//      Alaska Software, (c) 1997-2003. All rights reserved.         
//  
//  Contents:
//      Sample implementation of a XbpGet class derived from XbpSle which uses
//      an overloaded textmode Get object as server for the picture and buffer
//      management.
//   
//  Remarks:
//      The mechanisms for pre- and postvalidation are implemented in the
//      XbpGetController class (XBPGETC.PRG). This assures correct validation
//      of single XbpGet objects in both modal and modeless windows.
//   
//////////////////////////////////////////////////////////////////////

#include "Appevent.ch"
#include "Common.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "Font.ch"
#include "dfStd.ch"

/*
 * InvisibleGet service class
 *
 */
CLASS InvisibleGet FROM Get
   EXPORTED:
   METHOD init
   METHOD display
   METHOD setDecPos
ENDCLASS

METHOD InvisibleGet:Init( nRow, nCol, bVarBlock, cVarName, cPicture, ;
                          cColor, bValid, bWhen )
RETURN ::Sle:Init( bVarBlock, cVarName, cPicture, bValid, bWhen )

METHOD InvisibleGet:display()
RETURN self

METHOD InvisibleGet:setDecPos(n)
  IF n != NIL
     ::get:decPos := n
  ENDIF
RETURN ::get:decPos


/*
 * XbpGet class
 */
CLASS XbpGet FROM XbpSLE


   PROTECTED:
   CLASS VAR oContextMenu SHARED  // Popup menu for XbpGet objects
   CLASS METHOD enableMenuItems

   VAR    original                // The original value before editing

   EXPORTED:
   ///////////////////////////////////////////////////
   //LUCA
   /////////// Spostata per compatibilit…
   VAR    Get                     // The embedded invisible service GET
   ///////////////////////////////////////////////////
   //Inserita per compatibilit…
   VAR setHome                   // Used by an XbpGet object
   ///////////////////////////////////////////////////

   CLASS METHOD initClass

   VAR    value                   // The current value during editing

                                  ** creation flags
   VAR    Picture                 // The picture mask
   VAR    preBlock                // Code blocks for pre- and
   VAR    postBlock               // postvalidation
   VAR    controller              // The XbpGetController object

                                  ** overloaded from XbpSle
   METHOD Init, Create            // Lifecycle
   METHOD Clear                   // Clear edit buffer 
   METHOD Keyboard                // Overloaded keyboard handling
   METHOD LbUp                    // inquire mark
   METHOD RbDown                  // focus change or context menu display
   METHOD RbUp                    // Display context menu

   METHOD CutMarked               // Methods for Copy, Delete, Insert
   METHOD PasteMarked             // operations
   METHOD DeleteMarked            //
   METHOD itemSelected            // context menu selection 

                                  ** Overloaded from DataRef
   METHOD SetData, GetData        // Overloaded SetData, GetData
   METHOD Undo                    // Overloaded Undo to Get

   METHOD SetEditBuffer           // Change edit buffer
   METHOD home                    // Set position in Get and XbpSle

                                  ** Focus change methods
   METHOD setInputFocus           // Input focus is obtained
   METHOD killInputFocus          // Input focus is lost

   METHOD preValidate             // Validation before input focus is obtained
   METHOD postValidate            // Validation before input focus is lost
   METHOD badDate                 // Overloaded Date validation

   ACCESS ASSIGN METHOD picture  

ENDCLASS


/*
 * Create the context menu for XbpGet objects
 */
CLASS METHOD XbpGet:InitClass
   ::oContextMenu := XbpMenu():new( AppDesktop() ):create()

   ::oContextMenu:title := "XbpGet Popup"
   ::oContextMenu:addItem( { "~Validate"   ,  } )
   ::oContextMenu:addItem( { "~Undo"       ,  } )
   ::oContextMenu:addItem( {NIL, NIL , XBPMENUBAR_MIS_SEPARATOR, 0} )
   ::oContextMenu:addItem( { "Cu~t"        ,  } )
   ::oContextMenu:addItem( { "~Copy"       ,  } )
   ::oContextMenu:addItem( { "~Paste"      ,  } )
   ::oContextMenu:addItem( { "~Delete"     ,  } )
   ::oContextMenu:addItem( {NIL, NIL , XBPMENUBAR_MIS_SEPARATOR, 0} )
   ::oContextMenu:addItem( { "Select ~All" ,  } )

   #define MENU_ITEM_VALIDATE   1
   #define MENU_ITEM_UNDO       2
   #define MENU_ITEM_CUT        4
   #define MENU_ITEM_COPY       5
   #define MENU_ITEM_PASTE      6
   #define MENU_ITEM_DELETE     7
   #define MENU_ITEM_SELECTALL  9

RETURN self


/*
 * Enable all applicable menu items
 */
CLASS METHOD XbpGet:enableMenuItems( oXbpGet )
   LOCAL i, imax := ::oContextMenu:numItems()
   LOCAL xTemp

   FOR i:=1 TO imax
      ::oContextMenu:enableItem(i)
   NEXT

   IF oXbpGet:postBlock == NIL
      IF oXbpGet:Get:type <> "D"
         ::oContextMenu:disableItem( MENU_ITEM_VALIDATE )
      ENDIF
   ENDIF

   IF .NOT. oXbpGet:changed
      ::oContextMenu:disableItem( MENU_ITEM_UNDO )
   ENDIF

   xTemp := oXbpGet:queryMarked()
   IF xTemp[1] == xTemp[2]
      ::oContextMenu:disableItem( MENU_ITEM_CUT    )
      ::oContextMenu:disableItem( MENU_ITEM_COPY   )
      ::oContextMenu:disableItem( MENU_ITEM_DELETE )
   ENDIF

   IF Abs( xTemp[1] - xTemp[2] ) == Len( oXbpGet:editBuffer() )
      ::oContextMenu:disableItem( MENU_ITEM_SELECTALL )
   ENDIF

   xTemp := XbpClipboard():New():Create()
   xTemp:open()
   IF xTemp:getBuffer( XBPCLPBRD_TEXT ) == NIL
      ::oContextMenu:disableItem( MENU_ITEM_PASTE )
   ENDIF
   xTemp:close()
   xTemp:destroy()
RETURN self


/*
 * Initialize the object
 */
METHOD XbpGet:Init( oParent, oOwner, aPos, aSize, aPP, lVisible ) 

   ::XbpSle:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::tabStop := .T.

RETURN self


/*
 * Create method
 */
METHOD XbpGet:Create( oParent, oOwner, aPos, aSize, aPP, lVisible ) 
   LOCAL bBlock := {|x| IIf(x==NIL, ::value, ::value := x ) }

   /*
    * ::dataLink code block must be defined already
    */
   ////////////////////////////////////////////////////////////////////
   //Spostato dopo il create:  Luca 17/01/2006 
   IF ValType( ::DataLink ) == "B"
      ::value    := ;
      ::original := Eval( ::dataLink )
   ELSE 
      ::value    := ;
      ::original := ""
   ENDIF
   //////////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////
   DEFAULT ::controller TO SELF
   DEFAULT ::setHome    TO .F.
   //////////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////
   /*
    * now initialize the text mode get object as picture server
    */
   ::Get := InvisibleGet():New(,, bBlock, "", ::picture )

   ::Get:setFocus()

   IF ::Get:buffer != NIL
     ::BufferLength := Len( ::Get:buffer )
   ELSE
     ::BufferLength := 256
   ENDIF

   ::Get:killFocus()
   ::Get:reset()

   /*
    * create the GUI SLE
    */
   ::XbpSle:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ////////////////////////////////////////////////////////////////////
   //Inserito per compatibilit… Luca 17/01/2006
   ////////////////////////////////////////////////////////////////////
   IF ! ValType( ::DataLink ) == "B"
      ::Status := XBP_STAT_FAILURE
      RETURN self
   ENDIF
   ////////////////////////////////////////////////////////////////////

RETURN self


/*
 * This method accepts data of type C,D,L,N and transfers a Picture
 * formatted string to the edit buffer of the XbpSLE.
 */

//Maudp 04/11/2010 XL 2474 In caso di selezione dalla lista di autofill,  non riportava gli eventuali spazi
//Aggiunto parametro per gestire correttamente l'autofill

//METHOD XbpGet:SetData( xData)
METHOD XbpGet:SetData( xData , lSetSpace)
   LOCAL cBuffer
   LOCAL nPCount := 0

   DEFAULT lSetSpace TO .F.

/*
   IF PCount() == 1
      ::value := xData
   ELSE
      ::value := Eval( ::dataLink )
   ENDIF
*/

//Maudp 04/11/2010 XL 2474 In caso di selezione dalla lista di autofill,  non riportava gli eventuali spazi
   nPCount := PCount()

   IF nPCount == 1 .OR. ;
     (nPCount == 2 .AND. lSetSpace)


      IF lSetSpace                     .AND. ;
         VALTYPE(xData)       == "C"   .AND. ;
         VALTYPE(::dataLink ) == "B"

         xData := PADR(xData, LEN(Eval( ::dataLink )))

      ENDIF

      ::value := xData

   ELSE
      ::value := Eval( ::dataLink )
   ENDIF

   ::original := ::value
   ::changed  := .F.
   cBuffer    := Transform ( ::value, IIf(::Get:Picture==NIL, "", ::Get:picture) )

   /*
    * update the buffer of the XbpSLE
    */
   ::SetEditBuffer( cBuffer )

   /*
    * update the buffer of the picture server Get
    */
   IF ::Get:hasFocus
      ::Get:UpdateBuffer()

      /*
       * XbpGet has focus, set the initial mark
       */
      IF Set( _SET_INSERT )
         ::SetMarked ( { ::Get:Pos, ::Get:Pos } )
      ELSE
         ::SetMarked ( { ::Get:Pos, ::Get:Pos + 1 } )
      ENDIF
   ENDIF

RETURN self


/*
 * The method returns the edited value and passes
 * it to the :dataLink code block.
 */
METHOD XbpGet:GetData( lSetOriginal )
   DEFAULT lSetOriginal TO .T.

   IF ::Get:hasFocus
      ::Get:assign()
      ::Get:pos := ::queryMarked()[1]
   ENDIF
//Maudp-LucaC 22/03/2012 Messo controllo sul DATALINK che a volte risultava a NIL
//ES.: sulla GesIntI, campo NUMCON, cliccando proprio sul primo pixel dell'immaginina
//   ::value := Eval( ::DataLink, ::value )
//Luca: Mantis 2176
   IF VALTYPE(::DataLink)=="B"
      ::value := Eval( ::DataLink, ::value )
   ENDIF

   IF lSetOriginal
      ::original := ::value
      ::changed  := .F.
   ENDIF
RETURN ::value


/*
 * Undo changes made in the edit buffer.
 */
METHOD XbpGet:Undo()
   LOCAL cBuffer

   ::value   := ::original
   ::changed := .F.

   IF ::Get:hasFocus
      ::Get:Reset()
      cBuffer := ::Get:buffer
   ELSE
      cBuffer := Transform ( ::value, IIf(::Get:Picture==NIL, "", ::Get:picture) )
   ENDIF
RETURN ::SetEditBuffer( cBuffer )


/*
 * Change the edit buffer of the XbpSle.
 */
METHOD XbpGet:SetEditBuffer( cBuffer )
   ::XbpSle:SetData( cBuffer )
RETURN self


/*
 * Clears the edit buffer.
 */
METHOD XbpGet:clear
   ::get:clear := .T.
   ::xbpSle:clear()
RETURN .T.



/*
 * Move the caret to the first editable character in the edit buffer.
 */
METHOD XbpGet:home
   LOCAL aMarked, lClear := ::get:clear

   IF ::Get:hasFocus
      ::get:home()
   ELSE
      ::Get:pos := 1
   ENDIF

   ::get:clear := lClear
   ::XbpSle:setFirstChar( ::get:pos )

   IF Set( _SET_INSERT )
      aMarked := { ::Get:Pos, ::Get:Pos }
   ELSE
      aMarked := { ::Get:Pos, ::Get:Pos + 1 }
   ENDIF

   ::SetMarked( aMarked )
RETURN self



/*
 * XbpGet obtains input focus. A prevalidation is performed by the
 * Controller object. If the prevalidation fails, the Controller object
 * sets focus to the next XbpGet.
 */
METHOD XbpGet:setInputFocus

   IF ::controller:preValidate( self )
      /*
       * The Controller object checks wether or not self
       * may obtain input focus (it calls self:preValidate()).
       */
      ::get:setFocus()
      ::xbpSLE:setInputFocus()
      ::get:buffer := ::editBuffer()

      IF ::controller:setHome
         ::home()
         ::controller:setHome := .F.
      ELSE
         ::Get:pos := ::QueryMarked()[1]
      ENDIF
   ENDIF

   ::changed := .NOT. ( ::original == ::value )
RETURN self


/*
 * XbpGet looses input focus. A postvalidation is performed by the
 * Controller object. If the postvalidation fails, the focus remains
 * with the XbpGet.
 */
METHOD XbpGet:killInputFocus

   IF ::controller:postValidate( self )
      /*
       * The Controller object checks wether or not self
       * may loose input focus (it calls self:postValidate()).
       */
      IF ::Get:hasFocus
         IF ::Get:Type == "N"
            ::Get:ToDecPos()
            ::SetEditBuffer( Trim(::Get:Buffer) )
         ENDIF
         ::Get:killFocus()
      ENDIF
      ::xbpSLE:killInputFocus()
   ELSE
      /*
       * Postvalidation failed. Mark all characters in the edit buffer.
       */
      ::home()
      ::setMarked( {1, Len(::editBuffer())+1 } )
   ENDIF

RETURN self


/*
 * Overloaded Keyboard handling. Marking is performed by the XbpSLE.
 * Cursor movement is taken from the invisible Get because it knows 
 * how to navigate in a Picture formatted string.
 */
METHOD XbpGet:Keyboard( nKey )
   LOCAL aMarked, cChar
   LOCAL lSetPos := .T., lHandled := .T.

   aMarked := ::QueryMarked()

   DO CASE
   CASE .NOT. ::get:hasFocus .AND. !EMPTY(::controller) .AND. !(::controller==SELF) .AND. !EMPTY(nKey)
        /*
         * Delegate keyboard events to the Controller object if XbpGet
         * does not have focus (this can happen after a failed validation).
         */
        ::controller:keyboard( nKey )
        RETURN self

   CASE nKey == xbeK_SH_RIGHT
        aMarked[2] := Min( aMarked[2] + 1, ::Bufferlength + 1 )

        IF .NOT. Set( _SET_INSERT ) .AND. aMarked[1]==aMarked[2]
           aMarked[1] --
           aMarked[2] := Min( aMarked[2] + 1, ::Bufferlength + 1 )
        ENDIF

        ::XbpSle:setMarked( aMarked )

        IF aMarked[2] < aMarked[1]
           /*
            * The caret is on the left side of the mark
            */
           ::Get:pos := aMarked[2]
        ELSE
           ::Get:pos := aMarked[2] - 1
        ENDIF
        lSetPos := .F.

   CASE nKey == xbeK_SH_LEFT
        aMarked[2] := Max( aMarked[2] - 1, 1 )

        IF .NOT. Set( _SET_INSERT ) .AND. aMarked[1]==aMarked[2]
           aMarked[1] ++
           aMarked[2] := Max( aMarked[2] - 1, 1 )
        ENDIF

        ::XbpSle:setMarked( aMarked )

        IF aMarked[2] < aMarked[1]
           /*
            * The caret is on the left side of the mark
            */
           ::Get:pos := aMarked[2]
        ELSE
           ::Get:pos := aMarked[2] - 1
        ENDIF
        lSetPos   := .F.

   CASE nKey == xbeK_SH_END
        IF ::Get:Type == "N"
           ::Get:ToDecPos()
           ::Get:_End()
        ENDIF

        aMarked[2] := ::Bufferlength + 1
        ::Get:Pos  := ::Bufferlength
        lSetPos    := .F.
        ::setMarked( aMarked )

   CASE nKey == xbeK_SH_HOME
        IF aMarked[2]-aMarked[1] == 1
           aMarked[1] := aMarked[2]
        ENDIF
        ::home()
        aMarked[2] := ::Get:Pos
        lSetPos    := .F.
        ::SetMarked( aMarked )
         
   CASE nKey == xbeK_CTRL_U
        ::Undo()

   CASE nKey == xbeK_CTRL_LEFT
        /*
         * In overstrike mode, the caret is on the right side of the marked
         * character. Set the caret to the left side before the XbpSLE
         * handles the key.
         */
        ::setMarked( { ::Get:pos, ::Get:pos } )
        ::XbpSle:Keyboard( nKey )
        ::Get:pos := ::querymarked()[2]

   CASE nKey == xbeK_CTRL_RIGHT
        ::XbpSle:Keyboard( nKey )
        ::Get:pos := ::querymarked()[2]

   CASE nKey == xbeK_LEFT
        IF aMarked[2] > aMarked[1]
           ::Get:Pos := Min( ::get:pos, aMarked[1] )
        ENDIF
        ::Get:Left()

   CASE nKey == xbeK_RIGHT
        IF aMarked[1] > aMarked[2]
           ::Get:Pos := Max( ::get:pos, aMarked[1] - 1 )
        ENDIF
        ::Get:Right()

        IF ::get:typeOut .AND. ::get:type <> "L"
           ::get:Pos ++
        ENDIF

   CASE nKey == xbeK_HOME
        ::Home()

   CASE nKey == xbeK_END
        IF ::Get:Type == "N"
           ::Get:ToDecPos()
        ENDIF
        ::Get:_End()

        ::XbpSle:SetFirstChar( Len( ::Get:Buffer ) )
        IF Set( _SET_INSERT)
           /*
            * We're behind the last character
            */
           ::Get:Pos ++        
        ENDIF

   CASE nKey == xbeK_INS
        Set( _SET_INSERT, ! Set( _SET_INSERT) )

   CASE nKey == xbeK_CTRL_INS
        ::CopyMarked()
        lSetPos := .F.

   CASE .NOT. ::editable .AND. !EMPTY(::controller) .AND. !(::controller==SELF) .AND. !EMPTY(nKey)
        /*
         * XbpGet is Read only. No other editing keys are processed.
         * Check if there is a navigation key pressed
         */
        lHandled := ::controller:keyboard( nKey )

   CASE nKey == xbeK_SH_INS
        ::PasteMarked()

   CASE nKey == xbeK_BS
        ::Get:BackSpace()

   CASE nKey == xbeK_DEL

        IF Set(_SET_INSERT) .AND. aMarked[1] == aMarked[2]
           aMarked[2] := aMarked[1] + 1
           ::SetMarked(aMarked)
        ENDIF
        ::DeleteMarked()

   CASE nKey == xbeK_SH_DEL
        ::CutMarked()

   CASE nKey == xbeK_CTRL_T
        ::Get:DelWordRight()

   CASE nKey == xbeK_CTRL_Y
        ::Get:DelEnd()

   CASE nKey == xbeK_CTRL_BS
        ::Get:DelWordLeft()

   CASE nKey >= 32 .AND. nKey <= 255
      cChar := Chr(nKey)

      IF ::Get:Type == "N" .AND. cChar $ ".,"
         ::Get:CondClear()
         ::Get:ToDecPos()
      ELSE
   
         IF Set(_SET_INSERT)
            IF Abs( aMarked[2]-aMarked[1]) > 0
               ::deleteMarked()
            ENDIF
            ::Get:Insert( cChar )
         ELSE
            IF Abs(aMarked[2]-aMarked[1]) > 1
               ::deleteMarked()
               ::Get:Insert( cChar )
            ELSE
               ::Get:Overstrike( cChar )
            ENDIF
         ENDIF

         IF ::Get:typeOut .AND. ::get:type <> "L"
            ::Get:pos ++
         ENDIF

      ENDIF

   OTHERWISE

     /*
      * Check if a key is pressed that navigates between XbpGets
      */
     IF !EMPTY(::controller) .AND. !(::controller==SELF) .AND. !EMPTY(nKey)
        lHandled := ::controller:keyboard( nKey )
     ENDIF 

   ENDCASE

   IF ! ::EditBuffer() == ::Get:Buffer
      IF ::Get:Type == "N"
         ::SetEditBuffer( Trim(::Get:Buffer) )
      ELSE
         ::SetEditBuffer( ::Get:Buffer )
      ENDIF

      /*
       * assign internal ::value 
       */
      ::Get:assign()
      ::changed := .NOT. ( ::original == ::value )
   ENDIF

   IF lSetPos
      IF Set( _SET_INSERT )
         aMarked := { ::Get:Pos, ::Get:Pos }
      ELSE
         aMarked := { ::Get:Pos, ::Get:Pos+1 }
      ENDIF
      ::SetMarked( aMarked )
   ENDIF

   IF ! lHandled
      RETURN ::XbpSle:Keyboard( nKey )
   ENDIF
RETURN self


/*
 * Overloaded LbUp() method. When the left mouse button is released,
 * the position of the caret must be determined.
 */
METHOD XbpGet:LbUp(mp1, mp2)
   LOCAL aMarked

   IF ::get:type == "L"
      ::XbpSle:LbUp( mp1, mp2 )
      RETURN ::home()
   ENDIF

   /*
    * Tell the server Get where the cursor is
    */
   aMarked   := ::queryMarked()
   ::Get:Pos := aMarked[1]

   IF aMarked[2] - aMarked[1] == 0 .AND. ! Set( _SET_INSERT )
      /*
       * Mark the current character when overstrike mode is active
       */
      ::SetMarked( { aMarked[1], aMarked[1]+1 } )
   ENDIF
RETURN ::XbpSle:LbUp( mp1, mp2 )


/*
 * Overloaded :rbDown() method. When the right button is pressed, an XbpGet
 * must gain input focus. This triggers the post validation for the XbpGet
 * that currently has focus.
 */
METHOD XbpGet:rbDown( mp1, mp2 )
   IF .NOT. ::hasInputFocus()
      SetAppFocus( self )
   ELSE
      ::XbpSle:rbDown( mp1, mp2 )
   ENDIF
RETURN self


/*
 * Overloaded :rbDown() method. When the right button is pressed, an XbpGet
 * must gain input focus. This triggers the post validation for the XbpGet
 * that currently has focus.
 */
METHOD XbpGet:rbUp( mp1 )
   IF ::hasInputFocus()
      ::enableMenuItems( self )
      ::oContextMenu:itemSelected := {|nItem| ::itemSelected( nItem ) }
      ::oContextMenu:popUp( self, mp1 )
   ENDIF
RETURN self


/*
 * Overloaded :cutMarked() method. Copy the marked characters to the
 * clipboard and delete them from the edit buffer.
 */
METHOD XbpGet:CutMarked()
   ::CopyMarked()
   ::DeleteMarked()
RETURN self


/*
 * Overloaded :PasteMarked() method. Insert the clipboard contents
 * into the edit buffer.
 */
METHOD XbpGet:PasteMarked()
   LOCAL aMarked := ::QueryMarked()
   LOCAL cString, oClipboard, i, nPaste, cChar
   LOCAL xRet,  nPos1, nPos2, xSub, nVal

   /*
    * Get clipboard contents
    */
   oClipboard := XbpClipboard():New():Create()
   oClipboard:open()
   cString := oClipboard:getBuffer( XBPCLPBRD_TEXT )
   oClipboard:close()
   oClipboard:destroy()

   /*
    * Do not paste when the clipboard does not contain a valid string.
    */
   IF cString == NIL
      Tone(1000)
      RETURN self
   ENDIF

   // simone 22/6/09
   // riga XL 565
   // verifico se la stringa contiene caratteri speciali??
   xRet := {}
   FOR i := 1 TO LEN(cString)
      nVal := ASC(DFCHAR(cString, i))
      IF nVal < 32 .OR. nVal > 254
         AADD(xRet, i)
      ENDIF
   NEXT

   // tolgo i caratteri speciali trovati
   FOR i := 1 TO LEN(xRet)
      cString := STUFF(cString, xRet[i]-(i-1), 1, "")
   NEXT
  
   /*
    * delete the marked string and 
    * insert the current contents of the clipboard
    */
   ::deleteMarked()
   ::Get:Pos := Min( aMarked[1], aMarked[2] )

   IF Abs(aMarked[2] - aMarked[1]) <= 1
      nPaste := Len( cString )
   ELSE
      nPaste := Min( Len( cString ), Abs(aMarked[2] - aMarked[1]) )
   ENDIF

   //////////////////////////////////////////////////////////////
   //Mantis 502
   //////////////////////////////////////////////////////////////
   IF VALTYPE(::Get:Untransform()) == "N"
      cString   := alltrim(cString)
      cString   := StrTran(cString, " ", "")
      nPos1 := AT(",",cString)
      nPos2 := AT(".",cString)
      IF nPos1>0 .AND. nPos2 >0 
         IF nPos2 > nPos1 
            //OK Š un numero standard inglese
            cString   := StrTran(cString, ",", "")
         ELSE
            // Š un numero standard italiano
            cString   := StrTran(cString, ".", "")
            cString   := StrTran(cString, ",", ".")
         ENDIF
      ELSEIF nPos2 >0 .AND. nPos1 == 0
            cString   := StrTran(cString, ".", "")
      ELSEIF nPos2==0 .AND. nPos1 >  0
            cString   := StrTran(cString, ",", ".")
      ELSE
          //Numero senza punti o virgole
      ENDIF
      nVal  := VAL(cString)
      xRet := Transform( nVal, ::Get:Picture   )
      ::Get:Buffer :=  xRet
      ::Get:Pos := aMarked[1]
   ELSE
   //////////////////////////////////////////////////////////////
      FOR i := 1 TO nPaste
         IF i <= Len( cString )
            cChar := SubStr( cString, i, 1 )
         ELSE
            cChar := " "
         ENDIF
         ::Get:Insert( cChar )
      NEXT
   ENDIF

   IF Set(_SET_INSERT) .AND. Max( aMarked[1], aMarked[2] ) + nPaste > ::bufferLength
      /*
       * Edit buffer is full. Set the Get cursor behind the last character.
       */
      ::get:pos := ::bufferLength + 1
   ENDIF
RETURN self


/*
 * Overloaded :deleteMarked() method
 */
METHOD XbpGet:DeleteMarked()
   LOCAL aMarked := ::QueryMarked()
   LOCAL nMarked := Abs( aMarked[2] - aMarked[1] )
   LOCAL i

   ////////////////////////////////////////
   //Mantis 980
   IF VALTYPE(::Get:Untransform()) == "N" 
      IF nMarked == 0 .OR. nMarked == 1 // simone 27/3/08 mantis 0000667: Migliorare la libreria e la gestione delle GET numeriche.
         ::Get:Delete()
      ELSE
         ::Get:Pos := Min( aMarked[1], aMarked[2] )
         FOR i := 1 TO nMarked
             IF !(::Get:Buffer[::Get:Pos] == ",")
               ::Get:Delete()
             ENDIF
            ::Get:Pos++
         NEXT
      ENDIF
   ////////////////////////////////////////

   ELSE

      IF nMarked == 0
         //::Get:BackSpace()
         ::Get:Delete()
         /*
          * We're in insert mode and nothing is marked -> delete nothing.
          */
      //ELSEIF nMarked == 1
      //   ::Get:Delete()
      ELSE
         ::Get:Pos := Max( aMarked[1], aMarked[2] )
         FOR i := 1 TO nMarked
               ::Get:BackSpace()
         NEXT
      ENDIF
   ENDIF

RETURN self


/*
 * Selection in context menu
 */
METHOD XbpGet:itemSelected( nItem )
   DO CASE
   CASE nItem == MENU_ITEM_VALIDATE  
      IF .NOT. ::postValidate()
         MsgBox( "Illegal data" )
         SetAppFocus( self )
      ENDIF

   CASE nItem == MENU_ITEM_UNDO      ; ::undo()
   CASE nItem == MENU_ITEM_CUT       ; ::cutMarked()
   CASE nItem == MENU_ITEM_COPY      ; ::copyMarked()
   CASE nItem == MENU_ITEM_PASTE     ; ::pasteMarked()
   CASE nItem == MENU_ITEM_DELETE    ; ::deleteMarked()
   CASE nItem == MENU_ITEM_SELECTALL ; ::setMarked( {1, Len(::editBuffer())+1 } )
   ENDCASE

   IF ! ::EditBuffer() == ::Get:Buffer
      IF ::Get:Type == "N"
         ::SetEditBuffer( Trim(::Get:Buffer) )
      ELSE
         ::SetEditBuffer( ::Get:Buffer )
      ENDIF

      /*
       * assign internal ::value 
       */
      ::Get:assign()
      ::changed := .NOT. ( ::original == ::value )
   ENDIF

RETURN self


/*
 * Picture mask is changed. Tell it to the service Get.
 */
METHOD XbpGet:picture( cPict )
   IF Valtype( cPict ) == "C"
      ::picture := cPict
      IF ::Get <> NIL
         ::Get:picture := cPict
         ::Get:reset()
      ENDIF
   ENDIF
RETURN ::picture


/*
 * Perform a postvalidation.
 */
METHOD XbpGet:postValidate
   LOCAL lValid := .T.

   IF ::badDate()
      ::undo()
      RETURN .F.
   ENDIF

   /*
    * Assign value to edited variable to assure a proper 
    * postvalidation context, but keep the original value.
    * Passing .F. assures that an :undo() is possible during
    * editing for all XbpGets contained in a dialog window, even if
    * focus changes (dialog wide :undo())
    */
   ::getData( .F. )

   IF Valtype( ::postBlock ) == "B"
      lValid := Eval( ::postBlock, self )
   ENDIF
RETURN lValid


/*
 * Perform a prevalidation.
 */
METHOD XbpGet:preValidate
   LOCAL lValid := .T.

   IF Valtype( ::preBlock ) == "B"
      lValid := Eval( ::preBlock, self )
   ENDIF
RETURN lValid


/*
 * Validate a date value.
 */
METHOD XbpGet:badDate

   IF ::Get:type <> "D"
      RETURN .F.
   ELSEIF ::Get:hasFocus
      /*
       * When an illegal date is entered
       * - Get:badDate() is .T. during editing
       * - Get:buffer is set to "  /  /  " due to :undo() in :postValidate() 
       * - After postvalidation we have ::Get:buffer <> ::editBuffer() == .T.
       */
      RETURN ::Get:badDate() .OR. ::Get:buffer <> ::editBuffer()
   ENDIF

   /*
    * An empty date is valid
    */
RETURN IIf( .NOT. (::original == ::value), Empty( ::value ), .F. )



********* DA QUI IN POI IGNORATO *****************
********* DA QUI IN POI IGNORATO *****************
********* DA QUI IN POI IGNORATO *****************
********* DA QUI IN POI IGNORATO *****************
********* DA QUI IN POI IGNORATO *****************
********* DA QUI IN POI IGNORATO *****************
#ifdef IGNORE_THIS
********* DA QUI IN POI IGNORATO *****************
********* DA QUI IN POI IGNORATO *****************
********* DA QUI IN POI IGNORATO *****************
********* DA QUI IN POI IGNORATO *****************
********* DA QUI IN POI IGNORATO *****************
********* DA QUI IN POI IGNORATO *****************




//////////////////////////////////////////////////////////////////////
//
//  XBPGET.PRG
//
//  I modified this to work with a point-of-sale application I'm writing.
//  I needed these features because my users will not be using the mouse
//  at all.  I needed it to work more like @..GET & READ.
//
//
//  Same as normal XbpGet from Alaska samples, with added features
//
//  NextObject var: Use to assign the next object to get focus
//                  if RETURN or TAB is pressed.
//
//  HotKeys var: Assign an array of hot keys to look for
//               ie {{xbeK_F1,{||Help()}},{xbeK_F2,{MSGBOX("F2 was pressed")}}}
//
//  Valid var: Codeblock to eval when TAB or RETURN is pressed.
//             It must return .T. to move to the NextObject
//
//  LastKey var:  Stores the last key pressed.
//
//  TerminatorFunction var:  Codeblock to eval upon pressing RETURN
//
//
//  Modified the Keyboard method slightly to work with new vars
//
//
//////////////////////////////////////////////////////////////////////

#include "Appevent.ch"
#include "Common.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "Font.ch"


* **********************************************************************
* InvisibleGet service class
* **********************************************************************
CLASS InvisibleGet FROM Get
   EXPORTED:
   METHOD init
   METHOD display
ENDCLASS

METHOD InvisibleGet:Init( nRow, nCol, bVarBlock, cVarName, cPicture, ;
                          cColor, bValid, bWhen )
RETURN ::Sle:Init( bVarBlock, cVarName, cPicture, bValid, bWhen )

METHOD InvisibleGet:display()
RETURN self


* **********************************************************************
* XbpGet class
* **********************************************************************
CLASS XbpGet FROM XbpSLE

   HIDDEN:

   PROTECTED:
   METHOD InitGet

   EXPORTED:
   VAR    Get                     // the embedded invisible service GET

                                  ** creation flags
   VAR    Picture                 // my picture

   VAR    NextObject              // Object to pass focus to

   VAR    Valid                   // Must return .T. to leave field

   VAR    LastKey                 // Last key pressed

   VAR	  HotKeys		  // Hot keys to look for and activate
				  //   ie {{xbeK_F1,{||Help()}},{...}}

   VAR    TerminatorFunction      // Code block to evaluate after a a RETURN
                                  //   use for an object that end a series.

                                  ** overloaded from XbpSle
   METHOD Init, Create            // Lifecycle
   METHOD Keyboard                // overloaded keyboard handling
   METHOD LbUp                    // to inquire mark

   METHOD CutMarked, PasteMarked, DeleteMarked // manipulate mark

                                  ** overloaded from DataRef
   METHOD SetData, GetData        // overloaded SetData, GetData
   METHOD Undo                    // overloaded Undo to Get

   METHOD SetEditBuffer           // change edit buffer


ENDCLASS

* **********************************************************************
* Init method
* **********************************************************************
METHOD XbpGet:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   DEFAULT aPP TO {}

   * initialisation of base class
   // AAdd( aPP, { XBP_PP_COMPOUNDNAME, FONT_DEFFIXED_SMALL } )
   ::XbpSle:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

RETURN self

* **********************************************************************
* Create method
* **********************************************************************
METHOD XbpGet:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   * create the SLE and disable keyboard handling
   ::XbpSle:autoKeyboard := .F.
   ::XbpSle:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   * now the datalink must have been specified
   IF ! ValType( ::DataLink ) == "B"
      ::Status := XBP_STAT_FAILURE
      RETURN self
   ENDIF
   ::initGet()

RETURN self

METHOD XbpGet:InitGet()
   * now initialize the get object
   ::Get := InvisibleGet():New(,, ::Datalink, "", ::Picture )
   // ::Get:SetFocus()
   ::BufferLength := Len( ::Get:buffer )
   // IF ::Get:Type == "N"
   //    ::Align := XBPSLE_RIGHT                  // not supported on WIN32
   // ENDIF

RETURN self


* **********************************************************************
* Overloaded SetData()
*
* This method should not behave like the normal XbpSle:SetData() method
* which needs strings. This method will rather call the codeblock and
* use its return value and convert this value to the given datatype.
* **********************************************************************
METHOD XbpGet:SetData( xData )

   * call updatebuffer on GET, this will call the datalink and set
   * the :Get:buffer value
   IF !Empty( xData )
      ::Get:Buffer := Transform ( xData, ::Get:Picture )
   ELSE
      ::Get:UpdateBuffer()
   ENDIF

   * now set the data in the SLE class
   ::SetEditBuffer( ::Get:Buffer )

   * now set the initial mark
   IF Set( _SET_INSERT )
      ::SetMarked ( { ::Get:Pos, ::Get:Pos } )
   ELSE
      ::SetMarked ( { ::Get:Pos, ::Get:Pos + 1 } )
   ENDIF

RETURN self

* **********************************************************************
* Overloaded GetData()
*
* Return untransformed contents of the GET buffer
* **********************************************************************

METHOD XbpGet:GetData()

   LOCAL xValue := ::Get:Untransform()

   // Workaround per problema su untransform(), e STR()
   IF VALTYPE(xValue) == "N"
      xValue := VAL( IIF(xValue==INT(xValue), STR(xValue, 30, 0), STR(xValue, 45, 10)) )
   ENDIF

   * store value to datalink
   Eval( ::DataLink, xValue )

RETURN xValue

* **********************************************************************
* Overloaded Undo()
* **********************************************************************
METHOD XbpGet:Undo()

   ::Get:Undo()
   ::Get:Buffer := Transform( ::Get:Original, ::Get:Picture )

RETURN ::SetEditBuffer( ::Get:buffer )

* **********************************************************************
* Change the edit buffer of the XbpSle.
* **********************************************************************
METHOD XbpGet:SetEditBuffer( cBuffer )

   ::XbpSle:SetData( cBuffer )

RETURN self

* **********************************************************************
* Overloaded Keyboard handling
* **********************************************************************
METHOD XbpGet:Keyboard( nKey )
   LOCAL aMarked, cChar, lHandled := .T.
   LOCAL setPos    := .T.

   aMarked := ::QueryMarked()
   ::LastKey := nKey

   IF ::HotKeys != NIL
     AEVAL(::HotKeys,{|x|IF(x[1]==nKey,EVAL(x[2]),NIL)})
   ENDIF

   DO CASE

   CASE nKey == xbeK_RETURN
     IF (::Valid == NIL)
       IF ::TerminatorFunction != NIL
         EVAL(::TerminatorFunction,self)
       ELSE
         IF ::NextObject != NIL
           SetAppFocus(::NextObject)
         ENDIF
       ENDIF
     ELSE
       IF EVAL(::Valid,self)
         IF ::TerminatorFunction != NIL
           EVAL(::TerminatorFunction,self)
         ELSE
           IF ::NextObject != NIL
             SetAppFocus(::NextObject)
           ENDIF
         ENDIF
       ENDIF
     ENDIF


   CASE nKey == xbeK_TAB
     IF (::Valid == NIL)
       IF ::NextObject != NIL
         SetAppFocus(::NextObject)
       ELSE
         lHandled := .F.
       ENDIF
     ELSE
       IF EVAL(::Valid,self)
         IF ::NextObject != NIL
           SetAppFocus(::NextObject)
         ELSE
            lHandled := .F.
         ENDIF
       ENDIF
     ENDIF

   CASE nKey == xbeK_SH_RIGHT
        ::Get:Pos ++
        aMarked[2] := ::Get:Pos
        ::SetMarked( aMarked )
        setPos := .F.

   CASE nKey == xbeK_SH_LEFT
        ::Get:Pos --
        aMarked[1] := ::Get:Pos
        ::SetMarked( aMarked )
        setPos := .F.

   CASE nKey == xbeK_SH_END
        aMarked[2] := ::Bufferlength + 1
        ::Get:Pos  := ::Bufferlength
        ::SetMarked( aMarked )
        setPos := .F.

   CASE nKey == xbeK_SH_HOME
        ::Get:Pos  := 1
        aMarked[1] := 1
        ::SetMarked( aMarked )
        setPos := .F.

   CASE nKey == xbeK_CTRL_U
        ::Undo()

   CASE nKey == xbeK_RIGHT
        ::Get:Right()

   CASE nKey == xbeK_CTRL_RIGHT
        ::Get:WordRight()

   CASE nKey == xbeK_LEFT
        ::Get:Left()

   CASE nKey == xbeK_CTRL_LEFT
        ::Get:WordLeft()

   CASE nKey == xbeK_HOME
        ::Get:Home()
        ::SetFirstChar( 1 )

   CASE nKey == xbeK_END
        ::Get:_End()

   CASE nKey == xbeK_INS
        Set( _SET_INSERT, ! Set( _SET_INSERT) )

   CASE nKey == xbeK_SH_INS
        IF ::editable
           ::PasteMarked()
        ENDIF

   CASE nKey == xbeK_CTRL_INS
        ::CopyMarked()

   CASE nKey == xbeK_BS
        IF ::editable
           ::Get:BackSpace()
        ENDIF

   CASE nKey == xbeK_DEL
        IF ::editable
           ::DeleteMarked()
        ENDIF

   CASE nKey == xbeK_SH_DEL
        IF ::editable
           ::CutMarked()
        ENDIF

   CASE nKey == xbeK_CTRL_T
        IF ::editable
           ::Get:DelWordRight()
        ENDIF

   CASE nKey == xbeK_CTRL_Y
        IF ::editable
           ::Get:DelEnd()
        ENDIF

   CASE nKey == xbeK_CTRL_BS
        IF ::editable
           ::Get:DelWordLeft()
        ENDIF

   CASE nKey >= 32 .AND. nKey <= 255
      cChar := Chr(nKey)

      IF ::Get:Type == "N" .AND. cChar $ ".,"
         ::Get:ToDecPos()
      ELSE

         IF ::editable
            IF Set(_SET_INSERT)
               ::Get:Insert( cChar )
            ELSE
               ::Get:Overstrike( cChar )
            ENDIF
         ENDIF

      ENDIF

   OTHERWISE
     lHandled := .F.

   ENDCASE

   IF ! ::EditBuffer() == ::Get:Buffer
      ::SetEditBuffer( ::Get:Buffer )
   ENDIF

   IF setPos
      IF Set( _SET_INSERT )
         aMarked := { ::Get:Pos, ::Get:Pos }
      ELSE
         aMarked := { ::Get:Pos, ::Get:Pos + 1 }
      ENDIF
   ENDIF
   ::SetMarked( aMarked )

   IF ! lHandled
      RETURN ::XbpSle:Keyboard( nKey )
   ENDIF

RETURN self

* **********************************************************************
* Overloaded LbUp
* **********************************************************************
METHOD XbpGet:LbUp(mp1, mp2)

   LOCAL aMarked := ::queryMarked()
   // Avvolte con le get numeriche si ha il problema di avere ::Get a NIL inizzialmente
   IF ::Get == NIL 
      RETURN ::XbpSle:LbUp( mp1, mp2 )
   ENDIF
   * now locate Get on the specified position
   ::Get:Pos := aMarked[1]

   * now set the mark when insert mode is not active
   IF aMarked[2] - aMarked[1] == 0 .AND. ! Set( _SET_INSERT )
      ::SetMarked( { aMarked[1], aMarked[1]+1 } )
   ENDIF

RETURN ::XbpSle:LbUp( mp1, mp2 )

* **********************************************************************
* Overloaded CutMarked()
* **********************************************************************
METHOD XbpGet:CutMarked()

   ::CopyMarked()
   ::DeleteMarked()

RETURN self

* **********************************************************************
* Overloaded PasteMarked()
* **********************************************************************
METHOD XbpGet:PasteMarked()
   LOCAL xRet,  nPos1, nPos2, xSub, nVal
   LOCAL aMarked := ::QueryMarked()
   LOCAL cString, oClipboard, i, nPaste

   * get string from clipboard
   oClipboard := XbpClipboard():New():Create()
   oClipboard:Open()
   cString := oClipboard:GetBuffer( XBPCLPBRD_TEXT )
   oClipboard:Close()

   * paste an empty string into the edit buffer when the clipboard
   * does not contain a valid string
   IF cString == NIL
      cString := ""
   ENDIF

   * clear the selected string and insert the current contents of the
   * clipboard

//              Ken Levitt 1/18/99 Bug fix.
//  PasteMarked did not work at all correctly in TYPEOVER mode
//  If only mark is due to typeover mode, it is not proper to delete the
//  marked area.  If more than one char is marked, only the marked area
//  should be deleted.  This was not the case in the old code.
   IF ! Set(_SET_INSERT)  .AND.  aMarked[1] = aMarked[2]-1
//                        only mark is due to cursor mark
      aMarked[2] := aMarked[1]
      ::SetMarked(aMarked)
   ELSE
      ::DeleteMarked()              // delete the marked area
   ENDIF


   //Mantis 502
   IF VALTYPE(::Get:Untransform()) == "N"
      cString   := alltrim(cString)
      cString   := StrTran(cString, " ", "")
      nPos1 := AT(",",cString)
      nPos2 := AT(".",cString)
      IF nPos1>0 .AND. nPos2 >0 
         IF nPos2 > nPos1 
            //OK Š un numero standard inglese
            cString   := StrTran(cString, ",", "")
         ELSE
            // Š un numero standard italiano
            cString   := StrTran(cString, ".", "")
            cString   := StrTran(cString, ",", ".")
         ENDIF
      ELSEIF nPos2 >0 .AND. nPos1 == 0
            cString   := StrTran(cString, ".", "")
      ELSEIF nPos2==0 .AND. nPos1 >  0
            cString   := StrTran(cString, ",", ".")
      ELSE
          //Numero senza punti o virgole
      ENDIF
      nVal  := VAL(cString)
      xRet := Transform( nVal, ::Get:Picture   )
      ::Get:Buffer :=  xRet
      ::Get:Pos := aMarked[1]
   ELSE
      //come era prima:
        //              Ken Levitt 1/18/99 Bug fix.
        //  PasteMarked did not work at all correctly in TYPEOVER mode
        //  If only mark is due to typeover mode, it is not proper to delete the
        //  marked area.  If more than one char is marked, only the marked area
        //  should be deleted.  This was not the case in the old code.
      ::Get:Pos := aMarked[1]
      FOR i=1 TO Len(cString)
        ::Get:Insert( SubStr( cString, i, 1 ) )
      NEXT
   ENDIF

RETURN self

* **********************************************************************
* Overloaded DeleteMarked()
* **********************************************************************
METHOD XbpGet:DeleteMarked()

   LOCAL aMarked := ::QueryMarked()
   LOCAL i

   IF aMarked[1] == aMarked[2]
      ::Get:Delete()
   ELSEIF aMarked[1] > aMarked[2]
      ::Get:Pos := aMarked[1]
      FOR i := 1 TO ABS(aMarked[2] - aMarked[1])
         ::Get:BackSpace()
      NEXT
   ELSE
      ::Get:Pos := aMarked[2]
      FOR i := 1 TO ABS(aMarked[2] - aMarked[1])
         ::Get:BackSpace()
      NEXT
   ENDIF


RETURN self

********* FINO A QUI IGNORATO *****************
********* FINO A QUI IGNORATO *****************
********* FINO A QUI IGNORATO *****************
#endif