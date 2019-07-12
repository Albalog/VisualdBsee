//////////////////////////////////////////////////////////////////////
//
//  TOOLTIP.PRG
//
//  Copyright:
//      Alaska Software Inc., (c) 1997. All rights reserved.
//
//  Contents:
//      Tooltip help system
//
//////////////////////////////////////////////////////////////////////

#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "common.ch"

#include "dfSet.ch"
#include "dfMsg1.ch"
#include "dfStd.ch"
#include "dfXbase.ch"

//
// PROCEDURE Main
//    LOCAL nEvent, mp1:=0, mp2:=0
//    LOCAL oDlg, oXbp, drawingArea, oXbp1
//    LOCAL oHelp
//
//    SET DEFAULT TO "..\..\DATA"
//
//    oHelp := MagicHelp():New()
//
//    oDlg := XbpDialog():new( AppDesktop() , , {172,80}, {487,315}, , .F.)
//    oDlg:taskList := .T.
//    oDlg:title := "SampleDialog"
//    oDlg:visible := .F.
//    oDlg:maxSize := oDlg:currentSize()
//    oDlg:create()
//    oDlg:helpLink := MagicHelpLabel():New(1)
//
//    drawingArea := oDlg:drawingArea
//    drawingArea:setColorBG( GRA_CLR_PALEGRAY   )
//    drawingArea:setFontCompoundName( FONT_HELV_SMALL )
//
//    oXbp1 := XbpStatic():new( drawingArea, , {12,12}, {456,60} )
//    oXbp1:clipSiblings := .T.
//    oXbp1:type := XBPSTATIC_TYPE_RAISEDBOX
//    oXbp1:create()
//    oXbp1:helpLink := MagicHelpLabel():New(2)
//
//    oXbp := XbpPushButton():new( oXbp1, , {12,12}, {96,24} )
//    oXbp:caption := "Pushbutton"
//    oXbp:clipSiblings := .T.
//    oXbp:create()
//    oXbp:activate := {|| NIL }
//    oXbp:helpLink := MagicHelpLabel():New(10)
//
//    oXbp := XbpPushButton():new( oXbp1, , {120,12}, {96,24} )
//    oXbp:caption := "Pushbutton"
//    oXbp:clipSiblings := .T.
//    oXbp:create()
//    oXbp:activate := {|| NIL }
//    oXbp:helpLink := MagicHelpLabel():New(11)
//
//    oXbp := XbpPushButton():new( oXbp1, , {240,12}, {96,24} )
//    oXbp:caption := "Pushbutton"
//    oXbp:clipSiblings := .T.
//    oXbp:create()
//    oXbp:activate := {|| NIL }
//    oXbp:helpLink := MagicHelpLabel():New(12)
//
//    oXbp := XbpPushButton():new( oXbp1, , {348,12}, {96,24} )
//    oXbp:caption := "Pushbutton"
//    oXbp:clipSiblings := .T.
//    oXbp:create()
//    oXbp:activate := {|| NIL }
//    oXbp:helpLink := MagicHelpLabel():New(13)
//
//
//    oXbp := XbpStatic():new( drawingArea, , {12,192}, {84,24} )
//    oXbp:caption := "Firstname"
//    oXbp:clipSiblings := .T.
//    oXbp:options := XBPSTATIC_TEXT_VCENTER
//    oXbp:create()
//
//    oXbp := XbpSLE():new( drawingArea, , {96,192}, {372,24} )
//    oXbp:clipSiblings := .T.
//    oXbp:create()
//    oXbp:helpLink := MagicHelpLabel():New(6)
//
//
//    oXbp := XbpStatic():new( drawingArea, , {12,156}, {84,24} )
//    oXbp:caption := "Lastname"
//    oXbp:clipSiblings := .T.
//    oXbp:options := XBPSTATIC_TEXT_VCENTER
//    oXbp:create()
//
//    oXbp := XbpSLE():new( drawingArea, , {96,156}, {372,24} )
//    oXbp:clipSiblings := .T.
//    oXbp:create()
//    oXbp:helpLink := MagicHelpLabel():New(7)
//
//
//    oXbp := XbpStatic():new( drawingArea, , {12,120}, {84,24} )
//    oXbp:caption := "Address1"
//    oXbp:clipSiblings := .T.
//    oXbp:options := XBPSTATIC_TEXT_VCENTER
//    oXbp:create()
//
//    oXbp := XbpSLE():new( drawingArea, , {96,120}, {372,24} )
//    oXbp:clipSiblings := .T.
//    oXbp:create()
//    oXbp:helpLink := MagicHelpLabel():New(8)
//
//
//    oXbp := XbpStatic():new( drawingArea, , {12,84}, {84,24} )
//    oXbp:caption := "Address2"
//    oXbp:clipSiblings := .T.
//    oXbp:options := XBPSTATIC_TEXT_VCENTER
//    oXbp:create()
//
//    oXbp := XbpSLE():new( drawingArea, , {96,84}, {372,24} )
//    oXbp:clipSiblings := .T.
//    oXbp:create()
//    oXbp:helpLink := MagicHelpLabel():New(9)
//
//
//    oXbp := XbpStatic():new( drawingArea, , {12,228}, {456,48} )
//    oXbp:caption := "MagicHelp Sample"
//    oXbp:clipSiblings := .T.
//    oXbp:options := XBPSTATIC_TEXT_VCENTER
//    oXbp:setColorFG(GRA_CLR_WHITE)
//    oXbp:setColorBG(GRA_CLR_BLACK)
//    oXbp:setFontCompoundName(FONT_HELV_LARGE+FONT_STYLE_BOLD)
//    oXbp:create()
//
//    oDlg:show()
//    SetAppWindow(oDlg); SetAppFocus( oDlg)
//    oHelp:start()
//
//    nEvent := xbe_None
//    DO WHILE nEvent <> xbeP_Close
//       nEvent := AppEvent( @mp1, @mp2, @oXbp )
//       oXbp:handleEvent( nEvent, mp1, mp2 )
//    ENDDO
// RETURN
//
// PROCEDURE APPSYS()
// RETURN
//
// PROCEDURE DBESYS()
// LOCAL lSuccess:= .T.
//
//   IF !DbeLoad( "CDXDBE",.T.)
//    lSuccess := .F.
//   ENDIF
//
//   IF ! DbeLoad( "FOXDBE",.T.)
//    lSuccess := .F.
//   ENDIF
//
//   IF ! DbeBuild( "FOXCDX", "FOXDBE", "CDXDBE" )
//    lSuccess := .F.
//   ENDIF
//   IF !lSuccess
//      Alert( "FOXCDX Database-Engine;could not be built" , {"OK"} )
//   ENDIF
// RETURN


