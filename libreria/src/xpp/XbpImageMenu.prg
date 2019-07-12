//////////////////////////////////////////////////////////////////////
//
//  MENUS.PRG
//
//  Copyright:
//   Alaska Software, (c) 1997-2005. All rights reserved.         
//  
//  Contents:
//   This source contains the maintenance code of the owner-drawn menu
//   system of the OWNERDRW sample application.
//    
//////////////////////////////////////////////////////////////////////
#include "font.ch"
#include "xbp.ch"
#include "gra.ch"
#include "appevent.ch"

#if XPPVER < 01900000
CLASS XbpDialogImageMenu FROM XbpDialog
ENDCLASS

#else

// Defines for the spacing between the individual
// elements that make up a menue entry
#define ITEM_SPACING        5
#define IMAGE_BOX           16

// Background color for the popup menu
#define MENU_BGCOLOR        GraMakeRGBColor( {245,245,255} )

// ==============================================
CLASS XbpDialogImageMenu FROM XbpDialog
   HIDDEN:
      VAR menuBarItem

   EXPORTED:
      METHOD init
      METHOD create
      METHOD menuBar
      METHOD show
      METHOD destroy
ENDCLASS

METHOD XbpDialogImageMenu:init( oParent, oOwner, aPos, aSize, aPres, lVisible )
   ::XbpDialog:init( oParent, oOwner, aPos, aSize, aPres, lVisible )
   return (self)

METHOD XbpDialogImageMenu:create( oParent, oOwner, aPos, aSize, aPres, lVisible )
   ::XbpDialog:create( oParent, oOwner, aPos, aSize, aPres, lVisible )
   return (self)

METHOD XbpDialogImageMenu:menuBar()
   if ::menuBarItem == NIL
      ::menuBarItem := XbpMenuBarImage():new( self ):create()
   endif
   return (::menuBarItem)

METHOD XbpDialogImageMenu:destroy()
   ::XbpDialog:destroy()
   ::menuBarItem := NIL
   return self

METHOD XbpDialogImageMenu:show()
   ::XbpDialog:show()
   if !(::menuBarItem == NIL)
      ::menuBarItem:show()
   endif
   return (self)


// ==============================================
CLASS XbpMenuBarImage FROM XbpMenuBar
   EXPORTED:
      METHOD Init()
      METHOD addItem()
ENDCLASS

METHOD XbpMenuBarImage:init( oParent, aPresParms, lVisible )
   LOCAL oDlg := oParent
   ::XbpMenuBar:init( oParent, aPresParms, lVisible )
   ::measureItem := {|nItem,aDims,self| MeasureMenubarItem(oDlg,self,nItem,aDims) }
   ::drawItem    := {|oPS,aInfo,self  | DrawMenubarItem(oDlg,self,oPS,aInfo) }
   Return (self)

METHOD XbpMenuBarImage:addItem( aItem )
   aItem := ACLONE(aItem)
   IF LEN(aItem) < 4
      ASIZE(aItem, 4)
   ENDIF
   IF EMPTY(aItem[4])
      aItem[4] := XBPMENUBAR_MIA_OWNERDRAW
   ELSE
      aItem[4] += XBPMENUBAR_MIA_OWNERDRAW
   ENDIF
   Return ::XbpMenuBar:addItem(aItem)

// ==============================================

//
// Declaration of a class derived from XbpMenu.
// Among other things, the class introduces an enhanced 
// :AddItem() method that supports defining images
// for menu items. Furthermore, the class introduces 
// overloaded versions of methods :MeasureItem() and 
// :DrawItem()
//
CLASS XbpImageMenu FROM XbpMenu
  PROTECTED:
    // Internal array of images defined for 
    // the menu's items 
    VAR    ItemImages

    // Width computed for menu's items, see
    // :MeasureItem()
    VAR    ItemWidth

    // Width and height of the font used
    // for caption text, as well as for the
    // text rendered at the left of a popup
    // menu
    VAR    FontWidth
    VAR    FontHeight

    VAR    BarFont
    VAR    BarWidth

  EXPORTED:
    // Text rendered at the left of a popup
    // menu
    VAR    BarText

    METHOD Init()
    METHOD Create()
    METHOD Destroy()

    METHOD MeasureItem()
    METHOD DrawItem()
    METHOD AddItem()

