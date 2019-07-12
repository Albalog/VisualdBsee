// #ifdef IE4_STYLE

/*

 Configuration
 New()
 :Caption     "text or bitmap"
 :type       default = XBPSTATIC_TYPE_TEXT
 :IconType   default = XBPSTATIC_TYPE_ICON
 :Activate   default = {|| NIL }



 Sample button

  oXbp := Ie4Button():New( oStatic, , { 271,1 }, { 90, 56 } )
  oXbp:Icon     :=   PRINTER_ICON
  oXbp:Caption := "Print"
  oXbp:Activate := {|x,y,obj| PrinterFunction( oDlg )  }
  oXbp:Create()
  oXbp:HelpLink := MagicHelpLabel():New( "Print information in the calculator window." )



  Sorry no notes in the code maybe next time.......  BR



 */

#include "xbp.ch"
#include "gra.ch"

// Aggiunto pointerFocus per compatibilit… con xbpPushButton, non funziona



CLASS IE4Button FROM XbpStatic
   HIDDEN
     VAR oIcon       // the icon, is showed only if ::icon <> 0
     VAR oStatic     // the text
     VAR oFrame      // the static that shows the rectangle
     VAR lFocus, enabled, originalcolor, IconColor
     VAR aPrevPos

     INLINE METHOD PosChanged(n1, aPos)
        LOCAL lRet := ::aPrevPos[n1][1] != aPos[1] .OR. ;
                      ::aPrevPos[n1][2] != aPos[2]
        IF lRet
           ::aPrevPos[n1] := aPos
        ENDIF
     RETURN lRet

   EXPORTED
     VAR Caption
     VAR Icon
     VAR activate
     VAR Size
     VAR lastPos
     VAR button
     VAR Type
     VAR IconType

     VAR pointerFocus  // does nothing
     VAR iconNoFocus   // the icon to show when the mouse is over the button
     VAR IconFocus     // the icon to show when the mouse isn't over the button
     VAR IconDisabled  // the icon to show when the button is disabled
     VAR lRaised       // show the rectangle around the button
     VAR toolTipText   // text of the tooltip
     VAR FGColorFocus
     VAR FGColorNoFocus
     VAR FGColorDisabled
     VAR lInvertOnDisable

     // Simone 22/3/06
     // mantis 0001016: poter impostare altezza toolbar a livello di progetto per usare icone più grandi
     VAR lCenter       // centra testo/immagine

     METHOD init,create, focus, activate, disable, enable, Invert
     METHOD hilite, dehilite

     INLINE METHOD isHilited(); RETURN ::lFocus
     INLINE METHOD isEnabled(); RETURN ::enabled

     INLINE METHOD UpdIcon(oImg)
        ::oStatic:setCaption(oImg)
     RETURN self
ENDCLASS

METHOD IE4Button:init( oParent, oOwner, aPos, aSize, aPresParm, lVisable )
   ::XbpStatic:init( oParent, oOwner, aPos, aSize, aPresParm, lVisable )
   // ::oStatic := XbpStatic():New( ::XbpStatic )
   ::Caption := ''    // Text
   ::Icon := 0
   ::IconType := XBPSTATIC_TYPE_ICON
   ::activate := {|| NIL }
   ::lFocus := .F.
   ::Size := IIF(aSize <>  NIL, ACLONE(aSize), NIL)
   ::XbpStatic:Motion := {|aPos,u,oS| ::Focus( aPos, 1 ) }
   ::type := XBPSTATIC_TYPE_TEXT
   ::Lastpos := {-1,-1}
   ::enabled := .T.
   ::button := .F.
   ::FGColorFocus    := GRA_CLR_BLUE
   ::FGColorNoFocus  := GRA_CLR_BLACK
   ::FGColorDisabled := GRA_CLR_WHITE
   ::lRaised := .T.   // Show the rectangle around the button
                      // when mouse is over
   ::lInvertOnDisable := .T.
   ::lCenter := .F.
   ::aPrevPos  := { {NIL,NIL},{NIL,NIL},{NIL,NIL},{NIL,NIL} }
RETURN self