FUNCTION dfTooltipMagicHelpON()
   MagicHelp():nMinChars := 15
RETURN .T.
FUNCTION dfTooltipMagicHelpOFF()
   MagicHelp():nMinChars :=  0
RETURN .T.
FUNCTION dfTooltipMagicHelpSetChar(nChar)
   LOCAL nOld := MagicHelp():nMinChars
   IF !EMPTY(nChar) .AND. VALTYPE(nChar) == "N"
      MagicHelp():nMinChars :=  nChar
   ENDIF 
RETURN .T.



CLASS MagicHelp FROM Thread

  HIDDEN:
  METHOD DisplayToolTip()
  METHOD PaintTheTip()

  EXPORTED:
  VAR producerID
  VAR oLastMotionXBP
  VAR oLastTipXBP
  VAR oBlockedXBP
  VAR nLastTipTime
  VAR aLastMotionPos
  VAR oTip
  VAR lTipIsShown
  VAR nTipSensitivity

  VAR oCharTip
  VAR aCharTipInfo

  CLASS VAR nMinChars // se > 0 abilita visaulizzazione tooltip caratteri rimanenti
  CLASS VAR nCharTipTimeout // tempo di timeout del tooltip

  INLINE METHOD init()
    ::nTipSensitivity := 1
    ::thread:init()
    ::producerID := ThreadID()
  RETURN

  EXPORTED:
  METHOD execute()
  METHOD atStart()
  METHOD atEnd()
  METHOD showTip()
  METHOD hideTip()
ENDCLASS

METHOD MagicHelp:atStart()
  ::lTipIsShown       := .F.
  ::oLastMotionXBP    := NIL
  ::aLastMotionPos    := NIL

  DEFAULT ::nCharTipTimeout TO 3 //secondi di timeout

  /*
   * The HELP Database and Index are located in the ..\..\DATA\
   * directory. The Index expression is as followed:
   * INDEX ON StrZero(lang_id,4,0)+StrZero(help_id,4,0) TAG ID TO MHELP
   */
//  USE MHELP.DBF INDEX MHELP.CDX SHARED
RETURN


METHOD MagicHelp:atEnd()
  // DbCloseAll()
RETURN