ENDCLASS


//
// Overloaded :Init() method. It initializes the
// instance of the XbpImageMenu class
//
METHOD XbpImageMenu:Init( oParent, aPP, lVisible )

   ::ItemImages := {}

   ::ItemWidth  := 0

   ::BarWidth   := 0
   ::BarText    := ""

   ::FontWidth  := 0
   ::FontHeight := 0

RETURN ::XbpMenu:Init(oParent,aPP,lVisible)


//
// Overloaded :Create() method. It allocates
// system resources used by the object.
//
METHOD XbpImageMenu:Create( oParent, aPP, lVisible )

 LOCAL oPS
 LOCAL oFnt
 LOCAL aBox

   // Create font used for rendering text at
   // the left-hand side
   oPS := AppDesktop():lockPS()

   // Determine width and height of the
   // font used for rendering caption
   // text
   oFnt := GraSetFont( oPS )
   ::FontWidth  := oFnt:width
   ::FontHeight := oFnt:height

   IF Len(::BarText) > 0
      ::BarFont := XbpFont():new( oPS )
      ::BarFont:create( "12.Arial Bold" )
      ::BarWidth := ::BarFont:height

      // Compute default width for a menu.
      // This is used in case the first menu 
      // item is a separator item.
      aBox := GraQueryTextBox( oPS, ::BarText )
      ::ItemWidth := ::BarWidth + (aBox[3][1] - aBox[2][1]) + ;
                     ::FontWidth *8 + ITEM_SPACING *3
   ENDIF

   AppDesktop():unlockPS()

RETURN ::XbpMenu:Create(oParent,aPP,lVisible)


//
// Overloaded :Destroy() method. It frees resources
// allocate by :Create() and at run time.
//
METHOD XbpImageMenu:Destroy()

   IF ::BarFont != NIL
      ::BarFont:Destroy()
      ::BarFont := NIL
   ENDIF

   AEval( ::ItemImages, {|x| IIF( x != NIL, x:Destroy(),)} )
   ::ItemImages := {}

RETURN ::XbpMenu:Destroy()

//
// Overloaded :Init() method. It supports
// passing in images.
//
METHOD XbpImageMenu:AddItem( aItem, nResId )

 LOCAL oBmp
 LOCAL xImage


   IF ValType(nResId) == "N"
      oBmp := XbpBitmap():new():create()
      oBmp:load( , nResId )

      IF oBmp:xSize > 0
         oBmp:transparentClr := oBmp:getDefaultBGColor()
         xImage := oBmp
      ELSE
         oBmp:Destroy()
      ENDIF
   ENDIF

   AAdd( ::ItemImages, xImage )          

RETURN ::XbpMenu:AddItem( aItem )


