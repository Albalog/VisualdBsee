// XbpMenuBmpBar.prg
//
// Author : Phil Ide
// Credits:
//
// Purpose: Replacement for XbpMenuBar() class.
//          Adds icon's to text captions on menu items.
//          Doesn't care if icons not supplied.
//
// Usage  : As for XbpMenuBar().  Just add a new parameter to the
//          oSubMenu:addItem() call.
//
//          oMenuBar := oDlg:menuBar()
//
//          oSubMenu := XbpMenu():new():create()
//          oSubMenu:cargo := {}
//          oSubMenu:title := '~File'
//
//          oSubMenu:addItem( aItem , BMP_FILE_RESOURCE_ID )
//          oMenuBar:addItem( {oSubMenu, NIL} )
//
//
// Notes  : 'Icons' are actually bitmaps, not true icon files.
//          For best results, create images as 13x13 with 16 colours
//
//          Bitmaps are only added to submenu items, not mainmenu items.
//
// CLASSES:
//          XbpMenuBmp      replaces XbpMenu()
//          XbpMenuBmpBar   replaces XbpMenuBar()
//          XbpMenuBmpDialog  replaces XbpDialog()
//
////////////////////////////////////////////////////////////////////

#include "common.ch"
#include "dll.ch"

DLLFUNCTION GetMenuItemID(hMenu, nPos) USING STDCALL FROM "USER32.DLL"

DLLFUNCTION GetMenu(hWnd) USING STDCALL FROM "USER32.DLL"

DLLFUNCTION GetSubMenu(hMenu, nPos) USING STDCALL FROM "USER32.DLL"


CLASS XbpMenuBmp FROM XbpMenu
   HIDDEN:
      METHOD normaliseBmpParm

   EXPORTED:
      VAR resource

      METHOD init
      METHOD create

      METHOD addBMP
      METHOD setBMP
      METHOD getBMP
      METHOD addItem
ENDCLASS

METHOD XbpMenuBmp:init( oParent, aPresParms, lVisible )
   ::XbpMenu:init( oParent, aPresParms, lVisible )
   ::resource := {}
   return (self)

METHOD XbpMenuBmp:create( oParent, aPresParms, lVisible )
   ::XbpMenu:create( oParent, aPresParms, lVisible )
   return (self)

METHOD XbpMenuBmp:addBMP( x )
   local xBmp := ::normaliseBmpParm(x)
   aadd( ::resource, xBmp )
   return (self)

METHOD XbpMenuBmp:normaliseBmpParm(x)
   local aRet
   do case
      case Valtype(x) == 'N'
         aRet := {x, x}

      case Valtype(x) == 'A'
         x := ACLONE(x) // non modifico array originale
         while len(x) < 2
            aadd(x,NIL)
         enddo
         x[1] := iif( !valtype(x[1]) == 'N', -1, x[1] )
         x[2] := iif( !valtype(x[2]) == 'N', x[1], x[2] )
         aRet := x

      otherwise // Valtype(x) == 'U'
         aRet := {-1,-1}

   endcase
   return (aRet)

METHOD XbpMenuBmp:addItem( aItem, xBmp )
   ::XbpMenu:addItem(aItem)
   ::addBmp(xBmp)
   return (self)

METHOD XbpMenuBmp:setBmp( nPos, xBmp )
   if nPos <= len(::resource)
      xBmp := ::normaliseBmpParm(xBmp)
      ::resource[nPos] := xBmp
   endif
   return (self)

METHOD XbpMenuBmp:getBmp( nPos )
   local aRet := {-1,-1}
   if nPos <= len(::resource)
      aRet := ::resource[nPos]
   endif
   return (aRet)
         
//===============================================

CLASS XbpMenuBarBmp FROM XbpMenuBar
   EXPORTED:
      VAR imagesAdded   // BOOL : flag to say whether config completed

      METHOD init
      METHOD create

      METHOD show       // interrupt default show() to complete config
ENDCLASS

METHOD XbpMenuBarBmp:init( oParent, aPresParms, lVisible )
   ::XbpMenuBar:init( oParent, aPresParms, lVisible )
   ::imagesAdded := FALSE
   Return (self)
METHOD XbpMenuBarBmp:create( oParent, aPresParms, lVisible )
   ::XbpMenuBar:create()
   Return (self)