METHOD IE4Button:Create( oParent, oOwner, aPos, aSize, aPresParm, lVisable )
   LOCAL lAutoSize := ::autoSize
   ::autoSize := .F.

   ::XbpStatic:Create( oParent, oOwner, aPos, aSize, aPresParm, lVisable )
   ::Size := IIF( aSize <> NIL, ACLONE(aSize), ::Size )

   ::oStatic := XbpStatic():New( )
   //::XbpStatic, , { 1, 1 }, { ::Size[1]-2, IIF( ::type == XBPSTATIC_TYPE_TEXT, 13, ::Size[ 2 ]-2  ) } )
   ::oStatic:Type := ::type
   ::oStatic:Caption := ::Caption

   IF ::type == XBPSTATIC_TYPE_TEXT
      IF ::Options == NIL
         ::oStatic:Options := XBPSTATIC_TEXT_CENTER + XBPSTATIC_TEXT_VCENTER
      ELSE
         ::oStatic:Options := ::Options
      ENDIF
   ELSE
      ::iconNoFocus := ::caption
   ENDIF

   ::oStatic:Motion := {|aPos,u,oS| ::Focus( {aPos[1]-2,aPos[2]-2 }, 2 ) }

   aPos  := IIF(::lRaised, {2,2}, {0,0} )
   aSize := {0,0}
   IF lAutoSize
      ::oStatic:autoSize := .T.
   ELSE
      aSize := { ::Size[1]-4,;
                 IIF( ::type <> XBPSTATIC_TYPE_TEXT .OR. EMPTY(::Icon), ;
                      ::Size[ 2 ]-4, 13  ) }
   ENDIF

   ::oStatic:Create( ::XbpStatic, NIL, aPos, aSize )

   IF ::oStatic:autoSize
      ::size := ::oStatic:currentSize()
      IF ::lRaised
         ::size[1] := ::Size[1]+4
         ::size[2] := IIF( ::type <> XBPSTATIC_TYPE_TEXT .OR. EMPTY(::Icon), ;
                           ::Size[ 2 ]+4, 13  )
      ENDIF
      ::setSize(::size)

   ENDIF

   ::oFrame := XbpStatic():New( ::XbpStatic, , {0,0}, ::Size  )
   //::oFrame := XbpStatic():New( ::XbpStatic, , {-aSize[1], -aSize[2]}, ::Size  )


   ::XbpStatic:lbDown := {| aPos| ::activate( aPos,.F.)  }
   ::XbpStatic:lbUp   := {| aPos| ::activate( aPos,.T.)  }
   ::button := .F.

   // Simone 22/3/06
   // mantis 0001016: poter impostare altezza toolbar a livello di progetto per usare icone più grandi
   // centra immagine 
   IF ::lCenter .AND. ;
      ::type <> XBPSTATIC_TYPE_TEXT .OR. EMPTY(::Icon)

      // prende dimensione testo/bitmap
      oParent := XbpStatic():new()
      oParent:autoSize:= .T.
      oParent:caption := ::oStatic:caption
      oParent:type    := ::oStatic:type
      oParent:create(::XbpStatic, NIL, {-1000, -1000}, NIL, NIL, .F.)
      aSize := oParent:currentSize()
      oParent:destroy()
      oParent := NIL

      // trova differenza fra altezza immagine e pulsante
      oParent := ACLONE(aSize) // appoggio su oParent
      aSize := {::currentSize()[1] - aSize[1] , ;
                ::currentSize()[2] - aSize[2]}

      // se c' differenza centra immagine verticalmente
      IF aSize[1] != 0 .OR. aSize[2] != 0
         aPos  := { ROUND(aSize[1]/2, 0), ;
                    ROUND(aSize[2]/2, 0)  }
         aSize := oParent
         ::oStatic:setPosAndSize(aPos, aSize)
      ENDIF
   ENDIF

   IF ! EMPTY(::Icon)
      ::oIcon := XbpStatic():New( ::XbpStatic, , { (::Size[1]/2) - 16 , 14 }, {  32, 32  } )
      ::oIcon:Type := ::Icontype  //XBPSTATIC_TYPE_ICON
      ::oIcon:Caption := ::Icon
      ::oIcon:Motion := {|aPos,u,oS|  ::Focus( { aPos[1] - ( ( ::Size[1]/2 ) - 16 )  ,  aPos[2]- 14 }, 3 )}
      ::oIcon:Create()
      ::iconNoFocus := ::icon
   ENDIF

RETURN self

METHOD IE4Button:Focus( aPos, nObj )
   IF ::XbpStatic <> NIL .AND. ::XbpStatic:Status() <> XBP_STAT_INIT .AND. ;
      ::posChanged(nObj, aPos)

      IF ! ::lFocus .AND. aPos[1] >=0 .AND. aPos[2] >=0 .AND. ;
         aPos[1]<= ::Size[1] .AND. aPos[2]<= ::Size[2]  .AND. ::enabled

         ::hilite()

      ELSEIF !( aPos[1] >=0 .AND. aPos[2] >=0 .AND. ;
                aPos[1]<= ::Size[1] .AND. aPos[2]<= ::Size[2] )
             // .AND. ! ::button
         ::dehilite()
      ENDIF
   ENDIF
RETURN NIL

METHOD IE4Button:hilite()
IF ! ::lFocus .AND. ::enabled
   IF ::iconFocus != NIL
      IF EMPTY(::icon)
         ::oStatic:setCaption(::iconFocus)
         ::oStatic:configure()
      ELSE
         ::oIcon:setCaption(::iconFocus)
         ::oIcon:configure()
      ENDIF
   ENDIF

   IF ::lRaised
      ::oFrame:Type := XBPSTATIC_TYPE_RAISEDRECT
      ::oFrame:Motion := {|aPos,u,oS| ::Focus( aPos, 4 ), ::XbpStatic:CaptureMouse( .T. ) }
      ::oFrame:Create()
   ENDIF

   ::lFocus := .T.
   ::XbpStatic:CaptureMouse( .T. )
   IF ::oStatic:type == XBPSTATIC_TYPE_TEXT
      ::oStatic:SetColorFG( ::FGColorFocus )
   ENDIF