METHOD MagicHelp:Execute()
  LOCAL nEvent, mp1:=0, mp2:=0, oXbp:=NIL
  LOCAL nLastMotionTime := 0
  LOCAL xAvail, lShow, aTmp, oXbp1, nEvent1
  

  DO WHILE .T.

     /*
      * Because our entire Event sniffer pools events, we have
      * to go sleep after each iteration otherwise we would
      * consume to much CPU resources for nothing!
      */
     Sleep( 10 )

     // simone D 15/6/7 
     // mantis 0001243: nel tooltip visualizzare quanti caratteri rimangono alla fine del testo
     // mostra tooltip caratteri rimanenti quando
     // l'oggetto che ha il focus Š un GET 
     oXbp := SetAppFocus()

     // se attivato
     lShow  := ! EMPTY(::nMinChars) .AND. ! EMPTY(oXbp)
     xAvail := 0

     IF lShow .AND. oXbp:isDerivedFrom("S2Get")
        lShow := EMPTY(oXbp:oCombo) // se Š un GET non deve avere lookup
     ENDIF

     IF lShow

        // NOTA: Simone 30/08/07
        // ci pu• essere un errore di runtime in valutazione oXbp:datalink 
        // se il codeblock accede a variabili PRIVATE perche le private non sono visibili
        // nel thread separato 
        //
        // vedi mantis 0001320: errore su tabelle tipo CATANA,ATTANA
        // vedi modifica in DDDE.PRG

        // COMMENTATO perche dava runtime error su spinbutton e non si capiva dove accadeva il problema
        // Mantis 1616: errore in spnbutton numerico
        //lShow:=oXbp:isDerivedFrom("XbpSle")                     .AND. ;
        //       oXbp:status() == XBP_STAT_CREATE                 .AND. ;
        //       oXbp:isVisible() .AND. oXbp:isEnabled()          .AND. ; 
        //       ! EMPTY(oXbp:XbpSle:bufferLength)                .AND. ;
        //       VALTYPE(oXbp:dataLink) == "B"                    .AND. ;
        //       VALTYPE(EVAL(oXbp:dataLink)) == "C"              .AND. ;
        //       oXbp:XbpSle:bufferLength > ::nMinChars           .AND. ;
        //       ((xAvail := oXbp:XbpSle:bufferLength - LEN(TRIM(oXbp:editBuffer()))) < ::nMinChars)
        //


        lShow := lShow .AND. oXbp:isDerivedFrom("XbpSle")       
        //////////////////////////////////////////////////////////
        // Mantis 1616: errore in spnbutton numerico
        lShow := lShow .AND. !oXbp:isDerivedFrom("XbpSpinButton")       
        //////////////////////////////////////////////////////////
        lShow := lShow .AND. oXbp:status()    == XBP_STAT_CREATE      
        lShow := lShow .AND. oXbp:isVisible() .AND. oXbp:isEnabled() .AND. oXbp:editable
        lShow := lShow .AND. ! EMPTY(oXbp:XbpSle:bufferLength)        
        lShow := lShow .AND. VALTYPE(oXbp:dataLink) == "B"            
        lShow := lShow .AND. VALTYPE(EVAL(oXbp:dataLink)) == "C"      
        lShow := lShow .AND. oXbp:XbpSle:bufferLength > ::nMinChars   
        lShow := lShow .AND. ((xAvail := oXbp:XbpSle:bufferLength - LEN(TRIM(oXbp:editBuffer()))) < ::nMinChars)

     ENDIF

     xAvail := MAX(0, xAvail)

     IF lShow                       

        IF EMPTY(::aCharTipInfo)    
           ::aCharTipInfo := {oXbp, xAvail, NIL}
        ENDIF

        IF ::aCharTipInfo[1] != oXbp   .OR. ;
           ::aCharTipInfo[2] != xAvail .OR. ;
           ::aCharTipInfo[3] == NIL

           ::aCharTipInfo[1] := oXbp
           ::aCharTipInfo[2] := xAvail
           ::aCharTipInfo[3] := SECONDS() + ::nCharTipTimeout // aggiorna secondi timeout

        ELSEIF ::aCharTipInfo[3] < SECONDS()   // se niente Š cambiato e sono passati gi… X secondi 
           lShow := .F.                        // spengo il tooltip

        ELSEIF ::oCharTip != NIL
           // simone 17/6/09
           // riga XL 286 nascondo il chartip se ci clicco sopra
           nEvent1 := AppEvent(NIL,NIL,@oXbp1, 10)
           IF oXbp1 != NIL .AND. ;
              oXbp1 == ::oCharTip .AND. ;
              nEvent1 $ {xbeM_LbDown, xbeM_MbDown, xbeM_RbDown, ;
                        xbeM_LbUp  , xbeM_MbUp  , xbeM_RbUp  , ;
                        xbeM_LbClick, xbeM_MbClick, xbeM_RbClick, ;
                        xbeM_LbDblClick, xbeM_MbDblClick, xbeM_RbDblClick}
              lShow := .F.
              ::aCharTipInfo[3] := SECONDS() -1 // lo metto come da non far vedere nuovamente
           ENDIF
        ENDIF
        
     ENDIF

        
     IF lShow

        IF ::oCharTip != NIL .AND. ::oCharTip:cargo != oXbp
           ::oCharTip:hide()
           ::oCharTip:destroy()
           ::oCharTip := NIL
        ENDIF

        IF ::oCharTip == NIL
           ::oCharTip := XbpStatic():new()
           ::oCharTip:options := XBPSTATIC_TYPE_FGNDFRAME
           ::oCharTip:create(AppDesktop(),AppDesktop(), ;
                             calcAbsolutePosition({0, -20}, oXbp), { 0 , 0 })
           ::oCharTip:cargo := oXbp
        ENDIF


        // Messaggio "Caratteri disponibili: xx"
        xAvail := dfMsgTran(dfStdMsg1(MSG1_TOOLTIPMINCHARS), "nchars="+ALLTRIM(STR(xAvail)))

        // aggiorna il tooltip
        ::PaintTheTip(xAvail, ::oCharTip, 1)

     ELSEIF ::oCharTip != NIL
        ::oCharTip:hide()
        ::oCharTip:destroy()
        ::oCharTip := NIL
     ENDIF

     /*
      * here we go, using LastAppEvent to sniff into the event
      * queue of another thread
      */
     nEvent := LastAppEvent(@mp1,@mp2,@oXbp,::producerID)

     IF oXbp == NIL
        LOOP
     ENDIF

     // Simone 11/10/2010
     // mantis 0002094: Il tooltip di help sulla toolbar o dei caratteri rimanenti non si attiva se vi Š un control realtime sulla form 
     IF nEvent == xbeP_User+EVENT_REALTIME // fix per realtime
        IF EMPTY(::oLastMotionXBP) .OR. EMPTY(::aLastMotionPos)
           LOOP
        ENDIF
        nEvent := xbeM_Motion
        oXbp := ::oLastMotionXBP
        mp1 := aclone(::aLastMotionPos)
     ENDIF

     /*
      * Because XbpIWindows are not in our interest in
      * terms of User-Related semantics we take the parent
      */
     IF(oXbp:isDerivedFrom("XbpIWindow"))
       oXbp := oXbp:setParent()
     ENDIF

     /*
      * blocked XBP have input focus and have to be left out
      * in the tip heuristics
      */
     IF(ValType(::oBlockedXBP)=="O" .AND.;
        oXbp == ::oBlockedXBP )
       LOOP
     ENDIF

     /*
      * Only motion events are relevant to detect situations at which
      * we have to post a tip.
      */
     IF(nEvent == xbeM_Motion)

       /*
	* Ok, a motion event has occured, and it was not over the
	* XBP which is blocked - means of input-focus - so we
	* remove the block
	*/
       ::oBlockedXBP := NIL

       /*
	* We check here if the motion was again over the same XBP as the
	* last motion event was, then we validate for the same mouse pos.
	* If thats all the case we only have to ensure that the
	* ::nTipSensitivity timeframe was reached, if so we post the tip.
	*/
       IF ( ValType( ::oLastMotionXBP) == "O" .AND. oXbp == ::oLastMotionXBP )

         IF( ::aLastMotionPos[1] == mp1[1] .AND. ;
            ::aLastMotionPos[2] == mp1[2] )

            IF((Seconds() - nLastMotionTime) > ::nTipSensitivity )
               ::showTip()
            ENDIF

         ELSE
            ::aLastMotionPos := AClone(mp1)
            nLastMotionTime := Seconds()
         ENDIF
       /*
	* Check if the current XBP we are over has the same parent
	* as the XBP for which we have posted the last TIP. In that
	* case we check out if the timeframe between these two actions
	* was under half a second. Are all prev. conditions fullfilled
	* we assume the user is interested in another tip for the XBP
	* in the neighborhood of its current - so it goes.
	*/
       ELSEIF ( ValType(::oLastTipXBP) == "O" .AND. ;
                oXbp:setParent() == ::oLastTipXBP:setParent() .AND. ;
                oXbp != ::oLastTipXBP )

         ::hideTip()
         ::oLastMotionXBP  := oXbp
         ::aLastMotionPos  := AClone(mp1)
         nLastMotionTime := Seconds()

         IF( ::nLastTipTime>0 .AND. ;
               (Seconds()-::nLastTipTime)<=0.5 )
            ::showTip()
         ENDIF

       /*
	* Ok, nothing special has occured, so we simple store the
	* event data related to the motion to be used in the next
	* pass.
	*/
       ELSE

         ::oLastMotionXBP  := oXbp
         ::aLastMotionPos  := AClone(mp1)
         nLastMotionTime   := Seconds()
         ::hideTip()
       ENDIF

     /*
      * Any event except PaintEvents has to hide the Tip in
      * addition we mark the XBP for which this event was as
      * blocked - because user-interaction via Keyboard or Mouse
      * has taken place - to avoid Tip postings while user
      * interacts with XbasePART
      */
     ELSEIF nEvent != xbeP_Paint
         IF(oXbp==::oLastTipXBP)
            ::oBlockedXBP    := oXbp
         ENDIF
         ::oLastMotionXBP := NIL
         ::hideTip()
     ENDIF

  ENDDO