//
// Overloaded :MeasureItem() method for computing
// the dimensions of the menu entries. The method
// uses GraQueryTextBox() to compute the textbox
// required for rendering the menu caption and
// adds the space required for drawing the bar
// at the left-hand side.
//
METHOD XbpImageMenu:MeasureItem( nItem, aDims )

 LOCAL oPS
 LOCAL oFnt
 LOCAL aBox
 LOCAL aItem := ::getItem( nItem )
 LOCAL cTmp
 LOCAL cStr
 LOCAL nType

   // Check whether the menu item is a separator
   // item. In this case, this method returns
   // the item width previously computed and
   // uses a constant value as the item's height.
   // Separator items are displayed using a
   // line.
   IF aItem[3] != NIL .AND. BAnd(aItem[3], XBPMENUBAR_MIS_SEPARATOR) != 0
      aDims[1] := ::ItemWidth
      aDims[2] := ITEM_SPACING

      RETURN self
   ENDIF

   // Check whether a caption was defined for
   // the menu item. If not, the item width
   // computed previously is used. The height
   // is determined based on the height of the
   // font.
   nType := ValType( aItem[1] )
   IF nType == "C"
      cStr := aItem[1]
   ELSEIf nType == "O"
      cStr := aItem[1]:title
   ENDIF

   IF cStr == NIL
      aDims[1] := ::BarWidth   + ::ItemWidth + ITEM_SPACING *4 + ::FontWidth *8
      aDims[2] := ::FontHeight + ITEM_SPACING *2

      AppDesktop():unlockPS()
      RETURN self
   ENDIF
   
   // Compute the dimensions of a menu item that
   // has a caption string. The item's width is
   // derived from the textbox required for
   // rendering the caption string. Note that
   // menu shortcuts require special processing,
   // as these are displayed right-aligned.
   // The height of the entry is computed based
   // on the height of the font.
   oPS  := AppDesktop():lockPS()

   cTmp := StrTran( cStr, "~" )
   cTmp := StrTran( cTmp, Chr(9) )
   aBox := GraQueryTextBox( oPS, cTmp )
   
   AppDesktop():unlockPS()

   aDims[1] := ::BarWidth + (aBox[3][1] - aBox[2][1]) + ;
               ::FontWidth *8 + ITEM_SPACING *4
   aDims[2] := ::FontHeight   + ITEM_SPACING *2

   // Store item width computed, if the item
   // is wider than those computed before.
   // The item width stored is used for items
   // not displaying a caption or for 
   // separator items
   IF aDims[1] > ::ItemWidth
      ::ItemWidth := aDims[1]
   ENDIF

RETURN self