ENDIF

RETURN self

METHOD IE4Button:dehilite()
   IF ! ::button .AND. ::lFocus  .AND. ;
         ( ::iconFocus!=NIL .OR. ;
            (::lRaised .AND. ::oFrame <> NIL .AND. ;
            ::oFrame:Status() <> XBP_STAT_INIT)   )

      IF ::iconFocus != NIL
         IF EMPTY(::icon)
            ::oStatic:setCaption(::iconNoFocus)
            ::oStatic:configure()
         ELSE
            ::oIcon:setCaption(::iconNoFocus)
            ::oIcon:configure()
         ENDIF
      ENDIF

      IF ::lRaised
         ::oFrame:Destroy()
      ENDIF

      ::lFocus := .F.
      ::XbpStatic:CaptureMouse( .F. )
      IF ::oStatic:type == XBPSTATIC_TYPE_TEXT  .AND. ::enabled
         ::oStatic:SetColorFG( ::FGColorNoFocus )
      ENDIF

   ENDIF
RETURN self


METHOD IE4Button:Activate( aPos, lUp )
   IF ::XbpStatic <> NIL .AND.;
      ::XbpStatic:Status() <> XBP_STAT_INIT .AND. ::Enabled
      IF lUp
         IF ::lFocus .AND. ::lRaised
            ::oFrame:Type := XBPSTATIC_TYPE_RAISEDRECT
            ::oFrame:Configure()
         ENDIF
         ::button := .F.
         IF aPos[1] >=0 .AND. aPos[2] >=0 .AND. aPos[1]<= ::Size[1] .AND. aPos[2]<= ::Size[2]
            ::XbpStatic:CaptureMouse( .F. )
            eval( ::Activate, , , self )
            IF ::lFocus .AND. ::enabled                       //could have been turned off
               ::XbpStatic:CaptureMouse( .T. )
            ENDIF
         ENDIF

      ELSEIF ::lFocus
         IF ::lRaised
            ::oFrame:Type :=  XBPSTATIC_TYPE_RECESSEDRECT
            ::oFrame:Configure()
         ENDIF
         ::Button := .T.
      ENDIF
   ENDIF
RETURN NIL

METHOD IE4Button:Disable()
   IF ::oStatic:type <> XBPSTATIC_TYPE_TEXT
      // Simone 28/8/06
      // mantis 0001130: dare possibilità di impostare icone toolbar disabilitate/focused   
      IF ! EMPTY(::iconDisabled)
         ::oStatic:setCaption(::iconDisabled)
      ELSEIF ::lInvertOnDisable
         ::oStatic:Paint := {|x,y,obj| ::invert(obj) }
         ::oStatic:invalidaterect()
      ELSE
         ::oStatic:disable()
      ENDIF
   ELSE
      ::oStatic:SetColorFG( ::FGColorDisabled )
   ENDIF
   IF ! EMPTY(::icon)
      IF ::lInvertOnDisable
         ::oIcon:Paint := {|x,y,obj| ::invert(obj)  }
         ::oIcon:invalidateRect()
      ELSE
         ::oIcon:disable()
      ENDIF
   ENDIF
   ::enabled := .F.
   ::button := .F.
   ::XbpStatic:CaptureMouse( .F. )
RETURN  .T.

METHOD IE4Button:Enable()
   IF ::oStatic:type == XBPSTATIC_TYPE_TEXT
      ::oStatic:SetColorFG( ::FGColorNoFocus )
   ENDIF
   // Simone 28/8/06
   // mantis 0001130: dare possibilità di impostare icone toolbar disabilitate/focused   
   IF ! EMPTY(::iconDisabled)
      ::oStatic:setCaption(::iconNoFocus)
   ELSEIF ::lInvertOnDisable
      ::oStatic:Paint := {|| NIL }
      ::oStatic:invalidaterect()
      IF ! EMPTY(::icon)
         ::oIcon:paint := {|| NIL }
         ::oIcon:invalidateRect()
      ENDIF
   ELSE
      ::oStatic:enable()
      IF ! EMPTY(::icon)
         ::oIcon:enable()
      ENDIF
   ENDIF
   ::enabled := .T.
RETURN  .T.

METHOD IE4Button:invert(obj)
   LOCAL oP
   IF obj <> NIL .AND. obj:status() <> XBP_STAT_INIT
      oP := obj:LockPs()
      GraBitBlt( oP, oP,{0,0,31,31},{0,0,31,31}, GRA_BLT_ROP_DSTINVERT  )
      obj:unlockps( oP )
   ENDIF
RETURN NIL

// #ELSE
//
// FUNCTION IE4DUMMY()
// RETURN NIL
//
// #ENDIF