RETURN

METHOD MagicHelp:showTip(cText, aPos)
  IF(!::lTipIsShown)
    DEFAULT aPos TO ::aLastMotionPos
    ::DisplayToolTip(aPos, ::oLastMotionXBP, cText)
    IF ::oTip != NIL
      ::oTip:show()
      ::lTipIsShown  := .T.
      ::oLastTipXBP  := ::oLastMotionXBP
      ::oBlockedXBP := NIL
    ENDIF
  ENDIF
RETURN

METHOD MagicHelp:hideTip()
  IF(::lTipIsShown) .AND. ::oTip != NIL
    ::oTip:hide()
    ::oTip:destroy()
    ::lTipIsShown := .F.
    ::nLastTipTime := Seconds()
  ENDIF
RETURN

METHOD MagicHelp:DisplayToolTip(aLastMotionPos, oXbpRequestingHint, cText)
   LOCAL cID   := ""
   LOCAL aPos

   /*
    * calculate absolute position of motion event and adjust it
    * about the mouse pointer size
    */
   aPos  := calcAbsolutePosition(aLastMotionPos,oXbpRequestingHint)
   aPos[1] += 6
   aPos[2] -= 30

   /*
    * Check if the XBP for which we have to post a hint has a
    * Helplabel associated with, and if so , retrieve the ID and
    * hint-message from the database
    */
   // IF(ValType(oXbpRequestingHint:helpLink)=="O" .AND. ;
   //    oXbpRequestingHint:helpLink:isDerivedFrom("MagicHelpLabel"))
   //
   //   cID := oXbpRequestingHint:helpLink:getID()
   //   IF(DbSeek(cID,.F.))
   // cText := " "+AllTrim(FIELD->HINT)+" "
   //   ENDIF
   // ENDIF

   IF cText!=NIL
      // non faccio niente
   ELSEIF IsMemberVar(oXbpRequestingHint, "cMsg") .AND. ! EMPTY(oXbpRequestingHint:cMsg)
      cText := oXbpRequestingHint:cMsg
   ELSEIF IsMemberVar(oXbpRequestingHint, "toolTipText") .AND. ! EMPTY(oXbpRequestingHint:toolTipText)
      cText := oXbpRequestingHint:toolTipText
   ENDIF

   IF VALTYPE(cText) == "B"
      cText := EVAL(cText, oXbpRequestingHint, self, ThreadID())
   ENDIF

   // IF(ValType(oXbpRequestingHint:helpLink)=="O" .AND. ;
   //    oXbpRequestingHint:helpLink:isDerivedFrom("MagicHelpLabel"))
   //
   //   cID := oXbpRequestingHint:helpLink:getID()
   //   IF(DbSeek(cID,.F.))
   // cText := " "+AllTrim(FIELD->HINT)+" "
   //   ENDIF
   // ENDIF

   /*
    * Ok, now lets paint the TIP
    */

   IF EMPTY(cText)
      ::oTip := NIL
   ELSE

      cText := " "+STRTRAN(cText, CRLF, " ")+" "

      ::oTip := XbpStatic():new()
      ::oTip:options := XBPSTATIC_TYPE_FGNDFRAME
      ::oTip:create(AppDesktop(),AppDesktop(), aPos, { 0 , 0 })
      ::PaintTheTip(cText, ::oTip)
   ENDIF