METHOD XbpMenuBarBmp:show()
   local hMenu
   local nMenu
   local aItems
   local hSubMenu
   local nInst
   local hWnd
   local menuID
   local nMenuCount := ::numItems()
   local ni
   local aSItem
   local lpmii
   local x

   if !::imagesAdded
      ::imagesAdded := TRUE
      hWnd := ::setParent():getHWnd()
      hMenu := GetMenu( hWnd )
      for nMenu := 1 to nMenuCount
         aItems := ::getItem(nMenu)
         IF VALTYPE(aItems) == "A" .AND. VALTYPE(aItems[1]) == "O"
            aItems := aItems[1]:resource

            if Ascan( aItems, {|a| a[1] > 0 .or. a[2] > 0 } ) > 0
     
               hSubMenu := GetSubMenu( hMenu, nMenu-1 )

               nInst := SysGetWindowLongA(hWnd)

               For ni := 1 to len(aItems)
                  aSItem := ::getItem(nMenu)

                  IF VALTYPE(aSItem) == "A" .AND. VALTYPE(aSItem[1]) == "O"
                     aSItem := aSItem[1]:getItem(ni)
                     if aSItem[1] <> NIL
                        // simone 23/3/06
                        // fix per sottomenu di sottomenu
                        IF VALTYPE(aSitem[1]) == "O"
                           aSItem[1]:setTitle(' '+aSItem[1]:getTitle())
                        ELSE
                           aSItem[1] := ' '+aSItem[1]
                        ENDIF
                        ::getItem(nMenu)[1]:setItem(ni,aSItem)
                        //::Body:Caption := ::Display
                     endif

                     if aItems[ni][1] > 0
                        menuId := GetMenuItemID(hSubMenu, ni - 1)
                        lpmii := 0
                        x = SysSetMenuItemBitmaps(hMenu, menuID, 4, SysLoadBitmapA(nInst, aItems[ni][1]), SysLoadBitmapA( nInst, aItems[ni][2]) )
                     endif    
                  ENDIF   
               Next
            endif
         endif
      next
   endif
   ::XbpMenuBar:show()
   return (self)


//
// Para llamar a ciertas API
//
Function SysGetWindowLongA( hWnd )
   Local cCall
   Local nDll
   Local nRes

   nDll := DllLoad( "USER32.DLL")
   if nDll != 0
      cCall := DllPrepareCall( nDLL, DLL_STDCALL, "GetWindowLongA")
      if len( cCall) != 0
         nRes := DLLExecuteCall( cCall, hWnd, -6)
      endif   
   endif 
Return(nRes)


//
// Para llamar a ciertas API
//
Function SysLoadBitmapA( hInstance, nResource )
   Local cCall
   Local nDll
   Local nRes
   Local ni

   nDll := DllLoad( "USER32.DLL")
   if nDll != 0
      cCall := DllPrepareCall( nDLL, DLL_STDCALL, "LoadBitmapA")
      if len( cCall) != 0
         nRes := DLLExecuteCall( cCall, hInstance, nResource)
      endif   
   endif 
Return(nRes)


//
// Para llamar a ciertas API
//
Function SysSetMenuItemBitmaps( hMenu, nPos, uFlags, BmpCheck, BmpUnCheck )
   Local cCall
   Local nDll
   Local nRes
   Local ni

   nDll := DllLoad( "USER32.DLL")
   if nDll != 0
      cCall := DllPrepareCall( nDLL, DLL_STDCALL, "SetMenuItemBitmaps")
      if len( cCall) != 0
         nRes := DLLExecuteCall( cCall, hMenu, nPos, uFlags, BmpCheck, BmpUnCheck )
      endif   
   endif 
Return(nRes)

//
// Para llamar a ciertas API
//
Function SysGetMenuItemInfoA( hMenu, uItem, fByPosition, lpmii )
   Local cCall
   Local nDll
   Local nRes
   Local ni
   Local aData := 0

   nDll := DllLoad( "USER32.DLL")
   if nDll != 0
      cCall := DllPrepareCall( nDLL, DLL_STDCALL, "GetMenuItemInfoA")
      if len( cCall) != 0
         nRes := DLLExecuteCall( cCall, hMenu, uItem, fByPosition, aData )
      endif   
   endif 
Return(nRes)

// ==============================================
CLASS XbpDialogBmpMenu FROM XbpDialog
   HIDDEN:
      VAR menuBarItem

   EXPORTED:
      METHOD init
      METHOD create
      METHOD menuBar
      METHOD show
      METHOD destroy
ENDCLASS

METHOD XbpDialogBmpMenu:init( oParent, oOwner, aPos, aSize, aPres, lVisible )
   ::XbpDialog:init( oParent, oOwner, aPos, aSize, aPres, lVisible )
   return (self)

METHOD XbpDialogBmpMenu:create( oParent, oOwner, aPos, aSize, aPres, lVisible )
   ::XbpDialog:create( oParent, oOwner, aPos, aSize, aPres, lVisible )
   return (self)

METHOD XbpDialogBmpMenu:menuBar()
   if ::menuBarItem == NIL
      ::menuBarItem := XbpMenuBarBmp():new( self ):create()
   endif
   return (::menuBarItem)

METHOD XbpDialogBmpMenu:destroy()
   ::XbpDialog:destroy()
   ::menuBarItem := NIL
   return self

METHOD XbpDialogBmpMenu:show()
   ::XbpDialog:show()
   if !(::menuBarItem == NIL)
      ::menuBarItem:show()
   endif
   return (self)


