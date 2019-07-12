/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "common.ch"
#include "Xbp.ch"

/*
 * This directive calculates a centered position
 */
#xtranslate  CenterPos( <aSize>, <aRefSize> ) => ;
             { Int( (<aRefSize>\[1] - <aSize>\[1]) / 2 ), ;
               Int( (<aRefSize>\[2] - <aSize>\[2]) / 2 ) }

/*
 * This procedure displays an image file in a separate window
 */
FUNCTION dfLoadRaw(cFile, nInkey, oOwner )
   LOCAL oDlg, oImage, oPS, aSize, aPos
   LOCAL lRet := .F.

   DEFAULT nInkey TO 0

  /*
   * Only bitmap and meta files are supported
   */
   IF cFile <> NIL            .AND. ;
     ( ".BMP" $ Upper( cFile ) .OR. ;
       ".GIF" $ Upper( cFile ) .OR. ;
       ".JPG" $ Upper( cFile ) .OR. ;
       ".PNG" $ Upper( cFile ) .OR. ;
       ".EMF" $ Upper( cFile ) .OR. ;
       ".MET" $ Upper( cFile )      ) .AND. ;
     FILE(cFile)

     /*
      * Create hidden dialog window
      */
      oDlg := XbpDialog():new( AppDesktop(),oOwner,,{100,100} )
      oDlg:taskList := .F.
      oDlg:visible  := .F.
      oDlg:title    := cFile
      oDlg:create()


     /*
      * Create a presentation space and connect it with the device
      * context of :drawingArea
      */
      oPS := XbpPresSpace():new():create( oDlg:drawingArea:winDevice() )

      IF ".BMP" $ Upper( cFile ) .OR. ;
         ".GIF" $ Upper( cFile ) .OR. ;
         ".JPG" $ Upper( cFile ) .OR. ;
         ".PNG" $ Upper( cFile ) 
        /*
         * File contains a bitmap. Limit the window size to a range
         * between 16x16 pixel and the screen resolution
         */
         oImage   := S2XbpBitmap():new():create( oPS )
         lRet := oImage:loadFile( cFile )

         aSize    := { oImage:xSize, oImage:ySize }
         aSize[1] := Max( 16, Min( aSize[1], AppDeskTop():currentSize()[1] ) )
         aSize[2] := Max( 16, Min( aSize[2], AppDeskTop():currentSize()[2] ) )
         aSize    := oDlg:calcFrameRect( {0,0, aSize[1], aSize[2]} )

         oDlg:setSize( {aSize[3], aSize[4]} )

         /*
          * The window must react to xbeP_Paint to redraw the bitmap
          */
         oDlg:drawingarea:paint := {|x,y,obj| x:=obj:currentSize(), ;
                                              oImage:draw( oPS, {0, 0, x[1], x[2]}, ;
                                                                {0, 0, oImage:xSize, oImage:ySize} ), Sleep(0.1) }
      ELSE
        /*
         * Display a meta file. It has no size definition for the image
         */
         oImage := XbpMetafile():new():create()
         lRet := oImage:load( cFile )
         aSize := { 600, 400 }
         oDlg:setSize( aSize )
         oDlg:drawingarea:paint := {|| oImage:draw( oPS, XBPMETA_DRAW_SCALE ), Sleep(0.1) }

      ENDIF

      IF lRet
         /*
         * Display the window centered on the desktop
         */
         aPos:= CenterPos( oDlg:currentSize(), AppDesktop():currentSize() )
         oDlg:setPos( aPos )
         oDlg:show()
         SetAppFocus( oDlg )

         WaitEvent(oDlg, nInkey)

         oImage:destroy()
      ENDIF

      oPS:destroy()
      oDlg:destroy()

   ENDIF
RETURN lRet

STATIC PROCEDURE WaitEvent(oDlg, nInkey)
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL lLoop := .T.
   LOCAL nExit := IIF(nInkey > 0, SECONDS()+nInkey, NIL)

   oDlg:close    := {|| lLoop := .F.  }
   oDlg:keyboard := {|| lLoop := .F.  }

   DO WHILE lLoop
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp, 10, oDlg )
      IF oXbp != NIL
         oXbp:HandleEvent(nEvent, mp1, mp2)
      ENDIF

      IF nExit != NIL .AND. SECONDS() >= nExit
         lLoop := .F.
      ENDIF
   ENDDO
RETURN