RETURN(SELF)


METHOD MagicHelp:PaintTheTip(cText, oTip, nRefresh)
   LOCAL aAttr, oPS
   LOCAL aPoints
   LOCAL aSize := {0,0}
   LOCAL aPos
   LOCAL lRefresh := .F.

   oPS := oTip:lockPS()
   aPoints := GraQueryTextBox( oPS, cText)
   oTip:unlockPS()

   aSize[1] := (aPoints[3,1] - aPoints[1,1]) + 8
   aSize[2] := (aPoints[1,2] - aPoints[2,2]) + 4

   IF nRefresh != NIL // auto
      // se la dimensione diminuisce faccio refresh
      lRefresh:= aSize[1] < oTip:currentSize()[1] .OR. ;
                 aSize[2] < oTip:currentSize()[2]
   ENDIF

   // simone 15/12/04
   // se il ToolTIP Š fuori da coordinate schermo ricalcolo la posizione
   aPos := oTip:currentPos()
   IF aPos[1]+aSize[1] > Appdesktop():currentSize()[1]
      aPos[1] := Appdesktop():currentSize()[1] - aSize[1] - 2

      oTip:setPosAndSize(aPos, aSize,lRefresh)
   ELSE
      oTip:setSize(aSize,lRefresh)
   ENDIF
   oPS := oTip:lockPS()

   aAttr := Array( GRA_AA_COUNT )
   aAttr [ GRA_AA_COLOR ] := XBPSYSCLR_INFOBACKGROUND
   GraSetAttrArea( oPS, aAttr )
   aAttr := Array( GRA_AL_COUNT )
   aAttr [ GRA_AL_COLOR ] := GRA_CLR_BLACK
   GraSetAttrLine( oPS, aAttr )
   GraBox( oPS, { 0, 0}, { aSize[ 1] -1, aSize[ 2] -1 }, GRA_OUTLINEFILL)

