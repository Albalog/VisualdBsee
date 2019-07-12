///////////////////////////////////////////////////////////////////////////////
//
// FILE NAME
//
//    CONTAINER.PRG
//
// AUTHOR
// 
//    Volker Spahn
//    (c) Copyright 1999, Alaska Software
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
//    XbpWinCOntainer Implementation
//
// REMARKS
//
//
// HISTORY
//
//    21.09.99 VS creation of file
//
///////////////////////////////////////////////////////////////////////////////

  /* This class is used as a tiny wrapper class which basically is
   * intended to serve as a container for win32 windows in order
   * to provide the system callbacks of the embedded windows.
   *
   * It features the XPP lifecycle and IS correctly embedded into 
   * the Xbase++ childlist hierarchy of its parent because it
   * is derived from XbpParthandler.
   *
   * However, it has only the SetSize and SetPos methods to allow
   * the position and size of the container to be changed.
   *
   */
  CLASS XbpWinContainer FROM XbpPartHandler

  PROTECTED:

     VAR    hWnd                /* our window handle */

  EXPORTED:
     CLASS METHOD InitClass     /* the initclass method */

     METHOD Init, Create        /* lifecycle */
     METHOD Destroy             /* lifecycle */
     METHOD HandleEvent         /* the event handling routine */

     METHOD GetHWND             /* inquire our window handle */

     METHOD HandleAllMsgs       /* handle all pending events for this thread */

     METHOD SetSize             /* adjust the size of the object */
     METHOD SetPos              /* adjust the position of the object */


     VAR    WinMsg              /* this callback slot receives all
                                 * events for our window */

  ENDCLASS

  /* the initclass method basically registers the window class
   * for our window class
   */
  CLASS METHOD XbpWinContainer:InitClass()

     /* register the win32 window class of my OS part */
     _winRegisterClass()

  RETURN self

  /* init the window
   */
  METHOD XbpWinContainer:Init( oParent )

     /* init the base class */
     ::XbpPartHandler:Init( oParent )

  RETURN self

  /* create the window
   */
  METHOD XbpWinContainer:Create( oParent )

     LOCAL hWnd, aSize

     /* creation of the base class, this is used to add ourself to the
      * childlist of my parent
      */
     ::XbpPartHandler:Create( oParent )

     /* we will fit into the parent's client area */
     aSize := oParent:CurrentSize()
     hWnd  := oParent:GetHWND()

     /* now create the Window which is to receive
      * the window messages
      */
     ::hWnd := _winCreateWindow( hWnd, { 0, 0 }, aSize, ;
                { | msg, mp1, mp2 | self:HandleEvent( msg, mp1, mp2 ) } )

  RETURN self

  /* destroy the window
   */
  METHOD XbpWinContainer:Destroy()

     /* destroy the window */
     _winDestroyWindow( ::hWnd )
     ::hWnd := 0

  RETURN ::XbpPartHandler:Destroy()

  /* our event handler
   *
   * This code here is the clue: the WinProc of the embedded
   * window will eval the passed codeblock for all WM_* messages
   * and this codeblock will call this method here. When we have a
   * codeblock specified in ::WinMsg then we might be able to react
   * on the message
   */
  METHOD XbpWinContainer:HandleEvent( nEvent, mp1, mp2 )

     /* call the registred codeblock on all messages, this codeblock is
      * note able to change the return value for the message, it may only
      * receive notifications. When we want to alter the default handling 
      * for the embedded message then we have to customize the class
      * by overloading the HandleEvent message  */
     IF ValType( ::WinMsg ) == "B"
        Eval( ::WinMsg, nEvent, mp1, mp2 )
     ENDIF

     /* now we have to forward the message to the default
      * window procedure 
      */
  RETURN _winDefWindowProc( ::hWnd, nEvent, mp1, mp2 )

  /* process all pending system events on the current thread for all
   * windows
   */
  METHOD XbpWinContainer:HandleAllMsgs()
  RETURN _winHandleAllEvents( 0 )

  /* resize the window
   */
  METHOD XbpWinContainer:SetSize( aSize )
  RETURN _winSetWindowSize( ::hWnd, aSize )

  /* reposition the window
   */
  METHOD XbpWinContainer:SetPos( aPos )
  RETURN _winSetWindowPos( ::hWnd, aPos )

  /* inquire window handle
   */
  METHOD XbpWinContainer:GetHWND()
  RETURN ::hWnd

  // EOF