//
// Overloaded :DrawItem() method. This method
// does the actual rendering of the individual
// menu items with respect to their respective
// states.
//
METHOD XbpImageMenu:DrawItem( oPS, aInfo )

 LOCAL cStr
 LOCAL cSCut
 LOCAL aItem
 LOCAL nY
 LOCAL aAAttrs := Array( GRA_AA_COUNT )
 LOCAL aLAttrs
 LOCAL aSAttrs := Array( GRA_AS_COUNT )
 LOCAL nFill
 LOCAL nTmp
 LOCAL oOldFnt
 LOCAL oBmp
 LOCAL aOldAttrs
 LOCAL nType
       // Rectangle for rendering caption text. The rectangle is aligned 
       // to the right of the item's image and the bar displayed at the 
       // menu's left-hand side
 LOCAL aTxtBox := {aInfo[4][1] + ::BarWidth + ITEM_SPACING*3 + IMAGE_BOX,aInfo[4][2],;
                   aInfo[4][3] - ITEM_SPACING,aInfo[4][4] -1}
       // Rectangle for rendering an item's background. The background
       // rectangle encompasses both the caption and the item's image,
       // if defined. It is used for rendering selected menu items,
       // for example.
 LOCAL aItemBG := {aInfo[4][1] + ::BarWidth + ITEM_SPACING,aInfo[4][2],;
                   aInfo[4][3] - ITEM_SPACING,aInfo[4][4] -1}

   // If the first item is about to be rendered, clear
   // the background of the menu with a custom background
   // color. Also, output the bar displayed at the 
   // left-hand side. Note that the background is drawn
   // only when the whole menu is redrawn. Otherwise, 
   // unecessary flicker would result.

   IF BAND(aInfo[2], XBP_DRAWACTION_DRAWALL) != 0 .AND.;
      aInfo[1] == 1
      aAAttrs[GRA_AA_COLOR] := MENU_BGCOLOR
      GraSetAttrArea( oPS, aAAttrs )
      GraBox( oPS, {0,0}, oPS:SetPageSize()[1], GRA_FILL )

      aAAttrs[GRA_AA_COLOR] := GraMakeRGBColor( {200,200,255} )
      GraSetAttrArea( oPS, aAAttrs )
      GraBox( oPS, {0,0}, {::BarWidth, oPS:setPageSize()[1][2]}, GRA_FILL )

      aSAttrs[GRA_AS_COLOR] := MENU_BGCOLOR
      aSAttrs[GRA_AS_ANGLE] := {0,10}
      aSAttrs[GRA_AS_VERTALIGN] := GRA_VALIGN_TOP

      IF Len(::BarText) > 0
         oOldFnt   := GraSetFont( oPS, ::BarFont )
         aOldAttrs := GraSetAttrString( oPS, aSAttrs )

         GraStringAt( oPS, {0,ITEM_SPACING}, ::BarText )

         GraSetAttrString( oPS, aOldAttrs )
         GraSetFont( oPS, oOldFnt )
      ENDIF

      aInfo[2] := BOr( aInfo[2], XBP_DRAWACTION_SELCHANGE )
   ENDIF

   // Display the image associated with the item,
   // if any. The image is positioned to the
   // right of the bar displayed at the left-hand
   // side of the menu, aligned vertically within
   // the item rectangle.
   oBmp := ::ItemImages[aInfo[1]]
   IF oBmp != NIL
      nY := ((aInfo[4][4] - 1 - aInfo[4][2]) - oBmp:ySize) /2 
      nY += aInfo[4][2]
      oBmp:draw( oPS, {aInfo[4][1] + ::BarWidth + ITEM_SPACING *2,nY} )
   ENDIF

   // Render the background of a menu item whose
   // selection state has changed. Selected items 
   // are displayed using a special background color 
   // and their display rectangles are framed. If 
   // an image is associated with the item, it is 
   // also framed. If the item has been unselected,
   // the whole item rectangle is cleared.
   IF BAnd(aInfo[2], XBP_DRAWACTION_SELCHANGE) != 0
      IF BAnd(aInfo[3], XBP_DRAWSTATE_SELECTED) != 0
         aLAttrs := Array( GRA_AL_COUNT )
         aLAttrs[GRA_AL_COLOR] := GraMakeRGBColor( {124,124,255} )
         GraSetAttrLine( oPS, aLAttrs )

         IF oBmp != NIL
            GraBox( oPS, {aItemBG[1],aItemBG[2]}, ;
                         {aItemBG[1]+IMAGE_BOX + ITEM_SPACING *2,;
                          aItemBG[4]}, GRA_OUTLINE )

            aItemBG[1] += IMAGE_BOX + ITEM_SPACING *2
         ENDIF

         aAAttrs[GRA_AA_COLOR] := GraMakeRGBColor( {200,200,255} )
         nFill := GRA_OUTLINEFILL
      ELSE
         IF oBmp != NIL
            aLAttrs := Array( GRA_AL_COUNT )
            aLAttrs[GRA_AL_COLOR] := MENU_BGCOLOR
            GraSetAttrLine( oPS, aLAttrs )
            GraBox( oPS, {aItemBG[1],aItemBG[2]}, ;
                         {aItemBG[1]+IMAGE_BOX + ITEM_SPACING *2,;
                          aItemBG[4]}, GRA_OUTLINE )

            aItemBG[1] += IMAGE_BOX + ITEM_SPACING *2
         ENDIF

         aAAttrs[GRA_AA_COLOR] := MENU_BGCOLOR
         nFill := GRA_FILL
      ENDIF


      GraSetAttrArea( oPS, aAAttrs )
      GraBox( oPS, {aItemBG[1],aItemBG[2]}, {aItemBG[3],aItemBG[4]}, nFill )
   ENDIF
   
   // Render menu item's caption. For separator
   // items, a line is output. For menu items
   // with a caption string assigned, the string
   // is processed first to determine whether
   // it contains the definition of a menu shortcut.
   // The actual caption is rendered left-aligned,
   // whole the shortcut is aligned with the
   // item's right-hand border.
   aItem := ::getItem( aInfo[1] )
   nType := ValType( aItem[1] )
   IF nType == "C"
      cStr := aItem[1]
   ELSEIf nType == "O"
      cStr := aItem[1]:title
   ENDIF

   IF cStr != NIL
      nTmp := At( Chr(9), cStr )
      IF nTmp > 0
         cSCut := SubStr( cStr, nTmp +1 )
         cStr  := SubStr( cStr, 1, nTmp -1 )

         aSAttrs[GRA_AS_COLOR] := XBPSYSCLR_WINDOWTEXT
         aSAttrs[GRA_AS_HORIZALIGN] := GRA_HALIGN_RIGHT
         aSAttrs[GRA_AS_VERTALIGN]  := GRA_VALIGN_HALF
         aSAttrs[GRA_AS_ANGLE] := {1,0}
         aOldAttrs := GraSetAttrString( oPS, aSAttrs )
         nY := aTxtBox[2] + (aTxtBox[4] - aTxtBox[2]) /2 
         GraStringAt( oPS, {aTxtBox[3] - ITEM_SPACING,nY}, cSCut )
         aOldAttrs := GraSetAttrString( oPS, aOldAttrs )
         GraSetAttrString( oPS, aOldAttrs )
      ENDIF

      oPS:DrawCaptionStr( {aTxtBox[1] + ITEM_SPACING,aTxtBox[2]}, ;
                          {aTxtBox[3],aTxtBox[4]}, cStr )
   ELSE
      aLAttrs := Array( GRA_AL_COUNT )
      aLAttrs[GRA_AL_COLOR] := GraMakeRGBColor( {124,124,255} )
      GraSetAttrLine( oPS, aLAttrs )
      nY := aTxtBox[2] + (aTxtBox[4] - aTxtBox[2]) /2 

      GraLine( oPS, {aItemBG[1] + ITEM_SPACING,nY},{aItemBG[3] - ITEM_SPACING *2,nY} )
   ENDIF