//   aAttr := Array( GRA_AA_COUNT )
//   aAttr [ GRA_AA_COLOR ] := GRA_CLR_WHITE
//   GraSetAttrArea( oPS, aAttr )
//   GraBox( oPS, { 1, 1}, { aSize[ 1] + 4, aSize[ 2] + 4}, GRA_FILL)
//
//   aAttr := Array( GRA_AA_COUNT )
//   aAttr [ GRA_AA_COLOR ] := GRA_CLR_BLACK
//   GraSetAttrArea( oPS, aAttr )
//   GraBox( oPS, {0,1}, {aSize[1]-1,aSize[2]-1})

   GraStringAt( oPS, {4,4}, cText)

   oTip:unLockPS( oPS)
RETURN(SELF)


// CLASS MagicHelpLabel
//   CLASS VAR nLangID
//   VAR nID
//
//   INLINE CLASS METHOD initClass()
//    ::nLangID := 1
//   RETURN
//
//   INLINE METHOD init(nID)
//      ::nID := nID
//   RETURN
//
//   EXPORTED:
//   INLINE CLASS METHOD setLanguage(nID)
//      ::nLangID := nID
//   RETURN
//
//   INLINE METHOD getID()
//   RETURN(StrZero(::nLangID,4)+StrZero(::nID,4))
//
// ENDCLASS


/*
 * This function calculates the absolute position
 * from a given position relative to an XbasePART
 */
STATIC FUNCTION calcAbsolutePosition(aPos, oXbp, oDesktop)
   LOCAL aAbsPos := AClone(aPos)
   LOCAL oParent := oXbp
   LOCAL aLoop := {}    // Serve per evitare una eventuale ricorsione
   LOCAL nLoop := 2000  // Serve per evitare una eventuale ricorsione

   IF EMPTY(oDesktop)
      oDesktop := AppDesktop()
   ENDIF

   DO WHILE ! EMPTY(oParent) .AND. ;
            oParent <> oDesktop .AND. ;
            ASCAN(aLoop, oParent) == 0 .AND. ;
            --nLoop > 0

      aAbsPos[1] += oParent:currentPos()[1]
      aAbsPos[2] += oParent:currentPos()[2]

      AADD(aLoop, oParent)
      oParent := oParent:setParent()
   ENDDO
RETURN aAbsPos

FUNCTION dfCalcAbsolutePosition(aPos, oXbp, oDesktop)
RETURN calcAbsolutePosition(aPos, oXbp, oDesktop)