RETURN self


//
// Function for computing the dimensions of menubar entries.
// The dimensions are computed based on the textbox
// required for drawing an item's caption string.
//
STATIC FUNCTION MeasureMenubarItem( oDlg, oMbar, nItem, aDims )

 LOCAL oPS
 LOCAL cStr
 LOCAL cTmp
 LOCAL oFnt
 LOCAL aBox

   oPS  := AppDesktop():lockPS()
   oFnt := GraSetFont( oPS )

   cStr := oMbar:getItem(nItem)[1]:title
   cTmp := StrTran( cStr, "~" )

   aBox := GraQueryTextBox( oPS, cTmp )

   aDims[1] := aBox[3,1] - aBox[2,1]
   aDims[2] := oFnt:width + ITEM_SPACING *2
   AppDesktop():unlockPS()

RETURN oMbar


//
// Function for rendering the menubar entries. These
// are represented only via their caption string.
//
STATIC FUNCTION DrawMenubarItem( oDlg, oMbar, oPS, aInfo )

 LOCAL aItem   := oMbar:getItem( aInfo[1] )
 LOCAL aSAttrs := Array( GRA_AS_COUNT )
 LOCAL aAAttrs := Array( GRA_AA_COUNT)

   IF BAnd(aInfo[3], XBP_DRAWSTATE_SELECTED) != 0
     aAAttrs[GRA_AA_COLOR] := XBPSYSCLR_WINDOW
   ELSE
     aAAttrs[GRA_AA_COLOR] := XBPSYSCLR_3DFACE
   ENDIF

   GraSetAttrArea( oPS, aAAttrs )
   // Check whether the application runs on
   // Windows XP with Themes enabled. If yes,
   // adjust the background rectangle (separator).
   IF IsThemeActive(.F.) == .T.
      GraBox( oPS, {aInfo[4][1],aInfo[4][2]+1},{aInfo[4][3],aInfo[4][4]}, GRA_FILL )
   ELSE
      GraBox( oPS, {aInfo[4][1],aInfo[4][2]},  {aInfo[4][3],aInfo[4][4]}, GRA_FILL )
   ENDIF

   aSAttrs[GRA_AS_VERTALIGN] := GRA_VALIGN_HALF
   GraSetAttrString( oPS, aSAttrs )

   oPS:DrawCaptionStr( {aInfo[4][1] + ITEM_SPACING,aInfo[4][2]}, {aInfo[4][3],aInfo[4][4]}, aItem[1]:title )

RETURN oMBar

#endif